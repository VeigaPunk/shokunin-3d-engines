# Round 49 independent NavigationAgent3D query review

Reviewer: named LEAF non-author `game-dev-3d-r49-navagent-review`. Read `LOG.md` r49 (including adverse path-read ordering), fixture README/source, and r13 direct NavigationServer3D fixture/review. Godot `/usr/bin/godot` version `4.7.2.stable.arch_linux.ed1daf0bf`. Sole tracked write: this lesson; private copies and run receipts are ignored. No implementation edits, push, or merge.

## Independent replay

Run from repository root; both commands exited **0**:

```sh
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only navagent3d_next,navagent3d_next_alternate
```

Full `corpus/live/runs/20261013T081147076161Z/verdicts.json` SHA-256 `443b353c12e75ea19dd5701c978f6a8e875c6a11c9e2374e2ded1aff689e2bb4`: **73/73 PASS**, 35 ordinary/38 negative, and all four probes PASS; `seeds_unchanged=true`. Tree/crash/stream/failing receipts SHA-256, respectively: `93ede035e34d0be0edb15c352a3103f2723d513092f1374d4e2290a2903ce3c6`, `1cb1bca09392f274c720b749447fffd600f4e8a8eb4d37dcb27d4753bc7a536e`, `2de802d5a7933ca048985d8f50dcc2f4846ce6547b1c10ce94b968b71d197ab6`, `7faa6e07c20278ed5b92695d0f7b7cf03bf9936247dc52aee47717ce45c31bfb`. The registered failing probe changes body-contact geometry, not this navigation fixture.

Pair `corpus/live/runs/20261013T081147076446Z/verdicts.json` SHA-256 `1e6a65e7e39db80744061c67b9d0cee0b343f5b2db9660ec98434ab69c3939bb`: **2/2 PASS**, normal exit0 with exact `PASS navagent3d_next path_end=3.000,0.000,3.000 next=3.000,0.000,3.000`; alternate exit2 with exact `NEGATIVE REJECTED: navagent3d_next alternate path_end=3.000,0.000,1.000 next=3.000,0.000,1.000`. Both have empty stderr/reasons. Full/pair seed maps agree, before/after seed maps unchanged. Previous r48 full `corpus/live/runs/20261013T080440209599Z/verdicts.json` SHA-256 `bbb6814ca956a7e004e32fa21890a9346f4be3fb3a27718045d5b4f114918460`: **all 71 complete raw records identical** in `case, script, flags, expected_exit, actual_exit, error, kind, marker, verdict, reasons, stdout, stderr`; only elapsed/command scratch location excluded. Seed changes only README `a5853c52d348a04e897a7a65299d85f5bad6079f84c23a21ae26c9c1b2fb923d` → `c7d186bbb33d9d3ad47d7f0e41fbbc7a1fe15c0391775864d9ff52d1e74f3589`, runner `72a22d7e12895d7ec69c06339969cc102ba4279f8bcd56a7192a40b3f8273113` → `2cebcaa4e4dee61a131fa02f3b8039d9d79e9ad70c15c4148c71e7a68af76d26`, and newly added `navagent3d_next.gd` SHA-256 `f0ea0fbb0c8400b7b6fd4b5e5139ae02d0487a1ddedfe483e1fd3c3f6ac5e94f`. Other seed hashes unchanged.

## Source and private mutant

`navagent3d_next.gd` creates an active `NavigationServer3D` map and one attached region with a hand-authored planar four-vertex, one-polygon mesh. A live `Node3D` actor at `(1,0,1)` owns a live `NavigationAgent3D`, explicitly assigned that map and a target. After **30 physics frames** for sync, it calls `agent.get_next_path_position()` **before** reading `agent.get_current_navigation_path()`: author's reverse-order feasibility read returned an empty path despite next returning the target, so this proves only the initialized query in this ordering. The fixture asserts live actor/parent/map/region/polygon and actor unmoved at `(1,0,1)`, then measured two-point path start `(1,0,1)`, expected end and next `(3,0,3)` versus same-map alternate `(3,0,1)`. It does not explicitly guard the source target value; target influences the measured path and next. `path[1]` and `next` are one compound `or` predicate, not independently mutation-isolated. r13 `navigation3d_path.gd` instead queries `NavigationServer3D.map_get_path` directly on the server; that earlier server path does not establish this agent behavior.

Private copy **only** normal expression `Vector3(3, 0, 1 if alternate else 3)` → `Vector3(3, 0, 1 if alternate else 2)` in `corpus/live/runs/r49-navagent-review-private/navagent3d_next.gd`, SHA-256 `f0b698d818a85d5dc8d575cdc73e72d014d56bb5f42a68a45926cff591fce7d7`. Reproduce from repo root:

```sh
/usr/bin/godot --headless --path /home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/r49-navagent-review-private --script res://navagent3d_next.gd
```

Ordinary-arm **exit 1** after setup, no PASS and stdout only the Godot banner (SHA-256 `1fb0f12cefe41f881cb436e6731d981084b95f8db9b1d6f3e25ac930f360a32e`). Stderr SHA-256 `5dc25f99c4ecbc060598662a4c0cee426ef18e6cb3d27dd54b729ee7a59a9c26`: `ERROR: navagent3d_next: agent next position mismatch path=[(1.0, 0.0, 1.0), (3.0, 0.0, 2.0)] next=(3.0, 0.0, 2.0)` at `_run` line38. No parse/SCRIPT ERROR or ObjectDB leak warning. The measured agent route/next changed while setup and path-start guards passed, not a target-source guard. Both route endpoint and next differed but compound predicate does not isolate their individual sensitivity; an existing server map/path alone could not supply the observed agent readback.

**Bounded judgment:** coverage improved for one live headless NavigationAgent3D next-path query over r13's direct server path; depth and calibration unchanged. No autonomous actor movement, avoidance, NavigationMesh baking, pixels, GPU, or general eager current-path availability. Assumptions/constants: pinned Godot build, 30 sync frames, fixed `(1,0,1)` actor and authored 4×4 polygon; only private copy changes normal target Z from 3 to 2, never the seed.
