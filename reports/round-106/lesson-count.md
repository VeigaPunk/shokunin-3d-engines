# SEAT-95 LESSON-COUNT — r106

Axes: **coverage** (every `corpus/lessons` path, not a prose total), **depth** (r105 file still present and still the lifecycle lesson, not a name-only check), **calibration** (worktree count vs `HEAD` vs work `3634bc0`; deletion filters empty; dirty sha not quoted as landed).

This seat wrote only this file. No `corpus/lessons` file was edited. No fixture code was written. No Unreal runtime claim.

## Verdict

`LESSON_FILES=96` at `2026-10-18T21:55:33Z`. Same 96 paths at `HEAD` `0cc3f41` and at work `3634bc0`. `R105_PRESENT=yes`. `DELETIONS=0` against `HEAD`, against `3634bc0`, and in `git log --diff-filter=D` for this path. Sweep edits in the window were content modifications (`M`) only.

Not a close lock. The dirty set grew while this seat watched (8 → 17 → 40) and peer seats were still writing. Rerun the deletion block after they stop before treating this as the freeze.

| check | result |
|---|---|
| worktree files | 96 (92 `.md`, 4 `.json`) |
| directories | 2 (`corpus/lessons`, `corpus/lessons/r1`) |
| `HEAD` tracked | 96 |
| `3634bc0` tracked | 96 |
| missing vs `HEAD` | none |
| extra vs `HEAD` | none |
| deleted `3634bc0` → `HEAD` | none |
| added `3634bc0` → `HEAD` | none |
| untracked under `corpus/lessons` | none |
| empty or non-regular | none |
| ever-deleted commits | 0 |
| r105 on disk / `HEAD` / `3634bc0` | yes / yes / yes |

## Commands and observed output

Lane `HEAD` (also the named `0cc3f41`). Work `3634bc0` is an ancestor (`merge-base --is-ancestor` rc 0).

```text
$ date -u '+%Y-%m-%dT%H:%M:%SZ'
2026-10-18T21:55:33Z
$ git rev-parse HEAD
0cc3f4162f8c319f8d01a69a174fe939f36701bd
$ find corpus/lessons -type f | wc -l
96
$ find corpus/lessons -type d | wc -l
2
$ git ls-tree -r --name-only HEAD -- corpus/lessons | wc -l
96
$ git ls-tree -r --name-only 3634bc0 -- corpus/lessons | wc -l
96
```

Path-set compare at that same timestamp (`os.walk` regular files vs `git ls-tree -r --name-only`):

```text
wt 96 HEAD 96 3634 96
missing_vs_HEAD NONE
extra_vs_HEAD NONE
deleted_HEAD_vs_3634 NONE
added_HEAD_vs_3634 NONE
bad NONE
ext {'.md': 92, '.json': 4}
r105_in_all True
```

The four `.json` paths (path set identical to `HEAD`, so these are the only four): `corpus/lessons/r70-navagent-detour-non-author.json`, `corpus/lessons/r1/adversarial-controls.json`, `corpus/lessons/r1/clean-verdicts.json`, `corpus/lessons/r1/mutation-verdicts.json`.

Deletion filters, same timestamp. Empty output is the observation.

```text
$ git diff --name-status --diff-filter=D HEAD -- corpus/lessons
(empty)
$ git diff --name-status --diff-filter=DRC HEAD -- corpus/lessons
(empty)
$ git ls-files --deleted -- corpus/lessons
(empty)
$ git ls-files --others --exclude-standard -- corpus/lessons
(empty)
$ git log --diff-filter=D --name-only --pretty=format:'commit %H' 3634bc0..HEAD -- corpus/lessons
(empty)
$ git log --diff-filter=D --pretty=format:'%H' -- corpus/lessons | wc -l
0
```

`git status --porcelain=v1 --untracked-files=all -- corpus/lessons` at `21:55:33Z` was 40 `M` lines and no `D`, `A`, `R`, or `?`. `git diff --name-status HEAD -- corpus/lessons` was the same 40 paths, each `M`.

```text
M corpus/lessons/r1-headless-verification.md
M corpus/lessons/r105-unreal-lifecycle.md
M corpus/lessons/r2-independent-review.md
M corpus/lessons/r3-signal-exit.md
M corpus/lessons/r3-signal-review.md
M corpus/lessons/r4-stream-attribution.md
M corpus/lessons/r4-stream-review.md
M corpus/lessons/r47-remote-review.md
M corpus/lessons/r48-rotation-review.md
M corpus/lessons/r49-navagent-review.md
M corpus/lessons/r5-cleanup-review.md
M corpus/lessons/r5-identified-witness-timeout.md
M corpus/lessons/r5-timeout-review.md
M corpus/lessons/r50-navfollow-review.md
M corpus/lessons/r51-retarget-review.md
M corpus/lessons/r52-final-review.md
M corpus/lessons/r53-doc-review.md
M corpus/lessons/r54-near-review-inherited.md
M corpus/lessons/r55-far-review.md
M corpus/lessons/r56-exact-near-review.md
M corpus/lessons/r56-final-doc-review.md
M corpus/lessons/r57-exact-far-review.md
M corpus/lessons/r58-three-camera-review.md
M corpus/lessons/r6-final-review.md
M corpus/lessons/r6-isolation-review.md
M corpus/lessons/r6-three-review.md
M corpus/lessons/r61-stream-review.md
M corpus/lessons/r62-three-ortho-near-review.md
M corpus/lessons/r63-three-ray-review.md
M corpus/lessons/r64-ray-side-review.md
M corpus/lessons/r65-ray-order-review.md
M corpus/lessons/r66-ray-range-review.md
M corpus/lessons/r67-ray-boundary-review.md
M corpus/lessons/r68-ray-layers-review.md
M corpus/lessons/r7-camera-far-plane.md
M corpus/lessons/r7-camera-review.md
M corpus/lessons/r79-bpy-two-layer-model.md
M corpus/lessons/r8-camera-near-plane.md
M corpus/lessons/r8-near-review.md
M corpus/lessons/r9-glb-review.md
```

