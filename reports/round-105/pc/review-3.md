# SEAT-26 PC-REVIEWER-3 — independent review of the P/C package

**Round:** r105 · **Axis:** calibration (primary), coverage and depth (supporting)
**Owned path written:** `reports/round-105/pc/review-3.md` only.
**Reviewed snapshot:** `distiller.md` SHA-256 `498fd04eb28078a6246928ca761e0a5e156070a8101d292448d5398c4131c511`; `ruling-draft.md` `0dc0340a35a028944765ad855aaf481dc6acb3286565afcd23ebb718d582dd30`; `impact.md` `dd5c0e9891fc51e10dad869b52bb1f7b45597fbe59d57a55eabd5f73b390501f`; README `c79d8dd1d7c0c7bc934700187ee322d6d1cb20fc03cc974fa62ee2d95b8ee721`.
**Decision status:** review recommendation only; no operator ruling made or applied.

## Verdict

**REVISE — P-narrow is a defensible candidate, but this proposal snapshot does not support its proposed 13/0/0 census or implementation.** The latest distiller improves the proposal materially: it separates claim-level binary status from whole-card ternary scope and supplies a falsifiable three-part path test. Applying that test to the existing card text surfaces likely qualifying paths beyond `actors-scene` (at least Sequencer and Testing), while the ruling and impact artifacts still give incompatible outcomes. The test must be applied consistently to all 13 cards and the canonical proposal/impact must be aligned before another frozen-hash review round.

I support shared label semantics with card-owned evidence/application as a candidate for the operator. This is not approval of P-narrow, not a census ruling, and not authorization to change README/cards, `SKILL.md`, lessons, gate, or manifests. No Unreal runtime behavior was tested.

## Independent evidence re-derived

All commands below were run from the lane root during this review.

**1. The README definitions overlap as written.**

```sh
nl -ba corpus/knowledge/unreal-mcp/README.md | sed -n '31,48p'
```

Observed: line 40 defines `static-only` as static document facts proven with **no runtime observation**, with subsystem behavior `unproven`; line 41 defines `unproven-runtime` as a claim needing the live editor with **nothing observed**. Both predicates apply to the six cards' unobserved behavior. The README hash independently re-derived as:

```sh
sha256sum corpus/knowledge/unreal-mcp/README.md
```

```text
c79d8dd1d7c0c7bc934700187ee322d6d1cb20fc03cc974fa62ee2d95b8ee721  corpus/knowledge/unreal-mcp/README.md
```

**2. The six-card disagreement is still present, with the exact membership.**

```sh
grep -rln 'Not `unproven-runtime`' corpus/knowledge/unreal-mcp/executability/*.md | sort
grep -rln 'Not `unproven-runtime`' corpus/knowledge/unreal-mcp/executability/*.md | wc -l
```

Observed: `animation-controlrig.md`, `blueprints.md`, `editor-general.md`, `gameplay-gas.md`, `materials.md`, and `meshes-textures.md`; count **6**. My own quote check:

```sh
nl -ba corpus/knowledge/unreal-mcp/executability/blueprints.md | sed -n '110,115p'
```

At line 113, Blueprints says the path is “not even identified” because signatures are unknown pending `describe_toolset`, and chooses `static-only`. The README’s card-authority assertion is separately explicit:

```sh
nl -ba corpus/knowledge/unreal-mcp/README.md | sed -n '204,212p'
```

Lines 209–210 say the binding verdict and evidence live in each card and “only the card is authoritative.” Both current proposal texts now explicitly propose narrowing that sentence (`ruling-draft.md:20, 129`; `distiller.md:110`); this is a genuine authority conflict, and the owner-authorized diff must change and recheck it only after approval.

**3. The baseline census is 13 cards, 12 static-only / 1 unproven-runtime / 0 verified-here.** I parsed the declared header forms for all card files, including the nonstandard Assets, UI, Scripting, and VFX forms (rather than relying on a first-token scan):

