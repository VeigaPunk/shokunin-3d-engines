# Game-dev-3d round 70 — scribe report (seat: scribe, host: devin)

Declared lane axis-move (from dispatch): **depth** — resolve the r69 UNKNOWN
"is `NavigationAgent3D.distance_to_target` Euclidean or path-sum?" by adding a
`navagent3d_detour.gd` fixture whose navmesh forces a non-straight path, with a
straight-line control arm. Scribe duty: draft the knowledge entry and the
LOG.md round-70 entry. Documentation draft, report-only; not the judge.

## Measured evidence (scribe-observed, scratch scope)

The declared seed fixture did not exist at observation time (no
`corpus/fixtures/navagent3d_detour.gd`; `git status` clean except this
untracked `reports/round-70/`). To keep the drafts receipt-backed, scribe ran
an independent probe in own write scope — distinct geometry, same L-corridor
discrimination idea the lane's scout seat was reconning concurrently.

Command (run twice, outputs byte-identical on all 10 `PROBE` lines):

    cd corpus/live/r70-scribe/runs/20261013T220324135042030Z
    timeout 60 /usr/bin/godot --headless --path scratch \
      --script res://navagent3d_detour_probe.gd

Godot `4.7.2.stable.arch_linux.ed1daf0bf`, physics 60 tps, map cell_size 0.25,
`edge_connection_margin=0.250000`, `path_postprocessing=0` (corridor funnel).
Geometry: three quads joined by exact shared edges — P1 x[0,3]×z[0,1],
P2 x[3,4]×z[0,1], P3 x[3,4]×z[1,5] (P1/P2 share x=3, z∈[0,1]; P2/P3 share
z=1, x∈[3,4]). Verbatim output:

    PROBE detour S=(0.500,0.000,0.500) T=(3.500,0.000,4.500) postproc=0 dist=5.000000 euclid=5.000000 final=(3.5, 0.0, 4.5) next=(3.0, 0.0, 1.0) reachable=true reached=false finished=false
    PROBE detour dist_to_final=5.000000 dist_to_next=2.549510 agent_path(3)=[(0.5, 0.0, 0.5), (3.0, 0.0, 1.0), (3.5, 0.0, 4.5)] len=6.085044
    PROBE detour map_path(3)=[(0.5, 0.0, 0.5), (3.0, 0.0, 1.0), (3.5, 0.0, 4.5)] len=6.085044 regions=1
    PROBE straight S=(0.500,0.000,0.500) T=(3.500,0.000,0.500) postproc=0 dist=3.000000 euclid=3.000000 final=(3.5, 0.0, 0.5) next=(3.0, 0.0, 0.5) reachable=true reached=false finished=false
    PROBE straight dist_to_final=3.000000 dist_to_next=2.500000 agent_path(3)=[(0.5, 0.0, 0.5), (3.0, 0.0, 0.5), (3.5, 0.0, 0.5)] len=3.000000
    PROBE straight map_path(3)=[(0.5, 0.0, 0.5), (3.0, 0.0, 0.5), (3.5, 0.0, 0.5)] len=3.000000 regions=1
    PROBE offmesh S=(0.500,0.000,0.500) T=(0.500,0.000,4.500) postproc=0 dist=4.000000 euclid=4.000000 final=(3.0, 0.0, 4.5) next=(3.0, 0.0, 0.0) reachable=false reached=false finished=false
    PROBE offmesh dist_to_final=4.716990 dist_to_next=2.549510 agent_path(4)=[(0.5, 0.0, 0.5), (3.0, 0.0, 0.0), (3.0, 0.0, 1.0), (3.0, 0.0, 4.5)] len=7.049510
    PROBE offmesh map_path(4)=[(0.5, 0.0, 0.5), (3.0, 0.0, 0.0), (3.0, 0.0, 1.0), (3.0, 0.0, 4.5)] len=7.049510 regions=1

Receipts: `corpus/live/r70-scribe/runs/20261013T220324135042030Z/`
`probe-output.txt`, `probe-output-rerun.txt` (identical PROBE lines), probe
script sha256 `3ec41767828392c3206fe81f6d9fde4cf82ea68ee97ae22b5cd0fe54473a5b30`
(`sha256.txt`).

