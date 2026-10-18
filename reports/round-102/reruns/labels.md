# r102 · SEAT-36 · LABELSCAN-RERUN — 13-card verdict-label scan, re-implemented standalone

**Seat:** SEAT-36 (LABELSCAN-RERUN) · round 102 · lane `game-dev-3d-shokunin`
**Date:** 2026-10-18 · **HEAD at run time:** `2c99b7b`
**Target:** `corpus/knowledge/unreal-mcp/executability/*.md` — the 13 r101 subsystem verdict cards
**Purpose:** independent re-run of gate check 3 ("13-card label scan") for claim **C1 (coverage)**.
**Discipline:** read-only over the subtree. Nothing under `corpus/` was written by this seat.

---

## 0. What this seat did, and what it deliberately did not

The r101 protocol shipped its scanner as a heredoc inside
`reports/round-101/r101-verification-protocol.md` §0 (`label-scan.sh`). Re-running *that* file
would only prove the file is reproducible; it would not prove the **property** is scanner-independent.
So this seat wrote a **second, independent implementation** with a different decision rule, ran both,
and compared them. The scanner lives outside the repo (scratch) and is embedded verbatim below so
the check is self-contained and re-runnable without this seat's `/tmp`.

Only the 13 `executability/*.md` cards are in scope. `upstream/**` and `.manifest.d` are byte-pinned
and were not touched; the cards are not pinned, so their hashes are recorded in §4 as the pin for
this run.

---

## 1. The scanner (independent re-implementation)

```sh
# /tmp/r102-labelscan/label-scan-r102.sh   sha256 8f060f6b12ca94bf631e84afb43ac8eb769afb7f75fa17791491e0726c2b6da9
#!/usr/bin/env bash
# SEAT-36 / r102 — standalone 13-card verdict-label scan (independent re-implementation).
# Deliberately NOT a copy of reports/round-101/r101-verification-protocol.md's label-scan.sh.
#
# DECLARATION RULE (declared here, not guessed from the cards):
#   The DECLARED LABEL is the token on the first line, within the first 40 lines, that
#     (a) contains >=1 allowed token, and
#     (b) after stripping markdown decoration (#, *, `, |, :, spaces) is either a bare
#         heading or at most 8 words.
#   Condition (b) is what separates a DECLARATION ("**`static-only`**",
#   "**Verdict:** `static-only`") from PROSE that merely mentions a token
#   ("... is missing. That is `unproven-runtime` by the lane's own criterion").
#   The declaration line must then carry exactly ONE allowed token, be marked
#   (bold / heading / table cell), and be inside the card head.
# usage: label-scan-r102.sh [card_dir] [expected_cards]
set -u
root=${1:-corpus/knowledge/unreal-mcp/executability}
expected=${2:-13}
allowed='verified-here|static-only|unproven-runtime'

strip() { printf '%s' "$1" | sed -e 's/[#*`|]//g' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'; }

cards=$(find "$root" -maxdepth 1 -type f -name '*.md' | sort)
n=$(printf '%s\n' "$cards" | grep -c .)
bad=0; c_static=0; c_runtime=0; c_verified=0

printf '%-34s %-17s %-6s %s\n' CARD DECLARED LINE DETAIL
printf '%s\n' '-------------------------------------------------------------------------------'

while IFS= read -r f; do
  [ -z "$f" ] && continue
  b=$(basename "$f"); ln=0; text=""; tok=""
  while IFS= read -r rec; do
    rln=${rec%%:*}; rtext=${rec#*:}
    [ "$rln" -gt 40 ] && break
    stripped=$(strip "$rtext")
    words=$(printf '%s' "$stripped" | wc -w)
    if [ "$words" -le 8 ]; then ln=$rln; text=$rtext; tok=$(printf '%s' "$rtext" | grep -oE "$allowed" | head -1); break; fi
  done < <(grep -nE "$allowed" "$f")

  if [ -z "$tok" ]; then
    printf '%-34s %-17s %-6s %s\n' "$b" '(none)' '-' 'FAIL: no declaration line with a verdict token in head'
    bad=$((bad+1)); continue
  fi
  cnt=$(printf '%s' "$text" | grep -oE "$allowed" | wc -l)
  detail="ok"
  [ "$cnt" -ne 1 ] && { detail="FAIL: $cnt tokens on declaration line"; bad=$((bad+1)); }
  case "$text" in *'**'*|*'#'*|*'|'*) ;; *) detail="$detail; FAIL: unmarked declaration"; bad=$((bad+1));; esac
  case "$tok" in
    static-only) c_static=$((c_static+1));;
    unproven-runtime) c_runtime=$((c_runtime+1));;
    verified-here) c_verified=$((c_verified+1));;
    *) detail="$detail; FAIL: off-vocabulary"; bad=$((bad+1));;
  esac
  printf '%-34s %-17s %-6s %s\n' "$b" "$tok" "$ln" "$detail"
done <<< "$cards"

