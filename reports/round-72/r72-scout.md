# r72 scout — pdd pop-index vs agent position + two-mode is_navigation_finished, edge-measured

Seat: scout (recon only, leaf — no dispatch). Lane axis-move: **depth** —
formalize `path_desired_distance` (pdd) waypoint-pop semantics and the two-mode
`is_navigation_finished` the r71 boundary seat measured. Declared claim: pin pdd
pop-point index vs agent-position as tracked arms on the L-corridor plus the two
finish modes with equality-edge cases (euclid exactly == tdd reachable vs
unreachable).

Host/engine: `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`, physics 60 tps,
map cell_size 0.25. All numbers below are engine-measured in own scratch
(`corpus/live/r72-scout/`, probe sha `8b3281cc…`, project.godot sha
`1fda90d4…` byte-identical to `corpus/fixtures/project.godot`), 43 arms, all
exit 0, all stderr empty. Paths lane-repo-relative.

## Headline — both gates are STRICT `<`, measured at exactly-representable constants

- **Waypoint pop:** advance `path_index` while `idx < size-1` AND
  `euclid(agent_origin → path[idx]) < pdd`. At the engineered exact edge
  `pdd=1.5` vs waypoint `euclid=1.500000` (postproc `none`/`edgecentered`
  midpoint (2,0,0.5)) it does **NOT** pop — `pdd=1.51` does. Resolves
  r71-boundary's "inclusive-ish" caveat: the earlier `pdd=1.581139` pop was
  float rounding — true `√2.5 = 1.58113883… < 1.581139` parsed.
- **Unreachable finish:** `euclid(agent → clamped final) < pdd` STRICT —
  `pdd=2.5` vs `euclid_final=2.500000` → `finished=false`; `pdd=2.6` → true.
  Confirmed twice (t3 2.5-edge, t2 0.5-edge). Index saturation at `size-1` is
  **not** sufficient (pdd=2.0: idx=3, finished=false).
- **Reachable finish:** `euclid(agent → raw T) < tdd` STRICT — `tdd=2.0` vs
  `euclid=2.000000` → `finished=false`; `tdd=2.1` → true (t2). Same for gap2
  `tdd=2.5`/`2.5` (boundary) and t3 `tdd=2.0`/`2.022375` → false.
- **Selector:** `is_target_reachable` = `euclid(final → T) ≤ tdd` INCLUSIVE —
  `tdd=1.2` vs `gapfinal=1.200000` → `reachable=true`; `1.19` → false (t3).
- **Full measured model:** `finished = (euclid(agent→T) < tdd) OR
  (reachable==false AND euclid(agent→final) < pdd)`. Reached fires even on
  unreachable targets (boundary gap2 tdd=2.7); reachable mode makes finished
  **pdd-immune** — pdd=5.0 with idx saturated and `euclid_final < pdd` still
  yields `finished=false` (measured 3×: `t3_pdd5_tdd{1.4,1.5}`, `t2_pdd5_tdd1.5`,
  detour ctl pdd=5.0).
- **Non-monotone selector flip (new pin):** same geometry, pdd=3.0 —
  `tdd=1.19` → `reachable=false finished=true`; `tdd=1.20` →
  `reachable=true finished=false`. `finished` goes true→**false** as tdd
  crosses the reachable boundary upward. The two-mode selector in one
  contrast pair.

## Property surface on this build (settable names, defaults, readback-verified)

| property | type | default | evidence |
|---|---|---|---|
| `path_desired_distance` | float | 1.0 | probe sets `agent.path_desired_distance = pdd`, readback `absf(…)≤0.0001` (scratch :107, :128); same in r71-boundary `navagent3d_meta_pdd.gd:67`; r71-scout default table |
| `target_desired_distance` | float | 1.0 | tracked `navagent3d_distance.gd:37`; probe :108; `meta_pdd.gd:68` |
| `path_postprocessing` | int (enum hint) | 0 | detour :81-84 via `NavigationPathQueryParameters3D.PATH_POSTPROCESSING_*` |
| `path_metadata_flags` | bitmask | 7 | `meta_pdd.gd:66` |
| `target_position` | Vector3 | — | detour :85 |

