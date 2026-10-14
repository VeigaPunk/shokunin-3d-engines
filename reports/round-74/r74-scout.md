# Game-dev-3d round 74 — scout: moving-agent navigation semantics (frozen path / pop-follows / latch / re-anchor)

Seat: scout (leaf). Scope: `corpus/live/r74-scout/` + this report. No tracked
edits, no dispatch, no git mutation. Question: map the moving-agent surface of
`navagent3d_detour.gd` before the author lands the four declared claims as
tracked CASES arms.

Engine (measured, this host): `4.7.2.stable.arch_linux.ed1daf0bf` via
`/usr/bin/godot`, headless, 60 Hz physics (project.godot pins
`physics_ticks_per_second=60`). Sources read: `corpus/fixtures/
navagent3d_detour.gd` (sha256 `0ae04750…`), `corpus/fixtures/run_battery.py`
(sha256 `9f18a711…`; 127 CASES rows, 42 detour), `corpus/fixtures/
navretarget3d_driver.gd`, `corpus/fixtures/navfollow3d_driver.gd`,
r72-boundary report + its `navagent3d_walk.gd` receipts, r73-scout report.

All measurements below are mine, executed in my own scratch:
`corpus/live/r74-scout/scratch/navagent3d_motion_probe.gd` (sha256
`9eb0d175…`, 8 probes selected by `--probe=`), run as
`timeout 60 /usr/bin/godot --headless --path corpus/live/r74-scout/scratch
--script res://navagent3d_motion_probe.gd -- --probe=<name>`; receipts
`corpus/live/r74-scout/runs/probe_*.stdout.txt` — 91 PROBE lines, all exits
0, all stderr empty; `reanchor` re-run byte-identical (deterministic).
Baseline stability: `corpus/live/r74-reviewer/battery-r74.out` (all 127 rows
PASS before author lands).

---

## (1) How the detour fixture drives the agent — mechanism map

`navagent3d_detour.gd` (extends SceneTree, `_initialize` → deferred `_run`):

- **The agent never self-moves.** `actor` is a plain `Node3D` (L170-172);
  `NavigationAgent3D` is its child (L173-175). There is no
  `_physics_process`, no velocity — motion exists only as scripted
  `actor.global_position` assignment.
- **Movement today = exactly ONE teleport.** Optional arm key `tp`
  (L205-210): `actor.global_position = cfg["tp"]`, wait 5 physics frames,
  capture `st2 = _read_state(agent, actor)`. `tp_mid`, `tp_eq`,
  `fin_idx_gate`, `fin_wall`, `fin_latch` all use it.
- **Stepwise motion is NOT scriptable by existing presets** — a new
  mechanism arm is needed. Minimal-diff sketch (author owns the choice):
  add optional `"steps": [{tp: Vector3, ...expected tuple}, ...]` to
  `_arm_cfg`; in `_run` loop `actor.global_position = s.tp`, wait, then
  `_read_state`; compare each step's tuple in `_run_pop_arm` (extend
  signature with the step-state list). The `expected_pos` sanity at
  L212-221 currently pins `spawn` or `tp` — a steps arm must compare
  against the LAST step's position (or drop that check when `steps`
  present). All 42 existing presets lack `steps` → zero drift.
- Alternative (heavier): adopt the `navfollow3d_driver.gd` /
  `navretarget3d_driver.gd` pattern — a driver Node3D that calls
  `get_next_path_position()` per `_physics_process` and moves
  `global_position.move_toward(next, SPEED*delta)`. Needed only if the
  round wants continuous locomotion evidence; scripted teleports cover all
  four declared claims (a stepwise tp IS "locomotion" to the agent — the
  eval reads the live transform, never the trajectory).
- Readout capture is `_read_state` (L655-665): **call order is
  next → idx → path → dist → final → reachable → reached → finished**.
  That order is LOAD-BEARING on this build — see (3): the first getter
  triggers the agent's lazy update; the two array getters before it would
  otherwise return the stale committed snapshot.
- `_run_pop_arm` (L667-724) compares every `cfg` key present — additive
  expected keys are free; `path` compare is elementwise on the POST state,
  and `tp` arms additionally pin the PRE tuple + that the stored path
  array did not change under the move (L693-711 — already the claim-(a)
  pin shape).
- `run_battery.py` CASES rows are append-only; `seed_digests()` only
  detects within-run edits. Battery invocation (L668):
  `godot --headless --path <scratch> --script res://<script> -- <flags>`.

## (3 first — it gates everything) Headless physics sync & the LAZY-UPDATE contract

Measured: **the NavigationAgent3D update is lazy — it runs inside certain
getters at call time on the agent's LIVE node transform. No passive
per-physics-frame agent update exists on this build.**

Evidence (`probe_getorder`, `probe_triggers`, `probe_settle`,
`probe_noframe`):

