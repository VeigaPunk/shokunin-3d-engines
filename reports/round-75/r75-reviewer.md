# Game-dev-3d round 75 — reviewer (non-author audit of r74 committed state + landed r75 diff)

Reviewer did not author r74 or r75. Audit ran on the canonical repo
`~/Projects/shokunin/game-dev-3d-shokunin` (brief's `~/Projects/prymeagnt/...`
path is the stale prymeagnt worktree shell — the live repo is the shokunin one
named in the dispatch line). Scratch confined to gitignored
`corpus/live/r75-reviewer/`; this report is the only tracked write. No commits,
no subagents, LEAF.

Host: devin; `/usr/bin/godot` = `4.7.2.stable.arch_linux.ed1daf0bf` (same pin
as r73/r74), Python 3.14.7, Node v24.21.0, three.js 0.186.1.

**Timing note (material to scope):** HEAD moved mid-audit — `35a911c` at my
first `git log`, then `770299e` ("r74 boundary seat + pmd operand correction",
docs-only) at 02:09:50 -0300, then the r75-author diff landed in the working
tree during the audit (fixture mtime 02:12:31 -0300 per boundary's log), and
was finally **committed as `6498973`** ("r75: map/link mutation under
committed path — two-stage gate, zombie resolved") at 02:31:47 -0300 — while
this report was being written. The commit is byte-identical to the audited
working tree except for one 5-line header-comment correction (Finding 1 below)
and picks up all r75 sibling reports. My committed-state battery receipt
below was taken on the clean `35a911c`+`770299e`-era seed set before the diff
touched the tree (verified: `seeds_unchanged=true`, 145 cases — the r75 CASES
count is 156).

## 1 — Fresh full battery, r74 committed state: reproduced (145/145 + 4 probes)

Command (repo root, ABSOLUTE `--runs` per the documented trap):

```
python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
  --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r75-reviewer/runs \
  --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
```

Exit 0, `PASS battery`. Receipt
`corpus/live/r75-reviewer/runs/20261014T050427191143Z/verdicts.json`:

- `totals = {cases: 145, pass: 145, fail: 0, ordinary: 100,
  negative_controls: 45}` — **145/145 PASS** (127 pre-r74 + 18 `mv_*`).
- `seeds_unchanged = true`; `seed_digests` 52 keys **byte-identical** to the
  r74-author receipt (`corpus/live/r74-author/runs/20261014T041431092173Z/`,
  which is also the path the lesson cites).
- Row-level drift vs that same author receipt: **0 mismatches over 145 cases ×
  12 fields** (`case, script, flags, expected_exit, actual_exit, kind, marker,
  verdict, reasons, stdout, stderr, error`) — all prior rows byte-stable.
- `godot_version = 4.7.2.stable.arch_linux.ed1daf0bf`; `verdict = PASS`.
- Probes **4/4**: crash (`signaled` exit −15), stream attribution, tree-timeout
  (`witness_verified=true`, `witness_gone=true`,
  `witness_cleanup="SIGTERM to verified detached witness"`, `cleanup_exit=-9` —
  the absolute-path verified-witness path; `pgrep` post-run clean), mutation
  (`detected=true`, mutant exit 1 with the authored contact-plane diagnostic).
- All 145 rows carry `marker ∈ stdout` (programmatic exact-substring check,
  0 misses); 18 rows are `navagent3d_detour_mv_*`.

## 2 — Byte-exact replays, committed blobs (3 `mv_*` arms, one per lesson claim)

`corpus/live/r75-reviewer/scratch/` = `git show HEAD:` blobs, verified
byte-identical to disk: `navagent3d_detour.gd` sha256
`336898f4b711021a21e619385244e662168889ba5c52ec6812af9c5034601276`,
`project.godot` sha256 `1fda90d4…8eac23`. Ran
`godot --headless --path scratch --script res://navagent3d_detour.gd --
--arm=<name>`; programmatic compare of the stdout PASS line vs the CASES
literal in `run_battery.py`:

| arm | lesson claim exercised | exit | byte-exact |
|---|---|---|---|
| `mv_pmd_edge` | conditional freeze (4.995 frozen → 5.025 breach, idx reset, B-edge re-anchor) | 0 | **True** |
| `mv_unlatch` | same-value `target_position` unlatch + clear | 0 | **True** |
| `mv_reanchor_lazy` | lazy materialization anchor (post-teleport, not assignment-time) | 0 | **True** |

## 3 — r74 lesson claims: all four named claims survive on my measurements

`corpus/lessons/r74-navagent-moving-agent.md` (post-`770299e` text):

1. **Lazy forcing set** — verified *directly*, not just by receipt:
   `corpus/live/r75-reviewer/scratch/lazy_probe.gd` (own probe, exit 0):
   - Phase A/E: `set_target_position` + 30 physics frames with **zero** forcing
     calls → `get_current_navigation_path`=`[]`, idx=0 — pure readers never
     materialize; idle ticks change nothing.
   - Phase B: first `get_next_path_position()` synchronously materializes
     (`next=(2,0,1)`, then path=[S,(2,0,1),T], idx=1) — the forcing-getter set
     is real.
   - Phase D: same-value re-assignment → pure read shows `path=[]` (synchronous
     clear) + stale `idx=1` residue while `is_target_reached` already reads
     false — matches the lesson's "stale idx residue readable" and boundary's
     `e2` dirty-window measurement.
2. **Conditional freeze, strict-`<` on pmd** — `mv_pmd_edge` byte-exact
   (§2); scribe's exact-equality datapoint cross-checked on receipt
   `corpus/live/r74-scribe/runs/mz_pmd.stdout.txt` (`euc_to_p1=4.900000
   frozen=true` / **`5.000000` `frozen=false`** / `5.099020` `frozen=false`).
   Operand note: the gate operand was corrected to **leg-segment distance**
   (`path[idx-1]→path[idx]`) by the r74 boundary seat and absorbed by the
   adjudicator — `770299e` patched lesson line 30 accordingly; all pinned
   CASES tuples remain correct (waypoint and leg coincide at the pinned
   points — boundary's own caveat). See Finding 3 for the leftover stale
   wording.
3. **Same-value unlatch** — `mv_unlatch` byte-exact (§2): latched agent at
   (10,0,10) → same-value `set_target` unlatches, `idxs=1,0`, path re-anchored
   `[(3,0,4),fg]`, `reached=finished=false`.
4. **Lazy materialization anchor** — `mv_reanchor_lazy` byte-exact: set_target
   + teleport in one no-read window anchors `path[0]` at the post-teleport
   (2.6,0,2.0); `mv_reanchor_force` (battery-verified) anchors at read-time
   — the pair pins "anchored at the position live at the first forcing call."
5. **Fixture/diff claims** — `git diff e435a01..fc9915e` numstat:
   `navagent3d_detour.gd` +501/−5, `run_battery.py` +36/−0. The five deletions
   verified mechanical exactly as disclosed (header line, tp-branch fold
   ×2 lines, `expected_target` gate). `35a911c` and `770299e` touch no fixture
   code (LOG/SCORECARD/lesson/reports only).
6. **Map-mutation row** (lesson :51-54, "measured, NOT CASES-pinned") —
   critic receipts consistent: `fw_layermask`/`fw_al_mid` show EMPTY path +
   `final=(0,0,0)`; `fw_mapedit` shows the non-empty re-anchor
   `[(5,0,0.5),(5,0,1.0)]`. Cosmetic imprecision: the lesson line lumps
   `fw_mapedit` under "EMPTY path + final=(0,0,0) possible" — `fw_mapedit`
   itself produced a clamped 2-point path; the EMPTY outcome came from the
   layer-mask probes.

## 4 — Node three.js suites: reproduced (31/31)

From `corpus/fixtures/three/`, `node run_<s>.mjs --receipt
<ABS>/corpus/live/r75-reviewer/node/run_<s>.json` → run_cases 3/3,
run_layer_cases 4/4, run_order_cases 9/9, run_camera_cases 5/5,
run_ortho_cases 5/5, run_ray_cases 5/5 = **31/31 PASS**, every suite
`seedsUnchanged=true`, exit 0, Node v24.21.0 / three.js 0.186.1.

## 5 — r75-author diff check: additive, zero prior-arm mutation

Audited as working-tree diff (uncommitted at audit time; now committed as
`6498973`, byte-identical modulo the Finding-1 header fix — committed
`navagent3d_detour.gd` sha256 `04d881ee…`, `run_battery.py` sha256
`f99c48f8…` matching the author's cited digest). The audited diff:
`run_battery.py` **+22/−0** (11 `mut_*` CASES rows
appended after `mv_bridge_walk`; every prior row literal untouched),
`navagent3d_detour.gd` **+475/−11** (sha256 `dbe6a2ae…`, matches the author
report's cited digest). All 8 hunks inspected: doc block, `srv`/`fs` wiring,
`want_regions` gate, link-gate literal→`fs` fold + mutation-honesty gate, 11
`mut_*` arm configs, `_run_steps` signature (+`srv`) + `_apply_mutation` +
`_final_srv_state`, two `_run_motion_arm` `peek_*` branches. Every deletion is
a mechanical fold; for arms without `mutate`/`peek_*` keys the fold reproduces
the r73 literals verbatim (`_final_srv_state` defaults == old `arm_cfg` reads)
— verified structurally AND empirically:

- **My own WT battery run** (no probes; same absolute-`--runs` discipline):
  `corpus/live/r75-reviewer/runs-wt/20261014T051956990552Z/verdicts.json` —
  **156/156 PASS**, `seeds_unchanged=true`; **0 mismatches over 156 cases ×
  12 fields vs the author's own receipt**
  (`corpus/live/r75-author/runs/20261014T051912324357Z`, 4-probe PASS).
- WT replays byte-exact: `mut_link_kill`, `mut_layers_region`,
  `mut_region_move`, `mut_lazy`, `mut_latch_zombie` (5/11 sampled arms) plus
  `mv_pmd_edge`/`mv_walk` still exact under the refactored `_run_steps`.
- Declared claim verdict: **"the stored path is invalidated by map mutation" —
  CONFIRMED and sharpened.** Invalidation is lazy (stored array byte-stable
  through pure ticks — `peek`/`peek_only` pins), forcing-call-gated, and
  lands the r74 critic measurements as tracked arms (`mut_layers_region` =
  `fw_layermask`'s EMPTY+`final=(0,0,0)`; `mut_region_move` = `fw_mapedit`'s
  `[(5,0,0.5),(5,0,1.0)]` clamp). The zombie waypoint exists as stored data
  and is never served *post-sync* to unlatched agents; under the `finished`
  latch it IS served (`mut_latch_zombie` survives region transform AND
  delete, `reachable=true` on a deleted map). One synchronous exception
  pinned: `agent.navigation_layers` clears the stored path same-turn
  (`mut_layers_agent` peek `[]`, stale idx readable).

## 6 — `--runs` docstring gap: STILL OPEN (re-flagged, now with fresh burns)

Unfixed at HEAD `770299e`, verified by direct read of the working tree:

- `corpus/fixtures/run_battery.py` docstring lines 1–15: no `--runs` mention,
  no absolute-path requirement; `args.runs` consumed raw at line 677
  (`run_dir = args.runs / stamp`) — no `.resolve()`.
- `corpus/fixtures/README.md:23`: `--runs /path/to/receipts`, no absolute note.
- `corpus/lessons/`: no lesson records the trap; `r1-headless-verification.md:15`
  still shows a **relative** `--runs corpus/live/runs` example.
- Trap mechanism confirmed by reading `timeout_tree3d.gd`:
  `ProjectSettings.globalize_path` puts ABSOLUTE paths in the witness cmdline,
  so a relative `scratch` prefix in `same_live_witness()`/`witness_verified`
  can never match → `witness_verified=false` → `FAIL battery`.
- **Fresh evidence it still burns seats:** the r75 author's own report
  (`r75-author.md` §Incidents) records TWO full 156-case batteries failed by
  exactly this trap (`tree_probe_ok=false` on a relative `--runs`) before
  re-running absolute. The adjudicator queued the fix "for wave-6
  housekeeping" — still absent.

## Findings by severity

1. **Medium — falsified durable wording (r75 header + author report) —
   CONFIRMED BY ME, FIXED IN THE LANDED COMMIT.** Working-tree
   `navagent3d_detour.gd` header (~line 148) and `mut_link_kill`'s comment
   claimed "**no dead-hop point is ever SERVED**"; `r75-author.md:12` repeated
   "never served to an unlatched agent." **Falsified inside the setter→map-sync
   window**: the update runs on the last-synced map, so a same-turn forcing
   call serves AND pop-traverses the dead gate. Independently reproduced on my
   own probe (`corpus/live/r75-reviewer/scratch-wt/zw_probe.gd`, exit 0):
   `pre-kill idx=2` (agent on (2.5,0,3.4), leg-seg dist 0.1<pdd) →
   `link_set_enabled(false)` → same-turn `link_get_enabled=true`, `iter=1`
   (server truth stale) → same-turn `get_next_path_position()` returns
   **`idx=3`, `next=(2.5,0,5.5)` — the killed link's far endpoint served and
   popped**, stored array untouched. Post-sync (5 frames): `en=false`,
   `iter=2`, re-query `[(2.5,0,3.4),(2.5,0,4.0)]`, `finished=true`. Convergent
   with critic `zw_popgate_sameturn` and boundary's latency bisect
   (query-visible at **2 frames link / 3 frames region transform**; all 11
   authored arms use `wait≥5`, so every pinned CASES marker was already
   correct post-sync — only the prose universal failed). **Disposition: the
   landed commit `6498973` corrected the header before landing** — committed
   text now reads "no dead waypoint is served after the server sync lands (~2
   physics frames for link toggles, ~3 for region_set_transform — a same-turn
   forcing call inside the setter->sync window still serves the stale hop, and
   mutate steps therefore need wait>=1 before their forcing read)", and the
   commit message credits the falsification. Committed blob verified
   (`navagent3d_detour.gd` sha256 `04d881ee…` = audited `dbe6a2ae…` + this
   comment only; `mut_link_kill`/`mut_latch_zombie` replayed byte-exact on it).
   Residual: `r75-author.md:12` still carries the stale universal — authored
   report, self-contained stale sentence.
2. **Medium-latent — mutation-honesty gate is sync-blind (bounds CASES
   expressibility, not current correctness); NOW DOCUMENTED, still latent.**
   The `_final_srv_state`/`link` readback gate reads *pre-sync* server truth:
   a **terminal** `wait:0` mutate step fails `authored link flags not in
   effect` even though the setter issued — my repro `mut_zw_terminal` on the
   author's own machinery exits 1 at the gate. The finer bound I measured is
   narrower than the critic's "surface cannot express the window": a
   **mid-step** `wait:0` mutate followed by a `wait≥1` step passes the gate
   — my injected `mut_zw_sameturn` arm (scratch-only, exit-0 PASS,
   `idxs=2,3,1 … finished=true`) pins the same-turn zombie serve AND the
   post-sync re-query in one arm. The committed header comment now documents
   the bound ("mutate steps therefore need wait>=1"), so this is a documented
   limitation rather than an undocumented trap; the machinery itself is
   unchanged — an arm whose **last** mutation hasn't synced by arm end still
   cannot be authored, and a `peek_only` LAST step would `KeyError` on `stf`
   (simplifier-flagged, malformed-config class).
3. **Minor — stale pmd-gate wording persists after the `770299e` correction.**
   `corpus/lessons/r74-navagent-moving-agent.md:49` still reads
   `euclid(agent, path[idx]) >= path_max_distance` (waypoint operand) in the
   invalidation-triggers list — inconsistent with the same file's corrected
   line 30 (leg-segment). Fixture header `navagent3d_detour.gd:83` still says
   "within `path_max_distance` (default 5.0, STRICT >) of the CURRENT next
   waypoint" — stale on *both* axes (operand = leg segment; breach is
   inclusive `>=`, i.e. freeze is strict `<`). Committed docs; CASES tuples
   unaffected since the two operands coincide at every pinned point.
4. **Minor — lesson attribution slip.** `r74-navagent-moving-agent.md:53`
   cites `fw_mapedit` under "EMPTY path + `final=(0,0,0)`"; the `fw_mapedit`
   receipt actually shows a non-empty re-anchor `[(5,0,0.5),(5,0,1.0)]`
   (EMPTY is `fw_layermask`/`fw_al_mid`). Cosmetic.
5. **Re-flagged — `--runs` docstring gap** (§6): still absent from
   docstring/README/lessons/code; now with two author-burned batteries as
   evidence the trap is live.
6. **Info — uncovered mutation/invalidation regimes** (sibling-measured,
   consistent, unpinned): `map_set_active(map,false)` produces **no iter bump**
   → the committed agent serves its stale path *forever with no latch*
   (scout) — arguably the starkest zombie regime and within the declared
   axis family; the 2/3-frame sync latencies (boundary); map-wide eager
   invalidation incl. irrelevant objects + same-value-write suppression
   (boundary `um_*`; single-agent CASES surface can't pin the multi-agent
   half — both critic and boundary note this); link-disable-under-latch
   unpinned (author-flagged open edge).
7. **Info — transient mid-edit crash (self-resolved).** Boundary observed a
   02:12:30 snapshot missing the `peek_only` branch crash `mut_lazy`/hang
   (exit 124); the landed file one second later contains the branch and
   passes. Landed state verified clean by my 156/156 run.

## Residual risk / verification gaps

- My committed-state battery (finished ~05:08Z) predates the WT diff
  (fixture mtime 05:12:31Z) — clean separation; `seeds_unchanged=true` proves
  the seed set was untouched through the run.
- The WT battery run omitted the 4 probes (speed); the author's probed
  receipt exists and matches mine on all 156 rows × 12 fields, and the probes
  are nav-fixture-independent. The committed landing (`6498973`) differs from
  my audited WT file only by the Finding-1 header comment; I replayed
  `mut_link_kill`/`mut_latch_zombie` on the committed blob from
  `scratch-commit/` — byte-exact PASS markers, no functional drift.
- My `mut_zw_sameturn`/`mut_zw_terminal` test arms exist only in
  `corpus/live/r75-reviewer/scratch-wt/` — injected probes, never part of the
  author's CASES (committed file confirmed clean of them).
- Node suites were run on committed state; `corpus/fixtures/three/*` is
  untouched by the r75 diff, so the result carries.
- Sibling-scratch claims (sync latency numbers, map-wide dirty, same-value
  suppression, `map_set_active` inertness) were cross-checked for
  consistency; I re-derived the load-bearing falsification (same-turn zombie
  serve + stale server getters) independently, plus the expressibility bound.
- Compared receipts are gitignored on-disk artifacts (carried-forward caveat).
- No `lsp` device is bound on this dispatch; caller/definition checks used
  text grep + direct reads as the documented literal fallback.
- My scratch probes leak RIDs at exit (no `free_rid` in teardown) — scratch
  artifacts only, no claim affected.
- This report is a recommendation; admission belongs to the canonical judge.
