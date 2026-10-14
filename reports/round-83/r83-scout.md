# game-dev-3d round 83 — scout (seat: scout, host: devin)

Pre-measurement of the r83 author's declared surface (`tasks/g3d-author.md`,
ARM = the PhysicsServer3D generated-event two-tier lattice), before it lands.
Read first: `SHARED.md`, `tasks/g3d-author.md`, r82 author report,
`reports/frontier/fb-physserver.md` (the port is empty at HEAD — see §5.1),
r82-scout. HEAD `f8a088c`; `git status --porcelain` clean except the
untracked `reports/round-83/` directory this seat's report lands in.
Scratch only: `corpus/live/r83-scout/` (`corpus/.gitignore:1 live/` — verified
ignored). No tracked file touched, no git mutation, no subagent.

**Runtime (every bound below is scoped to this).** `/usr/bin/godot`
`4.7.2.stable.arch_linux.ed1daf0bf` (2026-08-17, 182 015 704 B,
sha256 in `corpus/live/r83-scout/manifest.sha256`), `--headless --path <proj>
--script res://<probe>.gd`, `SceneTree` script, `physics/common/
physics_ticks_per_second=60`. Project variants (all under
`corpus/live/r83-scout/`): `proj` (defaults → GodotPhysics3D),
`proj_st` (`physics/3d/run_on_separate_thread=true`), `proj_jolt`
(`physics/3d/physics_engine="Jolt Physics"`), `proj_jolt_st` (both).

## 0. Method, viability, receipts

- Probes (all stdout-only witnesses, no timing thresholds):
  `backend_probe.gd` (backend fingerprint), `inv_probe.gd` (settings/ClassDB
  inventory), `mgr_probe.gd` (PhysicsServer3DManager surface), `fb_r83.gd`
  (the 18-arm battery-shaped sweep: `q_*` query family, `contact_*`,
  `sync_cb*`, `force_cb`, `signal_*`, `st_live`, `cast_raw`,
  `q_create_split`), `edge_probe.gd` (E1-E6 boundary cells),
  `tick_probe.gd` (at-tick write cells), `st_conv.gd` + `dss_probe.gd` +
  `st_live2.gd` (the separate-thread cells).
- Runners: `run_arms.sh` (r83 gen-1), `run_jolt.sh` (this generation, adds
  Jolt/ST sweeps + backend/liveness probes). 204 stdout receipts, 1.8 MB,
  pinned file-by-file in `manifest.sha256` (445 lines, built by
  `mkmanifest2.sh`). Every arm ran ×2 (some ×3/×10); `exit` recorded per run
  (184 `.exit`, plus 10 `.err` from the ×10 stability sweep).
  Naming note: `run_jolt.sh`'s `run()` builds `${proj}_${arm}`, so the
  arm-less invocations land as `runs/<proj>_.stdout.txt` — those four files
  are the `st_live2` rep-1 receipts, not backend-probe receipts (the backend
  probes were re-run as `bid2_*` after the collision was found).
- **Determinism.** All 18 `fb_r83` arms are byte-identical rep1↔rep2 under
  `proj` and under `proj_jolt` (diff of stdout after the version banner,
  0 differences); `proj_st` rep1↔rep2 likewise. `proj_st q_mv` re-run ×10:
  10/10 identical settled row, stderr 0 B.
- **`proj` vs `proj_st`: 42/42 arms byte-identical stdout, all stderr 0 B.**
  This is the headline of §3: the ST project file alone converts *nothing*
  observable in the `fb_r83` battery.

## 1. Viability gate — PhysicsServer3D backend inventory (Jolt present)

`inv_probe.gd` (`runs/inv.stdout.txt:4-…`), `mgr_probe.gd`
(`runs/mgr.stdout.txt`), `backend_probe.gd` (`runs/bid2_*.stdout.txt`):

