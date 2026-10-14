# game-dev-3d round 85 — scout (seat: scout, host: devin)

Wave `shokunin-train-20261101-w16`, lane g3d. Assignment
(`.ufo/waves/shokunin-train-20261101-w16/tasks/g3d-scout.md`, verbatim): "r85
SCOUT (g3d) — backend x threading surface map … Pre-measure the r85 frontier"
with the five listed probes (Jolt × threaded, Dummy backend inventory,
server-write surfaces, remaining backend gap, under-armed query surfaces).

Read first: `SHARED.md`, `tasks/g3d-{author,boundary,scribe}.md`,
`reports/round-84/r84-scout.md`, `r84-boundary.md` §1–§6, the landed fixture
`corpus/fixtures/phys3d_events.gd` (`e09e30ee1c8d62c7…`, 1036 lines).

**Runtime (every bound below is scoped to this):** `/usr/bin/godot`
`4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`, 60 tps, 32 cores. HEAD
`ac025b2`, `git status --porcelain` = `?? reports/round-85/` only. Scratch
`corpus/live/r85-scout/` (`corpus/.gitignore:1`); **no tracked file touched, no
git mutation, no subagent.** Receipts: 200 run groups (200 `.stdout.txt` + 200
`.stderr.txt` + 200 `.exit` + 199 `.ms`, 799 files) + 10 child logs, pinned in
`corpus/live/r85-scout/manifest.sha256` (840 lines). **Read
`corpus/live/r85-scout/RECEIPTS.md` first** — it names six reading hazards,
including the one family whose rc=1 is a probe artifact, not a finding, and one
superseded receipt slot that was removed rather than cited.

**LSP unavailability recorded.** `mcp_list_servers` exposes no `lsp` device for
this repo; every symbol fact below is engine-measured or read/grep-level, never
presented as semantic proof.

Method: six parent project variants (`proj` DEFAULT, `proj_jolt`,
`proj_dummy`, `proj_godot`, `proj_thr`, `proj_jolt_thr`) × 17 probes × 12 landed
arms; plus four child project variants (`gen/{jolt,jolt_thr,thr,dummy}`) running
the fixture's own `--child` bodies directly. Determinism: `tw_*` 2/2
byte-identical per variant; `twf_*` 2/2; the `tw2_*` delay sweep 2/2 per point;
the `lad_*` ladder 2/2 per point; the `ch_*` child bodies 1 run each but every
derived value re-derives from a second independent route (`sp_*`, `arm_*`).

---

## 1. Jolt × threaded — the split is threading-invariant; the *fetch* is not

### 1.1 The child route: byte-identical

The landed `_child_jolt` body run directly inside a **Jolt + `run_on_separate_thread=true`** project
(`runs/ch_joltedge_jolt_thr.*`) is **byte-identical** to the Jolt-only run
(`cmp` IDENTICAL; 1051 ms vs 1135 ms — no new timing class):

| verdict key | Jolt | Jolt+threaded |
|---|---|---|
| `jolt_backend` | `Jolt Physics` | identical |
| `jolt_dss_class` | `JoltPhysicsDirectSpaceState3D` | identical |
| `jolt_isect` | `same-signature` (`s0=1 m0=0 away=0 n1=0 back=1`) | identical |
| `jolt_cast` | `differs-constants` (`0.149841 / 0.150024`) | identical |
| `jolt_btm` | `differs-constants` (`t0=-0.998535`) | identical |
| `jolt_contact_stale` | `same-signature` (`set=0,1 in=0,1,4 out=4,0`) | identical |
| `jolt_static_nopair` | `inverts` (`tp=0,0,1,1,1,1,1,1 delta=1`) | identical |

