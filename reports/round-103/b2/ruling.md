# B2 — PER-FILE RULING: in-place mechanical repair vs dated correction note

**Seat:** SEAT-22 B2-RULING · round r103 · lane `game-dev-3d-shokunin`
**Owned path written:** `reports/round-103/b2/ruling.md` (only). No tracked file was touched by this seat.
**Repo:** `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`, HEAD `c85a816` (r102 report-last; work `c6f655d`)
**Date:** 2026-10-18 (evidence window closed `2026-10-18T18:38Z`)
**Inputs read:** `reports/round-103/b2/scanner.md` (SEAT-21), `reports/round-102/adversary/F1.md` (SEAT-11),
`reports/round-103/b2/adversary.md` (SEAT-30), `reports/round-103/b2/repair-glb.md` (SEAT-23),
`reports/round-103/b2/verify-unity.md` (SEAT-27), `reports/round-102/fold-spec.md` §B2.
**No Unreal/Unity runtime claim is made or implied anywhere in this file.**

---

## 0. Verdict up front

| # | File | lines | HEAD digest | **cited in HEAD?** | RULED DISPOSITION | owner |
|---|---|---:|---|---:|---|---|
| 1 | `corpus/artifacts/glb-r12/README.md` | 3 | `0af4f3691e19f858…` | **0** | **in-place mechanical repair** — clean | SEAT-23 |
| 2 | `corpus/artifacts/unity-r19/README.md` | 2 | `c4463ab5ef137acc…` | **2** | **in-place repair permitted, AND a dated correction note is REQUIRED on the two citing lessons** | SEAT-24 (+ routed note owner, §4) |
| 3 | `corpus/fixtures/three/README.md` | 17 | `ebd2d97ef69d0a7c…` | **0** | **in-place mechanical repair** — clean | SEAT-25 |
| — | `corpus/fixtures/{three/scene_graph.mjs,crash_exit3d.gd,timeout_tree3d.gd,stream_attribution3d.gd}` | 7 | cited ×6 / ×1 | **≥1** | **KEEP — never repair** | nobody |

**All three repairs have already landed and been independently verified** (§5). This ruling creates
**two open items**: the unity correction note (§3.2 → §4) and the r22 line-7 standing defect
(§3.5 → §4). Both are routed to the L1 because no r103 seat's declared scope names the files.

---

## 1. The deciding rule (cited verbatim, with line numbers)

The r102 adversary framework (SEAT-11, `reports/round-102/adversary/F1.md` §3, §5 R2/R3) splits the
hits into classes, and the split is what decides in-place vs note:

| class | nature | disposition | binding clause |
|---|---|---|---|
| **A** | narrative/historical prose — a first-person record of what an author did | **dated correction note**, appended; in-place rewrite forbidden | `CORPUS.md:52` · `PROTOCOL.md:123` |
| **B** | a literal runnable command block in a document that *is* the reproduction contract | **in-place mechanical repair permitted** | `PROTOCOL.md:341` |
| **C** | a quote of the defect inside a correction note | **KEEP** | `CORPUS.md:52` |

Verbatim, the three load-bearing clauses:

**`~/.kimi-code/skills/shokunin/protocol/PROTOCOL.md:341`** — the clause that *licenses* class-B repair:

> An evidence pointer must resolve at *closure* time, not only at write time: paths under `tmpfs`
> (`/tmp`, `/dev/shm`), session-scoped `local://` artifacts, and any pointer a fresh session cannot
> reach are not evidence — commit the artifact or cite a reproducible command.

**`~/.kimi-code/skills/shokunin/protocol/CORPUS.md:52`** — the clause that *forbids* class-A rewrite:

> - **Corrections are new entries, never rewrites.** Lanes own
>   `lessons/round-<N>.md`; the aggregator writes only
>   `lessons/round-<N>-aggregator-*.md` and does not edit lane-authored corpus
>   files in place …

**`~/.kimi-code/skills/shokunin/protocol/PROTOCOL.md:351`** — the clause that converts a *collateral*
stale citation into a note:

> - **A falsified claim in an append-only file gets a named correction entry in the lane's next
>   round** — appended, never rewritten; it stays on the routed-defect queue until it lands.

