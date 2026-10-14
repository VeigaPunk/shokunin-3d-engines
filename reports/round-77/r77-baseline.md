# game-dev-3d round 77 — frozen before-state baseline (seat: baseline)

Baseline replay for the r77 move: pin mutation APPLY-ORDER as a measured
axis — `_apply_mutation`'s fixed order (delete→recreate→transform→
link→agent) is load-bearing or inert? Declared falsifiable claim: at
least one order-pair produces observable distinct served state; if all
order-pairs converge, order is provably inert under this build. New arms
to land: hand-ordered same-tick setter sequences (e.g.
region_transform-then-delete vs delete-then-recreate;
link_disable+endpoint_move in both orders), a `map_force_update` CASES
arm, and a wait-ladder verdict-groups receipt. This report records only
the frozen before-state at canonical `HEAD`; no fixture authored here.
Canonical repo `~/Projects/shokunin/game-dev-3d-shokunin` (the
`~/Projects/prymeagnt/game-dev-3d` path in the brief is the stale
predecessor; canonical reached via its `.shokunin/game-dev-3d` symlink).

Environment: `/usr/bin/godot` = `4.7.2.stable.arch_linux.ed1daf0bf`
(same pinned build as r73–r76), Python 3.14.7, Node v24.21.0,
three.js 0.186.1.

## Frozen tree

    git -C ~/Projects/shokunin/game-dev-3d-shokunin archive HEAD | tar -x -C \
      corpus/live/r77-baseline/frozen

- Frozen commit: `e417365821194a98b7a018cf4f23a5c82735bb8f`
  (`e417365 r76 report-last: ADMIT — per-class sync edges
  {link:2,region:3,map_off:perm,agent:0} four-way converged +
  suppression pins; verifier AGREE 5/5; lesson/LOG/SCORECARD`), which
  contains the r76-admitted 163-row battery (156 r75 rows + 7
  sync-window/suppression arms from `3ab09fd`) plus the committed
  `8a67f71` `_check_tuple` extraction on `navagent3d_detour.gd`. No r77
  content is committed at freeze time.
- `git diff 3ab09fd..e417365 -- corpus/fixtures` (verifier-tested commit
  → freeze HEAD): `navagent3d_detour.gd` only, +33/−86 — the committed
  `_check_tuple` shared-predicate extraction; `e417365` itself is
  report/LOG/SCORECARD-only. Zero CASES-table delta (`run_battery.py`
  unchanged since `3ab09fd`).
- `git status --porcelain` on the canonical repo at dispatch and
  post-replay: **clean** (0 entries). Every write of this seat is
  confined to gitignored `corpus/live/` (`git check-ignore
  corpus/live/r77-baseline` → ignored) plus this report path.
- Archive carries tracked files only: `find frozen -name node_modules -o
  -name .git -o -name 'r*-baseline' -o -name live` → **0 hits**; 297
  tracked files extracted.
- `corpus/fixtures/three/node_modules` is gitignored; frozen tree
  provisioned with `npm ci` inside `frozen/corpus/fixtures/three` →
  `added 1 package, and audited 2 packages` (three@0.186.1 per tracked
  lockfile; `node_modules/three/package.json` `"version": "0.186.1"`).
- Frozen seed digests, each verified byte-identical to the `git show
  e417365:` blob:
  - `navagent3d_detour.gd` sha256
    `13af380467c00da9477a42626c42fcc516b165d7c2e94f116413c72572f24735`
    (post-refactor — differs from the r76-verifier-pinned `066a06d2…`
    because the verifier ran at `3ab09fd`, before `8a67f71` landed)
  - `corpus/fixtures/project.godot`
    `1fda90d46b0529aea0e75710a64f038cbf983adc8385285dd8bbe6202a8eac23`
    (unchanged since r72)
  - `run_battery.py` `6faa83560ac2ba69cc7032c899134ef33e32a497e3c1941a921e9d61a9b5cba1`
    (unchanged from the r76-verifier receipt — the +14-line CASES growth
    to 163 rows landed in `3ab09fd`, before verification)

