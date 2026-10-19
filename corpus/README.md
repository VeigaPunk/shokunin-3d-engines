# game-dev-3d — fixture corpus

Reference corpus of the **game-dev-3d** shokunin lane (campaign prymeagnt,
minted 2026-10-13): a headless **3D** fixture battery — movement
and collision, spatial queries, camera projection, scene structure,
transform composition, input-driven 3D mechanics — with discriminating
negative controls, plus the inherited games-engine-mechanics suite, an
REA static-inspection reference, and an engine census. Engine-neutral by
operator directive: Godot, Unity, Unreal Engine, three.js, and any
further 3D rendering tooling the lane discovers and validates on its
shonen path.

Purposes: (1) reference guide — every fixture carries its exact reproduction
command and expected exit signature; (2) discovery corpus for new 3D
mechanics moves; (3) inspiration source — failed fits and rejected probes
are preserved as negative results under lessons/ and live/runs/.

Upstream: https://github.com/VeigaPunk/prymeagnt-game-dev-3d (branch main
carries this corpus; craft/* branches carry round-by-round history). Local
execution references it with: git fetch game-dev-3d main

Layout:
- fixtures/ — the round-1 3D battery seeds (read-only) plus run_battery.py,
  which copies seeds to an ignored scratch run before execution.
- predecessor/ — games-engine-mechanics r15 corpus (2D-agnostic headless
  patterns: synthetic input, physics overlap, causal chains, scene
  transitions, discriminating negatives), inherited read-only.
- knowledge/ — seed provenance, the REA tooling reference, and the
  engine census (Godot/Unity/Unreal/three.js execution reality).
- lessons/ — round lesson files with cited receipts.
- live/runs/ — ignored, disposable execution receipts.

## Correction note (r106, 2026-10-18)

The paragraphs above are the mint index (commit `82c21b4`, 2026-10-13)
and are preserved verbatim. Re-measured from this checkout at HEAD
`0cc3f41` on 2026-10-18. Command log:
`reports/round-106/sweep/chunk-16.md`. No Unreal runtime claim: the
editor is not installed.

### `git fetch game-dev-3d main` does not resolve here

This repo's only remote is `origin` →
`https://github.com/VeigaPunk/shokunin-3d-engines.git`. There is no
remote named `game-dev-3d`.

```
$ git fetch game-dev-3d main
fatal: 'game-dev-3d' does not appear to be a git repository
fatal: Could not read from remote repository.
```

exit 128. That attempt did not move a ref.

The remote name exists in the parent campaign repo
`/home/vgpnk/Projects/prymeagnt/game-dev-3d` (URL
`https://github.com/VeigaPunk/prymeagnt-game-dev-3d.git`). A
non-updating probe from that cwd exited 0. After it,
`FETCH_HEAD` was absent:

```
$ git -C /home/vgpnk/Projects/prymeagnt/game-dev-3d fetch --dry-run game-dev-3d main
From https://github.com/VeigaPunk/prymeagnt-game-dev-3d
 * branch              main       -> FETCH_HEAD
```

Tracking ref `game-dev-3d/main` stayed
`ed6530e7778bb2ba472e3eb0cf58fff95900b0e2`.

From this repo, read the cited tip without adding a remote:

```
$ git ls-remote https://github.com/VeigaPunk/prymeagnt-game-dev-3d.git refs/heads/main
ed6530e7778bb2ba472e3eb0cf58fff95900b0e2	refs/heads/main
```

Do not substitute `git fetch origin main`. That remote is a different
repository. Local `origin/main` was `cb872339`; the network tip of
`shokunin-3d-engines` `main` observed the same day was `4565305f`.
Neither is this checkout (`0cc3f41`).

### The upstream sentence is stale as a description of this tree

The URL exists (private; `git ls-remote --heads` exit 0). It has three
heads, not a craft branch per round:

- `main` `ed6530e7` — 2026-10-13T13:45:41Z, "corpus refresh"
- `craft/game-dev-3d-mint` `8c67aa7e` — default branch, not `main`
- `craft/game-dev-3d-r1` `e1e863c3` — extract; `.shokunin/game-dev-3d`
  became a symlink

Both `craft/*` trees are the campaign wrapper (`.shokunin`, `config`,
`docs`, `scripts`, `skills`, `verification`). Neither has a top-level
`corpus/`. This lane's later rounds are commits on this repo, not
those branches.

`main` does contain a `corpus/` tree. It is the 2026-10-13 r68
snapshot, not HEAD. Child trees `artifacts` `3fac1f53`, `fixtures`
`6830178f`, `knowledge` `2e1dafa1`, `lessons` `29778307`, and
`predecessor` `9c49cc61` match local `a731d899` (2026-10-13 10:41:46
-0300). `corpus/README.md` blob `6f85cb29` matched this file before
this note, because the file had not been edited since mint. HEAD has
moved: `fixtures` `14087337`, `lessons` `425a06ab`, `knowledge`
`46d105d7`, `artifacts` `69791563`. `predecessor` `9c49cc61` still
matches. Upstream `.gitignore` blob `d123993e` is the same three
patterns as local `fa8ee3fb` (`live/`, `__pycache__/`, `*.pyc`) in a
different order. Tracked fixture files: 12 at `82c21b4`, 147 at HEAD.

### Paths the mint list does not name

Layout names resolve from this file's directory (`corpus/`), not as
bare names from the repo root. That is the directory-README
convention, not a broken citation.

Present now, absent from the five bullets above:

- `artifacts/` — static samples added after mint (r9–r22). Not an
  engine-execution record.
- `knowledge/unreal-mcp/` — added at r101 (`1659c03`). Static pinned
  tree. Not proof of plugin load or editor runtime.

These still resolve from `corpus/`: `fixtures/`,
`fixtures/run_battery.py`, `predecessor/`, `knowledge/` (`seed.md`,
`rea.md`, `engines.md`), `lessons/`, `live/runs/`. `live/` is
gitignored (`git check-ignore -v corpus/live/runs` →
`corpus/.gitignore:1:live/`).

`run_battery.py` still copies seeds to an ignored scratch before
execution (`--runs` default `corpus/live/runs/<stamp>/scratch`; skips
`run_battery.py`, `__pycache__`, `three`, and dotfiles). "Read-only"
is that runtime rule, not a claim that `fixtures/` is still only the
round-1 seeds. sha256 `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`.

"Preserved under `live/runs/`" overclaims durability. That tree is
ignored and disposable. Durable negative results are the lesson files.

The purpose line that every fixture carries a reproduction command,
and the lessons line that every lesson cites a receipt, were not
re-audited here. Fixture code is protected; lesson files belong to
other chunks and were being edited during this sweep. See the report.

## Coverage map (r108, 2026-10-19)

`core` means a narrow executable battery row exists at base commit `7c4e589`, not that the surface is comprehensively covered. `frontier` means named but partial or unprobed. `adjacent` marks another lane's ground. Every core count below is pinned to the base blob so the r108 additions do not silently rewrite the baseline.

| surface | status | evidence | where to learn |
|---|---|---|---|
| 3D movement/collision | core | Base row count: `git show 7c4e589:corpus/fixtures/run_battery.py \| grep -cE '^    \("(slope3d_\|floor3d_\|body3d_\|area3d_\|jump3d_)'` → 12; `corpus/fixtures/run_battery.py:306-378`. | Godot CharacterBody3D movement, floor/wall classification, collision contacts; see `corpus/SOURCES.md` |
| spatial queries | core | Base row count: `git show 7c4e589:corpus/fixtures/run_battery.py \| grep -cE '^    \("(raycast3d_\|shapecast3d_)'` → 6; `corpus/fixtures/run_battery.py:258-264,404-410`. | Godot RayCast3D, ShapeCast3D, direct-space queries; see `corpus/SOURCES.md` |
| camera projection/frustum | core | Base row count: `git show 7c4e589:corpus/fixtures/run_battery.py \| grep -cE '^    \("camera3d_'` → 15; `corpus/fixtures/run_battery.py:314-396`. These assert projection/frustum math, not pixels (`corpus/fixtures/README.md:186-195`). | Godot Camera3D projection, near/far planes, frustum classification; see `corpus/SOURCES.md` |
| scene structure/instancing | core | Base row count: `git show 7c4e589:corpus/fixtures/run_battery.py \| grep -cE '^    \("scene3d_'` → 8; `corpus/fixtures/run_battery.py:334-348`. | Godot PackedScene, resource locality, scene instances; see `corpus/SOURCES.md` |
| transform composition | core | Base row count: `git show 7c4e589:corpus/fixtures/run_battery.py \| grep -cE '^    \("(transform3d_\|remote3d_transform)'` → 4; `corpus/fixtures/run_battery.py:238-241,411-419`. | Godot Transform3D composition and RemoteTransform3D; see `corpus/SOURCES.md` |
| input-driven mechanics | core | Base row count: `git show 7c4e589:corpus/fixtures/run_battery.py \| grep -cE '^    \("input3d_'` → 2; `corpus/fixtures/run_battery.py:421-428`. | Godot synthetic input events and deterministic movement; see `corpus/SOURCES.md` |
| headless determinism | core | Base row count: `git show 7c4e589:corpus/fixtures/run_battery.py \| grep -cE '^    \("'` → 350; Godot invocations use `--headless` (`corpus/fixtures/run_battery.py:1267-1269`); the base is also recorded in `reports/frontier/unknowns-map.md:13-18`. | Godot headless SceneTree, physics ticks, and fixture-runner determinism; see `corpus/SOURCES.md` |
| physics backends: GodotPhysics3D vs Jolt | core | Base row count for explicit Jolt comparison rows: `git show 7c4e589:corpus/fixtures/run_battery.py \| grep -cE '^    \("phys3d_events_jolt_'` → 2; `corpus/fixtures/run_battery.py:451-454`; backend matrix history: `SCORECARD.md:134-146,249-253`. | GodotPhysics3D/Jolt backend selection and differential behavior; see `corpus/SOURCES.md` |
| animation | core | Base row count: `git show 7c4e589:corpus/fixtures/run_battery.py \| grep -cE '^    \("animation3d_'` → 6; `corpus/fixtures/run_battery.py:294-304`. | Godot AnimationPlayer keys, playback, blending, and AnimationTree; see `corpus/SOURCES.md` |
| mesh/ArrayMesh | core | Base row count: `git show 7c4e589:corpus/fixtures/run_battery.py \| grep -cE '^    \("mesh3d_'` → 8; `corpus/fixtures/run_battery.py:278-292`. | Godot Mesh/ArrayMesh surfaces, indices, and mesh queries; see `corpus/SOURCES.md` |
| navigation | core | Base row count: `git show 7c4e589:corpus/fixtures/run_battery.py \| grep -cE '^    \("(navagent3d_\|navigation3d_)'` → 101; `corpus/fixtures/run_battery.py:40-237,398-403`. Navmesh baking remains open (`reports/frontier/unknowns-map.md:212`). | Godot NavigationAgent3D, NavigationServer3D, and navmesh baking; see `corpus/SOURCES.md` |
| glTF/asset import | core | Base row count: `git show 7c4e589:corpus/fixtures/run_battery.py \| grep -cE '^    \("r98_gltflat_'` → 9; `SCORECARD.md:268-273`; residual payload/extension gaps: `reports/frontier/unknowns-map.md:171,217-220`. | Godot GLTFDocument import versus independent format validation; see `corpus/SOURCES.md` |
| Blender bpy | core | Base row count: `git show 7c4e589:corpus/fixtures/run_battery.py \| grep -cE '^    \("bpy_rbw3d_render"'` → 1; `corpus/fixtures/run_battery.py:564-565`. The row writes Cycles PNGs and compares hashes, not decoded pixels (`corpus/fixtures/r91_child.py:481-559`); boundary dissection: `reports/frontier/bpy-boundary.md:44-47`. | Blender bpy headless render settings and output determinism; see `corpus/SOURCES.md` |
| cannon-es (vendored, Node) | core | Base row count: `git show 7c4e589:corpus/fixtures/run_battery.py \| grep -cE '^    \("r94_cannon_'` → 19; separate probe-only runtime, vendored `r94vendor/cannon-es.js`, markers pin `node=v24.21.0` (`reports/frontier/unknowns-map.md:53`; `corpus/fixtures/PINNED-ENV.md`). | cannon-es step/accumulator semantics and Node version pinning; see `corpus/SOURCES.md` |
| pybullet (vendored, Python child) | core | Base row count: `git show 7c4e589:corpus/fixtures/run_battery.py \| grep -cE '^    \("r95_bullet_'` → 20; separate probe-only runtime (`reports/frontier/unknowns-map.md:54`); two SHM rows currently fail on host drift of the child diagnostic count (`reports/round-108/battery/README.md`). | Bullet/pybullet solver and shared-memory client behavior; see `corpus/SOURCES.md` |
| render capture/visual regression | frontier | Godot `--headless` has no rasterizer/framebuffer (`corpus/lessons/r1-headless-verification.md:173-177`); camera rows are math-only (`corpus/fixtures/README.md:186-195`). Blender has only the bounded PNG-hash case above, not a decoded-pixel oracle (`reports/frontier/bpy-boundary.md:44-47`). | Godot real-render capture, image readback, and visual-regression oracles; see `corpus/SOURCES.md` |
| Unity | frontier | Editor/runtime is not installed; Unity evidence is bounded static artifact checking (`SCORECARD.md:15-18`; `corpus/lessons/r19-unity-review.md:3,40`). | Unity scene serialization and the static-versus-editor/runtime boundary; see `corpus/SOURCES.md` |
| Unreal | frontier | Editor/runtime is not installed; the lesson explicitly makes no Unreal behavior claim (`SCORECARD.md:15-18`; `corpus/lessons/r102-unreal-integration.md:10-15`). | Unreal project/asset formats and the static-versus-editor/runtime boundary; see `corpus/SOURCES.md` |
| three.js | frontier | Node coverage is scene-graph/math only; 425/444 exports remain unprobed and WebGLRenderer has no GL context (`reports/frontier/unknowns-map.md:51,132-141`). | three.js Object3D, loaders, animation, and renderer boundaries; see `corpus/SOURCES.md` |
| Bevy | frontier | [INFERENCE] Bevy is not in the current runtime census, which lists Godot, Node/three.js, Blender, cannon-es, pybullet, Unity, and Unreal (`reports/frontier/unknowns-map.md:48-55`); absence from that census is not proof it cannot run. | Bevy ECS schedules, Transform, and headless App tests; see `corpus/SOURCES.md` |
| automated playtesting | frontier | [INFERENCE] The lane's declared executable evidence is headless fixtures (`PROVINCE.md:3-22`); no agent-playtest oracle is named in the runtime census (`reports/frontier/unknowns-map.md:48-55`). Keep the in-scope candidate to deterministic in-engine fixture exploration. | Deterministic action playback and explicit in-engine state oracles; see `corpus/SOURCES.md` |
| REA static inspection | frontier | The province limits REA to static inspection supporting 3D artifact evidence (`PROVINCE.md:8-12,39-41`); the REA carrier lesson says ZIP inventory does not prove GLB parsing/import/rendering (`corpus/lessons/r10-rea-zip-carrier.md:14-24`). | REA static artifact/container inventory and its semantic limits; see `corpus/SOURCES.md` |
| 2D production/physics | adjacent | The province explicitly refuses 2D product surfaces and names `game-dev-2d` (`PROVINCE.md:36-38`). | game-dev-2d production and physics scope; see `corpus/SOURCES.md` |
| desktop/compositor display | adjacent | The sibling province owns desktop/compositor craft and display behavior (`../mado-shokunin/PROVINCE.md:3-12`). | mado desktop, compositor, and display behavior; see `corpus/SOURCES.md` |
| general orchestration/multi-agent tooling | adjacent | The sibling province owns orchestration and tooling (`../kumitate-shokunin/PROVINCE.md:3-6`). | kumitate orchestration and multi-agent tooling; see `corpus/SOURCES.md` |
| LLM/model evaluation | adjacent | The sibling province owns LLM/model research and evaluation (`../kengaku-shokunin/PROVINCE.md:3-6`). | kengaku model research and evaluation; see `corpus/SOURCES.md` |
| reverse engineering as an end in itself or live-target analysis | adjacent | The province refuses reverse engineering as an end in itself and limits REA to supporting static 3D artifact inspection (`PROVINCE.md:33-41`); the contested lane is `revenger`. | revenger reverse-engineering practice; see `corpus/SOURCES.md` |

## Frontier

Ordered by a cheap discriminating probe before broader expansion. Base CASES counts above are not r108 verdicts. Item 4 moved to core in r108; its line is kept as the record of that frontier move.

1. **Godot headless-versus-render.** Why frontier: `--headless` disables the rasterizer/framebuffer and camera assertions are math-only (`corpus/lessons/r1-headless-verification.md:173-177`; `corpus/fixtures/README.md:186-195`); the Blender PNG-hash row is only partial (`reports/frontier/bpy-boundary.md:44-47`). First falsifiable probe: render one fixed scene at a pinned tick through a real viewport path, assert image dimensions and pixels against an authored control, and keep the headless result separate. Read first: Godot viewport rendering, image readback, and visual-regression oracles; see `corpus/SOURCES.md`.
2. **GodotPhysics3D-versus-Jolt differential.** Why frontier: backend-specific behavior already differs in pinned rows, while further solver regimes and settings remain open (`SCORECARD.md:134-146,249-253`; `reports/frontier/unknowns-map.md:196-203`). First falsifiable probe: run the same fixed contact/joint fixture and tick schedule under both backends, compare the emitted state trace, and assert one predeclared divergence or equality. Read first: Godot physics backend selection and solver/contact semantics; see `corpus/SOURCES.md`.
3. **glTF validator-versus-engine import separation.** Why frontier: the local validator is narrow and the REA ZIP inventory is not a GLB parser or engine import (`corpus/lessons/r10-rea-zip-carrier.md:14-24`; `reports/frontier/unknowns-map.md:217-220`). First falsifiable probe: pass a valid/malformed pair independently through a format validator and Godot `GLTFDocument` import; record each result separately and require the malformed control to fail at the declared layer. Read first: glTF container validation versus Godot importer behavior; see `corpus/SOURCES.md`.
4. **CharacterBody3D floor-angle tolerance — moved to core in r108.** Was frontier: the prior scorecard named the floor-angle boundary as unprobed (`SCORECARD.md:18`). Result: at `floor_max_angle=45°` the floor/wall flip sits at 45.573° (floor at 45.57°, wall at 45.58°; GodotPhysics3D in the battery, Jolt in the scratch scan) — `corpus/knowledge/godot-floor-angle-threshold.md`; rows `slope3d_bound_*` (`corpus/fixtures/run_battery.py`); receipts `reports/round-108/battery/README.md`. Remaining frontier: other `floor_max_angle` values, the ceiling predicate, `floor_block_on_wall`/snap interactions. Read first: S012 → S011 → S035 in `corpus/SOURCES.md`.
5. **Navigation mesh baking.** Why frontier: `NavigationMeshGenerator` and source-geometry baking are ranked open U25 despite path/agent coverage (`reports/frontier/unknowns-map.md:212,145-153`). First falsifiable probe: bake one mesh from fixed source geometry, assert the baked polygon/region path, then change one bake parameter and require the expected geometry or path oracle to flip. Read first: Godot NavigationMeshGenerator and source-geometry data; see `corpus/SOURCES.md`.
6. **Bevy runtime census.** Why frontier: [INFERENCE] Bevy is absent from the listed runtime census (`reports/frontier/unknowns-map.md:48-55`), so its availability is unknown, not disproven. First falsifiable probe: inventory only already-present Bevy/Rust tooling; if present, step a minimal headless App with a fixed transform schedule and assert the exact post-step state, otherwise record the missing prerequisite without installing. Read first: Bevy ECS schedule, Transform, and headless App testing; see `corpus/SOURCES.md`.
7. **Agent playtesting with an explicit oracle.** Why frontier: [INFERENCE] no agent-exploration test is documented in the current runtime census (`reports/frontier/unknowns-map.md:48-55`); scope stays bounded to this lane's deterministic in-engine fixture exploration, not orchestration or LLM evaluation (`PROVINCE.md:3-22`; `../kumitate-shokunin/PROVINCE.md:3-6`; `../kengaku-shokunin/PROVINCE.md:3-6`). First falsifiable probe: run a fixed action trace in one toy 3D scene and assert exact final transform, tick count, and collision-free route; a one-step action mutation must fail the oracle. Read first: deterministic action playback and fixture-state oracles; see `corpus/SOURCES.md`.
8. **REA static artifact inspection boundary.** Why frontier: REA contributes bounded static evidence but ZIP inventory does not establish format semantics or runtime behavior (`PROVINCE.md:8-12,39-41`; `corpus/lessons/r10-rea-zip-carrier.md:14-24`). First falsifiable probe: inspect a valid/malformed 3D container pair, preserve exact member hashes, and compare only inventory facts with a separate engine-import result. Read first: REA artifact/container inventory and evidence limits; see `corpus/SOURCES.md`.
