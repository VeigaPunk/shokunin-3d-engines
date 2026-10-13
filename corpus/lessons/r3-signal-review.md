# Round 3 independent signal-exit review — 2026-10-13

Reviewer: `game-dev-3d-r3-signal-review`, not the probe author. I read the standing mission, round-3 LOG before-state, fixture README, `crash_exit3d.gd`, and `run_battery.py`; then independently ran the two commands from the repository root:

```sh
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-crash-exit
```

Both commands returned 0 on Godot `4.7.2.stable.arch_linux.ed1daf0bf`. Reproducible, ignored receipts:

- Default: `.shokunin/game-dev-3d/corpus/live/runs/20261013T031034988809Z/verdicts.json`
- Opt-in: `.shokunin/game-dev-3d/corpus/live/runs/20261013T031038925033Z/verdicts.json` and `crash-exit-verdicts.json`

Both batteries report `PASS`, `cases=12 pass=12 fail=0 ordinary=6 negative_controls=6`. All 12 case names, stdout-line arrays, stderr-line arrays, marker expectations, and actual exit values match across these runs; each case has empty rejection reasons. The six ordinary cases exit 0; the six negative controls exit 2. The opt-in pair is separate and uncounted (`probes=1` in console output). Both receipt sets say `seeds_unchanged=true`; their 13-entry SHA-256 maps match one another and my fresh digest of the fixture directory after both runs (excluding `__pycache__`, per the runner).

The signal receipt reports `verdict=PASS`. Both arms printed the identical full stdout, including the Godot banner followed by the exact line `CRASH_EXIT_3D: spatial node ready`, and both had `stderr=""` and `error=null`. Normal arm: `actual_exit=1`, `classified_normal=true`, `reasons=[]`. Hold-open arm: `marker_observed_while_live=true`, `signal_sent=true`, `actual_exit=-15`, `classified_normal=false`, `reasons=["process died on signal 15"]`. Source inspection corroborates the mechanism: a Node3D is placed at `(2,3,-4)` and checked before printing; without `--hold-open`, the script calls `quit(1)`; with it, the script awaits a 30-second timer before that call. The runner waits up to 8 seconds for the exact marker while `process.poll() is None`, sends SIGTERM to this direct child, and `communicate(timeout=3)` reaps it; timeout triggers `kill()` and another bounded `communicate(timeout=3)`. Its classifier explicitly rejects *any* negative return code before considering the otherwise matching marker. After my replay, `/proc` enumeration found no process with `--script res://crash_exit3d.gd` in its command line.

**Assessment:** independent evidence supports the declared calibration improvement: a live Godot direct child with identical stdout is accepted on expected normal exit 1 but rejected on SIGTERM -15, with unchanged 12/12 baseline and unchanged seeds. Depth and coverage remain unchanged. No observed fault in this run. This is not a spontaneous crash, SIGSEGV, process-tree timeout/orphan test, or rendered-output test. Cleanup is bounded by the runner's timeout logic for the direct child, not verified for arbitrary descendants; `/proc` scan is an after-run snapshot, not continuous observation. The ignored receipts may be deleted; rerun commands above to reproduce them. The probe's success relies on this POSIX host and Godot build, not evidence for other engines/platforms.
