# r94 boundary — attacking the r94 scout's pins (verbatim replay, engine variation, unstated modes, load)

Seat: `g3d r94 boundary` · lane `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`.
Subject: `reports/round-94/r94-scout.md` (three.js + cannon-es physics
determinism in headless node, 49 arms × 3 reps, `drift=0`).
Runtimes: `node v24.21.0` (V8 13.6, the scout's) and `node v26.12.0` (V8 14.6),
no browser, no GL. Dependencies: the scout's own `cannon-es@0.20.0` +
`three@0.186.1` (byte-identical copy of their project).

Evidence: `corpus/live/r94-boundary/` (gitignored, `corpus/.gitignore:1: live/`) —
`scout-replay/` (a byte-identical copy of `corpus/live/r94-scout` plus my
batches), `probes/r94b_*.mjs`, `r94b_drive.mjs`, `r94b_run.mjs`, `compare.mjs`,
`hogs.sh`, `runs/` (**1383 captured children**: 942 mine + 441 in the copy),
`logs/`, `manifest.sha256` (**2888 files**), `RECEIPTS.md`. The only
tracked-tree write is this report (`git status --porcelain` at seat end:
`?? reports/round-94/r94-boundary.md`; the two untracked
`corpus/fixtures/r93_*.gd` files that appeared at 16:50 are a concurrent seat's
work, untouched here, and no tracked file was modified).

Load: every loaded batch ran under **16 CPU hogs** (`hogs.sh`, trap-killed;
`pgrep -f 'while :; do :; done'` re-checked after each). Every launch is
`timeout`-bounded (25 s kill in my runners; ad-hoc probes under `timeout 25`).

Confidence: **[O]** receipt-pinned measurement, **[I]** inference, **[?]** unknown.
Nothing here re-pins a scout cell that did not survive the attack.

---

## 0. Verdicts

| # | scout pin / claim | verdict | evidence |
|---|---|---|---|
| 1 | 49 arms × 3 reps, `drift=0`, 44 exit 0 / 5 exit 2, **verbatim hashes** | **CONFIRMED** | 147/147 children byte-identical (stdout+stderr+rc) to the scout's batch, idle **and** under 16 hogs; `rcHistogram={"0":44,"2":5}` |
| 2 | their `manifest.sha256` (456 files) is a faithful receipt | **CONFIRMED** | `sha256sum -c` rc=0 against their tree |
| 3 | §2.1 "a fixed-step world is reproducible to the bit" (`step(dt)`) | **CONFIRMED** | survives 16 hogs, `--jitless`, `--predictable`, and node v26/V8 14.6 |
| 4 | §0 "`internalStep` is a pure function of [the four body quantities]" | **FALSIFIED** | direct `internalStep` with the clock frozen lands `1.499930148` vs `1.499985073`; adding `world.time += dt` by hand reproduces the pin exactly (§4) |
| 5 | §2.3 "accumulator stepping is not reproducible across machines" **[I]**, host effect unmeasured **[?]** | **CONFIRMED and measured** | substep counts for one identical call span **1…222** in-process; every child gets a different physics hash (§7) |
| 6 | §2.1 "body-add order is bit-neutral" (their own **[?]**) | **FALSIFIED outside their scene** | 3 asymmetric multi-contact scenes, forward ≠ reverse, 3/3 rep-stable (§8) |
| 7 | §2.2 `tolerance=1e-7` never breaks early; `iters` 1/20 move the hash | **CONFIRMED** | replay + `iters=5 → 89b292ca9c60f52b` (new cell) |
| 8 | §2.7 `sap` ≠ `naive` (broadphase is not bit-neutral) | **CONFIRMED**, **extended** | `sap` = `0b0f249979097645` for `axisIndex` 0/1/2 alike; `GridBroadphase` is unusable (§9) |
| 9 | §2.7 "effective deceleration ≈ 15·μg" **[I]**, saturation **[?]** | **FALSIFIED as a law** | factor is mass-inert (15.173) but μ- and v₀-dependent: **3.05 … 17.27** (§10) |
| 10 | §2.5 "`dt=0` and `dt<0` are NaN-free" | **FALSIFIED in accumulator mode** | `step(0, elapsed, n)` → `accumulator=NaN` → world frozen forever (§6) |
| 11 | §2.5 / RECEIPTS "raw-bit hash over a NaN state is not admissible"; mechanism **[?]** | **CONFIRMED, mechanism narrowed** | live reproduction under `--no-opt`: ~34 % of 99 fresh processes flip `rawQ`; disappears with `--no-maglev` (§3) |
| 12 | §2.3 `fixedStep` "not used by these cells" (silent) | **NEW MODE, not a fixed-step scheduler** | 240 calls advance **1** tick and every process gets a different hash (§5) |
| 13 | §2.8 Godot comparison table (GP/Jolt citations from r93) | **CONFIRMED (citation audit)** | every cited value found in the r93 receipts (§11) |

Net: **8 clusters of the scout's pins survive the attack verbatim; 4 of its own
claims/qualifiers die**, and 4 new unstated modes are pinned (§5–§7, §9).

---

## 1. Verbatim replay — 147/147, twice

`scout-replay/` is `cp -a` of the scout's tree; `diff -rq` (excluding the new
`runs/` batches and `node_modules`) → rc=0, `node_modules` → rc=0,
`sha256sum -c manifest.sha256` → rc=0 (456 files). Their driver was then run
unmodified:

