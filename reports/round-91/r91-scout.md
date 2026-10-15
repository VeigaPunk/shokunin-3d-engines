# r91 scout — the bpy rigid-body world and its point cache (Blender 5.2.1 headless)

Lane: g3d · runtime `/usr/bin/blender` **5.2.1 LTS** (hash `9e2066aef7ef`, built
2026-09-01), embedded CPython 3.14.7, `blender -b -P`, this host.
Evidence: `corpus/live/r91-scout/` — `probes/` (19 arm scripts + the `rbc.py` helper + 17 superseded
scratch probes), `driver.py`, `audit.py`, `runs/20261015T055556607370Z/`
(**111 children, 699 `ARM` rows**), `manifest.sha256` (375 files), `RECEIPTS.md`.
Reps: **37 arms × 3 fresh processes**; `audit.py` reports `drift=none` for
35/37 — the two drifting arms are the render arms and only their PNG sha256
field moves (reported as a measured cell below, not hidden).
No tracked fixture, `LOG.md`, or `SCORECARD.md` write; the only tracked-tree
write is this report. `corpus/fixtures/**` was read only.

Confidence labels: **[O]** observation (receipt-pinned, rep-stable),
**[I]** inference, **[?]** unknown / not decided by these cells.

---

## 0. Surface choice and the shape of the thing

The r91 brief offered the bpy bake surface or a three.js physics adapter. The
three.js fixture (`corpus/fixtures/three/`) pins `three@0.186.1` only — **no
physics adapter dependency exists**, so that surface would need a new tracked
dependency (the npm registry is reachable: `cannon-es` resolves to 0.20.0) and
a new fixture; it stays unmeasured here. The bpy eval/depsgraph lattice is
already pinned by r79–r82 and the Godot physics surfaces by r83–r90; the
**rigid-body world + point cache** subsystem had **zero** cells in the lane.

