# Game-dev-3d round 72 — simplifier report (minimal-design critique, report-only)

Seat: simplifier. Judged the landed diff for the r72 depth move —
formalizing `path_desired_distance` (pdd) waypoint-pop semantics and the
two-mode `is_navigation_finished` the r71 boundary seat measured. Simplifier
did not author this round. All probes/mutants ran in own write scope
(`corpus/live/r72-simplifier/`); seeds untouched. Host devin,
`/usr/bin/godot` 4.7.2.stable.arch_linux.ed1daf0bf, physics 60 tps.

Landed diff at critique time (uncommitted when first read; committed as
`05405ae` mid-critique — judged content byte-identical, fixture sha256
`ea722a75…` verified against committed HEAD): `M
corpus/fixtures/navagent3d_detour.gd` +297/-1 (the one deletion is the
setup-pin's `spawn` -> `expected_pos` generalization — identical semantics
for all pre-r72 paths), `M corpus/fixtures/run_battery.py` +44/-0 = 22
CASES tuples, all exit-0 PASS arms selected by `--arm=<name>`. Nothing else
tracked touched. Adjudication `f95a16e` (ADMIT) recorded this seat as
in-flight; this report lands with report-last.

## Independent ground truth (own probe, before reading the diff closely)

`corpus/live/r72-simplifier/proj/pdd_probe.gd` — same L-corridor,
flag-parameterized spawn/target/pdd/tdd, one process per arm, 41 runs, all
exit 0, banner-only stderr (`runs/probe/*.out|err`). Measurements:

- Pop gate is `euclid(agent, path[idx]) < pdd` **STRICT**: literals
  `pdd=1.5811388`/`1.5811389` round to exactly f32(sqrt2.5)=1.5811388493
  (the euclid to (2,0,1)) and do NOT pop (idx stays 1); `1.581139` is one
  ulp above and pops. Resolves r71's "inclusive-ish" — it was sub-ulp float.
- Pop saturates at `idx = size-1` on both geometries (detour pdd=10 ->
  idx=2 of 3; gap2 pdd>=2.0 -> idx=3 of 4); the final point is never
  popped past.
- Pop basis is Euclidean-to-agent, not path-sum: gap2 pdd=2.0 pops the
  dogleg waypoint (2,0,1) (euclid 1.581139 < 2.0 < path-sum 2.581139) ->
  idx=3. A path-sum basis predicts idx=2.
- Spawn-offset arms confirm the agent-position keying: gap2 from
  (1.5,0,0.5) pdd=1.0 -> idx=3 (both bend waypoints inside 1.0).
- `is_navigation_finished`, unreachable mode: `euclid(agent, clamped final)
  < pdd` **STRICT**, measured at an exact-representable edge — my `gapE`
  target (0.9,0,2.5) clamps to final (2,0,2.5) at euclid exactly 2.5:
  `pdd=2.5` -> finished=false, `pdd=2.500001` -> true. f32-level
  corroboration on gap2 (euclid_final=f32 2.9154758453): literals
  2.9154758/9 (f32-equal) -> false; 2.9154760 (one ulp up) -> true.
- Reachable mode: finished follows the reached gate `euclid(agent, raw T)
  < tdd` STRICT (gap2 tdd=2.5 at euclid_t exactly 2.5 -> false; 2.6 ->
  reached=true finished=true — through-wall fire reproduced).
- `is_target_reachable` = `euclid(final, T) <= tdd` INCLUSIVE (gap2
  final->T gap exactly 1.5: reachable=false at tdd=1.4, true at 1.5).
- Selector: gap vs gap2 at pdd=3.0 — identical path/final/pdd, only
  `reachable` differs -> finished false vs true.

