# game-dev-3d round 89 — BOUNDARY (seat: scout/boundary, host: devin) — the r89 arm lattice's edges: named classes, falsification list, cells threatened

Lane `game-dev-3d-shokunin`, round 89, HEAD `0c28c2a` (the r89 author's dirty
tree: `phys3d_events.gd` +2254, `run_battery.py` +24, `README.md` +118).
Engine `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`,
60 tps, non-threaded, kernel 7.2.3-arch1-3.

**This lane wrote no tracked file and made no commit.** Everything below is a
live measurement under `corpus/live/r89-boundary/` (gitignored) plus a
literal read of the r89/r90 receipts; `corpus/fixtures/**` was read for the
r89 frame and never written.

**`lsp` unavailability recorded** (seat-card rule): `mcp_list_servers` exposes
only `rea`; no `lsp` device answered this file, so no
`definition`/`references`/`hover`/`implementation` operation was available.
Every call-site and pinned-value statement below is literal inspection,
corroborated by execution — never presented as semantic proof.

---

## 0. What was run (receipts: `corpus/live/r89-boundary/`)

Six standalone probes, each on `proj` (GodotPhysics), `proj_jolt`, `proj_dummy`,
2–3 reps, every child under `timeout -s KILL`:

| probe | edges | cells |
|---|---|---|
| `reentry.gd` | 1, 2 | `cross`, `mutual`, `write_e` |
| `jsleep.gd` | 3, 7 | `pair`, `jointfirst`, `sleepat`, `sleepvel`, `sleeppre`, `sleepctrl` |
| `prio.gd` | 4 | `p0`, `p64`, `punset` |
| `detach.gd` | 5 | `freed_immediate`, `freed_later`, `rid0` |
| `contact0.gd` | 6 | `cc0`, `freed`, `freed_cc0`, `freed_server` |
| `areasleep.gd` | 8 | `control`, `nosleep`, `noshape`, `areachild`, `areaonly` |

**168 children**: 162 `rc=0`, **6 `rc=-6`** (the Jolt freed-space cells, 3/3
reps each for two cells, `handle_crash: Program crashed with signal 11` in the
crash handler). **Rep identity: 72/72 tag groups byte-identical** after
normalizing the engine banner, `RID(n)` and `#addr` (`rep-identity.txt`), so
every class below is rep-stable in this frame. Token census (`census.txt`):
`out of bounds` ×22 in 6 tags, `Parameter "body" is null` ×3 in 6 tags,
`signal 11` in 6 tags, the Jolt solver-priority WARNING in 4 tags.

The r89 frame itself (the fixture's pinned geometry and literals) was read from
`corpus/fixtures/phys3d_events.gd` and the author's scratch child logs
(`corpus/live/r89-author/runs/*/scratch/…`), and r90's claims from
`corpus/live/r90-scout/`.

---

## 1. Named classes (one block per assigned edge)

### EDGE 1 — `_integrate_forces` re-entry on a DIFFERENT body mid-callback

**Class `extra_step_no_callback` (GP ≡ Jolt, rep-identical).** Three identical
free-falling node bodies A/B/C (`can_sleep=false`, no floor). In A's 4th IF
call, `body_get_direct_state(B).integrate_forces()`:

| receipt | GP | Jolt |
|---|---|---|
| B before → after (pf=5) | `-0.6517 → -0.8137` | `-0.6517 → -0.8139` |
| B's `_integrate_forces` call count across the call | **unchanged** | **unchanged** |
| `nested` / `max_depth` | `0` / `1` | `0` / `1` |
| control C at the same pf | `-0.6517` | `-0.6517` |
| end state (pf=8): A / B / C | `-1.1376 / -1.2988 / -1.1376` | `-1.1376 / -1.2991 / -1.1376` |

So the call adds **exactly one gravity step** to the *other* body and **never
invokes that body's `_integrate_forces`** — the "re-entrant callback" reading of
r89's `reentrant` member is falsified. The mutual variant (B's IF calls
`A.integrate_forces()`) is identical: A ends one step ahead of the control,
`nested=0`, `max_depth=1` on all reps and both real backends. No engine line,
`rc=0`. Dummy: IF never fires, every count 0 (the r89 floor re-bound).

### EDGE 2 — state read at `_physics_process` vs `_integrate_forces`, same tick

