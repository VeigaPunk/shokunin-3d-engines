# R70 — NavigationAgent3D distance_to_target is Euclidean (Godot 4.7.2)

## Decision and evidence

`distance_to_target()` returns **Euclidean distance to the raw authored
`target_position`** — never the routed path sum, and (sharper) never distance
to the clamped/computed path end.

| geometry | routed path len | distance_to_target | discriminates |
|---|---|---|---|
| L-corridor 3-quad (fixture), (0.5,0,0.5)→(2.5,0,3.5) via (2,0,1) | 4.130649 | **3.605551 = √13** | yes, gap 0.525 ≈131× tol |
| tromino (scribe) | 6.085044 | 5.000000 | yes |
| U-corridor (critic) | 16.142136 | 4.000000 | yes |
| convex 4x4 control `--straight`, (1,0,1)→(3,0,3) | 2.828427 | 2.828427 | no — candidates coincide |
| off-mesh/gap target (boundary, scout) | — | euclid to raw target while `final` clamps | reference is authored target |
| absent path / degenerate mesh (critic) | none | still exact Euclidean | a distance-only assert can't tell Euclidean from silent-no-path — fixture pins reachable/final/next/pathlen |

Companion map (boundary): `get_next_path_position` returns the next chain
waypoint (detour corner), `get_final_position` returns the computed path END
(raw target when reachable; closest-on-component when not);
`is_target_reachable`/`is_target_reached`/`is_navigation_finished` key on
`euclid(final_position, target) ≤ target_desired_distance` — reachable=true
with **zero path** when `tdd ≥ euclid(final,target)` (fires "through walls",
blocked arm tdd=5.0 measured). Portal-crossing midpoints stay in the chain
even when collinear (`--straight`: 3 points via (3,0,0.5)) — observed,
unexplained.

Named non-author `corpus/lessons/r70-navagent-detour-non-author.json`:
88/88 PASS (85 prior rows 0 mismatches ×11 fields vs frozen baseline), 4
probes PASS, `seeds_unchanged=true`; Node suites 31/31 all
`seedsUnchanged=true`. Spot-checks verbatim: detour marker exit 0;
`--assert-pathsum` exit 2 `NEGATIVE REJECTED … expected_pathsum=4.130649
euclid=3.605551`. See `../../reports/round-70/r70-verifier.md`,
`r70-adjudicator.md`. Work `2a0e46f`+`0ea70cf`, fixture sha `669c539d…`.

## Not established

Moving-agent semantics; non-CORRIDORFUNNEL postprocessing; other engine
versions (the `path.size()==3` funnel-vertex pin is this-build evidence);
`navagent3d_retarget` intermittence (r68 SDL stderr / r69 0.0236 drift)
remains open; no rendering, GPU, arbitrary-geometry or production inference.
