# game-dev-3d round 76 — scout (seat: scout, host: devin)

Axis under mapping: the **same-turn setter→server-sync WINDOW** as tracked
CASES rows. Declared claim: a forcing call on the same tick as a RID
mutation serves the pre-mutation path while wait>=1 serves post-sync
state; the exact frame count is a stable constant on this host/build.
Repo root used: `~/Projects/shokunin/game-dev-3d-shokunin` (the brief's
`~/Projects/prymeagnt/game-dev-3d` is the meta worktree whose
`.shokunin/game-dev-3d` symlink points here; HEAD `cb6bf7b` r75).

Independent evidence: probe `corpus/live/r76-scout/proj/r76s_window.gd`
(sha256 `e156ff95…071cfb31`), verbatim committed `project.godot` (sha256
`1fda90d4…8eac23`), geometry identical to the r73/r74/r75 family
(L-corridor A1/A2/B + island C x[2,3]z[5,6] + server link
`(2.5,0,3.5)→(2.5,0,5.5)`; committed bridge path `[S,(2,0,1),ls,le]`,
S=(0.5,0,0.5), T=(2.5,0,5.5)). Godot `4.7.2.stable.arch_linux.ed1daf0bf`,
`/usr/bin/godot --headless`, 60 tps. **17 runs, all exit 0, all stderr
byte-empty** (banner on stdout). Receipts
`corpus/live/r76-scout/runs/<arm>.{stdout,stderr,exit}`; runner
`corpus/live/r76-scout/run_arms.sh`.

## Measured window — headline table (this host/build)

`mutate → n physics frames → forcing read` (steps `wait:n` equivalent):

| mutation | object getter applies | map iter bump | forcing read serves post-mutation |
|---|---|---|---|
| `link_set_enabled(l,false)` | **f1** (`getter_window`: same-turn true→f1 false) | **f2** (iter 2→3) | **wait:2** — stale at wait 0,1 |
| `region_set_transform(r,+5x)` | **f1** (`getter_region`: same-turn origin 0→f1 +5x) | **f3** | **wait:3** — stale at wait 0,1,2 |
| `map_set_active(map,false)` | **f1** (`mapoff_gate`: same-turn true→f1 false) | **never** (iter frozen at 2) | **never** — committed tuple served forever |

Receipts `runs/win_link_n{0..3}`, `runs/win_region_n{0..3}`,
`runs/getter_window`, `runs/getter_region`, `runs/mapoff_gate`,
`runs/mapinact`, `runs/mapinact_x`. Independent re-measurement **agrees
exactly** with r75-boundary's `ld_syncn{1..4}` (link stale n=1, fresh
n=2) and `dw_syncn{1..4}` (region stale n=1,2, fresh n=3) — the window
is a stable measured constant, three-way convergent (boundary,
r75-author's own comment constants, this probe).

**Literal-claim caveat for the record:** the brief's phrasing "wait>=1
serves post-sync state" is falsified as written — wait:1 still serves
the PRE-mutation path for BOTH link (edge=2) and region (edge=3). The
claim's substance (same-tick serves stale; the edge is a stable frame
count) holds: the exact constants are link=2, region_transform=3,
map_set_active=∞. The author's r75 fixture comment
(`navagent3d_detour.gd:1124-1127`) says "mutate steps therefore need
wait>=1 before their forcing read" — that bound describes the
object-getter edge (~1f), not the query edge (2/3f); landed arms all
wait ≥5 so nothing is wrong, but a wait:1 arm written to that comment
would pin a stale tuple.

## (1) Steps machinery — same-tick mutate+forcing-read arm

Expressible today, zero fixture edits (`_run_steps`
`corpus/fixtures/navagent3d_detour.gd:1552-1577`):

- Order inside a step: `set_target` → `tp` → `mutate` → `wait` → peek
  capture → `_read_state` (forcing; `get_next_path_position` first,
  :1379). `wait` is `range(int(step.get("wait", 5)))` `await
  physics_frame` (:1562-1563) — **`wait:0` is legal** (`range(0)` = no
  await = same-turn read).
- A `{mutate:{…}, wait:0}` step IS the same-tick mutate+forcing-read
  arm: setter then forcing call inside one turn — my `win_link_n0` /
  `win_region_n0` are the probe-equivalent and serve the committed
  tuple verbatim.
