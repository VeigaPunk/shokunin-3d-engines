# SEAT-48 CLOSE-FLAKE-RERUN — r104 close-of-round durability record

**Author:** SEAT-48 CLOSE-FLAKE-RERUN · round 104 · lane `game-dev-3d-shokunin`
**Window:** 2026-10-18T19:18:40Z – 19:25:0xZ (UTC) · host `plazir27` · Linux `7.2.3-arch1-3`
**Lane HEAD:** `88c3b2ca70fc83ec47a931d7b6dcff85a111c04e` (`88c3b2c`, r103 report-last)
**Raw evidence:** `reports/round-104/gate/scratch/seat48/` (per-run logs, TSV tables, the runner `close-runs.sh`)

## Verdict

**The gate is NOT durable at the close of r104 on its default scratch root.** Six consecutive
default runs did not return one verdict; they returned two. The cause is **not** the vendored bytes
and **not** the network — it is `/tmp`, where the gate's scratch lives by default. On the same frozen
gate bytes, same tree, minutes apart:

| arm | runs | PASS | BLOCKED | FAIL | harness verdict |
|---|---|---|---|---|---|
| default workdir (`/tmp`) | 6 | 1 | 5 | 0 | `FLAKY` (rc=1) |
| `GATE_WORKDIR` on the repo filesystem | 6 | 6 | 0 | 0 | `STABLE` (rc=0) |

That paired A/B is the headline: **the flake is a property of the scratch filesystem, and C2's
`GATE_WORKDIR` removes it.** Neither arm's red is evidence about Unreal Editor behaviour — the editor
is not installed on this host, and no run here makes a runtime claim.

## Pinned identities (the report applies only to these bytes)

| artifact | sha256 |
|---|---|
| `corpus/knowledge/unreal-mcp/gate/run_gate.sh` | `e55213049db7538d2c126f02b7e6d91bfb38af77ff5f8b375b521b400d7b9c08` (`e5521304…`) |
| `reports/round-104/gate/flake_harness.sh` | `1aeec7000878b4ebcb1f61069202405766dff6b201194267360e68b78dd25bb2` |
| subtree `upstream/` + `executability/` + `.manifest.d/` | `2f5cd3f110768d08a1168762e4d63901621547ddd8c2a1c00ac22cff7689a6ba` |

The subtree hash was **identical at the start and end of the window and across every run**. Nothing
in the pinned trees moved. `UNRESOLVED=0` in every run that completed CHECK 4.

**Measurement hazard, stated up front:** the gate file was being edited *by the C2 seat throughout my
window*. I observed its sha move `577c8b54 → 7404998e → 2436678f → 7903c589 → abebee5c → 15fc46d5 →
b6d8c61a → e5521304`. Two runs died on `bash: syntax error near unexpected token` because they
executed a file that was half-written at that instant. Everything below is labelled with the sha it
was measured on; only the final section is on the frozen `e5521304`.

## The final six consecutive runs (frozen `e5521304`, default workdir)

Command, run six times back to back with no gap:

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "RC=$?"
```

| run | gate sha | `/tmp` avail | rc | `GATE RESULT:` | STEP lines | POINTERS | UNRESOLVED | secs |
|---|---|---|---|---|---|---|---|---|
| 1 | `e5521304…` | 3.2G | 0 | `PASS (checks failed: 0)` | 4/0 | 103 | 0 | 1.13 |
| 2 | `e5521304…` | 3.2G | 0 | `PASS (checks failed: 0)` | 4/0 | 103 | 0 | 1.41 |
| 3 | `e5521304…` | 3.2G | 0 | `PASS (checks failed: 0)` | 4/0 | 103 | 0 | 1.27 |
| 4 | `e5521304…` | 3.2G | 0 | `PASS (checks failed: 0)` | 4/0 | 103 | 0 | 1.03 |
| 5 | `e5521304…` | 3.1G | **2** | `BLOCKED (checks failed: 0; CHECK 2 could not run)` | 3/1 | 103 | 0 | 0.90 |
| 6 | `e5521304…` | 3.1G | 0 | `PASS (checks failed: 0)` | 4/0 | 103 | 0 | 1.35 |

**5 PASS / 1 BLOCKED.** Run 5's CHECK 2 failed at the clone's *first write*:

```text
error: failed to write new configuration file /tmp/tmp.3e7pNqYZcg/clone/.git/config.lock
fatal: could not set 'core.repositoryformatversion' to '0'
```

Runs 1–4 were byte-identical to each other; run 6 differed from them in exactly one line —
`WORK_ROOT_FREE=3.1G` vs `3.2G`. So the *content* of a PASS is reproducible; only *whether* you get
one is not.

The same gate bytes under `GATE_WORKDIR` pointed at the repo filesystem (930G btrfs, 772G free) gave
**6/6 `PASS`, byte-identical logs, zero residue** in the scratch dir afterwards
(`find "$GW" -mindepth 1 | wc -l` → `0`), and `WORK_ROOT_FREE=772G of 930G (16% used)`.

## Anomaly characterization

Four distinct signatures were observed. Only the first two are the r103 root cause; the third and
fourth are *different* problems that a durability record should not blur together.

**S1 — manifest-sweep FAIL with an empty diagnostic.** Printed `FAIL per-seat manifest sweep
(--strict) failed:` and then **nothing**, while CHECK 1 itself scored `MANIFEST_OK=12 FAILED=0 RC=0`.
Mechanism, reproduced directly: the gate does `MANLOG=$(mktemp)` then redirects the sweep into it.
`mktemp` returns a `/tmp` path and *succeeds*, the redirect *opens* fine, but the filesystem raises
`EDQUOT` **at flush/close** — after the shell has already reported success. The log is left 0 bytes,
so the failure branch prints its header and an empty body, and the sweep's exit code 1 is real.

```text
python3: open('/tmp/...','wb') returns, then close() raises
         OSError: [Errno 122] Disk quota exceeded
