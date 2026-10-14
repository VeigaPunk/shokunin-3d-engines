# Game-dev-3d round 73 — simplifier report (minimal-design critique, report-only)

Seat: simplifier. Judged the landed r73 diff — off-mesh NavigationLink3D
traversal gating as tracked CASES arms on the detour fixture. Simplifier did
not author this round. All probes/mutants ran in own write scope
(`corpus/live/r73-simplifier/`); seeds untouched. Host devin,
`/usr/bin/godot` 4.7.2.stable.arch_linux.ed1daf0bf, physics 60 tps.

Landed diff at critique time (uncommitted working tree; fixture sha256
`0ae04750b2041ba17bfb1835c70c40ad182e116ab87069be7fec05b1e4835ce4`,
battery `9f18a711ff958abce08aad3b6db8e7f226c9a897beedc811023540cc61872860`):
`M corpus/fixtures/navagent3d_detour.gd` +337/−2 (both deletions are
semantic-preserving generalizations, see below), `M
corpus/fixtures/run_battery.py` +30/−0 = 15 CASES tuples, all exit-0 PASS
arms selected by `--arm=<name>`. Nothing else tracked touched.

## Independent ground truth (own probe, before reading the diff closely)

`corpus/live/r73-simplifier/proj/link_probe.gd` — same L-corridor + island
quad C x[2,3]z[5,6], server/node link modes, flag-parameterized
meta/pdd/layers/oneway/rev/disabled/enter/travel, one process per arm,
33 runs, all exit 0 (`runs/probe/*.out|err`, banner-only stderr).
Measurements on this build:

- **(a) metadata**: meta=7 shortcut → path `[S,ls,le,T]`,
  `types=0,1,0,0` (LINK=1 marks the hop's START index), link RID at index
  1 (region elsewhere), valid NavigationLink3D ObjectID at index 1 for
  node-authored link (server link → invalid ids); meta=0 → all three
  arrays EMPTY on the identical path (opaque). Per-bit gating: meta=1 →
  types only, 2 → rids only, 4 → owners only.
- **(b) gates**: `ll=2/al=1` → corridor `[S,(2,0,1),T]`; `al=3` (bits 1|2)
  → link restored (bitmask, not equality); `--oneway --rev` → corridor;
  `--disabled` → corridor. On bridge each drop → unreachable, final
  clamps (2.5,0,4.0), types all-region under meta=7.
- **(c) costs**: `enter=10` AND `enter=100` → link still chosen (INERT,
  anomaly reproduced); `travel=10` → corridor (LIVE); `travel=0.1` →
  link. Link route chosen at default costs despite longer path sum
  (4.192582 > 4.130649) — route cost ≠ funnel path sum, as r72 reported.
- **(d) pop-through**: bridge pdd=2.0 → idx=2 next=(2.5,0,3.5) near
  endpoint; pdd=3.605551 (≈euclid S→linkstart, strict-edge) → idx=2;
  pdd=3.6056/4.03/5.0 → idx=3 saturated, next=(2.5,0,5.5) across the
  void — still `reachable=true finished=false`. Pop edge is the same
  strict-`<` Euclidean gate as r72's region waypoints; link endpoints get
  no special protection.

## Verdict

**Adequate discrimination everywhere; 14/15 arms load-bearing, one
borderline (`link_meta`); zero missing arms against the declared claims;
one weight item (verbatim-duplicated tuple-check chain) flagged, not
demanded.** Every one of the 15 arms executes, passes, and byte-matches
its CASES marker on replay (15/15 focused battery + 10/10 prior detour
rows through the generalized mesh path). Eight scratch mutants all
rejected on measured diagnostics — including a no-op link setter killed
by the new gate-honesty read-back.

## The discrimination lattice and per-arm marginal value

Claim (a) — metadata (5 rows):

| cell / mutant killed | pinning arms | marginal note |
|---|---|---|
| link authored + in path, all arrays EMPTY at meta=0 (opaque plain path) | `link_shortcut` (server, meta=0) | load-bearing — the "enabling" causal half + server-authoring control |
| bit 1 → types only (`0,1,0,0`) | `link_meta_types` | load-bearing |
| bit 2 → rids only (link RID@1, region elsewhere) | `link_meta_rids` | load-bearing |
| bit 4 → owners only + node-authoring route (valid ObjectID@1) | `link_meta_owners` | load-bearing |
| bits jointly → union of all three | `link_meta` (meta=7, node) | **borderline** — kills only a "bits interfere" model; every asserted element already pinned per-bit. The claim's headline arm, but the weakest marginal row — deletion candidate #1, not demanded |

Claim (b) — traversal gates (5 rows):

| cell / mutant killed | pinning arms | marginal note |
|---|---|---|
| layers bitmask-mismatch drops link → corridor, types all-region | `link_layers_off` (ll=2, al=1) | load-bearing |
| bitmask MATCH restores link despite unequal layer ids | `link_layers_on` (ll=2, al=3) | load-bearing — kills "layers must be equal" wrong model the off-arm cannot separate |
| oneway traversed forward → reachable, LINK type@2 | `link_oneway_fwd` (bridge) | load-bearing — control attributing rev's drop to direction, not flag brokenness |
| oneway approached from exit side → unreachable clamp | `link_oneway_rev` | load-bearing |
| enabled=false → unreachable clamp | `link_disabled` | load-bearing |

Claim (c) — cost asymmetry (2 rows): `link_travelcost` (10 → corridor)
live vs `link_entercost` (100 → link still chosen) inert — exactly the
declared pinned pair, no third cost arm. Load-bearing, minimal-perfect.

Claim (d) — pop-through (3 rows): `link_gap` (no link → unreachable
clamp; the void premise and shared control for all gated-unreachable
arms), `link_pop_bank` (pdd=2.0 → idx=2, next=near endpoint — kills
"any pdd pops through"/"pdd ignored on links"), `link_pop_void` (pdd=4.0
→ idx=3, next=(2.5,0,5.5) across the void). All three load-bearing —
the pair brackets the strict euclid edge at 3.605551.

Every gate arm doubles as a metadata-consistency pin: gated paths assert
`types` all-region under meta=1, so the dropped-link annotation is
checked, not just the path. The meta=0↔meta=7 shortcut pair implicitly
pins metadata-inertness (identical path tuple) without a dedicated arm.

## Missing-arm check — none against the declared claims

All three declared gates pinned with positive controls; both cost knobs
pinned as the asymmetry pair; all three companion arrays asserted AND
checked (`types` exact, `nrids`+`rid_at`+region-elsewhere, `nowners`+
`own_at`+`own_class`); pop-through pinned with premise and threshold
control. One documented-but-unpinned detail: the header comment claims
"server links give invalid 0s" for owner_ids — `link_meta_owners` is
node-authored, so server-invalid-owner is asserted nowhere. A finer
unclaimed detail, not a declared claim — a `meta=4` server arm asserting
`nowners=4` + no valid instance would pin it; optional, not demanded.

## Mutation coverage — demonstrated (private scratch mutants, real exits)

Copy `proj/detour_base.gd` (sha256 `0ae04750…`, byte-identical to the
landed fixture); each mutant flips one setup constant or expectation:

| mutant | arm | exit | measured diagnostic |
|---|---|---|---|
| m1: meta_types bit 1→2 | link_meta_types | **1** | `ntypes=0 expected=4 types=[]` — bit-independence is real (bit 2 yields rids, not types) |
| m2: layers_off linklayers 2→1 (gate no-op) | link_layers_off | **1** | `next=1.500000,0.000000,0.500000 expected=2.000000,…` — arm fails when gate doesn't take effect |
| m3: oneway_rev drops `rev` | link_oneway_rev | **1** | `final=2.500000,0.000000,5.500000 expected=2.500000,0.000000,4.000000` — direction pin discriminates |
| m4: entercost expectation → corridor | link_entercost | **1** | `npath=4 expected=3` — assert layer bites, not literal-echo |
| m5: pop_void pdd 4.0→3.0 (< euclid 3.6056) | link_pop_void | **1** | `idx=2 expected=3` — pop-through is genuinely pdd-gated |
| m6: disabled flag removed | link_disabled | **1** | `final=…5.500000 expected=…4.000000` — enabled-link control bites |
| m7: `link_set_navigation_layers` neutered to `pass` | link_layers_off | **1** | `authored link flags not in effect` — the gate-honesty read-back block kills no-op setters |
| m8: shortcut meta 0→1 | link_shortcut | **1** | `ntypes=4 expected=0 types=[0, 1, 0, 0]` — meta=0 opaqueness genuinely pinned |

Eight mutants, eight failing runs, zero literal-only rejections.
Mutation coverage: adequate.

## Arm replay — exact markers byte-match CASES

    python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
      --runs <abs r73-simplifier>/runs --only <all 15 new link arms>
    -> totals: cases=15 pass=15 fail=0
    receipt: runs/20261014T015805020889Z/verdicts.json, seeds_unchanged
    prior detour replay (10 rows incl. --straight + --assert-pathsum
    negatives through the generalized verts/want_polys path):
    -> totals: cases=10 pass=10 fail=0
    receipt: runs/20261014T015855491812Z/verdicts.json

## Weight item — duplicated assert chain (flagged, not demanded)

`_run_link_arm` (lines 736–757) reproduces `_run_pop_arm`'s
idx→next→final→dist→flags→path elif-chain **byte-identical** (verified
by `diff` of both blocks): the tuple-check logic now lives in two
places. A shared `_check_tuple(st2, cfg) -> String` helper used by both
engines removes ~22 duplicated lines and keeps one authority for the
observable-tuple predicate. Not demanded here: the additive copy keeps
the proven r72 engine untouchable (byte-stability of 22 prior arms),
and the link arm legitimately skips the teleport-block. Candidate for a
follow-up extraction when the assert surface next changes; recorded as
the round's principal "second copy" observation.

## Considered-and-rejected smaller expressions

- **Drop the three per-bit meta arms, keep only `link_meta`**: would
  save 3 rows but lose bit→array exclusivity (a "meta=1 enables all
  arrays" bug would pass). Rejected — the per-bit set is the
  discriminator; `link_meta` is the redundant direction.
- **One combined `meta=7` arm + drop `link_shortcut`**: loses the
  meta=0 opaqueness pin that makes "enabling the flag" causal.
  Rejected.
- **Fuse the gate arms onto existing pop arms** (e.g., disabled+pdd in
  one row): couples independent fates into one red — same rejection as
  r71/r72 sweep arms.
- **Shortcut-geometry duplicates of the bridge gates** (disabled/
  oneway_rev on corridor instead of island): same killed model as the
  bridge versions minus the unreachable consequence; correctly absent.

## Nits (cosmetic, non-blocking)

- `st = _read_state(agent, actor)` still executes for link arms though
  `_run_link_arm` receives only `st2` (no tp arms this round) — one
  wasted state read per link arm, harmless.
- The unused `euclid` local and `DETOUR_EUCLID` const remain — both
  pre-existing (r72/r70), **not recurred**: r73 adds no unused consts,
  no dead vars, no stale names (`owned_nodes`, `want_polys`,
  `eff_link`, `own_class` all live).
- Comment budget consistent with file convention: ~25-line r73 header
  model block + ~4–7 comment lines per arm section ≈ 15 lines/arm
  all-in vs r72's ~13 — measured-rationale density, not oversized.
- `link_layers_off`/`link_travelcost`/`link_entercost` run shortcut
  while `link_oneway_*`/`link_disabled`/`link_pop_*` run bridge —
  geometry split is deliberate (fallback-path vs unreachable-clamp
  consequences both pinned), not accidental asymmetry.

## Contract preserved

`call_deferred`/`_run` shape, 30-frame settle, exact-match flags,
`_argval` prefix parser with unknown-`--arm` fail-closed, `_fail`/
`_cleanup` teardown extended correctly to `owned_nodes` (node links
freed, no ObjectDB leak — battery would flag one). The two deletions
are generalizations required by the island quad: `mesh.vertices` now
built via a `verts` local (property getter returns a copy — append
would not write through; comment documents this), and the
polygon-count pin generalized to `want_polys`. New gate-honesty block
reads back every authored link flag through server getters before the
arm runs — a no-op setter fails closed (`authored link flags not in
effect`, proven by m7). PASS marker grammar extended additively with
` link=%s meta=%d types=%s ridat=%d own=%s`; prior markers byte-stable
(replay-verified). `run_battery.py` diff is insertions-only; no prior
tuple touched.

## Evidence index

- Independent probe + 33 receipts:
  `corpus/live/r73-simplifier/proj/link_probe.gd`,
  `runs/probe/*.out|.err` (meta bits, gates, costs, pdd edge brackets
  3.605551 vs 3.6056).
- Mutant sources/outputs/exits: `mut/m{1-8}*.{gd,out,err}`; fixture
  copy `proj/detour_base.gd` sha256 `0ae04750…`.
- Replay receipts:
  `corpus/live/r73-simplifier/runs/20261014T015805020889Z/verdicts.json`
  (15/15 link arms), `…/20261014T015855491812Z/verdicts.json` (10/10
  prior detour rows).

## Scope notes

- No full-battery (127 rows) or Node suite run — verifier/baseline
  scope. My replay covers the entire detour family (32 rows: 15 new +
  17 prior sampled incl. all path shapes); the battery diff is
  insertions-only so prior-row drift risk is nil.
- Semantic verdicts are for this build/geometry/host: stationary
  agent, single region+island, corridorfunnel, cell_size 0.25, 60 tps.
- Next deletion would remove a truth-table cell — the only slack is
  `link_meta` (union-consistency cell, borderline). Stopping.
