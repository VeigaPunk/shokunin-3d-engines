# r99 scout — the `AnimationTree` / `AnimationNodeBlendTree` surface

Lane: g3d · engine `4.7.2.stable.arch_linux.ed1daf0bf` · `--headless`, 60 tps.
Backends swept for **every** cell: GodotPhysics (`proj`), Jolt (`proj_jolt`),
Dummy (`proj_dummy`).
Evidence: `corpus/live/r99-scout/` — `probes/` (6 `.gd`), `driver.py`,
`audit.py`, `runs/` (**536 children**, rc/ms sidecars), `RECEIPTS.md`,
`manifest.sha256`, `audit_report.txt`, `*_batch.log`.
Measured: **132 cells** (tree 14, sm 14, mode 5, life 10 cases × 3 backends
+ 3 census cells) — **536 children, 536× rc=0**; no crash, no timeout kill, no
watchdog abort.
Reps: tree/sm/mode 3, `min`/`rootswap`/`travel`/`cond`/`stopstart`/`idle` 6,
**life 10/10 cells × 6 reps**, census 3/1/1.
Rep identity: **130 multi-rep tags — 123 rep-stable, 7 unstable**; the 7 are
exactly the IDLE-callback cells plus one probe-reporting artifact (§6).

Confidence: **[O]** receipt-pinned observation, **[I]** inference, **[?]** unknown.
Scratch, no tracked writes (report excepted per the task contract), no commits.

---

## 0. Headless census — the class surface, and API shape corrections

`at_cls.gd` (3 reps GP + 1 Jolt + 1 Dummy, byte-identical, rc=0):

- **[O] Every `AnimationNode*` class in the candidate list exists and is
  `ClassDB.instantiate`-able headless** (32/32), including
  `AnimationNodeStateMachinePlayback` (parent `Resource`),
  `AnimationNodeExtension`, `AnimationNodeBlendSpace1D/2D`. Nothing abstract
  here, and **no r97-style instantiate+free teardown crash** (`CENSUS_DONE`,
  rc=0, 3/3 reps).
- **[O] API shape corrections vs the r92-era mental model** (inherited method
  list, `ClassDB.class_get_method_list(cls, false)`):
  - `AnimationTree` has **no `callback_mode_process`** — that is
    `AnimationPlayer`'s property. The tree's knob is **`process_callback`**
    (`set_process_callback`/`get_process_callback`). The r92 PHYSICS law must be
    re-applied through this name (§6).
  - `AnimationTree` has **no `set_parameter`/`get_parameter` methods** — the
    parameter surface is property access only: `tree.set("parameters/…")` /
    `tree.get("parameters/…")`.
  - `AnimationTree.anim_player` is a property; its accessors are
    **`set_animation_player`/`get_animation_player`** (there is no
    `set_anim_player`).
  - `AnimationNodeBlendTree` has **no `get_connection_list()`** and no
    `get_node_count()`; only `get_node_list()`. A first pass died on this
    (script error → hang, §11 hazard 1).
  - `AnimationNodeAnimation` is an **`AnimationRootNode`** in 4.7.2
    (`parent=AnimationRootNode`), so it *is* a legal `tree_root` (§1.4).
  - `AnimationNodeStateMachineTransition` constants: `SWITCH_MODE_IMMEDIATE=0
    SWITCH_MODE_SYNC=1 SWITCH_MODE_AT_END=2`, `ADVANCE_MODE_DISABLED=0
    ADVANCE_MODE_ENABLED=1 ADVANCE_MODE_AUTO=2`. `AnimationMixer`:
    `ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS=0 IDLE=1 MANUAL=2`.
- **[O] Fresh-object defaults**: `AnimationTree` → `process_callback=1` (IDLE),
  `active=true`, `tree_root=<Object#null>`, empty `anim_player`;
  `AnimationPlayer` → `callback_mode_process=1` (IDLE), `active=true`;
  `AnimationNodeStateMachineTransition` → `advance_mode=1` (ENABLED),
  `switch_mode=0` (IMMEDIATE), `xfade_time=0.00`, `priority=1`.
  **A new `AnimationTree` is already `active` and already IDLE** — the
  `active=true` step is a no-op, the callback-mode step is not.
