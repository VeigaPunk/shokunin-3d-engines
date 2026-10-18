# F2 — before-capture: cited receipt `corpus/live/runs/20261013T053632289732Z/verdicts.json` is absent

- Seat: SEAT-02 (before capture only; no edits)
- Round: r102
- Repo HEAD at capture: `2c99b7b8155841617d844c609813afcba77aa207`
- Working dir: `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`
- Date: 2026-10-18
- Claim under test: F2 — `corpus/lessons/r22-unreal-review.md:48` cites a Godot receipt file that
  does not exist and is not in the tracked tree (it lives under the gitignored `corpus/live/`).
- Verdict at capture: **CONFIRMED (defect reproduces; exit=2 on the cited path)**.

## The citation

`corpus/lessons/r22-unreal-review.md:48`:

> Godot receipt `corpus/live/runs/20261013T053632289732Z/verdicts.json`, SHA-256 `a806b9e4d2928ac2c01ba463804ad55f7e14086b72d7846a458f91e271e3d8fc`

A second cite exists at `corpus/lessons/r23-ortho-review.md:3` (same path, used as the round-22
comparison receipt).

## Checks and verbatim output

### 1. Path absence (cited file)

```
$ ls -la corpus/live/runs/20261013T053632289732Z/verdicts.json
ls: cannot access 'corpus/live/runs/20261013T053632289732Z/verdicts.json': No such file or directory
exit=2

$ test -e corpus/live/runs/20261013T053632289732Z/verdicts.json && echo PRESENT || echo ABSENT
ABSENT
exit=0
```

The parent directory `corpus/live/runs/20261013T053632289732Z/` does not exist either
(`ls: cannot access 'corpus/live/runs/20261013T053632289732Z/': No such file or directory`,
exit=2).

### 2. Gitignore status

```
$ git check-ignore -v corpus/live/runs/20261013T053632289732Z/verdicts.json
corpus/.gitignore:1:live/	corpus/live/runs/20261013T053632289732Z/verdicts.json
exit=0

$ git check-ignore -v corpus/live/runs/20261013T053632289732Z/
corpus/.gitignore:1:live/	corpus/live/runs/20261013T053632289732Z/
exit=0
```

`corpus/.gitignore` (full content):

```
live/
__pycache__/
*.pyc
```

The `live/` rule at `corpus/.gitignore:1` ignores the whole `corpus/live/` tree, so any receipt
written there can never be tracked.

### 3. Git history for the path (never committed)

```
$ git log --all --oneline -- corpus/live/runs/20261013T053632289732Z/verdicts.json
exit=0   # (no output — zero commits touched this path)

$ git log --all --oneline -- corpus/live/runs/20261013T053632289732Z/
exit=0   # (no output)

$ git log --all --full-history --oneline -- corpus/live
exit=0   # (no output — full history walk over corpus/live, still nothing)

$ git ls-files corpus/live
exit=0   # (no output — no tracked file under corpus/live)

$ git log --all --diff-filter=A --name-only --pretty=format: | grep -i 'live/'
exit=0   # (no output — no add commit ever introduced a live/ path)
```

Repo has 275 commits across all refs (`git rev-list --all --count` → `275`); refs present are
`main`, `origin/HEAD`, `origin/main` (3 refs). None of them contains the path.

### 4. No such file anywhere on disk

```
$ find . -name verdicts.json -not -path './.git/*'
exit=0   # (no output — file exists nowhere in the working tree)
```

### 5. What `corpus/live/runs/` actually contains now

```
$ ls -la corpus/live/runs/
total 0
drwxr-xr-x 1 vgpnk vgpnk 88 Oct 18 14:40 .
drwxr-xr-x 1 vgpnk vgpnk 34 Oct 18 14:22 ..
drwxr-xr-x 1 vgpnk vgpnk 14 Oct 18 14:17 20261018T171756783227Z
drwxr-xr-x 1 vgpnk vgpnk 14 Oct 18 14:40 20261018T174044163916Z
exit=0
```

Only 2026-10-18 run directories exist (both created by r101/r102 re-runs); the cited
`20261013T053632289732Z` directory is absent.

## Consequence

- The cited receipt is **not in the tracked tree and never was**, so it is unresolvable for any
  reader who clones the repo. The cited digest `a806b9e4d2928ac2c01ba463804ad55f7e14086b72d7846a458f91e271e3d8fc`
  is therefore uncheckable by construction.
- Independently corroborated at r101 by `reports/round-101/r101-critic-c3.md:179-197` (same
  exit=2 output).
- Repair discipline (r102): the r22/r23 lesson lines are historical factual claims, so they must
  not be silently rewritten — the repair adds a dated correction note stating the receipt lives
  only in the ephemeral gitignored `corpus/live/` tree and is not reproducible from a clone.

## Reproduce

```
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
ls -la corpus/live/runs/20261013T053632289732Z/verdicts.json     # exit=2
git check-ignore -v corpus/live/runs/20261013T053632289732Z/verdicts.json
git log --all --oneline -- corpus/live/runs/20261013T053632289732Z/verdicts.json
```
