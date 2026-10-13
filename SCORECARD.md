# game-dev-3d scorecard — mint

Owned axes: depth, coverage, calibration. Scores remain unassigned without a
quality rubric; a row count is a measurement, not a score or verdict.

| axis | score | evidence / counting command | last change |
|---|---|---|---|
| depth | unscored | `node .shokunin/game-dev-3d/corpus/fixtures/three/run_camera_cases.mjs` → 5/5 (inside, far negative, near negative, two measured-contradiction mutations); original three.js Object3D `run_cases.mjs` 3/3 and Godot combined battery 83/83+four probes unchanged. At near1/far10/FOV90/aspect4/3, near point (0.25,0.125,-0.5) has shared NDC x/y (0.375,0.25) with depth4/12 controls but live `Frustum.containsPoint=false`; near0.1 mutation exits1 on measured true. Non-author `corpus/lessons/r59-three-near-review.md`, work `3cb98a01fcb8df63f238c2fa8b1e3dfbc9620f34`. Near NDC z hand-derived only, no GL/pixel/precision-boundary proof. | r59 |
| coverage | unscored | `node .shokunin/game-dev-3d/corpus/fixtures/three/run_ortho_cases.mjs` → 3/3 (depth4/8 in-frustum, depth12 far-negative, far20 mutation fails measured frustum), four seed hashes stable; perspective runner 5/5 and Object3D runner 3/3 unchanged; Godot combined battery 83/83 plus four probes unchanged across 83 raw cases/50 seeds. three.js OrthographicCamera/Frustum under Node, NDC x=.5/y=1/3 at three depths, z=-1/3,5/9,13/9 checked in source. Non-author `corpus/lessons/r60-three-ortho-review.md`, work `1c63d04d9b3c85a8c711cb922369938187806904`. No GL, rendered pixel or browser proof. | r60 |
| calibration | unscored | Three Node runners now compare selected stream exactly to `expectedLine + "\n"`, other stream empty. Non-author `corpus/lessons/r61-stream-review.md`: private copied-source PASS+`\n\n` output with child exit0 accepted by all old `6b1af7e` runners but rejected as positive-only FAIL by all revised runners at work `6c2e02597a08890cfa41ac9fa482e9c1d60367c0`; normal Object3D 3/3, perspective 5/5, ortho 3/3 raw fields unchanged except runner hashes; Godot 83/83+four probes, 83 fields/50 seeds unchanged. Narrow Node script UTF-8 newline policy only. | r61 |

planned: depth — rendering/GPU behavior, navigation mesh baking,
multiplayer/replication, orthographic boundary precision beyond the one sampled near=1 point, general far-boundary precision beyond the one sampled far=10 point, general slope sliding and friction, untouched initial grounded flag/general jump controller, other resource types and physics solver edge regimes remain unprobed.
Coverage — executable engines beyond Godot and Node three.js (Unity/Unreal not installed; only fixed-scope static samples, census in corpus/knowledge/engines.md), production-project
launch, broad PackedScene serialization/compatibility, GUI/viewport embedding, export templates for 3D, and platforms
beyond this Linux headless host remain unprobed. Calibration —
no same-step slope contact telemetry or floor-angle boundary sweep; direct-child signal, one identified detached witness timeout and stream-attribution probes exist with narrow limits, not generic crash/process-tree policy.
retired: none.
