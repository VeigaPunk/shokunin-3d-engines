# frontier pre-measurement — PhysicsServer3D direct API (seat: scout, host: devin)

Wave-11 candidate "Godot PhysicsServer3D direct API", second in-engine server
surface, measured as the mirror of the navserver edge-constant work (r74–r78).

Measured on Godot `4.7.2.stable.arch_linux.ed1daf0bf`, `/usr/bin/godot
--headless`, 60 tps (project.godot sha256 `1fda90d4…8eac23`, byte-identical to
the r75 probe project — the only pin is
`physics/common/physics_ticks_per_second=60`; `physics/3d/run_on_separate_thread`
and `physics/3d/physics_engine` are build defaults, i.e. GodotPhysics3D,
single-thread stepping). Probe `corpus/live/frontier-physserver/proj/
fb_physserver.gd` (sha256 `a0f7d7b4…7f7bf`), runner
`corpus/live/frontier-physserver/run_arms.sh`, receipts
`corpus/live/frontier-physserver/runs/<arm>{,.r2}.{stdout.txt,stderr.txt,exit}`.
**14 arms × 2 reps = 28 runs, all exit 0, all stderr banner-only, all reps
byte-identical.** Writes issue from the deferred-`_run` (process) context
except `pp_callsite` (write+read inside `_physics_process`).

## Headline: the PhysicsServer3D edge constants are all ZERO

Every measured mutation publishes to the space query **in the same turn** —
there is no setter→sync window on this surface at all. The navserver constants
{link:2, region:3} frames have no counterpart here; the per-class edge table
collapses to `{*: 0}` for query visibility, with only *integration* (position
moving under a velocity) still living on the per-tick clock.

### Per-call edge table vs navserver constants

| call | object truth (`body_get_state`/`body_get_collision_layer`) | space query (`intersect_ray`) | edge | navserver analog / edge |
|---|---|---|---|---|
| `body_set_state(TRANSFORM)` A→B | new origin same-turn | ray misses A, hits B same-turn | **0** | `region_set_transform` / **3** |
| same, BODY_MODE_RIGID | same-turn | same-turn | **0** | — |
| `body_create`+`add_shape`+`set_space`+`set_state` | new RID valid | ray-visible same-turn; visibility lands exactly at `body_set_space` (`create_split` decompose: miss after create, miss after add_shape, HIT at set_space) | **0** | `region_create`+`region_set_map` / 2–3 |
| `body_set_shape_disabled(0,true)` | — | ray misses same-turn | **0** | `region_set_enabled`-class / 2+ |
| `body_set_collision_layer(2)`, ray mask=1 | getter returns 2 same-turn | masked ray misses same-turn | **0** | `link_set_navigation_layers` / **2** |
| `body_set_space(RID())` detach | `body_get_direct_state` → **null** for spaceless body | ray misses same-turn | **0** | `link_set_map(RID())` / **2** |
| `free_rid(body)` | — | ray misses same-turn, no error | **0** | `free_rid(region)` — zombie window 2–3 |
| `body_set_state(LINEAR_VELOCITY=6)` | vel reads back same-turn | position integrates per tick: x=0.0998,0.1995,0.2990,0.3983 at n1..n4 (≈0.1/tick at 60tps, factor ~0.9983 unexplained — damp or integrator detail) | state 0 / motion **per-tick** | — |
| write inside `_physics_process` | same-tick | ray inside `_physics_process` sees B same-tick | **0** (no callsite shift) | navserver: `_physics_process` writes shifted **+1** frame |
| `space_create()` space | `space_is_active`=**false** by default | `space_get_direct_state` rays answer fully while inactive; move edge still 0 after `space_set_active(false)` | 0 | `map_set_active(false)` → permanent-stale, query-inert regime — **NOT mirrored** |

## Answers to the brief

**(a)** `intersect_ray` sees the body at the new origin **immediately, same
turn** after `body_set_state(BODY_STATE_TRANSFORM)` — no tick edge. The old
position stops hitting in the same turn. Holds for static and rigid bodies,
for writes from process context and inside `_physics_process`
(`pp_callsite`: PPWriter wrote at physframe 4 and rayed B in the same
callback), and inside a custom `space_create` space.

**(b)** No PhysicsServer3D-vs-PhysicsDirectSpaceState timing split exists:
`body_get_state`, `body_get_direct_state` (PhysicsDirectBodyState3D
`.transform`, readable from process context — not null while the body has a
space), and `intersect_ray` all agree same-turn on every sample. The only
divergence measured: `body_get_direct_state` returns `null` for a spaceless
body while `body_get_state` still answers.

**(c)** `flush_queries()` is the force-analog that **does not exist** —
`ClassDB.class_get_method_list("PhysicsServer3D")` on this build contains no
`flush*`/`sync*`/`step*`/`update*` method (neither does `PhysicsServer2D`).
The navserver `map_force_update` two-stage collapse has no twin here, and none
is needed: there is no deferred stage to collapse. Nearest alternates on the
surface are `body_get_direct_state` (same-turn object truth, not a force) and
`body_set_state_sync_callback` (notification hook, unprobed).

## Mechanism (inference, marked)

GodotPhysics applies `body_set_state`/`body_set_space`/layer/shape writes
inline when the space isn't locked — the broadphase move happens inside the
setter, so `intersect_ray` reads live state with no commit queue. Contrast
navserver's queued setter-apply → map-rebuild pipeline behind
`map_get_iteration_id`. Corollary for authoring: the physics surface's
"per-tick flush" is the **step itself**, which only owns *integration*
(velocity→position, contact generation); it is not a commit boundary for
queries.

## Caveats / unprobed (wave-11 boundary notes)

- Measured with build-default single-thread stepping; under
  `physics/3d/run_on_separate_thread=true` mid-step writes from process
  context may lock/defer — unmeasured, worth a follow-up arm if that setting
  is in scope.
- GodotPhysics3D only; Jolt (`physics/3d/physics_engine`) unprobed.
- Query coverage is `intersect_ray` only; `intersect_shape`/`cast_motion`/
  `body_test_motion` and contact-pair generation (collision pairs are very
  plausibly step-gated even though broadphase rays are not) unprobed.
- `create_split` cannot isolate whether a body in a space is ray-visible at
  its default identity transform before `set_state` — A coincides with the
  origin; ordering fact (visibility lands at `set_space`) is unaffected.
- vel_step's 0.9983/tick factor (expected exactly 0.1 for v=6 at 60tps) is a
  loose end — likely default damping/integration, not pursued.

## Repro

```
cd corpus/live/frontier-physserver && ./run_arms.sh
# or single arm:
cd corpus/live/frontier-physserver/proj
/usr/bin/godot --headless --path . --script res://fb_physserver.gd -- --arm=mv_ladder
```

Confidence: high — 28/28 clean exits, byte-identical reps, all edges directly
observed in stdout samples. Leaf seat: no dispatch, no tracked edits, no
commits.
