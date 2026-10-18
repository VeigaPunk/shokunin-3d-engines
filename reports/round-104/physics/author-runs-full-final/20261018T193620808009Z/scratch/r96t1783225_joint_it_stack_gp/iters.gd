# r96-scout probe 1: solver iteration counts — do velocity vs position steps
# buy different joint settling?
#
# The iteration knobs are project settings, so every cell is a project bake
# (see driver.py PROJECTS):
#   GodotPhysics: physics/3d/solver/solver_iterations            (1..32+)
#   Jolt:         physics/jolt_physics_3d/simulation/velocity_steps (2..16+)
#                 physics/jolt_physics_3d/simulation/position_steps (1..16+)
#
# Bodies are SERVER-created and explicitly put in the world space, the r89/r93
# harness: a joint created in _initialize() on NODE bodies is silently dropped
# on GodotPhysics (the node's space is assigned after init and
# GodotPhysicsServer3D::body_set_space() calls clear_constraint_map(); see
# srvjoint.gd).
#
# Joint pivots are the MIDPOINT of the two bodies (Godot's pin drives its two
# pivot points to coincide, so a midpoint pivot is what makes it a distance
# link -- the PinJoint3D node's global position is exactly that pivot).
#
# Cases (argv[0]):
#   pin    - one pin link, made at rest length 1.0, body teleported 0.3 m down
#            before step 1: pure position-error recovery
#   chain  - 3-link pin chain hanging under gravity: steady-state stretch
#   hinge  - hinge, pivot at the midpoint, axis = world Z, limit +-0.2 rad,
#            body spun at 3 rad/s into the limit: limit overshoot
#   stack  - 5-box tower on a static floor: penetration + tower jitter
extends SceneTree

var case := "pin"
var tick := 0
var done := false
var parts: Array = []          # [{rid, tag}]
var joints: Array = []
var body_rids: Array = []      # rids whose y we report (chain order)
var anchor_rid: RID
var rest_len := 1.0
var boxes: Array = []
var hinge_rid: RID
var peak := {"max_gap": -1e9, "max_sum": -1e9, "max_over": -1e9,
		"min_pen0": 1e9, "max_vmax": -1e9, "last_gap": 0.0,
		"last_sum": 0.0, "last_pen0": 0.0, "last_over": 0.0, "last_y2": 0.0,
		"last_y4": 0.0, "last_xz4": 0.0, "last_lv": 0.0}


class Watcher extends Node:
	var probe
	func _physics_process(_d: float) -> void:
		probe.on_e()


func fmt(x: float, nd := 6) -> String:
	return String.num(x, nd)


func v3(v: Vector3) -> String:
	return "%.4f,%.4f,%.4f" % [v.x, v.y, v.z]


func tr_of(rid: RID) -> Transform3D:
	var v: Variant = PhysicsServer3D.body_get_state(rid,
			PhysicsServer3D.BODY_STATE_TRANSFORM)
	return v if v is Transform3D else Transform3D()


func lv_of(rid: RID) -> Vector3:
	var v: Variant = PhysicsServer3D.body_get_state(rid,
			PhysicsServer3D.BODY_STATE_LINEAR_VELOCITY)
	return v if v is Vector3 else Vector3.ZERO


# `size` is SERVER semantics: box shape data is HALF-EXTENTS (r93 pinned this),
# sphere data is the radius (size.x).
func mk_srv(pos: Vector3, mode: int, kind: String, size: Vector3,
		mass: float, tag: String) -> RID:
	var rid := PhysicsServer3D.body_create()
	PhysicsServer3D.body_set_mode(rid, mode)
	var sh: RID
	if kind == "sphere":
		sh = PhysicsServer3D.sphere_shape_create()
		PhysicsServer3D.shape_set_data(sh, size.x)
	else:
		sh = PhysicsServer3D.box_shape_create()
		PhysicsServer3D.shape_set_data(sh, size)
	PhysicsServer3D.body_add_shape(rid, sh)
	PhysicsServer3D.body_set_space(rid, root.world_3d.space)
	PhysicsServer3D.body_set_state(rid, PhysicsServer3D.BODY_STATE_TRANSFORM,
			Transform3D(Basis(), pos))
	if mode > PhysicsServer3D.BODY_MODE_KINEMATIC:
		PhysicsServer3D.body_set_param(rid,
				PhysicsServer3D.BODY_PARAM_MASS, mass)
		PhysicsServer3D.body_set_param(rid,
				PhysicsServer3D.BODY_PARAM_FRICTION, 1.0)
		PhysicsServer3D.body_set_param(rid,
				PhysicsServer3D.BODY_PARAM_BOUNCE, 0.0)
	parts.append({"rid": rid, "tag": tag})
	return rid


