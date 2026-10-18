# r102 scribe-audit — custody audit of `reports/round-102/`

Seat: **SEAT-42 SCRIBE-AUDIT**. Lane: `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`.
Scope: inventory `reports/round-102/` at this seat's runtime — file count, naming-convention
compliance against `reports/round-101/`, duplication flags — and verify that r101 stayed untouched.

**Read-only.** This seat wrote nothing but this file, edited no cited artifact, and ran no
`git` state-mutating command.

Lane HEAD throughout: `2c99b7b8155841617d844c609813afcba77aa207`
(*"r101 report-last: verdict (all axes improved), LOG entry, SCORECARD block, adjudication
addendum — work 1659c036"*).

Tags: **[O]** command-run observation · **[I]** labelled inference · **[?]** unknown.

**Status: AUDIT COMPLETE, and the subject never stopped moving.** The directory grew
**3 → 57 files** during this seat's window (`2026-10-18T14:40:52-03:00` →
`2026-10-18T14:49:46-03:00`, ~8.9 min) and was still growing when the last frame was taken. The
count was also **non-monotone** — it went 53 → 52 → 54 → 57 across four consecutive frames (§8) —
so it is a series, not a number. Every count below carries the time it was observed; §2 is the
growth series and §8 the closing frames, and together they are the honest form of "file count" for
this round.

---

## 0. Method (exact commands, all read-only)

```
date -Iseconds                                    # every frame is stamped
find reports/round-102 -type f -printf '%P|%s\n' | sort
find reports/round-102 -type f -exec sha256sum {} \;
find reports/round-102 -mindepth 1 -type d -printf '%P\n' | sort
find reports/round-102 -maxdepth 1 -type f -name 'r102-*' | sort
find reports -type f -printf '%f\n' | sort | uniq -d              # basename collisions
find reports -type f -exec sha256sum {} \; | awk '{print $1}' | sort | uniq -d   # byte dups
find reports/round-* -maxdepth 1 -type f -name '*.md' ! -name 'r[0-9]*-*'        # off-pattern
for d in $(find reports -mindepth 1 -maxdepth 1 -type d); do ... done            # per-round tally
git rev-parse HEAD
git status --porcelain
git status --porcelain reports/round-101
git diff --name-only HEAD -- reports/round-101
git ls-files reports/round-101 | wc -l
for f in $(git ls-files reports/round-101); do cmp -s "$f" <(git show HEAD:"$f"); done
grep -rn "reports/round-102" --include='*.md' --include='*.sh' . | grep -v '^./reports/round-102/'
```

---

## 1. r101 is untouched — the discipline check **[O]**

This is the one property the brief asks to verify, and it holds on **five** independent
re-verifications spread across the whole audit window.

```
$ git ls-files reports/round-101 | wc -l
33
$ git status --porcelain reports/round-101 | wc -l
0
$ git diff --name-only HEAD -- reports/round-101 | wc -l
0
```

All **33** tracked files under `reports/round-101/` are byte-identical to their `HEAD` blobs
(`cmp -s "$f" <(git show HEAD:"$f")` → `OK` for every one; **0** `DIFF` rows). No r101 file was
added, deleted, renamed, or rewritten by any r102 seat.

The same check run against **every other round directory** in the lane also comes back clean:

```
$ for d in $(find reports -mindepth 1 -maxdepth 1 -type d ! -name 'round-102'); do
    n=$(git status --porcelain "$d" | wc -l); [ "$n" -ne 0 ] && echo "DIRTY $d ($n)"; done
(no output — no DIRTY lines)
```

Repo-wide working tree at the last frame **[O]**:

```
$ git status --porcelain
 M corpus/artifacts/unreal-r22/README.md
 M corpus/knowledge/engines.md
 M corpus/knowledge/rea.md
 M corpus/knowledge/unreal-mcp/README.md
 M corpus/lessons/r22-unreal-review.md
?? corpus/knowledge/unreal-mcp/gate/
?? corpus/lessons/r102-unreal-integration.md
?? reports/round-102/
```

