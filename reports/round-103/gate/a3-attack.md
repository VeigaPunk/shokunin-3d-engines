# A3-ATTACK — the card-name set is not compared; the gate can be made green over a typo-named card

**Seat:** SEAT-13 A3-ATTACK · round 103 · lane `game-dev-3d-shokunin`
**Owned path:** this file only (`reports/round-103/gate/a3-attack.md`). No other file was written by this seat.
**Date:** 2026-10-18
**Lane HEAD at start:** `c85a816e227984272a3c29b58aa7f7c1a76f1e9c` (r102 report-last; work `c6f655d`)
**Gate under attack:** `corpus/knowledge/unreal-mcp/gate/run_gate.sh`
sha256 `412d1b84857233e8992b7da4888a61faae6832bffe0b7c70f962b21febf5ea96` (tracked at HEAD; `git ls-files` confirms both `gate/run_gate.sh` and `gate/README.md`)
**Claim served:** C2 (depth) — fold-spec A3, `reports/round-102/fold-spec.md` §2/A3.

**No Unreal runtime claim appears anywhere in this file.** Unreal Editor is not installed on this host and
live-MCP behaviour is unproven by construction; nothing below says anything about the editor.

---

## 0. Result in one line

The A3 attack **fails the gate** — `GATE RESULT: FAIL`, exit 1 — and the requirement "gate must FAIL"
is met. But the mechanism is **not** the one A3 was written to install: CHECK 3 contains **no card-name
comparison at all** (`grep -c 'EXPECTED_NAMES\|NAME_SET\|declared_names' run_gate.sh` → `0`), and on the
rename-only variant CHECK 3 prints `CARDS=13 EXPECTED=13 BAD=0 / STEP=PASS`. The rename is caught only
**incidentally**, by CHECK 4's backtick pointer sweep noticing that the referring documents still name the
old filename. When the referring documents are made consistent with the typo name, **the entire gate goes
green over a card set that has no `sequencer.md`** — a full false PASS. That is the A3 gap, still open.

## 1. Baseline — the gate is green on the frozen HEAD bytes

Run from the repo root, unmutated:

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "GATE_RC=$?"
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0 CLONE_TRACKED=12 PATH_EXTRA=0 PATH_MISSING=0 BLOB_DIFFS=0
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
POINTERS=88 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)
GATE_RC=0
```

`POINTERS=88` here, not the `87` of the lane brief. The count is **scanner- and tree-relative**, not a
constant: it moves whenever any prose file under the subtree gains or loses a backtick-wrapped path, and
concurrent seats were editing exactly that prose while this seat ran (a sibling re-pinned the same value
to `90` mid-run — see §5). `UNRESOLVED=0` is the binding invariant (fold-spec §1 makes the same point);
the count is an advertised measurement, not a contract, and is not compared across rounds.

## 2. The attack, and the four variants run

**The mutation required by this seat.** Rename one card file to a typo name and drop a correctly-named
replacement that carries **no label**:

```
executability/sequencer.md   ->   executability/sequencer_.md     (typo name, label intact)
executability/sequencer.md   <-   correctly-named replacement, NO label line anywhere
```

I ran the mutation in four variants, because the first run showed the two failure modes are separable and
only one of them is what A3 promised to fix.

### Harness (reproducible)

Every variant runs on a subtree extracted from the **frozen HEAD blob**, never on the live worktree —
the worktree went red mid-run under a concurrent seat (§5), and a control that moves is not a control:

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
R=$(pwd); A=/home/vgpnk/r103-vN; rm -rf $A; mkdir -p $A
git archive HEAD corpus/knowledge/unreal-mcp | tar -x -C $A          # frozen bytes, HEAD=c85a816
# symlink the live siblings so CHECK 4's repo-relative sweep resolves at the same depth
for e in corpus/*; do b=$(basename "$e"); [ "$b" = knowledge ] && continue; ln -s "$R/$e" "$A/corpus/$b"; done
for e in corpus/knowledge/*; do b=$(basename "$e"); [ "$b" = unreal-mcp ] && continue; ln -s "$R/$e" "$A/corpus/knowledge/$b"; done
ln -s "$R/reports" "$A/reports"
bash $A/corpus/knowledge/unreal-mcp/gate/run_gate.sh
```

**Control on this exact harness, unmutated:** `CARDS=13 EXPECTED=13 BAD=0`, `POINTERS=88 … UNRESOLVED=0`,
`GATE RESULT: PASS (checks failed: 0)`, exit 0.

### V1 — rename + unlabeled replacement (the literal seat instruction)

