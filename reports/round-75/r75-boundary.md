# Game-dev-3d round 75 — boundary (revenger): map/link MUTATION under a committed path, edge probes

Seat: boundary (role revenger). Scope: scratch-only under
`corpus/live/r75-boundary/`; no tracked edits, no commits, leaf — no
dispatch. The lane's declared axis-move (tracked CASES arms pinning
server-side map/link mutation on `navagent3d_detour.gd`) is owned by the
author seat; at probe time the tracked fixture carries no mutation code
(`git status` clean on `corpus/fixtures/`, HEAD `35a911c` r74 report
landing; `navagent3d_detour.gd` last committed `fc9915e` r74). My
assigned recon — the five probe edges from the brief — runs on my own
scratch geometry, independent of the tracked arms landing:

1. mutation BETWEEN materialization and first read vs between two reads
   (dirty-window exactness)
2. link deletion (queue_free/free) vs disable — different invalidation?
3. `region_set_transform` moving the mesh mid-path — does the stored
   path keep its absolute coords (stale-space traversal)?
4. mutation of an UNUSED link/agent-layer — lazy no-op or eager
   invalidate
5. finished-latch + mutation + SAME-value target re-assign — does
   unlatch+invalidation compose predictably

## Deliverable and method

`corpus/live/r75-boundary/scratch/navagent3d_mapmut.gd` sha256
`abc4244d1968789293d0d7843d34115a4634ad7578a897688bddd0f6a8aee7ea` —
SceneTree probe, one `PROBE` line per phase, exit 0 unless live-setup
fails. Geometry verbatim from the r70 L-corridor (A1 x[0,2]z[0,1], A2
x[2,3]z[0,1], B x[2,3]z[1,4]) plus the r73 island C x[2,3]z[5,6]
(`--geo=bridge`); `--link=server|node` authors the hop
(2.5,0,3.5)->(2.5,0,5.5) or an off-route shortcut (1.5,0,0.5)->(2.5,0,3.0)
with `--tc=10`; `--region2` authors a second far-away region
x[10,12]z[10,12] never on any route. `project.godot` is a byte-identical
copy of the tracked seed (sha256 `1fda90d4…8eac23`). Godot
`4.7.2.stable.arch_linux.ed1daf0bf` via `/usr/bin/godot --headless`,
60 tps, cell_size 0.25, 30-tick settle.

Command shape per arm:

```
timeout 90 /usr/bin/godot --headless --path corpus/live/r75-boundary/scratch \
    --script res://navagent3d_mapmut.gd -- --arm=<name> \
    [--geo=bridge --link=server|node --la/--lb --tc --ll \
     --spawn --target --pdd --tdd --region2=1 --n=N]
```

52 runs under `corpus/live/r75-boundary/runs/` (`<arm>.stdout.txt`,
`.stderr.txt`, `.exit` + two `_r2` repeats), every run exit 0, every
stderr banner-only; `dw_absorb_sameturn` and `lm_deadgate` repeats are
byte-identical — deterministic. Runner `corpus/live/r75-boundary/
run_arms.sh`.

Vocabulary carried from r74-critic: forcing calls (run the deferred
update): `get_next_path_position`, `get_final_position`,
`is_navigation_finished`, `is_target_reachable`; pure reads (no update):
`get_current_navigation_path`, `get_current_navigation_path_index`,
`distance_to_target`, `is_target_reached` (stored flag). Requery witness
for outcome-identical mutations: teleport the agent to M=(1.5,0,0.5)
first — `path[0]` re-anchors at the live-position clamp IFF the next
forcing call re-queried; a byte-identical stored array means the
mutation did not dirty the committed path.

## (1) Dirty-window exactness — mutation needs a MULTI-FRAME map sync; the window is deeper than "lazy"

The r74 model says invalidation is forcing-call-gated. The measured
contract is one level finer: **a map mutation is invisible to every
forcing call until the server-side sync publishes it — 2 physics frames
for link-edge toggles, 3 for `region_set_transform` — and only then does
the next forcing call re-query.**

- `dw_between_reads` (runs/dw_between_reads.stdout.txt): region +5x ->
  same-turn pure read serves the old array -> same-turn
  `get_next_path_position` serves the OLD array too
  (`forced_same_turn next=(2,0,1) path=[S,(2,0,1),T]`) — the forcing
  call in the same frame does NOT see the mutation. Post-5-tick read:
  `[(5,0,0.5),(5,0,1.0)]` reachable=false.
