# Floor/wall classification boundary at floor_max_angle=45 deg (r108). Godot's CharacterBody3D
# classifies a contact as floor when its angle <= floor_max_angle + FLOOR_ANGLE_THRESHOLD (0.01 rad),
# so the effective boundary sits at 45.573 deg, not 45. Run via run_battery.py --only slope3d_bound_naive,
# slope3d_bound_in,slope3d_bound_edge_in,slope3d_bound_edge_out,slope3d_bound_out.
# Direct scratch: godot --headless --path <scratch> --script res://slope3d_boundary.gd -- --tilt <deg>
# Expected exit 0 PASS slope3d_boundary (floor) or exit 2 NEGATIVE REJECTED: slope3d_boundary above_threshold (wall).
extends SceneTree
const Runner = preload("res://runner3d.gd")
const FLOOR_LIMIT := 45.0
const ENGINE_FLOOR_ANGLE_THRESHOLD := 0.01
var frames := 0

func _initialize() -> void:
	call_deferred("_run")

func _process(_delta: float) -> bool:
	frames += 1
	if frames > 1200:
		return _fail("frame bound exceeded")
	return false

func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var at := args.find("--tilt")
	if at < 0 or at + 1 >= args.size() or not args[at + 1].is_valid_float():
		return _fail("missing --tilt <deg>")
	var tilt := args[at + 1].to_float()
	var slab_box := BoxShape3D.new()
	slab_box.size = Vector3(12, 1, 12)
	var slab_shape := CollisionShape3D.new()
	slab_shape.shape = slab_box
	var slab := StaticBody3D.new()
	slab.collision_layer = 1
	slab.rotation.z = deg_to_rad(tilt)
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
	var expected_normal := Vector3(-sin(deg_to_rad(tilt)), cos(deg_to_rad(tilt)), 0)
	if normal.distance_to(expected_normal) > 0.001:
		return _fail("normal mismatch normal=%s expected=%s" % [normal, expected_normal])
	var observed_limit := rad_to_deg(actor.floor_max_angle)
	var observed_tilt := rad_to_deg(slab.rotation.z)
	if absf(observed_limit - FLOOR_LIMIT) > 0.001 or absf(observed_tilt - tilt) > 0.001:
		return _fail("setting mismatch floor_limit=%.3f tilt=%.3f expected_tilt=%.3f" % [observed_limit, observed_tilt, tilt])
	var normal_deg := rad_to_deg(acos(clampf(normal.dot(Vector3.UP), -1.0, 1.0)))
	var threshold_deg := rad_to_deg(deg_to_rad(FLOOR_LIMIT) + ENGINE_FLOOR_ANGLE_THRESHOLD)
	var on_floor := actor.is_on_floor()
	var on_wall := actor.is_on_wall()
	var fields := "tilt=%.3f normal_deg=%.4f limit=%.3f threshold_deg=%.4f on_floor=%s on_wall=%s live_contact=%s" % [tilt, normal_deg, observed_limit, threshold_deg, str(on_floor), str(on_wall), str(actor.contacts >= 1)]
	if on_floor and not on_wall:
		print("PASS slope3d_boundary " + fields)
		quit(0)
		return
	if on_wall and not on_floor:
		print("NEGATIVE REJECTED: slope3d_boundary above_threshold " + fields)
		quit(2)
		return
	_fail("ambiguous classification " + fields)

func _fail(message: String) -> bool:
	push_error("slope3d_boundary: " + message)
	quit(1)
	return true