- **[O] The user-facing parameter surface** (from `tree.get_property_list()`,
  verbatim):
  - blend tree `{anim, output}`: `parameters/current_length,
    parameters/current_position, parameters/current_delta,
    parameters/output/current_{length,position,delta},
    parameters/anim/current_{length,position,delta}, parameters/anim/backward`
  - state machine: `parameters/playback`, `parameters/conditions/go`, plus
    `End`/`Start`/per-state `current_{length,position,delta}` and `backward`
  - blend tree with `AnimationNodeTimeScale`: `parameters/ts/scale`.
  **`parameters/current_position` is the AnimationTree clock** — the only
  script-visible time source; `AnimationPlayer.current_animation_position` is
  *not* it (§1.3).

---

## 1. Building a minimal AnimationTree from script

Rig for every cell: `Stage` → `Actor: Node3D` + `Ball: RigidBody3D`
(`freeze=true`, y=3) + `Player: AnimationPlayer` (library `a` = Actor x 0→4,
`b` = Actor y 0→4, `ab` = Actor **and** Ball tracks) + `Tree: AnimationTree`
(`process_callback=0`, `anim_player = tree.get_path_to(player)`).

### 1.1 `connect_node` is receiver-first — measured on four arms **[O]**

`AnimationNodeBlendTree.connect_node` takes 3 args in 4.7.2. `at_wire.gd`
ran both readings (`runs/` has the arms; superseded by `tr_*`):

| arm | call | result |
|---|---|---|
| A (provider-first) | `connect_node("anim", 0, "output")` | **rejected**: `ERROR: Condition "p_output_node == SceneStringNames::get_singleton()->output" is true.` — no connection |
| A (provider-first) | `connect_node("a", 0, "blend")` | **rejected**: `ERROR: Index p_input_index = 0 is out of bounds ((int)nodes[p_input_node].connections.size() = 0).` |
| B (receiver-first) | `connect_node("output", 0, "anim")` | **works** — `E pf=20 … actor=(1.2000,0.0000,0.0000)`, `ONE arm=B_one … actor=(1.2667,0.0000,0.0000)` |
| B (receiver-first) | `connect_node("blend", 0, "a")` + `("blend", 1, "b")` + `("output", 0, "blend")` | **works** — `w=0.0 actor=(0.8667,0,0)`, `w=1.0 actor=(0.0,0.9333,0)` |

Author directive: `connect_node(<node whose input port is fed>, <its input
index>, <node whose output feeds it>)`. **[O]** Also measured:
`AnimationNodeAnimation` has **no input ports** — `connect_node("anim", 0, …)`
is the rejected form above; the only valid wiring into a graph is *out of* an
animation node.

### 1.2 The minimal tree runs, and the tree clock is the only time source **[O]**

`tr_proj_min.r1` (6 reps stable; identical GP/Jolt, Dummy identical modulo
`srv=nil`):

```
PRE active=true cb=0 root=AnimationNodeBlendTree pactive=true playing=false anim= ppos=0.0000
E pf=2 seq=5 actor=(0.0000,0.0000,0.0000) ball=(0.0000,3.0000,0.0000) srv=(0.0000,3.0000,0.0000) tp=0.0000
E pf=3 seq=9 actor=(0.0000,0.0000,0.0000) ball=(0.0000,3.0000,0.0000) srv=(0.0000,3.0000,0.0000) tp=0.0000
E pf=4 seq=13 actor=(0.0667,0.0000,0.0000) ball=(0.0667,3.0000,0.0000) srv=(0.0667,3.0000,0.0000) tp=0.0167
…
E pf=31 seq=107 actor=(1.8667,0.0000,0.0000) … tp=0.4833
PARAM_LIST n=10 parameters/current_length,parameters/current_position,…
```

- **[O] The rate is exactly 4 u/s at 60 tps** (0.0667/frame), and the first
  **two** physics frames do not advance (`tp=0.0000` at pf=2 and pf=3) — the
  r92 "first awaited frame does not advance" law, one frame wider in this rig.
- **[O] The tree does not drive the `AnimationPlayer`**: `playing=false`,
  `anim=` (empty) for the whole run, and any read of
  `player.get_current_animation_position()` raises
  `ERROR: AnimationPlayer has no current animation.
  (scene/animation/animation_player.cpp:732)`. The tree evaluates the library
  itself and writes the **targets**; `parameters/current_position` is the clock.
  A fixture that pins `player.current_animation_position` under an active tree
  measures an error, not a time. **[O]**
- **[O] `tree.active=false` ⇒ total inertness** (`tr_*_inactive`: 12 frames,
  actor `(0,0,0)`, `pactive=true playing=false`), and flipping it on mid-run
  (`activelate`) starts the animation from the *current* clock, not from 0
  (`BEFORE_ACTOR (0,0,0)` → `AFTER_ACTOR (0.6000,0,0)` after 10 frames).

