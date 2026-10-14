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
#
# Reproduce one arm:
#   godot --headless --path <scratch> --script res://phys3d_events.gd -- --arm=isect
extends SceneTree

const SETTLE := 4
const WALL_FAR := Vector3(0, 0, -30)

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
	_cleanup_nodes()
	_cleanup_rids()
	quit(1)
	return true


func _exit_ok(marker: String) -> void:
	_cleanup_nodes()
	_cleanup_rids()
	print(marker)
	quit(0)


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
	# parent under a generated run_on_separate_thread=true project, and by
	# the jolt_edge parent under a generated physics_engine="Jolt
	# Physics" project (the --arm selects which child body runs).
	if "--child" in OS.get_cmdline_user_args():
		# r84 critic: the child dispatch must be total -- a bare or
		# unknown --arm used to run the threaded body silently. The
		# threaded parent passes --arm=threaded_edge explicitly.
		match _argval("--arm=", ""):
			"jolt_edge":
				await _child_jolt()
			"threaded_edge":
				await _child_threaded()
			var bad:
				prints("CHILD_RESULT child_arm=unknown arm='%s'" % bad)
				quit(2)
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
			_cleanup_nodes()
			_cleanup_rids()
			print("NEGATIVE REJECTED: phys3d_events static_nopair static_tp_fired=false ticks=3 area_move_delta=1")
			quit(2)

		"threaded_edge":
			# conversion cell: same queries under run_on_separate_thread=true.
			# The parent writes a threaded project under res://thrproj and
			# re-execs this script with --child through /bin/sh so the child's
			# stdout+stderr land in a log file (OS.execute's output array only
			# captured the startup banner on this build — measured hazard);
			# the child's ERROR diagnostics can then never reach the case
			# stream, and the log doubles as evidence.
			var thrdir := ProjectSettings.globalize_path("res://thrproj")
			var mk := DirAccess.make_dir_recursive_absolute(thrdir)
			if mk != OK:
				return _fail("threaded_edge cannot make thrproj err=%d" % mk)
			var f := FileAccess.open(thrdir.path_join("project.godot"), FileAccess.WRITE)
			if f == null:
				return _fail("threaded_edge cannot write child project")
			f.store_string("[application]\n\nconfig/name=\"ThrChild\"\n\n[physics]\n\ncommon/physics_ticks_per_second=60\n3d/run_on_separate_thread=true\n")
			f.close()
			var selfpath := ProjectSettings.globalize_path("res://phys3d_events.gd")
			var logpath := thrdir.path_join("child.log")
			# `timeout -s KILL` bounds the child: without it a hung child
			# survives the battery's kill of the direct /bin/sh parent and
			# is orphaned (reviewer F2). 30 s covers the ~2 s healthy run.
			var cmd := ("timeout -s KILL 30 \"%s\" --headless --path \"%s\" --script \"%s\""
					+ " -- --child --arm=threaded_edge > \"%s\" 2>&1") % [
					OS.get_executable_path(), thrdir, selfpath, logpath]
			# r84 critic: child.log is a never-unlinked single slot -- a
			# stale log from a prior run would forge a verdict map, so
			# remove it before spawn (missing-after-spawn stays _fail).
			DirAccess.remove_absolute(logpath)
			var code := OS.execute("/bin/sh", ["-c", cmd], [], false)
			var verdict := ""
			var script_err := false
			var lf := FileAccess.open(logpath, FileAccess.READ)
			if lf != null:
				while not lf.eof_reached():
					var line := lf.get_line()
					if line.begins_with("CHILD_RESULT "):
						verdict = line
					elif "SCRIPT ERROR" in line or "Parse Error" in line:
						script_err = true
					elif ("ObjectDB" in line and "leaked" in line):
						# ObjectDB-only leaks print as WARNING, not ERROR
						# (r84 reviewer F1): mirror the battery classifier's
						# LEAKED_OBJECTDB arm into the parent scan.
						script_err = true
					elif (line.begins_with("ERROR:")
							and "Space state is inaccessible" not in line):
						# the refusal-class ERRORs are the expected witness;
						# any other engine ERROR is a defect (reviewer F4)
						script_err = true
				lf.close()
			else:
				return _fail("threaded_edge child log missing")
			var expect := ("CHILD_RESULT pp_edge0=true "
					+ "proc_dss_refused=true srv_ok=true")
			if code != 0 or script_err or verdict != expect:
				return _fail("threaded_edge child mismatch exit=%d serr=%s verdict='%s'"
						% [code, str(script_err), verdict])
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
			# threaded_edge thrproj pattern -> joltproj) and pin the
			# per-arm split {same-signature | differs-constants |
			# inverts}. static_nopair is the known inverter (r83 critic
			# C2: under Jolt the teleported static body pairs and fires).
			# Gate first: if this build's engine hint lacks "Jolt
			# Physics" the row reports BLOCKED, never a fabricated split.
			var jolt_avail := false
			for prop in ProjectSettings.get_property_list():
				if prop.name == "physics/3d/physics_engine":
					jolt_avail = "Jolt Physics" in prop.hint_string
			if not jolt_avail:
				_cleanup_nodes()
				_cleanup_rids()
				print("BLOCKED phys3d_events jolt_edge jolt_absent=true")
				quit(1)
				return
			var joltdir := ProjectSettings.globalize_path("res://joltproj")
			var mk := DirAccess.make_dir_recursive_absolute(joltdir)
			if mk != OK:
				return _fail("jolt_edge cannot make joltproj err=%d" % mk)
			var jf := FileAccess.open(joltdir.path_join("project.godot"),
					FileAccess.WRITE)
			if jf == null:
				return _fail("jolt_edge cannot write child project")
			jf.store_string("[application]\n\nconfig/name=\"JoltChild\"\n\n[physics]\n\ncommon/physics_ticks_per_second=60\n3d/physics_engine=\"Jolt Physics\"\n")
			jf.close()
			var selfpath := ProjectSettings.globalize_path("res://phys3d_events.gd")
			var logpath := joltdir.path_join("child.log")
			# `timeout -s KILL` bounds the child exactly like
			# threaded_edge (r83 reviewer F2); stdout+stderr are
			# file-redirected so child diagnostics never reach the case
			# stream (the OS.execute output-array hazard, r83 author).
			var cmd := ("timeout -s KILL 30 \"%s\" --headless --path \"%s\""
					+ " --script \"%s\" -- --child --arm=jolt_edge"
					+ " > \"%s\" 2>&1") % [
					OS.get_executable_path(), joltdir, selfpath, logpath]
			DirAccess.remove_absolute(logpath)  # stale-slot guard (r84 critic)
			var code := OS.execute("/bin/sh", ["-c", cmd], [], false)
			var verdicts := {}
			var script_err := false
			var lf := FileAccess.open(logpath, FileAccess.READ)
			if lf != null:
				while not lf.eof_reached():
					var line := lf.get_line()
					if line.begins_with("CHILD_RESULT "):
						var kv := line.substr(13).split("=", true, 1)
						if kv.size() == 2:
							verdicts[kv[0]] = kv[1]
					elif "SCRIPT ERROR" in line or "Parse Error" in line:
						script_err = true
					elif ("ObjectDB" in line and "leaked" in line):
						# WARNING-class ObjectDB leak (r84 reviewer F1) --
						# not an ERROR line, mirrors LEAKED_OBJECTDB
						script_err = true
					elif line.begins_with("ERROR:"):
						# no expected-witness class under Jolt: any
						# engine ERROR is a defect (r83 reviewer F4)
						script_err = true
				lf.close()
			else:
				return _fail("jolt_edge child log missing")
			var expect := {
				"jolt_backend": "Jolt Physics",
				"jolt_dss_class": "JoltPhysicsDirectSpaceState3D",
				"jolt_isect": "same-signature",
				"jolt_cast": "differs-constants",
				"jolt_btm": "differs-constants",
				"jolt_contact_stale": "same-signature",
				"jolt_static_nopair": "inverts",
			}
			if code != 0 or script_err or verdicts != expect:
				return _fail("jolt_edge child mismatch exit=%d serr=%s verdicts=%s"
						% [code, str(script_err), str(verdicts)])
			_exit_ok("PASS phys3d_events jolt_edge backend=Jolt isect=same cast=constants btm=constants contact_stale=same static_nopair=inverts child_exit=0")

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
	_cleanup_nodes()
	_cleanup_rids()
	quit(0)


