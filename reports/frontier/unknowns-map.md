# game-dev-3d frontier unknowns map — post-r100

Seat: scout (unknowns-map). Lane: `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`.
Host: devin substrate, 32 cores, sibling lanes active. Engine under probe:
`4.7.2.stable.arch_linux.ed1daf0bf` (`/usr/bin/godot --headless`).
Confidence tags: **[O]** receipt-pinned observation, **[I]** labelled inference,
**[?]** unknown. Coverage numbers are a **name-mention grep proxy**, never
semantic proof — a class can be mentioned without being measured, and measured
without being named.

## 0. What "post-r100" means, and provenance

- **Committed frontier**: HEAD `c28783a` = r99 adjudicate (ADMIT-with-findings on
  `f1ff626`), 342 battery rows, LOG last entry "ROUND 99". **[O]**
- **Uncommitted r100 work in the worktree**: `M corpus/fixtures/run_battery.py`
  (342 → **350** CASES rows), untracked `r100_fpslat.gd` (17 rows) and six
  `r100_probe_r100b_*.gd` probes. Wave-B (critic/verifier/fold/adjudicator) has
  not run on it. **[O]**
- **r101 forward reports already landed** (2026-10-15): `reports/round-101/
  r101-unknowns-map.md` (41-row ranked table + 3 measured unknowns, 264 children),
  `bpy-dissection.md` (metadata flake), `navagent-dissection.md` (1-tick miss
  mechanism). **[O]**
- **Contract-file divergence (recorded, not resolved by this seat)**: the wave
  task card `.ufo/waves/shokunin-train-20261015-w22/tasks/g3d-unknowns-map.md`
  names a different deliverable (`reports/round-101/r101-unknowns-map.md` +
  `corpus/live/r101-unknowns/`), which an earlier seat already produced. This
  dispatch names `reports/frontier/unknowns-map.md` + `corpus/live/unknowns-map/`;
  the dispatch prompt is the canonical assignment, so that is what was produced.
  **[O]**
- **Probes this seat ran** (bounded, read-only, all receipts gitignored):
  1. `um_classcensus.gd` — one Godot headless run, rc=0, 2.5 s, 8 586 stdout
     lines: every ClassDB class with parent/3D flags/member counts, full
     declared-member lists for 137 target classes, a 21-token knob scan over all
     classes, engine singletons, 105 `physics/`+`navigation/`+`animation/`+
     `rendering/limits` project settings. **[O]**
  2. `three_exports.txt` — node v24.21.0, `three` 0.186.1 (REVISION 186):
     444 exports enumerated. **[O]**
  3. `join.py` — grep-proxy join of the census against all fixture text
     (123 files) and all 289 reports. **[I]** by construction.
- Receipts: `corpus/live/unknowns-map/` — `proj/um_classcensus.gd`,
  `runs/census.stdout.txt`, `runs/three_exports.txt`, `summary.txt`,
  `uncovered_classes.tsv` (313 rows), `uncovered_members.tsv` (5 010 rows),
  `token_hits.tsv`, `settings.tsv`, `three_coverage.tsv`, `families.txt`,
  `manifest.sha256`. **Only tracked write: this report. No commits.**

## 1. Runtime census (this host, this seat)

| runtime | version | how it runs here | frontier status |
|---|---|---|---|
| Godot | 4.7.2.stable.arch_linux.ed1daf0bf | `/usr/bin/godot --headless`, `--script` and real main loop, 30/60/120 tps, GodotPhysics + Jolt + Dummy | primary executable runtime; **no renderer** (`--write-movie` SIGSEGVs) |
| Node + three.js | node v24.21.0 / three 0.186.1 (REVISION 186) | `node corpus/fixtures/three/run_*.mjs`, no GL context | scene-graph/math only |
| Blender / bpy | 5.2.1 LTS, embedded CPython 3.14.7 | `blender -b -P` child rigs | eval-event + render-metadata surface |
| cannon-es | vendored `r94vendor/cannon-es.js` (no version string in the vendor tree) | `node r94_child.mjs` | separate runtime, probe-only |
| pybullet | vendored `r95vendor/pybullet.cpython-314-x86_64-linux-gnu.so` (no version string recovered by a bounded `strings` grep) | python child | separate runtime, probe-only |
| Unity / Unreal | not installed | static/format artifacts only (r19/r22) | census unchanged since mint |

