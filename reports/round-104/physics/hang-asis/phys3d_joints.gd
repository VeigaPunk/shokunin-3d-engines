extends SceneTree
# r90 fixture — joint RID lifecycle + solver-priority + freed-endpoint
# lattice, measured on all three 3D backends. One arm per battery row:
#   godot --headless --path <scratch> --script res://phys3d_joints.gd -- --arm=<name>
# Boot-selected 3d physics engine is a per-project constant, so each
# (case, backend) measurement spawns a child Godot process into a
# generated minimal project under res://r90bt_*/ running r90_child.gd;
# the parent scans the child's merged log for `M`-prefix verdict lines,
# ERROR/WARNING counts and crash-class evidence, and prints ONE digest
# line per run. No object ids / addresses / timestamps are emitted.
#
# Crash cells (a case frees a live body's RID): the pin is the envelope
# class — `mode_ok` plus the stable M-prefix sha — never ASLR backtrace
# bytes; rc class and crash marker are admission predicates (the BIMODAL
# table below names both realizations per cell).
#
# Arms (the `match` dispatch is the sole index):
#   sweep      joint_set_solver_priority round-trip -2..128 + unmade sets
#   rid        joint RID create/free/recreate alias classes
#   api        ClassDB presence/instantiation/method surface per backend
#   free_pair  freeb / freea / freeb_dyn — freed endpoint witnesses
#   free_ops   freeb_ops / freeb_twice / freeb_make / freeb_world /
#              freeb_afterclear / freej_then_b / detachb_free
#   detach     detachb — space detach/reattach around a live joint
#   chain3     chain3_freemid — 3-body chain mid free
#   twopin     twopin_hi1 / twopin_hi2 — two-pin priority ordering t=16

var arm := ""
const BOUND_S := 20
const BATCH_BOUND_S := 16
const BACKENDS := [["gp", ""], ["jolt", "Jolt Physics"], ["dummy", "Dummy"]]

const ARM_CASES := {
	"sweep": ["sweep"],
	"rid": ["rid"],
	"api": ["api"],
	"free_pair": ["freeb", "freea", "freeb_dyn"],
	"free_ops": ["freeb_ops", "freeb_twice", "freeb_make",
			"freeb_world", "freeb_afterclear", "freej_then_b",
			"detachb_free"],
	"detach": ["detachb"],
	"chain3": ["chain3_freemid"],
	"twopin": ["twopin_hi1", "twopin_hi2"],
}

# Teardown-UAF window (r90 verifier): the child's teardown loop frees
# [joint, joint2] + joints + bodies + shapes unconditionally, so any case
# that frees one of those RIDs mid-run makes the teardown re-free a UAF —
# Invalid ID (clean rc=0) or SIGSEGV (rc 134/137/139), decided per run by
# heap state. A 504-run matrix (corpus/live/r90-repair/mx.csv, every
# endpoint case x 3 backends x 12 reps) shows the mechanism present on
# every exposed gp+jolt cell (the teardown loop re-frees the case's freed
# RID) and the crash realized on 9 of those 20 tags inside the 12-rep
# matrix window (the 10th, freeb@gp, realized on the simplifier lane
# outside the matrix); Dummy never realizes it (its free_rid is inert).
# sweep/rid/api quit() in _initialize and never reach the teardown loop;
# freeb_world/detachb/twopin_* free nothing.
# BIMODAL maps each exposed tag -> [n_pre, full_msz]: cells emit
# mode_ok plus the sha of the first n_pre M-lines. n_pre is the full
# line count when every observed crash lands post-DONE (teardown window:
# m is complete in both modes) and the shared prefix length when a
# mid-ops crash truncates the stream (freeb_ops, freeb_dyn, chain3@gp).
# e/w are mode-dependent (the clean teardown logs the Invalid ID the
# crash replaces) and are never emitted for these cells.
const BIMODAL := {
	"freeb@gp": [11, 11], "freea@gp": [11, 11],
	"freeb_dyn@gp": [8, 11], "freeb_ops@gp": [6, 8],
	"freeb_make@gp": [4, 4], "freeb_twice@gp": [4, 4],
	"freeb_afterclear@gp": [4, 4], "freej_then_b@gp": [4, 4],
	"detachb_free@gp": [4, 4], "chain3_freemid@gp": [2, 3],
	"freeb@jolt": [11, 11], "freea@jolt": [11, 11],
	"freeb_dyn@jolt": [11, 11], "freeb_ops@jolt": [6, 8],
	"freeb_make@jolt": [4, 4], "freeb_twice@jolt": [4, 4],
	"freeb_afterclear@jolt": [4, 4], "freej_then_b@jolt": [4, 4],
	"detachb_free@jolt": [4, 4], "chain3_freemid@jolt": [3, 3],
}


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--arm="):
			arm = a.substr(6)
	call_deferred("_run")


