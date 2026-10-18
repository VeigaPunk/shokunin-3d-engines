extends SceneTree
# r97 gameplay node-class lattice — parent fixture.
#
# Children are byte-identical copies of the r97 scout probes and the r97
# boundary's own probes, run under their ORIGINAL res:// names (njoint.gd,
# soft.gd, r97b_softfloor.gd, ...) so a child receipt reproduces the
# scout's/boundary's receipt byte-for-byte; the parent copies the source out
# of res://r97_probe_<name>.gd into a per-cell project dir. Only cells the
# r97 boundary verified are pinned; armed/two-valued cells are not pinned.
#
# Digest cell:
#   <name>{rc=<n>,sha=<16 hex>,<field>=<value>,...}
# `sha` is sha256-16 over the child's NORMALIZED contract stream. Dropped or
# masked before hashing (declared normalizations, never content-changing):
#   - the "Godot Engine v..." banner and empty lines;
#   - the exact 2-line Jolt job-system warning, allowlisted by text and
#     tolerated at ANY position (r96/r97-boundary: a dense-frame artifact of
#     the Jolt job system, not physics) — counted in `w`;
#   - runtime object ids: `<Class#12345>` -> `<Class#N>` (allocation-order
#     artifacts; the pinned claim is identity=false, not the id);
#   - the crash dump's ASLR fields: "Load address: <hex>" -> "Load address: A"
#     and each "[n] <hex> ..." backtrace frame -> "[n] F" (frame COUNT is
#     preserved, so a different dump still changes the sha).
# Expected-error classes (per-cell `e` list) stay in the hashed stream and
# are counted in `ee`; any OTHER line matching ERROR:/SCRIPT ERROR/
# Parse Error/handle_crash/ObjectDB-leak lands in `ue` and fails the cell.
#
# Laws landed (r97-scout folded through r97-boundary §9 authorability):
#   joint     Joint3D node lattice: binding order is free (bind == bindpre
#             physics rows), get_rid() valid at construction on GP+Jolt and
#             invalid on Dummy, bad/absent node_b silently world-pins A
#             (badpath == nob rows), a non-body node_a is silently inert,
#             node-level teardown (freerj/freeb/readd/repath/dupclaim) is
#             clean on both backends — the r90 server UAF does not
#             reproduce at node level — and the node flag/param arms work
#             as named (hmot -> avb -2.5 each, hlim caps spin, exclx and
#             clampbig discriminate).
#   soft      SoftBody3D contract: an unindexed mesh is REJECTED on
#             GodotPhysics (godot_soft_body_3d.cpp:148) and simulates
#             nothing (v stays 0, rc=0); an indexed patch on the 0.1 m slab
#             tunnels on GP (-10.83421) but rests on Jolt (0.05); Jolt's
#             mass=10 / precision=50 fall through the same thin slab;
#             queue_free mid-run is clean.
#   softfloor the re-scoped contact law: GP soft-body/box contact is
#             thickness-selective, not absent — tunnel at 0.1, REST at
#             0.2/0.5/2.0, sideways ejection at 0.4; Jolt's mass/prec
#             failures are bounded to the thin slab (rest at 0.05 on 2.0 m);
#             and the pinned-cloth phase law: pins applied before the first
#             step (--pins=now, pf=0) are deterministic on both backends —
#             ball-through-cloth on GP vs bounce on Jolt. The deferred-pin
#             branch is censused in '#' diagnostics, never pinned (it is a
#             startup race; both branches are deterministic).
#   dss       the DSS query-param matrix: collide_with_areas defaults FALSE
#             for rays (miss without, hit at 2.75 with), hit_from_inside
#             sees the inner surface from inside only, trimesh
#             hit_back_faces is inert for the up-ray, and max_results=2
#             truncation is backend-ordered (GP tri,wall2 / Jolt tri,sph).
#   cb        CharacterBody3D edges: FLOATING never reports floor while
#             resting (fl=0 wlo=1, v.y free-integrates by the probe's own
#             scripted dt), floor_constant_speed holds |v|=2 on the 20 deg
#             downslope on GP and FAILS on Jolt, up_direction=+Z
#             reclassifies floor as wall, the plat_ride split is in the
#             reported slide count (GP n=1, Jolt n=0 while still carried),
#             safe_margin is a hover height (GP 0.5919 / Jolt 0.5969), and
#             max_slides=1 in the V-groove jitters on GP, quiet on Jolt.
#   vehicle   VehicleBody3D: the raycast-vehicle drop is backend- and
#             load-invariant (GP == Jolt byte-for-byte, settle 0.7299,
#             contact=4), engine_force=400 tumbles on both and diverges in
#             the chaotic tail (a divergence witness, pinned per-backend),
#             suspension_stiffness scales the still-sinking 2 s readings.
#   xr        the ClassDB instantiate+free teardown envelope: all 44
#             classes exist, can_instantiate=false only for the 5 named,
#             instantiate("XRServer") returns a DISTINCT second object
#             (identical=false), free() -> deterministic teardown crash
#             (rc=134 envelope, pinned as crash-class not text), while
#             leaking it exits cleanly with the expected
#             "Interface not found" + ObjectDB-leak notices.
#   freegrain deferred deletion is STEP-granular: a queue_free issued from
#             a physics tick is gone on the next tick even when both ticks
#             share one process frame (pinned under --fixed-fps batching at
#             2/4/6 ticks per frame, GP and Jolt).
#
# Not pinned (boundary-armed or not-replayed): the deferred-pin cells'
# values (two-valued setup race), solver_priority dominance, trimesh
# hit_back_faces=true semantics, floor_snap_length, recovery_as_collision=
# false, the GP thickness-selection rule, and every scout cell the boundary
# did not replay (slider/cone/g6/prio_*, the DSS pt_*/is_*/cs_*/cm_* set,
# the CB snap_*/ceil_*/blockwall*/realvel/recovery/wallslide/stop_on_ceil/
# constspd_off set, sbx impulse/pt_impulse/ray, vehicle brake/steer/skid/
# nowheel/noroll, cls_proj_dummy, iso_xrs_dummy).

