# r107-sent-scope — SCOPE/IDENTITY SENTINEL (round 107, 3D side-round)

**Plan (5 lines).**
1. Freeze the pre-audit baseline: HEAD commit, branch, lane identity (`git log -1 --format`), and the byte-hash of the frozen battery `corpus/fixtures/run_battery.py` at HEAD.
2. Write-boundary audit: enumerate every path this round created/modified inside the lane repo (`git status --porcelain -uall`, mtime sweep) and assert all of them fall under `reports/round-107/` (plus orchestrator-only `corpus/knowledge/unreal-mcp/`).
3. Battery-immutability audit: compare worktree bytes vs `HEAD` blob for `corpus/fixtures/run_battery.py` and every other fixture, and prove no seat executed the battery (no run artifacts, no trace).
4. Scratch-hygiene audit: confirm every round-107 scratch root lives under `/var/tmp/r107-*` and that no seat wrote to `/tmp`, `$HOME`, or a sibling lane checkout.
5. Zero-commit + identity audit: prove no seat committed (`git log` unchanged vs baseline, reflog clean) and that lane identity is the 3D lane, not the 2D lane or a sibling; record [O]/[I]/[?] verdicts.

**Status:** COMPLETE. Baseline `2026-10-19T03:08:52Z`, close re-read `2026-10-19T03:11:37Z` UTC.
Seat wrote exactly one path: `reports/round-107/r107-sent-scope.md`. Scratch: `/var/tmp/r107-sent-scope/`.

---

## 0. Audit method and a methodological correction (recorded for honesty)

This shard is an *audit*, not a deliverable. Every claim carries the exact command
and the output seen on this host. Labels: **[O]** observed here, **[I]** inference,
**[?]** unknown from this seat. Baseline captured first, re-read at close; a delta
between the two readings is itself a finding.

**Correction — my first scratch grep was a false positive [O].** An early pass ran
`grep -rho -E '/tmp/r107-[a-z0-9-]+'` and reported 21 "bare `/tmp`" scratch roots. That
pattern matches *inside* `/var/tmp/r107-…`, because the substring `/tmp/r107-` occurs
there. Re-running boundary-corrected (`(^|[^a-zA-Z/])/tmp/…`) shows **zero** shard
citations of bare `/tmp/r107-*` **[O]**:

```
$ grep -rlE '(^|[^a-zA-Z/])/tmp/r107-' reports/round-107/*.md reports/round-107/mutations/*
(no output; count=0)
```

The defect I do report in §4 is a *different*, narrower one and is unaffected by this
correction: it is real files on disk under `/tmp`, not shard text.

---

## 1. Baseline and identity

| field | value | command |
|---|---|---|
| HEAD | `3ea02ffaafc6c618bb97a19f103a3d28ecdc2638` | `git rev-parse HEAD` **[O]** |
| branch | `main` | `git rev-parse --abbrev-ref HEAD` **[O]** |
| lane identity | `game-dev-3d-shokunin <game-dev-3d@shokunin.local>` | `git log -1 --format='%an <%ae>'`; `git config user.name/email` **[O]** |
| HEAD subject | `r106 report-last: verdict … work 26cd9f2`, committed `2026-10-18 22:24:32 -0300` | `git log -1 --format='%H%n%an <%ae>%n%ci%n%s'` **[O]** |
| battery sha256 | `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` | `sha256sum corpus/fixtures/run_battery.py` **[O]** |

Identity is the 3D lane, not the 2D lane **[O]**. `git config --local --list` gives
`user.name=game-dev-3d-shokunin`, `user.email=game-dev-3d@shokunin.local`; the 2D lane's
own HEAD (`e8990516`) is authored by `game-dev-2d-shokunin <game-dev-2d@shokunin.local>`
— distinct identity, distinct repo **[O]**. Lane remote is
`https://github.com/VeigaPunk/shokunin-3d-engines.git` **[O]**, i.e. this is the 3D lane's
own checkout, not a shared tree.

---

## 2. Write-boundary audit — PASS

Every path created or modified this round is inside `reports/round-107/` **[O]**:

```
$ git status --porcelain=v1 -uall | awk '{print $2}' | grep -v '^reports/round-107/' || echo "NONE [O]"
NONE [O]
$ git status --porcelain=v1 -uall | wc -l
60
```