- `dw_between_forces` (runs/dw_between_forces.stdout.txt): forceA ->
  mutate -> forceB same turn -> forceB serves old path; +1 tick ->
  force STILL old; +4 more -> moved. Not merely a once-per-frame budget
  effect (see witness bisect).
- `dw_syncn`/`ld_syncn` bisect (runs/dw_syncn{1..4}.stdout.txt,
  runs/ld_syncn{1..4}.stdout.txt): forced `get_next` after N ticks of
  mutation — region transform: STALE at n=1 and n=2, re-queried at n=3;
  link disable: STALE at n=1, re-queried at n=2. The zombie window is
  the sync latency, not just call laziness.
- `dw_witnessn`/`ld_witnessn` (runs/dw_witnessn{1,2,3}.stdout.txt,
  runs/ld_witnessn{1,2}.stdout.txt) discriminates dirty-pickup vs map
  rebuild: teleport M, mutate, force at n. At n<=2 (region) / n=1
  (link) the forced call returns `path[0]=(0.5,0,0.5)` — the STORED
  array, not a re-anchored requery of the not-yet-rebuilt map (a stale-
  map requery would have anchored at M). So the dirty flag itself is
  agent-invisible until the sync lands; inside the window the update
  serves the committed result untouched.
- `dw_absorb` (runs/dw_absorb.stdout.txt): `set_target` then region +5x
  INSIDE the deferred window -> pure reads stay `[]` through the
  mutation (w1=[], w2=[]) -> the materializing query lands on the
  MOVED map `[(5,0,0.5),(5,0,1.0)]`. A mutation inside the dirty window
  is absorbed: no zombie version of that path ever exists.
- `dw_absorb_sameturn` (runs/dw_absorb_sameturn.stdout.txt): set_target
  + mutate + get_next in ONE turn materializes on the OLD map
  `[(0.5,0,0.5),(2,0,1),(2.9,0,3.9)]` — the deferred query routes on the
  last-synced snapshot — and a LATER update still picks up the mutation
  (posttick re-queried to the moved map): materializing on a stale map
  does not consume the dirty state.
- `dw_after_materialize` (runs/dw_after_materialize.stdout.txt):
  materialize on old map, then mutate same turn — the just-materialized
  path is instantly stale for pure readers; the zombie window is
  exactly (materialization, first post-sync forcing call].

## (2) Delete vs disable — identical invalidation channel; the dead gate is fully traversable-looking until sync+force

On the bridge, committed path `[S,(2,0,1),(2.5,0,3.5)ls,(2.5,0,5.5)le]`:

- `ld_disable_ticks`, `ld_free_ticks`, `ld_node_disable`,
  `ld_node_free`, `ld_node_qfree` (runs/ld_*.stdout.txt): server
  `link_set_enabled(false)`, server `free_rid`, node `enabled=false`,
  node `free()`, node `queue_free()` — ALL produce the same outcome:
  pure reads keep serving the dead-gate waypoints verbatim
  (`pure_path=[S,(2,0,1),ls,le]` — the zombie IS observable), and the
  post-sync forcing call re-queries to the clamped bank path
  `[S,(2,0,1),(2.5,0,4.0)]` reachable=false, idx repop to 1. Delete and
  disable are the SAME lazy invalidation channel; deletion is just
  irreversible.
- Same-turn forcing calls after `free_rid`/`free()`/`queue_free()`/
  `enabled=false` still route through the dead link (map not yet
  rebuilt): `ld_free_sameturn sameturn next=(2,0,1) path=[..ls,le]`,
  `ld_node_free sameturn` identical; `ld_node_qfree` shows
  `valid=true` same turn / `valid=false` at tick1 yet `tick1f` still
  serves the link path — object lifetime, server registration and
  map-query visibility are three different timelines.
- `ld_free_recreate` (runs/ld_free_recreate.stdout.txt): free_rid +
  recreate identical link -> same-turn query serves stored path
  (new link `iter=0` unjoined) -> post-sync `iter=1` + forcing call
  re-queries and the hop returns BYTE-IDENTICAL
  `[S,(2,0,1),ls,le]`. Recreate restores; there is no stale-RID
  shadow.
- `ld_disable_enable` (runs/ld_disable_enable.stdout.txt): disable ->
  clamped unreachable; re-enable -> the link path returns
  byte-identical — the toggle round-trips cleanly through two
  lazy requeries.
