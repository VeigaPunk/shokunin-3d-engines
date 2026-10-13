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
