# game-dev-3d scorecard — mint

Owned axes: depth, coverage, calibration. Scores remain unassigned without a
quality rubric; a row count is a measurement, not a score or verdict.

| axis | score | evidence / counting command | last change |
|---|---|---|---|
| depth | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only camera3d_depth,camera3d_depth_far,camera3d_depth_near` → 3/3, full 15/15 + four prior probes, near +0.5 forward depth rejected despite same pixel, private local-Z mutant exit1; non-author `corpus/lessons/r8-near-review.md` (r8 work commit in report) | r8 |
| coverage | unscored | `npx -y rea-agents@6.4.0 inspect-artifact .shokunin/game-dev-3d/corpus/artifacts/zip-r10/triangle-carrier.zip --format json --full-output` → ZIP member Evidence `ev_289ef677b404333d1dde092987d65529261883c47fd81f40050402c7e4df0358`, GLB member hash `78f51afa...65fbc`; invalid ZIP also inventoried but rejected by local truth control; named non-author `corpus/lessons/r10-zip-review.md` (work commit cited in report) | r10 |
| calibration | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → default 12/12, clean exit0 accepted, timeout logical null / cleanup -9 rejected, one verified detached witness gone; non-author `corpus/lessons/r5-timeout-review.md` and `r5-cleanup-review.md` (r5 work commit cited in report) | r5 |

planned: depth — rendering/GPU behavior, navigation mesh baking,
multiplayer/replication, and physics solver edge regimes remain unprobed.
Coverage — engines beyond Godot (Unity, Unreal, three.js, discovered
tooling; census in corpus/knowledge/engines.md), production-project
launch, GUI/viewport embedding, export templates for 3D, and platforms
beyond this Linux headless host remain unprobed. Calibration —
crash-exit classification, process-tree timeout, and stdout/stderr
attribution probes port from the game-dev-2d lessons remain unported.
retired: none.
