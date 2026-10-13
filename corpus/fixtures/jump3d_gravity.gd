# Single upward impulse then explicit gravity on CharacterBody3D, flat floor vs relocated floor.
# run_battery.py --only jump3d_land,jump3d_no_floor
extends SceneTree
const IMPULSE := 6.0
const GRAVITY := 12.0
const TICKS := 60
var frames := 0
var floor_body: StaticBody3D
var actor: CharacterBody3D

func _initialize() -> void:
	call_deferred("_run")

func _process(_delta: float) -> bool:
	frames += 1
	if frames > 1200:
		return _fail("frame bound exceeded")
	return false

func _run() -> void:
	var lower := "--lower-floor" in OS.get_cmdline_user_args()
	var floor_box := BoxShape3D.new()
	floor_box.size = Vector3(8, 1, 8)
	var floor_shape := CollisionShape3D.new()
	floor_shape.shape = floor_box
	floor_body = StaticBody3D.new()
	floor_body.collision_layer = 1
	floor_body.position.y = -20 if lower else 0
	floor_body.add_child(floor_shape)
	root.add_child(floor_body)
	actor = CharacterBody3D.new()
	actor.motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
	actor.collision_layer = 2
	actor.collision_mask = 1
	actor.position = Vector3(0, 1, 0)
	var actor_box := BoxShape3D.new()
	actor_box.size = Vector3.ONE
	var actor_shape := CollisionShape3D.new()
	actor_shape.shape = actor_box
	actor.add_child(actor_shape)
	root.add_child(actor)
	await physics_frame
	if floor_box.size != Vector3(8, 1, 8) or actor_box.size != Vector3.ONE or (actor.collision_mask & floor_body.collision_layer) == 0:
		return _fail("collision setup absent")
	actor.velocity = Vector3(0, -0.01, 0)
	actor.move_and_slide()
	var initially_grounded := actor.is_on_floor()
	if initially_grounded == lower or absf(actor.position.y - 1.0) > 0.002:
		return _fail("initial floor probe failed grounded=%s y=%.4f lower=%s" % [initially_grounded, actor.position.y, lower])
	var velocity_y := IMPULSE
	var apex_y := actor.position.y
	var apex_tick := 0
	var landing_tick := 0
	var landed := false
	for tick in range(1, TICKS + 1):
		velocity_y -= GRAVITY / 60.0
		actor.velocity = Vector3(0, velocity_y, 0)
		actor.move_and_slide()
		velocity_y = actor.velocity.y
		if actor.position.y > apex_y:
			apex_y = actor.position.y
			apex_tick = tick
		if actor.is_on_floor() and not landed:
			landed = true
			landing_tick = tick
		await physics_frame
	if apex_tick != 29 or absf(apex_y - 2.45) > 0.003 or actor.position.x != 0 or actor.position.z != 0:
		return _fail("apex/planar mismatch tick=%d y=%.4f position=%s" % [apex_tick, apex_y, actor.position])
	if lower:
		if floor_body.position.y != -20 or landed or actor.is_on_floor() or absf(actor.position.y - 0.9) > 0.002:
			return _fail("lower-floor control landed=%s final_y=%.4f floor_y=%.1f" % [landed, actor.position.y, floor_body.position.y])
		var final_y := actor.position.y
		_cleanup()
		print("NEGATIVE REJECTED: jump3d_gravity no_floor_landing apex_tick=%d apex_y=%.3f final_y=%.3f initially_grounded=false grounded=false floor_intact=true" % [apex_tick, apex_y, final_y])
		quit(2)
		return
	if floor_body.position.y != 0 or not landed or landing_tick != 60 or not actor.is_on_floor() or absf(actor.position.y - 1.0) > 0.003:
		return _fail("landing failed tick=%d y=%.4f floor=%s" % [landing_tick, actor.position.y, actor.is_on_floor()])
	var final_y := actor.position.y
	_cleanup()
	print("PASS jump3d_gravity apex_tick=%d apex_y=%.3f landing_tick=%d final_y=%.3f initially_grounded=true grounded=true" % [apex_tick, apex_y, landing_tick, final_y])
	quit(0)

func _cleanup() -> void:
	if is_instance_valid(actor):
		actor.free()
	if is_instance_valid(floor_body):
		floor_body.free()

func _fail(message: String) -> bool:
	_cleanup()
	push_error("jump3d_gravity: " + message)
	quit(1)
	return true
