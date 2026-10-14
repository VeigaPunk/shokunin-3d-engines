# Game-dev-3d round 74 — simplifier report (minimal-design critique, report-only)

Seat: simplifier. Judged the landed r74 diff — MOVING-AGENT navigation
semantics as 18 tracked `mv_*` CASES arms on the detour fixture (scripted
teleports + target re-assignment). Simplifier did not author this round.
All mutants/replays ran in own write scope (`corpus/live/r74-simplifier/`);
seeds untouched — `corpus/live/` is gitignored (verified via
`git check-ignore`), and `git status` still shows only the author's
`M`/`??` entries. Host devin, `/usr/bin/godot`
4.7.2.stable.arch_linux.ed1daf0bf, physics 60 tps. No LSP server answers
GDScript on this host (only the unrelated `rea`/Ghidra MCP is
configured); reference checks below are grep-level, recorded as the
literal fallback per seat rules — no function-level deletion is proposed,
so no semantic caller proof was needed.

Landed diff at critique time (uncommitted working tree; fixture sha256
`336898f4b711021a21e619385244e662168889ba5c52ec6812af9c5034601276`,
battery `697b3d5fa0dcab147ee79016354e07dee52e6820777508cca237b27385f70f86`):
`M corpus/fixtures/navagent3d_detour.gd` +506/−5 across 6 hunks
(header model block, `pmd` write, `steps`/`states` dispatch,
`expected_pos`/`expected_target` generalization, 18 arm dicts, two new
functions `_run_steps`/`_run_motion_arm`), `M
corpus/fixtures/run_battery.py` +36/−0 = 18 CASES tuples, insertions-only.

## Verdict

**18/18 arms load-bearing; zero drops; no arm duplicates stationary
semantics (every arm authors ≥1 move). One weight item now graduates:
the observable-tuple elif-chain exists in THREE identical copies plus a
prefixed variant — the shared-helper extraction flagged-and-deferred in
r73 is now warranted. Two nits (dead `st2` store on the steps path, the
persistent link-arm wasted `st` read).** Declared claim (a) was
falsified in part by the author's own measurement (the path is NOT
unconditionally frozen — a `path_max_distance` breach re-queries), and
the header records the falsification honestly rather than forcing the
claim.

## Discrimination lattice — per-arm marginal value vs declared claims

Claim (a) frozen-vs-requery (path storage):

| arm | cell killed | marginal note |
|---|---|---|
| `mv_walk` | "any teleport re-queries" | composite corridor walk; per-step full-path pin — m2 mutant (forced re-query after tp) fails `step0 path[0]=1.0,0,0.5 expected=0.5,0,0.5` |
| `mv_void` | "off-mesh (no polygon) within pmd re-queries" | also pins strict tdd edge (euclid==tdd → reached=false) |
| `mv_pmd_edge` | "re-query boundary is not exactly pmd" | bracket pair: 4.995 frozen / 5.025 re-queries + B-edge clamp + idx reset to 0 |
| `mv_pmd_offmesh` | "off-map re-anchor restores on return" | 13.4-unit teleport clamps origin to (3,0,4); step2 pins NO-undo |
| `mv_pmd2` | "threshold is a hardcoded 5.0" | authored pmd=2.0 tracked — m1 (neutered pmd write) fails `step0 idx=1 expected=0` |
| `mv_latch` step2 | "finished agent still pmd-re-queries" | agent 10.63 from path[1], path `[fg,fg]` untouched — re-query gated OFF by the finished latch |

Claim (b) pop-follows (strict-< sequential vs stored path, live position):

| arm | cell killed | marginal note |
|---|---|---|
| `mv_live` | "re-pop needs a physics frame" | `wait=0` read already shows idx=2; step2 is the wait=5 identity twin — intra-arm control, justified |
| `mv_popback` | "idx follows current nearest" | teleport back to spawn keeps idx=2 — monotone — m3 fails `step1 idx=2 expected=1` |
| `mv_popstrict` | "euclid <= pdd pops" | exact-boundary cell at euclid==pdd under motion — m7 fails `step0 idx=1 expected=2` |
| `mv_popskip` | "idx jumps to nearest waypoint" | sequential no-skip + flags decoupled from idx — m6 fails `step0 idx=1 expected=2` |
| `mv_bridge_walk` | "link endpoints are special waypoints under motion" | idx 1→2→3 across the void hop, path frozen off-mesh mid-hop within pmd — narrowest unique cell (overlaps `mv_void` on off-mesh-frozen), still keep |

