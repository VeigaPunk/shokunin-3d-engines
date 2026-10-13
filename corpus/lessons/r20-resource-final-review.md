# Round 20 — fresh final non-author PackedScene resource review

**Verdict: qualified admission for depth after source-sharing correction.** Godot 4.7.2 headless demonstrates an isolated local-to-scene BoxMesh clone and a deliberately shared control that mutates **both the second clone and the original source resource**. The implementation now asserts shared `mesh_a == mesh_b == source_mesh` and, after first-clone mutation, second/source size `(2,1,1)`; the local arm asserts both clones differ from each other and source, and after mutation first `(2,1,1)`, second/source `(1,1,1)`. The authored source is intact after mutation only in the local arm. No implementation edit, push, or merge was performed.

## Fresh replay

From repository root, independently ran:

```sh
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only scene3d_resource_local,scene3d_resource_shared
```

Both commands exit 0. Full receipt `.shokunin/game-dev-3d/corpus/live/runs/20261013T052850019973Z/verdicts.json`, SHA-256 `2df6be9e9010c2be8f0fb29930a50d037e4c0b0514339aff4fe384bd6ea6020d`: **27/27 PASS**, 13 ordinary and 14 negative; four `tree-timeout-verdicts.json`, `crash-exit-verdicts.json`, `stream-attribution-verdicts.json`, `mutation-verdicts.json` each PASS. Paired receipt `corpus/live/runs/20261013T052854452725Z/verdicts.json`, SHA-256 `cdfa42de4b07e63012dfe1e6303739011a6f63f97e8dace27303e3a0313b0efb`: **2/2 PASS**, local exit 0 and shared exit 2. Exact case stdout marker lines:

```text
PASS scene3d_resource local_mesh_mutation first_size=2.000,1.000,1.000 second_size=1.000,1.000 distinct_resources=true
NEGATIVE REJECTED: scene3d_resource shared_mesh_mutation second_size=2.000,1.000,1.000 source_size=2.000,1.000,1.000 same_resource=true
```

All 27 case stderr arrays are empty, as are the paired arrays; no parse, ObjectDB, mesh/RID or geometry leak warnings. Both receipts report `seeds_unchanged=true` with identical seed maps. Current `scene3d_resource.gd` SHA-256 is `7bbd986c1bc22921a7a2b85c43f0a06530efdafb35eb411494a1eecbb718181c`; `run_battery.py` is `d9805b4f9898b53a40c2c5eda5ca3b2aeedd4b0e298323eac3421a8c04680558`; `README.md` is `92d8e7fb43972d5ededf55cab64580fe7532b16b17df283748266a0390aa1b9c`. Against the prior independent 25-case full receipt `corpus/live/runs/20261013T051450833462Z/verdicts.json`, all **25 prior** cases have exactly identical stdout/stderr arrays, actual and expected exits, errors, kinds, markers, flags, reasons and verdicts. Twenty of its 22 seed hashes remain identical; README and runner changed for the new pair, while `scene3d_resource.gd` is newly added. Godot is `/usr/bin/godot`, `4.7.2.stable.arch_linux.ed1daf0bf`; runner per-case timeout is 20 seconds and fixture internal frame bound is 1200 frames.

## Source and private adverse check

Read `corpus/fixtures/scene3d_resource.gd`: source Node3D owns the BoxVisual MeshInstance3D with BoxMesh before `PackedScene.pack`; `resource_local_to_scene = not shared`. Before changing `mesh_a.size`, it asserts both clone BoxMesh types, source-child identity, three independent literal `Vector3.ONE` initial sizes, readback locality flags, and either three-way shared equality or three-way distinctness. After changing first mesh size to `Vector3(2,1,1)`, shared checks **both** second and source against the new literal; local checks first against that literal and second/source against `Vector3.ONE`. All owned nodes are freed on success and `_fail`; exact marker text is hardcoded after checks, not generated from observed dimensions.

Copied that source only into ignored `corpus/live/runs/review-r20-final-mutant/scratch/scene3d_resource.gd` and changed exactly `const INITIAL_SIZE := Vector3.ONE` to `const INITIAL_SIZE := Vector3(1.5, 1, 1)` (private copy SHA-256 `3f846abbacf9bfa73a1c45034d014b2a2f254ff7c75a6849f3cffd8ac232750c`). Reproduce from repo root:

```sh
/usr/bin/godot --headless --path "$PWD/.shokunin/game-dev-3d/corpus/live/runs/review-r20-final-mutant/scratch" --script res://scene3d_resource.gd --
/usr/bin/godot --headless --path "$PWD/.shokunin/game-dev-3d/corpus/live/runs/review-r20-final-mutant/scratch" --script res://scene3d_resource.gd -- --shared
```

Both exit **1** before either marker and report `ERROR: scene3d_resource: initial mesh size mismatch first=(1.5, 1.0, 1.0) second=(1.5, 1.0, 1.0) source=(1.5, 1.0, 1.0)` with `_fail` push_error backtrace on stderr, banner only on stdout. Captured separated `mutant.stdout`, `mutant.stderr`, `mutant-shared.stdout`, `mutant-shared.stderr` in that ignored scratch. Neither arm shows a Parse Error, SCRIPT ERROR, ObjectDB warning or RID/geometry leak. This is a **literal** baseline rejection; modifying INITIAL_SIZE does not merely move the expected initial size.

**Limits:** One in-memory headless Godot PackedScene/BoxMesh setup only. Shared branch mutates the original source resource by design; neither the source node nor packed scene is guaranteed semantically unchanged after shared mutation. These assertions do not validate rendered pixels, saved `.tscn` reload, other resource classes, generic scene ownership, other Godot versions or engines. Fixed markers are guarded by actual literal assertions but are not raw dimension telemetry. The four probes make only their documented bounded claims, not general crash/process-tree/mutation coverage.
