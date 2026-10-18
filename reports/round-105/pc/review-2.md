# SEAT-25 PC-REVIEWER-2 — independent P/C review

**Verdict: REVISE.** I prefer a shared semantic policy with card-owned evidence/application (the P direction), and I support keeping binary claim truth separate from a ternary whole-card label. P-narrow is a plausible candidate, not an accepted ruling. Do not implement this packet yet: the option names and impact analysis do not describe one coherent pair of alternatives, the current ruling draft has not adopted the distiller's explicit path test, and the census implied by that test has not been derived by a 13-card evidence audit.

## Answers to the decision questions

- **What controls label meaning?** Prefer one shared mapping; cards should supply evidence and apply it, not independently redefine identical tokens. This addresses the cross-card comparability problem without pretending a static document check proves runtime behavior.
- **What is the label unit?** Keep `proven` / `unproven` at claim level; use the ternary token for the whole card's supported evidence scope. A documentary finding must not imply successful runtime behavior.
- **When is a runtime path identified?** The latest distiller's three-part predicate is a useful candidate: cite a concrete subsystem operation, explicitly map it to a named subsystem-specific toolset/member, and document invocation. Generic MCP plumbing or a merely plausible toolset is insufficient. Require a card-by-card audit before using it to set labels.
- **Which proposal should be adopted?** None in its present form. Reconcile the alternatives, update one canonical operator-facing proposal and impact diff, freeze its hash, then obtain the required same-hash independent reviews.

## Blocking findings

1. **P/C names and consequences are inconsistent across the packet.** `ledger.md:29-31` defines P as shared policy plus an identified-path distinction (six cards stay `static-only`, `actors-scene` stays `unproven-runtime`); C is card-first authority. `ruling-draft.md:10-18,24-26` also recommends shared P and retains the six labels. But `impact.md:41-43` calls the README's literal, broad runtime predicate “P” and predicts flipping the six labels to `6/7/0`; its C branch adds a `static-only/path-unidentified` semantic sub-class and a README amendment absent from the ledger's C definition (`impact.md:82-97`). The latest `distiller.md:88-95` calls its distinct shared-policy/three-part-test hybrid “P-narrow” and proposes `13/0/0` on currently cited evidence. The actual extraction command and output below confirm all four descriptions. These are materially different options, not interchangeable names. State whether P-narrow is a third option or the corrected P, and rewrite the option-by-option impact accordingly.

2. **The operation threshold and `actors-scene` basis do not yet support a final census.** The ruling draft calls the actor path identified because it names live operations (`ruling-draft.md:26`), but the card says the landing site is only plausible and records no `ActorTools`; it says `LevelTools` is named in another skill (`actors-scene.md:302-316`). Under the distiller's own three-part test (`distiller.md:56,116`), generic transport, `call_tool`, endpoint, prerequisites, and an unmapped plausible toolset fail unless the card also cites the operation-to-toolset mapping and invocation route. The actor card therefore does not justify retaining the lone `unproven-runtime` label on the evidence presented; `13/0/0` is a candidate, not an audited result. The package needs one non-author 13-row audit showing operation, mapping, invocation, binary claim state, proposed label, and citations for every card.

3. **The literal-P impact's six-label counterfactual is not a complete semantic audit.** A current-card parser confirms a baseline of 13 cards (`12 static-only / 1 unproven-runtime / 0 verified-here`) and six explicit F7 dissent markers. Separate static-only cards also describe why they do not meet their own runtime-label tests: `assets-content.md:21`, `ui-umg-slate.md:21-25`, and `sequencer.md:42` (the card says the route is blocked before the client, so `unproven-runtime` would overstate readiness). That does not prove these cards must change; it does mean `impact.md` must explain why a literal README rule affects exactly the six markers and not these other static-only cards. A count of dissent markers is not a rule-based classification of all 13 cards.

