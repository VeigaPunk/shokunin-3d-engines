# Stationary NavigationAgent3D distance and reach-threshold queries on an
# authored NavigationServer3D region (round 69).
# Positive: agent at (1,0,1), target (3,0,3), default target_desired_distance
# 1.0. distance_to_target must measure 2*sqrt(2)=2.828427 against the live
# region; get_final_position the authored target; reached/finished false while
# reachable true.
# Negative --wide-reach: identical geometry with target_desired_distance=3.0,
# exceeding the measured distance, so is_target_reached/is_navigation_finished
# flip true without any movement while distance stays 2.828427.
# No agent motion, avoidance, baking, or rendering claim.
extends SceneTree
var owned: Array[RID] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var wide := "--wide-reach" in OS.get_cmdline_user_args()
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
	if wide:
		agent.target_desired_distance = 3.0
	agent.target_position = Vector3(3, 0, 3)
	for i in range(30):
		await physics_frame
	var distance := agent.distance_to_target()
	var final := agent.get_final_position()
	var next := agent.get_next_path_position()
	var reached := agent.is_target_reached()
	var reachable := agent.is_target_reachable()
	var finished := agent.is_navigation_finished()
	if not actor.is_inside_tree() or agent.get_parent() != actor or agent.get_navigation_map() != map \
			or not NavigationServer3D.map_is_active(map) or NavigationServer3D.map_get_regions(map).size() != 1 \
			or mesh.get_polygon_count() != 1 or actor.global_position.distance_to(Vector3(1, 0, 1)) > 0.0001 \
			or agent.target_position.distance_to(Vector3(3, 0, 3)) > 0.0001 \
			or absf(agent.target_desired_distance - (3.0 if wide else 1.0)) > 0.0001:
		return _fail(actor, "live navigation agent/map setup absent")
	if absf(distance - 2.828427) > 0.004 or final.distance_to(Vector3(3, 0, 3)) > 0.001 \
			or next.distance_to(Vector3(3, 0, 3)) > 0.001 or not reachable:
		return _fail(actor, "measured distance/final/next mismatch distance=%.6f final=%s next=%s reachable=%s" % [distance, final, next, reachable])
	if wide:
		if not reached or not finished:
			return _fail(actor, "wide reach threshold did not register reached=%s finished=%s" % [reached, finished])
		_cleanup(actor)
		print("NEGATIVE REJECTED: navagent3d_distance wide_reach distance=%.6f reached=true finished=true reachable=true" % distance)
		quit(2)
	else:
		if reached or finished:
			return _fail(actor, "default reach threshold wrongly satisfied reached=%s finished=%s" % [reached, finished])
		_cleanup(actor)
		print("PASS navagent3d_distance distance=%.6f final=3.000,0.000,3.000 next=3.000,0.000,3.000 reached=false reachable=true finished=false" % distance)
		quit(0)

func _cleanup(actor: Node3D) -> void:
	actor.free()
	for rid in owned:
		NavigationServer3D.free_rid(rid)
	owned.clear()

func _fail(actor: Node3D, reason: String) -> bool:
	_cleanup(actor)
	push_error("navagent3d_distance: " + reason)
	quit(1)
	return true