Every modification is a declared r102 repair path outside `reports/round-101/`; the only untracked
report directory is `reports/round-102/` itself. `reports/round-102/` is **not** gitignored
(`git check-ignore -v reports/round-102/battery-integrity.md` → rc=1), so it is tracked-visible
for the round-close commit. **[O]**

---

## 2. The file count is a moving target — growth series **[O]**

35 frames, same command (`find reports/round-102 -type f | wc -l`), each stamped with the time it
was taken. All times `-03:00`.

| time | files | `r102-*` | what appeared |
|---|---|---|---|
| 14:40:52 | 3 | 0 | `before/{F2-verdicts-json,F6-rea-census}.md`, `repairs/F1a-r22-readme.md` — the first frame |
| 14:41:24 | 3 | 0 | (unchanged) |
| 14:41:35 | 7 | 0 | `before/{baseline-integrity,F3-sha-drift,F5-engines-threejs}.md`, `battery-integrity.md` |
| 14:41:44 | 8 | 0 | `reruns/pointer-sweep.sh` |
| 14:41:53 | 12 | 0 | `freshness-pin.md`, `git-hygiene.md`, `gate/runtime-run.md` |
| 14:42:03 | 15 | 0 | `reruns/links.md`, `repairs/F6-rea-census.md`, `lesson-index.md` |
| 14:42:13 | 17 | 0 | `reruns/labels.md`, `reruns/manifest.md` |
| 14:42:23 | 18 | 0 | `provenance-rerun.md` |
| 14:42:33 | 21 | 0 | `ledger-check.md`, `gate/author-run.raw.txt`, `adversary/F3.md` |
| 14:42:43 | 25 | 0 | `adversary/{F5,F6}.md`, `reports-index.md`, `reruns/pointers.md` |
| 14:42:58 | 26 | 0 | `install-recheck.md` |
| 14:43:04 | 29 | 0 | `kimi-surfaces.md`, `gate/controls.txt`, `repairs/F5-engines.md` |
| 14:43:16 | 30 | 0 | `adversary/F6.md` rewrite window |
| 14:43:24 | 32 | 0 | `adversary/{F1,F2}.md`, `gate/mutation.md` |
| 14:43:32–14:44:04 | 32 | 0 | (flat for ~40 s) |
| 14:44:12 | 33 | 0 | `round-count.md` |
| 14:44:24 | 37 | 1 | `gate/author-run.md`, `math-audit.md`, `sentinel-mcp.md`, `skill-decision-table-draft.md`, **`r102-distiller.md`** |
| 14:44:51 | 39 | 2 | **`r102-connector.md`** |
| 14:45:06 | 40 | 2 | `gate/review.md` |
| 14:45:21 | 41 | 2 | — |
| 14:45:33 | 42 | 3 | `before/F1-r22-path-drift.md` + a third `r102-*` |
| 14:45:45 | 45 | 4 | `fold-spec.md`, `gate/{adversary-b,sentinel}.md` |
| **14:46:01** | **47** | **5** | `r102-boundary-scout.md`, `r102-report.md`, `r102-verification-protocol.md` |

Growth across the window: **3 → 47 files, ~16×**, roughly one file every 4–6 seconds at the
observed rate. **The directory was still growing at this frame** — this table stops at `14:46:01`
because the audit proper ended there; **§8 carries the frames after it, out to 57 files at
`14:49:46`, including a frame where the count went *down*.** Neither table is the final state: the
true final state is not recorded in this document by construction, and this seat did not wait for
quiescence. **[O]**

### 2.1 This finding is corroborated by an independent seat **[O]**

`reports/round-102/reports-index.md` (**SEAT-57**) ran the same audit from a different window
(`2026-10-18T17:41:27Z` → `17:45:06Z`, i.e. `14:41:27` → `14:45:06` local) and reports
**7 → 40 files** with five correction frames. Its 40-file frame and this seat's 40-file frame are
the same instant. Two seats, independently, measuring the same live directory, agreeing on the
count at the overlap. **[O]**

