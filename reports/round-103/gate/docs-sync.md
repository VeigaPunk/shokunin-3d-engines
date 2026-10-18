# SEAT-20 DOCS-SYNC — does `gate/README.md` match the installed gate?

**Seat:** SEAT-20 DOCS-SYNC · round 103 · lane `game-dev-3d-shokunin`
**Written:** 2026-10-18
**Artifact under test:** `corpus/knowledge/unreal-mcp/gate/README.md`
**Reference implementation:** `corpus/knowledge/unreal-mcp/gate/run_gate.sh`
**Ownership:** this seat writes **only** this file. `gate/README.md` and `gate/run_gate.sh` are
**not** mine; they are read-only here. Every finding below is a *flag*, not an edit.

## 0. The target moved while this seat measured — read this first

Both files under test were being edited by **other seats** throughout this window (SEAT-05 on the
README, SEAT-09 on the script). `run_gate.sh` took **eight** distinct shas in ~23 minutes:

```
412d1b84… (r102, frozen at HEAD)  15:15
1305485d…  15:34      55a76cf8…  15:35       ff2c26c0…  15:36
eca9e92f…  15:36      510e186c…  15:36       06917256…  15:36
0c1ca3e1…  15:38   ← the snapshot this verdict is rendered against
```

**The implementation changed under this seat twice in ways that flipped a finding** — A4 landed,
then A3, then A1 and A2. Every claim below is bound to the snapshot in §0.1, and §8 records what
changed after the first draft.

### 0.1 The snapshot this verdict is rendered against

```
$ date -Iseconds
2026-10-18T15:38:25-03:00
$ sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh corpus/knowledge/unreal-mcp/gate/README.md
0c1ca3e1a5606243b45e2c1d4d4ce54d1faea9dcea79048e3c646feca6ab545e  …/gate/run_gate.sh
27f7d8091a23378d8699cc7bc10a5181ce5683f3611b887db485cb7d1db35720  …/gate/README.md
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_TRACKED=12   PATH_EXTRA=0 PATH_MISSING=0   BLOB_DIFFS=0
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
NAME_SET=OK NAME_BAD=0
POINTERS=98 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)          rc=0
```

**Headline verdict: all four A1–A4 behaviors have now landed in the script, and the README
documents none of them.** Every one of the four assigned criteria fails — three of them (1.1-A1–A4,
1.3, 1.4) because the documentation was never written for behavior that now exists, and one (1.2)
because the pin contradicts itself. **A1–A4 have landed; `gate/README.md` is now describing a gate
that no longer exists.**

---

## 1. The four assigned criteria

### 1.1 "A1–A4 documented" — **NO. All four landed; none is documented.**

I verified each item **behaviorally** on `$HOME`-resident mirror copies of the subtree (§3), not by
grepping for markers.

| item | state in the script (sha `0c1ca3e1…`) | README documents it? |
|---|---|---|
| **A1** range-tail endpoints | **LANDED, verified** — endpoint loop `for ln in $(printf '%s' "$rest" \| tr ',-' '  '); do` (`:306`); new `POINTER_STRINGS` output token (`:327`) | **no** |
| **A2** prose-hijack-proof label rule | **LANDED, verified** — structural `LABEL_RE` (`:212`) replacing `grep -nE "$ALLOWED" \| head -1` | **no** |
| **A3** card-**name** set comparison | **LANDED, verified** — `PINNED_CARD_NAMES='actors-scene …'` (`:41`), `NAME_SET=OK NAME_BAD=0` (`:256`) | **no** |
| **A4** distinct BLOCKED signal + exit 2 | **LANDED, verified** — `STEP=BLOCKED`, `GATE RESULT: BLOCKED`, `exit 2` (`:337`), `GATE_REF` (`:130`) | **no** |

```
$ grep -c 'exit 2\|STEP=BLOCKED\|GATE_REF\|SEAT-09\|NAME_SET\|POINTER_STRINGS' \
    corpus/knowledge/unreal-mcp/gate/README.md
0
```

