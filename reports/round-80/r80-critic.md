# game-dev-3d round 80 — critic (seat: critic, host: devin)

Adversarial audit of the r80 evalcat fold. Reviewed as author working tree;
commit `faae4e0` landed during the review with **byte-identical fixture
blobs** (verified: `git show HEAD:…` sha256 = reviewed working-tree sha256),
so this audit applies to the committed tree verbatim. Reviewed artifacts:
`corpus/fixtures/bpy_sync_probe.py` sha256 `e9609814…` (1041 lines; evalcat
section `:417`, `_ec_edge` `:581`, `arm_evalcat` `:1016`),
`corpus/fixtures/bpy_battery.py` sha256 `ae3b04b1…` (302 lines; +27 CASES
`:81-192`). Same host/build as r79/frontier (`Blender 5.2.1 LTS`, hash
`9e2066aef7ef`). Frontier read first; author/scout/boundary reports
cross-read. Scratch + receipts: `corpus/live/r80-critic/` — counter probes
(`evalcat_counter_probe.py`, `…probe2.py`, `inst_probe.py`, `libprobe.py`,
`custom_setter_probe.py`), runs under `runs/` (all exit 0, stderr byte-empty
except where noted), author-replay battery, falsifier re-run, parser-hazard
demo.

**Net: the closure claim survives the strongest counterexample I could
construct. 37 additional mutation classes probed — zero flushes outside the
five surfaces; four independent sweeps (author 23 EDGE rows, scout 10-class
closure + 10-op, boundary 45-class screen hits=0, critic 37-class sweep)
agree. I independently replayed the landed fold (64/64; r79's 78 ARM lines
byte-identical) and re-ran the falsifier-liveness check (violations
0→1→1→1→2; `edge=FALSIFIED` fires on synthetic bare flush and bare handler
fire). Two real, small defects: (1) the `closed` row's falsifier only covers
the 8 `invoked=none` rows — the scorecard must say *bounded* closure, not
"closed"; (2) the tracked bare-class catalogue (8 classes) is far smaller
than the already-measured inert evidence — folding ~6 representative rows is
the smallest correction that makes the pinned catalogue match its claim.
Nits: r79-only module docstring; `dund` in the violation predicate; +3.5s
walltime arm (tradeoff, not defect).**

## 1. Counterexample hunt — falsifier NOT found (the assigned attack)

Method (strongest available): hold `dg0` pre-mutation, place a pending RNA
write `ob.location=(5,0,0)` as a graph-global witness (held stale `(0,0,0)`;
flush ⇒ `(5,0,0)`), run the candidate mutation with **no enumerated surface
called in-window** (call-site counters `de=get/vlu/fs/dgu/ops` all 0),
co-witness handler deltas (`dpre/dpost/dfcp/dfc/dund`) and then land via
`view_layers[0].update()`. Controls reproduced the five surfaces exactly:
dirty `get`/`vl.update`/`dg.update` → flush + dup+1; `frame_set` → flush +
fc pair+1, dup 0; `primitive_cube_add` → flush + dup+2.

Candidate classes probed (all **inert**: post held `(0,0,0)`, `dh` all-zero,
`de` all-zero): `frame_current` RNA write; `view_layers[0].depsgraph`
property; `ob.parent=`; `instance_type/instance_collection` (Empty object);
`objects.remove` / `batch_remove`; `orphans_purge`; `layer_collection.exclude`;
`view_layers.new`; `render.engine` switch; `ob.data=` swap (verts witness
3→4); `clear_geometry`+`from_pydata` (verts witness 3→3); `select_set`;
`view_layer.objects.active=`; `shape_key_add`; `animation_data_create`+empty
`action=`; `animation_data_clear`; `world=`+`camera=`; `collection.children.link`;
`hide_viewport`; `hide_set`; `keyframe_insert` (frontier-inert re-confirmed);
`scenes.new`; `matrix_world`/`dimensions`/`rotation_euler` writes;
`libraries.load(link=True)` and `(link=False)`+link; `enum` micro-probes.
Receipts: `runs/counter1.stdout.txt` (28 arms + 6 opcount, 1055 ms),
`runs/counter2.stdout.txt`, `runs/inst.stdout.txt`, `runs/libprobe.stdout.txt`
(+`lib/lib.blend`), `runs/custom.stdout.txt`.

