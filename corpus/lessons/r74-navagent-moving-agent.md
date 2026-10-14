
# R74 — NavigationAgent3D moving-agent semantics (Godot 4.7.2)

## Decision and evidence

`NavigationAgent3D` on this build is fully LAZY: no per-tick agent update
exists. All observable state moves only inside "forcing" getters —
`get_next_path_position`, `get_final_position`, `is_navigation_finished`,
`is_target_reachable` — each of which synchronously runs the once-per-frame
update (requery-if-dirty, pop eval, flag eval) on the agent's LIVE node
transform. Pure readers never trigger: `get_current_navigation_path`,
`get_current_navigation_path_index` (return the last committed snapshot),
`is_target_reached` (stored flag — can read stale), `distance_to_target`
(pure call-time euclid to the RAW `target_position`, commits nothing).
Physics ticks with zero queries change nothing (pop included). Authoring
rule: any state capture must run a forcing call before reading
path/idx/reached, else it reads the previous commit; `set_target_position`
synchronously CLEARS the stored result (`path=[]`, `final`=raw target,
stale idx residue readable) and marks dirty — the re-query MATERIALIZES
inside the first forcing call afterward, anchored at the position live at
THAT call, not at assignment. A set+teleport in one no-read window anchors
post-teleport (author `mv_reanchor_lazy`, scribe `mz_lazy`); a forcing
read in between pins the anchor at read-time (`mv_reanchor_force`,
`mz_lazy_force`).

### Motion semantics table (all measured on `4.7.2.stable.arch_linux.ed1daf0bf`)

| surface | rule under scripted motion | discriminating receipts |
|---|---|---|
| stored path | stable under locomotion/velocity/ticks/non-query setters; NEVER re-queries while `segment_distance(agent, path[idx-1]→path[idx]) < path_max_distance` — the gate measures distance to the CURRENT LEG SEGMENT, not to the waypoint (boundary `e3`: mid-void at 1.0 from BOTH endpoints of the LS→LE leg stays frozen at pmd 0.8 — segment distance is what is <pmd); breach inclusive at exact equality (4.9 frozen / **5.000000 re-query** / 5.099 re-query, pmd=5.0); authored `path_max_distance` tracked (pmd=2 breaches at 4.53); breach re-queries lazily from live pos, `path[0]`=navmesh clamp, idx resets to 0; no undo on return | author `mv_walk`/`mv_void`/`mv_pmd_edge`/`mv_pmd2`/`mv_pmd_offmesh`, scribe `mz_walk`/`mz_steps`/`mz_freeze`/`mz_pmd`, boundary `e3_*/e4_ratchet` |
| pop index | monotone non-decreasing, SEQUENTIAL strict-`<` Euclidean vs the STORED path, evaluated on live pos inside the forcing call (0 frames needed); cannot skip a waypoint (`next` can point backward while flags fire); equality `==pdd` does not pop; advances through link endpoints as ordinary waypoints mid-void | author `mv_walk`/`mv_live`/`mv_popback`/`mv_popstrict`/`mv_popskip`/`mv_bridge_walk`, scribe `mz_steps`/`mz_eq`/`mz_backtrack`/`mz_regress`/`mz_skip`/`mz_calltime` |
| `reached`/`finished` | latch once fired — survive arbitrary motion incl. off-mesh and beyond-pmd; `finished` latching early-returns the update: pop loop AND the pmd re-query both freeze (latched agent 10.6 from `path[idx]` keeps the stale path; idx stays on a live waypoint under it). Measured unlatch: ANY `target_position` assignment — same value included, no dedup — which also clears the stored path and resets idx to 0 | author `mv_latch`/`mv_unlatch`, scribe `mz_latch`/`mz_steps` s7, simplifier `pmd_--tpx_10.6_--latch`, critic `pop_after_finish`/`lt_*` |
| re-anchor | `target_position` re-assignment (any value) re-queries from the agent's LIVE position: on-mesh → `path[0]`=live pos verbatim; off-mesh → navmesh clamp, nearest bank (scribe two-bank void pair: z=2→south, z=3→north; author island: `(2.5,0,3.9)`→link route or B-edge clamp unreachable→`finished=true` via the idx+pdd clause) | author `mv_reanchor`/`_same`/`_bank`/`_void`, scribe `mz_reanchor_*`/`mz_retarget_new`/`mz_lazy*` |
| signals | `path_changed` fires at materialization and each re-query only; `waypoint_reached` per idx pop inside the update, payload `{position, type, rid, owner}`; `target_reached`+`navigation_finished` co-fire in the latching update — all call-time artifacts, not tick broadcasts | scribe MZSIG logs (all arms) |

