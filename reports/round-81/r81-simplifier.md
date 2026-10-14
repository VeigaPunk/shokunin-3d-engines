# game-dev-3d round 81 — simplifier (seat: simplifier, host: devin)

Write scope honored: this report + `corpus/live/r81-simplifier/**` only; no git
mutations; no tracked file written by this seat. LEAF — no subagents, no
judging, no shipping.

**Arrival state / provenance.** Entered on the r80-landed tree
(`bpy_sync_probe.py` `bfa80ed4…`, `bpy_battery.py` `ae3b04b1…`; baseline
receipt `corpus/live/r81-simplifier/baseline-runs/bpy-20261014T143530350390Z/`,
64/64). The author's r81 working tree landed at 11:56 local and was stable
through this seat (`02131534a760eb33…` / `111568eec55fe1e4…`). The author
committed it mid-report as `65b2f26` (12:03:47 local); the committed blobs are
byte-identical to the audited working-tree shas (`git show HEAD:… | sha256sum`
= `02131534…` / `111568ee…`), so everything below audits the committed tree
verbatim (`corpus/live/r81-simplifier/audited-shas.txt`); r81-author report
read first, r81-critic/r81-scout cross-read.

**LSP device: unavailable — recorded.** MCP servers exposed to this seat:
`rea` only (Ghidra/REA binary-analysis device); no `lsp` server answers Python
files. Caller / dead-code checks below are text-level (grep + a refcount tool),
never presented as semantic proof.

## (1) Deletion candidates verified with byte-identity proof (scratch only)

All three are code-weight only; none touches a pinned row or a gate. Each was
applied in a scratch copy, run under the battery-faithful pipe capture
(`scratch/pipe_run.py` reproduces `bpy_battery.run_process`), and compared to
the tracked receipt `947ad72643d2a450fbea099a2b4392bc8eec51005e1e03568bbdce6879ddc1d0`.

**D-A — dead store `t0` (`bpy_sync_probe.py:1004`).** Residue of the r80 D1
fix (commit `e32e2de` dropped the `slept=` kwarg but left its timer).
- Grep fallback: `t0` occurs exactly once in the file — its own store; no reader.
- Proof: scratch `scratch/new/A_t0.py` (line deleted) → probe stdout sha
  `947ad726…` = tracked receipt, byte-identical; exit 0, stderr 0 B.

**D-B — `_ec_edge1` dead branches (`bpy_sync_probe.py:597-599`, fn at `:595`).**
The `"0"` / `"na"` returns cannot survive into an emitted row:
`_ec_held` (`:573-582`) returns only `flushed` / `na` / `stale`; `na` and
`flushed` imply a handler fire or a moved read; `_ec_edge`'s predicate
(`:589-590`) forces `edge=FALSIFIED` (`:591-592`) for every `invoked=None` row
in those states. All 10 call sites (`:722, :739, :816, :839, :990` + the five
r81 ext sites `:1055, :1077, :1098, :1124, :1148`) pass `invoked=None`.
- Measured: all 11 `edge=1` rows in the receipt are `held=stale`; collapsed
  scratch `scratch/new/B_edge1.py` → byte-identical receipt.
- This is r80-simplifier D2 carried forward, now re-proven with 10 call sites.

**D-C — `or d["und"]` in the FALSIFIED predicate (`bpy_sync_probe.py:590`).**
The r80-critic nit ("keep the field, drop the term"): undo_post firing is not
an eval event, so the term is a false-positive gate. The `dund=` field stays
emitted (`:595`).
- Measured: `dund=0` in all 28 EDGE rows of the receipt (22 r80 + 6 r81 ext);
  scratch `scratch/new/C_und.py` → byte-identical receipt.

**Combined landing shape (A+B+C).** Scratch battery `scratch/landing_ABC/`
(battery copy + probe with all three deletions): exit 0, **74/74 PASS**,
4/4 order checks True, probe stdout **byte-identical** to the tracked receipt
(`scratch/landing_ABC/runs/bpy-20261014T150313139043Z/`). This is the strongest
available proof: the deletions are invisible to the parser and the verdict path.

## (2) Audit of the r81 landing — clean on dead defs / dupes / unpinned weight

| check | command | result |
|---|---|---|
| dead defs (grep-level refcount) | `tools/refcount.py corpus/fixtures/bpy_sync_probe.py` | all 6 `_ec_x_*` (`:1029-1174`) + `arm_reorder` (`:1227`) referenced exactly once from the runner tuples (`:1188-1189, :1256`); imports os/stat/sys/subprocess all used; no zero-ref helper |
| duplicate emitted cells | `tools/dupes_census.py …/probe.stdout.txt` | 123 ARM lines, 122 unique keys, **1** duplicate: `reorder\|dup\|FD1` (`src=child_inj` then `src=parent`) — the intentional pinned last-wins cell; no other cell duplicated or torn |
| case-key census | `tools/cases_census.py corpus/fixtures/bpy_battery.py …` | 73 pinned keys, 0 same-key contradictions (the one collision `transform\|w0\|RNA` pins disjoint aspects), 0 missing rows |
| new unpinned rows | same | r81 added **none**: all 10 new keys pinned; `gluevictim` is dropped by design; `spawn\|ERR` exists only on spawn failure |
| prior-row stability | `tools/prior_rows.py baseline-arms.txt landed-arms.txt` | 112/112 r80-era bodies **unchanged**, 0 missing, 10 new keys |
| byte-stability | battery ×2, tracked tree | 74/74 both, probe stdout sha `947ad726…` ×2, stderr 0 B (`landed-runs/bpy-20261014T150032790991Z`, `…150037278462Z`) |

