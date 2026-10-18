# r101 scribe — custody audit of the round-101 report directory

Seat: **SEAT-55 SCRIBE**. Lane: `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`.
Scope: inventory `reports/round-101/` as it exists at this seat's runtime, flag
naming and duplication issues, and record the relation of the 3 pre-existing
frontier files to this round. **Read-only.** This seat committed nothing, edited
nothing outside this file, and re-ran no probe.

Status: **AUDIT COMPLETE — directory is live-mutating under concurrent seats; the
inventory below is a frozen snapshot, not a claim about the directory's final
state.**

**Audit window: `2026-10-18T14:14:03-03:00` → `2026-10-18T14:19:25-03:00`.** Ten
snapshots were taken inside that window; the directory went from **3 to 27
files** and never stopped changing. Every count in this report carries the time
it was observed. Nothing in §1 should be read as the directory's contents now —
the §1 table is one frame, and §1.1–§1.2 record the frames after it. **[O]**

Tags: **[O]** command-run observation, **[I]** inference, **[?]** unknown.

---

## 0. Method (exact commands, all read-only)

```
date -Iseconds                                              # snapshot time
find reports/round-101 -type f | sort
find reports/round-101 -type f -printf '%p|%s|' -exec sha256sum {} \;
ls -laR reports/round-101/
git rev-parse HEAD
git status --porcelain
git ls-files reports/round-101/
git diff --name-only
git log --format='%h|%ad|%s' --date=short -- <each file>
git show --stat <each commit>
cmp -s <file> <(git show HEAD:<file>)                       # disk vs HEAD blob
find reports -type f -printf '%f\n' | sort | uniq -d        # basename collisions
find reports -mindepth 2 -type d | sort                     # subdirectories
find reports/round-* -maxdepth 1 -type f -name '*.md' ! -name 'r[0-9]*-*'
grep -rn "reports/round-101" --include='*.md' . | grep -v '^./reports/round-101/'
cat .ufo/waves/shokunin-train-20261015-w22/tasks/g3d-{bpy-boundary,navagent-dissection,unknowns-map}.md
```

Working tree at audit time: HEAD = `cb87233904d7041c100aab02f6d736e545b939a8`
("game-dev-3d: frontier reports — bpy boundary, navagent dissection, unknowns
map"). `git diff --name-only` → **empty**: no tracked file was modified by any
seat during this audit. **[O]**

---

## 1. Snapshot — every file present at runtime

Snapshot taken `2026-10-18T14:16:10-03:00`. **16 files** present, in 2 levels. **[O]**

> **This table is one frozen frame.** The directory reached **27 files** at
> `2026-10-18T14:19:25-03:00` — see §1.1 for the growth series and §1.2 for what
> appeared after this frame. Read the table as "what existed at 14:16:10", never
> as "what is in `reports/round-101/`".

| # | path | bytes | sha256 (first 16) | mtime | git state |
|---|---|---|---|---|---|
| 1 | `reports/round-101/bpy-dissection.md` | 20895 | `63b2a90f2be9e223` | 2026-10-15 17:22 | tracked @ `6421676` |
| 2 | `reports/round-101/navagent-dissection.md` | 17769 | `d13041fc05cfc690` | 2026-10-15 17:45 | tracked @ `fc6d033` |
| 3 | `reports/round-101/r101-unknowns-map.md` | 25610 | `b061321bc8723674` | 2026-10-15 17:14 | tracked @ `3c7b460` |
| 4 | `reports/round-101/r101-mutation-tester.md` | 13439 | `0885e58005b8b06f` | 2026-10-18 14:15 | untracked (SEAT-54) |
| 5 | `reports/round-101/r101-reviewer-c1.md` | 16022 | `e4b34df7e060298c` | 2026-10-18 14:15 | untracked (SEAT-44) |
| 6 | `reports/round-101/probes/plugin-json.md` | 10105 | `4e161e18919083bc` | 2026-10-18 14:14 | untracked (SEAT-16) |
| 7 | `reports/round-101/probes/toolset-census.md` | 13283 | `d29b01aa9e77c35b` | 2026-10-18 14:14 | untracked (SEAT-25) |
| 8 | `reports/round-101/probes/license-audit.md` | 14205 | `6e9ce55dac91a9a1` | 2026-10-18 14:14 | untracked (SEAT-28) |
| 9 | `reports/round-101/probes/byte-identity-reference.md` | 14624 | `47783c89f21c8b94` | 2026-10-18 14:14 | untracked (SEAT-15) |
| 10 | `reports/round-101/probes/operations-inventory.md` | 15749 | `a9ad4a503e832e65` | 2026-10-18 14:16 | untracked (SEAT-22) |
| 11 | `reports/round-101/probes/skill-frontmatter.md` | 16614 | `309f15b92916846f` | 2026-10-18 14:15 | untracked (SEAT-19) |
| 12 | `reports/round-101/probes/md-links.md` | 19066 | `e9c61059b499617f` | 2026-10-18 14:14 | untracked (SEAT-20) |
| 13 | `reports/round-101/probes/prereq-matrix.md` | 19423 | `87f63af5891fe71a` | 2026-10-18 14:15 | untracked (SEAT-23) |
| 14 | `reports/round-101/probes/hook-shellcheck.md` | 20332 | `7d466b5827dee238` | 2026-10-18 14:14 | untracked (SEAT-18) |
| 15 | `reports/round-101/probes/security-surface.md` | 24374 | `c663b63eb0b2420e` | 2026-10-18 14:16 | untracked (SEAT-24) |
| 16 | `reports/round-101/probes/r22-relation.md` | 13100 | `bcce8eb97ffb31a6` | 2026-10-18 14:15 | untracked (SEAT-27) |

`git status --porcelain` at snapshot time **[O]**:

```
?? corpus/knowledge/unreal-mcp/
?? reports/round-101/probes/
?? reports/round-101/r101-mutation-tester.md
?? reports/round-101/r101-reviewer-c1.md
```

Seat IDs are read from each file's first line (`# SEAT-NN PROBE — …` /
`# SEAT-NN MUTATION-TESTER` / `# SEAT-44 REVIEW — …`). **[O]**

