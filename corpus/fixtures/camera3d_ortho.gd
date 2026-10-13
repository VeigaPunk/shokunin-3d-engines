# Orthographic Camera3D same pixels at two positive depths with lateral rejection.
# run_battery.py --only camera3d_ortho,camera3d_ortho_outside
extends SceneTree
const VIEWPORT := Vector2i(800, 600)
const ORTHO_SIZE := 8.0
const FRONT := Vector3(2, 1, -4)
const DEEP := Vector3(2, 1, -8)
const OUTSIDE := Vector3(6, 1, -4)
const NEAR_POINT := Vector3(2, 1, -0.5)
const NEAR_INSIDE := Vector3(2, 1, -1.01)
const NEAR_EXACT := Vector3(2, 1, -1.0)
const NEAR_OUTSIDE := Vector3(2, 1, -0.99)
const FAR_INSIDE := Vector3(2, 1, -9.99)
const FAR_EXACT := Vector3(2, 1, -10.0)
const FAR_OUTSIDE := Vector3(2, 1, -10.01)
const FAR_POINT := Vector3(2, 1, -12)
var frames := 0
var active_viewport: SubViewport

func _initialize() -> void:
	call_deferred("_run")

func _process(_delta: float) -> bool:
	frames += 1
	if frames > 1200:
		return _fail("frame bound exceeded")
	return false

