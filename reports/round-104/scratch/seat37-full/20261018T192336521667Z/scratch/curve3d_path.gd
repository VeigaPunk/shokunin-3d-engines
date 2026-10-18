# Baked Curve3D bent 3D path versus intact straight control.
extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var straight := "--straight" in OS.get_cmdline_user_args()
	var curve := Curve3D.new()
	curve.bake_interval = 0.1
	curve.add_point(Vector3(0, 0, 0))
	curve.add_point(Vector3(2, 0 if straight else 2, 1), Vector3(-0.5, 0, -0.25), Vector3(0.5, 0, 0.25))
	curve.add_point(Vector3(4, 0, 2))
	var path := Path3D.new()
	path.curve = curve
	root.add_child(path)
	await process_frame
	var length := curve.get_baked_length()
	var quarter := curve.sample_baked(length * 0.25)
	var middle := curve.sample_baked(length * 0.5)
	var three_quarter := curve.sample_baked(length * 0.75)
	if not path.is_inside_tree() or path.curve != curve or curve.point_count != 3 or curve.get_point_position(0) != Vector3.ZERO or curve.get_point_position(2) != Vector3(4, 0, 2) or curve.get_point_out(1).distance_to(Vector3(0.5, 0, 0.25)) > 0.0001:
		return _fail(path, "live curve/path setup absent")
	if straight:
		if absf(length - 4.472136) > 0.001 or quarter.distance_to(Vector3(1, 0, 0.5)) > 0.001 or middle.distance_to(Vector3(2, 0, 1)) > 0.001 or three_quarter.distance_to(Vector3(3, 0, 1.5)) > 0.001:
			return _fail(path, "straight baked path mismatch length=%.6f q=%s mid=%s tq=%s" % [length, quarter, middle, three_quarter])
		path.free()
		print("NEGATIVE REJECTED: curve3d_path straight length=4.472136 midpoint=2.000,0.000,1.000")
		quit(2)
		return
	if absf(length - 6.072724) > 0.003 or quarter.distance_to(Vector3(0.917559, 1.118591, 0.45878)) > 0.003 or middle.distance_to(Vector3(2, 2, 1)) > 0.001 or three_quarter.distance_to(Vector3(3.082441, 1.11859, 1.541221)) > 0.003:
		return _fail(path, "bent baked path mismatch length=%.6f q=%s mid=%s tq=%s" % [length, quarter, middle, three_quarter])
	path.free()
	print("PASS curve3d_path bent length=6.072724 quarter_y=1.118591 midpoint_y=2.000000")
	quit(0)

func _fail(path: Path3D, reason: String) -> bool:
	path.free()
	push_error("curve3d_path: " + reason)
	quit(1)
	return true
