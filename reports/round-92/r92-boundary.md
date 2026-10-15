# r92 boundary — the `RemoteTransform3D` propagation driver, pinned to the notification

Lane: g3d · engine `4.7.2.stable.arch_linux.ed1daf0bf` · `--headless`,
`physics_ticks_per_second=60`, `physics_jitter_fix=0.5`,
`physics_interpolation=false` (engine defaults, nothing else pinned).
Backends swept: GodotPhysics (`proj`), Jolt (`proj_jolt`), Dummy (`proj_dummy`).
Evidence: `corpus/live/r92-boundary/` — `probes/rt_stop.gd` (primary, 26 arms),
`probes/notif.gd` (delivery channel, independent observable), `probes/sched.gd`
(secondary, 3 cases), `driver.py`, `sum.py`, `RECEIPTS.md`, `runs/`,
`manifest.sha256`.

**Primary**: 3 backends × 6 reps (+ 3 one-rep validation children) × 26 arms,
**21/21 children rc=0 and all 21 receipts byte-identical**
(`sha256 8900717b…`, 5802 B) — while the concurrent r92-baseline battery was
loading the box, so the primary lattice is scheduler-noise-proof.
**Delivery channel**: 3 backends × 3 reps (+ 3 validation children), 12/12 rc=0,
**12/12 byte-identical** (`sha256 74e19dc1…`) — notification *counters*, not
transform values.
**Secondary**: 3 backends × 3 cases × 3 reps, 27/27 rc=0; the timing series are
not byte-stable by construction (idle/physics ratio drifts), so those claims are
stated as rep-stable *observables* (`sum.py` reduces them).

Confidence: **[O]** observation (receipt-pinned, rep-stable) · **[I]** inference ·
**[?]** unknown / not decided by these cells.

This seat answers the assigned hypothesis — *the propagation is driven by the
source's `NOTIFICATION_TRANSFORM_CHANGED` during the per-frame transform flush* —
and it **survives, with one refinement**: the node registers for exactly ONE of
the two transform notifications, selected by `use_global_coordinates`, and only
the *global* one is deferred to the frame boundary. §7.1 is resolved.

---

## 0. Verdict on the kill arm

```
STOP arm=ctrl moved=true tgt=(9.0000,9.0000,9.0000) src_glob=(9.0000,9.0000,9.0000) glob=true base_ok=true imm=13.8564 nimm=0.0000 f1=0.0000 f2=0.0000 flags0=[nt=true nlt=false] flags1=[nt=true nlt=false]
STOP arm=notify_off moved=false tgt=(1.0000,1.0000,1.0000) src_glob=(9.0000,9.0000,9.0000) glob=true base_ok=true imm=13.8564 nimm=0.0000 f1=13.8564 f2=13.8564 flags0=[nt=true nlt=false] flags1=[nt=false nlt=false]
```

`source.set_notify_transform(false)` on a live binding **stalls propagation
completely**: the source moves to `(9,9,9)` (its own global transform is
correct — the flag does not gate the transform, only the notification), the
target stays frozen at its last propagated value `(1,1,1)`, and it is still
frozen two frame boundaries later. Identical at a physics boundary
(`notify_off_phys`), and identical on GP/Jolt/Dummy, 6/6 reps, byte-for-byte.

- **The assigned falsifier did NOT fire.** "`notify_off` still propagating ⇒ the
  driver is not the transform notification" — it did not propagate.
- **[O]** `RemoteTransform3D` defaults to `is_transform_notification_enabled() =
  true`, `is_local_transform_notification_enabled() = false` in global mode
  (`flags0` on every global-mode arm), and the constants are
  `NOTIFICATION_TRANSFORM_CHANGED = 2000`, `NOTIFICATION_LOCAL_TRANSFORM_CHANGED = 44`
  (`STOP_PRE … ntc=2000 nltc=44`).

## 1. The mechanism, in three separable stages

The explicit-notification arms decompose the driver, and the decomposition is
what makes the kill arm interpretable rather than merely observed:

| stage | arm | verbatim | reading |
|---|---|---|---|
| **handler** | `explicit_notify` | `imm=13.8564 … nimm=0.0000` | a script-dispatched `source.notification(2000)` propagates **inside the same statement** — the handler body *is* the propagation |
| **handler, flag off** | `explicit_notify_dead` | `imm=13.8564 … nimm=0.0000 flags1=[nt=false nlt=false]` | with the flag killed, the binding is **alive**; only the automatic *delivery* is gated |
| **handler, via transform API** | `force_upd` | `imm=13.8564 … nimm=0.0000` | `force_update_transform()` propagates synchronously too |
| **registration** | `revive_on_nomove` | `moved=false tgt=(1.0000,1.0000,1.0000) flags1=[nt=true nlt=false]` | re-enabling the flag does **not** re-deliver a change that happened while it was off (edge-triggered, no catch-up) |
| **registration** | `revive_on_move` | `moved=true tgt=(5.0000,5.0000,5.0000)` | a *new* move after re-enabling does propagate |
| **scheduling** | `ctrl` vs `explicit_notify` | `imm=13.8564` vs `nimm=0.0000` | the frame boundary is the *delivery schedule*, not the propagation itself |

**[I]** So the observable "one-frame lag" is a property of *when the engine
delivers the notification*, not of the propagation logic. This is the same
decomposition the round's §0.1 pinned from the outside; it is now pinned from
the inside.

## 2. The registration is mode-dependent — and that is what the crossed pair found

The inherited crossed pair assumed both notify flags default on. They do not.
*(The blocks in §2 and §3 are **abridged to the fields under discussion** — one
`grep -h '^STOP arm=' runs/bd_proj.r1.stdout.txt` prints all 26 full lines; §0
and §5.3 are verbatim.)*

```
arm=nloc_off_g    moved=true  glob=true  flags0=[nt=true nlt=false] flags1=[nt=true nlt=false]    # the kill was a no-op
arm=nloc_off_l    moved=false glob=false flags0=[nt=false nlt=true ] flags1=[nt=false nlt=false]   # the kill landed
arm=notify_off_l  moved=true  glob=false flags0=[nt=false nlt=true ] flags1=[nt=false nlt=true ]   # the kill was a no-op
arm=mode_g2l      moved=true  glob=false flags0=[nt=true nlt=false] flags1=[nt=false nlt=true ]
arm=mode_l2g      moved=true  glob=true  flags0=[nt=true nlt=false] flags1=[nt=true nlt=false]
arm=parented_glob  moved=true imm=12.2066 glob=true  flags0=[nt=true nlt=false]
arm=parented_local moved=true imm=0.0000  glob=false flags0=[nt=false nlt=true ]
```

**[O]** `use_global_coordinates` **maintains the notify pair**: `true` ⇒
`(nt=true, nlt=false)`, `false` ⇒ `(nt=false, nlt=true)`, and a *runtime* write
of the property rewrites the pair in both directions (`mode_g2l` / `mode_l2g`,
`parented_*` with the source and target under separate holders at `(10,0,0)` so
local ≠ global).

**[O]** Killing the **registered** notification stops propagation — `notify_off`
and `nloc_off_l` (and `both_off`), all `moved=false`, `f1=f2=13.8564`.
Killing the **unregistered** one is a no-op — `nloc_off_g` in global mode,
`notify_off_l` in local mode, both `moved=true`.

**[O]** The kill also holds when the motion is **parent-induced**: with `nt=false`
and the parent moved to `(9,9,9)`, the source's global reaches `(10,10,10)` while
the target stays at `(1,1,1)` (`notify_off_parent`, `moved=false`).

**[O]** `remote_path = ""` on a live binding freezes the target (`unbind`,
`moved=false`, `f1=f2=13.8564`) — confirms the scout's `LC_UNBIND` reading with a
non-identity follow metric.

## 3. The scheduling split: the local notification is delivered synchronously

`imm` is the distance **at the statement immediately after the move** — a
same-statement observable, immune to frame-count drift. It splits the arms
cleanly by *which notification is registered*:

| mode | registered trigger | arm | `imm` | verdict |
|---|---|---|---|---|
| `use_global_coordinates=true` | `NOTIFICATION_TRANSFORM_CHANGED` | `ctrl`, `nloc_off_g` | `13.8564` | **deferred to the frame boundary** (`f1=0`) |
| `use_global_coordinates=true` | same, parented (local≠global) | `parented_glob` | `12.2066` | deferred |
| `use_global_coordinates=false` | `NOTIFICATION_LOCAL_TRANSFORM_CHANGED` | `notify_off_l`, `mode_g2l` | `0.0000` | **synchronous, same statement** |
| `use_global_coordinates=false` | same, parented (local≠global) | `parented_local` | `0.0000` | synchronous |
| `use_global_coordinates=true`, `nt` off, `nlt` on | `NOTIFICATION_LOCAL_TRANSFORM_CHANGED` | `local_on_only` | `0.0000` | synchronous |

