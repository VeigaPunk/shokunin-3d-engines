# r94 scout — three.js + cannon-es physics determinism in headless node

Lane: g3d · runtime `node v24.21.0` (V8 13.x, this host), no browser, no GL,
no renderer, no pixels. Dependencies pinned lane-local:
`cannon-es@0.20.0`, `three@0.186.1` (`corpus/live/r94-scout/proj/package-lock.json`).
Evidence: `corpus/live/r94-scout/` — `driver.mjs`, `audit.mjs`,
`proj/probes/` (`lib.mjs`, `scene.mjs`, `p_det.mjs`, `p_varstep.mjs`,
`p_nan.mjs`, `p_sync.mjs`, `p_material.mjs`, `p_parity.mjs`),
`runs/20261015T061500Z/` (**147 children** = 49 arms × 3 reps + `audit.txt` +
`driver-summary.json`), `manifest.sha256` (456 files), `RECEIPTS.md`.
`corpus/fixtures/**`, `reports/round-9[0-3]/**` and every other `corpus/live/*`
tree were read only; the only tracked-tree write is this report.
`git status --porcelain` at the end of this lane shows exactly one tracked
modification and three untracked entries: ` M corpus/fixtures/phys3d_events.gd`
(+1570 lines, an r89–r93 Godot author lane's work — **not this lane's**, left
untouched), `?? reports/round-1-20261015/`, `?? reports/round-89/r89-baseline.md`
(both pre-existing) and `?? reports/round-94/` (this report). `corpus/live/` is
gitignored, so the whole r94-scout evidence tree is untracked by design.

Reps: **49 arms × 3 fresh processes**, `drift=0` (`audit.mjs` byte-compares
stdout, stderr and exit code per rep): 44 positive arms exit 0, 5 negative arms
exit 2, **no arm exits 1**. Confidence labels: **[O]** observation
(receipt-pinned, rep-stable), **[I]** inference, **[?]** unknown / not decided
by these cells.

Canonical scene for every cell (one shape, disclosed): static ground
`Box(10,0.5,10)` at `(0,-0.5,0)` (top face `y=0`), `Sphere r=0.5` mass 1 at
`(0,5,0)`, three `Box(0.5,0.5,0.5)` mass 1 at `(1.5,4,0)`, `(-1.5,3,0)`,
`(0,2,0)`; gravity `(0,-9.82,0)`, `dt=1/60`, 240 steps = 4.0 s. Bodies are
added ground → ball → boxA → boxB → boxC. Witnesses are **exact IEEE-754 bit
patterns** (`Float64` → hex via `DataView`), never rounded decimals: `h` is
`sha256` over the index-keyed state (`position`, `quaternion`, `velocity`,
`angularVelocity`, the two interpolation buffers, `sleepState`) truncated to 16
hex chars, and `physHash` drops the interpolation buffers.

---

## 0. The two witnesses a cannon-es determinism claim needs

The engine keeps **two poses per body**, and which one you hash decides the
answer:

- `body.position/quaternion/velocity/angularVelocity` — the solver's state.
  `internalStep` is a pure function of these.
- `body.previousPosition/interpolatedPosition/previousQuaternion/
  interpolatedQuaternion` — a **render** buffer, written only by the
  accumulator branch of `World.step(dt, elapsed, maxSubSteps)`.

`varstep.fixed` shows the buffer is **never written in fixed-step mode**:

```
fixed interpPos=0.000000,5.000000,0.000000 pos=0.001539,1.499985,0.002550 eq=false
fixed prevPos=1.499985 interpQuat=0000000000000000000000000000000000000000000000003ff0000000000000 quat=bf6fb53159d64eadbea7a2d6e869c6033f64dfa14688e7c13fefffe97b9d0b4f qeq=false
```

After 240 fixed steps the ball is at `y=1.499985` while
`interpolatedPosition` still reads the **spawn pose `(0,5,0)`** and
`interpolatedQuaternion` still reads identity `(0,0,0,1)`. `varstep.exact`
shows the converse: with `elapsed ≡ dt` the physics is bit-identical to fixed
stepping (`physEq=true`) but the *render* witness differs (`eq=false`) because
the accumulator branch also writes and re-normalizes those buffers:

```
exact fixed=0e24fb5aca619253 elapsed=dt b95c69cacf7f74c7 eq=false physEq=true
exact fixed stepnumber=240 time=4.000000000 var stepnumber=240 time=4.000000000
exact fixed interpPos.y=5.000000000000
```

**[O] Any "byte-identical body state" cell must name its witness.** Every hash
below is the physics-only witness unless the interpolation buffer is the
subject.

---

## 1. Arm table (verbatim-armable cells)

Each cell is one fresh `node` child; `driver.mjs --only <id> --reps 3` reproduces
it. Command = `node proj/probes/<script> <args>` from `corpus/live/r94-scout/`.
All arms were run ×3 and are byte-identical across reps.

### 1.1 Fixed-step determinism (`p_det.mjs`)