### 1.3 Degenerate roots and missing data — three different failure classes **[O]**

| cell | setup | measured |
|---|---|---|
| `animnode_root` | `tree.set("tree_root", AnimationNodeAnimation)` | **accepted** (`AR_ASSIGN tree_root=AnimationNodeAnimation`, actor moves to `(0.4000,0,0)`) — no need for a blend tree wrapper |
| `bt_missing` | `AnimationNodeAnimation.animation="ghost"` | **completely silent**: actor static, `playing=false`, **zero** error/warning lines |
| `bt_dupnode` | `add_node("anim", …)` twice | `ERROR: Condition "nodes.has(p_name)" is true.` — node list unchanged, original kept (`same=true`) |
| `null_anim_player` (life) | `tree_root` set, `anim_player` empty | silent, actor static, rc=0 |
| `null_root` (life) | `anim_player` set, `tree_root=null`, `active=true` | silent, actor static, rc=0 |
| `parammiss` | `set("parameters/nope/amount", 1.0)`, `set("parameters/blend/nope", 1.0)` | **silent no-op**; reads return `<null>`; the valid write still lands (`PM_AFTER_WRITES blend=0.5`, `PM_ACTOR actor=(0.1667,0.1667,0.0000)`) |

Author directive: a typo in an animation name or a parameter path is
**indistinguishable from a correct-but-static rig** by stdout alone; assert on
the target transform, not on the absence of errors.

### 1.4 The untracked-target default write — headline hazard **[O]**

`tr_*_untracked` (two arms in one process, 3 reps stable, identical on all
three backends):

```
UT_ARM1_LIB ["a", "ab", "b"]
UT_ARM1_BUILD actor=(0.0000,0.0000,0.0000) ball=(0.0000,3.0000,0.0000) srv=(0.0000,3.0000,0.0000)
UT_ARM1_FRAME1 actor=(0.0000,0.0000,0.0000) ball=(0.0000,3.0000,0.0000) srv=(0.0000,3.0000,0.0000) tp=0.0000
E pf=2  actor=(0.0000,0.0000,0.0000) ball=(0.0000,3.0000,0.0000) srv=(0.0000,3.0000,0.0000) tp=0.0000
E pf=3  actor=(0.0000,0.0000,0.0000) ball=(0.0000,0.0000,0.0000) srv=(0.0000,0.0000,0.0000) tp=0.0000
UT_ARM1_POST actor=(0.4667,0.0000,0.0000) ball=(0.0000,0.0000,0.0000) srv=(0.0000,0.0000,0.0000) tp=0.1167
UT_ARM2_LIB ["a"]                     # same rig, library has no Ball track anywhere
UT_ARM2_POST actor=(0.5333,0.0000,0.0000) ball=(0.0000,3.0000,0.0000) srv=(0.0000,3.0000,0.0000) tp=0.1333
```

- **[O] When the playing animation does not drive a path that exists anywhere
  in the `AnimationPlayer`'s library, the tree writes the track type's default
  (`Vector3.ZERO` for `TYPE_POSITION_3D`) to that path on its first process.**
  Arm 1: the Ball snaps `(0,3,0) → (0,0,0)` (node *and* physics server) at
  `pf=3` while the playing animation `a` never mentions it. Arm 2 (no Ball
  track in any animation) leaves the Ball at `(0,3,0)` forever.
- This is the r92 `empty_track` law widened from "a keyless track in the playing
  animation" to **"any track path in the library"**; it is the mechanism behind
  the `activelate` Ball snap (`ball=(0.0000,0.0000,0.0000)` at the activation
  frame, from a library that contains `ab`).
- **[O] Author directive**: keep unrelated nodes out of the player's library, or
  give every animation an explicit track for every path it can reach — a
  subtree that merely *appears* in some other animation gets teleported to the
  origin. Silent: no error, no warning in either arm.
- **[?]** Whether the write is library-wide or per-path-cache is not isolated
  (a third arm with a Ball track only in a *never-added* library was not run).

---

## 2. Blend tree semantics **[O]**

`tr_*_blend2` / `tr_*_blendparam` (3 reps stable on all backends; `a` drives
Actor x, `b` drives Actor y):

