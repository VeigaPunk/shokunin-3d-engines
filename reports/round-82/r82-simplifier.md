# game-dev-3d round 82 — simplifier (seat: simplifier, host: devin)

Write scope honored: this report + `corpus/live/r82-simplifier/**` scratch only
(gitignored: `corpus/.gitignore:1 live/`); no git mutation by this seat; no
tracked file written. LEAF — no subagents, no judging, no shipping, no other
runtime.

**Arrival state / provenance.** Entered on the r81-landed tree (`31cf56a`):
`bpy_sync_probe.py` `a4b1f94b…`, `bpy_battery.py` `111568ee…`. My own arrival
battery run reproduces the r81 receipt exactly — 74/74 PASS, probe.stdout
sha256 `947ad726…`, stderr 0 B
(`baseline-runs/bpy-20261014T151911682463Z/`).

**Audited revision (state this before every claim below).** The r82 author's
tree is `probe 33091ec188dc0330…` / `battery fba5ba7a86493982…`. The battery is
committed in `0619300` (12:38:26 local); the probe carries **one uncommitted
refinement** — the pre-redirect C-stdio `fflush` (`git show HEAD:… | sha256sum`
= `061cc21e6c0dd003…`). Everything below audits the **working-tree pair**;
it was stable from 12:41:16 through this seat
(`wait_stable.sh 180`, `watch.log`). r82-author read first;
r82-scout / r82-critic / r82-boundary cross-read. If the operator commits the
probe refinement verbatim, the audited pair is what ships; if the refinement is
dropped, §2-D-C shows the receipt regresses (banner eaten) — the refinement is
load-bearing, not cosmetic.

**LSP device: unavailable — recorded.** MCP servers exposed to this seat: `rea`
only (Ghidra/REA binary-analysis device); no `lsp` server answers `.py`. No
`jedi`, `parso`, `pyright`, `pylsp`, `ruff`, `pyflakes`, or `flake8` on this
host either. Every caller / dead-code check below is **AST + text fallback** and
is never presented as semantic proof. Cold-start caution from the seat card does
not apply (no server to warm up): the device is absent, not empty.

## (1) Deletion candidates verified with byte-identity proof (scratch only)

Both are code-weight only; neither touches a pinned row, an emitted field, or a
gate. Reference receipt: the tracked-tree battery run
`probe-runs/bpy-20261014T154438026367Z/` — **83/83 PASS**, 4/4 order-checks,
7/7 hazard-checks, probe.stdout sha256
`6a98c570dbaec6f33f23c684ae2938470a251c229cb50d4451c23eb1d07defc3`, stderr 0 B
(×2 by me, ×3 by the author: `…154116`, `…154123`, `…154404`).

**D-A — `_ec_edge1`'s dead `held` parameter (`bpy_sync_probe.py:599` + 16 call
sites).** Residue of the r81 fold (`fd75567`): r81 deleted the `"0"`/`"na"`
returns that read `held` and left the parameter behind. r82 then added **6 more
call sites** that pass it.
- Body is a single return: `return "1" if fresh == expected else "unbound"` —
  `held` is unreferenced. This is stronger than a receipt replay: the deletion
  is behavior-preserving **for every input**, not just this run.
- Tool: `tools/paramscan.py corpus/fixtures/bpy_sync_probe.py` →
  `UNUSEDPARAM :599 _ec_edge1 arg='held'` — the **only** unused parameter in the
  file (66 defs).
- Call sites: `:723, 740, 817, 840, 991, 1055, 1077, 1098, 1124, 1148` (r80/r81)
  + `:1229, 1252, 1286, 1324, 1416, 1465` (r82) = **16**. `:817` passes `held2`,
  `:1465` passes `held, fresh_ctl`.
- Proof: scratch `scratch/variants/A_edge1param.py` (def line + all 16 args
  rewritten, `ast.parse` OK, def-line protected against the call-site regex) →
  probe stdout sha `6a98c570…` = tracked receipt, byte-identical; exit 0,
  stderr 0 B.
