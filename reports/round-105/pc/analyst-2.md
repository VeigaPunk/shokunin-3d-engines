# SEAT-20 PC-ANALYST-2 — Case for the six cards

**Status:** C3 analysis/proposal only; no precedence ruling is applied here.
**Axes:** calibration (keep claim-level truth separate from card-level evidence class), depth (preserve the missing-path distinction), coverage (all six dissenting cards and the counterexample).

## Position

Bind the six cards' reading **at subsystem-card level**: retain `static-only` while the card establishes facts from static artifacts but has no identified subsystem call path. Keep every subsystem-behavior claim `unproven`; use `unproven-runtime` for a card only once its runtime path is identified and remains unobserved. This does not claim the behavior is proven or that a runtime route cannot exist. It states the narrower thing actually known: the available card evidence is static, and for these surfaces the executable contract/path is not identified.

This is the card-first precedence proposal (C), not a request to erase the README mapping. `SKILL.md` separates binary `proven`/`unproven` claim states from ternary subsystem-card labels, then admits they collide. The README's `static-only` row explicitly means document facts proven and subsystem behavior unproven; its `unproven-runtime` row speaks of a claim needing the live editor. The strongest honest reading keeps those units distinct: a runtime subclaim can be `unproven` (and, when appropriate, `unproven-runtime`) while the mixed evidence card remains `static-only`. The `editor-general` card says this distinction outright.

## The six cards' own testimony

The following excerpts are the direct output of a batched source extraction command (included under Evidence). They show five cards expressly using an identified-path threshold; Editor-General makes the related but distinct point that the whole card is a static artifact even though its live-call subclaim is `unproven-runtime`.

- **Animation / Control Rig** (`animation-controlrig.md:170-172`): “that label would assert a real, identified runtime path that merely went untested. Here the path is not even identified — the toolset name is unknown by construction, because the corpus defers signatures to a live `describe_toolset` (F6).” It says `static-only` is the weaker statement about the documented, unspecified surface, and warns that `unproven-runtime` invites “someone just needs to run it” when the artifacts to run against are not in hand.
- **Blueprints** (`blueprints.md:113-115`): the runtime path “is not even identified — the signatures are unknown by construction” until live `describe_toolset` (F7); the documented surface exists but is not specified. Same calibration warning: having a toolset/capability name is not yet a callable contract.
- **Editor-General** (`editor-general.md:46-52`): “`unproven-runtime` correctly labels the *live-call* sub-claim,” but the card's content is a static reading and its label is `static-only`; an attempt must first discover “whether an Editor toolset is registered at all.” This is the clearest evidence that a card label is not a substitute for the narrower claim label.
- **Gameplay / GAS** (`gameplay-gas.md:149-151`): the toolset name is unknown until `describe_toolset`, and unlike Actors-and-Scene there is no specified asset-level residue. It explicitly says its surface is documented but unspecified, and that the stricter test yields `static-only`.
- **Materials** (`materials.md:192-194`): signatures are unknown pending `describe_toolset` (F10); the only surface that had named Material methods was deleted upstream (F19–F21). It calls the subsystem documented but unspecified, then repeats the distinction between “just run it” and lacking artifacts to run against.
- **Meshes and Textures** (`meshes-textures.md:243-250`): the signatures are unknown by construction; the card calls `static-only` the “stronger” negative label and says its `StaticMeshTools` mentions carry no member name at all. Relabeling it would overstate what is known.

The positive contrast is `actors-scene.md:302-310`: that card says its path *is* identified because the transport, meta-tools, `call_tool` argument shape, endpoint and prerequisites are specified, with a plausible named toolset; what is missing is the editor. That is a meaningful boundary, not a claim that the other six have been exercised.

## Why this reading should bind