```
BL_SET w=0.00 read=0.0 ; BL_ROW w=0.00 tp=0.0667 … got=(0.4667,0.0000,0.0000)
BL_SET w=0.50 read=0.5 ; BL_ROW w=0.50 tp=0.1000 … got=(0.5000,0.2667,0.0000)
BL_SET w=1.00 read=1.0 ; BL_ROW w=1.00 tp=0.1333 … got=(0.0000,1.0667,0.0000)
BP w=0.00 read=0.0  tp=… actor=(0.2000,0.0000,0.0000)
BP w=0.25 read=0.25 tp=… actor=(0.3500,0.0667,0.0000)
BP w=0.50 read=0.5  tp=… actor=(0.3667,0.2667,0.0000)
BP w=0.75 read=0.75 tp=… actor=(0.2500,0.6000,0.0000)
BP w=1.00 read=1.0  tp=… actor=(0.0000,1.0667,0.0000)
```

- **[O] `parameters/<node>/blend_amount` is a live float write with immediate
  read-back** (`read` equals the written value exactly, every step), and the
  output is a per-component linear blend of the two animation outputs: x decays
  0.20→0.35→0.37→0.25→0.00 while y rises 0.00→0.07→0.27→0.60→1.07 as `w`
  rises 0.00→1.00 (the time also advances during the walk, so the pure
  relation is the *monotone hand-over*; the endpoints are exact: `w=0` ⇒ pure
  `a`, `w=1` ⇒ pure `b`).
