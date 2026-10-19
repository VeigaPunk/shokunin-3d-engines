# r17 non-author instance review — provisional blocker

Independent verifier (read-only implementation). Read `.shokunin/game-dev-3d/PROVINCE.md` and `LOG.md` round 17 before testing. Godot 4.7.2 headless Linux; no push or merge.

## Replay

- `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → `corpus/live/runs/20261013T051012374948Z/verdicts.json`, PASS 23/23 (11 ordinary, 12 negative), four opt-ins PASS. Exact r17 raw exits 0/2; expected stdout marker lines; empty stderr; `error=null`. Probe receipts in the same run directory: crash normal exit1 versus signaled -15, stream diagnostic rejected with identical exit0/stdout, tree logical timeout with witness gone, body-contact constant mutant exit1 and expected diagnostic.
- `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only scene3d_instances,scene3d_instances_wrong_local` → `corpus/live/runs/20261013T051022145889Z/verdicts.json`, PASS 2/2, empty stderr.
- Seed map unchanged within both runs. Relative to r16 full `corpus/live/runs/20261013T050610908903Z/verdicts.json`, all 21 prior cases have identical raw stdout/stderr, exits, markers, reasons, kinds and verdicts. Changed seed hashes only README and runner; new seed `scene3d_instance.gd` SHA-256 `04ec1fce6adacf5dea31d0be58bb65d4626e4af1b88e77252abe5404021d4ef8` at initial test.

## Source review and mutation blocker

`source.add_child(child)` and `child.owner = source` precede `PackedScene.pack(source)`. Two `packed.instantiate()` calls produce distinct root and child nodes, each attached to SceneTree; exact local/world transforms and source child position are compared against independent literals. Negative explicitly changes **second** child position to `(2,2,-3)` after both clones exist, proves first remains at `(1,2,-3)`/`(11,2,-3)` and source remains at `(1,2,-3)`, then checks second world `(-8,2,2)` rather than original `(-9,2,2)`. Success branches free both clones and source before marker/exit. Labels/positions in the printed markers are **hardcoded**, though guarded by the literal predicates; not live-formatted telemetry. The two mesh references are only tested non-null, so this does **not** prove that instances have separate BoxMesh resources or mutable mesh-resource isolation.

Private fixture copy at `corpus/live/runs/review-r17-mutant-20261013T051037865663Z/scratch` changes only `const CHILD_LOCAL := Vector3(1, 2, -3)` to `Vector3(2, 2, -3)`. Reproduce with `/usr/bin/godot --headless --path "$PWD/.shokunin/game-dev-3d/corpus/live/runs/review-r17-mutant-20261013T051037865663Z/scratch" --script res://scene3d_instance.gd --`. Actual exit1 with `ERROR: scene3d_instances: source changed` at the literal source-position assertion; no PASS marker or parse error. **But** `_fail` exits without freeing the instantiated nodes/source, and stderr also reports leaked ObjectDB instances and Mesh/geometry RIDs. This initially failed requested clean attribution. The author was notified and repaired failure-path cleanup; the following amendment supersedes this preliminary blocker.

## Amendment — repaired fixture replay

Author reordered the first-clone literal ahead of source check and tracks the source and both instantiated roots for `_cleanup()` before `_fail` reports exit1; both clean branches also call `_cleanup()`. New `scene3d_instance.gd` SHA-256 `bf47af512df4e9e7750ebed024c65ccdede38c65e6cdc4c49aacfd1b655385cb`. The earlier copied-source mutant receipt above documents the **superseded** version and is not the final acceptance test.

- Paired rerun: `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only scene3d_instances,scene3d_instances_wrong_local` → `corpus/live/runs/20261013T051126079512Z/verdicts.json`; PASS 2/2 with exact exits 0/2, markers, and empty stderr; seeds unchanged.
- Fresh private copy `corpus/live/runs/review-r17-mutant-20261013T051131418475Z/scratch`: changed **only** authored `const CHILD_LOCAL := Vector3(1, 2, -3)` to `Vector3(2, 2, -3)` with exact-match edit. Run `/usr/bin/godot --headless --path "$PWD/.shokunin/game-dev-3d/corpus/live/runs/review-r17-mutant-20261013T051131418475Z/scratch" --script res://scene3d_instance.gd --`. Actual exit **1**, no PASS or parse error. Exact attributable diagnostic: `ERROR: scene3d_instances: first clone mismatch local=(2.0, 2.0, -3.0) world=(12.0, 2.0, -3.0)`; following stderr contains only Godot push_error location and backtrace, **no ObjectDB/RID/geometry leaks**. The first clone's observed world coordinate changes by +1 as the authored local coordinate changes by +1; independent literal still expects 11.
- Full rerun: `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → `corpus/live/runs/20261013T051126079226Z/verdicts.json`: PASS **23/23**, 11 ordinary/12 negative; four opt-in probe JSON receipts all PASS; seeds unchanged. Both new cases have exact exits 0/2, expected marker and empty stderr. All prior 21 r16 raw streams/exits/markers/reasons and verdicts match `20261013T050610908903Z`; only README/runner seed digests changed and new instance script was added. Normal probes verify direct-child signal, unexpected stderr rejection, identified Linux timeout witness cleanup, and body-contact depth mutation, not a general guarantee outside these bounded checks.

**Independent verdict:** r17 acceptance blocker resolved. **Coverage improves** narrowly for in-memory Godot 4.7.2 headless `PackedScene.pack` and two instance-local Node3D/MeshInstance3D transforms with preserved source and a deliberate second-only local deviation. Depth and calibration unchanged; no regression in 21 prior cases or four optional probes. Do not claim serialized scene file, rendering, mesh-resource identity/isolation, other engines, or general leak-free failure paths beyond tested mutation.

<!-- r106-seat45-receipt-note -->

> **Non-resolvable receipt note (r106, 2026-10-18, SEAT-45).** Re-checked 2026-10-18: each path below is a concrete `corpus/live/runs` receipt cited in this lesson. The cited path is absent (`test -e` failed) and no durable copy exists under `reports/` (no receipt artifact whose path or `started_utc` is that run id; a prose mention is not a copy). Quoted receipt SHA-256 values on these lines do not match any tracked file or any `reports/` receipt artifact. `corpus/.gitignore` ignores `live/`, so these paths were never tracked. Historical sentences above are unchanged. Register: `reports/round-106/consistency/receipts.md`.
>
> - `corpus/live/runs/20261013T051012374948Z/verdicts.json`
> - `corpus/live/runs/20261013T051022145889Z/verdicts.json`
> - `corpus/live/runs/20261013T050610908903Z/verdicts.json`
> - `corpus/live/runs/review-r17-mutant-20261013T051037865663Z/scratch`
> - `corpus/live/runs/20261013T051126079512Z/verdicts.json`
> - `corpus/live/runs/review-r17-mutant-20261013T051131418475Z/scratch`
> - `corpus/live/runs/20261013T051126079226Z/verdicts.json`
