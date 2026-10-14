# PhysicsServer3D two-tier lattice (round 83): query APIs bind edge-0
# same-turn; generated events (contact sets, area monitor callbacks,
# body_entered/exited signals, state_sync callbacks) bind at the physics tick.
#
# Measured on Godot 4.7.2 --headless, 60 tps, physics_engine=DEFAULT
# (GodotPhysics3D; Jolt is pinned in-battery by the jolt_edge child arm —
# the lattice holds on the query/event split while cast/btm differ on
# solver constants and static_nopair inverts; the r84 child runs the
# full 6-result map under Jolt clean-exit on this build).
#
# Arms (run one per case):
#   isect        intersect_shape sees a moved body same-turn, both directions
#   cast         cast_motion safe/unsafe fractions update same-turn
#   btm          body_test_motion hit->miss on a wall move, same-turn
#   pp_queries   the same three queries issued inside _physics_process
#   contact_stale get_contact_count stays stale at w0 while intersect_shape is
#                already live — the two-tier discriminant
#   contact_sig  Area3D.body_entered on a rigid teleport: never same-turn,
#                fires at the next physics tick (delta=1)
#   sync_cb      body_set_state_sync_callback fires once per tick while the
#                body is active; never fires on a static body
#   srv_area_cb  server-level area_set_monitor_callback: enter/exit land at
#                the next physics tick — delta=1 from a physics-phase write,
#                delta=2 from a process-phase write (write-phase-dependent,
#                critic C1; this fixture writes from the physics phase)
#   static_nopair NEGATIVE: a teleported STATIC body never re-pairs with a
#                settled Area3D (no signal, overlaps=0) — the pair only forms
#                when the AREA itself moves. GodotPhysics3D ONLY: under Jolt
#                the same cell fires (ov=1 sig=1, 3/3 — critic C2), so the
#                only-movers rule is backend-scoped, not universal
#   threaded_edge parent arm: spawns a second godot with
#                physics/3d/run_on_separate_thread=true and checks the
#                conversion — inside _physics_process the write->query edge is
#                still 0, while process-context direct-space-state access is
#                refused (server calls body_get_state/body_test_motion keep
#                answering mid-frame)
#   phase_delta  the write-phase discriminant as a first-class cell
#                (r83 critic C1): the same rigid teleport into the same
#                settled area fires body_entered at delta=2 when the
#                write issues from the process phase (await
#                process_frame continuation) vs delta=1 from the physics
#                phase — the frame owns the extra tick, not the solver
#   jolt_edge    parent arm: spawns a second godot under a generated
#                physics/3d/physics_engine="Jolt Physics" project and
#                pins the per-arm backend split {same-signature |
#                differs-constants | inverts} — isect/contact_stale keep
#                the DEFAULT signature, cast/btm keep the edge on
#                different solver constants, static_nopair INVERTS
#                (tp fires ov=1 sig=1 delta=1 under Jolt — critic C2).
#                Gated on the physics_engine hint containing "Jolt
#                Physics"; absent -> honest BLOCKED row, no fabrication
#   jolt_threaded cross-product arm (round 85): generated child carrying
#                BOTH physics_engine="Jolt Physics" AND
#                3d/run_on_separate_thread=true — pins whether the
#                backend split holds identically under the threaded
#                stepper. A threading witness (proc-context
#                space_get_direct_state refusals) is pinned in the map so
#                a silently-nonthreaded child fails loudly
#   dummy_refused negative-control arm (round 85): generated child under
#                physics_engine="Dummy" runs the SAME reduced sweep —
#                every arm must classify 'unexpected' (zero/silent reads
#                never earn a known-class label), proving the split is
#                backend-real, not a map coincidence
#   srv_phase_delta server-write phase delta (round 85 stretch):
#                PhysicsServer3D.body_set_state writes vs the
#                node-position writes of phase_delta — same event-tier
#                boundaries (proc-phase -> delta=2, physics-phase ->
#                delta=1): the write PATH is not a tier, the write PHASE
#                is. A raw server RID carries no instance id, so the
#                monitor is the server-level area_set_monitor_callback
#                (a node Area3D's body_entered cannot resolve it)
#   script_size_gate parent arm (round 86): the deferred process-context
#                direct-space-state fetch is released or refused by the
#                script's statement count, not by the fetch position — an
#                UNCALLED function body releases it too (r86 critic A3) —
#                and on this host that is a ~100-line STOCHASTIC
#                BAND (~475-575 lines), not a boundary (r86 boundary §1, 6
#                reps per point). One GENERATED probe source at two sizes in
#                the same threaded project: the 25-line body is refused
#                (deterministic, far below the band) and the 1025-line body
#                is granted (deterministic, far above it); the same minimal
#                body in an unthreaded project is granted, because the gate
#                does not exist without run_on_separate_thread. Every child
#                is corroborated by the engine's own refusal-line count in
#                its log, never by the child's self-report alone.
#                The fourth child is this fixture's own bare fetch at the
#                same position: it is granted, and the r86 boundary seat
#                showed 16 real-token shrinks down to 725 lines never flip
#                it. So this is a LATENT fragility, not a live defect — the
#                file would have to lose ~500 lines of real tokens to reach
#                the band — and the arm exists to make that trip loud
#                instead of silent.
#   deferred_hang parent arm (round 86): an unguarded deref of the refused
#                fetch inside the deferred _run coroutine aborts that
#                coroutine before quit(); the SceneTree is then left with
#                no exit condition and spins until the spawn bound kills
#                it (rc 137 = 128+SIGKILL through /bin/sh, no
#                CHILD_RESULT line at all). rc is the only detector: a
#                SIGKILLed process emits no at-exit leak report, so the
#                leak scan can never see the zombie RIDs (r86 boundary
#                §3.1). The identical body under Dummy+threaded is the
#                contrast: the silent floor grants every fetch, so it
#                exits 0 and can never witness the hang class. Bounded by
#                `timeout -s KILL` at 8 s.
#   backend_tier  parent arm (round 86): one tier sweep spawned under
#                {GodotPhysics, Jolt, Dummy} generated projects. The area
#                gravity/damping override INVERTS — GodotPhysics honours
#                it, Jolt silently ignores it (the body keeps the global
#                constant while the area parameter reads back 20.0); the
#                shape-query `margin` is the mirror split (inert on
#                GodotPhysics, honoured by Jolt); the separation ray
#                differs only in solver constants.
#   dummy_floor   parent arm (round 86): the Dummy silent floor as a
#                class. Every create returns RID(0), every read comes back
#                Nil / 0.0 / empty, one shape type is a WRONG constant, and
#                the two calls that are loud refusals on a real backend
#                (space_get_direct_state(RID()) and free_rid(RID())) are
#                silent no-ops. Pinned as an 11-token signature tuple plus
#                the real-backend refusal count, so "silent floor" can
#                never be read as "refusal". The Dummy child is armed for
#                the floor ONLY — the r86 boundary seat's 34-call sweep
#                found 0 errors and no loud refusal anywhere under Dummy,
#                so a Dummy child can never witness a refusal class.
#   body_handle  parent arm (round 87): the held-handle identity law — the
#                body-state object is ONE per-body singleton live handle, the
#                same instance _integrate_forces and
#                body_set_state_sync_callback are handed, and it survives
#                detach/reattach. Three generated children (GP/Jolt/Dummy);
#                the Dummy row is the floor contrast, never a hazard detector
#   acq_use      parent arm (round 87): the acquisition-vs-use split under
#                run_on_separate_thread — the FETCH is refused out of phase
#                while a HELD handle reads live and writes land at every
#                position: the gate controls acquisition, not use. The gate
#                witness doubles as the threading witness
#   step_stamp   parent arm (round 87): the object's own flush seams —
#                get_step is step-stamped on both real backends (init
#                constant -> real dt), gravity/damp only on GodotPhysics
#                (Jolt reports real values pre-first-solve), and the contact
#                buffer is last-step data that needs
#                body_set_max_contacts_reported > 0 to report anything
#   write_loss   parent arm (round 87): the out-of-phase held-handle write as
#                a BOUNDED repeated observation (8 reps) — the gate refusal
#                and the same-turn write are pinned, the landed/lost split is
#                evidence (the write path is ungated and unsynchronized), and
#                a loss is never claimed that was not witnessed
#   body_tier    parent arm (round 87): the backend split AT the body tier —
#                first-in-contact-step get_contact_impulse zero (GP) vs real
#                (Jolt), out-of-range contact_local_shape -1 vs 0,
#                set_sleep_state keeping vs zeroing velocity, and the
#                detached-impulse write silent vs LOUD (log-counted)
#   freed_space  parent arm (round 87, FATAL TAIL): the one crash surface at
#                this tier — a space-state object reached through a body
#                handle whose SPACE was free_rid'd. The crash site is
#                backend-specific on this host: GP dies INSIDE
#                held.get_space_state() (its `space=` note never prints),
#                Jolt's call returns and the kill is at intersect_ray.
#                GP reports signal 11 and
#                aborts through its own handler (rc 134 in ~1.5 s; a
#                load-slowed handler was measured at 44.2 s and is then
#                bound-killed at rc 137), Jolt's crash mode is heap-layout
#                dependent (uncaught std::system_error or the same signal-11
#                handler), Dummy returns {} and exits 0. Pinned per backend
#                as one crash line in the raw log plus the breadcrumb
#                prefix at that backend's site plus the ABSENCE of any
#                child marker
#
# Reproduce one arm:
#   godot --headless --path <scratch> --script res://phys3d_events.gd -- --arm=isect
extends SceneTree

const SETTLE := 4
const WALL_FAR := Vector3(0, 0, -30)
# r86 size-gate ladder. The r86 boundary seat measured the deferred
# process-context fetch as a ~100-line STOCHASTIC BAND, not a boundary:
# deterministically refused below ~475 lines of one-statement-per-line
# padding, deterministically granted above ~575, with a race inside (6 reps
# per point). 0 padding (25 lines) sits far below the band and 1000 padding
# (1025 lines) far above it, so both ends of this cell are on the
# deterministic side of the race rather than inside it. (This arm pins the
# release/refuse OUTCOME, not the boundary seat's `pf` observable: the
# generated probe prints `pf` after its own await, so the two readings are
# not the same measurement.)
const SIZE_PAD := 1000
# r86 hang arm: a healthy child of this size exits in ~0.5 s, so 8 s is a
# 16x margin on the abort, and 137 is what `/bin/sh` reports for the
# `timeout -s KILL` kill (128 + SIGKILL).
const HANG_BOUND_S := 8
const HANG_RC := 137
# r87 body-tier arms. BODY_REPS is the bounded repeated-observation length the
# acquisition/use and write-loss cells share: both cells are REPEATED so a
# single lucky frame can never carry them. CRASH_BOUND_S bounds the freed-space
# crash children. The GodotPhysics crash handler normally finishes its backtrace
# in ~1.5 s and aborts (rc 134 — measured 5/5 in this fixture form, 3/3 in the
# battery runs), but the SAME handler was measured taking 44.2 s under host
# load, so a bound can cut it short and the child then dies by the bound's
# SIGKILL (rc 137 through /bin/sh). The rc is therefore the handler's exit
# PATH, not the class: the row pins the crash CLASS (the engine's own crash
# line, no child marker, a signal-class rc) and accepts both.
const BODY_REPS := 8
const CRASH_BOUND_S := 6

var owned: Array[RID] = []
var owned_nodes: Array[Node] = []
var dss: PhysicsDirectSpaceState3D
var wspace: RID
var sig_log := []


func _initialize() -> void:
	call_deferred("_run")


func _argval(prefix: String, dflt: String) -> String:
	for a in OS.get_cmdline_user_args():
		if a.begins_with(prefix):
			return a.substr(prefix.length())
	return dflt


func _frames(n: int) -> void:
	for i in range(n):
		await physics_frame


func _mk_body(pos: Vector3, mode := PhysicsServer3D.BODY_MODE_STATIC) -> RID:
	var shape := PhysicsServer3D.box_shape_create()
	PhysicsServer3D.shape_set_data(shape, Vector3(1.0, 1.0, 1.0))
	var body := PhysicsServer3D.body_create()
	PhysicsServer3D.body_set_mode(body, mode)
	PhysicsServer3D.body_add_shape(body, shape)
	PhysicsServer3D.body_set_collision_layer(body, 1)
	PhysicsServer3D.body_set_collision_mask(body, 1)
	PhysicsServer3D.body_set_space(body, wspace)
	PhysicsServer3D.body_set_state(body,
			PhysicsServer3D.BODY_STATE_TRANSFORM, Transform3D(Basis(), pos))
	owned.append(body)
	owned.append(shape)
	return body


func _sphere_params(pos: Vector3, motion := Vector3.ZERO,
		mask := 1) -> PhysicsShapeQueryParameters3D:
	var s := SphereShape3D.new()
	s.radius = 0.5
	var p := PhysicsShapeQueryParameters3D.new()
	p.shape = s
	p.transform = Transform3D(Basis(), pos)
	p.motion = motion
	p.collision_mask = mask
	p.collide_with_bodies = true
	return p


func _floor_isect_hits(exclude_body: RID) -> int:
	var b := BoxShape3D.new()
	b.size = Vector3(2, 2, 2)
	var p := PhysicsShapeQueryParameters3D.new()
	p.shape = b
	p.transform = Transform3D(Basis(), Vector3(0, 0.5, 0))
	p.collision_mask = 1
	p.collide_with_bodies = true
	p.exclude = [exclude_body]
	return dss.intersect_shape(p).size()


func _contacts(body: RID) -> int:
	var st: PhysicsDirectBodyState3D = PhysicsServer3D.body_get_direct_state(body)
	return st.get_contact_count() if st != null else -1


func _cleanup_nodes() -> void:
	for n in owned_nodes:
		if is_instance_valid(n):
			n.free()
	owned_nodes.clear()


func _cleanup_rids() -> void:
	for r in owned:
		PhysicsServer3D.free_rid(r)
	owned.clear()


func _fail(reason: String) -> bool:
	push_error("phys3d_events: " + reason)
	_quit_clean(1)
	return true


func _exit_ok(marker: String) -> void:
	_quit_clean(0, marker)


# r86 simplifier: the exit protocol — every exit path in this file cleans up
# its nodes/RIDs and quits with its own code, printing its report line (if
# any) after the cleanup (r84: "every exit path in the file cleans up").
func _quit_clean(code := 0, message := "") -> void:
	_cleanup_nodes()
	_cleanup_rids()
	if message != "":
		print(message)
	quit(code)


# r85: the jolt_threaded and dummy_refused arms are the third and fourth
# child-spawn sites, so the r84 simplifier's deferred V2 fold lands —
# _spawn_child single-sources the project generation, the
# `timeout -s KILL 30` /bin/sh spawn, the stale-log unlink, and the
# CHILD_RESULT/error scan. `allow_inaccessible` admits the refusal-class
# "Space state is inaccessible" ERROR lines a threaded child emits on
# its proc-context dss witness; every other ERROR: is a defect, as is
# any SCRIPT ERROR/Parse Error or ObjectDB-leak WARNING (r84 reviewer
# F1). Returns {code, verdicts, last, serr, errs} on spawn, or {err} where
# the caller fails with `err` verbatim (identical fail text to the unfolded
# arms — their receipts stay byte-identical).
#
# r86: `script_res` and `bound_s` are additive (defaulted to the r83-r85
# behaviour, so every existing call site and receipt is unchanged).
# `script_res` lets an arm spawn a GENERATED probe instead of this fixture
# (the size-gate arm cannot measure the fixture's own size with the
# fixture), and `bound_s` lets the hang arm bound its spin short of the
# 30 s that a healthy child never needs. `errs` is the list of the lines
# the scan below rejected, so an arm can pin an expected-witness class
# (a refusal count, an abort line) instead of only a boolean.
#
# r87: `allow_lines` is additive (defaulted empty, so every r83-r86 receipt
# stays byte-identical). The body-tier arms spawn children whose expected
# witness IS an engine ERROR line — the body-tier fetch refusal, the
# out-of-range contact-index refusal, Jolt's detached-impulse refusal — and
# a witness the scan rejects can never be asserted. The flag's own
# "Space state is inaccessible" carve-out is unchanged.
func _spawn_child(dirname: String, project_body: String, arm: String,
		allow_inaccessible: bool, script_res := "res://phys3d_events.gd",
		bound_s := 30, allow_lines := []) -> Dictionary:
	var dir := ProjectSettings.globalize_path("res://" + dirname)
	var mk := DirAccess.make_dir_recursive_absolute(dir)
	if mk != OK:
		return {"err": "%s cannot make %s err=%d" % [arm, dirname, mk]}
	var pf := FileAccess.open(dir.path_join("project.godot"), FileAccess.WRITE)
	if pf == null:
		return {"err": "%s cannot write child project" % arm}
	pf.store_string(project_body)
	pf.close()
	var selfpath := ProjectSettings.globalize_path(script_res)
	var logpath := dir.path_join("child.log")
	# `timeout -s KILL` bounds the child: without it a hung child
	# survives the battery's kill of the direct /bin/sh parent and is
	# orphaned (r83 reviewer F2). 30 s covers the ~2 s healthy run.
	var cmd := ("timeout -s KILL %d \"%s\" --headless --path \"%s\""
			+ " --script \"%s\" -- --child --arm=%s"
			+ " > \"%s\" 2>&1") % [
			bound_s, OS.get_executable_path(), dir, selfpath, arm, logpath]
	# r84 critic: child.log is a never-unlinked single slot -- a stale
	# log from a prior run would forge a verdict map, so remove it
	# before spawn (missing-after-spawn stays a named failure).
	DirAccess.remove_absolute(logpath)
	var code := OS.execute("/bin/sh", ["-c", cmd], [], false)
	var res := {"code": code, "verdicts": {}, "last": "", "serr": false, "errs": []}
	var lf := FileAccess.open(logpath, FileAccess.READ)
	if lf == null:
		return {"err": "%s child log missing" % arm}
	while not lf.eof_reached():
		var line := lf.get_line()
		if line.begins_with("CHILD_RESULT "):
			res["last"] = line
			var kv := line.substr(13).split("=", true, 1)
			if kv.size() == 2:
				res["verdicts"][kv[0]] = kv[1]
		elif "SCRIPT ERROR" in line or "Parse Error" in line:
			res["serr"] = true
			res["errs"].append(line)
		elif ("ObjectDB" in line and "leaked" in line):
			res["serr"] = true
			res["errs"].append(line)
		elif line.begins_with("ERROR:") \
				and not _error_allowed(line, allow_inaccessible, allow_lines):
			res["serr"] = true
			res["errs"].append(line)
	lf.close()
	return res


