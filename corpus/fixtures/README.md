# game-dev-3d — headless 3D fixture battery

Bounded, deterministic Godot 4.7.2 `--headless` fixtures for six 3D mechanic
classes. Each class is one positive causal case plus one discriminating
negative control that runs the *same* assertion machinery against a different
arrangement, so an absent effect is attributable to the arrangement and never to
a broken setup.

Everything in this directory is a **seed** and is treated read-only at run time.
`run_battery.py` copies the directory into `corpus/live/runs/<ts>/scratch` and
executes only the copy; it records a SHA-256 map of the seeds before and after
and fails the battery if any seed changed. Nothing here writes into the seeds,
and Godot's `.godot/` import cache is created inside the scratch copy only.

## Running

```
python3 corpus/fixtures/run_battery.py                     # all 19 cases (round 14)
python3 corpus/fixtures/run_battery.py --probe-failing     # + one adversarial mutation
python3 corpus/fixtures/run_battery.py --only raycast3d_hit,raycast3d_miss
python3 run_battery.py --godot /path/to/godot --runs /path/to/receipts
```

The battery prints a per-case PASS/FAIL table plus totals and exits 0 only when
every case passes. Receipts land in `corpus/live/runs/<ts>/`: `verdicts.json`
(per-case command, exit codes, exact marker, full stdout/stderr, rejection
reasons, seed digests), `battery-output.txt`, and with `--probe-failing` also
`mutation-verdicts.json`. That tree is disposable; the seeds are not.

Single fixtures can be reproduced directly against a scratch copy:

```
godot --headless --path <scratch> --script res://<fixture>.gd [-- <flag>]
```

Each fixture's header comment carries its own exact commands and expected exit
signature.

## Exit contract

| situation | exit | stdout | battery verdict |
|---|---|---|---|
| positive holds | 0 | one exact `PASS <case> ...` line | PASS |
| negative control rejects as intended | 2 | one exact `NEGATIVE REJECTED: <case> <reason>` line | PASS |
| setup/script error, bound breach, assertion that is not the intended negative | 1 | no marker, one `ERROR: <fixture>: ...` line | FAIL |
| crash, timeout, missing marker, `SCRIPT ERROR:`, `Parse Error:`, any unexpected `ERROR:` line, ObjectDB leak warning | any | — | FAIL |

Exit 2 is a *passing* negative control, not a failure: it means the fixture
proved the effect absent under an arrangement that is otherwise identical. The
battery requires the exact marker line on stdout — never the exit code alone —
and classifies stdout and stderr separately.

## Cases

