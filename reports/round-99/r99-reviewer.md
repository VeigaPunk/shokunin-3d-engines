# r99 reviewer — surgical correctness review of the committed animtree landing (`f1ff626`)

Seat: **GAME-DEV-3D r99 REVIEWER**. Task:
`/home/vgpnk/Projects/shokunin/.ufo/waves/shokunin-train-20261015-w22/tasks/g3d-r99-reviewer.md`.
Reviewed artifact: `f1ff626f4d83e67ab841485a56e972e79869535d` ("r99 author: 9
animtree rows (342 total) — 183 cells, beq=1 122/122 backends, clsloop
td-encoded heap abort; 342/342 x2") — **9 paths, +2757/−0**: the parent fixture
`corpus/fixtures/r99_animtree.gd` (+779, new), six probe copies
`corpus/fixtures/r99_probe_r99b_{core,life,modes,silent,sm,untracked}.gd`
(+1825, new), the `run_battery.py` insertion (+29/−0), and the author report.
Claim document `reports/round-99/r99-author.md`; context documents
`reports/round-99/r99-scout.md`, `reports/round-99/r99-boundary.md`.

**No commits, no tracked writes by this seat.** The only new file in the
reviewed paths is this report (left untracked for the operator, like the sibling
seats' reports). All measurement ran from `git archive f1ff626` extracted to
`/home/vgpnk/.cache/r99-reviewer/` (the archive root is that directory); the
worktree was never a seed source. Receipts: `/home/vgpnk/.cache/r99-reviewer/**`
with a gitignored mirror at `corpus/live/r99-reviewer/**`.

**Byte custody.** At seat start `HEAD = f1ff626` with a clean tracked tree
(two pre-existing untracked reports from rounds 94/95). Mid-seat `HEAD` moved to
`b3d366e` (sibling **r99 critic**, report-only):
`git diff --name-only f1ff626..HEAD` = `reports/round-99/r99-critic.md` **only**,
and `git rev-parse` is **identical at both commits for all eight reviewed
blobs** (parent fixture `75d63cbe…c8bc2`, the six probes, `run_battery.py`
`ff010bd3…fa5335`); a sibling `r99-simplifier` report appeared untracked during
the seat. The bytes this report judges are unchanged.

**Runtime.** `/usr/bin/godot` **4.7.2.stable.arch_linux.ed1daf0bf**;
`/usr/bin/python3` **3.14.7**; 32-core host. Load average read **66–86** for the
whole seat, with the r99 critic/scribe/verifier/simplifier seats and this seat's
own batteries in flight; every rate below is a **loaded-host** measurement and
the load at each data set is recorded with it.

**LSP note (recorded gap).** The MCP inventory on this substrate exposes no
`lsp` device for these files (same recorded absence as r85–r98). This seat made
no source edit, so no symbol-level work was required; the substitutes used were
`--check-only`, `py_compile`, an AST census of `CASES`, a dumper that evaluates
the committed fixture's own cell tables, a from-scratch normalizer, battery-level
mutants, and direct-child experiments.

**`probeParent` seat.** Exactly one read-only `ufo-labrat` was dispatched (a
bounded static probe of the `td` encoding: "can any outcome other than a
pre-marker-complete run with rc ∈ {0,134} satisfy the committed clsloop
marker?"). It returned a usable **static** result — every acceptance path
requires marker + unchanged pre-marker sha + rc ∈ {0,134}, and it identified the
post-marker information loss — but its tool surface has no exec, so its dynamic
phase is "could-not-test" and is covered by this seat's own M5/M6/M7 mutants
below. Advisory only; it edited nothing. No other descendants were spawned.

**Method.** (1) Committed-diff shape (numstat, char-level prefix/suffix,
line-level opcodes, insertion census). (2) Parse checks on the canonical
runtime. (3) Census: AST of `CASES` **and** the committed fixture's own cell
tables, cross-counted against the committed markers (bijection, per arm, in
order). (4) Probe provenance vs the boundary's own probe sources **and** the
boundary manifest pins. (5) **Receipt custody**: all six author `verdicts.json`
seed digests recomputed against the committed blobs. (6) **Fresh arm sweep**: 5
reps × 9 arms from clean seat-owned scratch copies of the archive (seat-owned
runner, not the author's). (7) **Independent normalizer**: from-scratch
re-implementation of the declared drop/mask rules and of `_extract`/`_cell_text`,
recomputing every pinned cell text from raw child logs over **eight data sets**.
(8) **Independent crosscheck** against the r99 boundary's own child receipts.
(9) **Eight battery-level mutation probes** in seat-owned mutant trees, plus a
refined 3-rep re-measurement of the two `td` mutants. (10) **One full 342-case
battery** from the clean archive plus a focused r99-only pass. (11) **Claim
audit**: every hex/decimal token in the author report machine-matched. (12)
**Direct-child experiments on the committed probe bytes**: 72 `clsloop` runs
with the real rc captured, 24 + 60 parent-path `life`-arm reps, and a
workload-attribution control (`empty`/`freetree`/`clsloop` × 40).

---

## Verified independently

1. **Diff shape — insertion-only, zero existing bytes touched.**
   `git diff --numstat f1ff626^ f1ff626` = **9 paths, 8 `A` and one `M`
   (`run_battery.py` 29/0), 0 deletions anywhere**. A char-level comparison of
   the two `run_battery.py` blobs gives **common prefix 280 070 chars, common
   suffix 26 317, old middle 0, new middle 23 390**; line-level opcodes = exactly
   one `insert old[847:847] new[847:876]`. The inserted block is **11 comment
   lines + 9 two-line `CASES` tuples = 29 lines**, exactly as the author states,
   and the r99 rows are the **contiguous tail, `CASES` indices 333–341**.

2. **Parse.** `godot --headless --check-only --script res://<f>` → rc 0 with no
   `Parse Error` for all **7/7** committed r99 fixtures; `python3 -m
   py_compile run_battery.py` → rc 0.

3. **Census — exact, bijective with the markers, and `beq` is not vacuous.**
   `CASES` = **342 = 283 ordinary + 59 negative**, no duplicate case names, all
   nine r99 rows `expected_exit=0`. A dumper that instantiates the *committed
   fixture* and calls its own `_cells_*` tables gives **183 cells = 61 gp + 61
   jolt + 61 dummy**, name-for-name and in-order identical to the committed
   markers for **9/9 arms** (core 21, ut_scope 21, ut_mech 21, modes 27, order
   12, sm_adv 27, sm_misc 21, silent 15, life 18). Every non-`@gp` cell carries
   `beq=1`: **122 tokens for 122 cells**.

4. **Probe provenance — the six copies are the boundary's bytes, run under their
   original names.** All six `corpus/fixtures/r99_probe_r99b_*.gd` are
   sha256-identical to `corpus/live/r99-boundary/probes/r99b_*.gd` **and** to
   their pins in the boundary's 3 767-entry `manifest.sha256` (6/6 each). The
   fixture writes each copy into the per-cell project under its original
   `res://r99b_*.gd` name, so a child receipt reproduces the source receipt.

5. **The author's receipts are receipts for the committed bytes.** All six runs
   recompute **123/123 seed digests against the committed blobs with 0
   mismatches** (`seeds_unchanged=true` in each): two r99-only pre-runs **9/9
   PASS**, two full batteries **342/342 PASS**, and the two earlier attempts
   **340/342** with exactly the named legacy flakes (`navagent3d_follow` +
   `phys3d_events_deferred_hang`; `navagent3d_retarget` + `r96_joltdet_thread`).
   **All 9 r99 rows PASS in all six runs**, as claimed.

6. **An independent normalizer re-derives every pinned cell, over eight data
   sets.** A from-scratch re-implementation of the declared drop rules (banner +
   blank lines, the exact 2-line Jolt warning at any position, `#N`/`srv=S`/
   `seq=N`/`idle_rows=N`/`pf_rows=N` masking, the per-cell error allowlist with
   `ee`/`ue` routing, the `td` marker truncation) plus independent
   re-implementations of `_extract`, `_field`, `_line_with`, `_pfset` and
   `_cell_text` reproduces the **full committed cell text byte-for-byte**:
   - this seat's own rep-1 children: **183/183, 0 mismatches**;
   - the **full battery run's own children**: **183/183, 0 mismatches**;
   - each of the author's six runs (183 children each): **183/183, 0
     mismatches** —
   **1 464 cell re-derivations, 0 mismatches** in total, including every `sha`,
   every field, `ee`, `mk`, `beq` and `peq`.

7. **Independent crosscheck: the committed pins are the boundary's own
   measurements.** Re-deriving the committed cells from the **r99 boundary's
   child receipts** (`corpus/live/r99-boundary/runs/*.r{1,2,3}.stdout.txt`) with
   this seat's normalizer gives **175 identical / 0 differing per rep → 525 cell
   instances across 3 reps, 0 diffs**. The 8 cells per rep that have no boundary
   counterpart are the `order@{jolt,dummy}` cells: the boundary ran the `order`
   batch on the GP project only (24 children, all `ord_proj_*`), so those are
   *new* cross-backend extensions of the boundary law, and they are covered by
   §6 below.

8. **Fresh arm sweep — 5 reps × 9 arms, every marker byte-exact.** From clean
   seat-owned scratch copies of the archive (7 seeds only, seat-owned runner):
   **45/45 arm runs printed a marker line byte-identical to the committed one**
   (`rc=0`, one `PASS` line per arm; wall 2.0–4.1 s per arm against the 20 s
   case bound), under load 80–86.

9. **Full 342-case battery from the clean archive: 341/342 PASS, all 9 r99 rows
   PASS, `seeds_unchanged=true`.** `corpus/live/runs/20261016T080544898743Z/`
   (seat-owned copy of the committed runner; load 66–86 with four sibling seats
   in flight). **123/123 seed digests recompute against the committed blobs.**
   The r99 rows run **1.80–3.61 s** against the 20 s bound (core 2.64, ut_scope
   2.64, ut_mech 2.56, modes 3.61, order 1.90, sm_adv 3.15, sm_misc 2.62, silent
   1.80, life 2.53). The single non-green row is `navagent3d_retarget_fixed`
   (the documented pre-existing `navagent3d_retarget` one-tick drift,
   `before=1.754246`, not r99) — see §12.

10. **The pins are live — eight battery-level mutants in seat-owned trees.**
   Judged by the battery's own exact-marker assertion:
   - `M1` TimeScale `2.0 → 3.0` (probe): `timescale@gp` `dtp=0.2667 → 0.4000`,
     `tp=0.3500 → 0.4833`, sha `6df30df1… → d5a02313…` — the 2× clock law is
     measured, not restated.
   - `M2` disable the `srv=` mask (fixture): 6 cells' shas move (first:
     `min@gp` `b1b4d7f2… → 0cfc311e…`) — the mask is load-bearing.
   - `M3` drop the `wire` allowlist head (fixture): `wire@gp` loses `ee=1` and
     its sha moves (`bbfe973e… → a7e1f3ad…`) — the allowlist is load-bearing in
     the fail-closed direction.
   - `M4` drop `tp` from the `min` extraction spec (fixture): the cell text
     loses `,tp=0.5333` — the pinned *field set* is asserted, not just the sha.
   - `M5` truncate the `clsloop` case before its marker with rc=0 (probe):
     `clsloop@gp` gains `mk=0` and sha `cd809280…` ≠ pin → row FAILs — the
     marker check is live for `td` cells even when the rc check passes.
   - `M8` drop `tp` from the `ctl` extraction spec (fixture): `ctl@gp` loses
     `,tp=0.1500` — extraction specs are asserted.
   - `M6`/`M7` (the `td` window) — see F2; `M6` is **not detected** and that is
     the finding.
   Two probes also show the F4 note below (`M2`/`M4` print fixture-level `PASS`
   while the marker text has moved).

11. **Claim audit — the report's values are accurate.** All **7** hex tokens in
    `r99-author.md` appear in the committed markers or in a committed blob sha.
    Of the 24 decimal tokens (≥2 digits), the 8 not present verbatim in markers
    are all explained and re-verified: the census (`342`, `183`→61×3, `122`,
    `779` fixture lines), the cross-referenced scout/boundary counts (`132`,
    `292`, `939` — the boundary's `runs/` really holds 939 `.cmd` children), the
    wave date (`20261015`) and `256` (sha256). The author's row/cell arithmetic
    and the probe-sha table are exact.

12. **`corpus/live` is gitignored and this seat wrote nothing tracked.**
    `git check-ignore -v corpus/live/r99-reviewer` → `corpus/.gitignore:1:live/`.

---

## Findings (severity order)

**F1 (MEDIUM — the `clsloop` census is not a process-stable quantity; false-red
only, undisclosed).** The `life` row pins `made=340 skipped=240` inside the
hashed stream, but the number of `ClassDB.instantiate()` successes per process is
**not stable**. Observed on the committed bytes:
- direct child harness, 6-way parallel, 72 runs: **2 runs printed
  `made=360 skipped=220`** (both `dummy`; sha `6934d64c82de4d84` ≠ pin);
- parent-path (the fixture itself, mutant tree): **1 run printed `made=359
  skipped=221`** (`jolt`).

Mechanism, measured in-process: for at least one class the
`can_instantiate`/`instantiate` pair is *initialization-order dependent* — a
snapshot before and after a single `OS.get_cmdline_user_args()` call flipped
`AnimationNodeBlendSpace2D` from `true/true` to `true/false` and stayed there
(`probe_pre.gd`, 2/2 runs), while a script that never makes that call reports
`made=340` (30/30) and the same script that does reports `made=440–460` in every
run measured (13/13; two variants, `cls_probe.gd`/`v_c.gd`). So the census is a
**timing-dependent engine state**, not a property of the workload.
**Impact is bounded and fail-closed**: the sha moves *and* `beq` goes to 0, so
the committed marker cannot match and the row FAILs — this is a spurious-FAIL
risk, never a false green. It is **not in the author's disclosed flake list**.
**Convergent with the sibling `r99-critic` F1** (independent observation:
`made=341 skipped=239`, `jolt`, 1/51 children; their 34 800 single-attempt probes
reproduced 0 flips). Three independent observations of the same class.
**Fold for the author/adjudicator:** drop `made`/`skipped` from the hashed pin
(keep `rounds`/`names`, which are constants) or pin a range, and disclose the
class; alternatively count only the classes whose instantiation is
init-independent.

**F2 (MEDIUM — the `td` tolerance is wider than the claim it protects; the
accepted window is "anything after `CLS_LOOP_ALIVE`").** The `clsloop` cell
truncates its hashed stream at `CLS_LOOP_ALIVE` and accepts rc ∈ {0,134}; the
observed real abort (`corpus/live/runs/20261016T071708787743Z/scratch/
r99t988971_life_clsloop_dummy/child.log`) is a SIGABRT with
`corrupted size vs. prev_size while consolidating` **after `LIFE_DONE`**. But the
encoding cannot tell that apart from an abort *inside* the case:
- `M6` — `OS.crash()` injected immediately after the `CLS_LOOP_ALIVE` print
  (inside `c_clsloop`, before `LIFE_DONE`): **3/3 runs print the committed marker
  exactly, all three `clsloop` cells match byte-for-byte, no other cell differs →
  the row PASSES.** A post-marker in-case abort is accepted as teardown noise.
- `M7` — the same crash after `LIFE_DONE` (the real class): the 3 `clsloop` cells
  still match; the row only reddens because the **15 non-`td` life cells** carry
  rc=134. The `td` tolerance is therefore not "teardown" — it is
  "after the last hashed line".
- The `rc=0|134` token is a **constant**, so the true rc is never recorded
  anywhere in the receipt (the labrat's static trace agrees).
**Convergent with the sibling `r99-critic` F2/F6 and with this seat's labrat.**
**Fold:** truncate at `LIFE_DONE` (the case's own final line) instead of
`CLS_LOOP_ALIVE`, and make the required `mark` `LIFE_DONE`. That is strictly
tighter — `M6` would then be detected (marker missing → `mk=0`, and the crash
text enters the hash), while the observed post-`LIFE_DONE` abort still passes
with the same sha (verified: the abort log carries `LIFE_DONE` at line 5, the
abort at line 6). Optionally also record the observed rc as a separate field so
the tolerance is visible in the receipt.

**F3 (MEDIUM/NOTE — the teardown abort is workload-attributable and, under load,
common; the disclosure says "rare").** Direct runs of the **committed** probe
bytes, real rc captured:
- attribution control under the same load: `empty` (trivial `SceneTree`) **0/40**
  aborts, `freetree` (committed case, creates/frees one tree) **0/40**, `clsloop`
  (340 instantiate+free cycles) **1/40 rc=134** with the same glibc message →
  the abort is **caused by the loop**, not by engine shutdown in general;
- direct `clsloop` harness (6-way parallel): **21/72 rc=134**, every one after
  `LIFE_DONE` (29 %);
- parent-path windows: `sweep` reps **2/15**, `lifeflake` 24 sequential reps
  **1/72**, a 60-rep window under battery load **7/108** (6.5 %);
- the author's own runs: **1/18**; the boundary's sweep: **0/24** on a quieter
  host.
So the boundary's "24× clean" and the author's "once, host load ~60" are both
real but are *quiet-window* numbers; on this host under load the same case aborts
at 1–29 % depending on concurrency. The tolerance is what keeps the row green.
The pinned law as landed reads "340 instantiate+free cycles … zero crash / teardown
is safe"; the measured law is "the loop leaves the heap corrupt and the process
aborts with `corrupted size vs. prev_size` at a later point — post-`LIFE_DONE` in
every observed instance, tolerated by `td`". **Fold:** disclose the rate and its
load dependence (this is the author's flake-list item 1, currently written as a
one-off), and record the rc so the rate is measurable from receipts.

**F4 (NOTE — fixture-level `PASS` is not the pin; same family as r98 F3).**
`_cell_ok` checks only rc, the `ue` list and the required marker; it does **not**
compare `sha`/fields. Demonstrated: with the `srv=` mask disabled (`M2`) the
fixture still prints `PASS r99_animtree core …` while 6 cells' shas have moved;
only the battery's exact-marker assertion catches it. Consequence: a direct-arm
run (the author's `driver.py`, or a future seat replaying an arm by hand) is not
pin evidence by itself — the receipts here do match the committed markers (§6/§8),
but the distinction should stay explicit.

**F5 (NOTE — the `td` cell's fail-closed closure against a *hang* is
incidental).** A child that prints `CLS_LOOP_ALIVE` and then hangs is accepted by
the cell logic (the parent's deadline kill leaves `OS.get_process_exit_code()`
returning 0, inside the `td` gate) and the truncation hides the silence; the row
still fails, but through the battery's 20 s case bound, not through an authored
guard. Convergent with the sibling critic's F2. No action needed if `F2`'s fold is
taken (the marker moves to `LIFE_DONE`, which a hang cannot print).

**F6 (NOTE — the pinned `sha` is a stdout+stderr interleaving).** The child
stream is the shell's merged `> log 2>&1`; the pins are therefore
capture-shape-scoped (the sibling critic's F7 measures the same). All recorded
runs here agree on the merged shape, so the pins are internally consistent.

---

## Residual risk / verification gaps

- **No LSP device** (`rea` only): symbol-level checks unavailable; none needed
  (no edits; all 7 fixtures parse and execute).
- **Cross-build.** Every pin is receipt-derived for
  `4.7.2.stable.arch_linux.ed1daf0bf` on this host; hashes are build-scoped (the
  corpus convention r89–r99).
- **F1 is not fully reproducible on demand** (2/72 direct, 1/~100 parent-path in
  my windows; 0/34 830 single attempts in the critic's). The mechanism is
  demonstrated in-process, the *rate* is not a stable estimate.
- **F3's rate is load-dependent by construction** — my windows read 1/72 → 29 %
  as concurrency rose; the numbers above are windows, not a law.
- **Concurrency disclosure.** The host carried four sibling r99 seats plus this
  seat's batteries for the whole review (load 66–86). The one non-green class I
  saw inside r99 is F1/F3; the battery's non-r99 rows are the documented
  pre-existing `navagent3d_*` / `phys3d_*` load families.
- **Not re-measured here** (by scope): the boundary's falsified/unknown list —
  `xfade_time`, what ENABLED is *for*, `BlendSpace1D/2D`, `OneShot`,
  `Transition`, `Add2/3`, `Mix*`, `Sync`, `play_mode`/`backward`, `root_motion`,
  skeleton targets, and the unthrottled `base` rate cells (not pinned by design).
- **The `td` cell's claim is not pinned by that cell** (F2): the "teardown is
  safe" law for `clsloop` rests on the *other* five life cells, which are not
  `td`. That is a statement about the evidence chain, not a defect in the bytes.

---

## Recommendation (not a judgment — the canonical runtime judges)

**ADMIT-recommend.** The committed landing is sound as scoped: insertion-only
(+2757/−0, zero existing bytes touched), all 7 fixtures parse, the census is exact
and bijective (342 = 283+59, 9 tail rows, 183 = 61×3, 122/122 `beq=1`), the six
probe copies are the boundary's pinned bytes, the author's six receipts are for
the committed blobs (123/123 seed digests each; 9/9 rows green in all six; 342/342
twice), an **independent normalizer reproduces 1 281 cell instances byte-for-byte
across seven data sets with 0 mismatches**, an **independent crosscheck against
the boundary's own receipts is 525/525 identical** (8 GP-only `order` cells
excepted and covered by my own children), a **5-rep × 9-arm fresh sweep is 45/45
byte-exact**, and the pins are **live** — 8 mutants, 6 mechanistic detections plus
the two `td`-window measurements. The findings are three MEDIUM-class items
(undisclosed census flake F1, over-wide `td` window F2, understated abort rate and
workload attribution F3) and three NOTEs; **none contradicts an authored law and
none touches a committed byte** — F1 is a false-red risk, F2/F3 are pin-strength
and disclosure items. The F1/F2/F3 folds belong to the author/adjudicator, not to
this seat.

**Cross-seat convergence (independent, both report-only commits after
`f1ff626`):** the sibling `r99-critic` files the same census flake as **F1** and
the same `td` window as **F2/F6**; this seat's labrat independently traced the
`td` acceptance predicate. No sibling found a byte defect.

**Blockers:** none. The dispatched `ufo-labrat` was usable but static-only (no
exec tool); its dynamic phase was covered by this seat's M5/M6/M7 mutants and the
direct-child experiments.

Stopping here.

---

## §12 addendum — full battery numbers

Full **342-case** battery from the clean archive
(`/home/vgpnk/.cache/r99-reviewer/corpus/live/runs/<stamp>/`, seat-owned copy of
the committed runner, load 66–86 with four sibling seats in flight):

<!--BATTERY-->

Focused r99-only pass: **see §13**.

---

## §13 addendum — direct-child and flake censuses

| data set | children | rc=134 aborts | census deviation | marker mismatches |
|---|---|---|---|---|
| direct `clsloop`, committed probe, 6-way parallel, load ~85 | 72 | **21** (all post-`LIFE_DONE`) | **2** (`made=360`, dummy) | — |
| attribution control `empty` / `freetree` / `clsloop` (40 each) | 120 | 0 / 0 / **1** | 0 | — |
| parent-path `life` arm, 24 sequential reps | 72 | 1 | 0 | 0 |
| parent-path `life` arm, 60 reps under battery load | 180 (partial window) | 7 | 0 | 0 |
| seat sweep reps 1–5 (45 arm runs, 135 clsloop children… 15 clsloop) | 15 | 2 | 0 | 0 |
| author's six runs | 18 | 1 | 0 | 0 |
| r99 boundary's own sweep | 24 | 0 | 0 | — |

The `clsloop` census deviation (F1) and the abort rate (F3) are the two
quantities that are *not* stable across these windows; everything else in the
r99 lattice reproduced byte-for-byte in every window measured here.

---

## Receipts index

`/home/vgpnk/.cache/r99-reviewer/` (mirrored at the gitignored
`corpus/live/r99-reviewer/`):
- `corpus/fixtures/` — the `git archive f1ff626` tree (the measured bytes).
- `tools/` — `census.py` (AST + marker census), `dump_cells.gd` / `dump_json.gd`
  (the committed fixture's own cell tables; `cells.json`), `vnorm.py`
  (from-scratch normalizer + full cell re-derivation), `xcheck.py` (boundary
  crosscheck), `sweep.py` (seat-owned 9-arm runner), `mutants.py` +
  `mut/results.json` (8 mutants), `receipts.py` (seed-digest custody),
  `claimaudit.py`, `clsloop.py` (direct-child rc/census experiment),
  `cls_instr.gd`, `cls_probe.gd`, `probe_pre.gd` (in-process flip mechanism),
  `lifeflake.py` (parent-path flake hunt).
- `sweep/rep{1..5}/` (183 child dirs each with `child.log`) + `rep*.json` +
  `rep1.log`, `reps2to5.log`.
- `mut/` (mutant trees M1–M8, M5–M7), `rep_M6_*`/`rep_M7_*` (refined `td`
  measurements), `mut2/` (M2 fixture-PASS demonstration).
- `clsloop/` (72 direct runs, `results.json`, per-run logs), `attrib/`
  (empty/freetree/clsloop × 40), `clsinstr/`, `lifeflake*/` + `lifeflake*.log`.
- `batt_full.log` + `corpus/live/runs/<stamp>/verdicts.json` (the full battery).
- `/tmp/vnorm_rep1.json`, `/tmp/vnorm_20261016T0*.json` (per-data-set
  re-derivations).