56 of 96 paths were clean at that frame. This seat did not review the hunks. They are other seats' chunks. None of those edits removed a path.

## r105 lesson

Present. First line at `21:55:33Z`:

```text
# r105 lesson — Unreal lifecycle: pin, vendor, gate, harden, repair
```

Landed identity is the `HEAD` blob, not the dirty worktree. `git log -1 -- corpus/lessons/r105-unreal-lifecycle.md` → `3634bc0748f2ae1e02e20571874b39a3f3705daa` (2026-10-18 18:14:40 -0300, r105 lifecycle lesson commit).

```text
$ git rev-parse HEAD:corpus/lessons/r105-unreal-lifecycle.md
59ead0358a49561937c10fe1692282955ecbf54d
$ git show HEAD:corpus/lessons/r105-unreal-lifecycle.md | sha256sum
c7f6a27f0cc71b56bff875a1ffdd3c1c32761d7bf00ba9f48ef8351942d82729  -
$ git show HEAD:corpus/lessons/r105-unreal-lifecycle.md | wc -l -c
    162   10415
$ sha256sum corpus/lessons/r105-unreal-lifecycle.md
c4aa80ec883e5118017bd6f3953e2c881bdaa0024c79e2a048189c85b450304c  corpus/lessons/r105-unreal-lifecycle.md
$ wc -l -c corpus/lessons/r105-unreal-lifecycle.md
  174 11289 corpus/lessons/r105-unreal-lifecycle.md
$ git hash-object corpus/lessons/r105-unreal-lifecycle.md
45f029142b67949d64d801b177d77bf178c1a7ac
```

At `2026-10-18T21:27:07Z`, before the in-flight note, `git hash-object` of the worktree file equalled `HEAD:` `59ead035…` and `sha256sum` was `c7f6a27f…` (162 lines, 10415 bytes). At `21:42:24Z` `git diff -- corpus/lessons/r105-unreal-lifecycle.md` was an inserted block headed `Environment pairing (r106, 2026-10-18)` under the 2.9 s bullet (index `59ead03..45f0291`). That is a dated note, not a deletion. Do not quote `c4aa80ec…` / `45f02914…` / 174 lines as the landed lesson.

## Sweep window (this seat)

Path count stayed 96. Dirty set grew. No path left the set.

| stamp | `find -type f` | missing vs `HEAD` | dirty (`M` only) |
|---|---|---|---|
| `2026-10-18T21:27:07Z` | 96 | none | 8: `r61`–`r68`. r105 blob matched `HEAD`. |
| `2026-10-18T21:42:24Z` | 96 | none | 17: `r105`, `r47`–`r51`, three `r5*` files, `r61`–`r68`. `diff-filter=D` empty. |
| `2026-10-18T21:55:33Z` | 96 | none | 40, listed above. `diff-filter=D` empty. |
| `2026-10-18T21:59:14Z` | 96 | n/a (deletion filter only) | 40. `diff-filter=D` count 0. r105 present. |

Post-write recheck, after this file existed:

```text
$ date -u '+%Y-%m-%dT%H:%M:%SZ'
2026-10-18T21:59:14Z
$ find corpus/lessons -type f | wc -l
96
$ git diff --name-only --diff-filter=D HEAD -- corpus/lessons | wc -l
0
$ test -f corpus/lessons/r105-unreal-lifecycle.md && echo r105=PRESENT
r105=PRESENT
$ git status --porcelain=v1 --untracked-files=all -- corpus/lessons | wc -l
40
```

## Queued, not rewritten

- Close-time rerun required. This snapshot is not a lock. Command: `git diff --name-status --diff-filter=D HEAD -- corpus/lessons` plus `find corpus/lessons -type f | wc -l` plus `test -f corpus/lessons/r105-unreal-lifecycle.md`.
- Do not cite worktree sha `c4aa80ec…` as the committed r105 lesson. Landed content sha is `c7f6a27f0cc71b56bff875a1ffdd3c1c32761d7bf00ba9f48ef8351942d82729`, git blob `59ead0358a49561937c10fe1692282955ecbf54d`, 162 lines, 10415 bytes.
- Older r105 receipts are not that blob. `reports/round-105/close-receipt.md` records `d089aae70c0fd251c6c2c9efc7a7c00e28a3c63d792d7a6fef3a92372c0349e6` (162 lines, pre-commit). `reports/round-105/lesson/bleed.md` records `dd9b9ac064511b9cbc95cd4ebed6d62b995606dd3db069453f0ff653afefe758` (155 lines). Round-105 reports are protected; this seat did not edit them. Quote the `HEAD` pair above for the landed file.
- `LOG.md` and `SKILL.md` were not found to state a current lesson-file total that disagrees with 96. No count rewrite was applied. `reports/round-106/ledger-math.md` also says 96; that is another seat's frame (`21:41:02Z`), not this measurement.
