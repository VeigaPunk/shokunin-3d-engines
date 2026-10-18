# SEAT-16 HARDENING-SENTINEL — audit of the r103 gate hardening diff

**Seat:** SEAT-16 HARDENING-SENTINEL · round 103 · lane `game-dev-3d-shokunin`
**Owned path:** this file only (`reports/round-103/gate/sentinel.md`). No other file was written by
this seat. `gate/run_gate.sh` and `gate/README.md` are **read-only here**; every finding is a flag,
not an edit.
**Date:** 2026-10-18 · **Lane HEAD:** `c85a816e227984272a3c29b58aa7f7c1a76f1e9c`
**Artifact under audit:** `corpus/knowledge/unreal-mcp/gate/run_gate.sh` — the r102→r103 hardening diff.

**No Unreal runtime claim appears anywhere in this file.** The editor is not installed on this host;
live-MCP behaviour is unproven by construction. Every claim below is a *static* claim about a shell
script plus the output of commands actually run on this host.

**Question assigned:** audit the hardening diff — (1) no new network surface, (2) no writes outside
`gate/`, (3) fail-closed only, (4) no new bare PATH-shadowable tools without guards, (5) exit-code
vocabulary declared in README. Evidence per line range.

---

## 0. Headline

| sub-question | verdict |
|---|---|
| 1. No new network surface | **PASS** — one `git clone` to the pinned URL, unchanged from r102; `GATE_REF` only *removes* network use (§3) |
| 2. No writes outside `gate/` | **PASS at the frozen revision** — the r102 hardcoded `/tmp/advgate/.h1` write is gone; the only absolute write is `/dev/null`, all scratch is `mktemp` + `trap … EXIT` (§4) |
| 3. Fail-closed only | **PARTIAL** — no new false-PASS path was introduced, but two r102 false-PASS classes survive *unchanged* (A7 shadowed `sha256sum`, A8 failing `comm`), plus a new *vacuous pass* inside check 4 under a shadowed `grep` (§5, §6) |
| 4. No new bare PATH-shadowable tools without guards | **FAIL** — the r103 guard still covers only `git sha256sum grep find sort comm`; `sed cut wc tr timeout mktemp basename rm` are unguarded, and `cut` is on the check-2 blob path (§6.4) |
| 5. Exit-code vocabulary declared in README | **FAIL at the audited revision → FIXED at `efc1e618…`** — the audited revision implemented `0/1/2` while README declared only `0`/`1`; a `## Exit codes` section declaring all three landed afterwards (§7, §10) |

**One structural caveat governs everything below.** The gate was rewritten by other seats **seven
times** during this audit. Claims here are bound to a named revision (§1), and §10 records the
post-audit drift that changes two rows of this table.

---

## 1. The artifact moved continuously — every claim names its revision

```
$ sha256sum <each snapshot>            # SEAT-16, /tmp/s16-adv/
412d1b84857233e8…  gate-r102-committed.sh   # r102, == git show c6f655d:…/gate/run_gate.sh
9ea943dc…(md5)     snap-run_gate.sh          # 15:35:16  A4 landed, hardcoded /tmp path removed
abc0ddde1ef63eff…  FROZEN.sh                 # 15:36:43  A2 anchored label rule + A3 PINNED_CARD_NAMES
0c1ca3e1a5606243…  FROZEN2.sh                # 15:37:19  EXIT_CODE=0 removed; == live at write time
```

**The revision this audit is rendered against** is the r103 working-tree revision
`sha256 0c1ca3e1a5606243b45e2c1d4d4ce54d1faea9dcea79048e3c646feca6ab545e`
(md5 `c81802c59e4ce349a91f86eb5f76b063`), which I froze to `/tmp/s16-adv/FROZEN2.sh` and which is
still byte-identical to the live file at the time of writing:

```
$ md5sum corpus/knowledge/unreal-mcp/gate/run_gate.sh
c81802c59e4ce349a91f86eb5f76b063  corpus/knowledge/unreal-mcp/gate/run_gate.sh
$ diff -q corpus/knowledge/unreal-mcp/gate/run_gate.sh /tmp/s16-adv/FROZEN2.sh && echo UNCHANGED
UNCHANGED
$ git status --porcelain corpus/knowledge/unreal-mcp/gate/
 M corpus/knowledge/unreal-mcp/gate/README.md
 M corpus/knowledge/unreal-mcp/gate/run_gate.sh
```

