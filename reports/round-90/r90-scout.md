# r90-scout — joints/constraint lattice beyond the pin

Engine `4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`, 60 tps, non-threaded.
Backends: `proj` (GodotPhysics), `proj_jolt`, `proj_dummy` (control), `proj_it8`
(solver_iterations=8). Probes/driver/audit in `corpus/live/r90-scout/`
(`driver.py`, `probes/{jprio,jfree,jflags,jend,jchain}.gd`, `audit.py`,
`RECEIPTS.md`, `manifest.sha256`). 1269 run files, 321 tags, 3 reps/tag;
317/318 rep-triples byte-identical after normalization (the one differ is a
UB cell, see EN-4). Engine-source snapshot `corpus/live/r90-scout/src/` used
for mechanism claims only, each marked [src]. Prior r89 pin findings assumed
(`reports/round-89/r89-scout.md`); this round stays on the deeper axes.

Legend: [O] observed in runs · [I] inference · [?] unresolved.
All cells below are verbatim-armable: rep = `godot --headless -s probes/<p>.gd
-- <case> <engine>` (see driver.py). Every signature was stable across
r1/r2/r3 on both real backends unless marked.

## 1. Solver priority — GP implements, Jolt drops, DUMMY refuses

[O] **PRIO-1** `jprio.gd <prioN>`: `joint_set_solver_priority` round-trip —
GP `get_after=N` for N∈{0,1,2,4,8,32,64} incl. 0 (rep-identical);
Jolt `get_after=1` for every set, plus exactly one
`WARNING: "1" is the only supported value for solver priority in Jolt.
Ignoring provided value "N".` per non-1 call (`prio2` shown); `prio1` on Jolt
emits no warning. DUMMY: `ERROR: This Physics3DServer...does not implement...`
(verb in source `dummy_physics_server_3d.cpp:90` = `"jjoint_set_solver_priority"`—
note double-j typo in engine source). Evidence `runs/{pr_proj,pr_proj_jolt,pr_proj_dummy}_prio{0..64}.r*.stdout.txt`.
Falsifier: Jolt `get_after`≠1, or warning absent on prio2.

[O] **PRIO-2** `prio_unmade`/`prio_nojoint`: priority is a RID-map default
(`mdef(JT, j, 1)`), no joint needed — `get_after=32` on both cells, GP.
Falsifier: ERR or `get_after=1`.

[O] **PRIO-3** `p32_slider`: GP slider-joint priority 32 vs 8 contact bodies —
at t=12 `gap=0.4811 lv.y≈19.39`; `proj_it8` halves the climb (+1.24 vs +2.48).
[I] mechanism: `(prio-1)×solver_iterations` extra copies of the same
wrong-direction clamp impulse; [src] `godot_step_3d.cpp:214-259` re-solves
sorted constraints, keeping joint if `joint->get_priority() <= min_priority`.
Jolt p32 trace identical to default. Falsifier: it8 ≈ it16 drift, or Jolt
gap differs from default by >0.001.

[O] **PRIO-4** `twopin_hi1`/`hi2`: two pins at x=±0.5 claim one body. GP t=31:
hi-pin side wins — `b.x≈-0.4976` (hi1) / `+0.4976` (hi2). Jolt t=31: `b.x≈±0.0556`
— neither wins, symmetric midpoint. Armable asymmetric-pin ordering test.
Falsifier: GP hi1 x>0 or Jolt hi1 |x|>0.1.

## 2. Flag matrices — per-joint honor/drop × backend

[O] **HM-1** `hmot` (hinge_motor target 5.0, impulse 50, spin at t=1):
GP `en=true tv=5.0 mi=50.0`, at t=24 `av.z≈5.0` exactly (motor hits target,
locked at rate); Jolt `flag=true`, `av.z≈0` steady — motor flag accepted,
zero effect. Armable GP-only signature `av.z≈5.0` t≥16.
Falsifier: Jolt |av.z|>0.1 at t=24, or GP av.z deviates from 5.0 by >0.01.

[O] **HM-2** `hmot_joltf`: `hinge_joint_set_flag(HINGE_JOINT_JOLT_FLAG_ENABLE_MOTOR,...)`
→ `set=ABSENT` on BOTH backends — the `*_jolt_*` native extension API
(`hinge_joint_set_jolt_flag`, `generic_6dof_joint_set_jolt_flag`,
`joint_set_enabled`, `joint_make_hinge_simple`, `joint_set_breakable`, …,
~40 fns in `jolt_physics_server_3d.h`) is NOT ClassDB-bound in this build;
`ClassDB.class_get_method_list("JoltPhysicsServer3D",true)` = 0 methods.
`hsimple` cell: `call=ABSENT` both backends. Whole Jolt-extension surface
untestable via GDScript → armable as an absence-predicate.
[src] confirmed absent from every `jolt_physics_server_3d.cpp::_bind_methods`.
Falsifier: any `set=` value other than ABSENT on either backend.

