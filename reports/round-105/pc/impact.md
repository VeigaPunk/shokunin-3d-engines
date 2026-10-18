# r105 · SEAT-22 PC-IMPACT — counterfactual diffs

**Owned path:** `reports/round-105/pc/impact.md` only.
**Status:** impact analysis for operator review; neither branch is a ruling. No source, card, gate, pin, or other report was edited by this seat.

## Axes and baseline evidence

Axes: calibration (show each branch without choosing it), coverage (include both label and census consequences), scope safety (no proposed source change applied).

`bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; rc=$?; printf 'exit=%s\n' "$rc"; exit 0` was run on lane HEAD `1eaa5680c22a704ddf05f9b51ff3fcc731b9be8b`. Observed: manifest `12/12`; fresh clone at `a6aa73ada02a9fb1f5415bec491f9942c519b297`, `PATH_EXTRA=0 PATH_MISSING=0 BLOB_DIFFS=0`; `CARDS=13 EXPECTED=13 BAD=0`; `CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0`; `NAME_SET=OK`; `POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0`; all four checks PASS, `GATE RESULT: PASS`, `exit=0`.

`for f in animation-controlrig blueprints editor-general gameplay-gas materials meshes-textures; do printf '%s: ' "$f"; sed -n '4p' "corpus/knowledge/unreal-mcp/executability/$f.md"; done; printf 'cards='; find corpus/knowledge/unreal-mcp/executability -maxdepth 1 -name '*.md' -type f | wc -l` observed all six line-4 declarations as `**Label:** \`static-only\`` and `cards=13`.

The in-memory parser/counterfactual below was actually run using the same five declaration shapes and first-40-line scope recorded by CHECK 3. It did not write files and did not run the gate against a hypothetical tree. Output:

```text
current={'static-only': 12, 'unproven-runtime': 1} total=13
--- corpus/knowledge/unreal-mcp/executability/animation-controlrig.md:4
-**Label:** `static-only`
+**Label:** `unproven-runtime`
--- corpus/knowledge/unreal-mcp/executability/blueprints.md:4
-**Label:** `static-only`
+**Label:** `unproven-runtime`
--- corpus/knowledge/unreal-mcp/executability/editor-general.md:4
-**Label:** `static-only`
+**Label:** `unproven-runtime`
--- corpus/knowledge/unreal-mcp/executability/gameplay-gas.md:4
-**Label:** `static-only`
+**Label:** `unproven-runtime`
--- corpus/knowledge/unreal-mcp/executability/materials.md:4
-**Label:** `static-only`
+**Label:** `unproven-runtime`
--- corpus/knowledge/unreal-mcp/executability/meshes-textures.md:4
-**Label:** `static-only`
+**Label:** `unproven-runtime`
would_be={'static-only': 6, 'unproven-runtime': 7} total=13
```

This is arithmetic from the observed declarations, not a post-edit gate result. Gate constants were inspected with `Grep(pattern="EXPECTED_STATIC|EXPECTED_UNPROVEN|EXPECTED_VERIFIED|EXPECTED_CARDS", path="corpus/knowledge/unreal-mcp/gate/run_gate.sh")`; observed `EXPECTED_STATIC=12`, `EXPECTED_UNPROVEN=1`, `EXPECTED_VERIFIED=0`, `EXPECTED_CARDS=13`.

## Branch P — README's current runtime predicate binds

**Counterfactual:** the README's current definition applies to each subsystem runtime verdict: if a live editor is required and no runtime observation exists, the verdict is `unproven-runtime`, even when a concrete route is not identified. Six declaration lines change; no evidence becomes runtime evidence. The resulting declaration census is `6/7/0` (in-memory counterfactual above).

Exact declaration-line diff (equivalent to a line-4 `sed -i` substitution in each listed card; **not** executed):

```diff
corpus/knowledge/unreal-mcp/executability/animation-controlrig.md:4
-**Label:** `static-only`
+**Label:** `unproven-runtime`
corpus/knowledge/unreal-mcp/executability/blueprints.md:4
-**Label:** `static-only`
+**Label:** `unproven-runtime`
corpus/knowledge/unreal-mcp/executability/editor-general.md:4
-**Label:** `static-only`
+**Label:** `unproven-runtime`
corpus/knowledge/unreal-mcp/executability/gameplay-gas.md:4
-**Label:** `static-only`
+**Label:** `unproven-runtime`
corpus/knowledge/unreal-mcp/executability/materials.md:4
-**Label:** `static-only`
+**Label:** `unproven-runtime`
corpus/knowledge/unreal-mcp/executability/meshes-textures.md:4
-**Label:** `static-only`
+**Label:** `unproven-runtime`
```

