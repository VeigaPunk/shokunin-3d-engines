# r76 verifier — sync-window CASES {link:2, region:3, map_off:∞, agent:0} + same-value suppression pins

Seat: `ufo-verifier` (non-author, leaf — no subagent dispatch, no git mutation).
Committed state: HEAD `3ab09fdb804b0600a6f6a14b28c42f0bb4e49e0f` ("r76: sync-window CASES …").
Build: Godot `4.7.2.stable.arch_linux.ed1daf0bf` (`/usr/bin/godot`), Node `v24.21.0`.
Working tree at verification: clean vs HEAD (only `?? reports/round-76/r76-simplifier.md` — a sibling lane artifact appearing mid-run; `corpus/live/` is ignored).
Seed identity cross-check: battery seed digest `navagent3d_detour.gd = 066a06d2…a19e4` — byte-identical to the sha256 the author reported for the changed fixture; `run_battery.py = 6faa8356…cba1` likewise. The verified tree is the committed tree.

## Verdict: **AGREE — 5/5 claims**, two scoping caveats noted (non-blocking).

### Claim 1 — seven new `mut_*` arms + `map_active` mutate key; CASES 156→163, prior rows untouched — **AGREE**

- `git show HEAD -- corpus/fixtures/run_battery.py`: pure addition — the diff contains only `+` lines (14: seven 2-line CASES rows for `mut_win_link`, `mut_win_region`, `mut_map_off`, `mut_map_cycle`, `mut_same_link`, `mut_same_region`, `mut_same_agent`), inserted after `navagent3d_detour_mut_latch_zombie` and before `remote3d_transform`. Zero `-` lines → no prior row edited, reordered, or removed.
- `ast` count: CASES 156 → 163 (old file re-counted at 156).
- `navagent3d_detour.gd` diff: +290/−6. Additions: the seven `_arm_cfg` arms (lines ~1421–1647), header truth block (164–192), `"map_active"` in `_apply_mutation` (1885–1886, applied last per its comment), `fs["map_active"]` seed + fold in `_final_srv_state` (1908, 1938–1939), and the setup-gate generalization `map_is_active(map) != fs["map_active"]` (352–354). The six removed lines are exactly the author's declared set (stale `wait>=1` comment lines + hardcoded `map_is_active` + fs seed line).

### Claim 2 — strict per-class sync-window constants — **AGREE** (with caveat C1)

Spot-checks run against a verifier-owned scratch copy (`corpus/live/r76-verifier/scratch`), each matching its pinned CASES marker byte-exact:

| arm | observed marker | window evidence |
|---|---|---|
| `mut_win_link` | `steps=4 idxs=2,3,3,1 next=2.500000,0.000000,4.000000 … finished=true` | stale serve at +0 pops 2→3 **across the killed gate** (`next=(2.5,0,5.5)`, the dead far endpoint); +1 still stale (idx=3); +2 re-queries anchored at live bank `[(2.5,0,3.4),(2.5,0,4.0)]`, `reachable=false`, `finished=true` → **edge = 2f** |
| `mut_win_region` | `steps=4 idxs=1,1,1,0 next=5.000000,0.000000,0.500000 … finished=false` | stale at +0/+1/+2 verbatim; +3 re-queries `[(5,0,0.5),(5,0,1.0)]` with `reachable=false`; the +3 step's `peek` still shows the pre-move stored array → **edge = 3f**, two-stage (map synced, agent re-queries only inside the forcing call) |
| `mut_map_off` | `steps=3 idxs=1,1,1 … reachable=true finished=false` | committed tuple served unchanged at +0, +10, +15 cumulative frames; `finished` never latches → **permanent-stale (no edge)**, mechanism distinct from `mut_latch_zombie` (there the agent update early-returns while the server still syncs; here the map leaves the sync iteration) |
| `mut_map_cycle` | `steps=4 idxs=1,1,1,1 … reachable=false` | kill queued under inactive map stays invisible through +5 idle frames; after `map_set_active(true)`, +1 stale and +2 clamps → reactivation re-arms the normal 2-frame window |
| `mut_same_agent` (agent channel) | `peek_path=[]` at `wait:0` on the effective write (1→2) | `agent.navigation_layers` clears the stored array **synchronously at 0** — confirmed inside the arm's step-3 pin |

Per-step assertion coverage is not just the marker: `_run_motion_arm` compares every step's `idx/next/final/dist/reachable/reached/finished` plus the full `path` array and the non-forcing `peek_idx`/`peek_path` pins (navagent3d_detour.gd ~1971–2030). All seven PASS.

