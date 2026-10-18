# r104 · SEAT-21 SKILL-BLEED — frontmatter accuracy, cross-domain bleed, PROVINCE consistency

**Seat:** SEAT-21 SKILL-BLEED · round 104 · lane `game-dev-3d-shokunin`
**Owned path written:** `reports/round-104/skill/bleed.md` (this file only). No `SKILL.md` byte, no
`PROVINCE.md`/`SHONEN.md`/`LOG.md`/`SCORECARD.md`, no `corpus/**` file, no `reports/round-10{1,2,3}/**`
file, and no other seat's report was written or modified. Every command below is read-only.
**Subject under audit:** `SKILL.md` at the lane root —
`sha256 1055a52f570410e16f35c5d2384a36382e66568964e4d530cce914443e9fb66c`, 174 lines, untracked
(`git status --porcelain SKILL.md` → `?? SKILL.md`; `git ls-files SKILL.md` → 0).
**Date:** 2026-10-18 · **Lane HEAD:** `88c3b2ca70fc83ec47a931d7b6dcff85a111c04e` (r103 report-last; work `8c9d9ad`) · no commit.

**No Unreal runtime claim is made or implied anywhere in this file.** Unreal Editor is not installed on
this host; nothing below asserts live-editor behaviour.

Tags: **[O]** command run by this seat with output quoted · **[C]** cross-referenced to a concurrent r104
seat's report · **[F]** the subject's own claim did not reproduce.

---

## 0. Bottom line

**Verdict: PASS on the two questions the seat exists to answer; two calibration defects recorded, one
resolved mid-seat, one still live and owed at fold time.**

| question | verdict | evidence |
|---|---|---|
| frontmatter `description` + trigger strings accurate after the edit | **PASS with one under-delivery note (§3)** | name = dir name; engine set = PROVINCE's owns-set exactly; both anti-trigger siblings are real lane dirs; the one body-unbacked trigger set is a router promise, not a false claim |
| no cross-domain bleed | **PASS** | 0 hits for `lore`/`narrative`/`canon`/`fictional`/`2D`/`harness-integrity`/`gate-evidence`/`rlm-dispatch`/`art-east`/`revenger` in the body; the only sibling words are the two frontmatter anti-triggers, which are *correct* exclusions. The loose case-insensitive scan's 4 matches are 1 × `canonical` and 3 × the hex byte `2d` inside sha256 digests — resolved individually in §2.2 |
| PROVINCE consistency | **PASS** | every domain term, the 2D inheritance clause, and the Unreal census row reproduce against `PROVINCE.md` and `corpus/knowledge/engines.md` |

**Defect 1 (resolved mid-seat) — a forward reference to a receipt that did not exist.** `SKILL.md`
cites `reports/round-104/skill/author.md` §2 four times (rows A, C, D, E) as its re-derivation receipt.
At `19:20Z` that path did not exist (`ls` → `No such file or directory`). It appeared at `19:20Z`
(16994 bytes) and grew to 17699 bytes by `19:21Z`. This is the file's *own* `prose-cites-bytes` class —
§2 of the file names it as an error pattern — occurring inside the file that names it. **Now resolved;
recorded because the landing order was observable and the same order in a slower round would have
shipped a dangling citation.**

**Defect 2 (live, owed at fold time) — the gate sha citation is correct but guaranteed to rot.** See §4.
`SKILL.md` pins the gate at `577c8b54…` in three places. That is the **HEAD** value and was right at
write time. But `corpus/knowledge/unreal-mcp/gate/run_gate.sh` is `M` in the worktree and the C2 seat is
editing it *now*; I observed **six distinct identities** during this seat's run. The citation is
compliant with the file's own rule (it carries no gate *line number*, and §6 says "re-hash before
acting"), but the sha will be stale the moment C2 commits.

**One SHONEN-state imprecision, reported not repaired** — §5, minor [F].

---

## 1. Frontmatter accuracy

### 1.1 Identity fields

