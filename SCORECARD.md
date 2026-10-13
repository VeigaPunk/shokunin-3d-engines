# game-dev-3d scorecard — mint

Owned axes: depth, coverage, calibration. Scores remain unassigned without a
quality rubric; a row count is a measurement, not a score or verdict.

| axis | score | evidence / counting command | last change |
|---|---|---|---|
| depth | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → 61/61 + four probes; x1.25 same-path ray misses, radius0.5 ShapeCast3D hits box edge(1,0,1) safe≈.425781, radius0.1 misses; private positive radius.5→.1 exits1 on measured missing collision; non-author `corpus/lessons/r42-graze-review.md`; measured at `3818943545d941630b28a0d380d3c9f092e585dc` | r42 |
| coverage | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → 63/63 + four probes; live Path3D/Curve3D three-point handled bent path baked length≈6.072724 and quarter Y≈1.118591 vs intact straight length≈4.472136/quarter Y0; private bent middle y2→3 exits1 on measured length7.580958/quarter Y1.61809/mid Y3; non-author `corpus/lessons/r43-curve-review.md`; measured at `fddb3a10d97084b25619a81c886b771646fd61eb`. No navigation agent/rendered line. | r43 |
| calibration | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → 37/37 + four probes; private slope30→40 plus rotation expectation40 exits1 on X=-0.1347 mismatch; additionally adjusted X/Y/count exits1 on first normal(-.643,.766) mismatch; prior37 raw records unchanged; non-author `corpus/lessons/r29-sensitivity-review.md`; measured at `1f4ab3fd049c35a210ab57e11e69faa7733c00be` | r29 |

planned: depth — rendering/GPU behavior, navigation mesh baking,
multiplayer/replication, orthographic boundary precision, general slope sliding and friction, untouched initial grounded flag/general jump controller, other resource types and physics solver edge regimes remain unprobed.
Coverage — executable engines beyond Godot and Node three.js (Unity/Unreal not installed; only fixed-scope static samples, census in corpus/knowledge/engines.md), production-project
launch, broad PackedScene serialization/compatibility, GUI/viewport embedding, export templates for 3D, and platforms
beyond this Linux headless host remain unprobed. Calibration —
no same-step slope contact telemetry or floor-angle boundary sweep; direct-child signal, one identified detached witness timeout and stream-attribution probes exist with narrow limits, not generic crash/process-tree policy.
retired: none.
