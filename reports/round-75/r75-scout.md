# game-dev-3d round 75 — scout (seat: scout, host: devin)

Axis under mapping: server-side map/link **MUTATION under a committed
path** — the zombie-waypoint question. Declared claim: the stored path is
invalidated by map mutation, lazily (forcing-call-gated). This report maps
the surface pre-landing *and* reconciles against the author's working-tree
landing (`M corpus/fixtures/navagent3d_detour.gd` +464/−11, 11 `mut_*`
arms; `M corpus/fixtures/run_battery.py` +22/−0, 145→156 CASES rows) which
landed mid-review, and against `reports/round-75/r75-critic.md`.

Independent evidence: scratch probe `corpus/live/r75-scout/proj/
r75s_mutate.gd` (sha256 `faecec0a…8d671`), verbatim committed
`project.godot` (sha256 `1fda90d4…8eac23`), bridge geometry identical to
the r73/r74 family (L-corridor A1/A2/B + island C x[2,3]z[5,6] + server
link `(2.5,0,3.5)→(2.5,0,5.5)`; committed path `[S,(2,0,1),ls,le]`,
S=(0.5,0,0.5), T=(2.5,0,5.5), pathlen 6.130649). Godot `4.7.2.stable.
arch_linux.ed1daf0bf`, `/usr/bin/godot --headless`, 60 tps. **19 arm
runs, all exit 0, stderr banner-only.** Receipts:
`corpus/live/r75-scout/runs/<arm>.{stdout,stderr,exit}`; runner
`corpus/live/r75-scout/run_arms.sh`.

## (1) Object references — pre-landing fixture

All server objects were **`_run()`-local vars**
(`corpus/fixtures/navagent3d_detour.gd` @committed `336898f4…01276`):
`map` RID :156, `region` RID :187, `mesh` :160, `link_rid` :192,
`link_node` :193 (`"server"` vs `"node"` arm_cfg link authoring :194-223),
`actor` :224, `agent` :227. `_run_steps(steps, agent, actor)` :263/:1225
saw only `agent`+`actor` — **no step could mutate map/link/region; the
schema needed both a new key AND a widened signature.** Predicted hazards
that the landed diff confirms it handled: the post-step gates at
:284-304 (authored link flags, `map_get_regions(map).size()==1`) ran
AFTER the steps and would have failed every mutating arm; `_cleanup`'s
`owned` free list would have double-freed a deleted region (an `ERROR:`
line fails the battery classifier at run_battery.py:422-424).

**Landed resolution** (working-tree diff): `srv := {"map","region",
"mesh","link_rid","link_node","agent"}` dict + `_run_steps(..., srv)`;
`mutate` step key dispatched to `_apply_mutation` (order inside a step:
set_target→tp→mutate→wait→peek→read; inside mutate: region delete→
recreate→transform/enabled/layers→link→agent); `_final_srv_state` folds
every step's mutate dict into the post-step gate (`want_regions`,
mutated link/region readback); `owned.erase` before `free_rid` + recreated
region re-registered into `srv["region"]`; `peek_path`/`peek_idx`/
`peek_only` step keys capture the NON-forcing stored state between the
wait and the forcing `_read_state` — exactly the missing observability.

## (2) Scriptable mutation inventory — measured this round

All `NavigationServer3D.*` module calls are scriptable mid-run in fixture
context. Per-mutation verdict on the committed bridge path (my runs):