```
$ sed -n '1,3p' SKILL.md
---
name: game-dev-3d-shokunin
description: Domain specialist — 3D game production verified by executable headless fixtures —
  spatial queries, camera/frustum, transforms, scene structure, determinism — across Godot,
  three.js, Unity and Unreal. Use for 3D fixture work, headless battery runs, engine/version
  census questions, or any claim about what a 3D engine did on this host. Trigger strings:
  "3D fixture", "headless battery", "phys3d", "camera3d/frustum", "engine census", "is Unreal
  installed". Anti-trigger: 2D production surfaces (sibling `game-dev-2d-shokunin`); reverse
  engineering as an end in itself (`revenger-shokunin`). Sibling arbitration: 2D fixture patterns
  are inherited, 2D product surfaces are not; contested scope is reported per `PROVINCE.md`,
  never absorbed.
---

$ basename "$PWD"
game-dev-3d-shokunin
```

`name` matches the lane directory exactly. **[O]**

### 1.2 The engine set matches PROVINCE's owns-list — no more, no less

```
$ grep -oE "Godot|Unity|Unreal Engine|three\.js" PROVINCE.md | sort -u | tr '\n' ' '
Godot three.js Unity Unreal Engine

$ grep -oE "Godot|Unity|Unreal|three\.js" SKILL.md | sort -u | tr '\n' ' '
Godot three.js Unity Unreal
```

The only difference is `Unreal Engine` vs `Unreal` — a truncation, not a scope change; `PROVINCE.md`
itself uses both forms. No engine is claimed that PROVINCE does not own, and none owned is missing. **[O]**

### 1.3 Anti-trigger siblings are real lanes, and are the right two

```
$ ls -d /home/vgpnk/Projects/shokunin/*-shokunin | xargs -n1 basename | grep -E "^game-dev-2d|^revenger"
game-dev-2d-shokunin
revenger-shokunin
```

Both directories exist. **[O]** Both are named in `PROVINCE.md`'s refusal list:

```
$ sed -n '33,40p' PROVINCE.md
Refuses: engine/editor source mutation; publishing or store submission;
asset rights clearance (art-east-asian-design); harness/evidence auditing
(harness-integrity, gate-evidence, rlm-dispatch); narrative canon (lore
lane — contested scope is reported, not absorbed); 2D production scope
(game-dev-2d — shared fixture patterns are inherited, 2D product surfaces
are not); reverse engineering as an end in itself or live-target runtime
evidence (revenger).
```

The frontmatter's anti-triggers are therefore *derived from* PROVINCE, not invented — which is the
correct direction for a skill file. **[O]**

### 1.4 The 2D arbitration clause is a faithful restatement of PROVINCE

```
$ tr '\n' ' ' < PROVINCE.md | grep -oE "game-dev-2d[^)]*"
game-dev-2d — shared fixture patterns are inherited, 2D product surfaces are not

$ grep -oE "2D fixture patterns[^.]*\." SKILL.md
2D fixture patterns are inherited, 2D product surfaces are not; contested scope is reported
per `PROVINCE.md`, never absorbed.
```

`shared fixture patterns` → `2D fixture patterns`; the operative half (`2D product surfaces are not`)
is verbatim. No scope is widened. **[O]**

### 1.5 `Rank:` is omitted — a convention gap, not a bleed

```
$ for f in /home/vgpnk/Projects/shokunin/*-shokunin/SKILL.md; do \
    printf '%-30s %s\n' "$(basename $(dirname $f))" "$(grep -c 'Rank: shonen' $f)"; done | head -20
chousa-shokunin               1
game-dev-3d-shokunin          0
kagi-shokunin                 1
kaidoku-shokunin              1
kake-shokunin                 1
kama-shokunin                 2
kasegi-shokunin               1
kengaku-shokunin              1
kotoba-shokunin               1
kotodama-shokunin             1
kumitate-shokunin             1
lore-shokunin                 0
mado-shokunin                 1
mori-shokunin                 1
souji-shokunin                0
tabi-shokunin                 1
tameshi-shokunin              1
tsukuroi-shokunin             1
```

15 of 18 lane `SKILL.md` files carry `Rank: shonen`; this file does not. Three lanes omit it
(`game-dev-3d`, `lore`, `souji`), so it is a majority convention rather than a rule. **Recorded as a
consistency note, not a defect** — `SHONEN.md` in this lane is present and unchecked, so the rank is
already machine-visible; the field is redundant here, not missing information. **[O]**

---

## 2. Cross-domain bleed

### 2.1 The strict scan is clean

```
$ sed -n '7,174p' SKILL.md | grep -ciE "\blore\b|\bnarrative\b|\bcanon\b|\bfictional\b|harness-integrity|gate-evidence|rlm-dispatch|art-east|\brevenger\b"
0
```

