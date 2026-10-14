# r77 verifier — apply-order doomed-RID divergence, map_force_update reach, wait-ladder verdict-groups

Seat: `ufo-verifier` (non-author, leaf — no subagent dispatch, no git mutation).
Committed state under test: HEAD `35dfbe2fa9c841048da3351f62fcfa97c8fa28a7`
("r77: mutation apply-order CASES — doomed-RID divergence load-bearing…").
Build: Godot `4.7.2.stable.arch_linux.ed1daf0bf` (`/usr/bin/godot`), Node `v24.21.0`, three `0.186.1`.
Working tree at verification: clean vs HEAD (`git status --porcelain` empty after all runs).
Seed identity: committed `navagent3d_detour.gd` sha256 `fa4eb04a…e77` and `run_battery.py`
`92c5ad87…661` byte-equal the author's declared working-tree digests, and all 52 seed
digests embedded in the author's battery receipt equal the committed seed bytes —
the verified tree is the committed tree.

## Verdict: **AGREE — 6/6 claims**

### Claim 1 — apply-order load-bearing via doomed-RID voiding; surviving pairs inert — **AGREE**

- Mechanism verified **independently** of the fixture's `_apply_mutation`/`_run_steps`
  machinery: verifier-owned probe `corpus/live/r77-verifier/scratch/proj/r77v_probe.gd`
  (own map/mesh/region mirroring the authored detour geometry, 60tps):
  - `--mode=xform_first` (transform +5x queued on rid1, then free+recreate):
    `xform=0.000000,0.000000,0.000000` on the fresh RID — the write is voided;
    served `final=2.500000,0.000000,3.500000` (unmoved corridor).
  - `--mode=renew_first` (free+recreate, then transform on the new RID):
    `xform=5.000000,0.000000,0.000000`; served `final=5.000000,0.000000,1.000000`
    (moved corridor). Same setter multiset, different order, different served state.
- The committed arms pin exactly this pair through the battery's own gates:
  `mut_ord_renew_xform` serves `final=(5,0,1) pathlen=0.500000` with srv_get
  `region_transform=(5,0,0)`; `mut_ord_xform_renew` serves `final=(2.5,0,3.5)
  pathlen=4.130649` with srv_get `region_transform=(0,0,0)` — both PASS byte-exact.
- Surviving-object pairs convergent: `mut_ord_link_offmv` vs `mut_ord_link_mvoff`
  identical markers (`final=(2.5,0,4.0) pathlen=4.622520`) and identical srv_get
  internals (`en=false`, endpoints `(2.5,0,3.9)/(2.5,0,5.9)` — writes on a disabled
  link still land); `mut_ord_kill_mapoff` vs `mut_ord_mapoff_kill` identical 3-step
  markers including the reactivation edge. All PASS.
- Machinery confirmed by inspection: `mutate` array → `_mut_list` (navagent3d_detour.gd
  :2211) feeds each sub-dict through `_apply_mutation`'s unchanged fixed order
  (:2215–2260: delete → recreate → region xform/enabled/layers → link
  enabled/layers/start/end → agent → map_force → map_active); bare dict keeps the
  fixed order. `_run_steps` loops the list (:2175–2177).

### Claim 2 — map_force_update collapses only the getter edge; serve boundary jittered {1,2} — **AGREE**

Verifier probe, 10 reps, `--mode=force_ladder` (link kill + `map_force_update` same turn):

- w0: `en=false, iter=2` (getter applied same-turn) + `final=5.5` (serve stale) — 10/10.
- w1: fresh (`final=4.0`) in **6/10**, stale (`final=5.5`) in **4/10** → the serve
  boundary under force is jittered on {1,2}, reproduced independently.
- w3: fresh 10/10.
- Control `--mode=ctl_ladder` (no force), 5 reps: w0 getter stale (`en=true, iter=1`),
  w1 getter applied + serve stale, w2 fresh — deterministic unforced edge w2, 5/5.
- The tracked arm (`mut_force_link`, cfg :1849–1872) pins only w0 (srv_get applied +
  stale serve) and w3 (fresh clamp), skipping the jittered w1 sample; `mut_force_ctl`
  pins the full unforced ladder. Both PASS in battery and `--only` spot runs.

### Claim 3 — wait-ladder verdict-groups via `_tuple_sig` partition — **AGREE**

- `_tuple_sig` (:2031) is canonical over idx/next/final/dist/flags/path-elements;
  the ladder block (:2424–2447) partitions **observed** per-step states into
  consecutive identical-signature groups, bound = first differing index, and the
  PASS marker carries the derived `bound/groups/sizes` (byte-pinned in CASES).
