# r102 · SEAT-61 DISSONANCE-HUNTER — contradictions between r102 artifacts and the r101 verdicts

**Seat:** SEAT-61 DISSONANCE-HUNTER · round 102 · lane `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`
**Owned path:** this file only (`reports/round-102/dissonance.md`). No other file was written or modified by this seat.
**Date:** 2026-10-18 · **Lane HEAD at run:** `2c99b7b8155841617d844c609813afcba77aa207` (r101 report-last; work commit `1659c036c961c6cdfd0b2679db72ecb9517a2f3b`)
**Snapshot window:** `2026-10-18T17:41:59Z` → `17:49:58Z`. The round-102 tree was **live** throughout: `corpus/knowledge/unreal-mcp/gate/` landed at `17:42`, the F8 fold at `17:43`, the r102 lesson at `17:44`, and `engines.md`/`rea.md`/`r22-unreal-review.md` all moved under this seat. Every observation below carries the time and the sha256 of the bytes it was taken against; where a value moved, both values are given.

**Method.** For each candidate contradiction: locate the r101 claim, re-run its stated command (or the nearest equivalent) on the frozen tree, and compare. Nothing is quoted from an author's transcript — every number below was produced by a command run in this session. Where a claim reproduced, it is recorded in §3 so the failures are calibrated against successes.

**Scope and discipline.** No Unreal runtime claim is made or implied. Unreal Editor is not installed on this host, so live-MCP behavior is unproven by construction; nothing here asserts it. The r101 subtree `corpus/knowledge/unreal-mcp/upstream/` and `.manifest.d/` were read-only to this seat and were not modified (verified below, §3 F1).

Tags: **[O]** command-run observation · **[I]** inference · **[?]** unresolved.

---

## 1. Headline

Twelve contradictions, in four classes:

| class | count | meaning |
|---|---|---|
| **A. r101 claim does not reproduce** | 5 | the r101 verdict text states a number/receipt that the frozen tree does not produce |
| **B. r102 artifact contradicts r101** | 3 | an r102 artifact falsifies, or is falsified by, an r101 verdict |
| **C. r102 artifact contradicts another r102 artifact** | 2 | two round-102 seats disagree about the same bytes |
| **D. r102 artifact contradicts the tree it describes** | 2 | an r102 artifact's own receipt/pointer fails when re-run |

The single most consequential finding is **D1/D2/D3**: on the *same* subtree there are now **three** independent pointer scanners producing **three different `POINTERS` counts** (`40 / 0 PASS`, `41 / 2 skipped / 1 FAIL`, `43 / 3 FAIL`), because the new r102 gate plants control pointers that the two r101-era scanners do not exclude. The r102 lesson cites "`POINTERS=40`" for two of them as if they agreed. They cannot both be right, and the r101 protocol's own step-7 gate now reads **FAIL** on the tree it was written to gate.

---

## 2. The contradictions

### A. r101 claims that do not reproduce on the frozen tree

---

#### C1 — The C3 file sizes and line counts in the r101 report never matched the landed blob

**Side A (r101 report, `reports/round-101/r101-report.md`).** Two places, both presenting the numbers as landed measurements:

- `:52-53` — "`adaptation-kimi.md` (20 525 B, 330 lines) … `PROVENANCE.md` (16 666 B) carries the pin, byte-identity, license and install receipts across 7 sections."
- `:182-183` (the C3 measurement table) — "**present, 16 666 B**, 7 sections" / "**present, 20 525 B / 330 lines**, 7 sections".

**Side B (frozen tree).**

```
$ git cat-file -s $(git rev-parse 1659c036:corpus/knowledge/unreal-mcp/PROVENANCE.md)      → 18269
$ git cat-file -s $(git rev-parse 1659c036:corpus/knowledge/unreal-mcp/adaptation-kimi.md) → 21744
$ git show 1659c036:corpus/knowledge/unreal-mcp/PROVENANCE.md | wc -l                      → 361
$ git show 1659c036:corpus/knowledge/unreal-mcp/adaptation-kimi.md | wc -l                 → 363
$ grep -c '^## ' corpus/knowledge/unreal-mcp/PROVENANCE.md                                 → 8
$ grep -c '^## ' corpus/knowledge/unreal-mcp/adaptation-kimi.md                            → 8
```

Both files are byte-identical at `1659c036`, at HEAD `2c99b7b`, and in the working tree (`git diff --stat 1659c036 2c99b7b -- corpus/knowledge/unreal-mcp/` → empty; the C3 files carry exactly one commit each, `git log --all --oneline -- <path>` → `1659c03` only). So there is **no committed revision** with 20 525 B or 16 666 B or 330 lines or 7 sections.

