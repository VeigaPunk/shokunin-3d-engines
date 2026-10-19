# game-dev-3d — fixture corpus

Reference corpus of the **game-dev-3d** shokunin lane (campaign prymeagnt,
minted 2026-10-13): a headless **3D** fixture battery — movement
and collision, spatial queries, camera projection, scene structure,
transform composition, input-driven 3D mechanics — with discriminating
negative controls, plus the inherited games-engine-mechanics suite, an
REA static-inspection reference, and an engine census. Engine-neutral by
operator directive: Godot, Unity, Unreal Engine, three.js, and any
further 3D rendering tooling the lane discovers and validates on its
shonen path.

Purposes: (1) reference guide — every fixture carries its exact reproduction
command and expected exit signature; (2) discovery corpus for new 3D
mechanics moves; (3) inspiration source — failed fits and rejected probes
are preserved as negative results under lessons/ and live/runs/.

Upstream: https://github.com/VeigaPunk/prymeagnt-game-dev-3d (branch main
carries this corpus; craft/* branches carry round-by-round history). Local
execution references it with: git fetch game-dev-3d main

Layout:
- fixtures/ — the round-1 3D battery seeds (read-only) plus run_battery.py,
  which copies seeds to an ignored scratch run before execution.
- predecessor/ — games-engine-mechanics r15 corpus (2D-agnostic headless
  patterns: synthetic input, physics overlap, causal chains, scene
  transitions, discriminating negatives), inherited read-only.
- knowledge/ — seed provenance, the REA tooling reference, and the
  engine census (Godot/Unity/Unreal/three.js execution reality).
- lessons/ — round lesson files with cited receipts.
- live/runs/ — ignored, disposable execution receipts.

## Correction note (r106, 2026-10-18)

The paragraphs above are the mint index (commit `82c21b4`, 2026-10-13)
and are preserved verbatim. Re-measured from this checkout at HEAD
`0cc3f41` on 2026-10-18. Command log:
`reports/round-106/sweep/chunk-16.md`. No Unreal runtime claim: the
editor is not installed.

### `git fetch game-dev-3d main` does not resolve here

This repo's only remote is `origin` →
`https://github.com/VeigaPunk/shokunin-3d-engines.git`. There is no
remote named `game-dev-3d`.

```
$ git fetch game-dev-3d main
fatal: 'game-dev-3d' does not appear to be a git repository
fatal: Could not read from remote repository.
```

exit 128. That attempt did not move a ref.

The remote name exists in the parent campaign repo
`/home/vgpnk/Projects/prymeagnt/game-dev-3d` (URL
`https://github.com/VeigaPunk/prymeagnt-game-dev-3d.git`). A
non-updating probe from that cwd exited 0. After it,
`FETCH_HEAD` was absent:

```
$ git -C /home/vgpnk/Projects/prymeagnt/game-dev-3d fetch --dry-run game-dev-3d main
From https://github.com/VeigaPunk/prymeagnt-game-dev-3d
 * branch              main       -> FETCH_HEAD
```

Tracking ref `game-dev-3d/main` stayed
`ed6530e7778bb2ba472e3eb0cf58fff95900b0e2`.

From this repo, read the cited tip without adding a remote:

```
$ git ls-remote https://github.com/VeigaPunk/prymeagnt-game-dev-3d.git refs/heads/main
ed6530e7778bb2ba472e3eb0cf58fff95900b0e2	refs/heads/main
```

Do not substitute `git fetch origin main`. That remote is a different
repository. Local `origin/main` was `cb872339`; the network tip of
`shokunin-3d-engines` `main` observed the same day was `4565305f`.
Neither is this checkout (`0cc3f41`).

### The upstream sentence is stale as a description of this tree

The URL exists (private; `git ls-remote --heads` exit 0). It has three
heads, not a craft branch per round:

- `main` `ed6530e7` — 2026-10-13T13:45:41Z, "corpus refresh"
- `craft/game-dev-3d-mint` `8c67aa7e` — default branch, not `main`
- `craft/game-dev-3d-r1` `e1e863c3` — extract; `.shokunin/game-dev-3d`
  became a symlink

Both `craft/*` trees are the campaign wrapper (`.shokunin`, `config`,
`docs`, `scripts`, `skills`, `verification`). Neither has a top-level
`corpus/`. This lane's later rounds are commits on this repo, not
those branches.

`main` does contain a `corpus/` tree. It is the 2026-10-13 r68
snapshot, not HEAD. Child trees `artifacts` `3fac1f53`, `fixtures`
`6830178f`, `knowledge` `2e1dafa1`, `lessons` `29778307`, and
`predecessor` `9c49cc61` match local `a731d899` (2026-10-13 10:41:46
-0300). `corpus/README.md` blob `6f85cb29` matched this file before
this note, because the file had not been edited since mint. HEAD has
moved: `fixtures` `14087337`, `lessons` `425a06ab`, `knowledge`
`46d105d7`, `artifacts` `69791563`. `predecessor` `9c49cc61` still
matches. Upstream `.gitignore` blob `d123993e` is the same three
patterns as local `fa8ee3fb` (`live/`, `__pycache__/`, `*.pyc`) in a
different order. Tracked fixture files: 12 at `82c21b4`, 147 at HEAD.

### Paths the mint list does not name

Layout names resolve from this file's directory (`corpus/`), not as
bare names from the repo root. That is the directory-README
convention, not a broken citation.

Present now, absent from the five bullets above:

- `artifacts/` — static samples added after mint (r9–r22). Not an
  engine-execution record.
- `knowledge/unreal-mcp/` — added at r101 (`1659c03`). Static pinned
  tree. Not proof of plugin load or editor runtime.

These still resolve from `corpus/`: `fixtures/`,
`fixtures/run_battery.py`, `predecessor/`, `knowledge/` (`seed.md`,
`rea.md`, `engines.md`), `lessons/`, `live/runs/`. `live/` is
gitignored (`git check-ignore -v corpus/live/runs` →
`corpus/.gitignore:1:live/`).

`run_battery.py` still copies seeds to an ignored scratch before
execution (`--runs` default `corpus/live/runs/<stamp>/scratch`; skips
`run_battery.py`, `__pycache__`, `three`, and dotfiles). "Read-only"
is that runtime rule, not a claim that `fixtures/` is still only the
round-1 seeds. sha256 `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`.

"Preserved under `live/runs/`" overclaims durability. That tree is
ignored and disposable. Durable negative results are the lesson files.

The purpose line that every fixture carries a reproduction command,
and the lessons line that every lesson cites a receipt, were not
re-audited here. Fixture code is protected; lesson files belong to
other chunks and were being edited during this sweep. See the report.
