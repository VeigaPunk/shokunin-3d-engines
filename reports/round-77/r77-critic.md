# r77 critic — navagent3d same-tick mutation APPLY-ORDER / map_force_update / verdict-groups

Lane `g3d`, seat `critic`, round `r77`. Repo `/home/vgpnk/Projects/prymeagnt/game-dev-3d`
(= canonical `~/Projects/shokunin/game-dev-3d-shokunin`). Godot
`4.7.2.stable.arch_linux.ed1daf0bf` (`/usr/bin/godot`).

## Review cutoff

The landed diff arrived in the working tree mid-review (uncommitted):
`corpus/fixtures/navagent3d_detour.gd` +500/-33, `corpus/fixtures/run_battery.py` +20,
`reports/round-77/` untracked (baseline/boundary/reviewer/scout reports present; no
`r77-author.md` at cutoff). The diff **changed again during review** — `mut_force_link`
was re-authored from a 3-step ladder pinning w1-stale to a 2-step arm that skips w1
(mtime 2026-10-14 08:20–08:21 -03:00). All findings below cite the CURRENT file,
md5 `bc4206062aac1d64555ccd6f5e57fc19` (snapshot:
`corpus/live/r77-critic/fixture-snapshot.gd`, runner snapshot `runner-snapshot.py`).

## Headline verdict

The declared falsifiable claim — "at least one order-pair produces observable distinct
served state" — **stands, but only via the doomed-RID class it actually measured**, and
the "seam analog / emergent state" framing over-reads the mechanism. The divergent pair
(`mut_ord_renew_xform` vs `mut_ord_xform_renew`) is fully explained by which RID
received the transform — sequential dead-write voiding, not a third emergent state:
the fixed-order composite serves exactly the tuple `region_transform` alone produces.
Meanwhile a real counterexample exists where order DOES change the world but NOT the
served tuple (my `omk` pair) — so "order-pair convergence" verdicts must be scoped to
the served surface only; they do not prove the internal state converged.

`map_force_update` claims in the diff are **partially falsified**: the code comment
"the served-path edge is unmoved" (fixture L2250-2253) is false for region transforms —
the serve edge moves deterministically 3f→2f (9/9 reps) — and for link kills the serve
edge is jittered w1/w2 rather than fixed at w2. The header comment (L209-217) now
honestly documents the jitter; the arm evades the w1 sample instead of pinning it.

Verdict-groups receipt is sound as a serve-surface partition (bounds reproduce r76
edges exactly) but hides real intra-group transitions at the getter and stored-path
surfaces — the "bound" is a serve-edge bound, not a settle bound.

Battery: 173/173 PASS on the current tree; prior 163 rows byte-stable.

## Attack 1 — is apply-order observable at served AND raw surfaces?

Landed mechanism: `mutate` may be an array of dicts, each applied through the fixed
`_apply_mutation` order (`_mut_list` L2211, `_apply_mutation` L2215;
delete→recreate→transform→enabled→layers→link{en,layers,start,end}→agent→map_force→map_active).
Any key-level ordering is expressible as a sequence of singleton dicts — the
mechanism is complete for the axis it claims to pin.

My independent probe (`corpus/live/r77-critic/scratch/r77c_order.gd`, run via
`godot --headless --path corpus/live/r77-critic/scratch --script res://r77c_order.gd --
--arm=<a>`) applies per-key orderings directly and reads both the agent tuple and raw
server state (`map_get_iteration_id`, `map_get_regions` count, `link_get_enabled` /
`link_get_start_position` / `link_get_iteration_id`, `region_get_transform` /
`region_get_iteration_id` / RID validity). Results, receipts `runs/<arm>.stdout.txt`:

| pair (fixed vs hand) | served tuple | raw server state | verdict |
|---|---|---|---|
| oxd: {del,rec,xform} vs {xform,del,rec} | DIVERGE: moved mesh `[(5,0,0.5),(7,0,0),(7,0,1),(7,0,4)]` vs corridor | x=5.000 vs x=0.000 | divergent — matches `mut_ord_renew_xform`/`mut_ord_xform_renew` |
| odr: {del,rec} vs {rec,del} | DIVERGE: corridor vs empty | nreg=1 vs nreg=0 | divergent |
| oer: {rec,en} vs {en,rec} | DIVERGE: empty/unreachable vs corridor | en=false vs en=true on fresh RID | divergent — en before recreate dies with the freed RID |
| omk: {del,rec,en} vs {rec,en,del} | **CONVERGE** (empty/unreachable) | **DIVERGE**: nreg=1 live disabled region vs nreg=0 void | masking witness — see attack 2 |
| olm: {en,move} vs {move,en} | converge (clamp) | converge (en=false, start=10,10) | inert — writes on a disabled link still land |
| olr: {en,layers} vs {layers,en} | converge | converge | inert |
| oal: {link_en, agent_layers} vs reversed | converge (empty, synchronous) | converge | inert — agent write is synchronous and dominates |
| oml: {link_en, map_off} vs {map_off, link_en} | converge (stale under frozen map) | converge (en=false, active=false, iter frozen) | inert — matches `mut_ord_*mapoff*` |
| oxn: {del,xform} vs {xform,del} | converge (empty) | converge (void) | inert — the transform dies either way |

Direct arm receipts (`runs/arm_*.out`, all exit 0, PASS markers byte-identical to
CASES expectations L212-231): both divergent order arms pass and pin `srv_get`
readback — `mut_ord_renew_xform` asserts `region_transform=(5,0,0)`,
`mut_ord_xform_renew` asserts `(0,0,0)`, so the landed work DOES probe raw server
state, not just the tuple. That part of my standing objection is answered.

What the landed set does NOT pin: no arm covers a pair whose tuple converges while
internals diverge (`omk`-shape), so the report-level claim "order is inert for
surviving-object pairs" is supported only on the link/map pairs actually landed —
true there, but the generalization "order is inert outside doomed-RID voiding"
overreaches: `{del,rec,en}` vs `{rec,en,del}` is a surviving-*nothing* distinction the
tuple cannot see while `map_get_regions` count differs 1 vs 0 (receipt
`runs/omk_fix.stdout.txt` vs `runs/omk_alt.stdout.txt`).

## Attack 2 — is the "seam analog" claim sound?

The brief calls the composed mutation "the 'seam' analog — emergent state neither
setter alone produces". Measured against the divergent pair this is half-true:

- `{del,rec,xform}` (fixed) serves `[(5,0,0.5),(5,0,1)]`-class moved-mesh tuple.
  But `region_transform` alone on the surviving RID serves the SAME moved tuple —
  the served surface cannot distinguish "fresh RID born at +5x" from "old RID moved
  to +5x". The emergence is internal only (RID identity / region_iter), not a served
  state neither op produces.
- What IS genuinely produced only by the composition: the *freed-RID write voiding* —
  `{xform,del,rec}` leaves the new region at identity because the write died with the
  freed RID. That is sequential dead-write semantics, exactly explainable without any
  emergence vocabulary.

Counterexample found where order "should matter but does not" at the served surface:
`omk` — `[rec,en,del]` frees the disabled fresh RID, `[del,rec,en]` leaves it alive
and disabled. Same tuple forever (empty/unreachable), different world (nreg 0 vs 1,
RID validity). Any verdict system that only diffs served tuples — including the
landed `_tuple_sig` partition — reports this order-pair "converged". For the six
landed convergent pairs the `srv_get` pins make convergence honest; the omk-shape gap
is the standing hole.

## Attack 3 — does map_force_update reach the serve path?

Landed mechanism: `map_force` key applied inside `_apply_mutation` after all RID/agent
writes, before `map_active` (L2253-2255). Landed claim (code comment L2249-2252):
"the object-getter edge collapses to same-turn while the served-path edge is unmoved."
Header (L209-217) after the mid-review re-edit: getter same-turn, "SERVE edge does not
collapse (stale at w0)", serve boundary "JITTERED — fresh at w1 on some runs, w2 on
others", arm "skips the w1 sample".