| # | arm | expected signature (verbatim, r1) | falsified if |
|---|---|---|---|
| 1.1 | `base` | `base h=0e24fb5aca619253 y@1=4.997272 y@30=3.733635 y@60=1.561085 y@120=1.499985 y@240=1.499985`; `base contacts=0 fric=0 sleep=2,2,2,2 nan=false`; `base ball.x=0.001538955 ball.y=1.499985073 ball.q=-0.003870579,-0.000000704,0.002548041,0.999989263` | the hash moves across processes/reps |
| 1.2 | `rebuild` (two complete worlds in one process) | `rebuild h1=0e24fb5aca619253 h2=0e24fb5aca619253 eq=true`; `rebuild ids1=1,2,3,4 ids2=6,7,8,9` | the second in-process world differs |
| 1.3 | `interleave` (A 30 steps, B 30, A 210, C 30) | `interleave A=0e24fb5aca619253 base=0e24fb5aca619253 eqA=true`; `interleave B=e5253750feab8eed C=e5253750feab8eed eqBC=true` | a world's trajectory depends on physics that ran earlier in the same process |
| 1.4 | `order-probe` (reverse body-add order) | `order-probe h_forward=0e24fb5aca619253 h_reverse=0e24fb5aca619253 eq=true`; `solverEqOrder step60 forward=[0-2 0-2 0-2 0-2 0-2 0-2 0-2 0-2 0-3 … 1-4 1-4 0-2 0-2 0-2 0-2 0-3 … 1-4] reverse=[5-9 ×6 5-8 ×8 5-7 ×8 6-9 ×2] rawSame=false sortedSame=false` (**abbreviated with `×n`**; the receipt holds the full 36-entry lists) | the permuted equation order moves any body bit |
| 1.5 | `sap` | `broadphase naive=0e24fb5aca619253 sap=0b0f249979097645 eq=false` (y samples identical to 6 dp) | the broadphase is bit-neutral |
| 1.6 | `iters1` / `iters20` | `iters1 base=0e24fb5aca619253 variant=a87c85c948341344 eq=false ball.y=1.480328572423`; `iters20 … variant=d3fda7808f2de666 eq=false ball.y=1.499995948122` | `solver.iterations` is not observable |
| 1.7 | `tol0` / `tol1e-3` | `tol0 … variant=0e24fb5aca619253 eq=true`; `tol1e-3 … variant=b0737aa3df868fbc eq=false ball.y=1.499985068692` | tolerance is not observable |
| 1.8 | `iters` (solver subclass counts iterations) | `iters tol=1e-7 steps=240 mean=4.125 hist=0x141,10x99`; `iters tol=0.001 … mean=3.521 hist=0x141,5x2,6x4,7x19,8x30,9x2,10x42`; `iters tol=0 … mean=4.125 hist=0x141,10x99` | the default tolerance ever triggers the early break |
| 1.9 | `perturb-track` (`--mag 1e-9`) | `perturb-track mag=1e-9 20:1.000e-9 … 240:1.035e-9`; `… firstOver 1e-9@52 final=1.035024e-9 growth=1.035024` | a 1e-9 m offset amplifies (1e-6/1e-3 never crossed) |
| 1.10 | `steps-saturated` | `steps-saturated 240=0e24fb5aca619253 239=0e24fb5aca619253 eq=true sleep=2,2,2,2` | step 240 still changes the state (all bodies are asleep by then) |
| 1.11 | `contacts-forward` / `contacts-reverse` | `contacts forward step=60 n=8 fric=16 0-3/0-5 ×4 0-4/0-7 ×4`; `contacts reverse step=60 n=8 fric=16 0-4/0-7 ×4 0-3/0-5 ×4`; both `maxN=13` | the contact list order is not the body-add order |
| 1.12 | `neg-dt`, `neg-gravity`, `neg-steps-early` | `NEGATIVE REJECTED: … 0e24fb5aca619253->fef95d480950e291`; `…->bbd0b5e36f1bb4f2`; `…->ce7a6080f3d7329c` | any of those three inputs is bit-neutral |

### 1.2 Fixed step vs accumulator (`p_varstep.mjs`)

| # | arm | expected signature (verbatim, r1) | falsified if |
|---|---|---|---|
| 2.1 | `fixed` | `fixed stepnumber=240 time=4.000000000 ball.y=1.499985072545` | — |
| 2.2 | `exact` (`elapsed ≡ dt`) | `exact … eq=false physEq=true`; both `stepnumber=240 time=4.000000000` | physics differs, or the render buffer is not the only difference |
| 2.3 | `uneven` (same 4.0 s total, schedule `1/90 + 1/45`) | `uneven fixed=0e24fb5aca619253 uneven=c37c514dfccc07f3 eq=false physEq=false`; `uneven elapsedTotal=4.000000000 world.time=4.000000000 stepnumber=240 fixedStepnumber=240`; `uneven ball.y=1.499985072524 fixedBall.y=1.499985072545` | the delivery schedule is bit-neutral at equal substep count |
| 2.4 | `maxsub` (one call, `elapsed=0.5`, `maxSubSteps=10`) | `maxsub stepnumber=10 time=0.500000000 accumulator=4.163336e-17 ball.y=4.850047582139`; `maxsub-1000 stepnumber=30 time=0.500000000 ball.y=3.733634602311`; `maxsub-fixed30 stepnumber=30 time=0.500000000 ball.y=3.733634602311` | `world.time` tracks the substeps |
| 2.5 | `bailout` (`dt=1e-5`, `elapsed=1e-3`, `maxSubSteps=1000`) | `bailout … stepnumber=1 time=1.000000e-3 accumulator=1.000000e-5 ball.y=4.999999999018`; `bailout-control … maxSubSteps=1 stepnumber=1` | the 100 intended substeps ever run |
| 2.6 | `interp` | `interp fixed interpPos=5.000000000 pos.y=1.561084641`; `interp elapsed=dt interpPos.y=1.552395033996 pos.y=1.561084640788 prevPos.y=1.552395033996 interpEqPos=false`; `interp elapsed=dt+1/240 acc=1.666667e-2 interpPos.y=1.499020405350 pos.y=1.499020405350 prevPos.y=1.498636322432`; `… interpQuat=…1344… quat=…1345… qeq=false` | the buffer holds the live pose |
| 2.7 | `sleep-phase` | `sleep-phase fixed   1@132 2@132 3@118 4@101 time=4.000000000`; `sleep-phase uneven  6@134 7@134 8@120 9@102 time=4.000000000`; `sleep-phase elapsed=dt 11@132 12@132 13@118 14@101` | sleep onset is schedule-independent |
| 2.8 | `neg-elapsed` | `NEGATIVE REJECTED: … b95c69cacf7f74c7->f296e9e78042d55b stepnumber=240,240` | a 1e-6 s elapsed jitter is absorbed |

### 1.3 Degenerate setups and NaN classes (`p_nan.mjs --case all`, 22 cases)

