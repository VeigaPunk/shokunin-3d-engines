extends SceneTree
# r90 child probe — joint RID lifecycle + solver-priority + freed-endpoint
# families, spawned per (case, backend) by phys3d_joints.gd. Emits
# `M0 case=..` / `M <case> ..` / `M DONE ..` verdict lines on stdout.
# argv: `-- <case>`.

var case := "sweep"
var a_rid: RID
var b_rid: RID
var c_rid: RID
var joint: RID
var joint2: RID
var shapes: Array = []
var bodies: Array = []
var joints: Array = []
var e_tick := 0
var done := false
var fired := false

class Watcher extends Node:
	var probe
	func _physics_process(_d: float) -> void:
		probe.on_e()


func v3(v: Vector3) -> String:
	return "%.4f,%.4f,%.4f" % [v.x, v.y, v.z]


func fmt(v: Variant) -> String:
	if v is Vector3:
		return v3(v)
	if v == null:
		return "null"
	return str(v)


func st(rid: RID, s: int) -> Variant:
	return PhysicsServer3D.body_get_state(rid, s)


func bpos(rid: RID) -> Vector3:
	var v: Variant = st(rid, PhysicsServer3D.BODY_STATE_TRANSFORM)
	return v.origin if v is Transform3D else Vector3.ZERO


func mk_body(pos: Vector3, mode: int, half := Vector3(0.4, 0.4, 0.4),
		sphere := false) -> RID:
	var sh: RID
	if sphere:
		sh = PhysicsServer3D.sphere_shape_create()
		PhysicsServer3D.shape_set_data(sh, 0.5)
	else:
		sh = PhysicsServer3D.box_shape_create()
		PhysicsServer3D.shape_set_data(sh, half)
	var b := PhysicsServer3D.body_create()
	PhysicsServer3D.body_set_mode(b, mode)
	PhysicsServer3D.body_add_shape(b, sh)
	PhysicsServer3D.body_set_space(b, root.get_world_3d().space)
	PhysicsServer3D.body_set_state(b, PhysicsServer3D.BODY_STATE_TRANSFORM,
			Transform3D(Basis(), pos))
	shapes.append(sh)
	bodies.append(b)
	return b


func wit() -> String:
	var tb: Variant = st(b_rid, PhysicsServer3D.BODY_STATE_TRANSFORM)
	var lv: Variant = st(b_rid, PhysicsServer3D.BODY_STATE_LINEAR_VELOCITY)
	var bs := "null"
	if tb is Transform3D:
		bs = v3((tb as Transform3D).origin)
	return "b=%s lv=%s jtype=%s" % [bs, fmt(lv),
			fmt(PhysicsServer3D.joint_get_type(joint))]


