# SEAT-17 GATE-DOCS-SYNC — does `gate/README.md` still match the installed gate?

**Seat:** SEAT-17 GATE-DOCS-SYNC · round 104 · lane `game-dev-3d-shokunin`
**Written:** 2026-10-18
**Artifact under test:** `corpus/knowledge/unreal-mcp/gate/README.md`
**Reference implementation:** `corpus/knowledge/unreal-mcp/gate/run_gate.sh`
**Ownership:** this seat writes **only** this file. `gate/README.md` and `gate/run_gate.sh` are **not**
mine; every finding below is a *flag*, not an edit.

**No Unreal runtime claim appears anywhere in this file.** Unreal Editor is not installed on this
host; the strongest statement available is that the vendored bytes are byte-identical to the pinned
upstream commit and that these static checks ran here. A green gate is static evidence only.

---

## 0. The target moved twice under this seat — read this before the verdict

Both files under test were being rewritten by **SEAT-12 GATE-WORKDIR-AUTHOR** throughout this
window. The README took **five** distinct shas and the script **four**:

| wall clock (local) | `run_gate.sh` | `README.md` | lines (README) | state |
|---|---|---|---|---|
| 16:16 (seat start) | `577c8b54…` | `834f468d…` | 356 | r103-settled: **no** workdir work |
| 16:21 | `abebee5c…` | `834f468d…` | 356 | C2 script landing begins |
| 16:22 | `15fc46d5…` | `834f468d…` | 356 | `WORK_ROOT` block present |
| 16:22 | `b6d8c61a…` | `834f468d…` | 356 | |
| 16:23 | `e5521304…` | `1ec70290…` | 432 | README gains "Running under quota pressure" |
| 16:24 | `e5521304…` | `f84a580e…` | 461 | r104 control matrix added |
| 16:25 → | **`e5521304…`** | **`e3bc66b7…`** | **461** | **settled; all claims below bound here** |

### 0.1 The snapshot this verdict is rendered against

```
$ date -Iseconds
2026-10-18T16:28:43-03:00
$ sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh corpus/knowledge/unreal-mcp/gate/README.md
e55213049db7538d2c126f02b7e6d91bfb38af77ff5f8b375b521b400d7b9c08  …/gate/run_gate.sh   (442 lines)
e3bc66b7f5d981a1128dc60ae910ec7c53dac85107c67802134e32bc7c0e98bf  …/gate/README.md     (461 lines)
```

Stability confirmed before measuring — three consecutive 25 s samples returned the identical pair:

```
t=25s R=e3bc66b7 S=e5521304
t=50s R=e3bc66b7 S=e5521304
t=75s R=e3bc66b7 S=e5521304
```

**Headline verdict: all four assigned criteria now PASS — but they passed only in the last minutes of
this seat, and they failed outright on the README that existed when the seat began.** At 16:16 the
README was the r103 file (`834f468d…`, 356 lines) which contained **zero** mentions of
`GATE_WORKDIR`, `TMPDIR`, or `WORK_ROOT`; the script it documented was the r103 scanner
(`577c8b54…`). Criterion 1, 3 and 4 were all false against that pair. SEAT-12 landed C2 in the
script at 16:21–16:23 and rewrote the README at 16:23–16:25, and **the criteria are satisfied by
that rewrite, not by any work of this seat.** This file is a *post-landing audit*, and its value is
the residual-drift list in §2, which survives the rewrite.

---

## 1. The four assigned criteria — verified behaviourally at `e5521304…` / `e3bc66b7…`

### 1.1 "GATE_WORKDIR + TMPDIR documented" — **YES**

Documented in a dedicated section, with the precedence rule, the host root cause, the remediation
command, and two recorded limits.

```
$ grep -c 'GATE_WORKDIR' corpus/knowledge/unreal-mcp/gate/README.md   → 11
$ grep -c 'TMPDIR'       corpus/knowledge/unreal-mcp/gate/README.md   →  5
$ sed -n '62,67p' corpus/knowledge/unreal-mcp/gate/README.md
## Running under quota pressure

Both of this gate's scratch sites — the manifest log and CHECK 2's clone workdir — live under

WORK_ROOT=${GATE_WORKDIR:-${TMPDIR:-/tmp}}
```

The documented precedence is **behaviourally correct**, verified three ways against the installed
script (roomy scratch on real disk, `$HOME/.r104-seat17/…`):