```
CHECK 3 verdict-card-scan
OK   static-only      scripting-programmatic.md      line 5
FAIL no-label       /home/vgpnk/r103-v1/corpus/knowledge/unreal-mcp/executability/sequencer.md
OK   static-only      sequencer_.md                  line 5
OK   static-only      testing-automation.md          line 5
CARDS=14 EXPECTED=13 BAD=1
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
STEP=FAIL

CHECK 4 pointer-sweep
POINTERS=88 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS

GATE RESULT: FAIL (checks failed: 1)
```

Caught by the **unlabeled-card** rule (`FAIL no-label`), and by count (`CARDS=14`). Note CHECK 4 is
**green** here — the typo'd `sequencer_.md` is not referenced by anything, so nothing dangles.

### V2 — rename only, referring docs made consistent with the typo name

Rename, no replacement (13 cards), and the attacker also updates the four documents that name the file
(`README.md`, `PROVENANCE.md`, `executability/animation-controlrig.md`, `gate/README.md`):

```
$ grep -rn 'executability/sequencer\.md' $S --include='*.md' | grep -v '/upstream/'
(none)

CHECK 3 verdict-card-scan
OK   static-only      sequencer_.md                  line 5
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
STEP=PASS

CHECK 4 pointer-sweep
POINTERS=88 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS

GATE RESULT: PASS (checks failed: 0)
```

**This is the finding.** `GATE RESULT: PASS`, exit 0, over a 13-card set in which the Sequencer card is
named `sequencer_.md`. CHECK 3 counts cards and reads their labels but never compares their names;
CHECK 4 only sees names that some other document happens to spell out. A rename that is internally
consistent is invisible to both. The declared name set (`README.md:215-227`, 13 rows, row 7 =
`executability/sequencer.md`) is never read by the gate.

### V3 — rename only, referring docs left untouched (the isolation)

```
CHECK 3 verdict-card-scan
OK   static-only      sequencer_.md                  line 5
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
STEP=PASS

CHECK 4 pointer-sweep
MISSING-PATH-REL executability/sequencer.md
POINTERS=88 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=1
STEP=FAIL

GATE RESULT: FAIL (checks failed: 1)
```

CHECK 3 **passes** on the typo-named set; the red comes entirely from CHECK 4, and only because
`README.md:221` (and `PROVENANCE.md:283`, `animation-controlrig.md:220`) still spell `sequencer.md`.
This isolates the blindness: it is CHECK 3 that does not compare names, exactly as fold-spec A3 says.

## 3. Variant matrix

| variant | mutation | referring docs | exit | CHECK 3 | CHECK 4 | caught by |
|---|---|---|---|---|---|---|
| control | none | — | 0 | PASS `CARDS=13 BAD=0` | PASS `UNRESOLVED=0` | — |
| **V1** | rename + unlabeled replacement | untouched | **1** | **FAIL** `CARDS=14 BAD=1`, `FAIL no-label` | PASS | unlabeled-card rule + count |
| **V2** | rename only (13 cards) | made consistent with typo name | **0** | PASS `CARDS=13 BAD=0` | PASS `UNRESOLVED=0` | **nothing — full false PASS** |
| **V3** | rename only (13 cards) | untouched | **1** | PASS `CARDS=13 BAD=0` | FAIL `MISSING-PATH-REL executability/sequencer.md` | CHECK 4, incidentally |

Read the table downward: the seat's required mutation (V1) is caught, but **not by a name check** — by the
label rule and the count. Remove the replacement and the rename alone slips CHECK 3 (V3). Make the tree
self-consistent and it slips the whole gate (V2).

## 4. Falsifiable acceptance for the A3 fold (unchanged from fold-spec)

The gate must compare the `basename` set under `executability/` against the 13 declared domain names and
print e.g. `NAME_SET=OK`, failing closed on any mismatch. Acceptance, re-derived here:

1. `grep -c 'NAME_SET\|EXPECTED_NAMES' corpus/knowledge/unreal-mcp/gate/run_gate.sh` → `≥ 1` (today `0`).
2. **V3** (rename only, docs untouched) must fail with a *name-set* signal, not only `MISSING-PATH-REL`:
   the transcript must name the missing/extra basename.
3. **V2** (rename only, docs consistent) must be `STEP=FAIL` / exit 1 — today it is a clean PASS.
4. The unmodified tree must still print `CARDS=13 EXPECTED=13 BAD=0` / `GATE RESULT: PASS`.
5. Existing control **C6** (`rm executability/sequencer.md`) must still fail — a name-set check subsumes
   the count check and must not regress it.

A count-only check cannot satisfy (2) or (3): both variants have the right count and the right census.

## 5. Environment notes (why the evidence looks the way it does)

