# game-dev-3d round 70 — critic (seat: critic, host: devin)

Scope of attack: falsify the detour discrimination for the declared depth move
(`navagent3d_detour.gd`: is `NavigationAgent3D.distance_to_target` Euclidean or
path-sum?). The author fixture landed mid-review (uncommitted
`corpus/fixtures/navagent3d_detour.gd` + a +6-line `run_battery.py` diff of
three CASES rows); this critic first stress-tested the *design* with an
independent harness, then replayed the actual fixture artifact. Scratch probe:
`corpus/live/r70-critic/scratch/r70c_navprobe.gd`; receipts:
`corpus/live/r70-critic/runs/*.out|.err` (probe exits 0, stderr engine banner
only). Godot `4.7.2.stable.arch_linux.ed1daf0bf`, physics 60 tps,
cell_size 0.25, 30-frame settle, same SceneTree/NavigationServer3D authoring
pattern as `navagent3d_distance.gd`.

## Primary result — the r69 UNKNOWN resolves to EUCLIDEAN, unconditionally

U-mesh: 5 quads with exact shared edges — left leg x[0,2]×z[0,8], bridge
x[0,6]×z[8,10] (three quads), right leg x[4,6]×z[0,8]. Agent (1,0,1), target
(5,0,1): the void x[2,4]×z[0,8] forces a bent route.

Verbatim (`runs/detour.out`):

    MEASURE agent_path=[(1.0, 0.0, 1.0), (2.0, 0.0, 8.0), (4.0, 0.0, 8.0), (5.0, 0.0, 1.0)]
    MEASURE agent_path_len=16.142136
    MEASURE map_path_len=16.142136
    MEASURE distance_to_target=4.000000
    MEASURE euclid_agent_target=4.000000
    MEASURE final=(5.0, 0.0, 1.0) next=(2.0, 0.0, 8.0)
    MEASURE reachable=true reached=false finished=false
    MEASURE next_off_straight_line=7.000000

`distance_to_target=4.000000` is exactly `|agent−target|` while the engine's
own routed path measures 16.142136 — **Euclidean, not path-sum**, margin
12.14 (~3000× the r69 tolerance 0.004). Unoptimized path
(`map_get_path optimize=false`, `runs/rawpath.out`) is 18.828427 — the
discrimination is postprocessing-robust. Two independent same-round probes
agree on different geometries: scout r70 (L-corridor) 3.605551 vs path
4.130649; scribe r70 5.000000 vs path 6.085044.

### Measured semantic model (this build, stationary agent, single region)

- `distance_to_target` = `|agent_pos − target_position|` — Euclidean to the
  **raw authored target**, even when no path exists (see F1).
- `get_final_position` / path end = closest reachable point toward target
  (clamped when off-mesh/unreachable).
- `is_target_reachable` ≈ `euclid(final, target) <= target_desired_distance`.
  Boundary measured: offmesh gap=1.0 gives reachable=false at `--tdd=0.5`
  and `--tdd=0.9`, true at default 1.0 and `--tdd=1.5` (`runs/offmesh-tdd*.out`).
- `is_target_reached` / `is_navigation_finished` = Euclidean radius gate on
  `distance_to_target` (see F3).

## Findings — counterexamples and traps the fixture must survive

**F1 (sharpest): Euclidean value is degenerate-indistinguishable.** With
degenerate geometry (zero-vertex polygons from a vertex-assignment bug in my
first probe iteration — every arm's path empty, `reachable=false`,
`final=(0,0,0)`), `distance_to_target` STILL returned the exact Euclidean
value in all six arms (e.g. `distance_to_target=4.000000` with
`agent_path=[]`). A fixture that asserts only `distance≈euclidean` cannot
distinguish "engine returns Euclidean semantics" from "path computation
silently absent." The discrimination claim is valid **only** when the
fixture also proves the routed path exists and is bent: assert
`reachable=true`, `final≈target`, and `next` (or a path waypoint) off the
spawn→target line by a stated margin (measured 7.0 on this U-geometry).

