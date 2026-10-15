# r97 boundary — the scout's gameplay-node pins under verbatim replay, load, rate modes and tps variation: 64/67 hold, 3 are one bimodal setup race, and the GP soft-body "no collision" law is a thin-slab artifact

Lane: g3d · engine `4.7.2.stable.arch_linux.ed1daf0bf` · `--headless`, 60 tps
unless a mode is named. Backends: GodotPhysics (`proj`), Jolt (`proj_jolt`),
Dummy (`proj_dummy`) wherever the scout swept them.
Evidence: `corpus/live/r97-boundary/` — `probes/` (the scout's 9 probes as
byte-identical `r97b_*` copies + `probes/soft.gd` under the scout's own name +
3 new probes), `driver.py`, `cmp.py`, `run_arms.sh`, `runs/` (**1263 children**;
`.stdout.txt` per child plus `.exit/.ms/.load/.cmd` for driver-run children), `RECEIPTS.md`,
`manifest.sha256` (**6389 files**). The scout's corpus was read, never written.
Only tracked-tree write: this report.

Host state: **1-min load average 84–120 on 32 cores** during the arms (other
live lanes: `r92-verify2`, `r93-baseline2`, `r99-boundary --hogs 32`, the 2D
`r92-scout` loadtest's 16 `yes`). There is no quiet baseline on this host, so
the "replay" arm is itself a load arm relative to the scout's session, and
`load16`/`load32` stack 16/32 of my own hogs on top of that.

Confidence: **[O]** receipt-pinned observation · **[I]** inference ·
**[?]** unknown / not decided by these cells.

**Seat verdict.** The scout's cell set is *reproducible*: **64 of the 67 scout
cells I replayed are byte-identical to the scout's own receipts** under ambient
load, under +16 hogs, and under `--fixed-fps 60` (declared normalizations only:
ASLR crash addresses, the task's probe rename, the r100 §7.5 Jolt warning line).
The **3 that are not** are all GodotPhysics *pinned-cloth* cells and are **one
mechanism**: the scout's `soft.gd` applies its pins through
`call_deferred("_do_pins")`, and that deferred flush lands **either before
(pf=0) or after (pf=1) the first physics step** — a startup race. Both branches
are internally deterministic and `rc=0`; the scout's receipts are the `pf=0`
branch, my replay's are `pf=1`, and `--pins=now` reproduces the scout's branch
byte-for-byte on all three cells. Separately, the scout's **headline soft-body
law is falsified as written**: "GodotPhysics … does not collide" is a property
of the 0.1 m slab it was measured on — in the identical rig GP *rests* on slabs
of 0.2 m and ≥0.5 m (and tunnels at 0.15/0.25/0.3, ejects at 0.4), while Jolt's
"mass=10 / precision=50 fall through" failures likewise disappear on a 2.0 m
slab. The teardown SIGSEGV envelope, the joint lattice, the DSS matrix and the
CharacterBody3D splits all survive every attack I ran, including 32 hogs.

---

## 0. Verdict table per assigned attack

| # | attack | verdict | anchor |
|---|---|---|---|
| 1 | verbatim replay vs the scout's own receipts | **CONFIRMED** — 64/67 byte-identical | §1 |
| 2 | the 3 non-identical cells | **MECHANISM FOUND** — deferred pin-phase race, both branches deterministic | §2 |
| 3 | ≥12 hogs (16/32 `yes` on top of load 84–120) | **NO CHANGE** — 82/85 cells byte-identical, crash set identical | §3 |
| 4 | `--fixed-fps 60` (1 tick/frame) | **NO CHANGE** — 82/85 identical; the 3 are my own scheduler probe | §4 |
| 5 | other rate modes (2/4/6 ticks per frame, 1 tick/2 frames) | **NO CHANGE** — trajectory hash and free-at-tick cells invariant | §4 |
| 6 | tps variation (30/120) | **SPLIT** — laws survive at equal sim time; 2 pinned *values* are tps-scoped; 1 is a probe artifact | §5 |
| 7 | GP soft-body "simulates but does not collide" | **FALSIFIED** — thickness sweep: rests at 0.2 and ≥0.5 | §6 |
| 8 | Jolt "collides, barely" + mass/precision thin-floor failure | **BOUNDED** — thin-slab only; both rest at 0.05 on a 2.0 slab | §6 |
| 9 | deferred-deletion granularity (unstated mode hunt) | **HYPOTHESIS REJECTED** — deletion is step-granular, not frame-granular | §7 |
| 10 | Dummy backend inertness | **CONFIRMED** in every arm | §8 |
| 11 | rep identity (scout: 336/337) | **CONFIRMED** — 82/85 in my replay; the 3 are my scheduler probe | §8 |

---

## 1. Verbatim replay — 64/67 byte-identical

Every probe is a byte-identical copy of the scout's (`sha256` in `RECEIPTS.md`),
run through the scout's own command shape
(`--headless --path <proj> --script res://<probe> -- <args>`), 3–6 reps per cell.
`python3 cmp.py --scout` against `corpus/live/r97-scout/runs/`:

```
== replay  vs scout: 64 identical, 3 differ, 18 no-scout-cell
== load16  vs scout: 64 identical, 3 differ, 18 no-scout-cell
== ffps60  vs scout: 64 identical, 3 differ, 18 no-scout-cell
```

The 18 "no scout cell" are my own (`md_*`, `sf_*`); four of the scout's
finisher-supplement tags are reached through an alias table
(`njx_proj_clampbig`, `njx_proj_exclx_on/off`, `q_proj_ray_hfi_in`).

Rep identity in the same arms (`cmp.py --reps`), which is also *load* identity
because all reps ran 6–8-way concurrent on a host at load 84–120:

| arm | cells with ≥2 reps | identical | differ |
|---|---|---|---|
| `replay` | 85 | 82 | 3 (all `md_*`, by design — they print the scheduler fields) |
| `load16` | 85 | 82 | 3 (all `md_*`) |
| `ffps60` | 85 | 85 | 0 |
| `tps30` / `tps120` | 36 / 36 | 34 / 34 | 2 / 2 (`md_*`) |
| `load32` / `tps120ff` | 8 / 8 | 8 / 8 | 0 |
| `softfloor` | 15 | 14 | 1 (the pin-phase line, §2) |
| `freegrain` | 11 | 8 | 3 (`ff` in *unpinned* base mode — a wall-clock counter by construction) |

The 6-rep teardown/lifecycle cells (`freerj`, `freeb`, `readd`, `dupclaim`,
`freeme`, GP and Jolt) are **6/6 byte-identical, rc=0** in both the ambient and
the 16-hog arm.

Two receipt-level corrections to the scout's prose, both harmless:

- **`badpath`/`nob` and `bind`/`bindpre` are not byte-identical receipts** — they
  differ in the case-name stamp (`NJ setup case=…`, `NJSUM case=…`). The
  *physics rows* are byte-identical, in the scout's receipts and in mine alike.
- The scout's "336/337 byte-identical, the single difference is the crash dump's
  ASLR `Load address` line" is one line short: `cls_proj` r1/r2/r3 differ in
  **7** lines (`Load address` + the six `[n] …` backtrace frames). I re-ran
  their `audit.py` verbatim: `children=1116 rc!=0: 13 cells=337 identical=336
  differ=1`.

---

## 2. The 3 non-reproducing cells — one mechanism, both branches deterministic

The three are `sbx_proj_collide`, `sbx_proj_pin_top`, `sbx_proj_pin_mid` (GP
pinned cloth). The scout's own probe explains why, but cannot show it: their
`soft.gd` sets the pins from `_initialize` via `call_deferred("_do_pins")`, and
**a deferred call is flushed at the end of the first physics step *or* at the
end of the first process frame, whichever comes first** — i.e. the pins are
registered before (`pf=0`) or after (`pf=1`) the cloth's first integration step.
The pin anchor is taken from the vertex state at pin time, so the whole pinned
trajectory branches.

`r97b_softfloor.gd` is the scout's rig with the phase printed and a `--pins=`
switch. Verbatim, GP, `thick=0.1` (= the scout's rig):

```
pp_proj_collide_t01_def.r1  SF pins applied at pf=1 tick=1  SF t=10 v4=0.00032,2.89464,0.00057
pp_proj_collide_t01_def.r2  SF pins applied at pf=0 tick=0  SF t=10 v4=0.00099,2.90742,0.00146
pp_proj_collide_t01_def.r3..r6                              (all pf=0, same value)
pp_proj_collide_t01_now.r1..r6  pf=0 (6/6)                  SF t=10 v4=0.00099,2.90742,0.00146
pp_proj_pinmid_now.r1..r3       pf=0 (3/3)                  SF t=10 v0=-0.49717,2.88951,-0.4978
```

and the scout's receipts for the same three cells:

```
sbx_proj_collide.r1  SB t=10 v4=0.00099,2.90742,0.00146
sbx_proj_pin_top.r1  SB t=10 v4=0.00099,2.90742,0.00146
sbx_proj_pin_mid.r1  SB t=10 v4=0.0,3.0,0.0 v0=-0.49717,2.88951,-0.4978
```

- **[O] The scout's values are the `pf=0` branch, exactly**, and
  `--pins=now` (pin immediately after tree entry, before the first step)
  reproduces them 6/6 and 3/3 — deterministic, no race.
- **[O] Both branches are deterministic**: 6/6 and 3/3 within each branch, and
  every one of my 36 deferred-setup GP collide runs landed on one of exactly two
  values. My replay arms landed `pf=1` (3/3 each in `replay`, `load16`,
  `ffps60`), the `pinphase` batch landed `pf=0` 5/6.
- **[O] Phase census** (every receipt that prints it): GP deferred **29× pf=1 /
  7× pf=0**; Jolt deferred 24× pf=1 / 0× pf=0. Jolt's cloth branches too —
  `--pins=now` on Jolt gives `0.00022,2.92202,0.00021` vs the scout's (pf=1)
  `0.00054,2.92247,0.00058` — the scout's Jolt cells matched my replay only
  because both sessions happened to sit in the same branch.
- **[?]** the exact trigger of the race (first-frame delta vs `1/tps` is the
  natural reading, but `--frame-delay 0/50/100` did not move it: 6/6 `pf=1`).
  **[I]** the fix is to pin synchronously, or to print the phase; an rc/text
  match cannot see the branch.

**Hazard.** `sbx_proj_pin_top`, `sbx_proj_pin_mid`, `sbx_proj_collide` and their
Jolt counterparts are two-valued cells. Pinning either value as a fixture
invariant is armed; pin the branch instead (`pf=0` ⇔ pin before the first step).

---

## 3. Load arms (16 and 32 hogs)

- **[O] The crash set is identical in every arm.** `rc=134` children:
  `replay` 14/279, `load16` 14/279, `load32` 24/48, `ffps60` 14/282 — always
  exactly `cls_proj`, `cls_proj_jolt`, `iso_xrs_1`(×6), `iso_xrs_jolt`, never
  anything else. **66 crash children, 0 escapes, 0 rc=0 in the crash set**
  (whole-corpus rc census: 1197× `rc=0`, 66× `rc=134`, 0× `rc=137`).
  `iso_clean` (the other 40 instantiable classes), `xr_same`, `xr_keep`,
  `xr_dbl` are `rc=0` in every arm — the "instantiate-and-free poisons teardown,
  instantiate-and-leak does not" split is load-invariant, and the r90
  bimodality did **not** appear here. Keep the envelope phrasing, but the
  observed distribution is degenerate.
- **[O] Load does not move a single physics row**: `replay` vs `load16` is
  82/85 byte-identical (the 3 are `md_*`), including the Jolt vehicle tumble
  tails, the `maxslides` jitter, the soft-body sweeps and the CB hover heights.
- **[O] The per-tick physics delta is exactly `1/tps` under load** — every
  `md_*` row in the load16 arm reads `d=0.016666667` (and `0.033333333` /
  `0.008333333` on the tps bakes), which is why load cannot move the physics:
  the tick sequence, not the wall clock, is what the probes print. `d` here is
  the argument handed to `_physics_process` (the physics step); the *process*
  delta is a different quantity and r100-boundary §3.3 shows it is
  jitter-scaled at `physics_jitter_fix=0.5` for `N ≠ tps`. Nothing here depends
  on that: the 82/85 byte-identity and the crash census are the load claims.

---

## 4. Rate modes (`--fixed-fps`)

`r97b_mode.gd` first reproduces r100 §1 on this rig (120 ticks, GP):

```
base   (60 tps)   ff=291 hist=2:70 3:49 4:1    traj=3843dd35
ffps60            ff=119 hist=0:1 1:119        traj=3843dd35
ffps30            ff=60  hist=0:60 1:60        traj=3843dd35
ffps10            ff=20  hist=0:100 1:20       traj=3843dd35
tps120 + ffps60   ff=60  hist=0:60 1:60        traj=44c80d21
tps120 + ffps30   ff=30  hist=0:90 1:30        traj=44c80d21
tps30  + ffps60   ff=238 hist=0:1 2:119        traj=0a320f68
```

- **[O] r100's law generalizes to the whole r97 surface**: `replay` vs `ffps60`
  is **82/85 byte-identical** — the only differences are my own `md_*` probe's
  scheduler fields (`ff`, `df`, `ifr`). Every scout cell, on all three backends,
  in every mode (soft bodies, vehicles, character bodies, joints, DSS, crash
  dumps), is rate-mode-invariant.
- **[O] The trajectory is interleave-invariant from 1 tick/frame to 6
  ticks/frame** — one hash (`3843dd35`) for base (2–4 frames/tick), `ffps60`
  (1 tick/frame), `ffps30` (2 ticks/frame) and `ffps10` (6 ticks/frame) — and the
  tps=120 modes agree with each other (`44c80d21`) at 2 and 4 ticks/frame.
- **[O] r100 §7.5's Jolt warning is a dense-frame artifact here too**: 21
  `ffps60` children, 1 `tps120ff`, 1 `ffps30`, **0** in the unpinned arms. It is
  rep-stable inside an arm (the 21 cells are identical across their reps), so it
  is a receipt-shape difference, not a physics one. (r100-boundary §6 measured
  its *rate* as load-dependent — 38 % at ambient up to 92 % under starvation;
  my arms are all in the dense-frame regime, so the line is simply always there.)
- Engine flags were always placed **before** `--script` (r100 §7.1); every
  child's `.cmd` sidecar records the exact shape.

---

## 5. tps variation (30 / 120)

Both tps bakes are `rc=0` and rep-identical. Reading the laws at *equal sim
time* (the probes report at fixed tick indices, so tps=30 t=120 is 4 s and
tps=120 t=120 is 1 s):

| pin | tps 60 | tps 30 | tps 120 | verdict |
|---|---|---|---|---|
| GP `constspd` rv on the 20° slope | `1.8794,-0.684` (fl=1) | same at t=60 (2 s), fl=1 | same at t=60/120, fl=1 | **survives** |
| Jolt `constspd` | fails (rv≈3.3/4.7) | degrades by t=45 (`2.0434,-1.3507`, fl 1→0) | fails (`4.7228,7.1282`) | **survives** |
| vehicle drop settle (GP==Jolt byte-wise) | `0.7299` | `0.7298` | `0.7316` (v=0.0065, still settling) | **law survives, value tps-scoped** |
| `maxres` survivor order | GP `tri,wall2` / Jolt `tri,sph` | same | same | **survives** |
| soft drop, 0.1 slab | GP tunnels, Jolt rests | same | same | **survives** |
| Jolt `mass_hi`/`prec_hi` | fall through | fall through | fall through | **survives** |
| `margin_hi` hover (GP / Jolt) | `0.5919` / `0.5969` | `0.5887` / `0.5937` | `0.5934` / `0.5984` | **split survives, value tps-scoped ±3 mm** |
| `plat_ride` (GP fl=1 n=1 / Jolt fl=0 n=0) | split | split | split | **survives** |
| `FLOATING` fl=0 wlo=1, `v.y=-19.6` | — | same | same | **probe artifact** (below) |

- **[O] The vehicle's raycast-suspension equilibrium is backend- and
  tps-invariant**: GP and Jolt are byte-identical at every tps; only the
  *convergence state* differs (`0.7316` at 1 s is still settling toward 0.73).
- **[O] `susp5`/`susp0` are snapshots, not equilibria**: at tps=30, t=120 (4 s)
  both have sunk to `0.2985`/`0.2987` — the scout's `0.4566`/`0.3383` are the
  2 s values of a still-sinking trajectory, which is exactly how the scout read
  them.
- **[O] Probe artifact, not an engine law**: `r97b_cbedge.gd:187` hardcodes
  `var dt := 1.0 / 60.0`, so the CB cells' scripted forcing (velocity
  integration, platform motion) is 60-tps-scaled no matter what the project
  says. The scout's "`velocity.y` free-integrates to −19.6" is that constant:
  120 ticks × 9.8/60, identical at 30/60/120 tps *by construction*. It is still
  true that the engine reports `wlo=1`/`fl=0` while the capsule rests.
- **[O] A tps=30 under-power trap** (mine, worth recording): at tps=30 the
  `constspd` capsule reaches the end of the ramp by t=120 (4 s) and reports
  `fl=0 rv=2.0,-4.9` — a geometry artifact of comparing at equal *tick* index.
  At t=45/60/90 the same cell holds the pinned `1.8794,-0.684` law.

---

## 6. The GP soft-body law, re-scoped — and Jolt's thin-slab boundary

`r97b_softfloor.gd` reproduces the scout's rig exactly at `thick=0.1`
(regression control: `sf_proj_drop_t01` == `sbx_proj_drop` byte-for-byte) and
sweeps only the slab. GP, centre vertex `v4.y` at t=120, all cells rep-identical:

```
0.10 → -10.83421  fell through      0.25 →  -7.81311  fell through
0.15 →  -9.63194  fell through      0.30 → -12.62384  fell through
0.20 →   0.10180  RESTS             0.40 →  -0.96678 at x=-4.27 (ejected sideways, fell off)
0.50 →   0.09762  RESTS             2.00 →   0.10180  RESTS      8.00 → 0.10050  RESTS
```

- **[O] FALSIFIED as stated.** The scout's §2 headline — "Indexed, GP simulates
  — but does not collide … free-falls through the static floor" — is a property
  of the **0.1 m slab**, not of GodotPhysics. In the identical rig GP's patch
  *rests on the slab* at 0.2 m and at ≥0.5 m.
- **[O] The surviving law is stranger and non-monotone**: GP's soft-body/box
  contact is deterministic and rep-identical but *thickness-selective* — no
  contact at 0.1/0.15/0.25/0.3, contact + sideways ejection at 0.4, stable rest
  at 0.2/0.5/2.0/8.0. Rest height is ~0.05 m **above** the slab top (0.05 → the
  patch centre sits at ~0.10), i.e. GP keeps a contact offset of about one
  patch-vertex spacing. **[?]** the selection rule was not isolated; it is not a
  simple penetration-per-step threshold (a 0.3 m slab is 2.4 steps thick at the
  7.6 m/s impact yet still tunnels, while 0.2 m catches).
- **[O] The ball-through-cloth half of the scout's law survives**: at `thick=2.0`
  GP's 2 kg ball still passes the pinned cloth and rests on the floor (y≈0.16 at
  t=60) while Jolt's bounces off (y≈3.95) and rolls away. That is a
  cloth-vs-rigid property, independent of the slab.
- **[O] Jolt's failures are bounded to the thin slab**: `mass=10` and
  `prec=50` rest at exactly `0.05` on the 2.0 m slab (`sf_proj_jolt_mass_hi_t20`,
  `sf_proj_jolt_prec_hi_t20`), while the scout's 0.1 m arms reproduce
  (`-16.17986` / `-16.17628` at t=120). So the scout's "[?] heavier/finer verts
  vs contact margin" resolves to **slab thickness**: Jolt's soft-body contact is
  penetration-limited, and 0.1 m is below its working range at this impact
  speed — the same class of artifact as GP's, with a different threshold.
- **[O] Dummy stays fully inert** (`v4 = v0 = 0,0,0`, no errors) at every
  thickness.

---

## 7. Unstated mode hunted and *rejected*: deferred deletion is step-granular

Hypothesis: Godot flushes the delete queue at the end of the *process* frame, so
under tick batching a `queue_free()` issued from the first tick of a frame would
not take effect until the next frame — which would make every free-at-tick cell
in the scout's set frame-interleave-sensitive. `r97b_free.gd` queues the free at
a chosen tick and prints the process-frame counter `ff` at every following tick,
so the receipt shows whether the free tick and the next tick share a frame:

```
fg_proj120_ffps60_at8  (2 ticks/frame)  free at t=8 ff=4 → t=9 ff=4 (same frame) alive=false
fg_proj_ffps10_at6     (6 ticks/frame)  free at t=6 ff=1 → t=7 ff=1 (same frame) alive=false
fg_proj120_ffps30_at4  (4 ticks/frame)  free at t=4 ff=1 → t=5 ff=1 (same frame) alive=false
```

- **[O] Hypothesis REJECTED.** The node is already gone on the next tick even
  when both ticks are inside one process frame — the flush happens at the end of
  the physics step (as well as at frame end). Deletion is **step-granular**.
- **[O] The scout's free-at-tick cells are therefore interleave-invariant, not
  lucky**: `nj_proj_freerj/freeb/readd/dupclaim`, `nj_proj_jolt_*`,
  `sbx_proj_freeme`, `nj_proj_repath` are byte-identical between `replay` and
  `ffps30` (2 ticks/frame), and between `tps120` and `tps120ff` (2 ticks/frame),
  8/8 cells each.
- **[O] The base rig cannot discriminate this** — unpinned, every tick has 2–4
  frames of its own, so both flush rules look the same; only the batching modes
  expose it. The `ff` field in the unpinned `freegrain` cells is the one
  wall-clock counter that legitimately differs across reps (3/11 cells).

---

## 8. What survived untouched, and the backend split

All **64** of the replayed scout cells that are not in §2 are byte-identical to
the scout's receipts in `replay`, `load16` **and** `ffps60` (the 67-cell list is
in `cmp.py`; the tags are reproduced below by group):

