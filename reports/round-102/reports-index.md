# SEAT-57 REPORTS-INDEX — `reports/round-102/` naming convention audit + runtime inventory

Seat: **SEAT-57 REPORTS-INDEX** (r102). Lane: `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`.
Scope: verify `reports/round-102/` naming against the r101 convention, note any new convention,
and list every file present at this seat's runtime. **Read-only.** This seat wrote nothing but
this file; no cited artifact was edited, and no `git` state was mutated.

Lane HEAD at snapshot: `2c99b7b8155841617d844c609813afcba77aa207`.
**Snapshot window: `2026-10-18T17:41:27Z` → `2026-10-18T17:42:20Z`** (six frames). The directory
went **7 → 18 files** and never stopped changing. Every count below carries the time it was
observed; the §1 table is one frame, not a claim about the directory's final state.

Tags: **[O]** command-run observation · **[I]** inference · **[?]** unknown.

---

## 1. Runtime inventory — frame at `2026-10-18T17:42:20Z` (18 files)

Command and result **[O]**:

```
$ date -u +%Y-%m-%dT%H:%M:%SZ
2026-10-18T17:42:20Z
$ find reports/round-102 -type f | sort | wc -l
18
```

| # | path | seat (from H1) | bytes | sha256 (16) |
|---|---|---|---|---|
| 1 | `reports/round-102/adversary/F3.md` | SEAT-13 | 11028 | `6a2d297a3379dd7d` |
| 2 | `reports/round-102/battery-integrity.md` | SEAT-33 | 6282 | `01f101c85d9bd70a` |
| 3 | `reports/round-102/before/baseline-integrity.md` | SEAT-06 | 17937 | `cb193412cbbe1b65` |
| 4 | `reports/round-102/before/F2-verdicts-json.md` | SEAT-02 | 4447 | `6a9e157740464e3f` |
| 5 | `reports/round-102/before/F3-sha-drift.md` | SEAT-03 | 6491 | `c45493548703051a` |
| 6 | `reports/round-102/before/F5-engines-threejs.md` | SEAT-04 | 8827 | `706ff204cc5e7907` |
| 7 | `reports/round-102/before/F6-rea-census.md` | SEAT-05 | 5580 | `4f9b01f9dfae3b77` |
| 8 | `reports/round-102/freshness-pin.md` | SEAT-59 | 6504 | `0c9eb3ce720460e3` |
| 9 | `reports/round-102/gate/runtime-run.md` | SEAT-39 | 9554 | `f0e72cd3e96038f9` |
| 10 | `reports/round-102/git-hygiene.md` | SEAT-51 | 5884 | `6b03316ce8a13bac` |
| 11 | `reports/round-102/ledger-check.md` | SEAT-55 | 10238 | `8c79cb53ef57f8ee` |
| 12 | `reports/round-102/lesson-index.md` | SEAT-56 | 3335 | `73480fd4f554b84a` |
| 13 | `reports/round-102/repairs/F1a-r22-readme.md` | SEAT-07 | 3642 | `c347527347bccd62` |
| 14 | `reports/round-102/repairs/F6-rea-census.md` | SEAT-10 | 9739 | `542c5a189f1bc70f` |
| 15 | `reports/round-102/reruns/labels.md` | SEAT-36 | 14238 | `7c5826b8092761c3` |
| 16 | `reports/round-102/reruns/links.md` | SEAT-38 | 13059 | `b36c99e53752e93f` |
| 17 | `reports/round-102/reruns/manifest.md` | SEAT-35 | 9802 | `092a97d4a4d52ae0` |
| 18 | `reports/round-102/reruns/pointer-sweep.sh` | SEAT-37 (body; no H1 seat line) | 2203 | `dd5edc70ef639d71` |

No `r102-report.md` exists at this frame — the round-close scribe report is not yet written. **[O]**

### 1.1 Frames observed (growth rate)

| time (UTC) | files | note |
|---|---|---|
| `17:41:27Z` | 7 | first frame; `before/` + `repairs/` only |
| `17:41:41Z` | 8 | `reruns/` appears |
| `17:41:47Z` | 10 | `freshness-pin.md`, `reruns/manifest.md` |
| `17:42:05Z` | 15 | `gate/`, `lesson-index.md` |
| `17:42:10Z` | 17 | `adversary/`, `reruns/labels.md` |
| `17:42:20Z` | 18 | `ledger-check.md` |

