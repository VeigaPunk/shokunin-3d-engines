# Case 3 — Camera3D perspective world-to-screen against hand-computed pixels.
#
# Reproduce (seeds are read-only; the battery copies this directory into
# corpus/live/runs/<ts>/scratch first):
#   python3 corpus/fixtures/run_battery.py                       # case camera3d_project
#   python3 corpus/fixtures/run_battery.py                       # case camera3d_project_behind
# Direct invocation against a scratch copy of this directory:
#   godot --headless --path <scratch> --script res://camera3d_project.gd
#   godot --headless --path <scratch> --script res://camera3d_project.gd -- --behind-camera
#
# Expected exit signature (positive):
#   exit 0, stdout line:
#   PASS camera3d_project viewport=800,600 fov=90.000 proj_x_scale=0.750 proj_y_scale=1.000 world=2.000,1.000,-4.000 screen=550.000,225.000 center_screen=400.000,300.000 mirror_screen=250.000,375.000 behind=false in_frustum=true
# Expected exit signature (negative control --behind-camera):
#   exit 2, stdout line:
#   NEGATIVE REJECTED: camera3d_project behind_camera_projection_rejected point=2.000,1.000,4.000 is_position_behind=true in_frustum=false raw_screen=250.000,375.000 collides_with_mirrored_control=true lateral_screen=3400.000,300.000 lateral_in_frustum=false in_front_control_accepted=true
# Setup/script error: exit 1 with an "ERROR: camera3d_project: ..." line.
#
# The fixture authors its own SubViewport because Godot 4.7.2 --headless pins
# the root Window to 64x64 and ignores display/window/size project settings; an
# authored SubViewport makes the viewport an authored constant instead of a
# host default.
#
# Hand-derived pinhole math, vertical fov 90 with KEEP_HEIGHT on 800x600:
#   aspect = 800/600 = 4/3
#   f_y    = 1 / tan(fov/2) = 1 / tan(45) = 1.0
#   f_x    = f_y / aspect   = 0.75
# For a camera at the origin looking down -Z and a point at view depth w = 4:
#   P=(2,1,-4):  ndc.x = 0.75*2/4 = 0.375 -> x = (0.375*0.5+0.5)*800 = 550
#                ndc.y = 1.0*1/4  = 0.25  -> y = (0.5-0.25*0.5)*600  = 225
#                (viewport y grows downward, so +y in world maps up-screen)
#   P=(0,0,-4):  ndc = (0,0)              -> (400,300) viewport centre
#   P=(-2,-1,-4): ndc = (-0.375,-0.25)    -> (250,375)
#   P=(40,0,-4): ndc.x = 0.75*40/4 = 7.5  -> x = (7.5*0.5+0.5)*800 = 3400,
#                outside the authored 0..800 viewport rect
#   P=(2,1,+4): behind the camera. The raw projection returns (250,375), the
#                pixel of the legitimate mirror control above — which is exactly
#                why the behind/off-frustum gate, not the raw number, decides
#                acceptance.
extends SceneTree

const VIEWPORT := Vector2i(800, 600)
const FOV := 90.0
const NEAR := 0.05
const FAR := 100.0
const WORLD_POINT := Vector3(2.0, 1.0, -4.0)
const CENTER_POINT := Vector3(0.0, 0.0, -4.0)
const MIRROR_POINT := Vector3(-2.0, -1.0, -4.0)
const LATERAL_POINT := Vector3(40.0, 0.0, -4.0)
const BEHIND_POINT := Vector3(2.0, 1.0, 4.0)
const EXPECTED_SCREEN := Vector2(550.0, 225.0)
const EXPECTED_CENTER_SCREEN := Vector2(400.0, 300.0)
const EXPECTED_MIRROR_SCREEN := Vector2(250.0, 375.0)
const EXPECTED_LATERAL_SCREEN := Vector2(3400.0, 300.0)
const EXPECTED_PROJ_X_SCALE := 0.75
const EXPECTED_PROJ_Y_SCALE := 1.0
const SCREEN_EPSILON := 1.0e-4
const FRUSTUM_EPSILON := 1.0e-6
const SCALE_EPSILON := 1.0e-6
const FRAME_BOUND := 1200

var frames := 0


func _initialize() -> void:
	call_deferred("_run")


func _process(_delta: float) -> bool:
	frames += 1
	if frames > FRAME_BOUND:
		push_error("camera3d_project: process bound exceeded frames=%d" % frames)
		quit(1)
		return true
	return false