| mutation call | map iter | stored path pre-force | post-forcing result |
|---|---|---|---|
| `link_set_enabled(l,false)` | 2→3 | zombie 4-pt intact | requery → `[S,(2,0,1),(2.5,0,4.0)]` reachable=false, idx re-pops to 1 |
| `link_set_enabled(l,true)` (authored off) | bump | clamped path intact | bridge hop restored, reachable false→true |
| `link_set_navigation_layers(l,2)` vs agent mask 1 | bump | zombie | link dropped → clamped; restore re-materializes hop |
| `link_set_bidirectional(l,false)` fwd-legal | bump | unchanged | **silent mutation**: same 4-pt path byte-identical (iter bump is the only witness) |
| `bidirectional=false` + endpoint swap (committed dir illegal) | bump | zombie | link dropped → clamped unreachable |
| `link_set_end_position(l,(2.5,0,5.9))` | bump | zombie old endpoint | requery → **5-pt path** `[S,(2,0,1),ls,(2.5,0,5.9),(2.5,0,5.5)]` |
| `link_set_map(l,RID())` detach | bump | zombie | link dropped → clamped unreachable |
| `link_set_enter_cost(l,100)` | bump | unchanged | **inert** — bridge path kept (r73 anomaly holds as mutation) |
| `link_set_travel_cost(l,10)` | bump | unchanged | path kept — **non-discriminating on bridge** (link is the only route; cost arms need the shortcut geometry where corridor vs hop compete) |
| `region_set_transform(r,+5x)` | bump | zombie | requery on moved mesh → `[(5,0,0.5),(7,0,0),(7,0,1),(7,0,4)]` idx reset 0, reachable=false (link does NOT move with region — not region-parented; critic agrees) |
| `region_set_navigation_layers(r,2)` | bump | zombie | **EMPTY** path, final=(0,0,0), idx→0 |
| `free_rid(region)` | bump | zombie | **EMPTY** path, final=(0,0,0) |
| delete + `region_create` same mesh | bump ×2 | zombie | byte-identical path restored (re-materializes with no retarget) |
| `map_set_active(map,false)` | **NO iter bump (stays 2)** | unchanged | **fully inert on the committed agent** — forced read still serves the bridge path; no sync ⇒ no dirty ⇒ no requery. A distinct permanent-stale regime, not covered by the author's 11 arms |
| `agent.navigation_layers = 2` | **no iter involved** | **SYNCHRONOUS clear: same-turn path=[]** (stale idx still readable) | stays empty while masked (final=(0,0,0)); restore re-materializes |

Node-authored link (`link_node`) property setters (`enabled`,
`bidirectional`, `navigation_layers`, `enter_cost`, `travel_cost`,
`start_position`, `end_position`, `set_navigation_map`) route through the
same server RID (`link_node.get_rid()`), so they share the same
sync-gated timing. Critic notes node-link mutation itself unprobed.

## (3) Invalidation surface — which call reveals the mutation

Confirmed against r74-critic's forcing-call attribution
(`reports/round-74/r74-critic.md`): forcing calls are
`get_next_path_position`, `get_final_position`, `is_navigation_finished`,
`is_target_reachable`; non-forcing are `get_current_navigation_path`,
`get_current_navigation_path_index`, `distance_to_target`,
`is_target_reached` (stored flag). Fixture `_read_state` :1058-1068 calls
`get_next_path_position` FIRST → every fixture read is post-update.

Three-layer timing, measured (`mut_link_disable`, `mut_disable_window`):

1. **setter→sync window (same turn):** the mutation is invisible to
   EVERYTHING — `link_get_enabled` still reads true and
   `map_get_iteration_id`/`link_get_iteration_id` stay at the pre-mutation
   value in the same turn as the setter (critic `iter_check` receipt;
   my `mut_disable_window` shows iter=2 unchanged same-turn). A forcing
   call inside this window queries the **pre-mutation map**: stored path
   served AND pop-evaluated against it.
2. **sync→force window (≥1 physics frame):** map iteration applies the
   mutation, iter bumps (2→3), but the agent's stored array still holds
   the committed coordinates byte-for-byte through arbitrary ticks —
   **ticks never re-query** (my `:ticks5` reads: zombie 4-pt with iter=3).
   The zombie exists as readable data only.
3. **first forcing call post-sync:** re-query, anchored at the LIVE agent
   position (same anchor rule as set_target, r74). Reveal signature: new
   path array (clamped/re-routed/EMPTY), idx reset→re-pop from live pos,
   `final` recomputed (clamp point or (0,0,0)), `reachable` recomputed,
   `next` = first live waypoint; `dist` stays raw euclid. EMPTY mode:
   path=[], next=agent position, final=(0,0,0).

`NavigationServer3D.map_get_iteration_id(map)` is a usable non-forcing
server-side dirty witness (my probe prints it per read).

## (4) Zombie waypoint — measured verdict

**The declared claim is CONFIRMED post-sync; falsified inside the
setter→sync window and under the latch.** Convergent across author arms,
critic attacks, and my 19 runs:

- **Post-sync: no dead waypoint is ever served.** `mut_link_disable`:
  reveal `next=(2,0,1)` on the new clamped path, never a dead endpoint.
  `mut_disable_pdd4` (pdd=4.0, r73 pop-through config): committed
  `next=(2.5,0,5.5)` IS the far dead endpoint with idx=3 saturated →
  post-disable reveal `next=(2.5,0,4.0)` idx re-popped to 2 — the
  sharpest zombie-kill observable on this geometry.
