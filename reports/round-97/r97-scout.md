# r97 scout — the gameplay node-class surface: Joint3D node binding/lifecycle, SoftBody3D, VehicleBody3D, CharacterBody3D edges, the DSS query-param matrix, and a ClassDB instantiate+free teardown crash

Lane: g3d · engine `4.7.2.stable.arch_linux.ed1daf0bf` · `--headless`, 60 tps.
Backends swept: GodotPhysics (`proj`), Jolt (`proj_jolt`), Dummy
(`proj_dummy`) for **every** cell.
Evidence: `corpus/live/r97-scout/` — `probes/` (9 `.gd`), `driver.py`,
`audit.py`, `runs/` (**1116 children**, rc/ms/stdout sidecars),
`RECEIPTS.md`, `manifest.sha256` (4507 pinned files), `fullrun_*.log`.

**Dead-seat reconstruction.** The r97 scout died having written all 8
probes but run none (`proj/` staged with only the census scripts, zero
`runs/`). This seat reproduced its intended first leg, found the crash its
`crashiso.gd` was clearly built to bisect, fixed one latent parse bug and
four under-powered cells (each kept as-written *and* supplemented —
`njx_*`/`sbx_*`/`qx_*`/`cbx_*` tags), and completed all declared legs.

Reps: 337 rep cells; **336 byte-identical** across `.r1..rN`. The single
difference is the crash dump's ASLR `Load address` line in `cls_proj`.
Teardown/lifecycle cells carry 6 reps (r90 bimodal lesson), all clean.

Confidence: **[O]** receipt-pinned observation, **[I]** inference,
**[?]** unknown.

---

## 0. ClassDB census — what exists headless, and the teardown trap

`classdb.gd` prints the complete census (44 candidates) and then crashes at
quit. Recovered table:

- **All 44 classes exist.** `can_instantiate=false` only for:
  `Joint3D` (abstract), `XRInterface`, `WebXRInterface`, `PhysicsServer3D`,
  `PhysicsDirectSpaceState3D`. Everything else — including `XRServer`,
  `MobileVRInterface`, `SpringBoneSimulator3D`, `PhysicalBone3D` — is
  `ClassDB.instantiate`-able in a `--headless --script` SceneTree. [O]
- **API shape corrections vs the dead scout's spot list** [O]:
  `Generic6DOFJoint3D` has no bare `set_param`/`set_flag` — it is
  `set_param_x/y/z`, `set_flag_x/y/z`. `SoftBody3D` has `set_point_pinned`,
  not `pin_point`/`unpin_point`. `get_point_transform` returns `Vector3`
  (a position), not `Transform3D` — this was a latent parse bug in the
  dead `soft.gd` (never run), fixed in place.
- **[O] `ClassDB.instantiate("XRServer")` + `free()` → deterministic
  SIGSEGV at quit**: `iso_xrs_*` 8/8 rc=134 across `proj`, `proj_jolt`,
  `proj_dummy`; `classdb.gd` itself 5/5 rc=134. `crashiso.gd` over the
  other 40 instantiable classes is clean (`iso_clean`, rc=0).
- **[O] The object returned is a distinct second XRServer**, not the
  singleton (`xr_same`: `identical=false`,
  `<XRServer#26…>` ≠ `<XRServer#34…>`). Instantiating and **leaking** it
  exits cleanly 9/9 with `ERROR: Interface not found.
  (servers/xr/xr_server.cpp:295)` + an ObjectDB leak warning (`xr_keep`,
  `xr_dbl`). Only the early `free()` poisons teardown — a
  destructor-side global-registration UAF. **[I]** mechanism.
- **HAZARD (r90 lesson applied):** 13/13 crashes observed here, so in *this*
  rig it is deterministic — but it is a teardown-ordering destructor crash,
  the same class that went bimodal under load in r90. Pin it as
  `rc ∈ {0,134}`-style envelope or "instantiate-without-free = clean /
  instantiate+free = teardown crash", never as a value invariant. Any
  harness that ClassDB-instantiates `XRServer` mid-run and frees it is
  armed.

## 1. Joint3D node lattice (`njoint.gd`, 23 cases + 4 supplements ×3 backends)

Rig: pin/hinge/slider/cone/6DOF `Joint3D` nodes between two 1 kg spheres (or
static slabs); the node-level counterpart of r90's server-RID battery.

- **[O] Binding timing is free.** `bind` (NodePaths set after tree entry) is
  byte-identical to `bindpre` (set before) on both real backends.
- **[O] `get_rid()` is valid at construction** (`getrid`: `prerid=true`
  before tree entry, GP+Jolt; `false` always on Dummy).