Its §13 closing note and this seat's last frame also agree that the r101 `rNN-<seat>.md` form
arrived **late and progressively** — 0 files for the first four minutes, then a trickle. **[O]**

---

## 3. Naming-convention compliance vs `reports/round-101/` **[O]**

### 3.1 The two rounds side by side

Command:

```
$ for d in round-98 round-99 round-100 round-101 round-102; do
    printf '%s: top-level=%s rNN=%s offpattern=%s subdirs=%s\n' "$d" \
      "$(find reports/$d -maxdepth 1 -type f|wc -l)" \
      "$(find reports/$d -maxdepth 1 -type f -name 'r[0-9]*-*'|wc -l)" \
      "$(find reports/$d -maxdepth 1 -type f ! -name 'r[0-9]*-*'|wc -l)" \
      "$(find reports/$d -mindepth 1 -maxdepth 1 -type d|wc -l)"; done
```

| round | top-level files | `rNN-*` | off-pattern | round-level subdirs |
|---|---|---|---|---|
| round-98 | 9 | 9 | 0 | 0 |
| round-99 | 9 | 9 | 0 | 0 |
| round-100 | 9 | 9 | 0 | 0 |
| **round-101** | 17 | **15** | 2 | 1 (`probes/`) |
| **round-102** @14:46:01 | 19 | **5** | **14** | **5** |
| **round-102** @14:49:31 | **27** | **7** | **20** | **5** |

Lane-wide, `rNN-*.md` is the standing form: **31 of 35 round directories use it for every
top-level file** (`for d in $(find reports -mindepth 1 -maxdepth 1 -type d -name 'round-*'); do
find "$d" -maxdepth 1 -type f ! -name 'r[0-9]*-*' | wc -l; done` → the only non-zero rounds are
`round-101` (2), `round-102` (20), `round-1-20261015` (2), `round-86` (2)). `round-101` is the
first to slip (15/17, the 2 exceptions pre-existing and task-card-named); `round-102` is the
first to invert the ratio. **[O]**

### 3.2 Verdict: r102 does **not** follow the r101 convention — it invents a different one

At the first frame the count of `r102-<seat>.md` files was **zero**:

```
$ find reports/round-102 -maxdepth 1 -type f -name 'r102-*' | sort
(no output)
```

By the closing frame it is **7** (`r102-adjudicator-draft.md`, `r102-boundary-scout.md`,
`r102-connector.md`, `r102-distiller.md`, `r102-report.md`, `r102-scribe-audit.md`,
`r102-verification-protocol.md`) against **20** off-pattern top-level files
(`battery-integrity.md`, `battery-relation.md`, `engines-verify.md`, `fold-spec.md`,
`freshness-pin.md`, `git-hygiene.md`, `install-recheck.md`, `kimi-surfaces.md`, `ledger-check.md`,
`lesson-critic.md`, `lesson-index.md`, `lesson-verify.md`, `math-audit.md`, `provenance-rerun.md`,
`reports-index.md`, `round-count.md`, `r22-crosscheck.md`, `sentinel-mcp.md`,
`skill-decision-table-draft.md`, `stub-cleanliness.md`). **[O]**