Minimum mechanical gate impact (not applied):

```diff
-EXPECTED_STATIC=12
-EXPECTED_UNPROVEN=1
+EXPECTED_STATIC=6
+EXPECTED_UNPROVEN=7
 EXPECTED_VERIFIED=0
```

The script's expected-comment text also changes from `12 static-only / 1 unproven-runtime / 0 verified-here` to `6 / 7 / 0`. The gate README's current census references must move from `12/1/0` to `6/7/0`: its expected summary (`CENSUS ... EXPECTED=12/1/0`), human-readable output, and pinned label-census table all need the new values. Its C5 negative control cannot remain the current `blueprints.md` → `unproven-runtime` mutation: Blueprints would already have that label. To preserve a real one-label drift test, the copy-control would instead set `actors-scene.md:5` to `static-only`, yielding `7/6/0` against expected `6/7/0`. Neither gate README nor gate script was edited or tested on this hypothetical tree.

A declaration-only sed pass is not a complete semantic migration: the six cards' bodies currently explain why they are **not** `unproven-runtime`. Any approved P landing must reconcile that prose and all operative cross-card summaries as well as the counts. Historical receipts below should remain historical, not be rewritten to simulate a later state.

## Branch C — cards remain authoritative

**Counterfactual:** retain all 13 existing declarations and the `12/1/0` gate pin; make the README table distinguish the six-card “path unidentified” evidence class instead of allowing the central mapping to flatten it into the known-path case. The fourth class below is a **semantic sub-class of the literal `static-only` card token**, not a fourth token for CHECK 3. That distinction preserves the existing three-token scan and leaves the census unchanged.

Proposed exact README table diff only (new name/text are a concrete impact proposal, not approved vocabulary):

```diff
-| card label | what it means | policy state |
+| card label / evidence class | what it means | policy state |
 | `verified-here` | a bounded run of the subsystem actually happened on this host, with a saved receipt | `proven` |
 | `static-only` | the vendored document facts are proven by a static check run here; **no** runtime observation was made | `proven` for the document facts, `unproven` for the subsystem's behavior |
+| `static-only` / `path-unidentified` | the card establishes a documented surface but no concrete callable tool/path/signature; it does not say a known operation is merely awaiting a run | `proven` for checked document facts; `unproven` for runtime behavior and callability |
 | `unproven-runtime` | the claim needs the live editor and nothing was observed | `unproven` |
```

The extra row qualifies the existing `static-only` class; it is not a new declaration token. If an operator instead intends a fourth **literal card label**, that is a different migration: `run_gate.sh`'s allowed-token regex/census case and card labels would need a separate reviewed change. This seat did not infer or apply that broader change. The r105 `analyst-2.md` argument against inventing a fourth label is compatible with this semantic-subclass form, but not with a new token.

## Census-citing documents — observed inventory

Searches actually run with `Grep(pattern="12/1/0|12 / 1 / 0|static-only=12|12.*static-only.*unproven-runtime", glob="*.md", output_mode="files_with_matches", head_limit=0)` over `reports/round-101` through `reports/round-105`, `corpus/`, and the root `LOG.md`/`SCORECARD.md` produced the paths below. This is an inventory of documents that state the old label census; it is **not** a direction to edit all of them. The final scan also matched this impact report itself; excluding that self-hit, there are 91 canonical census-citing source documents at this snapshot. Three additional hits are copied under the r104 gate's scratch tree and are not canonical sources.