Rate: **~11 files in 53 seconds**, i.e. roughly one file every 5 s. Nothing in §1 should be read
as the directory's contents now. **[O]**

### 1.2 Subdirectories — frame at `17:42:18Z`

```
$ find reports/round-102 -mindepth 1 -type d | sort
reports/round-102/adversary
reports/round-102/before
reports/round-102/gate
reports/round-102/repairs
reports/round-102/reruns
```

Five round-level subdirectories, **all created during r102**. **[O]**

---

## 2. Naming convention — verdict

### 2.1 The r101 convention it is being measured against

The r101 round used the lane's standing `rNN-<seat>.md` form for its seat files. Measured
lane-wide **[O]**:

```
$ for d in $(ls -d reports/round-*); do printf '%s\t%s\n' "$(basename $d)" \
    "$(ls $d/r[0-9]*-*.md 2>/dev/null | wc -l)"; done
round-100	9
round-101	15
round-102	0
round-1-20261015	0
round-69	2
round-70…round-99	5–12 each
```

**33 of 35 round dirs contain at least one `rNN-*.md` file**; `round-102` and
`round-1-20261015` are the two that do not. `reports/round-101/` carried **15** such files
(`r101-connector.md`, `r101-critic-c1…c3.md`, `r101-reviewer-c1…c3.md`, `r101-report.md`,
`r101-scribe-audit.md`, …). **[O]**

### 2.2 Verdict: `reports/round-102/` does **not** follow the `rNN-<seat>.md` convention

```
$ find reports/round-102 -maxdepth 1 -type f -name 'r102-*' | sort
(no output — zero files)
```

**Zero** `r102-<seat>.md` files exist at this frame, against 15 in r101. Every top-level file is
a free-form topic slug **[O]**:

```
$ find reports/round-102 -maxdepth 1 -type f ! -name 'r102-*' -printf '%f\n' | sort
battery-integrity.md
freshness-pin.md
git-hygiene.md
ledger-check.md
lesson-index.md
```

This is a **continuation, not a break, of the drift the r101 scribe already logged** as its
finding F1 (`reports/round-101/r101-scribe-audit.md:158`, "Four coexisting naming conventions in
one round directory"). At that audit the off-pattern top-level names lane-wide were exactly 5;
`round-102` has now added 5 more, taking the lane total to 10 **[O]**:

```
$ find reports/round-* -maxdepth 1 -type f -name '*.md' ! -name 'r[0-9]*-*' | sort
reports/round-101/bpy-dissection.md
reports/round-101/navagent-dissection.md
reports/round-102/battery-integrity.md
reports/round-102/freshness-pin.md
reports/round-102/git-hygiene.md
reports/round-102/ledger-check.md
reports/round-102/lesson-index.md
reports/round-1-20261015/PathCritic.md
reports/round-86/bpx-scout.md
reports/round-86/nas-scout.md
```

**Observation, not defect.** No task card visible to this seat mandates the `r102-<seat>.md` form,
and the seat id *is* recoverable from every file's H1 (SEAT-13, SEAT-33, … SEAT-59 — see §1
column 3). The cost is that a reader cannot tell the producing seat from the filename alone, and
a later `grep -l 'r102-'` over `reports/` returns nothing for this round. **[I]**

### 2.3 New convention: round-level subdirectories are now the norm — **noted**

r102 introduces five round-level subdirs (`adversary/`, `before/`, `gate/`, `repairs/`,
`reruns/`). r101 had exactly one (`probes/`), and before r101 the only precedent anywhere in the
lane was `reports/round-1-20261015/before/` **[O]**:

```
$ find reports -mindepth 2 -type d | sort
reports/round-101/probes
reports/round-102/adversary
reports/round-102/before
reports/round-102/gate
reports/round-102/repairs
reports/round-102/reruns
reports/round-1-20261015/before
```

**Verdict: the subdir layout is a new convention, and it is acceptable and self-documenting.** The
four r102 subdir names are stable and meaningful — `before/` (pre-repair captures), `repairs/`
(post-repair captures), `reruns/` (independent re-executions of r101 gates), `gate/` (gate
receipts), `adversary/` (adversarial findings). This is a *net readability improvement* over
r101's `probes/` free-form slugs, because a `reruns/manifest.md` is identifiable as a re-run
receipt from its path. It is recorded here as the r102 convention so round-close and later rounds
can either adopt it deliberately or revert. **[O]** for the layout, **[I]** for the judgement.

