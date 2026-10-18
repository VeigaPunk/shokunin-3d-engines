# Case 6 — synthetic InputEventKey driving CharacterBody3D displacement.
#
# Reproduce (seeds are read-only; the battery copies this directory into
# corpus/live/runs/<ts>/scratch first):
#   python3 corpus/fixtures/run_battery.py                       # case input3d_move
#   python3 corpus/fixtures/run_battery.py                       # case input3d_move_no_event
# Direct invocation against a scratch copy of this directory:
#   godot --headless --path <scratch> --script res://input3d_move.gd
#   godot --headless --path <scratch> --script res://input3d_move.gd -- --no-input
#
# Expected exit signature (positive):
#   exit 0, stdout line:
#   PASS input3d_move key=W receipts=1 releases=1 ticks=10 displacement=1.000,0.000,0.000 expected_x=1.000 post_release_ticks=5 post_release_displacement=0.000
# Expected exit signature (negative control --no-input):
#   exit 2, stdout line:
#   NEGATIVE REJECTED: input3d_move no_event_zero_displacement receipts=0 intent=false ticks=10 displacement=0.000,0.000,0.000 late_control_receipts=1 late_control_ticks=5 late_control_displacement=0.500
# Setup/script error: exit 1 with an "ERROR: input3d_move: ..." line.
#
# Hand-derived constants (authored as literals, not recomputed from
# input_mover3d.gd, so a change to that script's SPEED is caught as a
# disagreement between the model and the engine instead of being silently
# re-derived):
#   displacement over TICKS = 6.0 * 10 / 60 = 1.0 on +X, 0 on Y and Z
#   late control displacement = 6.0 * 5 / 60 = 0.5 on +X
# The pinned physics tick (project.godot, 60 Hz) makes each move_and_slide()
# advance exactly 6.0/60 = 0.1, so the total is a fixed-tick product and never
# a wall-clock measurement.
#
# Tick alignment, measured on this host: SceneTree.physics_frame is emitted at
# the start of a physics step, before Node._physics_process. Snapshotting
# immediately after `await physics_frame` and then awaiting TICKS further
# physics frames therefore spans exactly TICKS _physics_process calls, which the
# fixture asserts through the actor's own tick counter rather than assuming.
extends SceneTree

const Mover = preload("res://input_mover3d.gd")

const MOVER_SIZE := Vector3(1.0, 1.0, 1.0)
const TICKS := 10
const POST_RELEASE_TICKS := 5
const LATE_CONTROL_TICKS := 5
const EXPECTED_X := 1.0
const EXPECTED_LATE_CONTROL_X := 0.5
const DISPLACEMENT_EPSILON := 1.0e-4
const AXIS_EPSILON := 1.0e-9
const RECEIPT_BOUND := 20
const FRAME_BOUND := 1200

var frames := 0


func _initialize() -> void:
	call_deferred("_run")


func _process(_delta: float) -> bool:
	frames += 1
	if frames > FRAME_BOUND:
		push_error("input3d_move: process bound exceeded frames=%d" % frames)
		quit(1)
		return true
	return false


func _run() -> void:
	var no_input := "--no-input" in OS.get_cmdline_user_args()
	var mover_box := BoxShape3D.new()
	mover_box.size = MOVER_SIZE
	var mover_shape := CollisionShape3D.new()
	mover_shape.shape = mover_box
	var mover := Mover.new()
	mover.name = "Mover3D"
	mover.collision_layer = 2
	mover.collision_mask = 0
	mover.motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
	mover.add_child(mover_shape)
	mover.position = Vector3.ZERO
	root.add_child(mover)
	await process_frame
	if not _setup_intact(mover, mover_box):
		return _fail("mover collision setup is not the authored arrangement")
	if mover.receipts != 0 or mover.intent:
		return _fail("mover did not start idle receipts=%d intent=%s"
				% [mover.receipts, str(mover.intent)])

	if not no_input:
		_inject(true)
		var got_receipt: bool = await _await_receipt(mover)
		if not got_receipt:
			return _fail("synthetic W press did not reach _input receipts=%d" % mover.receipts)
	await physics_frame
	var origin := mover.position
	var origin_ticks: int = mover.ticks
	for _i in range(TICKS):
		await physics_frame
	var ticks: int = mover.ticks - origin_ticks
	if ticks != TICKS:
		return _fail("physics tick budget was not exact ticks=%d expected=%d" % [ticks, TICKS])
	var displacement := mover.position - origin
	# Both verdict helpers await, so they are coroutines and must be awaited here;
	# each one quits the tree itself.
	if no_input:
		await _zero_verdict(mover, displacement, ticks)
		return
	await _displacement_verdict(mover, displacement, ticks)


