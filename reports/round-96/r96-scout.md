# r96 scout — the solver-internals surface: iteration counts, warm starting, penetration recovery, damping, the restitution combine rule, and the kinematic/static contact class

Lane: g3d · engine `4.7.2.stable.arch_linux.ed1daf0bf` · `--headless`, 60 tps.
Backends swept: GodotPhysics (`proj`) and Jolt (`proj_jolt`) for **every** cell,
plus **17 one-knob project bakes** (`proj_it1`, `proj_it64`, `proj_jolt_v1`,
`proj_jolt_v60`, `proj_jolt_p0/p1/p8`, `proj_jolt_nocache`, `proj_jolt_slop`,
`proj_jolt_baum`, `proj_jolt_spec0`, `proj_jolt_kinct`, `proj_jolt_bthr0`,
`proj_gp_pen`, `proj_gp_bias`, `proj_gp_recycle0`, `proj_gp_sep0`).
Evidence: `corpus/live/r96-scout/` — `probes/` (8 batch probes + 2 debug
harnesses), `driver.py`, `audit.py`, `runs/*` (**507 children, 507 rc=0**),
`manifest.sha256` (2112 pinned files), `RECEIPTS.md`, `fullrun.log`,
`settingsrun.log`.

Reps: 169 cells carry a `.r1/.r2/.r3` triple from three fresh processes.
**168 are byte-identical**; the single exception is named in §2.2 (a
contact-impulse *read* differs, the row's physics observables do not).

Confidence labels: **[O]** observation (receipt-pinned, rep-stable),
**[I]** inference, **[?]** unknown / not decided by these cells.

---

## 0. The knob surface, enumerated from `ProjectSettings`

`settings.gd` dumps every `physics/` property with its value, type and **hint
string** (the editor's legal range). These are the actual names on this build —
there is no `physics/3d/jolt_physics/solver` path; the Jolt block is
`physics/jolt_physics_3d/*` and is registered on **both** backends (the dump is
identical under `proj` and `proj_jolt`; only the active engine differs).

### 0.1 GodotPhysics 3D

| setting | default | hint (range) |
|---|---|---|
| `physics/3d/solver/solver_iterations` | `16` | `1,32,or_greater` |
| `physics/3d/solver/contact_max_allowed_penetration` | `0.01` | `0.001,0.1,or_greater` |
| `physics/3d/solver/contact_max_separation` | `0.05` | `0,0.1,or_greater` |
| `physics/3d/solver/contact_recycle_radius` | `0.01` | `0,0.1,or_greater` |
| `physics/3d/solver/default_contact_bias` | `0.8` | `0,1,0.01` |
| `physics/3d/sleep_threshold_linear` | `0.1` | `0,1,or_greater` |
| `physics/3d/sleep_threshold_angular` | `0.13962634` | `0,90°,radians_as_degrees` |
| `physics/3d/time_before_sleep` | `0.5` | `0,5,suffix:s` |
| `physics/3d/default_linear_damp` / `default_angular_damp` | `0.1` / `0.1` | `0,100,or_greater` |

**[O] There is no 3D warm-starting toggle, no separate position-iteration
count, and no restitution-combine setting on this backend.** The 2D block has
`physics/2d/solver/default_constraint_bias = 0.2`; the 3D block does **not**
have that key (the 3D-only key is `default_contact_bias`).

### 0.2 Jolt (`physics/jolt_physics_3d/*`)

| setting | default | hint |
|---|---|---|
| `simulation/velocity_steps` | `10` | `2,16,or_greater` |
| `simulation/position_steps` | `2` | `1,16,or_greater` |
| `simulation/baumgarte_stabilization_factor` | `0.2` | `0,1,0.01` |
| `simulation/penetration_slop` | `0.02` | `0,1,0.00001,or_greater,m` |
| `simulation/speculative_contact_distance` | `0.02` | `0,1,0.00001,or_greater,m` |
| `simulation/bounce_velocity_threshold` | `1.0` | `0,1,0.001,or_greater,m/s` |
| `simulation/body_pair_contact_cache_enabled` | `true` | bool |
| `simulation/body_pair_contact_cache_angle_threshold` | `0.034906585` | `0,180°,radians_as_degrees` |
| `simulation/body_pair_contact_cache_distance_threshold` | `0.001` | `0,0.01,m` |
| `simulation/generate_all_kinematic_contacts` | `false` | bool |
| `simulation/allow_sleep` | `true` | bool |
| `simulation/sleep_velocity_threshold` | `0.03` | `0,1,m/s` |
| `simulation/sleep_time_threshold` | `0.5` | `0,5,s` |
| `limits/max_linear_velocity` / `max_angular_velocity` | `500` / `47.12389` | `0,500,m/s` / `0,2700°/s` |
| `collisions/collision_margin_fraction` | `0.08` | `0,1` |
| `joints/world_node` | `0` | `Node A,Node B` |

**[O] `position_steps=0` is accepted** even though the hint range starts at 1
(`st_proj_jolt_p0` reads `0`, and §1 shows it disables the pin's position
recovery outright). `velocity_steps=1` is likewise accepted below its `2` floor
(the readback in `st_proj_jolt_v1` is `1`, and its effect is visible in §1).

**[O] The only warm-start-adjacent knob Jolt exposes is the contact cache**
(`body_pair_contact_cache_enabled` + its two thresholds); GP's nearest knob is
`contact_recycle_radius`. Neither is a "warm starting" switch (§2).

---

## 1. Solver iteration counts: velocity vs position steps

Scene (server-created bodies, explicit `body_set_space` — see §1.4):
`pin` = one pin link, pivot at the midpoint of the two bodies (Godot's pin
drives its two pivot points to coincide, so a midpoint pivot *is* the distance
link), joint made at rest length 1.0, body teleported 0.3 m down before step 1.
`chain` = anchor + 3 spheres on midpoint pins, hanging under gravity.
`hinge` = hinge line = world Z through the **body centre**, angular limit
±0.2 rad, body spun at 3 rad/s into the limit. `stack` = five 0.4 m cubes with
0.005 m clearance on a static floor. All run 180 ticks.

### 1.1 Arm table (verbatim-armable cells)

Run from `corpus/live/r96-scout/`; `--only` matches a tag substring.

| # | command | expected signature (verbatim, r1) | falsified if |
|---|---|---|---|
| 1.1 | `python3 driver.py --batch iters --reps 3 --only it_proj_pin` | `ITSUM case=pin ticks=180 … max_gap=0.3`; trace `IT t=2 gap=0.21 lv=5.399999 y=1.79` … `IT t=60 gap=0.0 lv=0.0 y=2.0` | the 0.3 m error is not recovered, or the velocity residue is absent |
| 1.2 | `… --only it_proj_jolt_pin` | `IT t=2 gap=0.192 lv=0.0 y=1.808` … `IT t=60 gap=0.0 lv=0.0 y=2.0` (**`lv` is 0.0 at every tick**) | a velocity residue appears |
| 1.3 | `… --only it_proj_jolt_p0_pin` | `IT t=180 gap=0.3 lv=0.0 y=1.7` (the error is **never** recovered) | `position_steps=0` still corrects position |
| 1.4 | `… --only it_proj_jolt_p1_pin` | gap 0.3→0.24→0.192→0.1536 (ratio 0.8/tick), residual `gap=0.00001` at t=180 | the residual is 0 |
| 1.5 | `… --only it_proj_it1_chain` / `it_proj_it64_chain` | `ITSUM … last_sum=0.045513 max_sum=0.053731` / `last_sum=0.0 max_sum=0.0` (default `it16`: `last_sum=0.000163`) | `solver_iterations` does not move the chain |
| 1.6 | `… --only it_proj_jolt_v1_chain` / `it_proj_jolt_v60_chain` | `last_sum=0.00168 max_sum=0.010582` / `last_sum=0.0 max_sum=0.0` (default v10: `0.000031`) | `velocity_steps` does not move the chain |
| 1.7 | `… --only it_proj_jolt_p0_chain` / `p1` / `p8` | `last_sum=0.000162` / `0.000077` / `0.000007` (default p2 `0.000031`) | `position_steps` does not move the chain |
| 1.8 | `… --only it_proj_hinge` | `ITSUM … max_over=-0.050499 last_over=-0.099943` (identical for `it1`/`it16`/`it64`) | GP's limit behaviour is iteration-limited |
| 1.9 | `… --only it_proj_jolt_hinge` | `IT t=6 euler=…,0.2312 av=…,2.9751 over=0.031202` then `av=0` and `over` decaying to `0.000004` at t=180 | Jolt's limit has a velocity residue |
| 1.10 | `… --only it_proj_jolt_p1_hinge` / `p8` | `max_over=0.039002` / `max_over=0.008179` (default p2 `0.031202`); `p0` → `max_over=0.048753 last_over=0.048753` | `position_steps` does not set the overshoot |
| 1.11 | `… --only it_proj_it1_stack` | `ITSUM … last_y4=0.191492 last_xz4=0.719894 max_vmax=3.599209` (the tower **collapses**) vs default `last_y4=1.760015 last_xz4=0.012934` | the tower stands at 1 iteration |
| 1.12 | `… --only it_proj_jolt_v1_stack` / `v60` | `last_pen0=0.011403 last_xz4=0.036294` / `last_pen0=0.000056 last_xz4=0.000216` (default v10: `0.000468` / `0.002211`) | `velocity_steps` does not move the tower |
| 1.13 | `… --only it_proj_jolt_p1_stack` / `p8` | byte-identical to the default (`last_pen0=0.000468`) | position steps move the contact penetration |

### 1.2 Verdicts **[O]**

- **Jolt separates the two duties cleanly.** `position_steps` owns the *joint
  positional* residual: the pin's 0.3 m error recovery (p0 = no recovery at
  all, p1 = ratio 0.8/tick leaving 1e-5, p2 = ratio 0.64/tick reaching 0) and
  the hinge limit overshoot (+0.0488 / +0.0390 / +0.0312 / +0.0082 for
  0/1/2/8 steps). `velocity_steps` owns the *velocity-level* convergence of
  loaded multi-constraint scenes: chain stretch 0.00168 (v1) → 0.000031 (v10)
  → 0.0 (v60), tower drift 0.0363 → 0.0022 → 0.0002.
- **The two knobs do not substitute for each other.** Chain stretch under v1
  is 0.00168 but under p1 is only 0.000077; the pin under v1 is identical to
  v10 while p1 changes it. A tower's resting penetration (`last_pen0`) is
  **not** moved by `position_steps` at all (p1 = p2 = p8, byte-identical) —
  contact penetration is a velocity-solver/Baumgarte product (§3).
- **Jolt's joint correction leaves no velocity residue**: the pin's `lv` is
  exactly `0.0` at every tick while the gap closes, and the hinge's `av` snaps
  to `0` the tick after the overshoot, then the position solver walks the angle
  back to the limit.
- **GP has a single knob.** `solver_iterations` moves the *loaded* scenes
  (chain: 0.045513 → 0.000163 → 0.0 for 1/16/64; tower: collapse at 1, drift
  0.0129 at 16, 0.0030 at 64) but is **inert for single-joint position
  recovery and for the hinge limit** (all three bakes byte-identical to the
  default in those cells). GP's pin is a velocity-level impulse: the 0.3 m
  error is corrected with a 5.4 m/s spike and a geometric 0.7/tick decay.
- **`position_steps=0` is a real, unbounded failure mode** on Jolt: a joint
  that starts misaligned stays misaligned forever (`gap=0.3` for all 180
  ticks) while the physics otherwise runs normally.

### 1.3 GP vs Jolt joint semantics (same cells)

| witness | GodotPhysics | Jolt |
|---|---|---|
| pin position-error recovery | velocity impulse, peak `lv=5.4` m/s, ratio 0.7/tick, converges to 0 | position-only, `lv≡0`, ratio 0.64/tick, converges to 0 |
| hinge limit behaviour | **never reaches** the limit: max angle 0.1495 of 0.2 (`max_over=-0.050499`), then drifts back with `av=-0.0996` still present at t=180 | **overshoots** to `over=+0.0312`, `av` snaps to 0, position-solved back to `over=0.000004` |
| `position_steps=0` analogue | n/a (one knob) | pin: error never corrected; hinge: `last_over=0.048753` at t=180 |

### 1.4 The node-body joint trap (why every joint cell uses server bodies) **[O]**

A joint created through the `PhysicsServer3D` API inside `_initialize()` on
**node**-based bodies is silently dropped on GodotPhysics and works on Jolt:

| case | GodotPhysics | Jolt |
|---|---|---|
| `node_init` (joint in `_initialize()`) | `space_a=RID(0) space_b=RID(0)`; body free-falls `y=2.0→1.821328` at t=12 | binds: `y=2.0→2.796224` |
| `node_late` (joint at tick 2) | binds: `y→2.410001` | binds: `y→2.794069` |
| `srv` (server bodies + `body_set_space`) | binds: `y→2.410001` | binds: `y→2.796224` |

Mechanism **[I]**: a node body has no space yet during `_initialize()`; the
space is assigned later and `GodotPhysicsServer3D::body_set_space()` calls
`body->clear_constraint_map()` (`godot_physics_server_3d.cpp:463`, r90-scout's
engine-source cache — provenance: r90's copy, not sha-pinned to the binary),
which drops the joint the constructor had just registered. Jolt's joint layer
has no equivalent failure. **Any GP fixture that builds joints in
`_initialize()` on nodes must build them after the first frame, or use
server bodies.**

---

## 2. Warm starting / contact history

No backend exposes a warm-starting toggle. Measured instead: the per-tick
contact **impulse** of a settled body (`_integrate_forces`, contact 0), and
what happens when the contact is destroyed for exactly one tick.

### 2.1 Arm table

| # | command | expected signature (verbatim, r1) | falsified if |
|---|---|---|---|
| 2.1 | `--batch warm --only wm_proj_rest` | `W t=60 cc=1 imp=-0.000000,0.163333,-0.000000 y=0.290000051 lv=0.000003129` … `W t=139 … y=0.290008157 lv=0.000009015` (constant `m·g·dt` impulse, slow upward **creep**) | the impulse is not the steady support value |
| 2.2 | `--only wm_proj_jolt_rest` | `W t=60 cc=1 imp=0.000000,0.163333,0.000000 y=0.300000012 lv=0.0` (identical for all 140 ticks) | the impulse or pose drifts |
| 2.3 | `--only wm_proj_gp_recycle0_rest` | `W t=60 cc=2 imp=-0.000000,-0.000000,-0.000000 y=0.289998919 lv=0.0` (frozen; **no creep**) | `contact_recycle_radius=0` is inert |
| 2.4 | `--only wm_proj_jolt_nocache_rest` | byte-identical to 2.2 | `body_pair_contact_cache_enabled=false` is inert (it is, for a single resting contact) |
| 2.5 | `--only wm_proj_break` | `W t=101 cc=0 … y=0.287281007 lv=-0.163327232`, then `t=102 imp=…,-0.000000,…`, `t=103 imp=…,0.326661,…`, `t=104 imp=…,0.163333,…` — re-contact with a **double impulse**, then asymptotic return to `y=0.29` | the re-contact transient is absent |
| 2.6 | `--only wm_proj_jolt_break` | `W t=101 cc=0 … y=0.297277778 lv=-0.163333341`, `t=102 imp=…,0.326667,…`, then `y=0.297277778` **for the rest of the run** | the break is pose-neutral |
| 2.7 | `--only wm_proj_stack` | `W t=60 cc=4 imp=0.000206,0.075407,0.001811 y0=0.199280933 vmax=0.00076576` … `t=139 y0=0.199282825` (creeping) | — |
| 2.8 | `--only wm_proj_gp_recycle0_stack` | `W t=60 cc=4 imp=-0.000000,-0.000000,-0.000000 y0=0.190290883 vmax=0.061264221` … `t=139 y0=0.188612878 vmax=0.195231155` (the tower **sinks and keeps moving**) | the recycle radius does not change the tower |
| 2.9 | `--only wm_proj_jolt_stack` | `W t=60 cc=8 imp=-0.000544,0.050267,0.001056 y0=0.199872971 vmax=0.000012007` … `t=139 vmax=0.000000026` (dead stop) | — |

### 2.2 Verdicts **[O]**

- **The steady contact impulse is the same constant on both backends**:
  `0.163333 = m·g·dt` for the ball, and the tower's first contact carries
  `0.0754` (GP, 4 contacts) / `0.0503` (Jolt, 8 contacts). A settled contact is
  a constant-impulse state on both — the observable signature of a warm-started
  / accumulated-impulse contact.
- **A one-tick contact break is not history-neutral, and the two backends
  differ in *how*.** GP re-converges: the re-contact impulse is 0 (t=102) then
  **2×** the steady value (0.326661) then 1×, and the ball asymptotically
  returns to its pre-break rest `y=0.29` — GP's resting penetration is a
  *setpoint*. Jolt's re-contact impulse is exactly 2× for one tick, and the
  ball then rests **0.00272 m lower forever** (`y=0.297277778`, penetration
  0.00272 < slop 0.02) — Jolt's resting penetration is a *tolerance band*.
- **GP's `contact_recycle_radius` is observable, Jolt's contact cache is not
  (for a single contact).** With `contact_recycle_radius=0.0` the ball's contact
  set becomes 2 contacts and the body freezes exactly (no creep), and the tower
  sinks to `y0=0.1886` with `vmax` growing to 0.195. With
  `body_pair_contact_cache_enabled=false` the ball cell is byte-identical; the
  tower's pose shifts by 4e-5 and its contact-0 impulse reads 0 — the manifold's
  contact identity changes but the physics barely does.
- **The one non-byte-stable cell in this round lives here**:
  `wm_proj_jolt_nocache_stack` r1 reports `imp=0.000000,0.000000,0.000000` on
  the first sampled row while r2/r3 report `imp=-0.000522,0.050273,0.001045`;
  the same row's `y0=0.199833333` and `vmax=0.000093835` are identical. With
  the cache off, contact-0's identity is not rep-stable.

---

## 3. Contact penetration recovery constants

### 3.1 Arm table

| # | command | expected signature (verbatim, r1) | falsified if |
|---|---|---|---|
| 3.1 | `--batch pen --only pn_proj_overlap` | `P t=2 sep=-0.068` → `t=3 sep=-0.0216` → `t=10 sep=-0.010001` (residual = `contact_max_allowed_penetration`), `lv≡0.0` | the residual is not the setting |
| 3.2 | `--only pn_proj_gp_pen_overlap` | `sep_end=-0.200001` with the setting at 0.2 | the residual does not track it |
| 3.3 | `--only pn_proj_gp_bias_overlap` | **byte-identical to 3.1** (`default_contact_bias=0.2` is inert here) | the bias moves the depenetration |
| 3.4 | `--only pn_proj_jolt_overlap` | `t=2 sep=-0.22` → `t=3 -0.148` → `t=4 -0.10192` → `t=40 -0.02` (residual = `penetration_slop`) | the residual is not the slop |
| 3.5 | `--only pn_proj_jolt_slop_overlap` | `sep_end=-0.1` with `penetration_slop=0.1` | the residual does not track the slop |
| 3.6 | `--only pn_proj_jolt_baum_overlap` | `t=2 sep=-0.28` → `t=3 -0.26` → `t=4 -0.24` (a **linear** −0.02/tick with `baumgarte_stabilization_factor=0.05`, vs the default's geometric 0.64/tick) | Baumgarte does not set the rate |
| 3.7 | `--only pn_proj_rest` / `pn_proj_jolt_rest` | `pen_end=0.009974` / `pen_end=0.02` after a 1 m drop | — |
| 3.8 | `--only pn_proj_approach` / `pn_proj_jolt_approach` | first velocity change at `first_mod_tick=9 first_mod_y=0.495 first_mod_gap=-0.005` / `first_mod_tick=8 first_mod_y=0.5 first_mod_gap=0.0` | the contact-onset distance is backend-independent |
| 3.9 | `--only pn_proj_jolt_spec0_approach` | the physics rows are identical to 3.8's Jolt row (only the header's `spec_dist=0.0` readback differs) | the speculative distance is what stops the body |

### 3.2 Verdicts **[O]**

- **GP's resting penetration is exactly `contact_max_allowed_penetration`**
  (0.010001 at the default 0.01; 0.200001 at 0.2) — a *setpoint* the solver
  drives back to, in both the two-sphere and sphere-on-floor scenes.
  `default_contact_bias` and `contact_max_separation` do not move either the
  curve or the residual in these cells.
- **Jolt's resting penetration is exactly `penetration_slop`** (0.02 default,
  0.1 when raised) — a *tolerance band*, and `baumgarte_stabilization_factor`
  sets the *rate* (0.05 → a constant 0.02 m/tick, i.e. a linear approach)
  rather than the residual.
- **Both backends depenetrate with zero velocity residue** (`lv≡0.0` in every
  sampled row) — the recovery is a position projection, not a bounce.
- **Jolt stops an incoming body at the geometric surface** (`first_mod_gap=0.0`),
  GP only after 0.005 m of penetration (= half of its 0.01 allowance);
  `speculative_contact_distance=0` does not change Jolt's onset, so the onset
  here is the collision margin (0.04, r93-pinned), not the speculative distance.

---

## 4. `linear_damping` — the decay law has the same shape on both backends

### 4.1 Arm table

| # | command | expected signature (verbatim, r1) | falsified if |
|---|---|---|---|
| 4.1 | `--batch damp --only dp_proj_lin10` | `D t=2 lv=8.333333015 ratio=0.833333302`, `t=3 ratio=0.833333333`, … `t=20 ratio=0.833333307` | the ratio is not `1 − d·dt` |
| 4.2 | `--only dp_proj_jolt_lin10` | **byte-identical** to 4.1 | the laws differ |
| 4.3 | `--only dp_proj_lin100` / `dp_proj_jolt_lin100` | `D t=2 lv=0.0 ratio=0.0` on **both** (the `1−d·dt` clamp at 0, not the reciprocal `1/(1+d·dt)` = 0.375) | either backend uses the reciprocal law |
| 4.4 | `--only dp_proj_lin05` | `ratio=0.991666682` at t=3 and `0.991666729` at t=20 (≈ `1 − 0.5/60`) | — |
| 4.5 | `--only dp_proj_lin0repl` / `lin0comb` | `ratio=1.0` / `ratio=0.998333347` (COMBINE pulls in `physics/3d/default_linear_damp=0.1`) | REPLACE still applies the project default |
| 4.6 | `--only dp_proj_ang10` / `dp_proj_jolt_ang10` | `av` trace byte-identical, `ratio=0.833333333` | angular damping differs |
| 4.7 | `--only dp_proj_grav10` / `dp_proj_jolt_grav10` | identical y and `lv` traces; terminal `lv=-0.9799999` at t=200 (≈ −g/d) | the gravity+damping recurrence differs |
| 4.8 | `--only dp_proj_sleep1` / `dp_proj_jolt_sleep1` | GP `DSUM … slept_at=126 lv_end=0.061173905`; Jolt `DSUM … slept_at=144 lv_end=0.0`; Jolt also prints `sl=true hdl_sleep=false` at t=1 | both sleep at the same tick, or Jolt keeps its velocity |

### 4.2 Verdicts **[O]**

- **The per-tick decay ratio is `1 − d·dt`, identical to 9 decimals on both
  backends** for `d ∈ {0.5, 10, 100}` and for angular damping — including the
  clamp-to-zero at `d·dt ≥ 1`. **Jolt does not use a reciprocal
  `1/(1+d·dt)` law**, and the COMBINE/REPLACE damp-mode semantics match.
- **The default project damping is applied through COMBINE only**: a body with
  `linear_damp = 0` decays at 0.998333/tick in COMBINE mode and not at all in
  REPLACE mode, on both backends.
- **Sleep is the split, not the curve**: GP sleeps at t=126 and *keeps* its
  velocity (`lv_end=0.0612`), Jolt sleeps at t=144 and *zeroes* it
  (`lv_end=0.0`) — a re-bind of r89's `sleep` split on a damping-driven decay
  (the thresholds differ too: GP `sleep_threshold_linear=0.1` vs Jolt
  `sleep_velocity_threshold=0.03`). Jolt's spawn-frame `SLEEPING=true` false
  positive (r93) re-appears at t=1.

---

## 5. Restitution: the combine rule is a clamped **sum**, not a max

### 5.1 Arm table

| # | command | expected signature (verbatim, r1) | falsified if |
|---|---|---|---|
| 5.1 | `--batch rest --only rs_proj_max` / `rs_proj_min` | both `e_vel=0.9` for a 0.9/0.0 and a 0.0/0.9 pair | the rule is order-dependent |
| 5.2 | `--only rs_proj_sum` | ball 0.3 + floor 0.4 → `e_vel=0.7` (max would be 0.4, product 0.12, average 0.35) | the rule is max/product/avg |
| 5.3 | `--only rs_proj_mid` | ball 0.5 + floor 0.8 → `e_vel=1.0` (0.5+0.8 clamped to 1.0) | the rule is max (0.8) |
| 5.4 | `--only rs_proj_both` | 0.9+0.9 → `e_vel=1.0` | — |
| 5.5 | `--only rs_proj_jolt_sum` | `e_vel=0.7`, `apex=0.78305` (identical `e_vel` to GP) | the combine rule differs per backend |
| 5.6 | `--only rs_proj_low` / `rs_proj_jolt_low` | GP `v_in=-0.816667 v_out=0.735 e_vel=0.9`; Jolt `v_in=-0.653333 v_out=0.0 e_vel=0.0` (a 0.03 m drop, 0.65–0.82 m/s impact) | Jolt has no restitution threshold |
| 5.7 | `--only rs_proj_jolt_bthr0_low` | `v_out=0.588 e_vel=0.9` with `bounce_velocity_threshold=0.0` | the threshold is not the mechanism |
| 5.8 | `--only rs_proj_pair` / `rs_proj_jolt_pair` | head-on dynamic pair (2 m/s each, bounce 0.9/0.0): `v1_out=-1.8 v2_out=1.8 e1=0.9` on **both** | — |
| 5.9 | `--only rs_proj_jolt_pairlow` | closing 0.5 m/s: `v1_out=0.0 v2_out=0.0` — the pair comes to rest at `z=±0.3` (stuck together) vs GP's `e1=0.9` | the threshold does not apply to body-body pairs |

### 5.2 Verdicts **[O]**

- **The combine rule is `e_eff = clamp(bounce_A + bounce_B, 0, 1)` on both
  backends.** The two asymmetric cells that discriminate it are `sum`
  (0.3/0.4 → 0.7, which rules out max/product/average) and `mid`
  (0.5/0.8 → 1.0, which rules out max). **Godot's documented "bounce is
  combined using max" is falsified on this build** — a 0.5/0.8 pair bounces
  with `e=1.0`, and any pair whose bounces sum above 1.0 is fully elastic.
- **Jolt applies a minimum impact velocity for restitution**
  (`bounce_velocity_threshold = 1.0 m/s`): a 0.03 m drop (0.65–0.82 m/s) and a
  0.5 m/s closing pair produce **zero** bounce, while GP bounces with `e=0.9`.
  The `proj_jolt_bthr0` bake restores the bounce, pinning the threshold as the
  mechanism. The threshold applies to both body-floor and body-body pairs.
- Where the combine rule agrees, the *outgoing velocity ratio* agrees exactly
  (0.9 / 0.7 / 1.0); the rebound **apex** still differs by ~15 mm on the
  `max` cell (GP 1.123283 vs Jolt 1.108083) — the same contact that produced
  the same exit velocity resolves the contact tick slightly differently.

---

## 6. Kinematic vs static contact class

### 6.1 Arm table

| # | command | expected signature (verbatim, r1) | falsified if |
|---|---|---|---|
| 6.1 | `--batch kin --only kn_proj_static` … `kn_proj_anim` | all five platform classes (StaticBody3D, frozen STATIC, frozen KINEMATIC, server `BODY_MODE_KINEMATIC`, AnimatableBody3D) give `KSUM … y_end=0.29001 lv_end=0.00001 cc_end=1` | a dynamic ball's rest depends on the platform's class |
| 6.2 | `--only kn_proj_jolt_static` … `kn_proj_jolt_anim` | all five: `y_end=0.3 lv_end=0.0 cc_end=1` | — |
| 6.3 | `--only kn_proj_kcontact` | a **kinematic** ball overlapping the static floor reports `K kcontact first_cc t=2 cc=1` | a kinematic body reports no contact on GP |
| 6.4 | `--only kn_proj_jolt_kcontact` | `kin_cc=0` at every tick (`kin_first_cc=-1`) | Jolt reports kinematic-vs-static contacts |
| 6.5 | `--only kn_proj_jolt_kinct_kcontact` | `first_cc t=2 cc=1` with `generate_all_kinematic_contacts=true` | the knob is not the mechanism |
| 6.6 | `--only kn_proj_carrykin` / `kn_proj_jolt_carrykin` | both: `K t=32 … lv=15.499978` — a teleported kinematic platform **launches** the resting ball at ~31× the platform speed, on both backends | the launch is backend-specific |
| 6.7 | `--only kn_proj_carrystatic` | GP: the ball rattles (`t=32 lv=0.5`, `t=35 lv=0.173333`, `t=45 lv=-0.316667`, … `KSUM … y_end=0.307486 lv_end=-0.316667 cc_end=0`) | GP ignores `constant_linear_velocity` |
| 6.8 | `--only kn_proj_jolt_carrystatic` | Jolt: `t=32 … y=0.283333 lv=0.0 cc=1` unchanged for the whole run | Jolt honours `constant_linear_velocity` |

### 6.2 Verdicts **[O]**

- **For a dynamic body resting on a platform, the contact class does not
  matter**: StaticBody3D, `freeze_mode=STATIC`, `freeze_mode=KINEMATIC`,
  server `BODY_MODE_KINEMATIC` and AnimatableBody3D all give the identical
  rest pose and contact count on each backend (only the backend split itself
  remains: GP rests at 0.29001 with a 1e-5 residual velocity, Jolt at 0.300000
  with exactly zero).
- **The kinematic/static split is in contact *reporting*, not contact
  *solving***: on Jolt a kinematic body generates **no** contacts against a
  static body unless `generate_all_kinematic_contacts=true` (GP reports one by
  default). Any fixture that watches a kinematic body's contacts must set that
  knob on Jolt.
- **`StaticBody3D.constant_linear_velocity` is a GP-only idiom**: GP's contact
  solve injects the platform's 0.5 m/s into the ball (which then rattles
  between 0.298 and 0.316 with `lv` swinging ±0.5 and never settles), while
  Jolt ignores it completely (`y=0.283333 lv=0.0` for 120 ticks). Neither
  backend *carries* the ball upward — the classic "moving platform" behaviour
  needs an AnimatableBody3D moved per tick, not a constant velocity.
