# Game-dev-3d round 73 — scribe report (seat: scribe, host: devin)

Declared lane axis-move (from dispatch): formalize off-mesh
`NavigationLink3D` traversal gating as tracked CASES arms on the existing
detour fixture — (a) `path_metadata_flags` surfaces LINK-typed points in
the companion arrays where the plain path array is opaque; (b) traversal
gates (`navigation_layers` bitmask mismatch, `bidirectional=false`
approached from the exit side, `enabled=false`) each drop the link from
the computed path, each independently falsifiable; (c) re-test the
r72-boundary anomaly — `enter_cost` inert vs `travel_cost` live — as a
pinned arm pair; (d) pop-through hazard — large pdd pops the link's near
endpoint and `next` points across the void to the far endpoint. Prior
surface byte-stable: 112 CASES rows, 4 probes, Node 31/31. Scribe duty:
independent derivation of the four claims in own scratch + the lesson
draft (`corpus/lessons/` convention); report-only, not the judge.

Canonical repo `~/Projects/shokunin/game-dev-3d-shokunin`, reached via
worktree symlink `~/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d`.
Engine `/usr/bin/godot` = `4.7.2.stable.arch_linux.ed1daf0bf` (same build
as r69–r72), Python 3.14.7, 30-frame settle, single process per arm.

## Measured evidence (scribe-observed, own scratch)

Own probe `corpus/live/r73-scribe/scratch/link_gate_check.gd` sha256
`59c10df589a631c9d1608ff0c1d1ed092ebe3f3e81cc85f27bfdd7fb0ad2afe3` —
authored fresh for this seat (no copying): own geometry, own flag names,
own `SPROBE` output format. `project.godot` byte-identical to
`corpus/fixtures/project.godot` (sha256 `1fda90d4…8eac23`).

**Own geometry** (differs from every sibling): pad A `x[0,2]z[0,1]`,
island B `x[0,2]z[3,4]`, void `z(1,3)`; `--walk` adds a foot strip
`x[2,3]` (R1 `z[0,1]`, R2a `z[1,3]`, R2b `z[3,4]`, exact shared edges)
giving B a 5-poly region route. Agent `S=(0.5,0,0.5)` → `T=(1.5,0,3.5)`
on B; link `LS=(1,0,0.5)`→`LE=(1,0,3.5)` (3.0-unit hop, both endpoints
interior). Without `--walk` the link is the ONLY route (binary
reachable-flip); with `--walk` a dropped link degrades to the region
route (path-shape observable) — each gate measured on both surfaces.

Command per arm (cwd `corpus/live/r73-scribe/`):

    timeout 60 /usr/bin/godot --headless --path scratch \
      --script res://link_gate_check.gd -- <flags>

32 probe runs (17 `iso_*` + 15 `w_*`, one a determinism repeat), all
exit 0, all stderr empty; `iso_node_meta7` vs `iso_node_meta7_b`
byte-identical. Receipts
`corpus/live/r73-scribe/runs/<arm>.{stdout.txt,stderr.txt,exit}`.

### (a) Companion arrays — CONVERGE (opaque at meta=0; LINK at hop-start index)

| arm | meta | types | rids | owners | reading |
|---|---|---|---|---|---|
| iso_node_meta0 | 0 | `[]` | 0 | 0 | link path `[S,LS,LE,T]` fully returned yet all three arrays **empty** — the plain point array is opaque, enabling the flag is causal |
| iso_node_meta1 | 1 | `[0,1,0,0]` | 0 | 0 | `PATH_SEGMENT_TYPE_LINK`(=1) at **idx 1 = hop START** (segment `path[1]→path[2]`); far endpoint REGION |
| iso_node_meta2 | 2 | `[]` | 4 (3 region + link @1) | 0 | rids-only gating |
| iso_node_meta4 | 4 | `[]` | 0 | 4 (`NavigationLink3D` @1) | node-authored owner ObjectID valid at hop-start index only |
| iso_node_meta7 | 7 | `[0,1,0,0]` | 4 | 4 | union; `owners=[0,NavigationLink3D,0,0]` |
| iso_srv_meta7 | 7 | `[0,1,0,0]` | 4 | 4 × invalid `0` | server-authored link: RID surfaces, ObjectID does not |