| case | fixture | flag | exit | mechanic |
|---|---|---|---|---|
| `floor3d_ground` | `floor3d_ground.gd` | — | 0 | Downward CharacterBody3D stops on live floor at hand-derived center y=1, first contact tick 30, normal +Y and `is_on_floor=true` |
| `floor3d_airborne` | `floor3d_ground.gd` | `--lower-floor` | 2 | Same live box lowered to y=-20; actor travels 60 ticks to y=-2 with no contact or floor state |
| `body3d_contact` | `body3d_slide.gd` | — | 0 | `CharacterBody3D.move_and_slide()` stops at the hand-derived contact plane `z=2.5` (box half-depth 2.0 + body half-depth 0.5) on tick 21 with normal `+Z` |
| `body3d_contact_far` | `body3d_slide.gd` | `--far-body` | 2 | same assertions, body starts at `z=40`; zero contacts, travels the authored 10.0, wall proven intact |
| `area3d_chain` | `area3d_chain.gd` | — | 0 | `Area3D.body_entered` → domain `collected` chain fires exactly once with payload `Runner3D`/layer 2 at or past the derived entry threshold `x=4.0` |
| `area3d_chain_no_overlap` | `area3d_chain.gd` | `--no-overlap` | 2 | pickup relocated to `x=40`; zero signals while `monitoring`, mask/layer match and runner travel are proven live |
| `camera3d_project` | `camera3d_project.gd` | — | 0 | `unproject_position(2,1,-4)` → `(550,225)` on an authored 800×600 `SubViewport`, fov 90, `KEEP_HEIGHT`; `f_x=0.75`, `f_y=1.0`; centre and mirror controls |
| `camera3d_project_behind` | `camera3d_project.gd` | `--behind-camera` | 2 | behind-camera point `(2,1,4)` rejected by `is_position_behind`/frustum gate; its raw projection aliases the legitimate mirror pixel `(250,375)`; lateral off-frustum point projects to `x=3400`, outside the viewport rect |
| `camera3d_depth` | `camera3d_depth.gd` | — | 0 | translated/rotated Camera3D at (10,0,0) looking +X projects local (2,1,-4) to (550,225), world (14,1,2), depth 4 inside authored near 1/far 10 |
| `camera3d_depth_far` | `camera3d_depth.gd` | `--far-point` | 2 | farther local (6,3,-12) projects to identical pixel but is beyond far 10; near control remains visible, so frustum rejection is depth-driven |
| `camera3d_depth_near` | `camera3d_depth.gd` | `--near-point` | 2 | geometrically front-facing local (0.25,0.125,-0.5) at depth 0.5 < near 1 projects to (550,225), outside near plane; Godot `is_position_behind=true` here despite positive forward depth, depth-2 control remains visible |
| `navigation3d_path` | `navigation3d_path.gd` | — | 0 | active NavigationServer3D map with one 4×4 hand-authored planar region returns exact two-point path (1,0,1)→(3,0,3) after server synchronization |
| `navigation3d_path_disconnected` | `navigation3d_path.gd` | `--disconnected` | 2 | second map/region independently routes (21,0,1)→(23,0,3); source map query to that remote destination clamps endpoint at (4,0,3), not target, proving disconnection despite live source and target |
| `raycast3d_hit` | `raycast3d.gd` | — | 0 | `PhysicsDirectSpaceState3D.intersect_ray` hits `(0,2,0)` with normal `(0,1,0)` on the authored collider; offset ray returns an empty Dictionary |
| `raycast3d_miss` | `raycast3d.gd` | `--miss-ray` | 2 | hitting control ray proves the space is live, then the `z=9` offset ray (7.0 clear of the box half-depth) returns zero hits |
| `transform3d_compose` | `transform3d_compose.gd` | — | 0 | parent `R_y(90)` at `(2,0,0)` ∘ child `R_x(90)` at `(0,0,-3)` → global origin `(-1,0,0)`, basis columns `(0,0,-1) (1,0,0) (0,-1,0)`, determinant 1, composition identity holds, reversed order rejected |
| `transform3d_compose_wrong_order` | `transform3d_compose.gd` | `--wrong-order` | 2 | correct-order expectation still matches, and the reversed hypothesis (`R_x·R_y`, summed translations → `(2,0,-3)`) is rejected by exact assertion |
| `input3d_move` | `input3d_move.gd` | — | 0 | synthetic `InputEventKey` W press → `1.000` on +X over exactly 10 physics ticks (`6.0 × 10 / 60`), zero on Y/Z, and motion stops after the matching release |
| `input3d_move_no_event` | `input3d_move.gd` | `--no-input` | 2 | no event injected → zero displacement over the same 10 live ticks, then a late control press moves the same body `0.500`, proving the zero was caused by the absent event |

Supporting scripts are not cases and carry no exit signature: `runner3d.gd`
(deterministic-drive `CharacterBody3D` actor), `input_mover3d.gd` (key-intent
actor), `pickup_orb3d.gd` (`Area3D` trigger with the `collected` chain).

## Optional identified-descendant timeout (round 5)

`python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout`
adds one uncounted real Godot Node3D pair using `timeout_tree3d.gd`. Clean
exit 0 passes. The hold-open arm spawns `timeout_descendant.py` and writes
a PID/PGID witness file only in scratch, then prints the same marker. At 3s
its logical result is `actual_exit=null`, independent of cleanup exit -9.
The runner confirms the `/proc` identity and start time of the one detached
witness, kills/reaps Godot and sends SIGTERM to that verified witness *before*
waiting for pipe EOF. It checks the witness is no longer live within 3s.
Godot 4.7.2's `OS.create_process` detached the witness into its own process
group, so this is **not** arbitrary process-tree cleanup, nor portable beyond
Linux `/proc`. A wrong identity, missing marker, cleanup timeout or live
witness fails the probe. Raw paired state is in ignored
`corpus/live/runs/<timestamp>/tree-timeout-verdicts.json`; rerun for evidence.

## Optional stdout/stderr attribution (round 4)

