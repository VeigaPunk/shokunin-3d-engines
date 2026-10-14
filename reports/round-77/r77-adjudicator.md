# R77 adjudicator (Sol) — mutation apply-order + map_force_update + verdict groups

Round: 77. Wave: `shokunin-train-20261014-w8`. Work commit: `35dfbe2`
("r77: mutation apply-order CASES — doomed-RID divergence load-bearing…");
hygiene `565318c` (post-verifier per-class force-edge comment fix —
falsified wording corrected, zero behavior change).

## Declared move (depth)

- Measure whether `_apply_mutation`'s fixed application order is
  bypassable: explicit `mutate` arrays of ordered sub-dicts; claim at
  least one order-pair produces observably different served state.
- Measure `map_force_update` reach on the getter and serve edges.
- Emit wait-ladder verdict-groups (bound + group sizes) derived from
  observed `_tuple_sig` partitions, per RID class.
- Preserve all 163 prior cases + 4 probes + Node suites.

## Seat convergence

| seat | landing | contribution |
|---|---|---|
| author | yes | `navagent3d_detour.gd` +501/−33 (`_mut_list` fan-out, `srv_get`/`ladder`/`_tuple_sig` schema, `map_force` key, 10 arms); `run_battery.py` +20/−0; 173/173 battery; **self-corrected the jittered w1 pin** after the scout's defect report — pins w0+w3 only |
| scout | yes | pre-empted author defect on WIP snapshot: `mut_force_link` fails — force collapses link serve edge too (2→1 observed); mapped force reach + apply-order diverging ONLY through RID lifecycle (4 pairs); verdict-groups shape verified |
| boundary | yes | all 6 perms of {Rdel,Rrec,Rx03} → THREE observable states (moved/unmoved/gone); 2f empty-path interlude; same-field last-wins; cross-object + same-object triples inert; `_physics_process` callsite −1 tick; order sensitivity decomposes PAIRWISE; verdict-group collision witness (disabled region hides transform truth) |
| critic | yes | supported-with-correction: "emergent seam" → dead-write voiding (masking witness omk: identical served tuple, divergent internals); region serve edge under force DETERMINISTIC 3f→2f (9/9) — falsified the fixture comment's "unmoved"; region iter stamp w1 asymmetry; caught mut_force_link flaking INSIDE official battery ~15-20%; `bound` = serve-edge bound only |
| reviewer | yes | audit clean; confirmed the w1-skip arm pins only stable facts |
| scribe | yes | **own-geometry (dock-and-raft) + own-harness** — apply-order CONFIRMED (4 divergent pairs incl. triple; transient seam geometry-shaped: reachable raft route vs boundary's `[]`); RESOLVED the force mechanism to a **mark-vs-phase race**: prior forcing read marks stamped-dirty → next scheduled sync publishes early; single-read-per-rung sees NO collapse (link 2, region 3); race workload-biased (light probe 5/5 edge-1, heavy 13/15 w2); replayed BOTH `mut_force_link` versions (v1: 6/8 fail converging on the jitter; v2: 6/6 clean); independent ladder partition + 3-group seam; mid-window FU → residual 0 |
| simplifier | yes | minimal bar met — 10/10 arms + all machinery load-bearing (`_mut_list` = minimal expression, zero duplicated setters; 14-mutant lattice incl. the array-vs-dict core discrimination + 2 inert-pair controls proven non-vacuous); THREE flags applied as `a5ae849` (dead `link_layers` srv_get branch 0/18 consumers — 88-case pairwise byte-identical; `st2` dead store 3rd-round flag — real LSP refs {354;366,371,373;429,430}; stale 'never the serve edge' comment — 4th site the fleet fixes missed); jitter-rate refinement: rate is context-dependent (4% probe shape vs ~63% arm shape — phase artifact, not a constant); post-flags tree re-verified green |
| baseline | yes | frozen `e417365`; replay 163/163 + Node 31/31, 0 drift — first independent post-`8a67f71`-consolidation receipt (163×12 fields byte-equal) |
| verifier | yes | **AGREE 6/6** on `35dfbe2` — own-geometry probe `r77v_probe.gd`: xform_first → identity/unmoved, renew_first → (5,0,0)/moved; force jitter independently reproduced (6/10 fresh@w1, 4/10 stale; w3 10/10); ladder re-derived via Python simulation; 173/173 + 10/10 new + 4 probes + Node 31/31; 0 mismatches vs author's 173×12 and vs r76 verifier's 163×12 |

## Measured headline (multi-seat convergence)

- **Apply-order is load-bearing only through RID lifecycle.** Doomed-RID
  voiding verified independently both directions; boundary's all-6-perm
  census gives THREE outcome classes; order sensitivity decomposes
  pairwise (RID-rebinding adjacency + same-field last-wins); the one
  non-pairwise observable (+1 flush coupling) is order-inert.
  Surviving-object and cross-object pairs converge.
- **map_force_update reach**: getter edge collapses to same-turn
  (link stamped; region VALUE lands same-turn but region_iter stamps
  w1). Serve edge is a **mark-vs-phase race** (scribe mechanism):
  force drains the setter stage deterministically; the publish stage
  lands on the next scheduled sync — and a prior forcing READ marking
  the dirty map pulls it one frame early. Cumulative read-every-frame
  callers see link {w1 ~15-20%, w2} / region 3f→2f; single-read-per-
  rung probes see NO collapse. Mid-window second force collapses the
  residual to 0. The jitter RATE is context-dependent (simplifier:
  ~63% w1-fresh on the arm shape vs 4% on the probe shape — a phase
  artifact, not a constant). The tracked arm pins only w0/w3.
- **Wait-ladder verdict groups** re-derive the r76 edges from observed
  tuples: link bound=2 [2,2]; region bound=3 [3,2]. Groups are a
  serve-surface projection — internal state differences are invisible
  (omk masking witness).

## Corrections absorbed this round

- "Emergent seam" → dead-write voiding (critic; adjudicator adopts).
- Fixture comment "SERVE edge does not collapse" falsified for region —
  per-class wording landed as `565318c` (link jittered {1,2}; region
  deterministic −1f; region iter stamp asymmetry noted) + the
  mark-vs-phase mechanism line as `5e02b25`.
- `mut_force_link` initially pinned the jittered w1 cell — caught
  flaking inside the official battery (~15-20%); corrected to skip w1.
  Nondeterministic edges now carry measured distributions, never pinned
  constants.
- Author report numstat +502 → true +501 (cosmetic).

## Adjudicator own reproduction

- Boundary byte-verified the landed diff (173/173, all 7-10 arms
  byte-verbatim, constants match its independent table); verifier
  re-ran the full committed battery + probes + Node suites with 0
  mismatches; spot-run of 4 arms on committed HEAD post-hygiene PASS
  (this seat's `corpus/live/integ-r77/`).

## Bounds

Godot 4.7.2 / 60tps-pinned / Linux x86_64; link w1 jitter is a
mark-vs-phase race biased by harness weight (measured ~15-20% here —
arm skips it); read-history perturbs the measured edge under force
(sampling protocol is part of the bound); verdict groups are
serve-surface only (truth digests = open frontier); force-update
region getter stamp asymmetry (iter w1) now documented in-fixture.

## Verdict — **ADMIT**

- depth: **improved locally** — apply-order mechanism resolved to
  doomed-RID voiding with a full permutation census; force-update reach
  split per-class with honest jitter handling.
- coverage: **improved locally** — `mutate` array schema +
  `srv_get`/`ladder`/`_tuple_sig` receipt keys; 10 new CASES; groups
  re-derive prior edges from data.
- calibration: **unchanged** — additive CASES only; 163 prior rows
  byte-stable vs independent receipt; Node 31/31; seeds unchanged.

Work `35dfbe2` + hygiene `565318c`/`5e02b25`/`a5ae849`; report-last
commit follows.
