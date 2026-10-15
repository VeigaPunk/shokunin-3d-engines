# r89 scout — `PhysicsDirectBodyState3D` contact family, `_integrate_forces` interior rules, the joint family, cross-space handles, the sleeping body

Lane: g3d · engine `4.7.2.stable.arch_linux.ed1daf0bf` · `--headless`, 60 tps.
Backends swept: GodotPhysics (`proj`), Jolt (`proj_jolt`), Dummy (`proj_dummy`),
plus `proj_it1`/`proj_it64`/`proj_jolt_vs1` (solver-iteration bakes).
Evidence: `corpus/live/r89-scout/` — `probes/`, `driver.py`, `runs/*` (795
children, **795 rc=0**), `manifest.sha256`, `RECEIPTS.md`, `audit.py`,
`sum_ifrules.py`. `corpus/fixtures/` and `reports/round-88/` untouched.

Reps: 183 cells carry a `.r1/.r2/.r3` triple. 29 differ in raw bytes, **0 differ
after normalizing the engine tick stamp** (`pf`, `seq`, row index, idle-frame F
multiplicity) — the physics observables are rep-stable; see `RECEIPTS.md`.

Confidence labels: **[O]** observation (receipt-pinned, rep-stable),
**[I]** inference, **[?]** unknown / not decided by these cells.

---

## 0. The intra-tick phase lattice (the foundation for §1 and §2)

Every row in `contact.gd` / `ifrules.gd` carries `seq`, a counter bumped at the
top of *every* callback, so the order inside one tick is read off the receipt
instead of inferred:

```
CTX p=IF pf=14 seq=55 …      # _integrate_forces
CTX p=E  pf=14 seq=56 …      # _physics_process
CTX p=F  pf=14 seq=57 …      # _process (idle)
```

**[O] Within one physics tick the order is `_integrate_forces` → `_physics_process`
→ `_process`** (`ct_proj_ifbuf`, `ct_proj_jolt_ifbuf`, all reps; identical seq
ordering on both real backends). The deferred D position (`await physics_frame`)
resumes **before** `_physics_process` (`ct_proj_outside`: `p=D pf=8 seq=30` then
`p=E pf=8 seq=31`).

**[O] `_integrate_forces` is a PRE-step view, not a post-solve view.** At the same
`pf`, IF and E return byte-identical `tr`, `lv` and contact rows, and F(pf=k)
equals IF/E(pf=k+1):

| position | reads the state left by | contact buffer |
|---|---|---|
| IF(pf=k) | step k−1 | post-step k−1 record |
| E(pf=k) | step k−1 | post-step k−1 record |
| D(pf=k) | step k−1 | post-step k−1 record |
| F(pf=k) | step k | post-step k record |

So **the current step's contact data is only readable at F (idle) or at the next
tick's IF/E/D** — IF is exactly as stale as E. This falsifies the common
"read contacts inside `_integrate_forces` to get the current step's contacts"
assumption on this build. `Engine.get_physics_frames()` is the reliable tick
stamp at all four positions.

---

## 1. The contact surface (`PhysicsDirectBodyState3D`)

### 1.1 Arm table (verbatim-armable cells)

Each cell = one child process; `--path <proj>` selects the backend.

