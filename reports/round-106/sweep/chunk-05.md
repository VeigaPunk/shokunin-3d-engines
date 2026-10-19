# SEAT-05 SWEEP-CHUNK — corpus/lessons chunk E

**Axes:** coverage (path/command resolution), calibration (historical counts and digests not silently rewritten). Depth census is not this seat.
**Seat:** SEAT-05. **Write scope:** the eight lesson files below, plus this report. No other file was edited by this seat.
**Repo:** `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`, HEAD `0cc3f41` (r105 report-last; work `3634bc0`). Date of the notes: 2026-10-18.
**No Unreal runtime claim.** This chunk cites no Unreal editor, MCP, or Live Coding command. Nothing here is evidence of Unreal behavior.

## Chunk

Alphabetical `Path.rglob` of `corpus/lessons` (96 files), chunks of 8, remainder to SEAT-12. Chunk E is indices 32–39:

| file | post-edit SHA-256 |
|---|---|
| `corpus/lessons/r61-stream-review.md` | `2b6f5d524a12921a0bd799187e060f16fddec004750fb2e2e17b06dff6ea3e62` |
| `corpus/lessons/r62-three-ortho-near-review.md` | `86d3ae7753eb2a917aefa1b13544a86216d899f07667c9407138ea30e5d09a67` |
| `corpus/lessons/r63-three-ray-review.md` | `18600d513dcce3f9da53ccb0c81a9bde3664c3c09e8ab0552191697e0b1f9218` |
| `corpus/lessons/r64-ray-side-review.md` | `e448fb2f0373b250f2d809ccea1ebb5fdd3f141b917ee5d9cd76564b1c5becdd` |
| `corpus/lessons/r65-ray-order-review.md` | `3d7e5d812b2b9c024f2ab30523c4616673b728f16fbf91654eaf3719a7857deb` |
| `corpus/lessons/r66-ray-range-review.md` | `6558fdbe7c0b49c2c40f37433b8d5455c2087d59c11d48bb622053b37d6db602` |
| `corpus/lessons/r67-ray-boundary-review.md` | `6fa3247c3c82a53f15b0a2d621ce01446ad677880424c785162d2314bc17f8c2` |
| `corpus/lessons/r68-ray-layers-review.md` | `b40538b5d5014cae2cedb7fc3373990376653f4dc951e8e3bf663926db8cfcfb` |

`git diff --stat` on these eight: `8 files changed, 42 insertions(+), 34 deletions(-)`.

## What was fixed

Every runnable `node` / `python3` citation rooted at `.shokunin/game-dev-3d/` was rewritten to a repo-relative path. Two absolute `/home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/…` receipt paths in r62 were rewritten the same way. The prose `LOG.md` citation in r61 was likewise de-prefixed. Each file gained one dated correction note. Historical sentences (83/83, 3/3, 6/6, SHA-256s, Node v26.11.1) were not rewritten.

Prefix-token count `.shokunin/game-dev-3d/` before the edit: r61 5, r62 10 (of which 2 sat inside the absolute prymeagnt form), r63 10, r64 10, r65 5, r66 6, r67 6, r68 6 — **58**. After the edit, the lesson bodies contain **1** remaining token, and it is the retained git-object path in r61 (below). The eight correction notes quote the old prefix on purpose.

### Before (dead filesystem root)

```
$ ls -d .shokunin
ls: cannot access '.shokunin': No such file or directory
exit=2
$ git log --all --oneline -- .shokunin
(no output)
$ python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
python3: can't open file '…/game-dev-3d-shokunin/.shokunin/game-dev-3d/corpus/fixtures/run_battery.py': [Errno 2] No such file or directory
exit=2
$ node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs
Error: Cannot find module '…/.shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs'
exit=1
```

The same `Cannot find module` / exit 1 was observed for `run_order_cases.mjs`, `raycast_triangle.mjs --mutate-offset`, `orthographic_frustum.mjs --mutate-near`, `raycast_layers.mjs --mutate-far-layer`, and `raycast_order.mjs --mutate-near-clip`.

### After (repo-relative, this root, 2026-10-18)

`node` is v26.12.0 (`/home/vgpnk/.local/share/mise/installs/node/latest/bin/node`). Pinned `three` is still `0.186.1`. Godot `--headless --version` is `4.7.2.stable.arch_linux.ed1daf0bf`.