- Landing proof (strongest available): scratch battery
  `scratch/landing_AB/` (D-A + D-B applied, tracked battery verbatim) → exit 0,
  **83/83 PASS**, 4/4 order-checks, 7/7 hazard-checks, probe stdout
  **byte-identical** `6a98c570…` ×2 runs
  (`landing_AB/runs/bpy-20261014T154609960014Z`, `…/runs2/…154738450846Z`).
- Recommendation: **land**. The parameter now reads as a guard and gates
  nothing; deleting it removes a misleading surface, and the contract sentence
  moves into the docstring text (see §3-F-2, which edits the same docstring).

**D-B — dead binding `dg0` in `_ec_x2_instance_refused`
(`bpy_sync_probe.py:1342`, r82-new).** `ob, dg0 = _ec_settle()`; `dg0` is never
read in the function (the sub-probe emits only handler deltas and the two
refusal witnesses).
- Tool: `tools/deadcode.py` → `DEADSTORE :1342 dg0`.
- Proof: `scratch/variants/B_dg0.py` → byte-identical `6a98c570…`; also inside
  the `landing_AB` battery run above (83/83, identical stdout).
- Weight: honestly **2 characters** (`dg0` → `_`). Listed because it is
  provably dead and r82-new, not because it moves any axis.

## (2) Candidates measured and *not* recommended (kept) — each with its proof

**D-C — the `ctypes` pre-redirect `fflush` block
(`bpy_sync_probe.py:1352-1356`) is LOAD-BEARING, keep.**
- Scratch `scratch/variants/C_nofflush.py` (block deleted) → stdout **13431 B**,
  sha `3f82eb52…` ≠ `6a98c570…`: the receipt **loses its first line**, the
  Blender banner `Blender 5.2.1 LTS (hash 9e2066aef7ef built 2026-09-01
  00:24:57)` (diff shows `1d0 <` banner).
- Independently confirmed against the committed blob: running
  `git show HEAD:corpus/fixtures/bpy_sync_probe.py` verbatim
  (`scratch/variants/COMMITTED_nofflush.py`) reproduces exactly that 13431 B /
  `3f82eb52…` stream. The author's receipts agree: `…153825`, `…153837` are
  `3f82eb52…` (pre-refinement), `…154116`, `…154123`, `…154404` are
  `6a98c570…` (post-refinement).
- Conclusion: this is not r82 weight to remove — it is the fix for an r82
  regression. (Tradeoff noted, §6.)

**D-D — the fd1→devnull redirect in the same sub-probe
(`:1357-1376`) is LOAD-BEARING, keep.**
- Scratch `scratch/variants/D_noredirect.py` (redirect disabled, `fflush` kept)
  → stdout **13579 B**, sha `187c52f1…` ≠ reference. The extra line is
  `00:04.331  reports          | ERROR Only empty objects support collection
  instances` — a C-level line carrying an **uptime timestamp**, i.e. it would
  jitter the receipt on every run as well as add bytes. Deleting the redirect
  would be a nondeterminism regression, not a simplification.

**M-1 — `hazard_dup_flush_lastwins`'s `src` pin key is redundant with `v`
(`bpy_battery.py:332-333`), measured, keep.** The two candidate rows
(`_DUP_A`/`_DUP_B`) correlate `src` and `v` perfectly, so one key is implied by
the other. Measured: scratch `scratch/bat_M1/` (pin reduced to `{"v":
"forged"}`) → exit 0, **83/83 PASS**. Kept: a pin dict is documentation, not
weight, and the second key names *which* row won, which is the diagnostic a
future FAIL needs.