sum=$((c_static+c_runtime+c_verified))
printf '\nCARDS=%s EXPECTED=%s BAD=%s\n' "$n" "$expected" "$bad"
printf 'CENSUS static-only=%s unproven-runtime=%s verified-here=%s SUM=%s\n' "$c_static" "$c_runtime" "$c_verified" "$sum"
if [ "$c_verified" -ne 0 ]; then printf 'FAIL: verified-here declared, but no bounded run is possible (no editor on this host)\n'; bad=$((bad+1)); fi
if [ "$sum" -ne "$n" ]; then printf 'FAIL: census sum != card count\n'; bad=$((bad+1)); fi
if [ "$n" -eq "$expected" ] && [ "$bad" -eq 0 ]; then echo STEP=PASS; exit 0; else echo STEP=FAIL; exit 1; fi
```

Run:

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
bash /tmp/r102-labelscan/label-scan-r102.sh
```

---

## 2. Output — pasted verbatim

```
CARD                               DECLARED          LINE   DETAIL
-------------------------------------------------------------------------------
actors-scene.md                    unproven-runtime  5      ok
animation-controlrig.md            static-only       4      ok
assets-content.md                  static-only       15     ok
blueprints.md                      static-only       4      ok
editor-general.md                  static-only       4      ok
gameplay-gas.md                    static-only       4      ok
materials.md                       static-only       4      ok
meshes-textures.md                 static-only       4      ok
scripting-programmatic.md          static-only       5      ok
sequencer.md                       static-only       5      ok
testing-automation.md              static-only       5      ok
ui-umg-slate.md                    static-only       5      ok
vfx-niagara-dataflow.md            static-only       6      ok

CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 SUM=13
STEP=PASS
```

`EXIT=0`. Census **12 × `static-only`, 1 × `unproven-runtime`, 0 × `verified-here`** — identical to
the r101 report's C2 census (`reports/round-101/r101-report.md:45`), re-derived here by a different
rule. The one `unproven-runtime` is `actors-scene.md`; the other 12 are `static-only`.

Determinism: two consecutive runs diff clean (`diff -q` → `IDENTICAL`).

---

## 3. Cross-check against the r101 protocol scanner, and a real finding

The r101 scanner, run on the same tree, also passes:

```
OK   unproven-runtime actors-scene.md                line 5
OK   static-only      animation-controlrig.md        line 4
OK   static-only      assets-content.md              line 15
... (13 rows, same labels, same lines) ...
CARDS=13 EXPECTED=13 BAD=0
STEP=PASS
```

`EXIT=0`. Both scanners agree on all 13 labels **and** on the declaration line number for every card.
That agreement is the load-bearing result for C1: the label property is not an artifact of one script.

### 3a. Finding — the r101 rule is position-fragile; the r102 rule is not