- **Same-turn: zombie IS served and pop-traversed** — critic
  `zw_popgate_sameturn` (agent on the near gate endpoint,
  `link_set_enabled(false)` then same-turn `get_next` → next=(2.5,0,5.5),
  idx 2→3 across the dead gate). My `mut_disable_window` is the
  consistent corridor-side reading (at S the pop condition isn't met, so
  next stays (2,0,1) on the still-stored zombie array; iter=2 proves the
  disable hadn't landed server-side). The author's header wording "no
  dead-hop point is ever SERVED" is the falsified universal; honest form:
  "once a physics frame has synced the mutation."
- **Pop never crosses a dead gate post-sync**: `mut_link_disable_zombie`
  tp sequence (2.5,0,3.9)→(2.5,0,4.5)→(2.5,0,5.4): the first forced read
  re-anchored at the live bank position → `[(2.5,0,3.9),(2.5,0,4.0)]`,
  `finished=true` via the unreachable idx+pdd clause, and `reached`
  stayed **false even at dist 0.1 on the island** — freeze-after-finish
  (r74) composes with mutation: the kill creates the latch that freezes
  the flags.
- **Latch = permanent served zombie**: `mut_disable_latch` — island
  latched, then link disabled: stored 4-pt path + `next=(2,0,1)` +
  `reached/finished=true` all frozen post-sync (iter bumped 2→3 anyway —
  the server syncs, the agent's update early-returns). Critic's
  `lt_zombie_gate` is the served-dead-endpoint variant (idx=3, next=le
  forever). `map_set_active(false)` produces the same permanent-stale
  regime by a different mechanism (no iteration ever runs).

## (5) Per-mutation observability table (authoring guide)

| arm intent | required step keys | discriminating observables | witness for "invalidation happened" |
|---|---|---|---|
| link kill under committed path | `island`, `link` server, `mutate:{link_enabled:false}` | path 4-pt→3-pt clamped; reachable true→false; final T→(2.5,0,4.0) | path array rewrite + `peek_path` still showing dead hop |
| zombie-window pin | `mutate` + `wait:0`-class read | pure path/idx BEFORE any force | **needs peek machinery** — landed `peek_path`/`peek_idx`/`peek_only`; note landed gate is sync-blind: `wait:0` mutate steps fail `_final_srv_state` readback (critic defect note — server getters read pre-sync truth) |
| dead-gate-served kill | pdd≥4 commit (idx=3, next=le) then `mutate:{link_enabled:false}` | next le→clamp (2.5,0,5.5)→(2.5,0,4.0), idx 3→re-pop | next/idx on the forced step |
| silent mutation | `bidirectional=false` (fwd stays legal) or cost flip | path byte-identical | only `iter`/`link_get_iteration_id` or companion `types`/rids via `meta` — path tuple alone cannot witness it |
| agent-layer flip | `mutate:{agent_layers:n}` | **same-turn `peek_path=[]`** vs stale idx — the ONLY synchronous observable | path empties pre-tick |
| region delete/recreate | `mutate:{region_delete/recreate}` | EMPTY tuple then byte-restore | needs `want_regions`-aware gate + `owned` erase (landed) |
| latch interaction | latch via edge_* spawn then `mutate` | every field frozen incl. served next | iter bump proves sync ran while agent stayed frozen |

Composite hazards for arm authors: mutation near the dead bank can latch
`finished` via the idx+pdd unreachable clause and then freeze `reached`
at false permanently (`mut_link_disable_zombie`); cost/directionality
mutations on the bridge are non-discriminating (link is the only route —
use the shortcut geometry for those).

## Confidence and remaining unknowns

- **High (measured, convergent 3-way)**: lazy total invalidation
  post-sync; same-turn zombie serve/pop; synchronous agent-side clear;
  latch exemption; EMPTY vs clamped-anchor modes; recreate restore.
- **Unknown/not probed here**: node-authored `NavigationLink3D` mutation;
  enter/travel cost flips on the *shortcut* geometry (bridge can't
  discriminate); multi-agent global dirty scope (critic-probed, not
  CASES-expressible on the single-agent fixture); `map_set_active` as a
  tracked arm (my probe only); behavior under avoidance/real locomotion.
- Fixture-edit surface needed pre-landing is landed: `srv` dict +
  `mutate`/`peek_*` step keys + `_final_srv_state`/`want_regions` gates +
  `owned.erase` on free. 11 `mut_*` CASES rows landed (145→156).

Evidence: `corpus/live/r75-scout/runs/*.stdout.txt` (19 arms incl.
`mut_disable_pdd4`), probe `corpus/live/r75-scout/proj/r75s_mutate.gd`,
runner `run_arms.sh`. Priors cited: r74-critic `fw_mapedit`/`fw_layermask`/
`mapedit_lazy`/`fw_al_mid`/`pmd_lazy`/`lt_latch_*` receipts; r75-critic
`zw_*`/`iter_check`/`lt_*`/`race_*`/`shared_*` receipts. Leaf — no
dispatch, no tracked edits, no commits.