**M-2 — `hazard_detail["forge_midstream_in_stdout"]` and
`["closed_cell_has_forged_key"]` duplicate two check expressions
(`bpy_battery.py:556-558`), measured, keep.** Same predicate evaluated twice —
the classic duplicate-authority shape (they can drift silently).
`scratch/bat_M2/` (both keys dropped) → exit 0, **83/83 PASS**, all 7
hazard-checks PASS. Kept: `hazard_detail` is the human-readable receipt; the
duplication is 4 lines in one file, and deleting payload keys is a receipt-shape
change that belongs to the author/verifier, not to me.

**M-3 — the forward-order half of the synthetic dup_flush gate is redundant with
the live pin, measured, keep.** `hazard_dup_flush_order_decides` asserts
`dup_ab == "forged" and dup_ba == "first"`; `dup_ab` (forward order) restates
what the **live** CASES pin `hazard_dup_flush_lastwins` already asserts
end-to-end. `scratch/bat_M3/` (forward half + its literal removed) → exit 0,
**83/83 PASS**, 7/7 hazard-checks. Kept: the reverse-order half (`dup_ba`) is
the only place that direction is exercised — it cannot be produced live — and
the two halves cost ~3 lines together. Deleting the whole synthetic block would
remove that direction and harm the coverage axis.

**`_ec_all_names` (`:1188`) is a near-duplicate of `_ec_names` (`:558`)** —
identical body minus the `if not i.is_instance` filter. Considered as
"duplicate authority" and rejected: the pair encodes an intentional
instance-aware vs instance-blind witness distinction that r82-critic's F5b
correction demanded, and folding them into `_ec_names(dg, all=…)` would create a
second convention (a flag argument) for 3 lines. Keep both.

## (3) Stale names in the r82 diff — measured, not deletions