- After `agent.target_position = T` + 30-frame settle, reading ONLY
  `get_current_navigation_path()`/`get_current_navigation_path_index()`
  for 8 physics frames commits nothing (npath=0, idx=0 the whole time).
  One `get_next_path_position()` call then returns the real waypoint AND
  commits npath=3 / idx=1 instantly (`getorder pathonly_f0..f7` →
  `afternext`).
- **Triggering getters (each commits the full update — fresh query
  consumed, pop loop run on live transform, flags eval'd):**
  `get_next_path_position`, `is_navigation_finished`,
  `is_target_reachable`, `get_final_position` (`triggers` probe: each left
  committed_npath=2, committed_idx=1 after reassign+teleport).
- **Pure readers (never trigger; return last-committed snapshot or pure
  arithmetic):** `get_current_navigation_path`,
  `get_current_navigation_path_index`, `is_target_reached` (committed
  flag only — at euclid 0.141<tdd 1.0 post-reassign it still returned the
  cleared `false`), `distance_to_target` (call-time live arithmetic,
  commits nothing).
- The path query inside the triggered update is **synchronous**: after a
  mid-path `target_position` re-assign, ONE triggering getter resolves
  the new path immediately — `rt_afternext` npath=2 with zero frames
  elapsed. The 30-frame settle exists for MAP sync (region must join the
  map iteration): `probe_settle` shows the query returns empty/identity
  (next=agent pos, final=(0,0,0), reach=false) until ~frame 5, real path
  at frame 5+. **Authoring rule: keep the 30-frame initial settle (map
  sync); between teleports/reassigns ZERO frames are technically needed —
  use 1-2 for readability; the existing 5-frame convention is safe.**
- `actor.global_position = p` alone is sufficient "movement": the update
  evals the node's live transform, not a server-submitted position.
  `noframe tp1_f0`: teleport to (1.6,0,0.6) → same-frame `next` call
  already popped on the NEW position (next jumped to path[2]=final; the
  pre-update idx read showed the stale committed 1).
- **finished latches → the update itself freezes.** `latch onwp`: agent
  teleported ONTO path[1]=(2,0,1) (euclid 0.05 < pdd 1.0) while
  finished=true — idx stayed 1; the pop loop did not run.
  `reanchor z4.51_pre`: fin latched via the unreachable clause with
  rch=false; live euclid→T dropped to 0.99 < tdd 1.0 yet `reached` stayed
  false — the freeze blocks the reached eval too (separates r72's
  open "reached-alone vs finished" question: it is the whole update that
  freezes).

So `_read_state`'s next-first order is what makes every captured tuple
fresh; an arm that reads `path`/`idx`/`reached` before a triggering getter
in the same frame reads the PREVIOUS update's commit. The empty-path
signature (npath=0 + next=own pos + final=(0,0,0) + reach=false) means
"no update has consumed a result yet", not "no route".

## (2)+(4) Per-claim observability table — measured discriminants

Geometry: corridor arms S=(0.5,0,0.5) → T=(2.5,0,3.5), stored path
`[S,(2,0,1),T]`, pdd/tdd per arm. Island adds C x[2,3]z[5,6], void z(4,5),
T2=(2.5,0,5.5).

| claim | arm sketch (all additive keys on `_arm_cfg`) | measured prediction (this probe) | discriminating readouts |
|---|---|---|---|
| (a) frozen path | `steps` of teleports incl. off-mesh (10,0,10) and cross-void (2.5,0,5.5); pin elementwise `path` + `p0` per step | `samepath=yes` at ALL 7 steps; `p0` stayed (0.5,0,0.5) — never re-anchored even off-mesh | `get_current_navigation_path()` elementwise + `path[0]`; a re-query would move p0 to the live clamp |
| (a) live arithmetic | same arms | `dist` = euclid(live,T) exactly every step (3.036445 @1.6,0,0.6; 9.924717 @10,0,10); call-time at 0 frames | `distance_to_target` vs hand-computed euclid (POS_TOL) |
| (b) pop-follows | stepwise teleports landing within pdd of successive stale waypoints | idx advanced per strict-< on live pos: (-0.1,0,0.5)→idx1, (1.95,0,0.95)→idx2 (pdd 0.4, off-mesh spawn held idx 0); multi-pop in ONE update | `idx`, `next`; spawn (-0.5,0,0.5) w/ pdd 0.4 holds idx=0 (euclid→p0 0.5) — clean stepwise ladder |
| (b) non-decrement | teleport back along the path | idx NEVER decreases: back to S or off-mesh spawn → stays 2 | `idx` post-backstep |
| (c) latch under motion | fire reached (tp within tdd), drift away | `fin_wall`/`fin_latch` (r72) + re-measured: `fired` rch/fin=true, `drift`→S still true; off-mesh (10,0,10) still true | `reached`, `finished` post-drift |
| (c) unreachable-clause latch | pdd 3.0, off-mesh T (0.5,0,3.0): finished without reached | settle fin=true; drift to (0,0,0) (euclid→final 3.606>3.0): fin STAYS true | `finished` after leaving the pdd gate |
| (c) unlatch condition | re-assign `target_position` (SAME value) | rch/fin cleared AT CALL TIME (`rt_f0`: rch=false fin=false, npath=0, stale idx residue); no early-out on identical value — the ONLY unlatch measured | rt arm: `reached`/`finished`/`npath` at the instant of re-assign |
| (c) freeze side-effect | fire finished, then tp onto an unpopped waypoint | idx stuck at 1 standing ON path[1] (euclid 0.05<pdd) — pop loop frozen | `idx` while on a live waypoint post-finish |
| (d) re-anchor mid-path | re-assign same/new target at scripted positions | p0 = CLAMPED live pos: on-mesh (2.0,0,1.05)→p0 (2,0,1.05) exact-ish (±2e-6, e.g. p0=2.5,0,3.900002); new path 2 pts; idx re-pops on new array | `path[0]`, `npath`, `next`, `final` |
| (d) bank-side boundary | island, T2 unreachable; tp to z down the void, re-assign T2 at each z | z≤4.50 → p0 (2.5,0,4.0) B-side, final (2.5,0,4.0), reachable=false (euclid→T2 1.5>tdd); z≥4.51 → p0 (2.5,0,5.0) C-side, path [(2.5,0,5.0),(2.5,0,5.5)], reachable=TRUE; **tie at z=4.50 → mainland bank** | `p0` bank + `reachable` flag flip — the two-bank geometry makes re-query-from-live observable, not just path[0]-shifts |
| — | not-yet-synced signature | read before first update: npath=0, next=own pos, final=(0,0,0), reach=false | arm guard — always trigger-update before asserting |

Numbers to reuse verbatim in arm dicts: frozen-path ladder above; latch
chain `fired` (2.2,0,3.2; dist 0.424264) → `onwp` (2.0,0,1.05; idx stays 1)
→ `rt` (same T; npath 0→2, p0 2,0,1.05) → `drift` to S (rch/fin false);
bank sweep p0 4.0→5.0 flip between z=4.50 and z=4.51.

## (5) Waitpoints needed

| moment | minimum measured | recommendation |
|---|---|---|
| initial settle after map+region+agent+target | ~5 physics frames for region sync (`probe_settle` f5) | keep fixture's 30 — cheap insurance, unchanged |
| post-teleport → readouts | **0 frames** — eval is call-time on live transform via a triggering getter | 1-2 frames per step for staged clarity; 5 matches r72 convention |
| post-reassign → path array | 0 frames IF a triggering getter precedes the path read in the same call sequence (`rt_afternext` npath=2 instantly) | `_read_state` already orders next-first; keep it |
| read-order rule | — | in every state capture, call `get_next_path_position()` (or fin/final/reach) BEFORE reading `path`/`idx`/`reached`, else stale commit |

## Confidence and remaining unknowns

High confidence (measured on this build, deterministic re-run): lazy-update
model + trigger/non-trigger getter sets; frozen path under off-mesh and
cross-void motion; strict-< multi-pop non-decrement; double-latch +
finished-freezes-update (incl. blocked reached eval); unlatch = any
`target_position` re-assignment incl. same-value; bank-side re-anchor with
measured z∈(4.50,4.51] boundary and mainland tie-break; zero-frame
post-reassign resolution; empty-path pre-sync signature.

Gaps (unprobed — flag if the author wants them):
- WHY `is_target_reached` is a pure reader while its sibling flags
  trigger the update — engine code-path detail, observed not explained;
  engine-source check would settle it.
- Whether the finished-freeze is a whole-update early-out or per-clause
  skip — composite behavior measured, internals not separated.
- Avoidance path (`agent.velocity`, `velocity_computed`), RVO coupling —
  unprobed; claims are transform-driven-motion only.
- Whether map/region/link MUTATION mid-path re-queries (r72 open gap —
  still open; only target_position re-assignment probed as trigger).
- Tie-break rule at exactly-equidistant closest points (z=4.50 chose B;
  the selection order over polygons is engine-internal).
- Multi-region re-anchor, `path_max_distance`, `simplify_path`,
  `path_height_offset`, non-Y-up motion — unprobed.
- `p0` epsilon: on-mesh re-anchor lands at live pos ±~2e-6
  (2.5,0,3.900002 observed); arms should use POS_TOL, never byte equality.

## Receipts index (this lane)

- `corpus/live/r74-scout/scratch/navagent3d_motion_probe.gd` sha256
  `9eb0d175c676972194f9848140b732ae4ccc334abbbb12dcdaf696964dde5c82`
- `corpus/live/r74-scout/scratch/project.godot` sha256 `1fda90d4…`
  (byte-identical copy of the fixtures seed)
- `corpus/live/r74-scout/runs/probe_{frozen,noframe,steps,latch,
  latch_unr,reanchor,getorder,triggers,settle}.stdout.txt` — all exit 0,
  stderr empty; reanchor re-run byte-identical
- Report-only lane: nothing tracked was modified; seeds untouched.
