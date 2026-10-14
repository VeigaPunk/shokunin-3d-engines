# Game-dev-3d round 72 — scribe report (seat: scribe, host: devin)

Declared lane axis-move (from dispatch): **depth** — formalize the
`path_desired_distance` (pdd) waypoint-pop semantics and the two-mode
`is_navigation_finished` the r71 boundary seat measured. Declared claim:
pin the pdd pop-point index vs agent position as tracked arms on the
L-corridor (agent at known offsets sweeps which path index next-path
returns under increasing pdd), plus the two `is_navigation_finished`
modes with equality-edge cases (euclid exactly == tdd reachable vs
unreachable); additive arms on `navagent3d_detour.gd` + CASES rows;
prior 90 rows field-stable. Scribe duty: draft the lesson entry
(`corpus/lessons/` convention) plus the LOG.md round-72 entry —
report-only; not the judge.

## Measured evidence (scribe-observed, scratch scope)

Independent probe
`corpus/live/r72-scribe/scratch/pdd_finish_probe.gd` (sha256
`da4360a65b0dc521e4665c95862bb0cc9c16d30f8e0cebc1e1d48fa1052cfd3d`) — own
implementation, r70 L-corridor verbatim geometry (A1 x[0,2]z[0,1], A2
x[2,3]z[0,1], B x[2,3]z[1,4]), verbatim `project.godot` copy (sha256
`1fda90d4…`, byte-identical to `corpus/fixtures/project.godot`).
Two-phase protocol: phase A = 30-frame settle + first forcing
`get_next_path_position`; phase B = optional live mutation
(`--pdd-eq-*`, `--tdd-eq=*`, `--teleport=x,z`) + 3-frame settle +
re-query. Command:

    cd corpus/live/r72-scribe
    timeout 60 /usr/bin/godot --headless --path scratch \
      --script res://pdd_finish_probe.gd -- <flags>

Godot `4.7.2.stable.arch_linux.ed1daf0bf` (same build as r69–r71),
cell_size 0.25, stationary or teleported agent. 29 probe arms × 2 PROBE
lines (58 lines), all exit 0, all stderr banner-only (verified `grep -v`
across all receipts), determinism spot-check (`gap2_pdd3.0` rerun
byte-identical).
Receipts `corpus/live/r72-scribe/runs/<arm>.{stdout.txt,stderr.txt,exit}`.

### Pop gate: Euclidean to the LIVE agent position, strict `<`, saturating

| arm | pdd | phase | agent | idx | next | reading |
|---|---|---|---|---|---|---|
| det_pdd0.5 | 0.5 | B | S | 1 | (2,0,1) | euclid(S→path[1])=1.581139 > pdd, no pop |
| det_pdd1.581 | 1.581 | B | S | 1 | (2,0,1) | below printed edge, no pop |
| det_pddeq_wp1 | :=1.581138849 | B | S | **1** | (2,0,1) | **engine-float equality → NO pop → strict `<`** |
| det_pdd1.58114 | 1.58114 | A | S | 2 | final | literal above √2.5 pops — resolves r71-boundary's "inclusive-ish" note |
| det_pdd1.6 / 5.0 | 1.6 / 5.0 | A | S | 2 | final | saturates at `size−1`; finished=false on reachable target even at pdd 5.0 |
| det_tel_nearwp | 0.5 | B | (2,0,0.8) | 1→**2** | final | teleport 0.2 from path[1] pops on the FIXED stored path — position is live |
| det_tel_nearfinal | 0.5 | B | (2.4,0,3.0) | **1** | **(2,0,1)** | 0.51 from raw T yet next still returns the corner — the pop chain cannot skip path[1] (2.04 > pdd) |
| det_tel_nearfinal_p3 | 3.0 | B | (2.4,0,3.0) | 2 | final | same position, larger pdd pops through |
| gap2_pdd2.0 | 2.0 | B | S | **3** | (2,0,3) | path[2]=(2,0,1) is euclid 1.581139 but path-sum 2.581139 from S — pops → **Euclidean, not path-sum** |
| gap2_pdd1.55 / 1.59 | 1.55 / 1.59 | A | S | 1 / **3** | (2,0,0) / (2,0,3) | both mid-waypoints sit at euclid √2.5 — one pdd step jumps idx 1→3 (multi-pop per update) |

