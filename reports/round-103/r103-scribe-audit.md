# r103 scribe-audit — custody audit of `reports/round-103/`

Seat: **SEAT-42 SCRIBE-AUDIT**. Lane: `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`.
Scope: inventory `reports/round-103/` at this seat's runtime — file count, naming-convention
compliance against the r102 subdir convention, growth frames if live — and verify that
`reports/round-101/` and `reports/round-102/` stayed untouched.

**Read-only.** This seat wrote nothing but this file, edited no cited artifact, and ran no
`git` state-mutating command.

Lane HEAD throughout: `c85a816e227984272a3c29b58aa7f7c1a76f1e9c`
(*"r102 report-last: verdict (coverage/depth improved, calibration unchanged), LOG + SCORECARD,
gate-hardening + battery-boundary addendum — work c6f655d"*).

Tags: **[O]** command-run observation · **[I]** labelled inference · **[?]** unknown.

**Status: AUDIT COMPLETE, and the subject never stopped moving.** `reports/round-103/` grew
**1 → 49 files** during this seat's window (`2026-10-18T15:31:34-03:00` →
`2026-10-18T15:40:21-03:00`, ~8.8 min) and was **still growing when the last frame was taken**.
The count is a series, not a number; §2 is the growth series and §8 the closing frames. Every
count below carries the time it was observed. **§8.3 is a dated correction that withdraws one
claim §8.2 made** — read it before quoting §8.2. **§8.7 is the latest measured state**; five
successive "final" frames in §8 were each overtaken. **§1.1 records a protected-path edit this
seat observed but did not make.**

---

## 0. Method (exact commands, all read-only)

```
date -Iseconds                                    # every frame is stamped
find reports/round-103 -type f -printf '%P|%s\n' | sort
find reports/round-103 -type f -printf '%f\n' | sort | uniq -d          # intra-round collisions
find reports/round-103 -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort
find reports/round-103 -maxdepth 1 -type f -name 'r103-*' | sort
find reports/round-103 -maxdepth 1 -type f ! -name 'r103-*' | sort
find reports -type f -printf '%f\n' | sort | uniq -d                    # lane-wide collisions
find reports -type f -exec sha256sum {} \; | awk '{print $1}' | sort | uniq -d   # byte dups
for f in $(find reports/round-103 -type f); do grep -q "SEAT-[0-9]" "$f" || echo "NO-SEAT: $f"; done
grep -rn "reports/round-103" --include='*.md' --include='*.sh' . | grep -v '^./reports/round-103/'
git rev-parse HEAD
git status --porcelain
git status --porcelain reports/round-101 reports/round-102
git diff --name-only HEAD -- reports/round-101 reports/round-102
git ls-files reports/round-101 | wc -l
```

Growth series (60 frames at 5 s cadence, `n` / `rNN` / `subdirs`):

```
while :; do printf '%s\t%s\t%s\t%s\n' "$(date -Iseconds)" \
  "$(find reports/round-103 -type f | wc -l)" \
  "$(find reports/round-103 -maxdepth 1 -type f -name 'r103-*' | wc -l)" \
  "$(find reports/round-103 -mindepth 1 -maxdepth 1 -type d | wc -l)"; sleep 5; done
```

---

## 1. r101 and r102 are untouched — the discipline check **[O]**

Re-verified at three points in the window (open, middle, close). All three agree.

```
$ git status --porcelain reports/round-101 reports/round-102 | wc -l
0
$ git diff --name-only HEAD -- reports/round-101 reports/round-102 | wc -l
0
$ git ls-files reports/round-101 | wc -l
33
```

No r101 or r102 file was added, deleted, renamed, or rewritten by any r103 seat. Note that
`reports/round-102/` is **still being read and cited** by r103 seats — `note/gate-pin.md`,
`gate/docs-sync.md` and `gate/exit-codes.md` all measure the r102 gate — but reading is not
writing, and the tree is clean. **[O]**

Repo-wide working tree at the closing frame **[O]**:

```
$ git status --porcelain                                    # @15:39:56
 M corpus/artifacts/glb-r12/README.md
 M corpus/artifacts/unity-r19/README.md
 M corpus/fixtures/three/README.md
 M corpus/knowledge/unreal-mcp/adaptation-kimi.md
 M corpus/knowledge/unreal-mcp/gate/README.md
 M corpus/knowledge/unreal-mcp/gate/run_gate.sh
?? reports/round-103/
```

Every modification is outside `reports/` and belongs to a declared r103 path (the C3 dead-root
repairs, the C1 freshness note, the C2 gate hardening). `reports/round-103/` is the only untracked
report directory and is **not** gitignored (`git check-ignore -v reports/round-103/ledger-check.md`
→ rc=1), so it is tracked-visible for the round-close commit. **[O]**

### 1.1 A protected path was modified mid-round — `corpus/fixtures/three/README.md` **[O]**

The lane brief for this round names `corpus/fixtures/**` as a **byte-pinned / protected** path.
At `15:39:56` it is **dirty**:

```
$ git status --porcelain corpus/fixtures
 M corpus/fixtures/three/README.md
$ git diff --stat -- corpus/fixtures/three/README.md
 corpus/fixtures/three/README.md | 34 +++++++++++++++++-----------------
 1 file changed, 17 insertions(+), 17 deletions(-)
$ stat -c '%y' corpus/fixtures/three/README.md
2026-10-18 15:35:34.878809345 -0300
```

The diff is a **pure re-rooting of command paths** — every `.shokunin/game-dev-3d/` prefix is
stripped from the runnable commands (17 insertions / 17 deletions, no other content change):

```
-npm ci --prefix .shokunin/game-dev-3d/corpus/fixtures/three
-node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs
+node corpus/fixtures/three/run_cases.mjs
```