```
$ GATE_WORKDIR=<roomy dir> bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
WORK_ROOT=/home/vgpnk/.r104-seat17/gw (from GATE_WORKDIR)
WORK_ROOT_FREE=769G of 930G (16% used)
GATE RESULT: PASS (checks failed: 0)          RC=0

$ TMPDIR=<roomy dir> bash corpus/knowledge/unreal-mcp/gate/run_gate.sh      # GATE_WORKDIR unset
WORK_ROOT=/home/vgpnk/.r104-seat17/tmp (from TMPDIR)
GATE RESULT: PASS (checks failed: 0)          RC=0

$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh                        # neither set
WORK_ROOT=/tmp (from default)
WORK_ROOT_FREE=3.1G of 16G (80% used)
```

The up-front validation the README describes is also real — a bad root is a named `FAIL` before any
check runs, exactly as documented at `README.md:106`:

```
$ GATE_WORKDIR=/nonexistent/xyz bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "RC=$?"
FAIL scratch root is not a directory: /nonexistent/xyz
     set GATE_WORKDIR (or TMPDIR) to an existing writable directory
RC=1

$ GATE_WORKDIR=<chmod 555 dir> bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
FAIL scratch root is not writable: /home/vgpnk/.r104-seat17/ro
RC=1
```

The README's `local-resource` classification (§`README.md:110–122`) is likewise real: on this host
with the default `/tmp` root the gate now names the disk cause instead of blaming the network —

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh     # default /tmp, quota-pressured
CHECK 2 BLOCKED (local-resource)
BLOCKED fresh clone could not complete — scratch filesystem full or quota-exhausted
BLOCKED the network may be fine: this is a DISK failure, not an unreachable upstream
error: copy-fd: write returned: Disk quota exceeded
GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)          RC=2
```

— which is a **live reproduction of the r103 defect**, and the README's quoted remediation text
matches the script's `printf` strings verbatim (`run_gate.sh:268–271`).

### 1.2 "Exit codes 0/1/2 declared" — **YES**

```
$ sed -n '286,296p' corpus/knowledge/unreal-mcp/gate/README.md
## Exit codes

Exit codes are strict and fail-closed, with a declared third state for a check that **could not
run**:

- **`0`** — every check printed `STEP=PASS`. Clean.
- **`1`** — at least one check printed `STEP=FAIL`. …
- **`2`** — CHECK 2 printed `STEP=BLOCKED` (the fresh clone could not complete) and no other check
  failed. This is **not** a pass and **not** a verdict: the vendored bytes are *unchecked*, not
  divergent. …
