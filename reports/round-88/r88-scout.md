# r88 scout — the `PhysicsDirectSpaceState3D` read family + `PhysicsDirectBodyState3D` inertia getters

Lane: g3d · engine `4.7.2.stable.arch_linux.ed1daf0bf` · `--headless`, 60 tps.
Backends: GodotPhysics (`proj`), Jolt (`proj_jolt`), Dummy (`proj_dummy`);
threaded twins `proj_thr`, `proj_jolt_thr`, `proj_dummy_thr`.
Evidence: `corpus/live/r88-scout/` — probes, driver, `runs/*` receipts,
`manifest.sha256`, `RECEIPTS.md`. `phys3d_events.gd` untouched (r87 in
flight; its working-tree diff is r87's own arm additions).

Axis targets from the brief: return shapes/types, access timing & gate,
backend differences (GP/Jolt/Dummy), threading behavior, crash/refusal
classes, param-object identity, byte stability.

## 1. ClassDB signatures and return types (intro_*.r1)

`PhysicsDirectSpaceState3D` — all six methods flags=1 (METHOD_FLAG_NORMAL,
not const):

| method | args | return |
|---|---|---|
| intersect_point | `PhysicsPointQueryParameters3D`, `max_results:int=32` | `Array` |
| intersect_ray | `PhysicsRayQueryParameters3D` | `Dictionary` |
| intersect_shape | `PhysicsShapeQueryParameters3D`, `max_results:int=32` | `Array` |
| cast_motion | `PhysicsShapeQueryParameters3D` | `PackedFloat32Array` |
| collide_shape | `PhysicsShapeQueryParameters3D`, `max_results:int=32` | `Array` |
| get_rest_info | `PhysicsShapeQueryParameters3D` | `Dictionary` |

`PhysicsDirectBodyState3D` getters measured: `get_inverse_mass`,
`get_inverse_inertia`, `get_inverse_inertia_tensor`,
`get_principal_inertia_axes`, `get_transform`, `get_center_of_mass`,
`get_center_of_mass_local` — flags=5 (normal|const).

Param-class defaults (instantiated, `sh_*`/`intro_*`): shape query
`margin=0`, `motion=0`, `transform=identity`, `collision_mask=0xFFFFFFFF`,
`collide_with_bodies=true`, `collide_with_areas=false`, `shape=null`,
`shape_rid=RID(0)`, `exclude=[]`. Point query: `position=0`, same
mask/bodies/areas/exclude. Ray query: `from=to=0`, bodies AND areas true,
`hit_from_inside=false`, `hit_back_faces=true`.

## 2. Return shapes and identity (sh_*.r1..3 — byte-identical x3 on all four variants)

Hit dictionaries (`intersect_point`, `intersect_ray`, `intersect_shape`
elements): keys `rid`, `collider_id`, `collider`, `shape`; ray adds
`position`, `normal`. `get_rest_info` dict: `point`, `normal`, `rid`,
`collider_id`, `shape`, `linear_velocity` (6 keys) — and `linear_velocity`
is real: a body moving at (0.9867,0,0) reported exactly that
(`S ri_dyn_lv`). `collide_shape` returns `Array[Vector3]` contact points
(2 points for the measured floor contact on GP: `(0,-0.2236,-0.5528)`,
`(0,0,-1)` — one point per contact pair role). `cast_motion` returns
exactly 2 floats `[safe, unsafe]`.

- `max_results`: bounds the returned array (`cs_max4=2` == uncapped count
  on the measured single-contact geometry; `max_results<=0` → empty, no
  error). Whether `collide_shape`'s cap counts points or contact pairs is
  undecided by these cells (measured contacts = 1 pair = 2 points — the
  unit would need a multi-contact scene to discriminate).
- Repeat calls return fresh container objects (new Array/Dictionary each
  call) with identical contents — `same_object` false, byte-equal values.
- `shape_rid` beats `shape` when both are set (`sh_*` both-set rows hit
  the RID's sphere, not the resource's box). A live `SphereShape3D`
  resource assigned to `p.shape` works and stays reusable.
- Node-created `RigidBody3D` colliders preserve identity end-to-end:
  `collider` is the same Object (`==`), `collider_id` is its instance id,
  `rid` is its server RID (`nid_*` rows).

## 3. Param-object mutation (sh_*)

No measured read method mutates its param object: `transform`, `motion`,
`margin`, `mask`, `shape`, `shape_rid`, `exclude` byte-identical before
and after `cast_motion`, `intersect_shape`, `collide_shape`,
`get_rest_info`, `intersect_point` (`cm_p_before == cm_p_after` and the
`isect`/`rest` param dumps). The param object is pure input — no
"out-param" smuggling.

## 4. `motion` is per-method — the semantic split (gate rev 3, all reps)

Same sphere, same `PhysicsShapeQueryParameters3D`, only geometry varied:

- `cast_motion` APPLIES motion: clear-start sphere at (0,0.6,-1) casting
  -5z reports `[~0.098, ~0.104]` = wall face at z=-2 (`cmw`); penetrating-
  floor start gives the identical wall fraction (`cm`) — a start overlap
  does NOT pin the cast to 0. Moving AWAY +5z from the wall reports
  `[~0.598, ~0.602]` (GP) / `[~0.600, ~0.600]` (Jolt) — nonblocking
  mid-sweep fractions, semantics of the overlap-exit contact deferred
  (§unknown). Miss/zero-motion/short-motion all return `[1.0, 1.0]`.
- `collide_shape` DOES NOT apply motion: a clear-start sphere whose -2z
  sweep ENDS embedded in the wall reports `n=0` at every position
  (`cw=0`); only the in-place overlap is reported (`cs=2` for the
  penetrating-floor start).
- `get_rest_info` DOES NOT apply motion: same end-embedded sweep reports
  `n=0` (`rw=0`); a penetrating start reports the in-place contact
  (floor dict, `ri=6`, point = sphere's own start center).
- `intersect_shape` ignores motion (`is_withmotion` == `is` on sh_*).

So within one params object, `motion` is honored by exactly ONE of the
four methods that accept it — `cast_motion` only. Authoring implication:
`collide_shape`/`get_rest_info` are pose probes, not sweep probes, on both
real backends.

## 5. The access gate and its lattice (gt_*)

Fetch legality (fresh `PhysicsServer3D.space_get_direct_state(wspace)` or
`World3D.direct_space_state`):

| variant | A (init) | B/C (pre-first-step, out-of-phase) | D/E (in-phase) | F (_process) | SS/IF twins |
|---|---|---|---|---|---|
| proj | object | object | object | object | object |
| proj_jolt | object | object | object | object | object |
| proj_thr | **nil** | **nil + errors** | object | **nil + 3 ERRORS** | object |
| proj_jolt_thr | **nil** | **nil + errors** | object | **nil + 3 ERRORS** | object |
| proj_dummy(-thr) | object | object | object | object | object |

Under threaded physics the fetch is refused at EVERY out-of-phase
position — including `_initialize` before the first step; only positions
inside the physics tick (D/E/SS/IF) yield a handle. Non-threaded
backends hand out the object everywhere.

The threaded fetch refusal emits three errors (one per acquisition path:
`space_get_direct_state`, `World3D.direct_space_state`, and the
`body_get_direct_state` arm) then returns nil — same refusal class as r87
documented; the gate covers FETCHING.

Use legality — queries on a STASHED handle at out-of-phase positions —
are NOT refused on any backend: `pt/is/ray/cm` answer from every sampled
position on every variant. With one position anomaly below.

**D-window (contact-data seam)**: at position D — the deferred
continuation resumed inside `physics_frame` emission — `collide_shape`
and `get_rest_info` on the penetrating-floor query return EMPTY
(`cs=0 ri=0`) while `pt/is/ray/cm/cmw` all answer normally; from
`_physics_process` (E) onward the same calls return `cs=2 ri=6`.
Rep-stable across 3 reps on BOTH non-threaded backends and proj_thr —
position-determined, not a race: the F windows on non-threaded never show
it, threaded F windows show the same `cs=0 ri=0` signature
probabilistically. Same signature family as the r87 contact-buffer
step-stamp: the two contact-GENERATING methods see a narrower data
window than the broadphase/sweep methods. Mechanism: unknown (the floor
contact is transient-query narrowphase, not a body pair — inference:
contact-solving consults a step-stamped artifact the physics_frame
emission precedes).

Bypass paths measured:

- `bds.get_space_state()` (`BYP` rows): a held body-state singleton
  returns the SAME dss object (`==` the world direct state) even at
  refused positions — including `F` on the THREADED variants where the
  direct fetch returns nil (`BYP F bds_space=<backend>DSS3D pt_n=1`) —
  and queries through it answer. A genuine fetch-gate bypass on all real
  backends; on threaded ones its results join the same race (below).
- `space_get_direct_state` on a NEVER-ACTIVATED private space
  (`space_create` + `space_set_active(false)`): on NON-threaded backends
  the fetch succeeds at every position (`ALT A alt_fetch=<backend>DSS3D`
  at pf=0, never stepped) — the gate keys on the step cycle, not on
  activation. On THREADED variants the same fetch is refused at
  out-of-phase positions (`ALT F alt_fetch=nil`) — the threaded gate is
  per-process-phase and covers inactive spaces. The STASHED inactive-
  space handle keeps answering at every position either way
  (`ALTS pt=1 is=1 ray=7 rv=6`; inactive space has only a wall, so
  `cs/ri=0` is geometric; `rv` is the in-place overlap control).

## 6. Threaded race taxonomy (gt_proj_thr / gt_proj_jolt_thr, 3 reps each)

Everything in this section is a measured race observable — none of it is
deterministic API semantics.

- `proj_thr` (GP+thread): fresh world fetch refused at F (above). Held-
  handle queries at F: broadphase (`pt`, `is`, `ray`) always answered in
  all reps; contact queries show the `cs=0 ri=0` window in 9/24 sampled
  rows; `cast_motion` fractions DRIFTED twice (`cm=0.197`, `cmw=0.156`
  vs stable `0.098`) — torn mid-step transform reads, not just emptiness.
- `proj_jolt_thr`: deeper race. F-window per-row distribution across
  reps spans: all-answer `pt=1 ray=7 is=1 cs=2 cm=0.100 ri=6`; shape-
  channel empty `is=0 cs=0 cm=n0 ri=0` while `pt=1 ray=7` still answer;
  full-empty `pt=0 ray=0 ...`. The INACTIVE-space stashed handle races
  identically (`ALTS F` rows flip `is`, `cm`, `rv` independently) —
  the lock exposure is global, not per-space (inference).
- **Crash-class outcome**: `gt_proj_jolt_thr.r1` aborted mid-run, rc=134:
  an off-phase `intersect_shape`/`collide_shape` on the stashed
  inactive-space handle tore the shape-RID resolution — `Failed to build
  Jolt Physics sphere shape with {radius=0.000000}`, `Parameter
  "jolt_shape" is null` (`jolt_physics_direct_space_state_3d.cpp:565/655`)
  then `pure virtual method called` / `terminate called without an active
  exception`. 1 of 3 reps; r2/r3 completed with race rows only. So the
  Jolt threaded window is not just "empty results" — off-phase queries
  can hard-abort the process.
- `proj_dummy_thr` ≡ `proj_dummy` byte-identical — Dummy exposes no gate
  and no race; not a witness for this axis.

## 7. Body-state inertia getters (bg_*, byte-identical x3; proj_thr ≡ proj)

Rigid body: box half-extents (2,0.5,0.5), mass 2 → theoretical I =
(diag(1/3, 17/3·?…) — measured `inverse_inertia=(3, 0.352941, 0.352941)`,
`inverse_mass=0.5` on GP and Jolt identically.

- `get_inverse_inertia_tensor()` returns the WORLD-space tensor: rot-Y-30°
  gives `x=(2.338235,0,-1.146210) z=(-1.146210,0,1.014706)` = R·diag·Rᵀ —
  identical numbers GP and Jolt.
- `get_principal_inertia_axes()` tracks orientation on both backends but
  the COLUMN ORDER differs: GP rot-Y-30 x-col `(0.866,0,-0.5)` (the
  rotated longest box axis); Jolt x-col `(0,1,0)` — Jolt returns a
  differently-ordered basis (likely sorted by inertia magnitude;
  inference). Both are valid principal bases for a degenerate
  (y≡z) tensor.
- `get_transform().basis` == body orientation; `com`/`coml` track
  `BODY_PARAM_CENTER_OF_MASS` writes (cb body → `(0.4,0,0)` both).
- `BODY_PARAM_INERTIA` write → `inverse_inertia` reflects it
  (inertia (9,4,1) → inverse `(0.111111,0.25,1.0)`, tensor rotated under
  `iw_y30`) on GP and Jolt.

Backend splits:

| body | GP | Jolt | Dummy |
|---|---|---|---|
| rigid mass-2 box | imass .5, iinertia (3,.353,.353) | same | all-zero |
| **static** | imass **0**, iinertia 0, iit **zero** | imass **1.0**, iinertia **0**, iit **identity** | imass 0, iit identity |
| **kinematic** | same as static (all-zero) | imass **1.0**, iit **identity** | all-zero/identity |
| custom-inertia / COM writes | reflected | reflected | ignored |

Jolt's non-dynamic placeholders are internally inconsistent
(`inverse_mass=1` + `inverse_inertia=0` + `iit=I₃`) — treat Jolt
static/kinematic inertia getters as meaningless-but-nonzero, NOT as
infinite-mass semantics. Dummy's iit=identity matches the Jolt
placeholder convention — identity tensor is the "no data" marker on two
of three backends; GP uses the zero matrix.

## 8. Wrong-argument and max-results cells (wr_*, 39 cells x2, rc=0 everywhere)

All wrong-class params objects are refused in the WRAPPER layer —
backend-independent, identical error text on GP/Jolt/Dummy:

- `intersect_point(shape_params)` → `ERROR: Required object
  "rp_point_query" is null.` → returns empty Array.
- shape-family methods given point/ray params → `Required object
  "rp_shape_query" is null.` → typed empty (Array / PackedFloat32Array /
  Dictionary per method).
- `null` params → same `is null` family → empty, rc=0.
- `shape`/`shape_rid` both unset → empty result, rc=0; on Jolt the error
  additionally names the jolt layer (`jolt_physics_direct_space_state_3d`
  guard) — benign.
- `max_results=-1` / `=0` → empty Array, rc=0 (negative treated as 0).

No wrong-args cell crashes or hangs; every case exits rc=0 with a typed
empty return.

## 9. Freed-space postconditions (cr_*, one method per process, x2 reps)

`free_rid(space)` then call on the stashed direct-state object:

| method | GP | Jolt | Dummy |
|---|---|---|---|
| intersect_point | rc=134 x2 (abort) | **rc=0 x2 — dead-handle path** | rc=0, n=0 |
| intersect_ray | rc=134 x2 | **rc=0 x2 — dead-handle** | rc=0, empty dict |
| intersect_shape | rc=134 x2 | rc=134 x2 | rc=0, n=0 |
| collide_shape | rc=134 x2 | rc=134 x2 | rc=0, n=0 |
| cast_motion | rc=134 x2 | rc=134 x2 | rc=0, empty PF32 |
| get_rest_info | rc=134 x2 | rc=134 x2 | rc=0, empty dict |

- GP: every read method on a freed space's dss = hard abort (SIGABRT,
  rc=134) — crash class, both reps.
- Jolt: the four shape-channel methods abort; `intersect_point` /
  `intersect_ray` took a dead-handle path (previously-freed-object
  errors, typed empty, rc=0) in BOTH reps — but the same methods aborted
  in earlier rev runs, so Jolt's post-free outcome is
  process/race-sensitive: do not treat pt/ray as safe-on-freed-space.
- `space_get_direct_state(freed_rid)` refetch: Dummy returns a fresh
  Dummy dss object (rc=0); real-backend refetch is inside the aborting
  cells' postconditions.
- `bds.get_space_state()` POST-free: GP/Jolt abort or dead-handle per
  rep; Dummy returns its no-op dss.
- Dummy is uniformly benign: typed empties, rc=0, no gate, no crash —
  it is a floor-contrast witness, never a hazard detector (same caveat
  as r86/r87).

## 10. Backend-geometry splits (independent of gate)

- `intersect_point` on a boundary-touching position: GP counts the
  containing wall only (`pt=1`); Jolt additionally counts the touching
  floor (`pt_n=2` in the jolt pt rows) — boundary-touch inclusion differs.
- `cast_motion` wall-contact fractions: GP `[0.0977,0.1035]` vs Jolt
  `[0.0999,0.1002]` — Jolt lands tighter on the geometric 0.1; GP's
  margin handling inflates the bracket symmetric around it.
- `get_rest_info` normal for the same in-place floor penetration:
  GP `(-0.0, 0.4472, -0.8944)` (tilted depenetration) vs Jolt
  `(0,1,0)` (pure up). `ri_overlap_point` differs likewise
  (`(0,0,-2.2)` vs `(0.0014,0.0014,-2)`).
- `collide_shape` point count for identical geometry: GP 2, Jolt 2 —
  same shape, different coordinates (narrowphase solvers differ).
- No backend parity claims are valid for contact geometry — values are
  backend-specific within a common envelope (key sets, types, counts
  modulo boundary-touch).

## 11. Observation / inference / unknown

Observation (receipt-pinned, rep-stable unless noted): everything above
labeled with numbers, exit codes, or `byte-identical` claims.

Inference (labeled):
- The Jolt-threaded lock exposure is global — inferred from the inactive
  space's handle racing during the WORLD step; plus the abort tearing a
  shape-RID lookup that is not space-scoped.
- The `cs=0 ri=0` D-window and the F-window contact-empty cells share a
  signature family — both hit exactly the two contact-generating methods
  — suggesting one pre-step data seam; mechanism unknown.
- Jolt's `principal_inertia_axes` ordering looks like a magnitude sort;
  unverified.

Unknown (deferred):
- Why a penetrating-start contact query is empty at the
  physics_frame-emission position but populated at `_physics_process` in
  the same tick.
- `cast_motion`'s `~0.6` fraction for a laterally-penetrating start moving
  away — some solver contact semantics, not geometrically obvious.
- Whether Jolt's `pt`/`ray` post-free survival vs abort is scheduled by
  the same lock or by object-cleanup order — outcome varied across
  process lives.

## Receipts pointer

`corpus/live/r88-scout/`: `driver.py` (batch runner, `timeout -s KILL`,
merge-mode for error-order-sensitive probes), `probes/*.gd`, `runs/`
(980 receipt files), `RECEIPTS.md` (probe revs, disclosed confounds,
probe-side leak warnings), `manifest.sha256` (1023 pinned files).
`corpus/live/` is gitignored — scratch only, per lane contract.