- **[O] `AnimationNodeTimeScale` wiring**: `connect_node("ts", 0, "anim")`
  (TimeScale's input 0 ← the animation node) + `connect_node("output", 0,
  "ts")`; then `parameters/ts/scale` reads `1.0` and setting `2.0` doubles the
  clock: `TS_BEFORE tp=0.1167 actor=(0.4667,0,0)` → `TS_AFTER tp=0.3833
  actor=(1.5333,0,0)` after 8 more physics frames — **Δtp = 0.2667 = 16/60 s
  over 8 physics frames = exactly 2×**.
- **[O] `tree_root` replacement mid-run does not reset the clock**:
  `RS_BEFORE actor=(0.6000,0,0) tp=0.1500` → `RS_ASSIGN root=AnimationNodeBlendTree`
  → `RS_AFTER actor=(0.0000,1.2667,0) tp=0.3167` — the new graph is evaluated
  at the *continued* clock (1.2667 = 4 u/s × 0.3167 s), so a swap is a hard
  cut in pose but not in time.
- **[O] `tree.process_mode = PROCESS_MODE_DISABLED` freezes the tree**
  (`PZ_BEFORE 0.3333` → `PZ_AFTER 0.3333` after 6 frames, `active` still true)
  and restoring it resumes (`PZ_RESTORED 0.7333`). Unlike r92's
  `RemoteTransform3D` propagation, this driver *is* stoppable.

---

## 3. Per-backend question: the AnimationTree surface is backend-inert **[O]**

- **[O] Cross-backend projection identity: 41/43 cells identical across
  GP/Jolt/Dummy** (`audit.py` + masked comparison; the mask covers the Dummy-only
  `srv=nil`, the per-run playback instance id, and one probe-side counter).
  The only 2 differing cells are `mo/idle` and `mo/idle_player_phys`, which
  differ *within a backend across reps* — scheduler-driven, not backend-driven.
  GP vs Jolt: **41/43 identical** (same 2).
- **[O] `tr_*_body` verbatim (identical GP/Jolt; Dummy differs only in the
  server read)**:

```
GP   : BD_POST actor=(1.2667,0.0000,0.0000) ball=(1.2667,3.0000,0.0000) srv=(1.2667,3.0000,0.0000) frozen=true
Jolt : BD_POST actor=(1.2667,0.0000,0.0000) ball=(1.2667,3.0000,0.0000) srv=(1.2667,3.0000,0.0000) frozen=true
Dummy: BD_POST actor=(1.2667,0.0000,0.0000) ball=(1.2667,3.0000,0.0000) srv=nil frozen=true
```

  The AnimationTree's write to a frozen `RigidBody3D` **reaches the physics
  server** exactly as the r92 `AnimationPlayer` write did, with the same
  byte-identical value on the node and on the server, on both real backends;
  Dummy keeps the node-side write and reports no server state (the established
  Dummy signature, not an animation divergence).
- **[I]** The blend/state-machine/parameter layers live entirely above the
  solver — no cell in this sweep needed a backend split, and none was found.

---

## 4. `AnimationNodeStateMachine` — the entry contract is `Start` **[O]**

`at_sm.gd`, rig as above, `tree_root = AnimationNodeStateMachine` with user
states `a`, `b` (and `c` in `notravel`).

- **[O] A fresh state machine contains built-in `Start` and `End` states and
  begins in `Start`**: `SM_LINK … nodes=[&"End", &"Start", &"a", &"b"]`,
  `MIN_PRE node=Start playing=false actor=(0.0000,0.0000,0.0000)`, and after 12
  frames `MIN_POST node=Start playing=true travel_path=[] actor=(0.0000,…)`.
  **A minimal SM animates nothing until a travel happens** — `pb.travel("a")`
  then gives `MIN_AFTER_TRAVEL node=a playing=true actor=(0.4667,0,0) tp=0.1167`.
  There is **no `set_start_node` API** (`SN_HAS_SETTER false`), so the entry
  state is not authorable through script in this build.
- **[O] `travel()` is deferred by one process**: `TV_CALL_IMMEDIATE node=Start`
  (same-statement read) → next frames `node=b actor=(0.0000,0.6000,0.0000)`.
- **[O] `travel()` to a state with no transition works as a hard cut**
  (`notravel`: `nodes=[&"End",&"Start",&"a",&"b",&"c"]`, no transitions,
  `NT_AFTER node=b actor=(0.0000,0.4667,0.0000) travel_path=[]`), and it also
  **resets the clock to 0** (`tp 0.1500 → 0.0000` at the switch frame in
  `xfade`/`xfade2` rows).
- **[O] `stop()` / `start()`** (`stopstart` rows, verbatim):
  `SS_STOP_IMMEDIATE node=b playing=true` (read-back is not synchronous);
  the switch frame shows `node=b … actor=(0.0000,0.0000,0.0000) tp=0.0000`
  (clock reset), then the current state **keeps advancing**
  (`pf=14..18 actor y 0.2667→0.5333, tp 0.0667→0.1333`) while
  `SS_STOPPED … playing=false`; `pb.start("b")` resets the clock again
  (`pf=19 tp=0.0000`) and resumes from the state's start.
  **[O] Author directive**: `stop()` is not "freeze the pose" — it resets the
  play position and clears `is_playing()`, while the current state's animation
  continues to be evaluated.
- **[O] Advance conditions — `AUTO` fires, `ENABLED` did not** (76-frame runs,
  condition written to `true` while active and at state `a`):
  - `condlong` (`ADVANCE_MODE_ENABLED`, `advance_condition="go"`):
    `COL_END mode=1 node=a actor=(4.0000,0.0000,0.0000) tp=1.0000 fading=@0.0000 cond=true`
    — **no transition**, even with the condition true and the animation at its
    end (`tp=1.0000` = the 1.0 s length).
  - `condauto` (`ADVANCE_MODE_AUTO`, same condition):
    `COL_END mode=2 node=b actor=(0.0000,4.0000,0.0000) tp=1.0000 fading=@0.0667 cond=true`
    — **fired at the animation end**.
  - **[O] Practical directive: drive auto-transitions with `ADVANCE_MODE_AUTO`;
    `ENABLED` produced no advance in this rig.** **[?]** What `ENABLED` *does*
    require is not identified (the census enum is
    `DISABLED=0 ENABLED=1 AUTO=2`).
- **[O] A condition written while the tree is inactive fires on re-activation**
  (`condlate`: `CL_WRITE_INACTIVE cond=true active=false` → `CL_ACTIVE node=b
  actor=(0.0000,0.6000,0.0000)`), i.e. stale conditions are dangerous: a state
  switch happened although the machine had never entered the transition's
  source state (`Start → b`, the transition being `a → b`).
- **[O] `next()` was inert** with the only transition `ADVANCE_MODE_DISABLED`
  (`NX_BEFORE node=a` → `NX_AFTER node=a actor=(0.7333,0,0)`) — a null cell at
  this wiring, not a disproof.
- **[O] `travel("zzz")` to a nonexistent state is silent on a live playback**
  (`BN_AFTER_ZZZ node=Start travel_path=[]`, zero error lines), but the same
  call on a playback whose root was swapped away errors three times:
  `ERROR: No such node: 'b'`, `ERROR: b is not found current state.`,
  `ERROR: Condition "!p_state_machine->states.has(travel)" is true. Returning: false`.
- **[O] `parameters/playback` is one object reused across root swaps**:
  `PB_SWAP same_object=true old=():<AnimationNodeStateMachinePlayback#…> new=():<… same id …>`
  — cache it once; and after the swap the same object drives the *new* graph
  (`PB_END old_node=Start new_node=Start`).