This is the **same B2 dead-root defect class** the round's C3 claim targets (`.shokunin/game-dev-3d/`
is a dead root — see `reports/round-102` B2), and the repair is materially correct for a runnable
README: the commands now match the lane's actual layout. **But the file sits inside a tree the
round brief lists as protected**, and this seat did not write it — it was written at `15:35:34` by
a seat whose report this audit did not identify. Recorded as a **custody observation, not an
accusation**: the modification may be authorized by the C3 seat's own brief (the C3 claim names
`three` among the dead-root READMEs to repair). What this seat can state is the fact and the
mtime; what it cannot state is whether `corpus/fixtures/**` protection was meant to cover README
text or only fixture bytes. **[O]**/**[?]**

The round-close scribe should resolve this before landing: either the C3 seat's brief authorized
this exact file (then the protection list and the brief are in tension and one of them should be
corrected), or it did not (then this is an unauthorized write into a protected tree and must be
reverted with a dated correction note). This seat took no action on the file either way. **[I]**

Also note: `corpus/knowledge/unreal-mcp/gate/run_gate.sh` is modified — that is the C2 gate
hardening this seat's own lane brief describes, and it is **not** on the protected list (only
`corpus/knowledge/unreal-mcp/upstream/**` and `.manifest.d/**` are). Consistent. **[O]**

---

## 2. The file count is a moving target — growth series **[O]**

60 frames, same command, each stamped with the time it was taken. All times `-03:00`. Frames
where the value changed are listed; flat stretches are collapsed.

| time | files | `r103-*` | subdirs | what appeared |
|---|---|---|---|---|
| 15:31:34 | 1 | 0 | 2 | `gate/clean.raw.txt` — the first frame |
| 15:31:39 | 1 | 0 | 2 | (flat) |
| 15:31:44 | 2 | 0 | 2 | `ledger-check.md` |
| 15:32:04 | 3 | 0 | 2 | `note/urls.md` |
| 15:32:09 | 4 | 0 | 2 | `note/configline.md` |
| 15:32:34 | 5 | 0 | 2 | `seats-ledger.md` |
| 15:32:39 | 8 | 0 | 2 | `freshness-pin.md`, `subtree-integrity.md`, `install-recheck.md` |
| 15:32:44 | 9 | 0 | 2 | `note/binary.md` |
| 15:33:04 | 9 | 0 | **3** | **`b2/` subdir created** (first file lands at 15:33:38) |
| 15:33:19 | 10 | 0 | 3 | `gate/a4-attack.md` |
| 15:33:29 | 13 | 0 | 3 | `gate/clean.now.txt`, `b2/adversary.md` |
| 15:33:59 | 16 | 0 | 3 | `gate/final-run.md`, `note/author.md`, `gate/clean.md` |
| 15:34:09 | 18 | 0 | 3 | `gate/mutations.md`, `note/rows.md` |
| 15:34:14 | 20 | 0 | 3 | `gate/a3-attack.md`, `b2/verify-unity.md` |
| 15:34:24 | 22 | 0 | 3 | `gate/docs-sync.md`, `note/gate-pin.md` |
| 15:34:35 | 23 | 0 | 3 | `gate/exit-codes.md` |
| 15:34:40 | 24 | 0 | 3 | `b2/repair-glb.md` |
| 15:34:45–15:35:00 | 24 | 0 | 3 | (flat ~15 s) |
| 15:35:05 | 26 | **1** | 3 | **first `r103-*` file**: `r103-distiller.md`; + `note/verify.md` |
| 15:35:10 | 28 | 1 | 3 | `skill-table-review.md`, `note/adversary.md` |
| 15:35:15 | 29 | 1 | 3 | `gate/a2-attack.md` |
| 15:35:25 | 30 | 1 | 3 | `note/crosscheck.md` |
| 15:36:00 | 30 | 1 | 3 | `pathroot-sweep.md` (rewrite window; count flat) |
| 15:36:05 | 30 | 1 | 3 | `r103-distiller.md` rewritten (22093 → 23871 B) |
| 15:36:25 | 31 | 1 | 3 | one further file |

Growth: **1 → 36 files, ~36×**, roughly one file every 5–10 seconds at the observed rate. The
table above stops at `15:36:25` (31 files) because the audit proper ended there; §8 carries the
frames after it, out to 36 files at `15:37:14`. The directory was **still growing at every
frame**; the true final state is not recorded here by construction, and this seat did not wait
for quiescence. **[O]**

The `r103-*` form was **absent for the first 3.5 minutes** (24 files, 0 matches) and the first
instance arrived at `15:35:05`, 3 min 31 s into the window — the same late-and-partial adoption
r102 showed (`reports/round-102/r102-scribe-audit.md` §3.2). **[O]**

---

## 3. Naming-convention compliance vs the r102 subdir convention **[O]**

### 3.1 The three rounds side by side

```
$ for d in round-101 round-102 round-103; do printf '%-12s top=%-3s rNN=%-3s off=%-3s subdirs=%-2s total=%-3s\n' "$d" \
    "$(find reports/$d -maxdepth 1 -type f|wc -l)" \
    "$(find reports/$d -maxdepth 1 -type f -name 'r[0-9]*-*'|wc -l)" \
    "$(find reports/$d -maxdepth 1 -type f ! -name 'r[0-9]*-*'|wc -l)" \
    "$(find reports/$d -mindepth 1 -maxdepth 1 -type d|wc -l)" \
    "$(find reports/$d -type f|wc -l)"; done
```

| round | top-level files | `rNN-*` | off-pattern | round-level subdirs | total |
|---|---|---|---|---|---|
| **round-101** | 17 | 15 | 2 | 1 (`probes/`) | 33 |
| **round-102** | 29 | 8 | 21 | 5 | 61 |
| **round-103** @15:36:30 | **8** | **1** | **7** | **3** | **31** |
| **round-103** @15:37:14 | **9** | **2** | **7** | **4** | **36** |

Lane-wide, `rNN-*.md` is the standing form: **31 of 36** round directories use it for every
top-level file. The exceptions are `round-101` (2 off), `round-102` (21 off), `round-103`
(7 off), `round-1-20261015` (2), `round-86` (2). **[O]**

### 3.2 Verdict: r103 **inherits** the r102 subdir layout, partially, and repeats its late `rNN-*` adoption

At the frame `15:39:07` r103 has **3 of 14** top-level files in the `r103-*` form
(`r103-distiller.md`, `r103-report.md`, `r103-scribe-audit.md` — this file); the other 11 are
topic slugs. The ratio was **0 of 5** at `15:32`, **1 of 8** at `15:36:30`, **2 of 9** at
`15:37:14`, **3 of 14** at `15:39:07` — the form is adopted progressively as the round's long
close-out artifacts land, exactly as r102's frames showed. **[O]**

Six of those off-pattern names (`freshness-pin.md`, `install-recheck.md`, `ledger-check.md`,
`skill-table-review.md`, `git-hygiene.md`, `math-audit.md`) are **the same topic slugs r102 used
at top level**, which is what creates §4.1's new lane-wide collisions. So the off-pattern names
are not arbitrary: r103 is re-running r102's seats and reusing their slugs. **[O]**/**[I]**

