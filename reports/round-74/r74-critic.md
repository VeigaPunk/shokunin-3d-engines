# game-dev-3d round 74 — critic (seat: critic, host: devin)

Scope of attack: the declared axis-move — MOVING-AGENT NavigationAgent3D
semantics as tracked CASES arms: (a) stored path array FROZEN at
target-assignment, locomotion never re-queries, distance_to_target /
next_target stay live call-time arithmetic; (b) pop index follows live
agent position per the strict-< Euclidean rule on the stale stored path;
(c) reached/finished latch under motion (or measure the unlatch
condition); (d) target_position re-assignment re-queries from the agent's
LIVE position (nearest-bank re-anchor per r73-boundary).

Author status at review cutoff: NOT LANDED — `git status` on the canonical
tree shows no fixture diff (`corpus/fixtures/navagent3d_detour.gd` mtime
2026-10-13 22:54, unchanged); the author's bounded spike is in flight at
`corpus/live/r74-author/scratch/navagent3d_motion_probe.gd` with ~20 probe
runs under `corpus/live/r74-author/runs/` but no tracked CASES arms and no
`r74-author.md` yet. Per the brief ("poll; else build own moving-agent
scratch fixture") I built an independent probe and ran every attack.

Probe: `corpus/live/r74-critic/scratch/r74c_motion.gd` (sha256
`3918f7b8758f2374a74da7b9d877ed230ee7e94fc1f21aeecb5fde404c31d7f4`),
extends-SceneTree driver on the verbatim committed `project.godot`
(sha256 `1fda90d4…8eac23`), same L-corridor (A1/A2/B) + optional island C
+ server link. Godot `4.7.2.stable.arch_linux.ed1daf0bf` via
`/usr/bin/godot --headless`; 60 tps; cell_size 0.25. 40 arm runs + 4
repeat runs, all exit 0, all stderr banner-only; `fw_walk` and
`fb_set_tp_pure` repeats byte-identical. Receipts:
`corpus/live/r74-critic/runs/<arm>.{stdout,stderr,exit}`.

Command shape per arm:

    godot --headless --path corpus/live/r74-critic/scratch \
        --script res://r74c_motion.gd -- --arm=<name> \
        [--geo=corridor|bridge --link=server --spawn=x,z --target=x,z \
         --pdd=F --tdd=F --settle=N --avoid]

The probe deliberately separates *pure stale reads*
(`get_current_navigation_path`, `get_current_navigation_path_index`)
from forcing calls and interleaves them against same-turn teleports so
that call-time vs tick-time evaluation is observable.

## Headline finding: the agent is fully LAZY — nothing runs on physics ticks

This reframes every clause's timing semantics:

- `probe_lazy_s1/s3/s30` (`runs/probe_lazy_s*.stdout.txt`): after
  `target_position` set + 1/3/**30** pure physics ticks with zero getter
  calls, `get_current_navigation_path()` returns `[]` and idx 0 — the
  **initial query never ran during the ticks**. The first forcing call
  runs it. The fixture's 30-frame settle exists for MAP sync (region/link
  joining the map iteration), not for agent state — a static arm's
  observed path is materialized by the read itself.
- `pop_tick_only`: teleport within pdd of `path[1]`, 3 pure ticks, zero
  calls → `idx_pre=1` (no pop); the next `get_next_path_position()` pops
  to 2 **inside the call**. Ticks never pop.
- Setter/query/getter split, measured per call (`pop_attr`, `pop_attr2`,
  `fb_attr`, `fb_attr_reach`):
  - **forcing calls** (run the deferred update — requery-if-dirty, pop
    eval, flag eval): `get_next_path_position`, `get_final_position`,
    `is_navigation_finished`, `is_target_reachable`.
  - **non-forcing**: `distance_to_target` (pure live euclid),
    `is_target_reached` (returns the STORED flag — can be stale),
    `get_current_navigation_path` / `get_current_navigation_path_index`
    (return the stored/stale array+index without consuming dirty).
- `set_target_position` synchronously CLEARS the stored result (path=[],
  final=raw target) and marks dirty; idx is NOT cleared (stale value
  readable in the empty window — `ra_idx_pre`: `idx_pre=1 p_pre=[]`).

## Attack 1 — frozen path: TRUE under locomotion; invalidation triggers found; freeze-point mislabeled

Claim (a)'s load-bearing half survives every motion attack:

- `fw_walk` (12 stepwise teleports S→along corridor→adjacent to T + a
  return hop to S): stored path byte-identical every step
  (`pathsame=true` ×13), while `dist` tracks live euclid each step
  (3.605551 → 0.05 → 3.605551). `fw_walk_noget` (never calls get_next)
  same result. `fw_idle` 120 ticks: 0 path changes.
- `fw_walk_vel` / `fw_walk_vel_avoid` (`set_velocity` each tick, with and
  without `avoidance_enabled`): 0 path changes — the avoidance channel is
  inert w.r.t. the stored path (`velocity_api=true`).
- `fw_meta_mid`: `path_metadata_flags` flip mid-run leaves the stored
  path untouched and retro-fills companion arrays on the existing result
  (types `[0,0,0]`, 3 rids, 3 owners) — meta is presentation, not state.

But "FROZEN at target-assignment time" is wrong in both endpoints:

1. **Freeze-point is the first forcing call, not the assignment.**
   `fb_set_tp_pure`: `target_position=(2.9,0,3.9)` then teleport to
   M=(2.6,0,2.0) in the SAME turn, zero reads → posttick path is
   `[(2.6,0,2.0),(2.9,0,3.9)]` — anchored at the POST-teleport position.
   `fb_set_tp` (identical but flag getters between set and teleport):
   the same-turn getters force the query while the agent is still at S →
   path `[(0.5,0,0.5),(2,0,1),(2.9,0,3.9)]` anchored at S. The declared
   "re-queries from the agent's LIVE position" resolves to *live at
   update-run time*, not at assignment — a move inside the assignment
   frame shifts the anchor unless a forcing call lands first.
2. **Map edits and agent-side query-param setters invalidate it.**
   `fw_mapedit`: `region_set_transform(+5x)` mid-run → next forcing call
   re-queries: path becomes `[(5,0,0.5),(5,0,1.0)]`, reachable=false
   (clamp-to-moved-mesh), and `idx` visibly RESETS (pre=1 → post=0).
   `fw_layermask` (region layers→2 vs agent mask 1) → lazy requery →
   EMPTY path + `final=(0,0,0)` (the r73 empty-path third mode, produced
   here without touching the target). `fw_al_mid`
   (`agent.navigation_layers=2`) — same emptying via the agent-side
   setter: the stored path is cleared same-turn (dirty), `p_mid=[]`.
   `mapedit_lazy` proves the map-edit invalidation is LAZY: after the
   move + 5 ticks the pure `get_current_navigation_path()` still returns
   the OLD corridor coordinates (`p_pre=[(0.5,…)(2,0,1)(2.5,0,3.5)]`);
   the requery fires inside the next `get_next_path_position`.
   Inert on the stored path: `path_desired_distance` (fw_pdd_mid —
   pdd=4.0 does not clear; the new rule is applied to the STALE path at
   the next forcing call, idx 1→2 same array).

So the honest contract: **the stored path is stable under locomotion,
velocity, ticks and non-query setters; it is synchronously cleared by
`target_position`/`navigation_layers` assignment, and lazily invalidated
by map data changes — with materialization+anchor at the first forcing
call after invalidation.**

## Attack 2 — pop follows live position: call-driven, sequential, can't skip; freezes at finish

- Call-time pop confirmed: `pop_sf` same-turn teleport to (1.95,0,0.95)
  (euclid to path[1] = 0.0707 < pdd=1): pure-idx read shows 1, then
  `get_next_path_position` returns path[2] and idx reads 2 — the advance
  happened inside the call, no tick. `pop_callpop` identical.
- Which getter pops: `pop_attr`/`pop_attr2` interleave pure idx reads —
  `get_final_position` and `is_navigation_finished` each advance idx
  (j0=1 → fin() → j2=2); `is_target_reached`, `is_target_reachable`,
  `get_current_navigation_path`, `distance_to_target` do not pop… wait,
  see precise attribution: reachable pops only because it forces the
  update — in pop_attr2 order (reached → finished → reachable) it was
  `is_navigation_finished` that flipped idx 1→2.
- Hysteresis/no-skip: `pop_skip` — teleport to (2.4,0,3.2), 0.316 from
  the final but 2.236 from path[1]: idx stays 1, `next=(2,0,1)` points
  backward, AND `reached=true finished=true` (raw-euclid flags decoupled
  from the sequential idx). `pop_island` on the bridge at exact
  equidistance (2.5,0,4.5, pdd=1.0): strict-< → neither endpoint pops,
  idx=1, `next=(2,0,1)` across the void — the r73 retro-point hazard
  reproduces under pure motion (no retarget needed).
- Two teleports in one turn (`pop_two_tp` → A=(1.5,0,0.55) then
  B=(2.05,0,1.05)): only the LAST position is ever observed — pop sees
  B, idx→2. Intermediate positions inside a forcing-call gap are
  invisible.
- **Pop freezes under latched finish**: `pop_after_finish` — latch
  reached+finished at idx=1 (agent at (2.4,0,3.2)), then teleport within
  pdd of path[1] ((2.05,0,0.9), dist 0.11<1): idx stays `1/1`, next still
  backward `(2,0,1)` — once `finished` latches, the update gates off and
  idx cannot advance even though the strict-< condition is met.

## Attack 3 — latch: unlatch conditions measured; flags are sampled at forcing-call time

- Motion never unlatches: `lt_retarget_same_away:moved_away` (teleport
  from fg to S, euclid 2.5>tdd) keeps `reached=true finished=true`;
  `lt_unr_away:away` keeps the unreachable-clause `finished=true`.
  `lt_mapset` (re-register the SAME map): no reset, latch intact.
- **The unlatch trigger is `target_position` assignment — any
  assignment, value-change not required.** `lt_retarget_new` (retarget to
  a far target): `reached=false finished=false`, re-anchored path
  `[(2,0,3),(2,0,1),(0.5,0,0.5)]`. `lt_retarget_same_away`: re-assigning
  the IDENTICAL target after moving away → `reached=false
  finished=false`, path re-anchored at S `[S,(2,0,0),(2,0,1),(2,0,3)]` —
  identical-value re-set resets; there is no changed-value check.
- **Freeze-after-finish, sharper than a latch**: `lt_unr_away` latched
  `finished` via the unreachable clause with `reached=false`; teleporting
  adjacent to the raw target (dist 0.4 < tdd 1.4, `near_target`) leaves
  `reached=false` — reached is not independently live-checked post-finish;
  it is FROZEN at its then-value once finished latches. (r72's `fin_latch`
  arm can't see this — it finishes via the reached clause.)
- **`reachable` is NOT latched** — it re-evaluates per forcing call under
  the current tdd: `lt_tdd_shrink` latches reached+finished at tdd=1.6,
  shrink tdd to 0.1, force an update → `reachable` flips true→false
  (euclid(final,raw)=1.5>0.1) while `reached`/`finished` stay true. A
  three-valued divergence an arm could pin: live `dist`, mutable
  `reachable`, frozen `reached`/`finished`.
- **Flag sampling is call-time, so transients are invisible.**
  `lt_reach_transit`: teleport adjacent to T (euclid 0.3<1), 2 ticks,
  back to S, 3 ticks, read → `reached=false finished=false` — the near-T
  window was never sampled because no forcing call ran inside it.
  `lt_reach_sf` contrast: teleport adjacent, and a same-turn
  `is_navigation_finished()` call FORCES the eval at the near position →
  `f=true` fires and latches even though the agent is teleported back to
  S before the next tick.
- **Mid-window incoherence**: `flags_attr` — at the near position,
  same-turn `is_target_reached()` returns `false` (stale stored flag)
  while the immediately following `is_navigation_finished()` forces the
  update and returns `true`; the next `is_target_reached()` then reads
  `true`. So `reached=false ∧ finished=true` is observable mid-turn on a
  reachable target — the flag pair is NOT a coherent snapshot; read order
  inside a frame changes what an arm sees. Any tracked arm asserting
  `reached` after a scripted move must run a forcing call first or the
  read is stale.

## Attack 4 — frame-boundary: teleport between assignment and materialization moves the anchor

- `fb_set_tp` (set T2 → same-turn flag reads → teleport M → ticks):
  same-turn `path` reads `[]` right after the set (synchronous clear —
  the declared "frozen array" literally does not exist in the window),
  and the flag getters force the query at S → posttick path anchored S
  (`[S,(2,0,1),(2.9,0,3.9)]`).
- `fb_set_tp_pure` (set T2 → teleport M, NO reads): posttick anchor M
  (`[M,(2.9,0,3.9)]`, pathlen 1.923540) — the deferred query consumed the
  post-teleport position.
- `fb_tp_set` (teleport then set, same turn): anchor M —
  order-insensitive once the position is already M at set time.
- `fb_dist_sameframe`: `distance_to_target` returns live euclid same-turn
  post-teleport (1.503330 = euclid(M,T)) — pure arithmetic confirmed
  call-time, while `next` still serves the frozen stored waypoint
  (2,0,1).

So a "teleport mid-query-change" DOES behave differently from
"between queries" — the distinguishing variable is whether a forcing call
executed between the assignment and the move.

## Attack 5 — re-anchored path reachability recomputes (and the anchor lives on C)

- `ra_new`: teleport M mid-path, retarget (0.5,0,0.5) → path
  `[M,(2,0,1),S]` re-anchored at live pos, `reachable` recomputed true,
  idx reset (requery resets to 0 then re-pops; fw_mapedit's 1→0 is the
  clean reset witness).
- `ra_offmesh`: retarget to off-mesh (0.5,0,3.0) → path `[M,(2,0,3)]`,
  `final=(2,0,3)` clamped, `reachable=false` recomputed (not inherited),
  flags cleared.
- `ra_same_away`: teleport M, re-assign the IDENTICAL reachable target →
  fresh path `[M,T]` — assignment alone re-queries; no diff-check.
- `ra_island` (bridge+link): teleport onto island C (2.5,0,5.4) WITHOUT
  retarget → stored path stays the frozen mainland hop `[S,(2,0,1),ls,le]`
  (`pathsame=true`), next `(2,0,1)` still points backward across the
  void, and `reached`/`finished` latch at dist 0.1 — the pop-through
  retro-hazard composes with the latch under motion. Re-set the same
  island target → `[(2.5,0,5.4),(2.5,0,5.5)]`: C-side anchor, the link
  abandoned — the r73-boundary nearest-bank re-anchor confirmed as a
  moving-agent semantic.

## Verdict summary

| attack | result |
|---|---|
| (1) frozen-path / invalidation triggers | Substance CONFIRMED (0 path changes under 12-step walk + backstep, velocity_set ±avoidance, 120 idle ticks) — but "FROZEN at target-assignment time" is wrong twice: nothing is stored at assignment (sync-cleared empty window, lazy materialization) and the freeze point is the first forcing call, anchored at the position live THEN; map edits + `navigation_layers` lazily invalidate; pdd/tdd/meta do not |
| (2) pop follows live position | CONFIRMED with sharp edges: pop is call-driven inside forcing getters (ticks never pop — pop_tick_only), sequential and cannot skip (pop_skip: idx=1, next backward, reached+finished true at dist 0.316), last-position-only hysteresis (pop_two_tp), and idx FREEZES once finished latches (pop_after_finish) |
| (3) latch under motion | CONFIRMED; the measured unlatch condition is `target_position` assignment — including an identical value — not motion and not same-map re-set. Sharper: finished latching freezes reached mid-value (never fires at dist 0.4<tdd post-finish); reachable stays live under tdd changes; flag eval only happens inside forcing calls so transients are invisible and `reached` can read stale-false next to `finished=true` mid-turn |
| (4) frame-boundary | CONFIRMED differently than worded: the deferred query anchors at the position live at the first forcing call after assignment — a same-turn teleport between set and any read moves the anchor (fb_set_tp_pure → M) while a forcing call in between pins it at S (fb_set_tp). The dirty window (`path=[]`, stale idx, `final`=raw target) is directly observable |
| (5) re-anchored reachability | CONFIRMED: reachable recomputes fresh per requery (off-mesh retarget → false), idx resets to 0 at requery then re-pops, island-side anchor abandons the link (r73-boundary consistent) |

## Impacted axes

- **depth**: the four claims survive, but the model is sharper than the
  wording: fully lazy/call-driven agent; no tick-side evaluation at all;
  forcer/non-forcer getter split; freeze-point = first forcing call post-
  assignment, not assignment; sequential pop can't skip and freezes at
  finish; flags sampled at call time; unlatch = any target assignment;
  reachable live-recomputed.
- **coverage**: unpinned surfaces named for possible arms — the empty
  dirty window (`path=[]` + stale idx + `final=raw target`), the
  anchor-shift same-turn teleport, post-finish idx freeze,
  `reached=false ∧ finished=true` mid-window read, `reachable` flip under
  tdd shrink while latched, lazy map-edit invalidation (region move /
  layers flip / agent layers flip).
- **calibration**: the author's own spike logs show the same lazy window
  (`S0 … path=[]`) — independent convergence, good sign for the round;
  my battery stands as counterexample evidence only (author's tracked
  arms had not landed at cutoff, so no 127+N replay verdict exists yet).

## Smallest safe corrections (fixable wording; nothing measured blocks the move)

1. Header/claim (a): "stored path array is FROZEN at target-assignment
   time" → "cleared at assignment, materialized at the first forcing
   call (get_next_path_position / get_final_position / is_target_reachable /
   is_navigation_finished), anchored at the position live then; stable
   under locomotion, velocity, ticks, and non-query setters". One line;
   prevents readers expecting assignment-time stamping.
2. Arms that assert `reached`/`finished`/`idx`/`path` after scripted
   moves must run a forcing call inside the observed window — a pure
   `is_target_reached()`/`get_current_navigation_path()` read is stale
   (flags_attr: same-turn `reached=false` next to `finished=true`). If
   the author's arms already sequence `get_next_path_position` before
   flag reads, this is editorial only.
3. Optional tracked arm candidates if the lane wants the hazards pinned:
   post-finish pop freeze (pop_after_finish numbers), dirty-window read
   (`path=[]`/`final=raw`/stale idx after retarget), last-position
   hysteresis (pop_two_tp), `reachable` live-flip under tdd shrink.

Bounded: one engine build (`4.7.2.stable.arch_linux.ed1daf0bf`), one
host, 60 Hz physics, scripted teleports/stepwise moves (transform-driven
locomotion — no collision-body stepping), single region + optional
island + one server link, 30-tick settle. Not probed: avoidance
velocity_computed path effects (avoidance channel enabled but never
exercised by the server without agents), `path_max_distance`,
`pathfinding_algorithm`/postprocessing setter invalidation, distinct-map
`set_navigation_map` (same-map re-set measured inert), multi-region,
CharacterBody move_and_slide real locomotion. Receipts:
`corpus/live/r74-critic/runs/` (40 arms + 4 repeats, ×.stdout/.stderr/
.exit), runner `corpus/live/r74-critic/run_arms{,2}.sh`, probe
`corpus/live/r74-critic/scratch/r74c_motion.gd`. No tracked files
touched, no commits, leaf — no dispatch.
