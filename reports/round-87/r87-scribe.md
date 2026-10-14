# game-dev-3d round 87 — ledger audit + r87 receipt re-derivation (seat: scribe)

Lane: g3d · engine `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`,
`--headless`, 60 tps. Brief:
`.ufo/waves/shokunin-train-20261101-w18/tasks/g3d-r87-scribe.md`.
Scope: read-only audit + receipt re-derivation. No git mutations by this
seat, no battery re-runs; every number below is derived from receipts,
committed diffs, or receipt-consuming scripts under
`corpus/live/r87-scribe/scratch/`.

Bracket: audit opened at HEAD `af15a52` (r86 report-last), r87 author
changes observed live in the worktree, author commit `c57fa40` landed
during the audit, baseline post-commit replay observed after it.
`corpus/live/` is host-local untracked evidence.

---

## 1. r86 ledger re-derivation (`reports/round-86/*` vs `LOG.md`/`SCORECARD.md`)

### 1.1 CASES census (independent parse of `run_battery.py` @ r86)

- 195 `CASES` entries; 149 expected-exit-0 ordinary + 46 expected-exit-2
  negative controls — matches LOG.md r86 row and every r86 seat report.
- The four r86 cells occupy positions 192–195, in order:
  `phys3d_events_script_size_gate`, `phys3d_events_deferred_hang`,
  `phys3d_events_backend_tier`, `phys3d_events_dummy_floor`.
- Prior r85 ledger: 191 rows — prefix confirmed (see 1.4).

### 1.2 Fold commit `dd1737a` vs its declaration

Diff inspected in full. `README.md` carried exactly two relevant hunks
(A3, A4); `phys3d_events.gd` carried the helper insertion, the SP1/SP2
call-site replacements, and A1/A2/A5 logic.

- **SP1 (13 project-body literals → `_project_body(name, engine,
  threaded)`):** all 13 pre-fold literals extracted from the diff and
  compared byte-for-byte against the helper's generated output —
  **13/13 identical** (an earlier asymmetric `rstrip` in my first
  comparison falsely reported non-identity; exact decoded-string
  comparison is the correct check and it passes). The declared
  "15 generated outputs byte-identical" is consistent: some generated
  projects are shared by multiple spawns.
- **SP2 (17 exit tails → `_quit_clean(code, message)`):** 17
  `_quit_clean` call sites counted at the folded state; the only
  executable `quit(code)` remaining is inside the helper. No stray
  exit path.
- **Critic corrections A1–A5:** all five present in the diff —
  A1 deferred-hang acceptance requires the `"null instance"` abort
  witness; A2 Dummy contrast receives `HANG_BOUND_S`; A3 wording moved
  to script-statement count (uncalled bodies also count); A4 refusal
  provenance requires the engine `space_get_direct_state` callsite in
  the raw child log (not only merged `2>&1`); A5 Dummy floor pins
  zero-vs-positive `solver_iterations` (not literal `16.0`).

### 1.3 Nav-cell record correction

Re-derived from raw logs in `corpus/live/r86-author/nav-replication/`:
project-less runs 6/6 `safe_n=0`; project-present runs 17/17
`safe_n=10`; an empty `project.godot` alone is sufficient. The
divergence is a harness/environment artifact (project presence), not a
scout falsehood; the cell was not landed. SCORECARD/LOG wording
("Park stays on procedure; the recorded ground was corrected") is
consistent with this.

### 1.4 r86 receipt census and tuple identity

15 receipts with 195 rows found: **12 green** share tuple-sha
`eb710364ae8d705f…` (serialization: per-row
`(case, verdict, actual_exit, marker)` `\x1f`-joined, `\x1e`-terminated,
sha256); **3 failed** receipts are the declared superseded
SDL/gamepad-flake simplifier runs — retained in census, excluded from
green identity claims.

Green receipts: rows[0:191] share prefix tuple `efb81318…` (the r85
tuple) and show **zero diffs across all 12 compared row fields**
vs each other and the r86 post-commit reference.

### 1.5 r86 mutation matrices

- Author 9/9 load-bearing mutations re-executed from saved script —
  all 9 fail the relevant arm with named drift.
- Verifier 4-mutation matrix confirmed 3/4: V-M1, V-M3, V-M4 detected;
  V-M2 intentionally not detected (masked by `_cleanup_rids`/double-free
  behavior) — mechanism documented, consistent with the reports.

---

## 2. r87 landing — what `c57fa40` actually committed

Commit `c57fa40` "r87 work: body-tier direct-state lattice — 6 arms",
landed 2026-10-14 18:51 local. `git show --numstat`:

| file | + | − |
|---|---|---|
| `corpus/fixtures/README.md` | 90 | 0 |
| `corpus/fixtures/phys3d_events.gd` | 876 | 4 |
| `corpus/fixtures/run_battery.py` | 14 | 0 |
| `reports/round-87/r87-author.md` | 398 | 0 (new) |

Committed bytes equal the author-declared submission shas:
`phys3d_events.gd` `0e5e64f4…`, `run_battery.py` `45b1ea86…`,
`README.md` `45ec89a2…`.

**Discrepancy (minor, verbatim):** the author report claims
`phys3d_events.gd` +880/−4; the committed numstat is **+876/−4**.

### 2.1 CASES — insertion-only at the commit level

- Committed `CASES`: **201 entries** — 155 ordinary / 46 negative.
- Literal-tuple comparison `c57fa40` vs `af15a52`: `new[:195] == old`
  — every prior entry byte-identical at identical positions.
- Appended rows, positions 196–201, in declared order:
  `phys3d_events_body_handle`, `phys3d_events_acq_use`,
  `phys3d_events_step_stamp`, `phys3d_events_write_loss`,
  `phys3d_events_body_tier`, `phys3d_events_freed_space`. The
  crash-class row (`freed_space`) is last, as documented.
