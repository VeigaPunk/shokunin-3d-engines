# r66 independent Raycaster range review — 2026-10-13

Reviewed work commit `5126ed6ffbd64f98e9c4f78681ff46edec1f962a` as a named non-author LEAF. Read `LOG.md`, `corpus/README.md`, `corpus/fixtures/README.md` and `corpus/fixtures/three/README.md`. No source, LOG, report or SCORECARD edits.

## Reproduction

From repository root, all five Node runners exit 0 with exact individual exit/stream signatures and unchanged seeds:

| command (`node corpus/fixtures/three/… --receipt corpus/live/r66-review-….mjs.json`) | result |
|---|---|
| `run_order_cases.mjs` | 6/6 |
| `run_cases.mjs` | 3/3 |
| `run_camera_cases.mjs` | 5/5 |
| `run_ortho_cases.mjs` | 5/5 |
| `run_ray_cases.mjs` | 5/5 |

Direct `node corpus/fixtures/three/raycast_order.mjs --mutate-near-clip` exits **1**, stdout empty, stderr exactly `ERROR: three3d ray range measured contradiction hits=2 first=near near=2.000 far=10.000\n`. This arises in the observed hit-count/object/point/distance check before any literal setting assertion; no parser or marker failure. The registered `mutate_near_clip` row has the identical diagnostic and exit.

The two new range rows each exit 2, empty stderr and one exact newline-terminated stdout line: `NEGATIVE REJECTED: three3d ray_range near_clip hits=1 remaining=far distance=5.000` and `NEGATIVE REJECTED: three3d ray_range far_clip hits=1 remaining=near distance=3.000`. Runner tests no signal, 5-second child timeout, exact stdout/stderr and unchanged four seed digests. `node=v26.11.1`, pinned `three=0.186.1`. New `raycast_order.mjs` SHA-256 `14c75e00d0d4328428f0cb2f5c62258d5c448568246c0338ac635cd431607496`; `run_order_cases.mjs` SHA-256 `69bcb33c87f5e96ac4fd04106784133bca39f8adc619cc748567db275d081d8d`; package and lock digests match r65.

Geometry hand check: each mesh uses triangle local vertices (-1,-1,0), (1,-1,0), (0,1,0), identical geometry and material, distinct Mesh objects; both translate x=2 and stay at z=-3/-5 in clipping arms. Ray (2,0,0) along (0,0,-1) crosses each triangle at interior local (0,0,0), world points (2,0,-3)/(2,0,-5), distances 3/5. `intersectObjects([farMesh, nearMesh], false)` under default near=0,far=10 yields both ordered near then far despite reverse input order. Near=4,far=10 excludes distance3 and retains far at 5. Near=0,far=4 retains near at 3 and excludes distance5. The clipping branch asserts one hit, precise expected **object identity**, measured distance and point, after both meshes' identity/geometry checks; the unmodified `ordered` arm verifies two live hits in the same battery. Near mutation near=2,far=10 retains both and fails measured hit-count/first-identity. This samples only distances3/5, not exact boundary precision. Both clipped cases share meshes without moving geometry. Caveat: clipping branches do not independently recast at default limits within each process; the adjacent unchanged ordered arm is their live default control.

Against `corpus/live/r65-review-run_order_cases.mjs.json`, the full raw result objects for `ordered`, `near_off_axis`, and `swap_depths` match exactly (including commands, exits, streams and marker bytes). Four legacy r65 Node reviewer receipts `r65-review-run_{cases,camera_cases,ortho_cases,ray_cases}.mjs.json` match their r66 counterparts in complete raw rows and full seed SHA-256 maps. The two changed order source/runner hashes are expected for the added arms; package digests stay the same.

Ran `python3 corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing`, exit 0: 83/83 registered Godot cases (41 ordinary, 42 negative), all four probes accepted, seeds unchanged. Receipt `corpus/live/runs/20261013T132554274450Z/verdicts.json`, with its `mutation-verdicts.json`, `tree-timeout-verdicts.json`, `crash-exit-verdicts.json`, and `stream-attribution-verdicts.json`. Compared with r65 reviewer `corpus/live/runs/20261013T132010352702Z/verdicts.json`: all 83 result rows have identical `case`, `script`, `flags`, `expected_exit`, `actual_exit`, `error`, `kind`, `marker`, `verdict`, `reasons`, full `stdout` and `stderr` fields, and all 50 seed hash entries match. Variable timestamps, scratch paths, per-case elapsed times and probe receipt locations differ; not claimed byte-identical full JSON.

