# game-dev-3d round 79 — scout (seat: scout, host: devin)

Axis under test: **first-contact Blender 5.2.1 LTS headless bpy**, declared
claim: *direct RNA writes are synchronously visible to same-script reads, BUT
depsgraph-evaluated reads lag by one evaluation — a two-layer timing model
analogous to Godot's getter-vs-NavigationServer3D-serve split* (r76–r78 edges
{link:2, region:3, map_off:perm}). Lane root `~/Projects/shokunin/game-dev-3d-shokunin`;
HEAD `87b456b` (r78 report-last). Probe files live under ignored
`corpus/live/r79-scout/` (`git check-ignore` confirms); working tree clean.
The brief's fixture name `corpus/fixtures/bpy_sync_probe.py` is the intended
landing spot — my write scope is scratch-only, so the tracked fixture is the
author's call; the probe is at `corpus/live/r79-scout/bpy_sync_probe.py`
(sha256 `6b9e8200d01692978f6b`) with helpers `bpy_probe2_membership.py`
(`5bd8dc354630f9`), `bpy_probe3_shared.py` (`b9ef1927873d6f`).

## (0) Viability — positive

| command | exit | evidence |
|---|---|---|
| `blender --version` | 0 | `Blender 5.2.1 LTS (hash 9e2066aef7ef built 2026-09-01)` |
| `blender -b --python-expr "import bpy;print(bpy.app.version_string)"` | 0 | `BPY_OK 5.2.1 LTS` |
| `blender -b -P bpy_sync_probe.py` | 0 | 462ms wall, stderr byte-empty, `PROBE_DONE` emitted |
| `blender -b -P bpy_probe2_membership.py` / `bpy_probe3_shared.py` | 0 | 372/370ms, stderr byte-empty |

Receipts `corpus/live/r79-scout/runs/probe{1,2,3}.{stdout,stderr,exit,elapsed_ms}.txt`.
`-b` is full background mode (no display, no GPU); rendering was not exercised
— only the Python/depsgraph surface this round needs.

## (1) Measured read-timing lattice — the claim is half-confirmed, half-narrowed

Sample points: `w0` = read in the same statement stream after the write;
`wU` = after `view_layer.update()`; `wF` = after `scene.frame_set(+1)`.
Held vs fresh = depsgraph handle obtained before vs after the write.

| read layer | w0 | wU | wF | receipt (probe:line) |
|---|---|---|---|---|
| RNA written prop: `location`, `hide_get()`, `modifiers`, collection membership/`users_collection` | **fresh** | fresh | fresh | p1 all arms w0 |
| RNA **derived** prop: `matrix_world` | **STALE** `(0,0,0)` after `location=(5,0,0)` | fresh `(5,0,0)` | fresh | p1 `transform` w0/wU/wF |
| DEG via **held** (pre-write) handle: `evaluated_get(dg0).location` | **STALE** `(0,0,0)` | fresh | fresh | p1 `w0-held`→`wU-held` |
| DEG via **fresh** `evaluated_depsgraph_get()` | **fresh** `(5,0,0)` — *the get itself evaluates* | — | — | p1 `w0-fresh`; real eval proven by modifier arm: `eval_verts=49` vs base 16 at w0-fresh (SUBSURF SIMPLE L1 ran) |
| DEG membership `dg.object_instances` after `collection.objects.unlink`/`link` | held: **stale** (`keep\|mover` kept the removed obj); fresh: **correct** (`keep`) | fresh both | — | p2 `membership` both directions |
| `dg.update()` explicit eval | exists on this build, flushes | — | — | p1 `transform wD` |

Two structural facts measured by probe3:

- **One shared graph, not snapshots.** `evaluated_depsgraph_get()` post-write
  returns the *same* Depsgraph object (`is_same=True`) and evaluates it in
  place: after one fresh get, the previously-held handle reads fresh too
  (`w0-held-b loc=(2,0,0)`). Staleness is a property of *time-since-last-
  evaluation-event*, never of the handle. A reader can only observe the stale
  layer by caching a handle pre-write and reading before the next eval event —
  every `evaluated_depsgraph_get()` is itself an eval event, so a reader who
  obtains a handle after writing **always sees fresh**. The "lag by one
  evaluation" exists, but the edge collapses to zero for the natural read path.