const CHUNK := 8
const BOUND_S := 14

const JOLT := "3d/physics_engine=\"Jolt Physics\"\n"
const DUMMY := "3d/physics_engine=\"Dummy\"\n"

const WARN1 := "WARNING: Jolt Physics job system exceeded the maximum number of jobs. This should not happen. Please report this. Waiting for jobs to become available..."
const WARN2 := "     at: CreateJob (modules/jolt_physics/spaces/jolt_job_system.cpp:123)"

const CLEAN_SET := "VehicleBody3D,VehicleWheel3D,SoftBody3D,PinJoint3D," \
	+ "HingeJoint3D,SliderJoint3D,ConeTwistJoint3D," \
	+ "Generic6DOFJoint3D,CharacterBody3D,XRAnchor3D,XRCamera3D," \
	+ "XRController3D,XROrigin3D,MobileVRInterface,XRBodyTracker," \
	+ "XRHandTracker,XRFaceTracker,PhysicsShapeQueryParameters3D," \
	+ "PhysicsRayQueryParameters3D,PhysicsPointQueryParameters3D," \
	+ "SpringBoneSimulator3D,PhysicalBone3D,PhysicalBoneSimulator3D," \
	+ "BoneAttachment3D,Skeleton3D,RayCast3D,ShapeCast3D," \
	+ "SpringArm3D,AnimatableBody3D,StaticBody3D,RigidBody3D," \
	+ "Area3D,CollisionShape3D,CollisionPolygon3D," \
	+ "ConcavePolygonShape3D,ConvexPolygonShape3D," \
	+ "HeightMapShape3D,SeparationRayShape3D,WorldBoundaryShape3D"

const SUM_PREFIX := {
	"njoint": "NJSUM", "soft": "SBSUM", "r97b_softfloor": "SFSUM",
	"dssparam": "QSUM", "cbedge": "CBSUM", "vehicle": "VHSUM",
	"crashiso": "B DONE", "xrkeep": "XR DONE", "classdb": "SPOT",
	"r97b_free": "FRSUM",
}

# Expected-error allowlist heads. Each entry is either an exact line or a
# prefix; a matching ERROR-class head is kept in the hashed stream and
# counted in `ee` instead of failing the cell. "leak" is a sentinel for the
# ObjectDB-leak warning line (matched by regex).
const ERR_ALLOW := {
	"gp_soft": [
		"ERROR: Soft body's mesh needs to have indices",
		"ERROR: Condition \"p_index >= (int)map_visual_to_physics.size()\" is true.",
	],
	"jolt_soft": [
		"ERROR: Condition \"mesh_indices.is_empty()\" is true.",
		"ERROR: Parameter \"shared_settings\" is null.",
		"ERROR: Failed to set transform for '",
		"ERROR: Failed to retrieve point position for '",
	],
	"xr": [
		"ERROR: Interface not found.",
		"leak",
	],
	"crash": [
		"handle_crash: Program crashed with signal 11",
	],
}

