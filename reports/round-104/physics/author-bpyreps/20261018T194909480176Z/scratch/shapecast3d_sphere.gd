# Live ShapeCast3D sphere toward static box versus lateral miss.
extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var offset := "--offset" in OS.get_cmdline_user_args()
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(2, 2, 2)
	var collider := CollisionShape3D.new()
	collider.shape = box_shape
	var wall := StaticBody3D.new()
	wall.name = "Target"
	wall.collision_layer = 1
	wall.add_child(collider)
	root.add_child(wall)
	var sphere := SphereShape3D.new()
	sphere.radius = 0.5
	var cast := ShapeCast3D.new()
	cast.shape = sphere
	cast.collision_mask = 1
	cast.position = Vector3(4 if offset else 0, 0, 4)
	cast.target_position = Vector3(0, 0, -6)
	root.add_child(cast)
	for i in range(4):
		await physics_frame
	cast.force_shapecast_update()
	if not cast.is_inside_tree() or not wall.is_inside_tree() or cast.shape != sphere or sphere.radius != 0.5 or box_shape.size != Vector3(2, 2, 2) or cast.target_position != Vector3(0, 0, -6) or (cast.collision_mask & wall.collision_layer) == 0:
		return _fail(cast, wall, "live shape/target setup absent")
	if offset:
		if cast.is_colliding() or cast.get_collision_count() != 0 or absf(cast.get_closest_collision_safe_fraction() - 1.0) > 0.0001:
			return _fail(cast, wall, "lateral cast unexpectedly hit count=%d safe=%.6f" % [cast.get_collision_count(), cast.get_closest_collision_safe_fraction()])
		cast.free()
		wall.free()
		print("NEGATIVE REJECTED: shapecast3d_sphere lateral_miss x=4.000 hits=0 safe=1.000")
		quit(2)
		return
	if not cast.is_colliding() or cast.get_collision_count() != 1:
		return _fail(cast, wall, "center sphere cast missed count=%d" % cast.get_collision_count())
	var point := cast.get_collision_point(0)
	var normal := cast.get_collision_normal(0)
	if cast.get_collider(0) != wall or cast.get_collider(0).get_instance_id() != wall.get_instance_id() or point.distance_to(Vector3(0, 0, 1)) > 0.0001 or normal.distance_to(Vector3(0, 0, 1)) > 0.0001 or absf(cast.get_closest_collision_safe_fraction() - 0.4140625) > 0.002 or absf(cast.get_closest_collision_unsafe_fraction() - 0.41796875) > 0.002:
		return _fail(cast, wall, "sphere cast hit mismatch point=%s normal=%s safe=%.6f unsafe=%.6f" % [point, normal, cast.get_closest_collision_safe_fraction(), cast.get_closest_collision_unsafe_fraction()])
	cast.free()
	wall.free()
	print("PASS shapecast3d_sphere radius=0.500 contact_z=1.000 safe=0.414062 unsafe=0.417969 hits=1")
	quit(0)

func _fail(cast: ShapeCast3D, wall: StaticBody3D, reason: String) -> bool:
	cast.free()
	wall.free()
	push_error("shapecast3d_sphere: " + reason)
	quit(1)
	return true
