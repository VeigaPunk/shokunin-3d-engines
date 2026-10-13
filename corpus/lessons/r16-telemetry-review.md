# r16 independent non-author telemetry review (2026-10-13)

**Named non-author verdict: PASS, narrowly for observed slope marker telemetry and floor-angle setting readback in Godot 4.7.2 headless.** I did not author implementation or change fixture seeds. At review start HEAD `7af58a7ed8e71fb3f2bd9dc7dfc3a83166235891` on `craft/game-dev-3d-r1`; `LOG.md`, fixture `README.md`, and `slope3d_angle.gd` were uncommitted author edits. Godot `/usr/bin/godot --version`: `4.7.2.stable.arch_linux.ed1daf0bf`. Read LOG round-16 predeclaration and `corpus/lessons/r15-slope-review.md`.

## Independent runs and preservation

From repo root, independently executed (both exit **0**):

```sh
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only slope3d_floor,slope3d_steep
```

Full raw receipt: `.shokunin/game-dev-3d/corpus/live/runs/20261013T050610908903Z/verdicts.json`. **21/21** seeded cases PASS (10 ordinary, 11 negative), four optional probes PASS; raw probe receipts beside it: `tree-timeout-verdicts.json`, `crash-exit-verdicts.json`, `stream-attribution-verdicts.json`, `mutation-verdicts.json`. Pair raw receipt: `.shokunin/game-dev-3d/corpus/live/runs/20261013T050610910459Z/verdicts.json` (**2/2**). Both report `seeds_unchanged=true`, and their 20-entry seed digest maps agree. Floor actual exit 0, stdout engine banner/blank line then exactly `PASS slope3d_floor normal_y=0.866 floor_limit=45.000 on_floor=true on_wall=false live_contact=true`; steep actual exit 2, same banner/blank then exactly `NEGATIVE REJECTED: slope3d_angle steep_contact_not_floor normal_y=0.500 floor_limit=45.000 on_floor=false on_wall=true live_contact=true`; stderr empty in both full and paired runs.

Compared all **21 r15 cases** to `.shokunin/game-dev-3d/corpus/live/runs/20261013T050139735344Z/verdicts.json`: case names, flags, raw stdout/stderr arrays, actual/expected exits, kind, expected marker, and verdict match exactly. All 20 r15 seed paths persist; only intentional `README.md` and `slope3d_angle.gd` digests change. The slope seed SHA-256 moves from r15 `da332f721dc2c7edecbba153280c075c95452a8cb9d78134c60598c7917659f8` to r16 `0833050b4581738aaf7c784db3b473455ee3bb429eb11a0ed9b4f13f2bce4ccc`; the other 18 seed digests match r15. This is preservation of exact tested outputs, not proof of identical internals.

## Source and adverse probes

`slope3d_angle.gd` reads `actor.first_contact_normal` captured by `runner3d.gd` from a real `get_slide_collision(0).get_normal()`, with bounded `contacts >= 1` and first contact; checks that vector against independent hand-authored literal normals with 0.001 tolerance. It reads `rad_to_deg(actor.floor_max_angle)` and `rad_to_deg(slab.rotation.z)`, comparing them against independent **literal** `45.0` and `30.0`/`60.0` within 0.001, not expectations derived from `FLOOR_LIMIT`, `SHALLOW_ANGLE`, or `STEEP_ANGLE`. Only afterward it queries `is_on_floor()`/`is_on_wall()`, checks expected flags, and formats `normal.y`, observed limit, both queried flags and `actor.contacts >= 1` into the exact markers. `%.3f` rounds numeric evidence: the marker is formatted observation under tolerances, not an exact full-precision measurement; live contact remains a cumulative-count flag, and the first-contact normal is historical rather than re-read at the flag snapshot.

In **private copied seeds** at `.shokunin/game-dev-3d/corpus/live/runs/review-r16-20261013T050627684826Z`, the original seed SHA remains `0833050b4581738aaf7c784db3b473455ee3bb429eb11a0ed9b4f13f2bce4ccc`. Replaced one exact `const FLOOR_LIMIT := 45.0` by `const FLOOR_LIMIT := 35.0` only (`floor-limit35/slope3d_angle.gd` SHA-256 `8cb9567761fe7e2d3472dc4ca3418ae248be63a9fcf4a8023f4d3db55c66b873`). Direct commands:

```sh
godot --headless --path .shokunin/game-dev-3d/corpus/live/runs/review-r16-20261013T050627684826Z/floor-limit35 --script res://slope3d_angle.gd
godot --headless --path .shokunin/game-dev-3d/corpus/live/runs/review-r16-20261013T050627684826Z/floor-limit35 --script res://slope3d_angle.gd -- --steep
```

**Both exit 1**, stdout only engine banner/blank, stderr respectively `ERROR: slope3d_angle: setting mismatch floor_limit=35.000 tilt=30.000 expected_limit=45.000 expected_tilt=30.000` and `... tilt=60.000 ... expected_tilt=60.000`, plus `_fail` stack. No PASS/NEGATIVE marker or parser error. Separate copied *counterfactual control* retains the 35° setting but changes solely the independent check `observed_limit - 45.0` to `observed_limit - 35.0` in scratch (SHA `f5249debc20007f9b73e872e371586b49cbcc5549e4d53a6be5574ec5727918f`): the same direct commands under `.shokunin/game-dev-3d/corpus/live/runs/review-r16-20261013T050627684826Z/floor-limit35-control` exit **0/2** with normal-y **0.866/0.500**, `on_floor=true/on_wall=false` and `on_floor=false/on_wall=true`, and observed `floor_limit=35.000` markers, empty stderr. Therefore this 45→35 change actually preserves both classification outcomes and is rejected by the new readback guard rather than a solver-classification failure. Control is a diagnostic scratch mutation, not a production expectation.

Old 30→60 sensitivity remains: separate private copy changes only `const SHALLOW_ANGLE := 30.0` to `60.0` (SHA `571d79a09cd5ede6652a3eba079822c3efbb79f27e1155616494075229205b22`). Direct commands under `.shokunin/game-dev-3d/corpus/live/runs/review-r16-20261013T050627684826Z/shallow60` (with and without `-- --steep`) exit **1/2** respectively. Shallow stdout has no marker; stderr identifies `normal mismatch normal=(-0.866025, 0.5, 0.0) expected=(-0.5, 0.866025, 0.0)`. Steep unchanged passes its expected marker; mutation applies to shallow geometry only. All direct-run streams saved in `.shokunin/game-dev-3d/corpus/live/runs/review-r16-20261013T050627684826Z/*-{floor,steep}.stdout` / `.stderr` (and first-run combined transcript in `direct-mutants.json`).

**Limits:** One pair of authored angles and one 35° counterfactual on this host, not generic floor-angle boundary precision. No fresh same-step contact normal/flags assertion, persistent contact, downhill slide, gravity, rendering, exported builds or other engines. Timeout, signal and stderr probes have their existing narrow bounded meanings; no arbitrary process-tree guarantee or spontaneous crash claim. No implementation edits, push, merge, or judgment of other axes.
