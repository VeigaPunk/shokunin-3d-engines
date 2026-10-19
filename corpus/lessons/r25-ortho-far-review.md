# Round 25 — independent orthographic far-plane review

**Finding: depth improved narrowly; coverage and calibration unchanged.** Independently replayed Godot `4.7.2.stable.arch_linux.ed1daf0bf` on headless Linux. This is a non-author review of a sampled far-plane exclusion, not a source implementation edit, rendered-pixel result, or GPU culling proof.

## Exact runs and receipts

From repository root:

```sh
python3 corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
# exit 0; 33/33 (15 ordinary, 18 negatives), four optional uncounted probes PASS; seeds_unchanged=true
python3 corpus/fixtures/run_battery.py --only camera3d_ortho,camera3d_ortho_outside,camera3d_ortho_near,camera3d_ortho_far
# exit 0; 4/4 (one ordinary, three negatives); seeds_unchanged=true
```

Full receipt `corpus/live/runs/20261013T054855628286Z/verdicts.json` SHA-256 `fd698a0d64b46293070906a2a30963dc9991c17092eff078a781f3719ad12c30`; subset `corpus/live/runs/20261013T054901267616Z/verdicts.json` SHA-256 `0383cf9aa07792b37bf490dde677b75660b569debf9102a79bf78a2e972fea9c`. Full auxiliary receipt SHA-256: `crash-exit-verdicts.json` `d977eba9ed56f1f8503c56e1033162908336568a79e211e652f5516ad249ca0c`, `stream-attribution-verdicts.json` `67e7a5c7c4006f8bbef991c88bbe8f17d53024511bb79ae745b930aac44fa049`, `tree-timeout-verdicts.json` `cb54412495e80f104556b01c8b6f87faa5fa8878265d05a3c34bd6c2e12b8ba7`, `mutation-verdicts.json` `847e6b24409748121edcd851bfe2b6a636882aab3ef7f36ec2246f7e6cf30741`. The latter probes concern runner/process policy and a different body-contact mutation, not new camera coverage.

Compared against r24 full `corpus/live/runs/20261013T054452120374Z/verdicts.json` SHA-256 `64e0923d75715748a8c9a309d2c6e6f7ffbcaa1010ddf1adb2fb535f0723c554`: all prior 32 ordered records retain identical case names, scripts, flags, expected/actual exits, error, kind, exact marker, verdict, reasons, and **raw stdout/stderr line arrays**. Scratch-dependent command paths and elapsed times intentionally excluded. The two full/subset seed SHA-256 maps agree and each run reports unchanged pre/post seed hashes. Compared to r24 seed map, exactly three digests changed: `README.md` `6995edd9fd2c4ab0a506d4917d24e2b2949130680e3078f6a36f307876f77289` → `a99f23c1b13c204e56c770ae36558c18818d8d80a0cdc59914671573aabc2cd2`; `camera3d_ortho.gd` `9097841eb0ed3878eeda7d35ad316e24322a6deb5ce72839a2bbcd641ce38e67` → `6487234e4156f54cd91d3f422c543c16d99d6c901847a77532fc42ae6af1141f`; `run_battery.py` `c6eb69e6ae85a81daf6b4fc227c917aa93530157043d2f19f76c19b8d47d161a` → `d9f22a8d57876d1d4cf9f7d133e84d4f576f0f3d650e473b03adf4c63fa2d3dd`. All other prior seed digests match.

## Geometry and direct negative check

`camera3d_ortho.gd` creates an 800×600 `SubViewport` and an origin, -Z-facing orthographic `Camera3D` (`KEEP_HEIGHT`, size 8, near 1, far 10), verifies setting readback, then verifies world `(2,1,-4)` and `(2,1,-8)` have screen `(550,225)`, `is_position_behind=false` and `is_position_in_frustum=true` **before** the far arm. Vertical scale is `600/8=75` pixels/unit: the new world `(2,1,-12)` has geometric forward depth `12 > far=10` yet the same numerical screen `(400+2×75,300-1×75)=(550,225)`. The arm checks literal world `(2,1,-12)`, independently authored depth 12 and pixel `(550,225)`, `is_position_in_frustum=false` and `is_position_behind=false`. Full/subset raw streams show actual exit 2, empty stderr, no reasons and exact stdout marker `NEGATIVE REJECTED: camera3d_ortho far_plane_depth=12.000 screen=550.000,225.000 in_frustum=false api_behind=false geometric_front=true controls_same_pixel=true` after the Godot banner. The pre-near arm stays exit 2 with API-behind=true; lateral outside arm stays exit 2. The marker fields are hardcoded after assertions, not independently formatted numerical telemetry. API-behind=false here does **not** imply in-frustum; the far-depth gate determines exclusion.

Private copied check changed only `const FAR_POINT := Vector3(2, 1, -12)` → `const FAR_POINT := Vector3(2, 1, -13)` under ignored `corpus/live/r25-private-far-review/scratch`; mutant source SHA-256 `0244344eb9c0a480aa931ba9f7e428281f6ff969a4f9aad92e0d381ad4af8f59`. Exact run:

```sh
/usr/bin/godot --headless --path corpus/live/r25-private-far-review/scratch --script res://camera3d_ortho.gd -- --far-point
# exit 1; no NEGATIVE REJECTED marker; stderr:
# ERROR: camera3d_ortho: far gate failed depth=13.000 screen=(550.0, 225.0) frustum=false api_behind=false
```

Captured separate stdout/stderr/exit in `corpus/live/r25-private-far-review/far-mutant-verdict.json` SHA-256 `6f72f6b2b00a209186b1cbc7f6251be74a6d80602dae57599e456b8d9d53926d`. No Parse Error, SCRIPT ERROR, or ObjectDB leak in its raw streams. Authored seed hash remained `6487234e4156f54cd91d3f422c543c16d99d6c901847a77532fc42ae6af1141f` before/after private test. The mutation is caught by literal world/depth mismatch, **not** by altered frustum or API-behind classification: both far points project to the same pixel and remain outside.

Adverse limits: one Godot version, one camera orientation, one sampled depth beyond far, no exact far=10 boundary sweep, rendered pixels, GPU culling, or general camera API theorem. Assumptions/constants unchanged in authored source: viewport 800×600; orthographic vertical size 8; near/far 1/10; controls Z=-4/-8 and far sample Z=-12; screen tolerance 0.0001, location/depth tolerance 0.000001. Only private ignored copy changes Z=-12 to -13. No implementation edits, push, or merge by this reviewer.

<!-- r106-seat45-receipt-note -->

> **Non-resolvable receipt note (r106, 2026-10-18, SEAT-45).** Re-checked 2026-10-18: each path below is a concrete `corpus/live/runs` receipt cited in this lesson. The cited path is absent (`test -e` failed) and no durable copy exists under `reports/` (no receipt artifact whose path or `started_utc` is that run id; a prose mention is not a copy). Quoted receipt SHA-256 values on these lines do not match any tracked file or any `reports/` receipt artifact. `corpus/.gitignore` ignores `live/`, so these paths were never tracked. Historical sentences above are unchanged. Register: `reports/round-106/consistency/receipts.md`.
>
> - `corpus/live/runs/20261013T054855628286Z/verdicts.json`
> - `corpus/live/runs/20261013T054901267616Z/verdicts.json`
> - `corpus/live/runs/20261013T054452120374Z/verdicts.json`
