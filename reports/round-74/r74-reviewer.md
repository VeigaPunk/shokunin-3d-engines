# Game-dev-3d round 74 — reviewer (non-author audit of round 73 committed state)

Reviewer did not author r73. Audited committed state: r73 work `b41fb33`
plus adjudication `e435a01` (= HEAD at audit time) in canonical repo
`~/Projects/shokunin/game-dev-3d-shokunin`, reached via the worktree symlink
`~/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d`. Scratch confined to
gitignored `corpus/live/r74-reviewer/`; this report is the only tracked write.
No commits, no subagents, LEAF.

Host: devin; `/usr/bin/godot` = `4.7.2.stable.arch_linux.ed1daf0bf` (same pin
as r73), Python 3.14.7, Node v24.21.0, three.js 0.186.1 (pre-provisioned
`corpus/fixtures/three/node_modules`).

## 1 — Fresh full battery re-execution: reproduced (127/127 + 4 probes)

Command (canonical repo root, ABSOLUTE `--runs` per the documented
convention):

```
python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
  --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r74-reviewer/runs \
  --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
```

Exit 0, `PASS battery`. Receipt
`corpus/live/r74-reviewer/runs/20261014T022415832979Z/verdicts.json`:

- `totals = {cases: 127, pass: 127, fail: 0, ordinary: 82, negative_controls: 45}` — **127/127 PASS**.
- `seeds_unchanged = true`; `seed_digests` 52 keys, **byte-identical to the
  r73-author receipt** (`corpus/live/r73-author/runs/20261014T015541463862Z/verdicts.json`).
- Probes **4/4**: `crash_probe_ok`, `stream_probe_ok`, `tree_probe_ok` all
  true; mutation probe `verdict=PASS` (`detected=true`,
  `mutant_body3d_contact` exit 1 with the authored contact-plane diagnostic).
- `tree-timeout-verdicts.json`: `witness_verified=true`, `witness_gone=true`,
  `witness_cleanup="SIGTERM to verified detached witness"`, `cleanup_exit=-9` —
  the absolute-path verified-witness path. `pgrep -fa timeout_descendant`
  post-run: clean (no leak).
- `godot_version = 4.7.2.stable.arch_linux.ed1daf0bf`; `verdict = PASS`.
- All **127** rows carry `marker ∈ stdout` (programmatic exact-substring
  check over the receipt, 0 misses); 15 rows are `navagent3d_detour_link_*`.

## 2 — Byte-exact replays (4 link arms, one per declared claim): verbatim

