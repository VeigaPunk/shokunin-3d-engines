# game-dev-3d round 75 — frozen before-state baseline (seat: baseline)

Baseline replay for the r75 move: pin server-side map/link MUTATION under
a committed path on the detour fixture — once a path materializes and
latches, does mutating the map (disable/enable the off-mesh link, change
`navigation_layers` on link or agent, delete/recreate the region,
`region_set_transform`) invalidate the stored path lazily, leave a
traversable dead-gate waypoint, or update on the next forcing call. The
declared falsifiable claim: the stored path is invalidated by map
mutation, forcing-call-gated per the r74 lazy-update model; r74-critic
probes `fw_mapedit`/`fw_layermask` measured EMPTY path + final=(0,0,0)
on map edits and are the arms to land as tracked CASES rows. This report
records only the frozen before-state at canonical `HEAD`; no fixture
authored here. Canonical repo `~/Projects/shokunin/game-dev-3d-shokunin`
(the `~/Projects/prymeagnt/game-dev-3d` path in the brief is the stale
predecessor; canonical reached via its `.shokunin/game-dev-3d` symlink).

Environment: `/usr/bin/godot` = `4.7.2.stable.arch_linux.ed1daf0bf`
(matches the r73/r74-verifier-pinned build), Python 3.14.7, Node v24.21.0,
three.js 0.186.1.

## Frozen tree

    git -C ~/Projects/shokunin/game-dev-3d-shokunin archive HEAD | tar -x -C \
      corpus/live/r75-baseline/frozen

- Frozen commit: `35a911cfa108be1a6ee7e2a133eca38c763990af`
  (`35a911c r74 report-last: adjudication + lesson + verifier AGREE 6/6`),
  which contains the r74-admitted 145-row battery (127 r73 rows + 18
  moving-agent `mv_*` arms from `fc9915e`). No r75 content is committed
  at freeze time.
- `git status --porcelain` on the canonical repo at dispatch: **clean**
  (0 entries). Post-replay status: 1 entry, `?? reports/round-74/
  r74-boundary.md` — a sibling r74 lane's untracked report, not mine;
  every write of this seat is confined to gitignored `corpus/live/`
  (`corpus/.gitignore: live/`; `git check-ignore corpus/live/r75-baseline`
  confirms) plus this report path.
- Archive carries tracked files only: no `.git`, no `corpus/live/` state,
  no prior `r*-baseline` trees, no `node_modules` (verified: `find
  frozen -name node_modules -o -name 'r*-baseline' -o -name .git` → 0
  hits).
- `corpus/fixtures/three/node_modules` is gitignored; frozen tree
  provisioned with `npm ci` inside `frozen/corpus/fixtures/three` →
  `added 1 package, and audited 2 packages` (three@0.186.1 per tracked
  lockfile; `node_modules/three/package.json` version field confirms).
- Frozen seed digests, each verified byte-identical to the `git show
  35a911c:` blob:
  - `navagent3d_detour.gd` sha256
    `336898f4b711021a21e619385244e662168889ba5c52ec6812af9c5034601276`
    (changed from r74's `0ae04750…` — the committed r74 moving-agent
    landing)
  - `project.godot` `1fda90d46b0529aea0e75710a64f038cbf983adc8385285dd8bbe6202a8eac23`
    (unchanged since r72)
  - `run_battery.py` `697b3d5fa0dcab147ee79016354e07dee52e6820777508cca237b27385f70f86`
    (changed from r74's `9f18a711…` — the r74 CASES-table growth
    127→145; 55 `--arm=` entries)

## Godot battery — frozen tree — PASS 145/145 + 4 probes

Command (run from the frozen tree root, `--runs` **absolute** per the
r72-verifier-documented relative-path trap):

    python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
      --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r75-baseline/runs \
      --probe-failing --probe-crash-exit --probe-stream-attribution --probe-tree-timeout

Receipt `runs/20261014T050310010897Z/verdicts.json`:

- `verdict`: **PASS**; `godot_version` `4.7.2.stable.arch_linux.ed1daf0bf`,
  battery invocation exit 0.
- `totals`: `cases=145 pass=145 fail=0 ordinary=100 negative_controls=45
  probes=4` — **145/145 PASS**.
- `seeds_unchanged`: `true`; 52 seed digests, **byte-identical** to the
  r74-verifier receipt (see drift section).
- Probes 4/4: `crash_probe_ok=true`, `stream_probe_ok=true`,
  `tree_probe_ok=true` — witness `pid 1948856` `witness_verified=true`,
  `witness_gone=true`, `witness_cleanup="SIGTERM to verified detached
  witness"`; `ps` post-run shows no leaked witness (0 `hold-open`
  processes). Mutation probe (`--probe-failing`): `detected=true`,
  `seeds_unchanged=true` — mutant `body3d_contact` rejected with the
  expected contact-plane diagnostic (`exit 1 != expected 0`,
  `final_z=3.500 expected=2.500`, marker absent).

