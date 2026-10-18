# SEAT-58 PATHROOT-SWEEP — dead path roots beyond `.shokunin/game-dev-3d/`, in RUNNABLE commands

**Seat:** SEAT-58 PATHROOT-SWEEP · round r103 · lane `game-dev-3d-shokunin`
**Repo:** `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`, HEAD `c85a816e227984272a3c29b58aa7f7c1a76f1e9c` (work `c6f655d`)
**Write scope:** this file only. **No repository file was modified by this seat** — every command below is
read-only except for the disposable, gitignored receipts my own verification runs wrote under
`corpus/live/runs/` (confirmed ignored: `git check-ignore -v corpus/live/runs/20261018T183407518519Z/verdicts.json`
→ `corpus/.gitignore:1:live/`).
**Charge:** beyond `.shokunin`, scan lessons/READMEs for other never-existent or `/tmp`-rooted path
citations in **runnable** commands (sample 20 files); list candidates with the failing command for a
future ruling. **No repair is performed or proposed as decided here** — this is a candidate list.

**No Unreal runtime claim is made anywhere in this file.** The editor is not installed and live-MCP
behaviour is unproven by construction. Nothing here touches `corpus/knowledge/unreal-mcp/upstream/**`
or `.manifest.d/**`.

---

## 0. Two premises this sweep had to correct before counting anything

Both were re-derived here by running the commands, not quoted.

**P1 — "the root never existed" is false.** `.shokunin/game-dev-3d` was a real path; it is now a
symlink in the **parent** repo:

```
$ ls -ld /home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d
lrwxrwxrwx 1 vgpnk vgpnk 38 Oct 13 17:04 … -> ../../../shokunin/game-dev-3d-shokunin
$ ls /home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/fixtures/run_battery.py
/home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/fixtures/run_battery.py
```

So a command written as `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py` **works when
run from the parent repo root** and **fails when run from this repo root**. That asymmetry is the whole
defect, and it is why every hit is a *path-conformance* defect measured from *this* root — not a false
statement about what the author did. (Peer seat SEAT-30 `reports/round-103/b2/adversary.md` §1 dates
the tree→symlink transition to parent commit `e1e863c3`, 2026-10-13 17:04; this seat re-ran the
symlink read above, which is the observable that matters for a "failing command" claim.)

**P2 — in *this* repo the prefix has never existed, in any commit.** Verified two ways:

```
$ git log --all --oneline -- .shokunin          # no output
$ git ls-tree HEAD .shokunin                     # no output
```

Hence the control below is valid: the same command in repo-relative form succeeds.

---

## 1. Sample construction (reproducible)

Universe = every lesson/README/artifact-README in the corpus:

```
$ ls corpus/lessons/*.md corpus/lessons/*/*.md corpus/artifacts/*/README.md \
     corpus/fixtures/README.md corpus/README.md corpus/knowledge/unreal-mcp/README.md | wc -l
97
$ awk 'NR%5==1' <(…same list | sort) | cat -n        # 20 files, the seat's sample
```

The 20 sampled files: `corpus/README.md`, `corpus/fixtures/README.md`,
`corpus/artifacts/{glb-r12,unity-r19,unreal-r22}/README.md`, `corpus/knowledge/unreal-mcp/README.md`,
`corpus/lessons/r102-unreal-integration.md`, and 13 lesson reviews r13/r18/r2/r20/r25/r34/r39/r42/r47/r50/r55/r59/r74.

A citation counts as **RUNNABLE** only when it sits on a command line — line begins with an executable
(`python3`, `node`, `npm`, `uv`, `godot`, `bash`, `sh`, `cp`, `mkdir`) and the cited path is an argument.
Prose that merely *names* a path ("receipt `corpus/live/runs/…`") is classified separately in §4,
because it fails differently.

---

## 2. Per-sample class map

`P1` = runnable command citing the relative `.shokunin/game-dev-3d/` root ·
`P2` = runnable command citing the absolute `/home/vgpnk/Projects/prymeagnt/…/.shokunin/…` root ·
`P3` = runnable command rooted at `/tmp/…` ·
`LIVE` = prose citation of a `corpus/live/…` receipt or a bare `corpus/live/*.json`.

