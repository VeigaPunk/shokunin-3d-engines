# Round 23 — independent Camera3D orthographic review

**Verdict: depth improved, narrowly; coverage unchanged; calibration unchanged.** I independently ran Godot 4.7.2.stable.arch_linux.ed1daf0bf headless on Linux. The new positive and paired lateral negative passed; the previous 29 cases kept identical raw exits, stdout, stderr, reasons and verdicts compared with the round-22 receipt `corpus/live/runs/20261013T053632289732Z/verdicts.json`. No implementation edits, push, or merge.

## Reproduction and raw evidence

From repository root:

```sh
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
# exit 0; 31/31 cases PASS (15 ordinary, 16 negative); four optional probes PASS; seeds_unchanged=true
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only camera3d_ortho,camera3d_ortho_outside
# exit 0; 2/2 PASS; seeds_unchanged=true
```

Full raw receipt: `corpus/live/runs/20261013T054038500246Z/verdicts.json`, SHA-256 `09c826bbafdcbf804fed40839a5db9a2823d994d02ce1016b80c63fe4be88c25`. Paired receipt: `corpus/live/runs/20261013T054038500353Z/verdicts.json`, SHA-256 `b5e9ea54ada7833c4650510808723e8e70631e382c989e7a56447aa10e04b76b`. Both new full and paired records have empty stderr and no rejection reasons. Positive actual exit 0 and exact stdout `PASS camera3d_ortho viewport=800,600 front_screen=550.000,225.000 deep_screen=550.000,225.000 near=1.000 far=10.000`; outside actual exit 2 and exact stdout `NEGATIVE REJECTED: camera3d_ortho lateral_outside screen=850.000,225.000 in_frustum=false controls_same_pixel=true`. Their only additional stdout is Godot's version banner. All 29 prior raw records match the round-22 receipt in ordered case name, actual exit, stdout lines, stderr lines, verdict and reasons. Old seed hash mappings agree for all prior fixture source/project files; only updated `README.md` and `run_battery.py` differ, with new `camera3d_ortho.gd` SHA-256 `f1963b8f9cfd5f7630a7c0e454ea12f2e69a074202c0993de88ade49d14bba6d`. Full and pair seed maps match each other; both unchanged pre/post run.

Four **optional, uncounted** probes, not four additional default cases: `crash-exit-verdicts.json` PASS (normal exit 1 accepted; same-marker live direct child SIGTERM exit -15 rejected), `stream-attribution-verdicts.json` PASS (stdout marker/exit 0 accepted, identical stdout/exit with `STREAM_3D_STDERR` rejected), `tree-timeout-verdicts.json` PASS (normal exit 0 accepted; live marker, logical exit null on 3-second timeout, cleanup exit -9; detached witness identity verified and terminated), and `mutation-verdicts.json` PASS (existing body-contact mutant exited 1 at final_z 3.500 versus expected 2.500, no success marker, seeds unchanged). Their raw JSON lives next to the full receipt; hashes respectively `87fbe0e63bd76a5652898dd57890e2a8fc8a06f3ca927ff253b879661bd9187e`, `5aba349f8ac1c70a6dbc83801095376250f1baa1c5ffb1526a9bb6647b3c178c`, `6d2a9026d66d129c4910cbe915b1a9557ba53d237a5779e04f93f738c1437c51`, `8973870433c68075f18f867fa032121f68c1b2083eceaaa7f0bc7a1595b0165e`.

## Projection derivation and actual assertions

`camera3d_ortho.gd` authors a `SubViewport` size 800×600, camera at origin facing -Z, `PROJECTION_ORTHOGONAL`, `KEEP_HEIGHT`, `size=8.0`, near 1.0, far 10.0, then waits two process frames. With KEEP_HEIGHT and vertical world span 8, 600/8 = 75 pixels per world unit; center is (400,300), +X moves screen right and +Y moves screen up. Therefore `(2,1,-4)` and `(2,1,-8)` both yield `(400+2×75,300-1×75)=(550,225)` independent of their in-range depths, while `(6,1,-4)` yields `(850,225)`, beyond the 800-wide viewport (horizontal half-span 4 × (800/600) = 16/3 world units). The fixture reads back viewport size, mode, orthographic size, near and far against independent literal expected values; compares both in-frustum `unproject_position` results to `(550,225)` with 0.0001 tolerance, checks both `is_position_behind` false and `is_position_in_frustum` true. The outside arm keeps both valid depth controls, checks its literal `(850,225)` and `is_position_in_frustum` false while not behind. Thus an outside result is not an absent/broken camera surrogate. Projection/frustum assertions precede fixed printed markers; marker numerals are not formatted measurements.

Private mutation: copied seeds to `/tmp/r23-ortho-review-lq3dk7tp/project`, changed the **only** `const ORTHO_SIZE := 8.0` occurrence to `10.0` in copied `camera3d_ortho.gd` (mutant SHA-256 `e2a4ebede9f479570257b40575072829033a4cf34bf9a5e386a0693493faf155`). Both direct Godot positive and `--outside` runs exit **1** with empty success-marker output and `ERROR: camera3d_ortho: viewport/projection setting mismatch` on stderr at `_run` line 38. Neither emits `SCRIPT ERROR:`, `Parse Error:`, or ObjectDB leak warning. Rejection is the literal size readback *before* projection; this mutation does **not** independently show downstream projection mismatch after bypassing readback. Nothing in tracked seeds was changed by this control.

Scope: one headless Godot build, one authored viewport and three local points. `size=8` means vertical span here because `KEEP_HEIGHT` and 800×600 are explicitly set; root headless window is not assumed to be 800×600. Near/far checks cover the two chosen interior depths 4 and 8 and readback 1/10, **not** near/far boundary precision or general culling. `unproject_position` is numerical screen projection, not rendered pixels, rasterization, visibility in a rendered image, GPU clipping/culling, all camera orientations, or other engines. Optional runner signal/timeout/stream probes have separate bounded claims and are not orthographic projection evidence. Assumptions/constants used: viewport 800×600, origin/forward -Z, vertical orthographic size 8, near/far 1/10, asserted screen tolerance 0.0001; I changed only the private copied `ORTHO_SIZE` from 8.0 to 10.0.

<!-- r106-seat45-receipt-note -->

> **Non-resolvable receipt note (r106, 2026-10-18, SEAT-45).** Re-checked 2026-10-18: each path below is a concrete `corpus/live/runs` receipt cited in this lesson. The cited path is absent (`test -e` failed) and no durable copy exists under `reports/` (no receipt artifact whose path or `started_utc` is that run id; a prose mention is not a copy). Quoted receipt SHA-256 values on these lines do not match any tracked file or any `reports/` receipt artifact. `corpus/.gitignore` ignores `live/`, so these paths were never tracked. Historical sentences above are unchanged. Register: `reports/round-106/consistency/receipts.md`.
>
> - `corpus/live/runs/20261013T053632289732Z/verdicts.json`
> - `corpus/live/runs/20261013T054038500246Z/verdicts.json`
> - `corpus/live/runs/20261013T054038500353Z/verdicts.json`