- **[O] `xfade_time` produced no observable crossfade in either arm**:
  `xfade` (`xfade_time=0.5`, `SWITCH_MODE_IMMEDIATE`) and `xfade2`
  (`xfade_time=1.0`, `SWITCH_MODE_SYNC`) both show a hard cut with the clock
  reset (`S pf=12 node=a actor=(0.6000,0,0) tp=0.1500` →
  `S pf=13 node=b actor=(0.0000,0,0) tp=0.0000`) and `fading=@0.0000` on every
  frame. **[?]** The crossfade blend surface is therefore *unmeasured*, not
  disproven (a rig that keeps `reset` off, or `SWITCH_MODE_AT_END`, is the next
  probe).
- **[O] Duplicate state names**: `ERROR: Condition "states.has(p_name)" is true.`
  — original kept.

---

## 5. Rep stability — the r92 callback law, re-stated for `AnimationTree` **[O]**

`at_mode.gd`, one blend tree, 40 physics frames, rows per physics **and** per
idle callback, plus fixed-threshold samples (`x_pf10/20/30` = the first physics
frame ≥ 10/20/30, `x_idle10/20` = the 10th/20th idle callback).

| cell | `process_callback` | player `callback_mode_process` | x_pf10 | x_pf20 | x_pf30 | verdict |
|---|---|---|---|---|---|---|
| `phys` | **0 PHYSICS** | 0 | `0.5333` | `1.2000` | `1.8667` | **rep-stable** (3/3, raw byte-identical) |
| `phys_player_idle` | 0 PHYSICS | 1 IDLE | `0.5333` | `1.2000` | `1.8667` | **rep-stable** |
| `idle` | **1 IDLE (default)** | 0 | `0.6208` / `0.6205` / `0.6209` | `1.2871` / `1.2868` / `1.2872` | `1.9538` / `1.9534` / `1.9538` | **rep-unstable** (3/6 reps differ in the 4th decimal) |
| `idle_player_phys` | 1 IDLE | 0 PHYSICS | varies | varies | varies | **rep-unstable** |
| `manual` | 2 MANUAL | 0 | — | — | — | no advance without `advance()` |

- **[O] The law**: an AnimationTree cell must pin
  `tree.process_callback = ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS (=0)`.
  The **default is IDLE (=1)**, and IDLE makes the value at a fixed physics
  frame depend on how many rendered frames the unthrottled headless scheduler
  granted. `AnimationPlayer.callback_mode_process` is irrelevant once a tree
  drives the targets (`phys_player_idle` stable, `idle_player_phys` unstable).
- **[O] MANUAL is inert until advanced, and the first `advance()` is absorbed**:
  `MA_IDLE actor=(0,0,0)` → `MA_ADV1 actor=(0.0000,0,0)` → `MA_ADV2
  actor=(1.0000,0,0)` for `advance(0.25)` at 4 u/s (the second call lands
  exactly one dt: 4 × 0.25 = 1.0). Same "first process initializes, does not
  advance" shape as §1.2.
- **[O] Rep-identity census over the whole sweep**: 130 multi-rep tags →
  **123 rep-stable, 7 unstable**; the 7 are `mo_*_idle` (3), `mo_*_idle_player_phys`
  (3) and `mo_proj_dummy_manual` (whose only projection difference is the
  probe's own scheduler-variable `idle_rows` counter in its summary line — the
  animated values are byte-identical 3/3). Raw stdout differs while the
  projection matches wherever the idle-frame *count* varies
  (`idle_rows` 74–75 in the tree cells): the r92 idle-multiplicity signature,
  reproduced here for the tree.
- **[O] Physics-anchored value identity** (`erows`: pf normalized to the first
  physics frame, `seq` masked) is identical for every non-IDLE cell — the
  values at equal physics-frame counts are deterministic.

---

## 6. Lifecycle / teardown — 10 cells × 6 reps, all rc=0 **[O]**

