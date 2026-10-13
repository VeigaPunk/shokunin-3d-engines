# game-dev-3d scorecard — mint

Owned axes: depth, coverage, calibration. Scores remain unassigned without a
quality rubric; a row count is a measurement, not a score or verdict.

| axis | score | evidence / counting command | last change |
|---|---|---|---|
| depth | unscored | `test -f .shokunin/game-dev-3d/corpus/lessons/r1-headless-verification.md` → true; r1 decision table distinguishes causal positive controls from discriminating negatives across six 3D mechanic classes | r1 |
| coverage | unscored | `node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs` → three.js 0.186.1 Node scene-graph/math 3/3 (positive, wrong-order negative, runtime-offset mutant); non-author `corpus/lessons/r6-three-review.md`, `r6-isolation-review.md`, `r6-final-review.md`; `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py` → Godot 12/12, 16 current seed hashes stable (r6 work commit cited in report) | r6 |
| calibration | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → default 12/12, clean exit0 accepted, timeout logical null / cleanup -9 rejected, one verified detached witness gone; non-author `corpus/lessons/r5-timeout-review.md` and `r5-cleanup-review.md` (r5 work commit cited in report) | r5 |

planned: depth — rendering/GPU behavior, navigation mesh baking,
multiplayer/replication, and physics solver edge regimes remain unprobed.
Coverage — engines beyond Godot (Unity, Unreal, three.js, discovered
tooling; census in corpus/knowledge/engines.md), production-project
launch, GUI/viewport embedding, export templates for 3D, and platforms
beyond this Linux headless host remain unprobed. Calibration —
crash-exit classification, process-tree timeout, and stdout/stderr
attribution probes port from the game-dev-2d lessons remain unported.
retired: none.