```text
actors-scene.md: unproven-runtime
animation-controlrig.md: static-only
assets-content.md: static-only
blueprints.md: static-only
editor-general.md: static-only
gameplay-gas.md: static-only
materials.md: static-only
meshes-textures.md: static-only
scripting-programmatic.md: static-only
sequencer.md: static-only
testing-automation.md: static-only
ui-umg-slate.md: static-only
vfx-niagara-dataflow.md: static-only
TOTAL_PARSED= 13 COUNTS= {'unproven-runtime': 1, 'static-only': 12}
```

The reviewed sources (`README.md` and all card files) were clean against HEAD when checked:

```sh
git diff --quiet HEAD -- corpus/knowledge/unreal-mcp/README.md corpus/knowledge/unreal-mcp/executability && printf 'reviewed README/cards are clean against HEAD\n'
```

Observed: `reviewed README/cards are clean against HEAD`.

## Findings blocking acceptance

### F1 — The proposed 13/0/0 census is not derived by the new test

The latest distiller states a useful operational rule: cite (a) a concrete subsystem operation, (b) an explicit mapping to a named subsystem-specific toolset/member, and (c) how the target is invoked; generic `call_tool` plumbing or an unmapped plausible toolset alone does not pass (`distiller.md:59, 98, 121, 124`). This materially improves the earlier draft. But it has not been applied to all 13 cards, and existing card text appears to pass it in at least two cases:

- `sequencer.md:30–35, 170–185` names the concrete operation `create_level_sequence`, maps it to `SequencerTools`, and says those toolset-qualified tools are dispatched through `call_tool`.
- `testing-automation.md:64–77` explicitly says to load `AutomationTestToolset`, call `DiscoverTests`, then `ListTests`/`RunTests` and poll results. That is a named operation-to-toolset mapping with an invocation sequence.

Other likely audit rows need explicit disposition: `blueprints.md:51, 61–65` names `BlueprintTools.create` and the `call_tool` route; `assets-content.md:165–178` describes `AssetTools` save APIs and the generic discovery/dispatch route. If these are excluded because the named symbols are only examples, not capability contracts, the test must state that boundary and cite why Testing's explicit sequence is different. Under the current rule, a name/schema is not mandatory when mapping and invocation are explicit. I do not infer a replacement census from this spot-check; it is enough to show that `13/0/0` cannot be accepted without the promised row-by-row audit.

The actor-specific result also remains unsettled: `actors-scene.md:97–120` says no `ActorTools` mapping is stated and `LevelTools`/`ObjectTools` are only candidate inferences, so the proposed test supports changing that card to `static-only`; the distiller's `13/0/0` conclusion is still a candidate, not a completed audit (`distiller.md:60, 100, 112, 124`).

**Required fold:** publish the 13-row audit with the concrete operation, cited mapping, cited invocation route, binary claim status, proposed card label, and reason any apparently qualifying example is rejected. Derive the census from those rows, not from the existing gate constants or the six dissent markers.

### F2 — The branch/impact files still disagree with P-narrow

`ruling-draft.md:129, 138` preserves `12/1/0` and retains `actors-scene.md` as `unproven-runtime`; `impact.md:41–43, 82–97` analyzes a literal-README P branch as `6/7/0` and C as `12/1/0`; the latest `distiller.md:93–100, 108–115` recommends P-narrow with candidate `13/0/0`. The distiller has a paired P-narrow/C matrix, but the separate ruling and impact artifacts have not been reconciled to it. This is not one operator-ready branch/impact package.

**Required fold:** name P-narrow consistently, define C as the exact alternative in `ledger.md:29–33`, and make the canonical ruling, impact report, and distillation agree on label unit, path test, and audit-derived census. Keep both branch impacts distinct from analyst-1's literal-P `6/7/0` counterfactual.

### F3 — Reviews do not cover one frozen proposal hash

I measured these current artifact hashes for this review: `distiller.md` `498fd04eb28078a6246928ca761e0a5e156070a8101d292448d5398c4131c511`; `ruling-draft.md` `0dc0340a35a028944765ad855aaf481dc6acb3286565afcd23ebb718d582dd30`; `impact.md` `dd5c0e9891fc51e10dad869b52bb1f7b45597fbe59d57a55eabd5f73b390501f`. They remain separate artifacts, not one frozen proposal/diff identity.

The three existing review reports target different distiller revisions:

- `review-1.md` (`72435018cb908919dbbfbb910bc0107d25a346bed61a50fe73613ee46256316f`) returns REVISE on `d337efd2dd32bd853e91497b5e08b51ffc48c7ff695a01af9ecec2914df55e24`.
- `review-2.md` (`4f7cfa37c77b3bb49d758796eea118e2c4fa66ba199beac4533bf7d73ad98469`) returns REVISE on `7c51400847eb6a203df241f2e7869b325ecb51fcc0f0d6a93e928f44a7e12cf7`.
- The prior `review-3.md` (`44e48b1cf751aee9b7d4a0afb1a5567ec2cc0d8525814a5bfeeca68e5767e321`) was CONDITIONAL ACCEPT for discussion on `890df3662f357a0a68d4e586b4690f3a375bafd465a1c196bac1191993d3b4e7` and ruling `c0d14e2e35b560ede713b426b5b98ce61beef21272b0d8725738a80df353ddb0`.

This updated report reviews the current distiller hash above plus the current ruling and impact hashes in its header. No prior report reviews that same target. The current distiller inventory lists review-2 and its report hash (`distiller.md:9, 25`), but records it against an earlier distiller target (`distiller.md:9`); its review-3 entry is the pre-refresh report hash (`distiller.md:26`). The ledger's three-same-hash review requirement remains unmet (`ledger.md:39`).

**Required fold:** align and freeze one canonical proposal/diff, update its inventory, and obtain three distinct non-author reviews that all cite that exact hash and record a verdict. This report is not implementation approval.

### F4 — Preserve the no-application boundary

The proposal correctly says it is for operator/subtree-owner approval and makes no source edits (`ruling-draft.md:3-6, 136-140`). I made no edits to the README, cards, `SKILL.md`, lessons, gate, upstream, or manifests; no Unreal Editor/runtime behavior was tested. The decision remains proposed. Do not treat a clean census or gate PASS as semantic acceptance; the ledger already recognizes that the gate sees tokens and pointers, not the precedence rule (`ledger.md:21, 31-33`).

## Recommendation to the operator

**REVISE P-narrow, not reject the shared-policy direction.** Keep binary `proven`/`unproven` at claim level and ternary labels at whole-card scope as the candidate semantics. Before acceptance, require the 13-row route audit to account for at least the Sequencer and Testing evidence (and decide Blueprints/Assets), align the ruling and impact files with the resulting census, correct the packet inventory, freeze one canonical proposal/diff hash, and obtain three non-author reviews against that exact hash. Keep `SKILL.md` §4 open and apply no changes to byte-pinned files until the operator rules.

## Reviewed artifact identities

```sh
sha256sum reports/round-105/pc/{distiller,ruling-draft,impact,review-1,review-2,review-3}.md corpus/knowledge/unreal-mcp/README.md
```

Observed at the reviewed snapshot:

- `distiller.md` `498fd04eb28078a6246928ca761e0a5e156070a8101d292448d5398c4131c511`
- `ruling-draft.md` `0dc0340a35a028944765ad855aaf481dc6acb3286565afcd23ebb718d582dd30`
- `impact.md` `dd5c0e9891fc51e10dad869b52bb1f7b45597fbe59d57a55eabd5f73b390501f`
- `review-1.md` `72435018cb908919dbbfbb910bc0107d25a346bed61a50fe73613ee46256316f`
- `review-2.md` `4f7cfa37c77b3bb49d758796eea118e2c4fa66ba199beac4533bf7d73ad98469`
- `review-3.md` before this update `44e48b1cf751aee9b7d4a0afb1a5567ec2cc0d8525814a5bfeeca68e5767e321`
- `corpus/knowledge/unreal-mcp/README.md` `c79d8dd1d7c0c7bc934700187ee322d6d1cb20fc03cc974fa62ee2d95b8ee721`

No Unreal Editor/runtime command or gate was run for this refreshed review. Card evidence was inspected at `actors-scene.md:97–120`, `sequencer.md:30–35, 170–185`, `testing-automation.md:64–77`, `blueprints.md:51, 61–65`, and `assets-content.md:165–178` under `corpus/knowledge/unreal-mcp/executability/`.