# r86 simplifier: one generator for all 13 child project bodies (four r83-r85
# arms + nine r86 arms); the 13 literals matched this shape byte-for-byte.
func _project_body(name: String, engine := "", threaded := false) -> String:
	var body := "[application]\n\nconfig/name=\"%s\"\n\n[physics]\n\ncommon/physics_ticks_per_second=60\n" % name
	if engine != "":
		body += "3d/physics_engine=\"%s\"\n" % engine
	if threaded:
		body += "3d/run_on_separate_thread=true\n"
	return body


# r86: the size-gate and hang arms need a probe whose SOURCE is generated —
# the gate is a property of the script's own size, so the child source
# cannot be this fixture. Writing the probe and then delegating keeps the
# project generation, the bounded spawn, the stale-log unlink and the error
# scan single-sourced in _spawn_child (the r84 simplifier's V2 rule).
func _spawn_probe(dirname: String, project_body: String, script_name: String,
		script_body: String, arm: String, allow_inaccessible: bool,
		bound_s := 30) -> Dictionary:
	var dir := ProjectSettings.globalize_path("res://" + dirname)
	var mk := DirAccess.make_dir_recursive_absolute(dir)
	if mk != OK:
		return {"err": "%s cannot make %s err=%d" % [arm, dirname, mk]}
	var sf := FileAccess.open(dir.path_join(script_name), FileAccess.WRITE)
	if sf == null:
		return {"err": "%s cannot write child probe" % arm}
	sf.store_string(script_body)
	sf.close()
	return _spawn_child(dirname, project_body, arm, allow_inaccessible,
			dir.path_join(script_name), bound_s)


# The generated probe: the deferred process-context fetch at the same
# position (call_deferred from _initialize) at two sizes. `--arm=guarded`
# null-checks the handle and names the outcome; `--arm=deref` dereferences
# it unguarded, which is the hang class whenever the fetch was refused.
# Padding is real file-scope statements, never comments or blank lines: the
# r86 size ladder measured the gate on compile work, not on line or byte
# count (2 026 blank lines and 256 KB of comments never released the fetch).
func _size_probe_body(pad: int) -> String:
	var pad_txt := str(pad)
	var body := "# r86 generated size probe: pad=" + pad_txt + " statements\n"
	body += "extends SceneTree\n\n\nfunc _initialize() -> void:\n"
	body += "\tcall_deferred(\"_run\")\n\n\n"
	for i in range(pad):
		body += "var v%d := %d\n" % [i, i]
	body += "\nfunc _run() -> void:\n"
	body += "\tvar mode := \"guarded\"\n"
	body += "\tfor a in OS.get_cmdline_user_args():\n"
	body += "\t\tif a.begins_with(\"--arm=\"):\n"
	body += "\t\t\tmode = a.substr(6)\n"
	body += "\tvar d = root.get_world_3d().direct_space_state\n"
	body += "\tvar refused := d == null\n"
	body += "\tawait physics_frame\n"
	body += "\tif mode == \"deref\":\n"
	body += "\t\tprints(\"CHILD_NOTE sz_deref pad=" + pad_txt + " null=%s\" % [str(refused)])\n"
	body += "\t\tprints(\"CHILD_RESULT sz_abort=%s\" % d.get_class())\n"
	body += "\t\tquit(0)\n"
	body += "\t\treturn\n"
	body += "\tprints(\"CHILD_NOTE sz_fetch pad=" + pad_txt + " pf=%d\" % [Engine.get_physics_frames()])\n"
	body += "\tprints(\"CHILD_RESULT sz_fetch=%s\" % (\"refused\" if refused else \"granted\"))\n"
	body += "\tquit(0)\n"
	return body


# The physics_engine hint gates child arms that need a named backend:
# absent -> honest BLOCKED row, never a fabricated split.
func _engine_hint_has(engine: String) -> bool:
	for prop in ProjectSettings.get_property_list():
		if prop.name == "physics/3d/physics_engine":
			return engine in prop.hint_string
	return false


# r87: the ERROR-line admission predicate for _spawn_child. The landed
# `allow_inaccessible` carve-out is preserved verbatim as its own branch; each
# `allow_lines` entry admits any line CONTAINING it, so a body-tier arm can
# name its expected witness class without widening any other arm.
func _error_allowed(line: String, allow_inaccessible: bool,
		allow_lines: Array) -> bool:
	if allow_inaccessible and "Space state is inaccessible" in line:
		return true
	for token in allow_lines:
		if token in line:
			return true
	return false


# r87: corroborate a child claim against the lines in the raw child log.
# The child log merges 2>&1 by design (position fidelity) — the child's own
# prints share that stream, so a text match ALONE is self-printable (r87
# critic F1): the crash rows therefore count the signature line AND require
# the breadcrumb prefix the real run leaves at each backend's crash site,
# and the refusal rows count the engine's ERROR lines == BODY_REPS. Returns
# -1 when the log is unreadable (a named failure, never a silent zero).
func _log_count(logpath: String, token: String) -> int:
	var lf := FileAccess.open(logpath, FileAccess.READ)
	if lf == null:
		return -1
	var n := 0
	while not lf.eof_reached():
		if token in lf.get_line():
			n += 1
	lf.close()
	return n


# Write + same-tick query inside _physics_process (callsite-tier cell).
# Stores measured outcomes; never prints (the parent asserts the fields so
# the marker is earned, not claimed).
class PPQueries extends Node:
	var wall: RID
	var probe: RID
	var wspace: RID
	var dss: PhysicsDirectSpaceState3D  # null forces the in-callback fetch path
	var printed := false
	var ray_hit := true
	var isect_n := -1
	var safe := -1.0
	var btm_hit := true
	var travel_z := 0.0

	func result_ok() -> bool:
		return printed and not ray_hit and isect_n == 0 \
				and absf(safe - 1.0) < 0.0001 and not btm_hit \
				and absf(travel_z - (-10.0)) < 0.0001

	func _physics_process(_delta: float) -> void:
		if printed:
			return
		var d := dss
		if d == null:
			d = PhysicsServer3D.space_get_direct_state(wspace)
		if d == null:
			return  # legal-context fetch raced server start; retry next tick
		PhysicsServer3D.body_set_state(wall,
				PhysicsServer3D.BODY_STATE_TRANSFORM,
				Transform3D(Basis(), Vector3(0, 0, -30)))
		var ray := d.intersect_ray(PhysicsRayQueryParameters3D.create(
				Vector3(0, 5, -3), Vector3(0, -5, -3)))
		var s := SphereShape3D.new()
		s.radius = 0.5
		var p := PhysicsShapeQueryParameters3D.new()
		p.shape = s
		p.transform = Transform3D(Basis(), Vector3(0, 0, -2.5))
		p.collision_mask = 1
		p.collide_with_bodies = true
		var h := d.intersect_shape(p)
		p.motion = Vector3(0, 0, -10)
		p.transform = Transform3D(Basis(), Vector3.ZERO)
		var c := d.cast_motion(p)
		var params := PhysicsTestMotionParameters3D.new()
		params.from = Transform3D(Basis(), Vector3.ZERO)
		params.motion = Vector3(0, 0, -10)
		var res := PhysicsTestMotionResult3D.new()
		var rb := PhysicsServer3D.body_test_motion(probe, params, res)
		printed = true
		ray_hit = not ray.is_empty()
		isect_n = h.size()
		safe = c[0]
		btm_hit = rb
		travel_z = res.get_travel().z