- **§0 ClassDB / crash / XR**: `cls_proj`, `cls_proj_jolt`, `iso_xrs_1`,
  `iso_xrs_jolt`, `iso_clean`, `xr_same`, `xr_keep`, `xr_dbl` — all 44 classes
  exist, `can_instantiate=false` only for `Joint3D`, `XRInterface`,
  `WebXRInterface`, `PhysicsServer3D`, `PhysicsDirectSpaceState3D`; the XRServer
  identity (`identical=false`), the leak = clean exit + `Interface not found` ×2
  + ObjectDB warning (1 leaked, 2 for `dbl`), and the free = `rc=134` split.
- **§1 Joint3D lattice** (GP + Jolt): `bind`, `bindpre`, `bindnode`, `badpath`,
  `nob`, `getrid`, `freerj`, `freeb`, `readd`, `repath`, `dupclaim`, `hmot`,
  `hlim`, `njx_exclx_on/off`, `njx_clampbig`, plus `nj_proj_dummy_getrid` —
  binding timing free, `get_rid()` valid at construction (`prerid=true` GP+Jolt,
  `false` Dummy), bad/absent `node_b` world-pins A, non-body `node_a` silently
  inert, hinge motor/limit params, exclusion and clamp supplements, and
  node-level teardown clean 6/6 on GP and Jolt (Dummy was replayed for `getrid`
  only).
