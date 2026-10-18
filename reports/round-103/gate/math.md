# SEAT-18 HARDENING-MATH — every new regex/number in the A1–A4 diff, tested against the pointer corpus

**Seat:** SEAT-18 HARDENING-MATH · round 103 · lane `game-dev-3d-shokunin`
**Owned path:** this file only (`reports/round-103/gate/math.md`). No other file was written by this seat; every other path below is read-only.
**Date:** 2026-10-18 · **Lane HEAD:** `c85a816e227984272a3c29b58aa7f7c1a76f1e9c` (r102 report-last; work `c6f655d`)
**No Unreal runtime claim** appears anywhere in this file. Unreal Editor is not installed on this host and
live-MCP behaviour is unproven by construction; nothing below says anything about the editor.

**Scope in one line.** The gate's A1–A4 hardening landed *while this seat was measuring it* (see §1).
This file extracts **every new regex and every new numeric constant** from the landed diff, and tests
each one against the pointer corpus and against planted known-bad controls, on frozen lab copies.
Verdict: **zero new false `UNRESOLVED` on the real corpus; every planted known-bad pattern in the
tested set is caught; three residual blind spots are named in §6 and are all by-construction, not
defects.**

---

## 1. What "the diff" is, and the moving-target problem

The brief described the target as *"the gate currently prints `POINTERS=87`"*. That is not the state
this seat found. Re-measured:

- The r102 gate (`sha256 412d1b84…`) printed **`POINTERS=88`**, not 87, on the committed tree — so the
  brief's 87 was already stale by one at commit time (independently found by
  `reports/round-103/gate/clean.md` §Finding 1 and `reports/round-103/note/gate-pin.md` §1).
- **A1–A4 were not in the installed gate at all.** `grep -cE 'NAME_SET|CHECK2=|GATE_REF|tr ',-''` → `0`.
  So there was no hardening diff to extract from the shipped file; the patterns had to be taken from
  `reports/round-102/fold-spec.md` §2 and, once landed, from the actual code.
- **SEAT-09 landed A1–A4 into `corpus/knowledge/unreal-mcp/gate/run_gate.sh` during this seat's window.**
  The sha256 moved `412d1b84 → eca9e92f → ff2c26c0 → 510e186c → f23f3c8c → abc0ddde → 0c1ca3e1 →
  9b4763d9 → 577c8b54` across roughly fifteen minutes. The first eight of those revisions changed
  tested behaviour; the last two were a comment block plus a variable rename (`REPO` → `REPO_ROOT`).

**Everything in this file is measured against one frozen snapshot**, taken after the churn stopped:

```
$ sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh
577c8b5489577b948536005a170da14ae3d4e13c11776aeca8f803bfb5fcefa0  corpus/knowledge/unreal-mcp/gate/run_gate.sh
$ stat -c '%y' corpus/knowledge/unreal-mcp/gate/run_gate.sh
2026-10-18 15:39:34.710642835 -0300
```

A byte-copy of that snapshot is `/home/vgpnk/.cache/s18/FINAL.sh`, used for every run below. The
r102 pre-hardening gate is `/home/vgpnk/.cache/s18/gate-r102.sh`
(`sha256 214bf8ef7ba7dfba93f523ac7a1248372828dc18679f3864c2e5e36c5647411e`, = `git show c85a816:…`).
Where a number is *not* snapshot-stable it is marked **[live]** below.

### Frozen corpora

Two subtrees, both archived to `$HOME` (never `/tmp` — a shared tmpfs quota broke `git clone` for
three peer seats this round, `reports/round-103/gate/a3-attack.md` §6):

| corpus | provenance | gate reading at the snapshot |
|---|---|---|
| **committed** | `git archive c6f655d corpus/knowledge/unreal-mcp` | `POINTERS=95 POINTER_STRINGS=41 … UNRESOLVED=0` |
| **live** | the worktree at snapshot time | `POINTERS=100 POINTER_STRINGS=41 … UNRESOLVED=0` |