- `physics/3d/physics_engine` hint_string = **`DEFAULT,Jolt Physics,
  GodotPhysics3D,Dummy`** (`runs/mgr.stdout.txt:75`); 2D =
  `DEFAULT,GodotPhysics2D,Dummy` (`:74` — no Jolt 2D in this build).
  Default setting value `DEFAULT`, `run_on_separate_thread=false`,
  `physics_ticks_per_second=60` (`runs/inv.stdout.txt:5,7-8`).
- **Jolt IS compiled in and selectable**: binary strings carry
  `module_jolt_physics_enabled`, `create_jolt_physics_server`,
  `modules/jolt_physics/jolt_physics_server_3d.cpp`; setting it changes
  measured physics (see the fingerprint table).
- `ClassDB.class_exists("JoltPhysicsServer3D")=false`,
  `GodotPhysicsServer3D=true`; the `PhysicsServer3D` singleton's `get_class()`
  is the **abstract base in both backends** (`class=PhysicsServer3D`,
  `is_class("GodotPhysicsServer3D")=false`, `is_class("PhysicsServer3DWrapMT")
  =false`; `runs/wrap_proj*.stdout.txt`) → **`is_class` on the singleton is not
  a backend discriminator**, and the Godot-3-style MT wrap class is absent from
  the binary.
- `PhysicsServer3DManager` exists (`runs/mgr.stdout.txt:4-5,68-73`): the only
  callable entry points are `register_server(name:StringName,
  create_callback:Callable)` and `set_default_server(name:StringName,
  priority:int)`; **there is no `get_server` / `get_server_count` /
  `get_default_server`** — GDScript cannot read the *active* backend from the
  manager. `ClassDB.instantiate("PhysicsServer3DManager")` returns a fresh
  object, not the live manager. (The `static=true` column in that receipt is a
  probe artifact — `flags & 1` is `METHOD_FLAG_NORMAL`, not a static test;
  ignore it.)

### Measured backend fingerprints (what the author may pin)

| discriminator | DEFAULT / GodotPhysics3D | Jolt Physics | usable? |
|---|---|---|---|
| `body_get_state(LINEAR_VELOCITY)` after setting 600 (clamp) | `(600,0,0)` → `(598.0016,0,0)` after 3 ticks | **`(500,0,0)`** → `(498.3347,0,0)` | **yes** — `runs/bid2_proj.stdout.txt:6-9` vs `runs/bid2_proj_jolt.stdout.txt:6-9` |
| `body_get_direct_state(rigid)` concrete class | `<GodotPhysicsDirectBodyState3D#…>` | `<JoltPhysicsDirectBodyState3D#…>` | **yes** — `runs/bid2_proj.stdout.txt:11` / `bid2_proj_jolt.stdout.txt:11` |
| `cast_motion` raw pair, sphere r=.5 from x=-2, motion +4 | `[0.12109375, 0.126953125]` | `[0.124755859375, 0.12548828125]` | **yes** (numeric) — `runs/proj_cast_raw.stdout.txt:4`, `runs/proj_jolt_cast_raw.stdout.txt:4` |
| sync callback, body asleep | `sleeping=3` invocations | **`sleeping=0`** | **yes** — `runs/proj_sync_cb4.stdout.txt:4` vs `runs/proj_jolt_sync_cb4.stdout.txt:4` |
| node `body_entered` frame (same fixture) | frame **9** | frame **7** | **yes** — `runs/proj_contact_signal.stdout.txt:11` vs `runs/proj_jolt_contact_signal.stdout.txt:7` |
| `Engine.get_singleton("PhysicsServer3D").is_class("GodotPhysicsServer3D")` | false | false | **no** |
| `body_get_direct_state(spaceless)` is null | true | true | **no** |
| `soft_body_create()` RID valid | true | true | **no** (Jolt supports soft bodies here) |
| instance-id string of the singleton (`<PhysicsServer3D#4479516912>`) | — | — | **no** — identical across separate processes, so it is not an identity witness (`runs/wrap_proj*.stdout.txt`) |

Recommendation: gate on the **setting enum + the velocity-clamp or the
direct-body-state class**, not on `is_class` or instance ids.

