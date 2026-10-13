# In-flight scripted NavigationAgent3D target change in live physics callbacks.
extends SceneTree
var owned: Array[RID] = []
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var retarget := not ("--fixed" in OS.get_cmdline_user_args())
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
	var actor := preload("res://navretarget3d_driver.gd").new()
	actor.position = Vector3(1, 0, 1)
	actor.retarget = retarget
	root.add_child(actor)
	var agent := NavigationAgent3D.new()
	actor.add_child(agent)
	agent.set_navigation_map(map)
	agent.target_position = Vector3(3, 0, 3)
	actor.agent = agent
	for i in range(125):
		await physics_frame
	if not actor.is_inside_tree() or agent.get_parent() != actor or actor.agent != agent or agent.get_navigation_map() != map or not NavigationServer3D.map_is_active(map) or NavigationServer3D.map_get_regions(map).size() != 1 or mesh.get_polygon_count() != 1:
		return _fail(actor, "live agent/map setup absent")
	if actor.ticks != 120 or absf(actor.delta_sum - 2.0) > 0.003 or actor.first_next.distance_to(Vector3(1, 0, 1)) > 0.001 or actor.before_switch.distance_to(Vector3(1.730676, 0, 1.730676)) > 0.004:
		return _fail(actor, "pre-switch callbacks/motion mismatch ticks=%d first_next=%s before=%s" % [actor.ticks, actor.first_next, actor.before_switch])
	var expected_end := Vector3(1, 0, 3) if retarget else Vector3(3, 0, 3)
	var expected_start := actor.before_switch if retarget else Vector3(1, 0, 1)
	if actor.after_path.size() != 2 or actor.after_path[0].distance_to(expected_start) > 0.004 or actor.after_path[1].distance_to(expected_end) > 0.001 or actor.after_next.distance_to(expected_end) > 0.001:
		return _fail(actor, "agent route after switch mismatch path=%s next=%s" % [actor.after_path, actor.after_next])
	if actor.final.distance_to(expected_end) > 0.001 or actor.global_position.distance_to(actor.final) > 0.001 or not agent.is_target_reached() or not agent.is_navigation_finished():
		return _fail(actor, "agent-guided actor endpoint mismatch final=%s target=%s reached=%s finished=%s" % [actor.final, agent.target_position, agent.is_target_reached(), agent.is_navigation_finished()])
	_cleanup(actor)
	if retarget:
		print("PASS navagent3d_retarget callbacks=120 before=1.730676,0.000,1.730676 after_end=1.000,0.000,3.000 final=1.000,0.000,3.000")
		quit(0)
	else:
		print("NEGATIVE REJECTED: navagent3d_retarget fixed callbacks=120 after_end=3.000,0.000,3.000 final=3.000,0.000,3.000")
		quit(2)

func _cleanup(actor: Node3D) -> void:
	actor.free()
	for rid in owned:
		NavigationServer3D.free_rid(rid)
	owned.clear()

func _fail(actor: Node3D, reason: String) -> bool:
	_cleanup(actor)
	push_error("navagent3d_retarget: " + reason)
	quit(1)
	return true