**F2: measured distance anchors to a different point than the path.** Offmesh
arm (`--offmesh`, target (3,0,5) in the void): `final=(2,0,5)`,
`agent_path` ends at the clamp (len 4.123106), yet
`distance_to_target=4.472136` = euclid to the RAW target — not to final
(euclid_agent_final=4.123106). So `final`/`next`/`path` describe the clamped
endpoint while `distance` describes the raw one. If the author's mesh edges
misalign and the target silently clamps, the distance value stays
innocent-Euclidean; only the `final≈target` and `reachable` assertions expose
it. They are load-bearing, not decorative.

**F3: reach gates fire through the wall.** `--wide-detour` (U-mesh,
`target_desired_distance=5.0`, agent stationary): `reached=true
finished=true` with path 16.142136 never traversed — the gate consumes the
Euclidean metric, not path progress. Stronger: `blocked --tdd=5.0` (no path
to target at all) yields `reachable=true reached=true finished=true` — the
clamped final (2,0,1) sits 3.0 < 5.0 from target and the agent 4.0 < 5.0.
An author porting r69's `--wide-reach` control onto detour geometry stays
correct (and strengthens the Euclidean claim), but any expectation that
`reached`/`reachable` imply path existence or traversal is falsified.

**F4: query-order dependency.** `get_current_navigation_path()` returned `[]`
in all arms when called before `get_next_path_position()`; reordering (matching
`navagent3d_next.gd:30-31`) populated it identically to `map_get_path`
(optimize=true) in every arm. If the fixture asserts the detour via the cached
path it must query it after `get_next_path_position`, or use
`NavigationServer3D.map_get_path` directly. First-iteration receipts
(`runs/detour.out` pre-reorder, superseded) and the post-reorder runs preserve
both halves of this evidence.

**F5: degenerate-case behavior table** (verbatim fields in `runs/`):

| arm | path len | distance | final | reachable | note |
|---|---|---|---|---|---|
| detour | 16.142136 | 4.000000 | =(5,0,1) target | true | discriminates 12.14 |
| flat control | 4.000000 | 4.000000 | =target | true | semantics coincide; kept |
| blocked (bridge mid removed) | 1.000000 partial to (2,0,1) | 4.000000 | clamps (2,0,1) | **false** | Euclidean anyway; path end ≠ target |
| partial (floor gap x[4,6], detour strip) | 8.576491 | 8.000000 | =(9,0,1) | true | margin 0.576 ≈144× tol — thin but real |
| edge-target (3,0,8) on polygon boundary | 8.071068 | 7.280110 | =target | true | boundary targets reachable & clean |
| offmesh (3,0,5) in void | 4.123106 to clamp | 4.472136 | (2,0,5) | true (gap=1.0=tdd) | distance anchors raw target |
| wide-detour tdd=5.0 | 16.142136 | 4.000000 | =target | true; reached/finished true | gate fires through wall |
| blocked tdd=5.0 | 1.000000 | 4.000000 | (2,0,1) | **true; reached/finished true** | no-path "reached" falsification |

Fixture-claim survival per degenerate case: fully-blocked geometry does NOT
discriminate semantics (distance reads Euclidean regardless) — a blocked arm
must assert reachable=false + clamped final, not path-shaped distances;
partial-block works but with thin margin; boundary targets are safe; and
under any raised `target_desired_distance` a blocked/off-mesh target can read
`reachable/reached/finished` all-true — such arms must pin the default radius.

## Review of the landed fixture (`navagent3d_detour.gd`, uncommitted)

