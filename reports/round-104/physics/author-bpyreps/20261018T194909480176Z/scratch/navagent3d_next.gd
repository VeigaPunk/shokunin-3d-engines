# Live NavigationAgent3D path query on authored NavigationServer3D region.
extends SceneTree
var owned: Array[RID] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var alternate := "--alternate" in OS.get_cmdline_user_args()
	var map := NavigationServer3D.map_create()
	owned.append(map)
	NavigationServer3D.map_set_active(map, true)
	NavigationServer3D.map_set_cell_size(map, 0.25)
	var mesh := NavigationMesh.new()
	mesh.vertices = PackedVector3Array([Vector3(0, 0, 0), Vector3(4, 0, 0), Vector3(4, 0, 4), Vector3(0, 0, 4)])
	mesh.add_polygon(PackedInt32Array([0, 3, 2, 1]))
	var region := NavigationServer3D.region_create()
	owned.append(region)
	NavigationServer3D.region_set_map(region, map)
	NavigationServer3D.region_set_navigation_mesh(region, mesh)
	var actor := Node3D.new()
	actor.position = Vector3(1, 0, 1)
	root.add_child(actor)
	var agent := NavigationAgent3D.new()
	actor.add_child(agent)
	agent.set_navigation_map(map)
	agent.target_position = Vector3(3, 0, 1 if alternate else 3)
	for i in range(30):
		await physics_frame
	var next := agent.get_next_path_position()
	var path := agent.get_current_navigation_path()
	if not actor.is_inside_tree() or agent.get_parent() != actor or agent.get_navigation_map() != map or not NavigationServer3D.map_is_active(map) or NavigationServer3D.map_get_regions(map).size() != 1 or mesh.get_polygon_count() != 1 or actor.global_position.distance_to(Vector3(1, 0, 1)) > 0.0001:
		return _fail(actor, "live navigation agent/map setup absent")
	if path.size() != 2 or path[0].distance_to(Vector3(1, 0, 1)) > 0.001 or agent.is_navigation_finished():
		return _fail(actor, "agent route setup failed path=%s" % path)
	var expected_end := Vector3(3, 0, 1) if alternate else Vector3(3, 0, 3)
	if path[1].distance_to(expected_end) > 0.001 or next.distance_to(expected_end) > 0.001:
		return _fail(actor, "agent next position mismatch path=%s next=%s" % [path, next])
	_cleanup(actor)
	if alternate:
		print("NEGATIVE REJECTED: navagent3d_next alternate path_end=3.000,0.000,1.000 next=3.000,0.000,1.000")
		quit(2)
	else:
		print("PASS navagent3d_next path_end=3.000,0.000,3.000 next=3.000,0.000,3.000")
		quit(0)

func _cleanup(actor: Node3D) -> void:
	actor.free()
	for rid in owned:
		NavigationServer3D.free_rid(rid)
	owned.clear()

func _fail(actor: Node3D, reason: String) -> bool:
	_cleanup(actor)
	push_error("navagent3d_next: " + reason)
	quit(1)
	return true