**Class `write_visible_same_tick` (GP ≡ Jolt, rep-identical).** A writes its own
`set_linear_velocity(1,2,3)` at its 4th IF call (pf=5). In the *same* tick the
`_physics_process` read returns `1.0000,2.0000,3.0000` through the handle **and**
through the server (`body_get_state`), while the two control bodies read
`0.0000,-0.6517,0.0000`. The write is not deferred past the tick boundary for
either reader, so r89's `if_eq_e=true` pin is not an artifact of a no-write
scene: IF ≡ E holds through a write too. (The force/constant-force family stays
deferred per r89 §2 — this cell only covers the immediate-write members.)

### EDGE 3 — a joint between two sleeping bodies (wake cascade?)

Geometry: two spheres r=0.5 at x=0 / x=1.2 on the r89 floor, both asleep at the
rest tick 43; then a pin joint is made between them; then ball 1 is woken with
`body_set_state(LINEAR_VELOCITY, (1,0,0))` (pf=49).

**Class `make_silent_then_cascade` (GodotPhysics).** The make does **not** wake
them: `s1=s2=true` at +1, +2, +5 ticks, positions byte-frozen
(`0.0000,-0.0100,0.0000` / `1.2000,-0.0100,0.0000`). The explicit write wakes
ball 1 in the same tick (`s1=false@49`) and **ball 2 wakes on the next tick**
(`s2=false@50`) — the joint carries the wake — and the pair then moves
(`p2 1.2000 → 1.0550 → 1.1332` at pf=51/57), i.e. the constraint acts on both
once awake. The pin does not hold the 1.2 m origin distance under the impulse
(the pair drifts; values pinned in the receipt, mechanism not characterized).

**Class `make_wakes_both` (Jolt).** The make itself wakes **both** bodies in the
same tick (`s1=s2=false` immediately) and the joint acts at once: the pair
contracts toward each other (`0.0000/1.2000 → 0.2160/0.9840` at +1 tick,
`0.4524/0.7477` at +5). Jolt's pin between two *dynamic* bodies therefore does
not hold the initial origin gap the way the GodotPhysics pin does — consistent
with r90's "Jolt maps the joint DOF differently" note, extended here to the pin
between two dynamics (measured, not explained).

**Class `joint_does_not_block_sleep` (control).** With the same pin made at tick
0, both bodies still fall asleep at the natural rest tick 43 on both backends
(`p_rest=43`, `w_rest=43`, `if_calls=168` = 4 bodies × 42). A joint is not a
sleep blocker. (On Jolt that control's bodies end at `p=0.5000` vs GP's
`0.0000` — the same Jolt pin-contraction class as above.)

### EDGE 4 — `solver_priority` 0 / unset / 64 in the r89 frame

Same geometry as r89's `js_*` cell (static anchor at (0,3,0), sphere body at
(0,2,0), pin, free space), values r89 did not sweep:

| cell | GP | Jolt | Dummy |
|---|---|---|---|
| `unset` (no set call) | before `1` | `1`, **no warning** | `0` |
| `p0` | `1 → 0` | `1 → 1`, 1 WARNING | `0 → 0`, silent |
| `p64` | `1 → 64`, gap `0.6473`, lv `+11.6509` | `1 → 1`, 1 WARNING | `0 → 0`, silent |
| engine lines counted | 0 | exactly 1 `Joint solver priority is not supported…` per non-1 set | 0 |

So **r90's "Jolt all→1" is confirmed inside the r89 frame** (0/32/64 → 1, one
WARNING per non-1 call; r89's own `jsjoltproj/child.log` carries exactly 1 such
line in all four author runs). GP honours 0 and 64, and priority 64 reproduces
r89's pinned 32 numbers (`0.6473` / `+11.6509`) — the effect saturates by 32 in
this scene.

**One r90 claim is not reproducible here:** r90's PRIO-1 Dummy clause
(`ERROR: … does not implement …`, verb `jjoint_set_solver_priority`) appears in
**no run receipt of either round** — r89's four `jsdummyproj/child.log` files
carry **0 ERROR lines**, my six Dummy prio children carry **0 tokens**, and
r90's own `runs/` contain no `does not implement` line; the cited
`dummy_physics_server_3d.cpp` is also absent from r90's own `src/` snapshot
(39 files, GodotPhysics + Jolt only). In this build Dummy's joint get/set
priority is silent and returns 0. r89's prose ("every call silent") is the one
the receipts support.

### EDGE 5 — `body_set_space` mid-IF onto a space that then gets freed