**Verdict: CONFIRMED contradiction.** The r101 report's C3 size/line/section figures are stale mid-draft values, not measurements of the landed artifact. Four of the eight numbers are wrong: both byte counts, both line counts, and both section counts. The *qualitative* claim they support (both files present, policy at §5, register at §6) is independently true — see §3 F3 — so this is a calibration defect in the r101 report, not a coverage gap in the artifact. **[O]**

---

#### C2 — The r101 report's probe inventory is wrong in both components while its total is right

**Side A (r101 report).** `:57` — "**Evidence probes (14 files).**" followed by a **13-name** list; `:207` — "round-101 report files … **33** at close (14 probes + 19 top-level `.md`, incl. this report)".

**Side B (frozen tree at `2c99b7b`, i.e. the r101 report-last commit).**

```
$ git ls-tree -r HEAD --name-only reports/round-101/probes/ | wc -l   → 16
$ git ls-tree HEAD --name-only reports/round-101/ | grep -c '\.md$'   → 17
$ git ls-tree -r HEAD --name-only reports/round-101 | wc -l           → 33
```

The listed names omit three files that exist (`doc-consistency.md`, `hooks-json.md`, `kimi-surfaces.md`) and count 13 while asserting 14. The split is **16 + 17 = 33**, not 14 + 19 = 33.

**Verdict: CONFIRMED contradiction.** The total (33) reproduces exactly; the decomposition does not. Two independently wrong components cancelling to a right total is precisely the failure mode the r102 lesson names as "enumerate, never trust a count written into prose" — and the r101 report is an instance of it. **[O]**

---

#### C3 — The "unfiltered sweep will always read UNRESOLVED=2" prediction is false, and r101 contradicts itself about it

**Side A (r101 report).** `:171-173`:

> "Re-measured at close on the committed tree (`1659c036…`): **unchanged, 78 / 0 PASS**. The unfiltered sweep over `reports/round-101` will always read `UNRESOLVED=2` for as long as the protocol's controls stand — that is the scanner's known self-contamination, not a C3 defect."

**Side B (same report, `:159`).** "**De-contaminated and re-measured [O].** Both strings have been removed from this file." — i.e. the report states it *removed* the contamination source, then predicts the contaminated reading forever.

**Side B (measured now).** The scanner self-excludes the protocol file, so the only place the control strings live is already excluded:

```
$ grep -rln 'upstream/nope\.md\|upstream/README\.md:9999\|upstream/README\.md:500' reports/round-101/
reports/round-101/r101-verification-protocol.md          # the file the scanner self-excludes
$ bash /tmp/r101-closeout/pointer-check.sh reports/round-101
POINTERS=75 UNRESOLVED=0
STEP=PASS
rc=0
```

**Verdict: CONFIRMED contradiction, and an internal one.** The prediction is falsified on the frozen tree (0, not 2), and it was already inconsistent with the report's own `:159` statement. The report's `:149-155` reading of `UNRESOLVED=2` was accurate only for the draft in which the report itself quoted the control strings. **[O]**

---

#### C4 — The r101 report and the r101 protocol disagree about which revision of `pointer-check.sh` is authoritative

**Side A (r101 report, `:146`, `:170-171`).** Receipts printed as `POINTERS=40 UNRESOLVED=0` and `POINTERS=78 UNRESOLVED=0` — a **two-field** line with no skip counter.

**Side B (r101 protocol, `:465`).** "`POINTERS=78 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0` → `STEP=PASS`" — a **three-field** line.

**Side B (the two on-disk scripts differ).**

```
$ diff /tmp/r101-closeout/pointer-check.sh /tmp/r102-dh/pointer-check.sh
< # EXCLUSIONS, both deliberate:
> # EXCLUSIONS, all deliberate and all printed so they cannot hide a real failure:
...
< total=0; bad=0
> sentinel='upstream/nope\.md:[0-9]+|upstream/README\.md:(9999|500)'
> total=0; bad=0; skipped=0
>       if printf '%s' "$ptr" | grep -qE "^($sentinel)$"; then skipped=$((skipped+1)); continue; fi
< printf 'POINTERS=%s UNRESOLVED=%s\n' "$total" "$bad"
> printf 'POINTERS=%s SKIPPED_CONTROL_SENTINELS=%s UNRESOLVED=%s\n' "$total" "$skipped" "$bad"
```

