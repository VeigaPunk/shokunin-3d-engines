extends SceneTree
# r97 probe: node-level Joint3D lattice (PinJoint3D/HingeJoint3D/SliderJoint3D
# nodes, node_a/node_b NodePath binding) vs the r89/r90 server-RID baseline.
#
# Default rig: two 1 kg spheres A (x=-0.25,y=2) and B (x=+0.25,y=2), r=0.1,
# plus a Joint3D node at (0,2,0). Bodies are added first; the joint node is
# added and then gets node_a/node_b NodePaths (relative to itself) unless the
# case says otherwise. B teleports +0.3 down at t=2 (bind cases).
#
# Cases:
#   bind        paths set after tree entry — does it bind, and when?
#   bindpre     paths set before tree entry — canonical order
#   bindnode    node_a assigned to a NON-body node — error class
#   badpath     node_b path points at nothing — error class
#   nob         only node_a set — binds to world? stays unbound?
#   freerj      free joint node at t=8 — bodies released, no crash?
#   freeb       free body-B NODE at t=8 — node teardown vs r90 server UAF
#   readd       remove joint node t=8, re-add t=30 — rebinds?
#   prio_l/hi   two node pins claim one body; prio=8 on left/right pin
#   excl_on     exclude_nodes_from_collision=true — overlapping jointed pair
#   excl_off    exclude=false — do overlapping jointed bodies fight?
#   excl_def    default (property untouched)
#   clamp       PinJoint3D impulse_clamp=0.1 — spike capped vs free?
#   clamp0      impulse_clamp=0.0 control
#   hmot        HingeJoint3D motor enable+target 5.0 via node flags
#   hlim        HingeJoint3D angular_limit +-0.2 via node flags
#   getrid      get_rid() before/after tree entry
#   repath      node_b changed to a third body mid-run — rebind?
#   slider      SliderJoint3D linear_limit, B pushed +x
#   cone        ConeTwistJoint3D swing_span=0.3, B dropped 0.5
#   g6          Generic6DOFJoint3D angular_limit_x +-0.3, B spun on x
#   dupclaim    two pin nodes claim the same body pair
#
# Rows: "NJ t=.. a=.. b=.. avb=.. jrid=.."

var case := "bind"
var tick := 0
var A: Node3D
var B: RigidBody3D
var C: RigidBody3D
var J: Joint3D
var J2: Joint3D
var LA: StaticBody3D
var LB: StaticBody3D

func fmt(x: float) -> String:
	return String.num(x, 4)

class Watcher extends Node:
	var probe
	func _physics_process(_d: float) -> void:
		probe.on_tick()

func ball(nm: String, pos: Vector3, r := 0.1) -> RigidBody3D:
	var b := RigidBody3D.new()
	b.name = nm
	b.position = pos
	b.mass = 1.0
	b.can_sleep = false
	var cs := CollisionShape3D.new()
	var sh := SphereShape3D.new()
	sh.radius = r
	cs.shape = sh
	b.add_child(cs)
	get_root().add_child(b)
	return b

func slab(nm: String, pos: Vector3) -> StaticBody3D:
	var b := StaticBody3D.new()
	b.name = nm
	b.position = pos
	var cs := CollisionShape3D.new()
	var sh := BoxShape3D.new()
	sh.size = Vector3(0.2, 0.2, 0.2)
	cs.shape = sh
	b.add_child(cs)
	get_root().add_child(b)
	return b

func new_joint(kind: String) -> Joint3D:
	match kind:
		"hinge": return HingeJoint3D.new()
		"slider": return SliderJoint3D.new()
		"cone": return ConeTwistJoint3D.new()
		"g6": return Generic6DOFJoint3D.new()
	return PinJoint3D.new()