func _run() -> void:
	var behind := "--behind-camera" in OS.get_cmdline_user_args()
	var viewport := SubViewport.new()
	viewport.name = "AuthoredViewport"
	viewport.size = VIEWPORT
	root.add_child(viewport)
	var camera := Camera3D.new()
	camera.name = "ProbeCamera"
	camera.fov = FOV
	camera.near = NEAR
	camera.far = FAR
	camera.keep_aspect = Camera3D.KEEP_HEIGHT
	camera.projection = Camera3D.PROJECTION_PERSPECTIVE
	camera.position = Vector3.ZERO
	viewport.add_child(camera)
	camera.make_current()
	await process_frame
	await process_frame
	if not _setup_intact(viewport, camera):
		return _fail("authored viewport/frustum is not in place")

	var proj := camera.get_camera_projection()
	if absf(proj[0].x - EXPECTED_PROJ_X_SCALE) > SCALE_EPSILON:
		return _fail("projection x scale disagrees with hand-derived f_x=%0.6f got=%0.6f"
				% [EXPECTED_PROJ_X_SCALE, proj[0].x])
	if absf(proj[1].y - EXPECTED_PROJ_Y_SCALE) > SCALE_EPSILON:
		return _fail("projection y scale disagrees with hand-derived f_y=%0.6f got=%0.6f"
				% [EXPECTED_PROJ_Y_SCALE, proj[1].y])

	var screen := camera.unproject_position(WORLD_POINT)
	var center_screen := camera.unproject_position(CENTER_POINT)
	var mirror_screen := camera.unproject_position(MIRROR_POINT)
	var control_accepted := (screen.distance_to(EXPECTED_SCREEN) <= SCREEN_EPSILON
			and center_screen.distance_to(EXPECTED_CENTER_SCREEN) <= SCREEN_EPSILON
			and mirror_screen.distance_to(EXPECTED_MIRROR_SCREEN) <= SCREEN_EPSILON
			and not camera.is_position_behind(WORLD_POINT)
			and camera.is_position_in_frustum(WORLD_POINT))
	if behind:
		return _behind_verdict(camera, control_accepted, mirror_screen)
	if not control_accepted:
		return _fail("in-front projections disagree with hand-computed pixels screen=%s center=%s mirror=%s"
				% [_v(screen), _v(center_screen), _v(mirror_screen)])
	print("PASS camera3d_project viewport=%d,%d fov=%s proj_x_scale=%s proj_y_scale=%s world=%s screen=%s center_screen=%s mirror_screen=%s behind=false in_frustum=true"
			% [VIEWPORT.x, VIEWPORT.y, _f(FOV), _f(proj[0].x), _f(proj[1].y),
				_v3(WORLD_POINT), _v(screen), _v(center_screen), _v(mirror_screen)])
	quit(0)


func _setup_intact(viewport: SubViewport, camera: Camera3D) -> bool:
	if not viewport.is_inside_tree() or not camera.is_inside_tree():
		return false
	if viewport.size != VIEWPORT:
		return false
	if camera.get_viewport() != viewport:
		return false
	if not camera.is_current():
		return false
	# Camera3D stores near/far as 32-bit floats, so the authored 0.05 reads back
	# as 0.05000000074506; compare with a tolerance rather than equality.
	if camera.fov != FOV or absf(camera.near - NEAR) > FRUSTUM_EPSILON \
			or absf(camera.far - FAR) > FRUSTUM_EPSILON:
		return false
	if camera.keep_aspect != Camera3D.KEEP_HEIGHT:
		return false
	return camera.global_transform.origin == Vector3.ZERO


func _behind_verdict(camera: Camera3D, control_accepted: bool, mirror_screen: Vector2) -> void:
	# The in-front control must still project correctly, otherwise the rejection
	# below would be a broken projection rather than a discriminating negative.
	if not control_accepted:
		return _fail("in-front control projection failed; rejection would not be discriminating")
	if not camera.is_position_behind(BEHIND_POINT):
		return _fail("authored behind point is not behind the camera point=%s" % _v3(BEHIND_POINT))
	if camera.is_position_in_frustum(BEHIND_POINT):
		return _fail("authored behind point was accepted by the frustum")
	var raw := camera.unproject_position(BEHIND_POINT)
	if raw.distance_to(mirror_screen) > SCREEN_EPSILON:
		return _fail("behind point did not alias the mirrored control pixel raw=%s mirror=%s"
				% [_v(raw), _v(mirror_screen)])
	var lateral := camera.unproject_position(LATERAL_POINT)
	if camera.is_position_in_frustum(LATERAL_POINT) or camera.is_position_behind(LATERAL_POINT):
		return _fail("authored lateral point was not classified off-frustum in front")
	if lateral.distance_to(EXPECTED_LATERAL_SCREEN) > SCREEN_EPSILON:
		return _fail("lateral projection disagrees with hand-computed pixel got=%s expected=%s"
				% [_v(lateral), _v(EXPECTED_LATERAL_SCREEN)])
	if lateral.x >= 0.0 and lateral.x < float(VIEWPORT.x):
		return _fail("lateral projection landed inside the authored viewport rect x=%s" % _f(lateral.x))
	print("NEGATIVE REJECTED: camera3d_project behind_camera_projection_rejected point=%s is_position_behind=true in_frustum=false raw_screen=%s collides_with_mirrored_control=true lateral_screen=%s lateral_in_frustum=false in_front_control_accepted=true"
			% [_v3(BEHIND_POINT), _v(raw), _v(lateral)])
	quit(2)


func _fail(message: String) -> void:
	push_error("camera3d_project: " + message)
	quit(1)


func _f(value: float) -> String:
	# snappedf + 0.0 keeps marker text stable: it folds -0.0 and sub-tolerance
	# noise to 0.000 while leaving genuine negatives such as -1.000 intact.
	return "%0.3f" % (snappedf(value, 0.001) + 0.0)


func _v(value: Vector2) -> String:
	return _f(value.x) + "," + _f(value.y)


func _v3(value: Vector3) -> String:
	return _f(value.x) + "," + _f(value.y) + "," + _f(value.z)
