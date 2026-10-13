# Round 26 — independent jump/landing review

**Finding: depth improved narrowly; coverage and calibration unchanged.** Named non-author replay of Godot `4.7.2.stable.arch_linux.ed1daf0bf` on this headless Linux host. No implementation edits, push, or merge.

## Runs and receipts

From the repository root:

```sh
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
# exit 0; 35/35 (16 ordinary, 19 negative); four additional probes PASS; seeds_unchanged=true
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only jump3d_land,jump3d_no_floor
# exit 0; 2/2 (one ordinary, one negative); seeds_unchanged=true
```

Full `corpus/live/runs/20261013T055425026403Z/verdicts.json` SHA-256 `4234d6098ffde37214527c38dcb66e15ab1c7495b307a16e5d0009e78c0f9e8b`; pair `corpus/live/runs/20261013T055428088439Z/verdicts.json` SHA-256 `279edef43e2ba53d293791a11514cea7a4b7764e35ed0c80e943beff164b27a9`. Full auxiliary receipts: `crash-exit-verdicts.json` `e3c1cfa196cab20f8a6a2b55b54e1e6a50797b0bdb5f34ac475d4746e8afd3f1`; `stream-attribution-verdicts.json` `9082fa34eeddc5c8435a5bc44cdae22e779f3fcc9769631a5792ebdc0bf49bc5`; `tree-timeout-verdicts.json` `4d2dd391b7ccc3646b27f24b6064b742bef5d21f4d6c2159343c8c7b4bd6ddec`; `mutation-verdicts.json` `6be3d3fd8d6efae5ac3eaed7007a1630b495d131a1f24b91c744fe0894f14673`. These four runner probes concern established process/stream policy and a *body3d_contact* mutation, not a jump mutation.

Compared with r25 full `corpus/live/runs/20261013T054855628286Z/verdicts.json` SHA-256 `fd698a0d64b46293070906a2a30963dc9991c17092eff078a781f3719ad12c30`: all prior 33 case records retain their order, scripts, flags, expected/actual exits, errors, kinds, markers, verdicts, reasons, and exact raw stdout/stderr arrays. Scratch paths and elapsed times deliberately excluded. Both new runs have the same seed SHA-256 map and independently report unchanged pre/post seed hashes. Only three changes/additions against the r25 map: `README.md` `a99f23c1b13c204e56c770ae36558c18818d8d80a0cdc59914671573aabc2cd2` → `7dbd1c6950e530c43a81b1f00ed707647716890fb978b29674dde1246489900a`; `run_battery.py` `d9f22a8d57876d1d4cf9f7d133e84d4f576f0f3d650e473b03adf4c63fa2d3dd` → `fe81c3d3d45ea8edb5f0a3c8cb121202a7928059ff6be60e24251ae9cbdade91`; new `jump3d_gravity.gd` `a2dbe8ddfa0a7af3f38d1cd61b2de55b23c9402f7d8ba4d85908f27b5a3cca00`. All other prior seeds identical.

## Actual mechanics and failure checks

`jump3d_gravity.gd` creates one 8×1×8 box floor centered y=0 and one unit-box `CharacterBody3D` centered y=1, with collision mask/layer contact checked. It sets impulse +6 once; for exactly 60 iterations after a first `physics_frame` wait, updates vertical velocity by -12/60, sets actor velocity, calls `move_and_slide()` once, reads back actor velocity, records the highest *observed* y and first `is_on_floor()`, then awaits `physics_frame`. Thus these are **60 explicit move calls paced by frames**, not `_physics_process` callback calls. Hand free-space sum is y(n)=1+sum_{i=1}^n(6-0.2i)/60 = 1+0.1n-n(n+1)/600; n29 and n30 both ideal y2.45, and the source's strict `>` peak update retains tick29. At n59 ideal y1.0 and n60 ideal y0.9. Actual positive raw stdout reports `PASS jump3d_gravity apex_tick=29 apex_y=2.451 landing_tick=60 final_y=1.001 grounded=true` (exit0, empty stderr). This Godot collision solver/safe-margin result is *not* free ballistic landing at 59 or center1.000. The floor relocated intact to y=-20 produces actual stdout `NEGATIVE REJECTED: jump3d_gravity no_floor_landing apex_tick=29 apex_y=2.450 final_y=0.900 grounded=false floor_intact=true` (exit2, empty stderr); the lower floor remains untouched, with no floor flag or landing during the 60 calls.