func _run() -> void:
	# child modes: this same script is re-exec'd by the threaded_edge
	# parent under a generated run_on_separate_thread=true project, by
	# the jolt_edge parent under a generated physics_engine="Jolt
	# Physics" project, by the jolt_threaded parent under a generated
	# project carrying BOTH, and by the dummy_refused parent under a
	# generated physics_engine="Dummy" project (the --arm selects which
	# child body runs).
	if "--child" in OS.get_cmdline_user_args():
		# r84 critic: the child dispatch must be total -- a bare or
		# unknown --arm used to run the threaded body silently. The
		# threaded parent passes --arm=threaded_edge explicitly.
		match _argval("--arm=", ""):
			"jolt_edge":
				await _child_jolt()
			"jolt_threaded":
				await _child_jolt_threaded()
			"dummy_refused":
				await _child_dummy()
			"threaded_edge":
				await _child_threaded()
			"size_probe":
				await _child_size()
			"tier_plain":
				await _child_tier("plain")
			"tier_jolt":
				await _child_tier("jolt")
			"tier_dummy":
				await _child_tier("dummy")
			"floor_dummy":
				await _child_floor("dummy")
			"floor_real":
				await _child_floor("real")
			"bh_plain":
				await _child_bh_identity("bh_plain")
			"bh_jolt":
				await _child_bh_identity("bh_jolt")
			"bh_dummy":
				await _child_bh_identity("bh_dummy")
			"au_plain":
				await _child_acq_use("au_plain")
			"au_jolt":
				await _child_acq_use("au_jolt")
			"ss_plain":
				await _child_step_stamp("ss_plain")
			"ss_jolt":
				await _child_step_stamp("ss_jolt")
			"wl_plain":
				await _child_write_loss("wl_plain")
			"bt_plain":
				await _child_body_tier("bt_plain")
			"bt_jolt":
				await _child_body_tier("bt_jolt")
			"bt_dummy":
				await _child_body_tier("bt_dummy")
			"fs_plain":
				await _child_freed_space("fs_plain")
			"fs_jolt":
				await _child_freed_space("fs_jolt")
			"fs_dummy":
				await _child_freed_space("fs_dummy")
			var bad:
				_quit_clean(2, "CHILD_RESULT child_arm=unknown arm='%s'" % bad)
		return

	var arm := _argval("--arm=", "isect")
	wspace = root.get_world_3d().space
	dss = root.get_world_3d().direct_space_state
	# a null process-context fetch must fail named — a silent null would
	# hang the query arms to the harness timeout instead (reviewer F3)
	if dss == null:
		return _fail("dss null at process-context fetch")

	match arm:
		"isect":
			# wall box half=1 at z=-3 (face -2); sphere r=.5 at z=-2.5 overlaps.
			var wall := _mk_body(Vector3(0, 0, -3))
			await _frames(SETTLE)
			var q := _sphere_params(Vector3(0, 0, -2.5))
			var qmask := _sphere_params(Vector3(0, 0, -2.5), Vector3.ZERO, 2)
			var s0 := dss.intersect_shape(q).size()
			var m0 := dss.intersect_shape(qmask).size()
			if s0 != 1 or m0 != 0:
				return _fail("isect setup wrong s0=%d mask2=%d" % [s0, m0])
			PhysicsServer3D.body_set_state(wall,
					PhysicsServer3D.BODY_STATE_TRANSFORM, Transform3D(Basis(), WALL_FAR))
			var away := dss.intersect_shape(q).size()
			await _frames(1)
			var away_n1 := dss.intersect_shape(q).size()
			PhysicsServer3D.body_set_state(wall,
					PhysicsServer3D.BODY_STATE_TRANSFORM,
					Transform3D(Basis(), Vector3(0, 0, -3)))
			var back := dss.intersect_shape(q).size()
			if away != 0 or away_n1 != 0 or back != 1:
				return _fail("isect edge drift away=%d n1=%d back=%d"
						% [away, away_n1, back])
			_exit_ok("PASS phys3d_events isect settled=1 mask2=0 away_w0=0 away_n1=0 back_w0=1")

		"cast":
			# sphere r=.5 at origin cast (0,0,-10): wall face z=-2 gives
			# safe 0.14453125 / unsafe 0.150390625 on this build; wall -> -30
			# yields [1.0, 1.0] in the same turn.
			var wall := _mk_body(Vector3(0, 0, -3))
			await _frames(SETTLE)
			var q := _sphere_params(Vector3.ZERO, Vector3(0, 0, -10))
			var c0 := dss.cast_motion(q)
			if absf(c0[0] - 0.14453125) > 0.0001 or absf(c0[1] - 0.150390625) > 0.0001:
				return _fail("cast settled fractions drift safe=%s unsafe=%s"
						% [str(c0[0]), str(c0[1])])
			PhysicsServer3D.body_set_state(wall,
					PhysicsServer3D.BODY_STATE_TRANSFORM, Transform3D(Basis(), WALL_FAR))
			var c1 := dss.cast_motion(q)
			await _frames(1)
			var c2 := dss.cast_motion(q)
			if absf(c1[0] - 1.0) > 0.0001 or absf(c1[1] - 1.0) > 0.0001 \
					or absf(c2[0] - 1.0) > 0.0001 or absf(c2[1] - 1.0) > 0.0001:
				return _fail("cast edge drift w0=%s,%s n1=%s,%s"
						% [str(c1[0]), str(c1[1]), str(c2[0]), str(c2[1])])
			_exit_ok("PASS phys3d_events cast settled_safe=0.144531 settled_unsafe=0.150391 w0=1.000000 n1=1.000000")

		"btm":
			# kinematic probe at origin, motion (0,0,-10): wall at z=-3 gives
			# hit + truncated travel; wall -> -30 clears in the same turn.
			var wall := _mk_body(Vector3(0, 0, -3))
			var probe := _mk_body(Vector3.ZERO, PhysicsServer3D.BODY_MODE_KINEMATIC)
			await _frames(SETTLE)
			var params := PhysicsTestMotionParameters3D.new()
			params.from = Transform3D(Basis(), Vector3.ZERO)
			params.motion = Vector3(0, 0, -10)
			var res := PhysicsTestMotionResult3D.new()
			var r0 := PhysicsServer3D.body_test_motion(probe, params, res)
			if not r0 or absf(res.get_travel().z - (-0.9765625)) > 0.001:
				return _fail("btm setup wrong hit=%s travel=%s"
						% [str(r0), str(res.get_travel())])
			PhysicsServer3D.body_set_state(wall,
					PhysicsServer3D.BODY_STATE_TRANSFORM, Transform3D(Basis(), WALL_FAR))
			var res1 := PhysicsTestMotionResult3D.new()
			var r1 := PhysicsServer3D.body_test_motion(probe, params, res1)
			await _frames(1)
			var res2 := PhysicsTestMotionResult3D.new()
			var r2 := PhysicsServer3D.body_test_motion(probe, params, res2)
			if r1 or r2 or absf(res1.get_travel().z - (-10.0)) > 0.0001 \
					or absf(res2.get_travel().z - (-10.0)) > 0.0001:
				return _fail("btm edge drift w0=%s,%s n1=%s,%s"
						% [str(r1), str(res1.get_travel()),
						str(r2), str(res2.get_travel())])
			_exit_ok("PASS phys3d_events btm settled_hit=true settled_travel=-0.976562 w0_hit=false w0_travel=-10.000000 n1_hit=false")

		"pp_queries":
			# callsite tier: write + ray/isect/cast/btm inside _physics_process.
			var wall := _mk_body(Vector3(0, 0, -3))
			var probe := _mk_body(Vector3.ZERO, PhysicsServer3D.BODY_MODE_KINEMATIC)
			await _frames(SETTLE)
			var w := PPQueries.new()
			w.wall = wall
			w.probe = probe
			w.wspace = wspace
			w.dss = dss
			root.add_child(w)
			owned_nodes.append(w)
			var deadline := Engine.get_physics_frames() + 30
			while not w.printed and Engine.get_physics_frames() < deadline:
				await _frames(1)
			if not w.result_ok():
				return _fail("pp_queries drift printed=%s ray=%s isect=%d safe=%s btm=%s"
						% [str(w.printed), str(w.ray_hit), w.isect_n,
						str(w.safe), str(w.btm_hit)])
			_exit_ok("PASS phys3d_events pp_queries ray_hit=false isect=0 safe=1.000000 btm=false travel=-10.000000")

		"contact_stale":
			# two-tier discriminant: teleport INTO floor overlap -> w0 the
			# query (intersect_shape, body excluded) already sees the floor
			# while get_contact_count is still 0; generated contacts land at
			# the next tick (4). Teleport back UP -> w0 still reports 4
			# (stale generated data), cleared at the next tick.
			var floor_b := _mk_body(Vector3(0, -1, 0))
			var rig := _mk_body(Vector3(0, 8, 0), PhysicsServer3D.BODY_MODE_RIGID)
			PhysicsServer3D.body_set_param(rig,
					PhysicsServer3D.BODY_PARAM_GRAVITY_SCALE, 0.0)
			PhysicsServer3D.body_set_max_contacts_reported(rig, 8)
			await _frames(SETTLE)
			if _contacts(rig) != 0 or _floor_isect_hits(rig) != 1:
				return _fail("contact_stale setup c=%d isect=%d"
						% [_contacts(rig), _floor_isect_hits(rig)])
			PhysicsServer3D.body_set_state(rig,
					PhysicsServer3D.BODY_STATE_TRANSFORM, Transform3D(Basis(), Vector3(0, 0.5, 0)))
			var in_w0_c := _contacts(rig)
			var in_w0_i := _floor_isect_hits(rig)
			await _frames(1)
			var in_n1_c := _contacts(rig)
			if in_w0_c != 0 or in_w0_i != 1 or in_n1_c != 4:
				return _fail("contact_stale in-phase drift w0_c=%d w0_i=%d n1_c=%d"
						% [in_w0_c, in_w0_i, in_n1_c])
			PhysicsServer3D.body_set_state(rig,
					PhysicsServer3D.BODY_STATE_TRANSFORM, Transform3D(Basis(), Vector3(0, 8, 0)))
			var out_w0_c := _contacts(rig)
			await _frames(1)
			var out_n1_c := _contacts(rig)
			if out_w0_c != 4 or out_n1_c != 0:
				return _fail("contact_stale out-phase drift w0_c=%d n1_c=%d"
						% [out_w0_c, out_n1_c])
			_exit_ok("PASS phys3d_events contact_stale in_w0_c=0 in_w0_isect=1 in_n1_c=4 out_w0_c=4 out_n1_c=0")

		"contact_sig":
			# rigid node body teleported into a settled Area3D mid-frame:
			# body_entered never fires same-turn; it lands at the next tick.
			var area := Area3D.new()
			var ashape := CollisionShape3D.new()
			var abox := BoxShape3D.new()
			abox.size = Vector3(4, 4, 4)
			ashape.shape = abox
			area.add_child(ashape)
			area.collision_layer = 0
			area.collision_mask = 2
			area.monitoring = true
			area.body_entered.connect(func(_b):
				sig_log.append(Engine.get_physics_frames()))
			root.add_child(area)
			owned_nodes.append(area)
			var bshape := CollisionShape3D.new()
			var bbox := BoxShape3D.new()
			bbox.size = Vector3(1, 1, 1)
			bshape.shape = bbox
			var body := RigidBody3D.new()
			body.collision_layer = 2
			body.gravity_scale = 0.0
			body.add_child(bshape)
			body.position = WALL_FAR
			root.add_child(body)
			owned_nodes.append(body)
			await _frames(SETTLE)
			var f0 := Engine.get_physics_frames()
			body.position = Vector3.ZERO
			var w0_fired := sig_log.size() > 0
			var w0_ov := area.get_overlapping_bodies().size()
			await _frames(1)
			var n1_fired := sig_log.size() > 0
			var n1_ov := area.get_overlapping_bodies().size()
			var delta: int = -1
			if n1_fired:
				delta = sig_log[0] - f0
			if w0_fired or not n1_fired or delta != 1 or w0_ov != 0 or n1_ov != 1:
				return _fail("contact_sig drift w0=%s n1=%s delta=%d ov=%d,%d"
						% [str(w0_fired), str(n1_fired), delta, w0_ov, n1_ov])
			_exit_ok("PASS phys3d_events contact_sig w0_fired=false w0_overlaps=0 n1_entered=true delta=1 n1_overlaps=1")

		"sync_cb":
			# body_set_state_sync_callback fires once per physics tick while
			# the body is active; a STATIC body's callback never fires.
			var rig := _mk_body(Vector3(0, 5, 0), PhysicsServer3D.BODY_MODE_RIGID)
			PhysicsServer3D.body_set_param(rig,
					PhysicsServer3D.BODY_PARAM_GRAVITY_SCALE, 0.0)
			await _frames(SETTLE)
			var count := [0]
			PhysicsServer3D.body_set_state_sync_callback(rig, func(_s):
				count[0] += 1)
			var w0: int = count[0]
			await _frames(1)
			var n1: int = count[0]
			await _frames(2)
			var n3: int = count[0]
			var stbody := _mk_body(Vector3(0, 20, 0))
			var scount := [0]
			PhysicsServer3D.body_set_state_sync_callback(stbody, func(_s):
				scount[0] += 1)
			await _frames(2)
			var sstatic: int = scount[0]
			if w0 != 0 or n1 != 1 or n3 != 3 or sstatic != 0:
				return _fail("sync_cb drift w0=%d n1=%d n3=%d static=%d"
						% [w0, n1, n3, sstatic])
			_exit_ok("PASS phys3d_events sync_cb w0=0 n1=1 n3=3 static_cb=0")

		"srv_area_cb":
			# server-level monitor callback: rigid body teleport -> enter at
			# next tick; area moved off/on -> exit/enter each at next tick.
			var ashape := PhysicsServer3D.box_shape_create()
			PhysicsServer3D.shape_set_data(ashape, Vector3(2.0, 2.0, 2.0))
			var area := PhysicsServer3D.area_create()
			PhysicsServer3D.area_add_shape(area, ashape)
			PhysicsServer3D.area_set_collision_layer(area, 1)
			PhysicsServer3D.area_set_collision_mask(area, 1)
			PhysicsServer3D.area_set_space(area, wspace)
			PhysicsServer3D.area_set_transform(area, Transform3D(Basis(), Vector3.ZERO))
			owned.append_array([area, ashape])
			PhysicsServer3D.area_set_monitor_callback(area,
					func(status, _rid, _iid, _shape, _self_shape):
					sig_log.append("%d@%d" % [status, Engine.get_physics_frames()]))
			var rig := _mk_body(WALL_FAR, PhysicsServer3D.BODY_MODE_RIGID)
			PhysicsServer3D.body_set_param(rig,
					PhysicsServer3D.BODY_PARAM_GRAVITY_SCALE, 0.0)
			await _frames(SETTLE)
			var f0 := Engine.get_physics_frames()
			PhysicsServer3D.body_set_state(rig,
					PhysicsServer3D.BODY_STATE_TRANSFORM, Transform3D(Basis(), Vector3.ZERO))
			await _frames(1)
			var enter_ok := sig_log.has("0@%d" % (f0 + 1)) and sig_log.size() == 1
			PhysicsServer3D.area_set_transform(area, Transform3D(Basis(), WALL_FAR))
			var f1 := Engine.get_physics_frames()
			await _frames(1)
			var exit_ok := sig_log.has("1@%d" % (f1 + 1)) and sig_log.size() == 2
			PhysicsServer3D.area_set_transform(area, Transform3D(Basis(), Vector3.ZERO))
			var f2 := Engine.get_physics_frames()
			await _frames(1)
			var reenter_ok := sig_log.has("0@%d" % (f2 + 1)) and sig_log.size() == 3
			if not enter_ok or not exit_ok or not reenter_ok:
				return _fail("srv_area_cb drift log=%s" % str(sig_log))
			_exit_ok("PASS phys3d_events srv_area_cb enter=1 exit=1 reenter=1 all_delta1=true")

		"static_nopair":
			# NEGATIVE: static body teleported into a settled area never
			# re-pairs — no body_entered for 3 ticks, overlaps stays 0 —
			# while moving the AREA onto the same body fires at the next
			# tick, proving the setup is live and the event tier only
			# re-pairs movers.
			var area := Area3D.new()
			var ashape := CollisionShape3D.new()
			var abox := BoxShape3D.new()
			abox.size = Vector3(4, 4, 4)
			ashape.shape = abox
			area.add_child(ashape)
			area.collision_layer = 0
			area.collision_mask = 2
			area.monitoring = true
			area.body_entered.connect(func(_b):
				sig_log.append(Engine.get_physics_frames()))
			root.add_child(area)
			owned_nodes.append(area)
			var bshape := CollisionShape3D.new()
			var bbox := BoxShape3D.new()
			bbox.size = Vector3(1, 1, 1)
			bshape.shape = bbox
			var body := StaticBody3D.new()
			body.collision_layer = 2
			body.add_child(bshape)
			body.position = WALL_FAR
			root.add_child(body)
			owned_nodes.append(body)
			await _frames(SETTLE)
			body.position = Vector3.ZERO
			for i in range(3):
				await _frames(1)
			var tp_fired := sig_log.size() > 0
			var tp_ov := area.get_overlapping_bodies().size()
			area.position = WALL_FAR
			await _frames(1)
			area.position = Vector3.ZERO
			# Clear the tp-phase entries — without this the control's
			# mv_delta reads a stale first entry and prints a nonsense
			# negative delta on the failing path (critic C2).
			sig_log.clear()
			var f_mv := Engine.get_physics_frames()
			await _frames(2)
			var mv_fired := sig_log.size() > 0
			var mv_delta: int = -1
			if mv_fired:
				mv_delta = sig_log[0] - f_mv
			if tp_fired or tp_ov != 0 or not mv_fired or mv_delta != 1:
				return _fail("static_nopair drift tp=%s ov=%d mv=%s delta=%d"
						% [str(tp_fired), tp_ov, str(mv_fired), mv_delta])
			_quit_clean(2, "NEGATIVE REJECTED: phys3d_events static_nopair static_tp_fired=false ticks=3 area_move_delta=1")

		"threaded_edge":
			# conversion cell: same queries under run_on_separate_thread=true.
			# _spawn_child (r85 V2 fold) writes res://thrproj and re-execs
			# this script with --child through /bin/sh so the child's
			# stdout+stderr land in a log file (OS.execute's output array only
			# captured the startup banner on this build — measured hazard);
			# the child's ERROR diagnostics can then never reach the case
			# stream, and the log doubles as evidence. The refusal-class
			# "Space state is inaccessible" ERRORs are the expected witness
			# (allow_inaccessible); any other engine ERROR is a defect
			# (reviewer F4).
			var spawned := _spawn_child("thrproj",
					_project_body("ThrChild", "", true),
					"threaded_edge", true)
			if spawned.has("err"):
				return _fail(spawned["err"])
			var expect := ("CHILD_RESULT pp_edge0=true "
					+ "proc_dss_refused=true srv_ok=true")
			if spawned["code"] != 0 or spawned["serr"] or spawned["last"] != expect:
				return _fail("threaded_edge child mismatch exit=%d serr=%s verdict='%s'"
						% [spawned["code"], str(spawned["serr"]), spawned["last"]])
			_exit_ok("PASS phys3d_events threaded_edge pp_edge0=true proc_dss_refused=true srv_ok=true child_exit=0")

		"phase_delta":
			# write-phase discriminant as a first-class cell (r83 critic
			# C1): the SAME rigid teleport into the SAME settled area
			# fires body_entered at delta=2 when the write issues from the
			# process phase (await process_frame continuation) vs delta=1
			# from the physics phase — the frame owns the extra tick, not
			# the solver (replicated live-only under Jolt: identical
			# deltas on this build).
			var area := Area3D.new()
			var ashape := CollisionShape3D.new()
			var abox := BoxShape3D.new()
			abox.size = Vector3(4, 4, 4)
			ashape.shape = abox
			area.add_child(ashape)
			area.collision_layer = 0
			area.collision_mask = 2
			area.monitoring = true
			area.body_entered.connect(func(_b):
				sig_log.append(Engine.get_physics_frames()))
			root.add_child(area)
			owned_nodes.append(area)
			var bshape := CollisionShape3D.new()
			var bbox := BoxShape3D.new()
			bbox.size = Vector3(1, 1, 1)
			bshape.shape = bbox
			var body := RigidBody3D.new()
			body.collision_layer = 2
			body.gravity_scale = 0.0
			body.add_child(bshape)
			body.position = WALL_FAR
			root.add_child(body)
			owned_nodes.append(body)
			await _frames(SETTLE)
			# (a) process-phase write -> enter lands TWO ticks later.
			await process_frame
			var f0 := Engine.get_physics_frames()
			body.position = Vector3.ZERO
			var w0_fired := sig_log.size() > 0
			var w0_ov := area.get_overlapping_bodies().size()
			await _frames(1)
			var n1_fired := sig_log.size() > 0
			var n1_ov := area.get_overlapping_bodies().size()
			await _frames(1)
			var n2_fired := sig_log.size() > 0
			var n2_ov := area.get_overlapping_bodies().size()
			var proc_delta: int = -1
			if n2_fired:
				proc_delta = sig_log[0] - f0
			if w0_fired or n1_fired or not n2_fired or proc_delta != 2 \
					or w0_ov != 0 or n1_ov != 0 or n2_ov != 1:
				return _fail("phase_delta proc-phase drift w0=%s,%d n1=%s,%d n2=%s,%d delta=%d"
						% [str(w0_fired), w0_ov, str(n1_fired), n1_ov,
						str(n2_fired), n2_ov, proc_delta])
			# (b) dissolve the pair, then the physics-phase contrast. The
			# sig_log clear mirrors static_nopair: without it the delta
			# reads a stale first entry (critic C2 lesson folded in r83).
			body.position = WALL_FAR
			await _frames(6)
			var left := area.get_overlapping_bodies().size()
			sig_log.clear()
			var f1 := Engine.get_physics_frames()
			body.position = Vector3.ZERO
			var p0_fired := sig_log.size() > 0
			await _frames(1)
			var p1_fired := sig_log.size() > 0
			var p1_ov := area.get_overlapping_bodies().size()
			var phys_delta: int = -1
			if p1_fired:
				phys_delta = sig_log[0] - f1
			if left != 0 or p0_fired or not p1_fired or phys_delta != 1 \
					or p1_ov != 1:
				return _fail("phase_delta phys-phase drift left=%d w0=%s n1=%s,%d delta=%d"
						% [left, str(p0_fired), str(p1_fired), p1_ov, phys_delta])
			_exit_ok("PASS phys3d_events phase_delta proc_delta=2 phys_delta=1")

		"jolt_edge":
			# backend-split cell: re-exec this script under a generated
			# physics/3d/physics_engine="Jolt Physics" project (the
			# threaded_edge thrproj pattern -> joltproj, now through
			# _spawn_child) and pin the per-arm split {same-signature |
			# differs-constants | inverts}. static_nopair is the known
			# inverter (r83 critic C2: under Jolt the teleported static
			# body pairs and fires). Gate first: if this build's engine
			# hint lacks "Jolt Physics" the row reports BLOCKED, never a
			# fabricated split.
			if _gate("Jolt Physics", "jolt_edge", "jolt"): return
			var spawned := _spawn_child("joltproj",
					_project_body("JoltChild", "Jolt Physics", false),
					"jolt_edge", false)
			if spawned.has("err"):
				return _fail(spawned["err"])
			# no expected-witness error class under Jolt: any engine
			# ERROR: is a defect (r83 reviewer F4) — allow_inaccessible=0.
			var expect := {
				"jolt_backend": "Jolt Physics",
				"jolt_dss_class": "JoltPhysicsDirectSpaceState3D",
				"jolt_isect": "same-signature",
				"jolt_cast": "differs-constants",
				"jolt_btm": "differs-constants",
				"jolt_contact_stale": "same-signature",
				"jolt_static_nopair": "inverts",
			}
			if spawned["code"] != 0 or spawned["serr"] \
					or spawned["verdicts"] != expect:
				return _fail("jolt_edge child mismatch exit=%d serr=%s verdicts=%s"
						% [spawned["code"], str(spawned["serr"]),
						str(spawned["verdicts"])])
			_exit_ok("PASS phys3d_events jolt_edge backend=Jolt isect=same cast=constants btm=constants contact_stale=same static_nopair=inverts child_exit=0")

		"jolt_threaded":
			# cross-product cell (r85): generated child carrying BOTH
			# physics_engine="Jolt Physics" AND
			# 3d/run_on_separate_thread=true. Pins whether the backend
			# split {same-signature | differs-constants | inverts} holds
			# identically under the threaded stepper. The map additionally
			# pins jt_threaded=true — the child's process-context
			# space_get_direct_state refusals — so a project whose
			# threading flag was silently ignored fails loudly (those
			# refusal ERRORs are the expected witness class here).
			if _gate("Jolt Physics", "jolt_threaded", "jolt"): return
			var spawned := _spawn_child("joltthrproj",
					_project_body("JoltThrChild", "Jolt Physics", true),
					"jolt_threaded", true)
			if spawned.has("err"):
				return _fail(spawned["err"])
			var expect_jt := {
				"jt_backend": "Jolt Physics",
				"jt_threaded": "true",
				"jt_dss_class": "JoltPhysicsDirectSpaceState3D",
				"jt_isect": "same-signature",
				"jt_cast": "differs-constants",
				"jt_btm": "differs-constants",
				"jt_contact_stale": "same-signature",
				"jt_static_nopair": "inverts",
			}
			if spawned["code"] != 0 or spawned["serr"] \
					or spawned["verdicts"] != expect_jt:
				return _fail("jolt_threaded child mismatch exit=%d serr=%s verdicts=%s"
						% [spawned["code"], str(spawned["serr"]),
						str(spawned["verdicts"])])
			_exit_ok("PASS phys3d_events jolt_threaded backend=Jolt threaded=true isect=same cast=constants btm=constants contact_stale=same static_nopair=inverts child_exit=0")

		"dummy_refused":
			# negative control (r85): the SAME reduced sweep under
			# physics_engine="Dummy". Dummy answers every query with
			# zero/silent reads, so every arm must classify 'unexpected'
			# — never a known-class label. This cell proves the
			# {same|differs|inverts} split is backend-real: the verdict
			# map changes with the backend, not with the sweep code.
			if _gate("Dummy", "dummy_refused", "dummy"): return
			var spawned := _spawn_child("dummyproj",
					_project_body("DummyChild", "Dummy", false),
					"dummy_refused", false)
			if spawned.has("err"):
				return _fail(spawned["err"])
			var expect_dm := {
				"dummy_backend": "Dummy",
				"dummy_dss_class": "PhysicsDirectSpaceState3DDummy",
				"dummy_isect": "unexpected",
				"dummy_cast": "unexpected",
				"dummy_btm": "unexpected",
				"dummy_contact_stale": "unexpected",
				"dummy_static_nopair": "unexpected",
			}
			if spawned["code"] != 0 or spawned["serr"] \
					or spawned["verdicts"] != expect_dm:
				return _fail("dummy_refused child mismatch exit=%d serr=%s verdicts=%s"
						% [spawned["code"], str(spawned["serr"]),
						str(spawned["verdicts"])])
			_exit_ok("PASS phys3d_events dummy_refused backend=Dummy isect=unexpected cast=unexpected btm=unexpected contact_stale=unexpected static_nopair=unexpected child_exit=0")

		"srv_phase_delta":
			# server-write phase delta (r85 stretch): a
			# PhysicsServer3D-level body_set_state write vs the
			# node-position writes of phase_delta — the event tier lands
			# at the SAME boundaries (proc -> delta=2, physics -> delta=1):
			# the write PATH is not a tier, the write PHASE is. The
			# monitor must be the server-level area_set_monitor_callback:
			# a raw server RID carries no instance id, so a node Area3D's
			# body_entered / get_overlapping_bodies can never resolve it
			# (measured r85: node monitor stays silent under a
			# server-write pair).
			var srv_log := []
			var sashape := PhysicsServer3D.box_shape_create()
			PhysicsServer3D.shape_set_data(sashape, Vector3(2.0, 2.0, 2.0))
			var sarea := PhysicsServer3D.area_create()
			PhysicsServer3D.area_add_shape(sarea, sashape)
			PhysicsServer3D.area_set_collision_layer(sarea, 1)
			PhysicsServer3D.area_set_collision_mask(sarea, 1)
			PhysicsServer3D.area_set_space(sarea, wspace)
			PhysicsServer3D.area_set_transform(sarea,
					Transform3D(Basis(), Vector3.ZERO))
			owned.append_array([sarea, sashape])
			PhysicsServer3D.area_set_monitor_callback(sarea,
					func(status, _rid, _iid, _shape, _self_shape):
					srv_log.append("%d@%d" % [status, Engine.get_physics_frames()]))
			var srig := _mk_body(WALL_FAR, PhysicsServer3D.BODY_MODE_RIGID)
			PhysicsServer3D.body_set_param(srig,
					PhysicsServer3D.BODY_PARAM_GRAVITY_SCALE, 0.0)
			await _frames(SETTLE)
			# (a) process-phase server write -> enter lands TWO ticks
			# later (the phase_delta boundary, via the server path).
			await process_frame
			var f0 := Engine.get_physics_frames()
			PhysicsServer3D.body_set_state(srig,
					PhysicsServer3D.BODY_STATE_TRANSFORM,
					Transform3D(Basis(), Vector3.ZERO))
			var s_w0 := srv_log.size()
			await _frames(1)
			var s_n1 := srv_log.size()
			await _frames(1)
			var s_n2 := srv_log.size()
			if s_w0 != 0 or s_n1 != 0 or s_n2 != 1 \
					or srv_log != ["0@%d" % (f0 + 2)]:
				return _fail("srv_phase_delta proc drift w0=%d n1=%d n2=%d log=%s"
						% [s_w0, s_n1, s_n2, str(srv_log)])
			# (b) dissolve (exit at +1 from this in-phase write), clear,
			# then the physics-phase contrast: enter at +1.
			PhysicsServer3D.body_set_state(srig,
					PhysicsServer3D.BODY_STATE_TRANSFORM,
					Transform3D(Basis(), WALL_FAR))
			var fexit := Engine.get_physics_frames()
			await _frames(1)
			var exit_ok := srv_log.size() == 2 \
					and srv_log.has("1@%d" % (fexit + 1))
			await _frames(5)
			srv_log.clear()
			var f1 := Engine.get_physics_frames()
			PhysicsServer3D.body_set_state(srig,
					PhysicsServer3D.BODY_STATE_TRANSFORM,
					Transform3D(Basis(), Vector3.ZERO))
			var s_p0 := srv_log.size()
			await _frames(1)
			var s_p1 := srv_log.size()
			if not exit_ok or s_p0 != 0 or s_p1 != 1 \
					or srv_log != ["0@%d" % (f1 + 1)]:
				return _fail("srv_phase_delta phys drift exit=%s p0=%d p1=%d log=%s"
						% [str(exit_ok), s_p0, s_p1, str(srv_log)])
			_exit_ok("PASS phys3d_events srv_phase_delta srv_proc_delta=2 srv_phys_delta=1")

		"script_size_gate":
			# size-gate cell (r86): the deferred process-context fetch is
			# released or refused by the script's STATEMENT COUNT, NOT by
			# the fetch position — an uncalled function body releases it
			# too (r86 critic A3: dead code at 1000 statements granted
			# 7/7) — and on this host that is
			# a ~100-line STOCHASTIC BAND (~475-575 lines), not a boundary
			# (r86 boundary §1, 6 reps per point: deterministic refusal
			# below, deterministic grant above, a race inside). One
			# generated source at two sizes in the same threaded project
			# is the discriminating pair: the same `_run` body is refused
			# at 25 lines and granted at 1025, and both ends sit far
			# outside the band. The unthreaded child is the control — the
			# minimal body is granted without the threading flag, so the
			# gate needs the flag AND the small script. The fourth child
			# is this fixture itself (bare fetch, same position): it is
			# granted, which is the LATENT fragility this arm makes loud —
			# the r86 boundary seat shrank the fixture 16 times to 725
			# lines without flipping it, so the file would have to lose
			# ~500 lines of real tokens to reach the band.
			#
			# Witness discipline: every child here is a self-report, so
			# each is corroborated by the engine's own lines in its log —
			# exactly one refusal for the refused child, none for the three
			# granted ones — and the carve-out is NOT used, so an extra
			# refusal at any callsite fails the arm instead of hiding.
			var thr_proj := _project_body("SzThr", "", true)
			var plain_proj := _project_body("SzPlain", "", false)
			var min_body := _size_probe_body(0)
			var min_thr := _spawn_probe("szminproj", thr_proj, "szprobe.gd",
					min_body, "guarded", false)
			if min_thr.has("err"):
				return _fail(min_thr["err"])
			var min_plain := _spawn_probe("szplainproj", plain_proj, "szprobe.gd",
					min_body, "guarded", false)
			if min_plain.has("err"):
				return _fail(min_plain["err"])
			var pad_thr := _spawn_probe("szpadproj", thr_proj, "szprobe.gd",
					_size_probe_body(SIZE_PAD), "guarded", false)
			if pad_thr.has("err"):
				return _fail(pad_thr["err"])
			var fixture_thr := _spawn_child("szfxproj", thr_proj, "size_probe", false)
			if fixture_thr.has("err"):
				return _fail(fixture_thr["err"])
			var probes := [
				["min_thr", min_thr, "sz_fetch", "refused", 1,
						"ERROR: Space state is inaccessible"],
				["min_plain", min_plain, "sz_fetch", "granted", 0, ""],
				["pad_thr", pad_thr, "sz_fetch", "granted", 0, ""],
				["fixture_thr", fixture_thr, "sp_fetch", "granted", 0, ""],
			]
			for spec in probes:
				var spawn: Dictionary = spec[1]
				var errs: Array = spawn["errs"]
				var verdicts: Dictionary = spawn["verdicts"]
				var ok: bool = spawn["code"] == 0 and verdicts.size() == 1 \
						and verdicts.get(spec[2]) == spec[3] \
						and errs.size() == spec[4]
				if ok and spec[4] == 1:
					ok = str(errs[0]).begins_with(spec[5])
				if not ok:
					return _fail("script_size_gate %s drift exit=%d v=%s errs=%s"
							% [spec[0], spawn["code"], str(verdicts), str(errs)])
			# the refused child's own "ERROR: Space state is inaccessible"
			# print would satisfy the spec above (boundary MX4 / critic A4 —
			# the child log merges 2>&1 by design for position fidelity, so
			# corroborate by the ENGINE's provenance line in the raw log,
			# which a self-print cannot produce).
			var min_log := FileAccess.open(ProjectSettings.globalize_path(
					"res://szminproj/child.log"), FileAccess.READ)
			var saw_callsite := false
			if min_log != null:
				while not min_log.eof_reached():
					if "space_get_direct_state" in min_log.get_line():
						saw_callsite = true
				min_log.close()
			if not saw_callsite:
				return _fail("script_size_gate min_thr: no engine "
						+ "space_get_direct_state callsite line in the raw "
						+ "child log — the refusal could be self-printed")
			_exit_ok("PASS phys3d_events script_size_gate min_thr=refused min_plain=granted pad_thr=granted fixture_thr=granted child_exit=0")

		"deferred_hang":
			# hang-class cell (r86): an unguarded deref of the refused
			# fetch inside the deferred `_run` coroutine aborts the
			# coroutine before quit(), the SceneTree keeps running with
			# no exit condition, and the spawn bound kills it — rc 137
			# through /bin/sh, no CHILD_RESULT line at all. rc is the only
			# detector: a SIGKILLed process emits no at-exit report, so
			# the leak scan never runs and the zombie RIDs stay invisible
			# (r86 boundary §3.1). The witness is engine-level and
			# two-sided — the refusal that caused the abort AND the abort
			# line, both in the child log, plus the process-level rc —
			# never the killed child's own report, which cannot exist.
			# The Dummy+threaded child is the contrast and the class
			# boundary: the silent floor grants every fetch, so the
			# IDENTICAL body dereferences a real handle, prints its class
			# and exits 0 — the hang is reachable only where a refusal is,
			# never under Dummy.
			var hang_thr := _project_body("HangThr", "", true)
			var hang_dummy := _project_body("HangDummy", "Dummy", true)
			var hang_body := _size_probe_body(0)
			var hung := _spawn_probe("hangproj", hang_thr, "szprobe.gd",
					hang_body, "deref", false, HANG_BOUND_S)
			if hung.has("err"):
				return _fail(hung["err"])
			var floor_ok := _spawn_probe("hangdummyproj", hang_dummy, "szprobe.gd",
					hang_body, "deref", false, HANG_BOUND_S)
			if floor_ok.has("err"):
				return _fail(floor_ok["err"])
			var aborted := false
			var refused := false
			for line in hung["errs"]:
				# the landed abort text, not just the class: an unrelated
				# SCRIPT ERROR elsewhere in the child must not satisfy the
				# witness (r86 critic A1).
				if "SCRIPT ERROR" in line and "null instance" in line:
					aborted = true
				if str(line).begins_with("ERROR: Space state is inaccessible"):
					refused = true
			if hung["code"] != HANG_RC or not hung["verdicts"].is_empty() \
					or not aborted or not refused or hung["errs"].size() != 2:
				return _fail("deferred_hang drift exit=%d expected=%d marker=%s abort=%s refusal=%s errs=%s"
						% [hung["code"], HANG_RC, str(hung["verdicts"]),
						str(aborted), str(refused), str(hung["errs"])])
			if floor_ok["code"] != 0 or not floor_ok["errs"].is_empty() \
					or floor_ok["verdicts"] != {"sz_abort": "PhysicsDirectSpaceState3DDummy"}:
				return _fail("deferred_hang dummy-floor drift exit=%d errs=%s v=%s"
						% [floor_ok["code"], str(floor_ok["errs"]),
						str(floor_ok["verdicts"])])
			_exit_ok("PASS phys3d_events deferred_hang threaded_rc=137 abort=true no_marker=true dummy_rc=0 floor_no_hang=true child_exit=0")

		"backend_tier":
			# backend tier matrix (r86): the SAME tier sweep under the
			# three generated projects, so a class difference can never
			# be a code difference. Area gravity/damping overrides are
			# the new inverter — GodotPhysics honours them (the body
			# reads (0,20,0) / damp 2.0), Jolt silently ignores them
			# while the area parameter itself reads back 20.0 (the write
			# lands, the effect does not), and Dummy is the silent floor.
			# The shape-query margin splits the other way: inert on
			# GodotPhysics, honoured by Jolt, empty under Dummy. The
			# separation ray keeps the edge and differs only in solver
			# constants. Gated on both engine hints — absent means an
			# honest BLOCKED row, never a fabricated split.
			if _gate("Jolt Physics", "backend_tier", "jolt"): return
			if _gate("Dummy", "backend_tier", "dummy"): return
			var tier_plain := _spawn_child("tierplainproj",
					_project_body("TierPlain", "", false),
					"tier_plain", false)
			if tier_plain.has("err"):
				return _fail(tier_plain["err"])
			var tier_jolt := _spawn_child("tierjoltproj",
					_project_body("TierJolt", "Jolt Physics", false),
					"tier_jolt", false)
			if tier_jolt.has("err"):
				return _fail(tier_jolt["err"])
			var tier_dummy := _spawn_child("tierdummyproj",
					_project_body("TierDummy", "Dummy", false),
					"tier_dummy", false)
			if tier_dummy.has("err"):
				return _fail(tier_dummy["err"])
			var expect_plain := {
				"plain_backend": "DEFAULT",
				"plain_dss_class": "GodotPhysicsDirectSpaceState3D",
				"plain_area_override": "honors",
				"plain_margin": "inert",
				"plain_sepray": "same-signature",
			}
			var expect_jolt := {
				"jolt_backend": "Jolt Physics",
				"jolt_dss_class": "JoltPhysicsDirectSpaceState3D",
				"jolt_area_override": "ignores",
				"jolt_margin": "binds",
				"jolt_sepray": "differs-constants",
			}
			var expect_dummy := {
				"dummy_backend": "Dummy",
				"dummy_dss_class": "PhysicsDirectSpaceState3DDummy",
				"dummy_area_override": "floor",
				"dummy_margin": "empty",
				"dummy_sepray": "floor",
			}
			for probe in [[tier_plain, expect_plain, "plain"],
					[tier_jolt, expect_jolt, "jolt"],
					[tier_dummy, expect_dummy, "dummy"]]:
				var spawn: Dictionary = probe[0]
				if spawn["code"] != 0 or spawn["serr"] \
						or spawn["verdicts"] != probe[1]:
					return _fail("backend_tier %s drift exit=%d serr=%s v=%s"
							% [probe[2], spawn["code"], str(spawn["serr"]),
							str(spawn["verdicts"])])
			_exit_ok("PASS phys3d_events backend_tier plain=honors jolt=ignores dummy=floor margin=inert,binds,empty sepray=same,differs,floor child_exit=0")

		"dummy_floor":
			# silent-floor cell (r86): the Dummy backend as a class, not a
			# failure. The dummy child pins the 11-token floor signature —
			# creates come back RID(0), reads come back Nil / 0.0 /
			# empty, a box shape reports type 2, and a direct state comes
			# back for ANY argument including RID(0) — and produces zero
			# rejected lines. The real-backend child runs the IDENTICAL
			# body and produces exactly two loud refusals on the same two
			# calls, so the floor can never be read as a refusal: the
			# Dummy backend answers where a real backend errors.
			if _gate("Dummy", "dummy_floor", "dummy"): return
			var floor_dummy := _spawn_child("floordummyproj",
					_project_body("FloorDummy", "Dummy", false),
					"floor_dummy", false)
			if floor_dummy.has("err"):
				return _fail(floor_dummy["err"])
			var floor_real := _spawn_child("floorrealproj",
					_project_body("FloorReal", "", false),
					"floor_real", false)
			if floor_real.has("err"):
				return _fail(floor_real["err"])
			if floor_dummy["code"] != 0 \
					or floor_dummy["verdicts"] != {"dummy_backend": "Dummy",
							"dummy_floor": "silent-floor"} \
					or not floor_dummy["errs"].is_empty():
				return _fail("dummy_floor dummy drift exit=%d v=%s errs=%s"
						% [floor_dummy["code"], str(floor_dummy["verdicts"]),
						str(floor_dummy["errs"])])
			var real_errs: Array = floor_real["errs"]
			if floor_real["code"] != 0 \
					or floor_real["verdicts"] != {"real_backend": "DEFAULT",
							"real_floor": "real-values"} \
					or real_errs.size() != 2 \
					or not str(real_errs[0]).begins_with(
							"ERROR: Parameter \"space\" is null.") \
					or not str(real_errs[1]).begins_with("ERROR: Invalid ID."):
				return _fail("dummy_floor real-backend refusal drift exit=%d v=%s errs=%s"
						% [floor_real["code"], str(floor_real["verdicts"]),
						str(real_errs)])
			_exit_ok("PASS phys3d_events dummy_floor dummy=silent-floor dummy_errs=0 real=real-values real_errs=2 child_exit=0")

		"body_handle":
			# held-handle identity law (r87): the object
			# `body_get_direct_state` returns is ONE per-body singleton live
			# handle — the SAME instance the engine hands
			# RigidBody3D._integrate_forces and
			# body_set_state_sync_callback — and it survives detach/reattach.
			# Three generated children, one sweep: a class difference can
			# never be a code difference. Dummy is the floor contrast (its
			# callbacks never fire and its fetch answers for ANY RID), and
			# the row is never a Dummy hazard detector (scout directive 8).
			if _gate("Jolt Physics", "body_handle", "jolt"): return
			if _gate("Dummy", "body_handle", "dummy"): return
			var bh_plain := _spawn_child("bhplainproj",
					_project_body("BhPlain", "", false), "bh_plain", false)
			if bh_plain.has("err"):
				return _fail(bh_plain["err"])
			var bh_jolt := _spawn_child("bhjoltproj",
					_project_body("BhJolt", "Jolt Physics", false),
					"bh_jolt", false)
			if bh_jolt.has("err"):
				return _fail(bh_jolt["err"])
			var bh_dummy := _spawn_child("bhdummyproj",
					_project_body("BhDummy", "Dummy", false), "bh_dummy", false)
			if bh_dummy.has("err"):
				return _fail(bh_dummy["err"])
			var expect_bh_plain := {
				"bh_plain_backend": "DEFAULT",
				"bh_plain_if_same": "true",
				"bh_plain_ss_same": "true",
				"bh_plain_ss_fired": ">0",
				"bh_plain_detach": "nil",
				"bh_plain_held_live": "true",
				"bh_plain_reattach": "true",
				"bh_plain_twin": "true",
			}
			var expect_bh_jolt := {
				"bh_jolt_backend": "Jolt Physics",
				"bh_jolt_if_same": "true",
				"bh_jolt_ss_same": "true",
				"bh_jolt_ss_fired": ">0",
				"bh_jolt_detach": "nil",
				"bh_jolt_held_live": "true",
				"bh_jolt_reattach": "true",
				"bh_jolt_twin": "true",
			}
			# Dummy: no callback ever fires, and the fetch answers for a
			# detached RID too — the floor contrast, pinned as its own dict
			# rather than folded into the real-backend law.
			var expect_bh_dummy := {
				"bh_dummy_backend": "Dummy",
				"bh_dummy_if_same": "false",
				"bh_dummy_ss_same": "false",
				"bh_dummy_ss_fired": "0",
				"bh_dummy_detach": "obj",
				"bh_dummy_held_live": "true",
				"bh_dummy_reattach": "true",
				"bh_dummy_twin": "true",
			}
			for probe in [[bh_plain, expect_bh_plain, "plain"],
					[bh_jolt, expect_bh_jolt, "jolt"],
					[bh_dummy, expect_bh_dummy, "dummy"]]:
				var spawn: Dictionary = probe[0]
				if spawn["code"] != 0 or spawn["serr"] \
						or spawn["verdicts"] != probe[1]:
					return _fail("body_handle %s drift exit=%d serr=%s v=%s"
							% [probe[2], spawn["code"], str(spawn["serr"]),
							str(spawn["verdicts"])])
			_exit_ok("PASS phys3d_events body_handle if_same=true ss_same=true detach=nil held_live=true reattach=true twin=true dummy_cb=never child_exit=0")

		"acq_use":
			# acquisition-vs-use split (r87): under
			# run_on_separate_thread the FETCH is gated (a fresh
			# body_get_direct_state at a process-frame position returns a
			# null-Object Variant and the engine prints "Body state is
			# inaccessible right now"), but a handle obtained ONCE at a
			# legal position reads live and its writes land at every later
			# position — the gate controls ACQUISITION, not USE. The gate
			# witness is also the threading witness: a child whose
			# run_on_separate_thread key was silently ignored would grant
			# every fetch and fail this row loudly instead of reprinting the
			# unthreaded map.
			if _gate("Jolt Physics", "acq_use", "jolt"): return
			var au_allow := ["Body state is inaccessible"]
			var au_plain := _spawn_child("auplainproj",
					_project_body("AuPlain", "", true), "au_plain", false,
					"res://phys3d_events.gd", 30, au_allow)
			if au_plain.has("err"):
				return _fail(au_plain["err"])
			var au_jolt := _spawn_child("aujoltproj",
					_project_body("AuJolt", "Jolt Physics", true),
					"au_jolt", false, "res://phys3d_events.gd", 30, au_allow)
			if au_jolt.has("err"):
				return _fail(au_jolt["err"])
			for probe in [[au_plain, "DEFAULT", "plain"],
					[au_jolt, "Jolt Physics", "jolt"]]:
				var spawn: Dictionary = probe[0]
				var want := {
					"au_%s_backend" % probe[2]: probe[1],
					"au_%s_gate" % probe[2]: "refused",
					"au_%s_use" % probe[2]: "ungated",
					"au_%s_out_of_phase" % probe[2]: str(BODY_REPS),
				}
				if spawn["code"] != 0 or spawn["serr"] \
						or spawn["verdicts"] != want:
					return _fail("acq_use %s drift exit=%d serr=%s v=%s errs=%s"
							% [probe[2], spawn["code"], str(spawn["serr"]),
							str(spawn["verdicts"]), str(spawn["errs"])])
			# r87 critic F3: allow_lines forgives the class; the count is
			# the conjunct. Each refused fresh fetch prints one engine
			# ERROR — == BODY_REPS in the raw log, so a silently-nil
			# fetch (the scout's class-3 shape) can never pass as a
			# gated refusal.
			for dirname in ["auplainproj", "aujoltproj"]:
				var refusals := _log_count(ProjectSettings.globalize_path(
						"res://%s/child.log" % dirname),
						"Body state is inaccessible")
				if refusals != BODY_REPS:
					return _fail("acq_use %s refusal lines=%d expected=%d"
							% [dirname, refusals, BODY_REPS])
			_exit_ok("PASS phys3d_events acq_use gate=refused out_of_phase=8 held_read=live write=ungated reps=8 child_exit=0")

		"step_stamp":
			# step-stamped getters (r87): the body-state object has its own
			# internal flush seams. `get_step` reads a backend INIT CONSTANT
			# before the first solve completes (0.0010000000475 on
			# GodotPhysics, 0.0 on Jolt) and the real dt (0.0166666675359)
			# after it; `get_total_gravity`/`get_total_linear_damp` are
			# step-stamped on GodotPhysics ONLY — Jolt reports the real
			# values before the first solve, which is a backend split INSIDE
			# the step-stamped class (the r87-scout-dss summary generalised
			# the GodotPhysics behaviour; its own ph_proj_jolt receipt shows
			# the split). The contact buffer is the one snapshot-semantics
			# field (last-step data) and reports nothing at all until
			# body_set_max_contacts_reported opts the body in.
			if _gate("Jolt Physics", "step_stamp", "jolt"): return
			var ss_plain := _spawn_child("ssplainproj",
					_project_body("SsPlain", "", false), "ss_plain", false)
			if ss_plain.has("err"):
				return _fail(ss_plain["err"])
			var ss_jolt := _spawn_child("ssjoltproj",
					_project_body("SsJolt", "Jolt Physics", false),
					"ss_jolt", false)
			if ss_jolt.has("err"):
				return _fail(ss_jolt["err"])
			var expect_ss_plain := {
				"ss_plain_backend": "DEFAULT",
				"ss_plain_step_pre": "0.0010000000475",
				"ss_plain_grav_pre": "zero",
				"ss_plain_damp_pre": "0.0",
				"ss_plain_step_post": "0.0166666675359",
				"ss_plain_damp_post": "0.10000000149012",
				"ss_plain_cc_off": "0",
				"ss_plain_cc_on": "4",
				"ss_plain_last_step": "4,0",
			}
			var expect_ss_jolt := {
				"ss_jolt_backend": "Jolt Physics",
				"ss_jolt_step_pre": "0.0",
				"ss_jolt_grav_pre": "real",
				"ss_jolt_damp_pre": "0.10000000149012",
				"ss_jolt_step_post": "0.0166666675359",
				"ss_jolt_damp_post": "0.10000000149012",
				"ss_jolt_cc_off": "0",
				"ss_jolt_cc_on": "4",
				"ss_jolt_last_step": "4,0",
			}
			for probe in [[ss_plain, expect_ss_plain, "plain"],
					[ss_jolt, expect_ss_jolt, "jolt"]]:
				var spawn: Dictionary = probe[0]
				if spawn["code"] != 0 or spawn["serr"] \
						or spawn["verdicts"] != probe[1]:
					return _fail("step_stamp %s drift exit=%d serr=%s v=%s"
							% [probe[2], spawn["code"], str(spawn["serr"]),
							str(spawn["verdicts"])])
			_exit_ok("PASS phys3d_events step_stamp gp_step_pre=0.001 gp_grav_pre=zero jolt_step_pre=0.0 jolt_grav_pre=real step_post=0.016667 cc_off=0 cc_on=4 last_step=4,0 child_exit=0")

		"write_loss":
			# out-of-phase write-loss race (r87): a held-handle write issued
			# out of phase is ungated and UNSYNCHRONIZED — nothing orders it
			# against the physics thread, so a lost update is possible in
			# principle. This row is the bounded repeated-observation form
			# the class demands: BODY_REPS reps, each asserting the
			# deterministic witnesses (the fresh fetch refused at every rep,
			# the write applied and same-turn visible at every rep, the
			# tally accounted) while the per-rep split stays EVIDENCE, not a
			# gate. The r87-scout-dss `fl_proj_thr` r1 loss was NOT
			# reproduced by this form (0 lost across 13 author child runs
			# and 4 landed/lost forms), so the row pins the precondition plus
			# the accounted tally and reports the split in the child log —
			# it never claims a loss it did not witness.
			var wl_allow := ["Body state is inaccessible"]
			var wl := _spawn_child("wlproj",
					_project_body("WlProj", "", true), "wl_plain", false,
					"res://phys3d_events.gd", 30, wl_allow)
			if wl.has("err"):
				return _fail(wl["err"])
			var wl_v: Dictionary = wl["verdicts"]
			var wl_landed := int(wl_v.get("wl_plain_landed", "-1"))
			var wl_lost := int(wl_v.get("wl_plain_lost", "-1"))
			var wl_ok: bool = wl["code"] == 0 and not wl["serr"] \
					and wl_v.get("wl_plain_backend") == "DEFAULT" \
					and wl_v.get("wl_plain_gate") == "refused" \
					and int(wl_v.get("wl_plain_same_turn", "-1")) == BODY_REPS \
					and wl_landed >= 1 and wl_landed + wl_lost == BODY_REPS
			if not wl_ok:
				return _fail("write_loss drift exit=%d v=%s errs=%s"
						% [wl["code"], str(wl_v), str(wl["errs"])])
			# r87 critic F3: the refusal count is the corroborating
			# conjunct — == BODY_REPS engine ERROR lines in the raw log.
			var wl_refusals := _log_count(ProjectSettings.globalize_path(
					"res://wlproj/child.log"),
					"Body state is inaccessible")
			if wl_refusals != BODY_REPS:
				return _fail("write_loss refusal lines=%d expected=%d"
						% [wl_refusals, BODY_REPS])
			_exit_ok("PASS phys3d_events write_loss gate=refused reps=8 same_turn=8 race=bounded child_exit=0")

		"body_tier":
			# backend split at the body tier (r87): three generated children,
			# one sweep. GodotPhysics reads the FIRST in-contact step's
			# get_contact_impulse(0) as exactly zero while Jolt reads the real
			# impact impulse (the impulse cell is pinned at that step in the
			# scout geometry — on GodotPhysics the same field oscillates
			# through zero at later steps, so "GP is always zero" is a
			# sampling artifact and is NOT claimed); the out-of-range
			# contact_local_shape reads -1 vs 0; set_sleep_state(true) keeps
			# the velocity on GodotPhysics and zeroes it on Jolt; and the
			# detached-body impulse write is a silent no-op on GodotPhysics
			# and a LOUD Jolt refusal, corroborated by the engine's own line
			# count in the raw child log. Dummy is the silent floor.
			if _gate("Jolt Physics", "body_tier", "jolt"): return
			if _gate("Dummy", "body_tier", "dummy"): return
			var bt_allow := ["Index p_contact_idx",
					"Failed to apply central impulse"]
			var bt_plain := _spawn_child("btplainproj",
					_project_body("BtPlain", "", false), "bt_plain", false,
					"res://phys3d_events.gd", 30, bt_allow)
			if bt_plain.has("err"):
				return _fail(bt_plain["err"])
			var bt_jolt := _spawn_child("btjoltproj",
					_project_body("BtJolt", "Jolt Physics", false),
					"bt_jolt", false, "res://phys3d_events.gd", 30, bt_allow)
			if bt_jolt.has("err"):
				return _fail(bt_jolt["err"])
			var bt_dummy := _spawn_child("btdummyproj",
					_project_body("BtDummy", "Dummy", false), "bt_dummy", false,
					"res://phys3d_events.gd", 30, bt_allow)
			if bt_dummy.has("err"):
				return _fail(bt_dummy["err"])
			var expect_bt_plain := {
				"bt_plain_backend": "DEFAULT",
				"bt_plain_cc": "4",
				"bt_plain_impulse": "zero",
				"bt_plain_lshape_oob": "-1",
				"bt_plain_sleep_lv": "kept",
			}
			var expect_bt_jolt := {
				"bt_jolt_backend": "Jolt Physics",
				"bt_jolt_cc": "4",
				"bt_jolt_impulse": "real",
				"bt_jolt_lshape_oob": "0",
				"bt_jolt_sleep_lv": "zeroed",
			}
			var expect_bt_dummy := {
				"bt_dummy_backend": "Dummy",
				"bt_dummy_cc": "0",
				"bt_dummy_impulse": "nil",
				"bt_dummy_lshape_oob": "absent",
				"bt_dummy_sleep_lv": "flat",
			}
			for probe in [[bt_plain, expect_bt_plain, "plain"],
					[bt_jolt, expect_bt_jolt, "jolt"],
					[bt_dummy, expect_bt_dummy, "dummy"]]:
				var spawn: Dictionary = probe[0]
				if spawn["code"] != 0 or spawn["serr"] \
						or spawn["verdicts"] != probe[1]:
					return _fail("body_tier %s drift exit=%d serr=%s v=%s"
							% [probe[2], spawn["code"], str(spawn["serr"]),
							str(spawn["verdicts"])])
			# the detached-impulse refusal is a LOG witness, never a child
			# self-report: 0 lines on GodotPhysics (silent no-op), exactly 1
			# on Jolt, 0 under Dummy.
			var loud := [
				["btplainproj", 0], ["btjoltproj", 1], ["btdummyproj", 0],
			]
			for spec in loud:
				var n := _log_count(ProjectSettings.globalize_path(
						"res://%s/child.log" % spec[0]),
						"Failed to apply central impulse")
				if n != spec[1]:
					return _fail("body_tier %s detached-impulse refusal count=%d expected=%d"
							% [spec[0], n, spec[1]])
			_exit_ok("PASS phys3d_events body_tier gp_impulse=zero jolt_impulse=real gp_lshape=-1 jolt_lshape=0 gp_sleep_lv=kept jolt_sleep_lv=zeroed dummy_cc=0 detach_write=silent,loud,silent child_exit=0")

		"freed_space":
			# freed-space crash class (r87, FATAL TAIL): the ONE crash
			# surface at this tier is not the body handle but the space
			# handle reached THROUGH it — reaching the space-state object
			# on a freed space kills the process. The crash SITE is
			# backend-specific on this host (r87 critic F2): GodotPhysics
			# dies inside held.get_space_state() itself (the `space=` note
			# never prints), while Jolt's get_space_state() returns the
			# object and the kill is at intersect_ray. GodotPhysics reports
			# signal 11 and then aborts
			# through its own handler; Jolt's crash mode is heap-layout
			# dependent (uncaught std::system_error OR the same signal-11
			# handler); Dummy returns an empty dict and exits 0. The pinned
			# class is one crash line in the raw child log plus the
			# breadcrumb prefix at that backend's site plus the
			# absence of any child marker; the rc is the handler's exit
			# PATH, not the class (GodotPhysics lands 134 in ~1.5 s when the
			# handler completes and 137 when a bound cuts a load-slowed
			# handler short), so both signal-class rcs are accepted and the
			# marker carries the class. Freed-BODY handles are benign
			# (silent nulls) — this is the freed-SPACE cell only.
			if _gate("Jolt Physics", "freed_space", "jolt"): return
			if _gate("Dummy", "freed_space", "dummy"): return
			var fs_plain := _spawn_child("fsplainproj",
					_project_body("FsPlain", "", false), "fs_plain", false,
					"res://phys3d_events.gd", CRASH_BOUND_S)
			if fs_plain.has("err"):
				return _fail(fs_plain["err"])
			var fs_jolt := _spawn_child("fsjoltproj",
					_project_body("FsJolt", "Jolt Physics", false),
					"fs_jolt", false, "res://phys3d_events.gd", CRASH_BOUND_S)
			if fs_jolt.has("err"):
				return _fail(fs_jolt["err"])
			var fs_dummy := _spawn_child("fsdummyproj",
					_project_body("FsDummy", "Dummy", false), "fs_dummy", false,
					"res://phys3d_events.gd", CRASH_BOUND_S)
			if fs_dummy.has("err"):
				return _fail(fs_dummy["err"])
			# a crashing child can leave no marker at all: verdicts must be
			# empty and the rc must be a signal-class exit (134 SIGABRT when
			# the handler finishes, 137 when the bound kills the hung
			# handler). The crash is corroborated by the child's own
			# breadcrumb PREFIX in the raw log at the backend-specific site
			# (r87 critic F1/F2): a bare printed crash line is forgeable —
			# the row requires the full envelope instead. On GodotPhysics
			# the crash fires INSIDE held.get_space_state(), so the log
			# ends at the `held=` note (no `space=` line); on Jolt the
			# space-state object returns and the crash is at
			# intersect_ray, so `space=` prints but `ray` never does.
			var fs_gp_log := ProjectSettings.globalize_path(
					"res://fsplainproj/child.log")
			var fs_gp_line := _log_count(fs_gp_log,
					"handle_crash: Program crashed with signal 11")
			if fs_plain["code"] != 134 and fs_plain["code"] != 137:
				return _fail("freed_space plain rc=%d not signal-class"
						% fs_plain["code"])
			if not fs_plain["verdicts"].is_empty() or fs_gp_line != 1:
				return _fail("freed_space plain marker=%s crash_lines=%d"
						% [str(fs_plain["verdicts"]), fs_gp_line])
			if _log_count(fs_gp_log, "CHILD_NOTE fs_plain held=") != 1 \
					or _log_count(fs_gp_log, "held=nil") != 0 \
					or _log_count(fs_gp_log,
							"CHILD_NOTE fs_plain space=") != 0:
				return _fail("freed_space plain crash-site envelope drift")

			# Jolt's crash MODE is heap-layout dependent, not fixed: the freed
			# space's memory is either still shaped enough like a live Jolt
			# system that the internal check fires and the uncaught throw
			# aborts, or it is not and the query dereferences it into
			# Godot's own SIGSEGV handler. The author measured BOTH modes on
			# this host (the r87-scout-dss probe script: std::system_error
			# 3/3; this fixture's larger child: signal 11 3/3). The row pins
			# the class — hard crash, no marker, exactly one engine crash
			# line, signal-class rc — and records which mode the run took,
			# never one mode as the law.
			var fs_jolt_log := ProjectSettings.globalize_path(
					"res://fsjoltproj/child.log")
			var fs_throw := _log_count(fs_jolt_log, "std::system_error")
			var fs_segv := _log_count(fs_jolt_log,
					"handle_crash: Program crashed with signal 11")
			if fs_jolt["code"] != 134 and fs_jolt["code"] != 137:
				return _fail("freed_space jolt rc=%d not signal-class"
						% fs_jolt["code"])
			if not fs_jolt["verdicts"].is_empty() \
					or fs_throw + fs_segv != 1:
				return _fail("freed_space jolt marker=%s throw=%d segv=%d"
						% [str(fs_jolt["verdicts"]), fs_throw, fs_segv])
			# Jolt site pin (r87 critic F2): get_space_state() returns the
			# object here, so `space=` prints; the crash is at
			# intersect_ray, so `ray_empty`/`ray` never appear.
			if _log_count(fs_jolt_log, "CHILD_NOTE fs_jolt held=") != 1 \
					or _log_count(fs_jolt_log, "held=nil") != 0 \
					or _log_count(fs_jolt_log,
							"CHILD_NOTE fs_jolt space=") != 1 \
					or _log_count(fs_jolt_log,
							"CHILD_NOTE fs_jolt ray") != 0:
				return _fail("freed_space jolt crash-site envelope drift")
			if fs_dummy["code"] != 0 or fs_dummy["serr"] \
					or fs_dummy["verdicts"] != {"fs_dummy_ray": "empty"}:
				return _fail("freed_space dummy drift exit=%d serr=%s v=%s"
						% [fs_dummy["code"], str(fs_dummy["serr"]),
						str(fs_dummy["verdicts"])])
			_exit_ok("PASS phys3d_events freed_space gp=crash jolt=crash dummy=empty child_exit=0")

		_:
			return _fail("unknown arm " + arm)


