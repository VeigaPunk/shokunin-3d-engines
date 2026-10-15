extends SceneTree
# r92 animphys: AnimationPlayer x physics bodies. Parent fixture — spawns
# res://r92_child.gd per (case, backend) into res://r92a_<arm>_<bk>_<case>/
# and folds each merged log into a verbatim digest cell
# `<case>@<bk>{rc=..,m=<M-lines|..>,e=..,w=..,s=..}`.
#
# Every animation cell pins callback_mode_process =
# ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS (the scout's fixture-design law)
# EXCEPT `idlemode`, the contrast arm: idle-mode advance is scheduled by
# host idle frames, so its per-rep x is a distribution, not a constant.
# The arm runs REPS_IDLEN reps per backend (>= the mandated six), validates
# each rep against an invariant envelope — rc=0, s=0, e=0, w=0, one M0 and
# one M DONE, the `post` row with y=2.0000, z=0.0000, playing=true, and the
# backend constants lv=(0,-1.1376,0)/srv=(x,2,0) on gp+jolt vs
# lv=(0,0,0)/srv=nil on dummy — and pins only `ok=REPS` + `xband`, the
# median-x bucket. x itself never enters the marker.
#
# Laws pinned:
#   rbpos/rbfrozen: track transforms land as per-tick teleports on live and
#     frozen RigidBody3D, reaching body_get_state one tick behind the node;
#     gravity keeps integrating under the written transform on a live body.
#   animrb:  the same pinning on a body in free fall (no floor) — the E row
#     still reads the written transform; srv shows the integrated body.
#   animatable: AnimatableBody3D drives identically under
#     sync_to_physics=true/false on gp+jolt (with a ray hit + rider atop);
#     Dummy moves ONLY under sync_to_physics=false (pinned inversion) and
#     its ray misses. Rider settle splits 2.9973 (gp) vs 3.0000 (jolt/dummy).
#   reset:   an animation literally named RESET is an ordinary runtime
#     track — play("RESET") teleports to its key, does not snapshot.
#   manual:  PROCESS_MANUAL freezes the track until advance(0.5).
#   destroy: keyless TYPE_POSITION_3D track writes Vector3.ZERO and the
#     body rests inside the floor at the backend split 0.3920 (gp) /
#     0.0800 (jolt) / 0.0000 (dummy); `badkey` adds the wrong-typed
#     track_insert_key cell: both inserts return -1, the track keeps 0
#     keys, play still teleports to zero — with the two engine ERROR
#     witness lines pinned as e=2.
#   iforder: the tick's E read sees the previous push; the idle read sees
#     this tick's pushed value (per-tick +0.05 advance visible at idle).
#   badkey_insert (NEGATIVE, exit 2): the SAME wrong-typed inserts, but the
#     author checks the -1 returns and refuses to play — the transform is
#     never destroyed. Emits NEGATIVE REJECTED when every backend shows
#     refused + intact.