- **Teleporting a kinematic platform into a resting ball is a shared
  pathology**: both backends eject the ball at 15.5 m/s for a 0.5 m/s platform
  (a 31× amplification) — a "moving platform" built by teleporting the body
  will launch anything resting on it.

---

## 7. Backend split summary (one row per measured divergence)

| axis | GodotPhysics | Jolt |
|---|---|---|
| joint position recovery (`position_steps` analogue) | `solver_iterations` inert; pin corrects with a velocity spike | `position_steps` owns it; `0` disables it entirely |
| hinge limit | never reached (max 0.1495 of 0.2), residual `av=-0.0996` at t=180 | overshoots (+0.0312), `av→0`, position-solved back to `over=0.000004` |
| joint creation in `_initialize()` on node bodies | **silently dropped** (space assigned later clears the constraint map) | binds |
| resting contact penetration | setpoint = `contact_max_allowed_penetration` (0.01), asymptotically restored after a break | tolerance band = `penetration_slop` (0.02); a 0.00272 penetration is kept forever |
| resting creep | a settled ball creeps upward (lv 3e-6 → 9e-6 over 80 ticks) | exactly zero |
| contact count (ball on floor / 5-cube tower) | 1 / 4 | 1 / 8 |
| `contact_recycle_radius` (contact cache) | observable: changes contact count, freezes the creep, sinks the tower | n/a |
| `body_pair_contact_cache_enabled` | n/a | inert for a single contact; shifts the tower's contact identity |
| restitution below 1 m/s | bounces (`e=0.9` at 0.77 m/s and 0.5 m/s) | **no bounce** (`bounce_velocity_threshold=1.0`) |
| contact onset vs an incoming body | 0.005 m of penetration before the first velocity change | at the geometric surface (gap 0.0) |
| `StaticBody3D.constant_linear_velocity` | injected into the contact solve (ball rattles) | ignored |
| kinematic body vs static body contacts | reported | **not reported** unless `generate_all_kinematic_contacts=true` |
| sleep tick under damping / velocity at sleep | t=126, velocity kept (0.0612) | t=144, velocity zeroed (0.0) |
| spawn-frame `BODY_STATE_SLEEPING` | false | **true at t=1** (r93 re-bind) |