Metadata is descriptive: identical `path`/`idx`/`next`/`dist` at meta=0
vs meta=7 (byte-equal tuples). `get_current_navigation_path()` returns
the same 4 points either way — link-ness lives only in the result
object's companion arrays (`agent.get_current_navigation_result()`).
Note (scout-measured, corroborated): the agent property's engine default
is `PATH_METADATA_INCLUDE_ALL` (=7) on this build — an "opaque" arm must
set `meta=0` explicitly.

### (b) Traversal gates — CONVERGE (each gate reproduces the exact no-link tuple)

Island surface (sole-route): every closed gate yields a tuple
byte-identical to `iso_nolink` — `path=[S,(1.5,0,1)]` npath=2,
`pathlen=1.118034`, `final=(1.5,0,1)`, `eufin=2.5`, `reachable=false`,
`types=[0,0]` all-region:

| arm | config | result |
|---|---|---|
| iso_lay_mm | link `navigation_layers=2`, agent `=1` | **dropped** — identical unreachable tuple |
| iso_lay_ok | link `=2`, agent `=3` (bits 1\|2) | link used — **bitmask AND, not equality** |
| iso_one_fwd | `bidirectional=false`, start on A | traversable, reachable=true |
| iso_one_rev | `bidirectional=false`, start on B (agent approaches the exit side) | **dropped** — identical unreachable tuple |
| iso_dis | `enabled=false` | **dropped** — identical unreachable tuple |

Walk surface (`--walk`, fallback exists): `w_lay_mm`, `w_one_rev`,
`w_dis` each produce the identical 5-point region route
`[S,(2,0,0),(2,0,1),(2,0,3),T]`, `pathlen=5.288246`, `reachable=true`,
`types` all-REGION — the gate drops the link **from the computed path**
while connectivity remains, byte-identical to `w_nolink`. `w_one_fwd`
still traverses the link (pathlen 4.0). Both consequence surfaces pinned.

### (c) enter_cost inert vs travel_cost live — CONVERGE (anomaly reproduces on independent geometry)

Link route (pathlen 4.000000) beats the walk route (5.288246) at default
costs → `w_link` uses the link.

| arm | config | measured route |
|---|---|---|
| w_tcost_1.05 / 1.1 / 1.2 | `travel_cost` up to 1.2 | link still chosen |
| w_tcost_1.3 / 1.4 / 1.5 / 20 | `travel_cost` ≥1.3 | **walk route** — travel_cost is live; crossover ∈ (1.2, 1.3] |
| w_ecost20 | `enter_cost=20` | link still chosen — identical tuple |
| w_ecost100 | `enter_cost=100` | link still chosen — a 100 surcharge ≫ the 1.29 route margin, still cannot displace the link |

Naive length-linear pricing predicts crossover at tcost≈1.43
(`1.0 + 3·t = 5.288`); the measured crossover (1.2,1.3] sits lower —
consistent with the r72/r73 caveat that engine route cost is a
polygon-hop approximation, not the post-funnel path sum. `enter_cost`
inertness reproduces exactly; r73-boundary hardened it to structural
inertness (1e6, sole-route, chained, negatives clamped to 0 — their
receipts).

### (d) Pop-through hazard — CONVERGE, sharper edge on this geometry

`euclid(S→LS)=0.5`, so the hazard fires below the engine default
`pdd=1.0`:

| arm | pdd | idx | next | reading |
|---|---|---|---|---|
| iso_pop_hold | 0.40 | 1 | `(1,0,0.5)` LS | near endpoint stands |
| iso_pop_eq | **0.50** | 1 | `(1,0,0.5)` LS | exact float equality does NOT pop — **strict `<`**, same rule as r72 region waypoints |
| iso_pop_over | 0.51 | 2 | `(1,0,3.5)` LE | **next points across the 2-unit void** to the far endpoint |
| (any default arm) | 1.00 | 2 | `(1,0,3.5)` LE | default pdd already aims across the void on this geometry |
| iso_pop_sat | 4.00 | 3 | `(1.5,0,3.5)` T | saturates at `size−1` past the far endpoint too |

