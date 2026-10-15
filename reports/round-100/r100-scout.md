# r100 scout — the headless main-loop rate surface: `--fixed-fps N` as a deterministic scheduler

Lane: g3d · engine `4.7.2.stable.arch_linux.ed1daf0bf` · `--headless`, 60 tps.
Backends swept for **every** cell: GodotPhysics (`proj`), Jolt (`proj_jolt`),
Dummy (`proj_dummy`). Bakes on GP only: `proj_cap`
(`max_physics_steps_per_frame=1`), `proj_jit0` (`physics_jitter_fix=0.0`),
`proj_dsfalse` (`application/run/delta_smoothing=false`).

Evidence: `corpus/live/r100-scout/` — `probes/` (5 `.gd`), `driver.py`,
`audit.py`, `sum.py`, `runs/` (**552 children**: 534 rc=0 + 18 rc=137 declared
negative control; stdout/exit/ms/cmd sidecars), `RECEIPTS.md` (2277-entry
`manifest.sha256`), `*_batch.log`. Scratch only; the sole tracked-tree write is
this report.

Reps: sched/rt/area/census 3 per cell, **life 6 per cell** (r90 bimodal
lesson). 160 cells with ≥2 reps: **124 byte-identical** after dropping only the
wall-clock line (`RS_TIME`/`AR_TIME`); every one of the 36 unstable cells is
named and explained in §8. All reps ran 6–8-way concurrent, so rep identity is
also load identity.

Confidence: **[O]** receipt-pinned observation, **[I]** inference, **[?]** unknown.

---

## 0. Why this surface

The chain's own caveat is the strongest remaining unknown: r92 §0.1 states the
frame-boundary law "lands at the next frame boundary" but every report since
r92 has had to key on scheduler-owned fields, because "an unthrottled headless
run grants a variable number of idle frames per physics tick, so they drift
between reps". That is a *harness* defect sitting under the whole lane's
byte-comparability, and `--fixed-fps` is the one engine flag the lane never
touched (r92 pinned `physics_interpolation=false`, r96 pinned solver knobs,
r97–r99 pinned node/asset surfaces; the CLI rate flags appear in no prior
receipt). Pre-measuring it first (feasibility pass) showed a deterministic 1:1
idle:physics interleave at `--fixed-fps 60` with the 120-tick trajectory
byte-identical to the unpinned run — so this round chose the rate surface over
the two asset-side candidates (a skinned-GLTF/`PhysicalBone3D` follow-up, and
glTF animation channels onto bodies). The `PhysicalBoneSimulator3D` probe did
run (feasibility pass; see the deferred bullet in §10): the class exists and
instantiates, a simulator child
is what makes `physical_bones_start_simulation()` bind (`pb0_parent=Sim`), and
the r93 follow-up is *deferred with a named rig defect* rather than guessed —
but its measurement value here was lower than a scheduler law that upgrades
every future fixture.

**Headline.** `--fixed-fps N` turns a `--headless --script` SceneTree run into a
wall-clock-independent scheduler: process delta becomes exactly `1/N`, the
process-frames-per-physics-tick ratio becomes exactly `N/60`, the physics
trajectory is bit-identical to the unpinned run, and `--quit-after M` becomes a
deterministic **tick** budget of `M·60/N` ticks. Under `--fixed-fps 60` a
120-tick run takes **1 ms** instead of **2008 ms** and its receipt is
byte-identical across 3 reps under 8-way concurrent load.

---

## 1. The rate law, measured

`rs_sched.gd` runs one falling sphere for 120 physics ticks and reports the
process-frames-per-tick histogram, the per-tick `y`/`vy` trajectory hash, and
the first frames' deltas. `RS_END` per mode (GP; identical on Jolt except where
noted; Dummy differs only in the trajectory hash — it never integrates):

| mode | `n_pr` | `fpt` histogram | process delta law | traj |
|---|---|---|---|---|
| base | 293 | `[2:69, 3:50, 4:1]` | wall-clock, variable | `2311ff14cd04c227` |
| `--fixed-fps 5` | 11 | `[0:110, 1:10]` | 1/5 | same |
| `--fixed-fps 10` | 21 | `[0:100, 1:20]` | 1/10 | same |
| `--fixed-fps 30` | 61 | `[0:60, 1:60]` | 1/30 (transient, §2) | same |
| `--fixed-fps 60` | 120 | `[0:1, 1:119]` | **1/60, exactly** | same |
| `--fixed-fps 90` | 180 | `[0:1, 1:59, 2:60]` | 1/90 | same |
| `--fixed-fps 120` | 239 | `[0:1, 2:119]` | 1/120 | same |
| `--fixed-fps 240` | 478 | `[1:1, 4:119]` | 1/240 | same |

