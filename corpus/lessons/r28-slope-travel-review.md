# Round 28 — independent slope travel review

**Verdict:** Narrow depth improvement for a 30° live slope with explicit nondefault `floor_stop_on_slope=false`: measured negative X displacement versus an intact level no-downhill control. The default-policy premise was falsified, not admitted as an unconditional gravity-slide claim. Coverage and calibration unchanged. Reviewed headless Godot `4.7.2.stable.arch_linux.ed1daf0bf` on this Linux host; no implementation edit, push, or merge.

## Reproducible replay and preservation

From repository root:

```sh
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
# exit 0; 37/37 (17 ordinary, 20 negative); four opt-ins PASS; seeds_unchanged=true
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only slope3d_travel,slope3d_travel_level
# exit 0; 2/2 (one ordinary, one negative); seeds_unchanged=true
```

Full receipt `corpus/live/runs/20261013T060433692579Z/verdicts.json` SHA-256 `5586f718dfbf3c6f1f128bf9e5167bea43153a2e09ba6a732c23e2d1a7f0d81d`; paired receipt `corpus/live/runs/20261013T060433692552Z/verdicts.json` SHA-256 `cde7f7f265798c51ba2bfb97b362e54332ee209e38310a35d92ff7cffd70709c`. Full-run opt-in receipts: `tree-timeout-verdicts.json` `f236fdfe137c2efcec974234378a8a3a7b308cb509946c106430898d690231f4`; `crash-exit-verdicts.json` `7487ee9a45d7ea283f4f3ba88b2cb8e62e8fc5bfaabc7178c91127e6ce5222fe`; `stream-attribution-verdicts.json` `29fa8905b628f57e98bc9b731f56ab88b3abef6ba30f1ef0691cd12a644cdfbf`; `mutation-verdicts.json` `f7cc13e44025c112b89dd5f09329a9c5d3e1e1050703eb10ad9a1a3798352a7d`. Built-in mutation concerns `body3d_contact`, not slope travel.

Against prior r27 full `corpus/live/runs/20261013T055914266533Z/verdicts.json` (SHA-256 `e0cfee0a698199084f7bff550851aa8dffa3b9fc45f34d624e7841dc9a2d4d1f`), all 35 prior cases retain case/order, script, flags, expected/actual exits, error, kind, exact marker, verdict, reasons, and complete stdout/stderr arrays. Only run-specific commands, timing and scratch paths differ. All prior seed digests are identical except the declared README (`f9c95665ba4fc662ca608e1a386dda2d85cd39a7170e696a3cfb0498a8721a61` → `b3b87e1e2c8cf1044f53d0b88643824d5763ac21a5ea5f0fa8e33d09f2c25dcd`) and runner (`f3ded050f5fa2f7ea36e857e522e62ebe6bffbc63dd652f54accff349eab5333` → `a7fb30dcdd8df03fca46394ac9fa352440c298f626fc3530bc9e6e6aebf0672c`); new slope source SHA-256 `ad553688c2213e2a64a3296051fe5b51d5cdcb40f0a5b8059a4de32d24b78e5c`. Full and paired current seed maps agree. The two new cases also agree in all listed raw fields across full and paired runs.

## Observed mechanics and boundaries

`slope3d_travel.gd` creates a live 30×1×20 `StaticBody3D` slab rotated around Z by 30° (level arm 0°), and a unit `CharacterBody3D` in grounded motion mode with matching mask/layer, initial center `(0,1.5,0)`. It **explicitly assigns** `actor.floor_stop_on_slope = false`. Following one `physics_frame`, 60 explicit calls each subtract `12/60` from vertical velocity, assign `Vector3(0,velocity_y,0)`, call `move_and_slide()`, retain returned vertical velocity, count `is_on_floor()`, and await the next physics frame. This is frame-paced code, not `_physics_process`; gravity is hand-integrated, not an engine project gravity setting.

The slope run exits 0 and prints exact `PASS slope3d_travel downhill_x=-0.0810 y=1.3203 grounded_ticks=52 normal_y=0.866 stop_on_slope=false`; its complete stdout is Godot banner, blank line, marker, with empty stderr. The level control exits intended negative 2 and prints exact `NEGATIVE REJECTED: slope3d_travel level_no_downhill x=0.0000 y=1.0001 grounded_ticks=44 normal_y=1.000`, same banner/blank line and empty stderr. Both remain on floor at the final check, not every tick. Slope assertions check live rotation within 0.001° of authored 30°, X within 0.003 of -0.0810, center Y within 0.003 of 1.3203, exactly 52 grounded ticks, first floor normal within 0.0001 of literal `(-0.5,0.8660254,0)`; level checks rotation 0, |X|≤0.002, Y within 0.003 of 1.0, exactly 44 grounded ticks, and first normal approximately `(0,1,0)`. Final policy and floor flags are checked. Markers are *fixed labels printed after assertions*, not direct numerical telemetry.

Private ignored copy `corpus/live/r28-private-slope-review/angle/slope3d_travel.gd` changed only `const SLOPE_ANGLE := 30.0` → `40.0` (mutant SHA-256 `055e67c704b07fcbcdd2b956b627fb5ca9181322a36bbc99b2f29d1ddd28e781`):

```sh
/usr/bin/godot --headless --path .shokunin/game-dev-3d/corpus/live/r28-private-slope-review/angle --script res://slope3d_travel.gd
# exit 1; banner only; stderr ERROR: slope3d_travel: slope travel failed x=-0.1347 y=1.4605 grounded=60 normal=(-0.642788, 0.766044, 0.0)
```

The observed angle is 40°, normal matches rotated up at 40°, and measured X/Y/grounded count depart from the independent 30° literals. Rotation is the first term in an `or` assertion, so this run proves rejection on that predicate; it does *not* independently exercise each later short-circuited predicate. Captured `angle.stdout` SHA-256 `1fb0f12cefe41f881cb436e6731d981084b95f8db9b1d6f3e25ac930f360a32e`, `angle.stderr` `dfb86eaf102446cd7dd9c2c7fff4c6eb81d4aecceff16f7c63bcd2a5a59626b5`. No PASS marker, Parse Error, SCRIPT ERROR, or ObjectDB leak.

A separate private ignored copy `corpus/live/r28-private-slope-review/policy/slope3d_travel.gd` changed only `actor.floor_stop_on_slope = false` → `true` in behavior, plus a pre-guard diagnostic print (mutant SHA-256 `b1f7ee79e71a609c91cb988ebf85a46d04390cfe9c0dca12e9b95c93929ba658`):

```sh
/usr/bin/godot --headless --path .shokunin/game-dev-3d/corpus/live/r28-private-slope-review/policy --script res://slope3d_travel.gd
# exit 1; stdout POLICY_OBSERVED x=0.0000 y=1.3662 grounded_ticks=52 normal=(-0.5, 0.866025, 0.0) rotation=30.0 stop=true
# stderr ERROR: slope3d_travel: floor/policy setup lost
```

The original guard rejects true policy before the X assertion; the diagnostic was necessary to measure X≈0. Captured `policy.stdout` SHA-256 `79e4d443df808412093454a964224d446c7de010c1a5de59c941f2605ec83e39`, `policy.stderr` `5ea4f506ffc2bebb4cfd8831eb75cebf9ca500b1890a7a242bf72a7f47f41d6f`. No PASS marker, parse/script error or leak. This reproduces the LOG's adverse default-policy finding and separates it from explicit-policy travel; it does not prove a general friction or acceleration law, universal slope behavior, all-tick grounding, or rendered motion. Reviewer altered only ignored private copies; no tracked fixture constant changed.
