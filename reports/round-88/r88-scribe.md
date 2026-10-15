# game-dev-3d round 88 — scribe (seat: scribe, host: devin) — r87 closeout audit

Round 88 · wave `shokunin-train-20261101-w20` · lane g3d. Brief
(`.ufo/waves/shokunin-train-20261101-w20/tasks/g3d-r88-scribe.md`, verbatim):
re-derive the r87 closeout from the repo record — commits `c57fa40` (work),
`a11e1ad` (fold), `db64943` (report-last); `reports/round-87/*`; `LOG.md` /
`SCORECARD.md` entries; receipts under `corpus/live/` (r87-* seat trees +
`runs/`). Checks: ledger arithmetic vs actual diffs; adjudicator claims vs
real receipts; unrecorded mutations; critic F1/F2 envelope conjuncts landed
in `phys3d_events.gd`; author `+880/−4` vs actual `+876/−4`.

**Read-only honored.** No tracked file modified, no commit/push, no battery
or engine re-run by this seat. Every number below is re-derived from
committed blobs/diffs or from on-disk receipts under gitignored
`corpus/live/`. HEAD at audit time: `db64943` (`git status --porcelain` =
`?? reports/round-88/` only — this report plus the in-flight
`r88-scout.md`; no dirty tracked state).

Runtime context: Godot `4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`,
60 tps, this host.

---

## 1. Ledger arithmetic vs actual diffs

### 1.1 Work commit `c57fa40` — author's `+880/−4` is `+876/−4` ✓ (as recorded)

`git show --numstat c57fa40`:

| file | + | − | author claim (r87-author.md §0/§10) | match |
|---|---|---|---|---|
| `corpus/fixtures/README.md` | 90 | 0 | +90/−0 | ✓ |
| `corpus/fixtures/phys3d_events.gd` | **876** | **4** | **+880/−4** | ✗ −4 on insertions |
| `corpus/fixtures/run_battery.py` | 14 | 0 | +14/−0 | ✓ |
| `reports/round-87/r87-author.md` | 398 | 0 | new | ✓ |

The slip is real and the record handles it correctly: reviewer §11.1,
verifier claim 19, and scribe §2 all flag `+880` as the `git show --stat`
churn figure (876+4), and adjudicator `r87-adjudicator.md` records the fix
verbatim ("author's `+880/−4` is `+876/−4`"). `SCORECARD.md` r87 carries the
corrected `+876/−4`. The source report is unedited (as it should be —
corrections live in the ledger, not by rewriting the claim).

### 1.2 Fold commit `a11e1ad` — committed delta vs attributed portions

`git show --numstat a11e1ad`: `README.md` +15/−6, `phys3d_events.gd`
**+171/−138**, `run_battery.py` +2/−2.

- **Simplifier portion.** `corpus/live/r87-simplifier/fold.diff` counted
  directly: 87 `+` lines / 119 `−` lines, minus 2 `+++`/`---` header lines
  → **+85/−117**, exactly the figure in the adjudicator, `LOG.md` r87
  FOLDS line, and `SCORECARD.md` calibration cell. ✓
- **Critic + record-fix portion.** Remainder on `phys3d_events.gd` =
  +86/−21 — the F1/F2 crash-site envelope blocks, F3 refusal-count
  conjuncts, F5 `ss_fired` emit/pin, and the corrected `_log_count`
  docstring. Consistent with the commit message and adjudicator text.
- `run_battery.py` +2/−2 = exactly the two expected-marker string edits
  (`two_fetch=true` dropped from `body_handle`, `tally=8` dropped from
  `write_loss`) — the marker-side of simplifier P1/P2, verified in the diff.