### 3.3 Subdirectories: partial adoption, three new role names

```
$ echo "r102: $(find reports/round-102 -mindepth 1 -maxdepth 1 -type d -printf '%f ')"
r102: repairs before reruns gate adversary
$ echo "r103: $(find reports/round-103 -mindepth 1 -maxdepth 1 -type d -printf '%f ')"
r103: gate note b2
```

| subdir | r102 | r103 | role |
|---|---|---|---|
| `gate/` | ✅ 9 files | ✅ 10 files | gate execution receipts — **the one carried-over role name** |
| `before/` | ✅ 6 | — | pre-repair captures (not used this round) |
| `repairs/` | ✅ 6 | — | post-repair captures (not used; repairs land at top level as `pathroot-sweep.md`) |
| `reruns/` | ✅ 5 | — | independent re-executions (not used) |
| `adversary/` | ✅ 5 | — | adversarial findings (r103 uses `note/adversary.md` + `b2/adversary.md` instead) |
| `note/` | — | ✅ 9 | **new** — the C1 freshness-note evidence set |
| `b2/` | — | ✅ 7 | **new** — the B2 dead-root investigation |
| `physics/` | — | ✅ 1 | **new** — the C3 battery-row investigation (landed `~15:37:12`, see §8.3) |

**Reading:** r103 did **not** adopt r102's five-subdir convention; it adopted **one** of them
(`gate/`) and invented **three** new role names (`note/`, `b2/`, `physics/`). The r102 audit
recommended "record the layout as a convention, or rename before landing"
(`r102-scribe-audit.md` §7.2), and `reports-index.md` §2.3 judged the five names "a new
convention … acceptable and self-documenting". r103 is the first test of whether that
convention propagates, and the answer from the frames is **partially**: the *idea* of
role-grouped subdirs propagated, the *specific five names* did not. **[O]**/**[I]**

The subdir count is itself a moving number: **2 → 3 → 4** across this seat's window
(`b2/` at `15:33:04`, `physics/` at `~15:37:12`). §3.3's verdict is stated against the closing
frame in §8.4; the intermediate frame in §8.2 asserted that no further subdir would appear and
was **falsified** (§8.3). Read the verdict, not the intermediate claim. **[O]**

This is not necessarily a defect — `note/`, `b2/` and `physics/` are self-documenting for this
round's three non-gate claims, and a round that makes different claims may legitimately need
different buckets. But it means **there is no stable subdir vocabulary yet**: a cross-round grep
must now know that r102 keeps reruns in `reruns/` and r103 keeps them at top level. Recorded, not
flagged. **[I]**

---

## 4. Duplication flags

### 4.1 Lane-wide basename collisions grew **4 → 9 → 11 → 12** **[O]**

At the `15:36:30` frame the set was **9**; by `15:38:08` it was **11**; by `15:38:28` it was
**12**, as r103 top-level and `gate/` files landed reusing r102 slugs:

```
$ find reports -type f -printf '%f\n' | sort | uniq -d          # @15:38:28
adversary.md
F3-sha-drift.md
F6-rea-census.md
freshness-pin.md
git-hygiene.md
install-recheck.md
kimi-surfaces.md
ledger-check.md
math-audit.md
navagent-dissection.md
sentinel.md
skill-table-review.md
```

| collision | new in | paths | reading |
|---|---|---|---|
| `F3-sha-drift.md` | r102 | `round-102/before/` vs `round-102/repairs/` | intended defect-id reuse (r102 §4.1) |
| `F6-rea-census.md` | r102 | `round-102/before/` vs `round-102/repairs/` | intended defect-id reuse |
| `navagent-dissection.md` | pre-r102 | r101 vs `reports/frontier/` | documented in `r101-scribe-audit.md` §F3 |
| `kimi-surfaces.md` | r102 | `round-101/probes/` vs `round-102/` | r102 re-ran the r101 probe |
| **`freshness-pin.md`** | **r103** | `round-102/` vs `round-103/` | **new** — r103 re-ran the r102 pin check |
| **`install-recheck.md`** | **r103** | `round-102/` vs `round-103/` | **new** — re-run of the same check |
| **`ledger-check.md`** | **r103** | `round-102/` vs `round-103/` | **new** — re-run of the same check |
| **`skill-table-review.md`** | **r103** | `round-102/` vs `round-103/` | **new** — re-run of the same review |
| **`git-hygiene.md`** | **r103** | `round-102/` vs `round-103/` | **new** — re-run of the same hygiene check |
| **`math-audit.md`** | **r103** | `round-102/` vs `round-103/` | **new** — re-run of the same audit |
| **`sentinel.md`** | **r103** | `round-102/gate/` vs `round-103/gate/` | **new** — a `gate/`-scoped pair; same subdir name, different round |
| **`adversary.md`** | **r103** | `round-103/note/` vs `round-103/b2/` | **new, intra-round** — see §4.2 |

The **seven** r102↔r103 collisions share one shape: a seat re-runs an r102 seat's check and keeps
the same topic slug. Six are top-level slug reuse; `sentinel.md` is the same slug inside the same
subdir name (`gate/`) in two different rounds, which is the collision the role-grouped layout makes
most likely. Byte comparison confirms none are copies:

```
$ for n in freshness-pin.md install-recheck.md ledger-check.md skill-table-review.md git-hygiene.md math-audit.md sentinel.md; do
    find reports -name "$n" -printf '  %p %s\n'; done
  reports/round-102/freshness-pin.md 6504
  reports/round-103/freshness-pin.md 7299
  reports/round-102/install-recheck.md 10248
  reports/round-103/install-recheck.md 15405
  reports/round-102/ledger-check.md 11651
  reports/round-103/ledger-check.md 3778
  reports/round-102/skill-table-review.md 23987
  reports/round-103/skill-table-review.md 26971
  reports/round-102/git-hygiene.md 5884
  reports/round-103/git-hygiene.md 29578
  reports/round-102/math-audit.md 36648
  reports/round-103/math-audit.md 50544
  reports/round-102/gate/sentinel.md 27314
  reports/round-103/gate/sentinel.md 25238
```

All six pairs differ in size. Note that `ledger-check.md` is the one pair where the r103 file is
*smaller* (3778 vs 11651) — r103's ledger check is narrower (it checks three ledger files plus
the two prior round dirs) than r102's, which carried a full per-seat table. **[O]**

### 4.2 Intra-round collision: `adversary.md` in `note/` and `b2/` **[O]**

```
$ find reports/round-103 -type f -printf '%f\n' | sort | uniq -d
adversary.md
$ find reports/round-103 -name 'adversary.md' -printf '  %p %s\n'
  reports/round-103/note/adversary.md 21680
  reports/round-103/b2/adversary.md 16886
```

This is the **r102 `before/`↔`repairs/` shape repeated in a different pair of namespaces**: the
same role-word (`adversary`) used as a filename in two subdirs, with different bytes and
different subjects (the `note/` file challenges the C1 freshness note; the `b2/` file
challenges the B2 ruling). Unlike r102's pair, the two files here do **not** share a defect id —
they share a *role name*. A reader grepping `**/adversary.md` gets two hits with no round or
subdir context in the name. **[O]**/**[I]**

### 4.3 No byte-identical duplicate anywhere under `reports/` **[O]**

```
$ find reports -type f -exec sha256sum {} \; | awk '{print $1}' | sort | uniq -d
(no output)
```

Sampled repeatedly across the window; the set stayed empty. As the r102 audit established
(§4.2 there), a single `find`+`sha256sum` sample cannot distinguish a real duplicate from a seat
mid-rename, so this claim rests on re-sampling, which it has. **[O]**

---

## 5. Other runtime observations

### 5.1 Seat recoverability **[O]**

Mapping at the closing frame (`15:36:30`, 30 files). **28 of 30** files carried a `SEAT-NN`
marker; the 2 exceptions were raw gate captures:

```
$ with=0; without=0; for f in $(find reports/round-103 -type f); do
    if grep -q "SEAT-[0-9]" "$f" 2>/dev/null; then with=$((with+1)); else without=$((without+1)); fi; done
