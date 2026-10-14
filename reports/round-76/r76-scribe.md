# game-dev-3d round 76 — scribe report (seat: scribe, host: devin)

Declared lane axis-move (from dispatch, verbatim): "pin the same-turn
setter→server-sync WINDOW as tracked CASES: r75 measured the two-stage
gate report-side (~2–3 frames; same-turn forcing calls serve stale/dead
data) but no CASES row pins the window itself. Declared falsifiable
claim: the sync boundary is frame-measurable — a forcing call on the
same tick as a RID mutation serves the pre-mutation path while wait>=1
serves post-sync state; the exact frame count of the window is a stable
measured constant on this host/build. Add same-turn-mutation arms
(mutate + forcing read at wait=0/1/2), map_set_active(false)
reachability, and same-value-mutation suppression arms; 156/156 +
4 probes + Node 31/31 must stay green."

Scribe duty per brief: independently re-run the author's landed arms and
re-measure under `corpus/live/r76-scribe/` — own geometry, own arms —
then verify or falsify the sync-window frame bound and same-value
suppression; draft the lesson (`corpus/lessons/` convention, fenced
below) + LOG.md round-entry draft. Report-only; not the judge.

Canonical repo `~/Projects/shokunin/game-dev-3d-shokunin` (the brief's
`~/Projects/prymeagnt/game-dev-3d` worktree line is the stale
predecessor path — `.shokunin/game-dev-3d` symlinks here; same finding
as r75/r76-baseline). Engine `/usr/bin/godot` =
`4.7.2.stable.arch_linux.ed1daf0bf`, Python 3.14.7, Node v24.21.0,
three.js 0.186.1, 60 tps pinned (`project.godot`). The r76 work commit
landed MID-round while this seat measured: `3ab09fdb804b0600a6f6a14b28c42f0bb4e49e0f`
("r76: sync-window CASES — per-class edges {link:2, region:3,
map_off:∞, agent:0} + same-value suppression pins"; `navagent3d_detour.gd`
+290/−6 sha256 `066a06d2…39a19e4`, `run_battery.py` +14/−0 sha256
`6faa8356…b5cba1`). Everything this seat replayed is that committed
content — the author-replay copy's sha256 matches the committed blob
byte-for-byte.

## Own measured evidence (independent derivation)

Probe `corpus/live/r76-scribe/scratch/r76s_syncwin.gd`, sha256
`d9f55f6995478365a0193b7ab5e47e2af29c03495e00dd084dc4adbddea45691`,
extends-SceneTree driver on a byte-identical `project.godot` copy
(sha256 `1fda90d4…8eac23`). **Own geometry, own arms, own `R76S`
output format** — deliberately unlike every sibling (author/critic/
scout/boundary all reuse the r70 L-corridor A1/A2/B + island C + link
`(2.5,0,3.5)→(2.5,0,5.5)`; r75-scribe used two-region hook-and-ferry):

- "shelf-hop", ONE region RID holding two polygons: LOW `x[0,5]z[0,5]`
  + SHELF `x[7,10]z[7,10]` (void z(5,7)); server link
  `(4.2,0,4.2)→(7.5,0,7.5)`, bidirectional, layers 1, travel_cost 1.
- `S=(1,0,1)` → `T=(9,0,9)`; committed P0 =
  `[(1,0,1),(4.2,0,4.2),(7.5,0,7.5),(9,0,9)]` (4-pt link path,
  materialized once before any arm).
- Re-anchor witness `M=(2.5,0,2.5)` — on the S→LA leg: a bare teleport
  there never re-queries (sameP0 stays true), so a post-mutation
  `path[0]==M` proves the write dirtied; `path[0]==S` proves
  suppression.

Command per arm (cwd `corpus/live/r76-scribe/`):

    /usr/bin/godot --headless --path scratch \
      --script res://r76s_syncwin.gd -- --mode=<mode> [--mut=<m> --n=<k>]