**F-1 (stale line citations, r82-new, `bpy_battery.py:468-469`).** The new
hazard-block comment pins the tracked path as `run_process :281-292, parse_arms
:295-304`. At the audited revision the defs are **`run_process` `:358` (body
358-369)** and **`parse_arms` `:372` (body 372-381)** — both cited numbers are
**77 lines stale**. (The pre-r82 numbers were `:264-275` / `:278-287`, so the
author's numbers match neither the old nor the new file; this is the same defect
class r82-critic raised against the author brief's `:211-220`.)
- Root cause, measured: the offset is exactly **+17**, and the r82 diff's first
  two insertions above `run_process` are 16 docstring lines
  (`bpy_battery.py:24-39`) + `import time` (`:47`) = **17**. The citation was
  correct against that intermediate revision and went stale when the +76-line
  `CASES` block (`:257-333`) landed above it. Both citations decayed together,
  which is why the two spans kept their correct shapes (12 and 10 lines).
- Verify: `awk 'NR>=355 && NR<=382' corpus/fixtures/bpy_battery.py`.
- Recommend (2-token edit, no row impact): `:281-292` → `:358-369`,
  `:295-304` → `:372-381`.
- Note the same author report cites `hazard_checks` `:466-565` and the probe
  section `:1177-1474`; those two I spot-checked and they are correct — only
  the two in-fixture citations are stale.

**F-2 (stale count + dangling reference, `bpy_sync_probe.py:600-603`).**
`_ec_edge1`'s docstring says *"`held` is "stale" on every reachable path …
(all 11 edge=1 call sites measured held=stale)"*. Measured now: **17 `edge=1`
rows** in the receipt and **16 `_ec_edge1` call sites** (the 17th row,
`rna_write`, computes its label inline at `:628-629`). r82 added 6 call sites
and did not update the sentence. The phrase also conflated *rows* with *call
sites* at r81 (10 call sites, 11 rows).
- Measured: `grep -c 'edge=1 ' <receipt>` = 17 (arrival was 11);
  `grep -c '_ec_edge1(' corpus/fixtures/bpy_sync_probe.py` = 17 = 1 def + 16
  calls.
- Recommend: reword to name the mechanism, not a count ("every call site passes
  the row's `held`; the closed-set predicate in `_ec_edge` forces FALSIFIED for
  `flushed`/`na` before this value is emitted"). If D-A lands, this sentence
  must be reworded anyway, since `held` stops being a parameter.

## (4) Audit of the r82 landing — clean on dead defs / dupes / unpinned weight

| check | command | result |
|---|---|---|
| dead defs (AST refcount) | `tools/refcount.py corpus/fixtures/bpy_sync_probe.py` | all 8 new `_ec_x2_*` referenced exactly once from `arm_evalcat`'s tuple (`:1519-1522`); `arm_hazards` defined `:1593` and referenced once from the runner tuple (`:1604`); `_ec_all_names` 2, `_ec_inst_count` 3, `_ec_in_dg` 2; imports `os/stat/subprocess/sys/time/traceback` all used; no zero-ref helper |
| dead stores | `tools/deadcode.py` both files | probe: 15 hits, 14 are the deliberate `_ = <read>` re-touch/keep-alive idiom (draincheck/walltime) or `_ec_settle()` side-effect bindings; **1 real** (D-B). battery: `_eof_err`/`_ctl_err` (`:509`, `:513`) — underscore-marked discards, 0-byte weight |
| unused params | `tools/paramscan.py` both files | probe: exactly one (`_ec_edge1.held`, D-A). battery: none |
| unreachable stmts / literal tests / `pass`-branches / dup dict keys | `tools/paramscan.py`, `tools/deadcode.py` | **0** in both files |
| duplicate emitted cells | `tools/dupes_census.py <receipt>` | 134 ARM lines, 131 unique keys, **3** dup keys — all intentional and pinned last-wins contracts: `evalcat\|closed\|EDGE` (the r82 forged row + genuine row), `reorder\|dup\|FD1` (r81), `hazard\|dup_flush\|PARSE` (r82) |
| case-key census | `tools/cases_census.py corpus/fixtures/bpy_battery.py <receipt>` | 83 pinned keys, 0 same-key contradictions, 0 missing rows, **0 new unpinned rows** (49 unpinned diagnostic rows, unchanged from baseline — r82 added none) |
| prior-row stability | `tools/prior_rows.py arrival-arms.txt <receipt>` | `before_keys=122 after_keys=131 common=122 **changed_bodies=0** missing=0 new=9` — every r79/r80/r81 row byte-identical by body |
| byte-stability | battery ×2, tracked tree | 83/83 both, probe stdout `6a98c570…` ×2, stderr 0 B (`probe-runs/…154438026367Z`, `…154645426332Z`) |

Sub-sha corroboration from my receipts: the r79/r80/r81 ARM bodies are
unchanged, so the `947ad726…` → `6a98c570…` delta is exactly the 11 inserted
physical lines (forged `closed`, 6 `ext2_*` EDGE, 2 `ext2_*` DEG, 2 `hazard`
PARSE) plus the banner's relocation to byte 0 — the author's `bytestab.py`
claim, independently reproduced by `prior_rows.py` + the D-C/D-D diffs above.

## (5) Preserved contract (measured, not assumed)

- 83/83 PASS, `signal_fail=0`, `quirk_drift=0`, `fatals=0`, `launch_ok=True`,
  `done_marker=True`, `exit=0`; probe stderr byte-empty.
- 4/4 `order_checks` PASS (reorder topology + splice-drop unchanged).
- 7/7 `hazard_checks` PASS, and the *values* are pinned: forged marker present
  in raw bytes; the winning `closed` cell is the genuine row (`violations=0`,
  `events` present, no `forged` key); synthetic forge-last `violations=0` /
  forge-first `violations=3`; `dup_ba="first"`; `binjunk_raised=
  "UnicodeDecodeError"`; detach-EOF `TIMEOUT`+`rc=None`+`EOF_PARENT_DONE`
  captured; control `rc=0` fast.
- Falsifier still armed and still counts: `closed | violations=0`, `events=`
  list intact, and the forged mid-stream row is absorbed rather than
  masking-onto the genuine cell (my receipt: forged row at line 80, genuine at
  line 128 — the author's citation, verified).
- The deletions in §1 leave **all of the above byte-identical** (combined
  `landing_AB` run, ×2).
- Tracked tree untouched by this seat: `git status --porcelain` still shows only
  the author's own ` M corpus/fixtures/bpy_sync_probe.py`; audited shas re-read
  at 12:47 local are unchanged from 12:41.

## (6) Tradeoffs and stop point

- **D-A touches 16 source lines, 10 of them pre-r82** (the r80/r81 call sites).
  That is emitted-row-neutral — `prior_rows.py` shows 0 changed bodies — and is
  exactly the shape of the r81 simplifier fold (`fd75567` edited an r80-era
  predicate). But it is *source* churn in an insertion-only wave, so it is the
  author's/operator's call whether to take it in this wave or leave it with the
  F-2 docstring fix only. I do not land it.
- **D-C's guard is silent on failure.** The `try/except Exception: pass` around
  `ctypes.CDLL("libc.so.6").fflush(None)` means a host without libc-visible
  `ctypes` would lose the banner *without any check failing* (nothing pins the
  banner). That is a deliberate robustness-over-loudness trade; the author's
  "fails loudly" claim applies to the redirect block, not to this one. Recording
  it, not asking for a change — the alternative (pinning the banner) is an
  addition, outside this seat.
- **The largest remaining receipt weight is evidence, not dead code.** The 49
  unpinned diagnostic rows, the two documentary `ext2_*` DEG side cells, the
  `hazard_detail` block, and the synthetic hazard gates are all cited receipt
  evidence or falsifier surface; `M-1`/`M-2`/`M-3` each measure verdict-neutral
  but delete *evidence*, which §"out of scope" forbids me to land.
- **Stopping:** the next deletion would harm an axis — byte-stability (D-C/D-D
  are load-bearing), evidence (M-1/M-2/M-3, unpinned rows, side cells), or the
  insertion-only contract on prior rows. No further weight can be removed
  without breaking a preserved contract.

## Evidence index

- Scratch root `corpus/live/r82-simplifier/` (gitignored):
  `arrival-shas.txt`, `arrival-arms.txt`, `watch.log`, `wait_stable.sh`,
  `baseline-r81.stdout.txt`, `probe1.stdout.txt`, `probe2.stdout.txt`,
  `landed-deadcode-{probe,battery}.txt`, `landed-paramscan-{probe,battery}.txt`,
  `arrival-refcount-{probe,battery}.txt`.
- Tools (AST/text fallback, never semantic proof): `tools/{refcount,deadcode,
  paramscan,dupes_census,cases_census,prior_rows,run_and_cmp}.py`.
- Variants: `scratch/variants/{CTRL,A_edge1param,B_dg0,C_nofflush,
  D_noredirect,COMMITTED_nofflush}.py` + `.stdout.txt`.
- Landings: `scratch/landing_AB/` (probe D-A+D-B, tracked battery) — runs
  `bpy-20261014T154609960014Z` and `…154738450846Z`, both 83/83 + `6a98c570…`.
- Battery mutants: `scratch/bat_M1/`, `bat_M2/`, `bat_M3/` (each 83/83).
- Receipts: baseline `baseline-runs/bpy-20261014T151911682463Z` (74/74,
  `947ad726…`); landed `probe-runs/bpy-20261014T154438026367Z` +
  `…154645426332Z` (83/83, `6a98c570…`, stderr 0 B); author's
  `corpus/live/r82-author/runs/*` (`3f82eb52…` ×2 pre-refinement, `6a98c570…`
  ×3 post).
- Diffs audited: `scratch/r82-probe.diff`, `scratch/r82-battery.diff`
  (`git diff 31cf56a -- <file>`).
- Tracked files were read-only to this seat; the audited pair is
  `33091ec1…`/`fba5ba7a…`, re-read at 12:47 local, unchanged since 12:41:16.

Stopping here.