| cell | verbatim | reading |
|---|---|---|
| `freetree` | `FT_BEFORE … actor=(0.4667,0,0)` → `FT_FREED tree=invalid pactive=true` → `FT_AFTER actor=(0.4667,0,0)` | freeing the tree freezes the pose, no error, no crash |
| `freeplayer` | `FP_FREED … player=invalid` → `FP_AFTER actor=(1.0000,0,0)` | **the tree keeps animating after the AnimationPlayer is freed** (it holds the animation data itself); no crash |
| `freeactor` | `FA_FREED actor=invalid` → `FA_AFTER … actor=invalid` | freeing the animated target is silent and harmless (6/6 rc=0) |
| `active_off` | `AO_OFF active=false` → `AO_AFTER actor=(0.4667,0,0)`; `AO_ON` → `AO_REACT actor=(0.4667,0,0)` | off freezes; on resumes from the same pose (clock held) |
| `remove_readd` | `RR_REMOVED` (frozen) → `RR_READDED` → `RR_AFTER actor=(1.0000,0,0)` | re-entry rebinds and resumes |
| `reparent` | `RP_AWAY actor=(0.4667,0,0)` + `WARNING: AnimationMixer: 'a', couldn't resolve track: 'Actor'.` → `RP_AFTER actor=(1.5333,0,0)` | leaving the `root_node` subtree breaks track resolution (warning class), returning repairs it |
| `null_anim_player` | `NP_AFTER actor=(0,0,0)` | silent inertness |
| `null_root` | `NR_AFTER root=null actor=(0,0,0)` | silent inertness |
| `tree_root_null` | `TN_BEFORE actor=(0.6000,0,0)` → `TN_NULLED root=null` → `TN_AFTER actor=(0.6000,0,0)` | nulling the root **freezes at the last pose** (no reset to default) |
| `playback_after_rootswap` | `PB_SWAP same_object=true` → `PB_END old_node=Start new_node=Start` + 3 errors | one playback object, rebound to the new graph |

- **[O] No teardown crash anywhere**: 180 life children (30 cells × 6 reps), all
  rc=0, and every one of the 30 life tags is rep-stable in value (the r97
  `XRServer` instantiate+free SIGSEGV class does **not** reproduce for any
  AnimationTree/AnimationNode object, including `AnimationTree.free()`,
  `AnimationNodeBlendTree`/`AnimationNodeStateMachine`/`AnimationNodeAnimation`
  free and unreference paths in the census).
- **[O] Warning vs silence split**: unresolved track paths after a reparent emit
  `WARNING: AnimationMixer: '<anim>', couldn't resolve track: '<path>'` (once
  per animation), whereas a missing animation name (`bt_missing`) and a missing
  parameter path (`parammiss`) emit nothing.

---

## 7. Hazards

1. **Probe-hang mode (harness)**: a *runtime* script error inside a `--script`
   SceneTree callback aborts the callback but leaves the process alive — the
   first census pass ran 3/3 into `timeout -s KILL` at `rc=137` (60 s each)
   instead of exiting. Any r99+ animation probe should arm a watchdog timer
   before touching the API (the probes here do; `rc=3` = watchdog abort, and no
   cell used it in the final sweep).
2. **Untracked-target default write** (§1.4): any node path present in *any*
   animation of the player's library is written `Vector3.ZERO` when the tree is
   active, even if that animation is not playing. Silent.
3. **Silent no-ops**: missing animation name, missing parameter path, and
   `travel()` to a missing state (live playback) are all silent; assert on the
   target transform.
4. **Default callback mode is IDLE** (§5): an AnimationTree built from script
   without touching `process_callback` cannot be rep-stable in unthrottled
   headless.
5. **The SM entry state is `Start`** and is not script-authorable: a state
   machine that never travels renders nothing, and a condition that is true
   while the tree is inactive can switch state on activation (§4).
6. **`stop()` is not a freeze** (§4): it resets the play position and clears
   `is_playing()`, while the current state keeps advancing.
7. **`AnimationPlayer.current_animation_position` is an error source** under an
   active tree — the clock is `parameters/current_position` (§1.2).
8. **`connect_node` argument order** (§1.1): the provider-first form is rejected
   with a bounds error on a 0-input node and with an "output" guard otherwise —
   a wrong-order graph silently renders nothing if the calls are wrapped in
   error handling.

---

## 8. Author directives (each backed by a measured cell)

1. **Build a tree with** `tree.anim_player = tree.get_path_to(player)`,
   `tree.process_callback = ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS` (0),
   `tree.tree_root = <AnimationNodeBlendTree | AnimationNodeStateMachine |
   AnimationNodeAnimation>`, then wire **receiver-first**
   (`connect_node("output", 0, "anim")`). `active` is already true. [§1.1, §1.2]
2. **Pin the physics frame count and read the target transform** — never
   `player.current_animation_position`; use `tree.get("parameters/current_position")`
   for the clock. [§1.2]
3. **Expect two non-advancing physics frames** at start (and one absorbed
   `advance()` in MANUAL) before the ramp begins. [§1.2, §5]