Order discipline (boundary + author verified): set knobs **before**
`agent.target_position` — `path_postprocessing` does not requery a cached path
(r71-scout gotcha 1). pdd/tdd were always set pre-target here; post-target
setter timing unprobed (not needed by the claim).

## Fixture map — `corpus/fixtures/navagent3d_detour.gd` (182 lines, sha `5b873cd0…`, committed HEAD `996ea37`)

- Geometry `:57-70`: L-corridor 3 quads — A1 x[0,2]z[0,1], A2 x[2,3]z[0,1]
  (shares x=2 edge), B x[2,3]z[1,4] (shares z=1 x[2,3] edge). `spawn`/`target`
  are local vars at `:57-58` — override points for spawn/target arms sit
  exactly there (precedent: `--straight` overrides both `:62-63`).
- Setup `:71-85`: region bind; `actor.position=spawn` :76; agent childed;
  `set_navigation_map` :80; postproc flags :81-84; `target_position` :85.
  New `agent.path_desired_distance`/`target_desired_distance` setters land
  at :80-84, before :85.
- Settle/query `:86-97`: 30 physics frames; `get_next_path_position` :88,
  `get_current_navigation_path` :89, distance/final/reached/finished :93-97.
- Flag parsing `:48-51` (`OS.get_cmdline_user_args`); float-value flags need
  an `_argval` helper — copy r71-boundary `meta_pdd.gd:19-23` verbatim.
- **idx pinning requirement:** `get_current_navigation_path_index()` must be
  read AFTER a forcing `get_next_path_position` — pre-force idx is stale 0
  and path empty (`npath=0/N` on all 43 arms). `next` is idempotent
  (`next2==next`, idx stable) — `meta_pdd.gd:75-87` is the proven read order.
- Marker contract (`run_battery.py:8-12`): exit 0 + exact `PASS …` line, or
  exit 2 + `NEGATIVE REJECTED: …`; stderr must be empty; timeout 20 s/case.
- CASES rows `run_battery.py:34-242`; navagent3d_detour block `:51-60`;
  battery currently 90 rows (45 pos/45 neg) — r71 author verified all 88
  prior rows byte-stable. New rows append; `--only` runs a named subset.

## Measured arm data (all receipts `corpus/live/r72-scout/runs/*.stdout.txt`)

### Spawn-offset pop sweep (default funnel, detour target)

| arm | spawn | path | euclid→path[1] | pdd | idx after | next | reading |
|---|---|---|---|---|---|---|---|
| ctl | (0.5,0,0.5) | [S,(2,0,1),(2.5,0,3.5)] | 1.581139 | 1.0 | **1** | (2,0,1) | control (matches detour) |
| s15 | (1.5,0,0.5) | [(1.5,0,0.5),(2,0,1),(2.5,0,3.5)] | 0.707107 | 0.7 | 1 | (2,0,1) | below euclid, no pop |
| s15 | " | " | " | 0.707107 | 2 | (2.5,0,3.5) | printed-eq pops (√0.5=0.7071068 < parsed) |
| s15 | " | " | " | 1.0 | **2** | (2.5,0,3.5) | spawn +1.0x flips idx at same pdd |
| sedge | (2,0,0.5) on shared edge | [(2,0,0.5),(2.083333,0,1),(2.5,0,3.5)] | 0.506897 | 0.49/0.5 | 1 | (2.083333,0,1) | **funnel waypoint is interior, not vertex (2,0,1)** |
| sedge | " | " | " | 1.0 | 2 | (2.5,0,3.5) | pops at default |
| s25 | (2.5,0,0.5) | [(2.5,0,0.5),(2.5,0,1),(2.5,0,3.5)] | 0.5 | 1.0 | 2 | (2.5,0,3.5) | collinear portal point retained; dist=pathlen=3.0 |

