# r105 · SEAT-23 PC-RULING-DRAFT

**Status:** PROPOSED for the operator / Unreal-MCP subtree owner; not a lane ruling and not applied.
**Owned path:** `reports/round-105/pc/ruling-draft.md` only.
**Axes:** calibration (primary), coverage (shared label census), depth (migration and acceptance path).
**Decision requested:** adopt Option P below as the shared meaning of the labels; preserve the six cards' current labels and their documentary evidence. The lane must not edit the subtree's byte-pinned files on the strength of this proposal.

## Proposed ruling

**Recommend policy-first (Option P), with the README mapping as the shared semantic authority and the individual cards as the authority for their evidence and current subject-level verdict.** The README's current `unproven-runtime` definition is too broad to distinguish a documented runtime operation from a documentation-only account that explicitly says no operation/path is specified. Resolve that ambiguity centrally rather than allowing each card to define the same label differently.

Proposed shared rule, for the operator to accept or amend:

1. The binary policy remains about claims: behavior requiring Unreal runtime evidence is `unproven` until supported by a bounded run and saved receipt. Static checks prove only the static/document property they actually ran.
2. `verified-here` is reserved for a bounded run of the subsystem on this host with a saved receipt.
3. `static-only` describes a card whose supported statement is limited to facts about the shipped/documented surface that were checked statically. It does **not** promote a capability or its behavior; those remain `unproven` binary claims.
4. `unproven-runtime` describes an explicit, concrete runtime capability/operation that the card identifies but which has no observed runtime result. A card that establishes only that the vendored documentation omits a concrete operation/path remains `static-only` for that documentary finding; it may not imply that the unnamed operation works.
5. A card supplies the evidence and applies this shared rule to its subject. Its prose cannot redefine the vocabulary. The six F7 cards therefore keep `static-only` for their documentation-scope finding, while any claim about their subsystem behavior remains `unproven`.

This is a proposed clarification and reconciliation, not an assertion that the current README already says all five points. In particular, the index sentence that says “only the card is authoritative” must be narrowed to evidence/verdict application, not independent label semantics.

### Why this side

The two readings both preserve the current six `static-only` labels, but they differ on what a future author treats as binding. Option C (card-first) makes each card locally authoritative even where cards attach incompatible meanings to one token; that does not repair comparability. Option P gives the lane one shared decision rule, while preserving card-specific observations and allowing a narrow definition repair. The proposal does not say that the six cards are wrong, or relabel them to make a headline census appear consistent.

The operational distinction is the **scope of the card's supported statement**, not an inference that unobserved runtime behavior is proven: the six cards say the available corpus does not identify an executable path; `actors-scene.md` names live editor operations and says their execution is the missing evidence. A claim that any such operation actually succeeds remains `unproven` in either case.

## Evidence and the independent review set

### This seat's re-derivation

Commands were run from the lane root at HEAD `1eaa568`.

```text
$ grep -rln 'Not `unproven-runtime`' corpus/knowledge/unreal-mcp/executability/*.md | sort
corpus/knowledge/unreal-mcp/executability/animation-controlrig.md
corpus/knowledge/unreal-mcp/executability/blueprints.md
corpus/knowledge/unreal-mcp/executability/editor-general.md
corpus/knowledge/unreal-mcp/executability/gameplay-gas.md
corpus/knowledge/unreal-mcp/executability/materials.md
corpus/knowledge/unreal-mcp/executability/meshes-textures.md
$ grep -rln 'Not `unproven-runtime`' corpus/knowledge/unreal-mcp/executability/*.md | wc -l
6
$ sha256sum corpus/knowledge/unreal-mcp/README.md
c79d8dd1d7c0c7bc934700187ee322d6d1cb20fc03cc974fa62ee2d95b8ee721  corpus/knowledge/unreal-mcp/README.md
```

The first quick extractor used for reconnaissance missed nonstandard card heading formats; the corrected parser below scans full card text with patterns for the label-declaration styles present across the 13 cards. Only the corrected result is evidence for the census:

```sh
python3 - <<'PY'
from pathlib import Path
import re
root = Path('corpus/knowledge/unreal-mcp/executability')
patterns = [
    re.compile(r'^\s*\*\*(?:Label|Verdict)(?: label)?:\*\*\s*`?(verified-here|static-only|unproven-runtime)'),
    re.compile(r'^\s*\*\*(?:Label|Verdict)(?: label)?:\s*`?(verified-here|static-only|unproven-runtime)`?\*\*'),
    re.compile(r'^\s*(?:Label|Verdict)(?: label)?:\s*\*\*\s*`?(verified-here|static-only|unproven-runtime)'),
    re.compile(r'^\s*\*\*`(verified-here|static-only|unproven-runtime)`\*\*'),
    re.compile(r'^\s*#+\s*(?:Label|Verdict)(?: label)?:\s*`?(verified-here|static-only|unproven-runtime)'),
]
counts = {'static-only': 0, 'unproven-runtime': 0, 'verified-here': 0}
for p in sorted(root.glob('*.md')):
    found = None
    for n, line in enumerate(p.read_text().splitlines(), 1):
        for pat in patterns:
            m = pat.search(line)
            if m:
                found = (m.group(1), n)
                break
        if found: break
    label, ln = found if found else ('MISSING', '-')
    print(f'{label:16} {p.name} line={ln}')
    if label in counts: counts[label] += 1
