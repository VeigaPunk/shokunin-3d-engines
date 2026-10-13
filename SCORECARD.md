# game-dev-3d scorecard — mint

Owned axes: depth, coverage, calibration. Scores remain unassigned without a
quality rubric; a row count is a measurement, not a score or verdict.

| axis | score | evidence / counting command | last change |
|---|---|---|---|
| depth | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → 21/21 + four probes; 30° slope normal Y≈0.866 floor versus 60° normal Y=0.5 wall at 45° floor limit; private source angle and floor-limit mutants exit1; non-author `corpus/lessons/r15-slope-review.md`; measured at `d50c782505238e71ebd2676ba3183696873af27f` | r15 |
| coverage | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → 23/23 + four probes; in-memory PackedScene two-instance local/world transforms and one-instance wrong-local control, private CHILD_LOCAL mutant exit1 without resource leaks; non-author `corpus/lessons/r17-instance-review.md`; measured at `370e2ec3978a438eadebf943dc7a6a0dcff5f80f` | r17 |
| calibration | unscored | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → 21/21 + four probes; observed slope marker and readback guard: private 45°→35° setting mutant exit1 despite preserved floor/wall outcomes in isolated counterfactual; non-author `corpus/lessons/r16-telemetry-review.md`; measured at `1b864ccf5359811aab6b844f9d7dd51a511b50fe` | r16 |

planned: depth — rendering/GPU behavior, navigation mesh baking,
multiplayer/replication, sustained slope sliding, friction and other physics solver edge regimes remain unprobed.
Coverage — engines beyond Godot (Unity, Unreal, three.js, discovered
tooling; census in corpus/knowledge/engines.md), production-project
launch, persisted PackedScene serialization, GUI/viewport embedding, export templates for 3D, and platforms
beyond this Linux headless host remain unprobed. Calibration —
no same-step slope contact telemetry or floor-angle boundary sweep; direct-child signal, one identified detached witness timeout and stream-attribution probes exist with narrow limits, not generic crash/process-tree policy.
retired: none.
