# Scripted NavigationAgent3D next-point following in live physics callback.
extends SceneTree
var owned: Array[RID] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var stationary := "--stationary" in OS.get_cmdline_user_args()
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
	var actor := preload("res://navfollow3d_driver.gd").new()
	actor.position = Vector3(1, 0, 1)
	actor.stationary = stationary
	root.add_child(actor)
	var agent := NavigationAgent3D.new()
	actor.add_child(agent)
	agent.set_navigation_map(map)
	agent.target_position = Vector3(3, 0, 3)
	actor.agent = agent
	for i in range(95):
		await physics_frame
	if not actor.is_inside_tree() or agent.get_parent() != actor or actor.agent != agent or agent.get_navigation_map() != map or not NavigationServer3D.map_is_active(map) or NavigationServer3D.map_get_regions(map).size() != 1 or mesh.get_polygon_count() != 1 or agent.target_position.distance_to(Vector3(3, 0, 3)) > 0.0001:
		return _fail(actor, "live navigation follow setup absent")
	if actor.ticks != 90 or absf(actor.delta_sum - 1.5) > 0.003 or actor.first_next.distance_to(Vector3(1, 0, 1)) > 0.001:
		return _fail(actor, "callback count/delta/initial next mismatch ticks=%d sum=%.6f next=%s" % [actor.ticks, actor.delta_sum, actor.first_next])
	var path := agent.get_current_navigation_path()
	if path.size() != 2 or path[0].distance_to(Vector3(1, 0, 1)) > 0.001 or path[1].distance_to(Vector3(3, 0, 3)) > 0.001:
		return _fail(actor, "agent path setup absent path=%s" % path)
	if stationary:
		if actor.first.distance_to(Vector3(1, 0, 1)) > 0.001 or actor.final.distance_to(Vector3(1, 0, 1)) > 0.001 or agent.is_target_reached() or agent.is_navigation_finished():
			return _fail(actor, "stationary navigation actor moved first=%s final=%s" % [actor.first, actor.final])
		_cleanup(actor)
		print("NEGATIVE REJECTED: navagent3d_follow stationary callbacks=90 final=1.000,0.000,1.000 reached=false")
		quit(2)
		return
	if actor.first.distance_to(Vector3(1.612825, 0, 1.612825)) > 0.004 or actor.final.distance_to(Vector3(3, 0, 3)) > 0.001 or actor.global_position.distance_to(actor.final) > 0.001 or not agent.is_target_reached() or not agent.is_navigation_finished():
		return _fail(actor, "agent-guided actor motion mismatch first=%s final=%s reached=%s finished=%s" % [actor.first, actor.final, agent.is_target_reached(), agent.is_navigation_finished()])
	_cleanup(actor)
	print("PASS navagent3d_follow callbacks=90 first=1.612825,0.000,1.612825 final=3.000,0.000,3.000 reached=true")
	quit(0)

func _cleanup(actor: Node3D) -> void:
	actor.free()
	for rid in owned:
		NavigationServer3D.free_rid(rid)
	owned.clear()

func _fail(actor: Node3D, reason: String) -> bool:
	_cleanup(actor)
	push_error("navagent3d_follow: " + reason)
	quit(1)
	return true
