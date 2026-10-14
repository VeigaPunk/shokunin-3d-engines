# game-dev-3d round 72 — frozen before-state baseline (seat: baseline / scout)

Baseline replay for the r72 depth move: formalize the
`path_desired_distance` (pdd) waypoint-pop semantics and the two-mode
`is_navigation_finished` the r71 boundary seat measured. Established by
scratch: pdd pops path waypoints by Euclidean distance to the AGENT
position (not path-sum), saturating at the last index; `is_navigation_finished`
is two-mode — reachable: `euclid(agent, raw target) < target_desired_distance`
(strict); unreachable: `euclid(agent, clamped final) <= ~pdd`. Declared
claim: pin pdd pop-point index vs agent position as tracked arms on the
L-corridor, plus the two `is_navigation_finished` modes with
equality-edge cases. This report records only the frozen before-state at
`HEAD`; no fixture authored here.

## Frozen tree

    git -C ~/Projects/shokunin/game-dev-3d-shokunin archive HEAD | tar -x -C \
      .shokunin/game-dev-3d/corpus/live/r72-baseline/tree

- Frozen commit: `996ea376f1e5d7cc8be38429f7f97f1a8b7018c7`
  (`996ea37 game-dev-3d r71 adjudication: ADMIT — LOG/SCORECARD/verifier
  +adjudicator reports + lesson`), the commit that contains the
  r71-admitted `navagent3d_detour.gd` postprocessing arms.
- `git status --porcelain` on the live repo at dispatch: clean (no
  output).
- `corpus/live/` is gitignored — the archive carries no prior run state.
- `corpus/fixtures/three/node_modules` is gitignored; the frozen tree was
  provisioned with `npm ci` inside
  `tree/corpus/fixtures/three` → `added 1 package, and audited 2
  packages` (three@0.186.1 per the tracked lockfile; runner seed digests
  are computed from tracked files, which `npm ci` never writes).

## Godot battery — frozen tree — PASS 90/90 + 4 probes

Command (run from the frozen tree root):

    python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
      --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r72-baseline/runs \
      --probe-failing --probe-crash-exit --probe-stream-attribution --probe-tree-timeout

`--runs` passed in absolute form per the r69 caveat (relative `--runs`
produced a tree-timeout witness failure). Node suites accept `--receipt`,
not `--runs`; receipts went to `corpus/live/r72-baseline/receipts/`.

Runner tail, verbatim:

    PASS crash-exit probe: /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r72-baseline/runs/20261014T003555854844Z/crash-exit-verdicts.json
    PASS stream-attribution probe: /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r72-baseline/runs/20261014T003555854844Z/stream-attribution-verdicts.json
    PASS tree-timeout probe: /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r72-baseline/runs/20261014T003555854844Z/tree-timeout-verdicts.json
    PASS     mutant_body3d_contact              body3d_slide.gd            (scratch mutation) -/1       probe
    totals: cases=90 pass=90 fail=0 ordinary=45 negative_controls=45 probes=4
    PASS battery: /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r72-baseline/runs/20261014T003555854844Z/verdicts.json

Receipt `runs/20261014T003555854844Z/verdicts.json`, verbatim fields:

- `godot_version`: `4.7.2.stable.arch_linux.ed1daf0bf`,
  `godot_version_exit`: 0
- `started_utc`: `20261014T003555854844Z`; `case_timeout_seconds`: 20
- `results`: 90 rows — `Counter({'PASS': 90})`;
  `Counter({'negative_control': 45, 'ordinary': 45})`
- `seeds_unchanged`: `true`; 52 seed digests (r71's
  `navagent3d_detour.gd` present, sha256
  `5b873cd06a8f50cb98a97764eb914e2a80f8553edb9ae216543979624d531647`;
  `run_battery.py`
  `b4b314997177c0a53ebd9cdf1f94f4ba91f3e7e7d774f4f4154e9169b1513809`)