Identical on both backends (measured, not assumed): the damping law and its
COMBINE/REPLACE semantics; the restitution combine rule (clamped sum); the
per-tick depenetration of an overlapping pair having zero velocity residue;
the steady support impulse `m·g·dt`; the kinematic-platform launch
amplification; and the resting pose on all five platform classes.

---

## 8. Falsification list (claims this round tested)

1. **"Godot's bounce is combined using max."** FALSIFIED — a 0.5/0.8 pair
   bounces with `e=1.0` and a 0.3/0.4 pair with `e=0.7`; the rule is
   `clamp(A+B, 0, 1)` on both backends (§5).
2. **"`solver_iterations` buys joint accuracy."** FALSIFIED for single joints
   (pin recovery and the hinge limit are byte-identical at 1/16/64) but
   CONFIRMED for loaded multi-constraint scenes (chain stretch 0.0455 → 0.0;
   a 5-cube tower collapses at 1 and stands at 64) (§1).
3. **"Velocity and position iterations are interchangeable tuning knobs."**
   FALSIFIED — on Jolt `position_steps=0` leaves a pin misaligned forever and
   sets the hinge overshoot, while `velocity_steps` moves the chain and the
   tower; neither moves the other's witness (§1).
4. **"`position_steps` also controls contact penetration."** FALSIFIED — the
   tower's resting penetration is byte-identical for `position_steps` 1, 2 and
   8 (§1.13); penetration is `penetration_slop`/Baumgarte territory (§3).