## Godot battery — frozen tree — PASS 163/163 + 4 probes

Command (run from the frozen tree root, `--runs` **absolute** per the
r72-verifier-documented relative-path trap):

    python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
      --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r77-baseline/runs \
      --probe-failing --probe-crash-exit --probe-stream-attribution --probe-tree-timeout

Receipt `runs/20261014T105018199403Z/verdicts.json`:

- `verdict`: **PASS**; `godot_version` `4.7.2.stable.arch_linux.ed1daf0bf`,
  battery invocation exit 0.
- `totals`: `cases=163 pass=163 fail=0 ordinary=118 negative_controls=45
  probes=4` — **163/163 PASS** (matches the brief's required green).
- `seeds_unchanged`: `true`; 52 seed digests recorded.
- Probes 4/4: `crash_probe_ok=true`, `stream_probe_ok=true`,
  `tree_probe_ok=true` — witness `pid 3029841` `witness_verified=true`,
  `witness_gone=true`, `witness_cleanup="SIGTERM to verified detached
  witness"`, `cleanup_exit=-9`; `ps` post-run shows no leaked witness
  (0 `hold-open` processes). Mutation probe (`--probe-failing`):
  `detected=true`, `seeds_unchanged=true` — mutant `body3d_contact`
  rejected with the expected contact-plane diagnostic (`exit 1`,
  `final_z=3.500 expected=2.500`, marker absent).

## Drift vs r76 verifier receipt — ZERO (row tuples); one owned seed-digest delta

Tuple comparison of every row in my fresh receipt against
`corpus/live/r76-verifier/runs/20261014T102343921913Z/verdicts.json`
(the r76 verifier's 163-row passing absolute-`--runs` run on `3ab09fd`)
on the 12-field tuple `case, script, flags, expected_exit, actual_exit,
kind, marker, verdict, reasons, stdout, stderr, error` (excluding
run-specific `command`, `elapsed_seconds`):

- rows: 163 vs 163 — **missing in new: none; added in new: none**
- **field mismatches: 0 over 163 rows × 12 fields** — all 163 prior rows
  byte-stable, including all 18 `mut_*` arms verbatim.
- `totals` identical; same godot build string; probe flags equal
  (`detected/seeds_unchanged=true`, crash/stream/tree `true` both
  sides).
- `seed_digests`: 52 keys each; **one digest differs —
  `navagent3d_detour.gd` `13af3804…` (frozen `e417365`) vs `066a06d2…`
  (verifier-tested `3ab09fd`)**. This is an owned, explained delta, not
  behavioral drift: the r76-verifier ran before `8a67f71` (the committed
  `_check_tuple` extraction, −86/+33 on the fixture) landed. The
  verifier-tested tree is not the freeze tree; row tuples are the
  behavioral comparison and they are bit-identical.
- Corollary: no r76 seat published a receipt on the post-`8a67f71`
  tree (author/verifier/boundary receipts all carry `066a06d2…`;
  critic/reviewer ran the older 156-row battery). This replay is the
  first committed-record battery run on `e417365`, and its 163
  byte-identical rows independently confirm `8a67f71`'s byte-identical
  claim.

## r77 anchor rows — before-state the apply-order arms must preserve

All 90 nav-family rows pass with stdout verbatim-equal to the
r76-verifier receipt. Key verbatim marker tails from
`runs/20261014T105018199403Z/verdicts.json` (stdout last line):

- `navagent3d_detour_mut_win_link` (same-turn window, link edge at +2f):
  `steps=4 idxs=2,3,3,1 next=2.500000,0.000000,4.000000
  final=2.500000,0.000000,4.000000 dist=2.100000 pathlen=0.600001
  reachable=false reached=false finished=true`
- `navagent3d_detour_mut_win_region` (region edge at +3f):
  `steps=4 idxs=1,1,1,0 next=5.000000,0.000000,0.500000
  final=5.000000,0.000000,1.000000 dist=3.605551 pathlen=0.500000
  reachable=false …`
- `navagent3d_detour_mut_map_off` (map deactivation → permanent stale,
  no edge): `steps=3 idxs=1,1,1 next=2.000000,0.000000,1.000000
  final=2.500000,0.000000,5.500000 dist=5.385165 pathlen=6.130649
  reachable=true reached=false finished=false`
- `navagent3d_detour_mut_map_cycle` (off→on restores sync):
  `steps=4 idxs=1,1,1,1 next=2.000000,0.000000,1.000000
  final=2.500000,0.000000,4.000000 dist=5.385165 pathlen=4.622520
  reachable=false …`
- `navagent3d_detour_mut_same_link` / `mut_same_region` /
  `mut_same_agent` (same-value suppression pins): `steps=3`/`3`/`4`,
  verbatim tuples incl. `mut_same_agent` wait:0 peeks
  (`idxs=2,2,0,2`)
- `navagent3d_detour_mut_link_kill` / `mut_latch_zombie`: verbatim
  (`pathlen=0.600001 reachable=false`; `reachable=true reached=true
  finished=true` zombie latch)
- `navagent3d_detour` (untouched base): `distance=3.605551
  semantic=euclidean final=2.500,0.000,3.500 next=2.000,0.000,1.000
  pathlen=4.130649 reachable=true reached=false finished=false`

**Apply-order is greenfield at CASES level** — measured in
`frozen/corpus/fixtures/navagent3d_detour.gd`:

- `_apply_mutation` (L1841–1873) applies a mutate dict in fixed order:
  `region_delete` (L1842) → `region_recreate` (L1846) →
  `region_transform`/`region_enabled`/`region_layers` (L1856–1861) →
  `link_enabled`/`link_layers` (L1863–1866) → `agent_layers` (L1867) →
  `map_active` LAST (L1872–1873, with the committed note that map
  deactivation stops sync so same-dict writes stay invisible
  regardless of setter order). Order inside a step is
  `set_target -> tp -> mutate -> wait -> read` (L1812–1820).
- Authored mutate dicts are **almost entirely single-key**: 27 of 28
  `mutate` literals carry exactly one setter key. The sole composed
  same-tick dict is `mut_same_region`'s suppression pin at L1606:
  `{"region_layers": 1, "region_transform": Vector3(0,0,0)}` — a
  same-class pair whose DICT order (layers,transform) is the reverse
  of the applier order (transform→layers at L1856/L1860) and still
  converges to the pinned tuple. That is one weak convergence datum,
  not an order measurement: both writes target the same RID channel
  and both are same-value writes.
- **Zero cross-class composed dicts exist**: no arm writes
  `region_transform`+`region_delete` (transform-then-delete vs
  delete-then-recreate), no `link_enabled`+endpoint/link-layer pair,
  no `agent_layers`+`map_active` composition in one tick. The r77
  seam claim is untested by construction — every committed mutation is
  either single-key or split across steps separated by `wait>=0`.
- `map_force_update` appears **nowhere** in `navagent3d_detour.gd` or
  `run_battery.py` (grep: 0 hits) — the r77 `map_force_update` CASES
  arm is a new vocabulary item; neither the object-getter edge nor the
  serve edge is armed.
- Wait-ladder substrate exists but no verdict-group receipt does:
  authored mutate waits are 0/5/10 frames (`mut_same_agent` carries the
  only `wait:0` mutate steps, at L1631/L1636; `mut_lazy` uses `wait:10`
  peek_only). A post-mutation tuple partitioned by identical signature
  → window bound as partition boundary is unpinned — the r76 window
  arms pin per-class edges ({link:2f, region:3f, map_off:∞, agent:0f})
  as single ladders, not as a grouped partition receipt.
- The `_final_srv_state` readback gate (L1880+) folds every step's
  mutate dict — a composed dict's fold order (delete→recreate→…→
  map_active, L1901–1930+) mirrors the applier; a reversed-order arm
  asserting distinct served state must still pass this fold, so the
  r77 author's expectation bookkeeping inherits the same fixed order.
  Known mechanical bound carried forward: terminal `wait:0` mutate
  steps sample pre-sync truth in the gate (r76-verifier finding);
  `mut_same_agent` avoids it only because a later `wait:5` step
  re-reads.

## Node three.js suites — frozen tree — 31/31

Run from `frozen/corpus/fixtures/three` (post `npm ci`) with
`--receipt …/r77-baseline/receipts/run_<suite>.json`; every runner
exited 0 with `seeds_unchanged=true`. Verbatim tails:

    node run_cases.mjs        → PASS three battery: 3/3, seeds_unchanged=true        exit=0
    node run_layer_cases.mjs  → PASS three layer battery: 4/4, seeds_unchanged=true  exit=0
    node run_order_cases.mjs  → PASS three order battery: 9/9, seeds_unchanged=true  exit=0
    node run_camera_cases.mjs → PASS three camera battery: 5/5, seeds_unchanged=true exit=0
    node run_ortho_cases.mjs  → PASS three ortho battery: 5/5, seeds_unchanged=true  exit=0
    node run_ray_cases.mjs    → PASS three ray battery: 5/5, seeds_unchanged=true    exit=0

**Total 31/31**; receipts at `corpus/live/r77-baseline/receipts/run_*.json`.

## Before-state summary

| surface | result |
|---|---|
| Godot battery | PASS 163/163 (118 ordinary + 45 negative) + 4 probes PASS, seeds_unchanged=true |
| Row tuples vs r76-verifier | 0 mismatches / 163 rows × 12 fields; 52 seed digests — one explained delta (`navagent3d_detour.gd` = committed `8a67f71` refactor content, zero row drift) |
| Node six suites | PASS 31/31 (3+4+9+5+5+5), all seeds_unchanged=true |
| Composed same-tick mutate dicts | one exists (`mut_same_region` L1606, same-class layers+transform suppression pin); zero cross-class pairs — apply-order seam untested |
| `map_force_update` arm | none — symbol absent from fixture and battery; both edges unarmed |
| Wait-ladder verdict-groups receipt | none — per-class edges pinned as single ladders; grouped partition unpinned |

The r77 author starts from a fully green frozen state at `e417365`
whose 163 rows are byte-identical to the r76-verified battery. Any
order-pair, `map_force_update`, or wait-ladder arm that perturbs an
existing row's tuple is measurable drift against this receipt pair; the
`_final_srv_state` fold order mirroring the applier's fixed order is
the known bookkeeping constraint for reversed-order arms.

## Receipts / scratch (all inside write scope)

- `corpus/live/r77-baseline/frozen/` — frozen `e417365` tree (+
  gitignored `node_modules` via `npm ci`)
- `corpus/live/r77-baseline/runs/20261014T105018199403Z/` — verdicts.json,
  crash-exit/stream-attribution/tree-timeout verdicts,
  mutation-verdicts, scratch + mutation-scratch dirs
- `corpus/live/r77-baseline/receipts/run_{cases,layer_cases,order_cases,
  camera_cases,ortho_cases,ray_cases}.json` — six Node suite receipts

## Limits

- Single replay per surface; zero failures, no flake-retry needed.
- Host intermittence caveat carried from r68/r69 (`navagent3d_retarget`)
  did not manifest in this run.
- This baseline asserts nothing about mutation apply-order semantics —
  no committed arm composes cross-class setters in one tick; it only
  pins the pre-move surface the r77 arms must not regress. The one
  seed-digest delta vs the r76-verifier receipt is commit-owned
  (`8a67f71` refactor), demonstrated inert by the 163 byte-identical
  rows.