with=28 without=2
```

At the later frame `15:37:36` (36 files) the same check gives **34 of 36** — the two raw gate
captures remain the only marker-less files, so the ratio *improved* as the round landed:

```
$ with=34 without=2
```

| subdir | files → seats |
|---|---|
| `gate/` (10) | `a2-attack`→SEAT-12 · `a3-attack`→SEAT-13 · `a4-attack`→SEAT-14 · `clean`→SEAT-10 · `clean.now.txt`→**NONE** · `clean.raw.txt`→**NONE** · `docs-sync`→SEAT-20 · `exit-codes`→SEAT-61 · `final-run`→SEAT-53 · `mutations`→SEAT-19 |
| `note/` (9) | `adversary`→SEAT-04 · `author`→SEAT-01 · `binary`→SEAT-06 · `configline`→SEAT-60 · `crosscheck`→SEAT-08 · `gate-pin`→SEAT-05 · `rows`→SEAT-02 · `urls`→SEAT-07 · `verify`→SEAT-03 |
| `b2/` (7) | `adversary`→SEAT-30 · `postgrep`→SEAT-31 · `repair-glb`→SEAT-23 · `repair-three`→SEAT-25 · `scanner`→SEAT-21 · `verify-three`→SEAT-28 · `verify-unity`→SEAT-27 |
| `physics/` (1) | `investigate`→SEAT-32 |
| top level (9) | `freshness-pin`→SEAT-56 · `install-recheck`→SEAT-57 · `ledger-check`→SEAT-39 · `pathroot-sweep`→SEAT-58 · `r103-distiller`→SEAT-36 · `r103-scribe-audit`→**this file** · `seats-ledger`→SEAT-55 · `skill-table-review`→SEAT-59 · `subtree-integrity`→SEAT-54 |

Seat ids observed span **SEAT-01 … SEAT-61** (34 distinct at `15:37:36`). Only the two raw gate
captures carry no seat marker. Two subdirs are **contiguous seat blocks**: `note/` is
**SEAT-01…SEAT-08** (the C1 evidence set, minted as one batch) and `b2/` is **SEAT-21…SEAT-31**
(the B2 investigation). The C1 and B2 seats were dispatched as contiguous waves; the `gate/`
seats are scattered (SEAT-10, 12, 13, 14, 19, 20, 53, 61), consistent with gate work being
routed to whichever seat owned the relevant attack. **[O]**/**[I]**

### 5.2 r103 is cited from outside itself — 5 → 4 exact-path citations **[O]**

At the `15:37:14` frame there were **five** exact-path citations of r103 from outside
`reports/round-103/`:

```
$ grep -rn "reports/round-103" --include='*.md' --include='*.sh' . | grep -v '^./reports/round-103/'   # @15:37:14
./corpus/knowledge/unreal-mcp/adaptation-kimi.md:372:in `reports/round-103/note/author.md`.
./corpus/knowledge/unreal-mcp/adaptation-kimi.md:506:same conclusion: `reports/round-103/note/urls.md` §4 (SEAT-07).
./corpus/knowledge/unreal-mcp/gate/README.md:225:(`reports/round-103/note/author.md`, `…/urls.md`), and this seat's own correction note added one
./corpus/knowledge/unreal-mcp/gate/README.md:226:more (`reports/round-103/note/gate-pin.md`).
./corpus/knowledge/unreal-mcp/gate/README.md:233:`reports/round-103/note/gate-pin.md`.
```

By `15:40:37` it was **four** — a peer seat rewrote `gate/README.md`'s correction-note paragraph
mid-audit, replacing three `note/` citations with two different ones:

```
$ grep -rn "reports/round-103" --include='*.md' --include='*.sh' . | grep -v '^./reports/round-103/'   # @15:40:37
./corpus/knowledge/unreal-mcp/adaptation-kimi.md:372:in `reports/round-103/note/author.md`.
./corpus/knowledge/unreal-mcp/adaptation-kimi.md:506:same conclusion: `reports/round-103/note/urls.md` §4 (SEAT-07).
./corpus/knowledge/unreal-mcp/gate/README.md:214:`reports/round-103/gate/exit-codes.md`; the fix is a future-round decision, not silently applied
./corpus/knowledge/unreal-mcp/gate/README.md:298:off-by-one proof are in `reports/round-103/note/gate-pin.md`.
```

Either way it is **4–5**, against **one** for r102 at its own scribe audit
(`r102-scribe-audit.md` §5.2). The r103 evidence set is wired into the corpus while the round is
still landing — the opposite of r102's near-orphaned state. Note that the citations now include
**`gate/exit-codes.md`**, a `gate/`-scoped r103 file, so the wiring is no longer `note/`-only.
**[O]**/**[I]**

Note the asymmetry: `gate/README.md` cites r103 files to support its own correction-note count,
i.e. r103 is being used as evidence *by the artifact it audits*. That is a legitimate use but it
means the citation direction is not purely corpus→round. **[O]**

**This count is moving, and it moved in this seat's own window.** Any scribe quoting a citation
number must re-run the grep. **[O]**

### 5.3 r103 does not re-derive r102; it re-runs it **[O]**

Six of r103's top-level files (`freshness-pin.md`, `install-recheck.md`, `ledger-check.md`,
`skill-table-review.md`, `git-hygiene.md`, `math-audit.md`) carry the **same topic slugs** as r102
files (§4.1) and are the seats re-running r102's checks under r103's claims. `gate/clean.now.txt`
(POINTERS=90) and `gate/clean.raw.txt` (POINTERS=88) are two gate receipts from the same round,
and the difference is real:

```
$ diff reports/round-103/gate/clean.raw.txt reports/round-103/gate/clean.now.txt
50c50
< POINTERS=88 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
---
> POINTERS=90 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
54d53
< RC=0
```

Both show `UNRESOLVED=0` and `STEP=PASS` on every check. The pointer count moved 88 → 90 between
the two runs, which is the **scanner-relative** property r102's L1 recorded as load-bearing
(`r102-report.md` close-out: "pointer counts are scanner-relative … the binding invariant is
`UNRESOLVED=0`"). This seat does **not** adjudicate which number is correct; it records that the
same invariant held in both receipts. **[O]**/**[I]**

### 5.4 An internal inconsistency in the r102 report, carried into the lane **[O]**

The r102 report states its own directory size three times with three different values, and one
of them is not timestamped:

```
$ grep -n "52\|58" reports/round-102/r102-report.md | grep -i "file\|artifact\|final frame"
107:| `reports/round-102/**` | 52 evidence artifacts across 6 subdirectories at the final frame **[moving]** | ...
254:| round-102 report files | ... | **52** at the final frame `17:47:07Z` **[moving]** — was 46 at ...
415:**58** at the final frame; ...
```

Measured now:

```
$ find reports/round-102 -type f | wc -l
61
$ find reports/round-102 -mindepth 1 -maxdepth 1 -type d | wc -l
5
```

So the actual directory is **61 files / 5 subdirs**, while `r102-report.md:107` says **52** files
and **6** subdirectories. `reports-index.md:76` independently says **5** subdirs. The `6` in
`:107` is simply **wrong** (no sixth round-level subdir exists at any frame this seat observed);
the `52` is a stale `17:47:07Z` snapshot presented in the `:107` row **without** the timestamp
that `:254` gives it. `:415`'s **58** is a third value from an untimestamped later frame. All
three are labelled **[moving]**, which is honest, but the `6` is a counting error, not drift —
drift cannot change a directory count that never moved. **[O]**

This matters for the r103 scribe because `r102-report.md:107` is the row a reader would quote as
"the r102 report set size". Routed below as a recommendation, **not** repaired: the r102 report
is byte-pinned by this round's rules and this seat will not rewrite a historical claim.

---

## 6. What this seat did not do

- Did not modify, stage, commit, rename, or delete anything. `git status` shows only the
  untracked `reports/round-103/` and other seats' declared corpus edits — including the
  protected-path edit recorded in §1.1, which this seat **observed and reported but did not touch**.
- Did not verify the content claims of any r103 report — including C1, C2, C3 and the B2 repair.
  This audit covers **presence, naming, provenance, duplication, r101/r102 immutability, and the
  protected-path check in §1.1 only**.
- Did not adjudicate the `POINTERS=88` vs `90` difference (§5.3) or the r102 report's `52/58/61`
  and `5/6` counts (§5.4); both are recorded, neither is resolved.
- Did not resolve whether `corpus/fixtures/three/README.md`'s edit was authorized (§1.1) — this
  seat has no access to the C3 seat's brief, only to the round brief's protection list.
- Did not audit `corpus/knowledge/unreal-mcp/` or any file outside `reports/`.
- Did not wait for the directory to stop growing. §2's last frame and §8 are both snapshots of a
  live directory; the round-close scribe must re-run §9's commands rather than quote them.

---

## 7. Recommendations to the L1 (advisory only — no axis claim)

1. **Resolve the protected-path edit in §1.1 before landing.** `corpus/fixtures/three/README.md`
   is dirty at `15:35:34` and sits inside the round's protected list. Either the C3 seat's brief
   authorized it (then fix the protection list or the brief) or it did not (then revert it with a
   dated correction note). This is the only custody question this audit could not close. **[I]**
2. **The subdir vocabulary has not stabilised.** r103 adopted `gate/` from r102 and invented
   `note/`, `b2/` and `physics/`; four of r102's five role names were not reused. Before r104,
   decide whether the role names are a fixed vocabulary (then say so, and use them) or a
   per-round free choice (then say that, and stop treating `reports-index.md` §2.3 as a
   convention). **[I]**
3. **Fix the `6` in `r102-report.md:107` at r102's next permitted touch.** It is a counting error,
   not drift — the round-level subdir count was 5 at every frame this seat observed and
   `reports-index.md:76` agrees. Attaching `:254`'s `17:47:07Z` timestamp to the `52` would also
   remove the untimestamped duplicate. **[I]**
4. **Snapshot before landing.** The directory went **1 → 48 files** in ~8 minutes and was still
   climbing; `git add -A reports/round-103/` taken now commits an arbitrary mid-edit revision.
   Wait for quiescence. **[I]**
5. **Flag the new collisions in the round index, do not delete files.**
   `note/adversary.md` vs `b2/adversary.md` is a role-name reuse inside one round; the seven
   r102↔r103 pairs (§4.1) are re-runs. Both are benign once named. **[I]**
6. **The r103 evidence set is already corpus-wired** (4–5 outside citations, §5.2) — unlike r102
   at the same stage. Worth preserving at close rather than renaming, since the citations are from
   `adaptation-kimi.md` and `gate/README.md`, i.e. tracked artifacts. **[I]**

---

## 8. Closing frames — after this file was written

This seat's own artifact lands as `reports/round-103/r103-scribe-audit.md`, the **second**
`r103-<seat>.md` file. By this document's own rule (§2), read any digest from disk, not from
this text.

### 8.1 Frame `2026-10-18T15:36:30-03:00` (31 files) — structural claims re-verified

| claim | frame | value |
|---|---|---|
| total files | `15:36:30` | **31** (was 1 at `15:31:34`) |
| top-level / `r103-*` / off-pattern | `15:36:30` | `8` / `1` / `7` |
| round-level subdirs | `15:36:30` | `gate/` (10), `note/` (9), `b2/` (4) |
| intra-round basename dups | `15:36:30` | `adversary.md` |
| lane-wide basename dups | `15:36:30` | **9** (4 pre-existing + 5 new) |
| byte-identical pairs lane-wide | `15:36:30` | **none** |
| exact-path r103 citations from outside r103 | `15:36:30` | **5** |
| r101+r102 dirty / diff / r101 tracked | `15:36:30` | `0` / `0` / `33` |
| r102 files / round-level subdirs | `15:36:30` | `61` / `5` |

The `r102-*` count stayed at 1 while off-pattern went to 7, and the subdir set grew 2 → 3
mid-window (`b2/` created at `15:33:04`). The directory was **still growing when this frame was
taken**. **[O]**

### 8.2 Post-landing frame `2026-10-18T15:36:57-03:00` (33 files) — nothing in §3–§5 changed shape

The directory grew again after this file was written, and the growth is consistent with §2:

```
$ find reports/round-103 -type f | wc -l
33
$ find reports/round-103 -maxdepth 1 -type f -name 'r103-*' | sort
r103-distiller.md  r103-scribe-audit.md
$ find reports/round-103 -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort
b2  gate  note
$ for s in $(find reports/round-103 -mindepth 1 -maxdepth 1 -type d); do echo "$(basename $s)=$(find $s -type f|wc -l)"; done
b2=5  gate=10  note=9
```

| claim | frame | value |
|---|---|---|
| total files | `15:36:57` | **33** (was 31 at `15:36:30`) |
| top-level / `r103-*` / off-pattern | `15:36:57` | `9` / `2` / `7` |
| round-level subdirs | `15:36:57` | `gate/` (10), `note/` (9), `b2/` (5) |
| intra-round basename dups | `15:36:57` | `adversary.md` |
| lane-wide basename dups | `15:36:57` | **9** (unchanged) |
| byte-identical pairs lane-wide | `15:36:57` | **none** |
| exact-path r103 citations from outside r103 | `15:36:57` | **5** (unchanged) |
| seat markers `with` / `without` | `15:36:57` | `31` / `2` |
| r101+r102 dirty / diff / r101 tracked | `15:36:57` | `0` / `0` / `33` |

Two files landed (`b2/postgrep.md`, `b2/repair-three.md`), both inside the existing `b2/` subdir —
**no new subdir was invented**, which is the same self-limiting behaviour `reports-index.md` §13
observed for r102 over its last 7 files. This seat's own file is the second `r103-*` top-level
name, moving that ratio from 1/8 to 2/9. **[O]**

**This is the last frame in this document, and the directory was still growing when it was
taken.** The round-close scribe must re-run §9's commands, not quote them. **[O]**

### 8.3 CORRECTION (dated) — §8.2's "no new subdir was invented" is **falsified** **[O]**

The sentence in §8.2 above is **wrong as a forward-looking claim**, and it is corrected here
rather than deleted, per the lane's dated-correction-note discipline. At `15:37:14`, ~17 s after
the §8.2 frame, a **fourth** round-level subdirectory appeared:

```
$ find reports/round-103 -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort
b2  gate  note  physics
$ find reports/round-103/physics -type f -printf '%f %s\n'
investigate.md 18507
$ find reports/round-103 -type f | wc -l
36
```

`physics/investigate.md` (18507 B) is the C3 seat's battery-row investigation — the row
`phys3d_joints_free_ops` that failed the r102 idle run. Its own subdir means r103 now runs
**four** round-level subdirs, **three of them new** relative to r102:

```
$ comm -13 <(find reports/round-102 -mindepth 1 -maxdepth 1 -type d -printf '%f\n'|sort) \
           <(find reports/round-103 -mindepth 1 -maxdepth 1 -type d -printf '%f\n'|sort)
