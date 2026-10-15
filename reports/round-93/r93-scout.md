# r93 scout — the Area3D monitoring lattice, the `shape_*` runtime ops, layer/mask writes mid-contact, and the PhysicalBone3D / Generic6DOF edges

Lane: g3d · engine `4.7.2.stable.arch_linux.ed1daf0bf` · `--headless`, 60 tps.
Backends swept: GodotPhysics (`proj`) and Jolt (`proj_jolt`) for **every** cell.
Evidence: `corpus/live/r93-scout/` — `probes/` (6 scripts), `driver.py`,
`runs/*` (**204 children, 204 rc=0**), `manifest.sha256` (878 files),
`RECEIPTS.md`, `audit.py`. `corpus/fixtures/`, `reports/round-88..92/**` and
the other `corpus/live/*` trees untouched.

Reps: 68 cells carry a `.r1/.r2/.r3` triple. 61 are byte-identical across reps;
2 differ only in the `pf`/`seq` stamps; 5 differ only in idle-frame (`p=F`)
multiplicity and the resulting `seq` offsets — **0 differ in physics
observables** (`audit.py`, which drops `p=F` rows and blanks `pf=`/`seq=`
before hashing).

Confidence labels: **[O]** observation (receipt-pinned, rep-stable),
**[I]** inference, **[?]** unknown / not decided by these cells.

---

## 0. Where an Area3D signal sits inside a physics tick

Every row carries `pf` (`Engine.get_physics_frames()`) and `seq` (one counter
bumped at the top of *every* callback, signal handlers included), so the
emission point is read off the receipt rather than inferred:

```
AR p=IF pf=21 seq=93          # RigidBody3D._integrate_forces
AR p=A sig=A.body_entered pf=21 seq=94     # the signal handler
AR p=A sig=A.body_shape_entered pf=21 seq=95
AR p=E  pf=21 seq=96 t=21 by=2.0343 ovA=1/0   # _physics_process
```

**[O] On both backends an area overlap signal is emitted inside the physics
step that detects the overlap: after `_integrate_forces` and before
`_physics_process`, with the area's own overlap list already updated in the
handler.** The ball enters the area mid-run (`enter`: overlap first true at
pf=21) and the signal lands at pf=21 between IF and E; the same ordering holds
for the exit signal (teleport written at E(34) → `body_exited` at pf=35 between
IF(35) and E(35)) and for the already-overlapping-at-scene-start case
(`enter0`: `E(1)` still reads `ovA=0/0`, the signal fires in the pf=2 step).
There is no deferred/idle-frame path: `p=F` rows never carry the signal.

---

## 1. The Area3D monitoring / monitorable / priority matrix

Scene: static floor (top y=−0.5), sphere ball r=0.5 (rest y≈−0.01), area A
`BoxShape3D 6×2×6` at (0,0.6,0) (y∈[−0.4,1.6] — excludes the floor), area B
`2×2×2` inside A (parked at (100,0,0) unless the case needs it).

### 1.1 Arm table (verbatim-armable cells)

Run from `corpus/live/r93-scout/`; each cell is one child per backend.