**[O]** No Godot engine source exists on this host (recorded independently in
r100-scout §6, r100-boundary §11, r101-unknowns §6, r101-navagent §6). Every
"why" below is therefore measured-not-source-derived, and the delegated
read-only probe route is dead: three dispatched `ufo-labrat` probes (r100,
r101-unknowns, r101-bpy) all returned **BLOCKED — no exec surface**. Do not
budget a delegated probe for a measurement.

## 2. Surface coverage — what the lane actually covers, quantified

### 2.1 The class surface **[O]**

- `ClassDB` exposes **1 054 classes**; **313** are 3D-relevant by this seat's
  filter (Node3D descendants + 3D-adjacent names); **87** of those are named
  anywhere in a tracked seed fixture; **226 are not**.
- **121 Node3D descendants** exist; **37** are named in seed fixtures; **84 are
  never named**. Of the 226 uncovered: 34 appear only in round *probe* files,
  31 in some report, 4 in a lesson.
- Declared-member dump (137 target classes, `no_inheritance=true`): **4 363
  methods / 1 405 properties / 121 signals**; **5 010** of those members are
  never named in any fixture text.
- `RenderingServer`: **535 declared methods, 533 never named in any fixture**,
  and **zero mentions in 289 report files** — the single largest structural gap
  in the lane's evidence base. **[O]**

### 2.2 Unprobed 3D class families (seed-fixture mentions = 0) **[O]**

`declared` = sum of the classes' ClassDB method-list sizes (includes inherited),
so it over-states work; it is a ranking weight, not a count of novel APIs.

| family | classes (Node3D) | declared | notable members |
|---|---|---|---|
| render-visual | 45 (42) | 14 241 | `RenderingServer` 597, `CPUParticles3D` 404, `GPUParticles3D` 377, `Label3D` 375, `Sprite3D`/`AnimatedSprite3D`/`SpriteBase3D`, `MultiMeshInstance3D` 316, `GeometryInstance3D`, `Light3D`/`Directional`/`Omni`/`Spot`/`AreaLight3D`, `ReflectionProbe`, `Decal`, `FogVolume`, `VoxelGI`, `LightmapGI`, `OccluderInstance3D`, `VisibleOnScreenNotifier3D`/`Enabler3D`, `TextMesh` |
| CSG (subset of render-visual, listed separately) | 9 (9) | 3 170 | `CSGShape3D`, `CSGCombiner3D`, `CSGBox3D`/`Sphere3D`/`Cylinder3D`/`Torus3D`/`Polygon3D`/`Mesh3D`, `CSGPrimitive3D` |
| skeletal modifiers / IK | 28 (25) | 7 812 | `LookAtModifier3D`, `CCDIK3D`, `FABRIK3D`, `JacobianIK3D`, `SplineIK3D`, `TwoBoneIK3D`, `SkeletonIK3D`, `BoneTwistDisperser3D`, `RetargetModifier3D`, `SpringBoneSimulator3D` + 4 `SpringBoneCollision*`, `ModifierBoneTarget3D`, `XRBodyModifier3D`/`XRHandModifier3D`/`XRFaceModifier3D` |
| XR | 61 (9) | 8 696 | `OpenXRInterface`, `XRNode3D`, `XRCamera3D` (probe-only), `XRController3D`, `XRBodyTracker`, `OpenXRCompositionLayer*`, `OpenXRHand`, `OpenXRRenderModel*`, `OpenXRVisibilityMask`, 3 editor classes |
| animation nodes | 20 (1) | 2 623 | `AnimationNodeBlendSpace1D/2D`, `AnimationNodeOneShot`, `AnimationNodeTransition`, `Add2/3`, `Blend2/3`, `Sync`, `TimeScale`, `TimeSeek`, `AnimationNodeAnimation` (probe-only for most) |
| navigation | 6 (2) | 950 | `NavigationRegion3D` (report-only), `NavigationObstacle3D`, `NavigationPolygon`, `NavigationMeshSourceGeometryData3D`, `NavigationMeshGenerator`, `NavigationServer3DManager` |
| physics resources/extensions | 11 (0) | 1 476 | `PhysicsServer3DExtension` 433, `PhysicsDirectBodyState3DExtension` 162, `PhysicsDirectSpaceState3DExtension` 76, `Shape3D`, `CylinderShape3D`, `PhysicsMaterial` |
| gridmap | 1 (1) | 323 | `GridMap` |
| audio (3D) | 2 (2) | 590 | `AudioStreamPlayer3D`, `AudioListener3D` — **audio lane's province, flagged not absorbed** |
| scene/other | 26 | 3 370 | `Marker3D`, `RootMotionView`, `ParticleProcessMaterial`, the 15-class `InputEvent*` family, `InputMap`, `Performance`, `EngineProfiler`/`EngineDebugger`, `ViewportTexture`, `Timer` (probe-only) |