| # | command (from `corpus/live/r89-scout/`) | expected signature (verbatim) | falsified if |
|---|---|---|---|
| 1.1 | `python3 driver.py --batch contact --only ifbuf` | `p=IF pf=13 cc=0` / `p=F pf=13 cc=1` (first record at F); `p=IF pf=14 cc=1` and `p=E pf=14 cc=1`; `p=F pf=14 … imp=-0.0000,2.1022,-0.0000` | IF(pf=13) shows cc=1, or IF(pf=k) ≠ E(pf=k) |
| 1.2 | `… --only outside` | `p=D pf=k` ≡ `p=E pf=k`; `p=F pf=13` shows the post-step-13 record while D/E at pf=14 show the same record | D differs from E |
| 1.3 | `… --only decay` (GP) | teleport out at E(pf=20): `cc=1` at pf=20, `cc=0` from pf=21; teleport in at pf=27 (y=0.0): `cc=0` at pf=28, `cc=1` from pf=29 | the buffer clears in the same tick it separates, or appears in the penetration tick |
| 1.4 | `… --only decaypen` (y=−0.02) | record appears at **pf=28** (one step earlier than 1.3) on GP; Jolt shows pf=28 in both | GP shows the same timing in 1.3 and 1.4 |
| 1.5 | `… --only nomax` | `cc=0` at every sampled tick while the ball rests at `tr=-0.0100` | any non-zero count without the opt-in |
| 1.6 | `… --only idx_oob` | one `ERROR: Index p_contact_idx = 1 is out of bounds (body->contact_count = 1).` per getter call; all defaults; `cc_after=1` | a crash, a silent out-of-range read, or a mutated count |
| 1.7 | `… --only idx_insane` | `ERROR: … = 2147483647 is out of bounds …`; rc=0 | rc≠0 |
| 1.8 | `… --only sleepbuf` / `--only sleepfrozen` | asleep: handle answers, buffer retained; see §5 | buffer cleared on sleep |

### 1.2 Record shape and identity (both real backends) **[O]**

Resting sphere (r=0.5, mass 1) on a static box, `max_contacts_reported=8`, at
E(pf=20): `cc=1`, and the 11 getters read
`lp=(0,-0.5100,0)` (GP) / `(0,-0.5110,0)` (Jolt), `ln=(0,1,0)`,
`imp=(∓0.0000,0.1633,∓0.0000)`, `ls=0`, `lv=(0,-0.1633,0)`,
`col=<floor RID>`, `cp=(0,-0.5000,0)`, `cid=<floor instance id>`,
`cob=obj:StaticBody3D` (the live node), `csh=0`, `cv=(0,0,0)`.
The floor RID, the instance id and the Object identity all round-trip for a
node-created `StaticBody3D`; the collider-side velocity is 0 for a static body.
GP prints negative zeros where Jolt prints `0.0000`.

**[O] Opt-in is mandatory**: with `body_set_max_contacts_reported` left at its
default 0 the count reads 0 at every position while the body is visibly resting
(1.5) — re-binds r87's `step_stamp` claim on a fresh scene.

### 1.3 The impulse is one solve behind (GP) / same-step (Jolt) **[O]**

Same geometry, first contact at step 13 (F(pf=13) is the first record):

| | GP | Jolt |
|---|---|---|
| `imp` in the first record (F pf=13) | `(-0.0000,-0.0000,-0.0000)` | `(0.0000,2.1022,0.0000)` |
| `lv` (contact-local velocity) same record | `(0,-2.1022,0)` | `(0,-2.1022,0)` |
| `imp` in the next record (F pf=14) | `(-0.0000,2.1022,-0.0000)` | `(0.0000,0.1633,0.0000)` |

So on **GP the record's `impulse` field always holds the impulse applied during
the PREVIOUS step's solve** (a first-contact record reads exactly 0; the impact
impulse appears in the following record; the steady-state record reads
`0.1633 = m·g·dt`), while **Jolt's record holds its own step's impulse**.
`get_contact_local_velocity_at_position` is the *current* pre-solve relative
velocity on both backends and equals the impulse magnitude at an impact
(`|imp| = |Δv|·m`). This is the mechanism behind r87's `body_tier` zero-impulse
cell; the value is not "always zero" on GP — it is one solve late.

Third independent confirmation (`decay`): the impact impulse `1.4602` appears at
E(pf=30) (the record for step 29) and the resting support impulse `0.1633` from
E(pf=31) on; the first record (E(pf=29)) reads 0.

### 1.4 Record lifetime: appears with the pair, clears one step after separation **[O]**

- Continuous motion into contact: recorded in the **same** step (the ball's AABB
  is inside the broadphase margin before the step).
- Teleport to the **exact touching height** (centre y=0.0): the record appears
  **one step later** than the penetration step on **GP** (1.3), and the
  penetrating variant (1.4, y=−0.02) removes that extra step — **[I]** GP's
  broadphase pair test excludes the exact AABB touch; Jolt's does not.