5. **"`default_contact_bias` tunes GP's depenetration."** FALSIFIED — 0.2 vs
   0.8 is byte-identical in both the overlapping-pair and floor scenes (§3).
6. **"A joint made through the PhysicsServer3D API behaves the same on node
   and server bodies."** FALSIFIED on GP — a joint created in `_initialize()`
   on node bodies is dropped when the node's space is assigned (§1.4).
7. **"`linear_damping` is applied differently by Jolt (reciprocal law)."**
   FALSIFIED — the ratio is `1 − d·dt` to 9 decimals on both, including the
   clamp at `d·dt ≥ 1` (§4).
8. **"A contact broken for one tick leaves no trace."** FALSIFIED on both —
   GP re-converges through a double impulse, Jolt rests 2.72 mm lower forever
   (§2).
9. **"Jolt's `body_pair_contact_cache_enabled` changes resting behaviour."**
   FALSIFIED for a single contact (byte-identical); it is only observable
   through the tower's contact identity (§2).
10. **"`penetration_slop` and `baumgarte` are two names for one knob."**
    FALSIFIED — the slop is the residual (0.02/0.1 exactly), Baumgarte is the
    rate (a linear 0.02 m/tick at 0.05) (§3).
11. **"The speculative contact distance stops an approaching body."**
    FALSIFIED in this cell — Jolt's first velocity change is at the geometric
    surface even with `speculative_contact_distance=0`; the onset is the
    collision margin (§3).
