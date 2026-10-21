# r107-integrate — W-INTEGRATE (round 107, 3D side-round)

Plan (5 lines):
1. Inventory every r107 shard + mutation artifact that must land (PROVENANCE, upstream tree, cards, adaptation, gate, reports).
2. Establish the exact landing order with per-step preconditions/verification commands.
3. Enumerate collision surface: what the parallel 2D session / sibling lanes could touch (corpus/knowledge siblings, reports/round-107, LOG/SCORECARD/PROVINCE).
4. Draft the orchestrator checklist as copy-pasteable command blocks with expected output.
5. Cross-check drafts against current tree state (pin, tracked-file count, gate) before publishing.

Status: **complete**. All measurements by this seat, 2026-10-19, from the lane root and
`/var/tmp/r107-integrate/`. Labels: **[O]** observed here · **[I]** inference · **[?]** unknown.
**No Unreal runtime claim** — the editor is not installed and the docker pull is still in flight.

---

## 0. Headline for the orchestrator (read this before landing anything)

**Three facts change the landing plan from the one in the round brief.**

1. **There is no pin delta, so step 2 ("upstream/ tree swap") is a VERIFY-ONLY no-op.** Upstream
   `main` still resolves to `a6aa73ada02a9fb1f5415bec491f9942c519b297` — byte-for-byte the r101
   pin — across three transports this seat ran independently (§5). All 12 git blob ids match the
   r101 table. **Do not rewrite the 12 files.** A rewrite can only introduce a diff and would
   invalidate `.manifest.d/` for nothing. The honest landing is: re-verify, then add a *dated
   re-pin note* recording that the 2026-10-19 re-fetch returned the same bytes.
2. **`gate/README.md` carries two stale sha pins** that its own "state the pin with a scanner
   sha256" rule makes load-bearing (§1 step 5). Fixing them changes `gate/README.md`'s own sha,
   which `SKILL.md:179` and `corpus/lessons/r102-unreal-integration.md:242` cite — a cascade the
   orchestrator must own (§2 C3).
3. **A cross-lane artifact exists.** `game-dev-2d-shokunin/reports/round-107/r107-planner.md` is
   a *3D side-round* planner (textually identical to this lane's `r107-planner.md`, untracked,
   created 00:08). The docker pull was launched with its cwd inside the 2D lane. See §2 C1 — an
   orchestrator decision, not a seat one.

---

## 1. Landing order