- Frame math is cumulative across steps: `[{mutate,wait:0},{wait:1},
  {wait:1}]` produces forcing reads at t+0,+1,+2 — the link bisect.
  Consecutive wait:0 steps stay in the SAME turn (no frame between
  steps — step k's read and step k+1's mutate are same-turn if k had
  wait:0).
- `peek_path`/`peek_idx` on any step capture the non-forcing stored
  array BETWEEN the wait and the forcing read (:1565-1567) — at t2 a
  peek still shows the stale 4-pt while `iter` has already bumped
  (`win_link_n2:pre2`): the two-stage pin in one step.
- Intra-window forcing reads do not consume the dirty: a wait:0 force
  then later-step forces still re-query post-sync (my per-n runs are
  independent; r75-boundary `dw_absorb_sameturn`/`dw_between_forces`
  pin non-consumption directly).
- Hazards for the author:
  - `set_target` in the mutate step collapses the pin — the agent-side
    setter clears the stored array SYNCHRONOUSLY (r75 `mut_layers_agent`
    peek=`[]`; boundary `um_agent_layers_equiv`). Same-tick window arms
    must not carry `set_target` on the mutate step.
  - The fs/mutate readback gates (:332-359) run in the SAME turn as the
    last step — object getters apply at ~f1 (`getter_window`/
    `getter_region`), so an arm whose LAST step is `wait:0` after a
    mutation fails "…not in effect" (r75 critic's sync-blind-gate note,
    `r75-boundary.md:67` area). Rule of thumb: last step must be ≥1
    frame past the mutation for the readback to see applied values —
    automatically satisfied by any arm ending at/after the query edge.
  - `_apply_mutation` (:1584-1611) keys: `region_delete`,
    `region_recreate`, `region_transform`, `region_enabled`,
    `region_layers`, `link_enabled`, `link_layers`, `agent_layers`.
    **No `map_active` key** — map_set_active arms need a fixture edit
    (see §4).

## (2) Where the ~2–3-frame boundary was measured; arms to bisect

Prior measurement (report-side only — no CASES row pins it):
`corpus/live/r75-boundary/runs/ld_syncn{1..4}.stdout.txt` (link stale@1
fresh@2), `dw_syncn{1..4}.stdout.txt` (region stale@1,2 fresh@3),
`dw_witnessn{1,2,3}`/`ld_witnessn{1,2}` (M-witness: dirty flag itself
agent-invisible pre-sync — path[0] stays S, not M), probe
`corpus/live/r75-boundary/scratch/navagent3d_mapmut.gd:291-338`;
r75-critic `runs/iter_check.stdout.txt` (same-turn iter/en unchanged)
and `zw_popgate_sameturn` (same-turn pop 2→3 ACROSS the dead gate,
next=le served); r75-scout `mut_disable_window`/`mut_map_inactive`.
Summary `reports/round-75/r75-boundary.md` §(1), :280, :326-330.

Bisect arms (probe-verified constants, all on the committed bridge
path):

- **link_set_enabled**: `win_link` — wait 0: committed 4-pt tuple
  verbatim (next=(2,0,1) idx=1 reachable=true); wait 1: identical
  (iter still 2); wait 2: `[S,(2,0,1),(2.5,0,4.0)]` idx=1 final=(2.5,0,4.0)
  dist=5.385165 reachable=false (iter=3). = `mut_link_drop`'s landed
  post-step constants.
- **region_set_transform +5x**: `win_region` — stale at 0/1/2; wait 3:
  `[(5,0,0.5),(7,0,0),(7,0,1),(7,0,4)]` idx=0 next=(5,0,0.5)
  final=(7,0,4) dist=5.385165 reachable=false. (Corridor-target
  variant `[S,(2,0,1),T]` → `[(5,0,0.5),(5,0,1.0)]` per landed
  `mut_region_move`.) The link does NOT ride the region transform —
  not region-parented (r75-scout table).
