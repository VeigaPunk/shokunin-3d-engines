# game-dev-3d round 76 — critic (seat: critic, host: devin)

Scope of attack: the declared axis-move — pin the same-turn setter→server-sync
WINDOW as tracked CASES. Declared falsifiable claim (verbatim): *"the sync
boundary is frame-measurable — a forcing call on the same tick as a RID
mutation serves the pre-mutation path while wait>=1 serves post-sync state;
the exact frame count of the window is a stable measured constant on this
host/build."*

**No landed r76 diff at review cutoff.** HEAD = `cb6bf7b` (r75 report-last),
working tree clean apart from `?? reports/round-76/` (sibling reports) and my
own untracked scratch; `corpus/live/r76-author/` and the fixture diff do not
exist yet. All attacks below therefore hit (a) the declared claim's literal
content and (b) the fixture machinery the arms will land on. Independent
measurement four-way converges with r75-boundary (`ld_syncn*`/`dw_syncn*`),
r76-scout (`win_link_*`/`win_region_*`), and r76-boundary's resamples
(`fstar=2` for server AND node-authored links).

Independent probe: `corpus/live/r76-critic/scratch/r76c_window.gd` (sha256
`01a29709…`), verbatim committed `project.godot` (sha256 `1fda90d4…8eac23`,
`physics_ticks_per_second=60`), same L-corridor + island C + server link
ls=(2.5,0,3.5)→le=(2.5,0,5.5) geometry as the landed fixture. Godot
`4.7.2.stable.arch_linux.ed1daf0bf`. Instrumentation: `map_get_iteration_id`
(map rebuild clock — bumps only on dirty syncs), `link/region_get_iteration_id`
(per-object apply stamp), per-getter value readback, plus non-forcing peek +
forcing `_read_state` per wait. **47 arm runs, all exit 0, stderr
banner-only.** Receipts `corpus/live/r76-critic/runs/<arm>.{stdout,stderr,
exit}.txt`; runner `run_arms.sh`.

Green-baseline check: full battery on HEAD (156 cases + 4 probes) ran under
concurrent seat load → `verdicts.json`
`corpus/live/r76-critic/battery-runs/20261014T095646979904Z/` — cases=156
pass=156 fail=0, all four probes ok, seeds_unchanged=True.

## Headline: the window is real and stable — but the declared claim is falsified TWICE

**"wait>=1 serves post-sync state" is FALSE for every RID mutation class.**
A forcing call at exactly wait=1 still serves the pre-mutation path — the
served-path edge is **2 physics frames for link setters and region free_rid,
3 for region setters, ∞ for map_set_active(false), 0 for agent-side setters**.
Measured constants (all byte-stable across reps):

| mutation | object truth visible (getter + iter stamp) | map rebuild (`map_iter`) | forcing read serves post-mutation |
|---|---|---|---|
| `link_set_enabled(false)` | w1 (`link_iter` 1→2, `en=false`) | w2 (iter 2→3) | **w2** (stale at 0,1) — `scan_linkoff`, `w1_linkoff`, `rep_linkoff_w{0,1,2}` |
| `link_set_navigation_layers(2)` | w1 | w2 | **w2** — `scan_linklayers` |
| `link_set_start/end_position` (move) | w1 | w2 | **w2** — `rep_linkmove_w{1,2}` |
| `link_set_travel_cost(10)` | w1 | w2 | **w2** — `rep_linkcost_w{1,2}_shortcut` (shortcut geometry; bridge is non-discriminating — the link is the only route there) |
| `free_rid(region)` | w0 — RID invalid same-turn (synchronous destroy) | w2 | **w2** — `scan_regiondel`, `rep_regiondel_w{1,2}` |
| `region_set_enabled(false)` | w1 value readable; `region_iter` stamped w2 | w3 | **w3** (stale at 0,1,2) — `scan_regionoff`, `rep_regionoff_w{2,3}` |
| `region_set_navigation_layers(2)` | w1 / stamp w2 | w3 | **w3** — `scan_regionlayers` |
| `region_set_transform(+5x)` | w1 / stamp w2 | w3 | **w3** — `scan_regionxform`, `rep_regionxform_w{2,3}` |
| `region_set_navigation_mesh(shifted)` | stamp w2 | w3 | **w3** — `rep_regionmesh_w{2,3}` |
| `map_set_active(false)` | w1 (`map_is_active`→false) | never while inactive | **never** — stale committed tuple served indefinitely, `reachable=true` intact — `scan_mapoff`, `rep_mapoff_w3`, `bb_mapoff`, `bb_mapoff_latch` |
| `agent.navigation_layers=2` | w0 — synchronous clear (`peek=[]`) | n/a | **w0** — `scan_agentlayers`, `bb_agentlayers_w0` |

Two falsifications of the declared claim follow directly:

1. **The constant isn't 1.** At wait=1 the mutation has already landed on the
   object (`link_iter`=2, `en=false` — `runs/w1_linkoff.stdout.txt`) yet the
   forcing call still serves the untouched zombie tuple verbatim
   (`[S,(2,0,1),ls,le]`, `reachable=true`). `wait>=1` describes the
   *getter-stage* edge, not the *query-stage* edge — the two are decoupled by
   exactly one extra map sync. An author arm authored to the declared claim
   (`mutate`+`wait:1` expecting post-sync) pins stale data; the fixture's own
   header hedge "~2–3 frames" is the true measure.
2. **There is no single constant.** The served-path window is per-class:
   0 (agent layers — synchronous), 2 (link setters, `free_rid`), 3 (all
   region *setters* — the region itself needs a stamp cycle before the map
   rebuilds), and **no finite window at all for `map_set_active(false)`** —
   deactivation freezes the map's sync clock (`map_iter` pinned at 2 across
   `scan_mapoff` w0→w5) and the agent keeps serving its committed
   `reachable=true` path on a dead map forever: a whole-map zombie.

## Attack (1) — is the window real and frame-stable, or scheduling jitter?

**Real and tick-exact; not jitter.** `rep` arms rebuild the whole world per
rep (fresh map/region/link/agent, 30-frame settle) and ran while 4 sibling
godot instances plus the 156-case battery hammered the same box:

- `rep_linkoff`: wait=0 → STALE ×10, wait=1 → STALE ×10, wait=2 → FRESH ×10.
- `rep_regionxform`: wait=2 → STALE ×10, wait=3 → FRESH ×10.
- `rep_regionoff`/`regiondel`/`linkmove`/`linkcost`/`mapoff`: identical
  determinism (106 rep lines total, zero boundary deviation).
- `bb_idle` shows the count is *tick*-keyed, not signal-keyed: 3
  `process_frame` awaits land the same endpoint as physics awaits
  (`map_iter`=3, fresh serve). In headless each main-loop iteration steps
  physics once; idle vs physics await counts coincide.

The mechanism visible in the receipts is a two-stage drain: stage 1 applies
the queued RID setter (getters + object `iteration_id` update), stage 2 —
one sync later — rebuilds the map and posts agent invalidation. Region
setters spend one more cycle stamping the region itself. `map_iter` only
counts dirty syncs (frozen during idleness), so the window is denominated in
**map sync passes**, and anything that stalls the sync source (inactive map)
freezes the window open indefinitely.

## Attack (2) — the window differs per mutation class: confirmed, sharpened

Beyond the 0/2/3/∞ split above, three cross-class edges:

- **`bb_double`** (link off + region +5x same turn): `w2` serve already shows
  the corridor clamp `[S,(2,0,1),(2.5,0,4.0)]` — the *link* dead — while the
  region transform is still unapplied in path space; the *region* lands at
  `w4` (`map_iter`=4, re-anchor at `[(5,0,0.5),…,(7,0,4)]`). Two mutations
  issued in one turn resolve on their own clocks — mixed staleness is
  real, not an artifact of either class.
- **`bb_mapoff_kill`**: mutations issued *while the map is inactive* are not
  lost — `link_set_enabled(false)` queued during inactivity reads
  `en=false` (yet `link_iter` stays 1 — no stamp without a sync), and after
  reactivation the boundary replays exactly: on+0 stale → on+1 applied/stale
  → on+2 fresh clamp. The window restarts on reactivation, not on write.
- **Physics-context writes shift the window by one tick**
  (`bb_physmut`): a `link_set_enabled(false)` issued inside a node's
  `_physics_process` applies in *that same tick's* drain (getters already
  false at the tick's end) and the served path flips at the **next** tick —
  an await-count of **1**, vs **2** for the identical setter issued from
  idle/coroutine context. So even "the frame count" is callsite-dependent:
  a reader awaiting `physics_frame` after a physics-callback write sees
  fresh one tick sooner than the fixture's step-context writes. The
  fixture's `wait` counts are all resume-context, so CASES constants 2/3 are
  correct *for that context* — but "stable measured constant" needs the
  callsite qualifier or a physics-context writer gets a different number.

## Attack (3) — same-value suppression: CONFIRMED inert (with one carve-out)

Discriminator: force the path at S, teleport to (1.5,0,0.5) *without* a
forcing read, then write the SAME value back. If the write dirties, the next
forcing read re-anchors the path at the live position (`path[0]` moves off
S); if inert, the stored array survives and only the pop index advances.

| arm | write (already-equal) | iter bump | reanchored | verdict |
|---|---|---|---|---|
| `sv_link_en` | `link_set_enabled(true)` | no (`link_iter`=1, `map_iter`=2 at w5) | no | **inert** |
| `sv_link_layers` | `link_set_navigation_layers(1)` | no | no | **inert** |
| `sv_region_en` | `region_set_enabled(true)` | no | no | **inert** |
| `sv_region_layers` | `region_set_navigation_layers(1)` | no | no | **inert** |
| `sv_region_xform` | `region_set_transform(IDENTITY)` | no | no | **inert** |
| `sv_map_active` | `map_set_active(true)` | no | no | **inert** |
| `sv_agent_layers` | `agent.navigation_layers=1` | n/a | no | **inert** (peek path intact at w0 — the synchronous clear does NOT fire on same-value) |
| `sv_ctrl` | `link_set_enabled(false)` — real change | yes (`link_iter`→2, `map_iter`→3) | **yes** — `[(1.5,0,0.5),(2,0,1),(2.5,0,4.0)]` | discriminator proven |

