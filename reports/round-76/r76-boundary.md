# Game-dev-3d round 76 — boundary (revenger): the setter→server-sync WINDOW, resampled

Seat: boundary (role revenger). Scope: scratch-only under
`corpus/live/r76-boundary/`; no tracked edits, no commits, leaf — no
dispatch. The lane's declared axis-move (pin the same-turn
setter→server-sync window as tracked CASES — mutate + forcing read at
wait=0/1/2, `map_set_active(false)` reachability, same-value-mutation
suppression) is owned by the author seat. **At probe time the tracked
fixture carries no r76 code**: canonical repo HEAD is `cb6bf7b` (r75
report-last), `git status` was clean on `corpus/fixtures/` at that point,
`navagent3d_detour.gd` last committed `6498973` (r75). My assigned recon
— the five probe edges from the brief — runs on my own scratch geometry
independent of the tracked arms landing. The author's diff landed after
the probe corpus completed; the post-cutoff section below verifies it:

1. bisect the sync window under repeated samples — strict constant or
   distribution?
2. mutation DURING the window — two setters same tick: queue or
   coalesce?
3. `map_set_active(false)` then true — restore or force requery?
4. multi-agent dirty scope, reachable headlessly?
5. node-link mutation (`NavigationLink3D` property writes vs server
   RIDs)

## Deliverable and method

`corpus/live/r76-boundary/scratch/navagent3d_syncwin.gd` sha256
`ddf26f3e0c7e7c935783ede8d94fa33bb66e69c43e2262b141c1bad3eee41174` —
SceneTree probe. Geometry verbatim from the r70 L-corridor (A1
x[0,2]z[0,1], A2 x[2,3]z[0,1], B x[2,3]z[1,4]) plus r73 island C
x[2,3]z[5,6] (`--geo=bridge`), r73 bridge link
(2.5,0,3.5)->(2.5,0,5.5) authored `--link=server|node`; `--geo2` adds a
SECOND map+region with the same corridor offset +10x/+10z (agent B on
map2, coordinates stay distinct). `project.godot` byte-identical to the
tracked seed (sha256 `1fda90d4…8eac23`). Godot
`4.7.2.stable.arch_linux.ed1daf0bf` via `/usr/bin/godot --headless`,
60 tps, cell_size 0.25, 30-tick settle; the deferred query is
materialized once before `P0` is captured (pure reads are `[]` until the
first forcing call — r74 lazy materialization — so trial 0's baseline is
the real stored array, not materialization noise).

