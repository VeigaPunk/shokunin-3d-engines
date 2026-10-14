# Game-dev-3d round 77 — author: mutation APPLY-ORDER pinned, map_force_update reach, wait-ladder verdict groups

Seat: author. Lane `g3d` round `r77`. Leaf lane — no subagent dispatch, no
commit/push/merge/rebase/stash/checkout. Tracked edits limited to the two
permitted files; scratch under `corpus/live/r77-author/`; this report is the
only write outside `corpus/`.

Brief: `.ufo/waves/shokunin-train-20261014-w8/tasks/g3d-author.txt` — pin
mutation APPLY-ORDER as a measured axis (is `_apply_mutation`'s fixed order
delete→recreate→transform→link→agent load-bearing or inert?), land a
`map_force_update` CASES arm (does it collapse only the object-getter edge,
or the serve edge too?), land a wait-ladder verdict-groups receipt, keep all
163 prior rows byte-stable.

Godot `4.7.2.stable.arch_linux.ed1daf0bf` via `/usr/bin/godot --headless`,
project physics 60 tps (`corpus/fixtures/project.godot`).

## Declared-claim verdict: CONFIRMED — apply-order is load-bearing

At least one order-pair produces observable distinct served state: the
doomed-RID pair `{region_transform} ↔ {region_delete+region_recreate}`.
The same setter multiset applied in different orders serves two different
post-sync paths. The claim "at least one order-pair produces observable
distinct served state" survives; the failure mode is *voiding*: a write
queued on a RID that a later dict frees is silently discarded by the server.

## Measured order-pairs

New machinery: a step's `mutate` may be an `Array` of dicts; each element is
applied in sequence through `_apply_mutation`'s unchanged fixed order
(`navagent3d_detour.gd:2215`) — the hand-ordered override — while a bare
dict keeps the fixed order for the whole set. Fixed order per dict:
delete → recreate → region transform/enabled/layers → link
enabled/layers/start/end → agent layers → `map_force` → `map_active`
(`navagent3d_detour.gd:2215`–`2267`).

| order pair | verdict | measured difference |
|---|---|---|
| {delete,recreate}→xform (dict/fixed) vs xform→{delete,recreate} (array) | **DIVERGENT** | `mut_ord_renew_xform` serves the moved corridor `[(5,0,0.5),(5,0,1.0)]`, pathlen 0.500000, readback xform `5,0,0`; `mut_ord_xform_renew` serves the unmoved corridor `[S,(2,0,1),(2.5,0,3.5)]`, pathlen 4.130649, readback xform stays identity `0,0,0` — the +5x lands on the doomed RID and is voided |
| link disable + endpoint move (dict: enabled→start/end) vs move→disable (array) | inert | both serve the corridor clamp `final=(2.5,0,4.0)` pathlen 4.622520; `srv_get` pins identical post-sync internals (en=false, endpoints (2.5,0,3.9)/(2.5,0,5.9) — writes on a disabled link still land) |
| link kill + map_off (dict: link→map) vs map_off→kill (array) | inert | both serve the committed tuple under the frozen map (`map_active=false` via `srv_get`), then replay the 2f reactivation edge to the same fresh clamp |
| agent_layers vs link setters, both orders (spike only) | inert | convergent served tuples — agent writes are synchronous on both orders |
| same-key last-write (flip/flop, spike only) | inert | ordinary last-write-wins inside one dict |

Divergence requires the doomed-RID pattern — a write targeting a RID that a
later sub-dict frees/recreates. For surviving objects the server applies
queued writes set-wise; order within the tick is inert. For an absorbing
change (`map_set_active(false)`) both orders converge because the freeze
swallows the whole queued set regardless of queue position.

## map_force_update: collapses the GETTER edge, not the serve edge — and the serve edge is JITTERED

`mut_force_link` vs `mut_force_ctl` (same-tick `link_set_enabled(false)`,
with vs without `NavigationServer3D.map_force_update(srv["map"])`,
`navagent3d_detour.gd:2255`):

| edge | control (no force) | forced |
|---|---|---|
| object getter (`link_get_enabled`, `link_get_iteration_id`) | stale at w0 (en=true, iter=1); applied at w1 (en=false, iter=2) | **applied at w0** (en=false, iter=2) — edge 1→0, collapsed to same-turn |
| served path | stale w0, stale w1, fresh w2 (deterministic r76 edge) | stale w0 (pinned); fresh by w3 (pinned); **boundary w1-vs-w2 is nondeterministic** |

The jitter is measured, not assumed: the arm originally pinned w1-stale and
flaked — first full battery attempt failed `mut_force_link` step1
(`final=2.500000,0.000000,4.000000` served where the stale `(2.5,0,5.5)`
was expected, exit 1, 172/173), and standalone reps went 2/5 fail. The
forced drain lands the map rebuild on the next scheduled sync *phase*, so
under force the serve edge is {1,2} on this host; without force it is the
deterministic w2. The tracked arm therefore pins only the stable facts —
`srv_get` applied + stale serve at w0, fresh clamp at w3 — and skips the
jittered w1 sample (`navagent3d_detour.gd:1849`–`1872`, header note
`:209`–`217`). Answer to the brief's question: force collapses the getter
edge only; it does *not* collapse the serve edge, and it makes the serve
boundary phase-dependent rather than earlier.

