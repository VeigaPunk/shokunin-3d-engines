# Game-dev-3d round 70 — boundary (revenger): NavAgent3D detour discrimination + reach-surface recon

Seat: boundary (role revenger). Scope: scratch-only under
`corpus/live/r70-boundary/`; no tracked edits, no commits, leaf — no
dispatch. Declared lane axis-move (depth): resolve the r69 UNKNOWN — is
`NavigationAgent3D.distance_to_target` Euclidean or path-sum? r69 could not
discriminate because a convex 4x4 polygon makes both candidates coincide at
2.828427. Plus scratch recon for the NEXT depth surface:
`get_final_position()`/`get_next_path_position()` semantics on a bent path,
and `is_target_reachable` under partial blocking.

## Deliverable

`corpus/live/r70-boundary/scratch/navagent3d_detour.gd`, sha256
`6e4e7c6a51d048fd3d1184029a7dcd8fbdaa5da4241279f08d493989f48f77c9`, plus a
verbatim copy of the seed `project.godot` (sha `1fda90d4…23`, identical to
`corpus/fixtures/project.godot`). Battery-shaped (PASS/NEGATIVE/exit
contract, PROBE lines ahead of the marker); liftable into `corpus/fixtures/`
by the author.

Geometry — L-corridor, three quads joined by EXACT shared edges (no reliance
on `edge_connection_margin`, measured 0.2500):
`A1 x[0,3]z[0,1]`, `A2 x[3,4]z[0,1]` (shares x=3 with A1, z=1 with B),
`B x[3,4]z[1,4]`; `--island` adds `D x[0,1]z[3,4]` disconnected.
S=(0.5,0,0.5); targets T_detour=(3.5,0,2.5), T_straight=(3.5,0,0.5),
T_gap=(1.5,0,3.0) off-mesh dead angle, T_island=(0.5,0,3.5) on-mesh but
disconnected. Discrimination gap: euclid sqrt(13)=3.605551 vs corridor
path-sum 4.130649 — separation >0.5, tol 0.004.

## Command and receipts

```
godot --headless --path .shokunin/game-dev-3d/corpus/live/r70-boundary/scratch \
  --script res://navagent3d_detour.gd -- [arm-flag]
```

Godot `4.7.2.stable.arch_linux.ed1daf0bf` via `/usr/bin/godot`. Raw
stdout/stderr/exit per arm: `corpus/live/r70-boundary/runs/<arm>.stdout.txt`,
`.stderr.txt`, `.exit`. Detour arm repeated: stdout byte-identical
(`detour-repeat.stdout.txt`), exit 0.

## Measured results (all engine-observed, no literals)

| arm | exit | dist | euclid | agent path-sum | semantics |
|---|---|---|---|---|---|
| detour (default) | 0 PASS | 3.605551 | 3.605551 | 4.130649 | **euclidean** |
| --straight | 0 PASS | 3.000000 | 3.000000 | 3.000000 | coincident (control) |
| --expect-path-sum | 2 NEGATIVE REJECTED | 3.605551 | — | literal 4.130649 | path-sum falsified |
| --gap (T off-mesh) | 0 PROBE | 2.692582 | 2.692582 | 5.549510 | euclidean to raw T |
| --island (T on-mesh, disconnected) | 0 PROBE | 3.000000 | 3.000000 | 6.049510 | euclidean to raw T |

## Resolved UNKNOWN (r69 carried): distance_to_target is EUCLIDEAN

- Detour: `distance_to_target`=3.605551 == `S.distance_to(T)` to all six
  printed decimals while the agent's own `get_current_navigation_path()` sums
  to 4.130649 (identical to one-shot `map_get_path` sum). Bent path present
  (3 points), so the difference is not degenerate geometry.
- Stronger: the reference is the RAW `target_position`, not the path end.
  `--gap`: dist=2.692582 = euclid S→(1.5,0,3) although the path clamps at
  final=(3,0,3) and `reachable=false`; euclid to final would be 3.535534.
  `--island`: dist=3.000000 = euclid S→(0.5,0,3.5) while final=(3,0,3.5).
- Consistent with r69's 2.828427=sqrt(8) on the convex map (both candidates
  coincided there).
- Reconstructed contract: `distance_to_target()` ≡ straight-line distance
  from agent origin to `target_position`; it ignores the computed path, the
  clamped final position, and reachability entirely. Confidence: high on
  this host/engine/version; stationary agent only (motion not probed).

## Recon for the NEXT surface (observations, receipts as above)

