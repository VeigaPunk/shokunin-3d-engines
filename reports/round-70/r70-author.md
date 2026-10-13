# Game-dev-3d round 70 — NavigationAgent3D distance_to_target semantic discrimination (author, host: devin)

## Work performed

- Before-state `e054cfe` (r69 report commit): 85 Godot headless cases plus
  four opt-in probes. r69 measured `distance_to_target=2.828427` on a convex
  4x4 single-polygon navmesh where Euclidean and path-sum coincide — the
  Euclidean-vs-path-sum UNKNOWN was recorded unresolved.
- Declared depth move: new fixture `corpus/fixtures/navagent3d_detour.gd`
  (sha256 `669c539d0bb38c82184f1b39df0a4d70059276e532def125438f352899a7fc45`)
  plus three additive CASES rows in `run_battery.py` (+6 lines only, sha256
  `5a7d6c13ac4a24960ce8f24bcc45b24a65da31919e78b5cc5934e3c248a79dee`).
- Author feasibility probe first (own receipts, not seeds):
  `corpus/live/r70-author/probe1/` ran a scratch script on this host's
  `/usr/bin/godot` 4.7.2.stable.arch_linux.ed1daf0bf:
  `timeout 60 /usr/bin/godot --headless --path corpus/live/r70-author/probe1 --script res://probe_nav.gd`
  → exit 0, verbatim stdout:
  `PROBE detour dist=3.605551 euclid=3.605551 pathlen=4.130649 next=(2.0, 0.0, 1.0) final=(2.5, 0.0, 3.5) reachable=true reached=false finished=false`,
  `PROBE straight_flat dist=2.828427 euclid=2.828427 pathlen=2.828427 ...`,
  `PROBE straight_lmesh dist=2.000000 euclid=2.000000 pathlen=2.000000 ...`.
  Independently reproduces scout `corpus/live/r70-scout/runs/probe1/` and
  critic `corpus/live/r70-critic/runs/*.out` (5 more arms incl. blocked,
  partial-edge, off-mesh target: all Euclidean to authored target).

## Geometry and candidate values

- One `NavigationMesh`, three convex quads sharing exact full edges:
  A1 x[0,2]z[0,1], A2 x[2,3]z[0,1] (shares x=2,z[0,1]), B x[2,3]z[1,4]
  (shares z=1,x[2,3]); partial-edge and concave-single-polygon variants were
  ruled out by scout probe (no connection / walked as convex hull).
- Detour arm: agent (0.5,0,0.5), target (2.5,0,3.5). Euclidean sqrt(13) =
  **3.605551**; routed funnel path via vertex (2,0,1) sums
  sqrt(2.5)+sqrt(6.5) = **4.130649**. Gap 0.525098 ≈ 131x the 0.004 distance
  tolerance — the two hypotheses are cleanly discriminated.
- Fixture classifies the measurement (`|distance−euclid|≤tol` → euclidean,
  `|distance−pathlen|≤tol` → path_sum, else exit 1 bounded UNKNOWN) and
  asserts the bend is real at query time: `next=(2,0,1)`, path size 3,
  `pathlen≈4.130649`, `pathlen−euclid>0.4`, `final=(2.5,0,3.5)`,
  `reachable=true`, `reached=false`, `finished=false`.
- `--straight` control: convex 4x4 single polygon (same seed polygon and
  endpoints as `navagent3d_distance.gd`), (1,0,1)→(3,0,3): both candidates
  coincide at 2.828427 — reproduces the r69 coincident measurement, marked
  `discriminates=false`, exit 2 per the battery's straight-arm convention
  (curve3d_path_straight, pathfollow3d_curve_straight precedent).
- `--assert-pathsum` negative: same detour mesh, authors the wrong
  hypothesis distance≈4.130649; engine refutes with 3.605551 and the
  fixture reports the refutation — proves the measured value is not the
  losing candidate.

## Before → after measurements

- Focused: `--only navagent3d_detour,navagent3d_detour_straight,navagent3d_detour_assert_pathsum`
  → 3/3 PASS, `corpus/live/r70-author/runs/20261013T221033332873Z/verdicts.json`.
- Full battery + 4 probes (absolute `--runs`, r69 caveat honored):
  `python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r70-author/runs --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing`
  → exit 0, **PASS 88/88** (43 ordinary / 45 negative_controls),
  `seeds_unchanged=true`, godot `4.7.2.stable.arch_linux.ed1daf0bf`;
  receipt `corpus/live/r70-author/runs/20261013T221041493928Z/verdicts.json`.
  Probes: crash_probe_ok=true, stream_probe_ok=true, tree_probe_ok=true,
  mutation `detected=true` (`mutant_body3d_contact` rejected with expected
  diagnostic).
