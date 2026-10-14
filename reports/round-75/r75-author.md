# r75 author — NavigationAgent3D server-side map/link mutation vs materialized stored path

Seat: `ufo-executor` (author lane, game-dev-3d). Brief: `.ufo/waves/shokunin-train-20261014-w6/tasks/g3d-author.txt`.
Repo: `game-dev-3d-shokunin`. HEAD at verification: `770299e` (`r74 boundary seat + pmd operand correction`). All r75 changes are uncommitted in the working tree. No commit/push/merge performed.

## Verdict on the declared claim

Declared: **"the stored path is invalidated by map mutation."**

**Refined, and falsified in one pinned corner.** Measured on Godot `4.7.2.stable.arch_linux.ed1daf0bf` and committed as tracked CASES arms:

1. **Unlatched agents: invalidated, but LAZILY — not eagerly.** Every map/link/region mutation (link `enabled`, link `layers`, agent `layers`, region `layers`/`enabled`/`transform`, region delete/recreate) leaves the stored array and pop index byte-identical through pure physics ticks — `peek` (non-forcing `get_current_navigation_path`/`_index`) still reads the pre-mutation coordinates, dead link hop included. Invalidation happens *inside the first forcing call* (`get_next_path_position`/`is_navigation_finished`), which re-queries anchored at the live agent position before popping — so the dead waypoint exists only as stored data and is **never served** to an unlatched agent.
2. **Falsified under the finished latch.** Once `is_navigation_finished` has latched, the update loop early-returns and invalidation is gated off with it: a latched agent keeps **serving** the pre-mutation path through `region_transform +5x` AND full `region_delete` — `next=(2,0,3)`, `reachable=true`, `finished=true` on a map that no longer contains the region. This is the only genuinely served zombie. (`mut_latch_zombie`.)
3. **One synchronous exception on the agent side.** Writing `agent.navigation_layers` clears the stored path same-turn (`peek=[]` at 0 frames) while the pop index stays readable-stale (`peek_idx=1`). All server-side (RID-level) mutations are lazy.
4. **Re-mutations rematerialize without retargeting.** link re-enable, agent re-layer, region re-enable, region recreate all re-query and re-materialize the path on the next forcing call.
5. **Empty-path tuple pinned:** `idx=0`, `next`=agent position (not `(0,0,0)`), `final=(0,0,0)`, `path=[]`, `reachable=false`, `dist`=live euclid to raw target, `reached=finished=false`.

Fixture header lines 132-162 carry the full measured comment block.

## Files changed (uncommitted)

| file | delta | sha256 (working tree) |
|---|---|---|
| `corpus/fixtures/navagent3d_detour.gd` | +475/−11 | `dbe6a2ae10de9a5d6fa4314ae5f3e0a1b9ff8c02cc77da99c714a7392c5586dc` |
| `corpus/fixtures/run_battery.py` | +22/−0 | `f99c48f8e1671b7759aa57b3616771652d21578d363fdde048ebef2a1686844e` |

`git diff --stat`: `2 files changed, 486 insertions(+), 11 deletions(-)`. `git status --short`: only the two `M` files plus `?? reports/round-75/` (sibling reports + this file). The 11 removed fixture lines are a mechanical refactor — the old literal post-setup gate became the folded `_final_srv_state` gate, and `_run_steps` gained a `srv` parameter; for arms with no `mutate` step the fold emits the r73 literals verbatim (all 145 prior rows PASS byte-exact, see Evidence).

### Fixture mechanism (additive)

- **Step keys** (`navagent3d_detour.gd` `_run_steps`, lines 1547-1572): `mutate` dict applied after `set_target`/`tp`, before `wait`; `peek_path`/`peek_idx` = non-forcing stored-path/index capture after the wait but before the step's forcing `_read_state`; `peek_only` = a step that performs ONLY the non-forcing capture (its `path`/`idx` pin the stale stored state — mutation with no forcing call at all).
- **`_apply_mutation`** (1579-1606): `region_delete`/`region_recreate` rebuild the region RID inside `srv` (recreated region re-joins the same map/mesh; order is fixed: delete → recreate → transform/enabled/layers → link → agent). Keys: `link_enabled`, `link_layers`, `agent_layers`, `region_enabled`, `region_layers`, `region_transform`, `region_delete`, `region_recreate`.
- **`_final_srv_state`** (1613-1657) + readback gate (344-358): folds authored arm flags plus every step's `mutate` dict into the final expected server state, then reads it back after the steps — a no-op setter fails the arm instead of silently passing.
- **`_run_motion_arm`** (1663+) asserts `peek_idx`/`peek_path`/`peek_only` expectations per step (lines 1697-1730), on top of the existing per-step tuple+path pins.
- **`srv` dict + `fs` fold** wired at 291-296.

### New arms (1110-1370) → new CASES rows (`run_battery.py` 171-192)