- **§4 DSS**: `ray_areas`, `qx_ray_areason`, `ray_bf_upon`, `ray_hfi_in`,
  `maxres` (GP + Jolt for `maxres`) — `collide_with_areas` default false for
  rays (miss without, hit at 2.75 with), `hit_from_inside` on an inside ray, and
  the backend-ordered `maxres` survivors.
- **§5 CharacterBody3D**: `constspd`, `float`, `updir`, `margin_hi`,
  `plat_ride`, `maxslides` (GP + Jolt where the scout swept both) — `FLOATING`
  never reports floor (`fl=0 wlo=1`), `up_direction=+Z` reclassifies floor as
  wall, the GP/Jolt `plat_ride` split, GP `maxslides` jitter vs Jolt quiet, and
  the GP/Jolt `margin_hi` hover gap.
- **§2/§3 soft body and vehicle**: `sb_proj_drop` (unindexed, the
  `godot_soft_body_3d.cpp:148` rejection), `sb_proj_nomesh`,
  `sbx_proj_jolt_mass_hi`, `sbx_proj_jolt_prec_hi`, `sbx_proj_freeme`,
  `vh_proj_drop`/`vh_proj_jolt_drop` (byte-identical settle 0.7299),
  `vh_proj_drive`/`vh_proj_jolt_drive` (tumble + chaotic-tail divergence),
  `vh_proj_susp5`/`vh_proj_susp0`.