### `is_navigation_finished`: two firing clauses, both strict

| arm | setup | reachable | reached | finished | reading |
|---|---|---|---|---|---|
| det_tddeq_target | tdd:=3.605551243 (euclid S→T exactly) | t | f | **f** | **reachable-mode clause strict `<` at float equality** |
| det_tdd3.6055 / 3.6056 | tdd just below/above √13 | t | f→**t** | f→**t** | bracket |
| det_tel_nearfinal | agent 0.51 from T, idx=1 | t | t | **t** | reachable clause ignores the pop index entirely |
| gap2_pdd2.9 | pdd 2.9 < euclid→final 2.915476 | f | f | f | below unreachable edge |
| gap2_pddeq_final | pdd:=2.915475845 (euclid S→final exactly) | f | f | **f** | **unreachable-mode clause strict `<` at float equality** — refines r71-boundary `<= ~pdd` |
| gap2_pdd3.0 | pdd 3.0 | f | f | **t** | unreachable finish fires (3.0 < pathlen 4.581139 — path-sum basis also falsified for the finish referent) |
| gap2_tel_nearfinal | teleport 0.1 from final, pdd 0.5 | f | f | **f** | **idx stays 1 — sitting on the final does not finish**; the pop chain must arrive at `size−1` |
| gap2_tel_nearfinal_p3.5 | same teleport, pdd 3.5 | f | f | **t** | chain pops 1→3 (2.9,1.9,0.1 all < 3.5) then final-within-pdd fires |
| gap2_tel_neartarget | teleport 0.1 from raw T | **f** | **t** | **t** | target-proximity clause fires on an UNREACHABLE target — reached ignores reachability |
| gap2_tddeq_gap | tdd:=1.5 = euclid(final→T) exactly | **t** | f | f | **`is_target_reachable` is INCLUSIVE at equality**; finished now defers to the strict reached clause |
| gap2_tddeq_target | tdd:=2.5 = euclid(S→T) exactly | t | **f** | f | reached strict at equality on the gap geometry too |
| gap2_tdd2.51 | tdd 2.51 > euclid 2.5 | t | t | t | through-wall fire reproduced (agent→T inside tdd while final stays 1.5 away) |
| det_tel_offpath | teleport off-mesh (0.5,2.0), pdd 0.5 | t | f | f | off-path position doesn't repath or pop (dist→path[1] 1.80 > pdd); `reachable` is target-side only |

### Author-fixture verbatim replay (field check, uncommitted working tree)

Working-tree `navagent3d_detour.gd` (sha `ea722a75…`, +297/−1) copied
into scribe scratch; all **22 new `--arm=` CASES rows replayed: exit 0 +
PASS marker byte-identical to the runner literal + empty stderr, 22/22**
(receipts `runs/arm_*.{stdout.txt,stderr.txt,exit}`; comparison strips
the `Godot Engine …` stdout banner the battery runner also filters).
Runner sha `4e9ead37…` (+44/−0). The author's pinned constants
reproduce exactly on a second machine-side process — including the
non-monotone `edge_*` sawtooth (finished T→F→T as tdd crosses the
inclusive reachable boundary at 1.5) and `fin_idx_gate` (agent ON the
clamped final, idx never arrives → finished=false).

### Source-level corroboration (documentation read — data, not measured evidence)

`godotengine/godot` master `scene/3d/navigation/navigation_agent_3d.cpp`
`NavigationAgent3D::_update_navigation`/`_advance_waypoints` matches the
measured table clause-for-clause: pop loop
`while (euclid(origin, path[idx]) < pdd)` (strict) with
`_is_last_waypoint()` → `last_waypoint_reached` and break (the index
never exceeds `size−1`; the last point is *marked reached* only when the
loop arrives AND finds it within pdd — the source of the observed
idx-gate conjunct); `_is_within_target_distance` =
`euclid(origin, target_position) < tdd` (strict, checked FIRST —
unconditional on reachability, then advances waypoints and latches
`target_reached`/`navigation_finished`); `_is_target_reachable` =
`tdd >= euclid(final, target)` (inclusive); `navigation_finished` is
latched (early-return once set) and cleared only by `_request_repath`
(target re-submit or map change). Also source-visible, unmeasured here:
repath triggers when the agent's distance to the segment
`path[idx−1]→path[idx]` reaches `path_max_distance` (5.0 default) — my
teleports stayed <3.0 from the current segment and never repathed
(stored path byte-identical in every teleport arm, printed per run).
Master is not the 4.7.2 binary; cited as mechanism narrative consistent
with measurement, not as evidence.