1. **It preserves epistemic strength instead of inventing a target.** “Runtime has not been observed” is true of both sides. The dissent adds a useful distinction: on one side there is a named route one could attempt once an editor is available; on the other, one must first discover whether a subsystem toolset exists and what its signatures are. Calling both `unproven-runtime` collapses “known path, test pending” into “unknown whether there is a path.” The cards do not assert nonexistence; they keep that question open.
2. **It keeps claim truth separate from card evidence class.** A consumer must not infer runtime capability from `static-only`: the README says behavior remains `unproven`, and the cards say the live contract is still missing. Conversely, moving the whole card to `unproven-runtime` makes a runtime status label do double duty as the summary of a card whose positive evidence is static. Editor-General demonstrates the cleaner split explicitly: whole-card `static-only`; live-call subclaim `unproven-runtime`.
3. **It matches the existing interim rule rather than silently resolving the collision.** `SKILL.md` row C already states the conditional: only use `unproven-runtime` when the runtime path is identified; otherwise the six cards stay `static-only`, and contradictory claims must cite the affected card. The precedence proposal should elevate that precise interim rule to the ruling, not rewrite it implicitly by relabeling six declarations.
4. **It retains the only informative cross-card comparison.** The identified-path counterexample explains why `actors-scene` differs. If all labels are assigned solely by “needs editor, nothing observed,” the labels stop communicating whether a user knows what to call and what evidence would settle the claim. The honest next step for the dissenting surfaces is discovery/specification before execution, not an invented call against an unknown surface.

## What breaks if the six are relabeled `unproven-runtime`

- **Calibration:** it upgrades uncertainty about the route into a status that the five cards explicitly reserve for a real, identified route awaiting a run. This invites readers to treat the work as “just run it” even though the card says `describe_toolset` discovery is a prerequisite. It does not make the runtime claim more proven; the binary state stays `unproven`.
- **Scope:** it erases the two-level distinction between an aggregate evidence card and its runtime subclaims. In particular, it contradicts Editor-General's explicit separation of card label from live-call label.
- **Comparability:** the known-path counterexample and the unknown-surface cards become indistinguishable by label. The label then tracks only “editor absent,” not how much of a runtime path is identified.
- **Mechanical baseline:** the gate-shaped scan I ran found 13 cards at `static-only=12 / unproven-runtime=1 / verified-here=0`; moving the six declarations produces `6 / 7 / 0`. `run_gate.sh` currently pins `EXPECTED_STATIC=12`, `EXPECTED_UNPROVEN=1`, `EXPECTED_VERIFIED=0`. That is an impact to account for in a reviewed amendment set—not semantic proof that today's labels are correct, and I did not run the gate against a hypothetical modified tree.
- **Ruling integrity:** changing card labels alone would pick the policy-first reading without resolving the label-unit ambiguity in the README or aligning the row-C rule. If the operator chooses that branch, the definitions, skill table, card rationales, and expected census must be amended together by their owners; this report does not authorize those edits.

## Proposed ruling text

> At subsystem-card level, the card's own evidence scope controls. `static-only` means static document facts were checked while subsystem behavior remains `unproven`; it does not assert behavior or deny that a runtime path exists. `unproven-runtime` is for a card whose runtime path is identified but whose behavior has no receipt. A runtime subclaim may independently be called `unproven` (or `unproven-runtime` when that subclaim's path is identified) without relabeling a mixed static-evidence card. Any aggregate/runtime statement that contradicts one of the six cards must cite it. Revisit a card label only when new evidence identifies the path or produces a bounded runtime receipt.

This is a proposed operator decision, not an adopted rule. The upstream bytes, protected knowledge files, `SKILL.md`, and gate were not edited. No Unreal runtime behavior is claimed or tested in this report.

## Evidence actually run

**Card excerpts.** Command run from the lane root; the observed output is quoted above:

```sh
python3 -c 'from pathlib import Path
files = {
"animation-controlrig.md": (170,172),
"blueprints.md": (113,115),
"editor-general.md": (46,52),
"gameplay-gas.md": (149,151),
"materials.md": (192,194),
"meshes-textures.md": (243,250),
}
root = Path("corpus/knowledge/unreal-mcp/executability")
for name, (start, end) in files.items():
    print(f"--- {name} ---")
    for number, text in enumerate((root / name).read_text().splitlines(), 1):
        if start <= number <= end:
            print(f"{number}: {text}")'
```

