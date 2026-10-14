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
# Round-72 arms (path_desired_distance pop-index vs agent position, and the
# two-mode is_navigation_finished with equality edges): --arm=<name> selects a
# preset from _arm_cfg. Each arm authors spawn/target/pdd/tdd (and optionally a
# post-settle teleport) and pins the full observable tuple: path points, popped
# path index, next point, final, distance, reachable, reached, finished.
# Measured on this build (Godot 4.7.2, single region, stationary or teleported
# agent):
#   pop loop: while idx < size-1 and euclid(agent, path[idx]) < pdd -> idx++ —
#     STRICT (<): an exact euclid==pdd does not pop; keyed on the LIVE agent
#     position (a post-settle teleport re-pops on the FIXED stored path);
#     saturates at the last index so the final point is what next returns.
#   is_target_reached = euclid(agent, raw target) < tdd — STRICT, ignores
#     reachability (fires through walls), latched once true.
#   is_target_reachable = euclid(clamped final, raw target) <= tdd —
#     INCLUSIVE at equality, independent of agent position.
#   is_navigation_finished = reached OR (unreachable AND idx == size-1 AND
#     euclid(agent, clamped final) < pdd) — both sub-gates STRICT, latched;
#     sitting on the final without the pop index reaching it does not finish.
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
	var arm := _argval("--arm=", "")
	var arm_cfg := _arm_cfg(arm) if arm != "" else {}
	if arm != "" and arm_cfg.is_empty():
		push_error("navagent3d_detour: unknown --arm=" + arm)
		quit(1)
		return
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
	if arm != "":
		spawn = arm_cfg["spawn"]
		target = arm_cfg["target"]
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
	if arm != "":
		agent.path_desired_distance = arm_cfg["pdd"]
		agent.target_desired_distance = arm_cfg["tdd"]
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
	# Round-72 pop/finish arms: st is the pre-teleport state (or the only
	# state for non-teleport arms); st2 is the state asserted against cfg.
	var st := {}
	var st2 := {}
	if arm != "":
		st = _read_state(agent, actor)
		if arm_cfg.has("tp"):
			actor.global_position = arm_cfg["tp"]
			for i in range(5):
				await physics_frame
			st2 = _read_state(agent, actor)
		else:
			st2 = st
	var expected_pos := spawn
	if arm != "" and arm_cfg.has("tp"):
		expected_pos = arm_cfg["tp"]
	if not actor.is_inside_tree() or agent.get_parent() != actor \
			or agent.get_navigation_map() != map or not NavigationServer3D.map_is_active(map) \
			or NavigationServer3D.map_get_regions(map).size() != 1 \
			or mesh.get_polygon_count() != (1 if straight else 3) \
			or actor.global_position.distance_to(expected_pos) > 0.0001 \
			or agent.target_position.distance_to(target) > 0.0001:
		return _fail(actor, "live navigation agent/map setup absent")
	if arm != "":
		return _run_pop_arm(actor, arm, arm_cfg, st, st2)
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

func _argval(prefix: String, dflt: String) -> String:
	for a in OS.get_cmdline_user_args():
		if a.begins_with(prefix):
			return a.substr(prefix.length())
	return dflt

func _v3(v: Vector3) -> String:
	return "%.6f,%.6f,%.6f" % [v.x, v.y, v.z]

