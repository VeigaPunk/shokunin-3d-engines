# Node3D _physics_process drives live PathFollow3D at fixed speed.
extends SceneTree

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
	var driver := preload("res://pathfollow3d_driver.gd").new()
	driver.follower = follow
	driver.marker = marker
	driver.stationary = stationary
	root.add_child(driver)
	for i in range(65):
		await physics_frame
	if not driver.is_inside_tree() or not path.is_inside_tree() or driver.follower != follow or driver.marker != marker or follow.get_parent() != path or marker.get_parent() != follow or path.curve != curve or absf(curve.get_baked_length() - 6.072724) > 0.003:
		return _fail(driver, path, "live callback/follower setup absent")
	if driver.ticks != 60 or absf(driver.delta_sum - 1.0) > 0.003:
		return _fail(driver, path, "physics callback count/delta mismatch ticks=%d sum=%.6f" % [driver.ticks, driver.delta_sum])
	if stationary:
		if absf(follow.progress) > 0.0001 or driver.first.distance_to(Vector3.ZERO) > 0.0001 or driver.second.distance_to(Vector3.ZERO) > 0.0001 or driver.marker_second.distance_to(Vector3(0, 0, 1)) > 0.0001:
			return _fail(driver, path, "stationary callback moved progress=%.6f first=%s second=%s" % [follow.progress, driver.first, driver.second])
		driver.free()
		path.free()
		print("NEGATIVE REJECTED: pathfollow3d_callback stationary callbacks=60 progress=0.000")
		quit(2)
		return
	if absf(follow.progress - 3.0) > 0.003 or driver.first.distance_to(Vector3(0.906026, 1.105767, 0.453013)) > 0.003 or driver.second.distance_to(Vector3(1.968047, 1.997535, 0.984023)) > 0.003 or driver.marker_second.distance_to(driver.second + Vector3(0, 0, 1)) > 0.003:
		return _fail(driver, path, "callback follower mismatch progress=%.6f first=%s second=%s marker=%s" % [follow.progress, driver.first, driver.second, driver.marker_second])
	driver.free()
	path.free()
	print("PASS pathfollow3d_callback callbacks=60 delta_sum=1.000 progress=3.000 first_y=1.105767 second_y=1.997535")
	quit(0)

func _fail(driver: Node3D, path: Path3D, reason: String) -> bool:
	driver.free()
	path.free()
	push_error("pathfollow3d_callback: " + reason)
	quit(1)
	return true
