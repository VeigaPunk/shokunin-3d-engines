# r102 adjudicator DRAFT — admit/reject skeleton (game-dev-3d shokunin)

**Seat:** SEAT-47 ADJUDICATOR-DRAFT · round 102 · lane `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`
**Owned path written:** this file only. No commit, no `git` mutation, no edit to any other seat's path.
**Purpose:** a **draft**, not a verdict. It fixes the *form* of the r102 decision (the five-section
adjudication skeleton used at r98–r101), states what is already decided and what is not, and names
every finding that must still be adjudicated at close. The L1 owns the final ruling.
**HEAD at every measurement:** `2c99b7b8155841617d844c609813afcba77aa207` (r101 report-last; work
commit `1659c036`). Final measurement pass `2026-10-18T14:48:25-03:00`.
**Upstream pin:** `a6aa73ada02a9fb1f5415bec491f9942c519b297` — re-confirmed the tip of `main` this
round (`reports/round-102/freshness-pin.md` §1, three transports).

Tags: **[O]** command run by this seat, output observed · **[D]** deduped from a peer seat's receipt
(pointer given) · **[?]** not measurable here.

**Concurrency disclosure.** The tree was live-mutating under ~60 concurrent seats for the whole of
this seat's runtime. `corpus/knowledge/unreal-mcp/gate/` went **absent → present** between two
consecutive tool calls of mine; `reports/round-102/` grew **7 → 54 files**; `corpus/lessons/r102-unreal-integration.md`
went absent → 178 → 212 lines; `corpus/knowledge/unreal-mcp/README.md` changed sha256 at least twice.
Every number below is stamped with the command that produced it and marked **[moving]** where it can
still move. Re-measure all of them on the close commit.

---

## 0. Draft decision (for the L1 to confirm, amend, or overrule)

