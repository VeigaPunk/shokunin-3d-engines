# game-dev-3d round 83 — boundary (seat: boundary, host: devin)

Declared lane axis (dispatch brief, verbatim): "r83 BOUNDARY (g3d) — edge cells
+ negative controls … Edge cells for the PhysicsServer3D two-tier lattice:
backend-absent/blockage gates (Jolt vs GodotPhysics), run_on_separate_thread
interplay, mid-frame vs at-tick generated-event boundaries, RID/space-setup
preconditions, negative controls. Report -> reports/round-83/r83-boundary.md."

Wave `shokunin-train-20261101-w14`, lane g3d. This seat measures the boundary
lattice the r83 author brief's ARM implies — it does not implement the arm,
fold cells, judge, edit fixtures, or ship.

Lane root `~/Projects/shokunin/game-dev-3d-shokunin`, HEAD `f8a088c` (r82
report-last); working tree carries only untracked `reports/round-83/`
(`git status --porcelain` = `?? reports/round-83/`). No tracked file was
modified; no git mutation of any kind. Runtime: `/usr/bin/godot` =
`4.7.2.stable.arch_linux.ed1daf0bf` (2026-08-17), `--headless`, 60 tps; the
physics backend is `physics/3d/physics_engine` (DEFAULT → GodotPhysics3D
unless a run is named otherwise) and `physics/3d/run_on_separate_thread`
(false unless named). Every arm wrapped `timeout -s KILL` (carried guard).
**LSP unavailability recorded:** `mcp_list_servers` exposes only `rea`
(Ghidra binary analysis) — no `lsp` device serves this repo, so every symbol
fact below is engine-measured or text-level (read/grep), never presented as
semantic proof.

**Recovery context.** The prior generation of this seat died ~16:10Z. Its
scratch landed and is *verified and reused* here (§0): probe I
(`proj/r83b_edges.gd`, 18 arms run across the DEFAULT/thread/Jolt/Dummy
projects = 40 runs + 16 reps), the Jolt/thread/Dummy/fps/contact receipts,
the kill probes and the lane's own Godot battery. Probe II
(`proj/r83b_edges2.gd`, this seat, 17 arms) adds the arms the brief names that
probe I did not carry.

## (0) Viability and reuse basis

| check | command / receipt | exit | measured |
|---|---|---|---|
| lane battery at HEAD | `corpus/live/r83-boundary/battery-runs/20261014T160748529914Z/verdicts.json` + `battery-1.log` | PASS | Godot battery **176/176**, `seeds_unchanged=true`, `godot_version=4.7.2.stable.arch_linux.ed1daf0bf` (prior generation, 16:07:48Z) |
| probe-I determinism | `cmp` base vs `rep2-` stdout, 16 arms + `default-dss_{access,stress}` vs `rep2-dss_*` | — | **18/18 byte-identical** (contacts, cross_space_free, empty, fps, fps_delta, fps_negative, fps_zero, motion_edges, multi_space, node_freeze, omit, server_off, sleep, space_free_order, space_off, world3d_free, dss_access, dss_stress) |
| probe-I exit census (arrival) | `grep -l` over `runs/*.exit` | — | 40 non-rep2 runs (4 Jolt arm names, **5 runs at exit 134** incl. the `crash-forward-cleanup` variant) + 16 `rep2-` runs; every GodotPhysics arm 0 |
| probe-I inventory facts reused | `runs/{inventory,jolt-inventory,dummy-inventory}.stdout.txt` | 0 | §1(a) |
| probe-II syntax gate | first `r83b_edges2.gd` run | — | `SCRIPT ERROR: Parse Error: Too few arguments for "set_default_server()" call. Expected at least 2` → the manager API takes `(name, priority)`; fixed, re-run green (§1(b)) |
| probe II sha | `sha256sum proj/r83b_edges2.gd` | — | `5386871523e60d612f258ea68bdfe5e84b2ae7953c2bc25f595f371373785741`, identical in `proj/`, `proj_thread/`, `proj_jolt/` |

Probe II arms run under three projects: `proj/` (DEFAULT/GodotPhysics,
60 tps), `proj_thread/` (`run_on_separate_thread=true`), `proj_jolt/`
(`physics_engine="Jolt Physics"`); runner `run_edges.sh` (`SCRIPT`, `PROJ`,
`PREFIX`, `LIMIT=30`, `timeout -s KILL` per arm). Receipts `runs/<prefix><arm>.{stdout.txt,stderr.txt,exit}`.

