# r105 P/C precedence package — distiller

**Seat:** SEAT-27 PC-DISTILLER · **Round:** r105 · **Axes:** depth / coverage / calibration
**Owned path written:** `reports/round-105/pc/distiller.md` only.
**Status:** proposed operator distillation, not approval or an adopted ruling. It synthesizes three independent r104 reviews, the r105 analysis/ruling/impact packet, and three r105 reviewer reports. No byte-pinned file was edited and no Unreal runtime claim was tested. All three reviewers examined different earlier packet snapshots; none reviewed this current distiller, and no same-hash review gate is satisfied.

## 0. Current packet and basis

The r105 PC packet contains two analyses, card evidence, history, ruling and impact drafts, this distillation, a ledger, and `review-1.md`, `review-2.md`, `review-3.md`. The three r104 reviews are historical input: they reviewed the r104 skill revision, not this r105 package. Review-1 returns **REVISE** on `distiller.md` hash `d337efd2dd32bd853e91497b5e08b51ffc48c7ff695a01af9ecec2914df55e24` and `ruling-draft.md` hash `0dc0340a35a028944765ad855aaf481dc6acb3286565afcd23ebb718d582dd30`. Review-2 returns **REVISE** and says its reviewed distiller hash was `7c51400847eb6a203df241f2e7869b325ecb51fcc0f0d6a93e928f44a7e12cf7`, with ruling hash `0dc034…` and `impact.md` hash `dd5c0e…`. Review-3 now returns **REVISE** on the distiller hash `498fd04eb28078a6246928ca761e0a5e156070a8101d292448d5398c4131c511`, with ruling `0dc034…` and impact `dd5c0e…`. It rejects the earlier P-narrow census claim as unsupported without a 13-card audit, citing likely qualifying Sequencer and Testing paths and requiring decisions on Blueprints and Assets. This current distiller revision is not yet reviewed by all reviewers on one identical frozen proposal/diff hash.

Current input identities measured for this synthesis:

| Input | SHA-256 |
|---|---|
| `SKILL.md` | `ae79cab11bbd3ee1e2f0590780d2431c54d8635b8c448a13580eb1c6afc98608` |
| `corpus/knowledge/unreal-mcp/README.md` | `c79d8dd1d7c0c7bc934700187ee322d6d1cb20fc03cc974fa62ee2d95b8ee721` |
| `reports/round-105/pc/ruling-draft.md` | `0dc0340a35a028944765ad855aaf481dc6acb3286565afcd23ebb718d582dd30` |
| `reports/round-105/pc/impact.md` | `dd5c0e9891fc51e10dad869b52bb1f7b45597fbe59d57a55eabd5f73b390501f` |
| `reports/round-105/pc/analyst-1.md` | `bb29882b33ed7a1deb42fbf229fa76479d8794ac865c60cec06cdacce3f89733` |
| `reports/round-105/pc/analyst-2.md` | `17c5d6550b09e5a16f4d502d986aef13f09ce114e90f5ccb668466ef8540c624` |
| `reports/round-105/pc/cards.md` | `268b7e1e13b0c9f2460151c5e96e11636d8e0d33cc4d6b24dd9fae9f0a3f119f` |
| `reports/round-105/pc/history.md` | `53728d6ee565343290db3b3d5e98b9514d947ec2c164dc0a66112b3bf1131ac8` |
| `reports/round-105/pc/ledger.md` | `84a47a1ff8879638140d89862824862c603d3399f0a597dc3f7fc40275c6e439` |
| `reports/round-105/pc/review-1.md` | `72435018cb908919dbbfbb910bc0107d25a346bed61a50fe73613ee46256316f` |
| `reports/round-105/pc/review-2.md` | `4f7cfa37c77b3bb49d758796eea118e2c4fa66ba199beac4533bf7d73ad98469` |
| `reports/round-105/pc/review-3.md` | `87575deedc62ec0733f48b315aa58d60b168a9e8432e003dc000cf3afd24d879` |

The r104 review set:

- SEAT-19, `reports/round-104/skill/review.md` — non-author re-run.
- SEAT-20, `reports/round-104/skill/critic.md` — adversarial claim-strength review.
- SEAT-21, `reports/round-104/skill/bleed.md` — frontmatter / scope audit.

**Consensus across the three r104 reviews:** F7 remains open; commands and green checks cannot settle normative precedence; §4 should say the ruling is owed rather than silently choose P or C. They did not vote for either branch. Their review text included:

- `review.md:228`: “The P/C ruling remains owed (§4) and the table says so rather than papering over it”; `review.md:561`: “The P/C precedence ruling is still owed”.
- `critic.md:254`: “The `⇔` must become a conditional”; `critic.md:261`: §4 is “right to refuse to resolve the P/C precedence ruling itself”.
- `bleed.md:219`: “The open precedence ruling (state it, do not resolve it)”.

**Consensus across the three r105 reviews:** all favor shared policy semantics with card-owned evidence/application and binary claim truth distinct from a whole-card ternary label; all require an operational path test, a 13-card evidence audit, no implementation before operator approval, and a frozen same-hash review target. All three reports return **REVISE**. Review-3 reviewed the immediately preceding distiller hash and found that the test may classify Sequencer and Testing as identified paths, while Blueprints and Assets need explicit audit decisions; it rejects any P-narrow census until the 13-row audit is complete. The reviewers differ on the interpretation of individual evidence and on how the P/C alternatives are named and scoped.

**Synthesis of the proposal conflicts:** Analyst-1 and `impact.md` use P for the literal broad runtime predicate and a six-label `6/7/0` counterfactual. Analyst-2 and the ledger describe C as card-first authority. The ruling draft and ledger describe P as shared policy plus an identified-path distinction, retaining the current `12/1/0` baseline. `impact.md`'s C adds a `path-unidentified` semantic sub-class that is not the ledger's C. P-narrow remains a candidate shared-policy variant, but its audit-derived census is open; it must be explicitly named, and the impact artifact must be aligned or superseded by its owner. The broad-P `6/7/0` calculation is not a full 13-card audit; `assets-content.md`, `ui-umg-slate.md`, and `sequencer.md` also need classification under any broad rule.

## 1. Consensus and scope of the inputs

1. **F7 is a semantic collision, not a failed measurement.** The r105 `history.md` traces it from r101; six cards dissent; all three r104 reviews leave precedence open. Current `SKILL.md` also marks the ruling owed. No check or census decides P versus C.
2. **Binary claim status and ternary card scope are distinct questions.** All three r105 reviewers and both analyses keep runtime behavior unproven without a bounded receipt. Static checks prove only the document property checked. A whole-card label must say whether it summarizes documentary evidence or runtime-capability scope; `editor-general.md` explicitly demonstrates this distinction for its live-call subclaim.
3. **Shared semantics are favored, but the operative rule is unresolved.** The r105 reviewers favor P-narrow/shared vocabulary, not analyst-1's broad predicate. The route test, exact C alternative, actor classification, and census must be made consistent across the ruling, impact, ledger, and distiller.
4. **Review status is not sign-off.** The three r104 reviews concern r104. Review-3 covers the immediately preceding distiller hash, not this revision; review-1 and review-2 cover older snapshots. None reviews one identical canonical proposal/diff hash with the other reviewers. The ledger requires three non-author reviews of one frozen hash before implementation.

## 2. Contested points and current-tree evidence

The r104 critic's objection to `unproven ⇔ unproven-runtime` and §4 prescribing one label for all six cards is version-scoped. Current `SKILL.md` hash is `ae79cab11bbd3ee1e2f0590780d2431c54d8635b8c448a13580eb1c6afc98608`; row C at line 46 already has a conditional, while §4 at lines 135–141 still records the ruling as owed and states the interim rule. This does not resolve the r105 disagreement. The ledger's historical P/C branches are not a substitute for reviewing one current proposal revision.

**Contested points the operator must resolve:**

