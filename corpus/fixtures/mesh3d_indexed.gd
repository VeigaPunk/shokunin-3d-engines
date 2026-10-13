# Indexed four-vertex quad: two CPU-readback triangles and reversed winding control.
extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var reversed := "--reversed" in OS.get_cmdline_user_args()
	var vertices := PackedVector3Array([Vector3(0, 0, 0), Vector3(2, 0, 0), Vector3(2, 3, 0), Vector3(0, 3, 0)])
	var indices := PackedInt32Array([0, 2, 1, 0, 3, 2] if reversed else [0, 1, 2, 0, 2, 3])
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	root.add_child(instance)
	var returned := mesh.surface_get_arrays(0)
	var read_vertices := returned[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var read_indices := returned[Mesh.ARRAY_INDEX] as PackedInt32Array
	var cross0 := (read_vertices[read_indices[1]] - read_vertices[read_indices[0]]).cross(read_vertices[read_indices[2]] - read_vertices[read_indices[0]])
	var cross1 := (read_vertices[read_indices[4]] - read_vertices[read_indices[3]]).cross(read_vertices[read_indices[5]] - read_vertices[read_indices[3]])
	if mesh.get_surface_count() != 1 or mesh.surface_get_primitive_type(0) != Mesh.PRIMITIVE_TRIANGLES or instance.mesh != mesh or read_vertices.size() != 4 or read_indices.size() != 6:
		return _fail(instance, "indexed surface setup absent")
	if read_vertices != PackedVector3Array([Vector3(0, 0, 0), Vector3(2, 0, 0), Vector3(2, 3, 0), Vector3(0, 3, 0)]):
		return _fail(instance, "vertex readback mismatch vertices=%s" % read_vertices)
	var expected_indices := PackedInt32Array([0, 2, 1, 0, 3, 2] if reversed else [0, 1, 2, 0, 2, 3])
	if read_indices != expected_indices:
		return _fail(instance, "index readback mismatch indices=%s" % read_indices)
	var expected_cross := Vector3(0, 0, -6 if reversed else 6)
	if cross0.distance_to(expected_cross) > 0.0001 or cross1.distance_to(expected_cross) > 0.0001:
		return _fail(instance, "triangle cross mismatch first=%s second=%s" % [cross0, cross1])
	var bounds := mesh.get_aabb()
	if bounds.position != Vector3.ZERO or bounds.size.distance_to(Vector3(2, 3, 0.00001)) > 0.0001 or instance.get_aabb() != bounds:
		return _fail(instance, "indexed bounds mismatch mesh=%s instance=%s" % [bounds, instance.get_aabb()])
	instance.free()
	if reversed:
		print("NEGATIVE REJECTED: mesh3d_indexed reversed_indices triangles=2 cross_z=-6.000 shared_vertices=4")
		quit(2)
	else:
		print("PASS mesh3d_indexed forward_indices triangles=2 cross_z=6.000 shared_vertices=4")
		quit(0)

func _fail(instance: MeshInstance3D, reason: String) -> bool:
	instance.free()
	push_error("mesh3d_indexed: " + reason)
	quit(1)
	return true
