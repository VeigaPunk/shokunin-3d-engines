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
# Round-73 arms (off-mesh NavigationLink3D traversal gating, measured on this
# build — Godot 4.7.2, same L-corridor plus an additive disconnected island
# quad C x[2,3]z[5,6] for the bridge arms):
#   authoring: both NavigationServer3D.link_create() ("server") and
#     NavigationLink3D.new() ("node") join the agent's path query headlessly
#     after the normal physics settle (link iteration_id 1).
#   metadata: agent.path_metadata_flags bits 1/2/4 gate the companion arrays
#     on get_current_navigation_result() — types/rids/owner_ids. At meta=0
#     all three are EMPTY even though the path crosses the link (opaque);
#     the LINK segment type (1) marks the waypoint index where the hop
#     STARTS (segment path[i]->path[i+1]); rids[i] carries the link RID at
#     that index (region RID elsewhere); owner_ids[i] carries a valid
#     NavigationLink3D ObjectID only for node-authored links (server links
#     give invalid 0s). Metadata changes NO path output.
#   gates (each independently falsifiable — the arm fails if the flag did
#     not take effect OR the path keeps the link): navigation_layers is a
#     BITMASK intersection (link layers=2 vs agent layers=1 drops the link;
#     agent layers=3 restores it); bidirectional=false traversed forward
#     uses the link but approached from the exit side (start/end swapped)
#     drops it; enabled=false drops it; travel_cost=10 prices the hop out of
#     route selection. enter_cost is INERT on this build — 10 and 100 leave
#     the link chosen (measured anomaly, pinned as the TRUE behavior).
#   pop-through hazard: link endpoints are ordinary waypoints to the pdd
#     pop loop — with pdd=4.0 on the bridge the agent pops the near endpoint
#     and get_next_path_position returns the far endpoint across the void.
# Round-74 motion arms (moving-agent semantics, measured on this build —
# Godot 4.7.2; "tp" = scripted global_position teleport, "set_target" =
# target_position re-assignment, "wait" = physics frames before reading,
# default 5; the r71-r73 surface was stationary or single-teleport):
#   path storage: the stored path array is NOT unconditionally frozen.
#     Locomotion leaves it untouched while the agent stays within
#     path_max_distance (default 5.0, STRICT >) of the CURRENT next
#     waypoint path[navigation_path_index] — teleports inside that radius
#     (on-mesh, off-mesh into the void, or off the map edge) never re-query.
#     Beyond it the next update re-queries the map and the new path[0] is
#     the navmesh-surface clamp of the LIVE position (agent at (10,0,10)
#     re-anchors to (3,0,4); at (2.5,0,6.x) to the B edge (2.5,0,4.0)).
#     The boundary was bisected: euclid(agent, path[1]) 4.995 stays frozen,
#     5.0001 re-queries, and it tracks a written path_max_distance exactly
#     (pmd 10/6 keep 5.52 frozen; pmd 5.5/2 re-query). Once
#     is_navigation_finished latches the update loop early-returns: the
#     pmd re-query is gated OFF too — a latched agent at 10.6+ from
#     path[1] keeps its stale path.
#   pop index: monotone non-decreasing strict-< Euclidean vs the STORED
#     path, driven by the LIVE position at call time — a wait=0 read
#     immediately after a teleport already shows the re-pop (no frame
#     needed); teleporting back toward the start never un-pops.
#   latch: is_target_reached/is_navigation_finished stay latched through
#     arbitrary motion including off-mesh; the measured unlatch is ANY
#     target_position re-assignment (same value too — no value dedup),
#     which also resets the pop index to 0 and synchronously clears the
#     stored path (get_current_navigation_path is [] until the next
#     getter-forced update).
#   re-anchor: set_target re-queries the map from the agent's LIVE
#     position — same-value assignment included — so path[0] is the live
#     position (on-mesh) or its navmesh clamp (off-mesh). Bank-side: at
#     (2.5,0,3.9) re-assigning the island target yields
#     [(2.5,0,3.9),(2.5,0,3.5),(2.5,0,5.5)] with the link and
#     [(2.5,0,3.9),(2.5,0,4.0)] without (unreachable -> finished=true via
#     the idx+pdd clause). "Live" pins down one level finer: the query
#     is LAZY — it materializes inside the first forcing call after the
#     assignment, anchored at the position live at THAT call, not at
#     assignment time. mv_reanchor_lazy (set_target + teleport in one
#     step, no read between) anchors at the post-teleport (2.6,0,2.0);
#     mv_reanchor_force (a read between assignment and teleport) anchors
#     at the read-time (1.5,0,0.5) and that path stays frozen through the
#     follow-up move.
#   pop index (cont.): the advance is SEQUENTIAL — it cannot skip a
#     waypoint. mv_popskip teleports adjacent to the final (euclid 0.707
#     < tdd) while idx=1: the index stays 1 and next still returns the
#     unconsumed waypoint BEHIND the agent, while the raw-euclid
#     reached/finished flags fire anyway (flags decoupled from idx).
#   getter laziness: none of the observed state moves without a getter —
#     get_current_navigation_path does NOT force an update (it returns []
#     until the first get_next_path_position call), while
#     get_next_path_position forces the once-per-frame update
#     synchronously. _read_state therefore always sees the post-update
#     tuple, matching r72/r73.
# No self-propelled locomotion, avoidance, baking, or rendering claim —
# motion here is authored teleports plus target re-assignment.
extends SceneTree
var owned: Array[RID] = []
var owned_nodes: Array[Node] = []

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
		var verts := PackedVector3Array([
			Vector3(0, 0, 0), Vector3(0, 0, 1), Vector3(2, 0, 1), Vector3(2, 0, 0),
			Vector3(3, 0, 0), Vector3(3, 0, 1), Vector3(3, 0, 4), Vector3(2, 0, 4)])
		if arm_cfg.get("island", false):
			# Disconnected island quad C x[2,3]z[5,6]; the z(4,5) gap is the
			# void. Verts must be complete before assignment — the property
			# getter hands back an array append_array does not write through.
			verts.append_array(PackedVector3Array([
				Vector3(2, 0, 5), Vector3(2, 0, 6), Vector3(3, 0, 6), Vector3(3, 0, 5)]))
		mesh.vertices = verts
		mesh.add_polygon(PackedInt32Array([0, 1, 2, 3]))
		mesh.add_polygon(PackedInt32Array([3, 2, 5, 4]))
		mesh.add_polygon(PackedInt32Array([2, 7, 6, 5]))
		if arm_cfg.get("island", false):
			mesh.add_polygon(PackedInt32Array([8, 9, 10, 11]))
	if arm != "":
		spawn = arm_cfg["spawn"]
		target = arm_cfg["target"]
	var region := NavigationServer3D.region_create()
	owned.append(region)
	NavigationServer3D.region_set_map(region, map)
	NavigationServer3D.region_set_navigation_mesh(region, mesh)
	# Round-73 off-mesh link authoring (opt-in per arm; absent key = no link).
	var link_rid := RID()
	var link_node: NavigationLink3D = null
	if arm_cfg.get("link", "") != "":
		var la: Vector3 = arm_cfg["link_a"]
		var lb: Vector3 = arm_cfg["link_b"]
		if arm_cfg.get("rev", false):
			var ltmp := la
			la = lb
			lb = ltmp
		if arm_cfg["link"] == "server":
			link_rid = NavigationServer3D.link_create()
			owned.append(link_rid)
			NavigationServer3D.link_set_map(link_rid, map)
			NavigationServer3D.link_set_start_position(link_rid, la)
			NavigationServer3D.link_set_end_position(link_rid, lb)
			NavigationServer3D.link_set_bidirectional(link_rid, not arm_cfg.get("oneway", false))
			NavigationServer3D.link_set_enabled(link_rid, not arm_cfg.get("disabled", false))
			NavigationServer3D.link_set_navigation_layers(link_rid, int(arm_cfg.get("linklayers", 1)))
			NavigationServer3D.link_set_enter_cost(link_rid, float(arm_cfg.get("entercost", 0.0)))
			NavigationServer3D.link_set_travel_cost(link_rid, float(arm_cfg.get("travelcost", 1.0)))
		else:
			link_node = NavigationLink3D.new()
			root.add_child(link_node)
			owned_nodes.append(link_node)
			link_node.set_navigation_map(map)
			link_node.start_position = la
			link_node.end_position = lb
			link_node.bidirectional = not arm_cfg.get("oneway", false)
			link_node.enabled = not arm_cfg.get("disabled", false)
			link_node.navigation_layers = int(arm_cfg.get("linklayers", 1))
			link_node.enter_cost = float(arm_cfg.get("entercost", 0.0))
			link_node.travel_cost = float(arm_cfg.get("travelcost", 1.0))
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
		agent.path_metadata_flags = int(arm_cfg.get("meta", 0))
		agent.navigation_layers = int(arm_cfg.get("agentlayers", 1))
		if arm_cfg.has("pmd"):
			agent.path_max_distance = float(arm_cfg["pmd"])
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
	var states: Array = []
	if arm != "":
		st = _read_state(agent, actor)
		if arm_cfg.has("steps"):
			states = await _run_steps(arm_cfg["steps"], agent, actor)
			st2 = states[states.size() - 1]
		elif arm_cfg.has("tp"):
			actor.global_position = arm_cfg["tp"]
			for i in range(5):
				await physics_frame
			st2 = _read_state(agent, actor)
		else:
			st2 = st
	var expected_pos := spawn
	var expected_target := target
	if arm != "":
		if arm_cfg.has("tp"):
			expected_pos = arm_cfg["tp"]
		if arm_cfg.has("steps"):
			for step in arm_cfg["steps"]:
				if step.has("tp"):
					expected_pos = step["tp"]
				if step.has("set_target"):
					expected_target = step["set_target"]
	var want_polys := 1 if straight else (4 if arm_cfg.get("island", false) else 3)
	if not actor.is_inside_tree() or agent.get_parent() != actor \
			or agent.get_navigation_map() != map or not NavigationServer3D.map_is_active(map) \
			or NavigationServer3D.map_get_regions(map).size() != 1 \
			or mesh.get_polygon_count() != want_polys \
			or actor.global_position.distance_to(expected_pos) > 0.0001 \
			or agent.target_position.distance_to(expected_target) > 0.0001:
		return _fail(actor, "live navigation agent/map setup absent")
	# Link-arm gate honesty: every authored link flag must read back applied,
	# else a "gate drops the link" arm cannot falsify a no-op setter.
	if arm_cfg.get("link", "") != "":
		var lrid: RID = link_node.get_rid() if link_node != null else link_rid
		if not lrid.is_valid() or NavigationServer3D.link_get_map(lrid) != map \
				or NavigationServer3D.link_get_iteration_id(lrid) < 1 \
				or int(NavigationServer3D.link_get_navigation_layers(lrid)) != int(arm_cfg.get("linklayers", 1)) \
				or NavigationServer3D.link_is_bidirectional(lrid) != (not arm_cfg.get("oneway", false)) \
				or NavigationServer3D.link_get_enabled(lrid) != (not arm_cfg.get("disabled", false)) \
				or absf(NavigationServer3D.link_get_enter_cost(lrid) - float(arm_cfg.get("entercost", 0.0))) > 0.0001 \
				or absf(NavigationServer3D.link_get_travel_cost(lrid) - float(arm_cfg.get("travelcost", 1.0))) > 0.0001 \
				or int(agent.path_metadata_flags) != int(arm_cfg.get("meta", 0)) \
				or int(agent.navigation_layers) != int(arm_cfg.get("agentlayers", 1)):
			return _fail(actor, "authored link flags not in effect")
	if arm != "":
		if arm_cfg.has("steps"):
			return _run_motion_arm(actor, arm, arm_cfg, st, states)
		if arm_cfg.get("island", false) or arm_cfg.get("link", "") != "":
			return _run_link_arm(actor, agent, region, link_rid, link_node, arm, arm_cfg, st2)
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
	for n in owned_nodes:
		if is_instance_valid(n):
			n.free()
	owned_nodes.clear()
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
		# Round-73 off-mesh link arms. Extra keys: "island" (add the
		# disconnected quad C), "link" ("server"|"node"), "link_a"/"link_b",
		# "linklayers"/"agentlayers", "oneway", "rev", "disabled",
		# "entercost"/"travelcost", "meta" (path_metadata_flags); expected
		# companion arrays: "types" (exact PackedInt32 match, [] = empty),
		# "nrids"/"rid_at" (link RID index; all others must be the region),
		# "nowners"/"own_at"/"own_class" (valid ObjectID instance class).
		# Shortcut geometry: link (1.5,0,0.5)->(2.5,0,3.0), path
		# [S,ls,le,T] pathlen 4.192582; link dropped -> corridor
		# [S,(2,0,1),T] pathlen 4.130649. Bridge geometry: island C, target
		# T2=(2.5,0,5.5) euclid 5.385165; link (2.5,0,3.5)->(2.5,0,5.5) gives
		# [S,(2,0,1),ls,le] pathlen 6.130649; no traversable link -> clamped
		# [S,(2,0,1),(2.5,0,4.0)] pathlen 4.622520, reachable=false.
		# (a) metadata: opaque at meta=0; per-bit companion arrays.
		"link_shortcut":
			return {"spawn": s, "target": td, "pdd": 1.0, "tdd": 1.0,
				"link": "server", "link_a": Vector3(1.5, 0, 0.5), "link_b": Vector3(2.5, 0, 3.0),
				"path": [s, Vector3(1.5, 0, 0.5), Vector3(2.5, 0, 3.0), f],
				"idx": 1, "next": Vector3(1.5, 0, 0.5), "final": f, "dist": 3.605551,
				"reachable": true, "reached": false, "finished": false,
				"types": [], "nrids": 0, "nowners": 0}
		"link_meta_types":
			return {"spawn": s, "target": td, "pdd": 1.0, "tdd": 1.0,
				"link": "server", "link_a": Vector3(1.5, 0, 0.5), "link_b": Vector3(2.5, 0, 3.0),
				"meta": 1,
				"path": [s, Vector3(1.5, 0, 0.5), Vector3(2.5, 0, 3.0), f],
				"idx": 1, "next": Vector3(1.5, 0, 0.5), "final": f, "dist": 3.605551,
				"reachable": true, "reached": false, "finished": false,
				"types": [0, 1, 0, 0], "nrids": 0, "nowners": 0}
		"link_meta_rids":
			return {"spawn": s, "target": td, "pdd": 1.0, "tdd": 1.0,
				"link": "server", "link_a": Vector3(1.5, 0, 0.5), "link_b": Vector3(2.5, 0, 3.0),
				"meta": 2,
				"path": [s, Vector3(1.5, 0, 0.5), Vector3(2.5, 0, 3.0), f],
				"idx": 1, "next": Vector3(1.5, 0, 0.5), "final": f, "dist": 3.605551,
				"reachable": true, "reached": false, "finished": false,
				"types": [], "nrids": 4, "rid_at": 1, "nowners": 0}
		"link_meta_owners":
			return {"spawn": s, "target": td, "pdd": 1.0, "tdd": 1.0,
				"link": "node", "link_a": Vector3(1.5, 0, 0.5), "link_b": Vector3(2.5, 0, 3.0),
				"meta": 4,
				"path": [s, Vector3(1.5, 0, 0.5), Vector3(2.5, 0, 3.0), f],
				"idx": 1, "next": Vector3(1.5, 0, 0.5), "final": f, "dist": 3.605551,
				"reachable": true, "reached": false, "finished": false,
				"types": [], "nrids": 0, "nowners": 4,
				"own_at": 1, "own_class": "NavigationLink3D"}
		"link_meta":
			return {"spawn": s, "target": td, "pdd": 1.0, "tdd": 1.0,
				"link": "node", "link_a": Vector3(1.5, 0, 0.5), "link_b": Vector3(2.5, 0, 3.0),
				"meta": 7,
				"path": [s, Vector3(1.5, 0, 0.5), Vector3(2.5, 0, 3.0), f],
				"idx": 1, "next": Vector3(1.5, 0, 0.5), "final": f, "dist": 3.605551,
				"reachable": true, "reached": false, "finished": false,
				"types": [0, 1, 0, 0], "nrids": 4, "rid_at": 1, "nowners": 4,
				"own_at": 1, "own_class": "NavigationLink3D"}
		# (b) traversal gates — each drops the link independently; meta=1
		# exposes the absent LINK type so the types array pins it too.
		"link_layers_off":
			return {"spawn": s, "target": td, "pdd": 1.0, "tdd": 1.0,
				"link": "server", "link_a": Vector3(1.5, 0, 0.5), "link_b": Vector3(2.5, 0, 3.0),
				"linklayers": 2, "agentlayers": 1, "meta": 1,
				"path": [s, Vector3(2, 0, 1), f],
				"idx": 1, "next": Vector3(2, 0, 1), "final": f, "dist": 3.605551,
				"reachable": true, "reached": false, "finished": false,
				"types": [0, 0, 0]}
		"link_layers_on":
			return {"spawn": s, "target": td, "pdd": 1.0, "tdd": 1.0,
				"link": "server", "link_a": Vector3(1.5, 0, 0.5), "link_b": Vector3(2.5, 0, 3.0),
				"linklayers": 2, "agentlayers": 3, "meta": 1,
				"path": [s, Vector3(1.5, 0, 0.5), Vector3(2.5, 0, 3.0), f],
				"idx": 1, "next": Vector3(1.5, 0, 0.5), "final": f, "dist": 3.605551,
				"reachable": true, "reached": false, "finished": false,
				"types": [0, 1, 0, 0]}
		"link_oneway_fwd":
			return {"spawn": s, "target": Vector3(2.5, 0, 5.5), "pdd": 1.0, "tdd": 1.0,
				"island": true,
				"link": "server", "link_a": Vector3(2.5, 0, 3.5), "link_b": Vector3(2.5, 0, 5.5),
				"oneway": true, "meta": 1,
				"path": [s, Vector3(2, 0, 1), Vector3(2.5, 0, 3.5), Vector3(2.5, 0, 5.5)],
				"idx": 1, "next": Vector3(2, 0, 1), "final": Vector3(2.5, 0, 5.5),
				"dist": 5.385165,
				"reachable": true, "reached": false, "finished": false,
				"types": [0, 0, 1, 0]}
		"link_oneway_rev":
			return {"spawn": s, "target": Vector3(2.5, 0, 5.5), "pdd": 1.0, "tdd": 1.0,
				"island": true,
				"link": "server", "link_a": Vector3(2.5, 0, 3.5), "link_b": Vector3(2.5, 0, 5.5),
				"oneway": true, "rev": true, "meta": 1,
				"path": [s, Vector3(2, 0, 1), Vector3(2.5, 0, 4.0)],
				"idx": 1, "next": Vector3(2, 0, 1), "final": Vector3(2.5, 0, 4.0),
				"dist": 5.385165,
				"reachable": false, "reached": false, "finished": false,
				"types": [0, 0, 0]}
		"link_disabled":
			return {"spawn": s, "target": Vector3(2.5, 0, 5.5), "pdd": 1.0, "tdd": 1.0,
				"island": true,
				"link": "server", "link_a": Vector3(2.5, 0, 3.5), "link_b": Vector3(2.5, 0, 5.5),
				"disabled": true, "meta": 1,
				"path": [s, Vector3(2, 0, 1), Vector3(2.5, 0, 4.0)],
				"idx": 1, "next": Vector3(2, 0, 1), "final": Vector3(2.5, 0, 4.0),
				"dist": 5.385165,
				"reachable": false, "reached": false, "finished": false,
				"types": [0, 0, 0]}
		# (c) cost asymmetry: travel_cost=10 prices the hop out (corridor
		# chosen); enter_cost=100 leaves the link chosen — inert on this
		# build, pinned as the TRUE behavior (anomaly documented r72).
		"link_travelcost":
			return {"spawn": s, "target": td, "pdd": 1.0, "tdd": 1.0,
				"link": "server", "link_a": Vector3(1.5, 0, 0.5), "link_b": Vector3(2.5, 0, 3.0),
				"travelcost": 10.0, "meta": 1,
				"path": [s, Vector3(2, 0, 1), f],
				"idx": 1, "next": Vector3(2, 0, 1), "final": f, "dist": 3.605551,
				"reachable": true, "reached": false, "finished": false,
				"types": [0, 0, 0]}
		"link_entercost":
			return {"spawn": s, "target": td, "pdd": 1.0, "tdd": 1.0,
				"link": "server", "link_a": Vector3(1.5, 0, 0.5), "link_b": Vector3(2.5, 0, 3.0),
				"entercost": 100.0, "meta": 1,
				"path": [s, Vector3(1.5, 0, 0.5), Vector3(2.5, 0, 3.0), f],
				"idx": 1, "next": Vector3(1.5, 0, 0.5), "final": f, "dist": 3.605551,
				"reachable": true, "reached": false, "finished": false,
				"types": [0, 1, 0, 0]}
		# (d) pop-through hazard + the void premise: the island is
		# unreachable without a link (clamped final (2.5,0,4.0)); with the
		# link, the pdd pop loop treats link endpoints as ordinary waypoints
		# — pdd 2.0 pops to idx=2 so next is the link's near endpoint
		# (2.5,0,3.5) (euclid(S)=3.605551 > 2.0 keeps it), while pdd 4.0 pops
		# THROUGH it to idx=3 so next points across the void at the far
		# endpoint (2.5,0,5.5) — still reachable=true, finished=false.
		"link_gap":
			return {"spawn": s, "target": Vector3(2.5, 0, 5.5), "pdd": 1.0, "tdd": 1.0,
				"island": true,
				"path": [s, Vector3(2, 0, 1), Vector3(2.5, 0, 4.0)],
				"idx": 1, "next": Vector3(2, 0, 1), "final": Vector3(2.5, 0, 4.0),
				"dist": 5.385165,
				"reachable": false, "reached": false, "finished": false,
				"types": []}
		"link_pop_bank":
			return {"spawn": s, "target": Vector3(2.5, 0, 5.5), "pdd": 2.0, "tdd": 1.0,
				"island": true,
				"link": "server", "link_a": Vector3(2.5, 0, 3.5), "link_b": Vector3(2.5, 0, 5.5),
				"path": [s, Vector3(2, 0, 1), Vector3(2.5, 0, 3.5), Vector3(2.5, 0, 5.5)],
				"idx": 2, "next": Vector3(2.5, 0, 3.5), "final": Vector3(2.5, 0, 5.5),
				"dist": 5.385165,
				"reachable": true, "reached": false, "finished": false,
				"types": []}
		"link_pop_void":
			return {"spawn": s, "target": Vector3(2.5, 0, 5.5), "pdd": 4.0, "tdd": 1.0,
				"island": true,
				"link": "server", "link_a": Vector3(2.5, 0, 3.5), "link_b": Vector3(2.5, 0, 5.5),
				"path": [s, Vector3(2, 0, 1), Vector3(2.5, 0, 3.5), Vector3(2.5, 0, 5.5)],
				"idx": 3, "next": Vector3(2.5, 0, 5.5), "final": Vector3(2.5, 0, 5.5),
				"dist": 5.385165,
				"reachable": true, "reached": false, "finished": false,
				"types": []}
		# Round-74 motion arms. Extra keys: "steps" (ordered moves; each a
		# dict with optional "tp"/"set_target"/"wait" plus the expected
		# post-move tuple: idx/next/final/dist/reachable/reached/finished
		# and the complete stored "path" array), "pmd" (optional authored
		# path_max_distance). The base tuple pins the PRE-motion state; each
		# step pins its own full tuple — a stored path element that moved
		# without an authored re-query is a named per-step failure.
		# (a)+(b)+(c): stepwise teleports along the corridor — path frozen
		# at every step; idx advances on live position; reached/finished
		# fire when the agent arrives inside tdd.
		"mv_walk":
			return {"spawn": s, "target": td, "pdd": 1.0, "tdd": 1.0,
				"path": [s, Vector3(2, 0, 1), f],
				"idx": 1, "next": Vector3(2, 0, 1), "final": f, "dist": 3.605551,
				"reachable": true, "reached": false, "finished": false,
				"steps": [
					{"tp": Vector3(1.0, 0, 0.5), "idx": 1, "next": Vector3(2, 0, 1),
						"final": f, "dist": 3.354102,
						"path": [s, Vector3(2, 0, 1), f],
						"reachable": true, "reached": false, "finished": false},
					{"tp": Vector3(1.8, 0, 0.9), "idx": 2, "next": f,
						"final": f, "dist": 2.692582,
						"path": [s, Vector3(2, 0, 1), f],
						"reachable": true, "reached": false, "finished": false},
					{"tp": Vector3(2.5, 0, 3.0), "idx": 2, "next": f,
						"final": f, "dist": 0.5,
						"path": [s, Vector3(2, 0, 1), f],
						"reachable": true, "reached": true, "finished": true}]}
		# (a) live call-time: wait=0 read immediately after the teleport
		# already shows the re-pop — no physics frame needed; a second
		# read after 5 frames is byte-identical.
		"mv_live":
			return {"spawn": s, "target": td, "pdd": 1.0, "tdd": 1.0,
				"path": [s, Vector3(2, 0, 1), f],
				"idx": 1, "next": Vector3(2, 0, 1), "final": f, "dist": 3.605551,
				"reachable": true, "reached": false, "finished": false,
				"steps": [
					{"tp": Vector3(1.8, 0, 0.9), "wait": 0, "idx": 2, "next": f,
						"final": f, "dist": 2.692582,
						"path": [s, Vector3(2, 0, 1), f],
						"reachable": true, "reached": false, "finished": false},
					{"tp": Vector3(1.8, 0, 0.9), "idx": 2, "next": f,
						"final": f, "dist": 2.692582,
						"path": [s, Vector3(2, 0, 1), f],
						"reachable": true, "reached": false, "finished": false}]}
		# (b) monotone pop: forward teleport pops idx to 2; teleporting back
		# to the spawn never un-pops — next still returns the final point.
		"mv_popback":
			return {"spawn": s, "target": td, "pdd": 1.0, "tdd": 1.0,
				"path": [s, Vector3(2, 0, 1), f],
				"idx": 1, "next": Vector3(2, 0, 1), "final": f, "dist": 3.605551,
				"reachable": true, "reached": false, "finished": false,
				"steps": [
					{"tp": Vector3(1.8, 0, 0.9), "idx": 2, "next": f,
						"final": f, "dist": 2.692582,
						"path": [s, Vector3(2, 0, 1), f],
						"reachable": true, "reached": false, "finished": false},
					{"tp": s, "idx": 2, "next": f,
						"final": f, "dist": 3.605551,
						"path": [s, Vector3(2, 0, 1), f],
						"reachable": true, "reached": false, "finished": false}]}
		# (b) strict-< boundary under motion: euclid==pdd does not pop;
		# 0.01 closer does.
		"mv_popstrict":
			return {"spawn": s, "target": td, "pdd": 1.0, "tdd": 1.0,
				"path": [s, Vector3(2, 0, 1), f],
				"idx": 1, "next": Vector3(2, 0, 1), "final": f, "dist": 3.605551,
				"reachable": true, "reached": false, "finished": false,
				"steps": [
					{"tp": Vector3(2, 0, 0), "idx": 1, "next": Vector3(2, 0, 1),
						"final": f, "dist": 3.535534,
						"path": [s, Vector3(2, 0, 1), f],
						"reachable": true, "reached": false, "finished": false},
					{"tp": Vector3(2, 0, 0.01), "idx": 2, "next": f,
						"final": f, "dist": 3.525635,
						"path": [s, Vector3(2, 0, 1), f],
						"reachable": true, "reached": false, "finished": false}]}
		# (a) off-mesh within pmd: standing in the void (2.5,0,4.5) — no
		# polygon beneath, dist-to-path[1] 3.54 < 5 — the path stays frozen
		# and distance/reached stay live (euclid==tdd: strict, not reached).
		"mv_void":
			return {"spawn": s, "target": td, "pdd": 1.0, "tdd": 1.0,
				"path": [s, Vector3(2, 0, 1), f],
				"idx": 1, "next": Vector3(2, 0, 1), "final": f, "dist": 3.605551,
				"reachable": true, "reached": false, "finished": false,
				"steps": [
					{"tp": Vector3(2.5, 0, 4.5), "idx": 1, "next": Vector3(2, 0, 1),
						"final": f, "dist": 1.0,
						"path": [s, Vector3(2, 0, 1), f],
						"reachable": true, "reached": false, "finished": false}]}
		# (a) pmd re-query boundary: euclid(agent, path[1]) 4.995 < 5.0
		# stays frozen; 5.025 > 5.0 re-queries and re-anchors the origin at
		# the B-edge clamp (2.5,0,4.0) — idx resets to 0.
		"mv_pmd_edge":
			return {"spawn": s, "target": td, "pdd": 1.0, "tdd": 1.0,
				"path": [s, Vector3(2, 0, 1), f],
				"idx": 1, "next": Vector3(2, 0, 1), "final": f, "dist": 3.605551,
				"reachable": true, "reached": false, "finished": false,
				"steps": [
					{"tp": Vector3(2.5, 0, 5.97), "idx": 1, "next": Vector3(2, 0, 1),
						"final": f, "dist": 2.47,
						"path": [s, Vector3(2, 0, 1), f],
						"reachable": true, "reached": false, "finished": false},
					{"tp": Vector3(2.5, 0, 6.0), "idx": 0, "next": Vector3(2.5, 0, 4.0),
						"final": f, "dist": 2.5,
						"path": [Vector3(2.5, 0, 4.0), f],
						"reachable": true, "reached": false, "finished": false}]}
		# (a)+(d) off-map re-anchor: a 13.4-unit teleport past every polygon
		# re-queries and clamps the origin to (3,0,4); teleporting back to
		# the corridor does NOT restore the old path — the re-anchor has no
		# undo.
		"mv_pmd_offmesh":
			return {"spawn": s, "target": td, "pdd": 1.0, "tdd": 1.0,
				"path": [s, Vector3(2, 0, 1), f],
				"idx": 1, "next": Vector3(2, 0, 1), "final": f, "dist": 3.605551,
				"reachable": true, "reached": false, "finished": false,
				"steps": [
					{"tp": Vector3(10, 0, 10), "idx": 0, "next": Vector3(3, 0, 4),
						"final": f, "dist": 9.924717,
						"path": [Vector3(3, 0, 4), f],
						"reachable": true, "reached": false, "finished": false},
					{"tp": Vector3(1.0, 0, 0.5), "idx": 0, "next": Vector3(3, 0, 4),
						"final": f, "dist": 3.354102,
						"path": [Vector3(3, 0, 4), f],
						"reachable": true, "reached": false, "finished": false}]}
		# (a) the re-query gate tracks authored path_max_distance: pmd=2.0
		# makes the same (2.5,0,5.5) teleport (dist-to-path[1] 4.53) breach.
		"mv_pmd2":
			return {"spawn": s, "target": td, "pdd": 1.0, "tdd": 1.0, "pmd": 2.0,
				"path": [s, Vector3(2, 0, 1), f],
				"idx": 1, "next": Vector3(2, 0, 1), "final": f, "dist": 3.605551,
				"reachable": true, "reached": false, "finished": false,
				"steps": [
					{"tp": Vector3(2.5, 0, 5.5), "idx": 0, "next": Vector3(2.5, 0, 4.0),
						"final": f, "dist": 2.0,
						"path": [Vector3(2.5, 0, 4.0), f],
						"reachable": true, "reached": false, "finished": false}]}
		# (c) latch under motion: reached/finished fire at spawn and stay
		# latched after two teleports — the second leaves the agent 10.63
		# from path[1] (> pmd 5) yet NO re-query fires: the finished latch
		# early-returns the whole update loop (path and idx untouched).
		"mv_latch":
			return {"spawn": fg, "target": tg, "pdd": 1.0, "tdd": 1.6,
				"path": [fg, fg],
				"idx": 1, "next": fg, "final": fg, "dist": 1.5,
				"reachable": true, "reached": true, "finished": true,
				"steps": [
					{"tp": s, "idx": 1, "next": fg,
						"final": fg, "dist": 2.5,
						"path": [fg, fg],
						"reachable": true, "reached": true, "finished": true},
					{"tp": Vector3(10, 0, 10), "idx": 1, "next": fg,
						"final": fg, "dist": 11.800424,
						"path": [fg, fg],
						"reachable": true, "reached": true, "finished": true}]}
		# (c)+(d) measured unlatch: same latch, then a same-value
		# target_position re-assignment unlatches reached/finished, resets
		# idx to 0 and re-anchors the path at the live-position clamp
		# (3,0,4) — no same-value dedup.
		"mv_unlatch":
			return {"spawn": fg, "target": tg, "pdd": 1.0, "tdd": 1.6,
				"path": [fg, fg],
				"idx": 1, "next": fg, "final": fg, "dist": 1.5,
				"reachable": true, "reached": true, "finished": true,
				"steps": [
					{"tp": Vector3(10, 0, 10), "idx": 1, "next": fg,
						"final": fg, "dist": 11.800424,
						"path": [fg, fg],
						"reachable": true, "reached": true, "finished": true},
					{"set_target": tg, "idx": 0, "next": Vector3(3, 0, 4),
						"final": fg, "dist": 11.800424,
						"path": [Vector3(3, 0, 4), fg],
						"reachable": true, "reached": false, "finished": false}]}
		# (d) re-anchor to a NEW target mid-path: the re-query starts at the
		# live position (1.5,0,0.5), not at the original path origin S.
		"mv_reanchor":
			return {"spawn": s, "target": td, "pdd": 1.0, "tdd": 1.0,
				"path": [s, Vector3(2, 0, 1), f],
				"idx": 1, "next": Vector3(2, 0, 1), "final": f, "dist": 3.605551,
				"reachable": true, "reached": false, "finished": false,
				"steps": [
					{"tp": Vector3(1.5, 0, 0.5), "idx": 2, "next": f,
						"final": f, "dist": 3.162278,
						"path": [s, Vector3(2, 0, 1), f],
						"reachable": true, "reached": false, "finished": false},
					{"set_target": Vector3(0.5, 0, 0.5), "idx": 1,
						"next": Vector3(0.5, 0, 0.5),
						"final": Vector3(0.5, 0, 0.5), "dist": 1.0,
						"path": [Vector3(1.5, 0, 0.5), Vector3(0.5, 0, 0.5)],
						"reachable": true, "reached": false, "finished": false}]}
		# (d) same-value re-assignment still re-queries from the live
		# position: path[0] moves S -> (1.5,0,0.5) on an unchanged target.
		"mv_reanchor_same":
			return {"spawn": s, "target": td, "pdd": 1.0, "tdd": 1.0,
				"path": [s, Vector3(2, 0, 1), f],
				"idx": 1, "next": Vector3(2, 0, 1), "final": f, "dist": 3.605551,
				"reachable": true, "reached": false, "finished": false,
				"steps": [
					{"tp": Vector3(1.5, 0, 0.5), "idx": 2, "next": f,
						"final": f, "dist": 3.162278,
						"path": [s, Vector3(2, 0, 1), f],
						"reachable": true, "reached": false, "finished": false},
					{"set_target": td, "idx": 2, "next": f,
						"final": f, "dist": 3.162278,
						"path": [Vector3(1.5, 0, 0.5), Vector3(2, 0, 1), f],
						"reachable": true, "reached": false, "finished": false}]}
		# (d) bank-side re-anchor with the link live: at (2.5,0,3.9) on the
		# void edge, re-assigning T2 anchors the new query at the live
		# position and still routes through the link behind the agent —
		# new path [(2.5,0,3.9),(2.5,0,3.5),(2.5,0,5.5)], pop lands on the
		# far endpoint across the void.
		"mv_reanchor_bank":
			return {"spawn": s, "target": Vector3(2.5, 0, 5.5), "pdd": 1.0, "tdd": 1.0,
				"island": true,
				"link": "server", "link_a": Vector3(2.5, 0, 3.5), "link_b": Vector3(2.5, 0, 5.5),
				"path": [s, Vector3(2, 0, 1), Vector3(2.5, 0, 3.5), Vector3(2.5, 0, 5.5)],
				"idx": 1, "next": Vector3(2, 0, 1), "final": Vector3(2.5, 0, 5.5),
				"dist": 5.385165,
				"reachable": true, "reached": false, "finished": false,
				"steps": [
					{"tp": Vector3(2.5, 0, 3.9), "idx": 1, "next": Vector3(2, 0, 1),
						"final": Vector3(2.5, 0, 5.5), "dist": 1.6,
						"path": [s, Vector3(2, 0, 1), Vector3(2.5, 0, 3.5), Vector3(2.5, 0, 5.5)],
						"reachable": true, "reached": false, "finished": false},
					{"set_target": Vector3(2.5, 0, 5.5), "idx": 2,
						"next": Vector3(2.5, 0, 5.5),
						"final": Vector3(2.5, 0, 5.5), "dist": 1.6,
						"path": [Vector3(2.5, 0, 3.9), Vector3(2.5, 0, 3.5), Vector3(2.5, 0, 5.5)],
						"reachable": true, "reached": false, "finished": false}]}
		# (d) bank-side re-anchor without the link: the same re-assignment
		# clamps the new query to the B edge — [(2.5,0,3.9),(2.5,0,4.0)],
		# unreachable, and the idx+pdd clause fires finished=true standing
		# 0.1 from the clamped final.
		"mv_reanchor_void":
			return {"spawn": s, "target": Vector3(2.5, 0, 5.5), "pdd": 1.0, "tdd": 1.0,
				"island": true,
				"path": [s, Vector3(2, 0, 1), Vector3(2.5, 0, 4.0)],
				"idx": 1, "next": Vector3(2, 0, 1), "final": Vector3(2.5, 0, 4.0),
				"dist": 5.385165,
				"reachable": false, "reached": false, "finished": false,
				"steps": [
					{"tp": Vector3(2.5, 0, 3.9), "idx": 1, "next": Vector3(2, 0, 1),
						"final": Vector3(2.5, 0, 4.0), "dist": 1.6,
						"path": [s, Vector3(2, 0, 1), Vector3(2.5, 0, 4.0)],
						"reachable": false, "reached": false, "finished": false},
					{"set_target": Vector3(2.5, 0, 5.5), "idx": 1,
						"next": Vector3(2.5, 0, 4.0),
						"final": Vector3(2.5, 0, 4.0), "dist": 1.6,
						"path": [Vector3(2.5, 0, 3.9), Vector3(2.5, 0, 4.0)],
						"reachable": false, "reached": false, "finished": true}]}
		# (b) sequential pop cannot skip: a teleport adjacent to the final
		# (euclid 0.707 < tdd) with idx=1 does NOT jump the index — next
		# still returns the unconsumed waypoint behind the agent — while
		# the raw-euclid flags reached/finished fire anyway (decoupled
		# from the sequential idx).
		"mv_popskip":
			return {"spawn": s, "target": td, "pdd": 1.0, "tdd": 1.0,
				"path": [s, Vector3(2, 0, 1), f],
				"idx": 1, "next": Vector3(2, 0, 1), "final": f, "dist": 3.605551,
				"reachable": true, "reached": false, "finished": false,
				"steps": [
					{"tp": Vector3(2.4, 0, 2.8), "idx": 1, "next": Vector3(2, 0, 1),
						"final": f, "dist": 0.707107,
						"path": [s, Vector3(2, 0, 1), f],
						"reachable": true, "reached": true, "finished": true}]}
		# (d) lazy materialization: set_target then teleport with NO read
		# between — the path query anchors at the position live at the
		# first forcing call (the post-teleport (2.6,0,2.0)), not at the
		# assignment-time position.
		"mv_reanchor_lazy":
			return {"spawn": s, "target": td, "pdd": 1.0, "tdd": 1.0,
				"path": [s, Vector3(2, 0, 1), f],
				"idx": 1, "next": Vector3(2, 0, 1), "final": f, "dist": 3.605551,
				"reachable": true, "reached": false, "finished": false,
				"steps": [
					{"tp": Vector3(1.5, 0, 0.5), "idx": 2, "next": f,
						"final": f, "dist": 3.162278,
						"path": [s, Vector3(2, 0, 1), f],
						"reachable": true, "reached": false, "finished": false},
					{"set_target": Vector3(2.9, 0, 3.9), "tp": Vector3(2.6, 0, 2.0),
						"idx": 1, "next": Vector3(2.9, 0, 3.9),
						"final": Vector3(2.9, 0, 3.9), "dist": 1.923539,
						"path": [Vector3(2.6, 0, 2.0), Vector3(2.9, 0, 3.9)],
						"reachable": true, "reached": false, "finished": false}]}
		# (d) materialization-time contrast: identical assignment+move, but
		# a read forces the update while the agent still sits at
		# (1.5,0,0.5) — the path anchors THERE and stays frozen through
		# the follow-up teleport (dist to path[2] 1.92 < pmd).
		"mv_reanchor_force":
			return {"spawn": s, "target": td, "pdd": 1.0, "tdd": 1.0,
				"path": [s, Vector3(2, 0, 1), f],
				"idx": 1, "next": Vector3(2, 0, 1), "final": f, "dist": 3.605551,
				"reachable": true, "reached": false, "finished": false,
				"steps": [
					{"tp": Vector3(1.5, 0, 0.5), "idx": 2, "next": f,
						"final": f, "dist": 3.162278,
						"path": [s, Vector3(2, 0, 1), f],
						"reachable": true, "reached": false, "finished": false},
					{"set_target": Vector3(2.9, 0, 3.9), "idx": 2,
						"next": Vector3(2.9, 0, 3.9),
						"final": Vector3(2.9, 0, 3.9), "dist": 3.676955,
						"path": [Vector3(1.5, 0, 0.5), Vector3(2, 0, 1), Vector3(2.9, 0, 3.9)],
						"reachable": true, "reached": false, "finished": false},
					{"tp": Vector3(2.6, 0, 2.0), "idx": 2,
						"next": Vector3(2.9, 0, 3.9),
						"final": Vector3(2.9, 0, 3.9), "dist": 1.923539,
						"path": [Vector3(1.5, 0, 0.5), Vector3(2, 0, 1), Vector3(2.9, 0, 3.9)],
						"reachable": true, "reached": false, "finished": false}]}
		# (a)+(b) across the link: the pop index walks through link
		# endpoints as ordinary waypoints on live position — idx 1->2->3 —
		# and the stored path stays frozen even mid-hop over the void
		# (agent off every polygon, still within pmd of path[idx]).
		"mv_bridge_walk":
			return {"spawn": s, "target": Vector3(2.5, 0, 5.5), "pdd": 1.0, "tdd": 1.0,
				"island": true,
				"link": "server", "link_a": Vector3(2.5, 0, 3.5), "link_b": Vector3(2.5, 0, 5.5),
				"path": [s, Vector3(2, 0, 1), Vector3(2.5, 0, 3.5), Vector3(2.5, 0, 5.5)],
				"idx": 1, "next": Vector3(2, 0, 1), "final": Vector3(2.5, 0, 5.5),
				"dist": 5.385165,
				"reachable": true, "reached": false, "finished": false,
				"steps": [
					{"tp": Vector3(2.0, 0, 0.9), "idx": 2, "next": Vector3(2.5, 0, 3.5),
						"final": Vector3(2.5, 0, 5.5), "dist": 4.627094,
						"path": [s, Vector3(2, 0, 1), Vector3(2.5, 0, 3.5), Vector3(2.5, 0, 5.5)],
						"reachable": true, "reached": false, "finished": false},
					{"tp": Vector3(2.5, 0, 3.4), "idx": 3, "next": Vector3(2.5, 0, 5.5),
						"final": Vector3(2.5, 0, 5.5), "dist": 2.1,
						"path": [s, Vector3(2, 0, 1), Vector3(2.5, 0, 3.5), Vector3(2.5, 0, 5.5)],
						"reachable": true, "reached": false, "finished": false},
					{"tp": Vector3(2.5, 0, 5.4), "idx": 3, "next": Vector3(2.5, 0, 5.5),
						"final": Vector3(2.5, 0, 5.5), "dist": 0.1,
						"path": [s, Vector3(2, 0, 1), Vector3(2.5, 0, 3.5), Vector3(2.5, 0, 5.5)],
						"reachable": true, "reached": true, "finished": true}]}
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

