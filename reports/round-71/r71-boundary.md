# Game-dev-3d round 71 — boundary (revenger): path_metadata_flags + path_desired_distance recon

Seat: boundary (role revenger). Scope: scratch-only under
`corpus/live/r71-boundary/`; no tracked edits, no commits, leaf — no
dispatch. Lane's declared axis-move (depth) is owned by other seats: whether
`path_postprocessing` {edgecentered, none} leaves `distance_to_target`
Euclidean-invariant. My assignment is recon for the NEXT depth surface:
(a) `path_metadata_flags` — do the returned path arrays carry per-point
metadata that changes next-path semantics under postprocessing?
(b) the r70 reach-gate boundary — r70 critic found `reached`/`finished`
firing through walls at large `target_desired_distance` on a Euclidean
basis; probe whether `path_desired_distance` uses the same Euclidean basis
or path-sum, on discriminating geometry.

## Deliverable and method

`corpus/live/r71-boundary/scratch/navagent3d_meta_pdd.gd`, sha256
`a7b4d9ac574be13691961cdc62bbeba4ac4f50bede61c83fc0389c987442595c`, plus a
verbatim copy of the seed `project.godot` (sha256
`1fda90d46b0529aea0e75710a64f038cbf983adc8385285dd8bbe6202a8eac23`,
byte-identical to `corpus/fixtures/project.godot`). One SceneTree script,
flag-parameterized; every arm emits one `PROBE` line, exit 0 (exit 1
reserved for live-setup failure — never triggered).

Geometry: the tracked `navagent3d_detour.gd` L-corridor verbatim — quads
A1 x[0,2]z[0,1], A2 x[2,3]z[0,1], B x[2,3]z[1,4] joined by exact shared
edges; spawn S=(0.5,0,0.5). Targets: default T=(2.5,0,3.5) (euclid √13 =
3.605551, routed path via vertex (2,0,1) sums 4.130649); `--gap`
T=(1.5,0,3.0) off-mesh dead angle (clamped final (2,0,3), euclid
final→T = 0.5); `--gap2` T=(0.5,0,3.0) further off-mesh (same clamped
final (2,0,3), euclid final→T = 1.5 — properly unreachable at default
tdd). Gap arms route S→(2,0,0)→(2,0,1)→(2,0,3), pathlen 4.581139,
euclid(S→final) 2.915476.

Command per arm (cwd `corpus/live/r71-boundary/`):
```
timeout 60 /usr/bin/godot --headless --path scratch \
  --script res://navagent3d_meta_pdd.gd -- <flags>
```
Godot `4.7.2.stable.arch_linux.ed1daf0bf` via `/usr/bin/godot`. 32 runs,
all exit 0, stderr = engine banner only (verified `grep -v` across all
`runs/*.stderr.txt`); receipts `runs/<arm>.{stdout.txt,stderr.txt,exit}`.
Determinism: `gap2_pdd3.0` repeated — stdout byte-identical.

## (a) path_metadata_flags — measured answers

`path_metadata_flags` is a per-bit gate on companion arrays of
`NavigationPathQueryResult3D` (via `get_current_navigation_result()`;
there is no `get_current_navigation_path_*` getter on the agent — first
draft of the probe failed on that, fixed):

| flag bit | array (type) | content observed |
|---|---|---|
| 1 (TYPES) | `get_path_types()` PackedInt32Array | `[0,…]` per point — all `PATH_SEGMENT_TYPE_REGION` |
| 2 (RIDS) | `get_path_rids()` Array[RID] | every entry `==` our single region RID |
| 4 (OWNERS) | `get_path_owner_ids()` PackedInt64Array | all `0` — invalid ObjectIDs (pure-server regions own no Object) |

- Bits act independently: `--meta=1` fills types only, `--meta=2` rids
  only, `--meta=4` owners only, `--meta=7` all three, `--meta=0` all
  empty. Arrays align 1:1 with path points (3 pts → 3 entries; 4 pts → 4).
