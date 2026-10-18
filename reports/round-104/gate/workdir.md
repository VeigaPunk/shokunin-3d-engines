# SEAT-12 GATE-WORKDIR-AUTHOR — gate scratch-root resilience

**Seat:** SEAT-12 GATE-WORKDIR-AUTHOR · round 104 · lane `game-dev-3d-shokunin`
**Owned paths:** `corpus/knowledge/unreal-mcp/gate/run_gate.sh`, `corpus/knowledge/unreal-mcp/gate/README.md`, this file
**Lane HEAD at run:** `88c3b2ca70fc83ec47a931d7b6dcff85a111c04e` (r103 report-last)
**Claim:** C2 (coverage) — gate workdir resilience + full attack regression
**Target after change:** `run_gate.sh` sha256 `e55213049db7538d2c126f02b7e6d91bfb38af77ff5f8b375b521b400d7b9c08` (442 lines)
**Target before change:** `run_gate.sh` sha256 `577c8b5489577b948536005a170da14ae3d4e13c11776aeca8f803bfb5fcefa0` (347 lines; the r103 settled scanner)
**README after change:** sha256 `e3bc66b7f5d981a1128dc60ae910ec7c53dac85107c67802134e32bc7c0e98bf`

No Unreal runtime claim is made anywhere below. The editor is not installed on this host; every
statement here is about a static checker over vendored bytes. **A green gate is static evidence
only** and is never evidence of live-MCP or editor behaviour.

---

## 1. What was wrong (the r103 routed defect, reproduced live)

`reports/round-103/gate/close-runs.md` recorded two anomalies in the r103 close window and could not
reproduce them: one run printed `GATE RESULT: FAIL (checks failed: 1)` with CHECK 4 PASS, and one run
produced **empty output with exit 1**. Root cause class named there: `/tmp` is a 16G tmpfs shared
with the user's other sessions under a per-user quota, and **both** of the gate's scratch sites were
plain `mktemp` — i.e. hardcoded to `/tmp`.

This seat reproduced the class on the unmodified r103 script, at lane HEAD, during this round:

```
$ df -h /tmp
tmpfs              16G   12G  3.2G  79% /tmp
```

**(a) A local disk failure reported as a network failure.** The network was demonstrably up:

```
$ timeout 15 git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297	HEAD
```

Yet the gate's CHECK 2 reported BLOCKED, because `git clone` into `/tmp` fails when `/tmp` is full —
while the identical clone into `$HOME` succeeds at the pin:

```
$ git clone --quiet <repo> /tmp/seat12-clonetest
error: copy-fd: write returned: Disk quota exceeded
fatal: cannot copy '/usr/share/git-core/templates/description' to '/tmp/seat12-clonetest/.git/description': Disk quota exceeded
clone_into_tmp_rc=128

$ git clone --quiet <repo> /home/vgpnk/.cache/r104-seat12/ct
clone_into_home_rc=0
$ git -C /home/vgpnk/.cache/r104-seat12/ct rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
```

So a *disk* condition produced `CHECK 2 BLOCKED (network)` and exit 2 — the reader is sent to the
wrong subsystem. r103's SEAT-01 recorded the same symptom from the other side ("CHECK 2 flaky … while
the network was demonstrably up").

**(b) The diagnostic destroyed itself.** The clone's stderr was redirected to `$WORK/clone.log`,
which lives on the same full filesystem, so under pressure the log was created empty and the
`BLOCKED` branch printed **no cause line at all**:

```
CHECK 2 BLOCKED (network)
BLOCKED fresh clone could not complete — upstream unreachable, nothing compared
BLOCKED exit 2 is not a verdict: the vendored bytes are UNCHECKED, not divergent
STEP=BLOCKED
```