`python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-stream-attribution`
adds an uncounted pair using the same `stream_attribution3d.gd` script. Both
set up a Node3D, exit 0 and print exactly `STREAM_3D_STDOUT: spatial node ready`
on stdout. Only `--emit-stderr` also prints `STREAM_3D_STDERR` on stderr;
`classify` rejects any nonempty stderr line. The raw paired streams, exit,
reasons and verdict are recorded in ignored `corpus/live/runs/<timestamp>/stream-attribution-verdicts.json`;
rerun the command. Default twelve cases remain unchanged.

## Optional direct-child signal classification (round 3)

`python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-crash-exit`
adds a **separate, uncounted** pair using `crash_exit3d.gd`. Both arms set up
a Node3D and print the exact `CRASH_EXIT_3D: spatial node ready` line. The
normal arm `quit(1)` passes the existing classifier when expecting exit 1;
the `--hold-open` arm remains live after printing, receives parent SIGTERM,
and must return -15 and be rejected by the same classifier despite the
marker. The paired streams, liveness, exit, and cleanup are in ignored
`corpus/live/runs/<timestamp>/crash-exit-verdicts.json`; rerun the command
for evidence. Eight seconds bounds marker observation; three seconds bounds
cleanup before forced kill. This is not a spontaneous crash or process-tree
guarantee. The twelve default cases are unchanged.

## Slope floor-angle classification (round 15)

`python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only slope3d_floor,slope3d_steep`
executes `slope3d_angle.gd` in grounded mode. One intact box slab is tilted
30° or 60° around Z; `floor_max_angle=45°`, up direction +Y. Drive is pinned
vertically downward until contact (at most 30 physics ticks). The contact
normal is checked against the hand-derived rotated +Y vector: (-0.5, 0.866, 0)
versus (-0.866, 0.5, 0). A shallow contact must be classified floor, while a
steep contact must be classified wall, never an absent-geometry surrogate.
This checks angle classification, not gravity, downhill travel or friction.
The marker fields are formatted from observed contact normal, floor-angle
readback and floor/wall flags after exact-setting checks; a 45°→35° source
change must fail rather than printing an unobserved 45° label. Contact normal
is stored on first contact, not re-read in the same frame as the flags.

## PackedScene instance-local transforms (round 17)

`python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only scene3d_instances,scene3d_instances_wrong_local`
packs a reusable Node3D with an owned MeshInstance3D/BoxMesh child at local
(1,2,-3), instantiates twice, and checks world (11,2,-3) versus (-9,2,2)
after parents at (10,0,0) and (-10,0,5). The negative changes only the second
child's local X to 2, checking its world (-8,2,2) while the first and source
stay intact; both instances and source are freed before exit. This is live
headless scene instancing and transform isolation, not persisted scene-file
serialization or rendered pixels.

## Authored text-scene round-trip (round 18)

`python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only scene3d_disk,scene3d_disk_wrong_local`
packs an owned Node3D/MeshInstance3D subtree and saves it as a scratch
`generated-scene3d.tscn`, then loads/instances the file and checks the local
(1,2,-3) and world (11,2,2) child transform against literal expectations.
The negative changes only the serialized X translation from 1 to 2 after
save. The resulting text scene must still load with its mesh and source
untouched, but the observed world (12,2,2) differs. No seed project or
persisted artifact outside ignored run scratch is modified; this proves a
headless Godot serialization/load path, not visual output or arbitrary scene
file validation.

## PackedScene mesh resource locality (round 20)

`python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only scene3d_resource_local,scene3d_resource_shared`
packs one Node3D/MeshInstance3D/BoxMesh scene and instantiates two clones.
With `resource_local_to_scene=true`, actual mesh object identities differ and
changing first mesh size X from 1 to 2 leaves second/source X=1. With the
same flag false, both clones and source share the same mesh and the size
mutation reaches both second and source (X=2). Both arms assert literal initial
and post-mutation dimensions and
free the nodes before exit. This is mutable scene-resource behavior, not GPU
rendering, material identity, disk scene persistence or other engines.

## Saved-scene BoxMesh resource locality (round 21)

`python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only scene3d_resource_disk_local,scene3d_resource_disk_shared`
saves an owned BoxMesh scene as scratch `generated-resource3d.tscn`, loads it
with cache ignored, and instantiates three copies. With scene-local true, the
saved file contains `resource_local_to_scene = true`; first/second/loaded
reference distinct meshes, first size X2 after mutation and others X1. With
flag false, Godot omits the default false field from `.tscn`; three loaded
instances share the resource and all sizes move X1→X2. The fixture checks
actual mesh identities, sizes and flag readback. This is one file and Godot
build, not arbitrary saved-scene compatibility or GPU rendering.