### 1.1 The directory moved during this seat

The inventory is **not stable**. Nine observations, same command, spread over
~5.5 minutes, each with the file count: **[O]**

| snapshot | time | files | probes | what appeared |
|---|---|---|---|---|
| A | 14:14:03 | 3 | 0 (empty dir) | `probes/` created empty at 14:13:54 |
| B | 14:14:50 | 10 | 6 | `byte-identity-reference.md` and `hook-shellcheck.md` landed mid-command |
| C | 14:16:10 | 16 | 11 | `prereq-matrix.md`, `r22-relation.md`, `security-surface.md`, `r101-mutation-tester.md`, `r101-reviewer-c1.md`; `operations-inventory.md` and `security-surface.md` rewritten 2–3× (`operations-inventory.md` 13528 → 14739 → 15148 → 15749 B; `security-surface.md` 23080 → 23749 → 24094 → 24374 B) |
| D | 14:16:44 | 17 | 11 | one more top-level file — §1 is therefore **16 of the 17** present at 14:16:44 |
| E | 14:17:11 | 18 | 11 | `r101-connector.md`; `operations-inventory.md` 15749 → 18986 B and `security-surface.md` 24374 → 25688 B |
| F | 14:17:33 | 22 | 12 | `probes/ue-version-matrix.md`, `r101-critic-c1.md`, `r101-scout-roster.md`, `r101-verification-protocol.md` |
| G | 14:17:51 | 23 | 13 | one more probe file |
| H | 14:18:16 | 24 | 14 | `probes/doc-consistency.md`, `probes/install-path.md`; `r101-connector.md` 25822 → 26348 B, `r101-scout-roster.md` 15491 → 15951 B, `r101-verification-protocol.md` 23825 → 24890 B |
| I | 14:18:37 | 26 | 14 | `r101-report.md`, `r101-reviewer-c2.md`; `probes/doc-consistency.md` 23002 → 23602 B, `r101-verification-protocol.md` 24890 → 26333 B |
| J | 14:19:25 | **27** | 14 | one more top-level file; `corpus/knowledge/unreal-mcp/` reached 40 files / 13 cards |

