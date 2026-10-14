# game-dev-3d round 76 — frozen before-state baseline (seat: baseline)

Baseline replay for the r76 move: pin the same-turn setter→server-sync
WINDOW as tracked CASES — r75 measured the two-stage gate report-side
(~2–3 frames; a same-turn forcing call inside the setter→sync window
still serves the stale hop) but no CASES row pins the window itself.
Declared falsifiable claim: the sync boundary is frame-measurable — a
forcing call on the same tick as a RID mutation serves the pre-mutation
path while wait>=1 serves post-sync state; the exact frame count is a
stable measured constant on this host/build. New arms to land:
same-turn-mutation (mutate + forcing read at wait=0/1/2),
`map_set_active(false)` reachability, and same-value-mutation
suppression. This report records only the frozen before-state at
canonical `HEAD`; no fixture authored here. Canonical repo
`~/Projects/shokunin/game-dev-3d-shokunin` (the
`~/Projects/prymeagnt/game-dev-3d` path in the brief is the stale
predecessor; canonical reached via its `.shokunin/game-dev-3d` symlink).

Environment: `/usr/bin/godot` = `4.7.2.stable.arch_linux.ed1daf0bf`
(matches the r73/r74/r75-pinned build), Python 3.14.7, Node v24.21.0,
three.js 0.186.1.

## Frozen tree

    git -C ~/Projects/shokunin/game-dev-3d-shokunin archive HEAD | tar -x -C \
      corpus/live/r76-baseline/frozen

- Frozen commit: `cb6bf7b637a3857c3dcc354d4e267797e284f253`
  (`cb6bf7b r75 report-last: verifier AGREE 5/5 + adjudicator +
  map-mutation lesson + LOG/SCORECARD; fw_mapedit citation fix`), which
  contains the r75-admitted 156-row battery (145 r74 rows + 11
  `navagent3d_detour_mut_*` arms from `6498973`). No r76 content is
  committed at freeze time.
- `git diff cefc821..cb6bf7b --stat` (verified commit → freeze HEAD):
  6 files, +315/−3 — LOG.md, SCORECARD.md, two lesson files,
  r75-adjudicator.md, r75-verifier.md only; **zero fixture delta**, so
  the r75-verifier receipt carries to this freeze.
- `git status --porcelain` on the canonical repo at dispatch and
  post-replay: **clean** (0 entries). Every write of this seat is
  confined to gitignored `corpus/live/` (`git check-ignore
  corpus/live/r76-baseline` → ignored) plus this report path.
- Archive carries tracked files only: `find frozen -name node_modules -o
  -name .git -o -name 'r*-baseline' -o -name live` → **0 hits** (no
  `.git`, no `corpus/live/` state, no prior `r*-baseline` trees, no
  `node_modules`).
- `corpus/fixtures/three/node_modules` is gitignored; frozen tree
  provisioned with `npm ci` inside `frozen/corpus/fixtures/three` →
  `added 1 package, and audited 2 packages` (three@0.186.1 per tracked
  lockfile; `node_modules/three/package.json` `"version": "0.186.1"`
  confirms).
- Frozen seed digests, each verified byte-identical to the `git show
  cb6bf7b:` blob:
  - `navagent3d_detour.gd` sha256
    `81a8c10a53c8554bfae270d2f1b7fe77649b119ae3328840022027c9c2b1a504`
    (unchanged from r75 — matches the r75-verifier-pinned `81a8c10a…`)
  - `project.godot` `1fda90d46b0529aea0e75710a64f038cbf983adc8385285dd8bbe6202a8eac23`
    (unchanged since r72)
  - `run_battery.py` `d8354022823111cb6ea7355eaa252bb4d9bdc2d327458ec66a2cf945becd4473`
    (changed from r75-baseline's `697b3d5f…` — the r75 CASES-table growth
    145→156 plus the `--runs` docstring fix)

## Godot battery — frozen tree — PASS 156/156 + 4 probes