**Caveat C1 (scoping, non-blocking):** the "link-family"/"region-family" phrasing is wider than the armed evidence — frame-resolution edges are pinned only for `link_set_enabled` (2f) and `region_set_transform` (3f); `link_layers`, `region_layers`, `region_delete`, `region_enabled` follow the same lazy path but their exact per-channel edges are not separately armed (the author's own residual names this). "map_off:∞" is a *pin to +15 cumulative frames*, not a proof of unboundedness — by design, since it is the first casualty of an engine change.

### Claim 3 — same-value suppression on link/region/agent-layers; `target_position` NOT suppressed — **AGREE**

- `mut_same_link`: `link_set_enabled(true)` on an already-enabled link leaves the M-witness tuple anchored at spawn S through +5f (`peek_idx=2`, `path[0]=S`); the same arm's effective write (→false) re-anchors `path[0]` at M — suppression vs. re-query contrast inside one arm. PASS byte-exact.
- `mut_same_region`: `region_layers=1` + `region_transform=identity` in one step both suppress (Transform3D value compare); contrast `layers 1→2` empties the path. PASS byte-exact.
- `mut_same_agent`: same-value `navigation_layers=1` dedups *before* the synchronous clear (`peek` npath=3 at wait:0). PASS byte-exact.
- `target_position` carve-out: r74 arm `mv_reanchor_same` is unchanged in the diff and re-ran green both in the battery and in my focused run — `idxs=2,2 … path=[(1.5,0,0.5),(2,0,1),f]`: a same-value `set_target` still forces the re-query anchored at the live position. The asymmetry (node property `target_position` never dedups; server/agent setters do) is correctly preserved.

### Claim 4 — battery 163/163 + 4/4 probes + Node 31/31; wait≥1 for sync-blind readback — **AGREE** (with caveat C2)

- Battery (absolute `--runs`, all four probes): `corpus/live/r76-verifier/runs/20261014T102343921913Z/verdicts.json` → `verdict=PASS`, `totals: cases=163 pass=163 fail=0 ordinary=118 negative_controls=45`, `seeds_unchanged=true`, `tree_probe_ok=true`, `crash_probe_ok=true`, `stream_probe_ok=true`; final stdout `PASS battery: …/verdicts.json`, runner exit 0.
- Probe receipts under the same run dir: `crash-exit-verdicts.json`, `stream-attribution-verdicts.json`, `tree-timeout-verdicts.json`, `mutation-verdicts.json` — all `verdict=PASS` (the mutant `BOX_SIZE 4→6` was detected: case-level `FAIL` with `exit 1 != expected 0` + the expected contact-plane diagnostic — the probe working, `detected=true`).
- Node suites (`corpus/live/r76-verifier/node/`): run_cases 3/3, run_layer_cases 4/4, run_order_cases 9/9, run_camera_cases 5/5, run_ortho_cases 5/5, run_ray_cases 5/5 = **31/31**, all six receipts `verdict=PASS`, `seedsUnchanged=true`, runner exits all 0.
- wait≥1 invariant: parsed all 18 `steps`-bearing mutation arms in the committed fixture — every arm has ≥1 cumulative physics frame between the LAST `mutate` and arm end (min observed 2f: `mut_win_link`, `mut_map_cycle`; `mut_same_agent`'s `wait:0` mutate is followed by a 5f step). The `fs` mutation-honesty readback gate (setup block 377–389 + `map_is_active` at 354) therefore never samples a pre-setter object value.

**Caveat C2 (scoping, non-blocking):** "enforce" is the authored invariant + the readback gate's fail-on-noop property, not a mechanical linter — `_run_steps` happily accepts a `wait:0` last mutate (it would then fail the fs gate ~1f-sync channels, but nothing statically forbids authoring it). True today for all 18 arms.

### Claim 5 — prior 156 rows re-run, 0 mismatches — **AGREE**

All 163 case records in `verdicts.json` are `verdict=PASS` with byte-exact pinned markers; the prior-156 diff surface is pure addition (claim 1), so every prior row re-ran under its unchanged marker — 0 mismatches.

## Residual risk / verification gaps

- Per-channel window edges for non-armed mutations (`link_layers`, `region_layers`, `region_enabled`, `region_delete`) remain unpinned at frame resolution — inherited r75/r76 residual, not introduced by this commit.
- The `map_off` "never" is bounded by the +15f pin; an eager-invalidation engine change would falsify it exactly as designed.
- Window constants are build/host-pinned (Godot 4.7.2, ~60 physics ticks/s) — the same qualification every prior round carries; the CASES themselves are the tripwire.

No commit, push, or other tree mutation performed. Stopping here.