- **The live worktree went red during this seat's run**, from a *concurrent* seat's authoring, not from
  anything here:

  ```
  $ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "REAL_RC=$?"
  MISSING-PATH-REL reports/round-103/note/author.md
  POINTERS=90 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=1
  GATE RESULT: FAIL (checks failed: 1)
  REAL_RC=1
  $ git status --porcelain corpus/knowledge/unreal-mcp/
   M corpus/knowledge/unreal-mcp/adaptation-kimi.md
  ```

  A sibling landed a pointer to `reports/round-103/note/author.md` before that file existed. That is a
  **CHECK 4 false red on a live, mid-round tree** — worth noting for whoever runs the close-out gate: the
  gate must be run against a settled tree, and its check 4 sweep treats every `reports/...` backtick path
  as a live target. This seat changed no file under `corpus/`; the `adaptation-kimi.md` modification is
  the C1 freshness-note seat's, not mine.
- **`/tmp` was intermittently unusable**: a shared `tmpfs` user quota filled by concurrent seats produced
  `error: copy-fd: write returned: Disk quota exceeded` from `git clone`, which makes CHECK 2 print
  `FAIL fresh clone failed (network down or repo unreachable) — BLOCKED, not PASS` / `STEP=FAIL`. Three
  consecutive re-runs of the same copy returned `GATE RESULT: PASS` when the quota recovered, so this is
  environmental, **not** a gate defect — but it is a live demonstration of fold-spec **A4**: a
  quota/network-blocked host is indistinguishable in the exit channel from a real byte mismatch. This
  seat's harness therefore lives under `$HOME`, not `/tmp`.
- **`LANE_HEAD=870a976…`** appears in the harness transcripts. The gate derives it from `git -C "$SUB"
  rev-parse HEAD`, and the `$HOME`-rooted harness resolves to `/home/vgpnk`, which is itself a git repo
  (the operator's home). The `SUBTREE=` line in every transcript is the harness path, and all four
  `STEP=` lines are the mutated subtree's own bytes. The repo-root control in §1 (`LANE_HEAD=c85a816…`)
  is the authoritative one.
- **The sibling subtree was moving under this seat, and one sibling edit touched `gate/README.md`.**
  Its diff (17 insertions, 3 deletions vs HEAD) re-pins the advertised `POINTERS` value `87` → `90` and
  adds a paragraph on the two-pass sweep; it is **not** this seat's edit and it does **not** perturb the
  CHECK 3 code path this file argues about. Verified that this seat's `sed` did not leak into the real
  tree: `grep -c 'executability/sequencer\.md'` on the live `gate/README.md` → `2`, and
  `grep -c 'executability/sequencer_\.md'` → `0`. All mutations in §2 were made to copies under `$HOME`.
- Every variant is a copy under `$HOME`. **No repository file was modified by this seat**, and no finding
  depends on any scratch path surviving.

## 6. Reproduce

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
git rev-parse HEAD                      # c85a816e227984272a3c29b58aa7f7c1a76f1e9c
sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh
# 412d1b84857233e8992b7da4888a61faae6832bffe0b7c70f962b21febf5ea96

# A3 is unlanded: no name-set comparison exists
grep -c 'EXPECTED_NAMES\|NAME_SET\|declared_names' corpus/knowledge/unreal-mcp/gate/run_gate.sh   # 0

# V2 — the full false PASS. Build the frozen harness, rename, make refs consistent, run.
R=$(pwd); A=/home/vgpnk/r103-v2; rm -rf $A; mkdir -p $A
git archive HEAD corpus/knowledge/unreal-mcp | tar -x -C $A
for e in corpus/*; do b=$(basename "$e"); [ "$b" = knowledge ] && continue; ln -s "$R/$e" "$A/corpus/$b"; done
for e in corpus/knowledge/*; do b=$(basename "$e"); [ "$b" = unreal-mcp ] && continue; ln -s "$R/$e" "$A/corpus/knowledge/$b"; done
ln -s "$R/reports" "$A/reports"
S=$A/corpus/knowledge/unreal-mcp
sed -i 's|executability/sequencer\.md|executability/sequencer_.md|g' \
  $S/README.md $S/PROVENANCE.md $S/executability/animation-controlrig.md $S/gate/README.md
mv $S/executability/sequencer.md $S/executability/sequencer_.md
bash $S/gate/run_gate.sh; echo "V2_RC=$?"     # GATE RESULT: PASS (checks failed: 0), exit 0
```

## 7. Limits of this file

- One seat, one owned path. This seat wrote **only** `reports/round-103/gate/a3-attack.md`.
- The finding is a **latent** gap on a settled tree — the unmodified tree is green and CHECK 3 passes it
  honestly. V2 is a mutation control, not a defect in the shipped card set.
- The gate's own sha256 is the r102-landed one; a sibling seat hardening `run_gate.sh` concurrently would
  invalidate §1's hash, not §2's argument, which rests on the CHECK 3 code path (`run_gate.sh:159-193`),
  which has no name comparison in any form.
- **No Unreal runtime claim.** A green gate is never evidence of live-editor behaviour, and a red one
  says nothing about the editor either.
