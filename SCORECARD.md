# game-dev-3d scorecard — mint

Owned axes: depth, coverage, calibration. Scores remain unassigned without a
quality rubric; a row count is a measurement, not a score or verdict.

| axis | score | evidence / counting command | last change |
|---|---|---|---|
| depth | unscored | `test -f .shokunin/game-dev-3d/corpus/lessons/r1-headless-verification.md` → true; r1 decision table distinguishes causal positive controls from discriminating negatives across six 3D mechanic classes | r1 |
| coverage | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py` → all cases PASS (6 ordinary case pairs + discriminating negatives, exact count recorded in the r1 report); predecessor 2D-agnostic suite inherited read-only under corpus/predecessor/ | r1 |
| calibration | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-crash-exit` → 12/12 baseline plus opt-in normal 1 accepted / live SIGTERM -15 rejected with same marker; non-author `corpus/lessons/r3-signal-review.md` independently replayed and confirmed digests/streams (r3 work commit cited in report) | r3 |

planned: depth — rendering/GPU behavior, navigation mesh baking,
multiplayer/replication, and physics solver edge regimes remain unprobed.
Coverage — engines beyond Godot (Unity, Unreal, three.js, discovered
tooling; census in corpus/knowledge/engines.md), production-project
launch, GUI/viewport embedding, export templates for 3D, and platforms
beyond this Linux headless host remain unprobed. Calibration —
crash-exit classification, process-tree timeout, and stdout/stderr
attribution probes port from the game-dev-2d lessons remain unported.
retired: none.
