# r92 scout — the AnimationPlayer×body surface, the RemoteTransform3D lattice, and the SceneTree timing edges

Lane: g3d · engine `4.7.2.stable.arch_linux.ed1daf0bf` · `--headless`,
`physics_ticks_per_second=60`, `max_physics_steps_per_frame=8`,
`physics_jitter_fix=0.5`, `physics_interpolation=false`.
Backends swept: GodotPhysics (`proj`), Jolt (`proj_jolt`), Dummy (`proj_dummy`).
Evidence: `corpus/live/r92-scout/` — `probes/` (5 scripts), `driver.py`,
`audit.py`, `sum_reps.py`, `runs/` (386 files), `manifest.sha256` (1570
entries), `RECEIPTS.md`. `corpus/fixtures/` and `reports/round-8*` untouched.

Reps: 114 cells (= 38 argv cases × 3 backends) × 3 reps = 342 children,
**342 rc=0**, 21 s wall clock. **111/114 cells are rep-stable at the observable
level**; the 3 exceptions are named in §6. Confidence labels: **[O]**
observation (receipt-pinned, rep-stable), **[I]** inference, **[?]** unknown /
not decided by these cells.

*Receipt-reading note.* Rows carry `seq` (a counter bumped at the top of every
callback) and `n_e`/`n_f` (per-callback counts). These are **scheduling**
stamps: an unthrottled headless run grants a variable number of idle frames per
physics tick, so they drift between reps in the later rows while the physics
observables stay fixed. The verbatim strings quoted below are exact r1 bytes;
when arming a fixture, key on the `pf`-stamped observables (`pos`, `srv`, `lv`,
`tr`) and treat `seq`/`n_e`/`n_f`/`anim_t` as the scheduler's, not the engine's.

---

## 0. The two frames the whole round turns on

### 0.1 A `RemoteTransform3D` write lands at the **next frame boundary**, never
### inside the frame that wrote it **[O]**

The source is written, then read three ways: immediately, by a node placed
*after* the source in tree order in the same frame, and by the same node one
frame later (`rt_proj_phase`, identical on GP/Jolt/Dummy, 3 reps):

```
write from a physics callback (_physics_process of a node before the source)
RT write_at_E W_E n=2 pf=3 seq=11 IMM O=(0.0000,0.0000,0.0000) …   # same statement
RT arm=write_at_E p=R_E n=2 pf=3 seq=12 O=(0.0000,0.0000,0.0000) …  # same physics frame, later node
RT arm=write_at_E p=R_F n=5 pf=3 seq=13 O=(1.0000,0.0000,0.0000) …  # next idle frame

write from an idle callback (_process of a node before the source)
RT write_at_F W_F n=3 pf=9 seq=28 IMM O=(0.0000,0.0000,0.0000) …
RT arm=write_at_F p=R_F n=3 pf=9 seq=29 O=(0.0000,0.0000,0.0000) …  # same idle frame, later node
RT arm=write_at_F p=R_F n=4 pf=9 seq=30 O=(1.0000,0.0000,0.0000) …  # next idle frame
```

So the target always reflects the source **as of the last frame boundary**, at
every callback position (`_integrate_forces`, `_physics_process`, `_process`).
It is not synchronous with the property assignment, and it is not visible to a
later node in the same frame. From a coroutine, exactly **one**
`await process_frame` suffices (`rt_proj_lag`, 3/3 reps byte-identical):

```
LG write=1.0 imm=0.0 after1=1.0 after2=1.0
LG write=2.0 imm=1.0 after1=2.0 after2=2.0
```

**[I]** The propagation is a single per-frame pass over the source, which also
explains §1.6: a chain `A→B→C→leaf` converges in **one** frame in *either* tree
order (the pass resolves the whole chain, so tree order does not matter).
**[O]** A fixture that writes a source and reads the target must cross at least
one frame boundary; the registered `remote3d_transform` cell awaits four, so it
is safe.

### 0.2 An `AnimationPlayer` on a live `RigidBody3D`: the write reaches the
### server as a per-tick teleport, and the **velocity keeps accumulating** **[O]**

`ap_proj_rbpos`: sphere at `(0,2,0)`, gravity on, a `TYPE_POSITION_3D` track
`(0,2,0)@t=0 → (3,2,0)@t=1`, `ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS`
(3 reps stable):

```
RB_PRE  freeze=false pos=(0.0000,1.9973,0.0000) srv=(0.0000,1.9973,0.0000) lv=(0.0000,-0.1633,0.0000)
IF pf=4 seq=17 tr=(0.0500,1.9918,0.0000) lv=(0.0000,-0.4892,0.0000) sv=(0.0000,-0.4892,0.0000) srv=(0.0500,1.9918,0.0000)
E  pf=4 seq=18 pos=(0.0500,1.9918,0.0000) lv=(0.0000,-0.4892,0.0000) srv=(0.0500,1.9918,0.0000) anim_t=0.0167
F  pf=4 seq=19 pos=(0.1000,2.0000,0.0000) lv=(0.0000,-0.4892,0.0000) srv=(0.1000,1.9891,0.0000) anim_t=0.0333
…
RB_POST freeze=false pos=(0.3500,1.9757,0.0000) srv=(0.3500,1.9757,0.0000) lv=(0.0000,-1.4602,0.0000) anim_t=0.1167 playing=true
```

