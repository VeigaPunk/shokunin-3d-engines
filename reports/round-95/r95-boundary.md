# r95 boundary — attacking the r95 pybullet scout's pins under load

Seat: `g3d-r95-boundary` (falsification; leaf). Lane: `game-dev-3d-shokunin`.
Target: `reports/round-95/r95-scout.md` (pybullet 3.2.7, `p.connect(p.DIRECT)`,
double-precision `btScalar` build, module banner `build time: Oct 15 2026
03:47:36`).

Evidence: `corpus/live/r95-boundary/` (gitignored) — `driver_b.py`,
`probes_b.py` (`r95b_*` namespace), `hogs.sh`, `aslr_hunt.sh`, `shm_probe.py`,
`godot/`, `build_float/`, 7 run dirs, 5 verbatim logs,
`manifest.sha256` (1847 entries, self-check passes, sha256
`3fddafe1fc06f057be340f60d9d197e426c35e880c9a6943dc1b2b0d47c0f1eb`),
`RECEIPTS.md`. Harness shas: `driver_b.py 6a47c888…`, `probes_b.py 56f978b7…`,
`hogs.sh 95a62bc3…`, `aslr_hunt.sh 2f02edff…`, `shm_probe.py 4e35f17b…`,
`godot/gd_sleep.gd dd7120ce…`. Labels: **[O]** observation (rep receipt),
**[I]** inference, **[?]** unknown. Every launch bounded (`timeout`/SIGKILL,
25 s); the scout's tree was never written to (`sha256sum -c manifest.sha256
--quiet` still passes for all 11768 of its entries afterwards).

No `lsp` device exists in this seat's tool surface; nothing symbol-aware was
needed (all writes are new files in the gitignored scratch tree, no tracked
file touched).

## 0. Headline verdicts

| # | scout pin | verdict |
|---|---|---|
| 1 | 84 arm signatures (62 pass-1 + 22 pass-2), byte-stable ×3 processes | **SURVIVES under load**: 84 arms × 3 fresh processes replayed against the pinned bytes → **0 drift, 0 mismatch, 0 timeouts** at loadavg 31→58 |
| 2 | "No wall-clock path in pybullet; `setRealTimeSimulation` is dead" (§2.2, §4.2, §6) | **FALSIFIED as a general claim — survives only in `DIRECT`.** A *headless-reachable* transport (`p.connect(p.SHARED_MEMORY_SERVER)`, no display) has the wall-clock pump live: with `rt=1` the world falls 5 → 0.49999 during a bare 2 s sleep with **zero** `stepSimulation` calls, and the stepped path becomes rep-**non**deterministic (3 reps → 3 different 64-bit hashes). Scout unknown #1 is resolved, in the direction the scout flagged as untested |
| 3 | "Fixed-step determinism, no unstated mode" (§2.1) | **SURVIVES for `DIRECT`**: no ASLR/heap-layout dependence (32-box/128-contact pile, 12+12+12 fresh processes, ASLR on/off/off+seed-0), no `PYTHONHASHSEED` dependence, no cross-client knob leak |
| 4 | "`deterministicOverlappingPairs` is bit-neutral in this scene" (§1.8, §2.1) | **REFINED, not falsified**: neutral in the 5-body scene (re-confirmed), **loud at scale** — a 32-box pile gives `det0=daf67ba7bdfb7f80` vs `det1=a272ef21dd510162`. Scene-scoped pin |
| 5 | Solver knob observable, 50≡150 (§1.5) | **SURVIVES**, and extends to a **solver-backend** axis the scout did not probe: `constraintSolverType` PGS/DANTZIG change the canonical hash (SI ≡ unset ≡ `02309c52da41ef33`) |
| 6 | Sleep null result + `EMPTY` analytics calibration (§2.4, §2.9c) | **SURVIVES**: `an=i0/n1/it2`, `cc=1` through 1400 steps on both body representations; `sleep-force-max` still yields `EMPTY` + frozen body |
| 7 | Fixpoint is scene-dependent; ball fixes at step 80 (§2.1 pass-2) | **SURVIVES at 6.7× horizon**: canonical scene `changes=20000/20000` (never fixes); the scout's exact `freeze-ball` cell still `changes=79, freezeStep=80` at 20 000 steps |
| 8 | Friction/restitution product rule + 1-ulp caveat (§2.7, §7.14) | **SURVIVES** on both builds; commutativity `g0.64/b1.0 ≡ g1.0/b0.64` exact |
| 9 | Cross-build determinism (unknown #4) | **RESOLVED**: hashes are **build-scoped** (a float-`btScalar` rebuild changes every hash), but **every qualitative law survives** the width change |
| 10 | "Godot sleeps by default; resting `cc=1`" (§2.8 Godot column) | **HOLDS on GP and Jolt** (sphere cell, `--fixed-fps 60`): sleep at tick 40 / 38, `cc=1` at rest. **Undefined on Dummy** (no physics: never sleeps, `cc=0`, body never falls) |

## 1. Verbatim replay under load — the 84 pinned arms **[O]**

Method: `driver_b.py --probes <scout>/probes.py --arms-from-pinned
<scout>/runs/20261015T071515Z --compare-to <same> --cwd <scout> --reps 3
--timeout 25`, one fresh process per arm/rep, stdout byte-compared to the
scout's pinned `rep1.out` (which its own three reps already agreed on).

- pass 1: **62 arms × 3 reps → drift 0, pinned mismatch 0/186, timeouts 0**
  (57 s, loadavg 31.06 → 57.28).
- pass 2: **22 arms × 3 reps → drift 0, pinned mismatch 0/66, timeouts 0**
  (5 s, loadavg 57.28 → 57.90).

Representative verbatim match (`base`):

```
base h=02309c52da41ef33 z@1=4.99982951 z@30=4.92092951 z@60=4.69026842 z@120=3.78969868 z@240=1.4999778 z@480=1.49997782 contacts=13 nan=False
```

The slowest cells are wall-clock cells and stay wall-clock-bounded under load
(`rt-sleep20ms` 9.8 s/rep, `rt-sleep4ms` 2.1 s/rep, `rt-idle` 1.2 s/rep),
which is itself evidence that the sleeps are real and the sim ignores them.

**Wall-clock under heavier load than the scout used** (`r95b_rt_long`,
`r95b_rt_idle_load`): `rt=1` with **1 s sleeps** between step batches gives
`h=02309c52da41ef33` = the `rt=0` control (`eq=True`); 5 s of idle plus 240
paced API calls leaves `z0=5, z_after_5s_idle=5, z_after_240_api_calls=5`.
The DIRECT half of §2.2 is solid under load.

## 2. The transport falsification — `SHARED_MEMORY_SERVER` is headless and live **[O]**

`shm_probe.py` connects with `p.connect(p.SHARED_MEMORY_SERVER)` (returns a
usable client id, no display, no external server process) and compares against
`p.DIRECT` in the same harness. Paired matrix, 2 reps per cell, `shm_matrix.log`:

| transport | rt | idle | z after idle | steps in the following 1 s |
|---|---|---|---|---|
| DIRECT | 0 | 1 s / 2 s | `5` / `5` | 156 816, 97 236 / 124 060, 105 418 |
| DIRECT | 1 | 1 s / 2 s | `5` / `5` | 97 626, 267 571 / 70 636, 139 382 |
| SHM | 0 | 1 s / 2 s | `5` / `5` | 6 100, 10 678 / 1 987, 4 547 |
| **SHM** | **1** | 1 s | **`0.559269599`, `0.490261648`** | 6 313, 20 559 |
| **SHM** | **1** | 2 s | **`0.49999`, `0.49999`** | 9 223, 13 123 |

With `rt=1` on SHM the sphere **falls during a bare `time.sleep`** — no
`stepSimulation` call of any kind — and one rep read `z0=4.99948857` *before*
its first read completed, i.e. the sim was already advancing between
`createMultiBody` and the first query. The two `idle=1 s` reps disagree
(0.559 vs 0.490): wall-clock-driven motion is **load-dependent**, exactly the
`maxSteps = numSubSteps + 3` / `gDroppedSimulationSteps` path of
`stepSimulationRealTime`.

Stepped-path transport check (`shm_canonical.log`, canonical 5-body scene,
480 explicit steps, scout's witness):

```
direct rt=0 → h=02309c52da41ef33  (×3)
direct rt=1 → h=02309c52da41ef33  (×3)     # flag inert in DIRECT — scout confirmed
shm    rt=0 → h=02309c52da41ef33  (×3)     # transport-neutral when explicitly stepped
shm    rt=1 → h=3a2504de37ca7bd0, h=26880e50982d99d7, h=ba500d4394c90b06   # 3 reps, 3 hashes
```

So the boundary statement is: **the transport does not change the physics
(`SHM rt=0` reproduces the DIRECT pin exactly), but `rt=1` on SHM makes the
stepped path non-reproducible**, and the 9-digit `z480=1.49997782` printed by
all 12 runs would have hidden that entirely — only the bit witness separates
them. This is the one place in this seat's whole battery where two identical
command sequences produced different bits **[O]**.

Credit: the transport was named by this seat's single depth-2 `ufo-labrat`
probe, which — having **no shell/exec capability in its environment** —
delivered a *source trace only* (`pybullet.c:551-554` →
`SharedMemoryInProcessPhysics_C_API.cpp:278-285` → `PhysicsServerExample.cpp:240-447`
motion thread → `PhysicsServerCommandProcessor.cpp:15902-15917`). That trace is
**[I]**, advisory, unmeasured; the table above is the measurement.

## 3. Backend variation

**(a) Solver backend (`r95b_solvertype`)** — `setPhysicsEngineParameter(constraintSolverType=…)`:

```
unset    h=02309c52da41ef33 z480=1.49997782 cc=13
SI       h=02309c52da41ef33 z480=1.49997782 cc=13
PGS      h=8606ea0c3c45c5ad z480=1.49998    cc=13
DANTZIG  h=71248c7a8455c70a z480=1.49997818 cc=13
```

stderr: `PyBullet: Constraint Solver: MLCP + PGS` / `MLCP + Dantzig`,
`switched solver`. **The scout's pins are sequential-impulse-scoped**; two
alternative solvers exist in this build and both move the canonical bits. Stable
across 6 reps × {ASLR on/off/off+seed0}.

**(b) One-knob census (`r95b_knobs`)** — fresh client per knob, canonical scene,
480 steps:

- bit-neutral in this scene: `enableConeFriction=1`, `erp∈{0.2,0.8}`,
  `frictionERP=0.2`, `minimumSolverIslandSize=0`, `numNonContactInnerIterations=4`,
  `allowedCcdPenetration=0.02`, `deterministicOverlappingPairs=1`,
  `warmStartingFactor=0.0` — all `02309c52da41ef33`.
- moves bits: `contactERP=0.2` (`e08d5633b3cfd5cb`), `contactSlop=0.01`
  (`dea262fe1f8c2307`), `solverResidualThreshold=1e-6` (`f23fadf887f1b5a7`),
  `globalCFM=1e-5` (`b4a0542ad1487ca5`), `minimumSolverIslandSize=2`
  (`cdb837583b118907`), `numSolverIterations=10` (`210161bcc8879e15`),
  `numSubSteps=2` (`0282277d82fd76ff`), `fixedTimeStep=1/120`
  (`00640cdd62ab6c5d`).

`minimumSolverIslandSize` is the sharp one: `0` is neutral, `2` is loud.

**(c) Physics tick rate (`r95b_tps`)** — `1/240` reproduces the pin exactly;
`1/60 b7fd8f6b58763ddb`, `1/120 d3a2bd84a2a6d25f`, `1/480 0282277d82fd76ff`,
`1/1000 4a1d38fd622019aa`. Note `1/480 × 960 steps` ≡ `numSubSteps=2 × 480
steps` (identical hash) — the substep split and the halved dt agree bit-for-bit.

**(d) Second backend: float `btScalar` (`build_float/`)** — the vendored sdist
rebuilt with `setup.py:73`'s `-DBT_USE_DOUBLE_PRECISION` removed
(`build.log`, sha256 `eb4096a1…`; `.so` sha256 `7d578878…`). Precision
discriminator: `fixedTimeStep` bits `3f71111120000000` (float) vs
`3f71111111111111` (double). 43 pinned arms re-run on it (30+13, ×2 reps,
drift 0):

- **hashes move** — `base` `b999c776bb9a7a20` vs `02309c52da41ef33`;
- **every qualitative law survives**: `rebuild/interleave/reset/restore-state
  eq=True`, `order-probe eq=False`, `iters` 1 vs 50 differ and 50≡150,
  `iters0 contacts=0 z=-10.6855326`, `substeps` n0/n4/n8 all differ,
  `detpairs eq=True`, `steps-saturated eq=False`, `erp`/`warmstart` neutral,
  `rt-off ≡ rt-fast`, `contact-rest` `cc=0→1` from step 120 and `cc=1` through
  1400, coincident spheres normal `(1,0,0)` ballistic, `sleep-default`
  `iters=2` forever, `sleep-disable freezeStep=80`, `sleep-velwrite z+1=0.520631969`,
  `freeze-scene changes=3000`, **`freeze-ball changes=79 freezeStep=80`**,
  `sleep-force-max an=EMPTY` frozen, `nan-fric` dropped / `inf-fric` stored,
  `inf-dt` poison set `0.p+0.q+0.v+0.w+1.p+1.q+1.v+1.w`,
  `fric-bitexact prod0808=…147c vs prod064=…147b ulpEq=False` with
  `g0.64/b1.0 ≡ g1.0/b0.64`, `rest-bitexact g0.9/b0.9 ≡ g0.81/b1.0`,
  `fric-zero-mech` ideal slide restored by `linearDamping=0`.

So scout unknown #4 resolves as: **pins must be labelled with the build; the
rules generalize across the precision backend.**

**(e) Contact density (`r95b_pile_*`)** — 32-box 4×4×2 pile, 600 steps,
128 contacts:

```
pile_default h=daf67ba7bdfb7f80 cc=128 minz=0.499987024 maxz=1.49997575
pile_det0    h=daf67ba7bdfb7f80   (default == detpairs 0)
pile_det1    h=a272ef21dd510162 cc=128 minz=0.499986707
pile_rev     h=38cb12317d6644da   (reversed creation order)
pile_mb      h=99d3fdf650620da5   (maximal coordinates)
```

`pile_det0 == pile_default` establishes the unread-back default is 0; the
scout's "detpairs bit-neutral" is a *5-body-scene* statement.

## 4. Mode hunts — nothing else moved **[O]**

`aslr_hunt.sh` (N fresh processes × {ASLR on, `setarch -R`, `setarch -R` +
`PYTHONHASHSEED=0`}), verbatim in `aslr_hunt.log`:

| arm | reps × cells | result |
|---|---|---|
| `r95b_witness` | 6×3 | 18/18 `h16=02309c52da41ef33` |
| `r95b_pile_det0` | 12×3 | 36/36 `h=daf67ba7bdfb7f80` |
| `r95b_pile_det1` | 12×3 | 36/36 `h=a272ef21dd510162` |
| `r95b_pile_mb` | 8×3 | 24/24 `h=99d3fdf650620da5` |
| `r95b_pile_rev` | 8×3 | 24/24 `h=38cb12317d6644da` |
| `r95b_solvertype` | 6×3 | 18/18 first-row `h=02309c52da41ef33` |

No pointer-order / heap-layout / hash-seed mode in DIRECT, even with 128 live
contacts at loadavg 104–119.

Instrument checks: `PYTHONHASHSEED∈{0,1,12345}` gives byte-identical `base`
output (`cmp` against the scout's pinned `rep1.out` → identical); my
independent 64-hex re-derivation of the witness is a superset of the scout's
`h16` (`02309c52da41ef33c79d1d1d8a3eda301244cc6ab5e88238e5e33ea50d45dfbc`), so
the 16-hex truncation hides nothing; `r95b_leak` (two clients, iters=1 + rt=1
on A only) → `hB=hC=02309c52da41ef33`, and `hA=3cb4032b0b034959` **equals the
scout's pinned `iters 1:h=3cb4032b0b034959`** — an independent reproduction of
a scout pin by different code.

## 5. Fixpoint horizon (6.7×) **[O]**

- `r95b_freeze20k` (canonical scene, 20 000 steps): `changes=20000
  firstChange=1 lastChange=20000 hFinal=b575e8d158e376bd` — the multi-body
  scene still never fixes, now measured 6.7× past the scout's window.
- `r95b_freeze20k_ball1` — an **exact clone of the scout's `freeze-ball` cell**
  (ball dropped from z=1.0; witness = ball pos+orn+lv+av only) at 20 000 steps:
  `changes=79 freezeStep=80 hFinal=1eac8fdcfcf7659f` — identical change count
  and freeze step; the fixpoint holds for 19 920 further steps.
- `r95b_freeze20k_ball` (my own z=5 drop, all-body witness): `changes=611
  freezeStep=612` — a *different scene*, quoted only to show the freeze point
  is scene-dependent, consistent with the scout's own pass-2 correction.

## 6. Godot GP / Jolt / Dummy cross-check of the report's Godot column **[O]**

`godot/` — resting body dropped 0.1 m onto a static floor, `--headless
--fixed-fps 60`, engine args before `--script` (r100 law), 300 ticks, 3 reps
per backend, `out_sphere.txt` / `out_box.txt`:

| backend | slept_at | `cc` at rest (sphere) | rest y | `cc` (box) |
|---|---|---|---|---|
| DEFAULT (GP) | 40 | 1 (ticks 60–300) | 0.4900 | 4 |
| Jolt Physics | 38 | 1 | 0.5000 | 4 |
| Dummy | never (`node_sleep=false`, `srv_sleep=nil`) | 0 | 0.6000 (never falls) | 0 |

3/3 reps identical per backend. The r95 report's rows "sleeping default: sleeps
by default" and "resting contact count cc=1" therefore **hold on GP and Jolt**
(the sphere cell is the comparable one; a box reports 4 point contacts) and are
**undefined on Dummy**, which has no physics at all. Backend-specific detail the
r95 table does not carry: GP rests 0.01 deep, Jolt rests exactly at the surface,
and the sleep tick differs (40 vs 38).

## 7. Claim-by-claim ledger

**Survives verbatim (pin kept):** all 84 arm signatures under load; DIRECT
determinism incl. in-process rebuild/interleave/reset/restore; creation-order
sensitivity (`order-probe eq=False`, and the divergence is *large* — the 64-bit
witnesses differ from the first byte, not by an ulp); solver-knob observability
and 50≡150; substep/dt equivalence; `erp`/`warmstart` neutrality; sleep null
result on both body representations plus the `EMPTY` detector calibration;
`cc=1` persistence; stale-manifold window; coincident-sphere `(1,0,0)`
ballistic split; refusal lattice (`radius≤0`/NaN raises, `+inf` radius and NaN
half-extents accepted, `>=0` gates drop NaN and pass `+inf`); product combine
rules with the 1-ulp caveat; fixpoint scene-dependence at 6.7× horizon; the
scout's `manifest.sha256` (11768/11768 verify).

**Refined (pin must be re-scoped, not dropped):** `deterministicOverlappingPairs`
(5-body neutral → pile loud); "no wall-clock path" → **DIRECT-only** (SHM+rt=1
is live and non-reproducible); `freeze-ball`'s fixpoint is exact but is a
property of that ball-on-floor scene, not of "a single resting body" generally;
cross-build hashes are build-scoped while the rules are not.

**New axes the scout did not probe (unstated modes):** `constraintSolverType`
(SI/PGS/DANTZIG), `contactERP`/`contactSlop`/`solverResidualThreshold`/
`globalCFM`/`minimumSolverIslandSize` sensitivity, `SHARED_MEMORY_SERVER`
transport, and the 128-contact pile as a determinism stress cell.

**Not falsified anywhere:** no pin of the scout's own battery moved by a single
byte under 12 hogs + ambient loadavg 31→119, ASLR on/off, hash-seed changes, or
a 6.7× horizon extension.

## 8. Remaining unknowns / risks

1. **[?] Cross-compiler/cross-host determinism** — only `btScalar` width was
   varied (float vs double, same `gcc 16.1.1`, same flags otherwise). A
   different `-march`/FMA contraction is still unmeasured (scout unknown #4 is
   narrowed, not closed).
2. **[?] `SHARED_MEMORY_SERVER` details** — dropped-step accounting under
   controlled load, `rt=1` behaviour with `numSubSteps>0`, and whether
   `TCP`/`UDP` (compiled in: `-DBT_ENABLE_ENET -DBT_ENABLE_CLSOCKET`) behave
   like SHM were not measured; only the idle-fall and the 3-rep stepped
   divergence are receipts.
3. **[?] Godot cell scope** — my cross-check is a minimal resting-body cell of
   my own, not the r93 probe; it tests the r95 report's Godot *column*, not the
   r93 round.
4. **[?] Load was ambient and uncontrolled** — own 12 hogs plus foreign hogs,
   godot children and a `-j8` compile; every cell records its loadavg in
   `summary.json`, but there is no idle-machine contrast run (the scout's own
   idle-condition bytes *are* the contrast, and they match).
5. **[?] Own hogs were reaped externally mid-session** (all `yes`-comm
   processes, foreign and mine, vanished between 16:44 and 16:58 local) — no
   cell depended on them staying alive (loadavg stayed 93–119 from other
   seats' load), and no stray process of this seat remains.
6. **[I] The labrat probe produced source trace only** (its environment had no
   shell) — treat its chain as a lead, not as evidence; §2 is the measurement.

## 9. Reproduce

```
cd corpus/live/r95-boundary
./hogs.sh start 12                                     # >=12 hogs, own namespace
PYTHONDONTWRITEBYTECODE=1 ./driver_b.py --probes ../r95-scout/probes.py \
  --arms-from-pinned ../r95-scout/runs/20261015T071515Z \
  --compare-to ../r95-scout/runs/20261015T071515Z --cwd ../r95-scout --reps 3 --tag replay-pass1