Corroborated sub-shas from my receipt: r79 first-78 prefix
`08101bed2b07abdf…` identical before/after; r80 evalcat 34-line subsequence
`146af473447c58a1…` identical; `closed` row shifts 112 → 118 with content
unchanged (`violations=0`).

## (3) Candidates measured and *not* recommended (kept)

- **E — `reorder_child_before_post_spawn` (`bpy_battery.py:356-357`) is
  non-discriminating.** My collapse mutant (flush before spawn,
  `scratch/bat_full_mut/`) fails via check 1 + check 4 + case
  `reorder_dup_lastwins` (`src='child_inj'`) while check 2 stays **True** —
  matching the critic's independent mutant. Deletion is verdict-safe
  (`scratch/bat_nocheck2/`: 74/74; `scratch/bat_nocheck2_mut/`: same three
  failures persist). The author already documents it as "kept as documentary";
  the receipt payload records the topology, so I do not propose landing the
  deletion — it would trade a 2-line gate for one less explicit topology
  statement in `verdicts.json`.
- **F — `reorder_cells` whitelist entries `gluevictim` / `spawn ERR`
  (`bpy_battery.py:351-352`).** Removing them changes degraded-topology
  diagnostics, not passing-path behavior: `scratch/bat_nowl_mut/` (entries
  stripped + collapse mutant) adds a redundant `reorder_no_extra_cells=False`
  on top of the real failures. Rejected — the entries are the
  known-topology-vs-forged-cell discriminator.
- **Carried from r80 (not r81 weight):** the 49 unpinned diagnostic rows
  (r79 lattice extras + `keyframe_ins/keyframe_f/op_add_fresh/op_modapply_w0/
  walltime_s0-2`). They are cited receipt evidence; deleting them would harm
  the evidence axis. r81 added no new ones.

## (4) Preserved contract (measured, not assumed)

- 74/74 PASS, signal_fail=0, quirk_drift=0, fatals=0, done_marker=True; 4/4
  order checks; stderr byte-empty; deterministic probe stdout `947ad726…`
  (my ×2 + author's ×2 + critic's replay all agree).
- Insertion-only contract: every r79/r80 row byte-identical by body and the
  r79/r80 sub-sequences byte-identical by sha (above); only the `closed` row's
  stream position moved (112 → 118).
- Parse attribution under the fabricated reorder: `child_marker`→child,
  `dup`→parent (physical last-wins pinned), glued `gluevictim` line dropped
  (`^ARM` fails), `post_spawn` preconditions (`child_rc=0 line_buf=False
  write_through=False fd1_fifo=True`) — one duplicate cell, correctly resolved.
- The three deletion candidates leave all of the above byte-identical
  (§1, combined ABC run).

## (5) Tradeoffs and stop point

- D-A/B/C are pure code weight (1 store + 3 branch lines + 1 predicate term);
  the byte-identity proofs hold only under the battery's pipe capture — a
  shell-redirected manual run legitimately differs on `fd1_fifo` (`False`),
  which I measured and which the author/critic already document.
- The largest remaining receipt weight (unpinned diagnostics, walltime sleep
  rows) is evidence-bearing; the documentary order check is author-acknowledged
  and payload-recorded. Both are deliberate.
- **Stopping:** the next deletion (prior rows, unpinned evidence rows, or the
  documentary check) would harm an axis — byte-stability, evidence, or
  documentary topology. No further weight can be removed without breaking a
  preserved contract.

## Evidence index

- Scratch root: `corpus/live/r81-simplifier/` — `arrival-shas.txt`,
  `audited-shas.txt`, `baseline-arms.txt`, `landed-arms.txt`, `watch.log`;
  `tools/{refcount,dupes_census,cases_census,prior_rows}.py`;
  `scratch/{A_t0,B_edge1,C_und}.py` (old tree) and
  `scratch/new/{CTRL,A_t0,B_edge1,C_und}.py` + `*.pipe.stdout.txt`;
  `scratch/landing_ABC/`, `scratch/bat_{full,nocheck2,full_mut,nocheck2_mut,nowl_mut}/`,
  `scratch/pipe_run.py`, `scratch/parser_characterize.{py,out.txt}`.
- Receipts: baseline `baseline-runs/bpy-20261014T143530350390Z` +
  `…143937463067Z` (both `fb336ae5…`, 64/64); landed
  `landed-runs/bpy-20261014T150032790991Z` + `…150037278462Z` (both
  `947ad726…`, 74/74); ABC landing `scratch/landing_ABC/runs/bpy-20261014T150313139043Z`
  (74/74, `947ad726…`).
- Tracked files were read-only to this seat; final sha re-check at 15:03:30Z
  (pre-commit) and against `git show HEAD:…` post-commit both return the
  audited pair; the seat's writes are all untracked scratch under
  `corpus/live/r81-simplifier/**` plus this report.
- Commit-message nit (no fixture impact): `65b2f26`'s subject body says "prior
  111 ARM lines byte-identical"; my receipt measures **112/112** (r79 78 +
  r80 evalcat 34, `closed` included; `tools/prior_rows.py`). One-line
  undercount in the message only — the fixture and the author report's own
  "112 prior ARM rows" are correct.

Stopping here.