## Verdict (measured, this host/version only)

`distance_to_target()` = **straight-line Euclidean distance from the agent's
position to the authored `target_position`**. All three rival hypotheses are
falsified on the detour arm: path-sum would be 6.085044 (agent path polyline
and `map_get_path` agree, via corner (3,0,1)), distance-to-next would be
2.549510 — measured is 5.000000 = |T−S|. The **off-mesh arm sharpens it**: T
off all polygons gives dist=4.000000 = |T−S| while `get_final_position`
projects to (3,0,4.5) at distance 4.716990 and `is_target_reachable=false` —
so the reference point is the authored target, not the projected final
position or nearest reachable point. Straight-line control arm: dist=3.000000
where all hypotheses coincide, confirming the corridor itself isn't clamping
the query.

### Retained UNKNOWNs (do not claim)

- `path_postprocessing` modes other than 0 (edge-centered path geometry would
  not change a Euclidean return, but is unmeasured).
- Moving-agent sampling: agent was stationary at spawn; whether the value
  tracks `global_position` live between path updates is unmeasured.
- Ramps/elevation: all probes coplanar y=0; multi-polygon height paths and
  whether the Euclidean sum includes the y-component on sloped navmeshes
  are unproven (r69 retained this class).
- `path_max_distance`, `path_desired_distance` interplay; behavior with zero
  reachable path (partial path to nowhere vs dist-to-target) beyond the one
  off-mesh arm above.
- Anything other engines, baked NavigationRegion3D meshes (authoring here is
  hand-built `NavigationMesh` polygons on a raw `NavigationServer3D` map),
  avoidance enabled, or rendering.

Sibling-seat observations (verbatim, for the record): `corpus/live/r70-baseline/
runs/20261013T215959381187Z/verdicts.json` = **PASS 85/85** (42 ordinary /
43 negative), `seeds_unchanged=true`, produced by another r70 seat pre-move.
A concurrent `corpus/live/r70-scout/runs/probe1/probe_detour.gd` recon script
exists (three connectivity variants — exact edges, partial overlap, concave
single polygon — at S=(0.5,0,0.5) T=(2.5,0,3.5)); its godot process was
observed running at ~19:01 but wrote no persisted receipt file, so its output
is not citable here. No conflicts between seats observed.

## Draft: knowledge entry — NavigationAgent3D distance semantics

(Proposal for `corpus/knowledge/` or fixtures README; admission pending
author + named non-author replay.)

> **`NavigationAgent3D.distance_to_target()` — Euclidean to authored target
> (Godot 4.7.2, headless, pinned host).** Measured on a forced-detour
> L-corridor navmesh (three quads, exact shared edges, map cell_size 0.25,
> `path_postprocessing=0`): agent (0.5,0,0.5) → target (3.5,0,4.5), returned
> 5.000000 = |T−S| while the computed path bent through corner (3,0,1) with
> polyline length 6.085044 (both `get_current_navigation_path` and
> `NavigationServer3D.map_get_path` agree). Path-sum and distance-to-next
> (2.549510) hypotheses falsified. Off-mesh target (0.5,0,4.5): returns
> 4.000000 = |T−S| even when `is_target_reachable=false` and
> `get_final_position` sits 4.716990 away — the reference is the authored
> `target_position`, not the projected final point. Straight corridor arm:
> 3.000000, both candidates coincide (control). Companion semantics (r69):
> `is_target_reached`/`is_navigation_finished` gate on
> `target_desired_distance` against this same Euclidean value — reach radius
> 3.0 flips them true at measured 2.828427 with zero movement. Use
> `get_current_navigation_path()` and sum segments if a path-length figure is
> needed; `distance_to_target` alone gives crow-flies. Receipts:
> `corpus/live/r70-scribe/runs/20261013T220324135042030Z/` (scribe scratch);
> pending seed fixture `navagent3d_detour.gd` + non-author replay. UNKNOWNs:
> other `path_postprocessing` modes, moving agent, sloped/multi-level
> navmeshes, reachability edge regimes.

## Draft: LOG.md round-70 entry