In-process op-count stability (for pin semantics): `transform_apply` dup ×2
in 3/3 reps; `mode_set` EDIT ×2 / OBJECT ×1 in 3/3 reps; `primitive_cube_add`
dup ×2 — consistent with frontier "pin ≥1, not exact" (`counter1` opcount
rows).

Strongest counterexamples found anywhere in local evidence are **in-set** but
semantics-refining: boundary measured `bpy.ops.object.select_all` returning
CANCELLED and `wm.redraw_timer` raising at poll both firing dup+1 — the
`bpy.ops` event is the *call*, not the mutation; and `scene.frame_current=`
is silent at write+0 then lazily evaluated by the next tagged get with
`fc=0` at both points (my `frame_current_write` arm independently: inert at
w0, flush only at the explicit update; `fc` never fires). These refine the
claim's wording; they do not falsify it.

## 2. Independent replay of the landed fold (clean)

- `python3 corpus/fixtures/bpy_battery.py --runs corpus/live/r80-critic/runs/author-replay`
  → **64/64 PASS**, `signal_fail=0 quirk_drift=0 fatals=0`, `n_arm_lines=112`,
  probe 4.23 s; receipt `runs/author-replay/bpy-20261014T142429046822Z/`.
  Matches the author's receipt (`corpus/live/r80-author/runs/bpy-20261014T142321446240Z/`,
  64/64, 4.24 s) — non-author reproduction.
- **Byte-stability verified three ways**: r79 pre-fold baseline ARM-only sha
  `08101bed…` (78 lines, full stdout `69b512cb…`), the author's run, and my
  replay all hash the 78 r79 ARM lines **identically**; `PROBE_DONE` still the
  last marker. The fold appends `arm_evalcat` last in the runner tuple
  (`bpy_sync_probe.py:1033-1035`); only `import time` (`:41`) and the appended
  section changed outside it.
- **Falsifier liveness (re-run by me)**: `blender -b -P
  corpus/live/r80-author/falsify_check.py` → exit 0, 4229 ms,
  `violations 0→1→1→1→2`, two `edge=FALSIFIED` rows (bare flush+dup; bare
  handler-fire) while quiet-stale stays `edge=1` and `invoked=bpy.ops` flush
  stays `edge=0`. Receipt `runs/falsify_check.stdout.txt`. The closed-set
  check discriminates; it is not a constant.

## 3. FINDING (medium) — falsifier scope vs claim wording

`_ec_edge` (`bpy_sync_probe.py:581-593`) forces `FALSIFIED` only when
`invoked is None`. The `closed | violations=0` row therefore witnesses: the
**8 bare rows** (rna_write, driver, driver_expr, keyframe, key_explicit,
con_rna, conadd_target, walltime) never flushed and never fired a handler,
plus the event axis (get/update/frame_set/dg.update/clean-conditionality).
The ops rows are in-set **by construction** (invoked=`bpy.ops`) and can never
falsify. That is the correct operationalization — but "the eval-event set is
enumerable and closed" then means *bounded closure over the probed
catalogue*: "no probed non-op mutation class flushes outside the five; every
measured op call evals (dup≥1)". The author report is honest ("supported,
not falsified on this build", unknowns listed); the risk is scorecard-level
promotion to an unqualified "closed". Concrete instance already in the tree:
commit `faae4e0`'s subject says "closure falsifier armed (violations=0 on
45+ probed classes)" — the in-fixture falsifier covers the 8 bare rows; the
45-class screen is boundary-scratch evidence, not the tracked `closed` row.
Keep the two scopes distinct in the scorecard narrative. Judge-level:
ADMIT-as-bounded is available; universal closure must be rejected
(premature saturation).

## 4. FINDING (medium) — pinned bare catalogue ≪ measured evidence

Tracked bare rows: 8 classes. Already-measured-inert and *not* folded:
boundary's 45-class screen (frame_current lazy-eval with fc=0, `update_tag`
non-event, ID removals, data swap, mesh vertex writes/`Mesh.update()`,
parent, links, `matrix_world`, engine switch, action assign,
`instance_empty`, `libraries.write`, `scenes.new`, select/active/hide,
msgbus publish); scout §4 (8 non-op classes incl. modifier remove, first
link, collection-child link, `objects.remove`); my sweep (above, incl.
`libraries.load`, `vl.depsgraph` property, custom setters). Smallest safe
correction: fold a representative subset — at minimum `frame_current` (closes
the RNA-frame alternative with a tracked row), `update_tag` (tag ≠ eval),
one destructive class, one data-layer class, one relations class, one
custom-setter class — each already has a discriminating witness in the
cited receipts and costs <0.2 s. This grows the pinned bare set from 8 to
~14-16 and moves the claim from "8 classes" to the measured surface.

