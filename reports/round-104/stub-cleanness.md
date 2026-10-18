# r104 stub-cleanness — placeholder/stub scan of the round's artifacts

**Seat:** SEAT-28 STUB-CLEANNESS · round 104 · lane `game-dev-3d-shokunin`
**Owned path written:** this file only (`reports/round-104/stub-cleanness.md`). No `git` mutating
command was run.
**Lane HEAD at every frame below:** `88c3b2ca70fc83ec47a931d7b6dcff85a111c04e` (*"r103 report-last:
verdict … — work `8c9d9ad`"*). HEAD did not move during this seat's window.
**Primary scan frame:** `2026-10-18T16:28:25-03:00` (local), **1 210 lane-authored files** (§1).
**Scope:** scan the r104 artifacts for placeholder/stub text — `TODO`, `TBD`, `{{…}}`, `placeholder`,
`XXX`, `FIXME` — and list every hit as `file:line`.

---

## 0. Verdict

**No stub defect found.** Every token hit in the lane-authored r104 surface falls into one of three
classes, and there is **no Class D**:

- **(A) expected — the round-close report draft's declared slots.** `reports/round-104/r104-report.md`
  carries **33 `{{…}}` slots** (`{{R104_COMMIT}}`, `{{C1_FULL_BATTERY}}`, `{{RULING_C1}}`, …), whose
  contract the file states verbatim at `:9–10`: *"to be filled at round close; the L1 lands one commit
  and this report is the last artifact to land."* Exactly the Class-A population r102 and r103 each
  found in their round's report draft.
- **(B) prose, status vocabulary, and *discussants quoting this seat's token list*.** `pending` as an
  ordinary word (3 hits); `placeholder` as an ordinary word (3 hits); and the strict six appearing only
  because **three other r104 seats are auditing this very report and quoting its token list verbatim** —
  `math-audit.md:201,208`, `r104-report.md:151`, `consistency.md:497`. That relationship is the r102
  precedent (`reports/round-102/stub-cleanliness.md` §2, `adversary/F2.md:155`: "discussant, not
  source").
- **(C) false positive — the `XXXXXX` run of `mktemp(1)` templates** inside pasted shell transcripts:
  `gate/flake_harness.sh` (4), `skill/author.md` (7), `gate/close-runs.md` (2), `gate/pin-check.md` (1),
  plus the audit rows that cite them. In all four transcript files the token is **0** word-level.

Summary of the authored surface (1 210 files at the primary frame): **3** word-bound strict hits, all
discussants; **33** Class-A report slots (of 37 `{{…}}` hits total); **27** `XXX` substring hits, 24 of
them `mktemp` templates and 3 the discussants naming the token; **3** word-level `pending`; **3**
word-level `placeholder`; **0** `TODO`/`TBD`/`FIXME`/`WIP`/`PLACEHOLDER` standing as a word.

**Zero** word-boundary `TODO`, `TBD`, `FIXME`, `WIP` or `PLACEHOLDER` stands as a word in any
lane-authored r104 file **except where a seat is quoting the token list to audit this scan**. Every such
line names `stub-cleanness.md` on the same line. The same shape as
`reports/round-102/stub-cleanliness.md` §0 and `reports/round-103/stub-cleanness.md` §0, re-derived
rather than carried over.

Two r104-specific things forced method changes, both in §1: the artifact tree is **dominated by copies**
(raw grep is meaningless), and the round **never stopped landing** — `r104-report.md` did not exist at
this seat's first frames, and one Class-B hit resolved itself mid-round (§2.5).

## 1. Method — and the two things that make r104 different

Token sets (identical to r102/r103):

- **A — strict:** word-boundary `\b(TODO|TBD|FIXME|XXX|WIP|PLACEHOLDER)\b`.
- **B — `{{…}}` template slot:** `\{\{[^}]*\}\}`.
- **C — seat-spec literal list (substring, case-insensitive):** `TODO|TBD|\{\{[^}]*\}\}|placeholder|XXX|FIXME`.
- **D — seat-spec list plus `pending` (word-level).**

### 1.1 The scope problem: the tree is dominated by copies

The round ran the physics battery and the gate *inside `reports/round-104/`*, so the artifact tree is
mostly copies of things that already exist elsewhere:

| class | what it is | files @ `16:28:25` |
|---|---|---|
| **authored** | text/scripts/logs the round's seats produced | **1 210** |
| **clone / scratch / vendored** | whole-repo `git clone`s (of this lane *and* upstream), `node_modules`, and scratch under `gate/scratch/`, `scratch/`, `seat33-loop/`, `lessons-carry-loop/`, `s22tmp/`, `s22runs/`, `tmp.*` | ~5 000 |
| **fixturecopy** | byte-identical copies of `corpus/fixtures/**` | (see §3.1) |

A raw `grep -r` over `reports/round-104/` at `16:28:43` returns **2 174** seat-spec substring hits and
**727** strict word-bound hits — **and every one is a vendored third-party source, an upstream EpicGames
clone, a clone of this lane (which contains the r101/r102 stub reports, quoting every token name), a
`node_modules` tree, or a byte-identical copy of the lane's own fixture corpus.** Reporting any of them
as an r104 defect would be a false positive by construction, exactly as
`reports/round-103/stub-cleanness.md` §4 reasoned about `three/node_modules`.

The raw counts are also **unstable on a minute timescale**. The tree went `173 → 11 773 → 6 463` files
during this seat's window, once because a seat cloned the lane *recursively* (`scratch/s20-skel3/`, a
clone inside a clone, peaked near 259 000 files before its owner deleted it). A single raw count is
stale on arrival; §6 records the series.

### 1.2 The classifier

A **content test, not a path test**:

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
export TMPDIR=~/.cache/s28/tmp     # /tmp is unusable — §7
C=~/.cache/s28

find corpus/fixtures -type f -exec sha256sum {} + | awk '{print $1}' | sort -u > $C/fx.h
find reports/round-104 -type f | sort > $C/all.txt
: > $C/authored.txt
while IFS= read -r f; do
  case "$f" in
    reports/round-104/gate/scratch/*|reports/round-104/scratch/*|reports/round-104/seat33-loop/*|\
    reports/round-104/lessons-carry-loop/*|reports/round-104/s22tmp/*|reports/round-104/s22runs/*|\
    reports/round-104/tmp.*) continue;;
    */node_modules/*) continue;;
  esac
  h=$(sha256sum "$f" | awk '{print $1}')
  grep -qxF "$h" $C/fx.h || echo "$f" >> $C/authored.txt
done < $C/all.txt
grep -v 'stub-cleanness' $C/authored.txt > $C/authored.noself
```

A file is **authored** iff its sha256 is not the sha256 of any file under `corpus/fixtures/`. This is the
right discriminator because the fixture copies are **bit-exact**: `physics/s06/conc/README.md` and
`physics/s06/serial/README.md` hash to `347e0d1e5e4efca9c6f8b93440370352278bb30f3c1f62cee19edd3704619cb1`,
identical to `corpus/fixtures/README.md`, and all three copies of `run_battery.py` hash to the pinned
`f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`. A file that is byte-for-byte the
seed cannot be an unfinished r104 artifact.

Two path exclusions are **necessary and were added mid-run**, both measured:

- **`gate/scratch/`, `scratch/`, `seat33-loop/`, `lessons-carry-loop/`, `s22tmp/`, `s22runs/`, `tmp.*`**
  hold whole-repo clones. Their contents are *other rounds' artifacts and vendored upstream files*, and
  a clone of the lane contains the r101/r102 stub reports themselves — so hashing them against the
  fixture set would misclassify every lane file inside as "authored".
- **`*/node_modules/*`** is vendored dependency code (`physics/nc/three/node_modules/…`). It is
  gitignored by `physics/nc/three/.gitignore:1` (verified: `git check-ignore -v` → that line), so it is
  not a tracked surface, and its hundreds of JSDoc `{{…}}` type literals are not template slots. This is
  the r103 §4 reasoning, recurring at r104 in a new location.

**Self-match:** as at r102/r103, this file quotes the token names and self-matches any rescan; all
reported counts exclude it, and the exclusion is a measured necessity (§5).

## 2. Every hit in the lane-authored surface, with `file:line`

Frame `2026-10-18T16:28:25-03:00`, 1 210 authored files. **A** = expected (round-close slot) ·
**B** = legitimate prose / status / discussant quoting the scan · **C** = false positive (substring).
No hit was **D**.

### 2.1 Strict six, word-bound (command A): 3 hits — all **B**, all discussants

| `file:line` | token | class | verbatim context (trimmed) |
|---|---|---|---|
| `math-audit.md:201` | `TODO`…`PLACEHOLDER` | **B** | audit row 90: `` `SKILL.md` carries no stub token and no `{{…}}` slot \| `stub-cleanness.md` §0 \| `grep -nE '\b(TODO\|TBD\|FIXME\|XXX\|WIP\|PLACEHOLDER)\b' SKILL.md'` `` |
| `math-audit.md:208` | `XXX` | **B** | audit row 92: `` `flake_harness.sh`'s `mktemp -d "${TMPDIR:-/tmp}/flake-harness.XXXXXX"` is the `XXX` substring hit \| §0 (C) `` |
| `r104-report.md:151` | `TODO`…`PLACEHOLDER` | **B** | "`stub-cleanness.md` (zero word-boundary `TODO`/`TBD`/`FIXME`/`XXX`/`WIP`/`PLACEHOLDER`; 1 prose hit…)" |

Every line is a **quotation of this seat's own token list**, made by another seat auditing this scan, and
each names `stub-cleanness.md` on the same line. **The strict six never stand as a stub anywhere in the
round's own text.** This is the r102 §2 "discussant, not source" relationship, now occurring three times.

### 2.2 Command B — `{{…}}` template slots: 37 hits in 4 files

| file | slots | class | what they are |
|---|---|---|---|
| `r104-report.md` | **33** | **A** | the round-close slots, declared at `:9–10` and `:37` |
| `math-audit.md:201,211` | 2 | **B** | audit rows 90/95 quoting the slot to check it |
| `consistency.md:487` | 1 | **B** | prose: "The r104 report's own `{{C1_FULL_BATTERY}}` slot is the honest **placeholder**" |
| `r104-dissonance.md:507` | 1 | **B** | prose: "(the 350-row `{{C1_FULL_BATTERY}}` count does not exist yet at `19:26Z`)" |

`r104-report.md`'s 33 slots, verbatim from `grep -oE '\{\{[^}]*\}\}'`:

```
{{R104_COMMIT}} ×8   {{C1_FULL_BATTERY}} ×6   {{C1_NONAUTHOR_VERIFIER}} ×3   {{C3_NONAUTHOR_VERIFIER}} ×3
{{C1_WORSTCASE}} ×2  {{V_DEPTH}} {{V_COVERAGE}} {{V_CALIBRATION}} {{…}}
{{RULING_C1}} {{RULING_C2}} {{RULING_C3}} {{RULING_FLAKE}} {{RULING_BLOCKED_LABEL}} {{RULING_SKILL_SCOPE}}
```

**Class A.** `:9–10` states the contract in full, and `:37` declares the convention (*"Numbers marked
`{{…}}` are round-close slots this scribe cannot measure"*). The other three files' hits are Class B —
prose and audit rows *about* those slots, not slots of their own.

**Timing note, because it changes the verdict's population.** At the `16:19:02` frame there was **no
`r104-report.md`** (`ls reports/round-104/*report*.md` → rc=2) and the Class-A population was **empty**.
The draft landed at ~`16:22` and grew `493 → 562 → 585 → 647 → 656` lines across the frames this seat
measured, its slot count rising `26 → 32 → 31 → 33`. The 33 slots are a *late* arrival, not a stable
property; a rescan before the draft lands finds zero.

### 2.3 Command C — `XXX` substring: 27 hits in 6 files; the 24 `mktemp` hits are **0** word-level

| `file:line` | `XXX` runs | class | verbatim context (trimmed) |
|---|---|---|---|
| `gate/flake_harness.sh:98` | 2 | **C** | `_cand=$(mktemp -d "$_base/flake-harness.XXXXXX" 2>/dev/null) \|\| _cand=` |
| `gate/flake_harness.sh:139` | 2 | **C** | `_probe=$(mktemp "$PROBE_ROOT/probe.XXXXXX" 2>/dev/null) \|\| _probe=` |
| `skill/author.md:86` | 2 | **C** | `$ T=$(mktemp -d /tmp/r104s18.XXXXXX); cp -r corpus/knowledge/unreal-mcp "$T/sub"` |
| `skill/author.md:308` | 3 | **C** | `mktemp: failed to create file via template '<unwritable>/tmp.XXXXXXXXXX': Permission denied` |
| `skill/author.md:310` | 2 | **C** | `$ timeout 180 git clone --quiet <upstream-url> /tmp/r104clone.XXXXXX/clone` |
| `gate/close-runs.md:211` | 2 | **C** | `GW=$(mktemp -d "$PWD/.gate-work.XXXXXX")` |
| `gate/pin-check.md:397` | 1 | **C** | `GATE_WORKDIR=$(mktemp -d /var/tmp/gate.XXXX) bash corpus/knowledge/unreal-mcp/gate/run_gate.sh \` |
| `math-audit.md:201,207,208,338` | 12 | **B/C** | audit rows quoting `XXX` as a token name and citing the `mktemp` templates above |
| `r104-report.md:151` | 1 | **B** | the report draft quoting this seat's token list (§2.1) |

`placeholder`, `TODO`, `TBD`, `FIXME` contribute **0** substring hits outside the discussion of this
scan. **The discriminator holds exactly where it matters:** `grep -nwE 'XXX'` over the four
transcript files (`flake_harness.sh`, `pin-check.md`, `close-runs.md`, `skill/author.md`) returns
**nothing** — in every `mktemp` transcript the token is a substring of a template, never a word. The
only 3 word-level `XXX` in the authored surface are `math-audit.md:201,208` and `r104-report.md:151`,
i.e. the same discussants of §2.1 writing the token's *name* while auditing this scan. There is no
file in which `XXX` stands as a placeholder.

This is the same `mktemp`-template artefact r103 catalogued 13 times, and it is *expected* at r104: the
C2 mandate is precisely to make gate/harness scratch honour `TMPDIR`/`GATE_WORKDIR`, and a harness that
does so must create its directories with `mktemp`. Three of the files are the C2 seats' own evidence
transcripts, and `pin-check.md:397` shows the fix in use (`GATE_WORKDIR=$(mktemp -d /var/tmp/gate.XXXX)`).

### 2.4 Command D — `pending`, word-level: 3 hits, all **B**

| `file:line` | class | verbatim context (trimmed) |
|---|---|---|
| `consistency.md:81` | **B** | "subtree `README.md` layout block stale `(pending: …)` labels \| **CARRIED** (closed r101) \| `grep -n 'pending' …` → 1 hit at `:69`, and it is the unrelated engine-install wall" |
| `r104-distiller.md:27` | **B** | "…`SKILL.md` 174→182 lines …; box 1 still `[ ]` **pending** a non-author verifier" |
| `r104-report.md:615` | **B** | "Engine install is blocked **pending** operator Epic-account linking" |

All three are complete sentences or table cells carrying meaning: a *closed* check recorded as carried, a
live verification status, and the standing engine-install prose r102 §4 / r103 §3 already classified.

### 2.5 One Class-B hit that resolved itself mid-round

At the `16:19:02` frame the single authored hit was `physics/seeds.md:116`:

```
**STATUS: PENDING — the C1 patch had not landed at extraction time.**
```

At `16:20:56` `grep -nw PENDING reports/round-104/physics/seeds.md` returned **rc=1** — the line was
gone. The file's §4 now reads `**STATUS: LANDED and verified.**` The C1 patch (R3 concurrent children)
landed inside `corpus/fixtures/phys3d_joints.gd` — SEAT-04's declared scope — and the owning seat
updated its status in the same window. So this hit was Class B *and* self-resolving: a marker that
correctly tracked a real dependency and was cleared by its owner. Recorded because it was the one
Class-B hit of the early frames, and its disappearance is itself evidence the round was healthy.

### 2.6 `placeholder` and `stub`: 3 and 0

`placeholder` word-level → **3** hits, all Class B: `consistency.md:497` ("the honest **placeholder**" —
prose about the report's slot), `math-audit.md:201` (audit row quoting the token), `r104-report.md:151`
(quoting this seat). `\bstubs?\b` → **0**. No r104 artifact uses `placeholder` to stand in for content.

## 3. The excluded classes, and why each is excluded

### 3.1 `fixturecopy` — byte-identical copies of `corpus/fixtures/**`

The physics seats re-run the battery, and `run_battery.py`'s own contract — verbatim in the seed
`README.md`: *"`run_battery.py` copies the directory into `corpus/live/runs/<ts>/scratch` and executes
only the copy"* — means each run materialises a scratch tree. SEAT-06 additionally ran each
`phys3d_joints` arm against **two deliberately byte-different trees** (`serial` = HEAD bytes, `conc` =
HEAD + R3 spawn/collect) to prove stream identity, and kept both; later frames added `s06/err/`,
`s06/seat04/`, `physics/author-runs*/` and `physics/nc*/` variants.

Verified by `diff -rq corpus/fixtures <root>` → only `Only in corpus/fixtures: __pycache__`,
`Only in corpus/fixtures/three: node_modules`, plus the intended `phys3d_joints.gd` variants. Their hits
are the fixture corpus's own prose — e.g. `phys3d_events.gd:218` ("Jolt placeholders imass 1 + zero
inertia + identity tensor"), `run_battery.py:485` (the literal expected PASS string
`…st=zeros,placeholders child_exit=0`), `navagent3d_detour.gd`'s `PhysMutator.pending` API (a real
variable name), `bpy_sync_probe.py`'s "pending RNA write" measurement vocabulary.
**`corpus/fixtures/**` is write-protected this round and this seat wrote nothing in it or its copies.**

### 3.2 Clones, scratch, and `node_modules`

Whole-repo clones of **this lane at HEAD** (`git -C … rev-parse HEAD` → `88c3b2ca…`) plus clones of the
upstream EpicGames repo. Their hits are:

- **`git`'s own hook samples** — `pre-push.sample` ("with `WIP` (work in progress)"),
  `sendemail-validate.sample` (4 × `TODO`). Stock `git init` templates.
- **Vendored third-party sources** — `three.core.js`, `three.module.js`, `cannon-es.js`, a `pybullet`
  `.so`, and the `nc*/three/node_modules` trees. The `{{…}}` hits are JSDoc type literals
  (`@type {{data:TypedArray,width:number,…}}`), not template slots.
- **Prior rounds' own artifacts** — including `reports/round-102/stub-cleanliness.md` and
  `reports/round-101/r101-report.md` *inside the clone*. A clone of the lane contains **the earlier
  stub-cleanliness reports themselves**, which quote every token name verbatim; a raw recursive grep
  therefore reports the r102 report's own quotations as r104 hits. That is the single strongest argument
  for the §1 classifier.
- **The lane's own corpus** (`corpus/knowledge/unreal-mcp/**`, `corpus/lessons/**`, `LOG.md`,
  `SCORECARD.md`) — the r101 `pending operator Epic-account linking` prose and the r69–r99 scribe
  reports' `pending` status vocabulary, all classified at r102 §4 / r103 §3.

## 4. Three observations for the L1, outside this seat's scope

None is a stub defect; each is recorded because a stub-cleanliness seat is the one that reads the whole
surface.

1. **`reports/round-104/` is not gitignored and peaked at 566 MB / 11 773 files**, of which the large
   majority were clones, scratch and fixture copies. `corpus/.gitignore:1` is `live/`, which is why the
   equivalent `corpus/live/runs/<ts>/scratch` trees never entered `git status`; the r104 equivalents
   **do** appear as untracked. Whether they are committed, deleted, or ignored at round close is the
   L1's call; this seat neither wrote nor removed any of them.
2. **A recursive clone appeared and was cleaned up mid-round.** `reports/round-104/scratch/s20-skel3/`
   peaked near 259 000 files (a clone of the lane inside the lane's own report tree); its owner removed
   it before the `16:22:17` frame. Worth a glance at round close that no such tree survives into the
   commit.
3. **`/tmp` quota pressure struck this seat twice** (§7), and the round's own artifacts document the
   same failure independently: `skill/author.md:308–310` records `mktemp` failing with `Permission
   denied` and `git clone` failing with `Disk quota exceeded`, and `gate/workdir-verify.md` calls it
   *"the r103 root cause reproducing **during r104**"*. That is in-round corroboration for C2 from a seat
   that is not this one.

## 5. Reproduce

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
export TMPDIR=~/.cache/s28/tmp     # NOT /tmp — §7
C=~/.cache/s28

find corpus/fixtures -type f -exec sha256sum {} + | awk '{print $1}' | sort -u > $C/fx.h
find reports/round-104 -type f | sort > $C/all.txt
: > $C/authored.txt
while IFS= read -r f; do
  case "$f" in
    reports/round-104/gate/scratch/*|reports/round-104/scratch/*|reports/round-104/seat33-loop/*|\
    reports/round-104/lessons-carry-loop/*|reports/round-104/s22tmp/*|reports/round-104/s22runs/*|\
    reports/round-104/tmp.*) continue;;
    */node_modules/*) continue;;
  esac
  h=$(sha256sum "$f" | awk '{print $1}')
  grep -qxF "$h" $C/fx.h || echo "$f" >> $C/authored.txt
done < $C/all.txt
grep -v 'stub-cleanness' $C/authored.txt > $C/authored.noself

# A. strict six, word-bound — expect ONLY the three discussant lines of §2.1
while read -r f; do grep -nwE 'TODO|TBD|FIXME|XXX|WIP|PLACEHOLDER' "$f"; done < $C/authored.noself

# B. {{...}} slots — expect r104-report.md (33) plus the three prose/audit files of §2.2
while read -r f; do grep -nE '\{\{[^}]*\}\}' "$f"; done < $C/authored.noself
grep -oE '\{\{[^}]*\}\}' reports/round-104/r104-report.md | wc -l      # 33

# C. the brief's literal list, substring — expect the §2.3 table
while read -r f; do grep -noiE 'TODO|TBD|\{\{[^}]*\}\}|placeholder|XXX|FIXME' "$f"; done < $C/authored.noself

# D. pending / placeholder word-level — expect the §2.4 + §2.6 lines
while read -r f; do grep -nwiE 'pending|placeholder' "$f"; done < $C/authored.noself

# E. the false positives, disambiguated by word boundary — expect NO output, rc=1
grep -nwE 'XXX' reports/round-104/gate/flake_harness.sh reports/round-104/gate/pin-check.md \
  reports/round-104/gate/close-runs.md reports/round-104/skill/author.md

# F. the classifier's premise: a fixture copy IS the seed, byte for byte
sha256sum corpus/fixtures/run_battery.py \
  reports/round-104/physics/s06/conc/run_battery.py \
  reports/round-104/physics/s06/serial/run_battery.py
# all three → f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f

# G. the node_modules exclusion is a gitignore fact, not a guess
git check-ignore -v reports/round-104/physics/nc/three/node_modules/three/build/three.core.js
```

This file self-matches commands A–D (it quotes every token name), so `authored.noself` excludes it —
a **measured necessity**, not a precaution. At the `16:29:47` frame the raw form of command C over all of
`reports/round-104/` returns **2 174** hits while the authored-and-self-excluded form returns **74**
(and the 27 `XXX` + 37 `{{…}}` of §2.2–2.3 account for 64 of those). Any rescan must keep both
exclusions or it will report the scanner as the defect.

## 6. Frame series — the round never stopped landing

`reports/round-104/` grew from **173 files** at this seat's first frame to a **253 688-file** peak (a
recursive clone) and settled near **6 500** by the last, still rising. Sampled every 20 s early, then per
classifier pass; log at `~/.cache/s28/frames.log`.

| frame | total files | authored | raw substring | raw strict | authored hits (excl. this file) |
|---|---|---|---|---|---|
| `16:16:50` | 173 | — | — | — | 0 |
| `16:18:18` | 1 661 | 713 | — | — | 0 |
| `16:19:02` | 1 754 | 280 | — | — | 2 — `seeds.md:116` + `flake_harness.sh:61` |
| `16:19:47` | 1 754 | — | 617 | 141 | authored strict **0** |
| `16:20:56` | ~4 000 | 671 | — | — | `seeds.md:116` **gone** (§2.5) |
| `16:21:29` | 5 966 | 1 115 | — | — | clone-class hits only |
| `16:22:17` | **253 688** | 1 015 | — | — | recursive-clone peak |
| `16:23:04` | 7 917 | 1 178 | — | — | 2 — report draft `:128,527` |
| `16:24:07` | 10 525 | 1 381 | 4 444 | 1 221 | 3 — §2.4 (early form) |
| `16:28:25` | 6 463 | **1 210** | 2 174 | 727 | **§2 (final form)** |

Readings:

- The **swings** are all copies materialising and being cleaned up — SEAT-06's `serial`/`conc` trees, the
  gate seats' clone probes, the recursive clone, the `node_modules` installs. That is why raw counts move
  by an order of magnitude while the authored verdict stays at a handful of Class-A/B/C hits.
- `seeds.md:116` **disappeared** at `16:20:56` when its owner marked the C1 patch landed (§2.5), and
  `r104-report.md` **appeared** at ~`16:22` bringing the Class-A slots (§2.2). Later, three audit seats
  began quoting this report's token list (§2.1). All three are real changes in the round, correctly
  reflected — not scan noise.
- **Snapshot, not final state.** Files landing after `16:28:25` are not covered. Re-run §5 at round close.

## 7. Boundaries

- **No Unreal runtime claim.** This scan is text-only over markdown, shell, Python, GDScript and JSON.
  Unreal Editor is not installed on this host; nothing here speaks to live-MCP or editor behaviour.
- **Read-only.** This seat wrote exactly one file, `reports/round-104/stub-cleanness.md`. No `git`
  mutating command was run. No byte-pinned or protected path (`LOG.md`, `SCORECARD.md`, `SHONEN.md`,
  `PROVINCE.md`, `corpus/fixtures/**`, `reports/round-101/**`, `reports/round-102/**`,
  `reports/round-103/**`, `corpus/knowledge/unreal-mcp/upstream/**`, `.manifest.d/**`) was modified.
  `corpus/fixtures/phys3d_joints.gd` did become modified during this window — by SEAT-04, whose declared
  scope it is, not by this seat.
- **`/tmp` was unusable for scratch, twice.** One classifier pass died with
  `sort: write failed: 'standard output': Disk quota exceeded`; a later pass died inside `sort` itself
  (`sort: write failed: /tmp/sortTBAk9a: Disk quota exceeded`). All scratch moved to `~/.cache/s28/`
  with `TMPDIR` exported. This affected only where this seat's own scratch lived, never what it read —
  and it is independent in-round evidence for C2 (§4.3).
- **Line numbers drift.** The round was live-mutating; the `file:line` values in §2 are stamped to
  `2026-10-18T16:28:25-03:00` with per-file sha256s in §2. A rescan after further landings should expect
  the same *tokens* at shifted lines, not different tokens. `r104-report.md` alone grew
  `493 → 562 → 585 → 647 → 656` lines across this seat's frames.