- **Dummy** is degenerate everywhere the scout said so.

**Not replayed by this seat** (so: neither confirmed nor falsified here) —
`methods.gd`, `slider`/`cone`/`g6`/`prio_l`/`prio_r`/`clampbig0`, the DSS
`pt_*`/`is_*`/`cs_*`/`cm_*`/`ri_mask`/`excl_mut`/`excl_id`/`ray_mask*`/
`ray_bf_*off` cells, the CB `snap_*`/`ceil_*`/`blockwall*`/`realvel`/`recovery`/
`stop_on_ceil`/`constspd_off`/`wallslide` cells, and `sbx_*_impulse`/
`pt_impulse`/`ray`. The scout's own null-pair findings there are untouched.

---

## 9. Authorability deltas

- **Armable as-is** (survives every attack): the joint node lattice, the DSS
  flag matrix, the CB edge laws except the scout's listed null pairs, the
  XRServer crash/no-crash envelope (66/66 `rc=134` vs clean leak), the Jolt
  thin-slab failure *as a thin-slab statement*, `maxres` ordering.
- **Must be re-scoped before arming**:
  - "GP soft body does not collide" → **"GP soft-body/box contact is
    thickness-selective: no contact on a 0.1 m slab, rest on 0.2 m and ≥0.5 m,
    ejection at 0.4 m"** (§6). Any fixture that pins GP's cloth to fall through
    must pin the slab, not the engine.
  - The pinned-cloth cells → **pin the phase**: `pf=0` (pins before the first
    step) is deterministic and is what the scout's receipts recorded; `pf=1` is
    the other deterministic branch; a fixture that does not control it is armed
    (§2).
  - `safe_margin` hover and the vehicle settle height → **pin the tps**
    (±3 mm and 0.7298/0.7316 across 30/60/120), or state them as sim-time laws.
  - The CB cells' scripted forcing is 60-tps-scaled by the probe
    (`cbedge.gd:187`); do not read tps-invariance out of those numbers.
