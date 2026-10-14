# game-dev-3d round 83 — critic (seat: critic, host: devin)

Wave `shokunin-train-20261101-w14`, lane g3d. Adversarial falsification of the
landed two-tier lattice (`e9145d9`), not a judge, editor, integrator or shipper.
Lane root `~/Projects/shokunin/game-dev-3d-shokunin`, HEAD `e9145d9`, runtime
`/usr/bin/godot` = `4.7.2.stable.arch_linux.ed1daf0bf`, 32 cores, load ~0.9,
every probe wrapped `timeout -s KILL 30`. No git mutation, no subagent, no
fixture edit. Scratch `corpus/live/r83-critic/` (gitignored, `corpus/.gitignore:1`).

**Two counterexamples landed; three attacks tested and rejected.** Both
counterexamples are reproducible from my own probe, not from the author's
receipts: (1) the tick tier's latency is **write-phase-dependent** — the same
event lands one *or* two ticks after its triggering write, so README:573-574
("exactly one tick") is false as stated; (2) the landed `static_nopair`
**rule** is falsified under Jolt on this build (the teleported STATIC body
*does* pair and *does* fire `body_entered`), which contradicts README:585
("same lattice, different solver constants"). The landed DEFAULT battery stays
green (186/186, replayed here) — these are claim-scope and pin-scope defects,
not red cells.

## (0) Replay of the landed diff (the baseline my attacks sit on)