## (1) Backend-absent / blockage gates

### (a) The project setting is the effective gate (class registry flips)

| project | `physics/3d/physics_engine` | `CLASSEXISTS JoltPhysicsServer3D` | `CLASSEXISTS GodotPhysicsServer3D` | `SINGLETON PhysicsServer3D class` | world space |
|---|---|---|---|---|---|
| `proj/` (DEFAULT) | `DEFAULT` | **false** | true | `PhysicsServer3D` | `RID(98784247808)` |
| `proj_jolt/` | `Jolt Physics` | **true** | false | `PhysicsServer3D` | `RID(98784247808)` |
| `proj_dummy/` | `Dummy` | false | false | **`PhysicsServer3DDummy`** | **`RID(0)`** |

(`runs/inventory.stdout.txt`, `runs/jolt-inventory.stdout.txt`,
`runs/dummy-inventory.stdout.txt`; hint line
`PROP physics/3d/physics_engine hint= DEFAULT,Jolt Physics,GodotPhysics3D,Dummy`.)
So "Jolt absent" is not a property of the build but of the *selection*: the
same binary registers Jolt only when the setting selects it.

### (b) The runtime manager route is a loud refusal, not a switch

`mgr_gate` (`runs/mgr_gate.stdout.txt`, stderr 3× `ERROR: Condition "id == -1"
is true. at: set_default_server (servers/physics_3d/physics_server_3d.cpp:1193)`
for the first three calls; rep2 stderr byte-identical):

```
BND mgr signatures=["register_server(name:String,create_callback:Callable)", "set_default_server(name:String,priority:int)", ...]
BND mgr class_before=PhysicsServer3D
BND mgr class_after_jolt_absent=PhysicsServer3D      # ERROR id == -1
BND mgr class_after_unknown=PhysicsServer3D          # ERROR id == -1
BND mgr class_after_godot=PhysicsServer3D            # ERROR id == -1
BND mgr class_after_dummy=PhysicsServer3D            # no error, still unchanged
```

`set_default_server` needs `(name, priority)`; with an unregistered name
(Jolt under DEFAULT, an unknown string, even `"GodotPhysicsServer3D"`) it
raises `Condition "id == -1"` and leaves the singleton class unchanged.
`"Dummy"` is a registered name (no error) yet still produces no observable
swap in the same run. **Bounded claim:** on this build the runtime manager
cannot re-point the live server; the effective backend gate is the project
setting read at server creation. A "backend-absent gate" implemented by
calling the manager is therefore a *loud no-op*, and any probe that infers the
backend from `get_class()` after such a call infers nothing.

### (c) The Dummy floor (reused receipts, first reading in this report)

`dummy-{inventory,empty,sleep,multi_space}`: every RID is `RID(0)`,
`body_get_state` returns `null` (`sleep=<null> can=<null>`), `intersect_ray`
misses, `intersect_shape` counts 0, `cast_motion=[]` (an **empty** array —
whereas real backends return `[1.0,1.0]` for "no collision"),
`body_test_motion=false travel=0,0,0` (vs full travel on real backends), and
`space active=false` for a space the API reports as created. No call errors.
So on the Dummy backend every edge cell reads 0 *because nothing is
simulated*; any lattice pin must be conditioned on the backend class, and any
consumer that indexes `cast_motion()[0..1]` breaks on this backend.

## (2) Generated-event same-turn edges — the query tier is edge-0 everywhere

`_gen_line` (probe II) writes the target box from A=(0,0,0) to B=(10,0,0) via
`body_set_state(BODY_STATE_TRANSFORM)` **mid-frame from the deferred context**
and re-reads the whole query family in the same turn; `gen_back_w0` writes it
back. GodotPhysics, `runs/gen_edges.stdout.txt`:

| tag | `intersect_shape` A / B | `cast_motion` A / B | `intersect_ray` A / B | `body_test_motion` |
|---|---|---|---|---|
| `gen_pre` | 1 / 0 | `[0.34765625,0.3515625]` / `[1.0,1.0]` | hit / miss | `true travel=0,-2.9687,0` |
| `gen_w0` (same turn) | **0 / 1** | **`[1.0,1.0]` / `[0.34765625,0.3515625]`** | **miss / hit** | **`false travel=0,-10,0`** |
| `gen_n1` | 0 / 1 | as `w0` | miss / hit | as `w0` |
| `gen_back_w0` | 1 / 0 | as `pre` | hit / miss | as `pre` |