print(f"COUNTS static-only={counts['static-only']} unproven-runtime={counts['unproven-runtime']} verified-here={counts['verified-here']} total={sum(counts.values())}")
PY
```

Observed output: all six names above are `static-only`; all 13 cards have one recognized label; `COUNTS static-only=12 unproven-runtime=1 verified-here=0 total=13`.

```text
$ nl -ba corpus/knowledge/unreal-mcp/README.md | awk 'NR>=31&&NR<=48 || NR>=204&&NR<=211'
31  ### How the binary policy maps onto the ternary card labels
37  | card label | what it means | policy state |
40  | `static-only` | … no runtime observation … | `proven` for the document facts, `unproven` for the subsystem's behavior |
41  | `unproven-runtime` | the claim needs the live editor and nothing was observed | `unproven` |
43  So `static-only` is not a third policy state …
45  The binary policy still governs …
47  card is expected to resolve to `static-only` or `unproven-runtime` …
204  ## `executability/` — 13 subsystem verdict cards
207  Each card carries a verdict labeled exactly one of …
209  This index does not restate the labels: the binding verdict and its
210  evidence live in each card, and only the card is authoritative.
```

The exact command output contains the unabridged text; the abbreviated lines above identify the collision. Gate pin evidence:

```text
$ rg -n 'EXPECTED_STATIC|EXPECTED_UNPROVEN|EXPECTED_VERIFIED|CENSUS static-only' corpus/knowledge/unreal-mcp/gate/run_gate.sh corpus/knowledge/unreal-mcp/gate/README.md
corpus/knowledge/unreal-mcp/gate/run_gate.sh:78:EXPECTED_STATIC=12
corpus/knowledge/unreal-mcp/gate/run_gate.sh:79:EXPECTED_UNPROVEN=1
corpus/knowledge/unreal-mcp/gate/run_gate.sh:80:EXPECTED_VERIFIED=0
corpus/knowledge/unreal-mcp/gate/README.md:269:CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
```

At an earlier probe frame `sha256sum SKILL.md` returned `b4b94dd151b1d97bb4916ae150e740758730880b552ee741041664cc44ffa986`. A concurrent edit was visible on the later command: `sha256sum SKILL.md` returned `ae79cab11bbd3ee1e2f0590780d2431c54d8635b8c448a13580eb1c6afc98608`; `rg -n 'F7 clause|open precedence ruling|P/C precedence ruling|runtime path is identified' SKILL.md` then showed Row B at 45, Row C's conditional at 46, and §4 still open at 119–141. The file moved during this drafting; its owning seat must recheck the final hash. This matters: the r104 critic found an earlier intermediate `⇔` overclaim; the later observed table already carries the conditional correction, but no accepted precedence ruling.

### Three independent reviews (SEAT-19 / 20 / 21), with SEAT-22 cross-check

The search command actually run was:

```text
$ rg -n 'F7|precedence|ruling|six dissent|static-only|unproven-runtime|migration|recommend|binding' reports/round-104/skill/review.md reports/round-104/skill/critic.md reports/round-104/skill/bleed.md reports/round-104/r104-dissonance.md
```

Observed results and disposition:

- **SEAT-19, independent command reviewer** (`reports/round-104/skill/review.md`, SHA `8511e1188964795a3b6faf3e9c57444cb9a43fa2002bf5ccc0dee62180ece75b`): the review records the F7 census as **6**, matching this seat's reproduction above; it says the collision is still live at README SHA `c79d8dd1…`, Row B contains the six-card F7 qualifier, and “the P/C ruling remains owed.” It explicitly says a command check cannot settle a ruling. This supports retaining the distinction and confirms it is not an evidence-measurement issue.
- **SEAT-20, adversarial claim-strength critic** (`reports/round-104/skill/critic.md`, SHA `f80cc144c1eaeba1dffb94e6c3244f4e2b6c4e642631d09cfe6a15ba49ad`): at the reviewed intermediate frame, `⇔` and §4's binding sentence would prescribe `unproven-runtime` for six cards that reject it. Its distilled correction is conditional use of `unproven-runtime` and retaining `static-only` for the six; the current SKILL Row C reflects that conditional. The critic also says §4 was right not to decide for the byte-pinned subtree. Treat its intermediate wording finding as historical, not a claim that the current conditional is absent.
- **SEAT-21, scope/bleed review** (`reports/round-104/skill/bleed.md`, SHA `53ce48abeaad0cdb3e24e9e5ebe95cadcc4b9b953772722ed984665c26ffbce2`): verifies the §4 README hash and no cross-domain bleed; records the precedence collision as still open. Its scope review is not a vote for P or C, but independently confirms that the skill declines to invent a ruling.
- **SEAT-22, dissonance** (`reports/round-104/r104-dissonance.md`, SHA `ab1c4b724b07c247493aee357c9490c8285175d22dffa8e22f5d1f2cd9dc6f75`): `rg -n 'F7|P/C|precedence' reports/round-104/r104-dissonance.md` returned no direct P/C finding, so it is not counted as a fourth P/C review. The cross-round consistency record (`reports/round-104/consistency.md:111`) independently labels F7 “carried, still unruled,” reports six cards and the unchanged README SHA, and says it has persisted for four rounds.

Provenance hashes above were freshly observed with `sha256sum reports/round-104/skill/review.md reports/round-104/skill/critic.md reports/round-104/skill/bleed.md reports/round-104/r104-dissonance.md reports/round-102/skill-decision-table-draft.md reports/round-101/r101-critic-c3.md`. The r102 draft's §3 names both Option P (policy-first) and Option C (card-first); the r101 F7 finding and r102 lesson hook explicitly route the unresolved conflict to a ruling.

## Impact diffs — proposed only, no source bytes changed

The following is the distilled amendment set for an authorized owner. It is intentionally a semantic diff, not a patch applied in this lane.

1. **`corpus/knowledge/unreal-mcp/README.md` — central mapping and authority sentence.** Amend the `static-only` / `unproven-runtime` definitions to scope labels to the kind of statement a card supports: static/document facts versus an identified runtime operation with no observed result. State beside the table that runtime behavior remains binary `unproven` without a saved receipt. Replace “only the card is authoritative” with “the card owns its evidence and its application of these shared definitions; the mapping above governs label meanings.” Preserve the existing twelve/single/zero census.
2. **Six F7 cards — retain labels; remove categorical redefinition.** In `animation-controlrig.md`, `blueprints.md`, `editor-general.md`, `gameplay-gas.md`, `materials.md`, and `meshes-textures.md`, retain `static-only`. Replace the categorical “Not `unproven-runtime`” wording with the narrower statement that the inspected upstream documentation does not identify a concrete executable path for the card's capability, so this card's supported finding is documentary/static; the subsystem behavior is still unproven. A later explicit runtime operation with no receipt follows the shared `unproven-runtime` definition.
3. **`SKILL.md` — Row B, Row C, §4 only.** Row B should state that the README mapping supplies shared label semantics and the cards supply evidence/application. Row C should preserve its current separation (`unproven` binary behavior claim; ternary label conditional on the card's supported scope), and clarify the six documentation-only cases. Replace §4's “open precedence” with the accepted rule only after the operator accepts it. Rows A, D, E and the fixture-runtime sixth-row work are outside this ruling.
4. **`corpus/lessons/r102-unreal-integration.md` — append, do not rewrite history.** Keep the original hook as an accurate r102 open item. Add a dated/r105 carry-forward note naming the chosen policy-first rule, the six retained labels, the claim-vs-card distinction, and the post-change acceptance commands. Do not rewrite the historical reports or erase the original failure mode.

## Migration and compatibility

1. **Operator/subtree-owner accepts the proposal and explicitly authorizes any subtree edits.** Until then, no edit to `corpus/knowledge/unreal-mcp/README.md`, any card, or other byte-pinned corpus content is licensed by this draft.
2. Apply README semantics first, then update all six cards consistently, then revise the `SKILL.md` Row B / Row C / §4 text and append the lesson note. This order avoids temporarily presenting two meanings as one policy.
3. **Keep the label census at `12/1/0`.** The six cards stay `static-only`; `actors-scene.md` remains `unproven-runtime`; no card becomes `verified-here`. The gate's `EXPECTED_STATIC=12`, `EXPECTED_UNPROVEN=1`, `EXPECTED_VERIFIED=0` therefore need no label-census change. Do not silently flip six labels to satisfy a prose argument.
4. The README/card wording changes may affect the separate scanner-relative `POINTERS` count. Do not treat `POINTERS=103` as a stable semantic contract; after the authorized text lands, rerun the gate with a roomy `GATE_WORKDIR`, require `UNRESOLVED=0`, and have the gate-README owner re-pin any changed pointer count. This seat owns no gate README pin edit.
5. If the operator instead selects the rejected “flip the six labels” route, compatibility is materially different: the expected gate census becomes `6/7/0`, and the gate constants, gate README census example, SKILL rows, lesson, and any census references must all be changed together and tested. That is **not** this recommendation.

Acceptance commands for the future authorized migration (not run; not passed by this proposal):

```sh
# expected: the six old categorical markers are gone, with all six card labels retained
! grep -rln 'Not `unproven-runtime`' corpus/knowledge/unreal-mcp/executability/*.md
# expected: 13 cards / 12 static-only / 1 unproven-runtime / 0 verified-here
GATE_WORKDIR=<roomy-writable-directory> bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
# expected on the final authorized bytes: CARDS=13, CENSUS=12/1/0, UNRESOLVED=0, GATE RESULT: PASS
# manually verify each six-card declaration and check that SKILL Row B/C and §4 agree with the README mapping
rg -n 'static-only|unproven-runtime|P/C|precedence' SKILL.md corpus/knowledge/unreal-mcp/README.md
```

The gate command is deliberately marked future-only: this task makes a proposal and does not alter corpus bytes or claim that an authorized migration has passed.

## Write boundary

**Written by this seat:** `reports/round-105/pc/ruling-draft.md` only. This seat did not edit protected corpus files, `SKILL.md`, the lesson, gate README, fixtures, ledger, or other reports. After writing, `git diff --name-only HEAD -- corpus/knowledge/unreal-mcp/README.md corpus/knowledge/unreal-mcp/executability corpus/lessons/r102-unreal-integration.md SKILL.md corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d` printed `SKILL.md` only; that concurrent change is outside this seat's write and is owned by the SKILL seat. `git status --short -- reports/round-105/pc/ruling-draft.md` printed only `?? reports/round-105/pc/ruling-draft.md`. No commit, push, checkout, or reset was run.