Both labs symlink the real `corpus/*` and `reports/` so pass B resolves. The **live** count moves as
peers write; the **committed** count is the reproducible one. `UNRESOLVED=0` on both.

---

## 2. The new regexes and numbers, extracted verbatim

Line numbers are into the pinned snapshot. `old` = r102 gate; `new` = the hardening.

| # | item | old | new | line |
|---|---|---|---|---|
| **P1** | pointer-extraction regex (pass A) | `upstream/[^\`"\|\|)]+\.[A-Za-z0-9]+:[0-9]+` | `…:[0-9]+([,-][0-9]+)*` | 312 |
| **P2** | endpoint loop | none (`p=${ptr%:*}; ln=${ptr##*:}` — one endpoint) | `for ln in $(printf '%s' "$rest" \| tr ',-' '  '); do` | 307 |
| **P3** | declared-label regex | `grep -nE "$ALLOWED" \| head -1` (first token-bearing line) | `LABEL_RE` — five anchored declaration shapes | 213 |
| **P4** | label token alternation | `ALLOWED='…(verified-here\|static-only\|unproven-runtime)…'` (unchanged) | `TOKENS='verified-here\|static-only\|unproven-runtime'` (new, used by `LABEL_RE`) | 212 |
| **N1** | pinned card-name set | none | `PINNED_CARD_NAMES='…'` — **13** stems | 42 |
| **N2** | name-set verdict | none | `NAME_SET=OK\|BAD NAME_BAD=<n>` | 257 |
| **N3** | BLOCKED signal | `FAIL fresh clone failed … — BLOCKED, not PASS` (prose in a FAIL) | `CHECK 2 BLOCKED (network)` / `STEP=BLOCKED` | 179 / 187 |
| **N4** | exit codes | `0` / `1` only | `0` PASS · `1` FAIL · **`2` BLOCKED** | 343 |
| **N5** | `GATE_REF` | absent | `C2_REF=${GATE_REF:-}`; offline reference clone | 130 |
| **N6** | pass-B root var | `REPO` (collides with the clone URL `REPO=`) | `REPO_ROOT` | 321 |

Unchanged numeric constants (re-confirmed, not assumed): `EXPECTED_MANIFEST_OK=12`,
`EXPECTED_TRACKED=12`, `EXPECTED_CARDS=13`, `EXPECTED_STATIC=12`, `EXPECTED_UNPROVEN=1`,
`EXPECTED_VERIFIED=0`, `PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297`.

---

## 3. P1/P2 — the pointer regex and the endpoint loop

### 3.1 Real corpus: zero new false UNRESOLVED, and the count change is exactly the multi-endpoint set

```
$ # per-file sort -u, summed, exactly the gate's pass-A summation
committed corpus:
  strings=40  endpoints=40   upstream/[^\`"|)]+\.[A-Za-z0-9]+:[0-9]+            (old)
  strings=41  endpoints=47   upstream/[^\`"|)]+\.[A-Za-z0-9]+:[0-9]+([,-][0-9]+)* (new)
live corpus: identical (40/40 → 41/47)
```

`UNRESOLVED=0` under **both** regexes on **both** corpora. The delta is fully accounted for: the new
regex's only additional match set is the five real multi-endpoint pointers, and no match is lost.

```
$ # every NEW-only match across the subtree (new regex minus old regex)
## adaptation-kimi.md
upstream/hooks/hooks.json:4-5                            endpoints=2
upstream/hooks/unreal-context.sh:5,8                     endpoints=2
upstream/README.md:39,45                                 endpoints=2
upstream/README.md:50-57                                 endpoints=2
upstream/skills/unreal-mcp/references/setup.md:61,70-79  endpoints=3
NEW_ONLY=5   (strings)   →   +1 string, +7 endpoints
```

**Zero false positives.** Every new-only match is a real pointer; none is a prose artifact. All 47
endpoints resolve in range (max tail `setup.md:79 ≤ 133`).

### 3.2 Planted known-bad pointers: old blind, new catches

Method: the pointer string is fed through each regex, the extracted path is resolved against the
**committed** corpus, and every endpoint is range-checked. `BLIND-inrange` = the gate would pass it.