# Round-72 arm presets. Keys: spawn, target, pdd, tdd (authored setup); path
# (expected queried path), idx, next, final, dist, reachable, reached,
# finished (expected observed tuple); optional tp (post-settle teleport) plus
# pre_idx/pre_next/pre_reachable/pre_reached/pre_finished (expected tuple
# BEFORE the teleport — the observed tuple keys then apply to the post state).
func _arm_cfg(arm_name: String) -> Dictionary:
	var s := Vector3(0.5, 0, 0.5)      # default spawn
	var td := Vector3(2.5, 0, 3.5)     # reachable detour target
	var tg := Vector3(0.5, 0, 3.0)     # gap2 off-mesh target, clamps to (2,0,3)
	var f := Vector3(2.5, 0, 3.5)      # detour final
	var fg := Vector3(2, 0, 3)         # gap2 clamped final
	match arm_name:
		# pop-index sweep at default spawn: idx pins which path point
		# get_next_path_position returns as pdd grows (strict < pdd).
		"pop_lo":
			return {"spawn": s, "target": td, "pdd": 1.5, "tdd": 1.0,
				"path": [s, Vector3(2, 0, 1), f], "idx": 1, "next": Vector3(2, 0, 1),
				"final": f, "dist": 3.605551,
				"reachable": true, "reached": false, "finished": false}
		"pop_hi":
			return {"spawn": s, "target": td, "pdd": 2.0, "tdd": 1.0,
				"path": [s, Vector3(2, 0, 1), f], "idx": 2, "next": f,
				"final": f, "dist": 3.605551,
				"reachable": true, "reached": false, "finished": false}
		"pop_sat":
			return {"spawn": s, "target": td, "pdd": 5.0, "tdd": 1.0,
				"path": [s, Vector3(2, 0, 1), f], "idx": 2, "next": f,
				"final": f, "dist": 3.605551,
				"reachable": true, "reached": false, "finished": false}
		# pop-index vs agent position: the same pdd=1.0 pops the 0.707-away
		# waypoint from (1.5,0,0.5) but not the 1.581-away waypoint from S.
		"mid_lo":
			return {"spawn": Vector3(1.5, 0, 0.5), "target": td, "pdd": 0.7, "tdd": 1.0,
				"path": [Vector3(1.5, 0, 0.5), Vector3(2, 0, 1), f],
				"idx": 1, "next": Vector3(2, 0, 1), "final": f, "dist": 3.162278,
				"reachable": true, "reached": false, "finished": false}
		"mid_hi":
			return {"spawn": Vector3(1.5, 0, 0.5), "target": td, "pdd": 1.0, "tdd": 1.0,
				"path": [Vector3(1.5, 0, 0.5), Vector3(2, 0, 1), f],
				"idx": 2, "next": f, "final": f, "dist": 3.162278,
				"reachable": true, "reached": false, "finished": false}
		# strict-pop equality: spawn (2,0,0) sits at euclid EXACTLY 1.0 from
		# path[1]=(2,0,1); pdd=1.0 does not pop, pdd=1.01 does.
		"vert_pop_eq":
			return {"spawn": Vector3(2, 0, 0), "target": tg, "pdd": 1.0, "tdd": 1.0,
				"path": [Vector3(2, 0, 0), Vector3(2, 0, 1), fg],
				"idx": 1, "next": Vector3(2, 0, 1), "final": fg, "dist": 3.354102,
				"reachable": false, "reached": false, "finished": false}
		"vert_pop_above":
			return {"spawn": Vector3(2, 0, 0), "target": tg, "pdd": 1.01, "tdd": 1.0,
				"path": [Vector3(2, 0, 0), Vector3(2, 0, 1), fg],
				"idx": 2, "next": fg, "final": fg, "dist": 3.354102,
				"reachable": false, "reached": false, "finished": false}
		# live-position pop on a FIXED path: after the path is forced from S,
		# teleporting within pdd of (2,0,1) pops it; teleporting to euclid
		# EXACTLY 1.0 from it does not (strict) — same path, same pdd.
		"tp_mid":
			return {"spawn": s, "target": td, "pdd": 1.0, "tdd": 1.0,
				"tp": Vector3(1.6, 0, 0.6),
				"path": [s, Vector3(2, 0, 1), f],
				"pre_idx": 1, "pre_next": Vector3(2, 0, 1),
				"pre_reachable": true, "pre_reached": false, "pre_finished": false,
				"idx": 2, "next": f, "final": f, "dist": 3.036445,
				"reachable": true, "reached": false, "finished": false}
		"tp_eq":
			return {"spawn": s, "target": td, "pdd": 1.0, "tdd": 1.0,
				"tp": Vector3(2, 0, 0),
				"path": [s, Vector3(2, 0, 1), f],
				"pre_idx": 1, "pre_next": Vector3(2, 0, 1),
				"pre_reachable": true, "pre_reached": false, "pre_finished": false,
				"idx": 1, "next": Vector3(2, 0, 1), "final": f, "dist": 3.535534,
				"reachable": true, "reached": false, "finished": false}
		# Euclidean-not-path-sum pop basis: on the gap2 dogleg, (2,0,1) sits at
		# euclid 1.581139 from S but 2.581139 along the routed path; pdd=2.0 pops
		# it (idx=3) — a path-sum basis predicts no pop.
		"gap2_pop_basis":
			return {"spawn": s, "target": tg, "pdd": 2.0, "tdd": 1.0,
				"path": [s, Vector3(2, 0, 0), Vector3(2, 0, 1), fg],
				"idx": 3, "next": fg, "final": fg, "dist": 2.5,
				"reachable": false, "reached": false, "finished": false}
		# unreachable finish gate: euclid(agent, clamped final) < pdd STRICT —
		# 2.915476 vs pdd 2.9/3.0, then the exact-3.0 edge from spawn (2,0,0).
		"fin_unr_lo":
			return {"spawn": s, "target": tg, "pdd": 2.9, "tdd": 1.0,
				"path": [s, Vector3(2, 0, 0), Vector3(2, 0, 1), fg],
				"idx": 3, "next": fg, "final": fg, "dist": 2.5,
				"reachable": false, "reached": false, "finished": false}
		"fin_unr_hi":
			return {"spawn": s, "target": tg, "pdd": 3.0, "tdd": 1.0,
				"path": [s, Vector3(2, 0, 0), Vector3(2, 0, 1), fg],
				"idx": 3, "next": fg, "final": fg, "dist": 2.5,
				"reachable": false, "reached": false, "finished": true}
		"vert_fin_eq":
			return {"spawn": Vector3(2, 0, 0), "target": tg, "pdd": 3.0, "tdd": 1.0,
				"path": [Vector3(2, 0, 0), Vector3(2, 0, 1), fg],
				"idx": 2, "next": fg, "final": fg, "dist": 3.354102,
				"reachable": false, "reached": false, "finished": false}
		"vert_fin_above":
			return {"spawn": Vector3(2, 0, 0), "target": tg, "pdd": 3.01, "tdd": 1.0,
				"path": [Vector3(2, 0, 0), Vector3(2, 0, 1), fg],
				"idx": 2, "next": fg, "final": fg, "dist": 3.354102,
				"reachable": false, "reached": false, "finished": true}
		# reachable finish gate = reached gate: euclid(agent, raw target) < tdd
		# STRICT — the gap2 euclid is exactly 2.5, so tdd=2.5 fails, tdd=2.6 fires.
		"fin_reach_eq":
			return {"spawn": s, "target": tg, "pdd": 1.0, "tdd": 2.5,
				"path": [s, Vector3(2, 0, 0), Vector3(2, 0, 1), fg],
				"idx": 1, "next": Vector3(2, 0, 0), "final": fg, "dist": 2.5,
				"reachable": true, "reached": false, "finished": false}
		"fin_reach_above":
			return {"spawn": s, "target": tg, "pdd": 1.0, "tdd": 2.6,
				"path": [s, Vector3(2, 0, 0), Vector3(2, 0, 1), fg],
				"idx": 1, "next": Vector3(2, 0, 0), "final": fg, "dist": 2.5,
				"reachable": true, "reached": true, "finished": true}
		# mode selector + inclusive reachable + strict reached, one sweep:
		# spawn (2,0,3) sits ON the clamp point (euclid final = 0, euclid target
		# = 1.5 == the reachability gap). tdd 1.4 unreachable -> finished via
		# the idx+pdd clause; 1.5 -> reachable INCLUSIVE but strict reached
		# fails; 1.6 -> reached. finished is NON-MONOTONE in tdd: T,F,T.
		"edge_unr":
			return {"spawn": fg, "target": tg, "pdd": 1.0, "tdd": 1.4,
				"path": [fg, fg],
				"idx": 1, "next": fg, "final": fg, "dist": 1.5,
				"reachable": false, "reached": false, "finished": true}
		"edge_eq":
			return {"spawn": fg, "target": tg, "pdd": 1.0, "tdd": 1.5,
				"path": [fg, fg],
				"idx": 1, "next": fg, "final": fg, "dist": 1.5,
				"reachable": true, "reached": false, "finished": false}
		"edge_above":
			return {"spawn": fg, "target": tg, "pdd": 1.0, "tdd": 1.6,
				"path": [fg, fg],
				"idx": 1, "next": fg, "final": fg, "dist": 1.5,
				"reachable": true, "reached": true, "finished": true}
		# idx gate on the unreachable clause: agent teleported ONTO the clamped
		# final (euclid final = 0 < pdd) still does not finish because the pop
		# index never reached the last waypoint (idx stays 1, next looks back).
		"fin_idx_gate":
			return {"spawn": s, "target": tg, "pdd": 1.0, "tdd": 1.4,
				"tp": fg,
				"path": [s, Vector3(2, 0, 0), Vector3(2, 0, 1), fg],
				"pre_idx": 1, "pre_next": Vector3(2, 0, 0),
				"pre_reachable": false, "pre_reached": false, "pre_finished": false,
				"idx": 1, "next": Vector3(2, 0, 0), "final": fg, "dist": 1.5,
				"reachable": false, "reached": false, "finished": false}
		# reached ignores reachability: agent teleported adjacent to the raw
		# off-mesh target (euclid 0.5 < tdd) fires reached+finished through the
		# wall while reachable stays false — finished = reached OR clause.
		"fin_wall":
			return {"spawn": s, "target": tg, "pdd": 1.0, "tdd": 1.0,
				"tp": Vector3(0.5, 0, 2.5),
				"path": [s, Vector3(2, 0, 0), Vector3(2, 0, 1), fg],
				"pre_idx": 1, "pre_next": Vector3(2, 0, 0),
				"pre_reachable": false, "pre_reached": false, "pre_finished": false,
				"idx": 1, "next": Vector3(2, 0, 0), "final": fg, "dist": 0.5,
				"reachable": false, "reached": true, "finished": true}
		# latch: once reached/finished fire they stay fired even after the agent
		# teleports back out of every threshold.
		"fin_latch":
			return {"spawn": fg, "target": tg, "pdd": 1.0, "tdd": 1.6,
				"tp": s,
				"path": [fg, fg],
				"pre_idx": 1, "pre_next": fg,
				"pre_reachable": true, "pre_reached": true, "pre_finished": true,
				"idx": 1, "next": fg, "final": fg, "dist": 2.5,
				"reachable": true, "reached": true, "finished": true}
	return {}

