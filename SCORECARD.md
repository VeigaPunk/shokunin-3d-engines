# game-dev-3d scorecard — mint

Owned axes: depth, coverage, calibration. Scores remain unassigned without a
quality rubric; a row count is a measurement, not a score or verdict.

| axis | score | evidence / counting command | last change |
|---|---|---|---|
| depth | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → 69/69 + four probes; live Node3D `_physics_process(delta)` drives PathFollow3D over 60 callbacks sum≈1s, progress≈3 and follower Y≈1.105767/1.997535 versus speed0 stationary; private driver SPEED3→4 exits1 on measured progress≈4/positions; non-author `corpus/lessons/r46-callback-review.md`; measured at `fdbfe305d4adc3c6bec21ef1e83c6c865b5a1f3f` | r46 |
| coverage | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → 73/73 + four probes; live NavigationAgent3D on authored map next-path initialization yields path(1,0,1)→(3,0,3) vs alternate end(3,0,1), actor stationary; private normal target Z3→2 exits1 on measured agent path/next; non-author `corpus/lessons/r49-navagent-review.md`; measured at `ca4b3184d01f961b41aa6a084b49190a3f895190`. No autonomous motion/baking. | r49 |
| calibration | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → 71/71 + four probes; private remote source angle90→60 with adjusted source guard exits1 on measured Target basis X(.5,.866,0), and `update_rotation=false` with guard bypass exits1 on identity Target basis while origin still(2,1,-3); prior71 raw records unchanged; non-author `corpus/lessons/r48-rotation-review.md`; measured at `b41879b01d8801c89bbee504182356501853c00a` | r48 |

planned: depth — rendering/GPU behavior, navigation mesh baking,
multiplayer/replication, orthographic boundary precision, general slope sliding and friction, untouched initial grounded flag/general jump controller, other resource types and physics solver edge regimes remain unprobed.
Coverage — executable engines beyond Godot and Node three.js (Unity/Unreal not installed; only fixed-scope static samples, census in corpus/knowledge/engines.md), production-project
launch, broad PackedScene serialization/compatibility, GUI/viewport embedding, export templates for 3D, and platforms
beyond this Linux headless host remain unprobed. Calibration —
no same-step slope contact telemetry or floor-angle boundary sweep; direct-child signal, one identified detached witness timeout and stream-attribution probes exist with narrow limits, not generic crash/process-tree policy.
retired: none.