Scratch `corpus/live/r74-reviewer/scratch/` holds `git show HEAD:` blobs,
verified byte-identical to committed/disk state: `navagent3d_detour.gd`
sha256 `0ae04750b2041ba17bfb1835c70c40ad182e116ab87069be7fec05b1e4835ce4`
(= author's claimed post-change digest), `project.godot` sha256
`1fda90d46b0529aea0e75710a64f038cbf983adc8385285dd8bbe6202a8eac23`.
Each arm run as `timeout 60 /usr/bin/godot --headless --path <scratch>
--script res://navagent3d_detour.gd -- --arm=<name>`; programmatic compare of
the stdout marker line against the CASES-pinned literal in `run_battery.py`:

| arm | claim | exit | byte-exact vs CASES |
|---|---|---|---|
| `link_meta` (meta=7 node: types/rids/owner populated) | (a) | 0 | **True** |
| `link_oneway_rev` (exit-side → unreachable clamp) | (b) | 0 | **True** |
| `link_entercost` (enter_cost=100, link still chosen) | (c) | 0 | **True** |
| `link_pop_void` (pdd=4.0 → next across the void) | (d) | 0 | **True** |

Observed markers (verbatim stdout lines, each == the `run_battery.py:114/122/128/134` literal):

    PASS navagent3d_detour link_meta idx=1 next=1.500000,0.000000,0.500000 final=2.500000,0.000000,3.500000 dist=3.605551 pathlen=4.192582 reachable=true reached=false finished=false link=node meta=7 types=0,1,0,0 ridat=1 own=NavigationLink3D@1
    PASS navagent3d_detour link_oneway_rev idx=1 next=2.000000,0.000000,1.000000 final=2.500000,0.000000,4.000000 dist=5.385165 pathlen=4.622520 reachable=false reached=false finished=false link=server meta=1 types=0,0,0 ridat=-1 own=-
    PASS navagent3d_detour link_entercost idx=1 next=1.500000,0.000000,0.500000 final=2.500000,0.000000,3.500000 dist=3.605551 pathlen=4.192582 reachable=true reached=false finished=false link=server meta=1 types=0,1,0,0 ridat=-1 own=-
    PASS navagent3d_detour link_pop_void idx=3 next=2.500000,0.000000,5.500000 final=2.500000,0.000000,5.500000 dist=5.385165 pathlen=6.130649 reachable=true reached=false finished=false link=server meta=0 types=- ridat=-1 own=-

## 3 — r73 lesson + adjudication claims: hold on my fresh receipt

From `20261014T022415832979Z/verdicts.json` measured rows plus the replays:

1. **(a) Companion arrays under `path_metadata_flags`** — `link_shortcut`
   meta=0: link path taken yet `types=- ridat=-1 own=-` (all three arrays
   empty → opaque). `link_meta_types/rids/owners` populate per-bit;
   `link_meta` (meta=7 node) `types=0,1,0,0 ridat=1 own=NavigationLink3D@1`.
   Critic's opt-OUT correction confirmed by construction: fixture line 183
   sets `agent.path_metadata_flags` explicitly per arm (default `0`); the
   scout-verified engine default of 7 (PATH_METADATA_INCLUDE_ALL) is
   consistent with `link_*` arms pinning `meta` explicitly.
2. **(b) Three independent drop gates** — `link_layers_off` → corridor
   fallback `types=0,0,0` / `link_layers_on` restores link path;
   `link_oneway_fwd` traverses (`final=2.5,0,5.5`) vs `link_oneway_rev`
   clamps (`final=2.5,0,4.0 reachable=false`); `link_disabled` identical
   clamp. Read-back honesty gate live (`navagent3d_detour.gd:222-239`
   `_fail`s on any `link_get_*` mismatch).
3. **(c) enter_cost inert / travel_cost live** — `link_entercost` (100)
   tuple byte-identical to zero-cost `link_shortcut`; `link_travelcost`
   (10) → corridor `pathlen=4.130649`. Pinning note (verifier): the tracked
   arm pins e=100; the 10/1e6 extremes live in critic scratch sweeps.
4. **(d) Pop-through** — `link_gap` (no link) `final=2.5,0,4.0
   reachable=false` (void premise); `link_pop_bank` idx=2 next=near
   endpoint; `link_pop_void` idx=3 next=`2.5,0,5.5` across the void,
   `reachable=true finished=false`.
5. **Fixture integrity / diff scope** — `git diff 3f6a03d..b41fb33`
   numstat: `navagent3d_detour.gd` +337/−2 (the two deletions verified as
   the claimed mechanical folds: `mesh.vertices` → local `verts`, polygon
   literal → `want_polys`), `run_battery.py` +30/−0 (zero deletion lines —
   15 additive CASES rows at :105-134). `git diff b41fb33..e435a01` on
   `corpus/fixtures/` is **empty** (adjudication = LOG/SCORECARD/lesson/
   reports only). `_run_link_arm` (:733-812) fails exit 1 with named
   diagnostic on tuple/array/read-back mismatch — falsification paths live.
6. **Lesson file** `corpus/lessons/r73-navagent-link-gating-review.md`
   accurately restates the pinned semantics; its "adjudication-commit
   slot: b41fb33" line is a typo for `e435a01` (cosmetic, non-blocking).
   Claims standing on sibling receipts only (not re-derived by me):
   critic's enter_cost 1e6/−1e6 sweep, scribe's pdd=0.5 equality probe,
   boundary's symmetric retro pop-through + `link_connection_radius`
   strict-< + mid-flight endpoint-switch survey.

## 4 — Prior-row stability: reproduced, stronger

My receipt vs r73-author receipt
(`corpus/live/r73-author/runs/20261014T015541463862Z/verdicts.json`) on the
12-field tuple (case, script, flags, expected/actual exit, kind, marker,
verdict, reasons, stdout, stderr, error):

- prior rows absent in mine: **none**; new-only rows: **none**;
  **0 mismatches over 127 cases × 12 fields** — all 112 pre-r73 rows AND
  all 15 new link rows are byte-stable against the author's own receipt.

## 5 — Node three.js suites: reproduced (31/31)

From `corpus/fixtures/three/`, `node run_<s>.mjs --receipt
<ABS>/corpus/live/r74-reviewer/node/run_<s>.json` → run_cases 3/3,
run_layer_cases 4/4, run_order_cases 9/9, run_camera_cases 5/5,
run_ortho_cases 5/5, run_ray_cases 5/5 = **31/31 PASS**, every suite
`seedsUnchanged=true`, every exit 0, Node v24.21.0 / three.js 0.186.1.

## 6 — `--runs` docstring gap: STILL OPEN (confirmed absent)

The r73-reviewer flag is unfixed at HEAD `e435a01`; verified by direct read:

- `corpus/fixtures/run_battery.py` docstring lines 1–15: no `--runs`
  mention at all, no absolute-path requirement.
- `corpus/fixtures/README.md:23` documents `--runs /path/to/receipts` with
  no absolute-path note.
- Code unchanged: `args.runs` is consumed raw at `run_battery.py:641`
  (`run_dir = args.runs / stamp`); no `.resolve()` — a relative `--runs`
  still feeds the tree-timeout probe an unverifiable path → `FAIL battery`.
- `corpus/lessons/`: neither `r72-navagent-pdd-finish-review.md` nor
  `r73-navagent-link-gating-review.md` records the trap. Side observation:
  `r1-headless-verification.md:15` still shows a **relative** `--runs`
  example (`--runs corpus/live/runs`) — pre-trap era, harmless without
  `--probe-tree-timeout`, but a fresh seat copying it verbatim into a
  probed run reproduces the r69/r72 failure.
- The trap remains documented only in ledger/report surfaces:
  `SCORECARD.md:27`, `LOG.md:744,772`, `reports/round-69/r69-author.md:57-61`,
  `reports/round-72/r72-verifier.md`, `reports/round-73/r73-reviewer.md:111-149`.

## 7 — r74-author diff check

**No r74 author diff exists at audit time.** HEAD is `e435a01` (the r73
adjudication); `git status --porcelain` is empty; `corpus/live/` contains no
`r74-author` scratch; `git log` shows no post-adjudication commit. The r74
declared move (moving-agent navigation arms on the detour fixture) has not
landed; nothing has mutated prior arms. If the r74 author lands after this
audit, the drift check is the §4 comparison — this report's
`20261014T022415832979Z` receipt is the reference 127-row state.

## Findings by severity

- **No defect in the audited r73 committed state.** Every claim
  re-executed clean: 127/127 + 4/4 probes + Node 31/31, 0-mismatch over
  127×12 vs the author receipt, 4/4 byte-exact link-arm replays spanning
  all four declared claims, diff scope exactly as disclosed.
- **Minor / documentation gap (pre-existing, non-blocking, re-flagged):**
  the relative-`--runs` tree-timeout trap remains absent from
  `run_battery.py`'s docstring, `corpus/fixtures/README.md`, and
  `corpus/lessons/*`. Any dispatch spelling `--runs` relative with the
  tree probe enabled deterministically burns a full battery into FAIL.
  Not this seat's write scope.
- **Cosmetic:** r73 lesson line 74 "adjudication-commit slot: b41fb33"
  should read `e435a01`.

## Residual risk / verification gaps

- Bounded replay: same host, same Godot build, stationary/teleported
  agent — every r73 bound stands; the r74 declared move targets precisely
  this stationary-agent surface (frozen path array, live pop index, latch
  under motion, re-anchoring), so this is the known gap the incoming round
  exists to close, not a hidden one.
- The compared battery receipts are gitignored on-disk artifacts
  (carried-forward caveat).
- Sibling-receipt claims (critic 1e6 sweep, scribe pdd=0.5, boundary
  retro/connection-radius) were cross-checked for consistency, not
  re-derived from scratch probes.
- No `lsp` device is bound on this dispatch; caller/definition checks used
  text grep + direct reads as the literal fallback.
- This report is a recommendation; admission belongs to the canonical
  judge.
