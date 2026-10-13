# Stationary NavigationAgent3D distance_to_target semantic discrimination on
# an authored NavigationServer3D region (round 70). Resolves the r69 UNKNOWN:
# Euclidean vs routed path-sum.
# Positive: three convex quads forming an L corridor (A1 x[0,2]z[0,1],
# A2 x[2,3]z[0,1] sharing the full x=2,z[0,1] edge; B x[2,3]z[1,4] sharing the
# full z=1,x[2,3] edge). Agent (0.5,0,0.5) targets (2.5,0,3.5); the routed
# path must bend through portal vertex (2,0,1): path length
# sqrt(2.5)+sqrt(6.5)=4.130649 while the straight distance is sqrt(13)=
# 3.605551 — a 0.525098 gap, ~131x the 0.004 tolerance, so the measured
# distance_to_target discriminates the two candidate semantics. The fixture
# classifies the measurement against both candidates and asserts the
# Euclidean one, plus the bend witness get_next_path_position=(2,0,1) and the
# engine-measured path length 4.130649.
# Negative --straight: convex 4x4 single-polygon control (same seed polygon
# as navagent3d_distance.gd), agent (1,0,1), target (3,0,3): Euclidean and
# path-sum coincide at 2*sqrt(2)=2.828427, so the arm cannot discriminate —
# rejection of the discrimination claim, reproduction of the r69 control.
# Negative --assert-pathsum: same detour geometry, authors the wrong
# hypothesis distance==routed path length 4.130649; the engine measurement
# refutes it (3.605551) and the fixture reports the refutation.
# Post arms (round 71, invariance claim under measurement):
# --post-edgecentered / --post-none set path_postprocessing to
# EDGECENTERED(1)/NONE(2) before target submission on the same detour
# geometry. The claim under test: distance_to_target stays Euclidean to the
# raw target (3.605551) while postprocessing measurably changes the queried
# path. Measured on this build: edgecentered routes via edge midpoints
# (2,0,0.5),(2.5,0,1) — next=(2,0,0.5), pathlen=4.707107; none keeps the raw
# corridor (2,0,0.5),(2,0,1) — next=(2,0,0.5), pathlen=4.549510; corridorfunnel
# control next=(2,0,1), pathlen=4.130649. Each arm pins its own measured path
# (4 points, next=(2,0,0.5)) so a flag that did not take effect cannot pass,
# and classifies distance_to_target: semantic!=euclidean fails the arm with a
# diagnostic carrying the measured distance — the falsification path of the
# invariance claim. get_final_position stays (2.5,0,3.5) under all values.
# No agent motion, avoidance, baking, or rendering claim.
extends SceneTree
var owned: Array[RID] = []

