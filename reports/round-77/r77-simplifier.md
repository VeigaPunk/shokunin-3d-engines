# Game-dev-3d round 77 — simplifier report (minimal-design critique, report-only)

Seat: simplifier. Judged the landed r77 diff — mutation APPLY-ORDER pinned as a
measured axis (10 new CASES arms + order-override/getter-readback/wait-ladder
machinery on the detour fixture). Author landed mid-review exactly as r76:
watcher (`watch_landing.sh`, 20s polls on the canonical repo) observed
`navagent3d_detour.gd` grow through 12 content snapshots from 08:09 to 08:16,
then stabilize; committed as `35dfbe2` at 08:32, followed by two fleet
comment-only commits — `565318c` (per-class serve-edge wording) and `5e02b25`
(mark-vs-phase mechanism note) — bringing HEAD to `5e02b25`. The snapshot
critiqued is the COMMITTED blob at HEAD — fixture sha256
`7d1e9ac076d9556ec9289be43d33b29d2e8dfd987ce29a2e9772adbe7c868167`, battery
`92c5ad87df04d8ed247ced3b83d06d0e384e28fbaef0b22a161f280deb64b661` —
byte-identical to `git show HEAD:` (receipt `landed_sha.txt`; `landed/` built
from `git show`, not the working tree). The two post-landing commits changed
**zero code lines** — verified by stripping all `#` lines on both blobs:
1830 non-comment lines byte-identical `35dfbe2`↔HEAD, so every run receipt
collected against the earlier blob remains valid for HEAD. All work inside own scope
(`corpus/live/r77-simplifier/`, gitignored — `git check-ignore` verified).
Host devin, `/usr/bin/godot` 4.7.2.stable.arch_linux.ed1daf0bf, physics 60 tps.
Repo reached via `.shokunin/game-dev-3d` symlink →
`~/Projects/shokunin/game-dev-3d-shokunin` (canonical, per r77-baseline).

**LSP note (seat rule):** the Godot LSP server answers on this host; semantic
reference checks below used the real server (driver `lsp_refs.py`), grep is
the literal cross-check only.

Landed diff at critique (e417365→HEAD): `M corpus/fixtures/navagent3d_detour.gd`
+542/−33 — +521/−33 code+comment at `35dfbe2`, +21/−0 net comment lines added
by the two hygiene commits — (r77 header block +31; 10 arm dicts ~+309;
`_tuple_sig` +11; `_run_steps`
mutate-list + `srv_get` capture; `_mut_list` helper +3; `_apply_mutation`
+`link_start`/`link_end`/`map_force`; `_read_srv` getter table; `_final_srv_state`
re-indented inside `for m in _mut_list(step)`; `srv_get` assert + ladder
partition + `ladder_tail` PASS suffix), `M corpus/fixtures/run_battery.py`
+20/−0 = 10 CASES tuples insertions-only (163 prior rows byte-preserved → 173;
**zero** `-` content lines in the battery diff).

## Verdict

**10/10 new arms and every machinery piece except one are load-bearing;
one dead key + one carried dead store flagged. The order-override
machinery is already the minimal expression — `mutate` accepts an ARRAY
of dicts applied in sequence through the unchanged `_apply_mutation`
(`_mut_list`, 3 lines, 2 consumers); zero setter bodies were duplicated.
The same `_mut_list` normalizes the `_final_srv_state` fold, which is
load-bearing in the order-aware direction (proven by mutant `m_fold`).
One stale comment survives the mid-round amendment.**

Delete-and-measure (all on the committed file; driver `run_mutants77.py`,
receipt `mut_landed.json`, 14 mutants, 0 protocol failures):

| element | removal/perturbation | observed |
|---|---|---|
| `map_force` key in arm | drop from `mut_force_link` mutate | `step0 srv link_enabled=true expected=false` — getter stays queued without the flush |
| `map_force` apply site | delete `if m.get("map_force")` block | identical diag — the flush call is what collapses the getter edge |
| `srv_get` readback pin | `link_iter` 1→2 on ctl | `step0 srv link_iter=1 expected=2` |
| doomed-write readback | `region_transform` (0,0,0)→(9,0,0) on xform_renew | `srv region_transform=0… expected=9…` — voided write asserted on the fresh RID |
| served-divergence pin | renew_xform path → corridor | `step0 npath=2 expected=3` — the moved mesh really is served |
| **array-order machinery** | xform_renew `[{xform},{del,recreate}]` → one dict `{xform,del,recreate}` | `step0 idx=0 expected=1` — SAME setters under dict/fixed order serve the moved mesh. The core discrimination: array order is what voids the transform |
| endpoint-move readback | `link_end` 5.9→5.5 in mvoff srv_get | `srv link_end=…5.9 expected=5.5` |
| `_mut_list` | return `[mut[0]]` for arrays | `step0 idx=0 expected=1` — every sub-dict must apply |
| fold iterates all sub-dicts | `for m in [_mut_list(step)[0]]` | `mutated region flags not in effect` — fold order must mirror apply order |
| ladder `bound` field | 2→9 | `ladder bound=2 groups=2 expected=9,2 sigs=[…]` (derived sigs printed in diag) |
| boundary derivation | `bound = i` → `i+1` | `bound=3 expected=2` — the edge is DERIVED, not echoed |
| inert-pair control A | mvoff array → one dict | **still PASSes** (expected) — the surviving-object convergence is honest, not vacuous |
| inert-pair control B | mapoff_kill array → one dict | **still PASSes** (expected) — same for the absorbing map |
| sanity | mut_win_link idx 3→9 | `step1 idx=3 expected=9` — prior arms still discriminate post-diff |