The same child body under a **DEFAULT+threaded** project (`ch_joltedge_thr.*`)
prints `jolt_backend=unexpected`, `jolt_dss_class=GodotPhysicsDirectSpaceState3D`
and the *DEFAULT* constants (`cast=0.144531/0.150391`, `btm=-0.976562`,
`static_nopair=same-signature`) — `cmp` DIFFER from both Jolt runs. So the
verdict map tracks the **child project's** engine key and nothing else.

### 1.2 The parent route: 10/10 pass

The landed parent arms, with the fixture copied into the project dir (required:
the child path is `res://`-relative, §2.1 of r84-scout), pass under **every**
parent variant (`runs/sp_*`): `sp_{proj,proj_jolt,proj_thr,proj_jolt_thr,proj_dummy}_{threaded,jolt}`
= **rc 0 / 10**, each printing its exact landed PASS marker. A threaded or
Dummy *parent* is invisible to both arms — they measure the child project they
generate, never the parent's backend.

### 1.3 The fixture's own arm set under threading = the DEFAULT arm set

`runs/arm_proj_thr_*` vs `runs/arm_proj_*` (11 non-spawning arms each):
`cmp` IDENTICAL for `isect`; the full rc table is
`isect 0 cast 0 btm 0 pp_queries 0 contact_stale 0 contact_sig 0 sync_cb 0
srv_area_cb 0 static_nopair 2 phase_delta 0` in **both** variants — including
`phase_delta`'s `proc_delta=2 phys_delta=1`. `proj_jolt_thr` reproduces
`proj_jolt` row-for-row (`cast 1 btm 1 static_nopair 1`, rest 0). **The whole
r83/r84 lattice and the whole backend split survive `run_on_separate_thread`.**

### 1.4 New finding — the threaded fetch is a *script-size* accident

`thr_window.gd` maps eight fetch positions in one process, 2/2 per variant
(`runs/twf_*`):

