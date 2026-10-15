# r95 scout — pybullet 3.2.7 physics determinism in headless DIRECT mode

Lane: g3d · runtime `python 3.14.7` (system `/usr/bin/python3`), no pybullet
preinstalled (`import pybullet` → ModuleNotFoundError; `pymunk`/`Box2D` also
absent). Pivoted per dispatch: built `pybullet-3.2.7` from the PyPI sdist in a
lane-local venv `corpus/live/r95-scout/venv` (no cp314 wheel exists; compiled
from source, `-DBT_USE_DOUBLE_PRECISION` → `btScalar = double`,
`setup.py:73`). Wheel sha256 `aeee570b…261c`; module prints
`pybullet build time: Oct 15 2026 03:47:36`. `getAPIVersion()=202010061`.
All cells run `p.connect(p.DIRECT)` — in-process command processor
(`PhysicsDirect`), no GUI, no renderer.

Evidence: `corpus/live/r95-scout/` — `probes.py` (62 arms, one fresh process
each), `driver.py` (3 reps/arm, byte-compares stdout+stderr+exit code),
`runs/20261015T071515Z/` (186 rep triples + `summary.json`),
`manifest.sha256` (11768 entries covering `venv/`, `src/`, `runs/`, and the
tooling; `__pycache__/` and the manifest itself are excluded),
`RECEIPTS.md`. The sdist is vendored at
`src/pybullet-3.2.7.tar.gz`, unpacked at `src/pkg/pybullet-3.2.7/` — every
C++ line anchor below refers to that tree. `corpus/fixtures/**` and all other
tracked trees were read only; the only tracked-tree write is this report.

Reps: **62 arms × 3 fresh processes, drift = 0** — every arm byte-identical
across reps, *including the wall-clock arms* (see §2.2). Confidence:
**[O]** observation (rep-stable receipt), **[I]** inference, **[?]** unknown /
not decided by these cells.

## Two-pass provenance (read this before trusting any number)

This report merges **two seats of the same r95 scout lane**; the first was
rate-limited mid-flight, so the deliverable is a merged artifact, not a
single-author one.

- **Pass 1** (§1.1–§1.6, §2.1–§2.8, §3 anchors, §4 items 1–12, §5 items
  1–8) — the first seat. Its battery is `probes.py` /
  `runs/20261015T071515Z/`.