# --child --arm=jolt_edge body: runs entirely inside the generated Jolt
# project. Each reduced arm replays its parent cell's geometry, prints
# the raw fields as CHILD_NOTE (child.log evidence), then one
# `CHILD_RESULT jolt_<arm>=<class>` where class is
# same-signature (raw tuple equals the DEFAULT signature) |
# differs-constants (the edge/structure holds; settled constants match
# the Jolt signature measured on this build) | inverts (the cell's
# verdict flips — static_nopair fires under Jolt) | unexpected
# (outside both known signatures; fails the parent's compare loudly).
func _child_jolt() -> void:
	wspace = root.get_world_3d().space
	dss = root.get_world_3d().direct_space_state
	var jolt_cls := ClassDB.class_exists("JoltPhysicsServer3D")
	var godot_cls := ClassDB.class_exists("GodotPhysicsServer3D")
	var engine := str(ProjectSettings.get_setting("physics/3d/physics_engine"))
	prints("CHILD_NOTE jolt_class=%s godot_class=%s engine=%s"
			% [str(jolt_cls), str(godot_cls), engine])
	# The child must really be running Jolt: a silent backend fallback
	# would let GodotPhysics impersonate the split. The ClassDB pair
	# swaps exactly one member per backend on this build (r83 gate).
	prints("CHILD_RESULT jolt_backend=%s"
			% ("Jolt Physics" if jolt_cls and not godot_cls else "unexpected"))
	if dss == null:
		# a null handle would read every query arm as blind — bail named
		prints("CHILD_NOTE jolt dss_null=true")
		_cleanup_nodes()
		_cleanup_rids()
		quit(1)
		return
	# r84 critic: the ClassDB pair is registry-level evidence; the live
	# space-state object's class is the active-backend witness and is
	# pinned in the parent's verdict map.
	prints("CHILD_RESULT jolt_dss_class=%s" % dss.get_class())

	# jolt_isect: the isect arm's wall/sphere pair, both directions.
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
	prints("CHILD_NOTE jolt_isect s0=%d m0=%d away=%d n1=%d back=%d"
			% [s0, m0, away, away_n1, back])
	var cls := "unexpected"
	if s0 == 1 and m0 == 0 and away == 0 and away_n1 == 0 and back == 1:
		cls = "same-signature"
	elif s0 == 1 and back == 1:
		# r84 critic: differs-constants must stand on positive evidence --
		# a backend that returns nothing at all (Dummy) would otherwise
		# earn a known class from zero reads
		cls = "differs-constants"
	prints("CHILD_RESULT jolt_isect=%s" % cls)

	# jolt_cast: settled fractions are solver constants; the wall->far
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
		prints("CHILD_NOTE jolt_cast degenerate sizes=%d,%d,%d"
				% [c0.size(), c1.size(), c2.size()])
	else:
		prints("CHILD_NOTE jolt_cast safe=%.6f unsafe=%.6f w0=%.6f,%.6f n1=%.6f,%.6f"
				% [c0[0], c0[1], c1[0], c1[1], c2[0], c2[1]])
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
	prints("CHILD_RESULT jolt_cast=%s" % cls)

	# jolt_btm: kinematic probe vs the same wall (returned to -3); the
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
	prints("CHILD_NOTE jolt_btm r0=%s t0=%.6f r1=%s t1=%.6f r2=%s t2=%.6f"
			% [str(r0), t0, str(r1), t1, str(r2), t2])
	cls = "unexpected"
	var btm_edge := r0 and not r1 and absf(t1 + 10.0) < 0.0001 \
			and not r2 and absf(t2 + 10.0) < 0.0001
	if btm_edge:
		if absf(t0 + 0.9765625) < 0.0001:
			cls = "same-signature"
		elif absf(t0 + 0.99853515625) < 0.0001:
			cls = "differs-constants"
	prints("CHILD_RESULT jolt_btm=%s" % cls)
	_cleanup_rids()

	# jolt_contact_stale: the two-tier discriminant; the contact count is
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
	prints("CHILD_NOTE jolt_contact_stale set=%d,%d in=%d,%d,%d out=%d,%d"
			% [set_c, set_i, in_w0_c, in_w0_i, in_n1_c, out_w0_c, out_n1_c])
	cls = "unexpected"
	var stale_pat := set_c == 0 and set_i == 1 and in_w0_c == 0 \
			and in_w0_i == 1 and in_n1_c > 0 and out_w0_c == in_n1_c \
			and out_n1_c == 0
	if stale_pat:
		cls = "same-signature" if in_n1_c == 4 else "differs-constants"
	prints("CHILD_RESULT jolt_contact_stale=%s" % cls)
	_cleanup_rids()

	# jolt_static_nopair: the known inverter. Under GodotPhysics the
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
	prints("CHILD_NOTE jolt_static_nopair tp=%d,%d,%d,%d,%d,%d,%d,%d delta=%d mv=%d,%d,%d"
			% [tp[0], tp[1], tp[2], tp[3], tp[4], tp[5], tp[6], tp[7],
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
	prints("CHILD_RESULT jolt_static_nopair=%s" % cls)
	_cleanup_nodes()
	_cleanup_rids()
	quit(0)