- **map_set_active(false)**: no edge exists — the degenerate arm
  (`mapinact`: forced reads at +5,+10 serve the committed tuple
  verbatim, reachable stays TRUE, iter frozen 2). It is the sharpest
  no-sync CONTROL: a RID write under an inactive map never becomes
  query-visible; reactivation applies pending dirty at the normal
  window (`mapinact:react2` iter=3 → clamped at +2f post-reactivate;
  `mapinact_x:react5` → moved path).
- Sharpest serve-dead-data variant (optional): tp to the bank first
  (idx 2→3 committed), then `{mutate:{link_enabled:false},wait:0}` —
  same-turn read serves idx=3 next=(2.5,0,5.5) on the pre-mutation
  array (r75-critic `zw_popgate_sameturn` receipt); a `wait:2` step
  then shows the clamp.

## (3) Same-value suppression — writing the SAME value does NOT dirty

Measured (`runs/same_link`, `same_region`, `same_agent`, contrast
`eff_link`), agreeing with r75-boundary `um_link_enable_same`,
`um_region_layers_same`, `rt_identity_same`, `um_agent_layers_same`:

- M-witness discipline: tp to M=(1.5,0,0.5), 5f, forcing read — stored
  array keeps path[0]=(0.5,0,0.5) (bare teleport does not requery;
  pops idx 1→2 on the stale array, next=ls, dist=5.099020).
- `link_set_enabled(l,true)` on enabled link → read keeps path[0]=S,
  iter stays 2 — **suppressed**. Contrast `link_set_enabled(false)` →
  path[0] re-anchors at M `[(1.5,0,0.5),(2,0,1),(2.5,0,4.0)]` iter=3 —
  effective writes dirty even when outcome-relevant-or-not
  (`um_link_tc_used`, `um_link_*_unused`, `um_region2_*`).
- `region_set_transform(identity)` → suppressed (path[0]=S, iter=2).
- `agent.navigation_layers=1` on already-1 → suppressed AND the
  agent-side synchronous-clear channel dedups too: same-turn peek
  npath=4 (not `[]` — an effective write clears eagerly,
  `mut_layers_agent`/`um_agent_layers_equiv`).
- Asymmetry (r74/r75): `target_position` does NOT dedup — same-value
  retarget still clears+unlatches (`lm_*`, r74 `mv_unlatch`); toggle
  pairs do not collapse (`ld_toggle_netzero`).
- CASES-expressible TODAY (mutate keys exist):
  `{"tp":M,wait:5,<atM tuple>}` then `{"mutate":{"link_enabled":true},
  wait:5,<identical atM tuple — path[0]=s is the suppression pin>}`;
  agent variant uses `wait:0` + `peek_path`=4-pt to pin the absent
  synchronous clear. fs-gate is a non-issue: readback expects the
  unchanged value (e.g. `fs["link_enabled"]=true` vs live true).
  Discriminator = `path[0]` element pin (`_run_motion_arm:1688-1691`).

## (4) `map_set_active(false)` on a committed path

Measured (`runs/mapoff_gate`, `mapinact`, `mapinact_x`; r75-scout
`mut_map_inactive` agrees):

- Deferred object-level setter like the others: same-turn
  `map_is_active` still **true**; reads **false at f1** — deactivation
  lands on the ~1f object edge.
- Once inactive the map never syncs again: `map_get_iteration_id`
  frozen at its last value (2) permanently; `map_get_regions` still
  enumerates the region (nregions=1) — RID-object getters unaffected.
- The committed agent is fully served through arbitrary forcing calls:
  bridge tuple verbatim incl. `reachable=true`, `next=(2,0,1)` at
  +5/+10 frames — a **permanent-stale regime without the finished
  latch** (distinct mechanism: latch = agent update early-returns while
  server syncs; inactive = server never syncs, agent never dirties).
- RID writes while inactive APPLY at object level but never reach the
  query: `link_get_enabled`=false / `region_get_transform`=+5x read
  back, yet forced reads keep serving the committed path.
- Reactivation resumes sync: pending `link_set_enabled(false)` becomes
  query-visible at +2f post-`map_set_active(true)` (`react2` iter=3 →
  clamped `[S,(2,0,1),(2.5,0,4.0)]`); pending region transform at +5f
  (`react5` → moved path). `map_set_active(true)` itself is again
  deferred (`react_same` still false).
