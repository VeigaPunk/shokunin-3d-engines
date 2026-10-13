# r70 scout — mechanism for `navagent3d_detour.gd` (resolve: is `distance_to_target` Euclidean or path-sum?)

## Headline: the UNKNOWN is already measured-resolved

A scratch probe under `corpus/live/r70-scout/runs/probe1/` (receipt: stdout below)
built an L-corridor navmesh that forces a bent path and ran the same
SceneTree/NavigationServer3D pattern as the existing fixtures on this host's
`/usr/bin/godot` = **4.7.2.stable.arch_linux.ed1daf0bf**.

Observed (exact stdout lines):

```
PROBE detour_exact S=(0.5, 0.0, 0.5) T=(2.5, 0.0, 3.5) postproc=0 dist=3.605551 reachable=true final=(2.5, 0.0, 3.5) next=(2.0, 0.0, 1.0)
PROBE detour_exact agent_path(3)=[(0.5, 0.0, 0.5), (2.0, 0.0, 1.0), (2.5, 0.0, 3.5)] len=4.130649
PROBE detour_exact map_path(3)=[(0.5, 0.0, 0.5), (2.0, 0.0, 1.0), (2.5, 0.0, 3.5)] len=4.130649 regions=1 polys=3 euclid=3.605551
```

- `distance_to_target` = **3.605551 = sqrt(13) — EUCLIDEAN**, while the
  engine's own routed path through the reflex vertex (2,0,1) measures
  **4.130649**. The r69 UNKNOWN resolves to Euclidean on this engine build.
- `next=(2.0,0.0,1.0)` proves the routed path genuinely detours, so the
  3.605551 is not a degenerate straight corridor — the two hypotheses are
  discriminated by 0.5251, ~131x the 0.004 distance tolerance used at r69.
- Bonus semantic evidence from the disconnected arm: with `reachable=false`
  and `final=(2.5,0,1.0)` (clamped), `dist` was still 3.605551 — so the
  reference point is the authored `target_position`, not the path's
  clamped final position.

Command used:
`timeout 120 /usr/bin/godot --headless --path corpus/live/r70-scout/runs/probe1 --script res://probe_detour.gd`
(exit 0; stderr showed only a NavMap3D RID-leak warning because the probe
skips cleanup — see gotcha 2).

## How the navagent3d_* fixtures author and drive the agent (file:line)

All four share one pattern (shown for `navagent3d_distance.gd`; identical
block at `navagent3d_next.gd:10-27`, `navagent3d_follow.gd:10-28`,
`navagent3d_retarget.gd:8-26`, `navigation3d_path.gd:24-34`):

- `map_create` + `map_set_active(true)` + `map_set_cell_size(map, 0.25)` —
  navagent3d_distance.gd:20-22.
- `NavigationMesh` authored directly: `mesh.vertices = PackedVector3Array(...)`
  then `mesh.add_polygon(PackedInt32Array([0,3,2,1]))` — a single convex 4x4
  quad, vertices then **reversed-order** indices (distance.gd:24-25). No
  baking anywhere; the mesh is hand-authored.
- One `region_create` bound to map + mesh via
  `region_set_map`/`region_set_navigation_mesh` (distance.gd:26-30).
- `Node3D` actor at spawn + `NavigationAgent3D` child,
  `agent.set_navigation_map(map)` (distance.gd:31-35), then
  `agent.target_position = ...` (distance.gd:38).
- 30 `await physics_frame` settle (distance.gd:39-40), then queries:
  `distance_to_target` (41), `get_final_position` (42),
  `get_next_path_position` (43), `is_target_reached/reachable/finished`.
- `navagent3d_next.gd:30-31` reads `get_next_path_position()` BEFORE
  `get_current_navigation_path()` — required order, see gotcha 1.
- `navigation3d_path.gd:49-79` is the island precedent: a second map+region
  translated by `region_set_transform(Transform3D(..., (20,0,0)))` gives an
  unreachable target; `map_get_path` clamps the endpoint to the region
  boundary (expected marker `source_end=4.000,0.000,3.000`).
- `navagent3d_follow.gd:21,29` mounts `navfollow3d_driver.gd`, which moves the
  actor with `global_position.move_toward(agent.get_next_path_position(),
  2.0*delta)` (driver lines 14-18) — motion follows the agent's waypoint
  stream; not needed for the distance fixture.
- Battery registration: `run_battery.py` CASES rows for the nav family at
  lines 35-50 (navagent3d_distance pair at 47-50); scripts run as
  `godot --headless --path <scratch> --script res://<gd> -- <flags>`
  (run_battery.py:584-586) after `fixtures/` is copied to
  `corpus/live/runs/<ts>/scratch` (556-568).

## Mechanism evaluation — measured, not just reasoned

