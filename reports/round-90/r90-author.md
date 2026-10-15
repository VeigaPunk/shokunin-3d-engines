# r90 author — joint lifecycle lattice (phys3d_joints)

8 cells in `corpus/fixtures/phys3d_joints.gd` + child probe
`corpus/fixtures/r90_child.gd`, +8 battery rows → **225** (179 ordinary
+ 46 negative).

**Seat completion note:** the dispatched author (ds) landed the measure
probe (`corpus/live/r90-author/probes/m1.gd`, 362 lines) + driver + all
51 (case × backend × rep) measurements, then died in the 09:0x
rate-limit sweep before the fixture port. The parent completed it:
m1.gd → `r90_child.gd` verbatim; a new parent fixture implementing the
nested-boot convention (per-(case,backend) generated projects under
`res://r90bt_*/`, `timeout -s KILL 20` children, merged-log scan); pins
captured and **verified rep-stable ×2** standalone, then **225/225**
under battery context
(`corpus/live/r90-author-battery/20261015T132309103031Z/verdicts.json`).

## Cells

| arm | cases × backends | measured class |
|---|---|---|
| `sweep` | sweep ×3 | solver-priority round-trip: GP echoes -2..128 verbatim (incl. negative/over-max); Jolt collapses every set to 1 + 12 warnings; Dummy reads 0 for every set |
| `rid` | rid ×3 | freed joint RID: `is_valid()` stays true post-free (struct, not server state); `joint_get_type` reads 0; `joint_make_pin` on a freed joint silently refused; no slot recycling (`j2≠j1`, `j3∉{j1,j2}`). Dummy: `joint_create` returns an **invalid** RID outright — j1/j2/j3 all `==` the same null RID |
| `api` | api ×3 | backend classes exist in ClassDB **only under their own engine** (JoltPhysicsServer3D exists=true only under jolt; GodotPhysicsServer3D under gp; PhysicsServer3DDummy under dummy); none can_instantiate; `joint_set_enabled`, `*_solver_*_iterations`, `pin_joint_get_applied_force`, `*_jolt_flag`, `joint_set_breakable`, `joint_make_hinge_simple` all absent from `PhysicsServer3D` on every backend |
| `free_pair` | freeb, freea, freeb_dyn ×3 | freeing a jointed body's RID: GP/Jolt keep the joint typed-0 (silently cleared endpoint), reads go null. `freeb_dyn` (dynamic A freed) **crashes GP** (signal-class, deterministic 8-line prefix); Jolt/Dummy clean |
| `free_ops` | freeb_ops, freeb_twice, freeb_make, freeb_world, freeb_afterclear, freej_then_b, detachb_free ×3 | ops on a joint whose body is freed: Jolt keeps serving reads (type=0, prio=1, pin_param=0.3000…) and re-free errors; GP crashes mid-ops. `freeb_make` (make on freed body) refused on all backends (type=0). `freeb_world` (nil endpoint) accepted by GP/Jolt — type=0 world-anchored pin |
| `detach` | detachb ×3 | detach+reattach mid-flight keeps joint type on all backends; detached body holds position, reattach resumes gravity |
| `chain3` | chain3_freemid ×3 | mid-chain body free: **GP SIGSEGV (rc 134/137 class)** at next step; Jolt and Dummy clean (types cleared to 0) |
| `twopin` | twopin_hi1, twopin_hi2 ×3 | two pins at x=∓0.5 claim one body: at t=16 GP's **higher-priority pin wins** (b.x→∓0.4976, mirror-symmetric); Jolt holds symmetric midpoint (0.0556) — solver priority is a GP-only behavior |

## Crash-envelope convention

GP crash cells pin the envelope (signal-class rc ∈ {134,137,139}, sig11
marker count, stable M-prefix sha256-16, error/warning counts), never
ASLR bytes. `freeb_ops@gp` is **rep-bimodal** (crash mid-ops ~2/3 vs
clean completion ~1/3 — the ops-at-tick-7 window races the teardown
crash): the digest emits `mode_ok` admitting both named realizations
plus the shared 6-line prefix sha. Everything else is rep-stable ×3
author + ×2 folded.

## Bounds

- All float reads are 4dp-formatted in the child; positions/velocities
  are engine-version- and timestep-coupled (60 tps).
- Jolt sweep `w=12` counts the "not supported" warnings; GP's `e=3` on
  sweep/rid is teardown RID-leak census (the probe intentionally leaks
  unmade joints).
- `moved`/position traces are per-backend physical realizations, not a
  cross-backend equality claim — the pins record each backend's own
  trace.
- r89-sentinel S3 rule carried: child dirnames are built from arm/case
  literals + an explicit `[A-Za-z0-9_]` guard before any path write.

Wave-B pending seat recovery (critic/verifier/boundary/scribe).