# arm -> cell specs. n=name p=project pr=probe-suffix c=case args
# f=fields from the SUM line; x={pre,f} fields from one other row;
# e=allowlist classes; eargs=engine args; rc=expected rc; rpre=row prefix
# hashed into `rsha`; req/rdiff = compare rsha to a named cell in the same
# arm (pin row-identity / row-divergence).
const ARMS := {
	"joint": [
		{"n": "bind@gp", "p": "gp60", "pr": "njoint", "c": "--case=bind",
			"rpre": "NJ t="},
		{"n": "bind@jolt", "p": "jolt60", "pr": "njoint", "c": "--case=bind",
			"rpre": "NJ t="},
		{"n": "bindpre@gp", "p": "gp60", "pr": "njoint", "c": "--case=bindpre",
			"rpre": "NJ t=", "req": "bind@gp"},
		{"n": "badpath@gp", "p": "gp60", "pr": "njoint", "c": "--case=badpath",
			"rpre": "NJ t="},
		{"n": "badpath@jolt", "p": "jolt60", "pr": "njoint",
			"c": "--case=badpath", "rpre": "NJ t="},
		{"n": "nob@gp", "p": "gp60", "pr": "njoint", "c": "--case=nob",
			"rpre": "NJ t=", "req": "badpath@gp"},
		{"n": "bindnode@gp", "p": "gp60", "pr": "njoint",
			"c": "--case=bindnode",
			"x": {"pre": "NJ t=60 ", "f": ["a", "b", "jrid"]}},
		{"n": "getrid@gp", "p": "gp60", "pr": "njoint", "c": "--case=getrid",
			"x": {"pre": "NJ prerid", "f": ["prerid"]}},
		{"n": "getrid@jolt", "p": "jolt60", "pr": "njoint",
			"c": "--case=getrid",
			"x": {"pre": "NJ prerid", "f": ["prerid"]}},
		{"n": "getrid@dummy", "p": "dummy60", "pr": "njoint",
			"c": "--case=getrid",
			"x": {"pre": "NJ prerid", "f": ["prerid"]}},
		{"n": "freerj@gp", "p": "gp60", "pr": "njoint", "c": "--case=freerj",
			"x": {"pre": "NJ t=12 ", "f": ["jrid"]}},
		{"n": "freerj@jolt", "p": "jolt60", "pr": "njoint",
			"c": "--case=freerj",
			"x": {"pre": "NJ t=12 ", "f": ["jrid"]}},
		{"n": "freeb@gp", "p": "gp60", "pr": "njoint", "c": "--case=freeb",
			"x": {"pre": "NJ t=12 ", "f": ["b", "jrid"]}},
		{"n": "freeb@jolt", "p": "jolt60", "pr": "njoint",
			"c": "--case=freeb",
			"x": {"pre": "NJ t=12 ", "f": ["b", "jrid"]}},
		{"n": "readd@gp", "p": "gp60", "pr": "njoint", "c": "--case=readd",
			"x": {"pre": "NJ t=34 ", "f": ["jrid"]}},
		{"n": "repath@gp", "p": "gp60", "pr": "njoint", "c": "--case=repath",
			"x": {"pre": "NJ t=50 ", "f": ["jrid"]}},
		{"n": "repath@jolt", "p": "jolt60", "pr": "njoint",
			"c": "--case=repath",
			"x": {"pre": "NJ t=50 ", "f": ["jrid"]}},
		{"n": "dupclaim@gp", "p": "gp60", "pr": "njoint",
			"c": "--case=dupclaim",
			"x": {"pre": "NJ t=60 ", "f": ["jrid"]}},
		{"n": "hmot@gp", "p": "gp60", "pr": "njoint", "c": "--case=hmot",
			"x": {"pre": "NJ t=60 ", "f": ["avb"]}},
		{"n": "hmot@jolt", "p": "jolt60", "pr": "njoint", "c": "--case=hmot",
			"x": {"pre": "NJ t=60 ", "f": ["avb"]}},
		{"n": "hlim@gp", "p": "gp60", "pr": "njoint", "c": "--case=hlim",
			"x": {"pre": "NJ t=60 ", "f": ["avb"]}},
		{"n": "exclx_on@gp", "p": "gp60", "pr": "njoint",
			"c": "--case=exclx_on", "rpre": "NJ t="},
		{"n": "exclx_off@gp", "p": "gp60", "pr": "njoint",
			"c": "--case=exclx_off", "rpre": "NJ t=",
			"rdiff": "exclx_on@gp"},
		{"n": "clampbig@gp", "p": "gp60", "pr": "njoint",
			"c": "--case=clampbig",
			"x": {"pre": "NJ t=4 ", "f": ["avb"]}},
	],
	"soft": [
		{"n": "drop_unidx@gp", "p": "gp60", "pr": "soft", "c": "--case=drop",
			"e": ["gp_soft"],
			"x": {"pre": "SB t=120 ", "f": ["v4"]}},
		{"n": "nomesh@gp", "p": "gp60", "pr": "soft", "c": "--case=nomesh",
			"x": {"pre": "SB t=120 ", "f": ["v4"]}},
		{"n": "drop_idx@gp", "p": "gp60", "pr": "soft",
			"c": "--case=drop --indexed",
			"x": {"pre": "SB t=120 ", "f": ["v4"]}},
		{"n": "drop_idx@jolt", "p": "jolt60", "pr": "soft",
			"c": "--case=drop --indexed",
			"x": {"pre": "SB t=60 ", "f": ["v4"]}},
		{"n": "mass_hi@jolt", "p": "jolt60", "pr": "soft",
			"c": "--case=mass --mass=10.0 --indexed",
			"x": {"pre": "SB t=120 ", "f": ["v4"]}},
		{"n": "prec_hi@jolt", "p": "jolt60", "pr": "soft",
			"c": "--case=prec --prec=50 --indexed",
			"x": {"pre": "SB t=120 ", "f": ["v4"]}},
		{"n": "freeme@gp", "p": "gp60", "pr": "soft",
			"c": "--case=freeme --indexed",
			"x": {"pre": "SB t=30 ", "f": ["v4"]}},
	],
	"dss": [
		{"n": "ray_areas@gp", "p": "gp60", "pr": "dssparam",
			"c": "--case=ray_areas",
			"x": {"pre": "Q ray_areas ", "f": ["n", "col"]}},
		{"n": "ray_areason@gp", "p": "gp60", "pr": "dssparam",
			"c": "--case=ray_areason",
			"x": {"pre": "Q ray_areason ", "f": ["n", "col", "pos"]}},
		{"n": "ray_hfi_in@gp", "p": "gp60", "pr": "dssparam",
			"c": "--case=ray_hfi_in",
			"x": {"pre": "Q ray_hfi_in ", "f": ["n", "col", "pos", "nrm"]}},
		{"n": "ray_bf_upon@gp", "p": "gp60", "pr": "dssparam",
			"c": "--case=ray_bf_upon",
			"x": {"pre": "Q ray_bf_upon ", "f": ["n"]}},
		{"n": "maxres@gp", "p": "gp60", "pr": "dssparam",
			"c": "--case=maxres",
			"x": {"pre": "Q maxres ", "f": ["n", "cols"]}},
		{"n": "maxres@jolt", "p": "jolt60", "pr": "dssparam",
			"c": "--case=maxres",
			"x": {"pre": "Q maxres ", "f": ["n", "cols"]}},
	],
	"cb": [
		{"n": "float@gp", "p": "gp60", "pr": "cbedge", "c": "--case=float",
			"x": {"pre": "CB t=120 ", "f": ["fl", "wlo", "v"]}},
		{"n": "float@jolt", "p": "jolt60", "pr": "cbedge", "c": "--case=float",
			"x": {"pre": "CB t=120 ", "f": ["fl", "wlo", "v"]}},
		{"n": "constspd@gp", "p": "gp60", "pr": "cbedge",
			"c": "--case=constspd",
			"x": {"pre": "CB t=60 ", "f": ["rv", "fl"]}},
		{"n": "constspd@jolt", "p": "jolt60", "pr": "cbedge",
			"c": "--case=constspd",
			"x": {"pre": "CB t=120 ", "f": ["rv", "fl"]}},
		{"n": "updir@gp", "p": "gp60", "pr": "cbedge", "c": "--case=updir",
			"x": {"pre": "CB t=120 ", "f": ["fl", "wlo"]}},
		{"n": "plat_ride@gp", "p": "gp60", "pr": "cbedge",
			"c": "--case=plat_ride",
			"x": {"pre": "CB t=120 ", "f": ["fl", "n", "pvel", "rv"]}},
		{"n": "plat_ride@jolt", "p": "jolt60", "pr": "cbedge",
			"c": "--case=plat_ride",
			"x": {"pre": "CB t=120 ", "f": ["fl", "n", "pvel", "rv"]}},
		{"n": "margin_hi@gp", "p": "gp60", "pr": "cbedge",
			"c": "--case=margin_hi",
			"x": {"pre": "CB t=120 ", "f": ["pos", "fl"]}},
		{"n": "margin_hi@jolt", "p": "jolt60", "pr": "cbedge",
			"c": "--case=margin_hi",
			"x": {"pre": "CB t=120 ", "f": ["pos", "fl"]}},
		{"n": "maxslides@gp", "p": "gp60", "pr": "cbedge",
			"c": "--case=maxslides",
			"x": {"pre": "CB t=120 ", "f": ["rv", "pos"]}},
		{"n": "maxslides@jolt", "p": "jolt60", "pr": "cbedge",
			"c": "--case=maxslides",
			"x": {"pre": "CB t=120 ", "f": ["rv", "pos"]}},
	],
	"vehicle": [
		{"n": "drop@gp", "p": "gp60", "pr": "vehicle", "c": "--case=drop",
			"x": {"pre": "VH t=120 ", "f": ["pos", "contact"]}},
		{"n": "drop@jolt", "p": "jolt60", "pr": "vehicle", "c": "--case=drop",
			"x": {"pre": "VH t=120 ", "f": ["pos", "contact"]},
			"feq": "drop@gp"},
		{"n": "drive@gp", "p": "gp60", "pr": "vehicle", "c": "--case=drive",
			"rpre": "VH t="},
		{"n": "drive@jolt", "p": "jolt60", "pr": "vehicle",
			"c": "--case=drive", "rpre": "VH t=", "rdiff": "drive@gp"},
		{"n": "susp5@gp", "p": "gp60", "pr": "vehicle",
			"c": "--case=susp --susp=5.0",
			"x": {"pre": "VH t=120 ", "f": ["pos", "v"]}},
		{"n": "susp0@gp", "p": "gp60", "pr": "vehicle",
			"c": "--case=susp --susp=0.0",
			"x": {"pre": "VH t=120 ", "f": ["pos", "v"]}},
	],
}