- `get_next_path_position()` returns the next waypoint of the agent's
  waypoint chain, NOT the raw target: detour → corner (3,0,1); gap/island →
  (3,0,0) (paths to clamped finals hug polygon edges via A2's corner).
- `get_final_position()` returns the END of the computed path: raw target
  when reachable (detour/straight), the clamped closest point on the
  connected component when not: (3,0,3) for the off-mesh gap target,
  (3,0,3.5) for the disconnected-island target.
- `is_target_reachable` DOES differ under partial blocking: true on both
  corridor arms; false for off-mesh target AND for on-mesh-but-disconnected
  target — while a partial clamped path still exists in both. Inference
  (unprobed mechanism): reachability keys on whether the path end coincides
  with target_position, not on polygon membership — both false cases clamp.
- Path detail: `--straight` returns THREE path points — the A1|A2 portal
  midpoint (3,0,0.5) is retained in the chain even when fully collinear
  (path_postprocessing=0, corridor funnel). Engine waypoint chains carry
  portal crossings; `next` is therefore not "the point the agent should seek"
  in a Euclidean sense.
- `path_index=1`, `reached=false`, `finished=false` on every arm; `reached`
  stays false even for island/gap (final is clamped, never within
  target_desired_distance of T).

## Battery-integration suggestion (for the author, if admitted)

CASES rows in the established style:
- `navagent3d_detour` / `navagent3d_detour.gd` / `[]` / 0 / the PASS line
  measured above;
- `navagent3d_detour_straight` / `["--straight"]` / 0 / PASS straight_control;
- `navagent3d_detour_expect_path_sum` / `["--expect-path-sum"]` / 2 /
  NEGATIVE REJECTED line.
`--gap`/`--island` stay recon arms (PROBE output, exit 0) unless the lane
pins their markers.

## Cross-seat evidence: author fixture replayed in my scratch

The lane author seat concurrently created the tracked
`corpus/fixtures/navagent3d_detour.gd` (uncommitted at report time, sha256
`669c539d0bb38c82184f1b39df0a4d70059276e532def125438f352899a7fc45`) plus three
CASES rows in `run_battery.py` — different L-corridor (portal x[2,3]@z=1,
T=(2.5,0,3.5)), same discriminating constants (euclid 3.605551 vs pathlen
4.130649). I copied it byte-identical into my scratch as
`author_navagent3d_detour.gd` and replayed all three arms headless:

- default: exit 0 — `PASS navagent3d_detour distance=3.605551 semantic=euclidean final=2.500,0.000,3.500 next=2.000,0.000,1.000 pathlen=4.130649 reachable=true reached=false finished=false` — byte-matches the authored CASES marker.
- `--straight`: exit 2 — `NEGATIVE REJECTED: ... distance=2.828427 euclid=2.828427 pathlen=2.828427 discriminates=false` — reproduces the r69 coincident case as a control.
- `--assert-pathsum`: exit 2 — `NEGATIVE REJECTED: ... distance=3.605551 expected_pathsum=4.130649 euclid=3.605551` — the falsified hypothesis rejects on measured value.

Receipts: `runs/author_detour.*`, `author_straight.*`,
`author_assert_pathsum.*` under `corpus/live/r70-boundary/runs/`. Two
independent geometries, identical semantics, exact marker agreement — the
r69 UNKNOWN resolves to EUCLIDEAN on this host with convergent evidence.

## Divergences and honest caveats

- First draft of the `--straight` assertion required `path.size()==2` and
  failed on the measured 3-point chain (portal midpoint retained) — fixed
  after observing; the corridor-control PASS asserts the measured shape.
- An earlier run of the `--expect-euclid` arm typo'd the flag
  (`--expect_euclid` vs `--expect-euclid`) and silently ran the default arm;
  the arm was redesigned to `--expect-path-sum` once euclidean was measured.
  Flagless input falling through to the detour arm is a fixture-design
  caveat, recorded.
- Sibling seat `corpus/live/r70-scout/runs/probe1/probe_detour.gd` exists
  (same question, different geometry/partial-edge tests) but had NO captured
  run output when checked; this report's numbers are independent.
- One engine (`4.7.2.stable.arch_linux`), one host, one repeat
  (byte-identical); no claim on moving agents, avoidance, baked meshes,
  `path_postprocessing!=0`, `path_desired_distance`/`path_max_distance`
  gates, other engines, or rendered output.
- The path for unreachable targets routing via (3,0,0) — a longer-looking
  edge-hug rather than the intuitively shortest approach to the clamp point —
  is observed, not explained; left as an UNKNOWN for a future depth move.