The last row is the isolating cell: **same mode, same handler, only the trigger
kind differs** — `nt` → deferred (`ctrl`, `imm=13.8564`), `nlt` → synchronous
(`local_on_only`, `imm=0.0000`). **[O]** The scheduling difference is a property
of the notification kind, not of the tree layout or of the mode's transform
choice. **[I]** The engine flushes `NOTIFICATION_TRANSFORM_CHANGED` through the
per-frame xform list (a global transform is only known after the parent chain is
resolved), while `NOTIFICATION_LOCAL_TRANSFORM_CHANGED` is delivered at the local
transform write itself.

**Fixture consequence [O]:** in the default global mode a fixture must cross a
frame boundary to see the propagation (the registered cell's four awaits are
safe), but a `use_global_coordinates=false` fixture needs **no** await at all —
and a fixture that awaits in local mode is not wrong, just unnecessary.

### 3.1 The delivery channel corroborates it — counted, not inferred **[O]**

The transform metric cannot see *how many* notifications arrive. `probes/notif.gd`
attaches a `Src extends RemoteTransform3D` script that counts
`_notification(2000)` / `_notification(44)` on the source itself (the C++ handler
still runs — the target follows, so the subclass is not a behavior change) and
prints the counters with the delta since the previous read. 12/12 receipts
byte-identical (`sha256 74e19dc1…`); one rep, `…` marks an elided tail:

```
LAB_PRE engine=4.7.2-stable (arch_linux) ntc=2000 nltc=44
LAB ph=bind d_ntc=1 d_nltc=0 n_ntc=1 n_nltc=0 pf=0 … glob=true flags=[nt=true nlt=false]
LAB ph=base_write_imm d_ntc=0 d_nltc=0 n_ntc=1 n_nltc=0 pf=0 tgt=(0.0000,0.0000,0.0000) src=(1.0000,1.0000,1.0000) …
LAB ph=base_f1 d_ntc=1 d_nltc=0 n_ntc=2 n_nltc=0 pf=0 tgt=(1.0000,1.0000,1.0000) …
LAB ph=base_f2 d_ntc=0 d_nltc=0 n_ntc=2 n_nltc=0 pf=1 …
LAB ph=A_write_imm d_ntc=0 d_nltc=0 n_ntc=2 n_nltc=0 pf=1 tgt=(1.0000,1.0000,1.0000) src=(9.0000,9.0000,9.0000) glob=true flags=[nt=true nlt=false]
LAB ph=A_f1 d_ntc=1 d_nltc=0 n_ntc=3 n_nltc=0 pf=1 tgt=(9.0000,9.0000,9.0000) …
LAB ph=A_f4 d_ntc=0 d_nltc=0 n_ntc=3 n_nltc=0 pf=2 …
LAB ph=B_mode_imm d_ntc=0 d_nltc=0 n_ntc=3 n_nltc=0 pf=2 glob=false flags=[nt=false nlt=true]
LAB ph=B_after_mode d_ntc=0 d_nltc=0 n_ntc=3 n_nltc=0 pf=2 glob=false flags=[nt=false nlt=true]
LAB ph=B_write_imm d_ntc=0 d_nltc=1 n_ntc=3 n_nltc=1 pf=2 tgt=(5.0000,5.0000,5.0000) src=(5.0000,5.0000,5.0000) glob=false flags=[nt=false nlt=true]
LAB ph=B_f1 d_ntc=0 d_nltc=0 n_ntc=3 n_nltc=1 pf=3 …
LAB ph=B_f4 d_ntc=0 d_nltc=0 n_ntc=3 n_nltc=1 pf=4 …
LAB_NOTE NTC n_ntc=1 n_nltc=0 pf=0
LAB_NOTE NTC n_ntc=2 n_nltc=0 pf=0
LAB_NOTE NTC n_ntc=3 n_nltc=0 pf=1
LAB_NOTE NLTC n_ntc=3 n_nltc=1 pf=2
LAB_DONE n_ntc=3 n_nltc=1 pf=4
```