## 2. The discriminating cells — the two-tier claim, measured

`fb_r83.gd` geometry (mirrors the frontier probe): static box half-extents 1 at
A=(0,0,0); mid-frame write to B=(10,0,0); witnesses `ish0/ish10`
(`intersect_shape`), `castA/castB` (`cast_motion`), `btmA/btmB`
(`PhysicsServer3D.body_test_motion`), `get` (`body_get_state`).

**Query family = edge-0 same-turn. Confirmed, in every context measured.**
`runs/proj_q_mv.stdout.txt:4-5` — after the mid-frame transform write the same
turn reads `get=(10,0,0) ish0=false ish10=true castA=safe=1.000
castB=safe=0.121 btmA=none btmB=hit n=1 safe=0.121 pt=(9,0,0)`; unchanged at
n1-n3 (`:6-8`). Identical rows for:

- the write **inside `_physics_process`** (`q_mv_pp`, `runs/proj_q_mv_pp.stdout.txt:5`)
  and from the **idle `_process`** context (`q_mv_idle`, `:5`);
- a **rigid** body moved mid-frame (`contact_move` `ish_overlap=true` at
  `w0_sameturn`, `runs/proj_contact_move.stdout.txt:5`);
- **Jolt** (`runs/proj_jolt_q_mv.stdout.txt:5`, same flips, safe 0.125);
- with `run_on_separate_thread=true` (`runs/proj_st_q_mv.stdout.txt:5`).

**Verdict on the brief's declared partition.** Of the four named "generated
events", three are **not** tick-bound on this build: `body_test_motion`,
`cast_motion` and `intersect_shape` all flip **in the same turn** at the
mid-frame write (`runs/proj_q_mv.stdout.txt:5`, `btmA` hit→none,
`btmB` none→hit). They are *on-demand re-solves against the live broadphase*,
i.e. they belong to the query tier. The two-tier lattice is real, but the
partition line is **not** "queries vs generated events" — it is:

- **tier 0 — call-time solve** (edge-0 same-turn): `intersect_shape`,
  `cast_motion`, `body_test_motion`, `body_get_state`, layer/mask filters;
- **tier 1 — tick-produced state** (binds at the physics step): the contact
  manifold (`PhysicsDirectBodyState3D.get_contact_count()`,
  `RigidBody3D.get_contact_count()`, `body_entered`) and the engine callables
  (`body_set_state_sync_callback`, `body_set_force_integration_callback`).

Tier-1 witnesses:

| cell | witness |
|---|---|
| contact creation lags the query by exactly one tick | `contact_move` w0_sameturn `contacts=0 ish_overlap=true` → n1 `contacts=4` (`runs/proj_contact_move.stdout.txt:5-6`); `contact_create` w0 `contacts=0` → n1 `contacts=4` (`runs/proj_contact_create.stdout.txt:4-5`); same on Jolt (`runs/proj_jolt_contact_move.stdout.txt:5-6`) |
| at-tick write, same cell | `tick_probe contact_pp`: `pp_w0_sameturn`/`pp_w0_repeat`/`pp_turn1` all `frame=4 contacts=0 ish_overlap=true`, then `script_n1 frame=5 contacts=4` (`runs/proj_t_contact_pp.stdout.txt:4-8`) — the manifold is produced by the step that follows the write |
| node signal | `body_entered` fires at frame 9 with `contacts=4` while the poller read `contacts=0` at frame 8 (`runs/proj_contact_signal.stdout.txt:10-12`); Jolt frame 7 (`runs/proj_jolt_contact_signal.stdout.txt:9`) |
| contact **clearing** is ≥2 ticks behind | floor pulled away mid-frame: `w0_sameturn contacts=4`, n1 `contacts=4`, **n2 `contacts=0`** (`runs/proj_e5.stdout.txt:5-7`) — recycle lag, not a same-tick drop |
| contact reporting is opt-in per body | `max_contacts_reported=0` → `contacts=0` forever; `=4` → `4` from n2 (`runs/proj_e4.stdout.txt:4-6`) |
| `body_set_state_sync_callback` | fires **at the step** (`runs/proj_sync_cb3.stdout.txt:4-5`: `cb1_fire frame=2` then `scb3_tick n1 frame=2 invocations=1`); **arity-gated**: a 0-arg callable is never invoked (`runs/proj_sync_cb.stdout.txt:4-9`, `cb_static invocations=0`), a 1-arg callable gets the `PhysicsDirectBodyState3D`; on Jolt the 0-arg case raises `Method expected 0 argument(s), but called with 1` at `jolt_body_3d.cpp:1098` (`runs/proj_jolt_sync_cb.stderr.txt:1-2`) |
| invocation matrix (1-arg) | `static=0 sleeping=3 noreport=3 spaceless=0` on GodotPhysics (`runs/proj_sync_cb4.stdout.txt:4`); Jolt `sleeping=0` (`runs/proj_jolt_sync_cb4.stdout.txt:4`) |
| `body_set_force_integration_callback` | fires every step (`runs/proj_force_cb.stdout.txt:5-9`); userdata non-null → 2-arg call, userdata `null` → **1-arg call** (a 2-arg callable then errors: `runs/proj_jolt_st_.stderr.txt` / `st_live2` `_cb_fi`) |
| which callback carries the node contact machinery | clearing the **state-sync** callback freezes the node body completely (`y=0.5573` constant, `contacts=0` for 30 frames — `runs/proj_signal_mech.stdout.txt:4,11,34`), clearing the force-integration callback changes nothing (`runs/proj_signal_mech_fi.stdout.txt` tail `y=0.4900 contacts=4`) — backend-independent (`runs/proj_jolt_signal_mech.stdout.txt`, `…_mech_fi`) |

## 3. The run_on_separate_thread cell — the conversion is real but it is NOT in the battery's arms

`fb_r83`'s ST project is **measurement-inert**: 42/42 arms byte-identical to
non-ST (§0). The setting *is* read (`runs/proj_st_.stdout.txt:3`
`ST2 sep_thread=true ticks=60 engine=DEFAULT` — also confirming the duplicate
`[physics]` section in `proj_st/project.godot` merges rather than clobbers
`common/physics_ticks_per_second`), and thread inventory is unchanged (4 unnamed
+ 32 `WorkerThread` threads, identical name-multiset in both projects —
`runs/thr2_proj_task_2.txt`, `runs/thr2_proj_st_task_2.txt`), and a 300 ms
main-thread stall advances neither the frame counter, the callbacks, nor a
falling body (`runs/proj_st_.stdout.txt:6` `ST2 stall wall_ms=300 d_frames=0
d_fi=0 d_sync=0`, sync callback thread id 1 == main thread id 1 at `:4`;
`st_live dy=0.0000` in both projects, `runs/proj_st_st_live.stdout.txt:4`).

The real conversion is an **access-window gate**, measured by `st_conv.gd`
(both backends, reps stable; `runs/sc_proj_st_r1.stdout.txt`,
`runs/sc_proj_jolt_st_r1.stdout.txt`):

- **C1 acquisition** — `root.get_world_3d().direct_space_state` is **null** in
  the idle phase (`_process`: `:4 handle=null`) and valid inside
  `_physics_process` / on a `physics_frame` resume (`:5 handle=
  GodotPhysicsDirectSpaceState3D ish0=1 ish10=0 castA=safe=0.121`). Under
  ST=false both phases return the handle (`runs/sc_proj_r1.stdout.txt:4-5`).
  Guard text: `ERROR: Space state is inaccessible right now, wait for
  iteration or physics process notification.` at
  `modules/godot_physics_3d/godot_physics_server_3d.cpp:194` /
  `modules/jolt_physics/jolt_physics_server_3d.cpp:234`
  (`runs/sc_proj_st_r1.stderr.txt:1-2`, `runs/sc_proj_jolt_st_r1.stderr.txt:1-2`).
