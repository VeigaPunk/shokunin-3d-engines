# r96-scout probe 7: kinematic vs static contact class. A dynamic ball is
# dropped onto a platform that is (a) a StaticBody3D, (b) a RigidBody3D frozen
# STATIC, (c) a RigidBody3D frozen KINEMATIC, (d) a RigidBody3D whose server
# mode is set to KINEMATIC, (e) an AnimatableBody3D. Then a resting ball is
# carried by a rising platform in three flavours, and a KINEMATIC ball
# overlapping the floor is asked for its contact count (Jolt's
# generate_all_kinematic_contacts knob).
#
# Cases (argv[0]): static kinfreeze kinstatic kinmode anim carrykin
#                  carrystatic kcontact
extends SceneTree

var case := "static"
var tick := 0
var done := false
var ball: RigidBody3D
var plat: PhysicsBody3D
var plat_rid: RID
var plat_y0 := 0.0
var cc_seen := -1


class Watcher extends Node:
	var probe
	func _physics_process(_d: float) -> void:
		probe.on_e()


func fmt(x: float) -> String:
	return String.num(x, 6)


func mk_ball(pos: Vector3, r: float, frozen := false) -> RigidBody3D:
	var b := RigidBody3D.new()
	b.position = pos
	b.mass = 1.0
	b.can_sleep = false
	b.max_contacts_reported = 8
	b.contact_monitor = true
	b.linear_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
	b.angular_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
	b.linear_damp = 0.0
	b.angular_damp = 0.0
	if frozen:
		b.freeze = true
		b.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	var cs := CollisionShape3D.new()
	var sh := SphereShape3D.new()
	sh.radius = r
	cs.shape = sh
	b.add_child(cs)
	get_root().add_child(b)
	return b


func slab(pos: Vector3, half: Vector3, kind: String) -> PhysicsBody3D:
	var b: PhysicsBody3D
	match kind:
		"static": b = StaticBody3D.new()
		"anim": b = AnimatableBody3D.new()
		_: b = RigidBody3D.new()
	if b is RigidBody3D:
		(b as RigidBody3D).gravity_scale = 0.0
		(b as RigidBody3D).mass = 1.0
		(b as RigidBody3D).can_sleep = false
		if kind == "kinfreeze":
			(b as RigidBody3D).freeze = true
			(b as RigidBody3D).freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
		elif kind == "kinstatic":
			(b as RigidBody3D).freeze = true
			(b as RigidBody3D).freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	b.position = pos
	var cs := CollisionShape3D.new()
	var sh := BoxShape3D.new()
	sh.size = half * 2.0
	cs.shape = sh
	b.add_child(cs)
	var m := PhysicsMaterial.new()
	m.bounce = 0.0
	m.friction = 0.6
	(b as CollisionObject3D).physics_material_override = m
	get_root().add_child(b)
	return b


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	case = args[0] if args.size() > 0 else "static"
	var top := 0.0
	match case:
		"static":
			plat = slab(Vector3(0, top - 0.25, 0), Vector3(5, 0.25, 5), "static")
			ball = mk_ball(Vector3(0, 0.6, 0), 0.3)
		"kinfreeze":
			plat = slab(Vector3(0, top - 0.25, 0), Vector3(5, 0.25, 5),
					"kinfreeze")
			ball = mk_ball(Vector3(0, 0.6, 0), 0.3)
		"kinstatic":
			plat = slab(Vector3(0, top - 0.25, 0), Vector3(5, 0.25, 5),
					"kinstatic")
			ball = mk_ball(Vector3(0, 0.6, 0), 0.3)
		"kinmode":
			plat = slab(Vector3(0, top - 0.25, 0), Vector3(5, 0.25, 5),
					"rigidmode")
			ball = mk_ball(Vector3(0, 0.6, 0), 0.3)
		"anim":
			plat = slab(Vector3(0, top - 0.25, 0), Vector3(5, 0.25, 5), "anim")
			ball = mk_ball(Vector3(0, 0.6, 0), 0.3)
		"carrykin":
			plat = slab(Vector3(0, top - 0.25, 0), Vector3(5, 0.25, 5),
					"kinfreeze")
			ball = mk_ball(Vector3(0, 0.61, 0), 0.3)
		"carrystatic":
			plat = slab(Vector3(0, top - 0.25, 0), Vector3(5, 0.25, 5),
					"static")
			ball = mk_ball(Vector3(0, 0.61, 0), 0.3)
		"kcontact":
			plat = slab(Vector3(0, top - 0.25, 0), Vector3(5, 0.25, 5),
					"static")
			ball = mk_ball(Vector3(0, 0.1, 0), 0.3, true)
		_:
			print("K0 unknown case=%s" % case)
			quit(2)
			return
	plat_rid = plat.get_rid()
	plat_y0 = plat.global_position.y
	print("K0 case=%s engine=%s plat=%s mode=%s freeze=%s freeze_mode=%s gen_kin_contacts=%s" % [
			case, str(ProjectSettings.get_setting("physics/3d/physics_engine")),
			plat.get_class(), str(PhysicsServer3D.body_get_mode(plat_rid)),
			str(plat is RigidBody3D and (plat as RigidBody3D).freeze),
			str((plat as RigidBody3D).freeze_mode) if plat is RigidBody3D
					else "n/a",
			str(ProjectSettings.get_setting(
					"physics/jolt_physics_3d/simulation/generate_all_kinematic_contacts"))])
	var w := Watcher.new()
	w.probe = self
	get_root().add_child(w)


