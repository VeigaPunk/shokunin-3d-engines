extends SceneTree
# r100-scout probe 4: lifecycle / teardown cells for the rate surface (>=6 reps).
#
# Cases (user arg): clean | quit_idle | freetree | err | noquit_bound |
#                   noquit_unbound | finalize_touch | quit_double
# Every case prints LF_* markers; the driver's `--quit-after` is the bound for
# the noquit_bound cell and the 8 s kill is the bound for noquit_unbound.

var case := "clean"
var n_e := 0
var n_f := 0
var stage: Node3D
var body: RigidBody3D


func _initialize() -> void:
	var ua := OS.get_cmdline_user_args()
	if ua.size() > 0:
		case = ua[0]
	stage = Node3D.new()
	stage.name = "Stage"
	root.add_child(stage)
	body = RigidBody3D.new()
	body.name = "Ball"
	var cs := CollisionShape3D.new()
	var sp := SphereShape3D.new()
	sp.radius = 0.5
	cs.shape = sp
	body.add_child(cs)
	body.position = Vector3(0, 5, 0)
	stage.add_child(body)
	print("LF_BOOT case=%s" % case)


func _process(_d: float) -> bool:
	n_f += 1
	if case == "quit_idle" and n_f == 3:
		print("LF_QUIT_IDLE n_f=%d ff=%d" % [n_f, Engine.get_process_frames()])
		quit(0)
	if case == "quit_double" and n_f == 2:
		print("LF_QUIT_DOUBLE_PRE ff=%d" % Engine.get_process_frames())
		quit(0)
	return false


func _physics_process(_d: float) -> bool:
	n_e += 1
	if n_e > 12 and case != "noquit_bound" and case != "noquit_unbound":
		print("LF_OVER n_e=%d" % n_e)
		quit(0)
	match case:
		"clean":
			if n_e == 5:
				print("LF_CLEAN_QUIT pf=%d ff=%d" % [Engine.get_physics_frames(),
					Engine.get_process_frames()])
				quit(0)
		"freetree":
			if n_e == 3:
				stage.free()
				print("LF_FREETREE freed pf=%d valid=%s" % [
					Engine.get_physics_frames(), is_instance_valid(stage)])
			if n_e == 6:
				print("LF_FREETREE_END pf=%d" % Engine.get_physics_frames())
				quit(0)
		"err":
			if n_e == 3:
				print("LF_ERR_PRE pf=%d" % Engine.get_physics_frames())
				var bogus = body.no_such_method_at_all()
				print("LF_ERR_POST unreachable %s" % str(bogus))
			if n_e == 6:
				print("LF_ERR_END pf=%d" % Engine.get_physics_frames())
				quit(0)
		"noquit_bound":
			print("LF_TICK n_e=%d pf=%d" % [n_e, Engine.get_physics_frames()])
		"noquit_unbound":
			print("LF_TICK n_e=%d pf=%d" % [n_e, Engine.get_physics_frames()])
		"finalize_touch":
			if n_e == 3:
				print("LF_FIN_PRE pf=%d" % Engine.get_physics_frames())
				quit(0)
		"quit_double":
			if n_e == 4:
				print("LF_AFTER_QUIT n_e=%d pf=%d" % [n_e,
					Engine.get_physics_frames()])
	return false


func _finalize() -> void:
	if case == "finalize_touch":
		print("LF_FIN_TOUCH valid=%s" % is_instance_valid(body))
		print("LF_FIN_POS %s" % str(body.global_position))
	print("LF_END case=%s n_e=%d n_f=%d" % [case, n_e, n_f])
