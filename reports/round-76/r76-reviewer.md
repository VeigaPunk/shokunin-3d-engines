# Game-dev-3d round 76 — reviewer (committed-state audit of the r75 battery on HEAD)

Reviewer did not author r75. Per the brief, this audit re-ran the r75 committed
battery (`156/156 + 4 probes + Node 31/31`) on HEAD while the r76 author diff
was in flight. Audit repo: the canonical `~/Projects/shokunin/game-dev-3d-shokunin`
(the brief's `~/Projects/prymeagnt/game-dev-3d` path is the stale prymeagnt
worktree shell — `.shokunin/game-dev-3d` there symlinks here; same resolution as
r75-reviewer). Scratch confined to gitignored `corpus/live/r76-reviewer/`; this
report is the only tracked-path write. No commits, no subagents, LEAF.

**Audited state:** HEAD `cb6bf7b637a3857c3dcc354d4e267797e284f253`
("r75 report-last: verifier AGREE 5/5 + adjudicator + map-mutation lesson +
LOG/SCORECARD; fw_mapedit citation fix"). Working tree was clean at audit start,
at battery end, and at report write — the r76 author diff had **not** landed in
the working tree during the audit window (fixture mtimes still `2026-10-14
02:37:18/02:37:22 -0300`; only untracked `reports/round-76/` sibling reports
exist). To make the audit immune to a mid-run landing I did **not** run on the
working tree: `git archive HEAD corpus/fixtures | tar -x -C
corpus/live/r76-reviewer/head` materialized the committed seed set, and the
battery ran from that snapshot. Extraction verified byte-identical to both the
live tree and the r76-baseline seat's frozen copy (`run_battery.py` sha256
`d8354022823111cb6ea7355eaa252bb4d9bdc2d327458ec66a2cf945becd4473`,
`navagent3d_detour.gd` sha256
`81a8c10a53c8554bfae270d2f1b7fe77649b119ae3328840022027c9c2b1a504`).

Host: devin; `/usr/bin/godot` = `4.7.2.stable.arch_linux.ed1daf0bf` (same pin as
r73/r74/r75), Python 3.14.7, Node v24.21.0, three.js 0.186.1.

## 1 — Full battery on committed HEAD: reproduced (156/156 + 4 probes)

```
python3 head/corpus/fixtures/run_battery.py --godot /usr/bin/godot \
  --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r76-reviewer/runs \
  --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
```

ABSOLUTE `--runs` per the documented trap. Exit 0, `PASS battery`. Receipt
`corpus/live/r76-reviewer/runs/20261014T095433249078Z/verdicts.json`:

- `verdict=PASS`, `totals = {cases: 156, pass: 156, fail: 0, ordinary: 111,
  negative_controls: 45}`, `probes=4` — exactly the r75 shape.
- `seeds_unchanged=true`, `seed_digests` = 52 keys, **byte-identical to a fresh
  digest of the extracted HEAD snapshot** (proved the battery ran the committed
  blobs end to end).
- `godot_version = 4.7.2.stable.arch_linux.ed1daf0bf`.
- Probes 4/4: crash-exit (`signaled`, exit −15, `marker_observed_while_live`),
  stream-attribution `PASS`, tree-timeout `PASS` (`timed_out=true`,
  `marker_observed=true`, `witness_verified=true`, `witness_gone=true`,
  `cleanup_exit=-9` — the absolute-path verified-witness path; no stray
  witnesses afterward), mutation `PASS` (`detected=true`,
  `seeds_unchanged=true`).

## 2 — Drift analysis vs prior receipts: none

