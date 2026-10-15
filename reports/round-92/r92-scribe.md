# r92 scribe — custody + consistency audit

Seat: GAME-DEV-3D r92 SCRIBE. Repo `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`.
Audit window: HEAD **`b6169f6`** at start (`git status --porcelain
--untracked-files=all` = 0 lines); **HEAD moved mid-audit** to **`b6a3e1a`**
("r92 simplifier: 5 proven dead-code candidates …") — a report-only commit
(`git show b6a3e1a --stat` = `reports/round-92/r92-simplifier.md` +227, nothing
else). At filing, the only untracked file in the repo is this report
(`?? reports/round-92/r92-scribe.md`). All custody/arithmetic checks below were
run against the `dd32c3c`/`b6169f6` artifact set; the sibling landing touched no
fixture, runner, or receipt (F8).

Read-only audit: no battery, no godot child, no fixture was re-run. Every number
below comes from existing receipts/artifacts or git plumbing. This seat reports;
the canonical Rust judge remains the sole Pareto authority.

---

## 1. Custody — `sha256sum -c` over every r92 manifest

```
cd corpus/live            && sha256sum -c r92-scout/manifest.sha256      # exit 1
cd corpus/live/r92-boundary && sha256sum -c manifest.sha256              # exit 0
```

| manifest | rooting | entries | OK | FAILED | failing entry |
|---|---|---|---|---|---|
| `corpus/live/r92-scout/manifest.sha256` | `corpus/live/` (paths `r92-scout/…`) | 1570 | **1569** | **1** | `r92-scout/RECEIPTS.md` |
| `corpus/live/r92-boundary/manifest.sha256` | `corpus/live/r92-boundary/` (+1 entry `../../../reports/round-92/r92-boundary.md`) | 149 | **149** | 0 | — |

- **Scout failure (F1):** the manifest recorded `6e51afd1e97b…` for `RECEIPTS.md`;
  disk is now `2d528caee6ba…`. `stat` mtimes (−0300): `manifest.sha256`
  02:56:09.76 vs `RECEIPTS.md` 02:56:12.36 — the manifest was generated 2.6 s
  before the final RECEIPTS.md write. All 1569 payload entries pass; the
  manifest is a complete census (1571 files on disk = 1570 manifest entries +
  the manifest itself; no manifest-only entries).
- **Boundary coverage:** 149 entries = 69 `.exit` + 69 `.stdout.txt` receipts +
  `runs/sched_summary.txt` + 3 probes + driver.py + sum.py + 3 `project.godot` +
  `RECEIPTS.md` + the report. 148 of the 296 dir files are unhashed sidecars
  (69 `.ms`, 69 `.stderr.txt`, 9 `proj*/*.gd` copies, manifest itself) — scope
  note F6. All 69 `.exit` files read `0`.
- **In-report shas (baseline):** 8/8 cited values match disk exactly —
  `env.txt` `653efda9…`, `frozen-tree.tar` `05f781aa…`,
  `frozen-fixture-digests.txt` `c6ba106a…`, `compare-rows.log` `f93373c7…`,
  `run1-235-rows.json` `89687411…`, `run1-235-rows-full.json` `ca88a0aa…`,
  `runs/20261015T170059933033Z/verdicts.json` `d3137288…`,
  `runs/20261015T170636200710Z/verdicts.json` `33b32c64…`.
- **Boundary abbreviated shas check out:** 21 manifest entries `8900717b…`
  (primary receipts; `bd_proj.r1.stdout.txt` = 5802 B as quoted) and 12 entries
  `74e19dc1…` (delivery receipts `nf_proj*.stdout.txt`).
- **Scout run counts:** 386 stdout files, 385 `.exit` (all `0`; `intro.stdout.txt`
  is the one stdout without an rc sidecar) — consistent with "342 rep-triples +
  44 single-rep smoke runs".
- The **author** seat has no sha-manifest; custody there is the two battery
  receipts + logs, read directly in §3.

## 2. Cited-path resolution — dangling = 0