So the honest statement is **not** "r102 abandoned the convention" but **"r102 is adopting it late
and partially"** — 0 of 19 for the first four minutes, then 7 of 27. Two readings are consistent
with the frames and this seat cannot separate them: (a) long round-close artifacts
(`r102-report.md`, `r102-distiller.md`, `r102-connector.md`, `r102-verification-protocol.md`,
`r102-adjudicator-draft.md`) adopt the form while short per-defect captures do not; (b) seats
simply landed in different orders and the ratio would have risen further had the directory been
sampled later. **[O]**/**[I]**

Reading (a) is **supported by the late frames**: between `14:46:26` and `14:49:31` the
`r102-*` count went 6 → 7 while the off-pattern count went 15 → 20. Every late arrival except
`r102-adjudicator-draft.md` was a short topic-slug capture. **[O]**

### 3.3 A genuinely new layout: five round-level subdirectories

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

`reports/round-102/` is the first round in lane history to organise its reports into role-named
subdirectories. Before r102 the only round-level subdirs were `round-1-20261015/before/`
(JSON evidence, not reports) and `round-101/probes/` (created the previous round). r102 adds
**five**: `adversary/`, `before/`, `gate/`, `repairs/`, `reruns/`. **[O]**

The layout carries real information — it groups by *function* (before-capture / repair / re-run /
adversarial re-check / gate execution) rather than by *seat*, and it produces a visible
defect-id symmetry: `before/{F1,F2,F3,F5,F6}` ↔ `repairs/{F1a,F3,F5,F6,F8}` ↔
`adversary/{F1,F2,F3,F5,F6}` ↔ `gate/{mutation,review,sentinel,adversary-a,adversary-b}`. That
symmetry is the reason the §4.1 basename collisions exist at all. **[O]**/**[I]**

Cost: a filename alone no longer identifies the seat (`reruns/labels.md` vs `r102-<seat>.md`), and
cross-round greps that assume `reports/round-N/<file>.md` need a `-mindepth 2` form for this
round. The seat remains recoverable from each file's H1 for all but 2 of 57 files (§5.1). **[I]**

---

## 4. Duplication flags

### 4.1 `before/` ↔ `repairs/` basename reuse — **two** pairs, distinct content **[O], STANDS**

```
$ find reports/round-102 -type f -printf '%f\n' | sort | uniq -d
F3-sha-drift.md
F6-rea-census.md
```

| path | seat | bytes | sha256 |
|---|---|---|---|
| `reports/round-102/before/F3-sha-drift.md` | SEAT-03 | 6491 | `c45493548703051a…` |
| `reports/round-102/repairs/F3-sha-drift.md` | — | 17907 | (landed after `14:49`) |
| `reports/round-102/before/F6-rea-census.md` | SEAT-05 | 5580 | `4f9b01f9dfae3b77…` |
| `reports/round-102/repairs/F6-rea-census.md` | SEAT-10 | 9739 | `542c5a189f1bc70f…` |

Different sizes, different hashes, different roles: each `before/` file is the before-capture and
its `repairs/` namesake is the repair record for the **same defect id**. **Not a duplicate of
content — a deliberate reuse of the defect id across the `before/` and `repairs/` namespaces**,
which is what makes the round's defect lattice readable at a glance. **[O]**/**[I]**

`F6-rea-census.md` survived **every** frame from `14:42:02` to `14:49:22` — the one structural
claim in this document that never moved. `F3-sha-drift.md` is a **later instance of the same
pattern**, not a contradiction: the repair for F3 landed at `14:49` and reproduced the collision
shape exactly as predicted. **The pattern is growing as the round lands, which strengthens rather
than weakens it.** **[O]**

Lane-wide basename collisions are now four:

```
$ find reports -type f -printf '%f\n' | sort | uniq -d
F3-sha-drift.md
F6-rea-census.md
kimi-surfaces.md
navagent-dissection.md
```

- `F3-sha-drift.md`, `F6-rea-census.md` — **new in r102**, both the intended `before/`↔`repairs/`
  reuse described above. Scoped to `reports/round-102/` only. **[O]**
- `navagent-dissection.md` — pre-existing (r101 vs `reports/frontier/`), already documented in
  `reports/round-101/r101-scribe-audit.md` §F3. Unchanged by this round. **[O]**
- `kimi-surfaces.md` — **new in r102.** `reports/round-101/probes/kimi-surfaces.md`
  (37191 B, `ab8e1ee2d48d4870…`) vs `reports/round-102/kimi-surfaces.md`
  (16956 B, `a2da205fe8060da6…`). Different bytes, same topic — r102 re-ran the r101 probe.
  A reader grepping `**/kimi-surfaces.md` gets two hits with no round marker in the name. **[O]**

