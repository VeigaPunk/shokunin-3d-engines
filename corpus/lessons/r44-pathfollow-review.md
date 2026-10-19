# Round 44 independent PathFollow3D review

Reviewer: named LEAF non-author `game-dev-3d-r44-pathfollow-review`. LOG r44 before-state `c8ca2f11e2f290df81da1c0922dca9dc4bc67fa8`; Godot `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`, Linux headless. This is my sole tracked write. No implementation, runner, README, LOG, push or merge changes; private scratch is ignored under `corpus/live/runs/`.

## Independent replay and prior-case comparison

Both exact commands run from repository root and exit **0**:

```sh
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only pathfollow3d_curve,pathfollow3d_curve_straight
```

Full receipt `.shokunin/game-dev-3d/corpus/live/runs/20261013T073855191130Z/verdicts.json` SHA-256 `e330b092ed7910ff9b77b8bff3ac3f7c7d8b57e3c587ea890b302a096362e5b6`: **65/65 PASS**, 31 ordinary and 34 negative controls; four opt-ins (tree timeout, crash exit, stream attribution, existing body-contact failing mutation) report success, seeds unchanged. The body-contact probe is **not** the path-follow mutation below. Pair receipt `.shokunin/game-dev-3d/corpus/live/runs/20261013T073855191088Z/verdicts.json` SHA-256 `8ab7d1731578ed73f6987e89faaa17a4ed3599a3c5bb49c70ef079e2854f7f2a`: **2/2 PASS**, bent exit 0, straight exit 2, empty stderr and reasons; both runs have identical seed maps. Bent stdout marker `PASS pathfollow3d_curve bent first_y=1.118620 second_y=1.118619 marker_offset_z=1.000`; straight stdout marker `NEGATIVE REJECTED: pathfollow3d_curve straight first_y=0.000 second_y=0.000 marker_offset_z=1.000`. Per-case raw streams and exact subprocess argv appear in JSON receipts.

Prior r43 full receipt `.shokunin/game-dev-3d/corpus/live/runs/20261013T073219874871Z/verdicts.json` SHA-256 `af9bcdd8f321d779ef2fb07b2fefe93cf865067934031f0715633c7f28a5bcd7`: 63/63 PASS. All **63** prior complete raw case records exactly match on `case, script, flags, expected_exit, actual_exit, error, kind, marker, verdict, reasons, stdout, stderr` (zero discrepancies); scratch paths and elapsed time naturally differ. Compared with the r43 seed map, only `README.md` changed `d7e5ae97ae9842450406ee3b3deacb3ef677b9965115e7346a7e011776a8d9d4` → `29d4b08a18fcdc2c107dcfc4859a8516981900aca2bd1e74088bf683da5abf0d`, `run_battery.py` changed `dc452c49648d640e6bcb09037b1675f5d686d547269851a59d740972519eed66` → `888f5017f4a23e53a370bcbab2b6e59f391248400fe292015d2437d1e42c67a4`, and new `pathfollow3d_curve.gd` has SHA-256 `1a7259fbc3b84b2584f341cc8a75b2a5629736631551f4b9fa3de67e9e40629d`. Every other prior seed hash is identical; both new runs preserve seeds.

## Source and measured controls

The fixture constructs a live `Path3D` under scene root with authored `Curve3D` (`bake_interval=0.1`), points (0,0,0), bent middle (2,2,1) / straight middle (2,0,1), end (4,0,2), middle handles (-0.5,0,-0.25)/(0.5,0,0.25). It adds a `PathFollow3D` under that path with `ROTATION_NONE`, and a child `Node3D` marker local Z=1. After one `process_frame`, direct assignments set `follower.progress` to quarter and three-quarter of `curve.get_baked_length()` and measure **global follower and child-marker positions** before fixed output markers. Setup verifies the live parent chain, attached curve, marker local offset, rotation mode and point count. Length literals are bent 6.072724 and straight 4.472136 (tolerance 0.003). Bent follower positions ≈(0.917532,1.118620,0.458766), (3.082469,1.118619,1.541234); straight ≈(1,0,0.5), (3,0,1.5), each within 0.003. Marker measured global positions must equal respective follower expected position + (0,0,1), also within 0.003; `ROTATION_NONE` makes this Z-offset check straightforward. Length/first/second follower checks share one compound predicate, as do the two marker checks. The marker is not a navigation agent or a timed playback target.

Private copy `.shokunin/game-dev-3d/corpus/live/runs/r44-pathfollow-review-private/bent-middle-y3` changes **only** bent-middle source point Y2→3 in the `curve.add_point` line; setup and original literal expected positions/length remain unchanged. Mutated fixture SHA-256 `db96ee7d72f9cede21fb1e8a775f913961b00b5541a3df1743f2d12bb97a330e`. Exact command (exit **1**):