A full mtime sweep for anything newer than the round start agrees — the only non-`.git`
paths with a fresh mtime are `reports/`, `reports/round-107/` and its contents **[O]**:

```
$ find . -path ./.git -prune -o -newermt '2026-10-18 23:30' -print | grep -vc '^\./reports/round-107'
1                       # the single match is ./reports itself
$ find reports -maxdepth 2 -newermt '2026-10-18 23:30' -print | grep -v 'round-107'
(empty)
$ find corpus -newermt '2026-10-18 23:30' -print
(empty)
```

At close: **34** shards under `reports/round-107/*.md` and **26** files under
`reports/round-107/mutations/` **[O]**. All 60 porcelain entries are `??` (untracked) —
no tracked file in the lane was modified **[O]**:

```
$ git status --porcelain=v1 | grep -vc '^??'
0
$ git diff HEAD --stat -- corpus/fixtures/
(empty)
```

**Protected ledgers untouched [O].** `LOG.md`, `SCORECARD.md`, `PROVINCE.md`,
`SHENEN.md`/`SHONEN.md`, `README.md`, `SKILL.md` — all clean against HEAD
(`git status --porcelain=v1 -uall -- LOG.md SCORECARD.md PROVINCE.md SHONEN.md README.md`
→ empty; `SKILL.md` mtime `2026-10-18 22:24`, i.e. r106, not this round).

**Vendored tree untouched by seats — orchestrator-only rule respected [O].**

```
$ git status --porcelain=v1 -uall -- corpus/knowledge/unreal-mcp/
(empty)                                     # clean vs HEAD
$ find corpus/knowledge/unreal-mcp -newermt '2026-10-18 23:30' -print
(empty)                                     # nothing written this round
$ git log -1 --format='%h %ci' -- corpus/knowledge/unreal-mcp/
830095a 2026-10-18 22:24:31 -0300           # last touch is r105
```

No seat landed a file into the tree; the drafts (`r107-PROVENANCE-draft.md`,
`r107-cards*.md`, `r107-kimi-adapt.md`, `r107-gate*.md`) are all in `reports/round-107/`
where they belong **[O]**.

---

## 3. Battery immutability — PASS

All 108 tracked fixtures under `corpus/fixtures/` are byte-identical to their HEAD
blobs **[O]**. Per-file check, worktree vs `git cat-file -p HEAD:<path>`:

```
$ for f in $(git ls-files corpus/fixtures); do
    w=$(sha256sum "$f" | cut -d' ' -f1); h=$(git cat-file -p "HEAD:$f" | sha256sum | cut -d' ' -f1)
    [ "$w" = "$h" ] && echo "OK $f" || echo "DIFF $f"; done | grep -c '^OK'
108
$ ... | grep -c '^DIFF'
0
```

`corpus/fixtures/run_battery.py` specifically: worktree
`f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` = HEAD blob
`f456bd00…` **[O]**. The file's own mtime is `Oct 14 12:49` — untouched since before the
round **[O]**.

**No seat executed the battery [O]** (evidence class: absence of the artifacts an
execution would leave, plus no in-round reference to running it):
- no run artifacts: `find . \( -name '*.log' -o -name '.godot' -o -name 'run_battery*.json' -o -name '*.stdout' -o -name '*.stderr' \) -newermt '2026-10-18 23:30'` → empty **[O]**;
- `__pycache__/run_battery.cpython-314.pyc` mtime `Oct 18 18:22`, i.e. **before** the round start (23:30) — not a r107 import **[O]**; same for `bpy_*.pyc` (`18:31`) **[O]**;
- the only in-round occurrence of the string `run_battery` anywhere under `reports/round-107/` is in *this* shard's own plan text **[O]** — no other shard claims a run, and no shard cites an invocation.

Per the hard rules I did not run the battery or the 3D battery; nothing here depends on
having done so.

---

## 4. Scratch hygiene — PASS with one finding (F2)

Round-107 scratch is overwhelmingly where the rule requires it: **30+** roots under
`/var/tmp/r107-*`, several non-empty **[O]**:

```
$ ls -d /var/tmp/r107-* | wc -l
30+
$ ls -A /var/tmp/r107-va | wc -l        → 5
$ ls -A /var/tmp/r107-vb | wc -l        → 24
$ ls -A /var/tmp/r107-verify | wc -l    → 11
$ ls -A /var/tmp/r107-verify2 | wc -l   → 31
```