# --child mode body: runs entirely inside the threaded project. Pins are
# engine-semantic (fetch legality, callable results), never wall-clock.
func _child_threaded() -> void:
	wspace = root.get_world_3d().space
	# (b) pre-physics process-context dss fetch: refused under threading.
	var early_null := PhysicsServer3D.space_get_direct_state(wspace) == null

	var wall := _mk_body(Vector3(0, 0, -3))
	var probe := _mk_body(Vector3.ZERO, PhysicsServer3D.BODY_MODE_KINEMATIC)
	await _frames(SETTLE)

	# (a) inside _physics_process: write -> ray/isect/cast/btm same tick.
	var w := PPQueries.new()
	w.wall = wall
	w.probe = probe
	w.wspace = wspace
	w.dss = null  # force the in-callback fetch path (the conversion)
	root.add_child(w)
	owned_nodes.append(w)
	var deadline := Engine.get_physics_frames() + 30
	while not w.printed and Engine.get_physics_frames() < deadline:
		await _frames(1)
	var pp_edge0 := w.result_ok()

	# (b) process-context fresh fetches: refused for the dss object.
	var nulls := 0
	for i in range(12):
		var d: PhysicsDirectSpaceState3D = PhysicsServer3D.space_get_direct_state(wspace)
		if d == null:
			nulls += 1
		await process_frame
	var proc_dss_refused := nulls >= 8

	# (d) server object-truth + body_test_motion still answer mid-frame
	# (the wall sits at z=-30 after the in-callback move).
	var g: Transform3D = PhysicsServer3D.body_get_state(wall,
			PhysicsServer3D.BODY_STATE_TRANSFORM)
	var params := PhysicsTestMotionParameters3D.new()
	params.from = Transform3D(Basis(), Vector3.ZERO)
	params.motion = Vector3(0, 0, -10)
	var res := PhysicsTestMotionResult3D.new()
	var rb := PhysicsServer3D.body_test_motion(probe, params, res)
	var srv_ok := absf(g.origin.z - (-30.0)) < 0.001 and not rb \
			and absf(res.get_travel().z - (-10.0)) < 0.0001

	# early_null is racy (the startup window sometimes grants the fetch) —
	# reported as a note, never pinned.
	prints("CHILD_NOTE early_null=%s" % str(early_null))
	prints("CHILD_RESULT pp_edge0=%s proc_dss_refused=%s srv_ok=%s"
			% [str(pp_edge0), str(proc_dss_refused), str(srv_ok)])
	_quit_clean()


