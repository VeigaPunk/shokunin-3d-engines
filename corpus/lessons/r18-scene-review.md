# Round 18 — independent scene-file review (non-author)

Scope: `.shokunin/game-dev-3d/PROVINCE.md`, `LOG.md` round 18, `corpus/README.md`, `corpus/fixtures/README.md`, `scene3d_disk.gd` and `run_battery.py`. Read-only implementation; only this review and ignored `corpus/live/runs/` receipts were written. Godot `4.7.2.stable.arch_linux.ed1daf0bf`, Linux headless. No push or merge.

## Independent replay

From repository root:

```sh
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only scene3d_disk,scene3d_disk_wrong_local
```

First receipt: `corpus/live/runs/20261013T051450833462Z/verdicts.json`: exit 0, **25/25 PASS**, 12 ordinary/13 negative, seed hashes unchanged. Both new arms exit 0/2, with their exact markers on stdout, empty stderr, null error and empty reasons. Four uncounted probes PASS in that directory: `tree-timeout-verdicts.json` (logical timeout null exit, cleanup -9, verified witness gone), `crash-exit-verdicts.json` (normal exit 1 versus marked-live SIGTERM exit -15), `stream-attribution-verdicts.json` (both exit 0/identical stdout, stderr-only diagnostic rejected), `mutation-verdicts.json` (box depth mutant exit 1 with expected contact-plane mismatch). Paired receipt: `corpus/live/runs/20261013T051450833253Z/verdicts.json`: exit 0, **2/2 PASS**, same exact exits/streams and unchanged seed hashes.

Compared the full receipt with r17 `corpus/live/runs/20261013T051126079226Z/verdicts.json`: all **23 prior raw** case stdout lines, stderr lines, exit, error, expected marker, reasons, flags, kind and verdict equal. Only README and runner digests changed among prior seeds (`README.md` e29be2c6…→c420d4e3…, `run_battery.py` e96e80ed…→f6facbe8…); new `scene3d_disk.gd` SHA-256 `95f53495cbcf2aab082af23b75fa0d9ba5db344f3f858352c3364a115c41c207`. Both runs independently recorded `seeds_unchanged=true`.

## Scene text, runtime and adverse mutation

Actual paired-run negative file `corpus/live/runs/20261013T051450833253Z/scratch/generated-scene3d.tscn` contains a Node3D `DiskRoot`, owned MeshInstance3D `BoxVisual`, `[sub_resource type="BoxMesh"]`, `mesh = SubResource("BoxMesh_rmhlu")`, and `transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 2, 2, -3)`. A separately run positive at `corpus/live/runs/review-r18-positive-text/scratch/generated-scene3d.tscn` has corresponding transform `(…, 1, 2, -3)`; that separate run also has different Godot-generated node `unique_id`s, so comparing different runs is **not** evidence of a one-field-only edit. For an exact within-one-file check, a fresh positive Godot exit 0 generated `corpus/live/runs/review-r18-same-project/positive-scene-before-edit.tscn`; copying its text and replacing the sole child transform X `1`→`2` yielded `corpus/live/runs/review-r18-same-project/scratch/generated-scene3d.tscn`. Unified diff has **only that transform line** changed; root/child names/types/IDs and BoxMesh resource line are identical. This latter copy check directly verifies text change; the paired fixture's negative actual Godot exit 2, exact `loaded_world=12.000,2.000,2.000` marker and empty stderr verify runtime loading of its rewritten file (no parse or missing-resource failure).

Private copied-source mutant at `corpus/live/runs/review-r18-private-mutant/scratch/scene3d_disk.gd` differs from seed solely `const CHILD_LOCAL := Vector3(1, 2, -3)` → `Vector3(2, 2, -3)`; diff in `mutant-diff.txt`. Reproduce:

```sh
/usr/bin/godot --headless --path "$PWD/.shokunin/game-dev-3d/corpus/live/runs/review-r18-private-mutant/scratch" --script res://scene3d_disk.gd --
```

Actual exit **1**, Godot banner only on stdout (no PASS); stderr `ERROR: scene3d_disk: loaded transform mismatch local=(2.0, 2.0, -3.0) world=(12.0, 2.0, 2.0)` plus only push_error location/backtrace. No Parse Error, missing-file/resource report, ObjectDB/RID/geometry leak diagnostic. Captured separated raw streams as `mutant.stdout`/`mutant.stderr` in that ignored directory. The local/world shift is attributable to the authored X change; a literal positive expected local `(1,2,-3)`/world `(11,2,2)` catches it.

Source specificity: `source.add_child(child); child.owner = source` precede `PackedScene.pack`, `ResourceSaver.save` writes scratch `.tscn`; text must contain the generated source-dependent transform exactly once and `BoxVisual`. Negative replaces exactly this transform using `% int(CHILD_LOCAL.x)` and `+1`, **not** an independently authored corrupt text fixture. `ResourceLoader.load(..., "PackedScene", ResourceLoader.CACHE_MODE_IGNORE)` deliberately bypasses any stale saved-scene cache; `instantiate`, loaded `BoxVisual` and non-null mesh are checked, along with source child identity and its unchanged literal local position. Positive/negative compare loaded local/world to separate literal expectations and negative additionally rejects proximity to original world. `_cleanup` frees source/instance on successful branches and `_fail`, consistent with clean stderr in the mutant. The `source_intact`, `mesh_present` and world values in success markers are **hardcoded labels**, not formatted observed telemetry; claims rest on preceding checks. Mesh identity, mesh geometry dimensions, source mesh preservation beyond the source-child identity/non-null initial assignment, visual rendering and general serialization invariants are not proven.

**Finding:** no acceptance blocker on the declared narrow coverage move: authored text-scene disk save/load with one intact mesh-bearing child and a loadable one-translation negative, independently replayed without regression. Depth/calibration remain unchanged. REA/static reversing and GPU rendering are irrelevant to this Godot runtime serialization check.

<!-- r106-seat45-receipt-note -->

> **Non-resolvable receipt note (r106, 2026-10-18, SEAT-45).** Re-checked 2026-10-18: each path below is a concrete `corpus/live/runs` receipt cited in this lesson. The cited path is absent (`test -e` failed) and no durable copy exists under `reports/` (no receipt artifact whose path or `started_utc` is that run id; a prose mention is not a copy). Quoted receipt SHA-256 values on these lines do not match any tracked file or any `reports/` receipt artifact. `corpus/.gitignore` ignores `live/`, so these paths were never tracked. Historical sentences above are unchanged. Register: `reports/round-106/consistency/receipts.md`.
>
> - `corpus/live/runs/20261013T051450833462Z/verdicts.json`
> - `corpus/live/runs/20261013T051450833253Z/verdicts.json`
> - `corpus/live/runs/20261013T051450833253Z/scratch/generated-scene3d.tscn`
> - `corpus/live/runs/review-r18-positive-text/scratch/generated-scene3d.tscn`
> - `corpus/live/runs/review-r18-same-project/positive-scene-before-edit.tscn`
> - `corpus/live/runs/review-r18-same-project/scratch/generated-scene3d.tscn`
> - `corpus/live/runs/review-r18-private-mutant/scratch/scene3d_disk.gd`
> - `corpus/live/runs/review-r18-private-mutant/scratch`
