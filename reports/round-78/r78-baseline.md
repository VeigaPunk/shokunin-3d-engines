# game-dev-3d round 78 — frozen before-state baseline (seat: baseline)

Baseline replay for the r78 move: pin the `map_set_active(false)`
permanent-stale claim as a bounded measurement — the r76 "stale forever"
is measured only to +15f (r76-adjudicator: "not a proof of
unboundedness"). Ladder the inactive-map wait {20,60,120,300}f on the
link-kill-under-mapoff arm: the falsifiable claim is permanent-stale —
a late flush (map_iter bump, tuple change) at ANY rung falsifies it and
becomes the measured bound. Plus: pin the callsite shift as tracked
CASES — r76-critic's `_physics_process` +1-tick finding (bb_physmut) is
scratch-level only; land the same link-kill mutation issued from
{coroutine-resume, `_physics_process`-callsite} contexts as paired arms
with edge-shift receipts. This report records only the frozen
before-state at canonical `HEAD`; no fixture authored here. Canonical
repo `~/Projects/shokunin/game-dev-3d-shokunin` (the
`~/Projects/prymeagnt/game-dev-3d` path in the brief is the stale
predecessor; canonical reached via its `.shokunin/game-dev-3d` symlink).

Environment: `/usr/bin/godot` = `4.7.2.stable.arch_linux.ed1daf0bf`
(same pinned build as r73–r77), Python 3.14.7, Node v24.21.0,
three.js 0.186.1.

## Frozen tree

    git -C ~/Projects/shokunin/game-dev-3d-shokunin archive HEAD \
      --format=tar -o corpus/live/r78-baseline/frozen/frozen-tree.tar

- Frozen commit: `71818b70180d14c51d197a75253d8839e451c08b`
  (`71818b7 r77 report-last: ADMIT — apply-order = doomed-RID voiding
  (pairwise; 6-perm census 3 outcome classes); map_force_update =
  getter collapse + mark-vs-phase serve race …; hygiene
  565318c+5e02b25+a5ae849`), which contains the r77-admitted 173-row
  battery (163 r76 rows + 10 apply-order/force-update/ladder arms from
  `35dfbe2`) plus the three committed hygiene/comment commits on
  `navagent3d_detour.gd`. No r78 content is committed at freeze time.
- Archive kept as archive only — `frozen/` carries the `.tar`, no
  populated tree. Archive sha256
  `6082c80de24ca0362b3d0aa07ca185d839144812bb6ee5778d171a7898362bea`,
  334 tar members; member file list `diff`-identical to
  `git ls-files` (308 tracked files — `corpus/live/` is gitignored,
  so no prior `r*-baseline`/`frozen`/`tree` dirs or `node_modules`
  are members).
- Replay scratch: archive extracted once to
  `corpus/live/r78-baseline/frozen-extract/` (inside my gitignored
  write scope, never tracked). Required check run BEFORE any
  provisioning:
  `comm -23 <(cd frozen-extract && find . -type f | sed 's|^\./||' | sort) <(git ls-files | sort)`
  → **EMPTY (0 untracked members)**; reverse `comm -13` also EMPTY
  (0 missing members).
- `corpus/fixtures/three/node_modules` is gitignored; extract
  provisioned AFTER the comm check with `npm ci` inside
  `frozen-extract/corpus/fixtures/three` → `added 1 package, and
  audited 2 packages` (three@0.186.1 per tracked lockfile;
  `node_modules/three/package.json` `"version": "0.186.1"`).
- `git diff 35dfbe2..71818b7 -- corpus/fixtures` (verifier-tested
  commit → freeze HEAD): `navagent3d_detour.gd` only, +28/−21 — the
  three hygiene commits (`565318c`+`5e02b25` comment corrections,
  `a5ae849` three deletions). Zero CASES-table delta
  (`run_battery.py` unchanged since `35dfbe2`).
- `git status --porcelain` on the canonical repo at dispatch and
  post-replay: clean except `?? reports/round-78/` (new untracked dir
  carrying this and sibling lanes' reports). Every write of this seat
  is confined to gitignored `corpus/live/r78-baseline/` plus this
  report path.
- Frozen seed digests, each verified byte-identical to the `git show
  71818b7:` blob:
  - `navagent3d_detour.gd` sha256
    `de9ef7cf61b91073c058d77e3e7835820e3914bbc203a8cd870f1b1a11bc14d6`
    (post-hygiene — differs from the r77-verifier-pinned `fa4eb04a…`
    because the verifier ran at `35dfbe2`, before
    `565318c`/`5e02b25`/`a5ae849` landed)
  - `corpus/fixtures/project.godot`
    `1fda90d46b0529aea0e75710a64f038cbf983adc8385285dd8bbe6202a8eac23`
    (unchanged since r72)
  - `run_battery.py`
    `92c5ad87df04d8ed247ced3b83d06d0e384e28fbaef0b22a161f280deb64b661`
    (identical to the r77-verifier receipt — the 173-row CASES table
    at L212–231 is the committed r77 battery)

## Godot battery — frozen tree — PASS 173/173 + 4 probes

Command (run from the frozen-extract root, `--runs` **absolute** per
the r72-verifier-documented relative-path trap):

    python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
      --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r78-baseline/runs \
      --probe-failing --probe-crash-exit --probe-stream-attribution --probe-tree-timeout

Receipt `runs/20261014T120340433067Z/verdicts.json`:

- `verdict`: **PASS**; `godot_version` `4.7.2.stable.arch_linux.ed1daf0bf`,
  battery invocation exit 0, output tail
  `totals: cases=173 pass=173 fail=0 ordinary=128 negative_controls=45 probes=4`.
- `totals`: `cases=173 pass=173 fail=0 ordinary=128
  negative_controls=45 probes=4` — **173/173 PASS** (matches the
  brief's required green).
- `seeds_unchanged`: `true`; 52 seed digests recorded.
- Probes 4/4: `crash_probe_ok=true`, `stream_probe_ok=true`,
  `tree_probe_ok=true` — witness `pid 3738994`
  `witness_verified=true`, `witness_gone=true`,
  `witness_cleanup="SIGTERM to verified detached witness"`,
  `cleanup_exit=-9`; `pgrep -af hold-open` post-run shows no leaked
  witness (0 processes). Mutation probe (`--probe-failing`):
  `detected=true`, `seeds_unchanged=true` — mutant `body3d_contact`
  rejected with the expected contact-plane diagnostic (`exit 1`,
  `final_z=3.500 expected=2.500`, marker absent).

## Drift vs r77 verifier receipt — ZERO (row tuples); one owned seed-digest delta

Tuple comparison of every row in my fresh receipt against
`corpus/live/r77-verifier/runs/20261014T113358221848Z/verdicts.json`
(the r77 verifier's 173-row passing absolute-`--runs` run on
`35dfbe2`) on the 12-field tuple `case, script, flags, expected_exit,
actual_exit, kind, marker, verdict, reasons, stdout, stderr, error`
(excluding run-specific `command`, `elapsed_seconds`; comparator
script at `corpus/live/r78-baseline/compare_receipts.py`):

- rows: 173 vs 173 — **missing in new: none; added in new: none**
- **field mismatches: 0 over 173 rows × 12 fields** — all 173 prior
  rows byte-stable, including all 10 r77 `mut_ord_*`/`mut_force_*`/
  `mut_ladder_*` arms verbatim.
- `totals` identical; same godot build string; all probe flags equal
  (`detected/seeds_unchanged=true`, crash/stream/tree `true` both
  sides); `case_timeout_seconds=20` both.
- `seed_digests`: 52 keys each, key sets identical; **one digest
  differs — `navagent3d_detour.gd` `de9ef7cf…` (frozen `71818b7`) vs
  `fa4eb04a…` (verifier-tested `35dfbe2`)**. This is the owned,
  explained delta the brief anticipated, not behavioral drift: the
  r77-verifier ran before `565318c`+`5e02b25` (comment corrections)
  and `a5ae849` (three simplifier-proven deletions — dead
  `link_layers` srv_get branch, `st2` dead store, stale "never the
  serve edge" comment; `git show a5ae849` on `navagent3d_detour.gd`:
  −1 line at old-L367, −2 lines at old-L2283–2284, +3/−1 comment at
  old-L2213) landed. The verifier-tested tree is not the freeze tree;
  row tuples are the behavioral comparison and they are bit-identical.
- Corollary: no r77 seat published a battery receipt on the
  post-`a5ae849` tree (verifier receipt pins `fa4eb04a…`). This
  replay is the first committed-record battery run on `71818b7`, and
  its 173 byte-identical rows independently confirm the r77-hygiene
  deletions' inert claim (`a5ae849` commit msg: "post-delete
  173/173").

## r78 anchor rows — before-state the new arms must preserve

All nav-family rows pass with stdout verbatim-equal to the
r77-verifier receipt. Key verbatim marker tails from
`runs/20261014T120340433067Z/verdicts.json` (stdout last line):

- `navagent3d_detour_mut_map_off` (map deactivation → permanent
  stale, no edge): `steps=3 idxs=1,1,1 next=2.000000,0.000000,1.000000
  final=2.500000,0.000000,5.500000 dist=5.385165 pathlen=6.130649
  reachable=true reached=false finished=false`
- `navagent3d_detour_mut_map_cycle` (kill-under-mapoff then off→on
  restores sync): `steps=4 idxs=1,1,1,1 next=2.000000,0.000000,1.000000
  final=2.500000,0.000000,4.000000 dist=5.385165 pathlen=4.622520
  reachable=false …`
- `navagent3d_detour_mut_ord_kill_mapoff` /
  `mut_ord_mapoff_kill` (same-tick link-kill+map-off, both
  orders): identical tuples `steps=3 idxs=1,1,1
  next=2.000000,0.000000,1.000000 final=2.500000,0.000000,4.000000
  dist=5.385165 pathlen=4.622520 reachable=false reached=false
  finished=false` — kill+deactivate and deactivate+kill converge.
- `navagent3d_detour_mut_force_link` / `mut_force_ctl` (forced
  getter-collapse arms): verbatim (`steps=2`/`steps=3`, both
  `reachable=false` post-reactivation).
- `navagent3d_detour_mut_ladder_link` / `mut_ladder_region`
  (verdict-group ladders): verbatim `bound=2 groups=2 sizes=2,2` /
  `bound=3 groups=2 sizes=3,2`.
- `navagent3d_detour_mut_link_kill` (active-map kill edge):
  `steps=3 idxs=2,3,1 … pathlen=0.600001 reachable=false …
  finished=true`.

**Both r78 claims are greenfield at CASES level** — measured in
`frozen-extract/corpus/fixtures/navagent3d_detour.gd`:

- Inactive-map stale hold is bounded at **15f max** today:
  `mut_map_off` holds the map inactive across `wait:0` + `wait:10` +
  `wait:5` (L1536–1556) and still serves the committed tuple —
  exactly the "+15f" bound the r76-adjudicator flagged as not a
  proof of unboundedness. `mut_map_cycle` holds ~8f inactive
  (mapoff `wait:3` at L1571 → kill `wait:5` at L1578) before
  reactivation; both `mut_ord_*mapoff*` arms spend a single step
  inactive then reactivate at `wait:1` (L1795/L1827). No
  {20,60,120,300}f ladder exists anywhere; no arm combines
  link-kill with a LONG inactive hold — the r78 ladder arm is new.
- Callsite is single-context today: every mutation issues through
  `_apply_mutation` invoked from the `_run_steps` coroutine
  (L2180–2182: `if step.has("mutate"): for m in _mut_list(step):
  _apply_mutation(m, srv)`, the wait loop's `await physics_frame`
  at L2184). `_physics_process` appears **nowhere** in the fixture
  (grep 0 hits; the only physics hooks are `await physics_frame`
  at L340, L370, L2184). The paired coroutine-resume vs
  `_physics_process`-callsite link-kill arms are new vocabulary;
  `bb_physmut`-class evidence is scratch-level only.
- Observability for the falsifier already exists as vocabulary:
  `srv_get` supports `link_iter` (iteration-id bump, L2283–2284),
  `link_enabled`, `link_start`/`link_end`, `map_active`,
  `region_transform` (`_read_srv` L2278–2294; the a5ae849-deleted
  `link_layers` srv_get branch is confirmed absent from the frozen
  tree, `link_iter` intact), and `peek_path`/`peek_idx` non-forcing
  captures (L2186–2188) plus the served tuple itself
  (`next`/`final`/`dist`/`pathlen`) are how a late flush would
  surface — no `map_iter`/`region_iter` srv_get key exists today.

## Node three.js suites — frozen tree — 31/31

Run from `frozen-extract/corpus/fixtures/three` (post `npm ci`) with
`--receipt …/r78-baseline/receipts/run_<suite>.json`; every runner
exited 0 with `seeds_unchanged=true`. Verbatim tails:

    node run_cases.mjs        → PASS three battery: 3/3, seeds_unchanged=true        exit=0
    node run_layer_cases.mjs  → PASS three layer battery: 4/4, seeds_unchanged=true  exit=0
    node run_order_cases.mjs  → PASS three order battery: 9/9, seeds_unchanged=true  exit=0
    node run_camera_cases.mjs → PASS three camera battery: 5/5, seeds_unchanged=true exit=0
    node run_ortho_cases.mjs  → PASS three ortho battery: 5/5, seeds_unchanged=true  exit=0
    node run_ray_cases.mjs    → PASS three ray battery: 5/5, seeds_unchanged=true    exit=0

**Total 31/31**; receipts at
`corpus/live/r78-baseline/receipts/run_{cases,layer_cases,order_cases,camera_cases,ortho_cases,ray_cases}.json`.

## Before-state summary

| surface | result |
|---|---|
| Godot battery | PASS 173/173 (128 ordinary + 45 negative) + 4 probes PASS, seeds_unchanged=true |
| Row tuples vs r77-verifier | 0 mismatches / 173 rows × 12 fields; 52 seed digests — one owned delta (`navagent3d_detour.gd` = committed `565318c`+`5e02b25`+`a5ae849` post-verifier content, zero row drift) |
| Node six suites | PASS 31/31 (3+4+9+5+5+5), all seeds_unchanged=true |
| Inactive-map stale bound | 15f max measured (`mut_map_off` 0+10+5); no {20,60,120,300}f ladder; no link-kill under long map-off — permanent-stale unbounded at CASES level |
| Mutation callsite | single context — `_run_steps` coroutine-resume only; `_physics_process` absent from fixture; paired callsite arms greenfield |

The r78 author starts from a fully green frozen state at `71818b7`
whose 173 rows are byte-identical to the r77-verified battery. Any
ladder rung or callsite arm that perturbs an existing row's tuple is
measurable drift against this receipt pair; a late flush at any rung
of the inactive-map ladder falsifies the permanent-stale claim
against the verbatim tuples pinned above.

## Receipts / scratch (all inside write scope)

- `corpus/live/r78-baseline/frozen/frozen-tree.tar` — `git archive
  HEAD` output, sha256
  `6082c80de24ca0362b3d0aa07ca185d839144812bb6ee5778d171a7898362bea`
  (archive only; no populated tree inside `frozen/`)
- `corpus/live/r78-baseline/frozen-extract/` — replay scratch tree
  (gitignored; comm check EMPTY pre-provisioning; + gitignored
  `node_modules` via `npm ci`)
- `corpus/live/r78-baseline/runs/20261014T120340433067Z/` —
  verdicts.json, crash-exit/stream-attribution/tree-timeout
  verdicts, mutation-verdicts, scratch + mutation-scratch dirs
- `corpus/live/r78-baseline/receipts/run_{cases,layer_cases,
  order_cases,camera_cases,ortho_cases,ray_cases}.json` — six Node
  suite receipts
- `corpus/live/r78-baseline/compare_receipts.py` — 12-field tuple
  comparator used for the drift section

## Limits

- Single replay per surface; zero failures, no flake-retry needed.
- Host intermittence caveat carried from r68/r69
  (`navagent3d_retarget`) did not manifest in this run.
- This baseline asserts nothing about inactive-map bounds beyond
  15f or about callsite semantics — no committed arm measures
  either; it only pins the pre-move surface the r78 arms must not
  regress. The one seed-digest delta vs the r77-verifier receipt is
  commit-owned (`565318c`+`5e02b25` comments + `a5ae849` deletions),
  demonstrated inert by the 173 byte-identical rows.