func _read_state(agent: NavigationAgent3D, actor: Node3D) -> Dictionary:
	var next := agent.get_next_path_position()
	var idx := agent.get_current_navigation_path_index()
	var path := agent.get_current_navigation_path()
	var pathlen := 0.0
	for i in range(1, path.size()):
		pathlen += path[i - 1].distance_to(path[i])
	return {"pos": actor.global_position, "next": next, "idx": idx, "path": path,
		"pathlen": pathlen, "dist": agent.distance_to_target(),
		"final": agent.get_final_position(), "reachable": agent.is_target_reachable(),
		"reached": agent.is_target_reached(), "finished": agent.is_navigation_finished()}

func _run_pop_arm(actor: Node3D, arm_name: String, cfg: Dictionary,
		st: Dictionary, st2: Dictionary) -> bool:
	var diag := ""
	var want_path: Array = cfg["path"]
	if st2["idx"] != cfg["idx"]:
		diag = "idx=%d expected=%d" % [st2["idx"], cfg["idx"]]
	elif st2["next"].distance_to(cfg["next"]) > POS_TOL:
		diag = "next=%s expected=%s" % [_v3(st2["next"]), _v3(cfg["next"])]
	elif st2["final"].distance_to(cfg["final"]) > POS_TOL:
		diag = "final=%s expected=%s" % [_v3(st2["final"]), _v3(cfg["final"])]
	elif absf(st2["dist"] - cfg["dist"]) > DIST_TOL:
		diag = "dist=%.6f expected=%.6f" % [st2["dist"], cfg["dist"]]
	elif st2["reachable"] != cfg["reachable"] or st2["reached"] != cfg["reached"] \
			or st2["finished"] != cfg["finished"]:
		diag = "flags reachable=%s reached=%s finished=%s expected=%s,%s,%s" % [
			st2["reachable"], st2["reached"], st2["finished"],
			cfg["reachable"], cfg["reached"], cfg["finished"]]
	elif st2["path"].size() != want_path.size():
		diag = "npath=%d expected=%d path=%s" % [st2["path"].size(), want_path.size(), st2["path"]]
	elif diag == "":
		for i in range(want_path.size()):
			if st2["path"][i].distance_to(want_path[i]) > POS_TOL:
				diag = "path[%d]=%s expected=%s path=%s" % [i, _v3(st2["path"][i]), _v3(want_path[i]), st2["path"]]
				break
	# Teleport arms also pin the pre-teleport tuple and that the stored path
	# itself did not change under the move.
	if diag == "" and cfg.has("tp"):
		if st["pos"].distance_to(cfg["spawn"]) > 0.0001 \
				or st["idx"] != cfg["pre_idx"] \
				or st["next"].distance_to(cfg["pre_next"]) > POS_TOL \
				or st["reachable"] != cfg["pre_reachable"] \
				or st["reached"] != cfg["pre_reached"] \
				or st["finished"] != cfg["pre_finished"]:
			diag = "pre-teleport pos=%s idx=%d next=%s flags=%s,%s,%s expected idx=%d next=%s flags=%s,%s,%s" % [
				_v3(st["pos"]), st["idx"], _v3(st["next"]),
				st["reachable"], st["reached"], st["finished"],
				cfg["pre_idx"], _v3(cfg["pre_next"]),
				cfg["pre_reachable"], cfg["pre_reached"], cfg["pre_finished"]]
		elif st["path"].size() != want_path.size():
			diag = "pre-teleport path changed npath=%d expected=%d" % [st["path"].size(), want_path.size()]
		else:
			for i in range(want_path.size()):
				if st["path"][i].distance_to(want_path[i]) > POS_TOL:
					diag = "pre-teleport path[%d]=%s expected=%s (stored path moved under teleport)" % [i, _v3(st["path"][i]), _v3(want_path[i])]
					break
	if diag != "":
		return _fail(actor, arm_name + " " + diag)
	_cleanup(actor)
	if cfg.has("tp"):
		print("PASS navagent3d_detour %s before_idx=%d after_idx=%d next=%s final=%s dist=%.6f reachable=%s reached=%s finished=%s"
			% [arm_name, st["idx"], st2["idx"], _v3(st2["next"]), _v3(st2["final"]),
			st2["dist"], st2["reachable"], st2["reached"], st2["finished"]])
	else:
		print("PASS navagent3d_detour %s idx=%d next=%s final=%s dist=%.6f pathlen=%.6f reachable=%s reached=%s finished=%s"
			% [arm_name, st2["idx"], _v3(st2["next"]), _v3(st2["final"]),
			st2["dist"], st2["pathlen"], st2["reachable"], st2["reached"], st2["finished"]])
	quit(0)
	return true