Claim (c) latch:

| arm | cell killed | marginal note |
|---|---|---|
| `mv_latch` | "moving away unlatches reached/finished" | latched through corridor spawn AND off-map (10,0,10) |
| `mv_unlatch` | "latch survives set_target / same-value dedup exists" | measured unlatch = ANY re-assignment; idx→0, path re-anchors — m4 (expects latched) fails `step1 flags ... expected=true,true,true` |

Claim (d) re-anchor:

| arm | cell killed | marginal note |
|---|---|---|
| `mv_reanchor` | "re-query anchors at original origin S" | new target, path[0]=live (1.5,0,0.5) |
| `mv_reanchor_same` | "same-value assignment is dedup'd" | path[0] moves on unchanged target |
| `mv_reanchor_bank` | "bank-side re-query ignores live pos / drops link" | declared bank-side pin; pop lands past link endpoint |
| `mv_reanchor_void` | "unreachable still routes / finished needs reached" | no-link pair-half; idx+pdd clause fires finished=true at the B-edge clamp |
| `mv_reanchor_lazy` | "query anchors at assignment-time position" | combined set_target+tp anchors post-teleport (2.6,0,2.0) — m5 (assignment-time model) fails `step1 path[0]=2.6… expected=1.5…` |
| `mv_reanchor_force` | "always post-move anchor" | read-between contrast that makes lazy load-bearing; anchors (1.5,0,0.5), frozen through follow-up tp |

Every arm kills a distinct cell; the six (a)/(d) re-anchor cells are
non-overlapping boundary/geometry cases (threshold bracket, off-map
clamp, authored-pmd, latch-gated, bank±link, lazy-vs-forced). No arm is
a stationary-arms rerun — all mutate position or target mid-flight.

## Missing-arm check — none against the declared claims

All four declared sub-claims pinned with controls; the falsified half of
(a) is pinned by its own boundary bracket rather than asserted away.
Getter-laziness (`get_current_navigation_path` does not force an update)
is documented in the header but asserted only indirectly (the pre-motion
`st` read uses the same getter sequence as every prior arm) — consistent
with r72/r73 convention; a dedicated arm would need a separate read
order, out of this fixture's `_read_state` grain. Not demanded.

## Mutation coverage — demonstrated (private scratch mutants, real exits)

Copy `mut/base.gd` (sha256 `336898f4…`, byte-identical to the landed
fixture); each mutant flips one engine behavior or expectation; run as
`godot --headless --path mut --script <mut>.gd -- --arm=<arm>`:

| mutant | arm | exit | measured diagnostic |
|---|---|---|---|
| m1: `path_max_distance` write neutered to `pass` | mv_pmd2 | **1** | `step0 idx=1 expected=0` — authored-pmd arm genuinely gated by the write (dist 4.53 < default 5 → stays frozen) |
| m2: `agent.target_position = agent.target_position` appended after each tp in `_run_steps` | mv_walk | **1** | `step0 path[0]=1.000000,0.000000,0.500000 expected=0.500000,0.000000,0.500000` — the per-step whole-path pin catches a real re-query, not just a size change |
| m3: mv_popback step1 expected idx 2→1 | mv_popback | **1** | `step1 idx=2 expected=1` — monotone (no un-pop) pinned |
| m4: mv_unlatch step1 flags → true,true,true ("latch survives set_target" model) | mv_unlatch | **1** | `step1 flags … expected=true,true,true` — unlatch arm discriminates the wrong model |
| m5: mv_reanchor_lazy step1 path[0] → (1.5,0,0.5) ("anchor at assignment time" model) | mv_reanchor_lazy | **1** | `step1 path[0]=2.6,0,2.0 expected=1.5,0,0.5` — lazy materialization pinned |
| m6: mv_popskip expected idx 1→2 ("idx jumps to nearest" model) | mv_popskip | **1** | `step0 idx=1 expected=2` — sequential no-skip pinned |
| m7: mv_popstrict step0 expected idx 1→2 ("<= pops" model) | mv_popstrict | **1** | `step0 idx=1 expected=2` — strict-< at exact euclid==pdd under motion pinned |