## 5. Independent checks (clean)

- **No shared-emitter/row collision**: evalcat rows use the new arm name
  `evalcat` and unique points; the battery parser keys on
  `(arm,point,layer)` (`bpy_battery.py:211-220`) and is last-wins on
  duplicates — I demonstrated the hazard in a demo
  (`runs/parser_hazard_demo.txt`: a duplicate key silently rewrites the
  pinned row; `>=1` pins are inexpressible; space-containing values break
  parsing). The landed fold avoids all three: unique names, space-free
  values, derived booleans `dup_fired`/`fc_fired` for the ×1/×2 op counts.
- **Pin semantics**: ops pinned as `dup_fired=True` (≥1), never exact —
  matches frontier and my in-process ×1/×2 reps. `held=na` rows
  (`op_mode_object`, `op_conadd`) are structurally non-discriminating (the
  witness value is fixed pre/post), so `na` is deterministic given the op
  evals — not a witness-artifact hazard. Mechanism pins `upd_dup=1`
  (keyframe_wU) and `dpost=0` (frame_set rows) are stable across
  frontier/boundary/my sweeps; low cross-build risk, load-bearing for the
  two-path split.
- **Dead surfaces not pinned**: msgbus/undo_post excluded from pins per
  frontier; `dund` emitted as diagnostic only.
- **Identity/provenance**: r79 arms and 37 CASES untouched; battery CASES
  appended only (`:81-192`), so the 37 verdict rows keep print order;
  `run_battery.py`/Godot side untouched; evalcat section cites the frontier
  report and probes. Scout's scratch fold (`bpy_sync_probe_r80.py` /
  `bpy_battery_r80.py`, 67/67, different row schema) is **superseded** — the
  tracked fixture is the single authority; do not mix pins across schemas.
- **Battery verdict path**: `signal_failed`/`quirk_drift` split (r79
  correction) preserved; evalcat rows are signal rows; a `FALSIFIED` row
  fails both its own `edge` pin and `evalcat_closed_set`.

## 6. Nits (no action required)

- Module docstring is still r79-only (`bpy_sync_probe.py:1-38`); one line
  pointing at the r80 section would help readers (battery docstring was
  updated).
- `d["und"]` in the `_ec_edge` violation predicate (`:584-586`) is
  semantically off (undo_post firing is not an eval event) but unreachable
  headless — keep the field, drop the term.
- Walltime arm adds ~3.5 s (probe 4.23 s vs r79 0.6 s); frontier closed the
  axis and its dispatch hint advised against the sleep arm. Keep-or-drop is a
  tradeoff, not a defect; `TIMEOUT_S=60` unaffected.

## Impacted axes

- **depth**: bounded closure + the new op-call class (op call evals ≥1, even
  cancelled/poll-failed); keyframe `edge=frame` and driver/constraint
  `edge=1` now pinned. Falsifier armed in-fixture on bare rows. Bounded — do
  not promote to universal "closed".
- **coverage**: 37→64 CASES; evalcat EDGE/DEG rows; catalogue probed surface
  = 8 bare + 6 op classes tracked, ≥60 unique classes across four sweeps.
- **calibration**: no thresholds changed; derived-boolean pins avoid
  exact-count fragility; low-risk mechanism pins noted; no verdict-gate
  changes.

## Smallest safe corrections

1. Report/scorecard wording: "bounded closure over the probed catalogue
   (falsifier armed on the 8 bare rows; ops in-set by call)" — never
   unqualified "closed".
2. Fold ~6 representative measured-inert bare rows (frame_current,
   update_tag, one removal, one data-layer, one relations, one custom-setter)
   with the already-measured witnesses.
3. Nit sweep: docstring pointer; drop `dund` from the predicate.
4. Keep the tracked fixture as the single authority; scout's scratch schema
   is superseded.

Counterexample, evidence, impacted axes, and smallest safe correction
returned. Report only; I do not judge, admit, edit, integrate, or ship.
Stopping here.
