# game-dev-3d province

Owns: 3D game production verified by executable headless fixtures — 3D
movement and collision, spatial queries, camera projection and frustum
behavior, scene structure and instancing, transform composition, 3D
input-driven mechanics, headless determinism — across 3D engines and
rendering tooling: Godot, Unity, Unreal Engine, three.js, and any further
3D tooling the lane discovers and validates on its shonen path. REA
tooling is a supporting evidence source for the static inspection of 3D
artifacts (exported binaries, asset/container formats, serialized scene
data), under the observation/inference/unknown discipline the revenger
lane established.

Engine census and execution reality live in corpus/knowledge/engines.md
and are maintained by the lane. The standing host fact at mint: Godot
4.7.2 headless is installed and is the executable runtime; Unity and
Unreal editors are not installed; three.js runs under node for
scene-graph/math fixtures without a GL context. Where an engine cannot
execute headless on this host, the lane builds format-level and static
fixtures (scene/asset containers, projection math, serialization
round-trips, REA inspection) and labels runtime behavior unproven —
never fabricating runtime evidence.

Sources (read-only):
- corpus fixtures under .shokunin/game-dev-3d/corpus/ (predecessor suite
  seeded from games-engine-mechanics r15 with provenance in
  corpus/knowledge/seed.md; round-1 3D battery under corpus/fixtures/)
- ~/Projects/gamez/research/ (read-only demand context)
- 3D engines/runtimes per the census (Godot 4.7.2 headless installed)
- REA skill: ~/.agents/skills/reverse-engineer-anything/ (instructions
  only); REA package via `npx -y rea-agents@6.4.0` within authorized scope

Refuses: engine/editor source mutation; publishing or store submission;
asset rights clearance (art-east-asian-design); harness/evidence auditing
(harness-integrity, gate-evidence, rlm-dispatch); narrative canon (lore
lane — contested scope is reported, not absorbed); 2D production scope
(game-dev-2d — shared fixture patterns are inherited, 2D product surfaces
are not); reverse engineering as an end in itself or live-target runtime
evidence (revenger). REA use here is static inspection in service of 3D
craft evidence only: no live-target execution beyond a declared target
and lifecycle, no DRM circumvention, no publishing reversed material.
Installing new engines/tooling is allowed only within a declared round
scope with operator-visible setup receipts; setup never silently installs
unrelated software.

Only writes `.shokunin/game-dev-3d/**` and its own reports. Domain source
trees are read-only.

## Core

- 3D movement/collision, spatial queries, and camera projection/frustum have executable Godot rows; the counts are deliberately narrow and baseline-pinned in the corpus map. Evidence: `corpus/fixtures/run_battery.py:258-264,306-396,404-410`; camera proofs are mathematical, not rendered pixels (`corpus/fixtures/README.md:186-195`).
- Scene structure/instancing, transform composition, and mesh/ArrayMesh have paired positive/control rows, not a general serialization or rendering guarantee. Evidence: `corpus/fixtures/run_battery.py:238-241,278-292,334-348,411-419`.
- Input-driven movement and animation have deterministic in-engine fixture cases. Evidence: `corpus/fixtures/run_battery.py:294-304,421-428`.
- Navigation has path/agent behavior coverage, while mesh baking remains a frontier. Evidence: `corpus/fixtures/run_battery.py:40-237,398-403`; `reports/frontier/unknowns-map.md:212`.
- glTF/GLB import has a pinned Godot fixture lattice; this does not collapse format validation, engine import, and static inventory into one claim. Evidence: `SCORECARD.md:268-273`; `reports/frontier/unknowns-map.md:171,217-220`.
- GodotPhysics3D/Jolt behavior has backend-specific executable rows; the pinned build and measured regimes are not a universal backend-equivalence claim. Evidence: `corpus/fixtures/run_battery.py:451-454`; `SCORECARD.md:134-146,249-253`.
- Headless determinism is supported by the baseline 350-row CASES battery and `--headless` invocation path. Evidence: `reports/frontier/unknowns-map.md:13-18`; `corpus/fixtures/run_battery.py:1267-1269`.
- Blender bpy has headless evaluation and a Cycles PNG-hash case; it is not a decoded-pixel oracle for Godot rendering. Evidence: `corpus/fixtures/run_battery.py:564-565`; `reports/frontier/bpy-boundary.md:44-47`.

## Frontier

- Godot visual capture and visual regression need a real render path: `--headless` has no rasterizer/framebuffer (`corpus/lessons/r1-headless-verification.md:173-177`); the Blender case is only a bounded PNG hash (`reports/frontier/bpy-boundary.md:44-47`).
- CharacterBody3D floor-angle boundary — moved to core in r108 (45.573° effective boundary at a 45° limit, `corpus/knowledge/godot-floor-angle-threshold.md`); still frontier: other limits, the ceiling predicate, `floor_block_on_wall`/snap interactions.
- Expand GodotPhysics3D/Jolt differentials beyond existing pinned cells; several solver/contact regimes remain open (`reports/frontier/unknowns-map.md:196-203`).
- Separate glTF structural validation from Godot engine import and broaden payload/extensions beyond the existing lattice (`reports/frontier/unknowns-map.md:171,217-220`; `corpus/lessons/r10-rea-zip-carrier.md:14-24`).
- Bake and falsify a NavigationMesh from fixed source geometry (`reports/frontier/unknowns-map.md:212`).
- Unity and Unreal runtime/editor behavior remain unproven here; the host census says editors are not installed and evidence is static/format-level only (`SCORECARD.md:15-18`; `reports/frontier/unknowns-map.md:55`).
- Three.js remains a Node scene-graph/math surface without GL; Bevy availability is unverified. Evidence: `reports/frontier/unknowns-map.md:48-55,132-141`; Bevy absence is [INFERENCE].
- Bound any agent-playtesting probe to deterministic in-engine fixture exploration with an explicit state oracle; general orchestration and LLM evaluation are adjacent. Evidence: `PROVINCE.md:3-22`; `../kumitate-shokunin/PROVINCE.md:3-6`; `../kengaku-shokunin/PROVINCE.md:3-6`.
- REA remains static artifact inspection in service of 3D evidence, not unrestricted reverse engineering or live-target analysis (`PROVINCE.md:8-12,33-41`; `corpus/lessons/r10-rea-zip-carrier.md:14-24`).

## Adjacent

- 2D production and physics belong to `game-dev-2d`; shared fixture patterns do not transfer 2D product ownership (`PROVINCE.md:36-38`).
- Desktop/compositor display behavior belongs to `mado-shokunin` (`../mado-shokunin/PROVINCE.md:3-12`).
- General orchestration and multi-agent tooling belong to `kumitate-shokunin` (`../kumitate-shokunin/PROVINCE.md:3-6`).
- LLM/model research and evaluation belong to `kengaku-shokunin` (`../kengaku-shokunin/PROVINCE.md:3-6`).
- Reverse engineering as an end in itself and live-target analysis remain outside this lane; REA use here is supporting static inspection only (`PROVINCE.md:33-41`; contested lane: `revenger`).

## Correction note (r108, 2026-10-19)

The write-scope line `Only writes .shokunin/game-dev-3d/**` and the `.shokunin/game-dev-3d/corpus/` sources line refer to a root absent from this repo (`ls -d .shokunin` rc 2; dead-root history in `SCORECARD.md` r103/r106, lines 311-312 and 341); live scope is this repository's tracked tree (`corpus/**`, `reports/**`, ledgers). The original lines remain preserved verbatim above.