```sh
godot --headless --path .shokunin/game-dev-3d/corpus/live/runs/r44-pathfollow-review-private/bent-middle-y3 --script res://pathfollow3d_curve.gd > .shokunin/game-dev-3d/corpus/live/runs/r44-pathfollow-review-private/bent-middle-y3/mutation.stdout 2> .shokunin/game-dev-3d/corpus/live/runs/r44-pathfollow-review-private/bent-middle-y3/mutation.stderr
```

stdout SHA-256 `1fb0f12cefe41f881cb436e6731d981084b95f8db9b1d6f3e25ac930f360a32e` has only Godot banner/blank line; stderr SHA-256 `3c06f7c396deedeca82638a9f5db6fc8e73f59b784cb05fc132b6f3123a8474b` begins `ERROR: pathfollow3d_curve: follower positions mismatch length=7.580958 first=(0.881936, 1.618115, 0.440968) second=(3.118064, 1.618116, 1.559032)`. Setup did not reject it; the measured follower-position/length predicate did. This compound predicate does not independently isolate length from either follower position.

Separate private copy `.shokunin/game-dev-3d/corpus/live/runs/r44-pathfollow-review-private/marker-z2` changes marker local position Z1→2 and **only the setup marker.position literal** Z1→2, retaining expected measured child global offset Z1. Mutated fixture SHA-256 `35bbded04e9b667b9ea06997e5fd1956ba7b5d1075682f57210bcbf53dc4eada`. Exact command (exit **1**):

```sh
godot --headless --path .shokunin/game-dev-3d/corpus/live/runs/r44-pathfollow-review-private/marker-z2 --script res://pathfollow3d_curve.gd > .shokunin/game-dev-3d/corpus/live/runs/r44-pathfollow-review-private/marker-z2/mutation.stdout 2> .shokunin/game-dev-3d/corpus/live/runs/r44-pathfollow-review-private/marker-z2/mutation.stderr
```

stdout SHA-256 `1fb0f12cefe41f881cb436e6731d981084b95f8db9b1d6f3e25ac930f360a32e` likewise contains only Godot banner/blank line; stderr SHA-256 `dfbe61e8f53b4efb0b6fc994cb546ab4580f092338bd601ca822ef13197c4be3` begins `ERROR: pathfollow3d_curve: child marker follow mismatch first=(0.917532, 1.11862, 2.458766) second=(3.082469, 1.118619, 3.541234)`. Both private controls have no Parse Error, SCRIPT ERROR, ObjectDB leak warning or PASS marker. This second control reaches and rejects the measured child-marker global-position predicate, rather than a setup literal; it does not independently isolate first versus second marker checks.

Bounded verdict: **depth improved** beyond r43 direct baked-curve sampling for one live headless scene-tree follower and offset child at explicitly selected progress values, with intact straight-path control; coverage and calibration unchanged. Neither direct progress assignment nor a single-frame setup shows timed movement, navigation agents, collision, rendering, pixels, GPU behavior or portability across Godot versions.

> **Correction note (r106, 2026-10-18, SEAT-42).** Live-tree digest check. Quoted SHA-256 values above are the 2026-10-13 review record and are not rewritten; quoted `README.md` and `run_battery.py` digests match historical git blobs, not live `sha256sum` `corpus/fixtures/README.md` `347e0d1e5e4efca9c6f8b93440370352278bb30f3c1f62cee19edd3704619cb1` and `corpus/fixtures/run_battery.py` `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`. `pathfollow3d_curve.gd` digest `1a7259fbc3b8…` still matches the live fixture. Campaign HEAD `c8ca2f11e2f290df81da1c0922dca9dc4bc67fa8` is not an object in this repo and is left unrewritten. Absent `corpus/live/runs/` receipts and private mutant copies were not re-hashed.

<!-- r106-seat45-receipt-note -->

> **Non-resolvable receipt note (r106, 2026-10-18, SEAT-45).** Re-checked 2026-10-18: each path below is a concrete `corpus/live/runs` receipt cited in this lesson. The cited path is absent (`test -e` failed) and no durable copy exists under `reports/` (no receipt artifact whose path or `started_utc` is that run id; a prose mention is not a copy). Quoted receipt SHA-256 values on these lines do not match any tracked file or any `reports/` receipt artifact. `corpus/.gitignore` ignores `live/`, so these paths were never tracked. Historical sentences above are unchanged. Register: `reports/round-106/consistency/receipts.md`.
>
> - `corpus/live/runs/20261013T073855191130Z/verdicts.json`
> - `corpus/live/runs/20261013T073855191088Z/verdicts.json`
> - `corpus/live/runs/20261013T073219874871Z/verdicts.json`
> - `corpus/live/runs/r44-pathfollow-review-private/bent-middle-y3`
> - `corpus/live/runs/r44-pathfollow-review-private/bent-middle-y3/mutation.stdout`
> - `corpus/live/runs/r44-pathfollow-review-private/bent-middle-y3/mutation.stderr`
> - `corpus/live/runs/r44-pathfollow-review-private/marker-z2`
> - `corpus/live/runs/r44-pathfollow-review-private/marker-z2/mutation.stdout`
> - `corpus/live/runs/r44-pathfollow-review-private/marker-z2/mutation.stderr`
