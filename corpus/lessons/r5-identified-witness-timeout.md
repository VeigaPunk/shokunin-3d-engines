# Round 5: bounded timeout and identified detached witness

Run `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout` from repo root. Sources: `corpus/fixtures/timeout_tree3d.gd`, `timeout_descendant.py`, `run_battery.py:probe_tree_timeout`; independent receipts and safety review: `corpus/lessons/r5-timeout-review.md` and `r5-cleanup-review.md`. Fresh raw receipts are ignored under `corpus/live/runs/<timestamp>/tree-timeout-verdicts.json`; rerun.

| Same Godot Node3D script/marker | Logical outcome | Classifier | Cleanup |
|---|---|---|---|
| Normal exit | 0 | true | no descendant |
| Hold-open after spawning a witness | null, timeout at 3s | false, despite marker | Godot group killed/reaped; *one verified detached witness* signaled and observed not live |

`OS.create_process` on this host detached the witness into its own process group; killing Godot's group alone cannot clean it. The first author-run **failed**: the witness held inherited pipe handles, so waiting for Godot `communicate` before stopping witness timed out. Corrected ordering stops the verified witness first. The non-author review also found and corrected a forced-final-SIGKILL path that lacked the prior PPID/PGID ownership gate; its fresh reviewer tested that final guard synthetically with a trapped `os.kill`. The logical timeout `actual_exit=null` must never be replaced by Godot's cleanup `-9`.

This verifies only one known witness with Linux `/proc` PID/starttime/cmdline/PPID/PGID checks, not arbitrary tree cleanup. There remains a check-to-signal PID race (no pidfd); unverified descendants are not signaled and may survive. The review's after-run `/proc` absence is a finite observation, not a long-run guarantee. Default twelve seeded cases remain unchanged.
