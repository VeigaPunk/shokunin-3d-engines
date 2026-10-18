# P/C precedence: exact dissent from six cards

**Extraction command run from the lane root** (stdout is reproduced in the quoted extracts below):

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

**Animation-ControlRig.** Exact argument: “that label would assert a real, identified runtime path that merely went untested. Here the path is not even identified — the toolset name is unknown by construction, because the corpus defers signatures to a live `describe_toolset` (F6). The correct statement is weaker: the surface is documented as existing and is not specified. That is `static-only`. The distinction matters for calibration: `unproven-runtime` invites "someone just needs to run it"; `static-only` correctly says "running it is necessary *and* the artifacts to run it against are not in hand."” (`corpus/knowledge/unreal-mcp/executability/animation-controlrig.md:170-172`). Criterion: use `static-only` when even the toolset/path is unidentified and the callable contract is absent; reserve `unproven-runtime` for an identified path awaiting execution.

**Blueprints.** Exact argument: “that label would assert a real, identified runtime path that merely went untested. Here the path is not even identified — the signatures are unknown by construction, because the corpus defers them to a live `describe_toolset` (F7). The correct statement is weaker: the surface is documented as existing and is not specified. That is `static-only`. The distinction matters for calibration: `unproven-runtime` invites "someone just needs to run it"; `static-only` correctly says "running it is necessary *and* the artifacts to run it against are not in hand."” (`corpus/knowledge/unreal-mcp/executability/blueprints.md:113-115`). Criterion: the Blueprint capability claim and `BlueprintTools` name do not identify methods or signatures, so missing runtime execution alone is insufficient for `unproven-runtime`.

**Editor-General.** Exact argument: “Not `unproven-runtime` **as the card label**: `unproven-runtime` correctly labels the *live-call* sub-claim (§5), but the card's own content is a static reading of pinned text, and the seat declares `static-only`. §5 states the runtime sub-claim explicitly so it is not lost. The card is `static-only` because the evidence class is static and the domain is under-specified upstream — a runtime attempt would first have to discover whether an Editor toolset is registered at all (§6).” (`corpus/knowledge/unreal-mcp/executability/editor-general.md:46-52`). Criterion: label the whole evidence artifact by its static evidence class (`static-only`), while retaining `unproven-runtime` for the narrower live-call proposition; a toolset must first be discovered.

**Gameplay-GAS.** Exact argument: “that label asserts a real, identified runtime path that merely went untested. Here the path is not identified — the toolset name is unknown by construction, because the corpus defers signatures to a live `describe_toolset` (F7), and unlike Actors-and-Scene there is no specified asset-level residue to reason from either. The correct statement is weaker: the surface is documented as existing and is not specified. That is `static-only`.” The card adds the set-level dissent: “This card follows the **stricter** test (as `blueprints.md` and `animation-controlrig.md` do): the tool surface is unspecified, so `static-only`. If the adjudicator prefers `unproven-runtime` for the whole set, this card is one whose reasoning would need to change, and the change would be a one-line relabel — no evidence below moves.” (`corpus/knowledge/unreal-mcp/executability/gameplay-gas.md:149-151`). Criterion: `static-only` wins under the strict rule when there is no identified tool surface or asset-level residue; the card explicitly allows a whole-set `unproven-runtime` ruling as a label-only alternative that leaves evidence unchanged.

**Materials.** Exact argument: “that label would assert a real, identified runtime path that merely went untested. Here the path is not identified — the signatures are unknown by construction, because the corpus defers them to a live `describe_toolset` (F10), and the one surface that ever named Material methods was deleted upstream (F19–F21). The correct statement is weaker: the subsystem is documented as existing and is not specified. That is `static-only`. The distinction matters for calibration: `unproven-runtime` invites "someone just needs to run it"; `static-only` correctly says "running it is necessary *and* the artifacts to run it against are not in hand."” (`corpus/knowledge/unreal-mcp/executability/materials.md:192-194`). Criterion: the pinned surface has no identified methods or signatures, and historical method documentation is deleted, so an executable path is not established.

**Meshes-Textures.** Exact argument: “that label would assert a real, identified runtime path that merely went untested. Here the path is not identified at all — the signatures are unknown **by construction**, because the corpus defers them to a live `describe_toolset` (F7). The correct statement is weaker: the surface is documented as existing and is not specified. This card is deliberately the *stronger* of the two negative labels. The distinction matters for calibration: `unproven-runtime` invites "someone just needs to run it". `static-only` correctly says "running it is necessary **and** the artifacts to run it against are not in hand". For Meshes and Textures specifically, the corpus is thinner than for Blueprints: Blueprints at least yields a toolset name plus a negative tool-name example (`BlueprintTools.create`), whereas here the two `StaticMeshTools` mentions carry no member name at all. A mesh card labeled `unproven-runtime` would overstate how much is known.” (`corpus/knowledge/unreal-mcp/executability/meshes-textures.md:243-250`). Criterion: even the named `StaticMeshTools` surface has no member name; calling it `unproven-runtime` would overstate the known executable contract.