func on_tick() -> void:
	tick += 1
	match case:
		"bind", "bindpre", "bindnode", "badpath", "nob", "excl_on", \
		"excl_off", "excl_def", "clamp", "clamp0", "getrid", "dupclaim", \
		"exclx_on", "exclx_off":
			if tick == 2 and is_instance_valid(B):
				B.position.y -= 0.3
			if tick in [4, 8, 20, 40, 60]:
				report()
			if tick == 60:
				fin()
		"clampbig", "clampbig0":
			if tick == 2 and is_instance_valid(B):
				B.position.y -= 2.0
			if tick in [4, 8, 20, 40, 60]:
				report()
			if tick == 60:
				fin()
		"freerj":
			if tick == 2:
				B.position.y -= 0.3
			if tick == 8:
				report()
				print("NJ freeing joint node")
				J.queue_free()
			if tick in [12, 30]:
				report()
			if tick == 30:
				fin()
		"freeb":
			if tick == 2:
				B.position.y -= 0.3
			if tick == 8:
				report()
				print("NJ freeing body B node")
				B.queue_free()
			if tick in [12, 30]:
				report()
			if tick == 30:
				fin()
		"readd":
			if tick == 2:
				B.position.y -= 0.3
			if tick == 8:
				report()
				get_root().remove_child(J)
			if tick == 30:
				report()
				get_root().add_child(J)
			if tick in [12, 34, 50]:
				report()
			if tick == 50:
				fin()
		"prio_l", "prio_r":
			if tick in [10, 20, 31, 45, 60]:
				report()
			if tick == 60:
				fin()
		"hmot":
			if tick in [4, 10, 24, 40, 60]:
				report()
			if tick == 60:
				fin()
		"hlim":
			if tick == 2:
				B.angular_velocity = Vector3(0, 0, 3.0)
			if tick in [4, 10, 24, 40, 60]:
				report()
			if tick == 60:
				fin()
		"repath":
			if tick == 2:
				B.position.y -= 0.3
			if tick == 8:
				report()
				print("NJ rebind to C")
				J.node_b = J.get_path_to(C)
			if tick in [12, 30, 50]:
				report()
			if tick == 50:
				fin()
		"slider":
			if tick == 2:
				B.linear_velocity = Vector3(1.5, 0, 0)
			if tick in [4, 8, 20, 40]:
				report()
			if tick == 40:
				fin()
		"cone":
			if tick == 2:
				B.position.y -= 0.5
			if tick in [4, 8, 16, 30, 50]:
				report()
			if tick == 50:
				fin()
		"g6":
			if tick == 2:
				B.angular_velocity = Vector3(3.0, 0, 0)
			if tick in [4, 8, 16, 30, 50]:
				report()
			if tick == 50:
				fin()

func report() -> void:
	var jok := "?"
	if is_instance_valid(J):
		jok = str(J.get_rid().is_valid())
	else:
		jok = "gone"
	var b := "gone"
	var avb := "-"
	if is_instance_valid(B):
		b = "%s,%s,%s" % [fmt(B.position.x), fmt(B.position.y),
			fmt(B.position.z)]
		avb = "%s,%s,%s" % [fmt(B.angular_velocity.x),
			fmt(B.angular_velocity.y), fmt(B.angular_velocity.z)]
	print("NJ t=%d a=%s,%s,%s b=%s avb=%s jrid=%s" % [
		tick, fmt(A.position.x), fmt(A.position.y), fmt(A.position.z),
		b, avb, jok])

func fin() -> void:
	print("NJSUM case=%s" % case)
	quit(0)

