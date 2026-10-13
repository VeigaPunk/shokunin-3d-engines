# game-dev-3d scorecard — mint

Owned axes: depth, coverage, calibration. Scores remain unassigned without a
quality rubric; a row count is a measurement, not a score or verdict.

| axis | score | evidence / counting command | last change |
|---|---|---|---|
| depth | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → 77/77 + four probes; live scripted actor retargets NavigationAgent3D mid-flight at callback35 from(3,0,3) to(1,0,3), pre-switch actor≈(1.730676,0,1.730676), path/next switches and final reaches(1,0,3) versus fixed-target final(3,0,3); private retarget X1→2 exits1 on measured path/next end(2,0,3); non-author `corpus/lessons/r51-retarget-review.md`; measured at `5f5e9536d02a5161d7e84f4c69ccbe30c065e184`. Scripted, not autonomous movement. | r51 |
| coverage | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → 73/73 + four probes; live NavigationAgent3D on authored map next-path initialization yields path(1,0,1)→(3,0,3) vs alternate end(3,0,1), actor stationary; private normal target Z3→2 exits1 on measured agent path/next; non-author `corpus/lessons/r49-navagent-review.md`; measured at `ca4b3184d01f961b41aa6a084b49190a3f895190`. No autonomous motion/baking. | r49 |
| calibration | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → 77/77 + four probes; private NavigationAgent3D driver target X1→2 with aligned route expectation X2 passes route checks and exits1 at measured final actor X2 versus intact expected X1; named non-author `corpus/lessons/r52-final-review.md`; work measured at `4cd38990052d6585d3b4c6886ff898fe79e12c7d`, closure rerun same command PASS. Scope: one scripted route/final-actor check, not each compound predicate isolated. | r52 |

planned: depth — rendering/GPU behavior, navigation mesh baking,
multiplayer/replication, orthographic boundary precision, general slope sliding and friction, untouched initial grounded flag/general jump controller, other resource types and physics solver edge regimes remain unprobed.
Coverage — executable engines beyond Godot and Node three.js (Unity/Unreal not installed; only fixed-scope static samples, census in corpus/knowledge/engines.md), production-project
launch, broad PackedScene serialization/compatibility, GUI/viewport embedding, export templates for 3D, and platforms
beyond this Linux headless host remain unprobed. Calibration —
no same-step slope contact telemetry or floor-angle boundary sweep; direct-child signal, one identified detached witness timeout and stream-attribution probes exist with narrow limits, not generic crash/process-tree policy.
retired: none.
