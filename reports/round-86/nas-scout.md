# game-dev-3d round 86 — nas-scout (seat: g3d NAS-ANIM SCOUT, host: devin)

Wave `shokunin-train-20261101-w16`, lane g3d. Assignment (verbatim, first
lines): *"SEAT: g3d NAV-ANIM SCOUT — recon the navigation + animation fixture
families. Repo: /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin … Measure
(bounded, fresh processes): which registered nav/anim cells still pass on this
godot build; any stale rows? navagent3d surface gaps: avoidance, path_index
boundary conditions, target-position mid-flight updates — what behaviors are
unprobed? animation3d surface: blend weights vs track loops vs speed_scale —
which behavioral classes exist? The DEATH surfaces: what kills these scripts
(missing nav map, no animation player, null skeleton) — refusal classes vs
silent no-ops vs errors? skeleton3d + physics interplay (bone attachment +
rigid body)? Deliver: coverage map + ranked frontier list + 2-3 pre-measured
candidate cells. reports/round-86/nas-scout.md + corpus/live/nas-scout/."*

**Runtime (every bound below is scoped to this):** `/usr/bin/godot`
`4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`, 60 tps (`project.godot`),
32 cores. HEAD `f230443`. Scratch `corpus/live/nas-scout/` (gitignored,
`corpus/.gitignore:1`); **zero tracked-file edits by this seat** — every write
went to `corpus/live/nas-scout/` and this report.
Receipts: **178 run groups / 918 files**, 19 probes + 3 drivers, pinned in
`corpus/live/nas-scout/manifest.sha256`. **Read
`corpus/live/nas-scout/RECEIPTS.md` first** — it names five superseded runs,
the determinism boundary, and the one place this seat's first pass was wrong.

