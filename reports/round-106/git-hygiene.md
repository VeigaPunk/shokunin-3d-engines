# r106 SEAT-57 — Git hygiene

**Seat:** SEAT-57 `GIT-HYGIENE` · round r106 · lane `game-dev-3d-shokunin`
**Owned path:** this file only (`reports/round-106/git-hygiene.md`). This seat also wrote read-only scratch under `reports/round-106/scratch/seat57/` (host note authorizes that scratch root). No other path was edited.
**Repo:** `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`
**HEAD under test:** `0cc3f4162f8c319f8d01a69a174fe939f36701bd` (`r105 report-last`; work `3634bc0`). Branch `main`, **ahead 10 / behind 0** of `origin/main`. HEAD was re-read at every snapshot below and did not move.
**Primary tracked snapshot:** `2026-10-18T21:55:42Z`. Size re-measure: `2026-10-18T22:06:35Z`. Earlier probes (21:21Z–21:53Z) are cited where they caught a state that later moved.
**No `git commit` / `push` / `checkout` / `reset` was run by this seat.** `git add --dry-run` was run twice against nested clones; the index was not updated (see §3.2).
**No Unreal runtime claim.** The editor is not installed on this host. Nothing here promotes an `unproven-runtime` card. Upstream pin cited only as the object the nested clone resolved to: `a6aa73ada02a9fb1f5415bec491f9942c519b297`.

Roster used for attribution: `reports/round-106/scratch/seats.txt` (128 seats) and the C-locale alphabetical lesson partition in `reports/round-106/scratch/seat24/lesson-partition.txt` (92 lesson markdown files, groups of 8, seat 12 takes the remainder). This seat recomputed that partition from `corpus/lessons/*.md` sorted in C locale and it matched the partition file.

---

## 0. Verdict

**3 live violations, 1 self-cleared violation, 1 close-out risk.** Protected trees are clean. No staged content, stash, lock, or extra worktree.

| class | count | verdict |
|---|---|---|
| tracked write into a protected tree (`LOG`/`SCORECARD`/`SHONEN`/`PROVINCE`/`SKILL`/`reports/round-101..105`/`corpus/fixtures`/`upstream`/`.manifest.d`/`gate`) | 0 | clean (`git diff --quiet` exit 0 at 21:55:42Z) |
| untracked path outside `reports/round-106/` | 0 | clean |
| exclusive-chunk write (lesson paths owned by SEAT-09/10, notes cite chunk-05) | 8 files | **VIOLATION — §3.1** |
| historical path rewrite with no dated note in the added lines | 31 lesson files | **VIOLATION — §3.1** (edit contract: dated notes, never silent rewrites) |
| nested `.git` that makes `git add` fatal | 1 (`scratch/seat15/pred/repo`) | **VIOLATION — §3.2**, still present at 22:06:35Z |
| nested `.git` that `git add --dry-run` would record as a gitlink | 1 (`scratch/seat71/pin-clone`) | **VIOLATION, self-cleared** before 21:44:56Z |
| untracked bulk a close-out `git add -A` would commit | 548M, 29 `*.so`, 15785 untracked paths at 21:55:42Z | **RISK — §3.3** |
| staged / stash / index lock / rebase / extra worktree | 0 | clean |
| `git diff --check` | exit 0 | clean |

This is a timestamped live-tree snapshot while other seats are still writing. It is not a close-time lock. Re-run `git status --porcelain=v2 --branch --untracked-files=all` and `git diff --name-status HEAD` after the last seat exits, before any commit.

---

## 1. Method — commands actually run

All from the lane root. None of these switch HEAD.

