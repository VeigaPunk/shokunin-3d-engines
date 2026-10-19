# Round 51 independent in-flight NavigationAgent3D retarget review

Reviewer: named LEAF non-author `game-dev-3d-r51-retarget-review`. Read `LOG.md` r51, fixture `README.md`, `navagent3d_retarget.gd`, `navretarget3d_driver.gd`, and `r50-navfollow-review.md`. Pinned `/usr/bin/godot` 4.7.2.stable.arch_linux.ed1daf0bf. Sole tracked write is this lesson; private files/receipts under ignored `corpus/live/runs/`. No implementation edits, push, or merge.

## Independent replay

Both commands from repository root exited **0**:

```sh
python3 corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
python3 corpus/fixtures/run_battery.py --only navagent3d_retarget,navagent3d_retarget_fixed
```

Full `corpus/live/runs/20261013T082700091224Z/verdicts.json` SHA-256 `9d7f738bc9ac34c70fd679b6728b4fd2bdc53c9af403e8b2b2b5ce250544084d`: **77/77 PASS**, 37 ordinary/40 negative, all four opt-ins PASS, `seeds_unchanged=true`. Tree-timeout, crash-exit, stream-attribution, and failing-mutation receipts SHA-256 respectively `bd5d2a403108e23f67d08e3b6d4cdc180ba770b5c4022d8d6c3e36832cbdee0e`, `7bf262e274d07d989e730fe52a5a771bb5afe593780cfa325da1d7eca019fe83`, `a2142dbd69ed317ddd1ae3c3d01050eca5ce455e34b923257d851d09a6a4b393`, `9de921d1212e8cbc483df12ac6a602fa657e0eea4da8628a63223bf1218cbf28`. The registered failing probe is still a body-contact geometry mutation, not the retarget fixture.

Pair `corpus/live/runs/20261013T082700092449Z/verdicts.json` SHA-256 `0836b103e153f461989819b35979aa1cb4ac7d0c00fb60768173608490e5900c`: **2/2 PASS**; ordinary exit0 marker `PASS navagent3d_retarget callbacks=120 before=1.730676,0.000,1.730676 after_end=1.000,0.000,3.000 final=1.000,0.000,3.000`; fixed-target negative exit2 marker `NEGATIVE REJECTED: navagent3d_retarget fixed callbacks=120 after_end=3.000,0.000,3.000 final=3.000,0.000,3.000`; empty stderr and reasons. Full and pair seed maps agree.

Prior r50 full `corpus/live/runs/20261013T081923910743Z/verdicts.json` SHA-256 `3ef16c72bfca8009631f3fe8f38561191b315cc6a58229493584118c679ab7a0`: all **75 complete raw case records identical** across `case, script, flags, expected_exit, actual_exit, error, kind, marker, verdict, reasons, stdout, stderr`; elapsed/command scratch paths excluded. Previous→current seed differences only `README.md` `f2ada544d79e14cf5f062a84ff6691d2241ffcf53b4fd9f43aa970547b7af4bc` → `998bc12a7ac4f78d85503310ae0f2cd7f1925e81f97f8a7dfad524a392529be0`, `run_battery.py` `4b81589a3177d709f4119861eef97048d30fd3442ce1dced3d9e8e91057f2e0a` → `2b542fc0859afab6e94ffd5a898e1a427b0b5d462fce133c5c62504485f07922`, plus new `navagent3d_retarget.gd` `f323a2058e0f7de3e49b9bf83a59026d3aec14aa8d1c69e277d057fe02554b03` and `navretarget3d_driver.gd` `310a1419c878f13b973b7fff895f5f1d536c7d69bcfb6e5faab98a9f2e7b0102`. All other seed hashes unchanged.

## Live behavior and private mutant

`navagent3d_retarget.gd` creates an active NavigationServer3D map, one region and one authored flat 4×4 polygon, and a live actor at `(1,0,1)` with child NavigationAgent3D bound to the map and initially targeted at `(3,0,3)`. `navretarget3d_driver.gd` runs actual `_physics_process(delta)` callbacks, reads `get_next_path_position()`, and **scripts** actor `global_position.move_toward(next, 2*delta)`. At `ticks == 35`, before that callback's next-point query, it records actor `(1.730676,0,1.730676)` and changes target to `(1,0,3)` only in ordinary arm. It then captures current two-point path beginning at pre-switch position and ending `(1,0,3)`, plus next `(1,0,3)`; after 120 callbacks, actor/global final `(1,0,3)` and `is_target_reached()`/`is_navigation_finished()` true. The same callback count/map/script with `--fixed` leaves target `(3,0,3)` and completes there with reached/finished true; its path begins at original actor start `(1,0,1)`. First callback next=start `(1,0,1)` on this build, not the target. SceneTree awaits 125 frames, tests 120 callbacks and delta sum≈2.0 seconds; both markers are emitted only after checks. The after-path start, endpoint **and next are a compound assertion**, not independently mutation-isolated.

Private copy of **only** `navretarget3d_driver.gd` changed `agent.target_position = Vector3(1, 0, 3)` → `agent.target_position = Vector3(2, 0, 3)`; SHA-256 copied mutated driver `348aab36d650ecd3d0a5b492b78935345d92213494b7accd6519c0e44ec9161a`. Fixture and project copies match seed digests. Reproduce:

```sh
/usr/bin/godot --headless --path corpus/live/runs/r51-retarget-review-private --script res://navagent3d_retarget.gd > corpus/live/runs/r51-retarget-review-private/mutant.stdout 2> corpus/live/runs/r51-retarget-review-private/mutant.stderr
```

