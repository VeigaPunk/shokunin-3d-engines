# Round 38 independent Skeleton3D review (2026-10-13)

**Verdict:** bounded coverage improved: live headless Godot `Skeleton3D` rest-hierarchy and pose API readback, absent from the previous 51 cases. Depth/calibration unchanged. This independently reproduces the admitted behavior, not skinning or rendering. Reviewer made no implementation edits, push, merge, or commit. Runtime `/usr/bin/godot` 4.7.2.stable.arch_linux.ed1daf0bf, `--headless`.

## Source and distinction from rejected r37

Read `.shokunin/game-dev-3d/LOG.md` rounds 37–38, `corpus/fixtures/README.md`, `skeleton3d_pose.gd`, and `run_battery.py`. R37's intended per-instance `MultiMesh` transforms returned identity/empty buffer under the headless dummy renderer and **was rejected**, despite graphical-mode readback. R38 uses the unchanged headless runtime; it reads the real `Skeleton3D` APIs rather than inferring success from setters or changing the driver.

The live skeleton has Root bone index 0, Tip bone index 1, Tip parent 0, Root parent -1. Explicit **local rests** Root `(1,0,0)` and Tip `(0,2,0)` yield `get_bone_global_rest(1).origin=(1,2,0)`. The ordinary arm sets Tip `set_bone_pose_position(1, Vector3(0,3,0))` and verifies `get_bone_pose_position(1)`, `get_bone_pose(1).origin`, and `get_bone_global_pose(1).origin` equal `(0,3,0)`; Root global pose origin remains zero. The intact rest-only arm leaves Tip pose zero and confirms the same rest/hierarchy. The `global_pose` readback is **pose hierarchy data, not world/rest-combined child position `(1,5,0)`**; do not conflate it with `global_rest` or a skinned vertex. Successful exact markers follow checks: `PASS skeleton3d_pose parent=0 child_rest=1.000,2.000,0.000 child_pose_y=3.000` (exit 0); `NEGATIVE REJECTED: skeleton3d_pose rest_only child_rest=1.000,2.000,0.000 child_pose_y=0.000` (exit 2). Both have empty stderr, no reasons or runtime error in each run.

## Independent commands, receipts, hashes

- `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → exit 0; **53/53** (25 ordinary, 28 negative), four PASS opt-in probes, unchanged seed digests. Raw receipt `.shokunin/game-dev-3d/corpus/live/runs/20261013T065934752715Z/verdicts.json`, SHA-256 `925d74ac1cb71ab06e2c17b02027c154b212ef409af6d95ff941e3dbe1575ce4`. The four companion `tree-timeout-verdicts.json`, `crash-exit-verdicts.json`, `stream-attribution-verdicts.json`, `mutation-verdicts.json` are in that directory. The built-in failing mutation remains the separate body3d contact test, not Skeleton3D.
- `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only skeleton3d_pose,skeleton3d_rest_only` → exit 0; **2/2**, no opt-ins, unchanged seed digests. Raw receipt `/home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/20261013T065934752254Z/verdicts.json`, SHA-256 `9e851aae20f7ea50d21def0acf759e2fa42f552e5d1e1d679b12da7329482628`. Its seed-digest map equals the full receipt exactly.
- Previous complete **51/51** headless receipt `.shokunin/game-dev-3d/corpus/live/runs/20261013T065354780891Z/verdicts.json`, SHA-256 `d9b6534f78821ba51e86fc6c7b1282e71ef851fdae14b4c1740e3b5b0e0fd8b5`. All 51 prior case raw records are equal to this full run on `case,script,flags,expected_exit,actual_exit,error,kind,marker,verdict,reasons,stdout,stderr`. Excluded volatile scratch `command` paths and `elapsed_seconds`; none of the old seed keys disappeared. Prior→current changed seed SHA-256 only: `README.md` `46255087f985359904fd96c07c8a8a20cf266af5e6635533f1bd284f66e7284b` → `1900454083c323e6c30b2cfade55458febde01fd2aaff4fe32f85201f3b882a6`; `run_battery.py` `aedf58a12ade2dbe699ec5968b361a3d0592433709bfaa5fba5dfbce4c38d80e` → `5415e27a041ee67d1e0a4f7b936f8f5baa1536d3a93e88c9becd86bbea542189`. New `skeleton3d_pose.gd` `dd6a3b3b2bb72d68debc66429cc211a327a2dde8cf3892aefab5ab44809ad9cc`; all other previous seed hashes identical.

## Private copied setter mutation

Copied the pair's ignored scratch project to `.shokunin/game-dev-3d/corpus/live/runs/review-r38-private-skeleton/scratch` (excluded `.godot`), changed **only** this once-occurring setter in that copied fixture (source SHA-256 `dd6a3b3b2bb72d68debc66429cc211a327a2dde8cf3892aefab5ab44809ad9cc` → `86774fb751579616e08cea6ff7138780804312c469501d9718fe5a385eec8cc3`):

```diff
- skeleton.set_bone_pose_position(1, Vector3(0, 3, 0))
+ skeleton.set_bone_pose_position(1, Vector3(0, 4, 0))
```

`/usr/bin/godot --headless --path /home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/review-r38-private-skeleton/scratch --script res://skeleton3d_pose.gd --` → **exit 1**, no PASS or NEGATIVE marker, no parse error, `SCRIPT ERROR`, or ObjectDB leak. Exact diagnostic: `ERROR: skeleton3d_pose: bone pose readback mismatch local=(0.0, 4.0, 0.0) pose=(0.0, 4.0, 0.0) global=(0.0, 4.0, 0.0)`; backtrace `_run` line 29 / `_fail` line 40. The mutation leaves hierarchy/rest checks intact and reaches measured local/pose/global pose assertion; it is not rejected at setup or by a source-literal readback. Original tracked seed remains SHA-256 `dd6a3b3b2bb72d68debc66429cc211a327a2dde8cf3892aefab5ab44809ad9cc`.

