# game-dev-3d round 73 — verifier (seat: verifier, NON-AUTHOR, host: devin)

Verified the COMMITTED tree at HEAD `b41fb33bcfd6ed8b4014521e602de2ce1942738e`
(`git rev-parse HEAD` = b41fb33; canonical repo
`~/Projects/shokunin/game-dev-3d-shokunin`, reached via the worktree's
`.shokunin/game-dev-3d` symlink). Every command below ran against the committed
fixtures; my only writes are this report and scratch under
`corpus/live/r73-verifier/` (gitignored). No commits, no tracked edits.

Working-tree note at verify time: `reports/round-73/r73-scribe.md` sits
untracked (`??`) — a post-commit seat landing. It touches no fixture and does
not affect any claim below.

## Claim 1 — full battery on committed tree: 127/127 + 4 probes + seeds_unchanged — AGREE

    python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
      --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r73-verifier/runs \
      --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing

- exit `0`; receipt `corpus/live/r73-verifier/runs/20261014T020933241302Z/verdicts.json`
- `totals: cases=127 pass=127 fail=0 ordinary=82 negative_controls=45 probes=4`, `verdict=PASS`
- `crash_probe_ok=true`, `stream_probe_ok=true`, `tree_probe_ok=true`, mutation `probe.verdict=PASS` (`mutant_body3d_contact` exit 1, expected)
- `seeds_unchanged=true`, `seed_digests` 52 keys; `godot_version=4.7.2.stable.arch_linux.ed1daf0bf` exit 0
- `--runs` passed ABSOLUTE; the tree-timeout probe passed (`tree_probe_ok=true`), so the relative-path runner trap was not triggered.

## Claim 2 — prior stability: 112 rows, 0-mismatch vs r72-verifier receipt — AGREE

