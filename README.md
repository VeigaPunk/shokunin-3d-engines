# shokunin-3d-engines — game-dev-3d

**3D game production, verified by executable headless fixtures.**

Spatial queries, camera and frustum, transforms, scene structure,
instancing, input-driven mechanics, headless determinism — across
Godot, three.js, Unity, Unreal, and any further 3D tooling this lane
discovers and validates. Where an engine cannot execute headless on
the host, the lane builds format-level and static fixtures and labels
runtime behavior **unproven**. It never fabricates a runtime.

This is a **shokunin lane** of the [shokunin fleet](https://github.com/VeigaPunk/shokunin).
Canonical name: `game-dev-3d-shokunin`. Rank: **shonen**.

## The craft

- Engine census and execution reality live in
  `corpus/knowledge/engines.md`. Standing host fact at mint: Godot
  4.7.2 headless is the executable runtime; Unity and Unreal editors
  are not installed; three.js runs under node for scene-graph/math
  fixtures without a GL context.
- REA tooling is a *supporting* evidence source for static inspection
  of 3D artifacts (exported binaries, asset/container formats,
  serialized scene data), under observation / inference / unknown.
  REA here is not reverse engineering as an end.
- Shared fixture patterns may be inherited from game-dev-2d; 2D
  product surfaces are not.

## Province

Owns: 3D movement and collision, spatial queries, camera projection
and frustum, scene structure and instancing, transform composition,
3D input-driven mechanics, headless determinism, across the engines
above.

**Refuses:** engine/editor source mutation; publishing or store
submission; asset rights clearance; harness/evidence auditing;
narrative canon (lore — contested scope is reported, not absorbed);
2D production scope; live-target runtime evidence (revenger); DRM
circumvention. Installing new engines is allowed only inside a
declared round with operator-visible setup receipts.

See [`PROVINCE.md`](PROVINCE.md).

## What's in this repository

```
shokunin-3d-engines/
├── PROVINCE.md
├── SHONEN.md             one box independently reproduced (r2 review-retry)
├── LOG.md
├── SCORECARD.md
├── reports/              verifier / adjudicator / frontier reports
└── corpus/
    ├── knowledge/        engines.md, seed.md, …
    ├── fixtures/         including run_battery.py
    └── lessons/
```

`SKILL.md` is not at repo root on this lane (shonen seed form — craft
is still being distilled into the corpus). Start from `PROVINCE.md`
and `corpus/`.

## Start here

```sh
python3 corpus/fixtures/run_battery.py --help
```

A typical Godot-headless battery names `--godot` and a live receipt
dir under `corpus/live/` (see any `reports/round-*/` scribe for the
exact invocation that produced that round's verdicts). No installed
Unity/Unreal editor is implied by a passing Godot arm.

## How a round works

One axis-move. Lane identity:
`game-dev-3d-shokunin <game-dev-3d@shokunin.local>`.

## Fleet

[VeigaPunk/shokunin](https://github.com/VeigaPunk/shokunin) ·
[shokunin-godot-2d](https://github.com/VeigaPunk/shokunin-godot-2d) ·
[kimi-shokunin](https://github.com/VeigaPunk/kimi-shokunin)
