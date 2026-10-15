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
# Crash cells (GP frees a live body's RID): the pin is the envelope
# class — signal-class rc, M-prefix content/count, crash marker — never
# ASLR backtrace bytes. `freeb_ops` under GP is a measured bimodal
# crash-timing class (crash between pin_param and joint_clear ~2/3,
# clean completion ~1/3): the digest emits the stable 6-line prefix sha
# + `mode_ok` (both named realizations allowed), never one mode.
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

# Cases whose GP realization crashes inside the freed-endpoint window:
# digest emits rc-class + stable M-prefix, not raw stdout.
const GP_CRASH_CASES := {
	"freeb_ops": 6, "freeb_twice": 4, "freeb_dyn": 8,
	"chain3_freemid": 2,
}
# Only freeb_ops is rep-bimodal on GP (crash vs clean completion);
# the others crash deterministically.
const GP_BIMODAL := {"freeb_ops": true}


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--arm="):
			arm = a.substr(6)
	call_deferred("_run")


func _run() -> void:
	if not ARM_CASES.has(arm):
		_fail("unknown_arm")
	for case in ARM_CASES[arm]:
		for bk in BACKENDS:
			var d := _run_child(case, bk[0], bk[1])
			if d.has("err"):
				return _fail("%s@%s %s" % [case, bk[0], d["err"]])
			_emit(case, bk[0], d)
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


func _run_child(case: String, bk: String, engine: String) -> Dictionary:
	var dirname := "r90bt_%s_%s_%s" % [arm, case, bk]
	if dirname.length() > 0:
		for i in dirname.length():
			var c := dirname.unicode_at(i)
			var ok := (c >= 0x30 and c <= 0x39) or (c >= 0x41 and c <= 0x5A) \
					or (c >= 0x61 and c <= 0x7A) or c == 0x5F
			if not ok:
				return {"err": "unsafe dirname char U+%04X" % c}
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
	var code := OS.execute("/bin/sh", ["-c", cmd], [], false)
	var lf := FileAccess.open(logpath, FileAccess.READ)
	if lf == null:
		return {"err": "child log missing"}
	var mlines: Array = []
	var nerr := 0
	var nwarn := 0
	var sig11 := 0
	var throw_ := 0
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
		elif "std::system_error" in line:
			throw_ += 1
	lf.close()
	return {"rc": code, "m": mlines, "ne": nerr, "nw": nwarn,
		"sig11": sig11, "throw": throw_}


func _emit(case: String, bk: String, d: Dictionary) -> void:
	var tag := "%s@%s" % [case, bk]
	if GP_CRASH_CASES.has(case) and bk == "gp":
		# crash-envelope cell: pin the stable M-prefix (sha), the rc
		# class and the single crash marker. freeb_ops is rep-bimodal
		# (crash mid-ops vs clean completion) — mode_ok admits both
		# named realizations, either failing closes the row.
		var n_pre: int = GP_CRASH_CASES[case]
		var pre: Array = d["m"].slice(0, n_pre)
		var pre_sha := " ".join(pre).sha256_text().substr(0, 16)
		if GP_BIMODAL.has(case):
			# measured realizations: crash mid-ops (rc 134/137, e=1) or
			# clean completion (rc 0, m=prefix+2, e=2). Pin the shared
			# 6-line prefix + the named-mode set; e is mode-dependent.
			var mode_ok := 0
			if (d["rc"] == 134 or d["rc"] == 137) and d["sig11"] == 1 \
					and d["ne"] == 1:
				mode_ok = 1  # crash mid-ops
			elif d["rc"] == 0 and d["m"].size() == n_pre + 2 \
					and d["ne"] == 2:
				mode_ok = 1  # clean completion
			_parts.append("%s{mode_ok=%d,m%d=%s,w=%d}" % [
					tag, mode_ok, n_pre, pre_sha, d["nw"]])
			return
		# rc is bound-dependent (134 when the handler finishes, 137 when
		# the bound kills it mid-backtrace) — pin the signal class.
		var rcc := "sig" if d["rc"] in [134, 137, 139] else str(d["rc"])
		_parts.append("%s{rcc=%s,sig11=%d,m%d=%s,e=%d,w=%d}" % [
				tag, rcc, d["sig11"], n_pre, pre_sha,
				d["ne"], d["nw"]])
		return
	_parts.append("%s{rc=%d,m=%s,e=%d,w=%d}" % [
			tag, d["rc"], "|".join(d["m"]), d["ne"], d["nw"]])