Snapshot J is the last observation this seat took. Growth across the seat:
**3 → 10 → 16 → 17 → 18 → 22 → 23 → 24 → 26 → 27 files**, i.e. the directory
grew **9×** in under five and a half minutes, and six files were each rewritten
at least once. The §1 table is a **frozen 16-file snapshot at 14:16:10**, not
the current state. **[O]**

### 1.2 Files present after the §1 frame **[O]**

Snapshot F (14:17:33) — five files absent from §1:

| path | bytes | sha256 (first 16) |
|---|---|---|
| `reports/round-101/r101-connector.md` | 25822 | `1de9c255e769def0` |
| `reports/round-101/r101-critic-c1.md` | 27866 | `1f39379e9c3c1ff4` |
| `reports/round-101/r101-scout-roster.md` | 15491 | `64718212fb2ea3b2` |
| `reports/round-101/r101-verification-protocol.md` | 23825 | `b3b06964acaaadbb` |
| `reports/round-101/probes/ue-version-matrix.md` | 23007 | `5fd0219e5e74f326` |

Snapshot H (14:18:16) — two more files, plus rewrites of two already listed:

| path | bytes | sha256 (first 16) |
|---|---|---|
| `reports/round-101/probes/doc-consistency.md` | 23002 | `a351d5fa1d8c8b12` |
| `reports/round-101/probes/install-path.md` | 24291 | `d71d6259fecd0986` |
| `reports/round-101/r101-connector.md` (rewritten) | 26348 | `8d87a166c5b2397e` |
| `reports/round-101/r101-scout-roster.md` (rewritten) | 15951 | `3bdd0eae2580998a` |
| `reports/round-101/r101-verification-protocol.md` (rewritten) | 24890 | `871efe0c21adbc04` |

Snapshot I (14:18:37) — two more files, plus two more rewrites:

| path | bytes | sha256 (first 16) |
|---|---|---|
| `reports/round-101/r101-report.md` | 18040 | `40d07b333d79e7f8` |
| `reports/round-101/r101-reviewer-c2.md` | 33310 | `fcd7e3e5d1e6fe82` |
| `reports/round-101/probes/doc-consistency.md` (rewritten) | 23602 | `2693579eed2a1e34` |
| `reports/round-101/r101-verification-protocol.md` (rewritten again) | 26333 | `7760dad2f58d1773` |

All untracked; `git diff --name-only` was still **empty** at snapshot I, so
nothing tracked was touched at any point in this audit. **[O]**

`probes/` itself did not exist at 14:13:54 and was still empty; it held **11**
files at 14:16:10, **12** at 14:17:33 and **14** at 14:18:16. At snapshot I all
**14** probe files were cited from somewhere in the tracked tree, so none was
orphaned. Any reader of this directory is reading a moving target. **[O]**

---

## 2. Findings — naming and duplication

### F1 — Four coexisting naming conventions in one round directory **[O]**

| convention | files here | prevalence elsewhere |
|---|---|---|
| `rNN-<seat>.md` | `r101-unknowns-map.md`, `r101-mutation-tester.md`, `r101-reviewer-c1.md`, `r101-connector.md`, `r101-critic-c1.md`, `r101-scout-roster.md`, `r101-verification-protocol.md`, `r101-scribe-audit.md` (8 at snapshot F) | **the lane standard** — 33 of 34 round dirs contain at least one `rNN-*.md`; 31 of 34 use it for ≥5 files (`r70-author.md` … `r100-verifier.md`) |
| no prefix, `<topic>.md` | `bpy-dissection.md`, `navagent-dissection.md` | only `reports/round-86/{bpx-scout,nas-scout}.md` and `round-1-20261015/PathCritic.md` do this, in 34 round dirs |
| seat-slug under `probes/` | all 13 `probes/*.md` at snapshot F | **unprecedented** — see F2 |
| bare seat-id in title only | e.g. `# SEAT-25 PROBE` inside `probes/toolset-census.md` | n/a |

Command and result **[O]**:

```
$ find reports/round-* -maxdepth 1 -type f -name '*.md' ! -name 'r[0-9]*-*'
reports/round-101/bpy-dissection.md
reports/round-101/navagent-dissection.md
reports/round-1-20261015/PathCritic.md
reports/round-86/bpx-scout.md
reports/round-86/nas-scout.md
```