b2
note
physics
```

**What §8.2 got right and what it got wrong.** The frame it reports was accurate at its
timestamp — `b2=5 gate=10 note=9` and 33 files were all true at `15:36:57`. What was unsound was
the *inference* drawn from a single frame: "no new subdir was invented" is a claim about the
future made from one sample of a directory that §2 had already established was growing one file
every 5–10 s. This is exactly the sampling trap the r102 audit named and withdrew a finding for
(`r102-scribe-audit.md` §4.2): a single `find` sample cannot support a claim about what the
directory will not do next. §3.3's verdict — **partial adoption of the r102 subdir vocabulary** —
is *strengthened* by this correction, not weakened: three of four subdirs are new names, and the
subdir set was still expanding 6 minutes into the round. **[O]**/**[I]**

### 8.4 Frame `2026-10-18T15:37:14-03:00` (36 files)

| claim | frame | value |
|---|---|---|
| total files | `15:37:14` | **36** (was 1 at `15:31:34`) |
| top-level / `r103-*` / off-pattern | `15:37:14` | `9` / `2` / `7` |
| round-level subdirs | `15:37:14` | `gate/` (10), `note/` (9), `b2/` (7), `physics/` (1) |
| subdirs new vs r102 | `15:37:14` | `note/`, `b2/`, `physics/` (3 of 4) |
| intra-round basename dups | `15:37:14` | `adversary.md` |
| lane-wide basename dups | `15:37:14` | **9** (unchanged) |
| byte-identical pairs lane-wide | `15:37:14` | **none** |
| exact-path r103 citations from outside r103 | `15:37:14` | **5** (unchanged) |
| seat markers `with` / `without` | `15:37:14` | `34` / `2` |
| r101+r102 dirty / diff / r101 tracked | `15:37:14` | `0` / `0` / `33` |
| r102 files / round-level subdirs | `15:37:14` | `61` / `5` |

The subdir set grew **2 → 3 → 4** across this seat's window (`b2/` at `15:33:04`, `physics/` at
`~15:37:12`). The directory was **still growing when this frame was taken** — and, on this
document's own evidence, it can invent another subdir after it. **[O]**

### 8.5 Frame `2026-10-18T15:38:28-03:00` (44 files) — supersedes §8.4

The directory grew again (36 → 44) after §8.4. It supersedes §8.1–§8.4 as the state at its own
timestamp. §4.1 is already dated to this frame; §5.1's seat table is dated to `15:37:36`; both
remain true for their timestamps.

```
$ find reports/round-103 -type f | wc -l
44
$ find reports/round-103 -maxdepth 1 -type f | wc -l
12
$ find reports/round-103 -maxdepth 1 -type f -name 'r103-*' | sort
r103-distiller.md  r103-scribe-audit.md
$ for s in $(find reports/round-103 -mindepth 1 -maxdepth 1 -type d); do echo "$(basename $s)=$(find $s -type f|wc -l)"; done
b2=10  gate=12  note=9  physics=1
$ find reports -type f -printf '%f\n' | sort | uniq -d | wc -l
12
```

| claim | frame | value |
|---|---|---|
| total files | `15:38:28` | **44** (was 1 at `15:31:34`) |
| top-level / `r103-*` / off-pattern | `15:38:28` | `12` / `2` / `10` |
| round-level subdirs | `15:38:28` | `gate/` (12), `b2/` (10), `note/` (9), `physics/` (1) |
| subdirs new vs r102 | `15:38:28` | `note/`, `b2/`, `physics/` (3 of 4) |
| intra-round basename dups | `15:38:28` | `adversary.md` |
| lane-wide basename dups | `15:38:28` | **12** |
| byte-identical pairs lane-wide | `15:38:28` | **none** |
| exact-path r103 citations from outside r103 | `15:38:28` | **5** (unchanged) |
| seat markers `with` / `without` | `15:38:28` | `42` / `2` |
| r101+r102 dirty / diff / r101 tracked | `15:38:28` | `0` / `0` / `33` |
| r102 files / round-level subdirs | `15:38:28` | `61` / `5` |

Two observations that only the later frames could produce:

1. **The subdir count stabilised at 4** even as the file count went 31 → 44. Four new files landed
   inside `gate/` and `b2/` and one new top-level file (`battery-consistency.md`) appeared, but no
   fifth subdir. The "new subdir" behaviour was bursty, not continuous — which is why §8.2's
   single-frame inference failed and §8.3's correction was needed. **[O]**/**[I]**
2. **The two marker-less files never changed**: `gate/clean.raw.txt` and `gate/clean.now.txt`, at
   every frame from `15:31:34` onward. The seat-marker ratio improved from 28/30 to 42/44 purely
   by dilution. **[O]**

**The directory was still growing when this frame was taken, and this seat has now seen it grow
after four separate "final" claims (§8.1, §8.2, §8.4, this one).** The round-close scribe must
re-run §9's commands, not quote them. **[O]**

### 8.6 Absolute last frame `2026-10-18T15:39:20-03:00` (47 files) — the growth sampler stopped here

This seat's 5 s growth sampler ran 93 frames and was then stopped. Its last three frames:

```
2026-10-18T15:39:05-03:00  46  3  4
2026-10-18T15:39:10-03:00  46  3  4
2026-10-18T15:39:15-03:00  47  4  4
```

The closing state, measured once more at `15:39:20`:

```
$ find reports/round-103 -type f | wc -l
47
$ find reports/round-103 -maxdepth 1 -type f -name 'r103-*' | sort
r103-connector.md  r103-distiller.md  r103-report.md  r103-scribe-audit.md
$ for s in $(find reports/round-103 -mindepth 1 -maxdepth 1 -type d); do echo "$(basename $s)=$(find $s -type f|wc -l)"; done
b2=10  gate=12  note=9  physics=1
$ with=45 without=2
```

| claim | frame | value |
|---|---|---|
| total files | `15:39:20` | **47** (was 1 at `15:31:34`) |
| top-level / `r103-*` / off-pattern | `15:39:20` | `15` / `4` / `11` |
| round-level subdirs | `15:39:20` | `gate/` (12), `b2/` (10), `note/` (9), `physics/` (1) |
| lane-wide basename dups | `15:39:20` | **12** |
| byte-identical pairs lane-wide | `15:39:20` | **none** |
| exact-path r103 citations from outside r103 | `15:39:20` | **5** |
| seat markers `with` / `without` | `15:39:20` | `45` / `2` |
| r101+r102 dirty / diff / r101 tracked | `15:39:20` | `0` / `0` / `33` |
| r102 files / round-level subdirs | `15:39:20` | `61` / `5` |

Two close-out artifacts landed after §8.5 (`r103-connector.md`, `r103-report.md`), pushing the
`r103-*` ratio to **4 of 15**. The subdir set held at 4 throughout the final 3 minutes of
observation. **Growth from 1 to 47 files in ~7.8 minutes; the sampler stopped, the directory did
not necessarily stop.** **[O]**

### 8.7 Post-sampler frame `2026-10-18T15:40:21-03:00` (49 files) — the growth continued after the sampler died

The sampler was stopped after §8.6, but the directory did **not** stop. Two files landed in the
minute after the sampler's last frame, so §8.6's 47 is not the final state either:

```
$ find reports/round-103 -type f | wc -l
49
$ find reports/round-103 -maxdepth 1 -type f -name 'r103-*' | wc -l
4
```

| claim | frame | value |
|---|---|---|
| total files | `15:40:21` | **49** |
| top-level / `r103-*` | `15:40:21` | `15` / `4` |
| round-level subdirs | `15:40:21` | 4 (`gate/`, `note/`, `b2/`, `physics/`) |
| lane-wide basename dups | `15:40:21` | **12** |
| byte-identical pairs lane-wide | `15:40:21` | **none** |
| exact-path r103 citations from outside r103 | `15:40:21` | **4** (was 5 at `15:37:14`; a peer seat rewrote `gate/README.md` — §5.2) |
| r101+r102 dirty / r101 tracked | `15:40:21` | `0` / `33` |
| `corpus/fixtures/three/README.md` | `15:40:21` | **still dirty** (§1.1) |

**This document now records five successive "final" states (31, 33, 36, 44, 47) and every one of
them was overtaken.** That is the finding, not an embarrassment: the round's scribe-audit cannot
report a settled count, only a series, and any round-close number quoted from this document must
be re-measured. The structural findings — subdir set of 4, the collision set, r101/r102
immutability, the §1.1 protected-path edit, zero byte-duplicates — held at **every** frame from
`15:36:30` onward and are the parts of this audit that are safe to quote. **[O]**

---

## 9. Reproducing this audit

```
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
git rev-parse HEAD                                       # expect c85a816…
git status --porcelain reports/round-101 reports/round-102   # expect empty
git diff --name-only HEAD -- reports/round-101 reports/round-102   # expect empty
git ls-files reports/round-101 | wc -l                   # expect 33
find reports/round-103 -type f | sort | wc -l            # 1 → 49 during this seat, still growing
find reports/round-103 -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort
find reports/round-103 -maxdepth 1 -type f -name 'r103-*' | sort
find reports/round-103 -maxdepth 1 -type f ! -name 'r103-*' | wc -l
find reports/round-103 -type f -printf '%f\n' | sort | uniq -d
find reports -type f -printf '%f\n' | sort | uniq -d
find reports -type f -exec sha256sum {} \; | awk '{print $1}' | sort | uniq -d
for f in $(find reports/round-103 -type f); do grep -q "SEAT-[0-9]" "$f" || echo "no seat: $f"; done
grep -rn "reports/round-103" --include='*.md' --include='*.sh' . | grep -v '^./reports/round-103/'
find reports/round-102 -type f | wc -l                   # expect 61
```

The file count is the one number that will **not** reproduce (§2). Every count in this report is
stamped with the time it was observed. **[O]**

---

No Unreal runtime claim is made anywhere in this document. The Unreal Editor and UnrealBuildTool
are not installed on this host; the r101/r102 subtrees this round re-measures are treated as file
bytes only, and nothing here proves plugin load, compilation, or engine runtime behaviour.
