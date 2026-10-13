# R70 Sol independent per-axis adjudication — distance_to_target is Euclidean

**Verdict: ADMIT the bounded R70 depth move.** Depth **improved locally**; coverage **improved locally**; calibration **unchanged**. No scoped axis is harmed. This verdict accepts a locally measured API-semantics resolution — `NavigationAgent3D.distance_to_target` returns Euclidean distance to the raw authored `target_position` on Godot 4.7.2 — **not** a claim about other engine versions, moving agents, or postprocessing modes.

Pinned work adjudicated: `2a0e46f` (work) + `0ea70cf` (simplifier report) (clean-before `e054cfe`).

## The declared claim (as briefed)

One **depth** move: resolve r69's retained UNKNOWN — does `distance_to_target` report Euclidean distance or navigation path-sum? R69 measured 2.828427 on a convex 4x4 polygon where both candidates coincide.

## Evidence audited (this adjudicator's own runs, plus verifier)

- Own direct reproduction (fresh scratch project, committed fixture at sha `669c539d…`): detour arm → `distance=3.605551 semantic=euclidean final=2.500,0.000,3.500 next=2.000,0.000,1.000 pathlen=4.130649`, **exit 0**; `--assert-pathsum` → `NEGATIVE REJECTED … expected_pathsum=4.130649 euclid=3.605551`, **exit 2**; `--straight` → `NEGATIVE REJECTED … distance=2.828427 … discriminates=false`, **exit 2**. All byte-exact vs the authored CASES markers.
- Non-author verifier `r70-verifier.md`: **AGREE on all six claims** — full battery replay exit 0 `cases=88 pass=88` with all 4 probes PASS and `seeds_unchanged=true`; **0 mismatches over 85 prior cases × 11 raw fields** vs the frozen baseline receipt; both spot-check arms byte-exact; Node suites 31/31 all `seedsUnchanged`; commit-shape audit clean (`run_battery.py` exactly +6 lines, zero removed); secrets scan clean.
- Independent convergence (four geometries, four seats): scout L-corridor 3.605551 vs path 4.130649; scribe tromino 5.000000 vs 6.085044; boundary U-corridor + gap/island arms (distance stays Euclidean-to-raw even when unreachable, `final` clamped); critic's sharpest trap — *no path at all* still returns Euclidean (the fixture defeats this ambiguity by asserting `reachable`, `final≈target`, `next` off-straight, pathlen−euclid ≥0.4 margin). Boundary independently replayed the author's committed fixture byte-identical.
- Frozen baseline `r70-baseline`: `git archive` standalone replay → **85/85 + 4 probes + Node 31/31** on the committed before-state.
- Diff audit: `run_battery.py` +6/−0 (three CASES rows only); new fixture `navagent3d_detour.gd` +137; nothing else touched.

## Critic-derived sharpening (accepted into the record)

- `is_target_reachable`/`is_target_reached`/`is_navigation_finished` key off `euclid(final_position, target) ≤ target_desired_distance` — with no path at all, `tdd=5.0` makes all three true **through a wall** (blocked arm measured). The distance claim is Euclidean-to-raw-target; the *reach gates* are Euclidean-to-clamped-final. Fixture pins are load-bearing precisely because of this.
- Portal-crossing midpoints retained in the path chain even when collinear (`--straight` yields 3 points via (3,0,0.5)) — observed, left as bounded UNKNOWN.

## Per-axis judgment

| Axis | Judgment | Basis and limit |
|---|---|---|
| Depth | **Improved locally** | r69 UNKNOWN → established engine semantics with a discriminating fixture and four-geometry convergence; the falsified path-sum hypothesis is preserved as a green negative. |
| Coverage | **Improved locally** | 85→88 rows (detour positive + straight control + refuted-pathsum negative); all prior 85 byte-identical vs frozen baseline. |
| Calibration | **Unchanged** | No classifier/threshold touched; measurement constants only. |

## Learning trends

- **Expansion**: improved — new nav-agent distance-semantics surface (detour + reach-gate distinction mapped).
- **Quality**: improved — adversarial geometry traps (absent path, clamped final) designed out of the fixture's claim; four independent derivations.
- **Discernment**: improved — admitted (euclidean arm) and rejected (pathsum-hypothesis arm, non-discriminating control) both non-author replayed byte-exact.

## Bounded limits

Godot 4.7.2.stable.arch_linux.ed1daf0bf headless only; stationary agents; `CORRIDORFUNNEL` postprocessing only (other modes unprobed — retained UNKNOWN); hand-computable 2D-navmesh geometries; the `path.size()==3` funnel-vertex pin could be brittle across engine versions (disclosed by author); `navagent3d_retarget` intermittence (r68/r69) did not manifest and remains open.

## Reopen conditions

Reopen if: the battery stops producing 88/88; the detour arm's marker or exits (0/2/2) change; any of the 85 prior rows drifts vs the frozen baseline receipt; or a future engine version reports a non-Euclidean `distance_to_target` under this geometry.

This adjudicator made no git mutations and no writes other than this report; its direct-run scratch was `/tmp/r70-adj-scratch` (outside the repo).