**The refinement this ruling adds (and the reason it is per-file, not per-class):** class-B repair is
licensed by `PROTOCOL.md:341`, but it is **overridden** when the file's bytes are themselves a *cited
value*. That is SEAT-30's K4 harm mode (`reports/round-103/b2/adversary.md` §3 K4): editing a byte in
a digest-pinned file makes a landed citation **stop resolving**, so the "mechanical" fix *creates* a
new defect — the exact failure `PROTOCOL.md:341` exists to prevent. **The discriminator is therefore a
one-command test, applied per file:**

```sh
s=$(git show HEAD:<file> | sha256sum | cut -d' ' -f1); git grep -l "$s" HEAD | wc -l
```

`0` → the repair is clean. `≥1` → the repair falsifies a citation and **must be paired with a dated
correction note** on each citing record. This test was run for all three files; results are §0's
`cited in HEAD?` column.

---

## 2. The census this ruling acts on (re-derived, not quoted)

SEAT-21's scanner is authoritative; this seat re-ran the decisive counts on the live tree.

The raw pattern matches **two unrelated strings**, and only one is a defect
(`reports/round-103/b2/scanner.md` §1) — a census that quotes the raw count is wrong by ~1.7×:

```
$ grep -c '\.shokunin/game-dev-3d/' /tmp/b2_hits.txt        → 520   (D family — the defect)
$ grep -c 'shokunin/game-dev-3d-shokunin' /tmp/b2_hits.txt  → 286   (L family — correct today)
```

**The defect is cwd-conditional, not a phantom path** (scanner §3.3). The predecessor worktree still
hosts a live symlink:

```
$ readlink -f /home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d
/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
$ cd /home/vgpnk/Projects/prymeagnt/game-dev-3d && python3 .shokunin/game-dev-3d/corpus/artifacts/glb-r12/run_import.py
PASS Godot GLB import: …                                                    exit=0
```

So the prefix **resolves from the predecessor worktree and dies from the canonical repo root**. Every
defective README in scope says *"From the repository root"* — the documented cwd is the one where the
prefix dies. That is why the repair is correct and why **class A2 (317 lines in dated
`corpus/lessons/**` and `reports/round-{69..102}/**`) must be kept**: those seats genuinely worked in
the worktree, and rewriting their records would falsify them.

Post-repair corpus-scoped census (this seat, run at `2026-10-18T18:37Z`):

```
$ grep -rl '\.shokunin/game-dev-3d/' corpus/ --include='*.md' --include='*.py' --include='*.mjs' --include='*.sh' | wc -l
81
$ … | grep -v 'corpus/lessons/'
corpus/fixtures/three/scene_graph.mjs          ← the single non-lesson survivor, §3
$ grep -c '\.shokunin/game-dev-3d/' corpus/fixtures/three/README.md \
        corpus/artifacts/glb-r12/README.md corpus/artifacts/unity-r19/README.md
corpus/fixtures/three/README.md:0
corpus/artifacts/glb-r12/README.md:0
corpus/artifacts/unity-r19/README.md:0
```

**Zero dead-root lines remain in any reproduction-contract README.** The 81-file corpus remainder is
80 lessons (class A2, keep) + `scene_graph.mjs` (class K4, keep).

---

## 3. Per-file ruling

### 3.1 `corpus/artifacts/glb-r12/README.md` — **in-place mechanical repair** · owner **SEAT-23**

**Defect lines (HEAD):** 6, 7, 8 — three commands under the heading *"From the repo root run:"*.
**Class:** pure **B** — every one of the 3 dead-root lines is a command; **0 narrative lines**.

```
$ git show HEAD:corpus/artifacts/glb-r12/README.md | grep -n 'shokunin/game-dev-3d'
6:python3 .shokunin/game-dev-3d/corpus/artifacts/glb-r12/run_import.py
7:python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py
8:node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs
```

