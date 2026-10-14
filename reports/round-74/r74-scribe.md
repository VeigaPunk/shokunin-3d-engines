# Game-dev-3d round 74 — scribe report (seat: scribe, host: devin)

Declared lane axis-move (from dispatch): formalize MOVING-AGENT
`NavigationAgent3D` semantics as tracked CASES arms on the detour fixture —
the r71–r73 surface was stationary/single-teleport. Declared falsifiable
claims: (a) the stored path array is FROZEN at target-assignment (locomotion
does not re-query the map) while `distance_to_target`/`next_target` remain
live call-time arithmetic; (b) the pop index follows live agent position —
a teleported/stepwise-moving agent advances idx per the strict-`<` Euclidean
pop rule against the stale stored path; (c) reached/finished latch semantics
under motion — once reached fires it stays latched even if the agent moves
away (or measure the actual unlatch condition); (d) re-anchoring:
`target_position` re-assignment mid-path re-queries the map from the agent's
LIVE position (boundary measured bank-side). Additive `--arm=` presets;
127 prior CASES rows + 4 probes + Node 31/31 stable. Scribe duty:
independent derivation of the four claims in own scratch + the lesson
draft (`corpus/lessons/` convention); report-only, not the judge.

Canonical repo `~/Projects/shokunin/game-dev-3d-shokunin`, reached via
worktree symlink `~/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d`.
Engine `/usr/bin/godot` = `4.7.2.stable.arch_linux.ed1daf0bf` (same build
as r69–r73), Python 3.14.7, 30-frame settle convention, one process per arm.

## Measured evidence (scribe-observed, own scratch)

Own probe `corpus/live/r74-scribe/scratch/motion_z_probe.gd` sha256
`683e9cbe5eac4879eaf34d89bd1ce6fc1d8fad824efcd550a0ee7998cf8debff`
(current file; the first 15 receipts ran an earlier revision that lacks
only the `mz_lazy*` pair — the two new arms were appended after, outputs
below). Authored fresh for this seat: own geometry, own `MZPROBE`/`MZSIG`
output format, own arm names. `project.godot` byte-identical to
`corpus/fixtures/project.godot` (sha256 `1fda90d4…8eac23`).

**Own geometry** (differs from every sibling — author/critic use the
L-corridor + island + link): a 5-quad Z/S corridor built from
`NavigationServer3D` calls — Q2 `x[0,1]z[0,1]`, Q1 `x[1,4]z[0,1]`,
Q3 `x[0,1]z[1,4]`, Q4 `x[0,1]z[4,5]`, Q5 `x[1,4]z[4,5]`, exact shared
edges; the interior `x(1,4] z(1,4)` is VOID (nearest-bank re-anchor
testable on plain region geometry, no links). `S=(3.5,0,0.5)` on Q1 →
`T=(3.5,0,4.5)` on Q5: euclid 4.0 but the routed path dog-legs through
`(1,0,1)` and `(1,0,4)` — stored path
`[S,(1,0,1),(1,0,4),T]` npath=4, pathlen=8.099020, idx=1 at settle.
Defaults measured per run via MZCFG: `pmd=5.0 pho=0 post=0 meta=7
layers=1 avo=false`.

Command per arm (cwd `corpus/live/r74-scribe/`):

    timeout 60 /usr/bin/godot --headless --path scratch \
      --script res://motion_z_probe.gd -- --arm=<name> [--pdd=F --tdd=F --step=F]

19 own-probe runs (18 distinct arms + `mz_steps_b` determinism repeat,
byte-identical stdout) — all exit 0, all stderr empty; receipts
`corpus/live/r74-scribe/runs/<arm>.{stdout.txt,stderr.txt,exit}`.
(`mz_steps_b` is a repeat with stdout only — no .exit/.stderr captured;
stdout is byte-identical to `mz_steps`.)

### (a) Frozen path + live call-time arithmetic — CONVERGE, with the boundary sharpened

- `mz_walk` — a feedback driver moving `0.12` per tick toward
  `get_next_path_position()` for 47 ticks to finish: `path_frozen=true`
  at every sampled step and `dev=0.000000` always — `dist` equals
  hand-computed `euclid(live,T)` each tick (`runs/mz_walk.stdout.txt`).
  Locomotion never re-queried the map on this geometry.
- `mz_steps` — 8 scripted teleports along the route then back to spawn:
  `frozen=true` at all 8 steps while `dist` tracked live euclid
  (4.0 → 0.1 → 5.0). Same-model `sim_idx` (the r72 strict-`<` sequential
  rule simulated on the STORED array) matched engine idx at all 8 steps.
