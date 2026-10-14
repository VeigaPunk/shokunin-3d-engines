# game-dev-3d round 79 — author (seat: author; **operator-substituted**, host: devin)

> Provenance: the r79 author seat died to the free-model rate-limit
> massacre (16:01 UTC reset). The operator authored this diff under
> disclosed substitution, directly promoting the r79-scout's measured
> probes (`corpus/live/r79-scout/`, sha256 `6b9e8200…`/`5bd8dc35…`/
> `b9ef1927…`) into tracked fixtures. Independent verification is left to
> the verifier/boundary seats post-reset — nothing here is self-certified.

## Declared move (verbatim)

First-contact Blender 5.2.1 LTS headless bpy (`blender -b -P`): claim —
direct RNA writes are synchronously visible to same-script reads, BUT
depsgraph-evaluated reads lag by one evaluation, forming a two-layer
timing model analogous to Godot's getter-vs-serve split (r76–r78 edges
{link:2, region:3, map_off:perm}).

## Landed changes

- `corpus/fixtures/bpy_sync_probe.py` (NEW, ~330 lines): nine arms —
  transform, hide, modifier, collink, membership, draincheck, shared,
  freshhandle, vis quirk — emitting exact-stdout `ARM <name> | <point> |
  <layer> | k=v` lines. Scout's probe1 verbatim + probe2 membership/
  draincheck arms + probe3 shared-handle arm folded in.
- `corpus/fixtures/bpy_battery.py` (NEW sibling runner): one
  `blender -b -P` invocation, ARM-line parser, 37 pinned cases,
  `verdicts.json` receipt under `corpus/live/runs/bpy-*` (ignored).
  `non_signal=True` marks the evaluated-visibility quirk rows as
  observations, not staleness witnesses.
- `run_battery.py` untouched → all 176 prior Godot rows byte-stable
  by construction (sibling, not an in-place arm).

## Measured result (battery `bpy-20261014T135140Z`: 37/37 PASS)

Verdict on the claim — **half-confirmed, half-narrowed** (scout-measured,
operator-reproduced on the tracked fixture):

- Written RNA props (location, hide flag, modifier stack, collection
  membership): **synchronous at write+0** — confirmed.
- The split is **write-through vs evaluation-gated**, NOT RNA-vs-depsgraph:
  derived RNA (`matrix_world`) lags at w0 exactly like a held depsgraph
  handle — the RNA layer itself carries an eval edge.
- `evaluated_depsgraph_get()` is itself an eval event: fresh gets always
  see fresh, and the graph is SHARED (`is_same=True`) — one get flushes
  previously-held handles (`shared|w0-held-b` reads fresh `(2,0,0)`).
- **No implicit drain at all**: `draincheck` held handle stays stale
  across unrelated RNA reads — unlike Godot's unconditional per-tick
  serve. Held-handle staleness is unbounded → bpy's stale regime maps to
  Godot's `map_off` *permanent* regime, not the 2f/3f edges.
- Membership propagates identically via `dg.object_instances`
  (held stale / fresh immediate, both directions).
- Non-signal pinned: evaluated `visible_get()`/`hide_get()` stay False on
  an instantiated, RNA-visible object — receipt-pinned as quirk rows.

Godot analogue table (from scout §3): `evaluated_depsgraph_get` ≡
`map_force_update` (the get IS the force); `view_layer.update()`/`dg.update()`
≡ explicit serve; `frame_set(+1)` ≡ physics tick (only periodic eval);
held-handle regime ≡ `map_off` permanence; the per-tick drain has **no
bpy analogue**.

## Evidence

- `python3 corpus/fixtures/bpy_battery.py` → 37/37 PASS, exit 0,
  `PROBE_DONE` present, 0 fatal arms, ~0.6s wall.
- Receipts: `corpus/live/runs/bpy-20261014T135140188222Z/verdicts.json`
  + `probe.stdout.txt` (78 ARM lines parsed).
- Scout receipts (independent, same lattice): `corpus/live/r79-scout/
  runs/probe{1,2,3}.{stdout,stderr,exit,elapsed_ms}.txt`.

## Remaining unknowns (handed to boundary/next-round seats)

- eval events under `bpy.ops` mutation paths and driver/constraint writes
  (only direct RNA writes + modifier add measured);
- `frame_set` to the SAME frame / animation-only depsgraph paths;
- evaluated `visible_get()` provenance (non-signal pinned, mechanism open);
- render/EEVEE eval triggers — out of scope.
