# r99 boundary — attacking the r99 scout's `AnimationTree` pins

Lane: g3d · engine `4.7.2.stable.arch_linux.ed1daf0bf` · `--headless`, 60 tps.
Seat: boundary (falsification). Namespace `r99b_*`. Probe A–F, driver, audit.
Evidence: `corpus/live/r99-boundary/` — `probes/` (6 `.gd`), `driver.py`,
`audit.py`, `runs/` (**939 children**, `.exit`/`.ms`/`.cmd` sidecars),
`RECEIPTS.md`, `manifest.sha256` (3 767 lines), `audit_report.txt`, batch logs,
`load_snapshot.txt`.

Measured: **292 cells / 939 children / 939× rc=0** — no crash, no `timeout -s
KILL` kill (`rc=137`), no watchdog abort (`rc=3`), no mid-arm script-error
truncation (every run contains its arm's declared final marker; `audit.py`
checks this, because a GDScript error inside a coroutine aborts the arm and
still exits 0 — hit once during development, `sm/enabled_reapply`).

Every child: `timeout -s KILL 25 <godot> …` (task bound). Backends swept for
every cell: GodotPhysics (`proj`), Jolt (`proj_jolt`), Dummy (`proj_dummy`).
Deterministic arms run under `--fixed-fps 60` (r100's byte-stable scheduler);
`base` (no `--fixed-fps`) is kept as the scout's verbatim, unthrottled control.

**Host disclosure.** This lane shares the host with other seats; during the
sweeps there were foreign `yes` hogs, an `r92-verify2` battery, `r96-boundary`
children and a `game-dev-2d` `r91-boundary run_matrix.sh ff120load` matrix.
`load_snapshot.txt` records loadavg **84 → 110** (32 cores) across the 32-hog
round. No foreign process was signalled; my hogs are spawned with
`start_new_session=True` and killed by pgid.

Confidence: **[O]** receipt-pinned observation, **[I]** inference, **[?]**
unknown. Scratch; no tracked writes except this report; no commits.

---

## 0. Verdict table

| r99 scout pin | verdict | evidence |
|---|---|---|
| §1.1 `connect_node` is receiver-first; provider-first rejected | **survives** | §5.1 |
| §1.2 rate exactly 4 u/s at 60 tps; pose = clock | **survives** (example row is internally inconsistent) | §5.2 |
| §1.2 "the first two physics frames do not advance" | **corrected** — 2 is *sampler-position* and *rate* dependent (0–4) | §3 |
| §1.2 tree drives no `AnimationPlayer`; `current_animation_position` errors | **survives** | §5.2 |
| §1.3 missing animation / missing parameter are silent | **survives** | §5.3 |
| §1.3 duplicate node name errors, original kept | **survives** (blend tree *and* state machine) | §5.3 |
| §1.4 untracked-target default write, "on its first process" | **falsified in the mechanism, confirmed as a hazard** — the write is re-applied **every process pass**; scope is the library **(path, track-type)** set of *that* mixer | §1 |
| §1.4 attribution to the tree (vs the player) | **survives** — a plain `AnimationPlayer.play("a")` on the same library does **not** write the Ball | §1.4 |
| §2 blend/TimeScale/root-swap semantics | **survives** byte-identically | §5.4 |
| §3 backend-inert (GP/Jolt/Dummy) | **survives** — 85 cross-backend groups, 10 differ, all unthrottled-IDLE interleave | §4 |
| §4 "AUTO fires, ENABLED did not" | **survives, re-read** — AUTO fires **immediately** on the condition, and with *no* condition AUTO fires on entry (state skipped); ENABLED never auto-fires in 7 arms | §2.1 |
| §4 "fired at the animation end" (AUTO) | **falsified** — the switch is at the frame after the condition write (pf=7), not at `tp=1.0` | §2.1 |
| §4 "what ENABLED requires is not identified" | **partly answered** — not `next()` either (inert in DISABLED *and* ENABLED); `travel()` never populates a travel path in this rig | §2.3 |
| §4 `stop()` resets the clock, keeps advancing; read-back not synchronous | **survives** | §5.5 |
| §4 stale condition fires on re-activation (AUTO) | **survives** (AUTO only; ENABLED lands on the travel target) | §2.4 |
| §4 `travel("zzz")` silent on a live playback | **falsified** — 3 ERROR lines on the following process pass, in both playing states | §5.3 |
| §5 "must pin `process_callback = PHYSICS`; IDLE is rep-unstable" | **corrected** — IDLE is rep-unstable only *unthrottled*; under `--fixed-fps` every cell is rep-stable (IDLE included) but IDLE is **rate-dependent** while PHYSICS is rate-**invariant** | §2.2 |
| §5 "phys rep-stable 3/3, raw byte-identical" | **corrected** — the raw row interleave varies in `base` for *every* cell under ambient load; only the physics-anchored value projection is stable | §2.2 |
| §6 teardown is safe, no crash (incl. `freeplayer` keeps animating) | **survives** (6 reps × 3 backends) | §5.6 |
| §6 no r97-style instantiate+free crash | **survives** — 340 instantiate+free cycles | §5.6 |

---

## 1. The headline hazard, re-measured and bounded (§1.4)

### 1.1 Scope matrix (probe A, `--fixed-fps 60`, 3 reps × 3 backends, all rep-identical)

Rig: `Stage → Actor(Node3D) + Ball(frozen RigidBody3D @ y=3) + Player + Tree`;
the tree plays animation `a` (Actor-only). `POST <arm> … ball=` verbatim:

| arm | library / setup | Ball after | reading |
|---|---|---|---|
| `ctl` | `{a,b,ab}` (`ab` carries the Ball track) | `(0,0,0)` | scout arm 1 reproduced |
| `libclean` | `{a}` only | `(0,3,0)` | scout arm 2 reproduced |
| `orphan` | `{a}` + a Ball-track `Animation` **kept alive but never added to a library** | `(0,3,0)` | **not** "any Animation object" — the path set comes from the mixer's libraries |
| `otherplayer` | `{a}` + a Ball-track animation in a **second `AnimationPlayer`** | `(0,3,0)` | mixer-scoped, not process-global |
| `namedlib` | `{a}` + a Ball-track animation in a **named** library `"extra"` of the same player | `(0,0,0)` | the path set spans **all** libraries of the player |
| `keyless` | `{a}` + a **keyless** Ball position track in a non-playing animation | `(0,0,0)` | the path set is built from track *paths*, keys irrelevant |
| `ballonly` | `{a}` + an animation driving **only** the Ball | `(0,0,0)` | the non-playing animation need not share any path with the playing one |
| `inactive` | `{a,b,ab}`, `tree.active=false` | `(0,3,0)` | the write needs an active tree |
| `manual` | `{a,b,ab}`, `process_callback=MANUAL`, no `advance()` | `(0,3,0)` for 8 frames | the write needs a **process pass** |
| `ghostpath` | `{a}` + an animation whose track path `"Ghost"` does not exist | `(0,3,0)` | an unresolvable path is cached with a WARNING but does not touch the Ball |

`ghostpath` also emits, once, on cache build:
`WARNING: AnimationMixer: 'g', couldn't resolve track:  'Ghost'.` — i.e. the
scout's warning class is **wider** than the reparent case they recorded: *any*
library animation with an unresolvable path warns at cache build, even if that
animation is never played.

### 1.2 "on its first process" is wrong — the write is **re-applied every pass**

`repeat` arm (`{a,b,ab}`), verbatim `proj` rows:

```
E pf=7 actor=(0.2667,0,0) ball=(0.0000,0.0000,0.0000) srv=(0.0000,0.0000,0.0000) tp=0.0667
E pf=8 actor=(0.3333,0,0) ball=(0.0000,0.0000,0.0000) srv=(0.0000,0.0000,0.0000) tp=0.0833
REPEAT_RESET ball=(0.0000,3.0000,0.0000)          # Ball restored by hand at pf=8
E pf=9 actor=(0.4000,0,0) ball=(0.0000,0.0000,0.0000) srv=(0.0000,0.0000,0.0000) tp=0.1000
E pf=10 … ball=(0.0000,0.0000,0.0000) …           # snapped straight back
```

**[O]** The default write is **not one-shot**: a runtime restoration of the node
is overwritten on the next pass. "Keep the player's library free of paths you do
not want reset" (scout directive 4) is therefore not just a build-time rule —
there is no runtime escape while the tree is active.

### 1.3 The write is keyed by **(path, track type)**, not by path alone

`typedef` arm: library `{a, sr}` where `sr` has **only** `TYPE_SCALE_3D` and
`TYPE_ROTATION_3D` tracks on `Ball`; Ball preset to `scale=(3,3,3)`,
`rotation_degrees=(0,45,0)`:

```
TYPEDEF_PRESET sc=(3.0000,3.0000,3.0000) rotY=45.00
TYPEDEF_POST   sc=(1.0000,1.0000,1.0000) rotY=0.00    ball=(0.0000,3.0000,0.0000)
```

**[O]** The Ball **position was not written** (no position track exists for that
path anywhere in the library) while scale → `Vector3.ONE` and rotation →
identity were. So the scout's "the track type's default" is exact, and their
open question ("library-wide path set vs per-path cache") resolves to a
**per-(path, track-type) cache built from every library of the mixer** — the
same cache `ghostpath` shows warning at build time.

### 1.4 Attribution survives: the tree does it, the player does not

`notree` arm: no `AnimationTree` at all, plain `player.play("a")` on
`{a,b,ab}` → `POST notree … ball=(0.0000,3.0000,0.0000) srv=(0.0000,3.0000,0.0000)`,
0 error lines, on all three backends. **[O]** The library-wide default write is
an `AnimationTree`/`AnimationMixer`-driven behaviour, not the r92
`AnimationPlayer` `empty_track` law; the two must not be merged. `inactive` and
`manual` bound it further: it requires an active tree **and** a process pass
(first `advance()` in MANUAL mode performs it — node zeroed at the call, server
catches up on the next physics step: `MANUAL_ADV_NOW … ball=(0,0,0) srv=(0,3,0)`).

---

## 2. The scheduler/state-machine laws, re-measured

### 2.1 `ADVANCE_MODE_ENABLED` is inert in **every** wiring tried; AUTO's timing is not what the scout read

Probe C, `--fixed-fps 60`, 3 reps × 3 backends, 0 error lines in all arms:

| arm | mode / wiring | final node | verdict |
|---|---|---|---|
| `enabled_ctl` | ENABLED + cond `go`, SM root, IMMEDIATE, 76 frames after cond=true | `a` (`tp=1.0000`) | scout cell reproduced |
| `enabled_atend` | ENABLED + cond, `SWITCH_MODE_AT_END` | `a` | no advance |
| `enabled_nested` | SM nested in a blend tree, cond written to `parameters/sm/conditions/go` (outer path reads `<null>`) | `a` | nesting does not enable it |
| `enabled_nocond` | ENABLED, no `advance_condition` at all | `a` | no end-of-state advance either |
| `enabled_early` | ENABLED, cond true 2 frames into state `a` | `a` | no early fire |
| `enabled_pre` | ENABLED, cond true **before** `travel("a")` | `a` | no fire |
| `enabled_reapply` | properties re-applied after `add_transition` | `a` | no fire |
| `autocond` | **AUTO** + cond true at pf=6 (`tp=0.05`) | **`b` at pf=7** | fires on the **condition**, not at the end |
| `autonocond` | **AUTO**, no condition | **`b` at pf=3**, the entry frame | fires on entry — the state is skipped |
| `next_enabled` / `next_auto` | `pb.next()` with an ENABLED / AUTO transition | `a` | inert in both |
| `next_path` | `a→b→c`, `travel("a")` then `travel("c")` | `c`, `travel_path=[]` | `travel()` is a hard cut; the path is never populated |

**[O] `autocond` per-frame trace** (the falsification of "fired at the animation
end"): `pf=3..6 node=a` with the condition false → `pf=7 node=b tp=0.0000`.
The scout's `COL_END … node=b … tp=1.0000` is simply the state of the run 76
frames later: `b` had itself reached its 1.0 s end. Their inference "fired at
the animation end" is not supported by the frames.

**[O]** Therefore directive 7 needs a condition caveat: *an AUTO transition
without an `advance_condition` fires the moment the state is entered* (chain
collapse — in `next_path` mode=2 the `a→b→c` chain collapsed to `c` in one
pass), while AUTO **with** a condition fires on the condition. ENABLED is a
manual/`travel()`-class mode in this build; 7 independent wirings produced no
auto-advance.

### 2.2 The §5 callback law: the real variable is the scheduler, not the callback mode

`MODE_SUM` physics-anchored fields (`x_pf10/x_pf20/x_pf30/t_pf30/lead_zero`),
`proj`, 3 reps each, watcher placed **before** the rig:

| rate | `phys` (tree cb=0) | `idle` (tree cb=1, default) | `manual` |
|---|---|---|---|
| `base` (unthrottled) | **STABLE** `0.4667/1.1333/1.8000/0.4500/2` | **UNSTABLE** 3 distinct sets: `0.3208/0.9995/1.6662/0.4165/4`, `0.3918/1.0572/1.7407/0.4352/3`, `0.4834/1.1458/1.8162/0.4541/2` | STABLE (`-/-/-/-/5`) |
| `--fixed-fps 30` | STABLE `0.4667/1.1333/1.8000/0.4500/2` | STABLE `0.5367/1.2000/1.8667/0.4667/2` | STABLE |
| `--fixed-fps 60` | STABLE `0.4667/1.1333/1.8000/0.4500/2` | STABLE `0.5333/1.2000/1.8667/0.4667/1` | STABLE |
| `--fixed-fps 120` | STABLE `0.4667/1.1333/1.8000/0.4500/2` | STABLE `0.5667/1.2333/1.9000/0.4750/0` | STABLE |

- **[O] The PHYSICS cell is rate-invariant** — identical physics-anchored values
  in `base` *and* at 30/60/120. That is a stronger property than the scout's
  "rep-stable", and it is the correct justification for directive 5.
- **[O] IDLE is rep-stable under every `--fixed-fps` rate but its value changes
  with the rate** (`0.5367 / 0.5333 / 0.5667` at pf10): fixing the scheduler
  makes it deterministic, not portable.
- **[O] `phys_player_idle` ≡ `phys` in every rate mode** (the scout's
  "`AnimationPlayer.callback_mode_process` is irrelevant once a tree drives the
  targets" survives).
- **[O] Raw-stdout byte-identity is not a property of the PHYSICS cell.** Under
  ambient load the F/E row interleave varies for *every* `base` cell, PHYSICS
  included; only the physics-anchored projection is stable. The scout's
  "`phys` … 3/3, raw byte-identical" does not generalise off a quiet host.
- **[O] Rep identity over the sweep: 269 multi-rep tags stable, 23 unstable —
  all 23 are `base` (unthrottled) cells.** Every `--fixed-fps` cell is
  rep-stable, including 6-rep lifecycle cells under 32 hogs.
- **[O] Cross-rate: 24 groups, 54 (base, ffpsN) pairs differ; cross-backend:
  85 groups, 10 differ (all 5 `base` mode cells × Jolt/Dummy, all
  interleave-only); physics-anchored cross-backend: 2 differ, both unthrottled
  IDLE cells.** Backend-inertness (§3) holds; the only cross-backend deltas are
  the scheduler class the scout itself identified.

### 2.3 Why `next()` is inert — a rig property, not a mode property

`next_path` (`a→b→c`, ENABLED *and* AUTO variants): `pb.travel("c")` from `a`
lands **directly** on `c` with `get_travel_path()=[]` in both modes; `pb.next()`
changes nothing. **[O]** In this rig `travel()` is always a hard cut and the
travel path is always empty, so `next()` has nothing to walk. The scout's
`next` null cell ("not a disproof") is therefore still a null cell — it is
**not** evidence about `advance_mode`, and my ENABLED arm does not rescue it.

### 2.4 Stale conditions on re-activation (AUTO), and the ENABLED contrast

`condlate` replay (`tree.active=false`, condition written true, `travel("a")`
while inactive, then activate): **AUTO → `CL_ACTIVE node=b actor=(0,0.6,0)
tp=0.1500`** (scout's claim reproduced, 3 reps × 3 backends). New contrast arm
`condlate_enabled`: **ENABLED → `node=a actor=(0.6,0,0) tp=0.1500`** — the
pending travel lands on `a` and the true condition does nothing. **[O]** The
"stale condition is dangerous" hazard is an AUTO-only hazard.

---

## 3. "The first two physics frames do not advance" — corrected

`ord_*` arms, same probe, same cell, only the sampler's position in the node
order differs (watcher added before the rig = `pre`, after the rig = `post`):

| rate | cell | watcher | x_pf10 | lead_zero | pf_first_move |
|---|---|---|---|---|---|
| `base` | `phys` | pre | `0.4667` | **2** | 4 |
| `base` | `phys` | post | `0.5333` | **1** | 3 |
| `ffps60` | `phys` | pre | `0.4667` | 2 | 4 |
| `ffps60` | `phys` | post | `0.5333` | 1 | 3 |
| `ffps60` | `idle` | pre | `0.5333` | **1** | 3 |
| `ffps60` | `idle` | post | `0.5333` | 1 | 3 |
| `base` | `idle` | pre/post | varies per rep | **0…4** | varies |

- **[O]** The tree's *first* process (which writes the defaults and does not
  advance) lands on the first physics frame after the rig exists, and the pose
  then advances one `dt` per physics frame. A sampler that runs **before** the
  `AnimationTree` in the same frame observes the previous pass, so it sees two
  zero rows (the first process, then the first advance); a sampler that runs
  **after** the tree sees exactly one. The scout's "two" is therefore a
  *sampler-position* artifact — and it is *rate/mode* dependent on top: the
  IDLE-callback tree consumes its non-advancing first process in the
  pre-physics idle frame at `--fixed-fps 60`, so it shows **one** zero frame
  and sits exactly one advance ahead of the PHYSICS tree sampled the same way
  (`0.5333` vs `0.4667` at pf=10, identical thereafter).
- **[O]** The scout's own two probes disagree on this offset (`at_tree.min`
  reads the pre-style value, `at_mode.phys` the post-style value), so the
  report's absolute threshold table is not portable across rigs. Directive 3
  ("expect two non-advancing physics frames") should be restated as: *expect
  one non-advancing physics frame after the tree's first process; count two only
  if your sampler runs before the tree node.*

---

## 4. Backend-inertness (§3) survives

`body` cell (probe D, `--fixed-fps 60`, 20 physics frames, identical on 3 reps and 3 backends):

```
proj      : BD_POST actor=(1.2667,0.0000,0.0000) ball=(1.2667,3.0000,0.0000) srv=(1.2667,3.0000,0.0000) frozen=true tp=0.3167
proj_jolt : BD_POST actor=(1.2667,0.0000,0.0000) ball=(1.2667,3.0000,0.0000) srv=(1.2667,3.0000,0.0000) frozen=true tp=0.3167
proj_dummy: BD_POST actor=(1.2667,0.0000,0.0000) ball=(1.2667,3.0000,0.0000) srv=nil frozen=true tp=0.3167
```

Cross-backend projection over the whole sweep: **85 groups, 10 differ** — all
10 are the five `base` (unthrottled) mode cells against Jolt/Dummy, and every
diff is an F/E row-interleave line (the scheduler class of §2.2), never a
value. On physics-anchored fields only 2 groups differ, both unthrottled IDLE.
**[O]** No per-backend branching is needed for any `AnimationTree` behaviour
measured here, including the §1.4 hazard arms (all 14 arms identical on GP/Jolt,
Dummy modulo `srv=nil`).

---

## 5. Verbatim replays that survived (with receipts)

### 5.1 §1.1 `connect_node` order
`wire` arm: provider-first `connect_node("anim", 0, "output")` →
`ERROR: Condition "p_output_node == SceneStringNames::get_singleton()->output" is true.`
and the actor stays `(0,0,0)` for 8 frames; receiver-first
`connect_node("output", 0, "anim")` → `WIRE_B_END actor=(0.6000,0,0) tp=0.1500`.
Identical on all three backends, 3/3 reps.

### 5.2 §1.2 rate and the player-position error
`min` arm (PHYSICS, `--fixed-fps 60`, 34 frames): **`x = 4·tp` exactly on all 34
frames** (`d = x − 4·tp` is `0.0000`/`−0.0000` everywhere), `MIN_POST … tp=0.5333`.
Note: the scout's §1.2 example row `pf=31 … actor=(1.8667,0,0) … tp=0.4833` is
internally inconsistent (`4×0.4833 = 1.9333 ≠ 1.8667`); at pf=31 my run reads
`x=1.8667 tp=0.4667`. The *law* survives; that row is not quotable.
`pposerr`: `PP_PRE active=true playing=false anim='' tp=0.0833` →
`ERROR: AnimationPlayer has no current animation.` and the raw read returns
`0.0000` — exactly one error line, actor/clock unchanged after.

### 5.3 §1.3 silent vs error classes (probe F, 3 reps × 3 backends)
| arm | measured | error/warning lines |
|---|---|---|
| `missing_anim` (`animation="ghost"`) | `MA_MISSING … actor=(0,0,0) tp=0.0000 playing=false` | **0** |
| `parammiss` | `PM_GET_NOPE <null>`, `PM_READ_BACK nope=<null> amount=<null>`, valid write lands `blend=0.5`, `PM_ACTOR actor=(0.1667,0.1667,0.0000) tp=0.0833` (byte-equal to the scout's) | **0** |
| `dupnode` | `ERROR: Condition "nodes.has(p_name)" is true.` (animation_blend_tree.cpp:1506), list unchanged, original `anim` kept | 1 |
| `dupstate` | `ERROR: Condition "states.has(p_name)" is true.` (animation_node_state_machine.cpp:1304), list unchanged | 1 |
| `badstate` | `travel("zzz")` **always errors 3×** (next pass): `zzz is not found current state.` / `Condition "!p_state_machine->states.has(travel)" is true. Returning: false` / `No such node: 'zzz'`; state and travel path unchanged — **in both `playing=false` (at `Start`) and `playing=true` (at `a`) phases** | 3 per call |

**[O] Falsified:** "`travel("zzz")` to a nonexistent state is silent on a live
playback". The call site is silent *and* returns without effect, but the
`AnimationNodeStateMachine::_process` pass that follows emits the three errors;
a probe that prints and quits in the same frame sees none. This is the same
error class the scout recorded in their root-swap cell (where the names in the
messages were `b`, i.e. a different call), so the two cells should not be split.

**[O] Error/warning census over all 939 runs: 108 `ERROR` lines + 9 `WARNING`
lines, every one attributable to a designed arm** — 18× `zzz is not found
current state.`, 18× `No such node: 'zzz'`, 18× `!…states.has(travel)`,
18× `p_output_node == …output` (`wire`, ×2 batches), 18× `AnimationPlayer has
no current animation.` (`pposerr`, ×2 batches), 9× `states.has(p_name)`,
9× `nodes.has(p_name)`, 9× `couldn't resolve track` (`ghostpath`). No
unexplained engine diagnostic appears anywhere in the sweep.

### 5.4 §2 blend / TimeScale / root-swap (byte-identical, 3 backends × 3 reps)
```
BL_SET w=0.00 read=0.0000 ; BL_ROW w=0.00 tp=0.0500 actor=(0.2000,0.0000,0.0000)
BL_SET w=0.25 read=0.2500 ; BL_ROW w=0.25 tp=0.1167 actor=(0.3500,0.0667,0.0000)
BL_SET w=0.50 read=0.5000 ; BL_ROW w=0.50 tp=0.1833 actor=(0.3667,0.2667,0.0000)
BL_SET w=0.75 read=0.7500 ; BL_ROW w=0.75 tp=0.2000 actor=(0.2500,0.6000,0.0000)
BL_SET w=1.00 read=1.0000 ; BL_ROW w=1.00 tp=0.2667 actor=(0.0000,1.0667,0.0000)
TS_BEFORE tp=0.0833 actor=(0.3333,0,0) scale=1.0 → TS_SET read=2.0 → TS_AFTER tp=0.3500 actor=(1.4000,0,0) dtp=0.2667 expect=0.2667
RS_BEFORE actor=(0.5333,0,0) tp=0.1333 → RS_ASSIGN → RS_FRAME1 actor=(0.0000,0.6000,0) tp=0.1500 → RS_AFTER actor=(0.0000,1.1333,0) tp=0.2833
```
Every `BL_ROW` value equals the scout's §2 `BP` rows digit-for-digit; the 2×
TimeScale delta is exact (`0.2667 = 2×8/60`) on all three backends; the root
swap is a pose cut on a continuing clock (`1.1333 = 4×0.2833`).

### 5.5 §4 stop/start (replay, `--fixed-fps 60`)
```
SS_BEFORE pf=8 node=b actor=(0,0.3333,0) tp=0.0833
SS_STOP_IMMEDIATE node=b playing=true          # read-back is not synchronous
S pf=9  node=b actor=(0,0.0000,0) tp=0.0000    # stop() reset the clock
S pf=10..13 node=b actor y 0.4→0.6 tp 0.1→0.15 # …while the state keeps advancing
SS_STOPPED pf=13 … playing=false
SS_START_IMMEDIATE node=b playing=false ; SS_AFTER pf=18 tp=0.0667  # start() resets again
```
Scout claim survives verbatim, now deterministic (3 reps × 3 backends).

### 5.6 §6 lifecycle (probe E, 6 reps × 3 backends, `--fixed-fps 60`, all rc=0)
```
FT_FREED tree_invalid=true pactive=true ; FT_AFTER actor=(0.4000,0,0)      # frozen, no crash
FP_FREED player_invalid=true ; FP_AFTER actor=(0.9333,0,0) tp=0.2333       # tree keeps animating
FA_FREED actor_invalid=true ; FA_AFTER actor=invalid tp=0.2333             # silent
TN_NULLED root=<Object#null> ; TN_AFTER actor=(0.4000,0,0)                 # freezes at the last pose
AO_OFF actor=(0.4000,0,0) tp=0.1000 active=false ; AO_ON actor=(0.4667,0,0) tp=0.1167
CLS_LOOP made=340 skipped=240 rounds=20 names=29 ; CLS_LOOP_ALIVE ok=true  # 340 instantiate+free cycles
```
**[O]** All six survive, 18 cells × 6 reps × 3 backends, zero crash; the r97
`XRServer` SIGSEGV class does not reproduce for animation objects (20× the
scout's single pass). Note `made=340` because 12 of the 29 candidate names are
abstract/non-instantiable (`AnimationNode`, `AnimationRootNode`, …).

### 5.7 Under load (>=12 hogs, 16 and 32, plus ambient loadavg 84–110)
Every headline `--fixed-fps` cell reproduces its no-hog value byte-for-byte:
`hgut_ctl … ball=(0,0,0)`, `hgut_typedef TYPEDEF_POST sc=(1,1,1) rotY=0.00`,
`hgut_notree … ball=(0,3,0)`, `hgmo_ffps60_phys 0.4667/1.1333/1.8000/0.4500/2`,
`hgmo_ffps60_idle 0.5333/1.2000/1.8667/0.4667/1`, `hgcore_timescale dtp=0.2667`,
`hgsm_enabled_ctl node=a`, `hgsm_autocond node=b`, `hglf_*` all 6 reps rc=0.

**168 hog children; 90 of the 96 hog cells matched their no-hog counterpart's
outcome / physics-anchored projection exactly** (hog-vs-no-hog comparison, all
reps). The 6 exceptions are the two unthrottled-IDLE cells (`hgmo_base_idle`,
`hgmo_base_idle_player_phys` × 3 reps) — the same class the no-hog audit already
flags as rep-unstable (3 distinct value sets each), so a hog-vs-base equality is
undefined there, not a load effect. The only load-sensitive cells remain the
unthrottled `base` IDLE cells (rep-unstable by construction).

---

## 6. Hazards (r99 list, amended)

1. **Untracked-target default write — wider than recorded**: re-applied on
   **every** process pass (not the first), keyed by **(path, track type)**,
   sourced from **all libraries** of the player's mixer, needs an active tree
   and a process pass. A runtime restore is overwritten; a plain
   `AnimationPlayer` does *not* do it. Silent.
2. **Probe-hang mode (harness)**: unchanged, and now with a second face — a
   GDScript error inside a coroutine **truncates the arm and still exits rc=0**
   (hit in `sm/enabled_reapply`: `is_advance_condition_used` is not script
   exposed). Arm a per-arm final marker and assert on it; `audit.py` does.
3. **Silent no-ops**: missing animation name, missing parameter path — both
   silent with 0 error lines (re-verified). But `travel(<unknown>)` is **not**
   silent: it errors 3× on the following pass, which a same-frame read misses.
4. **Default callback mode is IDLE** — the real law is: *PHYSICS is
   rate-invariant; IDLE is deterministic under `--fixed-fps` but rate-dependent
   and unthrottled-unstable*. Pin PHYSICS (or pin the rate).
5. **The SM entry state is `Start`** and a true condition can fire on
   re-activation — **AUTO only** (ENABLED lands on the pending travel target).
6. **`stop()` is not a freeze** (re-verified).
7. **`AnimationPlayer.current_animation_position` is an error source** under an
   active tree (re-verified, exactly one error line).
8. **`connect_node` argument order** (re-verified).
9. **AUTO without a condition skips the state** (`autonocond`: `node=b` on the
   entry frame). A chain of condition-less AUTO transitions collapses to the
   last state in a single pass (`next_path` mode=2).
10. **Threshold samples are sampler-position dependent** (§3): "the first N
    physics frames" and any `x_pfN` constant must be quoted with the sampler's
    node order and the rate mode, or they are not comparable across rigs.

---

## 7. Directives (revised; each backed by a measured cell)

1. Build as the scout says (`anim_player = tree.get_path_to(player)`,
   `process_callback = PHYSICS`, receiver-first wiring; `active` is already
   true). [§5.1]
2. **Pin the rate as well as the mode.** `--fixed-fps 60` + PHYSICS is the only
   combination measured here that is rep-stable *and* rate-invariant; IDLE is
   deterministic under `--fixed-fps` but not portable across rates. [§2.2]
3. Count **one** non-advancing physics frame after the tree's first process;
   count two only if your sampler is placed before the tree node. [§3]
4. Keep the player's library free of every (path, type) you do not want
   reset — and note the reset repeats every pass, so there is no runtime
   repair while the tree is active. [§1]
5. Blend/scale as before (`blend_amount` read-back exact, TimeScale 2× exact on
   all backends). [§5.4]
6. A root swap is a pose cut on a continuing clock; nulling the root freezes at
   the last pose. [§5.4, §5.6]
7. Drive auto-transitions with AUTO **and always set an `advance_condition`** —
   condition-less AUTO fires on entry. Do not expect ENABLED to auto-advance in
   any wiring tried (7 arms), and do not expect `next()` to help (the travel
   path is empty in this rig). [§2.1, §2.3]
8. Cache `parameters/playback`; `stop()` does not freeze; `start()` resets the
   clock. [§5.5]
9. Backend-inert: no per-backend branching needed; Dummy lacks server reads
   only. [§4]
10. Teardown is safe (6 reps × 3 backends), but "player alive" is not a
    liveness signal for the tree. [§5.6]

---

## 8. Remaining unknowns / not tested

1. `xfade_time` crossfade — the scout's `[?]` is still open: my
   `enabled_atend` arm only shows that `SWITCH_MODE_AT_END` does not change the
   ENABLED outcome. `reset=false`, `break_loop_at_end`, a real multi-hop travel
   path are untested. **[?]**
2. What ENABLED *is* for in 4.7.2 — not auto-advance (7 arms), not `next()`
   (2 arms). Candidate: pure `travel()`-reachability bookkeeping. **[?]**
3. `AnimationNodeBlendSpace1D/2D`, `OneShot`, `Transition`, `Add2/3`, `Mix*`,
   `Sync`, `play_mode`/`backward`, `root_motion`, skeleton targets — untouched
   (unchanged from the scout's list). **[?]**
4. The `(path, type)` cache's *type* granularity beyond position/scale/rotation
   (e.g. blend-shape, method tracks) — inferred from three types, not swept. **[?]**
5. No mutation of any tracked file was attempted, so the lane's own shipping
   state was not exercised by this seat. **[—]**

## Reproducing

```bash
cd corpus/live/r99-boundary
python3 driver.py --batch untracked --jobs 6            # §1  (14 arms × 3 backends × 3 reps, --fixed-fps 60)
python3 driver.py --batch untracked_base --jobs 6       # §1  verbatim unthrottled control
python3 driver.py --batch modes --jobs 6                # §2.2/§3 rate matrix (5 cases × 4 rates × 3 backends)
python3 driver.py --batch order --jobs 6                # §3  watcher pre/post
python3 driver.py --batch sm --jobs 6                   # §2.1/§2.3/§2.4 (16 arms)
python3 driver.py --batch core --jobs 6                 # §5.1/§5.2/§5.4/§4
python3 driver.py --batch life --jobs 6                 # §5.6 (6 arms × 6 reps)
python3 driver.py --batch silent --jobs 6               # §5.3
python3 driver.py --batch hog_untracked --jobs 3 --hogs 32   # §5.7
python3 audit.py                                        # rc census, markers, rep identity, cross-backend/rate
```
Single cells: `--batch <b> --only <tag-substr>`; one project per backend is one
line in `driver.py`'s `PROJECTS`.
