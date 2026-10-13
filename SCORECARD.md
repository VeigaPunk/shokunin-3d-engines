# game-dev-3d scorecard — mint

Owned axes: depth, coverage, calibration. Scores remain unassigned without a
quality rubric; a row count is a measurement, not a score or verdict.

| axis | score | evidence / counting command | last change |
|---|---|---|---|
| depth | unscored | `test -f .shokunin/game-dev-3d/corpus/lessons/r1-headless-verification.md` → true; r1 decision table distinguishes causal positive controls from discriminating negatives across six 3D mechanic classes | r1 |
| coverage | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py` → all cases PASS (6 ordinary case pairs + discriminating negatives, exact count recorded in the r1 report); predecessor 2D-agnostic suite inherited read-only under corpus/predecessor/ | r1 |
| calibration | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-stream-attribution --probe-crash-exit --probe-failing` → 12/12, stream same stdout/exit0 accept(empty stderr)=true vs reject(STREAM_3D_STDERR)=false; non-author `corpus/lessons/r4-stream-review.md` compared old classifier false accept and retained r3/mutation probes (r4 work commit cited in report) | r4 |

planned: depth — rendering/GPU behavior, navigation mesh baking,
multiplayer/replication, and physics solver edge regimes remain unprobed.
Coverage — engines beyond Godot (Unity, Unreal, three.js, discovered
tooling; census in corpus/knowledge/engines.md), production-project
launch, GUI/viewport embedding, export templates for 3D, and platforms
beyond this Linux headless host remain unprobed. Calibration —
crash-exit classification, process-tree timeout, and stdout/stderr
attribution probes port from the game-dev-2d lessons remain unported.
retired: none.