Three separable facts:

1. **The animation's write reaches the physics server.** The X of the server
   transform is the animated X exactly (`0.05, 0.10, 0.15 …` = 3 u/s at 60 tps),
   and `animrb` (no floor) shows the body jumping from `y=9.9973` to the track's
   `y=2.0` — a teleport, not a fall.
2. **The teleport does not reset velocity.** `lv` grows by `9.8/60 = 0.1633`
   every tick without bound: `-0.1633, -0.3264, -0.4892, -0.6517, -0.8139,
   -0.9759, -1.1376, -1.4602`. The body is position-pinned by the animation and
   simultaneously carrying a runaway velocity — the exact "corrupt" class.
3. **Within one idle frame the node and the server disagree.** At `F(pf=k)` the
   node holds the raw track value (`y=2.0000`) while the server holds the
   integrated one (`y=1.9891 = 2.0 + lv·dt`). At `IF`/`E(pf=k)` they agree
   (both = the integrated value), which is consistent with r89's "IF/E is a
   PRE-step view".

A frozen body is the clean case: `rbfrozen` shows node == server == the track
value at **every** position, `lv` identically zero (GP/Jolt/Dummy all 3 reps).
`manual` + `advance(0.5)` drives a frozen body's server transform too
(`MA_ADV pos=(1.5000,2.0000,0.0000) srv=(1.5000,2.0000,0.0000) t=0.5000`).

---

## 1. The `RemoteTransform3D` lattice

### 1.1 Arm table (verbatim-armable cells)

Each cell = one child process; commands run from `corpus/live/r92-scout/`;
`--batch`/`--only` select the backend through the project directory in the tag
(`rt_proj_*` = GodotPhysics, `rt_proj_jolt_*` = Jolt, `rt_proj_dummy_*` =
Dummy).

