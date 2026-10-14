# game-dev-3d round 77 — scout (seat: scout, host: devin)

Axis under mapping: mutation **APPLY-ORDER** — is `_apply_mutation`'s fixed
order (delete→recreate→transform→link→agent→map_active) load-bearing or
inert under same-tick composition? Declared claim: at least one order-pair
produces observable distinct served state; if all converge, order is
provably inert. Plus `map_force_update` CASES-arm reach and a wait-ladder
verdict-groups receipt. Repo root used:
`~/Projects/shokunin/game-dev-3d-shokunin` (the brief's
`~/Projects/prymeagnt/game-dev-3d` is the meta worktree whose
`.shokunin/game-dev-3d` symlink points here; HEAD `e417365` r76).

Independent evidence: probe `corpus/live/r77-scout/proj/r77s_applyorder.gd`
(sha256 `f0c272a6…a0f`), verbatim committed `project.godot` (sha256
`1fda90d4…8eac23`), geometry identical to the r73-r76 family (plain
L-corridor for region arms; + island C x[2,3]z[5,6] + server link
`(2.5,0,3.5)→(2.5,0,5.5)` for link/map/fu arms; S=(0.5,0,0.5), region arms
target f=(2.5,0,3.5), island arms target T=(2.5,0,5.5)). Godot
`4.7.2.stable.arch_linux.ed1daf0bf`, `/usr/bin/godot --headless`, 60 tps.
**32 probe runs, all exit 0, all stderr byte-empty** + **10 WIP-arm runs**
below. Receipts `corpus/live/r77-scout/runs/<arm>.{stdout,stderr,exit}.txt`;
runner `corpus/live/r77-scout/run_arms.sh` (sha256 `369d6034…f05a`).

**Concurrent-landing note:** the author lane's diff landed while this
probe ran — the tracked `navagent3d_detour.gd` grew 500 lines (uncommitted
WIP, snapshotted at sha256 `a967f012…9664` into
`corpus/live/r77-scout/proj/navagent3d_detour_wip.gd`). HEAD cites below
are `e417365` positions; WIP cites are the shifted positions. I ran every
new WIP arm against that snapshot: **9/10 pass; `mut_force_link` fails**
(receipt `runs/wip_mut_force_link.stdout.txt` exit 1) — details in §3.

## Headline: the declared claim CONFIRMS — order is load-bearing, but only through RID lifecycle

Four order-pairs produce **observable distinct served state**; every pair
without a region-lifecycle op converges. The discriminating mechanism is
not sync timing — it is *which RID/generation a queued same-tick write
lands on*. `region_recreate` frees the old RID and installs a fresh one at
identity defaults; `region_delete` frees whatever `srv["region"]` names at
its position in the sequence. Field setters on a live stable RID commute.

| same-tick pair | fixture order result | reversed result | verdict |
|---|---|---|---|
| {`region_delete`, `region_recreate`} | `del→rec` (`ord_delrec`): fresh region, home detour `[S,(2,0,1),f]` reachable=true | `rec→del` (`ord_recdel`): region **gone** — empty-path tuple `[]`, final=(0,0,0), reachable=false | **DIVERGE** |
| {`region_recreate`, `region_transform:+5x`} | `rec→xform` (`ord_recxform`): fresh region moved — `[(5,0,0.5),(5,0,1.0)]` idx=0 reachable=false | `xform→rec` (`ord_xformrec`): write lands on the doomed RID; fresh region at identity — home tuple reachable=true | **DIVERGE** — matches WIP `mut_ord_renew_xform`/`mut_ord_xform_renew` (both pass on snapshot) |
| {`region_recreate`, `region_enabled:false`} | `rec→en` (`ord_recen`): fresh region disabled — empty `[]` | `en→rec` (`ord_enrec`): disable dies with old RID; fresh enabled — home tuple | **DIVERGE** |
| {`region_recreate`, `region_layers:2`} | `rec→layers` (`ord_reclayers`): fresh on mask 2, agent on 1 — empty `[]` | `layers→rec` (`ord_layersrec`): fresh keeps layers=1 — home tuple | **DIVERGE** |
| {`region_transform:+5x`, `region_delete`} | `del→xform` (`ord_delxform`): `is_valid` guard skips write on freed RID — empty `[]` | `xform→del` (`ord_xformdel`): write lands, RID freed — empty `[]` | converge (inert) |
| {`link_enabled:false`, `link_end`→(2,0,5.5)} | `dis→mv` (`ord_linkdis_move`): dead-link clamp `[S,(2,0,1),(2.5,0,4.0)]` reachable=false | `mv→dis` (`ord_linkmove_dis`): identical | converge — same-turn same-object writes coalesce (agrees r76-boundary `mw_samekey_*` and WIP `mut_ord_link_*` — both pass) |
| {`link_enabled:false`, `link_layers:2`} | `en→layers` (`ord_linken_layers`): dead clamp | `layers→en` (`ord_linklayers_en`): identical | converge |
| {`agent_layers:2`, `region_layers:2`} | `reg→agt` (`ord_regagent`, fixture order): post-sync home tuple reachable=true | `agt→reg` (`ord_agentreg`): identical — same-turn peek `path=[]` either way (sync clear is position-independent) | converge — **but EMERGENT**: each setter alone empties the path (mismatched mask); composed they serve a live path — the seam analog, order-inert |
| {`region_transform:+5x`, `map_active:false`} | `xform→off` (`ord_xform_mapoff`): post-reactivation moved 4-pt tuple `[(5,0,0.5),(7,0,0),(7,0,1),(7,0,4)]` final=(7,0,4) reachable=false | `off→xform` (`ord_mapoff_xform`): identical | converge — pending write queues under inactive map regardless of intra-tick position (WIP `mut_ord_*_mapoff`/`mut_ord_*mapoff_*` pass) |
| {`region_delete`, `map_active:false`} | `del→off` (`ord_del_mapoff`): region gone after reactivation — `[]` | `off→del` (`ord_mapoff_del`): identical (`free_rid` is immediate object-level even while inactive; `map_get_regions` still listed 1 stale entry until reactivation) | converge |