- `mz_freeze` — teleport to `(0.5,0,2.5)` mid-column: on-mesh, and a
  fresh query there WOULD differ (proven by `mz_reanchor_onmesh`, which
  produced `[(0.5,0,2.5),(1,0,4),T]` on re-assign) — yet the stored
  4-point path stayed `frozen=true`. Locomotion does not re-query even
  where a fresh query would materially differ.
- `mz_calltime` — same-frame after teleport: `idx_raw=1` (stale commit),
  `distance_to_target()=4.272002` = live euclid **without committing**,
  idx still 1 after it; then `get_next_path_position()` popped to 2
  inside the call. `mz_ticktime` — 3 physics frames post-teleport with
  zero queries: idx stayed 1 — **ticks never pop; the agent is fully
  lazy** (converges with r74-scout `probe_getorder`/`triggers` and
  r74-critic `probe_lazy_*`/`pop_tick_only` on their geometries).
- **Boundary sharpening (mine)**: `mz_pmd` drift ladder vs stored
  `path[1]=(1,0,1)`, pmd=5.0: `euc=4.900000` → `frozen=true`;
  **`euc=5.000000` exactly → re-query fires** (path re-anchored to
  `[(0,0,1),(1,0,4),T]`, idx reset 0); `euc=5.099020` stays re-anchored.
  Both operands are exact in IEEE-754 (dx=5.0, dy=dz=0 → sqrt(25)=5.0;
  pmd=5.0 default), so the measurement discriminates the comparator:
  the keep-frozen predicate is `euclid(agent, path[idx]) < pmd`
  **strict** — equivalently the repath triggers at `>=`, equality
  included. The author's fixture header/report write "(default 5.0,
  STRICT >)" and bisected 4.995-frozen / ~5.025-requery
  (`mv_pmd_edge`, `fp_edge_lo/hi`); their `fp_edge_eq` point was
  `(2.5,0,5.975)` = euclid **5.000062**, just above the boundary — no
  seat's prior data included a true-equality point. All sibling
  datapoints are consistent with mine; only the equality placement is
  new. Carried verbatim in Convergence.
- What the pmd gate measures: distance to the CURRENT `path[idx]`, not
  `path[0]` — at `(-3.9,0,1)` euclid to `path[0]=(3.5,0,0.5)` is 7.42
  (would breach immediately) yet stayed frozen at euclid-to-path[1]=4.9.
  Converges with the author's "CURRENT next waypoint" wording.
- Second-half of (a) on `next`: `get_next_path_position` is live only in
  that it runs the forcing update on live position — it returns STORED
  waypoints, never a fresh map query (within pmd). `distance_to_target`
  is pure call-time euclid to the RAW `target_position` (author's
  `mv_reanchor_void` proves raw-target: dist=1.6 to `(2.5,0,5.5)` while
  clamped `final=(2.5,0,4.0)`; my `dev`/`euc` columns confirm equal-value
  on reachable targets).

### (b) Pop follows live position — CONVERGE (strict-< sequential, monotone, call-time, no-skip)

| arm | observation |
|---|---|
| mz_steps | engine idx = r72-model `sim_idx` at all 8 teleports (incl. multi-step ladder and return-to-spawn) — the pop rule runs on the STALE stored path each step |
| mz_eq | agent at `(2,0,1)`: euclid to `path[1]=(1,0,1)` = **1.000000 == pdd → NO pop** (idx stays 1); at `(1.99,0,1)` → idx 2. Strict `<` under motion, same rule as r72 stationary |
| mz_backtrack | teleport beside path[2] while idx=1: euclid→path[1] 2.62 > pdd even though euclid→path[2] 0.5 < pdd — **idx stays 1; sequential pop cannot skip**; later landing near path[1] pops to 2 |
| mz_regress | idx advanced 1→2→3 on a live unfinished path, then retreat beside `path[1]`: idx **stays 3** — monotone non-decreasing, never un-pops |
| mz_skip | teleport adjacent to T (euc 0.1 < tdd) at idx=1: **idx stays 1, `next` still returns stored `path[1]=(1,0,1)` BEHIND the agent**, while `rched=true fin=true` fire anyway — raw-euclid flags decoupled from the sequential idx (same shape as author `mv_popskip`, critic `pop_skip`) |
| mz_calltime | the pop happened INSIDE the `get_next_path_position` call (idx 1→2 in one call sequence, 0 frames) — call-time on live position |
| mz_lazy | bonus equality datapoint: post-re-anchor path[0]=(3,0,1), agent at (3,0,2), euclid=1.000000==pdd → idx stays 0 — strict-`<` again on a re-anchored array |

