# Case 2 — Area3D body_entered chain with an inspectable payload.
#
# Reproduce (seeds are read-only; the battery copies this directory into
# corpus/live/runs/<ts>/scratch first):
#   python3 corpus/fixtures/run_battery.py                       # case area3d_chain
#   python3 corpus/fixtures/run_battery.py                       # case area3d_chain_no_overlap
# Direct invocation against a scratch copy of this directory:
#   godot --headless --path <scratch> --script res://area3d_chain.gd
#   godot --headless --path <scratch> --script res://area3d_chain.gd -- --no-overlap
#
# Expected exit signature (positive):
#   exit 0, stdout line:
#   PASS area3d_chain collected=1 entries=1 overlapping=1 body_name=Runner3D body_layer=2 entry_x=4.200 pickup_x=6.000
# Expected exit signature (negative control --no-overlap):
#   exit 2, stdout line:
#   NEGATIVE REJECTED: area3d_chain no_overlap_signal_absent collected=0 entries=0 overlapping=0 runner_x=6.000 pickup_x=40.000 monitoring=true mask_matches_layer=true
# Setup/script error: exit 1 with an "ERROR: area3d_chain: ..." line.
#
# Hand-derived constants (not re-derived at runtime, on purpose):
#   entry threshold on X = pickup center 6.0 - sphere radius 1.5 - runner
#                          half-width 1.0/2 = 4.0
#   negative travel      = 6.0 * 60 / 60 = 6.0, which is 32.0 short of the
#                          38.0 entry threshold of the relocated pickup
# The positive arm asserts the runner was at or past 4.0 when the chain fired,
# so a signal from nowhere would not pass. Both arms assert the authored
# monitoring/mask/layer arrangement first, so absence in the negative arm is an
# arrangement fact rather than a disabled trigger.
extends SceneTree

const Runner = preload("res://runner3d.gd")
const Orb = preload("res://pickup_orb3d.gd")

const PICKUP_RADIUS := 1.5
const PICKUP_X := 6.0
const FAR_PICKUP_X := 40.0
const RUNNER_SIZE := Vector3(1.0, 1.0, 1.0)
const DRIVE_SPEED := 6.0
const TICKS := 60
const ENTRY_X := 4.0
const EXPECTED_TRAVEL_X := 6.0
const POSITION_EPSILON := 1.0e-2
const FRAME_BOUND := 1200

var frames := 0
var collected_count := 0
var collected_name := ""
var collected_layer := -1
var collected_at := Vector3.ZERO
var entry_x := 0.0


func _initialize() -> void:
	call_deferred("_run")


func _process(_delta: float) -> bool:
	frames += 1
	if frames > FRAME_BOUND:
		push_error("area3d_chain: process bound exceeded frames=%d" % frames)
		quit(1)
		return true
	return false


func _collected(body_name: String, body_layer: int, at: Vector3) -> void:
	collected_count += 1
	collected_name = body_name
	collected_layer = body_layer
	collected_at = at


func _run() -> void:
	var no_overlap := "--no-overlap" in OS.get_cmdline_user_args()
	var sphere := SphereShape3D.new()
	sphere.radius = PICKUP_RADIUS
	var pickup_shape := CollisionShape3D.new()
	pickup_shape.shape = sphere
	var pickup := Orb.new()
	pickup.name = "OrbPickup"
	pickup.collision_layer = 4
	pickup.collision_mask = 2
	pickup.position = Vector3(FAR_PICKUP_X if no_overlap else PICKUP_X, 0.0, 0.0)
	pickup.add_child(pickup_shape)
	pickup.collected.connect(_collected)
	root.add_child(pickup)

	var runner_box := BoxShape3D.new()
	runner_box.size = RUNNER_SIZE
	var runner_shape := CollisionShape3D.new()
	runner_shape.shape = runner_box
	var runner := Runner.new()
	runner.name = "Runner3D"
	runner.collision_layer = 2
	runner.collision_mask = 0
	runner.motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
	runner.add_child(runner_shape)
	runner.position = Vector3.ZERO
	runner.drive = Vector3(DRIVE_SPEED, 0.0, 0.0)
	root.add_child(runner)

	await physics_frame
	if not _setup_intact(pickup, sphere, runner, runner_box):
		return _fail("area or runner trigger setup is not the authored arrangement")
	if collected_count != 0:
		return _fail("chain fired before any motion collected=%d" % collected_count)
	var start_ticks: int = runner.ticks
	var collect_tick := 0
	for _i in range(TICKS):
		await physics_frame
		if collected_count > 0 and collect_tick == 0:
			collect_tick = runner.ticks - start_ticks
			entry_x = runner.position.x
	var ticks: int = runner.ticks - start_ticks
	if ticks != TICKS:
		return _fail("physics tick budget was not exact ticks=%d expected=%d" % [ticks, TICKS])
	if no_overlap:
		return _absent_verdict(pickup, runner)
	return _chain_verdict(pickup, collect_tick)


