# Natural physics-frame AnimationPlayer advance; no seek or target assignment.
extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var still := "--still" in OS.get_cmdline_user_args()
	var stage := Node3D.new()
	stage.name = "Stage"
	root.add_child(stage)
	var actor := Node3D.new()
	actor.name = "Actor"
	stage.add_child(actor)
	var player := AnimationPlayer.new()
	player.name = "Player"
	player.root_node = NodePath("..")
	player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS
	stage.add_child(player)
	var animation := Animation.new()
	animation.length = 2.0
	var track := animation.add_track(Animation.TYPE_POSITION_3D)
	animation.track_set_path(track, NodePath("Actor"))
	animation.track_insert_key(track, 0.0, Vector3.ZERO)
	animation.track_insert_key(track, 2.0, Vector3.ZERO if still else Vector3(4, 0, 0))
	var library := AnimationLibrary.new()
	library.add_animation("travel", animation)
	player.add_animation_library("", library)
	await physics_frame
	player.play("travel")
	for i in range(30):
		await physics_frame
	var mid := actor.position
	var time_mid := player.current_animation_position
	for i in range(30):
		await physics_frame
	var later := actor.position
	var time_later := player.current_animation_position
	if animation.get_track_count() != 1 or animation.track_get_path(track) != NodePath("Actor") or animation.track_get_key_count(track) != 2 or player.get_animation("travel") != animation or player.callback_mode_process != AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS:
		return _fail(stage, "animation track/callback setup absent")
	if not player.is_playing() or absf(time_mid - 29.0 / 60.0) > 0.002 or absf(time_later - 59.0 / 60.0) > 0.002:
		return _fail(stage, "frame progression mismatch t_mid=%.4f t_later=%.4f playing=%s" % [time_mid, time_later, player.is_playing()])
	if still:
		if mid.distance_to(Vector3.ZERO) > 0.0001 or later.distance_to(Vector3.ZERO) > 0.0001:
			return _fail(stage, "constant track moved mid=%s later=%s" % [mid, later])
		stage.free()
		print("NEGATIVE REJECTED: animation3d_playback constant_track mid_x=0.000 later_x=0.000 physics_frames=60")
		quit(2)
		return
	if mid.distance_to(Vector3(29.0 / 30.0, 0, 0)) > 0.003 or later.distance_to(Vector3(59.0 / 30.0, 0, 0)) > 0.003:
		return _fail(stage, "frame-advanced position mismatch mid=%s later=%s" % [mid, later])
	stage.free()
	print("PASS animation3d_playback mid_x=0.967 later_x=1.967 physics_frames=60 playing=true")
	quit(0)

func _fail(stage: Node3D, reason: String) -> bool:
	stage.free()
	push_error("animation3d_playback: " + reason)
	quit(1)
	return true
