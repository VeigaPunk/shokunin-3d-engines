extends SceneTree
# r93 Area3D signal-in-tick ordering surface — parent fixture. Spawns
# res://r93_child.gd per (case, backend) into res://r93t_<bk>_<case>/ under
# --fixed-fps 60 and folds each merged log into a digest cell
#   <case>@<bk>{rc=..,m=<M-lines|..>,e=..[,et=..],w=..,s=..}
# `et` carries the distinct ERROR: first-lines in occurrence order
# ('~'-joined) and is emitted only when e>0 — the expected-error floor
# gate for r93 rows: a pinned refusal must actually fire, with the
# pinned text, and only that text.
#
# Laws landed (r93-scout lattice folded through r93-boundary falsifiers):
#   edges    detection-driven Area3D signals emit inside the detecting
#            step — after the body's _integrate_forces row, before that
#            tick's _physics_process row — for falling entry (pf=21),
#            spawn-overlap entry (pf=2), and teleported entry (pf=25);
#            E reads the overlap already updated (stale before, fresh
#            after).
#   writes   the same in-step flush holds when the overlap change is
#            written inside _integrate_forces (tif) and when the write is
#            refused mid-dispatch nothing flushes (monsig is in dispatch
#            arm); a monitoring=false write flushes exits inside the
#            write itself with mon=false observed by the handler
#            (monoff/monif); a teleport inside a signal handler does not
#            re-enter the dispatch — body_shape_entered still fires and
#            the exit lands next tick (tsig).
#   exits    queue_free exits are a frame-end flush: they land post_e
#            with the stale overlap list (ovn=ball) plus a next-tick
#            null-body shape dup; server free_rid exits land next tick
#            no_if. Neither is an in-step event.
#   dispatch monsig pins the in-dispatch monitoring write refusal:
#            e=1 with the exact engine line `Function blocked during
#            in/out signal. Use set_deferred("monitoring", true/false).`,
#            readback stays true, no flush; moncycle pins the same-tick
#            off->on split (GP re-detects pf=25, Jolt never in-window);
#            monoff0 pins the cross-tick re-enable that re-detects on
#            BOTH backends at pf=31 — the refusal is dispatch-bound, not
#            a monitoring freeze.
#   splits   telefr pins the frozen-body teleport split (GP nsig=0, Jolt
#            detects in-step at pf=25 no_if); monitoff pins the
#            monitorable write split (GP keeps the pair silently through
#            the off window, Jolt drops area signals at pf=21 and
#            re-detects at pf=27).
#   multi    same-tick two-body overlap: only order-free pins — the
#            canonical per-body sig set, grow=1,2 / shrink=1,0 counts,
#            and the per-backend entry_eq_exit boolean (GP=0, Jolt=1).
#            Per-body emission order is '#'-line diagnostic only: Jolt
#            flips it ~12% under load (r93-boundary §4). areasig pins
#            the paired-area exit ordering at B_AWAY; bodysig pins the
#            per-shape entry split (GP bsi=0,1 / Jolt bsi=1,0) and the
#            body_exited-between-shape-exits exit ordering.
#   prio     priority gates the space-override force split (B@1 wins
#            pre-swap fall ~-0.08/tick, A@5 wins post-swap) but NOT the
#            signal surface — both areas report body_entered at pf=2.
#
# Every child runs --fixed-fps 60 so each physics tick gets exactly one
# idle frame: F-row multiplicity and the freeq post-E window are
# deterministic, and the pinned e= counts (monitoring-off reads error
# per call) are scheduler-free.

const BOUND_S := 10
const BATCH_BOUND_S := 20
const CHILD := "res://r93_child.gd"
const BACKENDS := [["gp", ""], ["jolt", "Jolt Physics"], ["dummy", "Dummy"]]
const ARM_CASES := {
	"edges": ["enter", "enter0", "tele"],
	"writes": ["tif", "tsig", "monoff", "monif"],
	"exits": ["freeq", "freerid"],
	"dispatch": ["monsig", "moncycle", "monoff0"],
	"splits": ["telefr", "monitoff"],
	"multi": ["multi", "areasig", "bodysig"],
	"prio": ["prio"],
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
		print("FAIL r93_areasig unknown arm=%s" % arm)
		quit(0)
		return
	for c in ARM_CASES[arm]:
		_run_arm(c)
	print("PASS r93_areasig %s %s" % [arm, " ".join(parts)])
	quit(0)


func _run_arm(case_name: String) -> void:
	var specs := []
	for b in BACKENDS:
		specs.append({
			"dirname": "r93t_%s_%s" % [b[0], case_name],
			"project_body": _project_body("r93t%s" % arm, b[1]),
			"case": case_name,
		})
	var out := _spawn_batch(specs)
	for i in BACKENDS.size():
		parts.append(_cell(case_name, BACKENDS[i][0], out[i]))


func _cell(case_name: String, bk: String, res: Dictionary) -> String:
	if res.has("err"):
		return "%s@%s{err=%s}" % [case_name, bk, res["err"]]
	var et := ""
	if res["e"] > 0:
		et = ",et=%s" % res["et"]
	return "%s@%s{rc=%d,m=%s,e=%d%s,w=%d,s=%d}" % [case_name, bk,
			res["rc"], "|".join(res["m"]), res["e"], et, res["w"], res["s"]]


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
	var cmd := ("timeout -s KILL %d \"%s\" --headless --fixed-fps 60"
			+ " --path \"%s\" --script \"%s\" -- %s > \"%s\" 2>&1") % [
			BOUND_S, OS.get_executable_path(), dir, script, case_name, logpath]
	DirAccess.remove_absolute(logpath)
	return {"dir": dir, "logpath": logpath, "cmd": cmd}


func _scan(prep: Dictionary, code: int) -> Dictionary:
	var res := {"rc": code, "m": [], "e": 0, "w": 0, "s": 0, "et": []}
	var lf := FileAccess.open(prep["logpath"], FileAccess.READ)
	if lf == null:
		return {"err": "child log missing"}
	while not lf.eof_reached():
		var line := lf.get_line()
		if line.begins_with("M0 ") or line.begins_with("M "):
			res["m"].append(line)
		elif line.begins_with("ERROR:"):
			res["e"] += 1
			var txt := line.strip_edges().trim_prefix("ERROR: ")
			if txt not in res["et"]:
				res["et"].append(txt)
		elif line.begins_with("WARNING:"):
			# Jolt's JobSystemThreadPool capacity notice fires
			# intermittently under --fixed-fps unthrottled stepping
			# (~25% of serial child runs; never without the flag).
			# It is engine-internal load noise, not physics semantics,
			# so it is excluded from the pinned w= field.
			if not "job system exceeded the maximum number of jobs" in line:
				res["w"] += 1
		elif "SCRIPT ERROR" in line or "Parse Error" in line \
				or ("ObjectDB" in line and "leaked" in line) \
				or "handle_crash" in line:
			res["s"] += 1
	lf.close()
	res["et"] = "~".join(res["et"])
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