```sh
date -u '+%Y-%m-%dT%H:%M:%SZ'
git rev-parse HEAD
git log -1 --format='%H%n%s'
git status -sb
git rev-list --left-right --count origin/main...HEAD
git status --porcelain=v2 --branch --untracked-files=all   # first probe, 21:21Z; output was huge
git diff --name-status HEAD
git diff --stat HEAD
git diff --cached --name-status
git diff --check
git stash list
git worktree list
ls .git/index.lock .git/MERGE_HEAD .git/rebase-merge .git/CHERRY_PICK_HEAD
git diff --quiet HEAD -- LOG.md SCORECARD.md SHONEN.md PROVINCE.md SKILL.md \
    reports/round-101 reports/round-102 reports/round-103 reports/round-104 \
    reports/round-105 corpus/fixtures \
    corpus/knowledge/unreal-mcp/upstream \
    corpus/knowledge/unreal-mcp/.manifest.d \
    corpus/knowledge/unreal-mcp/gate
git ls-files --others --exclude-standard | grep -v '^reports/round-106/' | wc -l
git ls-files --others --exclude-standard | wc -l
git add --dry-run -- reports/round-106/scratch/seat71/pin-clone   # while that clone existed
git add --dry-run -- reports/round-106/scratch/seat15/pred/repo
stat -c '%y %s' .git/index
git ls-files -s -- reports/round-106/scratch/seat71/pin-clone
du -sh reports/round-106
find reports/round-106 -name '*.so' | wc -l
find reports/round-106 -name .git -type d
```

A hash walk at `2026-10-18T21:21:38Z`–`21:22:09Z` compared every tracked blob under the protected set plus `corpus/lessons` and `corpus/knowledge` (`git ls-tree -r HEAD` vs `git hash-object`). At that instant: protected+lessons+knowledge **0 differences, 0 untracked additions**. Lesson and `engines.md` edits landed after that walk.

`git add --dry-run` did not stage. Index mtime stayed `2026-10-18 18:16:01.215556079 -0300`, size `4172591`, before and after the seat71 dry-run. `git diff --cached --name-only` was empty after both dry-runs. `git ls-files -s` on the pin-clone path was empty.

This seat also wrote one accidental redirect to `/tmp/seat57-check.out` (host note: do not use `/tmp`). It was removed with `rm -f` in the same turn. It was not a repo path.

---

## 2. Full status

### 2.1 Branch

`git status -sb` at 21:53:23Z, confirmed by `git rev-parse` / `git rev-list --left-right --count origin/main...HEAD` at 21:55:42Z:

```text
## main...origin/main [ahead 10]
```

```text
# branch.oid 0cc3f4162f8c319f8d01a69a174fe939f36701bd
# branch.head main
# branch.upstream origin/main
# branch.ab +10 -0
```

`git log -1` subject: `r105 report-last: verdict (all axes improved), LOG + SCORECARD, shadowing-not-drift ruling + P/C operator package — work 3634bc0`.

`git worktree list`: only this checkout. `git stash list`: empty. No `index.lock`, `MERGE_HEAD`, `rebase-merge`, or `CHERRY_PICK_HEAD`.

### 2.2 Tracked modifications at 21:55:42Z

`git diff --stat HEAD`:

```text
41 files changed, 237 insertions(+), 111 deletions(-)
```

`git diff --cached --name-status`: empty.
`git diff --check`: exit 0, no output.
`git diff --quiet` on the protected set: exit 0.
`git ls-files --others --exclude-standard` paths outside `reports/round-106/`: **0**.

Tracked paths (all `M`, none staged):