## Drift vs r74 verifier receipt — ZERO

Tuple comparison of every row in my fresh receipt against
`corpus/live/runs/20261014T044234729734Z/verdicts.json` (the r74
verifier's 145-row passing absolute-`--runs` run on `fc9915e`) on the
12-field tuple `case, script, flags, expected_exit, actual_exit, kind,
marker, verdict, reasons, stdout, stderr, error` (excluding run-specific
`command`, `elapsed_seconds`):

- rows: 145 vs 145 — **missing in new: none; added in new: none**
- **field mismatches: 0 over 145 rows × 12 fields**
- `seed_digests`: 52 keys each, **zero digest differences**
- `totals` identical; same godot build string; probe flags equal
  (`crash/stream/tree/failing=true` both sides).

The frozen `35a911c` tree replays the committed r74 battery with
bit-for-bit row equality against the independent r74 verification. The
commit between the r74 content commit `fc9915e` and `35a911c` is the
adjudication landing (LOG/SCORECARD/lesson/reports only), so zero fixture
drift is the expected and observed outcome.

## r75 anchor rows — before-state the map-mutation arms must preserve

All 70 nav-family rows pass with stdout verbatim-equal to r74 — 50
`navagent3d_detour*` base/pop/finish rows, 15 `link_*` rows, 18 `mv_*`
rows (overlap: the detour arm rows partition into these), plus
`navagent3d_{follow,next,distance,retarget}` and `navigation3d_path*`.
Key anchors (verbatim marker tails from
`runs/20261014T050310010897Z/verdicts.json`):

- `navagent3d_detour`: `distance=3.605551 semantic=euclidean
  final=2.500,0.000,3.500 next=2.000,0.000,1.000 pathlen=4.130649
  reachable=true reached=false finished=false`
- `navagent3d_detour_link_shortcut` (link used): `idx=1
  next=1.500000,0.000000,0.500000 final=2.500000,0.000000,3.500000
  dist=3.605551 pathlen=4.192582 reachable=true … link=server`
- `navagent3d_detour_link_disabled` (authoring-time gate drops link):
  `idx=1 next=2.000000,0.000000,1.000000 final=2.500000,0.000000,4.000000
  dist=5.385165 pathlen=4.622520 reachable=false … link=server`
- `navagent3d_detour_link_layers_off` (authoring-time layer mask):
  `idx=1 next=2.000000,0.000000,1.000000 final=2.500000,0.000000,3.500000
  dist=3.605551 pathlen=4.130649 reachable=true …`
- `navagent3d_detour_mv_walk` (r74 stepwise locomotion): `steps=3
  idxs=1,2,2 next=2.500000,0.000000,3.500000 final=2.500000,0.000000,
  3.500000 dist=0.500000 pathlen=4.130649 reachable=true reached=true
  finished=true`
- `navagent3d_detour_mv_reanchor_lazy` (lazy re-anchor): `steps=2
  idxs=2,1 next=2.900000,0.000000,3.900002 final=2.900000,0.000000,
  3.900002 dist=1.923539 pathlen=1.923540 …`
- `navagent3d_detour_mv_latch` (reach/finish latch): `steps=2 idxs=1,1
  next=2.000000,0.000000,3.000000 final=2.000000,0.000000,3.000000
  dist=11.800424 pathlen=0.000000 reachable=true reached=true
  finished=true`
- `navagent3d_retarget`: `callbacks=120 before=1.730676,0.000,1.730676
  after_end=1.000,0.000,3.000 final=1.000,0.000,3.000`
- `navigation3d_path`: `points=2 start=1.000,0.000,1.000
  end=3.000,0.000,3.000 region_active=true`

**Post-materialization map/link mutation is greenfield in the
before-state** — traced in `frozen/corpus/fixtures/navagent3d_detour.gd`:

- `agent.target_position` is assigned once (line 241), followed by a
  30-frame settle, then the path read (`get_next_path_position`,
  `get_current_navigation_path`, lines 244–246). All link/region
  mutators — `NavigationServer3D.link_set_enabled`,
  `link_set_navigation_layers`, `link_set_bidirectional`,
  `link_set_enter_cost`, `link_set_travel_cost`,
  `region_set_map`, `region_set_navigation_mesh` — execute ONLY in the
  authoring block (lines 189–223), strictly BEFORE target assignment.
  Gate-honesty readback (lines 291–303) asserts authored flags are in
  effect; no second mutation pass exists.
- The only post-query actuation is `_run_steps` (lines 1225–1235), whose
  step vocabulary is exactly `set_target`, `tp`, `wait` — agent-target
  and actor-position keys only. No step key mutates the map, link,
  region transform, layers, or enabled state (`disabled`/`linklayers`/
  `oneway`/`entercost`/`travelcost` are consumed once at authoring; a
  `free_rid` at line 384 is teardown inside `_cleanup`). `region` and
  `link_rid`/`link_node` handles are in scope at `_run_link_arm`
  (line 1136) but are only READ there (gate honesty + `rid_at`/`own_at`
  assertions) — never re-mutated post-latch.
- The r73 `link_disabled`/`link_layers_off` rows therefore pin
  PRE-materialization gating (path never crosses the link), not the r75
  question of mutation AFTER the path has materialized and latched.
- The r74-critic probes that measured the actual post-latch semantics —
  unlanded, scratch-only (`corpus/live/r74-critic/runs/`):
  - `fw_mapedit`: `region_set_transform(+5x)` mid-run → next forcing
    call re-queries: `moved idx=1/0 next=5.000000,0.000000,0.500000
    final=5.000000,0.000000,1.000000 dist=3.605551 npath=2
    path=[(5,0,0.5)(5,0,1)] pathlen=0.500000 reachable=false
    pathsame=false`
  - `fw_layermask` (region layers→2 vs agent mask 1) → `masked idx=1/0
    next=0.500000,0.000000,0.500000 final=0.000000,0.000000,0.000000
    dist=3.605551 npath=0 path=[] pathlen=0.000000 reachable=false
    pathsame=false`
  Both show the stored path NOT surviving a map edit past the next
  forcing call (lazy requery semantics consistent with the r74
  lazy-update model — the declared r75 claim's prediction). The dead-gate
  / stale-waypoint alternative remains unpinned on the committed
  surface.

## Node three.js suites — frozen tree — 31/31

Run from `frozen/corpus/fixtures/three` (post `npm ci`) with
`--receipt …/r75-baseline/receipts/run_<suite>.json`; every runner exited
0 with `seeds_unchanged=true`. Verbatim tails:

    node run_cases.mjs        → PASS three battery: 3/3, seeds_unchanged=true        exit=0
    node run_layer_cases.mjs  → PASS three layer battery: 4/4, seeds_unchanged=true  exit=0
    node run_order_cases.mjs  → PASS three order battery: 9/9, seeds_unchanged=true  exit=0
    node run_camera_cases.mjs → PASS three camera battery: 5/5, seeds_unchanged=true exit=0
    node run_ortho_cases.mjs  → PASS three ortho battery: 5/5, seeds_unchanged=true  exit=0
    node run_ray_cases.mjs    → PASS three ray battery: 5/5, seeds_unchanged=true    exit=0

**Total 31/31**; receipts at `corpus/live/r75-baseline/receipts/run_*.json`.

## Before-state summary

| surface | result |
|---|---|
| Godot battery | PASS 145/145 (100 ordinary + 45 negative) + 4 probes PASS, seeds_unchanged=true |
| Row tuples vs r74-verifier | 0 mismatches / 145 rows × 12 fields; 52 seed digests byte-identical |
| Node six suites | PASS 31/31 (3+4+9+5+5+5), all seeds_unchanged=true |
| Post-latch map/link mutation on detour | none exists — mutation setters are authoring-time only; `_run_steps` vocabulary is `set_target`/`tp`/`wait` only; r75 axis greenfield |

The r75 author starts from a fully green frozen state at `35a911c` whose
145 rows are byte-identical to the r74-verified battery. Any mutation arm
that perturbs an existing row's tuple is measurable drift against this
receipt pair; the unlanded `fw_mapedit`/`fw_layermask` probe outputs
above are the expected-value candidates for the new arms.

## Receipts / scratch (all inside write scope)

- `corpus/live/r75-baseline/frozen/` — frozen `35a911c` tree (+ gitignored
  `node_modules` via `npm ci`)
- `corpus/live/r75-baseline/runs/20261014T050310010897Z/` — verdicts.json,
  crash-exit/stream-attribution/tree-timeout verdicts, mutation-verdicts,
  scratch + mutation-scratch dirs
- `corpus/live/r75-baseline/receipts/run_{cases,layer_cases,order_cases,
  camera_cases,ortho_cases,ray_cases}.json` — six Node suite receipts

## Limits

- Single replay per surface; zero failures, no flake-retry needed.
- Host intermittence caveat carried from r68/r69 (`navagent3d_retarget`)
  did not manifest in this run.
- This baseline asserts nothing about post-latch map/link mutation
  semantics — no committed detour-fixture arm exercises it; it only pins
  the pre-move surface the r75 arms must not regress. The `fw_*` numbers
  quoted are r74-critic scratch probes, not battery receipts.