- **[O] The interleave is exact**: `n_pr = 120·N/60 + 1` for N ≥ 60, and the
  histogram is a single value (`1:119` at N=60, `2:119` at N=120, `4:119` at
  N=240) plus the startup frame. At N=90 the 1.5 frames/tick split alternates
  `1:59, 2:60`. For N < tps the histogram is `{0:…, 1:…}` (2 ticks/frame at 30,
  6 at 10, 12 at 5).
- **[O] Wall-clock independence**: `RS_TIME` for the same 120-tick cell —
  base `t=2009 t=2008 t=2008`; `ffps60 t=1 t=1 t=1`; `ffps5 t=1 t=1 t=1`.
  The pinned receipt is a pure function of the flags.
- **[O] The physics does not move**: the whole-trajectory hash
  `2311ff14cd04c227` is identical in **all** of base, 5, 10, 30, 60, 90, 120,
  240, `ds_off`, `maxfps60`, `delay10`, `ffps60_delay10`, and the two bakes;
  GP and Jolt agree byte-for-byte on every `RS_PH` row
  (`diff <(grep ^RS_PH proj_ffps60) <(grep ^RS_PH proj_jolt_ffps60)` → empty).
  Dummy's hash `a2d4de09077612bf` is the r89 degenerate (bodies never
  integrate: `y=5.000000 vy=0.000000` at every tick).
- **[O] The only field the rate mode moves inside a physics row is `ifr`**
  (`Engine.get_physics_interpolation_fraction()`): base `diff` vs `ffps60`
  shows *only* `ifr=` lines differing, with `d=`, `y=`, `vy=` byte-identical.
  Verbatim (`rs_proj_base.r1` → `rs_proj_ffps60.r1`, same ticks):

```
< RS_PH n=30 pf=30 d=0.016666667 y=3.834048 vy=-4.627786 ifr=0.156160
> RS_PH n=30 pf=30 d=0.016666667 y=3.834048 vy=-4.627786 ifr=0.000000
```

- **[O] `ifr` is the tick phase, and the pinned modes pin it**: at every
  physics row, N ≥ tps gives exactly `0.000000` (60/120/240; 90 gives a
  repeating `0.000000, 0.333333` pattern), N < tps gives `1.000000`
  (10/5) or `0.500000…1.000000` (30). This closes r92 §7.8's residue: the
  fraction is not an interpolation signal, and `--fixed-fps` makes it a
  deterministic function of the mode.
- **[O] Verbatim law lines** (`rs_proj_ffps60.r1`):

```
RS_BOOT tps=60 ip=false maxfps=0 ts=1.000000 jit=0.500 cap=8 ds=true argz=2 userz=1
RS_PR n=1 pf=1 d=0.016666667 ifr=0.000000 ts=1.000000
RS_PR n=2 pf=2 d=0.016666667 ifr=0.000000 ts=1.000000
RS_PR n=3 pf=3 d=0.016666667 ifr=0.000000 ts=1.000000
RS_END n_pr=120 n_ph=120 pf=120 ff=120 fpt=[0:1, 1:119] traj=2311ff14cd04c227
RS_TIME t=1
```

and the unpinned contrast (`rs_proj_base.r1`), which is the drift r92 named:

```
RS_PR n=1 pf=0 d=0.008333333 ifr=0.500000 ts=1.000000
RS_PR n=2 pf=0 d=0.004166667 ifr=0.750000 ts=1.000000
RS_PR n=3 pf=0 d=0.000620333 ifr=0.787220 ts=1.000000
RS_END n_pr=293 n_ph=120 pf=120 ff=293 fpt=[2:69, 3:50, 4:1] traj=2311ff14cd04c227
RS_TIME t=2009
```

---

## 2. The startup frame, and the N < tps transient **[O]**

- The **first process frame** is the only frame that does not carry `1/N` for
  N ≥ tps: N=60/90/120 report `d=0.016666667` (1/60), N=240 reports
  `d=0.008333333` (1/120), then the law is exact from frame 2.