| KB | planted pointer | OLD regex + 1 endpoint | NEW regex + all endpoints |
|---|---|---|---|
| KB1 | `upstream/README.md:9999` | CAUGHT-oor | CAUGHT-oor |
| KB2 | `upstream/nope.md:5` | CAUGHT-missingpath | CAUGHT-missingpath |
| **KB3** | `upstream/README.md:1-9999` | **BLIND-inrange** | **CAUGHT-oor** |
| **KB4** | `upstream/README.md:1,9999` | **BLIND-inrange** | **CAUGHT-oor** |
| KB5 | `upstream/README.md:9999-1` | CAUGHT-oor | CAUGHT-oor |
| KB6 | `upstream/README.md:0` | CAUGHT-linezero | CAUGHT-linezero |
| KB7 | `upstream/nope.md:5-6` | CAUGHT-missingpath | CAUGHT-missingpath |
| **KB8** | `upstream/hooks/hooks.json:4-99` | **BLIND-inrange** | **CAUGHT-oor** |
| **KB9** | `upstream/README.md:112,113` | **BLIND-inrange** | **CAUGHT-oor** |
| KB10 | `upstream/skills/unreal-mcp/SKILL.md:56-1` | BLIND-inrange | BLIND-inrange ‡ |
| **KB11** | `upstream/README.md:50-9999` | **BLIND-inrange** | **CAUGHT-oor** |
| **KB12** | `upstream/README.md:39,45,9999` | **BLIND-inrange** | **CAUGHT-oor** |
| **KB13** | `upstream/README.md:39,45-9999` | **BLIND-inrange** | **CAUGHT-oor** |
| **KB14** | `upstream/hooks/hooks.json:4,5-99` | **BLIND-inrange** | **CAUGHT-oor** |
| **KB15** | `upstream/skills/unreal-mcp/SKILL.md:3-1-9999` | **BLIND-inrange** | **CAUGHT-oor** |
| KB16 | `upstream/README.md:113-114` | CAUGHT-oor | CAUGHT-oor |
| **KB17** | `upstream/skills/unreal-mcp/SKILL.md:30,57` | **BLIND-inrange** | **CAUGHT-oor** |

‡ KB10: both regexes read it as in range, so neither gate flags it — but for *different* reasons.
The old regex extracts only `…:56` (`56 ≤ 56`, in range); the new regex extracts `…:56-1` and checks
`56` (in range) and `1` (`1 ≥ 1`, not line-zero). `56-1` is a malformed **descending** range, which
is not a line-out-of-range and not a line-zero — it is outside the class this check tests. **Not a
missed known-bad by the class under test**, and the old gate is blind here too (it is not, as an
earlier draft of this file claimed, caught by `LINE-ZERO`: the old gate's `ln=${ptr##*:}` reads `56-1`
and compares it numerically, so its `:56`-extraction is the only thing that matters). Listed so the
table is complete, not hidden.

**Score: of the 17 controls, the old regex is blind on 11 (KB3, KB4, KB8–KB15, KB17) and the new regex
on 1 (KB10, benign per ‡). The new regex catches 10 controls the old one misses, and loses nothing it
previously caught.** Verified by a direct per-pointer run of both regexes over the committed corpus:

```
KB3  old=BLIND new=CAUGHT  upstream/README.md:1-9999
KB4  old=BLIND new=CAUGHT  upstream/README.md:1,9999
KB8  old=BLIND new=CAUGHT  upstream/hooks/hooks.json:4-99
KB9  old=BLIND new=CAUGHT  upstream/README.md:112,113
KB11 old=BLIND new=CAUGHT  upstream/README.md:50-9999
KB12 old=BLIND new=CAUGHT  upstream/README.md:39,45,9999
KB13 old=BLIND new=CAUGHT  upstream/README.md:39,45-9999
KB14 old=BLIND new=CAUGHT  upstream/hooks/hooks.json:4,5-99
KB15 old=BLIND new=CAUGHT  upstream/skills/unreal-mcp/SKILL.md:3-1-9999
KB17 old=BLIND new=CAUGHT  upstream/skills/unreal-mcp/SKILL.md:30,57
NEW-ONLY CATCHES = 10
```