const DIST_TOL := 0.004
const POS_TOL := 0.001
# Hand-derived candidates for the authored detour geometry.
const DETOUR_EUCLID := 3.605551   # sqrt(13)
const DETOUR_PATHLEN := 4.130649  # sqrt(2.5) + sqrt(6.5) via vertex (2,0,1)

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var straight := "--straight" in OS.get_cmdline_user_args()
	var assert_pathsum := "--assert-pathsum" in OS.get_cmdline_user_args()
	var post_edge := "--post-edgecentered" in OS.get_cmdline_user_args()
	var post_none := "--post-none" in OS.get_cmdline_user_args()
	var map := NavigationServer3D.map_create()
	owned.append(map)
	NavigationServer3D.map_set_active(map, true)
	NavigationServer3D.map_set_cell_size(map, 0.25)
	var mesh := NavigationMesh.new()
	var spawn := Vector3(0.5, 0, 0.5)
	var target := Vector3(2.5, 0, 3.5)
	if straight:
		mesh.vertices = PackedVector3Array([Vector3(0, 0, 0), Vector3(4, 0, 0), Vector3(4, 0, 4), Vector3(0, 0, 4)])
		mesh.add_polygon(PackedInt32Array([0, 3, 2, 1]))
		spawn = Vector3(1, 0, 1)
		target = Vector3(3, 0, 3)
	else:
		mesh.vertices = PackedVector3Array([
			Vector3(0, 0, 0), Vector3(0, 0, 1), Vector3(2, 0, 1), Vector3(2, 0, 0),
			Vector3(3, 0, 0), Vector3(3, 0, 1), Vector3(3, 0, 4), Vector3(2, 0, 4)])
		mesh.add_polygon(PackedInt32Array([0, 1, 2, 3]))
		mesh.add_polygon(PackedInt32Array([3, 2, 5, 4]))
		mesh.add_polygon(PackedInt32Array([2, 7, 6, 5]))
	var region := NavigationServer3D.region_create()
	owned.append(region)
	NavigationServer3D.region_set_map(region, map)
	NavigationServer3D.region_set_navigation_mesh(region, mesh)
	var actor := Node3D.new()
	actor.position = spawn
	root.add_child(actor)
	var agent := NavigationAgent3D.new()
	actor.add_child(agent)
	agent.set_navigation_map(map)
	if post_edge:
		agent.path_postprocessing = NavigationPathQueryParameters3D.PATH_POSTPROCESSING_EDGECENTERED
	elif post_none:
		agent.path_postprocessing = NavigationPathQueryParameters3D.PATH_POSTPROCESSING_NONE
	agent.target_position = target
	for i in range(30):
		await physics_frame
	var next := agent.get_next_path_position()
	var path := agent.get_current_navigation_path()
	var pathlen := 0.0
	for i in range(1, path.size()):
		pathlen += path[i - 1].distance_to(path[i])
	var distance := agent.distance_to_target()
	var final := agent.get_final_position()
	var reachable := agent.is_target_reachable()
	var reached := agent.is_target_reached()
	var finished := agent.is_navigation_finished()
	var euclid := spawn.distance_to(target)
	if not actor.is_inside_tree() or agent.get_parent() != actor \
			or agent.get_navigation_map() != map or not NavigationServer3D.map_is_active(map) \
			or NavigationServer3D.map_get_regions(map).size() != 1 \
			or mesh.get_polygon_count() != (1 if straight else 3) \
			or actor.global_position.distance_to(spawn) > 0.0001 \
			or agent.target_position.distance_to(target) > 0.0001:
		return _fail(actor, "live navigation agent/map setup absent")
	# Classify the engine measurement against the two authored candidates.
	var semantic := "unknown"
	if absf(distance - euclid) <= DIST_TOL:
		semantic = "euclidean"
	elif absf(distance - pathlen) <= DIST_TOL:
		semantic = "path_sum"
	if straight:
		if absf(distance - 2.828427) > DIST_TOL or absf(pathlen - 2.828427) > DIST_TOL \
				or absf(euclid - 2.828427) > DIST_TOL \
				or next.distance_to(Vector3(3, 0, 3)) > POS_TOL or not reachable:
			return _fail(actor, "straight control mismatch distance=%.6f euclid=%.6f pathlen=%.6f next=%s reachable=%s" % [distance, euclid, pathlen, next, reachable])
		_cleanup(actor)
		print("NEGATIVE REJECTED: navagent3d_detour straight distance=%.6f euclid=%.6f pathlen=%.6f discriminates=false" % [distance, euclid, pathlen])
		quit(2)
		return
	# Round-71 postprocessing arms: the invariance claim — distance_to_target
	# stays Euclidean to the raw target_position while postprocessing changes
	# the queried path outputs. A changed distance under either value
	# falsifies invariance and is reported with the measured semantic.
	if post_edge or post_none:
		var post_name := "post_edgecentered" if post_edge else "post_none"
		# Engine-measured path lengths: edgecentered 1.5+sqrt(0.5)+2.5,
		# none 1.5+0.5+sqrt(6.5); both differ from corridorfunnel 4.130649.
		var post_pathlen := 4.707107 if post_edge else 4.549510
		if semantic == "unknown":
			return _fail(actor, "bounded UNKNOWN under %s: distance=%.6f matches neither euclid=%.6f nor pathlen=%.6f" % [post_name, distance, euclid, pathlen])
		if semantic != "euclidean":
			return _fail(actor, "invariance falsified under %s semantic=%s distance=%.6f euclid=%.6f pathlen=%.6f" % [post_name, semantic, distance, euclid, pathlen])
		# The flag must have measurably changed the queried path vs the
		# corridorfunnel control (3 points, next=(2,0,1), pathlen=4.130649),
		# else the arm cannot discriminate whether postprocessing applied.
		if path.size() != 4 or next.distance_to(Vector3(2, 0, 0.5)) > POS_TOL \
				or absf(pathlen - post_pathlen) > DIST_TOL \
				or final.distance_to(Vector3(2.5, 0, 3.5)) > POS_TOL or not reachable:
			return _fail(actor, "%s path outputs unexpected path=%s next=%s pathlen=%.6f final=%s reachable=%s" % [post_name, path, next, pathlen, final, reachable])
		if reached or finished:
			return _fail(actor, "%s default reach threshold wrongly satisfied reached=%s finished=%s" % [post_name, reached, finished])
		_cleanup(actor)
		print("PASS navagent3d_detour %s distance=%.6f semantic=%s final=%.3f,%.3f,%.3f next=%.3f,%.3f,%.3f pathlen=%.6f reachable=true reached=false finished=false" % [post_name, distance, semantic, final.x, final.y, final.z, next.x, next.y, next.z, pathlen])
		quit(0)
		return
	# Both detour arms require the bend to be real at query time.
	if path.size() != 3 or next.distance_to(Vector3(2, 0, 1)) > POS_TOL \
			or absf(pathlen - DETOUR_PATHLEN) > DIST_TOL \
			or pathlen - euclid < 0.4 \
			or final.distance_to(Vector3(2.5, 0, 3.5)) > POS_TOL or not reachable:
		return _fail(actor, "detour path absent or unbent next=%s path=%s pathlen=%.6f final=%s reachable=%s" % [next, path, pathlen, final, reachable])
	if assert_pathsum:
		if semantic == "path_sum":
			return _fail(actor, "assert-pathsum premise unexpectedly held distance=%.6f pathlen=%.6f" % [distance, pathlen])
		if semantic == "unknown":
			return _fail(actor, "bounded UNKNOWN: distance=%.6f matches neither euclid=%.6f nor pathlen=%.6f" % [distance, euclid, pathlen])
		_cleanup(actor)
		print("NEGATIVE REJECTED: navagent3d_detour assert_pathsum distance=%.6f expected_pathsum=%.6f euclid=%.6f" % [distance, pathlen, euclid])
		quit(2)
		return
	if semantic == "unknown":
		return _fail(actor, "bounded UNKNOWN: distance=%.6f matches neither euclid=%.6f nor pathlen=%.6f" % [distance, euclid, pathlen])
	if semantic != "euclidean":
		return _fail(actor, "measured semantic=%s not euclidean distance=%.6f pathlen=%.6f" % [semantic, distance, pathlen])
	if reached or finished:
		return _fail(actor, "default reach threshold wrongly satisfied reached=%s finished=%s" % [reached, finished])
	_cleanup(actor)
	print("PASS navagent3d_detour distance=%.6f semantic=%s final=2.500,0.000,3.500 next=2.000,0.000,1.000 pathlen=%.6f reachable=true reached=false finished=false" % [distance, semantic, pathlen])
	quit(0)

func _cleanup(actor: Node3D) -> void:
	actor.free()
	for rid in owned:
		NavigationServer3D.free_rid(rid)
	owned.clear()

func _fail(actor: Node3D, reason: String) -> bool:
	_cleanup(actor)
	push_error("navagent3d_detour: " + reason)
	quit(1)
	return true
