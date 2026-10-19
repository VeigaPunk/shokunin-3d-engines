# Round 58 three.js perspective camera — independent non-author review (2026-10-13)

**Bounded PASS** at work commit `9796dc9a08656132f6f44a51dceabd9dde0947b7`. I did not author the fixture. I read the round 58 declaration in `LOG.md`, the lane-local `corpus/fixtures/three/README.md`, the existing and new Node runners and source, and `corpus/fixtures/README.md`. The worktree was clean before and after review. All commands below ran from repository root with the existing lane-local three.js 0.186.1 installation under Node v26.11.1.

## Reproduction and raw evidence

```sh
node corpus/fixtures/three/run_cases.mjs --receipt corpus/live/three-r58-review-old.json
node corpus/fixtures/three/run_camera_cases.mjs --receipt corpus/live/three-r58-review.json
node corpus/fixtures/three/camera_frustum.mjs --mutate-far
python3 corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
```

- Old Node runner: process exit **0**, 3/3 PASS, `seedsUnchanged=true`. Receipt `corpus/live/three-r58-review-old.json`, SHA-256 `c7df029b35086914303a879a6e148edde6cb5ed8fa7dfe7e7ecf40598b84f207`. Raw case tuples `(name, exit, stdout, stderr)` are positive `(0, "PASS three3d scene_graph world=-1.000,0.000,0.000 parent_intact=true reverse_rejected=true\n", empty)`, negative_wrong_order `(2, "NEGATIVE REJECTED: three3d wrong_order expected=-1,0,0 reversed=2.000,0.000,-3.000 parent_intact=true\n", empty)`, mutation `(1, empty, "ERROR: three3d world origin mismatch observed=-2.000,0.000,-0.000 expected=-1,0,0\n")`. Each has null signal/error and PASS verdict. The four SHA-256 seed hashes in the receipt match current seed files.
- New camera runner: process exit **0**, 3/3 PASS, `seedsUnchanged=true`. Receipt `corpus/live/three-r58-review.json`, SHA-256 `ddbd68d19df774a9ded6c03282451e295f9fa2a1dd02322c670d425d9d87da26`. Inside `(exit 0, stdout "PASS three3d camera inside_depth=4.000 inside_frustum=true outside_frustum=false screen=550.000,225.000\n", empty stderr)`; far_outside `(exit 2, stdout "NEGATIVE REJECTED: three3d camera_far outside_depth=12.000 outside_frustum=false inside_frustum=true shared_screen=550.000,225.000\n", empty stderr)`; mutate_far `(exit 1, empty stdout, stderr "ERROR: three3d far point entered frustum measured_outside=true far=20.000\n")`. Every case has null signal/error and PASS verdict; the four receipt seed hashes match current files. Both runners require exact exit/one-line stream and five-second child bound, and hash seeds before/after.
- **Direct source mutation flag**, outside the runner: `camera_frustum.mjs --mutate-far` exited **1**, stdout empty, stderr exactly `ERROR: three3d far point entered frustum measured_outside=true far=20.000\n`. The source changes only the authored camera far from 10 to 20, while the original point remains (6,3,-12). This branch checks the live `Frustum.containsPoint(outside)` result *before* testing far=10 or the NDC depth literals. Thus the failure is a measured outside-frustum contradiction, not a parser, marker or fixed-literal-only failure.
- Full Godot battery: process exit **0**, `83/83 PASS` (41 ordinary, 42 negative); four opt-in probes PASS (tree timeout, crash exit, stream attribution, scratch contact mutation). Receipt `corpus/live/runs/20261013T123903480026Z/verdicts.json`, SHA-256 `b8776444ffae18d9be1967081b495ab665ee5e3c4a7966ae9d6436078d6bfaf7`. `seeds_unchanged=true`; all **50** seed hashes equal the r57 independent receipt at `corpus/live/runs/20261013T123250681582Z/verdicts.json`. Comparing all 83 cases in order, `case`, `script`, `flags`, expected/actual exits, error, kind, marker, verdict, reasons, stdout, and stderr match the r57 raw fields exactly (zero differences). Process commands and elapsed times embed scratch run paths/timing and are not meaningful stable fields; no Godot seed or case changed.

## Independent math/source judgment

Camera at world origin looking toward -Z, vertical FOV 90°, aspect 4/3, near 1, far 10. At depth `d=-z`, the perspective NDC coordinates are `x/(d*4/3)` and `y/d`. For (2,1,-4) they are (0.375,0.25); for (6,3,-12) likewise (0.375,0.25). An 800×600 viewport maps these mathematically to `(550,225)` with downward-positive screen Y. With near=1 and far=10, NDC Z is `11/9 - 20/(9d)`: at d=4, `2/3`; at d=12, `28/27 > 1` (finite projection, but beyond far). The source constructs real `PerspectiveCamera`, updates its matrices, forms `Frustum` from projection × inverse world matrix, and projects both `Vector3` points. It checks lateral NDC and depths against these hand values and independently checks live frustum inclusion, with a live inside control on the negative arm. These NDC values are asserted in source, not emitted individually in the receipt. Camera is at identity and no renderer/GL context is created.

**Axes:** coverage improved for one bounded three.js perspective camera/frustum API surface under Node; depth unchanged; calibration unchanged (existing exact exit/stream and seed style plus measured mutation, not a generalized classifier). No rendered pixels, GPU culling, browser behavior, precision boundary or cross-engine result is established. No commits, pushes, merges or implementation edits in this review.

## r106 path-root conformance (2026-10-18)

Mechanical re-root only (SEAT-08). Every `.shokunin/game-dev-3d/` prefix above was removed so citations are repo-relative from this lane root. Historical totals, markers, SHA-256 digests, and the cited Node `v26.11.1` string were not rewritten. This note is not a re-run of the 2026-10-13 review.

Still non-resolvable (queued, not rewritten): cited `corpus/live/three-r58-review.json`, `corpus/live/three-r58-review-old.json`, and `corpus/live/runs/20261013T…` receipts are gitignored (`corpus/.gitignore` `live/`) and absent. Commit `9796dc9` resolves in `/home/vgpnk/Projects/prymeagnt/game-dev-3d`, not in this lane repo. Sweep evidence: `reports/round-106/sweep/chunk-08.md`.

<!-- r106-seat45-receipt-note -->

> **Non-resolvable receipt note (r106, 2026-10-18, SEAT-45).** Re-checked 2026-10-18: each path below is a concrete `corpus/live/runs` receipt cited in this lesson. The cited path is absent (`test -e` failed) and no durable copy exists under `reports/` (no receipt artifact whose path or `started_utc` is that run id; a prose mention is not a copy). Quoted receipt SHA-256 values on these lines do not match any tracked file or any `reports/` receipt artifact. `corpus/.gitignore` ignores `live/`, so these paths were never tracked. Historical sentences above are unchanged. Register: `reports/round-106/consistency/receipts.md`.
>
> - `corpus/live/runs/20261013T123903480026Z/verdicts.json`
> - `corpus/live/runs/20261013T123250681582Z/verdicts.json`