### Pop-under-motion vs the r72 stationary model

Identical gate — `while idx<size−1 and euclid(agent_live, path[idx]) <
pdd: idx++` — the only difference is WHEN it runs: never on ticks, always
inside a forcing getter on the live transform. The r72 strict-`<`,
sequential, non-skip, and finish-freeze clauses all hold under motion;
r74 adds the pmd invalidation gate, the lazy-materialization anchor rule,
and the finished-latch whole-update freeze.

### Invalidation triggers for the stored path

- `target_position` assignment — synchronous clear + lazy re-materialize
  (any value, no dedup). CASES-pinned.
- `segment_distance(agent, path[idx-1]→path[idx]) >= path_max_distance`
  at update time — the operand is the current leg SEGMENT, not the
  waypoint (boundary-measured); equality breaches (scribe-measured).
  CASES-pinned (`mv_pmd_*`).
- Map data changes (`region_set_transform`, region `navigation_layers`)
  and agent `navigation_layers` — lazy invalidation; EMPTY path +
  `final=(0,0,0)` on total severance (critic `fw_mapedit`/`fw_layermask`);
  clamped partial when a mainland stays on-mask. Measured; CASES-pinned
  in r75 (`mut_*`).
- `is_navigation_finished` latch — GATES OFF the whole update incl. the
  pmd re-query (author `mv_latch`, scribe `mz_steps` s7, simplifier
  10.6 receipt). CASES-pinned.
- Inert on the stored path: pdd/tdd/meta/enter_cost setters (critic
  `fw_pdd_mid`/`fw_meta_mid`; applied to the stale array next update),
  locomotion, velocity, idle ticks.

### Fixture

`navagent3d_detour.gd` gains the `steps` arm key (ordered steps; each may
`tp` the actor and/or `set_target` the agent — combined steps apply
set_target first — plus `wait` physics frames, default 5, `wait:0` reads
call-time) and optional `pmd` (`path_max_distance`); `_run_steps` +
`_run_motion_arm` pin the full per-step tuple INCLUDING the complete
stored path array — a path element that moved without an authored
re-query fails the step by name. 18 `mv_*` arms, all additive; battery
**145/145** (127 prior + 18 new), `seeds_unchanged=true`, 4/4 probes,
Node 31/31; prior rows byte-stable (scribe 14/14 spot + author full
replay 0-mismatch). The five deleted lines are mechanical (header line,
tp-branch fold, `expected_target` gate).

Receipts: `corpus/live/r74-author/runs/20261014T041431092173Z/` (145/145
full battery + probes + node `run_*.json`), `corpus/live/r74-baseline/
runs/20261014T022543376829Z/` (frozen 127/127), `corpus/live/r74-scribe/
runs/` (19 own-probe arms incl. determinism repeat + 18 wt mv-replays +
14 wt prior replays), `corpus/live/r74-scout/runs/` (8 probes, 91 lines),
`corpus/live/r74-critic/runs/` (44 arms), `corpus/live/r74-simplifier/
runs/` (in-flight probes); seat reports `reports/round-74/r74-*.md`;
pending r74-boundary/verifier + adjudication. Work commit: fc9915e.

Recheck conditions: any engine rebuild re-runs the battery (pmd gate,
lazy update and latch-early-return are engine internals); an upstream
change to the pmd comparator flips `mv_pmd_edge`/`mv_pmd2` honestly;
map-mutation / layers-flip invalidation and the dirty-window read are
candidates for future tracked arms; the equality datapoint (euclid==pmd)
should be re-pinned if the comparison internals ever ship as source.

## Not established

Engine internals of the pmd comparator and segment-vs-endpoint
measurement; map-mutation and agent-layers lazy invalidation as TRACKED
arms; `reachable` live-recompute under tdd change while latched;
is_target_reached staleness window pinned as a CASES row; avoidance/
velocity-driven locomotion, CharacterBody `move_and_slide`, multi-map/
multi-region, vertical motion, `simplify_path`/`path_height_offset`/
postprocessing-setter invalidation, runtime link endpoint mutation,
other engine builds.
