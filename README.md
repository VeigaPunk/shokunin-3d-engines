# shokunin-3d-engines

**3D game production, verified by executable headless fixtures — or
honestly labeled unproven.**

Lane name: **game-dev-3d-shokunin**. A **shokunin lane** minted and
trained under the [shokunin](https://github.com/VeigaPunk/shokunin)
skill.

**Wiki:** [lane overview](https://app.devin.ai/org/veigapunk/wiki/VeigaPunk/shokunin-3d-engines?branch=main)

## Domain

From `PROVINCE.md`: 3D movement and collision, spatial queries, camera
projection and frustum behavior, scene structure and instancing,
transform composition, 3D input-driven mechanics, headless determinism
— across Godot, three.js, Unity, Unreal, and any further 3D tooling the
lane discovers and validates.

Engine census and execution reality live in `corpus/knowledge/engines.md`.
Standing host fact at mint (do not silently update):

| Engine | On this host |
|---|---|
| Godot 4.7.2 headless | installed — the executable runtime |
| three.js | runs under node for scene-graph / math fixtures, no GL context |
| Unity / Unreal editors | not installed |

Where an engine cannot execute headless, the lane builds format-level
and static fixtures (scene/asset containers, projection math,
serialization round-trips, REA inspection) and labels runtime behavior
**unproven** — never fabricating runtime evidence.

REA tooling is a supporting evidence source for *static* inspection of
3D artifacts, under the observation / inference / unknown discipline
revenger established. It is not live-target reverse engineering.

## What it refuses

Engine/editor source mutation; publishing or store submission; asset
rights clearance; harness/evidence auditing; narrative canon
([lore](https://github.com/VeigaPunk/shokunin-world-bible) — contested
scope is reported, not absorbed); 2D product surfaces
([game-dev-2d](https://github.com/VeigaPunk/shokunin-godot-2d) — shared
fixture patterns are inherited); reverse engineering as an end in itself
([revenger](https://github.com/VeigaPunk/shokunin-binary-forensics)).

Installing new engines is allowed only within a declared round scope
with operator-visible setup receipts.

## In this repository

```
PROVINCE.md     engine census + write fence
SHONEN.md  SCORECARD.md  LOG.md
corpus/
  knowledge/     engines.md, seed.md
  fixtures/      round batteries (incl. three/)
  artifacts/     glb-r12, unity-r19, unreal-r22
  predecessor/   seeded from games-engine-mechanics r15
  lessons/
reports/
```

This lane is still in shonen seed form — distilled `SKILL.md` is absent;
the corpus is the craft record.

## How a lane learns

Append-only corpus; every claim separates observation / inference /
unknown; rounds are non-author-verified. See the fleet
[README](https://github.com/VeigaPunk/shokunin#readme).