- Probes: `crash_probe_ok=true`, `stream_probe_ok=true`,
  `tree_probe_ok=true`; `probe_failing` → `mutation-verdicts.json`:
  `verdict=PASS`, `detected=true`, `seeds_unchanged=true` (scratch
  mutation `body3d_slide.gd` BOX_SIZE 4.0→6.0 rejected with expected
  diagnostic `body did not stop at the contact plane final_z=3.500
  expected=2.500`).

## r72 anchor rows — reproduced verbatim on the frozen tree

The exact before-state values the r72 pdd / `is_navigation_finished`
arms must compare against. The L-corridor detour fixture keeps agent
stationary at spawn (0.5,0,0.5), target (2.5,0,3.5); it never sets
`path_desired_distance` or `target_desired_distance` (engine defaults,
both 1.0 on this build — `grep -rn path_desired` over the frozen
fixtures returns no hits, so the r72 axis is greenfield on this
surface):

- `navagent3d_detour` (ordinary, exit 0, corridorfunnel):
  `PASS navagent3d_detour distance=3.605551 semantic=euclidean final=2.500,0.000,3.500 next=2.000,0.000,1.000 pathlen=4.130649 reachable=true reached=false finished=false`
- `navagent3d_detour_post_edgecentered` (ordinary, exit 0):
  `PASS navagent3d_detour post_edgecentered distance=3.605551 semantic=euclidean final=2.500,0.000,3.500 next=2.000,0.000,0.500 pathlen=4.707107 reachable=true reached=false finished=false`
- `navagent3d_detour_post_none` (ordinary, exit 0):
  `PASS navagent3d_detour post_none distance=3.605551 semantic=euclidean final=2.500,0.000,3.500 next=2.000,0.000,0.500 pathlen=4.549510 reachable=true reached=false finished=false`
- `navagent3d_detour --straight` (negative, exit 2):
  `NEGATIVE REJECTED: navagent3d_detour straight distance=2.828427 euclid=2.828427 pathlen=2.828427 discriminates=false`
- `navagent3d_detour --assert-pathsum` (negative, exit 2):
  `NEGATIVE REJECTED: navagent3d_detour assert_pathsum distance=3.605551 expected_pathsum=4.130649 euclid=3.605551`
- `navagent3d_distance` (ordinary, exit 0, tdd default 1.0):
  `PASS navagent3d_distance distance=2.828427 final=3.000,0.000,3.000 next=3.000,0.000,3.000 reached=false reachable=true finished=false`
- `navagent3d_distance --wide-reach` (negative, exit 2, tdd=3.0 >
  euclid 2.828427):
  `NEGATIVE REJECTED: navagent3d_distance wide_reach distance=2.828427 reached=true finished=true reachable=true`
- `navagent3d_next` (ordinary, exit 0, single-segment path — pop
  saturates to the last index so `next` already equals path end):
  `PASS navagent3d_next path_end=3.000,0.000,3.000 next=3.000,0.000,3.000`
- `navagent3d_next_alternate` (negative, exit 2):
  `NEGATIVE REJECTED: navagent3d_next alternate path_end=3.000,0.000,1.000 next=3.000,0.000,1.000`

Read against the declared claim: under default pdd=1.0 the stationary
spawn at (0.5,0,0.5) is Euclidean-far from every L-corridor waypoint
(spawn→(2,0,1) = √2.5 ≈ 1.581 > 1.0), so no waypoint pops and `next`
is the first corridor vertex — `2,0,1` corridorfunnel / `2,0,0.5`
edgecentered·none. Those three `next` values are the index-0 anchors
the pdd-sweep arms vary agent offset against: an agent moved within
pdd of a waypoint should pop it and shift `next` to the following
index; the saturation claim predicts the final point `2.5,0,3.5` (=
`get_final_position`) is always reachable through the pop loop. The
two `is_navigation_finished` modes are anchored by
`navagent3d_distance` (reachable=true, finished=false at
euclid 2.828 > tdd 1.0) and its `--wide-reach` negative (finished=true
at euclid 2.828 < tdd 3.0); the equality edge `euclid == tdd` is the
unmeasured gap the r72 arm adds — reachable-mode is claimed strict `<`,
so equality should give finished=false.

