# Procedural ArrayMesh surface and live MeshInstance3D bounds.
extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var shifted := "--shifted" in OS.get_cmdline_user_args()
	var vertices := PackedVector3Array([Vector3(0, 0, 0), Vector3(2, 0, 0), Vector3(0, 3, 1 if shifted else 0)])
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	root.add_child(instance)
	var readback := mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array
	if mesh.get_surface_count() != 1 or mesh.surface_get_primitive_type(0) != Mesh.PRIMITIVE_TRIANGLES or instance.mesh != mesh or readback.size() != 3 or readback[0] != Vector3.ZERO or readback[1] != Vector3(2, 0, 0):
		return _fail(instance, "surface/instance setup absent")
	var expected_z := 1.0 if shifted else 0.0
	if readback[2].distance_to(Vector3(0, 3, expected_z)) > 0.0001:
		return _fail(instance, "vertex readback mismatch last=%s" % readback[2])
	var bounds := mesh.get_aabb()
	var live_bounds := instance.get_aabb()
	if bounds.position.distance_to(Vector3.ZERO) > 0.0001 or absf(bounds.size.x - 2.0) > 0.0001 or absf(bounds.size.y - 3.0) > 0.0001 or absf(bounds.size.z - (1.0 if shifted else 0.00001)) > 0.0001 or live_bounds != bounds:
		return _fail(instance, "mesh/instance bounds mismatch mesh=%s instance=%s" % [bounds, live_bounds])
	instance.free()
	if shifted:
		print("NEGATIVE REJECTED: mesh3d_array shifted_vertex last_z=1.000 aabb_size=2.000,3.000,1.000")
		quit(2)
	else:
		print("PASS mesh3d_array triangle last_z=0.000 aabb_size=2.000,3.000,0.00001")
		quit(0)

func _fail(instance: MeshInstance3D, reason: String) -> bool:
	instance.free()
	push_error("mesh3d_array: " + reason)
	quit(1)
	return true
