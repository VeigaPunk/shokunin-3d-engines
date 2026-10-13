# Round 34 named non-author indexed ArrayMesh review

**Verdict: bounded depth improvement; coverage and calibration unchanged.** Independently reproduced CPU-visible indexed topology for one live Godot `ArrayMesh` quad and a reversed-index control. Neither the fixture nor this review measures GPU winding, backface culling, rasterization, pixels, generated vertex normals, or collision geometry.

## Independent reproduction and compatibility

From repository root, `/usr/bin/godot` reports `4.7.2.stable.arch_linux.ed1daf0bf`:

```sh
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only mesh3d_indexed,mesh3d_indexed_reversed
```

Both exit 0. The full run is **47/47** (22 ordinary, 25 negative controls) plus **4/4 opt-in probes PASS**, unchanged seeds before/after; receipt `corpus/live/runs/20261013T063353862680Z/verdicts.json`, SHA-256 `8c513b633abbf18531054460c827a8cda37d329889d396ea0bb9477476aa446f`. Probe receipt hashes, all verdict PASS: tree-timeout `e9394c492ed6776e6b8d654fb0d797f71670e455a6dc1e9f74016e9e956453ce`, crash-exit `4a7bec608c9b34b05bd755049a0d329aa3842e71e684fa05c1b68177c43e06f2`, stream-attribution `f9559348c6bad4193c15a05cdd94986da40645538624e22b5902f8d74b38913e`, mutation `6e1c361596d647e7fe8f57f896d2aaf09f199f722d662f5f0c03267cb8a529e6`. The pair is **2/2** (forward exit 0, reversed exit 2); receipt `corpus/live/runs/20261013T063353862202Z/verdicts.json`, SHA-256 `9b5f57d236e2e9348f1a55be77e9bf51ed27903bee4272aa7bb1a22f0a4dd354`. Pair and full raw records match on `case/script/flags/expected_exit/actual_exit/error/kind/marker/verdict/reasons/stdout/stderr`; no unexpected stderr. Scratch command paths and elapsed times differ.

Compared by name with r33's 45/45 full receipt `corpus/live/runs/20261013T062810849525Z/verdicts.json` (SHA-256 `95a309a588fea390fca47647db2c014a5b1fe052b9e42d36d583eee2a560ff3b`), **all 45 old case records have identical exact fields** listed above. All prior seed hashes match except the declared README `5e2d24de9d5ba2426d072fc9f3f99c5ab7207f5f25ad3168eff83fd8edd42429` → `82889cb446b89868282bc4ab85f38e2e0b06b555dfc473347851f40f50714d17` and runner `6c97a593defae82d8f6819aba623aac614b3fe2055031bc33ded93e7b4e9d698` → `75abc5c8949f775f2f98f2b35713e2afeefa1a02933eac894414d4a08db78838`. No old seed removed. Added `mesh3d_indexed.gd` SHA-256 `14ce1bae6d7b6a4cfea2aa01a5aa7e4e0a5a10cf58f537339b3e229c738f40a6`. Pair/full seed maps also match. The new case stdout markers are fixed authored lines following assertions, not measured telemetry.

## Source/readback and private sensitivity

`mesh3d_indexed.gd` supplies four vertices `(0,0,0),(2,0,0),(2,3,0),(0,3,0)` and six indices `[0,1,2,0,2,3]`, or reversed `[0,2,1,0,3,2]`, to `Mesh.PRIMITIVE_TRIANGLES`. It attaches the resulting `ArrayMesh` to a root-child `MeshInstance3D`. It checks one surface, primitive, attached mesh, **all four returned vertices**, six returned index entries against a separate literal, and two signed cross products **computed from those returned vertices and indices**. Both forward triangles have cross Z+6; both reversed triangles have Z-6. Each triangle area is 3 square units by half the cross magnitude, inferred from the asserted cross; the fixture does not separately call an area API. Both arms check mesh AABB origin `(0,0,0)`, size approximately `(2,3,0.00001)` and exact equality with instance AABB. The tiny Z extent is Godot's planar AABB expansion, not geometric volume. Surface vertex count is established by the returned array length; no separate `surface_get_array_len` invocation occurs.

Private copies under ignored `corpus/live/runs/r34-private-index-review/` and `corpus/live/runs/r34-private-index-cross-review/` each copy `project.godot` and `mesh3d_indexed.gd`; **no seed modified**. First copy changes only forward authored `PackedInt32Array` selection:

```diff
-var indices := PackedInt32Array([0, 2, 1, 0, 3, 2] if reversed else [0, 1, 2, 0, 2, 3])
+var indices := PackedInt32Array([0, 2, 1, 0, 3, 2] if reversed else [0, 1, 2, 0, 3, 2])
```

Mutant script SHA-256 `cf64bad57635d1740307f532a04f84a4a0fa82302807fbb5bde2ce6b2c4118a4`. Ordinary-arm command:

```sh
/usr/bin/godot --headless --path .shokunin/game-dev-3d/corpus/live/runs/r34-private-index-review --script res://mesh3d_indexed.gd
```

Exit **1**, stderr `ERROR: mesh3d_indexed: index readback mismatch indices=[0, 1, 2, 0, 3, 2]` at `_run` line 31, after surface/vertex checks; stdout only engine banner/blank line. This measured returned-index guard **short-circuits before** cross and bounds assertions; it is not evidence that the first mutant independently reached cross validation.

To isolate downstream signed-cross behavior, the second private copy includes the *same authored mutation* **and only additionally** changes the forward literal in `expected_indices` from `[0, 1, 2, 0, 2, 3]` to `[0, 1, 2, 0, 3, 2]`; `expected_cross` stays forward Z+6. Second script SHA-256 `c8f82646807a018dcb064290f9a39e70334ae067074f80a47e64d20bbb86631c`. Command:

```sh
/usr/bin/godot --headless --path .shokunin/game-dev-3d/corpus/live/runs/r34-private-index-cross-review --script res://mesh3d_indexed.gd
```

Exit **1**, stderr `ERROR: mesh3d_indexed: triangle cross mismatch first=(0.0, 0.0, 6.0) second=(0.0, 0.0, -6.0)` at `_run` line 34. It passes index-exact readback and fails on independently computed second triangle signed cross while first remains +6. The battery sets `CASE_TIMEOUT_SECONDS=20` for its own case subprocesses; these direct private commands had no enforced timeout and each completed in <1 second locally. Redirection replays in each private directory yield identical stdout SHA-256 `1fb0f12cefe41f881cb436e6731d981084b95f8db9b1d6f3e25ac930f360a32e`; respective stderr SHA-256 `528dade3af068139e6a6db6f228746833ed9c485ca5ca8378de6b4923797fc1c` and `93502436d245f51eb9a90d8e192ac6a60f845e4213352331f8f2294b018c5f14`. Neither mutant has a PASS marker, parse error, `SCRIPT ERROR`, or ObjectDB leak. The bounds check remains downstream and is not mutation-isolated.

**Axis judgment:** depth improved over r33's unindexed one-triangle readback because two triangles reuse four vertices and an intact reverse-order control changes computed signed cross while preserving bounds. Coverage unchanged (same procedural ArrayMesh API family); calibration unchanged (same exit/marker classifier and four probes). This is a CPU-side topology/sample guarantee on Godot 4.7.2 only, not GPU face orientation or rendered appearance.