| # | file | P1 | P2 | P3 | LIVE |
|---|---|---|---|---|---|
| 1 | `corpus/README.md` | 0 | 0 | 0 | 0 |
| 2 | `corpus/fixtures/README.md` | 0 | 0 | 0 | 5 |
| 3 | `corpus/artifacts/glb-r12/README.md` | 3→0 | 0 | 0 | 1 |
| 4 | `corpus/artifacts/unity-r19/README.md` | 2→0 | 0 | 0 | 0 |
| 5 | `corpus/artifacts/unreal-r22/README.md` | 0 | 0 | 0 | 0 |
| 6 | `corpus/knowledge/unreal-mcp/README.md` | 0 | 0 | 0 | 0 |
| 7 | `corpus/lessons/r102-unreal-integration.md` | 0 | 0 | 2 | 1 |
| 8 | `corpus/lessons/r13-nav-review.md` | 2 | 0 | 0 | 1 |
| 9 | `corpus/lessons/r18-scene-review.md` | 2 | 0 | 0 | 5 |
| 10 | `corpus/lessons/r20-resource-review.md` | 2 | 0 | 0 | 4 |
| 11 | `corpus/lessons/r25-ortho-far-review.md` | 2 | 0 | 0 | 2 |
| 12 | `corpus/lessons/r2-independent-review.md` | 2 | 0 | 0 | 0 |
| 13 | `corpus/lessons/r34-index-review.md` | 2 | 0 | 0 | 3 |
| 14 | `corpus/lessons/r39-bone-rotation-review.md` | 2 | 0 | 0 | 2 |
| 15 | `corpus/lessons/r42-graze-review.md` | 3 | 0 | 0 | 5 |
| 16 | `corpus/lessons/r47-remote-review.md` | 3 | 0 | 0 | 1 |
| 17 | `corpus/lessons/r50-navfollow-review.md` | 2 | 0 | 0 | 3 |
| 18 | `corpus/lessons/r55-far-review.md` | 3 | 0 | 1 | 0 |
| 19 | `corpus/lessons/r59-three-near-review.md` | 4 | 0 | 0 | 1 |
| 20 | `corpus/lessons/r74-navagent-moving-agent.md` | 0 | 0 | 0 | 0 |

**12 of 20 sample files carry a runnable command citing the dead relative root.** The `→0` in rows 3–4
is a worktree state, not a HEAD state — see §3.

Whole-tree counts (not just the sample), all run here:

```
$ grep -rlE '\.shokunin/game-dev-3d/' corpus --include='*.md' | wc -l                        → 82
$ grep -rlE '\.shokunin/game-dev-3d/' corpus/lessons --include='*.md' | wc -l                → 80
$ grep -rlE '\.shokunin/game-dev-3d/' corpus/artifacts corpus/fixtures corpus/README.md --include='*.md' | wc -l → 2
$ grep -rlE '\.shokunin/game-dev-3d/' corpus --include='*.md' | sed -E 's|(corpus/[^/]+).*|\1|' | sort | uniq -c
      1 corpus/artifacts
      1 corpus/fixtures
     80 corpus/lessons
```

**Only 2 of the 82 are outside `corpus/lessons/`** — `corpus/artifacts/glb-r12/README.md` and
`corpus/fixtures/three/README.md`. That is the same pair the r102 fold-spec B2 item scoped (plus
`unity-r19/README.md`, which the sample row shows now has the prefix only in HEAD). The remaining 80
are historical review records.

---

## 3. Candidate table — with the failing command for each

Every row's failing command was executed from **this** repo root, verbatim.

### Class A — relative `.shokunin/game-dev-3d/` root in a runnable command