| # | case | expected signature (verbatim, r1) | falsified if |
|---|---|---|---|
| 3.1 | `zero_dt` | `nan zero_dt nan=false inf=false where=none … stepnumber=240 time=0 invDt=Infinity` | `dt=0` poisons the state |
| 3.2 | `neg_dt` | `nan neg_dt nan=false inf=false … time=-3.9999999999999907` | a negative `dt` NaNs |
| 3.3 | `nan_dt` | `nan nan_dt nan=true inf=true where=0.p+0.q+0.v+0.w … stepnumber=2` | `step(NaN)` stays finite |
| 3.4 | `inf_elapsed` | `nan inf_elapsed nan=false inf=false … afterInf=10 accumulator=NaN stepnumber=10 time=Infinity` | the world keeps stepping after an `Infinity` elapsed |
| 3.5 | `nan_elapsed` | `nan nan_elapsed … accumulator=NaN stepnumber=0 time=NaN` | same, NaN elapsed |
| 3.6 | `maxsub0` | `nan maxsub0 … stepnumber=0 time=1.0000000000000013 accumulator=0 y=5.000000000` | `maxSubSteps=0` still advances the sim |
| 3.7 | `iters0` | `nan iters0 nan=false inf=false … contacts=0 sleep=0 y=-72.845108129` | a zero-iteration solver still holds contacts |
| 3.8 | `nan_gravity` | `nan nan_gravity nan=true inf=true where=0.p+0.v … gravity.length=NaN` | — |
| 3.9 | `nan_mass` | `nan nan_mass nan=true inf=true where=0.p+0.v … invMass=0` | `mass=NaN` is contained by `invMass=0` |
| 3.10 | `mass0_dynamic` | `nan mass0_dynamic nan=false inf=false … type=1 invMass=0 y=5.000000000` | a mass-0 DYNAMIC body moves |
| 3.11 | `damping_gt1` | `nan damping_gt1 nan=true inf=true where=0.p+0.v … v=NaN pow(1-1.5,dt)=NaN` | — |
| 3.12 | `damping_eq1` | `nan damping_eq1 nan=false inf=false … v=-0.163666667 y=4.972722222` | damping 1.0 zeroes the velocity |
| 3.13 | `angdamping_gt1` | `nan angdamping_gt1 nan=true inf=true where=0.q+0.w … w=NaN,NaN,NaN` | — |
| 3.14 | `zero_box` | `nan zero_box nan=false inf=false … r=0 inertia=0,0,0 y=-0.000001485` | a zero-extent Box NaNs |
| 3.15 | `coincident_spheres` | `nan coincident_spheres nan=false inf=false … contacts=1 ni=0,0,0 cC=2.000110769230769 sep=0.000000000 a.v=0.000000000` | a zero contact normal NaNs, or separates the pair |
| 3.16 | `coincident_spheres_gravity` | `nan coincident_spheres_gravity … contacts=1 sep=0.000000000 a.y=-14.672741986` | the pair separates under gravity |
| 3.17 | `neg_radius` | `nan neg_radius threw="The sphere radius cannot be negative."` | `Sphere(-0.5)` is accepted silently |
| 3.18 | `zero_quat` | `nan zero_quat nan=false inf=false … q=0.000000000,0.000000000,0.000000000,0.000000000` | the engine replaces a zero quaternion |
| 3.19 | `nan_quat` | `nan nan_quat nan=true inf=true where=0.q … q=NaN y=4.959092470` | a NaN quaternion stays out of the position |
| 3.20 | `nan_radius_midsim` | `nan nan_radius_midsim nan=false inf=false … r=NaN y=0.459090028` | a NaN radius poisons the state instead of disabling the contact |
| 3.21 | `teleport_into_ground` | `nan teleport_into_ground nan=false inf=false … y=-14.995366460 v=-18.747073409` | a 1 m interpenetration ejects the body upward |
| 3.22 | `nan_payload` | `nan nan_payload … rawQ=7ff8000000000000 rawW=fff8000000000000 pow=fff8000000000000` | the raw NaN bits drift (see RECEIPTS) |
| 3.23 | summary line | `nan-summary cases=22 nan=7 [nan_dt,nan_gravity,nan_mass,damping_gt1,angdamping_gt1,nan_quat,nan_payload] inf_only=0 []` | the NaN set moves |

### 1.4 three.js `Object3D` ↔ `Body` sync (`p_sync.mjs`)

Scene: tumbling `Box(0.5,0.5,0.5)` mass 1 dropped from `(0.05,3,0.02)` with
`quaternion.setFromEuler(0.4,0.7,0.2)` and `angularVelocity=(0.3,1.1,-0.6)`,
240 steps; `mesh()` = `THREE.Mesh(BoxGeometry(1,1,1), MeshBasicMaterial)`.

| # | arm | expected signature (verbatim, r1) | falsified if |
|---|---|---|---|
| 4.1 | `full` | `full dPos=0.000e+0 dRotDeg=0.000e+0 objQ=… bodyQ=… qEq=true`; `full matrixWorld[12,13,14]=0.750712862,0.499998137,-0.320141411 body=0.750712862,0.499998137,-0.320141411` | a full copy leaves any error |
| 4.2 | `pos_only` | `pos_only dPos=0.000e+0 maxRotDeg=125.505113 finalRotDeg=124.514597`; `pos_only objQ=0000…3ff0000000000000 bodyQ=…` | a position-only sync keeps the rotation |
| 4.3 | `quat_only` | `quat_only dPos=0.956939 dRotDeg=0.000e+0 objPos=0.000000,0.000000,0.000000 bodyPos=0.750548,0.499998,-0.320017` | a quaternion-only sync keeps the position |
| 4.4 | `nested` (body world pose → child local transform, rotated parent) | `nested naiveWorld=9.679859,0.499998,-0.750713 bodyWorld=0.750713,0.499998,-0.320141 naiveErr=8.939521`; `nested local=0.320141,0.499998,-9.249287 fixedWorld=0.750713,0.499998,-0.320141 fixedErr=0.000e+0` | the parent transform is applied once |
| 4.5 | `scale_parent` (parent scaled ×2) | `scale_parent naiveWorld=9.359717,0.999996,-1.501426 bodyWorld=0.750713,0.499998,-0.320141 naiveErr=8.704044`; `scale_parent local=0.160071,0.249999,-4.624644 fixedWorld=0.750713,0.499998,-0.320141 fixedErr=0.000e+0` | the error is scale-free |
| 4.6 | `zero_quat` (cannon zero quaternion copied into three) | `zero_quat cannonQ=0000…(64) threeCopied=0000…(64) worldQ=0.000000,0.000000,0.000000,1.000000 threeNormalized=0.000000,0.000000,0.000000,1.000000`; `zero_quat matrixWorld=[1.000,0.000,0.000,0.000,0.000,1.000,0.000,0.000,0.000,0.000,1.000,0.000,1.000,2.000,3.000,1.000] detScale=1.000000` | three propagates the degeneracy |
| 4.7 | `interp` (copy the interpolation buffer in fixed-step mode) | `interp interpPos.y=5.000000000 bodyPos.y=0.421212608 objWorld.y=5.000000000 dPos=4.578787` | the mesh follows the body |
| 4.8 | `matrix_auto` | `matrix_auto manualComposeErr=0.000e+0 autoUpdateOffStaleErr=0.957109 pLen=0.957109` | `matrixAutoUpdate=false` still honours `position`/`quaternion` |
| 4.9 | `lag` (read the world matrix before `updateMatrixWorld`) | `lag maxStaleGap=0.108755 afterUpdateErr=0.000e+0` | the pre-update read is current |
| 4.10 | `neg_wxyz` | `NEGATIVE REJECTED: sync neg_wxyz w-first ordering rotates the mesh by 172.360 deg` | the ordering is harmless |