Independent replay in own scratch (`runs/fixture.out`,
`runs/fixturestraight.out`, `runs/fixtureassertpathsum.out`): all three arms
produce the declared markers byte-exact and the declared exits —

    PASS navagent3d_detour distance=3.605551 semantic=euclidean final=2.500,0.000,3.500 next=2.000,0.000,1.000 pathlen=4.130649 reachable=true reached=false finished=false   (exit 0)
    NEGATIVE REJECTED: navagent3d_detour straight distance=2.828427 euclid=2.828427 pathlen=2.828427 discriminates=false                                            (exit 2)
    NEGATIVE REJECTED: navagent3d_detour assert_pathsum distance=3.605551 expected_pathsum=4.130649 euclid=3.605551                                                   (exit 2)

Mapping against the traps above — the fixture **survives all of them**:

- F1 covered: bend asserted at query time (`path.size()==3`,
  `next≈(2,0,1)` within 0.001, `pathlen≈4.130649` within 0.004, and a
  declared margin `pathlen − euclid ≥ 0.4`, detour lines 103–106) — a silent
  absent/straight path fails the gate rather than passing as Euclidean.
- F2 covered: `final.distance_to((2.5,0,3.5)) ≤ 0.001` + `reachable` pin the
  anchor to an on-mesh endpoint; spawn and `target_position` pinned ±1e-4.
- F3 dodged by construction: no reach-radius arm on detour geometry; the
  default arm asserts `reached=false finished=false` (3.606 > tdd 1.0).
- F4 dodged: `get_next_path_position()` (line 69) precedes
  `get_current_navigation_path()` (line 70) — the populated order.
- `--assert-pathsum` negative arm is honest: it re-runs the bend gate, then
  exits 2 on the measured refutation — the discrimination is measured, not a
  literal comparison. `--straight` keeps the r69-coincident control as exit-2.

Residual nits (non-blocking): `path[0]` is not asserted ≈spawn (the 3-point
count + length + next assertions make a displaced anchor implausible but not
formally excluded); the `euclidean`-first `elif` ordering is safe only
because the two candidates differ by 0.525 >> 2×tol — fine for this geometry,
fragile if the constants were ever tightened to within 2×tol of each other;
discrimination margin is 0.525098 (~131× tol), narrower than this critic's
U-geometry margin 12.14 but decisive. Hand-derived `DETOUR_PATHLEN`
(√2.5+√6.5=4.130649) matches the engine-routed length exactly through the
portal vertex — verified live.

Polygon winding/portal audit: A1/A2 share x=2,z[0,1] and A2/B share
z=1,x[2,3] as reversed-direction edge pairs; all three quads wind +Y —
connections are exact-edge, not margin-dependent.

## Impacted axes

- **depth** — the declared move is viable: forced-detour geometry
  discriminates with ~12 units margin and the UNKNOWN resolves to Euclidean
  on this host (corroborated by three independent geometries). Admissibility
  hinges on the fixture carrying the F1/F2 assertions; without them the
  claimed discrimination is vacuous, not merely weak.
- **calibration** — F3/F4 are new measured gotchas (Euclidean reach gate,
  query-order dependence, reachable=radius-gate-on-final) that any new
  marker must encode honestly; none block admission.

Residual UNKNOWNs honestly scoped: semantics while the agent is mid-motion
(remaining-path evolution untested — all probes stationary at settle);
`path_postprocessing` variants other than the two sampled; the inferred
`reachable ⇔ euclid(final,target) ≤ tdd` rule is boundary-sampled (4 points),
not source-proven.

## Smallest safe correction

None required — the landed fixture already carries the assertions my
degenerate cases demand (reachable + final≈target + off-line waypoint +
pathlen−euclid margin + correct query order). If it is ever amended, the two
hardening candidates are asserting `path[0]≈spawn` and documenting that the
elif-order classification requires the candidate gap to exceed 2×tol.
`distance_to_target` measured truth on this host: `|agent − target_position|`
unconditionally — Euclidean to the raw target, not path-sum, not
final-anchored; the fixture's asserted value 3.605551 is correct, and its
claim is properly bounded to this geometry/build.
