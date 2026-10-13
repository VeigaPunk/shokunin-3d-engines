# game-dev-3d scorecard — mint

Owned axes: depth, coverage, calibration. Scores remain unassigned without a
quality rubric; a row count is a measurement, not a score or verdict.

| axis | score | evidence / counting command | last change |
|---|---|---|---|
| depth | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → 41/41 + four probes; physics-callback `AnimationPlayer.play` once without seek advances live Node3D X≈0.967/1.967 after 30/60 awaited frames at player time29/60,59/60 versus intact constant X0; private endpoint4→6 exits1 on X1.45/2.95; non-author `corpus/lessons/r31-playback-review.md`; measured at `21fdd336f08b994210623fca9a61046063d71f6a` | r31 |
| coverage | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → 39/39 + four probes; Godot `AnimationPlayer` live `Node3D` position X0→4 sampled by explicit seeks at half/end X2/4 versus intact constant X0/0; private endpoint4→6 exits1 on observed X3/6; prior37 raw records unchanged; non-author `corpus/lessons/r30-animation-review.md`; measured at `4c45524fbf366b18be0f5f8539532576c68fe4a3`. No timed playback/rendering. | r30 |
| calibration | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → 37/37 + four probes; private slope30→40 plus rotation expectation40 exits1 on X=-0.1347 mismatch; additionally adjusted X/Y/count exits1 on first normal(-.643,.766) mismatch; prior37 raw records unchanged; non-author `corpus/lessons/r29-sensitivity-review.md`; measured at `1f4ab3fd049c35a210ab57e11e69faa7733c00be` | r29 |

planned: depth — rendering/GPU behavior, navigation mesh baking,
multiplayer/replication, orthographic boundary precision, general slope sliding and friction, untouched initial grounded flag/general jump controller, other resource types and physics solver edge regimes remain unprobed.
Coverage — executable engines beyond Godot and Node three.js (Unity/Unreal not installed; only fixed-scope static samples, census in corpus/knowledge/engines.md), production-project
launch, broad PackedScene serialization/compatibility, GUI/viewport embedding, export templates for 3D, and platforms
beyond this Linux headless host remain unprobed. Calibration —
no same-step slope contact telemetry or floor-angle boundary sweep; direct-child signal, one identified detached witness timeout and stream-attribution probes exist with narrow limits, not generic crash/process-tree policy.
retired: none.
