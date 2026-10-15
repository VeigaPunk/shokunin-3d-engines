# r95 author — Bullet/pybullet 3.2.7 physics lattice

Seat: GAME-DEV-3D r95 AUTHOR. Task: `/home/vgpnk/Projects/shokunin/.ufo/waves/shokunin-train-20261015-w22/tasks/g3d-r95-author.md`. Scout evidence: `reports/round-95/r95-scout.md` + `corpus/live/r95-scout/`; boundary evidence: `reports/round-95/r95-boundary.md` + `corpus/live/r95-boundary/`. Only boundary-surviving claims are authored; every falsified or overbroad scout claim is encoded in its corrected form.

Landed one parent fixture, one python child probe, and the vendored engine bytes — following the `r94_cannon.gd`/`r94_child.mjs` parent→child convention (the engine is a CPython extension module, not a Godot engine):

- `corpus/fixtures/r95_bullet.gd` — 20 arms (`--arm=<name>`): 14 positive arms spawn one `/usr/bin/python3 r95_child.py <case> <res://r95vendor>` per case under `timeout -s KILL 15`, fold each child's merged log into `{rc,m,o,d}` digest cells (`m` = verbatim `M0`/`M`/`M DONE` lines, `o` = every other non-empty line — must be 0, `d` = `#` diagnostics — counted, never pinned verbatim), and print `PASS r95_bullet <arm> py=<ver> <cells>`. 6 negative arms require the child's live-control + `NEGATIVE REJECTED:` + rc 2; the parent echoes the exact line and quits 2.
- `corpus/fixtures/r95_child.py` — **52 cases** (46 positive + 6 negative) ported from the scout's `probes.py`/`probes_ext.py`/`probes_sleep.py` helpers and the boundary's `probes_b.py`/`shm_probe.py` cells, byte-for-byte witness-compatible: sha256-16 over canonicalized f64 bits of (pos, quat, linVel, angVel, bodyId), NaN→`b"NAN"`, ±inf→`b"±INF"`. **Both** stdout and stderr are captured for the whole process (b3Warning/b3Printf write fd 1, error paths fd 2) and re-emitted as `#` diagnostics; all contract output goes through a duplicated fd of the original stdout, so no engine print can ever land on the `o` surface.
- `corpus/fixtures/r95vendor/pybullet.cpython-314-x86_64-linux-gnu.so` — the scout's venv build after `strip --strip-debug` (91 MB → 7,063,864 B): sha256 `eca749a0d9b53964dca06764300c3481f328dc4cd1499a60e287393972be3693`. Source artifact `corpus/live/r95-scout/venv/lib/python3.14/site-packages/pybullet.cpython-314-x86_64-linux-gnu.so` sha256 `c035ebaf312fcb71b728e6206b5d225483c0624e7f1cccdd23995b61cf086d9a`. **Output-equivalence proven**: all 52 cases run against both artifacts, contract lines (`M0`/`M`/`M DONE`/`NEGATIVE`) byte-identical. Covered by `seed_digests()` before/after (verified `seeds_unchanged=true` in both run receipts).
- M0 header per child pins the engine identity: `engine=pybullet-3.2.7 api=202010061 py=3.14.7 dtBits=3f71111111111111 build="Oct 15 2026 03:47:36"` — `dtBits` is the IEEE-754 bits of the engine's stored `fixedTimeStep`, i.e. the `btScalar=f64` discriminator (the boundary's float rebuild would read `3f71111120000000`).

`run_battery.py`: **insertion-only** — 20 tuples appended after `r94_cannon_neg_grid`; `git diff` = +40 lines, zero existing bytes touched.

## Cells armed

20 CASES rows → **52 child cells** per battery pass, each a fresh `/usr/bin/python3` process:

| Arm (row) | Cases | Boundary-surviving law encoded |
|---|---|---|
| `r95_bullet_det` | 13 | Canon pin `h=02309c52da41ef33` (480 fixed steps @1/240, `z480=1.49997782`, `cc=13`); rebuild/interleave/`resetSimulation`/`saveState`-restore all bit-deterministic; **creation order is NOT neutral** (fwd `02309c…` ≠ rev `76988acc55682c1a` — the r94-cannon law does not transfer); `numSolverIterations` 1 moves bits, 50≡150, 0 falls through (`z=-10.6855237`); `numSubSteps` lattice (`n4=52204c…`, `n8=b186ca…`); `deterministicOverlappingPairs` neutral **5-body-scoped only**; 1e-9 perturbation track (`4.466e-14`@240→`6.804e-13`@480, `heq=False`); saturated non-fixpoint (`h960≠h961`); erp=0.9 / warmStart=0 neutral. |
| `r95_bullet_freeze` | 2 | Bit-fixpoint is **scene-dependent**: canonical 5-body `changes=3000/3000 freezeStep=-1 hFinal=7e1278628a4d5a12` (boundary extended to 20 000 — never fixes); single resting ball `changes=79 freezeStep=80`. |
| `r95_bullet_rt` | 3 | **DIRECT-scoped** wall-clock inertness (the corrected claim): rt0≡rt1 hash `02309c…` with flag readback `0/1`; idle 0.6 s + 120 non-step API calls move nothing (`z=5` throughout); paced stepping under rt=1 still hits the pin exactly. |
| `r95_bullet_shm` | 2 | SHARED_MEMORY_SERVER transport axis: `rt=0` stepped ≡ DIRECT pin (`h=02309c…`, `eqPin=True`) — transport is physics-neutral when stepped; `rt=1` pump is **live**: `fell=True` during a bare 2 s sleep (the boundary falsification, pinned as a class). Stepped hashes under rt=1 are `#` diagnostics only — pump injection is a timing race (boundary: 3 reps→3 hashes; this host: replayed the pin). |
| `r95_bullet_sleep` | 5 | The no-sleep lattice on the `createMultiBody` path: solver iterates forever (`iters=2` at rest, `i-1/it1` mid-fall); velwrite/teleport apply instantly (`vRead=5`, `z+1=0.520632014`); forced `ACTIVATION_STATE_SLEEP` ignored on reduced-coords (body keeps falling); **EMPTY-analytics calibration** on maximal coords (island skipped, body frozen — proves `EMPTY` is the sleep signal, and why natural sleep is never observed: bodies are collision objects, not in the rigid-body list). |
| `r95_bullet_sleep2` | 4 | Maximal-coord resting body: `an=i0/n1/it2` `cc=1` through step 1400 (resting `cc=1` is a live solved pair, not a sleeping manifold); `DISABLE_SLEEPING` bit-identical to default (`eq=True`); persistent contact `d=-1e-05/nf=9.82` from step 120 (`froze~101`); stale-manifold window (`postMove` still returns `n=1`, first step clears). |
| `r95_bullet_nan` | 2 | dt lattice: `dt<0`/`dt=0` silently freeze (`z=5 v=0`); `dt=NaN` poisons pos+quat only (`0.p+0.q+1.p+1.q`); `dt=+inf` poisons pos+quat+vel (`+0.v+0.w+1.v+1.w`); `numSubSteps=-1` → `h=ae21935ec081b2e4`. Field lattice: NaN vs +inf gravity both yield `z=nan` via different paths (`1.p+1.v`); inf-pos stored (`created=0`, `where=0.p`); NaN/+inf vel both poison; zero-quat → `fff8000000000000`; nan-quat propagates to `1.p+1.q+1.v+1.w`. |
| `r95_bullet_nan2` | 3 | Mass gate: create `m∈{0,-1,nan}` → static-but-stored (`dynMass=-1`, `dynMass=nan`, `z=5` frozen); `m=+inf` poisons whole body; `changeDynamics(mass=-1)` **dropped by the ≥0 gate** (`dynMass=1`); mass→0 mid-fall freezes velocity. Damping applied **unclamped** (`d=1.5` legal, `z=4.27577737`); neg/NaN damping dropped. Shape lattice: zero/neg halfExtents accepted and sink; coincident pair → fixed `(1,0,0)` normal + ballistic split; teleport-into-ground depenetration snap; ccd knob inert here (both tunnel `z=0.110300828`). |
| `r95_bullet_fric` | 3 | Combine lattice (raw product, clamp ±10): slide-x grid `g0.5/b0.5:x=4.08354903 … g0.05/b0.05:x=9.66585442`; **1-ulp correction** — `0.8*0.8=…147c` vs `0.64=…147b` (`ulpEq=False`) so equal-looking decimal products hash differently (`54d2f4…` vs `3e79f2…`) while commutative pairs stay bit-exact; the **≥0 write gate**: `mu=-0.5` dropped → `stored=0.5`, `mu=11` stored; `mu=0` residual is default `linearDamping=0.04` (`mu0+damp0` → ideal `x=12.5 vx=5`); g=0 invariance within noise. |
| `r95_bullet_rest` | 1 | Restitution: raw unclamped product; apex lattice (`g0.9/b0.9 ≡ g0.81/b1.0` `apex=0.851578572`); bit-exact hashes (`g0.9/b0.9 ≡ g0.81/b1.0 → 0f0edc29d1a48f22`); zero-product pairs `3212060bf6dabef8`. |
| `r95_bullet_knobs` | 2 | Boundary one-knob census verbatim: 9 neutral knobs (`cone_fric/erp×2/frictionERP/minIsland_0/innerIter/ccdPen/detpairs/warmstart` — `eqBase=9/9`); 8 loud knobs (`contactERP=e08d56…`, `contactSlop=dea262…`, `resid_1e-6=f23fad…`, `globalCFM=b4a054…`, `minIsland_2=cdb837…`, `iters_10=210161…`, `substeps_2=0282277…`, `ts_1/120=00640c…`). |
| `r95_bullet_solver` | 2 | `constraintSolverType` backend axis: SI≡unset≡`02309c…`; PGS `8606ea0c3c45c5ad`; DANTZIG `71248c7a8455c70a` (stderr solver-switch lines → `d=4`). `setTimeStep` lattice at scaled step counts (`1/60=b7fd8f…`, `1/120=d3a2bd…`, `1/240=02309c…`, `1/480=0282277…`, `1/1000=4a1d38…`) plus the substep/dt equivalence `dt480×960 ≡ nsub2×480` (`eq=True`). |
| `r95_bullet_pile` | 1 | 32-box/128-contact stress lattice: `default≡det0=daf67ba7bdfb7f80`; **detpairs is loud at scale** `det1=a272ef21dd510162` (the scene-scope correction); reversed creation `38cb12317d6644da`; maximal coords `99d3fdf650620da5`. |
| `r95_bullet_misc` | 3 | Contact persistence (`cc=0` falling, `cc=1` from step 120 rest) + ordered pair list (`0-1,0-1,… cc=12`); mutation boundary (margin write inert same tick, gravity write lands next step `v0=-2.42374526→-2.42236221`); world defaults (`fixedTimeStep=0.004166666666666667`, `numSolverIterations=50`, `useRealTimeSimulation=0`, 12-field dynInfo tuple — **no activation field: sleep is API-unobservable**). |
| `r95_bullet_neg_*` ×6 | 6 | Negative controls, live control proven first: `neg-dt` `1/119 → 3e5afa1e3405090d`; `neg-order` order-sensitivity `02309c→76988a`; `neg-radius` `{-0.5,0,nan}→pybullet.error` while `+inf` accepted (`id=1`); `neg-simtime` `simTimeScalingFactor` kwarg `TypeError` ×2 (legal `numSolverIterations` control); `neg-badid` 3 invalid-id calls refused; `neg-shm-rt` SHM transport non-neutral under rt=1 via pump-liveness (`froze=True` DIRECT vs `fell=True` SHM — **not** via the load-dependent stepped divergence). |

