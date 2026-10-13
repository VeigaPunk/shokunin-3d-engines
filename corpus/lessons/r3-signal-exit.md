# Round 3: direct-child Godot signal-exit classification

Run `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-crash-exit` from repo root. Source: `corpus/fixtures/crash_exit3d.gd` and `run_battery.py:probe_crash_exit`; named independent replay and exact receipt fields: `corpus/lessons/r3-signal-review.md`. Fresh run receipts live under ignored `corpus/live/runs/<timestamp>/crash-exit-verdicts.json`; rerun for fresh evidence.

| Same Node3D script and exact marker on stdout | Exit | `classify` with expected exit 1 |
|---|---:|---|
| Normal `quit(1)`, silent stderr | 1 | true |
| Marker observed while child still live, send SIGTERM, silent stderr | -15 | false: `process died on signal 15` |

The default 12 cases stay unchanged. The probe proves direct-child POSIX SIGTERM rejection despite an otherwise valid marker, not a spontaneous crash, SIGSEGV, process-tree timeout, descendant cleanup, or portability. Marker wait is 8 seconds; direct-child cleanup waits 3 seconds before forced kill. A timed-out or unobserved marker fails the opt-in probe.