`/tmp` is a 16G tmpfs at **1% used** (`df -h /tmp` → `tmpfs 16G 66M 16G 1%`) **[O]**;
`/var/tmp` is on the 930G root fs (`df -h /var/tmp` → `/dev/mapper/root 930G 175G 742G 20%`)
**[O]**, so the chosen scratch root is also the roomy one.

### F2 — 9 r107 scratch files written to bare `/tmp`, outside the mandated root [O]

```
$ ls -la /tmp/h1 /tmp/h2 /tmp/l1 /tmp/l2 /tmp/h1n /tmp/h2n /tmp/r107diff.txt /tmp/r107pr-*.txt
-rw-r--r-- 1 vgpnk vgpnk 2088 Oct 19 00:09 /tmp/h1
-rw-r--r-- 1 vgpnk vgpnk 1812 Oct 19 00:09 /tmp/h2
-rw-r--r-- 1 vgpnk vgpnk 1296 Oct 19 00:09 /tmp/l1
-rw-r--r-- 1 vgpnk vgpnk 1020 Oct 19 00:09 /tmp/l2
-rw-r--r-- 1 vgpnk vgpnk 1068 Oct 19 00:09 /tmp/h1n
-rw-r--r-- 1 vgpnk vgpnk 1068 Oct 19 00:09 /tmp/h2n
-rw-r--r-- 1 vgpnk vgpnk    0 Oct 19 00:09 /tmp/r107diff.txt
-rw-r--r-- 1 vgpnk vgpnk  638 Oct 19 00:09 /tmp/r107pr-allrefs.txt
-rw-r--r-- 1 vgpnk vgpnk  276 Oct 19 00:09 /tmp/r107pr-mainrefs.txt
```

Content is unambiguously r107 **[O]** — `/tmp/h1` holds a sha256 list rooted at
`unreal-engine-skills-for-claude-code-plugin-a6aa73ada02a9fb1f5415bec491f9942c519b297/`
and `/tmp/h2` the same list rooted at `EpicGames-unreal-engine-skills-for-claude-code-plugin-a6aa73a/`
— exactly the codeload-vs-REST pair `r107-VENDOR-B.md:122` compares with
`diff <(strip-topdir /tmp/h1) <(strip-topdir /tmp/h2)`. `/tmp/r107pr-*.txt` are ref
listings of the pinned repo. `r107-VENDOR-B.md:122` **cites the bare `/tmp/h1` path
verbatim** **[O]**, so at least that seat's scratch root was `/tmp`.

Severity and honest bounds:
- **Harm: none observed.** No lane file, no ledger, no fixture touched; `/tmp` is at 1% and
  these are small. The mandated root was the point, not the risk.
- **Not the 16G-quota failure class.** `r107-planner.md` §3.4 warns that a *large* scratch
  (a full clone) under `/tmp` can die as `Disk quota exceeded`. These 9 files total ~9 KB,
  so that failure mode was not triggered **[O]** — but the warning shows the rule exists
  for a reason, and this seat violated it anyway.
- **Attributing seat: [?]** for `/tmp/h1|h2|l1|l2|h1n|h2n` (VENDOR-B by its own citation,
  so `[I]`); **[?]** for `r107pr-*.txt` (no shard cites them; no `r107-pr-watch.md` exists
  — see F1).
- **Recommendation (orchestrator/next round):** state the scratch root explicitly as
  `/var/tmp/r107-<key>` in the seat prompt (as the round brief already does) and treat a
  bare `/tmp` write as a named, non-fatal boundary finding at adjudication — as it is here.

---

## 5. F1 — cross-lane write: a r107 3D shard landed inside the 2D lane [O]

The strongest finding this seat has. `game-dev-2d-shokunin/reports/round-107/` **exists**
and contains a 3D-side-round artifact:

```
$ git -C game-dev-2d-shokunin status --porcelain=v1 -uall
?? reports/round-107/r107-planner.md
$ ls -la game-dev-2d-shokunin/reports/round-107/
-rw-r--r-- 1 vgpnk vgpnk 571 Oct 19 00:08 r107-planner.md
```