- Teleport **out** of contact: the buffer still shows the old record for the
  rest of the tick in which the teleport was written, and is **empty from the
  next step** (E(pf=20) `cc=1` → E(pf=21) `cc=0`).

### 1.5 Index bounds — a typed refusal, never a crash **[O]**

Every index outside `[0, cc)` — `-1`, `cc`, `1048576`, `2147483647` — prints one
engine ERROR **per getter call** and returns a default; `cc` is unchanged; rc=0
on all three backends, all reps. Error text is backend-specific:

- GP: `ERROR: Index p_contact_idx = <i> is out of bounds (body->contact_count = <cc>).`
- Jolt: `ERROR: Index p_contact_idx = <i> is out of bounds ((int)body->get_contact_count() = <cc>).`
- Dummy: silent, rc=0.

Defaults: Vector3 zero, `get_contact_collider` → `RID(0)`,
`get_contact_collider_object` → null, `get_contact_collider_id` → 0,
`get_contact_collider_shape` → 0, and **`get_contact_local_shape` → −1 on GP vs
0 on Jolt** (the only getter whose out-of-range default splits; re-binds r87).
The out-of-range `-1` reaches the Jolt guard message as `4294967295`.

---

## 2. `_integrate_forces` interior rules

Setup: sphere free-falling from y=3, gravity on; the write happens at the 4th IF
call (tick 4); each row reports the same-turn readback through the same handle,
the server read at the next E, and the state 2 ticks later.

### 2.1 Arm table

| # | command | expected signature | falsified if |
|---|---|---|---|
| 2.1 | `--batch ifrules --only linvel` | `IFW wrote linvel=1,2,3 readback=1.0000,2.0000,3.0000`; `rel=1 srv_lv=1.0000,2.0000,3.0000`; motion integrates (`tr` rises) | the write is invisible at rel=1 |
| 2.2 | `--only cforce` | `rel=1 srv_lv=…-0.652` (unchanged), `rel=2 srv_lv=0.000,0.186,0.000` | the force shows at rel=1 |
| 2.3 | `--only sleep` | GP `rel=1 srv_lv=(0,-0.652,0) sleep=true`; Jolt `rel=1 srv_lv=(0,0,0) sleep=true` | the velocity is not zeroed on Jolt / not kept on GP |
| 2.4 | `--only integrate_forces_reentrant` | no error; `rel=1 srv_lv=(0,-0.8137,0)` vs the baseline `(0,-0.6517,0)` — one extra gravity step | no velocity effect |
| 2.5 | `--only body_set_space` | `srv_space=RID(0)`; from rel=1 on the body is frozen (`tr=2.9728`, `lv=-0.6517` forever) | the body keeps integrating |
| 2.6 | `--only outside_write` | the same velocity write from `_process` lands and integrates identically | an IF-only privilege exists |

### 2.2 Per-member verdict table (GP ≡ Jolt unless noted) **[O]**