| id | file:line (sample / tree) | failing command (verbatim) | observed | repo-relative twin |
|---|---|---|---|---|
| A1 | `corpus/artifacts/glb-r12/README.md:6` | `python3 .shokunin/game-dev-3d/corpus/artifacts/glb-r12/run_import.py` | `exit=2` — `can't open file '…/.shokunin/…/run_import.py': [Errno 2]` | `python3 corpus/artifacts/glb-r12/run_import.py` → `exit=0` |
| A2 | `corpus/artifacts/glb-r12/README.md:7` | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py` | `exit=2` — `[Errno 2] No such file or directory` | `python3 corpus/fixtures/run_battery.py --only raycast3d_hit` → `exit=0`, `PASS battery` |
| A3 | `corpus/artifacts/glb-r12/README.md:8` | `node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs` | `exit=1` — Node `MODULE_NOT_FOUND` | `node corpus/fixtures/three/run_cases.mjs` → `exit=0`, `PASS three battery: 3/3` |
| A4 | `corpus/artifacts/unity-r19/README.md:10-11` | `uv run --no-project --with pyyaml python .shokunin/game-dev-3d/corpus/artifacts/unity-r19/verify_scene.py` | `exit=2` — `can't open file '…/.shokunin/…/verify_scene.py'` | `uv run … corpus/artifacts/unity-r19/verify_scene.py` → `exit=0` |
| A5 | `corpus/fixtures/three/README.md:6` | `npm ci --prefix .shokunin/game-dev-3d/corpus/fixtures/three` | `exit=1` — `npm error` | `corpus/fixtures/three/node_modules` EXISTS; `node corpus/fixtures/three/run_cases.mjs` → `exit=0` |
| A6 | `corpus/fixtures/three/README.md:7-143` (**17 lines**, the largest single file) | `node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs` | `exit=1` | `exit=0` |
| A7 | `corpus/lessons/r56-exact-near-review.md:31-32` | `cp .shokunin/game-dev-3d/corpus/fixtures/project.godot .shokunin/game-dev-3d/corpus/fixtures/camera3d_ortho.gd /tmp/r56-near-review/` | `exit=1` — `cp: cannot stat '…': No such file or directory` (both operands) | — (lesson-internal repro block) |
| A8 | 12 of 20 sampled lesson files (rows 8–19 in §2), e.g. `corpus/lessons/r2-independent-review.md:10-11`, `r13:6-7`, `r18:10-11`, `r20:10-11`, `r25:10,12`, `r34:10-11`, `r39:11-12`, `r42:10-11,27`, `r47:10-11,27`, `r50:10-11`, `r55:7-8`, `r59:5-7,9` | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py …` (2–4 lines per file) | `exit=2` for the first line; the block aborts there | `python3 corpus/fixtures/run_battery.py …` → `exit=0` |

Class A whole-tree count of files carrying such a runnable line:

```
$ grep -rlE '(^|[^-A-Za-z0-9_./])(python3?|node|npm|uv|godot|bash|sh|cp|mkdir|sed|diff)[^|]*\.shokunin/' corpus --include='*.md' | wc -l
82
```

### Class B — absolute `/home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/…` root in a runnable command

Not in the 20-file sample at all (the sampled lessons use the relative form), but found while sweeping
the tree, so it is recorded as a candidate for the future ruling.

| id | scale | failing command (verbatim) | observed |
|---|---|---|---|
| B1 | 17 files / 47 lines tree-wide | `/usr/bin/godot --headless --path /home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/review-r39-private-rotation/setter-only --script res://skeleton3d_rotation.gd --` (`corpus/lessons/r39-bone-rotation-review.md:24`) | `exit=1` — `Invalid project path specified: "…", aborting.` |

This class is *worse* than class A in one respect: the absolute form does not even degrade to a
"file not found" — Godot treats it as an invalid project and aborts, and the parent symlink does **not**
save it, because the *cited scratch directory* is itself gone (§4). Files: `r11`, `r12`, `r19`, `r36`,
`r37`, `r38`, `r39`, `r48`, `r49`, `r50`, `r51`, `r52`, `r56`, `r57`, `r62`, `r6`, `r9`.

### Class C — `/tmp`-rooted runnable commands

