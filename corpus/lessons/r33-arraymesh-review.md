# Round 33 named non-author procedural ArrayMesh review

**Verdict: bounded coverage improvement; depth and calibration unchanged.** Independent replay validates one CPU-visible procedural `ArrayMesh` surface attached to a live `MeshInstance3D` and a shifted-vertex control. The authored planar triangle is in XY (all Z=0); it is not a noncoplanar triangle or proof of GPU drawing.

## Reproduction and baseline compatibility

From repository root, Godot `/usr/bin/godot` reports `4.7.2.stable.arch_linux.ed1daf0bf`:

```sh
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only mesh3d_array,mesh3d_array_shifted
```

The first command exits 0: **45/45 seeded cases**, 21 ordinary and 24 negative controls, plus **4/4 opt-in probes PASS**, with before/after seed hashes identical. Its receipt is `corpus/live/runs/20261013T062810849525Z/verdicts.json` (SHA-256 `95a309a588fea390fca47647db2c014a5b1fe052b9e42d36d583eee2a560ff3b`). The separate pair exits 0: **2/2** (ordinary exit 0, shifted negative exit 2); receipt `corpus/live/runs/20261013T062835815584Z/verdicts.json` (SHA-256 `8471430ad22c5baf614a70974dea1c6f26273041ecf93a9c90ca2a9d4f15adfa`). All two pair records match the full run's selected exact fields. The four probe receipts (`tree-timeout`, `crash-exit`, `stream-attribution`, `mutation`) individually say PASS; their SHA-256 values are:

- `tree-timeout-verdicts.json` `25dc8f149cc58177c3dc6bef8a7eadcaa04388381ea528d963b97b4572ba50cc`
- `crash-exit-verdicts.json` `553738e1e9f2afd97ed75494d4c2b0db56f7e4e9c00ee4eeb1c51df586bf5323`
- `stream-attribution-verdicts.json` `a29417d8e2d623abf5aa9de7f0fa966d1cffcdfd0cdff30b4290a8ee1d4dcc52`
- `mutation-verdicts.json` `01061bbfda82ee3782570f276bce0ff068b252c1e4a330ee32e306ae560063a3`

The previous r32 full receipt `corpus/live/runs/20261013T062352175533Z/verdicts.json` (43/43; SHA-256 `d539cab6e7a8b96e46598dbddf7b255f4ab0f446984c55fbce272d956979c28c`) compares by case name, **not row index**: all 43 prior case records' `case/script/flags/expected_exit/actual_exit/error/kind/marker/verdict/reasons/stdout/stderr` fields are byte-for-byte/equality identical. Command scratch paths and elapsed seconds naturally differ. No prior seed hash disappeared or changed except the declared README and runner:

| seed | previous SHA-256 | current SHA-256 |
|---|---|---|
| `README.md` | `84452475d28664f1e1269793c02cd22f8405fd87aff70a628c7bf06c83eaca00` | `5e2d24de9d5ba2426d072fc9f3f99c5ab7207f5f25ad3168eff83fd8edd42429` |
| `run_battery.py` | `4afb54d3e62b36a0c12c3837d6f016acadcb386362aabc81f3430721651ee3b3` | `6c97a593defae82d8f6819aba623aac614b3fe2055031bc33ded93e7b4e9d698` |

New `mesh3d_array.gd` SHA-256 `8dcbf29d6739d43787f47a221645e6226853b369ec38a47d721df06e66bae6cd`. All other 28 old seed hashes are identical. The new cases have exact stdout marker lines `PASS mesh3d_array triangle last_z=0.000 aabb_size=2.000,3.000,0.00001` and `NEGATIVE REJECTED: mesh3d_array shifted_vertex last_z=1.000 aabb_size=2.000,3.000,1.000`, after Godot banner and blank line, with empty stderr. Those markers are fixed literals, **not measured diagnostic telemetry**; the runtime checks precede printing them.

## Source/readback and private mutation

`mesh3d_array.gd` constructs an `ArrayMesh` surface from exactly three authored `PackedVector3Array` vertices `(0,0,0), (2,0,0), (0,3,0)` or shifted `(0,3,1)`, with `Mesh.PRIMITIVE_TRIANGLES`, then assigns it to a child of the live root as `MeshInstance3D.mesh`. It checks one surface, primitive type, `instance.mesh == mesh`, count and all three actual `surface_get_arrays(0)[Mesh.ARRAY_VERTEX]` vertices. Both `mesh.get_aabb()` and `instance.get_aabb()` must have origin `(0,0,0)` and identical measured bounds. The planar AABB's Z size `0.00001` is Godot's observed small expansion, **not an authored Z extent**; the shifted vertex Z1 gives AABB Z size 1. The fixture tests size X2/Y3 and exact instance/mesh AABB equality. It has no rendering, GPU-buffer, pixel, collision-mesh, winding-visibility, or manifold-topology assertion.

In ignored `corpus/live/runs/r33-private-arraymesh-review/`, I copied the seed project and only changed the authored planar third vertex's expression:

```diff
-Vector3(0, 3, 1 if shifted else 0)
+Vector3(0, 3, 1 if shifted else 2)
```

Only one occurrence was replaced; reversing it restores the exact seed bytes. Script SHA-256 seed `8dcbf29d6739d43787f47a221645e6226853b369ec38a47d721df06e66bae6cd`, mutant `31f28c7a5213975d35bf5c79e48320a682907322d53de4c7a082945db9e74230`. Run ordinary arm:

```sh
/usr/bin/godot --headless --path .shokunin/game-dev-3d/corpus/live/runs/r33-private-arraymesh-review --script res://mesh3d_array.gd > .shokunin/game-dev-3d/corpus/live/runs/r33-private-arraymesh-review/mutant.stdout 2> .shokunin/game-dev-3d/corpus/live/runs/r33-private-arraymesh-review/mutant.stderr
# exit 1
```

Its stdout is only the Godot banner/blank line (SHA-256 `1fb0f12cefe41f881cb436e6731d981084b95f8db9b1d6f3e25ac930f360a32e`); stderr (SHA-256 `5f3e9a880de3f864aadec35deaeb2eeae7caeef460e364fd432e86333408ac1e`) reports `ERROR: mesh3d_array: vertex readback mismatch last=(0.0, 3.0, 2.0)` with the `_run` line 23 and `_fail` backtrace. **This is not a setup failure:** the surface count, primitive, attachment, count and first two vertices passed; the third readback observed the changed Z2. No parse error, `SCRIPT ERROR`, ObjectDB leak, or PASS marker. Bounds assertion is downstream and was **not reached**; this mutation does not independently prove that a changed bound alone would reject.

## Scope and axis judgment

**Coverage improved** from r32's absence of explicit procedural mesh construction to this one headless Godot 4.7.2 surface, vertex readback, and live instance/mesh AABB pair; **depth unchanged** (single three-vertex surface and one shifted control); **calibration unchanged** (same exit/marker classifier and probes). Accept only that bounded readback/API claim. The r33 declaration's “noncoplanar-in-XY” wording is best read as a planar XY triangle with noncollinear XY vertices; it is not noncoplanar 3D geometry. AABB expansion is engine behavior, not proof of triangle volume or pixels.