func on_e() -> void:
	if done:
		return
	e_tick += 1
	match case:
		"freeb", "freea":
			if e_tick <= 8:
				print("M %s t=%d %s" % [case, e_tick, wit()])
			if e_tick == 6 and not fired:
				fired = true
				PhysicsServer3D.free_rid(b_rid if case == "freeb" else a_rid)
				print("M %s freed post jtype=%s" % [case,
						fmt(PhysicsServer3D.joint_get_type(joint))])
		"freeb_dyn":
			if e_tick <= 8:
				print("M %s t=%d %s" % [case, e_tick, wit()])
			if e_tick == 6 and not fired:
				fired = true
				PhysicsServer3D.free_rid(b_rid)
				print("M %s freed post jtype=%s" % [case,
						fmt(PhysicsServer3D.joint_get_type(joint))])
		"freeb_ops":
			if e_tick == 6 and not fired:
				fired = true
				PhysicsServer3D.free_rid(b_rid)
				print("M %s freed" % case)
			if e_tick == 7:
				print("M %s get_type=%s" % [case,
						fmt(PhysicsServer3D.joint_get_type(joint))])
				PhysicsServer3D.joint_set_solver_priority(joint, 8)
				print("M %s get_prio=%s" % [case,
						fmt(PhysicsServer3D.joint_get_solver_priority(joint))])
				PhysicsServer3D.pin_joint_set_param(joint,
						PhysicsServer3D.PIN_JOINT_BIAS, 0.5)
				print("M %s pin_param=%s" % [case,
						fmt(PhysicsServer3D.pin_joint_get_param(joint,
								PhysicsServer3D.PIN_JOINT_BIAS))])
				PhysicsServer3D.joint_disable_collisions_between_bodies(
						joint, false)
				print("M %s isdis=%s" % [case, fmt(
						PhysicsServer3D.joint_is_disabled_collisions_between_bodies(
								joint))])
				PhysicsServer3D.joint_clear(joint)
				print("M %s cleared type=%s" % [case,
						fmt(PhysicsServer3D.joint_get_type(joint))])
		"freeb_make":
			if e_tick == 4 and not fired:
				fired = true
				PhysicsServer3D.free_rid(b_rid)
				print("M %s freed_b" % case)
			if e_tick == 6:
				PhysicsServer3D.joint_make_pin(joint, a_rid, Vector3.ZERO,
						b_rid, Vector3.ZERO)
				print("M %s made type=%s" % [case,
						fmt(PhysicsServer3D.joint_get_type(joint))])
		"freeb_world":
			if e_tick == 6 and not fired:
				fired = true
				PhysicsServer3D.joint_make_pin(joint, a_rid, Vector3.ZERO,
						RID(), Vector3.ZERO)
				print("M %s made type=%s" % [case,
						fmt(PhysicsServer3D.joint_get_type(joint))])
			if e_tick <= 10:
				print("M %s t=%d %s" % [case, e_tick, wit()])
		"freeb_twice":
			if e_tick == 6 and not fired:
				fired = true
				PhysicsServer3D.free_rid(b_rid)
				print("M %s free1 done" % case)
			if e_tick == 8:
				PhysicsServer3D.free_rid(b_rid)
				print("M %s free2 done" % case)
		"freej_then_b":
			if e_tick == 6 and not fired:
				fired = true
				PhysicsServer3D.free_rid(joint)
				print("M %s joint freed" % case)
			if e_tick == 8:
				PhysicsServer3D.free_rid(b_rid)
				print("M %s b freed" % case)
		"freeb_afterclear":
			if e_tick == 5 and not fired:
				fired = true
				PhysicsServer3D.joint_clear(joint)
				print("M %s clear type=%s" % [case,
						fmt(PhysicsServer3D.joint_get_type(joint))])
			if e_tick == 6:
				PhysicsServer3D.free_rid(b_rid)
				print("M %s b freed" % case)
		"detachb":
			if e_tick == 6 and not fired:
				fired = true
				PhysicsServer3D.body_set_space(b_rid, RID())
				print("M %s detached jtype=%s" % [case,
						fmt(PhysicsServer3D.joint_get_type(joint))])
			if e_tick == 10:
				PhysicsServer3D.body_set_space(b_rid,
						root.get_world_3d().space)
				print("M %s reattached jtype=%s" % [case,
						fmt(PhysicsServer3D.joint_get_type(joint))])
			if e_tick <= 12:
				print("M %s t=%d %s" % [case, e_tick, wit()])
		"detachb_free":
			if e_tick == 6 and not fired:
				fired = true
				PhysicsServer3D.body_set_space(b_rid, RID())
				print("M %s detached" % case)
			if e_tick == 7:
				PhysicsServer3D.free_rid(b_rid)
				print("M %s freed" % case)
		"chain3_freemid":
			if e_tick == 20 and not fired:
				fired = true
				PhysicsServer3D.free_rid(bodies[1])
				print("M %s mid freed type1=%s type2=%s" % [case,
						fmt(PhysicsServer3D.joint_get_type(joints[0])),
						fmt(PhysicsServer3D.joint_get_type(joints[1]))])
		"twopin_hi1", "twopin_hi2":
			if e_tick <= 16:
				print("M %s t=%d %s" % [case, e_tick, wit()])
	if e_tick >= 12 and not done:
		if case.begins_with("twopin") or case == "chain3_freemid":
			if e_tick < (31 if case.begins_with("twopin") else 30):
				return
		done = true
		print("M DONE case=%s engine=%s" % [case,
				str(ProjectSettings.get_setting("physics/3d/physics_engine"))])
		# teardown: free joints first, then bodies (the scout's order)
		for r in [joint, joint2] + joints + bodies + shapes:
			if r is RID and r.is_valid():
				PhysicsServer3D.free_rid(r)
		await process_frame
		quit(0)


