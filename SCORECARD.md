# game-dev-3d scorecard — mint

Owned axes: depth, coverage, calibration. Scores remain unassigned without a
quality rubric; a row count is a measurement, not a score or verdict.

| axis | score | evidence / counting command | last change |
|---|---|---|---|
| depth | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → 57/57 + four probes; live BoneAttachment3D marker local(1,0,0) follows rotated Tip pose to global(-3,1,0) versus unrotated(1,3,0); private PI/2→PI/3 and adjusted attachment expectations exits1 on measured marker(-2.098,2.366,0); non-author `corpus/lessons/r40-attachment-review.md`; measured at `d597aba34926e503fbf578b34d19ec63be544b62` | r40 |
| coverage | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → 59/59 + four probes; live sphere ShapeCast3D radius0.5 from z4 toward -6Z hits box front z1, +Z, safe≈.414062/unsafe≈.417969 versus lateral x4 miss; private box z-size2→4 with adjusted setup exits1 on contact z2/fractions≈.244141/.25; non-author `corpus/lessons/r41-shapecast-review.md`; measured at `3412f7a5ee0bdd30ba07087ae1c009a2843603cd`. No continuous body movement/pixels. | r41 |
| calibration | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → 37/37 + four probes; private slope30→40 plus rotation expectation40 exits1 on X=-0.1347 mismatch; additionally adjusted X/Y/count exits1 on first normal(-.643,.766) mismatch; prior37 raw records unchanged; non-author `corpus/lessons/r29-sensitivity-review.md`; measured at `1f4ab3fd049c35a210ab57e11e69faa7733c00be` | r29 |

planned: depth — rendering/GPU behavior, navigation mesh baking,
multiplayer/replication, orthographic boundary precision, general slope sliding and friction, untouched initial grounded flag/general jump controller, other resource types and physics solver edge regimes remain unprobed.
Coverage — executable engines beyond Godot and Node three.js (Unity/Unreal not installed; only fixed-scope static samples, census in corpus/knowledge/engines.md), production-project
launch, broad PackedScene serialization/compatibility, GUI/viewport embedding, export templates for 3D, and platforms
beyond this Linux headless host remain unprobed. Calibration —
no same-step slope contact telemetry or floor-angle boundary sweep; direct-child signal, one identified detached witness timeout and stream-attribution probes exist with narrow limits, not generic crash/process-tree policy.
retired: none.