func _setup_intact(mover: Mover, mover_box: BoxShape3D) -> bool:
	if not mover.is_inside_tree():
		return false
	if mover_box.size != MOVER_SIZE:
		return false
	if mover.get_child_count() == 0 or not mover.get_child(0) is CollisionShape3D:
		return false
	if not mover.is_physics_processing() or not mover.is_processing_input():
		return false
	# get_physics_process_delta_time() is still 0.0 before the first physics step
	# completes, so liveness is asserted through the exact tick budget in _run
	# rather than here.
	return mover.process_mode == Node.PROCESS_MODE_INHERIT


func _await_receipt(mover: Mover) -> bool:
	for _i in range(RECEIPT_BOUND):
		await process_frame
		if mover.receipts > 0:
			return true
	return mover.receipts > 0


func _displacement_verdict(mover: Mover, displacement: Vector3, ticks: int) -> void:
	if mover.receipts != 1:
		return _fail("expected exactly one key receipt got=%d" % mover.receipts)
	if absf(displacement.x - EXPECTED_X) > DISPLACEMENT_EPSILON:
		return _fail("displacement disagrees with the fixed-tick product got_x=%0.9f expected_x=%0.9f"
				% [displacement.x, EXPECTED_X])
	if absf(displacement.y) > AXIS_EPSILON or absf(displacement.z) > AXIS_EPSILON:
		return _fail("displacement leaked onto another axis displacement=%s" % _v(displacement))
	_inject(false)
	for _i in range(RECEIPT_BOUND):
		await process_frame
		if mover.releases > 0:
			break
	if mover.releases != 1 or mover.intent:
		return _fail("matching W release did not clear intent releases=%d intent=%s"
				% [mover.releases, str(mover.intent)])
	await physics_frame
	var released_origin := mover.position
	var released_ticks: int = mover.ticks
	for _i in range(POST_RELEASE_TICKS):
		await physics_frame
	var post_release := mover.position - released_origin
	if mover.ticks - released_ticks != POST_RELEASE_TICKS:
		return _fail("post-release tick budget was not exact ticks=%d" % (mover.ticks - released_ticks))
	if post_release.length() > AXIS_EPSILON:
		return _fail("body kept moving after the matching release post_release=%s" % _v(post_release))
	print("PASS input3d_move key=W receipts=%d releases=%d ticks=%d displacement=%s expected_x=%s post_release_ticks=%d post_release_displacement=%s"
			% [mover.receipts, mover.releases, ticks, _v(displacement), _f(EXPECTED_X),
				POST_RELEASE_TICKS, _f(post_release.length())])
	quit(0)


func _zero_verdict(mover: Mover, displacement: Vector3, ticks: int) -> void:
	if mover.receipts != 0 or mover.releases != 0 or mover.intent:
		return _fail("event-free arm observed input state receipts=%d releases=%d intent=%s"
				% [mover.receipts, mover.releases, str(mover.intent)])
	if displacement.length() > AXIS_EPSILON:
		return _fail("body displaced with no injected event displacement=%s" % _v(displacement))
	# Late control: the same node, same tick budget discipline, one injected
	# press. Without it a zero displacement would also be produced by a dead
	# node, and the negative would not discriminate anything.
	_inject(true)
	var got_late_receipt: bool = await _await_receipt(mover)
	if not got_late_receipt:
		return _fail("late control press did not reach _input; the zero displacement was not discriminating")
	await physics_frame
	var control_origin := mover.position
	var control_ticks: int = mover.ticks
	for _i in range(LATE_CONTROL_TICKS):
		await physics_frame
	var control := mover.position - control_origin
	if mover.ticks - control_ticks != LATE_CONTROL_TICKS:
		return _fail("late control tick budget was not exact ticks=%d" % (mover.ticks - control_ticks))
	if absf(control.x - EXPECTED_LATE_CONTROL_X) > DISPLACEMENT_EPSILON:
		return _fail("late control did not move got_x=%0.9f expected_x=%0.9f"
				% [control.x, EXPECTED_LATE_CONTROL_X])
	print("NEGATIVE REJECTED: input3d_move no_event_zero_displacement receipts=0 intent=false ticks=%d displacement=%s late_control_receipts=%d late_control_ticks=%d late_control_displacement=%s"
			% [ticks, _v(displacement), mover.receipts, LATE_CONTROL_TICKS, _f(control.x)])
	quit(2)


func _inject(pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = KEY_W
	event.pressed = pressed
	event.echo = false
	Input.parse_input_event(event)


func _fail(message: String) -> void:
	push_error("input3d_move: " + message)
	quit(1)


func _f(value: float) -> String:
	# snappedf + 0.0 keeps marker text stable: it folds -0.0 and sub-tolerance
	# noise to 0.000 while leaving genuine negatives such as -1.000 intact.
	return "%0.3f" % (snappedf(value, 0.001) + 0.0)


func _v(value: Vector3) -> String:
	return _f(value.x) + "," + _f(value.y) + "," + _f(value.z)
