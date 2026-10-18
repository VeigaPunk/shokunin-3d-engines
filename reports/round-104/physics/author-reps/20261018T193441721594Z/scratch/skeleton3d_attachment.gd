# Live BoneAttachment3D and marker follow two-bone Skeleton3D pose.
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
	var attachment := BoneAttachment3D.new()
	attachment.bone_name = "Tip"
	skeleton.add_child(attachment)
	var marker := Node3D.new()
	marker.position = Vector3(1, 0, 0)
	attachment.add_child(marker)
	root.add_child(skeleton)
	await process_frame
	skeleton.set_bone_pose_rotation(0, Quaternion(Vector3(0, 0, 1), 0 if unrotated else PI / 2))
	skeleton.set_bone_pose_position(1, Vector3(0, 3, 0))
	for i in range(4):
		await process_frame
	if not skeleton.is_inside_tree() or skeleton.get_bone_count() != 2 or skeleton.get_bone_parent(1) != 0 or skeleton.get_bone_global_rest(1).origin.distance_to(Vector3(1, 2, 0)) > 0.0001 or attachment.bone_name != "Tip" or attachment.get_bone_idx() != 1 or attachment.get_parent() != skeleton or marker.get_parent() != attachment:
		return _fail(skeleton, "bone attachment/rest setup absent")
	var pose := skeleton.get_bone_global_pose(1)
	var expected_attachment := Vector3(0, 3, 0) if unrotated else Vector3(-3, 0, 0)
	var expected_marker := Vector3(1, 3, 0) if unrotated else Vector3(-3, 1, 0)
	var expected_x := Vector3(1, 0, 0) if unrotated else Vector3(0, 1, 0)
	if pose.origin.distance_to(expected_attachment) > 0.0001 or attachment.position.distance_to(expected_attachment) > 0.0001 or attachment.basis.x.distance_to(expected_x) > 0.0001:
		return _fail(skeleton, "attachment follow mismatch pose=%s attachment=%s basis_x=%s" % [pose.origin, attachment.position, attachment.basis.x])
	if marker.position.distance_to(Vector3(1, 0, 0)) > 0.0001 or marker.global_position.distance_to(expected_marker) > 0.0001 or marker.global_basis.x.distance_to(expected_x) > 0.0001:
		return _fail(skeleton, "attached marker mismatch global=%s basis_x=%s" % [marker.global_position, marker.global_basis.x])
	skeleton.free()
	if unrotated:
		print("NEGATIVE REJECTED: skeleton3d_attachment unrotated attached_marker=1.000,3.000,0.000")
		quit(2)
	else:
		print("PASS skeleton3d_attachment parent_z=90 attached_marker=-3.000,1.000,0.000")
		quit(0)

func _fail(skeleton: Skeleton3D, reason: String) -> bool:
	skeleton.free()
	push_error("skeleton3d_attachment: " + reason)
	quit(1)
	return true