### 1.5 Material / ContactMaterial lattice (`p_material.mjs`)

Slide scene: `Box(0.5,0.5,0.5)` mass 1 at `y=0.501` with `v=(5,0,0)`,
180 steps (`fixedRot` = the same body with `fixedRotation: true`).
Bounce scene: `Sphere r=0.5` mass 1 dropped from `y=3`, 300 steps.

| # | mode | expected signature (verbatim, r1) | falsified if |
|---|---|---|---|
| 5.1 | `no_material` | `material no_material slideX=1.087853297 … fricEqMax=8 defaultCm=f0.3/r0 pairCm=none apex=0.520553278 bounces=0` | — |
| 5.2 | `mat_defaults` (materials with `friction=-1, restitution=-1`) | byte-identical to `no_material` | a bare `Material` changes anything |
| 5.3 | `mat_pair_05` (both `friction=0.5`) | byte-identical to `no_material` (`slideX=1.087853297`, `fixedRot slideX=0.090261397`) | μ is observable in this configuration |
| 5.4 | `mat_one_sided` (ground 0.5, body -1) | byte-identical to `no_material` | — |
| 5.5 | `cm_pair_09` (`ContactMaterial(f=0.9)`) | `… pairCm=f0.9/r0` and byte-identical slide to `no_material` | the registered ContactMaterial is ignored |
| 5.6 | `cm_pair_09_rev` (registered in the opposite order) | `… pairCm=f0.9/r0`, byte-identical | the table lookup is order-sensitive |
| 5.7 | `cm_and_mat_fric` (CM 0.9 **and** materials 0.5) | `pairCm=f0.9/r0`, slide identical to `mat_pair_05` | the CM friction overrides the material product |
| 5.8 | `mat_pair_rest05` (both materials `restitution=0.5`) | `slideX=1.107635797 apex=0.751545694 bounces=1` | the product 0.25 is ignored |
| 5.9 | `cm_pair_rest09` (CM restitution 0.9, materials -1) | `slideX=1.134735883 pairCm=f0.3/r0.9 apex=2.728244191 bounces=1` | the CM restitution is ignored |
| 5.10 | `cm_and_mat_rest` (CM 0.9 **and** materials 0.5) | `apex=0.751545694` — the 0.25 product wins | the CM restitution overrides the material product |
| 5.11 | `cm_rest_one_sided` (ground restitution 0.5, body -1) | `apex=2.728244191` — the CM value wins | one-sided material restitution is honoured |
| 5.12 | `default_cm_rest06` (`world.defaultContactMaterial.restitution=0.6`) | `defaultCm=f0.3/r0.6 … apex=1.594171507` | the default CM is ignored |
| 5.13 | `fric_zero` (both `friction=0`) | `slideX=14.777510652 slideVx=4.854406205 fricEqMax=0`; `fixedRot … 14.774885616 vx=4.851495000` | a μ=0 pair still creates friction equations |
| 5.14 | `shape_material` (shape material 0.9, body material -1) | `fricEqMax=8`, slide identical to `no_material` | the shape material is not consulted |
| 5.15 | `friction_gravity` (gravity 0, `frictionGravity=(0,-9.82,0)`) | `slideX=14.774885616 … fricEqMax=0 apex=-1.000000000` | `frictionGravity` substitutes for gravity |
| 5.16 | `fric_sweep` (sphere, `fixedRotation`) | `mu=0.05 slideX=8.337526`; `mu=0.3 slideX=0.279647`; `mu=0.9 slideX=0.090271`; `fricEqMax=2`; `mu=0 slideX=164.671371 fricEqMax=0` | the stopping distance is μ-independent |

### 1.6 cannon-es vs the r93-measured Godot semantics (`p_parity.mjs`)

| # | arm | expected signature (verbatim, r1) | falsified if |
|---|---|---|---|
| 6.1 | `world_defaults` | `world_defaults world.allowSleep=false world2.allowSleep=true body.allowSleep=true body.sleepSpeedLimit=0.1 body.sleepTimeLimit=1 default_dt=0.016666666666666666 solver.iterations=10 solver.tolerance=1e-7 broadphase=NaiveBroadphase defaultContactMaterial=f0.3/r0` | the world opts into sleeping by default |
| 6.2 | `shape_shrink` (r=0.5→0.25 while resting) | `shape_shrink pre n=1 y=0.499998 writeTick n=1 y=0.499998 v=0.000000 nextTick n=0 y=0.497270 v=-0.163667`; `seq s122:0.491815/0 … s134:0.213789/0 s135:0.221989/1 … s141:0.247796/1` | the write tick already re-evaluates the contact |
| 6.3 | `shape_grow` (r=0.5→1.0 while resting) | `shape_grow before=0.499998 seq s121:0.653801/1 s122:0.804851/1 s123:0.953147/1 s124:1.098692/1 s125:1.241484/0 …` | the ejection is a slow push, or it is clamped to the new rest height |
| 6.4 | `shape_shared` (one `Sphere` object in two bodies) | `shape_shared sameObject=true yBefore=0.499998,0.499998 yAfter=0.249998,0.249998 sharedRadius=0.25` | the shape is copied per body |
| 6.5 | `sleep_natural` (`allowSleep: true`) | `sleep_natural world.allowSleep=true sleepStep=62 state=2 y=0.499998 v=0.000000`; `sleep_natural velWrite y=0.499998 v=4.999163 state=2 thenWakeUp y=0.580575 v=4.834659 state=0` | a velocity write wakes or moves a sleeping body |
| 6.6 | `sleep_wake` (a body dropped on the sleeper) | `sleep_wake sleptBefore=2 … rows 401:2.9973/2/0 … 431:1.6493/2/0 436:1.4633/0/2`; `final sleeperState=1 sleeperY=0.499987 moverY=1.499978 contacts=2` | an incoming body leaves the sleeper asleep |
| 6.7 | `contact_rest` | `contact_rest allowSleep=false s10:n=1/ball=0/ground=0/y=0.499927 … s400:n=1/ball=0/ground=0/y=0.499998 allowSleep=true s10:n=1/ball=1/ground=1/y=0.499927 s100:n=0/ball=2/ground=2/y=0.499998 … s400:n=0/ball=2/ground=2/y=0.499998` | the pair survives both bodies sleeping |
| 6.8 | `multishape_order` (two spheres, offsets ∓0.6) | `multishape_order shapeIds=2,3 offsets=-0.6,0.6 rows s1:n=0 [] s2:n=2 [si0-sj0 si1-sj0] s3:n=2 [si0-sj0 si1-sj0] s30:n=2 …` | the per-shape order is not the shape-array order |
| 6.9 | `sleep_thresholds` | `sleep_thresholds defaults=limit0.1/time1 limit=0.1/time=1:62 limit=0.01/time=1:67 limit=0.5/time=1:61 limit=0.1/time=0.1:9 limit=0.1/time=5:303 limit=0/time=1:never limit=0.5/time=0:2` | the sleep knobs are inert |