- For N < tps the first frames **converge to 1/N with a small rep-stable
  transient**: N=30 → `0.025000000, 0.033333333, 0.041666667, 0.029166667,
  0.030000000, 0.032500000 …`; N=10 → `0.1, 0.1, 0.1, 0.095833333,
  0.096666667, 0.099166667 …`; N=5 → same shape ×2. The transient is
  **byte-identical across reps** and **not delta smoothing**: the
  `proj_dsfalse` bake (`application/run/delta_smoothing=false`, `RS_BOOT
  … ds=false`) and `--delta-smoothing disable` both reproduce it exactly
  (§5.3). **[?]** its generating formula was not derived.
- For N < tps the first process frame also lands **after several ticks**
  (`ffps5`: `RS_PR n=1 pf=11`), i.e. the engine steps physics to the first
  frame boundary before the first idle callback; for N ≥ tps the first frame
  follows the first tick.

---

## 3. `--quit-after M` is a *frame* bound — and with `--fixed-fps` it is a tick bound

**[O]** `--quit-after` bounds a `--script` SceneTree main loop in process
frames. Verbatim pair (identical probe, `--ticks=100000` so only the engine
flag can end the run):

```
rs_proj_quit30.r1        RS_END n_pr=30 n_ph=10 pf=10 ff=30 fpt=[2:4, 3:5, 4:1] traj=a040a766907bda07
rs_proj_quit30_ffps60.r1 RS_END n_pr=30 n_ph=30 pf=30 ff=30 fpt=[0:1, 1:29] traj=b88b8f31210e82ab
```

- Unpinned, 30 frames buy a wall-clock-dependent 10 ticks (GP) / 11 ticks
  (Jolt, Dummy) — and the two runs' trajectories differ (`a040a766…`).
- With `--fixed-fps 60`, 30 frames buy exactly 30 ticks, byte-identical 3/3.
- `--quit-after 0` **disables** the bound: `quit0_ffps60` ran to the probe's own
  100000-tick target (n_pr=n_ph=100000, ~1 s, 268 KB receipt).
- **[O]** `_finalize()` still runs when `--quit-after` ends the loop
  (`LF_END` present in the `noquit_bound` life cell).

This is the harness primitive: `--fixed-fps 60 --quit-after M` gives a fixture
an exactly deterministic budget of M ticks with no self-quit code, and
`--fixed-fps 120 --quit-after M` gives M/2 ticks with two idle frames per tick.

---

## 4. What the companions do (and do not) do

| flag | `Engine` readback | scheduler effect | physics effect |
|---|---|---|---|
| `--fixed-fps N` | `maxfps` stays 0 | **exact N/60 frames per tick** | none |
| `--time-scale s` | `Engine.time_scale=s` (`ts05` `ts=0.500000`) | none — `fpt` histogram exactly base's | deltas ×s (`PH n=2 d=0.008333333 y=4.999320 vy=-0.081667` vs base `y=4.997278 vy=-0.163333`); traj `c20df6e2…` |
| `--max-fps 60` | `maxfps=60` | throttles real time; `fpt=[1:118, 2:1, 3:1]` — **not** exact | none (traj unchanged) |
| `--delta-smoothing disable` | project setting still `ds=true`; the bake `ds=false` | **none** in every mode | none |
| `--frame-delay 10` | — | none (`delay10` `t=2015` vs base `t=2008`; under `--fixed-fps 60` `t=1`) | none |
| `physics_jitter_fix=0.0` (bake) | `jit=0.000` | **phase shift of one frame** at N<tps (`ffps30`: `n_pr` 61→60, `fpt` `[0:60,1:60]`→`[0:61,1:59]`; `ffps5`: 11→10) | none (traj unchanged) |
| `max_physics_steps_per_frame=1` (bake) | `cap=1` | **none** — `ffps5` still does 12 steps/frame | none |

- **[O] `--time-scale` is a sim-time knob, not a scheduling knob**: it scales
  both the process delta and the `_physics_process` delta while leaving the
  frames-per-tick histogram and the tick-per-wall-second rate untouched.
- **[O] `physics_jitter_fix` is live under `--fixed-fps`** (r92 §7.7 recorded
  its arm as a no-op because it used the default). Base mode is indifferent
  (`jit0` vs default: identical `RS_END`), so the knob only manifests once the
  frame clock is pinned.
- **[O] `max_physics_steps_per_frame` did not clamp anything in this rig**:
  `cap=1` and `cap=8` are indistinguishable at `--fixed-fps 5`, where each
  frame performs 12 physics steps. **[?]** whether it is live in a rendered /
  non-`--script` loop is untested.
