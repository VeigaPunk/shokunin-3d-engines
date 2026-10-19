# Round 48 independent RemoteTransform3D rotation-attribution review

Reviewer: LEAF non-author `game-dev-3d-r48-rotation-review`. Read LOG r48, fixture README, and source. Godot `4.7.2.stable.arch_linux.ed1daf0bf` at `/usr/bin/godot`. Sole tracked write: this lesson. Runs/private copies are ignored; no implementation edits, push, or merge.

## Replay

Both exact repository-root commands exited 0:

```sh
python3 corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
python3 corpus/fixtures/run_battery.py --only remote3d_transform,remote3d_transform_unbound
```

Full `.shokunin/game-dev-3d/corpus/live/runs/20261013T080440209599Z/verdicts.json` SHA-256 `bbb6814ca956a7e004e32fa21890a9346f4be3fb3a27718045d5b4f114918460`: **71/71 PASS** (34 ordinary, 37 negative), four optional probes PASS. Tree/crash/stream/failing probe receipt SHA-256 respectively `8b9939ac1313539eae2a58035f4e037deede1af31d4448461c2b0a038cc8e3dd`, `84dfd7cdae383f982e9dc47c300a4174f5c63d0ecc449c6e575b9ab921cdee2b`, `30e94d9b4502f7654590cf2987dcf3f5cdcec8e4717ff19baa8f5425f0fa8f3b`, `45190f36c939f2ec659bea895f5fcb0d4a42f3076b3347b9befba4156ac32984`. Failing probe mutates body contact, not remote rotation. Pair `.shokunin/game-dev-3d/corpus/live/runs/20261013T080453242226Z/verdicts.json` SHA-256 `00445f9069abdfb2e10ab7b1854115c946c1acb71355c655b2ac3bf146158a4f`: **2/2 PASS**; bound exit0 and unbound exit2, same baseline exact markers, empty stderr/reasons. Seed maps match both runs and each before/after state. All **71** r47 complete raw records (`case, script, flags, expected_exit, actual_exit, error, kind, marker, verdict, reasons, stdout, stderr`) identical to current; elapsed seconds/scratch commands deliberately excluded. Prior `.shokunin/game-dev-3d/corpus/live/runs/20261013T075737700845Z/verdicts.json` SHA-256 `3f4b724d9f3ca64c7cfd9e2ce3be01c791cc5fe6a1a1e71d07d6c1aef3e30a5d`. Seed-map differences only README `c3080154e73f1f1dbb6ad381018be3999d66674cb7f21f5766330728beef5aa1` → `a5853c52d348a04e897a7a65299d85f5bad6079f84c23a21ae26c9c1b2fb923d` and remote script `19db84ebca945b9bfb01589d5cc62ae11168ffa2d5649d4f706c654cbdba98d5` → `65422bef734af4f8f50dc269c09853f3e7c9c8aa74225ecf4d3fe853f4b9fed4`; runner and all others unchanged.

## Private independent controls

Both private projects copied paired scratch; seed SHA-256 `65422bef734af4f8f50dc269c09853f3e7c9c8aa74225ecf4d3fe853f4b9fed4`. Exact commands, invoked from repo root:

```sh
godot --headless --path corpus/live/runs/r48-rotation-review-private/source-pi3 --script res://remote3d_transform.gd > corpus/live/runs/r48-rotation-review-private/source-pi3/mutation.stdout 2> corpus/live/runs/r48-rotation-review-private/source-pi3/mutation.stderr
godot --headless --path corpus/live/runs/r48-rotation-review-private/rotation-disabled --script res://remote3d_transform.gd > corpus/live/runs/r48-rotation-review-private/rotation-disabled/mutation.stdout 2> corpus/live/runs/r48-rotation-review-private/rotation-disabled/mutation.stderr
```

**A** `.shokunin/game-dev-3d/corpus/live/runs/r48-rotation-review-private/source-pi3/remote3d_transform.gd` SHA-256 `1a7441f65e0ed3491dfdd608206398d1534f5596d7cf307da63889c117effb3b`: change source Z angle `PI / 2` → `PI / 3`, change only unique source basis-X setup expectation `Vector3(0, 1, 0)` → `Vector3(0.5, 0.8660254, 0)`; retain target expectations. Ordinary exit **1**, stdout SHA-256 `1fb0f12cefe41f881cb436e6731d981084b95f8db9b1d6f3e25ac930f360a32e` Godot banner only, no PASS. Stderr SHA-256 `3ae64fa68bda0d571ba78a67cb17c78388d82c9017d8e4edfdf75d3c25af384f`: `ERROR: remote3d_transform: remote target basis mismatch target=[X: (0.5, 0.866025, 0.0), Y: (-0.866025, 0.5, 0.0), Z: (0.0, 0.0, 1.0), O: (2.0, 1.0, -3.0)]` at `_run` line39. Source and binding guards and literal Target origin `(2,1,-3)` check passed, so failure is measured Target basis, not source-only guard.