- **C2/C3 usage is NOT gated** — a tick-acquired handle used from the idle
  phase answers normally *and still binds edge-0 same-turn*:
  `C3 idle_write_sameturn frame=5 get=(10,0,0) ish0=0 ish10=1
  castA=safe=1.000 castB=safe=0.121` (`runs/sc_proj_st_r1.stdout.txt:8`; Jolt
  `runs/sc_proj_jolt_st_r1.stdout.txt:8`).
- **C4 `body_get_direct_state` IS gated by phase** — from the idle phase under
  ST it returns **null** (`BDS_NULL`, `:9,11`; `ERROR: Body state is
  inaccessible right now…` at `godot_physics_server_3d.cpp:952` /
  `jolt_physics_server_3d.cpp:969`), while ST=false returns a live state
  (`runs/sc_proj_r1.stdout.txt:9,11`). So an idle-phase contact-count sample
  under ST silently yields `null`, **not** "0 contacts".

**Hazard the author must not inherit (blockage class).** `fb_r83.gd` captures
`dss` in the deferred `_run()` — that capture point is phase-dependent:
`fb_r83` happened to land in the physics phase 36/36 arms and 10/10 extra
`q_mv` re-runs (`runs/stab_st_qmv_1..10.out`, stderr 0 B), while `tick_probe`
and `dss_probe` landed in the idle phase on **every** rep
(`runs/proj_st_t_contact_pp.stderr.txt:1-3` `_run (res://tick_probe.gd:112)`,
`runs/dss_proj_st_r1.stdout.txt:4-6`), which turns the handle null and makes
every query silently read "no hit" — `dss.intersect_shape` on null is a
`SCRIPT ERROR` per call, but the *stdout rows* look exactly like a legitimate
"query blind" cell (`q_disable`'s `ish0=false castA=safe=1.000 btmA=none`,
`runs/proj_q_disable.stdout.txt:5`). Any ST arm must therefore assert
`dss != null` (and `body_get_direct_state(...) != null`) and fail loudly, and
prefer capturing the handle inside the tick.

## 4. Edge members (boundary cells, measured)

| # | cell | measured | receipt |
|---|---|---|---|
| E1 | `body_test_motion` with a **spaceless** caster | returns `none` **and writes an engine ERROR to stderr** (`Parameter "body->get_space()" is null.` at `godot_physics_server_3d.cpp:943`; Jolt `Parameter "space" is null.` at `jolt_physics_server_3d.cpp:963`); same caster after `body_set_space` → `hit n=1 safe=0.121` (0.125 Jolt) | `runs/proj_e1.stdout.txt:4-5` + `.stderr.txt:1-2`; `runs/proj_jolt_e1.*` |
| E2 | mask flip on the **caster** body, mid-frame | `btm` flips same-turn (`none`→`hit n=1`), i.e. the mask binding is also edge-0 | `runs/proj_e2.stdout.txt:4-5` |
| E3 | body in space with **no shape** | `body_get_direct_state` is **non-null** (`bds_null=false`) while `intersect_shape`/`cast_motion` miss — distinguishes "no space" (null, frontier pin) from "no shape" | `runs/proj_e3.stdout.txt:4` |
| E4 | `max_contacts_reported=0` | contact count pinned at 0 forever | `runs/proj_e4.stdout.txt:4-6` |
| E5 | contact clearing | ≥2 ticks behind the write (recycle lag) | `runs/proj_e5.stdout.txt:5-7` |
| E6 | node `contact_monitor=false` | `rb.get_contact_count()` still reads **4**, `body_entered` never fires; setting `contact_monitor=true` afterwards **flushes the signal on the next tick** (`SIGNAL_FIRED frame=21`) | `runs/proj_e6.stdout.txt:4-5` |
| E7 | `q_create_split` (decomposed create edge) | `after_create`/`after_add_shape` are query-blind; the body becomes visible **the moment it enters the space** (`after_set_space ish0=true castA=safe=0.121`, same frame) — the binding point is `body_set_space`, not `body_add_shape` | `runs/proj_q_create_split.stdout.txt:4-6` (Jolt identical, safe 0.125) |
| E8 | shape disabled | `body_set_shape_disabled(body,0,true)` → same-turn all witnesses blind (`ish0=false castA=safe=1.000 btmA=none`) | `runs/proj_q_disable.stdout.txt:5` |
| E9 | layer flip | mask filter binds same-turn (`ish0_mask1` true→false, `mask2` false→true) | `runs/proj_q_layer.stdout.txt:4-5` |
| E10 | server contact surface on this build | `PhysicsServer3D` has **no** `intersect_shape`, `cast_motion`, `space_get_contacts`, `space_set_debug_contacts`, `body_set_enable_contact_monitor`; it has `body_test_motion`, `body_get_direct_state`, `body_set_max_contacts_reported`, `body_set_state_sync_callback`, `body_set_force_integration_callback` | `runs/api.stdout.txt:10-20` |