Seven mutants, seven failing runs, every diagnostic naming the falsified
cell. Mutation coverage: adequate.

## Arm replay — exact markers byte-match CASES

    python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
      --runs corpus/live/r74-simplifier/runs \
      --only navagent3d_detour_mv_walk,mv_live,mv_popback,mv_popstrict,
            mv_void,mv_pmd_edge,mv_pmd_offmesh,mv_pmd2,mv_latch,mv_unlatch,
            mv_reanchor,mv_reanchor_same,mv_reanchor_bank,mv_reanchor_void,
            mv_popskip,mv_reanchor_lazy,mv_reanchor_force,mv_bridge_walk
    -> totals: cases=18 pass=18 fail=0
    receipt: runs/20261014T041834707273Z/verdicts.json

    prior-row spot replay (detour base + tp_ + pop + link families):
    -> totals: cases=9 pass=9 fail=0
    receipt: runs/20261014T041902175155Z/verdicts.json

## Weight item — the tuple-check chain is now THREE copies (extraction warranted)

r73 flagged `_run_link_arm`'s 20-line idx→next→final→dist→flags→path
elif-chain as a byte-identical second copy of `_run_pop_arm`'s, deferred
for byte-stability of the proven engine. r74 makes it three: the
pre-motion block in `_run_motion_arm` (fixture lines 1245–1264) is the
same chain modulo `st`→`st2` — verified by `diff` after identifier
normalization (receipts `pop_chain_r74.txt`, `link_chain_r74.txt`,
`motion_pre_chain.txt`; pop≡link diff empty, motion≡pop modulo rename).
The per-step block inside the same function is a fourth, prefixed
variant (`step%d` diagnostics + leading `pos` check, same ordering).

At three copies the chain is a second convention: the next arm family
will copy it again, and diag drift between copies would silently change
which wrong-models each family can name. A pure
`_check_tuple(observed: Dictionary, want: Dictionary) -> String`
returning the first diagnostic (plus a `prefix := ""` for the step
variant) collapses ~78 duplicated lines to ~25 and keeps one authority
for the observable-tuple predicate; every emitted string stays
byte-identical so all CASES markers and failure diagnostics are
preserved — the r73 byte-stability objection does not apply to a pure
extraction. **Recommended for a follow-up extraction; not demanded of
this landed diff**, whose additive copy is consistent and correct.

## Considered-and-rejected smaller expressions

- **Drop `mv_bridge_walk`** (its off-mesh-frozen cell overlaps
  `mv_void`): rejected — it alone advances idx through a LINK-type
  waypoint under live motion and pins reached/finished on the island
  path. Weakest marginal row but a distinct cell; keep.