```
r94b-idle    : audit rcHistogram={"0":44,"2":5} drift=0 total=49
r94b-load16  : audit rcHistogram={"0":44,"2":5} drift=0 total=49   (16 hogs)
compare A=r94b-idle   B=20261015T061500Z arms=49 children=147 identical=147 stdoutDiff=0 stderrDiff=0 rcDiff=0
compare A=r94b-load16 B=20261015T061500Z arms=49 children=147 identical=147 stdoutDiff=0 stderrDiff=0 rcDiff=0
```

Every one of the scout's verbatim signature rows I re-read matches, e.g.
`base h=0e24fb5aca619253 … sleep=2,2,2,2 nan=false`,
`bailout dt=1e-5 elapsed=1e-3 maxSubSteps=1000 stepnumber=1 time=1.000000e-3
accumulator=1.000000e-5 ball.y=4.999999999018`, and the 5 negative arms exit 2.

Two arms that the scout's driver ran are **missing from its report's arm table**:
`det_fixed.order-swap` (`forward=0e24fb5aca619253 reverse=0e24fb5aca619253
eq=true`) and `det_fixed.ulp` (`mag=1e-9 h_a=0e24fb5aca619253
h_b=0c63200d1cbbf34d eq=false dx=1.034906e-9`). Both replay byte-identically; the
report documents 47 arms of the 49 its receipts claim. **[O]**

## 2. Engine variation — the pins are V8-version robust except one mode

| runtime | children | vs scout batch |
|---|---|---|
| node v24.21.0 default | 147 | identical 147 |
| node v24.21.0 + `--jitless` | 147 | identical 147 |
| node v24.21.0 + `--predictable` | 147 | identical 147 |
| **node v26.12.0 (V8 14.6)** | 147 | **identical 147** |
| node v24.21.0 + `--no-opt` | 147 | **identical 145, stdoutDiff 2** — both `nan.all` |

**[O] The scout's pins are not an artifact of V8 13.x**: a full V8 major bump
(13.6 → 14.6) reproduces all 147 children byte-for-byte, and so does the
interpreter-only build. **[O] The one exception is the NaN payload**, which
flips under `--no-opt` — the same arm whose drift the scout recorded once and
could not reproduce.

## 3. The NaN payload: reproduced, located, bounded (their **[?]** #2)

