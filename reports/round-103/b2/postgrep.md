# B2 POSTGREP — post-repair sweep of the dead `.shokunin/game-dev-3d/` root

**Seat:** SEAT-31 B2-POSTGREP · round r103 · lane `game-dev-3d-shokunin`
**Repo:** `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`, HEAD `c85a816e227984272a3c29b58aa7f7c1a76f1e9c` (work `c6f655d`)
**Write scope:** this file only. No repository file was modified by this seat; no commit, push,
checkout or reset was run.
**Sweep timestamp (UTC):** `2026-10-18T18:35:50Z` (worktree state captured; see §4 for the
concurrent-repair timeline)

**Verdict:** the repair-eligible class is closed. **Dead roots in runnable contexts = 0** in the
worktree — all three routed READMEs (`glb-r12`, `unity-r19`, `three`) were repaired by concurrent
r103 seats during this sweep and each now greps **0**. Every surviving hit is a **keep** class:
dated historical record, correction-note quote, append-only ledger, digest-pinned fixture seed, or
machine-printed tool receipt. The repair was correct because it was the *only* class where the
prefix is an executable contract; every other class is a record of what the prefix *meant* on its
day.

**One flag for the L1 (§4.1):** the third repair (`corpus/fixtures/three/README.md`) landed inside
`corpus/fixtures/**`, a HARD-RULES-protected tree, **after** SEAT-55's ledger check had declared
that tree clean. The content change is substantively correct (that README is excluded from the seed
map, so nothing digest-pinned moved) but the scope question is unruled and SEAT-55's verdict is now
stale. Details and evidence in §4.1.

---

## 0. Method

A hit is **RUNNABLE-CONTEXT** if the line, taken as a shell line, is a command: command position
after an optional prompt (`$ `), an optional opening backtick, or a shell/code comment prefix
(`#`, `//`) — the last is the copy-paste-comment form the fixture seeds use. Everything else
(prose, headings, fenced **output**, JSON evidence fields) is **NARRATIVE**. The classifier is at
`/tmp/b2final.sh`; it writes `/tmp/b2_runnable.txt` and `/tmp/b2_narrative.txt`.

The two classes are what the B2 ruling turns on: a RUNNABLE hit in a *reproduction document* is a
live defect (it fails when pasted); a NARRATIVE hit is a record. The sweep also separates
**document-level** runnable hits (READMEs) from **comment-level** runnable hits (fixture seeds),
because the two have opposite dispositions (repair vs keep, §3 K4).

---

## 1. Dead roots in runnable contexts = 0 — the paste

### 1.1 The three repaired files now grep zero

```
$ for f in corpus/fixtures/three/README.md corpus/artifacts/glb-r12/README.md \
           corpus/artifacts/unity-r19/README.md; do
    echo -n "$f : "; grep -c "shokunin/game-dev-3d" "$f"
  done
corpus/fixtures/three/README.md : 0
corpus/artifacts/glb-r12/README.md : 0
corpus/artifacts/unity-r19/README.md : 0
```

### 1.2 The whole-repo sweep, post-repair

```
$ date -u +%FT%TZ
2026-10-18T18:35:50Z
$ /tmp/b2final.sh
FILES=164 RUNNABLE_HITS=147 NARRATIVE_HITS=506
```

### 1.3 No runnable hit remains outside the keep classes

```
$ grep '^RUNNABLE' /tmp/b2_runnable.txt | grep -v ' corpus/lessons/' | grep -v ' reports/'
RUNNABLE  corpus/fixtures/crash_exit3d.gd:2 :: # python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-crash-exit
RUNNABLE  corpus/fixtures/stream_attribution3d.gd:2 :: # python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-stream-attribution
RUNNABLE  corpus/fixtures/three/scene_graph.mjs:2 :: // npm ci --prefix .shokunin/game-dev-3d/corpus/fixtures/three
RUNNABLE  corpus/fixtures/three/scene_graph.mjs:3 :: // npm test --prefix .shokunin/game-dev-3d/corpus/fixtures/three
RUNNABLE  corpus/fixtures/three/scene_graph.mjs:4 :: // node .shokunin/game-dev-3d/corpus/fixtures/three/scene_graph.mjs --wrong-order
RUNNABLE  corpus/fixtures/three/scene_graph.mjs:5 :: // node .shokunin/game-dev-3d/corpus/fixtures/three/scene_graph.mjs --mutate-offset
RUNNABLE  corpus/fixtures/timeout_tree3d.gd:2 :: # python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout
```