**`ADMIT-with-findings` on the r102 close commit, conditional on the C1 and C2 gates being re-run
green on the committed bytes.** Not a bare `ADMIT`: two of the six routed defects (F2's `r23`
sibling and F3's note) landed mid-flight, one finding (F7) is a **live calibration defect with no
fold**, and the gate itself carries five latent hardening gaps (fold-spec A1–A5) that are *not*
blocking but *are* part of the record.

This draft does **not** assert the decision. It asserts only: **nothing found at this seat's runtime
blocks admission**, and **the findings list below is the complete set the close-out must dispose of**.

---

## 1. The skeleton (fixed form — five sections)

Every adjudication in this lane since r98 uses this shape. r102's should be filled in the same order.

```
# Adjudicator report — round 102 (gate integration + routed-defect repair)

DECISION: <ADMIT | ADMIT-with-findings | ADMIT-corr | REJECT> on <COMMIT>
          <one paragraph: what the round adds, in numbers, and what it does not close>

## Evidence And Disposition
          one bullet per gate seat, with the numbers that seat produced and the seat's verdict

## Findings Carried Forward
          numbered; each = {what, where, measured-by, why it matters, fold-or-accept}
          every item ends with either a falsifiable acceptance command or an explicit "accept as
          disclosed contract"

## Fold Queue
          numbered; the items a folding seat applies, with the acceptance command per item

## Bounds And Non-Claims
          what the round does NOT prove, named explicitly
```

Two lane-specific invariants that must appear somewhere in the filled version, because the round
fails without them:

- **The no-editor posture.** Unreal Editor is not installed; no live-editor claim exists or can
  exist here. The gate's own spec says so (`gate/README.md:20-22`: *"A green gate is not evidence of
  live-editor behavior and must never be cited as such"*). Any adjudication text that reads a green
  gate as runtime evidence is wrong by construction.
- **The byte-pin.** `corpus/knowledge/unreal-mcp/upstream/` and `.manifest.d/` are read-only to every
  seat. Verified clean this round: `git diff --name-only HEAD -- …/upstream …/.manifest.d` → empty,
  0 lines **[O]**.

---

## 2. C1 (coverage) — what is already decided, and by what

All numbers below were re-derived by **this seat**, not quoted. Four independent gate runs, all
`rc=0`:

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo rc=$?
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0                       STEP=PASS
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0 CLONE_TRACKED=12 PATH_EXTRA=0 PATH_MISSING=0 BLOB_DIFFS=0   STEP=PASS
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0   STEP=PASS
POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0           STEP=PASS
GATE RESULT: PASS (checks failed: 0)   rc=0                    [O]
```

Independent re-derivation of two of the four checks with **my own** commands (not the gate's):

| check | my command | observed |
|---|---|---|
| manifest | `cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256` | 12 × `OK`, `rc=0` **[O]** |
| path-set equality | `diff <(cd upstream && find . -type f \| sed 's\|^\./\|\|' \| sort) <(git ls-files corpus/knowledge/unreal-mcp/upstream \| sed 's\|…/upstream/\|\|' \| sort)` | empty diff, `PATHSET_EQUAL=1 rc=0`, 12/12 **[O]** |
| card census | first-line-token scan over `executability/*.md` | `12 static-only`, `1 unproven-runtime`, 13 cards **[O]** |
| manifest glob | `sha256sum -c .manifest.d/*.sha256 \| grep -c ': OK'` | `24` **[O]** — matches the F8 fold's own wording |

**Non-author support.** `gate/review.md` (SEAT-22) re-ran the gate from `/tmp` (cwd-independence
holds); `gate/mutation.md` (SEAT-18) 7/7 mutations exit 1, no false PASS; `reruns/{manifest,labels,links,pointers}.md`
re-derive all four checks with independently written scanners; `adversary/F1.md`, `F3.md`, `F5.md`,
`F6.md` argue the contrary where it matters **[D]**.

**Draft disposition: C1(a) SUPPORTED.** The gate is self-contained, path-independent, fail-closed,
mutation-robust, and green on four independent runs by this seat. `C1(b)`
(`corpus/lessons/r102-unreal-integration.md`, 212 lines, 7 sections, sha256 `c7f18f28…32cc` **[moving]**)
and `C1(c)` (`engines.md` Unreal row, sha256 `d03907d3…bddf` **[moving]**) are **present and
internally consistent**; the lesson's 17 repo pointers were swept by this seat with 0 missing paths
and 0 out-of-range lines **[O]**.

**What C1 does not establish.** The gate's green verdict **does not close F7** (§4.1) — check 3
enforces *one allowed label per card*, which is exactly the property F7 shows is insufficient. A
green gate must not be read as F7 being closed. That sentence belongs in the filled adjudication.

---

## 3. C2 (depth) — the routed-defect lattice, per-defect disposition

Draft rulings, each with the deciding command this seat ran. "In place" = mechanical
command/path conformance fix; "dated note" = the correction-note discipline (never silently
rewrite a historical factual claim).

| # | defect | draft ruling | my evidence |
|---|---|---|---|
| **F1a** | r22 artifact README roots commands at `.shokunin/game-dev-3d/` | **REPAIRED, in place** | before (`HEAD` blob) `python3 .shokunin/…/verify_descriptor.py` → `exit=2`; after: `PASS local-static actual=accept expected=accept`, `exit=0`; reject arm `exit=0` **[O]** |
| **F1b** | same root in `corpus/lessons/r22-unreal-review.md` (7 lines) | **REPAIRED, in place** | `grep -c "\.shokunin/game-dev-3d" corpus/lessons/r22-unreal-review.md` → `0` **[O]** |
| **F2** | r22 lesson cites gitignored `corpus/live/runs/20261013T053632289732Z/verdicts.json` | **REPAIRED as a dated note** | note present (`grep -c "Correction note (r102"` → `1`); the historical cite is preserved verbatim (`grep -c "20261013T053632289732Z"` → `2`: the paragraph + the note's own reference) **[O]** |
| **F2b** | the **same absent receipt is also cited at `corpus/lessons/r23-ortho-review.md:3`** (plus two more absent live receipts at its tail) | **NOT REPAIRED — carry to r103** | `grep -c -i "correction note" corpus/lessons/r23-ortho-review.md` → `0`; the three cited `corpus/live/…` paths are all ABSENT **[O]** |
| **F3** | r22 lesson cites `run_battery.py` seed SHA `a065a56d…` | **REPAIRED as a dated note; ruled archival, not stale** | the note landed and reproduces its own numbers: `git cat-file blob 8b21cae:corpus/fixtures/run_battery.py \| sha256sum` → `a065a56d…2570`; `sha256sum corpus/fixtures/run_battery.py` → `f456bd00…1ef69f` **[O]** |
| **F4** | card claims `17 words`, its own stated command yields `13` | **NOT REPAIRED** | re-derived: whole line `18`, after-label `13`, minus-leading-dash `17`; the card now reads **13** at `assets-content.md:393` **[O]** — the number moved; **re-check at close** (see §4.4) |
| **F5** | `engines.md` three.js evidence command fails from a clean tree | **REPAIRED, in place** | `git archive HEAD corpus/fixtures/three \| tar -x -C /tmp/…` then bare `node …/run_cases.mjs` → `FAIL … 3/3`, `exit=1`; after `npm ci --prefix corpus/fixtures/three` in the same clean tree → `PASS three battery: 3/3, seeds_unchanged=true`, `exit=0` **[O]** |
| **F6** | `rea.md` census claims JADX/Binwalk/Unblob absent | **REPAIRED as a dated note; mint sentence preserved** | `grep -c "no Ghidra, JADX, Binwalk/Unblob, pwntools" corpus/knowledge/rea.md` → `1` (preserved); the note's own claims re-derive: `REA_PWNTOOLS_PYTHON -c "import pwnlib"` → `4.15.0` `rc=0`; `REA_JADX_MCP_JAR` → 42 619 858 B jar; `java -version` → OpenJDK `21.0.12.1` **[O]** |
| **F8** | subtree README `:187` said the glob sweep prints "12 lines" | **REPAIRED, in place (wording fold)** | the fold now names both counts: `audit-reference.sha256` → **12**, glob → **24**, each `OK`, exit `0`; my own run of the glob gives `24` **[O]** |

**Adversarial rulings the L1 must accept or overrule, not silently absorb** **[D]**:

- `adversary/F3.md` (SEAT-13): the digest is an **archival content address**, correctly cited for its
  round; repair by qualifier + commit pointer, **renumbering explicitly rejected**. The landed note
  is consistent with this ruling.
- `adversary/F5.md` (SEAT-14): F5 is an environment fact, not a defect attribution; the real
  sub-defects are the non-discriminating `3/3` token and the pointer/precondition split across two
  cells; plus an adjacent dead path root in `corpus/fixtures/three/README.md:6`.
- `adversary/F6.md` (SEAT-15): the census was **correct at authoring** (installs landed ~13h52m
  after the r1 commit); the "wrong at mint" framing in `before/F6-rea-census.md` §2 is unsupported.
- `adversary/F1.md` (SEAT-11): F1 is real but the routed premise (".shokunin never existed") is
  **false in the predecessor worktree**; disposition ruled *in-place command block only*, systemic
  scope (142 tracked files) deferred to the L1.

**Draft disposition: C2 SUPPORTED as a lattice**, with **F2b open**, **F4's number moved and
unverified as a repair**, and three adversarial reclassifications awaiting the L1's ruling. That is
`ADMIT-with-findings`, not `ADMIT`.

---

## 4. Findings list — everything still to be disposed of

Format per item: **{finding} — {where} — {deciding command} — {draft disposition}**.

### 4.1 F7 — the label vocabulary is still two vocabularies **[live defect, no fold]**

Where: `corpus/knowledge/unreal-mcp/README.md:41` defines `unproven-runtime` as *"the claim needs the
live editor and nothing was observed"*; six of the 13 cards explicitly reject that label on the
ground that the runtime path *"is not even identified"*.

```
$ grep -rln 'Not `unproven-runtime`' corpus/knowledge/unreal-mcp/executability/*.md | wc -l
6                                                    [O]
```

Draft disposition: **carry as a live calibration finding; the round does not close it and the
adjudication must say so.** Two groups with the same epistemic situation land on opposite labels, so
the 13-label census cannot be compared across cards. Fold spec: amend `README.md:41` to state which
side owns "path not even identified", **or** amend the six cards — one must win. Acceptance: after
the fold, the same six cards and `actors-scene.md` must be justifiable under a single written
definition, and `gate/README.md`'s pinned census must be re-pinned as an explicit, reviewed relabel
(not a silent edit that leaves the gate green).

### 4.2 Gate check 4 does not range-check a multi-endpoint pointer's tail **[latent; falsified by me]**

Where: `gate/run_gate.sh` extraction regex `…:[0-9]+` matches only the **first** number of a range.
The round's own sweep resolves every endpoint, so the two disagree on the same tree: **40 vs 47**.

Falsified by this seat on scratch copies (repo untouched) — a planted tail is invisible to the gate
but caught by the sweep:

```
$ printf '\nsee upstream/README.md:1-9999\n' >> <copy>/materials.md
$ bash <copy>/gate/run_gate.sh | tail -2
GATE RESULT: PASS (checks failed: 0)          rc=0        [O]   ← gate: invisible
$ BASE=<copy> bash reports/round-102/reruns/pointer-sweep.sh <copy> | tail -1
FILES_SCANNED=17 POINTERS=49 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=1   STEP=FAIL   [O]  ← sweep: caught
```

Direction of failure is **fail-open on the tail endpoint only**; all 11 tail endpoints in the tree
are currently in range, so nothing is falsely red today. The gate's own control C3 plants a
single-endpoint out-of-range pointer, which it does catch — the blind spot is specifically the
multi-endpoint form.

Draft disposition: **accept as a disclosed latent gap for r102; fold in r103.** Acceptance: adopt the
sweep's regex + per-endpoint loop; the gate must print `POINTERS=47` (not 40) with `UNRESOLVED=0`,
and the planted-tail control must flip check 4 to `STEP=FAIL`.

### 4.3 Gate hardening gaps A2–A5 **[latent; folded spec exists]** **[D]**

`reports/round-102/fold-spec.md` §2 documents four more, each falsified on a scratch copy: **A2**
first-token-wins label rule is position-fragile (a prose sentence above the declaration produces a
false FAIL on a correctly-labelled card); **A3** check 3 counts cards but never compares their
**names** (a typo'd rename keeps the gate green); **A4** an unreachable upstream is reported as
`STEP=FAIL`, indistinguishable in the exit channel from a byte mismatch; **A5** check 1 never runs
the 11 seat shards (a corrupted `seat02.sha256` leaves the gate green). Each carries a falsifiable
acceptance in that file. Draft disposition: **carry as the r103 gate-hardening queue**, with A4 and
A5 the ones a close-out reader is most likely to trip over.

### 4.4 F4 — the `17 words` / `13 words` number **[needs a close re-check]**

The card at `assets-content.md:393` now reads **13** and cites `wc -w` on the text after the
`**Assets and Content** - ` label. Re-derived by this seat on `upstream/README.md:102`: whole line
`18`, after-label `13`, minus-leading-dash-only `17` **[O]**. The number and the method now agree —
but the card changed during the round, so the adjudication must re-run the deciding command on the
**committed** bytes rather than accept either the before-capture or this draft. Acceptance:
`sed -n '102p' …/upstream/README.md | sed 's/.*\*\*Assets and Content\*\* - //' | wc -w` → `13`,
matching the number printed in the card.

### 4.5 F2b — the `r23` sibling citation **[live defect, unowned]**

`corpus/lessons/r23-ortho-review.md:3` cites the same absent, gitignored
`corpus/live/runs/20261013T053632289732Z/verdicts.json`; its tail cites two further absent receipts
(`…054038500246Z`, `…054038500353Z`). None is resolvable from a clone. Draft disposition: **carry to
r103 as a new routed defect** (the r102 charter named F1/F2/F3/F5/F6 + the F8 fold; this sibling was
not in the lattice). Acceptance: the r23 lesson gains a dated correction note of the same shape as
the r22 one, with the historical text preserved.

### 4.6 The dead `.shokunin/game-dev-3d/` root outside the repaired files **[live defect, systemic]**

Repaired this round: `corpus/artifacts/unreal-r22/README.md`, `corpus/lessons/r22-unreal-review.md`.
Still failing verbatim from the repo root **[O]**:

```
$ python3 .shokunin/game-dev-3d/corpus/artifacts/glb-r12/run_import.py            exit=2
$ node    .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs               exit=1
$ uv run --no-project --with pyyaml python .shokunin/game-dev-3d/corpus/artifacts/unity-r19/verify_scene.py  exit=2
```

Scale, re-derived: `grep -rl "\.shokunin/game-dev-3d" corpus/lessons/*.md | wc -l` → **80**;
`grep -rl "^(python3|node|bash|uv run|npm) .*\.shokunin/game-dev-3d" corpus/lessons/*.md | wc -l` →
**42** runnable-looking command lines in lessons, plus 3 artifact/fixture READMEs **[O]**.
Draft disposition: **do not repair as part of r102 close**; record the scope and let the L1 rule
(per `adversary/F1.md`, the root *was real in the predecessor worktree*, so this is a
presentation/portability defect, not a fabrication). Acceptance: either one seat per file with
in-place re-rooting, or a single documented statement that historical lessons are
worktree-relative by convention.

### 4.7 Numbers found WRONG in peer artifacts **[minor, self-disclosed]** **[D]**

`math-audit.md` (SEAT-58) re-derived **99 numbers across 28 files: 97 VERIFIED / 2 WRONG**
(`battery-integrity.md`'s `node_modules` count `1410` → measured `1264`; `reports-index.md`'s
`adversary/F3.md` byte count/sha, where the file was rewritten after that frame). Plus two
snapshot-local values that drifted by timing. Draft disposition: **accept as disclosed; no
load-bearing number was wrong** — nothing touching the byte-pin, the four checks, the 350 `CASES`
rows, the 12/24 manifest counts or the 13-card census.

### 4.8 No standing harness reaches the gate **[structural]** **[D]**

0 gate references in the 130-entry digest map; the gate writes no receipt. Its green verdict survives
only as a hand-pasted transcript. Draft disposition: **carry as an r103 coverage item**
(`--receipt <path>` flag mirroring `three/run_cases.mjs`).

---

## 5. Fold queue (draft — what a folding seat would apply)

1. **F2b** — dated correction note on `corpus/lessons/r23-ortho-review.md`. Acceptance: the three
   absent `corpus/live/…` cites remain verbatim, a dated note exists, and the note states the
   gitignore reason.
2. **A1** — range-aware pointer sweep in `gate/run_gate.sh`; gate must print `POINTERS=47`.
3. **A2/A3/A5** — label-declaration rule, card-name set comparison, shard-manifest run.
4. **A4** — a distinct `BLOCKED` state (token + exit code) or a `GATE_REF=<path>` offline mode.
5. **F7** — the one *semantic* fold: pick a side of the label split and re-pin the census explicitly.
6. **F4** — re-run the acceptance command on the committed bytes; close if it still prints `13`.

---

## 6. Bounds and non-claims (must appear in the filled version)

- **No live-editor evidence exists or can exist on this host.** Unreal Editor is not installed;
  the install wall was re-run this round and **nothing changed** (`install-recheck.md`: repo 404
  `exit=128`, `gh api` 404, AUR PKGBUILD aborts at `prepare()` line 280). Every live-editor claim is
  `unproven-on-this-host` by construction.
- **A green gate is a static statement only** — the vendored bytes equal the pinned upstream commit,
  and four static checks ran here. It is not evidence about the editor.
- **C1 is scoped to the pin** — all files tracked *at* `a6aa73ad…`; content outside the pin is
  recorded, not vendored (`PROVENANCE.md` §8).
- **F7 is open and the gate cannot see it.** Do not read `CENSUS … EXPECTED=12/1/0 STEP=PASS` as
  evidence that the label vocabulary is coherent.
- **The gate needs the network** (check 2 clones upstream); offline it exits 1 fail-closed.
- **This draft is not the verdict.** The L1 lands the ruling, `LOG.md`, `SCORECARD.md` and the axis
  rows at round close.

---

## 7. Reproduce (this seat's whole evidence set)

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin

# C1 — gate (4 runs by this seat, all rc=0)
bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "rc=$?"

# C1 — independent re-derivation
cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256; cd -
diff <(cd corpus/knowledge/unreal-mcp/upstream && find . -type f | sed 's|^\./||' | sort) \
     <(git ls-files corpus/knowledge/unreal-mcp/upstream | sed 's|corpus/knowledge/unreal-mcp/upstream/||' | sort)
(cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/*.sha256 | grep -c ': OK')   # 24

# C2 — F1a before/after, F5 before/after
git show HEAD:corpus/artifacts/unreal-r22/README.md | sed -n '8,9p'      # dead root
python3 corpus/artifacts/unreal-r22/verify_descriptor.py; echo "exit=$?"
rm -rf /tmp/f5 && mkdir -p /tmp/f5 && git archive HEAD corpus/fixtures/three | tar -x -C /tmp/f5
(cd /tmp/f5 && node corpus/fixtures/three/run_cases.mjs; echo "clean-tree exit=$?")
(cd /tmp/f5 && npm ci --prefix corpus/fixtures/three && node corpus/fixtures/three/run_cases.mjs; echo "after exit=$?")

# C2 — F2/F3/F6 notes and the absent-receipt census
grep -c "Correction note (r102" corpus/lessons/r22-unreal-review.md
git cat-file blob 8b21cae:corpus/fixtures/run_battery.py | sha256sum
sha256sum corpus/fixtures/run_battery.py
grep -c -i "correction note" corpus/lessons/r23-ortho-review.md     # 0 → F2b open
which jadx binwalk unblob; ${REA_PWNTOOLS_PYTHON:-python3} -c "import pwnlib; print(pwnlib.version)"

# F7 and the gate blind spot
grep -rln 'Not `unproven-runtime`' corpus/knowledge/unreal-mcp/executability/*.md | wc -l   # 6
cp -r corpus/knowledge/unreal-mcp /tmp/ctl && printf '\nsee upstream/README.md:1-9999\n' >> /tmp/ctl/materials.md
bash /tmp/ctl/gate/run_gate.sh | tail -2                                       # PASS  ← blind
BASE=/tmp/ctl bash reports/round-102/reruns/pointer-sweep.sh /tmp/ctl | tail -1 # FAIL ← caught
```

**Protected paths — clean at this seat's runtime [O]:**
`git diff --name-only HEAD -- LOG.md SCORECARD.md SHONEN.md SKILL.md PROVINCE.md corpus/fixtures
reports/round-101 corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d`
→ **0 lines**.

## 8. Files this seat wrote

- `reports/round-102/r102-adjudicator-draft.md` — this file. Nothing else was written; no commit,
  push, checkout or reset was performed.