Extractor over **all six** `reports/round-92/*.md` (five sibling reports +
this one; `r92-simplifier.md` landed mid-audit and is included), covering
dir-qualified/absolute tokens and bare filenames with known extensions,
resolved against repo root, `corpus/live`, the four seat dirs, `reports/`,
`corpus/fixtures/`, and absolute `/home/vgpnk/…`:

| class | checked | resolved | dangling |
|---|---|---|---|
| dir-qualified / absolute path refs | 80 | **80** | 0 |
| — of which glob patterns (e.g. `reports/round-8*`, `runs/*/verdicts.json`) | 8 | 8 | 0 |
| — of which context-only dir names (e.g. `scratch/`) | 2 | 2 | 0 |
| bare filenames (`.gd/.py/.md/.json/.txt/.log/.tar/.sha256`) | 46 | **46** | 0 |

Fourteen residual tokens from the raw scan were hand-verified as non-file refs
or constructs that expand to existing paths, not dangling: `GP/Jolt`,
`physics/common/physics_interpolation` (ProjectSettings key),
`corpus/lessons/r31/r32` (prose; `r31-playback-review.md`,
`r32-blend-review.md` exist), `imm/same_f/post_f/next_e` (field list),
`corpus/.gitignore:1:live/` (line-ref form; `corpus/.gitignore` exists),
wrapped brace constructs in this report's §9 that expand to existing files
(`corpus/live/r92-{scout,boundary}/{manifest.sha256,RECEIPTS.md,runs/}`;
`battery_run{1,2}.log`; `corpus/fixtures/{run_battery.py,r92_*.gd,
remote3d_transform.gd}`), the `git show 82afd7c:corpus/fixtures/run_battery.py`
object:path form, and brace-suffix fragments (`-start.txt`, `-stdout.log`) of
`run{1,2}-start.txt` / `run{1,2}-stdout.log`, all four of which exist. NodePath
literals (`../Plain`, `../Nope`, `../Target/Ghost`, `/root`) and engine
expressions (`9.8/60`, `1/N`) were excluded as in-engine strings.
The sibling `r92-simplifier.md` contributes 8 resolved refs + 2 glob patterns +
0 dangling on its own.

## 3. Claim arithmetic

| claim (author report) | measured | verdict |
|---|---|---|
| `run_battery.py` "+57 lines, 0 deletions" | `git diff --numstat 82afd7c..dd32c3c -- corpus/fixtures/run_battery.py` = `57	0`; `dd32c3c` = 5 files, 1790 insertions, 0 deletions | **verified** |
| "235 cases (189 ordinary + 46 negative)" → "258 cases (211 ordinary + 47 negative) = +23" | AST census of `CASES`: 82afd7c = 235 = 189+46; dd32c3c = 258 = 211+47; the 23 new rows = 22 ordinary + 1 negative (`r92_animphys_badkey_insert`, expected exit 2); baseline list is a strict prefix of the new list (tail-append, 0 removals) | **verified** |
| "23 new CASES rows → **369 child cells per battery pass** (Σ case×backend, plus 24 idlemode reps)" | fixture tables: remote 11 case-slots ×3 = 33; animphys 9×3 + idlemode 8×3 + badkey_insert 3 = 54; timing 12×3 = 36 → **123 children/pass**. Scratch census: run1 = 123 child dirs (33/54/36), run2 = 123; idlemode = 24/pass ✓. The report's own per-row Children column sums to 123. 369 = 3 × 123 = dev(123) + run1(123) + run2(123), all three censused | **conflict (F2)** |
| "Run 1 … 257/258 — `bpy_rbw3d_render` emitted `rdet stable=True` vs pinned `False`" | `runs/20261015T175116507786Z/verdicts.json`: totals `cases=258 pass=257 fail=1` (211/47); sole non-PASS is `bpy_rbw3d_render`, `reasons=['exact stdout marker missing']`, stdout carries `M rdet same_state stable=True` | **verified** |
| "Run 2 … 258/258 PASS, seeds unchanged both runs" | `runs/20261015T175829468804Z`: `cases=258 pass=258 fail=0`; `seeds_unchanged=true` both runs; 63 `seed_digests` identical; the same row now `stable=False` | **verified** |
| "Prior-row byte-identity run1↔run2: 234/235" | 235 pre-r92 rows compared on (exit, stdout, stderr): 234 identical; sole delta `bpy_rbw3d_render` (`stable=True`→`False`, verdict FAIL→PASS, reasons [..]→[]); 23/23 r92 rows byte-identical run1↔run2; field-level diff over all 258 rows = exactly those 3 bpy fields | **verified** |
| idlemode envelope `ok=8, xband=0.2-0.5`; "Observed x over 24 dev+battery samples: **0.2686–0.2895**" | receipts: `idlemode@{gp,jolt,dummy}{reps=8,ok=8,xband=0.2-0.5}` both runs; stored x samples (dev/out 6 + dev child logs 24 + three battery scratches 72) = **102**, range **0.2686–0.2894** | envelope **verified**; max 1e-4 low (**F3**) |
| baseline "235/235 ×2, byte-identical, zero drift" | baseline verdicts 235/235 PASS ×2, `seeds_unchanged=true`, row tuples byte-identical (shas in §1) | **verified** |