One caveat inherited from r101's F2: the subdir filenames (`F3.md`, `manifest.md`, `labels.md`)
carry **no seat id and no round prefix**, so a cross-round grep that assumes
`reports/round-N/<file>.md` must now also recurse. **[I]**

---

## 3. Duplication

### 3.1 First in-round duplicate basename in lane history

```
$ find reports/round-102 -type f -printf '%f\n' | sort | uniq -d
F6-rea-census.md
```

`F6-rea-census.md` exists **twice inside one round directory**, at two different paths and with
different bytes **[O]**:

| path | seat | bytes | sha256 (16) | role |
|---|---|---|---|---|
| `reports/round-102/before/F6-rea-census.md` | SEAT-05 | 5580 | `4f9b01f9dfae3b77` | before-capture (defect reproduced) |
| `reports/round-102/repairs/F6-rea-census.md` | SEAT-10 | 9739 | `542c5a189f1bc70f` | repair capture |

They are **not** duplicates of each other — the `before/` file is the failing reproduction and
the `repairs/` file is the fix. The collision is a *deliberate consequence of the new subdir
convention* (§2.3), where the same defect id is reused across the `before/`→`repairs/` pair. It is
recorded, not flagged as a defect. **[O]**/**[I]**

Lane-wide duplicate basenames are now two, up from one at the r101 audit **[O]**:

```
$ find reports -type f -printf '%f\n' | sort | uniq -d
F6-rea-census.md
navagent-dissection.md
```

`navagent-dissection.md` is the pre-existing r101-vs-frontier collision documented at
`reports/round-101/r101-scribe-audit.md` F3; it is unrelated to r102.

### 3.2 No byte-identical duplicate in `reports/round-102/`

```
$ find reports/round-102 -type f -exec sha256sum {} + | awk '{print $1}' | sort | uniq -d
(no output)
```

Distinct bytes for all 18 files at the §1 frame **[O]** — the `F6-rea-census.md` pair included.

### 3.3 No basename collision between r102 and any other round

```
$ comm -12 <(find reports/round-102 -type f -printf '%f\n' | sort) \
           <(find reports -type f ! -path 'reports/round-102/*' -printf '%f\n' | sort)
(no output)
```

Every r102 basename is new to `reports/` **[O]**.

---

## 4. Other runtime observations

- **Exactly one executable file** in the directory: `reports/round-102/reruns/pointer-sweep.sh`
  (mode `u+x`) **[O]**. It is a shell script, so it is the only non-markdown artifact.
- **Every markdown file except `reruns/pointer-sweep.sh` carries a `SEAT-NN` token** in its H1 or
  header block; the shell script carries `SEAT-37` in a `#` comment instead **[O]**. So the seat
  attribution is recoverable for all 18 files despite the filename drift in §2.2.
- **No `r102-report.md`** exists at any frame observed — round-close report is pending **[O]**.
- All files are **untracked** (`git status --porcelain reports/round-102/` → `?? reports/round-102/`);
  the round lands as one commit at close **[O]**.

---

## 5. How to re-measure this inventory

The directory mutates every few seconds. To reproduce a frame:

```bash
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
date -u +%Y-%m-%dT%H:%M:%SZ
find reports/round-102 -type f | sort | while read f; do
  seat=$(grep -o -m1 -E 'SEAT-[0-9]+' "$f" | head -1)
  printf '%s|%s|%s|%s\n' "$(sha256sum "$f" | cut -c1-16)" "${seat:-—}" "$(stat -c%s "$f")" "$f"
done
find reports/round-102 -mindepth 1 -type d | sort
```

**Caveat for the round-close scribe:** §1 is a frame at `2026-10-18T17:42:20Z`, not the final
state. Re-run the block above before quoting any count, and expect the file count to be higher.

---

## 6. Summary

> **Frozen frame.** This table summarises the `17:42:20Z` frame only. Two later frames (§7, §8)
> supersede parts of it — in particular the "byte-identical duplicates: None" row is
> **falsified** by §8, and the file count is now 30. See §8.1 for the per-claim status table.

| question | verdict |
|---|---|
| Does `reports/round-102/` follow the r101 `rNN-<seat>.md` convention? | **No** — 0 of 18 files use it; r101 had 15. Seats are still recoverable from H1. |
| Are the new `before/`, `repairs/`, `reruns/`, `gate/`, `adversary/` subdirs acceptable? | **Yes** — new convention, noted; r101 had only `probes/`, and pre-r101 only `round-1-20261015/before/`. |
| Any duplicate basenames? | `F6-rea-census.md` in `before/` + `repairs/` — first in-round duplicate in lane history, deliberate and non-identical. |
| Any byte-identical duplicates? | **None**. |
| Files present at snapshot | **18** at `17:42:20Z` (grew 7 → 18 over 53 s). |
| Round-close report present? | **No** — `r102-report.md` not yet written. |

---

## 7. Correction frame at `2026-10-18T17:42:43Z` (25 files)

§1–§6 above are **frozen at `17:42:20Z`** and are left unedited (correction-note discipline: a
frozen observation is not silently rewritten). This section records the next frame and corrects
the two §4 claims that it falsified.

Command and result **[O]**:

```
$ date -u +%Y-%m-%dT%H:%M:%SZ
2026-10-18T17:42:43Z
$ find reports/round-102 -type f | wc -l
25
```

### 7.1 Corrections to §4

| §4 claim as written | status | corrected statement |
|---|---|---|
| "Exactly one executable file … the only non-markdown artifact" | **FALSIFIED** | Two non-markdown files now exist: `reruns/pointer-sweep.sh` (still the only file with `u+x`) **and** `gate/author-run.raw.txt` (1925 B, mode `644`, gate stdout capture). |
| "Every markdown file … carries a `SEAT-NN` token" | **STANDS** | All **23** markdown files carry `SEAT-NN`; the 2 non-markdown files do not (`gate/author-run.raw.txt` carries 0 seat tokens — it is raw gate output). |
| "No `r102-report.md` exists" | **STANDS** | Still absent at this frame. |
| §2.2 "zero `r102-<seat>.md` files" | **STANDS** | Still zero at 25 files. |
| §3.1 duplicate basename `F6-rea-census.md` | **STANDS** | Still the only duplicate. |
| §3.2 no byte-identical duplicate | **STANDS** | Re-checked at 25 files: no output. |

```
$ find reports/round-102 -type f ! -name '*.md' | sort
reports/round-102/gate/author-run.raw.txt
reports/round-102/reruns/pointer-sweep.sh
$ find reports/round-102 -type f -perm -u+x | sort
reports/round-102/reruns/pointer-sweep.sh
$ find reports/round-102 -type f -name '*.md' | wc -l
23
```

### 7.2 Files added between the §1 frame and this one (7 new)

| path | seat | bytes | sha256 (16) |
|---|---|---|---|
| `reports/round-102/adversary/F5.md` | SEAT-14 | 14570 | `4fb3b8a3842233dd` |
| `reports/round-102/adversary/F6.md` | SEAT-15 | 9381 | `e7151bc5f9341ce5` |
| `reports/round-102/gate/author-run.raw.txt` | — (raw gate output) | 1925 | `85bfc600527dc7a2` |
| `reports/round-102/install-recheck.md` | SEAT-60 | 10034 | `9ce73dd3f4e6993b` |
| `reports/round-102/provenance-rerun.md` | SEAT-52 | 14010 | `97f843d96a08a006` |
| `reports/round-102/reruns/pointers.md` | SEAT-37 | 16041 | `86c91518fb632081` |
| `reports/round-102/reports-index.md` | SEAT-57 | 11645 | `de656474831b66e8` |

Three files also **changed in place** between frames — they are live-mutating, so any sha256
quoted for them is frame-specific **[O]**:

| path | §1 (17:42:20Z) | this frame (17:42:43Z) |
|---|---|---|
| `adversary/F3.md` | `6a2d297a3379dd7d`, 11028 B | `7d37c5f5eaa71eff`, 11702 B |
| `ledger-check.md` | `8c79cb53ef57f8ee`, 10238 B | `4f040115ecd74d50`, 11651 B |

### 7.3 Verdicts carried forward

The §2 convention verdict is **unchanged and now stronger**: at 25 files the round still has
**zero** `r102-<seat>.md` files, and the five subdirs (`adversary/`, `before/`, `gate/`,
`repairs/`, `reruns/`) are all still in use. The subdir layout has proved itself over the extra
7 files — every new file landed inside an existing subdir or as a top-level topic slug; no new
subdir was invented. **[O]**

Directory growth across the whole audit window: **7 → 18 → 25 files** over
`17:41:27Z`→`17:42:43Z` (76 s). Re-run §5's block before quoting any count.

---

## 8. Second correction frame at `2026-10-18T17:43:07Z` (29 files)

§7's "no byte-identical duplicate" re-check is now **falsified** by a file pair that landed after
it. Recorded here rather than edited into §7.

```
$ date -u +%Y-%m-%dT%H:%M:%SZ
2026-10-18T17:43:07Z
$ find reports/round-102 -type f | wc -l
29
$ find reports/round-102 -type f -exec sha256sum {} + | sort | awk '{print $1}' | uniq -d
85bfc600527dc7a23e64192083150651cca5f78c7e17c4f326d0bf73f02a822b
```

The pair **[O]**:

```
85bfc600527dc7a23e64192083150651cca5f78c7e17c4f326d0bf73f02a822b  reports/round-102/gate/author-run.raw.txt
85bfc600527dc7a23e64192083150651cca5f78c7e17c4f326d0bf73f02a822b  reports/round-102/gate/author-run.txt
```

`gate/author-run.raw.txt` and `gate/author-run.txt` are **byte-identical** — same 1925 B, same
sha256. This is the **first byte-identical duplicate in `reports/round-102/`**, and it falsifies
both §3.2 (18-file frame) and §7.1's carry-forward row. Two plausible readings, neither verifiable
from this seat **[?]**: (a) the same gate stdout was deliberately saved under two extensions
(`.raw.txt` = verbatim capture, `.txt` = the working copy), or (b) an accidental second write. A
seat owning `gate/` should resolve which; this seat writes no file it does not own.

### 8.1 Status of every earlier numeric claim at this frame

| claim | frame | status now |
|---|---|---|
| zero `r102-<seat>.md` files | §2.2 | **STANDS** — still 0 at 29 files |
| 5 round-level subdirs | §1.2 | **STANDS** — still exactly the same 5, no new subdir invented |
| duplicate basename `F6-rea-census.md` | §3.1 | **STANDS** — still the only basename duplicate |
| no byte-identical duplicate | §3.2, §7.1 | **FALSIFIED** — `gate/author-run.{raw.,}txt` pair (§8) |
| 2 non-markdown files | §7.1 | **SUPERSEDED** — now 4 (`gate/author-run.raw.txt`, `gate/author-run.txt`, `gate/controls.txt`, `reruns/pointer-sweep.sh`) |
| "exactly one executable" | §4, §7.1 | **STANDS** — `reruns/pointer-sweep.sh` is still the only `u+x` file |

### 8.2 Files added since §7 (4 new)

| path | bytes | sha256 (16) |
|---|---|---|
| `reports/round-102/gate/author-run.txt` | 1925 | `85bfc600527dc7a2` (dup of `.raw.txt`) |
| `reports/round-102/gate/controls.txt` | 2704 | `2f6934dcfb310fc7` |
| `reports/round-102/kimi-surfaces.md` | 16956 | `a2da205fe8060da6` |
| `reports/round-102/repairs/F5-engines.md` | 7485 | `90e7567510e20db3` |

Two more files changed in place (`adversary/F6.md` 9381→11599 B; `install-recheck.md`
10034→10248 B), confirming that even the §7 frame is already partly stale **[O]**.

### 8.3 Growth across the full audit window

| frame (UTC) | files |
|---|---|
| `17:41:27Z` | 7 |
| `17:41:41Z` | 8 |
| `17:41:47Z` | 10 |
| `17:42:05Z` | 15 |
| `17:42:10Z` | 17 |
| `17:42:20Z` | 18 |
| `17:42:43Z` | 25 |
| `17:43:07Z` | 29 |

**7 → 29 files in 100 seconds.** No frame in this document is the directory's current state.
The round-close scribe must re-run §5 before quoting any count. **[O]**

---

## 9. Transient observation — the byte-pinned `upstream/` was momentarily dirty at `17:43:26Z`

Not a defect in `reports/round-102/`; recorded because it affects anyone reading a gate result
taken during this window. **In scope for this seat only as a runtime observation** — this seat
wrote no file outside `reports/round-102/reports-index.md`.

At `17:43:26Z` a `git status` over the lane showed the r101 byte-pinned subtree dirty **[O]**:

```
$ git status --porcelain corpus/knowledge/unreal-mcp/
 M corpus/knowledge/unreal-mcp/upstream/README.md
 M corpus/knowledge/unreal-mcp/upstream/skills/unreal-mcp/SKILL.md
 M corpus/knowledge/unreal-mcp/README.md
?? corpus/knowledge/unreal-mcp/gate/
```

`git diff --stat` reported **168 deletions across 2 files** in `upstream/`, i.e. both vendored
files appeared truncated. Eight seconds later, at `17:43:34Z`, the same subtree was **clean**
again **[O]**:

```
$ git diff --stat HEAD -- corpus/knowledge/unreal-mcp/upstream/
(no output)
$ git status --porcelain corpus/knowledge/unreal-mcp/
 M corpus/knowledge/unreal-mcp/README.md
?? corpus/knowledge/unreal-mcp/gate/
```

Both files had fresh mtimes (`14:43:32.6018` / `14:43:32.6028`) and were byte-identical to HEAD
again by the time they were measured (`112` lines / `8398` B, and `56` lines / `7098` B — matching
`git show HEAD:` counts of `112` and `56`). The reading is that a concurrent gate run rewrites the
vendored files and restores them, leaving a window of a few seconds in which `upstream/` is
non-identical. **[I]** — this seat did not observe the writer.

**Consequence for the round:** any manifest/gate check over `corpus/knowledge/unreal-mcp/upstream/`
executed inside that window can report a spurious byte-identity failure. A gate that reports
failure on the subtree should be re-run before the failure is believed. **[I]**

`corpus/knowledge/unreal-mcp/README.md` remained modified at both frames — that is the F8 wording
fold the round owns, not a transient. **[O]**

---

## 10. Intermediate state of this seat's artifact — **superseded by §12**

> Written at the `17:43:34Z` frame; it is **not** the final state. §11 withdrew verdict 4 below and
> §12 superseded verdict 1. The current values are at §12.

| property | value at `17:43:34Z` |
|---|---|
| path | `reports/round-102/reports-index.md` |
| bytes / lines | 19516 / 447 (re-measure with `wc`) |
| frames recorded | 8 (`17:41:27Z` → `17:43:34Z`), file count **7 → 31** |
| files written by this seat | **1** — this file only |
| lane HEAD | `2c99b7b8155841617d844c609813afcba77aa207` (unchanged) |

**Verdicts at that frame** (1 and 4 since revised — see §12.1 and §11.5):

1. `reports/round-102/` does **not** use the r101 `rNN-<seat>.md` convention — **0** such files,
   against 15 in `reports/round-101/`. The seat is recoverable from each file's H1.
2. The five round-level subdirs (`adversary/`, `before/`, `gate/`, `repairs/`, `reruns/`) are a
   **new convention, acceptable and noted** — r101 had only `probes/`, pre-r101 only
   `round-1-20261015/before/`.
3. `F6-rea-census.md` is a duplicate basename across `before/` and `repairs/` (first in-round
   duplicate in lane history, deliberate, non-identical bytes).
4. `gate/author-run.raw.txt` and `gate/author-run.txt` are **byte-identical** (first such pair in
   the round).

---

## 11. Resolution at `2026-10-18T17:43:44Z` (32 files) — two "findings" were rename/write windows

This section resolves §8's duplicate and §9's dirty subtree. Both were **transient artifacts of
concurrent writers**, not defects. Recorded because §8 and §10 stated them as findings.

### 11.1 The byte-identical pair was a rename in progress — §8 claim 4 is withdrawn

```
$ date -u +%Y-%m-%dT%H:%M:%SZ
2026-10-18T17:43:44Z
$ find reports/round-102 -type f -exec sha256sum {} + | sort | awk '{print $1}' | uniq -d
(no output)
$ ls -la reports/round-102/gate/
-rw-r--r-- 1 vgpnk vgpnk  8212 Oct 18 14:43 author-run.md
-rw-r--r-- 1 vgpnk vgpnk  1925 Oct 18 14:42 author-run.txt
-rw-r--r-- 1 vgpnk vgpnk  3158 Oct 18 14:43 controls.txt
-rw-r--r-- 1 vgpnk vgpnk 22891 Oct 18 14:43 mutation.md
-rw-r--r-- 1 vgpnk vgpnk  9554 Oct 18 14:41 runtime-run.md
```

`gate/author-run.raw.txt` **no longer exists**; `gate/author-run.txt` does, with the same 1925 B
and the same `85bfc600527dc7a2…` sha256. The pair observed at `17:43:07Z` was therefore a
**rename window** — the writer created `author-run.txt` before removing `author-run.raw.txt`, and
this seat sampled the directory inside that window. **[I]**, and the inference is strong because
the content hash is unchanged and only the name differs.

**Withdrawn:** §8's "first byte-identical duplicate in `reports/round-102/`" and §10's surviving
verdict 4. `reports/round-102/` has **no** byte-identical duplicate at this frame. The only
duplicate that persists is the *basename* pair `F6-rea-census.md` (§3.1), which is deliberate.

### 11.2 The dirty `upstream/` was likewise a write window — §9 stands as a caution only

The subtree was clean again at `17:43:34Z` (§9) and remains clean. Same reading: a concurrent
writer, not a corruption. §9's operational caution is unaffected and remains the useful part of
that section — a gate over `upstream/` can hit a spurious failure inside such a window.

### 11.3 Files added since §9 (2 new)

| path | bytes |
|---|---|
| `reports/round-102/gate/mutation.md` | 22891 |
| `reports/round-102/round-count.md` | (see §12) |

### 11.4 What this changes for the reader

The lesson for any future seat indexing a live round directory: **a single `find`/`sha256sum`
sample cannot distinguish a real duplicate from a rename window, and cannot distinguish real
corruption from a write window.** Two samples separated by a few seconds are the minimum. Every
finding in this document that rested on one sample is marked with its frame time for exactly this
reason.

### 11.5 Claim status after §11

| claim | status |
|---|---|
| 0 `r102-<seat>.md` files | **STANDS** |
| 5 round-level subdirs, new convention | **STANDS** |
| duplicate basename `F6-rea-census.md` | **STANDS** |
| byte-identical duplicate | **WITHDRAWN** — rename window (§11.1) |
| dirty byte-pinned `upstream/` | **WITHDRAWN as a defect** — write window (§11.2) |

---

## 12. Final frame at `2026-10-18T17:44:29Z` (37 files) — convention partially adopted

§11.5's "0 `r102-<seat>.md` files" is **superseded**. One has landed **[O]**:

```
$ find reports/round-102 -maxdepth 1 -type f -name 'r102-*' | sort
reports/round-102/r102-distiller.md
```

`r102-distiller.md` (SEAT-31, 38124 B, sha256 `627d555396638cc3…`) is the **first and only** file
in this round to use the r101 `rNN-<seat>.md` form. The r101 convention is therefore being
**partially** adopted: 1 of 37 files, against 15 of ~17 in `reports/round-101/`.

### 12.1 Revised verdict on §2.2

| frame | `r102-<seat>.md` files | total files | verdict |
|---|---|---|---|
| `17:41:27Z` | 0 | 7 | no |
| `17:42:20Z` | 0 | 18 | no |
| `17:42:43Z` | 0 | 25 | no |
| `17:43:07Z` | 0 | 29 | no |
| `17:43:44Z` | 0 | 32 | no |
| `17:44:29Z` | **1** | **37** | **partial** |

**Final verdict: `reports/round-102/` does not follow the r101 `rNN-<seat>.md` convention, with one
exception (`r102-distiller.md`).** The round-close report, if it lands as `r102-report.md`, would be
a second exception. Every other file is a topic slug or a subdir slug. The seat remains recoverable
from each file's H1 in all 36 non-`r102-*` files **[O]**.

### 12.2 Full inventory at `17:44:29Z` — 37 files, 5 subdirs

Top level (17 files): `battery-integrity.md` · `freshness-pin.md` · `git-hygiene.md` ·
`install-recheck.md` · `kimi-surfaces.md` · `ledger-check.md` · `lesson-index.md` ·
`provenance-rerun.md` · `r102-distiller.md` · `reports-index.md` · `round-count.md` ·
`sentinel-mcp.md` · `skill-decision-table-draft.md`

`adversary/` (5): `F1.md` (SEAT-11) · `F2.md` (SEAT-12) · `F3.md` (SEAT-13) · `F5.md` (SEAT-14) ·
`F6.md` (SEAT-15)

`before/` (5): `baseline-integrity.md` (SEAT-06) · `F2-verdicts-json.md` (SEAT-02) ·
`F3-sha-drift.md` (SEAT-03) · `F5-engines-threejs.md` (SEAT-04) · `F6-rea-census.md` (SEAT-05)

`gate/` (5): `author-run.md` (SEAT-17) · `author-run.txt` · `controls.txt` · `mutation.md`
(SEAT-18) · `runtime-run.md` (SEAT-39)

`repairs/` (4): `F1a-r22-readme.md` (SEAT-07) · `F5-engines.md` (SEAT-26) · `F6-rea-census.md`
(SEAT-10) · `F8-readme-lines.md` (SEAT-28)

`reruns/` (5): `labels.md` (SEAT-36) · `links.md` (SEAT-38) · `manifest.md` (SEAT-35) ·
`pointers.md` (SEAT-37) · `pointer-sweep.sh` (SEAT-37)

Note the **defect-id symmetry**: `before/F2,F3,F5,F6` ↔ `repairs/F1a,F5,F6,F8` ↔
`adversary/F1,F2,F3,F5,F6`. The same defect id is reused across the three roles, which is what
produces the §3.1 basename duplicate. This is the intended shape of the new convention, not drift.
**[O]**/**[I]**