## Per-arm discrimination lattice

Declared axis: apply-order is load-bearing iff ≥1 order-pair produces
observable distinct served state. Measured verdict (arms + author's probe
corroborated): **DIVERGENT for the doomed-RID pair, inert for both
surviving/absorbing pairs** — the claim "at least one order-pair diverges"
is confirmed by exactly one class.

| arm | distinct cell killed | marginal note |
|---|---|---|
| `mut_ord_renew_xform` | "fixed order never lands writes on a post-delete object" | one dict {delete,recreate,transform} — fixed order lands +5x on the FRESH rid → serves moved mesh `[(5,0,0.5),(5,0,1.0)]`, `srv_get` pins xform=(5,0,0). Half of the divergent pair |
| `mut_ord_xform_renew` | "any order converges" | hand order [{xform},{del,recreate}] — transform voids on the freed RID → serves unmoved corridor, `srv_get` pins xform=identity. The falsification witness itself; `o_collapse` proves the array (not the values) carries it |
| `mut_ord_link_offmv` / `mut_ord_link_mvoff` | "every same-tick pair is order-sensitive" | surviving-object inert pair: dict order vs move→disable converge on serve AND internals (en=false, endpoints moved — writes on a disabled link still land; `srv_get` three-key pin). Identical CASES markers are deliberate convergence evidence |
| `mut_ord_kill_mapoff` / `mut_ord_mapoff_kill` | "the absorbing map orders matter" | absorbing-map inert pair: kill-queued-then-freeze vs freeze-then-queue converge — committed tuple served under frozen map, 2f edge replayed post-reactivation |
| `mut_force_link` | "force collapses the serve edge" AND "force is a no-op" | srv_get en=false/iter=2 at w0 (getter edge → same-turn), serve stale at w0, fresh clamp at w3 — skips the jittered w1 sample deliberately |
| `mut_force_ctl` | "the getter edge was already 0" | unforced control: srv_get en=true/iter=1 at w0 (queued getter pinned as tracked content — exists nowhere else), en=false/iter=2 at w1, deterministic 2f serve |
| `mut_ladder_link` | "the 2f edge is hand-pinned, not derived" | spawn-anchored ladder (NOT a mut_win_link re-run — that arm is tp-anchored pop-traverse): stale,stale|fresh,fresh → derived bound=2 sizes=2,2 in the PASS marker |
| `mut_ladder_region` | "the 3f edge is hand-pinned, not derived" | steps 1–4 tuple-identical to `mut_win_region`'s ladder — marginal content is the derived partition + the 5th sample (sizes=3,2 pins post-boundary persistence). Retained: the declared deliverable is the partition receipt on both channels |

Cross-round subsumption: `mut_ord_*mapoff*` vs `mut_map_cycle` — cycle pins
kill-queued-under-inactive across steps; the ord pair pins same-tick
composition in both orders. `mut_ord_*_xform/renew_*` vs `mut_region_renew`/
`mut_region_move` — the latter mutate across steps, never same-tick. No old
arm becomes droppable; no new arm re-runs a stationary cell.

## Flag 1 — dead key: `_read_srv`'s `link_layers` branch (−2 lines, demonstrated)

`_read_srv` (committed lines 2277–2295) maps `srv_get` keys to server
getters. Consumer census over all **18 `srv_get` dicts** in the file:
`link_enabled` ×9, `map_active` ×4, `link_iter` ×3, `link_start`/`link_end`/
`region_transform` ×2 each — **`link_layers` ×0**. The branch at
2282–2283 has no consumer. Demonstrated: `nolinklayers/` = committed file
minus those 2 lines; `compare_detour.py` pairwise replay of all **88 detour
cases (exit, stdout, stderr) byte-identical, all exits == CASES, all markers
present** — receipt `runs_nolinklayers.json` (176 run records). Trivially
safe deletion — recommend dropping the 2 lines (or adding a consumer arm;
no current claim needs it). **Adopted**: the uncommitted working tree at
critique time already carries this exact deletion (`git diff` hunk at 2280).

