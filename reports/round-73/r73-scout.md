# Game-dev-3d round 73 — scout: off-mesh-link gating + companion arrays

Seat: scout (leaf). Scope: `corpus/live/r73-scout/` + this report. No tracked
edits, no dispatch, no git mutation. Question: map the link-authoring surface
so the author can land `NavigationLink3D` traversal-gating CASES arms on
`navagent3d_detour.gd` without perturbing the 112-row battery.

Engine (measured, this host): `4.7.2.stable.arch_linux.ed1daf0bf` via
`/usr/bin/godot`. Sources read: `corpus/fixtures/navagent3d_detour.gd`
(sha256 `ea722a75…`), `corpus/fixtures/run_battery.py` (sha256 `4e9ead37…`),
r72-boundary report `reports/round-72/r72-boundary.md`, r72 prototype
`corpus/live/r72-boundary/scratch/navagent3d_link.gd` (sha256 `2552a5b0…` —
byte-identical copy reused under `corpus/live/r73-scout/scratch/`) and its 52
run receipts. All r72 link measurements re-executed in my own scratch; every
PROBE line reproduced identically (20 arms, receipts under
`corpus/live/r73-scout/runs/v_*.stdout.txt`, all exit 0, stderr empty).

---

## (1) Minimal diff sketch — NavigationLink3D into `navagent3d_detour.gd`

Design: reuse the existing `--arm=<name>` preset mechanism (`_arm_cfg`,
L246–407) — the preset dict gains optional keys; no new top-level flags are
required (a `--link=<name>` flag family is equivalent surface area but a
bigger diff: `_arm_cfg` already owns per-arm authored constants and
`_run_pop_arm` already owns tuple comparison). Every key below is opt-in;
all 27 existing detour presets lack them and observe zero change.

New optional `_arm_cfg` keys:

```
"island": true            # append island quad C x[2,3]z[5,6] (gap z(4,5))
"link": {                 # absent => today's behavior, byte-identical
  "mode": "server" | "node",
  "a": Vector3, "b": Vector3,     # authored in traversal direction; the
                                  # "reverse" gate is just a/b swapped —
                                  # no separate rev flag needed
  "bidirectional": bool (dflt true), "enabled": bool (dflt true),
  "layers": int (dflt 1), "enter_cost": float (dflt 0.0),
  "travel_cost": float (dflt 1.0) }
"agent_layers": int (dflt 1)      # agent navigation_layers
"meta": int (dflt 7 = PATH_METADATA_INCLUDE_ALL)
# expected-tuple additions, checked only when present:
"types": [int, ...]               # PATH_SEGMENT_TYPE_* per index
"nlink": int                      # count of LINK entries in types
"link_rid_idx": int               # index whose rids[i] == the link RID
"owner_node_idx": int             # index whose owners[i] resolves to the node
```

Edits, in file order:

1. **Mesh island (after L94, in the `else` detour branch):**
   ```gdscript
   if arm != "" and arm_cfg.get("island", false):
       mesh.vertices.append_array(PackedVector3Array([
           Vector3(2, 0, 5), Vector3(2, 0, 6), Vector3(3, 0, 6), Vector3(3, 0, 5)]))
       mesh.add_polygon(PackedInt32Array([8, 9, 10, 11]))  # C island
   ```
   Vertices are indexed `8..11` continuing the existing `0..7` block. Region
   count stays 1; island polys land in the same region (same `navigation_layers`).