# Round-73 link arms: the same full observable tuple as _run_pop_arm (no
# teleport arms here), plus the companion metadata arrays keyed off cfg.
# types: exact match to get_path_types() ([] asserts the array is empty).
# nrids + rid_at: rids array size, and that rid_at alone carries the link
# RID (every other entry must be the region RID). nowners + own_at +
# own_class: owner_ids size, and that own_at resolves to a live instance of
# the authored class (node-authored links only; server links give 0s).
func _run_link_arm(actor: Node3D, agent: NavigationAgent3D, region: RID,
		link_rid: RID, link_node: NavigationLink3D, arm_name: String,
		cfg: Dictionary, st2: Dictionary) -> bool:
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
	var res: NavigationPathQueryResult3D = agent.get_current_navigation_result()
	var types: PackedInt32Array = res.get_path_types()
	var rids: Array = res.get_path_rids()
	var owners: PackedInt64Array = res.get_path_owner_ids()
	var eff_link: RID = link_node.get_rid() if link_node != null else link_rid
	if diag == "" and cfg.has("types"):
		var wt: Array = cfg["types"]
		if types.size() != wt.size():
			diag = "ntypes=%d expected=%d types=%s" % [types.size(), wt.size(), types]
		else:
			for i in range(wt.size()):
				if int(types[i]) != int(wt[i]):
					diag = "types[%d]=%d expected=%d types=%s" % [i, types[i], wt[i], types]
					break
	if diag == "" and cfg.has("nrids") and rids.size() != int(cfg["nrids"]):
		diag = "nrids=%d expected=%d" % [rids.size(), cfg["nrids"]]
	if diag == "" and cfg.has("rid_at"):
		var ra: int = cfg["rid_at"]
		if ra < 0 or ra >= rids.size() or rids[ra] != eff_link:
			diag = "rids[%d] is not the authored link rid (size=%d)" % [ra, rids.size()]
		else:
			for i in range(rids.size()):
				if i != ra and rids[i] != region:
					diag = "rids[%d] is neither link nor region rid" % i
					break
	if diag == "" and cfg.has("nowners") and owners.size() != int(cfg["nowners"]):
		diag = "nowners=%d expected=%d" % [owners.size(), cfg["nowners"]]
	if diag == "" and cfg.has("own_at"):
		var oa: int = cfg["own_at"]
		if oa < 0 or oa >= owners.size():
			diag = "own_at=%d out of range nowners=%d" % [oa, owners.size()]
		else:
			var inst := instance_from_id(owners[oa])
			if not is_instance_valid(inst) or inst.get_class() != cfg["own_class"]:
				diag = "owners[%d] is not a live %s" % [oa, cfg["own_class"]]
	if diag != "":
		return _fail(actor, arm_name + " " + diag)
	var tparts := PackedStringArray()
	for t in types:
		tparts.append(str(t))
	var tstr := "-"
	if tparts.size() > 0:
		tstr = ",".join(tparts)
	var ostr := "-"
	if cfg.has("own_at") and int(cfg["own_at"]) >= 0 and int(cfg["own_at"]) < owners.size():
		var oi := instance_from_id(owners[int(cfg["own_at"])])
		if is_instance_valid(oi):
			ostr = "%s@%d" % [oi.get_class(), int(cfg["own_at"])]
	_cleanup(actor)
	print("PASS navagent3d_detour %s idx=%d next=%s final=%s dist=%.6f pathlen=%.6f reachable=%s reached=%s finished=%s link=%s meta=%d types=%s ridat=%d own=%s"
		% [arm_name, st2["idx"], _v3(st2["next"]), _v3(st2["final"]),
		st2["dist"], st2["pathlen"], st2["reachable"], st2["reached"], st2["finished"],
		cfg.get("link", "none"), int(cfg.get("meta", 0)), tstr,
		int(cfg.get("rid_at", -1)), ostr])
	quit(0)
	return true