Landed by the orchestrator in **one work commit** (mirroring r101's `1659c036`), with the
report-last artifacts in a second commit (mirroring r105/r106 `f5dbca2`/`3ea02ff`). Order below
is chosen so that each step's verification is green *before* the next step touches the tree.

| # | target | source shard(s) | action | gate-relevant? |
|---|---|---|---|---|
| 1 | `corpus/knowledge/unreal-mcp/PROVENANCE.md` | `r107-PROVENANCE-draft.md`, `r107-pindelta.md` | add re-pin rows + fetch date | no |
| 2 | `corpus/knowledge/unreal-mcp/upstream/**` | `r107-VENDOR-A/B.md`, `r107-verify*.md`, `r107-rev-pin.md` | **VERIFY ONLY — no file write** | CHECK 1, 2 |
| 3 | `corpus/knowledge/unreal-mcp/executability/**` | `r107-cards.md`, `r107-cards-crit.md`, `r107-rev-cards.md` | deltas only; likely no-op | CHECK 3, 4 |
| 4 | `corpus/knowledge/unreal-mcp/adaptation-kimi.md` | `r107-kimi-adapt.md`, `r107-kimi-ver.md`, `r107-rev-adapt.md` | targeted row refresh | CHECK 4 |
| 5 | `corpus/knowledge/unreal-mcp/gate/{README.md,run_gate.sh}` | `r107-gate.md`, `r107-rev-gate.md`, `r107-mut-gate.md` | README sha re-pin (see §1.5) | gate itself |
| 6 | `reports/round-107/**` | all 34+ shards + `mutations/` | land the directory as-is | CHECK 4 (pass B) |
| 7 | `corpus/lessons/r107-unreal-revendor.md` | `r107-scribe-lesson.md` | new lesson file | CHECK 4 |
| 8 | `LOG.md`, `SCORECARD.md` | `r107-scribe-log.md` | orchestrator scribe | no |
| 9 | `reports/round-107/r107-report.md` | `r107-scribe-report.md` | report-last commit | CHECK 4 |

### 1.1 PROVENANCE (step 1)

Precondition: `r107-pindelta.md` §3 (12/12 rows `none`) and `r107-PROVENANCE-draft.md` complete.

```sh
grep -n '2026-10-19' corpus/knowledge/unreal-mcp/PROVENANCE.md   # expect a re-pin/fetch-date row
grep -c 'a6aa73ada02a9fb1f5415bec491f9942c519b297' corpus/knowledge/unreal-mcp/PROVENANCE.md  # unchanged
```
Expected: fetch date advanced to 2026-10-19, SHA field **unchanged** `a6aa73ad…`. A shard claiming
a *new* SHA is fabricated and must be rejected — there is no merged upstream commit (§5).

**Constraint:** PROVENANCE.md contains **zero** `upstream/<path>:<line>` pointers **[O]**
(`grep -ohE 'upstream/…' | wc -l` → 0), so editing it cannot move the gate's `POINTERS=103`.
Safe to edit.

### 1.2 upstream/ tree (step 2) — verify only

```sh
git clone https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin /var/tmp/r107-land/clone
git -C /var/tmp/r107-land/clone rev-parse HEAD     # a6aa73ada02a9fb1f5415bec491f9942c519b297
diff -rq /var/tmp/r107-land/clone corpus/knowledge/unreal-mcp/upstream --exclude=.git   # empty, exit 0
(cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256)      # 12x OK, exit 0
```
Expected: both green **[O, re-run this seat §5]**. If either is red, the round is stale — stop and
re-pin per `r107-planner.md` §1.2, do not hand-edit files.

### 1.3 Cards (step 3)

`r107-cards.md` declares "deltas only". If the delta set is empty, **land nothing** — the cards
are already at the pin's content.

```sh
ls corpus/knowledge/unreal-mcp/executability/*.md | wc -l      # 13
(cd corpus/knowledge/unreal-mcp && find executability -maxdepth 1 -type f | wc -l)   # 13, no nested
```
Census must stay `static-only=12 unproven-runtime=1 verified-here=0` unless an unlock receipt
justifies a change (it does not — see §5 pull status). Editing a label to "make the census pass"
is the fabrication the gate exists to catch (`r107-planner.md` §3.3).

### 1.4 adaptation-kimi.md (step 4)

```sh
grep -c '^|' corpus/knowledge/unreal-mcp/adaptation-kimi.md    # 24 table rows incl. header/sep → 15 data rows
sha256sum corpus/knowledge/unreal-mcp/adaptation-kimi.md       # currently a2db1d28…
```
Live sha **before** landing: `a2db1d283ef3d277309322245fbf3614d066e35ca3e440d85efe39365f2223a1`
**[O]**. `gate/README.md:248` cites this file as `084a34cd…` **[O — stale]**. If step 4 edits the
file, its sha moves again — see §1.5.

### 1.5 gate (step 5) — the one substantive write

`gate/README.md` states its expected values *against a scanner sha256*. Two of those citations no
longer match the shipped bytes **[O]**:

| README line | README says | live truth (this seat) |
|---|---|---|
| 248, 283, 373, 440 (4 live-claim sites) | scanner `run_gate.sh` sha256 `e5521304…` | shipped `run_gate.sh` = `390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf` |
| 248 | `adaptation-kimi.md` sha256 `084a34cd…` | live `adaptation-kimi.md` = `a2db1d28…` |
| 42 | scanner `e5521304…` quoted inside the r104 history blockquote | historical — leave as history |
| 40, 397 | scanner `577c8b54…` (r103-era, history note) | historical — leave as history |

```sh
sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh   # must equal whatever README now cites
grep -n 'e5521304' corpus/knowledge/unreal-mcp/gate/README.md   # target: only line 42 (history), not 248/283/373/440
```
Expected after the edit: README cites `390a25ae…` and `a2db1d28…` (or a dated note explaining why
the cited values are historical). `390a25ae…` currently appears **nowhere** in `gate/README.md`
**[O]**.

**Do not** restructure the gate: the 4 checks, the `BLOCKED`(exit 2) vs `FAIL`(exit 1) split, the
tool guard, `WORK_ROOT=${GATE_WORKDIR:-${TMPDIR:-/tmp}}`, and `EXPECTED_*` constants are r102–r104
adversary-bought. A refresh that edits `EXPECTED_STATIC/UNPROVEN/VERIFIED` is overstepping.

### 1.6–1.9 reports, lesson, LOG/SCORECARD, report-last

- Step 6: land `reports/round-107/` wholesale. Note it is **live** — seats are still writing
  (§2 C2). Snapshot at a named instant and land that snapshot.
- Step 7: `corpus/lessons/r107-unreal-revendor.md` is a **new** file; `corpus/lessons/` currently
  holds 96 files (92 top-level `.md` + the `r1/` subdir with 4 JSON) and 96 tracked — no
  deletions **[O]**. Confirm the target name does not collide before adding; a new lesson lands as
  `corpus/lessons/r107-unreal-revendor.md` (top level, matching r102/r105).
- Steps 8–9: follow the r106 shape (`3ea02ff`: `LOG.md` + `SCORECARD.md` + `r107-report.md`, 3
  files, report-last).

---

## 2. Collision notes

### C1 — Cross-lane artifact (orchestrator decision)

`game-dev-2d-shokunin/reports/round-107/r107-planner.md` **[O]** — 571 bytes, untracked in the 2D
lane (`git -C game-dev-2d-shokunin status --porcelain` → `?? reports/round-107/r107-planner.md`),
content = the 3D side-round spec-planner header (identical text to this lane's `r107-planner.md`
header). The docker pull wrapper (pid 596297) has cwd `/home/vgpnk/Projects/shokunin/game-dev-2d-shokunin`
**[O, `r107-pull-watch.md` §Setup]**. Reading: the side-round's dispatch ran one seat with the 2D
lane as cwd **[I]**. Options: (a) delete the stray file from the 2D lane, (b) relocate it here,
(c) leave and record. **This seat writes only in the 3D lane and takes no action** — flagged for the
orchestrator, who owns cross-lane hygiene. Do not "fix" it from a seat.

### C2 — The parallel 3D session (live writes into paths you will land)

`reports/round-107/` is **growing while you read it** — VENDOR-B, pindelta, scribe-report, and
`mutations/{verify-manifest.json,vb-*.json,rev-pin.sh,cards-review.sh,w-cron-snapshot.sh}` were all
touched within the last 60 s of this seat's run **[O]**. Consequences:
- Land `reports/round-107/` **as one `git add`** after the swarm is quiesced, not file-by-file.
- `mutations/` holds generated artifacts (`*-manifest.json`, `*.sha256`, `*.sha1`) plus scripts
  (`*.sh`); land both. None is an input to a gate check — CHECK 4 scans only `*.md`/`*.txt`/
  `*.markdown` **under the subtree** (`corpus/knowledge/unreal-mcp/`), and this round adds no
  `.md`/`.txt` inside the subtree, so `reports/round-107/**` does not move `POINTERS` at all
  (see C4 for why the subtree's own backtick `reports/...` pointers are a pre-existing, passing
  concern).
- A `r107-report.md` written before the last seat lands will under-count. Report-last.

### C3 — Gate-README sha citation cascade (highest-risk collision)

Editing `corpus/knowledge/unreal-mcp/gate/README.md` changes its sha from `e3bc66b7…` **[O]**.
That exact sha is cited in:
- `SKILL.md:179` **[O]** (tracked, lane root),
- `corpus/lessons/r102-unreal-integration.md:242` **[O]**,
- `reports/round-104/gate/*` and `reports/round-102/*` (historical, dated — leave).

Likewise `run_gate.sh` `390a25ae…` is cited by `SCORECARD.md`, `SKILL.md:178`,
`corpus/lessons/{r102,r105}-*.md` **[O]**. Rule for the orchestrator: **edit the gate README, then
either** update the two live forward-citation sites (`SKILL.md:179`, r102 lesson) with a dated
note, **or** record in `r107-report.md` that those citations now name the superseded blob. Do not
silently leave a live-pointer citation pointing at bytes that no longer exist.

### C4 — Other files citing the pin (do not "refresh" blindly)

`a6aa73ad…` appears in **504 tracked files** **[O]** (`git grep -l`). Because there is no pin
delta, **none of them is stale**. Specifically: `corpus/knowledge/engines.md:44` **[O]**,
`corpus/README.md` (r106 dated note), `reports/round-101/probes/*`, `reports/round-102/*`. A
citation sweep is *not* warranted this round; `r107-crit-hygiene.md` owns the stale-vs-durable
ruling and should be the authority the orchestrator follows if any of these are touched.

**Pre-existing pass-B note (do not let a gate edit break it):** CHECK 4's pass B resolves
backtick-wrapped `reports/...` pointers found *inside the subtree* against `REPO_ROOT`; there are
`reports/round-101|102/...` pointers in the subtree's cards/README today and `UNRESOLVED=0` **[O]**.
If step 6 lands a `reports/round-107/...` reference **inside** `corpus/knowledge/unreal-mcp/`, that
path must exist after the commit or the gate goes red on CHECK 4. Prefer keeping round-107
references out of the subtree, or land the referenced file in the same commit.

### C5 — Orchestrator-only surfaces (seats must not have written here)

`LOG.md`, `SCORECARD.md`, `PROVINCE.md`, `SHONEN.md`, `SKILL.md`, `corpus/fixtures/**`,
`corpus/knowledge/unreal-mcp/**`. Verified this seat: `git status --porcelain -uall` shows
**nothing** outside `reports/round-107/` **[O]**; `run_battery.py` is `f456bd00…` unchanged and
`git diff --stat HEAD -- corpus/fixtures/` is empty **[O]**. The 2D lane's `corpus/knowledge/`
holds only `seed.md` + a checklist — no unreal-mcp surface to collide with **[O]**.

---

## 3. Pre-flight and post-landing verification

**Pre-flight (run before `git add`):**
```sh
git -C . rev-parse HEAD                                   # 3ea02ff (r106 report-last)
git status --porcelain -uall | grep -v '^?? reports/round-107/'   # expect empty
sha256sum corpus/fixtures/run_battery.py                  # f456bd00… (must be unchanged)
(cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256)  # 12x OK
```

**Post-landing (run on the committed tree, by a non-author seat):**
```sh
GATE_WORKDIR=/var/tmp/r107-close corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "exit=$?"
```
Expected (this seat's live run, §5): 4× `STEP=PASS`, `MANIFEST_OK=12`, `CLONE_HEAD=a6aa73ad…`,
`CARDS=13`, `CENSUS static-only=12 unproven-runtime=1 verified-here=0`, `NAME_SET=OK`,
`POINTERS=103 POINTER_STRINGS=41 UNRESOLVED=0`, `GATE RESULT: PASS`, `exit=0`.
Plus the two negative controls the adversary seats own: dead `REPO` → `CHECK 2 BLOCKED`, exit 2;
bad `GATE_REF` → `FAIL`, exit 1.

---

## 4. Open decisions for the orchestrator (not resolvable by a seat)

1. **Stray 2D-lane `r107-planner.md`** — delete, relocate, or record (C1).
2. **Gate-README citation cascade** — update `SKILL.md:179` + r102 lesson, or record the
   supersession in the report (C3).
3. **`reports/round-107/` snapshot instant** — the directory is live (C2).
4. **UE runtime label** — must be `unproven-with-attempt-log`. At this seat's run the pull was
   **still in flight** (`docker images | grep -i unreal` → empty; pid 596299 alive at 03:11
   elapsed; `r107-pull-watch.md` snapshot 1: 4.61/24.95 GiB) **[O]**. Either outcome closes the
   round; a "proven" label requires the U1–U4 receipt, not a container that merely boots.
5. **P/C label-precedence ruling** remains PENDING and is **not** this round's to resolve.

---

## 5. Evidence this seat gathered (commands + observed output)

| # | command | observed | label |
|---|---|---|---|
| 1 | `git ls-remote <url> main` | `a6aa73ada02a9fb1f5415bec491f9942c519b297  refs/heads/main`, exit 0 | [O] |
| 2 | `git clone <url> clone && git -C clone rev-parse HEAD` | `a6aa73ad…`; `ls-files \| wc -l` → 12 | [O] |
| 3 | `git -C clone log -1 --format='%s\|%an %ai\|%ci'` | `[MCP] Permit safe concurrent tool calls` / `Thomas Mansencal 2026-09-17 13:19:50 +1200` / `2026-09-17 13:28:32 +1200` | [O] |
| 4 | `gh api repos/…/commits/main --jq '.sha,.commit.committer.date'` | `a6aa73ad…`, `2026-09-17T01:28:32Z` | [O] |
| 5 | `gh api repos/…/tags` | empty — no tags | [O] |
| 6 | `diff -rq clone corpus/knowledge/unreal-mcp/upstream --exclude=.git` | no output, exit 0 | [O] |
| 7 | codeload tarball `…/tar.gz/<sha>` → extract → `find -type f \| wc -l` | 12 files; `diff -rq` vs vendored → exit 0 | [O] |
| 8 | `gh api …/contents/<p>?ref=<sha> --jq .sha` ×12 vs `git ls-tree` blob ids | 12× AGREE (`44c8dd3e`,`4a38912a`,`7ccb8b76`,`aa5fae26`,`ba4e660a`,`6be4b8b7`,`8c06ba24`,`9cd2cc26`,`49a921a9`,`e02d8d0e`,`febf5d5a`,`a1513865`) | [O] |
| 9 | `(cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256)` | 12× `OK`, exit 0 | [O] |
| 10 | `sha256sum -c .manifest.d/*.sha256` (glob) | exit 0 (24 lines) | [O] |
| 11 | `GATE_WORKDIR=/var/tmp/r107-integrate run_gate.sh` | 4× `STEP=PASS`; `GATE RESULT: PASS`; exit 0 | [O] |
| 12 | `sha256sum gate/run_gate.sh gate/README.md` | `390a25ae…` / `e3bc66b7…` | [O] |
| 13 | `grep -n 'e5521304' gate/README.md` | 5 hits (lines 40, 248, 283, 373, 440) | [O] |
| 14 | `grep -n '390a25ae' gate/README.md` | 0 hits | [O] |
| 15 | `sha256sum adaptation-kimi.md` | `a2db1d28…` (README cites `084a34cd…`) | [O] |
| 16 | `git status --porcelain -uall \| grep -v '^?? reports/round-107/'` | empty | [O] |
| 17 | `git -C game-dev-2d-shokunin status --porcelain` | `?? reports/round-107/r107-planner.md` | [O] |
| 18 | `docker images \| grep -i unreal` | no output — image not local | [O] |
| 19 | `ps -p 596299 -o pid,etime` | alive, 03:11 → 04:22 elapsed across the run | [O] |
| 20 | `sha256sum corpus/fixtures/run_battery.py` | `f456bd00…` unchanged | [O] |
| 21 | `git grep -l 'a6aa73ad' -- . \| wc -l` | 504 tracked files | [O] |
| 22 | `find corpus/lessons -type f \| wc -l` / `git ls-files corpus/lessons \| wc -l` | 96 / 96 (92 top-level `.md` + `r1/` with 4 JSON) | [O] |

---

## 6. What this seat did NOT verify [explicit]

- **[?]** Whether the docker pull completes and whether any U1–U4 probe fires — not this seat's
  artifact (`r107-unlock*.md`, `r107-pull-watch.md` own it).
- **[?]** The correctness of any PROVENANCE draft text, cards delta, adaptation row, or gate
  script draft — those are the author seats' claims; this seat only checks *where they land and in
  what order*.
- **[?]** Whether the parallel swarm will write more files into `reports/round-107/` after this
  shard's snapshot (it was live at 03:10–03:11).
- **[I]** The reading that the stray 2D-lane file came from a mis-cwd'd seat dispatch — the
  mechanism is inferred from the pull wrapper's cwd, not directly observed.
- No Unreal Editor, UnrealBuildTool or MCP tool call was made. Nothing here is runtime evidence.
