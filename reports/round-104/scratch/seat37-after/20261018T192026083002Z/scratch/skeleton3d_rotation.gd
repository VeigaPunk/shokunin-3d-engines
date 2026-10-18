# Root pose Z rotation and child pose translation in live two-bone Skeleton3D.
extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var unrotated := "--unrotated" in OS.get_cmdline_user_args()
	var skeleton := Skeleton3D.new()
	skeleton.add_bone("Root")
	skeleton.add_bone("Tip")
	skeleton.set_bone_parent(1, 0)
	skeleton.set_bone_rest(0, Transform3D(Basis.IDENTITY, Vector3(1, 0, 0)))
	skeleton.set_bone_rest(1, Transform3D(Basis.IDENTITY, Vector3(0, 2, 0)))
	root.add_child(skeleton)
	await process_frame
	skeleton.set_bone_pose_rotation(0, Quaternion(Vector3(0, 0, 1), 0 if unrotated else PI / 2))
	skeleton.set_bone_pose_position(1, Vector3(0, 3, 0))
	await process_frame
	if not skeleton.is_inside_tree() or skeleton.get_bone_count() != 2 or skeleton.get_bone_parent(1) != 0 or skeleton.get_bone_global_rest(1).origin.distance_to(Vector3(1, 2, 0)) > 0.0001:
		return _fail(skeleton, "two-bone rest hierarchy absent")
	if skeleton.get_bone_pose_position(1).distance_to(Vector3(0, 3, 0)) > 0.0001 or skeleton.get_bone_pose(1).origin.distance_to(Vector3(0, 3, 0)) > 0.0001:
		return _fail(skeleton, "child local pose absent")
	var expected_quaternion := Quaternion.IDENTITY if unrotated else Quaternion(Vector3(0, 0, 1), PI / 2)
	if skeleton.get_bone_pose_rotation(0).angle_to(expected_quaternion) > 0.001:
		return _fail(skeleton, "root rotation readback mismatch quaternion=%s" % skeleton.get_bone_pose_rotation(0))
	var child_global := skeleton.get_bone_global_pose(1)
	var expected_origin := Vector3(0, 3, 0) if unrotated else Vector3(-3, 0, 0)
	var expected_x := Vector3(1, 0, 0) if unrotated else Vector3(0, 1, 0)
	var expected_y := Vector3(0, 1, 0) if unrotated else Vector3(-1, 0, 0)
	if child_global.origin.distance_to(expected_origin) > 0.0001 or child_global.basis.x.distance_to(expected_x) > 0.0001 or child_global.basis.y.distance_to(expected_y) > 0.0001:
		return _fail(skeleton, "child composed pose mismatch origin=%s x=%s y=%s" % [child_global.origin, child_global.basis.x, child_global.basis.y])
	skeleton.free()
	if unrotated:
		print("NEGATIVE REJECTED: skeleton3d_rotation unrotated child_global=0.000,3.000,0.000 basis_x=1.000,0.000,0.000")
		quit(2)
	else:
		print("PASS skeleton3d_rotation parent_z=90 child_global=-3.000,0.000,0.000 basis_x=0.000,1.000,0.000")
		quit(0)

func _fail(skeleton: Skeleton3D, reason: String) -> bool:
	skeleton.free()
	push_error("skeleton3d_rotation: " + reason)
	quit(1)
	return true
