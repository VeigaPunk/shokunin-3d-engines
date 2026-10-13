# Round 20 — independent PackedScene resource review (non-author)

**Verdict: qualified admission for depth.** Headless Godot 4.7.2 exhibits distinct local-to-scene BoxMesh instances and an isolated size change; the paired flag-false branch shares one BoxMesh, so a first-clone size change reaches the second **and the original source**. The declared “intact authored source/packed setup” holds after mutation **only in the local branch**. Coverage and calibration unchanged. I edited no implementation and did not push or merge.

## Replay and receipts

Run at repository root:

```sh
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only scene3d_resource_local,scene3d_resource_shared
```

Full receipt `corpus/live/runs/20261013T052611647976Z/verdicts.json`: exit 0, **27/27 PASS** (13 ordinary/14 negative), seed hashes unchanged, four opt-in probe receipts `tree-timeout-verdicts.json`, `crash-exit-verdicts.json`, `stream-attribution-verdicts.json`, `mutation-verdicts.json` each PASS. Paired receipt `corpus/live/runs/20261013T052616358456Z/verdicts.json`: exit 0, **2/2 PASS**, unchanged seeds. Local exits 0 with exact `PASS scene3d_resource local_mesh_mutation first_size=2.000,1.000,1.000 second_size=1.000,1.000 distinct_resources=true`; shared exits 2 with exact `NEGATIVE REJECTED: scene3d_resource shared_mesh_mutation second_size=2.000,1.000,1.000 same_resource=true`. Both stderr arrays empty, no parse/leak warnings. This seed script SHA-256 is `46fdcfb99facb1199ba302ebb60efff8269af2f94cb78aa481f4c35cb547df98` in both receipts.

Compared the full receipt against r18 independent full receipt `corpus/live/runs/20261013T051450833462Z/verdicts.json` (25/25, also cited by the r18 review): **all 25 prior** case raw stdout/stderr arrays, actual/expected exits, errors, kinds, expected markers, flags, reasons and verdicts exactly match. Of 22 prior seed digests, 20 match; runner and fixture README differ as intended, and the new resource script is additional. Both receipts independently report `seeds_unchanged=true`. The r19 final review also recorded a separate 25/25 regression at `20261013T052155276140Z`, but it did not run the four probes; this review's raw comparison uses the complete r18 receipt.

## Private adverse check and actual ownership

Created only ignored `corpus/live/runs/review-r20-private-mutant/scratch/scene3d_resource.gd` copied from the seed; changed solely `const INITIAL_SIZE := Vector3.ONE` to `const INITIAL_SIZE := Vector3(1.5, 1, 1)`. Commands (relative to repository root):

```sh
/usr/bin/godot --headless --path "$PWD/.shokunin/game-dev-3d/corpus/live/runs/review-r20-private-mutant/scratch" --script res://scene3d_resource.gd --
/usr/bin/godot --headless --path "$PWD/.shokunin/game-dev-3d/corpus/live/runs/review-r20-private-mutant/scratch" --script res://scene3d_resource.gd -- --shared
```

Both exit **1**, with banner only on stdout; stderr has `ERROR: scene3d_resource: initial mesh size mismatch first=(1.5, 1.0, 1.0) second=(1.5, 1.0, 1.0) source=(1.5, 1.0, 1.0)` and push_error backtrace only. No marker, Parse Error, SCRIPT ERROR, ObjectDB/RID or geometry leak diagnostic. Separated streams are `mutant.stdout`, `mutant.stderr`, `mutant-shared.stdout`, `mutant-shared.stderr` alongside the ignored copy. This proves the literal `Vector3.ONE` baseline catches this authored-size drift in either arm; it does not test arbitrary resource mutations.

Inspection of `scene3d_resource.gd`: source Node3D owns its MeshInstance3D child; its BoxMesh has `resource_local_to_scene = not shared` before `PackedScene.pack`. After instantiating two nodes, the fixture checks their mesh types, source-child resource identity, three literal initial sizes, readback locality flags, and clone identity (distinct and neither source for local; clone-to-clone equality for shared). The first clone size becomes `(2,1,1)`; local checks first/second/source post-sizes, whereas shared checks **only second** post-size. Exact markers are hardcoded labels after those assertions, not formatted live dimensions. `_cleanup` frees both clones and the source in success/control and `_fail`; resource lifetime is tied to these owners/scene references, not a separate explicit resource-free call. `packed` is a local PackedScene reference. There is no rendered geometry assertion.

To disambiguate the missing source postcondition, I copied the unmodified seed into ignored `corpus/live/runs/review-r20-private-mutant/identity-scratch`, adding **only diagnostic prints after the size mutation** (not a source change), then invoked `/usr/bin/godot --headless --path "$PWD/.shokunin/game-dev-3d/corpus/live/runs/review-r20-private-mutant/identity-scratch" --script res://scene3d_resource.gd -- --shared` and the same command without `--shared`. Shared exit 2 prints `OBSERVED_SHARED source_is_first=true source_is_second=true source_size=(2.0, 1.0, 1.0)`; local exit 0 prints `OBSERVED_LOCAL source_is_first=false source_is_second=false source_size=(1.0, 1.0, 1.0)`. Thus the shared branch's source BoxMesh is the same object and is mutated; this is consistent with shared-resource semantics, not a regression. The unmodified shared fixture does **not** independently assert source identity or source's post-size, and the negative label's `same_resource=true` derives from the clone equality check, not a three-way equality check.

**Limits:** This is in-memory resource identity/size propagation for one BoxMesh under Godot headless. The r17 caveat about unchecked mutable mesh identity is closed for these two arms, not for other resources, saved `.tscn` reloads, GPU pixels, general clone ownership, or other engines. The static marker strings depend on earlier literal assertions rather than raw metric formatting. Do not claim the original source remains unchanged in the shared control; it does not.
