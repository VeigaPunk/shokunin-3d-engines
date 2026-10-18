# Explicit AnimationPlayer evaluation of a live Node3D position track.
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
	stage.add_child(player)
	player.root_node = NodePath("..")
	var animation := Animation.new()
	animation.length = 1.0
	var track := animation.add_track(Animation.TYPE_POSITION_3D)
	animation.track_set_path(track, NodePath("Actor"))
	animation.track_insert_key(track, 0.0, Vector3.ZERO)
	animation.track_insert_key(track, 1.0, Vector3(0, 0, 0) if still else Vector3(4, 0, 0))
	var library := AnimationLibrary.new()
	library.add_animation("travel", animation)
	player.add_animation_library("", library)
	await process_frame
	if animation.get_track_count() != 1 or animation.track_get_path(track) != NodePath("Actor") or animation.track_get_key_count(track) != 2 or player.get_animation("travel") != animation:
		return _fail(stage, "animation track setup absent")
	player.play("travel")
	player.seek(0.5, true)
	var mid := actor.position
	player.seek(1.0, true)
	var end := actor.position
	if not is_instance_valid(actor):
		return _fail(stage, "animation player state missing")
	if still:
		if mid.distance_to(Vector3.ZERO) > 0.0001 or end.distance_to(Vector3.ZERO) > 0.0001:
			return _fail(stage, "still control moved mid=%s end=%s" % [mid, end])
		stage.free()
		print("NEGATIVE REJECTED: animation3d_keys constant_track mid_x=0.000 end_x=0.000")
		quit(2)
		return
	if mid.distance_to(Vector3(2, 0, 0)) > 0.0001 or end.distance_to(Vector3(4, 0, 0)) > 0.0001:
		return _fail(stage, "animated position mismatch mid=%s end=%s" % [mid, end])
	stage.free()
	print("PASS animation3d_keys position_track mid_x=2.000 end_x=4.000 seek_update=true")
	quit(0)

func _fail(stage: Node3D, reason: String) -> bool:
	stage.free()
	push_error("animation3d_keys: " + reason)
	quit(1)
	return true
