# frontier seat — bpy eval-event catalogue (seat: frontier-a scout, host: devin)

Wave-11 pre-measurement, extends r79 (bpy two-layer lattice). Question:
**which mutation classes flush the depsgraph?** Lane root
`~/Projects/shokunin/game-dev-3d-shokunin`; HEAD `59e1d32`. Runtime:
Blender 5.2.1 LTS headless (`blender -b -P`), same build as r79. Probes live
under ignored `corpus/live/frontier-bpyeval/` (`git check-ignore` confirms):
`bpy_evalcat_probe.py` sha256 `c99d8143ae9c2d58`, `bpy_evalcat_probe2.py`
`c5b16ba6ac822d19`, `bpy_evalcat_probe3.py` `014c314f5dba9fc4`.

## (0) Viability — positive

| command | exit | wall | evidence |
|---|---|---|---|
| `blender -b -P bpy_evalcat_probe.py` | 0 | 4066ms (3.5s = arm sleeps) | `runs/evalcat1.*`, 53 lines, `PROBE_DONE` |
| `blender -b -P bpy_evalcat_probe2.py` | 0 | 458ms | `runs/evalcat2.*`, `PROBE2_DONE` |
| `blender -b -P bpy_evalcat_probe3.py` | 0 | 417ms | `runs/evalcat3.*`, `PROBE3_DONE` |

stderr byte-empty on all three. Method: held `dg0` captured pre-mutation;
the graph is shared (`is_same`, re-verified `dgident dg0_is_dg1=True`), so a
held read shows last-eval state — held-fresh ⇒ the mutation itself ran an
eval. Every line also carries `h=pre/post/fc/msg/und`, a snapshot of
`depsgraph_update_pre/post`, `frame_change_pre/post`, `msgbus`, `undo_post`
handler counts — so handler fires are co-witnessed at every sample.

## (1) Per-mutation eval-edge table (the deliverable)

| mutation class | held handle at write+0 | depsgraph_update_post fired | edge |
|---|---|---|---|
| RNA write (`location`, `hide_viewport`, driver `expression` edit) | **stale** | no | 1 eval event, any kind |
| `driver_add` + `drv.expression=` | **stale** `(0,0,0)` vs fresh `(7,0,0)` | no | 1 tagged eval suffices (get/update both pull it) |
| `keyframe_insert` / explicit fcurve `keyframe_points.insert` | **stale** AND stays stale through tagged evals | no | **frame-path only** — see (b) |
| `constraints.new` + `.target=` (RNA) | **stale** `(0,0,0)` vs fresh `(3,0,0)` | no | 1 eval event, any kind |
| `bpy.ops.object.transform_apply` | **flushed** (held `verts3 xmax1→xmax6`) | **yes, ×2** | auto-evals — edge 0 |
| `bpy.ops.mesh.primitive_cube_add` | **flushed** (held `object_instances` gains `Cube`) | yes, ×1 | auto-evals |
| `bpy.ops.object.modifier_apply` | **flushed** (held `verts16→49`) | yes, ×2 | auto-evals |
| `bpy.ops.object.mode_set` EDIT / OBJECT | **flushed** (held `loc 0→5` at EDIT) | ×2 / ×1 | auto-evals (asymmetric count) |
| `bpy.ops.object.location_clear` | n/a (value undiscriminating) | yes, ×1 | auto-evals |
| `bpy.ops.object.constraint_add` | n/a (constraint inert w/o target) | yes, ×2 | auto-evals |

**Every `bpy.ops` mutation measured auto-evaluates** — `bpy.ops` itself is a
new eval-event class; held handles see post-op state at write+0. The
stale-regime from r79 only exists for RNA/data-API writes. Op evals happen
in-place on the same shared Depsgraph (`post-op dg0_is_dg1=True`); the
`depsgraph_update_post` arg IS that same object (`arg_dg_is_dg0=True`,
handler signature `(scene, depsgraph)`). Eval count per op varies ×1/×2 —
pin `≥1`, not exact.

## (2) Eval-event catalogue (r79 set extended)

| event | flushes held | depsgraph_update_pre/post | frame_change_pre/post | notes |
|---|---|---|---|---|
| `evaluated_depsgraph_get()` tagged | yes | yes | no | **conditional**: `get-clean` fired nothing — get does NOT eval a clean graph |
| `view_layer.update()` tagged | yes | yes | no | conditional: `upd-clean1/2` on clean graph fired nothing |
| `dg.update()` | yes (`held 4→5`) | yes | no | explicit serve |
| `scene.frame_set(+1)` | yes | **NO** | **yes (both)** | separate handler path |
| `scene.frame_set(same)` | **yes** (`held→4.0`) | no | yes | closes r79 unknown (c): same-frame still evals |
| any `bpy.ops` mutation above | yes | yes (×1–2) | no | new eval-event class |
| `time.sleep` 0.5/2.0/1.0 + `bpy.context` re-touch | **never** (`held=(0,0,0)` ×4) | no | no | draincheck closed on time axis |
| unrelated RNA reads | never (r79 draincheck) | no | no | re-verified |