Ordinary mutant **exit1**: stdout Godot banner only (SHA-256 `1fb0f12cefe41f881cb436e6731d981084b95f8db9b1d6f3e25ac930f360a32e`), stderr SHA-256 `723e65eedf50bfcf0d8233ca171d9007243898e28825f997fff44d44a9d8f75c` reports `ERROR: navagent3d_retarget: agent route after switch mismatch path=[(1.730676, 0.0, 1.730676), (2.0, 0.0, 3.0)] next=(2.0, 0.0, 3.0)`. The live setup and pre-switch position/tick/initial-next guards passed; failure is measured post-retarget path/next, **before** the final actor endpoint check. No `PASS`, parser/`SCRIPT ERROR`/`Parse Error`, or ObjectDB leak. This mutant does not separately isolate path endpoint from next or prove a mutated final position.

**Bounded finding:** one headless, scripted in-flight NavigationAgent3D target change reroutes measured path/next and actor endpoint beyond r50's fixed-target follow. This is not autonomous NavigationAgent3D movement, avoidance, baked navigation mesh generation, collision, rendered pixels, or general route/timing guarantees. Assumptions/constants: pinned Godot build, 60 Hz physics, start `(1,0,1)`, original `(3,0,3)`, ordinary retarget `(1,0,3)` at callback index 35, speed 2, 120 callback cap, 125-frame observation. Only ignored private driver changes retarget destination to `(2,0,3)`.

## Correction note — 2026-10-18 (r106)

Dated correction note, not a rewrite of the findings above. Runnable command lines cited `.shokunin/game-dev-3d/` or `/home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/`. Those lines only were rewritten to repo-relative paths. Prose receipt paths, exits, markers, and SHA-256 values are unchanged.

Original commands at HEAD `0cc3f4162f8c319f8d01a69a174fe939f36701bd`:

```
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only navagent3d_retarget,navagent3d_retarget_fixed
/usr/bin/godot --headless --path /home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/r51-retarget-review-private --script res://navagent3d_retarget.gd > /home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/r51-retarget-review-private/mutant.stdout 2> /home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/r51-retarget-review-private/mutant.stderr
```

Measured from this root the same day: dead-root python → rc 2. Repo-relative `--only navagent3d_retarget,navagent3d_retarget_fixed` → rc 0, `PASS battery`, `seeds_unchanged=true` (durable copy `reports/round-106/scratch/seat07/only/nav-retarget.verdicts.json`, sha256 `8ea9da88aebc81219cf4d16a31fa93a9cb0bba73c8af127b26898e4889a21770`). Full probe battery not re-run. Cited `20261013T082700091224Z`, `20261013T082700092449Z`, and `20261013T081923910743Z` receipts, and `corpus/live/runs/r51-retarget-review-private/`, are absent. Rewritten godot command exits 1: `Invalid project path specified: "corpus/live/runs/r51-retarget-review-private"`. Godot pin re-checked: `4.7.2.stable.arch_linux.ed1daf0bf`. Live `corpus/fixtures/navretarget3d_driver.gd` sha256 `310a1419c878f13b973b7fff895f5f1d536c7d69bcfb6e5faab98a9f2e7b0102` matches the added-seed hash quoted above. Quoted `navagent3d_retarget.gd` `f323a2058e0f7de3e49b9bf83a59026d3aec14aa8d1c69e277d057fe02554b03` does not match the live file `6ad8584642edf8b1c41fb7116f39bf0e2d9513a2d73a99f0ea83d5cd4e1059d0`. That successor hash is the one `corpus/lessons/r52-final-review.md` records as the r52 change; `git log -1 -- corpus/fixtures/navagent3d_retarget.gd` → `b214575` (2026-10-13) `game-dev-3d r52: isolate retarget actor endpoint assertion`. The r51 sentence was not rewritten. Bare `r50-navfollow-review.md`, `navagent3d_retarget.gd`, and `navretarget3d_driver.gd` do not exist at repo root; resolving paths are under `corpus/lessons/` and `corpus/fixtures/`. Those narrative names were not rewritten. Quoted runner `2b542fc0…` and README `998bc12a…` are review-day rows; live runner is `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` and live `corpus/fixtures/README.md` is `347e0d1e5e4efca9c6f8b93440370352278bb30f3c1f62cee19edd3704619cb1`. Ledger: `reports/round-106/sweep/chunk-07.md`.

<!-- r106-seat45-receipt-note -->

> **Non-resolvable receipt note (r106, 2026-10-18, SEAT-45).** Re-checked 2026-10-18: each path below is a concrete `corpus/live/runs` receipt cited in this lesson. The cited path is absent (`test -e` failed) and no durable copy exists under `reports/` (no receipt artifact whose path or `started_utc` is that run id; a prose mention is not a copy). Quoted receipt SHA-256 values on these lines do not match any tracked file or any `reports/` receipt artifact. `corpus/.gitignore` ignores `live/`, so these paths were never tracked. Historical sentences above are unchanged. Register: `reports/round-106/consistency/receipts.md`.
>
> - `corpus/live/runs/20261013T082700091224Z/verdicts.json`
> - `corpus/live/runs/20261013T082700092449Z/verdicts.json`
> - `corpus/live/runs/20261013T081923910743Z/verdicts.json`
> - `corpus/live/runs/r51-retarget-review-private`
> - `corpus/live/runs/r51-retarget-review-private/mutant.stdout`
> - `corpus/live/runs/r51-retarget-review-private/mutant.stderr`
> - `corpus/live/runs/r51-retarget-review-private/`