(cd . && sha256sum --strict -c .manifest.d/*.sha256 > /tmp/LOG 2>&1) → rc=1, log bytes=0   (x3)
(cd . && sha256sum --strict -c .manifest.d/*.sha256 > REPO/LOG 2>&1) → rc=0, log bytes=864  (x3)
```

Note the shape of the lie: `sha256sum` was *asked to verify 12 files and could not write its
receipt*. The gate reported that as a manifest failure. It is a disk failure wearing a manifest
failure's clothes. Post-C2 this path is fixed at the source — `mktemp -p "$WORK_ROOT"` with an
explicit `|| MANLOG=''` and a loud `FAIL cannot create scratch file under …`.

**S2 — CHECK 2 BLOCKED, labelled `(network)`.** A local disk failure was reported as an unreachable
upstream, which is the single most misleading thing the gate can say here, because it invites the
reader to retry later instead of moving the scratch. Proven not to be network:

```text
git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin HEAD
  → a6aa73ada02a9fb1f5415bec491f9942c519b297    rc=0     # network fine
timeout 120 git clone --quiet <same url> /tmp/tmp.ZXqpJt5bn5/clone
  → error: copy-fd: write returned: Disk quota exceeded
  → fatal: cannot copy '.../description': Disk quota exceeded    rc=128   # disk not fine
```

**S3 — CHECK 2 BLOCKED, correctly relabelled `(local-resource)`.** Post-C2 (`b6d8c61a…`) the same
condition prints a distinct, actionable block, and this is a real improvement worth recording:

```text
CHECK 2 BLOCKED (local-resource)
BLOCKED fresh clone could not complete — scratch filesystem full or quota-exhausted
BLOCKED the network may be fine: this is a DISK failure, not an unreachable upstream
BLOCKED retry with GATE_WORKDIR (or TMPDIR) on a roomy filesystem — see gate/README.md
fatal: write error: Disk quota exceeded
```

**S4 — CHECK 4 pointer FAIL, unrelated to scratch.** In the mid-window `final-gw-*` series four runs
failed with `MISSING-PATH-REL reports/round-104/gate/workdir.md` (`POINTERS=103 UNRESOLVED=1`). This
is **not** a scratch flake: `gate/README.md` (lines 373, 441) cites that report as its transcript, and
at the time the file did not yet exist. It appeared at 19:24:52Z (13,645 bytes) and the pointer
resolved from the next run on. Correct behaviour, wrong moment — a close-out gate cannot be green
while the round's own deliverables are still being written. **Any close run must be taken after the
subtree's citations all exist, not merely after the tree stops being *edited*.**

**S5 — syntax errors from reading a half-written script.** Two runs aborted with
`run_gate.sh: line 187: syntax error near unexpected token 'fi'` and
`flake_harness.sh: line 209: syntax error near unexpected token ')'`. Both files were being saved at
that instant by the seats that own them. Transient and not a gate defect, but it means a flake
harness run during a live edit reports FLAKY for a reason that has nothing to do with the gate.

## Host condition that produced all of this

`/tmp` is a tmpfs with a **per-user quota**, and it was at or over the edge for the whole window:

```text
systemd tmp.mount: Options=…,size=50%,nr_inodes=1m,x-systemd.graceful-option=usrquota
/proc/mounts:      tmpfs /tmp tmpfs rw,nosuid,nodev,nr_inodes=1048576,inode64,huge=advise,usrquota
df -h  /tmp → 16G total, 12–13G used, 3.1–3.3G avail, 79–80%
df -i  /tmp → 1048576 inodes, 665239 used, 383337 free, 64%
```

`/tmp` held 7,551 top-level entries, **7,919 owned by `vgpnk`**, of which 2,365 are directories
(the largest: `arc2-l3r3-C1-inst` 1.6G, `seat50` 927M, `seat44-a4b` 885M). Capacity was never the
binding constraint — `df` showed 3.1G free throughout — the **per-user quota** was.

The failure mode is *intermittent at the byte level*, which is why it reads as a flake rather than a
hard break. On the same `/tmp`, seconds apart, both of these are true:

```text
300 × 8KiB writes to /tmp → 300 OK, 0 failed        # clean sweep, quota momentarily under
python3: write 4096 B then close → Errno 122        # EDQUOT at flush, quota momentarily over
df -h /tmp unchanged at 3.1G free in both cases
```

Because 13 other sessions were writing and removing files in that shared tmpfs the entire time, the
quota headroom oscillates. That is the honest characterization: **not "`/tmp` is full", but "`/tmp`'s
per-user quota is at the margin and the gate's scratch allocation races other tenants for it."**

## What the numbers say about the fix

The paired control is unambiguous — same gate sha `e5521304…`, same subtree hash `2f5cd3f1…`, same
minute, only the scratch root differs:

| arm | harness | result | rc |
|---|---|---|---|
| `FLAKE_LOGDIR=… bash reports/round-104/gate/flake_harness.sh 6` | `flake_harness.sh` @ `1aeec700…` | `pass=1 blocked=5` → **`HARNESS RESULT: FLAKY`** | 1 |
| `GATE_WORKDIR=<repo dir> FLAKE_LOGDIR=… bash … 6` | same | `pass=6 blocked=0` → **`HARNESS RESULT: STABLE`** | 0 |

The harness's own `SCRATCH_PREFLIGHT=OK (0/20 probe writes failed in /tmp)` line in the failing arm
is worth reading carefully: a 20-probe preflight **cannot** detect this flake, because the 20 probes
landed in a lucky window while the gate's own longer-lived writes did not. The preflight is not
evidence of health; only the repeated runs are.

Earlier in the window, before the frozen bytes, the same contrast held on the pre-C2 gate
(`577c8b54…`) with `TMPDIR` as the lever: default **0 PASS / 2 BLOCKED / 10 FAIL** across 12 paired
runs, `TMPDIR=<repo dir>` **11 PASS / 0 BLOCKED** (the 12th was an S5 syntax abort).

## Residuals and what a later round should decide

1. **`/tmp` is still the default.** `WORK_ROOT=${GATE_WORKDIR:-${TMPDIR:-/tmp}}` is the right
   precedence and the loud failure is the right behaviour, but a default run on this host is still
   a coin-flip. A caller who does not read the README gets a red gate. Consider whether a close-out
   gate should refuse to run on a scratch root it can prove is under quota pressure, rather than
   start and fail partway.
2. **S4 is unaddressed by C2.** The gate scans the live `reports/` tree for repo-relative pointers
   (`corpus/*|reports/*|docs/*` → `REPO_ROOT`), so its verdict depends on whether the round's own
   deliverables exist yet. That is intentional (it is the "second line of defence for peers'
   reports"), but it makes the gate un-runnable as a close-out artifact until the round is complete.
   The ordering rule is: write the cited reports first, then take the close series.
3. **`POINTERS` is not a contract, and this window proves it.** It read `101` for most of the round,
   `102`, then `103` as `gate/README.md` gained prose — within a single session, on a subtree whose
   hash never changed. The binding invariant remains `UNRESOLVED=0`.
4. **The pre-existing CHECK 2 corner is still open** (recorded in `gate/README.md`): BLOCKED *and*
   another check failing prints `GATE RESULT: FAIL` and exits 1, losing the third state. Not
   exercised here.

## Re-run recipe

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh   # expect e5521304… for THIS report to apply

# default arm — may be PASS or BLOCKED depending on /tmp quota headroom
bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "RC=$?"

# durable arm — this is what the close record should be taken on
GW=$(mktemp -d "$PWD/.gate-work.XXXXXX")
GATE_WORKDIR="$GW" bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "RC=$?"

# repeated-run durability check, both arms
bash reports/round-104/gate/flake_harness.sh 6                                   # expect FLAKY on this host
GATE_WORKDIR="$GW" bash reports/round-104/gate/flake_harness.sh 6                # expect STABLE
```

Note the harness now runs its own 20-write preflight and reports `truncated=` in its tally; on the
frozen bytes it read `TALLY runs=6 pass=1 fail=0 blocked=5 empty=0 truncated=0 unexpected=0` for the
default arm and `pass=6 blocked=0` for the `GATE_WORKDIR` arm.
