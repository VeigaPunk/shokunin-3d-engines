# Built-in AnimationPlayer transition between constant 3D position tracks.
extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var cut := "--cut" in OS.get_cmdline_user_args()
	var stage := Node3D.new()
	root.add_child(stage)
	var actor := Node3D.new()
	actor.name = "Actor"
	stage.add_child(actor)
	var player := AnimationPlayer.new()
	player.root_node = NodePath("..")
	player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS
	stage.add_child(player)
	var library := AnimationLibrary.new()
	for entry in ["from", "to"]:
		var animation := Animation.new()
		animation.length = 2.0
		var track := animation.add_track(Animation.TYPE_POSITION_3D)
		animation.track_set_path(track, NodePath("Actor"))
		var value := Vector3.ZERO if entry == "from" else Vector3(4, 0, 0)
		animation.track_insert_key(track, 0.0, value)
		animation.track_insert_key(track, 2.0, value)
		library.add_animation(entry, animation)
	player.add_animation_library("", library)
	await physics_frame
	player.play("from")
	for i in range(4):
		await physics_frame
	player.play("to", 0.0 if cut else 0.5)
	for i in range(15):
		await physics_frame
	var mid := actor.position
	for i in range(30):
		await physics_frame
	var end := actor.position
	var from_animation := player.get_animation("from")
	var to_animation := player.get_animation("to")
	if from_animation == null or to_animation == null or from_animation == to_animation or from_animation.get_track_count() != 1 or to_animation.get_track_count() != 1 or from_animation.track_get_path(0) != NodePath("Actor") or to_animation.track_get_path(0) != NodePath("Actor") or player.callback_mode_process != AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS or not player.is_playing():
		return _fail(stage, "blend track/player setup absent")
	if cut:
		if mid.distance_to(Vector3(4, 0, 0)) > 0.003 or end.distance_to(Vector3(4, 0, 0)) > 0.003:
			return _fail(stage, "cut control mismatch mid=%s end=%s" % [mid, end])
		stage.free()
		print("NEGATIVE REJECTED: animation3d_blend instant_cut mid_x=4.000 end_x=4.000")
		quit(2)
		return
	if mid.distance_to(Vector3(1.931034, 0, 0)) > 0.005 or end.distance_to(Vector3(4, 0, 0)) > 0.003 or not (mid.x > 0.01 and mid.x < end.x - 0.01):
		return _fail(stage, "cross-fade position mismatch mid=%s end=%s" % [mid, end])
	stage.free()
	print("PASS animation3d_blend fade_seconds=0.5 mid_x=1.931 end_x=4.000 physics_frames=15+30")
	quit(0)

func _fail(stage: Node3D, reason: String) -> bool:
	stage.free()
	push_error("animation3d_blend: " + reason)
	quit(1)
	return true
