# R81 adjudicator (Sol) — bpy reorder fabrication (X1 second runtime) + evalcat extension rows

Round: 81. Wave: `shokunin-train-20261101-w12`. Work commit `65b2f26`.

## Declared move (two arms)

(1) Reorder fabrication on `blender -b -P`: a spawned descendant
inherits blender's fd1; block-buffered parent withholds pre-spawn bytes
→ child rows land as a prefix — parse-survival pinned.
(2) Six r80-critic fold rows into the tracked evalcat catalogue
(frame_current, hier_link, data_swap, parent_write, obj_remove,
orphans_purge) — run inside arm_evalcat before `closed`, under the
closed-set falsifier.

## Claim adjudication

- **Reorder topology CONFIRMED on bpy** (74/74 + 4/4 order-checks,
  deterministic ×2; scout's 34-cell matrix + critic's mutants + my own
  replay): child ARM rows land before the parent's pre-spawn-emitted
  rows (`child_marker` at stream offset < `pre_spawn`); the forged dup
  resolves physically last-wins to the parent row; the unterminated
  `REORDERGLUE::` tail splices onto `gluevictim` which the `^ARM`
  parser **drops** (cell absent, bytes present — not misattributed).
- **X1 prediction (iv) falsified on bpy**: `PYTHONUNBUFFERED=1` is
  IGNORED by Blender's embedded interpreter — only honored with
  `--python-use-system-env` (boundary). Collapse controls = flush /
  `reconfigure(line_buffering=True)`. Per-runtime falsifiability is
  the claim's own shape, so this falsification is the designed
  discriminator, not a defect.
- **Evalcat extension**: all 6 classes measured `held=stale`, handler
  deltas 0 — five `edge=1` (frame_current/hier_link/data_swap/
  parent_write/obj_remove), `orphans_purge` `edge=absent` (data-layer
  destruction, depsgraph witness non-discriminating — label extended
  per scout's gap). `frame_current` pins `get_dup=1 get_fc=0`, closing
  r80-boundary unknown (a). Bare catalogue 8→14 under the falsifier;
  `closed|violations=0` preserved.
- **Parse-survival scope (critic's corrections folded)**: the pins
  cover distinct-key attribution, marker presence, drop-not-
  misattribute, and physical last-wins — NOT "no misattribution" in
  general (a body-splice via mid-line flush is out of the arm's reach;
  noted as the residual hazard class). Prior-row wording: r79 78-line
  block is a byte-identical prefix; r80 rows preserved in-order
  (extension rows insert before `closed`).

## Seat accounting

9/9 seats landed or produced evidence: author `65b2f26` (+331/−3,
insertion-only, 3 mechanical line-continuations); scout 34-cell matrix
+ collapse controls + extension-row pre-measurement; boundary 14-cell
reorder + 74/74 fold-ready extension anchors + `child_before_pre_spawn`
discriminator identification; critic collapse-mutant FAIL proof (the
pins discriminate) + wording corrections; scribe parser-hazard catalog
(last-wins, midline merge, forged violations=0) + byte-stability watch;
baseline zero-drift freeze on `ae89c13` (64/64 byte-identical, 176/176
Godot, 31/31 three.js); verifier + reviewer + simplifier landed or
recorded pending at report time.

## Verdict

**ADMIT** — reorder fabrication is runtime-confirmed on bpy with the
parse-survival contract pinned; evalcat bare catalogue extended 8→14
with every row measured edge/absent under the falsifier. Bounded:
Blender 5.2.1 `-b -P`, CPython-embedded 3.14.7 buffering (131072 B,
PYTHONUNBUFFERED-inert), pipe capture, this host.
