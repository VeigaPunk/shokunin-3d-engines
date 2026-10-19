# Round 43 independent Curve3D geometry review

Reviewer: named LEAF non-author `game-dev-3d-r43-curve-review`. LOG r43 baseline `50e44905a778d854a774aa7ece4f589b758558da`; Godot `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`, Linux headless. Sole tracked write is this review; no implementation, seed, runner, README or LOG edits; no push/merge. Scratch work is ignored under `corpus/live/runs/`.

## Exact replay

From repository root, both commands exit 0:

```sh
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only curve3d_path,curve3d_path_straight
```

Full `corpus/live/runs/20261013T073219874871Z/verdicts.json` SHA-256 `af9bcdd8f321d779ef2fb07b2fefe93cf865067934031f0715633c7f28a5bcd7`: **63/63 PASS** (30 ordinary, 33 negative controls), plus four opt-ins PASS: tree timeout SHA-256 `d57806a344d58cc575ba060ba7a6e15064efae31279f6e68cef839ce57d1a151`, crash exit `bf2fd218d5b7b1b964d0542ef7508f227b08d6b4c3b989ff2d9a09388d035c94`, stream attribution `c6cbaf320c65dad9607bc160f16f38d5db76878082b52efba2f8946de18d9e50`, and existing *body-contact* failing mutation `b038948fa19e9ef393bb07b171156c4ae9cd749f5d447a8de9226983d03d1c23`. That opt-in mutation is **not** the curve-specific control below. Seed hashes preserved before/after.

Pair `corpus/live/runs/20261013T073219875949Z/verdicts.json` SHA-256 `46c4106a2f97a3fd5cbbae7cbe8eb9506656b6fa76c65de6c64e69893c482ff2`: **2/2 PASS**, ordinary exit 0 / straight negative exit 2, both empty stderr and reasons, same seed map as full. The ordinary stdout marker is `PASS curve3d_path bent length=6.072724 quarter_y=1.118591 midpoint_y=2.000000`; straight marker `NEGATIVE REJECTED: curve3d_path straight length=4.472136 midpoint=2.000,0.000,1.000`. Exact raw streams/commands appear in the JSON receipts.

Prior r42 full `corpus/live/runs/20261013T072547453626Z/verdicts.json` SHA-256 `18daffa9224d5b21f972492e6dc73850a51a87146a43b6c50fa8c4ef0ad329ee`: 61/61 PASS. All prior **61** complete raw case records match r43 on `case, script, flags, expected_exit, actual_exit, error, kind, marker, verdict, reasons, stdout, stderr` (zero discrepancies); scratch command paths and elapsed times necessarily vary. Prior hashes differ only: `README.md` `0c20d630610670e87ece957c7a2ad87505a2a63c47dfa200bc3db6bd9e0adde8` → `d7e5ae97ae9842450406ee3b3deacb3ef677b9965115e7346a7e011776a8d9d4`, `run_battery.py` `bcb00e59a7b0cda53961cc6b3fb56ea9459e6aed7391b492f8cf544cecfba403` → `dc452c49648d640e6bcb09037b1675f5d686d547269851a59d740972519eed66`, and new `curve3d_path.gd` `7e9a71a07a9c76bd063b7d2da74369744230de43adc638fdbd3ba686b3128b7e`. Every other previous seed hash is identical; both r43 runs preserve their seed maps.

## Live geometry and mutation

Seed `corpus/fixtures/curve3d_path.gd` SHA-256 `7e9a71a07a9c76bd063b7d2da74369744230de43adc638fdbd3ba686b3128b7e` constructs `Curve3D` with `bake_interval=0.1`, points (0,0,0), (2,2,1) bent / (2,0,1) straight, (4,0,2), explicit middle in/out relative handles (-0.5,0,-0.25)/(0.5,0,0.25), and assigns the curve to a live `Path3D`. It awaits one process frame, reads baked length and samples at quarter/middle/three-quarter length before the fixed markers. Setup asserts live path/curve identity, point count, endpoint positions, and the middle **out** handle. It does not directly assert the middle in handle or middle point position as setup readbacks; the source defines them, and the geometric samples constrain the middle point. Bent literal tolerances: length 6.072724 ±0.003; quarter (0.917559,1.118591,0.45878) ±0.003; midpoint (2,2,1) ±0.001; three-quarter (3.082441,1.11859,1.541221) ±0.003. Straight literals: length 4.472136 ±0.001; quarter (1,0,0.5), midpoint (2,0,1), three-quarter (3,0,1.5), each within 0.001. Bent length exceeds straight and quarter/midpoint Y differs. Length/sample predicates are compound, not separately isolated by distinct mutations.