---

## 2. Observed rules

### 2.1 A fixed-step world is reproducible to the bit — in-process, cross-world, cross-process **[O]**

- Two complete worlds built and stepped back to back in one process are
  byte-identical (`rebuild eq=true`), even though their body ids differ
  (`ids1=1,2,3,4 ids2=6,7,8,9`) — the ids are process-global counters and must
  stay out of the witness.
- Interleaving does not contaminate: a world stepped 30, paused while another
  world ran 30, then stepped 210 more is byte-identical to the standalone run
  (`eqA=true`), and a world built *after* another has run is byte-identical to
  one built in a fresh process (`B == C = e5253750feab8eed`). The module-level
  contact/friction equation pools (`World_step_oldContacts`,
  `World_step_frictionEquations`) leak nothing observable here.
- All 44 positive arms are byte-identical across 3 fresh processes
  (`drift=0`).

**[O] The body-add order is bit-neutral in this scene while the solver's
equation order is not.** Reversing the add order permutes the equation list
(`rawSame=false`: `0-2 ×8, 0-3 ×8, 0-4 ×6, 1-4 ×2` becomes
`5-9 ×6, 5-8 ×8, 5-7 ×8, 6-9 ×2`, i.e. the same pairs in reverse), yet all
four bodies' position/quaternion/velocity/angularVelocity bits are identical
(`h_forward == h_reverse == 0e24fb5aca619253`). The contact list order does
follow the add order (`contacts-forward` vs `contacts-reverse`). This is one
scene with symmetric ground contacts; whether the invariance survives an
asymmetric multi-contact configuration is **[?]** — the cells here do not
decide it, and the mechanism (Gauss-Seidel on a permuted system reaching the
same bits) is **[I]**, not read off the source.

### 2.2 The solver's early break is a real, data-dependent branch **[O]**

`GSSolver.solve` returns the iteration it stopped on and breaks when
`deltalambdaTot² < tolerance²`. Measured over 240 steps of the canonical scene:

| tolerance | iterations histogram | mean |
|---|---|---|
| `1e-7` (default) | 141 steps with **0 equations**, 99 steps with **10** | 4.125 |
| `0` | identical to `1e-7` | 4.125 |
| `1e-3` | 0×141, 5×2, 6×4, 7×19, 8×30, 9×2, 10×42 | 3.521 |

`iter=0` is the "no equations at all" case (the ball is in free fall, or every
body is asleep and the broadphase skips the pair). **[O] `tolerance=1e-7` never
triggers the break in this scene** — `tol0` and the default give byte-identical
trajectories — while `tolerance=1e-3` does, and moves the resting height
(`ball.y=1.499985068692` vs `1.499985072545`). `solver.iterations` 1/20 both
move the trajectory (1 iteration: the ball sinks to `1.480328572423`).

### 2.3 Accumulator stepping: `world.time` is wall-clock, not sim time **[O]**

Three independent measurements pin the same rule:

- `maxsub`: one call with `elapsed=0.5` and `maxSubSteps=10` runs **10**
  substeps but advances `world.time` by the full **0.5 s** (`stepnumber=10
  time=0.500000000`, ball still at `4.850047582139` instead of `3.733634602311`
  after the 30 substeps that `maxSubSteps=1000` gives). The clamp silently
  drops 20 substeps of sim time; `world.time` never notices.
- `bailout`: the loop's own budget is `performance.now() - t0 > dt*1000`. With
  `dt=1e-5` that budget is 0.01 ms, smaller than one `internalStep`, so the
  loop breaks after **one** substep: `stepnumber=1` where `maxSubSteps=1000`
  should have given 100 — byte-identical to the `maxSubSteps=1` control, and
  again with `time=1.000000e-3`. **[I]** the number of substeps in that mode is
  a function of host speed/load, so accumulator stepping is not reproducible
  across machines; these cells bound the branch, they do not measure another
  host.
- `sleep-phase`: `sleepTick(world.time)` decides sleep onset, and in accumulator
  mode `world.time` advances by `elapsed`. With the same substep count (240) and
  the same total time (4.0 s) the schedule `1/90 + 1/45` pushes every sleep
  onset 1–2 steps later than fixed stepping (`1@132 2@132 3@118 4@101` →
  `6@134 7@134 8@120 9@102`), while `elapsed ≡ dt` reproduces the fixed
  onsets exactly. This is why `uneven` is `physEq=false` at equal step count:
  the *delivery schedule*, not the step count, moves the physics.
- The `accumulator % dt` trim is FP-fragile: after the bailout the retained
  residue is `1.000000e-5` — a full `dt` (measured `(1e-3 - 1e-5) % 1e-5 =
  9.999999999999914e-6`).

### 2.4 The interpolation buffer is a second, stale pose **[O]**

- Fixed-step mode never writes it: `interpolatedPosition` stays at the spawn
  pose `(0,5,0)` for 240 steps while the body lands at `y=1.499985`.
