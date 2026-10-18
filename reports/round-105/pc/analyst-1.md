# SEAT-19 PC-ANALYST-1 — Case for binding the README runtime label

**Status:** C3 analysis / ruling proposal only. No byte-pinned file or card was changed.

**Axes:** calibration (one shared definition), coverage (all runtime claims classifiable), and safe claims (no behavior implied without a live receipt).

## Position

Bind the README’s `unproven-runtime` definition to runtime-capability verdicts: if the claim needs the live editor and no runtime observation exists, it is `unproven-runtime` whether or not the tool, route, or schema has already been identified. “Identified runtime path” is not in the definition. Five of the six dissenting cards add that as an extra condition; the sixth explicitly says `unproven-runtime` correctly labels its live-call sub-claim, yet retains `static-only` as the whole-card label. [E1, E2]

This is a precedence proposal about the **runtime verdict**, not a claim that the static evidence is worthless. The README makes the policy binary at claim level: static checks can prove what pinned files say, while behavior requiring the editor remains unproven. Preserve file-level facts and receipts in each card; do not let those facts change the label on the subsystem-behavior conclusion. [E1]

The strongest counter-reading is real: the README also defines `static-only` as proven document facts plus unobserved subsystem behavior, and calls that the “honest split.” That supports the six cards if their label is read as an aggregate evidence summary. The text never explicitly orders that mixed-card summary against the direct `unproven-runtime` rule. This proposal makes the missing precedence explicit: the label follows the operative claim being adjudicated; for a runtime capability/callability verdict, row `unproven-runtime` controls, while static document claims remain separately proven. [E1]

## Why the README definition should control

1. **It states the predicate; the dissent adds a hidden one.** The README’s exact test is “the claim needs the live editor and nothing was observed.” It separately calls anything requiring a live editor `unproven`, and says runtime claims are labeled, never asserted. There is no “identified path” qualification. Requiring a known toolset before using `unproven-runtime` narrows the shared vocabulary without textual authority. [E1]
2. **Discovery itself is editor-dependent.** The cards’ rationales repeatedly say tool signatures are knowable only through live `describe_toolset`; five specifically reject `unproven-runtime` because the path/schema is unknown. But if a live call is the only way to discover whether a toolset exists, the runtime claim still needs the editor. The unknown is *what to call*, not *whether a static check observed behavior*. [E2]
3. **The contrast card demonstrates the imported threshold.** `actors-scene.md` says its path is identified because transport, `call_tool`, endpoint, and prerequisites are specified, then explicitly calls that the reason for `unproven-runtime`; it records the opposite tool-surface argument as residual tension. That is a defensible proposed distinction, but it is not the README’s stated predicate. [E3]

## What breaks if the six remain `static-only`

- The vocabulary becomes author-dependent: the same host fact—runtime operation needs the editor, no runtime observation—maps to `unproven-runtime` only after someone has documented enough of a route. Readers must inspect each card’s prose to learn that the label has acquired an unstated “path identified” exception. [E1–E3]
- A `static-only` summary can be mistaken for “static evidence is enough for this verdict,” even though the cards themselves say it is not: they defer actual signatures or behavior to a live editor. That increases the chance a consumer treats a missing schema as a documentation gap to fill from prose, rather than an unproven runtime claim requiring an editor receipt. [E2]
- Cross-card comparison stops measuring runtime uncertainty consistently. The distinction then tracks upstream documentation richness (whether a candidate tool/path was named), not the README’s stated condition (live editor needed; nothing observed). The detailed static evidence remains useful, but cannot substitute for a single consistent runtime label. [E1, E2]

The price of binding is that the top-level label no longer summarizes both evidence classes at once. Pay that price transparently: keep static facts and their checks in the card, but use `unproven-runtime` for its runtime-capability verdict. Do not invent a fourth label or erase proven document facts.

## Proposed operative wording

> For a subsystem-behavior or callability claim, use `unproven-runtime` whenever a live Unreal Editor is required and no runtime observation was made, whether or not the toolset or route is identified. `static-only` describes a claim about pinned document facts established by static checks; it does not downgrade a runtime claim merely because the card also contains proven document facts. A mixed card keeps those static facts as evidence and labels its runtime verdict `unproven-runtime`.

**Not applied:** this is a proposal for the operator’s P/C ruling. It does not edit the subtree README, any verdict card, gate, or pinned file.

## Evidence actually collected

**[E1] README predicate and mixed-card counter-reading.**

Command run: `sed -n '12,60p' corpus/knowledge/unreal-mcp/README.md`

Observed excerpts:

```text
The policy is binary. Every claim in this subtree is either proven or unproven — no middle ground.
- unproven — anything that requires a live Unreal Editor … Runtime claims are labeled, never asserted.
| static-only | the vendored document facts are proven by a static check run here; no runtime observation was made | proven for the document facts, unproven for the subsystem's behavior |
| unproven-runtime | the claim needs the live editor and nothing was observed | unproven |
So static-only is not a third policy state — it is the honest split of a card whose file-level claims are proven and whose behavior claims are not.
```

**[E2] Six dissenting cards and their labels/rationales.**

Command run:

```sh
python3 -c 'from pathlib import Path; ps=sorted(Path("corpus/knowledge/unreal-mcp/executability").glob("*.md")); hits=[p for p in ps if "Not `unproven-runtime`" in p.read_text()]; print("DISSENT_COUNT",len(hits)); print("DISSENT_CARDS", " ".join(p.stem for p in hits)); print("LABELS"); [print(p.stem, next((s for s in p.read_text().splitlines() if s.startswith("**Label:**")), "NO_LABEL")) for p in hits]'
```

Observed output:

```text
DISSENT_COUNT 6
DISSENT_CARDS animation-controlrig blueprints editor-general gameplay-gas materials meshes-textures
LABELS
animation-controlrig **Label:** `static-only`
blueprints **Label:** `static-only`
editor-general **Label:** `static-only`
gameplay-gas **Label:** `static-only`
materials **Label:** `static-only`
meshes-textures **Label:** `static-only`
```

A second command printed each card’s label and rationale paragraph. Five say `unproven-runtime` would assert a “real, identified runtime path”; `editor-general.md` instead says the label correctly applies to the “live-call sub-claim,” while its whole card is a static reading. Its output confirms the five rationales hinge on whether a path/signature is already identified; the editor card explicitly separates the live-call sub-claim from its whole-card static label. [E2]

**[E3] Where the “identified path” test comes from.**

Command run:

```sh
python3 -c 'from pathlib import Path; p=Path("corpus/knowledge/unreal-mcp/executability/actors-scene.md"); a=p.read_text().splitlines(); print("\n".join(f"{i}: {a[i-1]}" for i in range(296,318)))'
```

Observed: the card says the path is identified because transport, meta-tools, call shape, endpoint, and prerequisites are specified; it then calls the stricter tool-surface interpretation “residual tension” and cites the README’s label definition and policy line as its basis for `unproven-runtime`.

**[E4] Host runtime availability.**

Command run: `which UnrealEditor UnrealEditor-Cmd`

Observed output: `which: no UnrealEditor …`; `which: no UnrealEditor-Cmd …`; command exit code `2`. Neither editor executable was found on this host; no runtime test is claimed here.
