# Grounded-floor versus displaced-floor control; run via run_battery.py --only floor3d_ground,floor3d_airborne.
# Direct scratch: godot --headless --path <scratch> --script res://floor3d_ground.gd [-- --lower-floor]
# Exit 0 PASS floor3d_ground; exit 2 NEGATIVE REJECTED: floor3d_ground; setup error exit 1.
# Center y=0.5 floor top+0.5 actor half-height=1; (4-1)/(6/60)=30 ticks.
# Lower floor top=-19.5: 60 airborne ticks move y=4-6=-2.
extends SceneTree
const Runner = preload("res://runner3d.gd")
const FLOOR_Y := 0.0
const TICKS := 60
var frames := 0

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
	var floor_body := StaticBody3D.new()
	floor_body.collision_layer = 1
	floor_body.position.y = -20.0 if lower else FLOOR_Y
	floor_body.add_child(floor_shape)
	root.add_child(floor_body)
	var actor_box := BoxShape3D.new()
	actor_box.size = Vector3.ONE
	var actor_shape := CollisionShape3D.new()
	actor_shape.shape = actor_box
	var actor := Runner.new()
	actor.collision_layer = 2
	actor.collision_mask = 1
	actor.motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
	actor.position = Vector3(0, 4, 0)
	actor.drive = Vector3(0, -6, 0)
	actor.add_child(actor_shape)
	root.add_child(actor)
	await physics_frame
	if not floor_body.is_inside_tree() or not actor.is_inside_tree() or floor_box.size != Vector3(8, 1, 8) or actor_box.size != Vector3.ONE or (actor.collision_mask & floor_body.collision_layer) == 0:
		return _fail("collision setup absent")
	var start_ticks: int = actor.ticks
	for i in range(TICKS):
		await physics_frame
	if actor.ticks - start_ticks != TICKS:
		return _fail("tick budget mismatch")
	if lower:
		if actor.contacts != 0 or actor.is_on_floor() or actor.first_contact_tick != 0 or absf(actor.position.y + 2) > 0.002:
			return _fail("airborne control failed y=%.3f contacts=%d" % [actor.position.y, actor.contacts])
		print("NEGATIVE REJECTED: floor3d_ground airborne_with_lower_floor final_y=-2.000 contacts=0 on_floor=false floor_intact=true ticks=60")
		quit(2)
		return
	if absf(actor.position.y - 1) > 0.002:
		return _fail("ground center mismatch y=%.3f expected=1.000" % actor.position.y)
	if actor.first_contact_tick != 30:
		return _fail("first contact tick=%d expected=30" % actor.first_contact_tick)
	if actor.first_contact_normal.distance_to(Vector3.UP) > 0.000001 or not actor.is_on_floor() or actor.contacts < 1:
		return _fail("floor normal/grounded state failed normal=%s contacts=%d" % [actor.first_contact_normal, actor.contacts])
	print("PASS floor3d_ground final_y=1.000 first_contact_tick=30 normal=0.000,1.000,0.000 on_floor=true ticks=60")
	quit(0)

func _fail(message: String) -> bool:
	push_error("floor3d_ground: " + message)
	quit(1)
	return true