| # | command | expected signature (verbatim) | falsified if |
|---|---|---|---|
| 1.1 | `python3 driver.py --batch areas --reps 3 --only ar_proj_enter` (and `ar_proj_jolt_enter`) | `E(20) … ovA=0/0`; `body_entered pf=21 seq=94` between `IF pf=21 seq=93` and `E pf=21 seq=96`; `ACT OUT` at `E(34)`; `body_exited pf=35` | the signal is emitted before IF, after E, or at the idle frame |
| 1.2 | `--only ar_proj_enter0` (and jolt) | `E(1) … ovA=0/0`; `body_entered pf=2`; `ovA=1/0` at `E(2)` | the first stepped frame does not report the already-overlapping body |
| 1.3 | `--only ar_proj_monoff` (and jolt) | `body_shape_exited seq=93` then `body_exited seq=94` **inside** the `monitoring=false` write (before the `ACT` row `seq=95`); `ERROR: Can't find overlapping bodies when monitoring is off.` per read; re-enable at `E(26)` → `body_entered pf=27` | the exits are deferred to the next step, or `get_overlapping_*` answers a stale list instead of erroring |
| 1.4 | `--only ar_proj_monitoff` (and jolt) | **GP**: no signal and `ovA=1/1` for ticks 20–34; `A.area_exited` only at `pf=35` (B teleported away). **Jolt**: `A.area_exited`+`area_shape_exited` at `pf=21`, `A.area_entered`+`area_shape_entered` at `pf=27` | GP and Jolt agree |
| 1.5 | `--only ar_proj_prio` (and jolt) | both areas report `body_entered` at pf=2 regardless of priority; the per-tick fall step grows 0.0111→0.0772 pre-swap (derived a≈29.5 m/s²; B prio 1 gravity 30 beats A prio 0 gravity 0); post-swap the step is ≈constant 0.0853→0.0839 (derived a≈−0.7 m/s²; A prio 5 beats B prio 0) | priority gates the signals, or the lower-priority REPLACE wins |
| 1.6 | `--only ar_proj_areasig` (and jolt) | `A.area_entered(B)` + `A.area_shape_entered asi=0 lsi=0` at pf=2 and `B.area_entered(A)`; at pf=25 (after `B_AWAY` at E(24)) the order is `A.area_exited` → `A.area_shape_exited` → `B.body_exited` → `B.area_exited` | area-vs-area is one-directional, or the shape indices differ |
| 1.7 | `--only ar_proj_bodysig` (and jolt) | a 2-shape ball gives two `body_shape_entered` at pf=2 after `body_entered` and before `E(2)`: **GP `bsi=0` then `bsi=1`; Jolt `bsi=1` then `bsi=0`** (rep-stable 3/3 each); teardown order `shape_exited(0)` → `body_exited` → `shape_exited(1)` | one shape index only, `body_exited` before any shape exit, or the same per-shape order on both backends |

### 1.2 Verdicts **[O]**

- **Signal timing is in-step and pre-`_physics_process`** (§0) — identical on
  GP and Jolt, for both the entry and the exit edge.