2. **Link authoring block (after L107 `agent.set_navigation_map(map)`, before
   the post/arm flag writes and L115 `agent.target_position = target` —
   `path_metadata_flags` and `navigation_layers` must precede target
   assignment because they are query parameters):**
   ```gdscript
   var link_rid := RID()
   if arm != "" and arm_cfg.has("link"):
       var lc: Dictionary = arm_cfg["link"]
       if lc.get("mode", "server") == "node":
           var link_node := NavigationLink3D.new()
           root.add_child(link_node)
           node_owned.append(link_node)          # see edit 4
           link_node.set_navigation_map(map)
           link_node.start_position = lc["a"]
           link_node.end_position = lc["b"]
           link_node.bidirectional = lc.get("bidirectional", true)
           link_node.enabled = lc.get("enabled", true)
           link_node.navigation_layers = lc.get("layers", 1)
           link_node.enter_cost = lc.get("enter_cost", 0.0)
           link_node.travel_cost = lc.get("travel_cost", 1.0)
           link_rid = link_node.get_rid()
       else:
           link_rid = NavigationServer3D.link_create()
           owned.append(link_rid)
           NavigationServer3D.link_set_map(link_rid, map)
           NavigationServer3D.link_set_start_position(link_rid, lc["a"])
           NavigationServer3D.link_set_end_position(link_rid, lc["b"])
           NavigationServer3D.link_set_bidirectional(link_rid, lc.get("bidirectional", true))
           NavigationServer3D.link_set_enabled(link_rid, lc.get("enabled", true))
           NavigationServer3D.link_set_navigation_layers(link_rid, lc.get("layers", 1))
           NavigationServer3D.link_set_enter_cost(link_rid, lc.get("enter_cost", 0.0))
           NavigationServer3D.link_set_travel_cost(link_rid, lc.get("travel_cost", 1.0))
       agent.navigation_layers = arm_cfg.get("agent_layers", 1)
       agent.path_metadata_flags = arm_cfg.get("meta",
           NavigationPathQueryParameters3D.PATH_METADATA_INCLUDE_ALL)
   ```
   (Or hoist `link_node` to a file-scope `var` + `node_owned: Array[Node]`
   like the prototype; either is ~1 extra line.)

3. **Live-setup sanity (L145–151):** change the polygon term
   `(1 if straight else 3)` to
   `(1 if straight else (4 if arm_cfg.get("island", false) else 3))`, and
   inside the link gate add
   `link_rid.is_valid() and NavigationServer3D.link_get_iteration_id(link_rid) > 0`
   after the 30-frame settle — iter>0 proves the link synced into the map
   (measured `iter=1` on every link run). All non-link arms evaluate
   identically.

4. **Cleanup (L220 `_cleanup`):** free `node_owned` nodes BEFORE freeing
   `owned` RIDs, and never append a node link's RID to `owned` — the node
   frees its own RID (`link_node.free()`); double-free would print an
   `ERROR:` line and fail `classify()`. Empty for all existing arms.

5. **`_read_state` (L409–419):** append companion reads — harmless for
   existing arms (the returned dict gains keys; `_run_pop_arm` only compares
   keys present in `cfg`):
   ```gdscript
   var res: NavigationPathQueryResult3D = agent.get_current_navigation_result()
   # add: "types": res.get_path_types(), "rids": res.get_path_rids(),
   #      "owners": res.get_path_owner_ids()
   ```
   `res` is non-null here because every arm assigns `target_position` before
   the settle. Companion arrays are populated per `path_metadata_flags`.

6. **`_run_pop_arm` (L421+):** needs `link_rid`/`link_node` in scope —
   extend the signature with default args
   `func _run_pop_arm(actor, arm_name, cfg, st, st2, link_rid := RID(), link_node: NavigationLink3D = null)`,
   then chain (before the generic `path` compare) the new checks:
   `types` element-wise vs `st2["types"]`; `nlink` count;
   `link_rid_idx` → `st2["rids"][i] == link_rid`;
   `owner_node_idx` → `instance_from_id(st2["owners"][i]) == link_node`.
   Link-arm PASS lines may append `types=[…] nlink=N linkmatch=N
   ownlink=N` — new marker text only for new rows; existing markers untouched.

7. **`run_battery.py`:** append CASES rows only. No plumbing change —
   tuples already carry arbitrary flag lists. `seed_digests()` hashes
   fixtures within a single run (before vs after), so editing the fixture
   breaks nothing; the digest map is not cross-run pinned.