func _initialize() -> void:
	if OS.get_cmdline_user_args().size() > 0:
		case = OS.get_cmdline_user_args()[0]
	var P := PhysicsServer3D
	match case:
		"sweep":
			a_rid = mk_body(Vector3(0, 3, 0), P.BODY_MODE_STATIC)
			b_rid = mk_body(Vector3(0, 2, 0), P.BODY_MODE_RIGID, Vector3.ZERO,
					true)
			joint = P.joint_create()
			P.joint_make_pin(joint, a_rid, Vector3.ZERO, b_rid, Vector3.ZERO)
			var outs := []
			for n in [-2, -1, 0, 1, 2, 4, 8, 32, 64, 65, 128]:
				P.joint_set_solver_priority(joint, n)
				outs.append("%d:%s" % [n,
						fmt(P.joint_get_solver_priority(joint))])
			print("M sweep rt=%s" % [";".join(outs)])
			var ju := P.joint_create()
			print("M unmade get0=%s" % fmt(P.joint_get_solver_priority(ju)))
			P.joint_set_solver_priority(ju, 32)
			print("M unmade set32 get1=%s" % fmt(
					P.joint_get_solver_priority(ju)))
			P.joint_set_solver_priority(ju, -5)
			print("M unmade setneg get2=%s" % fmt(
					P.joint_get_solver_priority(ju)))
			print("M DONE case=sweep engine=%s" % str(
					ProjectSettings.get_setting("physics/3d/physics_engine")))
			quit(0)
			done = true
		"rid":
			var j1 := P.joint_create()
			print("M rid j1_valid=%s type=%s" % [str(j1.is_valid()),
					fmt(P.joint_get_type(j1))])
			P.free_rid(j1)
			print("M rid j1_after_free valid=%s type=%s" % [
					str(j1.is_valid()), fmt(P.joint_get_type(j1))])
			var j2 := P.joint_create()
			print("M rid j2_eq_j1=%s j2_valid=%s type=%s" % [
					str(j2 == j1), str(j2.is_valid()),
					fmt(P.joint_get_type(j2))])
			# remake on the FREED j1 (typed refusal per r89)
			P.joint_make_pin(j1,
					mk_body(Vector3(0, 3, 0), P.BODY_MODE_STATIC),
					Vector3.ZERO,
					mk_body(Vector3(0, 2, 0), P.BODY_MODE_RIGID,
							Vector3.ZERO, true), Vector3.ZERO)
			print("M rid remake_freed type=%s" % fmt(P.joint_get_type(j1)))
			# make on fresh j2 works
			P.joint_make_pin(j2,
					mk_body(Vector3(20, 3, 0), P.BODY_MODE_STATIC),
					Vector3.ZERO,
					mk_body(Vector3(20, 2, 0), P.BODY_MODE_RIGID,
							Vector3.ZERO, true), Vector3.ZERO)
			print("M rid fresh type=%s" % fmt(P.joint_get_type(j2)))
			# if j2 reused j1's slot, does j1 now alias j2's joint?
			print("M rid j1_alias_type=%s j1_eq_j2=%s" % [
					fmt(P.joint_get_type(j1)), str(j1 == j2)])
			P.free_rid(j2)
			print("M rid after j2free j1_type=%s" % fmt(P.joint_get_type(j1)))
			var j3 := P.joint_create()
			print("M rid j3_eq=%s,%s" % [str(j3 == j1), str(j3 == j2)])
			print("M DONE case=rid engine=%s" % str(
					ProjectSettings.get_setting("physics/3d/physics_engine")))
			quit(0)
			done = true
		"api":
			for c in ["JoltPhysicsServer3D", "GodotPhysicsServer3D",
					"PhysicsServer3DDummy", "PhysicsServer3D",
					"PhysicsDirectBodyState3D"]:
				print("M api cls %s exists=%s can_inst=%s meth=%d" % [c,
						str(ClassDB.class_exists(c)),
						str(ClassDB.can_instantiate(c)),
						ClassDB.class_get_method_list(c, true).size()])
			var jm := 0
			for m in ClassDB.class_get_method_list("PhysicsServer3D", true):
				var n: String = m["name"]
				if n.contains("joint") or n.contains("break") \
						or n.contains("enable") or n.contains("iterat") \
						or n.contains("applied"):
					jm += 1
			print("M api ps_joint_methods=%d" % jm)
			for n in ["joint_set_enabled", "joint_get_enabled",
					"joint_set_solver_velocity_iterations",
					"joint_set_solver_position_iterations",
					"pin_joint_get_applied_force",
					"hinge_joint_get_jolt_flag",
					"generic_6dof_joint_set_jolt_flag",
					"joint_set_breakable", "joint_make_hinge_simple"]:
				print("M api has %s=%s" % [n,
						str(PhysicsServer3D.has_method(n))])
			var r: Variant = "ABSENT"
			if PhysicsServer3D.has_method("joint_set_enabled"):
				r = PhysicsServer3D.callv("joint_set_enabled", [RID(), false])
			print("M api callv_guarded=%s" % fmt(r))
			print("M DONE case=api engine=%s" % str(
					ProjectSettings.get_setting("physics/3d/physics_engine")))
			quit(0)
			done = true
		_:
			# endpoint cells: A static box at (0,3,0), B sphere at (0,2,0)
			var dyn_a: bool = case == "freeb_dyn"
			a_rid = mk_body(Vector3(0, 3, 0),
					P.BODY_MODE_RIGID if dyn_a else P.BODY_MODE_STATIC)
			b_rid = mk_body(Vector3(0, 2, 0), P.BODY_MODE_RIGID,
					Vector3.ZERO, true)
			joint = P.joint_create()
			joint2 = P.joint_create()
			if case != "freeb_make" and case != "freeb_world" \
					and not case.begins_with("twopin"):
				P.joint_make_pin(joint, a_rid, Vector3.ZERO, b_rid,
						Vector3.ZERO)
			if case.begins_with("twopin"):
				P.joint_make_pin(joint, a_rid, Vector3(-0.5, 0, 0),
						b_rid, Vector3.ZERO)
				P.joint_make_pin(joint2, a_rid, Vector3(0.5, 0, 0),
						b_rid, Vector3.ZERO)
				P.joint_disable_collisions_between_bodies(joint, true)
				P.joint_disable_collisions_between_bodies(joint2, true)
				if case == "twopin_hi1":
					P.joint_set_solver_priority(joint, 32)
				else:
					P.joint_set_solver_priority(joint2, 32)
			if case == "chain3_freemid":
				# A at (0,4,0); B(0,3.2) C(0,2.4) spheres r=0.3
				bodies.clear(); shapes.clear()
				PhysicsServer3D.free_rid(a_rid); PhysicsServer3D.free_rid(b_rid)
				a_rid = mk_body(Vector3(0, 4, 0), P.BODY_MODE_STATIC)
				var bb := mk_body(Vector3(0, 3.2, 0), P.BODY_MODE_RIGID,
						Vector3.ZERO, true)
				var cc := mk_body(Vector3(0, 2.4, 0), P.BODY_MODE_RIGID,
						Vector3.ZERO, true)
				joints.clear()
				var j1 := P.joint_create()
				P.joint_make_pin(j1, a_rid, Vector3(0, -0.4, 0), bb,
						Vector3(0, 0.3, 0))
				var j2c := P.joint_create()
				P.joint_make_pin(j2c, bb, Vector3(0, -0.3, 0), cc,
						Vector3(0, 0.3, 0))
				joints.append(j1); joints.append(j2c)
				joint = j1; joint2 = j2c
	var w := Watcher.new()
	w.probe = self
	root.add_child(w)
	print("M0 case=%s engine=%s" % [case,
			str(ProjectSettings.get_setting("physics/3d/physics_engine"))])