The scout's `RECEIPTS.md` records one non-reproducing drift (raw-bit hash of
`angdamping_gt1`, `8a85547d1eaab41e` vs `162bfac9f5dec326`, printed fields
identical) and concludes a raw-bit hash over a NaN state is inadmissible. I
reproduced the class **and** narrowed the mode. 30 fresh processes per config,
their own `p_nan.mjs --case all`:

| flags | `rawQ` distribution |
|---|---|
| default | 30× `7ff8000000000000` |
| `--jitless` | 30× `7ff8000000000000` |
| `--no-maglev` | 30× `7ff8000000000000` |
| `--no-opt` | **20× `7ff8…`, 10× `fff8…`** |
| `--no-opt --no-sparkplug` | **17× `7ff8…`, 13× `fff8…`** |
| `--no-opt --no-maglev` | 30× `7ff8000000000000` |

Aggregate over every `--no-opt` child measured here: **34 flips in 99 fresh
processes (~34 %)**; zero flips in every other configuration (default, jitless,
predictable, no-maglev, no-opt+no-maglev, node 26, and under 16 hogs). The
scout's **own drift gate** fails in that mode:

```
--no-opt, 6 reps of nan.all : sha256 -> 5x 0436c1a3… , 1x 18ee2833…   (DRIFT)
default , 6 reps of nan.all : 6x 0436c1a3…                            (stable)
--no-opt, 49-arm driver     : nan.all r1, r2 differ from the scout's batch
```

Additional bounds **[O]**: the flip needs the *preceding 21 cases* — running
`--case nan_payload` alone is 12/12 stable in default, `--no-opt` and `--jitless`;
only `rawQ` flips (`rawW`/`pow` stay `fff8000000000000` in all 180 sweep
children); the canonical hash `h=152fc9d393846ae3` is identical in every flip,
and the `nan-summary` line never moves. The scout's *original* witness did not
come back: my verbatim `angdamping_gt1` mirror is 12/12 stable
(`rawHash=989bfafcc1cbfba4`) in default, `--no-opt`, `--jitless` and node 26 —
the reproduction above is the same *class* in the `nan_payload` cell, not the
old `angdamping_gt1` hash pair.

**[I]** the payload of the quaternion NaN (not of `pow` itself — `pow(-0.5,dt)`
is `fff8…` in cold and warm code in every config) depends on the code shape the
process reaches when the case runs: with the optimizing tier disabled but
**Maglev** enabled, some processes take a path that yields the positive quiet
NaN. **[O] the scout's mitigation is correct and necessary**: hash NaN
canonically, never by payload; and any future cell that hashes raw bits must
declare the V8 flag set.

## 4. The scout's §0 witness law is false: `internalStep` reads the clock

The scout's §0 states `internalStep` is a pure function of
`position/quaternion/velocity/angularVelocity`. Two cells, 3/3 identical each,
idle and under 16 hogs:

```
internal         h=c882e660f6b85f96 ph=c1365b74ffa49e03 ball.y=1.499930148 sleep=1,1,1,1  time=0
internal-clocked h=0e24fb5aca619253 ph=0c58591a5347866e ball.y=1.499985073 sleep=2,2,2,2  time=4
```

`internal-clocked` calls the *same* `world.internalStep(dt)` 240 times but
advances `world.time += dt` by hand — and reproduces the scout's `base` pin
exactly. So `world.time` is a **required input** to the step function.
Mechanism **[I]** anchored in the pinned bundle: `dist/cannon-es.js:12864`
`bi.sleepTick(this.time)` and `12866` `if (bi.sleepState !== SLEEPING)` gate the
integration; with the clock frozen no body ever leaves SLEEPY (`sleep=1,1,1,1`),
so the resting pose differs by 55 µm. Consequence: any "same state ⇒ same bits"
claim must carry the clock in the state tuple.

## 5. `fixedStep()` is a wall-clock scheduler (unstated mode)

