# Round 36 independent two-face collision review (2026-10-13)

**Verdict:** admit bounded depth evidence. Godot 4.7.2.stable.arch_linux.ed1daf0bf, `/usr/bin/godot`, headless; no implementation edits, commit, push, or merge by reviewer.

## Source and behavior

Read `.shokunin/game-dev-3d/LOG.md` round 36, `corpus/fixtures/README.md`, `mesh3d_faces_hit.gd`, and `run_battery.py`. The source authors an XY quad of four vertices `(0,0,0),(2,0,0),(2,2,0),(0,2,0)` with six indices, forward `[0,1,2,0,2,3]` and paired swapped triangle order `[0,2,3,0,1,2]`. `ArrayMesh.create_trimesh_shape()` supplies a generated concave collider; setup checks `generated.get_faces().size() == 6` (six face vertices, two triangles), one surface, attached shape/body, and `generated.backface_collision=true`. Each `PhysicsRayQueryParameters3D` also has `hit_back_faces=true` and collision mask 1; four awaited physics frames precede queries. This is explicitly two-sided, not evidence of default-backface behavior.

Both full and paired actual engine executions pass the fixture's physics-space dictionary assertions: disjoint rays through `(1.5,0.5)` and `(0.5,1.5)` hit the same live body and `body.get_instance_id()`, at the queried XY with Z0, normal `(0,0,1)` (tolerance `0.0001`). The forward indices give face indices `0,1`; reordered triples give `1,0` without changing positions or normals. Third actual ray at `(3,1)` is empty, not merely a printed claim. Printed exact markers are `PASS mesh3d_faces_hit two_faces face_a=0 face_b=1 outside_hits=0` (exit 0) and `NEGATIVE REJECTED: mesh3d_faces_hit reordered face_a=1 face_b=0 outside_hits=0` (exit 2). These markers follow the dictionary checks, though the fixture does not print all hit dictionaries on success.

## Independent reproduction and raw attribution

- Full command: `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing`. Exit 0, **51/51** (`24 ordinary, 27 negative`) plus **four PASS probes**, unchanged seeds. Receipt: `.shokunin/game-dev-3d/corpus/live/runs/20261013T064619036815Z/verdicts.json`; accompanying `tree-timeout-verdicts.json`, `crash-exit-verdicts.json`, `stream-attribution-verdicts.json`, `mutation-verdicts.json` in its directory. Runner case timeout 20 seconds.
- Pair command: `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only mesh3d_faces_hit,mesh3d_faces_reordered`. Exit 0, **2/2**, no opt-ins, unchanged seeds. Receipt: `.shokunin/game-dev-3d/corpus/live/runs/20261013T064641113977Z/verdicts.json`. Both new raw records have empty stderr, no errors/reasons, expected and actual exits 0/0 and 2/2 respectively.
- Previous complete 49-case receipt: `.shokunin/game-dev-3d/corpus/live/runs/20261013T064029016188Z/verdicts.json`. All 49 prior named raw records identical on `case,script,flags,expected_exit,actual_exit,error,kind,marker,verdict,reasons,stdout,stderr` (including exact stdout lines). Volatile `command` scratch paths and `elapsed_seconds` are deliberately excluded. Prior seed SHA-256 keys unchanged except `README.md` `94b04ef42213f1564d864b119feaf966ad6edaa41de7abe0be46aab61769c6b6` → `46255087f985359904fd96c07c8a8a20cf266af5e6635533f1bd284f66e7284b` and `run_battery.py` `d70bede71d492bdcf7ce1e305d2b74419f5754ab6c64ce37189562e3da5269dc` → `aedf58a12ade2dbe699ec5968b361a3d0592433709bfaa5fba5dfbce4c38d80e`; new `mesh3d_faces_hit.gd` seed `566e290f9a2e112e8e20921edcbeba04139c40fb0259a986e369372bbd174310`. No prior seed missing; pair and full seed digest maps identical.

## Private copied mutation