1. **Semantic authority and branch naming.** Analyst-1 and `impact.md` call the literal broad runtime predicate P; the ruling draft and ledger call shared policy plus an identified-path distinction P; analyst-2 and the ledger define C as card-first authority. Reviewers 1–3 favor shared semantics but reject the packet's inconsistent labels. Recommendation: explicitly name P-narrow as the narrowed shared-policy proposal, distinct from analyst-1's broad P; define C exactly as the ledger does. Do not pass off `impact.md`'s alternatives as the same two branches.
2. **Label unit.** Analyst-1's runtime-claim reading would place `unproven-runtime` on an unobserved runtime claim even inside a mixed static-evidence card. `editor-general.md` separates its `static-only` whole-card label from a live-call subclaim, but currently calls that subclaim `unproven-runtime` (`:46–48`). Recommendation: binary `proven`/`unproven` is claim-level; ternary labels summarize the whole card's supported evidence scope. Under P-narrow, retain the header and evidence but clarify that subclaim as binary `unproven`; do not silently assign a second ternary unit.
3. **What makes a runtime path “identified.”** Count a route as identified only when cited card evidence (a) names the concrete subsystem operation, (b) explicitly maps it to a named subsystem-specific toolset or callable member, and (c) documents how that target is invoked. A named callable member/schema is not mandatory if the operation-to-toolset mapping and invocation route are explicit. A symbol mentioned only as an illustration or plausible example is not an operative mapping or callable contract by itself; the audit must distinguish that from a documented operation/toolset relationship and an invocation sequence/dispatch contract. Generic `call_tool`, endpoint, meta-tools, prerequisites, or a merely plausible/unmapped toolset do not pass. A non-author must be able to point to all three facts and establish that the cited symbol is operative rather than illustrative; otherwise the path is not identified.
4. **The actor card and resulting census.** Review-1 treats `actors-scene.md:12–16` as the positive identified-path contrast and supports retaining its current label if the test confirms it; reviewers 2–3 question its specificity. Detailed actor-card evidence says upstream never writes `ActorTools` or states which toolset owns actors (`actors-scene.md:97`); `LevelTools` appears once in a different skill as a possible toolset to extend, with zero members, while `ObjectTools` has only generic UObject property access (`:111–114`); the card says a reader cannot say the route “is `LevelTools`” (`:116–120`). On the cited actor evidence, the operation and generic `call_tool` route are present, but the subsystem mapping is not; the actor row therefore appears not to pass unless audit evidence establishes that mapping. Propose `static-only` for documentary scope and binary `unproven` for behavior on that card, subject to the audit. No P-narrow aggregate census can be asserted until all 13 rows—including Sequencer, Testing, Blueprints, and Assets—are adjudicated under the clarified operative-versus-illustrative boundary.
5. **Review identity and status.** Review-1 returns REVISE on distiller `d337efd2…df55e24`; review-2 returns REVISE on distiller `7c514008…a7cf7`; review-3 now returns REVISE on the immediately preceding distiller `498fd04e…c4131c511` (ruling `0dc034…`, impact `dd5c0e…`). This revision supersedes the hash reviewed by review-3, so none reviews the current file or one identical canonical proposal/diff hash. The three reports remain historical inputs until all reviewers cover a frozen target.
6. **Impact alternatives are not aligned.** `impact.md` labels the broad predicate P and its exact C proposal adds a `path-unidentified` semantic sub-class. The ledger's C is instead card-first, while its P and the ruling draft preserve 12/1/0. The paired matrix below compares P-narrow against the ledger's exact C; the impact author must align or explicitly supersede the divergent branch table before review. The broad-P `6/7/0` result is marker arithmetic, not a full 13-card semantic audit; review-2 flags `assets-content.md`, `ui-umg-slate.md`, and `sequencer.md` for separate classification. `impact.md` inventories 91 canonical census-citing documents (plus three scratch-copy hits), so a broad-P migration would require owner-routed updates beyond six cards and the gate.
7. **Preserve the six witness cards.** Review-1 says not to remove “Not `unproven-runtime`” language merely to change a marker count. Under P-narrow, preserve each card's evidence/rationale unless the audit finds a concrete contradiction; under C, preserve each card's own verdict/rationale. No marker-count change is an acceptance condition.

**Observed current card census and dissent membership:**

