# game-dev-3d round 81 — scout (seat: scout, host: devin)

Claim under test (r81 lane move, verbatim): **"reorder topology falsifiable per
runtime; catalogue extension byte-stable."** Two arms — (1) X1 reorder
fabrication on `blender -b -P` (fd1-inheriting descendant × buffered parent →
prefix reordering of ARM-stream bytes; parse-survival cells for the battery's
own parser), (2) six representative bare-class rows folded into the tracked
evalcat catalogue (r80-critic fold guidance). This seat pre-measures both claim
surfaces independently; the author owns the tracked fold.

Lane root `~/Projects/shokunin/game-dev-3d-shokunin`, HEAD `ae89c13`, tracked
fixtures as read: `corpus/fixtures/bpy_sync_probe.py` sha `bfa80ed4…` (1041
lines), `corpus/fixtures/bpy_battery.py` sha `ae3b04b1…` (302 lines). Runtime
Blender 5.2.1 LTS headless (hash `9e2066aef7ef`), embedded CPython 3.14.7.
**LSP unavailability recorded:** the MCP census on this host exposes only the
`rea` (Ghidra) server — no `lsp` device serves this repo, so all
definition/caller tracing below is text-level (read + grep), never presented
as semantic proof. Scratch + receipts: `corpus/live/r81-scout/` (ignored;
`manifest.sha256` pins every artifact cited). Write scope respected; no git
mutations.

## (0) Viability — positive

| command | exit | wall | evidence |
|---|---|---|---|
| `python3 corpus/fixtures/bpy_battery.py --runs …/runs/baseline-a` | 0 | 4.24 s probe | 64/64 PASS, signal_fail=0 quirk_drift=0, `n_arm_lines=112`; stdout sha `fb336ae5…` |
| same, `--runs …/runs/baseline-b` | 0 | 4.25 s probe | 64/64 PASS; stdout **byte-identical** (`cmp`) |
| `blender -b -P bpy_reorder_probe.py` (default / `PYTHONUNBUFFERED=1`) | 0 / 0 | — | `runs/reorder/{default,default2,unbuffered}.stdout.txt`, stderr 0 B each |
| `blender -b -P bpy_ext_probe.py` ×2 (corrected sampling) | 0 / 0 | — | `runs/ext/ext-c|d.stdout.txt` identical; 6 rows |
| `blender -b -P bpy_ext2_probe.py` ×2 (addendum classes) | 0 / 0 | — | `runs/ext/ext2-c|d.stdout.txt` identical; 4 rows |
| `python3 fold/bpy_battery_r81.py --runs …/fold-a|-b` | 0 / 0 | 4.4 s probe | 73/73 PASS, 121 ARM lines, order checks all True; stdout identical ×2 |
| mutant runs: no-newline descendant / flush-collapse arm | 1 / 1 | — | battery FAIL by missing rows / by order check (§3) |

Baseline cross-check: the tracked probe's stdout reproduces the landed receipt
`corpus/live/runs/bpy-20261014T142716270088Z/probe.stdout.txt` byte-for-byte
(same sha `fb336ae5…`), and its first 78 ARM lines are byte-identical to the
r79 pre-fold baseline (`69b512cb…`, `corpus/live/r80-author/runs/bpy-…142209559394Z`).

## (1) Arm 1a — buffering facts on the bpy runtime

`RINFO` (probe-flushed first line): `version=3.14.7
default_buffer_size=131072 line_buffering=False write_through=False
isatty=False`. Blender's `-b -P` script stdout is a standard block-buffered
`io.TextIOWrapper` over fd1; the tracked probe's `emit()` never flushes
(`bpy_sync_probe.py:56-58`), so the whole ARM stream is one userspace buffer.

**Delta vs X1 prediction (iv):** `PYTHONUNBUFFERED=1` is **ignored** by
Blender's embedded interpreter — `unbuffered.stdout.txt` reports
`unbuf_env=1` yet `line_buffering=False`, and the entire run is byte-identical
to the default run except that one field (`diff` = 1 line). Every topology
cell keeps its reorder shape. On bpy the window collapses only via explicit
`flush()` or `sys.stdout.reconfigure(line_buffering=True)`, not via the env
var. (X1 risk "Blender's print path may differ" is closed: it does not.)

Stream layout fact: in the captured (non-tty) stdout the Python block comes
first and Blender's C-stdio banner/`Blender quit` come last (baseline receipt:
first line is already `ARM transform | w0 | RNA | …`; banner after
`PROBE_DONE`). A mid-run descendant writing into inherited fd1 therefore lands
at the **absolute front** of the stream — before every parent ARM line.

