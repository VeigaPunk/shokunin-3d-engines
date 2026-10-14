# Game-dev-3d round 72 — NavigationAgent3D pdd pop-index vs agent position + two-mode is_navigation_finished (author, host: devin)

## Work performed

- Before-state `996ea37` (r71 adjudication commit): 90 Godot headless cases
  plus four opt-in probes; Node three.js 31/31. The r71 boundary seat
  (revenger) recon'd `path_desired_distance`/`is_navigation_finished` on the
  same L-corridor and recorded them as a suggested battery surface.
- Declared depth move (dispatch brief): formalize the pdd waypoint-pop
  semantics and the two-mode `is_navigation_finished` — pin the pop-point
  index vs agent position as tracked arms (agent at known offsets sweeping
  which path index next-path returns under increasing pdd) plus the two
  finish modes with equality-edge cases.
- Author feasibility probe first (own receipts, scratch only):
  `corpus/live/r72-author/scratch/navagent3d_pop_probe.gd` (sha256
  `d25d4302508e008fea7fdf402749e589eaecc6360223beb426b6406f573a27af`) +
  verbatim `project.godot` copy (sha256
  `1fda90d46b0529aea0e75710a64f038cbf983adc8385285dd8bbe6202a8eac23` —
  byte-identical to the tracked seed). Flag-parameterized
  (`--pdd/--tdd/--gap2/--spawn/--teleport/--teleport-late`); 44 runs under
  `corpus/live/r72-author/runs/*.exit`, every one exit 0, stderr banner-only.
  Command shape:
  `timeout 60 /usr/bin/godot --headless --path corpus/live/r72-author/scratch --script res://navagent3d_pop_probe.gd -- <flags>`.
  Determinism: `g2_pdd3.0_repeat`, `sedge_repeat` byte-identical; all 22
  fixture arms additionally ran twice (focused + full battery) with identical
  markers.
- Fixture work (sole tracked writer this round): extended
  `corpus/fixtures/navagent3d_detour.gd` additively — sha256
  `5b873cd06a8f50cb98a97764eb914e2a80f8553edb9ae216543979624d531647` →
  `ea722a750818d06a50db5f3cdaeae1738fae29944ad0de54034e444a7d1f4da0`,
  `git diff --numstat` = +297/−1 (the single deletion is the live-check's
  `distance_to(spawn)` → `distance_to(expected_pos)` so teleport arms can
  assert their moved position) — plus 22 additive CASES rows in
  `run_battery.py` +44/−0 (`b4b314997177c0a53ebd9cdf1f94f4ba91f3e7e7d774f4f4154e9169b1513809`
  → `4e9ead37da8ed6211e4116d16f344d651d725af6863017e6544bb83186eefdfa`).
  New user flag is only `--arm=<name>`; each arm's spawn/target/pdd/tdd/tp
  AND its expected tuple are authored constants in `_arm_cfg`, so a CASES row
  cannot tune its own expectation. Sibling `navagent3d_pop.gd` rejected as
  larger (would duplicate the ~70-line map/region/settle/cleanup core).

## Measured semantics (Godot 4.7.2.stable.arch_linux.ed1daf0bf, authored L-corridor)

```
pop:       while idx < size-1 and euclid(agent, path[idx]) < pdd: idx++
           — STRICT <, saturates at the last index, monotonic, keyed on the
             LIVE agent position; the stored path itself is fixed once forced
reached:   euclid(agent, raw target) < tdd            — STRICT, ignores
             reachability (fires through walls), latched once true
reachable: euclid(clamped final, raw target) <= tdd   — INCLUSIVE at equality,
             independent of agent position
finished:  reached OR (NOT reachable AND idx == size-1 AND
             euclid(agent, clamped final) < pdd)      — both sub-gates STRICT,
             latched once true
```

Key receipts (`corpus/live/r72-author/runs/*.stdout.txt`, probe `PROBE` lines):

- Pop vs pdd (spawn S, detour path [S,(2,0,1),(2.5,0,3.5)]): pdd 1.5 → idx1
  next (2,0,1); pdd 2.0 → idx2 next final; pdd 5.0 → idx2 (saturates at
  size−1; finished stays false on a reachable target).