### 2.3 Member-level gaps inside *probed* classes **[O]** (declared-only; uncovered = never named in fixture text)

| class | methods (uncovered) | properties (uncovered) | signals (uncovered) |
|---|---|---|---|
| `PhysicsServer3DExtension` | 196 (195) | 0 | 0 |
| `NavigationServer3D` | 154 (117) | 0 | 3 (3) |
| `PhysicsServer3D` | 175 (107) | 0 | 0 |
| `Animation` | 85 (75) | 4 (2) | 0 |
| `NavigationAgent3D` | 87 (75) | 36 (26) | 6 (6) |
| `GLTFState` | 71 (64) | 31 (20) | 0 |
| `Node3D` | 71 (63) | 19 (7) | 1 (1) |
| `NavigationMesh` | 60 (56) | 35 (32) | 0 |
| `AnimationPlayer` | 54 (48) | 13 (11) | 2 (2) |
| `Area3D` | 50 (48) | 28 (19) | 8 (0) |
| `RigidBody3D` | 60 (44) | 29 (13) | 5 (1) |
| `Camera3D` | 49 (43) | 15 (8) | 0 |
| `SceneTree` | 47 (43) | 11 (8) | 9 (7) |
| `Skeleton3D` | 56 (41) | 6 (6) | 6 (6) |
| `AnimationMixer` | 43 (34) | 13 (9) | 7 (7) |
| `CharacterBody3D` | 49 (34) | 18 (5) | 0 |
| `NavigationPathQueryParameters3D` | 30 (30) | 15 (10) | 0 |
| `RayCast3D` / `ShapeCast3D` | 35 (30) / 39 (30) | 12 (5) / 13 (5) | 0 |
| `GLTFDocument` | 25 (18) | 7 (6) | 0 |
| `MultiMesh` | 38 (36) | 14 (12) | 0 |
| `ArrayMesh` / `Mesh` / `MeshInstance3D` | 30 (28) / 28 (23) / 21 (21) | 5 / 1 / 5 | 0 |
| `Curve3D` | 34 (28) | 6 (3) | 0 |

Read this as **breadth, not depth**: the lane's depth axis is carried by ~350
CASES rows over 53 fixture files; the rows above are the API surface those rows
have not touched. Many uncovered methods are engine plumbing (`_set`,
`_get`, `_validate_property`, 2D-shared members on the servers) — the table is a
scoping aid for the next probes, not 5 010 individual unknowns.

### 2.4 three.js **[O]**

