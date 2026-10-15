# r94 author — cannon-es/three "cannon.js/PyBullet-style" physics lattice

Seat: GAME-DEV-3D r94 AUTHOR. Task: `/home/vgpnk/Projects/shokunin/.ufo/waves/shokunin-train-20261015-w22/tasks/g3d-r94-author.md`. Scout evidence: `reports/round-94/r94-scout.md` + `corpus/live/r94-scout/`; boundary evidence: `reports/round-94/r94-boundary.md` + `corpus/live/r94-boundary/`. Only boundary-surviving claims are authored; every falsified scout claim is encoded in its corrected form.

Landed one parent fixture, one node child probe, and the vendored engine bytes — following the `bpy_rbw3d.gd`/`r91_child.py` parent→child convention (the engines are node libraries, not Godot engines):

- `corpus/fixtures/r94_cannon.gd` — 19 arms (`--arm=<name>`): 13 positive arms spawn one `node r94_child.mjs <case>` per case under `timeout -s KILL 15`, fold each child's merged log into `{rc,m,o,d}` digest cells (`m` = verbatim `M0`/`M`/`M DONE` lines, `o` = every other non-empty line — must be 0, `d` = `#` diagnostics — counted, never pinned verbatim), and print `PASS r94_cannon <arm> node=<ver> <cells>`. 6 negative arms require the child's live-control + `NEGATIVE REJECTED:` + rc 2; the parent echoes the exact line and quits 2.
- `corpus/fixtures/r94_child.mjs` — ~60 cases covering the surviving lattice: det, det2, varstep, bailout, nan, sync, material, friction, parity, parity2, modes, order, backends + 6 negatives. Bit-exact witnesses: IEEE-754 payload bits serialized per field, sha256-16 hashes over physics (`ph`) and physics+interp+sleep (`h`) state, canonical-NaN hashing (`canonHash`) for the NaN arm.
- `corpus/fixtures/r94vendor/` — `cannon-es.js` (sha `f0700cbd…`, byte-identical to the scout's `cannon-es@0.20.0 dist/cannon-es.js`), `three.module.js` (`9052042d…`) + `three.core.js` (`9edde002…`) from `three@0.186.1`, plus `package.json {"type":"module"}` (silences `MODULE_TYPELESS_PACKAGE_JSON` — would otherwise be an unexpected-stderr failure). All four are covered by the battery's `seed_digests()` before/after map (verified in the run receipt).

`run_battery.py`: **insertion-only** — 19 tuples appended after `r93_areasig_prio`; `git diff` = +38 lines, zero existing bytes touched.

## Cells armed

19 CASES rows → **66 child cells** per battery pass, each a fresh node process:

| Arm (row) | Cases | Boundary-surviving law encoded |
|---|---|---|
| `r94_cannon_det` | 13 | Canon pin `h=0e24fb5aca619253` (240 fixed steps, ball `y=1.499985073`); rebuild + interleave bit-determinism; **canon-scene-only** add-order neutrality + solver-eq signature (`rows=99/99`); naive vs SAP (`0b0f249979097645`, axis-invariant); iterations/tolerance move the hash (`iters5=89b292ca9c60f52b`); saturated-step invariance (239≡240, all asleep); ULP fork `1e-9` → `h_b=0c63200d1cbbf34d`. |
| `r94_cannon_det2` | 4 | GS iteration histograms per tolerance; perturbation growth track (`1.035024e-9` by step 240, first-over `1e-9@52`); ordered contact-pair witness rows forward/reverse (`step=60 n=8 fric=16`, `maxN=13`). |
| `r94_cannon_varstep` | 6 | Accumulator `elapsed=dt`: same `ph`, different `h` (`b95c69cacf7f74c7` — interp buffers differ); uneven schedule → `c37c514dfccc07f3` `physEq=false`; `maxSubSteps` cap (10 vs 30 vs fixed-30); interp fields; sleep-onset phase shift (`1@132→6@134` uneven). |
| `r94_cannon_bailout` | 1 | The wall-budget edge: `step(dt=1e-5, elapsed=1e-3, 1000)` → `stepnumber=1` (first `internalStep` already exceeds the `dt*1000` wall budget). Isolated in its own row per the boundary's load caution. |
| `r94_cannon_nan` | 1 | The full 22-row boundary NaN lattice, **canonical-hashed** (raw payload bits are flag-set dependent — never pinned): 7 NaN cases `[nan_dt,nan_gravity,nan_mass,damping_gt1,angdamping_gt1,nan_quat,nan_payload]`, `inf_only=0`, `neg_radius` constructor refusal, coincident-sphere `ni=0,0,0 cC=2.000110769`, `iters0` sink to `y=-72.845`. |
| `r94_cannon_sync` | 9 | Mesh-copy lattice: full copy `dPos=0 dRot=0` + `matrixWorld` bits; pos-only drifts `maxRotDeg=125.505`; quat-only `dPos=0.956939`; nested/scaled parents need `worldToLocal` (`naiveErr=8.939521`→`fixedErr=0`); zero-quaternion → identity (`detScale=1.000000`); interp-sync trap (`objWorld.y=5.0` vs `bodyPos.y=0.421` — fixed-step interp stays at init); `matrixAutoUpdate` staleness; read-before-update lag `0.108755`. |
| `r94_cannon_material` | 2 | 14-mode material/contact-material lattice (slideX/apex/fricEqMax per mode + summaries); friction sweep `mu∈{0…0.9}` (`mu=0.3→0.279647`, `fricEqMax=0` at `mu=0`/`friction_gravity`). |
| `r94_cannon_friction` | 1 | **Corrected deceleration law** — NOT `15·μg`: pinned grid `aOverMuG` mass-inert `{0.25,1,2,10}→{15.173,15.173,15.173,15.172}`, μ-dependent `{0.05,0.3,0.9}→{3.053,15.173,15.668}`, v0-dependent `{1,5,20}→{9.048,15.173,17.273}`. |
| `r94_cannon_parity` | 4 | Defaults (`allowSleep=false`, `sleepSpeedLimit=0.1`, `f0.3/r0`); shape-shrink: write tick keeps `n=1`, next tick `n=0` + free-fall resume; grow: immediate rebound `0.499998→0.653801`; shared-shape write propagates (`yAfter=0.249998,0.249998`). |
| `r94_cannon_parity2` | 5 | Natural sleep `@62`; vel-write to a sleeping body wakes it (`state=2→v=4.999163`); impact wake cascade; rest-contact `n` by allowSleep; multishape pair order `si0-sj0 si1-sj0`; sleep-threshold table (`limit=0→never`, `time=0→@2`). |
| `r94_cannon_modes` | 8 | **Corrected step-mode laws**: `internalStep`×240 clock-frozen → `h=c882e660f6b85f96` `ball.y=1.499930148` `sleep=1,1,1,1` `eqBase=false`; clocked `time+=dt` → `eqBase=true` `sleep=2,2,2,2` (the falsified "pure" claim, corrected); `dt=0` accumulator → `acc=NaN` + `frozen=true` forever; negative `dt` → normal first step `h=a12589891e16c474`; two-arg default `maxSubSteps` → 10 substeps `h=4c92fce24d8d7f58`; `elapsed=dt/2` ×10 → `stepnumber=5`; `elapsed=-dt` rewinds `time` with no step; `fixedStep`×240 → `class=wallclock mode_ok=1 ticks_lt_calls=true` (measured count → `#` diag only). |
| `r94_cannon_order` | 4 | **Corrected add-order law**: canon `h=true ph=true` vs `asym2` `2e65cf…≠d02da5…`, `stack3` `4caaad…≠d3795d…`, `tri` `f1a92e…≠a8ad93…`; solver-eq signatures `rawSame=false sortedSame=false` even where physics matches. |
| `r94_cannon_backends` | 2 | Broadphase: naive `0e24fb…` vs SAP `0b0f24…` (all axes), grid `nx=1` ≡ naive first step; solver: 8 variants → `distinctHashes=8` incl. `SplitSolver` `40aeebd22b384e32`. |
| `r94_cannon_neg_*` ×6 | 6 | Negative controls, live control proven first: `neg-dt` `0e24fb→fef95d`, `neg-gravity` `→bbd0b5`, `neg-steps-early` `→ce7a60`, `neg-elapsed` jitter `b95c69→f296e9`, `neg-wxyz` 172.360° mesh rotation, `neg-grid` nx∈{2,3,4} refusal class `TypeError:Cannot read properties of undefined (reading 'material')` after nx=1 control `y=4.997272222`. |

## Rep-stability contract

- Authoring sweep: **5 reps × 19 arms = 95 arm runs, all stdout byte-identical, all stderr empty** (`/tmp/r94test/reps/`), run concurrently with the full battery (i.e., under load) — the r94 surface is load-invariant on this host.
- Wall-clock/host-dependent quantities are **classes**, never counts: `fixedStep` pins `ticks_lt_calls=true`; the measured substep count goes to a `#` diagnostic (`d=1` pinned as count). Accumulator-mode pins use scripted `timeSinceLastCalled`, never wall time.
- `var_bailout` `stepnumber=1` is the measured edge the boundary flagged; it held across all 5 reps and both battery runs — pinned with its own row so a drift surfaces alone.
- NaN arm: `canonHash` only (boundary §3: raw payload bits flip ~34%/process under `--no-opt`); `nan_payload` case deliberately emits `payload=canonical`.
- Not authored (boundary-measured, non-pinnable): accumulator substep spread 1..222 per host; `GridBroadphase nx=10` noncompletion/`RangeError` class (hang — excluded from battery); the `--no-opt` payload flip.
- `node` resolves via inherited PATH (fnm `v24.21.0` on this host — same class of host pin as `/usr/bin/blender`); the version is pinned in every PASS line (`node=v24.21.0`).

## Battery

- Before: **265 cases** · After: **284 cases** = +19 r94 rows (13 ordinary + 6 negative).
- r94-only pre-run: **19/19 PASS** (`/tmp/r94test/runs/20261015T215209747397Z/verdicts.json`), seeds unchanged.
- Run 1 (full, concurrent with the 95-run rep sweep): **280/284**, `FAIL` rc 1 — exactly four fails, all on the documented load-flake list: `navagent3d_retarget` `before=1.754246` (+1 tick = +√2/60), `navagent3d_follow` `first=1.636395` (+1 tick = +√2/60 — r93-baseline F1 "navagent one-tick miss"), `phys3d_events_script_size_gate` + `phys3d_events_deferred_hang` (identical `granted` signature — size-gate granted-under-load, r93-baseline F2). All four failed inside the first ~60 s while the sweep was running. **All 19 r94 rows PASS.** `seeds_unchanged=true`. (`corpus/live/runs/20261015T215239880004Z/verdicts.json`)
- Run 2 (full, load ~60–100 from sibling work, no sweep): **284/284 PASS — fully green on final bytes**, `seeds_unchanged=true`, all four run-1 flake rows passing. (`corpus/live/runs/20261015T220110895172Z/verdicts.json`)
- Status vs "battery green on final bytes": run 2 is the fully green 284/284 pass; run 1's only fails are the documented load-flake rows (navagent one-tick miss + size-gate granted-under-load), reproduced under my own concurrent sweep load.

## Corrections / disclosures vs scout+boundary

1. **`internalStep` is not pure** — pins carry both branches: frozen clock → `c882e660f6b85f96`/`sleep=1,1,1,1`, clocked → canonical `0e24fb…`/`sleep=2,2,2,2`. The scout's "identical to world.step" claim is encoded as `eqBase=false`/`true` evidence, not restated.
2. **Add-order neutrality is canon-scene-only** — `det_order_*`/`ord_canon` pin the symmetric-scene equality (with the `sortedSame=false` solver-signature caveat); `ord_asym2|stack3|tri` pin per-order hashes — the general law is falsified and not authored.
3. **`15·μg` replaced by the measured grid** — mass-inert within the clamp (4th-digit drift at m=10 only), strongly μ- and v0-dependent (`3.053 … 17.273`).
4. **`fixedStep()` is wall-clock-driven** — pinned as `class=wallclock ticks_lt_calls=true`; the measured tick count is a `#` diagnostic, never a marker field (boundary measured spread under load).
5. **`dt=0` in accumulator mode freezes the world via `acc=NaN`** — pinned verbatim (`frozen=true`); negative `dt` normalizes to a valid first step (not equivalent).
6. **NaN witnesses use canonical hashing only** — raw IEEE payload bits are flag-set dependent; `h=152fc9d393846ae3` for the two payload-family cases is the canonical spelling.
7. **GridBroadphase is a refusal class** — authored only as the `neg_grid` negative (nx≥2 `TypeError` after the nx=1 live control); the nx=10 hang/RangeError class is documented non-authored.
8. **No Godot-side claims authored** — the parent is transport only; every pinned value is node-runtime evidence (the scout's Godot comparison material is not r94 evidence).

## Commands (repro)

    # one arm the way the battery runs it (inside a scratch copy)
    godot --headless --path <scratch> --script res://r94_cannon.gd -- --arm=det
    # a single child directly
    node corpus/fixtures/r94_child.mjs det_base
    # battery (full)
    python3 corpus/fixtures/run_battery.py

No commit made, per instruction.