**B** `.shokunin/game-dev-3d/corpus/live/runs/r48-rotation-review-private/rotation-disabled/remote3d_transform.gd` SHA-256 `fce67899cd3bbda395677bcde09ec6b0abe4afaf0bb40c61b742c4661a59e218`: set `source.update_rotation = false` immediately before source assignments; remove only `or not source.update_rotation` in setup guard. Source Z+90° and translation remain intact. Ordinary exit **1**, stdout SHA-256 `1fb0f12cefe41f881cb436e6731d981084b95f8db9b1d6f3e25ac930f360a32e` banner only, no PASS. Stderr SHA-256 `9d67ad81ff41f066c41b5aa0775b75957c0e6349452ac0c662e2a83ac6105a2e`: `ERROR: remote3d_transform: remote target basis mismatch target=[X: (1.0, 0.0, 0.0), Y: (0.0, 1.0, 0.0), Z: (0.0, 0.0, 1.0), O: (2.0, 1.0, -3.0)]` at `_run` line40. Target translation still propagated while target basis remained identity; binding/source and literal target-origin assertions passed.

Neither stderr contains `Parse Error`, `SCRIPT ERROR`, or ObjectDB leak warning. Both basis diagnostics test X **or** Y as a compound predicate; individual columns are not separately mutation-isolated. Private failed controls are not new registered battery cases. Bounded judgment: **calibration improved** through two independently target-measured rotation controls after r47's translation-only test; coverage/depth unchanged. Only one headless scene-tree binding tested, not network replication, rendered movement or general propagation guarantees.

## Correction note — 2026-10-18 (r106)

Dated correction note, not a rewrite of the findings above. Runnable command lines cited `.shokunin/game-dev-3d/` or `/home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/`. Neither root exists as a directory at this repo root. Those lines only were rewritten to repo-relative paths. Prose receipt paths, exits, markers, and SHA-256 values are unchanged.

Original commands at HEAD `0cc3f4162f8c319f8d01a69a174fe939f36701bd`:

```
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only remote3d_transform,remote3d_transform_unbound
godot --headless --path /home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/r48-rotation-review-private/source-pi3 --script res://remote3d_transform.gd > /home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/r48-rotation-review-private/source-pi3/mutation.stdout 2> /home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/r48-rotation-review-private/source-pi3/mutation.stderr
godot --headless --path /home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/r48-rotation-review-private/rotation-disabled --script res://remote3d_transform.gd > /home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/r48-rotation-review-private/rotation-disabled/mutation.stdout 2> /home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/r48-rotation-review-private/rotation-disabled/mutation.stderr
```

Measured from this root the same day: `ls -ld .shokunin` → No such file or directory. The predecessor symlink `/home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d` still points at this repo, but the cited scratch under it is gone. Dead-root python `--only remote3d_transform` → rc 2. Absolute-root godot command → rc 1, `Invalid project path specified: "/home/vgpnk/Projects/prymeagnt/…/r48-rotation-review-private/source-pi3"`. Repo-relative `--only remote3d_transform,remote3d_transform_unbound` → rc 0, `PASS battery`, `seeds_unchanged=true` (durable copy `reports/round-106/scratch/seat07/only/remote-pair.verdicts.json`, sha256 `19c2a38827bbc7b4e32c1e4dde80f5e4d968f9a7461fa44feb156a067f88cf2e`). Full probe battery not re-run. Cited `20261013T080440209599Z`, `20261013T080453242226Z`, and `20261013T075737700845Z` receipts, and both private scratch dirs, are absent (`corpus/.gitignore:1` is `live/`). Rewritten godot commands still exit 1: `Invalid project path specified: "corpus/live/runs/r48-rotation-review-private/source-pi3"`. Godot pin re-checked: `4.7.2.stable.arch_linux.ed1daf0bf`. Live `remote3d_transform.gd` sha256 `65422bef734af4f8f50dc269c09853f3e7c9c8aa74225ecf4d3fe853f4b9fed4` matches the post-change seed quoted above. Quoted runner/README digests are review-day rows; live runner is `f456bd00…` and live `corpus/fixtures/README.md` is `347e0d1e…` (full digests in `reports/round-106/sweep/chunk-07.md`). Not rewritten. Ledger: that file.

<!-- r106-seat45-receipt-note -->

> **Non-resolvable receipt note (r106, 2026-10-18, SEAT-45).** Re-checked 2026-10-18: each path below is a concrete `corpus/live/runs` receipt cited in this lesson. The cited path is absent (`test -e` failed) and no durable copy exists under `reports/` (no receipt artifact whose path or `started_utc` is that run id; a prose mention is not a copy). Quoted receipt SHA-256 values on these lines do not match any tracked file or any `reports/` receipt artifact. `corpus/.gitignore` ignores `live/`, so these paths were never tracked. Historical sentences above are unchanged. Register: `reports/round-106/consistency/receipts.md`.
>
> - `corpus/live/runs/20261013T080440209599Z/verdicts.json`
> - `corpus/live/runs/20261013T080453242226Z/verdicts.json`
> - `corpus/live/runs/20261013T075737700845Z/verdicts.json`
> - `corpus/live/runs/r48-rotation-review-private/source-pi3`
> - `corpus/live/runs/r48-rotation-review-private/source-pi3/mutation.stdout`
> - `corpus/live/runs/r48-rotation-review-private/source-pi3/mutation.stderr`
> - `corpus/live/runs/r48-rotation-review-private/rotation-disabled`
> - `corpus/live/runs/r48-rotation-review-private/rotation-disabled/mutation.stdout`
> - `corpus/live/runs/r48-rotation-review-private/rotation-disabled/mutation.stderr`
> - `corpus/live/runs/r48-rotation-review-private/source-pi3/remote3d_transform.gd`
> - `corpus/live/runs/r48-rotation-review-private/rotation-disabled/remote3d_transform.gd`
