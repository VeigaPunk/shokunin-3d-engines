# R73 — NavigationAgent3D off-mesh NavigationLink3D traversal gating (Godot 4.7.2)

## Decision and evidence

A `NavigationLink3D` (or `NavigationServer3D.link_create`) joins the
agent's path query after the normal physics settle (`link_get_iteration_id
≥1`); its endpoints become ordinary path waypoints. The hop is invisible
in `get_current_navigation_path()` — the same point array appears at
`path_metadata_flags=0` with all three companion arrays **empty**
(opaque). With flags on `agent.get_current_navigation_result()`:
`path_types` marks `PATH_SEGMENT_TYPE_LINK`(=1) at the waypoint index
where the hop **starts** (segment `path[i]→path[i+1]`, far endpoint stays
REGION); `path_rids[i]` carries the link RID there (region RID
elsewhere); `path_owner_ids[i]` resolves to the authoring
`NavigationLink3D` only for node-authored links (server links → invalid
0s unless `link_set_owner_id` is used — unpinned). Bits 1/2/4 populate
independently; metadata changes NO path output (byte-identical tuples at
meta=0 vs meta=7). Agent default on this build: `meta=7` — an "opaque"
pin must set 0 explicitly.

Traversal gates, each independently falsifiable, each independently
verified to drop the link (byte-identical to the no-link control on
sole-route geometry; identical region-route fallback where a walk route
exists):

| gate | mechanism | observable where |
|---|---|---|
| `navigation_layers` | bitmask AND vs `agent.navigation_layers` (link=2 vs agent=1 drops; agent=3 restores — not equality) | shortcut geometry → corridor fallback (path/types/next, `reachable` stays true); island geometry → `reachable=false` + clamped `final` |
| `bidirectional=false` | direction-selective — traversable start→end, dropped when approached from the exit side (start/end swapped) | same dual surface |
| `enabled=false` | link ignored entirely — identical tuple to authoring no link | same dual surface |
| `travel_cost` | reprices the hop in route selection (tcost=10 → corridor on the fixture; crossover bracketed ∈(1.2,1.3] on scribe's strip geometry) | pathlen/types route flip |
| `enter_cost` | **structurally inert on this build** — {10,100,1e6,−1e6→clamped 0} all leave the link chosen; `link_get_enter_cost` stores `max(0,v)` | NOT observable in routing anywhere — dead state, pinned as TRUE |
| `path_desired_distance` | pop-through: endpoints are ordinary waypoints to the strict-`<` Euclidean pop loop; pdd ≥ euclid(agent→near endpoint) pops it and `next` returns the FAR endpoint across the void | `idx`/`next`; saturates at `size−1` |

The `enter_cost` anomaly — the r72 recon's "inert" note — hardened to a
pinned pair: `link_entercost` (100 → link still chosen) vs
`link_travelcost` (10 → corridor). A future build that applies
enter_cost flips `link_entercost` to the corridor tuple and fails the row
honestly — the falsification path is built into the arm.

Pop-through mechanics vs the r72 pop rule: identical gate —
`while idx<size−1 and euclid(agent, path[idx]) < pdd: idx++` — strict `<`
(exact equality does not pop: scribe `pdd=0.5` at `euclid=0.5` holds the
near endpoint; author's `link_pop_bank`/`link_pop_void` bracket
3.605551→idx2 / 4.0→idx3). No link awareness anywhere in the chain:
`next` jumps near endpoint → far endpoint in one index step, and the
r72 reachable-mode finish semantics are unchanged (`reachable=true,
finished=false` throughout).

Fixture: `navagent3d_detour.gd` gains 15 `--arm=` presets — opt-in
`island`/`link`/`link_a`/`link_b`/`linklayers`/`agentlayers`/`oneway`/
`rev`/`disabled`/`entercost`/`travelcost`/`meta` keys; `_run_link_arm`
pins the full observable tuple plus `types` exact-match, `rid_at`
(link-RID index, region elsewhere), `own_at`/`own_class` (live-instance
check), and a gate-honesty read-back block (`link_get_*` of every
authored flag — a no-op setter fails closed). Battery **127/127**
(112 prior + 15 new), `seeds_unchanged=true`, 4/4 probes, Node 31/31,
prior 112 rows 0-mismatch vs the r72 receipt. Authoring caveat measured
this round: `mesh.vertices.append_array` after property assignment does
not write through (COW detaches) — build the vertex array complete in a
local, then assign; a post-assignment append yields `Corrupted
navigation mesh … indices out of range`.

Receipts: `corpus/live/r73-author/runs/20261014T015541463862Z/`
(127/127 full battery + probes), `…/20261014T015454762559Z/` (42/42
focused), `corpus/live/r73-baseline/runs/20261014T013403245240Z/` (frozen
112/112), `corpus/live/r73-scribe/runs/` (32-arm independent two-geometry
probe + 15-arm verbatim replay + write-through mechanism pin),
`corpus/live/r73-scout/runs/` (API verify + 20-arm reproduction),
`corpus/live/r73-boundary/runs/` (49-arm edge survey),
`corpus/live/r73-simplifier/runs/` (15/15 link replay + 8 mutants);
seat reports `reports/round-73/r73-*.md`; pending `r73-verifier` +
adjudication. Work commit: `b41fb33`; adjudication-commit slot:
b41fb33.

Recheck conditions: any engine rebuild re-runs the battery (link gates
are server internals); an upstream change making `enter_cost` live flips
`link_entercost` honestly; changes to `link_connection_radius` default,
postprocessing defaults, or map config warrant re-measurement; the
unpinned boundary surfaces (chains, connection-radius projection,
mid-hop signals/latch, retarget re-anchor, backward traversal) are
candidates for a future round's arms.

## Not established

Route-cost internals (polygon-hop approximation — link route chosen over
a shorter corridor at default costs; `travel_cost` crossover bracketed
(1.2,1.3] on strip geometry, law unpinned); any configuration where
`enter_cost` weighs in; `link_set_owner_id` surfacing for server links;
`link_connection_radius` snap semantics and off-mesh endpoint projection
(measured by boundary, not pinned by CASES); chained/same-polygon link
behavior in the battery; `link_reached`/`waypoint_reached` signal
payloads and cadence; edgecentered postproc across link segments;
collision-body locomotion through links; `path_max_distance` repath;
vertical hops; multi-map links; runtime endpoint mutation; other engine
builds, baked regions, avoidance, rendering.