### (c) Latch under motion — CONVERGE; unlatch measured = any `target_position` assignment

- `mz_latch`: teleport to `(3.2,0,4.3)` (euc 0.36 < tdd 1.0) → `rched=true
  fin=true` at t33. Retreat to `(0.5,0,0.5)` (euc 5.0): **both stay
  latched**, path frozen, idx stays 1. Same-value `target_position=T`
  re-assignment then unlatches: `rched=false fin=false`, fresh
  `path_changed` at t45, path re-anchored at live `(0.5,0,0.5)` =
  `[(0.5,0,0.5),(0.5714,0,1.0),(1,0,4),T]`, idx re-pops to 2 inside that
  same update — **no same-value dedup**.
- `mz_steps` s7: post-finish retreat keeps `rched/fin=true` AND the stored
  path frozen — at euclid-to-`path[3]` == 5.0 == pmd, i.e. at what my
  `mz_pmd` shows is the breach boundary: the finished latch suppresses
  even a boundary-distance pmd re-query (author's `mv_latch` claim and
  simplifier's `pmd_--tpx_10.6_--latch` receipt — fin=true keeps the stale
  path at 10.6 — corroborate at a decisive distance).
- `mz_walk`/`mz_skip`/`mz_steps` all end latched; the latch survives
  arbitrary scripted motion. No motion-only unlatch observed anywhere.

### (d) Re-anchor from live position — CONVERGE, incl. the lazy-materialization edge

| arm | agent position at re-assign | observed new path[0] |
|---|---|---|
| mz_reanchor_onmesh | `(0.5,0,2.5)` on-mesh | `(0.5,0,2.5)` exact — live pos verbatim |
| mz_reanchor_void_lo | `(3,0,2)` void, 1.0 above the south bank | `(3,0,1)` — navmesh clamp to the NEAR bank (Q1 edge z=1), full route resumes through both portals |
| mz_reanchor_void_hi | `(3,0,3)` void, 1.0 below the north bank | `(3,0,4)` — clamp to the NORTH bank, direct 2-pt path to T, `reach=true` |
| mz_retarget_new | `(0.5,0,2.5)`, retarget to NEW target S | `[(0.5,0,2.5),(1,0,1),S]` — live anchor to the new target, `final=S` |
| mz_lazy | set_target then teleport to `(3,0,2)`, NO read between | anchor = post-teleport clamp `(3,0,1)` — the query materializes at the position live at the FIRST FORCING CALL, not at assignment |
| mz_lazy_force | same, but a `_snap` (forcing read) between set and tp | `between` already shows `[(0.5,0,2.5),(1,0,4),T]` anchored at the READ-TIME position; stays frozen through the follow-up void teleport |

The two-bank discriminator is independent of the author's island/link
geometry — same bank-side semantics on a plain-region void. The lazy pair
converges with author `mv_reanchor_lazy`/`mv_reanchor_force` and critic
`fb_set_tp_pure`/`fb_set_tp`.

### Signal cadence (bonus observation, r73-UNKNOWN territory)

`MZSIG` logs: `path_changed` fires ONLY at materialization (t30) and at
each re-query (`mz_freeze` t50, `mz_pmd` t38, `mz_latch` t45, reanchor
arms t39) — never during ordinary pops. `waypoint_reached` fires once per
idx advance INSIDE the forcing update, payload `{position, type:0 REGION,
rid, owner:<Object#null>}` for region waypoints (e.g. mz_latch's
re-anchored pop emitted it for both `(0.5,0,0.5)` and the funnel point
`(0.5714,0,1.0)`). `target_reached`+`navigation_finished` co-fire in the
same update that latches (t33/t37/t77 across arms). `mz_calltime`'s
`t30:waypoint_reached{(1,0,1)}` was emitted inside the same-frame call
sequence — signals are call-time artifacts of forcing calls, not tick
broadcasts.

## Author-fixture verbatim replay (uncommitted working tree)

