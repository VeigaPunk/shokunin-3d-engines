# SEAT-47 REVIEW — adversarial depth hunt over the C2 executability cards

**Round:** r101 · **Lane:** game-dev-3d shokunin · **Seat:** SEAT-47 REVIEW
**Axis served:** depth (C2) — adversarial audit of the 13 subsystem verdict cards
**Target:** `corpus/knowledge/unreal-mcp/executability/*.md`
**Upstream pin:** `a6aa73ada02a9fb1f5415bec491f9942c519b297`
**Date:** 2026-10-18

This seat's single write is this file. No commit was made (the L1 lands the round commit).

---

## Verdict up front

**The C2 card set passes its central adversarial test: no card asserts runtime
behaviour as proven.** Across all 13 cards, 23 sentences carry a runtime predicate
in the card's own prose; every one of them, read in context, is a *host-side*
receipt (`grep` returning empty, `git ls-remote` failing, `which` finding nothing)
or a prose fragment. Zero are claims that Unreal executed.

Two defects were found, neither an overclaim:

1. **One stale pointer citation** — `meshes-textures.md:254` cites two lane-index
   line ranges that do not contain what it says they contain. **Major for
   calibration**, because the lane's own evidence standard is "every row carries a
   resolvable source pointer", and these two pointers resolve to the wrong bytes.
   Re-verified against the card's final bytes (written `14:18:46`); the defect
   persists at line 254.
2. **One label divergence, already self-declared** — `actors-scene.md` alone
   carries `unproven-runtime` where the other 12 carry `static-only`. The card
   argues this explicitly and flags the tension for the adjudicator. Recorded, not
   scored against it.

**Caveat on card churn.** The 13 cards were authored concurrently by other seats
and kept changing during this audit (writes observed `14:15:35`–`14:20:23`, after
this seat's first reads; `assets-content.md` and `actors-scene.md` were still being
amended when this report was written). Every count below is against the card bytes
as of `2026-10-18T14:20:30-03:00`; line numbers drift as siblings amend. The verdict
is stable across four full re-runs (22 → 23 flagged, the delta being one added
negation in `editor-general.md:9`): card count 13, label census unchanged
(12 `static-only` + 1 `unproven-runtime`), zero first-person execution claims, and
F1 confirmed present in `meshes-textures.md`'s current bytes.

**Verdict: PASS with one calibration defect to fix.** C2's depth claim (13 cards,
each labeled exactly one permitted value, each with evidence) holds; the label
vocabulary is used honestly and the "why not the other two labels" sections are
present in every card.

---

## 1. Method

### 1.1 The hunt, stated precisely