| row | clause | mutation | pinned result |
|---|---|---|---|
| `mut_link_kill` | (a) link disable mid-path | kill at idx=3 pointing INTO dead far endpoint | stale hop visible via peek, then re-query `[(2.5,0,3.4),(2.5,0,4.0)]` `finished=true` via idx+pdd clause — no zombie served |
| `mut_link_drop` | (a) | kill from spawn, then teleport onto bank | re-query corridor clamp; follow-up pops on NEW path (idx=1 not 3) |
| `mut_link_layers` | (a) layer flip | `link_set_navigation_layers 2` | same re-query, `reachable=false` |
| `mut_layers_agent` | (b) | `agent_layers` 2 → 1 | synchronous clear (`peek=[]`), re-layer rematerializes link path `reachable=true` |
| `mut_layers_region` | (b) | `region_layers` 2 | lazy clear; forcing read → empty-path tuple `final=(0,0,0)` |
| `mut_region_move` | (c) | `region_transform +5x` | re-query `[(5,0,0.5),(5,0,1.0)]` |
| `mut_region_off` | (c) | disable → re-enable | disable → empty tuple; re-enable → path rematerializes `reachable=true` |
| `mut_region_renew` | (c) | delete → recreate | delete → empty tuple; recreate → path rematerializes |
| `mut_link_revive` | (d) | disable → re-enable | dead hop restored on next forcing call, full link path back |
| `mut_lazy` | (e) | `peek_only` step, `wait=10` | stale array+idx byte-identical with zero forcing calls; forcing read re-queries on step 2 |
| `mut_latch_zombie` | falsification | latch, then `region_transform +5x`, then `region_delete` | **served zombie**: `next=2.000000,0.000000,3.000000` `reachable=true` `finished=true` through both mutations |

## Evidence

- **Full battery (all four probes), exit 0:**
  `python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r75-author/runs --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing`
  → `PASS battery: corpus/live/r75-author/runs/20261014T051912324357Z/verdicts.json`
  (`verdict=PASS`, `totals: cases=156 pass=156 fail=0 ordinary=111 negative_controls=45 probes=4`, `seeds_unchanged=True`, `tree_probe_ok/crash_probe_ok/stream_probe_ok=true`, `probe_failing` detected the mutant). Stdout receipt: `runs/battery-r75-full2.out` (last line `PASS battery …`). Every one of the 145 prior rows re-ran under its pinned marker → 0 mismatches; all 11 `mut_*` rows PASS.
- **Prior-row invariant (tuple level):** `git show HEAD:corpus/fixtures/run_battery.py` vs working tree — `old CASES: 145 | new CASES: 156`, `missing/reordered old rows: []`, `added rows:` exactly the 11 `navagent3d_detour_mut_*` names, in order after `navagent3d_detour_mv_bridge_walk`.
- **Focused arm run:** `corpus/live/r75-author/runs/arm_mut_*.stdout.txt` — 11 files each containing exactly one `PASS navagent3d_detour mut_* …` marker (e.g. `arm_mut_link_kill.stdout.txt`, `arm_mut_latch_zombie.stdout.txt`); all 11 `arm_mut_*.stderr.txt` empty.
- **Measurement probe (pre-authoring):** `corpus/live/r75-author/scratch/r75_mut_probe.gd` (208 lines), 13 scenario receipts `runs/s*.stdout.txt` (`s1_link_kill_idle` … `s12_latch_peek`) — each ends `DONE <scenario>`; these drove the pinned expectations.
- **Tree-timeout probe:** `20261014T051912324357Z/tree-timeout-verdicts.json` → `verdict=PASS`, normal half exit 0 with exact marker `TREE_TIMEOUT_3D: spatial node ready`, timeout half `timed_out`, `marker_observed`, `cleanup_exit=-9` (witness verified then SIGKILL'd, matching r74's pass shape).
- **Node suites, 31/31:** `runs/node-*.json` — run_cases 3/3, run_layer_cases 4/4, run_order_cases 9/9, run_camera_cases 5/5, run_ortho_cases 5/5, run_ray_cases 5/5; every receipt `verdict=PASS`, `seedsUnchanged=true`, `node v24.21.0`, `three 0.186.1`.

## Incidents during the round (resolved)

Two earlier full-battery invocations (`runs/20261014T051310362537Z`, `runs/20261014T051627765180Z`) exited 1 with `tree_probe_ok=false` while all 156 cases and the other three probes passed. Root cause was my invocation, not the code: the tree probe's witness-identity check compares `str(scratch/'timeout_descendant.py')` against the witness's **absolute** `/proc` cmdline, and I had passed `--runs` as a *relative* path, making the substring check structurally unmatchable (`witness_verified=false`, cleanup skipped, stray witness left to self-expire). Re-running with an absolute `--runs` produced the PASS receipt above — no harness edits. Stray witnesses from the failed runs self-expired / were cleaned; none remain.

## Remaining risks / blockers

- **None blocking.** The lazy-vs-latched distinction is now pinned twice per mutation kind (peek before force, full tuple after), so a future engine change that makes unlatched invalidation eager — or that serves a dead hop — fails the byte-exact markers immediately.
- Residual: `mut_latch_zombie` pins the *served* zombie for `region_transform`/`region_delete`; link-disable-under-latch follows the same early-return path in engine code but is not separately armed (the latch check precedes all invalidation kinds — noted as an open edge, not a gap in the declared clauses).
- Sibling lanes (`r75-reviewer`, `r75-simplifier`, …) ran godot concurrently during the battery in their own scratch dirs; `--path` isolation kept receipts clean (`seeds_unchanged=True`).

No commit, push, or other runtime invocation performed. Stopping here.