- `README.md` +15/−6 = the F1/F2 narrative correction (per-backend crash
  site, breadcrumb envelope documented, "the crash-line count alone is
  self-printable (r87 critic F1)"). Verified in the diff.

### 1.3 Report-last `db64943` — ledger + reports

`git show --numstat db64943`: `LOG.md` +27, `SCORECARD.md` +11, plus seven
new reports (adjudicator 77, baseline 372, critic 187, reviewer 430, scribe
216, simplifier 418, verifier 289) — all present on disk, byte-matched to
the commit. `LOG.md` r87 block (lines 1132–1158) and the SCORECARD r87
verdict table + history row restate the numbers verified above.

**Provenance note:** `reports/round-87/` holds 9 files. Eight were committed
in r87 commits; the ninth, `r87-scout-dss.md` (+246), was committed inside
the **r86 report-last** commit `af15a52` (scout ran ahead of the r87 work
window and the r86 sweep picked it up). The file is fully recorded — it just
does not live in an r87-named commit.

## 2. Adjudicator claims → receipts

`r87-adjudicator.md` claims vs what this seat found on disk:

| claim | verdict | receipt(s) |
|---|---|---|
| "201/201 folded battery" | **TRACES** | `corpus/live/runs/20261014T233857299128Z/verdicts.json`: PASS `cases=201 pass=201 fail=0 ordinary=155 negative_controls=46`, `seeds_unchanged=true`, `seed_digests.phys3d_events.gd = bbdac03f…` = the committed `a11e1ad` blob sha (re-hashed by this seat). Companion focused receipt `runs/20261014T233818294145Z`: 6/6 on the same folded bytes. **Caveat:** both receipts sit in the shared `corpus/live/runs/` root — no seat attribution recorded (every other r87 seat used a namespaced dir). |
| "195/195 prior rows byte-identical (semantic fields)" | **TRACES** | Author `prior_rows.py` output quoted in §9.1 (0 mismatches ×3 runs); reviewer C2 three-way comparison incl. its own pre/post pair (0 mismatches); verifier claims 1/3/4; baseline `prior-195-godot-rows.json` sha `dd8812be…` + post-commit verify; r87-scribe tuple-sha chain (r86 green tuple `eb710364…` is a strict prefix). On folded bytes specifically: simplifier `cmp_rows.txt` shows only the 4 intended new-row marker/stdout diffs over 2412 fields; the fold's marker edits touch only rows 196/199 (new rows), so prior-195 identity is preserved by construction plus replay on the vfold bytes. No receipt compares prior-195 on the exact `bbdac03f` blob — a small gap, bounded by the diff shape. |
| "Baseline zero-drift both phases, exactly 6 inserted rows @196–201, child-log maps identical" | **TRACES** | `r87-baseline.md` + `corpus/live/r87-baseline/`: frozen `af15a52` 195/195 (sha-pinned archive `91921c10…`), post-commit 201/201, 6 inserted rows at 196–201, 29 child logs compared (23 identical + 6 intended token deltas). |
| "Reviewer AGREE on all 11 claims" | **TRACES** | `r87-reviewer.md` verdict table: C1, C2, C3a–f, C4, C5, C6 = 11 AGREE; receipts sha256-listed (runs-full `25987af8…`, mutations `07944dec…` — file exists on disk). |
| "Verifier (swe-2) AGREE on all landed claims with record-precision notes" | **TRACES** | `r87-verifier.md`: 20-row claim table all AGREE except claim 20 partial (mechanism prose — GP crash site) and claim 19 "two slips"; own battery `runs-abs/20261014T224349463988Z` = 201/201 + 4/4 probes PASS. Its two earlier `runs/` receipts show top-level FAIL with 201/201 case pass — the documented relative-`--runs` tree-timeout trap (`witness_verified=false`), pre-existing since r71, not an r87 defect. |
| "Author correctly refused the scout's nav cell — safe_n=0 8/8 vs claimed 10; harness artifact; verifier re-derived 17/17" | **TRACES (r86 record)** | This is the **r86** story restated as a record correction: `corpus/live/r86-author/nav-replication/RERUN.md` = `safe_n=0` in 8/8 fresh processes; `corpus/live/r86-verifier/nav/` (E1–E5 + `nav_repro.json`) = `safe_n=10` line-identical in 17/17 with any `project.godot` present; r86-adjudicator recorded both sides. r87 carried no nav cell; "deferred to r88" restates the r86 adjudicator's "r87 may re-arm" — deferral rolled forward one round. Numbers in the r87 text match the r86 receipts. |
| "critic's forge was replayed on the folded tree and fails (`crash-site envelope drift`)" | **ASSERTED, NO RECEIPT FOUND** | The forge tree `corpus/live/r87-critic/forge/` is a **pre-fold** (c57fa40-based) patched copy whose child logs demonstrate the original forge PASS. No file under `corpus/live/` contains the string `crash-site envelope drift` as observed output (scan of every `verdicts.json` reasons/marker/stdout/stderr = zero hits; only fixture source and this report's citations match). No artifact was written under `corpus/live/` in the fold window other than the two unattributed `runs/` receipts. The failure is forced by inspection — the forge prints no `held=` note, so `_log_count(fs_gp_log,"CHILD_NOTE fs_plain held=") != 1` fires — but the claimed replay itself is unreceipted. Recorded verbatim for the judge. |
| "simplifier fold +85/−117, replay-verified" | **TRACES** | fold.diff arithmetic in §1.2; `runs-vfold/20261014T220217401209Z` = 201/201 on folded bytes (seed `d6c08908…`, the vfold variant — the committed blob additionally carries the critic/record changes). |
| "F3 refusal counts == BODY_REPS" | **TRACES, landed** | Fixture `phys3d_events.gd:1518–1524` (`auplainproj`/`aujoltproj`) and `:1615–1620` (`wlproj`): `_log_count(child.log, "Body state is inaccessible") != BODY_REPS` → `_fail`. |
| "F5 ss_fired pin makes dummy_cb=never honest" | **PARTIAL — half of the critic's fix landed** | `ss_fired` is emitted bucketed (`:2481` `"0" if ss["fired"]==0 else ">0"`) and pinned (`bh_dummy_ss_fired:"0"`, real backends `">0"` — `:1435/1445/1458`). Critic F5a recommended pinning **`bh_dummy_if_fired` as 0 too**; `if_fired` remains CHILD_NOTE-only (`:2473`). A Dummy that fires only `_integrate_forces` would still produce `if_same=false ∧ ss_fired=0` and pass `dummy_cb=never`. The sync-callback half is now a conjunct; the integrate-forces half is still commentary. Unflagged in the closeout. |
| "ss_same runs 5/5 not 4/4" (record fix) | **TRACES** | `corpus/live/r87-author/runs-final/…/bhplainproj/child.log:3` shows `ss=5/5` — the author's "4/4 ticks" understates by one; verifier claim 19 recorded the same. |
| "`_log_count` docstring no longer claims self-print impossibility" | **LANDED** | Folded comment (`:471–477`) now reads "a text match ALONE is self-printable (r87 critic F1)"; the pre-fold "a self-print cannot manufacture" wording is gone. |
| "bpy 83/83, three.js 31/31, seeds_unchanged" | **TRACES** | Author `bpy-final/bpy-20261014T214816011070Z` 83/83 sha `6a98c570…`; six `three-final-*.json` = 31/31 `seedsUnchanged=true`; reviewer re-ran both independently. |
| "scouts' write-loss did not replicate — accounted tally, race=bounded" | **TRACES, honest** | Scout's original evidence is real: `r87-scout-dss/runs/fl_proj_thr.r1.stdout.txt:74` `SLEEP srv_sleeping=false` vs r2 `true`. Retained author-side subset (5 wlproj logs + fxcheck + thr_wloss) all `lost=0`; the full "144 writes / 4 forms" set is not fully retained on disk (verifier noted same). The marker claims `race=bounded` only — no unwitnessed loss claimed. |

## 3. Critic F1/F2 fixes — envelope conjuncts in `phys3d_events.gd` ✓ LANDED

Worktree `phys3d_events.gd` sha256 `bbdac03f…` == `a11e1ad` blob (re-hashed).
The work-commit version (`c57fa40`, sha `0e5e64f4…`, 2752 lines) had only the
crash-line + empty-verdicts + rc checks; the fold added the per-backend
breadcrumb envelope. Verified conjuncts in the landed file:

- **GP (`fs_plain`, :1759–1763):** `held=` count ==1 AND `held=nil` ==0 AND
  `space=` ==0 → else `_fail("freed_space plain crash-site envelope drift")`.
  This is the F2 site correction: GP dies *inside* `held.get_space_state()`,
  so `space=` must never print.
- **Jolt (`fs_jolt`, :1790–1796):** `held=` ==1 AND `held=nil` ==0 AND
  `space=` ==1 AND `ray` ==0 → the kill is at `intersect_ray` after the
  space-state object returns.
- Retained companions on both: `rc ∈ {134,137}` (`:1753`, `:1780`), verdicts
  empty, exactly one engine crash line (`:1751–1758`, `:1777–1786`), Dummy
  floor `{fs_dummy_ray:"empty"}` rc 0 (`:1797–1801`).
- Header/arm comments and README now state the per-backend sites and that
  the line count alone is self-printable.

One-line `prints()`+`quit(134)` forge can no longer pass `fs_plain` (zero
`held=` notes). Residual is what the adjudicator states: envelope-level, not
absolute — a forge replaying the correct per-backend partial note sequence
still satisfies the counts (flagged for the r88 mutation pass).

## 4. Unrecorded mutations — none found

- `git status --porcelain`: `?? reports/round-88/` only. No tracked file
  modified vs `db64943`; worktree fixture shas == committed blobs
  (`phys3d_events.gd bbdac03f…`, `run_battery.py f9e31098…`,
  `README.md 904393b9…` — the README sha was not pre-declared by any seat;
  re-hashed here).
- `git fsck --unreachable --no-reflogs`: no output (no dangling commits).
- All 9 `reports/round-87/*` files are tracked; the only oddity is the
  scout report's commit placement (§1.3), which is recorded, not hidden.
- `corpus/live/` is gitignored (`corpus/.gitignore:1` = `live/`) — seat
  receipt trees are host-local by design; no tracked-surface writes leaked.
- Branch is 15 ahead of `origin/main` — consistent with the lane's
  no-push contract, not a mutation.
- In-flight r88 wave state observed (out of audit scope, noted for
  completeness): untracked `reports/round-88/r88-scout.md` +
  `corpus/live/r88-baseline/` tree (frozen extract + run dirs). The scout
  report itself records that `phys3d_events.gd` was untouched by it and
  that r87's diff was in flight.

## 5. Secondary observations (verbatim, for the judge)

1. **Unreceipted claim:** the post-fold forge replay asserted by the
   adjudicator has no durable receipt (§2). Forced by inspection;
   unreceipted as written.
2. **Unattributed receipts:** the folded-bytes battery pair under
   `corpus/live/runs/` (23:38Z, pre-commit clock) carry no seat tag.
3. **F5 half-fold:** `if_fired` unpinned; `dummy_cb=never` earns the
   sync-callback half only (§2).
4. **Mutation 6/6 chain is complete but two-stage:** author declared,
   r87-scribe recorded "declared, not receipted" at the time; reviewer
   (`mutations-20261014T220033Z.json`, exists, 6/6 detected) and verifier
   (re-ran `mutations.py`, 6/6) independently receipted afterward. The
   ledger's final state is consistent.
5. **Wave-tag drift:** r87 reports cite wave `w18` (author, scribe) and
   `w19` (baseline/critic/reviewer/simplifier/verifier/adjudicator); the
   report-last commit says "wave-B reports". Cosmetic; no claim turns on it.
6. **Known tool artifact (carried forward from r87-scribe):** baseline's
   `verify_prior_rows_full.py` dies mid-compare (`IndexError`, list-tuple
   vs dict) — recorded; equivalent field-wise comparison showed zero diffs.
7. **Pre-existing trap, not a defect:** verifier's two relative-`--runs`
   battery receipts are top-level FAIL with all 201 cases PASS
   (`witness_verified=false` tree-timeout contract, documented since r71).

## 6. Behavior / gates / surfaces

- **Behavior:** read-only audit of the r87 closeout; no git mutations, no
  fixture edits, no engine/battery executions. All arithmetic re-derived
  from `git` objects and on-disk receipts.
- **Gates exercised:** none (no battery run). Fixture-level gate reads are
  text inspection of committed blobs.
- **Touched surfaces:** wrote `reports/round-88/r88-scribe.md` only.
- **Artifact paths consulted:** `reports/round-87/*.md` (9), `LOG.md`,
  `SCORECARD.md`, `corpus/fixtures/{phys3d_events.gd,run_battery.py,
  README.md}` @ `a11e1ad`, `corpus/live/r87-{author,baseline,critic,
  reviewer,scout-dss,scribe,simplifier,verifier}/`,
  `corpus/live/runs/20261014T2338{18,57}*`, `corpus/live/r86-author/
  nav-replication/`, `corpus/live/r86-verifier/nav/`.
- **Out of scope:** admission/judgment (judge's call), r88 scout/baseline
  content audit, any re-execution of the battery or mutations.