Runner `corpus/live/r76-scribe/run_arms.sh`; receipts
`corpus/live/r76-scribe/runs/<arm>.{stdout.txt,stderr.txt,exit}`.
**65 runs, all exit 0, all stderr byte-empty.** Modes: `force` (mutate,
await `--n` physics frames, ONE forcing `get_next_path_position` — fresh
process per n, so the served tuple is independently pre- or post-sync),
`scan` (mutate, then per-frame SERVER truth + pure reads only — the
agent's lazy dirty state is never consumed inside the scan), `sv`/`cv`
(same-value vs changed-value writes at the M-witness), `mapoff_*`
(deactivation bisect + off/on round-trip), `base`.

### Window bisect — `mutate → n physics frames → forcing read`

| mutation class | n=0 | n=1 | n=2 | n=3 | n=4 | edge |
|---|---|---|---|---|---|---|
| `link_set_enabled(false)` | stale | stale | POST | POST | POST | **2 frames** |
| `link_set_navigation_layers(2)` | stale | stale | POST | POST | POST | **2 frames** |
| `region_set_transform(+6x)` | stale | stale | stale | POST | POST | **3 frames** |
| `region_set_enabled(false)` | stale | stale | stale | POST | POST | **3 frames** |
| `region_set_navigation_layers(2)` | stale | stale | stale | POST | POST | **3 frames** |

("stale" = forced tuple serves P0 verbatim, `sameP0=true`; "POST" =
re-query served — link kills clamp to `[(1,0,1),(5,0,5)]`
reachable=false; region edits re-anchor on the moved/masked map or
EMPTY `path=[]`. Receipts `runs/force_<m>_n<k>.stdout.txt`.)
Stability: boundary frames re-run ×3 — `rep_{a,b,c}_link_dis_n1/n2` and
`rep_{a,b,c}_reg_move_n2/n3` all **byte-identical** across repeats;
fresh process per (mut,n) cell.

### Sync decomposition — per-frame server truth (pure reads only)

| arm | object getter lands | `map_get_iteration_id` bumps | agent serve edge |
|---|---|---|---|
| `scan_link_dis` | k=1 (`link_en` true→false, `linkiter` 1→2) | k=2 (iter 2→3) | ≥2 |
| `scan_link_lay` | k=1 (`linkiter` 1→2) | k=2 | ≥2 |
| `scan_reg_move` | k=1 (`reg_x`→+6x) | k=3 | ≥3 |
| `scan_reg_dis` | k=1 (`reg_en`→false) | k=3 | ≥3 |
| `scan_reg_lay` | — | k=3 | ≥3 |
| `scan_map_off` | k=1 (`map_active`→false) | **never** (frozen at 2 through k=8) | **never** |

Two stages are visible in one run: the per-object setter truth is
server-readable at **frame 1**, while the map iteration that publishes
the dirty to agents bumps at **frame 2 (link class) / frame 3 (region
class)** — the query edge is one/two frames deeper than the object
edge, matching the author's landed comment (`navagent3d_detour.gd`
round-76 header block) and the reviewer's pre-landing bound (terminal
`mutate`+`wait:0` fails the readback gate, whose truth horizon is ~1f).

### Same-value suppression — anchor-shift witness at M=(2.5,0,2.5)

Teleport to M, settle 5f (`sv:atM` still `sameP0=true` — the teleport
alone never re-queries), write, wait n, force once.

| write (already-equal) | n | result | verdict |
|---|---|---|---|
| `link_set_enabled(true)` | 5, 0 | `sameP0=true` | **suppressed** |
| `link_set_navigation_layers(1)` | 5 | `sameP0=true` | **suppressed** |
| `link_set_travel_cost(1.0)` | 5 | `sameP0=true` | **suppressed** |
| `region_set_transform(identity)` | 5, 0 | `sameP0=true` | **suppressed** |
| `region_set_enabled(true)` | 5 | `sameP0=true` | **suppressed** |
| `map_set_active(true)` | 5 | `sameP0=true` | **suppressed** |
| `agent.navigation_layers=1` | 5, 0 | `sameP0=true` | **deduped** (no same-turn clear) |