The scout's §2.3 mentions `fixedStep` only to say it is "not used by these
cells". Measured (`dist/cannon-es.js:12473` reads `performance.now()/1000`):

```
240 × fixedStep(dt,10) tight loop : stepnumber=1  time=0.0188–0.0252 (wall)  h differs in 9/9 processes
60 × fixedStep(dt,10) at 5 ms/call: stepnumber=19–22 (idle 19,19,19 / 20,20,21; load 19,22,20)  ball.y 4.31–4.48
```

The tight-loop arm's **physics witness is stable** (`ph=a3ec872defc812b2` in all
9 processes) while the *render* witness moves — the scout's own §0 lesson, now
with a wall-clock-driven API. The paced arm moves the physics too under load
(`ph` 8fef07e7… idle vs 44bba517…/c3582332…/c334c8bf… loaded). **[O] "fixed-step
mode is byte-stable" holds only for `step(dt)` with no elapsed argument**;
`world.fixedStep()` — the documented fixed-rate API — is not reproducible, in
either witness, because its tick count is a function of wall time.

## 6. Degenerate modes in the accumulator branch (the scout's §2.5 has a hole)

The scout's `zero_dt`/`neg_dt` cells use the **fixed** branch. In the
accumulator branch (`dist:12512-12539`):

```
step(0, 1/60, 10)   -> stepnumber=1 time=0.016666666667 accumulator=NaN ball.y=5.000000000
   then a normal step(dt,1/60,10) -> stepnumber=1 (unchanged), ball still frozen, time advances
step(-dt, 1/60, 10) -> stepnumber=1 time=0.016666666667 accumulator=0 ball.v=+0.163666667 ball.y=4.997272222
step(dt, dt/2) ×10  -> stepnumber=5 time=0.083333333333 interpPos.y=4.972726791 ≠ pos.y=4.959092470
step(dt, -dt)       -> world.time 4.000000 -> 3.983333 (goes backwards), stepnumber unchanged
```

`dt=0` in accumulator mode poisons the accumulator (`accumulator % 0`), and
`accumulator >= dt` is then false forever: **the world is frozen while
`world.time` keeps advancing** — the same class as their `inf_elapsed`/
`nan_elapsed` cells, reached by a *different, unstated* input. `dt<0` runs one
substep with reversed gravity sign and no NaN. **[O] §2.5's "dt=0 and dt<0 are
NaN-free" is mode-conditional and must be split by branch.** Also **[O]**
`step(dt, elapsed)` with `maxSubSteps` omitted defaults to 10 (their `maxsub`
cell reproduced: `stepnumber=10 time=0.500000000 accumulator=4.16e-17`), and
`elapsed < dt` advances the clock and rewrites the interpolation buffers without
running a substep.

## 7. The accumulator budget: the scout's unmeasured host effect, measured

The loop's budget is `performance.now() - t0 > dt*1000` (`dist:12529`). With
`dt=1e-3` the budget is 1 ms, comparable to one `internalStep` (measured
91–604 µs/step on this host, tier- and load-dependent). Same call
(`step(1e-3, 1.0, 1000)`, fresh world), **6 in-process repeats per child**:

```
idle   child1 [157,166,18,183,12,191]  child2 [212,174,189,53,195,222]  child3 [66,37,195,146,187,91]
16 hogs child1 [48,72,148,138,4,52]    child2 [61,180,147,56,138,169]  child3 [179,94,169,178,182,1]
```

Substep counts for one identical call span **1…222** (a >200× spread on one
host); every child produced a
different physics hash (`ph`), and `ball.y` differs in the 2nd decimal
(4.757105406 … 4.999990180). `dt=1e-4` spans 5…26, `dt=1e-5` flips between 1
and 2, `dt=1e-2` reaches 99 (of 100) only after warm-up. **[O] the scout's
`bailout` pin is exact at its own arm (147/147 replay) but sits on a measured
boundary**: the same `dt=1e-5` with `elapsed=1.0` flips 1↔2 substeps.
**[O] the host-speed effect the scout left unmeasured is a >200× substep
spread in-process on one host** — so the [I] in its §2.3 is now a measurement,
and any accumulator-mode cell is unportable across machines.

