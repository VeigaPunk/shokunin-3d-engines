# game-dev-3d round 84 — scout (seat: scout, host: devin)

Wave `shokunin-train-20261101-w15`, lane g3d, arm `g3d-r84` (Godot backend
pinning). Assignment (`tasks/g3d-scout.md`, verbatim): "Measure FIRST in
`corpus/live/r84-scout/`: Jolt availability on this Godot build, per-arm
outcomes under a generated Jolt project (which arms re-bind, which differ on
constants, which invert), and the process-phase delta=2 prediction."
Read first: `SHARED.md`, `tasks/g3d-author.md` (+ the sibling briefs),
`reports/round-83/r83-scout.md`, r83-critic §1–§2, the landed fixture
`corpus/fixtures/phys3d_events.gd` (`1e042bcf…`, 611 lines).

Runtime (every bound below is scoped to this): `/usr/bin/godot`
`4.7.2.stable.arch_linux.ed1daf0bf` (182 015 704 B, sha256
`3a72f85d…cd4e72b`), `--headless`, 60 tps, 32 cores. HEAD `c4b2fa2`,
`git status --porcelain` = `?? reports/round-84/` only (another seat's report
landed there while this seat ran). Scratch: `corpus/live/r84-scout/`
(`corpus/.gitignore:1` ignores `live/`). No tracked file touched, no git
mutation, no subagent. Receipts: 75 run groups (75 `.stdout.txt` + 75
`.stderr.txt` + 75 `.exit`) + `runs/timing.txt` + 54 raw child logs, pinned in
`corpus/live/r84-scout/manifest.sha256`; read
`corpus/live/r84-scout/RECEIPTS.md` first — the `pj_`/`jj_` prefixes are
inverted from the intuitive reading (r84-scribe §4 flagged the same hazard
independently).

## 0. Method and determinism

- Projects (all under the scratch dir): `proj` (DEFAULT → GodotPhysics3D),
  `proj_jolt` (`physics/3d/physics_engine="Jolt Physics"`),
  `proj_bogus` (`…="Jolt Physics X"`, an unregistered name).
- Probes: `witness.gd` (`W`-line gate + fingerprint), `backend_line.gd` (the
  one-line `BACKEND …` child witness), `phase_probe.gd` / `phase_probe3.gd`
  (write-phase deltas), `jolt_child_probe.gd` / `jolt_child_probe2.gd`
  (runtime-generated Jolt project + child re-exec), `run_arms.sh`,
  `timing.sh`, `mkmanifest.sh`.
- **Determinism.** Every family is byte-identical across its reps: 10 arms ×2
  reps ×2 backends (`runs/{pj,jj}_<arm>.{1,2}`), 2 reps ×3 projects for
  `w2_*`/`bl_*`, 3 reps ×2 backends for `ph3_*`, and the generated-child
  probes run twice (parent DEFAULT and parent Jolt) with identical child
  outcomes. Every probe stream is clean (stderr 0 B) except the six
  Jolt-side arm failures that *are* the split (§2.2) and the three
  deliberately kept leak witnesses (§2.4).
- **Timing (receipt `runs/timing.txt`).** one arm 616 ms; `threaded_edge`
  (1 child) 1294 ms; 13 child spawns 9809 ms; `phase_probe3` 2239 ms. A
  5-arm child sweep therefore costs ≈3–4 s and a 10-arm sweep ≈6–7 s — both
  inside `run_battery.py`'s 20 s per-case bound (`CASE_TIMEOUT_SECONDS = 20`),
  but a 10-arm *sequential* child sweep is already ~1/3 of the case budget.

## 1. Jolt availability on this build — and what is NOT a gate

**Observed. Jolt is compiled in and selectable.** The setting's own enum hint
is `DEFAULT,Jolt Physics,GodotPhysics3D,Dummy` in all three projects
(`runs/w2_proj.1.stdout.txt`, `…_jolt…`, `…_bogus…`; `runs/bl_*.stdout.txt`).
Setting it converts the process — four independent in-process witnesses:

| witness | DEFAULT (`proj`) | Jolt (`proj_jolt`) |
|---|---|---|
| `root.get_world_3d().direct_space_state.get_class()` | `GodotPhysicsDirectSpaceState3D` | `JoltPhysicsDirectSpaceState3D` |
| `PhysicsServer3D.body_get_direct_state(rb).get_class()` | `GodotPhysicsDirectBodyState3D` | `JoltPhysicsDirectBodyState3D` |
| `ClassDB.class_exists("JoltPhysicsServer3D")` | `false` | `true` |
| velocity clamp (set 600, read after 1 tick, body clear of the wall) | `599.0` | `499.166656494141` |