### Pop strictness (postproc midpoint at exact 1.5)

| arm | euclid→path[1] | pdd | idx | next | reading |
|---|---|---|---|---|---|
| `--postproc=1 --pdd=1.49` | 1.500000 | 1.49 | 1 | (2,0,0.5) | no pop |
| `--postproc=1 --pdd=1.5` | 1.500000 | **1.5** | **1** | (2,0,0.5) | **equality: NO pop → strict** |
| `--postproc=1 --pdd=1.51` | 1.500000 | 1.51 | 2 | (2.5,0,1) | pops |
| `--postproc=2 …` | 1.500000 | 1.49/1.5/1.51 | 1/1/2 | (2,0,0.5)→(2,0,1) | identical edge under none |

### Unreachable finish edges — t3 target (0.8,0,2.5)

Measured base: `final=(2,0,2.5)` on B (B-closest 1.2 < A1-closest 1.5 — strict
margin, no tie), `euclid→T=2.022375`, `euclid_final=2.500000`,
`gapfinal=1.200000`, path 4 pts `[(0.5,0,0.5),(2,0,0),(2,0,1),(2,0,2.5)]`,
pathlen 4.081139, `reachable=false` at tdd=1.0.

| arm | reachable/reached/finished | pin |
|---|---|---|
| `--t3 --pdd=2.0` | f/f/**f** | idx=3 saturated yet not finished — "last index insufficient" |
| `--t3 --pdd=2.4` | f/f/f | below edge |
| `--t3 --pdd=2.5` | f/f/**f** | **equality → strict** (repeat byte-identical) |
| `--t3 --pdd=2.6` | f/f/**t** | unreachable finish fires |
| `--t3 --pdd=3.0 --tdd=1.19` | f/f/**t** | unreachable mode |
| `--t3 --pdd=3.0 --tdd=1.2` | **t**/f/**f** | **selector flip: finished true→false as reachable turns on** |
| `--t3 --tdd=1.19` / `--tdd=1.2` | f→**t** | reachable inclusive edge at gapfinal 1.2 |
| `--t3 --tdd=1.5` | t/f/f | reachable ⇒ pdd-immune finish (reached strict fails) |
| `--t3 --pdd=5.0 --tdd=1.5` | t/f/**f** | pdd 5.0 + idx 3 + euclid_final 2.5 < 5 — still false in reachable mode |
| `--t3 --tdd=2.0` | t/f/f | 2.022375 > 2.0, strict fails |
| `--t3 --tdd=2.1` | t/**t**/**t** | reached fires ⇒ finished |
| `--t3 --tdd=2.022375` | t/t/t | printed-eq fires (true √4.09=2.02237484 < parsed — consistent strict) |

### Reachable-mode equality + clamp-tie witness — t2 target (0.5,0,2.5)

Measured base: **`final=(0.5,0,1.0)` — clamp picked the agent-side polygon A1
in a 1.5/1.5 distance tie** (B's (2,0,2.5) equally close; path terminated
inside A1: `[(0.5,0,0.5),(0.5,0,1.0)]`, pathlen 0.5). `euclid→T=2.000000`,
`euclid_final=0.500000`, `gapfinal=1.500000`, `reachable=false` at tdd=1.0,
`finished=true` at default pdd (0.5 < 1.0).

