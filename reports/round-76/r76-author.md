# r76 author — pinning the same-turn setter→server-sync window for NavigationServer3D mutations

Seat: `ufo-executor` (author lane, game-dev-3d). Brief: `.ufo/waves/shokunin-train-20261014-w7/tasks/g3d-author.txt`.
Repo: `game-dev-3d-shokunin` (worktree `~/Projects/prymeagnt/game-dev-3d` resolves here via symlink). HEAD at verification: `cb6bf7b`. All r76 changes are uncommitted in the working tree. No commit/push/merge/checkout performed. Leaf lane — zero subagent dispatches; the bounded pre-authoring spike ran as a scratch probe script I wrote and executed directly.

## Verdict on the declared claim

Declared: **"the sync boundary is frame-measurable — a forcing call on the same tick as a RID mutation serves the pre-mutation path while wait>=1 serves post-sync state; the exact frame count of the window is a stable measured constant on this host/build."**

**Confirmed that the window is a stable, frame-measurable constant; the `wait>=1` bound itself is falsified.** Measured on Godot `4.7.2.stable.arch_linux.ed1daf0bf` (headless, ~60 physics ticks/s) and committed as tracked CASES arms:

1. **Link mutation edge = 2 physics frames.** `link_set_enabled(false)` issued the same tick as a forcing read serves the pre-mutation path — and *pops through the dead hop*: tp+mutate+wait:0 advances the stored index `2→3` across the killed gate so `next` is the dead far endpoint `(2.5,0,5.5)`. At **+1 frame the stale serve persists** (`idx=3`, `next=(2.5,0,5.5)`). Only at **+2 frames** does the next forcing read re-query anchored at the live position: `[(2.5,0,3.4),(2.5,0,4.0)]`, `reachable=false`, `finished=true` via the idx+pdd unreachable clause. `wait>=1` is therefore *inside* the window, not past it. (`mut_win_link`.)
2. **Region transform edge = 3 physics frames** — one frame deeper than the link channel. `region_set_transform(+5x)` serves the pre-transform path verbatim at +0, +1, AND +2 frames; the re-queried path `[(5,0,0.5),(5,0,1.0)]` first appears at +3. The non-forcing `peek` at the +3 step still shows the stale stored array — the map has synced but the agent re-queries only inside the forcing call, pinning the two-stage gate at the edge frame itself. (`mut_win_region`.)
3. **`map_set_active(false)` has no edge — it is permanent-stale, not lazy-invalidating.** `map_is_active` reads back `false`, but the map leaves the sync iteration entirely: no iter bump, no dirty surfacing, and the committed tuple (`reachable=true` included) is served unchanged through forcing reads at +0, +10, +15 cumulative frames **with no finished latch**. Distinct mechanism from `mut_latch_zombie`: the latch is the agent update early-returning while the server still syncs; here the server never syncs. (`mut_map_off`.)
4. **Writes queued under an inactive map apply at the normal edge on reactivation.** `link_set_enabled(false)` while inactive: object getter applies, but the committed path is served verbatim through +5 idle frames. After `map_set_active(true)`, +1 frame is still stale and **+2 frames** re-queries clamped — reactivation re-arms the measured 2-frame window rather than applying retroactively. (`mut_map_cycle`.)
5. **Same-value writes are suppressed on every channel tested** (M-witness: teleport to `(1.5,0,0.5)` pops the index but never re-queries, so `path[0]` stays anchored at spawn `S`; a genuine re-query would re-anchor at M):
   - `link_set_enabled(link, true)` on an already-enabled link: no dirty — stale-anchored tuple persists through +5 frames. Contrast effective write in the same arm re-anchors at M. (`mut_same_link`.)
   - `region_set_navigation_layers(region, 1)` AND `region_set_transform(identity)` in one step — both suppress; the transform dedup is a full `Transform3D` value compare. Contrast `layers 1→2` empties the path. (`mut_same_region`.)
   - `agent.navigation_layers = 1` same-value: dedups **before** the synchronous clear — stored array intact same-turn (`peek` npath=3). Contrast effective write clears synchronously (`peek=[]` at wait:0, stale idx still readable) and the restore re-materializes anchored at M. (`mut_same_agent`.)