- Accumulator mode writes it as `previousPosition.lerp(position, t)` with
  `t = accumulator/dt` (plus `previousQuaternion.slerp(...).normalize()`), so at
  `t≈1` it equals the live pose and at `t≈0` it is the **previous step's** pose
  (`interpPos.y=1.552395033996` vs `pos.y=1.561084640788`).
- The quaternion path is not a bit-exact copy even at `t≈1`
  (`interpQuat …3d3e1344…` vs `quat …3d3e1345…`, `qeq=false`) — the slerp +
  normalize moves the last bit.

### 2.5 NaN classes: six inputs poison the state, and two freeze the world silently **[O]**

**[O] Poisoning the body state (7 of 22 cases carry NaN, from 6 distinct
inputs; `nan_payload` re-runs `angdamping_gt1` as the raw-bits witness):**
`step(NaN)`, `gravity=NaN`, `mass=NaN` (poisons through the force term even
though `invMass` reads `0`), `linearDamping>1` and `angularDamping>1`
(`pow(1-1.5, dt)` is NaN; `damping=1` is safe and behaves as a hard
stop-then-refall: `v=-0.163666667` = one `g·dt` per step), and a NaN
`body.quaternion`.

**[O] Freezing the world silently (no NaN in any body, no error):**
`world.step(dt, Infinity, n)` and `world.step(dt, NaN, n)` both leave
`accumulator = NaN`, after which `accumulator >= dt` is false forever — the
world runs 10 substeps (Infinity) or 0 (NaN) and then **never steps again**,
while `world.time` keeps advancing (`time=Infinity` / `time=NaN`). The same
class contains `maxSubSteps=0` (`stepnumber=0 time=1.0000000000000013`) and
`solver.iterations=0` (no contact response at all: the ball falls through to
`y=-72.845108129` while contacts are reported as `0`).

**[O] Contained degeneracies:** `dt=0` and `dt<0` are NaN-free
(`stepnumber=240 time=0` / `time=-3.9999999999999907`); a zero-extent `Box`
rests on the surface (`y=-0.000001485`); exactly coincident spheres produce a
contact with `ni=(0,0,0)` and `computeC()=2.0001` — the SPOOK `eps` term keeps
the division finite, so there is **no NaN and no separation**: the pair stays
coincident for 120 steps under gravity (`sep=0.000000000 a.y=-14.672741986`); a
`NaN` radius written mid-sim disables the contact without poisoning the state
(`y=0.459090028`, it falls through); a zero quaternion is **preserved** as
`(0,0,0,0)`.

**[O] Validation split:** `new Sphere(-0.5)` **throws** (`The sphere radius
cannot be negative.`) — the r93 §2.9 Godot cell measured `shape_set_data(-1.0)`
accepted with no validation, so this is a genuine cross-engine difference, not
a shared contract.

**[?]** The one raw-bit instability recorded in `RECEIPTS.md` (a NaN payload
difference in a superseded revision) did not reproduce; a raw-bit hash over a
NaN-bearing state is therefore **not** an admissible witness.

### 2.6 The three.js sync cells: full copy is exact, every partial copy is a named failure **[O]**

| copy | measured error after 240 steps |
|---|---|
| position **and** quaternion | `dPos=0.000e+0 dRotDeg=0.000e+0`, `matrixWorld[12..14]` equals the body position to 9 dp |
| position only | `dPos=0`, rotation off by up to **125.505113°** (final 124.514597°) |
| quaternion only | `dRotDeg=0`, position off by **0.956939 m** |
| body **world** pose → child **local** transform (parent at `(10,0,0)`, `ry=90°`) | **8.939521 m** world error; `parent.worldToLocal(bodyWorldPos)` → `fixedErr=0.000e+0` |
| same with parent `scale=2` | **8.704044 m**; the fix still lands exactly |
| interpolation buffer, fixed-step mode | the mesh sits **4.578787 m** above the body |
| `matrixAutoUpdate=false` + stale `matrix` | the world position stays at the stale pose (`0.957109` = |p|), `position`/`quaternion` are ignored |
| read `matrixWorld` before `updateMatrixWorld` | one frame stale, max gap **0.108755 m** |
| quaternion copied `(w,x,y,z)` into three | **172.360 deg** off (`NEGATIVE REJECTED`) |

**[O] The two libraries disagree about a zero quaternion.** cannon-es keeps
`(0,0,0,0)` (`zero_quat cannonQ=0000…(64)`); three's `Matrix4.compose` turns it
into an **identity rotation** (`matrixWorld=[1,0,0,0, 0,1,0,0, 0,0,1,0,
1,2,3,1]`, `detScale=1.000000`) and `getWorldQuaternion()` reads back
`(0,0,0,1)` — the same value `new THREE.Quaternion(0,0,0,0).normalize()`
returns. So a degenerate cannon state renders as an unrotated mesh instead of
raising. **[?]** whether any *other* degenerate cannon state survives the three
`Matrix4.compose` path is not decided by these cells.

### 2.7 The material lattice: one product rule, one precedence order, and μ that is nearly invisible **[O]**

Source-read (0.20.0 `dist/cannon-es.js`) and confirmed by the cells:

- `createContactEquation` / `createFrictionEquationsFromContact` resolve the
  pair's `ContactMaterial` as
  `shapePair || bodyPair || world.defaultContactMaterial`; the world's default
  is `friction 0.3 / restitution 0` (`world_defaults` reads it back).
- If **both** materials' `friction >= 0`, the pair friction is their **product**
  (`mat_pair_05` → 0.25), overriding the registered ContactMaterial
  (`cm_and_mat_fric` is byte-identical to `mat_pair_05`); if **either** is `-1`
  the ContactMaterial's value is used (`cm_rest_one_sided` → the CM's 0.9,
  `apex=2.728244191`).
- The same product rule applies to restitution, measured as the bounce apex:
  product `0.25` → `apex=0.751545694`; CM `0.9` → `apex=2.728244191`; default
  CM `0.6` → `apex=1.594171507`; no restitution → `apex=0.520553278` (rest
  height, `bounces=0`).
- A bare `Material` (defaults `-1/-1`) is inert: `mat_defaults` is
  byte-identical to `no_material`.
- `TupleDictionary` keys by material **id order** (`getKey = (i,j) => i<j ?
  i-j : j-i`), so registering the ContactMaterial in either argument order is
  equivalent (`cm_pair_09_rev` byte-identical).