Net: ~60 additive lines in `navagent3d_detour.gd` + preset dicts + CASES
rows; zero lines changed for existing arms except the L148 polygon-count
expression (evaluates to the same value for all current rows).

---

## (2) Per-gate experiment table — measured predictions (re-run on r73)

Geometry A "shortcut": link `(1.5,0,0.5)→(2.5,0,3.0)`, both endpoints
interior to A1/B. S=`(0.5,0,0.5)`, T=`(2.5,0,3.5)`.
Geometry B "bridge": +island C `x[2,3]z[5,6]`, link `(2.5,0,3.5)→(2.5,0,5.5)`,
T=`(2.5,0,5.5)` on the island.

Corridor control path = `[S,(2,0,1),T]`, npath=3, pathlen `4.130649`.
Link shortcut path = `[S,(1.5,0,0.5),(2.5,0,3.0),T]`, npath=4,
pathlen `4.192582`, `types=[0,1,0,0]`, link RID at index 1.
Link bridge path = `[S,(2,0,1),(2.5,0,3.5),(2.5,0,5.5)]`, npath=4,
pathlen `6.130649`, `types=[0,0,1,0]`, link RID at index 2.
Gated/no-link bridge path = `[S,(2,0,1),(2.5,0,4.0)]` (clamped),
pathlen `4.622520`, `reachable=false`.

`distance_to_target` never discriminates any gate: it stays Euclidean to the
raw target (`3.605551` shortcut / `5.385165` bridge) — invariant control.

| arm (preset sketch) | link cfg | predicted path / types | next | final | reachable | gate observable through |
|---|---|---|---|---|---|---|
| `link_shortcut` | server, defaults | 4-pt link path, types `[0,1,0,0]` | (1.5,0,0.5) | (2.5,0,3.5) | true | baseline |
| `link_layers_mismatch` | `layers:2`, agent=1 | corridor 3-pt, types `[0,0,0]`, nlink=0 | (2,0,1) | (2.5,0,3.5) | **true** | path array, next, types, rids — NOT reachable |
| `link_layers_match` | `layers:2`, agent_layers=3 | link path (restored) | (1.5,0,0.5) | (2.5,0,3.5) | true | same — proves bitmask match, not equality |
| `link_oneway_fwd` | `bidirectional:false` | link path | (1.5,0,0.5) | (2.5,0,3.5) | true | same |
| `link_oneway_rev` | `bidirectional:false`, a=(2.5,0,3.0) b=(1.5,0,0.5) | corridor 3-pt, nlink=0 | (2,0,1) | (2.5,0,3.5) | **true** | path array, next, types, rids |
| `link_disabled` | `enabled:false` | corridor 3-pt, nlink=0 | (2,0,1) | (2.5,0,3.5) | **true** | path array, next, types, rids |
| `link_bridge` (ctrl) | island, server | 4-pt link path, types `[0,0,1,0]` | (2,0,1) | (2.5,0,5.5) | **true** | baseline |
| `link_bridge_nolink` | island, no link | clamped 3-pt | (2,0,1) | (2.5,0,4.0) | **false** | reachable + final + path |
| `link_bridge_layers` | island, `layers:2`, agent=1 | = nolink control | (2,0,1) | (2.5,0,4.0) | **false** | additionally reachable, final |
| `link_bridge_oneway_rev` | island, bidir=false reversed | = nolink control | (2,0,1) | (2.5,0,4.0) | **false** | same |
| `link_bridge_disabled` | island, `enabled:false` | = nolink control | (2,0,1) | (2.5,0,4.0) | **false** | same |
| `link_pop_bank` | island, `pdd:2.0` | link path; **idx=2** | **(2.5,0,3.5)** near bank | (2.5,0,5.5) | true | idx/next |
| `link_pop_void` | island, `pdd:4.03` | link path; **idx=3** saturated | **(2.5,0,5.5)** far bank across void z(4,5) | (2.5,0,5.5) | true | idx/next — pop-through pin |
| `link_node_owners` | `mode:"node"` | 4-pt link path | (1.5,0,0.5) or bridge variant | T | true | `owners[i]` = valid ObjectID resolving to `NavigationLink3D` (server link: all 0) |

