# r96-scout probe 5: the restitution COMBINE rule for an asymmetric pair.
#
# Godot's docs say the pair bounce is the MAX of the two bodies'. Candidates:
#   max(A,B) / min(A,B) / A*B / avg(A,B) / clamp(A+B) / A-only / B-only.
# A 1 m drop gives e_apex = sqrt((apex - r) / drop_height), so the four
# candidates are far apart: e=0.8 -> 0.64 m, 0.4 -> 0.16, 0.65 -> 0.4225,
# 1.0 -> 1.0.
#
# Cases (argv[0]): ball bounce / floor bounce
#   max   0.9 / 0.0   min   0.0 / 0.9   both  0.9 / 0.9
#   mid   0.5 / 0.8   low   0.9 / 0.0 (drop 0.03 m: impact 0.767 m/s, below
#                    Jolt's bounce_velocity_threshold=1.0)
#   pair  0.9 / 0.0 head-on dynamic pair (both mass 1, closing 2 m/s each)
#   pairlow  same at closing 0.25 m/s (below the threshold)
extends SceneTree

var case := "max"
var tick := 0
var done := false
var bb := 0.9
var fb := 0.0
var drop := 1.0
var ball: RigidBody3D
var ball2: RigidBody3D
var floor_body: StaticBody3D
var floor_body2: RigidBody3D
var v_in := 0.0
var v_out := 0.0
var apex := -1e9
var contact_seen := false
var pair_mode := false
var v1_out := 0.0
var v2_out := 0.0


class Watcher extends Node:
	var probe
	func _physics_process(_d: float) -> void:
		probe.on_e()


func fmt(x: float) -> String:
	return String.num(x, 6)


func mat(bounce: float, friction := 0.6) -> PhysicsMaterial:
	var m := PhysicsMaterial.new()
	m.bounce = bounce
	m.friction = friction
	return m


func mk_static_floor(pos: Vector3, size: Vector3, bounce: float) -> StaticBody3D:
	var b := StaticBody3D.new()
	b.position = pos
	var cs := CollisionShape3D.new()
	var sh := BoxShape3D.new()
	sh.size = size
	cs.shape = sh
	b.add_child(cs)
	b.physics_material_override = mat(bounce)
	get_root().add_child(b)
	return b


func mk_ball(pos: Vector3, r: float, bounce: float) -> RigidBody3D:
	var b := RigidBody3D.new()
	b.position = pos
	b.mass = 1.0
	b.linear_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
	b.angular_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
	b.linear_damp = 0.0
	b.angular_damp = 0.0
	var cs := CollisionShape3D.new()
	var sh := SphereShape3D.new()
	sh.radius = r
	cs.shape = sh
	b.add_child(cs)
	b.physics_material_override = mat(bounce, 0.0)
	get_root().add_child(b)
	return b


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	case = args[0] if args.size() > 0 else "max"
	match case:
		"max": bb = 0.9; fb = 0.0; drop = 1.0
		"min": bb = 0.0; fb = 0.9; drop = 1.0
		"both": bb = 0.9; fb = 0.9; drop = 1.0
		"mid": bb = 0.5; fb = 0.8; drop = 1.0
		"sum": bb = 0.3; fb = 0.4; drop = 1.0
		"low": bb = 0.9; fb = 0.0; drop = 0.03
		"pair": pair_mode = true
		"pairlow": pair_mode = true
		_:
			print("R0 unknown case=%s" % case)
			quit(2)
			return
	if pair_mode:
		var v := 2.0 if case == "pair" else 0.25
		ball = mk_ball(Vector3(0, 5, -1.0), 0.3, 0.9)
		ball2 = mk_ball(Vector3(0, 5, 1.0), 0.3, 0.0)
		ball.gravity_scale = 0.0
		ball2.gravity_scale = 0.0
		ball.linear_velocity = Vector3(0, 0, v)
		ball2.linear_velocity = Vector3(0, 0, -v)
		print("R0 case=%s engine=%s pair=true v=%s bounce=%s/%s" % [case,
				str(ProjectSettings.get_setting("physics/3d/physics_engine")),
				fmt(v), fmt(bb), fmt(fb)])
	else:
		floor_body = mk_static_floor(Vector3(0, -0.25, 0),
				Vector3(10, 0.5, 10), fb)
		ball = mk_ball(Vector3(0, 0.3 + drop, 0), 0.3, bb)
		print("R0 case=%s engine=%s drop=%s bounce=%s/%s" % [case,
				str(ProjectSettings.get_setting("physics/3d/physics_engine")),
				fmt(drop), fmt(bb), fmt(fb)])
	var w := Watcher.new()
	w.probe = self
	get_root().add_child(w)


func on_e() -> void:
	tick += 1
	if pair_mode:
		var v1 := ball.linear_velocity.z
		var v2 := ball2.linear_velocity.z
		if tick == 1:
			v_in = v1
		if not contact_seen and v1 < 0.0 and tick > 2:
			contact_seen = true
			v1_out = v1
			v2_out = v2
			print("R collide_tick=%d v1=%s v2=%s" % [tick, fmt(v1), fmt(v2)])
		if tick <= 40 or tick % 40 == 0:
			print("R t=%d v1=%s v2=%s z1=%s z2=%s" % [tick, fmt(v1),
					fmt(v2), fmt(ball.global_position.z),
					fmt(ball2.global_position.z)])
		if tick >= 320 and not done:
			done = true
			print("RSUM case=%s v_in=%s v1_out=%s v2_out=%s e1=%s v1_end=%s v2_end=%s" % [
					case, fmt(v_in), fmt(v1_out), fmt(v2_out),
					fmt(-v1_out / v_in) if v_in > 0 else "n/a", fmt(v1),
					fmt(v2)])
			quit(0)
		return
	var y := ball.global_position.y
	var lv := ball.linear_velocity.y
	if lv < v_in:
		v_in = lv
	if contact_seen:
		apex = max(apex, y)
	if not contact_seen and lv > 0.0:
		contact_seen = true
		v_out = lv
	if tick <= 30 or tick % 20 == 0:
		print("R t=%d y=%s lv=%s" % [tick, fmt(y), fmt(lv)])
	if tick >= 240 and not done:
		done = true
		var e_apex := sqrt(max(apex - 0.3, 0.0) / drop) if drop > 0 else -1.0
		print("RSUM case=%s v_in=%s v_out=%s e_vel=%s apex=%s e_apex=%s" % [
				case, fmt(v_in), fmt(v_out),
				fmt(-v_out / v_in) if v_in < 0 else "n/a", fmt(apex),
				fmt(e_apex)])
		quit(0)
