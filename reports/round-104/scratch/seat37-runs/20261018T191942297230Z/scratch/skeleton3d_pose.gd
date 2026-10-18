# Two-bone Skeleton3D hierarchy, rest and child pose data readback.
extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var rest_only := "--rest-only" in OS.get_cmdline_user_args()
	var skeleton := Skeleton3D.new()
	skeleton.add_bone("Root")
	skeleton.add_bone("Tip")
	skeleton.set_bone_parent(1, 0)
	skeleton.set_bone_rest(0, Transform3D(Basis.IDENTITY, Vector3(1, 0, 0)))
	skeleton.set_bone_rest(1, Transform3D(Basis.IDENTITY, Vector3(0, 2, 0)))
	root.add_child(skeleton)
	await process_frame
	if not rest_only:
		skeleton.set_bone_pose_position(1, Vector3(0, 3, 0))
	await process_frame
	if not skeleton.is_inside_tree() or skeleton.get_bone_count() != 2 or skeleton.find_bone("Root") != 0 or skeleton.find_bone("Tip") != 1 or skeleton.get_bone_parent(1) != 0 or skeleton.get_bone_parent(0) != -1:
		return _fail(skeleton, "bone hierarchy setup absent")
	if skeleton.get_bone_rest(0).origin.distance_to(Vector3(1, 0, 0)) > 0.0001 or skeleton.get_bone_rest(1).origin.distance_to(Vector3(0, 2, 0)) > 0.0001 or skeleton.get_bone_global_rest(1).origin.distance_to(Vector3(1, 2, 0)) > 0.0001:
		return _fail(skeleton, "rest hierarchy readback mismatch")
	var local_pose := skeleton.get_bone_pose_position(1)
	var pose_transform := skeleton.get_bone_pose(1)
	var global_pose := skeleton.get_bone_global_pose(1)
	var expected_pose := Vector3.ZERO if rest_only else Vector3(0, 3, 0)
	if local_pose.distance_to(expected_pose) > 0.0001 or pose_transform.origin.distance_to(expected_pose) > 0.0001 or global_pose.origin.distance_to(expected_pose) > 0.0001 or skeleton.get_bone_global_pose(0).origin.distance_to(Vector3.ZERO) > 0.0001:
		return _fail(skeleton, "bone pose readback mismatch local=%s pose=%s global=%s" % [local_pose, pose_transform.origin, global_pose.origin])
	skeleton.free()
	if rest_only:
		print("NEGATIVE REJECTED: skeleton3d_pose rest_only child_rest=1.000,2.000,0.000 child_pose_y=0.000")
		quit(2)
	else:
		print("PASS skeleton3d_pose parent=0 child_rest=1.000,2.000,0.000 child_pose_y=3.000")
		quit(0)

func _fail(skeleton: Skeleton3D, reason: String) -> bool:
	skeleton.free()
	push_error("skeleton3d_pose: " + reason)
	quit(1)
	return true
