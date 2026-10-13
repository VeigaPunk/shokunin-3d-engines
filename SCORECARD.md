# game-dev-3d scorecard — mint

Owned axes: depth, coverage, calibration. Scores remain unassigned without a
quality rubric; a row count is a measurement, not a score or verdict.

| axis | score | evidence / counting command | last change |
|---|---|---|---|
| depth | unscored | `node .shokunin/game-dev-3d/corpus/fixtures/three/run_order_cases.mjs` → independent 9/9 at amended work `469e576da146fd042e9345a38005ec55f1da55d4`: same-process default two-hit recast before gated cast; near=5 includes far depth5, far=3 includes near depth3, exact object/point/distance; near5→5.25 mutation exits1 on actual zero hits while baseline=2. Six prior order raw rows, other Node 3/5/5/5 raw rows/hashes, Godot 83/83+four probes and 50 hashes unchanged. Non-author `corpus/lessons/r67-ray-boundary-review.md`. Only sampled exactly representable CPU hit distances, not arbitrary precision or rendering. | r67 |
| coverage | unscored | `node .shokunin/game-dev-3d/corpus/fixtures/three/run_layer_cases.mjs` → non-author 4/4: layer0 near depth3, layer1 far depth5; ray mask1 selects near, mask2 far, mask3 both ordered; far layer1→0 mutation with ray mask2 exits1 on zero actual hits. Prior five Node suites 3/5/5/5/9 complete payloads unchanged. Godot first replay 82/83 on isolated SDL gamepad-mapping stderr, no-change retry 83/83+four probes with all 83 stable raw rows/50 hashes equal r67; preserve caveat. Evidence `corpus/lessons/r68-ray-layers-review.md`, work `f3e5644d5ec15637e0fd6a9c91174c828818a2bf`. CPU Raycaster mask selection only, not rendered visibility. | r68 |
| calibration | unscored | Three Node runners now compare selected stream exactly to `expectedLine + "\n"`, other stream empty. Non-author `corpus/lessons/r61-stream-review.md`: private copied-source PASS+`\n\n` output with child exit0 accepted by all old `6b1af7e` runners but rejected as positive-only FAIL by all revised runners at work `6c2e02597a08890cfa41ac9fa482e9c1d60367c0`; normal Object3D 3/3, perspective 5/5, ortho 3/3 raw fields unchanged except runner hashes; Godot 83/83+four probes, 83 fields/50 seeds unchanged. Narrow Node script UTF-8 newline policy only. | r61 |

planned: depth — rendering/GPU behavior, navigation mesh baking,
multiplayer/replication, orthographic boundary precision beyond the one sampled near=1 point, general far-boundary precision beyond the one sampled far=10 point, general slope sliding and friction, untouched initial grounded flag/general jump controller, other resource types and physics solver edge regimes remain unprobed.
Coverage — executable engines beyond Godot and Node three.js (Unity/Unreal not installed; only fixed-scope static samples, census in corpus/knowledge/engines.md), production-project
launch, broad PackedScene serialization/compatibility, GUI/viewport embedding, export templates for 3D, and platforms
beyond this Linux headless host remain unprobed. Calibration —
no same-step slope contact telemetry or floor-angle boundary sweep; direct-child signal, one identified detached witness timeout and stream-attribution probes exist with narrow limits, not generic crash/process-tree policy.
retired: none.