**The tree moved under this seat (provenance).** The sibling r85 wave-B lane
rewrote `corpus/fixtures/run_battery.py`, `corpus/fixtures/phys3d_events.gd` and
`corpus/fixtures/README.md` while this seat was measuring (mtimes
`16:54:36–16:54:43 -0300` = `19:54:36–19:54:43Z`; the `run_battery.py` diff is a
one-line `LEAKED_OBJECTDB` regex widening — not this seat's work). This seat
read `run_battery.py` @ sha
`991c6c8ac39a58a576dd9d1e1cc4d922a996dc9b978c9a5f435d325c2666add5` (191 CASES,
921 lines); the live file is now `2e1a3242…` (also 191 CASES, 921 lines).
**Every registration claim in §1 is scoped to `991c6c8a…`**; the frozen seed
copies in `scratch/` and `proj/` carry that revision, so the 121-cell run is
reproducible. The three tracked modifications visible at seat end are sibling
writes, not this seat's.

**LSP unavailability recorded.** `mcp_list_servers` exposes only `rea` for this
repo — no `lsp` device answers (same as r85/r86 sibling lanes). Every symbol
fact below is engine-measured (`ClassDB.class_get_method_list` /
`class_get_property_list` dumps in `runs/api`), never grep-level. No
symbol-aware operation was needed: this seat measures, it does not edit
fixtures.

**Measured vs predicted.** Everything below is **measured** unless a line says
**inference** or **unresolved**. Determinism is stated per probe (§RECEIPTS 4).

---

## 1. Registered-cell freshness: 121/121 pass, no stale rows

All **121** registered cells in the nav / follow / retarget / animation /
pathfollow / curve / skeleton families were re-run on this build in fresh
processes against the frozen seed (`runs/reg`, 16-way parallel, 25 s cap):

| family | cells | verdict |
|---|---|---|
| `navagent3d_detour.gd` (86 arms + 5 r85 arms) | 91 | PASS, exact marker |
| `navagent3d_{retarget,follow,next,distance}.gd` | 8 | PASS |
| `pathfollow3d_{callback,paced,curve}.gd` + `curve3d_path.gd` | 8 | PASS |
| `animation3d_{blend,playback,keys}.gd` | 6 | PASS |
| `skeleton3d_{attachment,rotation,pose}.gd` | 6 | PASS |
| `navigation3d_path.gd` | 2 | PASS |
| **total** | **121** | **ok=121 fail=[]** |

**Stderr is empty for all 121 cases** (0 bytes each) — no unexpected ERROR or
leak line anywhere in the family. Wall time: min 364 ms, median 1211 ms, max
6259 ms (`navagent3d_detour_mut_mapoff_ladder`), 150.4 s total.

**Stale rows: none.** Two independent checks:

- every script named in a `CASES` row exists in the seed, and
- every `.gd` seed not named in a row is a *declared support script*, not a
  missing cell. All nine orphans say so in their own header:
  `navfollow3d_driver.gd` / `navretarget3d_driver.gd` / `pathfollow3d_driver.gd`
  are drivers `preload`ed by registered fixtures; `runner3d.gd`,
  `pickup_orb3d.gd`, `input_mover3d.gd` are shared actors referenced by
  `area3d_chain` / `body3d_slide` / `floor3d_ground` / `slope3d_angle` /
  `input3d_move`; `crash_exit3d.gd`, `stream_attribution3d.gd`,
  `timeout_tree3d.gd` are consumed by the battery's own
  `probe_crash_exit` / `probe_stream_attribution` / `probe_tree_timeout`.

So the registration set is complete and consistent with the seeds at
`991c6c8a…`. **This seat found no stale row and no missing-cell hole in the
registered set** — the gaps are all *surface* gaps (§3–§7), not registration
gaps.

---

## 2. Coverage map

`✓` = a registered cell exercises it; `·` = no cell exercises it (measured by
this seat's probes); `—` = does not exist on this build.

| class | state | note |
|---|---|---|
| **path query** (map/region/mesh authored in script) | ✓ 91+ | the detour fixture is the deepest surface in the repo |
| path_postprocessing CORRIDORFUNNEL / EDGECENTERED / NONE | ✓ | r71 arms |
| path_desired_distance pop loop, `idx` saturation | ✓ | r72 arms |
| `is_target_reached` / `is_target_reachable` / `is_navigation_finished` | ✓ | r72/r73 arms, strict/inclusive edges pinned |
| `NavigationLink3D` (server + node authored, layers, oneway, costs, metadata) | ✓ | r73 arms; `enter_cost` inert (pinned anomaly) |
| moving agent: `path_max_distance` re-query boundary | ✓ | r74 arms, bisected |
| target_position re-assignment mid-flight | ✓ | `navagent3d_retarget` + `mv_*` arms |
| r85 `mut_*` mutation ladder | ✓ | 5 arms |
| **`get_current_navigation_path_index()` as a getter** | **·** | index *value* is pinned by many arms; the getter's **forcing behaviour** is not — §4 |
| **lazy-update forcing contract** (which getters re-query) | **·** | §4 — no cell calls a getter in isolation |
| **avoidance: agent vs agent** | **·** | §3 |
| **avoidance: agent vs `NavigationObstacle3D`** | **·** | §3 |
| **avoidance: entry contract (who sets velocity, from where)** | **·** | §3 — the single highest-value gap |
| **`NavigationServer3D` agent/obstacle RID API** | **·** | §3 |
| **`agent_set_paused`, `avoidance_enabled` toggling** | **·** | §3 |
| **death: no map / freed map / inactive map / no region** | **·** | §5 |
| **death: off-mesh / zero-length / NaN target** | **·** | §5 |
| animation: cross-fade `play(name, blend)` | ✓ | `animation3d_blend` |
| animation: explicit `seek(t, true)` | ✓ | `animation3d_keys` |
| animation: natural physics-frame advance + `current_animation_position` | ✓ | `animation3d_playback` |
| **`speed_scale` / `get_playing_speed`** | **·** | §6 |
| **`loop_mode` NONE / LINEAR / PINGPONG** | **·** | §6 |
| **`play_backwards`** | **·** | §6 |
| **`set_section` / `play_section`** | **·** | §6 |
| **MANUAL callback mode + `AnimationMixer.advance()`** | **·** | §6 |
| **`set_blend_time` (per-pair), `animation_set_next`** | **·** | §6 |
| **`TYPE_ROTATION_3D` / `TYPE_SCALE_3D` / `TYPE_VALUE` on a plain Node3D** | **·** | §6 |
| **`AnimationTree` / `AnimationNodeBlendTree` / `AnimationNodeStateMachine`** | **·** | no cell anywhere; class surface dumped in `runs/api` |
| skeleton: bone hierarchy, rest, local/global pose | ✓ | `skeleton3d_pose` / `skeleton3d_rotation` |
| skeleton: `BoneAttachment3D` follows the bone pose | ✓ | `skeleton3d_attachment` (marker `Node3D` only) |
| **`AnimationPlayer` → `Skeleton3D` bone tracks** | **·** | §7 — the anim↔skeleton bridge is entirely unregistered |
| **`BoneAttachment3D` + collision body in the physics server** | **·** | §7 |
| **`BoneAttachment3D` `override_pose` / `use_external_skeleton`** | **·** | class surface dumped |
| **`Skeleton3D.motion_scale`, `set_bone_global_pose_override`, physical bones, skins** | **·** | §7 |
| pathfollow: `progress` / `progress_ratio`, child marker | ✓ | 3 fixtures |
| **`PathFollow3D.rotation_mode` (Y / XY / XYZ), `h_offset`/`v_offset`, `use_model_front`, `cubic_interp`** | **·** | all three fixtures pin `ROTATION_NONE` |
| **`NavigationRegion3D` scene-tree behaviour, navmesh baking** | **·** | every cell authors the server directly |

---

## 3. Avoidance: an entire unprobed surface, and its entry contract is a silent no-op

The LOG declares avoidance out of scope at r13/r49/r50/r51 and never revisits
it (`LOG.md:177,184,558,569,573,579`). It is now the largest unmeasured block
in the nav family. Measured facts, in the order they matter:

### 3.1 `NavigationAgent3D.set_velocity()` never reaches the server — measured

`runs/p6/nav_node_rid`, `runs/p7b/nav_node_rid2`. Same agent, same map, same
frame loop, only the write path varies:

```
A_node_setter        safe_n=10 last_safe=(0.0, 0.0, 0.0) same_tick_srv=(0.0, 0.0, 0.0) srv_pos=(0.5, 0.0, 2.0) node_vel=(2.0, 0.0, 0.0)
   TAIL_SRV  [(0.0,0.0,0.0) ×10]      TAIL_SAFE [(0.0,0.0,0.0) ×10]
B_server_rid         safe_n=10 last_safe=(2.0, 0.0, 0.0) same_tick_srv=(2.0, 0.0, 0.0) srv_pos=(0.5, 0.0, 2.0) node_vel=(0.0, 0.0, 0.0)
   TAIL_SRV  [(0,0,0),(2,0,0) ×9]      TAIL_SAFE [(2,0,0) ×10]
C_server_rid_forced  safe_n=10 last_safe=(0.0, 0.0, 0.0) same_tick_srv=(0.0, 0.0, 0.0)
```

- **A** — `agent.set_velocity((2,0,0))` from a parent driver's
  `_physics_process` (the documented pattern) and from the SceneTree script:
  the node's `velocity` property is `(2,0,0)` but
  `NavigationServer3D.agent_get_velocity(agent.get_rid())` stays `(0,0,0)` for
  every frame, and `velocity_computed` delivers `(0,0,0)` every frame.
- **B** — the *same* agent's RID written directly with
  `NavigationServer3D.agent_set_velocity(agent.get_rid(), v)`: server velocity
  `(2,0,0)` from the next callback onward, safe velocity `(2,0,0)`.
- **C** — `agent_set_velocity_forced` on the RID: server velocity stays
  `(0,0,0)`, callback stays `(0,0,0)`. With a velocity already set it is also
  inert: `E2_FORCED base_safe=(2.0, 0.0, 0.0) after_forced=[(2,0,0) ×4]`.
- **Set-once test** (rules out "my per-frame set overwrote a write-back"):
  calling `agent.set_velocity((2,0,0))` exactly once on tick 0 leaves
  `srv_vel_series` `[(0,0,0) ×9]` and `safe` `[(0,0,0) ×9]` while
  `node_vel=(2.0,0.0,0.0)`. **The value never arrives.**

The node agent *is* fully registered — `NODE_RID in_map=true`,
`avoidance_enabled=true`, `has_cb=true`, `srv_pos=(1.0,0.0,1.0)` correct
(`runs/p6/nav_node_rid`). Only the velocity link is dead. **Class: silent
no-op** — no error, no warning, no state change, callback fires with zeros.

Scope: measured in a headless `SceneTree` fixture with the agent parented under
a driver that sets the velocity in `_physics_process`, and with the agent
parented directly under the tree. **Unresolved:** whether an agent that is
itself the `_physics_process` owner (no wrapper node) behaves differently — the
`B_server_rid` control makes that the only untested link in the chain.

### 3.2 Agent-vs-agent avoidance computes — when the velocity is pushed

With the RID push, avoidance is fully observable (`runs/p7b/nav_node_rid2`,
`runs/det-r1/nav_avoid4`):

```
E3_HEADON_NEAR a_safe=(-5.0, 0.0, 0.0) b_safe=(5.0, 0.0, 0.0) dist=0.70000004768372
E4_FAR         a_safe=(2.0, 0.0, 0.0)  b_safe=(-2.0, 0.0, 0.0) dist=4.24264049530029
```

Separation ladder (both r=0.5, `max_speed`=5.0, requested ±2.0, 5 reps):
`0.5`/`0.7` → `a=(-5,0,0)` `b=(5,0,0)` (full reverse at `max_speed`);
`1.0` → both `(0,0,0)` (full stop); `1.2…3.5` → partial braking; `≥4.0` →
`a=(2,0,0)` untouched while `b` is still braked to ~`-0.97…-1.98`. The
asymmetry is measured, reproducible in sign, and **unexplained** — `inference`:
a priority/leader-yields term. Radius ladder at fixed separation 2.0 is
monotone: r 0.1 → `a=1.234`, r 0.3 → `0.899`, r 0.5 → `0.694`, r 0.8 →
`0.278`, r 1.2 → `-5.0`.

**Non-determinism boundary (important for any cell):** the *partial* braking
magnitudes differ on every process — separation 2.0 gave `a=0.642612` /
`0.639081` / `0.515927` across three reps; radius 0.5 gave `0.694274` /
`0.515220`. **Saturated outcomes are byte-stable**: full reverse, full stop,
and exact-requested. An avoidance cell must assert a saturated witness.

### 3.3 `NavigationObstacle3D` works — but only with matched `use_3d_avoidance`

`runs/det-r1/nav_obstacle`, byte-identical across **4** reps
(full-file md5 `0f9c780a33a727f40b165b74041c6745` ×4). Agent at `(0.5,0,0.5)` pushed
`(2,0,0)`, obstacle at `(1.5,0,0.5)` r=0.7, `obstacles_in_map=1` in every row:

| obstacle `use_3d_avoidance` | agent `use_3d_avoidance` | safe velocity |
|---|---|---|
| *(no obstacle — baseline)* | true | `(2.0, 0.0, 0.0)` |
| **true** | **true** | **`(-5.0, 0.0, 0.0)`** |
| false | true | `(2.0, 0.0, 0.0)` ← **silent no-op** |
| true | false | `(2.0, 0.0, 0.0)` ← **silent no-op** |
| false | false | `(-5.0, 0.0, 0.0)` |
| true (radius 2.0) | true | `(-5.0, 0.0, 0.0)` |
| true (moving, `velocity=(-2,0,0)`) | true | `(-5.0, 0.0, 0.0)` |
| true (raw RID obstacle) | true | `(-5.0, 0.0, 0.0)` |

`NavigationObstacle3D.use_3d_avoidance` **defaults to false** while
`NavigationAgent3D.use_3d_avoidance` defaults to true — so the default pairing
in a 3D scene is the silent-no-op row. This seat's first obstacle pass
concluded "obstacle avoidance is a no-op"; that conclusion was **wrong** and is
corrected here (the obstacle had never been bound to the agent's map *and* the
modes were mismatched — see `RECEIPTS.md` §3).

### 3.4 Server-side lifecycle classes

`runs/p3b/nav_avoid2`:

- **Setters are deferred to the next sync.** On the RID path,
  `P1_PRESYNC avoid=false has_cb=false map=false pos=(0.0,0.0,0.0)
  map_agents=0` → `P1_POSTSYNC avoid=true has_cb=true map=true
  pos=(1.0,0.0,1.0) map_agents=1`. A pre-sync getter reads the *old* value; it
  is not an error and not a refusal.
- **`avoidance_enabled = false` stops the callback**: `P7_DISABLE
  off_events=0 after_reenable_total=8` — re-enabling resumes within one frame.
- **`agent_set_paused(rid, true)` stops the callback**:
  `P8_PAUSED base_events=6 paused_events=0 paused=true`.
- **Agent registration in the map is lazy**: `map_get_agents()` is 0 before the
  first sync and counts up afterwards (`MAP_AGENTS_FINAL=4` in `p2/nav_avoid`).

---

## 4. The lazy-update cache contract: which getters re-query

`runs/det2-d1/nav_cache`, byte-identical across 3 reps. Fresh map/region/agent
each sub-case, target `(3,0,3)` from `(1,0,1)`, 5 settle frames, then exactly
one getter, then read the cache through `get_current_navigation_path()`:

```
CASE G0_no_getter              returned=<null>                     cached_path_n=0 idx=0
CASE G1_next_path_position     returned=(3.0, 0.0, 3.0)            cached_path_n=2 idx=1
CASE G2_path_length            returned=0.0                        cached_path_n=0 idx=0
CASE G3_path_index             returned=0                          cached_path_n=0 idx=0
CASE G4_distance_to_target     returned=2.82842707633972           cached_path_n=0 idx=0
CASE G5_is_target_reachable    returned=true                       cached_path_n=2 idx=1
CASE G6_is_target_reached      returned=false                      cached_path_n=0 idx=0
CASE G7_is_navigation_finished returned=false                      cached_path_n=2 idx=1
CASE G8_get_final_position     returned=(3.0, 0.0, 3.0)            cached_path_n=2 idx=1
CASE G9_navigation_result      returned=<NavigationPathQueryResult3D…> cached_path_n=0 idx=0
CASE G10_target_position       returned=(3.0, 0.0, 3.0)            cached_path_n=0 idx=0
```

**Forcing** = `get_next_path_position`, `is_target_reachable`,
`is_navigation_finished`, `get_final_position`.
**Non-forcing (serve cache / compute locally)** =
`get_current_navigation_path`, `get_current_navigation_path_index`,
`get_path_length`, `distance_to_target`, `is_target_reached`,
`get_current_navigation_result`, `target_position`.

`G2` is the sharp edge: **`get_path_length()` returns the cached path length —
`0.0` when nothing has forced a query yet.** The registered arms never see this
because every one of them calls `get_next_path_position()` first. `nav_death`
D6 shows the same function returning a *non-zero* value with an **empty** path
(`path_n=0 … len=4.242640`), i.e. length is the agent→clamped-final distance
when the target is off-mesh, not the polyline sum.

Index boundaries (`nav_cache` tail): the index saturates at `size-1`
(`IDX at_end idx=1 next=(3.0,0.0,3.0) reached=true finished=true path_n=2`),
stays latched through an off-map teleport (`IDX off_map idx=1 next=(3.0,0.0,3.0)`),
and is **not** reset by a `path_desired_distance` change (`IDX pdd100 idx=1`).
After a `target_position` re-assignment the cache is cleared (`path_n=0`) while
the index keeps its old value (`idx=1`) until the next forcing call — the
`SEQ after retarget path_n=0 idx=1` line.

---

## 5. The DEATH surfaces: refusal vs silent no-op vs error

### 5.1 NavigationAgent3D (`runs/p1/nav_death`, byte-identical 3 reps)

| case | outcome | evidence |
|---|---|---|
| no map set | **silent no-op** — `get_navigation_map()` returns a *valid* default map RID; `next` = agent's own position, `final=(0,0,0)`, `len=0`, `reachable=false` | `D1_POST path_n=0 idx=0 next=(1.0,0.0,1.0) final=(0.0,0.0,0.0) dist=2.828427 reachable=false reached=false finished=false len=0.000000` |
| map+region freed after a live query | **stale cache served, no error** — the cached 2-point path and `reachable=true` survive the free, and `get_navigation_map().is_valid()` still reports `true` | `D2_POST_FREED path_n=2 idx=1 … reachable=true … map_valid=true` |
| map created inactive | silent no-op (same tuple as D1) | `D3_POST_INACTIVE … map_active=false regions=1` |
| active map, 0 regions | silent no-op | `D4_POST_NOREGION … regions=0` |
| region disabled | silent no-op | `D5_POST_REGDISABLED … region_enabled=false` |
| target far off-mesh | **clamp + empty path + non-zero length** — `final` is the nearest mesh point `(4,0,4)`, `dist` is Euclidean to the *raw* target (140.0), `path_n=0`, `len=4.242640` | `D6_POST_OFFMESH` |
| target == agent position | immediate `reached=true finished=true`, `path_n=0`, `len=0` | `D7_POST_ZEROLEN` |
| NaN target | **no error** — `dist=nan`, `target=(nan,nan,nan)`, all predicates false | `D8_POST_NAN` |
| target at 1e7 | same as off-mesh | `D9_POST_FAR dist=14142134.000000 … len=4.242640` |
| agent node freed mid-flight | agent leaves the map cleanly; the stale RID still reports `is_valid()=true` | `D10_POST_NODE_FREED map_agents=0 rid_valid=true` |

The **only** error line in the whole probe is a refusal on the *server* path:
`ERROR: Condition "map_index < 0" is true. at: _cmd_map_set_active` — i.e.
**`NavigationServer3D.map_set_active(fresh_map, false)` errors** because a
freshly created map is not yet in the active list. That is a distinct refusal
class from all of the above silent no-ops.

### 5.2 AnimationPlayer / Skeleton3D (`runs/p1/anim_death`, 8/9 cases byte-stable)

| case | class | evidence |
|---|---|---|
| `play("nope")` | **refusal: error + no state change** | 3 stderr ERRORs (`Animation not found: "nope".` ×1, `Animation not found: nope.` ×1, `AnimationPlayer has no current animation.` ×1); `A1_POST current= assigned= is_playing=false pos=(0,0,0) t=0.0` |
| no library at all, `play("travel")` | refusal: error, no state change | `ERROR: Animation not found: travel.`; `A2_POST current= is_playing=false t=0.0 len=0.0` |
| track path names a missing node | **silent no-op** — animation "plays" (`is_playing=true`, `t` advances) and nothing moves | `A4_POST ghost_track pos=(0.0,0.0,0.0) t=0.3166 is_playing=true` |
| `Skeleton3D` with 0 bones, `get_bone_global_pose(0)` | **refusal: error + identity return** | `ERROR: Index p_bone = 0 is out of bounds (bone_size = 0).` ×2; returns `Transform3D.IDENTITY` |
| `BoneAttachment3D` with a bone name that does not exist | **silent no-op** — `get_bone_idx()=-1`, attachment stays identity, marker at its local offset, no error | `A6_POST idx=-1 att_pos=(0,0,0) att_basis=IDENTITY marker_global=(1.0,0.0,0.0) skeleton=<Skeleton3D…>` |
| `BoneAttachment3D` with no `Skeleton3D` parent | **silent no-op** | `A7_POST skeleton=<Object#null> idx=-1 pos=(0.0,0.0,0.0)` |
| `BoneAttachment3D.bone_idx = 7` on a 1-bone skeleton | **silent no-op** — setter resets to `-1` and clears `bone_name` | `A8_POST idx=-1 name= pos=(0,0,0) skeleton=<Skeleton3D…>` |
| `AnimationPlayer` rotation track naming a **missing bone** (`../../Skelly:MissingBone`) | **silent no-op** (WARNING only) | `A9_POST missing_bone_rot root_pose=(0,0,0,1) t=0.3166 playing=true` |
| `AnimationPlayer` rotation track naming a **missing node** (via `root_node`) | WARNING only, track dropped | `WARNING: AnimationMixer: 'bone_move', couldn't resolve track: 'Skelly:Tip'.` (`runs/det2-d1/skel_phys` stderr) |

**Pattern:** the animation/skeleton surface refuses *loudly* only for
"animation not found" and out-of-bounds bone indices. Every *path-resolution*
failure (node missing, bone missing, attachment unbound) is a **warning-level
silent no-op**. A fixture that only checks "did the animation play" would pass
while nothing moved.

---

## 6. animation3d: the behavioral classes that exist

`runs/det2-d1/anim_surface` (byte-identical 3 reps) — 10 classes beyond the
three registered ones:

```
C1_SPEED2        pos=(0.966667,0,0) t=0.966667 playing_speed=2.0 is_playing=true      # speed_scale=2.0 doubles both
C2_LOOP_LINEAR   pos=(0.483333,0,0) t=0.483333 is_playing=true                        # 149 frames / 2.0 s wraps
C3_LOOP_PINGPONG pos=(1.516667,0,0) t=1.516667 is_playing=true                        # 4.0 - 2.4833 → reverses
C4_LOOP_NONE     pos=(2.0,0,0)      t=2.0      is_playing=false assigned=travel current=   ← end state
C5_BACKWARDS     pos=(1.0,0,0)      t=1.0      playing_speed=-1.0
C6_BLENDTIME     self=0.5 default=0.0                                                 # set_blend_time(a,a,0.5) accepted
C7_SECTION       at_start=(1.0,0,0) after=(2.0,0,0) t=2.0 sec=1.0 3.0                 # section clamps the seek window
C8_MANUAL        (superseded — print-order artifact, see RECEIPTS §3)
C9_ROT3D_ON_NODE quat=(0,-0.707107,0,0.707107) basis_y=(0,1,0)                        # TYPE_ROTATION_3D works on a plain Node3D
C10_SCALE_VALUE  scale=(1.483333,…) pos_y=0.0  vmode=1 interp=1
C10_END          scale=(3.0,3.0,3.0) pos_y=9.0                                        # TYPE_VALUE discrete track applies
```

**`LOOP_NONE` end state is the sharpest new class** (`C4`): at the end of a
non-looping animation `current_animation_position` clamps to `length`,
`is_playing()` flips to `false`, `current_animation` becomes the **empty
string**, and `assigned_animation` stays `"travel"`. The registered
`animation3d_playback` never reaches the end (60 frames of a 2.0 s track), so
this is unmeasured anywhere.

### 6.1 MANUAL callback mode, pinned (`runs/det3-d1/anim_manual`, 3 reps)

```
M1_PHYSICS t=0.483333 pos=(0.483333,0,0) playing=true        # PHYSICS: time and pose both advance
M2_MANUAL  frame 0..9  t=0.0 pos=(0.0,0.0,0.0)               # MANUAL from the start: BOTH frozen
M2_ADV1  t=0.016666 pos=(0.016667,0,0)                       # advance(delta) applies AND advances time
M2_ADV2  t=0.516666 pos=(0.516667,0,0)
M2_ADV3  t=1.516666 pos=(1.516667,0,0) playing=true
M3_SEEK_UPDATE_TRUE  t=1.0 pos=(1.0,0,0)                     # seek(t, true) applies immediately
M3_SEEK_UPDATE_FALSE t=1.5 pos=(1.0,0,0)                     # seek(t, false) moves time only
M3_SEEK_BACK        t=1.0 pos=(1.0,0,0)
M4_MANUAL_TO_PHYSICS m_t=0.0 m_pos=(0.0,0,0) now_t=0.066667 now_pos=(0.066667,0,0)
```

So `MANUAL` freezes **time and pose**; `advance(delta)` is the only thing that
moves either; `seek(t, false)` moves time without applying; switching back to
`PHYSICS` resumes advancing from the frozen time. The earlier `C8` "anomaly"
(`t_auto=1.0` with `pos=(0,0,0)`) was a print-order artifact in this seat's own
probe, not engine behavior — corrected here.

---

## 7. skeleton3d: the anim↔skeleton bridge and the physics interplay

### 7.1 `AnimationPlayer` drives `Skeleton3D` bone tracks (`runs/det3-d1/anim_skeleton`)

Track path grammar is `<NodeName>:<BoneName>` relative to `root_node`:

```
B1_PRE resolved=true tip_rest=(0.0, 2.0, 0.0)
B1_SEEK_END root_pose_q=(0, 0, 0.707107, 0.707107) …        # TYPE_ROTATION_3D on "Skelly:Root" resolves
B2_LIVE t=0.483333 tip_pose_q=(0.188667, 0, 0, 0.982041) …  # TYPE_ROTATION_3D on "Skelly:Tip" drives the child bone
B3_POS_BONE tip_local=(3.0, 2.0, 0.0) tip_global=(3.0, 2.0, 0.0)   # TYPE_POSITION_3D on a bone
B4_SCALE_BONE tip_scale=(2.0, 2.0, 2.0)                     # TYPE_SCALE_3D on a bone
B5_MANUAL_AFTER_ANIM animated=(0,0,0.707107,0.707107) now=(0,0,0,1)  # a manual pose write wins until the next apply
B5_REDRIVE root_q=(0,0,0.707107,0.707107)                   # seek() re-drives it back
```

A wrong path (`"Skelly:Tip"` with `root_node` = the skeleton) is a WARNING and
a silent no-op — see §5.2. `B4_MOTION_SCALE_0.5` showed no change, but the
probe re-`seek()`ed instead of letting frames advance, so **`motion_scale` is
unresolved**, not measured-inert.

### 7.2 A collision body under `BoneAttachment3D` tracks the bone *in the physics server*

`runs/det2-d1/skel_phys` (3 reps identical). `StaticBody3D` + `SphereShape3D`
parented under a `BoneAttachment3D` on bone `Tip`; the witness is a
`direct_space_state.intersect_ray` (reads the server's space, not the tree)
plus `PhysicsServer3D.body_get_state(rid, BODY_STATE_TRANSFORM)`:

```
RAY S0_rest        node_pos=(0.0,0.0,0.0) srv_origin=(0.0,0.0,0.0) hit=(0.0,0.5,0.0) hit_collider=StaticBody3D
RAY S1_pose_up     node_pos=(0.0,3.0,0.0) srv_origin=(0.0,3.0,0.0) hit=(0.0,3.5,0.0) hit_collider=RigidBody3D
RAY S2_root_rot90  node_pos=(-3.0,0.0,0.0) srv_origin=(-3.0,0.0,0.0) hit=<miss>
S4 body_state_origin=(-3.0,0.0,0.0) node_origin=(-3.0,0.0,0.0) matches=true
RAY S5_skeleton_moved node_pos=(-3.0,0.0,3.0) srv_origin=(-3.0,0.0,3.0) hit=<miss>
S7 rigid_global=(-3.0,0.0,3.0) rigid_freeze=true att_global=(-3.0,0.0,3.0) rigid_srv=(-3.0,0.0,3.0)
```

A bone-pose edit, a root rotation, and a whole-skeleton teleport all move the
**server-side** body transform (`matches=true`), and the raycast follows the
shape. A frozen `RigidBody3D` under the same attachment tracks too. So the
bone→physics link is real and witnessable; the registered
`skeleton3d_attachment` only proves the *node* transform, not the server's.

`S6`: `physical_bones_start_simulation()` on a skeleton with **no
`PhysicalBone3D` children** is a silent no-op — no error, `animate_physical_bones`
stays `true`.

---

## 8. Ranked frontier list (r87–r90)

Ranked by (unprobed surface size × falsifiability × independence from the
non-determinism boundary):

| # | frontier | why it ranks here | candidate cell |
|---|---|---|---|
| 1 | **Avoidance entry contract** — §3.1 | a documented API that silently delivers `(0,0,0)`; zero existing coverage; saturated witnesses are deterministic; the fix (RID push) is already measured | `navagent3d_set_velocity_inert` |
| 2 | **Obstacle avoidance + mode matching** — §3.3 | works, deterministic 4/4, and the *default* mode pairing is the silent-no-op row; positive + negative + control in one cell | `navagent3d_avoid_obstacle` |
| 3 | **Lazy-getter cache contract** — §4 | pure readback, no motion, no avoidance, deterministic 3/3; changes what "reading a path" means for every future nav arm | `navagent3d_cache` |
| 4 | **anim↔skeleton bone tracks** — §7.1 | entire bridge unregistered; deterministic 3/3; a natural companion to the 3 existing animation cells | `animationskeleton3d_bone` |
| 5 | **Bone→physics-server tracking** — §7.2 | raycast + `body_get_state` witness; deterministic 3/3; extends `skeleton3d_attachment` past the node transform | `skeleton3d_physics` |
| 6 | **`LOOP_NONE` end state + MANUAL mode** — §6 | two crisp, deterministic state machines; `LOOP_NONE` end state is unreachable in the current cells | `animation3d_loop`, `animation3d_manual` |
| 7 | **Nav death/refusal matrix** — §5.1 | 10 cases, one error line total; documents the silent no-op that a missing map is | `navagent3d_death` |
| 8 | **Anim/skeleton death matrix** — §5.2 | 9 cases; separates loud refusal from warning-level silent no-op | `animation3d_death` |
| 9 | **`PathFollow3D` rotation modes / offsets / `cubic_interp`** | all three pathfollow cells pin `ROTATION_NONE`; the rotation modes are the natural next arm | `pathfollow3d_orient` |
| 10 | **`Skeleton3D` pose override + `motion_scale` + skins** | class surface dumped in `runs/api`; `motion_scale` currently unresolved | `skeleton3d_override` |
| 11 | **`AnimationTree` / blend tree / state machine** | no cell anywhere; class surface dumped; heavier to author | `animationtree3d_blend` |
| 12 | **`NavigationRegion3D` scene-tree behaviour + navmesh baking** | the largest remaining *structural* gap (every cell authors the server directly) | `navigation3d_region` |

Do **not** rank the separation ladder or radius ladder as an early cell — §3.2
shows partial magnitudes are process-nondeterministic; only the saturated rungs
are cell-safe.

---

## 9. Pre-measured candidate cells

Three cells, fully measured, deterministic, with exact expected markers
derived from this seat's probes. The probes are at
`corpus/live/nas-scout/probes/probe_nav_node_rid.gd`,
`probe_nav_obstacle.gd`, `probe_nav_cache.gd`; the author can re-run any of them
in one fresh process (~1–2 s) to re-derive the marker.

### Cell A — `navagent3d_set_velocity_inert` (rank 1)

**Claim under test:** on this build a node-level `NavigationAgent3D` whose
velocity is written with `set_velocity()` never reaches the avoidance server,
so `velocity_computed` delivers `(0,0,0)`; the same agent's RID written
directly with `NavigationServer3D.agent_set_velocity()` delivers the requested
velocity.

- **Positive arm:** push `(2,0,0)` through `agent.get_rid()` each frame →
  `last_safe=(2.0,0.0,0.0)`, `same_tick_srv=(2.0,0.0,0.0)`.
- **Negative arm (the finding):** `agent.set_velocity((2,0,0))` **once** on
  tick 0, then never again → `srv_vel_series` all `(0,0,0)`,
  `safe` all `(0,0,0)`, while `node_vel=(2.0,0.0,0.0)`.
- **Control:** `agent_set_velocity_forced` on the same RID → `(0,0,0)`.

Exact measured lines to pin (`runs/p7b/nav_node_rid2`, `runs/p6/nav_node_rid`):

```
A_node_setter safe_n=10 last_safe=(0.0, 0.0, 0.0) same_tick_srv=(0.0, 0.0, 0.0) srv_pos=(0.5, 0.0, 2.0) node_vel=(2.0, 0.0, 0.0)
B_server_rid  safe_n=10 last_safe=(2.0, 0.0, 0.0) same_tick_srv=(2.0, 0.0, 0.0) srv_pos=(0.5, 0.0, 2.0) node_vel=(0.0, 0.0, 0.0)
C_server_rid_forced safe_n=10 last_safe=(0.0, 0.0, 0.0) same_tick_srv=(0.0, 0.0, 0.0) srv_pos=(0.5, 0.0, 2.0) node_vel=(0.0, 0.0, 0.0)
E1_SET_ONCE srv_vel_series=[(0.0, 0.0, 0.0), (0.0, 0.0, 0.0), (0.0, 0.0, 0.0), (0.0, 0.0, 0.0), (0.0, 0.0, 0.0), (0.0, 0.0, 0.0), (0.0, 0.0, 0.0), (0.0, 0.0, 0.0), (0.0, 0.0, 0.0)]
E1_SET_ONCE node_vel=(2.0, 0.0, 0.0)
```

Needs a driver script (like the existing `navfollow3d_driver.gd`) that owns the
per-tick push, because the probe must set the velocity from inside a
`_physics_process`. Determinism: 3/3 reps byte-identical.

### Cell B — `navagent3d_avoid_obstacle` (rank 2)

**Claim under test:** `NavigationObstacle3D` avoidance is active **iff** the
obstacle's `use_3d_avoidance` matches the agent's; a mismatch is a silent no-op
and the safe velocity stays exactly the requested one.

- **Positive:** obstacle `use_3d_avoidance=true`, agent `true`, obstacle at
  `(1.5,0,0.5)` r=0.7, agent at `(0.5,0,0.5)` pushed `(2,0,0)` →
  `safe=(-5.0, 0.0, 0.0)` (full reverse at `max_speed`).
- **Negative:** obstacle `use_3d_avoidance=false`, agent `true` →
  `safe=(2.0, 0.0, 0.0)` — unchanged, **no error, no warning**.
- **Negative 2:** obstacle `true`, agent `false` → `safe=(2.0, 0.0, 0.0)`.
- **Control:** obstacle `avoidance_enabled=false` (or absent) →
  `safe=(2.0, 0.0, 0.0)`.

Exact measured lines (`runs/det-r1/nav_obstacle`; `srv_radius` prints as
float32 — format `%.6f` in the fixture):

```
OBS baseline_no_obstacle  safe=(2.0, 0.0, 0.0)  in_map=1 srv_avoid=false srv_3d=true  srv_radius=0.000000
OBS obs3d=1 agent3d=1     safe=(-5.0, 0.0, 0.0) in_map=1 srv_avoid=true  srv_3d=true  srv_radius=0.700000
OBS obs3d=0 agent3d=1     safe=(2.0, 0.0, 0.0)  in_map=1 srv_avoid=true  srv_3d=false srv_radius=0.700000
OBS obs3d=1 agent3d=0     safe=(2.0, 0.0, 0.0)  in_map=1 srv_avoid=true  srv_3d=true  srv_radius=0.700000
CONTROL agent_vs_agent_1.0 a_safe=(0.0, 0.0, 0.0)
```

Determinism: **4/4 reps byte-identical** (full-file md5
`0f9c780a33a727f40b165b74041c6745`).
**Two authoring hazards:** (a) the obstacle must be bound with
`obs.set_navigation_map(map)` or `obstacles_in_map` stays 0 and the whole cell
is vacuous — this seat's first pass fell into exactly that; (b) the agent's
velocity must be pushed through the RID, not `set_velocity()` (Cell A).

### Cell C — `navagent3d_cache` (rank 3)

**Claim under test:** the `NavigationAgent3D` getters split into *forcing* and
*non-forcing*; `get_path_length()` on a cold cache returns `0.0`; the path index
saturates at `size-1` and is not reset by a target re-assignment.

Eleven sub-cases (one fresh map/region/agent each, 5 settle frames, one getter,
then read the cache) plus a control — exact expected lines in §4. The
discriminating arms are `G1` vs `G2`: both are "read something about the path",
one yields `cached_path_n=2 idx=1`, the other `cached_path_n=0 idx=0` **and
returns `0.0`**. A negative arm that authors the wrong forcing set (e.g.
asserts `get_path_length()` forces) must fail with the measured `0.0`.

Determinism: 3/3 reps byte-identical. No motion, no avoidance — this cell is
immune to §3.2's non-determinism.

---

## 10. Remaining risks / unresolved

- **`NavigationAgent3D.set_velocity()` scope.** Measured inert with the agent
  parented under a driver and under the tree. **Unresolved:** an agent that is
  itself the `_physics_process` owner. Cell A should keep the driver pattern
  that was measured.
- **Avoidance partial magnitudes are process-nondeterministic** (§3.2). Any
  cell asserting an exact partial safe velocity will flake. Cells A and B use
  only saturated witnesses.
- **Ladder asymmetry** (`a` unaffected at separation 4.0 while `b` is braked
  to ≈-0.97): reproducible in sign, **mechanism unresolved**. Do not build a
  cell on it yet.
- **`Skeleton3D.motion_scale`** — unresolved (probe re-seeked instead of
  advancing frames). `B4_MOTION_SCALE_0.5` is not evidence of inertness.
- **`anim_death` A3 is not byte-deterministic** (5th-decimal `t`); any
  awaited-frame `current_animation_position` readout needs a tolerance (the
  landed fixtures use 0.002).
- **`anim_surface` C8 is superseded** (print-order artifact). Cite
  `anim_manual` instead.
- **The tree moved under this seat.** Registration claims are scoped to
  `run_battery.py` @ `991c6c8a…`; re-derive from the live file before landing
  anything.
- **`NavigationObstacle3D` + `use_3d_avoidance` default** is a *default-value*
  hazard, not a bug claim: this seat measured the behaviour, not the intent.
- No tracked file was modified by this seat; no fixture was authored. The three
  candidate cells are **pre-measured, not landed** — landing them is the
  author's move, and r85 wave-B owns `corpus/fixtures/` until it settles.
