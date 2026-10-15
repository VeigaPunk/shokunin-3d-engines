extends SceneTree
# r92 timing: SceneTree/physics timing mutation edges. Parent fixture —
# spawns res://r92_child.gd per (case, backend) into res://r92t_<bk>_<case>/
# and folds each merged log into a verbatim digest cell
# `<case>@<bk>{rc=..,m=<M-lines|..>,e=..,w=..,s=..}`.
#
# The child mutates Engine inside tick pf=5 and emits only pf-stamped
# delta rows for the post-mutation window pf=6..8 plus read-back rows —
# the rep-stability contract: engine-level timing is backend-blind, so all
# three engines must report identical M rows (the digest still records
# each backend's own M0 engine name).
#
# Laws pinned:
#   tps:    physics_ticks_per_second writes take effect on the NEXT tick —
#     30 -> delta 0.033333, 120 -> 0.008333.
#   tscale: time_scale multiplies the delivered delta at unchanged tps —
#     0.5 -> 0.008333, 2 -> 0.033333, 10 -> 0.166667.
#   edge:   time_scale=0 keeps physics callbacks alive with delta 0.000000
#     and pf still advances; time_scale=-1 delivers delta -0.016667.
#   refuse: physics_ticks_per_second=0 / -60 are refused with one engine
#     ERROR line each (e=1) and read back unchanged at 60.
#   steps:  max_physics_steps_per_frame=1 under time_scale=10 delivers the
#     full 0.166667 delta (not a clamped slice); a runtime
#     physics_interpolation write reads back true but leaves the delta
#     schedule unchanged; physics_jitter_fix=0.0 reads back 0.0000 with
#     the schedule unchanged (the scout arm had only ever written the
#     default 0.5 — this is the axis's first real measurement).

const BOUND_S := 10
const BATCH_BOUND_S := 15
const CHILD := "res://r92_child.gd"
const BACKENDS := [["gp", ""], ["jolt", "Jolt Physics"], ["dummy", "Dummy"]]
const ARM_CASES := {
	"tps": ["tm_tps30", "tm_tps120"],
	"tscale": ["tm_ts05", "tm_ts2big", "tm_tsbig"],
	"edge": ["tm_ts0", "tm_tsneg"],
	"refuse": ["tm_tps0", "tm_tpsneg"],
	"steps": ["tm_maxsteps", "tm_interpf", "tm_jitfix0"],
}

var arm := ""
var parts: Array = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var a := OS.get_cmdline_user_args()
	for arg in a:
		if arg.begins_with("--arm="):
			arm = arg.substr(6)
	if not ARM_CASES.has(arm):
		print("FAIL r92_timing unknown arm=%s" % arm)
		quit(0)
		return
	for c in ARM_CASES[arm]:
		_run_arm(c)
	print("PASS r92_timing %s %s" % [arm, " ".join(parts)])
	quit(0)


func _run_arm(case_name: String) -> void:
	var specs := []
	for b in BACKENDS:
		specs.append({
			"dirname": "r92t_%s_%s" % [b[0], case_name],
			"project_body": _project_body("r92t%s" % arm, b[1]),
			"case": case_name,
		})
	var out := _spawn_batch(specs)
	for i in BACKENDS.size():
		parts.append(_cell(case_name, BACKENDS[i][0], out[i]))


func _cell(case_name: String, bk: String, res: Dictionary) -> String:
	if res.has("err"):
		return "%s@%s{err=%s}" % [case_name, bk, res["err"]]
	return "%s@%s{rc=%d,m=%s,e=%d,w=%d,s=%d}" % [case_name, bk,
			res["rc"], "|".join(res["m"]), res["e"], res["w"], res["s"]]


func _project_body(name: String, engine := "") -> String:
	var body := ("[application]\n\nconfig/name=\"%s\"\n\n[physics]\n\n"
			+ "common/physics_ticks_per_second=60\n") % name
	if engine != "":
		body += "3d/physics_engine=\"%s\"\n" % engine
	return body


# --- child spawn machinery (the corpus's bounded-parallel conventions) ------

func _child_prepare(dirname: String, project_body: String, case_name: String) -> Dictionary:
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
	pf.store_string(project_body)
	pf.close()
	var script := ProjectSettings.globalize_path(CHILD)
	var logpath := dir.path_join("child.log")
	var cmd := ("timeout -s KILL %d \"%s\" --headless --path \"%s\""
			+ " --script \"%s\" -- %s > \"%s\" 2>&1") % [
			BOUND_S, OS.get_executable_path(), dir, script, case_name, logpath]
	DirAccess.remove_absolute(logpath)
	return {"dir": dir, "logpath": logpath, "cmd": cmd}


func _scan(prep: Dictionary, code: int) -> Dictionary:
	var res := {"rc": code, "m": [], "e": 0, "w": 0, "s": 0}
	var lf := FileAccess.open(prep["logpath"], FileAccess.READ)
	if lf == null:
		return {"err": "child log missing"}
	while not lf.eof_reached():
		var line := lf.get_line()
		if line.begins_with("M0 ") or line.begins_with("M "):
			res["m"].append(line)
		elif line.begins_with("ERROR:"):
			res["e"] += 1
		elif line.begins_with("WARNING:"):
			res["w"] += 1
		elif "SCRIPT ERROR" in line or "Parse Error" in line \
				or ("ObjectDB" in line and "leaked" in line) \
				or "handle_crash" in line:
			res["s"] += 1
	lf.close()
	return res


func _spawn_batch(specs: Array) -> Array:
	var preps := []
	for spec in specs:
		var prep := _child_prepare(spec["dirname"], spec["project_body"],
				spec["case"])
		if not prep.has("err"):
			var pid := OS.create_process("/bin/sh", ["-c", prep["cmd"]])
			if pid <= 0:
				prep = {"err": "cannot create child process"}
			else:
				prep["pid"] = pid
		preps.append(prep)
	var deadline := Time.get_ticks_msec() + BATCH_BOUND_S * 1000
	var running := true
	while running and Time.get_ticks_msec() < deadline:
		running = false
		for prep in preps:
			if prep.has("pid") and OS.is_process_running(prep["pid"]):
				running = true
		if running:
			OS.delay_msec(20)
	var out := []
	for prep in preps:
		if prep.has("err"):
			out.append(prep)
			continue
		if running and OS.is_process_running(prep["pid"]):
			OS.kill(prep["pid"])
		var code := OS.get_process_exit_code(prep["pid"])
		out.append(_scan(prep, code))
	return out
