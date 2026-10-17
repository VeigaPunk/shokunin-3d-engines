# shokunin-3d-engines — game-dev-3d-shokunin

**3D game production, verified by executable headless fixtures** —
spatial queries, camera / frustum, transforms, scene structure,
determinism — across Godot, three.js, Unity, and Unreal.

This is a [shokunin](https://github.com/VeigaPunk/shokunin) lane. Rank:
shonen. Canonical lane name: `game-dev-3d-shokunin`. Where an engine
cannot execute headless on this host, the lane builds format-level and
static fixtures and labels runtime behavior **unproven** — never
fabricating runtime evidence.

Standing host fact at mint (`PROVINCE.md`): Godot 4.7.2 headless is
installed and is the executable runtime. Unity and Unreal editors are
not installed. three.js runs under node for scene-graph / math fixtures
without a GL context. Engine census: `corpus/knowledge/engines.md`.

## Province

**Owns:** 3D movement and collision; spatial queries; camera projection
and frustum behavior; scene structure and instancing; transform
composition; 3D input-driven mechanics; headless determinism; REA as a
*supporting* evidence source for static inspection of 3D artifacts
(exported binaries, asset / container formats, serialized scene data).

**Refuses:** engine / editor source mutation; publishing or store
submission; asset rights clearance; harness / evidence auditing;
narrative canon (→ lore — contested scope is reported, not absorbed);
2D production scope (→ game-dev-2d — shared fixture patterns are
inherited, 2D product surfaces are not); reverse engineering as an end
in itself or live-target runtime evidence (→ revenger). Installing new
engines is allowed only inside a declared round with operator-visible
setup receipts.

Domain source trees are read-only. Full boundary:
[`PROVINCE.md`](PROVINCE.md).

## Start here

1. [`PROVINCE.md`](PROVINCE.md) — owned mechanics and the unproven-runtime rule.
2. [`corpus/README.md`](corpus/README.md) — coverage map and engine census pointer.
3. [`corpus/fixtures/run_battery.py`](corpus/fixtures/run_battery.py) — headless battery runner.
4. [`SHONEN.md`](SHONEN.md) — promotion checklist (deleted on promotion).

This lane is still in shonen seed form: distilled `SKILL.md` lives in
the corpus until promotion. `corpus/QUALITY.md` is the admission bar.

## Fixtures

```
python3 corpus/fixtures/run_battery.py
```

Additional probes live beside it (`bpy_battery.py`, `bpy_sync_probe.py`,
round-scoped child runners). A passing fixture proves the named
property on the named runtime. It does not prove Unity or Unreal
runtime behavior on a host that cannot execute those editors, and it
does not prove a shipping game.

## What's in the repo

```
shokunin-3d-engines/
├── PROVINCE.md       domain boundary + engine-install reality
├── SHONEN.md         promotion checklist
├── LOG.md            append-only audit trail
├── SCORECARD.md      axis verdicts
├── reports/          verifier / adjudicator reports
└── corpus/
    ├── README.md     coverage map
    ├── QUALITY.md    admission bar
    ├── knowledge/    engines.md, seed.md, …
    ├── lessons/      per-round lessons
    ├── fixtures/     headless batteries
    └── artifacts/    captured outputs
```

Protocol: append-only corpus; every claim separates observation /
inference / unknown; rounds are non-author-verified. See the fleet
[README](https://github.com/VeigaPunk/shokunin#readme) for how a lane
learns.