4. **Keep the player's library free of paths you do not want reset**; a track
   path that appears in *any* library animation is defaulted to
   `Vector3.ZERO` when the tree runs. [§1.4]
5. **Blend with `parameters/<node>/blend_amount`** (immediate read-back, exact
   endpoint hand-over) and scale time with
   `connect_node("ts", 0, "anim")` + `parameters/ts/scale` (verified 2× rate).
   [§2]
6. **A root swap is a pose cut on a continuing clock** (tp 0.1500 → 0.3167);
   nulling the root freezes at the last pose. [§2, §6]
7. **State machines start in `Start`**: always `travel()` (or fire a condition)
   to enter a state; drive auto-transitions with `ADVANCE_MODE_AUTO`
   (`ENABLED` did not advance in this rig); expect a one-process delay between
   the `travel()` call and the switch. [§4]
8. **Cache `parameters/playback` once** — it is the same object after a root
   swap; and do not rely on `stop()` to freeze a pose. [§4]
9. **Backend-inert**: no per-backend branching is needed for any AnimationTree
   behaviour measured here (41/43 cells identical across GP/Jolt/Dummy; Dummy
   only lacks server reads). [§3]
10. **Teardown is safe**: freeing the tree, the player, or the animated target
    mid-run is rc=0 and rep-stable — but the tree keeps animating after the
    player is freed, so "player alive" is not a liveness signal. [§6]

---

## 9. Remaining unknowns

1. **What `ADVANCE_MODE_ENABLED` actually requires** — it did not fire with a
   true condition and a finished animation; `AUTO` did. [?]
2. **`xfade_time` crossfade** — no blend observed in either arm
   (`IMMEDIATE`/`SYNC`, 0.5 s/1.0 s); `SWITCH_MODE_AT_END`, `reset=false`, and
   `break_loop_at_end` are untested. [?]
3. **The untracked-default mechanism** — library-wide path set vs a per-path
   cache; a third arm (library present but never added to the player) was not
   run. [?]
4. **`AnimationNodeBlendSpace1D/2D`** — classes exist and instantiate, but no
   blend-space cell was written (the r92 §7.6 gap is narrowed, not closed). [?]
5. **`AnimationNodeOneShot` / `AnimationNodeTransition` /
   `AnimationNodeAdd2/3` / `Mix*` / `Sync`** — classes present, `ONE_SHOT_*` and
   `MIX_MODE_*` constants enumerated, no behaviour cell. [?]
6. **`AnimationNodeAnimation.play_mode` (`PLAY_MODE_FORWARD/BACKWARD`)** and the
   `parameters/<node>/backward` boolean — enumerated, not measured. [?]
7. **Skeleton targets** — this sweep animates `Node3D`/`RigidBody3D`; an
   AnimationTree driving `Skeleton3D` bone tracks is still unmeasured (r86 rank
   11's other half). [?]
8. **`root_motion`** (`get_root_motion_position`, `set_root_motion_track`
   present) — untouched. [?]

---

## 10. Host cleanup and writes

- `pgrep -af godot` at completion: no `r99-scout` process alive; every child was
  `timeout -s KILL 120` bounded and accounted for by a `.exit` receipt
  (536/536 rc=0 — no kill, no watchdog abort).
- Writes: `corpus/live/r99-scout/**` (gitignored) + this report. No
  `corpus/fixtures/**`, no tracked-tree edits, no commits.
- Scratch provenance: `manifest.sha256` (all probe/driver/audit/run files),
  `RECEIPTS.md`, `audit_report.txt`, `*_batch.log`.

## Reproducing

```bash
cd corpus/live/r99-scout
python3 driver.py --batch census --jobs 3   # class surface + parameter dumps
python3 driver.py --batch tree   --jobs 6   # §1–§3 (14 cases × 3 backends)
python3 driver.py --batch sm     --jobs 6   # §4   (14 cases × 3 backends)
python3 driver.py --batch mode   --jobs 6   # §5   (5 cases × 3 backends)
python3 driver.py --batch life   --jobs 6   # §6   (10 cases × 3 backends × 6 reps)
python3 audit.py                            # rc census + 3 rep-identity measures
```

Single cells: `--batch <b> --only <tag-substr>`; one project per backend is one
line in `driver.py`'s `PROJECTS`; `proj*/` is regenerated by the driver.
`at_wire.gd` is the `connect_node` order probe (arms `A_one`/`B_one`/`A_blend`/
`B_blend`) — run it manually as in §1.1 if the argument order is ever in doubt.
