# R72 — NavigationAgent3D pdd waypoint-pop + two-mode is_navigation_finished (Godot 4.7.2)

## Decision and evidence

`path_desired_distance` (pdd) drives a **sequential Euclidean pop loop
keyed on the live agent position**: each navigation update advances the
path index while `idx < size−1` and `euclid(agent, path[idx]) < pdd` —
strict `<` (an exact equality does NOT pop), saturating at the last
index so `get_next_path_position` converges to `path[size−1]`. The
basis is Euclidean to the agent, discriminated against path-sum on the
gap2 dogleg (path[2]=(2,0,1) at euclid 1.581139 but 2.581139 routed;
pdd=2.0 pops it, idx→3). Position-keying is live: a post-settle
teleport re-pops on the **fixed stored path** (idx 1→2 at 0.2-away;
idx 1→3 under pdd 3.5), and the chain cannot skip — teleporting next
to the final leaves `next` pointing at a still-unevaluated mid
waypoint. Pops are monotone and multi-per-update (pdd 1.59 jumps idx
1→3 through two equidistant √2.5 waypoints).

`is_navigation_finished` resolves into an OR of two strict clauses:

| gate | formula | strictness | evidence |
|---|---|---|---|
| `is_target_reached` | `euclid(agent, raw target) < tdd` | **strict**; ignores reachability (fires through walls / on off-mesh targets); latched | tdd=3.605551 at exactly √13 → false; 3.6056 → true; teleport 0.5 from off-mesh T → reached+finished while reachable=false |
| `is_target_reachable` | `euclid(clamped final, raw target) <= tdd` | **inclusive** at equality; agent-independent | euclid(final→T)=1.5 == tdd=1.5 → reachable=true; 1.4 → false |
| `is_navigation_finished` | `reached OR (NOT reachable AND idx==size−1 AND euclid(agent, clamped final) < pdd)` | both sub-gates **strict**; latched | pdd=2.915476 at exactly euclid→final → false; 3.0 → true; agent ON the final with idx=1 → false (index must arrive) |

Corollaries pinned by arms: reachable mode is **pdd-immune** (pdd=5.0
saturates the index yet finished=false at tdd=1.0 on a reachable
target); unreachable mode requires the pop chain to *arrive* at the
last index (proximity alone insufficient); `finished` is **non-monotone
in tdd** — on a degenerate spawn-on-clamp path, tdd 1.4 → true
(idx+pdd clause), 1.5 → false (reachable flips inclusive on, strict
reached fails at equality), 1.6 → true. Engine-side truth, consistent
with master `navigation_agent_3d.cpp`: the tdd clause is evaluated
first and unconditionally, the pdd clause only when unreachable, and
`navigation_finished` latches until a repath.

Fixture: `navagent3d_detour.gd` gains `--arm=<name>` presets (22 CASES
rows, all exit 0, expectations authored inside `_arm_cfg` — a row
cannot tune itself; any tuple mismatch exits 1 with a named
diagnostic). Arms cover pop sweeps (`pop_lo/hi/sat`), position-keying
(`mid_lo/hi`, `tp_mid/tp_eq`), basis discrimination (`gap2_pop_basis`),
strict pop equality at exact 1.0 (`vert_pop_eq/above`), unreachable
finish edges (`fin_unr_lo/hi`, `vert_fin_eq/above` at exact 3.0),
reachable-finish equality (`fin_reach_eq/above` at exact 2.5), the
selector sawtooth (`edge_unr/eq/above`), index-gate (`fin_idx_gate`),
through-wall (`fin_wall`), and latch (`fin_latch`). Battery 112/112 +
4 probes, `seeds_unchanged=true`, prior 90 rows byte-identical; scribe
independently replayed all 22 markers byte-exact.

Receipts: `corpus/live/r72-author/runs/20261014T004642048951Z/` (112/112)
+ `…/20261014T004610248553Z/` (27/27 focused),
`corpus/live/r72-baseline/runs/20261014T003555854844Z/` (frozen 90/90),
`corpus/live/r72-scribe/runs/` (29-arm independent probe + 22-arm
verbatim replay), `corpus/live/r72-scout/runs/` (43-arm edge matrix);
seat reports `reports/round-72/r72-*.md`; pending `r72-verifier` +
adjudication.

## Not established

`path_metadata_flags` behavioral role (LINK segments, restricted
bitmasks, signal payloads); moving-agent dynamics — real locomotion
re-pop cadence, signal emission, `path_max_distance` repath triggers,
`path_height_offset`, avoidance, mid-path map updates; latch release
conditions; `reachable` flip-back caching; final-vs-`path[size−1]`
referent separation; ULP-adjacent float edges; other engine builds,
baked regions, multi-region maps, rendering.