## 8. The add-order law is a property of their scene, not a law

Their §2.1 invariance is labeled **[?]** for asymmetric scenes (their unknown
#1). Three deliberately asymmetric, coupled multi-contact scenes, 240 fixed
steps, forward vs reverse body-add order, 3/3 reps, idle and under 16 hogs:

| scene | forward | reverse | eq |
|---|---|---|---|
| `canon` (their control) | `0e24fb5aca619253` | `0e24fb5aca619253` | **true** |
| `asym2` (2 boxes in face contact, masses 1/2, one rotated 0.3 rad, ball on the seam) | `2e65cf7fee2231ef` | `d02da58eee19ed26` | false |
| `stack3` (leaning 3-box column, ball on top) | `4caaad1536e64820` | `d3795db5d0707284` | false |
| `tri` (box + two spheres resting against it) | `f1a92e83a9cbee79` | `a8ad93a17b3fc7f4` | false |

All three also differ in the physics-only witness, and in `stack3` the two
orders execute a different *number* of solver calls (106 vs 175 — different
sleep schedules). The `canon` control reproduces their exact finding (equation
order permuted, `rawSame=false`, hash equal), so the divergence is the scene,
not my harness. **[O] "body insertion order does not change the physics" is
false in general**; it holds in their symmetric 4-body scene.

## 9. Backend lattice: two new pins, one broken class, one new solver mode

`broadphase` (their two classes plus the third one they never touched):

```
naive            0e24fb5aca619253   (their pin)
sap default / axisIndex 0 / 1 / 2    0b0f249979097645  (all four byte-identical — axisIndex is inert here)
grid nx=1        1 step in 5–9 ms, y=4.997272222 (single bin; matches the naive first step)
grid nx=2,3,4    TypeError: Cannot read properties of undefined (reading 'material') @ Narrowphase.getContacts, 70–180 ms
grid nx=10       no completion within 19.6–25 s, then RangeError: Invalid array length @ GridBroadphase.makePairsUnique
```

Root cause **[I]**, source-read from the pinned bundle: `makePairsUnique`
(`dist:4076-4107`) keeps **module-level shared** `p1/p2/temp` arrays
(`dist:4141-4145`), truncates the pair lists and re-pushes from stale indices,
so the arrays leak across calls and eventually exceed the array-length limit.
**[O] `GridBroadphase` must not be used in this scene**; the scout's
broadphase law is complete only because the third shipped class fails closed.

`solver` (8 variants, 8 distinct hashes): `gs` 1/5/10/20 →
`a87c85c948341344` / `89b292ca9c60f52b` / `0e24fb5aca619253` /
`d3fda7808f2de666`; `SplitSolver(GSSolver)` default `40aeebd22b384e32`, split
iters 1 `ccf8afd9a2a23512`, split iters 20 `b38f8eccf89e71e0`, split + subsolver
iters 1 `97af821da9944daf`. **[O] `SplitSolver` is not bit-equivalent to
`GSSolver`** (their §5 unknown #7, now pinned for the canonical scene), and
`SplitSolver.iterations` ≠ its subsolver's.

## 10. The friction factor is a one-point fit (their §2.7 [I], unknown #4)

Their sphere-slide scene, base check reproduced exactly (`mu=0.3, m=1 →
slideX=0.279647`), 2400 steps:

```
mass (mu=0.3):  m=0.25/0.5/1/2 -> 0.279647   m=5 -> 0.279652   m=10 -> 0.279658   (a/mu*g = 15.173 +/- 0.001)
mu  (m=1)   :   mu=0.05 -> a/mu*g = 3.053    mu=0.3 -> 15.173   mu=0.9 -> 15.669
v0  (m=1,mu=0.3): v0=1 -> 9.048              v0=5  -> 15.173    v0=20 -> 17.273
```

**[O] mass is inert (the clamp really is mass-normalised), but "effective
deceleration ≈ 15·μg" is a fit at one (μ, v₀)**: the ratio ranges 3.05–17.27
over the swept domain. `d ≈ 0.084/μ` is therefore not a usable rule outside
μ≈0.3, v₀≈5 m/s.

## 11. The Godot-facing surface: applicability and citation audit

**[O] Applicability.** The r94 scout has **no Godot runtime surface** — its 49
arms are node/JS only. `GP vs Jolt vs Dummy` and `--fixed-fps` are therefore
**inapplicable** to its cells (the lane's `--fixed-fps` law is an r100 Godot
result, `reports/round-100/r100-scout.md`, and was not re-run here). The only
Godot-facing content in the report is its §2.8 comparison table, which rests on
r93 receipts. I audited those citations against the receipts rather than
re-running r93 cells (that is the r93 boundary's job):

| §2.8 claim | r93 receipt | verdict |
|---|---|---|
| GP write tick keeps the old contact: `cc=1 y=0.4900`, then `pf=21 cc=0 lv=-0.1633` | `so_proj_shrink.r1.stdout.txt` (`pf=20 cc=1 y=0.4900`, `pf=21 cc=0 y=0.4873 lv=-0.1633`) | faithful |
| GP ejects 0.5 m in ≤3 steps `0.49→0.89→0.97→0.99` | `so_proj_grow.r1.stdout.txt` (`0.8900 / 0.9700 / 0.9860 / 0.9900`) | faithful |
| Jolt pushes ≈0.08/tick | `so_proj_jolt_grow.r1.stdout.txt` (`0.4890→0.5690→0.6490→0.7290→0.8090`) | faithful |
| GP sleeps at pf=43; a layer/mask write wakes it in the write tick; Jolt stays asleep | `ly_proj_sleepmask.r1` (`LY SLEPT pf=43`, `LY ACT ball.mask=0 … sleep=false pf=45`) vs `ly_proj_jolt_sleepmask.r1` (`sleep=true` after the write) | faithful |
| GP/Jolt report `cc=1` while resting and while asleep | `ly_proj_sleepmask.r1` / `ly_proj_jolt_sleepmask.r1` (`cc=1` at pf=43-46 with `sleep=true`) | faithful |

No symbol-level work was required by this seat (no source edit, no rename), so
no `lsp` request was made; the scout's own note that no server answers for the
vendored `node_modules` bundle stands and was not needed here.

## 12. Falsification list (what the attack killed)

1. **"`internalStep` is a pure function of the four body quantities"** —
   FALSIFIED; `world.time` is a required input (§4).
2. **"`dt=0` and `dt<0` are NaN-free"** — FALSIFIED for the accumulator branch;
   `dt=0` there freezes the world via `accumulator=NaN` (§6).
3. **"Body insertion order does not move the physics"** — FALSIFIED in three
   asymmetric multi-contact scenes; true only in the scout's own scene (§8).
4. **"Effective friction ≈ 15·μg / d ≈ 0.084/μ"** — FALSIFIED as a general law;
   the factor is μ- and v₀-dependent (3.05–17.27) (§10).
5. **"`world.fixedStep()` is a fixed-step scheduler"** (implicit in the §2.1
   law's reach) — FALSIFIED; it is wall-clock-driven and non-reproducible (§5).
6. **"`drift=0` is a property of the battery"** — BOUNDED: it is a property of
   the default V8 flag set. Under `--no-opt` the scout's own gate reports drift
   (§3).
7. **"A raw-bit NaN witness is merely inadmissible"** — upgraded: it is
   *measurably* inadmissible at a ~34 %/process rate under a named mode, and the
   canonical spelling is exactly the right mitigation (§3).
8. **"The third shipped broadphase class is a usable backend"** (the scout never
   tested it, and its §5 unknowns do not name it) — FALSIFIED: corrupt pair lists
   at nx=2–4, non-completion/RangeError at nx=10 (§9).
9. **"The broadphase/solver lattice is covered by naive+sap and GSSolver"** —
   extended: `SplitSolver` moves the hash in every configuration (§9).

## 13. What survives, and what a fold should carry

Survives verbatim (re-pinned, load- and runtime-independent): the 49-arm
battery's stdout/exit contract; the `base`/`rebuild`/`interleave`/`order-swap`
fixed-step hashes; the `sap` hash; the solver iteration/tolerance pins; the
`nan.all` canonical set and its 7-NaN summary; the sync/material/parity cells;
the interpolation-buffer separation; `steps-saturated`; the five negative arms.

Carry into the fold as **mode-qualified** pins: every accumulator-mode cell
(`maxsub`, `bailout`, `uneven`, `sleep-phase`, `interp`, `elapsed ≡ dt`) needs
its host-speed caveat; every raw-bit NaN cell needs its flag-set caveat; the
add-order law needs "symmetric scene only"; `fixedStep` needs "wall-clock, not
reproducible".

## 14. Remaining unknowns / risks / blockers

1. **[?] `--no-opt` flip mechanism at the instruction level** — the
   Maglev correlation is measured (0/30 with `--no-maglev`), not explained; no
   `--trace-maglev` receipt was taken, and the trigger depends on process
   history (21 preceding cases), which I did not reduce to a minimal prefix.
2. **[?] Cross-host size of the accumulator effect** — measured on one host
   (32 cores, 16 hogs); a second host is out of reach for this seat.
3. **[?] Whether the asymmetric add-order divergence needs the sleep system** —
   `stack3` differs in solver-call counts, which is consistent with a sleep-
   schedule divergence, but I did not run `allowSleep=false` variants.
4. **[?] `GridBroadphase` root cause** — source-read [I]; I did not patch or
   bisect the shared-temp arrays.
5. **Blocker for the operator (not this seat):** `reports/round-94/r94-scout.md`
   is tracked and its §2.5/§2.7/§2.1 qualifiers now need the mode caveats from
   §12; that is a fold/author decision, not a boundary write.
6. **Scope note:** no Godot cell was executed by this seat — the r94 scout has
   no Godot surface; the r93/r100 Godot receipts were read, not re-run.

## 15. Evidence index

`corpus/live/r94-boundary/manifest.sha256` — **2888 files** (probes, runners,
`logs/`, `runs/`, `RECEIPTS.md`), `sha256sum -c` rc=0. Key anchors:

```
scout-replay/manifest.sha256                     sha256sum -c rc=0 (their 456 files)
logs/replay-idle.driver.log, logs/replay-idle.audit.log      49 arms, drift=0
logs/replay-load16.driver.log, logs/replay-load16.audit.log  49 arms, drift=0, 16 hogs
logs/drive-{node26,jitless,noopt,predictable}.log            engine-variation batches
logs/noopt-nan6.driver.log, logs/default-nan6.driver.log     the drift gate, 6 reps each
logs/payload-sweep-{default,noopt,noopt_nospark,nomaglev,noopt_nomaglev,jitless}.log
logs/modes-idle.log, logs/modes-load16.log, logs/modes2-{idle,load16}.log
logs/order-idle.log, logs/order-load16.log  + runs/r94b-order-canon/ (3 children, console-logged)
logs/backends-idle.log, logs/grid.log, logs/friction-idle.log
runs/r94b-*/  (942 children: .stdout/.stderr/.meta sidecars + per-batch summary.json)
```

Reproduce any cell: `cd corpus/live/r94-boundary && node r94b_run.mjs --batch <b>
--script <probe> --reps 3 --arms "<a b c>"` (add `./hogs.sh 16 …` for the loaded
arm). Every child is a fresh process with a 25 s kill; hogs are trap-killed.