`/tmp/r101-closeout/pointer-check.sh` (the copy the r101 report's receipts came from) is an **older revision** than the one the protocol carries inline. The report claims (`:280-281`) that "The four scripts are also reproduced inline in `reports/round-101/r101-verification-protocol.md` §0, so a verifier never depends on a leftover `/tmp` file" — but re-extracting from §0 yields a *different* script than the one the report's receipts were produced with.

**Verdict: CONFIRMED contradiction.** The r101 report's stated reproducibility guarantee ("the inline copy is equivalent") does not hold: the inline copy adds an exact-sentinel filter and a printed skip counter that the `/tmp` copy lacks. A verifier who follows the report's instruction and re-extracts from §0 will run a different program and get a different number on the same tree (see D1). **[O]**

---

#### C5 — `38 distinct pointers` does not follow from the stated command

**Side A (r101 report `:187`).** "| distinct `upstream/…:line` pointers across all 3 index files + 13 cards | same, over the subtree's non-upstream md | 0 | **38** |", where "same" is the `:186` command `grep -ohE 'upstream/…:[0-9]+' | sort -u | wc -l`.

**Side B (measured).**

```
$ grep -rohE 'upstream/[A-Za-z0-9_./-]+:[0-9]+' README.md PROVENANCE.md adaptation-kimi.md executability/ | sort -u | wc -l
37
$ grep -rohE 'upstream/[A-Za-z0-9_./-]+:[0-9]+([,-][0-9]+)*' … | sort -u | wc -l
38
```

The extra pointer is exactly the five range/comma forms the strict pattern does not match (`upstream/hooks/hooks.json:4-5`, `upstream/hooks/unreal-context.sh:5,8`, `upstream/README.md:39,45`, `upstream/README.md:50-57`, `upstream/skills/unreal-mcp/references/setup.md:61,70-79`).

**Verdict: CONFIRMED contradiction (minor).** 38 is the range-inclusive count; the command the report states yields 37. The same table's `:186` row (17 pointers inside `adaptation-kimi.md`) **does** reproduce — `grep -ohE … adaptation-kimi.md | sort -u | wc -l` → 17 — so this is a per-row command/number mismatch, not a systematic offset. **[O]**

---

### B. r102 artifacts contradicting r101

---

#### C6 — The r102 gate falsifies the r101 C3 pointer gate it re-runs

**Side A (r101 protocol step 7, `:419-431`).** "`"$WORK/pointer-check.sh" reports/round-101 "$CORPUS"` … **Expected:** `UNRESOLVED=0` and `STEP=PASS`, exit 0", and the close-out table `G6 pointers | 7 | C3 | UNRESOLVED=0, hand-sample matches, and the negative control detected`.

**Side B (r102 gate artifact).** `corpus/knowledge/unreal-mcp/gate/README.md:147` plants `printf '\nsee upstream/README.md:200\n' >> "$T/sub/README.md"` and `:168` records `| C3 | plant upstream/README.md:200 | 1 | 4 | LINE-OOR … (max 112); UNRESOLVED=1 |` — i.e. the gate's own specification file contains the string `upstream/README.md:200`.

**Measured — the r101 protocol's exact step-7 command, run now:**

```
$ bash /tmp/r102-dh/pointer-check.sh reports/round-101 corpus/knowledge/unreal-mcp
LINE-OOR corpus/knowledge/unreal-mcp/gate/README.md :: upstream/README.md:200 (max 112)
POINTERS=116 SKIPPED_CONTROL_SENTINELS=2 UNRESOLVED=1
STEP=FAIL
rc=1
```

The r101 checker excludes only `*/upstream/*` and its own protocol file; it has no rule for a second checker's specification file. The r102 gate's own check 4 does (`SELF=$GATE_DIR/README.md`; `case "$f" in "$SUB"/upstream/*|"$SELF") continue;; esac`), which is why the gate passes.

**Verdict: CONFIRMED contradiction.** r102's C1(a) artifact, by landing inside the gated subtree, breaks the r101 C3 gate assertion (G6) that r102 also claims to re-derive. The r102 gate is green only because it excludes itself; the r101 gate is red on the same tree. Both cannot be cited as "the pointer sweep passes". **[O]**

---

#### C7 — `freshness-pin.md` §5 undercounts the unnamed PRs by two

**Side A (r102 `reports/round-102/freshness-pin.md:148-152`).** "**[O]** All five PRs remain `OPEN` … PR #8 (`Add an OpenCode port`) is **the only item not named in §8's** table".

**Side B (r102 `corpus/knowledge/unreal-mcp/PROVENANCE.md:348-356`).** The §8 table names, across six rows, only two PRs:

```
$ sed -n '348,356p' corpus/knowledge/unreal-mcp/PROVENANCE.md | grep -oE 'open PR [0-9]+' | sort | uniq -c
      1 open PR 1
      4 open PR 4
```

§5's own quoted `gh pr list` shows five open PRs: `#5`, `#4`, `#8`, `#2`, `#1`. Against §8's named set `{1,4}`, the unnamed set is `{2,5,8}` — three, not one.

**Verdict: CONFIRMED contradiction.** §5's sentence is false as written. The load-bearing freshness claim in §1–§4 (pin == tip) is unaffected; the error is in the reconciliation paragraph, which a reader would use to decide whether §8 is complete. **[O]**

---

#### C8 — The r102 lesson reports as repaired exactly the two defects it declares "still live"

**Side A (r102 `corpus/lessons/r102-unreal-integration.md`, hook 4).**

> "**Two remain live:** the r22 lesson still cites `corpus/live/runs/20261013T053632289732Z/verdicts.json`, which does not exist (`ls` → No such file or directory), and still cites `run_battery.py` sha `a065a56d…` where the file now hashes `f456bd00…`"

**Side B (r22 lesson, working tree, sha256 `8ead2129fc0b892fabead464efda201a51e29f1fffdbe4f95e2e43df61c97584`, mtime `17:48:29Z`).**

```
$ grep -n 'verdicts.json\|a065a56d' corpus/lessons/r22-unreal-review.md
48:Godot receipt `corpus/live/runs/20261013T053632289732Z/verdicts.json`, SHA-256 `a806b9e4…`
52:> - `corpus/live/runs/20261013T053632289732Z/verdicts.json` (SHA-256 `a806b9e4…3d8fc`) is a **non-resolvable live receipt**. `corpus/.gitignore:1` is `live/`, so nothing under `corpus/live/` was ever tracked; … The file is absent from this working tree and from the machine …
53:> - Three digests are **r21/r22-era blobs** … the `run_battery.py` seed `a065a56d…` (tree now `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`; …)
```

Both defects now carry a dated correction note in the r22 lesson — the exact repair the lesson's own sentence asks for ("Repair by dated correction note"). The lesson file is unchanged since `17:44:38Z` (`sha256 c7f18f28…`), so its claim is not a superseded snapshot: it is live text contradicted by the tree it points at.

**Verdict: CONFIRMED contradiction, with a timing caveat.** The r22 lesson gained its correction note at `17:47:05Z`/`17:48:29Z`, i.e. **after** the r102 lesson was written (`17:44:38Z`). So the lesson was accurate when written and is stale now. This is the same "moving tree" class the lesson itself warns about (hook 3) — and it is the reason a "still live" claim must carry an as-of stamp. **[O]**

---

### C. r102 artifacts contradicting each other

---

#### C9 — `battery-integrity.md` attributes the F8 fold to the wrong file

**Side A (r102 `reports/round-102/battery-integrity.md:34`).** "The only round-102 working-tree mutation is the **SEAT-owned F8 wording fold** in `corpus/artifacts/unreal-r22/README.md` (2 lines)".

**Side B (the two repairs' own declarations).**

```
$ head -3 reports/round-102/repairs/F8-readme-lines.md
# F8 — `corpus/knowledge/unreal-mcp/README.md` "12 lines" ambiguity, repaired
- Seat: **SEAT-28 SUBTREE-README-FIX**. Owned path: `corpus/knowledge/unreal-mcp/README.md` (only).
$ head -3 reports/round-102/repairs/F1a-r22-readme.md
# F1a — r22 artifact README path-root repair
Seat: SEAT-07 REPAIR. Owned path: `corpus/artifacts/unreal-r22/README.md` (only).
```

F8's declared path is the **subtree** README; the r22 artifact README is **F1a**. `reports/round-102/reruns/manifest.md:140-142` and `reports/round-102/git-hygiene.md:33` both correctly place the F8 fold in the subtree README.

**Verdict: CONFIRMED contradiction (label only).** `battery-integrity.md`'s substantive claim — `corpus/fixtures/` is byte-stable, 146 tracked files with 0 blob mismatches, `run_battery.py` sha256 `f456bd00…` identical worktree-vs-HEAD — was independently reproduced by this seat's reading of the same commands and is **not** in doubt. Only the F8/F1a attribution is wrong. **[O]**

---

#### C10 — `fold-spec.md`'s round-close baseline pins a sha256 that the tree does not have

**Side A (r102 `reports/round-102/fold-spec.md:34-39`).**

| surface | claimed sha256 | state |
|---|---|---|
| `corpus/lessons/r102-unreal-integration.md` | `ec6880a6dbd763d43f761cb0813de1a4e40002bb92ff44c60b48086a13601bd2` | untracked, new in r102 |
| `corpus/lessons/r22-unreal-review.md` | `d0522a6e99013891a98f96425cba53c209db01eae16c6097f060764550257656` | modified (F1b path only) |

**Side B (measured).**

```
$ sha256sum corpus/lessons/r102-unreal-integration.md
c7f18f285cd11809c632277905bd306287603d0f3c0b1302d4bd95bcf26932cc   ← claimed ec6880a6…
$ sha256sum corpus/lessons/r22-unreal-review.md
8ead2129fc0b892fabead464efda201a51e29f1fffdbe4f95e2e43df61c97584   ← claimed d0522a6e…

$ TZ=UTC stat -c '%y %n' corpus/lessons/r102-unreal-integration.md reports/round-102/fold-spec.md corpus/lessons/r22-unreal-review.md
2026-10-18 17:44:38 corpus/lessons/r102-unreal-integration.md
2026-10-18 17:50:12 reports/round-102/fold-spec.md
2026-10-18 17:48:29 corpus/lessons/r22-unreal-review.md
```

**Verdict: CONFIRMED contradiction, of two different kinds — the distinction matters.**

- **r22 lesson (`d0522a6e…` → `8ead2129…`): expected drift, not a defect.** The r22 lesson was edited at `17:47:05Z` and `17:48:29Z`, and fold-spec's own mtime is `17:50:12Z`; its pin is simply superseded by a later sibling edit. A baseline pin going stale because the pinned file changed is the normal case, and fold-spec labels the row "modified", so no error is implied.
- **r102 lesson (`ec6880a6…` → `c7f18f28…`): a real defect.** The lesson's mtime is `17:44:38Z`, which **precedes** fold-spec's `17:50:12Z`. A pin taken at `17:50:12Z` should have read `c7f18f28…`. Either the value was carried forward from an earlier read without a re-hash, or it was recorded against a revision that never persisted. Either way, the r103 queue's "must not perturb" baseline for the round's own lesson is wrong, and a folding seat that verifies its work against that table would see a spurious mismatch. **[O]**

---

### D. r102 artifacts contradicting the tree they describe

---

#### C11 — The r102 lesson's own pointer receipt fails when re-run, and its `gate/README.md:40` pointer resolves to the wrong content

**Side A (r102 lesson, "Re-running the gate").**

> - `bash /tmp/r101-closeout/pointer-check.sh corpus/knowledge/unreal-mcp` → `POINTERS=40 UNRESOLVED=0` / `STEP=PASS`
> - (`:127-128`) "(`reports/round-101/r101-critic-c3.md:365` F8, the finding; `gate/README.md:40` pins both counts)."

**Side B (measured — the lesson's exact command).**

```
$ bash /tmp/r101-closeout/pointer-check.sh corpus/knowledge/unreal-mcp
LINE-OOR corpus/knowledge/unreal-mcp/gate/README.md :: upstream/README.md:200 (max 112)
LINE-OOR corpus/knowledge/unreal-mcp/gate/README.md :: upstream/README.md:500 (max 112)
LINE-OOR corpus/knowledge/unreal-mcp/gate/README.md :: upstream/README.md:9999 (max 112)
POINTERS=43 UNRESOLVED=3
STEP=FAIL
rc=1
```

and

```
$ sed -n '40p' corpus/knowledge/unreal-mcp/gate/README.md
**Expected:** `MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0`, then `STEP=PASS`.
$ grep -c '24' corpus/knowledge/unreal-mcp/gate/README.md
0
```

Line 40 pins the 12-entry manifest check only; the string `24` occurs **nowhere** in `gate/README.md`. The F8 counts actually live at `corpus/knowledge/unreal-mcp/README.md:169-170` and `:187`.

**Verdict: CONFIRMED contradiction, two distinct failures.**

- The `/tmp`-scanner receipt does not reproduce (43/3 FAIL, not 40/0 PASS). The lesson's own *gate* receipt **does** reproduce (`POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0` / `STEP=PASS`, §3 F4) — so the lesson reports the same "40" for two scanners that provably disagree on this tree, and only one of them can be right.
- The `gate/README.md:40` pointer **resolves** (the file exists, line 40 is in range) but its claim about the target is false. A line-range check passes it. This is the more dangerous bad-pointer class, and it is the same class the r101 protocol warned about at `:454` ("A pointer can resolve and still point at the wrong content").

Both were independently found by `reports/round-102/lesson-critic.md` §3 (D2) and §4 (D3–D5); this seat re-derived them from the tree rather than quoting that file. **[O]**

---

#### C12 — The r102 lesson claims the subtree README "reverted to 12 lines" while the tree shows it did not

**Side A (r102 lesson, hook 3).**

> "Its byte-identity section changed shape twice in one session (one revision stated both counts, 24 and 12; another reverted to `12 lines`)."

**Side B (measured).** The subtree README has exactly **one** committed state and **one** working-tree state, and the working-tree state is the both-counts revision, not a reverted one:

```
$ git show HEAD:corpus/knowledge/unreal-mcp/README.md | sed -n '187p'
Observed output of the sweep (12 lines, all `OK`):                        ← HEAD: the pre-fold text

$ sed -n '187p' corpus/knowledge/unreal-mcp/README.md
Observed output of `sha256sum -c .manifest.d/audit-reference.sha256` (12 lines, all `OK`; the `*.sha256` glob prints 24 — the same 12 paths, each covered twice):
$ sha256sum corpus/knowledge/unreal-mcp/README.md
c79d8dd1d7c0c7bc934700187ee322d6d1cb20fc03cc974fa62ee2d95b8ee721
$ git diff corpus/knowledge/unreal-mcp/README.md | grep -c '^+'   → 3
```

The three-line fold (`26 insertions, 3 deletions` per `reruns/manifest.md:146`) is the only working-tree change; there is no evidence of a subsequent revert. The lesson's own hook 3 then says "Cite it by section heading, or re-read it before quoting a line number" — which is good advice that the lesson's `:127` pointer (C11) does not follow.

**Verdict: CONFIRMED contradiction (minor).** The "reverted to 12 lines" revision is not observable on the tree or in git. The stable fact the hook should carry is: HEAD holds the pre-fold text, the working tree holds the fold, and the fold is the only change. **[O]** — with the caveat that a mid-session revert-then-re-apply would leave no trace, so this is [?] on *how* the lesson arrived at the claim, and **[O]** on the claim being false of the tree as it stands.

---

## 3. What reproduced (calibration for the failures above)

The failures above are meaningful only against what held. These all reproduced **exactly**:

| # | check | command | observed |
|---|---|---|---|
| F1 | byte-pin untouched by r102 | `git diff --name-only HEAD -- corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d` | empty **[O]** |
| F2 | manifest byte-identity | `cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256` | 12 × `OK`, `RC=0` **[O]** |
| F2b | full manifest sweep | `sha256sum -c .manifest.d/*.sha256 \| grep -c ': OK$'` | `24`, 0 non-OK — **matches the F8 fold's corrected text** **[O]** |
| F3 | r101 README line pointers | `sed -n '12p;33p;74p;116p;204p;257p'` on both HEAD and worktree | all six hit the claimed sections **[O]** |
| F4 | r102 gate, all four checks | `bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo rc=$?` | `MANIFEST_OK=12 … RC=0` / `CLONE_HEAD=a6aa73ad…` / `CARDS=13 EXPECTED=13 BAD=0` / `CENSUS static-only=12 unproven-runtime=1 verified-here=0` / `POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0` / `GATE RESULT: PASS (checks failed: 0)`, `rc=0` **[O]** |
| F5 | r101 protocol step 3 (README byte/line table) | the 12-row `stat`/`wc -l` loop from protocol `:286-292` | all 12 rows match the table exactly (8398/112 … 6955/112) **[O]** |
| F6 | r101 protocol step 5 negative control | `runtime-claim-scan.sh /tmp/r102-dh/negctl` | `UNLABELED=1` / `STEP=FAIL`, `rc=1` — the control bites **[O]** |
| F7 | r101 protocol step 7 hand-sample | `sed -n '90p' upstream/README.md`, `'14p' setup.md`, `'6p' hooks.json` | `execute_tool_script` warning / two-plugins requirement / `"startup\|resume\|clear"` — all three as specified **[O]** |
| F8 | r101 label census | `label-scan.sh …/executability 13` | `CARDS=13 EXPECTED=13 BAD=0` / `STEP=PASS`; `actors-scene.md:5` the sole `unproven-runtime` **[O]** |
| F9 | lesson Law 3's F7 collision | `grep -rln 'Not \`unproven-runtime\`' corpus/knowledge/unreal-mcp/executability/*.md \| wc -l` | `6` — exactly as the lesson states **[O]** |
| F10 | r101 F8 finding is closed | `sed -n '187p' corpus/knowledge/unreal-mcp/README.md` | the folded text states both counts **[O]** |
| F11 | battery integrity | `sha256sum corpus/fixtures/run_battery.py` | `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` — matches C9's side B **[O]** |

**On the r101 report's cited line ranges.** The report's `sed -n '267,302p'` and `sed -n '303,316p'` for `adaptation-kimi.md` §5/§6 are misaligned by 3 against the landed file (§5 starts at `:270`, §6 at `:306`). Both ranges still *contain* their section header, so the evidence they were cited for holds — but they were computed against a different revision than the one they describe, which is the same root cause as C1. **[O]**

---

## 4. Verdicts and consequences

| # | contradiction | class | verdict | bears on |
|---|---|---|---|---|
| C1 | r101 C3 sizes/lines/sections (20 525 B / 330 L / 7 §; 16 666 B / 7 §) | A | **CONFIRMED** — no committed revision has these values | r101 calibration |
| C2 | r101 probe split "14 probes + 19 top-level" | A | **CONFIRMED** — actual 16 + 17; total 33 correct | r101 calibration |
| C3 | "unfiltered sweep will always read UNRESOLVED=2" | A | **CONFIRMED** — reads 0/PASS; also self-contradicts `:159` | r101 calibration |
| C4 | report receipts vs protocol §0 script revision | A | **CONFIRMED** — the two `pointer-check.sh` copies differ | r101 calibration, reproducibility guarantee |
| C5 | "38 distinct pointers" vs stated strict command | A | **CONFIRMED** — 37 strict, 38 only range-inclusive | r101 calibration |
| C6 | r102 gate falsifies r101 protocol step 7 (G6) | B | **CONFIRMED** — `UNRESOLVED=1` / `STEP=FAIL` on the gated tree | **r102 C1(a) vs r101 C3** |
| C7 | freshness-pin "PR #8 is the only item not named in §8" | B | **CONFIRMED** — §8 names `{1,4}`; unnamed are `{2,5,8}` | r102 C1(b) context |
| C8 | lesson "two remain live" (F2/F3) vs r22 lesson's correction notes | B | **CONFIRMED** — notes landed at `17:47`/`17:48`, lesson written `17:44` | r102 C1(b) |
| C9 | battery-integrity attributes F8 to the r22 README | C | **CONFIRMED** — F8 = subtree README, F1a = r22 README | r102 C2 context |
| C10 | fold-spec pins `ec6880a6…` for the r102 lesson | C | **CONFIRMED** — actual `c7f18f28…`; lesson mtime precedes fold-spec's | r103 queue baseline |
| C11 | lesson's `/tmp` receipt (40/0) + `gate/README.md:40` pointer | D | **CONFIRMED** — receipt reads 43/3 FAIL; `24` absent from `gate/README.md` | **r102 C1(a)/C1(b)** |
| C12 | lesson "another reverted to `12 lines`" | D | **CONFIRMED** of the tree; [?] on how the claim arose | r102 C1(b) |

**Consequences for the round's claims.**

1. **C1(a) — the gate itself is sound.** All four checks reproduce green on the current bytes (F4), the negative controls bite (F6, and `gate/mutation.md`'s independent M1–M6), and the manifest/pin are untouched (F1, F2). C6 does **not** impugn the gate; it impugns the *claim that the r101 C3 pointer gate still passes*, and it shows the gate's greenness depends on a self-exclusion rule that the r101 scanner does not share.
2. **C1(b) — the lesson needs two corrections.** Its `/tmp` pointer receipt (C11) and its `gate/README.md:40` pointer (C11) are both wrong, and its "two remain live" (C8) and "reverted to 12 lines" (C12) sentences are stale or unobservable. Its Laws 1–4, its F7 collision count (F9), and its gate receipt (F4) all reproduce.
3. **r101's C3 verdict should be read as scoped.** Four of its eight C3 measurements (C1), its probe decomposition (C2), its self-contamination prediction (C3), its stated script equivalence (C4) and one pointer count (C5) do not reproduce. The *artifacts* C3 claims exist do exist and their substance holds (F3, F7, F8, F9, F10) — so this is a measurement-provenance defect in the r101 report, not a fabrication and not a missing artifact.
4. **Three scanners, three answers, is the round's real calibration gap.** On `corpus/knowledge/unreal-mcp/` right now:

   | scanner | origin | result |
   |---|---|---|
   | `gate/run_gate.sh` check 4 | r102, self-excludes `gate/README.md` | `POINTERS=40 SKIPPED=0 UNRESOLVED=0` PASS |
   | protocol §0 `pointer-check.sh` | r101, exact-sentinel filter | `POINTERS=41 SKIPPED=2 UNRESOLVED=1` FAIL |
   | `/tmp/r101-closeout/pointer-check.sh` | r101, no sentinel filter | `POINTERS=43 UNRESOLVED=3` FAIL |

   A `POINTERS` number is only meaningful with its scanner identified. Any r102/r103 artifact that quotes "`POINTERS=40`" (or 41, or 43) without naming the scanner and its exclusions is quoting an under-specified measurement.

**Bounded — what this file does not establish.**

- **No runtime claim.** Unreal Editor is not installed; every live-MCP statement in the subtree and in this file is unproven by construction. Nothing above touches that.
- **No axis verdict.** This seat measures dissonance, not quality. C6 and C11 bear on C1(a)/C1(b)'s *reporting*, not on whether the gate or the subtree is correct; the L1/adjudicator owns the axis call.
- **The tree was live.** Every count above is stamped with a time and a sha256. Values that moved during the session are shown as before/after rather than reconciled; a re-run on the frozen close-out commit is required to convert any of these into a close-out verdict, exactly as `r101-verification-protocol.md:574-578` demands.
- **C12 is partly [?].** A revert-and-re-apply within one session leaves no git trace, so the observation "the tree does not show a reverted revision" is certain while the lesson's reason for saying otherwise is not recoverable from the tree.

---

## 5. Reproduce

All commands were run from the lane root unless noted.

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin

# C1 — the C3 sizes never matched the landed blob
git cat-file -s $(git rev-parse 1659c036:corpus/knowledge/unreal-mcp/PROVENANCE.md)
git cat-file -s $(git rev-parse 1659c036:corpus/knowledge/unreal-mcp/adaptation-kimi.md)
git show 1659c036:corpus/knowledge/unreal-mcp/adaptation-kimi.md | wc -l
grep -c '^## ' corpus/knowledge/unreal-mcp/PROVENANCE.md

# C2 — probe split
git ls-tree -r HEAD --name-only reports/round-101/probes/ | wc -l    # 16
git ls-tree HEAD --name-only reports/round-101/ | grep -c '\.md$'    # 17

# C3 — the "always UNRESOLVED=2" prediction
grep -rln 'upstream/nope\.md\|upstream/README\.md:9999' reports/round-101/
bash /tmp/r101-closeout/pointer-check.sh reports/round-101            # 75 / 0 PASS

# C4 — the two script revisions differ
diff /tmp/r101-closeout/pointer-check.sh /tmp/r102-dh/pointer-check.sh

# C5 — 37 vs 38
grep -rohE 'upstream/[A-Za-z0-9_./-]+:[0-9]+' corpus/knowledge/unreal-mcp/README.md \
  corpus/knowledge/unreal-mcp/PROVENANCE.md corpus/knowledge/unreal-mcp/adaptation-kimi.md \
  corpus/knowledge/unreal-mcp/executability/ | sort -u | wc -l                       # 37

# C6 — the r101 step-7 gate now fails on the tree it gates
bash /tmp/r102-dh/pointer-check.sh reports/round-101 corpus/knowledge/unreal-mcp

# C7 — PRs named in §8 vs observed open
sed -n '348,356p' corpus/knowledge/unreal-mcp/PROVENANCE.md | grep -oE 'open PR [0-9]+' | sort -u

# C8 — the r22 correction notes
grep -n 'verdicts.json\|a065a56d' corpus/lessons/r22-unreal-review.md

# C9 — F8 is the subtree README, F1a is the r22 README
head -3 reports/round-102/repairs/F8-readme-lines.md reports/round-102/repairs/F1a-r22-readme.md

# C10 — fold-spec's lesson pin
sha256sum corpus/lessons/r102-unreal-integration.md
TZ=UTC stat -c '%y %n' corpus/lessons/r102-unreal-integration.md reports/round-102/fold-spec.md

# C11 — the lesson's own receipts
bash /tmp/r101-closeout/pointer-check.sh corpus/knowledge/unreal-mcp        # 43 / 3 FAIL
bash corpus/knowledge/unreal-mcp/gate/run_gate.sh | tail -1                # PASS
sed -n '40p' corpus/knowledge/unreal-mcp/gate/README.md
grep -c '24' corpus/knowledge/unreal-mcp/gate/README.md                    # 0

# C12 — no reverted revision is observable
git show HEAD:corpus/knowledge/unreal-mcp/README.md | sed -n '187p'
sed -n '187p' corpus/knowledge/unreal-mcp/README.md
```

**Byte-pin integrity for this seat's own run (no file under the pinned subtree was modified by SEAT-61):**

```
$ git diff --name-only HEAD -- corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d
(empty)
```