[O] **CT-1** `cone_span` (set_span 0.5→0.1 mid-run at t=8): GP diverges hard —
`av.z≈-83.12` at t=9, settles ~-5.6 (parameter-mutation instability); Jolt
re-clamps cleanly, av→0. GP armable as runaway predicate `|av.z|>50 @t=9`;
Jolt as `|av.z|<0.5 @t=24`. Falsifier: Jolt |av.z|>10 @t=9-16 or GP quiet.

[O] **S6** `slide_slider`/`slim_lin`/`slim_neg`: GP slider linear freedom —
free x-impulse → `b.x≈0.6` held, `rot.free=none`; upper limit clamps at
`x≈0.4` (`slim_lin`), `x≈-0.1` (`slim_neg`). Jolt `slide_slider`: `b.x≈0`,
body does NOT slide on x — Jolt maps slider DOF differently (spring/axis
convention); armable as backend split `GP x≈0.6 vs Jolt x≈0.0` @t=25.
Falsifier: GP x<0.55, Jolt |x|>0.05.

[O] **G6-a** `g6_default`/`g6_linfree`/`g6_linlim1`/`g6_spring_y`/`g6_anglock`:
backend split is structural — GP honors linear_limit_enabled=false as free-fall
(`g6_linfree` lv.y=-9.8 @t=24), Jolt's `g6_default`/`g6_anglock` bodies
free-fall (y<2.5, lv.y<0) while GP holds `b=(0,2.5,0)`. `g6_anglock`: both
backends DO engage the ±0.3 angular limit (`bx≈(0.9553,0.2955,0)` = 0.3 rad
clamp, rep-identical) — angular limit real on both, linear flags split.
Falsifier: either backend `bx.x∉[0.95,0.96]` @t=24.

[O] **SLP** `slider_get` on a pin joint → `p0..p15=0.0` + no ERR either backend
(wrong-type reads silent-zero on Jolt too — consistent with r89 note).
`slang_def/wide`: GP lower=-0.05/upper=+0.05 clamp z-tilt to ~0 (wide 0.6/0.6
allows tilt `.27,.65`); Jolt ignores angular_limit both widths (tilt 0 both).

## 3. disable-collision-between-nodes + break-free

[O] **DC-1** GP default `joint_is_disabled_collisions_between_bodies()` =
**true stored but NOT installed** — `prio32` contact-fight still climbs
(gap drifts, lv.y +19.4). Only an explicit `joint_disable_collisions_between_
bodies(j,true)` (`pnocoll32`) or removing the shape (`pnoshape32`) stops it:
`isdis=true` after call; body stays `y=2.5` exact all frames. [src]
`godot_physics_server_3d.cpp` joint_make_* never installs the exception; only
the setter does (`godot_constraint_3d.h` default `_disable_collisions=true`
is a dead default). Armable: `pnocoll32` `b=0.0000,2.5000,0.0000` every frame.
Falsifier: GP prio32 stable (gap<0.01 @t=12) without explicit disable.

[O] **DC-2** Jolt: `isdis=false` stored default, `coll_e=true` probe shows
`PhysicsBody3D.add_collision_exception_with` still fires on jointed bodies;
`pnocoll` sets isdis=true + installs exceptions (no contact fight — but Jolt
had no fight anyway because its gap is stable). DUMMY: ERR not-implemented.
Falsifier: Jolt isdis≠stored, or coll_e=false for set collision exceptions.

[O] **BF-1** break-free: NO bound API on either backend in 4.7.2 —
`joint_make_*`/flags carry no break_force; `joint_set_breakable` is
Jolt-extension-only (ABSENT, HM-2). Axis CLOSED: unarmable via public API.
[r89 concurs: no break cell was found then either.] Falsifier: existence of
any `joint_set_breakable`/`break_force` in `class_get_method_list`.

## 4. Freed endpoints — crash taxonomy (GP) vs inert-joint (Jolt)

[O] **EN-1** GP `freeb`/`freeb_dyn`/`freea`: freeing an endpoint body while
the joint is reachable from a live dynamic body → SIGSEGV at next physics
step (rc=134, `dumped core`, GodotConstraint3D::solve_linear_constraint
frame) — deterministic 3/3 reps each. `freea` (static endpoint freed) same.
Falsifier: any of these three GP cells exits 0, or Jolt crashes.

[O] **EN-2** GP `freeb_ops`: steps fine while dead (gap drifts = joint inert
on live side, gap grows 1.06→1.27), then crash at `joint_clear`/`free_rid(j)`
— destructor walks `body->remove_constraint` on freed B (deferred UAF).
3/4 runs SIGSEGV; `.r1` survived to DONE (`cleared type=5`, then
`ERROR: Invalid ID` on double-free) — **probabilistic UB, not deterministic**:
armable only as `rc∈{0,134}`, not a fixed rc. [src] `~GodotJoint3D` iterates
`bodies[i]->remove_constraint` with no liveness check.
Falsifier: any contract that treats this cell as deterministic.