func mk_pin_mid(a: RID, b: RID) -> RID:
	var ta := tr_of(a)
	var tb := tr_of(b)
	var mid := (ta.origin + tb.origin) * 0.5
	var la := ta.affine_inverse() * mid
	var lb := tb.affine_inverse() * mid
	var j := PhysicsServer3D.joint_create()
	PhysicsServer3D.joint_make_pin(j, a, la, b, lb)
	joints.append(j)
	return j


func build_pin() -> void:
	anchor_rid = mk_srv(Vector3(0, 3, 0), PhysicsServer3D.BODY_MODE_STATIC,
			"box", Vector3(0.1, 0.1, 0.1), 0.0, "a")
	var b := mk_srv(Vector3(0, 2, 0), PhysicsServer3D.BODY_MODE_RIGID,
			"sphere", Vector3(0.2, 0.2, 0.2), 1.0, "b0")
	mk_pin_mid(anchor_rid, b)
	rest_len = 1.0
	body_rids = [b]
	PhysicsServer3D.body_set_state(b, PhysicsServer3D.BODY_STATE_TRANSFORM,
			Transform3D(Basis(), Vector3(0, 1.7, 0)))   # 0.3 m error
	print("IT0 case=pin rest=1.0000 spawn_err=-0.3000")


func build_chain() -> void:
	anchor_rid = mk_srv(Vector3(0, 6, 0), PhysicsServer3D.BODY_MODE_STATIC,
			"box", Vector3(0.1, 0.1, 0.1), 0.0, "a")
	var prev := anchor_rid
	for i in 3:
		var b := mk_srv(Vector3(0, 5 - i, 0), PhysicsServer3D.BODY_MODE_RIGID,
				"sphere", Vector3(0.15, 0.15, 0.15), 1.0, "b%d" % i)
		mk_pin_mid(prev, b)
		prev = b
		body_rids.append(b)
	rest_len = 1.0
	print("IT0 case=chain links=3 rest=1.0000 g=9.8")


func build_hinge() -> void:
	# Anchor at (0,3,0), body at (0,2,0); the hinge line is world Z through the
	# BODY CENTRE (0,2,0) so the body's spin about its own origin is the hinge's
	# free motion (a pivot off the centre is resisted by the hinge's linear part).
	anchor_rid = mk_srv(Vector3(0, 3, 0), PhysicsServer3D.BODY_MODE_STATIC,
			"box", Vector3(0.1, 0.1, 0.1), 0.0, "a")
	var b := mk_srv(Vector3(0, 2, 0), PhysicsServer3D.BODY_MODE_RIGID,
			"sphere", Vector3(0.2, 0.2, 0.2), 1.0, "b0")
	var fa := Transform3D(Basis(), Vector3(0, -1, 0))
	var fb := Transform3D(Basis(), Vector3.ZERO)
	var j := PhysicsServer3D.joint_create()
	PhysicsServer3D.joint_make_hinge(j, anchor_rid, fa, b, fb)
	PhysicsServer3D.hinge_joint_set_flag(j,
			PhysicsServer3D.HINGE_JOINT_FLAG_USE_LIMIT, true)
	PhysicsServer3D.hinge_joint_set_param(j,
			PhysicsServer3D.HINGE_JOINT_LIMIT_UPPER, 0.2)
	PhysicsServer3D.hinge_joint_set_param(j,
			PhysicsServer3D.HINGE_JOINT_LIMIT_LOWER, -0.2)
	joints.append(j)
	hinge_rid = b
	body_rids = [b]
	PhysicsServer3D.body_set_state(b, PhysicsServer3D.BODY_STATE_ANGULAR_VELOCITY,
			Vector3(0, 0, 3.0))
	print("IT0 case=hinge lim=+-0.2000 av0=(0,0,3.0000) pivot=body_center axis=frameZ")
	print("IT0 hinge_readback use_limit=%s bias=%s upper=%s lower=%s limit_bias=%s softness=%s relaxation=%s" % [
			str(PhysicsServer3D.hinge_joint_get_flag(j,
					PhysicsServer3D.HINGE_JOINT_FLAG_USE_LIMIT)),
			str(PhysicsServer3D.hinge_joint_get_param(j,
					PhysicsServer3D.HINGE_JOINT_BIAS)),
			str(PhysicsServer3D.hinge_joint_get_param(j,
					PhysicsServer3D.HINGE_JOINT_LIMIT_UPPER)),
			str(PhysicsServer3D.hinge_joint_get_param(j,
					PhysicsServer3D.HINGE_JOINT_LIMIT_LOWER)),
			str(PhysicsServer3D.hinge_joint_get_param(j,
					PhysicsServer3D.HINGE_JOINT_LIMIT_BIAS)),
			str(PhysicsServer3D.hinge_joint_get_param(j,
					PhysicsServer3D.HINGE_JOINT_LIMIT_SOFTNESS)),
			str(PhysicsServer3D.hinge_joint_get_param(j,
					PhysicsServer3D.HINGE_JOINT_LIMIT_RELAXATION))])