- `ld_midvoid45_disable` vs `ld_midvoid46_disable`
  (runs/ld_midvoid4*.stdout.txt) — the sharp mid-void boundary:
  at the exact equidistant point (2.5,0,4.5) disabling the link
  re-anchors the requery to the B bank (tie -> near bank, r73
  confirmed): degenerate `[(2.5,0,4.0),(2.5,0,4.0)]`,
  reachable=false, finished=TRUE via the idx+pdd clause (euclid 0.5
  < pdd) — "finished" latched in dead space. At z=4.6 the agent is
  0.9 < tdd from T2 so reached+finished latch FIRST — the disable is
  then gated off entirely and the live link path is served forever
  (see edge 5).
- `ld_link_move_end` (runs/ld_link_move_end.stdout.txt):
  `link_set_end_position(ls,(2.5,0,5.8))` invalidates identically —
  requery re-routes `[S,(2,0,1),ls,(2.5,0,5.8),(2.5,0,5.5)]` npath=5:
  the moved endpoint becomes a waypoint and the hop exits onto C at the
  OLD clamp, then walks back to T.
- Region lifetime (corridor): `ld_region_free` and
  `ld_region_disable` both produce the r73 third mode — EMPTY path +
  `final=(0,0,0)` + reachable=false, idx reset 1->0 (identical to the
  fw_layermask signature); `ld_region_recreate` restores the
  byte-identical original; `ld_region_disable_enable` round-trips
  (empty -> `[S,(2,0,1),T]`).

## (3) region_set_transform — stored path keeps ABSOLUTE coordinates until post-sync force; the query space is world-fixed

- `rt_small_move` (runs/rt_small_move.stdout.txt): region +0.3x (mesh
  still overlaps the old path) — same-turn AND post-5-tick pure reads
  serve the PRE-MOVE absolute coords `[(0.5,0,0.5),(2,0,1),(2.5,0,3.5)]`
  verbatim. The stored path does NOT ride the region's transform:
  zombie-space traversal is real for pure readers — the waypoints still
  point at where the geometry used to be.
- Post-sync force re-queries in world space: waypoints shift +0.3 to
  `[(0.5,0,0.5),(2.3,0,1),(2.5,0,3.5)]` — path[0] stays at the live
  position (still on-mesh under the small shift); the RAW target is
  also world-fixed (`dist` stays 3.605551: `target_position` is a
  stored Vector3 that does not move with the region).
- `rt_anchor_clamp` (runs/rt_anchor_clamp.stdout.txt): +5x moves every
  polygon off the live position — the requery anchors path[0] at the
  CLAMP of the live position onto the moved mesh
  `[(5,0,0.5),(5,0,1.0)]`, reachable=false, idx resets 1->0.
- `rt_move_back` (runs/rt_move_back.stdout.txt): +5 then restore
  identity -> the original path returns byte-identical
  `[S,(2,0,1),T]`. Requery is stateless: no drift, no accumulation.
- `rt_rot180` (runs/rt_rot180.stdout.txt): 180-degree Y rotation lands
  the mesh on x<0 — degenerate `[(0,0,0),(0,0,0)]` final=(0,0,0)
  reachable=false and finished=TRUE via the idx+pdd clause (euclid
  agent->final 0.707 < pdd). A total-remap mutation can "finish" an
  agent 3.6 units from its target.
- `rt_identity_same` (runs/rt_identity_same.stdout.txt): writing the
  CURRENT (identity) transform does NOT dirty the map — the M-witness
  path[0] stays (0.5,0,0.5), pathsame=true. Same-value writes are
  suppressed (see edge 4).

## (4) Unused/irrelevant mutation — EAGER invalidate at map granularity; same-value writes are the only no-op

Discriminator: teleport to M=(1.5,0,0.5) first; `path[0]` re-anchoring
to M at the post-mutation read proves a requery ran even when the route
is unchanged.

- Mutating objects that CANNOT affect this query still invalidates
  (`runs/um_link_*_unused.stdout.txt`): off-route shortcut link
  (travel_cost=10 -> corridor chosen): `link_set_enabled(false)`,
  `free_rid`, `link_set_navigation_layers(2)` — each re-anchors
  path[0] at M `[(1.5,0,0.5),(2,0,1),T]`. There is no relevance filter.