## Wait-ladder verdict groups

Arm cfg key `ladder` (`{"bound":N,"groups":M}`): `_run_motion_arm`
partitions the per-step SERVED tuple signatures (`_tuple_sig`,
`navagent3d_detour.gd:2031` — canonical over idx/next/final/dist/flags/
path elements) into consecutive identical groups; `bound` is the first
sample index whose signature differs from sample 0 — the window edge is
*derived from the partition*, not pinned by hand. Unit waits make the
sample index equal cumulated post-mutate frames.

- `mut_ladder_link`: tuple sequence stale,stale,fresh,fresh →
  **bound=2, groups=2, sizes=2,2** — re-derives the r76 2-frame link edge.
- `mut_ladder_region`: stale×3,fresh×2 → **bound=3, groups=2, sizes=3,2** —
  re-derives the r76 3-frame region edge.

Both bounds match the r76-pinned edges; the ladder emits
`bound=N groups=M sizes=...` in the PASS marker itself.

## Files changed (uncommitted)

| file | delta | sha256 (working tree) |
|---|---|---|
| `corpus/fixtures/navagent3d_detour.gd` | +502/−33 (2460 lines) | `fa4eb04af0387ac27c1bc4ec9aa782613e8b911da8b7a991852dc5ccb8832e77` |
| `corpus/fixtures/run_battery.py` | +20/−0 (additive only — all 163 prior CASES rows byte-stable) | `92c5ad87df04d8ed247ced3b83d06d0e384e28fbaef0b22a161f280deb64b661` |

`git status --porcelain`: only these two `M` plus `?? reports/round-77/`
(sibling reports + this file). Fixture changes: round-77 header block
(`:193`–`222`), 10 arm cfgs (`:1677`–`~1970`), `_tuple_sig` (`:2031`),
`_run_steps` array-mutate + `srv_get` capture (`:2167`), `_mut_list`
(`:2211`), `_apply_mutation` link_start/link_end/map_force (`:2215`,
force call `:2255`), `_read_srv` widened to link endpoints/map_active/
region xform (`:2269`), `_final_srv_state` folds mutation sequences
(`:2294`), `_run_motion_arm` `srv_get` + ladder validation and PASS-marker
`bound/groups/sizes` suffix (`:2351`). New CASES rows:
`run_battery.py:212`–`231`, inserted between `mut_same_agent` (`:210`) and
`remote3d_transform` (`:232`).

## Evidence

- Bounded spike before tracked edits:
  `corpus/live/r77-author/scratch/proj/r77a_probe.gd` (SceneTree probe,
  same geometry/keys) — measured all order pairs, force getter/serve
  ladders, and both verdict-group partitions before any tracked file was
  touched.
- Focused arms (post-edit fixture copied to scratch):
  `corpus/live/r77-author/runs/arm_<arm>.stdout.txt` /
  `.stderr.txt` — 10/10 `ARMS_OK=10/10`, non-banner stderr empty for all.
  Post-fix `mut_force_link` standalone: 6/6 exit 0
  (`/tmp/fl2_*.out`, all emitting the pinned marker).
- Full battery (final, green):
  ```
  python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
    --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r77-author/runs \
    --probe-failing --probe-crash-exit --probe-stream-attribution --probe-tree-timeout
  ```
  exit 0 — `totals: cases=173 pass=173 fail=0 ordinary=128
  negative_controls=45 probes=4`, `seeds_unchanged: true`, all four
  probes ok. Receipt:
  `corpus/live/r77-author/runs/20261014T112216847660Z/verdicts.json`
  (log: `corpus/live/r77-author/runs/battery_full.log`; scratch +
  seed-digest map inside the run dir).
- Prior-row byte-stability: `git diff corpus/fixtures/run_battery.py`
  contains zero `-` lines (20 added lines only); all 163 prior rows pass
  unchanged against the refactored fixture.
- Nondeterminism record (pre-fix): first full battery exit 1, fail=1 —
  `ERROR: navagent3d_detour: mut_force_link step1
  final=2.500000,0.000000,4.000000 expected=2.500000,0.000000,5.500000`;
  standalone reps 2/5 fail at the same step. Root cause: forced flush
  jitters the serve boundary {1,2}; fixed by pinning deterministic samples
  only (w0/w3). Reported, not masked — the jitter itself is part of the
  measured result.

## Residual risks / notes

- The `{1,2}` forced serve boundary is host/build phase-dependent; the
  tracked arm pins around it. A future round could instrument the sync
  phase directly if a deterministic w1 pin is wanted.
- `srv_get`/`ladder` extend the step schema but are opt-in keys; all prior
  arms exercise the unmodified paths (173/173 confirms no behavior drift).
- Operator-owned follow-ups: integration/commit of the two tracked files.