- `corpus/knowledge/engines.md` — declared dual owner: SEAT-38 (census owner) and SEAT-14 (citation sweep). The diff cites `reports/round-106/scratch/seat38/…` and a dated r106 correction note. Attribute to **SEAT-38** on that evidence. SEAT-14 had not left a separate sweep hunk in this diff.
- `corpus/lessons/r105-unreal-lifecycle.md` — alphabetical chunk SEAT-01; SEAT-18 also declared a re-sweep; the added paragraph is an environment pairing for `337/350` vs `350/350` dated `r106, 2026-10-18`, which is SEAT-46's declared line ownership (`seats.txt` line 46). Roster overlap, not an out-of-roster path. No seat token inside the paragraph, so the writer is inferred, not process-proven.
- Eight lessons with a dated note that cites `reports/round-106/sweep/chunk-05.md`: `r61-stream-review.md`, `r62-three-ortho-near-review.md`, `r63-three-ray-review.md`, `r64-ray-side-review.md`, `r65-ray-order-review.md`, `r66-ray-range-review.md`, `r67-ray-boundary-review.md`, `r68-ray-layers-review.md`. Alphabetical owners are SEAT-09 (`r61`–`r63`) and SEAT-10 (`r64`–`r68`). See §3.1.
- Thirty-one other lesson files, path-root substitutions, **no dated note in the added lines**. Roster owners from the alphabetical partition:

| roster owner | silent files |
|---|---|
| SEAT-01 | `r1-headless-verification.md` |
| SEAT-02 | `r2-independent-review.md` |
| SEAT-04 | `r3-signal-exit.md`, `r3-signal-review.md` |
| SEAT-05 | `r4-stream-attribution.md` |
| SEAT-06 | `r4-stream-review.md` |
| SEAT-07 | `r47-remote-review.md`, `r48-rotation-review.md`, `r49-navagent-review.md`, `r5-cleanup-review.md`, `r5-identified-witness-timeout.md`, `r5-timeout-review.md`, `r50-navfollow-review.md`, `r51-retarget-review.md` |
| SEAT-08 | `r52-final-review.md`, `r53-doc-review.md`, `r54-near-review-inherited.md`, `r55-far-review.md`, `r56-exact-near-review.md`, `r56-final-doc-review.md`, `r57-exact-far-review.md`, `r58-three-camera-review.md` |
| SEAT-09 | `r6-final-review.md`, `r6-isolation-review.md`, `r6-three-review.md` |
| SEAT-10 | `r7-camera-far-plane.md`, `r7-camera-review.md` |
| SEAT-12 | `r79-bpy-two-layer-model.md`, `r8-camera-near-plane.md`, `r8-near-review.md`, `r9-glb-review.md` |

Those owners are the roster assignment, not a process trace. The diffs themselves do not name a seat. Sampled shapes (commands: `git diff -- <path>`):

- `r1`: `python3 run_battery.py …` → `python3 corpus/fixtures/run_battery.py …`. No `.shokunin` token. No note.
- `r2`, `r3-*`, `r4-*`, `r47`–`r58`, `r5-*`, `r7-*`, `r8-*`: `.shokunin/game-dev-3d/` stripped from command lines. No note.
- `r79`: `` `bpy_battery.py` `` → `` `corpus/fixtures/bpy_battery.py` ``. No note.
- `r6-final-review.md` (read at 21:53Z): only the `python3` invocation was re-rooted; the `node .shokunin/game-dev-3d/…` line and several receipt paths were left prefixed. Partial silent rewrite.
- `r9-glb-review.md` (read at 21:53Z): Godot command re-rooted; the Node command still contained `.shokunin/game-dev-3d/`. The 21:55 stat then showed this file at `4 +-` (it had been `2 +-` a minute earlier), so that leftover may already have moved. Do not treat the leftover as still true without a re-read.

### 2.3 Untracked

`git ls-files --others --exclude-standard | wc -l` at 21:55:42Z: **15785**, all under `reports/round-106/`.
`du -sh reports/round-106` at 22:06:35Z: **548M**.
`find reports/round-106 -name '*.so' | wc -l` at 22:06:35Z: **29**.
`find … -name .git -type d` at 22:06:35Z: **1** (`scratch/seat15/pred/repo/.git`).

An earlier walk at 21:44:56Z counted 17356 files / 456.6 MB (walk counts files inside the embedded repo that `git status` collapses to one directory). The tree was still growing: 21:21Z untracked count was 1070; 21:30Z `find` count was 7524 / 267M; 21:55Z git-untracked was 15785; 22:06Z du was 548M.