## Refined measured model (all gates, this build)

```
pop:       while idx < size−1 and euclid(agent, path[idx]) < pdd: idx++
           — STRICT < (exact float equality does NOT pop), monotone,
             sequential (cannot skip a beyond-pdd waypoint), keyed on the
             LIVE agent position against the FIXED stored path
reached:   euclid(agent, raw target) < tdd
           — STRICT; ignores reachability (fires adjacent to off-mesh
             targets / through walls); latched once true
reachable: euclid(clamped final, raw target) <= tdd
           — INCLUSIVE at equality; agent-position independent;
             re-evaluated per call
finished:  reached OR (NOT reachable AND pop chain saturated at
             idx == size−1 AND euclid(agent, clamped final) < pdd)
           — both sub-gates STRICT; latched once true. Corollaries:
             reachable mode is pdd-immune (saturated idx + final inside
             pdd still not finished); unreachable mode requires the pop
             chain to ARRIVE at the last index — proximity to the final
             without the index is insufficient.
```

## Wave state at observation time

- Sibling reports present: `r72-{baseline,scout,reviewer,author}.md`;
  critic/boundary/simplifier scratch dirs populated but reports not
  landed; verifier/adjudicator pending — LOG draft marks those slots.
- Baseline (frozen `git archive HEAD` at `996ea37`): **90/90 + 4 probes +
  Node 31/31**, `seeds_unchanged=true`, receipt
  `corpus/live/r72-baseline/runs/20261014T003555854844Z/verdicts.json`.
- Author battery receipts (independently field-checked by scribe):
  focused 27/27 (`runs/20261014T004610248553Z/verdicts.json`) and full
  **112/112** (67 ordinary / 45 negative) + 4 probes,
  `seeds_unchanged=true`, godot `4.7.2.stable.arch_linux.ed1daf0bf`
  (`runs/20261014T004642048951Z/verdicts.json`). Author reports 0
  mismatches over the prior 90 rows × 12 fields vs the r71 receipt;
  seed map 52→52 (only the two fixture digests changed). Node 31/31.
- Scout: 43-arm scratch matrix, same strictness conclusions, plus the
  (2.083333,0,1) funnel-interior observation and the t2 clamp-tie
  witness (`final=(0.5,0,1.0)` on a 1.5/1.5 tie toward the containing
  polygon).
- Reviewer: r71 audit — AGREE all 10 claim families, byte-exact arms,
  90/90 replay, seed/sha checks clean.
- Tracked writes (author only, uncommitted at observation):
  `M corpus/fixtures/navagent3d_detour.gd` (`5b873cd0…` → `ea722a75…`),
  `M corpus/fixtures/run_battery.py` (`b4b31499…` → `4e9ead37…`).

## Convergence — and one verbatim refinement for the judge

Author, scout, and this scribe probe converge on every gate clause:
strict pop, saturation, live-position keying, Euclidean basis,
strict/inclusive asymmetry, latching, through-wall `reached`. Two
refinements against earlier records, reported verbatim:

1. **Scout's headline formula omits the index conjunct.** Scout reports
   `finished = (euclid(agent→T) < tdd) OR (reachable==false AND
   euclid(agent→final) < pdd)`. That form predicts `finished=true` for
   my `gap2_tel_nearfinal` arm (reachable=false, euclid(agent→final)=0.1
   < pdd=0.5) — measured **false** (idx stayed 1). The measured-correct
   unreachable clause additionally requires the pop chain saturated at
   `size−1` — exactly the author's landed formulation
   (`reached OR (NOT reachable AND idx == size−1 AND euclid(agent, clamped
   final) < pdd)`) and its `fin_idx_gate` pin. Scout's own data never
   separates the conjuncts (all its unreachable arms saturate at spawn);
   the correction is additive, not a contradiction of scout's numbers.
