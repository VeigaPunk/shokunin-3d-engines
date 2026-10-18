# r96-scout probe 6: warm starting / contact history. Neither backend exposes a
# "warm starting" boolean; the nearest knobs are
#   Jolt:  physics/jolt_physics_3d/simulation/body_pair_contact_cache_enabled
#   GP:    physics/3d/solver/contact_recycle_radius (contact caching radius)
# plus the contact cache thresholds. This probe measures the observable
# consequence of contact history: the per-tick contact IMPULSE of a settled
# ball (read in _integrate_forces) and what happens when the contact is broken
# for exactly one tick and re-made.
#
# Cases (argv[0]):
#   rest  - ball settles on the floor, then 80 ticks of impulse trace
#   break - same, but the floor is teleported 0.1 m down for ONE tick at t=100
#           and back: the contact is destroyed and re-created
#   stack - 3-box tower: bottom-contact impulse trace + tower speed
extends SceneTree

var case := "rest"
var tick := 0
var done := false
var ball: RigidBody3D
var floor_body: StaticBody3D
var boxes: Array = []
var if_cc := -1
var if_imp := Vector3.ZERO
var if_tick := 0


class RB extends RigidBody3D:
	var probe
	func _integrate_forces(st: PhysicsDirectBodyState3D) -> void:
		probe.on_if(st)


class Watcher extends Node:
	var probe
	func _physics_process(_d: float) -> void:
		probe.on_e()


func fmt(x: float) -> String:
	return String.num(x, 9)


func v3(v: Vector3) -> String:
	return "%.6f,%.6f,%.6f" % [v.x, v.y, v.z]


func mk_ball(pos: Vector3, r: float) -> RigidBody3D:
	var b := RB.new()
	b.probe = self
	b.position = pos
	b.mass = 1.0
	b.can_sleep = false
	b.max_contacts_reported = 8
	b.contact_monitor = true
	b.linear_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
	b.angular_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
	b.linear_damp = 0.0
	b.angular_damp = 0.0
	var cs := CollisionShape3D.new()
	var sh := SphereShape3D.new()
	sh.radius = r
	cs.shape = sh
	b.add_child(cs)
	get_root().add_child(b)
	return b


func mk_box(pos: Vector3, half: Vector3) -> RigidBody3D:
	var b := RB.new()
	b.probe = self
	b.position = pos
	b.mass = 1.0
	b.can_sleep = false
	b.max_contacts_reported = 8
	b.contact_monitor = true
	b.linear_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
	b.angular_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
	b.linear_damp = 0.0
	b.angular_damp = 0.0
	var cs := CollisionShape3D.new()
	var sh := BoxShape3D.new()
	sh.size = half * 2.0
	cs.shape = sh
	b.add_child(cs)
	get_root().add_child(b)
	return b


func mk_floor() -> StaticBody3D:
	var b := StaticBody3D.new()
	b.position = Vector3(0, -0.25, 0)
	var cs := CollisionShape3D.new()
	var sh := BoxShape3D.new()
	sh.size = Vector3(10, 0.5, 10)
	cs.shape = sh
	b.add_child(cs)
	var m := PhysicsMaterial.new()
	m.bounce = 0.0
	m.friction = 0.6
	b.physics_material_override = m
	get_root().add_child(b)
	return b


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	case = args[0] if args.size() > 0 else "rest"
	floor_body = mk_floor()
	match case:
		"rest", "break":
			ball = mk_ball(Vector3(0, 0.6, 0), 0.3)
		"stack":
			for i in 3:
				var b := mk_box(Vector3(0, 0.202 + 0.402 * i, 0),
						Vector3(0.2, 0.2, 0.2))
				boxes.append(b)
			ball = boxes[0]
		_:
			print("W0 unknown case=%s" % case)
			quit(2)
			return
	print("W0 case=%s engine=%s cache=%s cache_angle=%s cache_dist=%s recycle=%s max_sep=%s" % [
			case, str(ProjectSettings.get_setting("physics/3d/physics_engine")),
			str(ProjectSettings.get_setting(
					"physics/jolt_physics_3d/simulation/body_pair_contact_cache_enabled")),
			str(ProjectSettings.get_setting(
					"physics/jolt_physics_3d/simulation/body_pair_contact_cache_angle_threshold")),
			str(ProjectSettings.get_setting(
					"physics/jolt_physics_3d/simulation/body_pair_contact_cache_distance_threshold")),
			str(ProjectSettings.get_setting(
					"physics/3d/solver/contact_recycle_radius")),
			str(ProjectSettings.get_setting(
					"physics/3d/solver/contact_max_separation"))])
	var w := Watcher.new()
	w.probe = self
	get_root().add_child(w)


func on_if(st: PhysicsDirectBodyState3D) -> void:
	if_cc = st.get_contact_count()
	if if_cc > 0:
		if_imp = st.get_contact_impulse(0)
	else:
		if_imp = Vector3.ZERO
	if_tick = tick + 1   # IF runs before _physics_process in the same tick


func on_e() -> void:
	tick += 1
	if case == "break" and tick == 100:
		floor_body.global_position = Vector3(0, -0.35, 0)
	if case == "break" and tick == 101:
		floor_body.global_position = Vector3(0, -0.25, 0)
	if case == "stack":
		var vmax := 0.0
		for b in boxes:
			vmax = max(vmax, (b as RigidBody3D).linear_velocity.length())
		if tick >= 60:
			print("W t=%d cc=%d imp=%s y0=%s vmax=%s" % [tick, if_cc,
					v3(if_imp), fmt(boxes[0].global_position.y),
					fmt(vmax)])
		if tick >= 140 and not done:
			done = true
			print("WSUM case=stack ticks=%d" % tick)
			quit(0)
		return
	if tick >= 60:
		print("W t=%d cc=%d imp=%s y=%s lv=%s" % [tick, if_cc, v3(if_imp),
				fmt(ball.global_position.y),
				fmt(ball.linear_velocity.y)])
	if tick >= 140 and not done:
		done = true
		print("WSUM case=%s ticks=%d y_end=%s" % [case, tick,
				fmt(ball.global_position.y)])
		quit(0)