## Rep-stability contract

- **Vendor equivalence**: all 52 cases run on the stripped vendored `.so` AND the original unstripped venv `.so`; contract lines byte-identical (`/tmp/r95run` vs `/tmp/r95orig/out`).
- **Child rep sweep**: all 52 cases × 3 fresh processes on the vendored `.so` → identical rc/`o`/`d` everywhere (`/tmp/r95rep/`).
- **Fixture rep sweep**: all 20 arms × 3 godot runs → byte-identical `PASS`/`NEGATIVE` markers (`/tmp/r95marks/`).
- All positive M-lines diffed against the scout's pinned `rep1.out` files (`corpus/live/r95-scout/runs/20261015T071515Z` pass-1, `…T080234Z` pass-2) and the boundary's tables — byte-identical.
- Every child is bounded by `timeout -s KILL 15`; each battery row by `CASE_TIMEOUT_SECONDS=20`. Slowest child ~4.5 s (`shm_rtclass`, mostly real sleeps).
- Not authored (boundary-measured, non-pinnable): SHM+rt=1 stepped-hash divergence (a pump-timing race — `#` diagnostics only); measured idle-fall distances (`z1≈0.49999` — `#` only); SHM thread print ordering within the pinned `d` count; TCP/UDP transports; the float-`btScalar` rebuild's hashes (build-scoped out — `dtBits` in M0 discriminates); raw NaN payload bits (canonical token `NAN` used).