| check | command / receipt | measured |
|---|---|---|
| full battery replay | `python3 corpus/fixtures/run_battery.py --runs …/batt_full` → `batt_full/20261014T170227489416Z/verdicts.json` | **186/186 PASS**, `seeds_unchanged=true`, `verdict=PASS`, wall **196.2 s** |
| the 10 new rows in that replay | `batt_full.log` | all PASS (`static_nopair` exit 2/2 negative) |
| insertion-only claim | `git show e9145d9 --numstat` | `28/0`, `597/0`, `20/0`, `222/0` — **pure insertion, 0 deletions** (prior 176 rows byte-identical) |
| fixture sha | `sha256sum corpus/fixtures/phys3d_events.gd` | `6ddf4aefde97d31673f337699ba1dedbe9e6caf4226917225577a36b8ac4fab3` — matches the author's report |
| phase audit of the fixture | `grep -n 'await process_frame'` | exactly one hit, `:575` (the child's sampling loop) → **every landed write cell runs in the physics-frame phase** |
| backend of the battery | `corpus/fixtures/project.godot` | no `physics/3d/physics_engine` key → `DEFAULT` = GodotPhysics3D |

My probe: `corpus/live/r83-critic/proj_c/crit83b.gd`, sha256
`b9ffaf70aca80f2c914f8460ba80cdd849fb7d0fbe846e53c5da9a51c11b2116`
(identical in `proj_c_thread/`, `proj_c_jolt/`), runner `run_c.sh`
(`ARM PROJ PREFIX REPS`), receipts `runs_b/<prefix>.<rep>.{stdout,stderr,exit}`.
Arms: `phase`, `sphase`, `cphase`, `staticvac`, `dssdist`, `torn`.

## (1) COUNTEREXAMPLE 1 — the tick tier's latency is write-phase-dependent (1 or 2 ticks)

The landed README:573-574 says the generated events "each land **exactly one
tick** after their triggering write", and `contact_sig` (`:376`) hard-asserts
`delta != 1 → _fail`. Measured: the *same* geometric event, in the *same*
script, lands one tick after a write issued inside the physics step and **two
ticks** after the same write issued from the process frame.

| cell (my arm) | write phase | receipt | measured |
|---|---|---|---|
| `Area3D.body_entered`, rigid node teleport into a settled area | p1 `await physics_frame` (before that iteration's `step()`) | `runs_b/phase.1-3`, `phase2.1-2` | `write_pf=4/5 w0_sig=0 n1_sig=1 delta=1` — 5/5 |
| same | p2 `await process_frame` (after that iteration's steps) | same receipts | `write_pf=11/12 w0_sig=0 n3_sig=1 delta=2` — 5/5 |
| server `area_set_monitor_callback` (the author's `srv_area_cb` shape), **server write** | p1 | `runs_b/sphase.1-3` | `log=["0@5"]`, write_pf=4 → **delta 1** |
| same | p2 | same | `log=["0@13"]`, write_pf=11 → **delta 2** |
| contact manifold, **server write** (the author's `contact_stale` cell) | p1 | `runs_b/cphase.1-3` | `w0_c=0 n1_c=4 n2_c=4` → delta 1 |
| same | p2 | same | `w0_c=0 n1_c=0 n2_c=4` → **delta 2** |

Cross-checks: the p1 values reproduce the author's own pins (`delta=1`,
`in_w0_c=0 in_n1_c=4`, `enter@f0+1`), so the fixture is self-consistent; the p2
column is the falsifier. Reproduced under `run_on_separate_thread=true`
(`runs_b/phthr.1-3`, `phthr2.1-3`, `sphthr.1-2`) and under Jolt
(`runs_b/phjolt.1-2`, `sphjolt.1-2`, `cphj.1-2`) — the phase rule is
backend- and thread-invariant, i.e. it is a property of the frame, not of the
solver. Byte-identical across reps in every project.

Mechanism (inference, marked): `Main::iteration()` runs the physics steps and
then the process frame, and within a step the order is `sync()` →
`flush_queries()` → `physics_process()` (emits `physics_frame`) → `end_sync()`
→ `step()`. A write issued in the `await physics_frame` continuation is already
flushed when that step's `step()` runs, so the event is generated in the same
step and observed one tick later; a write issued from the process frame is
flushed by the *next* iteration's `sync()`, so its event lands one iteration
later (delta 2). The frame numbers agree in every receipt (p1 `4→5`, p2
`11→13`).

Why it matters despite a green battery: the fixture only ever writes at the
physics phase, so no landed pin flips — but the README sentence is the
banked claim, and the *common* consumer case (teleport in `_process`, an input
callback, `set_deferred`) is exactly the phase that measures 2.

## (2) COUNTEREXAMPLE 2 — the `static_nopair` rule does not hold under Jolt

README:575-577 states a *rule*: "The `static_nopair` negative proves the
generated-event tier only re-pairs movers: a teleported STATIC body never
produces an area pair, while moving the area itself fires enter at the next
tick." Measured on the same build, same script, same geometry, with
`physics/3d/physics_engine="Jolt Physics"` (compiled in and selectable, per the
author's own gate): the teleported STATIC body **does** pair and **does** fire.

| backend | receipt | measured at n1 / n3 |
|---|---|---|
| DEFAULT (GodotPhysics3D) | `runs_b/svac.1-3`, `svac2.1-3`, `svacthr.1-2` | `srv=(0,0,0) isect_A=1 ov=0 sig=0` (n1 and n3) — **no pair, non-vacuous** |
| Jolt | `runs_b/svacj.1-2`, `svacj2.1-3` | `srv=(0,0,0) isect_A=1 **ov=1 sig=1**` (n1 and n3) — **pair forms, event fires** |
| both, control (move the area) | same receipts | `mv_sig=1 mv_delta=1 ov=1` — the area-move control behaves identically on both |

The landed fixture itself fails the same way when run against a Jolt project
copy — I copied the seeds to scratch `fixtures_jolt/` (seeds untouched), set
`physics/3d/physics_engine="Jolt Physics"` **only in the copy's**
`project.godot`, and ran the landed `--only` line:

```
FAIL phys3d_events_static_nopair  exit=1 expected=2
  'static_nopair drift tp=true ov=1 mv=true delta=-3'   (phys3d_events.gd:488)
FAIL phys3d_events_cast   'cast settled fractions drift safe=0.14984130859375 unsafe=0.1500244140625'  (:242)
FAIL phys3d_events_btm    'btm setup wrong hit=true travel=(0.0, 0.0, -0.998535)'                      (:267)
totals: cases=10 pass=7 fail=3        → batt_jolt/20261014T170155308197Z/verdicts.json
```
Reproduced 3/3 on the 3-row subset with byte-identical stderr
(`batt_jolt2/…`). So under Jolt: **7/10 rows pass** (isect, pp_queries,
contact_stale, contact_sig, sync_cb, srv_area_cb, threaded_edge — the lattice
core *does* replicate, as the author claims), the two constant-pinned rows fail
as expected from the disclosed solver-constant difference, and **the one row
whose content is a mechanism rule fails for a mechanism reason**.

Two defects fall out of this, one of them in the fixture:

1. **Claim-scope (fixable):** README:585 says Jolt differs only in "solver
   constants" and the author report says "The claim is backend-invariant for
   the measured cells". The measured cells did not include `static_nopair` —
   the only cell whose content is a rule rather than a constant. The rule is
   GodotPhysics-only.
2. **Control independence (fixable, fixture):** the negative's own live control
   computes `mv_delta = sig_log[0] - f_mv` (`:486`) **without clearing
   `sig_log`**, so the moment the treated cell fires (Jolt), `sig_log[0]` is the
   *teleport's* frame and the control reports the nonsense `delta=-3`. The
   control is only independent of the treated cell on the backend where the
   treated cell is silent. My probe clears the log before the control
   (`SVAC control tp_sig=1 area_move mv_sig=1 mv_delta=1` under Jolt) — which is
   also how the DEFAULT receipt reads today.

## (3) CORRECTION — the ST "majority-refused 11/12" is a deterministic context gate, not a race

The fixture pins `proc_dss_refused := nulls >= 8` (`:576`) and README:587 hedges
it as "a majority-not-total property (pinned as a ≥8/12 threshold, not an
absolute)"; the author report calls the single non-null sample "one race-window
success". I ran the child's exact loop as its own arm (`--arm=dssdist`):

```
12/12 threaded runs:  DSSDIST thr=true nulls=11 of 12 threshold8=true ok_idx=[0] ok_inphys=[true]
 3/3  DEFAULT control: DSSDIST thr=false nulls=0 of 12 threshold8=false
```
(receipts `runs_b/dss.1-10`, `dss2.1-12`, `dssctl.1-3`)

Sample 0 is taken in the physics-frame continuation (the legal window) and is
always the one granted sample; samples 1-11 are process-frame samples and are
always refused. So the refusal is **context-determined and deterministic in
22/22 runs**, not a flaky majority — and the `≥8` threshold is 3 samples
weaker than the measurement supports. What *is* racy is the separate startup
fetch (`dss = root.get_world_3d().direct_space_state` in `_run`): under
threading it came back null in **11/11** of my threaded runs with
`ERROR: Space state is inaccessible right now … godot_physics_server_3d.cpp:194`
(probe stderr), consistent with the author's `early_null` note (1 non-null in
4) and boundary's startup hole. No green/red defect — the pin still passes —
but the hedge invites the wrong mental model (a window that might close) where
the evidence says a context rule.

**Probe hazard, recorded for the wave:** my first threaded runs printed
`w0_isect=0 n1_isect=0 n3_isect=0` from a **null** DSS and I nearly banked them
as "threaded queries miss the body". They are script errors
(`SCRIPT ERROR: Cannot call method 'intersect_shape' on a null value`,
`crit83b.gd:136`), not measurements; the corrected arm (`_ensure_dss` fetches in
a legal window when the startup fetch is refused) prints `prov=legal` and gives
`n1_isect=1` — the same value as DEFAULT. This is the author's probe1 lesson
(an errored arm can still exit 0) recurring one level down: **a value that looks
like a measurement can be a null-instance error unless stderr is read.**

## (4) Attacks tested and REJECTED (bounded non-findings)

- **Negative vacuity (the brief's question).** On DEFAULT the negative is
  **non-vacuous**, with witnesses the fixture does not carry: at n1 and n3 the
  static body's **server** transform is at the overlap position
  (`srv=(0,0,0)`) and a geometric query finds it in the space (`isect_A=1`),
  while the area's overlap list stays 0 and no signal fires — 6/6 DEFAULT reps
  plus 2/2 threaded. The silence is a real event-tier silence, not a write that
  never arrived. (Its *generality* still fails — §2.)
- **Nested-engine flake risk.** `phys3d_events_threaded_edge` launches a second
  Godot inside a 20 s per-case budget. Measured: whole `--only` invocation
  1.584 / 1.331 / 1.430 s wall (3/3) → ~12× headroom; the case is not a latent
  timeout.
- **ST pin flakiness.** 22/22 runs at `nulls=11` against a `≥8` pin — ≥3
  samples of margin; not flaky in this regime.

## (5) The partition's write-path confound (partial finding, LOW-MEDIUM)

The brief's "event-kind vs call-site" restatement is right that
`body_test_motion`/`cast_motion`/`intersect_shape` measure as queries — but the
fixture compares a **server** write (`body_set_state`) in the query cells
against a **node** transform write (`body.position`) in two of the four event
cells (`contact_sig:367`, `static_nopair:473`). Those are different flush
paths, and with the node path the query is *not* edge-0:

```
DEFAULT, node write:  w0_isect=0 → n1_isect=1        (runs_b/phase.1-3, 5/5)
```
i.e. after a node teleport the space does not see the new transform in the same
turn (it lands at the next tick), so inside `contact_sig`/`static_nopair` there
is **no query-vs-event split at all** — both sides move at n1. The clean
single-write-path discriminants in the landed set are `contact_stale` and
`srv_area_cb` (server writes; my `torn` DEFAULT control shows the server-write
query is live in the same turn, 24/24 samples across 3 runs). The fixture
*header* (`:1-3`) states "query APIs bind edge-0 same-turn" without the
write-path qualifier that README:565-570 correctly carries ("in the same turn as
a `body_set_state` write"). Fixable by one header line or one node-write query
cell; the lattice claim itself survives on the two clean cells.

## (6) Minor provenance

- Commit message `e9145d9` claims "contact manifold + body_entered/exited +
  **sync/force callbacks** delta=1". `grep -c body_set_force_integration_callback
  corpus/fixtures/phys3d_events.gd` = **0** — no force-integration-callback cell
  exists in the landed fixture (the README does not repeat the claim). Commit
  prose only; no artifact edit needed if the message is not banked as evidence.
- All live receipts — the author's Jolt replication included — sit under
  `corpus/live/`, which is gitignored (`git ls-files corpus/live` = 0). The
  landed commit therefore contains no re-runnable Jolt evidence; my §2 Jolt
  run is scratch too. Corpus convention, not a breach, but the Jolt sentence at
  README:585 is a claim whose support is ephemeral.

## (7) Impacted axes and smallest safe corrections

Axes named for this lane: **(a) claim fidelity/provenance, (b) regression-gate
strength, (c) backend generality, (d) determinism/byte-stability.** No axis
regresses from my findings (I changed nothing); each correction below is
insertion-only or claim-text and leaves the 186/186 DEFAULT battery green.

| # | axis | defect (fixable) or tradeoff | smallest safe correction |
|---|---|---|---|
| 1 | a, c | README:573-574 "exactly one tick after their triggering write" is false for process-frame writes (§1) | qualify to "one tick when the write is issued inside the physics step (the `await physics_frame` phase), two ticks from the process frame"; optionally one new insertion-only cell pinning `delta=2` |
| 2 | a, c | README:575-577 `static_nopair` rule is GodotPhysics-only; README:585 "same lattice, different solver constants" overclaims (§2) | qualify the rule to DEFAULT/GodotPhysics3D, record the Jolt counterexample (`ov=1 sig=1`) as a bounded cell, and gate the arm on the selected backend |
| 3 | b, a | the negative's control is not independent of the treated cell (`:486` computes delta from an uncleared log) (§2) | clear `sig_log` before the area move and compute `mv_delta` from the post-clear log |
| 4 | b | `proc_dss_refused` `≥8/12` threshold + "majority/race" hedge is weaker than the measured context rule (§3) | keep the threshold (no regression) and reword to the measured rule; or tighten to `nulls == 11` with `ok_inphys == [true]` |
| 5 | a | fixture header `:1-3` drops the `body_set_state` write-path qualifier that README:565-570 carries (§5) | one header line: edge-0 is demonstrated for server writes; a node teleport lands at the next tick |
| 6 | a | commit message "force callbacks" has no cell (§6); Jolt evidence is gitignored (§6) | wording only; no artifact change (the README is already accurate here) |

Nothing here is a tradeoff the judge must *reject*: every landed pin still
passes on DEFAULT, the two-tier split is genuinely demonstrated by
`contact_stale`/`srv_area_cb`, and the negative is non-vacuous on the pinned
backend. The defects are that three landed *sentences* bank more generality than
the cells measured (write phase, backend, and the race framing), and one
control line is not independent. If the adjudicator wants the Jolt generality
banked rather than qualified, the minimum is a landed Jolt-bounded receipt —
which is a new fixture cell, not a wording change.

## (8) Not measured here

- Contact-count / monitor-callback latency under Jolt **threaded** (the cross
  product the author already listed as unprobed) — I measured each factor
  separately, never both together.
- `body_set_force_integration_callback` timing (no cell exists; §6).
- The node-write flush path's exact flush point (measured: not same-turn,
  present at n1; the `sync()` attribution is inference).
- `static_nopair` on Dummy; static-vs-body-body contact pairs; area/soft-body
  RIDs in the Jolt free-order matrix.
- Every claim is bounded to this host and `4.7.2.stable.arch_linux.ed1daf0bf`;
  no cross-build or cross-version claim.

## (9) Artifacts

- Report: `reports/round-83/r83-critic.md` (this file).
- Probe: `corpus/live/r83-critic/proj_c/crit83b.gd` sha256
  `b9ffaf70aca80f2c914f8460ba80cdd849fb7d0fbe846e53c5da9a51c11b2116` (copies in
  `proj_c_thread/`, `proj_c_jolt/`); runner `run_c.sh`; projects
  `proj_c/{,thread,jolt}/project.godot`; receipts `runs_b/` (72 stdout/stderr
  pairs + `.exit` files, `phase*`, `sph*`, `cph*`, `svac*`, `dss*`, `torn*`).
- Landed-state replay: `batt_full/20261014T170227489416Z/verdicts.json`
  (186/186, `seeds_unchanged=true`) + `batt_full.log`.
- Jolt falsification of the landed rows: `batt_jolt/20261014T170155308197Z/`
  (10-row subset, 7 PASS / 3 FAIL) and `batt_jolt2/` (3-row subset ×3 reps),
  seeds copied to `fixtures_jolt/` (copy only; the seed tree was never touched).
- Timeout budget receipts: `batt_runs/20261014T1701{48,49,50}…Z/verdicts.json`.

Report only; I do not judge, admit, edit fixtures, commit, or ship. Stopping
here.
