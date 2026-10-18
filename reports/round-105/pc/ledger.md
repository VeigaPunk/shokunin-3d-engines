# r105 · SEAT-28 PC-LEDGER — operator queue for F7

**Owned path:** `reports/round-105/pc/ledger.md` only.

**Axis:** calibration (with coverage through the landing checklist).
**State:** proposed decision package; **not a ruling and not applied**.  Do not treat either branch below as adopted. This seat did not edit `SKILL.md`, the knowledge subtree, cards, upstream bytes, or manifests.

## Queue item: resolve the P/C label-precedence collision

**Question for the operator:** which rule controls when the central mapping in `corpus/knowledge/unreal-mcp/README.md` and an individual verdict card imply different meanings for `unproven-runtime`?

This is r101 finding F7, carried into r102 and still called open in `SKILL.md` §4. It is a label-semantics question; it does **not** change the binary `proven` / `unproven` policy for claims, establish Unreal runtime evidence, or authorize edits to byte-pinned `upstream/` or `.manifest.d/` files.

### Current frame — command evidence, not a ruling

All commands below were run from the lane root on HEAD `1eaa5680c22a704ddf05f9b51ff3fcc731b9be8b`.

- `sha256sum corpus/knowledge/unreal-mcp/README.md SKILL.md` → README `c79d8dd1d7c0c7bc934700187ee322d6d1cb20fc03cc974fa62ee2d95b8ee721`; `SKILL.md` `b4b94dd151b1d97bb4916ae150e740758730880b552ee741041664cc44ffa986`.
- `grep -rln 'Not \`unproven-runtime\`' corpus/knowledge/unreal-mcp/executability/*.md | sort` → exactly six: `animation-controlrig.md`, `blueprints.md`, `editor-general.md`, `gameplay-gas.md`, `materials.md`, `meshes-textures.md`.
- `find corpus/knowledge/unreal-mcp/executability -maxdepth 1 -type f -name '*.md' | wc -l` → `13`. The per-card first-label scan (`for f in ...; grep -m1 -oE 'verified-here|static-only|unproven-runtime'`) → `verified-here=0 static-only=12 unproven-runtime=1` (`actors-scene.md` is the one runtime label).
- `sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh` → `390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf`. `GATE_WORKDIR=/dev/shm bash corpus/knowledge/unreal-mcp/gate/run_gate.sh` → checks 1–4 `STEP=PASS`, `CARDS=13 EXPECTED=13 BAD=0`, `CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0`, `UNRESOLVED=0`, `GATE RESULT: PASS (checks failed: 0)`, `GATE_RC=0`. This verifies the current tree only; the gate checks census and path resolution, not P/C semantics.
- `sed -n '232,279p' reports/round-102/skill-decision-table-draft.md` → historical Options P and C both retain the six cards as `static-only`; the dispute is whether the central mapping or each card is authoritative for future citations. `sed -n '114,136p' SKILL.md` → §4 still says the ruling is owed and gives an interim rule. `sed -n '317,363p' reports/round-101/r101-critic-c3.md` → F7 records the incompatible readings and the 6/13 plus 11/1 census at that earlier frame.
- `find reports/round-105/pc -maxdepth 2 -type f -print 2>/dev/null | sort` → no files at this inventory snapshot; do not infer a later package is absent.

### Decision branches to put to the operator

Keep both choices visible in the proposal and impact diff. The package must not quietly choose one.

**P — policy-first.** Make the README mapping the binding rule. Adopt an operational distinction: `static-only` applies when locally checked document facts are the only proven part and no runtime observation exists; `unproven-runtime` applies when a concrete runtime path is identified but unobserved. State the test for “identified” and reconcile the README wording with it. Under the r102 draft's reading, the six dissenting cards remain `static-only`; `actors-scene.md` remains `unproven-runtime` because its card says the dispatch path is identified. Update affected label-basis prose and the skill table to follow the single rule.

**C — card-first.** Make each card authoritative for its own verdict; the central mapping is descriptive, not a precedence rule. Preserve current labels unless a card's own evidence is independently found inconsistent. Require cross-card claims to name and cite the card(s) they summarize, and state that equal label strings alone do not establish comparable semantics. Update the README and skill table to make this authority boundary explicit.

Both branches must leave the binary evidence policy and “no live-editor claim without a receipt” unchanged. The operator's chosen rule, its rationale, date/identity, and any rejected alternative must be recorded in the accepted ruling document. If the operator rejects both, keep F7 open and make no landing edits.

## Landing queue after the operator decides

