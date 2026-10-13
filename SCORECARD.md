# game-dev-3d scorecard — mint

Owned axes: depth, coverage, calibration. Scores remain unassigned without a
quality rubric; a row count is a measurement, not a score or verdict.

| axis | score | evidence / counting command | last change |
|---|---|---|---|
| depth | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → 47/47 + four probes; indexed four-vertex/two-triangle ArrayMesh forward readback/cross Z+6 vs reversed Z-6 with same bounds; private index mutation exits1 on readback, adjusted expectation exits1 on second cross Z-6; non-author `corpus/lessons/r34-index-review.md`; measured at `24dce474b725b572a381425de2fa92ec80f62cb5` | r34 |
| coverage | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → 49/49 + four probes; generated concave shape from ArrayMesh with explicit `backface_collision=true` and ray `hit_back_faces=true` yields interior hit(0.5,0.5,0)/+Z/face0 versus offset miss; private vertex contraction exits1 on missing hit, default-shape scratch also misses; non-author `corpus/lessons/r35-trimesh-review.md`; measured at `a2a0a282d97c92ed0e7ad73f80c467b347a75c40`. No default policy/rendering proof. | r35 |
| calibration | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → 37/37 + four probes; private slope30→40 plus rotation expectation40 exits1 on X=-0.1347 mismatch; additionally adjusted X/Y/count exits1 on first normal(-.643,.766) mismatch; prior37 raw records unchanged; non-author `corpus/lessons/r29-sensitivity-review.md`; measured at `1f4ab3fd049c35a210ab57e11e69faa7733c00be` | r29 |

planned: depth — rendering/GPU behavior, navigation mesh baking,
multiplayer/replication, orthographic boundary precision, general slope sliding and friction, untouched initial grounded flag/general jump controller, other resource types and physics solver edge regimes remain unprobed.
Coverage — executable engines beyond Godot and Node three.js (Unity/Unreal not installed; only fixed-scope static samples, census in corpus/knowledge/engines.md), production-project
launch, broad PackedScene serialization/compatibility, GUI/viewport embedding, export templates for 3D, and platforms
beyond this Linux headless host remain unprobed. Calibration —
no same-step slope contact telemetry or floor-angle boundary sweep; direct-child signal, one identified detached witness timeout and stream-attribution probes exist with narrow limits, not generic crash/process-tree policy.
retired: none.