Changed-value controls, same shape (`cv_*:n5`): `link_dis` re-anchors
`path[0]=(2.5,0,2.5)` → `[(2.5,0,2.5),(5,0,5)]`; `link_tc_chg` (1→5)
re-anchors `[(2.5,0,2.5),(4.2,0,4.2),(7.5,0,7.5),(9,0,9)]` (dirties on
an outcome-identical route — the witness works); `reg_move` →
`[(6,0,2.5),(9,0,5)]`; `reg_dis` → `path=[EMPTY]`; `agent_lay_chg`
(1→2) → **`pure` read EMPTY already at wait=0** (synchronous clear,
`runs/cv_agent_lay_chg_n0`). The discriminator bites on every channel,
so the seven suppressions are measured, not vacuous.

### `map_set_active(false)` reachability

`mapoff_n{0,1,2,5}`: pure AND forced reads serve the committed 4-pt
tuple verbatim at every window (`sameP0=true`, `reachable=true`,
`fin=false` — forcing calls keep working; the +5f late force too).
`mapoff_re` (off 4f → force → on 4f → force): byte-identical tuple both
sides — the off/on round-trip is a no-op on the committed state.
Corroborates r75-scribe's single-seat `gm_map_deactivate{,_pop}` on a
second geometry, now with the per-frame witness: the map leaves the
iteration (`mapiter` frozen) rather than invalidating through it.

## Author-arm independent replay (post-commit `3ab09fd`)

Copied the committed fixture + seed `project.godot` into
`corpus/live/r76-scribe/author-replay/proj/` (fixture sha256
`066a06d2…39a19e4` = committed blob) and ran every new arm standalone:

    /usr/bin/godot --headless --path author-replay/proj \
      --script res://navagent3d_detour.gd -- --arm=<name>

| arm | exit | PASS marker vs CASES row |
|---|---|---|
| `mut_win_link` | 0 | verbatim `steps=4 idxs=2,3,3,1 … finished=true` — the wait:0 step serves AND pops idx 2→3 across the killed gate (`next=(2.5,0,5.5)` dead endpoint), +1f still stale, +2f re-query clamps |
| `mut_win_region` | 0 | verbatim `idxs=1,1,1,0` — stale at +0/+1/+2, fresh at +3 |
| `mut_map_off` | 0 | verbatim `idxs=1,1,1 … reachable=true` through +0/+10/+15 |
| `mut_map_cycle` | 0 | verbatim `idxs=1,1,1,1 … reachable=false` — queued kill flushes at +2f post-reactivation |
| `mut_same_link` | 0 | verbatim `idxs=2,2,2` — same-value suppressed; effective write re-anchors `path[0]=(1.5,0,0.5)` |
| `mut_same_region` | 0 | verbatim `idxs=2,2,0 … path=[]` — layers=1 + identity-transform dedup; `layers→2` empties |
| `mut_same_agent` | 0 | verbatim `idxs=2,2,0,2` — same-value dedup before the synchronous clear; `→2` gives `peek=[]` same-turn; restore re-materializes |

Receipts `corpus/live/r76-scribe/author-replay/runs/<arm>.{stdout,stderr}.txt`.

**Full independent battery replay** (my own `--runs`, absolute path —
the r75 relative-path tree-timeout trap avoided):

    python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
      --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r76-scribe/runs-battery \
      --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing

→ `exit 0`, `corpus/live/r76-scribe/runs-battery/20261014T101915045860Z/verdicts.json`:
**163/163 cases PASS** (118 ordinary / 45 negative), `seeds_unchanged=true`,
`crash_probe_ok=true`, `stream_probe_ok=true`, `tree_probe_ok=true`,
adversarial-mutation probe `verdict=PASS detected=true`. Row-level diff
of my receipt vs the frozen-baseline receipt
(`corpus/live/r76-baseline/runs/20261014T095009263752Z/verdicts.json`):
**all 156 prior rows byte-identical on stdout AND exit code**; the only
new case names are exactly the 7 landed arms. `git diff` on
`run_battery.py` is a single +14/−0 insertion hunk after
`navagent3d_detour_mut_latch_zombie` — zero deleted lines, so prior
rows are byte-preserved at the source too.

