# game-dev-3d round 80 — author (seat: author, host: devin)

## Declared move (verbatim)

Fold the frontier eval-event catalogue into `bpy_sync_probe.py` arms
(evalcat arm emitting per-op edge rows) + bpy_battery pins per measured
edge. Claim to test: **the eval-event set {evaluated_depsgraph_get,
view_layer.update, frame_set, dg.update, bpy.ops} is enumerable and
closed** — falsified if any probed mutation class flushes held handles
without one of the five firing. Byte-stability of r79's 37 cases required.

## Landed changes

- `corpus/fixtures/bpy_sync_probe.py` (e9609814…): existing 9 arms
  untouched. Added `import time` + one new arm `arm_evalcat()` appended
  last in the runner tuple — 10 sub-probes (each with its own
  factory-reset + handler reinstall, frontier convention) emitting
  `ARM evalcat | <point> | EDGE | held=… invoked=… dpre/dpost/dfcp/dfc/dund
  dup_fired fc_fired edge=…` rows plus DEG witness rows. **The falsifier
  is mechanical, not a pin**: `_ec_edge()` forces `edge=FALSIFIED` and
  increments a violations counter whenever a bare (`invoked=none`) row
  shows a moved held read OR any watched-handler delta — i.e. an eval
  event outside the enumerated set. Closing row `closed | EDGE |
  violations=N` is the claim's single-bit refutation surface.
- `corpus/fixtures/bpy_battery.py` (ae3b04b1…): +27 CASES rows appended
  after the r79 block — all 23 EDGE rows + discriminating DEG rows.
  Op eval counts pinned as `dup_fired=True` (≥1), never exact — frontier
  measured ×1/×2 variance, mechanism unmeasured. msgbus/undo_post not
  pinned (dead surfaces headless per frontier; `dund` still emitted).
- `run_battery.py` / Godot side: untouched.

## Measured result (battery `bpy-20261014T142321446240Z`: 64/64 PASS)

Claim **supported, not falsified** on this build (Blender 5.2.1 LTS,
`-b -P`, same as r79/frontier): `evalcat | closed | EDGE | violations=0`.
Every probed mutation class is explained by the enumerated set:

| class | measured | edge |
|---|---|---|
| bare RNA write | held stale, all deltas 0 | 1 |
| driver_add + `expression=`; expr edit | stale → one tagged eval binds 7.0/9.0 + RNA copyback | 1 |
| `keyframe_insert` | stale; inert through a confirmed tagged update (`upd_dup=1`, fresh `(0,0,0)`); binds at `frame_set` (`f1=(0,4,0)`, `rna_y=4.000`) | frame |
| explicit layered action build | stale → tagged get binds z=8 (`build=layered`) — the tag-vs-rebuild differentiator | 1 |
| `constraints.new`+`target=` (RNA) | stale → fresh `(3,0,0)` | 1 |
| `transform_apply` | held `verts3:xmax6.000` at write+0, dup×2 | 0 |
| `primitive_cube_add` | held `object_instances` gains `Cube`, dup×1 | 0 |
| `modifier_apply` | held `verts49:xmax1.000`, dup×2 | 0 |
| `mode_set` EDIT / OBJECT | held `(5,0,0)`; ×2 / na+×1 (asymmetric, per frontier) | 0 |
| `location_clear` | held `(0,0,0)`, dup×1 | 0 |
| `constraint_add` | inert constraint → held=na, dup×2 is the eval witness | 0 |
| `con.target=` after op | still stale → fresh binds: op auto-eval does NOT leave graph live | 1 |

Event axis re-pinned: dirty `get`/`vl.update`/`dg.update` flush held and
fire `depsgraph_update_pre/post` only; `frame_set(+1)` AND `frame_set(same)`
flush held firing `frame_change_pre/post` with `dpost=0` — the two eval
paths stay distinguishable only by handler family (dup is not a universal
eval witness). Clean `get`/`update` fire nothing (`edge=cond`). Wall-time
`0.5/2.0/1.0s` + context re-touch: never a flush, never a fire
(`edge=absent`) — no eval event exists on the time axis.

## Evidence

- `python3 corpus/fixtures/bpy_battery.py --runs
  /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r80-author/runs`
  → `cases=64 pass=64 fail=0 (signal_fail=0 quirk_drift=0)
  launch_ok=True done_marker=True fatals=0 exit=0`; receipt
  `corpus/live/r80-author/runs/bpy-20261014T142321446240Z/verdicts.json`
  + `probe.stdout.txt` (112 ARM lines parsed).
- Byte-stability control: pre-edit baseline run
  `corpus/live/r80-author/runs/bpy-20261014T142209559394Z/` (37/37).
  `diff <(grep '^ARM' baseline/probe.stdout.txt) <(grep '^ARM' post |
  grep -v '^ARM evalcat')` → **identical**; trailer `PROBE_DONE` +
  Blender banner identical; stderr byte-empty; probe exit 0.
- Falsifier liveness proof: `corpus/live/r80-author/falsify_check.py`
  under `blender -b -P` — synthetic bare windows emit
  `edge=FALSIFIED` and count violations (flush+dup→1; quiet stale stays
  `edge=1`; `invoked=bpy.ops` flush stays `edge=0`; held-unmoved but
  fc-fired→2). The check discriminates, it is not a constant.

## Remaining unknowns / risks

- `na` rows (`op_mode_object`, `op_conadd`) pin eval only via `dup_fired`
  — the held witness can't discriminate; an op that evals but corrupts
  would still pass (bounded by the other ops' discriminating rows).
- `edge=frame` for `keyframe_insert` rests on frontier's tag-vs-rebuild
  inference (medium confidence there); the row pins the *observable*
  (inert at tagged eval, bound at frame_set), mechanism open.
- Op eval multiplicity (×1/×2) intentionally unpinned — mechanism
  unmeasured; `dpre/dpost` raw counts stay in receipts for future drift.
- Edit-mode `bpy.ops.mesh.*`, `--python` interactive msgbus pump,
  `bpy.app.timers`, render-engine triggers: still unmeasured (out of move).
- Walltime arm adds ~3.5s to probe wall (~4.6s total, TIMEOUT_S=60).
