# r96-scout probe 3: contact penetration recovery — the constants each backend
# actually obeys.
#
# GP knobs:   physics/3d/solver/contact_max_allowed_penetration (0.01),
#             default_contact_bias (0.8), contact_max_separation (0.05),
#             contact_recycle_radius (0.01)
# Jolt knobs: simulation/penetration_slop (0.02),
#             baumgarte_stabilization_factor (0.2),
#             speculative_contact_distance (0.02)
#
# Cases (argv[0]):
#   overlap   - two dynamic spheres r=0.5 spawned 0.7 apart (0.3 overlap), no
#               gravity: the depenetration curve
#   staticpen - dynamic sphere r=0.5 spawned 0.3 m inside a static floor top
#   rest      - ball dropped 1.0 m onto the floor: residual penetration at rest
#               and the approach trace
#   approach  - ball at 0.03 m above the floor with lv=(0,-0.3,0), no gravity:
#               the y at which the velocity is first modified (speculative
#               contact distance)
extends SceneTree

var case := "overlap"
var tick := 0
var done := false
var b1: RigidBody3D
var b2: RigidBody3D
var floor_body: StaticBody3D
var vmin := 0.0
var first_mod_tick := -1
var first_mod_y := 0.0
var y0 := 0.0
var pen_min := 1e9
var v0 := 0.0


class Watcher extends Node:
	var probe
	func _physics_process(_d: float) -> void:
		probe.on_e()


func fmt(x: float) -> String:
	return String.num(x, 6)


func mk_ball(pos: Vector3, r: float, grav: float) -> RigidBody3D:
	var b := RigidBody3D.new()
	b.position = pos
	b.mass = 1.0
	b.gravity_scale = grav
	b.can_sleep = false
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


func mk_floor(top: float, bounce := 0.0, friction := 0.6) -> StaticBody3D:
	var b := StaticBody3D.new()
	b.position = Vector3(0, top - 0.25, 0)
	var cs := CollisionShape3D.new()
	var sh := BoxShape3D.new()
	sh.size = Vector3(10, 0.5, 10)
	cs.shape = sh
	b.add_child(cs)
	var m := PhysicsMaterial.new()
	m.bounce = bounce
	m.friction = friction
	b.physics_material_override = m
	get_root().add_child(b)
	return b


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	case = args[0] if args.size() > 0 else "overlap"
	match case:
		"overlap":
			b1 = mk_ball(Vector3(0, 0, 0), 0.5, 0.0)
			b2 = mk_ball(Vector3(0.7, 0, 0), 0.5, 0.0)
			print("P0 case=overlap overlap0=0.300000 r=0.5 g=0")
		"staticpen":
			floor_body = mk_floor(0.0)
			b1 = mk_ball(Vector3(0, -0.2, 0), 0.5, 0.0)
			print("P0 case=staticpen inside0=0.300000 r=0.5 g=0")
		"rest":
			floor_body = mk_floor(0.0)
			b1 = mk_ball(Vector3(0, 1.5, 0), 0.5, 1.0)
			y0 = 1.5
			print("P0 case=rest drop=1.000000 r=0.5 g=9.8")
		"approach":
			floor_body = mk_floor(0.0)
			b1 = mk_ball(Vector3(0, 0.53, 0), 0.5, 0.0)
			b1.linear_velocity = Vector3(0, -0.3, 0)
			v0 = b1.linear_velocity.y
			print("P0 case=approach y0=0.530000 r=0.5 v0=%s" % fmt(v0))
		_:
			print("P0 unknown case=%s" % case)
			quit(2)
			return
	print("P0 engine=%s max_allowed_pen=%s contact_bias=%s max_sep=%s recycle=%s slop=%s baumgarte=%s spec_dist=%s" % [
			str(ProjectSettings.get_setting("physics/3d/physics_engine")),
			str(ProjectSettings.get_setting(
					"physics/3d/solver/contact_max_allowed_penetration")),
			str(ProjectSettings.get_setting(
					"physics/3d/solver/default_contact_bias")),
			str(ProjectSettings.get_setting(
					"physics/3d/solver/contact_max_separation")),
			str(ProjectSettings.get_setting(
					"physics/3d/solver/contact_recycle_radius")),
			str(ProjectSettings.get_setting(
					"physics/jolt_physics_3d/simulation/penetration_slop")),
			str(ProjectSettings.get_setting(
					"physics/jolt_physics_3d/simulation/baumgarte_stabilization_factor")),
			str(ProjectSettings.get_setting(
					"physics/jolt_physics_3d/simulation/speculative_contact_distance"))])
	var w := Watcher.new()
	w.probe = self
	get_root().add_child(w)


func on_e() -> void:
	tick += 1
	match case:
		"overlap":
			var sep := b1.global_position.distance_to(b2.global_position) - 1.0
			if tick <= 20 or tick % 10 == 0:
				print("P t=%d sep=%s lv1x=%s lv2x=%s x1=%s x2=%s" % [tick,
						fmt(sep), fmt(b1.linear_velocity.x),
						fmt(b2.linear_velocity.x),
						fmt(b1.global_position.x),
						fmt(b2.global_position.x)])
		"staticpen":
			var y := b1.global_position.y
			if tick <= 20 or tick % 10 == 0:
				print("P t=%d y=%s lv=%s pen=%s" % [tick, fmt(y),
						fmt(b1.linear_velocity.y), fmt(0.5 - y)])
		"rest":
			var y := b1.global_position.y
			var pen := 0.5 - y
			pen_min = min(pen_min, pen)
			if tick >= 55 and tick <= 75 or tick % 40 == 0:
				print("P t=%d y=%s lv=%s pen=%s" % [tick, fmt(y),
						fmt(b1.linear_velocity.y), fmt(pen)])
			if tick >= 240 and not done:
				done = true
				print("PSUM case=rest pen_min=%s y_end=%s pen_end=%s vmin=%s" % [
						fmt(pen_min), fmt(y), fmt(pen), fmt(vmin)])
				quit(0)
		"approach":
			var y := b1.global_position.y
			var lv := b1.linear_velocity.y
			if first_mod_tick < 0 and absf(lv - v0) > 1e-9:
				first_mod_tick = tick
				first_mod_y = y
				print("P first_mod t=%d y=%s gap=%s lv=%s" % [tick, fmt(y),
						fmt(y - 0.5), fmt(lv)])
			if tick <= 30 or tick % 20 == 0:
				print("P t=%d y=%s gap=%s lv=%s" % [tick, fmt(y),
						fmt(y - 0.5), fmt(lv)])
			if tick >= 120 and not done:
				done = true
				print("PSUM case=approach first_mod_tick=%d first_mod_y=%s first_mod_gap=%s y_end=%s lv_end=%s" % [
						first_mod_tick, fmt(first_mod_y),
						fmt(first_mod_y - 0.5), fmt(y), fmt(lv)])
				quit(0)
	if case in ["overlap", "staticpen"] and tick >= 120 and not done:
		done = true
		if case == "overlap":
			print("PSUM case=overlap sep_end=%s lv1_end=%s lv2_end=%s" % [
					fmt(b1.global_position.distance_to(b2.global_position)
							- 1.0), fmt(b1.linear_velocity.x),
					fmt(b2.linear_velocity.x)])
		else:
			print("PSUM case=staticpen y_end=%s pen_end=%s lv_end=%s" % [
					fmt(b1.global_position.y),
					fmt(0.5 - b1.global_position.y),
					fmt(b1.linear_velocity.y)])
		quit(0)