**Exactly 7 runnable-context hits survive, all in one keep class (K4, §3).** Zero remain in any
reproduction document. Every other runnable hit — 140 of the 147 — is inside
`corpus/lessons/**` (109) or `reports/round-{70,71,101,102}/**` (31), i.e. dated historical
records (K2/K1, §3).

### 1.4 The context that proves the class is closed (before → after, same commands)

```
$ node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs ; echo "dead-prefix exit=$?"
dead-prefix exit=1                     # still fails — the prefix remains dead, as it always was

$ node corpus/fixtures/three/run_cases.mjs ; echo "repo-relative exit=$?"
PASS three battery: 3/3, seeds_unchanged=true
repo-relative exit=0
```

The repaired READMEs now instruct the form that passes:

```
$ python3 corpus/artifacts/glb-r12/run_import.py ; echo "exit=$?"
PASS Godot GLB import: valid/tolerated load, bad magic diagnosed and not loaded; receipt=…/corpus/live/runs/r12-import-20261018T183344513123Z/verdicts.json
exit=0
$ uv run --no-project --with pyyaml python corpus/artifacts/unity-r19/verify_scene.py ; echo "exit=$?"
PASS local-static actual=accept expected=accept … world=(11,2,-3) (local static derivation)
exit=0
```

### 1.5 The dead root itself, restated

```
$ ls -d .shokunin
ls: cannot access '.shokunin': No such file or directory
$ ls -d /home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d
/home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d
```

The prefix is dead **from this repo root** and live **only** in the predecessor `prymeagnt`
worktree — which is why every remaining hit is a record of a path that was correct when written
(SEAT-30 §1 independently derived that `.shokunin/game-dev-3d` was a real `040000 tree` until
`e1e863c3`, 2026-10-13 17:04, when it became a `120000` symlink).

---

## 2. Census

| metric | HEAD `c85a816` | worktree @ 18:35:50Z |
|---|---:|---:|
| files carrying the prefix | **167** | **164** |
| RUNNABLE-context hits | — | **147** |
| NARRATIVE hits | — | **506** |
| total worktree hits | — | **653** |
| dead roots in runnable **documents** | — | **0** |

The three-file delta (167 → 164) is exactly the repaired class. At HEAD those three files still
carry it (17 + 3 + 2 = **22 lines**), which is the historical record:

```
$ for f in corpus/fixtures/three/README.md corpus/artifacts/glb-r12/README.md \
           corpus/artifacts/unity-r19/README.md; do
    echo "HEAD:$f = $(git grep -c "shokunin/game-dev-3d" "HEAD:$f")"
  done
HEAD:corpus/fixtures/three/README.md = HEAD:corpus/fixtures/three/README.md:17
HEAD:corpus/artifacts/glb-r12/README.md = HEAD:corpus/artifacts/glb-r12/README.md:3
HEAD:corpus/artifacts/unity-r19/README.md = HEAD:corpus/artifacts/unity-r19/README.md:2
```

**Runnable hits by area (survivors, all keep):**

| area | runnable hits | class | disposition |
|---|---:|---|---|
| `corpus/lessons/**` | 109 | K1/K2 historical record | KEEP |
| `reports/round-102/**` | 23 | K2 (byte-pinned) | KEEP |
| `reports/round-101/**` | 4 | K2 (byte-pinned) | KEEP |
| `reports/round-{70,71}/**` | 4 | K2 | KEEP |
| `corpus/fixtures/**` (comment seeds) | **7** | K4 digest-pinned | KEEP |
| **total** | **147** | | |

**Narrative hits by area (survivors, all keep):**

| area | narrative hits |
|---|---:|
| `corpus/lessons/**` | 234 |
| `reports/round-102/**` | 138 |
| `reports/round-{69,70,71,72,73,74,75,76,77,78,86,89}/**` | 51 |
| `reports/round-101/**` | 3 |
| `LOG.md` | 73 |
| `PROVINCE.md` | 2 |
| `SCORECARD.md` | 2 |
| `corpus/artifacts/**` (REA receipts) | 3 |
| **total** | **506** |