Measured, all receipts under `corpus/live/r77-critic/runs/`:

- **Getter edge collapses to same-turn** for link: `fu_link.stdout.txt`
  `post-fu SRV ... link_iter=2 en=false` — applied and iteration-stamped at T=0.
  Confirmed; `mut_force_link` pins `srv_get {en=false, link_iter=2}` at w0.
- **Region getter asymmetry**: `fu_region_rep*.stdout.txt` `post-fu SRV ...
  region_valid=true iter=1 x=5.000` — the transform VALUE is same-turn but
  `region_get_iteration_id` does NOT stamp until w1 (`iter=2` at w1). The header's
  "iter stamped at w0" is link-specific; the region stamp edge is w1 even under force.
- **Link serve edge is jittered**: fresh-at-w1 observed in `fu_link.stdout.txt`,
  `fu_link_clean.stdout.txt`, `fu_link_mapq.stdout.txt` (`w1 map_iter=3` + fresh
  tuple), in `fu_par3`, and **inside the official battery**: run
  `battery-runs/20261014T111826354707Z/verdicts.json` failed
  `navagent3d_detour_mut_force_link` with `step1 final=2.500000,0.000000,4.000000
  expected=2.500000,0.000000,5.500000` — the fresh clamp served at the w1 sample the
  (then-3-step) arm pinned stale. Stale-at-w1 observed in `fu_clean_rep1..12` (12/12),
  `arep1..3`, `crep1..3` and most later reps. Total: fresh@w1 in ~5 of ~30 identical
  invocations ≈ 15-20%; dominant mode w2. w0 is always stale (9/9 + fresh-agent probe).
- **Region serve edge is moved, not jittered**: `fu_region` rep1-9 show
  `w2 MAPQ` fresh translated path and fresh tuple — serve edge **2f under force vs
  3f unforced** (`lad_region` control + 3 fresh reps: stale w2, fresh w3). 9/9.
  This falsifies the code comment's "the served-path edge is unmoved" — for region
  mutations every pipeline stage shifts −1f under force: xform getter w1→w0,
  region_iter w2→w1, map_iter w3→w2, serve w3→w2.
- **Bare force is a no-op**: `fu_nop` — `map_iter=2` pre, post-fu, and w2; no sync
  cost, no getter churn. Good control.
- **Force under inactive map**: `fu_mapoff` — `off+fu SRV active=false ... link_iter=2
  en=false` — the queued link write IS getter-applied under force even while the map
  is frozen; `map_iter` stays frozen at 2. Also observed: `map_set_active(true)` is
  itself a queued write — `on_w0 SRV active=false` same-turn after reactivation.
- **Fresh-agent probe**: `fu_newagent` — a brand-new agent on the same map still gets
  the stale 4-point link path at w0 post-force (`npath=4` through the dead link) while
  `link_iter=2 en=false`. The stale state at w0 is the MAP's served routing graph, not
  agent-side caching.

Bottom line for the CASES arm: `mut_force_link` (current 2-step, w0-stale + w3-fresh)
is deterministic-safe — 8/8 direct reps + battery PASS — but it no longer samples w1,
so it cannot detect the jitter it documents. That is honest evasion; the reportable
correction is the still-overbroad code comment "served-path edge is unmoved" (false for
region) and the header's "next scheduled sync phase" mechanism, which is a hypothesis —
the deterministic −1f on the whole region pipeline is equally consistent with
force-update *performing one sync stage immediately* rather than merely rescheduling.

## Attack 4 — verdict-groups receipt audit

`_tuple_sig` (L2031) signs idx, next, final, dist (%.6f), reachable/reached/finished,
and the full path — the complete served tuple; the partition (L2423-2447) is
contiguous-run equality with `bound` = first differing index and `sizes` recorded in
the PASS marker. `mut_ladder_link` derives `bound=2 groups=2 sizes=2,2`;
`mut_ladder_region` `bound=3 groups=2 sizes=3,2` — reproducing the r76 edges
(2f link, 3f region) as partition boundaries rather than hand-pins. Both arms PASS
(`runs/arm_mut_ladder_*.out`; battery2 rows PASS).

