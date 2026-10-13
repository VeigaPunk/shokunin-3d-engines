# game-dev-3d scorecard — mint

Owned axes: depth, coverage, calibration. Scores remain unassigned without a
quality rubric; a row count is a measurement, not a score or verdict.

| axis | score | evidence / counting command | last change |
|---|---|---|---|
| depth | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → 35/35 + four probes; 60 explicit frame-paced CharacterBody3D gravity move calls apex tick29≈2.45, landing tick60≈1.001 versus intact relocated floor no landing/free final0.9; private IMPULSE6→7 exits1; non-author `corpus/lessons/r26-jump-review.md`; measured at `1a854b4d1318434cc0a0945ba165fc584b4a3d43` | r26 |
| coverage | unscored | `python3 .shokunin/game-dev-3d/corpus/artifacts/unreal-r22/verify_descriptor.py` accepts one authored Unreal-style .uplugin; bad-Type `--expect-reject` plus private missing Name, duplicate Type key, extra module reject; non-author `corpus/lessons/r22-unreal-review.md`; Godot default 29/29, Node 3/3 preserved; measured at `40d0df3fae58f758478872ef2b253c4c2dfec03a`. **No Unreal load/runtime.** | r22 |
| calibration | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → 21/21 + four probes; observed slope marker and readback guard: private 45°→35° setting mutant exit1 despite preserved floor/wall outcomes in isolated counterfactual; non-author `corpus/lessons/r16-telemetry-review.md`; measured at `1b864ccf5359811aab6b844f9d7dd51a511b50fe` | r16 |

planned: depth — rendering/GPU behavior, navigation mesh baking,
multiplayer/replication, orthographic boundary precision, sustained slope sliding, friction, actual initial grounded flag/jump controller, other resource types and physics solver edge regimes remain unprobed.
Coverage — executable engines beyond Godot and Node three.js (Unity/Unreal not installed; only fixed-scope static samples, census in corpus/knowledge/engines.md), production-project
launch, broad PackedScene serialization/compatibility, GUI/viewport embedding, export templates for 3D, and platforms
beyond this Linux headless host remain unprobed. Calibration —
no same-step slope contact telemetry or floor-angle boundary sweep; direct-child signal, one identified detached witness timeout and stream-attribution probes exist with narrow limits, not generic crash/process-tree policy.
retired: none.