---

## 3. Surviving hits with their keep-justification

Each row names the binding clause. `CORPUS.md` / `PROTOCOL.md` live at the fleet root
(`/home/vgpnk/Projects/shokunin/`), outside this lane repo.

### K1 — Correction-note quotes of the prefix itself

**Hit:** `corpus/lessons/r22-unreal-review.md` (narrative + its command blocks).
**Why keep:** the line's job is to *name* the prefix as the defect. A "sweep every mention" pass
would delete the record that the defect was found and leave the note self-contradictory.
`CORPUS.md:52` ("Corrections are new entries, never rewrites") and `PROTOCOL.md:123` bind it.
**Disposition:** KEEP. If the note's wording is later shown wrong, that is a **new appended
correction entry**, not an edit.

### K2 — Dated historical round reports

**Hits:** 71 files under `reports/round-{69..102}/`, incl. the **protected** `reports/round-101/**`
(4 runnable + 3 narrative) and `reports/round-102/**` (23 runnable + 138 narrative), byte-pinned by
this round's HARD RULES.
**Why keep:** per-round evidence whose numbers were measured on the trees of their day; rewriting
them would make a 2026-10-13 receipt appear to have been produced under a 2026-10-18 convention.
`PROTOCOL.md:123`, `CORPUS.md:52`. Includes `reports/round-102/adversary/F1.md` itself — the file
whose `git ls-tree` transcript proves the root was real.
**Disposition:** KEEP, all 71.

### K3 — Append-only ledger and write-scope declarations