`git status` does not list the embedded repo's internals as separate untracked files. `git status --porcelain=v1 -- reports/round-106/scratch/seat15/pred/repo` showed one line: `?? reports/round-106/scratch/seat15/pred/repo/`.

Pasting 15785 paths would rot before it was read. Prefix attribution is in §2.4. The counting commands above are the full-status evidence.

### 2.4 Untracked attribution

Host note for this round authorizes scratch under `reports/round-106/scratch/` (and `~/`), because `/tmp` quota is exhausted. A path there is not, by itself, an out-of-scope write. It is still a commit hazard (§3.3).

| prefix | attribution |
|---|---|
| `reports/round-106/scratch/seatNN*` | the numbered seat. Observed dirs included seat04–11, 13, 15, 16, 18–20, 24, 27, 28, 36, 37, 40, 41, 43, 45, 46, 49, 52, 53, 67, 71, 76, 79–81, 84–87, 89, 91, 93, 96–98, 100, 107, 109–111, 115, 117, 121, 122, 125, and this seat's `seat57`. Not a closed set; the tree was growing. |
| `reports/round-106/census/<name>.md` and `census/*/runs/` | census seats 25–40. Headers read at 21:30Z: `cannon.md` SEAT-28, `n24-state.md` SEAT-37, `phys3d-joints.md` SEAT-33, `three-default.md` SEAT-26, `verify.md` SEAT-40. Run trees under `census/phys3d-joints/runs/` and `census/navagent/runs/` match SEAT-33 and SEAT-31 contracts (battery scratch copies, including `pybullet*.so`). |
| `reports/round-106/gate/` | SEAT-70 `final-run.md`, SEAT-110 `blocked-check.md` (headers read). `gate/scratch/` is the directory SEAT-70 was told to create. |
| `reports/round-106/glb-unity/` | SEAT-94 receipt dir next to `glb-unity-regression.md` (header read: SEAT-94). |
| `reports/round-106/battery-default-quick-receipts/` | SEAT-87, next to `battery-default-quick.md` (header read: SEAT-87). |
| `reports/round-106/sweep/`, `consistency/`, `jolt/` | declared report trees for sweep/consistency/jolt seats. `jolt/` was empty at 21:24Z. |
| root `*.md` whose name is the roster path | the seat named in `seats.txt`. Headers confirmed at 21:30Z for the files that existed then (list in the table above plus `engine-count.md` SEAT-98, `install-recheck.md` SEAT-74, `ledger-final.md` SEAT-116, `r105-receipt-carry.md` SEAT-113, `r106-scribe-audit.md` SEAT-59, `r22-regression.md` SEAT-93, `consistency/adversary.md` SEAT-47). Files that appeared later (`citation-form-rule.md`, `consistency.md`, `engine-cmd-regression.md`, `freshness-pin.md`, `ledger-check.md`, `ledger-math.md`, `pc-carry.md`, `pinned-quick.md`, `r106-report.md`, `scorecard-shape.md`, `shonen-draft.md`) match roster names; their headers were **not** re-read. `shonen-draft.md` is a file from a report-back seat (SEAT-67); the roster did not name that path. |

**Unattributed (no seat token in the path):**

- `reports/round-106/scratch/20261018T212236099489Z/` — battery receipt, not a seat-prefixed dir. `verdicts.json` fields read: `started_utc=20261018T212236099489Z`, `only=phys3d_events_inactive_space`, `verdict=PASS`, `totals={cases:1, pass:1, fail:0}`, `seeds_unchanged=true`, `godot_version=4.7.2.stable.arch_linux.ed1daf0bf`. That `--only` arm is SEAT-32's contract. Inferred SEAT-32. Not proven.
- Scratch-root extracts with no seat id: `seats.txt`, `all-items.txt`, `seat-items.txt`, `item-10.txt` through `item-118.txt`, `parent-prompt-extract.txt`, `prompt_template.txt`, `swarm-line-2945.json`, `cards.txt`, `card-decl.txt`, `unity.txt`, `unreal-desc.txt`, `sha-root.txt`, `sha-sub.txt`, `three-default.txt`, `three-pinned.txt`. These are dispatch extracts. Writer not identified. Not a protected-path write.