Every query surface — ray, shape, cast, motion — rebinds **in the same turn as
the write**, and the reverse write rebinds back in the same turn, so the edge
is a function of the write and not of a settling window. Same values under
`run_on_separate_thread=true` (`runs/thread-gen_edges.stdout.txt`; its `BND`
lines are identical to the DEFAULT stream, the only stream difference being the
ARM header's `sep_thread` field) and under Jolt (`runs/jolt-gen_edges.stdout.txt`, edge
identical, geometry differs: cast `[0.3499755859375,0.35009765625]`,
`btm travel=0,-2.9993,0` — Jolt lands on 3.5/3.0 exactly, GodotPhysics stops
~0.023/0.031 early; a per-backend margin constant, **not** an edge difference).

- **At-tick** (`gen_edges_pp`, `runs/gen_edges_pp.stdout.txt`): inside one
  `_physics_process` callback, `x_before=0.0000 ray_at_B=miss ray_at_A=hit
  isect_B=0` then `x_sametick=4.0000 ray_at_B=hit ray_at_A=miss isect_B=1
  cast_B=[0.34765625,0.3515625]` → the same-tick flip holds, so the edge does
  not depend on being mid-frame either.
- **Server-created space** (`gen_edges_space`, `runs/gen_edges_space.stdout.txt`):
  identical to the world space (`spc_pre`/`spc_w0`/`spc_n1`), so the
  precondition for the cell is only `space_set_active(true)` plus a DSS handle.

## (3) The two-tier split, positioned: contacts are the tick tier

`contact_teleport` (probe II) teleports a rigid monitor body into overlap with
a static target **mid-frame** and reads the query family and the generated
contact count in the same turn (`runs/contact_teleport.stdout.txt`, DEFAULT):

```
BND ct pre cc=0 x=0.0000  isect_overlap=1 isect_start=1
BND ct w0  cc=0 x=19.0000 isect_overlap=2 isect_start=0 ray_overlap=hit bds=true   <- same turn
BND ct n1  cc=4 x=18.2080                                                          <- next tick
BND ct n2  cc=4 x=18.0496
```

At-tick variant (teleport inside `_physics_process`, read the count in the
**same callback**): `ct_pp_n1 pre cc=0 x=0.0000` → `ct_pp_n1 sametick cc=0
x=19.0000`; later callbacks read the *previous step's* product
(`ct_pp_n2 pre cc=8` → `sametick cc=8`; `ct_pp_n3 pre cc=4` → `sametick cc=4`).

**Finding (the discriminating cell).** In one receipt the two tiers separate:
the query family flips in the same turn as the write (edge 0) while the
generated contact count does not move until the step runs (edge 1 tick), and a
same-callback read after a fresh overlap teleport still reports the *pre-step*
value. So the author brief's "generated events bind at the physics tick" is
**true for contact generation and false for the query family** — the two-tier
lattice is a *tier split by event kind*, not a per-call tick window.
Reproduces under `run_on_separate_thread=true` (identical `BND` lines,
`runs/thread-contact_teleport.stdout.txt`) and under Jolt
(`runs/jolt-contact_teleport.stdout.txt`; counts 4/8 as on GodotPhysics,
separation distances differ: x=18.92/18.84 vs 18.208/18.0496).

Cross-check from probe I (`runs/contacts.stdout.txt`, natural fall, 80 ticks):
contact count 0 for t01–t42, first non-zero at **t43** (the landing tick),
saturating at 4 for `max_contacts_reported` 4 and 8, and never non-zero for
cap 0 — the count is a step product on the natural path too.

## (4) `run_on_separate_thread` interplay