The r102→r103 diff spans eight hunks (`diff -u gate-r102-committed.sh FROZEN2.sh | grep '^@@'`):
`@@ -35` (A3 constant), `@@ -62` (`/tmp/advgate` → `mktemp`), `@@ -103` (A4 + `GATE_REF`),
`@@ -136` (A4 block), `@@ -166` (A4 tail), `@@ -184` (A2 label rule), `@@ -206` (A3 name set),
`@@ -240` (A1 endpoint loop).

**Every line number in this file was read from the bytes named, not from `reports/round-102/fold-spec.md`.**
The fold-spec's own §8 warns the tree was mutating under concurrent seats; that warning applies to the
gate itself, and any r103 close-out claim about this gate must name the sha it was measured on.

---

## 2. Method, and the two environment traps I had to defuse

The audit needed a **green baseline** so that a red result isolates the hardening rather than sibling
churn. Two traps made that harder than expected; both are themselves findings.

**Trap 1 — `/tmp` is a shared, per-user-quota tmpfs that is currently exhausted.**

```
$ df -h /tmp
tmpfs  16G  13G  3.1G  80% /tmp
$ du -sh /tmp/* | sort -rh | head -3
1.6G /tmp/arc2-l3r3-C1-inst
885M /tmp/seat44-a4b
736M /tmp/advgate
```