| member | same-turn readback | next-E server read | effective in motion | verdict |
|---|---|---|---|---|
| `set_linear_velocity` | reflects it | reflects it | yes (1,2,3 integrated) | honored now |
| `set_angular_velocity` | reflects it | reflects it | yes | honored now |
| `set_transform` | reflects it (0,8,0) | reflects it | yes (falls from 8) | honored now |
| `apply_central_impulse` / `apply_impulse` | `lv=(0,2.3483,0)` (impulse − the step's gravity) | same | yes | honored now |
| `apply_torque_impulse` | `av=(0,0,30)` | same | yes | honored now |
| `apply_central_force` / `apply_force` | **not** visible | visible one step later | yes (`rel=2 lv=+0.186`) | **deferred one step** |
| `apply_torque` | not visible | one step later | yes (`rel=2 av=(0,0,10)`) | **deferred one step** |
| `add_constant_force` / `set_constant_force` | `get_constant_force()` reflects it | acts from the next step (`rel=2 lv=-0.714` vs baseline −0.814) | yes | deferred one step |
| `set_constant_torque` | reflects it | acts from the next step (`av=1.167`) | yes | deferred one step |
| `set_sleep_state(true)` | `is_sleeping()=true` | `BODY_STATE_SLEEPING=true` | body frozen; **GP keeps `lv`, Jolt zeroes it** | honored now (backend split) |
| `set_collision_layer/mask` | reflects it | — | n/a | honored now |
| `PhysicsServer3D.body_set_state(lv)` | server + handle agree | same | yes (rises) | honored now |
| `get_space_state()` | returns `…DirectSpaceState3D` | — | — | legal inside IF |
| `PhysicsServer3D.space_get_direct_state` | returns a live object | — | — | legal inside IF |
| `PhysicsServer3D.body_get_direct_state(self)` | `identity=true` | — | — | legal, same singleton (r87 law re-bound) |
| `state.integrate_forces()` (re-entrant) | no error | — | **double-integrates the velocity** (`rel=1 lv=-0.8137` vs −0.6517) | not refused, silent extra integration |
| `body_set_state_sync_callback` | accepted | fires from the next tick (`IFW ss2_callback pf=6`) | — | honored |
| `body_set_force_integration_callback` | accepted (1-arg callable) | no observable effect in the window | [?] | legal |
| `body_set_space(RID())` | `srv_space=RID(0)` | body frozen at its last state | yes | honored (detach stops integration) |

**No member is refused inside `_integrate_forces` on either real backend** — no
`Function blocked during in/out phase` class was observed for any of the 23
members. The "IF is the legal write path" claim is true but **not exclusive**:
the identical velocity write from `_process` (2.6) lands and integrates just as
well on non-threaded backends (r87's out-of-phase race class still applies under
`run_on_separate_thread`).

**[O] Dummy floor: `_integrate_forces` never fires.** Every `if_*_dummy_*`
receipt is header + fetch only (`out=244…284`); no member is even reached.

---

## 3. The joint / constraint family

`joint_create()` → `joint_make_{pin,hinge,slider,cone_twist,generic_6dof}`;
anchor A static at (0,3,0), body B dynamic at (0,2,0), free space, no floor.
`joint_get_type()` after each make: **pin 0, hinge 1, slider 2, cone 3, 6dof 4**
on GP and Jolt (Dummy reports 0 for every make). An **unmade** joint reads
**type 5 (`JOINT_TYPE_MAX`)** and `solver_priority=1` on both real backends.

### 3.1 The pin stiffness table (the constraint witness = anchor gap) **[O]**

| variant | GP gap at t=12 | GP `lv` | Jolt gap at t=12 | Jolt param readback |
|---|---|---|---|---|
| `pin` (defaults) | **0.8900** (equilibrium, not 0) | 0 | 0.2051 (still converging) | p0=0.3 p1=1.0 p2=0.0 |
| `pinsoft0` (softness 0) | **1.0000 — frozen, `lv=0`** | 0 | 0.2051 | **readback stays 0.3** |
| `pinsoft1` (softness 1) | **0.0000 — rigid** | 0 | 0.2051 | **readback stays 0.3** |
| `pinclamp` (clamp 1.0) | 0.8900 (≥ m·g·dt, no effect) | 0 | 0.2051 | readback 0.0 |
| `pinclamp2` (clamp 0.01) | **1.0036 — the clamp binds, the body sags** | −0.0364 | 0.2051 | **readback stays 0.0** |
| `pin_nomake` (control) | gap grows 1.0 → 1.1490 | −1.62 | same | — |

- **[O] A default pin is a soft constraint, not a rigid one**: it settles at a
  0.89 m offset under a 1 g load on GP. Softness 1 closes it exactly (0.0000);
  softness 0 produces a **velocity-level constraint with no position bias** —
  the body is frozen at the initial 1.0 offset with exactly zero velocity.
- **[O] `pin_nomake` is the falsification control**: with the joint created but
  never made, the body falls freely, so the witness measures the joint.
- **[O] The impulse clamp (p2) is a real ceiling**: 1.0 (above the 0.1633
  support impulse) is indistinguishable from the default, while 0.01 makes the
  joint sag — gap 1.0001 → 1.0036 over 12 ticks with `lv` −0.0033 → −0.0364.
- **[O] Jolt ignores `pin_joint_set_param` writes entirely** (the getter returns
  the default in every variant) and its behaviour is identical across the three
  variants — but see §3.2: the Jolt drop is per-param, not wholesale.

### 3.2 Per-param round-trip (`--batch paramrt`), set 0.5 → read back **[O]**

| type | GodotPhysics | Jolt |
|---|---|---|
| pin (p0 bias, p1 damping, p2 clamp) | all honored (0.5) | **all three dropped** (0.3 / 1.0 / 0.0) |
| hinge (p0..p7) | all honored | p1 LIMIT_UPPER, p2 LIMIT_LOWER, p6 MOTOR_TARGET_VELOCITY, p7 MOTOR_MAX_IMPULSE honored; p0 BIAS, p3 LIMIT_BIAS, p4 LIMIT_SOFTNESS, p5 LIMIT_RELAXATION **dropped** |
| cone (p0..p4) | all honored | p0 SWING_SPAN, p1 TWIST_SPAN honored; p2 BIAS, p3 SOFTNESS, p4 RELAXATION **dropped** |
| slider (p0..p21) | **no index round-trips (all read 0.0)** and every getter emits `Condition "joint->get_type() != JOINT_TYPE_CONE_TWIST" is true. Returning: 0` | p0/p1 (linear limits) honored; p2/p4/p5/p7/p8/p10/p11/p12/p13/p15/p18/p19/p21 read back at their non-zero defaults (softness/rest/damping/angular-limit class) — a per-index mix |
| g6dof (axis 0, p0..p21 + flags) | all honored (GP defaults: motor force limit 0.0, angular limits ∓1e30) | p2/p4/p13/p14/p15 dropped, the rest honored (defaults: motor force limit 3.4e38 = FLT_MAX, angular limits 0.0); all 6 flags round-trip |
| Dummy | every write dropped, every read 0.0 | — |

**[O] The two real backends expose different default tables** (hinge
`LIMIT_UPPER/LOWER` = ∓π on GP vs 0/0 on Jolt; cone `SWING_SPAN` = π/4 on GP vs
0 on Jolt; `SOFTNESS` 0.0 vs 0.8; slider all-zero vs a 0.7/1.0 default set;
g6dof "unbounded" sentinel ±1e30 on GP vs 0.0 on Jolt and FLT_MAX for the motor
force limit).

**[O] `joint_make_generic_6dof` is a silent no-op on Jolt**: the Jolt `g6dof`
witness trace is byte-identical to the `pin_nomake` control (gap 1.0027 → 1.1220,
`lv` −0.1633 → −1.4602) while `joint_get_type` still reads 4. On GP the same
call constrains (gap → 0.8900). **[O] `joint_is_disabled_collisions_between_bodies`
defaults differ: true on GP, false on Jolt** (Dummy false).

### 3.3 Solver interplay, mid-run toggle, freed RIDs **[O]**

- **`joint_set_solver_priority`**: `get` returns **1** by default; `set 32` is
  honored on GP (`get_after=32`) and **ignored on Jolt** (`get_after=1`). On GP
  raising it mid-run changes the physics drastically: the gap jumps
  0.8897 → 0.6230 and the body acquires `lv=+16.0145`, then settles into a
  steady `lv≈+11.65` climb — a large, rep-stable behavioural effect.
- **`physics/3d/solver/solver_iterations` = 1 vs 64 does not move the joint**:
  the gap/transform traces are identical tick for tick; the only differences are
  the header and the printed velocity residuals (`-0.0000` vs `0.0001`/`-0.0001`,
  i.e. ≤1e-4). `jolt_physics_3d/simulation/velocity_steps=1` is identical to the
  default 10 apart from the header. The pin's convergence is **not**
  iteration-limited in this scene; the setting does not buy joint accuracy here.
  (A negative result for joints — not a claim that the setting is inert for
  contact solving.)
- **`joint_clear` mid-run releases immediately**: clearing at E(pf=6) leaves the
  gap at 0.8897 for that tick and the body starts falling in the very next step
  (`pf=7 lv=−0.1633`, gap grows to 0.9873 by pf=14). `joint_get_type` afterwards
  reads **5** (MAX). Double `joint_clear` is a silent no-op; the RID is
  **reusable** (`joint_make_pin` on it re-arms it, `remade_type=0`).
- **Freed-joint RID = typed refusal, no crash** (rc=0 on all three backends,
  both reps): `free_rid(j)` then any call prints `ERROR: Parameter "joint" is
  null.` (GP and Jolt) and returns a default; `joint_make_pin` on a freed RID
  prints a *different* parameter name per backend — **GP `prev_joint`, Jolt
  `old_joint`** — and returns without a script error. Dummy is silent.
- **[O] With identity refs all five `joint_make_*` variants collapse to the same
  distance behaviour** on both backends (slider/cone/hinge traces ≡ the pin
  trace). The type is observable only through `joint_get_type` and the param
  tables; **rotational freedom is not characterized by this round** [?].

---

## 4. Cross-space handle validity

| # | command | expected signature | falsified if |
|---|---|---|---|
| 4.1 | `--batch cross --only twoworld` | `dssA`/`dssB`/`fetchB` all non-nil; `a_ne_b=true`; `bdsA_space_is_A=true`, `bdsB_space_is_B=true`, `bdsA_space_is_B=false`; ray in B hits `-9.7…` while A hits `0.7…`; both balls fall | any handle resolves to the other world's space |
| 4.2 | `--only bsfroma` | raw space fetch + `bds` non-nil; `ident=true`; `raw_ne_A=true`; ray in the raw space hits `-3.0…` while A hits `0.7…`; the raw body is simulated | the raw space does not step, or the handles cross |
| 4.3 | `--only boxsize` | server `shape_set_data(box,(1,1,1))` → ray hit **y=1.0000**; node `BoxShape3D.size=(1,1,1)` → ray hit **y=0.5000** | the two agree |

**[O]** A second `World3D` (a `SubViewport` with its own world) and a raw
`space_create()` + `space_set_active(true)` space are both fully serviceable from
the main world's `_physics_process`: `space_get_direct_state` and
`body_get_direct_state` answer for bodies in the other space, each body handle's
`get_space_state()` is **the same object** as its own space's direct state and
**not** the other world's, and each space answers its own queries (ray heights
−3.0/−9.7 vs 0.7). Both worlds step on the same physics ticks. **[O]** The
server box-shape API and the node box resource use **different size
conventions**: `shape_set_data` takes half-extents (ray hits y=1.0 for
`(1,1,1)` at y=0) while `BoxShape3D.size` is the full size (ray hits y=0.5).

