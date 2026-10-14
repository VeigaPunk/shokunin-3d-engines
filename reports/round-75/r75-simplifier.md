# Game-dev-3d round 75 — simplifier report (minimal-design critique, report-only)

Seat: simplifier. Judged the landed r75 diff — MAP/LINK MUTATION under a
committed stored path as 11 tracked `mut_*` CASES arms on the detour
fixture (`mutate`/`peek_path`/`peek_idx`/`peek_only` step keys, `srv`
live-objects dict, `_apply_mutation`, `_final_srv_state` gate fold).
Author landed mid-review (diff observed growing +31 → +486 across polls);
the snapshot critiqued is fixture sha256
`dbe6a2ae10de9a5d6fa4314ae5f3e0a1b9ff8c02cc77da99c714a7392c5586dc`,
battery `f99c48f8e1671b7759aa57b3616771652d21578d363fdde048ebef2a1686844e`
— stable for the remainder of the review. All work inside own scope
(`corpus/live/r75-simplifier/`, gitignored per `corpus/.gitignore`;
verified `git check-ignore`). Host devin, `/usr/bin/godot`
4.7.2.stable.arch_linux.ed1daf0bf, physics 60 tps.

**LSP correction (load-bearing for seat rules):** a GDScript-capable LSP
server DOES answer on this host — `godot --headless --editor --path . --
lsp-port <p>` serves `textDocument/references` over TCP. r74 recorded "no
LSP server answers GDScript" — superseded: semantic reference checks below
used the real server (session transcript in scratch); grep used only as
the literal cross-check.

Landed diff at critique: `M corpus/fixtures/navagent3d_detour.gd`
+464/−11 (header model block +31; `srv`/`fs` setup; `want_regions`-aware
setup gate; link gate re-keyed to `fs`; new `any_mut` gate-honesty block;
`_run_steps` +`srv` +mutate/peek; `_apply_mutation` ~29 lines;
`_final_srv_state` ~45 lines; 11 arm dicts ~262 lines; `_run_motion_arm`
+peek_only branch +pre-read peek block), `M corpus/fixtures/
run_battery.py` +22/−0 = 11 CASES tuples, insertions-only (145 prior rows
byte-preserved → 156).

## Verdict

**11/11 arms load-bearing; zero drops; no arm duplicates a stationary
equivalent (every arm authors the mutation via `mutate` steps AFTER the
base tuple materializes — timing/provenance is the pinned fact, a fact no
setup-flag arm can express). One weakest row flagged (`mut_link_layers`
— its forcing-step tuple is byte-identical to `mut_link_drop` step0).
The r74-flagged `_check_tuple(obs,want,prefix)` consolidation is NOW
warranted and here demonstrated byte-identical on the landed file
(−53 lines, 71/71 cases equal); the author's new code adds two more
partial copies of the same tail rather than resolving it. The dead `st2`
store survives at line 301 — trivially safe to delete, proven via LSP
references. One honesty flag: the header's "no dead-hop point is ever
SERVED" and `mut_link_kill`'s "NO zombie served" comment overclaim —
r75-critic's `zw_popgate_sameturn` falsifies inside the setter→sync
window; every landed arm pins post-sync (wait≥5) semantics only.**

## Per-arm discrimination lattice

Declared axis: does a map/link mutation invalidate the stored path lazily,
leave a traversable dead-gate waypoint, or update on next forcing call?
The landed arms pin: LAZY, forcing-call-gated invalidation; zombie exists
as stored data only (post-sync); agent-side layers the synchronous
exception; latch gates invalidation off.