| # | command | expected signature (verbatim) | falsified if |
|---|---|---|---|
| 1.1 | `python3 driver.py --batch remote1 --only rt_proj_lag --reps 3 --jobs 3` | `LG write=1.0 imm=0.0 after1=1.0 after2=1.0` (all 6 rows, all 3 reps) | `imm` ≠ the previous write, or `after1` ≠ the new write |
| 1.2 | `… --batch remote1 --only rt_proj_phase` | `RT write_at_E W_E n=2 pf=3 … IMM O=(0.0000,0.0000,0.0000)` then `RT arm=write_at_E p=R_E n=2 pf=3 … O=(0.0000,…)` then `RT arm=write_at_E p=R_F n=5 pf=3 … O=(1.0000,0.0000,0.0000)` | the later same-frame reader shows the new value (⇒ synchronous), or the next frame does not |
| 1.3 | `… --batch remote1 --only rt_proj_sync` | `S_POS_IMMEDIATE O=(0.0000,0.0000,0.0000) X=(1.0000,0.0000,0.0000) S=(1.0000,1.0000,1.0000)` → `S_NEXT_IDLE O=(2.0000,1.0000,-3.0000) X=(-0.0000,0.0000,-3.0000) S=(3.0000,3.0000,3.0000)` | any immediate read shows the propagated transform |
| 1.4 | `… --batch remote1 --only rt_proj_flags` | the 8-row matrix in §1.2 | any flag gates a component it should not |
| 1.5 | `… --batch remote1 --only rt_proj_stale` | §1.3 (four-way revival test) | a freed target errors or crashes; `force_update_cache()` or a same-value `remote_path` write revives the binding |
| 1.6 | `… --batch remote1 --only rt_proj_path` | all 7 degenerate paths print the unchanged target and **no error line** | any path class errors, crashes, or moves the target |
| 1.7 | `… --batch remote1 --only rt_proj_chainlag` | `CL order=fwd write=3.0 f1[b=3.0 c=3.0 leaf=3.0] …` and the identical `order=rev` block | reverse tree order needs a second frame |
| 1.8 | `… --batch remote1 --only rt_proj_srv` | GP/Jolt: `SRV_S1_IMMEDIATE … srv=[… O: (0.0, 0.0, 0.0)]` then `SRV_S2_AFTERPHYS … O: (5.0, 0.0, 0.0)] ray=hit@5.000,0.500,0.000`; Dummy: `srv=<null>` and `ray=miss` | the server transform moves in the same statement, or the ray misses on GP/Jolt |
| 1.9 | `… --batch remote1 --only rt_proj_driver` | `DR mode=process_off O=(2.0000,1.0000,-3.0000) …` for all three of `process_off`, `physics_off`, `both_off` | any of them stops propagation (⇒ the driver is the node's own process callback) |
| 1.10 | `… --batch remote1 --only rt_proj_local` | `LC_LOCALMODE loc=O=(1.0000,2.0000,3.0000) … glob=O=(1.0000,2.0000,3.0000) … src_glob=O=(11.0000,2.0000,3.0000)`; `LC_TOGGLE_GLOBAL … glob=O=(11.0000,2.0000,3.0000)` | the local mode writes the global transform, or the toggle is not honoured on the next frame |
| 1.11 | `… --batch remote1 --only rt_proj_parent` | `PA_IMMEDIATE O=(0.0000,0.0000,0.0000)…` → `PA_AFTER_FRAME O=(0.0000,4.0000,0.0000)…` → `PA_AFTER_PARENT_SCALE … S=(2.0000,2.0000,2.0000)` | a parent-induced move or scale is not propagated |

### 1.2 The flag lattice is fully independent **[O]**

`RemoteTransform3D` has **no `UpdateFlags` enum in 4.7.2** (`intro.gd`: only
`update_position` / `update_rotation` / `update_scale` bools). All 8
combinations, source = `pos (2,1,-3)`, `rot (0,π/2,0)`, `scale (3,3,3)`:

```
RT_FLAGS pos=true  rot=true  scl=true  glob=true O=(2.0000,1.0000,-3.0000) X=(-0.0000,0.0000,-3.0000) S=(3.0000,3.0000,3.0000)
RT_FLAGS pos=false rot=true  scl=true  glob=true O=(0.0000,0.0000,0.0000) X=(-0.0000,0.0000,-3.0000) S=(3.0000,3.0000,3.0000)
RT_FLAGS pos=true  rot=false scl=true  glob=true O=(2.0000,1.0000,-3.0000) X=(3.0000,0.0000,0.0000) S=(3.0000,3.0000,3.0000)
RT_FLAGS pos=true  rot=true  scl=false glob=true O=(2.0000,1.0000,-3.0000) X=(-0.0000,0.0000,-1.0000) S=(1.0000,1.0000,1.0000)
RT_FLAGS pos=false rot=false scl=true  glob=true O=(0.0000,0.0000,0.0000) X=(3.0000,0.0000,0.0000) S=(3.0000,3.0000,3.0000)
RT_FLAGS pos=false rot=true  scl=false glob=true O=(0.0000,0.0000,0.0000) X=(-0.0000,0.0000,-1.0000) S=(1.0000,1.0000,1.0000)
RT_FLAGS pos=true  rot=false scl=false glob=true O=(2.0000,1.0000,-3.0000) X=(1.0000,0.0000,0.0000) S=(1.0000,1.0000,1.0000)
RT_FLAGS pos=false rot=false scl=false glob=true O=(0.0000,0.0000,0.0000) X=(1.0000,0.0000,0.0000) S=(1.0000,1.0000,1.0000)
```

Each component is gated by exactly its own flag and nothing else — note
`rot=false scl=true` yields `X=(3,0,0)`, i.e. the scale is applied to the
*target's own* basis, not to the source's rotated basis. `use_global_coordinates
= false` copies the source's **local** transform into the target's **global**
transform, with the same per-flag gating:

```
RT_FLAGS pos=true  rot=false scl=false glob=false O=(1.0000,2.0000,3.0000) X=(1.0000,0.0000,0.0000) S=(1.0000,1.0000,1.0000) src_glob=O=(11.0000,2.0000,3.0000) X=(4.0000,0.0000,0.0000) S=(4.0000,4.0000,4.0000)
RT_FLAGS pos=false rot=false scl=false glob=false O=(0.0000,0.0000,0.0000) …
```

### 1.3 A target that leaves and re-enters the tree leaves the binding **dead**,
### and only a *changed* `remote_path` revives it **[O]**

`rt_proj_stale`, GP/Jolt/Dummy, r1 == r2 == r3:

```
ST_BOUND               O=(2.0000,1.0000,-3.0000) …        # live binding
ST_POST_FREE           valid=false                        # target.free()
ST_MOVE_AFTER_FREE_IMMEDIATE FREED                        # source write after free: silent
ST_AFTER_FRAME1        path=../Target                     # no error, no crash, path retained
ST_AFTER_FORCECACHE    (no error)                         # force_update_cache() is silent
ST_REBOUND             O=(4.0000,4.0000,4.0000) …         # re-pointing at a NEW node works
ST_ORPHAN_PRE          in_tree=false local=O=(4.0000,4.0000,4.0000) …
ST_ORPHAN_AFTER_FRAME  local=O=(4.0000,4.0000,4.0000) …   # source moved to (5,5,5); target did not
ST_REPARENTED          O=(4.0000,4.0000,4.0000) …         # re-added to the tree: STILL STALE
ST_REPARENTED_CACHED   O=(4.0000,4.0000,4.0000) …         # force_update_cache(): does NOT revive
ST_REPARENTED_REPATH_SAME  O=(4.0000,4.0000,4.0000) …     # same-value remote_path write: does NOT revive
ST_REPARENTED_REPATH_TOGGLE O=(5.0000,5.0000,5.0000) …    # "" then back: REVIVES
ST_SRC_ORPHAN          O=(5.0000,5.0000,5.0000) …         # source leaves the tree: frozen
ST_SRC_BACK            O=(6.0000,6.0000,6.0000) …         # source re-enters: REVIVES and catches up
```

Two separate silent-failure contracts:

- **a freed target is a silent no-op** — no error, no crash, the stale
  `remote_path` string survives, and the process stays rc=0;
- **an orphaned-then-reparented target is a permanently dead binding** within
  the process, recoverable only by a *changing* `remote_path` write or by the
  **source** re-entering the tree. `force_update_cache()` is not a repair.
  **[I]** the target is re-resolved on the source's own `ENTER_TREE`, and the
  `remote_path` setter short-circuits on an identical value.

A fixture that frees or reparents a remote target and then asserts on the target
would read the *last propagated* value and pass — the §5 falsifier for this cell
is the `(5,5,5)` vs `(4,4,4)` split.

### 1.4 Degenerate paths are all silent no-ops **[O]**

`rt_proj_path`, all 7 classes, GP/Jolt/Dummy, 3 reps, **zero error lines**:
`self` (`.`), `../Plain` (a plain `Node`, not a `Node3D`), `../Nope` (missing),
`` (empty), `/root` (a `Window`, not a `Node3D`), `..` (the source's own
`Node3D` parent), `../Target/Ghost` (a missing child of the target). Every row
prints the unchanged target and a live source; `PT_VALID_AGAIN
O=(1.0000,1.0000,1.0000)` confirms the binding still works afterwards. So a
`RemoteTransform3D` fixture cannot use "the target did not move" as evidence of
a refusal — the engine refuses nothing here.

### 1.5 The propagated transform reaches the physics server, one frame later **[O]**

`rt_proj_srv` (target is a `StaticBody3D` + box, ray witness):

```
GP/Jolt  SRV_S1_IMMEDIATE … srv=[X: (1.0, 0.0, 0.0), Y: (0.0, 1.0, 0.0), Z: (0.0, 0.0, 1.0), O: (0.0, 0.0, 0.0)]
         SRV_S2_AFTERPHYS … srv=[… O: (5.0, 0.0, 0.0)] ray=hit@5.000,0.500,0.000
Dummy    SRV_S2_AFTERPHYS … srv=<null> ray=miss
```

Dummy answers `body_get_state` with `<null>` and `intersect_ray` with a miss —
consistent with the r89 Dummy floor, and a reminder that a Dummy-arm fixture
must assert on the *node* transform only.

### 1.6 Chains resolve in one frame in either tree order **[O]**

`rt_proj_chainlag` (4 writes, 4 frames each, both orders, 3 reps):

```
CL order=fwd write=1.0 f1[b=1.0 c=1.0 leaf=1.0] f2[…] f3[…] f4[…]
CL order=rev write=1.0 f1[b=1.0 c=1.0 leaf=1.0] f2[…] f3[…] f4[…]
```

`A→B→C→leaf` is fully resolved at the first frame boundary in both tree orders,
for every write. **[I]** the pass is a repeated relaxation, so a single pass
covers the whole chain regardless of processing order.

### 1.7 The driver is neither `_process` nor `_physics_process` **[O]**

```
DR mode=process_off  O=(2.0000,1.0000,-3.0000) X=(1.0000,0.0000,0.0000) S=(1.0000,1.0000,1.0000)
DR mode=physics_off  O=(2.0000,1.0000,-3.0000) …
DR mode=both_off     O=(2.0000,1.0000,-3.0000) …
```

Disabling both script process callbacks does not stop propagation. **[I]** the
frame-boundary pass is internal (notification- or internal-process-driven), so a
fixture cannot gate propagation with `set_process(false)`.

---

## 2. `AnimationPlayer` / `AnimationMixer` × physics bodies

### 2.1 Arm table (verbatim-armable cells)

| # | command | expected signature (verbatim) | falsified if |
|---|---|---|---|
| 2.1 | `python3 driver.py --batch animphys1 --only ap_proj_rbpos` | `RB_POST freeze=false pos=(0.3500,1.9757,0.0000) srv=(0.3500,1.9757,0.0000) lv=(0.0000,-1.4602,0.0000) anim_t=0.1167 playing=true` | `lv` stays 0 or resets (⇒ the teleport resets velocity); or the server X does not follow the track |
| 2.2 | `… --only ap_proj_rbfrozen` | `RB_POST freeze=true pos=(0.3500,2.0000,0.0000) srv=(0.3500,2.0000,0.0000) lv=(0.0000,0.0000,0.0000) anim_t=0.1167 playing=true`; every sampled row node == server == track | the frozen body diverges from the track, or `lv` ≠ 0 |
| 2.3 | `… --only ap_proj_empty_track` | GP `ET_POST pos=(0.0000,0.3920,0.0000) srv=(0.0000,0.3920,0.0000) lv=(0.0000,0.0000,0.0000) t=0.0833`; **Jolt `ET_POST pos=(0.0000,0.0800,0.0000)`**; Dummy `pos=(0.0000,0.0000,0.0000) srv=nil` | the keyless track writes nothing, or the body does not end up embedded in the floor |
| 2.4 | `… --only ap_proj_badkey` | 2× `ERROR: Condition "(p_key.get_type() != Variant::VECTOR3) && (p_key.get_type() != Variant::VECTOR3I)" is true. Returning: -1`, then `BK_TRACKS n=1 keys=0 type=1`, then `BK_POST pos=(0.0000,0.0000,0.0000) srv=(0.0000,0.0000,0.0000) t=0.0500 playing=true` | the wrong-typed key is accepted, or the track refuses to play |
| 2.5 | `… --only ap_proj_reset` | `RS_LIST ["RESET", "travel"] reset_on_save=true` → `RS_AFTER_RESET pos=(7.0000,0.0000,0.0000) t=0.0000 anim=RESET playing=true` | `play("RESET")` restores the pre-`travel` pose instead of the RESET track's keys |
| 2.6 | `… --only ap_proj_animatable` | GP/Jolt both modes `AB_POST sync=true/false ab=(0.5000,2.0000,0.0000) srv=(0.5000,2.0000,0.0000) rider=(0.0407,2.9973,0.0000) ray=hit@0.500,3.195,0.000`; **Dummy `sync=true ab=(0.0000,2.0000,0.0000)`, `sync=false ab=(0.5000,2.0000,0.0000)`** | GP/Jolt split on `sync_to_physics`, or Dummy moves under `sync=true` |
| 2.7 | `… --only ap_proj_animrb` | `AR_PRE pos=(0.0000,9.9973,0.0000)` → `F pf=2 pos=(0.0000,2.0000,0.0000) srv=(0.0000,1.9946,0.0000)` → `AR_POST pos=(0.2500,1.9810,0.0000) lv=(0.0000,-1.1376,0.0000)` | the body keeps falling instead of teleporting to the track's Y |
| 2.8 | `… --only ap_proj_idlemode` | `IM_POST pos=(0.2959,2.0000,0.0000) srv=(0.2959,2.0000,0.0000) lv=(0.0000,-1.1376,0.0000) anim_t=0.0986` — **but see §6: this cell is NOT rep-stable** | used as a fixed-marker fixture |
| 2.9 | `… --only ap_proj_manual` | `MA_FROZEN pos=(0.0000,2.0000,0.0000) t=0.0000` → `MA_ADV pos=(1.5000,2.0000,0.0000) srv=(1.5000,2.0000,0.0000) t=0.5000` | `advance()` fails to drive the server transform |
| 2.10 | `… --only ap_proj_iforder` | `E pf=3 seq=11 pos=(0.0000,2.0000,0.0000) …` (frozen: IF/E/F all equal the track) | the animation is not applied on a frozen body |

### 2.2 Two silent transform-destroyers **[O]**

**A keyless `TYPE_POSITION_3D` track writes `Vector3.ZERO`.** With no keys at
all, the track still evaluates and applies the type default every frame:

```
GP    ET_PRE pos=(0.0000,1.9973,0.0000) lv=(0.0000,-0.1633,0.0000)
      F pf=2 pos=(0.0000,0.0000,0.0000) srv=(0.0000,0.3920,0.0000)   # node zeroed, server teleported into the floor
      ET_POST pos=(0.0000,0.3920,0.0000) srv=(0.0000,0.3920,0.0000) lv=(0.0000,0.0000,0.0000)
Jolt  ET_POST pos=(0.0000,0.0800,0.0000) srv=(0.0000,0.0800,0.0000)
Dummy ET_POST pos=(0.0000,0.0000,0.0000) srv=nil
```

The body is teleported to the origin (0.5 m inside the floor), the solver only
partly resolves the penetration, and the resting depth is **backend-specific**
(0.3920 GP vs 0.0800 Jolt). The velocity is zeroed by the collision.

**A wrong-typed key is a loud refusal at insert time and a silent zeroing at
play time.** `track_insert_key(t, 0.0, 0.0)` on a `TYPE_POSITION_3D` track
prints the `VECTOR3` condition error and returns `-1` for each key; the track
then exists with `keys=0` and plays as the keyless case above
(`BK_POST pos=(0.0000,0.0000,0.0000) srv=(0.0000,0.0000,0.0000) … playing=true`).
An author who ignores the `-1` return gets a fixture that "plays" and destroys
the transform.

### 2.3 `RESET` is an ordinary animation at runtime **[O]**

`play("RESET")` on a library that literally contains an animation named `RESET`
plays it like any other track — `RS_AFTER_RESET pos=(7.0000,0.0000,0.0000)
t=0.0000 anim=RESET playing=true` (the RESET track's own key), not a snapshot
restore of the pre-`travel` pose. `is_reset_on_save_enabled()` is `true` by
default, and there is no auto-apply. **[?]** whether `AnimationMixer._reset()`
(the private editor-save path) behaves differently is not reachable from script
and is not decided here. The result is rep-stable (3/3 identical), so
`play("RESET")` is a safe deterministic cell.

### 2.4 The Dummy backend inverts `AnimatableBody3D.sync_to_physics` **[O]**

`ap_*_animatable`, 3/3 reps on each backend, an `AnimatableBody3D` animated
`(0,2,0) → (6,2,0)` with a rider sphere on top:

| backend | `sync_to_physics=true` | `sync_to_physics=false` |
|---|---|---|
| GP | `ab=(0.5000,2.0000,0.0000) srv=(0.5000,2.0000,0.0000)` | `ab=(0.5000,2.0000,0.0000)` |
| Jolt | `ab=(0.5000,2.0000,0.0000) srv=(0.5000,2.0000,0.0000)` | `ab=(0.5000,2.0000,0.0000)` |
| Dummy | **`ab=(0.0000,2.0000,0.0000)` — the animation does not take** | `ab=(0.5000,2.0000,0.0000)` |

On GP and Jolt the two modes are indistinguishable on this observable
(`rider=(0.0407,2.9973,0.0000)` GP vs `(0.0407,3.0000,0.0000)` Jolt — a small
settle split, but the same for both modes). On Dummy, `sync_to_physics=true`
makes the animation inert. **[?]** the kinematic-vs-friction carry distinction
that `sync_to_physics` is documented to control was **not** isolated by this
observable; the rider moves ~0.04 in every arm. This is the honest gap, and the
per-backend inversion is the part that is measured.

---

## 3. SceneTree timing edges

### 3.1 Arm table (verbatim-armable cells)

Mutation at the 4th `_physics_process` (`MUTATE_AT n_e=4 pf=4`); the first
post-mutation tick is quoted. 40 idle frames per child.

| # | command | first post-mutation tick (verbatim) | falsified if |
|---|---|---|---|
| 3.1 | `python3 driver.py --batch timing1 --only tm_proj_tps30` | `E n_e=5 n_f=17 pf=5 delta=0.033333 tsc=1.0000 tps=30` | the delta changes only after a frame boundary, or stays `1/60` |
| 3.2 | `… --only tm_proj_tps120` | `E n_e=5 n_f=14 pf=5 delta=0.008333 tsc=1.0000 tps=120`; `TM_DONE … n_e=28 n_f=40 pf=28` | the tick rate per idle frame does not scale |
| 3.3 | `… --only tm_proj_ts05` | `E n_e=5 n_f=15 pf=5 delta=0.008333 tsc=0.5000 tps=60` | `time_scale` changes the tick *rate* instead of the delivered delta |
| 3.4 | `… --only tm_proj_ts2big` | `E … delta=0.033333 tsc=2.0000` | — |
| 3.5 | `… --only tm_proj_tsbig` | `E … delta=0.166667 tsc=10.0000 tps=60` | a spiral-of-death clamp appears in the delta |
| 3.6 | `… --only tm_proj_ts0` | `E n_e=5 n_f=15 pf=5 delta=0.000000 tsc=0.0000`; `TM_DONE … pf=15` | the physics loop stalls (pf frozen) or `_physics_process` stops firing |
| 3.7 | `… --only tm_proj_tsneg` | `E n_e=5 n_f=15 pf=5 delta=-0.016667 tsc=-1.0000` | a negative `time_scale` is clamped or refused |
| 3.8 | `… --only tm_proj_tps0` | `MUTATE_POST tsc=1.0000 tps=60 …`; `E … delta=0.016667 tps=60` | the write is accepted, or any error line appears |
| 3.9 | `… --only tm_proj_tpsneg` | `MUTATE_POST tsc=1.0000 tps=60 …`; `E … delta=0.016667 tps=60` | a negative tick rate is accepted |
| 3.10 | `… --only tm_proj_maxsteps` | `E … delta=0.166667 tsc=10.0000 tps=60 jit=0.5000 mps=1` | `mps=1` clamps the delivered delta |
| 3.11 | `… --only tm_proj_interpf` | `MUTATE_POST … interp=true`; `TM_DONE … n_e=15 n_f=40 pf=15` | any observable change appears |
| 3.12 | `… --only tm_proj_jitfix` | *(arm defect — see §3.3)* | — |

### 3.2 The measured laws **[O]**

1. **`Engine.physics_ticks_per_second = N` takes effect on the very next
   physics tick** — `delta` becomes exactly `1/N` with no frame-boundary lag
   (`tps30` → `0.033333`, `tps120` → `0.008333`), and the tick rate per idle
   frame follows (`TM_DONE`: 10 ticks/40 frames at tps=30, 15 at 60, 28 at 120).
2. **`Engine.time_scale` multiplies the delivered delta** — `0.5 → 0.008333`,
   `2 → 0.033333`, `10 → 0.166667`, all at an unchanged tick rate. It is *not*
   a tick-rate knob in this regime. The idle `_process` delta is scaled by the
   same factor (`F … delta=0.003450` at `tsc=0.5` vs `0.006900` before).
3. **`time_scale = 0` does not stall the loop** — `_physics_process` keeps
   firing, `pf` keeps advancing, and the delivered delta is exactly `0.000000`.
4. **A negative `time_scale` is honoured, not clamped** — `tsc=-1.0` delivers
   `delta=-0.016667` to `_physics_process`. **[?]** what a negative delta does to
   the solver is not measured here.
5. **`physics_ticks_per_second` refuses 0 and negatives silently** — the setter
   leaves the getter at `60`, with no error and no state change
   (`tps0`, `tpsneg`).
6. **`max_physics_steps_per_frame=1` does not clamp the delivered delta** —
   `mps=1` reads back, and the tick still delivers `0.166667` under
   `time_scale=10`.
7. **A `ProjectSettings` write at runtime is read back but changes nothing** —
   `physics/common/physics_interpolation` reads `true` after the write and the
   schedule is byte-identical to the control.

### 3.3 Arm defects (recorded, not hidden)

- `tm_*_jitfix` sets `Engine.physics_jitter_fix = 0.5`, which is **already the
  default** (`TM_PRE … jit=0.5000`), so the arm measures nothing. A follow-up
  must use `0.0` or `2.0`.
- `interpf` never sampled `Engine.get_physics_interpolation_fraction()`, so
  "interpolation stays off" is asserted only from the delta schedule, not from
  the interpolation fraction.

---

## 4. Skeleton3D / physical bones — reachability only

`intro.gd` and `skelphys.gd`. The API is reachable headless, and the state
machine is honest:

```
PB_PRE  simulating=false bones=2 children=0
PB_START simulating=true                     # no PhysicalBone3D children at all
PB_STOP  simulating=false
PB_ADDED simulating=false pb_bone=Tip pb_mass=1.0000 joint=0
PB_START2 simulating=true
PB_AFTER8 simulating=true b0=p=(0.0000,0.0000,0.0000) q=(0.0000,0.0000,0.0000,1.0000) b1=p=(0.0000,0.0000,0.0000) q=(0.0000,0.0000,0.0000,1.0000)
PB_STOP2 simulating=false
```

**`physical_bones_start_simulation()` flips `is_simulating_physics()` to `true`
and no bone pose moves over 8 physics frames — identical on GP, Jolt and Dummy
(3/3 reps).** This extends the r86 nas-scout finding (silent no-op with *no*
`PhysicalBone3D` children) to a skeleton that *has* one (`bone_name="Tip"`,
`mass=1.0`, a sphere `CollisionShape3D`, `joint_type=0`). **[?]** my minimal
setup omits a multi-bone chain and a non-`NONE` joint type, so the honest
reading is *"the surface is reachable and state-tracked, but no bone motion was
produced by this setup"* — not a general claim that physical bones never
simulate. `Skeleton3D`'s own override surface is live and rep-stable:

```
OV_SET_IMM   b1=p=(9.0000,9.0000,9.0000) …
OV_SET_NEXT  b1=p=(9.0000,9.0000,9.0000) …    # a manual global pose persists across frames
OV_DISABLED  b1=p=(9.0000,9.0000,9.0000) enabled=false   # set_bone_enabled(false) does NOT clear the pose
OV_RESET     b1=p=(0.0000,2.0000,0.0000) …    # reset_bone_poses() returns to rest
OV_MOTION    b1=p=(0.0000,2.0000,0.0000) … motion=0.5000
```

Two API facts worth carrying forward: the callback-mode enum and setter live on
**`Skeleton3D`** (`Skeleton3D.ModifierCallbackModeProcess`,
`set_modifier_callback_mode_process`), not on the modifier — all three modes
round-trip; and `get_bone_pose()` returns a pose *delta* relative to rest, so a
rest bone reads `p=(0,0,0)`, not its rest offset. The `override` arm's
`AnimationPlayer` track failed to resolve (`WARNING: AnimationMixer: 'travel',
couldn't resolve track: 'Skelly:Tip'`) because `root_node` was `".."` — the
r86 §5.2 warning-level silent no-op, re-observed. That makes this arm a pure
bone-override probe; the anim-vs-override ordering is already covered by r86
§7.1 `B5_MANUAL_AFTER_ANIM`.

---

## 5. Falsification list

Every claim above dies on a named, cheap observation:

| claim | falsifier | status |
|---|---|---|
| §0.1 propagation is frame-boundary deferred | a later node in the **same** frame sees the new value (`rt_proj_phase` `R_E n=2` / `R_F n=3` rows) | not observed on GP/Jolt/Dummy, 3/3 |
| §0.1 one `await process_frame` suffices | `LG … after1=` shows the previous value (`rt_proj_lag`) | not observed, 3/3 byte-identical |
| §1.2 flags gate independently | any row where a disabled flag's component still changes | not observed, 8/8 combos |
| §1.3 a reparented target is permanently stale | `ST_REPARENTED` shows `(5,5,5)` | not observed, 3/3 |
| §1.3 `force_update_cache()` does not repair | `ST_REPARENTED_CACHED` shows `(5,5,5)` | not observed, 3/3 |
| §1.4 degenerate paths are silent | any error/warning line in `rt_*_path` | zero error lines, 3 backends × 3 reps |
| §1.5 the server transform follows | `SRV_S1_IMMEDIATE` already shows `O: (5.0, 0.0, 0.0)` | not observed |
| §2.2 a keyless track writes `Vector3.ZERO` | `ET_POST` shows the body still falling | not observed; the resting depth is backend-specific (0.3920 GP / 0.0800 Jolt / 0.0000 Dummy) |
| §2.3 `RESET` is an ordinary animation | `RS_AFTER_RESET pos=(0.0000,2.0000,0.0000)` (the pre-`travel` pose) | not observed |
| §2.4 Dummy inverts `sync_to_physics` | Dummy `sync=true` moves to `0.5` | not observed, 3/3 |
| §3.2 tps mutation is immediate | the first post-mutation tick still delivers `1/60` | not observed |
| §3.2 negative `time_scale` is honoured | the delta is clamped to `0` or an error appears | not observed |
| §3.2 `tps=0` is refused silently | `MUTATE_POST` shows `tps=0`, or an error line appears | not observed |
| §4 physical bones are inert in this setup | any bone pose ≠ identity after 8 frames | not observed on GP/Jolt/Dummy |

**What would make a future fixture lie.** (a) Asserting on a `RemoteTransform3D`
target **without crossing a frame boundary** — the immediate read is the
*previous* value, so the assertion silently tests the old state. (b) Asserting
only on the node transform of an animated `RigidBody3D` — the node and the
server disagree inside the idle frame, and only the server carries the runaway
`linear_velocity`. (c) Using a keyless or wrong-typed track — it plays, reports
`playing=true`, and writes `Vector3.ZERO`. (d) Reading `get_bone_pose()` as an
absolute transform — it is a rest-relative delta. (e) Animating with the default
`IDLE` callback mode and pinning a fixed marker (§6).

---

## 6. Rep stability and the per-backend matrix

| measure | value |
|---|---|
| cells (38 cases × 3 backends) | 114 |
| children (×3 reps) | 342, **all rc=0** |
| raw stdout byte-identical across reps | 65 / 114 |
| raw differs but tick-stamp-normalized identical | 16 / 114 |
| **observable-projection identical across reps** | **111 / 114** |

Raw differences are row *multiplicity*: an unthrottled headless run grants a
variable number of idle frames per physics tick, so the `F` rows repeat a
variable number of times. `sum_reps.py` projects each cell onto one row per
(callback-kind, `pf`) with the scheduling stamps (`seq`, `n`, `anim_t`, `t`)
dropped.

**The 3 unstable cells are `ap_{proj,jolt,dummy}_idlemode`.** An
`AnimationPlayer` left in the default `ANIMATION_CALLBACK_MODE_PROCESS_IDLE`
advances once per **rendered frame**, so its animated X depends on the frame
count the scheduler grants:

```
rep1  E pf=3 pos=(0.0355,2.0000,0.0000)
rep2  E pf=3 pos=(0.0375,2.0000,0.0000)
rep3  E pf=3 pos=(0.0375,2.0000,0.0000)
```

This is a **fixture-design law**, not noise: an animation cell must pin
`ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS` (which the three registered
`animation3d_*` cells already do per `corpus/lessons/r31/r32`) or it cannot be
rep-stable in an unthrottled headless run.

Per-backend splits found this round, all rep-stable:

| observable | GP | Jolt | Dummy |
|---|---|---|---|
| `body_get_state` / `intersect_ray` | live | live | `<null>` / `miss` |
| keyless-track resting depth (`empty_track`) | 0.3920 | 0.0800 | 0.0000 |
| `AnimatableBody3D` + `sync_to_physics=true` | moves | moves | **does not move** |
| rider settle under an animated `AnimatableBody3D` | 2.9973 | 3.0000 | 3.0000 |
| every `RemoteTransform3D` cell | same | same | same (node-side) |

---

## 7. Remaining unknowns

1. **The propagation mechanism** (§0.1/§1.7): the observable contract is pinned,
   the driver is not — `set_process(false)`/`set_physics_process(false)` do not
   stop it, and no script-visible internal-process switch exists. **[?]**
2. **What a negative `time_scale` does to the solver.** `_physics_process`
   receives `delta=-0.016667`; the effect on bodies was not sampled.
3. **`sync_to_physics`'s kinematic-vs-friction distinction** (§2.4): the rider
   displacement (0.0407) was identical in all four GP/Jolt arms, so the flag's
   documented semantics were not isolated.
4. **Physical bones** (§4): no bone motion in a minimal one-bone setup; a
   multi-bone chain with a non-`NONE` joint type is the untested configuration.
5. **`AnimationMixer._reset()` / `reset_on_save`** (§2.3): the editor-save reset
   path is not reachable from script; only `play("RESET")` was measured.
6. **`AnimationTree` / `AnimationNodeBlendTree`** — untouched by this seat, still
   the largest unprobed animation surface (r86 rank 11).
7. **`time_scale` interaction with `physics_jitter_fix`** — the `jitfix` arm was
   a no-op (default value), so the jitter-fix axis is unmeasured.
8. **`Engine.get_physics_interpolation_fraction()`** under a runtime
   `physics_interpolation` write — unmeasured (the delta schedule did not
   change, but the fraction was never sampled).
