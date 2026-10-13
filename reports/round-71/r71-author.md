# Game-dev-3d round 71 — NavigationAgent3D path_postprocessing invariance of distance_to_target (author, host: devin)

## Work performed

- Before-state `9458c18` (r70 adjudication commit): 88 Godot headless cases
  plus four opt-in probes; Node three.js 31/31. r70 established
  `distance_to_target` = Euclidean to the raw `target_position`
  (3.605551 = √13 on the L-corridor vs routed 4.130649) under default
  CORRIDORFUNNEL(0) postprocessing only; other postprocessing values were a
  recorded caveat.
- Declared depth move (dispatch brief): resolve whether
  `NavigationAgent3D.path_postprocessing` changes that semantic — claim
  under test: `{edgecentered(1), none(2)}` leave `distance_to_target`
  Euclidean-invariant while changing `get_next_path_position`/
  `get_final_position` outputs; a changed `distance_to_target` under any
  value falsifies invariance.
- Author feasibility probe first (own receipts, scratch only):
  `corpus/live/r71-author/probe1/probe_postproc.gd` on this host's
  `/usr/bin/godot` 4.7.2.stable.arch_linux.ed1daf0bf:
  `timeout 60 /usr/bin/godot --headless --path corpus/live/r71-author/probe1 --script res://probe_postproc.gd`
  → exit 0 (raw transcript `corpus/live/r71-author/runs-probe1.stdout.txt`,
  empty stderr `runs-probe1.stderr.txt`), verbatim rows:

  | postproc | distance | euclid | pathlen | path | next | final | pidx |
  |---|---|---|---|---|---|---|---|
  | 0 corridorfunnel | 3.605551 | 3.605551 | 4.130649 | (0.5,0,0.5)→(2,0,1)→(2.5,0,3.5) | 2.000,0.000,1.000 | 2.500,0.000,3.500 | 1 |
  | 1 edgecentered | 3.605551 | 3.605551 | 4.707107 | (0.5,0,0.5)→(2,0,0.5)→(2.5,0,1)→(2.5,0,3.5) | 2.000,0.000,0.500 | 2.500,0.000,3.500 | 1 |
  | 2 none | 3.605551 | 3.605551 | 4.549510 | (0.5,0,0.5)→(2,0,0.5)→(2,0,1)→(2.5,0,3.5) | 2.000,0.000,0.500 | 2.500,0.000,3.500 | 1 |

  `reachable=true reached=false finished=false` under all three. A second
  pass setting postprocessing AFTER `target_position` re-queries
  identically (dist 3.605551; pathlen 4.707107 / 4.549510), so ordering is
  not load-bearing; the fixture sets the flag before target submission.
  Note: the parallel scout probe parse-failed
  (`corpus/live/r71-scout/runs/postproc_detour.stderr.txt` — `map_get_path`
  takes at most 5 args on this build); this measurement is the author's own.
- Fixture work (sole tracked writer this round): extended
  `corpus/fixtures/navagent3d_detour.gd` additively (+45 lines, sha256
  `669c539d…` → `5b873cd06a8f50cb98a97764eb914e2a80f8553edb9ae216543979624d531647`)
  with `--post-edgecentered` / `--post-none` flags, plus two additive CASES
  rows in `run_battery.py` (+4 lines, sha256 `5a7d6c13…` →
  `b4b314997177c0a53ebd9cdf1f94f4ba91f3e7e7d774f4f4154e9169b1513809`).
  `git diff --stat` = 2 files changed, 49 insertions(+), 0 deletions.
  Sibling-fixture alternative rejected as larger (would duplicate the ~40
  lines of shared map/region/geometry setup).

## Arm semantics asserted (post flags)

- Same L-corridor geometry, spawn (0.5,0,0.5), target (2.5,0,3.5);
  `agent.path_postprocessing` set to EDGECENTERED(1)/NONE(2) via
  `NavigationPathQueryParameters3D.PATH_POSTPROCESSING_*` before
  `target_position`; 30-frame settle, DIST_TOL 0.004, POS_TOL 0.001.
- Each arm classifies the measured distance exactly like the r70 arm
  (`euclidean` / `path_sum` / bounded `unknown`); `semantic != "euclidean"`
  fails exit 1 with diagnostic carrying measured distance/euclid/pathlen —
  the falsification path of the invariance claim.
- Each arm pins its measured path so a flag that did not take effect cannot
  pass: `path.size()==4`, `next=(2,0,0.5)` (vs corridorfunnel (2,0,1)),
  `pathlen` 4.707107 (edgecentered: 1.5+√0.5+2.5 via edge midpoints) or
  4.549510 (none: 1.5+0.5+√6.5 via raw corridor), `final=(2.5,0,3.5)`,
  `reachable=true`, `reached=false`, `finished=false`.
- `get_final_position` is unchanged by postprocessing on this geometry
  (last path point = clamped target); the claim's "may change" clause holds
  only for `get_next_path_position`/path outputs — recorded as observed.

## Before → after measurements

- Focused:
  `python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r71-author/runs --only navagent3d_detour,navagent3d_detour_post_edgecentered,navagent3d_detour_post_none`
  → exit 0, 3/3 PASS,
  `corpus/live/r71-author/runs/20261013T233722904076Z/verdicts.json`.
- Full battery + 4 probes (absolute `--runs`, r69 relative-path caveat
  honored):
  `python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r71-author/runs --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing`
  → exit 0, **PASS 90/90** (45 ordinary / 45 negative_controls),
  `seeds_unchanged=true`, godot `4.7.2.stable.arch_linux.ed1daf0bf`;
  receipt `corpus/live/r71-author/runs/20261013T233731295600Z/verdicts.json`.
  Probes: crash_probe_ok=true, stream_probe_ok=true, tree_probe_ok=true,
  mutation `detected=true` (`mutant_body3d_contact` rejected with the
  expected diagnostic).
