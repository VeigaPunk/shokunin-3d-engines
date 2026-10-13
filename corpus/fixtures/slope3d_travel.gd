# Gravity-driven grounded slope versus intact level slab; run via run_battery.py.
extends SceneTree
const SLOPE_ANGLE := 30.0
const TICKS := 60
var frames := 0
var actor: CharacterBody3D
var slab: StaticBody3D

func _initialize() -> void:
	call_deferred("_run")

func _process(_delta: float) -> bool:
	frames += 1
	if frames > 1200:
		return _fail("frame bound exceeded")
	return false

func _run() -> void:
	var level := "--level" in OS.get_cmdline_user_args()
	var slab_box := BoxShape3D.new()
	slab_box.size = Vector3(30, 1, 20)
	var slab_shape := CollisionShape3D.new()
	slab_shape.shape = slab_box
	slab = StaticBody3D.new()
	slab.collision_layer = 1
	slab.rotation.z = deg_to_rad(0.0 if level else SLOPE_ANGLE)
	slab.add_child(slab_shape)
	root.add_child(slab)
	actor = CharacterBody3D.new()
	actor.motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
	actor.floor_stop_on_slope = false
	actor.collision_layer = 2
	actor.collision_mask = 1
	actor.position = Vector3(0, 1.5, 0)
	var actor_box := BoxShape3D.new()
	actor_box.size = Vector3.ONE
	var actor_shape := CollisionShape3D.new()
	actor_shape.shape = actor_box
	actor.add_child(actor_shape)
	root.add_child(actor)
	await physics_frame
	if slab_box.size != Vector3(30, 1, 20) or actor_box.size != Vector3.ONE or (actor.collision_mask & slab.collision_layer) == 0:
		return _fail("collision setup absent")
	var velocity_y := 0.0
	var grounded_ticks := 0
	var first_normal := Vector3.ZERO
	for tick in range(TICKS):
		velocity_y -= 12.0 / 60.0
		actor.velocity = Vector3(0, velocity_y, 0)
		actor.move_and_slide()
		velocity_y = actor.velocity.y
		if actor.is_on_floor():
			grounded_ticks += 1
			if first_normal == Vector3.ZERO:
				first_normal = actor.get_floor_normal()
		await physics_frame
	if not slab.is_inside_tree() or not actor.is_inside_tree() or not actor.is_on_floor() or actor.floor_stop_on_slope:
		return _fail("floor/policy setup lost")
	if level:
		if slab.rotation.z != 0 or absf(actor.position.x) > 0.002 or absf(actor.position.y - 1.0) > 0.003 or grounded_ticks != 44 or first_normal.distance_to(Vector3.UP) > 0.000001:
			return _fail("level control failed x=%.4f y=%.4f grounded=%d normal=%s" % [actor.position.x, actor.position.y, grounded_ticks, first_normal])
		_cleanup()
		print("NEGATIVE REJECTED: slope3d_travel level_no_downhill x=0.0000 y=1.0001 grounded_ticks=44 normal_y=1.000")
		quit(2)
		return
	if absf(rad_to_deg(slab.rotation.z) - 30.0) > 0.001 or absf(actor.position.x + 0.0810) > 0.003 or absf(actor.position.y - 1.3203) > 0.003 or grounded_ticks != 52 or first_normal.distance_to(Vector3(-0.5, 0.8660254, 0)) > 0.0001:
		return _fail("slope travel failed x=%.4f y=%.4f grounded=%d normal=%s" % [actor.position.x, actor.position.y, grounded_ticks, first_normal])
	_cleanup()
	print("PASS slope3d_travel downhill_x=-0.0810 y=1.3203 grounded_ticks=52 normal_y=0.866 stop_on_slope=false")
	quit(0)

func _cleanup() -> void:
	if is_instance_valid(actor):
		actor.free()
	if is_instance_valid(slab):
		slab.free()

func _fail(message: String) -> bool:
	_cleanup()
	push_error("slope3d_travel: " + message)
	quit(1)
	return true
