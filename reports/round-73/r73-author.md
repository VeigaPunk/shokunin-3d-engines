# Game-dev-3d round 73 — off-mesh NavigationLink3D traversal gating as tracked CASES arms (author, host: devin)

## Work performed

- Before-state `3f6a03d` (r72 post-adjudication landing): 112 Godot headless
  cases plus four opt-in probes; Node three.js 31/31. The r72 boundary seat
  (revenger) measured off-mesh links headlessly
  (`reports/round-72/r72-boundary.md`) and recorded them as the suggested
  battery surface.
- Declared depth move (dispatch brief): formalize off-mesh navigation-link
  traversal gating as tracked CASES arms on the existing detour fixture —
  (a) `path_metadata_flags` companion arrays surface LINK-typed waypoints
  where the plain path array is opaque; (b) three traversal gates
  (`navigation_layers` bitmask mismatch, `bidirectional=false` approached
  from the exit side, `enabled=false`) each independently drop the link;
  (c) the r72 `enter_cost`-inert anomaly re-tested as a pinned arm pair vs
  live `travel_cost`; (d) the pop-through hazard (large pdd → `next`
  points across the void at the link's far endpoint).
- Bounded spike before tracked edits (own receipts, scratch only): the
  r72-boundary probe verbatim — `corpus/live/r73-author/scratch/
  navagent3d_link_probe.gd` sha256
  `2552a5b0c5331793a55b6624a6204744ed4e17f24565eb7382d122d7e07902a3`
  (byte-identical to `r72-boundary/scratch/navagent3d_link.gd`) + verbatim
  `project.godot` copy (sha256
  `1fda90d46b0529aea0e75710a64f038cbf983adc8385285dd8bbe6202a8eac23`,
  byte-identical to the tracked seed). 19 runs under
  `corpus/live/r73-author/runs/*.stdout.txt`, every one exit 0, stderr
  banner-only or empty. Command shape:
  `timeout 60 /usr/bin/godot --headless --path corpus/live/r73-author/scratch --script res://navagent3d_link_probe.gd -- <flags>`.
  Determinism: `sc_srv_repeat`, `br_pdd4_repeat` byte-identical to their
  first runs; all 15 fixture arms additionally ran twice (focused + full
  battery) with byte-identical stdout/stderr/exit fields.
- Fixture work (sole tracked writer this round): extended
  `corpus/fixtures/navagent3d_detour.gd` additively — sha256
  `ea722a750818d06a50db5f3cdaeae1738fae29944ad0de54034e444a7d1f4da0` →
  `0ae04750b2041ba17bfb1835c70c40ad182e116ab87069be7fec05b1e4835ce4`,
  `git diff --numstat` = +337/−2 (the two deletions are the mesh vertex
  assignment folded into a local `verts` var and the polygon-count literal
  folded into `want_polys` — both required for the island quad, neither
  changes existing-arm behavior) — plus 15 additive CASES rows in
  `run_battery.py` +30/−0 (`4e9ead37da8ed6211e4116d16f344d651d725af6863017e6544bb83186eefdfa`
  → `9f18a711ff958abce08aad3b6db8e7f226c9a897beedc811023540cc61872860`).
  The user flag is still only `--arm=<name>`; each link arm's setup
  (island/link endpoints/layers/direction/enabled/costs/meta) AND expected
  tuple + companion arrays are authored constants in `_arm_cfg`, checked by
  `_run_link_arm`, which fails exit 1 with a named diagnostic on mismatch.

## Measured semantics (Godot 4.7.2.stable.arch_linux.ed1daf0bf, authored L-corridor + island C x[2,3]z[5,6])

```
authoring:  NavigationServer3D.link_create() and NavigationLink3D.new()
            both join the agent's path query headlessly after the normal
            30-frame settle (link_get_iteration_id = 1)
metadata:   agent.path_metadata_flags bits 1/2/4 gate types/rids/
            owner_ids on get_current_navigation_result(); meta=0 leaves
            all three EMPTY even while the path crosses the link (opaque);
            LINK type (1) marks the index where the hop STARTS
            (path[i]->path[i+1]); rids[i]=link RID at that index (region
            RID elsewhere); owner_ids[i] is a valid NavigationLink3D
            ObjectID only for node-authored links (server links give 0s);
            metadata changes NO path output
gates:      navigation_layers = BITMASK intersection (link 2 vs agent 1
            drops; agent 3 restores); bidirectional=false traversable
            forward, dropped approached from the exit side; enabled=false
            drops; travel_cost=10 prices the hop out of route selection;
            enter_cost 10 AND 100 leave the link chosen — INERT on this
            build (measured anomaly, pinned as TRUE behavior)
pop:        link endpoints are ordinary waypoints to the strict-< pdd
            pop loop — pdd 4.0 on the bridge pops THROUGH the near
            endpoint: next = far endpoint (2.5,0,5.5) across the void,
            reachable=true, finished=false
```

Key receipts (`corpus/live/r73-author/runs/*.stdout.txt`, `PROBE` lines):

- (a) `sc_srv` meta=0: link path `[S,(1.5,0,0.5),(2.5,0,3.0),T]` but
  `types=[] nrids=0 nowners=0` — opaque. `sc_node_meta7`: `types=[0,1,0,0]`,
  `nrids=4 linkmatch=1`, `owners=[0,NavigationLink3D,0,0]`. Per-bit:
  `sc_srv_meta1` types-only, `sc_srv_meta2` rids-only (`ridmatch=3
  linkmatch=1`), `sc_srv_meta4` owners all-invalid (server),
  `sc_node_meta4` `ownvalid=1 ownlink=1`.
- (b) `sc_lay_off` (link layers=2, agent 1): corridor path
  `[S,(2,0,1),T]`, `types=[0,0,0]`. `sc_lay_on` (agent 3): link restored.
  `br_oneway_fwd` reachable `final=(2.5,0,5.5)` pathlen 6.130649;
  `br_oneway_rev` unreachable clamp `final=(2.5,0,4.0)` pathlen 4.622520.
  `br_disabled`/`sc_disabled`: link dropped (bridge → unreachable;
  shortcut → corridor). Each arm also read-backs every authored flag via
  `link_get_*` before judging — a no-op setter fails the arm.
- (c) `sc_travel10`: corridor chosen (link priced out). `sc_enter10` and
  `sc_enter100`: link path still chosen, byte-identical tuple to the
  zero-cost arm — enter_cost inert re-confirmed.
- (d) `br_none`: island without link unreachable (the void premise).
  `br_pdd2`: idx=2, next=link near endpoint (2.5,0,3.5) (near bank).
  `br_pdd4`: idx=3 saturated, next=link far endpoint (2.5,0,5.5) across
  the void — reachable=true, finished=false.

## New CASES rows (15, all exit 0)

`--arm=` → preset tuple in `_arm_cfg`; `_run_link_arm` pins
path/idx/next/final/dist/reachable/reached/finished (same order as
`_run_pop_arm`) plus the keyed companion arrays (`types` exact match,
`nrids`/`rid_at` = the link RID index with all other entries the region,
`nowners`/`own_at`/`own_class` = a live instance check).

- (a) `link_shortcut` (server link, meta=0 — opaque control),
  `link_meta_types` (meta=1), `link_meta_rids` (meta=2),
  `link_meta_owners` (meta=4 node), `link_meta` (meta=7 node — all three
  arrays populated, owner resolves to the authored `NavigationLink3D`)
- (b) `link_layers_off`/`link_layers_on` (bitmask mismatch/restore),
  `link_oneway_fwd`/`link_oneway_rev` (forward traversable vs exit-side
  unreachable on the bridge), `link_disabled` (enabled=false on the
  bridge)
- (c) `link_travelcost` (10 → corridor), `link_entercost` (100 → link
  still chosen — the anomaly pinned as TRUE)
- (d) `link_gap` (void premise: island unreachable without a link),
  `link_pop_bank` (pdd 2.0 → next=near endpoint), `link_pop_void`
  (pdd 4.0 → next=far endpoint across the void)

## Before → after measurements

- Focused:
  `python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r73-author/runs --only <all 42 detour cases>`
  → exit 0, **42/42 PASS**, receipt
  `corpus/live/r73-author/runs/20261014T015454762559Z/verdicts.json`.
  (An earlier focused pass at `runs/20261014T015242466681Z` caught the
  island-polygon authoring bug — `mesh.vertices.append_array` does not
  write through on this build; verts must be complete before assignment.
  Fixed, re-measured, all green.)
- Full battery + 4 probes (absolute `--runs`):
  `python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r73-author/runs --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing`
  → exit 0, **PASS 127/127** (82 ordinary / 45 negative_controls /
  probes=4), `seeds_unchanged=true`, godot
  `4.7.2.stable.arch_linux.ed1daf0bf`; receipt
  `corpus/live/r73-author/runs/20261014T015541463862Z/verdicts.json`.
  Probes: `crash_probe_ok`/`stream_probe_ok`/`tree_probe_ok`=true;
  mutation probe `verdict=PASS` (`mutant_body3d_contact` exit 1, expected
  diagnostic).
- Prior-case stability: all 112 pre-r73 raw case fields (case, script,
  flags, expected/actual exit, kind, marker, verdict, reasons, stdout,
  stderr, error) byte-identical to the r72-author full receipt
  `corpus/live/r72-author/runs/20261014T004642048951Z/verdicts.json` —
  **0 mismatches over 112 cases × 11 fields**; the 15 new names are the
  r73 link rows.
- Seed map 52→52: `navagent3d_detour.gd` and `run_battery.py` digest
  changes are the only diffs; no added/removed keys.
- Node three.js suites (Node v24.21.0, three.js 0.186.1, existing
  `corpus/fixtures/three` install): run_cases 3/3, run_layer_cases 4/4,
  run_order_cases 9/9, run_camera_cases 5/5, run_ortho_cases 5/5,
  run_ray_cases 5/5 — **31/31 PASS**, every suite `seeds_unchanged=true`;
  receipts `corpus/live/r73-author/runs/node/run_{cases,layer_cases,order_cases,camera_cases,ortho_cases,ray_cases}.json`.

## Independent check (lane's single labrat)

Dispatched one `ufo-labrat` probe on the six-clause hypothesis (opaque-at-
meta=0 + per-bit arrays; layers bitmask; bidirectional direction;
enabled; travel_cost-live/enter_cost-inert; pop-through). Its substrate
exposed no exec tool, so it audited the recorded r73-author receipts plus
the r72-boundary runs — **all six clauses SUPPORTED**, r72↔r73 tuples
byte-identical where shared. Two useful flags recorded: (1) dropped-link
receipts are signature-degenerate across gates — independence is
established only by controlled toggling across arms, which the arm set
does; (2) coverage gap — no bridge+`travel_cost` arm exists (repricing
with no corridor alternative unmeasured); not a contradiction.

## Resolved questions

- **`path_metadata_flags` is a per-bit companion-array gate on the agent's
  query result**: meta=0 leaves types/rids/owner_ids EMPTY on a path that
  crosses a link; bits 1/2/4 independently populate the three arrays; the
  LINK segment type marks the hop's START index. A `NavigationLink3D`
  node authors headlessly and surfaces as a valid owner ObjectID at that
  index; server-authored links give invalid 0s.
- **The three traversal gates are independent and live**: bitmask
  intersection on `navigation_layers` (mismatch drops, superset
  restores), `bidirectional=false` is directional (forward traversable,
  exit-side approach drops → island unreachable), `enabled=false` drops
  outright. Each arm pins the flag read-back AND the path result, so a
  silent no-op setter fails loudly.
- **The `enter_cost` anomaly is real and pinned**: `travel_cost=10`
  reprices the hop out of route selection (corridor chosen); `enter_cost`
  at 10 and 100 leaves the link chosen — byte-identical tuples to the
  zero-cost arm. The claim "appears inert" is confirmed; the tracked arm
  pins the TRUE behavior.
- **The pop-through hazard is real and pinned**: `link_pop_void` puts
  `next_target` on the far bank across an unjumpable gap while
  `reachable=true` — no link-specific protection in the pdd pop loop.

## Caveats / UNKNOWNs

- Bounded to Godot 4.7.2.stable.arch_linux.ed1daf0bf headless, the
  authored L-corridor + island, stationary agent, single region,
  cell_size 0.25, 30-frame settle. Moving agents, avoidance, mid-path
  map/link edits, other builds remain unprobed.
- `enter_cost` inertness is measured at {10, 100} on the shortcut
  geometry, not explained — whether ANY geometry/cost regime activates it
  (e.g. a link whose hop is already marginal) is unprobed; likewise
  `travel_cost` repricing with NO corridor alternative (bridge+travel
  arm) is unmeasured.
- `link_is_bidirectional` directionality is pinned at endpoint granularity
  (approach side); intra-hop behavior mid-traversal is out of scope
  (stationary agent).
- Owner-ObjectID pin requires the node route; server-link owner ids are
  all invalid by measurement — the arm set documents both.
- The corrupt-mesh authoring bug (`vertices.append_array` post-assignment
  not writing through) is a harness lesson, not an engine claim pinned
  here: fixed by completing verts before assignment.
- Labrat confirmation is receipt-level (its substrate had no exec) — the
  re-execution evidence is my own 19-run scratch matrix plus two
  battery passes.

## Per-axis verdicts (author claim — non-author review required before admission)

- **Depth: improved (claim)** — the r72 boundary's link recon is resolved
  into a pinned contract: companion-array bits, three independent
  traversal gates with read-back verification, the enter_cost anomaly
  pinned as a live arm pair, and the pop-through hazard pinned
  end-to-end (void premise → near-bank stop → far-bank pop).
- **Coverage: improved (claim)** — 112→127 battery rows on the
  NavigationAgent3D surface; first arms authoring NavigationLink3D nodes
  and server links, first island/disconnected-region geometry, first
  metadata-array assertions.
- **Discernment/quality (claim)** — every arm carries authored
  expectations + per-clause falsification paths (flag read-back +
  tuple + companion arrays); 15/15 run byte-identically twice; prior 112
  rows field-stable.
- Admission rests on improved axes with none harmed in finite replay,
  pending named independent verification; not marked.

## Assumptions and constants

Host devin; `/usr/bin/godot` ELF 4.7.2.stable.arch_linux.ed1daf0bf, Node
v24.21.0, three.js 0.186.1, physics 60 tps. Map cell_size 0.25;
L-corridor quads A1 x[0,2]z[0,1], A2 x[2,3]z[0,1], B x[2,3]z[1,4], island
C x[2,3]z[5,6]. Spawn (0.5,0,0.5); targets (2.5,0,3.5) corridor and
(2.5,0,5.5) island; shortcut link (1.5,0,0.5)->(2.5,0,3.0), bridge link
(2.5,0,3.5)->(2.5,0,5.5). DIST_TOL 0.004, POS_TOL 0.001; metadata flag
ints are raw bit positions (PATH_METADATA_INCLUDE_* constants are absent
from NavigationAgent3D on this build — the int property is set directly).

## SHONEN

- [ ] Real decision tables/error patterns/checklists with cited sources — not attested this round.
- [x] End-to-end domain task executed and logged — 19-run scratch matrix + 127-case battery + 31/31 Node receipts under `corpus/live/r73-author/runs/`; named `ufo-labrat` probe confirmed all six clauses against the recorded receipts.
- [ ] Instructions executable without oral context — not attested as a probation box.
- [ ] No cross-domain bleed; PROVINCE accurate — not attested as a probation box.
