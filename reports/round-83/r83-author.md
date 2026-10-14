# game-dev-3d round 83 — author (seat: author, host: devin)

## Declared move (verbatim)

r83 AUTHOR (g3d) — Godot PhysicsServer3D generated-event two-tier lattice.
ARM — the two-tier claim (xconnector X5): PhysicsServer3D QUERIES are
edge-0 same-turn (r82-banked frontier: flat {*:0}) while GENERATED events
(contact signals, body_test_motion results, cast_motion, intersect_shape)
bind at the PHYSICS TICK — a two-tier lattice inside one server. Extend the
Godot-side probe family in corpus/fixtures/ (the Godot battery machinery is
run_battery.py + godot probes):
- generated-event cells: body_test_motion/cast_motion/intersect_shape
  called mid-frame vs at-tick; contact signal emission timing
- run_on_separate_thread=true project setting: inline->deferred
  conversion cell (does the same-turn query still bind edge-0?)
- Jolt availability gate FIRST: check PhysicsServer3DManager /
  project settings for the backend; absent -> record which backend
  this build ships and bound the claim to it.
Viability-conditional; engine-semantic pins (callables invoked vs not),
never timing-only. bpy battery untouched. Report ->
reports/round-83/r83-author.md.

RECOVERY CONTEXT: wave-14 recovery dispatch; previous seats died ~16:10Z.
Sibling scratch under corpus/live/r83-*/ existed (scribe's raw/parsed audit
in reports/round-83/r83-scribe.md, uncommitted). Dead-seat residue under
corpus/live/r83-author/proj{,_threaded}/ was verified before reuse —
probe1 hung (called `PhysicsServer3DManager.get_server_count`, which does
not exist on this build → SCRIPT ERROR → tree never quit → SIGKILL at
timeout); fixed before reuse. probe2/probe3 ran clean as-drafted except a
missing kind-strip and a node-leak (below).

## Jolt gate (answered first, brief ordering)

Measured on `4.7.2.stable.arch_linux.ed1daf0bf`, battery project
(`physics/3d/physics_engine` unset → `DEFAULT`):

- `ClassDB.class_exists("JoltPhysicsServer3D")` = **false** under DEFAULT;
  `GodotPhysicsServer3D` = true. Under `physics_engine="Jolt Physics"` the
  classes swap (JoltPhysicsServer3D=true, GodotPhysicsServer3D=false —
  `r83-boundary/runs/jolt-inventory.stdout.txt`): **Jolt is compiled in and
  selectable on this build.**
- `physics/3d/physics_engine` hint string =
  `DEFAULT,Jolt Physics,GodotPhysics3D,Dummy`
  (`runs/probe1.stdout.txt:16`).