Working-tree snapshot copied into `corpus/live/r74-scribe/scratch/`:
`navagent3d_detour_wt.gd` sha256
`336898f4b711021a21e619385244e662168889ba5c52ec6812af9c5034601276` (=
current `corpus/fixtures/navagent3d_detour.gd`, +501/−5 vs committed
`0ae04750…`) and `run_battery_wt.py` sha256
`697b3d5fa0dcab147ee79016354e07dee52e6820777508cca237b27385f70f86`
(= working tree, +36/−0 vs `9f18a711…`). Command per arm:

    timeout 60 /usr/bin/godot --headless --path scratch \
      --script res://navagent3d_detour_wt.gd -- --arm=<name>

- **All 18 new `mv_*` arms: exit 0 + marker line byte-exact** vs the
  CASES literals (programmatic compare against `run_battery_wt.py` —
  `runs/wt/mv_*.stdout.txt`): `mv_walk` idxs 1,2,2; `mv_live` wait=0
  re-pop; `mv_popback` never un-pops; `mv_popstrict` eq-holds/
  0.01-pops; `mv_void` off-mesh frozen; `mv_pmd_edge` 4.995→5.025
  re-anchor; `mv_pmd_offmesh` (10,0,10)→(3,0,4) no-undo;
  `mv_pmd2` authored pmd=2 breach; `mv_latch` 10.63-past-path[1]
  stays latched+frozen; `mv_unlatch` same-value re-set unlatches;
  `mv_reanchor`/`_same` live-position anchors; `mv_reanchor_bank`
  routes through the link from the void edge; `mv_reanchor_void`
  unreachable-clamp `finished=true`; `mv_popskip` flags-decoupled
  no-skip; `mv_reanchor_lazy`/`_force` lazy materialization pair;
  `mv_bridge_walk` idx 2,3,3 through the link mid-void.
- **Prior rows on the modified fixture — 14/14 byte-exact**: base,
  `post_edgecentered`, `post_none`, `pop_lo`, `vert_pop_eq`, `tp_mid`,
  `tp_eq`, `edge_eq`, `fin_idx_gate`, `fin_wall`, `fin_latch`,
  `link_shortcut`, `link_oneway_rev`, `link_pop_void` — zero drift on
  this seat's replay (`runs/wt_prior/`). All 32 replayed runs
  (18 new + 14 prior, the base row inside the 14) exit 0, stderr empty.

## Wave state at observation time

- Seven seat reports exist in `reports/round-74/` (baseline, scout,
  reviewer, critic, author, simplifier — the latter two landed during
  this report's drafting — and this file). Boundary has only
  `corpus/live/r74-boundary/scratch/project.godot`. Simplifier verdict:
  **18/18 arms load-bearing, zero drops**; mutants m1–m7 killed;
  focused replays 18/18 mv_* + 9/9 prior detour rows
  (`corpus/live/r74-simplifier/runs/20261014T041834707273Z/` +
  `…1902175155Z/`); flags one weight item (the observable-tuple
  elif-chain now exists in three copies — shared-helper extraction
  warranted) plus two nits (dead `st2` store on the steps path, wasted
  `st` read on link arms). Trivial verbatim discrepancy for the judge:
  simplifier writes numstat "+506/−5" where `git diff --numstat` here
  reports +501/−5 (author agrees with 501). Verifier/adjudicator
  pending. The work commit is still
  **uncommitted**: `git status` = `M navagent3d_detour.gd`,
  `M run_battery.py`, `?? reports/round-74/`; numstat +501/−5, +36/−0.
- Author battery receipt
  `corpus/live/r74-author/runs/20261014T041431092173Z/verdicts.json`:
  **145/145 PASS** (100 ordinary / 45 negative = 127 prior + 18 new mv
  rows), `seeds_unchanged=true`, godot `4.7.2.stable.arch_linux.ed1daf0bf`,
  probes 4/4 per `runs/battery-r74-final.out` (mutation `detected=true`).
  Earlier author receipts: `…023611258293Z` 142/142 (15-arm intermediate),
  `…023536000831Z` 15/15 focused; `…024210983672Z` is a scratch-only
  interrupted capture. Node receipts `runs/node-run_*.json`: six suites
  PASS, `seedsUnchanged=true` (31/31).
- Baseline: frozen `e435a01` replay **127/127 + 4 probes + Node 31/31**,
  0-mismatch vs the r73-verifier receipt
  (`corpus/live/r74-baseline/runs/20261014T022543376829Z/`); moving-agent
  surface confirmed greenfield (`tp` was the only motion key).
- Reviewer: committed `e435a01` re-executed clean (127/127 + probes +
  Node 31/31, 0-mismatch vs r73-author receipt, 4/4 byte-exact link
  arms); re-flags the relative-`--runs` tree-timeout trap still absent
  from docstring/README/lessons. Audited BEFORE the author diff landed.
- Scout: lazy-update model measured first (forcing vs pure-reader getter
  split, 0-frame post-teleport reads, finished-freezes-update, bank
  sweep z∈(4.50,4.51] with mainland tie-break) — all consistent with
  what landed.
- Critic: 44-run audit post-claim-pre-diff — converges on substance and
  sharpened wording (freeze-point = first forcing call not assignment;
  sync-cleared dirty window; lazy map-edit/`navigation_layers`
  invalidation; `reachable` stays live under tdd changes; flag sampling
  call-time so transients invisible).

## Convergence — verbatim for the judge

All four declared claims CONFIRMED by the author (18 tracked arms,
145/145) and independently by this scribe on different geometry (plain
5-quad corridor with interior void, no links; 19 own-probe runs):

1. **(a)** Stored path stable under locomotion — verified under
   continuous next-chasing locomotion (47 ticks), 8-step teleport
   ladder, and mid-column positions where a fresh query would differ;
   `dist`==live euclid every observation (dev=0.000000). **Two wording
   corrections carried verbatim:** (i) "FROZEN at target-assignment" —
   the freeze point is the first forcing call, not the assignment
   (author + critic + my `mz_lazy` pair all agree); (ii) the pmd
   boundary: the keep predicate is `euclid(agent, path[idx]) < pmd`
   **strict** — **equality breaches** (my `mz_pmd`: exactly 5.000000 →
   re-query; author bracket lacked a true-equality point — `fp_edge_eq`
   was 5.000062). Read as "repath iff dist strictly `>` pmd" the author's
   "STRICT >" wording is falsified at equality; read as "within iff
   strictly `<`" it stands. Substance (pmd-gated lazy re-query vs the
   CURRENT `path[idx]`, authored pmd tracked) converges everywhere.