- `phys3d_events.gd`: six arm blocks with the header index at
  lines 124–151, child-spawn dispatch at 582–602 (incl. threaded
  twins), arm dispatch table at 1413+; comment-index entries match the
  arm semantics declared in the author report.

### 2.2 Receipt re-derivation — four independent 201-row runs

| receipt | verdict | cases | tuple-sha |
|---|---|---|---|
| `r87-author/runs-battery/20261014T213028552587Z` | PASS | 201/201 (155+46) | `3e3fe31226a250ea` |
| `r87-author/runs-battery2/20261014T213609598591Z` | PASS | 201/201 | `3e3fe31226a250ea` |
| `r87-author/runs-final/20261014T214355942770Z` | PASS | 201/201 | `3e3fe31226a250ea` |
| `r87-baseline/runs-post/20261014T215119929090Z` (post-commit, committed tree) | PASS | 201/201 | `3e3fe31226a250ea` |

All four share tuple-sha `3e3fe31226a250ea` (full serialization as in
§1.4) and `seeds_unchanged=true`. Crucially, each run's first-195
prefix tuple is `eb710364ae8d705f…` — **the r86 green tuple itself**,
so the tuple stream of the prior ledger is a strict prefix of the r87
stream.

### 2.3 Frozen-reference comparison (stdout+stderr included)

Baseline's frozen prior-195 reference (list tuples
`(case, verdict, exit, marker)` from the pre-commit 195/195 run
`runs/20261014T212001121842Z`) vs the post-commit receipt:

- **0 tuple-level diffs across all 195 rows**; insertions = the six
  declared cells only.
- Full-schema comparison (pre-run verdicts vs post-commit verdicts,
  12 fields incl. `stdout_sha`, `stderr_sha`, `expected_marker`,
  `duration_s`): **0 diffs on rows 0–194**.
- Note for the record: baseline's own `verify_prior_rows_full.py`
  crashes mid-compare (`IndexError`) at index 1 — a tool artifact: the
  frozen file stores list-tuples while verdicts rows are dicts. The
  same tool correctly lists the six `+[196]..[201]` insertions before
  crashing. The equivalent comparison run field-by-field above shows
  zero diffs; the crash is not evidence of row drift.
- Post-commit receipt's built-in adversarial checks all PASS:
  `mutation-verdicts`, `crash-exit-verdicts`,
  `stream-attribution-verdicts`, `tree-timeout-verdicts`.
- Rows 196–201 markers in the committed-tree receipt match the author
  report verbatim (incl. `freed_space gp=crash jolt=crash dummy=empty`).

### 2.4 Mutation matrix — declared, partially receipted

Author `corpus/live/r87-author/mutations.py` declares six mutations
(M1 reduced acquisition reps; M2 removed space free; M3 later impulse
read; M4 removed contact opt-in; M5 removed body detach; M6 in-phase
write) each with expected-drift notes; `mutation-scratch/` on disk
holds the post-M6 fixture state, so the harness ran. **However no
stdout/summary receipt of the 6/6 "detected" table was saved** — the
6/6 claim stands on the author report only (§9.3), plus on-disk
scratch state consistent with the last mutation. Recorded as declared,
not independently receipted.

### 2.5 Sibling batteries

- bpy: 83/83 PASS pre-commit and post-commit; `probe.stdout.txt`
  sha256 `6a98c570…` identical across author×2 and baseline×2
  receipts — the frozen-signature chain is intact.
- three.js: six `three-final-*.json` receipts (3+4+9+5+5+5 = 31 rows),
  all `verdict=PASS`, `seedsUnchanged=true`.

### 2.6 Known limits (verbatim, for the judge)

- **`write_loss` does not reproduce a loss.** Author disclosure stands:
  0 lost in 144 out-of-phase writes across four forms; the row pins the
  precondition (`gate=refused`, `reps=8`, `same_turn=8`, `tally=8`) and
  `race=bounded`. A loss would change the child log, not the marker —
  the row cannot fail because of it and cannot claim it either.
- Mutation-matrix 6/6 is declared, not receipted (§2.4).
- Author-report diff stat off by 4 lines on `phys3d_events.gd`
  (+880 claimed vs +876 committed).
- `corpus/live/` evidence is host-local/untracked; sibling r88 scout
  report `reports/round-88/r88-scout.md` landed during the bracket
  (out of scope here).

---

## 3. Touched surfaces / provenance

- This seat wrote only: `reports/round-87/r87-scribe.md` (this file)
  and `corpus/live/r87-scribe/scratch/r87s_audit.py` (receipt-consuming
  audit tool, untracked).
- No tracked file modified; no commit/push by this seat; no Godot or
  battery invocation — all battery numbers are re-derived from
  `verdicts.json`/raw logs.
- Key receipts: `corpus/live/r87-author/runs{,-battery2,-final}/*/verdicts.json`,
  `corpus/live/r87-baseline/runs/20261014T212001121842Z/verdicts.json`
  (frozen), `corpus/live/r87-baseline/runs-post/20261014T215119929090Z/verdicts.json`
  (post-commit), `corpus/live/r87-baseline/frozen/prior-195-*`,
  `corpus/live/r87-author/{bpy-runs,bpy-final}/*/probe.stdout.txt`,
  `corpus/live/r87-author/three-final-*.json`.

## 4. Out of scope

Admission/adjudication is the judge's call — this report asserts
mechanical facts only. Baseline report's own Phase-2 text was still
"PENDING" on disk at report time (its post-commit receipts exist and
were consumed directly). r88 scout lane not audited.