func contacts_of(rid: RID) -> int:
	var st: Variant = PhysicsServer3D.body_get_direct_state(rid)
	if st == null:
		return -2
	return (st as PhysicsDirectBodyState3D).get_contact_count()


func on_e() -> void:
	tick += 1
	if case == "kinmode" and tick == 2:
		PhysicsServer3D.body_set_mode(plat_rid, PhysicsServer3D.BODY_MODE_KINEMATIC)
		print("K mode_set t=2 readback=%d" % PhysicsServer3D.body_get_mode(
				plat_rid))
	if case == "carrykin" and tick > 30 and tick <= 90:
		plat.global_position = Vector3(0, plat_y0 + (tick - 30) * 0.008333,
				0)
	if case == "carrystatic" and tick == 31:
		(plat as StaticBody3D).constant_linear_velocity = Vector3(0, 0.5, 0)
	match case:
		"kcontact":
			var cc := contacts_of(ball.get_rid())
			if cc > 0 and cc_seen < 0:
				cc_seen = tick
				print("K kcontact first_cc t=%d cc=%d" % [tick, cc])
			if tick <= 20 or tick % 20 == 0:
				print("K t=%d kin_cc=%d mode=%d y=%s" % [tick, cc,
						PhysicsServer3D.body_get_mode(ball.get_rid()),
						fmt(ball.global_position.y)])
		_:
			var cc := contacts_of(ball.get_rid())
			if tick <= 20 or tick % 20 == 0 or (tick >= 28 and tick <= 75
					and case.begins_with("carry")):
				print("K t=%d cc=%d mode=%d y=%s lv=%s plat_y=%s" % [tick, cc,
						PhysicsServer3D.body_get_mode(plat_rid),
						fmt(ball.global_position.y),
						fmt(ball.linear_velocity.y),
						fmt(plat.global_position.y)])
	if tick >= 150 and not done:
		done = true
		print("KSUM case=%s y_end=%s lv_end=%s cc_end=%d plat_y_end=%s kin_first_cc=%d" % [
				case, fmt(ball.global_position.y),
				fmt(ball.linear_velocity.y),
				contacts_of(ball.get_rid()),
				fmt(plat.global_position.y), cc_seen])
		quit(0)