So `round-101` alone contributes 2 of the 5 off-pattern top-level filenames in
the entire lane history. The two are **pre-existing** (committed 2026-10-15,
`6421676` / `fc6d033`), not this round's authoring. Note that their names come
from the task cards, which specify those exact paths (F5).

### F2 — `reports/round-101/probes/` is the first round-level subdirectory in lane history **[O]**

```
$ find reports -mindepth 2 -type d | sort
reports/round-1-20261015/before
reports/round-101/probes
```

The only other round-level subdirectory is `round-1-20261015/before/`, which
holds `absolute.json` / `relative.json` evidence, not reports. Every other
round-70…round-100 puts one flat file per seat at the top level. The probe
files use free-form slugs (`md-links`, `prereq-matrix`, `security-surface`,
`ue-version-matrix`) rather than the seat-id convention, so a reader cannot tell
from the filename which seat produced a given probe — the seat id is only in the
file's H1.
**[O]** for the layout, **[I]** that this will complicate later cross-round
greps that assume `reports/round-N/<file>.md`.

### F3 — `navagent-dissection.md` is the only basename collision in all of `reports/` **[O]**

```
$ find reports -type f -printf '%f\n' | sort | uniq -d
navagent-dissection.md
```

Same basename, two directories, both tracked, **different bytes**:

| path | commit | bytes | lines | sha256 |
|---|---|---|---|---|
| `reports/round-101/navagent-dissection.md` | `fc6d033` | 17769 | 308 | `d13041fc05cfc690…` |
| `reports/frontier/navagent-dissection.md` | `cb87233` | 22462 | 386 | `82261cd3b6516dbc…` |

`diff -u` between them is 612 lines; 93 lines are identical. They are **not**
duplicates of each other — the frontier file is a longer, independently
re-dissected report on the same flake (see §3). **[O]**

No byte-identical duplicate exists anywhere in `reports/round-101/` at the §1
snapshot **[O]**:

```
$ sha256sum reports/round-101/*.md reports/round-101/probes/*.md | awk '{print $1}' | sort | uniq -d
(no output)
```

### F4 — `reports/round-101/` has no seat-role files that every other recent round has **[O]**