[O] **EN-3** Jolt same cells: rc=0 all reps. Freed endpoint → joint goes
inert (`freeb` C free-falls, gap grows), ALL joint ops still work:
`get_type=0 get_prio=1 pin_param=0.3(default) isdis=false cleared type=5`.
Second `free_rid(b)` → `ERROR: Failed to free RID: The specified RID has no
owner.` (Jolt) vs `ERROR: Invalid ID.` (GP, when it survives that far).
Falsifier: Jolt rc≠0 on freeb/freeb_dyn/freea/freeb_ops.

[O] **EN-4** `freej_then_b`/`detachb_free`: free joint BEFORE body → clean
rc=0 both backends (teardown-order safe). `detachb` then free B + free J →
rc=0 both. Armable safe-teardown contract. Falsifier: rc≠0.

[O] **EN-5** `freeb_world`/`freea_world`/`both_world`: `joint_make_pin(j,A,v,
RID(),v)` binds to World on BOTH backends — `made type=0`, body falls while
bound to world (gap≈0 held on GP `both_world`: `b=(0,2.5,0) av=0` held by
two world-pins); Jolt freeb_world same `type=0` arm. GP substitutes a static
global body internally; Jolt takes `body_b=nullptr`. [src] `jolt:1282-83`
has no `ERR_FAIL_NULL(body_b)`.
Falsifier: `made` step ERRs on either backend.

## 5. Chains — mixed/hinge/offset swing all stable; freed-mid crash

[O] **CH-1** `chain3_mixed` (pin+hinge+slider), `chain3_swing` (3 pins),
`chain3_hinge` (pin+hinge+hinge), `chain3_off` (offset pivots): all rc=0,
rep-identical on all 3 backends. GP e.g. chain3_mixed t=30
`c=(-0.6396,-0.3221,1.7553) lv=0` swung out and parked; `chain3_off`
`c=(-2.3946,0.0373,0.1408)` settled asymmetric. Jolt same traces (e.g.
chain3_mixed `c=(-0.6396,-0.3221,1.7553)` — identical coordinates to GP).
Armable steady-state witnesses: `chain3_swing` GP t=30 `b≈(0.937,-0.026,-0.155)`
`c≈(0.937,-0.026,-1.155)`. Falsifier: |Δpos|>0.02 between reps/backends vs
these witnesses (Jolt==GP coincidence is itself falsifiable if it diverges).

[O] **CH-2** `chain3_freemid`: free middle body of a 3-body chain → GP
SIGSEGV at the next step (rc=134, 4/4 files); Jolt & Dummy rc=0 — on Jolt C
free-falls (joints inert). Extends EN-1: reachability through C suffices.
Falsifier: GP rc=0 or Jolt rc≠0.

## Falsification list (r90 disproved / bounded)

F1. "Solver priority is honored on Jolt": `prio{0..64}` all `get_after=1`
+ warn per non-1 call. Dropped, not honored.
F2. "GP collision-disable default protects jointed bodies": stored `true`
but never installed (`prio32` still climbs); explicit setter required.
F3. "Hinge motor flag works on Jolt": accepted (`flag=true`) yet `av.z≈0`;
GP hits `tv=5.0` exactly.
F4. "Jolt native extension API is GDScript-callable": every `*_jolt_*`/
`joint_*` extension fn `ABSENT`; method list = 0.
F5. "Generic6DOF is a joint on Jolt in this geometry": default & anglock
bodies free-fall; only the ±0.3 angular clamp engages.
F6. "Freed-endpoint is a safe typed error": GP SIGSEGV (EN-1/CH-2) or
deferred-UAF at teardown (EN-2, probabilistic).
F7. "Setting endpoint RID to RID() is an error": binds to World on both
backends (`made type=0`).
F8. "GP cone_span mutation is well-behaved": `av.z≈-83` transient spike;
Jolt clean. Parameter mutation mid-solve is backend-dangerous.
F9. "freeb_ops is a deterministic crash": 3/4 SIGSEGV, 1/4 DONE — UB.
F10. "`joint_make_hinge_simple` exists": ABSENT both backends.

## Open / for the next seat

[?] GP `prio0` semantics: stored `0` is accepted; effect untested (priority 0
may mean "first pass only" or fall out of the sort key — source ambiguous).
[?] `g6_spring_y` on Jolt reads `k=80,d=2` via `generic_6dof_joint_get_param`
on FLAG-indices 0/1 — looks like real Jolt spring params leaking through the
param channel (SPRING_EQUILIBRIUM_POINT=0); whether that mapping is blessed
or enum-collision unverified.
[?] Jolt slider axis: `slide_slider` holds x=0 while GP slides — Jolt maps
the slider linear DOF on a different local axis or couples it to the spring
param (s15=80 reads back); needs an axis-rotated probe pair.
[?] EN-2's `joint_clear` UAF is probabilistic (1/4 survived): whether the
survival correlates with allocator state across reps is untracked.
[?] r89-pin overlap: I did not re-run r89's `jpin_*` force/impulse cells —
r90 covered make/flags/prio/teardown only, per scoping.
[?] Threaded physics (`run_on_separate_thread=true`) crash class likely
differs; all cells here are non-threaded.