const BOUND_S := 10
const BATCH_BOUND_S := 15
const CHILD := "res://r92_child.gd"
const BACKENDS := [["gp", ""], ["jolt", "Jolt Physics"], ["dummy", "Dummy"]]
const REPS_IDLEN := 8
const ARM_CASES := {
	"rbpos": ["rbpos"],
	"rbfrozen": ["rbfrozen"],
	"animrb": ["animrb"],
	"animatable": ["animatable"],
	"reset": ["reset"],
	"manual": ["manual"],
	"destroy": ["empty_track", "badkey"],
	"iforder": ["iforder"],
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
	if arm == "idlemode":
		_run_idlen()
		return
	if arm == "badkey_insert":
		_run_negative()
		return
	if not ARM_CASES.has(arm):
		print("FAIL r92_animphys unknown arm=%s" % arm)
		quit(0)
		return
	for c in ARM_CASES[arm]:
		_run_arm(c)
	print("PASS r92_animphys %s %s" % [arm, " ".join(parts)])
	quit(0)


func _run_arm(case_name: String) -> void:
	var specs := []
	for b in BACKENDS:
		specs.append({
			"dirname": "r92a_%s_%s_%s" % [arm, b[0], case_name],
			"project_body": _project_body("r92a%s" % arm, b[1]),
			"case": case_name,
		})
	var out := _spawn_batch(specs)
	for i in BACKENDS.size():
		parts.append(_cell(case_name, BACKENDS[i][0], out[i]))


func _run_idlen() -> void:
	# Envelope arm: REPS_IDLEN independent child processes per backend; the
	# parent's marker pins the predicate aggregate, never a sampled value.
	var specs := []
	for b in BACKENDS:
		for r in REPS_IDLEN:
			specs.append({
				"dirname": "r92a_idlemode_%s_r%d" % [b[0], r],
				"project_body": _project_body("r92aidlemode", b[1]),
				"case": "idlemode",
			})
	var out := _spawn_batch(specs)
	for i in BACKENDS.size():
		var bk: String = BACKENDS[i][0]
		var oks := 0
		var xs := []
		for r in REPS_IDLEN:
			var res: Dictionary = out[i * REPS_IDLEN + r]
			var ev := _env_idlen(bk, res)
			if ev["ok"]:
				oks += 1
				xs.append(ev["x"])
		parts.append("idlemode@%s{reps=%d,ok=%d,xband=%s}" % [
				bk, REPS_IDLEN, oks, _xband(xs)])
	print("PASS r92_animphys idlemode %s" % " ".join(parts))
	quit(0)


func _env_idlen(bk: String, res: Dictionary) -> Dictionary:
	var r := {"ok": false, "x": -1.0}
	if res.has("err") or res["rc"] != 0 or res["e"] != 0 \
			or res["w"] != 0 or res["s"] != 0:
		return r
	var m0 := 0
	var done := 0
	var post := ""
	for l in res["m"]:
		if l.begins_with("M0 "):
			m0 += 1
		elif l.begins_with("M DONE"):
			done += 1
		elif " post " in l:
			post = l
	if m0 != 1 or done != 1 or post == "":
		return r
	var d := {}
	for f in post.split(" "):
		var kv := f.split("=", true, 1)
		if kv.size() == 2:
			d[kv[0]] = kv[1]
	var x := float(d.get("x", "-1"))
	var lv_ok: bool = d.get("lv") == ("(0.0000,-1.1376,0.0000)"
			if bk != "dummy" else "(0.0000,0.0000,0.0000)")
	var srv_ok: bool = d.get("srv") == (("(%s,2.0000,0.0000)" % d.get("x", "?"))
			if bk != "dummy" else "nil")
	if x >= 0.05 and x <= 1.2 and d.get("y") == "2.0000" \
			and d.get("z") == "0.0000" and d.get("playing") == "true" \
			and lv_ok and srv_ok:
		r["ok"] = true
		r["x"] = x
	return r


func _xband(xs: Array) -> String:
	if xs.is_empty():
		return "none"
	xs.sort()
	var med: float = xs[xs.size() / 2]
	if med < 0.05:
		return "lt0.05"
	if med < 0.2:
		return "0.05-0.2"
	if med < 0.5:
		return "0.2-0.5"
	if med < 1.2:
		return "0.5-1.2"
	return "hi"


func _run_negative() -> void:
	var specs := []
	for b in BACKENDS:
		specs.append({
			"dirname": "r92a_badkey_insert_%s" % b[0],
			"project_body": _project_body("r92abk", b[1]),
			"case": "badkey_reject",
		})
	var out := _spawn_batch(specs)
	var ons := []
	var held := true
	for i in BACKENDS.size():
		var res: Dictionary = out[i]
		var row := ""
		for l in res["m"]:
			if " reject " in l:
				row = l
		var ok: bool = not res.has("err") and res["rc"] == 0 and res["e"] == 2 \
				and res["s"] == 0 \
				and row == ("M badkey_reject reject r1=-1 r2=-1 keys=0 "
						+ "pos=(0.0000,2.0000,0.0000) destroyed=false")
		if ok:
			ons.append(BACKENDS[i][0])
		else:
			held = false
	if held:
		print("NEGATIVE REJECTED: r92_animphys badkey_insert ins=-1,-1 "
				+ "keys=0 destroyed=false on=%s" % ",".join(ons))
		quit(2)
	else:
		print("FAIL r92_animphys badkey_insert predicate broken ons=%s"
				% ",".join(ons))
		quit(0)


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