**(c) The empty-output flake.** Two further runs on the unmodified script produced **completely empty
stdout and stderr with exit 1** — the exact anomaly `close-runs.md` could not reproduce:

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh > /tmp/seat12-r1.out 2>/tmp/seat12-r1.err; echo rc=$?
rc=1
$ stat -c%s /tmp/seat12-r1.out /tmp/seat12-r1.err
0
0
```

Three runs later the same script returned rc=0 with a full 1986-byte report — a true flake, in the
window of this seat, on this host.

## 2. The change

Both scratch sites now live under one root:

```
WORK_ROOT=${GATE_WORKDIR:-${TMPDIR:-/tmp}}
```

- `GATE_WORKDIR` (new) > `TMPDIR` (POSIX convention) > `/tmp` (default, so every existing caller is
  byte-for-byte unaffected).
- The root is **validated before any check runs** — a non-directory or non-writable root is a named
  `FAIL … exit 1`, not an obscure later failure.
- Both `mktemp` calls are rooted with `-p "$WORK_ROOT"` and their failure is now **loud** (the old
  bare `MANLOG=$(mktemp)` left `MANLOG` empty under pressure, so the redirect failed and a *clean*
  tree reported the manifest sweep as broken — the r103b defect class, one layer down).
- The banner prints the choice and the room left: `WORK_ROOT=… (from GATE_WORKDIR|TMPDIR|default)`
  and `WORK_ROOT_FREE=…`. `df` is used only if present — it is deliberately **not** added to the
  required-tool guard, which would make the gate more brittle.
- The clone's stderr is captured **in memory** (`C2_LOG`) and only then written to disk
  best-effort, so the evidence survives the full filesystem that caused the failure.
- A clone failure whose log matches a local resource error
  (`disk quota exceeded|no space left|out of diskspace|write error|quota exceeded`) prints
  `CHECK 2 BLOCKED (local-resource)` naming the disk and the fix. **The exit code stays 2** and the
  genuine network branch still prints `CHECK 2 BLOCKED (network)` verbatim — the A4 contract
  (`BLOCKED` ⇒ 2) is unchanged, this is a cause classification, not a new state.
- The cleanup trap covers **every** exit path (0/1/2) via `EXIT`, plus `INT`/`TERM`/`HUP`, so an
  interrupted gate cannot leave a clone behind to deepen the quota pressure that broke it.

## 3. Receipts — clean-tree PASS, and the control matrix

### 3.1 Clean-tree PASS (the seat's required receipt)

Run on the live tree at lane HEAD `88c3b2c`, unmodified subtree, `GATE_WORKDIR` on a roomy
filesystem:

```
$ GATE_WORKDIR=/home/vgpnk/.cache/r104-seat12/net bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "exit=$?"
GATE unreal-mcp subtree
SUBTREE=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/knowledge/unreal-mcp
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
WORK_ROOT=/home/vgpnk/.cache/r104-seat12/net (from GATE_WORKDIR)
WORK_ROOT_FREE=771G of 930G (16% used)
LANE_HEAD=88c3b2ca70fc83ec47a931d7b6dcff85a111c04e

MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
STEP=PASS

CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0
CLONE_TRACKED=12
PATH_EXTRA=0 PATH_MISSING=0
BLOB_DIFFS=0
STEP=PASS

CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
NAME_SET=OK NAME_BAD=0
STEP=PASS

POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS

GATE RESULT: PASS (checks failed: 0)
exit=0
```

All four checks PASS, rc=0, `UNRESOLVED=0`, at scanner sha256 `e5521304…`. This is the final
measurement on the frozen bytes; `POINTERS` settled at `103` (see §5).

### 3.2 Control matrix (W0–W7)

Every row was run against the installed script, sha256 `e5521304…`.

| control | setup | exit | observed signal |
|---|---|---|---|
| **W0** | none (default `/tmp`) | **0** | `WORK_ROOT=/tmp (from default)`; `GATE RESULT: PASS (checks failed: 0)` — the change is inert for existing callers |
| **W1** | `GATE_WORKDIR=<roomy dir>` | **0** | `WORK_ROOT=… (from GATE_WORKDIR)`; a 20 ms poller saw the scratch dir **created and removed**: `seen_paths=5 residual_after=0` |
| **W2** | `TMPDIR=<roomy dir>`, `GATE_WORKDIR` unset | **0** | `WORK_ROOT=… (from TMPDIR)`; `residual_after=0` |
| **W3** | `GATE_WORKDIR=<nonexistent>` | **1** | `FAIL scratch root is not a directory: …` + the fix hint, before any check |
| **W4** | `GATE_WORKDIR=<full tmpfs>` | **2** | `CHECK 2 BLOCKED (local-resource)`; `BLOCKED … this is a DISK failure, not an unreachable upstream`; rc still `2` |
| **W5** | dead proxy (`https_proxy=http://127.0.0.1:9`) + roomy `GATE_WORKDIR` | **2** | `CHECK 2 BLOCKED (network)` + `STEP=BLOCKED` — the A4 branch is unchanged verbatim |
| **W6** | `GATE_REF=<roomy clone at pin>` + roomy workdir | **0** | `GATE_REF=… (offline reference; no clone attempted)`; `BLOB_DIFFS=0`; `STEP=PASS` |
| **W7** | `kill -TERM` / `kill -INT` mid-run | 143 / 130 | signal traps ran `cleanup`; `residual_after=0` in both cases |
| **W8** | mutated copy (append a byte to `upstream/README.md`) | **1** | `MANIFEST_OK=11 EXPECTED=12 FAILED=1 RC=1`; `GATE RESULT: FAIL (checks failed: 4)`; `residual_scratch=0` — the FAIL path also cleans up |

W1/W2 verbatim:

```
$ GATE_WORKDIR=$W bash run_gate.sh; echo "GATE_WORKDIR rc=$?"
GATE_WORKDIR rc=0
seen_paths=5 residual_after=0
/home/vgpnk/.cache/r104-seat12/gw/tmp.BJB1T86652
/home/vgpnk/.cache/r104-seat12/gw/tmp.BJB1T86652/clone
/home/vgpnk/.cache/r104-seat12/gw/tmp.BJB1T86652/clone-files.txt
/home/vgpnk/.cache/r104-seat12/gw/tmp.BJB1T86652/clone.log
/home/vgpnk/.cache/r104-seat12/gw/tmp.BJB1T86652/vendored-files.txt

$ TMPDIR=$T bash run_gate.sh; echo "TMPDIR rc=$?"
WORK_ROOT=/home/vgpnk/.cache/r104-seat12/td (from TMPDIR)
GATE RESULT: PASS (checks failed: 0)
TMPDIR rc=0
residual_after=0
```