Command (run from the frozen tree root, `--runs` **absolute** per the
r72-verifier-documented relative-path trap):

    python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
      --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r76-baseline/runs \
      --probe-failing --probe-crash-exit --probe-stream-attribution --probe-tree-timeout

Receipt `runs/20261014T095009263752Z/verdicts.json`:

- `verdict`: **PASS**; `godot_version` `4.7.2.stable.arch_linux.ed1daf0bf`,
  battery invocation exit 0.
- `totals`: `cases=156 pass=156 fail=0 ordinary=111 negative_controls=45
  probes=4` — **156/156 PASS** (matches the brief's required green).
- `seeds_unchanged`: `true`; 52 seed digests, **byte-identical** to the
  r75-verifier receipt (see drift section).
- Probes 4/4: `crash_probe_ok=true`, `stream_probe_ok=true`,
  `tree_probe_ok=true` — witness `pid 2503704` `witness_verified=true`,
  `witness_gone=true`, `witness_cleanup="SIGTERM to verified detached
  witness"`, `cleanup_exit=-9`; `ps` post-run shows no leaked witness
  (0 `hold-open` processes). Mutation probe (`--probe-failing`):
  `detected=true`, `seeds_unchanged=true` — mutant `body3d_contact`
  rejected with the expected contact-plane diagnostic (`exit 1`,
  `final_z=3.500 expected=2.500`, marker absent).

## Drift vs r75 verifier receipt — ZERO

Tuple comparison of every row in my fresh receipt against
`corpus/live/r75-verifier/runs/20261014T093010381467Z/verdicts.json`
(the r75 verifier's 156-row passing absolute-`--runs` run on `cefc821`)
on the 12-field tuple `case, script, flags, expected_exit, actual_exit,
kind, marker, verdict, reasons, stdout, stderr, error` (excluding
run-specific `command`, `elapsed_seconds`):

- rows: 156 vs 156 — **missing in new: none; added in new: none**
- **field mismatches: 0 over 156 rows × 12 fields**
- `seed_digests`: 52 keys each, **zero digest differences**
- `totals` identical; same godot build string; probe flags equal
  (`detected/seeds_unchanged=true`, crash/stream/tree `true` both sides)

The frozen `cb6bf7b` tree replays the committed r75 battery with
bit-for-bit row equality against the independent r75 verification. The
only commits between `cefc821` (verifier-tested) and `cb6bf7b` are
report/LOG/SCORECARD/lesson landings, so zero fixture drift is the
expected and observed outcome.

## r76 anchor rows — before-state the sync-window arms must preserve

All 81 nav-family rows pass with stdout verbatim-equal to the
r75-verifier receipt: the 11 `mut_*` rows, 50 `navagent3d_detour*`
base/pop/finish rows, 15 `link_*` rows, 18 `mv_*` rows (families
overlap), plus `navagent3d_{follow,next,distance,retarget}` and
`navigation3d_path*`. Key verbatim marker tails from
`runs/20261014T095009263752Z/verdicts.json` (stdout last line):

- `navagent3d_detour_mut_link_kill` (dead-link requery, no zombie
  served): `steps=3 idxs=2,3,1 next=2.500000,0.000000,4.000000
  final=2.500000,0.000000,4.000000 dist=2.100000 pathlen=0.600001
  reachable=false …`
- `navagent3d_detour_mut_link_drop`: `steps=2 idxs=1,1
  next=2.000000,0.000000,1.000000 final=2.500000,0.000000,4.000000
  dist=1.600000 pathlen=4.622520 reachable=false …`
- `navagent3d_detour_mut_layers_agent` (agent-side synchronous clear +
  re-layer rematerialize): `steps=2 idxs=0,1
  next=2.000000,0.000000,1.000000 final=2.500000,0.000000,5.500000
  dist=5.385165 pathlen=6.130649 reachable=true …`
- `navagent3d_detour_mut_layers_region` (empty-path tuple):
  `steps=1 idxs=0 next=0.500000,0.000000,0.500000
  final=0.000000,0.000000,0.000000 dist=3.605551 pathlen=0.000000
  reachable=false …`
- `navagent3d_detour_mut_region_move` (+5x re-anchor):
  `steps=1 idxs=0 next=5.000000,0.000000,0.500000
  final=5.000000,0.000000,1.000000 dist=3.605551 pathlen=0.500000
  reachable=false …`
- `navagent3d_detour_mut_region_off` / `mut_region_renew` /
  `mut_link_revive` (disable→restore cycles): each `steps=2` re-serving
  the restored path (`pathlen=4.130649` / `6.130649`), `reachable=true`
- `navagent3d_detour_mut_lazy` (`wait=10 peek_only`, zero forcing
  calls): `steps=2 idxs=1,1 next=2.000000,0.000000,1.000000
  final=2.500000,0.000000,4.000000 dist=5.385165 pathlen=4.622520
  reachable=false …`
- `navagent3d_detour_mut_latch_zombie` (served zombie through transform
  AND delete): `steps=2 idxs=1,1 next=2.000000,0.000000,3.000000
  final=2.000000,0.000000,3.000000 dist=1.500000 pathlen=0.000000
  reachable=true reached=true finished=true`
- `navagent3d_detour` (untouched base): `distance=3.605551
  semantic=euclidean final=2.500,0.000,3.500 next=2.000,0.000,1.000
  pathlen=4.130649 reachable=true reached=false finished=false`
- `navagent3d_detour_link_shortcut`: `idx=1
  next=1.500000,0.000000,0.500000 final=2.500000,0.000000,3.500000
  dist=3.605551 pathlen=4.192582 reachable=true …`
- `navagent3d_detour_mv_latch`: `steps=2 idxs=1,1
  next=2.000000,0.000000,3.000000 final=2.000000,0.000000,3.000000
  dist=11.800424 pathlen=0.000000 reachable=true reached=true
  finished=true`

**The same-turn setter→server-sync window is greenfield at CASES level**
— traced in `frozen/corpus/fixtures/navagent3d_detour.gd`:

- The sync window exists only as header documentation + sibling probe
  evidence, not as a pinned arm: L1121–1127 records "the server sync
  lands ~2 physics frames for link toggles, ~3 for region_set_transform —
  a same-turn forcing call inside the setter->sync window still serves
  the stale hop, and mutate steps therefore need wait>=1 before their
  forcing read". Measured report-side (r75-verifier `sameturn_zombie`
  probe: same-turn `link_get_enabled=true iter=1`, forcing call serves
  dead endpoint `(2.5,0,5.5)`; `F2` re-queries) — never CASES-pinned.
- All 16 authored mutate steps wait **>=5** physics frames before the
  forcing read: runner default `"wait", 5` (`_run_steps` L1562);
  explicit waits are 10/5/10/5 (L1345/1348/1366/1371). **Zero `wait:0`,
  `wait:1`, or `wait:2` mutate steps exist.** The only `wait:0` step in
  the fixture is a `tp` step (L815, live call-time read after teleport),
  unrelated to mutation.
- `map_set_active` appears once — `map_set_active(map, true)` at L190,
  authoring-time setup only. The `_apply_mutation` vocabulary
  (L1584–1611) is `region_delete`, `region_recreate`,
  `region_transform`, `region_enabled`, `region_layers`, `link_enabled`,
  `link_layers`, `agent_layers` — **no map_active key**;
  `map_set_active(false)` reachability is unarmed (r75-verifier Info
  finding: no iteration bump → unlatched agent serves stale path
  indefinitely).
- **No same-value mutation arm**: every authored mutate dict writes a
  changed value (enable→disable, layers 1→2→1, transform +5x,
  delete/recreate). Same-value-write suppression (server skips
  dirty-marking) is unpinned — distinct from the agent-side
  `target_position` same-value re-assignment, which the header pins as
  "no value dedup" unlatch (L101–105).
- Substrate for the new arms already exists: step grammar applies
  `mutate` before the wait loop (L1560–1562: `set_target -> tp ->
  mutate -> wait -> read`), and `peek_path`/`peek_idx`/`peek_only`
  (L1115–1120) pin non-forcing stored state around it — a `wait:0`
  mutate step is the same-turn arm the r76 move wants. Documented bound
  (r75-verifier finding #2): a terminal `wait:0` mutate step trips the
  `_final_srv_state` readback gate (L1613+, reads pre-sync truth) — the
  r76 author must place the sync-boundary assertion where the gate
  doesn't eat it, or extend the gate.
- The 11 committed `mut_*` arms all sit strictly AFTER the window
  (wait>=5 ⇒ post-sync), so the r76 same-turn arms add a new timing
  band, not a re-measure of existing rows — any drift in the anchors
  above is regression, not window measurement.

## Node three.js suites — frozen tree — 31/31

Run from `frozen/corpus/fixtures/three` (post `npm ci`) with
`--receipt …/r76-baseline/receipts/run_<suite>.json`; every runner
exited 0 with `seeds_unchanged=true`. Verbatim tails:

    node run_cases.mjs        → PASS three battery: 3/3, seeds_unchanged=true        exit=0
    node run_layer_cases.mjs  → PASS three layer battery: 4/4, seeds_unchanged=true  exit=0
    node run_order_cases.mjs  → PASS three order battery: 9/9, seeds_unchanged=true  exit=0
    node run_camera_cases.mjs → PASS three camera battery: 5/5, seeds_unchanged=true exit=0
    node run_ortho_cases.mjs  → PASS three ortho battery: 5/5, seeds_unchanged=true  exit=0
    node run_ray_cases.mjs    → PASS three ray battery: 5/5, seeds_unchanged=true    exit=0

**Total 31/31**; receipts at `corpus/live/r76-baseline/receipts/run_*.json`.

## Before-state summary

| surface | result |
|---|---|
| Godot battery | PASS 156/156 (111 ordinary + 45 negative) + 4 probes PASS, seeds_unchanged=true |
| Row tuples vs r75-verifier | 0 mismatches / 156 rows × 12 fields; 52 seed digests byte-identical |
| Node six suites | PASS 31/31 (3+4+9+5+5+5), all seeds_unchanged=true |
| Same-turn mutate window in CASES | none exists — all 16 mutate steps wait>=5; window is header-comment + probe evidence only; r76 axis greenfield |
| `map_set_active(false)` arm | none — `map_set_active` is setup-only (L190); no `map_active` mutate key |
| Same-value mutation arm | none — all authored mutate dicts write changed values |

The r76 author starts from a fully green frozen state at `cb6bf7b` whose
156 rows are byte-identical to the r75-verified battery. Any same-turn
or map_active arm that perturbs an existing row's tuple is measurable
drift against this receipt pair; the documented `wait:0` mutate /
`_final_srv_state` gate bound above is the known mechanical trap for the
new arms.

## Receipts / scratch (all inside write scope)

- `corpus/live/r76-baseline/frozen/` — frozen `cb6bf7b` tree (+
  gitignored `node_modules` via `npm ci`)
- `corpus/live/r76-baseline/runs/20261014T095009263752Z/` — verdicts.json,
  crash-exit/stream-attribution/tree-timeout verdicts,
  mutation-verdicts, scratch + mutation-scratch dirs
- `corpus/live/r76-baseline/receipts/run_{cases,layer_cases,order_cases,
  camera_cases,ortho_cases,ray_cases}.json` — six Node suite receipts

## Limits

- Single replay per surface; zero failures, no flake-retry needed.
- Host intermittence caveat carried from r68/r69 (`navagent3d_retarget`)
  did not manifest in this run.
- This baseline asserts nothing about same-turn mutate semantics — no
  committed arm exercises `wait<5`; it only pins the pre-move surface
  the r76 arms must not regress. The ~2/~3-frame figures quoted are the
  committed header's report-side numbers + r75-verifier probe outputs,
  not battery receipts.