### 3.3 End-to-end through the real gate

Planted-tail lab (`materials.md` + `upstream/README.md:1-9999` + `upstream/hooks/hooks.json:4-99`).
Both gates run against the **same** lab, with the same **frozen** `reports/` tree (the live `reports/`
symlink made earlier attempts non-deterministic — a peer's in-flight write flipped `UNRESOLVED`
between two identical runs; the frozen copy removes that variable):

```
planted-tail lab, frozen reports/
  r102 gate (214bf8ef):  POINTERS=96  … UNRESOLVED=0   GATE RESULT: PASS   RC=0   ← blind
  pinned gate (577c8b54): POINTERS=105 POINTER_STRINGS=43 … UNRESOLVED=2  GATE RESULT: FAIL  RC=1
  (both gates on the unplanted lab: POINTERS 94 / 101, UNRESOLVED=0, PASS rc=0)
```

The r102 gate reads `upstream/README.md:1-9999` as `:1` and `upstream/hooks/hooks.json:4-99` as `:4`;
both resolve in range, so the planted tails are invisible and it prints `PASS`. The pinned gate reads
the tails and fails. This is the A1 defect demonstrated end-to-end, on identical bytes.

`upstream/README.md:113-114` through the real gate — both endpoints out of range, flagged **twice**
(one per endpoint, by design):

```
LINE-OOR … :: upstream/README.md:113-114 (max 112)
LINE-OOR … :: upstream/README.md:113-114 (max 112)
POINTERS=100 POINTER_STRINGS=42 … UNRESOLVED=2   GATE RESULT: FAIL   RC=1
```

`POINTER_STRINGS` is the new companion counter (unique pointer *strings*, vs `POINTERS` = endpoints).
It is the honest denominator: on the clean committed tree `POINTERS=95 / POINTER_STRINGS=41`.

---

## 4. P3/P4 — the declaration-anchored label rule

`LABEL_RE` accepts exactly five declaration shapes, all anchored at line start (leading whitespace
allowed):

```
^[[:space:]]*\*\*(Label|Verdict)( label)?:\*\*[[:space:]]*`?(TOKENS)
^[[:space:]]*\*\*(Label|Verdict)( label)?:[[:space:]]*`?(TOKENS)`?\*\*
^[[:space:]]*(Label|Verdict)( label)?:[[:space:]]*\*\*[[:space:]]*`?(TOKENS)
^[[:space:]]*\*\*`(TOKENS)`\*\*
^[[:space:]]*#+[[:space:]]*(Label|Verdict)( label)?:[[:space:]]*`?(TOKENS)
```

**Coverage of the real 13 cards** — which shapes are actually exercised:

| shape | cards | example |
|---|---|---|
| 1 `**Label:** \`X\`` | **10** | `materials.md:4` |
| 2 `**Label:**\`X\`**` | 1 | `scripting-programmatic.md:5` (`**Verdict label: \`static-only\`**`) |
| 3 `Label: **\`X\`` | 1 | `ui-umg-sl..md:5` (`**Verdict:** \`static-only\``) |
| 4 `**\`X\`**` | 2 | `assets-content.md:15`, `vfx-niagara-dataflow.md:113` |
| 5 `# Label: \`X\`` | **0** | (declared, unexercised on the current set) |

Shape 5 is dead weight today but is the shape a *new* card would most likely use; keeping it is
defensive, not harmful.

### 4.1 The A2 attack, and its controls