**Transient trees (gone by the later snapshot):**

- `reports/round-106/n24/` — present at 21:24Z (134 files, 11M), including `n24/runs/seat88-pinned-quick-20261018T212035Z/`. Absent at 21:30Z (`ls` → No such file). SEAT-88's declared report `pinned-quick.md` exists. Deletion of that seat's own untracked receipt tree is not a protected-path violation.
- `reports/round-106/scratch/seat71/pin-clone/` — see §3.2. Gone by 21:44:56Z.

---

## 3. Violations

### 3.1 Exclusive-chunk collision, and silent rewrites

Roster rule (`seats.txt` line 1): chunk A is the first 8 lesson files alphabetically; each following sweep seat takes the next 8; SEAT-12 takes the remainder. `seat24/lesson-partition.txt` records that split. Under it:

- chunk-05 / SEAT-05 = `r33-arraymesh-review.md` … `r4-stream-attribution.md`
- chunk-09 / SEAT-09 = `r59-three-near-review.md` … `r63-three-ray-review.md` (includes `r61`–`r63`)
- chunk-10 / SEAT-10 = `r64-ray-side-review.md` … `r70-navagent-detour-review.md` (includes `r64`–`r68`)

Observed:

1. `git diff -U0 -- corpus/lessons/r61-stream-review.md` added a correction note whose last clause is `Evidence: reports/round-106/sweep/chunk-05.md`. The same evidence pointer is on `r62`–`r68` (grep of `git diff -U0 -- corpus/lessons` at 21:32:49Z: eight `Evidence:` lines, all `chunk-05.md`).
2. `ls reports/round-106/sweep/chunk-05.md` at 21:53:23Z: `No such file or directory`. The cited evidence path does not resolve.
3. `reports/round-106/scratch/seat05/resolve.txt` lines 2–9 list exactly `r61`–`r68` with SHA-256s. That directory also contains `post-r61-cases.out` through `post-r68-layer.out`.
4. `reports/round-106/scratch/seat78-progress.txt` line 24, SEAT-10's own progress text: `The lessons changed under me.`

That is a cross-chunk write. The notes self-attribute to chunk-05; SEAT-05's scratch inventories the same eight paths; the alphabetical owners are SEAT-09 and SEAT-10. This seat did not capture a writer pid. The inference is from the note and the scratch, not from `git blame` (the edits are uncommitted).

Separate class, same snapshot: 31 lesson files listed in §2.2 were modified with no `Correction note` / `r106` marker in the added lines. The round rule is dated correction notes for historical facts, never silent rewrites. Stripping `.shokunin/game-dev-3d/` from a historical command is a historical-fact edit. Those 31 files violate that rule even when the roster owner is the likely writer. `r105-unreal-lifecycle.md` is not in that 31: its added paragraph is dated `Environment pairing (r106, 2026-10-18)`. `engines.md` has a dated correction-note section.

SEAT-86 owns the sweep-sentinel ruling on silent rewrites. This seat flags the worktree fact so the L1 does not treat the lesson diff as clean.

### 3.2 Nested git repositories

**Live — `reports/round-106/scratch/seat15/pred/repo/.git`.** Still present at 22:06:35Z (`find` count 1).

Observed while inspecting it:

- `git -C … rev-parse HEAD` → `fatal: ambiguous argument 'HEAD'` / `your current branch 'master' does not have any commits yet`.
- `.git/HEAD` is `ref: refs/heads/master`.
- `.git/config` remote `origin` = `https://github.com/VeigaPunk/prymeagnt-games-engine-mechanics`. `FETCH_HEAD` exists (a fetch ran). No commit is checked out.
- `git add --dry-run -- reports/round-106/scratch/seat15/pred/repo` printed:

```text
error: 'reports/round-106/scratch/seat15/pred/repo/' does not have a commit checked out
error: unable to index file 'reports/round-106/scratch/seat15/pred/repo/'
fatal: adding files failed
```

A close-out `git add -A` or `git add reports/round-106` will **fail** on this path until the nested repo is removed or given a commit. That is a blocker, not just noise. Lane HEAD was not switched.

The hard-rule list is `commit` / `push` / `checkout` / `reset`. This seat did not observe an explicit `git checkout` in the lane worktree. The nested repo's reflog could not be read (`fatal: your current branch 'master' does not have any commits yet`). Flag the embedded repo and the fatal add. Do not upgrade that to a proven `git checkout` of lane HEAD.

**Self-cleared — `reports/round-106/scratch/seat71/pin-clone/.git`.** Present at ~21:24Z, absent at 21:44:56Z (`ls` → No such file). While it existed:

- `git -C … rev-parse HEAD` → `a6aa73ada02a9fb1f5415bec491f9942c519b297`
- reflog: `a6aa73a HEAD@{0}: clone: from https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin`
- `git add --dry-run --` that path printed `warning: adding embedded git repository` and `add 'reports/round-106/scratch/seat71/pin-clone/'`. It did not update the index (see §1).

`git clone` is not in the forbidden verb list. It does check out the pin inside the nested repo. Lane `git rev-parse HEAD` stayed `0cc3f41` the whole audit, so the lane worktree was not checked out. The L1 should still treat an embedded clone under `reports/round-106/` as a gitlink hazard if one reappears. SEAT-71's declared deliverable is `subtree-integrity.md`, not a clone inside the worktree.

### 3.3 Close-out bulk risk

`reports/round-106/` is not gitignored (`git check-ignore -v reports/round-106` produced no match). At 22:06:35Z it was **548M**, with **29** `*.so` copies (battery scratch copies of `pybullet*.so`, ~7MB each, seen under census runs and `scratch/seat49`, `scratch/seat87`, `scratch/seat28-cannon`, `scratch/seat109`). `scratch/seat109` alone was 2571 files at the 21:24Z walk (clean-tree copies including `three/node_modules`).

`git add -A` at close would commit that bulk, including binaries, plus fail on the seat15 embedded repo (§3.2). The host note authorizes the scratch *location*. It does not authorize committing it. Highest-value item for the L1: do not `git add reports/round-106/scratch`, `census/*/runs`, or `n24` receipt trees. Keep the declared markdown reports; leave or delete the run scratch before commit.

`corpus/live/` had 93 files newer than `2026-10-18 18:15` at 21:44:56Z. `corpus/.gitignore` line 1 is `live/`, so those files are not in `git status` and are not a commit hazard. Fixture tracked bytes still matched HEAD (`git diff --quiet` exit 0 includes `corpus/fixtures`). This does not prove no seat wrote a fixture and reverted it between probes.

---

## 4. What is not a violation

- `engines.md` edited with a dated r106 note and `scratch/seat38` receipts. In-roster for SEAT-38. SEAT-14 is a second declared owner of the same file; no second writer's hunk was separated out.
- `corpus/fixtures/PINNED-ENV.md` and fixture code: not in the dirty set. Protected quiet exit 0.
- Reports under `reports/round-106/` that match a roster path: in scope, even when the header was not re-read (§2.4).
- This file, once written, is one more untracked path under `reports/round-106/`. It is the declared SEAT-57 path.
- No path under `reports/round-101` … `reports/round-105` differed from HEAD.

---

## 5. Limits

Point-in-time. Other seats were landing lesson edits during the audit (21:22Z hash walk: 0 lesson diffs; 21:26Z: 8 lessons; 21:55Z: 40 lessons + `engines.md`). Numbers above are the command's timestamp, not a final close. Process authorship is inferred from notes, scratch names, and the roster. A seat that writes a protected path after 21:55:42Z is not covered. Re-run the §1 commands before commit.