The durable r75 wording survives unchanged: *no dead waypoint is served after the server sync lands for an unlatched agent* — inside the window the stale path is served and pop-traversed (`mut_win_link` step 2 is exactly the critic's `idx=2→3` dead-hop reproduce, now a tracked CASE), and under the latch or an inactive map the stale path persists indefinitely.

## Files changed (uncommitted)

| file | delta | sha256 (working tree) |
|---|---|---|
| `corpus/fixtures/navagent3d_detour.gd` | +284/−6 | `066a06d290c27c870a1e411dace586d961282099b7ac2b8a740da35cb39a19e4` |
| `corpus/fixtures/run_battery.py` | +14/−0 | `6faa83560ac2ba69cc7032c899134ef33e32a497e3c1941a921e9d61a9b5cba1` |

`git diff --stat`: `2 files changed, 298 insertions(+), 6 deletions(-)`. `git status --porcelain`: only the two `M` files plus `?? reports/round-76/` (sibling reports + this file). The 6 removed lines are exactly: the four stale r75 step-comment lines that claimed `wait>=1` sufficed (replaced with the measured 2f/3f edges), the setup-gate `map_is_active` assertion (now compared against folded `fs["map_active"]` instead of hardcoded `true`), and the `fs` seed dict (gained `"map_active": true`).

### Fixture mechanism (additive)

- **`mutate` key `"map_active"`** (`_apply_mutation`, `navagent3d_detour.gd:1885-1886`): `NavigationServer3D.map_set_active(srv["map"], v)` — applied last in the dict order, after region/link/agent writes, so a queued RID write in the same dict stays invisible to queries under an inactive map.
- **`_final_srv_state` fold** (`1908`, `1938-1939`): `map_active` folds into final expected state; any arm whose last mutation flips it gets the readback gate for free.
- **Setup-gate readback** (`352-354`): `map_is_active(map) != fs["map_active"]` — a no-op `map_set_active` fails the arm instead of silently passing.
- **Cumulative-wait sampling**: `wait` counts physics frames after the step's mutate/tp; consecutive `wait:1` steps sample the forcing read at +0/+1/+2(+3) — the window edge is pinned without a nested wait primitive.
- **Header truth block** (`164-192`): records the measured edges (`link=2f`, `region_transform=3f`, `map_set_active(false)=NEVER`), the same-turn served-and-popped dead hop, the getter-vs-query two-stage timing (object-level truth ~1f, query-level 2-3f), and same-value suppression. The stale `wait>=1` comment at the `_run_steps` doc (`1150-1159`) now distinguishes the mutation-honesty readback edge (~1f) from the forcing-query edge (2f/3f).

### New arms (`navagent3d_detour.gd` 1409-1660) → new CASES rows (`run_battery.py` 198-211)

| row | clause | mutation | pinned result |
|---|---|---|---|
| `mut_win_link` | window edge | `link_set_enabled(false)` at wait 0/1/2 | +0: stale serve **pops 2→3 across dead gate**, `next=(2.5,0,5.5)`; +1: still stale `idx=3`; +2: re-query `[(2.5,0,3.4),(2.5,0,4.0)]` `finished=true` |
| `mut_win_region` | window edge | `region_set_transform(+5x)` at wait 0/1/2/3 | stale at +0/+1/+2 verbatim; +3: `[(5,0,0.5),(5,0,1.0)]` `reachable=false`; +3 peek still shows stale array (two-stage pin) |
| `mut_map_off` | permanent stale | `map_set_active(false)` | committed tuple + `reachable=true` served through +0/+10/+15 cumulative frames, no latch |
| `mut_map_cycle` | reactivation | `map_set_active(false)` → `link_set_enabled(false)` → `map_set_active(true)` | queued kill invisible while inactive; +1 post-reactivate stale, +2 clamps — normal window re-arms |
| `mut_same_link` | suppression | `link_set_enabled(true)` same-value at M-witness | stale-anchored tuple persists +5f; contrast effective write re-anchors `path[0]=M` |
| `mut_same_region` | suppression | `region_layers=1` + `region_transform=identity` same-value | both dedup; contrast `layers→2` empties path |
| `mut_same_agent` | suppression | `agent_layers=1` same-value | dedups before the synchronous clear (`peek` npath=3); contrast `→2` gives `peek=[]` same-turn, restore re-materializes |

## Evidence

- **Full battery (all four probes), exit 0:**
  `python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r76-author/runs/battery --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing`
  → `PASS battery: corpus/live/r76-author/runs/battery/20261014T101410997458Z/verdicts.json`
  (`verdict=PASS`, `totals: cases=163 pass=163 fail=0 ordinary=118 negative_controls=45 probes=4`, `seeds_unchanged=True`, `tree_probe_ok=True`, `crash_probe_ok=True`, `probe_failing=True` — the adversarial mutant was detected; its expected case-level `FAIL` line is the probe working, and `mutation-verdicts.json` verdict=PASS). Probe receipts: `{crash-exit,stream-attribution,tree-timeout,mutation}-verdicts.json` under the same run dir — all `verdict=PASS`. Stdout receipt: `corpus/live/r76-author/runs/battery_full.stdout.txt` (last line `PASS battery …`), stderr empty (`battery_full.stderr.txt`). All 156 prior rows re-ran under their pinned markers → 0 mismatches; all 7 new rows PASS.
- **Prior-row invariant:** `git diff` on `run_battery.py` is pure addition — 7 rows inserted after `navagent3d_detour_mut_latch_zombie` (198-211), before `remote3d_transform`; no existing row edited, reordered, or removed. CASES 156→163, ordinary 111→118.
- **Focused arm runs, 7/7 exit 0:** `corpus/live/r76-author/runs/arm_{mut_win_link,mut_win_region,mut_map_off,mut_map_cycle,mut_same_link,mut_same_region,mut_same_agent}.stdout.txt` — each contains exactly one `PASS navagent3d_detour <arm> …` marker matching its CASES expectation byte-for-byte; all seven `arm_*.stderr.txt` empty. Invoked as `timeout 30 /usr/bin/godot --headless --path corpus/live/r76-author/scratch/proj --script res://navagent3d_detour.gd -- --arm=<name>`.
- **Bounded pre-authoring spike:** `corpus/live/r76-author/scratch/proj/r76a_probe.gd` — seven scenarios (`win_link`, `win_region`, `map_off`, `map_cycle`, `same_link`, `same_region`, `same_agent`), all exit 0; these drove the pinned constants above (the tracked arms reproduce them byte-exact on first run).
- **Tree-timeout probe:** `20261014T101410997458Z/tree-timeout-verdicts.json` → `verdict=PASS`, `tree_probe_ok=True` in the main verdicts (absolute `--runs` path used — the r76 invocation avoided the r75 relative-path witness-identity failure).
- **Node suites, 31/31:** `corpus/live/r76-author/runs/node-*.json` — run_cases 3/3, run_layer_cases 4/4, run_order_cases 9/9, run_camera_cases 5/5, run_ortho_cases 5/5, run_ray_cases 5/5; every receipt `verdict=PASS`, `seedsUnchanged=true`, `node v24.21.0`, `three 0.186.1`; all six runner exits 0.
- **Seed integrity:** battery `seeds_unchanged=True` (fixture dir digested before/after); scratch copies ran under `corpus/live/r76-author/` only.

## Incidents during the round (resolved)

None blocking. One in-flight correction: the r75-era comment claimed `wait>=1` sufficed for post-sync reads — the measured edges (2f/3f) falsified that bound, and the comment was rewritten before landing. The `_run_steps` mutation-honesty gate also needed the `map_is_active` assertion generalized to `fs["map_active"]` so `mut_map_off`'s expected-inactive state passes the readback honestly rather than being hardcoded `true`.

## Remaining risks / blockers

- **None blocking.** Both window edges are pinned at frame resolution with the stale serve AND the post-sync tuple in one arm each; a future engine change that shifts the boundary, drops the same-turn dead-hop serve, starts serving pre-sync data after +1f, or makes `map_set_active(false)` invalidate eagerly fails byte-exact markers immediately.
- Residual: window edges are pinned for `link_set_enabled` (2f) and `region_set_transform` (3f); other mutation kinds (`link_layers`, `region_layers`, `region_delete`) follow the same lazy path but their exact per-channel edge constants are not separately armed — noted as an open edge, same as r75's link-under-latch note.
- The `map_set_active(false)` permanent-stale pin holds for the tested build; it is a stronger claim than the window claim and would be the first casualty of an engine-level "inactive maps still flush" change — that is by design (the arm exists to catch it).
- Fixture project hash unchanged: `1fda90d46b0529aea0e75710a64f038cbf983adc8385285dd8bbe6202a8eac23`.

No commit, push, or other runtime invocation performed. Stopping here.
