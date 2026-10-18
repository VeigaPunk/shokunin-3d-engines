# r103 · SEAT-62 · GATE-SECURITY — security review of the hardened close-out gate

**Seat:** SEAT-62 GATE-SECURITY · round 103 · lane `game-dev-3d-shokunin`
**Owned path:** this file only (`reports/round-103/gate/security.md`). No other file was written by this seat.
**Date:** 2026-10-18 · **Repo HEAD at authoring:** `c85a816` (r102 report-last; work `c6f655d`)
**Axes served:** coverage (primary — the gate is the round's coverage artifact) and depth; calibration is
untouched, because nothing here changes a score.

## 0. What this seat reviewed, and the moving-target problem

The subject is `corpus/knowledge/unreal-mcp/gate/run_gate.sh`, the close-out gate for the
byte-pinned unreal-mcp subtree. The question put to this seat is narrow and adversarial:

> **can crafted input make this gate (a) execute a command, (b) write where it should not, or
> (c) print a verdict that is not supported by the bytes it claims to have checked?**

**The artifact changed under this review.** When this seat first read the gate it was the committed
r102 file (`412d1b84…`, 249 lines, HEAD `c85a816`). Mid-review SEAT-09 landed A1–A4 and then E1/E2,
rewriting the file. Everything below is therefore pinned to a **single snapshot**:

| | |
|---|---|
| reviewed bytes | `577c8b5489577b948536005a170da14ae3d4e13c11776aeca8f803bfb5fcefa0` |
| size | 19 347 bytes, 347 lines |
| state | **uncommitted working-tree change** (`git diff --numstat` → `123 25`) |
| snapshot kept at | `/tmp/seat62/cur.sh` (identical hash to the on-disk file at 18:42:20Z) |
| earlier snapshot | `9b4763d9…` (346 lines) — **differs from the reviewed bytes by one comment line only** (a `# shellcheck disable=SC2016` header), so every line reference below holds for both |

Line references are to the reviewed bytes. This file is a **review, not a repair**: no gate line was
edited by this seat, and the pinned subtrees (`upstream/`, `.manifest.d/`) were never touched.

**Method.** Every claim below was produced by running a command, not by reading code. The gate was
copied to a scratch subtree under `/tmp/seat62/` and only the copy was run. Two harnesses were used:
a **bare copy** (for checks 1–3 and for the write-surface probes) and a **lane-shaped copy**
(`/tmp/seat62/lane/corpus/knowledge/unreal-mcp/` with `corpus/artifacts`, `corpus/lessons`,
`reports/` symlinked to the real repo) so that CHECK 4 resolves its repo-relative pointers and the
gate can reach a genuine `PASS`. **Harness control:** the lane-shaped copy with no plant prints
`POINTERS=101 … UNRESOLVED=0 / STEP=PASS` and exits 0 — the harness is not manufacturing reds.

**No Unreal runtime claim is made or implied anywhere in this file.** The editor is not installed on
this host and live-MCP behaviour is unproven by construction; this is a static review of a shell
script and of the bytes that script reads.

---

## 1. Verdict summary

| # | Finding | Class | Severity | Status |
|---|---|---|---|---|
| F1 | A fenced-code label line above the real declaration hijacks CHECK 3 (A2 residual) | fail-open | **HIGH** | open, reproduced |
| F2 | `MANLOG=$(mktemp)` unchecked → a scratch failure is reported as a *manifest* failure, on a sweep that never ran | misattributed verdict | **HIGH** | open, reproduced |
| F3 | `WORK=$(mktemp -d)` unchecked → clone log written to `/clone.log` at filesystem root | misdirected write | **HIGH** | open, reproduced |
| F4 | `audit-reference.sha256` is not itself pinned; a decoy set satisfies CHECK 1 | integrity gap (latent) | **MEDIUM** | open, reproduced |
| F5 | A line number beyond `intmax` makes the range test error out → CHECK 4 prints PASS (A1 residual) | fail-open | **MEDIUM** | open, reproduced |
| F6 | `for f in $CARDS` / `for n in $PINNED_CARD_NAMES` word-split on whitespace | robustness | **LOW** | open, reproduced |
| — | **command execution via crafted filenames or pointers** | — | **none found** | clean |
| — | **`eval` / `exec` / `source` / unquoted-expansion injection** | — | **none found** | clean |
| — | **path traversal out of the subtree** | — | **none found** | fails closed |
| — | **`mktemp`-scratch symlink attack on the *clone* path** | — | **none found** | `mktemp -d` is 0700 |

F1, F3 and F5 are **fail-open**: the gate's own control flow turns a defect into a green line —
F1 and F5 reach a full `GATE RESULT: PASS`. F2 fails *closed* but misattributed: the run goes red for
a reason that is not the reason printed. F4 is an integrity gap: it never lets a *divergent* byte
through (CHECK 2 catches that in every combination tested), but it makes CHECK 1's `PASS` mean less
than it appears to. F6 is robustness only. **Two of the six are residuals of r103's own hardening** —
F1 survives the A2 fix and F5 is a hole adjacent to the A1 fix (`§7`); F2 and F3 are the two sides of
the E1 fix. That is the most useful thing this file has to say: the A-series closed the reported holes
and left adjacent ones.

---

## 2. Injection and command-execution surface — clean

### 2.1 No dynamic-evaluation primitive

```
$ grep -nE '(^|[^A-Za-z_])eval([^A-Za-z_]|$)|(^|[^A-Za-z_])exec([^A-Za-z_]|$)|(^|[^A-Za-z_])source([^A-Za-z_]|$)' cur.sh
NONE
```

There is no `eval`, no `exec`, no `source`, and no command substitution fed by input. Every expansion
is double-quoted (`"$f"`, "$ptr", "$WORK/clone.log", "$SUB/upstream/$f", "$BASE/$p"); the only
unquoted expansions are deliberate `for … in $CARDS` / `$PINNED_CARD_NAMES` word-splits (F6) and the
`case` patterns of the pointer classifier. `shellcheck` reports **zero** findings on the reviewed
bytes (`shellcheck -f gcc cur.sh` → no output; the file even carries its own `disable=SC2016`).

### 2.2 Crafted filenames execute nothing

Attacks planted in a copy: `$(touch PWNED_A).md`, ``x`touch PWNED_C`y.md``, `-dash.md`,
`star*glob.md`, `semi;id.md` in `upstream/`, plus the pointer text
`` `upstream/$(touch PWNED_B).md:1` `` in a card.

```
$ ls -1 "$S/upstream"
$(touch PWNED_A).md
-dash.md
semi;id.md
star*glob.md
x`touch PWNED_C`y.md
$ bash "$G" … ; ls PWNED_* 2>&1 | head -3
ls: cannot access 'PWNED_*': No such file or directory
```

(For this clean run the command shown is the one actually executed — `ls PWNED_* 2>&1 | head -3` from
`/tmp/seat62` — and its output is the line quoted. An equivalent `find` check also returned nothing.)

Nothing executed. **Which check catches the planted files is worth stating precisely, because my
first reading of it was wrong.** These five names are *regular files*, so HARDENING A (`:59`,
`find … ! -type f ! -type d`) does **not** fire on them — it exists for symlinks and FIFOs. What
catches them is CHECK 2's path-set comparison: they are vendored files that upstream does not track,
so the run prints `PATH_EXTRA=2 PATH_MISSING=0` (`:163`) and CHECK 2 goes `STEP=FAIL` (exit 1). The
crafted **pointer text** is separately refused by CHECK 4's `[ -f "$BASE/$p" ]` (`:297`), which
treats the metacharacter names as *missing* rather than globbing them because its operand is quoted.
Both are refusals, by two different checks — and neither is HARDENING A.

### 2.3 Path traversal fails closed

`` `upstream/../../../../../../etc/passwd:999999` `` is read literally, finds no file under the
subtree, and is reported — it does not escape:

```
$ bash "$G" | grep 'etc/passwd'
MISSING-PATH-REL upstream/../../../../../../etc/passwd
```

The gate only ever *reads* `$BASE/$p`, and the traversal resolves to a non-existent path, so nothing
is leaked and nothing is written. A traversal that *did* resolve (`../` to a real file) would let a
pointer line-number check read an out-of-tree file's length — an information leak of line counts
only, which this seat judged not worth a finding, but which is the reason the sweep's `case` at
`:324-327` whitelists prefixes rather than accepting any path.

### 2.4 The `mktemp` scratch is not symlink-attackable

`WORK=$(mktemp -d)` (`:86`) creates a mode-`0700` directory with a random name; the clone lands in
`$WORK/clone` inside it. There is no fixed, predictable path in the reviewed bytes for an attacker to
pre-create — the r102 hardcoded `/tmp/advgate/.h1` (which *was* predictable, and world-writable in
`/tmp`) is gone. `grep -nE '/tmp/|/home/' cur.sh` returns **one line, a comment** (`:70`) explaining
the removal. The residual is the `mktemp`-failure case, which is F2/F3 — a robustness defect, not an
attack surface.

---

## 3. F1 — A fenced-code label line hijacks CHECK 3 (A2 residual) — HIGH

**Where:** `run_gate.sh:213-216` (`LABEL_RE`) and `:228` (`rec=$(grep -nE "$LABEL_RE" "$f" | head -1)`).

A2 replaced the old "first token-bearing line" rule with an **anchored** `LABEL_RE` that matches only
the five real declaration shapes. Anchoring defeats the *prose* hijack — SEAT-36's sentence "this card
is emphatically not `verified-here`" no longer matches, because it does not *start* with the shape.
But a **fenced code block** whose line starts with the shape still matches, and it sits above the
real declaration. Markdown fences are invisible to `grep`.

**Reproduced** (lane-shaped copy, one card replaced):

```
$ cat -n …/executability/materials.md
     1  # Verdict Card — Materials
     2
     3  Vocabulary used below:
     4
     5  ```
     6  **Label:** `static-only`
     7  ```
     8
     9  **Label:** `verified-here`          <-- the real declaration
$ bash "$G" | sed -n '/CHECK 3/,/CHECK 4/p'
OK   static-only      materials.md                   line 6
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
NAME_SET=OK NAME_BAD=0
STEP=PASS
```

The gate reads the **fence** as the declaration (line 6, not line 9), counts the card as
`static-only`, and the census lands exactly on the expected `12/1/0` — so the run is **green**:
`GATE RESULT: PASS (checks failed: 0)`. The card's actual declaration says `verified-here`, which is
the one label the gate exists to forbid (`EXPECTED_VERIFIED=0`).

**Re-verified on the reviewed bytes** `577c8b54…`: `OK static-only materials.md line 6 … STEP=PASS`.
This is the exact escalation A2 was written to prevent, reached by a different route: A2 hardened the
rule against prose and left it vulnerable to code.

**Why it matters more than a cosmetic bug.** The census `12/1/0` is the gate's whole statement about
runtime honesty — 12 cards that claim only static reading, 1 that admits unproven runtime, 0 that
claim a run happened. A spoofed fence lets a card **claim `verified-here` in its real declaration
while the gate counts it as `static-only`**, and the gate cannot see the contradiction. The
non-retired axis this round is coverage, and this is the coverage artifact's own control being
bypassed.

**Fix shape (not applied).** Strip fenced regions before scanning, or require the declaration to be
the *only* token-bearing anchored line in the card, or require it to sit inside the card's header
block (before the first `---`). Any of the three closes it; the cheapest is a `sed`/`awk` pass that
drops `^``` … ^```$` regions before `grep -nE`.

---

## 4. F2 — `MANLOG=$(mktemp)` is unchecked: the shard sweep reports a verdict it did not reach — HIGH

**Where:** `run_gate.sh:74` (`MANLOG=$(mktemp)`), redirected at `:75`, removed at `:80`.

E1 replaced the hardcoded `/tmp/advgate/.h1` with `mktemp` — a correct fix for the *spurious red* that
the old path caused on hosts without `/tmp/advgate`. But the substitution left the call unchecked, so
the failure moved rather than closed. When `mktemp` cannot create a file, `MANLOG` is **empty**, and
the redirect target becomes the empty string:

```
$ TMPDIR=/tmp/seat62/nope-62 bash -c 'MANLOG=$(mktemp); printf "x" >"$MANLOG"'
mktemp: failed to create file via template '/tmp/seat62/nope-62/tmp.XXXXXXXXXX': No such file or directory
bash: line 1: : No such file or directory
```

Inside the gate this is worse than a plain error, because the command is wrapped in an `if !` whose
failure is *supposed* to mean "a manifest failed". Verbatim from the reviewed bytes (`577c8b54…`,
`TMPDIR` pointing at a directory that does not exist):

```
$ TMPDIR=/tmp/seat62/nope-62 bash "$G" | sed -n '1,12p'
GATE unreal-mcp subtree
SUBTREE=…
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297

MANIFEST_FILES=12
mktemp: failed to create file via template '/tmp/seat62/nope-62/tmp.XXXXXXXXXX': No such file or directory
run_gate.sh: line 75: : No such file or directory
FAIL per-seat manifest sweep (--strict) failed:
sed: can't read : No such file or directory
```

The subshell's exit status is non-zero, so the guard fires and `FAILS` increments — the run ends red.
**Stating the defect precisely, because the obvious version of the claim is wrong.** This is *not*
fail-open; what is broken is the **attribution and the evidence**:

- the failure is reported as `FAIL per-seat manifest sweep (--strict) failed:` — blamed on the
  *manifests* — while the cause is the temp directory;
- `sha256sum --strict -c` **never ran**, so the printed sweep result is not a verdict at all. On a
  genuinely clean tree (as in this reproduction) the operator sees a manifest failure that does not
  exist, and a reader who diagnoses "manifests" and regenerates them has fixed nothing.

The `if !` idiom cannot distinguish "the command failed" from "the command never started", and the
gate uses it to *name a culprit*. That is why this is HIGH despite failing closed: it manufactures a
false accusation against the byte-pinned manifests, the one thing in this subtree that must not be
needlessly regenerated. The old E1 bug and this one are the same defect — an unchecked scratch-file
creation — reached from opposite sides.

**Fix shape.** `MANLOG=$(mktemp) || { printf 'FAIL cannot create scratch file\n'; exit 1; }`, and the
same for `WORK`. The guard must run *before* the `if !`, so a scratch failure can never be reported
as a manifest failure.

---

## 5. F3 — `WORK=$(mktemp -d)` is unchecked; the clone log lands at `/clone.log` — HIGH

**Where:** `run_gate.sh:86` (`WORK=$(mktemp -d)`), `:87` (`cleanup() { rm -rf "$WORK"; }`),
`:147` (`… >"$WORK/clone.log" 2>&1`), `:137` (`CLONE=$WORK/clone`).

This is the same unchecked-`mktemp` pattern as F2, on the **clone** path, and it has a second effect:
because every scratch path is `"$WORK/…"`, an empty `$WORK` turns them into **absolute paths at the
filesystem root**. Reproduced with a `TMPDIR` that does not exist:

```
$ TMPDIR=/tmp/seat62/nope-62 bash "$G"
mktemp: failed to create directory via template '/tmp/seat62/nope-62/tmp.XXXXXXXXXX': No such file or directory
run_gate.sh: line 147: /clone.log: Permission denied
CHECK 2 BLOCKED (network)
sed: can't read /clone.log: No such file or directory
```

The gate attempts to create **`/clone.log`** at the root of the filesystem. It failed only because the
invoking user is uid 1000:

```
$ id -u
1000
$ ls -la /clone.log
ls: cannot access '/clone.log': No such file or directory
```

Run as root — a CI container, a `sudo` invocation, a privileged close-out — the same run **writes
`/clone.log`**, and `CLONE=$WORK/clone` would aim the `git clone` at **`/clone`**. The `trap cleanup
EXIT` does not mitigate this: `cleanup` is `rm -rf "$WORK"`, and `rm -rf ""` is a silent no-op
(`bash -c 'rm -rf ""; echo rc=$?'` → `rc=0`), so the scratch tree is *never* cleaned up in this case
either. Every symptom of a missing temp directory is a write to an unintended location plus a leaked
scratch directory.

**Fix shape.** Same guard as F2, plus a defensive `[ -n "$WORK" ] || exit 1` before `trap`. Guarding
`cleanup` as `[ -n "$WORK" ] && rm -rf "$WORK"` is cheap insurance for any future edit that leaves
`WORK` empty by another route.

---

## 6. F4 — `audit-reference.sha256` is not itself pinned; a decoy set satisfies CHECK 1 — MEDIUM

**Where:** `run_gate.sh:97` (`sha256sum -c .manifest.d/audit-reference.sha256`), against the
per-seat sweep at `:75`.

HARDENING B added the per-seat sweep precisely because "check 1 only reads audit-reference.sha256".
But the audit reference is still the **unpinned root of trust**, and it is not covered by any shard:

```
$ grep -l 'audit-reference' "$SUB"/.manifest.d/seat*.sha256
NONE — audit-reference.sha256 is unpinned
```

CHECK 1 asserts a *count* (`C1_OK -eq EXPECTED_MANIFEST_OK`) and the absence of `FAILED` lines. A
decoy audit reference with exactly 12 entries satisfies both. Replacing the file with 12 card
hashes — no `upstream/` entries at all — on a lane-shaped copy with a **clean harness** yields a
fully green run:

```
$ ( cd "$S" && for f in $(ls executability/*.md | head -12); do printf '%s  %s\n' "$(sha256sum "$f" | cut -d' ' -f1)" "$f"; done > .manifest.d/audit-reference.sha256 )
$ grep -c upstream .manifest.d/audit-reference.sha256
0
$ bash "$G" | grep -E 'MANIFEST_OK|^STEP=|^GATE RESULT'
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
STEP=PASS        # CHECK 1
STEP=PASS        # CHECK 2
STEP=PASS        # CHECK 3
STEP=PASS        # CHECK 4
GATE RESULT: PASS (checks failed: 0)      RC=0
```

**CHECK 1 reports PASS over a manifest that pins none of the vendored bytes**, and every other check
also passes — so the run is a clean `exit 0`. (An earlier run of the same plant in a *non*-lane-shaped
harness failed on CHECK 4, but that red was the harness's own dangling report pointer, not the gate
catching the decoy. With a clean harness the decoy alone is invisible.) Deleting the shard files is
likewise reported only as an informational counter and is never asserted:

```
$ rm -f .manifest.d/seat*.sha256 ; bash "$G" | grep -E 'MANIFEST_FILES|GATE RESULT'
MANIFEST_FILES=11
GATE RESULT: PASS (checks failed: 0)
```

`MANIFEST_FILES` is printed and never compared to a pinned `12`.

**The honest bound on this finding — verified in both directions.** The decoy does **not** survive
CHECK 2. A modified vendored file is caught by the clone comparison even with every shard deleted,
and the compound case (decoy manifest + unreachable `REPO`, clean harness) fails closed as BLOCKED:

```
$ # decoy audit-reference + unreachable REPO, clean lane-shaped harness
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
STEP=PASS                    # CHECK 1 — green, having checked nothing real
STEP=BLOCKED                 # CHECK 2 — could not run
GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)      RC=2
```

**F4 is therefore a latent integrity gap, not a demonstrated bypass.** It is worth recording because
it is a *statement about CHECK 1 that is stronger than CHECK 1 can support* — "CHECK 1 pins the 12
vendored files" is not enforced by CHECK 1, it is enforced by CHECK 2, and CHECK 2 is the check with
a third state. The pairing that matters is **F2 + F4**: if the per-seat sweep fails to run (F2) *and*
the audit reference is a decoy (F4), then on a host where CHECK 2 is `BLOCKED` **nothing has verified
the vendored bytes**, and the only signal distinguishing that from a genuine verification is the
`exit 2` — which is correct, and which is why the exit code (not the summary line) is the thing to
key on.

**Fix shape.** Add `audit-reference.sha256` (and the expected shard count) to the pinned set, and
assert `MANIFEST_FILES -eq 12` rather than printing it. A shard entry for the audit reference would
close both the decoy and the deletion.

---

## 7. F5 — A line number beyond `intmax` defeats CHECK 4 (A1 residual) — MEDIUM

**Where:** `run_gate.sh:310` (`[ "$ln" -gt "$n" ]`), `:309` (`[ "$ln" -lt 1 ]`), inside the A1
per-endpoint loop at `:307-311`.

A1's own comment records the fix: the extraction regex now keeps the `:a-b` / `:a,b` tail and the loop
validates **every** endpoint. It does — for endpoints that fit in an integer. `test` has no
overflow-safe numeric comparison: a 20-digit operand makes `[ … -gt … ]` **error out and return
false**, which the loop reads as "in range".

```
$ for n in 9999999999999999999 9223372036854775808; do bash -c "[ $n -gt 5 ] && echo TRUE || echo FALSE"; done
bash: line 1: [: 9999999999999999999: integer expected
FALSE
bash: line 1: [: 9223372036854775808: integer expected
FALSE
```

Isolated on a lane-shaped copy (control `POINTERS=101 … UNRESOLVED=0 / STEP=PASS`), planting a single
pointer to a line far past the 112-line file:

```
$ printf '\n`upstream/README.md:99999999999999999999`\n' >> …/executability/materials.md
$ bash "$G"
run_gate.sh: line 309: [: 99999999999999999999: integer expected
run_gate.sh: line 310: [: 99999999999999999999: integer expected
POINTERS=102 POINTER_STRINGS=42 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
GATE RESULT: PASS (checks failed: 0)
```

(The two diagnostic lines come from the `-lt 1` test at `:309` and the `-gt "$n"` test at `:310`;
both error out and return false, so neither the `LINE-ZERO` nor the `LINE-OOR` branch fires.)

`POINTERS` counts the endpoint and `UNRESOLVED=0`, so the pointer is *counted as valid*. **A1's
falsifiable acceptance is met for the range form (`upstream/README.md:1-9999` → `LINE-OOR`, verified
here as control A1a in §9) but the same tail validation is bypassed by an operand that overflows.**
This is a
narrower hole than A1 closed and it is not reachable by accident — it needs a pointer deliberately
written with an absurd line number — but it is the difference between "validated every endpoint" and
"validated every endpoint that parses".

**Fix shape.** Validate the token before comparing, e.g.
`case "$ln" in ''|*[!0-9]*) …;; esac` plus a length check (`${#ln} -le 9`), and treat anything else
as `LINE-OOR`. A `printf '%d'` round-trip or an explicit digit/length gate both work.

---

## 8. F6 — Word-splitting on the card-name and card-list loops — LOW

**Where:** `run_gate.sh:250` (`for n in $PINNED_CARD_NAMES`) and `:253` (`for f in $CARDS`), both
unquoted; `PINNED_CARD_NAMES` is a space-separated string at `:42`.

A3's name-set comparison is exact for well-formed names, and this seat re-confirmed the intended
falsification (`sequencer.md` → `sequence-typo.md` → `card-name-missing sequencer.md`,
`card-name-extra sequence-typo.md`, `NAME_SET=BAD NAME_BAD=2`). The unquoted splits are safe **only
because** every card stem is a single whitespace-free word. A filename containing a space breaks the
comparison into fragments rather than reporting one clean mismatch:

```
$ mv …/executability/sequencer.md "…/executability/two words.md"
FAIL card-name-missing sequencer.md
FAIL card-name-extra two
FAIL card-name-extra words.md
NAME_SET=BAD NAME_BAD=3
```

The verdict is still a correct FAIL — the count is merely inflated — so this is robustness, not a
bypass. Worth a one-line note in the gate because the same idiom would become a real bypass if a
future card name were ever allowed to contain a space. (The `$CARDS` split is harmless here: `find`
output is one path per line and no path in the tree contains whitespace.)

---

## 9. Control re-verification — the r103 features work

This seat's probes double as a control matrix for SEAT-09's A1–A4 and E1. All PASS:

| control | plant | observed |
|---|---|---|
| C0 | none (lane-shaped copy) | `POINTERS=101 … UNRESOLVED=0 / STEP=PASS`, exit 0 |
| A1a | `` `upstream/README.md:1-9999` `` | `LINE-OOR … (max 112)`, `UNRESOLVED=1`, `STEP=FAIL`, exit 1 |
| A2a | **prose** line naming a token above the declaration | `CARDS=13 BAD=0`, census reads the real declaration, exit 1 (census mismatch) |
| A4a | unreachable `REPO`, no `GATE_REF` | `CHECK 2 BLOCKED (network)`, `STEP=BLOCKED`, `GATE RESULT: BLOCKED`, **exit 2** |
| A4b | unreachable `REPO`, valid `GATE_REF` | `GATE_REF=… (offline reference; no clone attempted)`, `BLOB_DIFFS=0`, `STEP=PASS`, exit 0 |
| E1 | `/tmp/advgate` absent | no spurious manifest red (the r102 hardcoded path is gone) |

The A4 exit channel is the strongest thing in the reviewed bytes: `exit 2` with a `GATE RESULT: BLOCKED`
line is a genuine third state, and the `GATE_REF` path was exercised against a real clone at the pin
(`CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297`). The F4/F5 findings are not a criticism of
A1–A4 — they are the residual set after A1–A4.

---

## 10. Attribution — what is already recorded elsewhere

Two r103 sibling seats worked adjacent ground; this file does not re-claim their results.

- **`reports/round-103/gate/hardening.md`** (SEAT-09) records E1 (the hardcoded `/tmp/advgate/.h1`,
  now `mktemp`) and E2 (the `REPO`/`REPO_ROOT` shadowing) as the two unqueued defects it fixed. **F2
  and F3 are the consequences of that fix**, not the pre-fix bug: the defect this file adds is that
  the *replacement* call is unchecked. SEAT-09's own E1 section documents the old failure; §4/§5 here
  document the new one.
- **`reports/round-103/gate/sentinel.md`** (SEAT-19) reports the write surface as `/dev/null` plus
  `mktemp` scratch, with the residual "the gate still *requires* a writable `TMPDIR` … fail-closed".
  **§5 here sharpens that residual into a reproduced misdirected write** (`/clone.log` at the root,
  blocked only by non-root uid). SEAT-19 measured the write surface with a *working* `TMPDIR`; the
  `TMPDIR`-missing path is the one that writes outside it.
- **`reports/round-103/gate/a2-attack.md`** (SEAT-12) covers V0–V11 of the prose hijack, including
  the residual that a **short** marked prose line is still read as a declaration. **F1 is a different
  route to the same class**: a *fenced* line of any length, which SEAT-12's matrix does not plant and
  which A2's anchoring does not exclude. Both residuals are worth carrying.

Where this file disagrees with a sibling, the disagreement is stated with its command. This seat found
no prior r103 record of the fenced-code route (F1), the unchecked-`mktemp` defects (F2/F3), the
`audit-reference.sha256` pin gap (F4), or the `intmax` overflow (F5).

---

## 11. Limits

- **The artifact is uncommitted and was moving during the review.** The review is pinned to
  `577c8b54…` (347 lines, snapshot `/tmp/seat62/cur.sh`). If SEAT-09 lands further edits, every line
  reference here must be re-resolved; the *finding classes* (unchecked `mktemp`, fence-blind label
  scan, unpinned root manifest, integer overflow) survive re-editing and should be re-tested rather
  than assumed fixed.
- **No Unreal runtime claim.** This is a static review of a shell script. It says nothing about
  whether the vendored upstream plugin works in an editor; the editor is not installed.
- **Scope.** Only `run_gate.sh` was reviewed as an artifact. `gate/README.md` was read only to check
  that A4's exit codes are declared (they are, `§"Exit codes"`); its prose was not audited for
  accuracy, which is a different seat's question.
- **Reproduce.** Scratch copies under `/tmp/seat62/`: `E_new.sh` (A1/A2/A4 controls),
  `F_manifest.sh` (manifest coverage, injection), `G_bypass.sh` and `G2.sh` (decoy manifest),
  `final.sh` (consolidated re-run of C0/F1/F4/F5 and the injection check against the reviewed bytes),
  plus one-off lane-shaped runs for F3. Raw outputs in `/tmp/seat62/*.out`. None of these touch the
  repo; the pinned subtrees were never modified.
- **A note on evidence hygiene.** Three line references in this file were corrected during a
  self-audit after the gate grew a line mid-review, and two quoted blocks were re-captured against the
  reviewed bytes rather than the earlier snapshot. Every `:N` reference above was re-verified against
  `/tmp/seat62/cur.sh` (`577c8b54…`) as the final act of this seat. Where a finding's strength changed
  under that re-verification, the change is stated in place — F4 was **downgraded** from "a decoy alone
  produces a failing run" to "a decoy alone produces a green run, but never lets a divergent byte
  through", and §2.2's attribution was **corrected** from HARDENING A to CHECK 2's `PATH_EXTRA`.
  A review that records only its confirmed claims is not a review.
