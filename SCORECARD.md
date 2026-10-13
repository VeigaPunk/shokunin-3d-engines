# game-dev-3d scorecard — mint

Owned axes: depth, coverage, calibration. Scores remain unassigned without a
quality rubric; a row count is a measurement, not a score or verdict.

| axis | score | evidence / counting command | last change |
|---|---|---|---|
| depth | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → 35/35 + four probes; 60 explicit frame-paced CharacterBody3D gravity move calls apex tick29≈2.45, landing tick60≈1.001 versus intact relocated floor no landing/free final0.9; private IMPULSE6→7 exits1; non-author `corpus/lessons/r26-jump-review.md`; measured at `1a854b4d1318434cc0a0945ba165fc584b4a3d43` | r26 |
| coverage | unscored | `python3 .shokunin/game-dev-3d/corpus/artifacts/unreal-r22/verify_descriptor.py` accepts one authored Unreal-style .uplugin; bad-Type `--expect-reject` plus private missing Name, duplicate Type key, extra module reject; non-author `corpus/lessons/r22-unreal-review.md`; Godot default 29/29, Node 3/3 preserved; measured at `40d0df3fae58f758478872ef2b253c4c2dfec03a`. **No Unreal load/runtime.** | r22 |
| calibration | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → 35/35 + four probes; tiny downward probe measures pre-impulse `is_on_floor=true` only with touching floor and false with floor y-20; private floor y0→-1 mutant exits1 before apex; non-author `corpus/lessons/r27-ground-review.md`; measured at `90379ed706d805020d35282c0daba1706b515c40` | r27 |

planned: depth — rendering/GPU behavior, navigation mesh baking,
multiplayer/replication, orthographic boundary precision, sustained slope sliding, friction, untouched initial grounded flag/general jump controller, other resource types and physics solver edge regimes remain unprobed.
Coverage — executable engines beyond Godot and Node three.js (Unity/Unreal not installed; only fixed-scope static samples, census in corpus/knowledge/engines.md), production-project
launch, broad PackedScene serialization/compatibility, GUI/viewport embedding, export templates for 3D, and platforms
beyond this Linux headless host remain unprobed. Calibration —
no same-step slope contact telemetry or floor-angle boundary sweep; direct-child signal, one identified detached witness timeout and stream-attribution probes exist with narrow limits, not generic crash/process-tree policy.
retired: none.