## 5. Blockages and author directives (exact)

1. **`ports/frontier/fb-physserver.md` does not exist** — the brief points at
   it; the file at HEAD is `reports/frontier/fb-physserver.md` (frozen copies
   in `corpus/live/r80..r83-baseline/frozen-extract/reports/frontier/`). Port
   path resolved by the author, not a probe failure.
2. **Re-partition the arm.** `body_test_motion` / `cast_motion` /
   `intersect_shape` are tier-0 (edge-0), not tick-bound; only the contact
   manifold and the two server callables are tier-1 (§2). Banking the brief's
   partition verbatim would land three falsified cells.
3. **The ST arm as declared does not convert** — the `fb_r83` ST battery is
   42/42 inert (§3). The convertible cell is *handle acquisition* (space/body
   direct state: tick-window-only under ST, both backends) plus the
   `BDS_NULL`-vs-0 contact-read distinction. Land that cell only with an
   explicit non-null assertion; otherwise an ST arm is a silent
   false-negative generator.
4. **Stderr is a signal, not noise**: E1 (`body_test_motion` on a spaceless
   caster) and the ST guards emit engine ERRORs on otherwise `exit=0` runs.
   A battery that only reads stdout will call those cells "measured".
5. **Two arity gates** are engine semantics worth pinning: state-sync
   callable must take 1 arg (0-arg silently never fires on GodotPhysics, hard
   error on Jolt); force-integration callable takes 2 args only when userdata
   is non-null.
6. **`cast_motion` return shape** differs across backends beyond the safe
   fraction (`[0.12109375, 0.126953125]` vs `[0.124755859375,
   0.12548828125]`) — pin both elements, or pin only `r[0]` and declare it.
7. **Contact surface is node/state-object only** on this build (E10): no
   `space_get_contacts`, no `body_set_enable_contact_monitor`. The contact
   tier must be sampled through `PhysicsDirectBodyState3D.get_contact_count()`
   (tick phase) or `RigidBody3D.get_contact_count()`.

## 6. Remaining unknowns

- Whether the ST handle gate is `using_threads && !doing_sync` or the space
  lock cannot be separated from GDScript; only the phase-dependence is
  measured (`godot_physics_server_3d.cpp:194,952`).
- The *cause* of the deferred-capture phase difference (`fb_r83` legal 46/46
  vs `tick_probe`/`dss_probe` illegal 100 %) is not isolated — candidates are
  script size/startup time and first-iteration physics-step count. Treated as
  a race; the guard in §5.3 is required either way.
- `body_entered` frame offset (GodotPhysics 9 vs Jolt 7) is pinned on one
  fixture geometry only; not generalized.
- No measurement of `Dummy` backend, of `physics_interpolation`, or of
  `max_physics_steps_per_frame` catch-up; none were in the declared surface.

**Seat output complete.** Evidence: `corpus/live/r83-scout/` (probes, 203
receipts, `manifest.sha256`). No claim above extends past this host, this
Godot build, `--headless`, and the named project variants.