var PROJECTS := {}
var arm := ""
var parts: Array = []
var notes: Array = []
var _leak_re: RegEx
var _id_re: RegEx
var _frame_re: RegEx

var run_prefix := ""


func _d(name: String) -> String:
	# child dirs are namespaced by pid so two concurrent parent instances (a
	# rep sweep) can never share a child dir.
	return "%s%s" % [run_prefix, name]


func _base(tps: int) -> String:
	return ("[application]\n\nconfig/name=\"R97Scout\"\n\n[physics]\n\n"
			+ "common/physics_ticks_per_second=%d\n") % tps


func _build_projects() -> void:
	PROJECTS = {
		"gp60": _base(60),
		"jolt60": _base(60) + JOLT,
		"dummy60": _base(60) + DUMMY,
		"gp120": _base(120),
		"jolt120": _base(120) + JOLT,
	}


func _initialize() -> void:
	_build_projects()
	run_prefix = "r97t%d_" % OS.get_process_id()
	_leak_re = RegEx.new()
	_leak_re.compile("^WARNING: [1-9][0-9]* ObjectDB instances? (were|was) leaked at exit")
	_id_re = RegEx.new()
	_id_re.compile("#[0-9]+")
	_frame_re = RegEx.new()
	_frame_re.compile("^\\[(\\d+)\\] ")
	call_deferred("_run")