- **Drop `mv_reanchor_force`** (superset of lazy's moves): rejected —
  it is the read-between contrast that makes "lazy" causal; without it
  lazy's post-teleport anchor cannot separate materialization-time from
  assignment-time anchoring.
- **Drop `mv_pmd_edge` step0** (sub-threshold frozen cell already in
  `mv_void`): rejected — it is the frozen half of the boundary bracket;
  the arm IS the bracket.
- **Drop `mv_live` step2** (identical tuple to `mv_popback` step1):
  rejected — the wait=0↔wait=5 intra-arm pair is what makes "call-time,
  no frame needed" falsifiable.
- **Fuse the bank pair (`_bank`/`_void`) into one arm** via a link flag:
  couples the reachable-clamp and unreachable-clamp fates into one red —
  same rejection as prior rounds' fused arms.

## Nits (cosmetic, non-blocking)

- `st2 = states[states.size() - 1]` (fixture line 264) is a dead store
  on the steps path — `_run_motion_arm` consumes `states`, not `st2`
  (grep-level: `st2` is consumed only at lines 309–310 by the link/pop
  dispatch). One line, harmless uniformity; no LSP server available to
  prove a semantic absence — recorded as grep evidence.
- The r73 nit persists in a new form: `st = _read_state(agent, actor)`
  still runs for link arms where it is unused — one wasted read per link
  arm. For `steps` arms the read is now load-bearing (pre-motion tuple),
  so the nit covers link arms only.
- `expected_pos`/`expected_target` generalization preserves prior
  semantics exactly (tp-only arms → tp pos + original target; no-move
  arms → spawn + target); verified in-context and by the 9/9 prior-row
  replay.
- r74 adds no unused consts, no dead vars, no stale names: `pmd`,
  `steps`, `set_target`, `wait`, `states` are all consumed; `spawn` key
  is reused as the step-loop position base — consistent naming.
- Arithmetic spot-checks all reproduce: pmd_edge 4.995/5.025 bracket,
  offmesh dist 9.924717, lazy dist 1.923539, latch dist 11.800424,
  bridge dist 4.627094 — match header/CASES values.

## Contract preserved

`call_deferred`/`_run` shape, 30-frame settle, exact-match flags,
`_argval` prefix parser with unknown-`--arm` fail-closed, `_fail`/
`_cleanup` teardown (link arms still free `owned_nodes`). The five
deletions are generalizations: `expected_pos`→steps-aware fold,
`target`→`expected_target` in the setup check, the header line replaced
by the r74 model block. `_run_steps` applies `set_target` before `tp`
inside a combined step — the ordering the lazy-anchor claim depends on —
and `wait` defaults to 5 with `0` reading live call-time, matching the
documented model. PASS grammar extended additively with
`steps=%d idxs=%s`; prior markers byte-stable (replay-verified).
`run_battery.py` diff is insertions-only; no prior tuple touched.
Gate-honesty read-back still runs for link-bearing steps arms
(`mv_reanchor_bank`, `mv_bridge_walk`).

## Evidence index

- Focused replays:
  `corpus/live/r74-simplifier/runs/20261014T041834707273Z/verdicts.json`
  (18/18 mv_* arms), `…/20261014T041902175155Z/verdicts.json` (9/9
  prior detour rows incl. tp_/pop/link families).
- Mutant sources/outputs: `corpus/live/r74-simplifier/mut/m{1-7}*.gd`,
  `m{1-7}*.{out,err}`; base copy `mut/base.gd` sha256 `336898f4…`.
- Chain-diff receipts: `pop_chain_r74.txt`, `link_chain_r74.txt`,
  `motion_pre_chain.txt` (pop≡link byte-identical; motion≡pop modulo
  `st`→`st2`).
- Corroborating probes present in this scratch from earlier seat work
  (`proj/{motion,order,latch_reset,pmd}_probe.gd`,
  `runs/probe/*.{out,err}`): pmd written-value tracking (pmd=4 re-query
  vs pmd=10 frozen at identical teleport), latched+pmd gate-off at
  tpx=10.6, same-value re-anchor, getter-order laziness — all consistent
  with the landed header model. Not independently re-derived here; my
  replay + mutants above carry the load-bearing evidence.

## Scope notes

- No full-battery (127 rows) or Node suite run — verifier/baseline
  scope. My replay covers all 18 new arms + a 9-row prior sample across
  every exercised engine path (tp, pop, link); the battery diff is
  insertions-only so prior-row drift risk is nil.
- Semantic verdicts are for this build/geometry/host: scripted teleports
  + target re-assignment (no self-propelled locomotion), single
  region+island+optional server link, corridorfunnel, cell_size 0.25,
  60 tps.
- Declared claim (a) falsified in part and honestly recorded; claims
  (b)/(c)/(d) confirmed as measured.
- Next deletion would remove a truth-table cell — the only slack is
  structural (the tripled tuple-check chain → one helper, ~53 lines
  reclaimable) and the 1-line `st2` dead store. Stopping.