**Two eval paths, distinguishable only by handler:** tagged path
(get/update/dg.update/bpy.ops) fires `depsgraph_update_*`; frame path
(`frame_set`, ±Δ or same) fires `frame_change_*` and silently bypasses
`depsgraph_update_post`. `depsgraph_update_post` is NOT a universal eval
witness — a wave-11 arm that watches only dup will call frame_set evals
"absent".

## (3) Cell answers

- **(a) bpy.ops** — all 6 measured ops auto-eval (table §1). `und` counter
  stayed 0 across every op AND an explicit `bpy.ops.ed.undo_push`
  (ret=FINISHED); `bpy.ops.ed.undo` poll-fails headless — `undo_post` is a
  dead surface under `-b -P`.
- **(b) driver writes** — `driver_add`/`expression=`: plain write-through,
  edge = 1 tagged eval (`fresh loc=(7,0,0)` at w0-get). **Fcurve keyframes
  are different**: `keyframe_insert` (ret=True, auto-bound slot `OBo`,
  action `oAction`) leaves **no graph-visible tag** — tagged evals
  (`get`/`view_layer.update()`, even with a guaranteed pending RNA tag)
  evaluated but the fcurve stayed inert (`wU-fresh=(0,0,0)`,
  `fresh-tagged=(0,0,0)`); the action bound only at `frame_set`
  (`f2/f1→(0,4,0)`, `rna_y=4.0` copyback). An *explicit* layered build
  (`action.slots/layers/strips/channelbags` + `ad.action_slot=` RNA assign)
  DID apply on the next tagged get (`explicit-fresh z=8.0`) — the
  differentiator is whether the write raises a relations-rebuild tag
  (inference; `keyframe_insert`'s internal auto-bind doesn't).
- **(c) constraint-add** — RNA `constraints.new`+`target`: edge = 1 eval
  event (`held (0,0,0)` → `fresh (3,0,0)`). Ops `constraint_add`: auto-evals
  like all ops, but the eval is unobservable while the constraint is inert.
- **(d) handlers** — `depsgraph_update_pre/post`: fire only on tagged-path
  evals (dirty get, dirty update, dg.update, every bpy.ops). `frame_change_*`
  (pre AND post): only `frame_set`, including same-frame. **msgbus: API is
  renamed in 5.x** — surface is `subscribe_rna`/`publish_rna`/
  `clear_by_owner` (`subscribe_rkey`/`publish_rkey` gone); subscription
  accepted (`key=(Object,"location")` tuple form) but **callbacks never
  fired headless** — not on RNA writes, not at eval, not on manual
  `publish_rna` (res=ok, count stayed 0): no notifier pump under `-b -P`.
  `undo_post`: never. Usable witnesses headless: dup counters only.
- **(e) wall-time** — `time.sleep` 0.5/2.0/1.0s plus context re-touch:
  held never flushed (`walltime sleep0/1/2`, `post-sleep-touch` all
  `(0,0,0)`, zero handler fires). **The r79 draincheck cell is closed on the
  time axis: no wall-time drain exists in `-b -P`** — staleness ends only at
  an eval event.

## (4) Other measured facts

- Driven-channel copyback: after eval, original-ID RNA shows driver/anim
  results (`rna_x=7.0` post-eval; `rna_y=4.0` post-frame_set) — derived-RNA
  lag applies to driven channels too.
- `Action.fcurves` legacy accessor removed in 5.2.1 (AttributeError);
  `keyframe_insert` still works and auto-assigns `action_slot`.
- `bpy.ops` context: `activate()` (active+select via RNA) +
  `temp_override(object/active_object/selected_objects)` sufficed headless;
  all op calls returned FINISHED except `ed.undo` (poll, no undo stack).

## Confidence and remaining unknowns

- High: bpy.ops auto-eval (6/6 ops), per-path handler split, conditional
  get/update, frame_set(same) eval, wall-time non-drain, msgbus/undo_post
  headless silence, keyframe-binds-at-frame_set (3-run cross-checked).
- Medium: mechanism of the ×2 op evals (undo-related vs internal redo —
  unmeasured); mechanism of keyframe relations binding (tag-vs-rebuild
  inference); `keyframe_insert` no-tag claim rests on no-handler-fire +
  inert eval — alternative "tagged but anim-node-skipped" not ruled out.
- Unknowns: edit-mode `bpy.ops.mesh.*` eval counts; whether op evals rebuild
  relations (constraint-with-preset-target untestable as stated); whether
  msgbus fires under `blender -b --python` interactive loop or
  `bpy.app.timers`; render-engine eval triggers (out of scope).

Dispatch hint for wave-11: the fixture can pin per-op `dup≥1` + held-fresh
witnesses in one `-b -P` run (~0.5s without the sleep arm); do NOT pin
msgbus/undo_post rows — both are dead surfaces headless.