| cell | receipt | measured |
|---|---|---|
| mid-frame write → object truth | `runs/thread-thread_convert.stdout.txt` | `tc midframe x_readback=4.0000` — the setter is inline in the server, same turn |
| mid-frame write → space truth | same | `dss=true ray_A=miss ray_B=hit isect_B=1` — the space sees the new transform same-turn, mid-frame |
| at-tick after a mid-frame write | same | `tc_pp_n1 x_before=4.0000 ray_at_B=hit ray_at_A=miss isect_B=1 cast_B=[0.34765625,0.3515625]` — no inline→deferred conversion in the write→query direction |
| object truth handle | same | `tc bds_here=true` — `body_get_direct_state` answers from the process context |
| DSS gate | `runs/thread-dss_hole.stdout.txt` | process-context sampling: `total=200 nulls=199 first_ok=0`; physics-frame sampling: `total=120 nulls=1 first_ok=1` |
| DSS gate, control | `runs/dss_hole.stdout.txt` | DEFAULT: `nulls=0` in both loops |
| gate error text | `runs/thread-inventory.stderr.txt` | `ERROR: Space state is inaccessible right now, wait for iteration or physics process notification. at: space_get_direct_state (…godot_physics_server_3d.cpp:194)` |
| prior stress cell, now attributed | `runs/thread-dss_stress.stdout.txt` | `dss_stress_process total=150 nulls=149` = the same shape; `first_ok=0` in probe II locates the one non-null sample at the **first** process-frame sample (startup hole), not a random window |

Bounded reading: under separate-thread stepping the process-context DSS gate is
a **timing race with a startup hole** — it is not a hard lock, and code that
takes a handle at the first sample would hold a live object while later calls
return null. Nothing in §2/§3 moves under this setting: the edge cells are
byte-identical to DEFAULT.

## (5) RID / space-setup preconditions

### (a) Freeing a space invalidates a held `PhysicsDirectSpaceState3D` — fatal to the run

`space_precond` (DEFAULT, `runs/space_precond.{stdout,stderr}.txt`; exit **137**):

```
BND spc pre dss=true ray=hit count=1
BND spc freeing_space_with_body_attached
SCRIPT ERROR: Invalid type in function '_hit' … The Object-derived class of argument 1
  (previously freed) is not a subclass of the expected argument class.
  at: _run (res://r83b_edges2.gd:365)      [0] _run (res://r83b_edges2.gd:365)
```

Mechanism (inference, marked): `free_rid(space)` destroys the space object the
DSS handle points at; the next *use* of the handle is a hard script error, the
arm aborts before `quit()`, the `SceneTree` keeps spinning, and the runner's
`timeout -s KILL` ends the process at 30 s. The "hang" is therefore
abort-without-quit, **not** a physics deadlock; the same receipt shape appears
under separate-thread (`runs/thread-space_precond`, exit 137) and under Jolt
(`runs/jolt-space_precond`, exit 137) — backend-independent.

Controls, one variable each (all exit 0, all clean):

| control | receipt | measured |
|---|---|---|
| no DSS handle at all | `runs/space_precond_nodss.stdout.txt` | `free_rid(space)` with a body attached, then `free_rid(body)` → both clean |
| DSS held but never used after the free | `runs/space_precond_holddss_only.stdout.txt` | `space_freed_dss_held_unqueued` → clean |
| fresh DSS after the free | `runs/space_precond_querydss_after.stdout.txt` | `dss_after_free=false` + `ERROR: Parameter "space" is null. at: space_get_direct_state (…godot_physics_server_3d.cpp:193)` → loud, null |

### (b) Freed `shape_rid` = loud error + empty result

`neg_controls` (`runs/neg_controls.stdout.txt`, stderr
`ERROR: Parameter "shape" is null. at: intersect_shape (…godot_space_3d.cpp:216)`,
probe line 449 = the **post-free** call): a query built with only
`p.shape_rid` (server shape, `p.shape` = null) answers **1** while the RID is
valid (`shape_rid_only p_shape=<Object#null> rid_valid=true`), and **0** after
`free_rid(srid)`. Contrast the r82 frontier's freed *body*: a ray against a
freed body misses **silently**. Stale RID-shaped handles and stale object
handles behave differently: the former degrades loudly-to-empty, the latter
raises a fatal object error (§5(a)).

### (c) Free-order matrix — GodotPhysics tolerates, Jolt segfaults

One cell per process, a marker printed before every free, so the crash site is
the last marker printed. GodotPhysics (`proj/`) vs Jolt (`proj_jolt/`):

| arm | GodotPhysics | Jolt | Jolt crash site |
|---|---|---|---|
| body free → space free | 0 clean | **0 clean** | — |
| space free → body free | 0 clean | **134 SIGSEGV** | `free_rid(b)` `r83b_edges2.gd:537` |
| World3D released → body free | 0 clean | **134 SIGSEGV** | `free_rid(b)` `r83b_edges2.gd:551` |
| space free with body attached → body free (no DSS) | 0 clean | **134 SIGSEGV** | `free_rid(b)` `r83b_edges2.gd:313` |
| `free_rid(body)` twice | 0 + `ERROR: Invalid ID. (…godot_physics_server_3d.cpp:1662)` | 0 + `ERROR: Failed to free RID: The specified RID has no owner. (…jolt_physics_server_3d.cpp:1598)` | — |
| body free → shape free | 0 clean | 0 clean | — |