Link endpoints are ordinary waypoints to the sequential strict-`<`
Euclidean pop loop (r72 model): no link-specific protection anywhere in
the chain. `reachable=true`/`finished=false` throughout — the same gate
semantics, the hazard is `next`'s referent.

## Author-fixture verbatim replay (field check, uncommitted working tree)

Working tree at snapshot sha256 `0ae04750…` for
`corpus/fixtures/navagent3d_detour.gd` (+337/−2 vs `ea722a75…`; the
`verts`-local island build) and `9f18a711…` for `run_battery.py`
(+30/−0, insertions-only — 15 `navagent3d_detour_link_*` CASES rows). Both
copied into `corpus/live/r73-scribe/scratch/` (`navagent3d_detour_wt.gd`,
`run_battery_wt.py`) and replayed:

    timeout 60 /usr/bin/godot --headless --path scratch \
      --script res://navagent3d_detour_wt.gd -- --arm=<name>

- **All 15 new link arms: exit 0 + CASES-pinned marker byte-exact in
  stdout** (programmatic compare against `run_battery_wt.py` literals —
  `runs/wt_link_*.stdout.txt`). Values reproduce the author's claims:
  shortcut `[S,(1.5,0,0.5),(2.5,0,3.0),T]` pathlen 4.192582;
  `link_layers_off` corridor `types=0,0,0`; `link_layers_on` restores;
  `link_oneway_fwd` reachable `final=(2.5,0,5.5)` types `0,0,1,0`;
  `link_oneway_rev`/`link_disabled`/`link_gap` unreachable clamp
  `final=(2.5,0,4.0)`; `link_travelcost` corridor; `link_entercost`
  link still chosen at 100; `link_pop_bank` idx=2 next=near endpoint;
  `link_pop_void` idx=3 `next=(2.5,0,5.5)` across the void.
- **Prior arms on the modified fixture**: all 22 r72 `--arm=` rows exit
  0 (`runs/snapshot-ee40c45e/wt_prior_*` + `runs/wt2_prior_*`), plus
  base/`--post-*` exit 0 and `--straight`/`--assert-pathsum` exit 2
  (expected negatives). Six arms additionally checked **byte-exact**
  against CASES literals (`pop_lo`, `vert_pop_eq`, `tp_mid`, `edge_eq`,
  `fin_idx_gate`, `fin_wall` — all true).