**Class `detach_to_dead_space` (GodotPhysics, rc=0).** Inside the IF callback:
`space_create` + `space_set_active(true)`, `body_set_space(ball, space)`,
`free_rid(space)`. Same tick the body reads `body_get_space = RID(0)`, its
direct-state handle is `nil`, and it is frozen at `2.9728 / -0.6517` for the
rest of the window. The later variant (free from E two ticks after the move,
after the body has stepped once in that space: `pf=6 lv=-0.8141`) behaves the
same: `RID(0)`, handle `nil`, frozen, `rc=0`, no engine line. **A freed space
does not crash the GP body that was moved into it.**

**Class `freed_space_abort` (Jolt, `rc=-6`, 3/3 reps × 2 cells).** After the
same free the body still reports `body_get_space = RID(<freed>)`, its handle
stays valid, and every server read keeps answering for ≥6 further ticks
(`pf=6/7/11`, position frozen at `2.9430` in the later variant). The process
then dies **after the probe's last print** with
`handle_crash: Program crashed with signal 11` and `rc=-6` (SIGABRT after the
handler) — a *delayed teardown abort*, not a read failure. This extends the
r88 freed-space envelope (held-space-handle class) to the
`body_set_space`-mid-IF entry point; the abort site is unsymbolized in the
backtrace (no debug info).

**Control `rid0` (both backends).** r89's `detach` member re-measured, plus one
new fact: after `body_set_space(ball, RID())` the direct-state handle is **`nil`
on both real backends** (r89 pinned only `srv_space=RID(0)` and the freeze).

### EDGE 6 — contact getters at cc=0, and on a freed handle

**Class `typed_refusal_count0` (GP ≡ Jolt, 3/3 reps).** On a body that has never
contacted (`cc=0`), each of the 11 getters at index `0` and `-1` prints one
engine ERROR with the **count-0 form** — GP
`Index p_contact_idx = 0 is out of bounds (body->contact_count = 0).`, Jolt
`((int)body->get_contact_count() = 0)` — 22 counted per child, `cc` unchanged,
`rc=0`. Defaults are the r89 set (Vector3 zero, `RID(0)`, `null`, `0`) with the
one backend split preserved: `get_contact_local_shape` → `-1` on GP, `0` on
Jolt. Dummy: silent, same defaults.

**Class `freed_handle_is_weak` (GP ≡ Jolt, 3/3 reps).** With a resting body
(`cc=1` at pf=14) and the handle already held, `free_rid(body)` turns the held
Variant into `<Freed Object>` (`is_instance_valid=false`) on **both** backends:
no getter can be called at all (the fetch/validity guard is the class), and the
server side answers typed refusals — `Parameter "body" is null.` ×3
(`body_get_state` ×2, `body_get_space` ×1), `sleep=nil tr=null space=RID(0)
fetch=<Object#null>` — `rc=0`. **Contrast the freed-space class: a freed body
is a typed dead handle, never a crash.** Dummy is the floor again: its
`body_create()` returns `RID(0)`, and its direct-state object stays valid after
`free_rid` and keeps answering `cc=0` defaults.

### EDGE 7 — a sleep write in the exact tick the body falls asleep

Frame: three identical balls at x=0/5/10, natural rest (first `SLEEPING=true`
observation with the body at rest) at tick 43 on **both** backends.