- **Still not armable**: `solver_priority` dominance, `hit_back_faces` true
  semantics, `floor_snap_length` discrimination, `recovery_as_collision=false`
  (all unchanged from the scout), plus the GP thickness-selection rule **[?]**.

---

## 10. Host cleanup and writes

- `pgrep -x yes` → **0**; no `r97-boundary` godot process and no driver process
  alive after the last arm (`run_arms.log` ends `### all arms done`). Every
  child was `timeout -s KILL 25` bounded; there are **no `rc=137`** children.
- Other lanes' processes (`r92-verify2`, `r93-baseline2`, `r99-boundary`,
  2D `r92-scout` hogs) were observed and left untouched.
- Writes: `corpus/live/r97-boundary/**` (gitignored) + this report. No
  `corpus/fixtures/**`, no tracked-tree edit other than this file, no commits.
  HEAD was `75739bc` when the seat started and is `455d9b1` at seat end —
  other lanes committed while this seat ran (`275bcae r94 boundary`,
  `d41b48d r100 boundary`, `455d9b1 r93 baseline-r2`). `git status` also shows
  ` M corpus/fixtures/run_battery.py` and two untracked `corpus/fixtures/r93_*`
  files, all written by the concurrently running verify/baseline lanes at
  16:50–16:54; **none of them are this seat's**.

## Reproducing

```bash
cd corpus/live/r97-boundary
sh run_arms.sh              # replay, ffps60, softfloor, mode, tps30, tps120,
                            # tps120ff, load16 (16 hogs), load32 (32 hogs)
python3 cmp.py --scout      # 64/67 vs the scout's receipts
python3 cmp.py --reps       # per-arm rep identity
python3 cmp.py --arm replay --vs ffps60
python3 cmp.py --arm replay --vs load16
```

`RECEIPTS.md` carries the probe shas, the arm table, the declared
normalizations and the verbatim key receipts.