```sh
python3 - <<'PY'
from pathlib import Path
import re
root = Path('corpus/knowledge/unreal-mcp/executability')
files = sorted(root.glob('*.md'))
selected = []
counts = {}
for path in files:
    header = '\n'.join(path.read_text().splitlines()[:30])
    match = re.search(r'`(verified-here|static-only|unproven-runtime)`', header)
    label = match.group(1) if match else 'unlabeled'
    counts[label] = counts.get(label, 0) + 1
    if 'Not `unproven-runtime`' in path.read_text():
        selected.append(path.stem)
print(f'card_files={len(files)} label_census={counts}')
print('dissenter_cards=' + ','.join(selected))
PY
```

Observed: `card_files=13 label_census={'unproven-runtime': 1, 'static-only': 12}`; `dissenter_cards=animation-controlrig,blueprints,editor-general,gameplay-gas,materials,meshes-textures`. This is the baseline census, not proof that the current labels follow the proposed criterion. The six names are directly enumerated by the Python scan, not inferred from its count.

The current README hash is `c79d8dd1d7c0c7bc934700187ee322d6d1cb20fc03cc974fa62ee2d95b8ee721`. No byte-pinned source is changed by this distillation.

## 3. Final recommended proposal to the operator

**Recommend P-narrow:** shared policy semantics, card-owned evidence/application, claim-level binary status, and card-scope ternary labels, with the explicit three-part path-identification test above. This is not the README wording verbatim, not analyst-1's unqualified runtime-subclaim rule, and not an adopted ruling.

Recommended semantics:

- Binary `proven` / `unproven` applies to claims. Runtime behavior/callability stays `unproven` without a bounded run and saved receipt, whether or not a route is known. Static checks prove only the document property they actually checked.
- Ternary labels apply to the whole card's supported scope: `verified-here` requires a bounded runtime receipt; `static-only` means the card supports a static/documentary finding and does not identify an operative runtime path under the test above; `unproven-runtime` means the card identifies a concrete subsystem operation, maps it to a named subsystem-specific toolset/member, and documents an invocation route as an operative capability rather than an illustrative example, but has no observed result.
- A documentary card must not imply runtime behavior is proven. A runtime subclaim remains binary `unproven`; no unqualified `unproven ⇔ unproven-runtime` mapping.
- The measured current baseline is 13 cards (`12/1/0`), but it is not the result of applying P-narrow. The proposed P-narrow census is unresolved pending the 13-row audit. Review-3 identifies Sequencer and Testing as likely qualifying paths and requires explicit decisions on Blueprints and Assets; the operative-versus-illustrative boundary must be applied consistently to every card. No total is inferred from the actor row, six dissent markers, or gate constants.

Why this recommendation: it keeps one shared policy authority, preserves the claim/card distinction, and answers the r105 reviewers' request for a repeatable route test. It rejects analyst-1's broader rule because that collapses “known route, execution pending” and “unknown whether an executable path exists.” The README's definition and “only the card is authoritative” sentence both need owner-approved amendment; current wording does not already state this proposal.

The three r104 reviews agree the collision is live but did not review an r105 proposal. All three r105 reports return REVISE: review-1 and review-2 cover older snapshots; review-3 covers the immediately preceding distiller hash, not this revision. The ledger's three non-author reviews of one frozen canonical proposal/diff hash remain required.

## 4. Paired impact diff — proposals only, no source changes