Hidden intra-group spread — confirmed, with exact reproductions:

- In `mut_ladder_link` group 0 (samples w0,w1, identical served signature), the raw
  server state diverges: `lad_link` shows `w0 SRV link_iter=1 en=true` (write still
  queued) vs `w1 SRV link_iter=2 en=false` (applied). The group lumps "queued" with
  "applied" — the getter edge (1f) lives inside group 0.
- In group 1 (w2,w3), the pre-force stored path differs: `w2 PEEK` still shows the
  stale 4-point path while `w2 TUPLE`/MAPQ are fresh; `w3 PEEK` is fresh. Same
  signature, different stored state — the stored-path refresh trails the forcing read.
- `pos` is excluded from the signature entirely (by design — a tp mid-ladder would
  split groups), fine for this use but worth naming.

So the derived `bound` is strictly a **serve-surface** bound: it answers "when does
the served tuple first change", not "when does the system settle" — the getter edge
(w1) and the stored-path refresh (w3, one behind the serve edge at w2) sit inside the
groups on either side. The header comment scopes it as "per-step SERVED tuples" — the
scoping is honest; consumers should not cite `bound=2` as "the sync edge" without the
qualifier. No distinct-signature-hiding bug found in the partition code itself:
`bound` stays -1 iff all signatures identical, and every per-step tuple is still
full-pinned, so a mid-ladder regression fails the arm before the group check.

## Stability — prior 163 rows

- `run_battery.py` diff vs HEAD: pure 20-line append — 10 new case tuples at L212-231,
  zero edits to existing expected markers. CASES now 173 entries.
- `navagent3d_detour.gd` diff: additive only for prior behavior — new `_mut_list`
  wraps dict mutations identically (`mut if mut is Array else [mut]`); new
  `_apply_mutation` keys (`link_start/link_end/map_force`) fire only when present;
  `srv_get`/`ladder` blocks fire only when authored; PASS-line print gains `%s%s` with
  `ladder_tail=""` for non-ladder arms → byte-identical output for all prior arms.
- Battery run 2 (clean, post-edit tree — run dir fixture copy md5-identical to
  working file): `corpus/live/r77-critic/battery-runs/20261014T112816558433Z/verdicts.json`
  → `verdict: PASS, seeds_unchanged: true, results: 173, fails: []`,
  log `battery2-run.log` `totals: cases=173 pass=173 fail=0`. Exact-marker matching
  makes all 163 prior rows byte-stable by verification, not just inspection.
- Battery run 1 (started before the mid-review re-edit): `20261014T111826354707Z`
  → 172/1 — the one FAIL was `mut_force_link` hitting the w1-fresh jitter described
  above, plus `seeds_unchanged=false` because the author's edit landed mid-run. Kept
  as a receipt: the flake is real and was observed in the official harness.

## Commands and receipt paths

Independent probe suite: `godot --headless --path corpus/live/r77-critic/scratch
--script res://r77c_order.gd -- --arm=<arm>` → `corpus/live/r77-critic/runs/<arm>.stdout.txt`
(probe source `corpus/live/r77-critic/scratch/r77c_order.gd`, runner `run_arms.sh`).
Arm replays: `godot --headless --path corpus/fixtures --script navagent3d_detour.gd --
--arm=<arm>` → `runs/arm_*.out` + `runs/mfl_*.out` (8/8 mut_force_link PASS).
Battery: `python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot --runs
corpus/live/r77-critic/battery-runs` → `battery2-run.log` (exit 0) and the two
`battery-runs/*/verdicts.json` receipts above.

## Issues encountered

- The landed diff was edited while under review (mut_force_link 3-step→2-step,
  CASES marker updated accordingly). Findings cite the current md5; the earlier
  battery FAIL documents the flake that motivated the re-edit.
- One invalid probe invocation (godot without `--script` printed banner-only);
  discarded, no receipt relied on it.
- `reports/round-77/r77-author.md` absent at cutoff — author's own verdict text not
  reviewable; comment blocks in the fixture carry the claims assessed here.
