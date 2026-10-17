# game-dev-3d-shokunin

Repo: `shokunin-3d-engines`.

**3D game production verified by executable headless fixtures** — movement
and collision, spatial queries, camera projection and frustum, scene
structure and instancing, transform composition, 3D input-driven
mechanics, headless determinism — across Godot, three.js, Unity, Unreal,
and any further 3D tooling the lane discovers and validates.

A **shokunin lane**: an expert agent for one domain, minted and trained
under the [shokunin skill](https://github.com/VeigaPunk/shokunin).
Rank: **shonen**. Promotion is a named non-author review of
[`SHONEN.md`](SHONEN.md), never self-attestation.

This lane answers: *does this 3D mechanic hold without a GPU window —
and where the engine cannot execute here, can we still pin a
format-level fixture without fabricating runtime evidence?*

## Domain

From [`PROVINCE.md`](PROVINCE.md): engine-neutral 3D craft. Standing host
fact at mint: **Godot 4.7.2 headless is installed** and is the executable
runtime; Unity and Unreal editors are not installed; three.js runs under
node for scene-graph/math fixtures without a GL context.

Where an engine cannot execute headless on this host, the lane builds
format-level and static fixtures (scene/asset containers, projection
math, serialization round-trips, REA inspection) and labels runtime
behavior **unproven**. Engine census: `corpus/knowledge/engines.md`.

REA tooling is a supporting evidence source for **static** inspection of
3D artifacts, under the observation/inference/unknown discipline
[revenger](https://github.com/VeigaPunk/shokunin-binary-forensics)
established. REA is not an end in itself here.

**Refuses:** engine/editor source mutation; publishing; asset rights
clearance; 2D product surfaces (→
[game-dev-2d](https://github.com/VeigaPunk/shokunin-godot-2d) — shared
fixture patterns are inherited, 2D product surfaces are not); narrative
canon (→ [lore](https://github.com/VeigaPunk/shokunin-world-bible));
live-target runtime evidence as RE.

Installing new engines is allowed only within a declared round scope
with operator-visible setup receipts.

## What's here

| Path | Role |
|---|---|
| [`PROVINCE.md`](PROVINCE.md) | owned 3D surfaces, engine reality, refusals |
| [`corpus/README.md`](corpus/README.md) | corpus purpose and layout |
| [`corpus/fixtures/`](corpus/fixtures/) | round-1 3D battery seeds + `run_battery.py` |
| [`corpus/fixtures/three/`](corpus/fixtures/three/) | three.js / node fixtures |
| [`corpus/artifacts/`](corpus/artifacts/) | GLB / Unity / Unreal format-level pins |
| [`corpus/predecessor/`](corpus/predecessor/) | inherited games-engine-mechanics suite |
| [`reports/`](reports/) | verifier / adjudicator reports |
| [`SCORECARD.md`](SCORECARD.md) · [`LOG.md`](LOG.md) · [`SHONEN.md`](SHONEN.md) | axes, trail, promotion |

(`SKILL.md` is still in shonen seed form — see `corpus/`.)

## The battery

```sh
python3 corpus/fixtures/run_battery.py
```

Seeds are copied to ignored scratch before execution. Each fixture
carries its reproduction command and expected exit signature in the
corpus docs. Failed fits are preserved as negative results under
`lessons/` and `live/runs/` — a rejection is evidence of taste.

## How a lane learns

Append-only corpus; every claim separates observation / inference /
unknown; rounds are non-author-verified. See the fleet
[README](https://github.com/VeigaPunk/shokunin#readme).
