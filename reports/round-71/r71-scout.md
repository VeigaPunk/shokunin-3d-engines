# r71 scout — NavigationAgent3D.path_postprocessing API map + per-value outcome table

Seat: scout (recon only, leaf). Lane axis-move: **depth** — resolve whether
`path_postprocessing` changes the r70-established Euclidean `distance_to_target`
semantics. Declared claim: `{edgecentered, none}` leave `distance_to_target`
Euclidean-invariant while changing `get_next_path_position`/`get_final_position`
outputs; a changed distance under any value falsifies it.

Host/engine: `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`, physics 60 tps,
map cell_size 0.25. All numbers below are engine-measured in own scratch
(`corpus/live/r71-scout/`), not doc-inferred. Paths lane-repo-relative.

## Headline — declared claim CONFIRMED in recon (with one sharpening)

`distance_to_target` = **3.605551 (Euclidean to raw `target_position`) under all
three postprocessing values** on the r70 L-corridor. The invariance claim is
measured-intact. Sharpening: `get_final_position` is also postprocessing-*invariant*
on every arm measured (stays (2.5,0,3.5) on detour, (2,0,3) on the off-mesh arm) —
the outputs that actually change are `get_next_path_position` and the
path array/length. If the author asserts `final` changes under postproc, that
sub-expectation is falsified by measurement; the author's in-flight diff
correctly pins `final` *unchanged*.

## Per-value outcome table (measured, detour geometry)

Geometry: `corpus/fixtures/navagent3d_detour.gd:50-55` verbatim — A1 x[0,2]z[0,1],
A2 x[2,3]z[0,1] (shared x=2 edge), B x[2,3]z[1,4] (shared z=1 edge).
S=(0.5,0,0.5) → T=(2.5,0,3.5). Receipts `runs/postproc_detour.{stdout,exit}`.

| `path_postprocessing` | `distance_to_target` | `get_next_path_position` | `get_final_position` | path (agent = `query_path`) | pathlen | reachable/reached/finished |
|---|---|---|---|---|---|---|
| 0 CORRIDORFUNNEL (default) | **3.605551** | (2,0,1) | (2.5,0,3.5) | 3 pts: (2,0,1) corner | 4.130649 | true/false/false |
| 1 EDGECENTERED | **3.605551** | (2,0,0.5) | (2.5,0,3.5) | 4 pts: (2,0,0.5),(2.5,0,1) edge midpoints | 4.707107 | true/false/false |
| 2 NONE | **3.605551** | (2,0,0.5) | (2.5,0,3.5) | 4 pts: (2,0,0.5),(2,0,1) portal midpoint then corner | 4.549510 | true/false/false |

Hand-derived check: edgecentered = 1.5+√0.5+2.5 = 4.707107; none =
1.5+0.5+√6.5 = 4.549510 — measurements explain, not just record.
`pidx=1` on every arm (index 0 is the spawn point).

**Discrimination warning for the arms:** `next` is *identical* under
edgecentered and none — (2,0,0.5) both times. The two modes are only separable
by `path[2]` ((2.5,0,1) vs (2,0,1)) or `pathlen` (4.707107 vs 4.549510 —
gap 0.157597 ≈ 39× the 0.004 DIST_TOL). An arm asserting only `next`
cannot tell which postproc applied; the author's pathlen pin discriminates.

`--straight` control arm (single convex 4x4 poly, (1,0,1)→(3,0,3)):
**all three postproc values produce byte-identical output** — dist 2.828427,
path(2) direct, next=T, len 2.828427 (receipt `runs/postproc_straight.*`).
Single polygon has no portals to postprocess — the straight arm reproduces
r69's coincidence but **cannot discriminate postproc application**; only the
multi-poly detour geometry can.