func _run() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--arm="):
			arm = a.substr(6)
	var ok := false
	match arm:
		"joint", "soft", "dss", "cb", "vehicle":
			ok = _run_cells(ARMS[arm])
		"softfloor":
			ok = _run_softfloor()
		"xr":
			ok = _run_xr()
		"freegrain":
			ok = _run_freegrain()
		_:
			print("FAIL r97_nodelat unknown arm=%s" % arm)
			quit(0)
			return
	for n in notes:
		print("# r97_nodelat %s %s" % [arm, n])
	if ok:
		print("PASS r97_nodelat %s %s" % [arm, " ".join(parts)])
	else:
		print("FAIL r97_nodelat %s %s" % [arm, " ".join(parts)])
	quit(0)


# --- scanner ----------------------------------------------------------------

func _sha16(lines: Array) -> String:
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update("\n".join(lines).to_utf8_buffer())
	return ctx.finish().hex_encode().substr(0, 16)


func _mask_ids(line: String) -> String:
	return _id_re.sub(line, "#N", true)


func _allowed(line: String, allow: Array) -> bool:
	for cls in allow:
		for head in ERR_ALLOW.get(cls, []):
			if head == "leak":
				continue
			if line == head or line.begins_with(head):
				return true
	return false


func _scan_lines(src: Array, allow: Array) -> Dictionary:
	var m: Array = []
	var w := 0
	var lk := 0
	var ee := 0
	var ue: Array = []
	var i := 0
	while i < src.size():
		var line: String = src[i]
		if line.is_empty() or line.begins_with("Godot Engine v"):
			i += 1
			continue
		if line == WARN1 and i + 1 < src.size() and src[i + 1] == WARN2:
			w += 1
			i += 2
			continue
		if line.begins_with("Load address:"):
			m.append("Load address: A")
			i += 1
			continue
		var fm := _frame_re.search(line)
		if fm != null:
			m.append("[%s] F" % fm.get_string(1))
			i += 1
			continue
		var is_err: bool = line.begins_with("ERROR:") \
				or "SCRIPT ERROR" in line or "Parse Error" in line \
				or "handle_crash" in line
		if is_err:
			if _allowed(line, allow):
				ee += 1
				m.append(_mask_ids(line))
			else:
				ue.append(line.strip_edges())
			i += 1
			continue
		if _leak_re.search(line) != null:
			if allow.has("xr"):
				lk += 1
				m.append(_mask_ids(line))
			else:
				ue.append(line.strip_edges())
			i += 1
			continue
		m.append(_mask_ids(line))
		i += 1
	return {"m": m, "sha": _sha16(m), "w": w, "lk": lk, "ee": ee, "ue": ue}


func _scan(path: String, allow: Array, cap := 0) -> Dictionary:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {"err": "child log missing"}
	var n := f.get_length()
	var txt := ""
	if cap > 0 and n > cap:
		txt = f.get_buffer(cap).get_string_from_utf8()
	else:
		txt = f.get_as_text()
	f.close()
	var res := _scan_lines(txt.split("\n"), allow)
	res["truncated"] = cap > 0 and n > cap
	return res


func _field(line: String, name: String) -> String:
	var key := " " + name + "="
	var i := line.find(key)
	if i < 0:
		return ""
	var rest := line.substr(i + key.length())
	var j := rest.find(" ")
	return rest if j < 0 else rest.substr(0, j)


func _sum_line(m: Array, probe: String) -> String:
	var pre: String = SUM_PREFIX.get(probe, "")
	for line in m:
		if line.begins_with(pre):
			return line
	return ""


func _line_with(m: Array, pre: String) -> String:
	for line in m:
		if line.begins_with(pre):
			return line
	return ""


func _rsha(res: Dictionary, rpre: String) -> String:
	var rows: Array = []
	for line in res.get("m", []):
		if line.begins_with(rpre):
			rows.append(line)
	return _sha16(rows)