- vs `corpus/live/r75-author/runs/20261014T051912324357Z/verdicts.json`
  (author's uncommitted-WT receipt): **0 mismatches over 156 cases × 12 fields**
  (`case, script, flags, expected_exit, actual_exit, kind, marker, verdict,
  reasons, stdout, stderr, error`), identical case order. `seed_digests`
  differs in exactly 2 keys — `navagent3d_detour.gd` (`81a8c10a…` committed vs
  `dbe6a2ae…` author-WT) and `run_battery.py` (`d8354022…` vs `f99c48f8…`) —
  fully accounted for by `git diff 6498973..HEAD` = `+9/−3`, **comment/docstring
  only** (the `cefc821` wording hygiene: leg-segment operand correction +
  absolute-`--runs` docstring, i.e. the landed r75 Finding-1 header fix and the
  Finding-5 docstring closure). Zero executable delta between the author's
  verified WT and the committed fixture.
- vs `corpus/live/r76-baseline/runs/20261014T095009263752Z/verdicts.json`
  (sibling committed-state battery ~4.5 min before mine): `verdict=PASS`,
  **identical `seed_digests`**, **0 row mismatches** over 156 × 12 fields — two
  independent byte-identical committed-state batteries.

## 3 — `mut_*` arms: all 11 present and verified, `mut_latch_zombie` included

All 11 `navagent3d_detour_mut_*` rows are committed CASES entries
(`run_battery.py:176-197`), all PASS in the battery, and all 11 were
**independently replayed** on the extracted-HEAD fixture — `godot --headless
--path replays/proj --script res://navagent3d_detour.gd -- --arm=<name>`, each
exit 0, empty stderr, stdout PASS line **byte-exact** against the committed
CASES literal (`corpus/live/r76-reviewer/replays/<arm>.stdout.txt`):

| arm | byte-exact | arm | byte-exact |
|---|---|---|---|
| `mut_link_kill` | yes | `mut_region_off` | yes |
| `mut_link_drop` | yes | `mut_region_renew` | yes |
| `mut_link_layers` | yes | `mut_link_revive` | yes |
| `mut_layers_agent` | yes | `mut_lazy` | yes |
| `mut_layers_region` | yes | **`mut_latch_zombie`** | **yes** |
| `mut_region_move` | yes | | |

`mut_latch_zombie` observed verbatim:
`PASS navagent3d_detour mut_latch_zombie steps=2 idxs=1,1
next=2.000000,0.000000,3.000000 final=2.000000,0.000000,3.000000 dist=1.500000
pathlen=0.000000 reachable=true reached=true finished=true` — the latched
agent keeps serving the pre-mutation waypoint through `region_transform +5x`
AND `region_delete` on a map that no longer contains the region; the r75
falsification arm reproduces exactly on committed HEAD.

## 4 — Node three.js suites: reproduced (31/31)

On the extracted-HEAD `three/` (`node_modules` is gitignored — symlinked from
the repo dir; all tracked `.mjs`/json files are HEAD blobs):
`run_cases` 3/3, `run_layer_cases` 4/4, `run_order_cases` 9/9,
`run_camera_cases` 5/5, `run_ortho_cases` 5/5, `run_ray_cases` 5/5 = **31/31
PASS**, every receipt `verdict=PASS`, `seedsUnchanged=true`, Node `v24.21.0`,
three `0.186.1` (`corpus/live/r76-reviewer/node/run_*.json`).

## 5 — Committed-state expressibility bounds relevant to the r76 axis (verified)

The declared r76 move arms same-turn `mutate`+forcing-read at `wait=0/1/2`,
`map_set_active(false)` reachability, and same-value-mutation suppression.
Measured on the committed blob (scratch-injected arms in
`corpus/live/r76-reviewer/replays/proj2/`, never tracked):

- **Terminal `mutate`+`wait:0` is still unauthorable on HEAD.** Injected
  `zw_terminal` (terminal `mutate:{link_enabled:false}, wait:0`, otherwise the
  `mut_link_kill` shape) exits 1 with `ERROR: navagent3d_detour: authored link
  flags not in effect` — the `_final_srv_state` readback gate
  (`navagent3d_detour.gd:332-359`) reads server getters that are still pre-sync
  same-turn. Reproduces r75-reviewer's `mut_zw_terminal` bound on the committed
  file; the committed header documents it (`:1124-1127`, "mutate steps
  therefore need wait>=1"). A r76 arm whose **last** mutation is at `wait=0`
  will hit this gate, not the engine.
- **Mid-step `mutate`+`wait:0` works and DOES pin the same-turn stale serve.**
  Injected `zw_mid` (mutate+`wait:0` step then a `wait:5` step) exits 0:
  `PASS … zw_mid steps=2 idxs=1,1 next=2.000000,0.000000,1.000000
  final=2.500000,0.000000,4.000000 dist=5.385165 pathlen=4.622520
  reachable=false reached=false finished=false` — step 1 served the
  pre-mutation tuple (`reachable=true`, stale path incl. the dead hop), step 2
  read the post-sync corridor clamp. The committed machinery already expresses
  the axis's wait=0/≥1 contrast for non-terminal mutation steps.
- **`map_set_active` has no plumbing.** `_apply_mutation` keys
  (`navagent3d_detour.gd:1584-1611`) are region*/link*/agent only — no map key;
  `_final_srv_state` has no map flag, and the setup gate (`:324`) asserts
  `map_is_active(map)` unconditionally. A `map_set_active(false)` arm requires
  new machinery (diff scope, not a committed-state defect).
- **`peek_only` terminal-step `KeyError` still latent** at HEAD:
  `_run_motion_arm` prints `stf["next"]`/`["final"]`/`["dist"]`…
  unconditionally (`:1761-1765`) and a `peek_only` last state carries only
  `pos`/`path`/`idx`/`peek_*` (simplifier-flagged malformed-config class).
- **Same-value-mutation suppression**: foldable today — `fs` lands the same
  value and the readback gate passes provided the getter is post-sync; only the
  stale-getter terminal case above is blocked.

## Findings by severity

1. **None — no drift.** The r75 committed battery is byte-exact reproducible on
   HEAD `cb6bf7b`: 156/156 cases, 4/4 probes, `seeds_unchanged`, all 11 `mut_*`
   arms PASS in-battery and byte-exact in independent replay, Node 31/31.
2. **Info — committed-state expressibility bounds** (§5): terminal
   `mutate`+`wait:0` rejected by the readback gate (verified, exit 1);
   `map_set_active` key absent; terminal `peek_only` KeyError. All documented
   or sibling-flagged; all verified present on the committed blob. They bound
   how the r76 same-turn arms must be authored — mid-step `wait:0` works.
3. **Info — concurrent sibling activity observed, not touching my audit:** a
   `game-dev-2d` lane battery ran concurrently under its own repo/`--path`
   isolation (different shokunin tree); my receipt's `seeds_unchanged=true`
   plus the HEAD-snapshot run make interference structurally impossible.

## Residual risk / verification gaps

- My battery ran on a `git archive HEAD` extraction rather than the working
  tree — a stricter reading of "committed state", and the two were proven
  byte-identical for `corpus/fixtures` at audit time anyway (`diff -r` vs the
  baseline frozen copy, sha256 spot-checks, equal `seed_digests` to baseline's
  own working-tree run).
- The r76 author diff had not landed in the working tree during the audit
  window; coverage of the *landed* r76 diff belongs to seats dispatched after
  it lands (verifier/adjudicator).
- `zw_terminal`/`zw_mid` exist only in my scratch `replays/proj2/` — injected
  probes, confirmed absent from the committed CASES (committed
  `run_battery.py` has exactly 11 `mut_*` rows, none named `zw_*`).
- Compared receipts are gitignored on-disk artifacts (carried-forward caveat).
- No `lsp` device is bound on this dispatch; checks were execution-based
  (running the committed fixture + digest/row diffs), which subsumes the
  text-grep fallback.
- This report is a recommendation; admission belongs to the canonical judge.
