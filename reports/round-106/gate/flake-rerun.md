# r106 · SEAT-75 · FLAKE-RERUN — six consecutive GATE_WORKDIR harness arms

**Seat:** SEAT-75 FLAKE-RERUN · round 106 · lane `game-dev-3d-shokunin`
**Owned report:** this file. Scratch receipts (not a second report): `reports/round-106/gate/scratch/seat75/`.
**No other file was written.** The gate and the harness were executed, not edited.
**Window:** `2026-10-18T21:21:18Z` → `2026-10-18T21:22:02Z` (UTC).
**Lane HEAD during every run:** `0cc3f4162f8c319f8d01a69a174fe939f36701bd` (printed by the gate as `LANE_HEAD=` in all 36 logs; `git rev-parse HEAD` before arm 1 and after arm 6 matched).

**No Unreal runtime claim.** `command -v UnrealEditor` printed `UnrealEditor: not on PATH`. `ls /usr/bin/Unreal* /opt/Unreal* /home/vgpnk/UnrealEngine` returned "No such file or directory" for each. A green gate is a static-byte result, not editor or live-MCP evidence. The editor is not installed on this host.

---

## 0. Verdict

**STABLE. 6/6 harness arms exited 0. 36/36 underlying gate runs returned `PASS` with exit 0, `POINTERS=103`, `UNRESOLVED=0`, and byte-identical stdout (one sha256 across all 36 logs).**

The durable harness was present, so the manual fallback was not used. The seat's named sample is six consecutive `GATE_WORKDIR` runs; each arm is the harness invoked with `N=6` (not the harness default of 10), serially, so a flake cannot be a concurrency artefact.

| | |
|---|---|
| harness | `reports/round-104/gate/flake_harness.sh` present (`test -f` → `HARNESS_PRESENT=yes`) |
| harness sha256 | `1aeec7000878b4ebcb1f61069202405766dff6b201194267360e68b78dd25bb2` (unchanged before arm 1 and after arm 6; same digest the r104 counting run recorded) |
| gate | `corpus/knowledge/unreal-mcp/gate/run_gate.sh` |
| gate sha256 | `390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf` (identical in every harness header, and identical to the r105 final-run receipt) |
| `GATE_WORKDIR` | `/home/vgpnk/tmp/r106seat75/gw` (real disk, `/dev/mapper/root`, 756G free). Passed as both `GATE_WORKDIR` and `TMPDIR` by the harness. |
| preflight | `SCRATCH_PREFLIGHT=OK (0/20 probe writes failed in /home/vgpnk/tmp/r106seat75/gw)` on all 6 arms |
| pin | `PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297`; every log `CLONE_HEAD=` that pin, `CLONE_DIRTY=0`, `CLONE_TRACKED=12`, `PATH_EXTRA=0 PATH_MISSING=0`, `BLOB_DIFFS=0` |
| log identity | 36 logs, one sha256 `bf37e449ff57133d7376ca011b4a64e7a06d2dce0c1f2067fefa6b86b45a8a40`, 2085 bytes each |
| wall per gate run | min `0.82s`, max `1.39s` (arm 3 run 6), mean `0.877s` (36 samples) |
| harness stderr | 0 bytes on all 6 arms |

`git status --porcelain -- corpus/knowledge/unreal-mcp/gate/run_gate.sh reports/round-104/gate/flake_harness.sh` after the window: empty. Neither file moved.

---

## 1. Command

Repeated six times, `N` = 1..6, waiting for each arm to finish before the next. Working directory: repo root.

```sh
GATE_WORKDIR=/home/vgpnk/tmp/r106seat75/gw \
FLAKE_LOGDIR=reports/round-106/gate/scratch/seat75/armN \
  bash reports/round-104/gate/flake_harness.sh 6
```

Observed harness exit: `0` on every arm. Observed closing lines, identical on all six stdouts:

```
TALLY runs=6 pass=6 fail=0 blocked=0 empty=0 truncated=0 unexpected=0
HARNESS RESULT: STABLE (6/6 runs returned PASS with a matching exit code)
```

`/tmp` was not used as scratch. A single probe write (`printf 'x\n' > /tmp/r106seat75-probe.$$`) succeeded at `2026-10-18T21:21:18Z` (`TMP_PROBE=WRITABLE`), so this seat does **not** claim the per-user `/tmp` quota was exhausted at that instant. Scratch was still pinned to real disk because the host note and the r104 harness contract treat `/tmp` quota failure as intermittent, and a quota fail is indistinguishable from a gate flake.

---

## 2. Arm table

