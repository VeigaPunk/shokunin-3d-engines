# game-dev-3d round 74 — frozen before-state baseline (seat: baseline)

Baseline replay for the r74 move: formalize MOVING-AGENT navigation
semantics as tracked CASES arms on the detour fixture — (a) stored path
array FROZEN at target-assignment while `distance_to_target`/`next_target`
stay live call-time arithmetic; (b) pop index follows live agent position
(teleported/stepwise-moving agent advances idx per the strict-< Euclidean
pop rule against the stale stored path); (c) reached/finished latch under
motion; (d) `target_position` re-assignment mid-path re-queries the map
from LIVE position. This report records only the frozen before-state at
canonical `HEAD`; no fixture authored here. Canonical repo
`~/Projects/shokunin/game-dev-3d-shokunin`, reached via worktree symlink
`~/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d`.

Environment: `/usr/bin/godot` = `4.7.2.stable.arch_linux.ed1daf0bf`
(matches the r73-verifier-pinned build), Python 3.14.7, Node v24.21.0,
three.js 0.186.1.

## Frozen tree

    git -C ~/Projects/shokunin/game-dev-3d-shokunin archive HEAD | tar -x -C \
      corpus/live/r74-baseline/frozen

- Frozen commit: `e435a018e856b5f7af4109de7becb0291398ecec`
  (`e435a01 game-dev-3d r73 adjudication: ADMIT — LOG/SCORECARD/lesson/
  verifier+scribe reports`), which contains the r73-admitted 127-row
  battery (112 r72 rows + 15 link-traversal arms from `b41fb33`). No r74
  content is committed at freeze time.
- `git status --porcelain` on the canonical repo at dispatch: **clean**
  (0 entries). Post-replay status: 1 entry, `?? reports/round-74/` —
  the sibling r74-reviewer lane's untracked report dir, not mine; every
  write of this seat is confined to gitignored `corpus/live/`
  (`corpus/.gitignore: live/`; `git check-ignore corpus/live/r74-baseline`
  confirms).
- Archive carries tracked files only: no `.git`, no `corpus/live/` state,
  no prior `r*-baseline` trees, no `node_modules` (verified: `find
  frozen -name node_modules -o -name 'r*-baseline' -o -name .git` → 0
  hits).
- `corpus/fixtures/three/node_modules` is gitignored; frozen tree
  provisioned with `npm ci` inside `frozen/corpus/fixtures/three` →
  `added 1 package, and audited 2 packages` (three@0.186.1 per tracked
  lockfile).