- CASES reachability — REQUIRES fixture edits (not expressible today):
  1. `_apply_mutation` (:1584) needs `map_active`:
     `NavigationServer3D.map_set_active(srv["map"], …)` — `srv["map"]`
     already in scope (:295).
  2. `_final_srv_state` (:1618) needs a `map_active` fold (default
     true).
  3. The setup gate at :324 `not map_is_active(map)` is unconditional —
     a `map_active:false` arm trips "live navigation agent/map setup
     absent" on any post-mutation step with wait≥1 (deactivation lands
     by f1). It must become `map_is_active(map) != fs["map_active"]` —
     or the arm cannot land.
- Arm shape once keys exist: `{"mutate":{"map_active":false},wait:N,
  <committed tuple verbatim>}` any N ≥0 — every later step identical;
  reachable stays true (the pin that distinguishes it from
  `mut_layers_region`'s empty-path kill). Cycle arm: off → mutate
  link_enabled:false (wait≥5) → `map_active:true` → wait:2 → clamped
  tuple (my `react2` constants).

## Suggested CASES surface (all constants probe-measured, this host)

| arm | steps sketch | pins |
|---|---|---|
| `mut_win_link` | mutate link_enabled:false@w0 → w1 → w1 | stale@0, stale@1, fresh@2 (edge=2); last-step peek = synced-iter/stale-array |
| `mut_win_region` | mutate region_transform+5x @w0 → w1 → w1 → w1 | stale@0,1,2, fresh@3 (edge=3) |
| `mut_deadserve` (opt) | tp bank (idx3) → mutate+wait:0 | same-turn serve of dead endpoint next=(2.5,0,5.5) |
| `mut_same_link` | tp M → mutate link_enabled:true w5 | path[0]=S: same-value suppressed (vs `eff_link` re-anchor M) |
| `mut_same_region` | tp M → mutate region_transform (0,0,0) w5 | identity write suppressed |
| `mut_same_agent` | tp M → mutate agent_layers:1 w0+peek | same-turn npath=4: agent channel dedups |
| `mut_map_off` | mutate map_active:false (needs keys) | committed tuple incl. reachable=true forever; iter frozen |
| `mut_map_cycle` | off → link disable → on → w2 | pending dirty applies at normal edge on reactivation |

## Confidence and remaining unknowns

- **High (measured, 3-way convergent):** window edges link=2f /
  region-xform=3f / map-off=∞; same-turn stale serve; ~1f object-getter
  edge for both link and region (and `map_is_active`); same-value
  suppression on link/region/agent-layers; map-inactive permanent-stale
  semantics + reactivation resume; wait:0 legality and step ordering.
- **Inference/medium:** WHY the query edge is 2 vs 3 (deferred merge
  pipeline stage) — timing-only evidence, engine source not read;
  `map_get_regions`/other map getters while inactive assumed object-
  level (nregions=1 measured only); latencies at other physics tick
  rates unprobed (60 tps here).
- **Unknown (unprobed anywhere):** whether `map_set_active(false)` mid-
  window freezes a pending unsynced mutation vs queues it (my probes
  deactivate BEFORE mutating — the mutate-then-instantly-deactivate
  ordering is open); node-authored `NavigationLink3D` same-turn window
  (server-RID symmetry inferred, not measured); link/region getter edge
  on node property writes; whether same-value suppression covers
  `link_set_map`/endpoint/cost setters.
- The `wait>=1` phrasing in the declared claim (and the r75 fixture
  comment :1127) is too tight: measured query edges are wait>=2 (link)
  and wait>=3 (region xform) — the CASES rows should pin the exact
  constants above.

Evidence: `corpus/live/r76-scout/runs/*` (17 runs, exit 0, empty
stderr), probe `corpus/live/r76-scout/proj/r76s_window.gd`, runner
`corpus/live/r76-scout/run_arms.sh`. Priors: r75-boundary
`dw_syncn*/ld_syncn*/dw_witnessn*/ld_witnessn*/um_*_same/rt_identity_
same/ld_toggle_netzero/um_agent_layers_*` receipts and
`reports/round-75/r75-boundary.md`; r75-critic `zw_popgate_sameturn`,
`iter_check`; r75-scout `mut_map_inactive`, `mut_disable_window`.
Leaf — no dispatch, no tracked edits, no commits.