- `PhysicsServer3DManager` exists but carries exactly
  `{register_server, set_default_server}` — **no enumeration API**
  (`probe1.stdout.txt:11-15`; boundary's inventory agrees).
- r83-boundary jolt-* receipts: `jolt-empty`/`jolt-contacts` exit 0, but
  `jolt-multi_space`/`jolt-space_free_order` SIGSEGV (exit 134) — a crash
  surface, not a lattice defect.
- **Bound**: the battery pins run on `DEFAULT` (GodotPhysics3D). The five
  core arms were additionally run under Jolt live-only (`proj_jolt/`,
  `runs/jolt_*`) — the lattice replicates with different solver constants.

## Landed changes (insertion-only)

- `corpus/fixtures/phys3d_events.gd` — NEW fixture (sha256
  `6ddf4aefde97d31673f337699ba1dedbe9e6caf4226917225577a36b8ac4fab3`).
  One `SceneTree` script, ten `--arm=` cells. `PPQueries` inner class
  (`:141-194`) does the inside-`_physics_process` write+query cell;
  `_child_threaded` (`:546`) is the re-exec'd threaded child.
- `corpus/fixtures/run_battery.py` — +10 CASES rows appended at the end of
  the list (`:419-438`); the diff is pure insertion, prior 176 rows
  byte-identical.
- `corpus/fixtures/README.md` — +1 section (`:561-587`) documenting the
  arm; the "Determinism rules" heading was restored after the insert.

## Measured result — two clean full batteries

`python3 corpus/fixtures/run_battery.py --runs corpus/live/r83-author/runs`

- `runs/20261014T164612500349Z` — **186/186 PASS** (140 ordinary +
  46 negative), `seeds_unchanged=true`, verdict PASS.
- `runs/20261014T165207093423Z` — **186/186 PASS**, `seeds_unchanged=true`,
  verdict PASS. (Intermediate run `…164857262617Z` reported `FAIL battery`
  with 186/186 case-PASS — seed digest tripped because I edited
  `README.md` mid-run; self-inflicted, re-run clean. Recorded as a
  harness-interaction note: seeds digest is computed before AND after the
  run, so no fixture file may be touched while a battery is in flight.)
- `--only` subset run `runs/20261014T164604096927Z` — 10/10 new cases PASS.

### Query tier — edge-0, both directions, both callsites (supports X5 tier-1)

| cell | witness (raw lines in `runs/p2_*.stdout.txt`, `p4_*.stdout.txt`) |
|---|---|
| `intersect_shape` | `settled hits=1 → w0_sameturn hits=0 → back_w0 hits=1` — both directions same-turn |
| `cast_motion` | `settled safe=0.14453125 unsafe=0.150390625 → w0 [1.0,1.0]` |
| `body_test_motion` | `settled hit=true travel z=-0.976562 → w0 hit=false travel -10.0` |
| inside `_physics_process` | `pp_isect frame=4 hits=0`, `pp_cast safe=1.0`, `pp_btm hit=false -10.0` — no callsite shift (extends frontier `pp_callsite` beyond `intersect_ray`) |

Note on the brief's grouping: `body_test_motion`/`cast_motion`/
`intersect_shape` measure as **queries** (edge-0), not generated events —
the event tier is the contact set, monitor/area signals, and sync
callbacks. The lattice split is sharper than the brief's list suggested.

### Event tier — binds at the physics tick (supports X5 tier-2)

| cell | witness |
|---|---|
| `get_contact_count` (both directions) | teleport INTO floor overlap: `w0 c=0` while `intersect_shape`=1 → `n1 c=4`; teleport UP: `w0 c=4` **stale** → `n1 c=0` (`p6_contact_stale`) — generated data lags one full tick either way |
| `Area3D.body_entered` (rigid) | mid-frame teleport: `w0 fired=false` → `enter@f+1` (delta=1), `get_overlapping_bodies` 0→1 at the same tick (`p3_tp_rigid`, fixture `contact_sig`) |
| `area_set_monitor_callback` (server) | rigid teleport in: `cb status=0@f5` (delta=1); area out: `status=1@f9`; area back: `status=0@f10` — all exactly one tick (`p4_srv_area`) |
| `body_set_state_sync_callback` | `w0=0 → n1=1 → n3=3` — once per tick while active; static body's callback never fires (`p2_sync_cb`, fixture `sync_cb` static control) |
| **pair-scope rule** | a teleported STATIC body never re-pairs with a settled area — `tp_static`/`add_inside` silent through 4 ticks at node and server level — while moving the AREA onto it fires `enter` at the next tick (`p3_*`, `p4_static_pair`, fixture `static_nopair` negative). Generated events re-pair movers, not the whole space |

Same-tick inside `_physics_process` the contact set is equally stale
(`p6_pp_contacts`: `pre_c=4 w0_c=4` inside the write callback) — the event
tier has no callsite escape either.

### Threaded conversion cell (`run_on_separate_thread=true`)

Child project `proj_threaded/project.godot` + `probe5.gd`, stdout
byte-identical ×3 (`runs/p5_thr{,.r2,.r3}.stdout.txt`):

- Inside `_physics_process`: write→ray/isect/cast/btm **still edge-0**
  (`THR pp frame=4 ray_hit=false isect=0 safe=1.0 btm=false`). The query
  tier's edge-0 survives threading in its legal context.
- Process context: `space_get_direct_state` refused 11/12 fetches (one
  race-window success; boundary's stress measured 149/150). Refusals emit
  `ERROR: Space state is inaccessible right now` to stderr — inside the
  battery cell this is file-redirected, never reaching the case stream.
- Server object-truth keeps answering mid-frame: `body_get_state` returns
  the new transform and `body_test_motion` runs correctly from process
  context (`proc_get_state wall_z=(0,0,-30) proc_btm hit=false`) — the
  conversion applies to the DSS accessor, not all server calls.
- Pinned in-battery as `proc_dss_refused=true` (nulls ≥8 of 12 —
  threshold, not an exact count: the race window is real).
- `early_null` (dss fetched before the first tick) is **racy**: null ×3 in
  probe5, non-null once in the fixture child — reported as `CHILD_NOTE`,
  never pinned.

Fixture cell `phys3d_events_threaded_edge`: parent writes
`scratch/thrproj/project.godot`, re-execs itself via
`/bin/sh -c '… > child.log 2>&1'`, asserts `child_exit=0` + the exact
`CHILD_RESULT pp_edge0=true proc_dss_refused=true srv_ok=true` line +
no SCRIPT/Parse error in the log. `child.log` is retained in the run's
scratch as evidence (`…165207093423Z/scratch/thrproj/child.log`, 10+
refusal ERRORs + CHILD_NOTE + CHILD_RESULT).

### Jolt replication (live-only, `proj_jolt/`, `runs/jolt_*`)

Same lattice on `physics_engine="Jolt Physics"`: isect edge-0 both
directions; cast edge-0 (safe 0.149841/0.150024 — different constants);
btm edge-0 (-0.998535); contact staleness identical (`w0 c=4 → n1 c=0`);
sync_cb per-tick `[5,6,7]`; pp queries edge-0; srv_area cb enter@f5/exit@f9.
The claim is backend-invariant for the measured cells; pinned cells remain
GodotPhysics3D (the battery project's DEFAULT), Jolt receipts are
supporting evidence.

## Evidence

- Battery: two full 186/186 PASS receipts (`runs/20261014T164612500349Z`,
  `runs/20261014T165207093423Z`), `seeds_unchanged=true`, all 176 prior
  rows byte-identical + 10 appended rows; per-case verdicts in
  `verdicts.json`.
- Fixture determinism: `p2_*` arms byte-identical ×2 reps; `p5_thr`
  byte-identical ×3; `fx_threaded_edge` PASS ×3.
- Live receipts under `corpus/live/r83-author/runs/`: `probe1` (gate),
  `p2_{isect,cast,btm,contact_sig,sync_cb,contact_count}{,.r2}`,
  `p3_{tp_static,tp_rigid,add_inside,move_out}`,
  `p4_{pp_isect,pp_cast,pp_btm,srv_area,static_pair}`,
  `p5_thr{,.r2,.r3}`, `p6_{contact_stale,pp_contacts}`,
  `jolt_{isect,cast,btm,contact_count,sync_cb,pp_isect,pp_cast,pp_btm,srv_area}`,
  `fx_*` single-arm runs. Projects: `proj/` (60 tps DEFAULT),
  `proj_threaded/` (`run_on_separate_thread=true`), `proj_jolt/`
  (`physics_engine="Jolt Physics"`), `scratch_fix/` (battery-sim).
- Sibling corroboration (pre-measured, verified): r83-scout
  `proj_contact_create` (`w0 contacts=0 ish_overlap=true → n1 c=4`),
  `proj_sync_cb` (static cb never fires), r83-boundary `thread-*`
  (process-context dss refusal, `dss_in_pp` legal), `jolt-*` crash
  receipts.

## Hazards recorded (engine + harness)

- **Dead-seat probe1 bug**: `PhysicsServer3DManager.get_server_count`
  doesn't exist → SCRIPT ERROR → `_run` aborted before `quit(0)` → the
  headless tree idled forever → SIGKILL at 30 s. A `--script` SceneTree
  that errors before quitting does not exit — every probe needs either a
  quit on all paths or a `timeout -s KILL` envelope.
- **`OS.execute` output array is unusable for full capture on this
  build**: with `output` + `read_stderr` it returned only the startup
  banner (child's later stdout inherited the parent's fd; stderr leaked to
  parent stderr). `sh -c '… > log 2>&1'` file-redirection captures
  everything; the fixture uses that.
- **Racy startup dss fetch** (`early_null`) — reported, unpinned.
- **`prints` of engine objects can embed `RID(...)`/paths** — no marker
  line carries them (scribe's RID-token warning); collider IDs were read
  but never printed into a pin.
- **`await`-leak**: node objects must be `.free()`d before quit or the
  ObjectDB-leak warning fails the classifier (probe2's `contact_sig`
  leaked 3); the fixture frees every created node/RID on all paths.
- **GDScript `%` precedence**: `("a%s" + "b%s") % [x, y]` — parens
  required; a missing paren formats the second fragment alone.
- **Seed-digest window**: `run_battery.py` hashes fixtures before AND
  after the run; editing any fixture file mid-run flips the verdict to
  FAIL even with 186/186 case-PASS (measured once, self-inflicted).

## Remaining unknowns / risks

- `proc_dss_refused` is a ≥8/12 threshold pin: measured 11/12 ×3 (+149/150
  boundary). A scheduler regime where >4 fetches land in race windows
  would flip it; the claim text says "majority-refused", not absolute.
- `sync_cb` fires per tick only while the body is active; the
  sleep-transition boundary (does the callback stop the tick the body
  sleeps?) is unprobed.
- The `static_nopair` rule is pinned for area-monitor pairs; whether a
  static teleport also fails to generate body-body contact pairs is
  unprobed (likely, same pair-cache mechanism — inference, not measured).
- Contact-count resolution (`max_contacts_reported=8` → observed 4) is
  solver-specific; the pin asserts the count at tick n1, not the value's
  universality.
- Jolt threaded (`Jolt Physics` + `run_on_separate_thread`) unprobed —
  cross product of two arms left for a later round.
- `body_test_motion`/`cast_motion` mid-frame legality under threading was
  measured for the kinematic probe and wall only; other body modes
  unprobed.

Files changed: `corpus/fixtures/phys3d_events.gd` (new),
`corpus/fixtures/run_battery.py` (+10 CASES rows, insertion-only),
`corpus/fixtures/README.md` (+1 section), this report, scratch under
`corpus/live/r83-author/`. Leaf seat: no subagent dispatch, no git
mutations — all work left uncommitted for the integrator. Stopping here.