- **[O]** Global mode: `A_write_imm d_ntc=0` (nothing at the write), `A_f1
  d_ntc=1` (exactly one `NOTIFICATION_TRANSFORM_CHANGED` at the boundary),
  `A_f4 d_ntc=0` (**no second delivery** over four boundaries).
- **[O]** Local mode: `B_write_imm d_nltc=1` **at the write statement** with
  `d_ntc=0` — the local kind is synchronous and the global kind is not delivered
  in this mode; `B_f1`/`B_f4` `d_nltc=0` — the local notification is **not**
  re-delivered at the boundary. Residual (a) of §7 is closed: the local
  notification is single-shot and synchronous.
- **[O]** `bind d_ntc=1` — writing `remote_path` itself delivers one
  `NOTIFICATION_TRANSFORM_CHANGED` (the cache resolution dirties the transform).
- **[O]** `B_mode_imm`/`B_after_mode` `d_ntc=d_nltc=0` — the
  `use_global_coordinates` write rewrites the flag pair but delivers **nothing**,
  and does not retro-deliver the change made under the old registration: the
  delivery-channel twin of `revive_on_nomove`.
- **[O]** Deliveries per write: **exactly one**, of exactly the registered kind,
  at exactly one schedule — the notification is edge-triggered and single-shot.

**[I]** This also explains the `imm` split without reference to the flush: the
local transform is known at the write, so the engine can deliver the local
notification inline; the global transform needs the parent chain resolved, so its
notification rides the per-frame xform list. `probes/notif.gd` was designed by a
dispatched `labrat` seat that had no exec capability (see §7); the executor seat
holds exec and ran it here.

## 4. What does NOT stall propagation **[O]**

Every arm below propagated with the *same latency* as `ctrl` (`f1=f2=0.0000`),
GP/Jolt/Dummy, 6/6 reps:

| switch | arm | `moved` |
|---|---|---|
| `process_mode = PROCESS_MODE_DISABLED` | `pmode_off` | true |
| `visible = false` | `hidden` | true |
| `top_level = true` | `toplevel` | true |
| source `reparent()`ed under a holder at `(10,0,0)` | `reparent` | true (`tgt=(19,9,9)`) |
| `SceneTree.paused = true` | `paused` | true |
| `Engine.time_scale = 0` | `ts0` | true |

**[O]** So there is exactly **one** script-visible stall switch for
`RemoteTransform3D` propagation: the notify flag of the registered notification
(plus `remote_path=""`, which is a binding kill rather than a scheduling kill).
`set_process(false)`/`set_physics_process(false)` (scout §1.7) and every switch
in this table leave it running. **[O]** `paused=true` does **not** gate the flush
— the pause arm's `process_frame` loop kept running (`SMOKE paused frames=3`) and
the propagation landed at the same boundary, so pause-gated propagation is *not*
a new law.

## 5. Secondary (§7.2, §7.7, §7.8) — bounded, 3 backends × 3 reps

`probes/sched.gd`, reduced by `sum.py` into `runs/sched_summary.txt`.

### 5.1 `physics_jitter_fix` is write-honoured and observationally inert **[O]**

The scout's arm wrote the default (`0.5`). This one writes `0.5 → 0.0 → 1.0 → 2.0`
in one child (`jit_read` confirms each write) and compares the *tick-step law*
rather than a pf-keyed map (the phases are sequential in time, so a pf-keyed
comparison is vacuous — a first version of the reducer made exactly that mistake,
recorded here rather than hidden):

```
  sc_proj_jitfix.r1          phases=['0.0', '0.5', '1.0', '2.0'] ratio[min=0.998327 max=0.998343] law=0.998333 offenders=0/15
                             boundary_ratios=['0.5->0.0 r=0.998338', '0.0->1.0 r=0.998343', '1.0->2.0 r=0.998332'] frac[min=0.0000 max=0.9522] interp_all_false=True
```

The per-tick velocity step is the default-damped Euler law
`Δv_k = -(9.8/60)·(1-0.1/60)^k` (project default `default_linear_damp=0.1`), and
consecutive ratios sit inside `[0.998327, 0.998343]` around the law
`0.9983333` — **including the three phase boundaries**, 0/15 offenders, GP+Jolt,
3/3 reps. A write that moved the step, the delta or the schedule would break the
constant at its boundary. Dummy reports `no unit steps` (its bodies never
integrate — the r89 floor).