12. **"A kinematic body's contacts are reported like a static body's."**
    FALSIFIED on Jolt — zero contacts against a static floor until
    `generate_all_kinematic_contacts=true` (GP reports one) (§6).
13. **"`StaticBody3D.constant_linear_velocity` is a portable moving-platform
    idiom."** FALSIFIED — GP injects it (and the ball rattles), Jolt ignores it
    (§6).
14. **"A dynamic ball's rest depends on the platform's body class."**
    FALSIFIED — five platform classes give an identical rest pose on each
    backend (§6).
15. **"Teleporting a kinematic platform carries a resting ball."** FALSIFIED on
    both — the ball is launched at ~31× the platform speed (§6).
16. **"A low-speed impact still bounces (restitution is scale-free)."**
    FALSIFIED on Jolt — below `bounce_velocity_threshold=1.0` m/s the bounce is
    zero for both body-floor and body-body pairs, while GP bounces at 0.5 m/s
    (§5).
17. **"`position_steps=0` is rejected or clamped to its hinted minimum."**
    FALSIFIED — the setting reads 0 and its effect (no joint position
    correction at all) is observable (§0, §1).
18. **"`contact_recycle_radius` is a rounding knob."** FALSIFIED on GP — 0.0
    changes the contact count, removes the resting creep, and makes a 5-cube
    tower sink and keep moving (§2).
