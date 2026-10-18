# Two indexed mesh faces converted to one static concave collider; query both.
extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var reversed := "--reversed" in OS.get_cmdline_user_args()
	var vertices := PackedVector3Array([Vector3(0, 0, 0), Vector3(2, 0, 0), Vector3(2, 2, 0), Vector3(0, 2, 0)])
	var indices := PackedInt32Array([0, 2, 3, 0, 1, 2] if reversed else [0, 1, 2, 0, 2, 3])
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var generated := mesh.create_trimesh_shape()
	generated.backface_collision = true
	var collision := CollisionShape3D.new()
	collision.shape = generated
	var body := StaticBody3D.new()
	body.collision_layer = 1
	body.add_child(collision)
	root.add_child(body)
	for i in range(4):
		await physics_frame
	var space := root.get_world_3d().direct_space_state
	var hits := []
	for xy in [Vector2(1.5, 0.5), Vector2(0.5, 1.5), Vector2(3, 1)]:
		var query := PhysicsRayQueryParameters3D.create(Vector3(xy.x, xy.y, 2), Vector3(xy.x, xy.y, -2))
		query.collision_mask = 1
		query.hit_back_faces = true
		hits.append(space.intersect_ray(query))
	if not body.is_inside_tree() or collision.shape != generated or not generated is ConcavePolygonShape3D or not generated.backface_collision or mesh.get_surface_count() != 1 or generated.get_faces().size() != 6:
		return _fail(body, "generated two-face collision setup absent")
	if hits.size() != 3 or hits[0].is_empty() or hits[1].is_empty() or not hits[2].is_empty():
		return _fail(body, "two-face hit/miss routing mismatch hits=%s" % hits)
	for j in range(2):
		var expected_xy := Vector2(1.5, 0.5) if j == 0 else Vector2(0.5, 1.5)
		var expected_index := (1 - j) if reversed else j
		var hit: Dictionary = hits[j]
		if hit.get("collider") != body or hit.get("collider_id") != body.get_instance_id() or hit.get("face_index") != expected_index or (hit.get("position", Vector3.INF) as Vector3).distance_to(Vector3(expected_xy.x, expected_xy.y, 0)) > 0.0001 or (hit.get("normal", Vector3.INF) as Vector3).distance_to(Vector3(0, 0, 1)) > 0.0001:
			return _fail(body, "face hit mismatch ray=%d expected_face=%d actual=%s" % [j, expected_index, hit])
	body.free()
	if reversed:
		print("NEGATIVE REJECTED: mesh3d_faces_hit reordered face_a=1 face_b=0 outside_hits=0")
		quit(2)
	else:
		print("PASS mesh3d_faces_hit two_faces face_a=0 face_b=1 outside_hits=0")
		quit(0)

func _fail(body: StaticBody3D, reason: String) -> bool:
	body.free()
	push_error("mesh3d_faces_hit: " + reason)
	quit(1)
	return true