- New markers verbatim:
  `PASS navagent3d_detour distance=3.605551 semantic=euclidean final=2.500,0.000,3.500 next=2.000,0.000,1.000 pathlen=4.130649 reachable=true reached=false finished=false`
  `NEGATIVE REJECTED: navagent3d_detour straight distance=2.828427 euclid=2.828427 pathlen=2.828427 discriminates=false`
  `NEGATIVE REJECTED: navagent3d_detour assert_pathsum distance=3.605551 expected_pathsum=4.130649 euclid=3.605551`
- Prior-case stability: all 85 pre-r70 raw case fields (script, flags,
  expected/actual exit, kind, marker, verdict, reasons, stdout, stderr)
  byte-identical to frozen baseline receipt
  `corpus/live/r70-baseline/runs/20261013T215959381187Z/verdicts.json`.
- Seed map 51→52: only new key `navagent3d_detour.gd` and the intended
  `run_battery.py` digest change; `git diff --stat` = +6 lines, one file.
- Node three.js suites (Node v24.21.0, three.js 0.186.1, `npm ci` in
  lane-local `corpus/fixtures/three`): run_cases 3/3, run_layer_cases 4/4,
  run_order_cases 9/9, run_camera_cases 5/5, run_ortho_cases 5/5,
  run_ray_cases 5/5 — 31/31 PASS, all `seeds_unchanged=true`; receipts at
  `corpus/live/r70-author/runs/run_*.json`.

## Resolved UNKNOWN

- **`distance_to_target()` is Euclidean** on this engine build: it measures
  the straight distance from the agent position to the authored
  `target_position`, not the routed path length. On the forced-detour mesh
  it returned 3.605551 while the engine's own 3-point routed path summed
  4.130649. Corroborating scout/critic probes: even with an unreachable or
  off-mesh target the value tracks the authored target, not the clamped
  `final` (`offmesh`: dist 4.472136 vs euclid-to-final 4.123106).

## Caveats / UNKNOWNs

- Claim is bounded to Godot 4.7.2.stable.arch_linux.ed1daf0bf headless, the
  authored geometries, a stationary agent at path start, and default
  `path_postprocessing` (CORRIDORFUNNEL). Under a moving agent mid-path,
  different postprocessing, or other engine versions the semantic is
  unprobed (edge-centered postproc would land ~4.707 on this mesh — still
  ≫3.606, so the discrimination design is robust to that knob).
- Path-sum candidate is asserted via the engine-measured
  `get_current_navigation_path` segment sum, not an engine-reported
  "remaining distance" — no claim about any internal path-length API.
- The r68/r69 host-contention intermittence (`navagent3d_retarget`
  SDL-stderr / numeric drift modes) did not manifest in this run; the
  caveat stands unretracted.
- No claim about agent motion, avoidance, baking, other engines, or
  rendered output.

## Per-axis verdicts (author claim — non-author review required before admission)

- **Depth: improved (claim)** — the r69 Euclidean-vs-path-sum UNKNOWN is
  resolved by measurement: `distance_to_target` is Euclidean to the authored
  `target_position` on a geometry where the two semantics differ by 0.525,
  with a live bend witness (`next=(2,0,1)`, `pathlen=4.130649`), a convex
  2.828427 reproduction control, and a refuted-hypothesis negative.
- **Coverage: unchanged** — same Godot engine, host, and NavigationAgent3D
  API class already under test since r69.
- **Calibration: unchanged** — same exit/marker/seed contract; receipts and
  intermittence caveats recorded.
- Admission would rest on one improved axis and none harmed in finite
  replay, pending named independent verification; not marked.

## Assumptions and constants

- Host devin; `/usr/bin/godot` ELF 4.7.2.stable.arch_linux.ed1daf0bf, Node
  v24.21.0, three.js 0.186.1, physics 60 tps. Map cell_size 0.25,
  default `edge_connection_margin` 0.25 (exact shared edges used, so the
  margin is not load-bearing). Agent spawn (0.5,0,0.5), target (2.5,0,3.5);
  `target_desired_distance` 1.0 default; 30-frame
  settle; distance tolerance 0.004, position tolerance 0.001, detour margin
  pathlen−euclid>0.4.

## SHONEN

- [ ] Real decision tables/error patterns/checklists with cited sources — not attested this round.
- [x] End-to-end domain task executed and logged — named non-author `game-dev-3d-r2-review-retry` checked at `.shokunin/game-dev-3d/corpus/lessons/r2-independent-review.md`.
- [ ] Instructions executable without oral context — not attested as a probation box.
- [ ] No cross-domain bleed; PROVINCE accurate — not attested as a probation box.