- Under postprocessing sweeps the metadata stays semantically flat:
  uniform REGION type and the same region RID on every point of every
  arm; only the array LENGTH follows the point count. The next-position
  change under postproc is carried entirely in the point array — the
  metadata neither differs by postprocessing nor participates in
  `get_next_path_position` semantics on this geometry.
- Same flat metadata on the unreachable arm (`--gap2 --meta=7`: 4×
  type=0, 4× region RID on the clamped path).
- Answer: YES, the path result carries per-point metadata as three
  parallel arrays; NO, it does not change next-path semantics under
  postprocessing — it is descriptive annotation (segment type, owning
  RID/owner per waypoint). A discriminating surface for it would need
  off-mesh links (type `PATH_SEGMENT_TYPE_LINK`); none authored here.

## (b) path_desired_distance — basis and the two-mode finish gate

Waypoint-advance gate (all postproc=0 unless noted):

| arm | euclid→next | idx after | finished | reading |
|---|---|---|---|---|
| pdd=1.0 (default) | 1.581139 | 1 | false | below waypoint dist, no pop |
| pdd=1.581 | 1.581139 | 1 | false | just below |
| pdd=1.581139 | 1.581139 | 2 | false | exact printed value pops (inclusive-ish boundary) |
| pdd=1.6 / 2.0 / 3.0 / 3.8 / 4.1 | — | 2 | false | popped to final waypoint |
| pdd=4.14 / 5.0 | — | 2 | false | idx saturates at `size−1`; last point NEVER popped |

- Advance is EUCLIDEAN to the next waypoint, and discriminated against
  path-sum on the gap2 dogleg: path[2]=(2,0,1) sits at euclid 1.581139
  from S but 2.581139 along the routed path (S→(2,0,0)→(2,0,1));
  `--gap2 --pdd=2.0` pops it (idx→3) — a path-sum basis predicts no pop.
  (On the detour arm itself the first leg is straight so the two bases
  coincide — non-discriminating there.)
- `is_navigation_finished` is NOT a pdd-only gate on reachable targets:
  on detour, `pdd=5.0` (> both candidates) still yields `finished=false`
  at tdd=1.0 — finished follows the reached gate (`euclid(agent→raw
  target) < tdd`; see below).
- On UNREACHABLE targets pdd owns a second finish mode — and its basis is
  EUCLIDEAN to the clamped final, not path-sum:
  `--gap2`: euclid(S→final)=2.915476, pathlen=4.581139.
  pdd=2.0 → idx=3 but finished=false (proves "idx at last" is
  insufficient; within-pdd-of-final required). pdd=2.9 → false;
  **pdd=3.0 → finished=true** (2.915476 < 3.0 < pathlen 4.581139 —
  path-sum basis falsified); pdd=4.6 → true (control above pathlen).
  All with `reachable=false reached=false` — a finished-without-reached
  signature the reachable arm never shows.
- The reachability selector isolated: `--gap --pdd=3.0` vs
  `--gap2 --pdd=3.0` — identical path, identical final, identical pdd;
  only `reachable` differs (final→T gap 0.5 vs 1.5 against tdd=1.0) →
  finished=false vs true. Reachable ⇒ finished ≡ reached-gate;
  unreachable ⇒ finished ≡ euclid(agent→final) <~ pdd.

