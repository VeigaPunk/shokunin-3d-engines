# game-dev-3d scorecard — mint

Owned axes: depth, coverage, calibration. Scores remain unassigned without a
quality rubric; a row count is a measurement, not a score or verdict.

| axis | score | evidence / counting command | last change |
|---|---|---|---|
| depth | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → 79/79 (38 ordinary/41 negative) + four probes; `--only camera3d_ortho_near_boundary_inside,camera3d_ortho_near_boundary_outside` → 2/2 at forward depths 1.01/0.99 around near=1 with shared projected pixel and distinct live frustum status; private outside -0.99→-1.01 exits1 at measured in-frustum contradiction; non-author `corpus/lessons/r54-near-review-inherited.md`; measured at work commit `2c50e4c18c54625599d4b1e1d38a2028323330de`. No exact-plane, pixels or GPU proof. | r54 |
| coverage | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → 73/73 + four probes; live NavigationAgent3D on authored map next-path initialization yields path(1,0,1)→(3,0,3) vs alternate end(3,0,1), actor stationary; private normal target Z3→2 exits1 on measured agent path/next; non-author `corpus/lessons/r49-navagent-review.md`; measured at `ca4b3184d01f961b41aa6a084b49190a3f895190`. No autonomous motion/baking. | r49 |
| calibration | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → 77/77 (37 ordinary/40 negatives) + four probes; README commands from repo root independently reproduce full 77/77, combined 77/77 + probes, subset 2/2; each case exit/marker/streams unchanged versus r52 and seed digests invariant; non-author `corpus/lessons/r53-doc-review.md`; instructions corrected at `0126831b33026c4010058c9af5e71d66a9f03038`. Documentation contract only, no new mechanics. | r53 |

planned: depth — rendering/GPU behavior, navigation mesh baking,
multiplayer/replication, exact orthographic boundary at near=1, far-boundary precision, general slope sliding and friction, untouched initial grounded flag/general jump controller, other resource types and physics solver edge regimes remain unprobed.
Coverage — executable engines beyond Godot and Node three.js (Unity/Unreal not installed; only fixed-scope static samples, census in corpus/knowledge/engines.md), production-project
launch, broad PackedScene serialization/compatibility, GUI/viewport embedding, export templates for 3D, and platforms
beyond this Linux headless host remain unprobed. Calibration —
no same-step slope contact telemetry or floor-angle boundary sweep; direct-child signal, one identified detached witness timeout and stream-attribution probes exist with narrow limits, not generic crash/process-tree policy.
retired: none.