- **`monitoring=false` flushes the area's own monitored set synchronously
  inside the property write**: `body_shape_exited` then `body_exited` are
  emitted during `area.monitoring = false` itself (their `seq` sits before the
  statement's own print). The handler's `get_overlapping_bodies()` **errors**
  (`scene/3d/physics/area_3d.cpp:517`) and returns empty, so the overlap list
  is unreadable at that moment. Re-enabling re-detects the still-overlapping
  ball in the next step (`body_entered` at pf=27 after the write at E(26)).
- **`monitorable=false` is a live-pair backend split** (1.4): GP keeps the
  established area pair and emits nothing; Jolt drops it at the next step with
  the full exit signal set, and re-adds it (with signals) when re-enabled.
- **`priority` does not gate signals** — both areas report the ball and each
  other at every priority. It does decide which `SPACE_OVERRIDE_REPLACE`
  gravity governs the body: the higher priority wins in both orders tested
  (B@1 beats A@0; A@5 beats B@0), measured as a≈29.5 m/s² vs a≈−0.7 m/s².
- **Area-vs-area reporting is symmetric** (`area_entered` on both, both
  `get_overlapping_areas()` non-empty) and carries the shape indices of the
  *other* area's shape 0 and the local shape 0.
- **`body_shape_entered` fires per shape, after `body_entered`, in the same
  step**; with two shapes on the ball the per-shape order is a rep-stable
  backend split: GP emits shape 0 then shape 1, Jolt emits shape 1 then shape 0.

---

## 2. `PhysicsServer3D.shape_*` runtime ops

All bodies are raw server bodies in the root world space; the ball is a sphere
r=0.5 resting on a static box (half-extents 10×0.5×10, top y=0) with
`body_set_max_contacts_reported(ball, 8)`; `cc` is
`body_get_direct_state(ball).get_contact_count()`.

### 2.1 Arm table

| # | command | expected signature (verbatim) | falsified if |
|---|---|---|---|
| 2.1 | `--only so_proj_shrink` (and jolt) | write at `E(20)` reads back `sd=0.25` with `cc=1 y=0.4900` still; `pf=21 cc=0 lv=-0.1633` (contact set re-evaluated next step); falls; `pf=34 cc=1 y=0.2439` (re-contact, GP; Jolt `y=0.2429`) | `cc` changes in the same tick, or the pair never re-forms |
| 2.2 | `--only so_proj_grow` (and jolt) | GP: `pf=21 cc=2 y=0.8900` → `pf=22 cc=1 y=0.9700` → rest `0.9900` (hard eject in ≤3 steps). Jolt: monotone push `0.5690, 0.6490, 0.7290 …` `+0.08`/tick → `0.9780` at t=34 | the body stays inside the enlarged shape, or both backends eject at the same rate |
| 2.3 | `--only so_proj_floorshrink` (and jolt) | `floor->(10,0.4,10)` at E(20): `pf=21 cc=0` (ball falls 0.1); `pf=29 cc=1 y=0.3924` and it stays | the floor change is ignored, or the re-contact is immediate |
| 2.4 | `--only so_proj_shapedisabled` (and jolt) | disable at E(20) → `pf=21 cc=0`, ball falls; re-enable at E(28) → `pf=29 cc=1 y=0.4705` (ejected from `0.3924`, i.e. 0.11 deep) → `0.4898` | re-enabling while overlapping does not re-form the contact |
| 2.5 | `--only so_proj_removeshape` (and jolt) | `remove_shape count_after=0` immediately; `pf=21 cc=0`; ball falls through forever | the body keeps colliding with a removed shape |
| 2.6 | `--only so_proj_sharebody` (and jolt) | two bodies, one sphere RID: `shape_set_data(0.3)` at E(20) → both `cc=0` at `pf=21` and both fall in lockstep; `PRE_FREE b1_shape0=<same RID>`; `FREED … get_data=null c1=0 c2=0` — the shape is detached from **both** bodies, no crash, rc=0; later `shape_get_data` prints `ERROR: Parameter "shape" is null.` | the RID is copied per body, or `free_rid` leaves a dangling shape |
| 2.7 | `--only so_proj_sharenode` (and jolt) | `b1_shape0 == b2_shape0 == res_rid`; `shared_res.radius=0.3` at E(20) → both bodies `cc=0` at `pf=21`, both fall to the new rest (−0.21 GP / −0.20 Jolt), `cc=1` at pf=33 | two `CollisionShape3D` nodes sharing one resource get separate server shapes |
| 2.8 | `--only so_proj_getdata` (and jolt) | sphere `0.7`→`0.69999998807907`; box `(1,2,3)`→same (half-extents); capsule/cylinder/sep_ray/heightmap need **Dictionary** data; concave needs `{"faces": PVA, "backface_collision": bool}`; `node_box size=(2,4,6)` → server `(1,2,3)`; `node_sphere 0.9` → `0.89999997615814` | a Vector2/Vec3 write round-trips on capsule/cylinder/sep_ray/concave |
| 2.9 | `--only so_proj_getdatabad` (and jolt) | sphere+Vector3 → `0.0`; sphere+Dict → `0.0`; box+float → `(0,0,0)`; capsule/cylinder+Vector2 → GP `null` / Jolt unchanged default; sep_ray+Vector2 → GP `{length 0.0}` / Jolt unchanged; concave+PVA → GP `null` / Jolt **error** `jolt_concave_polygon_shape_3d.cpp:105` + unchanged; convex+Array → `pva[4]` (accepted); sphere `-1.0` → `-1.0` (no validation) | a wrong-format write raises a GDScript error or is refused cleanly |
| 2.10 | `--only so_proj_getdata2` (and jolt) | concave Dictionary round-trips on both; `Array(faces12)` → GP `null`, Jolt unchanged | the Dictionary form is backend-specific |

### 2.2 Verdicts **[O]**

- **A live `shape_set_data` is applied at the start of the NEXT step, and the
  contact set is re-evaluated then** — the write tick keeps `cc=1` and the old
  pose; the next tick shows `cc=0` (shrink / floor shrink / shape disabled /
  shape removed) or a depenetration (grow). GP's server applies pending shape
  updates at the top of `step()` (`_update_shapes()`;
  `corpus/live/r90-scout/src/godot_physics_3d/godot_physics_server_3d.cpp:1679`,
  **[I]** — provenance: r90's copy, not sha-pinned to the binary), which
  matches the measured timing exactly.
- **Depenetration rate is a backend split**: GP ejects a 0.5 m interpenetration
  in ≤3 steps (a near-snap: `0.49→0.89→0.97→0.99`), Jolt pushes at a constant
  ≈0.08 m/tick and asymptotes (`0.95→0.978` by t=34). Same split on the
  re-enable path (`reenable`: GP `−0.159→−0.0398` in one step; Jolt
  `−0.16→−0.1096→−0.0774→…`).
- **A shape RID is shared by reference, not copied**: one RID in two bodies
  moves both on a single `shape_set_data`, and `free_rid` **detaches it from
  every owner** (both `body_get_shape_count` → 0, `body_get_shape` → invalid,
  later getters print `Parameter "shape" is null.`). No crash, rc=0, identical
  on GP and Jolt. (GP source confirms the detach loop — **[I]**, same cache.)
- **The node path is the same RID**: two `CollisionShape3D` nodes sharing one
  `SphereShape3D` resource expose the resource's RID as their body shape
  (`b1_shape0 == b2_shape0 == res_rid`), so a resource mutation mid-contact
  updates both bodies in the next step. There is no per-node copy.
- **Data formats (4.7.2)**: float32 storage (`0.7`→`0.69999998807907`);
  box data is half-extents (server) vs full size (node `BoxShape3D.size`);
  capsule/cylinder/separation-ray/heightmap take **Dictionaries**; concave
  takes `{"faces", "backface_collision"}`; convex takes a
  `PackedVector3Array`/`Array`; world boundary takes a `Plane`. A
  wrong-format write is **silently accepted with a default value** (sphere
  →0.0, box→(0,0,0)) or leaves the shape unconfigured (GP `null`) — the only
  refusal is Jolt's concave error line.
- **Unconfigured / freed reads**: a never-configured shape answers `null` on
  GP and a zero-valued default on Jolt (sphere `0.0`,
  capsule `{height:0, radius:0}`); a freed RID answers `null` on both (with an
  error line on GP). `shape_get_margin` reads `0.0` for GP raw shapes and
  `0.04` for Jolt box/cylinder/convex.

---

## 3. `collision_layer` / `collision_mask` writes mid-contact

Node bodies: static floor (top y=−0.5), ball r=0.5, `max_contacts_reported=8`;
`cc` from the direct state; the write happens at `E(20)` with the ball at rest
(`cc=1 y=−0.0100 lv=0`).

### 3.1 Arm table

| # | command | expected signature (verbatim) | falsified if |
|---|---|---|---|
| 3.1 | `--only ly_proj_maskoff` (and jolt) | `ACT ball.mask=0 node=0 srv=0` at E(20) with `cc=1 y=-0.0100`; `pf=21 cc=1 y=-0.0127 lv=-0.1633`; the ball **keeps sinking** with `cc` still 1 (1→2 as it deepens) through `pf=40 y=-0.5757` | the buffer clears on the mask write |
| 3.2 | `--only ly_proj_layeroff` / `--only ly_proj_layeroffsrv` (and jolt) | identical ghost trace via the node property and via `body_set_collision_layer(floor, 0)` | the two write paths differ |
| 3.3 | `--only ly_proj_reenable` (and jolt) | mask 0 at E(20), 1 at E(30) while the ball is 0.159 deep: `pf=31 y=-0.0398 lv=0` (GP ejection) → settles `-0.0100` by pf=35 | the re-enabled pair does not form |
| 3.4 | `--only ly_proj_newcontact` (and jolt) | mask 0 from the start: `cc=0` until `pf=13`, then `cc=1` from `pf=14` while the ball is still falling at `lv=-2.10…`; mask 1 at E(20) (`y=-0.3121`) → `pf=21 y=-0.0704 lv=0` (0.24 m ejection in one step) | `cc` stays 0 while the filtered pair overlaps, or the ejection is gradual on GP |
| 3.5 | `--only ly_proj_sleepstate` (and jolt) | GP `srv=false` at pf=1; **Jolt `srv=true` at pf=1**, `false` from pf=2 | the two backends agree at pf=1 |
| 3.6 | `--only ly_proj_sleepwake` / `ly_proj_sleepmask` (and jolt) | natural sleep at `pf=43` (`cc=1 y=-0.0100`, Jolt `-0.0110`); write at E(45): GP `sleep=false` in the write tick then falls (`pf=46 lv=-0.1633`); **Jolt `sleep=true`, `y` frozen at `-0.0110` through pf=53+** | the write wakes a sleeping body on Jolt |
| 3.7 | `--only ly_proj_nodevssrv` (and jolt) | `ball.collision_mask=4` → `srv_read=4`; `body_set_collision_layer(floor,8)` → `node_read=1`; `area.collision_mask=2` → `srv_read=2`; `area_set_collision_layer(16)` → `node_read=1` | the node readback tracks a server-side write |

### 3.2 Verdicts **[O]**

- **A mid-contact layer/mask write produces a GHOST contact**: the pair is not
  destroyed and the contact buffer is **not** cleared — `cc` stays ≥1 and even
  grows as the body sinks, while the solver stops applying impulses
  (`lv` grows negative, free fall). The sink starts one step after the write
  (`pf=21`), so the filter is evaluated per step at solve time, not at the
  write. This holds for the ball's mask, the floor's layer (node or server
  write) and on both backends. (Contrast r89 §1.4: a teleport out of contact
  *does* clear the buffer.)
- **The narrowphase runs through a filtered pair**: with the mask off from the
  start, `cc` goes 0→1 the step the ball penetrates (`pf=14`) and stays 1 while
  the ball passes through at full speed — contacts are generated and reported,
  the solve is skipped.
- **Re-enabling mid-penetration ejects the body** (GP: one hard step from
  0.159 deep; Jolt: gradual) and the ball settles back to the rest offset.
- **Node → server is live; server → node is stale**: a node property write is
  visible through `body_get_collision_mask`/`body_get_collision_layer`, but a
  server write does not update the node's cached `collision_layer`/
  `collision_mask` (reads 1 after writing 8/16). The physics uses the server
  value (3.2 behaves identically), so the node property is a cache, not a view.
- **Sleep is a backend split again**: GP's layer/mask write wakes the sleeping
  ball (and it then falls); Jolt's does not (frozen for the rest of the run).
  This re-binds r89's `sleepfrozen` split (GP propagates space writes to
  sleeping neighbours, Jolt does not) on a new write class.
- **Jolt reports `BODY_STATE_SLEEPING = true` on the spawn frame** (pf=1) for a
  freshly added falling body (3.5) — a false positive that any sleep-detection
  loop must debounce.

---

## 4. PhysicalBone3D and the Generic6DOF deeper edges

### 4.1 PhysicalBone3D surface (both backends)

`Skeleton3D` with bones `root`/`child`, one `PhysicalBone3D` child each
(`bone_name` set before entering the tree), CollisionShape3D sphere r=0.2.

**[O]** before the simulation starts: the body already exists —
`get_rid()` valid, `body_get_mode` = 0 (STATIC), `body_get_shape_count` = 1,
`is_simulating_physics()` false, `get_bone_id()` = **−1**.
`physical_bones_start_simulation()` resolves `bone_id` to 0/1, flips
`is_simulating_physics()` true and `body_get_mode` to **2 (RIGID)**, and both
bodies then fall as independent rigid bodies (GP: `3.0000→2.3220` by t=33 with
no lateral drift; Jolt: `3.0205→2.2372` with a small x/z drift). The
`Skeleton3D` bone poses stay at their rest values (`bone0=0,0,0`,
`bone1=0,0,0` in skeleton space) in every sampled row even though
`animate_physical_bones` reads true — **[O]** measured, mechanism **[?]**.

**[O]** `physical_bones_stop_simulation()` at t=20 sets
`is_simulating_physics()` false and `body_get_mode` to 1 (KINEMATIC); the
bodies freeze for one tick at their last position and then **snap back to the
skeleton origin (0,3,0)** — for *both* bones, i.e. not to the bone rest offset
of bone 1 (which is (0,2,0) in world space). Identical on GP and Jolt (Jolt
keeps its x/z drift during the freeze tick, then zeroes it too).

**[O]** `physical_bones_start_simulation(["root"])` is indistinguishable from
the unfiltered call in this scene: the per-row traces are identical on **both**
backends (`diff` of the `BO p=E` rows is empty for GP and Jolt) — the
bone-name filter has no effect here.

**[O]** API surface (ClassDB, 4.7.2): `PhysicalBone3D` has **no**
`set_bone_name`/`set_simulate_physics` methods; `bone_name` is a plain property
(`get`/`set` via `Object`), `simulate_physics` is read-only
(`get_simulate_physics()`, no setter, and no such property), and
`get_bone_id()`/`get_rid()`/`is_simulating_physics()` are the usable probes.

### 4.2 Generic6DOF rotational/linear witness

Scene: static anchor A at (0,3,0), dynamic B at (0,2,0), joint made with
identity refs; witness = B's euler + angular/linear velocity + the anchor gap.

| case | GodotPhysics | Jolt |
|---|---|---|
| `g6free` (control, no joint) | spin `(0,0,3)` survives (`av≈2.94` at t=14, `euler.z=0.5935`); falls freely (gap `1.0→1.80`) | identical |
| `g6rot` (default joint; angular axes locked at t=4) | spin **arrested in one step** (`3.0000→0.0001` at t=3, before the lock is written); gap pinned at **0.8900** | spin and fall survive the default joint (`av=2.99`, gap grows); the explicit lock arrests it by t=10 (`av=0`, `euler.z=0.0069`) |
| `g6motor` (axis-2 motor: target 3.0, force 10, flag on) | **no rotation at all** (`av=0.0000` for 25 ticks) | motor drives: `av=-3.0000` constant, `euler.z=-1.0278` at t=25 |
| `g6linear` (all 3 linear axes locked, flag on) | same as the default (gap 0.8900, no motion) | binds: gap `1.0→0.2484` by t=10 → `0.2001` at t=25 with `lv=0` |
| `g6nolin` (linear-limit flag cleared, then spin) | spin **survives at `av=0.8557`** and the body falls (gap `1.0→1.5737`), with a `+0.4279` m/s x-drift | not run (the flag is Jolt's only linear path) |

**[O]** r89's "`joint_make_generic_6dof` is a silent no-op on Jolt" is
**narrowed**: on Jolt the make is *not* a no-op — the angular limit and the
explicitly-flagged linear limit both bind, and the angular motor drives. What
Jolt lacks is the *default* (unflagged) linear lock that makes GP's g6dof a
pin-like constraint.

**[O]** On GP the default g6dof also freezes rotation, and clearing the
linear-limit flag is what lets the spin survive — **[I]** the angular arrest is
a side effect of the default linear-limit solve (identity refs put the joint
anchor at the body origin), not of the angular params, whose defaults read
±1e30 with the angular flag false. **[O]** GP's g6dof angular motor has no
authority in this scene even with the flag on and a 10.0 force limit.

---

## 5. Backend split summary (one row per measured divergence)

| axis | GodotPhysics | Jolt |
|---|---|---|
| `monitorable=false` on a live overlapping area | no-op: pair kept, no signal, list unchanged | honored next step: exit signals at pf=21, re-enter signals at pf=27 |
| per-shape signal order (`body_shape_entered`) | shape 0 then shape 1 | shape 1 then shape 0 |
| mid-contact depenetration rate | near-snap (≤3 steps for 0.5 m) | gradual ≈0.08 m/tick, asymptotic |
| sleeping body + layer/mask write | wakes in the write tick, then falls | stays asleep, frozen for the rest of the run |
| `BODY_STATE_SLEEPING` on the spawn frame | `false` | **`true`** at pf=1, `false` from pf=2 |
| default g6dof (flags false) | translation locked (gap 0.89) **and** rotation arrested | neither: free fall + free spin |
| g6dof angular limit / motor (flag on) | limit redundant, motor dead (`av=0`) | limit binds, motor drives (`av=-3.0`) |
| g6dof linear limit (flag on) | redundant with the default | binds (gap 0.2001, `lv=0`) |
| `joint_is_disabled_collisions_between_bodies` default | true | false (re-binds r89) |
| unconfigured shape read | `null` | zero-valued default (`0.0`, `{height:0,radius:0}`) |
| wrong-format concave write | silent `null` | error at `jolt_concave_polygon_shape_3d.cpp:105`, unchanged |
| `shape_get_margin` on raw shapes | `0.0000` | `0.0400` (box/cylinder/convex) |
| contact rest offset (sphere r=0.5 on box top y=0) | `y=-0.0100` | `y=-0.0110` |
| PhysicalBone3D fall trace | no lateral drift (`3.0000→2.3220`) | small x/z drift (`3.0205→2.2372`) |

Area3D signal timing, the ghost-contact mechanism, the shape-RID sharing
semantics and the `free_rid` detach are **identical** on both backends.

---

## 6. Falsification list (claims this round tested)

1. **"An area overlap signal is deferred to the next idle frame."** FALSIFIED —
   it fires inside the detecting physics step, between `_integrate_forces` and
   `_physics_process`, with the overlap list already updated (§0, §1.1).
2. **"`monitoring=false` mid-overlap leaves the overlap set alone."**
   FALSIFIED — the set is flushed synchronously in the property write, emitting
   `body_shape_exited` + `body_exited` before the assignment statement returns;
   the handler's `get_overlapping_*` then errors instead of answering (§1.1/1.3).
3. **"`monitorable` behaves the same on both backends."** FALSIFIED — GP keeps
   the live pair and emits nothing; Jolt drops it next step with signals (§1.4).
4. **"`priority` decides which area's signals fire."** FALSIFIED — both areas
   report regardless of priority; priority only decides which REPLACE override
   governs the body (higher wins) (§1.5).
5. **"`shape_set_data` on a live body's shape updates the contact set in the
   same tick."** FALSIFIED — the write tick keeps the old contact count and
   pose; the re-evaluation lands in the next step (§2.1–2.5).
6. **"A shrunken shape's pair is never re-created (the body tunnels)."**
   FALSIFIED on both backends — the ball re-contacts at pf=34 once the shrunken
   sphere reaches the floor (`y=0.2439` GP / `0.2429` Jolt); the apparent
   tunneling in a 34-tick window was a truncated observation (§2.1).
7. **"`shape_set_data` on a shape used by two bodies affects only one."**
   FALSIFIED — the RID is shared; one write moves both bodies in lockstep, and
   `free_rid` detaches it from both owners with no crash (§2.6).
8. **"Node `CollisionShape3D` nodes get their own server shape."** FALSIFIED —
   both nodes expose the shared resource's RID; a resource mutation moves both
   bodies next step (§2.7).
9. **"`shape_get_data` round-trips whatever you wrote."** FALSIFIED — float32
   storage (`0.7`→`0.69999998807907`), capsule/cylinder/sep-ray/heightmap/
   concave require Dictionary data, box is half-extents server-side, and a
   wrong-format write is silently accepted as a default (§2.8/2.9).
10. **"A mid-contact collision_layer/mask write terminates the contact."**
    FALSIFIED — the contact set persists and is regenerated while the solve
    stops: a ghost contact, and the body sinks through the collider (§3.1–3.2).
11. **"A body whose mask is off generates no contacts."** FALSIFIED — contacts
    are generated and counted (`cc=1`) while the body falls through; the filter
    is a solve-time gate, not a narrowphase gate (§3.4).
12. **"A server-side `body_set_collision_layer` updates the node property."**
    FALSIFIED — the node readback stays at its own value (1) after a server
    write of 8/16, while node→server writes are visible (§3.7).
13. **"A layer write wakes a sleeping body on every backend."** FALSIFIED on
    Jolt — GP wakes and the ball falls; Jolt stays asleep and frozen (§3.6).
14. **"`body_get_state(BODY_STATE_SLEEPING)` is false for a fresh body."**
    FALSIFIED on Jolt — it answers true on the spawn frame (pf=1) and false
    from pf=2 (§3.5).
15. **"`joint_make_generic_6dof` is a no-op on Jolt."** FALSIFIED as stated —
    Jolt's g6dof binds the angular limit and the flagged linear limit and its
    motor drives; only the default linear lock is missing (§4.2). (r89's
    distance witness could not see this — it is narrowed, not overturned for
    the default-flag case.)
16. **"A GP g6dof lets the body rotate by default."** FALSIFIED — the default
    joint arrests a 3 rad/s spin in one step; clearing the linear-limit flag is
    what lets it survive (§4.2).
17. **"`physical_bones_start_simulation(names)` filters the simulated bones."**
    FALSIFIED in this scene — the filtered call is row-identical to the
    unfiltered one on both backends (§4.1).
18. **"A `PhysicalBone3D` has no physics body until the simulation starts."**
    FALSIFIED — the body exists (STATIC, one shape) from the moment the node
    enters the tree; the start call only switches it to RIGID (§4.1).
19. **"`body_shape_entered` reports a multi-shape body's shapes in the same
    order on both backends."** FALSIFIED — GP emits shape 0 then shape 1, Jolt
    shape 1 then shape 0, rep-stable 3/3 on each (§1.1/1.7).

---

## 7. Observation / inference / unknown

Observation (receipt-pinned, rep-stable): every number, ordering, error string,
rc and byte-identity claim above.

Inference (labelled): the GP `_update_shapes()`-at-step-top mechanism for the
next-step timing (§2.2) and the detach-on-free loop (§2.2), both read from the
r90-scout engine-source cache (provenance: r90's copy, not sha-pinned to the
binary); the linear-limit-solve origin of GP's angular arrest (§4.2).

Unknown / deferred:
- Why the `Skeleton3D` bone poses never follow the physical bone bodies in this
  headless minimal skeleton (`animate_physical_bones` true, bodies fall and the
  nodes track them) — needs a skinned/imported skeleton to separate "no skin"
  from "no animation in `--headless`".
- The mechanism behind GP's residual `−0.7 m/s²` after the priority swap in
  `prio` (the higher-priority REPLACE does take over — the fall becomes
  near-constant-velocity — but the residual is unexplained).
- Whether a GP `monitorable=false` ever takes effect (this round only shows it
  does not within a 14-tick window on an established pair).
- Whether GP's `shape_set_data` on a *concave* shape can be made to configure
  (Dictionary works on Jolt; GP stays `null` for PVA and Array).
- The g6dof angular/linear axes' exact freedom semantics beyond the identity-ref
  anchor used here (offsets/rotated refs not swept).
- Threaded behaviour of every cell (all cells are non-threaded; r87/r88 own the
  threaded gate).
- `Dummy` backend not swept this round (r89 pinned its degenerate paths).

---

## 8. Reproducing

```
cd corpus/live/r93-scout
python3 driver.py --batch intro    --jobs 2      # ClassDB surface
python3 driver.py --batch intro2   --jobs 2      # dynamic property surface
python3 driver.py --batch areas    --reps 3 --jobs 8   # §0-§1 (7 cases x 2 backends)
python3 driver.py --batch shapeops --reps 3 --jobs 8   # §2 (10 cases x 2 backends)
python3 driver.py --batch layers   --reps 3 --jobs 6   # §3 (9 cases x 2 backends)
python3 driver.py --batch bones    --reps 3 --jobs 8   # §4 (8 cases x 2 backends)
python3 audit.py                                 # rc census + rep identity
```

Single cells: `python3 driver.py --batch areas --reps 3 --only ar_proj_monoff`
(or `ar_proj_jolt_monoff`); `--only so_proj_sharebody`, `ly_proj_sleepwake`,
`bo_proj_g6rot`, … (the `--only` filter matches the tag substring).

## Receipts pointer

`corpus/live/r93-scout/`: `probes/` (6 `.gd`), `driver.py`, `audit.py`,
`runs/` (204 children + rc/ms sidecars), `RECEIPTS.md` (probe inventory, run
groups, disclosed confounds), `manifest.sha256` (878 pinned files),
`fullrun.log`. `corpus/live/` is gitignored — scratch only, per lane contract.

Provenance note: this lane wrote **only** `corpus/live/r93-scout/**` and
`reports/round-93/r93-scout.md`; it did not read or write `corpus/fixtures/**`
or any other round's scratch tree. Every probe is a standalone `SceneTree`
script run against a generated `project.godot` (60 tps, backend selected by
project setting), so no receipt depends on the fixture battery.
