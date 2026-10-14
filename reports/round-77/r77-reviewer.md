# Game-dev-3d round 77 — reviewer (committed-state audit of the r76 battery on HEAD)

Reviewer did not author r76 or r77. Per the brief, this audit re-ran the r76
committed battery (`163/163 + 4 probes + Node 31/31`) on HEAD and re-verified
the r76 adjudication claims while the r77 author diff is in flight. Audit repo:
the canonical `~/Projects/shokunin/game-dev-3d-shokunin` (the brief's
`~/Projects/prymeagnt/game-dev-3d` path is the stale prymeagnt worktree shell —
`.shokunin/game-dev-3d` there symlinks here; same resolution as r75/r76
reviewers). Scratch confined to gitignored `corpus/live/r77-reviewer/`; this
report is the only tracked-path write. No commits, no subagents, LEAF.

**Audited state:** HEAD `e417365821194a98b7a018cf4f23a5c82735bb8f`
("r76 report-last: ADMIT — per-class sync edges
{link:2,region:3,map_off:perm,agent:0} four-way converged + suppression pins;
verifier AGREE 5/5; lesson/LOG/SCORECARD"), containing work commit `3ab09fd` +
hygiene `8a67f71`. Working tree clean at audit start, at battery end, and at
report write (`git status --porcelain`: only `?? reports/round-77/` — the
sibling baseline seat's `r77-baseline.md`; the r77 author diff had **not**
landed in the working tree during the audit window). The audit ran on a
`git archive HEAD corpus/fixtures | tar -x -C corpus/live/r77-reviewer/head`
snapshot — immune to any mid-run landing. Extraction verified byte-identical to
the live tree (`run_battery.py` sha256
`6faa83560ac2ba69cc7032c899134ef33e32a497e3c1941a921e9d61a9b5cba1`,
`navagent3d_detour.gd` sha256
`13af380467c00da9477a42626c42fcc516b165d7c2e94f116413c72572f24735` — identical
in snapshot and worktree both).

Host: devin; `/usr/bin/godot` = `4.7.2.stable.arch_linux.ed1daf0bf` (same pin
as r73–r76), Python 3.14.7, Node v24.21.0, three.js 0.186.1.

## 1 — Full battery on committed HEAD: reproduced (163/163 + 4 probes)

```
python3 head/corpus/fixtures/run_battery.py --godot /usr/bin/godot \
  --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r77-reviewer/runs \
  --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
```

ABSOLUTE `--runs` per the documented trap. Exit 0, `PASS battery`. Receipt
`corpus/live/r77-reviewer/runs/20261014T104813952010Z/verdicts.json`:

- `verdict=PASS`, `totals = {cases: 163, pass: 163, fail: 0, ordinary: 118,
  negative_controls: 45}`, `probes=4` — exactly the r76 shape.
- `seeds_unchanged=true`, `seed_digests` = 52 keys on the extracted snapshot;
  `godot_version = 4.7.2.stable.arch_linux.ed1daf0bf`;
  `tree_probe_ok=crash_probe_ok=stream_probe_ok=probe_failing=true`.
- Probe receipts (same run dir) all `verdict=PASS` with their bounded claims:
  crash-exit (SIGTERM vs normal exit marker `CRASH_EXIT_3D`),
  stream-attribution (`STREAM_3D_STDERR` diagnostic split), tree-timeout
  (detached witness terminated, no strays), mutation probe `detected=true,
  seeds_unchanged=true` (the `body3d_contact` wall-depth 4→6 mutant caught).

## 2 — Drift analysis vs prior receipts: none at row granularity

Field-level compare over `case, script, flags, expected_exit, actual_exit,
kind, marker, verdict, reasons, stdout, stderr, error` (12 fields):

- vs `corpus/live/r76-verifier/runs/20261014T102343921913Z/verdicts.json`
  (163-row run on `3ab09fd`): identical case order, **0 mismatches over
  163 cases × 12 fields**. `seed_digests`: 52 keys each, exactly ONE differs —
  `navagent3d_detour.gd` (`13af3804…` at HEAD vs `066a06d2…` at `3ab09fd`),
  fully accounted for by `git log 3ab09fd..HEAD -- corpus/fixtures` = only
  `8a67f71`, and `git diff 3ab09fd 8a67f71` = `navagent3d_detour.gd` +33/−86 —
  the committed `_check_tuple` shared-predicate extraction. Zero CASES-table
  delta: `run_battery.py` digest identical (`6faa8356…`). The 0-mismatch row
  compare is a full-granularity re-confirmation that the refactor is
  observably byte-identical (all stdout/stderr/marker fields equal), matching
  the simplifier's 78/78 + 19/19 and the adjudicator's 163/163 claims.
- vs `corpus/live/r76-baseline/runs/20261014T095009263752Z/verdicts.json`
  (156-row r75 committed state): all 156 shared rows **0 mismatches**; the
  only additions are exactly the 7 r76 rows (`mut_win_link`, `mut_win_region`,
  `mut_map_off`, `mut_map_cycle`, `mut_same_{link,region,agent}`) — the
  "prior 156 rows byte-stable" invariant holds on HEAD.
- vs `corpus/live/r77-baseline/runs/20261014T105018199403Z/verdicts.json`
  (sibling seat's independent frozen-HEAD battery ~2 min after mine):
  identical order, **0 mismatches**, identical `seed_digests` — two
  independent byte-identical committed-state batteries on `e417365`.

## 3 — `mut_*` arms: all 18 present, all byte-exact in independent replay

All 18 `navagent3d_detour_mut_*` rows are committed CASES entries
(`run_battery.py:176-211`) and all PASS in the battery. Each was additionally
replayed standalone on the extracted-HEAD fixture —
`godot --headless --path replays/proj --script res://navagent3d_detour.gd --
--arm=<name>` — 18/18 exit 0, empty stderr, and the single `PASS` line is
**byte-exact** against the committed CASES literal
(`corpus/live/r77-reviewer/replays/<arm>.stdout.txt`):

| arm | byte-exact | arm | byte-exact |
|---|---|---|---|
| `mut_link_kill` | yes | `mut_lazy` | yes |
| `mut_link_drop` | yes | `mut_latch_zombie` | yes |
| `mut_link_layers` | yes | `mut_win_link` | yes |
| `mut_layers_agent` | yes | `mut_win_region` | yes |
| `mut_layers_region` | yes | `mut_map_off` | yes |
| `mut_region_move` | yes | `mut_map_cycle` | yes |
| `mut_region_off` | yes | `mut_same_link` | yes |
| `mut_region_renew` | yes | `mut_same_region` | yes |
| `mut_link_revive` | yes | `mut_same_agent` | yes |

## 4 — Node three.js suites: reproduced (31/31)

On the extracted-HEAD `three/` (`node_modules` gitignored — symlinked to the
repo's; all tracked `.mjs`/json are HEAD blobs), each runner invoked with
`--receipt` writing into `corpus/live/r77-reviewer/node/`: `run_cases` 3/3,
`run_layer_cases` 4/4, `run_order_cases` 9/9, `run_camera_cases` 5/5,
`run_ortho_cases` 5/5, `run_ray_cases` 5/5 = **31/31 PASS**, every receipt
`verdict=PASS`, `seedsUnchanged=true`, Node `v24.21.0`, three `0.186.1`.

## 5 — r76 adjudication claims re-verified on HEAD

- **Per-class edges {link:2, region:3, map_off:perm, agent:0}** — VERIFIED.
  The pinned wait ladders reproduce byte-exact: `mut_win_link` (wait 0/1/1)
  serves stale at +0 — popping idx 2→3 *across the killed gate* with
  `next=(2.5,0,5.5)` the dead far endpoint — stale at +1, re-query clamped to
  `[(2.5,0,3.4),(2.5,0,4.0)]` at +2 (`idxs=2,3,3,1` → **edge 2f**);
  `mut_win_region` (wait 0/1/1/1) stale verbatim at +0/+1/+2, re-queries
  `[(5,0,0.5),(5,0,1.0)]` at +3 with the +3 peek still showing the stale
  stored array — the two-stage pin (`idxs=1,1,1,0` → **edge 3f**);
  `mut_map_off` serves the committed tuple incl. `reachable=true` through
  +0/+10/+15 cumulative frames with no latch (`steps=3 idxs=1,1,1` →
  **permanent-stale**, mechanism distinct from `mut_latch_zombie`);
  `mut_same_agent`'s contrast write `agent_layers 1→2` clears `peek_path=[]`
  at wait:0 — **agent channel synchronous at 0**.
- **`map_off` queue/flush semantics** — VERIFIED via `mut_map_cycle`:
  `link_enabled:false` queued under an inactive map stays invisible through
  +5 idle frames; after `map_set_active(true)`, +1 still stale and +2 clamps
  — reactivation re-arms the normal 2-frame window (`steps=4 idxs=1,1,1,1`).
- **Same-value suppression** — VERIFIED via all three `mut_same_*` arms
  byte-exact: `mut_same_link` (same-value `link_set_enabled(true)` leaves the
  M-witness tuple anchored at spawn S through +5f; the effective `→false`
  write re-anchors `path[0]=M` — suppression-vs-requery contrast inside one
  arm); `mut_same_region` (both `region_layers=1` and `transform=identity`
  dedup; contrast `layers→2` empties the path); `mut_same_agent` (same-value
  `navigation_layers=1` dedups *before* the synchronous clear — `peek`
  npath=3, not `[]`).
- **Callsite qualifier** — VERIFIED by independent reproduction. I copied the
  critic's probe `corpus/live/r76-critic/scratch/r76c_window.gd` into my own
  scratch (`corpus/live/r77-reviewer/probe_phys/`) and re-ran
  `--arm=bb_physmut` on HEAD: exit 0, empty stderr, stdout **byte-identical**
  to the critic's committed receipt (`diff` clean). The `_physics_process`
  write (`link_set_enabled(false)` at mutator tick 2) applies in that same
  tick's drain — `link_iter=2`, `link_en=false` already at the first
  post-write sample (t1) — while `map_iter` bumps one tick later and the
  forcing read flips at await-count 1 after the write tick (t1 stale, t2
  clamped to `(2.5,0,4.0)`, `reachable=false`) vs await-count 2 for the
  identical coroutine-context write. Frame constants are per-callsite-class,
  as adjudicated.
- **wait≥1 readback-gate invariant** — VERIFIED by static parse: all 18
  steps-bearing mutation arms have ≥1 cumulative physics frame between the
  LAST `mutate` and arm end (`wait` defaults to 5 when absent —
  `navagent3d_detour.gd:1818`); min observed = **2f** (`mut_win_link`,
  `mut_map_cycle`), matching the verifier's claim-4 numbers exactly.

## Findings by severity

1. **None — no drift.** The r76 committed battery is byte-exact reproducible
   on HEAD `e417365`: 163/163 cases, 4/4 probes, `seeds_unchanged`, all 18
   `mut_*` arms PASS in-battery and byte-exact in independent replay, Node
   31/31. Every adjudication claim (per-class edges, map_off regime,
   callsite qualifier, same-value suppression, readback-gate invariant)
   re-verified.
2. **Info — prior-row stability chain complete.** 156 r75 rows are
   byte-stable vs `r76-baseline`'s pre-r76 receipt; the full 163 are
   byte-identical vs `r76-verifier` (modulo the expected single seed-digest
   delta from the committed `8a67f71` hygiene refactor, which is itself
   proven observably inert by the 0-mismatch row compare). The r77 author's
   "all 163 prior rows byte-stable" invariant therefore starts from a
   verified-clean base.
3. **Info — concurrent sibling activity observed, not touching my audit:**
   the r77-baseline seat's battery ran ~2 min after mine on its own frozen
   tree; both receipts are byte-identical row-for-row (§2), which doubles as
   an inter-seat convergence check. The r77 author diff had not landed in
   the working tree during the audit window.

## Residual risk / verification gaps

- The audit ran on a `git archive HEAD` extraction rather than the working
  tree — a stricter reading of "committed state"; snapshot proven
  byte-identical to the live fixture dir by sha256 spot-checks and by the
  battery's own `seed_digests` matching the r77-baseline seat's frozen-tree
  digests.
- `bb_physmut` was run from a copied script in my scratch project — the copy
  is verbatim (`diff` byte-identical output vs the critic's receipt), so the
  callsite-qualifier verification inherits the critic probe's semantics
  rather than re-deriving them; the physics-callsite edge remains a measured
  claim, not a tracked CASES row (the lesson itself flags a tracked
  physics-callsite arm as future work).
- `map_force_update` and apply-order arms are the r77 axis — not committed at
  HEAD, correctly absent from CASES; no coverage claimed or implied here.
- Compared receipts are gitignored on-disk artifacts (carried-forward caveat).
- This report is a recommendation; admission belongs to the canonical judge.