444 exports; **19** are named in the lane's node fixtures — and two of those are
false positives (`console.error`/`console.log`): **17 real**. Everything else is
unprobed, including `AnimationMixer`/`AnimationClip`/`AnimationAction`,
`Bone`/`Skeleton`/`SkinnedMesh`, `InstancedMesh`/`BatchedMesh`, `Matrix3`,
`Euler`, `Box3`/`Sphere` (only `Sphere` is named), splines, all loaders,
`Raycaster` extensions (`Layers` was exercised via the r68 layer suite),
`Line`/`Points`, and the entire `WebGLRenderer` family (no GL context, so
out of scope by construction).

### 2.5 What *is* covered (so the gap list stays honest) **[O]**

350 CASES rows (worktree; 342 committed) across 53 fixtures: CharacterBody3D
floor/contact/slide/jump/slope, camera projection/depth/ortho, Area3D chains,
RayCast3D/ShapeCast3D, navigation (path/agent/detour/follow/retarget/mutation
windows), transform composition, scene/resource serialization, mesh/array/index/
trimesh/face picking, skeleton pose/rotation/attachment, animation
keys/playback/blend, path/curve following, input-driven movement, physics
server events + joints + node lattice (r83–r89, r96–r97), Jolt determinism,
cannon-es and Bullet/PyBullet lattices, bpy eval-events, GLTF/GLB runtime
import, AnimationTree (r99), and the scheduler/rate surface (r100/r101).

## 3. Laws with known gaps

"Law" = a measured invariant the lane ships fixtures against. Each row names the
residual unknown, not the law.

| # | law (round) | status | residual unknown | falsifiable headless? |
|---|---|---|---|---|
| L1 | `--fixed-fps N` pins the process delta to 1/N and the physics step to 1/tps; interleave + trajectory are loop-mode invariant (r100, r101 §2) | measured, 9/9 modes both loop modes, identical traj hash | exact `a(N)` startup-offset form — best fit falsified at 10 cells (F ∈ {8,14,16,24,32,64}); end-of-run phase slip (final interval up to 1.5·F); N < tps startup burst (10 ticks in one frame at N=45) | **yes** |
| L2 | `max_physics_steps_per_frame` clamps the catch-up path, bypassed by `--fixed-fps` (r101 §3) | measured both loop modes (6→1) | rendered/throttled loop; interaction with a deterministic slow frame at tps 30/120 | yes |
| L3 | r92 frame-boundary law: `set_notify_transform(false)` freezes RemoteTransform3D propagation; local mode is synchronous at the write | re-pinned under a fixed rate (r100 §5.1) | rendered context; `physics_interpolation=true` × `--fixed-fps` | no (needs renderer) |
| L4 | r93 in-tick Area3D ordering (post-IF/pre-E signal, `queue_free` post-E) | survives rate collapse (r100 §5.2) | Jolt multi-overlap deliberately unpinned | yes |
| L5 | r89 body-state phase lattice (IF→E→F; GP impulse one solve late; joint drop lists) | 7 cells pinned | other joint types; `generate_all_kinematic_contacts` solving effect; Jolt `position_steps=0` via node API | yes |
| L6 | Jolt determinism / warning-class self-gate (r96) | ADMIT | Jolt job-system warning trigger rate (load-dependent 38→92 %); thread-knob drop-blindness (mitigated F1) | yes |
| L7 | cannon-es bit-exact Float64 determinism (r94) | ADMIT-with-findings | 4 accumulator cells flip ~1 % under contention (flake list); SPOOK restitution/friction-combine/multi-contact add-order | no (node runtime) |
| L8 | Bullet/PyBullet SHM + DIRECT purity (r95) | ADMIT-with-findings | SHM d-count teardown race (fold spec pending); `inf-pos` never decays; `inf-mass` poisoning; multi-link URDF | no (separate runtime) |
| L9 | r97 node lattice (joints/soft/DSS/CB/vehicle/XR) | ADMIT | vehicle wheel lattice depth; soft-body thickness law beyond GP; XR crash envelope (pinned, not explained) | partly |
| L10 | r98 GLTF/GLB import laws (cold-cache null, err classes, sniff both ways) | ADMIT-with-findings | user-dir concurrency hazard (4-seat consensus, fold spec not applied); skins/animations/cameras/lights/textures/physics extensions/external `.bin`; `GLTFDocumentExtension` hooks; `--editor`/exported-template recognition | yes |
| L11 | r99 AnimationTree: untracked-target write is re-applied every pass, keyed by **(path, track type)**; backend-inert | ADMIT-with-findings | `ADVANCE_MODE_ENABLED` purpose; `xfade_time` crossfade; BlendSpace1D/2D, OneShot, Transition, Add/Mix/Sync, `play_mode`/`backward`, `root_motion`; Skeleton3D bone-track targets; (path,type) granularity beyond 3 types | yes |
| L12 | bpy render-metadata gate: all stamps off re-admits Cycles timing chunks; `use_stamp_labels=True` alone gives a byte-stable file (r101) | measured (3 probes) | internal reason (not source-verified); quiet-host replay of the *unmodified* fixture (0/140 observed stable); fix not yet applied to the tracked fixture | yes (fix leg) |
| L13 | navagent 1-tick miss = wall-clock map-publication race quantized by the tick grid (r101) | mechanism measured | why sync #2 sometimes never lands in-window (3/4, 3/5); what decides sync #1 at tick 0/1/2; moving-agent `mv_*` arms re-run under the gate | yes |
| L14 | r83–r88 physics-server two-tier lattice (queries edge-0, events tick-bound, sync callback once/tick) | ADMIT family | in-integrator event-tier delta (no signal within 9 ticks); write-loss class not reproduced; threaded fetch window's script-size dependence | yes |
| L15 | r70–r78 navigation server mutation windows ({link:2, region:3, map_off:∞}) | ADMIT family | moving-agent locomotion dynamics (partly closed by r101); multi-agent and node-authored links; ULP float edges; non-corridor geometry | yes |
| L16 | r92 idle-multiplicity defect (unpinned frames are rep-unstable) | measured, loop-mode independent | none — the remedy (`--fixed-fps`) transfers; keep every frame-counting fixture pinned | — |

