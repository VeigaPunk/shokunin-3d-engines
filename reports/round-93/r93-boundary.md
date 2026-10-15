# r93 boundary — the Area3D signal-in-tick law, stressed before the pin

Lane: g3d · engine `4.7.2.stable.arch_linux.ed1daf0bf` · `--headless`, 60 tps.
Backends: GodotPhysics (`proj`), Jolt (`proj_jolt`), Dummy (`proj_dummy`).
Evidence: `corpus/live/r93-boundary/` — `probes/tick.gd` (13 cases),
`probes/frz.gd` (7 arms), `driver.py` (with `--hogs`), `check.py`
(raw positional law checker + scout-audit normalization + mutation battery),
`runs/` (**339 children, 339 rc=0**), `RECEIPTS.md`, `manifest.sha256`
(1031 files).  Scout receipts were read (never written) for §1/§7 only.

Confidence: **[O]** observation (receipt-pinned, rep-stable) · **[I]** inference
· **[?]** unknown / not decided by these cells.

**Seat verdict.** The scout's §0 law survives for the **natural-motion entry**
and **teleport exit** edges on GP+Jolt — now fully receipt-bracketed, including
inside batched iterations — but its universal phrasing is **falsified in three
places**: the handler-time overlap list is updated **incrementally, one body at
a time** (not "the area's own overlap list already updated"); the `queue_free`
exit is emitted in the **frame-end window, outside any physics step**; and a
`monitoring` write made **inside the area's own signal dispatch is refused by
the engine** (`area_3d.cpp:382`).  Two new GP/Jolt splits surfaced (frozen-body
teleport detection; same-tick `monitoring` off→on re-detection).  The
simultaneous-overlap signal order is **not deterministic on Jolt** (7/57 runs
flipped at ambient *and* under load).  The scout audit's normalization cannot
mask a positional inversion, but it *does* mask a one-tick signal shift and is
blind to any systematic violation.

---

## 0. Verdict table per assigned attack

