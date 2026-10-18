# r96-scout probe 8: the node-body joint trap. A joint created through the
# PhysicsServer3D API binds or is silently dropped depending on WHEN it is
# created relative to the body's space assignment:
# GodotPhysicsServer3D::body_set_space() calls body->clear_constraint_map(),
# and a node body's space is assigned on tree entry / first frame, not in
# _initialize(). Cases (argv[0]):
#   node_init  - node bodies, joint made in _initialize()      (expect: dropped)
#   node_late  - node bodies, joint made at tick 2             (expect: binds)
#   srv        - server bodies, explicit body_set_space        (expect: binds)
extends SceneTree

var case := "node_init"
var tick := 0
var b_rid: RID
var a_rid: RID
var joint: RID
var a_pos := Vector3(0, 3, 0)
var made := false


class Watcher extends Node:
	var probe
	func _physics_process(_d: float) -> void:
		probe.on_e()


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	case = args[0] if args.size() > 0 else "node_init"
	var space := root.world_3d.space
	if case == "srv":
		var a_shape := PhysicsServer3D.box_shape_create()
		PhysicsServer3D.shape_set_data(a_shape, Vector3(0.1, 0.1, 0.1))
		a_rid = PhysicsServer3D.body_create()
		PhysicsServer3D.body_set_mode(a_rid, PhysicsServer3D.BODY_MODE_STATIC)
		PhysicsServer3D.body_add_shape(a_rid, a_shape)
		PhysicsServer3D.body_set_space(a_rid, space)
		PhysicsServer3D.body_set_state(a_rid,
				PhysicsServer3D.BODY_STATE_TRANSFORM,
				Transform3D(Basis(), a_pos))
		var s := PhysicsServer3D.sphere_shape_create()
		PhysicsServer3D.shape_set_data(s, 0.5)
		b_rid = PhysicsServer3D.body_create()
		PhysicsServer3D.body_set_mode(b_rid, PhysicsServer3D.BODY_MODE_RIGID)
		PhysicsServer3D.body_add_shape(b_rid, s)
		PhysicsServer3D.body_set_space(b_rid, space)
		PhysicsServer3D.body_set_state(b_rid,
				PhysicsServer3D.BODY_STATE_TRANSFORM,
				Transform3D(Basis(), Vector3(0, 2, 0)))
	else:
		var a := StaticBody3D.new()
		a.position = a_pos
		var cs := CollisionShape3D.new()
		var sh := BoxShape3D.new()
		sh.size = Vector3(0.2, 0.2, 0.2)
		cs.shape = sh
		a.add_child(cs)
		root.add_child(a)
		var b := RigidBody3D.new()
		b.position = Vector3(0, 2, 0)
		var cs2 := CollisionShape3D.new()
		var sh2 := SphereShape3D.new()
		sh2.radius = 0.5
		cs2.shape = sh2
		b.add_child(cs2)
		root.add_child(b)
		a_rid = a.get_rid()
		b_rid = b.get_rid()
	joint = PhysicsServer3D.joint_create()
	if case == "node_init" or case == "srv":
		PhysicsServer3D.joint_make_pin(joint, a_rid, Vector3.ZERO, b_rid,
				Vector3.ZERO)
		made = true
	print("J0 case=%s engine=%s type=%s space_a=%s space_b=%s world_space=%s" % [
			case, str(ProjectSettings.get_setting("physics/3d/physics_engine")),
			str(PhysicsServer3D.joint_get_type(joint)),
			str(PhysicsServer3D.body_get_space(a_rid)),
			str(PhysicsServer3D.body_get_space(b_rid)), str(space)])
	var w := Watcher.new()
	w.probe = self
	root.add_child(w)


func on_e() -> void:
	tick += 1
	if case == "node_late" and tick == 2:
		PhysicsServer3D.joint_make_pin(joint, a_rid, Vector3.ZERO, b_rid,
				Vector3.ZERO)
		made = true
		print("J made_at_tick2 type=%s space_b=%s" % [
				str(PhysicsServer3D.joint_get_type(joint)),
				str(PhysicsServer3D.body_get_space(b_rid))])
	var t: Variant = PhysicsServer3D.body_get_state(b_rid,
			PhysicsServer3D.BODY_STATE_TRANSFORM)
	var y: float = (t as Transform3D).origin.y if t is Transform3D else -999.0
	print("J t=%d y=%s made=%s" % [tick, String.num(y, 6), str(made)])
	if tick >= 12:
		quit(0)