Pop-through bracket (measured r73, bridge): pdd `3.605` → idx=2,
next=near bank; pdd `3.606` → idx=3, next=far bank. Threshold =
euclid(S→linkstart)=`3.605551`; strict `<` pop rule consistent.
A bridge + nolink + pdd `4.1` arm additionally pins
`is_navigation_finished=true` via the unreachable clause (euclid→clamped
final `4.031129`) — ties gates to the r71/r72 finish semantics.

---

## (3) Companion-array API on this binary — verified names

Receipt: `corpus/live/r73-scout/scratch/api_verify.gd` →
`runs/api_verify.stdout.txt` (exit 0). ClassDB values measured, not doc-derived:

- Agent surface: `NavigationAgent3D.path_metadata_flags` — int property,
  hint FLAGS, hint_string `"Include Types,Include RIDs,Include Owners"`.
  **Default = 7 (ALL) on this build** — companion arrays are populated
  unless explicitly narrowed; the "opaque" arm needs `meta=0` set
  explicitly, not merely omitted. Setters `set_path_metadata_flags` /
  `get_path_metadata_flags` exist.
- Enum constants live on **`NavigationPathQueryParameters3D`** (enum
  `PathMetadataFlags`): `PATH_METADATA_INCLUDE_NONE=0`, `TYPES=1`,
  `RIDS=2`, `OWNERS=4`, `ALL=7`. They are **MISSING** on
  `NavigationAgent3D` and `NavigationPathQueryResult3D` (measured) — the
  r72 probe's `MISSING` rows were a wrong-class lookup, now resolved.
- Companion arrays hang off the result object, not the agent:
  `agent.get_current_navigation_result()` → `NavigationPathQueryResult3D`:
  - `get_path()` → PackedVector3Array (same content as
    `get_current_navigation_path()`)
  - `get_path_types()` → PackedInt32Array (ret type 30)
  - `get_path_rids()` → Array (28) of RID
  - `get_path_owner_ids()` → PackedInt64Array (31) of ObjectID
  - `get_path_length()` → float
- Segment enum on `NavigationPathQueryResult3D`:
  `PATH_SEGMENT_TYPE_REGION=0`, `PATH_SEGMENT_TYPE_LINK=1`.
  Measured semantics: `types[i]==LINK` marks the index where the hop
  **starts** (segment path[i]→path[i+1]); the far endpoint is REGION.
- Per-bit gating (measured): flags 1 → only `types` filled; 2 → only
  `rids`; 4 → only `owners`; 7 → all; 0 → all three **empty** while the
  path itself is fully populated — the exact claim-(a) discriminant.
- Link authoring, both routes headless-verified:
  - server: `NavigationServer3D.link_create`, `link_set_map`,
    `link_set_start_position`, `link_set_end_position`,
    `link_set_bidirectional`, `link_set_enabled`,
    `link_set_navigation_layers`, `link_set_enter_cost`,
    `link_set_travel_cost`, `link_set_owner_id`, `link_get_iteration_id`,
    `link_get_map`; map-level `map_set/get_link_connection_radius`
    (default `1.0`), `map_get_links`. Defaults measured on a fresh RID:
    enabled=true, bidirectional=true, layers=1, enter=0.0, travel=1.0.
  - node: `NavigationLink3D` — props `enabled`, `bidirectional`,
    `navigation_layers`, `start_position`, `end_position`,
    `enter_cost`, `travel_cost`; `get_rid`, `set/get_navigation_map`,
    `set/get_global_start_position`, `set/get_global_end_position`.
    Identical measured defaults. `rids[i]` carries the same RID as
    server mode; `owners[i]` carries a valid ObjectID resolving via
    `instance_from_id` to the `NavigationLink3D` (server-authored links
    report `0` unless `link_set_owner_id` is used).