| id | file:line (sample) | failing command (verbatim) | observed |
|---|---|---|---|
| C1 | `corpus/lessons/r55-far-review.md:16` | `godot --headless --path /tmp/game-dev-3d-r55-far-review-jvdtidjr --script res://camera3d_ortho.gd -- --far-boundary-outside` | `exit=1` — `Invalid project path specified: "/tmp/game-dev-3d-r55-far-review-jvdtidjr", aborting.` |
| C2 | `corpus/lessons/r102-unreal-integration.md:152,154` | `bash /tmp/r101-closeout/pointer-check.sh corpus/knowledge/unreal-mcp` | path **exists today** (r101 scratch survived); a later reboot empties `/tmp` and this becomes C1. Not a live defect — flagged as *latent*. |

Whole-tree: 24 md files carry a runnable `/tmp`-rooted command; of the 26 distinct `/tmp/…` paths cited
anywhere in `corpus/**/*.md`, **12 exist and 14 are missing** right now:

```
$ grep -rhoE '/tmp/[A-Za-z0-9._@+-]+' corpus --include='*.md' | sort -u | wc -l                 → 26
$ … | while read p; do [ -e "$p" ] || echo MISSING $p; done | wc -l                             → 14
$ … | while read p; do [ -e "$p" ] && echo "EXISTS $p"; done
EXISTS /tmp/kimi_strings.txt        EXISTS /tmp/r101-audit        EXISTS /tmp/r101-closeout
EXISTS /tmp/r101seat12-aur-PKGBUILD EXISTS /tmp/r101sentinel      EXISTS /tmp/r101work
EXISTS /tmp/rb_r22.py               EXISTS /tmp/ue-pkgbuild       EXISTS /tmp/ue_pkgbuild
EXISTS /tmp/ue-skills-ref           EXISTS /tmp/up.list           EXISTS /tmp/vend.list
```

Note for the C1-refresh work (C1 in the round brief): `/tmp/ue-skills-ref` **exists** and its
byte-identity claims are therefore currently checkable; that is consistent with, and does not
contradict, the C1 pointer→vendored-copy fix.

### Class D — a relative scratch directory that never existed at repo root

| id | file:line | failing command (verbatim) | observed |
|---|---|---|---|
| D1 | `corpus/lessons/r13-nav-review.md:14` | `/usr/bin/godot --headless --path nav-mutation-scratch --script res://navigation3d_path.gd -- --disconnected` | `exit=1` — `Invalid project path specified: "nav-mutation-scratch", aborting.` |

The lesson says "Private ignored `nav-mutation-scratch/…`" and names the *real* directory only inside a
longer prose sentence (`…/runs/20261013T040039134400Z/nav-mutation-scratch`). A reader who copies the
short form fails. This is the one case in the sample where the root is neither `.shokunin` nor `/tmp`.

### Class E — cited artifact gone, root fine (the *other* failure mode)

This is the class the brief's "never-existent **or** /tmp-rooted path citations" wording does not yet
separate, and it is the largest by count. The path prefix may be perfectly correct and the command still
cannot reproduce, because the cited receipt is gitignored and gone.

```
$ ls corpus/live/runs | wc -l                     → 48   (every entry is 20261018T…)
$ grep -rhoE '20261013T[0-9]{12}Z' corpus --include='*.md' | sort -u | wc -l   → 150
$ … same set … | while read t; do [ -e "corpus/live/runs/$t" ] || miss=$((miss+1)); done
cited=150 missing=150
```

**All 150 distinct `20261013T…` receipts cited across the corpus are absent from this repo.** So is
every bare `corpus/live/*.json` citation (34 distinct, all missing), and 171 of 172 distinct
`corpus/live/runs/<name>` citations. Cause is structural, not accidental:

```
$ cat corpus/.gitignore
live/
__pycache__/
*.pyc
$ git check-ignore -v corpus/live/runs/20261018T183407518519Z/verdicts.json
corpus/.gitignore:1:live/	corpus/live/runs/…
```

`live/` has always been ignored, so **no receipt was ever tracked** and none of the 150 can be restored
by any in-place edit. `corpus/fixtures/README.md` documents this correctly ("That tree is disposable"),
which makes the citation *form* in the lessons the defect: it is written as a durable path.

