# Game-dev-3d round 73 — boundary (revenger): link-traversal edge probes

Seat: boundary (role revenger). Scope: scratch-only under
`corpus/live/r73-boundary/`; no tracked edits, no commits, leaf — no
dispatch. The lane's declared axis-move (tracked CASES arms pinning link
traversal gates on `navagent3d_detour.gd`) is owned by the author seat;
at probe time the tracked fixture still carries zero link code
(`grep -c link corpus/fixtures/navagent3d_detour.gd` = 0, HEAD 3f6a03d
r72). My assigned recon — the five probe edges from the brief — runs on
my own scratch geometry, independent of the tracked arms landing:

1. mid-flight readouts during a link hop (`next`/`distance_to_target`
   DURING traversal — interpolated? far endpoint? zero-length?)
2. multiple links chained / link inside the detour wall geometry
3. companion arrays (`path_metadata_flags` types/rids/owners) on a path
   with NO links — empty or typed differently?
4. `enter_cost` extreme values (1e6, 0, negative) — perturbation or
   structurally ignored on 4.7.2?
5. `target_position` set mid-link-traversal (re-anchoring during a hop)

## Deliverable and method

Two new probes + one new driver under `corpus/live/r73-boundary/scratch/`
(cwd for every run; `project.godot` is a byte-identical copy of
`corpus/fixtures/project.godot`, sha256 `1fda90d4…8eac23`):

- `navagent3d_linkedge.gd` sha256
  `072f294fe7043f026d5be8ec01d74cfe9890c6731b4e0d367721c8aead05b11b` —
  SceneTree probe, one `PROBE` line per arm. r72 L-corridor verbatim +
  additive islands C x[2,3]z[5,6] and D x[2,3]z[7,8]; modes
  corridor/shortcut/bridge/chain/chaineq/notch/notch2/wallseg/inregion;
  adds link readbacks (`lsa`/`lsb`/`ec`/`tc`) and pre/post-settle
  `linkrad` reads.
- `navagent3d_linkwalk.gd` sha256
  `2527216c9a6d2b8b51fa9ab4b97910afc6174e00e0739b695829aeffe1be4748` +
  `navlinkwalk3d_driver.gd` sha256
  `4c008c0233500d18c0f7a3b1862209dbdd45dc22ccbebb065f07ad706178aafb` —
  instrumented `get_next_path_position` follower (r72 `navwalk3d_driver`
  pattern; speed 2.0 default, delta 1/60, 30-frame settle + 300 ticks)
  over bridge geometry: link (2.5,0,3.5)→(2.5,0,5.5), T=(2.9,0,5.9)
  distinct from link end (`--tle` sets T=le). Per-tick `WALK` rows add
  `st` (types[idx] of frozen path) and `nl` (LINK count); `VOID` marks
  first tick inside the gap z∈(4,5); `RT_SAME`/`RT_NEW`/`TP_SAME` rows
  print post-action reads including the re-queried `p0`/`types`.
- Arm runner scripts `run_arms.sh` / `run_arms2.sh` (absolute
  `--path`/`runs` paths per brief).

Command per arm:
```
timeout 90 /usr/bin/godot --headless --path \
  /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r73-boundary/scratch \
  --script res://<probe>.gd -- <flags>
```
Godot `4.7.2.stable.arch_linux.ed1daf0bf` via `/usr/bin/godot`. 49 runs
under `corpus/live/r73-boundary/runs/`, all exit 0, every stderr empty;
`e1_walk` vs `e1_walk_repeat` byte-identical — deterministic.

## (1) Mid-flight readouts — `next` is never interpolated