Its own first line says it is ours **[O]**:

```
$ head -1 game-dev-2d-shokunin/reports/round-107/r107-planner.md
# r107-planner — SPEC-PLANNER (3D side-round, round 107)
```

The file is the **first 9 lines of our `reports/round-107/r107-planner.md` verbatim,
plus a 10th line `STATUS: in-progress`** **[O]** — an early draft of our shard, written
into the wrong repo and then abandoned (our own copy has since grown to 453 lines /
`eb29c625…`, so the residue is a stale prefix, not a live duplicate):

```
$ head -9 <our r107-planner.md> > /var/tmp/r107-sent-scope/p9.txt
$ diff /var/tmp/r107-sent-scope/p9.txt game-dev-2d-shokunin/reports/round-107/r107-planner.md
9a10
> STATUS: in-progress
$ sha256sum /var/tmp/r107-sent-scope/p9.txt   → e7c063f59b43f741ec4f6fa80e0ef5895a26a3b972327ce2e40c7a8ac2f18dbc
$ sha256sum <2D residue>                      → 61947ff6933bfe84425b5f6f53e77901abdb98f8691eb751ce42089d7b4667f4
```

No whole-file match exists between the 2D residue and any of our 34 shards **[O]** —
confirming it is a prefix, not a copy of a finished artifact.

**Two further 3D files transiently appeared in the 2D lane and then vanished [O].** At
`00:08`–`00:09` this seat observed the 2D lane's porcelain listing include
`reports/round-107/mutations/snapshot.sh` and `reports/round-107/r107-pull-watch.md`
(a r107 title of ours); by `00:09:32` both were gone, leaving only `r107-planner.md`:

```
$ (00:08) git -C game-dev-2d-shokunin status --porcelain=v1 -uall
?? reports/round-107/mutations/snapshot.sh
?? reports/round-107/r107-planner.md
?? reports/round-107/r107-pull-watch.md
$ (00:10, after re-check) git -C game-dev-2d-shokunin status --porcelain=v1 -uall
?? reports/round-107/r107-planner.md
$ ls -la game-dev-2d-shokunin/reports/round-107/mutations/
ls: cannot access '.../mutations/': No such file or directory
```

So a seat was **actively creating 3D side-round files inside the 2D lane during this
round**, and the residue is the one file that survived to close.

Bounds on this finding:
- **The 2D lane itself was not damaged [O].** Its worktree equals its HEAD
  (`git -C game-dev-2d-shokunin diff HEAD --shortstat` → empty; 0 modified tracked
  files), its HEAD `e8990516` is unchanged, and it has **no commits this round**
  (`git log --since='2026-10-18 23:30'` → only the two r104 commits at `00:04:32`, which
  are the lane's own closure). Nothing was committed into the 2D repo.
- **`reports/round-107/` in the 2D lane was never tracked [O]**:
  `git -C game-dev-2d-shokunin log --all --oneline -- reports/round-107` → empty;
  `git ls-tree -r HEAD -- reports/round-107` → empty. So no 3D path entered the 2D
  history.
- **Attributing seat: [?].** This seat sees the effect, not the writer. The content is
  derived from our SPEC-PLANNER shard and from the pull-watch seat's own title, so the
  candidates are those two seats (or a seat that re-ran their preamble) — but I cannot
  observe which, and I will not guess.
- **What it violates:** HARD RULE 1 ("Write ONLY inside `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`… NEVER touch the 2D lane or any sibling"). The write is transient/untracked and caused no 2D damage, but it is a real boundary breach and belongs in the close-out record.
- **Recommendation:** the orchestrator should `rm -rf game-dev-2d-shokunin/reports/round-107/`
  (untracked, contains only our residue — but that is the *2D* lane, so the 2D lane's owner
  or the orchestrator must decide; this seat will not write there), and the next round's
  seat prompt should pin `cd` to the lane repo before any write.

---

## 6. Zero-commit and integrity audit — PASS

**No seat committed [O].** HEAD is the r106 commit and nothing newer exists:

```
$ git rev-parse HEAD
3ea02ffaafc6c618bb97a19f103a3d28ecdc2638          # identical at baseline and at close
$ git log --since='2026-10-18 23:30' --format='%h' | wc -l
0
$ git reflog --date=iso -4 | head -1
3ea02ff HEAD@{2026-10-18 22:24:32 -0300}: rebase (finish): returning to refs/heads/main
```

Reflog's newest entry is `2026-10-18 22:24:32`, i.e. r106's own close, ~1h before this
round's first scratch write (`00:08`) **[O]**. `.git/index` mtime `2026-10-18 22:24:36`
— no `git add` ran this round **[O]**. `git for-each-ref` shows `refs/heads/main` =
`3ea02ff` and `refs/remotes/origin/main` = `3ea02ff` **[O]**; no new local branch, tag or
ref was created. Working tree diff is exactly the 60 untracked `??` entries of §2 **[O]**.

**Fleet-root writes are not this round's [O].** Two fleet-root paths have fresh mtimes —
`MANIFEST.json` (`00:05:03`) and `.ufo/reports/{round-11,round-104}` — but all three carry
the **2D lane's** closure fingerprint (`MANIFEST.json`'s last commit is
`ci fleet: game-dev-2d round-104 closure`, and `.ufo/reports/round-104/game-dev-2d.md`
is the 2D fleet report); grepping them for `game-dev-3d`/`round-107`/`unreal-mcp` returns
nothing **[O]**. So they are the 2D lane's fleet bookkeeping, not 3D side-round writes.
Also noted and dismissed: `/home/vgpnk/Projects/shokunin/bash: /` — a stray directory
created `2026-10-18 14:01`, ~9h **before** this round; not a r107 write **[O]**, and
outside my lane so I did not touch it.

