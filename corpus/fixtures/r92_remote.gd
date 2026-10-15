extends SceneTree
# r92 remote: the RemoteTransform3D frame-boundary lattice. Parent fixture —
# spawns res://r92_child.gd once per (case, backend) into a generated
# res://r92r_<arm>_<bk>_<case>/ child project and folds each merged log into
# a verbatim digest cell:
#
#     <case>@<bk>{rc=<rc>,m=<M-lines joined by |>,e=<n>,w=<n>,s=<n>}
#
# where e counts `ERROR:` lines, w counts `WARNING:` lines and s counts
# script/parse/leak/crash lines (all pinned at 0 by the markers). The
# child's own M rows carry only pf-stamped physics observables and labelled
# reads — the rep-stability contract measured in r92-scout; seq/n_e/n_f/
# anim_t stamps never cross this boundary.
#
# Laws pinned (all three engines, node side — RemoteTransform3D is a
# backend-blind SceneTree feature):
#   boundary: writes never propagate synchronously; the target observes the
#     pushed transform at the next frame boundary, whether the write ran in
#     an idle or a physics callback (one await suffices).
#   phase:    a physics-callback write is stale to a LATER same-tick
#     _physics_process and visible to the next idle/tick read; an
#     idle-callback write is stale to a same-frame _process reader and
#     visible post-boundary.
#   flags:    update_position/rotation/scale act independently;
#     use_global_coordinates=false pushes the source's local transform.
#   stale:    remote_path cache lifecycle — freed target, orphan target,
#     rebind, reparent, path "", path toggle, orphaned source.
#   path:     "."  and non-Node3D/missing/empty/absolute/parent paths all
#     leave the target untouched; a valid path rebinds cleanly.
#   chainlag: A->B->C->leaf converges in ONE frame regardless of tree order.
#   srv:      the pushed transform reaches body_get_state and the ray
#     surface — Dummy returns null/miss (pinned split).
#   drive:    set_process(false)/set_physics_process(false) do NOT gate the
#     propagation pass; use_global toggle + parent-scale push.

const BOUND_S := 10
const BATCH_BOUND_S := 15
const CHILD := "res://r92_child.gd"
const BACKENDS := [["gp", ""], ["jolt", "Jolt Physics"], ["dummy", "Dummy"]]
const ARM_CASES := {
	"boundary": ["sync", "lag"],
	"phase": ["phase"],
	"flags": ["flags"],
	"stale": ["stale"],
	"path": ["path"],
	"chainlag": ["chainlag"],
	"srv": ["srv"],
	"drive": ["driver", "parent", "local"],
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
		print("FAIL r92_remote unknown arm=%s" % arm)
		quit(0)
		return
	for c in ARM_CASES[arm]:
		_run_arm(c)
	print("PASS r92_remote %s %s" % [arm, " ".join(parts)])
	quit(0)


func _run_arm(case_name: String) -> void:
	var specs := []
	for b in BACKENDS:
		specs.append({
			"dirname": "r92r_%s_%s_%s" % [arm, b[0], case_name],
			"project_body": _project_body("r92r%s" % arm, b[1]),
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