| command now in the lessons | rc | observed tail |
|---|---:|---|
| `node corpus/fixtures/three/run_cases.mjs` | 0 | `PASS three battery: 3/3, seeds_unchanged=true` |
| `node corpus/fixtures/three/run_camera_cases.mjs` | 0 | `PASS three camera battery: 5/5, seeds_unchanged=true` |
| `node corpus/fixtures/three/run_ortho_cases.mjs` | 0 | `PASS three ortho battery: 5/5, seeds_unchanged=true` |
| `node corpus/fixtures/three/run_ray_cases.mjs` | 0 | `PASS three ray battery: 5/5, seeds_unchanged=true` |
| `node corpus/fixtures/three/run_order_cases.mjs` | 0 | `PASS three order battery: 9/9, seeds_unchanged=true` |
| `node corpus/fixtures/three/run_layer_cases.mjs` | 0 | `PASS three layer battery: 4/4, seeds_unchanged=true` |
| `node corpus/fixtures/three/raycast_triangle.mjs --mutate-offset` | 1 | stderr `ERROR: three3d ray interior hit mismatch observed_hits=0 expected_point=2.000,0.000,-5.000` |
| `node corpus/fixtures/three/raycast_triangle.mjs --backface --double-side` | 1 | stderr `ERROR: three3d ray backface unexpectedly hit measured_reverse_hits=1 side=2` |
| `node corpus/fixtures/three/raycast_order.mjs --swap-depths` | 1 | stderr `ERROR: three3d ray order measured contradiction hits=2 first=far distances=3.000,5.000` |
| `node corpus/fixtures/three/raycast_order.mjs --mutate-near-clip` | 1 | stderr `ERROR: three3d ray range measured contradiction hits=2 first=near near=2.000 far=10.000` |
| `node corpus/fixtures/three/raycast_order.mjs --mutate-near-boundary` | 1 | stderr `ERROR: three3d ray boundary measured contradiction hits=0 first=none near=5.250 far=10.000 baseline_hits=2` |
| `node corpus/fixtures/three/raycast_layers.mjs --mutate-far-layer` | 1 | stderr `ERROR: three3d ray layers measured contradiction hits=0 first=none ray_mask=2 far_mask=1` |
| `node corpus/fixtures/three/orthographic_frustum.mjs --mutate-near` | 1 | stderr `ERROR: three3d ortho near point entered frustum measured_near=true near=0.100` |
| `python3 corpus/fixtures/run_battery.py --only camera3d_depth` | 0 | `PASS battery` `cases=1 pass=1 fail=0` |

The lessons' full probe battery (`--probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing`, no `--only`) was **not** re-executed. The script path now resolves; the dead-prefix form of that same command exits 2. A full 350-case probe run is a new experiment, not a path fix, and would contend with census seats. The historical `83/83` sentences were left in place.

Tracked targets cited as plain paths (`LOG.md`, `corpus/README.md`, `corpus/fixtures/README.md`, `corpus/fixtures/three/README.md`, the `.mjs` runners above, `run_battery.py`) exist from this root. Placeholder forms (`<runner>`, `…`, `{stdout,stderr}`) were not expanded.

## Retained on purpose — git object path

`corpus/lessons/r61-stream-review.md` still contains `git show 6b1af7e:.shokunin/game-dev-3d/corpus/fixtures/three/<runner>`. Rewriting that to a repo-relative object path **fails in the only repo that has the commit**:

```
$ git -C /home/vgpnk/Projects/prymeagnt/game-dev-3d show 6b1af7e:.shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs
exit=0
$ git -C /home/vgpnk/Projects/prymeagnt/game-dev-3d show 6b1af7e:corpus/fixtures/three/run_cases.mjs
fatal: path 'corpus/fixtures/three/run_cases.mjs' does not exist in '6b1af7e'
exit=128
$ git cat-file -t 6b1af7e
fatal: Not a valid object name 6b1af7e
```

Parent commit is `6b1af7eaf6cc5ce03092c798bb427e9c7f899958`. This is a parent-tree path, not a filesystem path of this clone. Left unchanged. Still does not run here, because the commit is absent. Queued, not "fixed".

## Queued — not fixed here

