# game-dev-3d round 81 — author (seat: author, host: devin)

## Declared move (verbatim)

ROUND 81 — 3d lane. TWO arms (xconnector X1 on bpy + evalcat extension rows
per r80 critic): (1) reorder fabrication on `blender -b -P`: a spawned
descendant inherits blender's fd1; buffered-python parent -> prefix
reordering of ARM-stream bytes — live hazard class for the battery's own
ARM parser; pin parse-survival cells (the parser must not misattribute
reordered bytes). (2) evalcat extension rows: fold ~6 representative
bare-class rows into the tracked catalogue (scene-prop write, hierarchy
link, data swap, parent write, objects.remove, orphans_purge).
Claim: reorder topology falsifiable per runtime; catalogue extension
byte-stable. AUTHOR: implement in tracked fixture(s), self-verify, author
report. Insertion-only; prior rows byte-stable.

Runtime: Blender 5.2.1 LTS headless (hash `9e2066aef7ef`), embedded CPython
3.14.7, `/usr/bin/blender -b -P`. LSP unavailability recorded (per scout):
no `lsp` device serves this repo — all edits are text-level insertion
points located by read/grep; no cross-file rename was needed.

## Landed changes (insertion-only; 331 +, 3 −, all three − are
## mechanical line-continuations: two tuple literals + the verdict gate)

