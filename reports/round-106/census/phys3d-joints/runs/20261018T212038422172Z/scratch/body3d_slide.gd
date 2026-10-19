# Case 1 — CharacterBody3D move_and_slide stopped by a StaticBody3D box.
#
# Reproduce (seeds are read-only; the battery copies this directory into
# corpus/live/runs/<ts>/scratch first):
#   python3 corpus/fixtures/run_battery.py                       # case body3d_contact
#   python3 corpus/fixtures/run_battery.py                       # case body3d_contact_far
# Direct invocation against a scratch copy of this directory:
#   godot --headless --path <scratch> --script res://body3d_slide.gd
#   godot --headless --path <scratch> --script res://body3d_slide.gd -- --far-body
#
# Expected exit signature (positive):
#   exit 0, stdout line:
#   PASS body3d_contact start_z=6.000 expected_plane_z=2.500 final_z=2.500 ticks=60 first_contact_tick=21 on_wall=true normal=0.000,0.000,1.000
# Expected exit signature (negative control --far-body):
#   exit 2, stdout line:
#   NEGATIVE REJECTED: body3d_contact no_contact_at_far_arrangement start_z=40.000 final_z=30.000 expected_plane_z=2.500 contacts=0 on_wall=false wall_intact=true
# Setup/script error: exit 1 with an "ERROR: body3d_slide: ..." line; the
# battery classifies any exit-1 run of this fixture as FAIL.
#
# Hand-derived constants (not re-derived at runtime, on purpose):
#   contact plane on Z = box half-depth 4.0/2 + runner half-depth 1.0/2 = 2.5
#   ticks to contact   = (6.0 - 2.5) / (10.0 / 60) = 21
#   far-arrangement Z  = 40.0 - 10.0 * 60 / 60 = 30.0 (27.5 short of the plane)
# The measured stop is ~2.5003 because CharacterBody3D keeps its safe margin
# off the surface; PLANE_EPSILON below is 1e-3, tighter than that residual and
# far tighter than the 1.0 a wrong constant would move it.
extends SceneTree

const Runner = preload("res://runner3d.gd")

const BOX_SIZE := Vector3(4.0, 4.0, 4.0)
const RUNNER_SIZE := Vector3(1.0, 1.0, 1.0)
const START_Z := 6.0
const FAR_START_Z := 40.0
const DRIVE_SPEED := 10.0
const TICKS := 60
const EXPECTED_PLANE_Z := 2.5
const EXPECTED_CONTACT_TICK := 21
const EXPECTED_FAR_Z := 30.0
const EXPECTED_NORMAL := Vector3(0.0, 0.0, 1.0)
const PLANE_EPSILON := 1.0e-3
const NORMAL_EPSILON := 1.0e-6
const TRAVEL_EPSILON := 1.0e-2
const FRAME_BOUND := 1200

var frames := 0


func _initialize() -> void:
	call_deferred("_run")


func _process(_delta: float) -> bool:
	frames += 1
	if frames > FRAME_BOUND:
		push_error("body3d_slide: process bound exceeded frames=%d" % frames)
		quit(1)
		return true
	return false


func _run() -> void:
	var far := "--far-body" in OS.get_cmdline_user_args()
	var box := BoxShape3D.new()
	box.size = BOX_SIZE
	var wall_shape := CollisionShape3D.new()
	wall_shape.shape = box
	var wall := StaticBody3D.new()
	wall.name = "Wall"
	wall.collision_layer = 1
	wall.add_child(wall_shape)
	root.add_child(wall)

	var runner_box := BoxShape3D.new()
	runner_box.size = RUNNER_SIZE
	var runner_shape := CollisionShape3D.new()
	runner_shape.shape = runner_box
	var runner := Runner.new()
	runner.name = "Runner3D"
	runner.collision_layer = 2
	runner.collision_mask = 1
	runner.motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
	runner.add_child(runner_shape)
	runner.position = Vector3(0.0, 0.0, FAR_START_Z if far else START_Z)
	runner.drive = Vector3(0.0, 0.0, -DRIVE_SPEED)
	root.add_child(runner)

	await physics_frame
	if not _setup_intact(wall, box, runner, runner_box):
		return _fail("wall or runner collision setup is not the authored arrangement")
	var start_ticks: int = runner.ticks
	for _i in range(TICKS):
		await physics_frame
	var ticks: int = runner.ticks - start_ticks
	if ticks != TICKS:
		return _fail("physics tick budget was not exact ticks=%d expected=%d" % [ticks, TICKS])
	var final_z := runner.position.z
	if far:
		return _far_verdict(runner, final_z)
	return _contact_verdict(runner, final_z, ticks)


