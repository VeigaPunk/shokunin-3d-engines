# game-dev-3d round 74 — verifier (seat: verifier, NON-AUTHOR, host: devin)

Verified the COMMITTED tree at HEAD `fc9915ed8e546909c33fcedf1450a634c712890c`
(`git rev-parse HEAD` = fc9915e; canonical repo
`~/Projects/shokunin/game-dev-3d-shokunin`, reached via the lane worktree's
`.shokunin/game-dev-3d` symlink — `Path(__file__).resolve()` inside
run_battery.py lands on the committed fixtures). My only writes are this
report and scratch under `corpus/live/r74-verifier/` (gitignored), plus the
battery receipt dir `corpus/live/runs/20261014T044234729734Z/`. No commits,
no tracked edits.

Working-tree note at verify time: `LOG.md`/`SCORECARD.md` modified and
`r74-adjudicator.md`, `corpus/lessons/r74-*.md` untracked — sibling-seat
landings, none touching fixtures; no effect on any claim below.

Committed-byte identity: `sha256 corpus/fixtures/navagent3d_detour.gd` =
`336898f4b711021a21e619385244e662168889ba5c52ec6812af9c5034601276` and
`run_battery.py` = `697b3d5fa0dcab147ee79016354e07dee52e6820777508cca237b27385f70f86`
— byte-identical to the author's claimed post-change hashes. `git diff
HEAD~1..HEAD --numstat`: `+501/−5` detour, `+36/−0` battery — matches.

Environment: `godot --version` = `4.7.2.stable.arch_linux.ed1daf0bf` (same
build the author measured on), `node v24.21.0`, `python3`.

## Claim 5 first — full battery + probes + Node — AGREE

Command (run from the lane worktree per dispatch; `--runs` ABSOLUTE, probe
flags added because they are opt-in and the claim expects 4/4):

    cd ~/Projects/prymeagnt/game-dev-3d && python3 \
      .shokunin/game-dev-3d/corpus/fixtures/run_battery.py \
      --godot /usr/bin/godot \
      --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/runs \
      --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing

- exit `0`; receipt `corpus/live/runs/20261014T044234729734Z/verdicts.json`;
  capture `corpus/live/r74-verifier/battery-r74-verifier.out`.
- `totals: cases=145 pass=145 fail=0 ordinary=100 negative_controls=45
  probes=4`, `verdict=PASS`, `seeds_unchanged=true`.
- `crash_probe_ok=true`, `stream_probe_ok=true`, `tree_probe_ok=true`
  (`witness_verified=true`, `witness_gone=true`, cleanup `SIGTERM to verified
  detached witness` — the absolute `--runs` satisfied the witness check),
  mutation `probe.verdict=PASS detected=true` (`mutant_body3d_contact` exit 1
  with the authored diagnostic).
- All 18 `navagent3d_detour_mv_*` rows PASS; programmatic check: every row's
  exact `marker` is a stdout line (0 misses across all 145).

Node suites (runners DO exist in fixtures — `corpus/fixtures/three/run_*.mjs`,
six standalone suites; run each with `--receipt`):

| suite | result | exit | seeds_unchanged |
|---|---|---|---|
| run_cases | 3/3 PASS | 0 | true |
| run_layer_cases | 4/4 PASS | 0 | true |
| run_order_cases | 9/9 PASS | 0 | true |
| run_camera_cases | 5/5 PASS | 0 | true |
| run_ortho_cases | 5/5 PASS | 0 | true |
| run_ray_cases | 5/5 PASS | 0 | true |

31/31 total; receipts `corpus/live/r74-verifier/node-run_*.json`.

## Claim 6 — spot-check ≥4 arms byte-exact — AGREE (6/6)

    cd ~/Projects/prymeagnt/game-dev-3d && godot --headless \
      --path .shokunin/game-dev-3d/corpus/fixtures \
      --script res://navagent3d_detour.gd -- --arm=<name>

Each ran exit 0, empty stderr, and the `PASS …` line compared byte-exact
(`[ "$exp" = "$act" ]`) against the committed CASES marker string:

| arm | result |
|---|---|
| mv_walk | BYTE-EXACT |
| mv_pmd_edge | BYTE-EXACT |
| mv_popskip | BYTE-EXACT |
| mv_unlatch | BYTE-EXACT |
| mv_reanchor_same | BYTE-EXACT |
| mv_live | BYTE-EXACT |

Raw captures: `corpus/live/r74-verifier/spot-<arm>.{stdout,stderr}.txt`.

## Claims 1–4 — semantics, independently re-derived — AGREE each

Method: read `_run_steps`/`_run_motion_arm`/`_read_state` (detour.gd
L1058–1308) and all 18 arm configs (L723–1056), then recomputed every
boundary/distance constant from the authored geometry (`s=(0.5,0,0.5)`,
`td=f=(2.5,0,3.5)`, `tg=(0.5,0,3.0)`, `fg=(2,0,3)`, `path[1]=(2,0,1)`,
pdd=tdd=1.0, pmd default 5.0) rather than trusting seat prose.

Falsification edge is real, not ambient: `_run_motion_arm` asserts the
pre-motion tuple and each step's full tuple INCLUDING the complete stored
`path` array elementwise (POS_TOL 0.001); `_run_steps` applies `set_target`
before `tp`, waits `wait` physics frames (default 5; `wait:0` reads
call-time), and `_read_state` leads with `get_next_path_position()` — the
forcing getter — so each recorded tuple is post-update.

### Claim 1 — path frozen within path_max_distance; re-query at breach — AGREE

- Frozen arms all pin the stored array unchanged at every step and PASS:
  mv_walk (3 teleports, path stays `[s,(2,0,1),f]`), mv_void (agent at
  (2.5,0,4.5) off-mesh, dist-to-path[1] recomputed 3.5355 < 5), mv_pmd_edge
  step1, mv_bridge_walk (frozen mid-link-hop).
- Boundary recomputed: euclid((2.5,0,5.97), path[1]) = **4.9951 < 5** →
  frozen, idx stays 1; euclid((2.5,0,6.0), path[1]) = **5.0249 > 5** →
  re-query, idx resets 0, new path `[(2.5,0,4.0), f]` — path[0] is the
  navmesh clamp of the live position (pathlen 0.5 = |(2.5,0,4)→f| ✓).
- mv_pmd_offmesh: teleport (10,0,10) → re-anchored `[(3,0,4), f]`; return
  teleport does NOT restore the old path (no undo) — both steps PASS.
- mv_pmd2 (authored pmd=2.0): dist-to-path[1] recomputed 4.5277 > 2 →
  re-query, matching the gate tracking the written pmd.
- mv_latch sharpener confirmed: agent at (10,0,10), 10.63 > pmd from
  path[1], yet path `[fg,fg]`/idx untouched — the finished latch
  early-returns even the pmd re-query.

### Claim 2 — pop index follows live position, strict-< monotone, sequential — AGREE

- Pop rule confirmed as `while euclid(live_pos, path[idx]) < pdd: idx++`
  against the STORED path — consistent with every pinned idx including
  mv_reanchor_same's idx=2 (path[0] at live pos dist 0 pops, path[1]
  0.707 < 1 pops, path[2] 3.162 holds).
- mv_walk idxs 1,2,2; mv_popback idxs 2,2 (return to spawn never un-pops);
  mv_popstrict: (2,0,0)→path[1] euclid = 1.0 == pdd holds idx 1;
  (2,0,0.01)→0.99 < pdd pops to 2. All recomputed and byte/marker PASS.
- mv_live step1 `wait:0` already shows idx 2 — call-time pop, no physics
  frame needed.
- mv_popskip (byte-exact spot): teleport to (2.4,0,2.8), euclid-to-final
  0.7071 < tdd → reached/finished fire, yet idx stays 1 and next returns
  the unconsumed (2,0,1) BEHIND the agent — sequential, cannot skip;
  flags decoupled from idx.
- Note on wording: idx 1→0 in mv_pmd_edge/mv_unlatch is a re-query reset
  (new path), not a pop violation — the claim's cited arms
  (mv_live/mv_popback/mv_popstrict/mv_popskip) are all frozen-path and
  strictly monotone.

### Claim 3 — distance_to_target = call-time Euclidean to target_position — AGREE

Recomputed every `dist` field against `euclid(live_pos, target)`; all match
the committed constants to 6 decimals, including the discriminating cases
where path length differs sharply:

| arm.step | recomputed | pinned |
|---|---|---|
| mv_pmd_offmesh s1 (10,0,10)→f | 9.924717 | 9.924717 (pathlen 0.707!) |
| mv_latch s2 (10,0,10)→tg | 11.800424 | 11.800424 |
| mv_walk s1/s2/s3 | 3.354102 / 2.692582 / 0.5 | identical |
| mv_popstrict s1/s2 | 3.535534 / 3.525635 | identical |
| mv_reanchor_lazy s2 | 1.923539 | identical |
| mv_reanchor_force s2 | 3.676955 | identical |
| mv_bridge_walk s1 | 4.627094 | identical |
| mv_popskip | 0.707107 | identical |
| mv_pmd_edge s1/s2, mv_pmd2, mv_reanchor s2, mv_pmd_offmesh s2 | 2.47 / 2.5 / 2.0 / 1.0 / 3.354102 | identical |

`dist` tracks the raw target and the LIVE position even when the stored
path is stale (offmesh s1: dist 9.92 to f while stored path is a 0.707-long
remnant anchored at (3,0,4)) — call-time Euclidean confirmed.

### Claim 4 — latches hold through motion; ANY target_position re-assignment releases — AGREE

- mv_latch: reached/finished fire at spawn (tdd=1.6, dist 1.5) and stay
  true through teleports to s and (10,0,10); path/idx untouched — latch
  early-return confirmed.
- mv_unlatch: same-value `set_target(tg)` at (10,0,10) → reached/finished
  false, idx 0, path re-anchored at clamp `[(3,0,4), fg]` (pathlen
  recomputed 1.414214 ✓) — no same-value dedup.
- mv_reanchor: new target mid-path → new path `[(1.5,0,0.5),(0.5,0,0.5)]`
  — anchored at LIVE position, not the original origin.
- mv_reanchor_same (byte-exact spot): same-value re-assignment still moves
  path[0] S→(1.5,0,0.5).
- mv_reanchor_bank/void: same re-assignment at (2.5,0,3.9) with the server
  link live → `[(2.5,0,3.9),(2.5,0,3.5),(2.5,0,5.5)]` routes through the
  link; without it → `[(2.5,0,3.9),(2.5,0,4.0)]` unreachable →
  finished=true via the idx+pdd clause. Bank-side measured both ways.
- mv_reanchor_lazy/force pair pins the LAZY materialization: set_target+tp
  in one step anchors at post-teleport (2.6,0,2.0); an intervening read
  anchors at read-time (1.5,0,0.5) and that path then stays frozen.

## Prior-rows invariant (author claim, independently checked)

127 HEAD~1 CASES rows → all byte-present in HEAD CASES, order preserved;
added names = exactly the 18 `navagent3d_detour_mv_*`; removed = none;
zero prior marker strings changed (programmatic parse of both revisions).

## Summary

| claim | verdict |
|---|---|
| 1. Path frozen within pmd; re-query at breach (mv_walk/mv_pmd_edge/mv_pmd_offmesh) | AGREE |
| 2. Pop idx monotone strict-< on live position, sequential no-skip | AGREE |
| 3. distance_to_target = call-time Euclidean to target_position | AGREE (14 dist fields recomputed) |
| 4. Latch holds through motion; ANY re-assignment releases + resets idx | AGREE |
| 5. Battery 145/145 + 4/4 probes; Node 31/31 | AGREE (probe flags are opt-in — claim's shorthand omits them; ran all four) |
| 6. ≥4 arms byte-exact vs CASES marker | AGREE (6/6) |

No disagreement found. Residual risk (inherited, unchanged): single-build
measurement on `4.7.2.stable.arch_linux.ed1daf0bf`; motion is authored
teleports + target re-assignment only (no velocity locomotion — declared
scope); only mv_live step1 pins the literal 0-frame read, other steps are
settled post-update tuples. Blockers: none.
