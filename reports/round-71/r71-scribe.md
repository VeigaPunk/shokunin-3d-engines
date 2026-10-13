# Game-dev-3d round 71 — scribe report (seat: scribe, host: devin)

Declared lane axis-move (from dispatch): **depth** — resolve whether
`NavigationAgent3D.path_postprocessing` changes the r70-established
Euclidean `distance_to_target` semantics. Claim under test:
`{edgecentered(1), none(2)}` leave `distance_to_target` Euclidean-invariant
while changing `get_next_path_position`/`get_final_position` outputs; reuse
`navagent3d_detour.gd` geometry with a postprocessing arm; a measured
distance change under any value falsifies invariance. Scribe duty:
draft the knowledge/lesson entry (`corpus/lessons/` convention) plus the
LOG.md round-71 entry — report-only; not the judge.

## Measured evidence (scribe-observed, scratch scope)

Independent probe `corpus/live/r71-scribe/runs/20261013T234701309638844Z/scratch/pp_semantics_probe.gd`
(sha256 `15b350765b474c5488dc4b839c04629453aa9398bcb836dc6050da1fb8f4d50d`)
— own implementation, r70 L-corridor verbatim geometry (A1 x[0,2]z[0,1],
A2 x[2,3]z[0,1] shared x=2 edge; B x[2,3]z[1,4] shared z=1 edge),
S=(0.5,0,0.5) → T=(2.5,0,3.5), plus a server-level arm driving
`NavigationServer3D.query_path` with an explicit
`NavigationPathQueryParameters3D.path_postprocessing`. Command:

    cd corpus/live/r71-scribe/runs/20261013T234701309638844Z
    timeout 60 /usr/bin/godot --headless --path scratch \
      --script res://pp_semantics_probe.gd

Godot `4.7.2.stable.arch_linux.ed1daf0bf`, physics 60 tps, cell_size 0.25,
30-frame settle, stationary agent. Run twice; `diff` confirms all 10 PROBE
lines byte-identical (`probe-output.txt` = `probe-output-rerun.txt`),
stderr empty both runs. Verbatim:

    PROBE geom=detour arm=agent pp=corridorfunnel(0) dist=3.605551 euclid=3.605551 npts_pre=0 npts=3 pathlen=4.130649 next=(2.0, 0.0, 1.0) final=(2.5, 0.0, 3.5) reachable=true reached=false finished=false pts=(0.500,0.000,0.500)(2.000,0.000,1.000)(2.500,0.000,3.500)
    PROBE geom=detour arm=agent pp=edgecentered(1) dist=3.605551 euclid=3.605551 npts_pre=0 npts=4 pathlen=4.707107 next=(2.0, 0.0, 0.5) final=(2.5, 0.0, 3.5) reachable=true reached=false finished=false pts=(0.500,0.000,0.500)(2.000,0.000,0.500)(2.500,0.000,1.000)(2.500,0.000,3.500)
    PROBE geom=detour arm=agent pp=none(2) dist=3.605551 euclid=3.605551 npts_pre=0 npts=4 pathlen=4.549510 next=(2.0, 0.0, 0.5) final=(2.5, 0.0, 3.5) reachable=true reached=false finished=false pts=(0.500,0.000,0.500)(2.000,0.000,0.500)(2.000,0.000,1.000)(2.500,0.000,3.500)
    PROBE geom=detour arm=server pp=corridorfunnel(0) npts=3 pathlen=4.130649 euclid=3.605551 pts=(0.500,0.000,0.500)(2.000,0.000,1.000)(2.500,0.000,3.500)
    PROBE geom=detour arm=server pp=edgecentered(1) npts=4 pathlen=4.707107 euclid=3.605551 pts=(0.500,0.000,0.500)(2.000,0.000,0.500)(2.500,0.000,1.000)(2.500,0.000,3.500)
    PROBE geom=detour arm=server pp=none(2) npts=4 pathlen=4.549510 euclid=3.605551 pts=(0.500,0.000,0.500)(2.000,0.000,0.500)(2.000,0.000,1.000)(2.500,0.000,3.500)
    PROBE geom=straight arm=agent pp=corridorfunnel(0) dist=2.828427 euclid=2.828427 npts_pre=0 npts=2 pathlen=2.828427 next=(3.0, 0.0, 3.0) final=(3.0, 0.0, 3.0) reachable=true reached=false finished=false pts=(1.000,0.000,1.000)(3.000,0.000,3.000)
    PROBE geom=straight arm=agent pp=edgecentered(1) dist=2.828427 euclid=2.828427 npts_pre=0 npts=2 pathlen=2.828427 next=(3.0, 0.0, 3.0) final=(3.0, 0.0, 3.0) reachable=true reached=false finished=false pts=(1.000,0.000,1.000)(3.000,0.000,3.000)
    PROBE geom=straight arm=agent pp=none(2) dist=2.828427 euclid=2.828427 npts_pre=0 npts=2 pathlen=2.828427 next=(3.0, 0.0, 3.0) final=(3.0, 0.0, 3.0) reachable=true reached=false finished=false pts=(1.000,0.000,1.000)(3.000,0.000,3.000)