- Agent gate knob: `agent.navigation_layers` (LAYERS_3D_NAVIGATION
  bitmask, default 1) — link traversal requires link.layers &
  agent.layers != 0 while the agent must still match the region's
  layers (default 1). `agentlayers=3` vs link `layers=2` restores the
  link: it is a bitmask AND, not equality.

---

## (4) `enter_cost` vs `travel_cost` arm pair

The r72 anomaly re-measured on this build, identical:

| arm | link cfg | measured route | PASS pins |
|---|---|---|---|
| `link_cost_enter` | shortcut, server, `enter_cost:10` | **link path** (4-pt, types `[0,1,0,0]`, pathlen 4.192582) | enter_cost=10 does NOT gate route selection |
| `link_cost_enter_hi` | same, `enter_cost:100` | link path (identical tuple) | anomaly is not a magnitude problem: 100 ≈ 24× total route cost, still chosen |
| `link_cost_travel` | same, `travel_cost:10` | **corridor** (3-pt, types `[0,0,0]`, pathlen 4.130649) | travel_cost IS live — link hop repriced, corridor wins |
| `link_cost_travel_lo` (optional bound) | `travel_cost:0.1` | link path | live-ness spans the axis both directions |

The pair's discriminative content: identical geometry, identical cost
figure `10` — `enter_cost` inert, `travel_cost` flips the route. A flat
additive enter_cost of 10–100 cannot coexist with the observed route;
if a future build applies it, `link_cost_enter` measures the corridor
and fails honestly (falsification path). Optional battery-convention
negative (mirrors `--assert-pathsum`): a `--assert-costgate` style arm
authored with the wrong hypothesis ("enter_cost=10 ⇒ corridor") exits 2
with `NEGATIVE REJECTED` when the link is still chosen.

Adjacent measured caveat to pin or footnote: at default costs the link
route (`pathlen 4.192582`) is preferred over the shorter corridor
(`4.130649`) — the engine's internal route cost is not the post-funnel
path sum; polygon-hop cost internals unprobed.

---

## Confidence and remaining unknowns

High confidence (re-executed on r73, byte-identical to r72 receipts):
both authoring routes, all three gates (layers-mismatch, oneway-reverse,
disabled), companion-array names/defaults/flag gating, pop-through
bracket, enter/travel divergence.

Observed-but-unexplained (anomalies to pin, not explain): `enter_cost`
inertness at 10 and 100; default-cost preference for the longer link
route.

Gaps (unprobed, flag if the author needs them):
- `link_connection_radius` (default 1.0) endpoint-snap tolerance — all
  authored endpoints sit strictly interior to polygons.
- Whether `link_set_owner_id` on a server link surfaces in
  `owners[i]` (API exists; server links report 0 without it).
- `is_target_reachable` is gate-discriminating only on bridge geometry;
  on shortcut it stays true under every gate (by design of the fixture).
- Link behavior under `path_postprocessing` EDGECENTERED (r72: region
  legs reshape, link segment intact, duplicated final point — unpinned).
- Whether a mid-walk map/link mutation re-queries the path (r72 found
  only `target_position` re-assignment re-queries).

## Receipts index (this lane)

- `corpus/live/r73-scout/scratch/api_verify.gd` sha256 `1e388758…` →
  `runs/api_verify.stdout.txt` (exit 0)
- `corpus/live/r73-scout/scratch/navagent3d_link.gd` sha256 `2552a5b0…`
  (verbatim r72 prototype) → `runs/v_*.stdout.txt`, 20 arms all exit 0;
  tight pop bracket `runs/v_bridge_pdd_{3.605,3.606}.stdout.txt`
- r72 receipts reused as cross-check:
  `corpus/live/r72-boundary/runs/link_*.stdout.txt` (52 runs)
- Report-only lane: nothing tracked was modified; seeds untouched.