### 4.2 Byte-identical duplicate — **observed once, then WITHDRAWN** **[O]**

At frames `14:42:33`, `14:42:43` and `14:43:04`–`14:43:16` there were two byte-identical files:

```
$ find reports -type f -exec sha256sum {} \; | grep '^85bfc600'
85bfc600527dc7a23e64192083150651cca5f78c7e17c4f326d0bf73f02a822b  reports/round-102/gate/author-run.raw.txt
85bfc600527dc7a23e64192083150651cca5f78c7e17c4f326d0bf73f02a822b  reports/round-102/gate/author-run.txt
```

By the `14:45:06` frame `gate/author-run.raw.txt` no longer existed:

```
$ ls reports/round-102/gate/
author-run.md  author-run.txt  controls.txt  mutation.md  review.md  runtime-run.md
```

**This seat withdraws the finding as a rename window, not a defect.** The evidence: the `.raw.txt`
name vanished while the shared digest survived under `author-run.txt`, and across **eight**
subsequent re-samples (`14:45:06` → `14:46:01`) the lane-wide byte-duplicate set is **empty**:

```
$ find reports -type f -exec sha256sum {} \; | awk '{print $1}' | sort | uniq -d
(no output)
```

A single `find`+`sha256sum` sample of a live directory cannot distinguish a real duplicate from a
seat mid-rename. The minimum evidence is two samples a few seconds apart, which is what this
paragraph provides. **SEAT-57 reached and withdrew the identical class of false positive
independently** (`reports-index.md` §11.1) — two seats, same sampling trap. **[O]**/**[I]**

At the last frame the lane contains **zero byte-identical report pairs** anywhere under
`reports/`:

```
$ comm -12 <(find reports/round-102 -type f -exec sha256sum {} \; | awk '{print $1}' | sort -u) \
           <(find reports -type f -not -path 'reports/round-102/*' -exec sha256sum {} \; | awk '{print $1}' | sort -u)
(no output)
```

So no r102 file is a byte-copy of any pre-existing report either. **[O]**

---

## 5. Other runtime observations

### 5.1 Seat recoverability **[O]**

Mapping at the closing frame (`14:49:46`). **55 of 57** files carry a `SEAT-NN` marker; the
remaining 2 are raw command-output captures:

```
$ with=0; without=0; for f in $(find reports/round-102 -type f); do
    if grep -q "SEAT-[0-9]" "$f" 2>/dev/null; then with=$((with+1)); else without=$((without+1)); fi; done
with=55 without=2 total=57
```

| subdir | files → seats |
|---|---|
| `adversary/` | `F1`→SEAT-11 · `F2`→SEAT-12 · `F3`→SEAT-13 · `F5`→SEAT-14 · `F6`→SEAT-15 |
| `before/` | `baseline-integrity`→SEAT-06 · `F1-r22-path-drift`→SEAT-01 · `F2-verdicts-json`→SEAT-02 · `F3-sha-drift`→SEAT-03 · `F5-engines-threejs`→SEAT-04 · `F6-rea-census`→SEAT-05 |
| `gate/` | `adversary-a.md`→SEAT-20 · `adversary-b.md`→SEAT-21 · `author-run.md`→SEAT-17 · `author-run.txt`→**NONE** · `controls.txt`→**NONE** · `mutation.md`→SEAT-18 · `review.md`→SEAT-22 · `runtime-run.md`→SEAT-39 · `sentinel.md`→SEAT-19 |
| `repairs/` | `F1a-r22-readme`→SEAT-07 · `F3-sha-drift`→SEAT-09 · `F5-engines`→SEAT-26 · `F6-rea-census`→SEAT-10 · `F8-readme-lines`→SEAT-28 |
| `reruns/` | `labels`→SEAT-36 · `links`→SEAT-38 · `manifest`→SEAT-35 · `pointers`→SEAT-37 · `pointer-sweep.sh`→SEAT-37 (in body, no H1 seat line) |
| top level | `battery-integrity`→SEAT-33 · `battery-relation`→SEAT-34 · `engines-verify`→SEAT-27 · `fold-spec`→SEAT-63 · `freshness-pin`→SEAT-59 · `git-hygiene`→SEAT-51 · `install-recheck`→SEAT-60 · `kimi-surfaces`→SEAT-62 · `ledger-check`→SEAT-55 · `lesson-critic`→SEAT-24 · `lesson-index`→SEAT-56 · `lesson-verify`→SEAT-25 · `math-audit`→SEAT-58 · `provenance-rerun`→SEAT-52 · `r102-adjudicator-draft`→SEAT-47 · `r102-boundary-scout`→SEAT-32 · `r102-connector`→SEAT-30 · `r102-distiller`→SEAT-31 · `r102-report`→SEAT-46 · `r102-scribe-audit`→SEAT-42 · `r102-verification-protocol`→SEAT-43 · `r22-crosscheck`→SEAT-29 · `reports-index`→SEAT-57 · `round-count`→SEAT-64 · `sentinel-mcp`→SEAT-53 · `skill-decision-table-draft`→SEAT-40 · `stub-cleanliness`→SEAT-54 |

Seat ids observed span **SEAT-01 … SEAT-64** (53 distinct ids). Only `gate/author-run.txt` and
`gate/controls.txt` carry no seat marker (raw captures); `reruns/pointer-sweep.sh` names SEAT-37
in a body comment rather than an H1. **The convention that the filename fails to convey, the H1
carries** — seat provenance is recoverable for 55 of 57 files from content alone, so §3.2's
off-pattern filenames cost provenance *in the filename*, not provenance itself. **[O]**

### 5.2 Citation relation to the pre-existing round dirs **[O]**

```
$ grep -rn "reports/round-102" --include='*.md' --include='*.sh' . | grep -v '^./reports/round-102/'
./corpus/knowledge/rea.md:34:2026-10-18 (receipts: `reports/round-102/repairs/F6-rea-census.md`).
```

Exactly **one** exact-path citation of r102 exists outside `reports/round-102/`: the F6 repair
receipt referenced from the `corpus/knowledge/rea.md` correction note. No r102 report cites
`reports/round-101/` in the reverse direction, and no pre-existing round directory was modified
(§1). The r102 report set is currently **near-orphaned from the corpus** — expected for a round
that is still landing, and a thing the round-close scribe should re-measure once the directory
stops moving. **[O]**/**[I]**