### Scribe observations beyond the headline

1. **Call-order fact (new, measured):** `get_current_navigation_path()`
   read *before* the first `get_next_path_position()` returns an empty
   array (`npts_pre=0`) on all six agent arms — all three postprocessing
   values, both geometries. After the first `next` call the stored path is
   populated. `distance_to_target`, `get_final_position`, and
   `is_target_reachable` were already correct *before* any `next` call —
   consistent with `distance_to_target` never consulting path state. The
   r70 fixture always queries `next` first (`navagent3d_detour.gd:69-70`),
   so this ordering dependency was previously invisible. Mechanism (lazy
   path materialization on first next-query) is inferred, not proven.
2. **Server-level parity (independent reproduction of scout's claim):**
   `NavigationServer3D.query_path(qp, qr)` with
   `qp.path_postprocessing` = each enum value yields point-for-point
   identical arrays and lengths to the agent-level arms — the agent
   property maps 1:1 onto the query parameter on this build. (The
   lower-level `map_get_path` takes no query-parameters arg — scout's
   measured parse failure; `query_path` is the parameterized entry.)
3. **Straight control is postprocessing-invisible:** single convex 4x4
   polygon gives byte-identical rows under all three values (npts=2 —
   no portals to postprocess). Only multi-polygon corridors discriminate.
4. **Fixture-arm verbatim replay:** all five arms of the author's
   working-tree `navagent3d_detour.gd` (sha256
   `5b873cd06a8f50cb98a97764eb914e2a80f8553edb9ae216543979624d531647` —
   matches author's reported post-edit sha) run in scribe scratch:

   | arm | exit | stdout (byte-exact vs CASES marker) |
   |---|---|---|
   | default | 0 | `PASS navagent3d_detour distance=3.605551 semantic=euclidean final=2.500,0.000,3.500 next=2.000,0.000,1.000 pathlen=4.130649 reachable=true reached=false finished=false` |
   | `--post-edgecentered` | 0 | `PASS navagent3d_detour post_edgecentered distance=3.605551 semantic=euclidean final=2.500,0.000,3.500 next=2.000,0.000,0.500 pathlen=4.707107 reachable=true reached=false finished=false` |
   | `--post-none` | 0 | `PASS navagent3d_detour post_none distance=3.605551 semantic=euclidean final=2.500,0.000,3.500 next=2.000,0.000,0.500 pathlen=4.549510 reachable=true reached=false finished=false` |
   | `--straight` | 2 | `NEGATIVE REJECTED: navagent3d_detour straight distance=2.828427 euclid=2.828427 pathlen=2.828427 discriminates=false` |
   | `--assert-pathsum` | 2 | `NEGATIVE REJECTED: navagent3d_detour assert_pathsum distance=3.605551 expected_pathsum=4.130649 euclid=3.605551` |

   All stderr empty (receipts `fixture-*.out`/`.err`).

## Wave state at observation time

- Sibling reports present: `r71-{baseline,scout,author,reviewer,critic,
  simplifier}.md`; verifier/adjudicator not yet landed — LOG draft marks
  those slots pending.
- Tracked writes (author only, uncommitted working tree — `git status`):
  `M corpus/fixtures/navagent3d_detour.gd` (+45 lines, sha `669c539d…` →
  `5b873cd0…47`), `M corpus/fixtures/run_battery.py` (+4 lines, two CASES
  tuples, sha `5a7d6c13…` → `b4b314997177c0a53ebd9cdf1f94f4ba91f3e7e7d774f4f4154e9169b1513809`).
- Author battery receipt (independently field-checked by scribe):
  `corpus/live/r71-author/runs/20261013T233731295600Z/verdicts.json` —
  `verdict: PASS`, `totals {cases:90 pass:90 fail:0 ordinary:45
  negative_controls:45}`, `seeds_unchanged: true`,
  `godot_version 4.7.2.stable.arch_linux.ed1daf0bf`; both post rows PASS
  with the CASES markers above.
- Baseline (frozen `git archive HEAD` at `9458c18`): 88/88 + 4 probes +
  Node 31/31, `seeds_unchanged=true`,
  `corpus/live/r71-baseline/runs/20261013T233444776454Z/verdicts.json`.
- Critic: 12 arms (4 geometries × 3 postprocessing values) — distance
  Euclidean to raw target in all; sharpest cell = reachable-clamped
  off-mesh T=(2.5,0,5): `distance_to_target=4.924429` = euclid to raw T,
  not 4.031129 to `final=(2.5,0,4)`, while `reachable=true`.
- Simplifier: four scratch mutants all exit 1 on measured diagnostics
  (setter swap → pathlen pin; setter deletion → npts+next pins; constant
  swap → measured-vs-pin; `distance:=pathlen` → `invariance falsified …
  semantic=path_sum`); focused battery 5/5
  (`runs/20261013T233854937978Z/verdicts.json`).
- Reviewer audited r70 (all AGREE) and caught a live `seeds_unchanged=false`
  when the author's mid-run edits landed — the drift guard fired correctly;
  archive-isolated replay clean.
- No conflicts between seats observed; no seat touched another's scope.

## Verdict (measured, this host/version only)

**Invariance CONFIRMED:** `distance_to_target()` = **3.605551 = √13**
(Euclidean to raw `target_position`) under corridorfunnel(0),
edgecentered(1), and none(2) — identical to 6 decimals across every seat's
independent probe (author, scout, critic ×4 geometries, simplifier, scribe
agent- and server-level arms). The flag measurably took effect: `next`
(2,0,1)→(2,0,0.5), `npts` 3→4, `pathlen` 4.130649→4.707107/4.549510 — so
the discrimination is real, not vacuous.

**Narrowing on the claim as worded:** `get_final_position` is
postprocessing-*invariant* — (2.5,0,3.5) under all three values on every
geometry measured (12/12 critic arms, my 6 agent arms). The outputs that
move are `get_next_path_position` and the path array/length. The claim's
"changing … `get_final_position`" clause is measured false; the author's
landed fixture correctly pins `final` unchanged as an invariance witness.
Per discipline: partially-false claim corrected in the record, not enacted.

Hand-derivation explains the lengths: funnel √2.5+√6.5 = 4.130649;
edgecentered 1.5+√0.5+2.5 = 4.707107 (both portal midpoints
(2,0,0.5),(2.5,0,1)); none 1.5+0.5+√6.5 = 4.549510 (raw corridor keeps
edge midpoint AND corner (2,0,1)). **Edge vs none is invisible to `next`**
(both (2,0,0.5)) — only `path[2]` or `pathlen` (gap 0.157597 ≈ 39×
DIST_TOL) separates them; the fixture pins per-arm pathlen for exactly
this reason.

### Retained UNKNOWNs (do not claim)

- `path_metadata_flags` non-default values (default 7 = INCLUDE_ALL
  measured; TYPES/RIDS/OWNERS extraction mapped by scout, effect of
  restricted flags unprobed).
- Moving agent: stationary at path start throughout; live
  `global_position` tracking, mid-path retargets, and repath windows under
  non-default postprocessing unmeasured.
- `simplify_path`/`simplify_epsilon` interaction (scout: eps=1.0 collapses
  the funnel bend to a 2-point path of length 3.605551 — would break the
  bend witness; not mapped).
- `path_max_distance` (default 5.0), `path_desired_distance`,
  `path_return_max_*`, `path_search_max_*`, `excluded/included_regions`,
  links (`PATH_SEGMENT_TYPE_LINK`), multi-region maps, avoidance, baked
  NavigationRegion3D, other engine versions.
- Whether `final` can *ever* move under postprocessing — invariant on 4
  geometries here; structural endpoint exemption inferred, not proven
  generally.
- The `npts_pre=0` ordering fact is measured only for a stationary agent
  after settle; behavior across repaths/motion unmeasured.
- Reach-gate interaction under postprocessing on *blocking* geometry with
  raised `target_desired_distance` (r70 F3 regime) unprobed.

## Draft: lesson entry — `corpus/lessons/r71-navagent-postproc-review.md`

(Proposal; admission pending named non-author replay + parent verdict.
Modeled on `r70-navagent-detour-review.md` convention.)

> # R71 — NavigationAgent3D path_postprocessing: `distance_to_target` is Euclidean-invariant (Godot 4.7.2)
>
> ## Decision and evidence
>
> `path_postprocessing` reshapes the queried path corridor — never the
> scalar. `distance_to_target()` returns the identical Euclidean distance
> to raw `target_position` under every value while the path itself
> provably changes (r70 L-corridor, S=(0.5,0,0.5) → T=(2.5,0,3.5)):
>
> | `path_postprocessing` | `distance_to_target` | `get_next_path_position` | path pts | pathlen | `get_final_position` |
> |---|---|---|---|---|---|
> | 0 CORRIDORFUNNEL (default) | **3.605551** = √13 | (2,0,1) corner | 3 | 4.130649 | (2.5,0,3.5) |
> | 1 EDGECENTERED | **3.605551** | (2,0,0.5) edge midpoint | 4 via (2,0,0.5),(2.5,0,1) | 4.707107 = 1.5+√0.5+2.5 | (2.5,0,3.5) |
> | 2 NONE | **3.605551** | (2,0,0.5) | 4 via (2,0,0.5),(2,0,1) | 4.549510 = 1.5+0.5+√6.5 | (2.5,0,3.5) |
>
> `reachable=true`, `reached`/`finished=false` throughout. The Euclidean
> figure holds even on a **reachable-clamped** arm — off-mesh T=(2.5,0,5)
> gives `reachable=true` with `final=(2.5,0,4)` yet `distance=4.924429`
> = euclid(raw T), not 4.031129 = euclid(final): the referent is the
> authored target under all postprocessing (12/12 arms, 4 geometries —
> critic). `get_final_position` is itself postprocessing-invariant (path
> endpoint = clamped target, structurally exempt); only `next` and the
> intermediate path array/length move.
>
> Discrimination map for future arms: `next` separates {funnel} from
> {edge, none} but cannot separate edge from none on this corridor —
> use `path[2]` position or `pathlen` (gap 0.157597 ≈ 39× tol). A
> single-polygon control is postprocessing-invisible (byte-identical
> rows) — only multi-portal geometry discriminates.
>
> Companion facts (scout/scribe, measured): the `PathPostProcessing`
> enum lives on `NavigationPathQueryParameters3D` —
> `NavigationAgent3D.PATH_POSTPROCESSING_*` is a parse error (the class
> carries no enums). `agent.path_postprocessing` = plain int property,
> default 0. Setting the flag does **not** requery a cached path — set
> before `target_position`, or re-set the target. `map_get_path` takes
> ≤5 args (no params arg); `NavigationServer3D.query_path(qp, qr)` is
> synchronous, fills `NavigationPathQueryResult3D`, and returned
> point-identical paths to the agent under all three values.
> `get_current_navigation_path()` read before the first
> `get_next_path_position()` returns empty (measured `npts_pre=0`, all
> arms) — query `next` first. `simplify_path` collapses the bend witness
> at eps≥~1.0.
>
> Fixture: `navagent3d_detour.gd` arms `--post-edgecentered` /
> `--post-none` (CASES `navagent3d_detour_post_*`, exit 0, sha `5b873cd0…`,
> runner `b4b31499…`). Each arm classifies distance (euclidean /
> path_sum / bounded-unknown), fails exit 1 with `invariance falsified`
> on a changed distance, and pins `path.size()==4` + `next=(2,0,0.5)` +
> per-arm pathlen so a flag that did not take effect cannot pass.
> Mutation evidence (simplifier): setter-swap, setter-deletion,
> constant-swap and `distance:=pathlen` mutants all exit 1 on measured
> diagnostics. Battery 90/90 + 4 probes, `seeds_unchanged=true`;
> prior 88 rows byte-identical vs frozen baseline.
>
> Receipts: `corpus/live/r71-author/runs/20261013T233731295600Z/`
> (90/90), `corpus/live/r71-baseline/runs/20261013T233444776454Z/`
> (frozen 88/88), `corpus/live/r71-scribe/runs/20261013T234701309638844Z/`
> (independent agent+server sweep, 5-arm fixture replay), seat reports
> `reports/round-71/r71-*.md`; pending `r71-verifier` + adjudication.
>
> ## Not established
>
> Non-default `path_metadata_flags`; moving agent / mid-path retarget /
> repath windows under postprocessing; `simplify_path` mapping;
> `path_max_distance`, `path_desired_distance`, `path_return_max_*`,
> `path_search_max_*`, region filter RID arrays, links, multi-region
> maps; whether `final` can ever move under postprocessing; reach-gate
> behavior under blocking geometry + raised `target_desired_distance`;
> other engine builds, baked region meshes, avoidance, rendering.

## Draft: LOG.md round-71 entry

(Modeled on the r70 entry; bracketed slots await verifier/parent receipts.)

    ## Round 71 — devin host — depth: NavAgent3D path_postprocessing invariance of distance_to_target

    - Declared (dispatch brief): resolve whether `path_postprocessing`
      changes r70's Euclidean `distance_to_target` — claim {edgecentered(1),
      none(2)} leaves distance Euclidean-invariant while changing
      `get_next_path_position`/`get_final_position`; reuse
      `navagent3d_detour.gd` L-corridor with postprocessing arms; any
      measured distance change falsifies invariance. Prior 88 rows +
      4 probes + Node 31/31 byte-stable; non-author replay required.
    - Wave: 7-seat devin leaf set `reports/round-71/r71-{baseline,scout,
      author,reviewer,critic,simplifier,scribe}.md`, disjoint scratch,
      sole tracked writer = author.
    - Baseline: frozen `git archive HEAD` `9458c18` replay → 88/88 + 4
      probes, `seeds_unchanged=true`, Node 31/31 (receipt
      `corpus/live/r71-baseline/runs/20261013T233444776454Z/verdicts.json`).
    - Author `reports/round-71/r71-author.md`: additive +45-line fixture
      amendment (sha `669c539d…`→`5b873cd0…`, `--post-edgecentered` /
      `--post-none` arms) + two CASES rows (runner `5a7d6c13…`→`b4b31499…`).
      Full battery 90/90 (45/45) + 4 probes, `seeds_unchanged=true`
      (receipt `…/r71-author/runs/20261013T233731295600Z/verdicts.json`);
      Node 31/31.
    - Result — claim CONFIRMED with one narrowing: `distance_to_target`=
      3.605551 = √13 under corridorfunnel/edgecentered/none while the
      queried path measurably changes (npts 3→4, next (2,0,1)→(2,0,0.5),
      pathlen 4.130649/4.707107/4.549510; hand-derived 1.5+√0.5+2.5 and
      1.5+0.5+√6.5). `get_final_position` measured postprocessing-INVARIANT
      on all arms — the claim's final clause falsified-and-corrected in
      the record (author pins final unchanged). Convergent independent
      probes: critic 12 arms/4 geometries incl. reachable-clamped
      T=(2.5,0,5) cell (distance keys raw T, not clamped final); scribe
      agent+`query_path` server parity; simplifier sweep + 4 mutants all
      exit-1 on measured diagnostics; scout API map (enum lives on
      `NavigationPathQueryParameters3D`; flag-before-target ordering;
      edge-vs-none separable only by path[2]/pathlen; `simplify_path`
      destroys the witness at eps 1.0). New measured fact (scribe):
      `get_current_navigation_path()` is empty before the first
      `get_next_path_position()` on all arms.
    - Reviewer (r70 audit): AGREE all claims; caught live
      `seeds_unchanged=false` when author's mid-run edits landed —
      drift guard verified working; archive-isolated replay clean 88/88.
    - [verifier: named non-author replay receipt pending]
    - Per-axis verdicts (parent, on named non-author replay): **depth
      improved [pending]** — r70's non-default-postprocessing caveat
      resolved: `distance_to_target` Euclidean-invariant under all three
      values with falsification path live (exit-1 `invariance falsified`);
      **coverage improved locally [pending]** — 88→90 rows, additive only;
      **calibration unchanged** — same exit/marker/seed contract, plus
      two new measured discipline facts (flag ordering, path-read
      ordering). UNKNOWNs retained: non-default `path_metadata_flags`,
      moving-agent/repath semantics, `simplify_path` mapping, reach gates
      under blocking geometry, other builds/engines. Admit pending: one
      improved, none harmed, requires verifier replay.

## Gates / discipline check

- Leaf member: no subagent dispatch; no git write op run (no commit/push/
  merge/rebase/stash/checkout). `git status` shows only the author's
  in-flight `M` on the two fixture files plus untracked `reports/round-71/`.
- Writes confined to `reports/round-71/r71-scribe.md` and
  `corpus/live/r71-scribe/runs/20261013T234701309638844Z/` (scratch project
  copy of `project.godot` + working-tree `navagent3d_detour.gd` +
  `pp_semantics_probe.gd` + 16 receipt files). Seeds, runner, LOG.md,
  SCORECARD.md, knowledge files untouched.
- No battery rerun in tracked scope, no sibling scope written (all
  sibling `corpus/live/r71-*` dirs read-only to me). Falsified-claim
  discipline: the claim's `get_final_position` clause measured false and
  is reported as such, not forced.

## Out-of-scope items

- Verdict/admission — parent judge on named non-author replay (verifier
  seat not yet landed at report time).
- Committing the author's working-tree diff and the LOG/SCORECARD/lesson
  landings — parent integrates after the wave settles.
- Domain-facing actions — operator-owned; none taken.

## Findings summary

1. `distance_to_target` is Euclidean-invariant under all three
   `path_postprocessing` values — 3.605551 on the L-corridor — while the
   queried path provably changes (next, npts, pathlen). Declared
   invariance CONFIRMED by five independent probes.
2. `get_final_position` does NOT move under postprocessing (12/12 critic
   arms + scribe's 6) — claim narrowed honestly in the landed fixture.
3. Edgecentered and none are indistinguishable via `next` alone on this
   geometry; per-arm `pathlen` (or `path[2]`) is the load-bearing pin.
4. New call-order fact: `get_current_navigation_path()` returns empty
   before the first `get_next_path_position()` (`npts_pre=0`, all arms).
5. Server `query_path` with `NavigationPathQueryParameters3D` reproduces
   agent paths point-for-point under every value (independent of scout).
6. Author battery 90/90 + 4 probes `seeds_unchanged=true`; frozen
   baseline 88/88; reviewer incident proves the seed-drift guard live-fires.

## Artifact paths

- This report: `.shokunin/game-dev-3d/reports/round-71/r71-scribe.md`
- Probe + receipts: `.shokunin/game-dev-3d/corpus/live/r71-scribe/runs/20261013T234701309638844Z/`
  (`scratch/{project.godot,pp_semantics_probe.gd,navagent3d_detour.gd}`,
  `probe-output.txt`, `probe-output-rerun.txt`, `probe-stderr*.txt`,
  `fixture-{default,post-edgecentered,post-none,straight,assert-pathsum}.{out,err}`,
  `sha256.txt`)
- Cited read-only: `corpus/live/r71-author/runs/20261013T233731295600Z/verdicts.json`,
  `corpus/live/r71-baseline/runs/20261013T233444776454Z/verdicts.json`,
  `corpus/live/r71-simplifier/proj/pp{,_straight}.out`,
  `corpus/live/r71-simplifier/runs/20261013T233854937978Z/verdicts.json`,
  `corpus/fixtures/{navagent3d_detour.gd,run_battery.py}` (working tree),
  `reports/round-71/r71-{baseline,scout,author,reviewer,critic,simplifier}.md`,
  `corpus/lessons/r70-navagent-detour-review.md`