### 5.2 A runtime `physics_interpolation` write changes nothing observable **[O]**

- `ProjectSettings.set_setting("physics/common/physics_interpolation", true)`
  reads back `true` (`SCH_INTERP_POST setting_read=true`) and the step law is
  unbroken across the `true->false` boundary (`r=0.998338`, 0/4 offenders,
  GP+Jolt, 3/3).
- `Node3D.get_global_transform_interpolated()` **equals the raw transform in
  18/18 rows** of every receipt, in both setting states — a runtime write does
  not engage interpolation.
- **[O]** `Engine` has no `set_physics_interpolation_enabled` in 4.7.2
  (`SCH_PRE … has_eng_ip=false`); a *static* call to it does not even parse
  (that first probe attempt produced 27 rc=1 children with no receipt — the
  absence is now recorded by the `has_eng_ip` field instead of a dead child).
- **[O]** `Engine.get_physics_interpolation_fraction()` is a live per-tick ramp
  (`0.0000 → ~0.98`) **with interpolation off** — it is the tick phase, not an
  interpolation-enabled signal. The scout's `interpf` arm never sampled it; this
  one does, and it is *not* evidence of interpolation.

### 5.3 A negative `time_scale` reverses the integrator on GP, freezes Jolt **[O]**

`Engine.time_scale = -1.0` after 6 ticks, sampled per tick (18 negative-delta
ticks), 3/3 reps identical per backend:

GP (`sc_proj_tsneg.r1`, verbatim):
```
SCH_TSNEG_MUTATE tsc=-1.000000 pf=7
SCH_E c=tsneg n_e=7 pf=7 delta=0.016667 y=4.942992 vy=-0.975926 tsc=-1.000000
SCH_E c=tsneg n_e=8 pf=8 delta=-0.016667 y=4.924031 vy=-1.137632 tsc=-1.000000
SCH_E c=tsneg n_e=9 pf=9 delta=-0.016667 y=4.940301 vy=-0.976195 tsc=-1.000000
```
reduced (`runs/sched_summary.txt`, GP / Jolt / Dummy):
```
  sc_proj_tsneg.r1           … neg_y[4.831014..4.981166] neg_vy[-1.137632..1.643700] y_end=4.831014 vy_end=1.643700 moved_during_neg=True
  sc_proj_jolt_tsneg.r1      … neg_y[4.924031..4.924031] neg_vy[-1.170299..-1.137632] y_end=4.924031 vy_end=-1.170299 moved_during_neg=True
  sc_proj_dummy_tsneg.r1     … neg_y[5.000000..5.000000] neg_vy[0.000000..0.000000] y_end=5.000000 vy_end=0.000000 moved_during_neg=False
```

- **[O]** The delta is delivered as `-0.016667` on all three backends (the
  SceneTree timing is backend-independent); the *solver response* is not.
- **[O]** GP integrates the reversed step exactly: `Δy = v_new·dt` with `dt<0`
  reproduces the receipt to ~1e-6 (`n_e=8→9`: `Δy=+0.016270` vs
  `-(-0.976195)·(1/60)=+0.016270`), and `Δv = g·|dt|·(1-0.1/60)^k` likewise. The
  body decelerates, reverses (`vy` reaches `+1.6437`) and travels *backwards*
  along its trajectory (peak `4.981166`, then down to `4.831014`).
- **[O]** Jolt **freezes the position** at the mutation value for all 18 negative
  ticks while the reported velocity keeps drifting more negative
  (`-1.137632 → -1.170299`, ≈ `-0.0018`/tick) — a backend divergence worth a
  fixture-level warning, **[?]** mechanism not isolated here.
- **[O]** The mutation takes effect on the tick *after* the write
  (`n_e=7` still `+0.016667`), consistent with scout §3.2.1.

## 6. Falsification list (armable)

