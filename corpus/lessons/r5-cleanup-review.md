# Round 5 — independent final-cleanup re-review

Reviewer: `game-dev-3d-r5-cleanup-review`, non-author, Linux `/proc` and Godot `4.7.2.stable.arch_linux.ed1daf0bf`. Read standing mission, r5 LOG and `corpus/lessons/r5-timeout-review.md`; inspected the current runner. No implementation, LOG, report, or SCORECARD edits by this reviewer.

**Ownership-gate correction:** The actual `probe_tree_timeout` `finally` branch now says `if record["witness_verified"] and same_live_witness():` before `os.kill(witness_pid, signal.SIGKILL)`. The timeout SIGTERM and its later SIGKILL have the same conjunctive gate. Earlier verification requires a live `/proc` identity, PPID equal to the launched Godot PID, PGID equal to witness PID, and exact scratch helper/script argument paths; `same_live_witness()` rechecks live state, starttime and both scratch command arguments. Thus the previously identified unverified-witness forced-final-SIGKILL path is closed in this source. The final check does *not* recheck PPID/PGID, and uses no pidfd; it is not a race-free identity or ownership guarantee.

**Safe synthetic ownership-negative:** Parsed the current `probe_tree_timeout` function with Python `ast`, compiled and executed its **actual final witness-`if` node** in isolation, with `os.kill` replaced by a trap that would raise on any call. Passed the reviewer's own PID as the putative witness, without ever signaling it or any unrelated process. Two cases produced zero calls and no cleanup-status change: `(witness_verified=False, same_live_witness=True)` and `(witness_verified=True, same_live_witness=False)`. This dynamically checks that exact final branch's negative gating, not a full adversarial pidfile or real-process ownership-negative. The rest of the ownership safety reasoning is source inspection, not a dynamic proof against an unrelated process.

**Fresh execution:** Both `python3 corpus/fixtures/run_battery.py` and `python3 corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` exited 0. Ignored regenerable receipts:

- `corpus/live/runs/20261013T032445778223Z/verdicts.json`: default PASS, 12/12 (six ordinary, six intended negative controls), all seeded stderr empty.
- `corpus/live/runs/20261013T032515055203Z/{verdicts,tree-timeout-verdicts,crash-exit-verdicts,stream-attribution-verdicts,mutation-verdicts}.json`: combined PASS; baseline 12/12, each prior probe PASS, scratch mutant detected and uncounted in seeded total.

The clean timeout fixture exited 0, emitted one exact `TREE_TIMEOUT_3D: spatial node ready` line on stdout, empty stderr, classified true. Hold-open arm emitted the same marker with empty stderr; `timed_out=true`, logical `actual_exit=null`, error `TIMEOUT after 3 seconds`, classifier false, and separate Godot `cleanup_exit=-9`. Witness pidfile named PID/PGID 1222836 and PPID 1222798; receipt says `witness_verified=true`, `witness_cleanup="SIGTERM to verified detached witness"`, `witness_gone=true`. `/proc/1222836` was absent after completion, and a readable `/proc/*/cmdline` scan found no live `timeout_descendant.py` helper. This fresh run did not independently sample its witness identity while alive; that stronger live observation exists in the earlier r5 non-author review, whereas the new run relies on runner verification and post-run disappearance.

The crash probe kept identical stdout/empty stderr while normal exit 1 classified true and live-marker SIGTERM exit -15 classified false. Stream arms had identical exit 0 and stdout; empty stderr classified true, `STREAM_3D_STDERR` classified false. Mutation detected the authored contact-plane defect at exit 1. Both fresh runs report `seeds_unchanged=true`; their 16 SHA-256 seed digests agree, and independently recomputed on-disk hashes matched. No seeded case was altered.

**Verdict:** The final cleanup-gate defect is fixed for the identified-witness branch. Re-review supports **calibration improved** for one known detached Godot-spawned witness with no observed default regression; depth and coverage unchanged. The earlier first author-run cleanup failure remains a failure, not pass evidence. This does not establish arbitrary process-tree cleanup, detached discovery, absence of intermittent failure, or other-engine/OS behavior. The `/proc` identity-check-to-signal interval can race with PID reuse or process state changes; even with matched starttime there is no atomic pidfd signal. A legitimate descendant that fails verification is not signaled by the witness branch and may linger, potentially holding pipes until the bounded cleanup fails. Godot-group kill does not cover a detached helper. The witness is not `waitpid`-reaped by this runner; gone also treats zombie as not live. Constants retained: hold-open timeout 3s, witness SIGTERM grace 3s and optional SIGKILL grace 3s, Godot pipe/reap 3s, fixture hold timers 30s.

## Correction note — 2026-10-18 (r106)

Dated correction note, not a rewrite of the findings above. The two runnable commands in the fresh-execution sentence cited `.shokunin/game-dev-3d/corpus/fixtures/run_battery.py`. That prefix does not exist at this repo root. Those two command strings only were rewritten to `python3 corpus/fixtures/run_battery.py`. The sentence's "exited 0" and the receipt paths below it are unchanged historical facts.

Original fragment at HEAD `0cc3f4162f8c319f8d01a69a174fe939f36701bd`:

```
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
```

Measured the same day: dead-root form → rc 2, `can't open file '…/.shokunin/…/run_battery.py'`. The no-argument battery and the four-probe battery were not re-run (the script and all four flags exist; `--probe-tree-timeout` is `corpus/fixtures/run_battery.py:1236`). Cited receipts `corpus/live/runs/20261013T032445778223Z/` and `20261013T032515055203Z/` are absent. `/proc/1222836` is absent. Bare narrative name `timeout_descendant.py` does not exist at repo root; the resolving path is `corpus/fixtures/timeout_descendant.py` (exists). That narrative name was not rewritten. `corpus/lessons/r5-timeout-review.md` exists. Ledger: `reports/round-106/sweep/chunk-07.md`.

<!-- r106-seat45-receipt-note -->

> **Non-resolvable receipt note (r106, 2026-10-18, SEAT-45).** Re-checked 2026-10-18: each path below is a concrete `corpus/live/runs` receipt cited in this lesson. The cited path is absent (`test -e` failed) and no durable copy exists under `reports/` (no receipt artifact whose path or `started_utc` is that run id; a prose mention is not a copy). Quoted receipt SHA-256 values on these lines do not match any tracked file or any `reports/` receipt artifact. `corpus/.gitignore` ignores `live/`, so these paths were never tracked. Historical sentences above are unchanged. Register: `reports/round-106/consistency/receipts.md`.
>
> - `corpus/live/runs/20261013T032445778223Z/verdicts.json`
> - `corpus/live/runs/20261013T032515055203Z/{verdicts`
> - `corpus/live/runs/20261013T032445778223Z/`