Canonical scene for every cell (one shape, disclosed): factory-empty scene, a
size-1 cube `ball` (half-extent 0.5, default mass 1) at `(0,0,5)` made ACTIVE,
a 20×20 plane at the origin made PASSIVE, `bpy.ops.rigidbody.world_add()`,
scene frames 1..60, RBW defaults (`substeps_per_frame=10`,
`solver_iterations=10`, `use_split_impulse=False`, `time_scale=1.0`), scene fps
24 (Blender's factory default). The trajectory hash `h` is
`sha256(repr([(f, x, y, z) rounded to 6dp for f in 1..40]))[:16]` over the
**evaluated** transform `ball.evaluated_get(depsgraph).matrix_world.translation`.

**Reference trajectory (all three reps, every process):**
`h = 3302e3c1de9c5dd0`, `f1=(0,0,5)`, `f10=(0,0,4.306076)`,
`f20=(0,0,1.942529)`, `f30=(0.226293,-0.001284,0.612535)`,
`f40=(0.381156,-0.006439,0.500823)`.

Two objects own the surface and they are not the same thing:

- `scene.rigidbody_world.point_cache` (`PointCache`) — `frame_start=1`,
  `frame_end=250`, `frame_step=1`, `use_disk_cache=False`,
  `is_baked`/`is_outdated`/`is_baking`/`is_frame_skip`, `info`.
- the operators `bpy.ops.ptcache.bake_all` / `free_bake_all` (headless-armable)
  vs `bpy.ops.ptcache.bake` / `free_bake` / `bake_from_cache` (UI-only).

---

## 1. Arm table (verbatim-armable cells)

Each cell = one fresh `blender -b -P` child; commands run from
`corpus/live/r91-scout/`. `driver.py` writes `runs/<stamp>/<arm>.r<k>.{stdout,stderr,meta}`.
Every arm below was run ×3 and is byte-identical across reps unless marked.

| # | command | expected signature (verbatim) | falsified if |
|---|---|---|---|
| 1.1 | `python3 driver.py --only free_det --reps 3` | `sweep1 … h=3302e3c1de9c5dd0`; `sweep2 … eq1=True`; `sweep3_after_excursion … eq1=True`; `cache_after1 info='40 frames in memory (7 KiB).' baked=False outdated=False`; `fwd41_60 f45=(0.379696,-0.005126,0.500063) f60=(0.379671,-0.005131,0.500063)`; `cache_after3 info='60 frames in memory (10 KiB).'` | any sweep hash differs, or the hash moves across processes/reps |
| 1.2 | `--only bake_equiv` | `free_run h=3302e3c1de9c5dd0`; `bake_all ret={'FINISHED'} baked=True outdated=False info='250 frames in memory (41 KiB).'`; `baked_run eq_free=True h=3302e3c1de9c5dd0`; `narrow_readback n=20 eq_free20=True f20=(0.000000,0.000000,1.942529)` | the baked read differs from the free run |
| 1.3 | `--only bake_range_default` | raw fd1 flood **250** lines `bake: frame 1 :: 250` … `bake: frame 250 :: 250`; `default_after baked=True info='250 frames in memory (41 KiB).'`; `default_read h=3302e3c1de9c5dd0` | the cold-start bake trajectory differs from the free run, or the bake covers the scene range 1..60 |
| 1.4 | `--only bake_range_scene20` (scene `frame_end=20`, pc 1..250) | flood **250** lines `… :: 250`; `scene20_read h=3302e3c1de9c5dd0` | `scene.frame_end` bounds the bake |
| 1.5 | `--only bake_range_pc20` (pc `frame_end=20`) | flood **20** lines `1 :: 20` … `20 :: 20`; `pc20_read f20=(0.000000,0.000000,1.942529) f40=(0.000000,0.000000,1.942529)` | the bake ignores `pc.frame_end` |
| 1.6 | `--only bake_range_pc5_30` (pc 5..30) | flood **26** lines `5 :: 30` … `30 :: 30`; `pc5_30_read f20=(0.000000,0.000000,3.087401) f40=(0.074437,-0.000000,0.555247)` | the bake ignores `pc.frame_start`, or frame 20 ≠ free-run frame 16 |
| 1.7 | `--only bake_range_presweep20` (sweep 1..40 first, then pc `frame_end=20`) | flood **40** lines `1 :: 40` … `40 :: 40` | the bake stops at `pc.frame_end` when the cache already holds later frames |
| 2.1 | `--only order` | `jump40 loc=(0.000000,0.000000,5.000000) fcur=40`; `jump_then_seq40 h=3302e3c1de9c5dd0`; `backward back1=(0.000000,0.000000,5.000000) back20=(0.000000,0.000000,1.942529) back40=(0.381156,-0.006439,0.500823) fwd60=(0.381156,-0.006439,0.500823) re20=(0.000000,0.000000,1.942529) re1=(0.000000,0.000000,5.000000)`; `subframe f40_5=(0.381156,-0.006439,0.500823)`; `subframe_next f41=(0.379702,-0.005126,0.500062)`; `frame0 loc=(0.000000,0.000000,5.000000) fcur=0` | a jump simulates, or the backward re-reads differ from the forward values |
| 2.2 | `--only baked_jump` | `baked info='40 frames in memory (7 KiB).'`; `jump40 loc=(0.381156,-0.006439,0.500823)`; `jump60_past_cache loc=(0.381156,-0.006439,0.500823)`; `seq40 h=3302e3c1de9c5dd0` | a baked jump is not addressable, or frames past the bake range move |
| 3.1 | `--only window_end20` (pc `frame_end=20`, **no bake**) | `end20_head20 f20=(0.000000,0.000000,1.942529)`; `end20_tail f21=(0.000000,0.000000,1.942529) f25=(same) f30=(same) f40=(same) frozen=True h=6498e1a38a4b7b9f` | frames past `pc.frame_end` advance |
| 3.2 | `--only window_start20` (pc `frame_start=20`) | `start20_head20 f20=(0.000000,0.000000,5.000000)`; `start20_tail f21=(0.000000,0.000000,4.990638) f25=(0.000000,0.000000,4.783453) f30=(0.000000,0.000000,4.144729) f40=(0.000000,0.000000,1.615016) frozen=False h=3a72772535e85419` | the sim runs before `pc.frame_start`, or frame 21 ≠ free-run frame 2 |
| 3.3 | `--only window_scene20` (scene `frame_end=20`, pc 1..250) | `scene20_tail f21=(0.000000,0.000000,1.615016) f25=(0.033111,-0.000000,0.517439) f30=(0.226293,-0.001284,0.612535) f40=(0.381156,-0.006439,0.500823) frozen=False h=74e6cfb2e009f02f` (≡ `window_wide`) | the scene range bounds the sim |
| 3.4 | `--only window_end20_baked` / `--only window_end20_bake_only` | both `…_tail … frozen=True h=6498e1a38a4b7b9f` (identical to 3.1) | the bake (kept or freed) changes the window behaviour |
| 3.5 | `--only resim_control` (bake 1..20, no mutation, step 21..60, then widen to 60) | `tail f21=f30=f40=f60=(0.000000,0.000000,1.942529) frozen=True`; `after_widen f41=f50=f60=(0.000000,0.000000,1.942529) frozen=True info='20 frames in memory (3 KiB).'` | widening the range resumes the sim |
| 4.1 | `--only stale_ts` | `mutate ts=0.25 outdated=True baked=True`; `baked_ts025 eq_free=True h=3302e3c1de9c5dd0`; `freed baked=False outdated=False info='40 frames in memory (7 KiB).'`; `freed_ts025 eq_free=True h=3302e3c1de9c5dd0`; `disabled enabled=False eq_free=False h=5c473677cca8d53a` (every frame `(0.000000,0.000000,5.000000)`); `beyond_cache f45=(0.381156,-0.006439,0.500823) f60=(same) outdated=False` | a sim-input change re-simulates the served frames, or `free_bake_all` flushes them |
| 4.2 | `--only ts025_control` | `ts=0.25 h=5c2eb7d566c54855`; `f10=(0.000000,0.000000,4.956466) f20=(0.000000,0.000000,4.807371) f30=(0.000000,0.000000,4.552688) f40=(0.000000,0.000000,4.192864) last=(0.000000,0.000000,3.159576)` | this from-scratch control is not the ts=0.25 trajectory |
| 4.3 | `--only resim` (pc `frame_end=20`, sim 1..20, bake, mutate ts, free bake, toggle off/on, step 41..60) | `post_mutation_forward f21=f30=f40=(0.000000,0.000000,1.942529) h=6498e1a38a4b7b9f`; `reread_head eq_pre=True`; `after_toggle eq_pre=True`; `after_free_bake eq_pre=True info='20 frames in memory (3 KiB).'`; `far_forward f45=f60=(0.000000,0.000000,1.942529)` | any of the toggles re-simulates |
| 4.4 | `--only resim_partial` (pc 1..60, sim 1..20, mutate ts, step 21..40, re-read head) | `tail f21=(0.000000,0.000000,1.862350) f25=(0.000000,0.000000,1.531338) f30=(0.000000,0.000000,1.094436) f40=(0.009188,-0.000000,0.504694) h=393edd37abcaef22`; `head_reread eq_head=False f20=(0.000000,0.000000,4.807371)` | the tail equals the ts=1 baseline (→ no effect) or the ts=0.25 control (→ clean re-sim) |
| 4.5 | `--only resim_trace` (ordered single-frame reads after the mutation) | `R5 f05=(0.000000,0.000000,4.860652)`; `R20 f20=(0.000000,0.000000,4.860652)` (**the same value at a different frame**); `T` frozen at `4.860652` for 21..40; `H2` = the ts=0.25 control (`f10=(0.000000,0.000000,4.956466)`, `f20=(0.000000,0.000000,4.807371)`); `T2 f30=(0.000000,0.000000,4.552688)`; `T3 f60=(0.000000,0.000000,3.159576)`; `SUMMARY h1=c3af015e07cdf24e t=d32f1a69ce8ae319 h2=db5a3d0cbf7ef968 t2=4fd4be6202d9e92d t3=0b43f52c0daceded h1_eq_h2=False t_eq_t2=False` | the served trajectory is independent of the read order |
| 5.1 | `--only fps24` / `--only fps60` / `--only fps120` | `h=3302e3c1de9c5dd0` / `h=1f12776ddff6285f last=(0.000000,0.000000,2.940532)` / `h=9c73c3f28300910c last=(0.000000,0.000000,4.482864)` | the three hashes are equal (a fixed internal step) |
| 5.2 | `--only substeps1` / `substeps10` / `substeps40` | `h=4161bab53d2cbe73 last=(0.773845,0.195946,0.506597)` / `h=3302e3c1de9c5dd0` / `h=898e0dd0a6c61fc4 last=(0.370623,-0.000001,0.500063)` | any two are equal |
| 5.3 | `--only iters1` / `--only iters10` | `h=6eae9b3b9a01a1dd last=(0.243452,0.005565,0.499976)` / `h=3302e3c1de9c5dd0` | they are equal |
| 5.4 | `--only split0` / `--only split1` | `h=3302e3c1de9c5dd0` / `h=a3657c2e88f737c2 last=(0.133979,-0.001840,0.500063)` | they are equal |
| 6.1 | `--only render` (Cycles CPU, 1 sample, 64×64, camera+sun) | `jump40 pre=(0.000000,0.000000,5.000000) post=(0.000000,0.000000,5.000000) fcur=40`; `after_step20 f20=(0.000000,0.000000,1.942529)`; `jump40_from20 pre=(0.000000,0.000000,1.942529) post=(0.000000,0.000000,1.942529)`; `seq40 pre=(0.381156,-0.006439,0.500823) post=(same)`; `compare h1_eq_h2=False h3_diff=True` | `post ≠ pre` (the render steps the sim), or the jumped-to frame renders the stepped state |
| 6.2 | `--only render_det` | `same_state … stable=False` (three renders of one identical state, not all equal); `moved_state … differs=True` | `stable=True` — then PNG bytes could be pinned as a witness |
| 7.1 | `--only bake_ops` | `ptcache_polls POLL bake=False bake_all=True free_bake=False free_bake_all=True bake_from_cache=False`; `rigidbody_polls POLL bake_to_keyframes=True world_remove=True`; `bake_call err=RuntimeError msg=Operator bpy.ops.ptcache.bake.poll() failed, context is incorrect`; `from_cache_call err=RuntimeError`; `b2k_call err=RuntimeError`; `b2k_state actions=0 anim_data=False` | `ptcache.bake` polls True headless, or `bake_to_keyframes` produces an action |
| 8.1 | `--only disk_flag` | `rbw_set disk=False ext=False filepath=/tmp/r91scout-disk/rb_`; `rbw_external disk=False ext=True`; `rbw_after_sweep n=0 names= info='No valid data to read!'`; `rbw_after_bake n=0 baked=True info='No valid data to read!'`; `cloth_set disk=False`; `cloth_after_sweep n=0 info='10 frames in memory (30 KiB).'` | the disk flag sticks, or `use_external=True` leaves a working cache |
| 9.1 | `--only ptr_stale` / `--only ptr_fresh` | `rc=-11` (3/3), rows `reset` + `pre_write`, **no** `post_write`, **no** `PROBE_DONE` / `rc=0` with `post_write ts=0.25` | the stale-pointer write is benign |

---

## 2. Observed rules

### 2.1 The point cache's frame range IS the simulation window **[O]**

`pc.frame_start`/`pc.frame_end` (default 1..250) bound the rigid-body solver,
and **frame k inside the window shows trajectory step `k − frame_start + 1`;
frames outside the window hold the boundary state.**

| cell | window | read | result |
|---|---|---|---|
| 3.1 | 1..20 | f21..f40 | frozen at the f20 state, `frozen=True` |
| 3.2 | 20..250 | f20 → `(0,0,5.0)`; f21 → `(0,0,4.990638)` = free-run **f2**; f40 → `(0,0,1.615016)` = free-run f21 | sim starts at `frame_start` |
| 3.3 | 1..250 (scene 1..20) | f21..f40 | normal motion — the **scene** range is irrelevant |
| 1.6 | 5..30 | f20 → `(0,0,3.087401)` = free-run **f16**; f40 → `(0.074437,-0.000000,0.555247)` = free-run f26 = the frame-**30** state | phase shift + hold past `frame_end` |
| 3.5 | 1..20 → widened to 1..60 | f41..f60 | still frozen: **widening after the fact does not resume** |

The scene range is *not* the sim window: with scene 1..20 and pc 1..250 the
trajectory is byte-identical to the wide run (`h=74e6cfb2e009f02f`, 3.3 ≡
`window_wide`). This is the production trap in one row: a bake is only as long
as the cache range, and everything past it is a frozen hold, not a slow-down.

### 2.2 `bake_all` ≡ free-run; the bake range is the cache range **[O]**

- Cold start, bake 1..250, then read 1..40: `h=3302e3c1de9c5dd0` — **identical
  to the free run** (1.3). Baking does not perturb the trajectory on this build.
- The bake covers `[pc.frame_start, pc.frame_end]` — 250 lines for the default,
  20 for `frame_end=20`, 26 for 5..30 — and ignores `scene.frame_start/end`
  (1.4: scene 1..20 still bakes 1..250). The bake range is witnessed from the
  operator's own raw fd1 progress lines (`bake: frame N :: M`), because
  `pc.info` is *not* a range witness: after `free_bake_all` + narrowing it still
  reads `'250 frames in memory (41 KiB).'` (1.2 `narrow_range`, `bake_narrow`).
- **[O] The bake extends to frames already simulated:** with 1..40 already
  stepped and `pc.frame_end` then set to 20, the bake still runs 1..40 (1.7,
  40 flood lines `1 :: 40`).

### 2.3 Step-order: a jump does not simulate; a bake makes jumps addressable **[O]**

- `frame_set(40)` straight from frame 1 leaves the body at `(0,0,5)` —
  **the solver never ran** (2.1). Stepping 1..40 afterwards reproduces the
  sequential trajectory exactly (`h=3302e3c1de9c5dd0`): the jump leaves no
  residue, the state is a function of the steps actually observed.
- Backward reads are served (`back1/back20/back40` equal the forward values,
  `re20`/`re1` repeat them), `frame_set(0)` holds the initial transform, and
  `frame_set(40, subframe=0.5)` returns **exactly** the frame-40 tuple
  (no sub-frame interpolation observed at 6 dp).
- After a bake, the same jump *is* answered (`jump40 = (0.381156,-0.006439,0.500823)`),
  and a jump past the baked range (`frame 60` with `pc.frame_end=40`) holds the
  frame-40 state (2.2).

### 2.4 Stale authority: `is_outdated` is not honored, `free_bake_all` does not flush **[O]**

A baked scene whose `time_scale` is changed to 0.25 (`outdated=True`) keeps
serving the old ts=1 frames byte-for-byte (`baked_ts025 eq_free=True
h=3302e3c1de9c5dd0`, 4.1) while the from-scratch ts=0.25 control is a
completely different trajectory (`h=5c2eb7d566c54855`, 4.2). `free_bake_all`
clears only `is_baked` (the frames survive: `info='40 frames in memory'`) and
the reads stay stale. Turning the RBW off (`enabled=False`) stops the sim
writing the object transform, so the reads fall back to the authored
`(0,0,5)` — the cached frames are not served through a disabled world.

### 2.5 The served trajectory depends on the read order **[O]** — the sharpest finding

One scene, one parameter set, three different trajectories:

| arm | read order after the mutation | result |
|---|---|---|
| 4.3 `resim` (window 1..20) | step 21..40 | frozen at the f20 state for 40+ frames; free bake, toggle, far-forward all leave it frozen |
| 4.4 `resim_partial` (window 1..60) | step 21..40 | a **mixed** tail `f21=1.862350 f30=1.094436 f40=(0.009188,0,0.504694)` — neither the ts=1 baseline nor the ts=0.25 control; the head re-read then returns the ts=0.25 control's `f20=4.807371` |
| 4.5 `resim_trace` (window 1..60) | read f5, read f20, step 21..40, then sweep 1..20 | `f20` returns the **frame-5** value `4.860652` (a stale hold at the wrong frame), the tail freezes at that value, and only the later 1..20 sweep rebuilds the cache — after which `f20=4.807371`, `f30=4.552688`, `f60=3.159576` match the ts=0.25 control **exactly** |

So an input change is invalidated lazily and positionally: until a sweep
re-crosses the window, reads can be stale, mixed, or held at a neighbouring
frame's value. **[I]** the mechanism is a per-frame cache whose entries are
re-filled as the sim re-crosses them, with the current frame index left
where the mutation found it; the build does not expose a "flush" that fixes it.
**[?]** whether any single call (`free_bake_all` + `frame_set(frame_start)`,
`world_remove`/`world_add`, an undo step) forces a clean rebuild is **not**
decided by these cells.

### 2.6 The physics time base is `scene.render.fps`; the solver knobs all move **[O]**

- fps 24 / 60 / 120 → three different trajectories (`3302e3c1de9c5dd0` /
  `1f12776ddff6285f` / `9c73c3f28300910c`). 24 is Blender's factory default,
  which is why "the default trajectory" is the fps-24 one. **There is no fixed
  60 Hz internal step here**: one frame of sim time is `1/fps` seconds.
- `substeps_per_frame` 1 / 10 / 40 → three different trajectories
  (`4161bab53d2cbe73` / `3302e3c1de9c5dd0` / `898e0dd0a6c61fc4`).
- `solver_iterations` 1 ≠ 10 (`6eae9b3b9a01a1dd` vs `3302e3c1de9c5dd0`) —
  the opposite of r89's Godot joint scene, where 1 ≡ 64 was a *negative* result.
- `use_split_impulse` True ≠ False (`a3657c2e88f737c2` vs `3302e3c1de9c5dd0`).

### 2.7 Render order does not advance the simulation **[O]**

A Cycles CPU render (1 sample, 64×64, camera + sun, ~0.1 s) reads the **last
stepped state**: with the sim stepped to frame 20, rendering frame 40 renders
the frame-20 state (`pre=post=(0,0,1.942529)`, `fcur=40`); after stepping 1..40
the same render shows `(0.381156,-0.006439,0.500823)`. `pre == post` in every
shot: the render neither steps the sim nor moves the frame pointer.
The **image bytes are not a stable witness**: three renders of one identical
state were `stable=False` (two of three hashes equal), so no cell pins PNG
bytes (6.2). The 3-rep drift in the two render arms is exactly this field.

### 2.8 Headless armability, disk cache, external cache **[O]**

- `bpy.ops.ptcache.bake_all` and `free_bake_all` poll **True** in
  `-b`; `ptcache.bake` (the UI operator), `free_bake` and `bake_from_cache`
  poll **False** → `RuntimeError: … poll() failed, context is incorrect`.
- `bpy.ops.rigidbody.bake_to_keyframes` polls **True** but dies inside
  `bpy.ops.anim.keyframe_insert_by_name` (same context refusal), leaving
  `actions=0 anim_data=False` — the sim→keyframe bake is **not** armable
  headless in this form.
- `pc.use_disk_cache = True` **reads back False** on both the RBW cache and a
  cloth modifier cache (the write is refused; `filepath` does stick), and no
  cache file is ever produced.
- `pc.use_external = True` is accepted and **kills the cache silently**: the
  next sweep reports `info='No valid data to read!'` with no files, and
  `bake_all` still returns `{'FINISHED'}` with `is_baked=True` over that dead
  cache. A loud success over a silent no-data state.

### 2.9 Crash class: a stale RNA pointer across a factory reset **[O]**

Writing `rbw.time_scale` through a `rigidbody_world` pointer captured before
`bpy.ops.wm.read_factory_settings()` **segfaults**: rc **-11** 3/3, breadcrumbs
`reset` + `pre_write` present, `post_write` and `PROBE_DONE` absent, Blender's
own `Writing: /tmp/blender.crash.txt` line on stdout. The fresh-pointer control
(`ptr_fresh`, writing through the rebuilt scene's world) exits 0. Python `print`
is block-buffered on this runtime, so the breadcrumbs only survive because
`rbc.emit` flushes — the first run of this arm (pre-flush) lost them entirely.

---

## 3. Lane context (no cross-runtime equivalence claimed)

r83–r90 pinned the Godot `PhysicsServer3D` / `PhysicsDirectSpaceState3D`
surfaces; r87/r88 own the Godot crash classes; r89 owns contacts/joints. This
round pins the **Blender** rigid-body subsystem and shares no code path with
those. Two contrasts are worth keeping: the Godot `solver_iterations` *negative*
result (r89 §3.3) does **not** transfer to Blender (2.6), and the Godot
"backend split" habit has a Blender analogue in the cache/read-order lattice
rather than in a second backend (there is one solver here; the Dummy-style
floor is the disabled RBW, which serves the authored transform).

---

## 4. Falsification list (claims this round tested)

1. **"`ptcache.bake_all` output diverges from a free run."** FALSIFIED as a
   general claim on this build — a cold bake 1..250 read back 1..40 gives the
   free-run hash exactly (§2.2, 1.2/1.3).
2. **"Blender's rigid body runs a fixed internal step independent of scene
   fps."** FALSIFIED — fps 24/60/120 give three different trajectories (§2.6).
3. **"The scene frame range bounds the simulation."** FALSIFIED — scene
   `frame_end=20` does not stop it; the point-cache range does (§2.1, 3.3).
4. **"Frames past the cache range are simulated on demand."** FALSIFIED —
   they hold the boundary state (§2.1, 3.1).
5. **"Widening the cache range after a freeze resumes the sim."** FALSIFIED
   (§2.1, 3.5).
6. **"A frame jump simulates the skipped frames."** FALSIFIED — a jump leaves
   the body un-simulated at its authored transform (§2.3, 2.1).
7. **"`free_bake_all` invalidates the frames."** FALSIFIED — `is_baked` clears,
   the frames and the stale reads stay (§2.4, 4.1).
8. **"`is_outdated=True` means the next read re-simulates."** FALSIFIED — the
   old trajectory is served byte-for-byte (§2.4, 4.1).
9. **"The served trajectory is a function of scene parameters alone."**
   FALSIFIED — one scene, three trajectories, decided by read order
   (§2.5, 4.3/4.4/4.5).
10. **"`solver_iterations` does not move a rigid-body trajectory."** FALSIFIED
    here (iters 1 ≠ 10), in contrast to r89's Godot negative result (§2.6).
11. **"`substeps_per_frame` is inert / a quality-only knob."** FALSIFIED —
    1/10/40 are three different trajectories (§2.6).
12. **"Rendering a frame steps the simulation to that frame."** FALSIFIED —
    the render shows the last stepped state (§2.7, 6.1).
13. **"Rendered PNG bytes are a deterministic witness."** FALSIFIED — two of
    three identical-state renders differ (§2.7, 6.2).
14. **"`bpy.ops.ptcache.bake` is armable headless."** FALSIFIED — poll False;
    only `bake_all`/`free_bake_all` are (§2.8, 7.1).
15. **"`rigidbody.bake_to_keyframes` bakes headless."** FALSIFIED — poll True,
    execute dies in the anim operator, no action created (§2.8, 7.1).
16. **"`use_disk_cache` can be enabled from Python in background."** FALSIFIED
    on this host — the write reads back False on RBW and cloth caches (§2.8).
17. **"`use_external=True` leaves a working cache."** FALSIFIED — the cache goes
    to `'No valid data to read!'` while `bake_all` still reports success (§2.8).
18. **"A stale RNA pointer write is a silent no-op."** FALSIFIED — SIGSEGV,
    rc -11 3/3 (§2.9).

---

## 5. Observation / inference / unknown

**Observation (receipt-pinned, rep-stable):** every hash, tuple, poll, refusal
text, `info` string and rc above; the 3/3 rep identity of 35/37 arms and the
PNG-only drift of the other two.

**Inference (labelled):** the per-frame cache mechanism behind §2.5; that the
bake's extension past `pc.frame_end` (1.7) follows the already-simulated frames
rather than a hidden scene range; that `pc.info` counts retained cache entries
rather than a valid range.

**Unknown / deferred:**
- Whether any single call forces a clean cache rebuild after an input change
  (§2.5) — `free_bake_all`, `enabled` toggling and range widening were all
  measured **not** to.
- The exact invalidation rule (why frame 20 reads the frame-5 value in 4.5).
- Cloth / soft-body / dynamic-paint point caches: only the `use_disk_cache`
  refusal was probed; their bake determinism and window behaviour are unmeasured.
- Sub-frame semantics beyond `subframe=0.5` at frame 40 (one sample only).
- Whether the window rule holds for other geometry, RBW settings, or with
  `frame_step > 1`.
- Whether a **baked** world survives a save/reload round trip (no `.blend`
  write was performed here).
- The three.js physics-adapter surface (cannon-es/rapier/ammo) — untouched;
  the fixture has no adapter dependency today and the registry is reachable.

---

## 6. Reproducing

```
cd corpus/live/r91-scout
python3 driver.py --list                       # 37 arms
python3 driver.py --reps 3                     # admitted set (~90 s, 111 children)
python3 driver.py --only resim_trace --reps 3  # the read-order cell
python3 audit.py runs/<stamp>                  # rep identity + bake-range flood census
```

Each arm is also a standalone child:
`blender -b -P probes/a_resim_trace.py` (args after `--`, e.g.
`blender -b -P probes/a_window.py -- end20`).

## Receipts pointer

`corpus/live/r91-scout/`: `probes/` (19 arm scripts + `rbc.py` + 17 superseded scratch
probes), `driver.py`, `audit.py`, `runs/20261015T055556607370Z/` (111 children,
699 `ARM` rows, `summary.json` with rc/wall/cmd per child), `RECEIPTS.md`
(probe revisions, run groups, confounds), `manifest.sha256` (375 files).
`corpus/live/` is gitignored — scratch only, per lane contract.

Provenance note: this lane wrote **only** `corpus/live/r91-scout/**` and
`reports/round-91/r91-scout.md`. It read `corpus/fixtures/**` (the bpy battery,
the three fixture) but never wrote there, and never touched
`reports/round-88/**`, `reports/round-89/**`, `reports/round-90/**`,
`LOG.md` or `SCORECARD.md`. Every probe here is a standalone `SceneTree`-free
`bpy` script run against a factory-empty scene, so no receipt depends on the
tracked fixture batteries.

Bounded to Blender `5.2.1 LTS` (hash `9e2066aef7ef`), embedded CPython 3.14.7,
`-b` background mode, this Linux host.