---

## 5. The sleeping-body direct state

| # | command | expected signature | falsified if |
|---|---|---|---|
| 5.1 | `--batch sleep --only reads` | `if_calls_total=42` at `slept_at=43` (the callback stops on the sleep tick); the fetch while asleep returns `obj` and does **not** wake it; `hdl_sleep=true srv_sleep=true` for 6 further ticks | the callback keeps firing, or a read wakes the body |
| 5.2 | `--only wakewrite` | `same_turn readback_lv=0.0000,0.0000,2.0000 hdl_sleep=false`; the body moves (GP `tr_y=0.2012`, Jolt `0.2005`) | the write is dropped or the body stays asleep |
| 5.3 | `--only sleeptoggle` | same turn `hdl_sleep=false srv_sleep=false`; **GP re-sleeps at the next tick** (`toggle+1 srv_sleep=true`), **Jolt stays awake but frozen** (`tr` and `lv` unchanged for 8 ticks) | both backends behave alike |
| 5.4 | `--only xformwrite` | same turn `tr=(0,0.99,0) hdl_sleep=false`; both backends then fall (`tr_y≈0.892`, `lv≈−1.299`) | the transform write is refused |
| 5.5 | `--only sync` | `ss_count=0` for 5 ticks after `body_set_state_sync_callback` while asleep | the callback fires while asleep |