**Meaning, contrast, and expected census.** Command run from the lane root:

```sh
python3 -c 'from pathlib import Path
specs=[("SKILL.md",33,38),("SKILL.md",135,137),("corpus/knowledge/unreal-mcp/README.md",39,48),("corpus/knowledge/unreal-mcp/executability/actors-scene.md",302,310),("corpus/knowledge/unreal-mcp/gate/run_gate.sh",77,80)]
for p,a,b in specs:
    print(f"[{p}:{a}-{b}]")
    for i,line in enumerate(Path(p).read_text().splitlines(),1):
        if a <= i <= b: print(f"{i}: {line}")'
```

Observed excerpts:

```text
SKILL.md:34-36: binary `proven` / `unproven` governs claims; ternary labels govern subsystem cards
SKILL.md:38: The two collide without a precedence rule
SKILL.md:135-137: the interim rule labels claims on the six `static-only`; `unproven-runtime` is used only where a runtime path is identified
README.md:40: `static-only` = document facts proven, no runtime observation; subsystem behavior `unproven`
README.md:41: `unproven-runtime` = the claim needs the live editor and nothing was observed
actors-scene.md:302-305: its path is identified because transport, meta-tools, call shape, endpoint and prerequisites are specified, plus a plausible named toolset
run_gate.sh:77-80: EXPECTED_CARDS=13; EXPECTED_STATIC=12; EXPECTED_UNPROVEN=1; EXPECTED_VERIFIED=0
```

**Card inventory and counterfactual.** Command run from the lane root; the declaration expression mirrors the five anchored shapes documented at `run_gate.sh:308-312`:

```sh
python3 - <<'PY'
from collections import Counter
from pathlib import Path
import re
root = Path('corpus/knowledge/unreal-mcp/executability')
tokens = r'(verified-here|static-only|unproven-runtime)'
label_re = re.compile(
    r'^\s*\*\*(Label|Verdict)( label)?:\*\*\s*`?' + tokens + r'|'
    r'^\s*\*\*(Label|Verdict)( label)?:\s*`?' + tokens + r'`?\*\*|'
    r'^\s*(Label|Verdict)( label)?:\s*\*\*\s*`?' + tokens + r'|'
    r'^\s*\*\*`' + tokens + r'`\*\*|'
    r'^\s*#+\s*(Label|Verdict)( label)?:\s*`?' + tokens,
    re.M,
)
labels = {}
for path in sorted(root.glob('*.md')):
    lines = path.read_text().splitlines()
    decl = next(((i + 1, line, label_re.search(line)) for i, line in enumerate(lines[:40]) if label_re.search(line)), None)
    if not decl:
        print(f'NO_DECLARATION {path.name}')
        continue
    ln, line, match = decl
    lab = next(g for g in match.groups() if g in {'verified-here', 'static-only', 'unproven-runtime'})
    labels[path.stem] = lab
dissent = sorted(p.stem for p in root.glob('*.md') if 'Not `unproven-runtime`' in p.read_text())
print(f'CARDS={len(labels)} LABELS={dict(sorted(Counter(labels.values()).items()))}')
print(f'DISSENT={len(dissent)} {dissent}')
hypothetical = dict(labels)
for name in dissent:
    hypothetical[name] = 'unproven-runtime'
print(f'IF_ALL_SIX_RELABELED={dict(sorted(Counter(hypothetical.values()).items()))}')
PY
```

Observed stdout:

```text
CARDS=13 LABELS={'static-only': 12, 'unproven-runtime': 1}
DISSENT=6 ['animation-controlrig', 'blueprints', 'editor-general', 'gameplay-gas', 'materials', 'meshes-textures']
IF_ALL_SIX_RELABELED={'static-only': 6, 'unproven-runtime': 7}
```

The gate was not run on a hypothetical tree; the counterfactual is the scan's arithmetic against the currently pinned expectations, not a claimed test result.