- `corpus/fixtures/bpy_sync_probe.py` (`bfa80ed4…` → `02131534…`; committed HEAD blob after the simplifier fold is `58ffb9f2…` — report cites the pre-fold landing blob):
  - `import os/stat/subprocess/sys` added (`:41-44`).
  - Six `_ec_x_*` sub-probes (`:1029-1174`) appended as an r81 section
    between `_ec_walltime` and `arm_evalcat`, all called **inside**
    `arm_evalcat`'s tuple after `_ec_walltime` (`:1188-1189`) so they run
    before `closed` and stay under the closed-set falsifier — the armed
    bare catalogue grows 8 → 14 rows.
  - `arm_reorder()` (`:1227-1251`) appended last in the runner tuple
    (`:1256`). Construction per r81-critic corrections:
    `sys.stdout.flush()` seals the prior rows' byte-prefix, then
    `gluevictim` + `pre_spawn` are emitted into the block buffer
    (uncommitted), then `/bin/sh -c` (inherited fd1) writes a valid ARM
    row (`child_marker`), a forged duplicate cell (`dup src=child_inj`),
    and an unterminated tail `REORDERGLUE::`; then the parent's `dup
    src=parent` + `post_spawn` (with runtime precondition fields
    `child_rc/line_buf/write_through/fd1_fifo`) and a final flush.
- `corpus/fixtures/bpy_battery.py` (`ae3b04b1…` → `111568ee…`):
  docstring r81 line (`:17-23`); +10 CASES rows appended before the closing
  `]` (`:200-258`) — six `ext_*` EDGE pins + four reorder FD1 pins; an
  `order_checks` block (`:334-370`) on raw stdout (the case model cannot
  express byte order) gated into the verdict (`:389`) and recorded in the
  receipt payload (`:397-398`).

## Measured result — battery `bpy-20261014T145725071084Z`: 74/74 PASS,
## 4/4 order-checks PASS (also `…T145803952150Z`, identical stdout sha
## `947ad726…` — deterministic ×2)

**Arm 2 (catalogue extension) — supported.** All six folded classes measure
`held=stale invoked=none dpre=dpost=dfcp=dfc=dund=0` — inert bare writes,
none can trip the falsifier (`closed | violations=0` byte-identical). Rows
(probe.stdout.txt `:112-117`):

| class (point) | edge | discriminating witnesses |
|---|---|---|
| `ext_frame_current` | 1 | `held_loc=(0,0,0)` → `fresh_loc=(0,4,0)`; `frame=2`; **`get_dup=1 get_fc=0`** — lazy tagged eval binds the frame value with dup firing and fc never firing (closes r80-boundary unknown (a)) |
| `ext_hier_link` | 1 | `held_names=o` → `fresh_names=n|o`; `rna_child=True rna_n=1` (RNA membership immediate) |
| `ext_data_swap` | 1 | `held_mesh=verts3:xmax1.000` → `fresh_mesh=verts16:xmax1.000`; `rna_verts=16` (tier-0 RNA flip) |
| `ext_parent_write` | 1 | `held_mw=(0,0,0)` → `fresh_mw=(3,0,0)`; `rna_mw_w0=(0,0,0)` sampled pre-eval (scout's sampling trap avoided); `rna_parent=tgt` |
| `ext_obj_remove` | 1 | `held_names=keep|o` (freed ID still enumerated — fragility note) → `fresh_names=keep`; `rna_objs=keep` |
| `ext_orphan_purge` | absent | `purged=1`, `rna_meshes_before=2 → rna_meshes_after=1`; graph witness non-discriminating (`o`→`o`) |

Label decision (scout delta §6.4): `orphans_purge` takes `edge=absent` —
the label reads "no eval event on this axis", now covering the data-layer
axis, not only wall-time. The discriminating witnesses are the data-layer
counts; the depsgraph names witness is kept as evidence.

**Arm 1 (reorder fabrication) — supported on this runtime.** Stream layout
(`:119-125` of the receipt): the prior 112 ARM rows are an untouched
prefix; then `child_marker`, forged `dup src=child_inj`, the glued
casualty `REORDERGLUE::ARM reorder | gluevictim | …` (one physical line),
then `pre_spawn`, `dup src=parent`, `post_spawn`. The parent's
pre-spawn-emitted row lands **after** every child byte — prefix reorder
fabricated live. Parser outcomes, all pinned:

- `child_marker` parses to its own cell (`who=child`) — a descendant's
  valid ARM row is accepted; the injection surface is documented, not
  hidden.
- `dup` resolves `src=parent` — the parser's physical last-wins tie-break
  pinned explicitly (r81-critic C1: the value flips with byte order; the
  pin is the tie-break, not a universal).
- `gluevictim` emitted but its cell is absent — the spliced line fails
  `^ARM ` and is **dropped, not misattributed** (r81-critic C2 boundary,
  pinned as `reorder_splice_dropped`).
- `post_spawn` pins the mechanism preconditions: `child_rc=0
  line_buf=False write_through=False fd1_fifo=True` (block-buffered pipe).

Scope per r81-critic: survival is pinned for **distinct keys + marker
presence + the explicit physical tie-break**. The parser still loses a
row to splice corruption (demonstrated live by `gluevictim`) and the
tie-break is order-dependent — the claim wording stays bounded, never
"the parser cannot misattribute reordered bytes".

## Evidence

- Battery: `python3 corpus/fixtures/bpy_battery.py --runs
  corpus/live/r81-author/runs` → `cases=74 pass=74 fail=0
  (signal_fail=0 quirk_drift=0) launch_ok=True done_marker=True fatals=0
  exit=0`; receipts `runs/bpy-20261014T145725071084Z/` and
  `…T145803952150Z/` (`verdicts.json` carries the new `order_checks`
  block; probe stderr byte-empty; probe wall 4.39 s vs 4.24 s baseline —
  TIMEOUT_S=60 unaffected).
- Byte-stability chain (pre-edit baseline `…T145213656637Z`, 64/64,
  stdout sha `fb336ae5…`): post-fold r79 first-78 prefix sha `08101bed…`
  unchanged; r80 evalcat 34-line subsequence sha `146af473…` unchanged;
  all 112 prior ARM rows byte-identical as an ordered subsequence (the
  `closed` row shifts 112 → 118, content unchanged); non-ARM lines
  (banner, `PROBE_DONE`) identical; stderr 0 B.
- Falsifier liveness (claim is "falsifiable per runtime"): mutant
  `corpus/live/r81-author/probe_collapse_mutant.py` (one-line
  `sys.stdout.reconfigure(line_buffering=True)` inside `arm_reorder`)
  collapses the window; the tracked checks re-run against its stdout via
  `corpus/live/r81-author/liveness_check.py` → **5 failures**:
  `child_before_pre_spawn` False (discriminator flips), `splice_dropped`
  False (gluevictim parses under collapse), `dup` resolves `child_inj`,
  `post_spawn` reports `line_buf=True`/`fd1_fifo=False`. On the real
  receipt the same checker reports 0 failures. The pins discriminate;
  they are not constant-True decorations.
- Direct probe run `probe.direct.stdout.txt` (file-redirected fd1)
  emitted `fd1_fifo=False` — the precondition pin reflects the actual fd
  kind, and the reorder still formed (buffered either way).

## Remaining unknowns / risks

- `ext_obj_remove`'s `held_names=keep|o` rides a freed-ID read — stable
  ×2 here and corroborated by scout/boundary, but a future build that
  refuses name reads on freed IDs breaks the row (fragility inherited
  from the measurement, flagged by r81-scout §6.6).
- The reorder arm's child is short-lived `/bin/sh`+printf and waited; a
  Python descendant adds its own withholding layer (scout medium-
  confidence item). tty / `--python` interactive / Windows-console
  regimes unmeasured — the pins would falsify there by design.
- `reorder_child_before_post_spawn` is non-discriminating (True under
  collapse too) — kept as documentary; only `child_before_pre_spawn`
  discriminates (scout §3).
- `closed | violations=0` now covers 14 bare rows + the event axis — the
  closure remains bounded to the probed catalogue (r80-critic wording);
  the ops rows stay in-set by construction.
- Critic's wider list (`update_tag`, custom setters, `libraries.load` …)
  remains unfixed-sweep evidence, not tracked rows — candidate for a
  later fold; the six briefed classes are the tracked representative set.
- The spliced-casualty demonstration means one emitted parent row is
  lost per run by construction — a deliberate, documented receipt, not a
  defect; `reorder_no_extra_cells` guards the cell surface.

Files changed: `corpus/fixtures/bpy_sync_probe.py`, `corpus/fixtures/
bpy_battery.py`, this report, and scratch receipts under
`corpus/live/r81-author/`. Stopping here.