func build_stack() -> void:
	anchor_rid = mk_srv(Vector3(0, -0.25, 0), PhysicsServer3D.BODY_MODE_STATIC,
			"box", Vector3(5, 0.25, 5), 0.0, "floor")
	for i in 5:
		# 0.005 m clearance between 0.4 m cubes: no initial overlap (spawning
		# them exactly touching makes the solver launch the tower -- a
		# degenerate-contact confound, not an iteration effect).
		var b := mk_srv(Vector3(0, 0.2025 + 0.405 * i, 0),
				PhysicsServer3D.BODY_MODE_RIGID, "box",
				Vector3(0.2, 0.2, 0.2), 1.0, "box%d" % i)
		boxes.append(b)
	print("IT0 case=stack n=5 cube=0.4 floor_top=0.0000 gap0=0.005")


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	case = args[0] if args.size() > 0 else "pin"
	match case:
		"pin": build_pin()
		"chain": build_chain()
		"hinge": build_hinge()
		"stack": build_stack()
		_:
			print("IT0 unknown case=%s" % case)
			quit(2)
			return
	var w := Watcher.new()
	w.probe = self
	root.add_child(w)


func sample_tick() -> bool:
	return tick <= 10 or tick % 5 == 0 or (tick % 30 == 0 and tick <= 180)


func on_e() -> void:
	tick += 1
	match case:
		"pin":
			var b: RID = body_rids[0]
			var gap := tr_of(anchor_rid).origin.distance_to(tr_of(b).origin) \
					- rest_len
			peak["last_gap"] = gap
			peak["max_gap"] = max(peak["max_gap"], absf(gap))
			peak["last_lv"] = lv_of(b).y
			if sample_tick():
				print("IT t=%d gap=%s lv=%s y=%s" % [tick, fmt(gap),
						fmt(lv_of(b).y), fmt(tr_of(b).origin.y)])
		"chain":
			var gaps := []
			var total := 0.0
			var prev := tr_of(anchor_rid).origin
			for i in 3:
				var b: RID = body_rids[i]
				var g := tr_of(b).origin.distance_to(prev) - rest_len
				gaps.append(g)
				total += g
				prev = tr_of(b).origin
			var bot: RID = body_rids[2]
			peak["last_sum"] = total
			peak["max_sum"] = max(peak["max_sum"], absf(total))
			peak["last_y2"] = tr_of(bot).origin.y
			if sample_tick():
				print("IT t=%d g0=%s g1=%s g2=%s sum=%s lv2y=%s y2=%s" % [
						tick, fmt(gaps[0]), fmt(gaps[1]), fmt(gaps[2]),
						fmt(total), fmt(lv_of(bot).y),
						fmt(tr_of(bot).origin.y)])
		"hinge":
			var b := hinge_rid
			var e := tr_of(b).basis.get_euler()
			var av: Variant = PhysicsServer3D.body_get_state(b,
					PhysicsServer3D.BODY_STATE_ANGULAR_VELOCITY)
			peak["last_over"] = e.z - 0.2
			peak["max_over"] = max(peak["max_over"], e.z - 0.2)
			if sample_tick():
				print("IT t=%d euler=%s av=%s over=%s" % [tick, v3(e),
						v3(av if av is Vector3 else Vector3.ZERO),
						fmt(e.z - 0.2)])
		"stack":
			var b0: RID = boxes[0]
			var b4: RID = boxes[4]
			var vmax := 0.0
			for b in boxes:
				vmax = max(vmax, lv_of(b).length())
			peak["last_pen0"] = 0.2 - tr_of(b0).origin.y
			peak["min_pen0"] = min(peak["min_pen0"], peak["last_pen0"])
			peak["max_vmax"] = max(peak["max_vmax"], vmax)
			peak["last_y4"] = tr_of(b4).origin.y
			peak["last_xz4"] = max(absf(tr_of(b4).origin.x),
					absf(tr_of(b4).origin.z))
			if sample_tick():
				print("IT t=%d y0=%s pen0=%s y4=%s vmax=%s xz4=%s,%s" % [
						tick, fmt(tr_of(b0).origin.y),
						fmt(0.2 - tr_of(b0).origin.y),
						fmt(tr_of(b4).origin.y), fmt(vmax),
						fmt(tr_of(b4).origin.x), fmt(tr_of(b4).origin.z)])
	if tick >= 180 and not done:
		done = true
		var keys := peak.keys()
		keys.sort()
		var s := []
		for k in keys:
			s.append("%s=%s" % [k, fmt(peak[k])])
		print("ITSUM case=%s ticks=%d %s" % [case, tick, " ".join(s)])
		quit(0)
