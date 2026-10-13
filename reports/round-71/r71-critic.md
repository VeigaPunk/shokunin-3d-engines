# game-dev-3d round 71 — critic (seat: critic, host: devin)

Scope of attack: falsify the declared depth claim — "`path_postprocessing`
{edgecentered(1), none(2)} leaves `distance_to_target` Euclidean-invariant
while changing `get_next_path_position`/`get_final_position` outputs" — on
the r70 L-corridor semantics (`distance_to_target` = Euclidean to raw
`target_position`, 3.605551 = √13 vs routed 4.130649). Scratch probe:
`corpus/live/r71-critic/scratch/r71c_postproc.gd` (sha256
`d847bd04504c66e94f7476e68d7970b2cb022656e964c68bad4e811a9857fad3`), plus
verbatim copies of `project.godot` (sha `1fda90d4…23`, = committed) and the
r71 working-tree `navagent3d_detour.gd` (sha `5b873cd0…47`, the author's
post-arm artifact). Godot `4.7.2.stable.arch_linux.ed1daf0bf` via
`/usr/bin/godot --headless`; physics 60 tps; cell_size 0.25; 30-frame
settle; stationary agent, single region — same authoring pattern as
`navagent3d_detour.gd`.

Command shape per arm (receipts `corpus/live/r71-critic/runs/<arm>.out` /
`.err` / `.exit`):

    godot --headless --path corpus/live/r71-critic/scratch \
        --script res://r71c_postproc.gd -- --postproc=N [--offmesh|--offedge|--island]