```

All three states were exercised on the settled script:

| state | command | observed |
|---|---|---|
| `0` | `GATE_WORKDIR=<roomy> run_gate.sh` | `GATE RESULT: PASS (checks failed: 0)`, rc 0 |
| `1` | flip one vendored byte on a copy | `MANIFEST_OK=11 … FAILED=1`; `BLOB-DIFF README.md`; rc 1 |
| `2` | `REPO=<dead url>`, no `GATE_REF` | `CHECK 2 BLOCKED (network)`; `STEP=BLOCKED`; `GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)`; rc 2 |

The documented residual is also still true and was re-confirmed: when CHECK 2 is BLOCKED **and**
another check fails, the third state is lost —

```
$ # dead GATE_REF + a planted out-of-range pointer on a copy
STEP=PASS / STEP=PASS / STEP=PASS / STEP=FAIL
GATE RESULT: FAIL (checks failed: 1)          RC=1
```

`README.md:297–301` records exactly this, so the declaration is honest about it.

### 1.3 "Hardening history appended (r104 entry)" — **YES**

```
$ grep -n 'r104 (2026-10-18, SEAT-12' corpus/knowledge/unreal-mcp/gate/README.md
55:> **r104 (2026-10-18, SEAT-12 GATE-WORKDIR-AUTHOR).** The r103 close window left two unexplained
```

The entry names the seat, cites `reports/round-103/gate/close-runs.md` as the source, states the
root-cause class, and points at the new section. A second r104 block — the W0–W7 control matrix —
is present at `README.md:369–384`. The r102/r103/r103b entries are retained unchanged.

### 1.4 "Expected POINTERS value current" — **YES, and independently reproduced**

The README pins `POINTERS=103` against scanner `e5521304…` at `README.md:42, 248, 271, 283, 377`
and in the pinned-summary block at `:271`. The installed gate prints the same value, and it is
**stable across three runs**:

```
$ GATE_WORKDIR=<roomy> bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
GATE RESULT: PASS (checks failed: 0)          RC=0
```

The README's decomposition (pass A = 47 endpoints, pass B = 56) was **independently re-derived**
from the sweep regexes rather than copied, and it agrees exactly:

```
$ bash $HOME/.r104-seat17/decompose.sh
pass A endpoints = 47
pass B paths = 56
sum = 103
```

The full pinned summary block matches the gate line for line:

```
$ grep -E '^(MANIFEST_OK|CLONE_HEAD|CLONE_DIRTY|CLONE_TRACKED|PATH_EXTRA|CARDS|CENSUS|NAME_SET|POINTERS|GATE RESULT)' <final run>
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0
CLONE_TRACKED=12
PATH_EXTRA=0 PATH_MISSING=0
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
NAME_SET=OK NAME_BAD=0
POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)
```

Two other pins in the block were re-measured and are current: `adaptation-kimi.md` sha256
`084a34cd…` matches on disk, and `MANIFEST_FILES=12` is what the gate prints.

**One caveat that is *not* drift.** `README.md:40, 397` still cite the retired scanner sha
`577c8b54…`, and `:357, 401` still show `POINTERS=101`. These are **deliberate dated rows**: the
README's own "Pin continuation" note (`:435–441`) states the `101` rows are left as the r103
measurements they were, and the current pin is `103` at `e5521304…`. A reader who lands on `:397`
alone could still be misled, but the file explains itself in the next block. Flagged as a
**readability** item, not a false claim.

---

## 2. Residual drift still open (flags for the README owner; not applied here)

These survived the SEAT-12 rewrite. Each is a *claim about the README*, verified by a command.

| # | README claim | location | actual | evidence |
|---|---|---|---|---|
| **D1** | "the **12-attack** suite" | `:31` | the r102 record says **11/11** | `reports/round-102/r102-report.md:429` "**11/11 attacks DETECTED**, zero false-passes"; commit `c6f655d` subject "11/11 attacks detected". Same round's own documents disagree. |
| **D2** | "C1–C6, plus C7 where listed) must **each turn the gate red**" | `:307` | C7 must stay **green** | C7's own row (`:344`) reads exit **0**, "stays green". The sentence contradicts the matrix three lines below it. |
| **D3** | C7 pinned `SKIPPED_CONTROL_SENTINELS=2` | `:344` | `2` only if **two of the three** documented sentinels are planted | `:229` documents **three** sentinels. Measured: all three → `SKIPPED_CONTROL_SENTINELS=3`; the two `upstream/README.md` ones → `2`. The row is under-specified, not strictly wrong. |
| **D4** | The README documents **four checks**; CHECK 1 is described as one `sha256sum -c` | `:142–147` | the script can fail a run from **10** increment sites — 4 in-check plus 6 pre-check guards | `grep -c 'FAILS=$((FAILS+1))' run_gate.sh` → **10**. `grep -c` for `MANIFEST_FILES`, `non-regular`, `nested entry`, `non-markdown` in the README → **0** each. The pinned-tree guards (symlink rejection, the per-seat `--strict` sweep, CRLF rejection, nested-entry rejection, non-markdown rejection) are undocumented. |

**D4 is the most substantive.** A reader trusting the README would not know the manifest set is
pinned, the pinned trees are symlink-free, or that CRLF is rejected — and a red gate from any of
those guards would look unexplained. This is the same class r103's `docs-sync.md` raised as its
item 5.5; it was not closed by the C2 rewrite.

**D3 evidence** (lane-shaped copies so CHECK 4's pass B resolves; no writes to the pinned tree):

```
$ # plant all three documented sentinels
SKIPPED_CONTROL_SENTINELS=3 UNRESOLVED=0        GATE RESULT: PASS

$ # plant only upstream/README.md:9999 and :500
SKIPPED_CONTROL_SENTINELS=2 UNRESOLVED=0        GATE RESULT: PASS