Baseline: `corpus/live/r72-verifier/runs/20261014T011457986739Z/verdicts.json`
(the r72 verifier's own full-battery receipt, 112 results, verdict PASS).

Compared all 112 shared case names across 12 raw fields —
`case, script, flags, expected_exit, actual_exit, kind, marker, verdict,
reasons, stdout, stderr, error`:

- **0 mismatches over 112 rows × 12 fields** (the author claimed 11 fields; I
  additionally compared `error` — still 0).
- `command` and `elapsed_seconds` differ on every row BY CONSTRUCTION (per-run
  scratch path and wall clock); after normalizing the scratch path, `command`
  mismatches = 0.
- Added rows = exactly the 15 `navagent3d_detour_link_*` names, inserted at
  positions 35–49 (after `fin_latch`, matching the CASES diff hunk). Removed
  rows: none.
- Seed map 52→52, no added/removed keys; the ONLY digest changes are
  `navagent3d_detour.gd` `ea722a75…1f4da0` → `0ae04750…4835ce4` and
  `run_battery.py` `4e9ead37…eefdfa` → `9f18a711…872860` — byte-identical to
  the author's claimed before→after SHAs, and to the committed files on disk
  (`sha256sum` re-verified).

## Claim 3 — four declared claims, verbatim CASES-arm replay — AGREE

Focused verbatim replay, exit 0, 15/15 PASS —
receipt `corpus/live/r73-verifier/runs/20261014T021240692530Z/verdicts.json`:

    python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
      --runs <ABS>/corpus/live/r73-verifier/runs --only <all 15 link_* cases>

Measured stdout markers (each arm also passes the fixture's internal checks:
path vector, idx/next/final/dist/reachable/reached/finished, flag read-backs,
and the keyed companion arrays — a mismatch would exit 1, not print PASS):

**(a) companion arrays LINK-typed under metadata flags / empty at meta=0 — confirmed.**
- `link_shortcut` (server, meta=0): link path taken (`idx=1 next=1.5,0,0.5
  pathlen=4.192582`) yet `types=- ridat=-1 own=-` — all three arrays EMPTY.
- `link_meta_types` (meta=1): `types=0,1,0,0` — LINK (1) at index 1 = hop start.
- `link_meta_rids` (meta=2): `ridat=1`, `types=-` — rids populated, link RID at 1.
- `link_meta_owners` (meta=4, node): `own=NavigationLink3D@1` — live instance.
- `link_meta` (meta=7, node): `types=0,1,0,0 ridat=1 own=NavigationLink3D@1`.
- Path tuple identical across all five — metadata changes no path output.

**(b) three gates each independently drop the link — confirmed.**
- `link_layers_off` (link ll=2, agent al=1): corridor `next=2,0,1
  pathlen=4.130649 types=0,0,0`; `link_layers_on` (al=3): link restored
  `pathlen=4.192582 types=0,1,0,0` — bitmask intersection, same geometry.
- `link_oneway_fwd`: traversed `final=2.5,0,5.5 pathlen=6.130649
  types=0,0,1,0 reachable=true`; `link_oneway_rev`: dropped, clamp
  `final=2.5,0,4.0 pathlen=4.622520 reachable=false`.
- `link_disabled`: dropped, identical clamp `final=2.5,0,4.0
  pathlen=4.622520 reachable=false` — and the fixture read-back gate
  (`link_get_enabled`/`link_is_bidirectional`/`link_get_navigation_layers`/
  costs/meta/agent-layers, detour.gd L225–236) fails the arm on a no-op
  setter, so "dropped" cannot alias "never applied".

**(c) enter_cost inert while travel_cost live — confirmed, with a pinning note.**
- `link_travelcost` (travel_cost=10): corridor chosen `pathlen=4.130649
  types=0,0,0` — cost channel live.
- `link_entercost` (enter_cost=100): link chosen, path tuple byte-identical
  to the zero-cost `link_shortcut`/`link_meta_types` rows
  (`pathlen=4.192582 types=0,1,0,0`) — inert.
- Note on the dispatch wording "at 10 and 1e6": the TRACKED arms pin
  `travelcost=10` and `entercost=100` (see `_arm_cfg` L604–619). e=10 was an
  author scratch run (`sc_enter10`) and e≤1e6 was the critic's sweep — the
  inertness claim is what the committed battery pins, at e=100. Substance
  agrees.

**(d) pop-through across the void — confirmed, with a pinning note.**
- `link_gap` (island, no link): `final=2.5,0,4.0 reachable=false` — the void
  premise holds.
- `link_pop_bank` (pdd=2.0): `idx=2 next=2.5,0,3.5` — near endpoint.
- `link_pop_void` (pdd=4.0): `idx=3 next=2.5,0,5.5` — the FAR endpoint across
  the void, `reachable=true finished=false`.
- Note on "pdd 3.605551→idx=3": 3.605551 is the measured euclid S→linkstart
  (`dist` field, the strict-< flip threshold the critic bracketed at
  3.60/3.61); the pinned arm uses pdd=4.0 > threshold → idx=3. Substance
  agrees.

## Claim 4 — six Node suites 31/31 unchanged — AGREE

From `corpus/fixtures/three/` (existing install, Node `v24.21.0`):

    node run_<suite>.mjs --receipt <ABS>/corpus/live/r73-verifier/runs/node/run_<suite>.json

| suite | result | exit | seeds_unchanged |
|---|---|---|---|
| run_cases | 3/3 PASS | 0 | true |
| run_layer_cases | 4/4 PASS | 0 | true |
| run_order_cases | 9/9 PASS | 0 | true |
| run_camera_cases | 5/5 PASS | 0 | true |
| run_ortho_cases | 5/5 PASS | 0 | true |
| run_ray_cases | 5/5 PASS | 0 | true |

31/31 total; all six receipts under `corpus/live/r73-verifier/runs/node/`.

## Claim 5 — mutation scope + prior markers byte-identical — AGREE

`git diff 3f6a03d..b41fb33 --numstat`:

```
337	2	corpus/fixtures/navagent3d_detour.gd
30	0	corpus/fixtures/run_battery.py
245	0	reports/round-73/r73-author.md        (+ 6 more report files, all additive)
```

- Fixture deletions are EXACTLY the two claimed mechanical folds, verified in
  the raw diff: `mesh.vertices = PackedVector3Array([…])` → local `verts`
  (required for the island append, L115–124) and the polygon-count literal
  `(1 if straight else 3)` → `want_polys` (L215–221). Neither touches an
  existing arm's logic.
- `run_battery.py` diff has ZERO deletion lines — the 15 CASES rows are
  purely additive; every prior arm's expected marker is byte-identical by
  construction (and empirically: claim 2's 0-mismatch over `marker`/`stdout`).
- Committed file SHAs match the author's post-state claims
  (`0ae04750…4835ce4`, `9f18a711…872860`).

## Summary

| claim | verdict |
|---|---|
| 1. Full battery 127/127 + 4 probes + seeds_unchanged | AGREE |
| 2. 112 prior rows 0-mismatch vs r72-verifier receipt | AGREE |
| 3. Four declared claims via verbatim CASES replay | AGREE (pinning notes: enter_cost tracked at e=100 not 10/1e6; pop arm at pdd=4.0 vs the 3.605551 threshold) |
| 4. Node suites 31/31 | AGREE |
| 5. Mutation scope + marker identity | AGREE |

No disagreement found. Residual risk: all measurements are single-build
(`4.7.2.stable.arch_linux.ed1daf0bf` headless), single-host, stationary-agent;
the two pinning notes above are wording-vs-arm-precision, not defects — the
committed arms pin the true measured behavior. Verification gap: I replayed
CASES arms verbatim as dispatched; I did not re-derive the critic's 1e6
enter_cost sweep or the 3.60/3.61 strict-< bracket from scratch probes —
those stand on the critic's recorded receipts, not the committed battery.