The README's r102 history note (lines 24–34) still reads "Residual queue routed to r103 (fold-spec
A1 range-tail blindness, A2 prose-hijackable first-token rule, A3 card-name comparison, A4
network-blocked vs mismatch distinction)." That sentence was **true when written and is now false**:
all four are closed in code. Nothing in the README describes `NAME_SET`, `STEP=BLOCKED`, `GATE_REF`,
`POINTER_STRINGS`, or exit 2.

**The sharpest single fact in this report:** the script's own A4 comment asserts the README declares
the new exit code —

```
$ sed -n '121,124p' corpus/knowledge/unreal-mcp/gate/run_gate.sh
#     distinct `CHECK 2 BLOCKED (network)` signal and the gate exits 2 — declared
#     in gate/README.md alongside the other codes. It is deliberately NOT counted
```

— but it is **not** declared there. The code documents a README that does not exist. That is the
exact drift class this seat was created to catch, and it was introduced by the hardening itself.

### 1.2 "Expected values current" — **NO. The pin contradicts itself, and the format has drifted.**

A pin-correction note landed mid-window (SEAT-05, `README.md:207`), replacing `87`. But it left the
README disagreeing with **itself**, and the script then changed again:

```
$ grep -o 'POINTERS=[0-9]*' corpus/knowledge/unreal-mcp/gate/README.md | sort | uniq -c
      1 POINTERS=90
      2 POINTERS=91
$ grep -n 'POINTERS=[0-9]' corpus/knowledge/unreal-mcp/gate/README.md
129: … `POINTERS=91 … (pass A = 40, pass B = 51).
142:POINTERS=90 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
213:POINTERS=91 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh | grep POINTERS=
POINTERS=98 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
```

Line 129 and the correction note say **91**; the pinned-summary block (line 142) still says **90**.
The gate prints **98**, and now emits a **new field the README has never seen**:

- **The pinned line is missing `POINTER_STRINGS`.** The gate's CHECK 4 output line is now
  `POINTERS=%s POINTER_STRINGS=%s SKIPPED_CONTROL_SENTINELS=%s UNRESOLVED=%s`. The README's pinned
  block (line 142) and every quoted transcript in it show the old 3-field line. **A reader
  copy-pasting the README's expected line will not match the gate's output at all.**
- **The pinned scanner sha is stale.** Lines 129 and 153 cite `run_gate.sh` sha256 `412d1b84…` — the
  *pre-r103* script. The installed scanner is `0c1ca3e1…`.
- **The pass-A/pass-B decomposition disagrees with itself.** Line 129 says "pass B = 51"; line 232
  says "pass B = 50". The count has since moved past both.
- **The correction note's off-by-one proof is not sound.** It claims the count "rose 88 → 90 → 91
  across r103 … entirely through prose gains". I measured **88** on the frozen r102 tree with the
  *r102* scanner and **98** on the current tree with the *current* scanner — two different scanners,
  presented as one series. And `POINTERS` moved **91 → 98** in minutes while I worked (§8), through a
  mix of prose edits *and* the A1 scanner change. The number is not a function of prose alone.

Everything else pinned **is** correct and I re-confirmed each on the snapshot: `MANIFEST_OK=12
EXPECTED=12 FAILED=0 RC=0`, `CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297`, `CLONE_DIRTY=0`,
`CLONE_TRACKED=12`, `PATH_EXTRA=0 PATH_MISSING=0 BLOB_DIFFS=0`, `CARDS=13 EXPECTED=13 BAD=0`,
`CENSUS static-only=12 unproven-runtime=1 verified-here=0`.

### 1.3 "Exit codes (0/1/2) declared" — **NO. The README declares 0/1; the code has three states.**

```
$ sed -n '156,157p' corpus/knowledge/unreal-mcp/gate/README.md
Exit codes are strict and fail-closed: **`0`** iff all four checks print `STEP=PASS`; **`1`**
otherwise. There is no partial-pass state — a missing artifact is a FAIL, not a warning.
$ grep -c 'exit 2\|exit code 2' corpus/knowledge/unreal-mcp/gate/README.md
0
```

The code now exits **2** (`:337`) and prints `STEP=BLOCKED` / `GATE RESULT: BLOCKED`. The README's
`0/1 only` sentence is **wrong about the installed gate**, and the CHECK 2 section (lines 73–74)
still quotes the **old** failure text (`FAIL fresh clone failed … BLOCKED, not PASS … exits 1`)
which the script no longer emits. Three undocumented behaviours:

1. exit **2** and `STEP=BLOCKED` for an unreachable upstream;
2. `GATE_REF=<path>` for air-gapped runs (zero README mentions);
3. `GATE RESULT: BLOCKED` as a distinct summary line (the README's summary block lists only PASS).

**This is the highest-value remaining docs fix, and it is now purely documentation** — the behavior
exists and is verified end-to-end (§2).

### 1.4 "Hardening-history note appended naming SEAT-09" — **NO such note exists.**

```
$ grep -c 'SEAT-09' corpus/knowledge/unreal-mcp/gate/README.md
0
```

The only history note is still headed "Hardening history (r102 close, 2026-10-18)" (line 24). The
one r103 note present names **SEAT-05** (`README.md:207`, the pin correction) — a different seat and
a different concern. **SEAT-09's A1+A2+A3+A4 landing is entirely unrecorded in the README**,
including the `/tmp/advgate/.h1` → `mktemp` fix (`run_gate.sh:73`).

---

## 2. A4 verified working end-to-end (so the docs fix is unblocked)

Tested on a copy of the current script with the subtree pinned to the real tree and the upstream URL
made unreachable — no writes to the real gate, scratch under `$HOME` (`/tmp` was quota-blocked, §3.1).

**BLOCKED path — unreachable repo, no `GATE_REF`:**

```
$ bash rg_blocked.sh; echo "GATE_RC=$?"
CHECK 2 clone-equivalence
CHECK 2 BLOCKED (network)
BLOCKED fresh clone could not complete — upstream unreachable, nothing compared
BLOCKED exit 2 is not a verdict: the vendored bytes are UNCHECKED, not divergent
STEP=BLOCKED
GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)
GATE_RC=2
```

**`GATE_REF` offline path — unreachable repo, valid clone at the pin:**

```
$ GATE_REF=<clone at a6aa73ad…> bash rg_blocked.sh; echo "GATE_RC=$?"
GATE_REF=…/clone (offline reference; no clone attempted)
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
PATH_EXTRA=0 PATH_MISSING=0   BLOB_DIFFS=0
STEP=PASS          GATE_RC=0
```

**Bad `GATE_REF` — a genuine FAIL, not BLOCKED (correctly distinguished):**

```
$ GATE_REF=/nonexistent/ref bash rg_blocked.sh; echo "GATE_RC=$?"
FAIL GATE_REF is not a git clone: /nonexistent/ref
STEP=FAIL          GATE RESULT: FAIL (checks failed: 1)          GATE_RC=1
```

All three states behave as A4 specified. Residual nuance worth documenting: when CHECK 2 is BLOCKED
**and** another check fails, the `[ "$FAILS" -eq 0 ]` guard (`:336`) reports `FAIL`/exit 1 — BLOCKED
is surfaced only on an otherwise-clean run. Defensible, but undocumented.

## 3. A1–A3 verified behaviorally (positive and negative controls)

All on `$HOME`-resident mirror copies with the real subtree content; baseline mirror prints
`POINTERS=98 … UNRESOLVED=0` / `GATE RESULT: PASS`.

### A1 — the range-tail blind spot is genuinely closed

```
$ printf '\nsee upstream/README.md:1-9999\n' >> …/executability/materials.md
$ bash gate/run_gate.sh
LINE-OOR …/executability/materials.md :: upstream/README.md:1-9999 (max 112)
POINTERS=100 POINTER_STRINGS=42 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=1
GATE RESULT: FAIL (checks failed: 1)          rc=1
```

Decisive proof it was a **real** blind spot, shown at the regex level:

```
$ printf '%s\n' 'see upstream/README.md:1-9999' | grep -ohE "upstream/[^\`\"|)]+\.[A-Za-z0-9]+:[0-9]+"
upstream/README.md:1                    ← old scanner reads :1, which is in range (max 112)
$ printf '%s' "${ptr##*:}" | tr ',-' '  '
1 9999                                  ← new scanner reads both endpoints; 9999 is out of range
```

The old gate resolved `:1` and passed; the new gate resolves both endpoints and fails. A1 is closed.

### A2 — prose hijack no longer wins, and the real controls still fire

```
$ sed -i '1a This card is emphatically not `verified-here`; nothing was observed.' …/editor-general.md
  hijack     -> CARDS=13 EXPECTED=13 BAD=0 NAME_SET=OK NAME_BAD=0        (green — correct)