$ # direct regex test of all three documented forms against the script's SENTINEL
upstream/nope.md:5           MATCH
upstream/README.md:9999      MATCH
upstream/README.md:500       MATCH
```

The sentinel *filter* is correct — it skips exactly those three strings and nothing else. Only the
README's pin of `2` for "the exact sentinels" is ambiguous about which subset it means.

### 2.1 Checked and found **correct** (so the absence of a flag is meaningful)

- `MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0`, `CLONE_HEAD` = pin, `CLONE_DIRTY=0`,
  `CLONE_TRACKED=12`, `PATH_EXTRA=0 PATH_MISSING=0 BLOB_DIFFS=0`, `CARDS=13 EXPECTED=13 BAD=0`,
  `CENSUS 12/1/0`, `NAME_SET=OK NAME_BAD=0` — all re-measured, all match.
- `PINNED_CARD_NAMES` in the README (`:205–208`) matches the script's constant (`:84`) exactly.
- The `upstream` pin `a6aa73ad…` and `tracked upstream files = 12` match.
- C1 control on a copy reproduces the documented signal: `MANIFEST_OK=11 … FAILED=1`,
  `BLOB-DIFF README.md`, rc 1.
- A4a on a copy reproduces the documented signal verbatim: `CHECK 2 BLOCKED (network)` /
  `STEP=BLOCKED` / `GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)` / rc 2.
- cwd-independence (`:389–390`) still holds: the gate run from `/tmp` printed the same
  `GATE RESULT: PASS (checks failed: 0)`.
- `reports/round-104/gate/workdir.md` — cited at `:373` and `:441` — **exists** as of 16:25.
  During this seat's window it was cited for ~90 s before it existed, and the gate's own CHECK 4
  **FAILed the real tree** with `MISSING-PATH-REL reports/round-104/gate/workdir.md`,
  `UNRESOLVED=1`, rc 1. It self-resolved when the file landed; recorded because it shows the
  README's pointer sweep can red the gate on a mid-round README edit.

---

## 3. The seat's own audit was blocked mid-flight, and that is the finding

For roughly seven minutes this seat could not produce a stable verdict, because both files under
test were being rewritten. Two concrete consequences worth routing:

1. **A verdict rendered against a moving target is worthless.** My first draft measured
   `577c8b54…`/`834f468d…` and would have reported all four criteria failing. That was true at
   16:16 and false by 16:25 — same seat, same commands, opposite verdicts. The r103 `docs-sync.md`
   hit the identical problem (eight script shas, two finding flips); it is now a **recurring**
   pattern, not a one-off.
2. **The README's own pointer sweep can red the gate.** While `README.md` cited
   `reports/round-104/gate/workdir.md` before that file existed, CHECK 4 resolved the path, found
   nothing, and exited 1 — a **false red on a byte-clean tree**, produced entirely by README prose.
   Pass B counts the README's own backtick paths (documented at `:236–245`), so any round that
   edits this README can transiently red its own gate. The mitigation is ordering: land the cited
   receipt before (or with) the citation.

Neither is a defect in the C2 change; both are properties of auditing a file that other seats are
still writing. A future docs-sync seat should **wait for the artifact to settle** (hash twice, N
seconds apart) before rendering any verdict — which is what this seat ended up doing.

---

## 4. What the parent should do

1. **Accept criteria 1–4 as met at the settled snapshot** (`run_gate.sh` `e5521304…`, `README.md`
   `e3bc66b7…`) — with the explicit note that SEAT-12's rewrite satisfied them, not this seat.
2. **Route D1–D4 to whoever owns `gate/README.md` next.** D1 and D2 are one-line corrections;
   D3 is a wording fix; D4 is a short paragraph documenting the pre-check guards.
3. **Do not re-open the C2 change.** Every documented behaviour of the workdir fix was
   independently reproduced here and matches, including the `local-resource` classification and
   the up-front root validation.
4. **Consider a one-line "do not audit this file mid-round" note** in the README, or a settled-hash
   convention, given §3 recurs across rounds.

## 5. Reproduce

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
S=corpus/knowledge/unreal-mcp/gate/run_gate.sh
R=corpus/knowledge/unreal-mcp/gate/README.md
GW=/tmp/seat17-gw; mkdir -p "$GW"          # any roomy dir on real disk

# §0.1 — the settled snapshot
sha256sum "$S" "$R"; wc -l "$S" "$R"

# §1.1 — GATE_WORKDIR / TMPDIR documented and honoured
grep -c GATE_WORKDIR "$R"                  # 11
grep -c TMPDIR       "$R"                  #  5
GATE_WORKDIR="$GW" bash "$S" | grep WORK_ROOT          # (from GATE_WORKDIR)
TMPDIR="$GW"       bash "$S" | grep WORK_ROOT          # (from TMPDIR)
bash "$S"          | grep WORK_ROOT                    # (from default)
GATE_WORKDIR=/nonexistent/xyz bash "$S"; echo "RC=$?"  # named FAIL, RC=1

# §1.2 — exit codes 0/1/2
sed -n '286,296p' "$R"
#   rc 2: copy the subtree, REPO=https://127.0.0.1:1/nope.git, run the copy
#   rc 1: flip a byte in a copy's upstream/README.md
#   rc 0: GATE_WORKDIR="$GW" bash "$S"

# §1.3 — r104 history entry
grep -n 'r104 (2026-10-18, SEAT-12' "$R"

# §1.4 — the pin is current, and its decomposition is right
GATE_WORKDIR="$GW" bash "$S" | grep POINTERS           # 103
bash $HOME/.r104-seat17/decompose.sh                   # 47 + 56 = 103

# §2 — residual drift
sed -n '31p;307p;344p' "$R"                # D1, D2, D3
grep -c MANIFEST_FILES "$R"                # D4: 0
grep -c 'FAILS=$((FAILS+1))' "$S"          # D4: 10 increment sites
```
