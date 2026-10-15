# r96 boundary — the scout's pins under load, rate flags and backend variation

Lane: `g3d` · engine `4.7.2.stable.arch_linux.ed1daf0bf` · `/usr/bin/godot --headless` · 60 tps unless stated.
Namespace `r96b_*`. Receipts: `corpus/live/r96-boundary/` (gitignored) —
`probes/` (8 byte-identical copies of r96-scout's probe sources), `driver.py`,
`audit.py`, `runs/` (**662 children**, all `timeout -s KILL 25`),
`manifest.sha256` (3.2k files), `audit.log`, one `.log` per arm,
`RECEIPTS.md`, `runs.pilot-rename/` (§7.1).

Attack surface: every numbered pin of `reports/round-96/r96-scout.md`. Method:
(1) replay **74 of the scout's 169 cells** verbatim (all seven probe families)
and diff against its own receipts; (2) re-run under 14 own CPU hogs;
(3) re-run under `--fixed-fps` at four rates; (4) re-run at 30 and 120 tps to
test the *form* of the dt laws; (5) sweep the `Dummy` backend and the threaded
mode; (6) hunt unstated modes (`--time-scale`, `physics_jitter_fix`,
`max_physics_steps_per_frame`). No tracked file was written and no commit was
made.

---

## 0. Verdict table

| # | scout pin (or premise under test) | verdict |
|---|---|---|
| 1 | the §1–§6 receipt set | **CONFIRMED** — 74/74 replayed cells byte-identical on fresh project trees and fresh processes |
| 2 | "wall-clock contention does not enter any observable" (disclosed confound) | **CONFIRMED UNDER LOAD** — 58/58 byte-identical with 14 own hogs |
| 3 | "`--fixed-fps` receipts are byte-stable" (task premise, from r100) | **FALSIFIED on Jolt** — a job-system warning appears 0/1× at a variable stream position; the *physics* is unaffected |
| 4 | "`--fixed-fps` is a legal deterministic arm for r96 cells" | **PARTIAL** — legal with warning-line normalization; illegal as a raw-byte comparison |
| 5 | "the per-tick damping ratio is `1 − d·dt`" | **CONFIRMED and generalized** — 0.666667 / 0.833333 / 0.916667 at 30/60/120 tps; the clamp is `d·dt ≥ 1` |
| 6 | "the steady support impulse is `m·g·dt`" | **CONFIRMED at three tps** — 0.326667 / 0.163333 / 0.081667 |
| 7 | "GP's resting penetration is exactly `contact_max_allowed_penetration`" | **REFINED** — exact (0.010001) only at 60/120 tps; at 30 tps the ball rests at 0.295107 (pen 0.0049) and is still creeping *toward* the setpoint at t=140 |
| 8 | "Jolt's resting penetration is a tolerance band" | **REFINED** — band confirmed, but the resting pose is dt-dependent (0.300000 at 60/120 tps, 0.295111 at 30 tps, `lv≡0`) |
| 9 | "GP sleeps at t=126, Jolt at t=144" | **REFINED** — a wall-clock property: 64/126/≥252 ticks at 30/60/120 tps (Jolt 73/144/≥252; at 120 tps neither sleeps in the 200-tick window and both end at 0.094568834) |
| 10 | "the restitution combine rule is `clamp(A+B,0,1)`" | **CONFIRMED at three tps** — `sum` → `e_vel=0.7`, `mid` → `e_vel=1.0` at 30/60/120 tps |
| 11 | "a 0.9/0.0 pair bounces with `e_vel=0.9`" | **REFINED** — 0.9 is a 60-tps sampling of the tick-sampled ratio; the same pair reads 0.818182 at 30 tps (coefficient unchanged, sampling coarse) |
| 12 | "`solver_iterations` is inert for a single joint" | **CONFIRMED** at all dt (the GP pin's gap ratio is 0.7/tick at 30/60/120 tps; only the velocity spike scales as 1/dt: 2.7 / 5.4 / 10.8) |
| 13 | "Jolt's pin leaves no velocity residue" | **CONFIRMED** — `lv≡0.0` at every tick at 30/60/120 tps, gap ratio 0.64/tick |
| 14 | "the one non-byte-stable cell is rep-unstable" | **REFINED** — it is *batch-shape*-conditional, not random (§5) |
| 15 | (new) `--time-scale` is a rate knob like any other | **FALSIFIED** — `--time-scale 0.5` is byte-identical to the **120 tps** project and `--time-scale 2.0` to the **30 tps** project; it silently scales the physics timestep |
| 16 | (new) the `Dummy` backend | **no physics at all** (degenerate observables) and `damp.gd sleep1` **hangs** there (rc=137) |
| 17 | (new) the threaded mode | **identical** — 14/14 cells byte-identical to the single-threaded baseline |
| 18 | (new) the knob surface | 67 `physics/` keys, the list identical on GP, Jolt and Dummy (only the engine value differs); no warm-start / restitution-combine / GP-position-iteration key exists |

---

## 1. The replay baseline

Fresh project trees were regenerated from the scout's own `PROJECTS` strings:
**all 19 shared `project.godot` files are byte-identical** to
`corpus/live/r96-scout/<proj>/project.godot`. **74 of the scout's 169 cells**
were replayed with 2 reps and diffed against the scout's `r1` receipts: the
58-cell core set (all seven probes, every §1–§6 witness family) plus a
`gap`/`gap2` set that closes the remaining mechanism pins
(`rs_proj_jolt_bthr0_low`, `pn_proj_gp_sep0_overlap`, `rs_proj_min/both`), the
§6.1 five-platform identity, the §5.8 Jolt head-on pair, angular/gravity
damping, the Jolt tower and the `position_steps=8` stack.

```
replay    children=116  rc!=0: none        gap 4/4   gap2 12/12  (byte-identical to scout r1)
byte-identical=74 missing-ref=0 differing=0          (audit.log + gap/gap2 check)
replay raw-rep-stable=57/58   gap 4/4   gap2 12/12
```

Exemplar sha256 (16 hex chars, replay `r1` vs scout `r1`):
`it_proj_pin 725e6865accd9799`, `rs_proj_mid 9b79723afac5258b`,
`kn_proj_jolt_kcontact 085bb8291c89312a`,
`wm_proj_break ca94b419fb4ca1e4` — all MATCH. The gap cells reproduce the
scout's headline rows verbatim, e.g. the five platform classes all give
`KSUM … y_end=0.29001 lv_end=0.00001 cc_end=1`, the Jolt head-on pair gives
`RSUM case=pair v_in=2.0 v1_out=-1.8 v2_out=1.8 e1=0.9`, and
`rs_proj_jolt_bthr0_low` gives `v_out=0.588 e_vel=0.9` (the knob *is* the
mechanism).

Coverage, stated plainly: 74/169 ≈ 44% of the scout's cells, chosen to span
every witness family and every headline mechanism, not the full matrix (the
`iters` × 9-project grid, the `pen` grid and the remaining `kin`/`warm` cells
were not re-run — they are the same probes on other bakes).

The single rep-unstable cell is `wm_proj_jolt_nocache_stack`, exactly the cell
the scout disclosed: contact 0's *impulse readback* is
`0.000000,0.000000,0.000000` in r1 and `-0.000522,0.050273,0.001045` in r2,
while `y0=0.199833333` and `vmax=0.000093835` are identical on both rows. §5
characterizes it further.

---

## 2. Load: 14 own hogs (the scout's disclosed confound, attacked)

The scout wrote: *"The host was shared with other lanes' godot processes; all
witnesses are tick-indexed, so wall-clock contention does not enter any
observable."* That is the load-bearing claim behind every receipt in the
round, so it was attacked directly: the `load` arm re-ran all 58 cells with
**14 own `yes` hogs** spawned by the driver (pids recorded in `load.log`,
killed at arm exit) on top of an already-contended host (ambient loadavg 58.36
at arm start, ~10 foreign `yes` hogs, three other lanes' godot batches).

```
load      vs replay: raw-identical=58   phys-only-identical=0   phys-differing=0
load      children=116  rc!=0: none    (loadavg 58.36 -> 73.26)
```

**58/58 cells byte-identical — the load-invariance claim survives.** The same
holds for `loadff` (fixed-fps + hogs) once the Jolt warning is normalized:
`raw-identical=48  phys-only-identical=9  phys-differing=1` — and that one
physics difference is the `wm_proj_jolt_nocache_stack` contact-identity cell,
which differs between reps in the *unloaded* arms too (§5). No other receipt in
either loaded arm differs from its unloaded twin in any physics observable.

Caveat, stated plainly: a *quiet* baseline was impossible to obtain without
touching foreign processes, so "unloaded" here means loadavg ≈ 27–58, not
zero. The load arm is therefore "more load", not "load vs idle".

---

## 3. `--fixed-fps`: the deterministic arm is not byte-deterministic on Jolt

The task premise — "prefer `--fixed-fps` deterministic arms where the scout's
allow (r100 scout proved it byte-stable)" — does **not** transfer to the r96
cell set:

```
ffps   vs replay: raw-identical=46   phys-only-identical=11   phys-differing=1
ffps   raw-rep-stable=43/58
```

All 12 raw-differing cells are `proj_jolt*`; every GP cell is byte-identical.
The difference is a runtime warning, not physics:

```
WARNING: Jolt Physics job system exceeded the maximum number of jobs.
This should not happen. Please report this. Waiting for jobs to become available...
     at: CreateJob (modules/jolt_physics/spaces/jolt_job_system.cpp:123)
```

It appears **0 or 1 times per receipt, at a variable stream position**, so two
runs of the same cell differ by line insertion. Census over all 662 receipts:

| arm | receipts with the warning |
|---|---|
| `replay` (no flag) | **0 / 116** |
| `load` (no flag, 14 hogs) | **0 / 116** |
| `ffps` (`--fixed-fps 60`) | 24 / 116 |
| `loadff` (`--fixed-fps 60` + hogs) | 21 / 116 |
| `ffpsx` (`--fixed-fps` 30/60/120/240) | 6 / 12 |
| all 15 other arms | **0 / 530** |
| **total** | **51 / 662** |

The `ffpsx` arm shows the warning at **30, 60, 120 and 240 fps** — it is a
`--fixed-fps` artifact, not an fps-value artifact, and load does not change
its rate (24/116 vs 21/116). After dropping the two warning lines (and the
banner) the receipts are byte-identical to `replay` for 57/58 cells — the
remaining one is the nocache cell.

**Consequence for the fleet:** a `--fixed-fps` receipt on a Jolt cell is
usable as a *physics* comparison only with warning-line normalization; a raw
byte-identity audit that does not normalize will report false divergence on
~20% of Jolt cells. The GP cells are unaffected and are byte-stable under
`--fixed-fps` (all 46 raw-identical).

---

## 4. Tick-rate variation: which pins are dt-invariant, which are dt-scaled

Re-running the discriminating cells at 30 and 120 tps (`proj_tps30`,
`proj_tps120` and their Jolt twins; 14 cells × 2 reps × 2 rates, all
rep-stable) tests the *form* of every pinned law rather than one point of it.

| witness | 30 tps | 60 tps (scout) | 120 tps | law |
|---|---|---|---|---|
| `dp lin10` ratio (GP **and** Jolt, identical) | `0.666666603` | `0.833333302` | `0.916666698` | `1 − d·dt` with the **actual** dt |
| `dp lin100` ratio | `0.0` (clamped) | `0.0` (clamped) | `0.166666627` | clamp at `d·dt ≥ 1`, dt-scaled |
| `wm rest` support impulse (both backends) | `0.326667` | `0.163333` | `0.081667` | `m·g·dt` |
| `it pin` GP velocity spike at t=2 | `2.7` | `5.399999` | `10.799998` | `∝ 1/dt` |
| `it pin` GP gap decay | `0.3→0.21→0.147` | same | same | `0.7`/tick, dt-invariant |
| `it pin` Jolt gap decay, `lv` | `0.3→0.192→0.12288`, `lv≡0` | same | same | `0.64`/tick, dt-invariant |
| `pn overlap` residual GP | `−0.010004` | `−0.010001` | `−0.010001` | setpoint `contact_max_allowed_penetration` |
| `pn overlap` residual Jolt | `−0.02` | `−0.02` | `−0.02` | band `penetration_slop` |
| `rs sum` / `rs mid` `e_vel` | `0.7` / `1.0` | `0.7` / `1.0` | `0.7` / `1.0` | combine rule tps-invariant |
| `rs low` (0.03 m drop) Jolt | `v_out=0.0` | `v_out=0.0` | — | `bounce_velocity_threshold` holds |
| `dp sleep1` `slept_at` GP / Jolt | `64` / `73` | `126` / `144` | `−1` / `−1` | wall-clock, not ticks |

Two refinements worth pinning separately:

- **GP's "setpoint" is dt-conditional.** At 30 tps the settled ball rests at
  `y=0.295107216` (penetration 0.0049) with `lv=-0.00000447` and is *still
  creeping toward* 0.01 at t=140 (`y_end=0.295085520`, `lv=-1.16e-5`) —
  the 60-tps receipt (`y=0.290000051`, pen 0.010001) is the converged case,
  not a universal constant. Jolt is dt-dependent in pose too
  (`0.29511106` at 30 tps vs `0.300000012` at 60/120 tps) but keeps `lv≡0.0`
  and stays inside the slop band at every rate.
- **`e_vel=0.9` is a sampling artifact.** For the same 0.9/0.0 pair the
  30-tps receipt reads `v_in=-0.718667 v_out=0.588 e_vel=0.818182`
  (`e_apex=0.924562`); the *coefficient* the solver applies is unchanged —
  the tick-sampled ratio is not. The combine-rule discrimination (`sum` 0.7,
  `mid` 1.0) is unaffected because both cells are sampled the same way.

The damping identity across backends is even tighter at 120 tps: neither
backend sleeps inside the window and both report
`lv_end=0.094568834` — identical to 9 digits.

---

## 5. The one unstable cell is batch-shape-conditional

`wm_proj_jolt_nocache_stack` (Jolt, `body_pair_contact_cache_enabled=false`)
was re-run under controlled shapes:

| run shape | `W t=60` contact-0 impulse |
|---|---|
| scout: 507 children, jobs=6, no flag | r1 `0,0,0` · r2/r3 real |
| `replay`: 116 children, jobs=6, no flag | r1 `0,0,0` · r2 real |
| `load`: 116 children, jobs=6, 14 hogs, no flag | r1 `0,0,0` · r2 real |
| `ffps` / `loadff`: 116 children, jobs=6, `--fixed-fps 60` | r1 real · r2 real |
| `nc`: **1 cell**, 3 sequential reps, jobs=1 | all three real |
| `nc6`: **1 cell**, 3 sequential reps, jobs=6 | all three real |

`y0` and `vmax` are identical in every row of every shape. So the scout's "the
one non-byte-stable cell" is not process-random: the all-zero read appears
only in the *large, non-fixed-fps batches*, always on the first rep, and never
in a single-cell batch or under `--fixed-fps`. A byte-identity audit of this
cell must therefore control the batch shape, not just the rep count.

---

## 6. Unstated modes

### 6.1 `--time-scale` is a stealth tick-rate knob (new)

`--time-scale` was never passed by the r96 driver, and r100 treats it as an
ordinary rate flag. It is not:

```
--time-scale 0.5 @60tps  ==  the 120-tps project     (byte-identical, 2/2 cells)
--time-scale 2.0 @60tps  ==  the  30-tps project     (byte-identical, 2/2 cells)
```

and the physics moves accordingly: the GP pin's t=2 spike is
`lv=10.799998` under `--time-scale 0.5` (the 120-tps value) and
`lv=5.399999` plain; `dp lin10` reads `ratio=0.916666698` (the 120-tps value).
So `--time-scale k` multiplies the physics timestep by `k` — every dt-scaled
law in §4 shifts with it. Any cross-run comparison that mixes time scales (or
inherits one from a wrapper) is comparing different physics.

### 6.2 Inert modes (checked, all byte-identical)

- `--fixed-fps 30` (2 frames per tick) vs plain 60 tps: identical, 3/3 cells.
- `physics/common/physics_jitter_fix=0.0` under `--fixed-fps 30`: identical,
  3/3 cells (r100's phase shift does not reach these tick-indexed rows).
- `max_physics_steps_per_frame=1` vs 8: identical (`iters stack`), re-binding
  r100's finding on the r96 cells.
- `3d/run_on_separate_thread=true`: **14/14 cells byte-identical** to the
  single-threaded baseline (GP and Jolt: pin/chain/stack, warm rest/break,
  damp lin10, pen overlap). r87/r88 own the threaded gate generally; for this
  cell set the threaded mode is receipt-identical.

### 6.3 The knob surface is backend-independent

`settings.gd` on GP, Jolt, Dummy and the 30-tps bake: `ST total_props=949
physics_props=67` in all four, and the 67-key list is identical except for the
`physics/3d/physics_engine` value (and `physics_ticks_per_second` on the tps
bake). The scout's §0 enumeration checks out from my own dump: the 3D solver
block has exactly five keys and **no** `default_constraint_bias` (the 2D block
has it at 0.2), and no key anywhere in the list contains "warm", nor is there
a restitution-combine setting — only Jolt's `bounce_velocity_threshold`.

### 6.4 `Dummy`: no physics, and one probe hangs (new)

With `3d/physics_engine="Dummy"` the server is a complete no-op:

```
IT t=1 gap=-1.0 lv=0.0 y=0.0            (body_get_state returns a zero transform)
PSUM case=overlap sep_end=-0.3          (no depenetration)
WSUM case=rest y_end=0.600000024        (no fall; 11/12 cells rc=0)
DSUM case=lin10 lv_end=10.0 y_end=5.0   (no damping)
KSUM case=kcontact ... cc_end=0 kin_first_cc=-1
```

No r96 pin is defined on Dummy (every witness is degenerate), so the scout's
"on both backends" statements are complete for the selectable set it swept —
but the third selectable backend is not merely "another backend", it is a
null physics world.

Worse for reuse: **`damp.gd sleep1` never terminates under Dummy** —
`body_get_state(BODY_STATE_SLEEPING)` returns an invalid Variant, the probe
throws `SCRIPT ERROR: Invalid call. Nonexistent 'bool' constructor. at: on_e
(res://damp.gd:136)` before reaching its `tick >= 200` quit, and loops until
the 25 s KILL: `rc=137` on both reps, 431 KB of repeated error text. Any
future Dummy sweep of these probes must special-case that cell.

---

## 7. Probe artifacts and hazards

### 7.1 The `r96b_` `res://` rename is not byte-neutral for `kin.gd`

Running the probe copies under a namespaced `res://r96b_kin.gd` changes the
receipt: `kin.gd` raises a benign `ERROR: Condition "!is_inside_tree()" is
true` in `_initialize()` and the GDScript backtrace prints the script path.
`runs.pilot-rename/` (kept as evidence) holds the full 58-cell replay under
the renamed paths: **51 byte-identical, 6 kin cells differing only in that one
line, 1 nocache cell differing as disclosed**. The shipped receipts therefore
use the scout's original `res://` names while `probes/` keeps the `r96b_`
namespace — see `RECEIPTS.md`.

### 7.2 `damp.gd`'s `dt` print is a hardcoded constant

`D0 ... dt=0.016666666667` is `1.0/60.0` written into the probe, not a
readback. On the 30/120-tps bakes the header is wrong while the physics rows
are right; all §4 conclusions use the measured ratios, never that header.

### 7.3 `iters.gd` reports `-1e9` sentinels on non-matching cases

`ITSUM` prints every peak key regardless of case (`max_over=-1000000000.0`
on the pin case, etc.). Harmless for byte comparison, easy to misread as a
value.

---

## 8. Falsification list

1. **"A `--fixed-fps` receipt is byte-stable."** FALSIFIED on Jolt — a
   job-system warning is emitted 0/1× at a nondeterministic position in 51/662
   receipts, all of them in the three `--fixed-fps` arms (§3). GP is
   unaffected.
2. **"The r96 witnesses are load-invariant."** CONFIRMED — 58/58 byte-identical
   under 14 own hogs on an already-contended host (§2).
3. **"`--time-scale` is just another rate flag."** FALSIFIED — it multiplies
   the physics timestep: `0.5` ≡ 120 tps and `2.0` ≡ 30 tps, byte-identical
   (§6.1).
4. **"GP's resting penetration is exactly `contact_max_allowed_penetration`."**
   REFINED — a dt-conditional setpoint; at 30 tps it is still converging
   (pen 0.0049 at t=140) (§4).
5. **"Jolt rests at the geometric surface."** REFINED — 0.295111 at 30 tps,
   0.300000 at 60/120 tps; the band framing holds, the value does not (§4).
6. **"The sleep tick is a tick count."** REFINED — it is wall-clock
   (64/126/≥252 ticks at 30/60/120 tps) (§4).
7. **"A 0.9/0.0 pair bounces with `e_vel=0.9`."** REFINED — tick-sampled
   ratio (0.818182 at 30 tps); the combine rule itself is tps-invariant (§4).
8. **"The one non-byte-stable cell is rep-unstable."** REFINED — it is
   batch-shape-conditional, first-rep-of-large-batch, absent at jobs=1 and
   under `--fixed-fps` (§5).
9. **"`Dummy` is just a third backend."** FALSIFIED — no physics at all, and
   `damp.gd sleep1` hangs to the 25 s KILL (§6.4).
10. **"A namespaced `res://` probe name cannot change a receipt."** FALSIFIED
    for `kin.gd` (§7.1).

Confirmed unchanged (no counter-example found): §1 joint semantics and the
node-body joint trap, §2 warm-start observables and the break/`recycle0`
behaviour, §3 depenetration constants, §4 damping curve and COMBINE/REPLACE
semantics, §5 restitution combine + Jolt threshold, §6 kinematic/static
contact class and the five-platform identity.

---

## 9. Not tested / remaining risks

- **Threaded gate in general** (r87/r88 own it): only 14 cells were checked,
  and only at 60 tps without load.
- **`--time-scale` × `--fixed-fps` interaction** — the two flags were not
  combined.
- **Noise floor of the nocache cell** under a *quiet* host was not measured
  (the host was never quiet).
- **Apex-level discrepancies** (the scout's ~15 mm GP/Jolt rebound-apex gap)
  and the exact `baumgarte` → rate mapping were not re-attacked; the two-point
  curves stand as measured at 60 tps only.
- **Dummy's `sleep1` hang** is a probe bug, not a scout claim; it is reported
  as a reuse hazard.
- The **ambient host contention** (foreign `yes` hogs, three other lanes) is
  recorded but uncontrolled; my 14 hogs were killed at arm exit and no
  process of this lane survived.

---

## 10. Reproducing and receipts

```
cd corpus/live/r96-boundary
python3 driver.py --arm replay --reps 2 --jobs 6    # and: ffps load loadff
python3 driver.py --arm tps30  --reps 2 --jobs 6    # and: tps120 dummy threaded
python3 driver.py --arm unstated --reps 2 --jobs 6  # ffps30 / jitter0 / ts0.5 / cap1
python3 driver.py --arm ffpsx --reps 2 --jobs 6     # --fixed-fps 30/60/120/240
python3 driver.py --arm settings --reps 2 --jobs 4  # the 67-key dump, 4 backends
python3 driver.py --arm tsx --reps 2 --jobs 4       # --time-scale 2.0
python3 driver.py --arm nc --reps 3 --jobs 1        # and: nc6 (jobs=6)
python3 driver.py --arm gap --reps 2 --jobs 4        # remaining mechanism pins
python3 driver.py --arm gap2 --reps 2 --jobs 6       # headline cells outside CORE
python3 audit.py
```

`corpus/live/r96-boundary/`: `probes/` (8 `.gd`, sha-pinned), `driver.py`,
`audit.py`, `runs/` (662 children + `.cmd`/`.exit`/`.ms` sidecars),
`audit.log`, per-arm `.log`, `RECEIPTS.md`, `manifest.sha256` (3.2k files),
`runs.pilot-rename/` (§7.1 evidence). `corpus/live/` is gitignored — scratch
only, per lane contract.

Provenance: this lane wrote **only** `corpus/live/r96-boundary/**` and
`reports/round-96/r96-boundary.md`. It read `corpus/live/r96-scout/**` and
`reports/round-96/r96-scout.md`; neither was modified.
