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
func _spawn_child(dirname: String, project_body: String, arm: String,
		allow_inaccessible: bool, script_res := "res://phys3d_events.gd",
		bound_s := 30) -> Dictionary:
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
		elif line.begins_with("ERROR:") and (
				not allow_inaccessible
				or "Space state is inaccessible" not in line):
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
			if not _engine_hint_has("Jolt Physics"):
				_quit_clean(1, "BLOCKED phys3d_events jolt_edge jolt_absent=true")
				return
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
			if not _engine_hint_has("Jolt Physics"):
				_quit_clean(1, "BLOCKED phys3d_events jolt_threaded jolt_absent=true")
				return
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
			if not _engine_hint_has("Dummy"):
				_quit_clean(1, "BLOCKED phys3d_events dummy_refused dummy_absent=true")
				return
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
			if not _engine_hint_has("Jolt Physics"):
				_quit_clean(1, "BLOCKED phys3d_events backend_tier jolt_absent=true")
				return
			if not _engine_hint_has("Dummy"):
				_quit_clean(1, "BLOCKED phys3d_events backend_tier dummy_absent=true")
				return
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
			if not _engine_hint_has("Dummy"):
				_quit_clean(1, "BLOCKED phys3d_events dummy_floor dummy_absent=true")
				return
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
