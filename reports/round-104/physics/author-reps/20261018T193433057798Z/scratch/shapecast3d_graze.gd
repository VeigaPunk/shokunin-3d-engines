# Finite-radius grazing ShapeCast3D versus same-path ray and smaller sphere.
extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var small := "--small" in OS.get_cmdline_user_args()
	var wall := StaticBody3D.new()
	wall.collision_layer = 1
	var box := BoxShape3D.new()
	box.size = Vector3(2, 2, 2)
	var collision := CollisionShape3D.new()
	collision.shape = box
	wall.add_child(collision)
	root.add_child(wall)
	var sphere := SphereShape3D.new()
	sphere.radius = 0.1 if small else 0.5
	var cast := ShapeCast3D.new()
	cast.shape = sphere
	cast.position = Vector3(1.25, 0, 4)
	cast.target_position = Vector3(0, 0, -6)
	cast.collision_mask = 1
	root.add_child(cast)
	for i in range(4):
		await physics_frame
	cast.force_shapecast_update()
	var query := PhysicsRayQueryParameters3D.create(Vector3(1.25, 0, 4), Vector3(1.25, 0, -2))
	query.collision_mask = 1
	var ray_hit := root.get_world_3d().direct_space_state.intersect_ray(query)
	if not wall.is_inside_tree() or not cast.is_inside_tree() or box.size != Vector3(2, 2, 2) or cast.shape != sphere or cast.position != Vector3(1.25, 0, 4) or cast.target_position != Vector3(0, 0, -6) or (cast.collision_mask & wall.collision_layer) == 0:
		return _fail(cast, wall, "grazing shape/box setup absent")
	if not ray_hit.is_empty():
		return _fail(cast, wall, "same-path ray unexpectedly hit=%s" % ray_hit)
	if small:
		if absf(sphere.radius - 0.1) > 0.0001 or cast.is_colliding() or cast.get_collision_count() != 0 or absf(cast.get_closest_collision_safe_fraction() - 1.0) > 0.0001:
			return _fail(cast, wall, "small sphere unexpectedly hit count=%d safe=%.6f" % [cast.get_collision_count(), cast.get_closest_collision_safe_fraction()])
		cast.free()
		wall.free()
		print("NEGATIVE REJECTED: shapecast3d_graze small_radius=0.100 sphere_hits=0 ray_hits=0")
		quit(2)
		return
	if not cast.is_colliding() or cast.get_collision_count() != 1:
		return _fail(cast, wall, "finite sphere missed grazing box count=%d" % cast.get_collision_count())
	var point := cast.get_collision_point(0)
	var normal := cast.get_collision_normal(0)
	if cast.get_collider(0) != wall or point.distance_to(Vector3(1, 0, 1)) > 0.0001 or normal.distance_to(Vector3(0.509856, 0, 0.86026)) > 0.003 or absf(cast.get_closest_collision_safe_fraction() - 0.42578125) > 0.002:
		return _fail(cast, wall, "grazing contact mismatch point=%s normal=%s safe=%.6f" % [point, normal, cast.get_closest_collision_safe_fraction()])
	cast.free()
	wall.free()
	print("PASS shapecast3d_graze radius=0.500 sphere_hits=1 ray_hits=0 point=1.000,0.000,1.000 safe=0.425781")
	quit(0)

func _fail(cast: ShapeCast3D, wall: StaticBody3D, reason: String) -> bool:
	cast.free()
	wall.free()
	push_error("shapecast3d_graze: " + reason)
	quit(1)
	return true