19. **"A settled body's per-tick contact impulse is implementation-defined."**
    FALSIFIED — it is exactly `m·g·dt` (0.163333) on both backends (§2).

---

## 9. Observation / inference / unknown

Observation (receipt-pinned, rep-stable): every number, trace, byte-identity
claim and error string above.

Inference (labelled): the `clear_constraint_map()` mechanism behind the
node-body joint trap (§1.4), from r90-scout's engine-source cache — provenance
is r90's copy, not sha-pinned to this binary; the "setpoint vs tolerance band"
framing of the GP/Jolt resting-penetration split, which is what the measured
post-break poses imply but whose solver internals were not read.

Unknown / deferred:
- Whether Jolt's `position_steps=0` failure mode is reachable through any node
  API (only the project setting was exercised).
- The exact rule that maps `baumgarte_stabilization_factor` to the per-tick
  depenetration rate (only 0.2 → geometric and 0.05 → linear 0.02/tick were
  measured; the two-point curve is not enough to name the formula).
- Why a Jolt resting contact stops at 0.300000012 while GP rests at
  0.290000051 for the same 0.3 m sphere (the 1e-8 float32 tail vs the 0.01
  setpoint is clear; the exact Jolt rest offset under gravity is not swept).
- Whether `generate_all_kinematic_contacts=true` also changes *solving* (only
  contact reporting was witnessed).