**Deciding test:** pre-repair digest `0af4f3691e19f858…`, **cited in HEAD → 0** (run in §1's form).
The K4 override does not fire. `PROTOCOL.md:341` licenses the in-place fix outright.

**Before (exit 2), after (exit 0)** — this seat re-ran both arms:

```
$ python3 .shokunin/game-dev-3d/corpus/artifacts/glb-r12/run_import.py   → exit=2
$ python3 corpus/artifacts/glb-r12/run_import.py                        → exit=0
$ python3 corpus/fixtures/run_battery.py --only floor3d_ground          → exit=0
$ node corpus/fixtures/three/run_cases.mjs                              → exit=0
```

**RULED: in-place mechanical repair.** No correction note required (no historical claim, no cited
value). SEAT-23's own note (`reports/round-103/b2/repair-glb.md:51-52`) reached the same conclusion
independently: *"Neither the README's pre-repair blob hash nor its path is cited as evidence anywhere
in the corpus."*

### 3.2 `corpus/artifacts/unity-r19/README.md` — **in-place repair + REQUIRED correction note** · owner **SEAT-24**

**Defect lines (HEAD):** 10, 11 — two `uv run` commands. **Class:** pure **B** — 0 narrative lines.

```
$ git show HEAD:corpus/artifacts/unity-r19/README.md | grep -n 'shokunin/game-dev-3d'
10:uv run --no-project --with pyyaml python .shokunin/game-dev-3d/corpus/artifacts/unity-r19/verify_scene.py
11:uv run --no-project --with pyyaml python … verify_scene.py .shokunin/game-dev-3d/corpus/artifacts/unity-r19/Hierarchy.broken-reference.unity --expect-reject
```

**Deciding test — THIS IS THE ONE FILE WHERE THE OVERRIDE FIRES:**

```
$ git show HEAD:corpus/artifacts/unity-r19/README.md | sha256sum
c4463ab5ef137acc54fb0c56023f8f37f23afbce21dda992fdd5a268a10a8660  -
$ git grep -l c4463ab5ef137acc54fb0c56023f8f37f23afbce21dda992fdd5a268a10a8660 HEAD
HEAD:corpus/lessons/r19-unity-final-review.md
HEAD:corpus/lessons/r19-unity-review.md
```

The pre-repair bytes are a **cited value**, twice, in committed lessons:

```
corpus/lessons/r19-unity-review.md:9        … Artifact README SHA-256 `c4463ab5…a8660`.
corpus/lessons/r19-unity-final-review.md:9  … Artifact README SHA-256 `c4463ab5…a8660`.
```

**The repair has landed and the citation is now dead** — re-derived by this seat:

```
$ sha256sum corpus/artifacts/unity-r19/README.md
12c4abd106b3e5a341fbede8c54563b9332a16ec6b805258788704934d608b4c  corpus/artifacts/unity-r19/README.md
$ git ls-files -z | xargs -0 sha256sum | grep -c '^c4463ab5'   → 0
```

No file in the tree hashes to `c4463ab5…` any more, so both r19 lesson lines now cite a value that
**cannot be re-derived from a clone**. SEAT-27 flagged exactly this and routed it
(`reports/round-103/b2/verify-unity.md` §6: *"ROUTED (not mine to fix) — the repair creates one stale
sibling citation"*).

**RULED — two dispositions, at two different layers:**

1. **The two command lines: in-place mechanical repair, PERMITTED.** They are class B; the README's
   own heading is *"From repository root"*; `PROTOCOL.md:341` licenses the fix. **Landed**, both arms
   verified `exit=0` (§5).
2. **The two citing lesson lines: a DATED CORRECTION NOTE is REQUIRED, appended, never rewritten.**
   `CORPUS.md:52` protects `corpus/lessons/**` by name; `PROTOCOL.md:351` prescribes the remedy for a
   falsified claim in an append-only file. The note must carry **both** facts — the path-root
   convention (the prefix is worktree-relative, not phantom) **and** the superseded digest
   `c4463ab5…` → `12c4abd1…`, so a reader can still re-derive what the r19 seat actually measured.

**This is the ruling's sharpest finding:** the naive "class-B → always repair in place" rule would
have shipped this repair silently and left two lessons citing a dead hash. The per-file citation test
(§1) is what catches it.

**Convergence (reached independently).** SEAT-24 (`reports/round-103/b2/repair-unity.md:114-140`) and
SEAT-27 (`verify-unity.md` §6) each flagged the same falsified citation and prescribed the same remedy
— *"a one-bullet dated correction note in each lesson can carry both digests without rewriting the r19
record — same shape as the r22 F1b note."* Three seats, one disposition, from separate derivations.

**The correction note's scope is wider than the digest.** Both lessons also carry the dead prefix in
their **narrative** — SEAT-24 measured `r19-unity-review.md` 12 lines, `r19-unity-final-review.md` 4
lines (7, 15, 20, 28). Those are **class A** under F1 §5 R2/R3: the correction note must name the
path-root convention but must **not** rewrite the narrative, exactly as the r22 F1b note left its
line 7 verbatim.

### 3.3 `corpus/fixtures/three/README.md` — **in-place mechanical repair** · owner **SEAT-25**

**Defect lines (HEAD):** 6, 7, 8, 9, 19, 20, 41, 42, 67, 78, 79, 92, 104, 105, 119, 142, 143 — **17
lines**, the largest single surface. **Class:** pure **B** — every one is a command; **0 narrative
lines** (verified: the three backticked singletons at 67/92/119 are *inline commands*, not prose —
`git show HEAD:… | grep -n` shows each is exactly `` `node …run_*.mjs` ``).

**Deciding test:** pre-repair digest `ebd2d97ef69d0a7c…`, **cited in HEAD → 0**. The K4 override does
not fire — critically, **`three/README.md` is NOT in the battery's seed map**: `run_battery.py:946`
excludes it (`path.relative_to(HERE).parts[0] != "three"`), and the runner's own seed list is
`['scene_graph.mjs','run_cases.mjs','package.json','package-lock.json']` (`three/run_cases.mjs:9`) —
the README is not a member. So the repair cannot perturb a `seeds_unchanged` assertion.

```
$ python3 -c "…seed_digests()…"   →  'three/README.md' in map: False ; 172 entries
```

**Before (exit 1) / after (exit 0):**

```
$ node .shokunin/game-dev-3d/corpus/fixtures/three/run_ortho_cases.mjs  → exit=1
$ node corpus/fixtures/three/run_ortho_cases.mjs                        → exit=0
$ node corpus/fixtures/three/run_ray_cases.mjs                          → exit=0
$ node corpus/fixtures/three/run_order_cases.mjs                        → exit=0
$ node corpus/fixtures/three/run_layer_cases.mjs                        → exit=0
$ npm ci --prefix corpus/fixtures/three                                 → exit=0
```

**RULED: in-place mechanical repair.** SEAT-30's K5 caveat (*"repair with a mandatory declaration"*,
`adversary.md` §3 K5) is **satisfied** — the change is 17 command lines, the diff touches nothing else
(§5), and no cited value moves. The declaration requirement is discharged by SEAT-25's
`reports/round-103/b2/repair-three.md`.

### 3.4 The 7 surviving runnable lines — **KEEP, never repair** · owner: nobody

Four fixture sources carry dead-root **comments**, and their bytes are cited values:

```
corpus/fixtures/three/scene_graph.mjs:2-5   (4 lines)
corpus/fixtures/crash_exit3d.gd:2           (1)
corpus/fixtures/timeout_tree3d.gd:2         (1)
corpus/fixtures/stream_attribution3d.gd:2   (1)
$ git grep -l e4bb0a136391cb42baafcbab4905e1c4004d316cec44f5f67519f37a2ab075af HEAD | wc -l   → 6
```

`scene_graph.mjs`'s digest is cited in **6** landed files; `crash_exit3d.gd`'s in **1**
(`corpus/lessons/r70-navagent-detour-non-author.json`, which asserts `seeds_unchanged: true`).
Editing one comment byte makes every citation stop resolving and makes the r70 receipt look like it
recorded a wrong digest. The executable contract for these probes is `run_battery.py`'s own
invocation and the repaired READMEs — **not** a source comment.

**RULED: KEEP, all 7 lines / 4 files.** This agrees with SEAT-30 K4 and SEAT-21 §4, reached
independently by all three seats.

### 3.5 The cautionary precedent — the r22 line-7 silent rewrite (an OPEN defect)

This ruling's per-file discipline is not hypothetical. The r22 lesson is the case where the
class-A/B distinction was **violated**, and the violation is landed at HEAD:

```
$ for c in 8b21cae 7804a69 c6f655d c85a816; do git show $c:corpus/lessons/r22-unreal-review.md | sed -n '7p' | grep -o 'I checked `[^`]*`'; done
8b21cae: I checked `.shokunin/game-dev-3d/LOG.md`     ← the r22 record, verbatim
7804a69: I checked `.shokunin/game-dev-3d/LOG.md`
c6f655d: I checked `LOG.md`                            ← rewritten in the r102 close-out commit
c85a816: I checked `LOG.md`                            ← still rewritten at HEAD
```

SEAT-11 flagged this in advance (`reports/round-102/adversary/F1.md` §5 **R5**): *"the repair
currently in the working tree is NON-CONFORMANT … an in-place rewrite of a historical narrative with
no dated correction note, against `CORPUS.md:52` and `PROTOCOL.md:123`."* The recommendation was to
restore line 7 verbatim and carry the change as an appended note. **That restoration never happened**;
the rewrite shipped in `c6f655d`. The r22 lesson now asserts the author consulted a path that did not
exist for them at write time — a false claim introduced to remove a stale one.

**RULED:** this is a **standing conformance defect**, out of r103's B2 repair scope but in its
discipline scope. **Route to the L1** (§4). It is the strongest possible argument for the per-file
rule this ruling adopts: had the r102 seat applied the class-A/B split, line 7 would have been left
alone and the command block fixed under a declaration.

---

## 4. Files SEAT-23 / SEAT-24 / SEAT-25 own (exact)

| seat | owns (exclusive) | also writes (report) |
|---|---|---|
| **SEAT-23** REPAIR-GLB | `corpus/artifacts/glb-r12/README.md` — **lines 6, 7, 8 only** | `reports/round-103/b2/repair-glb.md` |
| **SEAT-24** REPAIR-UNITY | `corpus/artifacts/unity-r19/README.md` — **lines 10, 11 only** | `reports/round-103/b2/repair-unity.md` |
| **SEAT-25** REPAIR-THREE | `corpus/fixtures/three/README.md` — **lines 6-9, 19-20, 41-42, 67, 78-79, 92, 104-105, 119, 142-143 only** | `reports/round-103/b2/repair-three.md` |

**Nothing else in those files.** Each repair must be a command-line-only diff: the narrative, tables,
digests and headings in all three READMEs stay byte-identical. Verified for two of the three in §5.

### ROUTED — a file no r103 seat owns (the §3.2 note)

```
corpus/lessons/r19-unity-review.md:9        ← needs an appended dated correction note
corpus/lessons/r19-unity-final-review.md:9  ← needs an appended dated correction note
```

**No r103 seat's declared scope names either file.** SEAT-24's brief is *"owns the unity-r19 file(s)"*
and SEAT-58 is a scan-only sweep. `CORPUS.md:52` forbids a seat editing `corpus/lessons/**` outside
its declared ownership, and `PROTOCOL.md:351` requires the note to land *in the lane's next round* —
so this ruling **routes it to the L1** for assignment (or to a successor seat with explicit ownership
of both files). The note must not rewrite line 9; it appends.

### ROUTED — the r22 line-7 standing defect (§3.5)

```
corpus/lessons/r22-unreal-review.md:7   ← silently rewritten at c6f655d; needs restore + appended note
```

**Also unowned in r103.** SEAT-11's R5 recommendation (restore line 7 verbatim, carry the change as an
appended correction note) never landed. Routed to the L1 with the same discipline: `PROTOCOL.md:123`
(*"never an in-place rewrite"*) and `CORPUS.md:52` both bind, and the r22 lesson already carries a
correction note at line 54 whose scope this extends.

---

## 5. Verification of the landed repairs (this seat, independent)

All three repairs had landed by `2026-10-18T18:35Z`; this seat verified them rather than assuming
them. **Zero dead-root lines remain in the three READMEs:**

```
$ grep -c 'shokunin/game-dev-3d' corpus/artifacts/glb-r12/README.md \
        corpus/artifacts/unity-r19/README.md corpus/fixtures/three/README.md
0 / 0 / 0
```

**Acceptance commands, run by this seat from the repo root — all exit 0:**

```
$ python3 corpus/artifacts/glb-r12/run_import.py          → exit=0
$ python3 corpus/fixtures/run_battery.py --only floor3d_ground → exit=0
$ node corpus/fixtures/three/run_cases.mjs                → exit=0
  PASS positive: exit=0 expected=0
  PASS negative_wrong_order: exit=2 expected=2
  PASS mutation: exit=1 expected=1
  PASS three battery: 3/3, seeds_unchanged=true
$ uv run --no-project --with pyyaml python corpus/artifacts/unity-r19/verify_scene.py → exit=0
$ node corpus/fixtures/three/run_ortho_cases.mjs          → exit=0
```

**Diff scope is command-lines-only** (the §4 requirement):

```
$ git diff -U0 -- corpus/fixtures/three/README.md | grep '^@@'
@@ -6,4 +6,4 @@   @@ -19,2 +19,2 @@  @@ -41,2 +41,2 @@  @@ -67 +67 @@
@@ -78,2 +78,2 @@  @@ -92 +92 @@  @@ -104,2 +104,2 @@  @@ -119 +119 @@  @@ -142,2 +142,2 @@
$ git diff -- corpus/fixtures/three/README.md | grep -E '^-' | grep -vc '^---'   → 17   (17 −, 17 +)
$ git diff -- corpus/artifacts/glb-r12/README.md | grep -E '^[+-]' | grep -vcE '^(\+\+\+|---)' → 6  (3 −, 3 +)
```

Every changed hunk is a command line at exactly the line numbers §3 names. No narrative byte moved.

**Post-repair runnable census** (`reports/round-103/b2/postgrep.md`'s harness, re-run by this seat):

```
$ bash /tmp/b2postgrep.sh | tail -1
FILES=164 RUNNABLE_HITS=140 NARRATIVE_HITS=513
$ … | grep '^RUNNABLE' | sed 's/^RUNNABLE  //' | cut -d: -f1 | grep -v -e '^corpus/lessons/' -e '^reports/'
(no output — 0 runnable hits outside the keep classes)
```

**Zero runnable dead-root hits remain outside the two keep classes** (dated `corpus/lessons/**`,
`reports/**`). The `RUNNABLE_HITS=140` remainder is entirely class A2 (dated records) — which is the
disposition §2 requires, not a residual defect.

---

## 6. Reproduce this ruling

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin

# §0/§1 — the per-file deciding test (cited-value override)
for f in corpus/artifacts/glb-r12/README.md corpus/artifacts/unity-r19/README.md \
         corpus/fixtures/three/README.md; do
  s=$(git show HEAD:$f | sha256sum | cut -d' ' -f1)
  echo "$f  ${s:0:16}  cited_in_HEAD=$(git grep -l "$s" HEAD | wc -l)"
done
# → glb 0af4f369… 0 ; unity c4463ab5… 2 ; three ebd2d97e… 0

# §3.2 — the falsified citation
git show HEAD:corpus/artifacts/unity-r19/README.md | sha256sum     # c4463ab5…
sha256sum corpus/artifacts/unity-r19/README.md                     # 12c4abd1…
git grep -l c4463ab5ef137acc54fb0c56023f8f37f23afbce21dda992fdd5a268a10a8660 HEAD
git ls-files -z | xargs -0 sha256sum | grep -c '^c4463ab5'          # 0 — the citation is dead

# §3.4 — the keep class
git grep -l e4bb0a136391cb42baafcbab4905e1c4004d316cec44f5f67519f37a2ab075af HEAD | wc -l   # 6
python3 -c "import importlib.util; s=importlib.util.spec_from_file_location('rb','corpus/fixtures/run_battery.py'); \
m=importlib.util.module_from_spec(s); s.loader.exec_module(m); print('three/README.md in seed map:', \
'three/README.md' in m.seed_digests())"                            # False

# §5 — acceptance + scope
grep -c 'shokunin/game-dev-3d' corpus/artifacts/glb-r12/README.md corpus/artifacts/unity-r19/README.md \
      corpus/fixtures/three/README.md                              # 0 / 0 / 0
bash /tmp/b2postgrep.sh | tail -1
```

---

## 7. Limits and non-claims

- **This seat wrote exactly one file:** `reports/round-103/b2/ruling.md`. It modified no tracked file,
  no lesson, no fixture, no gate, no manifest, and no other seat's report. No git
  commit/push/checkout/reset was run.
- **The three repairs landed before this ruling was written** (by SEAT-23/24/25, ~`18:34–18:35Z`), so
  this file rules *and* verifies, rather than gating a pending edit. Where the ruling and a landed
  repair agree, that is convergence, not causality.
- **`reports/**` was scanned but not classified file-by-file** — its 317 A2 + most B/C lines are dated
  history and out of repair scope. The raw hit list is `/tmp/b2_hits.txt` (ephemeral; do not cite it
  as evidence — `PROTOCOL.md:341`).
- **The census is a moving target** (879 → 1036 in ~3 h) because peers write `reports/round-103/**`
  while scans run. Every count above is scoped to `corpus/` or pinned to HEAD `c85a816`.
- **No Unreal or Unity runtime claim is made anywhere in this ruling.** Unreal Editor is not
  installed; live-MCP behaviour is unproven by construction; the Unity-r19 checker is a local static
  YAML subset parser, not Unity. The `exit=0` runs above exercise local static checkers and headless
  Node/Godot math, not an engine editor.
