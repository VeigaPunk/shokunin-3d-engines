# SEAT-16 SWEEP-CHUNK — `corpus/README.md`

**Date:** 2026-10-18. **HEAD:** `0cc3f4162f8c319f8d01a69a174fe939f36701bd` (`0cc3f41`; r105 report-last; work `3634bc0`).
**Contract:** extract every path/command citation; test each (exists from repo root, and from this file's directory); fix mechanical resolution defects in this chunk only; dated notes for historical facts; no silent rewrites; queue judgment defects. Same shape as SEAT-13's restatement of the SEAT-01 contract.
**Axes:** coverage = citation resolution in this file. Depth (engine census) is not this seat. Calibration = quoted shas and counts below were measured here; historical sentences were not rewritten.
**Writes:** `corpus/README.md` (addition only) and this report. Scratch: `reports/round-106/scratch/seat16/`. No git commit/push/checkout/reset. No protected path written.

No Unreal runtime claim. This seat did not run an editor, MCP, or Live Coding command. `knowledge/unreal-mcp/` is named only as a path that exists.

## Counts

| item | n |
|---|---:|
| file | `corpus/README.md` (31 lines at HEAD; 140 after the note) |
| path citations in the mint index | 8 mentions, 6 unique names |
| unique names that exist from `corpus/` | 6/6 |
| unique names that exist as bare paths from repo root | 0/6 |
| command citations | 1 |
| command that resolves in this repo | 0 |
| URL citations | 1 (resolves; private) |
| mechanical fix | 1 dated note, `+109 / −0` |
| judgment defects queued | 6 |

```
$ git diff --numstat -- corpus/README.md
109	0	corpus/README.md
$ cmp <(git show HEAD:corpus/README.md) <(head -n 31 corpus/README.md) && echo PREFIX_MATCH
PREFIX_MATCH
$ sha256sum corpus/README.md
711f18cc1d2101f3cce61aee0a8acc2b27a4e03cbb2052290c878e5252374436  corpus/README.md
```

Pre-note blob (also the GitHub contents sha of upstream `main`'s `corpus/README.md`): git blob `6f85cb29824811e0696f4ef2dd654bb054740027`, sha256 `e7efd4d74bc589a5eedd1f074b5fbc791810a6ca069c01981abfbea6ca296e91`. The file's only commit before this note is `82c21b4` (2026-10-13 00:00:34 -0300).

## Citation ledger

Root A = this repo root. Root B = `corpus/` (the file's directory). A layout name in a directory README is tested at both. Placeholders are none. Engine names in the prose (Godot, Unity, Unreal, three.js) are not paths.

| id | cite | test | result |
|---|---|---|---|
| P1 | L16 `lessons/` | `test -e` at A and B | MISSING at A; EXISTS at B |
| P2 | L16 `live/runs/` | `test -e` + `git check-ignore -v` | MISSING at A; EXISTS at B; ignored (`corpus/.gitignore:1:live/`) |
| P3 | L23 `fixtures/` | `test -e` | MISSING at A; EXISTS at B |
| P4 | L23 `run_battery.py` | `test -e` as bare name and as `fixtures/run_battery.py` | bare name MISSING at A and B; `corpus/fixtures/run_battery.py` EXISTS |
| P5 | L25 `predecessor/` | `test -e` | MISSING at A; EXISTS at B |
| P6 | L28 `knowledge/` | `test -e` plus the three named files | dir EXISTS at B; `seed.md`, `rea.md`, `engines.md` EXISTS |
| P7 | L30 `lessons/` | same path as P1 | EXISTS at B |
| P8 | L31 `live/runs/` | same path as P2 | EXISTS at B; ignored |
| U1 | L18 `https://github.com/VeigaPunk/prymeagnt-game-dev-3d` | `git ls-remote --heads` + `gh api` | rc 0; private; 3 heads |
| C1 | L20 `git fetch game-dev-3d main` | run in this repo | rc 128; no remote of that name |
| X1 | `artifacts/` (not cited) | `test -e corpus/artifacts` | EXISTS; absent from the mint list |
| X2 | `knowledge/unreal-mcp/` (not cited) | `test -e` | EXISTS since `1659c03`; absent from the mint list |

Bare names failing at repo root is the directory-README convention, not a dead prefix. They were not rewritten. See J1.

### C1 — the only command

```
$ git remote -v
origin	https://github.com/VeigaPunk/shokunin-3d-engines.git (fetch)
origin	https://github.com/VeigaPunk/shokunin-3d-engines.git (push)
$ git fetch game-dev-3d main
fatal: 'game-dev-3d' does not appear to be a git repository
fatal: Could not read from remote repository.
exit=128
```

`git status --porcelain` immediately after that attempt was `?? reports/round-106/` only. No ref moved.

The remote name is configured in the parent campaign repo, not here:

```
$ git -C /home/vgpnk/Projects/prymeagnt/game-dev-3d config --get remote.game-dev-3d.url
https://github.com/VeigaPunk/prymeagnt-game-dev-3d.git
$ git -C /home/vgpnk/Projects/prymeagnt/game-dev-3d rev-parse refs/remotes/game-dev-3d/main
ed6530e7778bb2ba472e3eb0cf58fff95900b0e2
$ git -C /home/vgpnk/Projects/prymeagnt/game-dev-3d fetch --dry-run game-dev-3d main
From https://github.com/VeigaPunk/prymeagnt-game-dev-3d
 * branch              main       -> FETCH_HEAD
exit=0
```

After that dry-run the tracking ref was still `ed6530e7`, parent `git status --porcelain` was empty, and `FETCH_HEAD` was absent (`/home/vgpnk/Projects/prymeagnt/.git/worktrees/game-dev-3d/FETCH_HEAD` does not exist). Dry-run was used so this seat would not update another repo's refs.

Resolving read from this repo, no remote added:

```
$ git ls-remote https://github.com/VeigaPunk/prymeagnt-game-dev-3d.git refs/heads/main
ed6530e7778bb2ba472e3eb0cf58fff95900b0e2	refs/heads/main
exit=0
```

Not a substitute: `git rev-parse origin/main` → `cb87233904d7041c100aab02f6d736e545b939a8`. Network tip of `shokunin-3d-engines` `main` the same day (`git ls-remote --heads`) was `4565305f1e59b00045479f9a8c0f8119038b0a4e`. Both differ from HEAD `0cc3f41`.

### U1 — upstream sentence

```
$ git ls-remote --heads https://github.com/VeigaPunk/prymeagnt-game-dev-3d.git
8c67aa7e28a9f0b28838e9fb60314d14e7bbe260	refs/heads/craft/game-dev-3d-mint
e1e863c3f755247523d1d694216fce69d4353249	refs/heads/craft/game-dev-3d-r1
ed6530e7778bb2ba472e3eb0cf58fff95900b0e2	refs/heads/main
$ gh api repos/VeigaPunk/prymeagnt-game-dev-3d --jq '{default_branch,private,pushed_at}'
{"default_branch":"craft/game-dev-3d-mint","private":true,"pushed_at":"2026-10-13T20:04:16Z"}
```

`main` commit `ed6530e7` is 2026-10-13T13:45:41Z, message `corpus refresh: game-dev-3d latest craft state (2026-10-13)`. Its root tree is `README.md` + `corpus/` only.

`craft/game-dev-3d-mint` (`8c67aa7e`, 2026-10-13T03:00:34Z) and `craft/game-dev-3d-r1` (`e1e863c3`, 2026-10-13T20:04:15Z, "extract … `.shokunin/game-dev-3d` now a symlink") both have `.shokunin`, `config`, `docs`, `scripts`, `skills`, `verification`, and no top-level `corpus/`.

Upstream `main` `corpus/` children vs local:

| path | upstream `ed6530e7` | local `a731d899` | HEAD |
|---|---|---|---|
| `corpus/README.md` | `6f85cb29` | `6f85cb29` | `6f85cb29` before this note |
| `artifacts` | `3fac1f53` | `3fac1f53` | `69791563` |
| `fixtures` | `6830178f` | `6830178f` | `14087337` |
| `knowledge` | `2e1dafa1` | `2e1dafa1` | `46d105d7` |
| `lessons` | `29778307` | `29778307` | `425a06ab` |
| `predecessor` | `9c49cc61` | `9c49cc61` | `9c49cc61` |
| `.gitignore` | `d123993e` | `fa8ee3fb` | `fa8ee3fb` |

`a731d899` is 2026-10-13 10:41:46 -0300, `game-dev-3d r68: verify Raycaster layer masks independently`. Upstream `.gitignore` is the same three patterns as local (`live/`, `__pycache__/`, `*.pyc`) in a different order (`live/` / `*.pyc` / `__pycache__/`). Ignore rules match; blob sha does not.

```
$ git ls-tree -r --name-only 82c21b4 corpus/fixtures | wc -l
12
$ git ls-tree -r --name-only HEAD corpus/fixtures | wc -l
147
$ git ls-tree --name-only 82c21b4 corpus/
corpus/.gitignore
corpus/README.md
corpus/fixtures
corpus/knowledge
corpus/lessons
corpus/predecessor
```

`artifacts/` is not in the mint tree. First commits are r9–r22. `knowledge/unreal-mcp/` first appears at `1659c03` (r101).

### P4 — scratch claim

`corpus/fixtures/run_battery.py` sha256 `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` (matches the round's stated pin). Docstring and `main()`: default `--runs` is `HERE.parent / "live" / "runs"`; scratch is `run_dir / "scratch"`; copy skips `run_battery.py`, `__pycache__`, `three`, and dotfiles. The "copies seeds to an ignored scratch" sentence holds, with those exclusions. Not rewritten.

`predecessor/` exists. `corpus/knowledge/seed.md` cites import commit `4671a6b53dc4fbb878f477b2c2961305d1d9484c` and `craft/games-r15-toggle`. `corpus/predecessor/corpus/round-reports/games-r15.md` exists. The archive commit was not re-fetched here (J4).

## What was fixed

Appended `## Correction note (r106, 2026-10-18)` at `corpus/README.md:33`. The mint index (lines 1–31) is byte-identical to `git show HEAD:corpus/README.md` (`PREFIX_MATCH`). The note records:

- C1 does not resolve in this checkout; the dry-run that does; the `git ls-remote` read that does not add a remote.
- U1's two clauses are stale for this tree: `main` is the r68 snapshot, not HEAD; `craft/*` is two wrapper branches, and the default branch is `craft/game-dev-3d-mint`.
- X1 and X2 exist and were not in the mint list.
- "read-only" is the runtime copy rule (12 tracked fixture files at mint, 147 at HEAD).
- "preserved under `live/runs/`" overclaims durability; that tree is gitignored.

No historical sentence was rewritten. `git fetch origin main` was not substituted for C1.

## Judgment queue

Not fixed. A later seat can rule.

| id | defect | why queued |
|---|---|---|
| J1 | Bare layout names do not exist from repo root (`ls fixtures` fails; `ls corpus/fixtures` works). | Rewriting the five bullets to `corpus/…` would edit the mint index. They resolve from the file's directory. Dead-prefix rewrites in other chunks are a different defect: those prefixes exist in neither root. |
| J2 | Do not retarget the upstream URL to `shokunin-3d-engines`, and do not add a `game-dev-3d` remote to this repo. | Different repository. Adding a remote is a git-config mutation this seat was not asked to make. |
| J3 | L13 "every fixture carries its exact reproduction command and expected exit signature." | Not swept. Fixture code is protected. `corpus/fixtures/README.md` is SEAT-17. That README's line 38 states the header-comment contract; this seat did not check headers. |
| J4 | L30 "round lesson files with cited receipts." Point-in-time: `find corpus/lessons -name '*.md' \| wc -l` → 92; `rg -l 'corpus/live/runs\|reports/round-' corpus/lessons --glob '*.md' \| wc -l` → 86. The six non-matches at that moment were `r10-rea-zip-carrier.md` (cites `ev_` ids and `corpus/artifacts/zip-r10/rea-*.json`), `r75-navagent-map-mutation.md` (cites commits `6498973`, `cefc821`), `r76-navagent-sync-window.md`, `r78-mapoff-permanence-callsite.md`, `r79-bpy-two-layer-model.md` (no hit for `reports/\|corpus/live\|receipt\|ev_\|commit \|LOG`), `r8-camera-near-plane.md`. | Lesson files are other chunks and were dirty during this sweep. r8's runnable line was observed first with a `.shokunin/game-dev-3d/` prefix and later without it — another seat was editing it. Not this chunk. The r15 archive commit in J-adjacent P5 was not re-hashed against `games-engine-mechanics`. |
| J5 | Rewrite of L18–20 (URL, "main carries this corpus", "craft/*", the fetch command) was declined. | Correction-note discipline. The resolving command is in the note. A rewrite that points this file at `origin` would be false. |
| J6 | L16 "preserved … under `live/runs/`" vs L31 "ignored, disposable". | Dated in the note. The purpose sentence was not rewritten. Durable copies are the lesson files; `live/` is gitignored. |

## Not run

- Full battery. Not a path fix.
- `git fetch` that would update refs, in this repo or the parent. The failing fetch and the parent dry-run are the probes.
- Engine census (C2). `engines.md` exists; its rows were not re-probed.
- Unreal editor. Not installed; not claimed.