The gate creates its scratch with `mktemp` (`:73` `MANLOG=$(mktemp)`, `:85` `WORK=$(mktemp -d)`),
so **every run of this gate depends on `/tmp` having space**. With `/tmp` exhausted:

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
CHECK 2 clone-equivalence
CHECK 2 BLOCKED (network)
BLOCKED fresh clone could not complete — upstream unreachable, nothing compared
STEP=BLOCKED
GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)     exit=2
$ git clone --quiet <pinned REPO> /tmp/s16-adv/ctest
error: copy-fd: write returned: Disk quota exceeded
fatal: cannot copy '…/templates/description' to '…/ctest/.git/description': Disk quota exceeded
```

The network was **fine**; the *disk* was full, and the gate blamed the network. This is a
**mislabelled third state** and it is a finding in its own right (§7.3). All measurements below
were taken with `TMPDIR=/home/vgpnk/.cache/s16tmp` (a real filesystem, `774G` free) so that check 2
could actually complete:

```
$ TMPDIR=… bash <replica>/gate/run_gate.sh
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
STEP=PASS
POINTERS=98 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)                                exit=0
```

**Trap 2 — `cp -a` of the whole lane exceeds the same quota.** The first replica attempt died with
`Disk quota exceeded` partway through (2.9 MB of error output). The working replica is therefore
**layout-faithful but minimal**: the subtree, plus stub files for every repo-relative path the
gate's check-4 sweep B resolves. Verified green before any mutation:

```
BASE_EXIT=0
STEP=PASS ×4
POINTERS=98 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)
```

**Controls are mandatory and were always run.** A mutation result is only reported below together
with the *unmutated* run of the same replica, because a replica that is red for its own reasons
would make every mutation look "detected".

---

## 3. Sub-question 1 — network surface: PASS, no new surface

The complete network-relevant surface of the frozen revision:

```
$ grep -nE 'curl|wget|nc |ssh|scp|socat|git (clone|fetch|pull|ls-remote)|https?://' FROZEN2.sh
31:REPO=https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
146:    timeout 180 git clone --quiet "$REPO" "$CLONE" >"$WORK/clone.log" 2>&1
```

Two hits, both present in the r102 revision as well (r102 `:31` `REPO=…`, `:114` `timeout 180 git
clone`). No `curl`, no `wget`, no raw socket tool, no second URL. `strace` confirms exactly one
outbound TCP connection to the pinned host, plus DNS:

```
$ strace -f -e trace=connect,socket -o st2.txt bash <replica>/gate/run_gate.sh
$ grep -E 'connect\(' st2.txt | grep -oE 'sin_port=htons\([0-9]+\), sin_addr=inet_addr\("[0-9.]+"\)' | sort -u
sin_port=htons(443), sin_addr=inet_addr("4.228.31.150")     # github.com
sin_port=htons(53),  sin_addr=inet_addr("127.0.0.53")       # resolver
```

The r103 additions **reduce** network dependence rather than add to it: `GATE_REF` (`:130`) makes
check 2 read a caller-supplied clone and skip the `git clone` entirely, which I verified:

```
$ GATE_REF=/tmp/s16-adv/refclone bash <replica>/gate/run_gate.sh   # REPO= set to a bogus host
GATE_REF=/tmp/s16-adv/refclone (offline reference; no clone attempted)
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
STEP=PASS
```

**Verdict: PASS.** One pre-existing clone to the pinned URL; no new network surface; the new
`GATE_REF` path is strictly offline.

---

## 4. Sub-question 2 — writes outside `gate/`: PASS at the frozen revision (was FAIL in r102)

### 4.1 The r102 defect, and its fix

The r102 revision wrote a **hardcoded absolute path** into a directory it does not own:

```
$ grep -n '/tmp/advgate' gate-r102-committed.sh
65:if ! (cd "$SUB" && sha256sum --strict -c .manifest.d/*.sha256 >/tmp/advgate/.h1 2>&1); then
67:  sed 's/^/  /' /tmp/advgate/.h1
```

I reproduced the consequence on a clean tree with `/tmp/advgate` absent — the gate went **red for a
reason that has nothing to do with the subtree**:

```
$ unshare -rm bash -c 'mount -t tmpfs tmpfs /tmp && bash <repo>/…/run_gate.sh'
corpus/knowledge/unreal-mcp/gate/run_gate.sh: line 65: /tmp/advgate/.h1: No such file or directory
FAIL per-seat manifest sweep (--strict) failed:
sed: can't read /tmp/advgate/.h1: No such file or directory
STEP=FAIL
GATE RESULT: FAIL (checks failed: 2)          exit=1
```

The frozen revision replaces it with `mktemp` (`:73 MANLOG=$(mktemp)`, `:79 rm -f "$MANLOG"`), and
`grep -n '/tmp/advgate' FROZEN2.sh` now returns only a comment explaining the removal. **Fixed.**

### 4.2 The write surface at the frozen revision, by syscall

```
$ strace -f -qq -e trace=openat,creat,unlink,rename,mkdir,rmdir -o st2.txt bash <replica>/gate/run_gate.sh
$ grep -E 'O_CREAT|O_WRONLY|unlink|rename|mkdir|rmdir' st2.txt | grep -v ENOENT \
    | grep -oE '"/[^"]*"' | sort -u
"/dev/null"
```

**The only absolute path the gate writes is `/dev/null`.** Every other write is either relative to
the fresh clone inside the `mktemp` scratch tree, or the scratch files themselves. Scratch is
reclaimed by the trap, verified by counting the scratch directory before and after:

```
$ grep -n 'mktemp\|trap\|cleanup' FROZEN2.sh
73:MANLOG=$(mktemp)
85:WORK=$(mktemp -d)
86:cleanup() { rm -rf "$WORK"; }
87:trap cleanup EXIT
$ ls -A $TMPDIR | wc -l ; bash <replica>/gate/run_gate.sh >/dev/null; ls -A $TMPDIR | wc -l
1
1                       # no leftover scratch
```

### 4.3 The repo is not mutated

```
$ git status --porcelain > gs1.txt
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh >/dev/null 2>&1
$ git status --porcelain > gs2.txt
$ diff gs1.txt gs2.txt && echo IDENTICAL
IDENTICAL: gate run mutates no tracked/untracked repo state
$ find .git -newermt '-2 minutes' -type f | head
(no output)
```

**Verdict: PASS.** The one real "writes outside `gate/`" defect of r102 is closed, and the residual
write surface is `/dev/null` plus `mktemp` scratch that the trap removes. **Residual note:** the
gate still *requires* a writable `TMPDIR` (Trap 1, §2) — a host with no writable temp directory gets
a fail-closed red rather than a graceful skip. That is fail-*closed*, so it is acceptable, but it is
not the same as "self-contained".

---

## 5. Sub-question 3 — fail-closed only

### 5.1 The r102→r103 attack battery, run against the frozen revision

Eleven attacks, each on a fresh copy of the green replica. `run_gate.sh` is the installed file.

| # | attack | expected | observed | verdict |
|---|---|---|---|---|
| H2 | symlink planted in `upstream/` | red | `FAIL non-regular file in pinned tree` | **detected** |
| H3 | 14th card as a symlink | red | `FAIL non-regular file in pinned tree` | **detected** |
| H4 | 14th card in a subdir | red | `FAIL nested entry under executability/` | **detected** |
| H1 | `NOT-static-only` label | red | `FAIL no-label` (the anchored rule no longer matches it) | **detected** |
| H1b | `static-onlyness` label | red | `FAIL multi-label` | **detected** |
| H5 | dangling `executability/ghost.md:12` | red | check 4 `STEP=FAIL` | **detected** |
| H6 | pointer with a space in the path | red | check 4 `STEP=FAIL` | **detected** |
| H22 | seat manifests emptied | red | `FAIL per-seat manifest sweep (--strict) failed` | **detected** |
| H14 | CRLF in `audit-reference.sha256` | red | `FAIL CR byte in manifest` | **detected** |
| H21 | pointer `upstream/README.md:0` | red | check 4 `STEP=FAIL` | **detected** |
| H20 | uppercase `NOTES.MD` with an OOR pointer | red | `LINE-OOR … (max 112)` | **detected** |

**11/11 detected**, reproducing the r102 close-out claim on the r103 revision.

### 5.2 The r103 fold-spec queue A1–A8, re-run against the frozen revision

| item | mutation | frozen-revision result |
|---|---|---|
| A1 | plant `upstream/README.md:1-9999` (multi-endpoint tail) | **fixed** — `UNRESOLVED=1`, `GATE RESULT: FAIL` |
| A2 | prose sentence naming a token above the declaration | **fixed** — `BAD=0`, `GATE RESULT: PASS` (hijack no longer fires) |
| A3 | rename `sequencer.md` → `sequence-typo.md` | **fixed** — `NAME_SET=BAD NAME_BAD=2`, `GATE RESULT: FAIL` |
| A4 | unreachable `REPO`, no `GATE_REF` | **fixed** — `STEP=BLOCKED`, `GATE RESULT: BLOCKED`, `exit=2` |
| A5 | corrupt `seat02.sha256` with a zero digest | **fixed** — `FAIL per-seat manifest sweep` |
| A6 | plant `upstream/LICENSE:99999` (extensionless) | **STILL GREEN** — `UNRESOLVED=0`, `exit=0` |
| A7 | shadowed `sha256sum` + one flipped byte | **STILL GREEN** — `exit=0`, `GATE RESULT: PASS` |
| A8 | failing `comm` + stray `upstream/STRAY.md` | **STILL GREEN** — `exit=0`, `GATE RESULT: PASS` |

A1's fix is worth quoting, because it is the exact regex-plus-loop the fold-spec asked for:

```
$ sed -n '296,312p' FROZEN2.sh
    for ln in $(printf '%s' "$rest" | tr ',-' '  '); do
      P_TOTAL=$((P_TOTAL+1))
      [ "$ln" -lt 1 ] && { printf 'LINE-ZERO %s :: %s\n' "$f" "$ptr"; … }
      [ "$ln" -gt "$n" ] && { printf 'LINE-OOR %s :: %s (max %s)\n' "$f" "$ptr" "$n"; … }
    done
  done < <(grep -ohE "upstream/[^\`\"|)]+\.[A-Za-z0-9]+:[0-9]+([,-][0-9]+)*" "$f" | sort -u)
```

A1 is genuinely closed, and `POINTERS` now counts endpoints (`98`) rather than strings (`41`), which
is why the r103 revision prints a larger `POINTERS` than the r102 `87`.

**Verdict: PARTIAL.** No *new* false-PASS path was introduced by the hardening, and six of eight
queued items are genuinely closed. But A6/A7/A8 are **unchanged false-PASS classes** — see §6.

---

## 6. Sub-question 4 — bare PATH-shadowable tools: FAIL

### 6.1 What the guard covers

```
$ sed -n '26,28p' FROZEN2.sh
for _t in git sha256sum grep find sort comm; do
  if ! command -v "$_t" >/dev/null 2>&1; then printf 'FAIL required tool missing: %s\n' "$_t"; exit 1; fi
done
```

Six tools are checked **for presence**. Note what this guard does and does not do: it does **not**
verify that the resolved tool *is* the system one, so a shadowing stub on `PATH` passes the guard
trivially. The check is a presence check, not an integrity check.

### 6.2 A7 — shadowed `sha256sum` is still a full false green **[highest severity, unchanged]**

A stub `sha256sum` that replays the twelve expected `OK` lines in `-c` mode and exits 0, placed
ahead of the real one, against a tree with **one flipped byte**:

```
$ PATH=/tmp/s16-adv/sh2:$PATH bash hwA/…/gate/run_gate.sh ; echo exit=$?
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
BLOB_DIFFS=0
GATE RESULT: PASS (checks failed: 0)
exit=0

# control — same tree, same mutation, real PATH:
$ bash hwB/…/gate/run_gate.sh
MANIFEST_OK=11 EXPECTED=12 FAILED=1 RC=1
BLOB_DIFFS=1
GATE RESULT: FAIL (checks failed: 3)
```

The tampered tree returns **exit 0** with a transcript byte-for-byte identical to a clean run,
*asserting* the exact `MANIFEST_OK=12 … BLOB_DIFFS=0` values `gate/README.md:138-142` tells a verifier to
expect. Both sides of the check-2 blob compare use the unqualified tool (`:168`, `:169`), so the
stub also makes `a == b` trivially (empty vs empty). This is fold-spec A7, unfixed.

### 6.3 A8 — failing `comm` is still a full false green **[unchanged]**

A `comm` shim that exits 127, against a tree carrying a stray `upstream/STRAY.md`:

```
$ PATH=/tmp/s16-adv/bc:$PATH bash hwC/…/gate/run_gate.sh ; echo exit=$?
PATH_EXTRA=0 PATH_MISSING=0
BLOB_DIFFS=0
GATE RESULT: PASS (checks failed: 0)
exit=0

# control — same stray file, real PATH:
$ bash hwD/…/gate/run_gate.sh
PATH_EXTRA=1 PATH_MISSING=0
GATE RESULT: FAIL (checks failed: 1)
```

Both `comm` substitutions (`:160`, `:161`) yield the empty string when `comm` fails, so `wc -l` reads
`0` and the gate prints `PATH_EXTRA=0 PATH_MISSING=0` as if the sets matched. The presence guard does
not help: the shim *is* present. Fold-spec A8, unfixed.

### 6.4 `cut` is unguarded and sits on the check-2 blob path — the compounding false pass

```
$ grep -n 'cut' FROZEN2.sh
168:      a=$(sha256sum "$SUB/upstream/$f" | cut -d' ' -f1)
169:      b=$(git -C "$CLONE" show "$PIN:$f" | sha256sum | cut -d' ' -f1)
```

`cut` is **not** in the guard list. A `cut` stub that exits 0 with no output makes `a` and `b` both
empty for every file, so `BLOB_DIFFS=0` regardless of the bytes. Combined with a tampered tree this
is a second, independent full false green on the same check, reachable without touching `sha256sum`.

### 6.5 A new *vacuous pass*: shadowed `grep` makes check 4 print `UNRESOLVED=0`

This one is **not in the fold-spec queue** and I found it while running the shadow matrix. A `grep`
stub that exits 0 with no output, against a tree with a planted out-of-range pointer:

```
$ PATH=/tmp/s16-adv/shg:$PATH bash hwG2/…/gate/run_gate.sh ; echo exit=$?
MANIFEST_OK= EXPECTED=12 FAILED= RC=0
…/run_gate.sh: line 103: [: : integer expected
STEP=FAIL
…
CARDS= EXPECTED=13 BAD=13
…/run_gate.sh: line 257: [: : integer expected
STEP=FAIL

CHECK 4 pointer-sweep
POINTERS=0 POINTER_STRINGS=0 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
GATE RESULT: FAIL (checks failed: 2)
exit=1
```

The run is red overall — but **check 4 reports `UNRESOLVED=0 STEP=PASS` having examined nothing**
(`POINTERS=0`). A reader who greps the transcript for the binding invariant, which is exactly what
`gate/README.md:129` tells them to do, sees a green pointer check. This is a *false pass nested
inside a failing run*: less dangerous than A7/A8, because the aggregate is red, but it defeats the
documented per-check reading and it is the same shadowing class.

For completeness, shadowed `sed` degrades the count without turning anything green
(`POINTERS=48` instead of `98`), which is why the count must never be read as a contract.

### 6.6 The unguarded-tool list

```
$ grep -oE '(\$\(|\|\||&&|;|\|)[[:space:]]*[a-z][a-z0-9_-]*|^[[:space:]]*[a-z][a-z0-9_-]*' FROZEN2.sh \
    | sed 's/^[[:space:]]*//; s/^[$|&;]*[[:space:]]*//' | sort -u
```

Filtering that to real commands: **guarded** = `git sha256sum grep find sort comm` (`:26`).
**Unguarded** = `basename cut dirname head ln mktemp printf pwd rm sed timeout tr trap wc` — of
which the load-bearing ones on a scoring path are `cut` (`:168`, `:169`, blob compare), `sed`
(`:159`, vendored path list), `wc` (`:67`, `:153`, `:160`, `:161`, `:299`), `tr` (`:306`, endpoint split)
and `timeout` (`:146`). `printf`/`rm`/`mktemp` are output and scratch, not scoring.

**Verdict: FAIL.** The hardening added a presence guard for six tools but left the two highest-severity
shadowing classes (A7, A8) and the `cut` path unguarded, and introduced no integrity check that the
resolved tool is the system one. Fold-spec A7's acceptance clause — "qualify the calls (`/usr/bin/…`)
or add a `command -v` guard **plus an integrity check that fails the check when the tool is not the
system one**" — is only half met: the guard is present, the integrity check is not.

---

## 7. Sub-question 5 — exit-code vocabulary declared in README: FAIL

### 7.1 The code implements three codes

```
$ grep -n 'exit [0-9]' FROZEN2.sh
27:  … printf 'FAIL required tool missing: %s\n' "$_t"; exit 1; fi
335:if [ "$C2_BLOCKED" -eq 1 ] && [ "$FAILS" -eq 0 ]; then
336:  printf 'GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)\n'
337:  exit 2
341:[ "$FAILS" -eq 0 ] && exit 0 || exit 1
```

Confirmed behaviourally:

```
$ bash hwA/…/run_gate.sh (clean)                 → exit 0
$ bash hwB/…/run_gate.sh (tampered)              → exit 1
$ bash hwG/…/run_gate.sh (REPO unreachable)      → exit 2, GATE RESULT: BLOCKED
```

The `exit 2` path is gated on `FAILS -eq 0`, so it fires **only** when check 2 is the sole problem —
that is the correct design intent, and on a clean tree it works.

### 7.2 The README declares only two codes, and one of them is now wrong

```
$ grep -n 'exit 2' corpus/knowledge/unreal-mcp/gate/README.md
(no matches — count 0)
$ sed -n '156,157p' corpus/knowledge/unreal-mcp/gate/README.md
Exit codes are strict and fail-closed: **`0`** iff all four checks print `STEP=PASS`; **`1`**
otherwise. There is no partial-pass state — a missing artifact is a FAIL, not a warning.
$ sed -n '73,74p' corpus/knowledge/unreal-mcp/gate/README.md
**BLOCKED, not PASS.** This is the only check needing network. If the clone fails, the gate
prints `FAIL fresh clone failed … BLOCKED, not PASS`, the check fails, and the run exits 1.
```

Three contradictions with the frozen code: (a) `:156` says "`1` otherwise", which is false for the
BLOCKED path — the code exits 2; (b) `:74` still quotes the **pre-A4** message string
(`FAIL fresh clone failed … BLOCKED, not PASS`) and the pre-A4 behaviour ("the check fails, and the
run exits 1"), neither of which the code does any more; (c) `exit 2` appears nowhere in the README.
There is no lane-wide exit-code registry to fall back on. **Verdict: FAIL** — the vocabulary is
implemented but not declared.

### 7.3 A fourth defect in the same area: the BLOCKED state is mislabelled and can be lost

**Mislabelled.** The BLOCKED branch names the *network* as the cause (`:178`
`printf 'CHECK 2 BLOCKED (network)\n'`), but the branch is reached whenever `git clone` returns
non-zero — including a **local resource failure**. Measured (§2): with `/tmp` quota-exhausted the
gate printed `CHECK 2 BLOCKED (network)` and exit 2 on a clean, healthy tree, while the actual cause
was `Disk quota exceeded`. A reader diagnosing the run is sent to the wrong subsystem.

**Lost in the mixed case.** Because the `exit 2` gate requires `FAILS -eq 0`, a BLOCKED check 2
combined with *any* other failing check degrades to `exit 1`:

```
$ # unreachable REPO AND a planted OOR pointer:
CHECK 2 BLOCKED (network)
STEP=BLOCKED
STEP=FAIL
GATE RESULT: FAIL (checks failed: 1)
exit=1
```

The transcript still carries `STEP=BLOCKED`, but the *exit channel* — which is what the code comment
at `:334` says "is what carries the distinction" — does not. So the ambiguity A4 set out to remove
survives in exactly the case where a reader most needs it.

---

## 8. Residual queue for the next gate seat

Ranked by severity. Each is a flag against the frozen revision `0c1ca3e1…`; the owning seat decides.

1. **A7 — qualify or integrity-check `sha256sum`** (`:96`, `:168`, `:169`, plus `:74`). Highest
   severity: it is a *complete* false green asserting the README's own expected values. Qualify the
   calls or verify the resolved binary. Same for `cut` (`:168`, `:169`), which is unguarded and
   independently sufficient.
2. **A8 — guard `comm` and score the comparison only when it ran** (`:160`, `:161`). Fold-spec's own
   wording applies verbatim: run the comparison only when the tool succeeded.
3. **Check 4 vacuous pass under a shadowed `grep`** (§6.5). Have the sweep assert it actually read
   files (`POINTERS`-vs-files-scanned) and fail closed when the extractor produced nothing.
4. **README exit-code declaration** (`:73-74`, `:156-157`): declare `0/1/2`, fix the stale A4 string.
   *(Overlaps `reports/round-103/gate/exit-codes.md` and `docs-sync.md`; flagged here because this
   seat measured the code side.)*
5. **BLOCKED mislabel and mixed-case loss** (§7.3): rename the signal to name the actual failure, and
   decide whether BLOCKED should outrank FAIL on the exit channel.
6. **A6 — extensionless pointer targets** (`:311`): the regex still requires a dot in the path, so
   `upstream/LICENSE:99999` is invisible.
7. **`TMPDIR` dependency** (§2, §4.3): document that the gate needs a writable temp directory, since
   every scratch file now comes from `mktemp`.

---

## 9. What this audit did and did not establish

**Established, by running it:** network surface is one pre-existing clone to the pinned URL; the
r102 hardcoded `/tmp/advgate/.h1` write is gone and the residual write surface is `/dev/null` plus
`mktemp` scratch reclaimed by the trap; the gate does not mutate the repo or `.git`; 11/11 r102
attacks still detected; A1–A5 of the r103 queue are genuinely closed; A6/A7/A8 and the tool-shadowing
class are not; the exit-code vocabulary is implemented but undeclared, mislabelled, and lost in the
mixed case.

**Not established, and not claimed:** no Unreal Editor behaviour, no live-MCP behaviour, no statement
about any file outside the gate; no claim that `POINTERS=98` is a contract (it is scanner- and
tree-relative by construction and moved between every revision I measured); no claim about the
revision *after* `0c1ca3e1…`, which the owning seats may already have replaced.

**Scope note on the replica.** Mutations were run on a minimal layout-faithful replica, not on the
live lane tree — the live tree is shared with concurrent seats and the hard rules forbid writing the
pinned subtree. The replica's base was verified green (`exit=0`) before every mutation, and every
mutation is reported alongside its unmutated control.

---

## 10. Post-audit drift: a sixth revision landed, and it confirms §7.3

While this file was being finalised the gate changed again, to
`sha256 9b4763d9d070cbaf…` (md5 `9b6238d6b8898621941d88a5cf775652`, `FROZEN3.sh`). The diff is one
rename and it is worth recording, because it is independent confirmation of this report's method and
of §7.3's warning that a mutated harness can manufacture spurious reds:

```diff
-REPO=$(cd "$SUB/../../.." && pwd)
+# A4b (SEAT-09, r103): this root is named REPO_ROOT, not REPO. …
+REPO_ROOT=$(cd "$SUB/../../.." && pwd)
```

The check-4 pass-B root **reused the variable name `REPO`**, which at `:31` holds the upstream clone
URL. So `REPO=<url> bash run_gate.sh` — the obvious way to test the BLOCKED path — silently repointed
pass B at a nonexistent directory and emitted ~26 spurious `MISSING-PATH-REL` lines. I hit exactly
this in my own first A4 attempt and had to correct the harness (the `sed` that rewrote `REPO=` also
rewrote the pass-B root); the corrected harness then produced the clean `exit=2` result in §5.2 and
§7.1. **Fixed in `9b4763d9…`.**

Re-run of the live gate at that revision, for the record:

```
$ TMPDIR=… bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
POINTERS=98 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)          exit=0
```

This rename does **not** change any verdict in §3–§7: it is confined to pass B's root variable and
the observed `POINTERS=98 … UNRESOLVED=0` is identical at both revisions.

### 10.1 Two further revisions landed after that

- `sha256 577c8b5489577b94…` (md5 `efc1e618ce127f61b6112f04d0c3d95b`, `FROZEN4.sh`): a single added
  `# shellcheck disable=SC2016` directive line. Behaviour-neutral.
