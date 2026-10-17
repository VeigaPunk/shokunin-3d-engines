# shokunin-3d-engines — game-dev-3d

The question this lane answers is whether a 3D mechanic holds under an executable headless fixture: movement and collision, spatial queries, camera and frustum, scene structure, transforms, input-driven mechanics, and headless determinism (`PROVINCE.md`).

**Rank:** `SHONEN.md` is titled probation. One box is `[x]`, checked by the named non-author verifier `game-dev-3d-r2-review-retry` (`corpus/lessons/r2-independent-review.md`). The other three boxes are `[ ]`. The file says self-attestation counts as `[~]`. That is not a promotion.

## Owns / refuses

Owns 3D game production verified by those fixtures, across Godot, Unity, Unreal, three.js, and further 3D tooling the lane validates. REA tooling is supporting evidence for static inspection of 3D artifacts, under the observation / inference / unknown split (`PROVINCE.md`).

The standing host fact at mint, in that same file: Godot 4.7.2 headless is the executable runtime; Unity and Unreal editors are not installed; three.js runs under node without a GL context. Where an engine cannot execute headless here, the lane labels runtime behavior unproven.

Refuses engine or editor source mutation, publishing or store submission, asset-rights clearance, harness and evidence auditing, narrative canon, 2D product surfaces, and reverse engineering as an end in itself. Domain source trees are read-only. The write scope in `PROVINCE.md` names `.shokunin/game-dev-3d/**` and this lane's reports; this checkout is the standalone repository.

There is no root `SKILL.md`. Decision material is in `corpus/knowledge/` and `corpus/lessons/`.

## Start here

`corpus/fixtures/run_battery.py` runs the read-only Godot fixtures serially in an isolated scratch project. Seeds are copied; a seed mutation fails the battery. The battery exit code is 0 only when every case passes. It needs Godot. This page does not require you to run the full battery.

```sh
python3 corpus/fixtures/run_battery.py --help
```

`corpus/README.md` is the layout: `fixtures/`, `predecessor/` (inherited games-engine-mechanics patterns), `knowledge/` (census and REA reference), `lessons/`, and ignored `live/runs/` receipts. Case counts in older reports are not restated here; the battery and `corpus/fixtures/README.md` are the current text.

## Map

| Path | What it is |
|---|---|
| `PROVINCE.md` | Engine census boundary and refusals |
| `SHONEN.md` | Probation checklist |
| `LOG.md` | Append-only record |
| `SCORECARD.md` | Axis verdicts |
| `README.md` | This front door |
| `corpus/README.md` | Fixture-corpus layout |
| `corpus/fixtures/run_battery.py` | Godot battery |
| `corpus/knowledge/` | Seed, census, REA reference |
| `corpus/lessons/` | Round lessons |
| `reports/` | Verifier and adjudicator reports |

## Neighbors

game-dev-2d owns 2D product surfaces. Shared fixture patterns may be inherited; 2D products are not. lore owns narrative canon. revenger owns reverse engineering as an end in itself. Contested scope is reported (`PROVINCE.md`).

Fleet protocol: [VeigaPunk/shokunin](https://github.com/VeigaPunk/shokunin).