- **[O] A bad or absent `node_b` silently world-pins A.** `badpath`
  (nonexistent path) and `nob` (unset) are byte-identical: B free-falls,
  A swings as a pendulum about the joint origin — GP and Jolt alike, same
  world-substitution r90 measured at server level. `bindnode` (a non-body
  `Node3D` as node_a) is **silently inert** — bodies free-fall, valid RID,
  zero diagnostics in all three cases.
- **[O] Node-level teardown is clean — the r90 server UAF does not
  reproduce at node level.** `freerj` (free joint node), `freeb` (free the
  endpoint *node*), `readd` (remove/re-add), `dupclaim`, `prio_l`,
  `prio_r`: **6/6 rc=0 on all three backends**. Freeing B's node leaves the
  joint inert (`jrid=true`, A pins to world-anchor behaviour); freeing the
  joint releases both bodies. `repath` migrates the constraint — B's
  post-repath trajectory is byte-near-identical to the `freeb` ballistic
  arc while A couples to C.
- **[O] Params/flags work as named**: `hmot` drives relative ω to the
  5.0 rad/s target (±2.5 per equal-mass body); `hlim` ±0.2 caps a 3 rad/s
  spin (ω→0.07); `slider` linear limit holds B at the 0.4 bound;
  `cone` locks the pair into a rigid falling dumbbell; `g6` angular
  limit-x ±0.3 engages (`avb.x` 1.57→0.08).
- **[O] `solver_priority` produced no measurable dominance** between two
  pins claiming one body at equal anchors (`prio_l`/`prio_r` hold the body
  at the midpoint, both backends) — a null cell at this geometry, not a
  disproof.
- **Dead-probe flaws + supplements** [O]: `excl_*` spawned the spheres 0.3 m
  apart > r₁+r₂=0.2 — never overlapping, so `excl_on`/`excl_off`/`excl_def`
  are byte-identical (flag unobservable). `njx_exclx_*` at 0.15 m overlap
  **does** discriminate (divergent traces from t=4). `clamp`/`clamp0` never
  reach `impulse_clamp=0.1` with a 0.3 m teleport (identical);
  `njx_clampbig*` at −2.0 m separates them from t=4.

## 2. SoftBody3D — real on both backends, but collision is the axis (`soft.gd`)

- **[O] Both backends require an indexed mesh and fail closed without one.**
  The dead scout's unindexed `SurfaceTool` patch is rejected on GP
  (`ERROR: Soft body's mesh needs to have indices`, `godot_soft_body_3d
  .cpp:148`) and on Jolt (`mesh_indices.is_empty()` → `shared_settings`
  null, `jolt_soft_body_3d.cpp:135`) — the body then never enters a space;
  `get_point_transform` returns `Vector3()` for every index. Inert but
  rc=0. The `sbx_*` arm adds `st.index()` (9 deduped verts).
- **[O] Indexed, GP simulates — but does not collide.** `sbx_proj_drop`:
  the patch free-falls **through** the static floor to y=−10.8 at t=120.
  `sbx_proj_collide`: the 2 kg ball falls through the pinned cloth and
  rests on the floor under it (ball y=0.23; cloth untouched at ~2.9).
  Pinning works (`pin_top` corner verts hold at 3.0, centre sags to 2.93;
  `pin_mid` holds v4 at 3.0), `apply_central_impulse` lifts the COM,
  `apply_impulse(vert)` deforms asymmetrically.
- **[O] Jolt collides — barely.** `sbx_proj_jolt_drop` rests at y=0.05
  (floor top), `collide` bounces the ball off the cloth (ball y≈3.9 at
  t=60, rolls off), `pin_mid`/`pin_top` hang correctly. **But** `mass=10`
  (`sbx_..._mass_hi`) and `simulation_precision=50` (`prec_hi`) both fall
  through the same 0.1-thick floor (−16.2 at t=120) — Jolt's soft-body
  contact is penetration-limited on thin slabs. [?] mechanism
  (heavier/finer verts vs contact margin) not isolated.
- **[O] `freeme` is clean**: queue_free mid-run, 6/6 rc=0 both backends.
- **[O] Dummy: fully inert** — points read `0,0,0`, `nomesh` adds nothing
  and errors nothing.

## 3. VehicleBody3D — shared raycast-vehicle code, divergent chaos tail

- **[O] `drop` is byte-identical GP vs Jolt**: settle y=0.7299, `contact=4`
  from t=30 — the raycast wheel logic lives above the solver.
- **[O] `engine_force=400` on this rig flips the car** (contact 4→2→0, yaw
  spins past ±160°); both backends tumble, then diverge in the chaotic tail
  (GP still, Jolt still spinning at t=120) — a divergence witness, not a
  value pin.