$ sed -i '4s/.*/Verdict: static-only/' …/blueprints.md
  unmarked   -> CARDS=13 EXPECTED=13 BAD=1 NAME_SET=OK NAME_BAD=0 STEP=FAIL
$ sed -i '4s/.*/**Label:** `static-only` and not `verified-here`/' …/blueprints.md
  multilabel -> CARDS=13 EXPECTED=13 BAD=1 NAME_SET=OK NAME_BAD=0 STEP=FAIL
```

A prose line naming `verified-here` above the declaration is now ignored (the card is still counted
`static-only` at its real declaration line), while an unmarked label and a multi-label line both
still fail. A2 is closed and its negative controls survive.

### A3 — a renamed card is caught

```
$ mv …/executability/sequencer.md …/executability/sequence-typo.md
CARDS=13 EXPECTED=13 BAD=0
NAME_SET=BAD NAME_BAD=2
STEP=FAIL   STEP=FAIL   GATE RESULT: FAIL (checks failed: 2)          rc=1
```

Count stays 13 (the attack A3 targets), but `NAME_SET=BAD` catches the rename. A3 is closed.

### 3.1 Why no README C1–C7 controls were run

The README's own mutation matrix (C1–C7) needs throwaway copies of the subtree; `/tmp` was
quota-exhausted throughout this window (the same condition that broke CHECK 2, §4). I worked around
it with `$HOME`-resident mirrors, which is how §2 and §3 were run — but the README's C1–C7 matrix
itself is **not** independently re-verified here.

## 4. The A4 defect was live, not latent, during r103

Before SEAT-09's fix, CHECK 2 flipped to FAIL on this host with the cause being **not** a byte
mismatch:

```
$ git clone --quiet https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin /tmp/seat20_clone
error: copy-fd: write returned: Disk quota exceeded
fatal: cannot copy '…/applypatch-msg.sample' …: Disk quota exceeded
$ df -h /tmp
tmpfs   16G   12G  3.8G   76% /tmp
```

Two runs minutes apart on the same tree gave opposite verdicts (`rc=0`, then `rc=1`). SEAT-09's diff
also removed a second `/tmp`-hardcoded scratch (`/tmp/advgate/.h1` → `MANLOG=$(mktemp)`, `:73`),
whose comment records the same class of spurious fail-closed on a clean tree. **Both fixes are
undocumented in the README.**

### 4.1 A false FAIL was also observed from concurrent writes

During this window the gate returned FAIL twice in five consecutive runs **on a fixed sha**, then
20/20 clean afterwards:

```
run1 rc=0 : GATE RESULT: PASS (checks failed: 0)
run2 rc=1 : GATE RESULT: FAIL (checks failed: 1)
run3 rc=1 : GATE RESULT: FAIL (checks failed: 1)
run4 rc=0 : GATE RESULT: PASS (checks failed: 0)
run5 rc=0 : GATE RESULT: PASS (checks failed: 0)
```

The cause was peers rewriting `run_gate.sh` while it executed (bash reads a script incrementally).
This is an operational hazard for close-out, not a defect in the script: **a gate run taken while a
round is still writing can be a false FAIL.** Worth a line in the README's "What this gate does not
do" section.

## 5. Additional drift found (not in the four assigned criteria)

| # | README claim | location | actual (snapshot) | evidence |
|---|---|---|---|---|
| 5.1 | "these **six** lines" | `README.md:135` | **correct now** — was "five" and I flagged it mid-window; SEAT-05 fixed it in passing | gate prints 6 summary lines |
| 5.2 | "the **12-attack** suite" | `README.md:31` | the r102 record says **11/11** | `reports/round-102/r102-report.md:429` "11/11 attacks DETECTED"; commit `c6f655d` subject "11/11 attacks detected" |
| 5.3 | "(C1–C6, plus C7 …) must **each turn the gate red**" | `README.md:161` | C7 must stay **green** (exit 0) — the matrix row says so | `README.md:198` "C7 … **0** … stays green" — self-contradictory sentence (fold-spec A9 item 1, still open) |
| 5.4 | C7 pinned `SKIPPED_CONTROL_SENTINELS=2` | `README.md:198` | planting all three documented sentinels yields **3**; C7 is the only control with no `printf` shown | `upstream/nope.md:5` → MATCH, `upstream/README.md:9999` → MATCH, `upstream/README.md:500` → MATCH against `^($SENTINEL)$` (fold-spec A9 item 2, still open) |
| 5.5 | README's CHECK 1 section describes **only** the 12-entry audit reference | `README.md:47-52` | the code also emits `MANIFEST_FILES=12` and runs a per-seat `--strict` sweep, a non-regular-file guard, a CRLF guard, and a nested-entry guard — **none documented** | `grep -c 'MANIFEST_FILES\|non-regular\|nested entry\|HARDENING' README.md` → `0` |
| 5.6 | `GATE_REF` / `STEP=BLOCKED` / `NAME_SET` / `POINTER_STRINGS` | throughout | four new script output tokens, zero README mentions | §1.1, §1.2, §1.3 |
| 5.7 | pinned scanner sha `412d1b84…` | `README.md:129,153` | the installed scanner is `0c1ca3e1…` | §1.2 |
| 5.8 | pinned CHECK 4 output line (3 fields) | `README.md:142` | the gate now prints 4 fields (`POINTER_STRINGS` added) | §1.2 |

Item 5.5 remains the most substantive *silent* gap: the README documents four checks while the
script can fail a run from **9** increment sites at snapshot `0c1ca3e1…` — 4 in-check and 5
pre-check guards (non-regular file, per-seat manifest sweep, CRLF, non-markdown, nested entry). A
reader trusting the README would not know the manifest set is pinned, the trees are symlink-free, or
that CRLF is rejected.

## 6. What the parent should do

1. **Do not accept this seat as "docs updated."** All four assigned criteria fail at the snapshot.
   But the character of the failure has changed: A1–A4 are now **implemented and verified**, so all
   four criteria are now **purely documentation** and closeable in one README pass.
2. **One README pass must:** document A1 (endpoint semantics + `POINTER_STRINGS`), A2 (the structural
   `LABEL_RE` rule), A3 (`NAME_SET`/`PINNED_CARD_NAMES`), and A4 (`STEP=BLOCKED`, `GATE_REF`, exit 2);
   replace the `0/1 only` sentence (line 156) with 0/1/2; rewrite the CHECK 2 BLOCKED paragraph
   (lines 73–74) to the text the script now prints; correct the r102 history note's "residual queue"
   claim; append an r103 history note **naming SEAT-09**; and record the `/tmp` → `mktemp` fix.
   **No r103 seat currently owns `gate/README.md`** — SEAT-05 has been editing it ad hoc.
3. **Fix the `POINTERS` block entirely** (91 vs 90 at lines 129/142/213; missing `POINTER_STRINGS`;
   stale scanner sha; pass B 50-vs-51 at line 232). Retire the bare `<N>` pin in favour of the
   invariant the README already calls binding (`UNRESOLVED=0`) — the number is a function of how
   many seats have written and which scanner revision is installed, and it moved 91 → 98 during this
   round alone.
4. **Fix 5.2–5.5** in the same pass — mechanical, and each currently misleads a reader.
5. **Consider a README line on the concurrent-write hazard** (§4.1): a gate run taken mid-round can
   be a false FAIL.

## 7. Reproduce

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
S=corpus/knowledge/unreal-mcp/gate/run_gate.sh
R=corpus/knowledge/unreal-mcp/gate/README.md

# §0 — the snapshot
sha256sum "$S" "$R"; bash "$S"

# §1.1 — A1-A4 landed, none documented
grep -n "tr ',-'" "$S"          # 306  A1 endpoint loop
grep -n 'LABEL_RE=' "$S"        # 212  A2 structural label rule
grep -n 'PINNED_CARD_NAMES=' "$S"  # 41  A3 name set
grep -n 'exit 2' "$S"           # 337  A4 third exit state
grep -c 'exit 2\|STEP=BLOCKED\|GATE_REF\|SEAT-09\|NAME_SET\|POINTER_STRINGS' "$R"   # 0

# §1.2 — pin contradiction + format drift
grep -o 'POINTERS=[0-9]*' "$R" | sort | uniq -c
grep -n 'POINTERS=%s' "$S"      # 327  now 4 fields

# §1.3 — exit codes
sed -n '156,157p' "$R"

# §1.4 — no SEAT-09 note
grep -c 'SEAT-09' "$R"          # 0

# §5 — drift
sed -n '31p;135p;161p;198p' "$R"
grep -c 'MANIFEST_FILES\|non-regular\|nested entry\|HARDENING' "$R"   # 0
```