### Class F — prose pointer to a vanished file, read as an instruction

| id | file:line | citation | observed |
|---|---|---|---|
| F1 | `corpus/lessons/r15-slope-review.md:3`, `r6-isolation-review.md:3`, `r9-glb-review.md:3` | "Read standing mission `/tmp/mission-game-dev-3d-standing.md`" | `ls /tmp/mission-game-dev-3d-standing.md` → `exit=2`, `No such file or directory` |

Three files instruct the reader to read a file that does not exist and that the repo never tracked.
Unlike class C this is not even a scratch dir — it is a named deliverable of the old campaign.

---

## 4. What is NOT a candidate (kept deliberately)

Stated so a future ruling seat does not over-read this sweep:

- **`corpus/knowledge/unreal-mcp/**` `/tmp/ue-skills-ref` citations are not class-C defects today.**
  The clone exists; `git -C /tmp/ue-skills-ref rev-parse HEAD` is the pin check the subtree's own cards
  cite. This seat ran `ls -d /tmp/ue-skills-ref` → exists. Whether those should point at the vendored
  copy instead is exactly the round's **C1** claim, owned elsewhere; this seat makes no ruling on it.
- **Prose path citations of gone receipts are not the same defect as runnable ones.** A lesson that says
  "receipt `.shokunin/game-dev-3d/corpus/live/runs/20261013T030546459582Z/verdicts.json`" is a
  historical record of where a receipt landed on the day it was written; it is evidence about the
  author's run, and the receipt's disappearance is a property of the gitignored `live/` tree, not of
  the sentence. `reports/round-103/b2/adversary.md` reaches the same conclusion from the parent-repo
  symlink evidence and rules 164 of 167 files keep-worthy. This seat does not re-rule that; it records
  that its own independent counts (§2: 80 of 82 prefix hits are lessons) are consistent with it.
- **Worktree rows 3–4 of §2 read `→0` for a reason that is not a repair by this seat.** At the moment of
  the sample pass, two peer r103 seats had already edited those files in the worktree:

```
$ git status --porcelain | grep -v '^??'
 M corpus/artifacts/glb-r12/README.md
 M corpus/artifacts/unity-r19/README.md
 M corpus/knowledge/unreal-mcp/adaptation-kimi.md
 M corpus/knowledge/unreal-mcp/gate/README.md
$ git diff -- corpus/artifacts/glb-r12/README.md | head -12
-python3 .shokunin/game-dev-3d/corpus/artifacts/glb-r12/run_import.py
+python3 corpus/artifacts/glb-r12/run_import.py
…
$ git show HEAD:corpus/artifacts/glb-r12/README.md | grep -cE '\.shokunin/game-dev-3d'   → 3
$ git show HEAD:corpus/artifacts/unity-r19/README.md | grep -cE '\.shokunin/game-dev-3d' → 2
```

  So A1–A4 are **live at HEAD and already repaired in the worktree**; A5–A6
  (`corpus/fixtures/three/README.md`, 17 lines) are **live at HEAD and still unrepaired**. This seat
  wrote none of those four files.

---

## 5. Ranked candidate list for the future ruling

Ordered by (live failing command today, then blast radius). "Repair-eligible" here means *the defect is
in the command text itself and an in-place fix would not rewrite a historical claim* — the ruling itself
belongs to the L1/adjudicator, per the r102 fold-spec B2 precedent.