- Mutating a DIFFERENT region never on any route likewise invalidates:
  `um_region2_move` (far region +5x) and `um_region2_layers` both
  re-anchor path[0]=M. The dirty channel is map-wide.
- `um_link_tc_used` (runs/um_link_tc_used.stdout.txt): raising
  travel_cost 1->3 on the on-route bridge link (still the sole route,
  identical outcome) re-queries anyway — outcome-identical effective
  writes dirty.
- Same-value writes are the measured exceptions — ALL suppressed
  (`runs/um_link_enable_same`, `um_region_layers_same`,
  `rt_identity_same`, `um_agent_layers_same`):
  `link_set_enabled(true)` when already enabled,
  `region_set_navigation_layers(1)` when already 1,
  `region_set_transform(identity)` when already identity,
  `agent.navigation_layers = 1` when already 1 — no requery, path[0]
  stays, pathsame=true. Somewhere in the pipeline a value-changed check
  gates the dirty flag.
- `um_agent_layers_equiv` (runs/um_agent_layers_equiv.stdout.txt):
  agent mask 1->3 covers every region/link layer (outcome-identical) —
  yet the setter clears the stored path SYNCHRONOUSLY same-turn
  (`pure_path=[]`), then re-materializes at M on the next read.
  Agent-side setters and server-side map edits are TWO different
  invalidation channels: agent-side clears the array immediately
  (dirty window `[]`), server-side leaves the stale array readable
  until post-sync force. (`um_agent_layers_same` shows the agent
  setter does dedup — unlike `target_position`, which clears even on
  same-value writes per r74 mv_unlatch.)
- `ld_toggle_netzero` (runs/ld_toggle_netzero.stdout.txt): disable +
  re-enable in ONE turn is a net-zero map state — the M-witness still
  re-anchors path[0]=(1.5,0,0.5): the two effective-value writes each
  marked dirty; there is no collapse/dedup across a toggle.

## (5) Latch + mutation + same-value retarget — composes predictably; mutations accumulate under the latch and surface at unlatch

- `lm_latch_move_retarget` (runs/lm_latch_move_retarget.stdout.txt):
  fg/tg latch (spawn ON the clamp, tdd=1.6 -> reached+finished at
  settle). Region +5x under latch -> forcing call serves the frozen
  path `[fg,fg]` (pathsame=true — the latch early-returns the update
  BEFORE the dirty check). Same-value `target_position` re-assign ->
  pure read `[]` (synchronous clear) -> the deferred requery lands on
  the MOVED map `[(5,0,1),(5,0,1)]` reachable=false — then
  reached/finished RE-LATCH via the live euclid clause (1.5 < 1.6).
  Composition is sequential and predictable: mutation invisible under
  latch -> unlatch -> requery sees CURRENT map -> flags re-evaluate.
- `lm_latch_disable_retarget` (runs/lm_latch_disable_retarget.stdout
  .txt): latch -> disable the bridge link invisibly (pathsame=true)
  -> retarget to island T2 -> requery sees the dead link and clamps
  `[(2,0,3),(2.5,0,4.0)]` — with tdd=1.6 the clamped final reads
  reachable=TRUE (euclid(final,raw)=1.5 <= tdd, inclusive gate) and
  reached=false finished=false. Mutations under latch persist in the
  map and surface verbatim at the next materialization.
- `lm_deadgate` (runs/lm_deadgate.stdout.txt) — the dead-gate
  composition, both halves measured: committed link path -> agent
  mid-void at the tie point (2.5,0,4.5) -> disable -> requery clamps
  `[(2.5,0,4.0),(2.5,0,4.0)]` finished=TRUE -> RE-ENABLE the link ->
  forcing call: path STAYS the clamped zombie — the live map could
  route (link is back, iter verified) but the latched early-return
  keeps serving the dead result; `reachable` stays false, `next` stays
  (2.5,0,4.0). Same-value retarget -> unlatch -> requery restores the
  hop `[(2.5,0,4.0),(2.5,0,3.5),(2.5,0,5.5)]` reachable=true.
- `lm_deadgate_free` (runs/lm_deadgate_free.stdout.txt): identical
  composition through free_rid + recreate (recreated `iter=1`): the
  clamped zombie persists through the recreate under latch, retarget
  restores the hop. Delete vs disable identical even inside the latch
  composition.
