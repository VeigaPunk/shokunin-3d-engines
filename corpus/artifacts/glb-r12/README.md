# Round 12 — Godot headless GLB import contrast

From the repo root run:

```sh
python3 .shokunin/game-dev-3d/corpus/artifacts/glb-r12/run_import.py
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py
node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs
```

`run_import.py` creates three ignored isolated scratch Godot projects and copies only authored `project.godot`, `inspect_import.gd` and one `triangle.glb` into each. It executes `godot --headless --editor --import --path <scratch>` then `godot --headless --path <scratch> --script res://inspect_import.gd`; full per-process stdout/stderr, exits and seed hashes are in `corpus/live/runs/r12-import-<timestamp>/verdicts.json`. No source-seed edits or rendering.

| GLB bytes | Editor exit / stderr | Script exit | imported scene / mesh |
|---|---|---:|---|
| r9 valid 532B triangle | 0 / silent | 0 | root triangle, TriangleNode MeshInstance3D at (2,0,-3), 1 surface/3 vertices |
| r11 header length 531, physical 532 | 0 / silent | 0 | same observed mesh, tolerated by Godot |
| r12 four bytes `glTF`→`BAD!` | **0 / glTF parse + import errors** | **2** | no PackedScene / `.scn` |

The rejected file differs from the valid GLB at offsets 0–3 only. Engine reports failed glTF JSON parsing of BAD!, not a proven specific magic-header branch. Editor exit 0 and `[ DONE ]` are **not** success criteria; script load and stderr decide. The first runner draft incorrectly searched stdout for editor errors and failed; LOG records it. Named non-author replay and limits: `corpus/lessons/r12-import-review.md`. Nothing here proves rendered output, broad invalid-GLB rejection, other-engine import or REA GLB semantics.
