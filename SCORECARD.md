# game-dev-3d scorecard — mint

Owned axes: depth, coverage, calibration. Scores remain unassigned without a
quality rubric; a row count is a measurement, not a score or verdict.

| axis | score | evidence / counting command | last change |
|---|---|---|---|
| depth | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → 43/43 + four probes; live `AnimationPlayer` X0→X4 switch with 0.5s transition reaches intermediate X≈1.931 then X4 versus zero transition X4/X4; private endpoint4→6 exits1 on observed X2.897/6; non-author `corpus/lessons/r32-blend-review.md`; measured at `00aab731c6f7cce916dc4a07e4e7b85671343f94` | r32 |
| coverage | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → 45/45 + four probes; Godot live procedural `ArrayMesh` XY triangle surface/readback and `MeshInstance3D` AABB planar Z0.00001 vs shifted vertex Z1 extent1; private planar vertex Z0→2 exits1 on readback; prior43 raw cases unchanged; non-author `corpus/lessons/r33-arraymesh-review.md`; measured at `a6f63ccf5769160396dfd107ebd94c28dc0576af`. No GPU/pixel proof. | r33 |
| calibration | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → 37/37 + four probes; private slope30→40 plus rotation expectation40 exits1 on X=-0.1347 mismatch; additionally adjusted X/Y/count exits1 on first normal(-.643,.766) mismatch; prior37 raw records unchanged; non-author `corpus/lessons/r29-sensitivity-review.md`; measured at `1f4ab3fd049c35a210ab57e11e69faa7733c00be` | r29 |

planned: depth — rendering/GPU behavior, navigation mesh baking,
multiplayer/replication, orthographic boundary precision, general slope sliding and friction, untouched initial grounded flag/general jump controller, other resource types and physics solver edge regimes remain unprobed.
Coverage — executable engines beyond Godot and Node three.js (Unity/Unreal not installed; only fixed-scope static samples, census in corpus/knowledge/engines.md), production-project
launch, broad PackedScene serialization/compatibility, GUI/viewport embedding, export templates for 3D, and platforms
beyond this Linux headless host remain unprobed. Calibration —
no same-step slope contact telemetry or floor-angle boundary sweep; direct-child signal, one identified detached witness timeout and stream-attribution probes exist with narrow limits, not generic crash/process-tree policy.
retired: none.
