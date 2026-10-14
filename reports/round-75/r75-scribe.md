# game-dev-3d round 75 — scribe report (seat: scribe, host: devin)

Declared lane axis-move (from dispatch, verbatim): "pin server-side
map/link MUTATION under a committed path — the zombie-waypoint question
(XConnector wave-5 recommended arm): once a path materializes and
latches, does mutating the map (disable/enable the off-mesh link, change
navigation_layers on the link or agent, delete/recreate the region,
region_set_transform) invalidate the stored path lazily, leave a
traversable dead-gate waypoint, or update on the next forcing call?
Declared falsifiable claim: the stored path is invalidated by map
mutation (the r74 lazy-update model predicts invalidation is
forcing-call-gated, and critic fw_mapedit/fw_layermask measured EMPTY
path + final=(0,0,0) on map edits — land these as tracked CASES arms).
Additive --arm= presets only; 145 prior CASES rows + 4 probes + Node
31/31 stable."

Scribe duty per brief: independently derive under
`corpus/live/r75-scribe/` — own mutation fixture (own geometry + mutate
steps) — converge or diverge per claim (zombie waypoint, lazy
invalidation, latch-vs-mutation interaction); draft the lesson
(`corpus/lessons/` convention, fenced inside this report, [pending] sha
slots); report-only, not the judge.

Canonical repo `~/Projects/shokunin/game-dev-3d-shokunin` (the brief's
`~/Projects/prymeagnt/game-dev-3d` worktree line is the stale
predecessor path — same finding as r75-baseline). Engine
`/usr/bin/godot` = `4.7.2.stable.arch_linux.ed1daf0bf`, Python 3.14.7,
60 tps pinned (`project.godot`), one process per arm.

## Own measured evidence (independent derivation)

Probe `corpus/live/r75-scribe/scratch/r75s_mutation.gd`, sha256
`2c5d237014f4b3f06f9ed9f4edfb1c03af99b6797126863a4f1feb1f304bc199`,
extends-SceneTree driver on a byte-identical `project.godot` copy
(sha256 `1fda90d4…8eac23`). **Own geometry, own arms, own `GM` output
format** — deliberately unlike every sibling (author/critic/scout/
boundary all reuse the r70 L-corridor A1/A2/B + island C + aligned
vertical link `(2.5,0,3.5)→(2.5,0,5.5)` in a single-mesh region; r74
scribe used a 5-quad corridor with no links):

- "hook-and-ferry", **two region RIDs on one map** (region
  delete/recreate exercises a real second region, not a polygon in the
  shared mesh): region MAIN = G1 `x[0,4]z[0,1]`, G2 `x[0,4]z[1,2]`
  (share z=1 edge), spur E `x[4,5]z[0,1]` (exact shared edge x=4 z[0,1]
  with G1 — the first draft's sub-edge spur did NOT connect, confirming
  Godot joins polygons only on exact shared edges; fixed before any
  arm ran). Region ISLE = quad `x[6,9]z[2,5]`, its own RID.
- Server link (diagonal, not aligned): `(4.5,0,0.5)` spur →
  `(6.5,0,2.5)` isle, bidirectional, layers 1, `--linkoff` starts dead.
- `S=(1,0,0.5)` on G1 → `T=(8,0,4)` on I. Committed path at
  materialization:
  `[(1,0,0.5),(4,0,0.5),(4.5,0,0.5)ls,(6.5,0,2.5)le,(8,0,4)]` npath=5,
  pathlen=8.449747, dist=7.826238, reach=true, idx settles to 1.

Command per arm (cwd `corpus/live/r75-scribe/`):

    /usr/bin/godot --headless --path scratch \
      --script res://r75s_mutation.gd -- --arm=<name> [--linkoff --settle=N]

Runner `corpus/live/r75-scribe/run_arms.sh`; receipts
`corpus/live/r75-scribe/runs/<arm>.{stdout.txt,stderr.txt,exit}`.
**20 distinct arms + 2 byte-identical determinism repeats
(`gm_link_off_b`, `gm_latch_kill_b`), all exit 0, all stderr empty.**
Read discipline per arm: pure readers first (`get_current_navigation_
path`/`_index` — never run the update), then one forcing call
(`get_next_path_position`, or `is_navigation_finished` for
`gm_fin_force`), then the full state line. `same=` compares the stored
array verbatim to the materialized P0.

