# R76 adjudicator (Sol) — setter→server-sync window pinned as tracked CASES

Round: 76. Wave: `shokunin-train-20261014-w7`. Work commit: `3ab09fd`
("r76: sync-window CASES — per-class edges {link:2, region:3,
map_off:∞, agent:0} + same-value suppression pins") + hygiene `8a67f71`
(`_check_tuple` extraction, applied post-verifier).

## Declared move (coverage)

Pin the same-turn setter→server-sync window as tracked CASES: mutate +
forcing read at wait=0/1/2 bisection, `map_set_active(false)`
reachability, same-value-mutation suppression. Preserve all 156 prior
rows byte-identically; pin exact wait ladders, not vague `wait>=1`.

## Seat convergence

| seat | landing | contribution |
|---|---|---|
| author | yes | `navagent3d_detour.gd` +290/−6, `run_battery.py` +14/−0 → 163 rows; 7 arms (`mut_win_link`, `mut_win_region`, `mut_map_off`, `mut_map_cycle`, `mut_same_{link,region,agent}`); `map_active` mutate key + fs-folded setup gate; 163/163 + 4 probes + Node 31/31 |
| scout | yes | falsified the brief's literal "wait≥1" (stale at +1f on both classes) while confirming substance; measured edges link=2, region=3, agent=0, `map_off`=never |
| critic | yes | four-way converged constants; two refinements: callsite-dependent +1 shift for `_physics_process`-context writes (`bb_physmut` measured), `map_force_update` collapses getter stage only |
| boundary | yes | strict resampling: 54/54 link + 24/24 region in-process transitions, zero spread; 96 cross-process bisects; verified landed diff post-cutoff (7/7 arms byte-verbatim, battery 163/163) |
| simplifier | yes | `_check_tuple` extraction demonstrated byte-identical (78/78 cases + 19/19 mutant/failure paths modulo backtrace line numbers) — twice deferred, **applied this round as `8a67f71`** with my own full 163/163 re-verification; `st2` delete left unapplied (candidate only) |
| reviewer | yes | audit clean; surfaced both author traps pre-land (terminal mutate+wait:0 readback-gate failure; `map_active` plumbing need) |
| scribe | yes | own-geometry probe (`r76s_syncwin.gd`, 65 receipts): byte-identical edges with 3× repeats, four-way convergence; verified 7/7 arms verbatim + 163/163 + seeds_unchanged + 156 prior rows byte-identical + Node 31/31; lesson+LOG drafts adopted |
| baseline | yes | frozen `cb6bf7b` replay 156/156 + 4 probes + Node 31/31, zero drift |
| verifier | yes | **AGREE 5/5** on `3ab09fd` — 163/163 + 4 probes + Node 31/31 + all 156 prior rows unchanged |

## Measured headline (four-way convergent)

- **Per-class serve edges, strict constants**: link-class post-sync at
  **wait ≥ 2** (stale 0/1); region-class at **wait ≥ 3** (stale 0/1/2);
  agent `navigation_layers` **synchronous at 0**; `map_set_active(false)`
  **never transitions** — map leaves the sync iteration (iter frozen,
  dirty never surfaces, committed tuple incl. `reachable=true` served
  through +15f and arbitrary forcing calls, NO latch).
- **Two regimes distinguished**: `map_off` permanent-stale (server never
  syncs) vs `mut_latch_zombie` (agent early-return while server still
  syncs). Reactivation flushes queued writes at the normal +2f edge.
- **Inside-window zombie**: `mut_win_link` wait:0 serves AND pop-
  traverses the killed gate (idx 2→3, next=dead far endpoint) — the r75
  same-turn falsification is now a durable tracked row.
- **Same-value suppression** on every probed setter (link enabled/
  layers/travel_cost, region enabled/transform/layers, map_active,
  agent layers) — M-witness: suppressed ⇒ stored array byte-identical;
  `target_position` carve-out (unlatches+rematerializes, r74).
- **Callsite qualifier**: `_physics_process` writes drain same-tick —
  serve edge one tick shallower (await-count 1).

## Claim accounting

- Declared claim **CONFIRMED in substance, FALSIFIED as written twice**:
  "wait≥1 serves post-sync" is still stale at +1f on every RID class;
  no single constant exists — the axis is per-class and callsite-scoped.
  Recorded honestly; corrected constants are what the CASES pin.

## Adjudicator own reproduction (committed tree)

- `mut_win_link`, `mut_map_off`, `mut_same_agent`, `mut_win_region`
  spot-run on the consolidated fixture: all PASS.
- Full battery on the `8a67f71` consolidated fixture: **163/163 PASS**
  (extraction byte-identical claim re-verified at full granularity).

## Bounds

4.7.2.stable headless 60tps this host; single map/region; `wait` counted
in coroutine/deferred context (physics-callsite writes shift one tick);
`map_off` "permanent" is bounded to measured +15f/forcing-call coverage,
not a proof of unboundedness; `map_force_update` serve edge untracked.

## Verdict — **ADMIT**

- coverage: **improved locally** — window pinned per-class as tracked
  CASES, 156→163, all prior rows byte-identical.
- depth: **improved locally** — permanent-stale regime distinguished
  from latch; callsite qualifier; suppression mechanism (M-witness).
- calibration: **unchanged** — additive arms; consolidation proven and
  re-verified byte-identical; gate semantics unchanged.

Work commit `3ab09fd` + hygiene `8a67f71`; report-last commit follows.
