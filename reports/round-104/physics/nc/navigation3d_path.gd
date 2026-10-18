# Round 13: NavigationServer3D map with a 4x4 planar polygon, headless only.
# Reproduce: run_battery.py --only navigation3d_path,navigation3d_path_disconnected
# Positive exact marker: PASS navigation3d_path points=2 start=1.000,0.000,1.000 end=3.000,0.000,3.000 region_active=true
# Negative exact marker: NEGATIVE REJECTED: navigation3d_path disconnected_endpoint_rejected source_end=4.000,0.000,3.000 target_end=23.000,0.000,3.000 source_control_points=2 target_control_points=2
# No rendering, mesh baking, agent avoidance, or movement claim.
extends SceneTree

const FRAME_BOUND := 1200
var frames := 0
var owned_rids: Array[RID] = []

func _initialize() -> void:
	call_deferred("_run")

func _process(_delta: float) -> bool:
	frames += 1
	if frames > FRAME_BOUND:
		push_error("navigation3d_path: frame bound exceeded")
		quit(1)
		return true
	return false

func _run() -> void:
	var map := NavigationServer3D.map_create()
	owned_rids.append(map)
	NavigationServer3D.map_set_active(map, true)
	NavigationServer3D.map_set_cell_size(map, 0.25)
	var mesh := NavigationMesh.new()
	mesh.vertices = PackedVector3Array([Vector3(0, 0, 0), Vector3(4, 0, 0), Vector3(4, 0, 4), Vector3(0, 0, 4)])
	mesh.add_polygon(PackedInt32Array([0, 3, 2, 1]))
	var region := NavigationServer3D.region_create()
	owned_rids.append(region)
	NavigationServer3D.region_set_map(region, map)
	NavigationServer3D.region_set_navigation_mesh(region, mesh)
	var source_start := Vector3(1, 0, 1)
	var source_end := Vector3(3, 0, 3)
	var source_path := PackedVector3Array()
	for i in range(120):
		await physics_frame
		source_path = NavigationServer3D.map_get_path(map, source_start, source_end, true)
		if source_path.size() > 0:
			break
	if not NavigationServer3D.map_is_active(map) or NavigationServer3D.map_get_regions(map).size() != 1 \
			or mesh.get_polygon_count() != 1 or source_path.size() != 2 \
			or source_path[0].distance_to(Vector3(1, 0, 1)) > 0.001 \
			or source_path[1].distance_to(Vector3(3, 0, 3)) > 0.001:
		_fail("source map/path setup failed points=%d iteration=%d" % [source_path.size(), NavigationServer3D.map_get_iteration_id(map)])
		return
	if "--disconnected" in OS.get_cmdline_user_args():
		var target_map := NavigationServer3D.map_create()
		owned_rids.append(target_map)
		NavigationServer3D.map_set_active(target_map, true)
		NavigationServer3D.map_set_cell_size(target_map, 0.25)
		var target_region := NavigationServer3D.region_create()
		owned_rids.append(target_region)
		NavigationServer3D.region_set_map(target_region, target_map)
		NavigationServer3D.region_set_navigation_mesh(target_region, mesh)
		NavigationServer3D.region_set_transform(target_region, Transform3D(Basis.IDENTITY, Vector3(20, 0, 0)))
		var target_path := PackedVector3Array()
		for i in range(120):
			await physics_frame
			target_path = NavigationServer3D.map_get_path(target_map, Vector3(21, 0, 1), Vector3(23, 0, 3), true)
			if target_path.size() == 2 and target_path[1].distance_to(Vector3(23, 0, 3)) < 0.001:
				break
		var unreachable := NavigationServer3D.map_get_path(map, source_start, Vector3(23, 0, 3), true)
		if not NavigationServer3D.map_is_active(target_map) or NavigationServer3D.map_get_regions(target_map).size() != 1 \
				or target_path.size() != 2 or target_path[0].distance_to(Vector3(21, 0, 1)) > 0.001 \
				or target_path[1].distance_to(Vector3(23, 0, 3)) > 0.001:
			_fail("target control not navigable; disconnection would not discriminate")
			return
		if unreachable.size() != 2 or unreachable[0].distance_to(Vector3(1, 0, 1)) > 0.001 \
				or unreachable[1].distance_to(Vector3(4, 0, 3)) > 0.001 \
				or unreachable[1].distance_to(Vector3(23, 0, 3)) < 1.0:
			_fail("source map did not clamp disconnected destination to authored boundary path=%s" % str(unreachable))
			return
		print("NEGATIVE REJECTED: navigation3d_path disconnected_endpoint_rejected source_end=4.000,0.000,3.000 target_end=23.000,0.000,3.000 source_control_points=2 target_control_points=2")
		_cleanup()
		quit(2)
		return
	print("PASS navigation3d_path points=2 start=1.000,0.000,1.000 end=3.000,0.000,3.000 region_active=true")
	_cleanup()
	quit(0)

func _cleanup() -> void:
	for rid in owned_rids:
		NavigationServer3D.free_rid(rid)
	owned_rids.clear()

func _fail(message: String) -> void:
	_cleanup()
	push_error("navigation3d_path: " + message)
	quit(1)
