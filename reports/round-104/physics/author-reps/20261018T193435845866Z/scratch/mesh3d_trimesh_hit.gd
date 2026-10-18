# Procedural ArrayMesh converted to concave static collision and queried by ray.
extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var outside := "--outside" in OS.get_cmdline_user_args()
	var vertices := PackedVector3Array([Vector3(0, 0, 0), Vector3(2, 0, 0), Vector3(0, 3, 0)])
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
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
	if not body.is_inside_tree() or collision.shape != generated or not generated is ConcavePolygonShape3D or not generated.backface_collision or generated.get_faces().size() != 3 or mesh.get_surface_count() != 1:
		return _fail(body, "generated collision setup absent")
	var control_query := PhysicsRayQueryParameters3D.create(Vector3(0.5, 0.5, 2), Vector3(0.5, 0.5, -2))
	control_query.collision_mask = 1
	control_query.hit_back_faces = true
	var space := root.get_world_3d().direct_space_state
	var control := space.intersect_ray(control_query)
	if control.is_empty():
		return _fail(body, "interior ray missed generated mesh")
	if control.get("collider") != body or control.get("collider_id") != body.get_instance_id() or control.get("face_index") != 0 or (control.get("position", Vector3.INF) as Vector3).distance_to(Vector3(0.5, 0.5, 0)) > 0.0001 or (control.get("normal", Vector3.INF) as Vector3).distance_to(Vector3(0, 0, 1)) > 0.0001:
		return _fail(body, "mesh ray hit mismatch hit=%s" % control)
	var miss_query := PhysicsRayQueryParameters3D.create(Vector3(3, 0.5, 2), Vector3(3, 0.5, -2))
	miss_query.collision_mask = 1
	miss_query.hit_back_faces = true
	var miss := space.intersect_ray(miss_query)
	if not miss.is_empty():
		return _fail(body, "outside ray unexpectedly hit=%s" % miss)
	body.free()
	if outside:
		print("NEGATIVE REJECTED: mesh3d_trimesh_hit outside_ray control_hit=0.500,0.500,0.000 outside_hits=0 face_index=0")
		quit(2)
	else:
		print("PASS mesh3d_trimesh_hit interior_hit=0.500,0.500,0.000 normal_z=1.000 face_index=0 outside_hits=0")
		quit(0)

func _fail(body: StaticBody3D, reason: String) -> bool:
	body.free()
	push_error("mesh3d_trimesh_hit: " + reason)
	quit(1)
	return true