- `μ = 0` creates **no** friction equations (`fricEqMax=0`, slide
  `14.777510652` m ≈ the pure linear-damping decay `4.854406205` m/s), while
  every `μ > 0` creates **2 equations per contact point** (`fricEqMax=8` for a
  4-point box-box face contact, `2` for a sphere).

**[O] The friction bound is an impulse bound, so nominal μ is unobservable at
ordinary values.** `mug = friction·|gravity|` and the equation's
`minForce/maxForce = ±mug·reducedMass` are clamped on the accumulated λ, which
the solver applies as a velocity change (`vlambda += invMass·λ`). With a
4-point box contact (8 equations) a 5 m/s box stops inside one step for
μ ∈ {0.25, 0.3, 0.9} alike (`fixedRot slideX=0.090261397`, `vx=0` by step 15) —
the nominal μ is invisible. The single-contact sphere sweep makes it legible
again and fits `d ≈ 0.084/μ` m at `v₀=5 m/s` (μ=0.9→0.090271, 0.3→0.279647,
0.05→8.337526), i.e. an **effective deceleration ≈ 15·μg**: for μ=0.3 the
measured stop gives `a = v₀²/2d = 44.7 m/s² = 15.2·μg`, while the receipt's
`predicted` column prints the two-equation bound `v₀²/(4μg) = 2.121521` m
(measured 0.279647) and a Coulomb `v₀²/(2μg) = 4.243042` m. **[I]** the factor
is the per-step clamp applied without a `dt` scale, plus the second tangent
equation. **[?]** whether a fold should treat this as a defect or as the
library's documented behaviour is not a scout decision.

### 2.8 Against the r93 Godot semantics **[O]** where comparable, **[?]** elsewhere

| surface | cannon-es 0.20.0 (these cells) | Godot 4.7.2 (r93, receipt-pinned) |
|---|---|---|
| live shape mutation | the write tick keeps the old contact and pose (`writeTick n=1 y=0.499998 v=0.000000`); the **next** step re-evaluates (`nextTick n=0 y=0.497270 v=-0.163667`) | same shape: `so_proj_shrink` write tick `cc=1 y=0.4900`, `pf=21 cc=0 lv=-0.1633` |
| depenetration rate | fast snap with real velocity: `0.499998 → 0.653801 → 0.804851 → 0.953147 → 1.098692` (overshoots the new rest height 1.0, then ballistic) | GP ejects 0.5 m in ≤3 steps (`0.49→0.89→0.97→0.99`); Jolt pushes a constant ≈0.08/tick |
| shared shape object | one `Sphere` object in two bodies is shared by reference: mutating `radius` moves both (`yAfter=0.249998,0.249998`) | `so_proj_sharenode`/`sharebody`: one resource RID, both bodies follow; `free_rid` detaches both |
| sleeping | opt-in: `world.allowSleep=false` by default, `body.allowSleep=true`; with it on, a resting ball sleeps at step 62 (`sleepSpeedLimit 0.1`, `sleepTimeLimit 1`); a **velocity write is stored but not integrated** (`v=4.999163`, `y` frozen), `wakeUp()` then moves it; an incoming body wakes it at s436 | GP sleeps at `pf=43` and a layer/mask write wakes it in the write tick; Jolt stays asleep and frozen |
| contact count at rest | with `allowSleep=false`: `n=1` forever; with `allowSleep=true`: `n=0` once **both** bodies are SLEEPING (`needBroadphaseCollision` skips a both-static-or-sleeping pair) | GP/Jolt report `cc=1` while resting and while asleep |
| per-shape contact order | shape-array order (`si0-sj0 si1-sj0`) | GP shape 0 then 1; **Jolt reversed** |
| negative shape data | `Sphere(-0.5)` throws | `shape_set_data(-1.0)` accepted, no validation |
| friction/restitution combine | product of the two materials, else the ContactMaterial, else `defaultContactMaterial` (f0.3/r0) | **[?]** — no r93 cell measured friction/bounce combine; not compared here |

The two engines agree on the two things that matter most for a port: a shape
mutation lands at the **next** step (never in the write tick), and a sleeping
body is frozen until something wakes it. They disagree on the *default*: Godot
sleeps by default, cannon-es needs `allowSleep: true` on the world.

---

## 3. Source anchors for the rules above

Every line number is in the lane's own installed copies
(`corpus/live/r94-scout/proj/node_modules/…`), not a fetched page. Where a rule
is **[O]** the cell is the witness and the anchor only names the mechanism.

`cannon-es@0.20.0` `dist/cannon-es.js`