Geometry: path `[S,(2,0,1),(2.5,0,3.5)ls,(2.5,0,5.5)le,(2.9,0,5.9)T]`
(types `[0,0,1,0,0]`; the LINK mark sits at the hop's ORIGIN index 2).

- `next` jumps endpoint→endpoint in ONE tick, never an interpolated or
  mid-link point: t86 `next=(2.5,0,3.5)` (idx=2), t87 `next=(2.5,0,5.5)`
  (idx=3) — `runs/e1_walk.stdout.txt` WALK rows.
- During the whole void crossing (pos.z∈(4,5), ticks ~129–145):
  `next` = the far endpoint le while it is the current index, then T.
  `distance_to_target` stays `euclid(pos, T)` EXACTLY — `maxdev_pre`/
  `maxdev_post=0.000000` on every arm (960+ samples incl. all mid-void
  ticks). The r72 Euclidean model survives the hop untouched.
- `st=types[idx]` during actual traversal reads 0 (REGION): idx=3 →
  `types[3]=0`. The LINK annotation describes the hop's start index; the
  in-flight leg carries no metadata marker of its own.
- **Pop-through extension (claim d live)**: pdd=2.0 — the agent pops ls
  at t53 while at pos (1.4060,0,1.8590), euclid→ls 1.97<2.0, i.e. aims
  across the unjumpable gap from z≈1.86 deep on the near bank
  (`runs/e1_walk_pdd20.stdout.txt`). At t108 (pos z=3.6148, still on
  mesh) euclid→le<2 pops to idx=4 → `next=T` for the remainder of the
  crossing.
- **Mid-void latch**: `--tle` arm — `reached`/`finished` latch at t145
  with pos (2.3493,0,4.5309), z INSIDE the gap: euclid→T=le is
  0.980710 < tdd 1.0 while the agent stands off-mesh
  (`runs/e1_walk_tle.stdout.txt`). Same at pdd=2.0: latch t138 at
  z=4.5725 (`runs/e1_walk_pdd20_tle.stdout.txt`). Arrival is Euclidean —
  the engine fires "done" mid-hop in dead space.
- Teleport onto the link line mid-gap (tp=40 → (2.5,0,4.5)): the frozen
  path AND idx persist; `next` points BACK at ls (idx=2 unpopped), the
  agent walks backward 1 tick, pops ls at euclid<1 (t42), then re-aims
  forward across the void (`runs/e1_tp_void.stdout.txt`). There is no
  traversal state — the hop is exactly two ordinary waypoints.

## (2) Chained links and off-mesh/wall endpoints

`--chain` (link1 (2.5,0,3.5)→(2.5,0,5.5), link2 (2.5,0,5.8)→(2.5,0,7.5),
T=(2.5,0,7.9) on D) — `runs/e2_chain.stdout.txt`:
path `[S,(2,0,1),ls1,le1,ls2,le2,T]` npath=7, types `[0,0,1,0,1,0,0]` —
TWO chained LINK hops with a REGION leg between them inside C; rids
carry link1's RID at index 2 and link2's at index 4
(`linkmatch=1 link2match=1`).

- `chaineq` (link2 start == link1 end): the shared vertex is
  deduplicated — npath=6, types `[0,0,1,1,0,0]` consecutive LINK marks;
  back-to-back hops need no intervening region leg
  (`runs/e2_chaineq.stdout.txt`).
- `chain --rev` (link1 authored C→B): identical forward path —
  bidirectional is direction-agnostic (`runs/e2_chain_rev.stdout.txt`).
- `chain --disabled` (link1 off): the whole chain collapses — final
  clamps to B's north edge (2.5,0,4.0), `reachable=false`
  (`runs/e2_chain_disabled.stdout.txt`). A dead first hop isolates both
  downstream islands.

**Endpoints off-mesh** (notch = dead quad x[0,2]z[1,4] inside the
L-corridor's missing geometry; link start (1.0,0,2.0) sits at distance
exactly 1.0 from the nearest mesh point (1,0,1)):

- `map_set_link_connection_radius` is the gate and it is STRICT `<`:
  radius 0.5 → dead, **radius 1.0 → dead** (dist == radius does NOT
  connect), radius 1.01 / 1.5 → connected
  (`runs/e2_notch_linkrad05|10|101|15.stdout.txt`, `e2_notch.stdout.txt`).
- When connected, the PATH WAYPOINT IS THE PROJECTION, not the authored
  point: `[S,(1.0,0,1.0),(2.5,0,3.5)]` with `lsa` still reading the raw
  (1.0,0,2.0) — the server stores authored endpoints verbatim but the
  route snaps them to nearest mesh. types marks LINK at the projected
  index.
- `notch2` (both endpoints off-mesh): dead at radius 1.0, alive at 1.5 —
  BOTH endpoints project: `[S,(1.0,0,1.0),(2.0,0,3.0),T]`, types `[0,1,0,0]`
  (`runs/e2_notch2.stdout.txt`, `e2_notch2_linkrad15.stdout.txt`).
- **Getter/setter quirk**: `map_get_link_connection_radius` returns the
  STALE pre-sync value when read before the first physics frame —
  `linkrad=1.000/0.500` (pre/post-settle) — while the setter is already
  effective at query time. Pre-settle reads are unreliable; post-settle
  reads the true value.
- `wallseg` — link (1.0,0.5)→(2.5,0,3.0), both ends on mesh, segment
  crosses the notch: USED — `[S,(1,0,0.5),(2.5,0,3.0),T]`, types `[0,1,0,0]`,
  pathlen 3.915476 (`runs/e2_wallseg.stdout.txt`). Intervening non-mesh
  along the segment is irrelevant; only endpoint connection matters.
- `inregion` — link wholly inside polygon B (2.5,0,1.5)→(2.5,0,3.0):
  NEVER used at tc∈{0, 0.1, 1} or ec=1e6, server or node
  (`runs/e2_inregion*.stdout.txt`). Links bridging points on the SAME
  polygon are ignored by route selection even when strictly cheaper —
  links bridge polygons, they do not splice intra-polygon shortcuts.

## (3) Companion arrays on a link-free path

Flags set, no LINK point anywhere — the arrays are POPULATED to path
length, not empty, and typed uniformly REGION:

| arm | types | rids | owners |
|---|---|---|---|
| corridor meta=1 | `[0,0,0]` | — | — |
| corridor meta=2 | — | 3 × region | — |
| corridor meta=4 | — | — | 3 × `0` (invalid) |
| corridor meta=7 | `[0,0,0]` | 3 × region | 3 × `0` |
| corridor meta=7 postproc=1 | `[0,0,0,0]` | 4 × region | 4 × `0` |
| bridge no-link meta=1 (clamped path) | `[0,0,0]` | — | — |
| bridge no-link meta=2 | — | 3 × region | — |
| bridge no-link meta=4 | — | — | 3 × `0` |
| bridge no-link meta=7 | `[0,0,0]` | 3 × region | 3 × `0` |

(`runs/e3_*.stdout.txt`.) Per-bit gating is identical to link paths; the
only difference from a link path is the absence of value-1 (LINK)
entries and link RIDs. The unreachable clamped path reports the same
all-REGION metadata on its shortened array.

## (4) `enter_cost` — stored, clamped, structurally inert

Extremes on the r72 anomaly (`runs/e4_*.stdout.txt`):

| arm | result |
|---|---|
| shortcut ec=1e6 | link still chosen, pathlen 4.192582 — a 1e6 surcharge cannot push route selection off the link |
| shortcut ec=1e6 + tc=0.1 | link still chosen (cheap travel + huge enter still enters) |
| shortcut ec=10 + tc=10 | corridor — `travel_cost` dominates; enter never weighs in |
| bridge ec=1e6 (sole route) | link used, reachable=true |
| bridge ec=−1e6 | link used |
| chain link1 ec=1e6 | chain unchanged, both hops taken |
| inregion ec=1e6 | still ignored (same-polygon rule) |

**New readback finding**: `link_set_enter_cost` CLAMPS negatives —
`ec=-5` and `ec=-1e6` both read back `link_get_enter_cost=0.00`; positive
values store verbatim (`1e6→1000000.00`). The plumbed contract on this
build: enter_cost stores `max(0, v)` and is then ignored by routing at
every magnitude {0, 10, 100, 1e6} across shortcut/bridge/chain/inregion.
The r72 anomaly hardens: dead state, not an edge-case bug.

## (5) `target_position` mid-link-traversal — nearest-bank re-anchor

Same-target retarget while the follower is inside the gap
(`--rtz=F` fires on pos.z≥F, `runs/e5_rtz4{4,5,6}.stdout.txt`):

- Re-anchor clamps the LIVE position to the NEAREST bank edge:
  z=4.4321 → `p0=(2.3339,0,4.0)` on B; z=4.5309 and 4.6237 →
  `p0=(…,5.0)` on C. The boundary is the equidistant line z=4.5; the
  teleport+retarget tie probe at exactly (2.5,0,4.5) clamps to **B**
  (`runs/e5_tp45_rt45.stdout.txt`) — ties break to the near bank
  (measured, not explained).
- B-side re-anchor: new path `[p0, ls, le, T]`, types `[0,1,0,0]` — the
  query re-enters the link at ls (backward leg). The pdd-pop then skips
  the backtrack immediately (euclid(pos,ls)<1) → `next=le`; the agent
  never physically revisits ls.
- C-side re-anchor: new path `[p0, T]`, types `[0,0]` — the link is
  abandoned entirely; the hop "never happened" from the re-query on.
- `rtnew=0.5,0.5` at z=4.6 (C-side anchor, new target back at spawn):
  path `[p0, le, ls, (2,0,1), S]`, types `[0,1,0,0,0]` — the agent
  traverses the bidirectional link BACKWARD: `next=(2.5,0,3.5)` (the
  reverse exit) and walks the void back to ls, reach@264
  (`runs/e5_rtnew_back.stdout.txt`). The LINK mark follows path order —
  whichever index the hop starts at carries it, either direction.
- `rtnew=2.5,7.5` (unreachable target off-mesh): path `[p0,(2.5,0,6.0)]`
  clamps to C's far edge; `reachable=false`, `finished` latches at
  euclid→final<pdd — the r71/r72 two-mode gate survives a mid-hop
  retarget (`runs/e5_rtnew_d.stdout.txt`).
- Exact-tie pop boundary on a link waypoint: post-retarget at
  (2.5,0,4.5), euclid→ls == 1.0 EXACTLY → NOT popped (strict `<`) →
  `next=ls`, agent backtracks one tick before the pop
  (`runs/e5_tp45_rt45.stdout.txt`, idx_ticks `{3@44}`).

## Reconstructed contract (evidence chain)

1. A link hop is two ordinary waypoints plus a metadata mark at the
   hop's start index. There is NO traversal/interpolation state:
   `next` switches endpoint→endpoint in one tick; during the hop
   `next` = far endpoint (or beyond if popped);
   `distance_to_target` ≡ `euclid(live pos, T)` mid-void exactly
   (dev=0.000000 every tick, every arm).
2. `reached`/`finished` latch on the Euclidean gate even mid-gap —
   arrival fires off-mesh (z=4.53 < tdd boundary inside z∈(4,5)).
3. Chained links compose; shared endpoints deduplicate to consecutive
   LINK marks; bidirectional links are direction-agnostic and support
   full backward traversal on re-query; a disabled upstream hop
   orphans every downstream island.
4. Link endpoints off-mesh connect via their nearest-mesh PROJECTION
   iff `dist < map.link_connection_radius` strictly (== fails); the
   projection becomes the path waypoint while `link_get_*_position`
   still reads the authored point. `map_get_link_connection_radius`
   reads stale before the first sync.
5. Links whose endpoints connect to the SAME polygon are ignored by
   route selection at all costs — link = inter-polygon edge only.
6. `enter_cost` is write/read plumbing only: negatives clamp to 0,
   positives store verbatim, and {0,10,100,1e6} all fail to perturb
   route choice on this build — structurally inert. `travel_cost` is
   live (tc=10 drops the link).
7. `target_position` re-assignment mid-hop re-anchors at the live
   position clamped to the nearest bank (tie → near bank); the new
   query may re-enter the link (B anchor) or abandon it (C anchor);
   the frozen-path/idx/latch reset semantics of r72 apply unchanged.

## Suggested battery surface (for a future round, if admitted)

`navagent3d_linkedge` pins worth tracking: `chain` asserts
`types=[0,0,1,0,1,0,0]` + `linkmatch=1 link2match=1`; `chaineq` asserts
consecutive `[1,1]` marks; `notch --linkrad=1.0` dead vs
`--linkrad=1.01` projected-point path `(1,0,1)`; `wallseg` asserts the
notch-crossing segment used; `inregion` asserts the same-polygon link
ignored at tc=0. `navagent3d_linkwalk` pins: `next` discrete-switch
tick (t86→t87 ls→le), `dist==euclid` mid-void, `--tle` mid-void latch
(reach@145 z=4.5309), `rtz` re-anchor `p0` (B-side `(…,4.0)` /
C-side `(…,5.0)`), `rtnew=back` reverse traversal `next=ls`.
All constants measured above.

## Divergences and honest caveats

- Probe-authoring bug, fixed + re-run: the `linkedge` default-link
  logic first overrode explicit `--link=none` on non-corridor modes;
  the four `e3_bridge_nolink_*` arms ran with a link before the fix.
  Final receipts are the corrected re-runs (`runs/e3_bridge_nolink_*`,
  link=none in PROBE line). Runner: `run_arms2.sh`.
- `map_get_link_connection_radius` pre-sync staleness is a timing
  quirk of MY readback placement, not an engine misbehavior claim —
  post-settle readbacks (`linkrad=pre/post`) are the reliable form.
- The B-vs-C re-anchor boundary is bracketed at z∈(4.4321, 4.5309)
  with the exact tie at 4.5 measured once (B wins); the tie-break
  internals (which polygon wins on equidistance) are unprobed.
- Whether the engine's link-hop treats an agent that PHYSICALLY enters
  the gap differently (collision-layered body, not a transform
  follower) is out of scope — the follower moves the transform
  directly, same discipline as r72.
- `path_max_distance`, avoidance, link owner_id on server links,
  multi-map links, vertical (y) link hops — unprobed.
- One engine build (`4.7.2.stable.arch_linux.ed1daf0bf`), one host,
  60 Hz physics, 30-frame settle + 300 driver ticks; static arms 30
  frames then read-once.

## Confidence

High on all five edges: 49 arms, exit 0 everywhere, deterministic
repeat, every numeric claim backed by a `runs/` receipt on this host.
The enter_cost-inertness verdict is now brute-force (1e6, sole-route,
chained, negative-clamped); the mid-void latch and nearest-bank
re-anchor extend r72's contract without contradicting it.