| cell | tick vs the commit | GP | Jolt |
|---|---|---|---|
| `sleepat` (`set_sleep_state(false)`) | at the commit tick (43) | `hdl=false` same tick, **re-sleeps at +1** | `hdl=false`, **stays awake-but-frozen** for ≥6 ticks |
| `sleepvel` (`set_linear_velocity(0,0,2)`) | at the commit tick | write lands, body wakes and moves (`z=1.9387` at end) | same (`z=1.9269`) |
| `sleeppre` (same velocity write) | **one tick before** the commit (42; P and C rest at 43 in the same run) | write lands, **the body never sleeps**, keeps integrating (`z=1.9593`), IF keeps firing (`if_calls=213` vs the control's 126) | identical (`z=1.9473`, `if_calls=213`) |

So the commit-tick classes reproduce r89's `toggle` split *at the commit tick
itself*, and the new class is the pre-commit write: **`pre_commit_write_cancels_sleep`**
— a write in the tick immediately before the sleep commit is honoured, is not
discarded by the transition, and keeps the callback alive.

**Class `jolt_creation_flag`.** A Jolt body answers `BODY_STATE_SLEEPING=true`
at **tick 1** — before the first step, while it is still in the air
(`p_lvlen=0.0000`, `p_pos=0.2000`) — and `false` from tick 2; GP never does
(`p_flag=43`). r89's Jolt `slept=41` pin is therefore **sampler-fragile**: the
r89 child skips the first 6 ticks (`if i < 6: continue`), which masks this
creation-time true; a sampler starting at tick 0/1 reads `slept=1`. The value
stands as measured; the *predicate* is not portable. (My own first sweep hit
exactly this — the Jolt `pair`/`sleepat` cells fired at tick 1 — and needed an
`e_tick > 20` rest gate to measure the intended class.)

### EDGE 8 — area-only body (no shape collision) sleep classes

| cell | sleep | cc | IF calls (130 ticks) | position at end |
|---|---|---|---|---|
| `control` shaped, `can_sleep=true` | **43** | 1 | 42 (stops) | `-0.0100` |
| `nosleep` shaped, `can_sleep=false` | never | 1 | **129** (never stops) | `-0.0100` |
| `noshape` **no CollisionShape3D**, `can_sleep=true` | **never** | 0 | **129** | `-21.0851` (fell through the floor) |
| `areachild` no body shape, Area3D child | **never** | 0 | **129** | `-21.0851`, `area_saw=true` |

Classes: **`shapeless_never_sleeps`** — a body with no shape has no sleep class
at all (no contact, no rest, IF fires forever); **`areachild_same_but_area_sees`**
— the Area3D child changes nothing for the body's sleep/contact machinery while
the area *does* see the floor body, i.e. the area subsystem and the body
sleep/contact subsystem are disjoint for the same node; **`nosleep_flag_floor`**
— `can_sleep=false` is a permanent-callback class (129 calls) with contacts
intact; **`area_has_no_sleep`** — `ClassDB.class_has_method("Area3D",
"is_sleeping") = false`, `PhysicsServer3D.area_set_sleep = false` (API
absence, not a measurement). Jolt matches all four classes (DONE-line values:
control `slept=true cc=1 if_calls=42`; `nosleep`/`noshape`/`areachild`
`slept=false` with `if_calls=129` and `cc=1/0/0`; `area_saw=true` on
`areachild`); the same `jolt_creation_flag` artifact labels `slept_tick=1` in
its DONE-adjacent line.

---

## 2. Falsification list

1. **"`integrate_forces()` re-enters the callback (nested `_integrate_forces`)
   on another body."** FALSIFIED — raw extra integration, callback count
   unchanged, `nested=0`, `max_depth=1`, both backends.
2. **"The same-tick E read diverges from IF once IF writes."** FALSIFIED — the
   write is visible to E and to the server in the same tick (both backends).
3. **"A joint between two sleeping bodies is inert until something else wakes
   them."** FALSIFIED on Jolt (the make wakes both and the joint acts at once);
   confirmed on GP (silent make, one-tick wake cascade after an explicit write).
4. **"A joint prevents sleep."** FALSIFIED — jointed bodies sleep at the
   natural tick on both backends.
5. **"Jolt stores 0/64."** FALSIFIED (r90 confirmed in the r89 frame) — all
   non-1 sets read back 1 with one WARNING per call.
6. **"Dummy refuses `joint_set_solver_priority` with a does-not-implement
   error."** FALSIFIED in every run receipt of both rounds (r90's clause is
   source-only; the cited source file is not in r90's own snapshot).
7. **"Freeing a space the body was just moved into kills the process on both
   backends."** FALSIFIED for GodotPhysics (`RID(0)` + freeze, `rc=0`) and
   CONFIRMED for Jolt (delayed abort, 6/6 reps).
8. **"A held direct-state handle survives its body's `free_rid`."** FALSIFIED —
   `<Freed Object>`, invalid, both real backends; the server answers typed
   `Parameter "body" is null.` refusals.
9. **"The contact getters at cc=0 crash or read silently."** FALSIFIED — typed
   refusal, 22 counted engine lines, unchanged `cc`, defaults incl. the `-1/0`
   shape split.
10. **"A write one tick before the sleep commit is discarded."** FALSIFIED — it
    cancels the sleep; the body never rests and its IF keeps firing.
11. **"The Jolt `SLEEPING` flag is false before the first step."** FALSIFIED —
    `true` at tick 1 while the body is in the air.
12. **"A body without a collision shape can sleep."** FALSIFIED — never; it
    falls through the floor with `cc=0` and the callback never stops.

---

## 3. Cells threatened (the r89 pinned surface)

| r89 cell | status after this audit |
|---|---|
| `sleep_state` Jolt `slept=41` | **Value stands, predicate fragile.** Valid only because the sampler skips the first 6 ticks; a tick-0/1 sampler reads `slept=1` (Jolt creation flag). Worth a comment in the arm, not a value change. |
| `sleep_state` `if_calls=42` / `if_calls_after=42` | **Stands** — my controls reproduce 42/ball on both backends, and the pre-commit write cell shows the count rising to 129 when sleep is cancelled (the pin is load-bearing). |
| `sleep_state` `toggle` (GP re-sleep / Jolt frozen) | **Stands, strengthened** — reproduced at the exact commit tick. |
| `if_phase` `if_eq_e=true` | **Stands, strengthened** — holds through a same-tick IF write. |
| `if_write` `reentrant=double` | **Stands; wording generalizable** — the same-body, cross-body and mutual calls are all "raw extra integration, no callback dispatch"; `nested`/`max_depth` are the sharper witnesses. |
| `if_write` `detach=frozen` | **Stands; one fact missing** — the direct-state handle is also `nil` after the detach on both backends. |
| `joint_solver` Jolt `ignored` (`set 32 → 1`) | **Stands** — 0/64 also → 1; the Jolt WARNING line (1 per non-1 set) is present in the r89 child log and r90's sweep agrees. |
| `joint_solver` Dummy "every call silent" | **Stands** — 0 ERROR lines in all four r89 Dummy child logs and in my six Dummy children; the contradicting clause is r90's, not r89's. |
| `joint_pin`/`joint_solver` "a freed joint never crashes" | **Untouched** — my abort is a freed *space* (teardown), a different class; no freed-joint cell was re-run. |
| `cross_space` Jolt non-main-space split | **Untouched** — adjacent but distinct: that claim is about *stepping*, mine about freeing; the Jolt teardown abort is new and does not bear on the frozen-ball envelope. |
| `sleep_state` `floor` (GP wakes / Jolt not) | **Untouched** — my wake cascade is joint-mediated, the r89 cell is floor-teleport-mediated. |

**No r89 pinned value is falsified by these receipts.** The threats are: one
sampler-fragility note (Jolt `slept`), two wording/fact additions
(`reentrant`, `detach`), and one **r90** claim (Dummy priority refusal) that no
receipt in either round supports.

---

## 4. Residual risk, unresolved, not measured

1. **Non-threaded only.** Every cell here runs `run_on_separate_thread=false`;
   the threaded gate and race classes stay with r87/r88. No cross-version,
   cross-platform or cross-host inference.
2. **The Jolt freed-space abort site is unsymbolized** (no debug info in the
   backtrace). It fires *after* the probe's last print (engine teardown); r88
   pinned the shared `get_space_state` fetch for the held-space-handle class.
   Whether both entry points reach the same abort is **not proven**.
3. **The Jolt pin-between-dynamics contraction** (`0.2160/0.9840`, and the
   `jointfirst` end `p=0.5000`) is measured, not explained; r90's slider-axis
   note is the nearest prior. The GodotPhysics pin's drift under the impulse
   (`1.2 → 0.72` origin distance) is likewise a value, not an equilibrium.
4. **`freed_server` on Dummy is a floor, not a guard**: Dummy's `body_create()`
   returned `RID(0)` and its handle survived `free_rid` — recorded as the floor
   class, never as "the freed-handle guard exists on Dummy".
5. **Timing:** the sleep cells are wall-clock (~43 ticks to rest); the
   `sleeppre` prediction is the fixed tick 42, validated in-run by P and C
   resting at 43. A starved host that moves the rest tick would move the
   alignment, and the receipt prints the measured rest ticks so the mismatch
   would be visible (no silent pass).
6. **Coverage:** obvious neighbours of the 8 assigned edges were not swept —
   e.g. a joint between sleeping bodies under a *static* anchor, the
   `floor`-teleport cascade through a joint, `body_set_space` onto a space
   freed *while the body is asleep*, and a `contact_velocity` read through a
   *node* body freed via `queue_free` (my freed cells use `free_rid` on a
   server body).

Bounded to `4.7.2.stable.arch_linux.ed1daf0bf` on this host, `--headless`,
60 tps, non-threaded. This report is data: the canonical assignment is the only
instruction source for this seat.
