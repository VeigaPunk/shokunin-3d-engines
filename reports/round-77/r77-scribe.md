# game-dev-3d round 77 — scribe report (seat: scribe, host: devin)

Declared lane axis (from dispatch, verbatim): "pin mutation APPLY-ORDER as a
measured axis — `_apply_mutation`'s fixed order
(delete→recreate→transform→link→agent) is load-bearing or inert?
Hand-ordered same-tick setter sequences vs the fixture's fixed order (e.g.
region_transform-then-delete vs delete-then-recreate; link_disable+
endpoint_move in both orders): does apply-order change the post-sync served
state? Declared falsifiable claim: at least one order-pair produces
observable distinct served state (a composed same-tick mutation is the
'seam' analog — emergent state neither setter alone produces); if all
order-pairs converge, order is provably inert under this build. Additionally
land a `map_force_update` CASES arm (does it collapse only the object-getter
edge, or the serve edge too?) and a wait-ladder verdict-groups receipt
(post-mutation tuple partitioned by identical signature → window bound
derived as partition boundary). All 163 prior rows byte-stable."

Scribe duty per brief: independently re-run the author's landed arms under
`corpus/live/r77-scribe/` — own geometry, own harness — verify or falsify
the apply-order claim, `map_force_update` reach, and the ladder-group
receipt; draft the lesson (`corpus/lessons/r77-*` convention) + LOG.md
entry. Report-only; not the judge. Leaf lane: no subagents, no commits, no
tracked writes outside this report.

Canonical repo `~/Projects/shokunin/game-dev-3d-shokunin` (the brief's
`~/Projects/prymeagnt/game-dev-3d` is the stale worktree — its
`.shokunin/game-dev-3d` symlink resolves here; same finding as r75/r76).
Engine `/usr/bin/godot` = `4.7.2.stable.arch_linux.ed1daf0bf`, Python
3.14.7, Node v24.21.0, three.js 0.186.1, 60 tps pinned
(`corpus/fixtures/project.godot` sha256
`1fda90d46b0529aea0e75710a64f038cbf983adc8385285dd8bbe6202a8eac23`).

## Landed-state timeline — I measured BOTH versions of `mut_force_link`

The author diff grew mid-round in the live working tree; this seat snapshotted
and replayed twice:

| snapshot | sha256 (`navagent3d_detour.gd`) | `mut_force_link` shape | my replay |
|---|---|---|---|
| v1 pre-amendment | `a967f0123597c56ae40c330fc7f124a7dcd194991bcf6bd1e0ec427e9f9d6664` (`author-replay/proj/`) | pins **w1 stale** serve (bridge tuple `final=(2.5,0,5.5)`) | **6/8 exit 1** — see §(3) |
| v2 committed `35dfbe2` | `fa4eb04af0387ac27c1bc4ec9aa782613e8b911da8b7a991852dc5ccb8832e77` (`author-replay-v2/proj/`) | pins **w0 stale + w3 fresh**, skips jittered w1 | **6/6 exit 0** (`fl_v2_r*.out`) |