func _cell_text(name: String, res: Dictionary, spec: Dictionary,
		byname: Dictionary) -> String:
	if res.has("err"):
		return "%s{err=%s}" % [name, res["err"]]
	var txt := "%s{rc=%d,sha=%s" % [name, res["rc"], res["sha"]]
	var sum := _sum_line(res["m"], spec.get("pr", ""))
	for fname in spec.get("f", []):
		txt += ",%s=%s" % [fname, _field(sum, fname)]
	if spec.has("x"):
		var ln := _line_with(res["m"], spec["x"]["pre"])
		for fname in spec["x"]["f"]:
			txt += ",%s=%s" % [fname, _field(ln, fname)]
	if res.get("ee", 0) > 0:
		txt += ",ee=%d" % res["ee"]
	if res.get("lk", 0) > 0:
		txt += ",lk=%d" % res["lk"]
	if spec.has("rpre"):
		var rs := _rsha(res, spec["rpre"])
		txt += ",rsha=%s" % rs
		if spec.has("req"):
			var other: Dictionary = byname.get(spec["req"], {})
			txt += ",req=%d" % (1 if rs == _rsha(other, spec["rpre"]) else 0)
		if spec.has("rdiff"):
			var other: Dictionary = byname.get(spec["rdiff"], {})
			txt += ",rdiff=%d" % (0 if rs == _rsha(other, spec["rpre"]) else 1)
	if spec.has("feq"):
		var other: Dictionary = byname.get(spec["feq"], {})
		txt += ",feq=%d" % (1 if res["sha"] == other.get("sha", "-") else 0)
	return txt + "}"


func _cell_ok(res: Dictionary, spec: Dictionary) -> bool:
	if res.has("err") or not res.get("ue", []).is_empty():
		return false
	return res.get("rc", -1) == spec.get("rc", 0)


# --- child spawn machinery --------------------------------------------------

func _child_prepare(spec: Dictionary) -> Dictionary:
	var dirname: String = spec["dir"]
	if dirname.is_empty() or ".." in dirname or "/" in dirname \
			or "\\" in dirname or ":" in dirname:
		return {"err": "rejected dirname '%s'" % dirname}
	for i in dirname.length():
		var c := dirname.unicode_at(i)
		var ok := (c >= 0x30 and c <= 0x39) or (c >= 0x41 and c <= 0x5A) \
				or (c >= 0x61 and c <= 0x7A) or c == 0x5F or c == 0x2D
		if not ok:
			return {"err": "rejected dirname char U+%04X" % c}
	var dir := ProjectSettings.globalize_path("res://" + dirname)
	var mk := DirAccess.make_dir_recursive_absolute(dir)
	if mk != OK:
		return {"err": "cannot make %s err=%d" % [dirname, mk]}
	var pf := FileAccess.open(dir.path_join("project.godot"), FileAccess.WRITE)
	if pf == null:
		return {"err": "cannot write child project"}
	pf.store_string(PROJECTS[spec["body"]])
	pf.close()
	var src := FileAccess.open("res://r97_probe_%s.gd" % spec["probe"],
			FileAccess.READ)
	if src == null:
		return {"err": "probe source missing"}
	var dst := FileAccess.open(dir.path_join(spec["probe"] + ".gd"),
			FileAccess.WRITE)
	if dst == null:
		return {"err": "cannot write child probe"}
	dst.store_buffer(src.get_buffer(src.get_length()))
	src.close()
	dst.close()
	var logpath := dir.path_join("child.log")
	var bound: int = spec.get("bound", BOUND_S)
	var cmd := ("timeout -s KILL %d \"%s\" --headless %s --path \"%s\""
			+ " --script \"res://%s.gd\" -- %s > \"%s\" 2>&1") % [
			bound, OS.get_executable_path(), spec.get("eargs", ""), dir,
			spec["probe"], spec["case"], logpath]
	DirAccess.remove_absolute(logpath)
	return {"dir": dir, "logpath": logpath, "cmd": cmd}


func _spawn_batch(specs: Array) -> Array:
	var preps := []
	for spec in specs:
		var prep := _child_prepare(spec)
		if not prep.has("err"):
			var pid := OS.create_process("/bin/sh", ["-c", prep["cmd"]])
			if pid <= 0:
				prep = {"err": "cannot create child process"}
			else:
				prep["pid"] = pid
		preps.append(prep)
	var deadline := Time.get_ticks_msec() + BOUND_S * 1000
	var running := true
	while running and Time.get_ticks_msec() < deadline:
		running = false
		for prep in preps:
			if prep.has("pid") and OS.is_process_running(prep["pid"]):
				running = true
		if running:
			OS.delay_msec(20)
	var out := []
	for i in preps.size():
		var prep: Dictionary = preps[i]
		if prep.has("err"):
			out.append(prep)
			continue
		if OS.is_process_running(prep["pid"]):
			OS.kill(prep["pid"])
		var res := _scan(prep["logpath"], specs[i].get("e", []),
				specs[i].get("cap", 0))
		res["rc"] = OS.get_process_exit_code(prep["pid"])
		out.append(res)
	return out


func _chunks(specs: Array) -> Array:
	var out := []
	var i := 0
	while i < specs.size():
		out.append(specs.slice(i, min(i + CHUNK, specs.size())))
		i += CHUNK
	return out


func _run_all(specs: Array) -> Array:
	var out := []
	for chunk in _chunks(specs):
		out.append_array(_spawn_batch(chunk))
	return out


# --- generic arm ------------------------------------------------------------