- `ld_midvoid46_disable` is the mirror zombie: at (2.5,0,4.6) the
  agent latches reached+finished FIRST (0.9 < tdd) — the subsequent
  link disable is gated off entirely, and the stored LIVE link path
  `[S,(2,0,1),ls,le]` reachable=true is served forever through the
  dead link. The latch can pin either direction of divergence: a dead
  path on a live map, or a live-looking path through a dead gate.

## Reconstructed contract (evidence chain)

1. Server-side map invalidation is **sync-gated, then
   forcing-call-gated**: an effective-value map write becomes
   agent-visible only after the server publishes it — measured 2
   physics frames for link-edge toggles, 3 for `region_set_transform`.
   Inside the window every forcing call (including the first) serves
   the stored result untouched; the witness bisect shows the dirty
   flag itself is not yet visible (no re-anchored stale-map requery).
2. After the sync lands, the next forcing call re-queries in world
   space: the stored array is REPLACED (idx resets to 0 then re-pops
   on the new path; fw_mapedit's 1->0 reset corroborated throughout).
   The new path anchors at the live-position clamp and re-evaluates
   reachable under current tdd.
3. The zombie is real but bounded: between the mutation call and the
   first post-sync forcing call, pure reads
   (`get_current_navigation_path`/`_index`) serve the committed
   absolute coordinates verbatim — including waypoints of a deleted
   link or a moved region (stale-space traversal). It is observable
   only through pure getters; it cannot outlive the next post-sync
   forcing call.
4. The dirty channel is **map-wide and value-gated**: any
   effective-value write to any object on the map (unused link,
   far-away region, outcome-identical cost) invalidates every agent;
   same-value writes on region/link/agent-layers/transform are all
   suppressed. Toggle-pairs do not collapse.
5. Two invalidation channels with different observable windows:
   agent-side setters (`navigation_layers`, `target_position`) clear
   the stored array SYNCHRONOUSLY (dirty window `path=[]`, stale idx
   readable) and materialize lazily; server-side map edits leave the
   stale array readable until post-sync requery. `navigation_layers`
   dedups same-value; `target_position` does not (r74).
6. Latch composes predictably: under `finished` the update
   early-returns before the dirty check — mutations are invisible but
   persist in the map; ANY `target_position` re-assignment (same value
   included) unlatches + clears, and the deferred requery sees the
   accumulated current map; reached/finished then re-latch per live
   gates. Re-enabling a dead gate under latch produces a persistent
   zombie path; only the retarget restores routing.

## Suggested battery surface (for the author, if not already landed)

Each maps to a measured receipt above; all constants measured on this
build:

- link disable -> clamped `[S,(2,0,1),(2.5,0,4.0)]` reachable=false
  (ld_disable_ticks); node free and queue_free equivalent
  (ld_node_free / ld_node_qfree); region free/disable -> EMPTY path +
  `final=(0,0,0)` (ld_region_free / ld_region_disable); recreate ->
  byte-identical restore (ld_free_recreate / ld_region_recreate);
  disable->enable round-trip (ld_disable_enable).
- sync-window arm: mutate -> same-turn force serves OLD array ->
  post-sync force serves new (dw_between_reads /
  ld_disable_sameturn constants; latency 2 frames link / 3 region
  transform — if tracked arms assert a settle count, >=5 ticks is
  measured-safe).
- stale-space arm: +0.3x -> pure path serves old absolute coords ->
  post-sync waypoints +0.3 (rt_small_move).
- dead-gate arm: mid-void tie-point disable -> `[(4.0),(4.0)]`
  finished=true; re-enable -> zombie persists under latch ->
  same-value retarget -> hop restored
  `[(4.0),(3.5),(5.5)]` (lm_deadgate).
- eager-invalidation arm via the M-witness: unused-link disable
  re-anchors path[0]=(1.5,0,0.5) (um_link_disable_unused);
  same-value writes suppressed (um_link_enable_same /
  um_region_layers_same / rt_identity_same).

## Divergences and honest caveats

- The sync latency is bounded (link edits query-visible at 2 frames,
  region transform at 3) but the mechanism (deferred region rebuild
  vs map merge vs agent dirty-check order) is inferred from timing,
  not engine source — the numbers are exact on this host; whether the
  same latencies hold at a different physics tick rate is unprobed.
- At n<visibility, whether a forcing call "re-queries the not-yet-
  rebuilt map" or "does not requery" is partially indistinguishable;
  the M-witness (path[0]=S, not M) supports the latter — reported as
  the dirty flag being agent-invisible, marked inference where the
  pipeline stage is concerned.
- `ld_midvoid46`'s latch-first ordering depends on tdd>=0.9 at the
  teleport point; the boundary vs `ld_midvoid45` (exactly
  euclid==tdd, strict-< fails) is measured at 0.1 spacing — the
  equidistant-tie plus strictness both come from prior rounds'
  pinned semantics.
- All mutations here are server RIDs or direct node property writes
  on ONE agent's map; multi-agent, multi-map, NavigationRegion3D
  node-side transforms, baked-mesh rebakes and physics-body
  locomotion are out of scope (transform-follower discipline, same
  as r72-r74).
- One engine build (`4.7.2.stable.arch_linux.ed1daf0bf`), one host,
  60 Hz, 30-tick settle; arm receipts under
  `corpus/live/r75-boundary/runs/` are the evidence chain.

## Post-cutoff: author landing verified against this evidence

The author's tracked diff landed AFTER the probe corpus above was
complete (`navagent3d_detour.gd` working-tree mtime 2026-10-14
02:12:31, `run_battery.py` 02:13:01, both uncommitted vs r74 HEAD).
Re-verified in full:

- All 11 new `mut_*` arms run exit 0 / PASS against a verbatim copy
  of the landed fixture (`runs/author_*.stdout.txt`; copy
  `scratch/navagent3d_detour_wt.gd`, `diff` = clean):
  `mut_link_kill`, `mut_link_drop`, `mut_link_layers`,
  `mut_layers_agent`, `mut_layers_region`, `mut_region_move`,
  `mut_region_off`, `mut_region_renew`, `mut_link_revive`,
  `mut_lazy`, `mut_latch_zombie`.
- `run_battery.py` gains exactly 11 CASES rows (+22/-0 — purely
  additive, all 145 prior rows byte-identical, probes untouched),
  and every pinned expected string BYTE-MATCHES my measured PASS
  lines on this host (11/11 MATCH, verified by script).
- Model alignment vs the reconstructed contract: every author arm
  corroborates — lazy sync-gated invalidation with `peek_*` pinning
  the stale array (`peek_path`/`peek_idx` asserts run BEFORE the
  forcing read, `peek_only` proves no-forcing = no-op); the
  agent-side `navigation_layers` synchronous clear
  (`mut_layers_agent` peek `[]` with stale idx=1 — exactly the
  `um_agent_layers_equiv` channel split); region off/layers/delete ->
  empty path + `final=(0,0,0)`; re-enable/recreate rematerializes;
  the finished latch gating ALL invalidation — `mut_latch_zombie`
  even extends my transform-only latch test to region DELETE under
  latch (also survives — consistent with early-return ordering).
- Author arms remain SILENT on (scratch-only evidence, un-pinned):
  the 2/3-frame sync latency itself (all author waits are >=5/10
  ticks — safe but the number is not pinned); map-wide eager
  invalidation (`um_*`); same-value-write suppression
  (`um_*_same`/`rt_identity_same`); toggle non-collapse
  (`ld_toggle_netzero`); stale-space traversal at +0.3x; the
  mid-void tie-point boundary sharpness; the
  agent-layers-dedups-vs-target_position-does-not asymmetry; and the
  retarget/unlatch composition path (`mut_latch_zombie` never
  retargets — the unlatch mechanics are `lm_*` only).
- One transient defect observed and self-resolved by the author:
  a mid-edit snapshot (02:12:30, missing the `peek_only` branch in
  `_run_motion_arm`) crashed `mut_lazy` on `st_i["next"]` then hung
  headless (exit 124 under timeout) — the landed file (02:12:31,
  one second later) contains the branch and the arm passes. If the
  author's own validation ran during that window it may show one
  spurious timeout; the landed state is clean.

## Confidence

High on all five edges: 52 runs, exit 0 everywhere, byte-identical
determinism on repeats, every numeric claim backed by a `runs/`
receipt on this host. The two headline results — sync-window latency
(2/3 frames) and the latch-pinned dead-gate zombie (both directions) —
are each witnessed by at least two independent arms, and every
overlapping arm in the landed tracked surface reproduces my measured
constants byte-for-byte. The only softness is pipeline-stage
attribution inside the sync window, which is flagged as inference.