**Snapshot-honesty note (verbatim):** this seat raced the author's
in-flight writes twice. First copy sha `e36aa388…` was torn mid-append
(`_run_link_arm` referenced but not yet defined → parse error, receipt
`runs/torn-snapshot-e36aa388/wt_pop_lo.*`). Second copy sha `ee40c45e…`
parsed and ran but the three island arms (`link_oneway_fwd`,
`link_pop_bank`, `link_pop_void`) exited 1 inside `_run_link_arm` with
`final=…4.0 expected=…5.5` etc. after the engine reported `Corrupted
navigation mesh … indices of a polygon are out of range` — the
`mesh.vertices.append_array` post-assignment write-through failure. The
author found and fixed the same defect independently (`verts` local,
comment "the property getter hands back an array append_array does not
write through", their report lines ~126/~204). I pinned the mechanism in
own scratch (`scratch/append_array_wt.gd` → `WRITETHRU before=2
after_property_append=2 after_local_append=2 after_assign=3`: appending
through the property getter does NOT write back; assignment required —
`runs/mech_writethru.*`). Final replay on stable `0ae04750` is green
15/15. The episode is corroboration, not a residual defect: the landed
fixture builds verts complete before assignment.

## Wave state at observation time

- All eight seat reports exist in `reports/round-73/`; the work commit
  **`b41fb33`** (`game-dev-3d r73: off-mesh link traversal gating — 15
  tracked arms, all four claims confirmed`) landed during this report's
  drafting and carries the two fixture diffs plus seven sibling reports.
  Committed blobs byte-identical to my replayed snapshot (`0ae04750…` /
  `9f18a711…`). Verifier/adjudicator + LOG/SCORECARD/lesson landing
  pending.
- Tracked writes (author only): `M corpus/fixtures/navagent3d_detour.gd`
  (`ea722a75…` → `0ae04750…`, +337/−2), `M
  corpus/fixtures/run_battery.py` (`4e9ead37…` → `9f18a711…`, +30/−0
  insertions-only — zero prior CASES tuples touched); committed as
  `b41fb33` before this report closed.
- Critic (`r73-critic.md`): three-attack audit; battery replay
  `corpus/live/r73-critic/battery-runs/20261014T015632521492Z/` — prior
  rows byte-stable, all 15 `link_*` arms pass; records one claim-wording
  falsification verbatim (see Convergence).
- Author full battery receipt
  `corpus/live/r73-author/runs/20261014T015541463862Z/verdicts.json`:
  **127/127 PASS** (82 ordinary / 45 negative_controls = 112 prior + 15
  new link rows), `seeds_unchanged=true`, 4/4 probes
  (`crash`/`stream`/`tree` ok; mutation `detected=true`), godot
  `4.7.2.stable.arch_linux.ed1daf0bf`. Prior-row claim: 0 mismatches over
  112 cases vs the r72-author receipt. Node receipts
  `corpus/live/r73-author/runs/node/run_*.json` — six suites PASS,
  `seeds_unchanged=true` (31/31). An earlier focused receipt
  (`…015242466681Z`, 36/42 FAIL) records the mid-iteration island bug
  before the fix.
- Baseline: frozen `3f6a03d` replay **112/112 + 4 probes + Node 31/31**,
  0-mismatch vs r72-verifier receipt
  (`corpus/live/r73-baseline/runs/20261014T013403245240Z/`). Link surface
  greenfield in the before-state (`grep -iE 'navigationlink|…'` = 0 hits).
- Reviewer: r72 committed state re-executed clean (112/112, byte-exact
  spot arms, five model clauses hold); re-pins the relative-`--runs`
  tree-timeout trap as documented-in-ledger but absent from
  `run_battery.py` docstring / `corpus/fixtures/README.md` /
  `corpus/lessons/*` — flagged again for a future doc line.
- Scout: API surface verified on this binary (metadata flags live on the
  agent property; enum constants on `NavigationPathQueryParameters3D`;
  segment enum on `NavigationPathQueryResult3D`; default meta=7) + 20-arm
  re-execution of r72 boundary receipts byte-identical; pop bracket
  3.605/3.606.
- Boundary: 49-run edge survey (chains, `link_connection_radius` strict
  `<` + endpoint projection, same-polygon links ignored, mid-void latch,
  retarget re-anchor at nearest bank, backward traversal, `enter_cost`
  clamps negatives and is inert to 1e6).
- Simplifier: 14/15 arms load-bearing, `link_meta` borderline
  (union-consistency cell); 8/8 scratch mutants killed incl. a no-op
  `link_set_navigation_layers` caught by the author's gate-honesty
  read-back; one weight item (`_run_link_arm` duplicates `_run_pop_arm`'s
  tuple chain — flagged not demanded); missing-arm check clean except an
  optional `meta=4` server-invalid-owner pin.

## Convergence — verbatim for the judge

All four declared claims CONFIRMED by author + independently by this
scribe on different geometry (and by scout/simplifier/boundary on theirs):

1. **(a)** Companion arrays gate per-bit; meta=0 leaves all three empty
   on a live link path (opaque); `LINK=1` marks the hop-start index;
   node-authored `owner_ids` resolve to `NavigationLink3D`, server links
   give 0s. Convergent everywhere.
2. **(b)** All three gates drop the link independently — reproduced on
   two consequence surfaces (corridor-fallback on author's geometry;
   unreachable-clamp on island; region-route fallback on my `--walk`).
   Layers gate is bitmask-AND; one-way is direction-selective
   (forward traversable, exit-side approach dropped); disabled ≡ absent.
3. **(c)** `travel_cost` live (corridor/walk chosen when priced out),
   `enter_cost` inert at every magnitude probed ({10,100,1e6,−1e6}
   across seats; {20,100} on my geometry with a 1.29-unit margin). The
   anomaly is pinned as TRUE behavior, not explained; boundary adds the
   negative-clamp readback (`enter_cost` stores `max(0,v)`).
4. **(d)** Pop-through real: strict-`<` Euclidean pop treats link
   endpoints as ordinary waypoints; above `euclid(agent→linkstart)` the
   agent's `next` is the far endpoint across the void (my geometry fires
   at pdd>0.5 — below engine default 1.0). `reachable=true,
   finished=false` throughout.