- Current corpus/root summaries (7): `LOG.md`; `SCORECARD.md`; `corpus/knowledge/engines.md`; `corpus/knowledge/unreal-mcp/gate/README.md`; `corpus/knowledge/unreal-mcp/executability/assets-content.md`; `corpus/knowledge/unreal-mcp/executability/gameplay-gas.md`; `corpus/lessons/r102-unreal-integration.md`.
- r101 historical receipts (4): `reports/round-101/r101-report.md`; `reports/round-101/r101-critic-c2.md`; `reports/round-101/r101-critic-c3.md`; `reports/round-101/r101-distiller.md`.
- r102 historical receipts (27): `reports/round-102/r102-report.md`; `reports/round-102/lesson-verify.md`; `reports/round-102/repairs/audit.md`; `reports/round-102/r102-verification-protocol.md`; `reports/round-102/r22-crosscheck.md`; `reports/round-102/battery-relation.md`; `reports/round-102/dissonance.md`; `reports/round-102/fold-spec.md`; `reports/round-102/engines-verify.md`; `reports/round-102/gate/adversary-a.md`; `reports/round-102/r102-adjudicator-draft.md`; `reports/round-102/lesson-critic.md`; `reports/round-102/skill-decision-table-draft.md`; `reports/round-102/r102-boundary-scout.md`; `reports/round-102/gate/sentinel.md`; `reports/round-102/r102-distiller.md`; `reports/round-102/r102-connector.md`; `reports/round-102/math-audit.md`; `reports/round-102/gate/review.md`; `reports/round-102/repairs/F8-readme-lines.md`; `reports/round-102/gate/author-run.md`; `reports/round-102/gate/mutation.md`; `reports/round-102/round-count.md`; `reports/round-102/repairs/F5-engines.md`; `reports/round-102/ledger-check.md`; `reports/round-102/reruns/labels.md`; `reports/round-102/gate/runtime-run.md`.
- r103 historical receipts (27): `reports/round-103/r103-report.md`; `reports/round-103/b2/corrections.md`; `reports/round-103/gate/regression.md`; `reports/round-103/gate/security.md`; `reports/round-103/note/gate-pin.md`; `reports/round-103/r103-verification-protocol.md`; `reports/round-103/gate/critic.md`; `reports/round-103/r103-dissonance.md`; `reports/round-103/gate/math.md`; `reports/round-103/close-count.md`; `reports/round-103/gate/hardening.md`; `reports/round-103/gate/sentinel.md`; `reports/round-103/r103-connector.md`; `reports/round-103/math-audit.md`; `reports/round-103/gate/docs-sync.md`; `reports/round-103/skill-table-review.md`; `reports/round-103/gate/a1-attack.md`; `reports/round-103/gate/a2-attack.md`; `reports/round-103/b2/verify-unity.md`; `reports/round-103/gate/a3-attack.md`; `reports/round-103/gate/mutations.md`; `reports/round-103/gate/clean.md`; `reports/round-103/gate/final-run.md`; `reports/round-103/note/author.md`; `reports/round-103/gate/a4-attack.md`; `reports/round-103/subtree-integrity.md`; `reports/round-103/freshness-pin.md`.
- r104 historical receipts (16): `reports/round-104/r104-report.md`; `reports/round-104/r104-adjudicator-draft.md`; `reports/round-104/r104-verification-protocol.md`; `reports/round-104/gate/diff-sentinel.md`; `reports/round-104/gate/docs-sync.md`; `reports/round-104/gate/pin-check.md`; `reports/round-104/skill/review.md`; `reports/round-104/gate/regression.md`; `reports/round-104/math-audit.md`; `reports/round-104/gate/final-run.md`; `reports/round-104/r104-dissonance.md`; `reports/round-104/skill/critic.md`; `reports/round-104/skill/author.md`; `reports/round-104/lessons-carry.md`; `reports/round-104/gate/workdir.md`; `reports/round-104/subtree-integrity.md`.
- r105 proposal and pre-ruling gate receipts (10): `reports/round-105/pc/ruling-draft.md`; `reports/round-105/pc/analyst-2.md`; `reports/round-105/r105-report.md`; `reports/round-105/pc/distiller.md`; `reports/round-105/pc/ledger.md`; `reports/round-105/pc/review-3.md`; `reports/round-105/math-audit.md`; `reports/round-105/gate/integrity.md`; `reports/round-105/gate/pin-after-edits.md`; `reports/round-105/gate/final-run.md`.
- Noncanonical scratch-copy hits (3, preserve as scratch evidence): `reports/round-104/gate/scratch/c85a816/corpus/knowledge/unreal-mcp/gate/README.md`; `reports/round-104/gate/scratch/c85a816/corpus/knowledge/unreal-mcp/executability/gameplay-gas.md`; `reports/round-104/gate/scratch/c85a816/corpus/knowledge/unreal-mcp/executability/assets-content.md`.

For P, mutable current-state summaries and the gate pin must be routed to their owners; `LOG.md`, `SCORECARD.md`, `SKILL.md`, the gate README, r101–r104 records, and other protected/owned paths are not edited by this seat. The lesson's r101 measurement and all round receipts should stay historical. For C, the census remains valid; only the README mapping/authority text needs an authorized change. In either case, post-ruling receipts must be newly measured, not retrofitted into prior-round records.

## Limits

- The baseline gate was run; the `6/7/0` outcome is a parser counterfactual only. No post-change gate run, label migration, README-table edit, or precedence ruling was performed.
- No Unreal Editor/runtime claim was made. No fixture, environment, upstream, manifest, or protected root file was touched.
- The fourth-class name is provisional because the operator has not selected C; the proposed semantic sub-class deliberately avoids creating a fourth gate token.
