# Game-dev-3d round 72 — boundary (revenger): off-mesh links + moving-agent dynamics recon

Seat: boundary (role revenger). Scope: scratch-only under
`corpus/live/r72-boundary/`; no tracked edits, no commits, leaf — no
dispatch. The lane's declared axis-move (formalizing r71's pdd pop and
two-mode `is_navigation_finished` as tracked arms) is owned by other
seats. My assignment is recon for the NEXT depth surface:

(a) `path_metadata_flags` companion arrays — do per-point metadata
    (off-mesh links, traversal flags) alter next-path semantics, and can
    an off-mesh link be authored headlessly in this battery?
(b) moving-agent dynamics — does `distance_to_target` re-query per frame
    with a moving agent, and do the r71 values stay Euclidean mid-walk?

## Deliverable and method

Two probes + one introspection script under
`corpus/live/r72-boundary/scratch/`, run with cwd `corpus/live/r72-boundary/`:

- `navagent3d_link.gd` sha256
  `2552a5b0c5331793a55b6624a6204744ed4e17f24565eb7382d122d7e07902a3` —
  SceneTree probe, one `PROBE` line per arm, exit 0 (exit 1 = live-setup
  failure, never triggered). Reuses the r70/r71 L-corridor verbatim plus
  an additive disconnected island quad C x[2,3]z[5,6] (gap z(4,5)).
- `navagent3d_walk.gd` sha256
  `80d31e85e31220fafd85632a1ce4fdcdd14fc150c5306fadd4183b15f7afbe57` +
  `navwalk3d_driver.gd` sha256
  `caf11d75d541e7d81ea1952eda8a2b16052f604d7e5494bfa3ef2f59afec99f0` —
  instrumented `get_next_path_position` follower (same pattern as
  tracked `navfollow3d_driver.gd`, speed 2.0, delta 1/60): per-tick
  `WALK` rows sampling dist BEFORE and AFTER the move in the same frame,
  plus `TP_SAME`/`RT_SAME` same-frame reads at scripted teleports and
  target re-assignments.
- `api_probe.gd` sha256
  `db88afea47f738f2b17d0bad237317fbdfffdae3be5bae0137fd1b34617ccfe2` —
  ClassDB surface dump for the link API.
- `project.godot` — verbatim copy of `corpus/fixtures/project.godot`
  (sha256 `1fda90d4…8eac23`, byte-identical).

Command per arm:
```
timeout 60 /usr/bin/godot --headless --path scratch \
  --script res://<probe>.gd -- <flags>
```
Godot `4.7.2.stable.arch_linux.ed1daf0bf` via `/usr/bin/godot`. 52 runs,
all exit 0; every stderr banner-only or empty; two repeats
(`link_bridge_meta7`, `walk_tp10_rt60`) byte-identical — deterministic.

## (a) Off-mesh links — measured answers