Reach-gate boundary pins measured alongside (r70 critic's model extended):

- `is_target_reached` = euclid(agent→RAW target) < tdd — STRICT: at
  `--gap2 --tdd=2.5` with dist=2.500000 exactly, reached=false; tdd=2.7
  → reached=true finished=true (through-wall fire reproduced — agent→T
  euclid satisfied while euclid(agent→final)=2.915476 > 2.7, so the gate
  keys on the raw target, not the final — discriminated).
- `is_target_reachable` = euclid(final→target) ≤ tdd — INCLUSIVE at
  equality: `--gap2` final→T gap exactly 1.5 → reachable=false at
  tdd=1.4, TRUE at tdd=1.5, true at 1.6. Strictness asymmetry between
  the two tdd gates measured at exactly-representable equality points.
- `distance_to_target` stays euclid(agent→raw T) on every arm
  (3.605551 / 2.692582 / 2.500000) — postproc-invariant and
  metadata-invariant.

## Postprocessing observations (recon input to the declared claim)

Independent of the author seat's arms, my sweep measured on the same
L-corridor:

| postproc | path points | pathlen | next | dist |
|---|---|---|---|---|
| 0 corridorfunnel | 3: S,(2,0,1),(2.5,0,3.5) | 4.130649 | (2,0,1) | 3.605551 |
| 1 edgecentered | 4: S,(2,0,0.5),(2.5,0,1),(2.5,0,3.5) | 4.707107 | (2,0,0.5) | 3.605551 |
| 2 none | 4: S,(2,0,0.5),(2,0,1),(2.5,0,3.5) | 4.549510 | (2,0,0.5) | 3.605551 |

- Edgecentered places waypoints at portal-edge centers ((2,0,0.5) =
  center of the x=2,z[0,1] portal; (2.5,0,1) = center of the
  z=1,x[2,3] portal); none keeps raw corridor vertices.
- `distance_to_target` = 3.605551 under all three → Euclidean-invariant
  under postprocessing (consistent with the lane's declared claim;
  `get_next_path_position`/path points DO change, as declared).
- pdd advance operates identically on the reshaped paths
  (`--postproc=1 --pdd=1.55`: pops the 1.5-away portal-center point,
  stops at (2.5,0,1) at 2.061553; `--postproc=2` same at raw vertices).
- Lazy-update contract reproduced (critic F4): `get_current_navigation_path()`
  returns empty and idx=0 until a forcing getter runs — `npath=0/3`,
  `idx=0/1/1` on every arm; `get_next_path_position` is idempotent after
  the forced update.

## Suggested battery surface (for a future round, if admitted)

A `navagent3d_finish` fixture on this geometry could pin: reachable
detour asserts `finished=false` at pdd=5.0 (last-waypoint saturation);
`--gap2` asserts `finished=false` at pdd=2.9 and `finished=true` at
pdd=3.0 (Euclidean-to-clamped-final gate, path-sum falsified); the
reachable/unreachable contrast pair at pdd=3.0 pins the selector;
`tdd=2.5`-exactness pins the strict reached gate vs the inclusive
reachable gate at `tdd=1.5`. All constants measured above.

## Divergences and honest caveats

- First smoke run showed `get_current_navigation_path()` empty before
  `get_next_path_position()` — expected laziness (critic F4), and my
  read order was rebuilt around it; `npath=0/3` is documented in every
  PROBE line rather than asserted away.
- `get_current_navigation_path_types/rids/owners` do NOT exist on
  NavigationAgent3D in this build; the arrays live on
  `get_current_navigation_result()` (NavigationPathQueryResult3D) —
  first iteration failed on this; fixed before any measurement arm ran.
- Owners metadata uninformative for pure-server regions (all invalid
  ObjectIDs); a `NavigationRegion3D`-node mesh might populate real
  owners — unprobed. Link segments (type=1) absent — unprobed.
- pdd pop boundary: `pdd=1.581` does not pop the 1.581139-away waypoint
  while `pdd=1.581139` does — inclusive-at-equality or sub-printed-digit
  float; strictness of the finish gate at pdd==euclid_final (2.915476)
  unprobed; float-adjacent tdd values (1.499999…) unprobed.
- One engine build (`4.7.2.stable.arch_linux.ed1daf0bf`), one host,
  stationary agent, single region, 30-frame settle; no motion/mid-path
  evolution, avoidance, `path_max_distance`, `path_height_offset`,
  `simplify_path`, pathfinding algorithm, baked meshes, or rendering.
- The SDL-stderr/`navagent3d_retarget` intermittence from r68–r69 did
  not manifest (all stderr banner-only, repeat byte-identical); caveat
  stands unretracted.