13 godot invocations, all exit 0, all stderr empty (engine banner goes to
stdout on this host's script mode), `detour-p1` rerun byte-identical
(`detour-p1-repeat.out`).

## Attack (a): is the edgecentered discrimination vacuous? — NO, fails

`--postproc=1` measurably changes the queried path vs `--postproc=0` on the
identical navmesh (detour geometry, S=(0.5,0,0.5), T=(2.5,0,3.5)):

| postproc | agent_path | next | final | pathlen |
|---|---|---|---|---|
| 0 corridorfunnel | [S,(2,0,1),T] (3 pts) | (2,0,1) | (2.5,0,3.5) | 4.130649 |
| 1 edgecentered | [S,(2,0,0.5),(2.5,0,1),T] (4 pts) | (2,0,0.5) | (2.5,0,3.5) | 4.707107 |
| 2 none | [S,(2,0,0.5),(2,0,1),T] (4 pts) | (2,0,0.5) | (2.5,0,3.5) | 4.549510 |

`get_next_path_position` moves 0.5 (corner → edge midpoint) under both
non-default values; path length changes by +0.576458 (edgecentered) /
+0.418861 (none) — both ≫ DIST_TOL 0.004. Edgecentered matches hand-derived
1.5+√0.5+2.5 = 4.707107; `none` ≠ `edgecentered`: the raw path keeps the
corridor corner (2,0,1) at index 2 where edgecentered uses the z=1-edge
midpoint (2.5,0,1). The knob demonstrably took effect: **attack fails —
the discrimination is real, not vacuous.**

Discrimination warning (convergent with r71 scout): `next` alone is
identical under 1 and 2 on this geometry; only `path[2]` position or
`pathlen` (4.707107 vs 4.549510, gap 0.157597 ≈ 39× tol) separates them.

## Attack (b): does distance track the moved next-point? — NO, fails

Under postproc=1 the next-path point moved to (2,0,0.5): measured
`dist_to_next=1.500000` while `distance_to_target=3.605551` — √13 to the
raw target, exactly, at all six decimals. Same under postproc=2. The
"tracks next-point" hypothesis is falsified by a 2.105551 gap (~526× the
0.004 fixture tolerance). All candidate referents measured and excluded
per arm:

| arm | postproc | distance_to_target | euclid(raw T) | dist_to_next | dist_to_final |
|---|---|---|---|---|---|
| detour | 0/1/2 | 3.605551 | 3.605551 | 1.581139 / 1.500000 / 1.500000 | 3.605551 |
| offmesh T=(2.5,0,5) | 0/1/2 | 4.924429 | 4.924429 | 1.581139 / 1.5 / 1.5 | 4.031129 |
| island T=(0.5,0,3.5) on disconnected D | 0/1/2 | 3.000000 | 3.000000 | 1.581139 / 1.5 / 1.5 | 3.354102 |
| offedge T=(2.9,0,5) | 0/1/2 | 5.100000 | 5.100000 | 1.581139 / 1.5 / 1.5 | 4.243819 |

Sharpest cell: **offmesh is a *reachable* clamped arm** — `reachable=true`
(target_desired_distance 1.0 gate: euclid(final,(2.5,0,5))=1.0 ≤ 1.0,
consistent with the r70 boundary radius rule) with `final=(2.5,0,4)` ≠ T —
yet distance stays 4.924429 = euclid to raw T, not 4.031129 to final. So
`distance_to_target` keys on raw `target_position` (not path end, not next
point) even when the agent's own *reachable* postprocessed path ends
elsewhere — under all three postprocessing values. r70's equivalent
evidence was reachable=false only; this adds the reachable-clamped cell.

## Attack (c): find a postproc value that moves get_final_position — FAILS

`get_final_position` is postprocessing-**invariant** in all 12 measured
arms (4 geometries × 3 values): detour final=(2.5,0,3.5)=T; offmesh
(2.5,0,4); island (2,0,3.5); offedge (2.9,0,4) — identical under
corridorfunnel/edgecentered/none on every geometry.

The `--offedge` arm was built specifically to bait edgecentering: T=(2.9,0,5)
clamps to (2.9,0,4), an interior point of B's z=4 edge x∈[2,3] whose center
is (2.5,0,4). Edgecentered relocated both *internal* waypoints to edge
midpoints but left the endpoint at the non-center clamp (2.9,0,4). The path
endpoint (= closest reachable point toward target) is structurally exempt
from postprocessing on this build.

Consequence for the claim as worded: the "`get_final_position` changes"
clause is **measured false** — the only outputs that actually move are
`get_next_path_position` and the intermediate path array/length. The
author's landed fixture already reflects this narrowing: its post arms pin
`final=(2.5,0,3.5)` *unchanged* and `distance` still keys on raw T anyway,
so the falsification attempt on (c) fails — invariance stands.

## Verbatim replay of the author's landed arms (working-tree fixture)

`navagent3d_detour.gd` sha `5b873cd0…` in my scratch, battery flags:

    --post-edgecentered → exit 0, stdout byte-exact vs CASES marker:
      PASS navagent3d_detour post_edgecentered distance=3.605551
      semantic=euclidean final=2.500,0.000,3.500 next=2.000,0.000,0.500
      pathlen=4.707107 reachable=true reached=false finished=false
    --post-none → exit 0, byte-exact:
      PASS navagent3d_detour post_none distance=3.605551 semantic=euclidean
      final=2.500,0.000,3.500 next=2.000,0.000,0.500 pathlen=4.549510 …

Fixture audit notes: postproc set before `target_position` (lines 81–85);
each arm pins path.size()==4 + next=(2,0,0.5) + per-arm pathlen so a flag
that did not take effect cannot pass; semantic classifier + exit-1
diagnostic is the honest falsification path. One residual nit (non-blocking):
interior path points are pinned only via `pathlen`, not positionally — the
1-vs-2 discrimination rests on a single scalar (adequate here, 39× tol) and
a `next` that is identical under both values.

## Net verdict

- Declared invariance claim: **measured-intact, not falsified** — survives
  attacks (a),(b),(c) on 4 geometries × 3 postprocessing values plus
  verbatim arm replay; `distance_to_target` = Euclidean to raw
  `target_position` everywhere (12/12 arms, 6-decimal equality).
- As worded the claim overreached on `get_final_position` (never moves);
  the landed artifact already narrowed to next/path — correct per these
  measurements.
- Bounded: stationary agent, single region, cell_size 0.25, this Godot
  build, corridor-class authored geometries. Unprobed: moving agent /
  mid-path retarget under postproc, `simplify_path` interaction,
  `map_get_path`-level postprocessing parity, multi-region maps.

Receipts: `corpus/live/r71-critic/runs/` (16 arms × .out/.err/.exit incl.
control + repeat), probe `corpus/live/r71-critic/scratch/r71c_postproc.gd`.
No tracked files touched, no commits, leaf — no dispatch.