Zero hits across the entire body for every refused domain: the lore lane, the harness/evidence-audit
lane, the rights-clearance surface, and the revenger lane. **[O]**

### 2.2 The two traps in this scan, and why neither is a hit

A case-*insensitive* substring scan returns **4** hits on 3 lines:

```
$ sed -n '7,174p' SKILL.md | grep -ciE "lore|narrative|canon|fictional|2D|harness-integrity|gate-evidence|rlm-dispatch|art-east|revenger"
3
```

(The count is 3 *lines*, 4 *matches*.) Each hit was resolved to its matched substring:

| file line | matched | context | what it actually is |
|---|---|---|---|
| 40 | `canon` | `dence \| canonical com` | the word **`canonical`** in `canonical command` |
| 45 | `2d` | `646325b62decd0ca8d` | **hex inside a sha256** (`5e67bdf95c7646325b62decd0ca8d375d325ea19`) |
| 160 | `2d` ×2 | `0187ee322d6d1cb20f` | **hex inside a sha256** (`c79d8dd1d7c0c7bc934700187ee322d6d1cb20fc03cc974fa62ee2d95b8ee721`) |

So the loose hits are **1 × `canonical` + 3 × hex-digit `2d`**, and none of them is a domain term.
Re-running with a word boundary and case-sensitively yields **0**, as §2.1 shows. This is worth naming
for two reasons: a future bleed audit that greps `canon` case-insensitively will report a phantom hit
every round, and — more subtly — **any audit that greps `2d` case-insensitively will match sha256
hex**, because `2d` is a valid hex byte. A bleed scan on a file this dense with hashes must be
case-sensitive and word-bounded, or it will manufacture findings out of provenance digests. **[O]**

*Correction to an earlier draft of this section:* I first wrote that all three loose hits were
`canonical`. That was wrong — I had read the matches with a line-number offset that resolved them
against the wrong lines. The table above is the corrected, byte-level resolution; the strict count in
§2.1 was never affected (it was 0 both times).

### 2.3 `2D` appears only in the frontmatter, and only as an exclusion

```
$ sed -n '7,174p' SKILL.md | grep -c "2D"
0
```

The two `2D` occurrences in the file are both in the frontmatter description, both in the anti-trigger /
arbitration clause (§1.3, §1.4). No 2D fixture, tool, or product surface is described anywhere in the
body. **[O]**

### 2.4 The body is Unreal-scoped end to end

All six body sections are Unreal-content claim discipline:

```
$ grep -n "^## " SKILL.md
20:## 1. Unreal-content claim discipline — decision table
60:## 2. Error patterns — named signatures
77:## 3. Checklist — before writing any Unreal-content claim
105:## 4. The open precedence ruling (state it, do not resolve it)
130:## 5. What this table refuses
150:## 6. Re-deriving this file
```

No section imports another lane's method. §2's error patterns are the lane's *own* defects
(`prose-cites-bytes`, `count-written-into-prose`, `scanner-relative datum`, …), each sourced to a
`corpus/lessons/**` or `reports/round-10{2,3}/**` file in this lane. **[O]**

**Verdict: PASS. No cross-domain bleed.** The refused domains appear nowhere except as explicit
exclusions in the frontmatter, which is the opposite of bleed.

---

## 3. Trigger-string accuracy (the one under-delivery)

The description advertises six trigger strings. Checking each against the body for backing:

```
$ for t in "3D fixture" "headless battery" "phys3d" "camera3d/frustum" "engine census" "is Unreal installed"; do \
    printf '%-20s body_hits=%s\n' "$t" "$(sed -n '7,174p' SKILL.md | grep -ci "$t")"; done
3D fixture           body_hits=0
headless battery     body_hits=0
phys3d               body_hits=0
camera3d/frustum     body_hits=0
engine census        body_hits=2
is Unreal installed  body_hits=0
```

