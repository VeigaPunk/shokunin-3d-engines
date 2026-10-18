# B2 — DEAD-ROOT ADVERSARY: the keep-list (classes that must NOT be repaired)

**Seat:** SEAT-30 DEADROOT-ADVERSARY · round r103 · lane `game-dev-3d-shokunin`
**Repo:** `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`, HEAD `c85a816` (work `c6f655d`)
**Write scope:** this file only. No repository file was modified by this seat.
**Charge:** argue that at least one class of `.shokunin/game-dev-3d/` hit must **not** be repaired, and
deliver the ruled keep-list with citations.

**Verdict up front:** the repair-eligible class is **3 files / 22 lines**, and one of those three is
already fixed. Everything else — **164 of 167 files** — must be kept. The single strongest
must-not-repair argument is not "history is sacred": it is that **repairing the class-B fixture seeds
falsifies a different, already-landed, higher-value claim** (a cited SHA-256). Repair of that class is
harm, not hygiene.

---

## 1. The premise correction that reframes the whole question

r102 SEAT-11 (`reports/round-102/adversary/F1.md` §5 R1) refuted the r101 premise "that root has never
existed". This seat re-ran the refutation on the parent repo:

```
$ cd ~/Projects/prymeagnt
$ git ls-tree e1e863c3^ -- .shokunin/game-dev-3d
040000 tree 4b1e5ee6cb79a5aba3215c7f68eb8a1b517f9c95	.shokunin/game-dev-3d
$ git ls-tree e1e863c3  -- .shokunin/game-dev-3d
120000 blob 2577e66d02e72db8da25ae149207c7aed7b37050	.shokunin/game-dev-3d
$ git log -1 --format='%ad %H' --date=iso e1e863c3
2026-10-13 17:04:15 -0300 e1e863c3f755247523d1d694216fce69d4353249
```

**Confirmed.** `.shokunin/game-dev-3d` was a real tracked directory (`040000 tree`) that became a
symlink (`120000 blob`) at `e1e863c3`, on 2026-10-13 at 17:04. Rounds r1–r68 were authored **before**
that extraction, inside a `prymeagnt` worktree where the prefix resolved. The literal
`/home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/...` is *recorded inside the r10 REA
receipts themselves* (§4 below), which is the machine-printed proof that the path was live.

**Consequence for the ruling:** every hit is a *path-conformance* defect measured from *this* repo root.
It is **not** a factual error about what the author did. That distinction is what makes the historical
classes keep-worthy and what makes an unbounded sweep a history rewrite.

---

## 2. The census (re-measured on HEAD `c85a816`; the r102 figure is stale)

The r102 fold-spec carries `git grep -l "\.shokunin/game-dev-3d" HEAD | wc -l → 142`. That number is
superseded — r102's own 26 report files added hits:

```
$ git grep -l "\.shokunin/game-dev-3d" HEAD | wc -l      → 167   (files, HEAD)
$ git grep -h "\.shokunin/game-dev-3d" HEAD | wc -l      → 675   (lines, HEAD)
$ git grep -l "\.shokunin/game-dev-3d" | wc -l           → 166   (worktree; unity-r19 fixed in flight)
$ grep -rl "\.shokunin/game-dev-3d" . | wc -l            → 162   (raw, uncommitted incl.)
```

Line-shape split of the **675 escaped** HEAD lines
(`git grep -h "\.shokunin/game-dev-3d" HEAD | grep -cE '(^|[`\s])(python3?|node|npm|uv|npx)\s'`):

| shape | escaped (675) | unescaped (1076) |
|---|---:|---:|
| command-shaped (class B candidates) | 242 | 254 |
| prose / meta / narrative (class A/C) | 433 | 822 |

So **at most 242 of 675 lines** are even candidates for the mechanical class, and §4 shows the
document-level surface is far smaller than that (22 lines across 3 READMEs).

Distribution by directory (`HEAD:`, escaped literal):

| directory | files |
|---|---:|
| `corpus/lessons` | 83 |
| `reports/round-102` | 26 |
| `reports/round-{69..101}` | 45 |
| `corpus/fixtures` | 5 |
| `corpus/artifacts` | 5 |
| `PROVINCE.md` / `LOG.md` / `SCORECARD.md` | 3 |
| **total** | **167** |

---

## 3. The keep-list (MUST NOT be repaired) — with the reason and the citation

Each row names the binding clause. `CORPUS.md` and `PROTOCOL.md` live at
`/home/vgpnk/Projects/shokunin/` (fleet root), not in the lane repo.

### K1 — Correction-note quotes of the prefix itself

**Hit:** `corpus/lessons/r22-unreal-review.md:55` — the r102 correction note, which *quotes the defect*:

```
> - The two command blocks in this lesson were re-rooted in r102 from a never-existent `.shokunin/game-dev-3d/` prefix …
```

**Why keep:** this line's job is to *name* the prefix as the defect. A "sweep every mention" pass that
rewrote it would delete the record that the defect was ever found — the note would become
self-contradictory ("re-rooted from a  prefix"). `CORPUS.md:52` ("**Corrections are new entries, never
rewrites.**") and `PROTOCOL.md:123` ("append-only files … take an appended correction entry pointing at
the superseded text, **never an in-place rewrite**") bind it.

**Ruled disposition:** **KEEP.** If the note's *wording* is now known to be wrong (it says
"never-existent", which §1 refutes), that is a **new appended correction entry**, not an edit of line 55.

### K2 — Dated historical round reports

**Hits:** 71 files under `reports/round-{69..102}/`, including the **protected** `reports/round-101/**`
and `reports/round-102/**` (28 files, byte-pinned by this round's own HARD RULES).

**Why keep:** these are per-round evidence records whose numbers were measured on the trees of their
day. `PROTOCOL.md:123` and `CORPUS.md:52` forbid in-place rewrite; the lane's own round rule
additionally byte-pins r101/r102. Rewriting `reports/round-70/r70-baseline.md`'s command would make a
2026-10-13 receipt appear to have been produced with a 2026-10-18 path convention.

**Ruled disposition:** **KEEP, all 71.** Includes `reports/round-102/adversary/F1.md` itself — the
ruling that this file cites. Deleting the prefix from F1 would erase the `git ls-tree` transcript that
*proves* §1.

### K3 — Append-only ledger and write-scope declarations

**Hits:** `LOG.md` (73 hit lines), `PROVINCE.md:25` and `PROVINCE.md:46`.

```
$ sed -n '25p;46p' PROVINCE.md
- corpus fixtures under .shokunin/game-dev-3d/corpus/ (predecessor suite
Only writes `.shokunin/game-dev-3d/**` and its own reports. Domain source
```

**Why keep:** `LOG.md` is the append-only round ledger (`PROTOCOL.md:123`). `PROVINCE.md:46` is the
lane's **write-scope declaration** — the clause that authorises every seat's `corpus/**` writes. A
sweep that rewrites it edits the very rule it is acting under, and (as SEAT-11 R3 already noted) would
leave the lane self-inconsistent. Both files are also outside every r103 seat's write scope.

**Ruled disposition:** **KEEP.** `PROVINCE.md` is a fleet-level file; any change is an L1 act, not a seat's.

### K4 — Fixture seeds inside the `seed_digests()` map ← the decisive must-not-repair class

**Hits:** `corpus/fixtures/crash_exit3d.gd:2`, `corpus/fixtures/stream_attribution3d.gd:2`,
`corpus/fixtures/timeout_tree3d.gd:2`, `corpus/fixtures/three/scene_graph.mjs:2-4` — each a comment
line carrying a copy-paste command.

**Why keep — this is harm, not hygiene.** These files are hashed by the battery's own seed map, and the
resulting digest is a **cited, landed evidence value**:

```
$ python3 -c "…import run_battery… print(len(m.seed_digests()))"
entries: 130                      # includes crash_exit3d.gd, stream_attribution3d.gd, timeout_tree3d.gd
$ sha256sum corpus/fixtures/crash_exit3d.gd
efee43b93070f838d4174cfceacec98b056fb34c60525f0479e8e6e1e4c38f99  corpus/fixtures/crash_exit3d.gd
$ git grep -l efee43b93070f838d4174cfceacec98b056fb34c60525f0479e8e6e1e4c38f99 HEAD
HEAD:corpus/lessons/r70-navagent-detour-non-author.json
$ python3 -c "…json walk…"
/seed_digests/crash_exit3d.gd = efee43b93070f838d417
/probe/seed_digests_before/crash_exit3d.gd = efee43b93070f838d417
/probe/seed_digests_after/crash_exit3d.gd = efee43b93070f838d417
```

`corpus/lessons/r70-navagent-detour-non-author.json` is a **landed raw receipt** that records
`efee43b93070…` as the digest of `crash_exit3d.gd` and asserts `seeds_unchanged: true`. Editing one
comment byte in that seed:

1. changes the file's SHA-256, so the cited `efee43b93070…` **stops resolving** — a fresh run now emits a
   different digest for the same seed name;
2. makes the r70 receipt look like it recorded a **wrong digest**, when it was right on its day;
3. to restore conformance you would then have to rewrite the r70 receipt too — i.e. the path fix
   **propagates a rewrite into a second, higher-value record**.

That is exactly the failure mode SEAT-11 R3 warned about, one layer deeper: a one-file "mechanical" fix
that **creates** a new defect. `scene_graph.mjs` is the same shape at one remove: it is excluded from
`seed_digests()` (the map skips `three/`), but its SHA-256 `e4bb0a136391cb42baafcbab4905e1c4004d316cec44f5f67519f37a2ab075af`
is cited in **6** files:

```
$ git grep -l e4bb0a136391cb42baafcbab4905e1c4004d316cec44f5f67519f37a2ab075af HEAD
HEAD:corpus/lessons/r22-unreal-review.md
HEAD:corpus/lessons/r63-three-ray-review.md
HEAD:reports/round-102/adversary/F3.md
HEAD:reports/round-102/before/F3-sha-drift.md
HEAD:reports/round-102/before/F5-engines-threejs.md
HEAD:reports/round-102/r22-crosscheck.md
```

**Ruled disposition:** **KEEP, all 4.** The comment lines are not the reproduction contract; the
executable contract is the README (K5) and `run_battery.py`'s own invocation. Fixing a comment inside a
digest-pinned seed costs more conformance than it buys.

### K5 — `corpus/fixtures/three/README.md` — repair-eligible, but NOT a clean case

This is the 17-hit file and the biggest single candidate. It is **class B and repair-eligible**, but with
a caveat that belongs in the keep-list discussion: it is itself a seed-adjacent document whose digest
has been cited in prior lessons (the r56 reviews record `README.md` digest drift as a load-bearing
finding). A repair here must be **declared as a path-conformance change and carry its own note** — the
r22 precedent (`reports/round-102/repairs/F1b-F2-r22-lesson.md`) shows exactly how. **Not a keep; a
repair with a mandatory declaration.**

---

## 4. The repair-eligible class, bounded

**Class B, runnable command blocks in a document that is itself the reproduction contract:**

| file | hit lines | state | exit codes as written |
|---|---:|---|---|
| `corpus/artifacts/glb-r12/README.md` | 3 | unfixed | `exit=2` |
| `corpus/artifacts/unity-r19/README.md` | 2 | **already fixed in worktree** | was `exit=2` |
| `corpus/fixtures/three/README.md` | 17 | unfixed | `exit=1` |

Verbatim, run from the repo root this round:

```
$ python3 .shokunin/game-dev-3d/corpus/artifacts/glb-r12/run_import.py                    → exit=2
$ uv run --no-project --with pyyaml python .shokunin/game-dev-3d/corpus/artifacts/unity-r19/verify_scene.py → exit=2
$ node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs                          → exit=1
```

**Live finding for the L1:** `corpus/artifacts/unity-r19/README.md` is **already repaired in the working
tree** by a concurrent r103 seat — it is no longer in the defect set:

```
$ git status --porcelain
 M corpus/artifacts/unity-r19/README.md
$ git diff -- corpus/artifacts/unity-r19/README.md
-uv run --no-project --with pyyaml python .shokunin/game-dev-3d/corpus/artifacts/unity-r19/verify_scene.py
+uv run --no-project --with pyyaml python corpus/artifacts/unity-r19/verify_scene.py
```

So the true remaining repair surface is **glb-r12 (3 lines) + three (17 lines) = 20 lines / 2 files**,
not 22 / 3. The L1 must not re-dispatch unity-r19, and must ensure the in-flight edit carries its
declaration rather than landing as a silent rewrite.

**Also in the repair-eligible class but not documents:** `corpus/artifacts/{glb-r9/rea-inspect-error.json,
zip-r10/rea-positive.json, zip-r10/rea-negative.json}` — three REA receipts whose *machine-printed*
`local_path` is `/home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/…`. These are
**KEEP** (class A/C): they are raw tool output, and §1 shows that path was correct when printed. Editing
them would forge a receipt. They are listed here only so the L1 does not mistake them for the README class.

---

## 5. The ruled keep-list (one table)

| # | class | count | disposition | binding clause |
|---|---|---|---|---|
| K1 | correction-note quotes (`r22-unreal-review.md:55`) | 1 line | **KEEP** — new appended note if wording is wrong | `CORPUS.md:52`, `PROTOCOL.md:123` |
| K2 | dated round reports `reports/round-{69..102}/` | 71 files | **KEEP** (r101/r102 byte-pinned) | `CORPUS.md:52`, `PROTOCOL.md:123` |
| K3 | `LOG.md`, `PROVINCE.md`, `SCORECARD.md` | 3 files | **KEEP** — L1 act only | `PROTOCOL.md:123`; `PROVINCE.md:46` |
| K4 | digest-pinned fixture seeds (`.gd`×3, `.mjs`) | 4 files | **KEEP** — repair falsifies a cited SHA-256 | `PROTOCOL.md:339` (pointer must resolve) |
| K5 | REA receipts with printed `prymeagnt` paths | 3 files | **KEEP** — raw tool output, correct on its day | §1 evidence |
| — | class B command blocks in reproduction READMEs | **20 lines / 2 files** | **REPAIR**, with a declared note | `PROTOCOL.md:341` |

**Net:** 164 of 167 files keep. 2 files repair. 1 (unity-r19) is already repaired in flight.

---

## 6. Where this seat agrees with, and departs from, SEAT-11

- **Agrees:** R1 (premise refuted — independently re-derived, §1); R2 (narrative rewrite forbidden);
  R4 option 3 rejected (full sweep of the class); R5 flagged (the r22 line-7 rewrite).
- **Sharpens R5:** the non-conformant rewrite SEAT-11 flagged is now **landed at HEAD**, not merely in a
  working tree:

  ```
  $ git show HEAD:corpus/lessons/r22-unreal-review.md | sed -n '7p'
  … I checked `LOG.md` round 22, `PROVINCE.md`, and `corpus/artifacts/unreal-r22/README.md`. …
  ```

  Line 7 no longer carries the prefix at HEAD. So SEAT-11's R5 option (a) "restore line 7" is no longer
  available without rewriting a landed commit — which `PROTOCOL.md:123` forbids. The only live remedy is
  R5 option (b) plus a correction note, and the L1 should rule on that explicitly rather than let it sit.
- **Departs on the decisive reason:** SEAT-11 argued keep on *record-integrity* grounds. This seat adds
  K4, which is a stronger and less arguable ground: repairing the fixture seeds **breaks a cited digest**
  and forces a second rewrite downstream. K4 is why "repair everything mechanical" is not merely
  unwise but falsifiable — it can be shown to create a new conformance defect.
- **Departs on scope:** SEAT-11's 142 is stale; the census is 167/675. Any L1 ruling must be pinned to a
  re-measured number, not to r102's frame (`reports/round-102/fold-spec.md` §8 already warns its counts
  are "a frame, not a constant").

---

## 7. Limits of this file

- **No Unreal runtime claim appears in this file.** Unreal Editor is not installed on this host and
  live-MCP behaviour is unproven by construction; nothing here is evidence of engine behaviour.
- Every number above was measured on HEAD `c85a816` this round with the command shown. The tree is
  mutating under concurrent seats — the unity-r19 in-flight edit proves it — so a folding seat must
  re-run the census before acting. Treat §2 as a frame with a timestamp, not a constant.
- This seat wrote **only** `reports/round-103/b2/adversary.md`. No source file, lesson, fixture,
  manifest, receipt, or other seat's report was modified; no commit, push, checkout, or reset was run.

---

## 8. Reproduce this ruling

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin

# §1 — the root was real, then symlinked
cd ~/Projects/prymeagnt
git ls-tree e1e863c3^ -- .shokunin/game-dev-3d     # 040000 tree
git ls-tree e1e863c3  -- .shokunin/game-dev-3d     # 120000 blob
git log -1 --format='%ad' --date=iso e1e863c3      # 2026-10-13 17:04:15
cd -

# §2 — the census (r102's 142 is stale)
git grep -l "\.shokunin/game-dev-3d" HEAD | wc -l  # 167
git grep -h "\.shokunin/game-dev-3d" HEAD | wc -l  # 675
git grep -l "\.shokunin/game-dev-3d" HEAD | sed 's|^HEAD:||' \
  | awk -F/ '{if($1=="reports")print $1"/"$2; else if($1=="corpus")print $1"/"$2; else print $1}' \
  | sort | uniq -c | sort -rn

# §3 K4 — the decisive class: a seed whose digest is cited in a landed receipt
sha256sum corpus/fixtures/crash_exit3d.gd
git grep -l efee43b93070f838d4174cfceacec98b056fb34c60525f0479e8e6e1e4c38f99 HEAD
python3 -c "
import importlib.util
s=importlib.util.spec_from_file_location('rb','corpus/fixtures/run_battery.py')
m=importlib.util.module_from_spec(s); s.loader.exec_module(m)
print('seed_digests entries:', len(m.seed_digests()))"

# §4 — the repair-eligible class, verbatim from the repo root
python3 .shokunin/game-dev-3d/corpus/artifacts/glb-r12/run_import.py; echo "exit=$?"   # 2
node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs; echo "exit=$?"         # 1
git status --porcelain                            # M corpus/artifacts/unity-r19/README.md (in flight)
```
