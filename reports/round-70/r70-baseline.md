# game-dev-3d round 70 — frozen before-state baseline (seat: baseline / scout)

Baseline replay for the r70 depth move (`navagent3d_detour.gd`: discriminate
`NavigationAgent3D.distance_to_target` Euclidean vs path-sum). This report
records only the frozen before-state at `HEAD`; no fixture authored here.

## Frozen tree

    git -C ~/Projects/shokunin/game-dev-3d-shokunin archive HEAD | tar -x -C \
      .shokunin/game-dev-3d/corpus/live/r70-baseline/tree

- Frozen commit: `e054cfee74dea96cfd21cfbbfc9fdd4ac74a426b`
  (`e054cfe Revert "HOURS.md: craft-hours ledger opened (§Craft-hours canon)"`),
  the commit that contains the r69-verified state.
- `git status --porcelain` on the live repo at dispatch: clean (no output).
- `corpus/fixtures/three/node_modules` is gitignored; the frozen tree was
  provisioned with `npm ci` inside
  `tree/corpus/fixtures/three` → `added 1 package` (three@0.186.1 per the
  tracked lockfile; package.json/package-lock.json seed digests are
  computed by the runners from tracked files, which `npm ci` never writes).

## Godot battery — frozen tree — PASS 85/85 + 4 probes

Command (run from the frozen tree root):

    python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
      --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r70-baseline/runs \
      --probe-failing --probe-crash-exit --probe-stream-attribution --probe-tree-timeout

Note: `--runs` passed in absolute form resolving to
`.shokunin/game-dev-3d/corpus/live/r70-baseline/runs`, per the r69 caveat
that a relative `--runs` path produced a tree-timeout witness failure
(`witness_verified=false`).

Runner tail, verbatim:

    totals: cases=85 pass=85 fail=0 ordinary=42 negative_controls=43 probes=4
    PASS battery: /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r70-baseline/runs/20261013T215959381187Z/verdicts.json

Receipt `runs/20261013T215959381187Z/verdicts.json`, verbatim fields:

- `godot_version`: `4.7.2.stable.arch_linux.ed1daf0bf`,
  `godot_version_exit`: 0
- `started_utc`: `20261013T215959381187Z`; `case_timeout_seconds`: 20
- `results`: 85 rows — `Counter({'PASS': 85})`;
  `Counter({'negative_control': 43, 'ordinary': 42})`
- `seeds_unchanged`: `true`; 51 seed digests (r69's
  `navagent3d_distance.gd` present, sha256
  `b820e469c35e68cf60d3f87bda94c1968cbc9b943b78513a6bf61bd0761c803a`;
  `run_battery.py` `b992c7a5f135b2e4fd83104eae41deaaf93f4e7c74ea5af2361b3a8a650b46ea`)
- Probes: `crash_probe_ok=true`, `stream_probe_ok=true`,
  `tree_probe_ok=true`; `probe_failing` → `mutation-verdicts.json`:
  `detected=true`, `seeds_unchanged=true` (scratch mutation
  `body3d_slide.gd` BOX_SIZE 4.0→6.0 rejected with expected diagnostic).
- r69 distance marker reproduced on the frozen tree, verbatim stdout row:
  `PASS navagent3d_distance distance=2.828427 final=3.000,0.000,3.000 next=3.000,0.000,3.000 reached=false reachable=true finished=false`

## Node three.js suites — frozen tree — 31/31

Provisioned `npm ci` in `tree/corpus/fixtures/three` (see above). Commands
run from that directory; every runner exited 0 with
`seeds_unchanged=true`. Verbatim tails:

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
| Godot battery | PASS 85/85 (42 ordinary + 43 negative) + 4 probes PASS, seeds_unchanged=true |
| Node six suites | PASS 31/31 (3+4+9+5+5+5), all seeds_unchanged=true |

The r70 author starts from a fully green frozen state at `e054cfe`. The
r69 UNKNOWN this round's depth move targets is confirmed live in the
baseline: `navagent3d_distance` measures `distance=2.828427` (= sqrt(8)
for (1,0,1)→(3,0,3)) on a convex 4x4 nav polygon where Euclidean and
path-sum coincide, so it cannot discriminate the two semantics.

## Receipts / scratch (all inside write scope)

- `corpus/live/r70-baseline/tree/` — frozen HEAD tree (+ gitignored
  `node_modules` via `npm ci`)
- `corpus/live/r70-baseline/runs/20261013T215959381187Z/` — battery
  verdicts.json, probe verdicts, scratch, mutation scratch

## Limits

- Single replay per surface; no flake-retry needed (zero failures).
- Host intermittence caveat carried from r68/r69 (`navagent3d_retarget`
  SDL-stderr / numeric-drift modes) did not manifest in this run.
- This baseline asserts no claim about `navagent3d_detour.gd` (not yet
  authored) and makes no cross-engine or rendering claim.