The core instrument is a per-frame transition sampler: after a mutation,
one forcing call (`get_next_path_position`) per physics frame for 6–8
frames, recording the served-path signature each frame. `f*` (printed
`fstar`) = the first frame index — **0 = the same GDScript turn** (the
step machinery's `wait=0`), **k = after k physics frames** (`wait=k`) —
whose forcing call serves a path differing from the pre-mutation stored
array. Resample arms alternate mutation direction k times in one process
(`--k`), so each run yields k samples across both directions; repeated
process invocations give the cross-process distribution. All runs exit
0; all stderr empty; repeated runs byte-identical.

Command shape per arm:

```
timeout 120 /usr/bin/godot --headless --path corpus/live/r76-boundary/scratch \
    --script res://navagent3d_syncwin.gd -- --arm=<name> \
    [--geo=bridge --geo2=1 --link=server|node --k=N --n=N --cls=<class>]
```

187 runs under `corpus/live/r76-boundary/runs/` (`<name>.stdout.txt`,
`.stderr.txt`, `.exit`): 91 arm runs via `run_arms.sh` (incl.
`um_enter_cost_witness` and the four `sw_getter_edge_*` arms) + 96
per-class bisect runs. Every exit 0. (Post-landing replays —
`author_*` ×7, `prior_*` ×9 — bring the directory to 203 runs, all
exit 0.)

Vocabulary carried from r75-boundary: forcing calls (run the deferred
update) `get_next_path_position`/`get_final_position`/
`is_navigation_finished`/`is_target_reachable`; pure reads
`get_current_navigation_path`/`_index`/`distance_to_target`/
`is_target_reached`. Requery witness for outcome-identical writes:
teleport to M=(1.5,0,0.5) after materializing at S — the stored path
stays frozen at `[S,…]` (re-pops only); `path[0]` re-anchors at M iff
the mutation dirtied the map.

## (1) The sync window is a STRICT constant — two latency classes, and "wait>=1" is falsified for every RID class

Distribution tally across all samples (in-process alternating resamples
+ cross-process single-shot bisects, every sample identical):

| mutation class | stale at | post-sync at | samples |
|---|---|---|---|
| link writes — `link_set_enabled`, `link_set_navigation_layers`, `link_set_end_position` (server RID **and** `NavigationLink3D` property) | wait 0, 1 | **wait ≥ 2** | 54/54 resample trials fstar=2 (27 off + 27 on); 24/24 cross-process (n=0,1 → unchanged ×8, n=2 → changed ×8); 9/9 class bisect |
| region writes — `region_set_enabled`, `region_set_navigation_layers`, `region_set_transform`, `region_set_navigation_mesh` | wait 0, 1, 2 | **wait ≥ 3** | 24/24 resample trials fstar=3 (12 moved + 12 home); 24/24 cross-process (n=2 → unchanged ×8, n=3,4 → changed); 12/12 class bisect |
| agent-side setter (`agent.navigation_layers`) | — | **wait 0 (synchronous)** | fstar=0 both directions; path `[]` same-turn |
| `map_set_active` | — | **never (no transition)** | fstar=-1 all trials, 30-frame bound (edge 3) |
| `link_set_enter_cost` | n/a | **lands, outcome-invisible** | path identical at every n — but the M-witness re-anchors (`um_enter_cost_witness`: `path[0]` S→(1.5,0.5) after the write), so the effective write **does** dirty/requery; the link just stays chosen (r73 inertness resolved: lands-but-inert, not swallowed) |

Receipts: `sw_link_resample_r{1,2,3}.stdout.txt` (byte-identical md5s —
`8a5824d7…`), `sw_region_resample_r{1,2,3}.stdout.txt`,
`sw_link_node_resample_r{1,2,3}.stdout.txt`, `sw_link_bisect_n{0,1,2}_*`,
`sw_region_bisect_n{2,3,4}_*`, `cls_*.stdout.txt`, `sw_agentlayers`.

**Against the declared claim**: "a forcing call on the same tick serves
the pre-mutation path" — **CONFIRMED** for every RID class (wait=0 stale
everywhere). "wait>=1 serves post-sync state" — **FALSIFIED on every RID
class measured**: at wait=1 the served path is still pre-mutation (link
needs ≥2, region needs ≥3); no RID class lands at 1. The only sub-1
channel is the synchronous agent-side setter (0). "the exact frame count
is a stable measured constant" — **CONFIRMED strongly**: zero spread
across 78 in-process trials, both mutation directions, three independent
process batches, and 72 cross-process bisects; the constant is
class-dependent {link:2, region:3}, not a single number.

## (2) Mutation during the window — each write lands at write+class-latency; same-turn multi-class adds +1 to the slower write

