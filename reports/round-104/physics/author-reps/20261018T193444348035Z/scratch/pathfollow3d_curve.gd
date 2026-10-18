# Live PathFollow3D transform along bent versus straight Curve3D.
extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var straight := "--straight" in OS.get_cmdline_user_args()
	var curve := Curve3D.new()
	curve.bake_interval = 0.1
	curve.add_point(Vector3.ZERO)
	curve.add_point(Vector3(2, 0 if straight else 2, 1), Vector3(-0.5, 0, -0.25), Vector3(0.5, 0, 0.25))
	curve.add_point(Vector3(4, 0, 2))
	var path := Path3D.new()
	path.curve = curve
	root.add_child(path)
	var follower := PathFollow3D.new()
	follower.rotation_mode = PathFollow3D.ROTATION_NONE
	path.add_child(follower)
	var marker := Node3D.new()
	marker.position = Vector3(0, 0, 1)
	follower.add_child(marker)
	await process_frame
	var length := curve.get_baked_length()
	follower.progress = length * 0.25
	var first := follower.global_position
	var marker_first := marker.global_position
	follower.progress = length * 0.75
	var second := follower.global_position
	var marker_second := marker.global_position
	if not path.is_inside_tree() or path.curve != curve or follower.get_parent() != path or marker.get_parent() != follower or follower.rotation_mode != PathFollow3D.ROTATION_NONE or marker.position != Vector3(0, 0, 1) or curve.point_count != 3:
		return _fail(path, "live path follower setup absent")
	var expected_length := 4.472136 if straight else 6.072724
	var expected_first := Vector3(1, 0, 0.5) if straight else Vector3(0.917532, 1.11862, 0.458766)
	var expected_second := Vector3(3, 0, 1.5) if straight else Vector3(3.082469, 1.118619, 1.541234)
	if absf(length - expected_length) > 0.003 or first.distance_to(expected_first) > 0.003 or second.distance_to(expected_second) > 0.003:
		return _fail(path, "follower positions mismatch length=%.6f first=%s second=%s" % [length, first, second])
	if marker_first.distance_to(expected_first + Vector3(0, 0, 1)) > 0.003 or marker_second.distance_to(expected_second + Vector3(0, 0, 1)) > 0.003:
		return _fail(path, "child marker follow mismatch first=%s second=%s" % [marker_first, marker_second])
	path.free()
	if straight:
		print("NEGATIVE REJECTED: pathfollow3d_curve straight first_y=0.000 second_y=0.000 marker_offset_z=1.000")
		quit(2)
	else:
		print("PASS pathfollow3d_curve bent first_y=1.118620 second_y=1.118619 marker_offset_z=1.000")
		quit(0)

func _fail(path: Path3D, reason: String) -> bool:
	path.free()
	push_error("pathfollow3d_curve: " + reason)
	quit(1)
	return true