| line | code | rule it anchors |
|---|---|---|
| 12508 | `step(dt, timeSinceLastCalled, maxSubSteps)` — `if (timeSinceLastCalled === undefined) internalStep(dt); this.time += dt;` | §2.3 the two modes |
| 12529 | `if (performance.now() - t0 > dt * 1000) break;` | §2.3 the wall-clock bailout |
| 12539 | `this.accumulator = this.accumulator % dt;` | §2.3 the FP-fragile trim |
| 12549 | `this.time += timeSinceLastCalled;` | §2.3 `world.time` is wall-clock |
| 12473 | `fixedStep` reads `performance.now() / 1000` | §2.3 (not used by these cells) |
| 12818 | `const ld = pow(1.0 - bi.linearDamping, dt);` | §2.5 `damping > 1` → NaN |
| 3493 | `sleepTick(time)` (SLEEPY → SLEEPING on `time - timeLastSleepy > sleepTimeLimit`) | §2.3 `sleep-phase`, §2.8 |
| 12741 / 12750 | `wakeUpAfterNarrowphase = true` (needs the mover's speed ≥ 2·`sleepSpeedLimit`) | §2.8 `sleep_wake` |
| 4015 | `// Both bodies are static or sleeping. Skip.` (`needBroadphaseCollision`) | §2.8 `contact_rest` |
| 12184 | `this.allowSleep = !!options.allowSleep;` | §2.8 `world_defaults` |
| 12217 | `defaultContactMaterial = new ContactMaterial(defaultMaterial, defaultMaterial, {friction: 0.3, restitution: 0.0})` | §2.7 |
| 12680 | `cm = this.getContactMaterial(bi.material, bj.material) || this.defaultContactMaterial` | §2.7 precedence |
| 12695 | `c.restitution = bi.material.restitution * bj.material.restitution` | §2.7 product rule |
| 10448–10471 | `let friction = cm.friction; … matA.friction * matB.friction … minForce/maxForce = ±mug*reducedMass` | §2.7 |
| 12015 | `const getKey = (i, j) => i < j ? … : …;` | §2.7 order-insensitive pair table |
| 9961 | `if (deltalambdaTot * deltalambdaTot < tolSquared) break;` | §2.2 the early break |
| 7809 | `throw new Error('The sphere radius cannot be negative.')` | §2.5 validation split |

`three@0.186.1` `build/three.core.js`

| line | code | rule it anchors |
|---|---|---|
| 11030 | `Matrix4.compose( position, quaternion, scale )` | §2.6 the zero quaternion becomes identity |
| 12901 | `getWorldQuaternion( target )` | §2.6 the read-back `(0,0,0,1)` |
| 13067 | `updateMatrixWorld( force )` (honours `matrixAutoUpdate`) | §2.6 `matrix_auto`, `lag` |

**[?]** No cell here reads these lines at runtime; they were read as text from
the installed packages (the `lsp` device has no server for a vendored
`node_modules` bundle in this lane — a text read of a pinned, hash-recorded
artifact, recorded as such and never presented as semantic proof).

---

## 4. Falsification list

Every cell above is armed with an input change that must move the witness, and
each was replayed 3×:

1. **"Two identical runs produce byte-identical states."** FALSIFIED for
   accumulator stepping under an uneven schedule at equal substep count
   (`uneven eq=false physEq=false`, `ball.y` differs at the 11th decimal), and
   for any witness that includes the interpolation buffer even when
   `elapsed ≡ dt` (`exact eq=false physEq=true`). Holds **[O]** for fixed-step
   mode, in-process, cross-world, cross-process.
2. **"The accumulator path reproduces fixed stepping when the elapsed times
   are exact multiples of dt."** FALSIFIED for the *render* witness (the buffer
   is written and the previous quaternion re-normalized); **[O]** true for the
   physics witness.
3. **"`maxSubSteps` is only a safety clamp."** FALSIFIED: it silently drops
   substeps while `world.time` advances the full elapsed time
   (`stepnumber=10 time=0.500000000`).
4. **"`world.time` is the simulated time."** FALSIFIED (same cell; also
   `bailout stepnumber=1 time=1.000000e-3`, `maxsub0 stepnumber=0
   time=1.0000000000000013`).
5. **"The substep count determines the trajectory."** FALSIFIED: `sleep-phase`
   moves every sleep onset by 1–2 steps at an identical 240 substeps.
6. **"`solver.iterations`/`tolerance` are quality knobs with no observable
   effect."** FALSIFIED (1/20 iterations and `1e-3` tolerance all move the
   hash; the default tolerance never breaks early — `tol0` ≡ default).
7. **"Body insertion order changes the physics."** FALSIFIED in this scene
   (`eq=true` with a measured equation-order permutation); the contact *list*
   order does follow insertion order. Scene-bounded — **[?]** elsewhere.
8. **"`World.step(dt)` with `dt=0` or a negative dt poisons the state."**
   FALSIFIED (both NaN-free).
9. **"A zero contact normal produces NaN."** FALSIFIED: coincident spheres stay
   finite and stay coincident (`ni=0,0,0 cC=2.0001 sep=0`).
10. **"`mass=NaN` is contained by `invMass=0`."** FALSIFIED (the force term
    poisons position and velocity).
11. **"Sleeping is on by default."** FALSIFIED for cannon-es
    (`world.allowSleep=false`; nothing ever sleeps).
12. **"Writing `body.velocity` moves a sleeping body."** FALSIFIED: the value
    is stored and not integrated until `wakeUp()`.
13. **"A resting contact survives sleep."** FALSIFIED once both bodies are
    SLEEPING (`n=0`), in contrast to the Godot cells.
14. **"Nominal friction μ changes the sliding distance."** FALSIFIED at
    ordinary μ in a 4-point box contact (0.25/0.3/0.9 all `slideX=0.090261397`);
    observable only below μ≈0.05 in the single-contact sweep.
15. **"The ContactMaterial always wins."** FALSIFIED: two materials with
    non-negative values override it with their product (both friction and
    restitution).
16. **"Copying the body's world position into a child's local position is
    equivalent."** FALSIFIED (8.94 m error under a rotated parent).
17. **"Position-only sync is enough."** FALSIFIED (125.5° of unapplied
    rotation).
18. **"`interpolatedPosition` is the body position."** FALSIFIED (spawn pose in
    fixed-step mode; the previous step's pose at `t≈0`).
19. **"A raw-bit hash is a witness for a NaN-bearing state."** FALSIFIED by the
    recorded (non-reproducing) payload drift in `RECEIPTS.md`; the battery
    therefore hashes NaN canonically.

---

## 5. Remaining unknowns

1. **[?] Whether body-add-order bit-invariance survives an asymmetric
   multi-contact scene** — the cells here use a symmetric 4-body scene.
2. **[?] The mechanism of the one recorded NaN-payload drift** (superseded
   revision, `angdamping_gt1`), and whether any *other* engine state carries a
   payload-sensitive NaN.
3. **[?] Cross-host reproducibility of accumulator stepping** — the wall-clock
   break is read off the source and demonstrated at a `dt` that always trips it;
   no second host was measured, so the size of the host-speed effect is
   unmeasured.
4. **[?] Where the effective friction factor (≈15×μg) saturates** — the sweep
   covers one mass, one velocity, one contact count; the factor's dependence on
   contact count/mass is inferred, not measured.
5. **[?] Restitution fidelity** — the measured apexes (0.751546 for e=0.25,
   1.594172 for 0.6, 2.728244 for 0.9) are all *higher* than the Coulomb
   prediction (0.5 + (e·v)²/2g), so the SPOOK restitution is not exactly `e`;
   the mapping was not fitted.
6. **[?] Godot friction/restitution combine semantics** — no r93 cell measured
   them, so the cannon-es product rule is compared to nothing.
7. **[?] `SplitSolver`, `Trimesh`/`Heightfield`/`Particle` resolvers, and
   `world.subsystems`** — untouched by these 49 arms.
8. **[?] Thread/worker and `performance.now()`-independent operation** — every
   cell here is single-threaded and synchronous; nothing was measured under a
   worker or with a fake clock.
