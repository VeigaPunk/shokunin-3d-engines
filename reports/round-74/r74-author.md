# Game-dev-3d round 74 — moving-agent navigation semantics as tracked CASES arms (author, host: devin)

## Work performed

- Before-state `e435a01` (r73 adjudication landing): 127 Godot headless
  cases plus four opt-in probes; Node three.js 31/31. This session resumed a
  prior same-seat session's UNCOMMITTED working-tree diff
  (`navagent3d_detour.gd` +~501, `run_battery.py` +~36) plus partial scratch
  (`corpus/live/r74-author/{runs,scratch}`); per dispatch I audited the
  diff against the four declared claims before extending anything.
- Declared axis move (verbatim, dispatch brief): formalize MOVING-AGENT
  navigation semantics as tracked CASES arms on the r71-r73 stationary
  surface — (a) stored path FROZEN at target-assignment while
  distance_to_target/next stay live call-time arithmetic; (b) pop index
  follows live position by the strict-< Euclidean pop rule against the
  stale stored path; (c) reached/finished latch semantics under motion
  (or measure the actual unlatch); (d) target_position re-assignment
  re-queries from the agent's LIVE position, boundary measured bank-side.
  Additive `--arm=` presets only; 127 prior rows + 4 probes + Node 31/31
  stable.
- Bounded spike (prior session, receipts on disk, scratch-only):
  `corpus/live/r74-author/scratch/navagent3d_motion_probe.gd` sha256
  `bbf97216c95bb9ca49802a966aad74681b086917d7a9c7e2ed822ae2f734dea1` — a
  `--scenario=` stepper printing the full observable tuple
  (pos/idx/next/final/dist/reachable/reached/finished/target/path/plen)
  after every scripted teleport or target re-assignment on the same
  authored L-corridor + island + server link. 21 stdout receipts
  `corpus/live/r74-author/runs/fp*_*.stdout.txt` (pmd bisection
  `fp_edge_lo/eq/hi`, authored-pmd `fp_pmd10`/`fp_d30_pmd5`, latch
  `fp_lat*`, origin `fp_origin`, gap-corridor `fpg_*`, dist sweep
  `fp_d*`), every run exit 0, stderr banner-only. Scratch `project.godot`
  sha256 `1fda90d46b0529aea0e75710a64f038cbf983adc8385285dd8bbe6202a8eac23`
  = tracked seed. (Scratch also holds an intermediate `navagent3d_detour.gd`
  revision — the working copy before the last three arms; scratch only.)
- Audit verdict: the inherited diff pins all four claims — no
  fix/extension was needed. What it does: extends
  `corpus/fixtures/navagent3d_detour.gd` additively — sha256
  `0ae04750b2041ba17bfb1835c70c40ad182e116ab87069be7fec05b1e4835ce4` →
  `336898f4b711021a21e619385244e662168889ba5c52ec6812af9c5034601276`,
  `git diff --numstat` = +501/−5 — plus 18 additive CASES rows in
  `run_battery.py` +36/−0 (`9f18a711ff958abce08aad3b6db8e7f226c9a897beedc811023540cc61872860`
  → `697b3d5fa0dcab147ee79016354e07dee52e6820777508cca237b27385f70f86`).
  The five deletions are mechanical: the outdated "No agent motion" header
  line (replaced by the r74 arm doc block), the single-teleport
  `expected_pos` branch (folded into the steps-aware
  `expected_pos`/`expected_target` walk), the `arm_cfg.has("tp")` branch
  becoming `elif` after `steps`, and `target` → `expected_target` in the
  setup gate so `set_target` steps are checked. User surface unchanged:
  still only `--arm=<name>`; each motion arm's `steps` array is authored
  constants in `_arm_cfg` (per step: optional `tp`/`set_target`/`wait`
  plus the full expected tuple AND the complete expected stored `path`
  array), executed by `_run_steps` (set_target applies before tp inside a
  combined step; default 5 physics frames, `wait:0` reads call-time) and
  asserted by `_run_motion_arm` (named per-step diagnostics, exit 1).
  Optional per-arm `pmd` writes `agent.path_max_distance`.