## (2) Arm 1b — reorder topology cells (measured byte order)

| cell | mechanism | measured stream order | topology |
|---|---|---|---|
| `prefix` | `os.system("printf …")`, parent unflushed | `CCHILD CPRE CPOST` (122<129<134) | **prefix reorder** |
| `popen` | `subprocess.Popen` inherits fd1 | `PCHILD PPRE PPOST` (158<165<170) | **prefix reorder** |
| `armline` | child emits a full ARM line between two parent lines | `child_marker` (190) → `parent_head` (236) → `parent_tail` (282) | child line precedes all parent lines; all lines intact |
| `bigwrite` | parent writes `>131072` B (crossing), then child | `BIGPRE`+135168×`x` → `BIGCHILD` (135741) → `BIGMID` (135751) → `BIGPOST` | **hybrid**: crossing write flushes, then the parent's *pre-spawn* small write (` BIGMID `) is re-withheld and lands after the child |
| `splice` | parent flushes before child (control) | `SPRE SCHILD SPOST` | causal order — window collapsed |
| `reconf` | `reconfigure(line_buffering=True)` then newline-terminated writes | `RCONF ok PRE` → `RCHILD` → `RCONF POST` | causal order — collapse control |
| `midline` | child bytes injected while parent mid-line | line becomes ` who=childARM reorder | mid_parent | EDGE | who=parent` | parent line corrupted at the front |
| `fusion` | parent flushed `AR`, child completes | forged valid line `ARM reorder | fused | EDGE | who=child`; parent continuation non-matching | fragment fusion forges a row |
| `dupe` | same key parent+child | child, parent, parent2 | last-wins by stream order |

Determinism: `default` vs `default2` differ only by the added `reconf` cell
(`diff` receipt). Cells are byte-stable in-window on this build.

## (3) Arm 1c — parser survival (tracked parser, measured)

Fed to the tracked `parse_arms` (`bpy_battery.py:194, 211-220`; keyed
`(arm,point,layer)`, last-wins):

| stream | parser outcome | hazard |
|---|---|---|
| measured reorder stream | child row `who=child`; parent rows `who=parent`; child idx 190 < parent idx 236 | **survives** — content-keyed attribution, full-line child write |
| `midline_corrupt` | 0 rows | parent row **lost** (regex mismatch) |
| `hijack_no_newline` | child row = `{who: 'childARM', loc: (5,0,0), mw_t: (0,0,0)}`; parent `transform|w0|RNA` row gone | child row **absorbs the parent's witness values** |
| `fusion_forge` | forged `(reorder, fused, EDGE)` row present; `lost_parent` gone | mixed-provenance row fabricated |
| `dupe` (child first / child last) | `who=parent` / `who=child` | last-wins is order-dependent |
| forged `evalcat|closed|EDGE|violations=0` last | parser reports `violations=0` | **forged pin passes** if the child lands last |

Case-level impact on the tracked 64-case battery: non-newline first-line
prefix → `transform_w0_rna_loc_fresh`, `transform_w0_rna_mwt_stale` FAIL
(missing); space-token injection with a non-pinned key → all cases PASS but
the row silently carries `who=child`; colliding-key injection
(`loc=(9,0,0)`) → false FAIL of the pinned row.

End-to-end scratch fold (probe copy + `ext81` + `arm_reorder`; battery copy +
9 CASES + an order/parse-survival block):

- normal descendant (newline-terminated marker): **73/73 PASS**, 121 ARM
  lines, order checks True; child line is stream byte 0
  (`ARM reorder | child_marker …` precedes every parent line).
- no-newline mutant: battery exit 1, 3 signal fails — first stream line is
  `…who=childARM transform | w0 | RNA | …` (hijack), parent rows missing →
  **corruption is detected, not silently misattributed**.
- flush-collapse mutant (flush before spawn = line-buffered analogue): rows
  all parse (cases 73/73) but the order check FAILS → battery exit 1.
  **Discriminating power:** `child_before_pre_spawn` is the topology cell
  (True under reorder, False under collapse); `child_before_post_spawn` is
  non-discriminating (True in both — the child is always before a post-spawn
  write). Pin the former.
- Battery-model delta: CASES rows cannot express cross-line order; the order
  fact needs a raw-stdout index check in `bpy_battery.py` (mechanism
  demonstrated in `fold/bpy_battery_r81.py`).

## (4) Arm 2 — six extension rows, independently measured

