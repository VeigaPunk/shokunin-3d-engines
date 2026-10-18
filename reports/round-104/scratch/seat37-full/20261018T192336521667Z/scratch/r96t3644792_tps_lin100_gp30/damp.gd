# r96-scout probe 4: the damping law. Does the per-tick decay curve have the
# same SHAPE on both backends?
#
# Candidate laws for per-tick ratio r = |v_{k+1}| / |v_k| with d = the body's
# linear_damp and dt = 1/60:
#   model A (multiplicative):  v *= (1 - d*dt)      -> r = 1 - d*dt
#   model B (reciprocal):      v *= 1/(1 + d*dt)    -> r = 1/(1 + d*dt)
# At d=10 they differ by ~2.4% (0.833333333 vs 0.857142857); at d=100 model A
# clamps to 0 while model B gives 0.375.
#
# Cases (argv[0]):
#   lin10 lin100 lin05   - linear damp, gravity off, v0=(0,0,10), REPLACE mode
#   lin0repl lin0comb    - control: node damp 0, REPLACE vs COMBINE (COMBINE
#                          should pull in physics/3d/default_linear_damp=0.1)
#   ang10                - angular damp 10, av0=(0,0,10)
#   grav10               - linear damp 10, gravity ON, released from rest
#   sleep1               - linear damp 1, v0=(0,0,0.5), can_sleep=true: when
#                          does it sleep and does the curve continue after?
extends SceneTree

var case := "lin10"
var tick := 0
var ball: RigidBody3D
var prev := 0.0
var prev_a := 0.0
var prev_lv := 0.0
var slept_at := -1
var done := false
var dt := 1.0 / 60.0


class Watcher extends Node:
	var probe
	func _physics_process(_d: float) -> void:
		probe.on_e()


func fmt(x: float) -> String:
	return String.num(x, 9)


func mk_ball(pos: Vector3, r: float, mass: float) -> RigidBody3D:
	var b := RigidBody3D.new()
	b.position = pos
	b.mass = mass
	b.can_sleep = false
	b.linear_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
	b.angular_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
	b.linear_damp = 0.0
	b.angular_damp = 0.0
	b.gravity_scale = 0.0
	var cs := CollisionShape3D.new()
	var sh := SphereShape3D.new()
	sh.radius = r
	cs.shape = sh
	b.add_child(cs)
	get_root().add_child(b)
	return b


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	case = args[0] if args.size() > 0 else "lin10"
	ball = mk_ball(Vector3(0, 5, 0), 0.2, 1.0)
	match case:
		"lin10":
			ball.linear_damp = 10.0
			ball.linear_velocity = Vector3(0, 0, 10)
		"lin100":
			ball.linear_damp = 100.0
			ball.linear_velocity = Vector3(0, 0, 10)
		"lin05":
			ball.linear_damp = 0.5
			ball.linear_velocity = Vector3(0, 0, 10)
		"lin0repl":
			ball.linear_damp = 0.0
			ball.linear_velocity = Vector3(0, 0, 10)
		"lin0comb":
			ball.linear_damp_mode = RigidBody3D.DAMP_MODE_COMBINE
			ball.linear_damp = 0.0
			ball.linear_velocity = Vector3(0, 0, 10)
		"ang10":
			ball.angular_damp = 10.0
			ball.angular_velocity = Vector3(0, 0, 10)
		"grav10":
			ball.linear_damp = 10.0
			ball.gravity_scale = 1.0
		"sleep1":
			ball.linear_damp = 1.0
			ball.can_sleep = true
			ball.linear_velocity = Vector3(0, 0, 0.5)
		_:
			print("D0 unknown case=%s" % case)
			quit(2)
			return
	var rid := ball.get_rid()
	print("D0 case=%s engine=%s dt=%.12f node_lin=%s node_ang=%s srv_lin=%s srv_ang=%s sleep_thr_lin=%s sleep_thr_ang=%s time_before_sleep=%s can_sleep=%s" % [
			case, str(ProjectSettings.get_setting("physics/3d/physics_engine")),
			dt, str(ball.linear_damp), str(ball.angular_damp),
			str(PhysicsServer3D.body_get_param(rid,
					PhysicsServer3D.BODY_PARAM_LINEAR_DAMP)),
			str(PhysicsServer3D.body_get_param(rid,
					PhysicsServer3D.BODY_PARAM_ANGULAR_DAMP)),
			str(ProjectSettings.get_setting("physics/3d/sleep_threshold_linear")),
			str(ProjectSettings.get_setting("physics/3d/sleep_threshold_angular")),
			str(ProjectSettings.get_setting("physics/3d/time_before_sleep")),
			str(ball.can_sleep)])
	var w := Watcher.new()
	w.probe = self
	get_root().add_child(w)


func on_e() -> void:
	tick += 1
	if case == "ang10":
		var av := ball.angular_velocity.z
		if tick <= 20 or tick % 10 == 0:
			print("D t=%d av=%s ratio=%s" % [tick, fmt(av),
					fmt(av / prev_a) if tick > 1 else "n/a"])
		prev_a = av
	else:
		var lv := ball.linear_velocity.z if case != "grav10" \
				else ball.linear_velocity.y
		if tick <= 20 or tick % 10 == 0:
			print("D t=%d lv=%s ratio=%s y=%s" % [tick, fmt(lv),
					fmt(lv / prev_lv) if tick > 1 and absf(prev_lv) > 1e-12
							else "n/a",
					fmt(ball.global_position.y)])
		prev_lv = lv
		if case == "sleep1":
			var sl: Variant = PhysicsServer3D.body_get_state(
					ball.get_rid(), PhysicsServer3D.BODY_STATE_SLEEPING)
			var hdl := ball.sleeping
			print("D t=%d sl=%s hdl_sleep=%s lv=%s" % [tick, str(sl),
					str(hdl), fmt(lv)])
			if bool(sl) and slept_at < 0 and tick > 1:
				slept_at = tick
	if tick >= 200 and not done:
		done = true
		print("DSUM case=%s slept_at=%d lv_end=%s y_end=%s" % [case, slept_at,
				fmt(ball.linear_velocity.z),
				fmt(ball.global_position.y)])
		quit(0)