- Pop vs position, same pdd: spawn (1.5,0,0.5) euclid→(2,0,1)=0.707107 —
  pdd 0.7 → idx1, pdd 0.71/1.0 → idx2 (vs idx1 from S at pdd 1.0).
- Pop Euclidean-not-path-sum (gap2 dogleg [S,(2,0,0),(2,0,1),(2,0,3)]):
  (2,0,1) sits at euclid 1.581139 but path-sum 2.581139 from S; pdd=2.0 →
  idx3 (path-sum basis falsified).
- Pop STRICT edge: spawn (2,0,0) gap2 — euclid to path[1]=(2,0,1) is EXACTLY
  1.0; pdd=1.0 → idx1 (no pop), pdd=1.01 → idx2. `tp_eq` repeats the pin on a
  fixed S-path post-teleport.
- Live-position pop on a FIXED path (`tp_mid`): read idx1/next (2,0,1),
  teleport (1.6,0,0.6), re-read → idx2/next final; path array byte-identical
  (npath 3, pathlen 4.130649 both reads).
- Unreachable finish gate, Euclidean basis (spawn S gap2): euclid→final
  2.915476 vs pdd — 2.9 false, 3.0 true (3.0 < pathlen 4.581139). idx=3 at
  pdd 2.0 already — saturated index alone does NOT finish.
- Unreachable STRICT edge (spawn (2,0,0) gap2): euclid→final EXACTLY 3.0 —
  pdd=3.0 → finished=FALSE, 3.01 → true. Refines the r71 boundary's `<=~pdd`
  to strict `<` at exact equality.
- Reachable gate = reached gate STRICT (spawn S gap2): euclid→T exactly 2.5 —
  tdd=2.5 → reachable=true yet finished=false; tdd=2.6 → true. `det_tdd4.0`
  fires finished at idx1 of 3 — reachable mode is idx-independent.
- Selector sawtooth (spawn (2,0,3) ON the clamp point, degenerate 2-pt path,
  euclid→T = final→T gap = 1.5): tdd 1.4 → reachable=false, finished=TRUE
  (idx+pdd clause); 1.5 → reachable=TRUE (INCLUSIVE at equality) but finished
  FALSE (strict reached at euclid==tdd); 1.6 → reached+finished TRUE.
  finished is non-monotone in tdd: T,F,T — pins both mode formulas and the
  inclusive-vs-strict asymmetry in one sweep.
- Idx gate (`fin_idx_gate`): teleport ONTO the clamped final (euclid→final 0
  < pdd, tdd 1.4) → finished FALSE: the pop index never reached the last
  waypoint (stays 1; next looks backward to (2,0,0)). Within-pdd-of-final is
  insufficient without the pop loop arriving.
- Through-wall (`fin_wall`): teleport adjacent to the raw off-mesh target
  (euclid→T 0.5 < tdd 1.0) → reached+finished TRUE while reachable stays
  FALSE — the `reached OR` clause applies in unreachable mode too.
- Latch (`fin_latch` + `latch_reached` probe): spawn (2,0,3) tdd 1.6 fires
  reached+finished; teleport back to S (euclid→T 2.5 > tdd) → both stay TRUE.
- Lazy-path caveat confirmed along the way: a pre-first-getter teleport
  re-anchors the queried path at the live position (the lazy update queries
  from current position, not from submission-time position); a post-forcing
  teleport does not move the stored path.

## New CASES rows (22, all exit 0)