Bare-filename greps produce noise and are not usable as an orphan test here: `review.md` matches
37 files, `links.md` 5, `mutation.md` 3 — all substring hits in unrelated prose. Only the
exact-path form is meaningful. **[O]**

### 5.3 Relation to `reports/round-101/` — successor, not duplicate **[O]**

r102 does not re-derive r101. It **measures** it: `reruns/manifest.md` (SEAT-35) re-runs the r101
`.manifest.d/` sha256 check over the byte-pinned `corpus/knowledge/unreal-mcp/` subtree,
`reruns/labels.md` (SEAT-36) re-implements the 13-card label scan as a second, independent
scanner, and `reruns/pointers.md` + `pointer-sweep.sh` (SEAT-37) re-run the pointer sweep. The
r101 artifacts are cited **as the subject under test**, which is why they must stay byte-frozen —
and they did (§1). **[O]**

One r101 file is re-authored rather than re-measured: `reports/round-102/kimi-surfaces.md`
(16956 B) is a shorter, independent r102 pass at the same topic as
`reports/round-101/probes/kimi-surfaces.md` (37191 B). Not a copy — different bytes, 54% the size.
Recorded because it is the only r101↔r102 basename collision (§4.1). **[O]**

---

## 6. What this seat did not do

- Did not modify, stage, commit, rename, or delete anything. `git status` shows only the untracked
  `reports/round-102/` and other seats' declared repairs.