# --child --arm=size_probe body (r86): this fixture's OWN bare deferred
# fetch, nothing else. The generated pair in the parent arm measures the
# gate; this child is the fixture's own witness, so a fixture that shrank
# below the boundary fails the arm loudly instead of silently refusing the
# fetch everywhere under threading (latent fixture fragility).
func _child_size() -> void:
	var d = root.get_world_3d().direct_space_state
	prints("CHILD_NOTE sp pf=%d null=%s" % [Engine.get_physics_frames(),
			str(d == null)])
	_quit_clean(0, "CHILD_RESULT sp_fetch=%s" % ("refused" if d == null else "granted"))


# --- r85: the generated-project child bodies share one sweep ---------------
# jolt_edge (r84), jolt_threaded and dummy_refused (r85) share `_child_split`:
# a class difference between the three receipts can never be a difference in
# the sweep code (the bodies differ only in engine key, threading flag,
# prefix, plus jolt_threaded's pre-sweep witness loop + allow_inaccessible —
# the r84 simplifier's deferred V2 fold, landed). Each reduced arm replays
# its parent cell's geometry, prints the raw fields as CHILD_NOTE
# (child.log evidence), then one
# `CHILD_RESULT <prefix>_<arm>=<class>` where class is
# same-signature (raw tuple equals the DEFAULT signature) |
# differs-constants (the edge/structure holds; settled constants match the
# signature measured on this build) | inverts (the cell's verdict flips —
# static_nopair fires under Jolt) | unexpected (outside both known
# signatures; fails the parent's compare loudly).


