# game-dev-3d scorecard — mint

Owned axes: depth, coverage, calibration. Scores remain unassigned without a
quality rubric; a row count is a measurement, not a score or verdict.

| axis | score | evidence / counting command | last change |
|---|---|---|---|
| depth | unscored | `node .shokunin/game-dev-3d/corpus/fixtures/three/run_camera_cases.mjs` → 5/5 (inside, far negative, near negative, two measured-contradiction mutations); original three.js Object3D `run_cases.mjs` 3/3 and Godot combined battery 83/83+four probes unchanged. At near1/far10/FOV90/aspect4/3, near point (0.25,0.125,-0.5) has shared NDC x/y (0.375,0.25) with depth4/12 controls but live `Frustum.containsPoint=false`; near0.1 mutation exits1 on measured true. Non-author `corpus/lessons/r59-three-near-review.md`, work `3cb98a01fcb8df63f238c2fa8b1e3dfbc9620f34`. Near NDC z hand-derived only, no GL/pixel/precision-boundary proof. | r59 |
| coverage | unscored | `node .shokunin/game-dev-3d/corpus/fixtures/three/run_camera_cases.mjs` → 3/3 (inside, far-outside, far=20 mutation), stable four seed hashes; prior `node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs` → 3/3; Godot `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → 83/83 plus four probes, 83 prior raw cases unchanged and 50 seeds stable. Real three.js PerspectiveCamera/Frustum math, same lateral NDC (0.375,0.25), depth4 inside/depth12 outside, far10→20 exits1 on measured frustum contradiction. Non-author `corpus/lessons/r58-three-camera-review.md`; work `9796dc9a08656132f6f44a51dceabd9dde0947b7`. No GL, rendered pixels, or browser proof. | r58 |
| calibration | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → 77/77 (37 ordinary/40 negatives) + four probes; README commands from repo root independently reproduce full 77/77, combined 77/77 + probes, subset 2/2; each case exit/marker/streams unchanged versus r52 and seed digests invariant; non-author `corpus/lessons/r53-doc-review.md`; instructions corrected at `0126831b33026c4010058c9af5e71d66a9f03038`. Documentation contract only, no new mechanics. | r53 |

planned: depth — rendering/GPU behavior, navigation mesh baking,
multiplayer/replication, orthographic boundary precision beyond the one sampled near=1 point, general far-boundary precision beyond the one sampled far=10 point, general slope sliding and friction, untouched initial grounded flag/general jump controller, other resource types and physics solver edge regimes remain unprobed.
Coverage — executable engines beyond Godot and Node three.js (Unity/Unreal not installed; only fixed-scope static samples, census in corpus/knowledge/engines.md), production-project
launch, broad PackedScene serialization/compatibility, GUI/viewport embedding, export templates for 3D, and platforms
beyond this Linux headless host remain unprobed. Calibration —
no same-step slope contact telemetry or floor-angle boundary sweep; direct-child signal, one identified detached witness timeout and stream-attribution probes exist with narrow limits, not generic crash/process-tree policy.
retired: none.