| # | command | expected signature | falsified if |
|---|---|---|---|
| 6.1 | `python3 driver.py --batch stop --reps 6 --jobs 6` | 18 rc=0 receipts, `sha256 8900717b…`, 26 `STOP arm=` lines each | any receipt differs, or any rc≠0 |
| 6.2 | `grep -h 'arm=notify_off ' runs/bd_proj.r1.stdout.txt` | `moved=false … tgt=(1.0000,1.0000,1.0000) src_glob=(9.0000,9.0000,9.0000)` | the target follows ⇒ the driver is not the notification |
| 6.3 | `grep -h 'arm=explicit_notify_dead' runs/bd_proj.r1.stdout.txt` | `nimm=0.0000` with `flags1=[nt=false nlt=false]` | the binding dies with the flag ⇒ the kill is a binding kill |
| 6.4 | `grep -h 'arm=parented_' runs/bd_proj.r1.stdout.txt` | `parented_glob imm=12.2066` vs `parented_local imm=0.0000` | the split is a local==global artifact |
| 6.5 | `grep -h 'arm=mode_' runs/bd_proj.r1.stdout.txt` | flags flip `[nt=true nlt=false]↔[nt=false nlt=true]` | the pair is not mode-driven |
| 6.6 | `grep -h 'arm=paused\|arm=ts0\|arm=pmode_off' runs/bd_proj.r1.stdout.txt` | all `moved=true f1=0.0000` | any of them stalls ⇒ a new gating law |
| 6.7 | `python3 driver.py --batch sched --reps 3 --jobs 6 && python3 sum.py` | §5 signatures | any boundary ratio leaves `[0.998327,0.998343]`, or `gti_ne_y≠0` |
| 6.8 | `python3 driver.py --batch notif --reps 3 --jobs 3` | 9 rc=0 receipts, `sha256 74e19dc1…`; `A_write_imm d_ntc=0` then `A_f1 d_ntc=1` then `A_f4 d_ntc=0`; `B_write_imm d_nltc=1` | any delivery at the write in global mode, a second delivery at a later boundary, or a 2000 in local mode |

## 7. Defects, stability, remaining unknowns

- **Rep stability.** Primary: 21/21 byte-identical (single sha), across 3
  backends × 6 reps, under concurrent load. Delivery channel: 12/12
  byte-identical. Secondary: receipts differ in the idle/physics ratio
  (expected — `sum.py` compares observables, not bytes); the reduced verdicts are
  identical across 3/3 reps per backend.
- **Rep semantics.** A rep is a fresh process; the 26 arms run sequentially
  inside it, each rebuilding its own tree and asserting its own `base_ok=true`
  (all 26 `base_ok=true` in every receipt). The two global-state arms (`paused`,
  `ts0`) reset before teardown and are followed by arms whose `base_ok` would
  catch poisoning — it did not occur.
- **First-attempt defect (recorded, not hidden).** `sched.gd` v1 called
  `Engine.set_physics_interpolation_enabled(true)` statically → GDScript *parse*
  error → 27 rc=1 children, no receipts; fixed by dynamic dispatch + a
  `has_method` field. The reducer's first version compared phases by physics
  frame, which is vacuous for sequential phases; replaced by the step-law test.
- **probeParent dispatch (recorded, not hidden).** The one permitted depth-2
  `labrat` dispatch returned **no evidence**: that seat's substrate exposed only
  read-only tools (no exec, no write), so it could not create a project or launch
  godot. It reported `UNDECIDED` on all three sub-claims and explicitly declined
  to fabricate counters — correct behaviour. The seat's *design* (a
  `_notification` counter subclass) was sound and is what §3.1 runs; the executor
  seat holds exec and executed it, so §3.1 is executor evidence, not child
  evidence, and no child receipt is cited anywhere in this report.
- **[?] Residual.** (a) ~~whether the local notification is also flushed at the
  frame boundary~~ — **closed in §3.1: single, synchronous, no boundary
  re-delivery**; (b) which transform the handler reads when only `nlt` is
  registered in *global* mode (the scout's flag matrix implies global, but this
  seat's `local_on_only` layout had local == global); (c) Jolt's freeze mechanism
  under a negative delta; (d) `physics_jitter_fix` may be observable only under a
  *throttled* (vsync'd) render loop — this seat's regime is unthrottled headless,
  where the write is inert.
- **No tracked writes, no commits.** Everything landed under
  `corpus/live/r92-boundary/` (gitignored via `corpus/.gitignore:1`) plus this
  report; `git status --porcelain` shows only this new untracked report file.
  Every child was `timeout -s KILL 15`-bounded; no `godot` process of this seat
  survives (`pgrep -af r92-boundary` clean).