### 12.3 Stability samples after the final frame

Two samples 15 s apart, both at 37→38 files, both with the same duplicate set **[O]**:

```
$ (17:44:32Z)  count=37  r102-*=1  dup-basename=F6-rea-census.md  dup-bytes=(none)
$ (17:44:47Z)  count=38  r102-*=1  dup-basename=F6-rea-census.md  dup-bytes=(none)
```

The duplicate-*basename* finding is now confirmed across **six** independent frames and is the one
structural claim in this document that never moved. The byte-identical finding was a single-frame
artifact and is withdrawn (§11.1). **[O]**

### 12.4 Method note — why this document has five correction sections

The r102 report directory was written by ~30 concurrent seats and grew **7 → 38 files** during the
~3 minutes of this audit. Three of this seat's initial findings (`§3.2` byte-identical duplicate,
`§8`/`§10` same, `§9` dirty `upstream/`) were **concurrent-writer windows**, not defects, and each
is explicitly withdrawn where it was raised rather than deleted. The rule this seat applied:
*never silently rewrite a frozen observation; append a dated correction frame.* A single
`find`+`sha256sum` sample cannot distinguish a real duplicate from a rename window — the minimum
evidence is two samples a few seconds apart, which is what §12.3 provides.

---

## 13. Closing note at `2026-10-18T17:45:06Z` (40 files) — the convention is being adopted late

