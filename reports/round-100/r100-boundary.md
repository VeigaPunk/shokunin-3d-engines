# r100b boundary — attacking the r100 rate law under extreme contention

Lane: g3d · engine `4.7.2.stable.arch_linux.ed1daf0bf` (`/usr/bin/godot`) ·
`--headless --script` SceneTree runs · tps 30/60/120 · backends GodotPhysics
(`proj`), Jolt (`proj_jolt`), Dummy (`proj_dummy`).

Falsification seat on `reports/round-100/r100-scout.md`. Method: verbatim
replays of the scout's own probe (byte-identical copies, sha in §10), a
contention ladder (12/32/96 added CPU hogs on a 32-core host that was *already*
2–3.5× oversubscribed by other lanes), a per-process starvation arm
(`taskset` cpuset + pinned hogs, up to 5.8× slowdown), a deterministic
heavy-frame arm (`--frame-delay 200`), and an unstated-mode hunt over the
engine's CLI surface.

Evidence: `corpus/live/r100-boundary/` (gitignored) — `probes/` (5 byte-identical
copies of the scout's probes + `r100b_modes.gd`), `driver.py`, `starve.py`,
`audit.py`, `classify.py`, `stability.py`, `tables.py`, `replay_match.py`,
`runs/` (**1348 children**, 4 sidecars each), `manifest.sha256` (5445 entries),
`*_batch.log`. Scratch only; the sole tracked-tree write is this report.

Confidence: **[O]** receipt-pinned observation, **[I]** inference, **[?]** unknown.

---

## 0. Verdicts on the scout's pins

| # | scout claim | verdict | receipt |
|---|---|---|---|
| 1 | §1 "the interleave is exact: `n_pr = 120·N/60 + 1` for N ≥ 60" | **FALSIFIED (arithmetic)** — the *interleave* is exact, the *formula* is not; the scout's own receipts violate it (N=90: 180≠181, N=120: 239≠241, N=240: 478≠481) | §8, `T1` |
| 2 | §1 "process delta becomes exactly 1/N" | **FALSIFIED at the rig default** — true only with `physics_jitter_fix=0`; at the rig's default 0.5 the delta is jitter-scaled (N=119 frame 2 `d=0.008473389`, N=121 all frames `d=1/120`) | §3.3, `r100b_X_ffps119{,_jit0}` |
| 3 | §1 "wall-clock independence — the pinned receipt is a pure function of the flags" | **CONFIRMED, strengthened** — byte-identical at 12/32/96 added hogs, under 1-core starvation (5.8× slowdown), and under 200 ms/frame delay, across GP/Jolt/Dummy | §2 |
| 4 | §1 "the physics does not move (traj `2311ff14cd04c227`)" | **CONFIRMED** — same hash in every pinned cell and every load level, *and* in the unpinned base runs at L0/L12/L32/L96 | §2.3 |
| 5 | §1 `ifr` is the tick phase; N ≥ tps ⇒ `0.000000` at every physics row | **CONFIRMED** (PH rows); PR rows carry the intra-tick phase (0, 1/N, …) | `T5` |
| 6 | §2 "first frame is the only frame that does not carry 1/N" / "N < tps transient byte-stable" | **REFINED + CONFIRMED** — `d0` is a deterministic two-regime function of N/tps (20/20 cells), not wall-clock (`--frame-delay 200` leaves it byte-identical at N=5/30/150/240/300/600) | §3.1, §3.2 |
| 7 | §2 "[?] the N < tps transient's generating formula was not derived" | **PARTIALLY CLOSED** — with `jitter_fix=0` the whole transient collapses to `d = 1/N` from frame 1; with 0.5 the startup offset is `a(N)=fpt[0]` with a named best fit and one exception | §3.2, §3.3 |
| 8 | §3 "`--quit-after` is a frame bound; with `--fixed-fps` it is a tick bound of M·60/N" | **CONFIRMED as a frame bound; the tick budget is M·tps/N ± 1 (phase)** — exact at N = tps (M=1,7,30,100,20000,100000 all give M ticks), phase-dependent elsewhere | §5, `T4` |
| 9 | §3 "`--quit-after 0` disables the bound" | **CONFIRMED** (20 000-tick twin byte-identical on GP *and* Jolt) | §5 |
| 10 | §4 companions (`--time-scale` sim-time only, `--max-fps` not exact, `--delta-smoothing`/`--frame-delay` inert, jitter-fix live under pinned rates, cap inert) | **CONFIRMED and composed** — new composition laws for fixed-fps × time-scale, × max-fps (both orders), × delta-smoothing, and cap inert at 60 steps/frame | §7 |
| 11 | §7.5 Jolt warning "5/552 receipts, thread-pool saturation when frames are dense" | **CONFIRMED as the only rep-difference, but the rate is load-dependent**: 38 % at L0 ambient, 55 % at +12 hogs, 45 % at +32, 62 % at +96, 92 % under cpuset starvation | §6 |
| 12 | §8 "every `--fixed-fps` cell is byte-identical across its reps except the two Jolt warning cells" | **CONFIRMED, strengthened** — across 1348 children there is **zero** scheduler-field rep-instability in any cell where the pinned rate actually took effect; the only 4 pinned-but-unstable cells are inert flags or wall-clock emitters | §10.1 |
| 13 | §7.1 "engine args go before `--script`; flags after `--` are inert" | **CONFIRMED verbatim** (`RS_END n_pr=292 … fpt=[1:1, 2:68, 3:50, 4:1]`, i.e. unpinned) | §7 |
| 14 | §7.6 "rc=0 is blind" | **CONFIRMED + extended** — `--quiet` yields a **0-byte receipt at rc=0**; `--check-only` a 101-byte receipt at rc=0; `--write-movie` a SIGSEGV | §7 |

**Nothing the scout pinned as a *measurement* was overturned.** What broke is one
arithmetic formula, one "exactly 1/N" over-claim, and several "5/552"-style
statements that were properties of their load level, not of the flag.

---

## 1. Corpus, load, and how to reproduce

```
cd corpus/live/r100-boundary
python3 driver.py --batch replay   --jobs 8                  # 237 children, L0 ambient
python3 driver.py --batch modes    --jobs 6                  # 186  unstated modes
python3 driver.py --batch extra    --jobs 6                  # 124  frame-delay twins, qa ladder
python3 driver.py --batch tps      --jobs 4                  #  54  tps 30/120
python3 driver.py --batch ladder12 --jobs 8 --hogs 12        #  84
python3 driver.py --batch ladder32 --jobs 8 --hogs 32        #  84
python3 driver.py --batch extreme  --jobs 8 --hogs 96        #  96
python3 driver.py --batch rt       --jobs 6                  # 108
python3 driver.py --batch area     --jobs 6                  #  54
python3 driver.py --batch life     --jobs 6                  # 144
python3 driver.py --batch census   --jobs 3                  #  18
python3 starve.py --reps 6 --jobs 3                          # 144  cpuset starvation
python3 audit.py && python3 stability.py && python3 classify.py r100b_L0_ \
  && python3 replay_match.py && python3 tables.py
```

Every child is `timeout -s KILL 25` bounded (the `noquit_unbound` life control
and the two degenerate-N cells use 12 s) and accounted for by a `.exit`
sidecar (1348/1348). Load (32 cores, `loadavg` recorded per batch in
`*_batch.log`): **L0 27.6–108.2** (other lanes' batteries ran throughout),
**L12 94.5**, **L32 88.8**, **L96 89.2→127.4**, **starve 112.6→106.8**. The
"L0" arms are therefore not an idle baseline: they range from 0.9× to 3.4×
oversubscription of the 32 cores, and the L96 arm reaches ~4×.

Children: **1320 rc=0, 21 rc=137, 3 rc=134, 4 rc=9**. The 21 rc=137 are 18
declared `noquit_unbound` controls (3 backends × 6 reps) + 3 Jolt
`quit0_ffps60` children (see §5); the 4 rc=9 are the two degenerate-N cells ×2
(the probe's own 400 001-frame guard); the 3 rc=134 are `--write-movie` (§7).

---

## 2. The determinism law under contention

### 2.1 Verbatim replay (L0)

Paired by *exact command* (`replay_match.py`: project, probe kind, engine args,
user args), wall-clock lines and the argv echo dropped, probe filename
normalised inside engine error strings:

| verdict | pinned | unpinned |
|---|---|---|
| IDENTICAL | **402** | 1 |
| DIFF | **3** (all Jolt `quit0_ffps60`, rc=137 — see §5) | 137 |

`classify.py` on the same corpus (Jolt warning lines allowed to differ):
**136 IDENTICAL / 78 SCHED-FIELD / 23 WARN-ONLY**; every SCHED-FIELD child is
unpinned except the 3 timeout-truncated Jolt children. The 75 unpinned
SCHED-FIELD children are the r92 idle-multiplicity defect, unchanged.

### 2.2 Contention ladder — the law survives

`T2` (load-level identity, byte compare) — pinned cells only:

```
project+mode            L0    L12   L32   L96
proj_ffps5              same  same  same  same
proj_ffps30             same  same  same  same
proj_ffps60             same  same  same  same
proj_ffps120            same  same  same  same
proj_ffps240            same  same  same  -
proj_quit30_ffps60      same  same  same  same
proj_base (unpinned)    same  DIFF  DIFF  DIFF   <- the r92 defect, by design
proj_jolt_ffps*         same  DIFF* DIFF* DIFF*  <- *warning-only, see §6
```

At L96 the added 96 hogs drove `loadavg` from 89 to **127 on 32 cores**; the GP
pinned receipts did not move a byte. The Jolt row of that table is the warning
line and nothing else: re-comparing with the warning pair stripped gives `same`
at every level for all six cells. The exact per-cell picture at L12/L32/L96 is
`jolt_ffps120` DIFF at all three, `jolt_ffps240` at L12/L32, `jolt_ffps30` at
L12/L32, `jolt_ffps5` at L32, and `jolt_ffps60` + `jolt_quit30_ffps60`
byte-identical everywhere.

### 2.3 Starvation arm (a different mechanism)

`starve.py`: the godot child and all its threads confined with
`taskset -c 3` (then `3,4`) while 3/8/12 busy-loop hogs saturate that cpuset.

```
proj_ffps60        S0.r1..r6 same (834–1045 ms)   S1.r1..r6 same (1611–2016 ms)
                   S2.r1..r6 same (1104–2070 ms)  S3.r1..r6 same (2727–5198 ms)
proj_ffps5         S0..S3 24/24 same (max 7558 ms)
proj_ffps30        S0..S3 24/24 same (max 7382 ms)
proj_quit30_ffps60 S0..S3 24/24 same (max 7787 ms)
proj_jolt_ffps60   S0..S3 24/24 same after dropping the warning pair (92 % warned)
proj_base          S0.r1 same, S0.r2..r6 + S1..S3 all DIFF  (unpinned, by design)
```

The S3 arm runs a 0.9 s workload in 5.2 s (5.8× slowdown) and the receipt —
including the first-frame delta and the whole `RS_END` line — is unchanged.

### 2.4 Deterministic heavy frames

`--frame-delay 200` makes every frame take 200 ms of real time. Twin cells with
identical N and identical M=40, with and without the delay, are **byte-identical
in all six pairs** (N = 5, 30, 150, 240, 300, 600), e.g.

```
ffps600_qa40            BM_PR n=1 pf=0 d=0.008333333 ifr=0.500000 ts=1.000000
ffps600_fdelay200_qa40  BM_PR n=1 pf=0 d=0.008333333 ifr=0.500000 ts=1.000000
both                    BM_END n_pr=40 n_ph=4 pf=4 ff=40 fpt=[4:1, 10:3] traj=5226ca80040554e1
```

This is the sharpest single result of the round: the startup-frame delta and the
N < tps transient are **not** real-time derived, because a 200 ms/frame real
delay does not move them.

---

## 3. The startup frame, derived

### 3.1 `d0` (first-frame process delta) is a two-regime function of N/tps **[O]**

For N ≥ tps: `d0 = 1/tps` if `N ≤ 2·tps`, else `d0 = 1/(2·tps)`. 20/20 cells:

| tps | N | d0 | 1/tps | 1/(2·tps) |
|---|---|---|---|---|
| 60 | 45, 59, 60, 61, 75, 90, 119, 120 | 0.016666667 | 1/60 | 1/120 |
| 60 | 121, 150, 180, 240, 300, 600, 999999999 | 0.008333333 | 1/60 | 1/120 |
| 30 | 30, 60 | 0.033333333 | 1/30 | 1/60 |
| 30 | 120, 240 | 0.016666667 | 1/30 | 1/60 |
| 120 | 120, 240 | 0.008333333 | 1/120 | 1/240 |

For N < tps the first frames are the scout's transient (§2 there), reproduced
byte-for-byte here and still byte-stable under every load arm.

### 3.2 The startup offset `a(N) = fpt[0]` **[O]**, best fit **[I]**

`a` = number of process frames that elapse before tick 1. Measured (tps=60,
default jitter fix): 45→0, 59→0, 60→0, 61→0, 75→0, 90→0, 119→0, 120→0, 121→1,
150→1, 180→1, 240→1, 300→2, 600→4; (tps=30) 60→0, 120→1, 240→4;
(tps=120) 120→0, 240→0. Best fit `a = ceil(N/(2·tps)) − 1` holds in 20/21 cells;
the named exception is tps=30, N=240 (a=4, predicted 3). With the jitter fix
off the offset becomes `a = ceil(N/tps) − 1` (7/7 cells: 45→0, 75→1, 119→1,
121→2, 150→2, 240→3, 600→9) and the first-frame delta becomes exactly `1/N`.
The exact generating formula is still **[?]** — but it is now bounded to those
two regimes, and the total-frame count follows from it:

`n_pr = a(N) + (n_ticks−1)·N/tps + 1` for integer N/tps (exact on every cell),
with the fractional case giving the floor/ceil `fpt` split the scout tabulated.

### 3.3 `physics_jitter_fix` moves the *delta*, not just the phase **[O]**

```
proj_jit0   --fixed-fps 119  BM_PR n=1..8 all d=0.008403361  (= 1/119 exactly)
                             BM_END n_pr=239 n_ph=120 fpt=[1:2, 2:118]
proj (jit=.5) --fixed-fps 119  n=1 d=0.016666667  n=2 d=0.008473389  n=3..8 d=0.008403361
                             BM_END n_pr=239 n_ph=120 fpt=[0:1, 2:119]
proj (jit=.5) --fixed-fps 121  n=1..8 all d=0.008333333  (= 1/120 = 1.00833/121)
proj_jit0   --fixed-fps 121  n=1..2 d=0.008264463  (= 1/121 exactly)
```

Both receipts are rep-stable in both jitter settings, so this is not an
instability — it is a **correction to the headline**: "process delta becomes
exactly 1/N" holds only with `physics_jitter_fix=0.0`; at the rig's default 0.5
the engine's jitter compensation scales the process delta (observed ×1.00833 at
N=119/121, i.e. exactly the values that make `1/121` print as `1/120`). This is
the quantitative reason behind the scout's directive 3 ("pin `physics_jitter_fix`
explicitly").

---

## 4. tps generalization **[O]**

The law is `frames per tick = N/tps` — the scout only ever measured tps=60.

| project | mode | n_pr | n_ph | fpt | traj |
|---|---|---|---|---|---|
| tps=30 | ffps30 | 120 | 120 | `[0:1, 1:119]` | `c9625c56942ce36c` |
| tps=30 | ffps60 | 239 | 120 | `[0:1, 2:119]` | `c9625c56942ce36c` |
| tps=30 | ffps120 | 478 | 120 | `[1:1, 4:119]` | `c9625c56942ce36c` |
| tps=30 | ffps240 | 957 | 120 | `[4:1, 8:119]` | `c9625c56942ce36c` |
| tps=30 | ffps10 | 41 | 120 | `[0:80, 1:40]` | `c9625c56942ce36c` |
| tps=120 | ffps60 | 61 | 120 | `[0:60, 1:60]` | `c20df6e28a22902f` |
| tps=120 | ffps120 | 120 | 120 | `[0:1, 1:119]` | `c20df6e28a22902f` |
| tps=120 | ffps240 | 239 | 120 | `[0:1, 2:119]` | `c20df6e28a22902f` |
| tps=120 | ffps30 | 31 | 120 | `[0:90, 1:30]` | `c20df6e28a22902f` |

Two consequences:
- **The trajectory hash is a function of the tick delta alone.** `tps=30`
  reproduces the `--time-scale 2` hash `c9625c56…`, `tps=120` the
  `--time-scale 0.5` hash `c20df6e2…` — i.e. `traj = f(time_scale/tps)`.
- **Backend-inert**: `proj_tps30_jolt` / `proj_tps120_jolt` reproduce the GP
  `RS_END` lines byte-for-byte on the pinned modes.
- `--quit-after` follows tps too: `quit30_ffps60` = 15 ticks at tps=30 and
  59 ticks at tps=120 (§5).

---

## 5. `--quit-after` **[O]**

At N = tps it is an exact tick budget: `M` frames = `M` ticks for
M = 1, 7, 30, 100 (and 20 000 / 100 000 in the unbound cells). Away from N = tps
the budget is `M·tps/N` rounded by the engine's accumulator phase:

| tag | N | M | n_ph | M·tps/N |
|---|---|---|---|---|
| qa31_ffps45 | 45 | 31 | 40 | 41.33 |
| qa31_ffps75 | 75 | 31 | 24 | 24.80 |
| qa101_ffps90 | 90 | 101 | 67 | 67.33 |
| qa31_ffps120 | 120 | 31 | 16 | 15.50 |
| qa31_ffps150 | 150 | 31 | 12 | 12.40 |
| qa31_ffps180 | 180 | 31 | 10 | 10.33 |
| qa31_ffps240 | 240 | 31 | 8 | 7.75 |
| qa61_ffps240 | 240 | 61 | 15 | 15.25 |
| qa241_ffps240 | 240 | 241 | 60 | 60.25 |
| qa121_ffps120 | 120 | 121 | 61 | 60.50 |

Deterministic per (N, M) and rep-stable; not a floor or a ceil of `M·tps/N`
(see the 90/31 and 120/31 rows), because the startup offset `a(N)` of §3.2
shifts the phase. **[?]** the exact closed form.

`--quit-after 0` disables the bound: the bounded twin
(`--ticks=20000 --quit-after 0`) ends at `n_pr=n_ph=20000`,
`fpt=[0:1, 1:19999]`, `traj=1653f54d45d1d878`, **byte-identical on GP and
Jolt**. The scout's 100 000-tick Jolt cell needs ~20.5 s unloaded and exceeded
this seat's 25 s bound under load (rc=137, 3 children) — declared, not a law
failure; the boundary is closed by the 20 k-tick twin.

---

## 6. Backends and the Jolt warning **[O]**

- `RS_END`/`BM_END` is identical GP ↔ Jolt on every pinned mode (including the
  trajectory hash); Dummy differs only in the hash (`a2d4de09077612bf`,
  `y=5.000000 vy=0.000000` at every tick — the r89 degenerate).
- The job-system warning is the **only** rep-difference anywhere in the pinned
  corpus. Its rate is a function of load, not of the flags:

| arm | jolt children | warned | rate |
|---|---|---|---|
| L0 (ambient 28–98) | 63 | 24 | 38.1 % |
| +12 hogs | 42 | 23 | 54.8 % |
| +32 hogs | 42 | 19 | 45.2 % |
| +96 hogs (load 127) | 48 | 30 | 62.5 % |
| cpuset starvation | 24 | 22 | 91.7 % |

The scout's "5/552" was a property of their (lighter) host load. Verbatim
(normalised) warning:

```
WARNING: Jolt Physics job system exceeded the maximum number of jobs. This should not happen. Please report this. Waiting for jobs to become available...
     at: CreateJob (modules/jolt_physics/spaces/jolt_job_system.cpp:123)
```

---

## 7. Unstated modes (the hunt)

All of these are new relative to the scout's sweep. Each row is a cell in
`runs/`; receipts are rep-stable unless noted.

**Silent no-ops / parse traps**

- **`--fixed-fps=60` (equals form) is silently inert.** `argz=3`, receipt is the
  *unpinned* histogram: `BM_END n_pr=292 n_ph=120 ff=292 fpt=[0:1, 2:67, 3:51, 4:1]`.
  Any harness that writes `--fixed-fps=<N>` is measuring the default.
- **Duplicate `--fixed-fps 30 --fixed-fps 60`** → last wins, no error
  (receipt identical to plain `ffps60`).
- **`--fixed-fps 59.94`** → truncated to 59 (`n_pr=118`, `fpt=[0:3, 1:117]`).
- **`--fixed-fps` after `--`** → inert (scout hazard 1, re-confirmed).

**Degenerate N (all rep-stable, all documented for the first time)**

- **`--fixed-fps 0`** → `d=inf`, `ifr=-nan`, **physics never steps**
  (`n_ph=0`), and the run never self-quits (ran to the probe's 400 001-frame
  guard, rc=9, `traj=e3b0c44298fc1c14` = sha256 of the empty string). It does
  *not* disable the flag the way `--quit-after 0` does.
- **`--fixed-fps -5`** → the frame slice is floored at **1 µs**:
  `n_pr=400001 n_ph=24 fpt=[16666:8, 16667:16]` — physics advances one tick per
  ~16 667 frames, deterministically.
- **`--fixed-fps 999999999`** → first frame 8.333 ms then the 1 µs floor;
  `n_ph=0` inside 20 frames.

**Composition (never measured by the scout)**

- **`--fixed-fps N` × `--time-scale s`**: process delta `s/N`, physics delta
  `s/tps`, frames/tick `N/tps` unchanged; `traj = f(s/tps)` —
  `ffps60_ts05` → `c20df6e28a22902f` (the unpinned ts05 hash),
  `ffps60_ts2` → `c9625c56942ce36c` (the ts2 hash), `ffps60_ts4` → `45a5210f3d1ca654`.
  Also `ffps30_ts2` → `fpt=[0:60, 1:60]` (same as ffps30), traj = ts2's.
- **`--fixed-fps N` × `--max-fps M`**: fixed-fps wins in both orders; `maxfps`
  readback = M; receipt identical to plain `ffps60`.
- **`--fixed-fps 60` × `--delta-smoothing enable`** (the scout only tested
  `disable`): inert, receipt identical.
- **`physics/common/physics_interpolation=true`** (r92 §7.8 residue): the pinned
  receipt stays rep-stable and the trajectory is unchanged, but the **startup
  phase shifts by one frame** — `ip_ffps120` `n_pr=240` / `fpt=[1:1, 2:119]` vs
  `ffps120` `n_pr=239` / `fpt=[0:1, 2:119]`; `ip_ffps5` `n_pr=10` vs 11. The
  unpinned histogram also changes (`fpt=[0:1, 2:69, 3:49, 5:1]` vs base's
  `[2:69, 3:50, 4:1]`).

**`max_physics_steps_per_frame` (cap) — inert at a stronger point than tested**

- `--fixed-fps 1` performs **60 physics steps inside one frame** with
  `cap=1` and with `cap=8`: both give `n_pr=2 n_ph=120 fpt=[0:119, 1:1]
  steps_max=60` (and `--fixed-fps 5` gives 12; `--fixed-fps 5 --quit-after 40`
  gives `n_ph=479` in 40 frames with `steps_max=12`). No clamping in this rig,
  at 5× the step count the scout tested.

**Lifecycle / main-loop flags**

- **`--quit`** = quit after the first *iteration*, not the first tick: at
  `ffps60` that is `n_pr=1 n_ph=1`; at `ffps5` it is **11 ticks in one frame**
  (`n_ph=11 fpt=[0:11] steps_max=11`).
- `--single-threaded-scene`, `--disable-render-loop`, `--render-thread separate`,
  `--disable-vsync`, `--audio-driver Dummy`, `--main-loop SceneTree`,
  `--log-file <path>` → scheduler-inert (receipt identical to `ffps60`).
- **`--write-movie <f>` in headless → SIGSEGV** (rc=134), even though the docs
  say `--fixed-fps` is forced by it:
  `Movie Maker mode enabled, recording movie in 1152×648 @ 60 FPS...` then
  `ERROR: Parameter "t" is null.` / `at: texture_2d_get (./servers/rendering/dummy/storage/texture_storage.h:110)`
  / `handle_crash: Program crashed with signal 11`. The documented
  "fixed-fps is forced" mode is unusable in this rig.

**Output-surface flags (byte-comparability hazards)**

- **`--quiet` → a 0-byte receipt at rc=0** (the probe's own `print()`s are
  silenced).
- **`--check-only`** → 101 bytes, the probe never runs, rc=0.
- **`--benchmark`** (editor build) → injects wall-clock numbers into stdout
  (`- Main::Setup: 16.224 msec.`, `- Servers: 407.767 msec.`, 64 `msec.` lines;
  they differ per rep) while the probe receipt underneath stays identical.
- `--verbose` (+649 bytes of engine chatter), `--print-fps` (FPS/vsync lines),
  `--no-header` (banner removed) → receipt content unchanged, byte-comparison
  affected.

---

## 8. Corrected arithmetic

The scout's headline formula `n_pr = 120·N/60 + 1` (N ≥ 60) is contradicted by
their own receipts:

| N | formula | receipt | correct (this seat) |
|---|---|---|---|
| 90 | 181 | 180 | `a + 119·N/tps + 1` = `0 + 178.5→179 + 1` |
| 120 | 241 | 239 | `0 + 238 + 1` |
| 240 | 481 | 478 | `1 + 476 + 1` |
| 600 | 1201 | 1195 | `4 + 1190 + 1` |

The exact relations that survive every cell measured here (N ≥ tps, integer
N/tps): **`fpt[k] = N/tps` for k ≥ 2**, `fpt[0] = a(N)` (§3.2), and
**`n_pr = a(N) + (n_ticks−1)·N/tps + 1`**. For fractional N/tps the per-tick
count is the floor/ceil split (N=45 → `[0:31, 1:89]` at jit=0; N=150 →
`[1:1, 2:60, 3:59]`; N=600 → `[4:1, 10:119]`), and the interleave is still a
pure function of N and tps.

The `ifr` sets (`T5`, PH rows only) confirm the scout's reading and add the
two-regime structure: `ffps60 → {0.000000}`; `ffps90 → {0.000000, 0.333333}`;
`ffps120 → {0.000000}` and `ffps240 → {0.000000}` at every sampled physics row;
N < tps → `ffps5/ffps10 → {0.5, 1.0}`, `ffps30 → {0.5, 0.75, 1.0}` — small
deterministic sets, versus 9–14 scattered values in every unpinned mode
(`base` 9 values, `maxfps60` 9 values including a `0.900440…0.900880` cluster).

---

## 9. Hazards for lane fixtures (superseding/adding to the scout's §7)

1. Engine args before `--script`; `--fixed-fps` after `--` is inert (scout 1,
   re-confirmed). **The `=` form is also inert** — use the space form only.
2. `--quit-after M` is frames; `--quit-after 0` disables; the tick budget is
   `M·tps/N ± 1` unless `N = tps`.
3. Wall-clock fields must live on their own line (scout 3) — and beware
   `--benchmark`, which injects wall-clock msec lines anywhere.
4. `_finalize()` runs after the tree is freed (scout 4, re-confirmed).
5. Jolt's job-system warning is load-dependent (38 %→92 % across my arms), not
   a fixed 5/552; match message text, never line numbers.
6. rc=0 is blind (scout 6) — **and `--quiet` produces an empty receipt at
   rc=0**, `--check-only` a 101-byte receipt at rc=0, `--write-movie` a crash.
7. **Pin `physics_jitter_fix=0.0` if any fixture asserts a process delta**:
   at the default 0.5 the delta is jitter-scaled (N=119/121 measured), and the
   startup offset halves. Pin it in the *project file*; it is not a CLI flag.
8. **`--fixed-fps 0`/negative are not "off"**: they freeze physics (0) or floor
   the slice at 1 µs (negative). Never use them as "no pin".
9. `physics/common/physics_interpolation=true` shifts the pinned startup phase
   by one frame — pin it explicitly in fixtures that key on `fpt`/`n_pr`.
10. The first frame carries `1/tps` (N ≤ 2·tps) or `1/(2·tps)` (N > 2·tps), not
    `1/N`; count ticks, not frames, when N ≠ tps.

---

## 10. Rep identity, corpus, manifest

### 10.1 Rep identity across all 1348 children **[O]**

`stability.py` (rep1 vs all other reps, wall lines dropped, then the Jolt
warning pair dropped): **268 tags STABLE, 26 WARN-ONLY, 56 OTHER**. All 56
OTHER tags are unpinned by construction, except four that are pinned but
knowingly non-deterministic:

| tag | why |
|---|---|
| `M_afterdashes_ffps60` | the flag is after `--` → inert → unpinned run |
| `M_ffpseq60` | `--fixed-fps=60` equals form → inert → unpinned run |
| `M_ffps60_benchmark` | the BENCHMARK block is wall-clock data (the probe receipt is identical 3/3) |
| `M_ffps60_writemovie_qa10` | SIGSEGV backtrace (random load addresses) |

**There is no scheduler-field rep-instability in any cell where the pinned rate
took effect** — across GP/Jolt/Dummy, tps 30/60/120, 6 load arms, 40+ flag
combinations.

### 10.2 Verbatim-replay deltas vs the scout's receipts

`replay_match.py` pairs by exact command: **402 pinned children identical, 3
pinned children differ (Jolt `quit0_ffps60`, rc=137 timeout, §5), 137 unpinned
children differ (the r92 idle-multiplicity defect), 1 unpinned child identical.**
The probe filename differs inside engine error strings (`SceneTree(r100b_area.gd)`
vs `SceneTree(rs_area.gd)`) and inside `RS_ARGV`/`CLS_ARGV`; both are
normalised out and disclosed here.

### 10.3 Manifest

`corpus/live/r100-boundary/manifest.sha256` — 5469 entries (every file except
the manifest itself), 5470 files, 25 MB total. Probe shas (the five
byte-identical copies of the scout's probes, verified equal to
`corpus/live/r100-scout/probes/rs_*.gd`):

```
c61025594deff49dfbd7819376a9e6379dca6efb5c6d7b0aa149aa79cbc86849  probes/r100b_sched.gd
8bfd76adf5ae5551eb870524c7677ea24755ac068f71b1d1936e1fd298cb2585  probes/r100b_rt.gd
a577d6265f78f1ff337b09a7169a236044b0bd2b16ddfdf416d90e9364d4469d  probes/r100b_area.gd
427fc7d159f524da345c0b684b13c6d66690aa59f7e9afc6f73bbab1fb1ad760  probes/r100b_life.gd
0adf98aadd38cdc62b60742e3fb393566586cc531706edc3b3ebb98df2a45e03  probes/r100b_cls.gd
249c0caf8ac4a1d5270beccadd65d99d0083a1db77264d56958a8ec0ac884896  probes/r100b_modes.gd   (new)
d2936007c4e3508438ffbecc52d1a9c6db871facb4e2fd85f804ebdcf44111fc  driver.py
3eb414041a870b6718026dd467008a9f42497c098b3726f0708ac7c0ce4d6953  starve.py
2914e56f003d1b9c8752d13732dfb55ea9a4a1304d07a72b83930fa8ef048ce2  audit.py
fd7d580513d39380c1ec802814890b6cf050ca5260feeb0b86b42ea9bad0f6f9  classify.py
2bfab1191f430303eb6e9238a31adb94c34a8af031da1268e5176cb0aa71dbc7  stability.py
9f027f271a92fe267d5e98f9bfc98c507e960d5865eb42244ab928976563154f  tables.py
f082e30d352666c2265baec2c48976485c6c2c261a48631608fe3e1b01dd81e2  replay_match.py
```

---

## 11. What I could not break, and what remains unknown

**Survived every attack** (12/32/96 hogs to load 127 on 32 cores, 1-core
starvation to 5.8× slowdown, 200 ms/frame deterministic delay, tps 30/60/120,
three backends, 40+ flag combinations): the pinned interleave, the pinned
trajectory, the pinned receipt's byte-identity across reps, the `ifr` tick-phase
reading, the r92 frame-boundary law under a pinned rate (every pinned `rt` cell
rep-stable and identical to the scout's), the r93 in-tick area ordering (pinned
`area` cells identical; enter tick 29 / exit tick 35 reproduced), and the
lifecycle outcomes (pinned `life` cells identical, 6/6, including the
`--quit-after` clean exit with `_finalize` running).

**Still unknown [ ? ]**: the exact closed form of `a(N)` (two regimes measured,
one exception named) and of the `--quit-after` tick budget away from N = tps;
`max_physics_steps_per_frame` outside `--headless --script`; rendered /
non-`--script` main loops and `--write-movie` (which crashes headless);
`--fixed-fps` × `physics_interpolation=true` in a *rendered* context; whether
the 1 µs frame-slice floor is a documented clamp or an artifact.

---

## 12. Host hygiene and disclosure

- Every child was `timeout -s KILL` bounded and accounted for (1348/1348
  `.exit` sidecars). All hogs were killed in `finally` blocks; at completion
  `pgrep -af` finds no `r100b_hog`, no `r100b_starve_hog` and **no godot child
  of this seat**. Ten godot processes belonging to the concurrently running
  r92-verify2 / r93-baseline2 / r88-verify2 (2D) lanes were left untouched.
- Writes: `corpus/live/r100-boundary/**` (gitignored, 25 MB) + this report.
  No commits, no fixture edits, no other tracked-tree writes.
- **Delegated probe (frozen `probeParent`, one dispatch):** a `ufo-labrat` seat
  was dispatched with the cpuset-starvation hypothesis and returned **BLOCKED —
  its tool surface is read-only with no exec**, so it could run nothing and
  wrote nothing. The starvation arm was therefore run by this seat itself
  (`starve.py`, §2.3); the delegated probe contributed no evidence.
- **Not this seat's writes (disclosed):** `git status --porcelain` at
  completion shows untracked `corpus/fixtures/r93_areasig.gd`,
  `corpus/fixtures/r93_child.gd` (concurrent r93 lanes) and
  `reports/round-94/r94-boundary.md` (another lane) — all appear after this
  seat started, none touched. `git diff --stat` is empty (no tracked content
  modified); the only untracked file this seat authored is this report plus the
  gitignored corpus.
- Host note: the "L0" arms were never idle — other lanes held the box at
  28–108 load throughout (0.9×–3.4× oversubscription of 32 cores), and the L96
  arm peaked at ~4× before this seat's own hogs are counted.
