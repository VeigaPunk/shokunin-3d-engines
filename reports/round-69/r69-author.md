# Game-dev-3d round 69 — NavigationAgent3D distance / reach-threshold queries (author, host: devin)

## Work performed

- Before-state `25ed373` (r68 report commit): 83 Godot headless cases plus
  four opt-in probes; `navagent3d_next`/`navagent3d_follow`/
  `navagent3d_retarget` cover path lookup, guided motion and in-flight
  retarget, but `distance_to_target()`, `get_final_position()`,
  `is_target_reachable()` and the `target_desired_distance` gate behind
  `is_target_reached()`/`is_navigation_finished()` were never asserted.
  Derived move: one bounded depth move on the next untested
  NavigationAgent3D surface, same authored 4x4 single-polygon map.
- New fixture `corpus/fixtures/navagent3d_distance.gd` (sha256
  `b820e469c35e68cf60d3f87bda94c1968cbc9b943b78513a6bf61bd0761c803a`) and
  two CASES rows in `run_battery.py` (sha256
  `b992c7a5f135b2e4fd83104eae41deaaf93f4e7c74ea5af2361b3a8a650b46ea`,
  +4 lines only). A stationary agent at (1,0,1) targets (3,0,3); after a
  30-physics-frame settle the script asserts measured
  `distance_to_target=2.828427` (hand-derived 2*sqrt(2)),
  `get_final_position`/`get_next_path_position` = (3,0,3),
  `is_target_reachable=true`, `is_target_reached=false`,
  `is_navigation_finished=false` at default `target_desired_distance=1.0`.
  The `--wide-reach` arm changes only `target_desired_distance` to 3.0
  (>2.828427): identical geometry, identical measured distance, but
  reached/finished flip true with zero movement — exit 2 negative.
- Author verification (no commits made; lane writes uncommitted per
  dispatch): full battery + four probes run three times under
  `corpus/live/runs/round-69/` plus focused subset and all six Node suites.

## Before → after measurements

- Focused: `--only navagent3d_distance,navagent3d_distance_wide_reach`
  → 2/2, `20261013T164958602488Z/verdicts.json`.
- Full battery `20261013T165524265085Z`: **PASS, 85/85** (42 ordinary /
  43 negative controls), `seeds_unchanged=true`, godot
  `4.7.2.stable.arch_linux.ed1daf0bf`; all four probes PASS
  (`crash-exit`, `stream-attribution`, `tree-timeout`,
  `mutation detected=true`). New markers byte-exact:
  `PASS navagent3d_distance distance=2.828427 final=3.000,0.000,3.000 next=3.000,0.000,3.000 reached=false reachable=true finished=false`
  and `NEGATIVE REJECTED: navagent3d_distance wide_reach distance=2.828427 reached=true finished=true reachable=true`.
- Prior-case stability: all 83 pre-r69 raw case fields (exit, marker,
  verdict, reasons, stdout, stderr, script, flags) byte-identical to the
  last 83-case receipt `corpus/live/runs/20261013T133935795023Z`.
  Seed map 50→51: only new key `navagent3d_distance.gd` and the intended
  `run_battery.py` digest change.
- Node three.js suites on this host (Node v24.21.0, three.js 0.186.1):
  3/3, 5/5, 5/5, 5/5, 9/9, 4/4 all PASS with `seeds_unchanged=true`;
  receipts at `round-69/run_*.json`.

## Caveats / UNKNOWNs

- `distance_to_target` on a straight single-polygon corridor cannot
  distinguish Euclidean vs path-sum semantics; the claim is the measured
  2.828427 at this geometry only — semantic discrimination UNKNOWN.
- First full run `20261013T165007161683Z`: cases 85/85 but
  `tree-timeout` probe FAIL — **author invocation artifact**: a relative
  `--runs` path made `scratch` relative, so the witness-identity cmdline
  check compared `.shokunin/...` against the witness's absolute cmdline
  (`witness_verified=false`, witness never signaled, pipe EOF timed out).
  Diagnosed, not patched; receipt retained. Probe passed on both
  absolute-path reruns. Rule for reviewers: always pass absolute `--runs`.
- Second full run `20261013T165315209679Z`: 84/85 — pre-existing
  `navagent3d_retarget` flaked (`before=1.754246` vs expected 1.730676,
  drift 0.0236 > 0.004 tol) under load average ~14 with a concurrent
  REA/Ghidra analysis on this host; same case flagged intermittent at
  r68. Not caused by the new fixture (both new cases passed in that run
  too); kept as a documented host-contention UNKNOWN, clean no-change
  retry passed 85/85.
- No claim about agent motion, avoidance, baking, multi-polygon or
  off-mesh targets, other engines, or rendered output.

## Per-axis verdicts (author claim — non-author review required before admission)

- **Depth: improved (claim)** — first measured `distance_to_target`,
  `get_final_position`, `is_target_reachable`, and the
  `target_desired_distance` reach gate of NavigationAgent3D with a live
  discriminating negative (threshold flip without movement).
- **Coverage: unchanged** — same Godot engine, host and API class.
- **Calibration: unchanged** — existing exit/marker/seed contract; two
  documented receipt caveats above, neither evidence-bearing.
- Admission would rest on one improved axis and none harmed in finite
  replay, pending named independent verification; not marked.

## Assumptions and constants

- Host devin; `/usr/bin/godot` ELF 4.7.2.stable.arch_linux.ed1daf0bf,
  Node v24.21.0, three.js 0.186.1, physics 60 tps. Map cell_size 0.25,
  4x4 single polygon, agent spawn (1,0,1), target (3,0,3),
  `target_desired_distance` 1.0 default / 3.0 wide arm, 30-frame settle,
  distance tolerance 0.004, endpoint tolerance 0.001.

## SHONEN

- [ ] Real decision tables/error patterns/checklists with cited sources — not attested this round.
- [x] End-to-end domain task executed and logged — named non-author `game-dev-3d-r2-review-retry` checked at `.shokunin/game-dev-3d/corpus/lessons/r2-independent-review.md`.
- [ ] Instructions executable without oral context — not attested as a probation box.
- [ ] No cross-domain bleed; PROVINCE accurate — not attested as a probation box.