The fault class is exactly **`free_rid(body)` whose space is already gone**
(three independent probe-II cells, plus probe I's `jolt-space_free_order`
(`r83b_edges.gd:471`), `jolt-world3d_free` (`:506`) and the `jolt-multi_space`
teardown crash in `_cleanup` (`:144`), where the World3D holding `b3` was
garbage-collected before cleanup). Every Jolt crash reproduced **2/2**
(134 → 134). Jolt's *teardown* crash is not fully deterministic: the stored
`jolt-space_off` pair carries **byte-identical stdout with exits 0 and 134**
(`runs/jolt-space_off.{stdout.txt,exit}` vs
`runs/jolt-space_off.crash-forward-cleanup.{stdout.txt,exit}`); the
`crash-forward-cleanup` label refers to a cleanup-order variant that does not
exist in the surviving probe script (script mtime 13:06:58Z, after that run's
13:06:39Z receipt) — recorded as an unresolved provenance gap, not adopted.

## (6) Negative controls

| control | receipt | measured |
|---|---|---|
| cross-space isolation | `runs/neg_controls.stdout.txt` | `s1_count=1 s2_count=0`; a second body in s1 → `s1_after_second_body=1 s2_still=0` |
| shape query, mask 0 | same | `s1_shape_mask0=0` |
| shape query, `collide_with_bodies=false` | same | `s1_nobodies=0` |
| ray, mask 0 | same | `s1_ray_mask0=miss` |
| cast, mask 0 vs default/mask 1 | same | `cast_mask0=[1.0,1.0]` vs `cast_default=[0.34765625,0.3515625]`, `cast_mask1=[0.34765625,0.3515625]` |
| motion query, disabled target shape | `runs/motion_edges.stdout.txt` | `motion_shape_disabled=false travel=0,-10,0` (full travel = no hit) |
| motion query, sleeping / omit / inactive space | same | `motion_asleep=true travel=…-2.9687…`, `motion_omit=true …`, `motion_space_inactive=true …` — the motion query is **not** gated by `space_set_active`, and `inactive_ray=hit:RID(…)` shows rays are not either |
| motion query, motion = 0 | same | `motion_zero=false travel=0,0,0` |
| no-shape / spaceless body | `runs/empty.stdout.txt` | `noshape body_test_motion=false travel=0,-4,0`; `static_motion_self=false travel=0,-10,0`; inactive server space still answers `ray=miss count=0 cast_motion=[1.0,1.0]` |
| tick-rate gate | `runs/fps_zero.stderr.txt`, `fps_negative.stderr.txt` | `Engine.physics_ticks_per_second = 0 / -30` → `ERROR: Engine iterations per second must be greater than 0. (core/config/engine.cpp:49)`, readback stays 60 → loud refusal (these two streams are the ones the scribe flagged as classifier-dirty: intentional) |

## (7) Determinism / byte-stability

- Probe II: **29/29** base↔rep2 stdout pairs byte-identical (15 DEFAULT, 5
  thread, 9 Jolt, incl. all four crash/hang classes), and the crash/hang exits
  reproduce (`134→134` ×3, `137→137` ×2). `mgr_gate`'s stderr is byte-identical
  across reps too (the engine error text is deterministic).
- Probe I: 18/18 base↔rep2 pairs byte-identical (§0).
- Jolt's per-backend geometry constants differ from GodotPhysics (cast
  fraction, motion travel) — backend-bounded values, not drift.
- Exit conventions inside this lane are **not uniform**: `runs/inventory.exit`
  contains `exit=0\n` (a different writer) while `run_edges.sh` writes a bare
  `0`; the kill receipts carry their semantics in `.report.txt` with empty
  `.exit`. Corroborates the r83-scribe cross-harness convention hazard.

## (8) Deltas vs prior rounds

1. **The query family is edge-0 beyond `intersect_ray`** (the r82 frontier
   pinned rays only): `intersect_shape`, `cast_motion` and `body_test_motion`
   all rebind in the same turn as the write — mid-frame and at-tick, in the
   world space and in a server-created space, single- and separate-thread,
   GodotPhysics and Jolt.