4. **Review target is not frozen.** The ledger requires three non-author reviews of the same proposal/diff hash (`ledger.md:39`). The current ruling, impact, and distiller are separate artifacts; the distiller itself says to align and freeze them (`distiller.md:114`). During my review, `sha256sum reports/round-105/pc/distiller.md` returned `0bcf9ec1e25c66b9a5e43951ef00df66bd7f56ce7c784917c991a2af4a6a1779`, then later returned `7c51400847eb6a203df241f2e7869b325ecb51fcc0f0d6a93e928f44a7e12cf7`; this review covers the latter text/hash. Freeze before soliciting further reviews. I did not read `review-1.md` or `review-3.md`; the inventory command below listed both, but I make no claim about their contents or reviewed hashes.

## Command evidence from this review

**Input identity.** Command run: `sha256sum reports/round-105/pc/analyst-1.md reports/round-105/pc/analyst-2.md reports/round-105/pc/cards.md reports/round-105/pc/ledger.md reports/round-105/pc/ruling-draft.md reports/round-105/pc/impact.md reports/round-105/pc/distiller.md reports/round-105/pc/history.md corpus/knowledge/unreal-mcp/README.md SKILL.md`.

Observed SHA-256s:

| Input | SHA-256 |
|---|---|
| `analyst-1.md` | `bb29882b33ed7a1deb42fbf229fa76479d8794ac865c60cec06cdacce3f89733` |
| `analyst-2.md` | `17c5d6550b09e5a16f4d502d986aef13f09ce114e90f5ccb668466ef8540c624` |
| `cards.md` | `268b7e1e13b0c9f2460151c5e96e11636d8e0d33cc4d6b24dd9fae9f0a3f119f` |
| `ledger.md` | `84a47a1ff8879638140d89862824862c603d3399f0a597dc3f7fc40275c6e439` |
| `ruling-draft.md` | `0dc0340a35a028944765ad855aaf481dc6acb3286565afcd23ebb718d582dd30` |
| `impact.md` | `dd5c0e9891fc51e10dad869b52bb1f7b45597fbe59d57a55eabd5f73b390501f` |
| `distiller.md` (latest inspected version) | `7c51400847eb6a203df241f2e7869b325ecb51fcc0f0d6a93e928f44a7e12cf7` |
| `history.md` | `53728d6ee565343290db3b3d5e98b9514d947ec2c164dc0a66112b3bf1131ac8` |
| `README.md` | `c79d8dd1d7c0c7bc934700187ee322d6d1cb20fc03cc974fa62ee2d95b8ee721` |
| `SKILL.md` | `ae79cab11bbd3ee1e2f0590780d2431c54d8635b8c448a13580eb1c6afc98608` |

**Branch text.** Command run: a Python line extractor over `ruling-draft.md:10-26`, `impact.md:41-97`, `ledger.md:25-33`, and `distiller.md:52-58,86-99,103-128`. Observed: ruling P retains the six labels; impact P flips them to `6/7/0`; ledger P retains them and defines C as card-first; impact C defines an additional semantic sub-class; distiller recommends P-narrow and `13/0/0` pending audit, and calls for one frozen proposal.

**Card labels and dissent markers.** Command run: a Python scan of `corpus/knowledge/unreal-mcp/executability/*.md`, using the five declaration shapes from the package's census parser and searching complete card text for `Not \`unproven-runtime\``. Observed: `COUNTS static-only=12 unproven-runtime=1 verified-here=0 total=13`; dissenters are `animation-controlrig`, `blueprints`, `editor-general`, `gameplay-gas`, `materials`, `meshes-textures`. A separate Python line extraction of actor, assets, UI, and Sequencer cards returned actor lines 302-316 (plausible site; no `ActorTools`; `LevelTools` only in another skill), assets line 21, UI lines 21-25, and Sequencer line 42 (blocked before client). These observations support the audit questions above; they do not settle the normative rule.

**Runtime availability.** Command run: `which UnrealEditor UnrealEditor-Cmd` with return-code capture. Observed: both executables reported “no … in PATH”; `which_rc=2`. No Unreal runtime test was run, and no runtime claim is made.

**Review-file inventory.** Command run: `ls reports/round-105/pc`. Observed entries included `review-1.md` and `review-3.md`, with no `review-2.md` at that time. I did not read either other review. No gate was run as part of this review.