- **[O] `suspension_stiffness` scales the rest height**: 50 → 0.7299,
  5 → 0.4566 still sinking, 0 → 0.3383 and never rests (v≈0.245 constant).
- **[O] `nowheel`** = plain rigid body (falls to 0.29, rests; no errors).
  `noroll` is a null cell (symmetric drop produces no roll torque anyway).
- **[O] Dummy: car frozen at spawn** — no gravity integration at all.

## 4. DSS query params (`dssparam.gd`, 25 cases + 2 supplements)

`intersect_ray` returns a 7-key dict on hit — `n` values are dict sizes,
not counts.

- **[O] `exclude`**: wrong RID doesn't block the hit; right RID does;
  excluding both walls → empty. Reusing one params object and mutating the
  source array after assignment behaves copy-clean (`excl_mut` h1=h2=h3=7).
- **[O] `collision_mask`**: `mask=2` sees only the layer-2 wall; `mask=0`
  sees nothing; same for `intersect_point`/`intersect_shape`.
- **[O] `collide_with_areas` defaults FALSE for rays** — the dead scout's
  `ray_areas` (default) misses; `qx_ray_areason` (explicit true) hits the
  area box at 2.75 both backends. `intersect_point` with the flag sees the
  area.
- **[O] `hit_from_inside`**: ray starting inside the sphere hits its inner
  surface (pos=origin, nrm=0) only with the flag; `hit_from_inside=true` on
  an outside-in ray changes nothing (still hits the +z surface at 0.5).
- **[O] `hit_back_faces` produced no trimesh backface hit on either
  backend**: the triangle's front face is +y (down-ray hits with the flag
  *off* too, `qx_ray_bf_downoff` nrm=+y); the up-ray into its backface
  misses with `hit_back_faces=true`. Flag inert for trimesh rays here. [?]
  whether it governs solid-shape inside faces instead.
- **[O] `intersect_shape`/`collide_shape`/`cast_motion`/`get_rest_info`**
  honour exclude+mask; `cast_motion` returns `[safe,unsafe]` fractions
  (0.359/0.363 into the enclosing sphere on GP; 0.36/0.36 Jolt);
  `max_results=2` truncates — **which** two survive is backend-ordering
  (GP: `tri,wall2`; Jolt: `tri,sph`).
- **[O] Dummy returns empty everything** (rays n=0, cast `[-1,-1]`).

## 5. CharacterBody3D edges (`cbedge.gd`, 22 cases + 2 supplements)

- **[O] `safe_margin` is a hover height**: margin 0.001 rests at 0.4997;
  0.1 rests at 0.5919 (GP) / 0.5969 (Jolt).
- **[O] `motion_mode=FLOATING` never reports floor on flat ground**: `fl=0`,
  **`wlo=1`** the whole run, and `velocity.y` free-integrates to −19.6
  while the capsule physically rests (GP+Jolt identical law).
- **[O] `floor_constant_speed` holds |v|=2.0 on the 20° downslope on GP**
  (rv=(1.8794,−0.684) constant, fl=1); **on Jolt it fails** — rv≈4.6,
  leaves the slope. Sharpest CB backend divergence.
- **[O] `up_direction=+Z` reclassifies the floor as wall** (fl=0, wlo=1)
  while resting — same on both.
- **[O] Platform inheritance**: `plat_ride` carries the rider at rv=+2.0 —
  but on Jolt `fl=0`, `n=0` the whole ride (carried without a reported
  slide collision; `pvel` still reads 2.0). `plat_leave` reports
  rv=own(1)+platform(2)=3.0; `plat_jump` keeps the inherited platform
  velocity airborne (rv.x=2 during flight).
- **[O] `realvel`**: `velocity` stays 2.0 commanded while
  `get_real_velocity`→0 against the wall — the reported quantity is actual
  displacement.
- **[O] `max_slides=1` in a V-groove**: GP leaves a persistent ±z jitter;
  Jolt settles quiet — solver-class difference.
- **[O] `recovery` (teleport 0.4 into the floor)** ejects cleanly on both;
  the probe only exercises the default `recovery_as_collision` arm —
  `recovery_as_collision=false` was declared in the comment but **never
  implemented** (dead-probe gap, flagged not silently extended).
- **Under-powered cells**: `snap_def`/`snap_big`/`snap0` are byte-identical
  because the capsule reaches the step edge only at the last tick.
  `cbx_snapx_*` (spawn 0.5 m from the edge) shows the capsule **edge-grinds
  the ledge corner** (fl=0, held at ledge height) on both backends — snap
  length still unobservable in this geometry. `ceil_on`/`ceil_off`,
  `blockwall`/`blockwall_on` are also null-pairs at these impulses
  (reported as measured-null, not disproof).