Private fixture copy `corpus/live/runs/r43-curve-review-private/` changes **only** the bent middle Y in copied `curve3d_path.gd`: `curve.add_point(Vector3(2, 0 if straight else 2, 1),...)` → `curve.add_point(Vector3(2, 0 if straight else 3, 1),...)`. Endpoints, handles, setup guards and original sample/length expectations remain unchanged. Mutated script SHA-256 `a332c0b833ed0a83690f4e7722662984e803a635c77a2767540e5c815d77fa52`. Exact command (exit **1**):

```sh
godot --headless --path .shokunin/game-dev-3d/corpus/live/runs/r43-curve-review-private --script res://curve3d_path.gd > .shokunin/game-dev-3d/corpus/live/runs/r43-curve-review-private/mutation.stdout 2> .shokunin/game-dev-3d/corpus/live/runs/r43-curve-review-private/mutation.stderr
```

Private stdout SHA-256 `1fb0f12cefe41f881cb436e6731d981084b95f8db9b1d6f3e25ac930f360a32e` contains only banner/blank line, no PASS or negative marker; stderr SHA-256 `0a359016a8282061c9d6abafe3a2ef8d961086f0a56b4d426b8f02823af5c2a1` begins `ERROR: curve3d_path: bent baked path mismatch length=7.580958 q=(0.881965, 1.61809, 0.440983) mid=(2.0, 3.0, 1.0) tq=(3.118034, 1.618091, 1.559017)`. No parse error, SCRIPT ERROR, or ObjectDB leak. The unchanged setup passes; the bent baked geometry predicate, not a source-literal or setup guard, rejects the mutant. Because length/quarter/middle/three-quarter are one compound predicate, this proves a measured geometry mismatch but does not isolate each subpredicate independently.

Bounded conclusion: **coverage improved** for one live headless Godot authored/baked 3D curve against an intact straight control, beyond the prior navigation path query; depth and calibration unchanged. This does not prove a navigation agent traverses the curve, collision, a rendered line, pixels, GPU behavior or portability across Godot versions.

> **Correction note (r106, 2026-10-18, SEAT-42).** Live-tree digest check. Quoted SHA-256 values above are the 2026-10-13 review record and are not rewritten; quoted `README.md` and `run_battery.py` digests match historical git blobs, not live `sha256sum` `corpus/fixtures/README.md` `347e0d1e5e4efca9c6f8b93440370352278bb30f3c1f62cee19edd3704619cb1` and `corpus/fixtures/run_battery.py` `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`. `curve3d_path.gd` digest `7e9a71a07a9c…` still matches the live fixture. Campaign HEAD `50e44905a778d854a774aa7ece4f589b758558da` is not an object in this repo and is left unrewritten. Absent `corpus/live/runs/` receipts and private mutant copies were not re-hashed.

<!-- r106-seat45-receipt-note -->

> **Non-resolvable receipt note (r106, 2026-10-18, SEAT-45).** Re-checked 2026-10-18: each path below is a concrete `corpus/live/runs` receipt cited in this lesson. The cited path is absent (`test -e` failed) and no durable copy exists under `reports/` (no receipt artifact whose path or `started_utc` is that run id; a prose mention is not a copy). Quoted receipt SHA-256 values on these lines do not match any tracked file or any `reports/` receipt artifact. `corpus/.gitignore` ignores `live/`, so these paths were never tracked. Historical sentences above are unchanged. Register: `reports/round-106/consistency/receipts.md`.
>
> - `corpus/live/runs/20261013T073219874871Z/verdicts.json`
> - `corpus/live/runs/20261013T073219875949Z/verdicts.json`
> - `corpus/live/runs/20261013T072547453626Z/verdicts.json`
> - `corpus/live/runs/r43-curve-review-private/`
> - `corpus/live/runs/r43-curve-review-private`
> - `corpus/live/runs/r43-curve-review-private/mutation.stdout`
> - `corpus/live/runs/r43-curve-review-private/mutation.stderr`