func _run() -> void:
	var outside := "--outside" in OS.get_cmdline_user_args()
	var near_point := "--near-point" in OS.get_cmdline_user_args()
	var far_point := "--far-point" in OS.get_cmdline_user_args()
	var near_inside := "--near-boundary-inside" in OS.get_cmdline_user_args()
	var near_exact := "--near-boundary-exact" in OS.get_cmdline_user_args()
	var near_outside := "--near-boundary-outside" in OS.get_cmdline_user_args()
	var far_inside := "--far-boundary-inside" in OS.get_cmdline_user_args()
	var far_exact := "--far-boundary-exact" in OS.get_cmdline_user_args()
	var far_outside := "--far-boundary-outside" in OS.get_cmdline_user_args()
	var viewport := SubViewport.new()
	viewport.size = VIEWPORT
	root.add_child(viewport)
	active_viewport = viewport
	var camera := Camera3D.new()
	camera.keep_aspect = Camera3D.KEEP_HEIGHT
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = ORTHO_SIZE
	camera.near = 1.0
	camera.far = 10.0
	viewport.add_child(camera)
	camera.make_current()
	await process_frame
	await process_frame
	if viewport.size != VIEWPORT or camera.projection != Camera3D.PROJECTION_ORTHOGONAL or absf(camera.size - 8.0) > 0.000001 or absf(camera.near - 1.0) > 0.000001 or absf(camera.far - 10.0) > 0.000001:
		return _fail("viewport/projection setting mismatch")
	var near_screen := camera.unproject_position(FRONT)
	var deep_screen := camera.unproject_position(DEEP)
	if near_screen.distance_to(Vector2(550, 225)) > 0.0001 or deep_screen.distance_to(Vector2(550, 225)) > 0.0001:
		return _fail("depth-invariant projection mismatch near=%s deep=%s" % [near_screen, deep_screen])
	if camera.is_position_behind(FRONT) or camera.is_position_behind(DEEP) or not camera.is_position_in_frustum(FRONT) or not camera.is_position_in_frustum(DEEP):
		return _fail("two valid depth controls rejected")
	if near_exact:
		var exact_screen := camera.unproject_position(NEAR_EXACT)
		var exact_frustum := camera.is_position_in_frustum(NEAR_EXACT)
		var exact_behind := camera.is_position_behind(NEAR_EXACT)
		var inside_frustum := camera.is_position_in_frustum(NEAR_INSIDE)
		var outside_frustum := camera.is_position_in_frustum(NEAR_OUTSIDE)
		if exact_screen.distance_to(Vector2(550, 225)) > 0.0001 or camera.unproject_position(NEAR_INSIDE).distance_to(exact_screen) > 0.0001 or camera.unproject_position(NEAR_OUTSIDE).distance_to(exact_screen) > 0.0001 or not inside_frustum or outside_frustum:
			return _fail("near exact setup failed screen=%s inside=%s outside=%s" % [exact_screen, inside_frustum, outside_frustum])
		if not exact_frustum or exact_behind:
			return _fail("near exact measured contradiction depth=%.3f in_frustum=%s api_behind=%s" % [-NEAR_EXACT.z, exact_frustum, exact_behind])
		_cleanup()
		print("PASS camera3d_ortho near_boundary_exact depth=%.3f screen=550.000,225.000 in_frustum=%s api_behind=%s inside_control=true outside_control=false" % [-NEAR_EXACT.z, str(exact_frustum), str(exact_behind)])
		quit(0)
		return
	if near_inside or near_outside:
		var inside_screen := camera.unproject_position(NEAR_INSIDE)
		var outside_screen := camera.unproject_position(NEAR_OUTSIDE)
		var inside_frustum := camera.is_position_in_frustum(NEAR_INSIDE)
		var outside_frustum := camera.is_position_in_frustum(NEAR_OUTSIDE)
		var control_frustum := camera.is_position_in_frustum(NEAR_POINT)
		var inside_behind := camera.is_position_behind(NEAR_INSIDE)
		var outside_behind := camera.is_position_behind(NEAR_OUTSIDE)
		if inside_screen.distance_to(Vector2(550, 225)) > 0.0001 or outside_screen.distance_to(inside_screen) > 0.0001 or control_frustum or not inside_frustum or inside_behind:
			return _fail("near boundary setup failed inside_screen=%s outside_screen=%s inside_frustum=%s control_frustum=%s" % [inside_screen, outside_screen, inside_frustum, control_frustum])
		if near_outside:
			if outside_frustum:
				return _fail("near outside sample entered frustum measured_depth=%.3f in_frustum=%s" % [-NEAR_OUTSIDE.z, outside_frustum])
			_cleanup()
			print("NEGATIVE REJECTED: camera3d_ortho near_boundary_outside depth=%.3f screen=550.000,225.000 in_frustum=false api_behind=%s inside_control=true" % [-NEAR_OUTSIDE.z, str(outside_behind)])
			quit(2)
			return
		if outside_frustum:
			return _fail("near inside control lost rejection measured_depth=%.3f in_frustum=%s" % [-NEAR_OUTSIDE.z, outside_frustum])
		_cleanup()
		print("PASS camera3d_ortho near_boundary_inside depth=%.3f screen=550.000,225.000 in_frustum=true outside_control=false" % -NEAR_INSIDE.z)
		quit(0)
		return
	if far_exact:
		var exact_screen := camera.unproject_position(FAR_EXACT)
		var exact_frustum := camera.is_position_in_frustum(FAR_EXACT)
		var exact_behind := camera.is_position_behind(FAR_EXACT)
		var inside_frustum := camera.is_position_in_frustum(FAR_INSIDE)
		var outside_frustum := camera.is_position_in_frustum(FAR_OUTSIDE)
		if exact_screen.distance_to(Vector2(550, 225)) > 0.0001 or camera.unproject_position(FAR_INSIDE).distance_to(exact_screen) > 0.0001 or camera.unproject_position(FAR_OUTSIDE).distance_to(exact_screen) > 0.0001 or not inside_frustum or outside_frustum:
			return _fail("far exact setup failed screen=%s inside=%s outside=%s" % [exact_screen, inside_frustum, outside_frustum])
		if not exact_frustum or exact_behind:
			return _fail("far exact measured contradiction depth=%.3f in_frustum=%s api_behind=%s" % [-FAR_EXACT.z, exact_frustum, exact_behind])
		_cleanup()
		print("PASS camera3d_ortho far_boundary_exact depth=%.3f screen=550.000,225.000 in_frustum=%s api_behind=%s inside_control=true outside_control=false" % [-FAR_EXACT.z, str(exact_frustum), str(exact_behind)])
		quit(0)
		return
	if far_inside or far_outside:
		var inside_screen := camera.unproject_position(FAR_INSIDE)
		var outside_screen := camera.unproject_position(FAR_OUTSIDE)
		var inside_frustum := camera.is_position_in_frustum(FAR_INSIDE)
		var outside_frustum := camera.is_position_in_frustum(FAR_OUTSIDE)
		var control_frustum := camera.is_position_in_frustum(FAR_POINT)
		var inside_behind := camera.is_position_behind(FAR_INSIDE)
		var outside_behind := camera.is_position_behind(FAR_OUTSIDE)
		if inside_screen.distance_to(Vector2(550, 225)) > 0.0001 or outside_screen.distance_to(inside_screen) > 0.0001 or control_frustum or not inside_frustum or inside_behind:
			return _fail("far boundary setup failed inside_screen=%s outside_screen=%s inside_frustum=%s control_frustum=%s" % [inside_screen, outside_screen, inside_frustum, control_frustum])
		if far_outside:
			if outside_frustum:
				return _fail("far outside sample entered frustum measured_depth=%.3f in_frustum=%s" % [-FAR_OUTSIDE.z, outside_frustum])
			_cleanup()
			print("NEGATIVE REJECTED: camera3d_ortho far_boundary_outside depth=%.3f screen=550.000,225.000 in_frustum=false api_behind=%s inside_control=true" % [-FAR_OUTSIDE.z, str(outside_behind)])
			quit(2)
			return
		if outside_frustum:
			return _fail("far inside control lost rejection measured_depth=%.3f in_frustum=%s" % [-FAR_OUTSIDE.z, outside_frustum])
		_cleanup()
		print("PASS camera3d_ortho far_boundary_inside depth=%.3f screen=550.000,225.000 in_frustum=true outside_control=false" % -FAR_INSIDE.z)
		quit(0)
		return
	if far_point:
		var far_screen := camera.unproject_position(FAR_POINT)
		var forward_depth := -FAR_POINT.z
		var api_behind := camera.is_position_behind(FAR_POINT)
		var in_frustum := camera.is_position_in_frustum(FAR_POINT)
		if FAR_POINT.distance_to(Vector3(2, 1, -12)) > 0.000001 or absf(forward_depth - 12.0) > 0.000001 or far_screen.distance_to(Vector2(550, 225)) > 0.0001 or in_frustum or api_behind:
			return _fail("far gate failed depth=%.3f screen=%s frustum=%s api_behind=%s" % [forward_depth, far_screen, in_frustum, api_behind])
		_cleanup()
		print("NEGATIVE REJECTED: camera3d_ortho far_plane_depth=12.000 screen=550.000,225.000 in_frustum=false api_behind=%s geometric_front=true controls_same_pixel=true" % str(api_behind))
		quit(2)
		return
	if near_point:
		var near_point_screen := camera.unproject_position(NEAR_POINT)
		var forward_depth := -NEAR_POINT.z
		var api_behind := camera.is_position_behind(NEAR_POINT)
		var in_frustum := camera.is_position_in_frustum(NEAR_POINT)
		if NEAR_POINT.distance_to(Vector3(2, 1, -0.5)) > 0.000001 or absf(forward_depth - 0.5) > 0.000001 or near_point_screen.distance_to(Vector2(550, 225)) > 0.0001 or in_frustum or not api_behind:
			return _fail("near gate failed depth=%.3f screen=%s frustum=%s api_behind=%s" % [forward_depth, near_point_screen, in_frustum, api_behind])
		_cleanup()
		print("NEGATIVE REJECTED: camera3d_ortho near_plane_depth=0.500 screen=550.000,225.000 in_frustum=false api_behind=%s geometric_front=true controls_same_pixel=true" % str(api_behind))
		quit(2)
		return
	if outside:
		var lateral := camera.unproject_position(OUTSIDE)
		if lateral.distance_to(Vector2(850, 225)) > 0.0001 or camera.is_position_behind(OUTSIDE) or camera.is_position_in_frustum(OUTSIDE):
			return _fail("lateral rejection failed screen=%s frustum=%s" % [lateral, camera.is_position_in_frustum(OUTSIDE)])
		_cleanup()
		print("NEGATIVE REJECTED: camera3d_ortho lateral_outside screen=850.000,225.000 in_frustum=false controls_same_pixel=true")
		quit(2)
		return
	_cleanup()
	print("PASS camera3d_ortho viewport=800,600 front_screen=550.000,225.000 deep_screen=550.000,225.000 near=1.000 far=10.000")
	quit(0)

func _cleanup() -> void:
	if is_instance_valid(active_viewport):
		active_viewport.free()

func _fail(message: String) -> bool:
	_cleanup()
	push_error("camera3d_ortho: " + message)
	quit(1)
	return true