The r101 rule is *"the first line that contains any allowed token"* (its own comment: "the DECLARED
LABEL is the token on the FIRST line of the card that contains any allowed token"). A prose sentence
that merely *mentions* a token, placed above the declaration, hijacks the rule. Control experiment:
insert `This card is emphatically not \`verified-here\`; nothing was observed.` at line 4 of
`editor-general.md` (in a scratch copy, not in the repo):

```
--- r102 scanner (strict declaration rule)
editor-general.md                  static-only       5      ok
CARDS=13 EXPECTED=13 BAD=0

--- r101 protocol scanner (first-token-wins rule)
FAIL label-unmarked /tmp/r102-labelscan/negctl2/editor-general.md :: This card is emphatically not `verified-here`; nothing was observed.
CARDS=13 EXPECTED=13 BAD=1
```

The r101 scanner reports a false **FAIL** on a tree that is in fact correctly labelled; the r102 rule
(declaration line = short, marked line) reads the card correctly. This is a latent calibration gap in
the r101 gate script, not a defect in any card: today no card happens to put prose above its
declaration, so the r101 scanner passes — by luck of layout, not by rule. **Recommendation for the
gate:** adopt the short-line declaration rule, or pin the rule as "first line matching
`(Label|Verdict)…:` **or** a line that is nothing but a bolded token".

### 3b. Finding — two cards use non-`Label:` declaration forms (not a defect)

A first draft of the r102 scanner used a `(Label|Verdict)[^A-Za-z]{0,6}[:|]` prefix requirement and
scored `BAD=2`:

```
assets-content.md                  (none)            -      FAIL: no declaration line with a verdict token
scripting-programmatic.md          (none)            -      FAIL: no declaration line with a verdict token
```

Both are in fact correctly labelled, and the failure was in the scanner's prefix requirement:

- `assets-content.md:15` → `**\`static-only\`**` — bare bolded token under a `## Verdict` heading
  (the heading is the label carrier; line 17 then states "exactly one label, and this is it").
- `scripting-programmatic.md:5` → `**Verdict label: \`static-only\`**` — `Verdict label:` wording.

So the corpus admits **three** declaration shapes: `**Label:** \`x\`` (10 cards),
`**Verdict:** \`x\`` (`ui-umg-slate.md`), and the two above. All three are unambiguous; the scanner
was narrowed, not the cards. Recorded here because a future gate that hard-codes `Label:` will
false-fail 2 of 13 cards.

---

## 4. Negative controls (the scanner can fail)

Every control is run on a scratch copy under `/tmp/r102-labelscan/negctl*`; the repo tree was not
mutated. `NC0` is the unmodified copy and establishes the control baseline.

| # | mutation | expected | observed | verdict |
|---|---|---|---|---|
| NC0 | none (unmodified copy of all 13) | PASS | `CARDS=13 … BAD=0` / `STEP=PASS` | baseline holds |
| NC1 | delete `sequencer.md` | FAIL | `CARDS=12 EXPECTED=13 BAD=0` / `STEP=FAIL` | catches a missing card |
| NC2 | `blueprints.md` label → `static only` (broken token) | FAIL | `blueprints.md (none) … no declaration line` / `BAD=1` | catches an unlabelled card |
| NC3 | `materials.md` line → ``**Label:** `static-only` or `verified-here` `` | FAIL | `materials.md static-only 4 FAIL: 2 tokens on declaration line` / `BAD=2` | catches a multi-label card |
| NC4 | `testing-automation.md` → ``**Label:** `verified-here` `` | FAIL | `FAIL: verified-here declared, but no bounded run is possible` / `BAD=2` | catches an impossible label |
| NC5 | `gameplay-gas.md` → unmarked `Label: static-only` | FAIL | `gameplay-gas.md static-only 4 ok; FAIL: unmarked declaration` / `BAD=3` | catches an unmarked declaration |
| NC6 | prose token above the declaration (§3a) | r102 PASS, r101 FAIL | see §3a | discriminates the two rules |

NC1–NC5 each move the exit code to 1, so the `STEP=PASS` in §2 is not vacuous. The card count
assertion (`n == 13`), the exactly-one-token assertion, the marked-declaration assertion, and the
no-`verified-here` assertion are each independently exercised by at least one control.

---

## 5. Card pin for this run

The 13 cards are not byte-pinned by the r101 subtree discipline, so the run is only reproducible
against this exact content. Card-dir digest:

```sh
sha256sum corpus/knowledge/unreal-mcp/executability/*.md | sha256sum
# 68244ffd4ef2f4281bc22277591633ea292dce7921292c8233fb9b6e4c3ee0ca  -
ls corpus/knowledge/unreal-mcp/executability | wc -l   # 13
```

Per-card (first 12 hex):

| card | sha256[:12] | card | sha256[:12] |
|---|---|---|---|
| `actors-scene.md` | `3bba50abff45` | `materials.md` | `f5d18a9848a0` |
| `animation-controlrig.md` | `2411f081a4f4` | `meshes-textures.md` | `7f33c3727ca5` |
| `assets-content.md` | `d612f03f99db` | `scripting-programmatic.md` | `83c129e502f6` |
| `blueprints.md` | `f971ee1e4c74` | `sequencer.md` | `8ca709e1bb6e` |
| `editor-general.md` | `c9451497384e` | `testing-automation.md` | `0a0c85f5f896` |
| `gameplay-gas.md` | `a56cb3110012` | `ui-umg-slate.md` | `d908779d0f51` |
| | | `vfx-niagara-dataflow.md` | `3eb044695511` |

---

## 6. Boundary — what this does not establish

- **No runtime claim.** `verified-here` count is 0 *because it must be*: the Unreal Editor is not
  installed on this host, so no card can carry a receipt of a bounded run. The scanner asserts this
  (`NC4`) rather than assuming it. Nothing here says anything about live MCP behavior, which is
  unproven by construction.
- **Labels are not re-derived from evidence.** The scanner proves *exactly one label is declared per
  card, from the allowed ternary, in the card head*. It does **not** verify that a card's label is
  the right one for that card's evidence — that is the card author's call and the subtree README
  says so explicitly (`corpus/knowledge/unreal-mcp/README.md:237`). The 12/1 split is a census, not
  an audit of correctness.
- **Gate check 3 only.** This is one of the four checks of `run_gate.sh` (that seat's artifact, not
  this one's). Passing here says nothing about the manifest sha256, path-set, or pointer-sweep checks.
- **`corpus/knowledge/unreal-mcp/README.md` is dirty** (`M`) at run time — modified by another seat
  (C1c). This seat did not touch it; the card set it indexes is unaffected, since the cards themselves
  are unmodified. `corpus/artifacts/unreal-r22/README.md` and `corpus/lessons/r22-unreal-review.md`
  are likewise other seats' dirty files.

---

## 7. Bottom line

**Gate check 3 (13-card label scan): PASS**, re-derived by an independently written scanner whose
rule differs from the r101 protocol's, on a tree pinned by digest in §5.
`CARDS=13 EXPECTED=13 BAD=0` · `CENSUS static-only=12 unproven-runtime=1 verified-here=0` · exit 0 ·
deterministic across runs · 5 of 6 negative controls flip it to FAIL.

Two calibration notes carried forward for the gate: (a) the r101 scanner's first-token-wins rule
false-FAILs on a correctly-labelled card if prose above the declaration mentions a token; (b) the
corpus uses three declaration shapes, so a gate that hard-codes a `Label:` prefix false-fails
`assets-content.md` and `scripting-programmatic.md`.
