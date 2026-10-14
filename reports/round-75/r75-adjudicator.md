# R75 adjudicator (Sol) — map/link mutation under a committed path

Round: 75. Wave: `shokunin-train-20261014-w6`. Work commit: `6498973`
("r75: map/link mutation under committed path — two-stage gate, zombie
resolved"); wording hygiene follow-up `cefc821`.

## Declared move (depth)

Measure NavigationServer3D map/link/region mutations under a committed
navigation path — synchronization gates, lazy invalidation, zombie
waypoints, and interaction with the finished latch (XConnector-recommended
arm).

## Seat convergence

| seat | landing | contribution |
|---|---|---|
| author | yes | 11 `mut_*` arms (+464/−11), 156/156 + 4/4 probes + Node 31/31; latched-zombie falsification pinned (served dead-gate through region transform AND delete) |
| scout | yes | mutation surface confirmed greenfield (all `link_set_*`/`region_set_*` authoring-only prior) |
| critic | yes | 5 falsifications absorbed: ≥1-frame same-turn zombie window (pre-sync serving is real), global per-agent dirty (not per-edge), header "never SERVED" overclaim corrected to post-sync scope |
| boundary | yes | sync-blind readback gate (`wait>=1` required on mutation arms); map-wide dirty scope + same-value suppression + 2–3-frame sync timing measured in scratch, partially tracked |
| simplifier | yes | 11/11 arms load-bearing; `_check_tuple` extraction demonstrated byte-identical in scratch (warranted future cleanup); corrected the no-LSP record (`--lsp-port` works) |
| reviewer | yes | r74 re-execution 145/145 + r75 156/156 + Node 31/31; same-turn zombie serving reproduced pre-sync; flagged stale author-report sentence + `--runs` docstring gap — **both fixed in `cefc821`** |
| scribe | yes | lesson structure + cross-round model continuity confirmed |
| baseline | yes | frozen 145/145 + Node 31/31, 0 drift; mutation surface greenfield confirmed |
| verifier | yes | **AGREE 5/5** — 156/156 + 4 probes + Node 31/31 on `cefc821`; 0 mismatches 156×12 vs author + 145 shared r74 rows; byte-exact committed-blob replays; CASES additivity verified mechanically |

## Adjudicator own reproduction (committed tree)

`--only=navagent3d_detour_mut_{latch_zombie,link_kill,region_move}` —
3/3 PASS on committed `cefc821` state:
- `mut_latch_zombie`: finished agent serves `next=(2,0,3)`,
  `reachable=true`, `finished=true` after region moved +5x — the zombie.
- `mut_link_kill`: link disabled → post-sync forcing call re-queries,
  `reachable=false`, `finished=true` at pre-link hop.
- `mut_region_move`: region transform → re-anchor to moved surface.

## Corrections absorbed this round

- "no dead-hop point is ever SERVED" → scoped to **after server sync**;
  same-turn serving in the setter→sync window is real (critic + reviewer
  independent). Fixture header, author report, and r74 lesson's pmd
  operand wording (leg-segment, not waypoint) all corrected in `cefc821`.
- `--runs` relative-path trap (flagged across 3 rounds) now documented in
  `run_battery.py` docstring.

## Per-axis verdict — **ADMIT**

- **depth: improved locally** — the two-stage gate (setter→sync,
  sync→forcing-call) is measured; the latched zombie is pinned as the one
  genuinely-served zombie; agent-side synchronous exception identified.
- **coverage: improved locally** — 11 `mut_*` arms over link/region/agent
  mutation classes; 145→156.
- **calibration: unchanged** — additive arms; no threshold edits.

Bounds: Godot 4.7.2.stable.arch_linux.ed1daf0bf headless, this host;
single map/region geometry family; sync timing measured ~2–3 frames (not
pinned as CASES); multi-agent and node-link surfaces unexercised.

Work commit `6498973` (+ `cefc821` wording); report-last commit lands the verifier + lesson + LOG/SCORECARD.