Copied only the paired run's ignored scratch project to `.shokunin/game-dev-3d/corpus/live/runs/review-r36-private-faces/scratch`. One exact source-line match changed, with no fixture seed or other copied file changed:

```diff
- var indices := PackedInt32Array([0, 2, 3, 0, 1, 2] if reversed else [0, 1, 2, 0, 2, 3])
+ var indices := PackedInt32Array([0, 2, 3, 0, 1, 2] if reversed else [0, 2, 3, 0, 1, 2])
```

The unchanged reversed branch contains the same replacement literal, but the *full forward source-line anchor* occurred exactly once; `reversed` remains false under the command, and expected forward indices remain `0,1` in the assertions. Copied script SHA-256 before `566e290f9a2e112e8e20921edcbeba04139c40fb0259a986e369372bbd174310`, after `2e9a19e64b5c35201298c6025fab7409f0c85956e346aac79d465075178aa86c`. Command: `/usr/bin/godot --headless --path /home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/review-r36-private-faces/scratch --script res://mesh3d_faces_hit.gd --`; **exit 1**. Diagnostic: `ERROR: mesh3d_faces_hit: face hit mismatch ray=0 expected_face=0 actual={ "position": (1.5, 0.5, 0.0), "normal": (0.0, 0.0, 1.0), "face_index": 1, "collider_id": 26491225550, "collider": @StaticBody3D@3:<StaticBody3D#26491225550>, "shape": 0, "rid": RID(107374182400) }`. Backtrace names `_run` line 43 / `_fail` line 54. No PASS/NEGATIVE marker, parse error, `SCRIPT ERROR`, or ObjectDB leak. This mutation passes setup and hit/miss routing, then fails measured first-ray face-index comparison, rather than a source/readback guard.

**Limit:** This supports one static two-face mesh-derived collider and this engine build's face ordering after four ticks; it does not establish cross-version face-index stability, default backface collisions, dynamic contacts, GPU winding, rasterization, or pixels. The shape face count is asserted but its six vectors are not independently logged; hit identity/coordinates/normals are asserted, not separately mutation-isolated.

> **Correction note (r106, 2026-10-18, SEAT-42).** Live-tree digest check. Quoted SHA-256 values above are the 2026-10-13 review record and are not rewritten; quoted `README.md` and `run_battery.py` digests match historical git blobs, not live `sha256sum` `corpus/fixtures/README.md` `347e0d1e5e4efca9c6f8b93440370352278bb30f3c1f62cee19edd3704619cb1` and `corpus/fixtures/run_battery.py` `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`. `mesh3d_faces_hit.gd` digest `566e290f9a2e…` still matches the live fixture. Absent `corpus/live/runs/` receipts and private mutant copies were not re-hashed.

<!-- r106-seat45-receipt-note -->

> **Non-resolvable receipt note (r106, 2026-10-18, SEAT-45).** Re-checked 2026-10-18: each path below is a concrete `corpus/live/runs` receipt cited in this lesson. The cited path is absent (`test -e` failed) and no durable copy exists under `reports/` (no receipt artifact whose path or `started_utc` is that run id; a prose mention is not a copy). Quoted receipt SHA-256 values on these lines do not match any tracked file or any `reports/` receipt artifact. `corpus/.gitignore` ignores `live/`, so these paths were never tracked. Historical sentences above are unchanged. Register: `reports/round-106/consistency/receipts.md`.
>
> - `corpus/live/runs/20261013T064619036815Z/verdicts.json`
> - `corpus/live/runs/20261013T064619036815Z/tree-timeout-verdicts.json`
> - `corpus/live/runs/20261013T064619036815Z/crash-exit-verdicts.json`
> - `corpus/live/runs/20261013T064619036815Z/stream-attribution-verdicts.json`
> - `corpus/live/runs/20261013T064619036815Z/mutation-verdicts.json`
> - `corpus/live/runs/20261013T064641113977Z/verdicts.json`
> - `corpus/live/runs/20261013T064029016188Z/verdicts.json`
> - `corpus/live/runs/review-r36-private-faces/scratch`