- `mw_sameturn_link_region` / `mw_sameturn_region_link`
  (`runs/mw_sameturn_*.stdout.txt`): link-off + region +0.3x **one
  turn**, either order → identical sequence: f2 serves
  dead-link/**old-region** `[(0.5,0.5)(2.0,1.0)(2.5,4.0)]` for two
  frames, region lands at **f4** `[(0.5,0.5)(2.3,1.0)(2.5,4.0)]`. Two
  writes on different objects do NOT land in one wave: the link keeps
  its own 2-frame latency, the region write is pushed +1 beyond its
  solo 3 (to 4) when a same-turn link write shares the flush —
  order-insensitive. `mw_sameturn_big` (region +5x instead of +0.3x)
  lands region at f4 identically — move-size independent.
- `mw_region_only_small` (`runs/mw_region_only_small.stdout.txt`):
  solo +0.3x transform lands at f3 — the +1 in the same-turn pair is
  coupling, not move-size.
- `mw_overlap` (link at t0, region at t1): link lands t0+2, region
  lands **t1+3 — its own latency** (`runs/mw_overlap.stdout.txt`).
- `mw_overlap_rev` (region at t0, link at t1): region lands t0+3, link
  lands t1+2 — each keeps its own latency; they coincide at seq f2
  (`runs/mw_overlap_rev.stdout.txt`). The +1 push only appears when the
  slower (region) write is issued in the SAME turn as a pending link
  write; a region rebuild already in flight keeps schedule.
  Mechanism (marked inference): the region rebuild appears to queue
  behind the link edit inside a shared command flush.
- `mw_toggle_stagger` (`runs/mw_toggle_stagger.stdout.txt`): disable at
  t0, RE-enable at t1 (inside the disable's window) — the dead-link
  state IS served for exactly 2 frames (f1,f2 dead `…(2.5,4.0)`, f3
  alive again). No collapse, no coalescing across the stagger: each
  write lands at its own latency even when the net map state returns
  to the start.
- `mw_samekey_move_disable` / `mw_samekey_disable_move`: two keys on
  the SAME object in one turn (move-end + disable, either order) —
  single wave at f2, only the final state served (dead link); no
  intermediate moved-but-alive path. Same-turn same-object writes
  coalesce.

## (3) `map_set_active(false)` — query-inert: no dirty, no gate, no requery on re-activation

- `ma_off_serve` / `ma_off_resample` (k=6, `runs/ma_off_*.stdout.txt`):
  committed link path served **uninterrupted** through off (6 frames)
  and on — fstar=-1 every trial; `map_is_active` reads back `false`
  while the full path keeps serving; the agent stays bound
  (`agent.get_navigation_map()==map` throughout).
- `ma_off_on_sameturn`: off+on in ONE turn at the M-witness — stored
  path keeps `path[0]=S` (no re-anchor): the off/on pair does not even
  mark dirty, matching the same-value-suppression family.
- `ma_off_requery`: a deferred query materializing WHILE the map is
  inactive (same-value retarget clears `[]`, then force) returns the
  FULL live path `[S,(2,0,1),ls,le]` with `reachable=true` — "inactive"
  does not gate NavigationAgent3D path queries at all on this build.
- `ma_off_long`: 30 frames inactive, still serving; a retarget during
  off materializes `[(0.5,0.5)(2,0,1)(2.9,3.9)]` reachable=true.
- `ma_off_mutate_inside`: a link disable written while the map is
  inactive lands normally — dead-link clamp at f2 after re-activation.
- `ma_offn{0,1,2}`: force at any n after off → live corridor path,
  `reachable=true`.
- Answer to the brief's restore-vs-requery: **neither** — the committed
  path is never disturbed (no invalidation window exists for this
  setter), and queries resolve on the "inactive" map verbatim.
  `map_set_active` does not gate this query path; what it gates
  (avoidance sync? per-frame processing?) is outside this surface —
  marked inference.

## (4) Multi-agent dirty scope — per-map dirty, per-agent flags, no consumption

- `xag_two_same` (`runs/xag_two_same{,_r2}.stdout.txt`): agents A and B
  on the SAME map transition at the SAME frame — both fstar=2,
  identical sequences. Map-wide dirty confirms r75, now with the window
  pinned per-agent.
- `xag_consume` (`runs/xag_consume.stdout.txt`): A forces every frame
  through the window (transitions f2); B's FIRST forcing call at f5
  serves the post-mutation CLAMP — A's updates did not consume or
  advance B's dirty state. Dirty flags are per-agent; invalidation is
  per-map.
- `xag_agent_setter` (`runs/xag_agent_setter.stdout.txt`):
  `B.navigation_layers=2` clears B's stored path to `[]` synchronously
  while A's array stays byte-identical — the synchronous channel is
  per-agent, not map-wide.
- `xag_two_maps` (`runs/xag_two_maps.stdout.txt`): B lives on map2
  (+10/+10 corridor). Mutating map1's link: A fstar=2, B **fstar=-1**
  (byte-identical all 7 frames). Control: map2's own region +5x → B
  fstar=3 (region latency again), A fstar=-1. Dirty scope is strictly
  per-map.

## (5) Node-link mutation — the node property channel IS the server channel

- `sw_link_node_resample` (k=8 ×3 processes): `link_node.enabled`
  toggles land at **fstar=2** strictly, both directions — identical to
  the server-RID channel.
- `nl_layers` (`link_node.navigation_layers=2`): fstar=2, drops to the
  same clamp.
- `nl_move_end` (`link_node.end_position=(2.5,0,5.8)`): fstar=2; the
  moved endpoint re-routes npath=5 `[S,(2,0,1),ls,(2.5,5.8),(2.5,5.5)]`
  — byte-same shape as r75's server `ld_link_move_end`.
- `nl_mixed_server`: `NavigationServer3D.link_set_enabled(node.get_rid(),false)`
  on a node-authored link — fstar=2. Channels converge on one server
  object.
- `nl_prop_same` (`link_node.enabled=true`, already true): the
  M-witness stays `path[0]=S` — no re-anchor → same-value NODE property
  writes are suppressed exactly like the server same-value family.

## Reconstructed contract (evidence chain)

1. The setter→server-sync window is a **strict per-class constant** on
   this host/build: link-family writes land at **write+2 physics
   frames**, region-family writes at **write+3**, agent-side setters at
   **0 (synchronous)**, `map_set_active` **never** (query-inert). No
   distribution observed anywhere: 78 in-process alternating trials,
   96 cross-process class bisects, byte-identical repeats — the bound
   is exact, symmetric across mutation direction, and holds per-agent.
   Within the window every forcing call (first included) serves the
   stored path; the transition happens between consecutive physics
   frames at the pinned index. The boundary is **two-staged**:
   object-level getters observe setter state at ~write+1
   (`sw_getter_edge_{link,region,map,iter}` — `link_get_enabled`,
   `region_get_transform`, `map_is_active` all flip at f1; a new link's
   `iteration_id` goes 0→1 at f1), while the agent's path query lands at
   the deeper 2/3 edge — server publication and agent requery are
   separate stages.
2. Writes queue **per-object per-class latency**: staggered writes land
   independently (a disable-then-enable inside the window still serves
   the dead state for exactly its 2 frames); same-turn writes on the
   same object coalesce to one wave; same-turn writes on different
   objects keep their own latencies with the slower (region) write
   pushed +1 when a link write shares its flush.
3. `map_set_active` is outside the dirty/query system entirely: it
   dirties nothing, gates nothing, restores nothing — because nothing
   is ever disturbed (inference: it does not feed the query path at
   all on this build). Mutations WRITTEN while the map is inactive are
   not lost: they queue and become observable at ~reactivation+2 frames
   (their latency counts from reactivation, not from the write turn —
   `ma_off_mutate_inside` lands the dead-link clamp at +2 after a
   same-turn off-write+on-write; the landed `mut_map_cycle` lands it at
   +2 after reactivation even though the write happened 5 frames
   earlier while off).
4. Dirty scope is per-map for objects, per-agent for flags and for
   agent-side setters: every agent on a mutated map transitions at the
   same frame; agents on other maps never move; one agent's forcing
   calls neither consume nor advance another's invalidation.
5. The node property channel (`NavigationLink3D.enabled`,
   `.navigation_layers`, `.end_position`) and the server RID channel
   are the same channel: same 2-frame window, same served results,
   same same-value suppression — and a server write on `node.get_rid()`
   lands identically.
6. `link_set_enter_cost` is an effective write that lands (re-anchors
   the M-witness) yet stays route-inert — the r73 anomaly resolved to
   "lands but outcome-invisible", not suppressed and not swallowed.

## Suggested battery surface (for the author / verifier)

- wait=0/1/2 pins: for a link write, `wait=0` and `wait=1` MUST serve
  the pre-mutation path and `wait>=2` the post-mutation path — the
  falsification edge is exactly at the 1|2 boundary. For a
  region-class write the edge is at 2|3. An arm pinning `wait=1 →
  post-sync` on a link or region write would be falsified on this
  build (96+ measured samples).
- `map_set_active(false)` arms should pin the QUERY-INERT result
  (committed path served, deferred materialization resolves,
  reachable stays true, off/on is a no-op round-trip), not an
  empty-map result — if the author arm expects `reachable=false` or
  `path=[]` under off, it falsifies.
- `sw_agentlayers` (fstar=0) is the control distinguishing the
  synchronous agent channel from every server channel.
- Per-class coverage if tracked arms want the full map: link_enabled/
  link_layers/link_move land at 2; region_enabled/region_layers/
  region_transform/region_mesh land at 3.

_Post-landing note: the landed arms adopted exactly this shape —
wait-cumulative reads pinning stale at +0/+1 (link) and +0/+1/+2
(region), the query-inert `reachable=true` map-off tuple, and the
M-witness for same-value suppression. Every suggestion above resolved
MATCH, not falsification; see the post-cutoff table._

## Divergences and honest caveats

- The +1 same-turn coupling on the slower (region) write and the
  two-class latency split are timing observations; the pipeline
  mechanism (per-wave command flush vs per-object rebuild scheduling)
  is inference — flagged.
- `map_set_active`'s purpose is outside this surface; I measured only
  that it does not gate or dirty the NavigationAgent3D path query.
  Other subsystems (avoidance, physics-driven navigation, region
  baking) may consume the flag — unprobed, marked inference.
- `link_enter`'s landing is witnessed by re-anchor (M-witness); its
  frame latency cannot be pinned by path signature because the served
  path is outcome-identical.
- One engine build (`4.7.2.stable.arch_linux.ed1daf0bf`), one host,
  60 Hz physics, 30-tick settle, teleport-motion only, single
  region/link per map (plus map2 for scope) — same bounds as r72–r75.
  Cross-tick-rate behavior unprobed.
- The author's tracked diff had NOT landed at probe time (HEAD
  `cb6bf7b`, clean fixtures); all five edges were measured on the
  committed r75 surface. The diff landed afterwards — verified in the
  next section.

## Post-cutoff: author landing verification

The tracked diff landed after this corpus completed (working-tree
modification, uncommitted — same shape as r75). Verified stable across
the whole verification window: `git diff corpus/fixtures/navagent3d_detour.gd
corpus/fixtures/run_battery.py | sha256sum` =
`b6d842009205234b5d96d26efc358e4625983b0aaa88322ea7a9cca37a3e5167`
both at first observation and at report close; file mtimes
2026-10-14 07:13, all replays and the battery ran after that.

### What landed

`git diff --stat corpus/fixtures/`: `navagent3d_detour.gd` +290,
`run_battery.py` +14, zero other files. CASES grow 156→163 — seven new
rows, `run_battery.py:198-211` (`mut_win_link`, `mut_win_region`,
`mut_map_off`, `mut_map_cycle`, `mut_same_link`, `mut_same_region`,
`mut_same_agent`), inserted after `mut_latch_zombie`; no prior row
edited. Arm bodies `navagent3d_detour.gd:1421/1460/1492/1527/1566/
1596/1621`. New machinery: `map_active` mutate key →
`NavigationServer3D.map_set_active` at `:1886`; `fs["map_active"]`
default `true` folded per step at `:1908` and `:339-340` of the diff;
live-setup gate changed from `not map_is_active(map)` to
`map_is_active(map) != fs["map_active"]` at `:353` — semantically
identical for every prior arm (default true ⇒ same predicate), which is
why prior rows are untouched. Header comment now pins the constants:
"the query edge is exactly 2 physics frames for link toggles and 3 for
region_set_transform" and "the fs mutation-honesty readback sees
object-level truth from ~1 frame".

### Replay: 7/7 byte-match on this host

Method identical to r75-boundary: verbatim copy
`corpus/live/r76-boundary/scratch/navagent3d_detour_wt.gd` (`diff -q`
clean against the landed fixture; sha256 `066a06d2…19e4`, byte-identical
to the seed digest the battery hashed for `navagent3d_detour.gd`
before/after its run), then per arm:

```
timeout 90 /usr/bin/godot --headless --path corpus/live/r76-boundary/scratch \
    --script res://navagent3d_detour_wt.gd -- --arm=<arm>
```

Receipts `corpus/live/r76-boundary/runs/author_<arm>.{stdout.txt,
stderr.txt,exit}`: **7/7 exit 0, empty stderr**, and every printed
`PASS` line **byte-matches** its pinned CASES string (python compare
over `run_battery.py` rows: 7/7 MATCH).

### Constant cross-check — author pins vs independent corpus

| author arm (wait=frames after mutate, cumulative) | pin | my independent measurement | verdict |
|---|---|---|---|
| `mut_win_link`: stale at +0,+1 (served AND popped: idxs `2,3,3,1`), requery at +2 | edge 2 | fstar=2 — 54/54 resamples + 24/24 cross-process + 9/9 class bisects | MATCH |
| `mut_win_region`: stale at +0,+1,+2, requery at +3 | edge 3 | fstar=3 — 24/24 resamples + 24/24 cross-process + 12/12 class bisects | MATCH |
| `mut_map_off`: committed tuple incl `reachable=true` through +15 frames inactive | query-inert | fstar=-1, 30-frame bound, no dirty (`ma_off_*`) | MATCH |
| `mut_map_cycle`: link disable written while inactive applies at +2 after reactivation | queued, post-reactivation landing | `ma_off_mutate_inside` dead clamp at +2 | MATCH |
| `mut_same_link`/`mut_same_region`: M-witness `path[0]` stays at S on same-value, re-anchors on effective | suppressed | `nl_prop_same`, `um_enter_cost_witness` — same witness design, built independently before the landing | MATCH |
| `mut_same_agent`: same-value dedups BEFORE the synchronous clear; effective write clears `[]` same-turn | dedup-then-clear | `sw_agentlayers` fstar=0, `xag_agent_setter` | MATCH |
| header: "object-level truth from ~1 frame" | getter stage | `sw_getter_edge_{link,region,map,iter}`: getter flips at f1 (`link_get_enabled` t→f, `map_is_active` t→f, `region_get_transform`, new-link `iteration_id` 0→1) while the path stays stale until f2/f3 | MATCH |

The declared claim's literal "wait>=1 serves post-sync state" is
falsified by the author's own arms as well (their +1 steps pin stale
serves) — the landed pins encode the corrected {2,3} constants, i.e.
the author measured the same boundary I did.

One coverage addition beyond my corpus: `mut_win_link`'s tp+mutate
wait:0 step pins the in-window forcing call **serving AND popping** the
stale array (idx advances 2→3 across the killed gate, `next` serves the
dead far endpoint). My sampler recorded path signature, not pop index;
the observed idx trajectory is consistent with my contract — the
deferred update still runs on the live position inside the window — and
refines rather than contradicts it.

No divergence between the landed arms and this report's table exists;
no arm asserted the falsified wait=1 edge.

### Regression and baseline receipts (post-landing state)

- Spot-replay on the landed fixture, 9/9 PASS exit 0
  (`runs/prior_{mut_link_kill,mut_lazy,mut_latch_zombie,
  mut_layers_agent,mut_region_move,mv_walk,mv_latch,pop_lo,
  link_meta}.stdout.txt`): the gate change is non-regressive.
- Full battery, canonical path:

  ```
  python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
      --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r76-boundary/battery \
      --probe-failing --probe-crash-exit --probe-stream-attribution \
      --probe-tree-timeout
  ```

  exit 0 — `totals: cases=163 pass=163 fail=0 ordinary=118
  negative_controls=45 probes=4`, `verdict: PASS`,
  `seeds_unchanged: true`; log `corpus/live/r76-boundary/
  battery_full.log`, receipts `corpus/live/r76-boundary/battery/
  20261014T101546265435Z/{verdicts.json,crash-exit-verdicts.json,
  stream-attribution-verdicts.json,tree-timeout-verdicts.json,
  mutation-verdicts.json}`. The single `FAIL mutant_body3d_contact`
  log line is the `--probe-failing` witness (deliberate scratch
  defect, `detected=True` → probe PASS). The battery-scratch seed
  digest of the landed `navagent3d_detour.gd` is
  `066a06d2…19e4`, unchanged before/after.
- Node three.js suites, frozen tree
  `corpus/live/r76-baseline/frozen/corpus/fixtures/three` (author diff
  touches no Node file; `diff -r` against tracked `corpus/fixtures/three`
  clean): all six runners exit 0 — `run_cases` 3/3, `run_layer_cases`
  4/4, `run_order_cases` 9/9, `run_camera_cases` 5/5,
  `run_ortho_cases` 5/5, `run_ray_cases` 5/5 = **31/31**, every tail
  `seeds_unchanged=true`; receipts `corpus/live/r76-boundary/receipts/
  run_*.json`.

## Confidence

High on all five edges: 187 scratch runs, exit 0 everywhere, empty
stderr throughout, byte-identical determinism on every repeat family,
and the window constants witnessed by three independent methods
(in-process resample, cross-process single-shot bisect, per-class
bisect). Post-cutoff the confidence rises further: the landed tracked
arms replay byte-exact on this host (7/7 pinned strings MATCH), the
author's wait constants coincide with my independent table on every
row, the full battery is green 163/163 + 4 probes, and Node holds
31/31. The two falsification-relevant findings — the wait=1 boundary
is still stale on every RID class (no landed arm asserts post-sync at
wait=1; the author pinned the same {2,3} edges) and
`map_set_active(false)` is query-inert — are each witnessed by
multiple arms on both sides. Mechanism attribution inside the sync
pipeline remains inference and is marked.