## Flag 2 — carried dead store: `st2` at line 367 (re-proven at HEAD)

`st2 = states[states.size() - 1]` inside `if arm_cfg.has("steps"):` — the r75/
r76 flag, still live. LSP `textDocument/references` on `var st2` (HEAD file,
decl at 0-idx 354:5) returns exactly {354 decl; 366, 371, 373 writes;
429, 430 reads} — transcript `lsp_st2_head.json`. The only readers are the
`_run_link_arm`/`_run_pop_arm` dispatch args (430/431), and the steps path
`return _run_motion_arm(…)` at 428–429 precedes both — on the steps path the
store is never consumed. Same proof shape as r75/r76. **Delete 1 line.**
**Adopted**: the same uncommitted diff deletes the store at line 367.

## Flag 3 — stale comment: "never the serve edge" at line 2214 (live at HEAD, fixed in tree)

The `_mut_list` doc comment still reads "map_force … collapses the getter
edge to same-turn, **never the serve edge**" — the pre-amendment wording.
The fleet's own hygiene commits `565318c`/`5e02b25` fixed three sites —
the header block (207–227 now carries the per-class split and the
mark-vs-phase mechanism), the `mut_force_link` arm comment (~1838), and the
`map_force` apply comment (~2252, now "class-dependent (link: jittered
{w1,w2}; region: deterministic 3f->2f)") — but **missed this fourth
instance**: `grep -n "never the serve"` still hits line 2214 at HEAD.
Internally inconsistent — measured reality: the link-class serve edge under
force collapses to +1f on a phase-dependent fraction of runs. **Adopted**:
the uncommitted diff rewrites it to "the serve edge is class-dependent —
link jittered {w1,w2}, region deterministic 3f->2f".

**Flags-applied sanity**: all three fixes together on the working tree —
`headfix/` copy, `headfix_check.json`: `mut_force_link`, `mut_force_ctl`,
`mut_ord_xform_renew`, `mut_ladder_region` (marker `bound=3 groups=2
sizes=3,2` preserved), `mut_win_link` all PASS; `--arm=<bogus>` still
fails closed. Consistent with the byte-identical demonstrations: the
deletions touch no observable.

## Jitter-rate note (measured, corroborates the amendment)

The mid-review first landing (snap_10, 3-step `mut_force_link` pinning
w1-stale) flaked hard in my harness: **17/27 runs served fresh at w1**
(5/12 + 12/15 across two batches; receipt `runs_nolinklayers.json` first
pass also caught it live — the base side failed `step1 final=…4.0
expected=…5.5` mid-run). The committed arm's own header cites w1-fresh
"~15-20% …, w2 dominant" — but that rate is context-dependent: on the
author's probe shape (`r77a_probe.gd` force_link scenario, copied into my
`probe/` scratch — read-only reference, executed under my scope) I measured
**1/25 w1-fresh (4%)**, while the tracked-arm shape measured ~63%. The rate
is a phase artifact of *when* the forced drain lands vs the map's scheduled
sync, not a stable constant — the committed design (pin w0+w3, skip w1,
document the envelope) is the correct minimal expression of a jittered
boundary. `mut_force_link` post-amendment: **20/20 PASS on the 35dfbe2
blob + 10/10 re-hammered at HEAD** (`force_hammer_head.json`);
`mut_force_ctl` 20/20 + 10/10 at HEAD; all 8 other new arms 15/15 each.

Coverage note (not a defect): the header's "region: deterministic 3f->2f
(9/9 reps, r77-critic)" and "region transform value lands same-turn but
region_iter still stamps at w1" are comment-level claims sourced to sibling
scratch — no tracked arm exercises region+force. Acceptable documentation;
would need its own arm to become a battery-pinned fact.

## Prior-stability + contract preserved

- Battery diff is **pure insertion** (10 rows after `mut_same_agent`, zero
  `-` content lines): 163 → 173.
- Fixture deletions inventory: 30 fold-body lines re-emitted byte-identical
  modulo +1 indent inside `for m in _mut_list(step):` (verified
  programmatically), 1 call site (`_apply_mutation(step["mutate"], srv)` →
  the `_mut_list` loop), 2 print lines (→ `%s` `ladder_tail`). **Zero prior
  arm/cfg text modified.**
- Byte-stability measured, not just diffed: all **78 prior detour rows run
  on `base/` (pre-r77 HEAD `e417365`) vs `landed/` (committed `35dfbe2`)
  produce pairwise-equal (exit, stdout, stderr)** — receipt
  `runs_prior78.json` (156 records). The new machinery perturbs zero prior
  observables.
