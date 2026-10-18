# r103 stub-cleanliness — placeholder/stub scan of the round's artifacts

**Seat:** SEAT-41 STUB-CLEANNESS · round 103 · lane `game-dev-3d-shokunin`
**Owned path written:** this file only (`reports/round-103/stub-cleanness.md`). No `git` mutating
command was run.
**Lane HEAD at every frame below:** `c85a816e227984272a3c29b58aa7f7c1a76f1e9c`
(*"r102 report-last: verdict … — work `c6f655d`"*). HEAD did not move during this seat's window.
**Final scan frame:** `2026-10-18T15:47:27-03:00` (local), **58 files** under `reports/round-103/`
(1.2 MB). The token counts below are identical at the `15:46:46` frame (56 files) and at this
confirmation frame — see §6.1.
**Scope:** scan the r103 artifacts for placeholder/stub text — `TODO`, `TBD`, `{{…}}`, `placeholder`,
`XXX`, `FIXME` — and list every hit as `file:line`. The round-close report draft's declared commit
slot is expected by this seat's brief; anything else that reads as a left-unfinished artifact is a
defect.

---

## 0. Verdict

**No stub defect found.** Every token hit in the r103 surface is one of:

- **(A) expected** — the round-close report draft's declared `{{R103_COMMIT}}` slot, 8 hits, all in
  `reports/round-103/r103-report.md`, the one file whose brief-anticipated job is to carry a
  round-close slot;
- **(B) prose** — the ordinary English word `pending` used as status vocabulary inside complete
  sentences, 8 word-level hits;
- **(C) false positive** — the literal substring `XXX` inside `mktemp(1)` templates
  (`tmp.XXXXXXXXXX`), 13 substring hits, **0** word-level.

There is **zero** word-boundary occurrence of `TODO`, `TBD`, `FIXME`, `XXX`, `WIP` or `PLACEHOLDER`
anywhere in `reports/round-103/**`, in the r103-modified corpus deliverables
(`gate/run_gate.sh`, `gate/README.md`, `adaptation-kimi.md`, the three artifact READMEs), or in the
new `corpus/fixtures/three/node_modules` tree's tracked surface. `{{…}}` template syntax occurs in
exactly **one** r103 file, and it is the report draft.

This is the same shape as the r102 verdict (`reports/round-102/stub-cleanliness.md` §0), and it was
re-derived here rather than carried over.

## 1. Method

Four token sets were scanned, over two scopes.

- **A — strict (unambiguously stub text):** word-boundary `\b(TODO|TBD|FIXME|XXX|WIP|PLACEHOLDER)\b`.
  `grep -w` makes `XXXXXX` in a `mktemp` template a non-match, which is the discriminator that
  matters most on this round's surface.
- **B — `{{…}}` template slot:** `\{\{[^}]*\}\}`.
- **C — seat-spec literal list (case-insensitive substring):** `TODO|TBD|\{\{[^}]*\}\}|placeholder|XXX|FIXME`.
  This is the brief's literal list, and it is *substring* matching, so it necessarily collects the
  `mktemp` template hits; they are classified, not suppressed.
- **D — seat-spec list plus `pending`:** the r102 seat's superset, kept for comparability with the
  prior round's table.

Every scan over `reports/round-103/**` is run with `--exclude=stub-cleanness.md`, because this file
quotes the token names in its own prose and therefore self-matches (§5). The reported counts are the
self-excluded ones.