- **Pass 2** (§1.7, §2.9, the pass-2 rows in §4/§5) — this seat, a
  *verification* pass. It (a) re-ran pass 1's whole battery in a second run
  dir and byte-diffed the two runs, (b) added 22 independent arms
  (`probes_ext.py` / `driver_ext.py` / `runs/20261015T080234Z/`), and
  (c) **refuted two pass-1 claims** — §2.1's fixpoint generalization and
  §2.4's mechanism attribution — and **resolved two of pass 1's own
  unknowns** (#2 sleep on the rigid-body path, #5 the μ=0 residual).

Pass 2 re-run result: **62 arms × 3 reps, drift = 0** in
`runs/20261015T075938Z/`, and all **186 stdout files are byte-identical
across the two independent run dirs** (`cmp` per file, 6 fresh processes per
arm). Pass-2 battery: **22 arms × 3 reps, drift = 0**. Every signature quoted
below is from `rep1.out`; the other two reps are byte-equal.

**One provenance discrepancy, unresolved [?, not silently patched]:** the
header above says pass 1 *compiled from source* because "no cp314 wheel
exists", yet also quotes a `pybullet-3.2.7-cp314-cp314-linux_x86_64.whl`
sha256. Pass 2 cannot adjudicate: it inherited the venv and `pip install
pybullet` reported `Requirement already satisfied: pybullet 3.2.7`, and the
module banner (`build time: Oct 15 2026 03:47:36`) is identical for both
passes, so whichever route ran, **both passes measured the same binary** and
every cross-run comparison here is same-binary. The compile-vs-wheel question
does not affect any measurement in this report.

Canonical scene (Z-up; Bullet is Z-up, pybullet's own default): static ground
`Box halfExtents(10,10,0.5)` at `(0,0,-0.5)` (top face `z=0`), `Sphere r=0.5`
mass 1 at `(0,0,5)`, three `Box he(0.5,0.5,0.5)` mass 1 at `(1.5,0,4)`,
`(-1.5,0,3)`, `(0,0,2)`; gravity `(0,0,-9.82)`; default `fixedTimeStep=1/240`,
`numSubSteps=0`, `numSolverIterations=50`; 480 steps = 2.0 s. Witness `h` =
sha256 over every body's `(pos, quat, linVel, angVel, bodyId)` as canonical
IEEE-754 f64 bytes (NaN canonicalized, raw payload printed separately),
truncated to 16 hex. Body ids are **per-client** (restart at 0), so they stay
in the witness safely.

---

## 0. What is being hashed

pybullet exposes only the live solver state (`getBasePositionAndOrientation`,
`getBaseVelocity`); there is no interpolation buffer and no second pose to
confuse — `h` is *the* physics witness. `getDynamicsInfo` returns 12 fields
(mass, lateralFriction, inertia diag/frame, restitution, rolling/spinning
friction, contactDamping, contactStiffness, bodyType, collisionMargin) and —
notably — **no activation/sleep field**: sleep state is unobservable through
the API and is inferred here only through behavior.

`p.stepSimulation()` returns `()` unless
`setPhysicsEngineParameter(reportSolverAnalytics=1)`; then it returns
per-island `{islandId, numBodies, numIterationsUsed, remainingResidual}` —
used as the sleep probe (§2.4).

---

## 1. Arm table

Each cell is one fresh process; `driver.py --only <id>` reproduces it.
All arms ran ×3 byte-identical.

### 1.1 Fixed-step determinism

| # | arm | expected signature (verbatim, r1) | falsified if |
|---|---|---|---|
| 1.1 | `base` | `base h=02309c52da41ef33 z@1=4.99982951 z@30=4.92092951 z@60=4.69026842 z@120=3.78969868 z@240=1.4999778 z@480=1.49997782 contacts=13 nan=False` | the hash moves across processes |
| 1.2 | `rebuild` (two `DIRECT` clients, one process) | `rebuild h1=02309c52da41ef33 h2=02309c52da41ef33 eq=True ids1=0,1,2,3,4 ids2=0,1,2,3,4` | second in-process world differs |
| 1.3 | `interleave` (A 30, B 30, A 450, C fresh 30, D control 480) | `interleave A=02309c52da41ef33 base=02309c52da41ef33 eqA=True B=b5b5814549b9d518 C=b5b5814549b9d518 eqBC=True` | interleaving contaminates a world |
| 1.4 | `order-probe` (reversed body creation) | `order-probe h_forward=02309c52da41ef33 h_reverse=76988acc55682c1a eq=False` | creation order is bit-neutral |
| 1.5 | `iters` (numSolverIterations 1/50/150) | `iters 1:h=3cb4032b0b034959,z=1.49782812 50:h=02309c52da41ef33,z=1.49997782 150:h=02309c52da41ef33,z=1.49997782` | the solver knob is unobservable |
| 1.6 | `iters0` | `iters0 h=5c1f78b5e4aaabb1 z=-10.6855237 contacts=0 nan=False` | a zero-iteration solver still resolves contacts |
| 1.7 | `substeps4` (numSubSteps 0/4/8) | `substeps n0:h=02309c52da41ef33,z=1.49997782 n4:h=52204c986d237b60,z=1.49997935 n8:h=b186caf608002635,z=1.49997955` | substep count is bit-neutral |
| 1.8 | `detpairs` (deterministicOverlappingPairs 0/1) | `detpairs d0:h=02309c52da41ef33 d1:h=02309c52da41ef33 eq=True` | the flag moves bits in this scene |
| 1.9 | `reset` (run 120, `resetSimulation`, rebuild, 480) | `reset h=02309c52da41ef33 h2=02309c52da41ef33 eq=True` | a reset world differs from a fresh one |
| 1.10 | `perturb-track` (ball z +1e-9) | `perturb-track mag=1e-9 20:1.000e-09 60:1.000e-09 120:1.000e-09 240:4.466e-14 360:3.479e-13 480:6.804e-13 heq=False` | the offset is absorbed or explodes |
| 1.11 | `steps-saturated` (960 vs 961 steps) | `steps-saturated h960=f4610a1b8135297a h961=88423c4a585c192e eq=False nan=False` | a resting world reaches a fixpoint |
| 1.12 | `erp` (erp=0.9) | `erp def:h=02309c52da41ef33,z=1.49997782 0.9:h=02309c52da41ef33,z=1.49997782` | erp moves bits here |
| 1.13 | `warmstart` (warmStartingFactor=0) | `warmstart def:h=02309c52da41ef33,z=1.49997782 0.0:h=02309c52da41ef33,z=1.49997782` | warm-start factor moves bits here |
| 1.14 | `restore-state` | `restore-state hRestored=d724b9280dbb31a2 h120=d724b9280dbb31a2 eqRestore=True hPost=8627a9d5062f1396 h240=8627a9d5062f1396 eqPost=True` | save/restore loses bit-exactness |

### 1.2 Wall-clock / real-time (the stepSimulation question)

| # | arm | expected signature (verbatim, r1) | falsified if |
|---|---|---|---|
| 2.1 | `rt-off` | `rt-off flag=0 h=5f4966978bbf2af6 z=0.49999` | — |
| 2.2 | `rt-fast` (RT on, 480 stepSimulation calls, no sleeps) | `rt-fast flag=1 h=5f4966978bbf2af6 z=0.49999 120:3.78969868 240:0.490261648 360:0.499989561 480:0.49999` | `h` differs from `rt-off` |
| 2.3 | `rt-sleep4ms` (RT on, 4 ms wall sleep per call) | byte-identical to `rt-fast` | wall pacing moves the trajectory |
| 2.4 | `rt-sleep20ms` (RT on, 20 ms per call) | byte-identical to `rt-fast` | wall pacing moves the trajectory |
| 2.5 | `rt-idle` (RT on, 0.6 s idle, then 120 API calls ×4 ms) | `rt-idle flag=1 z0=5 z_after_0.6s_idle=5 z_after_120_api_calls=5` | any motion without stepSimulation |
| 2.6 | `rt-substeps4` (RT on + numSubSteps=4) | `rt-substeps4 h=2d59cdff9b464de3 z=0.49999` | — |
| 2.7 | `simtimescale` | `simtimescale 1.0:h=threw:…unexpected keyword argument 'simT…` (TypeError, both scales) | the factor is settable |

### 1.3 Sleep / deactivation

| # | arm | expected signature (verbatim, r1) | falsified if |
|---|---|---|---|
| 3.1 | `sleep-default` (resting ball, analytics on) | `sleep-default 1:iters=1,… 80:iters=2,v=1.94289029e-16,z=0.49999 … 1300:iters=2,v=1.94289029e-16,z=0.49999` — `numIterationsUsed=2` at every probe step to 1300 | the island ever stops iterating |
| 3.2 | `sleep-freeze` | `sleep-freeze freezeStep=80 finalV=1.94289029e-16,0 z=0.49999` | — |
| 3.3 | `sleep-disable` (`ACTIVATION_STATE_DISABLE_SLEEPING`) | `sleep-disable freezeStep=80 finalV=1.94289029e-16 z=0.49999` — identical to default | the flag is observable at rest |
| 3.4 | `sleep-velwrite` (write v=+5 to the rested body) | `sleep-velwrite zB=0.49999 vB=1.94e-16 vRead=5 z+1=0.520632014 z+31=1.05253767 v=3.61188341` | the write is stored-but-not-integrated |
| 3.5 | `sleep-teleport` (rested body → z=3) | `sleep-teleport zBefore=0.49999 postTeleport 1:2.99982951 … 120:1.78969868` (falls immediately) | a teleported rested body hangs |
| 3.6 | `sleep-force` (`ACTIVATION_STATE_SLEEP` mid-air) | `sleep-force midair z30=4.92092951 1:z=4.91566855,v=-1.26263146 … 60:z=4.31149208,v=-3.59098136` (keeps falling) + forced rest + velwrite `z+1=0.510225597` | forced sleep freezes motion |
| 3.7 | `sleep-wake-impact` (mover lands on sleeper, 1200 steps) | `sleep-wake-impact sleeperZ=0.49999 moverZ=1.49997583 sleeperV=1.94289029e-16` | — |
| 3.8 | `sleep-contact-persist` | `sleep-contact-persist froze~101 s10:cc=0 … s120:cc=1/d=-1e-05/nf=9.82 … s1400:cc=1/d=-1e-05/nf=9.82` | the contact count ever drops to 0 |
| 3.9 | `sleep-stale-manifold` (move ground away, no step) | `stale-manifold pre{n=1 d=-1e-05} postMove{n=1 d=-1e-05} closest{n=1 d=4.99999} postStep{n=0 d=} zNow=0.499819514 z+60=0.179994754` | getContactPoints sees the move pre-step |

### 1.4 NaN / degenerate inputs

| # | arm | expected signature (verbatim, r1) | falsified if |
|---|---|---|---|
| 4.1 | `neg-dt` (`setTimeStep(-1/240)`, 60 steps) | `neg-dt set=ok z=5 v=0 nan=False` | any motion or NaN |
| 4.2 | `zero-dt` | `zero-dt set=ok z=5 v=0 nan=False` | — |
| 4.3 | `nan-dt` (`setTimeStep(nan)`, 10 steps) | `nan-dt set=ok z=nan nan=True where=0.p+0.q+1.p+1.q` | NaN dt is contained |
| 4.4 | `nan-gravity` | `nan-gravity z=nan nan=True where=1.p+1.v` | — |
| 4.5 | `mass0` (createMultiBody mass=0) | `mass0 z=5 nan=False` | a mass-0 body falls |
| 4.6 | `neg-mass-create` / `nan-mass-create` | `neg-mass-create id=0 dynMass=-1 z=5 nan=False` / `nan-mass-create id=0 dynMass=nan z=5 nan=False` | a ≤0-mass body is dynamic |
| 4.7 | `neg-mass` (`changeDynamics(mass=-1)`) | `neg-mass set=ok dynMass=1 z=3.78969868 nan=False` | the write is stored |
| 4.8 | `damping` (linearDamping 0/1/1.5/-0.5/NaN, 120 steps) | `damping 0:…z=3.76227083 | 1:…z=4.17228129 | 1.5:…z=4.27577737 | -0.5:…z=3.78969868 | nan:…z=3.78969868` — no NaN anywhere | damping>1 NaNs, or negative is applied |
| 4.9 | `zero-box` / `neg-box` (halfExtents 0 / -0.5) | `…z=-1.58273451 nan=False contacts=0` (identical for both) | creation is refused, or the body rests |
| 4.10 | `coincident-spheres` (two r=0.5 at same pos, g=0) | `coincident i0 cc=1 n=[1,0,0/d=-1] sep=0.08 … i120 cc=0 sep=8.77316007 aX=4.38658004 bX=-4.38658004` | NaN normal or no separation |
| 4.11 | `coincident-spheres-gravity` | `coincG i240 sep=14.9745787 a=(7.48728934,…,0.49999) b=(-7.48728934,…,0.49999)` | they stay coincident or NaN |
| 4.12 | `neg-radius` / `zero-radius` | `threw:error:createCollisionShape failed.` + stderr `b3Warning[PhysicsDirect.cpp,1066]` | accepted silently |
| 4.13 | `zero-quat` (orientation (0,0,0,0)) | `zero-quat orn=nan,nan,nan,nan rawQ=fff8000000000000 nan=True where=1.p+1.q+1.v+1.w` | the zero quat is preserved or identity-fied |
| 4.14 | `nan-quat` | `nan-quat ornW=nan z=nan nan=True where=1.p+1.q+1.v+1.w` | — |
| 4.15 | `nan-pos` | `nan-pos nan=True where=1.p` (only position poisons; velocity stays finite) | — |
| 4.16 | `teleport-into-ground` (rest → z=0.2, 0.3 penetration) | `teleport-into-ground zBefore=0.49999 1:z=0.2239992,v=5.759808 … 60:z=1.30258519,v=3.10316239` | no upward ejection |
| 4.17 | `numsubsteps-neg` | `numsubsteps-neg set=ok z=4.69026842` (= default free-fall) | -1 is honored |
| 4.18 | `aabb-sleep-ccd` / `ccd-on` (r=0.05 ball at v=-500) | `ccd-off z=0.110300828` / `ccd-on z=0.110300828` | a difference (ccdSweptSphereRadius inert here) |

### 1.5 Friction / restitution combine

Slide scene: 1 kg box `(he 0.5)` at z=0.51 on big ground, v₀=(5,0,0),
600 steps, witness = final x.

| # | arm | expected signature (verbatim, r1) | falsified if |
|---|---|---|---|
| 5.1 | `fric-combine` | `g0.5/b0.5:x=4.08354903 g0.8/b0.8:x=1.79939656 g0.64/b1.0:x=1.79939656 g1.0/b0.64:x=1.79939656 g0.8/b1.0:x=1.46324194 g0.05/b0.05:x=9.66585442` | equal-product pairs differ |
| 5.2 | `fric-zero` (μ=0 both) | `fric-zero x=9.72455029` | μ=0 still brakes hard |
| 5.3 | `fric-neg` | `g-0.5/b0.5:stored=0.5,0.5 g0.5/b-0.5:stored=0.5,0.5 g-0.5/b-0.5:stored=0.5,0.5 g11/b1:stored=11,1,x=0.993892628 g-0.3/b0.9:stored=0.5,0.9,x=2.47307853` | negative friction is stored |
| 5.4 | `rest-combine` (bounce apex) | `g0/b0:apex=0 g0.9/b0.9:apex=0.851578572 g0.81/b1:apex=0.851578572 g0.9/b1:apex=1.02005302 g0.5/b0.5:apex=0.500280505` | equal-product pairs differ |

### 1.6 Contacts, mutation timing, misc

| # | arm | expected signature (verbatim, r1) | falsified if |
|---|---|---|---|
| 6.1 | `contact-rest` | `contact-rest s10:cc=0 s60:cc=0 s120:cc=1 … s1400:cc=1,z=0.49999` | cc drops to 0 at rest/sleep |
| 6.2 | `contact-order` | `contact-order pairs=0-1,0-1,0-1,0-1,0-2,0-2,0-2,0-2,0-3,0-3,0-3,0-3 cc=12` | order is not body-id grouped |
| 6.3 | `margin-change` (`collisionMargin` 0.001→0.45 at rest) | `margin-change margin 0.001->0.45 zBefore=0.499988605 zSameTick=0.499988605 1:…0.499988605 30:…0.499988605` | the margin write moves the resting box ≤30 steps |
| 6.4 | `mass-change` (mass→0 mid-flight at step 60) | `mass-change v0=-2.42374526 newMass=0 1:z=4.68016948,v=-2.42374526 … 30:z=4.38730026,v=-2.42374526` | gravity still applies after mass 0 |
| 6.5 | `gravity-change` (setGravity(0) between steps) | `gravity-change v0=-2.42374526 vAfter1Step=-2.42236221 vAfter2=-2.42098051` | takes >1 step to apply |
| 6.6 | `world-defaults` | `params=fixedTimeStep=0.004166… numSolverIterations=50 numSubSteps=0 useRealTimeSimulation=0`; `dynInfo mass=1 latFric=0.5 restit=0 … margin=0.5` | — |

### 1.7 Pass-2 arms (`probes_ext.py`, 22 arms × 3 reps, drift = 0)

`probes_ext.py` imports `probes` and registers into the same registry; reproduce
with `driver_ext.py --only <id>`. `an=` is the `reportSolverAnalytics=1` island
row (`i<islandId>/n<numBodies>/it<numIterationsUsed>`); **`EMPTY` means no island
was processed at all**, which §2.9 calibrates as the sleep signal.

| # | arm | expected signature (verbatim, r1) | falsified if |
|---|---|---|---|
| 7.1 | `sleep-force-mb` (reduced coords, forced `ACTIVATION_STATE_SLEEP` mid-air) | `sleep-force-mb 1:an=i-1/n1/it1,z=4.91566855,v=-1.26263146 … 120:an=i-1/n1/it1,z=3.13138128,v=-5.77575112` | the island is skipped or the body freezes |
| 7.2 | `sleep-force-max` (maximal coords, same force) | `sleep-force-max 1:an=EMPTY,z=4.92072396,v=0 … 120:an=EMPTY,z=4.92072396,v=0` | the analytics signal cannot express "asleep" |
| 7.3 | `sleep-rest-max` (maximal-coordinate body resting, 1400 steps) | `sleep-rest-max 1:an=i-1/n1/it1,cc=0 80:an=i0/n1/it2,cc=1 … 481:an=i0/n1/it2 … 1400:an=i0/n1/it2,cc=1` | a resting rigid body ever sleeps on its own |
| 7.4 | `sleep-disable-max` (maximal coords + `DISABLE_SLEEPING`) | `sleep-disable-max 80:an=i0/n1/it2,z=0.49999 … 1400:an=i0/n1/it2` — identical to 7.3 | the flag is observable |
| 7.5 | `sleep-motion-track` (last 5 steps of 1400) | `tail=1396:i0/n1/it2 … 1400:i0/n1/it2 finalV=1.94289029e-16` | the island ever stops being solved |
| 7.6 | `inf-dt` | `inf-dt set=ok z=nan nan=True inf=False where=0.p+0.q+0.v+0.w+1.p+1.q+1.v+1.w` | Inf dt is contained like NaN dt |
| 7.7 | `inf-gravity` | `inf-gravity z=nan nan=True inf=False where=1.p+1.v` | — |
| 7.8 | `inf-pos` (create at `z=+inf`) | `inf-pos created=0 nan=False inf=True where=0.p` | the body is refused or the Inf becomes NaN |
| 7.9 | `inf-vel` / `nan-vel` | `inf-vel x=nan nan=True inf=False where=1.p+1.v` / `nan-vel x=nan … where=1.p+1.v` | — |
| 7.10 | `inf-mass-create` | `inf-mass-create id=0 dynMass=inf z=nan nan=True where=0.p+0.q+0.v+0.w` | a +Inf mass behaves like a large finite mass |
| 7.11 | `inf-radius` / `nan-radius` | `inf-radius 0` (accepted, shape index 0) / `nan-radius threw:error:createCollisionShape failed.` | the refusal class is uniform in the radius argument |
| 7.12 | `nan-halfextents` | `nan-halfextents 0` (accepted, shape index 0) | NaN half-extents are refused |
| 7.13 | `nan-fric` / `inf-fric` | `nan-fric storedLatFric=0.5` (dropped) / `inf-fric storedLatFric=inf` (accepted) | the `>= 0` gate is NaN-only or Inf-only |
| 7.14 | `fric-bitexact` (same lattice as 5.1, full state hash) | `prod0808=3fe47ae147ae147c prod064=3fe47ae147ae147b ulpEq=False`; `g0.8/b0.8:h=54d2f436058159a8` ≠ `g0.64/b1.0:h=3e79f2f12524bf7e` = `g1.0/b0.64:h=3e79f2f12524bf7e` | equal-nominal-product pairs are bit-identical |
| 7.15 | `rest-bitexact` (restitution lattice, full state hash) | `g0.9/b0.9:h=0f0edc29d1a48f22` = `g0.81/b1.0:h=0f0edc29d1a48f22`; `g0.9/b1.0:h=b29bcd4686ea096a`; `g0/b0:h=3212060bf6dabef8` = `g0.5/b0.5:h=3212060bf6dabef8` | the restitution product rule is not bit-exact |
| 7.16 | `fric-zero-mech` (μ=0 residual decomposition) | `mu0:x=9.72455029[60:4.71540065\|300:3.82297219\|600:3.06464232] mu0+damp0:x=12.5[60:5\|300:5\|600:5] mu0+damp0+roll0+spin0:x=12.5[…] mu0+g0:x=9.72455241[…] mu0+g0+damp0:x=12.5[…]` | the residual is contact friction rather than default damping |
| 7.17 | `freeze-scene` (5-body canonical scene, 3000 steps) | `freeze-scene steps=3000 changes=3000 freezeStep=-1 hFinal=7e1278628a4d5a12` | the canonical scene reaches a bit-fixpoint |
| 7.18 | `freeze-ball` (single resting ball, 1400 steps) | `freeze-ball steps=1400 changes=79 freezeStep=80` | a single resting body never fixes its bits |

---

## 2. Observed rules

### 2.1 Fixed-step determinism: byte-exact, but creation order is not neutral **[O]**

- Same-scene runs are byte-identical across 3 fresh processes for **all 62
  arms** (drift=0), two complete worlds in one process are identical
  (`rebuild eq=True`), interleaving does not contaminate (`interleave
  eqA=True eqBC=True`), and `resetSimulation`+rebuild and
  `saveState`/`restoreState` round-trip bit-exactly (`reset`,
  `restore-state` both `eq=True`).
- **[O] Body creation order DOES move the hash** (`order-probe eq=False`,
  `76988acc55682c1a` vs `02309c52da41ef33`) — opposite of the r94 cannon-es
  result. **[I]** Bullet's island/constraint ordering follows object order,
  so a permuted creation permutes the solve order and the FP rounding.
- **`steps-saturated eq=False`**: stepping a fully-rested world still moves
  the hash. **CORRECTED IN PASS 2 — this is scene-dependent, not a property of
  pybullet.** `freeze-scene` (the same 5-body canonical scene, 3000 steps)
  changes the state hash on **every step** (`changes=3000`, `freezeStep=-1`),
  while `freeze-ball` (one sphere resting on the ground, 1400 steps) **does**
  reach a bit-fixpoint at **step 80** and holds it (`changes=79`). "pybullet
  worlds never reach a bit-fixpoint" is therefore false as written; the
  accurate statement is *the multi-body canonical scene does not fix its bits
  within 3000 steps, while a single resting body fixes at step 80*. This is
  independent of sleeping: the ball's island is still solved every step
  (§2.9) — the solver runs and returns identical bits. Pass 1's §1.3 row 3.8
  `froze~101` is the same phenomenon delayed by that arm's `i > 100` guard
  (`probes.py`, `sleep-contact-persist`), not a different freeze point.
- Solver knobs are observable (`iters` 1 vs 50 differ; 50≡150 → the
  convergence break saturates; `iters0` → ball falls through to z=-10.69
  with `contacts=0`), `numSubSteps` 0/4/8 differ (per-substep dt is
  `physicsDeltaTime/numSubSteps`), while `deterministicOverlappingPairs`,
  `erp=0.9` and `warmStartingFactor=0` were all bit-neutral *in this scene*.
- `perturb-track`: a 1e-9 offset is carried exactly through free fall
  (norm=1.000e-9 at steps 20–120) then amplified by contact solve to ~7e-13
  at step 480 — bounded, monotone-ish, no explosion.

### 2.2 stepSimulation: fixed dt only; there is NO wall-clock path in DIRECT **[O]**

Call chain (source): `pybullet_stepSimulation` (pybullet.c:345) →
`b3InitStepSimulationCommand` → `processForwardDynamicsCommand`
(PhysicsServerCommandProcessor.cpp:10554-10593):

```
deltaTimeScaled = m_physicsDeltaTime * simTimeScalingFactor      // :10581
numSubSteps>0:  stepSimulation(deltaTimeScaled, numSubSteps,
                               m_physicsDeltaTime/numSubSteps)   // :10586
numSubSteps=0:  stepSimulation(deltaTimeScaled, 0)               // :10591
```

- `m_physicsDeltaTime` defaults to `1/240`, `m_numSimulationSubSteps` to `0`
  (ctor, lines 1749-1750). The `timeStep` argument to Bullet's
  `stepSimulation` is **always the configured physicsDeltaTime — never a
  measured elapsed time**. Bullet's `m_localTime` accumulator
  (btDiscreteDynamicsWorld.cpp:391-398) therefore ingests a constant each
  call: `numSubSteps>0` runs exactly `numSubSteps` substeps of
  `physicsDeltaTime/numSubSteps`; `numSubSteps=0` runs one variable-branch
  step of `physicsDeltaTime`. The `maxSubSteps` clamp can never engage (the
  injected delta exactly equals `numSubSteps×substep`), and there is no
  `performance.now()`/`b3Clock` anywhere in this path.
- `setRealTimeSimulation(1)` is **set and read back but dead in DIRECT**:
  `rt-fast`, `rt-sleep4ms`, `rt-sleep20ms` are all byte-identical to
  `rt-off` (`h=5f4966978bbf2af6`), and `rt-idle` shows zero motion over
  0.6 s of idle wall time plus 120 non-step API calls. Source side: DIRECT
  connects via `b3ConnectPhysicsDirect` → `PhysicsDirect`
  (pybullet.c:575-577), which contains **no call to
  `stepSimulationRealTime`**; the wall-clock pump
  (`InProcessPhysicsClientExistingExampleBrowser::processServerStatus` →
  `m_clock.getTimeMicroseconds()`, SharedMemoryInProcessPhysicsC_API.cpp:196-205)
  belongs to the GUI/in-process-example-browser clients. The real-time
  branch itself (PhysicsServerCommandProcessor.cpp:15902-15917:
  `maxSteps = numSubSteps + 3`, `gDroppedSimulationSteps`) is never reached
  in DIRECT. **[?]** Whether it fires for `eCONNECT_GUI`/shared-memory
  clients is untested — irrelevant headless, flagged for completeness.
- `setTimeStep(-dt)`/`0`/`NaN`: all *accepted* (no validation). Negative and
  zero silently freeze the world (`z=5 v=0` — negative delta fails
  `m_localTime >= fixedTimeStep` so zero substeps run; zero trips
  `btFuzzyZero`). `NaN` poisons everything (`where=0.p+0.q+1.p+1.q` —
  including the static ground's transform, written back NaN).
- `simTimeScalingFactor` exists as a module-global in the processor
  (line 141) but is **not** a `setPhysicsEngineParameter` kwarg →
  TypeError; unreachable from Python in this build.
- **Real-time factor leak: none measurable.** Determinism in DIRECT is
  wall-clock-independent — the only nondeterminism source would be Python
  GC pauses, which don't affect state.

### 2.3 Refusal classes: explicit for radii, silent-drop for dynamics writes, silent-accept for boxes **[O]**

| input | behavior | class |
|---|---|---|
| `createCollisionShape(SPHERE, radius=-0.5)` | `pybullet.error: createCollisionShape failed` + `b3Warning PhysicsDirect.cpp:1066` | **explicit raise** |
| `createCollisionShape(SPHERE, radius=0)` | same failure | explicit raise — **zero is refused too** |
| `createCollisionShape(BOX, halfExtents=0 or -0.5)` | accepted; body falls through ground, lands at weird `z=-1.58273451`, `contacts=0` | silent-accept degenerate |
| `createMultiBody(mass=-1)` / `mass=NaN` | body created (`dynMass=-1`/`nan` stored); `isDynamic=(mass>0)` (line 12072) → **static**, never falls | silent → static |
| `changeDynamics(mass=-1 or -7)` | silently dropped: `pybullet.c` gates every dynamics write with `>= 0` (e.g. `if (mass >= 0)` ~line 1490) before calling `b3ChangeDynamicsInfoSetMass` | **silent drop at client layer** |
| `changeDynamics(lateralFriction=-0.3)` | silently dropped — `getDynamicsInfo` still reads default `0.5` | silent drop (same gate) |
| `changeDynamics(linearDamping=-0.5 or NaN)` | silently dropped (NaN fails `>=0`) → exactly the undamped trajectory `z=3.78969868` | silent drop |
| `linearDamping=1.5` | applied **unclamped** and monotone (`z` 3.7623→4.1723→4.2758 for d=0,1,1.5), no NaN — unlike cannon-es's `pow(1-d,dt)` poison | applied |
| `setTimeStep(-|0|NaN)`, `numSubSteps=-1` | all accepted silently | silent accept |
| `setPhysicsEngineParameter(simTimeScalingFactor=…)` | TypeError | explicit raise |
| `numSolverIterations=0` | accepted → contact solve disabled → bodies fall through silently | silent accept, degenerate |

### 2.4 Sleep: the machinery exists, fires internally — and is observably inert **[O]/[I]**

- btMultiBody sleep knobs exist and are on by default:
  `INITIAL_SLEEP_EPSILON=0.05` (squared-velocity), `INITIAL_SLEEP_TIMEOUT=2` s
  (btMultiBody.cpp:36-37), `m_canSleep=true` (ctor :110). After ~2 s of rest
  `checkMotionAndSleepIfRequired` (:2096-2129) flips `m_awake=false`, and
  `btMultiBodyDynamicsWorld::updateActivationState` (:127-170) drops the
  collider to `WANTS_DEACTIVATION`.
- **But nothing ever reaches `ISLAND_SLEEPING`.** **MECHANISM CORRECTED IN
  PASS 2.** Pass 1 attributed this to `btMultiBodyLinkCollider` not being a
  `btRigidBody`, so that `updateDeactivation` (btRigidBody.h:499) is never
  invoked. That is true but *not the whole cause*, and it is not the load-bearing
  one. The real cause is one level up: **the pybullet server never calls
  `addRigidBody` — it registers every body with `addCollisionObject` only**
  (`PhysicsServerCommandProcessor.cpp:10786, 10800, 10843, 10998, 11142`;
  `grep -rn "addRigidBody" examples/SharedMemory/` returns **nothing**). Every
  promotion path is therefore dead for *all* body types:
  - `btDiscreteDynamicsWorld::m_nonStaticRigidBodies` is only filled by
    `addRigidBody` (:552, :578), so it is **empty**; and
    `btDiscreteDynamicsWorld::updateActivationState` (:594-631) iterates exactly
    that array → `updateDeactivation` never runs on any body → no body ever
    reaches `WANTS_DEACTIVATION` → the island-manager promotion
    (`storeIslandActivationState`, btSimulationIslandManager.cpp:212-270, which
    sleeps an island iff no member is `ACTIVE_TAG`/`DISABLE_DEACTIVATION`) can
    never fire.
  - The only surviving route to `ISLAND_SLEEPING` is an explicit
    `forceActivationState` — `changeDynamics(activationState=…)`
    (PhysicsServerCommandProcessor.cpp:11028-11045) — which bypasses the
    bookkeeping, and which pass 2 shows *does* work (see next bullet).
  - Every skip gate in the world (`stepVelocities`, `addForce`, island
    processing — btMultiBodyDynamicsWorld.cpp:248,326,362,590,639,766,807)
    tests `col->getActivationState() == ISLAND_SLEEPING`, and `isActive()`
    (btCollisionObject.h:306) treats `WANTS_DEACTIVATION` as active — but that
    is now a *consequence*, not the cause. Result: no island ever sleeps, for
    multibodies **and** rigid bodies alike.
- **[O] Pass 2 calibration of the sleep detector, and the rigid-body surface
  (pass 1's own unknown #2).** Forcing `ACTIVATION_STATE_SLEEP` on a
  *maximal-coordinate* body (`useMaximalCoordinates=True`, a real `btRigidBody`)
  mid-air does exactly what the source predicts — the island disappears from the
  solver entirely and the body freezes:
  `sleep-force-max 1:an=EMPTY,z=4.92072396,v=0 … 120:an=EMPTY,z=4.92072396,v=0`.
  The same force on a reduced-coordinate multibody changes nothing:
  `sleep-force-mb … 120:an=i-1/n1/it1,z=3.13138128,v=-5.77575112` (still falling).
  Two consequences: (i) `EMPTY` analytics is a **validated** sleep signal, so
  "no island was ever skipped" is proof of non-sleep rather than an artifact of
  the instrument; (ii) pass 1's §1.3 bullet "even an explicit `goToSleep()` does
  not freeze a body" is true **only for the multibody path** — for a
  maximal-coordinate body it does freeze.
- **[O] A resting rigid body never sleeps either.** `sleep-rest-max` (maximal
  coords, resting on the ground, 1400 steps = 5.83 s ≫ the 2 s
  `gDeactivationTime`): `an=i0/n1/it2` at every probe from step 80 to 1400, with
  `cc=1`. `sleep-disable-max` is identical. So the null result holds on both
  body representations, and pass 1's §2.4 claim is *strengthened*, not weakened.
- Measured consequences:
  - `numIterationsUsed=2` at every probe step through 1300 — the solver
    iterates the resting contact **forever** (`sleep-default`).
  - Contact count stays `cc=1` and distance `-1e-05` for all 1400 steps
    (`sleep-contact-persist`, `contact-rest`) — the pair keeps being
    dispatched because `needsCollision` (btCollisionDispatcher.cpp:178)
    only skips when **both** bodies are inactive, which never happens.
    Same observable as Godot's `cc=1`, different mechanism (the pair is
    still *live*, not merely persisted).
  - A velocity write on a rested body integrates on the **very next step**
    (`sleep-velwrite z+1=0.520632014` = 5·dt exactly). cannon-es stored it
    unintegrated until `wakeUp()` — pybullet needs no wake call.
  - A teleported rested body falls immediately (`sleep-teleport`), and
    **forced** `ACTIVATION_STATE_SLEEP` mid-air keeps falling
    (`sleep-force` v −1.26→−3.59 over 60 steps) — on the multibody path
    (only) even an explicit `goToSleep()` does not freeze a body.
  - `ACTIVATION_STATE_DISABLE_SLEEPING` is byte-identical to default
    (`sleep-disable freezeStep=80` = `sleep-freeze` 80) — there is nothing
    to opt out of, observably.
- So: is sleeping opt-out? The internal flag is opt-out, but **[O] nothing
  observable ever sleeps in the `createMultiBody` path** — neither default,
  forced-sleep, nor disable-sleep changes any measured trajectory or
  contact behavior. (Rigid bodies created by the legacy
  `createBoxShapeCommand` path at line 12072 are plain `btRigidBody` and
  *could* sleep via `btRigidBody::updateDeactivation` — a different,
  unmeasured surface; **[?]**.)
- Stale-manifold window: after moving the ground away with
  `resetBasePositionAndOrientation`, `getContactPoints` still reports the
  last manifold (`n=1 d=-1e-05`) while `getClosestPoints` already reports
  the true gap (`d=4.99999`); the manifold is cleaned on the next step
  (`postStep n=0`). The only "stale contact" window in pybullet is between
  a transform write and the next `stepSimulation` — exactly the mutation
  boundary of §2.6.

### 2.5 Coincident spheres: fixed normal (1,0,0), ballistic separation **[O]**

`btSphereSphereCollisionAlgorithm.cpp:76-79`: `normalOnSurfaceB(1,0,0)`
when `len <= SIMD_EPSILON`. Measured: contact distance `-1.0`
(`len - (r0+r1)`), normal `(1,0,0)`, and the pair separates **ballistically**
along ±x — `sep` 0.08→0.16→0.48→2.42→8.77 over 120 steps under g=0
(`coincident-spheres`), and under gravity they land spread ±7.49 m apart
(`coincident-spheres-gravity`). The penetration impulse is huge because the
depth is a full diameter. No NaN. (cannon-es: `ni=(0,0,0)`, pair stayed
coincident — opposite containment choice.)

### 2.6 Shape mutation timing: there is no in-place collision-shape mutation **[O]**

- No Python-reachable API mutates an existing collision shape's
  dimensions: no radius/halfExtents setter exists; the only shape
  morphing hook in the protocol (`INIT_POSE_HAS_SCALING` →
  `setLocalScaling`, processor :11751-11759; client producer
  `b3CreatePoseCommandSetBaseScaling`, PhysicsClientC_API.cpp:2437) has
  **no binding in pybullet.c** — unreachable from Python.
  `resetVisualShapeData` is visual-only. So "shape mutation timing" is
  refused by absence: mutation = `removeBody` + `createMultiBody` (new id).
- The closest runtime mutations and their timing:
  - `changeDynamics(collisionMargin=0.45)` on a resting box: stored
    immediately (`getDynamicsInfo` reads 0.45), **zero observable effect
    over 30 steps** — the live manifold is not re-evaluated.
  - `changeDynamics(mass=0)` mid-flight: applies next step → the body
    becomes fixed-base (line 10774-10797 flips `CF_STATIC_OBJECT` +
    `setFixedBase(true)`) and keeps its **last velocity** ballistically
    (constant v=-2.42, no gravity — a frozen-velocity static body).
  - `setGravity(0)` between steps: effective next step (`vAfter1Step`
    already flat).
  - `resetBaseVelocity`/`resetBasePositionAndOrientation`: readable
    immediately, integrated next step — every command lands at the next
    `stepSimulation` boundary (single-threaded command processor; there
    is no intra-step mutation concept).

### 2.7 Friction & restitution combine: product, clamped ±10 / unclamped **[O]+source**

- `calculateCombinedFriction` = `body0->getFriction() * body1->getFriction()`
  clamped to ±10 (btManifoldResult.cpp:56-67); restitution = raw product
  (:68-71); rolling/spinning friction = cross mixture
  `a.roll·b.lat + b.roll·a.lat` (:31-49).
- Measured, **but the witness is weaker than pass 1's wording claimed
  (CORRECTED IN PASS 2)**: `slide(0.8,0.8) = slide(0.64,1.0) = slide(1.0,0.64)
  = 1.79939656` (all *nominal* products 0.64), distinct from
  `slide(0.8,1.0)=1.46324194` (product 0.8). Restitution apexes likewise:
  `apex(0.9,0.9) = apex(0.81,1.0) = 0.851578572` (product 0.81) vs
  `apex(0.9,1.0)=1.02005302`. **`x` is printed at 9 significant digits — it
  cannot witness a 1-ulp difference, so pass 1's "measured byte-exactly" was an
  over-claim.** Pass 2 re-ran the same lattice with the full state hash
  (`fric-bitexact`) and the claim is **false as stated**: `0.8*0.8` is
  `0x3fe47ae147ae147c` while `0.64` is `0x3fe47ae147ae147b` (**1 ulp apart**),
  and the resulting worlds differ — `g0.8/b0.8:h=54d2f436058159a8` vs
  `g0.64/b1.0:h=3e79f2f12524bf7e`. What *is* bit-exact: the product's
  commutativity (`g0.64/b1.0` ≡ `g1.0/b0.64`, same hash) and the restitution
  lattice (`rest-bitexact`: `g0.9/b0.9:h=0f0edc29d1a48f22` ≡
  `g0.81/b1.0:h=0f0edc29d1a48f22` — there `0.9*0.9` really does equal `0.81`
  in f64). So the **product rule** is confirmed; "equal-product pairs are
  byte-identical" holds only when the products are equal *as f64*, not when
  they are merely equal in decimal.
- Negative friction never reaches the combiner — dropped by the Python-side
  `>= 0` gate (§2.3). Product >10 clamps (g11/b1 stored 11 → same regime as
  μ=10).
- `fric-zero` x=9.72 m over 600 steps — μ=0 pair still decelerates slightly.
  **RESOLVED IN PASS 2 (`fric-zero-mech`): the residual is nothing but the
  default `linearDamping=0.04`, not contact friction, rolling/spinning friction
  or a solver floor.** With `linearDamping=0` the μ=0 box slides **exactly
  12.5 m** (5 m/s × 2.5 s) holding `vx=5` at steps 60/300/600 — the ideal
  frictionless result to the printed precision; adding
  `rollingFriction=0, spinningFriction=0` changes nothing further. The residual
  is gravity-independent (`mu0+g0` → `x=9.72455241`, same as `mu0`), and its
  velocity decay matches `v(t)=5·(1-0.04)^t`: 4.7154 / 3.8230 / 3.0646 at
  t=0.25/1.25/2.5 s. So §2.3's "linearDamping=1.5 is applied unclamped" and this
  cell are the same knob.

### 2.8 Cross-engine diffs vs r94 (cannon-es) / r93 (Godot)

| surface | pybullet 3.2.7 (these cells) | r94 cannon-es | r93 Godot |
|---|---|---|---|
| determinism, fixed step | byte-exact ×3, in-process + cross-world + reset | byte-exact | — |
| creation-order bit-neutrality | **fails** (`order-probe eq=False`) | held | — |
| wall clock in step | **none reachable in DIRECT**; RT flag dead | accumulator uses caller `elapsed`; wall-clock bailout exists | fixed |
| sleeping default | internally opt-out, **observably inert** — nothing ever sleeps | opt-in (`allowSleep=false` default) | sleeps by default |
| resting contact count | cc=1 forever (live dispatch) | n=0 once both sleep | cc=1 |
| coincident spheres | normal (1,0,0), ballistic split | ni=(0,0,0), never separates | — |
| negative radius | **createCollisionShape raises** | `Sphere(-0.5)` throws | accepted, no validation |
| negative mass/friction/damping write | silently dropped (`>=0` gate) | — | — |
| zero quaternion | **poisons to NaN p+q+v+w** | preserved (0,0,0,0) | — |
| solver iters observable | yes (1 vs 50 differ; 50≡150) | yes | — |
| world reaches bit-fixpoint | **never** (`steps-saturated eq=False`) | yes once asleep | — |
| depenetration | fast snap: v=+5.76 instantly, z 0.22→1.30/60 | fast snap similar | — |

Pass-2 amendment to the last row but one: the fixpoint row should read
**scene-dependent** — the 5-body scene never fixes (`freeze-scene
changes=3000`), a single resting body does at step 80 (`freeze-ball`).

### 2.9 Pass-2 findings **[O]**

**(a) Inf is a different poison class than NaN — and one input is a silent
no-op.** Pass 1 measured only NaN. The Inf family behaves neither like NaN nor
like a large finite number:

| input | measured | note |
|---|---|---|
| `setTimeStep(+inf)` | `z=nan where=0.p+0.q+0.v+0.w+1.p+1.q+1.v+1.w` | **wider** than `nan-dt`, which stopped at `0.p+0.q+1.p+1.q` — Inf dt also poisons the *velocities* and the static ground's transform |
| `setGravity(0,0,+inf)` | `z=nan where=1.p+1.v` | same shape as `nan-gravity` |
| `createMultiBody(…, basePosition=[0,0,+inf])` | `created=0 nan=False inf=True where=0.p` | **accepted and stored as `+inf`** — it does *not* become NaN, and the body exists |
| `resetBaseVelocity(linearVelocity=[+inf,0,0])` / `[nan,0,0]` | `x=nan where=1.p+1.v` for both | Inf and NaN velocities are indistinguishable after one step |
| `createMultiBody(mass=+inf)` | `dynMass=inf z=nan where=0.p+0.q+0.v+0.w` | *not* "behaves like a big mass": the whole body poisons, unlike `mass=0`/`mass=-1` (static, never falls) |
| `createCollisionShape(SPHERE, radius=+inf)` | **accepted** (shape index 0) | contrast `radius=nan` → raise, `radius<=0` → raise |
| `createCollisionShape(BOX, halfExtents=[nan,nan,nan])` | **accepted** (shape index 0) | NaN half-extents are not validated |
| `changeDynamics(lateralFriction=+inf)` | stored `inf` | contrast `nan` → dropped |

The unifying rule is exactly §2.3's client-side gate: the guards are written
`if (x >= 0)`, so **NaN is dropped and `+inf` passes** — the gate is a
NaN filter, not a sanity check. That is why `nan-fric` is a silent no-op while
`inf-fric` is stored, and why `inf-radius`/`nan-halfextents` differ from
`nan-radius`. Of the Inf inputs, only `setTimeStep(+inf)` is a *silent no-op
turned poison*: it is accepted (no raise) and then destroys every body's
transform, including the static ground's.

**(b) The `>= 0` gate also explains the refusal lattice's asymmetry.** Pass 1
recorded "sphere radius ≤0 raises, box halfExtents ≤0 are silently accepted" as
an unexplained inconsistency. It is the same gate read from the other side:
radius validation is a real check in the shape factory (`radius <= 0` → raise,
and it also rejects NaN), whereas half-extents have no such check at all, so
`0`, `-0.5` *and* `NaN` all pass. `+inf` radius slips past the `<= 0` test too.

**(c) The sleep detector is calibrated, and the null result is therefore
load-bearing.** See §2.4: `sleep-force-max` proves `EMPTY` analytics is a
reachable state (island genuinely skipped, body frozen), so every
`an=i0/n1/it2` in this report is positive evidence that the island *was*
solved at that step. Without that calibration, "nothing ever sleeps" could have
been an artifact of the reporting channel; with it, the claim is [O].

**(d) The canonical scene never fixes its bits; a single resting body does.**
`freeze-scene`: 3000/3000 steps change the hash. `freeze-ball`: 79 changes over
1400 steps, frozen from step 80. Both are consistent with (c) — sleeping is not
what stops the drift in `freeze-ball`; the solver simply returns identical bits.

---

## 3. Source anchors

All paths under `corpus/live/r95-scout/src/pkg/pybullet-3.2.7/`
(sdist-vendored, read as text — the `lsp` device has no server for C/C++
here; recorded as textual anchors, never semantic proof).

`examples/pybullet/pybullet.c`
| line | code | rule |
|---|---|---|
| 345 | `pybullet_stepSimulation` → `b3InitStepSimulationCommand` | §2.2 entry |
| 575-577 | `eCONNECT_DIRECT` → `b3ConnectPhysicsDirect()` | §2.2 no pump |
| ~1490 | `if (mass >= 0)` / `if (lateralFriction >= 0)` / `if (linearDamping >= 0)` guards before each `b3ChangeDynamicsInfoSet*` | §2.3 silent-drop gate |
| 1614-1660 | `getDynamicsInfo` — 12 fields, **no activation state** | §0 sleep unobservable |
| 1747-1772 | `setPhysicsEngineParameter` kwarg list (no `simTimeScalingFactor`) | §2.2 |

`examples/SharedMemory/PhysicsServerCommandProcessor.cpp`
| line | code | rule |
|---|---|---|
| 1749-1750 | `m_physicsDeltaTime(1./240.), m_numSimulationSubSteps(0)` | §2.2 defaults |
| 10581-10593 | `deltaTimeScaled = physicsDeltaTime·simTimeScalingFactor`; `stepSimulation(delta, numSubSteps, delta/numSubSteps)` / `stepSimulation(delta, 0)` | §2.2 fixed dt |
| 10682-10710 | `changeDynamics` activationState → `mb->wakeUp()/goToSleep()/setCanSleep/setCanWakeup` | §2.4 |
| 10722 | `mb->setSleepThreshold(...)` | §2.4 knob exists |
| 10774-10800 | `mass > 0` → fixedBase→dynamic; else `CF_STATIC_OBJECT`+`setFixedBase(true)` | §2.3/§2.6 mass switch |
| 11028-11045 | `changeDynamics` activationState → `rb->forceActivationState(ACTIVE_TAG / DISABLE_DEACTIVATION / ISLAND_SLEEPING)` | §2.4 the only live sleep route |
| 11142 | `addCollisionObject(rb, …)` in the dynamic-type switch — a `btRigidBody` added as a **collision object**, never `addRigidBody` | §2.4 pass-2 root cause |
| 10786, 10800, 10843, 10998 | `addCollisionObject(mb->getBaseCollider()/getLinkCollider())` | §2.4 pass-2 root cause |
| 11148 | `threshold2 = btSqrt(sleepThreshold)` | §2.4 |
| 11751-11759 | `INIT_POSE_HAS_SCALING` → `setLocalScaling` + `cleanProxyFromPairs` | §2.6 (unreachable from Python) |
| 12072 | `bool isDynamic = (mass > 0)` | §2.3 mass≤0 → static |
| 15792-15797 | `m_useRealTimeSimulation` setter | §2.2 |
| 15800-15920 | `stepSimulationRealTime(dtInSec,…)`: `maxSteps = numSubSteps+3`, `gDroppedSimulationSteps` | §2.2 the dead-in-DIRECT path |

`examples/SharedMemory/SharedMemoryInProcessPhysicsC_API.cpp`
| 196-205 | `m_clock.getTimeMicroseconds()` → `stepSimulation(dt)` per `processServerStatus` | §2.2 wall-clock enters only in example-browser clients |

`src/BulletDynamics/Dynamics/btDiscreteDynamicsWorld.cpp`
| 382-435 | `stepSimulation`: `m_localTime += timeStep`, substep count + `maxSubSteps` clamp; `maxSubSteps=0` variable branch | §2.2 accumulator is sim-time only |
| 552, 578 | `addRigidBody` — the **only** sites that push into `m_nonStaticRigidBodies` | §2.4 pass-2 root cause |
| 594-631 | `updateActivationState`: iterates `m_nonStaticRigidBodies`; a dynamic body gets only `WANTS_DEACTIVATION` (:614), `ISLAND_SLEEPING` is reserved for static/kinematic (:609) | §2.4 |
| 753 | `calculateSimulationIslands` ends with `storeIslandActivationState(...)` — the island promotion site | §2.4 |

`src/BulletCollision/CollisionDispatch/btSimulationIslandManager.cpp`
| 212-270 | `storeIslandActivationState`: an island sleeps iff **no** member is `ACTIVE_TAG`/`DISABLE_DEACTIVATION`; gated on `getIslandTag() == islandId` | §2.4 (pass 2) |
| 286-300 | `buildAndProcessIslands`: `islandSleeping` is true only if every member is `!isActive()`; `processIsland` (and hence the analytics row) is skipped when it is | §2.4/§2.9 the `EMPTY` signal |

`src/BulletDynamics/Dynamics/btRigidBody.h`
| 499-521 | `updateDeactivation`: accumulates `m_deactivationTime` while lin/ang velocity are under the sleep thresholds, else resets to 0 and forces `ACTIVE_TAG` | §2.4 |
| 522-537 | `wantsSleeping`: false for `DISABLE_DEACTIVATION`, `gDisableDeactivation`, `gDeactivationTime == 0` | §2.4 |

`src/BulletDynamics/Dynamics/btRigidBody.cpp:25-26` —
`gDeactivationTime = 2.`, `gDisableDeactivation = false` (defaults; nothing in
`examples/SharedMemory/` ever flips either, so the *flags* are not the reason
nothing sleeps — the empty `m_nonStaticRigidBodies` is).

`src/BulletDynamics/Featherstone/btMultiBody.cpp`
| 36-37 | `INITIAL_SLEEP_EPSILON=0.05`, `INITIAL_SLEEP_TIMEOUT=2` | §2.4 |
| 110-114 | `m_canSleep(canSleep)`, `m_canWakeup(true)` | §2.4 defaults |
| 2088-2129 | `wakeUp()/goToSleep()` toggle only `m_awake`; `checkMotionAndSleepIfRequired` | §2.4 |

`src/BulletDynamics/Featherstone/btMultiBodyDynamicsWorld.cpp`
| 127-170 | `updateActivationState`: collider gets only `WANTS_DEACTIVATION` | §2.4 the park |
| 248,326,362,590,639,766,807 | every skip gate tests collider `== ISLAND_SLEEPING` | §2.4 inert sleep |

`src/BulletCollision/CollisionDispatch/btCollisionObject.h:306`,
`btCollisionDispatcher.cpp:158-182`, `btManifoldResult.cpp:31-71`,
`btSphereSphereCollisionAlgorithm.cpp:57-89`, `btRigidBody.cpp:25`,
`btRigidBody.h:499-540,148-156`, `setup.py:73`
(`-DBT_USE_DOUBLE_PRECISION`) — as cited per section.

`examples/SharedMemory/PhysicsDirect.cpp:1066` — `b3Warning` +
"createCollisionShape failed" (the radius refusal site).

---

## 4. Falsification list

1. **"Two identical worlds diverge."** FALSIFIED: 62 arms ×3 reps,
   drift=0; rebuild/interleave/reset/restore all `eq=True`.
2. **"pybullet stepSimulation uses wall-clock."** FALSIFIED in DIRECT:
   `rt-off == rt-fast == rt-sleep4ms == rt-sleep20ms` byte-identical;
   idle wall time never advances the sim. (GUI-client path exists but is
   unreachable from DIRECT — flagged [?].)
3. **"Resting pybullet bodies sleep by default."** FALSIFIED observably:
   solver iterates forever (`iters=2` @1300), contacts persist cc=1,
   velocity writes and teleports act instantly, forced `SLEEP` mid-air
   keeps falling.
4. **"`ACTIVATION_STATE_DISABLE_SLEEPING` is needed to keep bodies live."**
   FALSIFIED: byte-identical to default.
5. **"A negative timestep errors or runs backwards."** FALSIFIED: silent
   freeze (zero substeps — `m_localTime` never reaches a negative
   `fixedTimeStep`).
6. **"Coincident spheres NaN the solver."** FALSIFIED: deterministic
   (1,0,0) normal, ballistic separation.
7. **"Negative shape parameters are uniformly refused."** FALSIFIED:
   sphere radius ≤0 raises, but box halfExtents ≤0 are silently accepted
   and fall through the ground.
8. **"`changeDynamics(mass=-1)` applies."** FALSIFIED: dropped at the
   Python `>=0` gate; stored mass unchanged.
9. **"Friction is combined by min/mean/default."** FALSIFIED: equal-product
   pairs are byte-identical while equal-min/avg pairs differ; product rule
   confirmed with source anchor. *(Pass-2 refinement: the "byte-identical"
   half of this item is itself refuted for friction — `0.8·0.8` and `0.64·1.0`
   differ by 1 ulp and produce different state hashes; only the product
   **rule** survives. See §2.7 and item 13.)*
10. **"getContactPoints is a live view."** FALSIFIED within-tick: it
    returns the stale manifold between a transform write and the next
    step (`postMove n=1` while `getClosestPoints` reports `d=4.99999`).
11. **"Collision-shape dimensions can be mutated in place from Python."**
    FALSIFIED: no such binding exists; `collisionMargin` writes are
    stored but observably inert on the live contact over 30 steps.
12. **"A stepped world reaches a fixpoint."** FALSIFIED:
    `steps-saturated eq=False` — extra steps keep moving the hash.
    *(Pass-2 refinement: this is scene-dependent — `freeze-ball` fixes at
    step 80. The item is true only for the multi-body scene.)*

### 4.1 Pass-2 falsifications (this seat)

13. **"Equal-nominal-product friction pairs produce byte-identical worlds."**
    FALSIFIED: `fric-bitexact` — `0.8*0.8 = 0x3fe47ae147ae147c` vs
    `0.64 = 0x3fe47ae147ae147b` (1 ulp), hashes `54d2f436058159a8` vs
    `3e79f2f12524bf7e`. Refutes pass 1's §2.7 wording, not its product rule.
14. **"NaN and +Inf are handled the same way by the `>= 0` gates."**
    FALSIFIED: `nan-fric` → dropped (stored 0.5); `inf-fric` → stored `inf`.
    The gate is a NaN filter.
15. **"`setTimeStep(+inf)` is contained like `setTimeStep(NaN)`."**
    FALSIFIED: `inf-dt` poisons `0.p+0.q+0.v+0.w+1.p+1.q+1.v+1.w`, strictly
    more fields than `nan-dt`'s `0.p+0.q+1.p+1.q` — it reaches the velocities
    and the static ground.
16. **"Shape parameters are validated for NaN."** FALSIFIED: `radius=NaN`
    raises, but `halfExtents=[NaN,NaN,NaN]` is accepted and `radius=+inf` is
    accepted.
17. **"`+inf` mass behaves like a very large finite mass."** FALSIFIED:
    `inf-mass-create` → `dynMass=inf` and the body's whole transform NaNs,
    unlike `mass=0`/`mass=-1` which are contained as static.
18. **"The solver-analytics channel cannot express 'asleep'."** FALSIFIED:
    `sleep-force-max` yields `an=EMPTY` with a frozen body — the channel is a
    validated sleep detector, which is what makes §2.4's null result [O]
    rather than an instrument artifact.
19. **"`goToSleep()` never freezes a body."** FALSIFIED for the
    maximal-coordinate path (`sleep-force-max` freezes at v=0); still true for
    reduced-coordinate multibodies (`sleep-force-mb` keeps falling).

---

## 5. Remaining unknowns

1. **[?] GUI / shared-memory / TCP client modes** — `stepSimulationRealTime`
   is live there (wall-clock pump exists); DIRECT cells say nothing about
   those transports. If a target ever runs `p.GUI`, the real-time factor
   question re-opens.
2. **[RESOLVED IN PASS 2] Plain `btRigidBody` paths** — measured directly via
   `useMaximalCoordinates=True` (`sleep-force-max`, `sleep-rest-max`,
   `sleep-disable-max`) and via a single-link URDF: **they never sleep either**,
   because the server registers them with `addCollisionObject` so
   `m_nonStaticRigidBodies` stays empty (§2.4). A *forced* sleep does freeze
   them. Remaining sub-question, narrowed: `btRigidBody`s created through
   soft-body internals were still not exercised.
3. **[?] `m_localTime` substep jitter** — with `numSubSteps>0` the
   accumulator could theoretically produce ±1 substep counts under FP
   rounding; the per-call substep count isn't readable (stepSimulation
   returns analytics, not counts), so only the end-state hash is
   rep-verified. Effect: unmeasured, bounded by `eq` of hashes.
4. **[?] Cross-host/cross-build determinism** — one compiler
   (`gcc 16.1.1`), one flag set; a different `-march`/FMA contraction
   could move bits. Unmeasured.
5. **[RESOLVED IN PASS 2] `fric-zero` residual dissipation** — it is the
   default `linearDamping=0.04`, nothing else: `linearDamping=0` restores the
   exact 12.5 m ideal slide with `vx≡5` (§2.7).
6. **[?] Threads/GIL** — all cells single-threaded; `stepSimulation` runs
   synchronously in-process so concurrent access ordering is untested.
7. **[?] Zero-box / neg-box resting depth** (`z=-1.58273451`, identical for
   both) — degenerate-shape penetration artifact, not root-caused.
8. **[?] `nan-mass-create` / `neg-mass-create` store their poisoned mass**
   (`dynMass=-1`/`nan`) yet behave static — the `isDynamic` gate contains
   them, but any later `changeDynamics(mass=+x)` on such a body is
   untested.

### 5.1 New unknowns opened by pass 2

9. **[?] `inf-pos` never decays.** A body created at `z=+inf` keeps
   `inf=True where=0.p` after 10 steps with gravity on — Inf + finite is still
   Inf, so it can never be rescued by simulation. Whether *any* pybullet write
   (`resetBasePositionAndOrientation`, `resetBaseVelocity`) can pull such a
   body back to a finite state is untested.
10. **[?] `inf-mass-create` poisoning path.** `mass=+inf` NaNs the transform
    rather than behaving as a heavy static body; the intermediate
    (`invMass = 0` then a 0·Inf in the gravity/inertia step) was not traced to
    a specific line.
11. **[?] Why the multi-body canonical scene never fixes its bits while a
    single resting ball does** (3000 vs 79 changes). Plausible candidates —
    warm-starting across 12 persistent contacts, the island's multi-body solve
    order, or residual solver drift in the 3-box stack — not separated.
12. **[?] URDF-loaded bodies** were spot-checked (single-link sphere, both
    `useMaximalCoordinates` values) and matched the `createMultiBody` results
    exactly, but that check was ad-hoc and is **not** in the pass-2 arm table;
    a multi-link URDF articulation was not exercised.

---

## 6. Dispatch questions → evidence

The eight r94 axes this lane was dispatched to resolve, each with the cells
that decide it. Every answer below is [O] (rep-stable receipt) unless marked.

| dispatch question | answer | cells |
|---|---|---|
| Fixed-step determinism: two worlds, interleaved, fresh ×3 — byte-identical? | **Yes**, all three shapes: fresh processes byte-identical (62×3 + 22×3, drift=0, and 186/186 stdout files byte-equal across two independent run dirs); two worlds in one process `eq=True`; interleaving `eqA=True eqBC=True`; `resetSimulation`+rebuild and `saveState`/`restoreState` round-trip too. **Caveat: body creation order is NOT bit-neutral** (`order-probe eq=False`) — the r94 cannon-es result does not transfer | 1.1–1.3, 1.9, 1.14 |
| Does `stepSimulation` use wall-clock or fixed dt? | **Fixed dt only.** The `timeStep` handed to Bullet is always the configured `physicsDeltaTime` (default 1/240); no clock is read anywhere in the DIRECT path. `setRealTimeSimulation(1)` is set-and-read-back but dead — `rt-fast`/`rt-sleep4ms`/`rt-sleep20ms` are byte-identical to `rt-off`, and 0.6 s of idle wall time moves nothing | 2.1–2.7, §2.2 source chain |
| Sleep/deactivation defaults — opt-out? | **Neither opt-in nor opt-out observably: nothing ever sleeps.** The knobs exist and default to "sleeping allowed", but no island ever reaches `ISLAND_SLEEPING` because the server never calls `addRigidBody`, so `m_nonStaticRigidBodies` is empty and `updateDeactivation` never runs (§2.4). `DISABLE_SLEEPING` is therefore byte-identical to default; a *forced* sleep does work on the maximal-coordinate path | 3.1–3.6, 7.1–7.5 |
| NaN/Inf poisoning | **Different classes.** NaN: 7 of 22 pass-1 cases poison; `setTimeStep(NaN)` → `0.p+0.q+1.p+1.q`. +Inf: accepted by every `>= 0` gate, and `setTimeStep(+inf)` poisons *more* (`…+0.v+0.w+1.v+1.w`); `+inf` position is stored as Inf and never decays; `+inf` mass NaNs the whole body. Gates are NaN filters, not sanity checks | 3.1–3.23, 7.6–7.13 |
| Coincident-sphere contact normal | **Fixed `(1,0,0)`** when the centre distance ≤ `SIMD_EPSILON`; contact distance `-1.0`; the pair then separates **ballistically** (±4.39 m after 120 steps at g=0, ±7.49 m under gravity). No NaN. Opposite containment choice to cannon-es (`ni=(0,0,0)`, pair stayed coincident) | 4.10, 4.11 |
| Negative radius/mass refusals | **Inconsistent, and the `>= 0` gate is the reason.** `radius ≤ 0` **raises** (`pybullet.error` + `b3Warning PhysicsDirect.cpp:1066`); `radius=NaN` also raises; but `radius=+inf` is **accepted**. `mass ≤ 0`/`NaN` at creation is **accepted** and becomes static; `changeDynamics(mass=-1)` is **silently dropped**; `halfExtents ≤ 0` *and* `NaN` are accepted | 4.5–4.7, 4.9, 4.12, 7.11–7.13 |
| Friction combine rule | **Raw product, clamped ±10** (`btManifoldResult.cpp:56-67`); restitution is the raw product, unclamped. Verified by source *and* by measurement — but the measurement must use a bit-exact witness: equal *decimal* products (0.8·0.8 vs 0.64·1.0) are 1 ulp apart and give different worlds. Negative μ never reaches the combiner (dropped by the gate); `+inf` does | 5.1–5.4, 7.14–7.16 |
| Contact persistence after both sleep (Godot keeps cc=1 — pybullet?) | **cc=1 forever — but for a different reason than Godot.** Nothing sleeps, so the pair is never merely *persisted*; it keeps being dispatched and re-solved every step (`cc=1`, `d=-1e-05`, `iters=2` through 1400 steps). The only stale-contact window is between a transform write and the next `stepSimulation` | 3.8, 6.1, 7.3 |
| Shape mutation timing | **There is no in-place shape mutation.** No Python-reachable setter for radius/halfExtents; the protocol's `INIT_POSE_HAS_SCALING` hook has no `pybullet.c` binding. Mutation = `removeBody` + `createMultiBody` (new id). Every other write (`collisionMargin`, `mass`, `setGravity`, `resetBase*`) lands at the next `stepSimulation` boundary; `collisionMargin` is stored but observably inert over 30 steps | 6.3–6.5, §2.6 |

### 6.1 Reproduce

```
cd corpus/live/r95-scout
./venv/bin/python driver.py      --reps 3   # pass 1, 62 arms  -> runs/<ts>/
./venv/bin/python driver_ext.py  --reps 3   # pass 2, 22 arms  -> runs/<ts>/
```

Both write `runs/<UTC-ts>/<arm>/rep{1,2,3}.{out,err,code}` plus `summary.json`
and print a per-arm `ok`/`DRIFT` line. `manifest.sha256` pins every input
(`venv/`, `src/`, `runs/`, tooling) except `__pycache__/` and itself.