# --child --arm=jolt_edge body (r84): the reduced split sweep under a
# generated physics_engine="Jolt Physics" project.
func _child_jolt() -> void:
	await _child_split("jolt")


# --child --arm=jolt_threaded body (r85 cross-product): the same sweep under
# a generated project carrying BOTH physics_engine="Jolt Physics" AND
# 3d/run_on_separate_thread=true. The split is expected identical to
# jolt_edge (r85 scout §1.1 measured the child route byte-identical under
# threading); the extra pin is the threading witness, so a child whose
# run_on_separate_thread key was silently ignored fails loudly instead of
# reprinting the Jolt map as if the flag had taken effect.
func _child_jolt_threaded() -> void:
	# Threading witness, measured before the sweep: an explicit
	# process-context space_get_direct_state from an idle-frame continuation
	# is refused under run_on_separate_thread=true and granted without it
	# (r85 author probe: 11/12 null on Jolt+threaded, 0/12 on DEFAULT). The
	# >=8-of-12 tolerance mirrors the landed threaded_edge arm's
	# proc_dss_refused witness. The refusal ERRORs are this arm's expected
	# witness class, so the parent spawns it with allow_inaccessible=true.
	var nulls := 0
	for i in range(12):
		if PhysicsServer3D.space_get_direct_state(root.get_world_3d().space) == null:
			nulls += 1
		await process_frame
	prints("CHILD_RESULT jt_threaded=%s" % str(nulls >= 8))
	await _child_split("jt")


# --child --arm=dummy_refused body (r85 negative control): the same sweep
# under a generated physics_engine="Dummy" project. Dummy answers every
# query with zero/silent reads (r85 scout §2.2), so every arm must classify
# 'unexpected' — a known class here would mean the {same|differs|inverts}
# split is a map coincidence, not backend truth. No proc-context fetch loop
# on this body: the Dummy server silently hangs a threaded child (r85 scout
# §2.3, rc 137 at the 20 s bound).
func _child_dummy() -> void:
	await _child_split("dummy")


# The shared reduced sweep: runs entirely inside the generated child project,
# prints `CHILD_RESULT <prefix>_<arm>=<class>` per arm, and terminates the
# child (cleanup + quit(0)); a refused direct space state bails named with
# exit 1 rather than reading every arm blind.
func _child_split(prefix: String) -> void:
	wspace = root.get_world_3d().space
	dss = root.get_world_3d().direct_space_state
	if dss == null:
		# r85: the deferred _run() fetch is refused under threading more
		# often than the r85 scout's size ladder predicted (measured: the
		# jolt_threaded child was refused at this fixture size, 10/10
		# refusals in the author probe). Retry on a bounded physics-frame
		# budget — the position the engine grants under
		# run_on_separate_thread — instead of inheriting a startup race.
		for i in range(8):
			await physics_frame
			dss = root.get_world_3d().direct_space_state
			if dss != null:
				break
	var jolt_cls := ClassDB.class_exists("JoltPhysicsServer3D")
	var godot_cls := ClassDB.class_exists("GodotPhysicsServer3D")
	var engine := str(ProjectSettings.get_setting("physics/3d/physics_engine"))
	prints("CHILD_NOTE %s_class=%s godot_class=%s engine=%s"
			% [prefix, str(jolt_cls), str(godot_cls), engine])
	# The child must really be running Jolt: a silent backend fallback
	# would let GodotPhysics impersonate the split. The ClassDB pair
	# swaps exactly one member per backend on this build (r83 gate).
	prints("CHILD_RESULT %s_backend=%s"
			% [prefix, ("Dummy" if ClassDB.class_exists("PhysicsServer3DDummy")
					else ("Jolt Physics" if jolt_cls and not godot_cls
					else "unexpected"))])
	if dss == null:
		# a null handle would read every query arm as blind — bail named
		prints("CHILD_NOTE %s dss_null=true" % prefix)
		_quit_clean(1)
		return
	# r84 critic: the ClassDB pair is registry-level evidence; the live
	# space-state object's class is the active-backend witness and is
	# pinned in the parent's verdict map.
	prints("CHILD_RESULT %s_dss_class=%s" % [prefix, dss.get_class()])

	# <prefix>_isect: the isect arm's wall/sphere pair, both directions.
	var wall := _mk_body(Vector3(0, 0, -3))
	await _frames(SETTLE)
	var q := _sphere_params(Vector3(0, 0, -2.5))
	var qmask := _sphere_params(Vector3(0, 0, -2.5), Vector3.ZERO, 2)
	var s0 := dss.intersect_shape(q).size()
	var m0 := dss.intersect_shape(qmask).size()
	PhysicsServer3D.body_set_state(wall,
			PhysicsServer3D.BODY_STATE_TRANSFORM, Transform3D(Basis(), WALL_FAR))
	var away := dss.intersect_shape(q).size()
	await _frames(1)
	var away_n1 := dss.intersect_shape(q).size()
	PhysicsServer3D.body_set_state(wall,
			PhysicsServer3D.BODY_STATE_TRANSFORM,
			Transform3D(Basis(), Vector3(0, 0, -3)))
	var back := dss.intersect_shape(q).size()
	prints("CHILD_NOTE %s_isect s0=%d m0=%d away=%d n1=%d back=%d"
			% [prefix, s0, m0, away, away_n1, back])
	var cls := "unexpected"
	if s0 == 1 and m0 == 0 and away == 0 and away_n1 == 0 and back == 1:
		cls = "same-signature"
	elif s0 == 1 and back == 1:
		# r84 critic: differs-constants must stand on positive evidence --
		# a backend that returns nothing at all (Dummy) would otherwise
		# earn a known class from zero reads
		cls = "differs-constants"
	prints("CHILD_RESULT %s_isect=%s" % [prefix, cls])

	# <prefix>_cast: settled fractions are solver constants; the wall->far
	# edge to [1,1] is the lattice signature.
	await _frames(2)  # let the wall re-settle at -3 before the sample
	var qc := _sphere_params(Vector3.ZERO, Vector3(0, 0, -10))
	var c0 := dss.cast_motion(qc)
	PhysicsServer3D.body_set_state(wall,
			PhysicsServer3D.BODY_STATE_TRANSFORM, Transform3D(Basis(), WALL_FAR))
	var c1 := dss.cast_motion(qc)
	await _frames(1)
	var c2 := dss.cast_motion(qc)
	cls = "unexpected"
	if c0.size() < 2 or c1.size() < 2 or c2.size() < 2:
		# r84 critic/reviewer F2: a backend can return a size-0 pair --
		# indexing it aborts with a SCRIPT ERROR instead of classifying
		prints("CHILD_NOTE %s_cast degenerate sizes=%d,%d,%d"
				% [prefix, c0.size(), c1.size(), c2.size()])
	else:
		prints("CHILD_NOTE %s_cast safe=%.6f unsafe=%.6f w0=%.6f,%.6f n1=%.6f,%.6f"
				% [prefix, c0[0], c0[1], c1[0], c1[1], c2[0], c2[1]])
		var cast_edge := absf(c1[0] - 1.0) < 0.0001 \
				and absf(c1[1] - 1.0) < 0.0001 \
				and absf(c2[0] - 1.0) < 0.0001 and absf(c2[1] - 1.0) < 0.0001
		if cast_edge:
			if absf(c0[0] - 0.14453125) < 0.0001 \
					and absf(c0[1] - 0.150390625) < 0.0001:
				cls = "same-signature"
			elif absf(c0[0] - 0.14984130859375) < 0.0001 \
					and absf(c0[1] - 0.1500244140625) < 0.0001:
				cls = "differs-constants"
	prints("CHILD_RESULT %s_cast=%s" % [prefix, cls])

	# <prefix>_btm: kinematic probe vs the same wall (returned to -3); the
	# settled travel is a solver constant, the hit->miss edge the
	# signature.
	var probe := _mk_body(Vector3.ZERO, PhysicsServer3D.BODY_MODE_KINEMATIC)
	PhysicsServer3D.body_set_state(wall,
			PhysicsServer3D.BODY_STATE_TRANSFORM,
			Transform3D(Basis(), Vector3(0, 0, -3)))
	await _frames(SETTLE)
	var params := PhysicsTestMotionParameters3D.new()
	params.from = Transform3D(Basis(), Vector3.ZERO)
	params.motion = Vector3(0, 0, -10)
	var res := PhysicsTestMotionResult3D.new()
	var r0 := PhysicsServer3D.body_test_motion(probe, params, res)
	var t0: float = res.get_travel().z
	PhysicsServer3D.body_set_state(wall,
			PhysicsServer3D.BODY_STATE_TRANSFORM, Transform3D(Basis(), WALL_FAR))
	var res1 := PhysicsTestMotionResult3D.new()
	var r1 := PhysicsServer3D.body_test_motion(probe, params, res1)
	var t1: float = res1.get_travel().z
	await _frames(1)
	var res2 := PhysicsTestMotionResult3D.new()
	var r2 := PhysicsServer3D.body_test_motion(probe, params, res2)
	var t2: float = res2.get_travel().z
	prints("CHILD_NOTE %s_btm r0=%s t0=%.6f r1=%s t1=%.6f r2=%s t2=%.6f"
			% [prefix, str(r0), t0, str(r1), t1, str(r2), t2])
	cls = "unexpected"
	var btm_edge := r0 and not r1 and absf(t1 + 10.0) < 0.0001 \
			and not r2 and absf(t2 + 10.0) < 0.0001
	if btm_edge:
		if absf(t0 + 0.9765625) < 0.0001:
			cls = "same-signature"
		elif absf(t0 + 0.99853515625) < 0.0001:
			cls = "differs-constants"
	prints("CHILD_RESULT %s_btm=%s" % [prefix, cls])
	_cleanup_rids()

	# <prefix>_contact_stale: the two-tier discriminant; the contact count is
	# a solver constant, the stale->live pattern the signature.
	var floor_b := _mk_body(Vector3(0, -1, 0))
	var rig := _mk_body(Vector3(0, 8, 0), PhysicsServer3D.BODY_MODE_RIGID)
	PhysicsServer3D.body_set_param(rig,
			PhysicsServer3D.BODY_PARAM_GRAVITY_SCALE, 0.0)
	PhysicsServer3D.body_set_max_contacts_reported(rig, 8)
	await _frames(SETTLE)
	var set_c := _contacts(rig)
	var set_i := _floor_isect_hits(rig)
	PhysicsServer3D.body_set_state(rig,
			PhysicsServer3D.BODY_STATE_TRANSFORM,
			Transform3D(Basis(), Vector3(0, 0.5, 0)))
	var in_w0_c := _contacts(rig)
	var in_w0_i := _floor_isect_hits(rig)
	await _frames(1)
	var in_n1_c := _contacts(rig)
	PhysicsServer3D.body_set_state(rig,
			PhysicsServer3D.BODY_STATE_TRANSFORM,
			Transform3D(Basis(), Vector3(0, 8, 0)))
	var out_w0_c := _contacts(rig)
	await _frames(1)
	var out_n1_c := _contacts(rig)
	prints("CHILD_NOTE %s_contact_stale set=%d,%d in=%d,%d,%d out=%d,%d"
			% [prefix, set_c, set_i, in_w0_c, in_w0_i, in_n1_c, out_w0_c, out_n1_c])
	cls = "unexpected"
	var stale_pat := set_c == 0 and set_i == 1 and in_w0_c == 0 \
			and in_w0_i == 1 and in_n1_c > 0 and out_w0_c == in_n1_c \
			and out_n1_c == 0
	if stale_pat:
		cls = "same-signature" if in_n1_c == 4 else "differs-constants"
	prints("CHILD_RESULT %s_contact_stale=%s" % [prefix, cls])
	_cleanup_rids()

	# <prefix>_static_nopair: the known inverter. Under GodotPhysics the
	# teleported STATIC body stays silent (no pair, no signal) while the
	# area-move control fires at delta=1; under Jolt the same cell fires
	# at delta=1 (sig/ov at n1+, measured this round). sig_log is
	# cleared before the control so mv_delta reads fresh entries (the
	# r83 fold for critic C2's control-independence defect).
	var jarea := Area3D.new()
	var jashape := CollisionShape3D.new()
	var jabox := BoxShape3D.new()
	jabox.size = Vector3(4, 4, 4)
	jashape.shape = jabox
	jarea.add_child(jashape)
	jarea.collision_layer = 0
	jarea.collision_mask = 2
	jarea.monitoring = true
	jarea.body_entered.connect(func(_b):
		sig_log.append(Engine.get_physics_frames()))
	root.add_child(jarea)
	owned_nodes.append(jarea)
	var sshape := CollisionShape3D.new()
	var sbox := BoxShape3D.new()
	sbox.size = Vector3(1, 1, 1)
	sshape.shape = sbox
	var sbody := StaticBody3D.new()
	sbody.collision_layer = 2
	sbody.add_child(sshape)
	sbody.position = WALL_FAR
	root.add_child(sbody)
	owned_nodes.append(sbody)
	await _frames(SETTLE)
	var f_tp := Engine.get_physics_frames()
	sbody.position = Vector3.ZERO
	var tp := [sig_log.size(), jarea.get_overlapping_bodies().size()]
	await _frames(1)
	tp.append_array([sig_log.size(), jarea.get_overlapping_bodies().size()])
	await _frames(1)
	tp.append_array([sig_log.size(), jarea.get_overlapping_bodies().size()])
	await _frames(1)
	tp.append_array([sig_log.size(), jarea.get_overlapping_bodies().size()])
	var tp_delta: int = -1
	if sig_log.size() > 0:
		tp_delta = sig_log[0] - f_tp
	# control: move the area off then back on — fires on both backends.
	jarea.position = WALL_FAR
	await _frames(1)
	jarea.position = Vector3.ZERO
	sig_log.clear()
	var f_mv := Engine.get_physics_frames()
	await _frames(2)
	var mv_sig := sig_log.size()
	var mv_ov := jarea.get_overlapping_bodies().size()
	var mv_delta: int = -1
	if mv_sig > 0:
		mv_delta = sig_log[0] - f_mv
	prints("CHILD_NOTE %s_static_nopair tp=%d,%d,%d,%d,%d,%d,%d,%d delta=%d mv=%d,%d,%d"
			% [prefix, tp[0], tp[1], tp[2], tp[3], tp[4], tp[5], tp[6], tp[7],
			tp_delta, mv_sig, mv_ov, mv_delta])
	cls = "unexpected"
	var silent: bool = tp[0] == 0 and tp[1] == 0 and tp[6] == 0 and tp[7] == 0
	var fired: bool = tp[0] == 0 and tp[1] == 0 and tp[6] >= 1 and tp[7] == 1 \
			and tp_delta == 1
	if mv_sig > 0 and mv_delta == 1:
		if silent:
			cls = "same-signature"
		elif fired:
			cls = "inverts"
	prints("CHILD_RESULT %s_static_nopair=%s" % [prefix, cls])
	_quit_clean()