- Did not audit `corpus/knowledge/unreal-mcp/` (the r101 byte-pinned subtree) or any file outside
  `reports/`. Its byte-stability is claimed by other seats' `reruns/` reports and was **not**
  independently re-derived here.
- Did not verify the content claims of any r102 report — including C1/C2 and the F1–F8 repairs.
  This audit covers **presence, naming, provenance, duplication, and r101 immutability only**.
- Did not wait for the directory to stop growing. §2's last frame and §8's closing frame are both
  snapshots of a live directory, and §8.2 shows the count moving **down** between frames — the
  round-close scribe must re-run §9's commands rather than quote them. **[O]**
- Withdrew one finding (§4.2) rather than leaving a false positive standing. The withdrawal is
  stated where the finding was raised, not deleted.

---

## 7. Recommendations to the L1 (advisory only — no axis claim)

1. **Snapshot before landing.** Across this seat's window the directory went **3 → 57 files** and
   was still climbing; `git add -A reports/round-102/` taken now commits an arbitrary mid-edit
   revision. Wait for quiescence, then freeze. **[I]**
2. **Record the layout as a convention, or rename before landing.** Five round-level subdirs and
   **20 of 27** off-pattern top-level names are a real departure from the `rNN-<seat>.md` form that
   31 of 35 rounds use. Renaming *after* landing breaks citations; renaming *before* is cheap. If
   the role-grouped layout is intended to stay, say so in the round report so the next scribe
   measures against the right baseline. **[I]**
3. **Resolve the new basename collisions by explanation, not deletion.**
   `before/{F3-sha-drift,F6-rea-census}.md` vs their `repairs/` namesakes is the intended defect-id
   reuse and should be left as is; `kimi-surfaces.md` (r101 probe vs r102 re-run) should be flagged
   in the r102 index so a filename-only grep does not read the shorter file as the r101 one. **[I]**
4. **Re-measure §5.2 at close.** One exact-path citation of r102 from outside the round is a low
   number; if it is still one at close, the r102 evidence set is not wired into the corpus. **[I]**
5. **The `before/`↔`repairs/` reuse is a feature worth naming.** It made the round's defect lattice
   readable (`before/F3` ↔ `repairs/F3` ↔ `adversary/F3`), and the collision it creates is
   predictable rather than accidental. If the layout stays, a one-line note in the round README
   turns a grep surprise into a documented convention. **[I]**

---

## 8. Closing frames — after this file was written

This seat's own artifact landed at `14:46` (`r102-scribe-audit.md`, 21222 B, sha256
`aba26713c16a1ff3…`) and became the **sixth** `r102-<seat>.md` file. Appending this section then
changed that file's own digest, so the digest just quoted is a **landing-frame** observation, not
the current value — by this document's own rule (§2), read the digest from disk, not from this
text.

### 8.1 Frame `2026-10-18T14:46:26-03:00` (49 files)

The directory reached **49 files**, against **47** at §2's last frame — it was still growing after
this seat stopped auditing, exactly as §2 predicts. **[O]**

```
$ find reports/round-102 -type f | wc -l
49
$ find reports/round-102 -maxdepth 1 -type f -name 'r102-*' | sort
r102-boundary-scout.md  r102-connector.md  r102-distiller.md
r102-report.md          r102-scribe-audit.md  r102-verification-protocol.md
$ find reports/round-102 -maxdepth 1 -type f ! -name 'r102-*' | wc -l
15
```

The `r102-*` ratio moved from **5 of 19** top-level files (`14:46:01`) to **6 of 21**
(`14:46:26`) in ~25 seconds — consistent with §3.2's "adopting late and partially" reading and
with the count rising further after this seat stopped. **[O]**

### 8.2 The count goes **down** — `14:47:08` (53) → `14:47:14` (52)