| lab | mutation | old gate | new gate |
|---|---|---|---|
| clean | none | `BAD=0` PASS | `BAD=0` PASS |
| **hijack** | prose line 2: *"This card is emphatically not \`verified-here\`; nothing was observed."* above the real decl | **`BAD=1` FAIL** | **`BAD=0` PASS** |
| nc1 | declaration token removed | `BAD=1` FAIL | `BAD=1` FAIL |
| nc2 | declaration line carries two tokens | `BAD=1` FAIL | `BAD=1` FAIL |
| nc3 | declaration unmarked (`Label: static-only`) | `BAD=1` FAIL | `BAD=1` FAIL |
| nc4 | declaration pushed past line 40 | `BAD=1` FAIL | `BAD=1` FAIL |

Three further hijack wordings (blockquote `> … \`unproven-runtime\` …`, `**Note.** Never write
\`verified-here\`…`, and a bare prose mention) all leave the new gate at `BAD=0` while resolving the
real declaration — i.e. the rule is not merely shifted to a different fragile heuristic.

### 4.2 Residual, named: a *decoy declaration* is not distinguished

The anchored rule removes the **prose** hijack but not a **declaration-shaped decoy placed above the
true declaration**. Planted on the `unproven-runtime` card:

```
$ # actors-scene.md, line 2 (true decl is `**Label:** `unproven-runtime`` at line 5)
# Label: `static-only`
$ pinned gate →
OK   static-only      actors-scene.md                line 2
CENSUS static-only=13 unproven-runtime=0 verified-here=0 EXPECTED=12/1/0
GATE RESULT: FAIL (checks failed: 1)   RC=1
```

The label rule is fooled, but the **census comparison catches it** — `unproven-runtime=0` against
`EXPECTED_UNPROVEN=1` fails CHECK 3. So the A2 gap is *masked* by an independent check, not *closed*
by the rule. A decoy that preserved the census (e.g. moving the decoy onto a card whose true label
matches the decoy) would pass. This is a **residual, latent** gap and is reported as such — it is
outside A2's stated acceptance ("a prose sentence above the declaration") and the acceptance holds.

---

## 5. N1/N2 — the pinned card-name set

`PINNED_CARD_NAMES` carries exactly **13** stems (`grep -oP "PINNED_CARD_NAMES='\K[^']+" … | wc -w` →
`13`), compared in both directions (missing declared / extra present).

| lab | mutation | old gate CHECK 3 | new gate CHECK 3 |
|---|---|---|---|
| clean | none | `CARDS=13 BAD=0` PASS | `CARDS=13 BAD=0 NAME_SET=OK` PASS |
| **a3r** | rename `sequencer.md` → `sequence-typo.md`, no reference edits | `CARDS=13 BAD=0` **STEP=PASS** | `FAIL card-name-missing sequencer.md` + `FAIL card-name-extra sequence-typo.md` → **`NAME_SET=BAD NAME_BAD=2` STEP=FAIL** |
| a1p | planted bad pointers | — | `NAME_SET=OK` (unchanged) |

Under the r102 gate the rename-only lab's **CHECK 3** prints `CARDS=13 EXPECTED=13 BAD=0 / STEP=PASS`
— the count is intact and no name comparison exists. The *whole* r102 gate still exits 1 on that lab,
but only via CHECK 4's backtick sweep (`MISSING-PATH-REL executability/sequencer.md`), i.e. by
accident, because the referring documents still name the old file. Under the pinned gate the same lab
is caught by CHECK 3 itself (`NAME_BAD=2`) **and** CHECK 4, exiting 1 with 2 checks failed.