| rank | candidate | scale | class | live today | shape of a future ruling |
|---|---|---|---|---|---|
| 1 | `corpus/fixtures/three/README.md` | 17 lines, 1 file | A | yes | in-place command fix (mechanical); still open — **peer seat had it open at end of this seat** (worktree diff `17 insertions(+), 17 deletions(-)` vs HEAD, which still carries all 17) |
| 2 | `corpus/artifacts/glb-r12/README.md` + `unity-r19/README.md` | 3 + 2 lines | A | at HEAD yes; repaired in worktree | confirm the peer repair lands; no action from this seat |
| 3 | 12 sampled lesson "Reproduce" blocks + 68 more lesson files | 82 files | A | yes (first line of each block) | the systemic question the fold-spec already routed to the L1 (options R4-1..3); **not** a per-file sweep |
| 4 | 17 lesson files citing the absolute `prymeagnt/…/.shokunin/…` root | 47 lines | B | yes — Godot aborts, exit 1 | same ruling as #3; absolute form is strictly worse |
| 5 | 150 distinct `20261013T…` receipt citations | 75 files | E | unreproducible by construction | needs a **convention note**, not a repair: `live/` is gitignored, receipts are disposable by design |
| 6 | `/tmp`-rooted repro commands (14 cited paths already gone) | 24 files | C | partly | convention note: `/tmp` scratch is not a durable citation |
| 7 | `/tmp/mission-game-dev-3d-standing.md` | 3 files | F | yes | correction note; the file is unrecoverable and untracked |
| 8 | `corpus/lessons/r13-nav-review.md:14` relative scratch | 1 line | D | yes | in-place fix or explicit "scratch is gone" note |

---

## 6. Verification log (all commands run, all output observed)

```
# premises
$ git rev-parse HEAD                                    → c85a816e227984272a3c29b58aa7f7c1a76f1e9c
$ git log --all --oneline -- .shokunin                  → (empty)
$ git ls-tree HEAD .shokunin                            → (empty)
$ ls -ld /home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d
  → lrwxrwxrwx … -> ../../../shokunin/game-dev-3d-shokunin

# class A, verbatim from this repo root
$ python3 .shokunin/game-dev-3d/corpus/artifacts/glb-r12/run_import.py                    → exit=2
$ node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs                          → exit=1
$ npm ci --prefix .shokunin/game-dev-3d/corpus/fixtures/three                             → exit=1
$ uv run --no-project --with pyyaml python .shokunin/game-dev-3d/corpus/artifacts/unity-r19/verify_scene.py → exit=2
$ python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py                            → exit=2
$ cp .shokunin/game-dev-3d/corpus/fixtures/project.godot … /tmp/seat58-probe/             → exit=1

# controls, repo-relative twins
$ python3 corpus/artifacts/glb-r12/run_import.py                                          → exit=0
$ node corpus/fixtures/three/run_cases.mjs                                                → exit=0  (PASS three battery: 3/3)
$ uv run --no-project --with pyyaml python corpus/artifacts/unity-r19/verify_scene.py     → exit=0
$ python3 corpus/fixtures/run_battery.py --only raycast3d_hit                             → exit=0  (PASS battery, 2/2)

# parent-root control (why premise P1 matters)
$ cd /home/vgpnk/Projects/prymeagnt/game-dev-3d
$ python3 .shokunin/game-dev-3d/corpus/artifacts/glb-r12/run_import.py                    → exit=0
$ node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs                          → exit=0
$ python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only raycast3d_hit,raycast3d_miss → exit=0 (2/2 PASS)

# class B / C / D
$ /usr/bin/godot --headless --path /home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/review-r39-private-rotation/setter-only --script res://skeleton3d_rotation.gd --   → exit=1
$ /usr/bin/godot --headless --path /tmp/game-dev-3d-r55-far-review-jvdtidjr --script res://camera3d_ortho.gd -- --far-boundary-outside → exit=1
$ /usr/bin/godot --headless --path nav-mutation-scratch --script res://navigation3d_path.gd -- --disconnected → exit=1

# class E / F
$ ls corpus/live/runs | wc -l                                                            → 48
$ grep -rhoE '20261013T[0-9]{12}Z' corpus --include='*.md' | sort -u | wc -l             → 150
$ … | while read t; do [ -e "corpus/live/runs/$t" ] || miss=$((miss+1)); done            → cited=150 missing=150
$ grep -rhoE 'corpus/live/[A-Za-z0-9._-]+\.json' corpus --include='*.md' | sort -u       → 34 distinct, all MISSING
$ ls /tmp/mission-game-dev-3d-standing.md                                                → exit=2
$ ls -d /tmp/ue-skills-ref /tmp/r101-closeout                                            → both EXISTS
$ git check-ignore -v corpus/live/runs/20261018T183407518519Z/verdicts.json              → corpus/.gitignore:1:live/

# census
$ grep -rlE '\.shokunin/game-dev-3d/' corpus --include='*.md' | wc -l                     → 82  (80 lessons, 2 non-lesson)
$ grep -rlE '…(python3?|node|npm|uv|godot|bash|sh|cp|mkdir|sed|diff)[^|]*\.shokunin/' corpus --include='*.md' | wc -l → 82
$ grep -rlE '…[^|]*(/tmp/)' corpus --include='*.md' | wc -l                              → 24
$ grep -rl '/tmp/mission-game-dev-3d-standing.md' corpus --include='*.md' | wc -l        → 3
```

