# r75 lesson — NavigationServer3D map/link mutation under a committed path (the two-stage gate + the latched zombie)

- Measured on Godot `4.7.2.stable.arch_linux.ed1daf0bf`, custom detour
  fixture, headless. Work commit `6498973`; wording hygiene `cefc821`.
- Fixture: `corpus/fixtures/navagent3d_detour.gd` — 11 `mut_*` arms, each a
  `steps` program of teleport/set_target/mutate/wait phases; mutation arms
  require `wait >= 1` before forcing reads (sync-blind readback gate).

## The two-stage invalidation gate

Server-side (RID-level) mutations — link `enabled`/`layers`, region
`layers`/`enabled`/`transform`, region delete/recreate — are gated TWICE:

1. **setter → server sync**: the write reaches the navigation server only
   after a physics flush (~2–3 frames on this build). A *same-turn*
   forcing call in this window still serves the pre-mutation (possibly
   dead-link) path — the bounded zombie window. NOT a universal
   impossibility: "no dead hop served" holds only *after* server sync.
2. **server sync → first forcing call**: after sync, the agent's stored
   state is marked dirty but the *stored array itself* stays byte-identical
   until the next forcing getter (`get_next_path_position`,
   `is_navigation_finished`, `is_target_reachable`, `get_final_position`)
   re-queries, re-anchored at the live agent position. Pure readers
   (`get_current_navigation_path`, `_index`, `is_target_reached`) keep
   serving stale stored data indefinitely.

- Agent-side `navigation_layers` write is the **synchronous exception**:
  clears the stored path same-turn (`peek=[]` at 0 frames) while the pop
  index stays readable-stale.
- Dirty marking is map-wide per-agent, not per-edge (critic): any server
  mutation dirties the agent's stored path.

## The latched zombie

Once `is_navigation_finished` latches, the update loop early-returns
BEFORE the dirty check — invalidation is gated off with it:

- A finished agent keeps **serving** the pre-mutation path through
  `region_transform +5x` AND full `region_delete` — `next`, `reachable`,
  `finished` unchanged on a map that no longer contains the region.
  (`mut_latch_zombie`.) Map mutations can accumulate invisibly under the
  latch.
- Any `target_position` assignment unlatches, clears, and lazily
  rematerializes against the CURRENT map state — including a same-value
  write (r74: no dedup).

## Re-mutation + empty-path contract

- Re-enable/re-layer/recreate all re-query and rematerialize on the next
  forcing call — no retargeting needed.
- Empty-path tuple pinned: `idx=0`, `next`=agent position (not origin),
  `final=(0,0,0)`, `path=[]`, `reachable=false`, `dist`=live euclid to raw
  target, `reached=finished=false`.

## Known gaps (next frontiers)

- Explicit same-turn mutation arms as tracked CASES (the zombie window is
  report-pinned, not case-pinned); sync latency (2–3 frames) pinned as
  cases; map-wide dirty scope; same-value mutation suppression;
  `map_set_active(false)`; node-link mutation; multi-agent scope;
  link-cost discrimination on geometry with alternate routes.
- `_check_tuple` extraction demonstrated byte-identical in scratch
  (simplifier) — warranted cleanup, not yet integrated.