### Results table (every row measured on this host)

| arm | mutation | lazy window (pure read, post-wait) | first post-wait forcing call |
|---|---|---|---|
| gm_base | none | `same=true` after 10 ticks | unchanged, idx=1 |
| gm_link_off | `link_set_enabled(false)` | OLD 5-pt array still served | re-query → `[S,(4,0,0.875),(5,0,1)]` npath=3, `final=(5,0,1)`, reach=false — **no dead gate served** |
| gm_link_off_gate | tp to (4.2,0,0.6) → idx pops 1→3 (next=le), then disable | pure shows stale **idx=3** on the dead route | re-anchored `[(4.2,0,0.6),(5,0,1)]`, idx reset→1, fin=true (unreachable clause) |
| gm_link_off_sameturn | disable + force in ONE turn | — | **same-turn force serves the OLD array + old next=(4,0,0.5)** — mutation invisible until a frame sync; +5 ticks → force → clamped path |
| gm_link_toggle | disable+enable same turn | — | 5-pt path restored (`same=true`; non-discriminating — anchor still at spawn, see note) |
| gm_link_revive (`--linkoff`) | `link_set_enabled(true)` | severed 3-pt clamp stored | full ferry path restored byte-identical, reach=true — revive is forcing-gated too |
| gm_link_layers | link nav_layers 1→4 | lazy stale | clamped 3-pt, reach=false (identical to disable) |
| gm_agent_layers | `agent.navigation_layers=4` | **same-frame pure read already `[]`** — agent-side setter clears EAGERLY | npath=0, `final=(0,0,0)`, reach=false |
| gm_region_layers | isle layers 1→2 | lazy stale | clamped 3-pt (isle invisible) |
| gm_region_move | isle `+6x` transform | lazy stale | clamped 3-pt `final=(5,0,1)` (ferry lands on void) |
| gm_region_off | `region_set_enabled(false)` | lazy stale | clamped 3-pt |
| gm_region_free_re | `region_set_map(rid, RID())` + `free_rid`, then NEW rid + same mesh | stale through BOTH windows | deleted → clamped 3-pt; recreated → **full ferry path byte-identical (`same=true`)** — no stale-RID shadow |
| gm_link_move | both endpoints → `(1.5,0,1.5)`/`(7.5,0,3.5)` | lazy stale | re-query routes through the NEW gate: `[S,(1.25,0,1),(1.5,0,1.5),(7.5,0,3.5),T]`; old gate never served post-sync |
| gm_link_travelcost | `travel_cost 0→50` on the sole route | lazy stale | `same=true` — unobservable on single-route geometry (non-discriminating; see note) |
| gm_latch_kill | tp onto isle beside T → latch rched+fin, then kill link | stale | **zombie under latch: forcing call still serves the dead ferry path, flags stay latched**; same-value `target_position` re-assign → unlatch → re-query lands on post-mutation map `[(7.7,0,3.8),T]` local isle path |
| gm_pure_ticks | disable, then 8 ticks of PURE reads only | **array byte-identical every tick** — ticks never invalidate | post force → clamped 3-pt |
| gm_map_deactivate | `map_set_active(map,false)` | stale | **`same=true`, reach=true — whole-map deactivation does NOT invalidate the committed path** |
| gm_map_deactivate_pop | deactivate, tp (3.5,0,0.8) within pdd of path[1] | stale | force **pops on the stored array** (idx 1→2, next=(4.5,0,0.5)) — the committed result still functions |
| gm_map_reregister | `agent.set_navigation_map(same map)` | — | inert (`same=true`) — r74 `lt_mapset` converged |
| gm_fin_force | disable; force with `is_navigation_finished` only | stale | invalidation lands (clamped 3-pt) — the flag getter consumes map-dirty like `get_next` does |

## Convergence vs the declared claim — per sub-question