W4 verbatim — a 300 KB tmpfs, mounted in a private namespace (`unshare -rm`), used as the scratch
root. This is a **deterministic** reproduction of the r103 flake class, not a wait-and-hope:

```
$ unshare -rm bash quota-control.sh
=== size=300k rc=2 ===
WORK_ROOT=/tmp/seat12q-300k (from GATE_WORKDIR)
WORK_ROOT_FREE=300K of 300K (0% used)
CHECK 2 BLOCKED (local-resource)
BLOCKED fresh clone could not complete — scratch filesystem full or quota-exhausted
BLOCKED the network may be fine: this is a DISK failure, not an unreachable upstream
BLOCKED retry with GATE_WORKDIR (or TMPDIR) on a roomy filesystem — see gate/README.md
BLOCKED exit 2 is not a verdict: the vendored bytes are UNCHECKED, not divergent
fatal: sha1 file '/tmp/seat12q-300k/tmp.ZmhsAZisJr/clone/.git/index.lock' write error. Out of diskspace
warning: Clone succeeded, but checkout failed.
STEP=BLOCKED
GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)
=== size=700k rc=0 ===   GATE RESULT: PASS
=== size=2M rc=0 ===     GATE RESULT: PASS
```

The 700 KB and 2 MB rows are the **boundary controls**: they prove the small-filesystem condition is
what produces the BLOCKED row, not the harness — at 700 KB the same clone completes and the gate
passes. Note the cause line is present in the 300 KB row: that is the in-memory `C2_LOG` fix
working, since the on-disk log is unreadable on that filesystem.

W5 verbatim (the A4 contract preserved):

```
$ GATE_WORKDIR=<roomy> https_proxy=http://127.0.0.1:9 http_proxy=http://127.0.0.1:9 bash run_gate.sh; echo rc=$?
CHECK 2 clone-equivalence
CHECK 2 BLOCKED (network)
BLOCKED fresh clone could not complete — upstream unreachable, nothing compared
BLOCKED exit 2 is not a verdict: the vendored bytes are UNCHECKED, not divergent
fatal: unable to access 'https://github.com/…/': Failed to connect to github.com:443 over proxy 127.0.0.1 after 0 ms: Could not connect to server
STEP=BLOCKED
GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)
rc=2
```

## 4. Two caveats about the control runs, recorded not hidden

1. **A4a's historical form uses `REPO=<url> run_gate.sh`.** That no longer works: the script assigns
   `REPO=` internally, so a caller's environment override is silently discarded (r103b renamed the
   *check-4* root to `REPO_ROOT` for the reverse reason, but `REPO` itself is still a plain
   assignment). W5 therefore uses a dead proxy to reach the network branch. The A4 *behaviour* is
   verified; the A4 *attack spelling* in the r103 matrix is stale. Routed, not fixed here — changing
   `REPO` to `${REPO:-…}` is a one-line change with its own attack surface, and it is outside this
   seat's declared scope.
2. **W4's `WORK_ROOT_FREE` line reads `300K of 300K (0% used)`** — `df` on a freshly mounted tmpfs
   before the clone writes. It is the *root's* free space, printed at start-up, not the space
   remaining at failure. Read it as "this is a small filesystem", which is the signal it is for.

## 5. Pin update (`POINTERS` 101 → 102 → 103)

`POINTERS` is **scanner- and tree-relative**, and CHECK 4's pass B counts this README's own prose, so
editing the README moves the number the README pins. The r104 README additions ("Running under quota
pressure" + the r104 control matrix) added backtick-wrapped paths and the count walked up. The r103
`101` rows are left in place as the dated r103 measurements they are, with a dated continuation note
appended; the current pin is stated against the new scanner sha256 `e5521304…`. The binding
invariant — `UNRESOLVED=0` — never changed.

**Note on a self-catching FAIL.** During the pin update the gate correctly turned **red** on this
seat's own forward reference to `reports/round-104/gate/workdir.md` before this file existed:

```
POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=1
GATE RESULT: FAIL (checks failed: 1)
```

That is the pointer sweep doing its job (an unresolvable backtick path is a real defect). It is
recorded here because it is evidence the sweep is live, and it is the reason this file's creation is
itself a gate-satisfying step rather than a formality.

## 6. What this change does not do

- It does not make a full filesystem work. It makes the failure **legible and avoidable**.
- It does not change the default. A caller who sets neither variable on a quota-pressured host gets
  the old behaviour on purpose — silently relocating a close-out artifact's scratch is a surprise —
  but now gets a banner line naming the root and its free space.
- It does not renegotiate the exit codes: `0` PASS / `1` FAIL / `2` BLOCKED, unchanged.
- It makes **no** runtime claim. The editor is not installed; `unproven-runtime` stays
  `unproven-runtime`.