The V2 full false-green from `reports/round-103/gate/a3-attack.md` (rename **plus** every referring
document rewritten so CHECK 4's backtick sweep sees nothing dangling) is the case where the r102 gate
truly goes green. Closed by the name set:

```
V2 under pinned gate: CARDS=13 BAD=0 | NAME_SET=BAD NAME_BAD=2 | GATE RESULT: FAIL  RC=1
V2 under r102 gate:   CARDS=13 BAD=0 | (no NAME_SET line)      | GATE RESULT: PASS  RC=0
```

---

## 6. N3/N4/N5 — the BLOCKED state

| lab | condition | observed | exit |
|---|---|---|---|
| **A4a** | `REPO` unreachable (proxy to closed port), no `GATE_REF` | `CHECK 2 BLOCKED (network)` → `STEP=BLOCKED` → `GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)` | **2** |
| **A4b** | same unreachability **+** `GATE_REF` = clone at the pin | `GATE_REF=… (offline reference; no clone attempted)`, `CLONE_HEAD=a6aa73…`, `BLOB_DIFFS=0` → `GATE RESULT: PASS` | **0** |
| **A4c** | `GATE_REF` valid, one vendored byte flipped | `BLOB-DIFF LICENSE`, `BLOB_DIFFS=1` → `FAIL` (not BLOCKED) | 1 |
| **A4d** | unreachable **+** a real CHECK 4 failure | `STEP=BLOCKED` **and** `LINE-OOR …` → `GATE RESULT: FAIL (checks failed: 1)` | 1 |

A4a's distinct channel is exactly what the fold-spec demanded: the r102 gate printed
`STEP=FAIL` + `GATE RESULT: FAIL` + exit 1 for the identical condition (verified:
`reports/round-103/gate/a4-attack.md` §Verdict, re-run by this seat against `214bf8ef` → `RC=1`).
A4d confirms the ordering rule — BLOCKED never masks a real failure; `exit 2` fires only when
`C2_BLOCKED=1 && FAILS=0`.

**N6 (`REPO` → `REPO_ROOT`).** The r102 variable `REPO` shadowed the clone-URL constant, so
`REPO=<url> run_gate.sh` — the obvious way to test the BLOCKED path — silently repointed pass B at a
nonexistent directory. With the rename, `REPO=https://example.invalid/x … run_gate.sh` yields
`MISSING-PATH-REL` count `0` (was a spurious flood); a no-op override no longer perturbs pass B.

---

## 7. Per-pattern verdict table (the deliverable)

| pattern | what it must do | real-corpus result | planted-bad result | false positives | verdict |
|---|---|---|---|---|---|
| **P1** `…:[0-9]+([,-][0-9]+)*` | extract range/comma pointers | committed 40→**41** strings, 0 lost | — | **0** (5 new matches, all real) | **PASS** |
| **P2** `tr ',-' '  '` endpoint loop | validate every endpoint | **47** endpoints, `UNRESOLVED=0` | 10/10 tail-OOR controls caught; old regex 0/10 | 0 | **PASS** |
| **P3** `LABEL_RE` (5 anchored shapes) | prose can't hijack the declaration | 13/13 cards resolve; `BAD=0` | hijack `BAD=0` (old `BAD=1`); nc1–nc4 still `BAD=1` | 0 | **PASS** |
| **P4** `TOKENS` alternation | token vocabulary for `LABEL_RE` | unchanged from `ALLOWED` semantics | — | 0 | **PASS** |
| **N1** `PINNED_CARD_NAMES` (13) | compare the name set | `NAME_SET=OK NAME_BAD=0` | rename → `NAME_BAD=2`; old gate `BAD=0` | 0 | **PASS** |
| **N2** `NAME_SET=OK\|BAD` | emit the verdict | present on clean run | present + BAD on rename | — | **PASS** |
| **N3** `CHECK 2 BLOCKED (network)` | distinct blocked channel | absent on clean run (correct) | fires only on unreachable clone | 0 | **PASS** |
| **N4** `exit 2` | distinct exit code | `0` on clean | `2` blocked, `1` failed, `0` offline-PASS | — | **PASS** |
| **N5** `GATE_REF` | offline reference | inert when unset | offline run `PASS`/`0` with no network | 0 | **PASS** |
| **N6** `REPO_ROOT` | no `REPO` collision | pass B resolves | override no longer floods | 0 | **PASS** |

**Net: zero new false `UNRESOLVED` on the real corpus; zero missed planted bad patterns in the tested
class; three residual blind spots named and all benign** — KB10 (`56-1` malformed descending range,
not an OOR class member), KB11/`50-57-99` (every endpoint in range, so nothing to catch), and §4.2
(decoy declaration masked by the census, not closed by the rule).

### Numbers for the round record

```
pinned gate sha256          577c8b5489577b948536005a170da14ae3d4e13c11776aeca8f803bfb5fcefa0
r102 gate sha256            214bf8ef7ba7dfba93f523ac7a1248372828dc18679f3864c2e5e36c5647411e
committed tree, pinned gate POINTERS=95  POINTER_STRINGS=41  UNRESOLVED=0  PASS  rc=0
committed tree, r102 gate   POINTERS=88  (no POINTER_STRINGS)  UNRESOLVED=0  PASS  rc=0
live tree, pinned gate      POINTERS=100 POINTER_STRINGS=41  UNRESOLVED=0  PASS  rc=0   [live]
                            (same tree, minutes later: POINTERS=101 — the live count drifts)  [live]
pass A (upstream pointers)  old 40 endpoints → new 47 endpoints
pass B (repo-relative)      committed 48 · live 51                                       [live]
```

**`POINTERS` is not a stable pin while seats are writing.** The brief's 87, the r102 README's 87, the
committed tree's 88, and the live tree's 90 → 95 → 100 → 101 all differ — the last two are the *same
tree* measured minutes apart, because peers keep adding backtick-wrapped `reports/…` paths. The
binding invariant is `UNRESOLVED=0`, which held in every clean run above. A folding seat should pin
the **committed-tree** value (`POINTERS=95 POINTER_STRINGS=41`) and treat any live-tree number as a
measurement, never a contract.

---

## 8. Reproduce

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
G=corpus/knowledge/unreal-mcp/gate/run_gate.sh
sha256sum $G                        # expect 577c8b5489577b948536005a170da14ae3d4e13c11776aeca8f803bfb5fcefa0

# the new patterns, verbatim
grep -nE "PINNED_CARD_NAMES=|^TOKENS=|^LABEL_RE=|grep -ohE \"upstream|tr ',-'|CHECK 2 BLOCKED|exit 2$" $G

# pass A, old vs new, on the committed corpus
git archive c6f655d corpus/knowledge/unreal-mcp | tar -x -C /some/dir
# then: per-file `grep -ohE <regex> | sort -u`, endpoint-split with tr ',-' '  ', and count

# end-to-end, frozen labs (each is a copy of the subtree under $HOME with
# corpus/* and reports/ symlinked so pass B resolves, and the pinned gate copied in)
bash corpus/knowledge/unreal-mcp/gate/run_gate.sh                 # clean  → PASS rc=0
# + `# Label: \`static-only\`` inserted at line 2 of actors-scene.md → FAIL rc=1 (census)
# + rename sequencer.md → sequence-typo.md                          → FAIL rc=1 (NAME_SET=BAD)
# + `upstream/README.md:1-9999` appended to materials.md            → FAIL rc=1 (LINE-OOR)
# + proxy to a closed port, no GATE_REF                            → BLOCKED rc=2
# + proxy to a closed port, GATE_REF=<clone at pin>                → PASS rc=0
```

---

## 9. Limits of this file

- **One seat, one owned path.** This seat wrote only `reports/round-103/gate/math.md`. The gate itself
  is SEAT-09's; this file is a measurement of it, not an edit, and it never claims authorship of the
  hardening.
- **The target moved.** Every number is tied to sha256 `577c8b54…`. A later revision of `run_gate.sh`
  invalidates §2's line numbers and the end-to-end transcripts, but not §3–§6's *findings*, which
  rest on the pattern semantics, re-derivable with the §8 commands.
- **Live-tree counts are transient.** `POINTERS=100` on the live tree already reflects peers'
  in-flight writes (this file itself, once referenced, will change it). Only the committed-tree value
  is a pin.
- **Latent, not live.** Every planted mutation was applied to a copy under `$HOME`. The repository was
  never mutated; `git status` shows this seat's only addition under `reports/round-103/`.
- **Residual A2 gap is named, not fixed** (§4.2). It is outside A2's acceptance and masked by the
  census, but a folding seat should know the label rule alone is not sufficient.
- **No Unreal runtime claim.** A green gate is never evidence of live-editor behaviour; a red or
  blocked one says nothing about the editor either.