1. **Preserve the decision as durable lane knowledge.** Recommended home: `corpus/knowledge/unreal-mcp/label-precedence.md`, linked from the README's mapping section. This is the consumer-facing policy corpus, whereas `reports/round-105/pc/` is the round's evidence/proposal/review archive. The proposed file is outside `upstream/` and `.manifest.d/`; do not touch those pinned regions. The new rule document should name the selected branch, define its authority and label semantics, address the six cards and `actors-scene.md`, preserve the binary policy, and link to the accepted proposal/reviews.
2. **Apply only the selected amendment set.** P requires reconciling the central definition, the six dissenting rationales, the `actors-scene.md` basis, and `SKILL.md`'s row B/C and §4. C requires making the README explicitly subordinate/descriptive, preserving card-level verdicts and requiring card citations for aggregate claims, and updating `SKILL.md`'s interim clause. Do not rewrite frozen r101/r102 evidence. Route writes to each path's owner; this ledger authorizes none of them.
3. **Three independent reviews, then a distilled amendment set.** Require three distinct non-author reviewers to assess the same proposal/diff hash and independently state `accept` or `revise`, their evidence, and any dissent. Fold accepted findings or record why the operator declines them. The final amendment list must map each changed path to the selected branch and identify the source/review evidence. Do not call a review independent if it reviewed a different proposal revision or is by the proposal author.
4. **Close the interim language only after the rule lands.** Replace `SKILL.md` §4's “still owed” and conditional wording with the selected rule and a pointer to the durable ruling. Update the README mapping and card rationale under the relevant owner. Keep this ledger and the three reviews as historical round evidence; they do not supersede the durable ruling.

### Acceptance commands — run after, not evidence of a future landing

The following are **pending**. They have not been run against an accepted ruling or post-ruling diff; the green baseline above is pre-decision.

```sh
# 1. Durable ruling exists and the README/skill point to the same selected rule.
test -s corpus/knowledge/unreal-mcp/label-precedence.md
# Expected: rc=0; inspect the file for explicit P or C, operator/date, scope and rationale.
grep -n 'label-precedence.md' corpus/knowledge/unreal-mcp/README.md SKILL.md
# Expected: both consumer documents point to the accepted rule; no “still owed” clause.

# 2. Three distinct independent review artifacts exist; manually verify IDs,
#    non-authorship, identical reviewed proposal/diff hash, and verdict/evidence.
find reports/round-105/pc -maxdepth 1 -type f -name 'review-*.md' -print | sort
# Expected: exactly three paths and three distinct reviewer identities.

# 3. Verify all 13 present card labels and the six dissent witnesses after the edits.
for label in verified-here static-only unproven-runtime; do
  printf '%s=' "$label"
  for f in corpus/knowledge/unreal-mcp/executability/*.md; do
    grep -m1 -oE 'verified-here|static-only|unproven-runtime' "$f"
  done | grep -c "^$label$"
done
# Expected for either branch unless the accepted amendment set explicitly justifies
# a changed card: verified-here=0, static-only=12, unproven-runtime=1.
grep -rln 'Not `unproven-runtime`' corpus/knowledge/unreal-mcp/executability/*.md | sort
# Expected: the six named cards, unless the chosen rule's reviewed amendment set
# explicitly changes their rationale; any changed census must be explained there.

# 4. Check whitespace and run the standing gate on roomy scratch.
set -e
git diff --check -- corpus/knowledge/unreal-mcp/README.md \
  corpus/knowledge/unreal-mcp/executability SKILL.md
# A new file is not covered by `git diff --check`; no-index exit 1 is expected
# for the addition, while whitespace errors produce a different nonzero code.
set +e
git diff --no-index --check /dev/null corpus/knowledge/unreal-mcp/label-precedence.md
rc=$?
set -e
if [ "$rc" -ne 1 ]; then exit "$rc"; fi
printf '%s\n' NEW_DOC_CHECK=PASS
GATE_WORKDIR=/dev/shm bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
# Expected: rc=0, CARDS=13 EXPECTED=13 BAD=0, NAME_SET=OK NAME_BAD=0,
# UNRESOLVED=0, GATE RESULT: PASS. Gate success is necessary, not semantic proof.

# 5. Confirm tracked and new-file paths against the operator-approved amendment set.
git status --short --untracked-files=all
# Expected: reviewed paths only; no upstream/, .manifest.d/, corpus/fixtures/,
# protected root files, or this seat's out-of-scope files.
```

The README hash, card census and current PASS above are point-in-time observations, not future acceptance. Re-run the commands after the operator's decision and on the final bytes. No Unreal Editor or runtime behavior was exercised or claimed.