func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--case="):
			case = a.substr(7)
	var w := Watcher.new()
	w.probe = self
	get_root().add_child(w)
	match case:
		"prio_l", "prio_r":
			# node version of r90 twopin: one body claimed by two pins
			LA = slab("anchorL", Vector3(-0.5, 2, 0))
			LB = slab("anchorR", Vector3(0.5, 2, 0))
			B = ball("bodyB", Vector3(0, 2, 0))
			A = B  # report slot A unused in this rig
			J = PinJoint3D.new()          # left pin, at midpoint of L-B
			J.position = Vector3(-0.25, 2, 0)
			J2 = PinJoint3D.new()         # right pin
			J2.position = Vector3(0.25, 2, 0)
			if case == "prio_l":
				J.solver_priority = 8
			else:
				J2.solver_priority = 8
			get_root().add_child(J)
			get_root().add_child(J2)
			J.node_a = NodePath("../anchorL")
			J.node_b = NodePath("../bodyB")
			J2.node_a = NodePath("../anchorR")
			J2.node_b = NodePath("../bodyB")
			print("NJ setup case=%s" % case)
			return
		"cone":
			A = ball("bodyA", Vector3(0, 3, 0))
			B = ball("bodyB", Vector3(0, 2.5, 0))
			J = new_joint("cone")
			J.position = Vector3(0, 2.75, 0)
		"g6":
			A = ball("bodyA", Vector3(0, 2.5, 0))
			B = ball("bodyB", Vector3(0, 2.0, 0))
			J = new_joint("g6")
			J.position = Vector3(0, 2.25, 0)
		"slider":
			A = slab("bodyA", Vector3(-0.5, 2, 0))
			B = ball("bodyB", Vector3(-0.2, 2, 0))
			B.gravity_scale = 0.0
			J = new_joint("slider")
			J.position = Vector3(-0.35, 2, 0)
		_:
			A = ball("bodyA", Vector3(-0.25, 2, 0))
			B = ball("bodyB", Vector3(0.25, 2, 0))
			var jkind := "pin"
			if case in ["hmot", "hlim"]:
				jkind = "hinge"
			J = new_joint(jkind)
			J.position = Vector3(0, 2, 0)
	match case:
		"bindpre":
			J.node_a = NodePath("../bodyA")
			J.node_b = NodePath("../bodyB")
			get_root().add_child(J)
		"bindnode":
			var n := Node3D.new()
			n.name = "notabody"
			get_root().add_child(n)
			J.node_a = NodePath("../notabody")
			J.node_b = NodePath("../bodyB")
			get_root().add_child(J)
		"badpath":
			J.node_a = NodePath("../bodyA")
			J.node_b = NodePath("../doesnotexist")
			get_root().add_child(J)
		"nob":
			J.node_a = NodePath("../bodyA")
			get_root().add_child(J)
		"excl_on", "excl_off", "excl_def":
			# NB dead-scout flaw: B at x=0.05 is 0.3 m from A(-0.25) —
			# r=0.1 spheres NEVER overlap; the flag is unobservable here.
			B.position = Vector3(0.05, 2, 0)
			if case != "excl_def":
				J.exclude_nodes_from_collision = (case == "excl_on")
			get_root().add_child(J)
			J.node_a = NodePath("../bodyA")
			J.node_b = NodePath("../bodyB")
		"exclx_on", "exclx_off":
			# finisher supplement: TRUE overlap — B at x=-0.10 is 0.15 m
			# from A(-0.25) < r1+r2=0.2, so contact would form without
			# the joint exclusion.
			B.position = Vector3(-0.10, 2, 0)
			J.exclude_nodes_from_collision = (case == "exclx_on")
			get_root().add_child(J)
			J.node_a = NodePath("../bodyA")
			J.node_b = NodePath("../bodyB")
		"clamp", "clamp0", "clampbig", "clampbig0":
			# NB: with a 0.3 m teleport the impulse never reaches the 0.1
			# clamp -> null cell; clampbig* teleports -2.0 instead.
			var cl := 0.0
			if case == "clamp" or case == "clampbig":
				cl = 0.1
			J.set("params/impulse_clamp", cl)
			get_root().add_child(J)
			J.node_a = NodePath("../bodyA")
			J.node_b = NodePath("../bodyB")
		"hmot":
			var h := J as HingeJoint3D
			h.set_flag(HingeJoint3D.FLAG_USE_LIMIT, false)
			h.set_flag(HingeJoint3D.FLAG_ENABLE_MOTOR, true)
			h.set_param(HingeJoint3D.PARAM_MOTOR_TARGET_VELOCITY, 5.0)
			h.set_param(HingeJoint3D.PARAM_MOTOR_MAX_IMPULSE, 50.0)
			get_root().add_child(J)
			J.node_a = NodePath("../bodyA")
			J.node_b = NodePath("../bodyB")
		"hlim":
			var h := J as HingeJoint3D
			h.set_flag(HingeJoint3D.FLAG_USE_LIMIT, true)
			h.set_param(HingeJoint3D.PARAM_LIMIT_LOWER, -0.2)
			h.set_param(HingeJoint3D.PARAM_LIMIT_UPPER, 0.2)
			get_root().add_child(J)
			J.node_a = NodePath("../bodyA")
			J.node_b = NodePath("../bodyB")
		"slider":
			var s := J as SliderJoint3D
			s.set_param(SliderJoint3D.PARAM_LINEAR_LIMIT_UPPER, 0.4)
			s.set_param(SliderJoint3D.PARAM_LINEAR_LIMIT_LOWER, -0.1)
			get_root().add_child(J)
			J.node_a = NodePath("../bodyA")
			J.node_b = NodePath("../bodyB")
		"cone":
			var c := J as ConeTwistJoint3D
			c.set_param(ConeTwistJoint3D.PARAM_SWING_SPAN, 0.3)
			c.set_param(ConeTwistJoint3D.PARAM_TWIST_SPAN, 0.3)
			get_root().add_child(J)
			J.node_a = NodePath("../bodyA")
			J.node_b = NodePath("../bodyB")
		"g6":
			var g := J as Generic6DOFJoint3D
			g.set_flag_x(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_LIMIT, true)
			g.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, -0.3)
			g.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, 0.3)
			get_root().add_child(J)
			J.node_a = NodePath("../bodyA")
			J.node_b = NodePath("../bodyB")
		"getrid":
			print("NJ prerid=%s" % str(J.get_rid().is_valid()))
			get_root().add_child(J)
			print("NJ intrid=%s" % str(J.get_rid().is_valid()))
			J.node_a = NodePath("../bodyA")
			J.node_b = NodePath("../bodyB")
		"repath":
			C = ball("bodyC", Vector3(0.25, 3, 0))
			get_root().add_child(J)
			J.node_a = NodePath("../bodyA")
			J.node_b = NodePath("../bodyB")
		"dupclaim":
			J2 = PinJoint3D.new()
			J2.position = Vector3(0.5, 2, 0)
			get_root().add_child(J)
			get_root().add_child(J2)
			J.node_a = NodePath("../bodyA")
			J.node_b = NodePath("../bodyB")
			J2.node_a = NodePath("../bodyA")
			J2.node_b = NodePath("../bodyB")
		_:
			get_root().add_child(J)
			J.node_a = NodePath("../bodyA")
			J.node_b = NodePath("../bodyB")
	print("NJ setup case=%s jrid=%s" % [case, str(J.get_rid().is_valid())])
