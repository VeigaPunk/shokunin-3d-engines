# r104 scribe-audit — custody audit of `reports/round-104/`

Seat: **SEAT-29 SCRIBE-AUDIT**. Lane: `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`.
Scope: inventory `reports/round-104/` at this seat's runtime — file count, naming-convention
compliance, growth frames — and verify that `reports/round-101/`, `reports/round-102/` and
`reports/round-103/` stayed untouched.

**Read-only.** This seat wrote nothing but this file. It edited no cited artifact and ran no
`git` state-mutating command (no commit / push / checkout / reset / add).

Lane HEAD throughout: `88c3b2ca70fc83ec47a931d7b6dcff85a111c04e`
(*"r103 report-last: verdict (all axes improved), LOG + SCORECARD, A4 timeline ruling + physics
ruling + fixtures conformance ruling — work 8c9d9ad"*).

Tags: **[O]** command-run observation · **[I]** labelled inference · **[?]** unknown.

**No Unreal runtime claim is made anywhere in this document.** The Unreal Editor and
UnrealBuildTool are not installed on this host; every number below is a byte count, an exit
status, or a filesystem measurement.

**Status: AUDIT COMPLETE. The subject never stopped moving, and this round it did not merely
grow — it spiked, then drained.** `reports/round-104/` went **156 → 11,315 files** during this
seat's window (`2026-10-18T16:16:32-03:00` → `16:25:59-03:00`, ~9.5 min). In the middle of that
window it reached **379,588 files** for roughly one minute (§2.3) when two seats concurrently copied
the whole `corpus/live/runs/` tree into their own `scratch/` directories and then deleted the copies.
After `16:27:04` the directory began **shrinking** as seats removed their scratch, reaching **6,189
files** at this seat's last frame (§8.6) — so the series is not a trend, it is a **30x transient
followed by a drain**. §2 is the growth series; §8 is the closing frames. Every count carries the
time it was observed.

**Two findings this seat did not expect and cannot resolve alone:**
§1.1 (the one authorized fixture edit, `corpus/fixtures/phys3d_joints.gd`, observed mid-write)
and §4.2 (**r104 is ~80% redundant bytes** — 11,315 files hold only 2,229 distinct digests).

---

## 0. Method (exact commands, all read-only)

```
date -Iseconds                                          # every frame is stamped
find reports/round-104 -type f | wc -l
find reports/round-104 -maxdepth 1 -type f | wc -l
find reports/round-104 -maxdepth 1 -type f -name 'r104-*' | wc -l
find reports/round-104 -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort
find reports/round-104 -type d | awk -F/ '{print NF}' | sort -rn | head -1     # tree depth
find reports/round-104 -type f -printf '%f\n' | sort | uniq -d                 # intra-round collisions
find reports -type f -printf '%f\n' | sort | uniq -d                           # lane-wide collisions
find reports/round-104 -type f -exec sha256sum {} \; | awk '{print $1}' | sort -u | wc -l
find reports -type f ! -path 'reports/round-104/*' -exec sha256sum {} \; \
  | awk '{print $1}' | sort | uniq -d                                          # non-r104 byte dups
git rev-parse HEAD
git status --porcelain
git status --porcelain reports/round-101 reports/round-102 reports/round-103
git diff --name-only HEAD -- reports/round-101 reports/round-102 reports/round-103
git ls-files reports/round-101 | wc -l ; git ls-files reports/round-102 | wc -l
for f in LOG.md SCORECARD.md SHONEN.md PROVINCE.md; do
  wt=$(git hash-object -- "$f"); hd=$(git rev-parse "HEAD:$f")
  printf '%s %s\n' "$f" "$([ "$wt" = "$hd" ] && echo IDENTICAL || echo DIFFER)"; done
git diff --stat HEAD -- corpus/fixtures/
```

Growth series (sampler, 5 s cadence; `n` / top-level files / `r104-*` / top-level subdirs):

```
while :; do printf '%s\t%s\t%s\t%s\t%s\n' "$(date -Iseconds)" \
  "$(find reports/round-104 -type f | wc -l)" \
  "$(find reports/round-104 -maxdepth 1 -type f | wc -l)" \
  "$(find reports/round-104 -maxdepth 1 -type f -name 'r104-*' | wc -l)" \
  "$(find reports/round-104 -mindepth 1 -maxdepth 1 -type d | wc -l)"; sleep 5; done
```

---

## 1. r101, r102 and r103 are untouched — the discipline check **[O]**

Re-verified at the open, middle and close of this seat's window. All three agree.

```
$ git status --porcelain reports/round-101 reports/round-102 reports/round-103 | wc -l
0
$ git diff --name-only HEAD -- reports/round-101 reports/round-102 reports/round-103 | wc -l
0
$ for d in reports/round-101 reports/round-102 reports/round-103; do \
    echo "$d dirty=$(git status --porcelain $d|wc -l) tracked=$(git ls-files $d|wc -l)"; done
reports/round-101 dirty=0 tracked=33
reports/round-102 dirty=0 tracked=61
reports/round-103 dirty=0 tracked=61
```

No r101, r102 or r103 file was added, deleted, renamed, or rewritten by any r104 seat. **[O]**

The four ledger files are byte-identical to HEAD:

```
$ for f in LOG.md SCORECARD.md SHONEN.md PROVINCE.md; do
    wt=$(git hash-object -- "$f"); hd=$(git rev-parse "HEAD:$f"); \
    printf '%s %s\n' "$f" "$([ "$wt" = "$hd" ] && echo IDENTICAL || echo DIFFER)"; done
LOG.md IDENTICAL
SCORECARD.md IDENTICAL
SHONEN.md IDENTICAL
PROVINCE.md IDENTICAL
```

Repo-wide working tree at the closing frame **[O]**:

```
$ git status --porcelain
 M corpus/fixtures/phys3d_joints.gd
 M corpus/knowledge/unreal-mcp/gate/README.md
 M corpus/knowledge/unreal-mcp/gate/run_gate.sh
?? .r104-seat17/
?? SKILL.md
?? reports/round-104/
```

Three declared r104 paths are dirty, plus two untracked paths **outside `reports/`** — `.r104-seat17/`
(§1.2) and `SKILL.md` (§1.3). `reports/round-104/` is **not** gitignored
(`git check-ignore -v reports/round-104/ledger-check.md` → rc=1), so it is tracked-visible for the
round-close commit. **[O]**

### 1.1 The one authorized fixture edit — `corpus/fixtures/phys3d_joints.gd` **[O]**

The round brief names `corpus/fixtures/**` as write-protected **except for SEAT-04, whose declared
scope is exactly `corpus/fixtures/phys3d_joints.gd`**. This seat observed that edit land mid-window,
and it is the **only** fixture byte that moved:

```
$ git status --porcelain corpus/fixtures/          # @16:24:54
 M corpus/fixtures/phys3d_joints.gd
$ git diff --stat HEAD -- corpus/fixtures/
 corpus/fixtures/phys3d_joints.gd | 33 ++++++++++++++++++++++++++-------
 1 file changed, 26 insertions(+), 7 deletions(-)
```

At the first frame (`16:16:32`) the file was **unchanged**; at `16:18:04` it was still unchanged
(`git hash-object` = `3ce066a68d7dc8c6849b7198c19ef368063ad06a` = `HEAD:corpus/fixtures/phys3d_joints.gd`);
by `16:20:44` it was dirty and its worktree sha256 had moved from
`88be87faee02e6f0afb7d4d93036c5c98755e5daa3ed63e6d361ed0189db4d73` to
`c7e776387f607f084379ace95cd44987518cc6e5bb1b9b5376b27e1ece919ccc`.

**The companion file the brief conditions on is untouched:**

```
$ sha256sum corpus/fixtures/run_battery.py
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
$ git status --porcelain corpus/fixtures/run_battery.py
(empty)
```

The sha256 matches the round brief's pin (`f456bd00…`) and the r102 receipt's
`seed_digests['run_battery.py']`, so **the CASES table is byte-frozen and the C1 fix is confined to
the script**, exactly as the brief permits. This is a **conformance PASS**, not a custody question:
the protected tree moved by exactly one file, and that file is the one SEAT-04's declared scope
names. **[O]**/**[I]**

Contrast with r103, where `corpus/fixtures/three/README.md` moved **without** a declared scope
(r103 audit §1.1) — that ambiguity did not recur this round. **[O]**

### 1.2 A 1.4 GB working copy sits at the repo root — `.r104-seat17/` **[O]**

```
$ git status --porcelain | grep '^??'
?? .r104-seat17/
?? SKILL.md
?? reports/round-104/
$ ls -d .r104*
.r104-seat17
$ find .r104-seat17 -type f | wc -l
92582
$ du -sh .r104-seat17
1.4G
```

`.r104-seat17/` is a **seat's private lane clone** — it contains `lane/corpus/` and `lane/reports/`
(a full copy of the lane tree) plus a `clean.out` at its top level. It is **untracked and not
gitignored** (`git check-ignore -v .r104seat43` → rc=1 for the sibling form; `.r104-seat17/` is the
same class). It is **outside `reports/`**, so it is not this audit's subject, but it is now the
second-largest object in the working tree and it will appear in any `git add -A` at round close.
Recorded, not adjudicated: whether a seat's scratch clone belongs inside the lane repo is an L1
decision, not a scribe's. **[O]**/**[I]**

A sibling of the same class appeared and vanished during the window — `.r104seat43/` was present at
`16:16` (46 files: a vendored plugin tree with a `fresh.git/` pack) and was gone by `16:18`. **[O]**

### 1.3 A root-level `SKILL.md` appeared, citing an r104 path that did not yet exist **[O]**

```
$ git status --porcelain SKILL.md
?? SKILL.md
$ git cat-file -e HEAD:SKILL.md
fatal: path 'SKILL.md' exists on disk, but not in 'HEAD'
$ sha256sum SKILL.md
1055a52f570410e16f35c5d2384a36382e66568964e4d530cce914443e9fb66c  SKILL.md
```

`SKILL.md` is untracked and **not** at HEAD. It contains the r103-drafted decision table (rows
A–E) and cites `reports/round-104/skill/author.md` §2 as its r104 re-derivation. At `16:20:15`
that path did **not** exist (`ls reports/round-104/skill/author.md` → *No such file or
directory*); by `16:25:40` it did (17699 B, SEAT-18). So the citation is **forward-referenced and
now satisfied** — but at the moment `SKILL.md` was first observed it pointed at nothing. **[O]**

This is the C3 claim's landing path, and it is landing **at the repo root, not under `reports/`**.
Recorded because a scribe auditing `reports/round-104/` would otherwise report "C3 evidence
missing" when the evidence is in `skill/` and the artifact is at root. **[I]**

---

## 2. The file count is a moving target — growth series **[O]**

86 sampler frames plus ad-hoc frames, same command each time, each stamped. All times `-03:00`.
Flat stretches are collapsed; every inflection is listed.

| time | files | top-level | `r104-*` | subdirs | what happened |
|---|---|---|---|---|---|
| 16:16:32 | 156 | 0 | 0 | 2 | first frame — only `physics/` + `gate/`, all scratch |
| 16:16:57 | 178 | 1 | 0 | 2 | first top-level file (`ledger-check.md`); first `r90bt_*` scenario dirs |
| 16:17:22 | 227 | 1 | 0 | 3 | third subdir appears |
| 16:17:27 | **519** | 1 | 0 | 3 | **+292 in 5 s** — a `corpus/fixtures` copy lands |
| 16:17:43 | 711 | 2 | 0 | 3 | |
| 16:17:48 | **683** | 3 | 0 | 2 | **count goes DOWN** — a subdir deleted |
| 16:18:08 | **1,597** | 3 | 0 | 2 | **+752 in 5 s** |
| 16:18:43 | 1,765 | 5 | 0 | 3 | |
| 16:18:53 | **1,718** | 5 | 0 | 3 | down again |
| 16:19:43 | 1,975 | 7 | 0 | 5 | |
| 16:20:13 | **3,249** | 7 | 0 | 5 | **+1,193 in 5 s** |
| 16:20:48 | **5,854** | 7 | 0 | 6 | **+1,603 in 5 s**; `skill/` appears |
| 16:21:13 | 7,566 | 7 | 0 | 6 | |
| 16:21:23 | 6,861 | 7 | 0 | 6 | down again |
| 16:21:28 | **97,531** | 8 | 1 | 6 | **+90,670 in 5 s** |
| 16:21:44 | **379,588** | 8 | 1 | 7 | **peak — +171,565 in 6 s** |
| 16:21:55 | 296,105 | 8 | 1 | 8 | |
| 16:22:02 | 270,804 | 8 | 1 | 8 | |
| 16:22:36 | 229,984 | 8 | 1 | 8 | |
| 16:22:42 | **120,420** | 9 | 1 | 8 | **−110k in 6 s** |
| 16:22:48 | **7,951** | 9 | 1 | 8 | **−112k in 6 s** — the spike is deleted |
| 16:23:03 | 7,917 | 11 | 2 | 8 | |
| 16:23:58 | 10,409 | 12 | 2 | 8 | |
| 16:24:23 | 10,925 | 13 | 2 | 8 | |
| 16:24:49 | 11,234 | 15 | 4 | 8 | |
| 16:25:59 | **11,315** | 15 | 4 | 8 | last sampler frame |

Growth across the window: **156 → 11,315 files**, a **~72x** net rise, but the path is not
monotone — it falls at `16:17:48`, `16:18:53`, `16:21:23`, `16:22:42` and `16:22:48`, and it
passes through a **379,588-file peak**. **[O]**

### 2.1 Why a single sample cannot describe this directory **[O]**

The r102 audit withdrew a finding for trusting one `find` sample of a live directory. Here the
sampling problem is an order of magnitude worse: **two consecutive 5 s frames can differ by
300,000 files.** A scribe who runs `find … | wc -l` once and writes the number down has a
probability of capturing the transient rather than the steady state. The r103 index answered this
by requiring a **tree hash to repeat** across samples before calling a frame settled
(`reports/round-103/reports-index.md` §1). **This seat could not satisfy that standard** — see §2.4.

### 2.2 The spike is explained: concurrent whole-`corpus/live` copies **[O]**

At the peak the sampler emitted `find:` errors naming the responsible paths:

```
find: ‘reports/round-104/scratch/s20-skel2/corpus/live/runs/20261018T174432492194Z/scratch/…’: No such file or directory
find: ‘reports/round-104/scratch/s20-skel3/corpus/live/runs/20261018T175023461328Z/scratch/…’: No such file or directory
```

Two seats (`s20-skel2`, `s20-skel3` — the `s20` prefix suggests a shared seat number) each copied
the **entire `corpus/live/runs/` tree** into their own `reports/round-104/scratch/` directory. That
tree is where the lane's own Godot battery scratch output accumulates, so it is large and deep. The
copies were deleted between `16:22:36` and `16:22:48`, which is the −112k step. **[O]**/**[I]**

The `scratch/` top-level directory was **1924 files** at the closing frame and had **469** in it at
`16:25:04`, i.e. the copy-delete cycle was still in flight. **[O]**

### 2.3 The directory reached 379,588 files **[O]**

That is **34x** the closing frame's 11,315 and roughly **4,200x** the first frame's 156. For
scale, the entire lane outside r104 holds **less than 700 files** (§3.1). If any other r104 seat
took a file count during `16:21:28`–`16:22:36` and wrote it into its report, that number is a
transient and must not be quoted. **This seat's own §8 frames are all post-collapse and are
therefore the safe ones to quote.** **[O]**/**[I]**

### 2.4 This seat did not obtain a settled frame **[O]**

The r103 standard requires the tree hash to repeat before a frame is called final. This seat ran
three hash samples at 20 s spacing and could not even complete them — the `sha256sum` walk
produced **9.4 MB of output** and had to be killed, because the directory was growing faster than
it could be hashed (at one point the walk was traversing ~250,000 files). The samples that did
complete:

```
2026-10-18T16:22:17-03:00 files=254407 treehash=814ff969f2836dac
2026-10-18T16:23:07-03:00 files=7940   treehash=39871ffa611a4e41
```

Two frames 50 s apart, differing by a factor of 32 in file count and completely in hash. **No
stable frame exists in this seat's window.** Every structural number in §3–§5 is therefore stated
against the **closing frame at `16:25:59`, and is a snapshot of a live directory, not a settled
one.** **[O]**

---

## 3. Naming-convention compliance **[O]**

### 3.1 r104 against the whole lane

```
$ for d in $(find reports -mindepth 1 -maxdepth 1 -type d | sort); do
    top=$(find $d -maxdepth 1 -type f|wc -l); rnn=$(find $d -maxdepth 1 -type f -name 'r[0-9]*-*'|wc -l)
    sub=$(find $d -mindepth 1 -maxdepth 1 -type d|wc -l); tot=$(find $d -type f|wc -l)
    if [ "$((top-rnn))" -gt 0 ] || [ "$sub" -gt 0 ]; then printf '%-22s top=%-3s rNN=%-3s off=%-3s sub=%-2s total=%-5s\n' \
      "$(basename $d)" "$top" "$rnn" "$((top-rnn))" "$sub" "$tot"; fi; done
round-101              top=17  rNN=15  off=2   sub=1  total=33
round-102              top=29  rNN=8   off=21  sub=5  total=61
round-103              top=20  rNN=6   off=14  sub=4  total=61
round-104              top=15  rNN=4   off=11  sub=8  total=11315
round-1-20261015       top=2   rNN=0   off=2   sub=1  total=4
frontier               top=5   rNN=0   off=5   sub=0  total=5
round-86               top=12  rNN=10  off=2   sub=0  total=12
```

Lane-wide, `rNN-*.md` is the standing form: **31 of 37 round directories use it for every
top-level file** (`find reports -mindepth 1 -maxdepth 1 -type d -name 'round-*'` → 37 dirs, 31 with
zero off-pattern top-level files). The exceptions are `round-101` (2 off), `round-102` (21 off),
`round-103` (14 off), `round-104` (11 off at this frame), `round-1-20261015` (2) and `round-86`
(2); `frontier` is not a round and is excluded. **[O]**

### 3.2 Verdict: r104 **inherits r103's ratio, and is the first round whose *directory* is not a report set**

At the closing frame r104 has **4 of 15** top-level files in the `r103`-style form
(`r104-connector.md`, `r104-distiller.md`, `r104-report.md`, `r104-verification-protocol.md`) —
**exactly the long round-close seats** that r102's and r103's audits both predicted would adopt the
form (`[I]` in each). The other 11 top-level files are topic slugs, six of which
(`freshness-pin`, `git-hygiene`, `install-recheck`, `ledger-check`, `stub-cleanness`,
`subtree-integrity`) are **the same slugs r102 and r103 used**, i.e. re-runs of the same seats.

| round | top-level | `rNN-*` | ratio | first `rNN-*` |
|---|---|---|---|---|
| round-101 | 17 | 15 | 88% | — |
| round-102 | 29 | 8 | 28% | ~3 min in |
| round-103 | 20 | 6 | 30% | ~2.5 min in |
| **round-104** | **15** | **4** | **27%** | late (first at `16:21:28`) |

The ratio is **stable at ~27–30% for three rounds running**. That is the finding: the `rNN-<seat>.md`
form has settled into a **convention for round-close artifacts only**, and the lane has been
treating it that way consistently since r102. It is no longer a compliance failure; it is the
observed convention. **[O]**/**[I]**

### 3.3 The real naming event is that r104 has **no** report-set shape at all **[O]**

```
$ find reports/round-104 -maxdepth 1 -type f -printf '%f %s\n' | sort
consistency.md|32094
freshness-pin.md|12183
git-hygiene.md|33431
install-recheck.md|23436
kimi-404-carry.md|12412
ledger-check.md|6438
lessons-carry-gate-default-tmpdir.out|2080
lessons-carry.md|41037
r104-connector.md|31646
r104-distiller.md|39550
r104-report.md|48580
r104-verification-protocol.md|57514
seats-ledger.md|15651
stub-cleanness.md|23123
subtree-integrity.md|17918
```

Those 15 files are **the round's actual report set** — 14 markdown reports plus one loop capture,
totalling ~430 KB. **The other ~11,300 files are not reports.** §4 classifies them.

The tree depth makes the point better than the file count does:

```
$ find reports/round-104 -type d | awk -F/ '{print NF}' | sort -rn | head -1
13
$ for d in $(find reports -mindepth 1 -maxdepth 1 -type d|sort); do
    echo "$(basename $d) depth=$(find $d -type d -printf '%d\n'|sort -rn|head -1)"; done
round-101 depth=1   round-102 depth=1   round-103 depth=1   round-104 depth=13
```

**r104 is 13 levels deep. Every other round in the lane is 0 or 1.** That is not a naming
variation — it is a different kind of object. **[O]**

### 3.4 Subdirectories: 8 top-level buckets, 5 of them new names **[O]**

```
$ for s in $(find reports/round-104 -mindepth 1 -maxdepth 1 -type d); do
    echo "$(basename $s)=$(find $s -type f|wc -l)"; done
gate=368
physics=10240
tmp.O08ANPOIb9=0
lessons-carry-loop=10
scratch=469
skill=3
s22tmp=2
s22runs=172
```

| subdir | r102 | r103 | r104 | role |
|---|---|---|---|---|
| `gate/` | ✅ 9 | ✅ 17 | ✅ 368 | gate execution receipts — **the one name carried through all three rounds** |
| `physics/` | — | ✅ 3 | ✅ 10,240 | the battery-row investigation — carried from r103 |
| `note/` | — | ✅ 9 | — | dropped |
| `b2/` | — | ✅ 11 | — | dropped |
| `before/`, `repairs/`, `reruns/`, `adversary/` | ✅ | — | — | dropped |
| `scratch/` | — | — | ✅ 469 | **new** — pinned clones and corpus copies |
| `skill/` | — | — | ✅ 3 | **new** — the C3 decision-table evidence set |
| `lessons-carry-loop/` | — | — | ✅ 10 | **new** — a repeat-run loop capture |
| `s22tmp/`, `s22runs/` | — | — | ✅ 174 | **new** — seat-numbered scratch |
| `tmp.O08ANPOIb9/` | — | — | 0 | **new, and empty** — an unremoved `mktemp -d` |

**Reading.** r103's audit recommended "decide whether the role names are a fixed vocabulary or a
per-round free choice" (r103 §7.2). r104 answers by doing neither cleanly: it keeps `gate/` and
`physics/`, drops `note/` and `b2/`, and adds five names — three of which (`scratch/`, `s22tmp/`,
`s22runs/`) encode **who ran it** rather than **what it is**, which is the opposite of the
role-grouping idea r102 introduced. `tmp.O08ANPOIb9/` is a leaked temp directory sitting at the
round's top level. **[O]**/**[I]**

---

## 4. Duplication and composition

### 4.1 Intra-round basename collisions: **1,457** **[O]**

```
$ find reports/round-104 -type f -printf '%f\n' | sort | uniq -d | wc -l
1457
$ find reports/round-104 -type f -printf '%f\n' | sort | uniq -c | sort -rn | head -8
    155 project.godot
    147 child.log
     21 README.md
      9 package.json
      6 tri_upper.GLB
      6 tri.gltf
      6 tri.glb
      6 transform3d_compose.gd
```

r103's audit flagged **one** intra-round collision (`adversary.md`) as a duplication event worth
explaining. r104 has **1,457** — a 1,400x rise — and they are of a completely different kind:
`project.godot` appears **155 times** and `child.log` **147 times** because each is a per-scenario
Godot project stub written into its own scenario directory by the battery runner. These are not
name reuse across report namespaces; they are **run artifacts that happen to share a filename by
design**. **[O]**/**[I]**

### 4.2 **r104 is ~80% redundant bytes** — the headline finding **[O]**

```
$ find reports/round-104 -type f | wc -l
11315
$ find reports/round-104 -type f -exec sha256sum {} \; | awk '{print $1}' | sort -u | wc -l
2229
```

**11,315 files hold only 2,229 distinct digests.** **9,086 files (80.3%) are byte-identical to some
other file in the same round directory** — only 19.7% of the files carry unique bytes, so the round
stores its own content about **5.1x** over. At the earlier frame `16:20:59` the ratio was 5,966
files / 2,419 digests (2.5x), and at `16:24:30` it was 10,909 / 2,164 (5.0x). **The *unique* count
moves far less than the file count** — 2,419 → 2,229 while the total went 5,966 → 11,315 — which is
the signature of a directory accumulating copies rather than content. **[O]**

The concrete mechanism is a **four-way and sometimes six-way and twelve-way copy of the same
fixture tree**:

```
$ find reports/round-104 -type f -exec sha256sum {} \; | sort | awk '{print $1}' | uniq -c | sort -rn | head
     12  <r98assets/glb_as_gltf.gltf, tri.glb, tri_upper.GLB × 4 trees>
      8  <r98assets/json_as_glb.glb, tri.gltf × 4 trees>
      7  <gate/scratch/live-gate.out + 6 loop outputs>
      4  physics/runs/<id>/scratch/<fixture>   ← copy 1
      4  physics/s06/conc/<fixture>            ← copy 2
      4  physics/s06/serial/<fixture>          ← copy 3
      4  physics/standalone/scratch-fresh/<fixture>  ← copy 4
```

Verified directly — the same fixture file at **three** paths, byte-identical (full 64-hex digests,
re-measured at `16:26:50`):

```
$ sha256sum reports/round-104/physics/runs/20261018T191620117114Z/scratch/bpy_battery.py \
            reports/round-104/physics/s06/conc/bpy_battery.py \
            reports/round-104/physics/s06/serial/bpy_battery.py
045102a8514df96bda0c2268841ec0751de87f678f34cbdf981c3a7c6ff882ec  reports/round-104/physics/runs/20261018T191620117114Z/scratch/bpy_battery.py
045102a8514df96bda0c2268841ec0751de87f678f34cbdf981c3a7c6ff882ec  reports/round-104/physics/s06/conc/bpy_battery.py
045102a8514df96bda0c2268841ec0751de87f678f34cbdf981c3a7c6ff882ec  reports/round-104/physics/s06/serial/bpy_battery.py
```

**A caution this re-measurement produced.** The digest-group listing above shows a **fourth** copy
at `physics/standalone/scratch-fresh/<fixture>` (4 copies per fixture), but when this seat re-ran
the three-path command at `16:26:50` to confirm the fourth, the path was **already gone**
(`sha256sum: …/standalone/scratch-fresh/bpy_battery.py: No such file or directory`). The 4-copy
grouping was measured at `16:19:36` and is correct **for that timestamp**; the fourth copy was
deleted between `16:19:36` and `16:26:50`. **This is §2's lesson restated in miniature**: a
duplication count is a frame, and the copies are moving. The three paths above are the ones this
seat reproduced twice. **[O]**

The copies are **107 of 113 `corpus/fixtures` files, verified byte-identical**:

```
$ same=0; diff=0; for f in $(ls corpus/fixtures); do
    [ -f "reports/round-104/physics/s06/conc/$f" ] && \
    { cmp -s "reports/round-104/physics/s06/conc/$f" "corpus/fixtures/$f" && same=$((same+1)) || diff=$((diff+1)); }; done
same=107 diff=0
```

So `physics/s06/conc/` and `physics/s06/serial/` are **verbatim copies of the byte-protected fixture
tree**, one per arm of the C1 experiment. The one file that differs is exactly the file SEAT-04 is
authorized to edit:

```
$ sha256sum reports/round-104/physics/s06/conc/phys3d_joints.gd \
            reports/round-104/physics/s06/serial/phys3d_joints.gd \
            corpus/fixtures/phys3d_joints.gd
e79c3180905c1104eccccdc94a29309dd95385347badd2383d48c36f5cb84b67  …s06/conc/phys3d_joints.gd   ← FIXED copy
88be87faee02e6f0afb7d4d93036c5c98755e5daa3ed63e6d361ed0189db4d73  …s06/serial/phys3d_joints.gd ← unmodified copy
88be87faee02e6f0afb7d4d93036c5c98755e5daa3ed63e6d361ed0189db4d73  corpus/fixtures/phys3d_joints.gd
```

That is a **clean experimental design**: `serial/` holds the pre-fix script, `conc/` holds the
post-fix script, and `run_battery.py` is identical (`f456bd00…`) in both. **[O]**/**[I]**

### 4.3 Lane-wide byte-duplicates: **0 before r104, and all of them are r104's own copies** **[O]**

```
$ find reports -type f ! -path 'reports/round-104/*' -exec sha256sum {} \; \
    | awk '{print $1}' | sort | uniq -d | wc -l
0
```

**Outside r104, the lane still has zero byte-identical report pairs** — the invariant r102 and r103
each established and this seat re-verified. The lane-wide duplicate set is now entirely r104's:

```
$ comm -12 <(find reports/round-104 -type f -exec sha256sum {} \; | awk '{print $1}' | sort -u) \
           <(find reports -type f ! -path 'reports/round-104/*' -exec sha256sum {} \; | awk '{print $1}' | sort -u) | wc -l
393
```

**393 r104 files are byte-identical to a tracked file elsewhere in `reports/`.** The cause is a
**742-file checkout of HEAD inside the round directory**:

```
$ find reports/round-104/gate/scratch/full-c85a816 -type f | wc -l
742
$ ls reports/round-104/gate/scratch/full-c85a816/
corpus  LOG.md  PROVINCE.md  README.md  reports  SCORECARD.md  SHONEN.md
$ ls reports/round-104/gate/scratch/full-c85a816/reports/ | head -8
frontier  round-100  round-101  round-102  round-1-20261015  round-69  round-70  round-71 …
```

A seat cloned the whole lane at `c85a816` into `gate/scratch/full-c85a816/` to test something, and
that clone contains **every round directory from round-69 to round-102**. Sample pairs:

```
001c0ea18e044a16b3db7b3655240b5f98945a23aaf167b9313cd67ce6f2bd5c
  reports/round-77/r77-boundary.md
  reports/round-104/gate/scratch/full-c85a816/reports/round-77/r77-boundary.md
01f101c85d9bd70a11755f23baa3bbe326f25f878309635e24b46dc0a98cabd0
  reports/round-102/battery-integrity.md
  reports/round-104/gate/scratch/full-c85a816/reports/round-102/battery-integrity.md
```

**This is why the lane-wide duplicate count went from 0 to 393 without a single report being
duplicated.** The frozen history is byte-identical to itself inside a clone. It is a **containment**
artifact, not a content problem — but it means any lane-wide duplicate scan taken after r104 must
exclude `reports/round-104/**/scratch/**` or it will report hundreds of phantom duplicates for as
long as a clone exists. **[O]**/**[I]**

### 4.3.1 CORRECTION (dated) — the clone was deleted mid-audit, and the 393 went to 0 **[O]**

The 393 figure above was measured at `16:24:30`. **Re-measured at `16:27:41`, it is 0**, because the
clone no longer exists:

```
$ find reports/round-104/gate/scratch/full-c85a816 -type f | wc -l
0
$ ls -d reports/round-104/gate/scratch/full-c85a816
ls: cannot access 'reports/round-104/gate/scratch/full-c85a816': No such file or directory
$ comm -12 <(find reports/round-104 -type f -exec sha256sum {} \; | awk '{print $1}' | sort -u) \
           <(find reports -type f ! -path 'reports/round-104/*' -exec sha256sum {} \; | awk '{print $1}' | sort -u) | wc -l
0
```

This does **not** retract §4.3 — the clone, its 742 files and the 393 matching digests were all
observed directly and the sample pairs are quoted from that frame. What it changes is the
**durability** of the claim: the phantom-duplicate problem is **transient by construction**, because
the thing that causes it is a scratch clone that a seat removes when it is done. A scribe who
measures at a moment when no clone exists will see `0` and conclude — wrongly — that §4.3's
mechanism does not occur. **Both readings are correct for their timestamp.** This is §2's lesson a
third time: every count here is a frame. **[O]**

### 4.4 The four-way classification of r104 **[O]**

```
$ for pat in gate/scratch physics/s06 physics/nc physics/author-runs physics/runs scratch s22runs; do
    echo "$pat=$(find reports/round-104 -path "*$pat*" -type f 2>/dev/null|wc -l)"; done
gate/scratch=362
physics/s06=6463
physics/nc=2866
physics/author-runs=584
physics/runs=342
scratch=1924
s22runs=172
```

| category | files (closing frame) | what it is |
|---|---|---|
| **report text** | ~45 | top-level 15 + `gate/` 7 + `skill/` 3 + `physics/` maxdepth-1 10 + `lessons-carry-loop/` 10 |
| **fixture copies** | ~6,500 | `physics/s06/{conc,serial}/` — verbatim `corpus/fixtures` |
| **corpus/run-tree copies** | ~4,300 | `physics/nc*`, `physics/author-runs*`, `physics/runs*`, `scratch/*`, `s22runs/` |
| **repo clone** | 742 | `gate/scratch/full-c85a816/` |

**~45 of 11,315 files (0.4%) are the round's reports.** The number a scribe wants is in the first
row; the number `find | wc -l` returns is in all four. **[O]**/**[I]**

### 4.5 Executables in the round **[O]**

```
$ find reports/round-104 -type f -perm -u+x -printf '%P\n'
gate/flake_harness.sh
gate/scratch/c85a816/corpus/knowledge/unreal-mcp/gate/run_gate.sh
gate/scratch/verify-workdir.sh
physics/{runs,s06/conc,s06/serial,standalone/scratch-fresh}/r95vendor/pybullet.cpython-314-x86_64-linux-gnu.so
```

r103's index reported **no** executable files. r104 has 7: two seat-authored gate scripts
(`flake_harness.sh`, `verify-workdir.sh` — the C2 claim's artifacts), one **copy of the gate itself**
inside the pinned clone, and four copies of a compiled Python extension module
(`pybullet…so`, 7 MB each) vendored for the physics comparison. **[O]**

---

## 5. Other runtime observations

### 5.1 Seat recoverability **[O]**

```
$ for f in $(find reports/round-104 -maxdepth 1 -type f); do
    echo "$(basename $f) -> $(grep -o 'SEAT-[0-9]*' $f|head -1)"; done
consistency.md -> SEAT-31
freshness-pin.md -> SEAT-43
git-hygiene.md -> SEAT-27
install-recheck.md -> SEAT-44
kimi-404-carry.md -> SEAT-47
ledger-check.md -> SEAT-26
lessons-carry-gate-default-tmpdir.out -> (none)
lessons-carry.md -> SEAT-46
r104-connector.md -> SEAT-24
r104-distiller.md -> SEAT-23
r104-report.md -> SEAT-35
r104-verification-protocol.md -> SEAT-32
seats-ledger.md -> SEAT-42
stub-cleanness.md -> SEAT-28
subtree-integrity.md -> SEAT-41
```

**14 of 15** top-level files carry a `SEAT-NN` marker; the one exception is a loop capture
(`lessons-carry-gate-default-tmpdir.out`). Every `gate/`, `skill/` and `physics/` maxdepth-1
markdown file carries one too (SEAT-40/14/45/15/12/13, SEAT-18/21/20, SEAT-02/11/03/09/08). The
seat convention held **completely** for r104's actual reports. **[O]**

```
$ grep -rho 'SEAT-[0-9]*' reports/round-104 --include='*.md' --include='*.sh' | sort -u | wc -l
46
```

**46 distinct seat ids** appear. The id→artifact mapping is in §8.3. Note that a naive
`grep -r 'SEAT-[0-9]' reports/round-104` also matches the **copied corpus text**, which inflates
the count — the figures above are from genuine report artifacts only. **[O]**

### 5.2 r104 is cited from outside itself — **9** exact-path citations **[O]**

```
$ grep -rn "reports/round-104" --include='*.md' --include='*.sh' . \
    | grep -v '^./reports/round-104/' | grep -v '^./.r104-seat17/' | wc -l
9
```

The citations come from `SKILL.md` at the repo root (5 lines: the C3 decision table's rows A, C, D,
E and a provenance line), each pointing at `reports/round-104/skill/author.md` §2. r102 had **1**
citation at its scribe audit; r103 had **4–5**. r104's evidence set is being cited from a
**tracked-visible root artifact** while the round is still landing, and the citation target moved
from `note/` (r103) to `skill/` (r104). **[O]**/**[I]**

One of the 9 is a **forward reference** — at `16:20:15` the cited `skill/author.md` did not exist
(§1.3). It was satisfied by `16:25:40`. Any scribe quoting a citation count must re-run the grep
and re-check that each target resolves. **[O]**

### 5.3 The gate receipts exist but this seat did not verify them **[O]**

`gate/` holds seven genuine artifacts (`final-run.md` SEAT-40, `flake-harness.md` + `flake_harness.sh`
SEAT-14, `pin-check.md` SEAT-45, `regression.md` SEAT-15, `workdir.md` SEAT-12,
`workdir-verify.md` SEAT-13) and 361 scratch files. The **gate state itself** — PASS/FAIL/BLOCKED,
the `POINTERS=` count, exit codes — is **not** audited here. That is a content claim belonging to
the C2 seat, and §6 says so. **[O]**

### 5.4 The two protected corpus paths that moved **[O]**

```
$ git status --porcelain
 M corpus/knowledge/unreal-mcp/gate/README.md
 M corpus/knowledge/unreal-mcp/gate/run_gate.sh
```

Both are the **C2 gate-workdir-resilience claim** (the `GATE_WORKDIR` + `TMPDIR` support the round
brief describes). They are **not** on the protected list — only
`corpus/knowledge/unreal-mcp/upstream/**` and `.manifest.d/**` are — so this is consistent, as it
was in r103. The pinned `upstream/` and `.manifest.d/` trees are byte-identical to HEAD. **[O]**

The host pressure that motivated C2 is visible in this seat's own environment:

```
$ df -h /tmp | tail -1
tmpfs  16G  13G  3.1G  80% /tmp
```

`/tmp` is an 80%-full 16 GB tmpfs — the same quota pressure r103's root cause names. **[O]**

### 5.5 The round's own scratch is on `/tmp`-adjacent storage and growing **[O]**

```
$ du -sh reports/round-104
564M
$ df -h /
/dev/mapper/root  930G  143G  771G  16% /
```

The round directory grew **156 files → 11,315 files → 564 MB** during a 9.5-minute window. Root has
headroom, but a round that can transiently hold 379,588 files is a round that can fill a disk
before anyone notices. Recorded as a capacity observation for the L1. **[O]**/**[I]**

---

## 6. What this seat did not do

- Did not modify, stage, commit, rename, or delete anything. `git status` shows only the untracked
  `reports/round-104/`, the untracked root `.r104-seat17/` and `SKILL.md`, and other seats'
  declared corpus edits — including the `corpus/fixtures/phys3d_joints.gd` edit recorded in §1.1,
  which this seat **observed and reported but did not touch**.
- Did not verify the content claims of any r104 report — **not C1** (the wall-cost fix), **not C2**
  (gate workdir resilience), **not C3** (the SKILL.md decision table). This audit covers **presence,
  naming, provenance, duplication, r101/r102/r103 immutability, and the fixture-scope check in §1.1
  only**. In particular the gate's PASS/FAIL/BLOCKED state and `POINTERS=` count are **not** audited.
- Did not adjudicate whether `corpus/fixtures/phys3d_joints.gd`'s edit is *correct* — only that it
  is the file SEAT-04's declared scope names and that `run_battery.py` stayed pinned. §1.1.
- Did not resolve whether `.r104-seat17/` (1.4 GB, 92,582 files) belongs in the lane repo. §1.2.
- Did not obtain a settled frame. The r103 tree-hash-stability standard could not be met because the
  directory outran the hash walk. §2.4.
- Did not wait for the directory to stop growing, and it did not stop. §2's last frame and §8 are
  both snapshots of a live directory; the round-close scribe must re-run §9's commands.

---

## 7. Recommendations to the L1 (advisory only — no axis claim)

1. **Exclude scratch from every future lane-wide scan.** A `find reports -exec sha256sum` now
   returns **393 phantom duplicates** and a `find reports -type f | wc -l` now returns 11,315 for a
   round with ~45 reports. Both numbers are true and both are useless. Publish the exclusion
   (`! -path '*/scratch/*' ! -path '*/s0*/*'`) or move scratch outside `reports/` entirely. **[I]**
2. **Move run scratch out of `reports/`.** `reports/` is a report set; r104 made it a build
   directory with a 13-level tree, a 742-file git checkout, and a transient of 379,588 files.
   `corpus/live/runs/` already exists for exactly this and is where the copies came from. **[I]**
3. **Sweep the two root-level objects before close.** `.r104-seat17/` (1.4 GB, untracked) and
   `SKILL.md` (untracked, and the C3 artifact itself). `git add -A` at round close would commit the
   first and the second together with the round. Decide each deliberately. **[I]**
4. **Delete the leaked `tmp.O08ANPOIb9/` and the empty `s22tmp/`.** A `mktemp -d` that outlived its
   seat is sitting at the round's top level; it is the exact failure mode the C2 claim exists to
   prevent, and it happened in C2's own round. **[I]**
5. **Decide the subdir vocabulary, as r103 asked.** r104 kept `gate/` and `physics/`, dropped
   `note/` and `b2/`, and added five names — three of which encode *who* ran rather than *what*
   it is. Either publish a fixed list or state that the names are free-form; the current state is
   neither. **[I]**
6. **Re-measure, do not quote.** Every count in this document is a snapshot of a directory that
   moved by 300,000 files between two consecutive 5-second samples. §9 carries the commands. **[I]**

---

## 8. Closing frames — after this file's measurements were taken

### 8.1 Frame `2026-10-18T16:25:59-03:00` (11,315 files) — the last sampler frame

| claim | frame | value |
|---|---|---|
| total files | `16:25:59` | **11,315** (was 156 at `16:16:32`; peaked at 379,588 at `16:21:44`) |
| top-level / `r104-*` / off-pattern | `16:25:59` | `15` / `4` / `11` |
| round-level subdirs | `16:25:59` | **8** — `physics/` (10,240), `scratch/` (469), `gate/` (368), `s22runs/` (172), `lessons-carry-loop/` (10), `skill/` (3), `s22tmp/` (2), `tmp.O08ANPOIb9/` (0) |
| total directories | `16:25:59` | **1,406** |
| tree depth | `16:25:59` | **13** |
| markdown files | `16:25:59` | `142` |
| total bytes | `16:25:59` | 552,623,165 (~527 MiB) |
| distinct digests | `16:25:43` | **2,229** of 11,292 files |
| intra-round basename dups | `16:25:59` | **1,457** |
| lane-wide basename dups | `16:25:59` | **1,480** |
| byte-dup pairs outside r104 | `16:25:59` | **0** |
| r104 files byte-identical to a tracked file | `16:24:30` | **393** (all via `gate/scratch/full-c85a816/`) |
| distinct `SEAT-NN` ids (reports only) | `16:25:40` | **46** |
| exact-path r104 citations from outside | `16:25:59` | **9** (all in root `SKILL.md`) |
| r101 / r102 / r103 dirty | `16:25:13` | `0` / `0` / `0` |
| r101 / r102 / r103 tracked | `16:25:13` | `33` / `61` / `61` |
| ledger files vs HEAD | `16:25:13` | `LOG`, `SCORECARD`, `SHONEN`, `PROVINCE` all **IDENTICAL** |
| `corpus/fixtures/run_battery.py` | `16:20:44` | `f456bd00…` — **matches the brief's pin** |
| `corpus/fixtures/phys3d_joints.gd` | `16:24:54` | **MODIFIED** (26+/7−), SEAT-04's declared scope |

**The directory was still growing when this frame was taken** — 11,283 at `16:24:59`, 11,315 at
`16:25:59`. **[O]**

### 8.2 The peak frame — `16:21:44`, **379,588 files**

This is the largest value this seat observed and it is **34x the closing frame**. It lasted under a
minute. No frame in §8.1 is a settled state, and no frame anywhere in this document should be quoted
without its timestamp. **[O]**

### 8.3 Seat → artifact map at the closing frame **[O]**

| subdir | files → seats |
|---|---|
| top level (15) | `consistency`→31 · `freshness-pin`→43 · `git-hygiene`→27 · `install-recheck`→44 · `kimi-404-carry`→47 · `ledger-check`→26 · `lessons-carry`→46 · `r104-connector`→24 · `r104-distiller`→23 · `r104-report`→35 · `r104-verification-protocol`→32 · `seats-ledger`→42 · `stub-cleanness`→28 · `subtree-integrity`→41 · `lessons-carry-gate-default-tmpdir.out`→**none** |
| `gate/` (7 reports) | `final-run`→40 · `flake-harness`→14 · `flake_harness.sh`→14 · `pin-check`→45 · `regression`→15 · `workdir`→12 · `workdir-verify`→13 |
| `skill/` (3) | `author`→18 · `bleed`→21 · `critic`→20 |
| `physics/` (6 reports + 4 captures) | `before`→02 · `ledger`→11 · `markers`→03 · `seeds`→09 · `sentinel`→08 · `author-full.stdout`→none · `before-battery*.stdout/stderr`→none |
| `lessons-carry-loop/` (10) | `run1..run10.out` → none (loop captures) |
| `scratch/`, `s22runs/`, `s22tmp/` | run artifacts, no seat marker by design |

Only raw captures lack a seat marker; **every report artifact carries one**. **[O]**

### 8.4 This document's own rule

This file is `reports/round-104/r104-scribe-audit.md`, the **fourth** `r104-*` file at the time it
was written and the **seventh** by `16:27:04`. By §2's own rule, read any digest from disk, not from
this text — and re-run §9's commands rather than quoting §8.1. **[O]**

### 8.5 Post-write frame `2026-10-18T16:27:04-03:00` (11,665 files) — supersedes §8.1

The directory kept moving while §1–§9 were being written. Measured once more:

```
$ find reports/round-104 -type f | wc -l
11665
$ find reports/round-104 -maxdepth 1 -type f | wc -l
18
$ find reports/round-104 -maxdepth 1 -type f -name 'r104-*' | wc -l
7
$ find reports/round-104 -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort
gate  lessons-carry-loop  physics  scratch  skill  tmp.O08ANPOIb9
$ for s in $(find reports/round-104 -mindepth 1 -maxdepth 1 -type d); do echo "$(basename $s)=$(find $s -type f|wc -l)"; done
gate=372  physics=10792  scratch=470  lessons-carry-loop=10  skill=3  tmp.O08ANPOIb9=0
```

| claim | frame | value |
|---|---|---|
| total files | `16:27:04` | **11,665** (was 11,315 at `16:25:59`) |
| top-level / `r104-*` | `16:27:04` | `18` / **`7`** |
| round-level subdirs | `16:27:04` | **6** — the `s22tmp/` and `s22runs/` buckets were deleted, `tmp.O08ANPOIb9/` remains |
| total directories | `16:27:04` | 1,494 |
| markdown files | `16:27:04` | 148 |
| lane-wide basename dups | `16:27:04` | 1,483 |
| byte-dup pairs outside r104 | `16:27:04` | **0** (invariant holds) |
| r101 / r102 / r103 dirty | `16:27:04` | `0` / `0` / `0`, tracked `33` / `61` / `61` |
| round dir size | `16:27:04` | 565 MB |

**The `r104-*` ratio rose from 4/15 to 7/18 in ~65 seconds** — the long close-out seats
(`r104-dissonance`, `r104-adjudicator`, and others) landed during this audit, which is the same
late adoption r102 and r103 both showed. The **subdir set shrank 8 → 6** as the two `s22*` buckets
were removed. **Neither §8.1 nor this frame is settled**; §2.4 stands. **[O]**

### 8.6 Absolute last frame `2026-10-18T16:27:41-03:00` (6,189 files) — the round began draining

The count **fell by 47%** in 37 seconds after §8.5, and this seat stopped measuring here:

```
$ find reports/round-104 -type f | wc -l
6189
$ find reports/round-104 -maxdepth 1 -type f | wc -l
19
$ find reports/round-104 -maxdepth 1 -type f -name 'r104-*' | wc -l
7
$ for s in $(find reports/round-104 -mindepth 1 -maxdepth 1 -type d); do echo "$(basename $s)=$(find $s -type f|wc -l)"; done
gate=372  physics=5291  scratch=471  lessons-carry-loop=10  skill=3  tmp.O08ANPOIb9=0
$ find reports/round-104/gate/scratch/full-c85a816 -type f | wc -l
0
$ du -sh reports/round-104
217M
```

| claim | frame | value |
|---|---|---|
| total files | `16:27:41` | **6,189** (was 11,665 at `16:27:04`; 379,588 at the `16:21:44` peak) |
| top-level / `r104-*` | `16:27:41` | `19` / `7` |
| round-level subdirs | `16:27:41` | 6 |
| total directories | `16:27:41` | 897 |
| round dir size | `16:27:41` | **217 MB** (was 565 MB) |
| r104 ↔ rest byte-identical files | `16:27:41` | **0** — the clone is gone (§4.3.1) |
| byte-dup pairs outside r104 | `16:27:41` | **0** |
| r101 / r102 / r103 dirty | `16:27:41` | `0` / `0` / `0`, tracked `33` / `61` / `61` |
| ledger files vs HEAD | `16:27:41` | all four **IDENTICAL** |
| `corpus/fixtures/run_battery.py` | `16:27:41` | `f456bd00…` — **still pinned** |

**This seat has now recorded eight successive "closing" states** (156, 11,315, 379,588, 7,951,
11,665, 6,189, and the intermediate frames of §2) and **every one was overtaken**. The directory
spent the last three minutes of observation *shrinking* as seats deleted their scratch — the round
is draining rather than settling, which is a different end-state from r102's and r103's monotone
climb. The structural findings that held at **every** frame — r101/r102/r103 immutability, the
ledger files, the `run_battery.py` pin, zero byte-duplicate pairs outside r104, tree depth 13, and
the ~45-report / ~11,000-scratch-file split — are the parts of this audit that are safe to quote.
The **counts are not**. **[O]**


---

## 9. Reproducing this audit

```
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
git rev-parse HEAD                                        # expect 88c3b2c…
git status --porcelain reports/round-101 reports/round-102 reports/round-103   # expect empty
git ls-files reports/round-101 | wc -l                    # expect 33
git ls-files reports/round-102 | wc -l                    # expect 61
for f in LOG.md SCORECARD.md SHONEN.md PROVINCE.md; do
  wt=$(git hash-object -- "$f"); hd=$(git rev-parse "HEAD:$f"); \
  echo "$f $([ "$wt" = "$hd" ] && echo IDENTICAL || echo DIFFER)"; done     # expect 4× IDENTICAL
git diff --stat HEAD -- corpus/fixtures/                  # expect phys3d_joints.gd only
sha256sum corpus/fixtures/run_battery.py                  # expect f456bd00…
find reports/round-104 -type f | wc -l                    # moving; peaked at 379588, ~11k at close
find reports/round-104 -maxdepth 1 -type f | wc -l        # expect 15
find reports/round-104 -maxdepth 1 -type f -name 'r104-*' | sort   # expect 4
find reports/round-104 -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort   # expect 8
find reports/round-104 -type d | awk -F/ '{print NF}' | sort -rn | head -1     # expect 13
find reports/round-104 -type f -exec sha256sum {} \; | awk '{print $1}' | sort -u | wc -l  # expect ~2200
find reports/round-104 -type f -printf '%f\n' | sort | uniq -d | wc -l         # expect ~1450
find reports -type f ! -path 'reports/round-104/*' -exec sha256sum {} \; \
  | awk '{print $1}' | sort | uniq -d | wc -l                                  # expect 0
find reports/round-104 -type f -exec sha256sum {} \; | sort | awk '{print $1}' | uniq -d | wc -l
grep -rn "reports/round-104" --include='*.md' --include='*.sh' . \
  | grep -v '^./reports/round-104/' | grep -v '^./.r104-seat17/' | wc -l        # expect 9
```

**The file count is the one number that will not reproduce** (§2), and it can move by 300,000
between two samples. Every count in this report is stamped with the time it was observed. **[O]**

---

No Unreal runtime claim is made anywhere in this document. The Unreal Editor and UnrealBuildTool
are not installed on this host; the r101–r103 subtrees and the r104 clones of them are treated as
file bytes only, and nothing here proves plugin load, compilation, or engine runtime behaviour.