| position | `proj` (DEFAULT) | `proj_thr` / `proj_jolt_thr` |
|---|---|---|
| A first statement of `_initialize` | non-null | **null** |
| B first statement of the deferred `_run` (the fixture's position) | non-null | **null** |
| C after `await process_frame` | non-null | **null** |
| D after 4 × `await physics_frame` | non-null | **non-null** |
| E inside `Node._physics_process` | non-null | **non-null** |
| F inside `Node._process` | non-null | **null** |
| G explicit `PhysicsServer3D.space_get_direct_state` at process context after D | non-null | **non-null** |
| H `PhysicsServer3D.body_get_direct_state` at process context after D | non-null | **non-null** |

The refused positions return **null silently** through
`World3D.direct_space_state` and raise a loud
`ERROR: Space state is inaccessible right now…` through the explicit server
call (`space_get_direct_state`, `godot_physics_server_3d.cpp:194` /
`jolt_physics_server_3d.cpp:234`). So the gate is *which main-thread position
you are in* — a physics-frame continuation or `_physics_process` is legal; the
idle frame and startup are not.

**But the fixture's `_run()` fetches at position B and succeeds.** A minimal
probe with the fixture's *exact preamble* does not: `thr_window3.gd --pre=5`
(child check → `_argval` → `wspace = …space` → fetch) is **null 2/2** on
`proj_thr` (`runs/lad_pre{1..5}_*`, all five preamble lengths null 2/2), while
the fixture is **non-null 6/6** on the same project dir. The discriminator is
**script load cost**, measured as a monotone ladder of otherwise-identical
probes (`runs/lad_sz{100,300,600,900}_*`; the padded variant adds an inner
class of N members to the same `thr_window3.gd` body):

| script lines | 138 | 338 | **638** | **938** | fixture (1036) |
|---|---|---|---|---|---|
| `dss` at position B under `proj_thr` | null 2/2 | null 2/2 | **non-null 2/2** | **non-null 2/2** | **non-null 6/6** |

`OS.delay_usec` does **not** move the window (`runs/tw2_*` sweep 0 → 64 ms, null
20/20) — blocking the main thread appears to prevent the very startup step that
releases the space, so the sweep is not a counter-example, it is a different
control.

**Confidence: high (observed).** Consequence: the fixture's threaded-parent
pass is an artifact of the fixture being ~1000 lines long. Any refactor that
shrinks it (or a minimal reproduction of an arm) flips the fetch to null and
turns **every** non-child arm into `_fail("dss null at process-context fetch")`
(`phys3d_events.gd:238-239`) — exit 1, no lattice evidence. This is a *row
stability* hazard, not a defect in any landed row.

---

## 2. Dummy backend — full inventory, and a hang

### 2.1 The state (`runs/binv_proj_dummy.*`, `tw_proj_dummy_*`, `dh_proj_dummy.*`)

| surface | Dummy | DEFAULT | Jolt |
|---|---|---|---|
| `physics/3d/physics_engine` readback | `Dummy` | `DEFAULT` | `Jolt Physics` |
| `PhysicsServer3D.get_class()` | **`PhysicsServer3DDummy`** | `PhysicsServer3D` | `PhysicsServer3D` |
| `root.get_world_3d().space` | **`RID(0)`** | `RID(98784247808)` | same as DEFAULT |
| `World3D.direct_space_state.get_class()` | **`PhysicsDirectSpaceState3DDummy`** | `GodotPhysicsDirectSpaceState3D` | `JoltPhysicsDirectSpaceState3D` |
| `PhysicsServer3D.space_get_direct_state(space)` | non-null `…Dummy` | non-null | non-null |
| `ClassDB.class_exists("PhysicsServer3DDummy")` | **true** | false | false |
| `ClassDB.class_exists("GodotPhysicsServer3D")` | false | true | **false** |
| `ClassDB.class_exists("JoltPhysicsServer3D")` | false | false | **true** |
| `PhysicsServer3D.body_get_direct_state(rid)` | **non-null** `PhysicsDirectBodyState3DDummy` | non-null | non-null |
| `PhysicsServer3D.box_shape_create()` / `body_create()` | **`RID(0)`** | real RIDs | real RIDs |
| `await physics_frame` | **fires** (4/4 in 76 ms) | fires | fires |

**The three ClassDB names are mutually exclusive per variant, 6/6 projects**
(`binv_*`: each `physics_class_list` contains exactly one of
`GodotPhysicsServer3D` / `JoltPhysicsServer3D` / `PhysicsServer3DDummy`; under
`jolt_thr` the Jolt *DSS* class is absent from the list while
`JoltPhysicsServer3D` is present). That gives a **3-way backend gate** the
landed 2-way `jolt_cls and not godot_cls` test (`phys3d_events.gd:794-803`)
does not name — and it is the only gate that survives a threaded project, where
the dss object is null.

### 2.2 What each query arm returns

| arm | Dummy (`qi_proj_dummy_*`, `tw_proj_dummy_*`, `dh_proj_dummy`) | DEFAULT / Jolt |
|---|---|---|
| `intersect_shape` | `0` | `1` |
| `intersect_ray` | empty Dictionary (`0`), **no error** | hit |
| `intersect_point` | `0` | `1` |
| `collide_shape` | `size 0` | `2` contact points |
| `get_rest_info` | empty Dictionary, `keys=[]` | 6 keys |
| `cast_motion` | **`PackedFloat32Array` size 0** at all three samples | size 2 |
| `body_test_motion` | `false`, `travel=0.000000` | `hit=true`, truncated travel |
| `body_get_state(rid, TRANSFORM)` | **`Nil`** (a null Variant, *not* a zeroed `Transform3D`) | a `Transform3D` |
| `area_get_transform` / area pairing | no area ever pairs | pairs |
| `free_rid(RID(0))` | no-op (no leak printed) | frees |

So Dummy is a **silent floor, not an error surface**: nothing throws on the
query calls themselves, and `get_overlapping_bodies()` / signal logs stay at 0.
The two hazards are both *type* hazards, not value hazards: a size-0
`cast_motion` and a `Nil` `body_get_state`.

### 2.3 The hang (reproduced twice, two scripts)

`runs/hang_dummy_thr.*` — the landed fixture as `--child --arm=threaded_edge`
inside a **Dummy** project: **rc 137 at the 20 s bound, stdout = 101 B (the
banner only — a silent hang), stderr two SCRIPT ERRORs**:

```
SCRIPT ERROR: Out of bounds get index '0' (on base: 'PackedFloat32Array')
  at: PPQueries._physics_process (phys3d_events.gd:209)
SCRIPT ERROR: Trying to assign value of type 'Nil' to a variable of type 'Transform3D'.
  at: _child_threaded (phys3d_events.gd:784)
```

`runs/dh_proj_dummy.*` (my own step-ladder mirror, 45 s bound → **rc 137**)
localises it: steps 0–8 complete (including `cast=0`, `btm=false travel=0.0`,
12 process frames), then **step 9 `body_get_state` → `Nil` → typed-assignment
SCRIPT ERROR aborts the coroutine before `quit()`** → the tree spins → the
harness bound kills it. Same class as r84-boundary §3's `cast_unguarded` 137,
now with a *second* trigger inside the landed fixture.

The parent-arm form is the same defect at the top level: `runs/arm_proj_dummy_cast`
= **rc 137 at 45 s** (unguarded `c0[0]` at `phys3d_events.gd:274`). Every other
Dummy arm is a clean named failure: `isect` `s0=0 mask2=0`; `phase_delta`
`n2=false,0 delta=-1`; `static_nopair` `mv=false delta=-1`; `pp_queries`
SCRIPT ERROR OOB at `:209` — all rc=1.

**The one landed body that IS Dummy-safe** is `_child_jolt`
(`runs/ch_joltedge_dummy.*`, rc 0, stderr 0 B, 1069 ms): all five arms classify
`unexpected`, `jolt_backend=unexpected`,
`jolt_dss_class=PhysicsDirectSpaceState3DDummy`, `jolt_cast degenerate
sizes=0,0,0`, and the r84-critic "positive evidence" guard fires exactly as
designed (no known class earned from zero reads). That is a ready-made Dummy
inventory body — its parent pin map must be the five `unexpected` values.

---

## 3. Server-write surfaces — the object-level lock, located

### 3.1 `body_set_state` vs `position =`, same callback, same RID

`runs/wn_*` — one `Node._physics_process` does WRITE then same-turn QUERY
(`write_node.gd`; `w0_isect` counts a wall at z=-3 **plus** the node moved to
z=-2.5, so `1` = "the write is not yet visible", `2` = "visible"):

| write | `w0_isect` | `body_get_state(rid).z` right after | `node.position.z` right after |
|---|---|---|---|
| `PhysicsServer3D.body_set_state(rid, TRANSFORM, …)` | **2** | **-2.5000** | -30.0000 |
| `StaticBody3D.position = …` | **1** | **-30.0000** | **-2.5000** |

- **The server write is same-turn visible to the query tier (edge-0) and is
  never reflected back into the node property.**
- **The node write is node-local and immediate, but server-visible only at the
  next physics tick (edge-1).**
- Persistence across ticks is measured in §3.2 (`aw_*` reads the same split at
  n1 **and** n3 for both the area and the body RID).
- The split is **identical** under Jolt (`wn_proj_jolt_srv/node`, same
  structure, only the cast/btm constants move: `0.149841/0.150024`,
  `btm_travel=-1.4984` vs `-1.4453`) and **identical** under threading
  (`wn_proj_thr_*` vs `wn_proj_*`: `diff` IDENTICAL for the srv cell; the
  in-callback fetch works, which is why the cell survives a threaded project).

### 3.2 The same rule for `Area3D`, with a read-back twist

`runs/aw_*` (DEFAULT and Jolt **cell-identical**, `diff` IDENTICAL modulo the
head line):

| step | query (`collide_with_areas`) | `area.position.z` | `area_get_transform.z` |
|---|---|---|---|
| area node write → w0 | **0** | **0.0** | -30.0 |
| area node write → n1 | **1** | 0.0 | **0.0** |
| body node write → w0 | **0** | 0.0 | -30.0 |
| body node write → n1 | **1** | 0.0 | **0.0** |
| **direct server write** → w0 | **1** | -30.0 | **0.0** |
| direct server write → n1, n3 | **1** | -30.0 | **0.0** |
| then an explicit node write → n1 | **0** | -30.0 | -30.0 |

So the rule is uniform across `Area3D` and `PhysicsBody3D`, and the direct
server write **sticks** (n1 and n3 unchanged) until a node write clobbers it
(last row). The node property and the physics world can therefore disagree
indefinitely — a direct server write is invisible to `node.position`, and a
node write silently reverts a prior server write.

### 3.3 Event-tier delta by write path — no path dependence

`runs/sw_*` (4 cells in one process, 1 rep, DEFAULT vs Jolt summaries
**IDENTICAL**; `write_in_phys` is captured *at* the write):

| cell | write path | write phase | `w0_sig` | `n1_sig` | `n2_sig` | delta |
|---|---|---|---|---|---|---|
| `np` | node `position =` | physics | 0 | 1 | 1 | **1** |
| `ns` | `body_set_state` | physics | 0 | 1 | 1 | **1** |
| `pp` | node `position =` | process | 0 | 0 | 1 | **2** |
| `ps` | `body_set_state` | process | 0 | 0 | 1 | **2** |

**The event-tier delta is a function of the write phase alone, not of the write
path** — the r84 `phase_delta` pin holds for a raw server write too, on the same
node RID. The sample-index conjuncts (`w0/n1/n2` fired+overlaps) are identical
across paths; only the phase moves them.

---

## 4. The remaining backend gap — exactly four values, no runtime switch

- **Hint enumeration, all 6 parent + 4 child project variants:**
  `physics/3d/physics_engine` = `DEFAULT,Jolt Physics,GodotPhysics3D,Dummy`
  (`hint_variants=4`, `prop_type=4` = String). **No fourth engine value is
  registered on this build.** The `physics/jolt_physics_3d/*` settings are
  registered in **every** variant including DEFAULT and Dummy, exactly like the
  hint — build-level, never backend state.
- **Of the three non-DEFAULT values, `GodotPhysics3D` is signature-identical to
  DEFAULT** (`binv_proj_godot` ≡ `binv_proj` on singleton, space RID, dss class,
  ClassDB; `tw_proj_godot` ≡ `tw_proj` on every query cell), and `Dummy` does
  not simulate (§2). So **`Jolt Physics` is the only non-DEFAULT value that
  changes behaviour** — and the only *working* alternatives are `Jolt Physics`
  and `GodotPhysics3D`.
- **There is no runtime path to a different server.** `PhysicsServer3DManager`
  exposes `register_server` and `set_default_server` (the only two
  non-`Object` methods on it), but `set_default_server(name)` raises
  `Expected 2 argument(s)` and `set_default_server(name, 1)` raises
  `ERROR: Condition "id == -1" is true. at: set_default_server
  (servers/physics_3d/physics_server_3d.cpp:1193)` for **all four** names tried
  — including the three registered ones and `NoSuchServer` (no validation
  difference) — and the singleton/dss are unchanged afterwards.
- **A runtime `ProjectSettings.set_setting` makes the readback lie.** Setting
  `"Jolt Physics"` at runtime reads back `Jolt Physics` while the live server
  stays `GodotPhysicsDirectSpaceState3D`, `PhysicsServer3D.get_class()` stays
  `PhysicsServer3D`, and a **newly created `World3D` also binds GodotPhysics**.
  This is a second, independent false-positive generator for the "setting is a
  request, never a state" rule (r84-scout §1): here the *readback itself* is
  wrong, not just a typo'd string.

---

## 5. Under-armed query surfaces — the asymmetry sweep

### 5.1 Coverage in the landed fixture

| `PhysicsDirectSpaceState3D` surface | armed as a write→read edge cell? |
|---|---|
| `intersect_shape` | yes (`isect`, `contact_stale`, `jolt_isect`) |
| `cast_motion` | yes (`cast`, `pp_queries`, `jolt_cast`) |
| `body_test_motion` (server) | yes (`btm`, `pp_queries`, `_child_threaded`, `jolt_btm`) |
| `intersect_ray` | **no** — only a *negative* read in `pp_queries` (`ray_hit=false` after the wall leaves); never a write→read edge |
| `intersect_point` | **absent** |
| `collide_shape` | **absent** |
| `get_rest_info` | **absent** |
| query→`Area3D` (`collide_with_areas`) | **absent** — the area tier is measured only through signals |
| node-write query edge | **absent** — every query-tier edge cell writes through the server |

### 5.2 Measured: all four missing surfaces bind edge-0, on both real backends

`runs/qi_*` (`q_inv.gd`; ray/rest are Dictionary-emptiness, not `.size()`):

| arm | DEFAULT | Jolt | Dummy |
|---|---|---|---|
| `ray_edge` | `s0=1 away_w0=0 away_n1=0 back_w0=1` **edge=true** | identical | `0/0/0/0` |
| `point_edge` | `s0=1 away_w0=0 away_n1=0 back_w0=1` **edge=true** | identical | `0` |
| `collide_edge` | `s0=2 away_w0=0 away_n1=0 back_w0=2` **edge=true** | identical | `0` |
| `rest_edge` | populated → empty → empty → populated, **edge=true** (`keys0=[point, normal, rid, collider_id, shape, linear_velocity]`) | identical | `keys0=[]` |

Ray controls, DEFAULT and Jolt identical: `mask2=0` (mask honoured),
`excluded=0` (exclude honoured), `inside_default=0` / `inside_on=1`
(`hit_from_inside` honoured). **The two-tier lattice extends to ray, point,
collide_shape and get_rest_info, unchanged, on both real backends** — so the
author can arm them as ordinary query-tier edge-0 rows.

### 5.3 The two real asymmetries

1. **Query→area is a different tier from query→body.** With
   `collide_with_areas=true`, a node-moved `Area3D` is invisible at w0 and
   visible at n1 (§3.2) — the same rule as a node-moved body, but the fixture
   has no cell that queries an area at all, so the area tier is currently
   *inferred* from signals rather than measured by query.
2. **The fixture's query-tier edge-0 claim is scoped to server writes.** Every
   query-tier edge cell writes via `PhysicsServer3D.body_set_state`; the node
   write is edge-1 (§3.1). A `node_write_query` contrast row would make that
   scope explicit and is the cheapest new discriminating cell on this frontier.

---

## 6. Author directives (exact)

1. **`jolt_threaded` must be a generated CHILD, not a parent arm**, and the
   child project must carry both keys itself (§1.1). The child split is
   byte-identical to Jolt-only — pin the *same* six-entry verdict map; add
   `jolt_threaded` as a second child-project axis rather than a second body.
2. **Do not reuse the `jolt_edge` log scanner for the threaded child.** The
   landed `jolt_edge` scan treats **any** `ERROR:` line as a defect
   (`phys3d_events.gd:724-727`); a threaded child emits three expected
   `ERROR: Space state is inaccessible right now…` lines from its own refusal
   loop (measured, `ch_thredge_{thr,jolt_thr}`). The `threaded_edge` whitelist
   (`:578`) is the correct scanner for that body. Note the *source file* in
   that line is backend-dependent (`godot_physics_server_3d.cpp:194` vs
   `jolt_physics_server_3d.cpp:234`) while the message text is not — key any
   whitelist on the text, never on the file.
3. **A Dummy cell must not reuse `--child --arm=threaded_edge`**: measured
   silent hang, rc 137, 101 B of stdout (§2.3). Use `_child_jolt` as the Dummy
   inventory body (Dummy-safe, exit 0, five `unexpected` verdicts) with its own
   `unexpected` pin map.
4. **Guard the two Dummy type hazards in every new arm**: `cast_motion()` can
   be size-0 (`phys3d_events.gd:274`, `:209`) and `body_get_state` can return
   `Nil` (`:784`) — the second aborts a coroutine before `quit()`, i.e. turns a
   FAIL into a 137 hang. `var g: Transform3D = …body_get_state(…)` must be a
   Variant-typed read with a null check, and every arm that awaits a bounded
   condition must bound by frames, not by an unbounded await.
5. **Gate the backend three ways, on ClassDB** (`JoltPhysicsServer3D` /
   `GodotPhysicsServer3D` / `PhysicsServer3DDummy`, mutually exclusive 6/6,
   §2.1) — the only gate that works inside a threaded project, where the dss
   object is null. Keep the dss class as the *in-child* active-backend witness
   where a project is not threaded.
6. **Never treat a threaded parent's process-context fetch as stable** (§1.4):
   it is legal only because the fixture is ~1000 lines long. Any arm that needs
   a dss under threading must fetch inside `_physics_process` (or from an
   `await physics_frame` continuation), never at `_run()`.
7. **Arm the four missing query surfaces** (ray/point/collide_shape/
   rest_info) as edge-0 rows — measured identical on DEFAULT and Jolt (§5.2) —
   and add the two contrast cells that make the scope explicit: a
   `node_write_query` edge-1 row and a query→area row (§5.3).
8. **Do not build a runtime backend switch**: `set_default_server` fails for
   every name (`id == -1`) and a runtime `ProjectSettings` write desyncs the
   readback from the live server (§4). The engine key must be written into the
   generated project file before spawn.

---

## 7. Remaining unknowns

- **Why** the threaded fetch window is script-size-dependent is **inference**
  (script load time crossing the physics thread's startup); the ladder is
  measured, the mechanism is not isolated. No counter-example to the ladder was
  found, and `OS.delay_usec` is not a valid control for it (§1.4).
- The `sp_*` parent-route pass is **1 rep per cell** (5 variants × 2 arms). The
  child-route byte-identity is 1 rep per child project; `arm_proj_thr_isect` was
  additionally re-run 3/3 by hand (no receipt — the three runs were inline).
- The `qi_proj_area_q` cell is **confounded** (a pending node write precedes the
  server write, so `srvwrite_n1=0` reads the node clobber, not a server-write
  failure). `aw_*` is authoritative for §3.2; the confounded cell is disclosed
  in `RECEIPTS.md`.
- The `aw_*`/`wn_*` server-write stickiness is measured on **this host, this
  build, one geometry**; the Dummy `Nil`/size-0 classes are measured on this
  build only.
- Jolt's `static_nopair` inversion *mechanism* (broadphase re-pair of a
  teleported static body) remains inference, unchanged from r84-scout §5.
- `physics_interpolation`, `max_physics_steps_per_frame`, `physics_jitter_fix`
  and `physics/3d/physics_interpolation/scene_traversal` were not in the
  declared surface and are unmeasured; `binv_*` lists them as present.
- The `thr_witness` in-callback query cell and the `wn_*` cell were not run
  under `Dummy + threaded` (the probe aborts on the `Nil` read first).

**Seat output complete.** Evidence: `corpus/live/r85-scout/` (17 probes, 10
project variants, 182 run groups / 546 receipts, 10 child logs,
`manifest.sha256`, `RECEIPTS.md`). No claim above extends past this host, this
Godot build, `--headless`, 60 tps, and the named project variants.