So no-op writes are *fully suppressed* at command level — not
dirty-and-rematerialize-identically. **Carve-out the author's wording must
respect:** `agent.target_position` same-value re-assignment is the opposite —
tracked arm `mv_reanchor_same` (r74) pins re-anchor + idx reset + unlatch on
an unchanged target. Suppression holds for RID/agent *property* setters; it
does not generalize to target submission. If a landed arm or comment claims
"same-value writes are suppressed" unqualified, the `target_position` row
falsifies it.

## Attack (4) — mutation+read combinations that break the claimed boundary

Found and receipted:

- **`map_force_update` collapses the getter stage, not the served stage**
  (`bb_fu`): `link_set_enabled(false)` + `map_force_update(map)` same turn →
  `link_iter`=2/`en=false` *immediately* (window 0 for object truth) — yet the
  same-turn forcing call still serves the zombie tuple, and the map rebuild +
  fresh serve still land at w2. The "window" is not one interval; forcing the
  command queue does not accelerate invalidation.
- **`map_set_active(false)` — infinite window** (above): the cleanest
  breaker. No await count yields post-mutation service while inactive; the
  committed tuple is served with `reachable=true` on a deactivated map.
- **Physics-callback callsite** (above): window measured in awaits is 1 vs 2
  by write context — the "exact frame count … stable" claim needs scoping.
- **`w1` interlude is a live hazard for the CASES arms**: at wait=1 object
  getters already read post-mutation truth — so the `_final_srv_state`
  honesty gate (`navagent3d_detour.gd:347-359`) *passes* — while the forcing
  read still serves stale. An arm `mutate + wait:1 + expected-fresh` will
  fail its path pin (not the gate); an arm `mutate + wait:1 + expected-stale`
  is expressible and correct. The r75 sync-blind-gate caveat sharpens: the
  gate's truth horizon (w1) sits strictly *inside* the serve horizon (w2/3).
- **Bounded, not probed:** multi-map agents, `region_set_map` reassignment,
  NavigationServer2D, node-authored link *property* writes mid-window (r76-
  boundary already resampled node links to the same `fstar=2`), cost-mutation
  on non-discriminating geometry, `map_set_active` under the latched-finished
  agent beyond `bb_mapoff_latch`'s 5-frame observation.

## Impacted axes

- **coverage**: the move is real and CASES-expressible as declared in shape —
  but the constants to pin are **0/1/2/3** (per-class), not `0` vs `>=1`.
- **calibration**: the declared claim's literal inequality (`wait>=1 →
  post-sync`) is falsified; the claim survives only rewritten as per-class
  edges {link:2, region:3, free_rid:2, map_off:∞, agent:0}, callsite-scoped.
- **depth**: sharper model landed by measurement — two-stage drain
  (setter-apply pass → map-rebuild pass), map-sync denominated, sync clock
  stoppable via `map_set_active(false)`, getter stage collapsible to 0 via
  `map_force_update` without affecting the serve stage.

## Smallest safe corrections (fixable; nothing structurally blocks the move)

1. Claim text / any CASES comments: `wait>=1 serves post-sync` →
   "wait=0 serves the pre-mutation tuple for every RID class; wait=2 for
   link mutations and region `free_rid`; wait=3 for region setters;
   `map_set_active(false)` never invalidates served state while inactive;
   agent-side setters are synchronous (w=0)." One line per class.
2. If a `wait:1` arm is authored expecting post-sync, it cannot pass — the
   author's wait axis should bisect {0,1,2} for link and {0,1,2,3} for
   region arms; mid-window arms should pin `peek_*` (stale array) plus the
   post-edge tuple.
3. `map_set_active` arms need a `map_active`/`map_off` key in
   `_apply_mutation` (`navagent3d_detour.gd:1584-1611` has none today) — and
   should pin the *whole-map zombie* tuple (stored path served unchanged,
   `reachable` frozen), not an empty path.
4. Same-value suppression arms: scope the pinned claim to property setters;
   note `target_position` same-value is a re-submission (r74 `mv_reanchor_same`)
   and stays non-suppressed.
5. Optional honesty note near `_final_srv_state`: object-getter readback is
   trustworthy at wait≥1, but served-path truth needs wait≥2/3 — the gate
   and the arm's own expectations see different horizons.

Evidence index: `corpus/live/r76-critic/scratch/r76c_window.gd` + `api_check.gd`;
`corpus/live/r76-critic/runs/` (47 arms × `.stdout/.stderr/.exit`, all exit 0,
banner-only stderr); `corpus/live/r76-critic/run_arms.sh`; battery receipt
`corpus/live/r76-critic/battery-runs/20261014T095646979904Z/verdicts.json`
(156/156 + 4 probes on unmodified HEAD `cb6bf7b`). No tracked files touched;
no commits. Leaf — no dispatch. Stopping here.