- **[O] A slept body's handle answers every read** (transform, velocity, angular
  velocity, contact count, `is_sleeping`) and the **fetch itself never wakes it**.
- **[O] The contact buffer is retained, not cleared, on sleep** (`sleepbuf`:
  `cc=1`, `imp=(−0.0000,0.1633,−0.0000)`, `lv=(0,−0.1633,0)` frozen while asleep).
  It is a **stale** buffer, not an empty one.
- **[O] Direct writes DO wake it** (velocity 5.2 and transform 5.4 on both
  backends), and the write takes effect (the body moves). `set_sleep_state(false)`
  alone does not keep it awake on GP (it re-sleeps within one tick) while Jolt
  leaves it awake-but-frozen.
- **[O] `sleepfrozen` — a backend split on wake propagation**: teleporting the
  **floor** under a sleeping ball wakes it on GP (`srv_sleep=false`, the ball
  then falls) but **not on Jolt** (`srv_sleep=true`, `tr` frozen at −0.0110 and
  `cc=1` retained for the rest of the run). GP propagates a transform write in
  the space to a sleeping neighbour; Jolt does not.
- **[O] Dummy floor**: the ball never sleeps (`BODY_STATE_SLEEPING` answers Nil,
  the handle's `is_sleeping()` answers false), `cc=0`, transform identity.

---

## 6. Backend split summary (one row per measured divergence)

| axis | GodotPhysics | Jolt | Dummy |
|---|---|---|---|
| first-contact record's `imp` | 0 (previous-solve lag) | the impact impulse (same step) | n/a |
| exact-touch teleport → first record | +1 step late (exact touch only; the penetrating variant removes it) | identical timing in both variants | n/a |
| `get_contact_local_shape` out-of-range | −1 | 0 | 0 |
| out-of-range error text | `(body->contact_count = n)` | `((int)body->get_contact_count() = n)` | silent |
| `set_sleep_state(true)` inside IF | keeps `lv` | zeroes `lv` | callback never fires |
| write waking a sleeping body | ball writes **and** floor writes | ball writes only | n/a |
| `set_sleep_state(false)` on a rested body | re-sleeps next tick | stays awake, frozen | n/a |
| joint param writes | honored (except slider) | per-param mix (solver tuning dropped) | all dropped |
| `joint_set_solver_priority` | honored (+large behavioural effect) | ignored | ignored |
| `joint_make_generic_6dof` | constrains | **no-op** | no-op |
| jointed-body collision default | disabled (true) | enabled (false) | false |
| joint param defaults | ∓π / π/4 / ±1e30 | 0 / 0 / FLT_MAX | 0 |
| freed-joint guard name on `make_pin` | `prev_joint` | `old_joint` | silent |
| server vs node box size | — (both backends: half-extents vs full size) | — | — |

---

## 7. Falsification list (claims this round tested)

1. **"Read contacts inside `_integrate_forces` to get the current step's
   contacts."** FALSIFIED — IF ≡ E (pre-step, previous record); only F (idle) or
   the next tick's IF/E/D see the current step's record (§0, §1.1).
2. **"`get_contact_impulse` is always zero on GodotPhysics."** FALSIFIED as a
   general claim — it is zero only in the *first* in-contact record; from the
   next record on it carries the real impulse (2.1022, 1.4602, 0.1633) — and it
   is one solve late, which is what r87's first-step sample happened to see
   (§1.3).
3. **"An out-of-range contact index returns a value or crashes."** FALSIFIED —
   typed ERROR + default, rc=0 at every index including INT_MAX (§1.5).
4. **"A sleeping body's contact buffer is empty."** FALSIFIED — retained/stale
   on both backends (§5).
5. **"A direct-state read wakes a sleeping body."** FALSIFIED — the fetch and
   all reads leave `is_sleeping` true (§5.1).
6. **"A sleeping body cannot be written through the direct state."** FALSIFIED —
   velocity and transform writes land, take effect, and wake the body (§5.2/5.4).
7. **"`set_state` inside `_integrate_forces` is the only legal write path."**
   FALSIFIED for the write itself — the identical velocity write from `_process`
   lands and integrates (non-threaded; the threaded race class is r87's) — but
   the interior rules ARE member-specific: forces/constant forces/torques are
   **deferred one step** while velocities/impulses/transform are immediate
   (§2.2).
8. **"Jolt honors the same joint param writes as GodotPhysics."** FALSIFIED —
   per-param drop list in §3.2, and `joint_set_solver_priority` is ignored.
9. **"`joint_make_generic_6dof` creates a working constraint on every backend."**
   FALSIFIED on Jolt (byte-identical to the no-joint control) (§3.2).
10. **"A freed joint RID crashes the server."** FALSIFIED — typed null-parameter
    refusal, rc=0 on all three backends (§3.3). (Contrast: freed *spaces* abort —
    r87/r88.)
11. **"Solver iterations buy joint stiffness."** FALSIFIED in this scene —
    `solver_iterations` 1 vs 64 leaves the joint trace identical tick for tick
    (residuals ≤1e-4) and Jolt `velocity_steps` 1 ≡ 10 (§3.3).
12. **"A second world's direct state is not reachable from the main world."**
    FALSIFIED — both a SubViewport `World3D` and a raw active space answer
    fetches and queries with correct per-space identity (§4).
13. **"`PIN_JOINT_IMPULSE_CLAMP` is inert."** FALSIFIED — a clamp of 0.01 (below
    the 0.1633 support impulse) makes the pin sag and the body drift down; 1.0
    is indistinguishable from the default (§3.1).

---

## 8. Observation / inference / unknown

Observation (receipt-pinned, rep-stable): every number, error string, rc and
`byte-identical` claim above.

Inference (labelled): the exact-touch broadphase explanation for the one-step
contact-record delay on GP (§1.4); that GP's `impulse` field is filled from the
recycled contact point's previous solve (§1.3); that the Jolt g6dof no-op is a
missing constraint implementation rather than a silently failing make call
(the joint exists, reports type 4, and holds params).

Unknown / deferred:
- The mechanism behind the GP `joint_set_solver_priority` energy injection
  (steady `lv≈+11.65` climb) — measured, not explained.
- Whether GP's `slider_joint_set_param` write reaches the solver (the getter is
  write-opaque and emits a wrong-type guard; the distance witness cannot
  separate a slider from a pin) — a rotational/translational freedom witness is
  required.
- Rotational freedom of hinge/cone/6dof on either backend.
- The exact rule behind Jolt's per-param drop list (the pattern "solver-tuning
  params dropped, limits/motors honored" holds for hinge/cone/pin but the
  slider's p12 ANGULAR_LIMIT_LOWER is dropped and p0/p1 are honored).
- Threaded behaviour of every cell in this round (all cells are non-threaded;
  r87/r88 own the threaded gate and race classes).
- Whether the force-integration callback fires at all in this scene (accepted
  without error, no observable effect in a 7-tick window).

## 9. Reproducing

```
cd corpus/live/r89-scout
python3 driver.py --batch intro                      # ClassDB surface
python3 driver.py --batch contact   --reps 3         # §1 (36 cells x 3 backends)
python3 driver.py --batch ifrules   --reps 3         # §2 (23 members x 3 backends)
python3 driver.py --batch joints    --reps 3         # §3 (52 cells x 3 backends)
python3 driver.py --batch paramrt   --reps 3         # §3.2 per-param round trip
python3 driver.py --batch solverit  --reps 3         # §3.3 iteration bakes
python3 driver.py --batch cross     --reps 3         # §4
python3 driver.py --batch sleep     --reps 3         # §5
python3 audit.py                                     # rc census + rep identity
python3 sum_ifrules.py <member>                      # §2 per-member summary
```

## Receipts pointer

`corpus/live/r89-scout/`: `probes/*.gd` (7 probes), `driver.py`, `runs/` (795
children + rc/ms sidecars), `RECEIPTS.md` (probe revisions, run groups, disclosed
confounds), `manifest.sha256` (3231 pinned files), `audit.py`, `sum_ifrules.py`.
`corpus/live/` is gitignored — scratch only, per lane contract.

Provenance note: this lane wrote **only** `corpus/live/r89-scout/**` and
`reports/round-89/r89-scout.md`; it never read or wrote `corpus/fixtures/**`
(the r88 author was editing `phys3d_events.gd` / `run_battery.py` concurrently —
their working-tree diff is r88's, not this lane's) and never touched
`reports/round-88/**`. Every probe here is a standalone `SceneTree` script run
against a generated `project.godot`, so no receipt depends on the fixture
battery.