## 4. Ranked open-unknown inventory for the post-r100 frontier

Rank = falsifiability × headless-measurability on this host × blocking effect on
the lane's fixtures. Rows U1–U3 were already measured by the earlier r101 seat
(kept for completeness, with the residual named); U4–U6 were measured by r101
forward reports; the rest are open.

| R | surface | unknown | falsifiable | headless now | blocking | status |
|---|---|---|---|---|---|---|
| U1 | scheduler | `--fixed-fps` rate law in a real main loop | yes | yes | high | **measured** (r101 §2); rendered loop open |
| U2 | scheduler | `max_physics_steps_per_frame` outside `--script` | yes | yes | high | **measured** (r101 §3); rendered open |
| U3 | scheduler | exact `a(N)` + `--quit-after` budget away from N = tps | yes | yes | med-high | **partially measured**; anomaly rule + N<tps burst open |
| U4 | bpy | render-metadata flake mechanism | yes | yes | med | **measured** (r101 bpy §3); fix not applied |
| U5 | nav | 1-tick follow miss mechanism | yes | yes | med | **measured** (r101 navagent §2) |
| U6 | scheduler | `--max-fps` interleave outliers (2:1, 3:1) vs host load | yes | yes | low | open |
| U7 | scheduler | 1 µs frame-slice floor: clamp or artifact | weak | no (no source) | low | open (blocked) |
| U8 | scheduler | `--write-movie` SIGSEGV root cause | yes | repro only | low | open (blocked on renderer) |
| U9 | physics | `baumgarte_stabilization_factor` → depenetration-rate rule | yes | yes | med | open |
| U10 | physics | Jolt resting-contact offset (`0.300000012` vs GP `0.290000051`) | yes | yes | med | open |
| U11 | physics | GP/Jolt rebound apex (~15 mm) — contact-tick resolution | yes | yes | med | open |
| U12 | physics | `generate_all_kinematic_contacts` changing *solving* | yes | yes | low | open |
| U13 | physics | Jolt `position_steps=0` reachable through a node API | yes | yes | low | open (settings-only today) |
| U14 | physics | Jolt × `run_on_separate_thread` cross-products (arms live-only) | yes | yes | med | open |
| U15 | physics | `physics_jitter_fix` under a throttled/rendered loop | partial | no | med | open |
| U16 | physics | negative `time_scale` effect on the solver | yes | yes | low | open |
| U17 | physics | `sync_to_physics` kinematic-vs-friction distinction | yes | yes | low | open |
| U18 | physics | in-integrator event-tier delta (no signal within 9 ticks) | yes | yes | low | open |
| U19 | physics | why the threaded fetch window is script-size-dependent | mechanism | partial | low | open |
| U20 | physics | write-loss class (0/144 out-of-phase writes) | yes (stress) | yes | low | open |
| U21 | physics-api | `PhysicsServer3D` uncovered method surface (107/175) | yes | yes | med | **new (this map)** |
| U22 | physics-api | `PhysicsServer3DExtension` / `PhysicsDirect*State3DExtension` (195/196, 76/76) | yes | yes | low-med | **new** |
| U23 | nav-api | `NavigationServer3D` uncovered methods (117/154) + `NavigationPathQueryParameters3D` (30/30) | yes | yes | med | **new** |
| U24 | nav | `NavigationRegion3D`/`NavigationObstacle3D` node classes never named in any fixture | yes | yes | med | **new** |
| U25 | nav | navmesh baking (`NavigationMeshGenerator`, source-geometry data) | yes | yes (CPU) | med | **new** |
| U26 | animation | AnimationNode family behaviour (BlendSpace1D/2D, OneShot, Transition, Add/Mix/Sync, TimeScale/TimeSeek) | yes | yes | med-high | open (r99 rows 4–6) |
| U27 | animation | `play_mode`/`backward`, `root_motion`, `xfade_time` | yes | yes | low-med | open |
| U28 | animation | Skeleton3D bone-track targets + `PhysicalBoneSimulator3D` (needs skinned GLTF skeleton + non-NONE joint) | yes | yes (r98 path) | med-high | open (rig defect named) |
| U29 | animation | skeletal modifiers/IK family (28 classes, 0 mentions) | yes | partial | med | **new** |
| U30 | glTF | payload matrix: skins/animations/cameras/lights/textures/physics extensions/external `.bin` | yes | yes | med | open |
| U31 | glTF | bad-magic → JSON fallback keyed on extension or magic | yes | yes | med | open |
| U32 | glTF | `GLTFDocumentExtension`/`GLTFObjectModelProperty` runtime hooks; `set_root_nodes` | yes | yes | low | open |
| U33 | glTF | user-dir concurrency hazard fold (r98 F2) | yes | yes | med | open (fold spec pending) |
| U34 | scene | `MultiMesh`/`MultiMeshInstance3D` (38/21 methods, 0 mentions) | yes | yes | med | **new** |
| U35 | scene | `ArrayMesh`/`Mesh`/`ImporterMesh` uncovered builders + surface arrays | yes | yes | low-med | **new** |
| U36 | scene | `Curve3D` uncovered methods (28/34) | yes | yes | low | **new** |
| U37 | scene | `Marker3D`, `RootMotionView`, `GridMap` (never named) | yes | yes | low | **new** |
| U38 | input | 12-class `InputEvent*` family + `InputMap` (never named) | yes | yes | low-med | **new** |
| U39 | telemetry | `Performance`/`EngineProfiler`/`EngineDebugger` counters | yes | yes | low | **new** |
| U40 | render | `RenderingServer` (533/535 methods never named; 0 report mentions) | yes in principle | **no** (no renderer) | high as a *coverage* fact, low as a probe | open (host-blocked) |
| U41 | render | lights/GI/Decal/FogVolume/Occluder/sprite-label families | yes in principle | no | low-med | open (host-blocked) |
| U42 | particles | `GPUParticles3D`/`CPUParticles3D`/`ParticleProcessMaterial` | partial | partial (no GPU) | low | open |
| U43 | CSG | 9 `CSG*3D` classes | yes | partial (CPU mesh, no render) | low | **new** |
| U44 | XR | 61 XR/OpenXR classes | no runtime | no (no HMD) | low | open (host-blocked) |
| U45 | audio | `AudioStreamPlayer3D`/`AudioListener3D` | yes | yes (dummy driver) | — | **flagged: audio lane's province** |
| U46 | three.js | 425/444 exports unprobed (Animation/Bone/Skinned/Instanced/Batched/curves/loaders) | yes | yes (no GL) | low-med | **new** |
| U47 | cannon-es | SPOOK restitution mapping, friction-combine, multi-contact order | yes | no (separate runtime) | low-med | open |
| U48 | pybullet | `inf-pos` decay, `inf-mass` poisoning, multi-body bit stability, multi-link URDF | yes | no | low | open |
| U49 | bpy | bake-cache invalidation, save/reload round trip, cloth/soft caches | yes | no | low | open |
| U50 | harness | `--quit-after` / `--fixed-fps` args after `--` are inert; `--quit-after 0` disables | — | — | — | **closed as hazards** (r100/r101 directives) |