- **No implicit drain at all.** Reading `frame_current`, `len(D.objects)`,
  `matrix_world`, `visible_get()` between writes triggers nothing — held
  handle stayed stale across three unrelated reads (p2 `draincheck` w0-held2/3
  still `(0,0,0)`). In `blender -b -P` there is no idle pump between
  statements; the only eval events measured are `evaluated_depsgraph_get()`,
  `view_layer.update()`, `scene.frame_set()`, `dg.update()`.

**Non-signal discovered:** `evaluated_obj.visible_get()` returns `False` for
an object that is instantiated in the depsgraph and RNA-visible
(p3 `vis|relinked`: `rna_vis=True ev_vis=False in_inst=True`, also with
explicit `view_layer=` arg), and `evaluated.hide_get()` never reflected
`hide_set(True)` (p1 `hide` all points). Evaluated-object visibility/hide
flags are not staleness witnesses on this build — use `object_instances`
enumeration for the membership cell.

## (2) Verdict on the declared claim

- *"Direct RNA writes immediately visible"* — **confirmed** for written
  properties (location, hide flag, modifier stack, collection membership).
- *"Depsgraph reads lag by one evaluation"* — **mechanism confirmed, scope
  narrowed**: the lag is real but gated on *evaluation events*, and the
  canonical read (`evaluated_depsgraph_get()`) is itself the event. Staleness
  needs a pre-write cached handle; it then persists **indefinitely** (no tick
  drain) until any eval call — bpy's held-handle stale regime is structurally
  closer to Godot's `map_off` *permanent* regime than to the 2f/3f edges.
- *Two-layer model generalizes* — **yes, but the split is write-through vs
  evaluation-gated, not RNA-vs-depsgraph**: `matrix_world` proves the RNA
  layer itself carries an eval edge (derived RNA props lag like held-handle
  depsgraph reads). Three measured tiers: written RNA (edge 0) → derived RNA +
  held-handle DEG (edge = 1 eval event) → nothing per-tick (drain absent).

## (3) Recommended arm table — bpy ops → Godot-analog cells

| bpy op/read | Godot analog (r76–r78 fixture) | measured edge |
|---|---|---|
| RNA write → same-prop RNA read | `link_set_enabled` → object getter `srv_get` | 0 |
| RNA write → `matrix_world` | (no Godot twin measured; getter of derived state) | +1 eval event |
| held `dg` handle `evaluated_get` | `peek_*` non-forcing stored-array read | stale until next eval event |
| fresh `evaluated_depsgraph_get()` | `map_force_update` forcing read — the get IS the force | 0 |
| `view_layer.update()` / `dg.update()` | `map_force_update` | explicit serve |
| `scene.frame_set(+1)` | physics tick | only periodic eval |
| inter-statement headless gap | Godot unconditional per-tick drain | **absent** |
| held-handle stale regime duration | `map_off` permanent-stale | unbounded until explicit eval |
| `collection link/unlink` → `dg.object_instances` | link/region serve edge | held-stale/fresh-0 |
| `modifiers.new` → `evaluated.to_mesh()` vert count | mutation serve edge | held-stale/fresh-0 |
| `hide_set` → `evaluated.visible_get()`/`hide_get()` | n/a — non-signal on this build | quirk, do not pin |

A tracked fixture (author's `corpus/fixtures/bpy_sync_probe.py`) can cover the
whole lattice in one `blender -b -P` run — ~0.5s wall, no timeout exposure vs
the 20s case budget; the fixture's own CASES rows would be exact-stdout marker
lines in the `ARM x | point | layer | k=v` shape used here.

## Confidence and remaining unknowns

- High: viability (4 runs, all exit 0, stderr-empty), written-RNA synchronicity,
  held-vs-fresh handle split, shared-graph `is_same=True`, absent inter-statement
  drain, `matrix_world` derived-RNA edge, membership propagation via
  `object_instances`.
- Medium-high: that `evaluated_depsgraph_get()` *evaluates* rather than
  returns-a-copy — inferred from `eval_verts=49` (subsurf ran) + held handle
  flushing after a fresh get + membership updating; not yet tested against a
  mutation that is expensive enough to time.
- Unknowns: (a) `evaluated.visible_get()` provenance — likely reads base-object
  flags rather than graph state, mechanism unpinned (worth a boundary lane only
  if a future arm wants eval-visibility as witness; `object_instances` already
  covers membership); (b) eval events under `bpy.ops` mutation paths and
  driver/constraint writes (only direct RNA writes + modifier add measured);
  (c) whether `frame_set` to the SAME frame or animation-only depsgraph paths
  differ — untested; (d) render/headless-Eevee eval triggers — out of scope.