## Orthographic Camera3D depth-invariant pixels (round 23)

`python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only camera3d_ortho,camera3d_ortho_outside`
uses a headless 800×600 SubViewport and `Camera3D.PROJECTION_ORTHOGONAL`,
vertical size 8, near 1, far 10. The authored pixel scale is 600/8=75 per
world unit: world (2,1,-4) and (2,1,-8) both project to (550,225) while
both remain in frustum. Lateral (6,1,-4) projects to (850,225), beyond the
viewport and outside frustum, with both valid depth controls retained. Mode,
size and planes are read back before claims. This is projection/frustum math,
not a rendered image or GPU culling proof.

## Orthographic near-plane gate (round 24)

`python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only camera3d_ortho,camera3d_ortho_outside,camera3d_ortho_near`
adds a near-negative (2,1,-0.5) to the r23 orthographic scene. Its geometric
camera-forward depth is +0.5 (in front of the origin, but less than near=1),
and numerical projection still equals the two valid depths' (550,225).
Godot 4.7.2 reports `is_position_in_frustum=false` **and**
`is_position_behind=true` for this point; the API's “behind” is not a claim
that its geometric forward depth is negative. Existing depth4/depth8 controls
remain in-frustum; no near-boundary precision or rendered pixels proven.

## Orthographic far-plane gate (round 25)

`python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only camera3d_ortho,camera3d_ortho_outside,camera3d_ortho_near,camera3d_ortho_far`
adds a far-negative world (2,1,-12) to the same r23/r24 orthographic setup:
forward depth12 exceeds far10 but projected screen stays (550,225), matching
in-frustum depth4/8. Godot 4.7.2 returns `is_position_in_frustum=false` and
`is_position_behind=false` at this far point, different from r24's positive-
forward pre-near API-behind=true. These are sampled API classifications, not
exact near/far boundary precision, rendered pixels or GPU culling.

## Gravity-driven vertical jump versus displaced floor (round 26)

`python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only jump3d_land,jump3d_no_floor`
starts a one-unit CharacterBody3D at y=1 touching a one-unit floor centered y=0 (top y=0.5),
sets one +6 vertical impulse, subtracts 12/60 from vertical velocity and calls
`move_and_slide` once after each physics-frame signal for 60 explicit calls.
Ideal free-motion displacement is sum(6−0.2n)/60 for n=1..60; apex at
call29, about y=2.45, and floor contact on this Godot build observed at call60
with resting center about y=1.001 (safe margin), not guessed ideal landing59.
The intact floor moved to y=-20 remains unreachable: apex matches early regime,
final free y≈0.9, no grounded/landing state. Initial y=1 is geometric contact,
not an independently sampled initial `is_on_floor()` state. This tests one
explicit integration loop, not a generalized gravity/jump controller or
rendered motion.

## Sampled pre-impulse floor state (round 27)

The r26 `jump3d_land,jump3d_no_floor` pair now calls `move_and_slide()` once
with a tiny downward velocity -0.01 after geometry setup and **before** the
+6 impulse. It checks `is_on_floor=true` for the y0 floor and false for the
same floor relocated y-20, and checks center y remains ≈1. The same 60
subsequent impulse/gravity calls still produce apex tick29 and landing tick60
or free final y≈0.9. Exact markers include `initially_grounded=`. This is a
sampled precondition, not proof of grounded state before the probing move.

## Downhill travel with explicit floor-stop policy (round 28)

`python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only slope3d_travel,slope3d_travel_level`
uses a wide static 30° box slope or intact level box, a unit CharacterBody3D
and 60 explicit frame-paced downward-gravity `move_and_slide` calls. **The
nondefault `floor_stop_on_slope=false` is required** on this Godot build:
with default true, feasibility run stayed at x=0 despite contact. With false,
slope x≈-0.081 after 60 calls, on floor at final check and grounded for 52
calls; level x≈0, grounded 44 calls. Literal tolerances check signed X,
center y, contact normal, rotation and policy. These observed small motions do
not prove a general slope acceleration/friction law or all-tick grounding.

## Slope assertion attribution (round 29)

