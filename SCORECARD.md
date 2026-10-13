# game-dev-3d scorecard — mint

Owned axes: depth, coverage, calibration. Scores remain unassigned without a
quality rubric; a row count is a measurement, not a score or verdict.

| axis | score | evidence / counting command | last change |
|---|---|---|---|
| depth | unscored | `node .shokunin/game-dev-3d/corpus/fixtures/three/run_ortho_cases.mjs` → 5/5: depths4/8 in-frustum, depth12 far-outside, positive-forward depth0.5 before near1 with same NDC x=.5/y=1/3 but `Frustum.containsPoint=false`; near0.1 mutation exit1 on measured true, far20 mutation retained. Previous 3 ortho raw arms unchanged; perspective 5/5, Object3D 3/3 and Godot combined 83/83+four probes unchanged. Non-author `corpus/lessons/r62-three-ortho-near-review.md`, work `e0bc0327d1e3edbabfaeb11b653b3f6c7dd80ceb`. Node math only, no GL/pixel/boundary precision proof. | r62 |
| coverage | unscored | `node .shokunin/game-dev-3d/corpus/fixtures/three/run_ray_cases.mjs` → 3/3: real three.js BufferGeometry/Mesh/Raycaster translated triangle interior hit (2,0,-5), distance5, lateral x5 miss with live hit, mesh x2→3 mutation exits1 on observed_hits=0; four seeds stable. Old Node Object3D 3/3, perspective 5/5, orthographic 5/5 and Godot combined 83/83+four probes with 83 raw fields/50 seeds unchanged. Named non-author `corpus/lessons/r63-three-ray-review.md`, work `cfbcda21df707a75b024a81c5063700c06b39f0e`. No arbitrary mesh, GL, rendered pixel or browser evidence. | r63 |
| calibration | unscored | Three Node runners now compare selected stream exactly to `expectedLine + "\n"`, other stream empty. Non-author `corpus/lessons/r61-stream-review.md`: private copied-source PASS+`\n\n` output with child exit0 accepted by all old `6b1af7e` runners but rejected as positive-only FAIL by all revised runners at work `6c2e02597a08890cfa41ac9fa482e9c1d60367c0`; normal Object3D 3/3, perspective 5/5, ortho 3/3 raw fields unchanged except runner hashes; Godot 83/83+four probes, 83 fields/50 seeds unchanged. Narrow Node script UTF-8 newline policy only. | r61 |

planned: depth — rendering/GPU behavior, navigation mesh baking,
multiplayer/replication, orthographic boundary precision beyond the one sampled near=1 point, general far-boundary precision beyond the one sampled far=10 point, general slope sliding and friction, untouched initial grounded flag/general jump controller, other resource types and physics solver edge regimes remain unprobed.
Coverage — executable engines beyond Godot and Node three.js (Unity/Unreal not installed; only fixed-scope static samples, census in corpus/knowledge/engines.md), production-project
launch, broad PackedScene serialization/compatibility, GUI/viewport embedding, export templates for 3D, and platforms
beyond this Linux headless host remain unprobed. Calibration —
no same-step slope contact telemetry or floor-angle boundary sweep; direct-child signal, one identified detached witness timeout and stream-attribution probes exist with narrow limits, not generic crash/process-tree policy.
retired: none.