`round-99` and `round-100` each carry 9 files: `{adjudicator, author, boundary,
critic, reviewer, scout, scribe, simplifier, verifier}`. `round-101` at the
§1 snapshot (16 files) has 3 committed files and 13 uncommitted files, and
**none** of them is a `r101-author.md`, `r101-verifier.md`, `r101-simplifier.md`,
`r101-adjudicator.md`, `r101-baseline.md`, `r101-boundary.md` or
`r101-scout.md`. The seat-like files present are `r101-reviewer-c1.md`,
`r101-mutation-tester.md`, `r101-connector.md`, `r101-critic-c1.md`,
`r101-scout-roster.md`, `r101-verification-protocol.md` and this seat's
`r101-scribe-audit.md` — every one uses a qualifier (`-c1`, `-tester`,
`-audit`, `-roster`) rather than the bare role name that 31 of 34 other rounds
use. This is expected if the round is still in flight (§1.1) — recorded as a
state observation, not a defect. **[O]**/**[I]**

Note that this seat's own file is one of them: the brief assigns
`reports/round-101/r101-scribe-audit.md`, not `r101-scribe.md`. The lane's
`r99-scribe.md` / `r100-scribe.md` files use the bare role name, so this round's
scribe file is itself an instance of F1's drift. **[O]**

### F5 — the off-pattern names are traceable to the wave task cards, not to seat drift **[O]**

Three task cards in `/home/vgpnk/Projects/shokunin/.ufo/waves/shokunin-train-20261015-w22/tasks/`
name these paths verbatim:

| card | card text (quoted) |
|---|---|
| `g3d-bpy-boundary.md` | `reports/round-93-adjacent/bpy-dissection.md (or reports/round-101/bpy-dissection.md)` |
| `g3d-navagent-dissection.md` | `reports/round-101/navagent-dissection.md` |
| `g3d-unknowns-map.md` | `reports/round-101/r101-unknowns-map.md` |

So `bpy-dissection.md` and `navagent-dissection.md` match their dispatch; they
diverge from the `rNN-<seat>.md` convention because the cards were written that
way. `r101-unknowns-map.md` matches the convention. **[O]**

`grep -l "round-101"` over the 216 cards in that wave returns exactly these
three files. There is **no** `r101-scribe` card, no `r101-reviewer` card, and no
card for the SEAT-15…SEAT-28 probes or SEAT-54/SEAT-44 — the Unreal round's
seats are dispatched from outside this wave directory. **[O]**

---

## 3. Relation of the 3 pre-existing frontier files to this round

The 3 pre-existing files named in this seat's brief — `bpy-dissection.md`,
`navagent-dissection.md`, `r101-unknowns-map.md` — are **committed to
`reports/round-101/`, not to `reports/frontier/`.** The brief's phrase "frontier
files" is accurate in the sense of "work that advanced the frontier", not in the
sense of "files in `reports/frontier/`". Recorded here because it is exactly the
kind of thing a later reader will get wrong. **[O]**

### 3.1 The 3 files themselves **[O]**

| file | commit | date | bytes | disk == HEAD blob |
|---|---|---|---|---|
| `r101-unknowns-map.md` | `3c7b460` | 2026-10-15 | 25610 | `cmp` → identical |
| `bpy-dissection.md` | `6421676` | 2026-10-15 | 20895 | `cmp` → identical |
| `navagent-dissection.md` | `fc6d033` | 2026-10-15 | 17769 | `cmp` → identical |

Each commit is insertion-only and touches exactly one file **[O]**:

```
3c7b460  reports/round-101/r101-unknowns-map.md | 406 +++  (1 file changed, 406 insertions)
6421676  reports/round-101/bpy-dissection.md     | 381 +++  (1 file changed, 381 insertions)
fc6d033  reports/round-101/navagent-dissection.md| 308 +++  (1 file changed, 308 insertions)
```

All three are ancestors of HEAD (`git merge-base --is-ancestor fc6d033 HEAD` →
YES). They predate the frontier commit `cb87233` by ~1.5 days.

### 3.2 The `reports/frontier/` trio — three separate reports, not copies **[O]**

`reports/frontier/` holds 5 tracked files; 3 of them were landed together in
`cb87233` and are the "frontier" counterparts:

| frontier file | commit | bytes | cites round-101 how |
|---|---|---|---|
| `bpy-boundary.md` | `cb87233` | 20669 | `:16` — "The r101 dissection (`reports/round-101/bpy-dissection.md`) delivered the mechanism and a fix spec. **This seat asks the boundary question instead: where does that fix stop working?**" |
| `navagent-dissection.md` | `cb87233` | 22462 | `:14` — names `reports/round-101/navagent-dissection.md` as "where an earlier seat's committed report already sits at `fc6d033`", and records the **path conflict as data** |
| `unknowns-map.md` | `cb87233` | 27197 | `:19` — lists the 3 round-101 files as "**r101 forward reports already landed** (2026-10-15)"; `:25` records the **contract-file divergence** |

So the relation is **successor-with-overlap, not duplication**:

- `frontier/bpy-boundary.md` (341 lines) asks a *different question* from
  `round-101/bpy-dissection.md` (381 lines) — boundary of the fix rather than
  the mechanism. 77 lines identical (shared headers/provenance). **[O]**
- `frontier/unknowns-map.md` (334 lines) is explicitly **post-r100** and treats
  `round-101/r101-unknowns-map.md` (406 lines) as an input; 38 lines identical.
  It re-harvests rather than replaces. **[O]**
- `frontier/navagent-dissection.md` (386 lines) is an **independent
  re-dissection** of the same flake by a second seat, dispatched to
  `reports/frontier/` while the wave card named `reports/round-101/`. 93 lines
  identical. **[O]**

### 3.3 The recorded path conflict — verbatim from the frontier file **[O]**

`reports/frontier/navagent-dissection.md:12–16`:

> The wave task file `.ufo/waves/shokunin-train-20261015-w22/tasks/g3d-navagent-dissection.md`
> names the same evidence dir but a different report path
> (`reports/round-101/navagent-dissection.md`, where an earlier seat's committed
> report already sits at `fc6d033`); the dispatch path was followed and the
> conflict is recorded here as data.

`reports/frontier/unknowns-map.md:23–28`:

> **Contract-file divergence (recorded, not resolved by this seat)**: the wave
> task card `.ufo/waves/shokunin-train-20261015-w22/tasks/g3d-unknowns-map.md`
> names a different deliverable (`reports/round-101/r101-unknowns-map.md` +
> `corpus/live/r101-unknowns/`), which an earlier seat already produced. This
> dispatch names `reports/frontier/unknowns-map.md` + `corpus/live/unknowns-map/`;
> the dispatch prompt is the canonical assignment, so that is what was produced.

This is the **documented cause of F3**: two seats were told, by two different
authorities (wave card vs dispatch prompt), to write the same deliverable to two
different paths, and both wrote it. Both frontier seats recorded the divergence
instead of silently overwriting. The conflict is **known and on the record**; it
is not a custody failure by either seat. **[O]**

### 3.4 Downstream consumers of the 3 files **[O]**

`grep -rn "reports/round-101" --include='*.md' .` outside the round dir returned
**21 hits at 14:16:48**, of which the 3 frontier files account for 4. The other
17 were in `corpus/knowledge/unreal-mcp/executability/` cards. By **14:18:34 the
same command returned 31 hits** — the citing tree was growing alongside the
cited one (cards went 8 → 13 during this audit):

```
$ grep -rn "reports/round-101" --include='*.md' . | grep -v '^./reports/round-101/' | cut -d: -f1 | sort | uniq -c
   (14:16:48 reading)
      2 ./corpus/knowledge/unreal-mcp/executability/actors-scene.md
      2 ./corpus/knowledge/unreal-mcp/executability/animation-controlrig.md
      1 ./corpus/knowledge/unreal-mcp/executability/assets-content.md
      2 ./corpus/knowledge/unreal-mcp/executability/blueprints.md
      3 ./corpus/knowledge/unreal-mcp/executability/editor-general.md
      3 ./corpus/knowledge/unreal-mcp/executability/materials.md
      3 ./corpus/knowledge/unreal-mcp/executability/meshes-textures.md
      1 ./corpus/knowledge/unreal-mcp/executability/ui-umg-slate.md
      1 ./reports/frontier/bpy-boundary.md
      1 ./reports/frontier/navagent-dissection.md
      2 ./reports/frontier/unknowns-map.md
```

`editor-general.md:366` refers to them as "**The 3 pre-existing
`reports/round-101/` files**" — the same three this section covers, from a
different seat, with the same count. Independent corroboration of the count.
**[O]**

Probe citations grew with the probe set. At **14:16:48**, `round-101/probes/*`
had **7 hits** covering all **11** probe files then present; at **14:18:34** all
**14** probe files present were cited from somewhere in the tracked tree, with
**no orphans** (`comm -23 <(ls reports/round-101/probes/) <(grep -rho
"round-101/probes/[a-z0-9-]*\.md" … | sed 's|.*/||' | sort -u)` → empty). The
14:16:48 reading:

```
$ grep -rho "round-101/probes/[a-z0-9-]*\.md" --include='*.md' . | sort | uniq -c
      3 round-101/probes/byte-identity-reference.md
      1 round-101/probes/hook-shellcheck.md
      2 round-101/probes/license-audit.md
      2 round-101/probes/md-links.md
      1 round-101/probes/operations-inventory.md
      1 round-101/probes/plugin-json.md
      1 round-101/probes/prereq-matrix.md
      1 round-101/probes/r22-relation.md
      1 round-101/probes/security-surface.md
      1 round-101/probes/skill-frontmatter.md
      8 round-101/probes/toolset-census.md
```

Because the citing cards and the probes were both being written during this
audit, this citation map is a **lower bound at any single instant** — it proves
the probes are being consumed, and it cannot prove that any probe is uncited at
a later time. **[O]**/**[I]**

---

## 4. Evidence directories referenced by the 3 files are absent from this worktree **[O]**

Every one of the 3 pre-existing files declares receipts under a gitignored
`corpus/live/…` path. `corpus/.gitignore` is exactly `live/`, `__pycache__/`,
`*.pyc`, and `git check-ignore -v corpus/live/x` → `corpus/.gitignore:1:live/`.
None of the directories exists here:

```
corpus/live/bpy-dissection            MISSING
corpus/live/navagent-dissection       MISSING
corpus/live/navagent-dissection/frontier MISSING
corpus/live/r101-unknowns             MISSING
corpus/live/unknowns-map              MISSING
corpus/live/bpy-boundary              MISSING
```

`ls corpus/` shows only `artifacts/ fixtures/ knowledge/ lessons/ predecessor/`.
This is the expected consequence of `live/` being gitignored — the receipts were
never in the repository — but it means **no claim in these 3 reports can be
re-derived from this worktree without re-running the probes.** Recorded for the
adjudicator; not a defect in the files. **[O]**

---

## 5. What this seat did not do

- Did not modify, stage, commit, or delete anything. `git diff --name-only` is
  empty and `git status` shows only the untracked paths listed in §1 and §1.2.
- Did not read any file outside `reports/`, `corpus/`, `.ufo/waves/…w22/tasks/`,
  `LOG.md`, `SCORECARD.md`, `README.md`, `PROVINCE.md` — all read-only.
- Did not verify the content claims of the probe files, the executability cards,
  or C1/C2/C3. This audit covers **presence, naming, provenance and duplication
  only**.
- Did not audit `corpus/knowledge/unreal-mcp/` (39 files at snapshot I, of which
  13 are `executability/*.md` cards). Its existence is noted because `git status`
  reports it and because most cross-references to `reports/round-101/` live
  inside it (17 of 21 at 14:16:48; 27 of 31 at 14:18:34).
- Did not re-derive any sha256 from a second source; the hashes in §1 are single
  observations of a directory that was changing while they were taken (§1.1).
  Four files were rewritten between consecutive hash passes
  (`operations-inventory.md`, `security-surface.md`, `r101-connector.md`,
  `r101-verification-protocol.md`, `r101-scout-roster.md`, `probes/doc-consistency.md`)
  — their table rows are the **last** observation, not a stable value.

## 6. Recommendations to the L1 (advisory only — no axis claim)

1. **Snapshot before landing.** Freeze the directory (or copy it) before the
   round-close commit; a `git add -A reports/round-101/` taken while probes are
   still being rewritten will commit an arbitrary mid-edit revision. Across this
   audit the directory went 3 → 26 files in under five minutes, with six files
   rewritten at least once. **[I]**
2. **Resolve the navagent path collision at close**, not by deleting either
   file: `reports/frontier/navagent-dissection.md` and
   `reports/round-101/navagent-dissection.md` are distinct reports and both
   carry load-bearing evidence. At minimum, leave §3.3's recorded conflict
   intact so the duplicate basename is explained where a reader will hit it. **[I]**
3. **Reconcile the seat-file names with the lane vocabulary before landing.**
   The round's seat files use qualifiers (`r101-reviewer-c1.md`,
   `r101-reviewer-c2.md`, `r101-critic-c1.md`, `r101-mutation-tester.md`,
   `r101-scribe-audit.md`, `r101-scout-roster.md`) where 31 of 34 rounds use
   `rNN-<role>.md` (`r101-reviewer.md` is the standard name, used 26 times
   lane-wide). Renaming before landing keeps cross-round greps working; renaming
   after landing would break the §3.4 citations. This is a bookkeeping
   preference, not a defect — the qualifiers do carry real information (which
   claim was reviewed). **[I]**

## 7. Reproducing this audit

```
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
git rev-parse HEAD                                   # expect cb87233…
git status --porcelain                               # untracked only; grows with each seat
find reports/round-101 -type f | sort | wc -l         # 3 → 10 → 16 → 17 → 18 → 22 → 23 → 24 → 26 during this seat
sha256sum reports/round-101/*.md reports/round-101/probes/*.md
find reports -type f -printf '%f\n' | sort | uniq -d  # expect: navagent-dissection.md
find reports -mindepth 2 -type d | sort               # expect: round-1-20261015/before, round-101/probes
find reports/round-* -maxdepth 1 -type f -name '*.md' ! -name 'r[0-9]*-*'
grep -rn "reports/round-101" --include='*.md' . | grep -v '^./reports/round-101/'
```

File counts are the one number that will **not** reproduce — see §1.1. Every
count in this report is stamped with the time it was taken. **[O]**