Also resolved (r76-scout open question): **mid-window freeze retains
banked progress**. `ord_midwin` (link-off at t0 → 1 frame → deactivate →
5f → reactivate) serves fresh at reactivate+**1** (`GROUPS 0|1-3`);
`ord_midwin0` (write + deactivate same turn, 0 banked frames) serves fresh
at reactivate+**2** — identical to a write issued while inactive
(`mut_map_cycle`'s +2). The pending write's elapsed schedule survives
deactivation; progress only accrues while the map is active. Neither
freeze drops the write nor restarts its clock.

## (1) `_apply_mutation` fixed order — every key and its apply position

HEAD `e417365`: `corpus/fixtures/navagent3d_detour.gd:1841-1873`; WIP
snapshot `:2214-2259`. Dict iteration order is irrelevant — the apply
sequence is hard-coded:

| pos | key | call site (HEAD / WIP) | target |
|---|---|---|---|
| 1 | `region_delete` | :1842-1845 / :2215-2218 | `free_rid(srv["region"])`, clears to `RID()` |
| 2 | `region_recreate` | :1846-1854 / :2219-2227 | frees live region; `region_create` + `region_set_map` + `region_set_navigation_mesh`; fresh RID at identity defaults |
| 3 | `region_transform` | :1856-1857 / :2229-2230 | guarded `region.is_valid()` — post-delete/recreate RID |
| 4 | `region_enabled` | :1858-1859 / :2231-2232 | guarded, same |
| 5 | `region_layers` | :1860-1861 / :2233-2234 | guarded, same |
| — | link RID resolves | :1862 / :2235 | `srv["link_node"].get_rid()` else `srv["link_rid"]` |
| 6 | `link_enabled` | :1863-1864 / :2236-2237 | guarded `link.is_valid()` |
| 7 | `link_layers` | :1865-1866 / :2238-2239 | guarded |
| 7.5 | `link_start`/`link_end` | — / :2242-2245 (WIP new) | endpoint move, inside the link block |
| 8 | `agent_layers` | :1867-1868 / :2246-2247 | `agent.navigation_layers` — synchronous clear, not server-deferred |
| 8.5 | `map_force` | — / :2253-2254 (WIP new) | `map_force_update(srv["map"])` — after all writes, before `map_active` |
| 9 | `map_active` | :1872-1873 / :2258-2259 | deliberately last (comment :2255-2257) |

WIP machinery around it: `_mut_list` (:2210-2212) accepts `mutate` as an
**array of dicts** applied in sequence through the fixed order — the
author's hand-ordering override (a bare dict keeps fixed order);
`srv_get` step key (:2183-2184) + `_read_srv` (:2268-2286) pin
object-level getter readbacks after the wait, before the forcing read.

Companion fold `_final_srv_state` (HEAD :1880-1927 / WIP :2293+) mirrors
the fixed order per dict and folds steps sequentially — single-dict folds
stay consistent; the array form iterates sub-dicts in declared order.

**Expressibility note:** even without the array form, consecutive
`wait:0` steps stay in the same turn (HEAD `_run_steps` :1819 / WIP :2177
— `range(0)` = no await) and `peek_only:true` steps skip the forcing read
(HEAD :1822-1828 / WIP :2185-2188) — a hand order was always expressible
by splitting the dict across `wait:0`/`peek_only` steps.

## (2) Which setter pairs plausibly interact — mapped then measured

- **RID-lifecycle × field write** (`delete`/`recreate` ×
  `transform`/`enabled`/`layers`): load-bearing — recreate resets field
  defaults on the fresh RID; writes before it die with the old RID, writes
  after it land on the new generation. Measured DIVERGE ×4 above.
- **`delete` × `recreate`**: load-bearing — last lifecycle op wins
  (`rec→del` leaves nothing).
- **Field × field on the same live RID** (`link_enabled`/`link_layers`/
  `link_start`/`link_end`): commute — single coalesced flush (r76-boundary
  `mw_samekey_*` + my `ord_link*` + WIP `mut_ord_link_*`).
- **Cross-object fields** (`link` × `region`): commute — each lands at
  write+class-latency; same-turn slower class takes +1 coupling
  (r76-boundary `mw_sameturn_*`, order-insensitive).
- **Agent channel × server channel**: commute at serve level — the agent
  write's synchronous clear is position-independent
  (`ord_agentreg`/`ord_regagent` identical post-sync tuple).
- **`map_active` × any queued write**: commute — write invisible while
  inactive, applies on reactivation, either intra-tick position
  (`ord_*_mapoff`/`ord_mapoff_*` pairs + WIP `mut_ord_kill_mapoff`/
  `mut_ord_mapoff_kill` both pass).
- **Left for boundary:** ≥3-setter permutations, `_physics_process`
  callsite × order, node-authored link property sequences,
  `link_set_start_position` mid-window.

## (3) `map_force_update` reach — measured; the WIP `mut_force_link` pin is falsified

API present in this build (`map_force_update`; `map_get_use_async_iterations`
reports `async_iter=true` default — its toggle moves the link edge 2→1,
`async_off` arm, so the window's +1 is async-iteration latency).

| call site | object getters | `map_get_iteration_id` | served tuple (agent forcing read) |
|---|---|---|---|
| fu same-tick as write (`fu_link0`, `fu_region0`) | **fresh in-turn** — `link_get_enabled=false`/`link_iter`→2, `region_get_transform` origin +5x | **unchanged** (stays 2) | stale at +0; fresh at **+1** (link, was 2) / **+2** (region, was 3) — serve edge advances exactly 1 frame |
| fu at +1 mid-window (`fu_link1`) | fresh | **bumps in-turn** 2→3 | **fresh same-turn** — forcing call re-queries on the bumped iter; residual edge collapses to 0 |
| fu alone (`fu_idle`) | — | **no bump** (2→2) | unchanged — fu is not itself an iteration |
| fu under inactive map (`fu_inact`) | object truth applies (`link_en=false`) while inactive | frozen at 2 | committed tuple keeps serving; fresh at +3f post-reactivation — fu does **not** re-arm sync on an inactive map |

**Flag for the round:** the WIP `mut_force_link` arm pins stale serve at
w1 (`final=(2.5,0,5.5)` bridge tuple on the `{wait:1}` step) under the
comment "the served-path edge is unmoved (mut_force_link vs
mut_force_ctl)". That pin **fails on this build** — receipt
`runs/wip_mut_force_link.stdout.txt` exit 1, stderr
`mut_force_link step1 final=2.500000,0.000000,4.000000 expected=2.500000,0.000000,5.500000`.
The control `mut_force_ctl` (no fu) passes with the identical ladder —
so the ONLY delta between the two arms is the fu call, and the engine's
answer is: **fu collapses the link serve edge 2→1, not 0** (stale w0,
fresh w1). My independent probe `fu_link0` measured the same before I saw
the WIP (`runs/fu_link0.stdout.txt`: f0 stale iter=2, f1 fresh iter=3).
The fix is a one-tuple edit: `mut_force_link`'s `wait:1` step should pin
the fresh clamp `[S,(2,0,1),(2.5,0,4.0)]` `final=(2.5,0,4.0)`
`reachable=false` — which makes the arm *stronger*: it pins that fu
measurably accelerates the serve edge rather than leaves it. The
`peek_path` stale array + `srv_get link_iter=2` pins on that step still
hold (the two-stage timing is untouched). r76-critic `bb_fu` sampled w0
(stale — agrees) and w2 (fresh — consistent); the +1 resolution is new.

## (4) Wait-ladder verdict-groups receipt — landed shape verified

What landed (WIP): cfg key `ladder: {"bound":N, "groups":M}`; signature
`_tuple_sig` (:2030-2036) = `idx|next|final|dist|reachable,reached,
finished|path` per served step — the same tuple field set I used; the
assertion in `_run_motion_arm` (:2423-2446) recomputes the partition from
`states` and appends ` bound=%d groups=%d sizes=%s` to the PASS line
**only when the arm sets `ladder`** — all 163 prior markers byte-stable
(they never set the key). Landed receipts pass on the snapshot:

- `mut_ladder_link` → `bound=2 groups=2 sizes=2,2` (4 samples, edge=2)
- `mut_ladder_region` → `bound=3 groups=2 sizes=3,2` (5 samples, edge=3)

My probe's equivalent runs agree: `ladder_link GROUPS 0-1|2-4`,
`ladder_region GROUPS 0-2|3-4`, `ladder_mapoff GROUPS 0-5` (single group —
the no-edge literal), `async_off GROUPS 0|1-3`. Watch-outs that hold for
any future ladder arm: a moving stale regime (e.g. `mut_win_link`'s
tp-then-mutate) fragments signatures into singletons — the clean 2-group
partition needs the stationary-agent shape; and `peek_*` captures inside a
group may differ from the served tuple (`ladder_link:pre2` pure shows the
stale array while iter already read 3) — the landed signature is on the
forced tuple, which is the right choice.

## CASES-surface check vs the landed WIP rows

All 10 added rows were executed against the WIP snapshot
(`runs/wip_*.stdout.txt`, snapshot `a967f012…9664`):

| row | run | my independent constants agree? |
|---|---|---|
| `mut_ord_renew_xform` | PASS | yes — fixture order moved `[(5,0,0.5),(5,0,1.0)]` |
| `mut_ord_xform_renew` | PASS | yes — reverse order home tuple (doomed-RID void) |
| `mut_ord_link_offmv` / `mut_ord_link_mvoff` | PASS both | yes — identical dead clamp either order |
| `mut_ord_kill_mapoff` / `mut_ord_mapoff_kill` | PASS both | yes — converge, reactivation replays the 2f edge |
| `mut_force_ctl` | PASS | yes — unforced ladder stale w0/w1 fresh w2 |
| `mut_force_link` | **FAIL** step1 | no — engine serves fresh at w1; see §3 |
| `mut_ladder_link` / `mut_ladder_region` | PASS both | yes — `sizes=2,2`/`3,2` = `0-1|2-3`/`0-2|3-4` |

Prior 163 rows: untouched by my work; the WIP diff to `run_battery.py` is
pure addition (inserted after `mut_same_agent` :210, before
`remote3d_transform`).

## Confidence and remaining unknowns

- **High (measured):** order load-bearing exactly at RID lifecycle — 4
  divergent pairs, 6 convergent pairs; recreate's identity-defaults reset
  is the mechanism; field setters commute; `map_active` interleave inert;
  mid-window freeze banks progress (edge −k for k elapsed frames);
  fu semantics per §3 incl. the falsified w1 pin; async-iteration toggle
  moves link edge 2→1; landed `ladder` receipt shape verified
  byte-stable-compatible.
- **Inference/medium:** internal reason fu@-0 advances the edge one frame
  (command-queue pre-stage vs partial drain); region's residual +1 vs
  link — timing evidence only.
- **Unknown (unprobed, flagged for boundary/critic):** ≥3-setter
  permutations; `_physics_process` callsite × order; node-authored link
  sequences; `link_start`/`link_end` mid-window; fu under
  `use_async_iterations(false)`; fu mid-window on a *region* write (only
  link measured at +1).
- The seam claim is doubly satisfied: order-pairs diverge (lifecycle) AND
  the composed {agent_layers:2,region_layers:2} dict serves a live path
  neither setter alone produces.

Evidence: `corpus/live/r77-scout/runs/*` (32 probe runs + 10 WIP-arm runs,
WIP `mut_force_link` the only non-zero exit — the falsification receipt),
probe `corpus/live/r77-scout/proj/r77s_applyorder.gd`, WIP snapshot
`proj/navagent3d_detour_wip.gd`, runner `run_arms.sh`. Priors reconciled:
r76-critic `bb_fu` (under-resolved at +1, not contradicted), r76-boundary
`mw_samekey_*`/`mw_sameturn_*`/`ma_off_*`, landed `mut_win_*`/`mut_map_*`
constants reproduced on this host. Leaf — no dispatch, no tracked edits,
no commits.
