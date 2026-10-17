# shokunin-3d-engines

3D game production, checked by executable headless fixtures: movement and
collision, spatial queries, camera projection and frustum, scene
structure and instancing, transform composition, input-driven mechanics,
and headless determinism.

The lane id is `game-dev-3d`. Rank is shonen. There is no root `SKILL.md`;
the working expertise is `PROVINCE.md`, the fixture corpus, and `reports/`.

## The job

`PROVINCE.md` names the engines the lane will validate on its shonen
path: Godot, Unity, Unreal Engine, three.js, and further 3D tooling once
a round has actually validated it. The standing host fact recorded at
mint: Godot 4.7.2 headless is the executable runtime; Unity and Unreal
editors are not installed; three.js runs under node for scene-graph and
math fixtures without a GL context. Where an engine cannot execute
headless here, the lane builds format-level and static fixtures and
labels runtime behavior unproven.

REA is a supporting evidence source for static inspection of exported
binaries, asset containers, and serialized scenes, under the
observation / inference / unknown split. Reverse engineering as an end
in itself, and live-target runtime evidence, belong to revenger.

The lane refuses engine or editor source mutation, publishing and store
submission, asset-rights clearance, narrative canon (lore), and 2D
product surfaces (game-dev-2d). Shared fixture patterns may be inherited.
2D product work is not.

Engine census and execution reality: `corpus/knowledge/engines.md`.

## Run the Godot battery

`corpus/fixtures/run_battery.py` runs the read-only Godot fixtures
serially in an isolated scratch project. Seeds in that directory are
never edited: every case runs against a copy under
`corpus/live/runs/<ts>/scratch`, and the run records a SHA-256 map of
the seeds before and after. A mutated seed fails the battery.

```sh
python3 corpus/fixtures/run_battery.py
```

The battery exits 0 only when every case passes. It needs the Godot
headless binary the province names. three.js cases live under
`corpus/fixtures/three/` and are invoked by the `run_*.mjs` drivers
beside them. Format-level checkers for captured artifacts sit in
`corpus/artifacts/` (`glb`, `unity`, `unreal`, `zip`).

## Read this first

1. [`PROVINCE.md`](PROVINCE.md) — engines, the host fact, the refusals.
2. [`corpus/README.md`](corpus/README.md) — what the fixture corpus is for.
3. [`corpus/knowledge/engines.md`](corpus/knowledge/engines.md) — which engines actually execute here.
4. [`SHONEN.md`](SHONEN.md) — the promotion checklist. Still present.

## On disk

| Path | Role |
|---|---|
| `PROVINCE.md` | Boundary. |
| `corpus/fixtures/` | Godot battery, three.js cases, bpy probes. |
| `corpus/artifacts/` | Static checkers for glTF, Unity, Unreal, and zip carriers. |
| `corpus/knowledge/`, `corpus/lessons/` | Census, provenance, per-round lessons. |
| `reports/` | Verifier and adjudicator reports. |
| `SCORECARD.md`, `LOG.md` | Axis verdicts and the audit trail. |
| `SHONEN.md` | Promotion checklist. |

## Fleet

Protocol and roster: [shokunin](https://github.com/VeigaPunk/shokunin).
Roster id `game-dev-3d`, repository name `shokunin-3d-engines`, rank **shonen**.
The 2D sibling is [shokunin-godot-2d](https://github.com/VeigaPunk/shokunin-godot-2d).
Canon is [shokunin-world-bible](https://github.com/VeigaPunk/shokunin-world-bible).