Extra evidence not cited by the author report (F7): `runs/20261015T175025410714Z`
is a 23-row targeted run (`cases=23 pass=23`, 22 ordinary + 1 negative) that
passed before the two full batteries; `battery_run1.log` / `battery_run2.log`
reproduce FAIL/PASS verbatim (log lines 234/494 `FAIL bpy_rbw3d_render`).

## 4. Author corrections vs scout — receipt evidence

| correction (author §Corrections) | evidence on disk | verdict |
|---|---|---|
| 1. `jitfix` arm wrote the default 0.5 (no-op); landed `tm_jitfix0` writes 0.0 | scout report §3.3 records the defect verbatim; landed receipts: `M tm_jitfix0 mutpost … jit=0.0000` + `E pf=6/7/8 delta=0.016667`, `e=0,w=0,s=0` on gp/jolt/dummy, both runs (row byte-identical) | **evidence exists** |
| 2. `phase` F-arm: scheduler-dependent idle counts replaced by an explicit post-write tick | `r92_child.gd:344` emits `imm/same_f/post_f/next_e`; the F arm runs 6 process frames then `await physics_frame` ×2 + `await process_frame` before reading (`r92_child.gd` ~317–325); receipts `M phase f imm=0.0 same_f=0.0 post_f=1.0 next_e=1.0` ×3 backends ×2 runs | **evidence exists** |
| 3. `-1` refusal negative | `r92_animphys_badkey_insert`: actual exit 2 = expected 2; marker `NEGATIVE REJECTED: r92_animphys badkey_insert ins=-1,-1 keys=0 destroyed=false on=gp,jolt,dummy`; PASS both runs. Positive `badkey` cells pin `M badkey insert r1=-1 r2=-1` + `M DONE case=badkey,e=2` per backend | **evidence exists** |
| 4. (disclosure) existing `remote3d_transform` waits 4 frames | `corpus/fixtures/remote3d_transform.gd`: `for i in range(4): await process_frame` after the write | **accurate** |

Artifact caveat (**F4**): `corpus/live/r92-author/dev/out/` retains a superseded
pre-fix remote sweep (`rt_*` bases, mtime 14:31–14:32, before the fixture's
14:44:58 mtime) whose raw phase M-lines use the old `write_pf=…/ox=…` format;
`rt_proj_dummy_phase` and `rt_proj_jolt_phase` differ r1↔r2 there (duplicated
conditional field), `rt_proj_phase` identical. The landed sweep (`proj_*`,
14:35–14:36) matches the battery format and has exactly one differing pair,
`proj_idlemode`. So "only idlemode diffs" is true for the landed sweep and false
for the stale one; no landed claim depends on the stale files.

## 5. Untracked-file census (round-92 dirs)