## 8. Post-first-draft drift addendum (the implementation moved under this seat)

My first draft of this file recorded "A1 and A2 **not implemented**; A3 and A4 landed but
undocumented." That was correct at sha `510e186c…` and became wrong within minutes: SEAT-09 landed
**A1** (`tr ',-'` endpoint loop, `POINTER_STRINGS` token) and **A2** (structural `LABEL_RE`) while I
was writing. I re-measured everything and rewrote §1–§3 against `0c1ca3e1…`.

What this demonstrates, beyond the individual findings:

- **`POINTERS` moved 91 → 98** across that window (prose edits plus the A1 scanner change). Any
  numeric pin is stale the moment another seat writes.
- **The README's criteria findings were stable across all eight shas**: zero mentions of
  `exit 2`, `STEP=BLOCKED`, `GATE_REF`, `SEAT-09`, `NAME_SET`, or `POINTER_STRINGS` in every
  revision I read. The documentation gap did not narrow while the code advanced — it widened.
- **A folding seat must re-run §7 against the sha installed at fold time.** The specific line
  numbers here are bound to `0c1ca3e1…`; the structural findings held on every sha observed.

## 9. Limits of this file

- **No Unreal runtime claim anywhere.** The editor is not installed on this host; nothing here
  promotes an `unproven-runtime` card, and a green gate remains no evidence of live-editor behavior.
- **The README's C1–C7 matrix was not independently re-verified** — `/tmp` was quota-exhausted, so
  the documented throwaway-copy controls could not be run as written. My A1/A2/A3 controls (§3) were
  run on `$HOME`-resident mirrors instead.
- **`gate/README.md` and `gate/run_gate.sh` were not modified by this seat.** Any edit to them
  belongs to their owner.
- **The target moved** — eight script shas, several README revisions, and two finding flips during
  this seat's window. §8 records the drift; §0.1 pins the snapshot.