Post-amendment hygiene `565318c` ("force-update serve-edge comment
corrected per-class — link jittered {1,2} vs region deterministic 3f->2f")
is **comment-only** (zero non-comment diff lines): current HEAD fixture
`9c50ff2f5242ee3e744f159299da6738487925fefb239cb9aa51dfcab9d0d344` is
execution-identical to `fa4eb04a` — my battery and v2 replays cover the
committed behavior.

Work commit `35dfbe2fa9c841048da3351f62fcfa97c8fa28a7` ("r77: mutation
apply-order CASES — doomed-RID divergence load-bearing, surviving pairs
inert; map_force_update getter-edge collapse + jittered serve boundary
{1,2}; wait-ladder verdict-groups; 163->173") landed the fixture
(+502/−33), `run_battery.py` (+20/−0, `sha256 92c5ad87df04d8ed247ced3b83d06d0e384e28fbaef0b22a161f280deb64b661`),
and five sibling reports; it also records the `seeds_unchanged=False` blip
from the author's own mid-run seed amend — superseded receipt, not a leak
(see r77-author.md).

## Own measured evidence — "dock-and-raft" geometry (deliberately unlike all siblings)

Probe `corpus/live/r77-scribe/scratch/r77s_order.gd` sha256
`1a9e86186447f430f354097c1f72e1671b97677c245fbc19d1435dbf42855824`,
extends-SceneTree, verbatim `project.godot` copy. **Distinct geometry** —
author/scout/boundary all reuse the r70 L-corridor + island C + link
`(2.5,0,3.5)→(2.5,0,5.5)`; r76-scribe used shelf-hop:

- RD "dock" region quad `x[0,4]z[0,4]`; RR "raft" region quad
  `x[6,10]z[6,10]`; void band between them. Server link L
  `(3.2,0,3.2)→(6.8,0,6.8)` bidirectional layers=1 is the ONLY route.
- `S=(1,0,1)` on dock → `T=(9,0,9)` on raft; committed path
  `[(1,0,1),(3.2,0,3.2),(6.8,0,6.8),(9,0,9)]`, base signature `d5dcde5c1f40`.

Ops implemented (arbitrary in-line order at t0): `del` (free dock RID),
`rec` (recreate dock on same map+mesh), `xf` (`region_set_transform` +6x),
`dis`/`en` (`link_set_enabled`), `mv` (endpoints→(1,0,3.5)/(9.2,0,9.2)),
`ag2` (`agent.navigation_layers=2`), `moff`/`mon` (`map_set_active`),
`fu` (`map_force_update`). Two read protocols, and the distinction turned
out to be load-bearing:

- **fresh-rung** (`ord_*`, `lad_*`, `fu_*`, `pre_moff_*`, `dbl_*`): fresh
  process per (seq,n) rung — mutate at t0, await n `physics_frame`s, one
  (or `dbl_` = two back-to-back) forced reads + `peek` + server truths.
- **cumulative** (`cuml_*`): one process, forced read every frame n=0..5 —
  matches the fixture's per-step sampling where every intermediate wait
  step performs a forcing read.

Runner `run_arms.sh` sha256 `a17f81260a0a428c32a9d0ec9b42182c79b24faf6531341d10ff741e798e3568`;
grouping `group_ladder.py` sha256
`a75fbe2bfbc38d9a86a088f1d598c8a8b5a9453fc08587b96bb2a2b1e7a4264f`.
**195 probe run receipts under `corpus/live/r77-scribe/runs/`** — all 172
captured `.exit` files = 0 (the 23 `cuml_*`/`dbl_*`/`smoke` runs launched
inline exited 0 in-session), every `.stderr.txt` byte-empty.
Repeatability triples `rep_{a,b,c}_{dis_n1,dis_n2,xf_n2,xf_n3,del_rec_n3,
rec_del_n3}` are **byte-identical** across all six rungs.

## (1) Apply-order — CONFIRMED load-bearing, exactly at RID lifecycle; pairwise

Divergent pairs on my geometry (fresh-rung, per-rung tuple signature):

| pair | divergent rungs | mechanism |
|---|---|---|
| `rec,xf` vs `xf,rec` | n=5 (and every post-settle rung) | `rec,xf` (fixture order) → `sig 5a32a2ec8f1c`, path `[(6,0,1),(9,0,4)]` reach=false — the +6x **lands on the recreated dock**; `xf,rec` → `sig d5dcde5c1f40`, original 4-pt bridge restored — the +6x **died with the doomed RID** |
| `del,rec` vs `rec,del` | n=4+ | `del,rec` → transient then **restored** bridge (`mapiter` bumps twice: 3 at f2, 4 at f4); `rec,del` → dock permanently gone, raft-clamp `[(6,0,6),(9,0,9)]` from f2 forever |
| `del,rec,xf` vs `xf,del,rec` (triple) | n=5 | same RID-rebinding split — order composes pairwise, no extra global effect observed on this triple |
| `xf,del` vs `del,xf` | none | both net "dock gone" — a write on a freed-later RID is voided either way |

Convergent pairs (identical signature at every rung): `dis,mv`/`mv,dis`
(link disable × endpoint move — dead dock clamp `[(1,0,1),(4,0,4)]`
reach=false either order, sig `8a146eef6405`), `en,mv`/`mv,en`,
`ag2,dis`/`dis,ag2` (agent channel — synchronous same-turn `[]` clear both
orders, sig `30e4c27ab9d8`), `dis,moff`/`moff,dis` (committed tuple frozen
under `mapact=false` either order), `pre_moff` `dis,mon`/`mon,dis`
(post-reactivation dead clamp identical).

The **transient seam** (the brief's "emergent state neither setter alone
produces"): every sequence containing both `del` and `rec` serves a THIRD
signature — `8482e0f42d41`, raft-only path `[(6,0,6),(9,0,9)]`
reach=true — for exactly two frames (f2–f3) before the recreated dock's
mesh publishes at f4 (second `mapiter` bump). On my two-region geometry the
transient is a reachable raft route; boundary's single-region geometry
serves `[]` for the same window — same mechanism, geometry-shaped
signature. `del` alone = `free_rid` class edge **2** (stays gone); `rec`
alone = the same transient-then-restore (my `rec` op is free+create
internally).

**Verdict:** the declared claim CONFIRMED — apply-order is load-bearing —
but operation-dependent, not universal: divergence needs a write ordered
relative to a RID lifecycle op that frees/recreates the RID it targets
(doomed-RID voiding / new-generation binding). Field-level pairs on
surviving objects coalesce and commute; `map_active` swallows its
co-queued set in either position. Matches the author's tracked arms
(`mut_ord_renew_xform` vs `mut_ord_xform_renew`, committed
`navagent3d_detour.gd:1690–1716`) and boundary's six-permutation triple
result (three outcome classes from one multiset; order **pairwise**).

## (2) `map_force_update` — collapses the SETTER stage; the serve edge is mark-then-phase, jittered {1,2}

Existence smoke `scratch/smoke.gd` (sha256 `5584d085…`, `runs/smoke.stdout.txt`
exit 0): `map_force_update(map)` callable; `map_set_active(true)` read back
`false` same-turn (the activation getter itself is deferred ≥1f);
end-of-run RID-leak warnings are probe hygiene (no teardown), not a fixture
result.

Stage model that fits every row below (names from boundary's two-stage
find): **S** = queued setter applied to the server object (object getters
+ object iteration stamp flip); **P** = the map-iteration bump
(`map_get_iteration_id`) that publishes dirty to agents — the serve edge is
the first forcing read after P. Unforced: S lands at the class's getter
edge (link f1; region value f1, regiter f2), P at the r76 edges (link f2,
region f3).

Cumulative protocol (read every frame — the fixture's shape):

| seq | n=0 | n=1 | n=2 | n=3 | serve edge |
|---|---|---|---|---|---|
| `dis` | stale, linkiter=1 | stale, **linkiter=2** (S) | **fresh**, mapiter=3 (P) | fresh | 2 |
| `dis,fu` | stale, **linkiter=2 (S at w0)** | **fresh, mapiter=3** | fresh | fresh | **1** |
| `xf` | stale, regx=0 | stale, regx=6 (value) | stale, regiter=2 | **fresh**, mapiter=3 | 3 |
| `xf,fu` | stale, **regx=6 at w0** | stale, regiter=2 | **fresh**, mapiter=3 | fresh | **2** |
| `del,rec` | stale, regiter=0 | stale | transient `8482…`, mapiter=3 | transient | restored at n=4, mapiter=4 |
| `rec,del` | stale, **regvalid=false at w0** | stale | raft-clamp, mapiter=3 | raft-clamp | 2 (permanent) |

Fresh-rung protocol (one read per process):

| seq | edge |
|---|---|
| `dis` | 2 (`{0,1}|{2,3,4,5}`) — same as cumulative |
| `dis,fu` | **2** (`{0,1}|{2,3}`) — UNCHANGED by FU |
| `xf` | 3 (`{0,1,2}|{3,4,5}`) |
| `xf,fu` | **3** — UNCHANGED by FU |
| `pre=moff dis,fu` | **none** — `groups=1`, stale through n=4 (FU on an inactive map: `linken=false`,`linkiter=2` applied to the object, `mapiter` frozen at 2, committed tuple served) |

Double-read controls (`dbl_dis_fu_n{0,1,2}`): two forcing reads in one
rung — the second read in the same frame does NOT flip; identical tuples.
`fu,dis` ordering (`fu_fu_dis_*`: FU before the write) — no special effect;
edge still 2.

**Resolution of the fresh-vs-cumulative split:** FU drains stage S to the
same turn (deterministic — linkiter/regx/`linken` applied at w0). Stage P
then lands on the next *scheduled* sync phase — and what makes it land one
frame early is a forcing read having *detected* the stamped dirty and
marked the map: with a w0 read in the pipeline (cumulative, or any
read-every-frame caller), P lands at f1 for link (edge 2→1) and f2 for
region (edge 3→2); under a single-read-per-rung probe nothing marks early
and P lands at the unforced cadence (edges unchanged). The mark-vs-phase
race explains the tracked-arm jitter: whether the w0 read's mark beats the
f1 sync phase is workload-sensitive — my light cuml probe: **5/5 edge 1**
(`cuml_rep{1..5}_dis_fu`); the pre-amendment tracked arm: **6/8 of my reps
served fresh at w1** (rep1,2,5,6,7,8 exit 1; rep3,4 exit 0), and boundary's
v1-arm replays went 13/15 exit 1 the same way — while boundary's
`fu_w0_only` sequence under their tracked-step emulation landed w2 in
13/15. Same race, harness-weight-dependent bias.
So: **FU does not collapse the serve edge to 0 and does not leave it
fixed — it makes the boundary phase-dependent {1,2} on the link class**;
the critic's per-class correction (committed as hygiene `565318c`) splits
the result — **link jittered {1,2}, region deterministic 3f→2f** (9/9
critic reps; my `cuml_rep{1..4}_xf_fu` all edge 2, zero variance). Mid-window FU
(boundary `fu_mid`) collapses the residual to 0; FU under `map_set_active
(false)` (my `fu_moff_*`, boundary `fu_off_queue`) applies S but leaves
serve frozen. Sibling scout adds `map_get_use_async_iterations` = true
default, and async-off moves the link edge 2→1 — the +1 being
async-iteration latency; consistent with the two-stage reading.

**Answer to the brief's question:** `map_force_update` collapses the
object-getter edge (S to same-turn) — and pulls the serve edge in by one
frame *only via* a prior forcing read marking the dirty; the boundary
becomes a phase race, not a constant. On an inactive map it is a
setter-stage-only no-op for serve.

## (3) Author-arm replay — v1 falsified the w1 pin (converged, not contradicted); v2 clean

All 10 r77 arms replayed from `author-replay/proj/` (v1 snapshot) and the
committed fixture (v2). On v1, 9/10 arms pass byte-exact markers;
`mut_force_link` failed **6/8** isolated runs, all with the same line:
`step1 final=2.500000,0.000000,4.000000 expected=2.500000,0.000000,5.500000`
(receipts `author-replay/runs/rep{1..8}_mut_force_link.{stdout,stderr}.txt`;
control `mut_force_ctl` exit 0 every rep). The author's own report records
the identical first-battery failure and 2/5 standalone fails before the
amendment — three independent measurements (author 2/5 standalone fails,
boundary 13/15 fails, this seat 6/8 fails — all at the same step1
w1-fresh-vs-stale-pinned mismatch) converge: the v1 pin was a race, not a
deterministic row. The committed v2 arm (`navagent3d_detour.gd:1849–1872`) drops the w1
sample and pins only `w0 {srv_get link_en=false,link_iter=2 + stale serve}`
+ `w3 fresh clamp`; my 6/6 v2 replays exit 0, marker byte-identical to
CASES: `steps=2 idxs=1,1 next=2.000000,0.000000,1.000000
final=2.500000,0.000000,4.000000 … reachable=false`.

Arm-by-arm agreement vs committed CASES (`run_battery.py:212–231`):
`mut_ord_renew_xform`/`mut_ord_xform_renew` markers verbatim (moved-region
`(5,0,0.5)` clamp vs restored corridor), `mut_ord_link_*` dead-clamp pair
identical, `mut_ord_{kill_mapoff,mapoff_kill}` identical frozen-map tuples,
`mut_ladder_link`/`mut_ladder_region` emit `bound=2 groups=2 sizes=2,2` /
`bound=3 groups=2 sizes=3,2`. All 10/10 pass on `35dfbe2`.

## (4) Wait-ladder verdict groups — receipt verified independently

`group_ladder.py` partitions consecutive same-signature rungs (sig =
sha256-12 of `idx|next|final|dist|reach|path`), bound = first index whose
sig differs from n=0. My ladders:

- `dis`: `{0,1}:d5dc… | {2,3,4,5}:8a14…` → **bound 2** (r76 link class)
- `xf`: `{0,1,2}:d5dc… | {3,4,5}:5a32…` → **bound 3** (r76 region class)
- `mv`: `{0,1} | {2,3,4,5}` → bound 2 (link class via endpoint move)
- `del`: `{0,1} | {2..5}` → bound 2 (free_rid class)
- `rec`/`del,rec`: **three** groups `{0,1} | {2,3} | {4..6}` — bound 2 plus
  the f4 restore — the partition surfaces the transient seam as its own
  group, exactly the "verdict groups" the brief asked the receipt to be.
- `pre=moff dis,fu`: `groups=1` — the no-edge literal (map-off permanent
  stale), matching boundary's `ladder_mapoff` single group.

The committed `ladder` cfg (`{"bound":N,"groups":M}`,
`_run_motion_arm` :2351+, `_tuple_sig` :2031) derives the bound from the
partition rather than hand-pinning the edge — verified shape: link
`bound=2 groups=2 sizes=2,2`, region `bound=3 groups=2 sizes=3,2` (r76
{link:2, region:3} re-derived).

## (5) Byte-stability, battery, Node — committed-state receipts

- **Prior rows:** `git diff e417365 35dfbe2 -- run_battery.py` = pure
  addition (20 lines, 10 CASES tuples, `run_battery.py:212–231`) — all 163
  prior expected strings byte-identical by construction. Executed check:
  my battery verdicts' recorded `marker` fields vs both r76 receipts —
  `corpus/live/r76-verifier/runs/20261014T102343921913Z/verdicts.json` and
  `corpus/live/r76-author/runs/battery/20261014T101410997458Z/verdicts.json`
  — **163/163 common cases, 0 marker diffs**; new set = exactly the 10 r77
  rows.
- **Full battery** (ran at 11:28Z on the live tree already carrying the
  amended fixture — the verdicts record `mut_force_link steps=2`, the v2
  shape):
  `python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot --runs
  <abs>/corpus/live/r77-scribe/runs-battery --probe-failing
  --probe-crash-exit --probe-stream-attribution --probe-tree-timeout` →
  `BATTERY EXIT=0`, `totals: cases=173 pass=173 fail=0 ordinary=128
  negative_controls=45 probes=4`, `seeds_unchanged: true`. Receipt
  `corpus/live/r77-scribe/runs-battery/20261014T112801071019Z/verdicts.json`;
  log `battery-full.log`.
- **Node:** six frozen-tree suites under `corpus/live/r77-scribe/node/` —
  cases 3/3, layer 4/4, order 9/9, camera 5/5, ortho 5/5, ray 5/5 →
  **31/31**, `seedsUnchanged: true` in every `run_*.json`.
- Repeatability: `rep_{a,b,c}` triples byte-identical; committed
  `mut_force_link` 6/6 exit 0.

## Cross-seat convergence map

| claim | author | scout | boundary | this seat |
|---|---|---|---|---|
| order load-bearing at RID lifecycle | CONFIRMED (tracked pair) | 4 divergent pairs + interaction matrix | CONFIRMED 3-way (6 perms, triple outcome classes) | CONFIRMED (4 divergent pairs incl. triple) |
| surviving-field / map-off / agent pairs inert | convergent | convergent | convergent | convergent |
| FU collapses getter edge only | pinned w0 + jittered {1,2} serve | edge advances 1 frame (cumulative) | two-stage model + mid-window collapse to 0 | getter@w0; serve {1,2} phase-race; mark mechanism |
| v1 `mut_force_link` pin | failed 2/5 → amended | FAIL on WIP snapshot | 2/15 exit0 pre-amend | **6/8 FAIL** |
| ladder groups | bound 2/3 landed | shape verified | single-group map-off | independent partition + 3-group seam |

## Draft: `corpus/lessons/r77-mutation-apply-order.md`

```markdown
# R77 — same-tick mutation APPLY-ORDER is load-bearing exactly at RID lifecycle; map_force_update drains the setter stage and phase-jitters the serve edge

## Decision and evidence

Under Godot 4.7.2.stable headless 60 tps, same-tick NavigationServer3D
setter sequences are order-sensitive **pairwise**, and only through two
mechanisms:

1. **RID-rebinding adjacency (load-bearing).** A write ordered before a
   `free_rid`/recreate of its target RID is silently voided (doomed-RID);
   ordered after, it lands on the new generation. Fixture-fixed
   `{delete,recreate}→transform` moves the recreated region (served
   `(5,0,0.5)` clamp, `mut_ord_renew_xform`); hand-ordered
   `transform→{delete,recreate}` restores the identity-region corridor
   (`mut_ord_xform_renew`) — the transform died with the freed RID.
   `recreate→delete` is fatal (net "no region"). Scribe own-geometry:
   `rec,xf` serves moved-region path vs `xf,rec` restored bridge;
   `del,rec` transient-then-restore (two mapiter bumps, f2+f4) vs `rec,del`
   permanently gone — THREE distinct post-sync states from one op multiset.
2. **Same-field last-wins.** Two writes to one field order by overwrite
   (boundary `Rx5,Rx03` vs `Rx03,Rx5`).

Everything else commutes: field×field on a live object coalesce in one
flush (`mut_ord_link_offmv` ≡ `mut_ord_link_mvoff` dead clamp); agent
`navigation_layers` clears synchronously either position; `map_active`
swallows its co-queued set either position (`mut_ord_kill_mapoff` ≡
`mut_ord_mapoff_kill`); cross-object writes land at per-class edges with
an order-inert +1 same-flush coupling. Boundary: all 6 permutations of a
cross-object triple converge; callsite (`_physics_process` vs coroutine)
shifts every edge −1 tick but leaves the order partition identical —
order matters identically, only the clock moves.

**The seam:** composed `delete+recreate` serves a transient THIRD state —
the absent-region path (empty `[]` on one-region geometry, surviving-region
clamp on two-region) — for ~2 frames between the free edge (f2) and the
recreated region's publish (f4, second mapiter bump). The verdict-group
partition exposes it: `del,rec` yields three groups {0,1}|{2,3}|{4..}, not
two.

## map_force_update — two stages, only the first is on-demand

- Stage S (setter apply → object getters + object iter): normally at the
  class getter edge (link f1, region value f1/iter f2). `map_force_update`
  runs it NOW — `srv_get` reads `link_en=false, link_iter=2` at w0
  (`mut_force_link` w0 pins vs `mut_force_ctl`'s still-queued `en=true,
  iter=1`).
- Stage P (map iteration bump → publish → serve): runs on the next
  scheduled sync phase, NOT on the force call. A forcing read that detects
  the stamped dirty marks the map; the republish lands next frame. So the
  forced serve edge is a phase race — measured **{1,2}** (light readers:
  edge 1; tracked-context: w2-biased ~80%+; fresh single-read rungs:
  unchanged {2,3}). FU mid-window (setter already drained) collapses the
  residual to 0; FU alone on an idle map is a no-op; FU on an inactive map
  applies S but leaves serve frozen.
- Tracked arm posture: pin w0 (S applied + stale serve) and w3 (fresh),
  never the jittered w1. The v1 w1-stale pin flaked on three independent
  rigs — falsified, amended, honest.

## Authoring consequences

- `mutate` may be an Array of dicts (applied in listed order through the
  unchanged fixed order) — the hand-order override; bare dict keeps
  delete→recreate→transform→link→agent→map_active.
- `srv_get` pins object-getter truth per step; `ladder:{bound,groups}`
  re-derives the window edge as a signature partition boundary (link
  `bound=2 sizes=2,2`, region `bound=3 sizes=3,2`).
- A moving stale regime fragments signatures into singletons — ladder arms
  need the stationary-agent shape.
- Never pin a jittered boundary: a CASES row whose edge is phase-dependent
  must pin around the race (w0/w3), not through it (w1).
```

## Draft: LOG.md round-77 entry

    ## Round 77 — devin host — mutation APPLY-ORDER pinned: doomed-RID divergence load-bearing, surviving pairs inert; map_force_update getter-collapse + jittered serve edge {1,2}; wait-ladder verdict groups
    - Declared (dispatch brief): is `_apply_mutation`'s fixed order
      (delete→recreate→transform→link→agent) load-bearing or inert;
      hand-ordered same-tick sequences vs fixed order; a map_force_update
      CASES arm; a wait-ladder verdict-groups receipt; 163 prior rows
      byte-stable. Claim: at least one order-pair produces observable
      distinct served state; else order provably inert.
    - Wave `shokunin-train-20261014-w8`: leaf reports
      reports/round-77/r77-{author,baseline,boundary,reviewer,scout,
      scribe}.md; work commit `35dfbe2` (navagent3d_detour.gd +502/−33 →
      2460 lines; run_battery.py +20/−0 → 173 rows; array-mutate, srv_get,
      map_force key, _tuple_sig, ladder partition).
    - Result — claim CONFIRMED, scoped: order is load-bearing exactly at
      RID-lifecycle adjacency (doomed-RID voiding + new-generation binding;
      `mut_ord_renew_xform` vs `mut_ord_xform_renew` diverge; del,rec vs
      rec,del → transient-restore vs permanent-loss three-way split) and
      same-field last-wins; all field-level, agent-channel and map-off
      pairs converge — order is pairwise, callsite-invariant (boundary:
      physics callsite shifts every edge −1, partition untouched).
      Composed delete+recreate exposes a 2-frame transient served state —
      the seam analog.
    - map_force_update: drains the setter stage to same-turn (getter edge
      1→0 pinned via srv_get); the serve edge is mark-then-scheduled-phase —
      boundary {1,2} jittered under force (tracked arm pins w0+w3 after
      the v1 w1-pin flaked on three independent rigs), collapses to 0
      mid-window, inert on inactive maps.
    - Wait-ladder verdict groups landed: served-tuple signature partition
      derives the bound (link bound=2 sizes=2,2; region bound=3 sizes=3,2 —
      the r76 edges re-derived; scribe partition independently yields
      {dis:2, xf:3, mv:2, del:2, rec:3-group seam}).
    - Scribe independent replay: distinct dock-and-raft geometry (~150
      probe runs, all exit 0, stderr empty, rep triples byte-identical);
      all 10 committed arms byte-exact; v1 arm flake reproduced 6/8
      (converged with author's own fix); full battery 173/173 + 4 probes +
      seeds_unchanged; 163 prior markers 0 diffs vs r76-verifier and
      r76-author receipts; Node 31/31.

## Residual risks / recheck conditions

- The forced serve boundary {1,2} is a host/build phase race; if a
  deterministic w1 pin is ever wanted, the sync phase must be instrumented
  (or use a mid-window second force — boundary `fu_w0_w1` — to drain P).
- Async-iteration default (`map_get_use_async_iterations` = true) carries
  part of the window constants — scout's `async_off` moves link 2→1; a
  build switching defaults would shift every pinned edge.
- All bounds are this-build / this-callsite-class / teleport-spawn
  measured; not a cross-version claim.