| option | outcome (probe) | verdict |
|---|---|---|
| Concave notch in ONE polygon | path = straight S→T, len 3.605551, `next`=target, `reachable=true` — the single polygon is walked as if convex hull | REJECTED: cannot force a detour |
| Two polys with PARTIAL edge overlap (B's bottom edge a sub-segment of A's top edge) | no connection: `reachable=false`, path clamped to (2.5,0,1.0), len 2.061553 | REJECTED: partial edges do not connect; default `edge_connection_margin` = 0.2500 does not rescue sub-segments |
| Second disconnected polygon island | clamps endpoint (same behavior as navigation3d_path.gd:65-75) | wrong discrimination — tests reachability, not distance semantics |
| NavigationObstacle3D carving | not probed — obstacle constrains avoidance/RVO only; `distance_to_target` is a map path query, structurally unaffected | rejected by API role (inference, not measured) |
| `navigation_layers` mask | viable but strictly heavier: needs two corridors plus layer plumbing on agent query | not minimal |
| **Multiple convex polys sharing EXACT full edges** | connects; path bends through reflex vertex (2,0,1); len 4.130649 | CHOSEN — minimal at 3 quads |

## Chosen design for `navagent3d_detour.gd` (hand-derived, probe-verified)

One region, one `NavigationMesh`, **three convex quads** forming an L inside
the familiar 4x4 footprint; every shared edge is a complete edge of both
polygons:

```
A1  x[0,2] z[0,1] : (0,0,0) (2,0,0) (2,0,1) (0,0,1)
A2  x[2,3] z[0,1] : (2,0,0) (3,0,0) (3,0,1) (2,0,1)   shares x=2,z[0,1] with A1
B   x[2,3] z[1,4] : (2,0,1) (3,0,1) (3,0,4) (2,0,4)   shares z=1,x[2,3] with A2
```

- Detour arm (positive): agent spawn (0.5,0,0.5), target (2.5,0,3.5).
  Euclidean = sqrt(2^2+3^2) = sqrt(13) = **3.605551**;
  path-sum (funnel, postproc=CORRIDORFUNNEL=0, agent default) =
  sqrt(2.5)+sqrt(6.5) = **4.130649** via (2,0,1).
  Assert `distance_to_target≈3.605551`, `get_next_path_position≈(2,0,1)`
  (the bend witness — this is what makes the arm discriminate rather than
  degenerate), `final≈(2.5,0,3.5)`, `reachable=true`.
- Straight control arm `--straight`: same 3-poly mesh, target (2.5,0,0.5).
  Segment stays z=0.5 through the A1→A2 portal; both hypotheses coincide at
  **2.0**, `next=(2.0,0,0.5)`. This arm controls for the multi-poly mesh
  itself (r69's convex 4x4 single-poly control would not).
- If the measured detour distance were ~4.130649 instead, the fixture reports
  path-sum — keep the claim parameter-free: print the raw value in the
  marker; the two candidates differ by 0.5251, far outside the 0.004 tol.

Suggested marker shape (matches run_battery.py CASES style, rows 47-50):

```
PASS navagent3d_detour distance=3.605551 final=2.500,0.000,3.500 next=2.000,0.000,1.000 reachable=true reachable_pathlen=4.130649
NEGATIVE REJECTED: navagent3d_detour straight distance=2.000000 next=2.000,0.000,0.500 reachable=true
```

(`pathlen` = sum of `get_current_navigation_path` segments — engine-measured,
not a literal constant; asserts the detour exists at query time.)

## Gotchas observed in the probe

1. `get_current_navigation_path()` returns `[]` if queried before the agent's
   first `get_next_path_position()` — the path materializes lazily. Call
   `get_next_path_position()` (then a frame) first, exactly as
   navagent3d_next.gd:30-31 already does.
2. Free every RID including the map: omitting `free_rid(map)` produced
   `ERROR: 1 RID allocations of type '8NavMap3D' were leaked at exit` on
   stderr, which the battery classifier (run_battery.py `LEAKED`/`ERROR`
   scans, ~280-307) would fail. `navagent3d_distance.gd` already appends the
   map to `owned` (line 22) — copy that.
3. Pass absolute `--runs` to run_battery.py — relative made the tree-timeout
   probe fail at r69 (r69-author.md caveat; verified at r69-verifier).
4. `NavigationMesh.add_polygon` index order must match the fixtures'
   reversed winding ([base, base+3, base+2, base+1] for quads); my probe used
   the same convention and all polys were walkable.

## Confidence and residual unknowns

- **Confidence high** for this engine build: measured, not doc-inferred.
  `distance_to_target` is Euclidean to authored `target_position` on Godot
  4.7.2 (including under an unreachable/clamped path).
- Residual: semantics under a *moving* agent mid-path (does the Euclidean
  reference track `global_position` per frame — presumably yes, unprobed),
  and under `path_postprocessing` ≠ CORRIDORFUNNEL (distance is
  postproc-independent in any case; only the path length would shift — the
  edge-centered variant would land ~4.707 via portal midpoints, still ≫
  3.606, so the discrimination is robust to that knob too).
- Probe artifacts retained at `corpus/live/r70-scout/runs/probe1/`
  (project.godot + probe_detour.gd); the stray write to `~/shokunin/...`
  during recon was moved into scope and the stray tree removed.
