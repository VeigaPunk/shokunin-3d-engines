# Orthographic Camera3D same pixels at two positive depths with lateral rejection.
# run_battery.py --only camera3d_ortho,camera3d_ortho_outside
extends SceneTree
const VIEWPORT := Vector2i(800, 600)
const ORTHO_SIZE := 8.0
const FRONT := Vector3(2, 1, -4)
const DEEP := Vector3(2, 1, -8)
const OUTSIDE := Vector3(6, 1, -4)
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
