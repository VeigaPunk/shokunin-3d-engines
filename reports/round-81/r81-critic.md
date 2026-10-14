# game-dev-3d round 81 — critic (seat: critic, host: devin)

Adversarial audit of the r81 landed diff (arm 1 reorder fabrication + arm 2
evalcat fold). Reviewed artifacts are the **author's working-tree diff** at
`corpus/fixtures/bpy_sync_probe.py` sha256 `02131534a760eb33…` (+225 lines) and
`corpus/fixtures/bpy_battery.py` sha256 `111568eec55fe1e4…` (+109 lines),
stable from 14:57:06Z through the end of this review (re-hashed after every
run; no tracked file modified by this seat; scratch is gitignored
`corpus/.gitignore:1`, this report is the only other write). No author report
or commit had landed at review time; the diff state reviewed is the one the
author's own receipts (`corpus/live/r81-author/runs/bpy-20261014T145725071084Z`)
match. Prior tree = r80 HEAD `ae89c13` (probe `bfa80ed4…`, battery `ae3b04b1…`).
Same host/build as r79–r80: Blender 5.2.1 LTS (`/usr/bin/blender` hash
`9e2066aef7ef`), python3 3.14.7. All receipts under `corpus/live/r81-critic/`.

**Net: the landed diff survives every falsification I could construct — 74/74
with all four order-checks green, 3/3 byte-identical replays, prior rows
byte-stable, and each new falsifier demonstrably live (three independent
mutations each force the battery to FAIL). The claim is correctly scoped.
Two coverage gaps and three nits remain, all wording/labeling; no defect
requires a fixture change.**

## 1. Landed diff — what was reviewed, and the replay

Probe (`bpy_sync_probe.py`): imports `os/stat/subprocess/sys`; six
`_ec_x_*` sub-probes (`:1029-1177`) appended to `arm_evalcat`'s list *before*
`closed`; `arm_reorder()` (`:1227`) appended last in the runner tuple
(`:1256`). Battery (`bpy_battery.py`): ten new CASES (`:200-258`) — six
`evalcat|ext_*|EDGE` + four `reorder|*|FD1`; a raw-stdout `order_checks`
block (`:342-368`); verdict gate extended with `order_failed` (`:389`) and the
checks exported in `verdicts.json`.

- **Replay** `python3 corpus/fixtures/bpy_battery.py` → exit 0,
  `cases=74 pass=74 fail=0 signal_fail=0 quirk_drift=0 launch_ok=True
  done_marker=True fatals=0`, probe 4.38 s, stderr byte-empty; all four
  `order_checks` pass (`runs/landed/bpy-20261014T145711083002Z/`).
- **Determinism**: 3/3 byte-identical replays — full stdout sha
  `947ad72643d2a450…`, ARM-only sha `3f12c7b45d352af8…`
  (`runs/det/bpy-20261014T1458{07,11,16}…`).
- **Prior-row byte-stability** (`runs/landed_stability*.txt`): the r79 78-line
  block is a **byte-identical prefix** (sha `08101bed…`); the r80 evalcat
  34-row block is byte-identical and in order as a subsequence (sha
  `146af473…`); the `closed` row is byte-identical (`violations=0`,
  unchanged events string); no prior CASES row changed (diff of parsed CASES:
  `changed 0 gone 0`); no case-key conflicts (the one pre-existing duplicate
  key `transform|w0|RNA` pins disjoint keys). Nuance for the verifier: the six
  ext rows are inserted *before* `closed` (by design, to keep them under the
  violations counter), so the prior evalcat block is no longer a contiguous
  prefix — `PROBE_DONE` moves 112 → 124. State it as "prior rows preserved in
  order; r79 block a byte-identical prefix", not "prior stdout is a prefix".
- **Counting nuance**: 123 ARM lines parse to `n_arm_lines=122` unique cells
  because the `dup` cell legitimately appears twice (child then parent); the
  extra line is the glued `REORDERGLUE::ARM …` line, which is not an ARM line
  (below). Not a drift.