**"Does mutating the map invalidate the stored path lazily?"**
CONVERGE, sharpened. Every server-side content mutation I ran (link
enable/layers/endpoint-move, region enable/layers/transform/
detach+free/recreate) leaves the committed array readable by pure
getters for arbitrarily many ticks (`gm_*:win` all `same=true`;
`gm_pure_ticks` byte-identical across 8 ticks), and the first forcing
call AFTER the map sync re-queries from the live position. This matches
the author's 11 landed `mut_*` arms (all PASS per critic's battery
re-run) and critic `zw_*`/`inv_*` + boundary `dw_*`/`ld_*`/`rt_*`/
`um_*` — four independent derivations on three geometries.

Two sharpenings the siblings measured that my window sizes bracket but
do not bisect: boundary's `dw_syncn`/`ld_syncn` pin the sync latency
itself (**link toggles visible at frame 2, `region_set_transform` at
frame 3** — "next forcing call" = next forcing call *after the next map
sync*), and boundary's `um_*` set shows the dirty channel is
**map-wide**: mutating an unused link or a never-on-route region still
re-anchors `path[0]` at the live position. My `gm_link_toggle` and
`gm_link_travelcost` are non-discriminating for that question (agent
still at spawn, sole route — an outcome-identical re-query returns the
same array); boundary's anchor-shift witness (`um_link_tc_used`
re-anchors at M, `ld_toggle_netzero` re-anchors under net-zero toggle)
proves those writes DO dirty. Consistent, mine just can't see it.

**"Leave a traversable dead-gate waypoint?"**
RESOLVED to a narrow window — not a persistent service. Post-sync, no
forcing call ever returns a dead-gate coordinate (all my `:post` rows
re-query; `gm_link_move` routes through the new gate). But two windows
exist where the dead route is real:

1. *Stored-data zombie* (lazy window): pure readers serve the stale
   array verbatim, stale idx included — `gm_link_off_gate:win` holds
   `idx=3` pointing at the dead far endpoint `(6.5,0,2.5)`; boundary's
   `rt_small_move` adds that the array keeps ABSOLUTE coordinates under
   a moved region (zombie-space, not riding the transform).
2. *Served/traversed zombie* (setter→sync window): a forcing call
   inside the mutation's own turn still answers from the stale commit —
   my `gm_link_off_sameturn:sameturn_force` returns `next=(4,0,0.5)`
   on the untouched 5-pt array; critic's `zw_popgate_sameturn` is
   sharper — `get_next_path_position` served the dead far endpoint
   `(2.5,0,5.5)` AND popped idx 2→3 across it, with server-side ground
   truth equally stale (`link_get_enabled` reads true until frame
   sync; `runs/iter_check.stdout.txt`). The author's fixture-header
   wording "no dead-hop point is ever SERVED" is **falsified** by the
   critic on this point (verbatim conflict carried below).

**"Or update on the next forcing call?"**
CONVERGE as worded, once "next" is read post-sync: re-query happens
inside the forcing call, idx resets→re-pops (my idx `3→1`,
author `mut_link_kill` `idxs=2,3,1`), `reachable`/`finished`
re-evaluate (dead-bank `finished=true` under the unreachable clause on
both my `gm_link_off_gate` and author `mut_link_kill`). Re-enable,
recreate, and re-gate all restore the route byte-identically
(`gm_link_revive`, `gm_region_free_re` `same=true`, `gm_link_move`);
boundary measured the same round-trip for link disable→enable and
region disable→enable.

**Latch-vs-mutation interaction.**
CONVERGE: `finished` latched gates the whole update BEFORE the dirty
check — `gm_latch_kill` keeps serving the dead ferry path through
forcing calls while latched (author `mut_latch_zombie`, critic
`lt_linkkill_*`, boundary `lm_deadgate` incl. the re-enable-under-
latch still-zombie half). Measured unlatch stays `target_position`
assignment; the pending map state surfaces at the unlatch re-query
verbatim (my `unlatched` phase re-anchored on the isle-local path;
boundary `lm_latch_disable_retarget` clamps on the moved map).

**Channel asymmetry (sharper than the claim wording).**
Agent-side setters are a different channel: `agent.navigation_layers=4`
cleared the stored array **synchronously in the same frame**
(`gm_agent_layers:sameframe pure []`) — eager, not lazy — matching
boundary `um_agent_layers_equiv` (and the asymmetry vs
`target_position`, which clears even on same-value writes while
`navigation_layers` dedups — boundary `um_agent_layers_same`). All
same-value server writes are suppressed no-ops (boundary
`rt_identity_same`/`um_*_same`); I did not re-measure those.