Receipts: `runs/w2_proj.1.stdout.txt`, `runs/w2_proj_jolt.1.stdout.txt`,
`runs/bl_proj.{1,2}.stdout.txt`, `runs/bl_proj_jolt.{1,2}.stdout.txt`.

*Trap (measured).* The clamp witness needs a body clear of other geometry: an
unpositioned rigid body at the origin, overlapping the wall, reads
`clamp=0.00000113280475` under Jolt (not ~500) and `body_test_motion` misses
(`btm=none`) — a fixture defect that reads like a backend signal. The clean
`backend_line.gd`/`witness.gd` generations position the body at `(0,5,0)`
first; the defective first generation was fixed before any receipt in §1.

**Two negative results the author must not build a gate on.**

1. **`Engine.get_version_info()` carries no module keys** (`W vinfo_keys=[]`,
   `runs/w2_proj.1.stdout.txt:2`): the `module_jolt_physics_enabled` symbol
   r83-scout found is a *binary string*, not a runtime API. It cannot be read
   from GDScript.
2. **The setting string is not a backend witness.** With
   `3d/physics_engine="Jolt Physics X"` the process silently runs
   GodotPhysics3D — `setting_value` still reads back the bogus string, the
   space-state class is `GodotPhysicsDirectSpaceState3D`, the constants are
   the DEFAULT ones, **stderr is 0 B and no WARNING is emitted**
   (`runs/bl_proj_bogus.{1,2}.stdout.txt`, `runs/w2_proj_bogus.1.stdout.txt`).
   r84-boundary's 7-project table (r84-scribe §4) corroborates with the
   near-misses `Jolt`, `jolt physics`, `""` — all silent GodotPhysics3D. So
   `ProjectSettings.get_setting("physics/3d/physics_engine")` is a *request*,
   never a *state*; a typo'd or absent engine degrades silently and a
   "backend" row built on it is a false-positive generator.

**Gate the author should land (all four are GDScript-observable here).**
availability = the hint string contains `Jolt Physics` (the only enumeration
of registered servers — `PhysicsServer3DManager` exposes no
`get_server`/`get_server_count`, r83-scout §1); active backend asserted
*inside the child* = the space-state class (or `ClassDB.class_exists
("JoltPhysicsServer3D")`); availability absent → honest `blocked` row. The
nearest measured analogue of the absent path is the bogus-name path above:
silent DEFAULT fallback, so the *availability* check must be done
independently of the *selection* check.

**Limit (unresolved, not measured).** On this build `ClassDB.class_exists
("JoltPhysicsServer3D")` is `false` whenever Jolt is merely *not selected*
(DEFAULT project) and `true` when it is selected — so **no GDScript witness
separates "compiled in but not selected" from "absent"**; only the hint string
enumerates registered servers. Whether a Jolt-less binary's hint string omits
the entry is inference from the 2D hint (`DEFAULT,GodotPhysics2D,Dummy`, no
Jolt 2D, r83-scout §1) — unmeasurable on this host, which has Jolt compiled in.

## 2. Per-arm outcomes under a generated Jolt project — the split

### 2.1 The generated-project mechanics (measured, both parents)

`jolt_child_probe{,2}.gd` mirror `threaded_edge`'s thrproj pattern exactly
(runtime-written `project.godot` under `res://`, `/bin/sh -c "… > log 2>&1"`,
`timeout -s KILL 30`), with `3d/physics_engine="Jolt Physics"` instead of
`3d/run_on_separate_thread=true`.

- **A runtime-generated project's engine key DOES take effect.** The child
  witness under the generated `joltproj`/`joltproj2` reports
  `BACKEND engine=Jolt Physics hint_has_jolt=true
  space_class=JoltPhysicsDirectSpaceState3D server_class=true
  clamp=499.166656494141 cast=[0.14984130859375, 0.1500244140625]
  btm=-0.99853515625` — identical under a DEFAULT parent and a Jolt parent
  (`runs/jc_proj.stdout.txt`, `runs/jc_proj_jolt.stdout.txt`,
  `runs/jc2_proj.stdout.txt`, `runs/jc2_proj_jolt.stdout.txt`).