**Node suites, independently re-run:** `corpus/fixtures/three/run_*.mjs
--receipt <abs>` → `corpus/live/r76-scribe/node/*.json` — **31/31 PASS**
(run_cases 3/3, run_layer_cases 4/4, run_order_cases 9/9,
run_camera_cases 5/5, run_ortho_cases 5/5, run_ray_cases 5/5), all
`seedsUnchanged=true`, node v24.21.0, three 0.186.1.

## Convergence vs the declared claim — per clause

1. **"a forcing call on the same tick as a RID mutation serves the
   pre-mutation path"** — CONFIRMED on every channel measured (all my
   n=0 cells stale; author's `mut_win_*` wait:0 steps; the link arm even
   serves-and-pops across the dead gate).
2. **"wait>=1 serves post-sync state"** — **FALSIFIED**, four-way
   convergent: at wait=1 the serve is still pre-mutation for BOTH
   classes (my bisect; scout `win_link_n1`/`win_region_n{1,2}`; boundary
   54/54 + 24/24 resamples `fstar=2`/`3`; author's own landed arms pin
   stale tuples at +1f). The true edges are **link class = 2 frames,
   region class = 3 frames** on this build — identical to r75-boundary's
   report-side `ld_syncn`/`dw_syncn`.
3. **"the exact frame count of the window is a stable measured
   constant"** — CONFIRMED with a scoping correction: it is **per
   mutation-class**, not one constant — {link writes: 2, region writes:
   3, `free_rid` on link: 2 (boundary), `map_set_active`: no finite edge
   (query-inert), agent `navigation_layers`: 0 (synchronous)} — and it
   is **callsite-scoped** (critic `bb_physmut`: the same setter issued
   inside `_physics_process` drains in that tick and flips the serve at
   await-count 1, one tick shallower than the coroutine/resume context
   every CASES `wait` measures; constants 2/3 are correct for the
   fixture's context). My 3× boundary-frame repeats are byte-identical;
   boundary's resample totals are strict.
4. **map_set_active(false) reachability** — resolved to a stronger
   measured fact than "reachable": the write leaves the sync pipeline
   entirely (object flag flips at f1, `mapiter` never bumps, dirty never
   surfaces, committed tuple + `reachable=true` served through arbitrary
   forcing calls with no latch; queued writes flush at the normal edge
   on reactivation — `mut_map_cycle`, author `map_cycle` probe, critic
   `bb_mapoff_kill`, my `mapoff_*`/`scan_map_off`).
5. **same-value suppression** — CONFIRMED as a suppression, not
   dirty-and-rematerialize-identically: every already-equal server/agent
   write left the stored array byte-identical under a proven
   discriminating witness (my 7 `sv_*` vs 5 `cv_*`; author
   `mut_same_*`; critic `sv_*` table + `sv_ctrl`; boundary
   `nl_prop_same` on the node channel). Carve-out preserved verbatim
   from critic: `target_position` same-value assignment is NOT
   suppressed (r74 `mv_reanchor_same`) — the author's comment scopes
   correctly ("on every probed setter — link_enabled / region_layers /
   region_transform(identity) / agent.navigation_layers"), so no landed
   wording falsifies.

## Wave state at observation time

- HEAD moved mid-round: `cb6bf7b` → `3ab09fd` (the r76 work commit +
  six sibling reports committed by the parent at 07:22). Working tree
  otherwise clean: `?? reports/round-76/{r76-simplifier,r76-verifier,
  r76-scribe}.md` (all landed after the commit).
- Sibling reports present: baseline (frozen `cb6bf7b` → 156/156 +
  4 probes + Node 31/31 verbatim), scout (17 runs; same edges 2/3/∞;
  flags the literal-claim caveat), critic (falsifies the claim twice —
  `wait>=1` and the single-constant wording; callsite +1-tick shift;
  `map_force_update` collapses only the getter stage), boundary
  (per-frame transition sampler; strict constants, per-map dirty scope,
  node≡server channel, `enter_cost` lands-but-route-inert), reviewer
  (pre-landing audit of committed HEAD — terminal `mutate`+`wait:0`
  unauthorable via the readback gate; mid-step `wait:0` works; verified
  on-blob), simplifier (7/7 arms load-bearing, zero drops; `st2` dead
  store survives; `map_active`-ordering caveat unexercised by landed
  arms), author (claim table + 163/163 receipt
  `corpus/live/r76-author/runs/battery/20261014T101410997458Z/`).
- Verifier `reports/round-76/r76-verifier.md`: **AGREE — 5/5 claims**
  (independent battery `corpus/live/r76-verifier/runs/
  20261014T102343921913Z/verdicts.json` = 163/163 + 4/4 probes +
  Node 31/31, `seeds_unchanged`; two non-blocking caveats noted).
  Adjudicator report pending at write time.

## Verbatim carries / conflicts for the judge

1. **Declared-claim outcome**: window is real, frame-exact, stable —
   but **not** at the declared bound: falsified twice as written
   (post-sync needs wait≥2 link / ≥3 region, and no single constant
   exists). Net: the substance lands, the `wait>=1` clause is refuted.
2. **Callsite scoping** (critic-measured, un-corroborated by my arms —
   my probe is resume-context like the fixture): physics-callback
   writes flip the serve one tick sooner. CASES constants 2/3 are
   deferred-coroutine-context constants; "stable constant" needs that
   qualifier.
3. **Suppression carve-out** (critic `sv_*`/`mv_reanchor_same`):
   `target_position` same-value assignment still unlatches/clears —
   suppression holds for RID/agent property setters only. Author
   wording already scoped; flagged so the lesson draft keeps the scope.
4. **Simplifier honesty flags**: `map_active` applied-last ordering in
   `_apply_mutation` is exercised by no landed same-dict mix (comment
   claim currently unexercised); `st2` dead store persists at
   `navagent3d_detour.gd:331`; `stf` malformed-config index-error class
   unchanged.
5. **Reviewer bound (pre-landing, verified on committed blob)**:
   terminal `mutate`+`wait:0` cannot pass `_final_srv_state` (getter
   truth ~1f < query edge) — the landed arms all end ≥1f after their
   last mutate, consistent.

## Retained UNKNOWNs (do not claim)

- Pipeline internals behind the 2-vs-3 split (rebuild stages; why
  region writes cost one more frame) — measured-not-explained.
- Physics-callsite windows for the region/agent classes (critic probed
  link only); other callsites (process-frame, signal handlers)
  unmeasured.
- `map_set_active(false)` permanent-stale is bounded at ~15–30 frames
  (author + boundary `ma_off_long`), not literally infinite.
- Multi-agent window semantics, `region_set_map`, NavigationServer2D,
  mid-window node-property writes, `enter_cost`'s deeper mechanism,
  other engine builds/tick rates — all sibling-noted, none cased here.

## Draft: lesson entry — `corpus/lessons/r76-navagent-sync-window.md`

(Proposal; admission pending named non-author replay + parent verdict.
Modeled on `r75-navagent-map-mutation.md`.)

```markdown
# R76 — the setter→server-sync window is a strict per-class frame constant (Godot 4.7.2)

## Decision and evidence

NavigationServer3D mutations under a committed `NavigationAgent3D` path
resolve on TWO distinct clocks, both frame-exact on this build
(`4.7.2.stable`, 60 tps, headless):

1. **object-getter edge ≈ 1 frame** — `link_get_enabled`,
   `region_get_transform`, `map_is_active`, `link_get_iteration_id` read
   post-setter truth one physics frame after the write.
2. **query/serve edge** — the `map_get_iteration_id` bump that publishes
   dirty to agents, after which the next forcing call re-queries:
   - **link-class writes** (`set_enabled`, `set_navigation_layers`,
     endpoint moves, `free_rid`): stale at wait 0 and 1, post-sync at
     **wait ≥ 2**.
   - **region-class writes** (`set_enabled`, `set_navigation_layers`,
     `set_transform`, `set_navigation_mesh`): stale at 0/1/2, post-sync
     at **wait ≥ 3**.
   - **agent-side `navigation_layers`**: **0 — synchronous** (same-turn
     clear to `[]`), a different channel entirely.
   - **`map_set_active`**: **no edge — permanent-stale**. The map leaves
     the sync iteration: flag flips at f1, `mapiter` never bumps, dirty
     never surfaces, and the committed tuple (`reachable=true`
     included) is served through arbitrary forcing calls with NO latch —
     distinct from `mut_latch_zombie` (latch = agent early-return while
     the server still syncs; here the server never syncs). Writes queued
     while inactive flush at the normal edge after reactivation
     (restart-on-reactivation, not apply-on-write).

Inside the window the forcing update still RUNS on the last-synced map:
`mut_win_link`'s tp+mutate+wait:0 step serves the killed gate's far
endpoint `(2.5,0,5.5)` AND pops idx 2→3 across it — the r75
same-turn-zombie falsification is now a tracked CASES row. At the edge
frame itself the pre-force `peek` still shows the stale stored array:
map synced, agent not yet re-queried — the two-stage gate pinned at
frame resolution.

The constants are strict: boundary resampled 54/54 (link) + 24/24
(region) in-process transitions and 96 cross-process bisects; scribe's
independent geometry reproduced byte-identical edges with 3× repeats;
scout converged. **Callsite qualifier (measured, critic `bb_physmut`)**:
a setter issued inside `_physics_process` drains in that same tick —
the serve flips at await-count **1**, one tick shallower than the
coroutine/deferred context every CASES `wait` uses. Frame constants are
per-callsite-class.

## Same-value suppression

Writes of the already-current value are fully suppressed no-ops on every
probed channel — `link_set_enabled`, `link_set_navigation_layers`,
`link_set_travel_cost`, `region_set_enabled`, `region_set_transform`
(a full `Transform3D` value compare), `region_set_navigation_layers`,
`map_set_active`, `agent.navigation_layers` — proven by the M-witness:
teleport on-path without re-query, write same value, post-window forcing
call; suppressed ⇒ stored array byte-identical, dirtied ⇒ `path[0]`
re-anchors at the live position. `agent.navigation_layers` dedups
BEFORE its synchronous clear: same-value leaves the array intact
same-turn, an effective write clears it to `[]` instantly. **Carve-out:**
`target_position` same-value assignment is NOT suppressed — it
unlatches, clears, and lazily rematerializes (r74 `mv_reanchor_same`).

## Authoring consequences (fixture)

- `wait` in `_run_steps` counts `await physics_frame` after the step's
  mutate; consecutive steps sample cumulatively — `mutate+wait:0` IS the
  same-turn arm.
- The `_final_srv_state` readback gate sees object truth at ~1f: an arm
  whose LAST mutate must pass the gate needs ≥1 elapsed frame before
  arm end; mid-step `wait:0` mutations are fine (reviewer-verified
  bound: terminal `mutate`+`wait:0` exits 1 by design).
- `map_active` is a new `mutate` key applied last in a dict; the setup
  gate now reads `map_is_active(map) != fs["map_active"]`.

## Recheck conditions

Any engine rebuild re-runs `mut_win_*`: edges 2/3 and the
permanent-stale `map_off` pin are engine internals measured, not
specified — the first casualty of an "inactive maps still flush" change
is `mut_map_off` (by design). Physics-callsite arms would pin the
one-tick-shallower window if the fixture ever writes from
`_physics_process`. `map_force_update` collapses only the getter edge
(0), not the serve edge — a tracked `force_update` arm would close that
gap.
```

## Draft: LOG.md round-76 entry

    ## Round 76 — devin host — coverage: the setter→server-sync WINDOW pinned as tracked CASES

    - Declared (dispatch brief): pin the same-turn setter→server-sync
      window — mutate + forcing read at wait=0/1/2, map_set_active(false)
      reachability, same-value-mutation suppression; 156 rows + 4 probes
      + Node 31/31 stable. Claim: frame-measurable — same-tick forcing
      call serves pre-mutation, wait>=1 serves post-sync, exact frame
      count a stable constant.
    - Wave `shokunin-train-20261014-w7`: 8-seat devin leaf set
      reports/round-76/r76-{scout,author,critic,reviewer,simplifier,
      scribe,baseline,boundary}.md; sole tracked writer = author;
      committed mid-round `3ab09fd` (navagent3d_detour.gd +290/−6,
      run_battery.py +14/−0 → 163 rows; `map_active` mutate key +
      fs-folded gate). Frozen baseline cb6bf7b → 156/156 + probes +
      Node 31/31 verbatim.
    - Author reports/round-76/r76-author.md: 7 new CASES —
      mut_win_link (link edge 2f; wait:0 serves AND pops idx 2→3 across
      the killed gate — dead endpoint next=(2.5,0,5.5)),
      mut_win_region (region edge 3f, stale 0/1/2), mut_map_off
      (permanent-stale: iter never bumps, reachable=true served through
      +15f, no latch), mut_map_cycle (queued write flushes at +2f
      post-reactivation), mut_same_{link,region,agent} (same-value
      suppression via M-witness; agent dedups before its synchronous
      clear). Battery 163/163 + 4 probes + Node 31/31.
    - Result — claim CONFIRMED in substance, FALSIFIED as written
      twice: "wait>=1 serves post-sync" is still stale at +1f on both
      classes (true edges link=2, region=3), and no single constant
      exists — per-class {link:2, region:3, free_rid:2, map_off:∞,
      agent:0} and callsite-scoped (physics-callback writes one tick
      shallower). Four independent derivations converge (author, critic,
      boundary 54/54+24/24 resamples, scribe own-geometry 65-run bisect)
      + r75-boundary report-side precedent. Same-value suppression
      confirmed on all probed setters (target_position carve-out: r74).
      Scribe independent replay: 7/7 arms verbatim, full battery
      163/163 + 4 probes + seeds_unchanged, 156 prior rows byte-identical
      vs frozen baseline, Node 31/31.
    - Non-author verifier reports/round-76/r76-verifier.md: AGREE 5/5 —
      163/163 + 4 probes + Node 31/31 on committed 3ab09fd.
    - Per-axis verdicts (Sol, adjudicator pending at write): coverage
      improved (the window is now case-pinned, not report-pinned).
      Commit `3ab09fd`; report-last follows.

## Touched surfaces (this seat only)

- `corpus/live/r76-scribe/scratch/r76s_syncwin.gd` — own probe
  (sha256 `d9f55f69…a45691`); `scratch/project.godot` — verbatim seed
  copy (sha256 `1fda90d4…8eac23`).
- `corpus/live/r76-scribe/run_arms.sh` — own runner
  (sha256 `52751f64…ce7f`).
- `corpus/live/r76-scribe/runs/` — 65 arm receipts, each
  `{.stdout.txt,.stderr.txt,.exit}`; all exit 0, all stderr empty.
- `corpus/live/r76-scribe/author-replay/` — committed-fixture copy +
  7 standalone arm receipts.
- `corpus/live/r76-scribe/runs-battery/20261014T101915045860Z/` — own
  full-battery receipt (`verdicts.json`, 163/163, verdict PASS) +
  probe verdicts + `battery-full.out` stdout.
- `corpus/live/r76-scribe/node/run_*.json` — six Node receipts, 31/31.
- This report: `reports/round-76/r76-scribe.md` — the only tracked-path
  write (authored report content, not a fixture edit).

## Out of scope / non-actions

- No commits, no pushes, no merges/rebases/checkouts/stash, no subagent
  dispatch (LEAF). No edits to `corpus/fixtures/` or any tracked file;
  sibling `corpus/live/r76-*` read for convergence only. The mid-round
  commit `3ab09fd` was the parent's integration, observed not performed.
- The lesson draft above is a proposal fenced inside this report — I
  did not write `corpus/lessons/r76-*.md` (the brief assigns the draft,
  not the landing); the LOG.md entry is likewise a draft.
- Not a verdict: admission is the canonical Rust judge's; verifier/
  adjudicator slots were still pending at write time.