---

## 7. Verdict table

| # | check | verdict | decisive evidence |
|---|---|---|---|
| 1 | lane identity = 3D lane | **PASS** | `git log -1 --format='%an <%ae>'` → `game-dev-3d-shokunin <game-dev-3d@shokunin.local>`; 2D HEAD authored by `game-dev-2d@…` **[O]** |
| 2 | all r107 writes inside `reports/round-107/` | **PASS** | `git status -uall \| grep -v '^reports/round-107/'` → NONE; mtime sweep agrees **[O]** |
| 3 | `run_battery.py` + all fixtures byte-identical to HEAD | **PASS** | 108/108 `OK` vs `HEAD:` blobs; battery `f456bd00…` both sides **[O]** |
| 4 | no battery execution | **PASS** | no run artifacts; `.pyc` predate the round; only self-reference to the name **[O]** |
| 5 | no writes into `corpus/knowledge/unreal-mcp/` | **PASS** | clean vs HEAD; no mtime > 23:30; last touch r105 **[O]** |
| 6 | scratch under `/var/tmp/r107-*` | **FINDING (F2)** | 30+ correct roots, but 9 files at bare `/tmp` incl. `/tmp/h1` cited by `r107-VENDOR-B.md:122` **[O]** |
| 7 | no writes into a sibling lane | **FINDING (F1)** | `game-dev-2d-shokunin/reports/round-107/r107-planner.md` = first 9 lines of our shard + `STATUS: in-progress`; 2 transient 3D files seen there at 00:08 **[O]** |
| 8 | zero commits | **PASS** | HEAD unchanged; `git log --since` → 0; reflog/index at 22:24; no new refs **[O]** |
| 9 | protected ledgers untouched | **PASS** | `LOG.md SCORECARD.md PROVINCE.md SHONEN.md README.md SKILL.md` clean vs HEAD **[O]** |
| 10 | UE runtime | **UNPROVEN (pull in flight)** | pull pid 596299 alive at 04:19 elapsed; `docker images \| grep -i unreal` → none; log 2358 B, 16 layers `Pull complete` **[O]** — not this seat's claim to make; see `r107-unlock*.md` |

**Bottom line.** The 3D lane's own boundary held: zero commits, all writes in
`reports/round-107/`, fixtures and the vendored tree untouched. Two boundary defects
exist at the edges — **F1** (a 3D shard written into the 2D lane, untracked, no 2D
damage) and **F2** (9 scratch files at bare `/tmp` instead of `/var/tmp/r107-*`). Both
are findings for adjudication, neither is a fabrication or a lane-integrity failure.
UNPROVEN items stay UNPROVEN: the UE runtime label is `UNPROVEN (pull in flight)`, and
the attributing seat for both F1 and F2 is **[?]** from this seat's vantage.