- Prior-rows invariant verified two ways: (i) programmatic — all 127 HEAD
  CASES tuples byte-present in the new CASES, order preserved, added names
  = exactly the 18 `navagent3d_detour_mv_*`, removed = none; (ii)
  behavioral — the fresh full battery re-ran every prior row with exact
  marker match, 0 mismatches.

## Audit of the four declared claims (all pinned — measured on Godot 4.7.2.stable.arch_linux.ed1daf0bf)

```
(a) frozen path — CONFIRMED WITH A MEASURED BOUNDARY (literal "frozen,
    locomotion never re-queries" reading is FALSIFIED at the edge):
    the stored path is frozen while the agent stays within
    path_max_distance (default 5.0, STRICT >) of path[nav_idx]; teleports
    on-mesh, off-mesh into the void, and off the map edge inside that
    radius never re-query (mv_walk, mv_live, mv_popback, mv_popstrict,
    mv_void, mv_bridge_walk pin the full stored array at every step).
    Beyond pmd the next forced update re-queries and the new path[0] is
    the navmesh clamp of the LIVE position: euclid(agent,path[1]) 4.995
    frozen / 5.025 re-queried (mv_pmd_edge, boundary bisected by
    fp_edge_lo/eq/hi); authored pmd tracks the gate (pmd=10 keeps the
    same teleport frozen — fp_pmd10; pmd=2.0 breaches — mv_pmd2,
    fp_d30_pmd5); off-map (10,0,10) re-anchors to clamp (3,0,4) with no
    undo on return (mv_pmd_offmesh). The finished latch gates even the
    re-query OFF (mv_latch, agent 10.63 > pmd keeps stale path).
    distance_to_target/next/final/flags stay live call-time arithmetic
    throughout — mv_live's wait=0 read already shows the re-pop with no
    physics frame elapsed.
(b) pop follows live position — CONFIRMED and sharpened: monotone
    non-decreasing strict-< Euclidean vs the STORED path, evaluated on
    the live position at call time (mv_walk idxs 1,2,2; mv_live wait=0;
    mv_popback never un-pops on return to spawn; mv_popstrict
    euclid==pdd holds / 0.01-closer pops). Two sharpenings: the advance
    is SEQUENTIAL — it cannot skip a waypoint (mv_popskip: teleport to
    euclid 0.707 < tdd of the final while idx=1 leaves idx=1 and next
    pointing at the unconsumed waypoint BEHIND the agent, while
    reached/finished fire anyway — raw-euclid flags decoupled from idx);
    and link endpoints pop as ordinary waypoints mid-void
    (mv_bridge_walk idxs 2,3,3).
(c) latch — CONFIRMED with the unlatch measured: is_target_reached /
    is_navigation_finished stay latched through arbitrary motion
    including off-mesh and beyond-pmd (mv_latch teleports to spawn then
    (10,0,10): flags still true, path/idx untouched — the latch
    early-returns the update loop). The measured unlatch is ANY
    target_position re-assignment, same value included — no dedup
    (mv_unlatch: set_target of the SAME target unlatches, resets idx to
    0, and re-queries anchored at the live-position clamp (3,0,4)).
(d) re-anchor — CONFIRMED one level finer than declared: target_position
    re-assignment re-queries from the agent's LIVE position
    (mv_reanchor new target mid-path → path[0]=(1.5,0,0.5);
    mv_reanchor_same same-value → path[0] still moves off S). Bank-side
    boundary measured both ways: with the server link live,
    re-assigning T2 at (2.5,0,3.9) anchors at the live position and
    still routes through the link [(2.5,0,3.9),(2.5,0,3.5),(2.5,0,5.5)]
    (mv_reanchor_bank); without it the same re-assignment clamps to the
    B edge [(2.5,0,3.9),(2.5,0,4.0)], unreachable → finished=true via
    the idx+pdd clause (mv_reanchor_void). Finer: the re-query is LAZY —
    it materializes inside the first forcing call anchored at the
    position live at THAT call, not at assignment (mv_reanchor_lazy:
    set_target+teleport in one step anchors post-teleport (2.6,0,2.0);
    mv_reanchor_force: a read between assignment and teleport anchors
    at read-time (1.5,0,0.5) and stays frozen through the move).
    Getter laziness recorded: get_current_navigation_path does NOT force
    an update ([] until the first get_next_path_position call);
    get_next_path_position forces the once-per-frame update
    synchronously — _read_state always sees the post-update tuple.
```