The r28 slope assertions now fail with separate diagnostics for rotation,
horizontal displacement, vertical/grounded state and first floor normal.
Private copied angle 30→40 plus rotation-literal 30→40 keeps the setup guard
satisfied yet exits 1 on observed X=-0.1347 versus original X=-0.0810.
A second private copy adjusts only the X/Y/grounded expectations to the
mutant's observed values, leaving the original normal literal untouched; it
exits 1 on normal(-0.642788,0.766044,0) versus authored
(-0.5,0.8660254,0). These scratch controls attribute the failure to separate
behavior predicates, not a general slope-sensitivity guarantee.

## Explicit sampled 3D animation evaluation (round 30)

`python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only animation3d_keys,animation3d_keys_still`
instantiates a live `Node3D` target and `AnimationPlayer` with one linear
`TYPE_POSITION_3D` track. `play`, then `seek(0.5,true)` and `seek(1.0,true)`
sample target positions X=2/X=4 from keys X=0→4; an intact constant-key
track yields X=0/X=0. Checks examine track binding/library and live actor
positions before fixed markers. Explicit seeks evaluate samples; this does
not prove timed playback, animation blending, rendering or sprites.

## Physics-frame 3D animation playback (round 31)

`python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only animation3d_playback,animation3d_playback_still`
starts a two-second `AnimationPlayer` position track in physics callback mode
and calls `play` once. After 30 and 60 awaited physics frames, without `seek`
or direct target position assignment, the live actor is at X≈0.967 and
X≈1.967, while the intact constant-key track stays at X=0. The player's
observed times are 29/60 and 59/60 seconds because the first awaited frame
does not advance the newly started animation on this build. The fixture
asserts times, `is_playing`, binding and positions before fixed markers. This
is headless frame-advanced playback, not rendered animation or a portable
frame-order guarantee.

## Two-animation 3D position cross-fade (round 32)

`python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only animation3d_blend,animation3d_blend_cut`
uses two live constant-key `AnimationPlayer` tracks (X0 and X4) on the same
`Node3D`. After four warmup physics frames of `from`, `play("to", 0.5)`
transitions to `to`; 15 awaited frames later X≈1.931 is strictly between
0 and 4, and another 30 frames yield X=4. The same tracks with zero-second
transition (`--cut`) yield X4 at both checks. Assertions sample live
positions and track binding before fixed markers. This observes one
engine-specific cross-fade schedule, not a universal blend curve or pixels.

## Procedural ArrayMesh triangle (round 33)

`python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only mesh3d_array,mesh3d_array_shifted`
constructs a live `ArrayMesh` triangle with vertices (0,0,0), (2,0,0),
(0,3,0) and attaches it to `MeshInstance3D`. Godot returns an AABB of size
(2,3,0.00001) for the planar surface: the tiny Z thickness is observed
engine behavior, not the authored geometric Z extent. The paired intact
triangle moves its third vertex to Z1, giving AABB size (2,3,1). Both cases
check the surface data readback and instance bounds before fixed markers.
This verifies CPU-visible mesh API data, not pixels, GPU buffers, winding
visibility or collision meshes.

## Indexed ArrayMesh topology readback (round 34)

`python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only mesh3d_indexed,mesh3d_indexed_reversed`
constructs one four-vertex, two-triangle indexed XY quad. The forward
index array [0,1,2,0,2,3] returns cross-product Z+6 for both triangles;
paired reversed [0,2,1,0,3,2] returns Z-6 while vertices and AABB remain
identical. CPU-side checks read indices and vertices back from Godot's
`ArrayMesh`, compute cross products from those returned arrays, and compare
mesh/instance bounds. This does not establish GPU winding, culling, pixels,
vertex-normal generation, or collision geometry.

## Mesh-derived static physics collision (round 35)

`python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only mesh3d_trimesh_hit,mesh3d_trimesh_outside`
builds a triangle `ArrayMesh`, converts it via `create_trimesh_shape()`, and
attaches the generated `ConcavePolygonShape3D` to a live `StaticBody3D`.
`backface_collision=true` on that shape and `hit_back_faces=true` on both
queries are explicit: initial default-shape experiments missed the triangle
although its face array was populated. After four physics ticks, the
interior ray at (0.5,0.5) hits (0.5,0.5,0), +Z normal, collider identity and
face index **0**; lateral x3 ray is empty. Both cases run the interior hit
first, so the negative arm's miss is not attributable to a dead world.
This tests one two-sided generated concave collider/raycast, not default
backface semantics, moving body contacts, mesh rendering or GPU behavior.

## Two-face mesh-derived static collision (round 36)