| arm | start (UTC) | end (UTC) | harness rc | pass | fail | blocked | empty | truncated | unexpected | POINTERS set | gate sha prefix | preflight |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 2026-10-18T21:21:18Z | 2026-10-18T21:21:23Z | 0 | 6 | 0 | 0 | 0 | 0 | 0 | 103 | `390a25ae` | OK 0/20 |
| 2 | 2026-10-18T21:21:35Z | 2026-10-18T21:21:41Z | 0 | 6 | 0 | 0 | 0 | 0 | 0 | 103 | `390a25ae` | OK 0/20 |
| 3 | 2026-10-18T21:21:41Z | 2026-10-18T21:21:47Z | 0 | 6 | 0 | 0 | 0 | 0 | 0 | 103 | `390a25ae` | OK 0/20 |
| 4 | 2026-10-18T21:21:47Z | 2026-10-18T21:21:52Z | 0 | 6 | 0 | 0 | 0 | 0 | 0 | 103 | `390a25ae` | OK 0/20 |
| 5 | 2026-10-18T21:21:52Z | 2026-10-18T21:21:57Z | 0 | 6 | 0 | 0 | 0 | 0 | 0 | 103 | `390a25ae` | OK 0/20 |
| 6 | 2026-10-18T21:21:57Z | 2026-10-18T21:22:02Z | 0 | 6 | 0 | 0 | 0 | 0 | 0 | 103 | `390a25ae` | OK 0/20 |

Source: `reports/round-106/gate/scratch/seat75/arms.tsv` plus each `armN.stdout` header. The gap between arm 1 and arm 2 is the operator turn, not a harness pause.

### Per-run wall seconds (all `rc=0 verdict=PASS POINTERS=103`)

| arm | r1 | r2 | r3 | r4 | r5 | r6 |
|---|---|---|---|---|---|---|
| 1 | 0.82 | 0.86 | 0.87 | 0.86 | 0.83 | 0.84 |
| 2 | 0.84 | 0.82 | 0.85 | 0.93 | 0.92 | 0.89 |
| 3 | 0.87 | 1.16 | 0.85 | 0.84 | 0.84 | 1.39 |
| 4 | 0.87 | 0.82 | 0.84 | 0.84 | 0.85 | 0.85 |
| 5 | 0.84 | 0.86 | 0.86 | 0.84 | 0.83 | 0.83 |
| 6 | 0.85 | 0.86 | 0.87 | 0.85 | 0.87 | 0.87 |

The 1.16s and 1.39s rows (arm 3, runs 2 and 6) are timing variance only. Those two logs hash to the same sha256 as the 0.82s logs. No verdict, exit code, pointer count, or step tally moved.

---

## 3. What was constant inside the logs

`grep -hE '^(POINTERS=|GATE RESULT:|STEP=)' arm*/run-*.log | sort | uniq -c` over the 36 logs:

```
    36 GATE RESULT: PASS (checks failed: 0)
    36 POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
   144 STEP=PASS
```

144 = 36 runs × 4 steps. No `STEP=FAIL`, no `STEP=BLOCKED`, no `UNEXPECTED`, no `MISMATCH`, no `EMPTY`, no `TRUNCATED`.

First and last log (`arm1/run-1.log`, `arm6/run-6.log`) both contain:

```
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
WORK_ROOT=/home/vgpnk/tmp/r106seat75/gw (from GATE_WORKDIR)
WORK_ROOT_FREE=756G of 930G (18% used)
LANE_HEAD=0cc3f4162f8c319f8d01a69a174fe939f36701bd
CHECK 2 clone-equivalence
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0
CLONE_TRACKED=12
PATH_EXTRA=0 PATH_MISSING=0
BLOB_DIFFS=0
GATE RESULT: PASS (checks failed: 0)
```

CHECK 2 was a real clone path (no `GATE_REF` was set). `POINTERS=103` matches the round's standing gate fact and did not step during this window, so the r104 citation-race shape (a sibling citation landing mid-arm, `POINTERS` 102→103, harness reporting a true FAIL) did not open here. That is a statement about this 44-second window, not about the rest of the round: sibling seats were writing `reports/round-106/` concurrently, and check 4's pointer count is tree-wide.

---

## 4. Judgment queue

None from this seat. No flake class fired. No mechanical citation fix was in scope (this seat does not own corpus files; the gate path is protected). Nothing to date-note.

---

## 5. Reproduce

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
GATE_WORKDIR=/home/vgpnk/tmp/r106seat75/gw \
FLAKE_LOGDIR=reports/round-106/gate/scratch/seat75/rerun \
  bash reports/round-104/gate/flake_harness.sh 6
```

Expected on this tree, while `POINTERS` is still 103 and the gate sha is still `390a25ae…`: six `verdict=PASS` lines, tally `pass=6`, harness exit 0. `POINTERS` is tree-wide; a later sibling write can change the number without the gate sha moving. The invariant this seat measured is constancy across the arm, not a frozen count for the rest of the round.

---

## 6. Residuals

1. Sample is 6 arms × 6 runs, not the harness default of 10. The seat named six consecutive runs; the harness was the runner. A longer `N` was not required and was not run.
2. Default-environment arm (`GATE_WORKDIR` unset, scratch on `/tmp`) was not run. A single `/tmp` probe write succeeded at the start of the window; that is not a quota-exhaustion reading, and it is not a flake reading either. The r104 false-FAIL under quota pressure remains an unfixed gate property owned elsewhere. This seat does not re-demonstrate it.
3. Stability of these 36 runs is not evidence about Unreal Editor behaviour. The editor is not installed here.