func _run_cells(cells: Array) -> bool:
	var specs := []
	for c in cells:
		specs.append({"dir": _d("%s_%s" % [arm, c["n"].replace("@", "_")]),
			"body": c["p"], "probe": c["pr"], "case": c["c"],
			"e": c.get("e", []), "eargs": c.get("eargs", "")})
	var out := _run_all(specs)
	var ok := true
	var byname := {}
	for i in cells.size():
		byname[cells[i]["n"]] = out[i]
	for i in cells.size():
		var res: Dictionary = out[i]
		parts.append(_cell_text(cells[i]["n"], res, cells[i], byname))
		if not _cell_ok(res, cells[i]):
			ok = false
			notes.append("%s ue=%s" % [cells[i]["n"],
					",".join(res.get("ue", []))])
	return ok


# --- softfloor arm ------------------------------------------------------------

func _run_softfloor() -> bool:
	var cells := [
		{"n": "drop_t01@gp", "p": "gp60", "c": "--case=drop --thick=0.1",
			"x": {"pre": "SF t=120 ", "f": ["v4", "below"]}},
		{"n": "drop_t02@gp", "p": "gp60", "c": "--case=drop --thick=0.2",
			"x": {"pre": "SF t=120 ", "f": ["v4", "below"]}},
		{"n": "drop_t04@gp", "p": "gp60", "c": "--case=drop --thick=0.4",
			"x": {"pre": "SF t=120 ", "f": ["v4", "below"]}},
		{"n": "drop_t05@gp", "p": "gp60", "c": "--case=drop --thick=0.5",
			"x": {"pre": "SF t=120 ", "f": ["v4", "below"]}},
		{"n": "drop_t20@gp", "p": "gp60", "c": "--case=drop --thick=2.0",
			"x": {"pre": "SF t=120 ", "f": ["v4", "below"]}},
		{"n": "drop_t01@jolt", "p": "jolt60",
			"c": "--case=drop --thick=0.1",
			"x": {"pre": "SF t=60 ", "f": ["v4", "below"]}},
		{"n": "drop_t20@jolt", "p": "jolt60",
			"c": "--case=drop --thick=2.0",
			"x": {"pre": "SF t=120 ", "f": ["v4", "below"]}},
		{"n": "drop_t20@dummy", "p": "dummy60",
			"c": "--case=drop --thick=2.0",
			"x": {"pre": "SF t=120 ", "f": ["v4", "below"]}},
		{"n": "mass_hi_t20@jolt", "p": "jolt60",
			"c": "--case=drop --thick=2.0 --mass=10.0",
			"x": {"pre": "SF t=120 ", "f": ["v4", "below"]}},
		{"n": "prec_hi_t20@jolt", "p": "jolt60",
			"c": "--case=drop --thick=2.0 --prec=50",
			"x": {"pre": "SF t=120 ", "f": ["v4", "below"]}},
		{"n": "collide_now@gp", "p": "gp60",
			"c": "--case=collide --thick=0.1 --pins=now",
			"x": {"pre": "SF t=120 ", "f": ["v4", "ball"]}},
		{"n": "collide_now@jolt", "p": "jolt60",
			"c": "--case=collide --thick=0.1 --pins=now",
			"x": {"pre": "SF t=120 ", "f": ["v4", "ball"]}},
		{"n": "pinmid_now@gp", "p": "gp60",
			"c": "--case=collide --thick=0.1 --pins=now --pin=mid",
			"x": {"pre": "SF t=120 ", "f": ["v4", "v0"]}},
	]
	var specs := []
	for c in cells:
		specs.append({"dir": _d("sf_%s" % c["n"].replace("@", "_")),
			"body": c["p"], "probe": "r97b_softfloor", "case": c["c"],
			"e": [], "eargs": ""})
	# deferred-pin census (the two-valued setup race): pf is counted in '#'
	# diagnostics only and never enters a pinned cell.
	var census := []
	for i in 4:
		census.append({"dir": _d("sf_def_r%d" % (i + 1)), "body": "gp60",
			"probe": "r97b_softfloor",
			"case": "--case=collide --thick=0.1", "e": [], "eargs": ""})
	var out := _run_all(specs + census)
	var pinned := out.slice(0, specs.size())
	var defs := out.slice(specs.size())
	var ok := true
	var byname := {}
	for i in cells.size():
		byname[cells[i]["n"]] = pinned[i]
	for i in cells.size():
		var res: Dictionary = pinned[i]
		parts.append(_cell_text(cells[i]["n"], res, cells[i], byname))
		if not _cell_ok(res, cells[i]):
			ok = false
			notes.append("%s ue=%s" % [cells[i]["n"],
					",".join(res.get("ue", []))])
	var pf0 := 0
	var pf1 := 0
	for res in defs:
		var ln := _line_with(res.get("m", []), "SF pins applied at pf=")
		var pf := _field(ln, "pf")
		if pf == "0":
			pf0 += 1
		elif pf == "1":
			pf1 += 1
		else:
			ok = false
	notes.append(("deferred pinphase census pf0=%d pf1=%d (two-valued race; "
			+ "never pinned)") % [pf0, pf1])
	return ok


# --- xr arm -----------------------------------------------------------------

