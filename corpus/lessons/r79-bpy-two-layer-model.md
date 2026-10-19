# r79 — bpy two-layer read model: write-through vs evaluation-gated

New runtime first-contact (Blender 5.2.1 LTS headless, `blender -b -P`).
The declared claim — "RNA synchronous, depsgraph lags by one evaluation" —
was **half-confirmed, half-narrowed** by the scout lattice (promoted to
`corpus/fixtures/bpy_sync_probe.py` + `corpus/fixtures/bpy_battery.py`, 37/37):

- The real split is **write-through vs evaluation-gated**, not
  RNA-vs-depsgraph: derived RNA props (`matrix_world`) lag at write+0
  exactly like held-handle depsgraph reads.
- `evaluated_depsgraph_get()` is itself an **evaluation event**: fresh
  gets always see fresh; the graph is SHARED (`is_same=True`) so one get
  flushes previously-held handles too.
- **No implicit drain exists** in `blender -b -P`: unrelated RNA reads do
  not flush a held handle (`draincheck` 3× stale). Godot's unconditional
  per-tick serve has no bpy analogue.
- Held-handle staleness is **unbounded** — structurally the bpy analogue
  of `map_off` permanence, not of the 2f/3f link/region edges.
- Membership via `dg.object_instances` propagates identically (held
  stale / fresh immediate).
- `evaluated.visible_get()`/`hide_get()` are a **non-signal** on this
  build (False on instantiated RNA-visible objects) — pinned as quirk
  rows, never a staleness witness.

## Reusable rules (next bpy rounds)

1. Sample points `w0/wU/wF` map to Godot rungs: fresh `depsgraph_get` ≡
   `map_force_update`; `view_layer.update()`/`dg.update()` ≡ explicit
   serve; `frame_set(+1)` ≡ physics tick.
2. To observe staleness a reader MUST hold a handle captured pre-write —
   every post-write get auto-evaluates.
3. Use `dg.object_instances` (not `visible_get`) for membership/visibility
   edges; use a vertex-count diff (SUBSURF SIMPLE L1: 16→49) as the
   proof an eval ran.
4. `blender -b -P` ~0.4–0.6s wall, stderr byte-empty — cheap enough for
   full-arm pinned batteries.