- **The child inherits NOTHING from the parent — including the backend.** The
  generated project written *without* an engine key runs GodotPhysics3D even
  when the parent is Jolt (`JOLTCHILD2 witness plain exit=0 BACKEND
  engine=DEFAULT … space_class=GodotPhysicsDirectSpaceState3D …`). Second,
  independent receipt: the tracked `threaded_edge` child, run under the Jolt
  project, emits the **GodotPhysics** guard text
  (`modules/godot_physics_3d/godot_physics_server_3d.cpp:194`) because its
  generated `thrproj/project.godot` has no engine key
  (`proj_jolt/thrproj/project.godot`, `proj_jolt/thrproj/child.log:3-5`).
  The `jolt_edge` child project must therefore write the key itself; the
  parent's own backend says nothing about the child.
- **The fixture copy must exist in the generated project iff the reduced set
  contains a self-spawning arm.** Spawning the fixture with `--script <abs
  path in the parent project>` + `--path <generated project>` works for all
  nine non-self-spawning arms (measured). `threaded_edge` resolves its own
  child script as `ProjectSettings.globalize_path("res://phys3d_events.gd")`
  *against the running project* (`phys3d_events.gd:521`), so in a generated
  project that lacks the copy its child dies with
  `ERROR: Attempt to open script '…/joltproj2/phys3d_events.gd' resulted in
  error 'File not found'.` and the arm fails
  (`proj/joltproj2/thrproj/child.log:3-7`, `runs/jc2_proj.stdout.txt`
  `jolt threaded_edge exit=1 … verdict=''`). With the fixture copied into the
  generated project the same arm passes byte-identically
  (`runs/te_in_joltproj2.stdout.txt`: exit 0, the tracked PASS marker, stderr
  0 B).
- **`--child` is already claimed and ignores `--arm`.** Spawning the fixture
  as `--child --arm=isect` under the generated Jolt project runs
  `_child_threaded()` — the ST child body — and prints
  `CHILD_NOTE early_null=false | CHILD_RESULT pp_edge0=true
  proc_dss_refused=false srv_ok=true` with **no arm marker**, exit 0
  (`runs/jc2_proj.stdout.txt` `JOLTCHILD2 collide …`). `--child` is checked
  before `--arm` is read (`phys3d_events.gd:201-205`). The `jolt_edge` child
  needs a distinct flag (or a keyed dispatch), or a `--child --arm=X` spawn
  silently measures the wrong body and reports success.

### 2.2 The split — all 10 landed arms, generated Jolt child and static Jolt project

Both routes agree row-for-row (static `proj_jolt` sweep `runs/jj_*`; generated
child `runs/jc2_proj.stdout.txt`, `runs/jc_proj.stdout.txt`), 2–3 observations
per arm, byte-identical.

| arm | DEFAULT (`proj`) | Jolt | class |
|---|---|---|---|
| `isect` | exit 0 `settled=1 mask2=0 away_w0=0 away_n1=0 back_w0=1` | **byte-identical stdout** | **same-signature** |
| `pp_queries` | exit 0 `ray_hit=false isect=0 safe=1.000000 btm=false travel=-10.000000` | identical | **same-signature** |
| `contact_stale` | exit 0 `in_w0_c=0 in_w0_isect=1 in_n1_c=4 out_w0_c=4 out_n1_c=0` | identical | **same-signature** |
| `contact_sig` | exit 0 `w0_fired=false w0_overlaps=0 n1_entered=true delta=1 n1_overlaps=1` | identical | **same-signature** |
| `sync_cb` | exit 0 `w0=0 n1=1 n3=3 static_cb=0` | identical | **same-signature** |
| `srv_area_cb` | exit 0 `enter=1 exit=1 reenter=1 all_delta1=true` | identical | **same-signature** |
| `threaded_edge` | exit 0 `pp_edge0=true proc_dss_refused=true srv_ok=true child_exit=0` | identical (its own child is DEFAULT+ST) | **same-signature** |
| `cast` | exit 0 `settled_safe=0.144531 settled_unsafe=0.150391 w0=1.000000 n1=1.000000` | exit 1 `cast settled fractions drift safe=0.14984130859375 unsafe=0.1500244140625` (`:247`) | **differs-constants** |
| `btm` | exit 0 `settled_hit=true settled_travel=-0.976562 w0_hit=false w0_travel=-10.000000 n1_hit=false` | exit 1 `btm setup wrong hit=true travel=(0.0, 0.0, -0.998535)` (`:272`) | **differs-constants** |
| `static_nopair` | exit **2** `NEGATIVE REJECTED: … static_tp_fired=false ticks=3 area_move_delta=1` | exit 1 `static_nopair drift tp=true ov=1 mv=true delta=1` (`:497`) | **inverts** |