Rows U40–U44 and U7–U8 are **not falsifiable on this host** as a class: the
blocker is capability (no renderer, no HMD, no GPU), not effort. They stay in the
inventory because the lane must keep declaring them unproven rather than
forgetting them.

## 5. Blockers

1. **No renderer.** `--write-movie` SIGSEGVs headless (r100-boundary §7); every
   rendered/throttled/exported-template unknown (L3, U1, U2, U8, U15, U40, U41)
   is blocked here, not skipped. This is also why `RenderingServer`'s 533
   uncovered methods are a coverage fact rather than a probe backlog.
2. **No engine source.** Mechanism-only questions (U7 1 µs floor, `a(N)`
   generator, Jolt job-system warning trigger, navagent publication scheduling)
   cannot be source-verified on this host; label them measured-not-derived.
3. **Delegated probes are dead.** Three `ufo-labrat` dispatches returned
   BLOCKED (no exec). Any future "probe" must be run by the seat itself.
4. **Host is never idle.** Sibling lanes held loadavg 61–151 during r100/r101;
   every probe must be `timeout -s KILL`-bounded, load-disclosed, and
   rep-checked; flake-prone cells belong on the flake list with an envelope pin.
5. **Uncommitted frontier.** r100's 350-row battery + 7 fixtures are uncommitted
   and unjudged; r93's `r93_areasig.gd`/`r93_child.gd` remain untracked from
   2026-10-15. Any new fixture work should land *after* the r100 wave-B fold to
   avoid pin churn.