2. **(b)** Pop follows live position — convergent: strict-`<` Euclidean
   on the STALE stored path, sequential (cannot skip — my `mz_backtrack`/
   `mz_skip`, author `mv_popskip`, critic `pop_skip`), monotone
   non-decreasing (`mz_regress`, author `mv_popback`), call-time inside
   forcing getters (`mz_calltime`, author `mv_live`, critic
   `pop_tick_only`), equality does not pop (`mz_eq`, author
   `mv_popstrict`), works across link endpoints mid-void (author
   `mv_bridge_walk`).
3. **(c)** Latch holds under arbitrary motion — convergent: retreat to
   spawn or far off-mesh keeps `reached`/`finished` true; the finished
   latch early-returns the update (idx frozen standing on a live
   waypoint — critic `pop_after_finish`; pmd re-query suppressed at the
   breach boundary — my `mz_steps` s7, author `mv_latch`, simplifier
   10.6 receipt). Measured unlatch = ANY `target_position` assignment,
   same value included, no dedup (my `mz_latch` re-assign phase, author
   `mv_unlatch`, critic `lt_retarget_same_away`).
4. **(d)** Re-anchor from LIVE position — convergent incl. the sharpest
   edge: on-mesh → live pos verbatim; off-mesh → navmesh clamp of the
   live pos, nearest-bank discriminated on my plain-void geometry
   (z=2→south `(3,0,1)`; z=3→north `(3,0,4)`); new-target retarget
   re-anchors identically; the query materializes LAZILY at the first
   forcing call — same-window set+teleport anchors post-teleport
   (`mz_lazy` ↔ `mv_reanchor_lazy`/`fb_set_tp_pure`), a forcing read
   between pins the anchor (`mz_lazy_force` ↔ `mv_reanchor_force`/
   `fb_set_tp`).