# --- r86: the backend tier sweep and the Dummy floor signature -------------
# Both bodies are spawned under more than one generated project, so a class
# difference can never be a code difference. Every read is Variant-typed and
# null-checked: an unguarded error inside the deferred _run coroutine is the
# hang class (the r86 deferred_hang arm), never a failure.


# The three-way backend gate. Exactly one member of the ClassDB trio exists
# per generated project on this build (measured r86: DEFAULT -> godot only,
# Jolt -> jolt only, Dummy -> dummy only). `_child_split` keeps its own
# frozen two-way expression: its receipts are pinned and it never runs under
# DEFAULT, so this is a different predicate, not a duplicate of it.
func _backend_name() -> String:
	if ClassDB.class_exists("PhysicsServer3DDummy"):
		return "Dummy"
	if ClassDB.class_exists("JoltPhysicsServer3D") \
			and not ClassDB.class_exists("GodotPhysicsServer3D"):
		return "Jolt Physics"
	if ClassDB.class_exists("GodotPhysicsServer3D"):
		return "DEFAULT"
	return "unexpected"


# --child --arm=tier_plain / tier_jolt / tier_dummy body (r86): the tier
# sweep. (a) area gravity + linear-damping override on a gravity_scale=1.0
# rigid body — the new inverter (GodotPhysics honours, Jolt ignores while
# the area parameter reads back, Dummy is the floor); (b) the shape-query
# `margin` — the mirror split (inert on GodotPhysics, honoured by Jolt,
# empty under Dummy); (c) the separation ray — the edge holds, the solver
# constants differ, Dummy has no data at all.
func _child_tier(prefix: String) -> void:
	wspace = root.get_world_3d().space
	prints("CHILD_RESULT %s_backend=%s" % [prefix, _backend_name()])
	dss = root.get_world_3d().direct_space_state
	if dss == null:
		# a non-threaded child grants this at _run; a refusal here would
		# read every arm blind, so retry bounded and then bail named
		for i in range(8):
			await physics_frame
			dss = root.get_world_3d().direct_space_state
			if dss != null:
				break
	if dss == null:
		prints("CHILD_NOTE %s dss_null=true" % prefix)
		_quit_clean(1)
		return
	prints("CHILD_RESULT %s_dss_class=%s" % [prefix, dss.get_class()])

	# (a) area override, measured on the body's own direct state
	var ashape := PhysicsServer3D.box_shape_create()
	PhysicsServer3D.shape_set_data(ashape, Vector3(40.0, 40.0, 40.0))
	var area := PhysicsServer3D.area_create()
	PhysicsServer3D.area_add_shape(area, ashape)
	PhysicsServer3D.area_set_collision_layer(area, 1)
	PhysicsServer3D.area_set_collision_mask(area, 1)
	PhysicsServer3D.area_set_space(area, wspace)
	PhysicsServer3D.area_set_transform(area, Transform3D(Basis(), Vector3.ZERO))
	owned.append_array([area, ashape])
	var rig := _mk_body(Vector3.ZERO, PhysicsServer3D.BODY_MODE_RIGID)
	await _frames(3)
	var b0 = PhysicsServer3D.body_get_direct_state(rig)
	var base_g := Vector3.ZERO
	var base_d := -1.0
	if b0 != null:
		base_g = b0.get_total_gravity()
		base_d = b0.get_total_linear_damp()
	PhysicsServer3D.area_set_param(area,
			PhysicsServer3D.AREA_PARAM_GRAVITY_OVERRIDE_MODE, 3)
	PhysicsServer3D.area_set_param(area, PhysicsServer3D.AREA_PARAM_GRAVITY, 20.0)
	PhysicsServer3D.area_set_param(area, PhysicsServer3D.AREA_PARAM_GRAVITY_VECTOR,
			Vector3(0, 1, 0))
	PhysicsServer3D.area_set_param(area,
			PhysicsServer3D.AREA_PARAM_LINEAR_DAMP_OVERRIDE_MODE, 3)
	PhysicsServer3D.area_set_param(area, PhysicsServer3D.AREA_PARAM_LINEAR_DAMP, 2.0)
	await _frames(2)
	var b1 = PhysicsServer3D.body_get_direct_state(rig)
	var ov_g := Vector3.ZERO
	var ov_d := -1.0
	if b1 != null:
		ov_g = b1.get_total_gravity()
		ov_d = b1.get_total_linear_damp()
	var area_g = PhysicsServer3D.area_get_param(area,
			PhysicsServer3D.AREA_PARAM_GRAVITY)
	prints("CHILD_NOTE %s_area base=%s/%.6f override=%s/%.6f area_readback=%s" % [
			prefix, str(base_g), base_d, str(ov_g), ov_d, str(area_g)])
	var cls := "unexpected"
	if ov_g.is_equal_approx(Vector3(0, 20, 0)) and absf(ov_d - 2.0) < 0.0001:
		cls = "honors"
	elif base_g.is_equal_approx(Vector3(0, -9.8, 0)) \
			and absf(base_d - 0.1) < 0.0001 \
			and ov_g.is_equal_approx(base_g) and absf(ov_d - base_d) < 0.0001 \
			and area_g != null and absf(float(area_g) - 20.0) < 0.0001:
		cls = "ignores"
	elif ov_g.is_equal_approx(Vector3.ZERO) and absf(ov_d) < 0.0001 \
			and area_g == null:
		cls = "floor"
	prints("CHILD_RESULT %s_area_override=%s" % [prefix, cls])

	# (b) shape-query margin on the `cast` arm's geometry (wall face z=-2)
	var wall := _mk_body(Vector3(0, 0, -3))
	await _frames(SETTLE)
	var casts := []
	for m in [0.0, 0.04, 0.5]:
		var s := SphereShape3D.new()
		s.radius = 0.5
		var p := PhysicsShapeQueryParameters3D.new()
		p.shape = s
		p.transform = Transform3D(Basis(), Vector3.ZERO)
		p.motion = Vector3(0, 0, -10)
		p.collision_mask = 1
		p.collide_with_bodies = true
		p.margin = m
		casts.append(dss.cast_motion(p))
	prints("CHILD_NOTE %s_margin m0=%s m004=%s m05=%s" % [
			prefix, str(casts[0]), str(casts[1]), str(casts[2])])
	cls = "unexpected"
	if casts[0].size() == 0 and casts[1].size() == 0 and casts[2].size() == 0:
		cls = "empty"
	elif casts[0].size() >= 2 and casts[1].size() >= 2 and casts[2].size() >= 2:
		var same01 := absf(casts[0][0] - casts[1][0]) < 0.0001
		var same12 := absf(casts[1][0] - casts[2][0]) < 0.0001
		if same01 and same12:
			cls = "inert"
		elif not same01 and not same12 and casts[0][0] > casts[1][0] \
				and casts[1][0] > casts[2][0]:
			cls = "binds"
	prints("CHILD_RESULT %s_margin=%s" % [prefix, cls])

	# (c) separation ray: the data form and the solver constants
	var sep: RID = PhysicsServer3D.separation_ray_shape_create()
	PhysicsServer3D.shape_set_data(sep, {"length": 2.0, "slide_on_slope": false})
	owned.append(sep)
	var sep_data = PhysicsServer3D.shape_get_data(sep)
	var sep_type := PhysicsServer3D.shape_get_type(sep)
	var sr := PhysicsShapeQueryParameters3D.new()
	sr.shape_rid = sep
	sr.transform = Transform3D(Basis(), Vector3.ZERO)
	sr.motion = Vector3(0, 0, -10)
	sr.collision_mask = 1
	sr.collide_with_bodies = true
	var sep_cast := dss.cast_motion(sr)
	prints("CHILD_NOTE %s_sepray data=%s type=%d cast=%s" % [
			prefix, str(sep_data), sep_type, str(sep_cast)])
	cls = "unexpected"
	if sep_data == null:
		cls = "floor"
	elif sep_cast.size() >= 2:
		if absf(sep_cast[0] - 0.197265625) < 0.0001:
			cls = "same-signature"
		elif absf(sep_cast[0] - 0.1998291015625) < 0.0001:
			cls = "differs-constants"
	prints("CHILD_RESULT %s_sepray=%s" % [prefix, cls])
	_quit_clean()


# --child --arm=floor_dummy / floor_real body (r86): the Dummy silent floor
# as an 11-token signature, with the identical body under a real backend as
# the refusal contrast. Tokens are printed, never inferred. Two calls in
# here are loud refusals on a real backend and silent no-ops under Dummy —
# that pair is the whole class distinction, so "silent floor" can never be
# read as "refusal".
func _child_floor(prefix: String) -> void:
	wspace = root.get_world_3d().space
	prints("CHILD_RESULT %s_backend=%s" % [prefix, _backend_name()])
	var shape: RID = PhysicsServer3D.box_shape_create()
	PhysicsServer3D.shape_set_data(shape, Vector3(1.0, 1.0, 1.0))
	var shape_data = PhysicsServer3D.shape_get_data(shape)
	var shape_type := PhysicsServer3D.shape_get_type(shape)
	var fresh: RID = PhysicsServer3D.space_create()
	var space_param = PhysicsServer3D.space_get_param(fresh,
			PhysicsServer3D.SPACE_PARAM_SOLVER_ITERATIONS)
	var dss_rid0 = PhysicsServer3D.space_get_direct_state(RID())
	var rig := _mk_body(Vector3(0, 5, 0), PhysicsServer3D.BODY_MODE_RIGID)
	var area: RID = PhysicsServer3D.area_create()
	PhysicsServer3D.area_set_space(area, wspace)
	PhysicsServer3D.area_add_shape(area, shape)
	owned.append_array([shape, fresh, area])
	await _frames(2)
	var b_state = PhysicsServer3D.body_get_state(rig,
			PhysicsServer3D.BODY_STATE_TRANSFORM)
	var b_param = PhysicsServer3D.body_get_param(rig,
			PhysicsServer3D.BODY_PARAM_GRAVITY_SCALE)
	var b_count := PhysicsServer3D.body_get_shape_count(rig)
	var b_shape = PhysicsServer3D.body_get_shape(rig, 0)
	var a_param = PhysicsServer3D.area_get_param(area,
			PhysicsServer3D.AREA_PARAM_GRAVITY)
	# the two loud refusals on a real backend, silent no-ops here
	PhysicsServer3D.free_rid(RID())
	var tokens := PackedStringArray([
		"rid0" if str(shape) == "RID(0)" else "rid",
		"nil" if shape_data == null else "v3",
		str(shape_type),
		"rid0" if str(fresh) == "RID(0)" else "rid",
		("nil" if space_param == null else
				("zero" if float(space_param) == 0.0 else "pos")),
		"dummy" if dss_rid0 != null else "nil",
		"nil" if b_state == null else "xform",
		"nil" if b_param == null else "value",
		str(b_count),
		"rid0" if str(b_shape) == "RID(0)" else "rid",
		"nil" if a_param == null else "value",
	])
	prints("CHILD_NOTE %s_floor tokens=%s" % [prefix, str(tokens)])
	# r86 critic A5: solver_iterations is a TUNEABLE project default — pin
	# the zero-vs-positive axis (Dummy floor = 0.0, real backend = whatever
	# positive default/tuning), not the engine's literal 16.0, or a host
	# with solver_iterations=8 fails as "refusal drift".
	var floor_sig := PackedStringArray(["rid0", "nil", "2", "rid0", "zero",
			"dummy", "nil", "nil", "0", "rid0", "nil"])
	var real_sig := PackedStringArray(["rid", "v3", "3", "rid", "pos",
			"nil", "xform", "value", "1", "rid", "value"])
	var cls := "unexpected"
	if tokens == floor_sig:
		cls = "silent-floor"
	elif tokens == real_sig:
		cls = "real-values"
	prints("CHILD_RESULT %s_floor=%s" % [prefix, cls])
	_quit_clean()


# --- r87: the body-tier deferred-state arms ---------------------------------
# Six arms over the PhysicsDirectBodyState3D tier, every one of them a
# generated-project CHILD: the laws are backend-scoped, and the crash class
# must kill a child process, never the fixture. All reads are Variant-typed
# and null-checked — an unguarded deref inside a deferred coroutine is the
# r86 hang class, never a failure (and the Dummy backend returns Nil for
# reads a real backend answers, so the guard is load-bearing there too).


# The RigidBody3D the identity law needs: the callback receives the engine's
# own handle, and the law is that a fresh fetch inside the callback returns
# the SAME object.
class BHBody extends RigidBody3D:
	var fired := false
	var same_obj := false
	var state_obj: Variant = null

	func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
		if fired:
			return
		fired = true
		same_obj = PhysicsServer3D.body_get_direct_state(get_rid()) == state
		state_obj = state