- **`gate/README.md` gained a `## Exit codes` section** (now `:198-211`) declaring all three codes
  `0`/`1`/`2` explicitly, including the "mixed case" residual, and the pre-A4 stale sentence at the
  old `:73-74` is gone. **This closes sub-question 5 (§7.2).** Verified at the finish revision:

```
$ grep -n 'exit 2' corpus/knowledge/unreal-mcp/gate/README.md
83:BLOCKED (network)`, `BLOCKED fresh clone could not complete …`, `BLOCKED exit 2 is not a verdict:
$ sed -n '198,200p' corpus/knowledge/unreal-mcp/gate/README.md
## Exit codes

Exit codes are strict and fail-closed, with a declared third state for a check that **could not
```

**Re-verified at the newest revision `577c8b5489577b94…`, the findings in §6 still hold exactly:**

| attack | newest revision | control |
|---|---|---|
| A7 shadowed `sha256sum` + flipped byte | `exit=0`, `MANIFEST_OK=12 … BLOB_DIFFS=0`, `GATE RESULT: PASS` | red (3 checks) |
| A8 failing `comm` + stray file | `exit=0`, `PATH_EXTRA=0`, `GATE RESULT: PASS` | red (1 check) |
| A6 `upstream/LICENSE:99999` | `exit=0`, `UNRESOLVED=0`, `GATE RESULT: PASS` | — |

So at the end of this audit the **live** residual set is: **A6, A7, A8 and the tool-shadowing class
(§6) — unchanged — plus the mislabelled-BLOCKED and `TMPDIR` items (§7.3, §8.7).** Sub-question 5 and
the r102 `/tmp` write defect are **closed**. Any close-out claim must re-check §6 against whatever
revision is current then: the gate took seven shas in ~25 minutes of wall clock, and the README's own
pinned scanner sha (`gate/README.md:129`, `:153`, both still reading `412d1b84…`) is now four
revisions stale.

**One thing this seat did not do, noted for the record:** `corpus/fixtures/three/README.md` shows as
modified in `git status` at `15:35:34`, inside the window of this audit. **This seat did not write it**
(this seat wrote only `reports/round-103/gate/sentinel.md`). Inspecting the diff, it is the C3
dead-root repair — stripping the `.shokunin/game-dev-3d/` prefix from the four commands
(`npm ci --prefix corpus/fixtures/three`, etc.) — so it is an intended round-103 change by the seat
that owns C3, not an unauthorised write. Flagged only so that it is not mistaken for this seat's work.