## 2. Arm 1 — the landed fabrication is sound; falsifiers are live

Construction: `sys.stdout.flush()` seals the prior rows; `gluevictim` +
`pre_spawn` are emitted into the block buffer; a `/bin/sh` descendant
inherits fd1 and writes `child_marker`, `dup=child_inj`, and an
**unterminated** `REORDERGLUE::` tail; then the parent emits `dup=parent`,
`post_spawn`, flush. Measured stream
(`runs/landed/bpy-20261014T145711083002Z/probe.stdout.txt:118-123`):
`child_marker`, `dup=child_inj`, merged
`REORDERGLUE::ARM reorder | gluevictim | …` (dropped by `^ARM`, `:194`),
`pre_spawn`, `dup=parent`, `post_spawn` — child bytes physically precede the
parent's pre-spawn row, exactly the fabricated topology (my independent
pre-measurement: same topology, total-prefix, deterministic; the boundary
constant `131072` in the probe comment matches `io.DEFAULT_BUFFER_SIZE` and
the scribe's independently measured first-flush offset ~123.2 KB — no 8 KiB
constant anywhere).

Falsifier liveness (scratch mutants; tracked fixtures untouched):

| mutation | expected | measured |
|---|---|---|
| probe: `flush()` added after `pre_spawn` (collapse window) | order checks fail | `reorder_child_before_pre_spawn` FAIL, `reorder_splice_dropped` FAIL, **case `reorder_dup_lastwins` FAIL** (`src=child_inj` ≠ `parent`) → verdict FAIL (`runs/collapse/…`) |
| battery: parser de-anchored (`ARM_LINE.search`, no `^`) | splice cell appears | `reorder_splice_dropped` FAIL, 74/74 cases still pass → verdict FAIL (`runs/lax2/…`) |
| probe: `view_layer.update()` injected in `_ec_x_data_swap` | ext row + closed fail | `evalcat_ext_data_swap` FAIL and `evalcat_closed_set` FAIL (violations=1) → verdict FAIL (`runs/foldmut/…`) |

The collapse mutant is the strongest counterexample available for the claimed
topology: it flips the duplicate-key winner and two order checks, i.e. the
pins are not constants.

**Remaining coverage gaps (scope, not defects).**
- *G1*: the `dup` cell pins the case where physical-last = logical-last (the
  parent writes its duplicate *after* the spawn). A duplicate key whose
  descendant write is logically last still resolves to the parent value under
  the parser's physical last-wins (`bpy_battery.py:219`) — my C1 measurement
  (`runs/sim_nflush.stdout.txt`, last-wins → `parent_early` while the child
  wrote later). The landed wording is already honest ("pins the parser's
  physical last-wins tie-break", `bpy_sync_probe.py` reorder header); keep it
  that way and do not promote the row to "no misattribution under reorder".
  Optional cell if the round wants the symmetric case.
- *G2*: the splice cell covers the glue-at-line-start variant (parser drops,
  `^ARM` fails). The body-splice variant — child bytes landing inside a
  parent row's `k=v` body (`(reorder,torn,T).v = SPLICED-CHILD`, my C2,
  `runs/tear_evidence.txt`) — is reachable only via a mid-line parent flush,
  which the landed arm never does; not reachable in the landed fixture, so no
  fixture change is required. If a future arm ever flushes a partial row, the
  parser misattributes — worth one sentence in the scribe note.

## 3. Arm 2 — the fold pins match independent measurement