- **Durable ruling** — Current: none accepted. **P-narrow:** after approval, add `corpus/knowledge/unreal-mcp/label-precedence.md` defining shared semantics, card scope, the path test, rejected C, and evidence/review hashes. **C:** use that same durable record to state that cards control their own verdicts and the central map is descriptive, not precedence. Owner: operator plus knowledge-subtree owner; create only after approval.
- **`reports/round-105/pc/impact.md`** — Current: calls the literal broad runtime predicate P (marker-only `6/7/0`) and gives C a `path-unidentified` semantic sub-class, unlike the ledger's card-first C. **P-narrow:** the impact author must label broad P as an unselected counterfactual or supersede it with this narrowed policy; **C:** replace its variant with the ledger's exact card-first rule. Owner: SEAT-22; no edit by this seat.
- **`corpus/knowledge/unreal-mcp/README.md`** — Current: overlapping label predicates; line 210 says only the card is authoritative. **P-narrow:** make the shared map binding and narrow card authority to evidence and application. **C:** explicitly make the map descriptive and each card authoritative for its verdict. Owner: subtree owner. Both require a change to the current authority sentence; neither is applied here.
- **Six dissenting cards** — Current: `static-only` with evidence/rationales that paths or signatures are unspecified. **P-narrow:** keep headers and evidence; preserve rationales except where they conflict with the shared test. One concrete scope conflict is `editor-general.md:46–48`: retain its whole-card `static-only` label but state its live-call subclaim as binary `unproven`, not a second ternary label. **C:** keep each card's own label and rationale unless independently factually wrong. Owner: card owner/subtree owner. No automatic flips or marker-count target.
- **`actors-scene.md`** — Current: `unproven-runtime`; its heading claims an identified dispatch path, while §2.4 says the toolset is not mapped and a reader cannot say it is `LevelTools` (`:97–120`). **P-narrow:** current evidence appears not to satisfy the mapping test, so propose `static-only` for documentary scope and binary `unproven` for behavior on this row, subject to the audit; no aggregate census follows from this row. **C:** retain its card-local `unproven-runtime` verdict absent an internal contradiction; current baseline `12/1/0`. Owner: card owner/subtree owner; no change by this seat.
- **`SKILL.md`** — Current: row C has an interim conditional; §4 says the precedence ruling is owed. **P-narrow:** adopt shared map/card scope and the identified-path test, then close §4 after approval. **C:** state explicitly that each card controls and the map does not settle conflicts, then align §4. Owner: SKILL owner; no change here.
- **`corpus/lessons/r102-unreal-integration.md`** — Current: historical F7 hook. **P-narrow or C:** append a dated decision/carry-forward note, preserving the r102 hook. Owner: lesson owner; no change here.
- **Gate/manifests** — Current baseline: 13 cards, `12/1/0`; gate checks census, not precedence. **P-narrow:** derive the proposed expectation only from a completed 13-row audit applying the operative-versus-illustrative test to all cards, including Sequencer, Testing, Blueprints, and Assets; do not predeclare an expected count. **C:** current baseline `12/1/0`, subject to the selected rule. Owner: gate/manifest owner; no edits by this seat. In either branch gate PASS is not semantic proof.

## 5. Final recommended amendment set — numbered and falsifiable

