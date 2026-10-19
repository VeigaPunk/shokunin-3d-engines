# Round 50 independent NavigationAgent3D guided-movement review

Reviewer: named LEAF non-author `game-dev-3d-r50-navfollow-review`. Read `LOG.md` r50, fixture README, `navagent3d_follow.gd`, `navfollow3d_driver.gd`, and r49 query review. Pinned `/usr/bin/godot` version `4.7.2.stable.arch_linux.ed1daf0bf`. Sole tracked write: this lesson. Private copy and run receipts are ignored; no implementation edits, push, or merge.

## Independent replay

From repository root, both commands exited **0**:

```sh
python3 corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
python3 corpus/fixtures/run_battery.py --only navagent3d_follow,navagent3d_follow_stationary
```

Full `corpus/live/runs/20261013T081923910743Z/verdicts.json` SHA-256 `3ef16c72bfca8009631f3fe8f38561191b315cc6a58229493584118c679ab7a0`: **75/75 PASS**, 36 ordinary/39 negative, all four probes PASS, `seeds_unchanged=true`. Tree-timeout, crash-exit, stream-attribution and failing-mutation receipt SHA-256 respectively: `cde29260b1b2748acb6b0eec6ba09949b64fc6a3ab9091b03e28ab482d1740e8`, `198538a23d0b06a7db340e75bc6b5f221801c50783e3f9375bb3f8232d5a9db7`, `cbf1ae6d925d902a523b193efe16126b56e87e27f5fa0ea319742721e749dd48`, `6ae57502c91aec61dcd7fb66512534f0565a6840ce276098f69cac98f52c0239`. The registered failing probe mutates body-contact geometry, not this navigation fixture.

Pair `corpus/live/runs/20261013T081923910457Z/verdicts.json` SHA-256 `dd22fa9418f942fe14d9ad1ac3d8e53cbcde06598fd7df3da41e45ddfabdf8b1`: **2/2 PASS**, moving exit0 with exact `PASS navagent3d_follow callbacks=90 first=1.612825,0.000,1.612825 final=3.000,0.000,3.000 reached=true`; stationary exit2 with exact `NEGATIVE REJECTED: navagent3d_follow stationary callbacks=90 final=1.000,0.000,1.000 reached=false`. Empty stderr/reasons on both arms. Full/pair seed maps agree. Previous r49 full `corpus/live/runs/20261013T081147076161Z/verdicts.json` SHA-256 `443b353c12e75ea19dd5701c978f6a8e875c6a11c9e2374e2ded1aff689e2bb4`: **all 73 complete raw records identical** in `case, script, flags, expected_exit, actual_exit, error, kind, marker, verdict, reasons, stdout, stderr`; elapsed/command scratch location excluded. Compared with r49, only README seed `c7d186bbb33d9d3ad47d7f0e41fbbc7a1fe15c0391775864d9ff52d1e74f3589` → `f2ada544d79e14cf5f062a84ff6691d2241ffcf53b4fd9f43aa970547b7af4bc`, runner `2cebcaa4e4dee61a131fa02f3b8039d9d79e9ad70c15c4148c71e7a68af76d26` → `4b81589a3177d709f4119861eef97048d30fd3442ce1dced3d9e8e91057f2e0a`, and new `navagent3d_follow.gd` `2bdcca4a08bd290bdcb097155c2299ae0fa6b5ac4893f68c2a04b073b782830c` / `navfollow3d_driver.gd` `ec094e7f7baa317636b093d622687cae4f30928df417a547900406f759d28bbf` differ. Every other seed hash unchanged.

## Source and private mutant

`navagent3d_follow.gd` builds a live active map/one region with a hand-authored flat four-vertex, single-polygon 4×4 NavigationMesh. A live actor Node3D at `(1,0,1)` has a child NavigationAgent3D explicitly assigned that map and target `(3,0,3)`. Unlike r49's stationary next-path query, `navfollow3d_driver.gd` actually executes `_physics_process(delta)`: each tick calls `agent.get_next_path_position()`, then, unless the intact `--stationary` control is selected, assigns `global_position.move_toward(next, SPEED * delta)` with speed **2.0**. It records tick30 and tick90 positions, first next point, callback count and delta sum, and caps at 90 callbacks. The SceneTree awaits 95 physics frames, checks 90 callbacks and sum≈1.5 seconds, first next=start `(1,0,1)` (the initial-path quirk), two-point path start/target, and then measured moving tick30≈`(1.612825,0,1.612825)`, final/global position≈target `(3,0,3)`, `is_target_reached()` and `is_navigation_finished()` true. The same-map, same-target speed-zero control receives 90 callbacks, stays `(1,0,1)` at both checkpoints, and both status reads remain false. The fixed marker follows these checks; it is not itself a measurement.

Private copied **only** `const SPEED := 2.0` → `const SPEED := 1.0` in ignored `corpus/live/runs/r50-navfollow-review-private/navfollow3d_driver.gd`, SHA-256 `9d0b55f0fcdab0d214a06f49bebc19e60f1de3ade6580630957e8977f520bd8b`. Reproduce from repository root:

```sh
/usr/bin/godot --headless --path corpus/live/runs/r50-navfollow-review-private --script res://navagent3d_follow.gd > corpus/live/runs/r50-navfollow-review-private/mutant.stdout 2> corpus/live/runs/r50-navfollow-review-private/mutant.stderr
```

Ordinary arm **exit1**, stdout only Godot banner, SHA-256 `1fb0f12cefe41f881cb436e6731d981084b95f8db9b1d6f3e25ac930f360a32e`; stderr SHA-256 `c8d8c4630cfc7911e37fc5739873950dd27a2a7810927ae229c671982e8d1fc9` includes `ERROR: navagent3d_follow: agent-guided actor motion mismatch first=(1.306414, 0.0, 1.306414) final=(2.013523, 0.0, 2.013523) reached=false finished=false`. Setup, callback-count/delta/initial-next, and path guards passed before this actor-measured failure; no `PASS`, parser/SCRIPT ERROR, or ObjectDB leak. The moving checkpoint/final/status are a compound assertion: this one mutation does not isolate each independently.

**Bounded finding:** depth improves from r49's unmoving NavigationAgent3D next-path query to one scripted actor following its measured next position in actual live physics callbacks. Coverage/calibration not independently expanded by this test. NavigationAgent3D does **not** move this actor autonomously; no avoidance, NavigationMesh baking, physical collision, rendered pixels, arbitrary timing/route, or other engine-version guarantee. Assumptions/constants: pinned Godot build and 60 Hz physics, actor `(1,0,1)`, authored flat 4×4 polygon and target `(3,0,3)`, callback cap 90 and observation after 95 frames; only the ignored private driver's speed changed to 1.0.

## Correction note — 2026-10-18 (r106)

Dated correction note, not a rewrite of the findings above. Runnable command lines cited `.shokunin/game-dev-3d/` or `/home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/`. Those lines only were rewritten to repo-relative paths. Prose receipt paths, exits, markers, and SHA-256 values are unchanged.

Original commands at HEAD `0cc3f4162f8c319f8d01a69a174fe939f36701bd`:

```
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only navagent3d_follow,navagent3d_follow_stationary
/usr/bin/godot --headless --path /home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/r50-navfollow-review-private --script res://navagent3d_follow.gd > /home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/r50-navfollow-review-private/mutant.stdout 2> /home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/r50-navfollow-review-private/mutant.stderr
```

Measured from this root the same day: dead-root python → rc 2. Repo-relative `--only navagent3d_follow,navagent3d_follow_stationary` → rc 0, `PASS battery`, `seeds_unchanged=true` (durable copy `reports/round-106/scratch/seat07/only/nav-follow.verdicts.json`, sha256 `0bfa6683904253f7ce516e811c0f39c7bd543a6911686a9fe134d115e2c019e4`). Full probe battery not re-run. Cited `20261013T081923910743Z`, `20261013T081923910457Z`, and `20261013T081147076161Z` receipts, and `corpus/live/runs/r50-navfollow-review-private/`, are absent. Rewritten godot command exits 1: `Invalid project path specified: "corpus/live/runs/r50-navfollow-review-private"`. Godot pin re-checked: `4.7.2.stable.arch_linux.ed1daf0bf`. Live `corpus/fixtures/navagent3d_follow.gd` sha256 `2bdcca4a08bd290bdcb097155c2299ae0fa6b5ac4893f68c2a04b073b782830c` and `corpus/fixtures/navfollow3d_driver.gd` sha256 `ec094e7f7baa317636b093d622687cae4f30928df417a547900406f759d28bbf` match the added-seed hashes quoted above. Bare narrative names `navagent3d_follow.gd` and `navfollow3d_driver.gd` do not exist at repo root; those sentences were not rewritten. Quoted runner/README digests are review-day rows; live runner is `f456bd00…` and live README is `347e0d1e…` (full digests in the ledger). Ledger: `reports/round-106/sweep/chunk-07.md`.

<!-- r106-seat45-receipt-note -->

> **Non-resolvable receipt note (r106, 2026-10-18, SEAT-45).** Re-checked 2026-10-18: each path below is a concrete `corpus/live/runs` receipt cited in this lesson. The cited path is absent (`test -e` failed) and no durable copy exists under `reports/` (no receipt artifact whose path or `started_utc` is that run id; a prose mention is not a copy). Quoted receipt SHA-256 values on these lines do not match any tracked file or any `reports/` receipt artifact. `corpus/.gitignore` ignores `live/`, so these paths were never tracked. Historical sentences above are unchanged. Register: `reports/round-106/consistency/receipts.md`.
>
> - `corpus/live/runs/20261013T081923910743Z/verdicts.json`
> - `corpus/live/runs/20261013T081923910457Z/verdicts.json`
> - `corpus/live/runs/20261013T081147076161Z/verdicts.json`
> - `corpus/live/runs/r50-navfollow-review-private/navfollow3d_driver.gd`
> - `corpus/live/runs/r50-navfollow-review-private`
> - `corpus/live/runs/r50-navfollow-review-private/mutant.stdout`
> - `corpus/live/runs/r50-navfollow-review-private/mutant.stderr`
> - `corpus/live/runs/r50-navfollow-review-private/`