**Repo hygiene:** no tracked file was modified by this seat. At the time of this seat's sample pass
`git status --porcelain | grep -v '^??'` listed four `M` entries — all pre-existing edits by peer r103
seats (glb-r12 README, unity-r19 README, adaptation-kimi.md, gate/README.md), none written here; by the
end of the seat the list had grown to six as peer seats landed two more (three/README 17/17 lines,
gate/run_gate.sh). The only new path from this seat is this report plus gitignored
`corpus/live/runs/…` receipts from the two verification runs above.

---

## 7. Adjacent live defect observed while sweeping (NOT this seat's to fix)

Recorded because it was observed with a real command while this seat was verifying §3, and because it
is a **byte-pinned-tree** issue that a reader of this sweep would otherwise miss. No repair, no ruling.

`corpus/fixtures/phys3d_joints.gd:118-121` creates its child project inside the **current project root**
rather than a scratch copy:

```gdscript
var dirname := "r90bt_%s_%s_%s" % [arm, case, bk]
var dir := ProjectSettings.globalize_path("res://" + dirname)
if DirAccess.make_dir_recursive_absolute(dir) != OK:
```

So running that fixture with `--path` pointing at the seed tree writes into the seed tree. Observed:

```
$ ps -eo pid,etime,cmd | grep -- '--path corpus/fixtures'
4144624  00:19  timeout 120 /usr/bin/godot --headless --path corpus/fixtures \
                --script res://phys3d_joints.gd -- --arm=free_ops
$ git status --porcelain | grep -c 'r90bt'
21
$ git status --porcelain | grep 'r90bt' | head -3
?? corpus/fixtures/r90bt_free_ops_detachb_free_dummy/
?? corpus/fixtures/r90bt_free_ops_detachb_free_gp/
?? corpus/fixtures/r90bt_free_ops_detachb_free_jolt/
$ git log --all --oneline -- 'corpus/fixtures/r90bt_*' | wc -l
0
```

The count grew 2 → 5 → 10 → 17 → 21 across this seat's ~4 minutes of observation, timestamps
`2026-10-18T15:35:23` to `15:35:41` (-0300). They are **untracked** (`??`) and never tracked
(`git log --all` empty), so no tracked seed blob changed, and `corpus/fixtures/README.md:12-18`'s
promise ("Nothing here writes into the seeds") holds *for the blob map* while being violated *for the
directory*. `run_battery.py` is not the writer — it copies seeds to
`corpus/live/runs/<ts>/scratch` first (its own docstring, line 2); the writer is a peer seat's direct
`godot --path corpus/fixtures` invocation, which bypasses that isolation. The peer seat was still
running at the end of this seat's work, so **these directories were not cleaned up by this seat** —
deleting them could race a live run. Flagging for whoever owns `corpus/fixtures/**` cleanup.

**Handoff note for the ruling seat:** the single most useful correction this sweep contributes is that
"the `.shokunin/game-dev-3d/` root" is **two different problems**. A runnable command in a README is a
defect with a mechanical fix (ranks 1–2, 8). A citation of a gone receipt or a gone `/tmp` scratch
(ranks 5–7) is **not repairable by editing the path** — those artifacts are gitignored and were never
tracked, so the only honest fix is a convention note. Ranking them together will produce either a
history rewrite or a fix that does not fix anything.