## Known flake classes (documented, not silent)

- **SHM `#`-diagnostic count** (`d=8`/`d=44`): pump-thread startup/teardown prints can interleave differently under pathological scheduling; the total byte count — and thus the line count — is fixed, and 50 ms settle sleeps after every SHM connect/disconnect land the prints before the drain. If a teardown print ever lands post-drain, `d` drifts and the `shm` row reddens — a legitimate signal, not a silent ignore.
- **`fell=True` / `froze=True` SHM idle classes**: rely on the pump stepping within a 2 s sleep; boundary observed motion within <1 s in every rep. A >2 s pump stall would flip the class — again a real behavior change, surfaced red.
- **SHM stepped-path**: genuinely non-reproducible (boundary's one place where identical commands gave different bits). Authored **only** as diagnostics so it can never flake a row; `neg_shm_rt` rejects via the robust pump-liveness contrast instead.

## Battery

- Before: **284 cases** · After: **304 cases** = +20 r95 rows (14 ordinary + 6 negative).
- r95-only pre-run: **20/20 PASS** (`corpus/live/runs/20261015T224412369946Z/verdicts.json`).
- Full battery run 1: **304/304 PASS**, `seeds_unchanged=true` (`corpus/live/runs/20261015T224443567926Z/verdicts.json`).
- Full battery run 2 on the same final bytes: **304/304 PASS**, `seeds_unchanged=true` (`corpus/live/runs/20261015T232218926492Z/verdicts.json`).
- No failures observed in either full run; nothing hit the documented flake list.

## Corrections / disclosures vs scout+boundary

1. **"No wall-clock path" authored DIRECT-scoped only** — the scout's general claim is falsified (boundary §2). `rt_*` rows pin DIRECT inertness; `shm_rtclass`/`neg_shm_rt` pin the correction: `SHARED_MEMORY_SERVER` + rt=1 has a live pump that falls a body during a bare sleep.
2. **SHM stepped divergence is load-dependent, never pinned** — the boundary's 3-rep-3-hash result does not reproduce on this host (the pin `02309c…` replays when the pump injects nothing inside the stepped window). Both outcomes are consistent with a timing race; authored only as `#` diagnostics.
3. **Creation order is not bit-neutral in Bullet** — contrary to the r94-cannon canon-scene result; authored positively (`det_order`, `pile rev`, `interleave`) plus the `neg_order` control rejecting order-neutrality.
4. **`deterministicOverlappingPairs` neutrality is scene-scoped** — neutral in the 5-body canon, loud in the 32-box pile (`daf67b…`→`a272ef…`); both halves pinned.
5. **Bit-fixpoint is scene-dependent** — the canonical scene never fixes (3000/3000 here; boundary 20 000/20 000), the single ball fixes at step 80.
6. **Friction combine is a raw f64 product** — equal-decimal products can differ by 1 ulp (`0.8*0.8` vs `0.64`); the scout's "equal products equal" is authored only in its bit-exact form (`ulpEq=False` + per-pair hashes); commutativity exact.
7. **The `>=0` write gate is a NaN filter** — NaN silently dropped (friction/damping/mass-change), `+inf` stored; `-1` mass at create is stored (static), at change is dropped — authored per-path.
8. **b3Warning rides stdout (fd 1)** — refusal warnings are captured with **both** fds for the whole process and re-emitted as `#` diagnostics; contract output travels a duplicated fd no engine print can reach. The pinned surface is `d` counts only.
9. **Sleep is structurally absent on the default path** — the server adds bodies as collision objects, so `an=i0/n1/it2`/`cc=1` persist forever; `EMPTY` analytics is the calibrated sleep signal and appears only under forced-sleep on maximal coords.
10. **No Godot-side claims authored** — the parent is process transport/digest validation only; every pinned value is `/usr/bin/python3`+pybullet evidence. Godot-side physics comparisons from the boundary (GP/Jolt/Dummy sleep rows) stay boundary evidence.

## Commands (repro)

    # one arm the way the battery runs it (inside a scratch copy)
    godot --headless --path <scratch> --script res://r95_bullet.gd -- --arm=det
    # a single child directly
    /usr/bin/python3 corpus/fixtures/r95_child.py det_base corpus/fixtures/r95vendor
    # battery (full)
    python3 corpus/fixtures/run_battery.py

No commit made, per instruction.