Converges exactly with the author's header-comment model:
`finished = reached OR (unreachable AND idx == size-1 AND euclid(agent,
clamped final) < pdd)` — all three distance gates strict, `reachable`
inclusive. (r71 boundary's "<= ~pdd" refined to strict on exact equality.)

## Verdict

**Adequate discrimination everywhere; envelope ~5 rows over strict
minimal — deletion candidates named, none demanded.** Every one of the 22
arms executes, passes, and byte-matches its CASES marker on replay (27/27
focused battery incl. the 5 prior detour rows). Every pinned equality edge
is engineered on exactly-representable constants, not ulp-adjacent
literals. Six scratch mutants all rejected on measured diagnostics. The
over-minimal residue is real but small, and each redundant row still
asserts a measured tuple a wrong model could fail — no dead weight.

## The discrimination lattice and per-arm marginal value

Pop surface (`idx` after `get_next_path_position`):

| cell / mutant killed | pinning arms | marginal note |
|---|---|---|
| below-threshold no-pop on primary geometry | `pop_lo` (pdd 1.5 < 1.581139) | load-bearing |
| ordinary pop transition (stops at last because euclid>pdd) | `pop_hi` (pdd 2.0) | justified — distinct stop mechanism from saturation |
| saturation at size-1 + **reachable-mode pdd-immunity** (idx-last AND euclid_final<pdd yet finished=false) | `pop_sat` (pdd 5.0) | load-bearing, double duty |
| **Euclidean vs path-sum pop basis** | `gap2_pop_basis` (pdd 2.0 -> idx 3; path-sum predicts 2) | the claim's core discriminator |
| **strict pop at exact euclid==pdd** | `vert_pop_eq`/`vert_pop_above` (spawn (2,0,0): euclid to (2,0,1) exactly 1.0; pdd 1.0 no-pop, 1.01 pop) | load-bearing pair — the elegant move: spawn geometry makes the edge exactly representable |
| **live agent position on FIXED stored path** | `tp_mid` (teleport (1.6,0,0.6): re-pops to idx 2; kills spawn-frozen and path[0]-keyed models) | load-bearing — spawn position cannot explain a post-settle re-pop |
| strict pop on live (post-teleport) position | `tp_eq` (teleport to exactly 1.0 from (2,0,1): no pop) | **redundant-ish** — strictness already pinned by `vert_pop_eq`; kills only an exotic position-source-dependent-strictness model |
| pop threshold moves with agent offset | `mid_lo`/`mid_hi` (spawn (1.5,0,0.5): euclid 0.707; pdd 0.7/1.0 -> no-pop/pop) | **redundant** — subsumed by `tp_mid` (same predicate, stronger: live position, fixed path). Their sole defense is being the claim's literal "agent at known offsets" |

Finish surface (`finished` truth-table cells):

| cell | pinning arms | marginal note |
|---|---|---|
| reachable AND euclid_t<tdd -> T | `fin_reach_above` (tdd 2.6), `edge_above` (1.6), `fin_latch`(pre) | triple-covered; `fin_reach_above` is the primary |
| reachable AND euclid_t>=tdd -> F | every reachable arm; **equality** by `fin_reach_eq` (tdd 2.5 == euclid_t exact) | load-bearing edge |
| unreachable AND idx-last AND euclid_f<pdd -> T | `fin_unr_hi` (3.0 > 2.915476, < pathlen 4.581139 — falsifies path-sum finish basis), `vert_fin_above` (3.01), `edge_unr` | load-bearing |
| unreachable AND idx-last AND NOT(euclid_f<pdd) -> F | `fin_unr_lo` (2.9), `gap2_pop_basis` (2.0, doubles), `vert_fin_eq` (pdd 3.0 == euclid_final 3.0 exact — the decisive strict edge) | `fin_unr_lo` only narrows the bracket; `gap2_pop_basis` already kills "idx-last suffices" at 2.0 — **borderline** |
| **unreachable AND NOT idx-last despite euclid_f<pdd** -> F | `fin_idx_gate` (teleport ONTO final: euclid_f=0<pdd but idx stuck 1 — also proves pops cannot skip ahead sequentially) | unique cell, load-bearing |
| **unreachable AND reached through wall** -> T | `fin_wall` (teleport to euclid 0.5 < tdd of raw T) | unique cell — kills "finished = reachable AND reached" AND-selector model; proves OR-composition |
| mode selector AT inclusive equality | `edge_eq` (tdd 1.5 == gap -> reachable=true, reached/finished false) paired with `edge_unr` (tdd 1.4 -> unreachable, finished=true) | the non-monotone T->F signature — load-bearing pair |
| finished F->T recovery after the flip | `edge_above` (tdd 1.6) | **borderline** — cell duplicates `fin_reach_above`; completes the T,F,T narrative |
| latch: flags persist after leaving all gates | `fin_latch` (teleport back out: reached/finished stay true at dist 2.5 > tdd) | **scope-extra** — latch is not in the declared claim, but is a newly measured semantic of the same gates; harmless expansion, one row |

Net: ~16 load-bearing + `pop_hi` justified = 17; **deletion candidates:
`mid_lo`, `mid_hi`** (no unique killed model — `tp_mid` supplies the same
agent-position discrimination strictly stronger), **`tp_eq`** (strictness
doubly pinned), **`fin_unr_lo`** (bracket-tightening only — the
`vert_fin_eq`/`vert_fin_above` exact pair pins the edge, `gap2_pop_basis`
pins below-threshold on the same geometry). **`edge_above`** is the weakest
defensible keep. `fin_latch` is the one arm outside the declared claim —
it costs a row and records a real semantic; author's call, not a demand.

## Adequate discrimination at the equality edges — the strong half of the diff

All four edge pins use exactly-representable constants, so the strictness
claims are measurement-true rather than float-lucky:

- `vert_pop_eq`/`vert_pop_above`: euclid exactly 1.0 via spawn (2,0,0)
  -> pdd 1.0/1.01. My f32 check: 1.0 and 3.0 are exact; margins one full
  centi-unit, far above DIST_TOL/ulp noise.
- `vert_fin_eq`/`vert_fin_above`: euclid(agent->final) exactly 3.0 on the
  same spawn -> the unreachable-mode strict edge.
- `fin_reach_eq`/`fin_reach_above`: euclid_t exactly 2.5 vs tdd 2.5/2.6 ->
  reachable-mode strict edge (and reachable=true, so pdd cannot explain
  the outcome).
- `edge_unr`/`edge_eq`/`edge_above`: gap exactly 1.5 vs tdd 1.4/1.5/1.6 ->
  reachable inclusive + reached strict + selector flip in one triple.

The `path` pin (`want_path` full point-array compare) plus `idx` plus the
three flags means an arm where the knob did not take effect cannot pass —
the "flag ignored" trap is structurally dead. Teleport arms additionally
pin the pre-teleport tuple AND stored-path immutability (a re-querying
pop model fails `pre path moved`).

## Mutation coverage — demonstrated (private scratch mutants, real exits)

Copy `detour-check/base.gd` (sha256 `ea722a75…`, byte-identical to the
landed fixture); each mutant flips one setup constant or one expectation:

| mutant | run | exit | measured diagnostic |
|---|---|---|---|
| m1: `vert_pop_eq` spawn (2,0,0)->(2,0,0.01) (breaks exact-1.0 edge) | `--arm=vert_pop_eq` | **1** | `idx=2 expected=1` — edge arm is measurement-driven, not literal-echo |
| m2: `fin_reach_eq` tdd 2.5->2.6 | `--arm=fin_reach_eq` | **1** | `reached=true finished=true expected …false,false` — strict edge discriminates |
| m3: `fin_unr_hi` pdd 3.0->2.9 (below euclid_final) | `--arm=fin_unr_hi` | **1** | `finished=false expected=…,true` — bracket discriminates |
| m4: `gap2_pop_basis` expected idx 3->2 (expectation tamper) | `--arm=gap2_pop_basis` | **1** | `idx=3 expected=2` — assert layer bites |
| m5: `edge_eq` tdd 1.5->1.4 | `--arm=edge_eq` | **1** | `reachable=false … finished=true expected=true,false,false` — mode flip surfaces in the flags |
| m6: `fin_idx_gate` expected finished false->true | `--arm=fin_idx_gate` | **1** | `finished=false expected=…,true` — the idx-conjunct pin is checked, not decorative |

Six mutants, six failing runs, zero literal-only rejections. Mutation
coverage: adequate.

Determinism: all five teleport arms re-run twice — stdout byte-identical
(`detour-check/rep{1,2}_{tp_mid,tp_eq,fin_idx_gate,fin_wall,fin_latch}.out`);
the 5-frame post-teleport settle is stable on this build.

## Arm replay — exact markers byte-match CASES

    python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
      --runs <abs r72-simplifier>/runs --only <all 5 prior + 22 new detour arms>
    -> totals: cases=27 pass=27 fail=0 (25 ordinary + 2 negative)
    receipt: runs/20261014T005146075346Z/verdicts.json, seeds_unchanged

## Considered-and-rejected smaller expressions

- **In-process sweep arms** (one `--arm=pdd_sweep` setting pdd twice and
  printing both observations): the fixture machinery could do it (states
  are already re-readable), saving ~6 rows, but it couples independent
  fates into one red and breaks the one-scenario-per-row marker
  convention. Not demanded — same shape as r71's rejected sweep arm.
- **Sibling `navagent3d_finish.gd`**: duplicates ~40 lines of
  map/region/mesh setup to isolate the same corridor — larger, rejected
  correctly (r71 precedent).
- **Subtractive row merges** (e.g., folding `mid_*` into `tp_*` —
  literally what the redundancy analysis says): the only real envelope
  win available. ~3-5 rows.

## Nits (cosmetic, non-blocking)

- The 22-arm preset table is the largest documentary+cfg surface in the
  file now; density is fine (~13 lines/arm all-in) and each block carries
  its measured rationale in the comment — consistent with file convention.
- `mid_lo`'s no-pop margin is thin by value (euclid 0.707107 vs pdd 0.7 =
  0.007) — safe over f32 noise, but this row is already the top deletion
  candidate, so moot.