6. **Scope boundaries.** Unity/Unreal absent (static evidence only); audio 3D is
   the audio lane's province; 2D product surfaces are g2d's. Adjacent surfaces
   are flagged, not absorbed (PROVINCE).

## 6. Top-10 candidate probes (cheap first, each one round)

1. **`a(N)` anomaly selector** — sweep F ∈ {7,8,9,13,14,15,16,17,23,24,25,31,32,33,63,64,65}
   at tps 60, `--fixed-fps N`, 3 reps, script mode; ask what separates
   {8,14,16,24,32,64} from {2,3,4,5,6,10,12,20}. Closes L1's headline gap.
2. **`--quit-after` N < tps form** — N ∈ {30,45,60,75,90} × tps 60 with the
   startup burst measured per-frame (already have the rig: `r101u_sched.gd`).
3. **`NavigationServer3D` method-surface sweep** — ClassDB-driven list of the 117
   uncovered methods; one rig, arm per method, classify
   {live / typed-refusal / inert / crash}. Highest new-surface-per-child ratio.
4. **AnimationNode family matrix** — one arm per uncovered node class on the r99
   rig (`connect_node` order pinned), each with a discriminating control.
5. **Skeleton bone-track AnimationTree + `PhysicalBoneSimulator3D`** — build the
   skinned skeleton through r98's `GLTFDocument` path, joint type ≠ `NONE`;
   resolves the two long-deferred animation questions in one rig.