## Evidence

- Full battery (this session, canonical repo root):
  `python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot --runs …/corpus/live/r74-author/runs --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing`
  → exit 0, `PASS battery`. Receipt
  `corpus/live/r74-author/runs/20261014T041431092173Z/verdicts.json`:
  `totals={cases:145, pass:145, fail:0, ordinary:100, negative_controls:45}`,
  `seeds_unchanged=true`, `godot_version=4.7.2.stable.arch_linux.ed1daf0bf`,
  all four probes ok (mutation probe `verdict=PASS detected=true`),
  18/18 `navagent3d_detour_mv_*` PASS, 127/127 prior PASS, every row's
  exact marker ∈ stdout (programmatic check, 0 misses). Capture
  `corpus/live/r74-author/runs/battery-r74-final.out`.
- Prior-session receipts corroborating the same green state:
  `corpus/live/r74-author/runs/20261014T023611258293Z/verdicts.json`
  (142/142 + 4/4 probes, the 15-arm intermediate state) and focused
  15-arm run `20261014T023536000831Z` (15/15). The interrupted third
  capture `battery-r74-full2.out` had already logged all 18 mv arms
  PASS before it was cut mid-battery.
- Node three.js suites (untouched this round, re-run for the gate):
  `node <suite>.mjs --receipt …` under `corpus/fixtures/three` —
  run_cases 3/3, run_layer_cases 4/4, run_order_cases 9/9,
  run_camera_cases 5/5, run_ortho_cases 5/5, run_ray_cases 5/5 =
  **31/31 PASS**, every suite `seeds_unchanged=true`; receipts
  `corpus/live/r74-author/runs/node-run_*.json`.
- Falsification path per clause is authored, not ambient: every step of
  every motion arm pins pos/idx/next/final/dist/three flags AND the
  complete stored path array — a path element that moved without an
  authored re-query fails the step with a named diagnostic
  (`stepN path[j]=… expected=…`), exit 1; a moved idx, flag, or waypoint
  likewise fails. The battery classifier independently rejects any
  missing/extra stdout line or stderr noise.
- Working tree (left uncommitted, per-seat rule): `git status` =
  `M corpus/fixtures/navagent3d_detour.gd`, `M corpus/fixtures/run_battery.py`,
  `?? reports/round-74/` (this report plus sibling seat reports); numstat
  +501/−5 and +36/−0; hashes above.

## Files changed

- `corpus/fixtures/navagent3d_detour.gd` (+501/−5): r74 motion-arm doc
  block; `steps`/`pmd` arm keys; `_run_steps` + `_run_motion_arm`;
  `expected_target` gate; 18 `mv_*` arm cfgs.
- `corpus/fixtures/run_battery.py` (+36/−0): 18 CASES rows
  `navagent3d_detour_mv_*`.
- Scratch (gitignored): `corpus/live/r74-author/` — spike script +
  project copy, 21 fp_* receipts, 3 run dirs, battery captures,
  6 node receipts.

## Remaining risks / blockers

- Single-build measurement: all semantics pinned on Godot
  `4.7.2.stable.arch_linux.ed1daf0bf`; pmd gate, lazy materialization and
  latch-early-return are engine internals that could shift across builds
  — the CASES expectations would then falsify noisily, by design.
- The `wait`-default-5-frames read means per-step state is the settled
  post-update tuple; only `mv_live` step 1 pins the literal call-time
  (0-frame) read. Between-frame transient states (e.g. the one-read lag
  between forced-update internals and `get_current_navigation_path`
  observed in `fp_edge_eq`'s S1) are documented in the header comment but
  not separately armed.
- No self-propelled locomotion covered — motion is authored teleports plus
  target re-assignment (declared scope; velocity-driven movement was never
  claimed).
- Blockers: none. Battery green end-to-end; prior rows 0-mismatch; no
  commits/pushes attempted (operator-owned).