- `vert_*`/`tp_eq` use spawn/teleport point (2,0,0), a polygon corner —
  the engine resolves it deterministically on this build and the `path`
  pin would fail red under a different projection; acceptable, recorded.
- The unused `euclid` local is still computed for arm paths before the
  early `return _run_pop_arm` — dead for arms, harmless.
- `DETOUR_EUCLID` const still unused (carried since r70) — outside this
  diff, author's call.

## Contract preserved

`call_deferred`/`_run` shape, 30-frame settle, exact-match flags plus a
new `_argval` prefix parser (unknown `--arm` exits 1 with a named error —
fail-closed), the setup-pin block generalized by one line
(`expected_pos`), `_fail`/`_cleanup` full-RID teardown, PASS marker
grammar with `%.6f`, one assert engine `_run_pop_arm` shared by all arms.
`git diff` is insertion-only except that one setup-pin generalization; no
prior arm's assertion touched.

## Evidence index

- Independent probe + 30 receipts:
  `corpus/live/r72-simplifier/proj/pdd_probe.gd`, `runs/probe/*.out|.err`
  (incl. f32-equality arms `gap2_p2.915475{8,9}`/…60, `gapE_p2.4-3.0`,
  spawn-offset `s1`-`s8`).
- Mutant sources/outputs/exits: `detour-check/m{1-6}.{gd,out,err}`;
  teleport determinism pairs `detour-check/rep{1,2}_*.out`.
- Focused battery receipt:
  `corpus/live/r72-simplifier/runs/20261014T005146075346Z/verdicts.json`.

## Scope notes

- No full-battery or Node suite run — verifier/baseline scope. My replay
  covers the whole detour family (27 rows); the run_battery diff is
  insertions-only so prior-row drift risk is nil.
- Semantic verdicts are for this build/geometry/host: stationary and
  teleported agents, single region, corridorfunnel, cell_size 0.25. The
  latch pin is single-direction (out of threshold); unlatching/un-setting
  target unprobed and unclaimed.
- Next deletion would remove a truth-table cell or an exercised edge —
  the only slack is the named redundant subset, whose removal loses no
  pinned cell. Stopping.