PYTHONDONTWRITEBYTECODE=1 ./driver_b.py --probes ../r95-scout/probes_ext.py \
  --arms-from-pinned ../r95-scout/runs/20261015T080234Z \
  --compare-to ../r95-scout/runs/20261015T080234Z --cwd ../r95-scout --reps 3 --tag replay-pass2
PYTHONDONTWRITEBYTECODE=1 ./driver_b.py --probes probes_b.py --cwd . --reps 3 --tag v-battery \
  --arms r95b_witness,r95b_prec,r95b_solvertype,r95b_knobs,r95b_tps,r95b_pile_det0,r95b_pile_det1,\
r95b_pile_default,r95b_pile_rev,r95b_pile_mb,r95b_leak,r95b_hashseed,r95b_order_bits,r95b_freeze20k,\
r95b_freeze20k_ball,r95b_freeze20k_ball1,r95b_rt_long,r95b_rt_idle_load
./aslr_hunt.sh r95b_pile_det0 12                        # + det1 / mb / rev / witness / solvertype
for t in direct shm; do for rt in 0 1; do \
  ../r95-scout/venv/bin/python shm_probe.py --transport=$t --rt=$rt --idle=2.0; done; done
../r95-scout/venv/bin/python shm_probe.py --transport=shm --rt=1 --canonical=1
./godot/run_godot.sh 300 3 sphere                       # + box
./hogs.sh stop
# float backend: build_float/ (sdist unpacked, setup.py:73 flag removed,
#   ./venv_float/bin/python setup.py build_ext --inplace --parallel 8)
FL=$(pwd)/build_float/pybullet-3.2.7/examples/pybullet/gym
PYTHONDONTWRITEBYTECODE=1 ./driver_b.py --probes ../r95-scout/probes.py --cwd ../r95-scout \
  --reps 2 --tag floatbuild-pass1 --env PYTHONPATH=$FL --arms base,rebuild,order-probe,iters,...
```

`manifest.sha256` (1847 entries, `sha256sum -c` clean) covers tooling, all
`runs/`, all logs and the Godot artifacts; `build_float/**` (vendored sdist,
267 objects, its venv) and `__pycache__/` are excluded and named in
`RECEIPTS.md`. This report's own sha256 is deliberately not self-quoted —
compute it from the file.