| arm | reachable/reached/finished | pin |
|---|---|---|
| `--t2 --tdd=2.0` | t/f/**f** | **reachable-mode equality: euclid→T exactly 2.0 ⇒ strict fails** |
| `--t2 --tdd=2.1` | t/t/t | strict satisfied |
| `--t2 --pdd=0.49` / `0.5` / `0.51` | f/f/**f** / **f** / **t** | second unreachable strict edge at exact 0.5 |
| `--t2 --tdd=1.4` / `1.5` | f/f/**t** → t/f/**f** | non-monotone flip at gapfinal 1.5 |
| `--t2 --pdd=5.0 --tdd=1.5` | t/f/**f** | reachable-mode pdd-immunity (idx saturated, euclid_final 0.5<5) |

## Predicted per-arm outcome table (for author — all constants measured here)

Recommended flags, additive on `navagent3d_detour.gd` (named flags consistent
with `--straight`/`--post-*` style; `_argval` for floats):

| proposed CASES row | flags | expected exit | asserted output (measured) |
|---|---|---|---|
| `navagent3d_detour_s15_popped` | `--spawn15 --pdd=1.0` | 0 | idx=2, next=(2.5,0,3.5), dist=3.162278, pathlen=3.256617 — same pdd different spawn flips idx vs control |
| `navagent3d_detour_s15_below` | `--spawn15 --pdd=0.7` | 0 | idx=1, next=(2,0,1) — spawn-dependence needs both signs |
| `navagent3d_detour_s25_popped` | `--spawn25 --pdd=1.0` | 0 | idx=2, next=final, pathlen=dist=3.0, path keeps portal (2.5,0,1) |
| `navagent3d_detour_pop_eq` | `--post-none --pdd=1.5` | 0 | idx=1, next=(2,0,0.5) — **strict pop equality pin** |
| `navagent3d_detour_pop_above` | `--post-none --pdd=1.51` | 0 | idx=2, next=(2,0,1) — bracket pair |
| `navagent3d_detour_t3_sat` | `--t3 --pdd=2.0` | 0 | idx=3, next=(2,0,2.5), finished=false — saturate ≠ finish |
| `navagent3d_detour_t3_eq` | `--t3 --pdd=2.5` | 0 | finished=false at exact 2.5 — **strict unreachable gate** |
| `navagent3d_detour_t3_above` | `--t3 --pdd=2.6` | 0 | finished=true |
| `navagent3d_detour_t3_sel` | `--t3 --pdd=3.0 --tdd=1.19` + `--t3 --pdd=3.0 --tdd=1.2` (two rows) | 0 | finished true vs false across reachable selector — **the two-mode pin** |
| `navagent3d_detour_t3_immune` | `--t3 --pdd=5.0 --tdd=1.5` | 0 | reachable=true, finished=false — pdd-immunity |
| `navagent3d_detour_t2_eq` | `--t2 --tdd=2.0` | 0 | reachable=true, finished=false at exact 2.0 — **strict reachable gate** (+ tie-clamp witness final=(0.5,0,1.0)) |
| `navagent3d_detour_t2_above` | `--t2 --tdd=2.1` | 0 | reached=true, finished=true |
| `navagent3d_detour_t2_pop_eq` | `--t2 --pdd=0.5` | 0 | finished=false — second exact strict edge |
| `navagent3d_detour_assert_*` (negative) | e.g. `--assert-finished-inclusive --t3 --pdd=2.5` | 2 | authors `finished=true` at equality → engine refutes → `NEGATIVE REJECTED:` (precedent :153-161) |

Fixture-add notes: spawn override goes at `:57` (e.g. `--spawn15` →
`(1.5,0,0.5)`), targets at `:58`, pdd/tdd setters at `:80-84`, idx read after
the forcing getter (`meta_pdd.gd:75-87` order). Pin `idx` in the marker —
it is the discriminating output for the pop arms. Sibling-vs-additive:
additive is again cheaper (r71 author's call, +45 lines for 2 arms); ~10 rows
here justifies flags-not-sibling; a new `navagent3d_finish.gd` would
duplicate ~60 lines of setup but isolates the surface — boundary's suggested
split (`r71-boundary.md:152-160`).

## Author-facing traps (measured)

1. **Printed equality ≠ float equality.** Only engineered constants
   (0.5, 1.2, 1.5, 2.0, 2.5) are true equality edges. `pdd=1.581139` pops
   (√2.5 < parsed literal) and `tdd=2.022375` reaches — both consistent with
   strict gates at *irrational* distances. Author equality pins ONLY on the
   exact constants above.
2. **The clamp-tie trap (new).** `T=(0.5,0,2.5)` clamps to `(0.5,0,1.0)` on
   A1 — a 1.5/1.5 tie resolved toward the agent's containing polygon, path
   never reaching B. Any off-mesh arm must verify `final` by measurement and
   prefer strict-margin targets (t3: 1.2 vs 1.5). Pinning t2's
   `final=(0.5,0,1.0)` is itself a good witness — a different tie-break fails
   noisily.
3. **Funnel-from-portal-edge:** spawn exactly on the x=2 shared edge yields
   waypoint `(2.083333,0,1)` — interior portal point, not vertex `(2,0,1)` —
   and `pathlen == euclid` (3.041381). sedge arms pin a non-obvious constant;
   viable but optional.
4. **Lazy update:** `get_current_navigation_path/index` are empty/0 before a
   forcing getter; read order is load-bearing (meta_pdd :75-87). `next` is
   idempotent thereafter.
5. **reachable-mode pdd-immunity:** a reachable arm with huge pdd and
   saturated index still reports `finished=false` — do not write "pdd
   finishes the path" claims; the finish gate is mode-selected.
6. Setter-before-`target_position` discipline for all knobs (postproc proven
   stale-path; keep same order for pdd/tdd).

## Honest bounds / retained UNKNOWNs

- One build (`4.7.2.stable.arch_linux`), stationary agent at path start,
  single region, corridorfunnel except where flagged, 30-frame settle. No
  moving-agent mid-path pop evolution, avoidance, `path_max_distance`,
  `simplify_path`, baked meshes, links, or multi-region evidence.
- Strict `<` is measured at float-exact constants; ULP-adjacent values
  (`pdd` one double below `euclid`) unprobed — the model claims strictness at
  representable equality, not comparator internals.
- `(2.083333,0,1)` funnel point unexplained (portal interior point; possibly
  cell_size subdivision — 1/12 of the portal width; not vertex-mapped).
- t2's tie-clamp direction (A1 over B) is single-sample deterministic
  (repeat byte-identical) but the engine's general tie-break rule unprobed —
  that's why t3 (strict margin) carries the gate edges and t2 only the
  reachable-mode 2.0 edge + witness.
- pdd/tdd setters run pre-target here; post-target setter semantics unprobed.
- Whether `finished` uses `final` or `path[size-1]` in the unreachable gate —
  identical on all arms here (final==last path point); a geometry where they
  differ is unprobed.
- `is_target_reached` on unreachable targets was boundary-measured (gap2
  tdd=2.7 → reached=true, finished=true through-wall); re-confirmed only
  implicitly via the OR-model fits, not re-probed on t2/t3.

## Artifact index

- Report: `reports/round-72/r72-scout.md` (this file)
- Scratch project: `corpus/live/r72-scout/scratch/` (`project.godot` sha
  `1fda90d4…` copy + `navagent3d_pdd_edges.gd` sha `8b3281cc…`)
- Receipts: `corpus/live/r72-scout/runs/` — 43 arms ×
  `{stdout.txt,stderr.txt,exit}`, all exit 0, all stderr empty; each stdout
  carries one `PROBE` line with arm/pdd/tdd/spawn/target, all queried
  distances, `idx=pre/post/post2`, `next/next2`, path array, and the
  reachable/reached/finished triple. Determinism: `t3_pdd2.5_repeat`
  byte-identical to `t3_pdd2.5`.
- Commands: `timeout 60 /usr/bin/godot --headless --path
  corpus/live/r72-scout/scratch --script res://navagent3d_pdd_edges.gd --
  <flags>` (cwd lane root).

No git write ops, no tracked-file edits, no sibling-scope writes.
