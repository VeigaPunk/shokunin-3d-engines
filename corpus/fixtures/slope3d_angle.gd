# 30-degree slope floor versus 60-degree steep contact; run via run_battery.py --only slope3d_floor,slope3d_steep.
# Direct scratch: godot --headless --path <scratch> --script res://slope3d_angle.gd [-- --steep]
# Expected exit 0 PASS slope3d_floor or exit 2 NEGATIVE REJECTED: slope3d_angle steep_contact_not_floor.
extends SceneTree
const Runner = preload("res://runner3d.gd")
const SHALLOW_ANGLE := 30.0
const STEEP_ANGLE := 60.0
const FLOOR_LIMIT := 45.0
var frames := 0

func _initialize() -> void:
	call_deferred("_run")

func _process(_delta: float) -> bool:
	frames += 1
	if frames > 1200:
		return _fail("frame bound exceeded")
	return false

func _run() -> void:
	var steep := "--steep" in OS.get_cmdline_user_args()
	var slab_box := BoxShape3D.new()
	slab_box.size = Vector3(12, 1, 12)
	var slab_shape := CollisionShape3D.new()
	slab_shape.shape = slab_box
	var slab := StaticBody3D.new()
	slab.collision_layer = 1
	slab.rotation.z = deg_to_rad(STEEP_ANGLE if steep else SHALLOW_ANGLE)
	slab.add_child(slab_shape)
	root.add_child(slab)
	var actor_box := BoxShape3D.new()
	actor_box.size = Vector3.ONE
	var actor_shape := CollisionShape3D.new()
	actor_shape.shape = actor_box
	var actor := Runner.new()
	actor.collision_layer = 2
	actor.collision_mask = 1
	actor.motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
	actor.up_direction = Vector3.UP
	actor.floor_max_angle = deg_to_rad(FLOOR_LIMIT)
	actor.position = Vector3(0, 3, 0)
	actor.drive = Vector3(0, -6, 0)
	actor.add_child(actor_shape)
	root.add_child(actor)
	await physics_frame
	if slab_box.size != Vector3(12, 1, 12) or actor_box.size != Vector3.ONE or not slab.is_inside_tree() or (actor.collision_mask & slab.collision_layer) == 0:
		return _fail("collision setup absent")
	var initial_ticks: int = actor.ticks
	for i in range(30):
		await physics_frame
		if actor.first_contact_tick > 0:
			break
	if actor.ticks - initial_ticks > 30 or actor.contacts < 1 or actor.first_contact_tick == 0:
		return _fail("no bounded live contact ticks=%d contacts=%d" % [actor.ticks - initial_ticks, actor.contacts])
	var normal := actor.first_contact_normal
	var expected_normal := Vector3(-0.8660254, 0.5, 0) if steep else Vector3(-0.5, 0.8660254, 0)
	if normal.distance_to(expected_normal) > 0.001:
		return _fail("normal mismatch normal=%s expected=%s" % [normal, expected_normal])
	if steep:
		if actor.is_on_floor() or not actor.is_on_wall():
			return _fail("steep classification floor=%s wall=%s normal=%s" % [actor.is_on_floor(), actor.is_on_wall(), normal])
		print("NEGATIVE REJECTED: slope3d_angle steep_contact_not_floor normal_y=0.500 floor_limit=45.000 on_floor=false on_wall=true live_contact=true")
		quit(2)
		return
	if not actor.is_on_floor() or actor.is_on_wall():
		return _fail("shallow classification floor=%s wall=%s normal=%s" % [actor.is_on_floor(), actor.is_on_wall(), normal])
	print("PASS slope3d_floor normal_y=0.866 floor_limit=45.000 on_floor=true on_wall=false live_contact=true")
	quit(0)

func _fail(message: String) -> bool:
	push_error("slope3d_angle: " + message)
	quit(1)
	return true
