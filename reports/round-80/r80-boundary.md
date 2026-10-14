# game-dev-3d round 80 — boundary (seat: boundary, host: devin)

Claim under test (r80 lane move, frontier `fa-bpy-evalcat.md`): **"the
eval-event set is enumerable and closed"** — every flush of a held depsgraph
handle is attributable to one of `{evaluated_depsgraph_get,
view_layer.update, frame_set, dg.update, bpy.ops}`; falsified by any probed
mutation class that flushes held handles without one of those firing.

Lane root `~/Projects/shokunin/game-dev-3d-shokunin`; HEAD `3f9e0703ef26`
(wave-10 report-last), working tree clean, **pre-fold** state: tracked
fixtures `corpus/fixtures/bpy_sync_probe.py` sha256 `740ccdf64c19…`,
`corpus/fixtures/bpy_battery.py` sha256 `e107b25152fc…`. Probe at
`corpus/live/r80-boundary/bpy_boundary_probe.py` sha256 `d001f3554abf…`
(ignored dir, `git check-ignore` confirms `corpus/live/`), analyzer
`analyze.py` sha256 `6a26efe2cb0b…`. Folding into the tracked fixtures is
outside my write scope (author's seat) — this seat supplies the adversarial
closure test + the pre-fold byte-stability baseline.

## (0) Viability — positive

| command | exit | wall | evidence |
|---|---|---|---|
| `blender -b -P bpy_boundary_probe.py` (×2) | 0 / 0 | 1550ms / 1516ms | `runs/boundary3a.*`, `runs/boundary3b.*`, 115 ARM lines, 0 FATAL, stderr 0 bytes, `PROBE_DONE` |
| `python3 analyze.py runs/boundary3a.stdout.txt` | 0 | — | `runs/analyze3a.txt`: arms=57 invalid=0 fatals=0 |
| `python3 corpus/fixtures/bpy_battery.py --runs …/battery-a` | 0 | — | 37/37 PASS, `launch_ok=True done_marker=True fatals=0` |
| `python3 corpus/fixtures/bpy_battery.py --runs …/battery-b` | 0 | — | 37/37 PASS (byte-stability baseline, §4) |

Blender 5.2.1 LTS (hash `9e2066aef7ef`), same build as r79/frontier.
Receipts under `corpus/live/r80-boundary/runs/` (`manifest.sha256` pins all).

## (1) Method — graph-global witness + discrimination controls

Frontier method (held `dg0`, held-fresh ⇒ mutation ran an eval) re-used, but
made independent of the mutated subject: a **witness object `ctl`** receives a
pending RNA write `location=(5,0,0)` (held read must be `(0,0,0)`); the
candidate mutation is applied to a separate subject/scene/datablock; the held
`dg0` read of `ctl` at write+0 is `(5,0,0)` **iff any evaluation ran on the
shared graph** (r79 pinned one shared graph, evaluated in place; re-verified
here by the `ctl_get` control flushing the pending `ctl` write). This also
works for destructive candidates (`objects.remove`, data swap) where the
subject's own state is gone. Handler counters
(`depsgraph_update_pre/post`, `frame_change_pre/post`, `undo_post`) are
differenced before/after each mutation (`dh=` field) to attribute each flush.

Harness validity (probe lines `run_arm` L124-158; `ARMS` L332-395):
- **5/5 positive controls flush and attribute**: `get` dup+1, `view_layer.update`
  dup+1, `frame_set` fc pair+1 (no dup), `dg.update` dup+1,
  `primitive_cube_add` dup+2.
- **5/5 known-stale controls stay stale with `dh=none`**: `hide_viewport`,
  `modifiers.new`, `constraints.new`, `driver_add`, `collection.objects.unlink`
  (frontier/r79 RNA regime).
- **confound control `ctx_only`** (`temp_override` enter/exit, no op) is stale,
  `dh=none` ⇒ the op-call flushes below are attributable to the op call, not
  the context manager.
- every `post` row reports `fresh=(5.000,0.000,0.000)` — no arm lost its
  pending write, so each stale reading is a true discriminator.

## (2) Closure test — no falsifier in 45 candidate mutation classes

`runs/analyze3a.txt` falsifier screen: **hits=0** (no candidate flushed
without a tagged/frame attribution). 40/45 candidates stayed stale with
`dh=none`; the only 5 flushes are `bpy.ops` **calls** (in-set by class).

| candidate class (arm) | held at write+0 | dh | verdict |
|---|---|---|---|
| `scene.frame_current` write | stale | none | not an eval event (see §3) |
| `frame_start` / `frame_end` / `render.fps` / `resolution_x` writes | stale | none | RNA regime |
| `render.engine` switch (→CYCLES) / `view_settings.view_transform` (→Standard) | stale | none | RNA regime |
| collection hierarchy `children.link` / `children.unlink` | stale | none | RNA regime |
| `object.data` swap, `parent` set/clear, `matrix_world`/`matrix_basis` writes | stale | none | RNA regime |
| mesh data: vertex `co` write, `Mesh.update()`, `Mesh.transform()`, `calc_loop_triangles()` | stale | none | data layer, no eval |
| `materials.append`, `scene.camera=`, `scene.world=`, collection-instance on Empty | stale | none | RNA regime |
| **explicit tag APIs** `obj.update_tag()` + `scene.update_tag()` | stale | none | tagging ≠ eval event |
| **destructive data ops**: `objects.remove`, `batch_remove`, `meshes.remove`, `orphans_purge` (purged 1) | stale | none | ID removal does not evaluate |
| `animation_data_create` + `action=` assign | stale | none | RNA regime |
| `object.copy`, `select_set`, view-layer `active=`, `hide_set` | stale | none | RNA regime |
| `scenes.new`, handler-list append | stale | none | unrelated to current graph |
| `meshes.new_from_object` (plain / `depsgraph=dg0` / `evaluated_get(dg0)` / `preserve_all_data_layers`) | stale | none | no eval |
| `data.libraries.write` (wrote `/tmp/r80boundary_lib.blend`, 140680 B) | stale | none | no eval |
| `msgbus.publish_rna` | stale | none | dead surface re-confirmed |
| **`bpy.ops` calls** (see §3): `select_all` CANCELLED (with/without override), `transform_apply` all-False FINISHED, `redraw_timer` poll-failed RuntimeError, `ed.undo_push` FINISHED | **flushed** | dup+1 each | in-set (op class), tagged path |

Note: mesh-object `instance_collection=` is refused by this build ("Only empty
objects support collection instances", Blender report line); the valid
Empty-object variant (`instance_empty`: `type=COLLECTION coll=True`) is stale.

**Claim verdict: not falsified.** Over 45 probed mutation classes the eval-event
set stayed closed: no flush occurred without a tagged-path or frame-path event
firing. The catalogue's five-event enumeration survived an adversarial probe
of RNA/scene/data/destruction/tagging surfaces.

## (3) Refinements measured (fold guidance for the author's evalcat arm)

1. **The `bpy.ops` event is the *call*, not the mutation.** Every op call
   measured flushes via the tagged path, including: `select_all` returning
   `CANCELLED` (with and without `temp_override`), `transform_apply` with all
   flags False returning `FINISHED`, and `wm.redraw_timer` **raising at poll**
   (`RuntimeError: poll() failed, context is incorrect`). `dh` = dup+1 for
   these; the mutating `primitive_cube_add` was dup+2. So the frontier wording
   "every `bpy.ops` mutation auto-evaluates" should be pinned as "every
   `bpy.ops` call measured auto-evaluates (≥1 tagged eval), regardless of
   mutation/cancel/poll-failure" — pin `dup≥1`, not an exact count.
2. **`scene.frame_current = n` (direct RNA write) is silent, then lazily
   evaluated on the tagged path** (`frame_lazy`, probe L161-180): no flush at
   write+0 and no `frame_change_*`; the next `evaluated_depsgraph_get()` flushes
   (`dh=dup+1`) and still fires **no** `frame_change_*`. `frame_change_pre/post`
   fire only on `frame_set` — a frame change made by RNA write is invisible to
   frame-change watchers. If the fixture pins this, pin: stale at write+0,
   `fc` delta 0, dup+1 at the next get, `fc` delta 0 there too. (Not a new
   eval-event class: the lazy eval is the tagged get.)
3. **Tagging ≠ evaluating**: `update_tag()` on object and scene leaves held
   handles stale and fires no handlers. This is the cleanest separation of the
   r79 "tagged vs evaluated" vocabulary — a mutation can tag without any eval.
4. **ID removal is not an eval event** under `-b -P`: `objects.remove`,
   `batch_remove`, `meshes.remove`, `orphans_purge` all stale/no-handlers.
5. Re-confirmed from frontier: `frame_set` fires the fc pair only (no dup);
   get/update/dg.update/ops fire dup only (no fc); `undo_post` stayed 0 in all
   57 arms including `undo_push`; `msgbus.publish_rna` fires nothing.

## (4) Byte-stability baseline for r79's 37 cases (pre-fold, required)

Tracked battery run twice against the unmodified pre-fold fixtures:

| run | command | verdicts | probe stdout sha256 |
|---|---|---|---|
| battery-a | `python3 corpus/fixtures/bpy_battery.py --runs corpus/live/r80-boundary/runs/battery-a` | 37/37 PASS, signal_fail=0, quirk_drift=0, exit 0 | `69b512cb3855…` |
| battery-b | same, `--runs …/battery-b` | 37/37 PASS, exit 0 | `69b512cb3855…` |

`cmp` on the two `probe.stdout.txt` files: **byte-identical** (sha pinned in
`runs/manifest.sha256`). The author's fold must preserve these 37 rows and this
probe-stdout byte-stability; the verifier replays post-landing.

Determinism of the boundary probe itself: boundary3a vs 3b differ only in
`bpy_struct` object addresses (`0x…` in `ret=` fields) and the wall-clock
prefix of one Blender report line — after masking addresses the diff is that
single timestamped line (`diff` receipt, §0). No behavioral nondeterminism.

## (5) Confidence and remaining unknowns

- **High**: closure over the 45 probed classes (0 falsifier hits, discriminating
  controls); op-call flush class incl. cancelled/poll-failed calls (n=5
  non-mutating/failing calls, all dup+1); `temp_override` non-event; direct
  `frame_current` write silent + lazy tagged eval with no fc handlers;
  `update_tag` non-event; destructive data ops non-events; r79 battery 37/37
  byte-stable pre-fold.
- **Medium**: generality of the op-call result to op classes not measured
  (render ops, file ops, undo/redo) — class-level inference from 6 ops;
  mechanism of dup ×1 vs ×2 per op (frontier medium, unmeasured here).
- **Unknowns**: (a) evaluated-frame *value* after the silent frame write —
  whether frame-dependent nodes see the new frame at that lazy tagged eval
  (no animation in this probe; inference: yes, unmeasured); (b) op
  argument-conversion errors raised before operator dispatch (my failures were
  post-dispatch: cancel/poll); (c) render-engine / interactive-loop / timers
  eval triggers (out of scope, frontier); (d) `keyframe_insert` tag-vs-rebuild
  mechanism (frontier medium, untouched).