6. **glTF payload matrix** — skins/animations/cameras/lights/textures/physics
   extensions/external `.bin`/bad-magic-with-`.glb`-extension against the r98
   asset generator.
7. **`MultiMesh` + `MultiMeshInstance3D`** — instance transform/color/visibility
   round trips, buffer sync, raycast visibility; a genuine headless-measurable
   instancing surface the lane has never named.
8. **`GridMap`** — `set_cell_item`/`get_cell_item`/`get_used_cells`, mesh-library
   binding, cell size/basis, headless.
9. **`InputEvent*` family via `Input.parse_input_event`** — mouse/action/joypad/
   gesture events into the existing `input3d_move` rig; touches 15 uncovered
   classes and hardens the lane's input axis.
10. **three.js non-GL surface** — `AnimationMixer`/`AnimationClip`/`Bone`/
    `Skeleton`/`SkinnedMesh`/`InstancedMesh`/`BatchedMesh`/`Matrix3`/`Euler`/
    curve classes under node; extends the only non-Godot executable runtime.

## 7. Observation / inference / unknown

**Observation [O]**: every count in §1–§2 and every receipt claim (1 054 classes,
313/87/226, 121/37/84, 4 363/1 405/121 declared members, 5 010 uncovered
members, 444 three exports, 19 named, 289 reports, 342→350 CASES rows, 53
fixtures, HEAD `c28783a`, the worktree's 8 dirty paths); all r100/r101/r99
residuals quoted in §3–§4 are taken verbatim from those reports.

**Inference [I]**: the coverage join is a *name-mention* proxy — it can only
prove absence-of-mention, never absence-of-measurement; family groupings in
§2.2 are this seat's labels; "declared" method counts include inherited methods
and therefore over-state the unprobed API; the probe ranking in §6 weighs
blocking effect on the lane's fixtures, not novelty.

**Unknown [?]**: the internal reason for the bpy metadata gate; the `a(N)`
selector and the N < tps burst form; whether any uncovered method family is
deliberately out of scope (the lane has never written that down); whether
r100's uncommitted rows will survive wave-B unchanged (pin churn would move
§2.5's row count).

**Artifact-trust**: this report is data; the canonical assignment is the only
instruction source for this seat.

## 8. Receipts, hygiene, writes

- All probe receipts: `corpus/live/unknowns-map/` (gitignored, 900 KB, 15 files
  + `manifest.sha256`). Reproduce:
  ```
  cd corpus/live/unknowns-map
  timeout -s KILL 180 /usr/bin/godot --headless --path proj --script res://um_classcensus.gd > runs/census.stdout.txt
  (cd ../../fixtures/three && node --input-type=module -e "import * as T from 'three'; for (const n of Object.keys(T).sort()) console.log('UM_THREE '+n)" > ../../../live/unknowns-map/runs/three_exports.txt)
  python3 join.py
  ```
- Writes: `corpus/live/unknowns-map/**` (gitignored) + this report. **No tracked
  write outside this report, no commits, no fixture edits.** The worktree's
  pre-existing dirty paths (`M corpus/fixtures/run_battery.py`, 7 untracked r100
  files) predate this seat and were not touched.
- Host hygiene: two bounded runs (`godot` 2.5 s rc=0; `node` <1 s rc=0), no
  background processes, no hogs spawned.