```
14:46:55   50   r102-*=6
14:47:08   53   r102-*=6
14:47:14   52   r102-*=6     ← one fewer than six seconds earlier
14:47:21   53
14:47:27   54
14:47:46   54   (stable ~20 s)
14:48:26   55   (stable ~35 s)
14:49:01   56
14:49:06   57
14:49:31   57   r102-*=7  off-pattern=20
```

**This is not a monotone growth series.** Seats rename and replace files concurrently, and a
single `wc -l` sample cannot distinguish a new file from a rename that momentarily presents both
names. That is the same trap that produced the withdrawn §4.2 finding, and it is why every
structural claim in this document rests on a re-sample rather than one frame. **[O]**

### 8.3 Closing frame `2026-10-18T14:49:46-03:00` (57 files) — all structural claims re-verified

| claim | frame | value |
|---|---|---|
| basename dups lane-wide | `14:49:46` | `F3-sha-drift.md`, `F6-rea-census.md`, `kimi-surfaces.md`, `navagent-dissection.md` |
| byte-identical report pairs, lane-wide | `14:49:46` | **none** (§4.2 withdrawal holds) |
| round-level subdirs | `14:49:46` | `round-101/probes`, `round-102/{adversary,before,gate,repairs,reruns}`, `round-1-20261015/before` |
| exact-path r102 citations from outside r102 | `14:49:46` | **1** (`corpus/knowledge/rea.md:34`) |
| r101 tracked files / dirty / diff / blobs≠HEAD | `14:49:54` | `33` / `0` / `0` / `0` |

The basename-duplicate set **grew** during the audit (`F6-rea-census.md` alone → adding
`F3-sha-drift.md`), which strengthens §4.1's reading rather than contradicting it: both are the
intended `before/`↔`repairs/` defect-id reuse, and F3's repair simply landed later. The
`r102-*` count stayed at 6 while off-pattern went 15 → 20, confirming §3.2's reading (a).

**This is the last frame in this document, and the directory was still growing when it was
taken.** The round-close scribe must re-run §9's commands, not quote them. **[O]**
seconds earlier. So this is not a monotone growth series: seats are renaming and replacing files
concurrently, and a single `wc -l` sample cannot distinguish a new file from a rename that
temporarily presents both names. This is the same trap that produced the withdrawn §4.2 finding,
and it is why every structural claim in this document rests on a re-sample rather than one frame.

**This is the last frame in this document.** The round-close scribe must re-run §9's commands,
not quote them. **[O]**

---

## 9. Reproducing this audit

```
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
git rev-parse HEAD                                   # expect 2c99b7b…
git status --porcelain reports/round-101             # expect empty
git diff --name-only HEAD -- reports/round-101       # expect empty
git ls-files reports/round-101 | wc -l               # expect 33
find reports/round-102 -type f | sort | wc -l        # 3 → 57 during this seat, still growing
find reports/round-102 -mindepth 1 -type d -printf '%P\n' | sort
find reports/round-102 -maxdepth 1 -type f -name 'r102-*' | sort
find reports/round-102 -maxdepth 1 -type f ! -name 'r102-*' | wc -l
find reports/round-102 -type f -printf '%f\n' | sort | uniq -d
find reports -type f -printf '%f\n' | sort | uniq -d
find reports -type f -exec sha256sum {} \; | awk '{print $1}' | sort | uniq -d
for f in $(find reports/round-102 -type f); do grep -q "SEAT-[0-9]" "$f" || echo "no seat: $f"; done
grep -rn "reports/round-102" --include='*.md' --include='*.sh' . | grep -v '^./reports/round-102/'
```

The file count is the one number that will **not** reproduce (§2, §8.2), and it can move
**downward** as well as up. Every count in this report is stamped with the time it was observed.
**[O]**

---

No Unreal runtime claim is made anywhere in this document. The Unreal Editor and UnrealBuildTool
are not installed on this host; the r101 subtree this round re-measures is treated as file bytes
only, and nothing here proves plugin load, compilation, or engine runtime behaviour.