- Threaded behaviour of every cell (all cells are non-threaded; r87/r88 own the
  threaded gate), and the `Dummy` backend (r89/r92 own its degenerate paths).
- The apex difference (≈15 mm) between GP and Jolt on an identical `e_vel` —
  the contact-tick resolution detail was not isolated.

---

## 10. Reproducing

```
cd corpus/live/r96-scout
python3 driver.py --batch iters    --reps 3 --jobs 6   # §1 (36 cells)
python3 driver.py --batch joints   --reps 3 --jobs 6   # §1.4 (6 cells)
python3 driver.py --batch pen      --reps 3 --jobs 6   # §3 (32 cells)
python3 driver.py --batch warm     --reps 3 --jobs 6   # §2 (12 cells)
python3 driver.py --batch damp     --reps 3 --jobs 6   # §4 (16 cells)
python3 driver.py --batch rest     --reps 3 --jobs 6   # §5 (24 cells)
python3 driver.py --batch kin      --reps 3 --jobs 6   # §6 (24 cells)
python3 driver.py --batch settings --reps 3 --jobs 6   # §0 (57 children)
python3 audit.py                                       # rc census + rep identity
```

Single cells: `python3 driver.py --batch iters --reps 3 --only it_proj_jolt_p0_pin`
(the `--only` filter matches the tag substring), `--only pn_proj_jolt_baum_overlap`,
`--only wm_proj_break`, `--only rs_proj_jolt_bthr0_low`, `--only kn_proj_kcontact`, ….
A bake is one line in `driver.py`'s `PROJECTS`; the whole `proj*/` tree is
regenerated by the driver from that table.

## Receipts pointer

`corpus/live/r96-scout/`: `probes/` (10 `.gd`), `driver.py`, `audit.py`,
`runs/` (507 children + rc/ms sidecars), `RECEIPTS.md` (probe inventory, run
groups, disclosed confounds), `manifest.sha256` (2112 pinned files),
`fullrun.log`, `settingsrun.log`. `corpus/live/` is gitignored — scratch only,
per lane contract.

Provenance note: this lane wrote **only** `corpus/live/r96-scout/**` and
`reports/round-96/r96-scout.md`; it did not write `corpus/fixtures/**` or any
other round's scratch tree. Every probe is a standalone `SceneTree` script run
against a generated `project.godot` (60 tps, backend and one baked setting),
so no receipt depends on the fixture battery.
