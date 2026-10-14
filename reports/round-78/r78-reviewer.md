# r78 reviewer — integration-base audit of committed r77 state

Seat: `reviewer`. Lane `g3d`, round `r78`. Audited state: HEAD `71818b7`
("r77 report-last: ADMIT"), which carries work commit `35dfbe2` + hygiene
`565318c` + `5e02b25` + `a5ae849` — the integration base for the r78 diff.

Repo note (same as r75/r76/r77 seats): the brief's `~/Projects/prymeagnt/game-dev-3d`
is the stale worktree — it does not contain `35dfbe2`/`565318c`/`5e02b25` at all
(`git cat-file -t` fails for each; its `.shokunin/game-dev-3d` symlink targets the
canonical repo). All work below ran in canonical
`~/Projects/shokunin/game-dev-3d-shokunin`. Build: Godot
`4.7.2.stable.arch_linux.ed1daf0bf` (`/usr/bin/godot`), Python 3.14.7, Node
v24.21.0, 60 tps (`project.godot` sha256 `1fda90d4…`, matches r77-scribe's pin).

LSP note: no `lsp` device is exposed to this seat on the devin substrate, so
caller/reference checks are text-grep/file-read evidence, not server-verified
semantic proof — recorded as a verification gap.

## Verified on committed HEAD (my own runs this round)

- **Battery 173/173** — `python3 corpus/fixtures/run_battery.py --godot
  /usr/bin/godot --runs <abs>/corpus/live/r78-reviewer/runs --probe-failing
  --probe-crash-exit --probe-stream-attribution --probe-tree-timeout` →
  `totals: cases=173 pass=173 fail=0 ordinary=128 negative_controls=45
  probes=4`, `seeds_unchanged: true`, runner exit 0, verdict PASS.
  Receipt `corpus/live/r78-reviewer/runs/20261014T120144701607Z/verdicts.json`;
  log `corpus/live/r78-reviewer/battery-run.log`. All four probe receipts
  `verdict=PASS` (mutation detected=true; tree-timeout verified detached
  witness + SIGTERM cleanup).
- **Node 31/31** — six suites on the committed tree, receipts
  `corpus/live/r78-reviewer/node/*.json`: run_cases 3/3, run_layer_cases 4/4,
  run_order_cases 9/9, run_camera_cases 5/5, run_ortho_cases 5/5,
  run_ray_cases 5/5 — all `verdict=PASS`, `seedsUnchanged=true`, exit 0.
- **Prior-163 byte-stable vs r76-verifier receipt** — field-diff of my
  `verdicts.json` vs `corpus/live/r76-verifier/runs/20261014T102343921913Z/
  verdicts.json` on the 12 stable fields (`case, script, flags,
  expected_exit, actual_exit, error, kind, marker, verdict, reasons, stdout,
  stderr`; `command`/`elapsed_seconds` excluded as path/timing):
  **163 common cases, 0 mismatches**; the only new rows are exactly the 10 r77
  arms. Same diff vs the r77-verifier receipt: **173/173 common, 0
  mismatches**. Script `corpus/live/r78-reviewer/compare_verdicts.py`.
- **mark-vs-phase comment accurate vs the fixture code path** — the committed
  header (`navagent3d_detour.gd:215–218`, landed `5e02b25`) reads "the w0
  forcing read marks the stamped-dirty map so the next scheduled sync
  publishes a frame early — a mark-vs-phase race; single-read-per-rung
  callers see NO serve collapse (link stays 2, region stays 3)". Code path
  check (`_run_steps` :2172–2199): step order is mutate → wait → peek →
  srv_get → `_read_state`'s forcing `get_next_path_position` — so in
  `mut_force_link` the w0 forcing read runs *after* `map_force_update`
  (stamped dirty exists: srv_get pins `link_iter=2, en=false` at w0), and in
  `mut_force_ctl` the w0 read runs *before* the queued write applies
  (`iter=1`), so it cannot mark. Consistent with the measured split:
  scribe's fresh-process-per-rung protocol shows NO collapse under force
  (`dis,fu` edge 2, `xf,fu` edge 3 — unchanged), while read-every-frame
  callers see the early publish ({w1,w2} link jitter / 3f→2f region). The
  critic's alternative (force performs one sync stage immediately) does not
  fit the fresh-rung data, so mark-vs-phase is the better-supported
  mechanism; the comment attributes it ("r77-scribe") and does not overstate.
- **mut_off permanence evidence ceiling = +15f** — `mut_map_off` step waits
  {0,10,5} → last stale sample at +15f post-deactivate (:1536–1556).
  Tighter for the r78 target class: the link-kill-under-mapoff arms hold the
  kill queued under an inactive map only ~5f — `mut_ord_kill_mapoff` step1
  (no `wait` key → default 5) and `mut_map_cycle` step2 `wait:5` — before
  reactivation replays the 2f edge. The r76 adjudicator's bound stands:
  "permanent … bounded to measured +15f/forcing-call coverage, not a proof
  of unboundedness" (`reports/round-76/r76-adjudicator.md:68`). The
  r78-declared {20,60,120,300}f ladder extends measured coverage well past
  both ceilings.
- Committed tree is clean vs HEAD after my runs (`git status --porcelain`
  empty; `corpus/live/` is gitignored — my scratch is contained). Fixture
  sha256 `de9ef7cf…`, runner `92c5ad87…` (runner byte-identical to the
  r77-author's recorded digest — untouched since `35dfbe2`).

## Findings (severity order)

**LOW-1 — jitter-rate "~15-20%" is a single-harness datapoint, not a
constant.** The header (:213) and arm comment (:1846) cite ~15-20% w1-fresh
"w2 dominant". Across r77 seat harnesses the measured rate ranged 4%
(simplifier, author-probe shape, 1/25) to ~63% (arm-shape, 17/27) and ~75%
(scribe v1 replays, 6/8) — the simplifier's adopted refinement is that the
rate is a phase artifact of harness weight, not a stable constant. The
comment is honest as a sourced measurement but can be misread as the rate.
The author's diff must not cite it as constant and must not pin any w1-rung
serve under force.

**LOW-2 — "NEVER"/"arbitrary forcing calls" wording exceeds the pinned
bound.** Header :169–172 and arm comment :1521–1526 assert map-off
permanent-stale with no frame bound attached; the measured ceiling is +15f
(pure map-off) / ~5f (kill-under-mapoff). This is exactly the r78 axis's
declared motivation. If the ladder lands with no late flush, the comment
should carry the new measured ceiling (e.g. "no flush through +300f"); if a
flush appears, the claim is falsified and the measured bound lands — the
author must then correct the wording, not leave "NEVER".

**NOTE-1 — region-force claims are comment-level only.** "region
deterministic 3f→2f" and "region_iter still stamps at w1" are sourced to
r77-critic/scribe scratch probes; no tracked arm exercises region+force
(r77-simplifier coverage note). If the r78 diff touches region+force paths,
these are scratch-evidence, not CASES-pinned facts.

**NOTE-2 — `srv_get` lacks a `map_iter` key.** `_read_srv` (:2278–2294)
supports link_enabled/link_iter/link_start/link_end/map_active/
region_transform — no `map_get_iteration_id` and no `region_iter`. The
declared falsifier "a late flush (map_iter bump, tuple change)" needs either
a new additive getter key or tuple-change detection alone. `_tuple_sig`
(:2036) does not sign iter state, so a pure iter bump with unchanged tuple
is invisible to the ladder partition — the author should be deliberate about
which surface detects the flush.

## What the r78 author's diff must NOT break

Contract rows (all measured-verified on this base):

1. **All 173 CASES markers byte-stable.** `run_battery.py` additions must be
   insertions only (r77 precedent: +20/−0). Any edit to an existing expected
   string — or any fixture change that shifts an existing arm's observed
   tuple — breaks the declared "173 prior rows byte-stable".
2. **The 4 probes green** (`--probe-failing` mutant detected with the exact
   diagnostic; crash-exit; stream-attribution; tree-timeout with verified
   detached-witness SIGTERM cleanup) and **Node 31/31** (`three/` is excluded
   from seed digests and the scratch copy — leave it untouched).
3. **Fixture schema stays opt-in.** `srv_get`/`ladder`/`peek_*`/`peek_only`/
   `mutate`-as-array/`map_force`/`map_active`/`link_start`/`link_end` fire
   only when the key is present — the 163 prior rows exercise the unmodified
   paths (byte-stability proves it). New keys must follow the same pattern.
4. **`_apply_mutation` fixed order**: delete → recreate → region
   xform/enabled/layers → link {en,layers,start,end} → agent → `map_force` →
   `map_active` (:2222–2269). The 10 r77 arms' semantics depend on it; the
   map_force-before-map_active placement is what makes a force+deactivate
   dict "flush then freeze".
5. **One forcing read per step.** `_read_state`'s `get_next_path_position`
   is the mark-vs-phase instrument itself — adding a forcing read inside a
   step (or an extra read step near a boundary) changes read-history and can
   shift the very edges the r77 arms pin (`mut_force_*`, `mut_ladder_*`,
   `mut_win_*`). Peek (`get_current_navigation_path`/`_index`) and `srv_get`
   must stay non-forcing or the two-stage pins collapse.
6. **`_tuple_sig` / `_check_tuple` / PASS-marker formats are byte-pinned**
   by CASES (incl. ` bound=%d groups=%d sizes=%s` suffix; `ladder_tail` must
   stay `""` for non-ladder arms). The partition already supports the
   permanence shape: all-rungs-identical → `bound=-1 groups=1` (scribe's
   `pre=moff` precedent).
7. **`_final_srv_state` fold must mirror apply order** for any new mutation
   key — the r77 simplifier mutant lattice proved fold/apply divergence is
   caught by the honesty gate. A callsite-issued mutation that bypasses the
   `mutate` fold will mismatch `fs` (map_active/agent_layers/region folds)
   and fail its own arm.
8. **Determinism, not just correctness.** `mut_force_link` exists because a
   w1 pin flaked inside the official battery. Two specific flake hazards for
   the declared work:
   - **Reactivation-edge reads.** `mut_ord_*mapoff*`/`mut_map_cycle` pin
     stale@+1/fresh@+2 post-reactivation with reads at +1 and +2 only. A
     read *at* the reactivation instant, or extra forcing reads near it, can
     mark the re-stamped map and pull the publish early — same mark-vs-phase
     race, new surface. Sample the deterministic rungs or pin the envelope.
   - **Callsite w1 pin.** The `_physics_process` −1 edge (link serve at
     await-count 1 vs coroutine 2) is measured (r76-critic `bb_physmut`;
     r77-boundary `phys_loff` fstar=1, order-partition invariant) but on
     limited reps — the same shape of claim that jittered under force.
     Multi-rep evidence before pinning the constant; if it jitters {0,1}
     instead, pin w0-facts + a later deterministic rung.
9. **Case timeout is 20 s.** At 60 tps a cumulative {20,60,120,300}f
   inactive hold ≈ 500f ≈ 8.3 s + ~30f settle + process startup — fits, but
   the margin narrows if more rungs or a second arm's waits stack up.
   `mut_map_off`'s own 15f precedent stays cheap; the new ladder is the
   slowest arm in the battery.
10. **Callsite machinery is new surface.** The fixture is SceneTree-coroutine
    only — no `_physics_process` instrument exists (grep: zero). A
    PhysMutator-style tree Node must be opt-in per arm (its mere existence is
    inert to nav timing, but keep it out of non-callsite arms), and the
    paired arms must pin the −1 tick shift as receipts, not just assert it.
11. **Suppression carve-outs.** Any new setter key must be a real-value
    change or the arm cannot falsify (M-witness precedent); note
    `map_set_active(true)` on an already-active map is itself a suppressed
    same-value write (r76 `sv_map_active` inert) — reactivation writes in the
    ladder arms must be genuine transitions.
12. **Setup gates run for every steps-arm** (:387–408 live-map/link/region
    readbacks + `fs` fold). The new arms must satisfy them with the arm's
    *final* state — for the permanence ladder that is `map_active=false`
    (the fold already supports it: `fs["map_active"]` folds `map_active`
    writes).

## Residual risk / verification gaps

- No `lsp` device on this substrate — cross-references (e.g. `link_layers`
  consumer-freeness, `st2` dead-store) verified by grep/read, not server
  diagnostics. The r77-simplifier's LSP-verified deletions are consistent
  with my text-level check (no remaining `want.has("link_layers")` consumer;
  `st2` declaration kept, dead assignment gone — battery green confirms).
- The mark-vs-phase mechanism is an inference from read-pattern experiments
  (fresh-rung vs cumulative, double-read control) — well-supported but not
  engine-source-proven. The fixture comment's attribution and scoping are
  accurate; the critic's residual alternative is noted above as the reason
  the rate figure should not be treated as constant.
- `map_off` permanence beyond +15f (pure) / +5f (kill-queued) is unmeasured
  on this base — precisely what the declared ladder addresses; falsification
  is a legitimate outcome and must be reported at the rung where it lands.
- The callsite −1 shift is replicate-thin (single-digit rep counts in both
  prior seats) — flagged under item 8.

## Recommendation (not a judgment — the canonical runtime judges)

Integration base `71818b7` is sound and every claim I re-measured holds:
173/173 + 4 probes + Node 31/31 on my own run, 163-row byte-stability
re-verified against the independent r76 receipt, mark-vs-phase comment
accurate against the code path, permanence ceiling +15f (≈+5f for the
kill-under-mapoff subclass the r78 ladder targets). The declared axis-move is
executable on this base without disturbing prior rows **if** the author keeps
all changes opt-in/additive, avoids sampling jittered boundaries (w1 under
force; possibly the callsite w1), carries the measured bound into the
permanence wording, and extends `_read_srv` deliberately for the
map_iter-bump falsifier. Stop here — findings reported, no tracked edits.
