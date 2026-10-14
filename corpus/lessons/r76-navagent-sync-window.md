# R76 — the setter→server-sync window is a strict per-class frame constant (Godot 4.7.2)

## Decision and evidence

NavigationServer3D mutations under a committed `NavigationAgent3D` path
resolve on TWO distinct clocks, both frame-exact on this build
(`4.7.2.stable`, 60 tps, headless):

1. **object-getter edge ≈ 1 frame** — `link_get_enabled`,
   `region_get_transform`, `map_is_active`, `link_get_iteration_id` read
   post-setter truth one physics frame after the write.
2. **query/serve edge** — the `map_get_iteration_id` bump that publishes
   dirty to agents, after which the next forcing call re-queries:
   - **link-class writes** (`set_enabled`, `set_navigation_layers`,
     endpoint moves, `free_rid`): stale at wait 0 and 1, post-sync at
     **wait ≥ 2**.
   - **region-class writes** (`set_enabled`, `set_navigation_layers`,
     `set_transform`, `set_navigation_mesh`): stale at 0/1/2, post-sync
     at **wait ≥ 3**.
   - **agent-side `navigation_layers`**: **0 — synchronous** (same-turn
     clear to `[]`), a different channel entirely.
   - **`map_set_active`**: **no edge — permanent-stale**. The map leaves
     the sync iteration: flag flips at f1, `mapiter` never bumps, dirty
     never surfaces, and the committed tuple (`reachable=true`
     included) is served through arbitrary forcing calls with NO latch —
     distinct from `mut_latch_zombie` (latch = agent early-return while
     the server still syncs; here the server never syncs). Writes queued
     while inactive flush at the normal edge after reactivation
     (restart-on-reactivation, not apply-on-write).

Inside the window the forcing update still RUNS on the last-synced map:
`mut_win_link`'s tp+mutate+wait:0 step serves the killed gate's far
endpoint `(2.5,0,5.5)` AND pops idx 2→3 across it — the r75
same-turn-zombie falsification is now a tracked CASES row. At the edge
frame itself the pre-force `peek` still shows the stale stored array:
map synced, agent not yet re-queried — the two-stage gate pinned at
frame resolution.

The constants are strict: boundary resampled 54/54 (link) + 24/24
(region) in-process transitions and 96 cross-process bisects; scribe's
independent geometry reproduced byte-identical edges with 3× repeats;
scout converged. **Callsite qualifier (measured, critic `bb_physmut`)**:
a setter issued inside `_physics_process` drains in that same tick —
the serve flips at await-count **1**, one tick shallower than the
coroutine/deferred context every CASES `wait` uses. Frame constants are
per-callsite-class.

## Same-value suppression

Writes of the already-current value are fully suppressed no-ops on every
probed channel — `link_set_enabled`, `link_set_navigation_layers`,
`link_set_travel_cost`, `region_set_enabled`, `region_set_transform`
(a full `Transform3D` value compare), `region_set_navigation_layers`,
`map_set_active`, `agent.navigation_layers` — proven by the M-witness:
teleport on-path without re-query, write same value, post-window forcing
call; suppressed ⇒ stored array byte-identical, dirtied ⇒ `path[0]`
re-anchors at the live position. `agent.navigation_layers` dedups
BEFORE its synchronous clear: same-value leaves the array intact
same-turn, an effective write clears it to `[]` instantly. **Carve-out:**
`target_position` same-value assignment is NOT suppressed — it
unlatches, clears, and lazily rematerializes (r74 `mv_reanchor_same`).

## Authoring consequences (fixture)

- `wait` in `_run_steps` counts `await physics_frame` after the step's
  mutate; consecutive steps sample cumulatively — `mutate+wait:0` IS the
  same-turn arm.
- The `_final_srv_state` readback gate sees object truth at ~1f: an arm
  whose LAST mutate must pass the gate needs ≥1 elapsed frame before
  arm end; mid-step `wait:0` mutations are fine (reviewer-verified
  bound: terminal `mutate`+`wait:0` exits 1 by design).
- `map_active` is a new `mutate` key applied last in a dict; the setup
  gate now reads `map_is_active(map) != fs["map_active"]`.

## Recheck conditions

Any engine rebuild re-runs `mut_win_*`: edges 2/3 and the
permanent-stale `map_off` pin are engine internals measured, not
specified — the first casualty of an "inactive maps still flush" change
is `mut_map_off` (by design). Physics-callsite arms would pin the
one-tick-shallower window if the fixture ever writes from
`_physics_process`. `map_force_update` collapses only the getter edge
(0), not the serve edge — a tracked `force_update` arm would close that
gap.
