# game-dev-3d round 78 — scout (seat: scout, host: devin)

Axes under mapping: **boundedness of the `map_set_active(false)` permanent-stale
regime** (r76-adjudicator: "bounded to measured +15f/forcing-call coverage, not a
proof of unboundedness" — `reports/round-76/r76-adjudicator.md:68`) and the
**mutation callsite split** (r76-critic `bb_physmut`: `_physics_process` writes
drain same-tick, serve edge −1 tick — measured but scratch-level only, never
tracked). Lane root used: `~/Projects/shokunin/game-dev-3d-shokunin` (the
brief's `~/Projects/prymeagnt/game-dev-3d` is the meta worktree; its
`.shokunin/game-dev-3d` symlink points here). HEAD `71818b7` (r77 report-last),
173 battery rows, working tree clean before and after (all probe files live
under ignored `corpus/live/r78-scout/`).

Independent evidence: probe copy of the committed fixture at
`corpus/live/r78-scout/scratch/navagent3d_detour.gd` (sha256 `ef00b439d610a338`,
seed `corpus/fixtures/navagent3d_detour.gd` + 4 additive deltas (inner
`PhysMutator` class, `phys_mutate`/`fire_at` step key, `map_iter` srv_get key,
`phys_mutate` fs fold) + 3 probe arms) + verbatim `project.godot` (sha256
`1fda90d46b0529ae` = `corpus/fixtures/project.godot`, 60 tps). Godot
`4.7.2.stable.arch_linux.ed1daf0bf` via `/usr/bin/godot --headless`. **10 runs
total — 7 on the 3 new probe arms (`r78_csite_ph` ×4, `r78_mapoff_lad` ×2,
`r78_offkill_lad` ×1), 3 on committed baselines — all exit 0, all stderr
byte-empty**; receipts
`corpus/live/r78-scout/runs/<arm>.{stdout,stderr,exit,elapsed_ms}.txt`.

## (1) How the current map_off arms express waits — the rung ladder shape that already exists

Step-level `"wait"` = physics frames of `await physics_frame`, cumulative across
steps (`_run_steps`, `corpus/fixtures/navagent3d_detour.gd:2183-2184`; default 5).
Intra-step order is `set_target → tp → mutate → wait → read` (:2176-2184);
`peek_*` (non-forcing stored-array read) and `srv_get` (object-level getter
readback) are captured post-wait, pre-forcing-read (:2186-2190, asserted
:2386-2422).

Existing inactive-map wait shapes, all on the same island+server-link geometry:

| arm | inactive wait | shape | line |
|---|---|---|---|
| `mut_map_off` | **15f total** (0+10+5, never reactivated) | three forcing reads under off, all committed tuple | :1527-1556 |
| `mut_map_cycle` | ~8f (off@w3, link kill queued under off @+5f) | kill-while-off, then reactivate → 2f edge replays | :1562-1596 |
| `mut_ord_kill_mapoff` / `mut_ord_mapoff_kill` | 5f (default wait on the combined/kill-under-off step) | apply-order pair; reactivate w1 stale → w1 fresh clamp | :1778-1848 |

The derived-edge shape is the `"ladder"` cfg (`{"bound":N,"groups":M}`,
`_run_motion_arm` :2431-2454): the per-step SERVED tuples are partitioned by
`_tuple_sig` (:2036); first boundary index = derived edge, printed as
`bound=… groups=… sizes=…` in the PASS marker (:2462-2465).
`mut_ladder_link` bound=2 sizes=2,2; `mut_ladder_region` bound=3 sizes=3,2.
The `fw_*` names are **r74/r75 critic-scratch** probes (`fw_mapedit`,
`fw_layermask`) that landed as `mut_region_move`/`mut_layers_region`
(fixture comments :1294, :1310; `reports/round-75/r75-baseline.md:169-174`) —
not a tracked family. **No rung ladder with non-unit waits exists yet** —
all current ladders are unit-wait; the rung {20,60,120,300}f shape is new.

## (2) 300f feasibility — fits with ~13.7s headroom

- `CASE_TIMEOUT_SECONDS = 20` (`corpus/fixtures/run_battery.py:36`), applied to
  the whole Godot child via `subprocess.run(timeout=…)` (:448, called per case
  :768); per-case `elapsed_seconds` is recorded (:775). Physics pinned at
  `common/physics_ticks_per_second=60` (`corpus/fixtures/project.godot:20`) —
  **`physics_frame` is wall-clock paced, not fast-forwarded**: 300f ≈ 5.0s.
- Measured wall times on this host (`runs/*.elapsed_ms.txt`):
  `mut_map_off` 1447ms, `mut_ord_kill_mapoff` 1368ms, `mut_ladder_link` 1318ms
  (~1.35s baseline ≈ boot + 30f settle + small step budgets);
  **`r78_mapoff_lad` 6296ms and 6326ms** (30f settle + 302 step-frames) —
  per-frame ≈ 19ms including boot, consistent with real-time pacing.
- Worst r78 rung shape fits in ~6.3s < 20s; even the 300f rung as a standalone
  arm ≈ 5.5-6s. No timeout risk. Battery rows are exact-stdout marker rows —
  each new arm needs its own CASES line with the full PASS string (rows at
  `run_battery.py:202-231` for the r76/r77 family).

## (3) Where the callsite split lives — and what a tracked arm needs

Today `navagent3d_detour.gd` issues **every** mutation from the SceneTree
coroutine: `_initialize → call_deferred("_run")` (:239-240), `await
physics_frame` between steps; `_apply_mutation` runs at resume time (:2180-2182,
:2222-2269). **No `_physics_process` exists in the fixture** — the callsite
context lives only in scratch instruments:

- `corpus/live/r76-critic/scratch/r76c_window.gd:37-45` — `PhysMutator extends
  Node3D` fires `link_set_enabled(link,false)` at its `tick_seen == 2`.
  Receipt `corpus/live/r76-critic/runs/bb_physmut.stdout.txt`: at the first
  post-fire read `link_iter=2 en=false` already applied (same-tick drain);
  serve still stale; fresh at the next read → **edge 1 vs coroutine's 2**.
- `corpus/live/r77-boundary/scratch/navagent3d_applyorder.gd:62-74` — same
  pattern generalized: `fire_at` tick, `harness._apply_seq(w, seq)`; r77-boundary
  measured `phys_loff` fstar=1 vs coroutine fstar=2, and the −1 shift on every
  sequence edge (`reports/round-77/r77-boundary.md:147-169`).
- r77-reviewer replayed `bb_physmut` byte-identical — **from a copied scratch
  script** (`reports/round-77/r77-reviewer.md:140-141,183`): the finding has
  never been a tracked CASE.

Probe (this round, inside the real fixture's machinery): added inner
`PhysMutator` + step key `phys_mutate` (fires the same `_apply_mutation` dict
inside `_physics_process` at `fire_at`) to my scratch copy. New arm
`r78_csite_ph` = same `{link_enabled:false}` dict, `fire_at:1`, `wait:1` first
sample → **PASS `bound=1 groups=2 sizes=1,1`, 4/4 byte-identical** vs coroutine
twin `mut_ladder_link` `bound=2 sizes=2,2` — the −1 edge shift lands inside the
fixture, with `srv_get {link_enabled:false, link_iter:2}` pinning the same-tick
drain at the post-fire read. Fixture deltas a tracked version needs:

1. inner `class PhysMutator extends Node3D` (or a sibling driver `.gd` like
   `navfollow3d_driver.gd` — but the seed is one file per fixture; inner class
   keeps that shape);
2. the `phys_mutate`/`fire_at` step keys in `_run_steps` (spawn before the wait
   loop, `root.add_child` + `owned_nodes.append` — **a mutator leaked at `quit`
   trips the battery's `LEAKED_OBJECTDB` classify gate**, `run_battery.py:486`);
3. `phys_mutate` folded into `_final_srv_state` (:2317+) or the link-flag
   honesty gate fails (`link_enabled` expected true, read false);
4. **fire-at/read-schedule caveat**: served tuples are signature-identical
   pre- vs post-fire while stale, so pre-fire samples collapse into group 0 —
   the arm's first read must be post-fire for `bound` to reflect the shifted
   edge (fire_at=1 + first sample after wait:1 → bound=1).

## (4) Predicted rung outcomes — measured at scratch level on BOTH phrasings

Probe arms (cumulative single-arm ladder: reads at cumulative 20/60/120/300f):

- `r78_mapoff_lad` — `{link_enabled:false, map_active:false}` one dict
  (mut_ord_kill_mapoff order): **PASS 6.3s ×2**, `steps=6 bound=5 groups=2
  sizes=5,1`.
- `r78_offkill_lad` — map off @w3 then link killed under the inactive map
  (mut_map_cycle order): **PASS 6.3s**, `steps=7 bound=6 groups=2 sizes=6,1`.

Predicted per model:

- **Permanent-stale (measured)**: every rung serves the committed pre-mutation
  tuple verbatim; `srv_get` at each rung reads `{map_active:false,
  link_enabled:false, link_iter:1, map_iter:2}` — the write applies at getter
  level under off but **iters never stamp without a sync** (no late flush
  through 300f in 2 orderings × this build). Reactivation replays the 2f edge:
  w1 stale → w1 fresh clamp (both arms PASS on that tail).
- **Late-flush (would falsify)**: the first flushing rung's tuple/peek/iters
  differ → `_run_motion_arm` fails at that step index, whose cumulative wait
  IS the measured bound. The falsifiable surface is exactly
  tuple/peek/link_iter/map_iter per rung — my `map_iter` srv_get key
  (`map_get_iteration_id`) is **absent from the committed `_read_srv`**
  (`navagent3d_detour.gd:2278-2294` knows `link_iter` but not `map_iter`); the
  author needs it (or equivalent) to pin "map_iter bump" as the falsification
  witness rather than only the served tuple.

## Confidence and remaining unknowns

- High: wait semantics, timeout budget, callsite file/class layout, −1 edge
  shift (scratch-verified inside the fixture, 4/4 identical; consistent with
  r76-critic + r77-boundary receipts).
- Medium-high: permanent-stale through 300f — 2 orderings, 1 rep each (plus
  the pair of 300f-capable runs byte-stable). A longer rep grid is
  boundary/reviewer's job; r77 found link-edge jitter {w1,w2} **only under
  `map_force_update`** (mark-vs-phase), and the callsite arm showed no spread
  in 4 reps — but the natural-edge determinism at 20f+ rungs is unproven.
- Unknowns for the author: (a) whether to pin `map_iter` at the reactivation
  reads — I left it unpinned there (receipt `bb_mapoff_kill` shows link_iter
  bumps at on_w1 while map_iter stays 2 — stamping is per-object, not
  per-map-tick; rung pins at 2 are safe, reactivation pins are not authored
  yet); (b) arm-count shape — one cumulative arm (my probe shape, cheapest,
  falsification lands at a step index) vs 4 rung arms (4× rows, each ~1.4-6s);
  (c) whether the paired callsite arm should be a `mut_ladder_link` twin
  (bound 2-vs-1, my probe shape) or a `mut_win_link`-style tp arm — the
  ladder twin is the minimal receipt of the shift.