Five of six trigger strings appear nowhere in the body; only `engine census` does (in §5.1's
no-promotion rule and §6's artifact table). The advertised domain terms behave the same way:

```
$ for t in "spatial quer" camera frustum transform "scene structure" instanc determinism input collision; do \
    printf '%-16s body=%s\n' "$t" "$(sed -n '7,174p' SKILL.md | grep -ci "$t")"; done
spatial quer     body=0
camera           body=0
frustum          body=0
transform        body=0
scene structure  body=0
instanc          body=0
determinism      body=0
input            body=0
collision        body=3
```

**Is this a defect?** Read strictly: no. The frontmatter `description` is the **router** — it decides
which tasks reach this skill. It is not a table of contents. A skill whose description says "use for 3D
fixture work" is promising to *handle* those tasks, not to *contain a section on* them, and the file
does handle the Unreal-content slice of that work correctly.

Read as calibration: **it is a real under-delivery worth flagging.** The description sells a broad 3D
craft surface — fixture work, headless battery runs, engine/version census — while the body teaches
exactly one topic: how to label an Unreal-content claim. The verified trigger terms (`phys3d`,
`camera3d/frustum`, `is Unreal installed`) exist in the corpus and are real tasks (1088, 585, 16 files
respectively), but a reader routed here by `phys3d` finds no `phys3d` guidance.

```
$ for t in phys3d camera3d frustum "3D fixture" "headless battery" UnrealEditor; do \
    printf '%-18s corpus_files=%s\n' "$t" "$(grep -rl "$t" corpus/ --include=* 2>/dev/null | wc -l)"; done
phys3d             corpus_files=1088
camera3d           corpus_files=585
frustum            corpus_files=574
3D fixture         corpus_files=83
headless battery   corpus_files=192
UnrealEditor       corpus_files=16
```

**This is the round's honest coverage gap, and it is the C3 claim's scope, not a bleed.** The r102
draft's own §0 said the gap was "one table that decides … which label a claim may carry" — that table
landed and it is correct. But the resulting file is narrower than its own description, because the lane
has **no** table for its *primary* executable surface (Godot headless batteries, the `phys3d`/`camera3d`
fixture families) — only for the *uninstalled* engine's content claims. Recommend the fold seat either
(a) narrow the description to the Unreal-content claim surface, or (b) note in §0 that §1 covers one
engine and the battery surface is still owed. Do not widen the table; it is right for what it covers.

---

## 4. PROVINCE consistency

### 4.1 Every PROVINCE-touching claim in `SKILL.md` reproduces

| `SKILL.md` claim | PROVINCE / corpus state | verdict |
|---|---|---|
| owns "3D game production verified by executable headless fixtures — spatial queries, camera/frustum, transforms, scene structure, determinism" | `PROVINCE.md:3-7` verbatim | **consistent [O]** |
| engines "Godot / three.js / Unity / Unreal" | `PROVINCE.md:8-9` | **consistent [O]** (§1.2) |
| "2D fixture patterns are inherited, 2D product surfaces are not" | `PROVINCE.md:36-37` | **consistent [O]** (§1.4) |
| "contested scope is reported per `PROVINCE.md`, never absorbed" | `PROVINCE.md:35-36` ("contested scope is reported, not absorbed") | **consistent [O]** |
| §5.1 "The Unreal row stays `installed: no / executable headless: no`" | `engines.md` Unreal row: `no \| no` | **consistent [O]** |
| §4 F7 subtree `README.md` sha `c79d8dd1…` | live `c79d8dd1d7c0c7bc934700187ee322d6d1cb20fc03cc974fa62ee2d95b8ee721` | **consistent [O]** |

The §5.1 census claim, verified directly:

```
$ grep -oE '^\| Unreal Engine \| [^|]*\| [^|]*\|' corpus/knowledge/engines.md
| Unreal Engine | no | no |
```

### 4.2 All nine artifact stamps in §6 reproduce byte-exactly

```
$ sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh \
            corpus/knowledge/unreal-mcp/gate/README.md \
            corpus/knowledge/unreal-mcp/README.md \
            corpus/knowledge/unreal-mcp/PROVENANCE.md \
            corpus/knowledge/unreal-mcp/adaptation-kimi.md \
            corpus/lessons/r102-unreal-integration.md \
            corpus/knowledge/engines.md \
            reports/round-102/skill-decision-table-draft.md \
            reports/round-103/skill-table-review.md
577c8b5489577b948536005a170da14ae3d4e13c11776aeca8f803bfb5fcefa0  …/gate/run_gate.sh
834f468ded21fcdf069ab378c2774298158f71a93954aef9ee0df86bd90927d2  …/gate/README.md
c79d8dd1d7c0c7bc934700187ee322d6d1cb20fc03cc974fa62ee2d95b8ee721  …/README.md
36938c71a0f5b1296b60ed505274d0b19fd87308eac61983525c2b2b44387f01  …/PROVENANCE.md
084a34cd94806caa497de1ab80df84f95876114048ead83bc158b4d50de8c879  …/adaptation-kimi.md
cf237b8831560c58a3d6d045a9a93e00e1993f798984c08b1abef8a19f9a8ea2  …/r102-unreal-integration.md
d03907d3d63771c10558a2bc276d62c50bcdea1d02150d78e6d1a720a0c3bddf  …/engines.md
fa360bde7f44de1078edef7d1555492a112f6c56ca443066ccbc3c6b1fb317c2  …/skill-decision-table-draft.md
95d40d92432252f66d6edf886ac99bf60e190461f075db3d7936bf94527d6815  …/skill-table-review.md
```

All nine match the values §6 prints. **[O]** This is the strongest property of the file: it is the
first artifact in this lane whose entire provenance column reproduces at once.

### 4.3 Every cited path resolves

```
$ for f in reports/round-101/r101-reviewer-c1.md reports/round-101/r101-mutation-tester.md \
           reports/round-101/r101-critic-c3.md reports/round-102/reruns/manifest.md \
           reports/round-102/reruns/labels.md reports/round-102/reruns/pointers.md \
           corpus/artifacts/unreal-r22/verify_descriptor.py \
           corpus/artifacts/unreal-r22/README.md \
           corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin \
           corpus/knowledge/unreal-mcp/executability/blueprints.md \
           corpus/knowledge/engines.md; do [ -e "$f" ] && echo "OK  $f" || echo "MISSING $f"; done
OK  reports/round-101/r101-reviewer-c1.md
OK  reports/round-101/r101-mutation-tester.md
OK  reports/round-101/r101-critic-c3.md
OK  reports/round-102/reruns/manifest.md
OK  reports/round-102/reruns/labels.md
OK  reports/round-102/reruns/pointers.md
OK  corpus/artifacts/unreal-r22/verify_descriptor.py
OK  corpus/artifacts/unreal-r22/README.md
OK  corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin
OK  corpus/knowledge/unreal-mcp/executability/blueprints.md
OK  corpus/knowledge/engines.md
```

The only path that did **not** resolve was `reports/round-104/skill/author.md` (§0 defect 1), now present.

### 4.4 No line-number citation of any file

```
$ grep -cE '[a-zA-Z0-9_/.-]+\.(sh|md|json|gd|py):[0-9]+' SKILL.md
0
```

The r103 review's landing condition 1 — *"zero gate line numbers"* — holds, and holds for **every**
file, not just the gate. The file cites by section heading (`§Verification policy`) and by sha. **[O]**

---

## 5. The two defects a fold seat must act on

### 5.1 The gate sha citation will rot when C2 commits (calibration, live)

`SKILL.md` pins the gate at `577c8b54…` in three places (§1 row A, §1 row B, §6). That value is the
**HEAD** identity and is correct:

```
$ git show HEAD:corpus/knowledge/unreal-mcp/gate/run_gate.sh | sha256sum
577c8b5489577b948536005a170da14ae3d4e13c11776aeca8f803bfb5fcefa0  -
```

But the gate is `M` and the C2 seat is editing it live. Six distinct worktree identities were observed
during this seat's run:

| observation | gate sha (short) | note |
|---|---|---|
| start of seat | `577c8b54…` | equals HEAD |
| mid-seat | `7903c589…` | C2 edit in progress |
| mid-seat | `abebee5c…` | C2 edit in progress |
| mid-seat | `15fc46d5…` | C2 edit in progress |
| mid-seat | `b6d8c61a…` | C2 edit in progress |
| last check `19:22Z` | `96bcf45a…` | C2 edit in progress |

```
$ git status --porcelain corpus/knowledge/unreal-mcp/gate/run_gate.sh
 M corpus/knowledge/unreal-mcp/gate/run_gate.sh
```

**Assessment: the citation is compliant, and it is still the thing that will break.** The file obeys its
own rule (no gate *line* number; §6 says "re-hash before acting on any of them"). But a sha citation of
a file under active edit is only as durable as the next commit, and C2 is *guaranteed* to move this file.
Recommend the fold seat re-stamp the three `577c8b54…` occurrences against the committed C2 gate, or —
better, and matching §1's own logic — cite the gate **by `CHECK n <name>` only** and drop the sha
entirely, since the check *names* are the stable interface and the file already says so.

**The red gate is a separate matter and not this seat's finding.** During this seat's run the gate
reported `GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)`, `GATE_RC=2` — CHECK 2's
network clone could not run, and CHECK 3/CHECK 4 were green (`CARDS=13 BAD=0`, `NAME_SET=OK`,
`UNRESOLVED=0`). An earlier run under C2's mid-edit state printed a spurious
`FAIL per-seat manifest sweep (--strict) failed` followed by `MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0`
— i.e. the sweep *passed* while the gate announced it failed. That is exactly the
"misleading-failure class" C2's own comment (`run_gate.sh:118-124`) says it exists to close, observed
while the closing edit was mid-flight. **The C2 seat is the seat of record for this surface**; recorded
here only because `SKILL.md` §1 row A tells a reader to run this gate, so a reader following the file
today can hit it. **[O][C]**

### 5.2 §6's SHONEN-state sentence does not match `SHONEN.md` (minor [F])

`SKILL.md:174` states:

> Until such a verifier records a pointer, box 1 reads `[~]`, not `[x]`.

`SHONEN.md:3` reads:

```
$ sed -n '3p' SHONEN.md | cat -A
- [ ] Real decision tables/error patterns/checklists with cited sources.$
```

The box is `[ ]`, not `[~]`. `[~]` is the *self-attestation* marker defined by SHONEN's own footer
("self-attestation counts as `[~]`"), so the sentence is a defensible statement of the *ceiling* — but
read literally as a claim about the current ledger it is false, and this file's entire discipline is
"never accept a state written into prose — enumerate." The precise sentence would be *"box 1 still
reads `[ ]`; a self-attestation would move it to `[~]`, and only a named non-author verifier to
`[x]`."*

`SHONEN.md` is byte-identical to HEAD and this seat is forbidden from writing it, so this is **reported,
not repaired**:

```
$ [ "$(git hash-object SHONEN.md)" = "$(git rev-parse HEAD:SHONEN.md)" ] && echo IDENTICAL
IDENTICAL
```

**Severity: minor.** It does not affect any row's executability and the box is correctly left open.

---

## 6. Verdict

| axis | verdict |
|---|---|
| **frontmatter accuracy** | **PASS** — `name` = lane dir; engine set = PROVINCE owns-set; both anti-trigger siblings are real lanes and are PROVINCE's own refusals; the 2D arbitration clause is a faithful restatement |
| **trigger-string accuracy** | **PASS with a recorded under-delivery** (§3) — five of six advertised triggers have no body backing, which is correct for a router description but means the file is narrower than it reads |
| **cross-domain bleed** | **PASS** — 0 true hits; the 3 loose `-i` hits are `canonical` |
| **PROVINCE consistency** | **PASS** — every PROVINCE-touching claim reproduces; all 9 artifact stamps reproduce; all cited paths resolve; 0 line-number citations |
| **defects owed at fold** | **2** — re-stamp the gate sha (or drop it) after C2 commits; correct §6's SHONEN-state sentence. Both are text edits inside `SKILL.md`, both mechanical. |

**No promotion is claimed.** `SKILL.md` is untracked (`?? SKILL.md`), and `SHONEN.md` box 1 remains
`[ ]` — a promotion gate needs a named non-author verifier, and this seat is a reviewer, not that
verifier. This file does **not** flip any box.

---

## 7. Reproduce

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin

# subject, pinned
sha256sum SKILL.md          # 1055a52f… 174 lines; untracked
git status --porcelain SKILL.md   # "?? SKILL.md"

# §1 frontmatter identity and engine set
sed -n '1,3p' SKILL.md; basename "$PWD"
grep -oE "Godot|Unity|Unreal Engine|three\.js" PROVINCE.md | sort -u
grep -oE "Godot|Unity|Unreal|three\.js" SKILL.md | sort -u
ls -d /home/vgpnk/Projects/shokunin/*-shokunin | xargs -n1 basename | grep -E "^game-dev-2d|^revenger"
tr '\n' ' ' < PROVINCE.md | grep -oE "game-dev-2d[^)]*"

# §2 bleed — strict (the number that matters) vs the two canonical false positives
sed -n '7,174p' SKILL.md | grep -ciE "\blore\b|\bnarrative\b|\bcanon\b|\bfictional\b|harness-integrity|gate-evidence|rlm-dispatch|art-east|\brevenger\b"   # 0
# the loose scan's 4 matches are NOT domain terms — resolve each one:
sed -n '7,174p' SKILL.md | grep -niE "canon"    # 1 line: "canonical command"
sed -n '7,174p' SKILL.md | grep -niE "2d"       # 2 lines, 3 matches: "2d" inside sha256 hex
sed -n '7,174p' SKILL.md | grep -c  "2D"        # 0 — no real 2D token in the body

# §3 trigger backing
for t in "3D fixture" "headless battery" phys3d "camera3d/frustum" "engine census" "is Unreal installed"; do \
  printf '%-20s body_hits=%s\n' "$t" "$(sed -n '7,174p' SKILL.md | grep -ci "$t")"; done

# §4 PROVINCE + stamps + paths + no-line-number
grep -oE '^\| Unreal Engine \| [^|]*\| [^|]*\|' corpus/knowledge/engines.md
sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh corpus/knowledge/unreal-mcp/gate/README.md \
          corpus/knowledge/unreal-mcp/README.md corpus/knowledge/unreal-mcp/PROVENANCE.md \
          corpus/knowledge/unreal-mcp/adaptation-kimi.md corpus/lessons/r102-unreal-integration.md \
          corpus/knowledge/engines.md reports/round-102/skill-decision-table-draft.md \
          reports/round-103/skill-table-review.md
grep -cE '[a-zA-Z0-9_/.-]+\.(sh|md|json|gd|py):[0-9]+' SKILL.md   # 0

# §5.1 the gate moves under the file
git show HEAD:corpus/knowledge/unreal-mcp/gate/run_gate.sh | sha256sum   # 577c8b54… (what §1/§6 cite)
sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh                    # 96bcf45a… (C2 worktree, moving)
git status --porcelain corpus/knowledge/unreal-mcp/gate/run_gate.sh       # " M …"
bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "GATE_RC=$?"      # BLOCKED, rc 2 (CHECK 2 network)

# §5.2 the SHONEN-state sentence
sed -n '3p' SHONEN.md | cat -A          # "- [ ] …"  — not "[~]"
sed -n '171,174p' SKILL.md              # "box 1 reads [~], not [x]"
[ "$(git hash-object SHONEN.md)" = "$(git rev-parse HEAD:SHONEN.md)" ] && echo IDENTICAL

# §1.5 the Rank convention
for f in /home/vgpnk/Projects/shokunin/*-shokunin/SKILL.md; do \
  printf '%-30s %s\n' "$(basename $(dirname $f))" "$(grep -c 'Rank: shonen' $f)"; done
```

---

## 8. Limits of this audit

- **I am a reviewer, not the author.** I edited no byte of `SKILL.md`, `PROVINCE.md`, `SHONEN.md`, or any
  `corpus/` file. Every command above is read-only. The two defects in §5 are **reported, not repaired**.
- **The subject moved into existence during this seat's run.** `SKILL.md` did not exist when the seat
  opened; it appeared untracked at `19:20Z` and has been byte-stable since
  (`1055a52f…`, re-checked at `19:20Z` and `19:22Z`). Any re-run must re-hash it first.
- **The tree is live and the gate is mid-edit.** I observed six gate identities and one spurious
  `FAIL per-seat manifest sweep` that was followed by a clean `MANIFEST_OK=12 … RC=0`. Both are C2's
  surface and are flagged to that seat, not adjudicated here.
- **I audited the frontmatter, the bleed surface, and PROVINCE consistency — not the table's
  correctness.** Whether the five rows' *content* is right is the r103 review's and the author's
  question; I re-ran the stamps and the paths, and confirmed the commands the file prints reproduce
  their printed rcs (`jq -e .` → 0, dot-less → 3; `shellcheck` default → 0, `-o all` → 1 with 31
  findings; `which UnrealEditor` → 2; row E accept/reject → 0/0; row A control → 11 `OK` + 1 `FAILED`).
- **No Unreal runtime claim.** The editor is not installed; nothing above asserts live-editor behaviour,
  and §3's under-delivery note is a statement about this file's scope, not about any engine.