**No conflicts on measured semantics.** One verbatim wording
falsification to carry for the judge: the critic notes the dispatch's
claim-(a) phrasing "**enabling** path_metadata_flags" is inverted on this
build — the property defaults to 7 (`PATH_METADATA_INCLUDE_ALL`), so the
flag is opt-OUT and meta=0 is what must be authored to demonstrate
opaqueness. The substance converges (arrays gate per-bit as claimed);
only the "enabling" framing needed the critic's correction — all seats'
meta=0 arms confirm the empty-array behavior. Reported-not-explained
items carried verbatim: engine route-cost is not the funnel path-sum
(link route chosen over a shorter corridor; my crossover (1.2,1.3] vs
naive 1.43 — the author commit message cites ~1.12 on their geometry,
same direction), and `enter_cost`'s inertness is structural on this
build.

## Retained UNKNOWNs (do not claim)

- Route-cost internals (polygon-hop approximation) and the exact
  `travel_cost` pricing law — crossover bracketed, law unpinned.
- `enter_cost`: any engine configuration where it weighs in — none found
  on this build; upstream intent unknown.
- Server-link `owners[i]` via `link_set_owner_id` (API exists; battery
  pins node-authored only — simplifier's optional gap).
- `link_connection_radius` snap semantics, chained links, same-polygon
  links, mid-hop latch/retarget re-anchor, backward traversal — measured
  by r73-boundary, NOT pinned by tracked CASES rows (recon, not battery).
- Signal cadence (`link_reached`/`waypoint_reached` payloads),
  edgecentered postproc over link segments, locomotion through links
  (boundary's follower is transform-driven; no collider body),
  `path_max_distance` repath across links, vertical hops, multi-map,
  runtime endpoint mutation.
- Scope: one build (`4.7.2.stable.arch_linux.ed1daf0bf`), one host,
  single region + island/strip, cell_size 0.25, corridorfunnel default,
  30-frame settle. r68/r69 `navagent3d_retarget` intermittence caveat
  stands unretracted (did not manifest in these runs).

## Draft: lesson entry — `corpus/lessons/r73-navagent-link-gating-review.md`

(Proposal; admission pending named non-author replay + parent verdict.
Modeled on `r72-navagent-pdd-finish-review.md` convention. Commit-sha
slots left pending — the diff is uncommitted at observation time.)

```markdown
# R73 — NavigationAgent3D off-mesh NavigationLink3D traversal gating (Godot 4.7.2)

## Decision and evidence

A `NavigationLink3D` (or `NavigationServer3D.link_create`) joins the
agent's path query after the normal physics settle (`link_get_iteration_id
≥1`); its endpoints become ordinary path waypoints. The hop is invisible
in `get_current_navigation_path()` — the same point array appears at
`path_metadata_flags=0` with all three companion arrays **empty**
(opaque). With flags on `agent.get_current_navigation_result()`:
`path_types` marks `PATH_SEGMENT_TYPE_LINK`(=1) at the waypoint index
where the hop **starts** (segment `path[i]→path[i+1]`, far endpoint stays
REGION); `path_rids[i]` carries the link RID there (region RID
elsewhere); `path_owner_ids[i]` resolves to the authoring
`NavigationLink3D` only for node-authored links (server links → invalid
0s unless `link_set_owner_id` is used — unpinned). Bits 1/2/4 populate
independently; metadata changes NO path output (byte-identical tuples at
meta=0 vs meta=7). Agent default on this build: `meta=7` — an "opaque"
pin must set 0 explicitly.

Traversal gates, each independently falsifiable, each independently
verified to drop the link (byte-identical to the no-link control on
sole-route geometry; identical region-route fallback where a walk route
exists):

| gate | mechanism | observable where |
|---|---|---|
| `navigation_layers` | bitmask AND vs `agent.navigation_layers` (link=2 vs agent=1 drops; agent=3 restores — not equality) | shortcut geometry → corridor fallback (path/types/next, `reachable` stays true); island geometry → `reachable=false` + clamped `final` |
| `bidirectional=false` | direction-selective — traversable start→end, dropped when approached from the exit side (start/end swapped) | same dual surface |
| `enabled=false` | link ignored entirely — identical tuple to authoring no link | same dual surface |
| `travel_cost` | reprices the hop in route selection (tcost=10 → corridor on the fixture; crossover bracketed ∈(1.2,1.3] on scribe's strip geometry) | pathlen/types route flip |
| `enter_cost` | **structurally inert on this build** — {10,100,1e6,−1e6→clamped 0} all leave the link chosen; `link_get_enter_cost` stores `max(0,v)` | NOT observable in routing anywhere — dead state, pinned as TRUE |
| `path_desired_distance` | pop-through: endpoints are ordinary waypoints to the strict-`<` Euclidean pop loop; pdd ≥ euclid(agent→near endpoint) pops it and `next` returns the FAR endpoint across the void | `idx`/`next`; saturates at `size−1` |

The `enter_cost` anomaly — the r72 recon's "inert" note — hardened to a
pinned pair: `link_entercost` (100 → link still chosen) vs
`link_travelcost` (10 → corridor). A future build that applies
enter_cost flips `link_entercost` to the corridor tuple and fails the row
honestly — the falsification path is built into the arm.

Pop-through mechanics vs the r72 pop rule: identical gate —
`while idx<size−1 and euclid(agent, path[idx]) < pdd: idx++` — strict `<`
(exact equality does not pop: scribe `pdd=0.5` at `euclid=0.5` holds the
near endpoint; author's `link_pop_bank`/`link_pop_void` bracket
3.605551→idx2 / 4.0→idx3). No link awareness anywhere in the chain:
`next` jumps near endpoint → far endpoint in one index step, and the
r72 reachable-mode finish semantics are unchanged (`reachable=true,
finished=false` throughout).

Fixture: `navagent3d_detour.gd` gains 15 `--arm=` presets — opt-in
`island`/`link`/`link_a`/`link_b`/`linklayers`/`agentlayers`/`oneway`/
`rev`/`disabled`/`entercost`/`travelcost`/`meta` keys; `_run_link_arm`
pins the full observable tuple plus `types` exact-match, `rid_at`
(link-RID index, region elsewhere), `own_at`/`own_class` (live-instance
check), and a gate-honesty read-back block (`link_get_*` of every
authored flag — a no-op setter fails closed). Battery **127/127**
(112 prior + 15 new), `seeds_unchanged=true`, 4/4 probes, Node 31/31,
prior 112 rows 0-mismatch vs the r72 receipt. Authoring caveat measured
this round: `mesh.vertices.append_array` after property assignment does
not write through (COW detaches) — build the vertex array complete in a
local, then assign; a post-assignment append yields `Corrupted
navigation mesh … indices out of range`.

Receipts: `corpus/live/r73-author/runs/20261014T015541463862Z/`
(127/127 full battery + probes), `…/20261014T015454762559Z/` (42/42
focused), `corpus/live/r73-baseline/runs/20261014T013403245240Z/` (frozen
112/112), `corpus/live/r73-scribe/runs/` (32-arm independent two-geometry
probe + 15-arm verbatim replay + write-through mechanism pin),
`corpus/live/r73-scout/runs/` (API verify + 20-arm reproduction),
`corpus/live/r73-boundary/runs/` (49-arm edge survey),
`corpus/live/r73-simplifier/runs/` (15/15 link replay + 8 mutants);
seat reports `reports/round-73/r73-*.md`; pending `r73-verifier` +
adjudication. Work commit: `b41fb33`; adjudication-commit slot:
[pending].

Recheck conditions: any engine rebuild re-runs the battery (link gates
are server internals); an upstream change making `enter_cost` live flips
`link_entercost` honestly; changes to `link_connection_radius` default,
postprocessing defaults, or map config warrant re-measurement; the
unpinned boundary surfaces (chains, connection-radius projection,
mid-hop signals/latch, retarget re-anchor, backward traversal) are
candidates for a future round's arms.

## Not established

Route-cost internals (polygon-hop approximation — link route chosen over
a shorter corridor at default costs; `travel_cost` crossover bracketed
(1.2,1.3] on strip geometry, law unpinned); any configuration where
`enter_cost` weighs in; `link_set_owner_id` surfacing for server links;
`link_connection_radius` snap semantics and off-mesh endpoint projection
(measured by boundary, not pinned by CASES); chained/same-polygon link
behavior in the battery; `link_reached`/`waypoint_reached` signal
payloads and cadence; edgecentered postproc across link segments;
collision-body locomotion through links; `path_max_distance` repath;
vertical hops; multi-map links; runtime endpoint mutation; other engine
builds, baked regions, avoidance, rendering.
```

## Draft: LOG.md round-73 entry

    ## Round 73 — devin host — depth: NavigationLink3D traversal gating + companion arrays

    - Declared (dispatch brief): pin (a) path_metadata_flags LINK-typed
      companion waypoints vs the opaque plain path; (b) three traversal
      gates (layers bitmask, bidirectional exit-side, enabled=false) each
      dropping the link; (c) enter_cost-inert vs travel_cost-live as a
      pinned pair; (d) pop-through hazard. Prior 112 rows byte-stable.
    - Wave: devin leaf set reports/round-73/r73-{baseline,scout,boundary,
      reviewer,author,critic,simplifier,scribe}.md [verifier/adjudicator
      pending]. Sole tracked writer = author; committed b41fb33 —
      navagent3d_detour.gd +337/−2 (15 --arm presets) + run_battery.py
      +30/−0 (insertions-only).
    - Baseline frozen 3f6a03d → 112/112 + 4 probes + Node 31/31,
      0-mismatch vs r72-verifier receipt.
    - Author battery 127/127 (82 ordinary/45 negative) + 4 probes +
      Node 31/31, seeds_unchanged=true; prior 112 rows 0-mismatch
      (receipt corpus/live/r73-author/runs/20261014T015541463862Z/).
    - Result — all four claims CONFIRMED and converged by 5 independent
      measurements: meta=0 opaque vs per-bit arrays (LINK at hop-start
      index; node owners valid, server 0s); each gate byte-identical to
      the no-link tuple on sole-route geometry and to the region-route
      fallback on walk geometry; enter_cost structurally inert
      ({10,100,1e6,negatives→0}); pop-through = the same strict-<
      Euclidean pop, no link protection (scribe edge: fires at pdd>0.5,
      below default). Non-author byte-exact replay: scribe 15/15 +
      simplifier 15/15 + 8/8 mutants killed.
    - Verbatim carries: enter_cost inertness measured-not-explained;
      route cost ≠ funnel path-sum; author's mid-iteration
      vertices.append_array write-through bug found+fixed (scribe
      mechanism-pinned, author-reported); relative --runs trap still
      absent from README/docstring/lessons (reviewer re-flag).
    - Commit: work b41fb33; adjudication landing [pending].

## Touched surfaces (this seat only)

- `corpus/live/r73-scribe/scratch/link_gate_check.gd` (own probe),
  `scratch/project.godot` (verbatim copy), `scratch/navagent3d_detour_wt.gd`
  + `scratch/run_battery_wt.py` (working-tree replay copies, sha-recorded),
  `scratch/append_array_wt.gd` (write-through mechanism pin),
  `corpus/live/r73-scribe/run_arms.sh` (own-probe arm runner).
- `corpus/live/r73-scribe/runs/` — 32 own-probe arm receipts + repeat +
  mechanism run, 15 working-tree link-arm replays, prior-arm replays;
  `runs/torn-snapshot-e36aa388/` (parse-error receipt of the torn copy)
  and `runs/snapshot-ee40c45e/` (intermediate-sha prior/base arms) kept
  as labeled evidence of the in-flight observation sequence.
- This report: `reports/round-73/r73-scribe.md` — the only tracked write.

## Out of scope / non-actions

- No commits, no pushes, no subagent dispatch (LEAF), no edits to tracked
  fixtures or other lanes' files; all godot runs confined to own scratch
  dir. Sibling `corpus/live/r73-*` read for convergence only.
- Working tree left as observed (`M` ×2, `?? reports/round-73/`).
- Not a verdict: admission is the canonical judge's; critic/verifier/
  adjudicator slots pending.