## Assessment and bounds

Independent finite replay supports the declared **depth** improvement: CPU-side three.js Raycaster near/far gates now select which of two intact mesh intersections survive, with an extra-hit mutation caught by measured behavior. Existing Node/Godot coverage and exact-signature calibration show no observed harm. This is not a verdict on rendered occlusion, browser/GL/GPU behavior, general meshes, other engines, or exact distance boundaries.
> **Correction note (r106, 2026-10-18) — path root only.** The command template, the direct `raycast_order.mjs` invocation, the battery command, and the r65 receipt path above were re-rooted from `.shokunin/game-dev-3d/` to repo-relative paths. The prefix has never existed in this repo (`ls -d .shokunin` → exit 2). Mechanical conformance fix, not a factual rewrite: the 6/6 order count and the 83/83 Godot count are left as the r66 record. From this root on 2026-10-18 the current `run_order_cases.mjs` exits 0 at **9/9** (r67 added boundary arms; 6/6 is the r66 record). `run_cases.mjs` 3/3, `run_camera_cases.mjs` 5/5, `run_ortho_cases.mjs` 5/5, `run_ray_cases.mjs` 5/5, all exit 0. `node corpus/fixtures/three/raycast_order.mjs --mutate-near-clip` exits 1, stdout empty, stderr `ERROR: three3d ray range measured contradiction hits=2 first=near near=2.000 far=10.000`. `node` is v26.12.0 (the review recorded v26.11.1). The full probe battery was not re-run. Cited `corpus/live/` receipts are gitignored and absent. Evidence: `reports/round-106/sweep/chunk-10.md`.

> **Correction note (r106 SEAT-10, 2026-10-18) — commits, digests, counts.** The path-root note's evidence pointer named `reports/round-106/sweep/chunk-05.md`, which was absent and is not this chunk's report; resolving evidence is `reports/round-106/sweep/chunk-10.md`. `5126ed6ffbd64f98e9c4f78681ff46edec1f962a` is absent from this clone (`git cat-file -t` → fatal) and is a commit in `/home/vgpnk/Projects/prymeagnt/game-dev-3d` (`cat-file -t` → `commit`). The hash is not rewritten to this clone's subject-matched `0c551dd9`. `git -C` parent `show 5126ed6ffbd6:.shokunin/game-dev-3d/corpus/fixtures/three/{raycast_order,run_order_cases}.mjs | sha256sum` → `14c75e00…` and `69bcb33c…`, matching the r66 hashes above and not the live files (live `d9880087…` / `7beab553…`). Named `corpus/live/` receipts are absent; their SHA-256s are not re-verifiable. `godot --version` → `4.7.2.stable.arch_linux.ed1daf0bf`. `CASES` is 83 at `ca9ca39` and 350 at HEAD. This seat did not re-run the battery. Pinned-env receipt `reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json` totals `cases=350 pass=350 fail=0`.

<!-- r106-seat45-receipt-note -->

> **Non-resolvable receipt note (r106, 2026-10-18, SEAT-45).** Re-checked 2026-10-18: each path below is a concrete `corpus/live/runs` receipt cited in this lesson. The cited path is absent (`test -e` failed) and no durable copy exists under `reports/` (no receipt artifact whose path or `started_utc` is that run id; a prose mention is not a copy). Quoted receipt SHA-256 values on these lines do not match any tracked file or any `reports/` receipt artifact. `corpus/.gitignore` ignores `live/`, so these paths were never tracked. Historical sentences above are unchanged. Register: `reports/round-106/consistency/receipts.md`.
>
> - `corpus/live/runs/20261013T132554274450Z/verdicts.json`
> - `corpus/live/runs/20261013T132010352702Z/verdicts.json`