Off-mesh secondary arm (S=(0.5,0,0.5) → T=(1.5,0,3.0) dead void, receipt
`runs/postproc_offmesh.*`): distance stays Euclidean to raw T at **2.692582**
under all three values; `final` clamps to (2,0,3) under all three; paths differ
(funnel via vertices (2,0,0),(2,0,1): len 4.581139; edgecentered (2,0,0.5),(2.5,0,1):
4.268660; none (2,0,0.5),(2,0,1): 4.000000); `reachable=true` throughout
(euclid(final,T)=0.5 < tdd 1.0 — consistent with r70's measured radius rule).

## API surface on this build (ClassDB-measured + extension_api dump)

Receipt: `runs/api_surface.stdout.txt`, `runs/navagent_api_extract.json`
(sha `fab7045a…`; extracted from `--dump-extension-api-with-docs`, dump
aborted post-write exit 134 — JSON complete and parsed).

### The constant trap (author-facing, measured)

`NavigationAgent3D` carries **zero enums/constants** on this build
(`ClassDB.class_get_enum_list` → `[]`, extract `enums: []`). Static access is a
parse-time kill: `NavigationAgent3D.PATH_POSTPROCESSING_EDGECENTERED` →
`Parse Error: Cannot find member "PATH_POSTPROCESSING_EDGECENTERED" in base
"NavigationAgent3D"`, script fails to load (receipt `runs/const_probe.*`,
exit 1). The `PathPostProcessing` enum lives on
**`NavigationPathQueryParameters3D`**: `PATH_POSTPROCESSING_CORRIDORFUNNEL=0`,
`PATH_POSTPROCESSING_EDGECENTERED=1`, `PATH_POSTPROCESSING_NONE=2`
(measured constants — receipt `runs/knobs.stdout.txt` first lines).
Setting it: `agent.path_postprocessing = <int>` (property is plain `int`,
hint_string `Corridorfunnel,Edgecentered,None`, default 0) — raw ints work;
the typed constant must come from `NavigationPathQueryParameters3D`.
The author's in-flight diff uses exactly this (fixture :81-84).

### Agent property defaults (live instance, `runs/api_surface.stdout.txt`)

| property | default | note |
|---|---|---|
| `path_postprocessing` | 0 | enum-hinted int; set BEFORE `target_position` (see gotcha 1) |
| `path_metadata_flags` | **7** (INCLUDE_ALL) | TYPES=1 RIDS=2 OWNERS=4; feeds `get_current_navigation_result()` |
| `path_max_distance` | **5.0** | max deviation from ideal path before repath (doc'd), unprobed |
| `path_desired_distance` | 1.0 | waypoint reach radius |
| `target_desired_distance` | 1.0 | reach-gate radius (r70 F3 semantics) |
| `path_height_offset` | 0.0 | y-offset subtracted from path positions |
| `pathfinding_algorithm` | 0 | ASTAR only (enum) |
| `simplify_path` | false | see gotcha 2 — collapses bend witness at eps≥~0.97 |
| `simplify_epsilon` | 0.0 | RDP tolerance in world units |
| `path_return_max_length` | 0.0 | clips returned path by length (0=off) |
| `path_return_max_radius` | 0.0 | clips returned path by radius from start |
| `path_search_max_polygons` | 4096 | A* search cap |
| `path_search_max_distance` | 0.0 | A* search distance cap |

### Companion surface (new — worth a future depth move)

`NavigationPathQueryParameters3D` mirrors the same path knobs plus
`map`/`start_position`/`target_position`/`excluded_regions`/`included_regions`
(RID arrays)/`metadata_flags` (named without `path_` prefix).
`NavigationServer3D.map_get_path` is **capped at 5 args** on this build —
no query-parameters arg (parse error measured). The parameterized entry is
`NavigationServer3D.query_path(qp, qr)` — **synchronous**, fills a passed
`NavigationPathQueryResult3D` (NOT a callback: arg-2 typed `NavigationPathQueryResult3D`,
parse error when passed a Callable — measured). `query_path` output matched the
agent path byte-for-byte under all three postproc values. `metadata_flags=7`
then `get_current_navigation_result()` yields `path_types=[0,…]` (all
PATH_SEGMENT_TYPE_REGION), `path_rids` all the region RID, `path_owner_ids=[0,…]`.

## Fixture map for reuse — `corpus/fixtures/navagent3d_detour.gd`

Working tree already carries the r71 author's amendment (uncommitted,
sha `5b873cd0…` vs committed `669c539d…`; runner +6 lines, two CASES rows).
Line numbers below are the **working-tree** file (182 lines):

- :35-36 straight/assert flags; **:50-51** new `post_edge`/`post_none` flags.
- :37-40 map_create/active/cell_size; :44-48 `--straight` single-poly control;
  :49-55 detour 3-quad mesh.
- :56-59 region bind; :60-64 actor+agent+`set_navigation_map`.
- **:81-84** `agent.path_postprocessing = NavigationPathQueryParameters3D.PATH_POSTPROCESSING_{EDGECENTERED,NONE}` — correctly positioned **before**
  :85 `agent.target_position = target` (load-bearing order, gotcha 1).
- :88-94 query order preserved: `get_next_path_position` then
  `get_current_navigation_path` (lazy-path ordering, r70 F4), then distance/final.
- :97-115 `--straight` arm (exit 2, unchanged); **:125-145** new postproc gate:
  `semantic=="euclidean"` required else `invariance falsified`/`bounded UNKNOWN`
  diagnostic; `path.size()==4`, `next≈(2,0,0.5)`, `pathlen≈4.707107`/`4.549510`,
  `final≈(2.5,0,3.5)`, `reachable`, `reached/finished` false — then
  `PASS … post_edgecentered|post_none …` exit 0.
- :147+ original detour gate unchanged (path.size()==3, next≈(2,0,1),
  pathlen≈4.130649 — only reachable on the corridorfunnel default, correctly
  bypassed by the post arms' early return at :125-145).

## Scout replay of the author's in-flight arms — byte-exact

Copied working-tree fixture to `scratch/author_detour.gd` (sha `5b873cd0…`,
identical to working file) and ran all five arms headless:

| arm | exit | stdout (verbatim, matches CASES marker) |
|---|---|---|
| `--post-edgecentered` | 0 | `PASS navagent3d_detour post_edgecentered distance=3.605551 semantic=euclidean final=2.500,0.000,3.500 next=2.000,0.000,0.500 pathlen=4.707107 reachable=true reached=false finished=false` |
| `--post-none` | 0 | `PASS navagent3d_detour post_none distance=3.605551 semantic=euclidean final=2.500,0.000,3.500 next=2.000,0.000,0.500 pathlen=4.549510 reachable=true reached=false finished=false` |
| (default) | 0 | `PASS navagent3d_detour distance=3.605551 … pathlen=4.130649 …` (unchanged) |
| `--straight` | 2 | `NEGATIVE REJECTED: … discriminates=false` (unchanged) |
| `--assert-pathsum` | 2 | `NEGATIVE REJECTED: … expected_pathsum=4.130649 euclid=3.605551` (unchanged) |

Receipts `runs/author_{xpostedgecentered,xpostnone,x,xstraight,xassertpathsum}.{stdout,stderr}.txt` + `.exit`.
The author's measured constants agree with this scout's independent probe
to all six decimals — convergent before verifier replay.

## Measured gotchas (calibration-grade)

1. **`path_postprocessing` does NOT requery a cached path.** Agent at funnel
   with path computed: set `path_postprocessing=1`, wait 10 frames → `next`
   stays (2,0,1). Re-set `target_position` to the *same* value → re-query,
   `next` becomes (2,0,0.5) (receipt `runs/knobs.stdout.txt` livechange lines).
   Set the property **before** `target_position` (author does, fixture :81-85)
   or the arm silently measures the default. Matches doc text:
   `get_current_navigation_path` "only updates when the target position is
   changed or the agent requires a repath."
2. **`simplify_path` destroys the bend witness.** On detour geometry eps≤0.1
   leaves all paths unchanged; **eps=1.0 collapses funnel path to 2 points,
   len 3.605551** — the pathlen−euclid>0.4 margin and `next=(2,0,1)` pins
   both fail. Keep `simplify_path` at default false in any postproc arm.
   (eps=0.1 under none already drops (2,0,1) → len 4.541381.)
3. **edgecentered vs none is invisible to `next`** on this geometry — both
   (2,0,0.5); discriminate via `path[2]`/`pathlen` only (author does).
4. **`final` is postproc-invariant** on reachable and clamped arms alike —
   don't assert it changes; it only reflects the corridor's reachable end.
5. `query_path` arg-2 is a result object (synchronous), not a callback;
   `map_get_path` takes ≤5 args (no parameter overload) — measured parse errors.

## Honest bounds / retained UNKNOWNs

- All measured on one build (`4.7.2.stable.arch_linux`), stationary agent at
  path start, hand-authored navmesh, `navigation_layers=1`, default
  `pathfinding_algorithm` (ASTAR). No moving-agent, avoidance, baked-region,
  link (`PATH_SEGMENT_TYPE_LINK`), `excluded_regions`, `path_return_max_*`
  clipping, or `path_search_max_*` exhaustion evidence — the QParams surface
  is mapped but only postproc/metadata_flags are measured here.
- Whether `path_postprocessing` also leaves `is_target_reachable`/`reached`
  invariant under a *blocking* geometry with raised `target_desired_distance`
  (r70 F3 regime) is unprobed; reach gates stayed true/false/false on all
  reachable arms measured here.
- `path_max_distance` (default 5.0) semantics doc'd but not measured.

## Artifact index

- Report: `reports/round-71/r71-scout.md` (this file)
- Scratch project: `corpus/live/r71-scout/scratch/` (`project.godot` copy +
  `api_surface.gd`, `postproc_probe.gd`, `knobs_probe.gd`, `const_probe.gd`,
  `author_detour.gd`; probe shas `runs/probe_shas.txt`)
- Receipts: `corpus/live/r71-scout/runs/` — `api_surface.stdout.txt`,
  `postproc_{detour,straight,offmesh}.stdout.txt` + `.exit`,
  `knobs.stdout.txt`, `const_probe.{stdout,stderr}.txt`,
  `author_*.stdout.txt` + `.exit`, `navagent_api_extract.json` (64 KB,
  class docs extracted from `--dump-extension-api-with-docs`).
- Commands: `timeout 60|90 /usr/bin/godot --headless --path corpus/live/r71-scout/scratch --script res://<script>.gd -- [arm]`

No git write ops, no sibling-scope writes, no tracked-file edits.