func _setup_intact(pickup: Orb, sphere: SphereShape3D, runner: Runner, runner_box: BoxShape3D) -> bool:
	if not pickup.is_inside_tree() or not runner.is_inside_tree():
		return false
	if sphere.radius != PICKUP_RADIUS or runner_box.size != RUNNER_SIZE:
		return false
	if not pickup.monitoring:
		return false
	if (pickup.collision_mask & runner.collision_layer) == 0:
		return false
	return true


func _chain_verdict(pickup: Orb, collect_tick: int) -> void:
	if collected_count != 1:
		return _fail("chain did not fire exactly once collected=%d" % collected_count)
	if collected_name != "Runner3D" or collected_layer != 2:
		return _fail("chain payload disagrees with the authored body name=%s layer=%d"
				% [collected_name, collected_layer])
	if pickup.entries != 1:
		return _fail("body_entered delivered more than once entries=%d" % pickup.entries)
	if not pickup.consumed:
		return _fail("trigger did not latch consumed=false")
	if pickup.get_overlapping_bodies().size() != 1:
		return _fail("expected exactly one overlapping body found=%d"
				% pickup.get_overlapping_bodies().size())
	if collect_tick <= 0 or entry_x < ENTRY_X - POSITION_EPSILON:
		return _fail("chain fired before the hand-derived entry threshold tick=%d x=%s threshold=%s"
				% [collect_tick, _f(entry_x), _f(ENTRY_X)])
	print("PASS area3d_chain collected=1 entries=1 overlapping=1 body_name=%s body_layer=%d entry_x=%s pickup_x=%s"
			% [collected_name, collected_layer, _f(entry_x), _f(PICKUP_X)])
	quit(0)


func _absent_verdict(pickup: Orb, runner: Runner) -> void:
	if collected_count != 0 or pickup.entries != 0 or pickup.consumed:
		return _fail("relocated pickup unexpectedly fired collected=%d entries=%d"
				% [collected_count, pickup.entries])
	if pickup.get_overlapping_bodies().size() != 0:
		return _fail("relocated pickup reports overlapping bodies found=%d"
				% pickup.get_overlapping_bodies().size())
	if absf(runner.position.x - EXPECTED_TRAVEL_X) > POSITION_EPSILON:
		return _fail("runner did not travel the authored distance x=%s expected=%s"
				% [_f(runner.position.x), _f(EXPECTED_TRAVEL_X)])
	print("NEGATIVE REJECTED: area3d_chain no_overlap_signal_absent collected=0 entries=0 overlapping=0 runner_x=%s pickup_x=%s monitoring=true mask_matches_layer=true"
			% [_f(runner.position.x), _f(FAR_PICKUP_X)])
	quit(2)


func _fail(message: String) -> void:
	push_error("area3d_chain: " + message)
	quit(1)


func _f(value: float) -> String:
	# snappedf + 0.0 keeps marker text stable: it folds -0.0 and sub-tolerance
	# noise to 0.000 while leaving genuine negatives such as -1.000 intact.
	return "%0.3f" % (snappedf(value, 0.001) + 0.0)
