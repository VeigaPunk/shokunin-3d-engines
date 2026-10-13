# Round 24 — independent orthographic near-plane review

**Finding: depth improved narrowly; coverage and calibration unchanged.** On Godot `4.7.2.stable.arch_linux.ed1daf0bf` headless/Linux, the new near-plane arm passes as a negative control (actual exit 2); the two earlier orthographic arms still pass. This is a non-author review, not an implementation edit, push, merge, rendered-pixel test, or a claim about all near-boundary positions.

## Reproduction and receipts

From repository root, independently ran:

```sh
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
# exit 0: seeded 32/32 (15 ordinary, 17 negatives); four optional, uncounted probes PASS; seeds_unchanged=true
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only camera3d_ortho,camera3d_ortho_outside,camera3d_ortho_near
# exit 0: 3/3 (one ordinary, two negatives); seeds_unchanged=true
```

Full receipt `corpus/live/runs/20261013T054452120374Z/verdicts.json` SHA-256 `64e0923d75715748a8c9a309d2c6e6f7ffbcaa1010ddf1adb2fb535f0723c554`; subset `corpus/live/runs/20261013T054452120814Z/verdicts.json` SHA-256 `75b75bf5bdde154711393c2cd607d43de495fbdb6b5a84e3e476c95ef47619be`. Full optional receipt hashes: `crash-exit-verdicts.json` `7ad44fcb1ad94b1932746b4b65ad2f3e442676cc857ad73e432b727bec9249de`; `stream-attribution-verdicts.json` `9c0cbb53078962c911ec807fcb6223f42beb67c6fbd23232b6335c35503e1cdf`; `tree-timeout-verdicts.json` `b6a1543f89c08aa04abe905a391906e1ee91efe24c074f12c43b4ee38be36648`; `mutation-verdicts.json` `5ed5ce001da92d6d5ffd62a41bd39970692213693490ba6f7ff70c5715d7da69`. These four probes address process/runner behavior and a different body-contact mutant, **not** additional orthographic points.

Compared all prior 31 seeded case records against independent r23 full receipt `corpus/live/runs/20261013T054038500246Z/verdicts.json` (SHA-256 `09c826bbafdcbf804fed40839a5db9a2823d994d02ce1016b80c63fe4be88c25`): ordered case names, scripts, flags, expected/actual exits, errors, kinds, exact markers, raw stdout/stderr line arrays, reasons and verdicts are unchanged; durations and scratch-specific command paths were intentionally not compared. The complete r23/r24 seed SHA-256 maps differ only for `README.md` (`aab79580…` → `6995edd9…`), `camera3d_ortho.gd` (`f1963b8f…` → `9097841e…`), and `run_battery.py` (`52e7aede…` → `c6eb69e6…`); all other prior seed digests agree. Full/subset seed maps agree with each other, and each run's pre/post seed hashes match. Exact r24 fixture SHA-256: `9097841eb0ed3878eeda7d35ad316e24322a6deb5ce72839a2bbcd641ce38e67`.

## Geometry, API result, and controls

`camera3d_ortho.gd` creates a headless 800×600 SubViewport, an origin Camera3D facing -Z with `KEEP_HEIGHT`, `PROJECTION_ORTHOGONAL`, vertical size 8, near 1, far 10, and reads settings back. Scale 600/8 = 75 screen pixels per world unit, so world `(2,1,-0.5)` has geometric forward depth `-z=+0.5` (front of camera **origin**, inside the near plane), numerical projection `(400+2×75,300-1×75)=(550,225)`, the same pixel as control points `(2,1,-4)` and `(2,1,-8)`. Those earlier controls are explicitly checked in-frustum and `is_position_behind=false` *before* the near arm. The outside arm retains the controls and checks `(6,1,-4)` projecting `(850,225)`, outside the lateral frustum.

For the actual near point, the fixture checks its **literal** world coordinate `(2,1,-0.5)`, independently expected forward depth 0.5, screen `(550,225)`, `is_position_in_frustum=false`, and the observed Godot `is_position_behind=true` before printing the fixed marker and quitting 2. Full and subset receipts record exit 2, empty stderr, no reasons, and exact stdout `NEGATIVE REJECTED: camera3d_ortho near_plane_depth=0.500 screen=550.000,225.000 in_frustum=false api_behind=true geometric_front=true controls_same_pixel=true` (plus Godot banner). **Do not interpret the API's “behind” as geometric behind-origin:** this specific positive-forward-depth point is classified behind by the API and outside its frustum. The stdout label is hardcoded after assertions, not independently formatted telemetry.

Private adversarial check: copied project fixture sources into ignored `corpus/live/r24-private-near-20261013T054459799305Z`, changed its sole `const NEAR_POINT := Vector3(2, 1, -0.5)` to `const NEAR_POINT := Vector3(2, 1, -0.75)`; copied mutant SHA-256 `51fb0732d5b3c84fd2e0f0da2e1f939ecbede2e36e17d75230ce7a20f631800f`. Ran:

```sh
/usr/bin/godot --headless --path .shokunin/game-dev-3d/corpus/live/r24-private-near-20261013T054459799305Z --script res://camera3d_ortho.gd -- --near-point
# exit 1; no NEGATIVE REJECTED marker; stderr: ERROR: camera3d_ortho: near gate failed depth=0.750 screen=(550.0, 225.0) frustum=false api_behind=true
```

The error comes from independent literal coordinate/depth assertions, not Parse Error, SCRIPT ERROR, or ObjectDB leak. Raw private receipt `corpus/live/r24-private-near-20261013T054459799305Z/near-mutant-verdict.json` SHA-256 `d689943886c38efb7856aef6d65ce24a04a44d4e9b1cab840d5d4428bbe90e69`. Seeded source hash stayed `9097841e…` before/after. The mutant still projects to the same pixel and has the same frustum/API classifications; this control demonstrates literal-location sensitivity, **not** a changed near-gate classification after bypassing the guard.

The first author subset run `20261013T054315293961Z` in LOG.md failed all three arms due to a duplicate `near_screen` parse declaration; author renamed the new local `near_point_screen`, and this independent run confirms the corrected version. One version of one headless Godot engine and sampled depths are covered. No exact near=1 boundary precision, rendered pixels, GPU culling, arbitrary camera transforms, other engines, or general `is_position_behind` semantics are proved. Assumptions/constants: camera origin/forward -Z, viewport 800×600, vertical size 8, near/far 1/10, points listed above, projection tolerance 0.0001; only the ignored private copy changed near-point Z to -0.75.