# Round-74 motion arms: execute the authored "steps" in order and return
# the post-step observable tuples. A step may teleport the actor ("tp"),
# re-assign the agent's target ("set_target"), or both — a combined step
# applies set_target FIRST then tp, so the query materializes inside the
# post-teleport read (the lazy-anchor edge: the path pins to the position
# live at the first forcing call, not at assignment). "wait" physics
# frames elapse before the read (default 5; 0 reads live call-time).
func _run_steps(steps: Array, agent: NavigationAgent3D, actor: Node3D) -> Array:
	var out: Array = []
	for step in steps:
		if step.has("set_target"):
			agent.target_position = step["set_target"]
		if step.has("tp"):
			actor.global_position = step["tp"]
		for i in range(int(step.get("wait", 5))):
			await physics_frame
		out.append(_read_state(agent, actor))
	return out

# Asserts the pre-motion tuple on st (same key order as _run_pop_arm),
# then each step's full authored tuple including the complete stored path
# array — the per-step path pin is the frozen-path falsification edge: a
# path element that moved without an authored re-query fails the step.
func _run_motion_arm(actor: Node3D, arm_name: String, cfg: Dictionary,
		st: Dictionary, states: Array) -> bool:
	var diag := ""
	var want_path: Array = cfg["path"]
	if st["idx"] != cfg["idx"]:
		diag = "idx=%d expected=%d" % [st["idx"], cfg["idx"]]
	elif st["next"].distance_to(cfg["next"]) > POS_TOL:
		diag = "next=%s expected=%s" % [_v3(st["next"]), _v3(cfg["next"])]
	elif st["final"].distance_to(cfg["final"]) > POS_TOL:
		diag = "final=%s expected=%s" % [_v3(st["final"]), _v3(cfg["final"])]
	elif absf(st["dist"] - cfg["dist"]) > DIST_TOL:
		diag = "dist=%.6f expected=%.6f" % [st["dist"], cfg["dist"]]
	elif st["reachable"] != cfg["reachable"] or st["reached"] != cfg["reached"] \
			or st["finished"] != cfg["finished"]:
		diag = "flags reachable=%s reached=%s finished=%s expected=%s,%s,%s" % [
			st["reachable"], st["reached"], st["finished"],
			cfg["reachable"], cfg["reached"], cfg["finished"]]
	elif st["path"].size() != want_path.size():
		diag = "npath=%d expected=%d path=%s" % [st["path"].size(), want_path.size(), st["path"]]
	elif diag == "":
		for i in range(want_path.size()):
			if st["path"][i].distance_to(want_path[i]) > POS_TOL:
				diag = "path[%d]=%s expected=%s path=%s" % [i, _v3(st["path"][i]), _v3(want_path[i]), st["path"]]
				break
	if diag == "":
		var epos: Vector3 = cfg["spawn"]
		for i in range(states.size()):
			var st_i: Dictionary = states[i]
			var es: Dictionary = cfg["steps"][i]
			if es.has("tp"):
				epos = es["tp"]
			var esp: Array = es["path"]
			if st_i["pos"].distance_to(epos) > 0.0001:
				diag = "step%d pos=%s expected=%s" % [i, _v3(st_i["pos"]), _v3(epos)]
			elif st_i["idx"] != es["idx"]:
				diag = "step%d idx=%d expected=%d" % [i, st_i["idx"], es["idx"]]
			elif st_i["next"].distance_to(es["next"]) > POS_TOL:
				diag = "step%d next=%s expected=%s" % [i, _v3(st_i["next"]), _v3(es["next"])]
			elif st_i["final"].distance_to(es["final"]) > POS_TOL:
				diag = "step%d final=%s expected=%s" % [i, _v3(st_i["final"]), _v3(es["final"])]
			elif absf(st_i["dist"] - es["dist"]) > DIST_TOL:
				diag = "step%d dist=%.6f expected=%.6f" % [i, st_i["dist"], es["dist"]]
			elif st_i["reachable"] != es["reachable"] or st_i["reached"] != es["reached"] \
					or st_i["finished"] != es["finished"]:
				diag = "step%d flags reachable=%s reached=%s finished=%s expected=%s,%s,%s" % [
					i, st_i["reachable"], st_i["reached"], st_i["finished"],
					es["reachable"], es["reached"], es["finished"]]
			elif st_i["path"].size() != esp.size():
				diag = "step%d npath=%d expected=%d path=%s" % [i, st_i["path"].size(), esp.size(), st_i["path"]]
			else:
				for j in range(esp.size()):
					if st_i["path"][j].distance_to(esp[j]) > POS_TOL:
						diag = "step%d path[%d]=%s expected=%s path=%s" % [
							i, j, _v3(st_i["path"][j]), _v3(esp[j]), st_i["path"]]
						break
			if diag != "":
				break
	if diag != "":
		return _fail(actor, arm_name + " " + diag)
	var idxs := PackedStringArray()
	for si in states:
		idxs.append(str(si["idx"]))
	var stf: Dictionary = states[states.size() - 1]
	_cleanup(actor)
	print("PASS navagent3d_detour %s steps=%d idxs=%s next=%s final=%s dist=%.6f pathlen=%.6f reachable=%s reached=%s finished=%s"
		% [arm_name, states.size(), ",".join(idxs), _v3(stf["next"]), _v3(stf["final"]),
		stf["dist"], stf["pathlen"], stf["reachable"], stf["reached"], stf["finished"]])
	quit(0)
	return true
