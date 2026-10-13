# Round 52 independent NavigationAgent3D final actor endpoint calibration review

Reviewer: named LEAF non-author `game-dev-3d-r52-final-review`. Read `LOG.md` r52, fixture `README.md`, `navagent3d_retarget.gd`, `navretarget3d_driver.gd`, and `r51-retarget-review.md`. Pinned `/usr/bin/godot` 4.7.2.stable.arch_linux.ed1daf0bf. Sole tracked write is this lesson; private copies/receipts under ignored `corpus/live/runs/`. No implementation edits, push, or merge.

## Independent replay

Both commands from repository root exited **0**:

```sh
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only navagent3d_retarget,navagent3d_retarget_fixed
```

Full `/home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/20261013T083258787449Z/verdicts.json` SHA-256 `1a671d909b50743710271ba2f86031147fce4de45715e086e0b48f87f1450b42`: **77/77 PASS**, 37 ordinary/40 negative, all four opt-ins PASS, `seeds_unchanged=true`. Tree-timeout, crash-exit, stream-attribution, failing-mutation receipts SHA-256 respectively `c3c2aed000400a6f8623a86555a8cf7f64ebfc86bb6acb43a8e6c8e14bc4fb7a`, `579586bf99fd4b03a3eb8c421388eda20e5fd899d6fd9170677e4304d931098c`, `2b07cd77b6df4c70e55410667781c54e51de3edf962516692dd5263c042206b6`, `a7ff24d80e173087da1f3120b0851fa2cb0d1c2ccdc6e8bd1d6cb34ce031dce8`. Registered failing probe remains body-contact geometry mutation, not retarget.

Pair `/home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/20261013T083258787548Z/verdicts.json` SHA-256 `8837836d08e67563e2c664ddc28965c4d9d7f3b146af48c6a6d3304990791749`: **2/2 PASS**. Ordinary exit0 exact marker `PASS navagent3d_retarget callbacks=120 before=1.730676,0.000,1.730676 after_end=1.000,0.000,3.000 final=1.000,0.000,3.000`; fixed control exit2 exact marker `NEGATIVE REJECTED: navagent3d_retarget fixed callbacks=120 after_end=3.000,0.000,3.000 final=3.000,0.000,3.000`. Both stderr and reasons empty. Full and paired seed maps agree.

Compared with prior r51 full `.shokunin/game-dev-3d/corpus/live/runs/20261013T082700091224Z/verdicts.json` SHA-256 `9d7f738bc9ac34c70fd679b6728b4fd2bdc53c9af403e8b2b2b5ce250544084d`: all **77 complete raw case records identical**, comparing `case, script, flags, expected_exit, actual_exit, error, kind, marker, verdict, reasons, stdout, stderr` in order; elapsed time and command scratch paths excluded. Prior→current seed differences only `README.md` `998bc12a7ac4f78d85503310ae0f2cd7f1925e81f97f8a7dfad524a392529be0` → `8ba4191e8d9823698ab433d216ba657c528b2820f1e69672d693cdaf44e6fc74` and `navagent3d_retarget.gd` `f323a2058e0f7de3e49b9bf83a59026d3aec14aa8d1c69e277d057fe02554b03` → `6ad8584642edf8b1c41fb7116f39bf0e2d9513a2d73a99f0ea83d5cd4e1059d0`; all other seed hashes (including `navretarget3d_driver.gd` and `run_battery.py`) unchanged. Current `navagent3d_retarget.gd` defines independent route `expected_end` and literal `expected_actor_end` `(1,0,3)` for retarget, instead of deriving the final actor expectation from the route variable.

## Private aligned route mutant

Ignored scratch `/home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/r52-final-review-private` copies the fixture seeds. Exactly two source changes: copied driver `agent.target_position = Vector3(1, 0, 3)` → `Vector3(2, 0, 3)`; copied fixture **only** route guard `var expected_end := Vector3(1, 0, 3) if retarget else Vector3(3, 0, 3)` → `var expected_end := Vector3(2, 0, 3) if retarget else Vector3(3, 0, 3)`. Literal `expected_actor_end` remains `(1,0,3)` on retarget. Private driver SHA-256 `348aab36d650ecd3d0a5b492b78935345d92213494b7accd6519c0e44ec9161a`, private fixture SHA-256 `b65f39d051b5e09faa6e7bc05c61655eb49d602820fb16bd758d59a5e0f322e6`; reverting these exact substitutions reproduces the seed files byte for byte. Command from repository root:

```sh
/usr/bin/godot --headless --path /home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/r52-final-review-private --script res://navagent3d_retarget.gd > /home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/r52-final-review-private/mutant.stdout 2> /home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/r52-final-review-private/mutant.stderr
```

Ordinary mutant **exit1**, stdout banner only SHA-256 `1fb0f12cefe41f881cb436e6731d981084b95f8db9b1d6f3e25ac930f360a32e`, stderr SHA-256 `5de79265472be2dd437a98fc58f33ff4134d1975f47541eb8ba360bdc3cb06f7`:

```text
ERROR: navagent3d_retarget: agent-guided actor endpoint mismatch final=(2.0, 0.0, 3.0) target=(2.0, 0.0, 3.0) reached=true finished=true
   at: push_error (core/variant/variant_utility.cpp:1023)
   GDScript backtrace (most recent call first):
       [0] _fail (res://navagent3d_retarget.gd:57)
       [1] _run (res://navagent3d_retarget.gd:40)
```

The only failing diagnostic is the actor endpoint check at fixture line 40, **after** live setup, 120-callback/pre-switch motion, and route path-start/end/next guards passed. It observes actor `final=(2,0,3)` and target `(2,0,3)`, reached/finished `true` against independent literal actor expectation `(1,0,3)`. The route guard expected X2 and passed, so the r51 early route failure has been bypassed without weakening the actor destination. No `PASS` marker, `SCRIPT ERROR:`, `Parse Error:`, or ObjectDB leak warning. This mutation specifically proves the actor **final literal mismatch is effective** in this sample; the assertion is compound with `global_position` vs `actor.final` and reached/finished status, and the mutant does **not** separately isolate every one of those checks or prove general paths/timing.

**Bounded finding:** calibration improved for one scripted in-flight NavigationAgent3D reroute final actor endpoint, beyond r51's route-only private rejection; case coverage/depth unchanged. Actor motion is scripted `move_toward` in live `_physics_process`, not built-in autonomous NavigationAgent3D locomotion. No avoidance, baked navmesh generation, physical collision, arbitrary route guarantees, GPU/pixels or general engine versions. Assumptions/constants unchanged: pinned Godot build, authored flat 4×4 map, 60 Hz physics, start `(1,0,1)`, initial target `(3,0,3)`, ordinary target `(1,0,3)` at callback index 35, speed 2, cap 120 callbacks/125 observation frames; only ignored private driver and route expectation change target X1→2.