| arm | distinct cell killed | marginal note |
|---|---|---|
| `mut_link_kill` | "dead waypoint is served after kill" | idx walked INTO the hop (idx=3 at bank (2.5,0,3.4)), disable link, stale array in peek, forcing re-query anchors live → `[(2.5,0,3.4),(2.5,0,4.0)]`, `finished=true` CREATED by the mutation via the idx+pdd clause — the only arm where a mutation latches finish |
| `mut_link_drop` | "post-invalidation pops hit the dead hop" | follow-up tp onto the bank pops on the NEW path (idx stays 1, next=(2,0,1)); had the zombie been served this step reads idx=3 at the dead far endpoint |
| `mut_link_layers` | setter-mechanism only | forcing-step tuple byte-identical to `mut_link_drop` step0 (idx=1/next=(2,0,1)/final=(2.5,0,4.0)/clamped path); sole distinct content = `link_layers` setter + its `fs` read-back — weakest new row, keep per the per-setter gate-honesty convention (a `link_layers` no-op setter would otherwise go unexercised) |
| `mut_layers_agent` | "all mutation is lazy" | the SYNCHRONOUS exception: `peek_path=[]` same-turn while stale idx=1 stays readable; restore re-materializes the full link path with no retarget — unique both directions |
| `mut_layers_region` | empty-path tuple via region layers | `peek` = old corridor coords → `idx=0, next=pos, final=(0,0,0), path=[]` — the critic's `fw_layermask` landed |
| `mut_region_move` | transform invalidation + re-anchor on moved mesh | `peek` = pre-move coords → `[(5,0,0.5),(5,0,1.0)]`, idx→0, dist stays raw euclid — the critic's `fw_mapedit` landed |
| `mut_region_off` | `region_enabled` flag mechanism | same empty-tuple shape as `renew`/`layers_region` but a distinct setter class (flag vs layers vs RID lifetime); restore step pins flag re-enable |
| `mut_region_renew` | RID-lifetime mechanism | `free_rid` → empty; fresh RID recreate → byte-identical path re-materializes — exercises `srv["region"]` swap + `want_regions`/`region_mut` gates no other arm touches |
| `mut_link_revive` | link-direction restore | distinct stale provenance: its step-2 `peek_path` is the stale CLAMPED path (vs `mut_layers_agent`'s empty store) — reachable flips false→true, same target |
| `mut_lazy` | "mutation needs no forcing call to take effect" | the round's causality arm: `peek_only` after 10 pure physics ticks shows stored array+idx byte-identical — falsifies synchronous-clear and eager-invalidate models |
| `mut_latch_zombie` | "invalidation bypasses the finished latch" | stored path survives `region_transform` AND `region_delete`; `next` still serves (2,0,3), `reachable=true` on a deleted map — the only truly SERVED zombie cell |

Intra-family tuple overlaps are all mechanism-distinct, not semantic
duplicates: the three empty-tuple arms (`layers_region`/`region_off`/
`region_renew` step0s) exercise three different invalidation channels each
with its own `fs` read-back; `mut_link_layers`/`mut_link_drop` share one
forcing tuple (flagged above). No `mut_*` arm re-runs a stationary cell:
`link_disabled`/`link_layers_off`/`link_oneway_*`/`link_travelcost` author
flags BEFORE first query; the mut arms all pin a materialized path first —
the r73 arms measure gate presence, the r75 arms measure invalidation
timing.

## Weight item — `_check_tuple(obs,want,prefix)`: NOW warranted (demonstrated)

Post-landing the observable-tuple elif-chain is **3 identical full copies
+ 1 prefixed full variant + 2 NEW prefixed partial variants**:

- `_run_pop_arm` (lines 1389–1408) ≡ `_run_link_arm` (1456–1475)
  byte-identical; `_run_motion_arm` pre-motion (1667–1686) ≡ modulo
  `st`→`st2` — verified by `diff` after rename (receipts
  `chain_{pop,link,motion_pre,motion_step}.txt`).
- Step-loop full variant (~1710–1730): same chain, `step%d ` diagnostics.
- **New this round**: `peek_only` elif branch (~1697–1709) and the
  pre-read peek block (~1735–1748) — each a partial copy of the same
  tail (idx → npath → path-elements with `step%d peek `/`step%d pre-read `
  prefixes). The author extended the duplication rather than consolidating.

Demonstrated extraction (`cons/navagent3d_detour.gd`, built on the landed
file): one `_check_tuple` helper (~27 lines) replaces the 3 full copies +
the step full variant at 4 call sites; peek/pre-read/pos/pre-teleport/
metadata checks stay in callers. 1762 → 1709 lines (**−53**). Verified:

- **PASS path**: all 71 detour cases run on `base/` (byte-identical copy
  of landed fixture) vs `cons/` — (exit, stdout, stderr) tuples equal
  pairwise, every base exit == CASES expectation, every exact marker
  present, stderr empty. Receipt `runs_compare_landed.json`.
- **Fail path**: 4 forced mutants on the landed pair — collapsed-chain
  diag (`mut_link_kill step2 idx=1 expected=2`), empty-tuple arm
  (`mut_layers_region step0 final=…`), pre-read (`step2 pre-read idx=3
  expected=2`), peek_only (`step0 peek idx=1 expected=2`) — diagnostic
  text byte-identical; only GDScript-backtrace LINE NUMBERS differ
  (inherent to any line-shifting refactor; not marker grammar — the
  battery never matches backtrace lines, `classify` only demands
  stderr-empty on pass). Receipt `mut_compare_landed.json`; earlier
  13/13 r74-file mutants same result (`mut_compare.json`).

Verdict: **keep recommendation — land the extraction.** The r73
byte-stability objection is met by the diff above; the r74 "follow-up"
deferral has now collected a fourth and fifth copy. If a same-turn arm
(r75-critic's falsification edge) is demanded, it becomes a sixth
consumer. Optional further −~15: a `_check_stored(idx,path,want_idx,
want_path,prefix)` folds the two peek tails (they differ only in
observed-key names).

## Deletion candidate — `st2` dead store (line 301), proven

`st2 = states[states.size() - 1]` inside `if arm_cfg.has("steps"):`.
LSP `textDocument/references` on `var st2` (line 289) returns exactly
{289 decl, 301, 306, 308 writes; 363, 364 reads} — the only readers are
the `_run_link_arm`/`_run_pop_arm` dispatch args, and `arm_cfg.has("steps")`
returns into `_run_motion_arm(…, st, states)` at line ~361 BEFORE either
read: on the steps path the store is never consumed. Semantic proof via
the real server; grep agrees. **Trivially safe — delete 1 line.** The
malformed-config edge (empty `steps` array) keeps its crash class:
`states[states.size()-1]` at ~1756 (`var stf`) raises the same
index-error the deleted line would have.

## Considered-and-rejected

- **Drop `mut_link_layers`** (forcing tuple ≡ `mut_link_drop` step0):
  rejected — it alone exercises the `link_layers` setter through the
  `fs` honesty fold; dropping leaves a mutate-dict key with no tracked
  coverage. Weakest row; flagged, not dropped.
- **Fuse `mut_link_drop` + `mut_link_revive`** (drop is revive's first
  half): rejected — couples invalidation and restoration into one red;
  same rejection as prior rounds' fused arms.
- **Fuse the three empty-tuple region arms**: rejected — flag/layers/
  RID-lifetime are distinct invalidation channels with distinct `fs`
  folds; tuple-shape overlap is mechanism coverage, the established
  convention (r73 kept `link_disabled` vs `link_layers_off` for the same
  reason).
- **Fold `mut_lazy` into `mut_link_drop`** as a peek_only first step:
  rejected — `mut_lazy` is the pure no-forcing-call cell; mixing it into
  an arm whose later steps force reads obscures exactly what its
  `peek_only` proves.
- **Also fold `elif diag == ""` redundancies / `esp` binding**: subsumed
  by the helper (the `elif diag == ""` tail is dead-condition weight;
  `esp` stays — still used by the peek_only branch).

## Nits and honesty flags

- **Header overclaim (falsified half)**: header ~line 148 "no dead-hop
  point is ever SERVED" and `mut_link_kill` comment "NO zombie served" —
  r75-critic's `zw_popgate_sameturn` serves AND pop-traverses the dead
  gate inside the setter→sync window (invalidation latches at map sync,
  not setter call; even `link_get_enabled` reads stale same-turn). Every
  landed arm uses wait≥5 — post-sync only. The honest wording is "no
  dead-hop point is served once a physics frame has synced the mutation."
  A same-turn arm is adjudicator scope; the comment qualification is a
  2-line fix either way.
- **r74 nit restated correctly**: "`st` read wasted on link arms" is
  imprecise — for non-tp/non-steps arms `st2 = st` (line 308) aliases it
  and the link arm asserts exactly that read. No wasted read exists; the
  residual is the redundant `st2` name — cosmetic, covered by the `st2`
  verdict above.
- `peek_only` steps carry a partial tuple (no next/final/dist/flags/
  pathlen) — safe by construction: the `peek_only` elif precedes the
  full-tuple chain and no authored arm ends on `peek_only` (a trailing
  one would `KeyError` on `stf[...]`). Malformed-config edge, same class
  as empty `steps` — convention-consistent; noted not flagged.
- `want_regions` now reads `fs["region_gone"]`: the setup gate runs AFTER
  `_run_steps`, so for mutate arms it asserts the POST-mutation region
  count (recreate→1, delete→0) — correct-by-construction, verified live
  on `mut_region_renew`/`mut_latch_zombie`.
- `_apply_mutation` ordering claim (delete → recreate → transform/
  enabled/layers → link → agent) matches `_final_srv_state`'s fold; every
  mutate key is exercised by ≥1 arm; all `srv`/`fs` keys consumed.
- Gate-honesty proven live: neutering `link_set_enabled` inside
  `_apply_mutation` fails `mut_link_drop` with `authored link flags not
  in effect` (receipt `honesty_neuter/` run) — the `fs` fold genuinely
  falsifies no-op setters rather than only re-describing them.

## Contract preserved

`call_deferred`/`_run` shape, 30-frame settle, exact-match flags,
`_argval` unknown-`--arm` fail-closed, `_fail`/`_cleanup` teardown
(`region_recreate` erases+owns the fresh RID — teardown still frees
exactly the live set). `_run_steps` ordering extended additively:
set_target → tp → mutate → wait → peek capture → forcing read — the
order the laziness claim depends on. PASS grammar unchanged for all
prior arms (`steps=%d idxs=%s` reused by mut arms; new surface appears
only in failure diagnostics). Battery diff insertions-only; the 9
deletions on the fixture diff are the `arm_cfg`→`fs` re-key, the
`want_regions` line, and the `_run_steps` signature — generalizations
with identical defaults for non-mut arms, verified by the 60/60 prior-row
replay.

## Evidence index

- Landed-file snapshot: `base/navagent3d_detour.gd` sha256 `dbe6a2ae…`
  (byte-identical to working tree at critique time).
- 71/71 replay (60 prior + 11 mut): `runs_compare_landed.json` — base
  exits == CASES expectations, markers exact, stderr empty; base-vs-cons
  (exit/stdout/stderr) pairwise equal.
- Consolidation artifact: `cons/navagent3d_detour.gd` (−53 lines);
  failure-path receipts `mut_compare_landed.json` (4 mut mutants),
  `mut_compare.json` (13 r74-file mutants).
- Chain-diff receipts: `chain_{pop,link,motion_pre,motion_step}.txt`
  (pop≡link byte-identical; motion-pre ≡ modulo `st2`→`st`; step variant
  prefixed).
- LSP: Godot headless editor `textDocument/references` session —
  `st2` refs {289,301,306,308 writes; 363,364 reads}. Transcript in
  scratch (session log `/tmp/godot_lsp*.log` + inline python driver
  above).
- Honesty neuter: `honesty_neuter/` — `link_set_enabled` no-op'd →
  `mut_link_drop` fails `authored link flags not in effect`.
- Author's own green run corroborated: `mut_lazy` PASS marker
  byte-matches CASES row (`runs_compare_landed.json`).

## Scope notes

- Sibling reports read for consistency (r75-critic headline
  falsification + sync-window latency; r75-boundary 2/3-frame sync
  latency, map-wide eager invalidation, both directions of the
  latch-pinned zombie). Semantic verdicts on the model itself are
  critic/adjudicator scope; this report judges only minimal expression,
  duplication, and deletability.
- Semantic verdicts for this build/geometry/host: single region +
  optional island + optional server link, corridorfunnel, cell 0.25,
  60 tps, scripted teleports.
- Next deletion would remove a truth-table cell: remaining slack is the
  `_check_tuple` extraction (−53 demonstrated, −~68 with the peek-tail
  fold) and the 1-line `st2` store. Stopping.