2. **The two-tier lattice is positioned by event kind, not by call site**: the
   tick tier is *contact generation* (count/state), while the query results
   are the same-turn tier — demonstrated with both tiers in one receipt
   (§3), with the natural-fall cross-check from probe I.
3. **`set_default_server` is a loud-refusal gate** (new): the class registry
   flips only via the project setting; the runtime manager call errors and
   changes nothing.
4. **A freed space invalidates a held DSS into a fatal object error** (new),
   and that — not a physics deadlock — is the mechanism behind the exit-137
   "hang" arms; three one-variable controls separate it from the free order.
5. **Jolt free-order matrix with per-cell attribution** (new): the fatal call
   is `free_rid(body)` after the space is gone; GodotPhysics tolerates the same
   orders (and reports double free loudly).
6. **The separate-thread DSS gate has a startup hole** at the first
   process-frame sample — probe I's 149/150 is now attributed rather than a
   random window.
7. **Dummy-backend floor characterized** (reused receipts, first reading
   here): RID(0)/null/empty-array returns with no errors; `cast_motion()`
   returns an empty array on this backend.

## (9) Remaining unknowns

- Contact **signal** emission timing (`body_entered`/area signals) is not
  measured here — the critic seat's cells; this seat pins the count/state side.
- The DSS startup hole was sampled for null-ness only; whether the handle
  obtained at the first sample stays usable after the physics thread starts is
  unmeasured.
- Jolt teardown-crash dependence on cleanup order is unresolved (the
  `crash-forward-cleanup` receipts' provenance, §5(c)).
- Only body/space/shape RIDs were exercised in the free-order matrix; area and
  soft-body RIDs are unprobed.
- `cast_motion` returning `[]` on Dummy vs `[1.0,1.0]` on real backends is
  recorded as a consumer hazard, not generalized to other query methods.
- Per-backend margin constants (cast fraction, motion travel) are measured on
  two backends only; no cross-build claim.
- The 30 s hang is bounded by `timeout -s KILL`; no claim that the spin is
  unbounded.
- Every claim is bounded to this host and Godot
  `4.7.2.stable.arch_linux.ed1daf0bf`.

## (10) Scope guards carried

- reorder topology = the fd1-OWNER's buffering mode — untouched, not exercised
  (no bpy runs this seat).
- bpy ignores `PYTHONUNBUFFERED` without `--python-use-system-env` — untouched.
- `io.DEFAULT_BUFFER_SIZE=131072` is build-specific — untouched.
- Wire order + write order + exit are **all three** needed as witnesses here:
  the Jolt teardown crash and the DSS invalidation are invisible in the stream
  (identical stdout), visible only in stderr/backtrace and the exit class.
- **rc alone is never a verdict**, demonstrated twice in this corpus:
  byte-identical stdout with exits 0 and 134 (`jolt-space_off`), and exit 137
  for an arm whose actual event is a script error at `r83b_edges2.gd:365`.
- fifo-open SIGTERM-immunity → every arm bounded with `timeout -s KILL`.
- Timing leaves are jitter, never verdicts: no timing cell is a verdict here;
  the 30 s bound is a mechanism witness only.
- Consumer forks are member-local — n/a.

## (11) Artifacts

- Report: `reports/round-83/r83-boundary.md` (this file).
- Scratch root `corpus/live/r83-boundary/` (gitignored, `corpus/.gitignore:1`):
  probe II `proj/r83b_edges2.gd` (+ copies in `proj_thread/`, `proj_jolt/`),
  sha256 `5386871523e60d61…`; probe I `proj/r83b_edges.gd` sha256
  `9fc2aecfe8a84011…`; runners `run_edges.sh`, `kill_probe.sh`; projects
  `proj/{project.godot,r83b_edges.gd,r83b_edges2.gd,r83b_inventory.gd,r83b_hang.gd}`,
  `proj_thread/`, `proj_jolt/`, `proj_dummy/`; battery
  `battery-runs/20261014T160748529914Z/`; receipts `runs/` (375 files, 119
  `.exit`: 102×0, 11×134, 5×137, 1 `exit=0`-style).
- `manifest-r83b.sha256` pins every artifact cited above (probes, projects,
  runners, battery verdicts, and every probe-II receipt incl. reps) — 198
  lines, sha256 `a4e3d243b827f4f9…`.

Report only; I do not judge, admit, edit fixtures, commit, or ship. Stopping
here.
