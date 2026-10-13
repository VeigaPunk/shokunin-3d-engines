# RemoteTransform3D source propagates to separate live Node3D target.
extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var unbound := "--unbound" in OS.get_cmdline_user_args()
	var stage := Node3D.new()
	stage.name = "Stage"
	root.add_child(stage)
	var target := Node3D.new()
	target.name = "Target"
	stage.add_child(target)
	var source := RemoteTransform3D.new()
	source.name = "Source"
	stage.add_child(source)
	if not unbound:
		source.remote_path = NodePath("../Target")
	await process_frame
	source.position = Vector3(2, 1, -3)
	source.rotation.z = PI / 2
	for i in range(4):
		await process_frame
	if not stage.is_inside_tree() or source.get_parent() != stage or target.get_parent() != stage or source == target or source.remote_path != (NodePath("") if unbound else NodePath("../Target")) or not source.update_position or not source.update_rotation:
		return _fail(stage, "live remote binding setup absent")
	if source.global_position.length() < 1.0 or source.global_basis.x.distance_to(Vector3(0, 1, 0)) > 0.0001:
		return _fail(stage, "source transform setup absent")
	if unbound:
		if target.global_position.distance_to(Vector3.ZERO) > 0.0001 or target.global_basis.x.distance_to(Vector3(1, 0, 0)) > 0.0001:
			return _fail(stage, "unbound target unexpectedly moved global=%s" % target.global_transform)
		stage.free()
		print("NEGATIVE REJECTED: remote3d_transform unbound target=0.000,0.000,0.000 source=2.000,1.000,-3.000")
		quit(2)
		return
	if target.global_position.distance_to(Vector3(2, 1, -3)) > 0.0001 or target.global_basis.x.distance_to(Vector3(0, 1, 0)) > 0.0001 or target.global_basis.y.distance_to(Vector3(-1, 0, 0)) > 0.0001:
		return _fail(stage, "remote target propagation mismatch target=%s" % target.global_transform)
	stage.free()
	print("PASS remote3d_transform bound target=2.000,1.000,-3.000 basis_x=0.000,1.000,0.000")
	quit(0)

func _fail(stage: Node3D, reason: String) -> bool:
	stage.free()
	push_error("remote3d_transform: " + reason)
	quit(1)
	return true