- **[O] `--delta-smoothing` and `--frame-delay` are inert** in `--headless
  --script` (flag and project bake both). **[I]** both live on the
  render/vsync path, which `--script` + headless bypass.

---

## 5. The r92 frame-boundary law and the r93 signal law under a pinned rate

### 5.1 `RemoteTransform3D`: the law is unchanged, its arithmetic is now pinned

`rs_rt.gd phase` (write in the writer's physics callback, read by a later tree
node in the same physics frame and by the reader's idle callback):

```
ffps60   RT write_at_E W_E n=2 pf=3 ff=2 seq=4 IMM O=(0.0000,0.0000,0.0000)
         RT arm=write_at_E p=R_E n=2 pf=3 ff=2 seq=5 O=(0.0000,0.0000,0.0000)
         RT arm=write_at_E p=R_F n=3 pf=3 ff=2 seq=6 O=(1.0000,0.0000,0.0000)
ffps30   RT arm=write_at_E p=R_E n=2 pf=3 ff=1 seq=4 O=(0.0000,0.0000,0.0000)
         RT arm=write_at_E p=R_F n=2 pf=3 ff=1 seq=5 O=(1.0000,0.0000,0.0000)
```

- **[O] r92 §0.1 holds verbatim under both pinned modes**: never synchronous,
  never visible to a later node in the same physics frame, visible to the idle
  phase of the frame that ran the physics step. The propagation pass therefore
  sits **between the physics step and the idle callbacks of the same frame** —
  a refinement of "the next frame boundary" that the unpinned scheduler could
  not express (r92's `p=R_F` row was a *later idle frame of the same tick*).
- **[O] The r92 `lag` law is unchanged**: `LG write=1.0 imm=0.0 after1=1.0
  after2=1.0` in every mode; only the frame index differs (base `ff1=2,4,6,8`,
  `ffps60/120` `ff1=1,3,5,7`).
- **[O] The propagated transform still reaches the physics server by the next
  tick** (`rt_proj_ffps60_srv.r1`: after the write, `node=O=(5.0000,0,0)` and a
  ray from `(5,3,0)` to `(5,-3,0)` reports `hit@5.000,0.500,0.000`).

### 5.2 `Area3D`: the r93 in-tick ordering survives the collapse

```
ar_proj_ffps60_exit.r1   AR p=IF pf=29 ff=28 ovA=0 by=3.9112
                         AR p=A sig=body_entered pf=29 ff=28 seq=57 by=3.9112
                         AR p=MUT pf=34 ff=33 seq=67 teleport_to_y=8
                         AR p=A sig=body_exited  pf=35 ff=34 seq=70 by=7.9099
                         AR_END case=exit n_e=60 first=29 last=35 ovA=0
```

- **[O]** enter at tick 29, exit at tick 35 (teleport written at 34) — the same
  tick indices as the unpinned run (`first=29 last=35` in both), so the rate
  mode does not move the signal tick; the signal still lands between
  `_integrate_forces` and `_physics_process` of the detecting tick.
- **[O]** Under `--fixed-fps 60` the tick's physics callbacks share one process
  frame (`ff = pf − 1`), so the receipt can now be keyed on `pf` *and* `ff`.
- **[O]** Dummy emits **no** signals at all (`first=-1 last=-1`): the ball never
  integrates on that backend (r89/r92 degenerate path), so Dummy is an expected
  null for every motion-driven cell.

---

## 6. Lifecycle / teardown (6 reps per cell)

| case | result | verbatim |
|---|---|---|
| `clean` | rc=0, `quit()` from `_physics_process` at tick 5 | `LF_CLEAN_QUIT pf=5 ff=4` (pinned) / `pf=5 ff=15` (unpinned) |
| `quit_idle` | rc=0, `quit()` from `_process` at frame 3 | `LF_QUIT_IDLE n_f=3 ff=2` |
| `freetree` | rc=0, `stage.free()` mid-run, 3 further ticks | `LF_FREETREE freed pf=3 valid=false`, `LF_FREETREE_END pf=6` |
| `err` | rc=0 **with** a SCRIPT ERROR line (r98 hazard re-confirmed) | `SCRIPT ERROR: Invalid call. Nonexistent function 'no_such_method_at_all' in base 'RigidBody3D'.` then `LF_ERR_END pf=6` |
| `noquit_bound` | rc=0, ended by `--fixed-fps 60 --quit-after 20` | `LF_TICK n_e=20 pf=20`, `LF_END case=noquit_bound n_e=20 n_f=20`, byte-identical 6/6 |
| `noquit_unbound` | rc=137 (the driver's 8 s kill) — the declared negative control | `LF_TICK n_e=453 pf=453` at kill time (≈57 ticks/s, real-time physics) |
| `finalize_touch` | rc=0 + SCRIPT ERROR: `_finalize` sees the freed tree | `SCRIPT ERROR: Invalid access to property or key 'global_position' on a base object of type 'previously freed'.` |
| `quit_double` | rc=0, `quit()` is immediate — no callback runs after it | `LF_QUIT_DOUBLE_PRE ff=2`, no `LF_AFTER_QUIT` |

- **[O]** The rate mode changes no teardown outcome; the only field it moves is
  the idle-frame counter. 6/6 reps byte-identical on every life cell except the
  unbound negative control (whose kill instant varies).
- **[O]** `--quit-after` ends the loop *cleanly* (rc=0, `_finalize` runs), so a
  fixture can drop its self-quit entirely.

---

## 7. Harness hazards pinned by this round

1. **Engine args go before `--script`; script args after `--` are only visible
   to `OS.get_cmdline_user_args()`.** `CLS_ARGV engine=--script|res://rs_cls.gd`,
   `CLS_USER user=`. A `--fixed-fps` placed after `--` is silently inert — the
   first feasibility run measured all eight rate flags as no-ops for exactly
   this reason, and the corrected run shows them live. Any lane harness that
   appends flags to the script side is measuring the default.
2. **`--quit-after` is frames, not ticks** (§3); `--quit-after 0` disables it.
3. **Wall-clock fields must live on their own line** or pinned receipts cannot
   be byte-compared (`RS_TIME`/`AR_TIME` convention).
4. **`_finalize()` runs after the tree is freed** — touching a node there is a
   `previously freed` script error at rc=0 (§6).
5. **Jolt prints a sporadic job-system warning** — verbatim: `WARNING: Jolt
   Physics job system exceeded the maximum number of jobs. This should not
   happen. Please report this. Waiting for jobs to become available... at:
   CreateJob (modules/jolt_physics/spaces/jolt_job_system.cpp:123)`. It appears
   in 5/552 receipts (`jolt_ffps120` ×2, `jolt_quit30_ffps60` ×2,
   `jolt_quit0_ffps60` ×1) and is the *only* rep-difference in the two pinned
   cells that carry it. **[I]** thread-pool saturation when frames are dense.
6. **rc=0 is blind** (r98 hazard re-confirmed): the `err` and `finalize_touch`
   cells exit 0 with SCRIPT ERROR lines; match on text, not rc.

---

## 8. Rep identity, exhaustively

160 cells with ≥2 reps; 124 byte-identical after dropping `RS_TIME`/`AR_TIME`.
The 36 unstable cells, all named:

| group | cells | cause |
|---|---|---|
| unpinned rate modes | `base`, `ds_off`, `ts05`, `ts2`, `maxfps60`, `delay10`, `quit30` on 3 backends + 6 bake-bases | the r92 idle-multiplicity signature — **this is the defect the round removes** |
| pinned + Jolt | `jolt_ffps120`, `jolt_quit30_ffps60` | the job-system warning line (§7.5); `RS_END` identical |
| rt | `rt_{proj,jolt,dummy}_base_phase` | unpinned `base` mode only; all pinned rt cells byte-identical |
| area | `ar_proj_base_enter`, `ar_dummy_base_{enter,exit}` | unpinned `base`; Dummy has no signals (variable row set) |
| life | the 3 `noquit_unbound` cells | kill instant varies by design |

- **[O]** Every `--fixed-fps` cell is byte-identical across its reps and across
  8-way concurrent load, except the two Jolt warning cells.
- **[O]** Cross-backend: `RS_END` is identical GP↔Jolt on every pinned mode
  (including the trajectory hash); Dummy differs only in the trajectory hash
  (no integration) — the scheduler is backend-inert, measured, not assumed.
- `audit.py` rc census: 157 tags rc=0 and 3 tags rc=137 (the three
  `noquit_unbound` tags, 6 reps each = 18 children); child-level `.exit`
  census over all 552: `534× rc=0`, `18× rc=137` (declared).

---

## 9. Author directives (actionable)

1. **Adopt `--fixed-fps 60 --quit-after <M>` for new headless fixtures** that
   count frames/ticks: M frames = M ticks, no self-quit, byte-reproducible.
   Use `--fixed-fps 120` when a fixture needs sub-tick idle resolution (2
   frames/tick) and `--fixed-fps 30` when it needs 2 ticks/frame.
2. **Re-key the r92/r93 fixtures on `pf`+`ff`** now that the interleave is
   exact: the RT propagation is visible in the idle phase of the frame that ran
   the physics step, and an area signal shares the detecting tick's frame.
3. **Pin `physics_jitter_fix` explicitly in any fixture that counts frames** —
   it shifts the fixed-fps phase by one frame at N < tps.
4. **Do not build fixtures on `--delta-smoothing`, `--frame-delay`, or
   `max_physics_steps_per_frame`** in this rig; all three are inert (§4).
5. **Keep wall-clock fields on their own line**; expect the Jolt warning line
   in dense-frame Jolt receipts and match message text, never line numbers.
6. **Never place engine flags after `--`**; read script args with
   `OS.get_cmdline_user_args()`.

---

## 10. Observation / inference / unknown

Observation (receipt-pinned, rep-stable): every number, histogram, delta,
trajectory hash, byte-identity claim, warning string and rc above.

Inference (labelled): the accumulator reading of `--fixed-fps` (process delta
`1/N`, physics stepped at `1/tps`) behind §1; the render-path explanation for
the inert `--delta-smoothing`/`--frame-delay` (§4); thread-pool saturation as
the Jolt warning trigger (§7.5); the first-frame transient being a startup
artifact rather than smoothing (§2, disproved smoothing directly).

Unknown / deferred:
- **Rendered / non-`--script` main loops** — every cell here is `--headless
  --script`; whether the same law holds with a real `SceneTree` main loop,
  `--write-movie`, or an exported template is unmeasured. **[?]**
- The exact accumulator formula behind the N < tps first-frame transient
  (measured byte-stable, not derived). **[?]**
- Whether `max_physics_steps_per_frame` is live outside this rig. **[?]**
- `--fixed-fps` × `physics_interpolation=true` in a *rendered* context — r92
  §7.8's residue; headless exposes only the tick phase, which §1 now pins. **[?]**
- `--max-fps` interleave outliers (`2:1, 3:1`) vs host load. **[?]**
- **Asset-side follow-ups deferred, with the rig defect named** (§0): the
  feasibility probe found `PhysicalBoneSimulator3D` exists and instantiates
  (`CLS_CLASS PhysicalBoneSimulator3D exists=true inst=true`), and that a
  simulator child is what makes `physical_bones_start_simulation()` bind the
  bodies (`PB_START bones=2 pb0_parent=Sim sim_children=2` vs `pb0_parent=Skel`
  without it) — but the bodies still did not integrate in that minimal rig, so
  the r93 "bone poses never follow" question is **not** resolved and must be
  re-armed with a skinned/imported skeleton (r98's `GLTFDocument` path) and a
  joint type other than `JOINT_TYPE_NONE`. **[?]**

---

## 11. Reproducing and host hygiene

```
cd corpus/live/r100-scout
python3 driver.py --batch sched --jobs 8   # 237 children
python3 driver.py --batch rt    --jobs 8   # 108
python3 driver.py --batch area  --jobs 8   #  54
python3 driver.py --batch life  --jobs 8   # 144
python3 driver.py --batch census --jobs 3  #   9
python3 audit.py && python3 sum.py
```

- Every child was `timeout -s KILL` bounded and accounted for by a `.exit`
  receipt (552/552). No `r100-scout` godot process was alive at completion
  (`pgrep -af godot` matched only other lanes' trees: 2D `r87-verifier`/
  `r87-critic`/`r87-simplifier` and the 3D `r92-author` lane).
- Writes: `corpus/live/r100-scout/**` (gitignored) + this report. No commits,
  no fixture edits, no other tracked-tree writes.
- **Not this seat's write (disclosed):** `git status --porcelain` at completion
  shows `?? corpus/fixtures/r92_child.gd` (mtime 14:35:04, authored while this
  lane ran) — the concurrently running **r92-author** lane's probe
  (`godot --path proj_jolt --script res://r92_child.gd`, cwd
  `corpus/live/r92-author/dev/proj`). It is left untouched; this seat wrote no
  file outside `corpus/live/r100-scout/` and `reports/round-100/`.