The constants and geometry are verified partly by literal checks: apex_tick=29, apex y≈2.45 tolerance .003, landing tick=60, final y≈1.0 tolerance .003, floor y=0, or in the displaced arm floor y=-20, no grounded/landing, final y≈0.9 tolerance .002. These literals do **not** recompute from IMPULSE, GRAVITY or floor offset. The fixture checks floor/actor box sizes, matching collision mask and planar position. Nevertheless the fixed output marker strings are printed only *after* checks, not formatted directly from measurements; a matching marker by itself is not independent telemetry. The apparent initial contact from center y1 and two half-unit extents is geometric: **initial `is_on_floor()` is never asserted** before impulse, so the declared “start grounded” claim is not established as a sampled Godot state. Likewise no independent numerical per-tick velocity sequence is asserted: source visibly integrates velocity, and apex/final/landing predicates detect a sizeable impulse perturbation, but they do not prove each intermediate velocity, variable frame delta, or controller behavior.

Private ignored scratch source copy changed only `const IMPULSE := 6.0` → `const IMPULSE := 7.0`, under `corpus/live/r26-private-jump-review/scratch/jump3d_gravity.gd` SHA-256 `208fbf723b4e6eb6e842b82d9b3587066bbd5e04bfcf13eb475683f7757fe8af`; original seed remains `a2dbe8ddfa0a7af3f38d1cd61b2de55b23c9402f7d8ba4d85908f27b5a3cca00`. Exact independent direct commands (raw streams/exit captured in `corpus/live/r26-private-jump-review/jump-mutant-verdict.json`, SHA-256 `c20e831ad32e59054fa409b9507e38712ec63442947c2f80ee68d588517048d5`):

```sh
/usr/bin/godot --headless --path .shokunin/game-dev-3d/corpus/live/r26-private-jump-review/scratch --script res://jump3d_gravity.gd
# exit 1; stderr ERROR: jump3d_gravity: apex/planar mismatch tick=34 y=2.9843 position=(0.0, 1.900941, 0.0)
/usr/bin/godot --headless --path .shokunin/game-dev-3d/corpus/live/r26-private-jump-review/scratch --script res://jump3d_gravity.gd -- --lower-floor
# exit 1; stderr ERROR: jump3d_gravity: apex/planar mismatch tick=34 y=2.9833 position=(0.0, 1.9, 0.0)
```

Both have only Godot banner/blank stdout, no PASS/NEGATIVE REJECTED marker, Parse Error, SCRIPT ERROR, or ObjectDB leak. The early authored apex assertion causes exit1 in both arms; the test does not reach the authored landing check, so cannot separately demonstrate that landing assertion detects this particular mutant. It does demonstrate the independently literal apex rejects changed impulse rather than a parse/leak failure.

## Adverse author receipts and scope

LOG r26 records first author pair `20261013T055145378168Z/verdicts.json` FAIL at classifier because authored expected output guessed landing59/y1.000 despite engine marker landing60/y1.001 (real engine exits0/2); `20261013T055229469904Z/verdicts.json` FAIL with negative exit1 `SCRIPT ERROR: Invalid access ... 'previously freed'` after cleanup before formatting; final author pair `20261013T055244064506Z/verdicts.json` PASS 2/2 after saving final y first. These failed rehearsals are not success evidence. Calibration remains bounded to one version, one floor/box, +6 and -12/60, a one-second call budget, and tolerances; no initial grounded state, general jump controller, rendered result, exact collision-boundary theorem or variable-step integration is proven. Assumptions/constants changed by this reviewer: only the private ignored IMPULSE +6→+7 copy; no authored constants or tracked implementation changed. This independent result supports depth improvement for one observed gravity/apex/grounded-vs-displaced-floor regime, not broader coverage or calibration.
