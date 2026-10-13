# game-dev-3d scorecard — mint

Owned axes: depth, coverage, calibration. Scores remain unassigned without a
quality rubric; a row count is a measurement, not a score or verdict.

| axis | score | evidence / counting command | last change |
|---|---|---|---|
| depth | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → 27/27 + four probes; `resource_local_to_scene=true` distinct BoxMesh identities, isolated first-size mutation, false shared identity and propagation to second+source; private initial-size mutant exit1; non-author `corpus/lessons/r20-resource-final-review.md`; measured at `75101f9477e521ad4805775777f6d427671d7e88` | r20 |
| coverage | unscored | `uv run --no-project --with pyyaml python .shokunin/game-dev-3d/corpus/artifacts/unity-r19/verify_scene.py` accepts one authored Unity-style static scene; `... Hierarchy.broken-reference.unity --expect-reject` rejects dangling father; non-author `corpus/lessons/r19-unity-final-review.md` adds four private rejection controls; Godot default 25/25, Node 3/3 preserved; measured at `8e91d7f65c155b60074f8773106761d005cf1757`. **No Unity import/runtime.** | r19 |
| calibration | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → 21/21 + four probes; observed slope marker and readback guard: private 45°→35° setting mutant exit1 despite preserved floor/wall outcomes in isolated counterfactual; non-author `corpus/lessons/r16-telemetry-review.md`; measured at `1b864ccf5359811aab6b844f9d7dd51a511b50fe` | r16 |

planned: depth — rendering/GPU behavior, navigation mesh baking,
multiplayer/replication, sustained slope sliding, friction, saved-scene resource locality and other physics solver edge regimes remain unprobed.
Coverage — executable engines beyond Godot and Node three.js (Unity/Unreal not installed; Unity-style static sample only, census in corpus/knowledge/engines.md), production-project
launch, broad PackedScene serialization/compatibility, GUI/viewport embedding, export templates for 3D, and platforms
beyond this Linux headless host remain unprobed. Calibration —
no same-step slope contact telemetry or floor-angle boundary sweep; direct-child signal, one identified detached witness timeout and stream-attribution probes exist with narrow limits, not generic crash/process-tree policy.
retired: none.