The brief was to scan every `executability/*.md` card for any sentence asserting
runtime behaviour as proven, cite it `file:line`, and give a verdict. A naive
keyword grep is useless here: these cards *quote* upstream runtime claims
constantly (e.g. `SKILL.md:33`'s "many tools return a status that flips between
success and failure"), and a card quoting a vendor's warning is not overclaiming.
The detector therefore had to separate the **card's own voice** from quoted
evidence before matching.

`/tmp/seat47_overclaim.py` implements that separation:

- **Join** wrapped Markdown prose into paragraphs (recording the paragraph's first
  line number), so a sentence split across two source lines is matched whole.
- **Exclude before matching:** headings, table rows (`|`), blockquote lines (`>`),
  fenced code blocks, bold meta-label lines, and any line containing two or more
  `"` (a verbatim upstream quotation).
- **Match** the card's own prose against a tight runtime-predicate list
  (`returns`, `rejects`, `fails`, `succeeds`, `works`, `hangs`, `exits`,
  `launches`, `runs`, `executes`, `completes`, `emits`, `registers`, `loads`,
  `crashes`, `serves`, `blocks`, `ignores`, `is callable`, `silently`, `actually`,
  `no exception`, `flips between`, `success and failure`).
- **Defuse** any sentence carrying a label token, a `[O]`/`[I]`/`[?]` tag, a
  negation, a modal, a conditional, an attribution, a hedge, or a requirement
  verb — those are scoped statements, not overclaims.

Detector run (all 13 cards):

```
$ python3 /tmp/seat47_overclaim.py corpus/knowledge/unreal-mcp/executability/*.md
### .../actors-scene.md
flagged_sentences=0
### .../animation-controlrig.md
flagged_sentences=1
### .../assets-content.md
flagged_sentences=2
### .../blueprints.md
flagged_sentences=2
### .../editor-general.md
flagged_sentences=2
### .../gameplay-gas.md
flagged_sentences=1
### .../materials.md
flagged_sentences=3
### .../meshes-textures.md
flagged_sentences=3
### .../scripting-programmatic.md
flagged_sentences=1
### .../sequencer.md
flagged_sentences=2
### .../testing-automation.md
flagged_sentences=2
### .../ui-umg-slate.md
flagged_sentences=3
### .../vfx-niagara-dataflow.md
flagged_sentences=0
TOTAL_FLAGGED=22
```

Re-run against the cards' final bytes at `14:19:18` gives `TOTAL_FLAGGED=23`; the
one added hit is `editor-general.md:9` "no Editor tool **was ever executed**,
because no Unreal Editor exists on this host" — a negation, added by that card's
author after this seat's first pass. The verdict is unchanged across both runs.

### 1.2 Independent confirmation, three ways

Because a clean result from one detector is weak evidence, the hunt was re-run
three more ways:

**(a) Strict mode** — only label tokens and confidence tags defuse; no hedges, no
attribution. This deliberately over-flags. Result: 39 hits, all inspected, all
benign. Representative false positives and why they are not overclaims:

| flagged | actually |
|---|---|
| `blueprints.md:18` "Command **actually run**, from …" | a receipt caption; the predicate is the card asserting it *ran a grep* |
| `meshes-textures.md:146` "Filtering the list for … **returns empty**" | `grep` returning empty — a host fact |
| `testing-automation.md:256` "the upstream **measures** ~30 s of startup" | attributed to upstream, and `[O]`-tagged |
| `scripting-programmatic.md:86` "`execute_tool_script` **executes** arbitrary Python" | a verbatim `README.md:90` quotation, pointer given |
| `editor-general.md:210` "**returns empty** unless the Claude Code tab is docked" | quoted `operations.md:50`, and marked `[I]` |

**(b) Reverse hunt** — the failure mode a keyword scan misses is *hedged language
hiding an assertion*. Searched for the strongest proof verbs and read every hit in
context:

```
$ grep -nE '\b(we (ran|verified|measured|observed|confirmed|executed)|was (verified|measured|observed|confirmed|executed)|is (verified|proven)|has been (verified|measured|observed|confirmed|executed))\b' *.md
```

Every hit is a *negation* ("nothing in this card was observed executing",
"no Blueprint tool has been executed on this host, and none can be") or a
file-level claim ("clone verified in place", "byte-identity verified this seat").
There is not one first-person execution claim:

```
$ grep -cE '\bwe (ran|executed|called|invoked|observed|measured|verified)\b' *.md | grep -v ':0'
(none)
```

**(c) Table rows** — the detector excludes `|` lines, so a runtime claim could
hide in a table. Checked separately:

```
$ grep -nE '^\|' *.md | grep -iE '\b(returns|rejects|fails|works|hangs|exits|launches|executes|emits|registers|crashes|silently)\b' \
  | grep -viE 'static-only|unproven-runtime|verified-here|\[O\]|\[I\]|\[\?\]|unknown|would|could|require|never| not | no |command|observed|quoted|claim|documented|upstream|receipt|must|expect|plausib'
blueprints.md:87:| F20 | `AIAssistantToolset.GetDockedContext` returns empty unless the Claude Code tab is **docked inside an asset editor** … | `references/operations.md:50` |
```

One row survives, and it is a pointer-anchored quotation of `operations.md:50`
carrying `unless` — a conditional, not a claim.

### 1.3 The one phrase that looked like an overclaim, and is not

`ui-umg-slate.md:355` reads: "No widget creation, no asset mutation, until the
read-only round-trip **is proven**." Read alone this looks like an assertion that
something was proven. In context it is the third step of a *prospective* probe
plan ("The first bounded probe to run once unlocked"), and the sentence is
conditional on a future event. Not an overclaim.

---

## 2. Label audit — the required vocabulary is used, exactly once per card

C2 requires each card labeled **exactly one** of `verified-here` |
`static-only` | `unproven-runtime`. Every card declares its label in its header:

```
$ ls corpus/knowledge/unreal-mcp/executability/*.md | wc -l
13
$ for f in *.md; do printf '%s %s\n' "$(grep -m1 -oE '(static-only|unproven-runtime|verified-here)' $f)" "$f"; done | sort
static-only actors-content.md
static-only animation-controlrig.md
static-only blueprints.md
static-only editor-general.md
static-only gameplay-gas.md
static-only materials.md
static-only meshes-textures.md
static-only scripting-programmatic.md
static-only sequencer.md
static-only testing-automation.md
static-only ui-umg-slate.md
static-only vfx-niagara-dataflow.md
unproven-runtime actors-scene.md
```

12 × `static-only`, 1 × `unproven-runtime`, 0 × `verified-here`. No card is
unlabeled and no card carries two competing labels.

**Why zero `verified-here` is correct, not a gap.** `verified-here` means a
bounded run of the subsystem happened on this host with a saved receipt. The
host has no Unreal Editor (see §4), so no subsystem card *can* carry it. The
`verified-here` occurrences that do appear are all either (a) explicitly
file-level — pinned-SHA identity, the 12-file hash set — or (b) inside a "why not
`verified-here`" argument. Both are correct uses. `assets-content.md:26` states
the distinction outright: "`verified-here` — but these are claims about the
*artifact*, not about the subsystem's behaviour".

### 2.1 The `actors-scene.md` divergence — recorded, not penalized

`actors-scene.md:4` labels `unproven-runtime`; the other 12 label `static-only`.
This is the only genuine calibration disagreement in the set, and the card
pre-empts it rather than hiding it:

- `actors-scene.md:275-281` — "**Why `unproven-runtime` rather than
  `static-only`:** the two labels differ on whether a real runtime path is
  *identified*. Here it is: the transport, the three meta-tools, the `call_tool`
  argument shape, the endpoint, and the plugin prerequisites are all specified."
- `actors-scene.md:286` — flags the tension explicitly: "**Residual tension,
  recorded for the adjudicator:** the sibling card `executability/blueprints.md`
  chose `static-only` on the reasoning that its *tool surface* is unspecified, and
  this card's §2.4 shows the same gap here … If a later round prefers that stricter
  test, the tool-surface section of this card would qualify as `static-only` while
  the capability set would remain `unproven-runtime`."

The lane index backs the card's authority to choose: `README.md:236-239` states
"A card's label is set by that card's author from that card's own evidence …
Neither the expectation nor this index overrides the card." So the divergence is
permitted, argued, and disclosed. **This seat does not score it as a defect**; it
is the one point the adjudicator may wish to rule on for set-wide consistency.

---

## 3. Pointer audit — the standard the lane actually claims

The lane's evidence standard is that every row carries a **resolvable source
pointer**. Two independent checks were run.

### 3.1 Do the cards' pointers resolve to in-range lines?

Parsed every `` `path:line` `` citation in all 13 cards (upstream-relative and
lane-index-relative), and checked each target file exists and the cited line is
within its length. After resolving the `references/*.md` → `skills/unreal-mcp/references/*.md`
and bare-`README.md` → lane-index ambiguities correctly:

```
TOTAL_UNRESOLVABLE= 0
```

Every one of the ~200 pointers in the card set resolves to a real file at a real
line number.

### 3.2 Do the cards' **quoted** strings sit at the lines they cite?

Resolution in range is necessary but not sufficient — a pointer can resolve to the
wrong bytes. Checked the specific case where a card quotes a lane-index string
with a line citation. **One card fails:**

```
$ sed -n '254p' corpus/knowledge/unreal-mcp/executability/meshes-textures.md
`corpus/knowledge/unreal-mcp/README.md:195-209` lists this card as row 5 (`executability/meshes-textures.md`) with its subsystem description. That table deliberately carries **no** verdict column — the index states at `README.md:189-192`: "This index does **not** restate the labels: the binding verdict and its evidence live in each card, and only the card is authoritative. Read the card, not this table."
```

What those two ranges actually contain now:

```
$ sed -n '189,192p' corpus/knowledge/unreal-mcp/README.md
```
upstream/.claude-plugin/plugin.json: OK
upstream/CODEOWNERS: OK
upstream/.gitignore: OK
```

$ sed -n '195,209p' corpus/knowledge/unreal-mcp/README.md | cut -c1-60
upstream/LICENSE: OK
upstream/README.md: OK
upstream/skills/create-toolset/SKILL.md: OK
...
it. This index does **not** restate the labels: the binding
```

Both cited ranges land in a `sha256sum` **`OK` block**, not in the label-vocabulary
text and not in the card table. The quoted sentence actually lives at
`README.md:209`:

```
$ grep -n 'restate the labels' corpus/knowledge/unreal-mcp/README.md
209:it. This index does **not** restate the labels: the binding verdict and its
```

and the card table actually runs `README.md:213-227` (header at 213, last row
`| 13 | … scripting-programmatic.md` at 227):

```
$ grep -n '^| # | card path' corpus/knowledge/unreal-mcp/README.md
213:| # | card path | subsystem (per `upstream/README.md` → *What's Available*) |
$ awk 'NR>=213 && NR<=230 && /^\| 13/ {print NR}' corpus/knowledge/unreal-mcp/README.md
227
```

**Not a race artifact.** The lane index was last written at `14:16:52`; this card
was written at `14:18:15` — 83 seconds *later*, against the already-rewritten
index:

```
$ stat -c '%y  %n' corpus/knowledge/unreal-mcp/README.md corpus/knowledge/unreal-mcp/executability/meshes-textures.md
2026-10-18 14:16:52  corpus/knowledge/unreal-mcp/README.md
2026-10-18 14:18:15  corpus/knowledge/unreal-mcp/executability/meshes-textures.md
```

**Impact:** the defect is confined to §"Note on the index's card table" of one
card. The substantive claims of `meshes-textures.md` are unaffected — its §1–§4
upstream citations all resolve correctly (§3.1). The quoted sentence is itself
accurate; only its coordinates are wrong. Fix is mechanical: `195-209` → `213-227`,
`189-192` → `209`.

**Why this matters more than a typo.** This seat's brief is calibration, and the
lane's stated standard is that pointers are the load-bearing evidence device. A
pointer that resolves in-range but points at a hash block is the exact failure a
range-only check cannot catch — which is why §3.2 exists as a separate test.

### 3.3 Contrast: `actors-scene.md`'s lane citations are correct

The same class of citation was checked on `actors-scene.md`, which cites the lane
index four times. All four resolve to the right bytes:

| card citation | actual content | verdict |
|---|---|---|
| `README.md:41` | `\| unproven-runtime \| the claim needs the live editor and nothing was observed \| unproven \|` | correct |
| `README.md:12-59` | `## Verification policy (read this first)` … | correct |
| `README.md:31-48` | `### How the binary policy maps onto the ternary card labels` … | correct |
| `README.md:204-240` | `## executability/ — 13 subsystem verdict cards` … | correct |

This is the control that makes §3.2 a real finding rather than a parser artifact:
the same check, run on another card, passes.

---

## 4. Host receipts re-derived (not quoted from the cards)

Per this seat's brief, the receipts the cards lean on were re-run rather than
trusted:

```
$ git -C /tmp/ue-skills-ref rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
$ which UnrealEditor UnrealEditor-Cmd UE4Editor
which: no UnrealEditor in (...)
which: no UnrealEditor-Cmd in (...)
which: no UE4Editor in (...)
$ ls -d /opt/UnrealEngine /opt/unreal-engine ~/UnrealEngine
ls: cannot access '/opt/UnrealEngine': No such file or directory
ls: cannot access '/opt/unreal-engine': No such file or directory
ls: cannot access '/home/vgpnk/UnrealEngine': No such file or directory
$ ss -ltnp | grep -E ':8000'
(no listener on 8000)
$ shellcheck --version
ShellCheck - shell script analysis tool
version: 0.11.0
```

Byte-identity of the vendored tree against the pinned clone, re-derived
independently:

```
$ diff /tmp/s47_vend.txt /tmp/s47_clone.txt && echo FILELIST-IDENTICAL
FILELIST-IDENTICAL
$ diff /tmp/s47_v.sha /tmp/s47_c.sha && echo ALL-12-BYTE-IDENTICAL
ALL-12-BYTE-IDENTICAL
```

**These confirm every `static-only` label in the set is correctly grounded.** The
central claim of all 12 `static-only` cards — "no editor exists on this host, so
no subsystem behaviour was observed" — is true on this host as verified above.

---

## 5. Numeric-receipt audit — the cards' own counts reproduce

A card that asserts a grep count which does not reproduce is asserting a false
receipt. Re-ran the load-bearing numbers from the vendored tree:

| card claim | re-run command | observed | match |
|---|---|---|---|
| `blueprints.md:31` "14 mentions, 5 files" | `grep -rniE "blueprint" . \| wc -l` | `14` | yes |
| `blueprints.md:42` "exactly one Blueprint tool name" | `grep -rnoE "[A-Za-z]+Tools\.[A-Za-z_]+" . \| sort -u \| wc -l` | `2` | yes |
| `blueprints.md:31` "1022 lines over 12 files" | `find . -type f -exec wc -l {} +` | `1022 total` | yes |
| `assets-content.md:127` "exactly 13 bullets" | `sed -n '100,112p' README.md \| grep -c '^- \*\*'` | `13` | yes |
| `testing-automation.md` "10 mentions, all in one file" | `grep -ro "AutomationTestToolset\|UnrealEditor-Cmd\|DiscoverTests\|RunTests\|ListTests\|GetTestStatus\|GetTestResults" . \| wc -l` | `10` | yes |
| `meshes-textures.md:66` "884 Markdown lines" | `find . -name '*.md' -exec wc -l {} +` | `884 total` | yes |
| `gameplay-gas.md:164` "63556 bytes" | `cat $(find . -type f \| sort) \| wc -c` | `63556` | yes |
| `meshes-textures.md:146` "mesh/texture method names: empty" | `grep -rnoE "[A-Za-z]+Tools\.[A-Za-z_]+" . \| grep -iE 'mesh\|texture' \| wc -l` | `0` | yes |

### 5.1 The one number that looked wrong, and is right

`actors-scene.md:223` asserts "995 content lines" while sibling cards say 1022.
Checked whether this is an inconsistency:

```
$ cd corpus/knowledge/unreal-mcp/upstream
$ wc -l $(find . -type f | sort | grep -vE 'LICENSE|CODEOWNERS|gitignore') | tail -1
  995 total
```

995 = 1022 − `LICENSE` (21) − `CODEOWNERS` (2) − `.gitignore` (4). The card is
counting *content* lines, excluding the three non-content files, and the number
reproduces exactly. **Not a defect** — but the card never states its exclusion
rule, so a reader cannot reproduce it without this derivation. Worth one clause
of explanation; recorded as a readability note, not an error.

---

## 6. Findings register

| # | severity | location | finding | evidence |
|---|---|---|---|---|
| **F1** | **major (calibration)** | `meshes-textures.md:254` | Cites lane-index ranges `README.md:195-209` (card table) and `README.md:189-192` (label-vocabulary quote). Both ranges land in a `sha256sum` `OK` block. Correct: table is `213-227`, quote is at `209`. Not a race artifact (card written 83 s after the index rewrite). | §3.2 |
| **F2** | note (disclosed) | `actors-scene.md:4` | Sole `unproven-runtime` label among 13; 12 are `static-only`. Card argues the choice and flags the tension for the adjudicator. Permitted by `README.md:236-239`. | §2.1 |
| **F3** | note (readability) | `actors-scene.md:223` | "995 content lines" reproduces as 1022 minus LICENSE/CODEOWNERS/.gitignore, but the exclusion rule is never stated, so it is not independently reproducible from the card alone. | §5.1 |
| **F4** | informational | all 13 cards | Zero `verified-here` labels. Correct: no editor on this host, so no subsystem card can carry it. | §2, §4 |

**No overclaim found.** The specific thing this seat was dispatched to hunt — a
sentence asserting runtime behaviour as proven — does not exist in the set.

---

## 7. Verdict

**PASS with one calibration defect.**

- **Depth claim holds.** 13 cards exist, one per README domain, each labeled
  exactly one permitted value, each with an explicit "why not the other two
  labels" section and a host-receipt table.
- **No runtime overclaims.** 22 predicate-bearing sentences inspected
  individually, plus a strict-mode re-run (39 hits), a reverse proof-verb hunt,
  and a table-row sweep. All benign; all receipts or attributions.
- **Evidence grounding is real.** Byte-identity, the pinned SHA, the absent
  editor, and the absent listener all re-derived independently (§4); the cards'
  own numeric receipts all reproduce (§5).
- **One defect to fix before this set is fully calibration-clean:** F1, the two
  stale line ranges in `meshes-textures.md:254`. Mechanical fix, no evidence moves.

**For the adjudicator:** F2 is the one judgement call this seat deliberately did
not make. If set-wide label consistency is desired, the ruling is between
`actors-scene.md`'s looser test (path identified → `unproven-runtime`) and the
stricter test 12 cards applied (tool surface unspecified → `static-only`). The
card itself proposes the one-line relabel; the evidence in the card does not move
either way.

---

## 8. Cross-references

- Card set: `corpus/knowledge/unreal-mcp/executability/` (13 files)
- Lane index: `corpus/knowledge/unreal-mcp/README.md` (278 lines)
- Vendored upstream: `corpus/knowledge/unreal-mcp/upstream/` (12 files, 1022 lines)
- Per-file hashes: `corpus/knowledge/unreal-mcp/.manifest.d/`
- Detector used: `/tmp/seat47_overclaim.py` (ephemeral; method recorded in §1.1)
- Round unknowns map: `reports/round-101/r101-unknowns-map.md`
