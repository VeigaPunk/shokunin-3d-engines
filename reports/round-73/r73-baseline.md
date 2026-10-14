# game-dev-3d round 73 — frozen before-state baseline (seat: baseline)

Baseline replay for the r73 move: formalize off-mesh navigation-link
traversal gating as tracked CASES arms on the existing detour fixture
(navigation_layers bitmask mismatch, bidirectional-from-exit, enabled=false
drop the link; path_metadata_flags LINK-typed companion waypoints;
enter_cost vs travel_cost pair; pdd pop-through hazard). This report
records only the frozen before-state at canonical `HEAD`; no fixture
authored here. Canonical repo `~/Projects/shokunin/game-dev-3d-shokunin`,
reached via worktree symlink `~/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d`.

Environment: `/usr/bin/godot` = `4.7.2.stable.arch_linux.ed1daf0bf`
(matches the r72-verifier-pinned build), Python 3.14.7, Node v24.21.0,
three.js 0.186.1.

## Frozen tree

    git -C ~/Projects/shokunin/game-dev-3d-shokunin archive HEAD | tar -x -C \
      corpus/live/r73-baseline/frozen

- Frozen commit: `3f6a03dfed3016eafd1b91e8752f0e8a7dbfccf2`
  (`3f6a03d game-dev-3d r72: simplifier report (post-adjudication landing)`),
  which contains the r72-admitted 112-row battery. No r73 content is
  committed at freeze time.
- `git status --porcelain` on the canonical repo at dispatch: **clean**
  (0 entries); still clean after all replay — every write confined to
  gitignored `corpus/live/` (`corpus/.gitignore: live/`).
- Archive carries tracked files only: no `.git`, no `corpus/live/` state.
- `corpus/fixtures/three/node_modules` is gitignored; frozen tree
  provisioned with `npm ci` inside `frozen/corpus/fixtures/three` →
  `added 1 package, and audited 2 packages` (three@0.186.1 per tracked
  lockfile; seed digests are computed from tracked files, untouched).
- Frozen `navagent3d_detour.gd` sha256 `ea722a750818d06a…` —
  byte-identical to the r72-verifier-pinned committed blob at `05405ae`
  (full `ea722a750818d06a50db5f3cdaeae1738fae29944ad0de54034e444a7d1f4da0`).
  `project.godot` `1fda90d4…`, `run_battery.py` `4e9ead37…` likewise match
  the seed digests recorded in both receipts.

## Godot battery — frozen tree — PASS 112/112 + 4 probes

Command (run from the frozen tree root, `--runs` **absolute** per the
r72-verifier-documented relative-path trap):

    python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
      --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r73-baseline/runs \
      --probe-failing --probe-crash-exit --probe-stream-attribution --probe-tree-timeout

Receipt `runs/20261014T013403245240Z/verdicts.json`:

- `verdict`: **PASS**; `godot_version` `4.7.2.stable.arch_linux.ed1daf0bf`,
  exit 0 for the battery invocation.
- `totals`: `cases=112 pass=112 fail=0 ordinary=67 negative_controls=45
  probes=4` — **112/112 PASS**.
- `seeds_unchanged`: `true`; 52 seed digests, **byte-identical** to the
  r72-verifier receipt (see drift section).
- Probes 4/4: `crash_probe_ok=true`, `stream_probe_ok=true`,
  `tree_probe_ok=true` — witness `pid 1248834` `witness_verified=true`,
  `witness_gone=true`, `witness_cleanup="SIGTERM to verified detached
  witness"` (the absolute-`--runs` convention works; no leaked witness —
  `ps` post-run shows only unrelated godot-mcp daemons and a sibling
  game-dev-2d lane process). Mutation probe (`--probe-failing`):
  `verdict=PASS`, `detected=true`, `seeds_unchanged=true` — mutant
  `body3d_contact` rejected with the expected contact-plane diagnostic.

## Drift vs r72 verifier receipt — ZERO

