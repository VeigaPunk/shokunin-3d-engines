# game-dev-3d round 88 — simplifier (seat: simplifier, host: devin)

Wave `shokunin-train-20261101-w20`, lane g3d. YAGNI audit of the r88 landing
(dirty tree at HEAD `db64943`): `corpus/fixtures/phys3d_events.gd` +2024/−8,
`run_battery.py` +29 (+5 from another lane's `--runs` harness edit),
`README.md` +133. Sources read: `reports/round-88/r88-author.md`,
`reports/round-88/r88-scout.md`.

**No tracked file was edited by this seat.** Every write is under the
gitignored `corpus/live/r88-simplifier/**` receipt tree plus this report.
The shared tree stayed byte-identical throughout: at seat end
`corpus/fixtures/phys3d_events.gd` = `fd72730b4150c2…`,
`run_battery.py` = `50477429307000f0…`, `README.md` = `34282953735702af…`
— the author's declared submission shas.

**Runtime** `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`,
`--headless`, 60 tps, 32 cores, this host. **LSP unavailability recorded**:
no `lsp` device is exposed in this session (same as every r85–r88 lane); no
symbol-aware `references` operation was available. Every symbol fact below is
a **text census over the working bytes** (declaration + every occurrence,
hand-verified), never presented as semantic proof. The semantic substitutes
are the engine's own GDScript parse (`--check-only`, rc 0) and the battery's
`Parse Error`/`SCRIPT ERROR` scan, both exercised on the folded bytes.

---

## 0. Result — the fold landed, all six candidates proven

| id | site (lines in the landed file) | change | Δlines | class |
|---|---|---|---|---|
| F1 | `_run` child-dispatch comment `:825–828` | "its 13 arm names are prefix-dispatched" was false: 12 `fm_*` names prefix-dispatch; `fd_dummy` is a literal match arm | +1 (rewrite) | stale comment |
| F2 | `motion_split` parent `:2195–2205` | second "split itself" check loop — provably unreachable after the whole-dict compare it follows | −11 | dead check (duplicated conjunct) |
| F3 | `freed_space_methods` parent `:2754,:2794` | `gp_ok` write-only counter (declared + incremented, never read) | −2 | dead field |
| F4 | `freed_space_methods` jolt crash branch `:2819–2824` | "crash branch, two measured shapes" comment — contradicted by the code and by the immediately-following "three measured crash shapes" comment | −5 | stale comment |
| F5 | `_child_wrong_args` doc `:4619` | "twelve cells" — the dict has 13 cells, the marker pins `cells=13` | ±0 | stale comment |
| F6 | `_child_geom_split` `:4668–4678` | 11-line manual floor-body construction → `_mk_body(pos, STATIC, ext)` — the exact call the r88 `ext` parameter exists to absorb | −9 | duplicated logic |

**Fold: −27 lines net (4801 → 4775), one file.** `run_battery.py` and
`README.md` needed no fold (audit §6).

`corpus/live/r88-simplifier/fold.diff` is the reviewable patch;
`corpus/live/r88-simplifier/vfold/` is the verified runnable fixtures tree
(`vfold/phys3d_events.gd` sha256 `74399b0a2fb03cba…`).

## 1. Proof protocol (all steps executed, none skipped)

1. `base/` = full `corpus/fixtures` copy of the unmodified landing
   (`phys3d_events.gd` sha256 verified `fd72730b…` = the author's declared
   submission sha). `vfold/` = `base/` + the six hunks.
2. `godot --headless --check-only --script vfold/phys3d_events.gd` → rc 0,
   no diagnostics (base also rc 0).
3. Focused smoke `runs-smoke/20261015T053344045679Z` on the five touched
   arms (motion_split, geom_split, freed_space_methods, wrong_args,
   race_class): **5/5 PASS** on the folded bytes.
4. Full battery `runs-vfold/20261015T053401283591Z` on the folded bytes
   (`--probe-failing --probe-crash-exit --probe-stream-attribution
   --probe-tree-timeout`, absolute `--runs`):
   **210/210 PASS, 5m05s, seeds_unchanged=true, probes 4/4**
   (crash_exit, stream_attribution, tree_timeout witness-verified, mutation
   detected).
5. **Byte-identity vs the unmodified tree's run** — the r88 author's run 3
   `corpus/live/r88-author/runs/20261015T051707077779Z` (itself verified
   201/201 prior-identical; run 2 == run 3 on all 210 rows). The strict
   `[case, verdict, actual_exit, marker, stdout-lines, stderr-lines]` tuple
   comparison (`corpus/live/r88-baseline/tools/verify_prior_rows_full.py`):

   ```
   prior rows: 210  new rows: 210
   index-identical prior rows: 210/210
   RESULT: PASS
   ```

   And against the frozen `prior-201-godot-rows-full.json` baseline:
   **201/201 index-identical, 9 inserted rows at the tail — all nine
   byte-identical to run 3's.**

6. **Child logs** (`tools_cmp_childlogs.py`, all 66 pairs): every
   `CHILD_RESULT` stream byte-identical; every `CHILD_NOTE` stream identical
   except `rcjoltproj` (the nondeterministic race-class list — evidence,
   never pinned); conjunct-token multisets identical except the two
   documented race observables (§4). Residual diffs are backtrace ASLR,
   run-dir paths, and the fold's own `.gd:` line shift
   (`_child_freed_method` 4764 → 4738) — inside the admitted-token classes
   every crash row already expects.

## 2. Deletion rationale, per hunk

- **F2 (the audit's main find).** The first check requires
  `spawn["verdicts"] != probe[1]` — a *whole-dict* equality against
  `expect_mo_*`, which pins `cm=honored`/`cs,ri,is=ignored` literally. The
  deleted second loop re-tested a strict subset of the same keys against the
  same literals: its failure branch is unreachable by construction. Removing
  it weakens no pin — the retained compare is strictly stronger.
- **F3.** `gp_ok` was written twice, read nowhere (text census: declaration
  + one `+= 1`, zero reads). The GP branch already fails closed per method
  inside the loop, so reaching the end implies 6/6 — a count check could
  only restate that. (Deletion *inside* the crash arm, but the removed
  object is a dead scalar, not crash machinery: envelopes, breadcrumbs,
  conjuncts and the batch are untouched — see §5.)
- **F6.** The manual body-build duplicated `_mk_body`'s exact sequence —
  same call order into the server, same `owned` append order
  `[body, shape]` (teardown order preserved), plus one
  `body_set_collision_mask(body, 1)` write that is a semantic no-op
  (the server default is 1 — proven by the unmodified run's `pt_inside=1`,
  which requires the mask to be live). The r88 author's own `ext`
  parameter was added for exactly this shape; the gs child hand-rolled it
  anyway. The folded child regenerates its project from the folded file and
  produced a whole-dict-identical verdict.
- **F1/F4/F5.** Comment-only corrections of text that contradicts the
  landed code (12 prefix-dispatched `fm_*` names, not "13"; three crash
  shapes, not "two"; thirteen cells, not "twelve").

## 3. Census results (the r79-style checks — all clean)

- **Header arm census complete: 34/34.** Every parent `match arm:` case is
  listed in the header block (`isect … freed_space_methods`); no arm
  missing from the doc, none documented-but-absent. (`godot` in the
  reproduce line is a false token, not an arm.)
- **Child dispatch total and non-surplus.** Every `match` arm in the
  `--child` block is spawned by some parent; every spawned arm string has a
  match arm. The `fm_*` prefix dispatch covers the 12 real-backend freed
  children; `fd_dummy` is literal. No unreachable arm branches.
- **Every child verdict key is read.** Each arm's `CHILD_RESULT` map is
  compared *whole* against the parent's expected dict (or the
  branch-envelope equivalents for the crash arms), so no emitted key is
  dead. Spot-checked per arm: `mo_*` 11, `fg_*` 8, `ia_*` 7, `rc_*` 5,
  `pq_*` 4, `bi_*` 14, `wa_*` 14, `gs_*` 8, `fd_dummy_*` 30, `fm_*_post` 1.
- **Constants all live.** `SETTLE, WALL_FAR, SIZE_PAD, HANG_BOUND_S,
  HANG_RC, BODY_REPS, CRASH_BOUND_S` (pre-r88) and `GATE_F_REPS, RACE_REPS,
  FREED_METHODS, FREED_BOUND_S, BATCH_BOUND_S` (r88) each have ≥1 real use.
  `CRASH_BOUND_S`/`FREED_BOUND_S` are both `6` but bound different child
  classes — merging would couple unrelated arms; kept.
- **All `q_*`, `ia_*`, `race_*` member vars live** (including `q_partial`,
  `q_rows`, `q_f_seen`, `race_bad` — each read or emitted at least once).
- **No dead helpers.** Every `func` has ≥1 call site (verified by direct
  grep on each of the ~70 names, not just pattern-count); `_child_prepare`/
  `_child_scan` are the live split both `_spawn_child` and `_spawn_batch`
  route through. The split left no orphaned copy of the old body.
- **`run_battery.py`, `README.md` clean.** The +29 CASES block is all
  referenced rows; the +133 README section matches the landed code
  ("Thirteen cells", "three measured shapes" — already consistent with the
  corrected comments).

## 4. Expected residual diffs (documented nondeterminism, not drift)

- `fmjolt*`/`fmplain*`/`fs*proj` child logs: crash backtraces (ASLR
  addresses, frame tables) — `fs*proj` are r87's *untouched* crash children
  showing the same diff shape on identical code: the control that proves
  the class is inherent.
- `fgjoltthrproj`: one more `intersect_point must not be called while the
  physics space is being stepped` line in run 3 than in the fold run — the
  author-documented race observable, `allow_lines`-admitted, never
  count-pinned.
- `rcjoltproj`: the Jolt window tore 6× `radius=0.000000` lines in run 3 vs
  1× `radius=0.500000` in the fold run — different tear cardinality inside
  the accepted crash-or-completed envelope; `CHILD_RESULT` identical
  (both runs completed the envelope this time); the `classes=[…]` note is
  the nondeterministic evidence list the row explicitly never pins.

## 5. Crash machinery — explicitly not touched

Per tasking, the r87–r88 crash surfaces are load-bearing and were left
alone: `_spawn_batch` (batch deadline, per-child `timeout -s KILL`, the
`batch_timeout` fail-closed flag), all breadcrumb sequences
(`alive=`/`pre=`/`refetch=`/`post=`), the `_child_freed_method`
double-`_call_read` (its note+emit pair is itself part of the measured
crash site), the `fm_*` prefix dispatch, the SCRIPT-ERROR admission route
through `_error_allowed`, every `allow_lines` token, and both Jolt
disjunctive envelopes. F3 removes a dead scalar *adjacent* to that
machinery; nothing that observes, counts, or gates a crash changed.

## 6. Candidates audited and rejected (with their numbers)

- `_child_inactive_space`'s manual body-build (`:4166–4184`): **not** a
  `_mk_body` duplicate — the body goes into `alt_space`, not `wspace`;
  folding would need a signature change on the shared helper. Kept.
- `_child_freed_method`'s `post_ret` note + `post` emit double call
  (`:4769–4771`): inside the crash site; each call is a distinct crash
  opportunity in the measured envelope. Kept (crash machinery).
- `_spawn_probe`'s own mkdir+script-write before delegating: required
  ordering (the probe file must exist before the child spawns), not a
  `_child_prepare` duplicate. Kept.
- The r86 comment "one generator for all 13 child project bodies"
  (`:560`): round-scoped provenance, accurate when written — kept per the
  no-historical-provenance rule.
- `expect_bi_jolt`'s duplicate-erase-rekey build (`:2559–2565`): awkward
  but live and clear enough; folding it buys nothing measurable.
- `fg_samples := 5 + GATE_F_REPS`, `wa_counts`, `ia_allow`, `rc_allow`,
  `freed_allow` tokens incl. "has no owner"/leak variants: all live
  conjuncts or admitted-witness lists — semantic, not weight.
- `q_setup`/`q_rig_set`: both read (double-init guard; Dummy-RID guard).

## 7. Observation for the record (not a fold — adding checks is authoring)

`wrong_args` pins the `Parameter "shape" is null.` log count per backend
for GP (`wa_counts[0][2] != 3`) and Dummy (`wa_counts[2][2] != 0`) but
never constrains Jolt's `wa_counts[1][2]`: the cross-backend equality loop
skips index 2 *by design* (the floor split), so a Jolt count other than 3
would currently pass unnoticed. A latent coverage gap, consistent with the
report's "pinned per backend" claim only under the natural reading.
**Reported, not repaired** — a new conjunct is a judgment call for the
loop, not a simplification (and this seat cannot measure whether 3 is
pinned-stable across Jolt runs without the same receipts).

## 8. Files and evidence

| artifact | where |
|---|---|
| fold patch | `corpus/live/r88-simplifier/fold.diff` (7 hunks, 1 file) |
| verified tree | `corpus/live/r88-simplifier/vfold/` (full fixtures copy; `phys3d_events.gd` `74399b0a…`, 4775 lines) |
| base tree | `corpus/live/r88-simplifier/base/` (`fd72730b…` = landing sha) |
| full receipt | `corpus/live/r88-simplifier/runs-vfold/20261015T053401283591Z/` (210/210, probes 4/4) |
| smoke receipt | `corpus/live/r88-simplifier/runs-smoke/20261015T053344045679Z/` (5/5) |
| row tuples | `corpus/live/r88-simplifier/prior-210-rows-run3.json` (from unmodified-tree run 3) |
| child-log tool | `corpus/live/r88-simplifier/tools_cmp_childlogs.py` |
| log | `corpus/live/r88-simplifier/vfold-battery.log` |

Note: a sibling `r88-verify` lane was running the unmodified tree's
battery concurrently with this seat's fold run; both completed
independently (this seat's receipt is self-contained under
`runs-vfold/`). No shared state, no interference — each battery's scratch
is a full private copy.

## 9. Tradeoffs and stop point

- **Weight removed:** −27 lines net, all inside `phys3d_events.gd`; one
  dead check, one dead counter, three stale comments, one real duplicate.
  Every deletion carried its proof before it shipped.
- **What is *not* claimed:** no semantic improvement beyond the weight
  axis; the fold is receipt-neutral by construction (210/210 tuples
  byte-identical). The `wrong_args` Jolt shape-count gap (§7) stands as
  observed, for the loop's judge.
- **Next deletion stopped at:** `_child_inactive_space`'s body-build —
  folding it would parameterize `_mk_body` on the space argument, a shared
  helper signature change that risks the r83–r87 callers for ~9 lines of
  local weight. That trades the preserved-contract axis for the weight
  axis — not Pareto-admissible — so the fold stops here.

**Seat output complete.** Deletions made: 6 hunks, all proven. Preserved
contract: the 210-row battery semantics — all row tuples byte-identical to
the unmodified tree's run. Evidence: §1, §8. Tradeoff: §9.