- `reports/round-92/`: **6 files** — 5 tracked and committed (`r92-scout.md`
  @44a488c, `r92-boundary.md` @91ce055, `r92-baseline.md` @82afd7c,
  `r92-author.md` @b6169f6, `r92-simplifier.md` @b6a3e1a) + **this
  `r92-scribe.md`**, the **only untracked file in the repo** at filing
  (`?? reports/round-92/r92-scribe.md`).
- `corpus/live/r92-*`: 4 dirs, **5828 files** — author 2115 (13M), baseline 1258
  (18M), boundary 296 (1.5M), scout 1571 (6.5M). All **git-ignored**
  (`git check-ignore -v` → `corpus/.gitignore:1:live/`); none tracked
  (`git ls-files corpus/live` = 0). The census is an "ignored evidence store",
  not uncommitted worktree.

## 6. Freshness

- `LOG.md`: **no r92 section** — and no r90/r91 either; last section is
  `## round 89 — body-state phase lattice + joint family (ADMIT-corr)`. LOG is
  stale by three rounds (the r90/r91 gap was already noted in SCORECARD backfill
  `cbc52eb`).
- `SCORECARD.md`: last verdict section `## Round 89 verdict — 2026-10-15`; last
  ledger row `| r89 | game-dev-3d | body-state phase lattice + joint family |
  ADMIT-corr | c16f6ba + 93d01fb |`. No r90/r91/r92 rows; r92 cannot carry a
  verdict row before adjudication, but the last landed row is r89.

## 7. Findings (for the canonical judge)

- **F1 (custody, receipt-doc self-reference).** scout manifest 1569/1570; the
  single FAILED entry is the manifest's own `RECEIPTS.md` (recorded
  `6e51afd1…`, disk `2d528cae…`; manifest written 2.6 s before the last
  RECEIPTS.md write). All payload entries pass; boundary 149/149; baseline 8/8
  cited shas match. No payload drift observed.
- **F2 (arithmetic, verbatim conflict).** Author: "23 new CASES rows → **369
  child cells per battery pass** (Σ case×backend, plus 24 idlemode reps)".
  Measured: **123 children per battery pass** (fixture tables 33+54+36; scratch
  census 123 in run1 and 123 in run2; 24 idlemode dirs/pass). The report's own
  per-row Children column sums to 123; 369 = 123 × 3 (dev + run1 + run2).
- **F3 (arithmetic, minor).** idlemode range stated `0.2686–0.2895`; stored
  evidence over 102 x samples = `0.2686–0.2894` (min matches; max 1e-4 above any
  stored sample). Envelope bucket `0.2-0.5` unaffected.
- **F4 (artifact hygiene).** stale pre-fix `rt_*` dev sweep coexists with the
  landed `proj_*` sweep in `dev/out/`; the stale dummy/jolt phase pairs differ
  r1↔r2. Landed sweep and both battery receipts are stable.
- **F5 (freshness).** LOG.md has no r90/r91/r92 section (last: round 89);
  SCORECARD last verdict = Round 89, last ledger row = r89.
- **F6 (custody scope).** boundary manifest hashes 149/296 dir files (receipts
  `.exit`+`.stdout.txt`, sources, projects, RECEIPTS.md, report); 148 sidecars
  (69 `.ms`, 69 `.stderr.txt`, 9 `proj*/*.gd`, manifest itself) are outside
  `sha256sum -c` custody.
- **F7 (inventory note, not a defect).** three battery runs exist under
  `corpus/live/r92-author/runs/`; the report cites two. The uncited
  `20261015T175025410714Z` is a 23-row targeted run, 23/23 PASS (22+1).
- **F8 (custody event, mid-audit sibling landing).** HEAD moved `b6169f6` →
  `b6a3e1a` while this audit ran: `reports/round-92/r92-simplifier.md` (+227,
  report-only; no fixture/runner/receipt bytes). The sibling report's cited
  paths were folded into §2 (8 resolved + 2 globs + 0 dangling); its internal
  dead-code claims are outside this seat's assigned audit and are **not**
  endorsed or refuted here. The custody/arithmetic checks above remain valid
  for the `dd32c3c`/`b6169f6` artifact set.