Tuple comparison of every row in my fresh receipt against
`corpus/live/r72-verifier/runs/20261014T011457986739Z/verdicts.json` (the
r72 verifier's passing absolute-`--runs` run) on the 12-field tuple
`case, script, flags, expected_exit, actual_exit, kind, marker, verdict,
reasons, stdout, stderr, error` (excluding run-specific `command`,
`elapsed_seconds`):

- rows: 112 vs 112 — **missing in new: none; added in new: none**
- **field mismatches: 0 over 112 rows × 12 fields**
- `seed_digests`: 52 keys each, **zero digest differences**
- `totals` identical; same godot build string.

The frozen `3f6a03d` tree replays the committed r72 battery with bit-for-bit
row equality against the independent r72 verification. The r72 commits
between `05405ae` and `3f6a03d` (adjudication `f95a16e`, simplifier
`3f6a03d`) touched reports/ledger files only, so zero fixture drift is the
expected and observed outcome.

## r73 anchor rows — before-state the link arms must preserve

All 27 `navagent3d_detour*` rows and both `navigation3d_path*` rows pass
with stdout verbatim-equal to r72. Key anchors (verbatim stdout tails):

- `navagent3d_detour`: `distance=3.605551 semantic=euclidean
  final=2.500,0.000,3.500 next=2.000,0.000,1.000 pathlen=4.130649
  reachable=true reached=false finished=false`
- `navagent3d_detour_post_edgecentered` / `post_none`: `next=2.000,0.000,0.500`,
  `pathlen=4.707107` / `4.549510`
- `navigation3d_path`: `points=2 start=1.000,0.000,1.000
  end=3.000,0.000,3.000 region_active=true`
- `navigation3d_path_disconnected` (negative): `disconnected_endpoint_rejected
  source_end=4.000,0.000,3.000 target_end=23.000,0.000,3.000`

**Link surface is greenfield in the before-state:** `grep -iE
'navigationlink|path_metadata|link'` over `frozen/corpus/fixtures/*.gd`,
`run_battery.py`, and `corpus/fixtures/three/*.mjs` returns **zero**
matches (`navigationlink` count = 0 in both `run_battery.py` and
`navagent3d_detour.gd`). The declared r73 arms (a)–(d) therefore pin new
behavior on an untouched axis; every existing row above is a
keep-byte-stable regression anchor.

## Node three.js suites — frozen tree — 31/31

Run from `frozen/corpus/fixtures/three` (post `npm ci`) with
`--receipt …/r73-baseline/receipts/run_<suite>.json`; every runner exited
0 with `seeds_unchanged=true`. Verbatim tails:

    node run_cases.mjs        → PASS three battery: 3/3, seeds_unchanged=true        exit=0
    node run_layer_cases.mjs  → PASS three layer battery: 4/4, seeds_unchanged=true  exit=0
    node run_order_cases.mjs  → PASS three order battery: 9/9, seeds_unchanged=true  exit=0
    node run_camera_cases.mjs → PASS three camera battery: 5/5, seeds_unchanged=true exit=0
    node run_ortho_cases.mjs  → PASS three ortho battery: 5/5, seeds_unchanged=true  exit=0
    node run_ray_cases.mjs    → PASS three ray battery: 5/5, seeds_unchanged=true    exit=0

**Total 31/31**; receipts at `corpus/live/r73-baseline/receipts/run_*.json`.

## Before-state summary

| surface | result |
|---|---|
| Godot battery | PASS 112/112 (67 ordinary + 45 negative) + 4 probes PASS, seeds_unchanged=true |
| Row tuples vs r72-verifier | 0 mismatches / 112 rows × 12 fields; seed digests byte-identical |
| Node six suites | PASS 31/31 (3+4+9+5+5+5), all seeds_unchanged=true |
| Link/link-gate rows | none exist yet — r73 axis greenfield |

The r73 author starts from a fully green frozen state at `3f6a03d` whose
112 rows are byte-identical to the r72-verified battery. Any link-gate arm
that perturbs an existing row's tuple is measurable drift against this
receipt pair.

## Receipts / scratch (all inside write scope)

- `corpus/live/r73-baseline/frozen/` — frozen `3f6a03d` tree (+ gitignored
  `node_modules` via `npm ci`)
- `corpus/live/r73-baseline/runs/20261014T013403245240Z/` — verdicts.json,
  crash-exit/stream-attribution/tree-timeout verdicts, mutation-verdicts,
  scratch + mutation-scratch dirs
- `corpus/live/r73-baseline/receipts/run_{cases,layer_cases,order_cases,
  camera_cases,ortho_cases,ray_cases}.json` — six Node suite receipts

## Limits

- Single replay per surface; zero failures, no flake-retry needed.
- Host intermittence caveat carried from r68/r69 (`navagent3d_retarget`)
  did not manifest in this run.
- This baseline asserts nothing about `NavigationLink3D` behavior — no
  fixture exercises it yet; it only pins the pre-move surface the r73
  arms must not regress.