Scope 1 is `reports/round-103/**` (the round's artifacts). Scope 2 is every tracked file this round
modified or added outside `reports/round-103/`, taken from `git status --porcelain -uall`.

Commands actually run and their observed output are in §2–§5. Because the round was still landing
for most of this seat's runtime, §6 records the frame series.

## 2. Every hit, with `file:line` and classification

Frame `2026-10-18T15:46:46-03:00`, 56 files. **A** = expected (round-close report slot) ·
**B** = legitimate prose, not a stub · **C** = false positive (substring match). No hit was **D**
(unexpected stub defect).

### 2.1 Strict — `{{…}}` template slots (command B): 8 hits, all one file

```sh
$ grep -rnE '\{\{[^}]*\}\}' reports/round-103/
reports/round-103/r103-report.md:8:**Landing commit:** `{{R103_COMMIT}}` — *to be filled at round close; the L1 lands one commit and
reports/round-103/r103-report.md:29:`{{R103_COMMIT}}`.
reports/round-103/r103-report.md:32:Numbers marked `{{…}}` are round-close slots this scribe cannot measure; every other number below was
reports/round-103/r103-report.md:89:Each row is tied to its r103 artifact and the commit that carries it (`{{R103_COMMIT}}` for
reports/round-103/r103-report.md:117:`{{R103_COMMIT}}`; a number that does not reproduce there is a FAIL for its claim.
reports/round-103/r103-report.md:361:Run from the lane root, on `{{R103_COMMIT}}`, after the untracked artifacts are committed:
reports/round-103/r103-report.md:415:1. **`{{R103_COMMIT}}`** — this report is written pre-landing; the hash slot and every round-close
reports/round-103/r103-report.md:474:*To be filled at round close by the L1, after the work commit lands as `{{R103_COMMIT}}` and this
```

| `file:line` | token | class | verbatim context (trimmed) |
|---|---|---|---|
| `reports/round-103/r103-report.md:8` | `{{R103_COMMIT}}` | **A** | "**Landing commit:** `{{R103_COMMIT}}` — *to be filled at round close; the L1 lands one commit and this report is the last artifact to land.*" |
| `reports/round-103/r103-report.md:29` | `{{R103_COMMIT}}` | **A** | "…must be re-measured at `{{R103_COMMIT}}`." |
| `reports/round-103/r103-report.md:32` | `{{…}}` | **A** | "Numbers marked `{{…}}` are round-close slots this scribe cannot measure…" |
| `reports/round-103/r103-report.md:89` | `{{R103_COMMIT}}` | **A** | "Each row is tied to its r103 artifact and the commit that carries it (`{{R103_COMMIT}}`…)" |
| `reports/round-103/r103-report.md:117` | `{{R103_COMMIT}}` | **A** | "`{{R103_COMMIT}}`; a number that does not reproduce there is a FAIL for its claim." |
| `reports/round-103/r103-report.md:361` | `{{R103_COMMIT}}` | **A** | "Run from the lane root, on `{{R103_COMMIT}}`, after the untracked artifacts are committed:" |
| `reports/round-103/r103-report.md:415` | `{{R103_COMMIT}}` | **A** | "1. **`{{R103_COMMIT}}`** — this report is written pre-landing; the hash slot…" |
| `reports/round-103/r103-report.md:474` | `{{R103_COMMIT}}` | **A** | "*To be filled at round close by the L1, after the work commit lands as `{{R103_COMMIT}}`…*" |

`reports/round-103/r103-report.md` is the round-close report draft (475 lines, sha256
`c492a00247e87d59cb96b791cc33d360ae69a4900352857164c4bfb4db65d66e`). Its own lines 8–9 and 474–475
declare the slot's contract verbatim: *"the L1 lands one commit and this report is the last artifact
to land."* The brief anticipates exactly this, so all 8 are **Class A**, not defects.

`grep -rlE '\{\{[^}]*\}\}' reports/round-103/` returns **one** path — `r103-report.md`. No other r103
artifact uses the template syntax. (This file quotes the token list and the slot verbatim, so it
self-matches any rescan; the reproduce commands in §5 exclude it for that reason.)

### 2.2 Strict — word-boundary stub tokens (command A): **0 hits**

```sh
$ grep -rnwE --exclude=stub-cleanness.md 'TODO|TBD|FIXME|XXX|WIP|PLACEHOLDER' reports/round-103/
$ echo "rc=$?"
rc=1
```

Zero. No `TODO`, `TBD`, `FIXME`, `XXX`, `WIP` or `PLACEHOLDER` stands as a word anywhere in the
round's artifacts. A case-insensitive variant (`grep -rniE 'todo|tbd|fixme'`) likewise returns
nothing.

### 2.3 Seat-spec literal list, substring (command C): 25 hits, all classified A or C

```sh
$ grep -rnoiE --exclude=stub-cleanness.md 'TODO|TBD|\{\{[^}]*\}\}|placeholder|XXX|FIXME' reports/round-103/
```

Per-file counts:

| file | substring hits | what they are |
|---|---|---|
| `reports/round-103/gate/security.md` | 9 | **C** — `tmp.XXXXXXXXXX` in three pasted `mktemp` transcripts |
| `reports/round-103/r103-report.md` | 8 | **A** — the `{{R103_COMMIT}}` slot, §2.1 |
| `reports/round-103/r103-connector.md` | 3 | **C** — `tmp.XXXXXXXXXX` |
| `reports/round-103/r103-verification-protocol.md` | 3 | **C** — `tmp.XXXXXXXXXX` |
| `reports/round-103/physics/investigate.md` | 2 | **C** — `direct.XXXXXX` |

All 13 `XXX` substring hits are the `XXXXXX` run of a `mktemp` template inside a pasted shell
transcript. Verbatim:

| `file:line` | token | class | verbatim context |
|---|---|---|---|
| `reports/round-103/gate/security.md:208` | `XXX` (×3) | **C** | `mktemp: failed to create file via template '/tmp/seat62/nope-62/tmp.XXXXXXXXXX': No such file or directory` |
| `reports/round-103/gate/security.md:223` | `XXX` (×3) | **C** | same template, inside a `run_gate.sh` transcript |
| `reports/round-103/gate/security.md:262` | `XXX` (×3) | **C** | `mktemp: failed to create directory via template '/tmp/seat62/nope-62/tmp.XXXXXXXXXX'` |
| `reports/round-103/physics/investigate.md:158` | `XXX` (×2) | **C** | `D=$(mktemp -d /tmp/r103phys/direct.XXXXXX); cp -a corpus/fixtures/. "$D"/` |
| `reports/round-103/r103-connector.md:293` | `XXX` (×3) | **C** | `mktemp: failed to create directory via template '/nonexistent-dir-xyz/tmp.XXXXXXXXXX'` |
| `reports/round-103/r103-verification-protocol.md:735` | `XXX` (×3) | **C** | `mktemp: failed to create file via template '/nonexistent-xyz/tmp.XXXXXXXXXX'` |

`grep -rlnwE --exclude=stub-cleanness.md 'XXX' reports/round-103/` returns nothing — the word-level
form of the same token is absent, which is the whole discriminator.

### 2.4 Seat-spec list plus `pending` (command D): 8 word-level hits, all **B**

```sh
$ grep -rnw -i --exclude=stub-cleanness.md 'pending' reports/round-103/
```

| `file:line` | token | class | verbatim context (trimmed) |
|---|---|---|---|
| `reports/round-103/b2/ruling.md:431` | `pending` | **B** | "this file rules *and* verifies, rather than gating a **pending** edit." |
| `reports/round-103/b2/repair-unity.md:102` | `pending` | **B** | "the other 165 files are the **pending** L1 systemic …" |
| `reports/round-103/r103-report.md:466` | `pending` | **B** | "Engine install is blocked **pending** operator Epic-account linking." |
| `reports/round-103/consistency.md:89` | `pending` | **B** | heading: "…layout block labelled `PROVENANCE.md`/`adaptation-kimi.md` as `(pending: …)` · **ADDRESSED**" |
| `reports/round-103/consistency.md:95` | `pending` | **B** | quoted command: `$ grep -n 'pending' corpus/knowledge/unreal-mcp/README.md` |
| `reports/round-103/consistency.md:96` | `pending` | **B** | quoted output: `69:  pending operator Epic-account linking.` |
| `reports/round-103/consistency.md:99` | `pending` | **B** | "The two `(pending: …)` labels are gone (landed at r101 close…)" |
| `reports/round-103/consistency.md:100` | `pending` | **B** | "The single surviving `pending` at `:69` is unrelated (the engine-install wall)." |

Every one is a complete sentence or a quoted command/output line. `consistency.md:89` is the
strongest case for a re-check and it resolves cleanly: it is a **finding heading** recording that
the two `(pending: …)` labels are *gone* — the token appears in the heading to name the repaired
state, and the row's own status cell reads **ADDRESSED**. That is the opposite of a stub.

Note the substring-vs-word distinction also holds here: the superset count is **42** substring hits
while the word-level count is **8**. The other 34 are `ap`**pending** / `de`**pending** inside
ordinary words (`note/adversary.md:130,246` "appending"; `b2/scanner.md:147` "depending";
`git-hygiene.md:565` "appending"; `battery-consistency.md:323` "depending"; `close-count.md:218`
"spending"; `r103-verification-protocol.md:350` "appending"). `grep -rnw -i pending` excludes all of
them, which is why §2.4 has 8 rows and not 42.

### 2.5 `placeholder` and `stub`: 0 and 8 hits respectively

`grep -rniE 'placeholder' reports/round-103/` → **no hits** (rc=1). This is a change from r102, where
`placeholder` appeared as prose. No r103 artifact uses it.

`grep -rniE '\bstubs?\b' reports/round-103/` → 8 hits, **all technical vocabulary in the gate seats'
attack notes**, describing deliberately planted fake tools and minimal trees — not unfinished
artifacts:

| `file:line` | context |
|---|---|
| `reports/round-103/gate/mutations.md:26` | "…stubs any still-dangling [pointer]…" — a mutation technique |
| `reports/round-103/gate/sentinel.md:118` | "**layout-faithful but minimal**: the subtree, plus stub files for every repo-relative path…" |
| `reports/round-103/gate/sentinel.md:308` | "a shadowing stub on `PATH` passes the guard" |
| `reports/round-103/gate/sentinel.md:313` | "A stub `sha256sum` that replays the twelve expected `OK` lines…" |
| `reports/round-103/gate/sentinel.md:333` | "stub also makes `a == b` trivially (empty vs empty). This is fold-spec A7, unfixed." |
| `reports/round-103/gate/sentinel.md:364` | "A `cut` stub that exits 0 with no output…" |
| `reports/round-103/gate/sentinel.md:371` | "stub that exits 0 with no output, against a tree with a planted out-of-range pointer" |
| `reports/round-103/skill-table-review.md:430` | "…plus stub lane-level targets…" — a test-harness plan |

These are Class B. `sentinel.md:333`'s "unfixed" is a *named open gap* (fold-spec A7) with a full
argument attached, not a placeholder standing in for content.

## 3. Scope 2 — r103-modified files outside `reports/round-103/`

`git status --porcelain -uall` at the final frame named these tracked modifications and untracked
additions. Each was scanned individually.

```sh
$ git status --porcelain -uall | grep -v '^?? reports/round-103/'
 M corpus/artifacts/glb-r12/README.md
 M corpus/artifacts/unity-r19/README.md
 M corpus/fixtures/three/README.md
 M corpus/knowledge/unreal-mcp/adaptation-kimi.md
 M corpus/knowledge/unreal-mcp/gate/README.md
 M corpus/knowledge/unreal-mcp/gate/run_gate.sh
```

| file | sha256 | stub-token hits |
|---|---|---|
| `corpus/knowledge/unreal-mcp/gate/run_gate.sh` | `577c8b5489577b948536005a170da14ae3d4e13c11776aeca8f803bfb5fcefa0` | **0** |
| `corpus/knowledge/unreal-mcp/gate/README.md` | `834f468ded21fcdf069ab378c2774298158f71a93954aef9ee0df86bd90927d2` | **0** |
| `corpus/knowledge/unreal-mcp/adaptation-kimi.md` | `084a34cd94806caa497de1ab80df84f95876114048ead83bc158b4d50de8c879` | **2** — `:17`, `:284`, both prose `pending` |
| `corpus/artifacts/glb-r12/README.md` | `d87774dcfc3c6265957e2850b4fc2f29a72eabef9697424009d6355d05b8582b` | **0** |
| `corpus/artifacts/unity-r19/README.md` | `12c4abd106b3e5a341fbede8c54563b9332a16ec6b805258788704934d608b4c` | **0** |
| `corpus/fixtures/three/README.md` | `19ad2c8ce1e75efd98577c3267da8afcb3cc77e94f5e2f4415680ab693ca3d30` | **0** |

`corpus/fixtures/three/README.md` entered the modified set at `15:35:34` (a 17-line in-place edit by
the C3 repair seat, before this seat's final frame). It is a **protected path** (`corpus/fixtures/**`)
and this seat did not write it — it is scanned here only as an r103-modified surface. Word-level
scan: **0** hits.

The two `adaptation-kimi.md` hits are the only word-level tokens outside the reports tree, and both
are the same sentence, twice:

```sh
$ grep -nw -i 'pending' corpus/knowledge/unreal-mcp/adaptation-kimi.md
17:AUR engine install blocked pending operator Epic-account linking. Consequently every row that
284:   engine install is blocked pending operator Epic-account linking, so no such claim may be
```

**Class B.** `:17` is host-receipt prose in the file's r101 header (untouched by r103 — the r103
edit is an append-only correction note beginning at line 363). `:284` is inside that appended note.
Both describe the engine-install wall; neither stands where finished content should be.

`corpus/knowledge/unreal-mcp/README.md:69` carries the same prose sentence and is the source of
`consistency.md:96`'s quoted line; it is **not** modified this round, so it is outside this seat's
scope and is recorded only for completeness.

## 4. The generated `node_modules` tree — scanned and excluded, with the reason

The C3 investigation created a build tree this round:
`corpus/fixtures/three/node_modules/` (23 MB, 1264 files, mtime `2026-10-18 15:34`). It contains
**350** substring hits for the stub lexicon, all inside vendored third-party `three.js` sources
(e.g. `three.module.js` TODO comments).

It is **not** an r103 artifact and not a tracked surface: `corpus/fixtures/three/.gitignore:1` is
`node_modules/`, and `git check-ignore -v` confirms the path is ignored —
`git status --porcelain -uall | grep -c node_modules` → `0`. A vendored dependency's upstream
`TODO` comments are not this lane's unfinished work, and flagging them would be a false positive by
construction. Recorded here so a reader re-running the scan with `-r` over `corpus/` is not
surprised by the 350 hits. **`corpus/fixtures/**` is a protected path** and this seat did not write
inside it.

## 5. Reproduce

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin

# A. strict word-bound stub tokens over the round's artifacts — expect NO output, rc=1
grep -rnwE --exclude=stub-cleanness.md 'TODO|TBD|FIXME|XXX|WIP|PLACEHOLDER' reports/round-103/

# B. {{...}} template slots — expect exactly the 8 r103-report.md lines in §2.1
grep -rnE --exclude=stub-cleanness.md '\{\{[^}]*\}\}' reports/round-103/

# C. the brief's literal list, substring — expect the 25 hits in §2.3 (8 Class A + 13 Class C
#    mktemp templates; note the hit count is a substring count, not a defect count)
grep -rnoiE --exclude=stub-cleanness.md 'TODO|TBD|\{\{[^}]*\}\}|placeholder|XXX|FIXME' reports/round-103/

# D. seat-spec list plus `pending`, word-level — expect the 8 prose lines in §2.4
grep -rnw -i --exclude=stub-cleanness.md 'pending' reports/round-103/

# E. the r103 corpus deliverables proper — expect only the two prose `pending` lines
grep -nwiE 'TODO|TBD|FIXME|XXX|WIP|PLACEHOLDER|placeholder|pending' \
  corpus/knowledge/unreal-mcp/gate/run_gate.sh \
  corpus/knowledge/unreal-mcp/gate/README.md \
  corpus/knowledge/unreal-mcp/adaptation-kimi.md \
  corpus/artifacts/glb-r12/README.md \
  corpus/artifacts/unity-r19/README.md

# F. the ignore-status proof for §4
git check-ignore -v corpus/fixtures/three/node_modules
```

Commands A–D carry `--exclude=stub-cleanness.md` because **this file self-matches**. That is a
measured fact, not a precaution: at the `15:46:46` frame, with this file present, the raw form of
command A returns **24** word-bound hits (all of them the token names quoted in this file's own
§0/§1/§5 prose) and `grep -rlnwE 'TODO|TBD|FIXME|XXX|WIP|PLACEHOLDER' reports/round-103/` returns
**one path — this one**. Command D's raw form returns **32** word-level `pending` hits versus 8 with
the exclusion. So the numbers in §2 are the **self-excluded** numbers, which is the only form that
measures the round rather than the scanner:

```sh
$ grep -rnwE 'TODO|TBD|FIXME|XXX|WIP|PLACEHOLDER' reports/round-103/ | wc -l
24                                    # raw: all inside this file
$ grep -rlnwE 'TODO|TBD|FIXME|XXX|WIP|PLACEHOLDER' reports/round-103/
reports/round-103/stub-cleanness.md   # the only path
$ grep -rnw -i --exclude=stub-cleanness.md 'pending' reports/round-103/ | wc -l
8
$ grep -rnw -i 'pending' reports/round-103/ | wc -l
32
```

The r102 seat hit the same problem and solved it the same way
(`reports/round-102/stub-cleanness.md` §1 and §5 both carry `--exclude=stub-cleanliness.md`); the
r102 brief anticipated it by calling the self-match out explicitly. Any re-run must keep the
exclusion or it will report this file's own quotations as round defects.

## 6. Frame series — the round was still landing

The round-103 tree grew **1 → 56 files** during this seat's window. Counts were sampled every 20 s;
the log is `/home/vgpnk/.cache/s41/frames.log` (written outside the repo, since `/tmp` was at its
16 GB tmpfs limit and refused further writes mid-run).

```
2026-10-18T15:33:03 n=9  strict=0 seatlist=0  superset=0
2026-10-18T15:33:43 n=14 strict=0 seatlist=0  superset=0
2026-10-18T15:34:43 n=24 strict=0 seatlist=0  superset=4
2026-10-18T15:35:43 n=30 strict=0 seatlist=0  superset=3
2026-10-18T15:37:03 n=33 strict=0 seatlist=0  superset=2
2026-10-18T15:37:23 n=36 strict=0 seatlist=2  superset=5
2026-10-18T15:38:43 n=45 strict=8 seatlist=10 superset=19
2026-10-18T15:39:23 n=47 strict=8 seatlist=13 superset=27
2026-10-18T15:42:43 n=54 strict=8 seatlist=19 superset=35
2026-10-18T15:43:23 n=55 strict=8 seatlist=25 superset=41
2026-10-18T15:45:43 n=55 strict=8 seatlist=25 superset=41
2026-10-18T15:46:23 n=56 strict=8 seatlist=25 superset=42
```

(Full series: 42 frames, 15:33:03 → 15:46:23, monotone in file count except at file replacements.)

Reading of the series:

- `strict` was **0** until `15:38:43`, then **8** and flat for the remaining 24 frames. The jump is
  exactly the arrival of `r103-report.md`; the 8 slots never grew. **No `TODO`/`TBD`/`FIXME`/`XXX`
  word ever entered the surface** — `strict` here counts the `{{…}}` set, which §2.2's word-bound
  scan is empty against.
- `seatlist` moved 0 → 25 in three steps (15:37:23, 15:38:43, 15:39:23, 15:42:43), tracking the
  arrival of the four files that paste `mktemp` transcripts.
- `superset` is the noisiest because `pending` substring-matches `appending`/`depending`/`spending`
  in ordinary prose; it settles at 42, of which 8 are word-level.

The last five frames (15:45:03 → 15:46:23) are flat apart from one new file at the end. **Snapshot,
not final state:** files landing after the final frame below are not covered; re-run §5 at round
close.

### 6.1 Post-report confirmation frame

Two further files landed while this report was being written (`physics/ledger.md` 419 lines,
`physics/investigate.md` already covered). Re-scanned at the confirmation frame
`2026-10-18T15:47:27-03:00`, **58 files**:

```sh
$ grep -rnwE --exclude=stub-cleanness.md 'TODO|TBD|FIXME|XXX|WIP|PLACEHOLDER' reports/round-103/
$ echo "rc=$?"
rc=1
$ grep -rnE --exclude=stub-cleanness.md '\{\{[^}]*\}\}' reports/round-103/ | wc -l
8
$ grep -rnw -i --exclude=stub-cleanness.md 'pending' reports/round-103/ | wc -l
8
$ grep -rnoiE --exclude=stub-cleanness.md 'TODO|TBD|\{\{[^}]*\}\}|placeholder|XXX|FIXME' reports/round-103/ | wc -l
25
```

Every count is unchanged from §2, so `physics/ledger.md` and the other late arrivals add **no** new
hit. `physics/ledger.md` was additionally scanned standalone: its one substring hit at
`:318` is the word **"ap"pending** inside prose ("…e.g. appending a `degraded` token to the PASS
line…"), and `grep -rnw -i pending reports/round-103/physics/ledger.md` returns nothing. **Class C.**

## 7. Boundaries

- **No Unreal runtime claim.** This scan is text-only over markdown, shell and JSON. Unreal Editor is
  not installed on this host; nothing here speaks to live-MCP or editor behaviour.
- **Read-only.** This seat wrote exactly one file, `reports/round-103/stub-cleanness.md`. No `git`
  mutating command was run. No byte-pinned or protected path (`LOG.md`, `SCORECARD.md`, `SHONEN.md`,
  `SKILL.md`, `PROVINCE.md`, `corpus/fixtures/**`, `reports/round-101/**`, `reports/round-102/**`,
  `corpus/knowledge/unreal-mcp/upstream/**`, `.manifest.d/**`) was modified by this seat.
- **Line numbers drift.** The round was live-mutating; the `file:line` values in §2 are stamped to
  the `15:46:46` frame with per-file sha256s given in §3. A rescan after further landings should
  expect the same *tokens* at shifted lines, not different tokens.
- **`/tmp` was unusable for scratch** during this seat's run (16 GB tmpfs at 80 % with a per-user
  write refusal). Frame logs were placed under `~/.cache/s41/`. This affected only where this
  seat's own scratch lived, never what it read.
