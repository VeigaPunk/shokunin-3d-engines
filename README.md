# shokunin-3d-engines

3D game production, proved by headless fixtures.

This is the game-dev-3d lane. A behavior is in the craft record when a
fixture exits the way its header says, on a copy of the seed, with the
seed bytes unchanged. Where an engine cannot run headless, the lane builds
format-level and static fixtures and labels runtime behavior unproven.

Rank: **shonen**. `SHONEN.md` is still here. Registered in the fleet
`MANIFEST.json` as game-dev-3d-shokunin since 2026-10-11. There is no
`SKILL.md` in this checkout. The distilled record is the battery, the
lessons, and `corpus/knowledge/`.

## Province

**Owns.** 3D movement and collision, spatial queries, camera projection
and frustum behavior, scene structure and instancing, transform
composition, input-driven 3D mechanics, and headless determinism. Engines
named by the province: Godot, Unity, Unreal, three.js, and further 3D
tooling the lane validates. REA is a supporting source for static
inspection of exported artifacts, under the observation / inference /
unknown split.

**Hands off.** Engine and editor source. Publishing and store submission.
Asset-rights clearance. Harness auditing as an end in itself. Narrative
canon (lore). 2D product surfaces (game-dev-2d). Reverse engineering as
an end in itself, and live-target runtime evidence (revenger). DRM
circumvention. Publishing reversed material.

The province's standing host fact at mint: Godot 4.7.2 headless is the
executable runtime; Unity and Unreal editors are not installed; three.js
runs under Node for scene-graph and math fixtures without a GL context.
`corpus/knowledge/engines.md` is the census. Re-read it before treating
that host fact as current.

## Start here

1. `PROVINCE.md` — the boundary.
2. `corpus/README.md` — what the battery is for, and the predecessor suite.
3. `corpus/fixtures/run_battery.py` — Godot cases. Seeds are copied; the
   module docstring says a mutated seed fails the battery.
4. `corpus/fixtures/three/` — Node / three.js cases.
5. `corpus/knowledge/` and `corpus/lessons/` — the claim and the round
   that measured it.
6. `SCORECARD.md` — owned axes are depth, coverage, and calibration, and
   the card says those scores stay unassigned. The verdict tables are
   `improved locally` / `unchanged` style judgments with a report path.
   Read the latest round section, not the mint row.

## Run a battery

Godot, from the repository root, with a Godot binary on the path you pass:

```sh
python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot
```

The module docstring is the exit contract: a case passes on exit 0 plus
an exact `PASS` marker, or on an intended negative's exit 2 plus
`NEGATIVE REJECTED`. The battery exits 0 only when every case passes.
Scratch lives under `corpus/live/runs/`. Relative `--runs` paths resolve
from the current working directory.

Node layer cases:

```sh
node corpus/fixtures/three/run_layer_cases.mjs
```

That runner hashes its own seeds before and after. The scorecard's note
on the layer cases bounds them to CPU raycaster mask selection, not
rendered visibility.

## The tree

| Path | What it is |
|---|---|
| `corpus/fixtures/` | Godot battery and seeds |
| `corpus/fixtures/three/` | three.js cases |
| `corpus/artifacts/` | Static samples (glTF, Unity, Unreal) with their own READMEs |
| `corpus/knowledge/` | Engine census, seed provenance |
| `corpus/lessons/` | Per-round claims and non-author replays |
| `corpus/predecessor/` | Inherited games-engine-mechanics suite |
| `reports/` | Verifier and adjudicator reports |
| `corpus/live/` | Run receipts |

## Fleet

Minted under [shokunin](https://github.com/VeigaPunk/shokunin).