func _run_xr() -> bool:
	var cells := [
		{"n": "cls@gp", "p": "gp60", "pr": "classdb", "c": "",
			"e": ["crash"], "rc": 134, "tag": "cls"},
		{"n": "cls@jolt", "p": "jolt60", "pr": "classdb", "c": "",
			"e": ["crash"], "rc": 134, "tag": "cls"},
		{"n": "iso_clean@gp", "p": "gp60", "pr": "crashiso", "c": CLEAN_SET,
			"tag": "iso"},
		{"n": "iso_xrs@gp", "p": "gp60", "pr": "crashiso", "c": "XRServer",
			"e": ["crash"], "rc": 134, "tag": "iso"},
		{"n": "iso_xrs@jolt", "p": "jolt60", "pr": "crashiso", "c": "XRServer",
			"e": ["crash"], "rc": 134, "tag": "iso"},
		{"n": "xr_same@gp", "p": "gp60", "pr": "xrkeep", "c": "--case=same",
			"e": ["xr"], "tag": "xr"},
		{"n": "xr_keep@gp", "p": "gp60", "pr": "xrkeep", "c": "--case=keep",
			"e": ["xr"], "tag": "xr"},
		{"n": "xr_dbl@gp", "p": "gp60", "pr": "xrkeep", "c": "--case=dbl",
			"e": ["xr"], "tag": "xr"},
	]
	var specs := []
	for c in cells:
		specs.append({"dir": _d("xr_%s" % c["n"].replace("@", "_")),
			"body": c["p"], "probe": c["pr"], "case": c["c"],
			"e": c.get("e", []), "eargs": ""})
	var out := _run_all(specs)
	var ok := true
	var byname := {}
	for i in cells.size():
		byname[cells[i]["n"]] = out[i]
	for i in cells.size():
		var res: Dictionary = out[i]
		var spec: Dictionary = cells[i]
		var txt := _cell_text(spec["n"], res, spec, byname)
		# cell-specific field extraction
		match spec["tag"]:
			"cls":
				var exists := 0
				var noinst := 0
				for line in res.get("m", []):
					if line.begins_with("CLS ") and "exists=true" in line:
						exists += 1
						if "inst=no_instantiate" in line:
							noinst += 1
				txt = txt.substr(0, txt.length() - 1) \
						+ ",classes=%d,noinst=%d,fatal=%d}" % [
						exists, noinst, 1 if res.get("ee", 0) > 0 else 0]
			"iso":
				var done := _line_with(res.get("m", []), "B DONE")
				txt = txt.substr(0, txt.length() - 1) \
						+ ",done=%d,fatal=%d}" % [
						0 if done.is_empty() else 1,
						1 if res.get("ee", 0) > 0 else 0]
			"xr":
				var ln := _line_with(res.get("m", []), "XR ")
				var extra := ""
				if spec["c"].ends_with("same"):
					extra = ",identical=%s" % _field(ln, "identical")
				elif spec["c"].ends_with("dbl"):
					extra = ",same=%s" % _field(ln, "same")
				txt = txt.substr(0, txt.length() - 1) + "%s}" % extra
		parts.append(txt)
		if not _cell_ok(res, spec):
			ok = false
			notes.append("%s ue=%s" % [spec["n"],
					",".join(res.get("ue", []))])
	return ok


# --- freegrain arm ------------------------------------------------------------

func _run_freegrain() -> bool:
	var cells := [
		{"n": "ffps10_at6@gp", "p": "gp60", "at": 6,
			"eargs": "--fixed-fps 10"},
		{"n": "ffps60_at8@gp120", "p": "gp120", "at": 8,
			"eargs": "--fixed-fps 60"},
		{"n": "ffps30_at4@gp120", "p": "gp120", "at": 4,
			"eargs": "--fixed-fps 30"},
		{"n": "ffps60_at8@jolt120", "p": "jolt120", "at": 8,
			"eargs": "--fixed-fps 60"},
	]
	var specs := []
	for c in cells:
		specs.append({"dir": _d("fg_%s" % c["n"].replace("@", "_")),
			"body": c["p"], "probe": "r97b_free",
			"case": "--at=%d" % c["at"], "e": [],
			"eargs": c["eargs"]})
	var out := _run_all(specs)
	var ok := true
	for i in cells.size():
		var res: Dictionary = out[i]
		var spec: Dictionary = cells[i]
		var at: int = spec["at"]
		var ff_at := ""
		var ff_next := ""
		var alive_next := ""
		var jrid30 := ""
		for line in res.get("m", []):
			if line.begins_with("FR freeing at t=%d " % at):
				ff_at = _field(line, "ff")
			elif line.begins_with("FR t=%d " % (at + 1)):
				ff_next = _field(line, "ff")
				alive_next = _field(line, "alive")
			elif line.begins_with("FR t=30 "):
				jrid30 = _field(line, "jrid")
		var same: bool = ff_at != "" and ff_at == ff_next
		var gone: bool = alive_next == "false" and jrid30 == "gone"
		var cell := "%s{rc=%d,sha=%s,same_frame=%d,gone_next=%d}" % [
				spec["n"], res.get("rc", -1), res.get("sha", "-"),
				1 if same else 0, 1 if gone else 0]
		parts.append(cell)
		if not _cell_ok(res, {"rc": 0}) or not same or not gone:
			ok = false
			notes.append("%s ue=%s" % [spec["n"],
					",".join(res.get("ue", []))])
	return ok
