# shokunin-3d-engines

3D game production, verified by executable headless fixtures.

Lane id: **game-dev-3d-shokunin**. Rank: **shonen**. [`SHONEN.md`](SHONEN.md)
has one box checked by an independent reviewer (the round-2 battery
replay). The other boxes are open. There is no root `SKILL.md` yet; the
distilled craft is in `corpus/knowledge/` and `corpus/lessons/`.

Fleet: [shokunin](https://github.com/VeigaPunk/shokunin).

## The question

> Does this 3D mechanic hold under a headless fixture with a
> discriminating negative control — and, where the engine cannot run
> here, what can still be shown from the file format alone?

Owned surfaces, from `PROVINCE.md`: 3D movement and collision, spatial
queries, camera projection and frustum, scene structure and instancing,
transform composition, input-driven 3D mechanics, and headless
determinism. Engines in scope: Godot, Unity, Unreal, three.js, and
further 3D tooling the lane validates on its shonen path.

Standing host fact recorded at mint: Godot 4.7.2 headless is the
executable runtime. Unity and Unreal editors are not installed. three.js
runs under Node for scene-graph and math fixtures without a GL context.
Where an engine cannot execute, the lane builds format-level fixtures and
labels runtime behavior unproven.

## Boundary

Engine and editor source stays unmodified. Publishing and store
submission stay outside. Asset-rights clearance, harness auditing, and
narrative canon stay outside (lore). 2D product surfaces belong to
[shokunin-godot-2d](https://github.com/VeigaPunk/shokunin-godot-2d).
Reverse engineering is a supporting static inspection of 3D artifacts,
under the observation / inference / unknown split. It is not an end in
itself, and it is not live-target execution. Domain source trees are
read-only.

## Run

Godot battery. Seeds are copied to an ignored scratch run; a mutation of
a seed fails the battery. Default `--godot` is `/usr/bin/godot` when that
path exists.

```sh
python3 corpus/fixtures/run_battery.py
```

`--only` takes a comma-separated case list. `--probe-failing` and the
other `--probe-*` flags are declared in the argparse block near the
bottom of that file.

three.js cases live in `corpus/fixtures/three/`. The census records
`node corpus/fixtures/three/run_cases.mjs` as the scene-graph run;
`run_camera_cases.mjs`, `run_ray_cases.mjs`, and the layer and
orthographic runners sit beside it. Format checks that do not launch an
editor, and that default to the sample next to the script:

```sh
python3 corpus/artifacts/glb-r9/validate_glb.py
python3 corpus/artifacts/unity-r19/verify_scene.py
python3 corpus/artifacts/unreal-r22/verify_descriptor.py
```

The module docstrings bound these: local GLB static check, not REA
evidence; Unity-style scene reference check, not a Unity import; `.uplugin`
field check, not Unreal Editor or UBT. `corpus/README.md` is the layout
guide: `fixtures/`, `predecessor/` (inherited games-engine-mechanics
patterns), `knowledge/` (census and provenance), `lessons/`, `reports/`.

## Map

| Path | What it is |
|---|---|
| [`PROVINCE.md`](PROVINCE.md) | owned mechanics and refusals |
| [`corpus/knowledge/engines.md`](corpus/knowledge/engines.md) | engine census, maintained by the lane |
| [`corpus/fixtures/run_battery.py`](corpus/fixtures/run_battery.py) | Godot battery |
| [`SHONEN.md`](SHONEN.md), [`SCORECARD.md`](SCORECARD.md), [`LOG.md`](LOG.md) | probation, verdicts, audit trail |

A fixture that cannot execute on this host is labeled unproven. It is not
filled in with a guessed runtime result.