func _run() -> void:
	if not ARM_CASES.has(arm):
		return _fail("unknown_arm")
	var jobs: Array = []
	for case in ARM_CASES[arm]:
		for bk in BACKENDS:
			var j := _spawn_child(case, bk[0], bk[1])
			if j.has("err"):
				return _fail("%s@%s %s" % [case, bk[0], j["err"]])
			jobs.append(j)
	for j in jobs:
		var d := _collect_child(j)
		if d.has("err"):
			return _fail("%s@%s %s" % [j["case"], j["bk"], d["err"]])
		_emit(j["case"], j["bk"], d)
	_finish()


func _fail(reason: String) -> void:
	print("FAIL phys3d_joints %s reason=%s" % [arm, reason])
	quit(1)


var _parts: Array = []

func _finish() -> void:
	print("PASS phys3d_joints %s %s" % [arm, " ".join(_parts)])
	quit(0)


func _project_body(name: String, engine: String) -> String:
	var body := ("[application]\n\nconfig/name=\"%s\"\n\n[physics]\n\n"
			+ "common/physics_ticks_per_second=60\n") % name
	if engine != "":
		body += "3d/physics_engine=\"%s\"\n" % engine
	return body


# r104 R3 — spawn every (case, backend) child first, then collect in the
# original nested-loop order. The emitted stream stays a pure function of the
# per-child logs; only the wall clock changes.
func _spawn_child(case: String, bk: String, engine: String) -> Dictionary:
	var dirname := "r90bt_%s_%s_%s" % [arm, case, bk]
	var dir := ProjectSettings.globalize_path("res://" + dirname)
	if DirAccess.make_dir_recursive_absolute(dir) != OK:
		return {"err": "mkdir failed"}
	var pf := FileAccess.open(dir.path_join("project.godot"),
			FileAccess.WRITE)
	if pf == null:
		return {"err": "cannot write child project"}
	pf.store_string(_project_body(dirname, engine))
	pf.close()
	var script_path := ProjectSettings.globalize_path("res://r90_child.gd")
	var logpath := dir.path_join("child.log")
	DirAccess.remove_absolute(logpath)
	var cmd := ("timeout -s KILL %d \"%s\" --headless --path \"%s\""
			+ " --script \"%s\" -- %s > \"%s\" 2>&1") % [
			BOUND_S, OS.get_executable_path(), dir, script_path, case,
			logpath]
	var pid := OS.create_process("/bin/sh", ["-c", cmd], false)
	if pid <= 0:
		return {"err": "spawn failed"}
	return {"case": case, "bk": bk, "pid": pid, "log": logpath}


func _collect_child(j: Dictionary) -> Dictionary:
	while OS.is_process_running(j["pid"]):
		OS.delay_msec(5)
	var code := OS.get_process_exit_code(j["pid"])
	var logpath: String = j["log"]
	var lf := FileAccess.open(logpath, FileAccess.READ)
	if lf == null:
		return {"err": "child log missing"}
	var mlines: Array = []
	var nerr := 0
	var nwarn := 0
	var sig11 := 0
	while not lf.eof_reached():
		var line := lf.get_line()
		if line.begins_with("M0 ") or line.begins_with("M "):
			mlines.append(line)
		elif line.begins_with("ERROR:"):
			nerr += 1
		elif line.begins_with("WARNING:"):
			nwarn += 1
		elif "handle_crash: Program crashed with signal 11" in line:
			sig11 += 1
	lf.close()
	return {"rc": code, "m": mlines, "ne": nerr, "nw": nwarn,
		"sig11": sig11}


func _emit(case: String, bk: String, d: Dictionary) -> void:
	var tag := "%s@%s" % [case, bk]
	if BIMODAL.has(tag):
		# Teardown-UAF cell: two named realizations share the emitted
		# prefix — clean completion (rc=0, sig11=0, m exactly full_msz)
		# or a SIGSEGV (rc 134/137/139, sig11=1) either mid-ops (m
		# truncated at >= n_pre) or post-DONE (m complete). Anything
		# outside both is mode_ok=0 and closes the row.
		var n_pre: int = BIMODAL[tag][0]
		var full_msz: int = BIMODAL[tag][1]
		var pre: Array = d["m"].slice(0, n_pre)
		var pre_sha := " ".join(pre).sha256_text().substr(0, 16)
		var msz: int = d["m"].size()
		var clean: bool = d["rc"] == 0 and d["sig11"] == 0 \
				and msz == full_msz
		var crash: bool = d["sig11"] == 1 \
				and (d["rc"] in [134, 137, 139]) and msz >= n_pre
		var mode_ok := 1 if clean or crash else 0
		_parts.append("%s{mode_ok=%d,m%d=%s}" % [
				tag, mode_ok, n_pre, pre_sha])
		return
	_parts.append("%s{rc=%d,m=%s,e=%d,w=%d}" % [
			tag, d["rc"], "|".join(d["m"]), d["ne"], d["nw"]])