1. **Select one branch and freeze one operator proposal.** Recommend P-narrow as the explicitly narrowed shared-policy rule; state C exactly as “each card controls its own verdict; the central map is descriptive, not precedence.” Align `ruling-draft.md`, `impact.md`, this distillation, and any ledger-facing branch names/impact claims. Label `impact.md`'s literal P as analyst-1's broad counterfactual and its path-unidentified C variant as not the ledger's C. **Acceptance:** one selected rule, one impact derived from the completed 13-row audit, both branch impacts for comparison, and one canonical proposal/diff hash repeated in every review; do not predeclare the P-narrow census.
2. **Record the accepted rule durably.** Only after operator approval, create `corpus/knowledge/unreal-mcp/label-precedence.md` outside `upstream/` and `.manifest.d/`, recording operator/date, selected branch, label unit, binary/ternary relation, path test, rejected branch, and evidence/review hashes. **Acceptance:** it says ternary labels describe whole-card scope and binary status describes individual claims; it asserts no runtime success without a receipt.
3. **Make path identification reproducible.** A card must cite (a) a concrete subsystem operation, (b) an explicit mapping from it to a named subsystem-specific toolset or callable member, and (c) the invocation route. A member/schema is optional only if the operation-to-toolset mapping and invocation route are explicit; generic MCP transport, `call_tool`, endpoint, meta-tools, prerequisites, and an unmapped plausible toolset alone fail. A symbol appearing only as an illustration is not an operative mapping or callable contract by itself. **Acceptance:** every row cites all three elements, explains whether the cited symbol is presented as an operative callable contract or only an example, or says “path not identified”; two non-authors applying the rule to the same evidence classify it identically.
4. **Amend the README under the selected branch.** For P-narrow, make the shared map binding and card authority evidence/application only; for C, make the map explicitly descriptive and cards authoritative for their own verdicts. **Acceptance:** static fact, unknown path/no observation, mapped path/no observation, and bounded receipt each have one ternary card label and one explicit binary claim status, with no authority contradiction.
5. **Preserve the six witness cards unless an audit finds a real conflict.** Review `animation-controlrig`, `blueprints`, `editor-general`, `gameplay-gas`, `materials`, and `meshes-textures` against the shared P test or selected C branch. Keep their headers and static evidence; do not delete “Not `unproven-runtime`” statements merely to change a marker count. Under P-narrow, clarify `editor-general.md:46–48`: its whole-card label remains `static-only`, while its live-call subclaim remains binary `unproven`, not a second ternary label. **Acceptance:** each label/rationale is traceable to the chosen rule; any other changed sentence cites a specific contradiction or factual correction; no runtime behavior is promoted without a receipt.
6. **Complete the 13-card audit and derive the census.** Audit all rows with filename, current/proposed label, evidence scope, concrete operation, mapped toolset/member, invocation route, whether names are operative or illustrative, binary status, and direct citations. Explicitly adjudicate the likely path evidence in `sequencer.md:30–35,170–185` and `testing-automation.md:64–77`, and the illustrative-versus-contract cases in `blueprints.md:51,61–65` and `assets-content.md:165–178`. **Acceptance:** a non-author reproduces every row and the aggregate is calculated from the selected rule; actor's row appears not to satisfy mapping on current evidence (`actors-scene.md:97–120`), but no total is asserted before the remaining rows are audited. Under C, retain the current `12/1/0` as baseline unless a card-local contradiction is shown. Any other census must be derived by the selected rule, not gate constants.
7. **Propagate only the accepted branch.** After approval, update `SKILL.md` row B/C and §4 to cite the durable ruling; append a dated r105 note to `corpus/lessons/r102-unreal-integration.md` without rewriting the historical hook. **Acceptance:** final guidance matches the selected branch, contains no unqualified `unproven ⇔ unproven-runtime`, and points to the same accepted-rule section/hash.
8. **Obtain three independent reviews of the same frozen proposal/diff.** Each reviewer must be a non-author and record identity, identical hash, `accept` or `revise`, evidence, and dissent. **Acceptance:** three distinct reviewer identities report the same hash; fold findings or record the operator's explicit disposition. The three r104 reports and the current r105 reports, including review-3's REVISE on the immediately preceding distiller hash, are not sign-off for this revision.
9. **Run post-edit acceptance on the authorized final tree.** Run `GATE_WORKDIR=<roomy-writable-directory> bash corpus/knowledge/unreal-mcp/gate/run_gate.sh`, check the audit-derived census and `UNRESOLVED=0`, and run `git diff --check` on the approved path list. **Acceptance:** gate PASS, whitespace clean, and the separate 13-row semantic audit passes; gate success alone does not prove precedence.

## 6. Limits / blockers

- Proposal only: the operator has not accepted P-narrow or C, and this seat has not applied either branch to README, cards, `SKILL.md`, lesson, gate, or manifests.
- The three r104 reviews concern the r104 skill revision. All three r105 reviewer reports return REVISE on prior snapshots; review-3's REVISE matches the immediately preceding distiller hash, but not this edited revision. No three reports review one identical frozen canonical proposal/diff, so the ledger's review gate remains unmet.
- Aligning `ruling-draft.md`, `impact.md`, and this distillation, and completing the reproducible 13-card route audit remain open. The P-narrow aggregate is unresolved: review-3 identifies Sequencer and Testing as likely qualifying paths and requires explicit decisions on Blueprints and Assets, with illustrative names distinguished from operative callable contracts. `12/1/0` is the measured current baseline only; no P-narrow result or expected gate count is proposed until the full audit is reproducible.
- This seat does not adjudicate on behalf of the operator and claims no Unreal Editor/runtime evidence.