`--arm=` → marker tuple pinned in `_arm_cfg` (spawn/target/pdd/tdd/tp and the
expected path/idx/next/final/dist/reachable/reached/finished are all authored
constants; `_run_pop_arm` fails exit 1 with a named diagnostic on any
mismatch — each row's falsification path is live).

- pop sweep: `pop_lo`/`pop_hi`/`pop_sat` (idx 1→2→2 at spawn S), `mid_lo`/
  `mid_hi` (position pair), `vert_pop_eq`/`vert_pop_above` (strict pop at
  exact 1.0), `tp_mid`/`tp_eq` (fixed-path live position), `gap2_pop_basis`
  (Euclidean-vs-path-sum discrimination)
- finish modes: `fin_unr_lo`/`fin_unr_hi` (2.9/3.0 vs 2.915476),
  `vert_fin_eq`/`vert_fin_above` (STRICT at exact 3.0), `fin_reach_eq`/
  `fin_reach_above` (STRICT at exact tdd 2.5), `edge_unr`/`edge_eq`/
  `edge_above` (selector sawtooth + inclusive reachable)
- refinements: `fin_idx_gate` (idx requirement), `fin_wall` (through-wall
  reached), `fin_latch` (latch)

## Before → after measurements

- Focused:
  `python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r72-author/runs --only navagent3d_detour,...,navagent3d_detour_fin_latch` (all 27 detour cases)
  → exit 0, **27/27 PASS**, receipt
  `corpus/live/r72-author/runs/20261014T004610248553Z/verdicts.json`.
- Full battery + 4 probes (absolute `--runs`):
  `python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r72-author/runs --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing`
  → exit 0, **PASS 112/112** (67 ordinary / 45 negative_controls / probes=4),
  `seeds_unchanged=true`, godot `4.7.2.stable.arch_linux.ed1daf0bf`;
  receipt `corpus/live/r72-author/runs/20261014T004642048951Z/verdicts.json`.
  Probes: `crash_probe_ok`/`stream_probe_ok`/`tree_probe_ok`=true; mutation
  probe `verdict=PASS` (`mutant_body3d_contact` exit 1, expected diagnostic).
- Prior-case stability: all 90 pre-r72 raw case fields (case, script, flags,
  expected/actual exit, kind, marker, verdict, reasons, stdout, stderr,
  error) byte-identical to r71-author receipt
  `corpus/live/r71-author/runs/20261013T233731295600Z/verdicts.json` — **0
  mismatches over 90 cases × 12 fields**; the 24 "new" names are the r71 post
  pair + 22 r72 rows. (The r71-baseline receipt has 88 rows and also compares
  0 mismatches.)
- Seed map 52→52: `navagent3d_detour.gd` and `run_battery.py` digest changes
  are the only diffs; no added/removed keys.
- Node three.js suites (Node v24.21.0, three.js 0.186.1, existing
  `corpus/fixtures/three` install): run_cases 3/3, run_layer_cases 4/4,
  run_order_cases 9/9, run_camera_cases 5/5, run_ortho_cases 5/5,
  run_ray_cases 5/5 — **31/31 PASS**, every suite `seeds_unchanged=true`;
  receipts `corpus/live/r72-author/runs/node/run_{cases,layer_cases,order_cases,camera_cases,ortho_cases,ray_cases}.json`.

## Independent check (lane's single labrat)

Dispatched one `ufo-labrat` probe on H1 strict-unreachable-finish / H2
strict-pop / H3 latch / H4 reachable-idx-independence. The labrat's substrate
exposed no exec tool, so it could not run godot itself; it audited the
recorded 27-arm receipt `runs/20261014T004610248553Z/verdicts.json` instead —
**all four hypotheses SUPPORTED from the measured rows** (the four raw
`pop_probe` invocations were inferred, not re-executed — recorded honestly).

## Resolved questions

- **pdd pop is strict `<` on live agent position against the FIXED stored
  path**, saturating at the last index: `get_next_path_position` returns
  `path[idx]` after advancing `idx` while `idx < size-1` and
  `euclid(agent, path[idx]) < pdd`. Euclidean basis confirmed against
  path-sum on the gap2 dogleg; position-keying confirmed by spawn offsets
  AND by a post-settle teleport that re-pops on an unchanged path (idx 1→2)
  or refuses at exact equality (1.0 == pdd → no pop).
- **`is_navigation_finished` = `reached OR (unreachable AND idx==size-1 AND
  euclid(agent,final) < pdd)`**, all comparisons strict, latched once true.
  The dispatch's "two modes" resolves into one OR of two clauses selected by
  the reachable flag: the tdd clause applies in BOTH modes (through-wall
  fire reproduced), and the pdd clause additionally requires the pop index
  to have reached the last waypoint — sitting on the final is not enough.
- **Refinements vs the r71-boundary model**: the unreachable pdd gate is
  STRICT at exact equality (`<= ~pdd` → `<`); `is_target_reached` ignores
  reachability (fires adjacent to an off-mesh target); reached and finished
  latch; reachable is INCLUSIVE at `euclid(final→T)==tdd` while reached is
  STRICT at `euclid(agent→T)==tdd` — the two tdd gates differ in strictness.

## Caveats / UNKNOWNs

- Bounded to Godot 4.7.2.stable.arch_linux.ed1daf0bf headless, the authored
  L-corridor, a stationary-or-teleported agent, single region, cell_size
  0.25, 30-frame settle (5 post-teleport), default
  postprocessing/metadata/path_max_distance. Real locomotion, avoidance,
  mid-path map updates, other builds remain unprobed.
- `edge_*` arms ride a degenerate 2-point path (agent spawns ON the clamped
  final); the sawtooth is the pin, not the path shape. Vertex/edge spawns
  ((2,0,0), (2,0,3)) resolve deterministically on this mesh — other meshes
  may clamp differently.
- Teleport arms exercise position re-evaluation, not tracked motion: the
  engine's per-update re-pop is pinned at a 5-frame horizon; whether a live
  CharacterBody moving through the corridor re-pops identically tick-by-tick
  is unprobed (plausible — same update path — but unmeasured).
- The strict-pop equality pin uses exactly-representable distances (1.0);
  float32-adjacent pdd values around sqrt(2.5) (1.5811388/1.5811389 both
  round to sqrtf(2.5) and do NOT pop, consistent with strict < in single
  precision) are recorded, not pinned as rows — irrational-boundary float
  edges are fragile pin material.
- `is_navigation_finished`'s latch release conditions (retarget, map update)
  unprobed; `is_target_reachable` re-evaluates (position-independent) — its
  own latch behavior unprobed at flip-back.
- r68/r69 `navagent3d_retarget` intermittence did not manifest in either
  battery run; caveat stands unretracted.
- Labrat confirmation is receipt-level (its substrate had no exec) — the
  probes' re-execution evidence is my own 44-run scratch matrix plus two
  full-battery passes.

## Per-axis verdicts (author claim — non-author review required before admission)

- **Depth: improved (claim)** — the r71 boundary's recon is resolved into a
  pinned contract: strict-equality edges on all three distance gates (pop,
  reached, unreachable-finish — each at an exactly-representable value), the
  OR-clause composition of `is_navigation_finished`, its idx==last
  requirement, latching, through-wall `reached`, and the inclusive-vs-strict
  tdd asymmetry — each clause with a live falsification path (authored
  constants fail exit 1 on drift). The `<= ~pdd` ambiguity is closed.
- **Coverage: improved (claim)** — 90→112 battery rows on the
  NavigationAgent3D surface, including the first arms that move the agent
  post-settle (position-keyed semantics) and off-mesh-target unreachable
  paths.
- **Discernment/quality (claim)** — expectations live in `_arm_cfg` as
  authored constants, not in flags; markers carry measured tuples; 44-run
  scratch matrix precedes the tracked pins; prior 90 rows field-stable.
- Admission rests on improved axes with none harmed in finite replay,
  pending named independent verification; not marked.

## Assumptions and constants

Host devin; `/usr/bin/godot` ELF 4.7.2.stable.arch_linux.ed1daf0bf, Node
v24.21.0, three.js 0.186.1, physics 60 tps. Map cell_size 0.25; L-corridor
quads A1 x[0,2]z[0,1], A2 x[2,3]z[0,1], B x[2,3]z[1,4]. Spawns (0.5,0,0.5),
(1.5,0,0.5), (2,0,0), (2,0,3); targets (2.5,0,3.5) reachable and (0.5,0,3.0)
off-mesh clamping to (2,0,3). DIST_TOL 0.004, POS_TOL 0.001; pdd/tdd set
before `target_position`; 30-frame settle, 5-frame post-teleport.

## SHONEN

- [ ] Real decision tables/error patterns/checklists with cited sources — not attested this round.
- [x] End-to-end domain task executed and logged — 44-run scratch matrix + 112-case battery + 31/31 Node receipts under `corpus/live/r72-author/runs/`; named `ufo-labrat` probe confirmed H1–H4 against the recorded receipt.
- [ ] Instructions executable without oral context — not attested as a probation box.
- [ ] No cross-domain bleed; PROVINCE accurate — not attested as a probation box.