(Modeled on the r69 format; bracketed slots belong to author/verifier/parent
receipts not yet produced.)

    ## Round 70 — devin host — depth: NavAgent3D distance_to_target semantics discrimination

    - Declared (dispatch brief): add `navagent3d_detour.gd` whose navmesh
      forces a non-straight agent→target path, discriminating Euclidean vs
      path-sum `distance_to_target` (r69 measured 2.828427 on a convex 4x4
      polygon where both coincide); keep a straight-line control arm. Prior
      85 rows + 4 probes must stay byte-stable; non-author replay required.
    - Baseline (sibling seat): `corpus/live/r70-baseline/runs/20261013T215959381187Z`
      PASS 85/85 (42 ordinary/43 negative), seeds_unchanged=true, godot
      4.7.2.stable.arch_linux.ed1daf0bf.
    - Scribe scratch probe (pre-fixture, `corpus/live/r70-scribe/runs/20261013T220324135042030Z`,
      deterministic over 2 runs): L-corridor detour arm dist=5.000000 = |T−S|
      vs path len 6.085044 via corner (3,0,1); off-mesh arm dist=4.000000 =
      |T−S| with final projected at 4.716990 and reachable=false — semantics
      resolved Euclidean-to-authored-target. Probe sha256 3ec41767….
    - [author: fixture + CASES rows, marker strings, battery result]
    - [verifier: named non-author replay receipt]
    - Per-axis verdicts (parent, on named non-author replay): **depth
      improved [pending]** — r69's Euclidean-vs-path-sum UNKNOWN resolved by
      forced-detour discrimination plus straight control; **coverage
      unchanged** (same Godot NavAgent3D single-map scene); **calibration
      unchanged** (existing exit/marker/seed contract). Retained UNKNOWNs:
      other path_postprocessing modes, moving agents, sloped/multi-polygon
      elevation paths, reachability edge regimes. Admit pending: one improved,
      none harmed, requires verifier replay.

## Gates / discipline check

- Leaf member: no subagent dispatch; no git write op run (no commit/push/
  merge/rebase/stash/checkout); `git status` shows only the sibling-created
  untracked `reports/round-70/`.
- Writes confined to `reports/round-70/r70-scribe.md` and
  `corpus/live/r70-scribe/runs/20261013T220324135042030Z/` (scratch project
  copy of `project.godot` + `navagent3d_detour_probe.gd` + 3 receipt files).
  Seed fixtures, runner, LOG.md, SCORECARD.md, knowledge files untouched.
- No seed edited, no battery rerun, no sibling scope written (r70-baseline,
  r70-scout read-only). Falsified-claim discipline: the path-sum hypothesis
  was falsified by measurement and is reported as such, not forced.

## Out-of-scope items

- Authoring the actual `corpus/fixtures/navagent3d_detour.gd` seed + CASES
  registration — author's scope (in-flight under sibling seats).
- Verdict/admission — parent judge on named non-author replay.
- Domain-facing actions — operator-owned; none taken.

## Findings summary

1. `distance_to_target` is Euclidean to the authored `target_position`
   (detour 5.0 vs path 6.085; off-mesh 4.0 vs final 4.717). r69 UNKNOWN
   resolved in measurement; seed-level admission pending author+verifier.
2. Reachability does not gate the distance value: off-mesh target still
   returns the Euclidean figure while `is_target_reachable=false`.
3. `get_current_navigation_path` == `map_get_path` polyline on all three
   arms; path-sum available by summing segments if ever needed.
4. Baseline 85/85 PASS receipt exists for r70 pre-move comparison.
5. Scout recon probe left no persisted receipt — its stdout was not
   redirected to a file; flagged so the parent doesn't cite it.

## Artifact paths

- This report: `.shokunin/game-dev-3d/reports/round-70/r70-scribe.md`
- Probe script + receipts: `.shokunin/game-dev-3d/corpus/live/r70-scribe/runs/20261013T220324135042030Z/`
  (`scratch/navagent3d_detour_probe.gd`, `probe-output.txt`,
  `probe-output-rerun.txt`, `sha256.txt`)
- Cited read-only: `corpus/live/r70-baseline/runs/20261013T215959381187Z/verdicts.json`,
  `corpus/fixtures/navagent3d_distance.gd`, `reports/round-69/r69-{author,verifier}.md`
