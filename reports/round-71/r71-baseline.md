# game-dev-3d round 71 — frozen before-state baseline (seat: baseline / scout)

Baseline replay for the r71 depth move: resolve whether
`NavigationAgent3D.path_postprocessing` changes the r70-established
Euclidean `distance_to_target` semantics. Declared claim: postprocessing
{edgecentered, none} leaves `distance_to_target` Euclidean-invariant while
changing `get_next_path_position`/`get_final_position` outputs. This report
records only the frozen before-state at `HEAD`; no fixture authored here.

## Frozen tree

    git -C ~/Projects/shokunin/game-dev-3d-shokunin archive HEAD | tar -x -C \
      .shokunin/game-dev-3d/corpus/live/r71-baseline/tree

- Frozen commit: `9458c183988c8428503b9287d51cd86f7a48378b`
  (`9458c18 game-dev-3d r70 adjudication: ADMIT depth — verifier report +
  lesson + LOG/SCORECARD`), the commit that contains the r70-admitted
  `navagent3d_detour.gd` state.
- `git status --porcelain` on the live repo at dispatch: clean (no output).
- `corpus/fixtures/three/node_modules` is gitignored; the frozen tree was
  provisioned with `npm ci` inside
  `tree/corpus/fixtures/three` → `added 1 package` (three@0.186.1 per the
  tracked lockfile; runner seed digests are computed from tracked files,
  which `npm ci` never writes).

## Godot battery — frozen tree — PASS 88/88 + 4 probes

Command (run from the frozen tree root):

    python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
      --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r71-baseline/runs \
      --probe-failing --probe-crash-exit --probe-stream-attribution --probe-tree-timeout

`--runs` passed in absolute form per the r69 caveat (relative `--runs`
produced a tree-timeout witness failure).

Runner tail, verbatim:

    totals: cases=88 pass=88 fail=0 ordinary=43 negative_controls=45 probes=4
    PASS battery: /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r71-baseline/runs/20261013T233444776454Z/verdicts.json

Receipt `runs/20261013T233444776454Z/verdicts.json`, verbatim fields:

- `godot_version`: `4.7.2.stable.arch_linux.ed1daf0bf`,
  `godot_version_exit`: 0
- `started_utc`: `20261013T233444776454Z`; `case_timeout_seconds`: 20
- `results`: 88 rows — `Counter({'PASS': 88})`;
  `Counter({'negative_control': 45, 'ordinary': 43})`
- `seeds_unchanged`: `true`; 52 seed digests (r70's
  `navagent3d_detour.gd` present, sha256
  `669c539d0bb38c82184f1b39df0a4d70059276e532def125438f352899a7fc45`;
  `run_battery.py`
  `5a7d6c13ac4a24960ce8f24bcc45b24a65da31919e78b5cc5934e3c248a79dee`)
- Probes: `crash_probe_ok=true`, `stream_probe_ok=true`,
  `tree_probe_ok=true`; `probe_failing` → `mutation-verdicts.json`:
  `detected=true`, `seeds_unchanged=true` (scratch mutation
  `body3d_slide.gd` BOX_SIZE 4.0→6.0 rejected with expected diagnostic
  `body did not stop at the contact plane final_z=3.500 expected=2.500`).

## r70 anchor rows — reproduced verbatim on the frozen tree

The exact before-state values the r71 postprocessing arm must compare
against (all under default `path_postprocessing` = corridorfunnel):

- `navagent3d_detour` (ordinary, exit 0):
  `PASS navagent3d_detour distance=3.605551 semantic=euclidean final=2.500,0.000,3.500 next=2.000,0.000,1.000 pathlen=4.130649 reachable=true reached=false finished=false`
- `navagent3d_detour --straight` (negative, exit 2):
  `NEGATIVE REJECTED: navagent3d_detour straight distance=2.828427 euclid=2.828427 pathlen=2.828427 discriminates=false`
- `navagent3d_detour --assert-pathsum` (negative, exit 2):
  `NEGATIVE REJECTED: navagent3d_detour assert_pathsum distance=3.605551 expected_pathsum=4.130649 euclid=3.605551`
- `navagent3d_distance` (ordinary, exit 0):
  `PASS navagent3d_distance distance=2.828427 final=3.000,0.000,3.000 next=3.000,0.000,3.000 reached=false reachable=true finished=false`
- `navagent3d_distance --wide-reach` (negative, exit 2):
  `NEGATIVE REJECTED: navagent3d_distance wide_reach distance=2.828427 reached=true finished=true reachable=true`

So under default postprocessing the before-state records
`distance_to_target=3.605551` (= √13, Euclidean to raw `target_position`
(2.5,0,3.5) from (0.5,0,0.5)), `next=2.000,0.000,1.000` (the corridor
portal vertex), `final=2.500,0.000,3.500`, routed `pathlen=4.130649`.
These are the discriminators the r71 arm varies postprocessing against:
invariance claim holds iff `distance` stays `3.605551` under
{edgecentered, none}; the claim's second half predicts `next`/`final`
change under at least one non-default value.

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
| Godot battery | PASS 88/88 (43 ordinary + 45 negative) + 4 probes PASS, seeds_unchanged=true |
| Node six suites | PASS 31/31 (3+4+9+5+5+5), all seeds_unchanged=true |

The r71 author starts from a fully green frozen state at `9458c18` that
already contains the r70-admitted detour fixture (88 rows = 85 prior + 3
detour cases). The r71 declared claim is anchored live: default
corridorfunnel yields `distance=3.605551`, `next=2.000,0.000,1.000`,
`final=2.500,0.000,3.500` — any measured change in `distance_to_target`
under a postprocessing arm falsifies invariance; unchanged `distance` with
changed `next`/`final` confirms both halves.

## Receipts / scratch (all inside write scope)

- `corpus/live/r71-baseline/tree/` — frozen HEAD tree (+ gitignored
  `node_modules` via `npm ci`)
- `corpus/live/r71-baseline/runs/20261013T233444776454Z/` — battery
  verdicts.json, crash-exit/stream-attribution/tree-timeout verdicts,
  mutation-verdicts.json, scratch dirs

## Limits

- Single replay per surface; no flake-retry needed (zero failures).
- Host intermittence caveat carried from r68/r69 (`navagent3d_retarget`
  SDL-stderr / numeric-drift modes) did not manifest in this run.
- This baseline asserts no claim about `path_postprocessing` behavior
  (the r71 arm is not yet authored) and makes no cross-engine or
  rendering claim.