- **[O] Dummy**: `move_and_slide` doesn't move the body at all (v.y
  accumulates, position frozen, n=0).

## 6. Backend split summary

| behaviour | GodotPhysics | Jolt | Dummy |
|---|---|---|---|
| joint node binding/repath/readd/teardown | clean, inert-on-bad | same laws | RID invalid, all inert |
| missing `node_b` | silent world-pin | silent world-pin | n/a |
| soft body, indexed | simulates, **no collision** (falls through floor, ball passes through cloth) | collides; thin-floor contact breaks at mass 10 / prec 50 | inert |
| soft body, unindexed | rejected (needs indices) | rejected (empty indices) | inert |
| vehicle drop/drive | rests 0.7299; tumbles | identical drop; tumble diverges in tail | frozen |
| `floor_constant_speed` downslope | holds 2.0 | **fails** (rv 4.6, leaves slope) | no motion |
| `plat_ride` floor report | fl=1, n=1 | carried but fl=0, n=0 | n/a |
| `maxslides` groove | persistent ±z jitter | settles quiet | — |
| `collide_with_areas` ray default | false | false | n/a |
| trimesh `hit_back_faces` | inert for rays | inert | n/a |
| `XRServer` instantiate+free | teardown SIGSEGV | same | same |

## 7. Hazards

1. **XRServer instantiate+free → teardown SIGSEGV** (deterministic 13/13
   here, *mode candidate* per r90: a destructor-ordering crash can turn
   bimodal under different heap states — author as an rc envelope).
2. **Under-powered scout cells** (listed above): identical outputs are
   null measurements, not evidence of equivalence — several of the dead
   scout's cells as-written could not discriminate (`excl_*`, `clamp*`,
   `snap_*`, `ray_areas` assumption, `recovery` missing arm).
3. **`soft.gd`'s original parse bug** meant every `sb_*` cell would have
   reported parse-error rc=1 — a dead probe's unrun cells carry zero
   prior validation.
4. `rep-identical` ≠ portable: vehicle tumble tails and `maxres` survivor
   choice are backend-ordering; Jolt soft-body contact is
   mass/precision-sensitive on thin geometry.
5. Silent failures abound: bad `node_b`, non-body `node_a`, unindexed
   soft mesh, no-wheel vehicle — all valid-RID/rc=0 with engine ERRORs at
   most, none fatal.

## 8. Authorability assessment

- **Armable now**: the whole `Joint3D` node lattice (bind orders, world-pin
  fallback, inert bad-binding, clean lifecycle, all flag/param arms with
  discriminators); the SoftBody3D indexed/unindexed contract + the GP
  no-collision law + Jolt thin-floor boundary; the DSS flag matrix;
  every CB edge law except the listed null pairs; the XRServer crash as a
  crash/no-crash envelope.
- **Not yet armable**: `solver_priority` dominance ordering (null at this
  geometry), `hit_back_faces` true semantics, `floor_snap_length`
  discrimination geometry, `recovery_as_collision=false`,
  Jolt soft-body penetration mechanism.
- **Suggested next probes**: priority-ordering with asymmetric anchors;
  snap on a true cliff edge (not the seam); `hit_back_faces` against a
  solid box's inner face; soft-body vs thicker floor / contact margin.

## 9. Host cleanup

- `pgrep -af godot` on completion: **zero `r97-scout` processes**; every
  child was `timeout -s KILL` bounded and accounted for by an `.exit`
  receipt. The only godot processes alive belong to other live lanes
  (`r91-author`, `r86bt`/`r86fc` 2D work) carrying their own timeouts —
  observed, not mine, left untouched.
- Writes: `corpus/live/r97-scout/**` (gitignored) + this report. No
  `corpus/fixtures/**`, no tracked-tree edits, no commits (HEAD still
  `6420dc7`).

## Reproducing

```bash
cd corpus/live/r97-scout
python3 driver.py --batch census --jobs 8   # classdb/methods/crashiso legs
python3 driver.py --batch xr --jobs 8       # XRServer edge
python3 driver.py --batch njoint --jobs 8   # §1 (incl. njx supplements)
python3 driver.py --batch soft   --jobs 8   # §2 (incl. sbx indexed arms)
python3 driver.py --batch vehicle --jobs 8  # §3
python3 driver.py --batch dss    --jobs 8   # §4 (incl. qx supplements)
python3 driver.py --batch cbedge --jobs 8   # §5 (incl. cbx supplements)
python3 audit.py                            # rc census + rep identity
```

Single cells: `--batch <b> --only <tag-substr>`; a project is one line in
`driver.py`'s `PROJECTS`; all `proj*/` dirs are regenerated by the driver.