**Limits:** One two-bone translation-only hierarchy, one nonzero child pose and one rest-only control under this engine/headless build. No rotations, scaling, skin/mesh deformation, animation blend, global/world-space child vertex location, GPU drawing, or pixels; the three readback predicates are checked together and not individually mutation-isolated.

> **Correction note (r106, 2026-10-18, SEAT-42).** Live-tree digest check. Quoted SHA-256 values above are the 2026-10-13 review record and are not rewritten; quoted `README.md` and `run_battery.py` digests match historical git blobs, not live `sha256sum` `corpus/fixtures/README.md` `347e0d1e5e4efca9c6f8b93440370352278bb30f3c1f62cee19edd3704619cb1` and `corpus/fixtures/run_battery.py` `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`. `skeleton3d_pose.gd` digest `dd6a3b3b2bb7…` still matches the live fixture. Absent `corpus/live/runs/` receipts and private mutant copies were not re-hashed.

<!-- r106-seat45-receipt-note -->

> **Non-resolvable receipt note (r106, 2026-10-18, SEAT-45).** Re-checked 2026-10-18: each path below is a concrete `corpus/live/runs` receipt cited in this lesson. The cited path is absent (`test -e` failed) and no durable copy exists under `reports/` (no receipt artifact whose path or `started_utc` is that run id; a prose mention is not a copy). Quoted receipt SHA-256 values on these lines do not match any tracked file or any `reports/` receipt artifact. `corpus/.gitignore` ignores `live/`, so these paths were never tracked. Historical sentences above are unchanged. Register: `reports/round-106/consistency/receipts.md`.
>
> - `corpus/live/runs/20261013T065934752715Z/verdicts.json`
> - `corpus/live/runs/20261013T065934752715Z/tree-timeout-verdicts.json`
> - `corpus/live/runs/20261013T065934752715Z/crash-exit-verdicts.json`
> - `corpus/live/runs/20261013T065934752715Z/stream-attribution-verdicts.json`
> - `corpus/live/runs/20261013T065934752715Z/mutation-verdicts.json`
> - `corpus/live/runs/20261013T065934752254Z/verdicts.json`
> - `corpus/live/runs/20261013T065354780891Z/verdicts.json`
> - `corpus/live/runs/review-r38-private-skeleton/scratch`