Two `rNN-<seat>.md` files now exist **[O]**:

```
$ find reports/round-102 -maxdepth 1 -type f -name 'r102-*' -printf '%s %p\n' | sort -k2
27630 reports/round-102/r102-connector.md
40825 reports/round-102/r102-distiller.md
```

`r102-connector.md` landed after §12's frame. So the r101 form is arriving **late and
progressively** — 0 files for the first four minutes of this audit, then 1 (`r102-distiller.md`,
`17:44:2x`), then 2 (`r102-connector.md`, `17:45:0x`) as the larger seats land. The likely reading
is that seats writing long, round-close-style artifacts adopt the convention while the short
per-defect capture seats do not **[I]** — this seat cannot verify seat intent.

**This is the last frame in this document.** The audit window was
`17:41:27Z` → `17:45:06Z` (~3.6 min), **7 → 40 files**. The directory was still growing when this
seat stopped measuring, so the true final state is not recorded here by construction. The
round-close scribe must re-run §5.

Final tally of this document's claims, with the frame each rests on:

| claim | frames supporting it | status |
|---|---|---|
| round-level subdirs (`adversary/ before/ gate/ repairs/ reruns/`) are a new, acceptable convention | 6 of 6 | **STANDS** |
| `F6-rea-census.md` is a duplicate basename across `before/` + `repairs/` | 6 of 6 | **STANDS** |
| `reports/round-102/` mostly does not use `rNN-<seat>.md` | 6 of 6, converging to 2/40 | **STANDS** (reworded §12.1, §13) |
| byte-identical duplicate exists | 1 of 6 | **WITHDRAWN** (§11.1) — rename window |
| byte-pinned `upstream/` was corrupted | 1 of 6 | **WITHDRAWN as a defect** (§11.2) — write window |

The two withdrawn claims are the substantive result of the second half of this audit: **a
single-sample inventory of a live round directory manufactures false positives**, and both this
seat's false positives came from sampling inside a concurrent writer's rename or rewrite window.