# --child --arm=bh_plain / bh_jolt / bh_dummy (r87): the held-handle identity
# law. (1) inside RigidBody3D._integrate_forces the fresh fetch IS the handle
# the callback was handed; (2) body_set_state_sync_callback sees the same
# object every tick; (3) a handle obtained once survives detach
# (body_set_space(RID()) -> refetch nil, the held handle still reads the last
# transform) and reattach (refetch == the held handle); (4) get_space_state()
# on the handle is the SAME object as space_get_direct_state and
# World3D.direct_space_state. Dummy is the floor: neither callback ever fires
# and the fetch answers for a detached RID, so the law is real-backend-only
# and a Dummy child can never witness it (scout directive 8).
func _child_bh_identity(prefix: String) -> void:
	wspace = root.get_world_3d().space
	var rb := BHBody.new()
	var cs := CollisionShape3D.new()
	var bx := BoxShape3D.new()
	bx.size = Vector3(1, 1, 1)
	cs.shape = bx
	rb.add_child(cs)
	rb.gravity_scale = 0.0
	rb.position = Vector3(0, 4, 0)
	root.add_child(rb)
	owned_nodes.append(rb)
	await _frames(6)
	var if_held: Variant = rb.state_obj
	var if_refetch := false
	if if_held != null:
		if_refetch = PhysicsServer3D.body_get_direct_state(rb.get_rid()) == if_held
	var srig := _mk_body(Vector3(0, 12, 0), PhysicsServer3D.BODY_MODE_RIGID)
	PhysicsServer3D.body_set_param(srig,
			PhysicsServer3D.BODY_PARAM_GRAVITY_SCALE, 0.0)
	await _frames(2)
	var held: Variant = PhysicsServer3D.body_get_direct_state(srig)
	var ss := {"fired": 0, "same": 0}
	PhysicsServer3D.body_set_state_sync_callback(srig, func(st):
		ss["fired"] += 1
		if PhysicsServer3D.body_get_direct_state(srig) == st:
			ss["same"] += 1)
	await _frames(4)
	var detach_nil := false
	var held_live := false
	var reattach_same := false
	var twin := false
	if held != null:
		var t_before: Transform3D = held.get_transform()
		PhysicsServer3D.body_set_space(srig, RID())
		detach_nil = PhysicsServer3D.body_get_direct_state(srig) == null
		# a detached body does not step, so the held handle must still read
		# the SAME transform it read before the detach. r87 critic F5
		# caveat: this is a FROZEN-READ witness — a zombie handle serving
		# stale state satisfies it — not a liveness proof; the fs arm is
		# the row that probes read-past-lifetime.
		held_live = held.get_transform() == t_before
		PhysicsServer3D.body_set_space(srig, wspace)
		await _frames(1)
		reattach_same = PhysicsServer3D.body_get_direct_state(srig) == held
		var sp: Variant = held.get_space_state()
		twin = sp == PhysicsServer3D.space_get_direct_state(wspace) \
				and sp == root.get_world_3d().direct_space_state
	_note(prefix, "if_fired=%s if_same=%s if_refetch=%s ss=%d/%d detach_nil=%s held_live=%s reattach_same=%s twin=%s" % [str(rb.fired), str(rb.same_obj), str(if_refetch), ss["fired"], ss["same"], str(detach_nil), str(held_live), str(reattach_same), str(twin)])
	_emit(prefix, "backend", str(_backend_name()))
	_emit(prefix, "if_same", str(rb.same_obj and if_refetch))
	_emit(prefix, "ss_same", str(ss["fired"] > 0 and ss["fired"] == ss["same"]))
	# r87 critic F5: `ss_same` alone never saw the fired count — a backend
	# whose callbacks fire with a DIFFERENT object still reads ss_same=false,
	# so `dummy_cb=never` needed the count itself. Bucketed (0 vs >0): the
	# real-backend count is scheduling-dependent, the floor's is not.
	_emit(prefix, "ss_fired", "0" if ss["fired"] == 0 else ">0")
	_emit(prefix, "detach", str("nil" if detach_nil else "obj"))
	_emit(prefix, "held_live", str(held_live))
	_emit(prefix, "reattach", str(reattach_same))
	_emit(prefix, "twin", str(twin))
	_quit_clean()


# --child --arm=au_plain / au_jolt (r87): acquisition vs use. A handle is
# acquired at a legal (physics-frame) position, then exercised at BODY_REPS
# process-frame positions where a FRESH fetch is refused: the held handle's
# read is compared against the server read at the same instant, its write is
# read back through itself (same turn) and through the server at the next
# in-phase position (persistence). The refused fetch is the arm's expected
# witness class, so the parent spawns this child with allow_lines.
func _child_acq_use(prefix: String) -> void:
	wspace = root.get_world_3d().space
	var rig := _mk_body(Vector3(0, 8, 0), PhysicsServer3D.BODY_MODE_RIGID)
	PhysicsServer3D.body_set_param(rig,
			PhysicsServer3D.BODY_PARAM_GRAVITY_SCALE, 0.0)
	var held: Variant = null
	for i in range(24):
		await physics_frame
		held = PhysicsServer3D.body_get_direct_state(rig)
		if held != null:
			break
	if held == null:
		_note(prefix, "held=nil")
		_quit_clean(1)
		return
	var out_of_phase := 0
	var refused := 0
	var live := 0
	var same_turn := 0
	var persist := 0
	for i in range(BODY_REPS):
		await process_frame
		if not Engine.is_in_physics_frame():
			out_of_phase += 1
		if PhysicsServer3D.body_get_direct_state(rig) == null:
			refused += 1
		var srv_lv: Variant = PhysicsServer3D.body_get_state(rig,
				PhysicsServer3D.BODY_STATE_LINEAR_VELOCITY)
		if srv_lv != null and Vector3(srv_lv) == held.get_linear_velocity():
			live += 1
		held.set_linear_velocity(Vector3(0, 20.0 + i, 0))
		if absf(held.get_linear_velocity().y - (20.0 + i)) < 0.0001:
			same_turn += 1
		held.set_transform(Transform3D(Basis(), Vector3(0, 30.0 + i, 0)))
		await physics_frame
		var srv_t: Variant = PhysicsServer3D.body_get_state(rig,
				PhysicsServer3D.BODY_STATE_TRANSFORM)
		if srv_t is Transform3D \
				and absf(srv_t.origin.y - (30.0 + i)) < 0.0001:
			persist += 1
	_note(prefix, "reps=%d out_of_phase=%d refused=%d live=%d same_turn=%d persist=%d" % [BODY_REPS, out_of_phase, refused, live, same_turn, persist])
	_emit(prefix, "backend", str(_backend_name()))
	_emit(prefix, "gate", str("refused" if refused == BODY_REPS else "granted"))
	_emit(prefix, "use", str("ungated" if live == BODY_REPS and same_turn == BODY_REPS
					and persist == BODY_REPS else "gated"))
	_emit(prefix, "out_of_phase", "%d" % [out_of_phase])
	_quit_clean()


# --child --arm=ss_plain / ss_jolt (r87): the object's own flush seams.
# The PRE reads happen in this deferred child dispatch, before the first solve
# completes (the r86/r87 phase map's position B), and the POST reads after the
# body has fallen into contact. get_step is step-stamped on both real
# backends; gravity/damp only on GodotPhysics. The contact buffer is last-step
# data and needs body_set_max_contacts_reported > 0 to report anything.
func _child_step_stamp(prefix: String) -> void:
	wspace = root.get_world_3d().space
	var floor_b := _mk_body(Vector3(0, -1, 0))
	var rig := _mk_body(Vector3(0, 2.2, 0), PhysicsServer3D.BODY_MODE_RIGID)
	PhysicsServer3D.body_set_state(rig,
			PhysicsServer3D.BODY_STATE_CAN_SLEEP, false)
	var s0: Variant = PhysicsServer3D.body_get_direct_state(rig)
	var pre_step := -1.0
	var pre_grav := "absent"
	var pre_damp := -1.0
	if s0 != null:
		pre_step = s0.get_step()
		pre_grav = "zero" if s0.get_total_gravity().is_equal_approx(
				Vector3.ZERO) else "real"
		pre_damp = s0.get_total_linear_damp()
	# default max_contacts_reported is 0: a body resting on the floor reports
	# NO contacts at all until it opts in
	await _frames(90)
	var s1: Variant = PhysicsServer3D.body_get_direct_state(rig)
	var cc_off: int = s1.get_contact_count() if s1 != null else -1
	PhysicsServer3D.body_set_max_contacts_reported(rig, 8)
	await _frames(2)
	var s2: Variant = PhysicsServer3D.body_get_direct_state(rig)
	var cc_on: int = s2.get_contact_count() if s2 != null else -1
	var post_step := -1.0
	var post_damp := -1.0
	var stale_w0 := -1
	var stale_n1 := -1
	if s2 != null:
		post_step = s2.get_step()
		post_damp = s2.get_total_linear_damp()
		# last-step data: teleport out of contact -> the count still reads
		# the last step's value, and clears only on the next step
		PhysicsServer3D.body_set_state(rig,
				PhysicsServer3D.BODY_STATE_TRANSFORM,
				Transform3D(Basis(), Vector3(0, 8, 0)))
		stale_w0 = s2.get_contact_count()
		await _frames(1)
		stale_n1 = s2.get_contact_count()
	_note(prefix, "pre=%s/%s/%s off=%d on=%d post=%s/%s stale=%d,%d" % [str(pre_step), pre_grav, str(pre_damp), cc_off, cc_on, str(post_step), str(post_damp), stale_w0, stale_n1])
	_emit(prefix, "backend", str(_backend_name()))
	_emit(prefix, "step_pre", str(pre_step))
	_emit(prefix, "grav_pre", str(pre_grav))
	_emit(prefix, "damp_pre", str(pre_damp))
	_emit(prefix, "step_post", str(post_step))
	_emit(prefix, "damp_post", str(post_damp))
	_emit(prefix, "cc_off", "%d" % [cc_off])
	_emit(prefix, "cc_on", "%d" % [cc_on])
	_emit(prefix, "last_step", "%d,%d" % [stale_w0, stale_n1])
	_quit_clean()


# --child --arm=wl_plain (r87): the out-of-phase held-handle write, as a
# BOUNDED repeated observation. Each rep re-arms the body in phase (awake,
# moving), issues set_sleep_state(true) through the held handle at a
# process-frame position where a fresh fetch is refused, reads the handle back
# same-turn (was the write applied at all?) and reads the server at the next
# in-phase position (did it survive the step?). landed/lost are the tally the
# parent accounts; the split is evidence, never a pinned per-rep outcome —
# the write path is unsynchronized, so the class is a race class.
func _child_write_loss(prefix: String) -> void:
	wspace = root.get_world_3d().space
	var rig := _mk_body(Vector3(0, 8, 0), PhysicsServer3D.BODY_MODE_RIGID)
	PhysicsServer3D.body_set_param(rig,
			PhysicsServer3D.BODY_PARAM_GRAVITY_SCALE, 0.0)
	PhysicsServer3D.body_set_state(rig,
			PhysicsServer3D.BODY_STATE_CAN_SLEEP, false)
	var held: Variant = null
	for i in range(24):
		await physics_frame
		held = PhysicsServer3D.body_get_direct_state(rig)
		if held != null:
			break
	if held == null:
		_note(prefix, "held=nil")
		_quit_clean(1)
		return
	var refused := 0
	var same_turn := 0
	var landed := 0
	var lost := 0
	var rows := []
	for i in range(BODY_REPS):
		await physics_frame
		held.set_sleep_state(false)
		held.set_linear_velocity(Vector3(0, 5, 0))
		await physics_frame
		await process_frame
		if PhysicsServer3D.body_get_direct_state(rig) == null:
			refused += 1
		held.set_sleep_state(true)
		var same: bool = held.is_sleeping()
		if same:
			same_turn += 1
		await physics_frame
		var srv: Variant = PhysicsServer3D.body_get_state(rig,
				PhysicsServer3D.BODY_STATE_SLEEPING)
		if srv == true:
			landed += 1
		else:
			lost += 1
		rows.append("%d:%s>%s" % [i, "T" if same else "F", str(srv)])
	_note(prefix, "reps=%d refused=%d same_turn=%d landed=%d lost=%d rows=%s" % [BODY_REPS, refused, same_turn, landed, lost, str(rows)])
	_emit(prefix, "backend", str(_backend_name()))
	_emit(prefix, "gate", str("refused" if refused == BODY_REPS else "granted"))
	_emit(prefix, "same_turn", "%d" % [same_turn])
	_emit(prefix, "landed", "%d" % [landed])
	_emit(prefix, "lost", "%d" % [lost])
	_quit_clean()


# --child --arm=bt_plain / bt_jolt / bt_dummy (r87): the backend split at the
# body tier. The impulse cell is read at the FIRST in-contact step in the
# r87-scout-dss `mm_*` geometry (floor at y=0, rigid at 2.2): on GodotPhysics
# that step reads exactly (0,0,0) and on Jolt the real impact impulse. The
# same field OSCILLATES through zero on GodotPhysics at later steps in other
# geometries (measured: a 40-frame series with the floor at y=-1 reads
# (0,0,0) at two steps and up to 0.103 at others), so the row claims the
# first-in-contact-step split only — never "GodotPhysics is always zero".
func _child_body_tier(prefix: String) -> void:
	wspace = root.get_world_3d().space
	var floor_b := _mk_body(Vector3(0, 0, 0))
	var rig := _mk_body(Vector3(0, 2.2, 0), PhysicsServer3D.BODY_MODE_RIGID)
	PhysicsServer3D.body_set_max_contacts_reported(rig, 8)
	PhysicsServer3D.body_set_state(rig,
			PhysicsServer3D.BODY_STATE_CAN_SLEEP, false)
	var st: Variant = null
	var first_i := -1
	for i in range(60):
		await physics_frame
		st = PhysicsServer3D.body_get_direct_state(rig)
		if st != null and st.get_contact_count() > 0:
			first_i = i
			break
	var cc := -1
	var impulse := "nil"
	var impulse_raw := "-"
	var lshape_oob := "absent"
	var sleep_lv := "absent"
	if st != null:
		cc = st.get_contact_count()
		if cc > 0:
			var imp: Vector3 = st.get_contact_impulse(0)
			impulse_raw = "%.9f,%.9f,%.9f" % [imp.x, imp.y, imp.z]
			impulse = "zero" if imp.length() < 0.000001 else "real"
			lshape_oob = str(st.get_contact_local_shape(cc + 5))
		st.set_linear_velocity(Vector3(0, 44.0, 0))
		var kept: float = st.get_linear_velocity().y
		st.set_sleep_state(true)
		var after: float = st.get_linear_velocity().y
		# `flat` is the Dummy floor: the value never moved, so there was
		# nothing to keep or zero (a zero-vs-zero read must not earn the
		# real-backend "kept" token)
		if absf(kept) < 0.0001 and absf(after) < 0.0001:
			sleep_lv = "flat"
		elif absf(after - kept) < 0.0001:
			sleep_lv = "kept"
		else:
			sleep_lv = "zeroed"
	# detached-body impulse write: silent no-op on GodotPhysics, a LOUD
	# refusal on Jolt (the parent counts the engine's line in the raw log)
	var rig2 := _mk_body(Vector3(20, 8, 0), PhysicsServer3D.BODY_MODE_RIGID)
	PhysicsServer3D.body_set_param(rig2,
			PhysicsServer3D.BODY_PARAM_GRAVITY_SCALE, 0.0)
	await _frames(1)
	var held2: Variant = PhysicsServer3D.body_get_direct_state(rig2)
	PhysicsServer3D.body_set_space(rig2, RID())
	if held2 != null:
		held2.apply_central_impulse(Vector3(0, 1, 0))
	PhysicsServer3D.body_set_space(rig2, wspace)
	_note(prefix, "first_i=%d cc=%d impulse=%s lshape_oob=%s sleep_lv=%s detach_write=done" % [first_i, cc, impulse_raw, lshape_oob, sleep_lv])
	_emit(prefix, "backend", str(_backend_name()))
	_emit(prefix, "cc", "%d" % [cc])
	_emit(prefix, "impulse", str(impulse))
	_emit(prefix, "lshape_oob", str(lshape_oob))
	_emit(prefix, "sleep_lv", str(sleep_lv))
	_quit_clean()


# --child --arm=fs_plain / fs_jolt / fs_dummy (r87): the freed-SPACE crash
# cell, and the last thing this file does — a crash cannot be caught, so the
# child dies and the parent pins the log envelope. The body handle is
# fetched first (the crash is not the body handle: freed BODY handles degrade
# to silent nulls), then the world space is free_rid'd, then the space-state
# object reached THROUGH the body handle is queried. On this host the crash
# site is backend-specific: GodotPhysics dies inside `held.get_space_state()`
# below (the `space=` note never prints), Jolt survives that call and dies at
# `sp.intersect_ray`. Jolt's crash mode is heap-layout dependent (uncaught
# std::system_error or the same handler), Dummy answers an empty dict and
# exits 0.
func _child_freed_space(prefix: String) -> void:
	wspace = root.get_world_3d().space
	var rig := _mk_body(Vector3(0, 8, 0), PhysicsServer3D.BODY_MODE_RIGID)
	PhysicsServer3D.body_set_param(rig,
			PhysicsServer3D.BODY_PARAM_GRAVITY_SCALE, 0.0)
	await _frames(2)
	var held: Variant = PhysicsServer3D.body_get_direct_state(rig)
	_note(prefix, "held=%s" % ["nil" if held == null else held.get_class()])
	PhysicsServer3D.free_rid(wspace)
	var sp: Variant = held.get_space_state() if held != null else null
	_note(prefix, "space=%s" % ["nil" if sp == null else str(sp)])
	if sp != null and sp is PhysicsDirectSpaceState3D:
		var q := PhysicsRayQueryParameters3D.create(
				Vector3(0, 10, 0), Vector3(0, -10, 0))
		var hit: Variant = sp.intersect_ray(q)
		_note(prefix, "ray_empty=%s" % [str(hit.is_empty())])
		_emit(prefix, "ray", str("empty" if hit.is_empty() else "hits"))
		_quit_clean()
		return
	_emit(prefix, "ray", "nospace")
	_quit_clean()


# r87 simplifier: one BLOCKED gate for every arm (the r86 SP2 shape at the
# other repeated exit). The engine hint is reported verbatim in the gate's own
# line; the caller returns, so an absent backend can never fall through into a
# fabricated split.
func _gate(engine: String, arm: String, token: String) -> bool:
	if _engine_hint_has(engine):
		return false
	_quit_clean(1, "BLOCKED phys3d_events %s %s_absent=true" % [arm, token])
	return true


# r87 simplifier: one emitter for every child verdict/note line, so the
# "CHILD_RESULT <prefix>_<key>=<value>" / "CHILD_NOTE <prefix> <text>" shapes
# exist once (the r86 SP1 rule: no second convention). Text-identical: the
# same format string with the same args is formatted by the same `prints`
# call inside the helper.
func _emit(prefix: String, key: String, value: String) -> void:
	prints("CHILD_RESULT %s_%s=%s" % [prefix, key, value])


func _note(prefix: String, text: String) -> void:
	prints("CHILD_NOTE %s %s" % [prefix, text])