- New markers verbatim:
  `PASS navagent3d_detour post_edgecentered distance=3.605551 semantic=euclidean final=2.500,0.000,3.500 next=2.000,0.000,0.500 pathlen=4.707107 reachable=true reached=false finished=false`
  `PASS navagent3d_detour post_none distance=3.605551 semantic=euclidean final=2.500,0.000,3.500 next=2.000,0.000,0.500 pathlen=4.549510 reachable=true reached=false finished=false`
- Prior-case stability: all 88 pre-r71 raw case fields (script, flags,
  expected/actual exit, kind, marker, verdict, reasons, stdout, stderr,
  error) byte-identical to frozen baseline receipt
  `corpus/live/r71-baseline/runs/20261013T233444776454Z/verdicts.json`
  (0 mismatches over 88 cases × 11 fields; comparison script output
  recorded above — 2 new cases only).
- Seed map 52→52: `navagent3d_detour.gd` and `run_battery.py` digest changes
  are the only diffs; no added/removed keys (post arms are flags on the
  existing seed, not new files).
- Node three.js suites (Node v24.21.0, three.js 0.186.1, existing
  `corpus/fixtures/three` install): run_cases 3/3, run_layer_cases 4/4,
  run_order_cases 9/9, run_camera_cases 5/5, run_ortho_cases 5/5,
  run_ray_cases 5/5 — 31/31 PASS, all `seeds_unchanged=true`; receipts
  `corpus/live/r71-author/runs/run_{cases,layer_cases,order_cases,camera_cases,ortho_cases,ray_cases}.json`.

## Resolved question

- **`distance_to_target()` is invariant under `path_postprocessing`** on
  this engine build: it returns 3.605551 (Euclidean to raw
  `target_position`) under corridorfunnel(0), edgecentered(1), and none(2)
  while the engine's own queried path measurably changes — length
  4.130649 → 4.707107 → 4.549510, next waypoint (2,0,1) → (2,0,0.5), path
  point count 3 → 4. Combined with r70, the property now reads: postproc
  reshapes the path corridor outputs, never the scalar distance; final
  stays the clamped target on reachable targets. The declared invariance
  claim is CONFIRMED by measurement on this fixture.

## Caveats / UNKNOWNs

- Bounded to Godot 4.7.2.stable.arch_linux.ed1daf0bf headless, the authored
  L-corridor geometry, a stationary agent at path start, and default
  `path_desired_distance`/`target_desired_distance`/`path_max_distance`.
  Moving-agent mid-path semantics, avoidance, map updates mid-flight, other
  postprocessing interactions (e.g. combined with `pathfinding_algorithm`)
  and other engine versions remain unprobed.
- Under `none` the raw corridor happened to retain portal vertex (2,0,1)
  AND edge midpoint (2,0,0.5); on other meshes the unprocessed corridor
  shape is unspecified — only this mesh's measured values are claimed.
- `path_postprocessing` set after `target_position` re-queried identically
  here (probe rows `postproc_after=*`); the fixture still sets it first —
  no claim about stale-path windows on live retargets.
- The r68/r69 `navagent3d_retarget` intermittence did not manifest in this
  run; caveat stands unretracted.
- No claim about agent motion, avoidance, baking, other engines, or
  rendered output.

## Per-axis verdicts (author claim — non-author review required before admission)

- **Depth: improved (claim)** — the r70 caveat "different postprocessing
  unprobed" is resolved by measurement: `distance_to_target` is Euclidean-
  invariant under all three `path_postprocessing` values on a geometry
  where each value measurably reshapes the path (4.130649/4.707107/
  4.549510); falsification path is live (semantic != euclidean → exit 1
  with measured diagnostic).
- **Coverage: unchanged-to-improved (claim)** — two new battery rows on the
  same Godot/NavigationAgent3D surface; whether 88→90 rows counts as
  coverage or stays inside the r70 boundary is the verifier's call.
- **Calibration: unchanged** — same exit/marker/seed contract; measured
  constants pinned per arm; receipts and intermittence caveats recorded.
- Admission would rest on one improved axis and none harmed in finite
  replay, pending named independent verification; not marked.

## Assumptions and constants

- Host devin; `/usr/bin/godot` ELF 4.7.2.stable.arch_linux.ed1daf0bf, Node
  v24.21.0, three.js 0.186.1, physics 60 tps. Map cell_size 0.25, exact
  shared edges (margin not load-bearing). Spawn (0.5,0,0.5), target
  (2.5,0,3.5); `target_desired_distance`/`path_desired_distance` 1.0
  defaults; 30-frame settle; DIST_TOL 0.004, POS_TOL 0.001. Enum values on
  this build: CORRIDORFUNNEL=0, EDGECENTERED=1, NONE=2 (probe-verified via
  `NavigationPathQueryParameters3D.PATH_POSTPROCESSING_*`).

## SHONEN

- [ ] Real decision tables/error patterns/checklists with cited sources — not attested this round.
- [x] End-to-end domain task executed and logged — named non-author `game-dev-3d-r2-review-retry` checked at `.shokunin/game-dev-3d/corpus/lessons/r2-independent-review.md`.
- [ ] Instructions executable without oral context — not attested as a probation box.
- [ ] No cross-domain bleed; PROVINCE accurate — not attested as a probation box.
