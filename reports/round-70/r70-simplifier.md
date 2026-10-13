# Game-dev-3d round 70 — simplifier report (minimal-design critique, report-only)

Seat: simplifier. Judged the landed diff for `navagent3d_detour.gd` +
`run_battery.py` — geometry minimality, arm redundancy, mutation coverage.
Simplifier did not author this round. All probes ran in own write scope
(`corpus/live/r70-simplifier/`); seeds untouched. Host devin,
`/usr/bin/godot` 4.7.2.stable.arch_linux.ed1daf0bf, physics 60 tps.

Landed diff at critique time (uncommitted, per lane convention):
`?? corpus/fixtures/navagent3d_detour.gd` (137 lines),
`M corpus/fixtures/run_battery.py` exactly +6 lines = 3 CASES tuples.
Nothing else tracked touched.

## Verdict

**Design is at the minimal envelope; no deletion demanded.** One cosmetic
deletion candidate (dead constant, below). The third arm is a judgment call
that survives scrutiny — recorded, not flagged redundant.

## Geometry minimality — the floor is measured, not argued

Independent probe (`corpus/live/r70-simplifier/proj/probe.gd`, commands
`godot --headless --path proj --script res://probe.gd -- --mode=<m>`):

| candidate | observed | viable? |
|---|---|---|
| single concave L-poly (6 verts) | path straight 2-pt through the notch, `dist=5.385165=eucl`, `npts=2` | **NO** — Godot walks the poly as if convex; cannot detour. Trap geometry. |
| 2 polys, partial edge overlap | `reachable=false`, dead-ends at boundary | **NO** — hand-authored polys connect only on exact shared-edge endpoints; `edge_connection_margin` does not rescue sub-segments |
| 2 polys, corridor form (B's whole shared edge = door sub-segment of A) | connects, bends: `pts=(0.5,2)(3,4)(3.5,6)`, `pathlen=5.263115` vs `dist=5.000000` | yes, but 9 verts, asymmetric, target confined to a 1-wide corridor — not simpler |
| 3 quads, L (author's choice) | `pts=(0.5,0.5)(2,1)(2.5,3.5)`, `pathlen=4.130649` vs `dist=3.605551` | **yes — minimal regular design** |

Author's mesh: 8 pooled vertices, 3 quads, all shared edges full
(`navagent3d_detour.gd:50-55`). Two full-edge-sharing quads can never force
a bend (union is a rectangle — convex), so 3 polys is the floor among
regular tilings; the only 2-poly alternative is the corridor form, which is
not lighter. **Geometry: minimal.** Partial-edge and concave shortcuts are
proven non-functional on this build — the author avoided both.

## Arms — 3 rows vs the brief's 2

- `navagent3d_detour` (exit 0): mandated.
- `navagent3d_detour_straight` (exit 2): the mandated straight-line control.
  Reuses r69's exact 4x4 polygon and endpoints (byte-identical
  `mesh.vertices`/`add_polygon` to `navagent3d_distance.gd:24-25`; same
  (1,0,1)→(3,0,3)) — **zero novel control geometry**, and its 2.828427 is
  directly comparable to the r69 baseline. `discriminates=false` marked
  honestly. Alternative same-mesh straight variant (scout's (2.5,0,0.5);
  author's own probe `straight_lmesh` dist=2.0) would instead isolate the
  multi-poly-mesh confound — a deliberate comparability tradeoff, not a
  defect.
- `navagent3d_detour_assert_pathsum` (exit 2): the one arm beyond the
  brief's ask. Not strictly redundant — its unique coverage is
  assertion-direction mutants (in a path-sum world the positive arm exits 1
  as a *failure*; this arm exits 1 by *design intent*, and in the Euclidean
  world it records the refuted candidate as a green battery-visible
  negative: `expected_pathsum=4.130649 euclid=3.605551`). Matches the
  lane's negative-control convention that discrimination must be exercised,
  not implied. Costs ~9 fixture lines + 1 CASES row. **Justified-minimal;
  the leaner fold (drop it) would lose the recorded falsification row.**

## Mutation coverage — adequate, demonstrated (private scratch mutants)

| mutant (in `corpus/live/r70-simplifier/detour-check/`) | result |
|---|---|
| m1: target AND final-pin moved together to (2.5,0,2.5) — self-consistent re-derivation | **exit 1**, `detour path absent or unbent ... pathlen=3.162278` — hand-derived `pathlen` pin + `pathlen−euclid>0.4` gap guard catch re-derived mutants |
| m2: B polygon dropped (`get_polygon_count()` 3→2) | **exit 1**, `live navigation agent/map setup absent` — setup pin |
| m3: `DETOUR_PATHLEN` 4.130649→4.0 | **exit 1**, measured `pathlen=4.130649` vs tampered literal |

Bend-witness is multi-pinned (`path.size()==3` ∧ `next==(2,0,1)` ∧
`pathlen≈4.130649` ∧ gap>0.4): a silently-straightened geometry fails on ≥2
pins. The semantic classifier keeps a third `unknown` bucket → bounded-UNKNOWN
exit 1 instead of force-fitting — honest epistemics preserved.

## Deletion candidate (cosmetic, non-blocking)

- `const DETOUR_EUCLID := 3.605551` (`navagent3d_detour.gd:28`) is never
  referenced — classification compares the computed `euclid` var
  (`spawn.distance_to(target)`, line 79); markers print measured values.
  Documentary-only dead weight; the comment already carries the √13
  derivation. One line; deletion would not change behavior. `DETOUR_PATHLEN`
  by contrast is live (line 104). Reported, not enacted — seeds are the
  author's scope.

## Independent semantic confirmation

My probe answers the r69 UNKNOWN the same way, on different geometry:
tromino arm `dist=3.535534` = eucl while routed path len = 3.605551;
unreachable arm `dist=7.206941` = eucl to *authored target* while
`final=(4,0,4)` clamped — so the reference is `target_position`, not the
projected final. Converges with scout (3.605551 vs 4.130649), scribe
(5.0 vs 6.085044 incl. off-mesh arm), and the author's own probe.
**`distance_to_target` is Euclidean to the authored target** on this build.

## Contract preserved

Exit/marker convention (0 PASS / 2 NEGATIVE REJECTED / 1 fail), setup-pin
block, full-RID cleanup incl. map (`owned.append(map)` line 38 — the
critic-flagged leak trap dodged), lazy-path ordering
(`get_next_path_position` line 69 before `get_current_navigation_path`
line 70), 30-frame settle, `call_deferred` pattern — all consistent with
the `navagent3d_*` family. Exact stdout markers bound in CASES match
observed output byte-for-byte.

## Evidence index

- Arms reproduced verbatim: `PASS navagent3d_detour distance=3.605551
  semantic=euclidean ... pathlen=4.130649` (exit 0), `NEGATIVE REJECTED:
  ... straight distance=2.828427 ...` (exit 2), `NEGATIVE REJECTED:
  ... assert_pathsum ...` (exit 2) — run in `detour-check/` scratch copy.
- Focused classifier run: `python3 run_battery.py --godot /usr/bin/godot
  --runs <abs r70-simplifier>/runs --only
  navagent3d_detour,navagent3d_detour_straight,navagent3d_detour_assert_pathsum`
  → 3/3 PASS, exits 0/2/2; receipt
  `corpus/live/r70-simplifier/runs/20261013T221745766802Z/verdicts.json`.
- Mutant exits verified with real codes (m1/m2/m3 → 1/1/1).
- Probe/mutant scripts + outputs under `corpus/live/r70-simplifier/`.

## Scope notes

- No full-battery or Node suite run — verifier's scope, not mine; baseline's
  pre-diff 85/85 and author's claimed post-diff 88/88 stand unreplicated
  here.
- `DETOUR_EUCLID` is the only deletion candidate found; everything else on
  the diff earns its weight. Next deletion would harm an axis — stopping.