Judgment / historical defects. Dated path notes already say the counts and digests are the round's record. Digest notes for chunks D–F belong to SEAT-42; receipt-absence notes belong to SEAT-45. This seat's path notes already record that the cited `corpus/live/` files are gitignored and absent, so a second note would be redundant unless those seats want a dedicated one.

1. **Live receipts absent, no durable byte copy.** `corpus/.gitignore:1` is `live/`. Every concrete `corpus/live/…` path cited in the eight bodies was missing when checked (`test -e`). Ten `20261013T*` verdict stamps have **0** hits under `reports/` except `20261013T133935795023Z`, which is named in prose in `reports/round-69/r69-author.md`, `reports/round-69/r69-verifier.md`, and `reports/round-70/r70-reviewer.md` — not a copied `verdicts.json`. Do not invent receipts. Do not treat a fresh battery run as those historical bytes.
2. **83/83 is the r61–r68 record.** `run_battery.py` now defines 350 cases (r105: default-env 337/350, pinned-env 350/350). Not rewritten.
3. **Runner totals moved after the review.** Current `run_ortho_cases.mjs` is 5/5 (r61 recorded an inside-arm 3/3). Current `run_ray_cases.mjs` is 5/5 (r63 recorded 3/3). Current `run_order_cases.mjs` is 9/9 (r65 recorded 3/3; r66 recorded 6/6). Notes state the current totals; the historical sentences stay.
4. **Node v26.11.1 vs host v26.12.0.** Three pin `0.186.1` still matches `corpus/fixtures/three/package.json` and the lock. Not a path defect.
5. **Work commits are not in this repo.** `git cat-file -t` is `ABSENT` for `6c2e02597a08890cfa41ac9fa482e9c1d60367c0`, `e0bc0327d1e3edbabfaeb11b653b3f6c7dd80ceb`, `cfbcda21df707a75b024a81c5063700c06b39f0e`, `75fd218ef0ff9882dd1dbf14e949ec1f8ba5fd1e`, `7826053bb3e71d08a69dba09e09c5c5e52d9ff41`, `5126ed6ffbd64f98e9c4f78681ff46edec1f962a`, `f588601144e14ba977e24eaaf428f2b1b404090d`, `469e576da146fd042e9345a38005ec55f1da55d4`, `f3e5644d5ec15637e0fd6a9c91174c828818a2bf`, and `6b1af7e`. `6c2e025` and `6b1af7e` do resolve in the parent repo.
6. **SHA-256 quotes vs the current tracked tree.** Scanner: sha256 of git-tracked files under `corpus/fixtures/three/`, `corpus/fixtures/run_battery.py`, and `corpus/lessons/`. **30 MATCH** (including `package.json` `799216c1…`, lock `1a8e6ee2…`, `run_cases.mjs` `97eca1b2…`, `run_camera_cases.mjs` `b6aee605…`, `scene_graph.mjs` `e4bb0a13…`, `camera_frustum.mjs` `52016445…`, ortho source `d7766dad…`, ortho runner `562e2b48…`, `raycast_triangle.mjs` `c78d768a…`, `run_ray_cases.mjs` `f1341e07…`, `raycast_order.mjs` `d9880087…`, `run_order_cases.mjs` `7beab553…`, `raycast_layers.mjs` `a307774e…`, `run_layer_cases.mjs` `ec16e193…`). **16 NOMATCH**, left as historical text: r61 runner/receipt digests `f9f40d47`, `c7bf14bd`, `2f07585d`, `80b7ef77`, `ac0c4c2c`, `fb622cb6`, `d36154df`, `a8b419e3`; r63 `acda1c39`, `ed2e2992`; r65 `97b2d10a`, `0e04980b`, `46bacc48`, `0f625bc0`; r66 `14c75e00`, `69bcb33c`. A sha256 file digest is not a git object id; this seat did not claim those bytes are absent from parent history.
7. **`/tmp/game-dev-3d-r61-review-7v7o99f5` is gone** (`ls` → no such file). Historical scratch. Not rewritten. `/tmp` quota on this host is exhausted; do not recreate it there.

## Not done

Full probe-battery rc for the eight historical invocations. Placeholder command templates were not expanded into invented paths. No digest sentences were silently updated. No commit/push/checkout/reset.