**No conflicts on measured substance.** The one verbatim wording item for
the judge is the pmd-boundary strictness above (equality measured by this
seat only). Author-observed subtleties I did not independently re-derive
but which agree with critic/scout and my own partial observations: the
sync-cleared dirty window (`path=[]` + stale idx + `final`=raw target);
the one-read lag in `fp_edge_eq` S1 (next/idx re-queried while the same
call-sequence's `path` read showed the old array); `is_target_reached` as
a pure reader of the stored flag; `reachable` live-recomputed under tdd
change while latched; map-edit/`navigation_layers` lazy invalidation;
pdd/meta setters inert on the stored path.

## Retained UNKNOWNs (do not claim)

- The pmd-gate expression internals (which engine clause/comparator —
   measured behavior only; equality result stands regardless of source
   reading); whether distance is vs `path[idx]` or the current segment
   (my data pins `path[idx]` over `path[0]`, segment-vs-endpoint
   unseparated).
- Map/region mutation mid-path and `navigation_layers` flips as lazy
   invalidation triggers — critic-measured, not pinned by tracked CASES
   arms this round (recon, not battery).
- `reachable` live-recomputation while latched (critic `lt_tdd_shrink`),
   the empty dirty window, mid-turn `reached=false ∧ finished=true`
   incoherence — same status: sibling-measured, not CASES-pinned.
- Avoidance channel (`velocity`, `velocity_computed`, RVO),
   CharacterBody `move_and_slide` real locomotion — all motion here and
   in the tracked arms is transform assignment + re-target, per declared
   scope.
- `path_max_distance` interplay with `path_postprocessing`/
   `pathfinding_algorithm` setter invalidation, `simplify_path`,
   `path_height_offset`, distinct-map `set_navigation_map`,
   multi-region maps, vertical/non-Y-up motion, runtime link endpoint
   mutation, baked regions, other engine builds.
- r68/r69 `navagent3d_retarget` intermittence caveat stands
   unretracted (did not manifest in these runs).

## Draft: lesson entry — `corpus/lessons/r74-navagent-motion-review.md`

(Proposal; admission pending named non-author replay + parent verdict.
Modeled on `r73-navagent-link-gating-review.md` convention. Commit-sha
slots left pending — the diff is uncommitted at observation time.)

```markdown
# R74 — NavigationAgent3D moving-agent semantics (Godot 4.7.2)

## Decision and evidence

`NavigationAgent3D` on this build is fully LAZY: no per-tick agent update
exists. All observable state moves only inside "forcing" getters —
`get_next_path_position`, `get_final_position`, `is_navigation_finished`,
`is_target_reachable` — each of which synchronously runs the once-per-frame
update (requery-if-dirty, pop eval, flag eval) on the agent's LIVE node
transform. Pure readers never trigger: `get_current_navigation_path`,
`get_current_navigation_path_index` (return the last committed snapshot),
`is_target_reached` (stored flag — can read stale), `distance_to_target`
(pure call-time euclid to the RAW `target_position`, commits nothing).
Physics ticks with zero queries change nothing (pop included). Authoring
rule: any state capture must run a forcing call before reading
path/idx/reached, else it reads the previous commit; `set_target_position`
synchronously CLEARS the stored result (`path=[]`, `final`=raw target,
stale idx residue readable) and marks dirty — the re-query MATERIALIZES
inside the first forcing call afterward, anchored at the position live at
THAT call, not at assignment. A set+teleport in one no-read window anchors
post-teleport (author `mv_reanchor_lazy`, scribe `mz_lazy`); a forcing
read in between pins the anchor at read-time (`mv_reanchor_force`,
`mz_lazy_force`).

### Motion semantics table (all measured on `4.7.2.stable.arch_linux.ed1daf0bf`)

| surface | rule under scripted motion | discriminating receipts |
|---|---|---|
| stored path | stable under locomotion/velocity/ticks/non-query setters; NEVER re-queries while `euclid(agent, path[idx]) < path_max_distance` STRICTLY — equality breaches (measured 4.9 frozen / **5.000000 re-query** / 5.099 re-query, pmd=5.0); authored `path_max_distance` tracked (pmd=2 breaches at 4.53); breach re-queries lazily from live pos, `path[0]`=navmesh clamp, idx resets to 0; no undo on return | author `mv_walk`/`mv_void`/`mv_pmd_edge`/`mv_pmd2`/`mv_pmd_offmesh`, scribe `mz_walk`/`mz_steps`/`mz_freeze`/`mz_pmd` |
| pop index | monotone non-decreasing, SEQUENTIAL strict-`<` Euclidean vs the STORED path, evaluated on live pos inside the forcing call (0 frames needed); cannot skip a waypoint (`next` can point backward while flags fire); equality `==pdd` does not pop; advances through link endpoints as ordinary waypoints mid-void | author `mv_walk`/`mv_live`/`mv_popback`/`mv_popstrict`/`mv_popskip`/`mv_bridge_walk`, scribe `mz_steps`/`mz_eq`/`mz_backtrack`/`mz_regress`/`mz_skip`/`mz_calltime` |
| `reached`/`finished` | latch once fired — survive arbitrary motion incl. off-mesh and beyond-pmd; `finished` latching early-returns the update: pop loop AND the pmd re-query both freeze (latched agent 10.6 from `path[idx]` keeps the stale path; idx stays on a live waypoint under it). Measured unlatch: ANY `target_position` assignment — same value included, no dedup — which also clears the stored path and resets idx to 0 | author `mv_latch`/`mv_unlatch`, scribe `mz_latch`/`mz_steps` s7, simplifier `pmd_--tpx_10.6_--latch`, critic `pop_after_finish`/`lt_*` |
| re-anchor | `target_position` re-assignment (any value) re-queries from the agent's LIVE position: on-mesh → `path[0]`=live pos verbatim; off-mesh → navmesh clamp, nearest bank (scribe two-bank void pair: z=2→south, z=3→north; author island: `(2.5,0,3.9)`→link route or B-edge clamp unreachable→`finished=true` via the idx+pdd clause) | author `mv_reanchor`/`_same`/`_bank`/`_void`, scribe `mz_reanchor_*`/`mz_retarget_new`/`mz_lazy*` |
| signals | `path_changed` fires at materialization and each re-query only; `waypoint_reached` per idx pop inside the update, payload `{position, type, rid, owner}`; `target_reached`+`navigation_finished` co-fire in the latching update — all call-time artifacts, not tick broadcasts | scribe MZSIG logs (all arms) |

### Pop-under-motion vs the r72 stationary model

Identical gate — `while idx<size−1 and euclid(agent_live, path[idx]) <
pdd: idx++` — the only difference is WHEN it runs: never on ticks, always
inside a forcing getter on the live transform. The r72 strict-`<`,
sequential, non-skip, and finish-freeze clauses all hold under motion;
r74 adds the pmd invalidation gate, the lazy-materialization anchor rule,
and the finished-latch whole-update freeze.

### Invalidation triggers for the stored path

- `target_position` assignment — synchronous clear + lazy re-materialize
  (any value, no dedup). CASES-pinned.
- `euclid(agent, path[idx]) >= path_max_distance` at update time —
  equality breaches (scribe-measured). CASES-pinned (`mv_pmd_*`).
- Map data changes (`region_set_transform`, region `navigation_layers`)
  and agent `navigation_layers` — lazy invalidation, EMPTY path +
  `final=(0,0,0)` possible (critic `fw_mapedit`/`fw_layermask`/`fw_al_mid`)
  — measured, NOT CASES-pinned.
- `is_navigation_finished` latch — GATES OFF the whole update incl. the
  pmd re-query (author `mv_latch`, scribe `mz_steps` s7, simplifier
  10.6 receipt). CASES-pinned.
- Inert on the stored path: pdd/tdd/meta/enter_cost setters (critic
  `fw_pdd_mid`/`fw_meta_mid`; applied to the stale array next update),
  locomotion, velocity, idle ticks.

### Fixture

`navagent3d_detour.gd` gains the `steps` arm key (ordered steps; each may
`tp` the actor and/or `set_target` the agent — combined steps apply
set_target first — plus `wait` physics frames, default 5, `wait:0` reads
call-time) and optional `pmd` (`path_max_distance`); `_run_steps` +
`_run_motion_arm` pin the full per-step tuple INCLUDING the complete
stored path array — a path element that moved without an authored
re-query fails the step by name. 18 `mv_*` arms, all additive; battery
**145/145** (127 prior + 18 new), `seeds_unchanged=true`, 4/4 probes,
Node 31/31; prior rows byte-stable (scribe 14/14 spot + author full
replay 0-mismatch). The five deleted lines are mechanical (header line,
tp-branch fold, `expected_target` gate).

Receipts: `corpus/live/r74-author/runs/20261014T041431092173Z/` (145/145
full battery + probes + node `run_*.json`), `corpus/live/r74-baseline/
runs/20261014T022543376829Z/` (frozen 127/127), `corpus/live/r74-scribe/
runs/` (19 own-probe arms incl. determinism repeat + 18 wt mv-replays +
14 wt prior replays), `corpus/live/r74-scout/runs/` (8 probes, 91 lines),
`corpus/live/r74-critic/runs/` (44 arms), `corpus/live/r74-simplifier/
runs/` (in-flight probes); seat reports `reports/round-74/r74-*.md`;
pending r74-boundary/verifier + adjudication. Work commit: [pending];
adjudication-commit slot: [pending].

Recheck conditions: any engine rebuild re-runs the battery (pmd gate,
lazy update and latch-early-return are engine internals); an upstream
change to the pmd comparator flips `mv_pmd_edge`/`mv_pmd2` honestly;
map-mutation / layers-flip invalidation and the dirty-window read are
candidates for future tracked arms; the equality datapoint (euclid==pmd)
should be re-pinned if the comparison internals ever ship as source.

## Not established

Engine internals of the pmd comparator and segment-vs-endpoint
measurement; map-mutation and agent-layers lazy invalidation as TRACKED
arms; `reachable` live-recompute under tdd change while latched;
is_target_reached staleness window pinned as a CASES row; avoidance/
velocity-driven locomotion, CharacterBody `move_and_slide`, multi-map/
multi-region, vertical motion, `simplify_path`/`path_height_offset`/
postprocessing-setter invalidation, runtime link endpoint mutation,
other engine builds.
```

## Draft: LOG.md round-74 entry

    ## Round 74 — devin host — depth: NavigationAgent3D moving-agent semantics (frozen path / pop-follows / latch / re-anchor)

    - Declared (dispatch brief): pin (a) stored path FROZEN at
      target-assignment with live call-time distance/next; (b) pop index
      follows live position via the strict-< Euclidean rule on the stale
      path; (c) reached/finished latch under motion (or the measured
      unlatch); (d) target_position re-assignment re-queries from LIVE
      position, bank-side boundary. Prior 127 rows + 4 probes + Node 31/31
      stable.
    - Wave: devin leaf set reports/round-74/r74-{baseline,scout,reviewer,
      critic,author,simplifier,scribe}.md [boundary pending;
      verifier/adjudicator pending]. Sole tracked writer = author;
      UNCOMMITTED diff at report time — navagent3d_detour.gd +501/−5
      (steps/pmd keys, _run_steps + _run_motion_arm, 18 mv_* cfgs) +
      run_battery.py +36/−0 (insertions-only).
    - Baseline frozen e435a01 → 127/127 + 4 probes + Node 31/31,
      0-mismatch vs r73-verifier receipt.
    - Author battery 145/145 (100 ordinary/45 negative) + 4 probes +
      Node 31/31, seeds_unchanged=true (receipt corpus/live/r74-author/
      runs/20261014T041431092173Z/). Scribe non-author replay: 18/18 mv
      markers byte-exact + 14/14 prior rows byte-exact on the wt copy.
    - Result — all four claims CONFIRMED and converged by 4+ independent
      geometries: lazy agent (no tick update; forcing vs pure-reader
      getter split); stored path stable under motion with a pmd gate vs
      path[idx] — scribe equality pin: breach AT euclid==pmd (keep iff
      strictly <); pop strict-< sequential monotone call-time, no-skip,
      decoupled raw-euclid flags; latch survives all motion, unlatch =
      any target assignment (no dedup), finished freezes the whole
      update incl. pmd requery; re-anchor from live pos incl. lazy
      materialization (anchor = position at first forcing call).
    - Verbatim carries: "FROZEN at assignment" corrected to cleared-at-
      assignment / materialized-at-first-forcing-call; pmd strictness —
      equality breaches (author "STRICT >" bisect lacked equality);
      critic extras sibling-measured not CASES-pinned (dirty window,
      map/layers invalidation, reachable live under tdd); relative
      --runs trap still absent from docstring/README/lessons (reviewer
      re-flag).
    - Commit: work [pending]; adjudication landing [pending].

## Touched surfaces (this seat only)

- `corpus/live/r74-scribe/scratch/motion_z_probe.gd` (own probe;
  earlier revision sha `fe0cea4b…` ran the first 15 arms; current file
  `683e9cbe…` adds the `mz_lazy`/`mz_lazy_force` pair),
  `scratch/project.godot` (verbatim seed copy),
  `scratch/navagent3d_detour_wt.gd` + `scratch/run_battery_wt.py`
  (working-tree replay copies, sha-recorded).
- `corpus/live/r74-scribe/runs/` — 18 `mz_*` arm receipts
  (+`mz_steps_b` byte-identical determinism repeat stdout), `runs/wt/`
  18 author-arm replays, `runs/wt_prior/` 14 prior-arm replays.
- This report: `reports/round-74/r74-scribe.md` — the only tracked write.

## Out of scope / non-actions

- No commits, no pushes, no subagent dispatch (LEAF), no edits to tracked
  fixtures or other lanes' files; all godot runs confined to own scratch
  dir. Sibling `corpus/live/r74-*` read for convergence only.
- Working tree left as observed (`M` ×2, `?? reports/round-74/`).
- Not a verdict: admission is the canonical judge's; verifier/
  adjudicator slots pending.