Full-precision constants (receipts `runs/bl_proj_jolt.{1,2}.stdout.txt`,
`runs/w2_proj_jolt.{1,2}.stdout.txt`): `cast_motion` raw pair
`[0.14453125, 0.150390625]` → `[0.14984130859375, 0.1500244140625]`
(Δsafe = 5.31e-3 = **53× the fixture's 1e-4 tolerance**; Δunsafe = −3.66e-4);
`body_test_motion` settled travel `−0.9765625` → `−0.99853515625`. The
GodotPhysics3D/Jolt split is exactly r83-critic §2's reading, now re-measured
on all ten arms and through the generated-child route.

### 2.3 What the split does *not* say (actionable)

- The two `differs-constants` rows fail **at their settled-constant assertion,
  before the edge move** (`:247`, `:272`): under Jolt those rows carry **no
  lattice evidence at all** — not "the edge-0 claim also holds". A per-backend
  constant table (or a row that measures the constants and *then* the edge)
  is required for a Jolt row to keep measuring the lattice.
- **Exit code alone cannot classify.** same-signature = exit 0 + marker;
  `differs-constants` = exit 1 + failure text; `inverts` = exit 1 (DEFAULT 2).
  The parent must read the child's failure text or the child must print a
  structured verdict; and the fixture's `_fail()` calls `quit(1)`
  (`:126-131`), so a *single* child that asserts through the reduced set stops
  at the first drifting arm — one child per arm, or a child that measures
  instead of asserting.
- The three same-signature *event-tier* rows (`contact_stale`, `contact_sig`,
  `srv_area_cb`) plus the two query rows (`isect`, `pp_queries`) are the ones
  that carry the lattice under Jolt — 7/10 rows re-bind exactly.

### 2.4 Leak class (a FAIL-class hazard for any child)

An unfreed RID prints, **on stdout after the last marker**,
`ERROR: 3 RID allocations of type 'P11JoltShape3D' were leaked at exit.` /
`'P10JoltBody3D'` (Jolt) or `'P11GodotBody3D'` / `'P12GodotShape3D'` (DEFAULT),
plus `WARNING: 1 ObjectDB instance was leaked at exit` **on stderr**, with exit
still 0 — kept as the deliberate leak witness `runs/w_proj*.{stdout,stderr}.txt`
(superseded by the clean `w2_*` family, stderr 0 B). Both lines are FAIL-class
under `run_battery.py`'s rules ("any unexpected ERROR: line", ObjectDB leak).
The landed fixture frees on both paths (`_cleanup_nodes`/`_cleanup_rids`,
`:113-123`), so its failing Jolt arms show only their own `_fail` ERROR
(`runs/jj_cast.1.stderr.txt`) — the `jolt_edge` child must inherit that
discipline on *every* path, including the backend-witness print.

## 3. The process-phase delta=2 prediction (`phase_delta` arm)

`phase_probe3.gd` runs the three event-tier cells plus the query-tier control
from three write positions in one process, cells isolated (own bodies, own log,
freed between cells), 3 reps × 2 backends, all exit 0 / stderr 0 B
(`runs/ph3_proj.{1,2,3}`, `runs/ph3_proj_jolt.{1,2,3}`).

| cell | p1 `await physics_frame` (landed fixture) | p2 `await process_frame` | p3 inside `Node._process()` |
|---|---|---|---|
| query tier — `intersect_shape` after a wall teleport | `s0=1 w0=0 n1=0` (**edge-0**) | `s0=1 w0=0 n1=0` (edge-0) | `s0=1 w0=0 n1=0` (edge-0) |
| node `Area3D.body_entered` (rigid teleport) | `w0=0 n1=1 n2=1 n3=1` **delta=1** | `w0=0 n1=0 n2=1 n3=1` **delta=2** | **delta=2** |
| server `area_set_monitor_callback` (server write) | `n1=["0@f0+1"]` **delta=1** | `n1=[] n2=["0@f0+2"]` **delta=2** | **delta=2** |
| contact manifold (server write) | `w0=0 n1=4 n2=4 n3=4` **delta=1** | `w0=0 n1=0 n2=4 n3=4` **delta=2** | **delta=2** |

- **The prediction holds for all three event-tier cells at both idle
  sub-positions, on both backends** — the consumer shape (`_process`, and by
  phase-equivalence `set_deferred`/input callbacks, marked inference) measures
  delta=2 — not only in the coroutine shape the critic probed.
- **The query tier stays edge-0 in every phase** — within one arm the phase
  changes the event tier only (delta 0 vs 2), which is the cleanest single-cell
  statement of the r83 split.
- **`Engine.is_in_physics_frame()` exists on this build**
  (`PHASE start … has_phase_api=true`) and is an exact phase witness: `true` at
  p1, `false` at p2 and p3 (printed at the moment of each write). The
  `phase_delta` arm can therefore **assert its own write phase** instead of
  trusting the await idiom — a silent phase slip would otherwise turn the cell
  into an unexplained delta=1.
- **Pin deltas, never absolute frame numbers**: the Jolt project's reps 2–3
  write one physics frame later than rep 1 (`f0=6` vs `5`) while every delta is
  identical — a ±1 startup jitter in the absolute counter. The landed
  `contact_sig` computes `delta = sig_log[0] - f0` (delta-based) and is safe.
- **Backend-invariant**: the DEFAULT and Jolt phase lines are identical
  (modulo `space_class`/`engine` in the header); the phase rule is a property
  of the frame, as r83-critic measured, now at three sub-positions.
- Method note (self-caught): the first probe generation let cells share the
  world and the log, so a *previous* cell's bodies fired into the next cell's
  signal log and every process-phase cell read a stale `delta=-3`/`w0=4`. The
  fix is the same lesson as r83-critic C2's `sig_log.clear()` — clear the log
  immediately before the write and free each cell's nodes. The superseded
  generation was overwritten in the single-slot `ph_*` family (disclosed in
  `RECEIPTS.md`); `ph3_*` is authoritative.

## 4. Author directives (exact)

1. **Gate on availability + an in-child backend assertion**, never on the
   setting string (§1). Availability absent → `blocked`; a near-miss name
   silently yields DEFAULT, so the child must print the space-state class (or
   `ClassDB.class_exists("JoltPhysicsServer3D")`) and the parent must pin it.
2. **Write the engine key into the generated project** — nothing is inherited
   from the parent, backend included (§2.1). Verify with the generated child's
   own witness line, not with the parent's backend.
3. **Copy the fixture into the generated project iff the reduced set includes
   `threaded_edge`** (its child self-path is `res://`-relative, §2.1);
   otherwise spawning with the parent's absolute script path is enough.
4. **Do not reuse `--child`**: it is claimed by `threaded_edge`, is checked
   before `--arm`, and silently runs the ST child body (§2.1).
5. **Classify per arm by the child's failure text, not by exit code**
   (§2.3); one child per arm, or a child that measures instead of asserting.
6. **Free every RID on every child path** — a leak is FAIL-class and lands on
   *stdout* as well as stderr (§2.4).
7. **Keep the Jolt rows measuring**: `cast`/`btm` die at their settled
   constants under Jolt (53× the tolerance), so a Jolt-tolerant pin (per-backend
   constant table) or an explicit scope note is required for those two rows
   (§2.3).
8. **`phase_delta` arm**: assert the write phase with
   `Engine.is_in_physics_frame()` (available), pin deltas (not absolute frame
   numbers), and expect the query tier to stay edge-0 while the event tier
   moves to 2 (§3).

## 5. Remaining unknowns

- The *mechanism* of the Jolt static-body re-pair (Jolt's broadphase re-pairs a
  teleported STATIC body with a settled area; GodotPhysics3D does not) is
  **inference** from the inverted cell, not isolated.
- A Jolt-less binary's hint string / the true "absent" branch is unmeasurable
  on this host (Jolt is compiled in); only the bogus-name fallback is measured.
- The Jolt `cast`/`btm` constants are pinned on **this one fixture geometry
  only** (sphere r=0.5, motion (0,0,−10), box half-extent 1 at z=−3).
- The ±1 absolute-frame jitter on Jolt reps 2–3 is not isolated (startup race);
  deltas are stable.
- `Dummy` backend behaviour, `physics_interpolation`, and
  `max_physics_steps_per_frame` catch-up were not in the declared surface (the
  boundary seat owns the `Dummy`/gate variants).
- The Jolt `contact_sig`/`body_entered` absolute frame offset (r83-scout: 9 vs
  7) was not re-measured per backend here — only the deltas.

**Seat output complete.** Evidence: `corpus/live/r84-scout/` (6 Godot probes +
3 runners, 3 project variants, 75 run groups / 225 receipts + 54 child logs,
`manifest.sha256`, `RECEIPTS.md`). No claim above extends past this host, this
Godot build, `--headless`, and the named project variants.
