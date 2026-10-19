# Round 21 — independent saved BoxMesh resource review

**Finding: qualified depth improvement.** In Godot `4.7.2.stable.arch_linux.ed1daf0bf` headless, the saved/reloaded `.tscn` scene's BoxMesh behaves differently under scene-local true versus default false. This reviewer did not edit implementation, push, or merge.

## Independent replay and receipts

From repository root, I ran:

```sh
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only scene3d_resource_disk_local,scene3d_resource_disk_shared
```

Both commands exited 0. Full receipt `.shokunin/game-dev-3d/corpus/live/runs/20261013T053240636367Z/verdicts.json` (SHA-256 `1e1dfb43a3b3149d7618f4684775350eafba2c908a8ec13c200bc012cb69bdba`) says **29/29 PASS**, 14 ordinary and 15 negative controls, stable seed digests. Its `tree-timeout-verdicts.json`, `crash-exit-verdicts.json`, `stream-attribution-verdicts.json`, and `mutation-verdicts.json` each say PASS. Pair receipt `corpus/live/runs/20261013T053240636908Z/verdicts.json` (SHA-256 `a8994fd72824bf1dff344ff0a39d0cf4b6581324b8981c0513c3a1e04bc31380`) says **2/2 PASS**, unchanged seeds, local exit 0 and shared exit 2. The two seed-digest maps match. Both cases have empty stderr and exact expected marker lines:

```text
PASS scene3d_resource_disk local_mesh_mutation first_size=2.000,1.000,1.000 second_size=1.000,1.000 distinct_resources=true
NEGATIVE REJECTED: scene3d_resource_disk shared_mesh_mutation second_size=2.000,1.000,1.000 loaded_size=2.000,1.000,1.000 same_resource=true
```

Compared to the previous independent 27-case receipt `corpus/live/runs/20261013T052850019973Z/verdicts.json`, **all previous 27** cases have identical raw stdout/stderr, exits, markers, flags, errors, reasons, kinds and verdicts; their case seed hashes are unchanged. The new fixture's SHA-256 is `996514bf30214bb2f7363bcb033bfe73a658c49fed1d3ba336871e89d452070f`.

## Saved text, assertions and private mutation

I inspected four **distinct fresh scratch projects** under ignored `corpus/live/runs/review-r21-independent/{local,shared,mutant-local,mutant-shared}/`. Their actual `generated-resource3d.tscn` files have `[gd_scene format=3]`, `[sub_resource type="BoxMesh" ...]`, a `ResourceRoot` Node3D and child `BoxVisual` MeshInstance3D with `mesh = SubResource(...)`. Local text explicitly persists `resource_local_to_scene = true`; shared text omits the **default false** field rather than writing literal false. Both unmutated files omit default `size=Vector3.ONE`. The mutant texts each add `size = Vector3(1.5, 1, 1)`; only mutant-local retains the true locality field. Godot-generated unique IDs vary between saves, so whole-file byte equality is neither required nor claimed. Direct unmutated runs exited 0/2 with the same marker lines and empty stderr.

Source `corpus/fixtures/scene3d_resource_disk.gd` constructs owned Node3D/MeshInstance3D/BoxMesh, sets locality, packs/saves and reloads with `CACHE_MODE_IGNORE`, then instantiates **three loaded instances**: `loaded_source`, `first`, `second`. It checks the loaded BoxMesh types, source child identity, three literal initial `Vector3.ONE` sizes, loaded flags and three-way resource identities. With true, `mesh_a`, `mesh_b`, `loaded_mesh` are pairwise distinct; changing first's X from 1 to 2 leaves second and loaded-source X1 while first is asserted X2. With false, those three loaded meshes are one object; changing first X1→2 makes second and loaded-source X2. The original separately spawned source node and `source_mesh` are only checked for setup (`source_child.mesh == source_mesh`); source-versus-loaded identity and original-source post-mutation size are **not** asserted. All owned nodes are freed on normal and `_fail` paths.

Private copied-only source mutation changed exactly `const INITIAL_SIZE := Vector3.ONE` to `const INITIAL_SIZE := Vector3(1.5, 1, 1)` in both mutant scratch projects. Direct `godot --headless --path <scratch> --script res://scene3d_resource_disk.gd -- [--shared]` exits **1 in both arms**, with stderr `ERROR: scene3d_resource_disk: initial mesh size mismatch first=(1.5, 1.0, 1.0) second=(1.5, 1.0, 1.0) loaded=(1.5, 1.0, 1.0)` and no PASS/NEGATIVE marker, Parse Error, SCRIPT ERROR, ObjectDB or RID/geometry leak warning. Separated stdout/stderr files are in `review-r21-independent/`. Literal readback detects changed initial dimension rather than re-deriving its expected value.

**Adverse limits:** The first author attempt (`LOG.md`, `20261013T053120219108Z`) mistakenly required literal false in `.tscn`; Godot actually omits the default and the corrected check is now independently confirmed. Marker dimensions and identity labels are hardcoded after assertions, not raw telemetry. Evidence concerns one saved BoxMesh scene in this headless Godot build, not original separately spawned-source mutation, arbitrary scene/resource formats, rendering/GPU output, other engine versions or general crash/process-tree coverage. Depth improves relative to in-memory r20 and the untested-resource-identity disk r18; coverage and calibration have no demonstrated new improvement or harm.

<!-- r106-seat45-receipt-note -->

> **Non-resolvable receipt note (r106, 2026-10-18, SEAT-45).** Re-checked 2026-10-18: each path below is a concrete `corpus/live/runs` receipt cited in this lesson. The cited path is absent (`test -e` failed) and no durable copy exists under `reports/` (no receipt artifact whose path or `started_utc` is that run id; a prose mention is not a copy). Quoted receipt SHA-256 values on these lines do not match any tracked file or any `reports/` receipt artifact. `corpus/.gitignore` ignores `live/`, so these paths were never tracked. Historical sentences above are unchanged. Register: `reports/round-106/consistency/receipts.md`.
>
> - `corpus/live/runs/20261013T053240636367Z/verdicts.json`
> - `corpus/live/runs/20261013T053240636908Z/verdicts.json`
> - `corpus/live/runs/review-r21-independent/{local`