**Hits:** `LOG.md` (73 narrative hits), `PROVINCE.md:25` (source-list prose) and `PROVINCE.md:46`
(the lane's **write-scope declaration**), `SCORECARD.md:8-9` (historical evidence rows).

```
$ sed -n '25p;46p' PROVINCE.md
- corpus fixtures under .shokunin/game-dev-3d/corpus/ (predecessor suite
Only writes `.shokunin/game-dev-3d/**` and its own reports. Domain source
```

**Why keep:** `LOG.md` is the append-only round ledger; `PROVINCE.md:46` is the clause that
authorises every seat's `corpus/**` writes — a sweep would edit the very rule it acts under.
`SCORECARD.md:8-9` are historical evidence cells (a dated r68/r70 row), not runnable commands.
**Disposition:** KEEP. `PROVINCE.md` is a fleet-level file; any change is an L1 act, not a seat's.

### K4 — Fixture seeds pinned by a cited SHA-256 ← the decisive keep class

**Hits (7 runnable-context lines):** `corpus/fixtures/three/scene_graph.mjs:2-5`,
`corpus/fixtures/crash_exit3d.gd:2`, `corpus/fixtures/stream_attribution3d.gd:2`,
`corpus/fixtures/timeout_tree3d.gd:2`.

```
$ sha256sum corpus/fixtures/crash_exit3d.gd corpus/fixtures/timeout_tree3d.gd \
             corpus/fixtures/stream_attribution3d.gd corpus/fixtures/three/scene_graph.mjs
efee43b93070f838d4174cfceacec98b056fb34c60525f0479e8e6e1e4c38f99  corpus/fixtures/crash_exit3d.gd
403a2e3e5f4a49fda283a147fd51577eda18a10a2d791cebb60be8d9d0712210  corpus/fixtures/timeout_tree3d.gd
ab923ceeac3797f1d0fabfd6695238f88529ef69fb9f452c45ec61b76eefa796  corpus/fixtures/stream_attribution3d.gd
e4bb0a136391cb42baafcbab4905e1c4004d316cec44f5f67519f37a2ab075af  corpus/fixtures/three/scene_graph.mjs

$ git grep -l e4bb0a136391cb42baafcbab4905e1c4004d316cec44f5f67519f37a2ab075af HEAD
HEAD:corpus/lessons/r22-unreal-review.md
HEAD:corpus/lessons/r63-three-ray-review.md
HEAD:reports/round-102/adversary/F3.md
HEAD:reports/round-102/before/F3-sha-drift.md
HEAD:reports/round-102/before/F5-engines-threejs.md
HEAD:reports/round-102/r22-crosscheck.md

$ git grep -l efee43b93070f838d4174cfceacec98b056fb34c60525f0479e8e6e1e4c38f99 HEAD
HEAD:corpus/lessons/r70-navagent-detour-non-author.json
```

**Why keep — this is harm, not hygiene.** Editing one comment byte in `crash_exit3d.gd` changes the
file's SHA-256, so the digest `efee43b93070…` cited in the landed r70 receipt stops resolving; the
receipt then looks like it recorded a wrong digest, and restoring conformance would force a
**second** rewrite downstream. `scene_graph.mjs`'s `e4bb0a13…` is cited in 6 files, same shape.
The comment lines are not the reproduction contract; the executable contract is the README (now
repaired) and `run_battery.py`'s own invocation. `PROTOCOL.md:339` (pointers must resolve) binds.
**Disposition:** KEEP, all 7 lines / 4 files.

### K5 — REA receipts whose machine-printed `local_path` is the predecessor path

**Hits:** `corpus/artifacts/glb-r9/rea-inspect-error.json`, `corpus/artifacts/zip-r10/rea-positive.json`,
`corpus/artifacts/zip-r10/rea-negative.json` — each a raw tool output whose `local_path` is
`/home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/…`.
**Why keep:** raw tool output, correct when printed (§1.5); editing it would forge a receipt.
**Disposition:** KEEP, all 3.

### The repaired class (now closed, 0 remaining)

| file | lines at HEAD | worktree | exit codes as written |
|---|---:|---:|---|
| `corpus/artifacts/glb-r12/README.md` | 3 | **0** | was `exit=2` → now `0` |
| `corpus/artifacts/unity-r19/README.md` | 2 | **0** | was `exit=2` → now `0` |
| `corpus/fixtures/three/README.md` | 17 | **0** | was `exit=1` → now `0` |

`git diff --stat` over the three: `3 files changed, 22 insertions(+), 22 deletions(-)` — a pure
prefix-drop, no other content touched.

---

## 4. Concurrent-repair timeline (why this seat's sweep changed mid-run)

The three READMEs were repaired **by other r103 seats while this sweep ran**, so the census moved
under the sweep. Observed on `git status --porcelain`:

| time (UTC) | event |
|---|---|
| 18:32:28 | `unity-r19/README.md` already ` M` (peer repair, 2-line hunk) |
| 18:33:56 | `glb-r12/README.md` appears as ` M` (peer repair, 3 lines) |
| 18:35:40 | `corpus/fixtures/three/README.md` appears as ` M` (peer repair, 17 lines) |
| 18:35:50 | this seat's frozen post-repair sweep: 0 dead roots in runnable documents |

This is the same live-mutation fact SEAT-30 (`reports/round-103/b2/adversary.md` §4) and SEAT-55
(`reports/round-103/seats-ledger.md` §5) independently recorded. **Any folding seat must re-run the
census before acting**; §2 is a frame with a timestamp, not a constant. The repairs landed as
working-tree edits only — nothing was committed.

### 4.1 ⚠ ONE REPAIR LANDED INSIDE A HARD-RULES-PROTECTED TREE — flag for the L1

`corpus/fixtures/three/README.md` sits under **`corpus/fixtures/**`**, which this round's HARD RULES
list as byte-pinned/protected. SEAT-25 (`reports/round-103/b2/repair-three.md`) edited it anyway, and
SEAT-55's ledger check (`reports/round-103/seats-ledger.md`), which answers the explicit question
*"did any r103 seat write … anything under `corpus/fixtures/`?"* with **"no"**, is **stale** — its
snapshot is superseded by this edit:

```
$ stat -c '%y %n' corpus/fixtures/three/README.md reports/round-103/seats-ledger.md
2026-10-18 15:35:34 -0300 corpus/fixtures/three/README.md     # = 18:35:34Z  ← the edit
2026-10-18 15:32:35 -0300 reports/round-103/seats-ledger.md   # = 18:32:35Z  ← the verdict

$ for d in corpus/fixtures; do git diff --quiet HEAD -- "$d" || git diff --name-only HEAD -- "$d"; done
corpus/fixtures/three/README.md
```

SEAT-55's confirming snapshot was `2026-10-18T18:32:22Z` (§0); the edit landed **~3 minutes later**.
So SEAT-55's "protected paths byte-identical to HEAD" was true when measured and is **false now**.
This is a live conformance question the L1 must rule on — not something this seat can settle:

- **For the edit:** SEAT-25's substantive justification is correct and I re-verified it independently.
  `run_battery.py:946` excludes the whole `three/` subtree from the seed map
  (`path.relative_to(HERE).parts[0] != "three"`), so this README is **not** digest-pinned, and its old
  digest `ebd2d97e…` is cited nowhere in HEAD (`git grep -l ebd2d97e… HEAD` → no output). The r56
  digest `8ff28c04…` that `adversary.md` §K4 worried about belongs to `corpus/fixtures/README.md`,
  a different file. The diff is a pure 17-line prefix-drop (no narrative byte changed).
- **Against the edit:** the HARD RULES name `corpus/fixtures/**` as protected without an exception for
  READMEs. A seat that owns only `reports/…` writing into the pinned tree is a scope breach even when
  the content change is defensible — and it invalidates a sibling seat's ledger verdict.

**Recommendation to the L1:** rule explicitly whether `corpus/fixtures/*/README.md` (non-seed
documentation, excluded from `seed_digests()`) is in or out of the `corpus/fixtures/**` pin. Either
way, SEAT-55's verdict needs an appended correction entry rather than being left to stand as a false
clean (this seat did **not** write SEAT-55's file).

---

## 5. Limits of this file

- **No Unreal runtime claim appears in this file.** Unreal Editor is not installed on this host and
  live-MCP behaviour is unproven by construction; nothing here is evidence of engine behaviour.
- The sweep measures **path conformance from this repo root**, not the factual correctness of any
  historical record. §1.5 shows the prefix was real where the historical rounds ran.
- The classifier is a heuristic on line shape. It is deliberately over-inclusive on the RUNNABLE
  side (it counts comment lines), so "0 dead roots in runnable documents" is a *lower bound* on the
  repair — every document-level command was also read by eye in §1.4 and executed.
- This seat wrote **only** `reports/round-103/b2/postgrep.md`. No source file, lesson, fixture,
  manifest, receipt, or other seat's report was modified; no commit, push, checkout or reset was run.

---

## 6. Reproduce this sweep

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin

# §1.1 — the repaired class greps zero
for f in corpus/fixtures/three/README.md corpus/artifacts/glb-r12/README.md \
         corpus/artifacts/unity-r19/README.md; do echo -n "$f : "; grep -c "shokunin/game-dev-3d" "$f"; done

# §1.2 — the classified sweep (script writes /tmp/b2_runnable.txt, /tmp/b2_narrative.txt)
bash /tmp/b2final.sh                 # FILES=164 RUNNABLE_HITS=147 NARRATIVE_HITS=506

# §1.3 — no runnable hit outside the keep classes
grep '^RUNNABLE' /tmp/b2_runnable.txt | grep -v ' corpus/lessons/' | grep -v ' reports/'

# §1.4 — the repaired commands pass; the dead prefix still fails
node corpus/fixtures/three/run_cases.mjs; echo "exit=$?"                              # 0
node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs; echo "exit=$?"        # 1
python3 corpus/artifacts/glb-r12/run_import.py; echo "exit=$?"                        # 0
uv run --no-project --with pyyaml python corpus/artifacts/unity-r19/verify_scene.py; echo "exit=$?"  # 0

# §2 — census
git grep -l "\.shokunin/game-dev-3d" | wc -l        # 164 (worktree, post-repair)
git grep -l "\.shokunin/game-dev-3d" HEAD | wc -l   # 167 (HEAD, historical)

# §3 K4 — the decisive keep class: cited digests
sha256sum corpus/fixtures/crash_exit3d.gd
git grep -l efee43b93070f838d4174cfceacec98b056fb34c60525f0479e8e6e1e4c38f99 HEAD
git grep -l e4bb0a136391cb42baafcbab4905e1c4004d316cec44f5f67519f37a2ab075af HEAD
```