**Can an off-mesh link be authored headlessly? YES, two routes** —
`NavigationServer3D.link_create()` (pure-server, same style as the
battery's `region_create`) and `NavigationLink3D.new()` node; both
traversed by the agent's path query after the normal physics settle
(`link_get_iteration_id`=1 on all link arms — synced into the map).

Geometry: spawn S=(0.5,0,0.5), corridor target T=(2.5,0,3.5).

- `--shortcut`: link (1.5,0,0.5)→(2.5,0,3.0) both endpoints interior to
  A1/B. Path becomes `[S, linkstart, linkend, T]` —
  `next=(1.5,0,0.5)`, pathlen 4.192582 (link hop counts as a straight
  2.692582 segment). Link endpoints become ordinary path waypoints.
- `--bridge`: island C + link (2.5,0,3.5)→(2.5,0,5.5), T on island.
  No-link control: unreachable, final clamps to (2.5,0,4.0)
  (euclid→final 4.031129, pathlen 4.622520). With link: reachable,
  `[S,(2,0,1),(2.5,0,3.5),(2.5,0,5.5)]`, pathlen 6.130649.
- `distance_to_target` stays Euclidean-to-raw-T through every link arm
  (3.605551 / 5.385165) — the r70 semantic is link-invariant.

**Per-point metadata DOES carry link information** (extends r71's flat
finding to non-flat data):

| meta bit | array | link-path content observed |
|---|---|---|
| 1 TYPES | `get_path_types()` | `[0,1,0,0]` shortcut / `[0,0,1,0]` bridge — `PATH_SEGMENT_TYPE_LINK` marks the waypoint index where the hop STARTS (segment path[i]→path[i+1]); the far-side point is REGION |
| 2 RIDS | `get_path_rids()` | link-start index carries the LINK RID; other points the region RID (regionmatch=3, linkmatch=1) |
| 4 OWNERS | `get_path_owner_ids()` | server link → invalid 0s; node link → valid `NavigationLink3D` ObjectID at the link-start index only (ownvalid=1, ownlink=1) |

Per-bit gating holds on link paths (meta=1→types only, meta=2→rids
only, meta=4→owners only). Metadata itself changes NO next-path output:
identical `next`/`idx`/`dist`/`path` at meta=0 vs meta=7 — it is
descriptive annotation. Edgecentered postproc reshapes only region legs
(bridge → 6 points with edge midpoints; link segment + endpoints stay
put; a duplicated zero-length final point appears after the hop).

**Traversal flags DO alter next-path semantics** — via route selection,
not the metadata arrays:

| arm | result |
|---|---|
| `linklayers=2` + `agentlayers=1` | link filtered → corridor path (shortcut) / unreachable clamp (bridge) |
| `agentlayers=3` (bits 1|2) vs link layers=2 | link used again — layer BITMASK match gates |
| `oneway` (bidir=false), forward | traversable |
| `oneway --rev` (start/end swapped) | not traversed backward → corridor/unreachable |
| `disabled` (enabled=false) | ignored → corridor |
| `travelcost=10` | corridor chosen (link hop priced ≈ cost×length) |
| `travelcost=0.1` | link path |
| `entercost=10`, `entercost=100` | **link still chosen** — enter_cost showed no route-selection effect measured |

Cost-model caveat: at default travel_cost=1 the link route (pathlen
4.192582) is chosen over the corridor (4.130649) despite being longer —
the engine's route cost is not the post-funnel path sum; the polygon-hop
approximation internals are unprobed. `enter_cost` inertness is a
measured anomaly on this build, reported not explained.

**pdd treats link waypoints uniformly — pop-through hazard**: on bridge,
`pdd=2.0` → idx=2, next=linkstart (2.5,0,3.5) (near bank); `pdd=4.03`
→ idx=3 saturated, next=linkend=T (2.5,0,5.5). Measured boundary
brackets the inferred threshold euclid(S→linkstart)=3.605551: once the
agent stands within pdd of the link start, `get_next_path_position`
returns the far bank — pointing across the unjumpable gap with no
link-specific protection. Unreachable-mode finish reproduced on link geometry:
`--bridge --link=none --pdd=4.1` → finished=true at
euclid(agent→clamped final)=4.031129 while reachable=false — r71's
two-mode gate holds with a link authored in the map.

## (b) Moving-agent dynamics — measured answers

Follower walk on the detour corridor (160 ticks, speed 2.0):

- **`distance_to_target` is not a per-frame re-query — it is live
  call-time arithmetic**: `dist == euclid(global_position,
  target_position)` EXACTLY (dev=0.000000) at every tick of every arm
  (~960 samples), including reads taken the SAME frame AFTER moving the
  transform — post-move `dpost` equals the new euclid immediately. It
  never goes stale, never touches the path state; r70/r71 Euclidean
  semantics hold unchanged mid-walk, mid-teleport, and off-mesh.
- **The path array is queried once and frozen**: `path[0]` stays the
  ORIGINAL spawn (0.5,0,0.5) for all 160 ticks and across teleports to
  (2.5,0,3.0), off-mesh (0.5,0,3.0), and back toward spawn — moving the
  agent never re-queries. Only `idx` advances through the frozen array.
- **Index advance is internal-sync, euclid≤pdd, multi-pop**: first
  advance observed at tick 4 (lazy cadence; tick-0 getter leaves idx=0).
  Walk: idx 0→1 @t4 (agent still at spawn, dist 0≤1.0); 1→2 @t22 —
  bracketed: dist(pos→portal) 1.0146 @t21 no-pop, 0.9805 @t22 pops.
  pdd=2.0: idx jumps 0→2 in ONE update @t4 (dist S→portal 1.581≤2.0).
  Corner-cut: agent never reaches portal vertex (2,0,1); closest
  approach 0.6887 @t43 — turns toward T when within pdd of the waypoint.
- **reached/finished are LATCHING flags**: flip when euclid(agent,T)
  first crosses below tdd (walk: t87 at 0.986861, bracketed below 1.0;
  teleport into radius: same-frame rch=1 fin=1). Once true they never
  re-clear on drift-away — `--teleport-b --tp-tick=10` ends parked at
  the portal vertex, euclid→T 2.549510, still `reached=true
  finished=true`.
- **finished latch freezes waypoint advance**: tp10 arm — idx stuck at 1
  for ~150 ticks even standing ON path[1] (dist 0 ≤ pdd); `next` pinned
  to the portal; the follower stalls there while the flags read done.
  (Whether `reached`-alone vs `finished` drives the freeze is
  unseparated — both latched together in reachable mode.)
- **Teleport arms**: stale path persists post-teleport — off-mesh
  (0.5,0,3.0) agent walks the straight stale `next=T` through the dead
  zone to target (reach @t73); near-target teleport latches
  reached/finished instantly (same frame).
- **Only `target_position` re-assignment re-queries**: `RT_SAME` arms
  (re-set the SAME target mid-walk) show the path re-anchored at the
  agent's CLAMPED live position — from off-mesh (1.659,0,1.848) →
  `p0=(2,0,1.848)` on B's west edge; from void (0.6617,0,3.0404) →
  `p0=(2,0,3.0404)` and `next=p0` first (walk to own projection). idx
  resets (`{0@0,2@4,1@61}` on the pdd=2.0 arm — idx drops 2→1 on the
  rebuilt 2-point path) and latches clear + re-gate (tp10+rt60: rch=1
  fin=1 → rch=0 fin=0 immediately at retarget, agent then walks to T).

## Reconstructed contract (evidence chain)

1. `distance_to_target()` ≡ `euclid(parent.global_position,
   target_position)` — instantaneous at call time; frame-rate and path
   independent (walk ×6 arms, teleport ×3, off-mesh — dev 0).
2. `get_current_navigation_path()` = the array returned by ONE query per
   `target_position` assignment; `path[0]` = clamped query-start, frozen
   for the life of the target. Movement never re-queries; re-setting the
   same target re-anchors at the clamped live position.
3. `get_next_path_position()` = `path[idx]`; internal per-sync advance
   `while idx<size-1 && euclid(agent, path[idx]) <= pdd: idx++` —
   Euclidean to the CURRENT waypoint, multi-pop per update, saturates at
   last index, link waypoints popped identically (no link protection).
4. `is_target_reached`/`is_navigation_finished` evaluate the live
   transform but LATCH on first satisfaction; once finished, idx advance
   stops; both reset by `target_position` re-assignment.
5. Links (server or node) join the path query headlessly; their
   endpoints become waypoints; `types[i]=LINK` + link RID + owner
   ObjectID annotate the hop's start index under the corresponding
   metadata bits; `navigation_layers`/`bidirectional`/`enabled`/
   `travel_cost` gate traversal, `enter_cost` did not (measured).

## Suggested battery surface (for a future round, if admitted)

A `navagent3d_link.gd` fixture could pin: shortcut arm asserts
`next=(1.5,0,0.5)`, path `[S,ls,le,T]`, `types=[0,1,0,0]`, link RID at
index 1; `meta` bit-arms pin per-bit arrays; `--linklayers=2` exits the
link route (corridor) vs `--agentlayers=3` restores it; `--oneway --rev`
unreachable on bridge; `travelcost=10` → corridor; `--link=node` arm
pins `owners[linkstart_idx]=NavigationLink3D`. A `navagent3d_walk`
fixture could pin: `dist==euclid` mid-walk at sampled ticks, same-frame
post-teleport dist freshness, frozen `p0=spawn`, idx ticks `{1@4,2@22}`,
latch persistence (post-teleport-away `reached` stays true), and
retarget re-anchor `p0=clamped-live-pos`. All constants measured above.

## Divergences and honest caveats

- First probe draft typed `get_path_types()` as PackedInt64Array —
  parse error; this build returns PackedInt32Array. Fixed and re-run;
  all final arms exit 0 (the failing stderr receipt was superseded by
  the clean re-run under the same file name).
- Flag-string arm names without `--` silently parsed as corridor in the
  first batch (geometry selector missed; the link arms still exercised
  the shortcut coordinates because `--link=` parses independently).
  Corrected and re-run — receipt names carry the `--`-normalized forms.
- `enter_cost` inertness (10 and 100) is measured, not explained — the
  A* link-cost internals are unprobed. Link-vs-corridor preference at
  default costs (4.19 > 4.13 chosen anyway) likewise measured.
- The advance-freeze separation (`finished` vs `reached` latch) is
  unprobed — both fired together; an unreachable-mode finished-without-
  reached walk arm would separate it.
- Whether map changes (region add/remove mid-walk) or param changes
  trigger re-query — unprobed; only `target_position` re-assignment
  measured as the re-query trigger.
- Avoidance (`velocity`, `velocity_computed`), `path_max_distance`,
  `path_height_offset`, `simplify_path`, real colliders under the walk —
  unprobed; the follower moves the transform directly.
- One engine build (`4.7.2.stable.arch_linux.ed1daf0bf`), one host,
  60 Hz physics, 30-frame settle + 160 driver ticks.