- Independent re-derivation (Python simulation of the same partition over the arms'
  authored step tuples, which `_check_tuple` enforces equal to observed states):
  `mut_ladder_link` → bound=2, groups=2, sizes=[2,2]; `mut_ladder_region` →
  bound=3, groups=2, sizes=[3,2]. Both markers PASS byte-exact → the live
  partition re-derives the r76 edges {link:2, region:3} from data, not per-step pins.

### Claim 4 — 10 new CASES arms — **AGREE** (name note)

Committed rows (`run_battery.py:212`–`231`): `mut_ord_renew_xform`,
`mut_ord_xform_renew`, `mut_ord_link_offmv`, `mut_ord_link_mvoff`,
`mut_ord_kill_mapoff`, `mut_ord_mapoff_kill`, `mut_force_link`, `mut_force_ctl`,
`mut_ladder_link`, `mut_ladder_region` — 10 rows, all PASS under the battery and
under a dedicated `--only` spot run (10/10, exit 0, receipt
`runs/20261014T113520538123Z/verdicts.json`). The claim's "names approximate"
covers it: there are no `mut_ord_agent_*` tracked arms — the agent pair stayed
spike-only per the author report's own table.

### Claim 5 — battery 173/173 + 4 probes + Node 31/31; 163 prior rows byte-stable; seeds_unchanged — **AGREE**

- Full battery (absolute `--runs`, all four probes), verifier-owned dir:
  `corpus/live/r77-verifier/runs/20261014T113358221848Z/verdicts.json` →
  `verdict=PASS`, `totals: cases=173 pass=173 fail=0 ordinary=128
  negative_controls=45`, `seeds_unchanged=true`, runner exit 0, stderr empty.
- Probe receipts all `verdict=PASS`: `mutation-verdicts.json` (mutant detected,
  `detected=true`), `crash-exit-verdicts.json`, `stream-attribution-verdicts.json`,
  `tree-timeout-verdicts.json` (verified detached witness, SIGTERM cleanup).
- **0 mismatches** vs the author's receipt: 173 cases × 12 fields
  (`case, script, flags, expected_exit, actual_exit, error, kind, marker, verdict,
  reasons, stdout, stderr`; `command`/`elapsed_seconds` excluded — path/timing).
- **0 mismatches** for the 163 prior rows vs the r76 verifier receipt
  (`corpus/live/r76-verifier/runs/20261014T102343921913Z/verdicts.json`), same
  12 fields — byte-stability confirmed against an independent prior-round receipt,
  not only the author's.
- Node suites (`corpus/live/r77-verifier/node/`): run_cases 3/3, run_layer_cases
  4/4, run_order_cases 9/9, run_camera_cases 5/5, run_ortho_cases 5/5,
  run_ray_cases 5/5 = **31/31**, all receipts `verdict=PASS`,
  `seedsUnchanged=true`, all six exits 0.
- Seed immutability: battery-internal before/after digest map equal
  (`seeds_unchanged=true`) and `git status --porcelain` empty post-run.

### Claim 6 — diff shape `navagent3d_detour.gd` +502/−33, `run_battery.py` +20/−0 — **AGREE** (cosmetic note)

- `git show --numstat 35dfbe2`: `501/33` and `20/0`. The "+502" is the author's
  `grep '^+'` counting the `+++ b/` header line; true insertion count is +501.
  1992 + 501 − 33 = 2460 lines — matches the declared file length.
- The 33 removed lines are exactly the refactor surface: the single-dict
  `_apply_mutation(step["mutate"], srv)` call, the old per-dict fs-fold body
  (now inside `_mut_list`), and the pre-ladder PASS print line pair.
- `run_battery.py` diff is pure addition (zero `-` lines): the 10 new rows sit
  between `mut_same_agent` and `remote3d_transform`.

## Residual risk / verification gaps

- The {1,2} forced serve boundary is host/build phase-dependent — reproduced here
  at 4/10 w1-stale; the tracked arm correctly pins around it (w0/w3 only).
- `srv_get`/`ladder` are opt-in schema keys; the unmodified paths are covered by
  the 163 prior rows all re-running green.
- All bounds are Godot 4.7.2 / 60tps-pinned — same qualification every prior round
  carries; the CASES rows are the tripwire.

Scratch confined to `corpus/live/r77-verifier/`; no commits, no subagents, no
tracked-file edits. Stopping here.