func _setup_intact(wall: StaticBody3D, box: BoxShape3D, runner: Runner, runner_box: BoxShape3D) -> bool:
	# Both arms run this check, so an absent contact in the negative arm is
	# attributable to the arrangement (distance) and never to a disabled or
	# unshapen body.
	if not wall.is_inside_tree() or not runner.is_inside_tree():
		return false
	if box.size != BOX_SIZE or runner_box.size != RUNNER_SIZE:
		return false
	if wall.collision_layer != 1 or (runner.collision_mask & wall.collision_layer) == 0:
		return false
	if runner.get_child_count() == 0 or not runner.get_child(0) is CollisionShape3D:
		return false
	return true


func _contact_verdict(runner: Runner, final_z: float, ticks: int) -> void:
	if runner.first_contact_tick <= 0:
		return _fail("no slide contact recorded within %d ticks final_z=%s" % [ticks, _f(final_z)])
	if absf(final_z - EXPECTED_PLANE_Z) > PLANE_EPSILON:
		return _fail("body did not stop at the contact plane final_z=%s expected=%s"
				% [_f(final_z), _f(EXPECTED_PLANE_Z)])
	if runner.first_contact_tick != EXPECTED_CONTACT_TICK:
		return _fail("first contact tick disagrees with the hand-derived value tick=%d expected=%d"
				% [runner.first_contact_tick, EXPECTED_CONTACT_TICK])
	if runner.first_contact_normal.distance_to(EXPECTED_NORMAL) > NORMAL_EPSILON:
		return _fail("contact normal is not +Z normal=%s" % _v(runner.first_contact_normal))
	if not runner.is_on_wall():
		return _fail("body is not resting against a wall after contact")
	if runner.contacts < 1:
		return _fail("no slide collisions were accumulated contacts=%d" % runner.contacts)
	print("PASS body3d_contact start_z=%s expected_plane_z=%s final_z=%s ticks=%d first_contact_tick=%d on_wall=true normal=%s"
			% [_f(START_Z), _f(EXPECTED_PLANE_Z), _f(final_z), ticks, runner.first_contact_tick,
				_v(runner.first_contact_normal)])
	quit(0)


func _far_verdict(runner: Runner, final_z: float) -> void:
	if runner.contacts != 0 or runner.first_contact_tick != 0 or runner.is_on_wall():
		return _fail("far arrangement unexpectedly contacted the wall contacts=%d tick=%d"
				% [runner.contacts, runner.first_contact_tick])
	if absf(final_z - EXPECTED_FAR_Z) > TRAVEL_EPSILON:
		return _fail("far arrangement did not travel the authored distance final_z=%s expected=%s"
				% [_f(final_z), _f(EXPECTED_FAR_Z)])
	print("NEGATIVE REJECTED: body3d_contact no_contact_at_far_arrangement start_z=%s final_z=%s expected_plane_z=%s contacts=0 on_wall=false wall_intact=true"
			% [_f(FAR_START_Z), _f(final_z), _f(EXPECTED_PLANE_Z)])
	quit(2)


func _fail(message: String) -> void:
	push_error("body3d_slide: " + message)
	quit(1)


func _f(value: float) -> String:
	# snappedf + 0.0 keeps marker text stable: it folds -0.0 and sub-tolerance
	# noise to 0.000 while leaving genuine negatives such as -1.000 intact.
	return "%0.3f" % (snappedf(value, 0.001) + 0.0)


func _v(value: Vector3) -> String:
	return _f(value.x) + "," + _f(value.y) + "," + _f(value.z)