| # | attack | verdict | anchor |
|---|---|---|---|
| 1 | ordering under CPU starvation, when physics batches | **CONFIRMED** — batch-invariant | §2: 186 signal rows in iterations with `dE∈{2,6}`, all `in_step`; 0 `pre_if`/`idle`/`post_e` in natural-motion cells |
| 2a | Dummy backend (IF doesn't fire) | **DEGENERATE** — no IF and no signals at all | §3: `nif=0 nsig=0` on all 13 Dummy cells incl. `enter0` and teleports |
| 2b | frozen body (IF doesn't fire, real backends) | **SPLIT** — GP never detects a moved static body; Jolt does, in-step | §3: `f_telein` GP `nsig=0` vs Jolt `nsig=4`; both `nif=0` |
| 3 | 2 bodies entering the same tick | **UNSTABLE (Jolt)** — order is a per-run coin flip; GP stable but phase-inverted | §4: Jolt 7/57 flipped; GP 33/33 entry b2→b1 / exit b1→b2 |
| 4a | exit via `queue_free` mid-step | **FALSIFIED (universal law)** — emitted in the frame-end window | §5: exit at pf=24 after `E(24)`, before the idle `F` rows; duplicate `body_shape_exited` with `body=<null>` at pf=25 |
| 4b | exit via server `free_rid` | in-step next tick, **no IF row** in that tick | §5: `body_exited pf=25` before `E(25)`, `ifc=0` |
| 4c | exit via teleport (E, IF, or handler-time) | **CONFIRMED** in-step next tick | §5: exit pf=35 (E-write), pf=25 (IF-write), pf=22 (handler-write) |
| 5a | `monitoring=false` write outside a signal dispatch | **CONFIRMED** — synchronous flush | §6: exits inside the write; re-detect next tick |
| 5b | `monitoring=false` write **inside** the area's signal dispatch | **FALSIFIED** — blocked by the engine | §6: `ERROR: Function blocked during in/out signal…`, readback stays `true`, no flush, no re-detect |
| 5c | `monitoring=false;true` in one statement block | **SPLIT** — GP re-detects, Jolt does not | §6: GP entry pf=25, Jolt none through pf=44 |
| 6 | audit.py normalization masking | **PARTIAL** — masks stamp-only shifts + all idle rows; blind to systematic violations; verified harmless on the scout's own reps | §7 |

---

## 1. The core law, fully bracketed — and the scout's unbracketed exit edge

The scout's own receipt cannot show "after IF" for the exit edge: their probe
prints IF rows only for the first 30 IF callbacks (`tick_if <= 30` → pf≤31 in
`enter`), while the exit lands at pf=35.  Verbatim from
`corpus/live/r93-scout/runs/ar_proj_enter.r1.stdout.txt` (their rows, tail):

```
AR p=IF pf=31 seq=139
AR p=E pf=31 seq=140 t=31 by=1.3543 ovA=1/0 ovB=0/0
AR p=E pf=32 seq=144 t=32 by=1.2720 ovA=1/0 ovB=0/0
AR p=E pf=33 seq=149 t=33 by=1.1871 ovA=1/0 ovB=0/0
AR ACT OUT ball=0.0000,5.0000,0.0000 pf=34 seq=154
AR p=E pf=34 seq=154 t=34 by=5.0000 ovA=1/0 ovB=0/0
AR p=A sig=A.body_exited pf=35 seq=159 body=@RigidBody3D@5 ovA=0/0
AR p=A sig=A.body_shape_exited pf=35 seq=160 body=@RigidBody3D@5 bsi=0 lsi=0
AR p=E pf=35 seq=161 t=35 by=4.9099 ovA=0/0 ovB=0/0
```

My probe prints IF and F rows for the whole run, so the same edge is bracketed
(`runs/bd_proj_enter.r1.stdout.txt`; GP and Jolt byte-identical here):

```
IF pf=34 seq=151 body=ball
ACT OUT idx=0 ball=0.0000,5.0000,0.0000 pf=34 seq=152
E pf=34 seq=153 t=34 by=5.0000 ovA=1/0 ovB=0/0 ifc=1 monA=true monB=true
F pf=34 seq=154 ovA=1/0 dE=1 dpf=1
F pf=34 seq=155 ovA=1/0 dE=0 dpf=0
F pf=34 seq=156 ovA=1/0 dE=0 dpf=0
IF pf=35 seq=157 body=ball
SIG sig=A.body_exited pf=35 seq=158 body=ball ovA=0/0 ovn=- mon=true
SIG sig=A.body_shape_exited pf=35 seq=159 body=ball bsi=0 lsi=0 ovA=0/0 ovn=- mon=true
E pf=35 seq=160 t=35 by=4.9099 ovA=0/0 ovB=0/0 ifc=1 monA=true monB=true
```

**[O] So the exit-edge law is confirmed where the scout could only infer it:
`IF(35) < body_exited(pf=35) < E(35)`.**  The entry edge is bracketed in both
probes (`IF(21) seq=92 < body_entered seq=93 < E(21)` on GP; same rows on
Jolt), and `enter0` (already overlapping at scene start) fires in the pf=2 step
after `IF(2)` and before `E(2)`, `E(1)` reads `ovA=0/0` — GP and Jolt
byte-identical.

**[O] One refinement the scout's single-body cells cannot see: the overlap list
is updated incrementally, per body, not for the whole detected set before
dispatch.**  With two bodies entering the same tick (`bd_proj_multi.r1`, GP):

```
SIG sig=A.body_entered pf=21 seq=114 body=b2 ovA=1/0 ovn=b2 mon=true
SIG sig=A.body_shape_entered pf=21 seq=115 body=b2 bsi=0 lsi=0 ovA=1/0 ovn=b2 mon=true
SIG sig=A.body_entered pf=21 seq=116 body=b1 ovA=2/0 ovn=b2,b1 mon=true
SIG sig=A.body_shape_entered pf=21 seq=117 body=b1 bsi=0 lsi=0 ovA=2/0 ovn=b2,b1 mon=true
```

The **first** handler sees only its own body (`1/0`, `ovn=b2`); the second sees
both.  Rep-stable 3/3 on both backends (Jolt's order differs, §4).  The scout's
"with the area's own overlap list already updated in the handler" is true for
the signalling body only; a fixture that pins `ovA==2` inside the first handler
would fail.

---

## 2. Attack 1 — ordering under starvation and iteration batching: CONFIRMED

Batching is measured, not assumed: F rows carry `dE=` (physics ticks since the
previous idle frame).  Three regimes were produced:

| regime | how | `dE` observed | ordering |
|---|---|---|---|
| 16 hogs | `--hogs 16`, 72 children | 1 (no batching) | all `in_step` |
| 64 hogs | `--hogs 64`, 24 children | 1–3 (12 rows at 2, 2 at 3) | all `in_step` |
| `Engine.max_fps=10` | deterministic batching, 24 children | **5–6** | all `in_step` |
| 30 ms idle busy-loop | deterministic batching, 12 children | 1–2 | all `in_step` |

`runs/fp_proj_enter.r1.stdout.txt` shows the batch fingerprint and the edge
inside a 6-tick iteration:

```
F pf=18 seq=41 ovA=0/0 dE=6 dpf=6
IF pf=19 seq=42 body=ball
E pf=19 seq=43 t=19 by=2.1389 ovA=0/0 ovB=0/0 ifc=1 monA=true monB=true
IF pf=20 seq=44 body=ball
E pf=20 seq=45 t=20 by=2.0879 ovA=0/0 ovB=0/0 ifc=1 monA=true monB=true
IF pf=21 seq=46 body=ball
SIG sig=A.body_entered pf=21 seq=47 body=ball ovA=1/0 ovn=ball mon=true
SIG sig=A.body_shape_entered pf=21 seq=48 body=ball bsi=0 lsi=0 ovA=1/0 ovn=ball mon=true
E pf=21 seq=49 t=21 by=2.0343 ovA=1/0 ovB=0/0 ifc=1 monA=true monB=true
...
IF pf=35 seq=79 body=ball
SIG sig=A.body_exited pf=35 seq=80 body=ball ovA=0/0 ovn=- mon=true
SIG sig=A.body_shape_exited pf=35 seq=81 body=ball bsi=0 lsi=0 ovA=0/0 ovn=- mon=true
E pf=35 seq=82 t=35 by=4.9099 ovA=0/0 ovB=0/0 ifc=1 monA=true monB=true
```

**[O] 186 signal rows landed in batched iterations (`dE∈{2,6}`), every one
`in_step`; the position census over all 339 children is `in_step 1398, post_e
12, no_if 84, teardown 138` with zero `pre_if`, zero `idle`, zero `other`.**
The `ifc=` field on E rows is 1 (single ball) or 2 (`multi`) in every batched
tick except the first — batching does not skip a tick's IF callback.  The r92
critic's iteration-batching class does **not** touch the IF→signal→E ordering;
it only moves *which iteration* a tick belongs to.  (What load *does* disturb is
the multi-body pair order — §4.)

---

## 3. Attack 2 — where IF doesn't fire: Dummy is degenerate, frozen bodies split

**Dummy (assigned).**  Every one of the 13 Dummy cells: `nif=0 nsig=0`.  There
is no `_integrate_forces` and **no Area3D signal at all** — including
`enter0` (body spawned overlapping), `tele` (teleported into the area) and
`monoff0` (re-enable while inside).  Verbatim (`bd_proj_dummy_enter.r1`):

```
PRE case=enter engine=Dummy threaded=false maxfps=0 spin=0 a_mon=true a_monable=true balls=1 a_y=[-0.40,1.60] ball_r=0.50
E pf=1 seq=1 t=1 by=n/a ovA=0/0 ovB=0/0 ifc=0 monA=true monB=true
F pf=1 seq=2 ovA=0/0 dE=1 dpf=1
...
DONE case=enter0 engine=Dummy nif=0 nsig=0 ne=34 nf=84 seq=119
DONE case=tele engine=Dummy nif=0 nsig=0 ne=44 nf=108 seq=154
DONE case=monoff0 engine=Dummy nif=0 nsig=0 ne=44 nf=108 seq=153
```

`_physics_process` still runs at 60 tps (`E` rows exist), `body_get_state`
returns no transform (`by=n/a`), and `get_overlapping_bodies()` answers empty
without erroring (monitoring is on).  **[O] The law is undefined on Dummy, not
false: no detection ⇒ no emission point.**  The scout's "on both backends"
must keep meaning GP+Jolt; a Dummy fixture asserting the ordering would fail at
"signal exists".

**Frozen bodies (found while probing the same question on real backends).**  A
`RigidBody3D` with `freeze=true` (FREEZE_MODE_STATIC, server `mode=0`) fires
**no IF ever** (`nif=0`), yet areas still monitor it:

| arm | GP | Jolt |
|---|---|---|
| `f_in0` frozen, spawned inside A | entry at pf=2 (`nsig=4` incl. teardown) | same |
| `f_telein` frozen, parked (100,5,0), teleported in at E(6) | **`nsig=0` — never detected** | entry pf=7, in-step |
| `f_telein2` two teleports | **`nsig=0`** | entry pf=7 |
| `f_nodemove` frozen, node `global_position` write | **`nsig=0`** | entry pf=7 |
| `f_telein_k` FREEZE_MODE_KINEMATIC (`mode=1`) | entry pf=8, **IF fires (`nif=23`)** | same |
| `f_telein_d` dynamic control | entry pf=7, `nif=23` | same |
| `f_teleout` frozen, spawned inside, teleported out at E(6) | exit pf=7 (`nif=0`) | same |

Rep-stable 3/3 per arm and backend.  GP verbatim (`fz_proj_f_telein.r1`, whole
run):

```
PRE arm=f_telein engine=DEFAULT mode=0 frozen=true fz_mode=0 threaded=false
...
ACT IN server teleport #1 (0,0.5,0) mode=0 pf=6 seq=6
E pf=6 seq=7 t=6 by=0.5000 mode=0 ovA=0/0 ifc=0
E pf=7 seq=8 t=7 by=0.5000 mode=0 ovA=0/0 ifc=0
...
DONE arm=f_telein engine=DEFAULT nif=0 ne=24 mode=0
```

Jolt verbatim (same arm):

```
ACT IN server teleport #1 (0,0.5,0) mode=0 pf=6 seq=6
E pf=6 seq=7 t=6 by=0.5000 mode=0 ovA=0/0 ifc=0
SIG sig=A.body_entered pf=7 seq=8 body=ball ovA=1/0 ovn=ball
SIG sig=A.body_shape_entered pf=7 seq=9 body=ball bsi=0 lsi=0 ovA=1/0 ovn=ball
E pf=7 seq=10 t=7 by=0.5000 mode=0 ovA=1/0 ifc=0
```

**[O] Two consequences for the law's scope.**  (i) Where IF does not fire the
signal can still fire — the "after IF" leg is vacuous (there is no IF row in
that tick); the signal is still before `E` (Jolt `f_telein`, `f_teleout`).  (ii)
The GP/Jolt split is real and rep-stable: **on GP a static-mode body moved into
a monitoring area is never detected** (teleport or node write), while a body
that was already inside at spawn is; Jolt detects both.  The scout's §1 matrix
never moved a frozen body.  (`telefr` in the main probe reproduces it in the
same scene: `bd_proj_telefr` `nsig=0` vs `bd_proj_jolt_telefr` entry pf=25 /
exit pf=35, `nif=0`.)  Kinematic-mode freeze does fire IF on both backends.

---

## 4. Attack 3 — two bodies entering the same tick: order is not deterministic

Both balls enter at pf=21 in every run; the **order of the pair callbacks** is
the observable.  Over all `multi` receipts (GP 33, Jolt 57; the Dummy cell has
no signals):

| backend | entry order | exit order | n |
|---|---|---|---|
| GP | b2 → b1 | b1 → b2 | 33/33 |
| Jolt | b1 → b2 | b1 → b2 | 50/57 |
| Jolt | b2 → b1 | b2 → b1 | **7/57** |

The 7 flipped Jolt receipts: `fa_proj_jolt_multi.r2/r8/r12` (ambient, 12-rep
sweep), `fl16_proj_jolt_multi.r3/r5/r10` (16 hogs), `ld16_proj_jolt_multi.r2`
(16 hogs).  Flips are **not** load-correlated: 3/12 ambient, 4/18 at 16 hogs,
0/12 at 64 hogs, 0/3 under `spin`, 0/3 under `max_fps=10`.  Within a run the
entry and exit orders agree; the handler-time list order follows the emission
order (`ovn=b1,b2` vs `ovn=b2,b1`).  Verbatim, the two Jolt shapes
(`fa_proj_jolt_multi.r1` vs `…r2`):

```
SIG sig=A.body_entered pf=21 seq=113 body=b1 ovA=1/0 ovn=b1 mon=true
SIG sig=A.body_entered pf=21 seq=115 body=b2 ovA=2/0 ovn=b1,b2 mon=true
SIG sig=A.body_exited pf=35 seq=195 body=b1 ovA=1/0 ovn=b2 mon=true
SIG sig=A.body_exited pf=35 seq=197 body=b2 ovA=0/0 ovn=- mon=true
```
```
SIG sig=A.body_entered pf=21 seq=113 body=b2 ovA=1/0 ovn=b2 mon=true
SIG sig=A.body_entered pf=21 seq=115 body=b1 ovA=2/0 ovn=b2,b1 mon=true
SIG sig=A.body_exited pf=35 seq=195 body=b2 ovA=1/0 ovn=b1 mon=true
SIG sig=A.body_exited pf=35 seq=197 body=b1 ovA=0/0 ovn=- mon=true
```

**[O] "Signal order for simultaneous overlaps" cannot be pinned as a
deterministic law on Jolt** — the pair order is a per-process property
(consistent inside a run, ~12 % of runs flipped here).  **[O]** GP is
rep-stable but its entry order (b2→b1) is the *inverse* of its exit order
(b1→b2), while Jolt keeps one order for both — so even a "creation-order"
reading fails on GP.  **[?]** mechanism (broadphase pair ordering) not
isolated; only the observable is pinned.

---

## 5. Attack 4 — exits mid-step: teleport vs server free vs node free

All rows below are `bd_proj_*` (Jolt byte-identical unless stated).

**Teleport at E(34)** — in-step next tick, fully bracketed (§1).

**Teleport inside `_integrate_forces`** (`tif`, write at tick 24):

```
IF pf=24 seq=108 body=ball
ACT TIF state.transform=(0.0000,5.0000) written inside _integrate_forces pf=24 seq=109
E pf=24 seq=110 t=24 by=5.0000 ovA=1/0 ovB=0/0 ifc=1 monA=true monB=true
IF pf=25 seq=113 body=ball
SIG sig=A.body_exited pf=25 seq=114 body=ball ovA=0/0 ovn=- mon=true
SIG sig=A.body_shape_exited pf=25 seq=115 body=ball bsi=0 lsi=0 ovA=0/0 ovn=- mon=true
E pf=25 seq=116 t=25 by=4.9359 ovA=0/0 ovB=0/0 ifc=1 monA=true monB=true
```

**[O]** An in-IF write at tick 24 is **not** seen by tick 24's area flush (the
E(24) row still reads `ovA=1/0`); the exit is detected and emitted in tick 25,
in-step.  A fixture that expects a same-tick exit from an IF write would fail.

**Teleport inside the `body_entered` handler** (`tsig`):

```
SIG sig=A.body_entered pf=21 seq=94 body=ball ovA=1/0 ovn=ball mon=true
ACT TSIG teleport-out inside body_entered handler pf=21 seq=95
SIG sig=A.body_shape_entered pf=21 seq=96 body=ball bsi=0 lsi=0 ovA=1/0 ovn=ball mon=true
E pf=21 seq=97 t=21 by=5.0000 ovA=1/0 ovB=0/0 ifc=1 monA=true monB=true
IF pf=22 seq=100 body=ball
SIG sig=A.body_exited pf=22 seq=101 body=ball ovA=0/0 ovn=- mon=true
SIG sig=A.body_shape_exited pf=22 seq=102 body=ball bsi=0 lsi=0 ovA=0/0 ovn=- mon=true
```

**[O]** The entry dispatch **continues** after the handler moved the body out
(`body_shape_entered` still fires); there is **no re-entrant exit** in the same
flush; the E row of the entry tick still reads the stale `ovA=1/0`; the exit is
detected in the next step (pf=22, in-step).

**Server `free_rid` mid-overlap** (`freerid`, at E(24)):

```
ACT FREERID PhysicsServer3D.free_rid(ball) mid-overlap pf=24 seq=109
E pf=24 seq=110 t=24 by=n/a ovA=1/0 ovB=0/0 ifc=1 monA=true monB=true
SIG sig=A.body_exited pf=25 seq=113 body=ball ovA=0/0 ovn=- mon=true
SIG sig=A.body_shape_exited pf=25 seq=114 body=ball bsi=0 lsi=0 ovA=0/0 ovn=- mon=true
E pf=25 seq=115 t=25 by=n/a ovA=0/0 ovB=0/0 ifc=0 monA=true monB=true
```

**[O]** The pair is not destroyed at the free; the exit is detected in tick 25
and emitted before `E(25)` — **but the freed body has no IF callback, so tick
25 has no IF row** (`ifc=0`): the law's "after IF" leg is vacuous for this
path.  The handler sees the updated empty list (`ovA=0/0`).

**Node `queue_free` mid-overlap** (`freeq`, at E(24)):

```
ACT FREEQ queue_free(ball) mid-overlap pf=24 seq=109
E pf=24 seq=110 t=24 by=n/a ovA=1/0 ovB=0/0 ifc=1 monA=true monB=true
SIG sig=A.body_exited pf=24 seq=111 body=ball ovA=1/0 ovn=ball mon=true
SIG sig=A.body_shape_exited pf=24 seq=112 body=ball bsi=0 lsi=0 ovA=1/0 ovn=ball mon=true
F pf=24 seq=113 ovA=0/0 dE=1 dpf=1
F pf=24 seq=114 ovA=0/0 dE=0 dpf=0
SIG sig=A.body_shape_exited pf=25 seq=115 body=<null> bsi=0 lsi=0 ovA=0/0 ovn=- mon=true
E pf=25 seq=116 t=25 by=n/a ovA=0/0 ovB=0/0 ifc=0 monA=true monB=true
```

**[O] FALSIFIED for the universal phrasing**: the exit is emitted **after
`E(24)`, before the idle `F` rows** — in the frame-end delete-flush window,
where no physics step exists at all; the exit handler reads a **stale** list
(`ovA=1/0`, `ovn=ball`); and a **duplicate `body_shape_exited` with
`body=<null>`** fires in tick 25.  Identical on GP and Jolt (same seq numbers),
rep-stable 3/3.  So "the signal is emitted inside the physics step" holds for
detection-driven exits, not for node-destruction-driven ones.  (The scout's
"no deferred/idle-frame path" sentence is falsified as a universal; their own
`p=F` evidence covered only their 7 idle rows at pf≈2–5, before any of their
signals at pf≥21.)

---

## 6. Attack 5 — `monitoring` toggles mid-window

**Write from `_physics_process` (scout's `monoff`) and from IF** — synchronous
flush confirmed.  `monif` (`monitoring=false` inside IF(24), ball overlapping):

```
IF pf=24 seq=108 body=ball
SIG sig=A.body_shape_exited pf=24 seq=109 body=ball bsi=0 lsi=0 ovA=0/0 ovn=- mon=false
SIG sig=A.body_exited pf=24 seq=110 body=ball ovA=0/0 ovn=- mon=false
ACT MONIF monitoring=false inside _integrate_forces readback=false pf=24 seq=111
E pf=24 seq=112 t=24 by=1.8578 ovA=0/0 ovB=0/0 ifc=1 monA=false monB=true
...
ACT MONIF monitoring=true readback=true pf=30 seq=138
SIG sig=A.body_entered pf=31 seq=144 body=ball ovA=1/0 ovn=ball mon=true
```

**[O]** The exits are emitted *inside the property write*, which here sits
inside the IF callback: after the IF row, before the statement's own print and
before `E(24)`; the handler's `get_overlapping_bodies()` errors and answers
empty (`mon=false` rows).  Re-enable at E(30) re-detects in tick 31, in-step.
GP = Jolt, 3/3.  Positionally this is `in_step`; mechanically it is a property
flush, not detection — fixtures should not read it as "the step detected the
exit".

**Write from inside the area's own signal dispatch** (`monsig`) —
**FALSIFIED**:

```
SIG sig=A.body_entered pf=21 seq=94 body=ball ovA=1/0 ovn=ball mon=true
SIG sig=A.body_shape_entered pf=21 seq=95 body=ball bsi=0 lsi=0 ovA=1/0 ovn=ball mon=true
ERROR: Function blocked during in/out signal. Use set_deferred("monitoring", true/false).
   at: set_monitoring (scene/3d/physics/area_3d.cpp:382)
ACT MONSIG monitoring=false inside body_shape_entered handler readback=true pf=21 seq=96
E pf=21 seq=97 t=21 by=2.0343 ovA=1/0 ovB=0/0 ifc=1 monA=true monB=true
...
ACT MONSIG monitoring=true readback=true pf=30 seq=136
DONE case=monsig engine=DEFAULT nif=43 nsig=2 ne=44 nf=108 seq=199
```

**[O]** The engine refuses the write (`area_3d.cpp:382`), the property readback
stays `true`, **no flush signals fire**, and the later `monitoring=true` at
E(30) is a no-op because the state never changed — the ball stays monitored
(no re-detect through the end of the run; the only exit signals are the probe's
own teardown `queue_free` at pf=44, which are `teardown` in the census).  GP =
Jolt, 3/3.  The scout's "`monitoring=false` flushes synchronously inside the
property write" holds only outside the in/out signal dispatch; inside it, the
write is dropped with an error line and `set_deferred` is the engine's own
prescription.

**`monitoring=false;true` in one statement block** (`moncycle`, E(24)) —
**new split**:

```
GP:   SIG …shape_exited pf=24 seq=109 (mon=false)
      SIG …body_exited  pf=24 seq=110 (mon=false)
      ACT MONCYCLE monitoring=false;true readback=true pf=24 seq=111
      E pf=24 … ovA=0/0
      SIG …body_entered pf=25 seq=116 body=ball ovA=1/0 ovn=ball mon=true   # re-detected
Jolt: … identical exit pair inside E(24) …
      E pf=25 … ovA=0/0 ; E pf=26 … ovA=0/0 ; … E pf=43 ovA=0/0            # never re-detected
```

**[O]** After a same-tick off→on cycle the still-overlapping ball is
re-detected on GP (pf=25) but **not within the remaining 20 ticks on Jolt**
(rep-stable 3/3 each).  `monoff0` (off from the start, on at E(30)) re-detects
at pf=31 on **both** backends — so the Jolt failure is specific to the
same-tick cycle, not to re-enabling over a live overlap.  The scout's
re-enable law is therefore backend- and timing-dependent.

---

## 7. Attack 6 — what the scout audit normalization can and cannot mask

The scout's `audit.py` compares reps after dropping `p=F` rows and blanking
`pf=`/`seq=`.  My `check.py` reimplements it and adds a raw positional checker
(line order + pf/seq, no normalization).  Findings:

1. **[O] On the scout's own receipts the headline is verified independently.**
   A structured comparison (group rows by `(kind, pf)`, compare fields, treat
   `seq` as a stamp) of all 136 scout rep pairs gives 125 identical, 7
   F-row-only, 4 seq-only (pair level; the scout reports the same classes at
   cell level — 61 byte-identical / 2 stamp-only / 5 F-row-only); every
   non-identical pair has `field={}` and no missing/extra non-F row.  "0 differ
   in physics observables" survives a comparison that does not depend on their
   hashing.
2. **[O] The filter is dialect-bound.**  Its idle filter is the literal
   substring `p=F `; my receipts spell idle rows `F …`.  On
   `bd_proj_enter.r1` the literal filter drops **0** idle rows (1 blank line)
   while the dialect-aware filter drops 108.  A ported audit silently stops
   dropping idle rows — exactly the class of difference it exists to classify.
3. **[O] Stamp blanking masks a one-tick signal shift.**  Mutation battery on
   the real `bd_proj_enter.r1` (clearly labelled synthetic; copies in memory
   only):

   ```
   filter dialect: literal(p=F)-dropped=1 dialect(F)-dropped=109 of 205 lines
   stamp_shift(exit)    scout-audit-vs-original=normdiff(pf/seq-only)  checker=pre_if
   move_to_idle(exit)   scout-audit-vs-original=diff                   checker=idle
   drop_one_F           scout-audit-vs-original=physdiff(F-row-only)   checker=in_step
   systematic_idle: all 3 reps mutated identically -> scout-audit rep pairs=['raw-identical', 'raw-identical']; checker exit cls=idle
   ```

   Shifting only the exit row's `pf` 35→36 (nothing else) lands in the audit's
   "differ only in `pf`/`seq` stamps" class — i.e. folded into "no physics
   difference" — while the positional checker sees the row now sits before the
   tick's IF (`pre_if`).  The `pf` stamp is the only evidence of *which tick*
   emitted a signal; blanking it removes that evidence.
4. **[O] Rep-identity is blind to systematic violations.**  Applying the
   falsifier shape (exit moved to the idle position) to *all three* reps
   identically leaves the triple byte-identical to the audit (`raw-identical`
   pairs) while the checker flags `idle`.  A uniformly wrong engine (or a
   uniformly wrong probe) passes the audit by construction; the audit is a
   stability check, not a law check.
5. **[O] What the audit cannot mask:** a positional inversion in a *raw*
   comparison (line order is hashed) and any change that alters a non-idle row
   (E/SIG fields, row counts).  The scout's exit-edge "after IF" leg, however,
   is not audit-maskable *or* audit-verifiable: 48 of their 360 signal rows
   have no same-tick IF row (`no_if`), because their IF print window ends at
   pf=31 while the exit edges land at pf=34/35 (§1).  My full-window probe
   closes that gap.

---

## 8. Falsification list (armable)

| # | command | expected signature | falsified if |
|---|---|---|---|
| 8.1 | `python3 driver.py --batch core --reps 3 --jobs 8` | 117 rc=0; `bd_proj_enter.r1`: `IF pf=35 seq=157` < `SIG …body_exited pf=35 seq=158` < `E pf=35 seq=160` | no IF row at pf=35, or the exit after `E(35)` |
| 8.2 | `python3 driver.py --batch fps --reps 3 --jobs 8` then `python3 check.py --cells fp_` | `dE=6` F rows; 0 non-`in_step` rows | any batched tick with a non-`in_step` signal |
| 8.3 | `--batch core --proj proj_dummy` | `DONE … nif=0 nsig=0` on all 13 cells | any Dummy signal or IF row |
| 8.4 | `--batch frz --reps 3 --jobs 7` | `fz_proj_f_telein` `nsig=0`, `fz_proj_jolt_f_telein` entry pf=7 | GP detecting a moved frozen body (or Jolt failing to) |
| 8.5 | `--batch flipamb --reps 12 --jobs 6` | Jolt flips in ~1/4 runs (`fa_proj_jolt_multi.r2/r8/r12` here); GP never | a single deterministic order pinned for Jolt |
| 8.6 | `--only bd_proj_freeq` | exit rows `pf=24` after `E pf=24 seq=110` and before the `F pf=24` rows; `body=<null>` shape exit at pf=25 | the free-path exit bracketed by IF/E of a step |
| 8.7 | `--only bd_proj_monsig` | `ERROR: Function blocked during in/out signal…` at `area_3d.cpp:382`; readback `true`; no exit rows | a flush from inside the dispatch |
| 8.8 | `--only bd_proj_moncycle` vs `bd_proj_jolt_moncycle` | GP `body_entered pf=25`; Jolt none | the two backends agreeing |
| 8.9 | `python3 check.py --mut --cells bd_proj_enter` | §7 verbatim battery | `stamp_shift` classified as a positional difference, or `systematic_idle` flagged by the audit |
| 8.10 | `python3 check.py --scout ../r93-scout/runs` | 48 `no_if` rows; 125 identical / 7 F-only / 4 seq-only pairs | the scout's exit edges being IF-bracketed in their receipts |

---

## 9. Reproducing

```
cd corpus/live/r93-boundary
python3 driver.py --batch core    --reps 3 --jobs 8      # 13 cases x 3 backends x 3
python3 driver.py --batch frz     --reps 3 --jobs 7      # 7 arms x 2 backends x 3
python3 driver.py --batch load16  --reps 6 --jobs 4 --hogs 16
python3 driver.py --batch load64  --reps 6 --jobs 2 --hogs 64
python3 driver.py --batch fps     --reps 3 --jobs 8      # Engine.max_fps=10
python3 driver.py --batch spin    --reps 3 --jobs 6      # 30 ms idle busy loop
python3 driver.py --batch flipamb --reps 12 --jobs 6
python3 driver.py --batch flipl16 --reps 12 --jobs 4 --hogs 16
python3 driver.py --batch flipl64 --reps 12 --jobs 2 --hogs 64
python3 check.py --scout ../r93-scout/runs > runs/check_summary.txt
python3 check.py --mut --cells bd_proj_enter >> runs/check_summary.txt
```

Single cells: `--only bd_proj_freeq`, `bd_proj_jolt_moncycle`, `fz_proj_f_telein`, …
(the `--only` filter matches the tag substring; `--proj` filters a backend).

## Receipts pointer

`corpus/live/r93-boundary/`: `probes/tick.gd`, `probes/frz.gd`, `driver.py`,
`check.py`, `RECEIPTS.md`, `runs/` (339 children + `.exit`/`.ms` sidecars +
`check_summary.txt`), `manifest.sha256` (1031 files).

Provenance: this lane wrote only `corpus/live/r93-boundary/**` and this report.
`corpus/live/r93-scout/runs/**` was read (never written) for §7.1/§7.5 and the
§1 comparison; `corpus/fixtures/**` and `reports/round-88..92/**` were not
touched.