## Node three.js suites — frozen tree — 31/31

Provisioned `npm ci` in `tree/corpus/fixtures/three` (see above).
Commands run from that directory with
`--receipt …/r72-baseline/receipts/run_<suite>.json`; every runner
exited 0 with `seeds_unchanged=true`. Verbatim tails:

    node run_cases.mjs        → PASS three battery: 3/3, seeds_unchanged=true        exit=0
    node run_layer_cases.mjs  → PASS three layer battery: 4/4, seeds_unchanged=true  exit=0
    node run_order_cases.mjs  → PASS three order battery: 9/9, seeds_unchanged=true  exit=0
    node run_camera_cases.mjs → PASS three camera battery: 5/5, seeds_unchanged=true exit=0
    node run_ortho_cases.mjs  → PASS three ortho battery: 5/5, seeds_unchanged=true  exit=0
    node run_ray_cases.mjs    → PASS three ray battery: 5/5, seeds_unchanged=true    exit=0

Suite composition (case names, all PASS): run_cases
positive/negative_wrong_order/mutation; run_layer_cases
default/far_only/both/mutate_far_layer; run_order_cases
ordered/near_off_axis/near_clip/far_clip/near_boundary/far_boundary/
swap_depths/mutate_near_clip/mutate_near_boundary; run_camera_cases
inside/far_outside/near_outside/mutate_far/mutate_near; run_ortho_cases
inside/far_outside/near_outside/mutate_far/mutate_near; run_ray_cases
hit/lateral_miss/backface/mutate_offset/double_side.

## Before-state summary

| surface | result |
|---|---|
| Godot battery | PASS 90/90 (45 ordinary + 45 negative) + 4 probes PASS, seeds_unchanged=true |
| Node six suites | PASS 31/31 (3+4+9+5+5+5), all seeds_unchanged=true |

The r72 author starts from a fully green frozen state at `996ea37` that
already contains the r71-admitted detour postprocessing arms (90 rows =
88 prior + 2 post arms). The r72 declared claim is anchored live:
default pdd=1.0 leaves all corridor waypoints unpopped from spawn —
`next=2,0,1` (corridorfunnel) / `next=2,0,0.5` (edgecentered, none) —
`final` pinned via `get_final_position=2.500,0.000,3.500`,
and `is_navigation_finished=false` under both reachable (`distance`
arm) and unreachable-but-unfinished (detour rows) states. Any pdd-sweep
arm that fails to move `next` falsifies the agent-position pop claim;
the equality-edge row decides reachable-mode strict `<`.

## Receipts / scratch (all inside write scope)

- `corpus/live/r72-baseline/tree/` — frozen HEAD tree (+ gitignored
  `node_modules` via `npm ci`)
- `corpus/live/r72-baseline/runs/20261014T003555854844Z/` — battery
  verdicts.json, crash-exit/stream-attribution/tree-timeout verdicts,
  mutation-verdicts.json, scratch + mutation-scratch dirs
- `corpus/live/r72-baseline/receipts/run_{cases,layer_cases,
  order_cases,camera_cases,ortho_cases,ray_cases}.json` — six Node
  suite receipts (verdict, per-case exits, seed digests)

## Limits

- Single replay per surface; no flake-retry needed (zero failures).
- Host intermittence caveat carried from r68/r69 (`navagent3d_retarget`
  SDL-stderr / numeric-drift modes) did not manifest in this run.
- This baseline asserts no claim about `path_desired_distance` behavior
  (the r72 arms are not yet authored): the "default 1.0" above is the
  engine default on this build, not a fixture-pinned value — no fixture
  currently sets pdd. No cross-engine or rendering claim.
