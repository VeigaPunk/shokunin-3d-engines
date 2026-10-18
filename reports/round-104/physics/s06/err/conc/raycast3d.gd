# Case 4 — PhysicsDirectSpaceState3D raycast hit and discriminating miss.
#
# Reproduce (seeds are read-only; the battery copies this directory into
# corpus/live/runs/<ts>/scratch first):
#   python3 corpus/fixtures/run_battery.py                       # case raycast3d_hit
#   python3 corpus/fixtures/run_battery.py                       # case raycast3d_miss
# Direct invocation against a scratch copy of this directory:
#   godot --headless --path <scratch> --script res://raycast3d.gd
#   godot --headless --path <scratch> --script res://raycast3d.gd -- --miss-ray
#
# Expected exit signature (positive):
#   exit 0, stdout line:
#   PASS raycast3d hits=1 position=0.000,2.000,0.000 normal=0.000,1.000,0.000 collider=Wall collider_id_matches=true miss_hits=0
# Expected exit signature (negative control --miss-ray):
#   exit 2, stdout line:
#   NEGATIVE REJECTED: raycast3d miss_ray_no_hit control_hits=1 control_position=0.000,2.000,0.000 miss_from=0.000,6.000,9.000 miss_hits=0 miss_offset_z=9.000 box_half_depth_z=2.000
# Setup/script error: exit 1 with an "ERROR: raycast3d: ..." line.
#
# Hand-derived constants (not re-derived at runtime, on purpose):
#   box size (4,4,4) centred on the origin -> top face plane y = +2
#   ray (0,6,0) -> (0,-6,0) crosses that plane at (0,2,0) with face normal +Y
#   the offset ray keeps z = 9, which is 7.0 clear of the box half-depth 2.0,
#   so intersect_ray() must return an empty Dictionary
# Both arms fire the hitting control ray first, so an empty result on the offset
# ray is attributable to the offset and never to a dead physics space.
extends SceneTree

const BOX_SIZE := Vector3(4.0, 4.0, 4.0)
const HIT_FROM := Vector3(0.0, 6.0, 0.0)
const HIT_TO := Vector3(0.0, -6.0, 0.0)
const MISS_Z := 9.0
const EXPECTED_HIT := Vector3(0.0, 2.0, 0.0)
const EXPECTED_NORMAL := Vector3(0.0, 1.0, 0.0)
const SETTLE_TICKS := 4
const HIT_EPSILON := 1.0e-6
const FRAME_BOUND := 1200

var frames := 0


func _initialize() -> void:
	call_deferred("_run")


func _process(_delta: float) -> bool:
	frames += 1
	if frames > FRAME_BOUND:
		push_error("raycast3d: process bound exceeded frames=%d" % frames)
		quit(1)
		return true
	return false


func _run() -> void:
	var miss_arm := "--miss-ray" in OS.get_cmdline_user_args()
	var box := BoxShape3D.new()
	box.size = BOX_SIZE
	var wall_shape := CollisionShape3D.new()
	wall_shape.shape = box
	var wall := StaticBody3D.new()
	wall.name = "Wall"
	wall.collision_layer = 1
	wall.add_child(wall_shape)
	root.add_child(wall)
	for _i in range(SETTLE_TICKS):
		await physics_frame
	if not _setup_intact(wall, box):
		return _fail("wall collision setup is not the authored arrangement")

	var space := root.get_world_3d().direct_space_state
	var control := space.intersect_ray(
			PhysicsRayQueryParameters3D.create(HIT_FROM, HIT_TO))
	if control.is_empty():
		return _fail("control ray did not hit the authored wall")
	var control_position: Vector3 = control.get("position", Vector3.INF)
	if control_position.distance_to(EXPECTED_HIT) > HIT_EPSILON:
		return _fail("control ray hit the wrong position got=%s expected=%s"
				% [_v(control_position), _v(EXPECTED_HIT)])
	if control.get("collider") != wall or control.get("collider_id") != wall.get_instance_id():
		return _fail("control ray reported the wrong collider")
	var control_normal: Vector3 = control.get("normal", Vector3.INF)
	if miss_arm:
		return _miss_verdict(space, control_position)
	return _hit_verdict(space, control_position, control_normal, wall)


func _setup_intact(wall: StaticBody3D, box: BoxShape3D) -> bool:
	if not wall.is_inside_tree():
		return false
	if box.size != BOX_SIZE:
		return false
	if wall.collision_layer != 1 or wall.get_child_count() == 0:
		return false
	return wall.get_child(0) is CollisionShape3D


func _hit_verdict(space: PhysicsDirectSpaceState3D, control_position: Vector3, normal: Vector3, wall: StaticBody3D) -> void:
	if normal.distance_to(EXPECTED_NORMAL) > HIT_EPSILON:
		return _fail("hit normal disagrees with the authored top face normal got=%s expected=%s"
				% [_v(normal), _v(EXPECTED_NORMAL)])
	var miss := space.intersect_ray(PhysicsRayQueryParameters3D.create(
			Vector3(HIT_FROM.x, HIT_FROM.y, MISS_Z), Vector3(HIT_TO.x, HIT_TO.y, MISS_Z)))
	if not miss.is_empty() or miss.size() != 0:
		return _fail("offset ray unexpectedly hit something size=%d" % miss.size())
	print("PASS raycast3d hits=1 position=%s normal=%s collider=%s collider_id_matches=true miss_hits=0"
			% [_v(control_position), _v(normal), wall.name])
	quit(0)


func _miss_verdict(space: PhysicsDirectSpaceState3D, control_position: Vector3) -> void:
	var miss_from := Vector3(HIT_FROM.x, HIT_FROM.y, MISS_Z)
	var miss := space.intersect_ray(PhysicsRayQueryParameters3D.create(
			miss_from, Vector3(HIT_TO.x, HIT_TO.y, MISS_Z)))
	if not miss.is_empty():
		return _fail("offset ray hit the wall; the miss arm no longer discriminates size=%d" % miss.size())
	print("NEGATIVE REJECTED: raycast3d miss_ray_no_hit control_hits=1 control_position=%s miss_from=%s miss_hits=0 miss_offset_z=%s box_half_depth_z=%s"
			% [_v(control_position), _v(miss_from), _f(MISS_Z), _f(BOX_SIZE.z * 0.5)])
	quit(2)


func _fail(message: String) -> void:
	push_error("raycast3d: " + message)
	quit(1)


func _f(value: float) -> String:
	# snappedf + 0.0 keeps marker text stable: it folds -0.0 and sub-tolerance
	# noise to 0.000 while leaving genuine negatives such as -1.000 intact.
	return "%0.3f" % (snappedf(value, 0.001) + 0.0)


func _v(value: Vector3) -> String:
	return _f(value.x) + "," + _f(value.y) + "," + _f(value.z)