2. **r71-boundary's `<= ~pdd` is strict `<`.** Both at engine-float
   equality (my `gap2_pddeq_final`, author's `vert_fin_eq` at exact 3.0)
   the unreachable finish gate does not fire; `pdd+0.01` does.
   Boundary's earlier `pdd=1.581139` pop was literal-vs-irrational float
   rounding (√2.5 = 1.58113883… < parsed 1.581139), consistent with a
   strict gate — scout's reading confirmed by my exact-float arm.

No other conflicts observed; no seat touched another's scope.

## Retained UNKNOWNs (do not claim)

- `path_metadata_flags` companion arrays under behavior — r71-boundary
  mapped types/rids/owner_ids as descriptive per-point annotation
  (uniform REGION, 1:1 alignment, postprocessing-invariant), but
  restricted bitmasks' effect on `waypoint_reached` signal payloads and
  any LINK-segment (`PATH_SEGMENT_TYPE_LINK`) behavior need an authored
  NavigationLink3D — none exists in the corpus.
- Moving-agent dynamics: teleports ≠ locomotion. Per-frame re-pop under
  real CharacterBody motion, `waypoint_reached`/`link_reached`/
  `target_reached`/`navigation_finished` signal emission cadence,
  repath triggering via `path_max_distance` (agent drift ≥5.0 from the
  current segment — teleports here stayed <3.0), `path_height_offset`,
  avoidance, and mid-path map updates are unprobed.
- Latch release conditions (retarget vs map change), `is_target_reachable`
  flip-back caching, and whether the unreachable finish referent is
  `get_final_position()` vs `path[size−1]` (identical on every arm here)
  are unprobed.
- Float-adjacent edges: strictness is pinned at exactly-representable
  constants (1.0/1.5/2.0/2.5/3.0) and at engine-float equality; ULP-
  adjacent pdd around irrational distances is recorded not pinned
  (author's note: 1.5811388/1.5811389 both round to √2.5 in single
  precision).
- Scope: one build (4.7.2.stable.arch_linux), one host, single region,
  cell_size 0.25, corridorfunnel on the pop arms, 30-frame settle. No
  baked NavigationRegion3D, multi-region map, avoidance, rendering, or
  cross-engine inference. r68/r69 `navagent3d_retarget` intermittence
  did not manifest; caveat stands unretracted.

## Draft: lesson entry — `corpus/lessons/r72-navagent-pdd-finish-review.md`

(Proposal; admission pending named non-author replay + parent verdict.
Modeled on `r71-navagent-postproc-review.md` convention.)

> # R72 — NavigationAgent3D pdd waypoint-pop + two-mode is_navigation_finished (Godot 4.7.2)
>
> ## Decision and evidence
>
> `path_desired_distance` (pdd) drives a **sequential Euclidean pop loop
> keyed on the live agent position**: each navigation update advances the
> path index while `idx < size−1` and `euclid(agent, path[idx]) < pdd` —
> strict `<` (an exact equality does NOT pop), saturating at the last
> index so `get_next_path_position` converges to `path[size−1]`. The
> basis is Euclidean to the agent, discriminated against path-sum on the
> gap2 dogleg (path[2]=(2,0,1) at euclid 1.581139 but 2.581139 routed;
> pdd=2.0 pops it, idx→3). Position-keying is live: a post-settle
> teleport re-pops on the **fixed stored path** (idx 1→2 at 0.2-away;
> idx 1→3 under pdd 3.5), and the chain cannot skip — teleporting next
> to the final leaves `next` pointing at a still-unevaluated mid
> waypoint. Pops are monotone and multi-per-update (pdd 1.59 jumps idx
> 1→3 through two equidistant √2.5 waypoints).
>
> `is_navigation_finished` resolves into an OR of two strict clauses:
>
> | gate | formula | strictness | evidence |
> |---|---|---|---|
> | `is_target_reached` | `euclid(agent, raw target) < tdd` | **strict**; ignores reachability (fires through walls / on off-mesh targets); latched | tdd=3.605551 at exactly √13 → false; 3.6056 → true; teleport 0.5 from off-mesh T → reached+finished while reachable=false |
> | `is_target_reachable` | `euclid(clamped final, raw target) <= tdd` | **inclusive** at equality; agent-independent | euclid(final→T)=1.5 == tdd=1.5 → reachable=true; 1.4 → false |
> | `is_navigation_finished` | `reached OR (NOT reachable AND idx==size−1 AND euclid(agent, clamped final) < pdd)` | both sub-gates **strict**; latched | pdd=2.915476 at exactly euclid→final → false; 3.0 → true; agent ON the final with idx=1 → false (index must arrive) |
>
> Corollaries pinned by arms: reachable mode is **pdd-immune** (pdd=5.0
> saturates the index yet finished=false at tdd=1.0 on a reachable
> target); unreachable mode requires the pop chain to *arrive* at the
> last index (proximity alone insufficient); `finished` is **non-monotone
> in tdd** — on a degenerate spawn-on-clamp path, tdd 1.4 → true
> (idx+pdd clause), 1.5 → false (reachable flips inclusive on, strict
> reached fails at equality), 1.6 → true. Engine-side truth, consistent
> with master `navigation_agent_3d.cpp`: the tdd clause is evaluated
> first and unconditionally, the pdd clause only when unreachable, and
> `navigation_finished` latches until a repath.
>
> Fixture: `navagent3d_detour.gd` gains `--arm=<name>` presets (22 CASES
> rows, all exit 0, expectations authored inside `_arm_cfg` — a row
> cannot tune itself; any tuple mismatch exits 1 with a named
> diagnostic). Arms cover pop sweeps (`pop_lo/hi/sat`), position-keying
> (`mid_lo/hi`, `tp_mid/tp_eq`), basis discrimination (`gap2_pop_basis`),
> strict pop equality at exact 1.0 (`vert_pop_eq/above`), unreachable
> finish edges (`fin_unr_lo/hi`, `vert_fin_eq/above` at exact 3.0),
> reachable-finish equality (`fin_reach_eq/above` at exact 2.5), the
> selector sawtooth (`edge_unr/eq/above`), index-gate (`fin_idx_gate`),
> through-wall (`fin_wall`), and latch (`fin_latch`). Battery 112/112 +
> 4 probes, `seeds_unchanged=true`, prior 90 rows byte-identical; scribe
> independently replayed all 22 markers byte-exact.
>
> Receipts: `corpus/live/r72-author/runs/20261014T004642048951Z/` (112/112)
> + `…/20261014T004610248553Z/` (27/27 focused),
> `corpus/live/r72-baseline/runs/20261014T003555854844Z/` (frozen 90/90),
> `corpus/live/r72-scribe/runs/` (29-arm independent probe + 22-arm
> verbatim replay), `corpus/live/r72-scout/runs/` (43-arm edge matrix);
> seat reports `reports/round-72/r72-*.md`; pending `r72-verifier` +
> adjudication.
>
> ## Not established
>
> `path_metadata_flags` behavioral role (LINK segments, restricted
> bitmasks, signal payloads); moving-agent dynamics — real locomotion
> re-pop cadence, signal emission, `path_max_distance` repath triggers,
> `path_height_offset`, avoidance, mid-path map updates; latch release
> conditions; `reachable` flip-back caching; final-vs-`path[size−1]`
> referent separation; ULP-adjacent float edges; other engine builds,
> baked regions, multi-region maps, rendering.

## Draft: LOG.md round-72 entry

(Modeled on the r71 entry; bracketed slots await critic/boundary/
simplifier/verifier/parent receipts.)

    ## Round 72 — devin host — depth: NavAgent3D path_desired_distance pop semantics + two-mode is_navigation_finished

    - Declared (dispatch brief): formalize the r71-boundary recon — pin pdd
      waypoint-pop index vs agent position on the L-corridor (spawn offsets /
      teleports sweeping the index under increasing pdd) plus the two
      is_navigation_finished modes with equality-edge cases (euclid exactly
      == tdd reachable vs unreachable). Additive `--arm=` rows on
      navagent3d_detour.gd + CASES; prior 90 rows field-stable; non-author
      replay required.
    - Wave: devin leaf set `reports/round-72/r72-{baseline,scout,author,
      critic,reviewer,simplifier,boundary,scribe}.md`, disjoint scratch,
      sole tracked writer = author. [critic/boundary/simplifier pending]
    - Baseline: frozen `git archive HEAD` `996ea37` replay → 90/90 + 4
      probes + Node 31/31, `seeds_unchanged=true` (receipt
      `corpus/live/r72-baseline/runs/20261014T003555854844Z/verdicts.json`).
    - Author `reports/round-72/r72-author.md`: additive +297/−1 fixture
      amendment (`5b873cd0…`→`ea722a75…`, `--arm=<name>` presets with
      authored expectations) + 22 CASES rows (`b4b31499…`→`4e9ead37…`).
      Focused 27/27 + full battery **112/112** (67 ordinary / 45 negative)
      + 4 probes, `seeds_unchanged=true`; prior 90 rows 0-mismatch vs r71
      receipt; Node 31/31.
    - Result — claim CONFIRMED and sharpened: pop is Euclidean to the LIVE
      agent position on the fixed stored path, strict `<` (exact-float
      equality does not pop; resolves r71-boundary's inclusive-ish note),
      sequential (no skipping), saturating at `size−1`.
      `is_navigation_finished` = `reached OR (unreachable AND
      idx==size−1 AND euclid(agent, clamped final) < pdd)` — both strict,
      latched; `is_target_reached` strict and reachability-blind
      (through-wall fire reproduced on an unreachable target);
      `is_target_reachable` inclusive at equality. `finished` measured
      non-monotone in tdd (T,F,T across the reachable selector at the
      1.5 equality edge). Convergent: scout 43-arm matrix (same strictness
      conclusions + funnel-interior waypoint + clamp-tie witness); scribe
      29-arm independent probe reproducing every clause including the
      index-arrival requirement (agent on the final without pop saturation
      does not finish — a conjunct scout's headline formula omits; author's
      formulation carries it); master-source corroboration recorded as
      mechanism narrative. Reviewer r71 audit: AGREE all claims.
    - [critic/boundary/simplifier slots pending]
    - [verifier: named non-author replay receipt pending]
    - Per-axis verdicts (parent, on named non-author replay): **depth
      improved [pending]** — pdd/finish contract formalized with live
      falsification paths on all clauses incl. three exact-equality pins;
      **coverage improved locally [pending]** — 90→112 rows, first
      agent-move arms (teleports) and off-mesh unreachable paths;
      **calibration unchanged** — same exit/marker/seed discipline.
      UNKNOWNs retained: metadata-flag behavior, moving-agent dynamics,
      latch release, other builds/engines. Admit pending: one improved,
      none harmed, requires verifier replay.

## Gates / discipline check

- Leaf member: no subagent dispatch; no git write op run (no commit/push/
  merge/rebase/stash/checkout). `git status` shows only the author's
  in-flight `M` on the two fixture files plus untracked `reports/round-72/`.
- Writes confined to `reports/round-72/r72-scribe.md` and
  `corpus/live/r72-scribe/` (scratch `project.godot` copy +
  `pdd_finish_probe.gd` + working-tree fixture copy + 154 receipt files
  under `runs/`). Seeds, runner, LOG.md, SCORECARD.md, lesson files
  untouched — the lesson and LOG entries above are drafts inside this
  report, per dispatch.
- Fixture replay used a copy of the author's uncommitted working-tree
  file in my own scratch project — no battery rerun in tracked scope, no
  sibling scope written.
- Artifact-content discipline: the author/scout/source-code readings
  above are cited as data; every gate clause in the refined model was
  independently measured in my own probe (29 arms) or replayed verbatim
  (22 fixture arms). The one disagreement found (scout's formula missing
  the index conjunct) is reported verbatim for the judge, not smoothed.

## Out-of-scope items

- Verdict/admission — parent judge on named non-author replay (verifier
  seat not yet landed at report time).
- Committing the author's working-tree diff and landing LOG/SCORECARD/
  lesson entries — parent integrates after the wave settles.
- Tracked battery execution — scribe scope is documentation draft plus
  scratch receipts only.