- Full 88-case replay on the committed file: `runs_landed.json` — every exit
  == CASES, every marker byte-present including the new `bound=… groups=…
  sizes=…` tail.
- Contract preserved: `call_deferred`/`_run` shape, 30-frame settle,
  exact-match markers, `_argval` unknown-`--arm` fail-closed, `_fail`/
  `_cleanup` teardown (new keys touch no owned-RID bookkeeping; `map_force`
  is an action, correctly not folded into `fs`; `link_start`/`link_end` are
  pinned via `srv_get`, not `fs` — consistent split of terminal state vs
  mid-run object truth).
- Honesty gates: `srv_get` captures after wait, before the forcing read;
  asserts run on `peek_only` steps too (ungated `if es.has("srv_get")`) —
  no silent path. The fold's mutation-honesty gate still fires for every
  arm (`fs["any_mut"]` set per non-empty sub-dict).

## Considered-and-rejected

- **Drop one arm of each convergent pair** (link_offmv/mvoff, kill_mapoff/
  mapoff_kill have pairwise-identical CASES markers): rejected — the inert
  claim needs BOTH orders pinned; a lone arm shows one order only. The
  `i_*_dict` controls prove the convergence is not vacuous.
- **Drop `mut_force_ctl`** as subsumed by the force arm + r76 edges:
  rejected — it carries the only tracked pin of the unforced getter queue
  (`en=true/iter=1` at w0); without it the force collapse has no in-build
  contrast.
- **Fold `srv_get` into `peek_*`**: rejected — server getters vs agent
  stored state are different stages; merging would blur the two-stage
  timing this round measures.
- **Fold `sizes` into `cfg["ladder"]` assertions**: rejected — the PASS
  marker already pins sizes byte-exact; a third asserted field duplicates.
- **Shrink `_tuple_sig`/`_read_srv` defensive tails** (`else null`/`-1`):
  rejected — they are the honest fail-closed paths for invalid RIDs;
  removing them makes a stale-RID read a hard error instead of a diag.

## Evidence index

- Landed snapshot: `landed/navagent3d_detour.gd` sha256 `7d1e9ac0…`,
  `landed/run_battery.py` `92c5ad87…` — byte-identical to `git show HEAD:`
  at `5e02b25` (`landed_sha.txt`); base sha map `base_sha.txt`. Code
  identical to the `35dfbe2` blob every run was measured on (0 non-comment
  line diffs).
- 88/88 replay on committed file: `runs_landed.json`.
- 78 prior rows byte-identical base↔landed: `runs_prior78.json`.
- Fail-path + control mutants: `mut_landed.json` — 14 mutants (12 fail-side,
  2 must-pass controls), verbatim diags in the lattice table.
- Dead-key demonstration: `nolinklayers/` (−2 lines), `runs_nolinklayers.json`
  — 88/88 byte-identical. Flags-applied working tree: `headfix/` +
  `headfix_check.json` — 5 arms green incl. the ladder marker intact.
- LSP: `lsp_st2_head.json` — `st2` refs {354 decl; 366,371,373 writes;
  429,430 reads} on the HEAD file (`lsp_st2_landed.json` has the same
  pattern on the earlier blob).
- Jitter measurements: `probe/jitter_rate.txt` (1/25 w1-fresh on the author
  probe shape); arm-shape rate 17/27 w1-fresh on snap_10 (shell-logged
  hammers; the runs_nolinklayers first pass also tripped it live);
  committed arm 20/20 + ctl 20/20 on `35dfbe2`, then **10/10 + 10/10
  re-hammered at HEAD** — `force_hammer_head.json`.
- Author's own evidence corroborated: `corpus/live/r77-author/runs/
  probe_all.stdout.txt` scenarios match landed arm constants (xform_renew
  converges corridor; renew_xform diverges to moved mesh; link pairs inert;
  ladder groups 2,2 / 3,2).
- Watcher record: `watch.log`, `snap_1..14` — the diff's landing trajectory
  (the w1-pin flake is visible in snap_10 vs the committed skip-w1 arm;
  snap_13/14 are the two comment-only hygiene commits).

## Scope notes

- Sibling reports read for consistency (r77-author, r77-baseline,
  r77-reviewer). Semantic verdicts on the model itself are critic/
  adjudicator scope; this report judges only minimal expression,
  duplication, deletability, and measured stability.
- Semantic context for this build/geometry/host: bridge island fixture +
  corridor, corridorfunnel, cell 0.25, 60 tps, scripted teleports.
- Remaining slack after this diff: the `link_layers` `_read_srv` branch
  (−2, demonstrated), the `st2` store (−1, re-proven), and the stale
  "never the serve edge" doc line — all three already applied in the
  uncommitted working tree at critique time and re-verified green.
  Every other new line earns its cell. Stopping.