- Frozen seed digests, each verified byte-identical to the `git show
  e435a01:` blob:
  - `navagent3d_detour.gd` sha256
    `0ae04750b2041ba17bfb1835c70c40ad182e116ab87069be7fec05b1e4835ce4`
    (changed from r73's `ea722a75…` — the committed link-arm landing)
  - `project.godot` `1fda90d46b0529aea0e75710a64f038cbf983adc8385285dd8bbe6202a8eac23`
    (unchanged since r72)
  - `run_battery.py` `9f18a711ff958abce08aad3b6db8e7f226c9a897beedc811023540cc61872860`
    (r73 CASES-table growth)

## Godot battery — frozen tree — PASS 127/127 + 4 probes

Command (run from the frozen tree root, `--runs` **absolute** per the
r72-verifier-documented relative-path trap):

    python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
      --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r74-baseline/runs \
      --probe-failing --probe-crash-exit --probe-stream-attribution --probe-tree-timeout

Receipt `runs/20261014T022543376829Z/verdicts.json`:

- `verdict`: **PASS**; `godot_version` `4.7.2.stable.arch_linux.ed1daf0bf`,
  battery invocation exit 0.
- `totals`: `cases=127 pass=127 fail=0 ordinary=82 negative_controls=45
  probes=4` — **127/127 PASS**.
- `seeds_unchanged`: `true`; 52 seed digests, **byte-identical** to the
  r73-verifier receipt (see drift section).
- Probes 4/4: `crash_probe_ok=true`, `stream_probe_ok=true`,
  `tree_probe_ok=true` — witness `pid 1575727` `witness_verified=true`,
  `witness_gone=true`, `witness_cleanup="SIGTERM to verified detached
  witness"` (the absolute-`--runs` convention works; `ps` post-run shows
  no leaked witness — only unrelated godot-mcp daemons and a sibling
  game-dev-2d lane's battery). Mutation probe (`--probe-failing`):
  `verdict=PASS`, `detected=true`, `seeds_unchanged=true` — mutant
  `body3d_contact` rejected with the expected contact-plane diagnostic
  (`exit 1 != expected 0`, marker missing, stderr error lines).

## Drift vs r73 verifier receipt — ZERO

Tuple comparison of every row in my fresh receipt against
`corpus/live/r73-verifier/runs/20261014T020933241302Z/verdicts.json` (the
r73 verifier's 127-row passing absolute-`--runs` run) on the 12-field
tuple `case, script, flags, expected_exit, actual_exit, kind, marker,
verdict, reasons, stdout, stderr, error` (excluding run-specific
`command`, `elapsed_seconds`):

- rows: 127 vs 127 — **missing in new: none; added in new: none**
- **field mismatches: 0 over 127 rows × 12 fields**
- `seed_digests`: 52 keys each, **zero digest differences**
- `totals` identical; same godot build string; probe flags equal
  (`crash/stream/tree=true` both sides).

The frozen `e435a01` tree replays the committed r73 battery with
bit-for-bit row equality against the independent r73 verification. The
commits between the r73 content commit `b41fb33` and `e435a01` are the
adjudication landing (LOG/SCORECARD/lesson/reports only), so zero fixture
drift is the expected and observed outcome.

## r74 anchor rows — before-state the moving-agent arms must preserve

All 50 `navagent3d_detour*` rows plus the `navagent3d_{follow,next,
distance,retarget}` and `navigation3d_path*` family — 52 nav-family rows
total — pass with stdout verbatim-equal to r73. Key anchors (verbatim
marker tails):

- `navagent3d_detour`: `distance=3.605551 semantic=euclidean
  final=2.500,0.000,3.500 next=2.000,0.000,1.000 pathlen=4.130649
  reachable=true reached=false finished=false`
- `navagent3d_detour_tp_mid`: `before_idx=1 after_idx=2
  next=2.500000,0.000000,3.500000 final=2.500000,0.000000,3.500000
  dist=3.036445 reachable=true reached=false finished=false`
- `navagent3d_detour_tp_eq`: `before_idx=1 after_idx=1
  next=2.000000,0.000000,1.000000 ... dist=3.535534 ... reached=false`
- `navagent3d_detour_fin_latch`: `before_idx=1 after_idx=1
  next=2.000000,0.000000,3.000000 final=2.000000,0.000000,3.000000
  dist=2.500000 reachable=true reached=true finished=true`
- `navagent3d_retarget`: `callbacks=120 before=1.730676,0.000,1.730676
  after_end=1.000,0.000,3.000 final=1.000,0.000,3.000`
- `navagent3d_detour_link_shortcut` (r73 link surface): `idx=1
  next=1.500000,0.000000,0.500000 ... pathlen=4.192582 reachable=true
  reached=false finished=false link=server meta=0 types=- ridat=-1 ...`

**Moving-agent surface is partially-greenfield in the before-state:**

- The `--arm=` mechanism already exists — `run_battery.py` CASES rows
  pass `--arm=<name>` to `navagent3d_detour.gd` (37 `--arm=` entries in
  the CASES table), whose fixture arm-dict keys include the r72 pop/
  finish/edge arms and r73 `link_*` arms. r74 presets are additive
  entries into this existing mechanism, not a new flag.
- In `navagent3d_detour.gd`, `agent.target_position` is assigned exactly
  once (`frozen/corpus/fixtures/navagent3d_detour.gd:185`), followed by a
  30-frame settle. Arms are then either read stationary (`st2 = st`,
  line 211) or perform a **single** post-settle teleport via the `tp`
  key (`actor.global_position = arm_cfg["tp"]` + 5 frames, lines
  205–209). No sequential/stepwise locomotion key exists (`steps`,
  multi-teleport, or velocity-driven motion absent — grep confirms `tp`
  is the only motion key, a lone Vector3).
- Mid-motion `target_position` **re-assignment** exists only on a
  different fixture: `navretarget3d_driver.gd:19` re-assigns once at tick
  35 while the actor locomotes via `move_toward(next, SPEED*delta)`
  (line 26); it pins endpoints/reached, not detour pop/latch semantics.
  `navfollow3d_driver.gd` likewise drives smooth locomotion. Neither
  touches the detour map.
- Therefore claims (a)–(d) pin new behavior on axes the detour fixture
  has never exercised under scripted stepwise motion; every existing row
  above is a keep-byte-stable regression anchor.

## Node three.js suites — frozen tree — 31/31

Run from `frozen/corpus/fixtures/three` (post `npm ci`) with
`--receipt …/r74-baseline/receipts/run_<suite>.json`; every runner exited
0 with `seeds_unchanged=true`. Verbatim tails:

    node run_cases.mjs        → PASS three battery: 3/3, seeds_unchanged=true        exit=0
    node run_layer_cases.mjs  → PASS three layer battery: 4/4, seeds_unchanged=true  exit=0
    node run_order_cases.mjs  → PASS three order battery: 9/9, seeds_unchanged=true  exit=0
    node run_camera_cases.mjs → PASS three camera battery: 5/5, seeds_unchanged=true exit=0
    node run_ortho_cases.mjs  → PASS three ortho battery: 5/5, seeds_unchanged=true  exit=0
    node run_ray_cases.mjs    → PASS three ray battery: 5/5, seeds_unchanged=true    exit=0

**Total 31/31**; receipts at `corpus/live/r74-baseline/receipts/run_*.json`.

## Before-state summary

| surface | result |
|---|---|
| Godot battery | PASS 127/127 (82 ordinary + 45 negative) + 4 probes PASS, seeds_unchanged=true |
| Row tuples vs r73-verifier | 0 mismatches / 127 rows × 12 fields; 52 seed digests byte-identical |
| Node six suites | PASS 31/31 (3+4+9+5+5+5), all seeds_unchanged=true |
| Stepwise-motion / mid-path retarget arms on detour | none exist yet — r74 axis greenfield on this fixture |

The r74 author starts from a fully green frozen state at `e435a01` whose
127 rows are byte-identical to the r73-verified battery. Any moving-agent
arm that perturbs an existing row's tuple is measurable drift against
this receipt pair.

## Receipts / scratch (all inside write scope)

- `corpus/live/r74-baseline/frozen/` — frozen `e435a01` tree (+ gitignored
  `node_modules` via `npm ci`)
- `corpus/live/r74-baseline/runs/20261014T022543376829Z/` — verdicts.json,
  crash-exit/stream-attribution/tree-timeout verdicts, mutation-verdicts,
  scratch + mutation-scratch dirs
- `corpus/live/r74-baseline/receipts/run_{cases,layer_cases,order_cases,
  camera_cases,ortho_cases,ray_cases}.json` — six Node suite receipts

## Limits

- Single replay per surface; zero failures, no flake-retry needed.
- Host intermittence caveat carried from r68/r69 (`navagent3d_retarget`)
  did not manifest in this run.
- This baseline asserts nothing about stepwise locomotion or mid-path
  retarget semantics — no detour-fixture arm exercises them yet; it only
  pins the pre-move surface the r74 arms must not regress.