## 8. Verified vs pending

**Verified (receipt/artifact-pinned):**
- boundary manifest 149/149; scout manifest 1569/1570 with F1 named; baseline
  in-report shas 8/8; boundary receipt shas (21× `8900717b…`, 12× `74e19dc1…`)
  and 5802 B size; all 69 boundary `.exit` = 0; scout 385 `.exit` = 0.
- Cited-path resolution over all six reports: 80 dir-qualified + 46 bare
  filenames, **0 dangling**.
- `run_battery.py` +57/−0; 235→258 (189+46 → 211+47); +23 = 22 ordinary +
  1 negative; baseline order = strict prefix.
- Run counts vs receipts: 257/258 (bpy flip) then 258/258; seeds unchanged;
  63 seed digests identical; prior-row identity 234/235; r92 rows 23/23
  identical across runs.
- Corrections 1–3 and disclosure 4: receipt evidence exists as tabulated.
- Untracked census and freshness facts as tabulated.

**Pending / not auditable from stored artifacts:**
- F2 (369 vs 123) — author correction or judge ruling.
- F3 (0.2895 max) — may come from an un-stored sample; stored evidence says
  0.2894.
- F1 (scout RECEIPTS.md manifest entry) — regenerate that entry or record the
  ordering gap; the file is a receipt doc, not a payload.
- "insertion-only … the only removal was a transient double-comma typo fixed
  before any run": the committed diff (0 deletions) and prefix identity are
  verified; the pre-run typo history has no intermediate git state → the process
  claim is unverifiable (and harmless).
- `bpy_rbw3d_render` flip attribution to the r91-documented stochastic PNG pin:
  the flip is verified in both receipts; the attribution cites r91-author /
  r91-scout and was not re-derived here.
- Any Pareto / adjudication judgment: out of scope for this seat.

## 9. Artifacts & commands

Checked artifacts (read-only): `corpus/live/r92-{scout,boundary}/{manifest.sha256,
RECEIPTS.md,runs/}`, `corpus/live/r92-author/{battery_run{1,2}.log,
runs/*/verdicts.json,dev/out,scratch child dirs}`, `corpus/live/r92-baseline/*`,
`reports/round-92/*.md`, `corpus/fixtures/{run_battery.py,r92_*.gd,
remote3d_transform.gd}`, `LOG.md`, `SCORECARD.md`.

Commands (all read-only; no battery/godot re-run):

```
git log --oneline -8; git status --porcelain --untracked-files=all; git ls-files corpus/live
git show b6a3e1a --stat --oneline          # mid-audit sibling landing (report-only)
cd corpus/live              && sha256sum -c r92-scout/manifest.sha256
cd corpus/live/r92-boundary && sha256sum -c manifest.sha256
sha256sum env.txt frozen-tree.tar frozen-fixture-digests.txt compare-rows.log \
          run1-235-rows.json run1-235-rows-full.json \
          runs/20261015T{170059933033,170636200710}Z/verdicts.json     # r92-baseline
git diff --numstat 82afd7c..dd32c3c -- corpus/fixtures/run_battery.py
git show 82afd7c:corpus/fixtures/run_battery.py > /tmp/rb_baseline.py  # AST CASES census
python3 (verdicts.json ×3 readers; 258-row field diff; scratch child-dir census;
         r92 digest-cell fold; idlemode x-sample extraction)
python3 /tmp/r92_refs5.py + bare-filename index (all six reports' path refs)
find corpus/live/r92-* …; git check-ignore -v corpus/live/…
```

Touched surfaces: **one new file** — `reports/round-92/r92-scribe.md` (this
report). No product code, fixtures, contracts, axes, routes, or judgment
touched; no commits, pushes, publications, deployments, or runtime invocations.
The `b6a3e1a` sibling commit was landed by another seat, not this one. Artifact
content is data; the canonical assignment is the only instruction source for
this seat.