All six are **bare (invoked=none) and inert**: `held=stale` at write+0,
`dpre=dpost=dfcp=dfc=dund=0` on every row (so none can increment the closed
row's violations). Proposed pins (values from `runs/ext/ext-c.stdout.txt`):

| class (point) | edge | discriminating witnesses (held → fresh) | proposed pin keys |
|---|---|---|---|
| scene-prop `frame_current` | 1 | `held_loc=(0,0,0)` → `fresh_loc=(0,4,0)`; `get_dup=1 get_fc=0` | held, invoked, deltas, edge, frame=2, held_loc, fresh_loc, get_dup, get_fc |
| hierarchy link `children.link` | 1 | `held_names=o` → `fresh_names=n|o` | …, held_names, fresh_names |
| data swap `ob.data=` | 1 | `held_mesh=verts3:xmax1.000` → `fresh_mesh=verts16:xmax1.000`; rna_verts=16 | …, held_mesh, fresh_mesh, rna_verts |
| parent write `ob.parent=` | 1 | `held_mw=(0,0,0)` → `fresh_mw=(3,0,0)`; `rna_mw_w0=(0,0,0)` | …, held_mw, fresh_mw, rna_mw_w0 |
| `objects.remove` | 1 | `held_names=keep|o` (freed ID still enumerated) → `fresh_names=keep` | …, held_names, fresh_names, rna_objs |
| `orphans_purge` | data-layer | graph witness non-discriminating (`o`→`o`); data read immediate `meshes 2→1`, `purged=1` | deltas + purged + rna_meshes_after (+ label decision, below) |

New measured facts:

- **`frame_current` closes r80-boundary unknown (a)**: after the silent RNA
  frame write the next tagged get binds the frame-dependent value
  (`fresh_loc=(0,4,0)`, `get_dup=1`) and fires **no** `frame_change_*`
  (`get_fc=0`) — frame-dependent nodes do see the new frame at the lazy
  tagged eval (boundary left this as inference, `r80-boundary.md:149-151`).
- **Parent-write witness-sampling trap (self-caught):** `ob.matrix_world` RNA
  read *after* the fresh get shows `(3,0,0)`; sampled at w0 it is `(0,0,0)`
  (stale, consistent with the tier-1 definition at `bpy_sync_probe.py:12-15`
  and the pinned row `transform_w0_rna_mwt_stale`, `bpy_battery.py:34`). Pins
  must sample pre-eval — my first ext receipt (ext-a/b) is superseded by
  ext-c/d for this reason.
- **`objects.remove` held read is a freed-ID read** (`keep|o`): stable ×2 on
  this build (corroborates `r80-scout.md:138-141`), but it is a fragility
  note — a future build that refuses name reads on freed IDs would break the
  row.
- **`orphans_purge` label gap:** the existing vocabulary has no fit —
  `absent` is defined for the wall-time axis (`bpy_sync_probe.py:440`); the
  purge is immediate data-layer destruction with no graph effect. Author
  decision: re-word the label definition ("no eval event on this axis") or add
  a data-layer label.
- Addendum (r80-critic's *other* named classes, absent from the brief's six):
  `update_tag` obj/scene → held stale, deltas 0, edge=1 (tag ≠ eval);
  `custom_matrix_world` → edge=1, rna_loc immediate; `custom_dimensions` →
  edge=1 with an evaluated-scale witness (`held_scale=(1,1,1)` →
  `fresh_scale=(2,2,1)`; the location witness is non-discriminating for a
  scale write). Measured in `runs/ext/ext2-c.stdout.txt`, deterministic ×2.

## (5) Catalogue extension byte-stable — pre-measured

- Tracked baseline: 112 ARM lines, stdout sha `fb336ae5…` (×2, equals the
  landed receipt); first 78 lines = r79 `69b512cb…`.
- Scratch fold (insertion-only: runner tuple `… arm_evalcat, arm_ext81,
  arm_reorder` last, `bpy_sync_probe.py:1033-1035`; CASES appended before the
  closing `]` at `bpy_battery.py:190-192`; additive `import os`): 73/73 PASS
  ×2; 121 ARM lines; the parent-side 118 ARM rows contain the baseline 112
  **byte-identical** (and in order); the 9 new rows byte-identical across
  runs; full stdout identical across runs. Probe wall 4.4 s vs 4.24 s
  baseline (TIMEOUT_S=60 unaffected; +0.16 s for the six ext sub-probes +
  reorder arm).

## (6) Deltas (what the author's design should carry)

1. `PYTHONUNBUFFERED=1` does not collapse the reorder on bpy (X1 (iv)
   falsified here); use `flush()` / `reconfigure(line_buffering=True)` as the
   collapse controls and record `default_buffer_size=131072` per receipt
   (xconnector rule, `xconnector.md:181-186`).
2. The topology pin must be `child before the pre-spawn sentinel`; the
   post-spawn variant is non-discriminating. The order fact needs a
   battery-side raw-index check (case model can't express order).
3. Arm design rules derived from the hazards: descendant must inherit fd1
   (no capture/redirect), write a **newline-terminated full line**, and no
   parent flush may occur between the pre-spawn sentinel and the spawn. A
   non-newline marker corrupts the parent's first buffered line (measured:
   2 missing cases + hijacked child row); a flush before the spawn collapses
   the topology (measured).
4. `orphans_purge` needs a label decision (existing `absent` is wall-time
   scoped) and its graph witness cannot discriminate — the data-layer read is
   the witness.
5. Parent-write pins must sample RNA `matrix_world` at w0, pre-eval.
6. `objects.remove` pin rides a freed-ID read (`keep|o`); record it as such.
7. The critic's `update_tag` and custom-setter classes are outside the
   brief's six; both measured here (`edge=1`, inert) if the author wants the
   critic's minimal set fully covered.
8. `frame_current` row also closes boundary unknown (a) — worth a witness
   (`fresh_loc`) so the closure is pinned, not inferred.

## (7) Confidence and remaining unknowns

- **High**: bpy block-buffering facts (131072, `line_buffering=False`) and
  PYTHONUNBUFFERED inertness; prefix-reorder topology for os.system/Popen
  children and the tracked fixture end-to-end; hybrid re-withholding after a
  crossing write; content-keyed parser survival for full-line prefix reorder;
  the five measured corruption/forge modes with exact parser outputs; all six
  extension classes inert with discriminating fresh controls; byte-stability
  of the insertion-only fold.
- **Medium**: generality of the child-behaviour cells to long-running /
  unwaited descendants (my children are short-lived and waited); the C-stdio
  banner-last ordering mechanism (inferred from bytes, not traced to source).
- **Unknowns**: a Python-descendant child adds its own withholding layer
  (g2d lane's pygame cells; for bpy any child runtime inherits the same fd1
  seam but timing depends on the child's own buffering); interactive
  `--python` / tty / Windows-console bpy regimes unmeasured; the author's
  final arm/label/order-check design (my fold is scratch evidence, not the
  tracked authority).

## (8) Receipts (sha256; all under `corpus/live/r81-scout/`)

| artifact | sha256 |
|---|---|
| `runs/baseline-a/bpy-…143607432635Z/probe.stdout.txt` (= baseline-b, = landed receipt) | `fb336ae5…` |
| `runs/reorder/default.stdout.txt` / `default2.stdout.txt` / `unbuffered.stdout.txt` | `bc57280a…` / `70af0954…` / `2c328ae3…` |
| `runs/reorder/parse_survival.txt` (parser cells) | in manifest |
| `runs/ext/ext-c.stdout.txt` (= ext-d; six rows) | `8d60b9b4…` |
| `runs/ext/ext2-c.stdout.txt` (= ext-d; addendum) | `513676b4…` |
| `runs/ext/mw.stdout.txt` (RNA-mw sampling probe) | `ffe2445e…` |
| `fold/runs/fold-a|b/bpy-…/probe.stdout.txt` (121 ARM, identical) | `745c1584…` |
| `fold/runs/fold-mut2/bpy-…/probe.stdout.txt` (hijack mutant) | `bfdf9c69…` |
| `fold/runs/fold-flat2/bpy-…/probe.stdout.txt` (collapse mutant) | `f3634de5…` |
| `bpy_reorder_probe.py` / `bpy_ext_probe.py` / `bpy_ext2_probe.py` / `parse_survival.py` | `4903a0e4…` / `aa7f04ca…` / `075373f5…` / `82fb8ff8…` |
| `fold/bpy_sync_probe_r81.py` / `fold/bpy_battery_r81.py` | `f5bfd192…` / `d5cdafa5…` |
| `manifest.sha256` | `3b1a4565…` |

Verdicts JSONs for every battery run are under `runs/` and `fold/runs/`
(64/64 ×2 baseline; 73/73 ×2 fold; FAIL ×2 mutants). Report only; I do not
judge, admit, edit, integrate, or ship. Stopping here.