**Completeness modes.** My two-region geometry splits what the brief
lumps as "EMPTY path + final=(0,0,0)": severing the ferry with the
mainland still on-mask yields a **clamped partial path**
(`final=(5,0,1)`, npath=3); the EMPTY mode needs total severance (my
`gm_agent_layers` mask-everything → npath=0 + `final=(0,0,0)`, and the
author's `mut_layers_region`). Verbatim for the judge: the r74 critic
receipts behind the claim are `fw_mapedit` → *repath* onto the moved
mesh (not empty) and `fw_layermask` → EMPTY + (0,0,0) (sole region
masked). Both modes are landed in the mut_* set.

**Single-seat observations (un-corroborated this round):**
`map_set_active(map,false)` did **not** invalidate the committed path —
the stored result stays served and even pops normally
(`gm_map_deactivate`, `gm_map_deactivate_pop` idx 1→2). If map-wide
content dirty is the channel, deactivation apparently doesn't post to
it on this build. Also `gm_fin_force`: `is_navigation_finished`
consumes the pending invalidation exactly like `get_next` (forcer
family per r74). Both are receipts-backed but mine alone — flagged, not
claimed as settled.

## Wave state at observation time

- HEAD moved mid-round: now `770299e` ("r74 boundary seat + pmd operand
  correction"), committed by a sibling lane while this seat ran.
  Working tree: `M corpus/fixtures/navagent3d_detour.gd` (+464/−11 —
  11 `mut_*` arms, `mutate`/`peek_path`/`peek_idx`/`peek_only` step
  keys, `_apply_mutation`, `_final_srv_state`, `srv` object dict per
  the critic/scout reports) and `M corpus/fixtures/run_battery.py`
  (+22/−0 — 11 CASES rows, 145→156, prior rows byte-preserved).
  `?? reports/round-75/` accumulates sibling reports.
- Author battery receipt `corpus/live/r75-author/runs/
  20261014T051310362537Z/verdicts.json`: **156/156 cases PASS**
  (111 ordinary / 45 negative), `seeds_unchanged=true`, mutation probe
  PASS — overall `verdict: FAIL` **only** on `tree_probe_ok=false`
  ("TIMEOUT after 3 seconds; Godot cleanup exceeded 3 seconds",
  `witness_verified=false`): the pre-existing relative-`--runs`
  tree-timeout trap flagged since r72, not a case regression.
  Second receipt `…051627765180Z` is a 1-case focused run.
- Sibling reports present: `r75-baseline.md` (frozen `35a911c` →
  145/145 + 4 probes + Node 31/31 verbatim), `r75-scout.md` (19 arms +
  pre-landing fixture recon), `r75-critic.md` (34 arms; falsifies the
  header's "never SERVED" universal; proves dirty flag lands at map
  sync via `iter_check`), `r75-boundary.md` (52 runs; sync latency
  2/3 frames, delete≡disable, absolute-coord zombie, map-wide dirty,
  same-value suppression, latch composition).
- r75-reviewer and r75-simplifier have live scratch/runs
  (mutant-compare JSONs, `navagent3d_detour_wt.gd` copies); r75-author
  report, verifier, adjudicator still pending at write time.

## Verbatim carries / conflicts for the judge

1. **Declared claim outcome**: "the stored path is invalidated by map
   mutation" — CONFIRMED in substance by four independent derivations,
   but only inside the sharpened contract: *lazily, at the first
   forcing call after the next map sync; eager-cleared only by
   agent-side setters; gated off entirely under latched `finished`;
   whole-map `map_set_active(false)` inert (scribe-observed).*
2. **Falsified sibling wording (verbatim)**: author fixture header /
   `mut_link_kill` comment — "no dead-hop point is ever SERVED … the
   update runs before the pop/next fetch inside the same forcing call"
   — falsified by critic `zw_popgate_sameturn` (dead far endpoint
   served, idx 2→3 across the dead hop) and corroborated by my
   `gm_link_off_sameturn` (same-turn force returns the stale
   array+next). Correct wording per critic: no dead-hop point is served
   *once a physics frame has synced the mutation*.
3. **Brief wording tightening**: "fw_mapedit/fw_layermask measured EMPTY
   path + final=(0,0,0) on map edits" — the r74 receipts are
   repath-under-move (`fw_mapedit` npath=2 on the moved mesh) and
   empty-under-total-mask (`fw_layermask`); both CASES'd now
   (`mut_region_move`, `mut_layers_region`/`mut_layers_agent` family).
4. **Probe infra (pre-existing, verbatim)**: author battery verdict
   FAIL is `tree_probe_ok` under relative `--runs` — the trap the
   r72-reviewer/r74-reviewer flagged; 156/156 cases themselves PASS.

## Retained UNKNOWNs (do not claim)

- Which engine clause carries the dirty (map iteration id vs
  per-object version); pipeline-stage attribution inside the sync
  window is sibling-inferred, not proven.
- `map_set_active(false)` inertness — single-seat single-config
  observation; no sibling arm covers it.
- Multi-agent scope: boundary/critic `--two` arms say dirty is
  per-agent-but-global-to-map; untestable on the landed single-agent
  fixture surface.
- `travel_cost`/enter_cost mutation effects where an ALTERNATE route
  exists (my geometry is sole-route; r73 pinned static crossover only).
- Node-authored `NavigationLink3D` runtime mutation vs server-RID
  (boundary's `ld_node_*` equalized delete/disable, but a freed node's
  lifetime vs server registration timelines are receipt-level only);
  `map_set_cell_size`, `path_height_offset`, simplify/postprocessing
  setter invalidation, baked/mesh-swapped regions, other engine builds.
- Exact sync latency numbers are boundary-measured (link 2 frames,
  region transform 3); my arms used 5-tick windows and observed only
  same-turn-vs-post-sync.

## Draft: lesson entry — `corpus/lessons/r75-navagent-map-mutation.md`

(Proposal; admission pending named non-author replay + parent verdict.
Modeled on `r74-navagent-moving-agent.md`. Commit-sha slots pending —
the tracked diff is uncommitted at observation time.)

```markdown
# R75 — NavigationAgent3D stored-path invalidation under map/link mutation (Godot 4.7.2)

## Decision and evidence

Mutating map data under a committed `NavigationAgent3D` path does NOT
touch the stored result eagerly: the committed array (and stale pop
index) remains readable by pure getters for arbitrarily many physics
ticks, and the first FORCING call after the next server-side map sync
re-queries from the agent's live position. The invalidation is therefore
gated twice — once by the physics sync that publishes the mutation to
the map (measured ~2 frames for link toggles, ~3 for
`region_set_transform`, boundary `dw_syncn`/`ld_syncn`), once by the
agent's lazy forcing-call update (r74 model). Inside the setter→sync
window the stale commit is still live: a same-turn forcing call serves
the old waypoints and can pop across a dead off-mesh hop (critic
`zw_popgate_sameturn`: `next` = dead far endpoint, idx 2→3; server
getters read pre-sync truth in the same window). The "zombie waypoint"
is real but transient — one sync frame at minimum — except under latch.

| mutation class | channel | post-sync forcing result | receipts |
|---|---|---|---|
| link `set_enabled(false)` | lazy, map-sync-gated | re-query; severed sole route → clamped partial path (`final` = nearest on-mask point), `reachable=false`, idx reset→re-pop; dead-bank `finished=true` via the unreachable clause | author `mut_link_kill`/`mut_link_drop`, scribe `gm_link_off*`, critic `zw_disable_*`, boundary `ld_*` |
| link `set_enabled(true)` / toggle off+on | same channel | route restored byte-identical; net-zero toggles still re-query (no collapse) | author `mut_link_revive`, scribe `gm_link_revive`, boundary `ld_disable_enable`/`ld_toggle_netzero` |
| link `navigation_layers`, `link_set_start/end_position`, `free_rid`, node `enabled=false`/`free()`/`queue_free()` | same channel | identical invalidation; moved/dead endpoints never served post-sync; recreate restores byte-identical (no stale-RID shadow) | author `mut_link_layers`, scribe `gm_link_layers`/`gm_link_move`, boundary `ld_link_move_end`/`ld_free_recreate`/`ld_node_*` |
| link `travel_cost` | same channel | dirties even when outcome-identical (anchor-shift witness) | boundary `um_link_tc_used` (scribe `gm_link_travelcost` non-discriminating sole-route) |
| region `set_transform`/`set_enabled`/`set_navigation_layers`/detach+`free_rid` | same channel | stored path keeps ABSOLUTE coords while stale (zombie-space — it does not ride the transform); re-query clamps or empties; recreate with same mesh restores byte-identical | author `mut_region_move`/`mut_region_off`/`mut_region_renew`, scribe `gm_region_*`, critic `zw_region_*`, boundary `rt_*`/`ld_region_*` |
| completeness modes | — | partial reachability → clamped partial path; nothing on-mask → EMPTY path + `final=(0,0,0)` (r73 third mode) | scribe `gm_link_off` vs `gm_agent_layers`, author `mut_layers_region` |
| agent `navigation_layers` setter | EAGER agent-side channel | stored array cleared synchronously same-turn (`[]` + stale idx), then lazy rematerialize at next forcing call | scribe `gm_agent_layers:sameframe`, author `mut_layers_agent` peek `[]`, boundary `um_agent_layers_equiv` |
| same-value writes (link enabled, region layers/transform, agent layers) | suppressed no-ops | no dirty, `pathsame=true` — except `target_position`, which clears on ANY assignment (r74) | boundary `um_*_same`/`rt_identity_same` |
| `map_set_active(false)` | inert (single-seat) | committed path stays served; pop still runs on the stored array | scribe `gm_map_deactivate{,_pop}` |
| `set_navigation_map` same map | inert | no observable change | scribe `gm_map_reregister`, r74 `lt_mapset` |
| granularity | map-wide | mutating an unused link or off-route region still dirties the committed path | boundary `um_*` anchor-shift set |
| under `finished` latch | gated OFF entirely | update early-returns before the dirty check: dead/mutated route stays served through forcing calls while latched; mutations accumulate and surface verbatim at the unlatch re-query (unlatch = any `target_position` assignment, r74) | author `mut_latch_zombie`, scribe `gm_latch_kill`, critic `lt_linkkill_*`, boundary `lm_*` |

### Zombie-waypoint resolution

A dead-gate waypoint is (a) stored-data-visible to pure readers for the
whole lazy window — including a stale idx aimed across the dead hop and
absolute (non-riding) coordinates under a moved region; (b) SERVED and
pop-traversed by forcing calls only inside the setter→sync window (~one
frame for links); (c) immortal while `finished` stays latched. Post-sync
and unlatched, no forcing call returns a dead coordinate — the update
re-queries before the pop/next fetch consumes anything.

### Fixture and battery

`navagent3d_detour.gd` +464/−11: `srv` object dict threaded into
`_run_steps`, `mutate` step key (ordered set_target→tp→mutate→wait→
peek→read) dispatching to `_apply_mutation`, `peek_path`/`peek_idx`/
`peek_only` non-forcing capture keys, `_final_srv_state` post-step gate
(reads post-sync truth — mutate arms need wait≥1). `run_battery.py`
+22/−0: 11 `mut_*` CASES rows → **156 total**, all additive, prior rows
byte-preserved. Author receipt `corpus/live/r75-author/runs/
20261014T051310362537Z/`: 156/156 cases + mutation probe PASS; battery
verdict FAIL on `tree_probe_ok` only — the pre-existing
relative-`--runs` tree-timeout trap (r72+), not a case failure. Baseline
frozen `35a911c` replay 145/145 + 4 probes + Node 31/31. Independent
derivations: scribe `corpus/live/r75-scribe/` (20 arms, two-region
"hook-and-ferry", diagonal link), critic `corpus/live/r75-critic/` (34
arms + iter_check), boundary `corpus/live/r75-boundary/` (52 runs),
scout `corpus/live/r75-scout/` (19 arms).

Commit: work [pending]; adjudication [pending]. Fixture sha256:
[pending]; run_battery.py sha256: [pending].

### Recheck conditions

Any engine rebuild re-runs the battery: sync latency (2/3 frames),
map-granularity dirty, same-value suppression, and latch gating are
engine internals measured, not specified. The same-turn zombie window is
expressible only below the fixture's wait≥1 gate — pinning it needs a
`peek_only` trailing-step arm or gate relaxation. If the tracker ever
ships `map_set_active` semantics, re-run `gm_map_deactivate*`; if a
multi-agent surface lands, re-check global-vs-dependent dirty scope.

## Not established

Engine internals of the dirty flag and sync pipeline (inferred from
behavior only); `map_set_active(false)` inertness (single-seat);
per-agent vs map-global dirty on a tracked multi-agent fixture; cost
mutations with an alternate route; node-authored link mutation beyond
delete/disable parity; cell_size/postprocessing/simplify/height-offset
mutation surfaces; baked-region or navmesh-swap mutation; multi-map
agents; other engine builds.
```

## Draft: LOG.md round-75 entry

    ## Round 75 — devin host — depth: NavAgent3D stored-path invalidation under map/link mutation (zombie-waypoint resolution)

    - Declared (dispatch brief): pin server-side map/link mutation under
      a committed path — does disable/enable link, navigation_layers on
      link/agent, region delete/recreate, region_set_transform
      invalidate lazily, leave a traversable dead gate, or update at the
      next forcing call. Claim: stored path IS invalidated by map
      mutation (forcing-call-gated per r74). 145 rows + 4 probes +
      Node 31/31 stable.
    - Wave: devin leaf set reports/round-75/r75-{baseline,scout,critic,
      boundary,scribe}.md [author/reviewer/simplifier/verifier/
      adjudicator pending at write]. Sole tracked writer = author;
      UNCOMMITTED diff: navagent3d_detour.gd +464/−11 (srv dict,
      mutate/peek_* step keys, _apply_mutation, _final_srv_state),
      run_battery.py +22/−0 (11 mut_* rows → 156).
    - Baseline frozen 35a911c → 145/145 + 4 probes + Node 31/31.
      Author battery 156/156 cases + probe PASS; verdict FAIL on
      tree_probe_ok only (relative --runs trap, pre-existing).
    - Result — claim CONFIRMED with sharpened contract: lazy +
      map-sync-gated invalidation (link ~2 frames, region transform ~3);
      dead gate is served/traversed only inside the setter→sync window
      (header "never SERVED" falsified verbatim by critic + scribe
      same-turn arms); agent-side setters are an EAGER channel
      (same-frame clear); finished-latch gates all invalidation
      (immortal zombie while latched, unlatch = any target assignment);
      EMPTY vs clamped-partial completeness modes; enable/recreate/
      re-gate restore byte-identical; map-wide dirty granularity;
      same-value writes suppressed; map_set_active(false) inert
      (scribe single-seat). Four independent geometries converge.
    - Commit: work [pending]; adjudication landing [pending].

## Touched surfaces (this seat only)

- `corpus/live/r75-scribe/scratch/r75s_mutation.gd` — own probe
  (sha256 `2c5d2370…4bc199`); `scratch/project.godot` — verbatim seed
  copy (sha256 `1fda90d4…8eac23`).
- `corpus/live/r75-scribe/run_arms.sh` — own runner.
- `corpus/live/r75-scribe/runs/` — 20 arm receipts + 2 byte-identical
  determinism repeats (`gm_link_off_b`, `gm_latch_kill_b`), each
  `{.stdout.txt,.stderr.txt,.exit}`.
- This report: `reports/round-75/r75-scribe.md` — the only tracked-path
  write (`reports/round-75/` is `??` untracked at write time; the
  report file is authored content, not a fixture edit).

## Out of scope / non-actions

- No commits, no pushes, no merges/rebases/checkouts, no subagent
  dispatch (LEAF). No edits to `corpus/fixtures/` or any tracked file;
  sibling `corpus/live/r75-*` read for convergence only. The working
  tree left exactly as observed (`M` ×2, `??` ×1).
- The lesson draft above is a proposal fenced inside this report — I
  did not write `corpus/lessons/r75-navagent-map-mutation.md` (the
  brief assigns the draft, not the landing).
- Not a verdict: admission is the canonical Rust judge's; verifier/
  adjudicator slots pending.