The six landed `ext_*` rows pin exactly the mechanism I measured independently
with the r80 witness harness (my `runs/fold_counter_{1,2,3}.stdout.txt`, 3/3
identical: all six inert, `held=stale`, `dpre=dpost=dfcp=dfc=dund=0`,
`edge=1`; scout `runs/ext/ext-a…d` agrees): no flush, no handler fire, one
tagged eval binds. Landed rows are discriminating — `held_loc/held_names/
held_mesh/held_mw` would flip under a flush, and the purge row's counts
(`rna_meshes 2→1`) carry the data-layer witness. The r80-critic trap I
pre-measured (an in-window `view_layer.update()` in `objects.remove` firing
`dpre=1 dpost=1` → spurious FALSIFIED) is avoided: the landed `_ec_x_obj_remove`
(`:1129-1151`) builds and settles `keep` and captures `dg0` *before* the
window; its receipt shows `dpre=dpost=0`. Falsifier liveness for the fold is
demonstrated by the injected-eval mutant above (`ext_data_swap` +
`closed` both fail), and because the six rows run before `closed`, a
FALSIFIED ext row also trips the violations pin. Byte-stability of the prior
catalogue is confirmed in §1.

## 4. Nits (no action required)

- `edge=absent` on `ext_orphan_purge` is a label extension: the depsgraph
  witness is non-discriminating (`o→o`), so the row cannot distinguish "no
  eval" from "eval that leaves this witness unchanged" — the same limitation
  every bare row has; the author documents it and the counts discriminate.
  Keep the label, keep the sentence.
- `reorder_splice_dropped` is construction-coupled: a future child with a
  trailing newline would no longer merge and the check would FAIL
  conservatively (false FAIL, never a silent pass). Acceptable; note it in
  the arm comment if the child program is ever edited.
- The `line_buf`/`write_through`/`fd1_fifo` pins are capture-context facts:
  the author's own direct (uncaptured) receipt shows `fd1_fifo=False`
  (`corpus/live/r81-author/probe.direct.stdout.txt`). The battery contract is
  the captured path, so pins hold; one word in the probe docstring
  ("captured") would prevent a reader from generalizing them.

## Impacted axes

- **depth**: reorder topology fabricated live and pinned per runtime
  (`blender -b -P`, pipe-captured); the discriminating cells are the
  child-before-pre_spawn order check and the physical-last-wins `dup` cell,
  both shown live under mutation. Parse survival is correctly scoped: distinct
  keys, marker presence, drop-not-misattribute for the glued line.
- **coverage**: 64 → 74 CASES; tracked bare catalogue 8 → 14; the six fold
  classes are under the closed-set falsifier; r79/r80 rows byte-stable.
- **calibration**: no thresholds changed; buffer constant `131072` matches
  `io.DEFAULT_BUFFER_SIZE`; no exact-count fragility added (`child_rc`,
  `frame`, derived booleans); the only new gate (`order_failed`) is
  conservative.

## Smallest safe corrections

1. Scorecard/LOG wording: "prior rows preserved in order (r79 block a
   byte-identical prefix; r80 evalcat block byte-identical as a subsequence);
   74/74 with four live order checks" — not "prior stdout byte-identical".
2. Keep the dup row's scope as written (physical tie-break); do not promote
   it to a no-misattribution claim (G1). Optional symmetric duplicate cell.
3. Note the body-splice boundary (G2) in the knowledge note; no fixture
   change required for the landed arm.
4. Optional nit sweep: "captured" in the probe docstring; one sentence on
   the splice check's construction coupling.

**Verification trail**: landed replay `runs/landed/…`; determinism `runs/det/…`;
stability `runs/landed_stability.txt`, `runs/landed_stability2.txt`; liveness
`runs/collapse/…`, `runs/lax2/…`, `runs/foldmut/…` (+ logs
`runs/landed_check_1.log`, `runs/liveness_landed.log`, `runs/liveness_lax.log`,
`runs/fold_liveness_landed.log`); pre-measurement `runs/pretrack/…`,
`runs/sim_*.stdout.txt`, `runs/tear_evidence.txt`, `runs/fold_counter_*.stdout.txt`,
`runs/evidence_table.txt`, `runs/unbuffered1.log`. I did not judge, admit,
edit, integrate, or ship anything; report only. Stopping here.