`python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only mesh3d_faces_hit,mesh3d_faces_reordered`
converts an indexed four-vertex/two-triangle XY quad into one generated
`ConcavePolygonShape3D` on a live static collider with explicit two-sided
policy. After four physics ticks, separate interior rays at (1.5,0.5) and
(0.5,1.5) hit the same collider with face indices 0/1; swapping the two
triangle index triples reverses the returned face indices 1/0 while the
hit points and +Z normals remain the same. A third x3 ray misses. The
fixture checks actual physics-space dictionaries; it does not imply stable
face ordering across engine builds, GPU winding, or rendered pixels.

## Headless Skeleton3D rest and pose data (round 38)

`python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only skeleton3d_pose,skeleton3d_rest_only`
builds a live two-bone `Skeleton3D`: Root local rest(1,0,0), child Tip local
rest(0,2,0), with measured child global **rest** origin(1,2,0). Setting
Tip local pose position(0,3,0) reports pose/global-pose origin(0,3,0);
the intact rest-only arm reports zero pose while retaining the same rest.
The `get_bone_global_pose` readback here is pose hierarchy data, **not** a
world/rest-combined child position. Assertions check hierarchy, separate
rest and pose readbacks before fixed markers. This headless API evidence
does not establish skinning, deformed vertices, pixels or GPU behavior.

## Child pose composition under parent rotation (round 39)

`python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only skeleton3d_rotation,skeleton3d_unrotated`
sets a live two-bone `Skeleton3D` Root pose to +90° about Z with Tip local
pose origin(0,3,0). Tip global **pose** then reads origin(-3,0,0), basis
X(0,1,0)/Y(-1,0,0). With an intact identity Root pose, Tip global pose
stays (0,3,0) with identity basis. Both retain the same child global
**rest** origin(1,2,0). Quaternion tolerance 0.001 rad accounts for
Godot float readback; composed origin/basis tolerances remain 0.0001.
This pose hierarchy data is not a skinned vertex or rendered movement.

## Live BoneAttachment3D follower (round 40)

`python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only skeleton3d_attachment,skeleton3d_attachment_unrotated`
attaches a `BoneAttachment3D` bound to Tip on a two-bone `Skeleton3D`,
with a marker `Node3D` at attachment-local (1,0,0). After setting Tip pose
(0,3,0) and Root pose +90° about Z, the attached marker's live global
position is (-3,1,0); with Root identity it is (1,3,0). The Tip global
**rest** remains (1,2,0) in both arms. Binding, attachment basis/origin,
and actual marker global transform are asserted before fixed markers.
This is a live Node3D follower in headless scene-tree coordinates, not
skinned mesh deformation, pixels or GPU evidence.

## Determinism rules for new cases

- Fixed tick budgets only. Count ticks through the actor's own counter and
  assert the budget exactly; never read a wall clock.
- `project.godot` pins `physics/common/physics_ticks_per_second=60`, so the
  authored delta is `1/60`.
- `SceneTree.physics_frame` is emitted at the **start** of a physics step, before
  `Node._physics_process`. Snapshot right after `await physics_frame`, then await
  N further physics frames to span exactly N `_physics_process` calls.
- No randomness, no `randf`, no OS/device input, no network, no display.
- Bound every wait (`FRAME_BOUND`) and exit through `SceneTree.quit(code)`.
- Expected values are hand-derived **literals** in the fixture, not recomputed
  from the same constants that build the geometry. Otherwise a mutated constant
  re-derives its own expectation and the assertion proves nothing — this is what
  `--probe-failing` checks.
- `--headless` pins the root `Window` to 64×64 and ignores
  `display/window/size`; author a `SubViewport` when a viewport size matters.
- `Camera3D.near`/`far` are stored as 32-bit floats (`0.05` reads back as
  `0.05000000074506`): compare with a tolerance. `Basis.get_row()` is not exposed
  to GDScript, and `basis[i]`, `basis.x/y/z` are columns.
- Format marker floats through `snappedf(v, 0.001) + 0.0` so `-0.0` and
  sub-tolerance noise print as `0.000` while genuine negatives stay signed.

## Scope

Headless Godot 4.7.2 on this Linux host: physics, spatial queries, projection
math, transform composition, scene-graph signals and synthetic input. It proves
nothing about rendering or GPU behaviour, exported builds, other engines, editor
tooling, multiplayer, or navigation baking. See
`corpus/lessons/r1-headless-verification.md`.
