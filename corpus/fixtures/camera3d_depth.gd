# Round 7: Camera3D rotated world point versus far-plane depth gate.
# Reproduce via run_battery.py --only camera3d_depth,camera3d_depth_far
# Direct scratch invocation: godot --headless --path <scratch> --script res://camera3d_depth.gd [-- --far-point]
# Positive exit 0 stdout: PASS camera3d_depth camera=10.000,0.000,0.000 visible=14.000,1.000,2.000 screen=550.000,225.000 depth=4.000 far=10.000 near=1.000
# Negative exit 2 stdout: NEGATIVE REJECTED: camera3d_depth far_point_depth=12.000 screen=550.000,225.000 in_frustum=false behind=false near_control_visible=true
# Rendering and GPU culling are NOT tested. Viewpoint at (10,0,0) looks +X via Y=-90°;
# local (2,1,-4) -> world (14,1,2). fov90, aspect4/3 gives (550,225).
# Far local (6,3,-12) -> world (22,3,6), same pixel (550,225) despite depth12 > far10.
extends SceneTree

const VIEWPORT := Vector2i(800, 600)
const FOV := 90.0
const NEAR := 1.0
const FAR := 10.0
const CAMERA_POS := Vector3(10.0, 0.0, 0.0)
const LOCAL_VISIBLE := Vector3(2.0, 1.0, -4.0)
const LOCAL_FAR := Vector3(6.0, 3.0, -12.0)
const EXPECTED_VISIBLE := Vector3(14.0, 1.0, 2.0)
const EXPECTED_FAR := Vector3(22.0, 3.0, 6.0)
const EXPECTED_SCREEN := Vector2(550.0, 225.0)
const EPS := 1.0e-4
const FRAME_BOUND := 1200

var frames := 0

func _initialize() -> void:
	call_deferred("_run")

func _process(_delta: float) -> bool:
	frames += 1
	if frames > FRAME_BOUND:
		push_error("camera3d_depth: process bound exceeded")
		quit(1)
		return true
	return false

func _run() -> void:
	var viewport := SubViewport.new()
	viewport.size = VIEWPORT
	root.add_child(viewport)
	var camera := Camera3D.new()
	camera.position = CAMERA_POS
	camera.rotation.y = -PI / 2.0
	camera.fov = FOV
	camera.near = NEAR
	camera.far = FAR
	camera.keep_aspect = Camera3D.KEEP_HEIGHT
	viewport.add_child(camera)
	camera.make_current()
	await process_frame
	await process_frame
	if not camera.is_inside_tree() or not camera.is_current() or viewport.size != VIEWPORT:
		return _fail("camera/viewport setup absent")
	if absf(camera.near - NEAR) > EPS or absf(camera.far - FAR) > EPS:
		return _fail("near/far setup differs")
	var visible := camera.to_global(LOCAL_VISIBLE)
	var far_point := camera.to_global(LOCAL_FAR)
	if visible.distance_to(EXPECTED_VISIBLE) > EPS or far_point.distance_to(EXPECTED_FAR) > EPS:
		return _fail("rotated/translated camera coordinates mismatch visible=%s far=%s" % [_v3(visible), _v3(far_point)])
	var near_control := camera.to_global(Vector3(0.0, 0.0, -2.0))
	var visible_screen := camera.unproject_position(visible)
	if visible_screen.distance_to(EXPECTED_SCREEN) > EPS or camera.is_position_behind(visible) or not camera.is_position_in_frustum(visible):
		return _fail("visible control projection/frustum failed screen=%s" % _v2(visible_screen))
	if not camera.is_position_in_frustum(near_control):
		return _fail("nearer control outside frustum")
	if "--far-point" in OS.get_cmdline_user_args():
		var far_screen := camera.unproject_position(far_point)
		if far_screen.distance_to(EXPECTED_SCREEN) > EPS or camera.is_position_behind(far_point) or camera.is_position_in_frustum(far_point):
			return _fail("far point did not project to same pixel outside far plane screen=%s" % _v2(far_screen))
		print("NEGATIVE REJECTED: camera3d_depth far_point_depth=12.000 screen=550.000,225.000 in_frustum=false behind=false near_control_visible=true")
		quit(2)
		return
	print("PASS camera3d_depth camera=10.000,0.000,0.000 visible=14.000,1.000,2.000 screen=550.000,225.000 depth=4.000 far=10.000 near=1.000")
	quit(0)

func _fail(message: String) -> void:
	push_error("camera3d_depth: " + message)
	quit(1)

func _v2(v: Vector2) -> String:
	return "%0.3f,%0.3f" % [v.x, v.y]

func _v3(v: Vector3) -> String:
	return "%0.3f,%0.3f,%0.3f" % [v.x, v.y, v.z]
