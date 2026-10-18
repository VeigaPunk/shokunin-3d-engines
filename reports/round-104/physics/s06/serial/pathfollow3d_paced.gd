# Fixed-rate PathFollow3D progress paced by awaited physics frames.
extends SceneTree
const SPEED := 3.0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var stationary := "--stationary" in OS.get_cmdline_user_args()
	var curve := Curve3D.new()
	curve.bake_interval = 0.1
	curve.add_point(Vector3.ZERO)
	curve.add_point(Vector3(2, 2, 1), Vector3(-0.5, 0, -0.25), Vector3(0.5, 0, 0.25))
	curve.add_point(Vector3(4, 0, 2))
	var path := Path3D.new()
	path.curve = curve
	root.add_child(path)
	var follow := PathFollow3D.new()
	follow.rotation_mode = PathFollow3D.ROTATION_NONE
	path.add_child(follow)
	var marker := Node3D.new()
	marker.position = Vector3(0, 0, 1)
	follow.add_child(marker)
	await physics_frame
	var first := Vector3.ZERO
	var second := Vector3.ZERO
	var marker_second := Vector3.ZERO
	for i in range(60):
		await physics_frame
		follow.progress += (0.0 if stationary else SPEED) / 60.0
		if i == 29:
			first = follow.global_position
		if i == 59:
			second = follow.global_position
			marker_second = marker.global_position
	if not path.is_inside_tree() or follow.get_parent() != path or marker.get_parent() != follow or path.curve != curve or follow.rotation_mode != PathFollow3D.ROTATION_NONE or curve.point_count != 3 or absf(curve.get_baked_length() - 6.072724) > 0.003:
		return _fail(path, "paced path setup absent")
	if stationary:
		if absf(follow.progress) > 0.0001 or first.distance_to(Vector3.ZERO) > 0.0001 or second.distance_to(Vector3.ZERO) > 0.0001 or marker_second.distance_to(Vector3(0, 0, 1)) > 0.0001:
			return _fail(path, "stationary follower moved progress=%.6f first=%s second=%s marker=%s" % [follow.progress, first, second, marker_second])
		path.free()
		print("NEGATIVE REJECTED: pathfollow3d_paced stationary progress=0.000 first_y=0.000 second_y=0.000")
		quit(2)
		return
	if absf(follow.progress - 3.0) > 0.003 or first.distance_to(Vector3(0.906026, 1.105767, 0.453013)) > 0.003 or second.distance_to(Vector3(1.968047, 1.997535, 0.984023)) > 0.003 or not (second.x > first.x and second.y > first.y):
		return _fail(path, "paced follower mismatch progress=%.6f first=%s second=%s" % [follow.progress, first, second])
	if marker_second.distance_to(second + Vector3(0, 0, 1)) > 0.003:
		return _fail(path, "paced child marker mismatch marker=%s second=%s" % [marker_second, second])
	path.free()
	print("PASS pathfollow3d_paced speed=3.000 progress=3.000 first_y=1.105767 second_y=1.997535")
	quit(0)

func _fail(path: Path3D, reason: String) -> bool:
	path.free()
	push_error("pathfollow3d_paced: " + reason)
	quit(1)
	return true
