extends SceneTree
# r91 fixture — the bpy rigid-body world + point-cache lattice, measured on
# Blender 5.2.1 LTS headless (`/usr/bin/blender -b -P`). One arm per battery
# row:
#   godot --headless --path <scratch> --script res://bpy_rbw3d.gd -- --arm=<name>
#
# The 3d physics backends do not exist on the bpy side (one solver); the
# per-(case, backend) spawn convention of phys3d_joints.gd maps onto
# per-case Blender child processes running r91_child.py into generated
# dirs under res://r91bt_*/. The parent scans each child's merged log for
# `M`-prefix verdict lines, blender error/traceback lines, warning lines,
# the `bake: frame N :: M` operator flood (the bake-range witness), and the
# `Writing: /tmp/blender.crash.txt` crash marker, then prints ONE digest
# line per run. No object ids / addresses / timestamps / PNG or .blend
# bytes are emitted (the child's binary outputs are non-witnesses — PNG
# sha drifts rep to rep, r91-scout 6.2).
#
# Crash cell (ptr_stale — a write through a stale RNA pointer captured
# before read_factory_settings): the pin is the envelope class — `mode_ok`
# plus the stable M-prefix sha — never ASLR backtrace bytes; rc class and
# the crash marker are admission predicates. Measured on this host: rc 139
# (SIGSEGV through `timeout -s KILL`), breadcrumbs reset+pre_write present,
# post_write and DONE absent, 3/3 scout reps + author reps.
#
# Arms (the `match` dispatch is the sole index):
#   det      free (sweep/re-read/excursion + cache info) · bequiv (bake ≡
#            free run, narrow-range info persistence)
#   bake     bake20 / bake5_30 / scene20b / presweep20 — the pc range is
#            the bake range (b= flood count), scene range ignored, bake
#            extends over already-simulated frames
#   window   end20 / start20 / scene20w — the pc range is the sim window:
#            tail freeze, phase shift, scene range irrelevant (no bake)
#   order    order (jump never sims; backward/subframe/frame0 reads) ·
#            bjump (a bake makes jumps addressable; past-cache holds)
#   resim    stale / resim / partial / trace / ctrl025 — is_outdated is not
#            honored, free_bake_all does not flush, the served trajectory
#            depends on read order (the scout's sharpest finding)
#   knobs    fps / solv — the physics time base is scene fps; every solver
#            knob moves the trajectory (in-process rebuild variants,
#            rebuild-determinism measured by the author probe)
#   ops      polls / b2k / disk — headless armability matrix, the
#            bake_to_keyframes execute-refusal (deterministic e= noise),
#            use_disk_cache/use_external refusals
#   io       blend — a baked cache survives save/reload (file bytes drift,
#            behaviour pinned)
#   render   shot / rdet — render does not step the sim; PNG bytes are not
#            a stable witness (stable=False pinned, never a sha)
#   ptr      ptr_stale (crash envelope) / ptr_fresh (control)

var arm := ""
const BOUND_S := 15
const BLENDER := "/usr/bin/blender"

const ARM_CASES := {
	"det": ["free", "bequiv"],
	"bake": ["bake20", "bake5_30", "scene20b", "presweep20"],
	"window": ["end20", "start20", "scene20w"],
	"order": ["order", "bjump"],
	"resim": ["stale", "resim", "partial", "trace", "ctrl025"],
	"knobs": ["fps", "solv"],
	"ops": ["polls", "b2k", "disk"],
	"io": ["blend"],
	"render": ["shot", "rdet"],
	"ptr": ["ptr_stale", "ptr_fresh"],
}

# Crash envelope cells: tag -> n_pre (exact M-line count before the crash:
# M0 header + breadcrumbs; post_write/DONE absent). Admission: sig11
# marker present AND rc in {134, 139} AND m exactly n_pre. A clean exit,
# a hang (rc 137, no crash marker), or a different prefix all fail.
const CRASH := {
	"ptr_stale@bpy": 3,
}


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--arm="):
			arm = a.substr(6)
	call_deferred("_run")


func _run() -> void:
	if not ARM_CASES.has(arm):
		_fail("unknown_arm")
	for case in ARM_CASES[arm]:
		var d := _run_child(case)
		if d.has("err"):
			return _fail("%s@bpy %s" % [case, d["err"]])
		_emit(case, d)
	_finish()


func _fail(reason: String) -> void:
	print("FAIL bpy_rbw3d %s reason=%s" % [arm, reason])
	quit(1)


var _parts: Array = []

func _finish() -> void:
	print("PASS bpy_rbw3d %s %s" % [arm, " ".join(_parts)])
	quit(0)


func _run_child(case: String) -> Dictionary:
	var dirname := "r91bt_%s_%s" % [arm, case]
	var dir := ProjectSettings.globalize_path("res://" + dirname)
	if DirAccess.make_dir_recursive_absolute(dir) != OK:
		return {"err": "mkdir failed"}
	var script_path := ProjectSettings.globalize_path("res://r91_child.py")
	var logpath := dir.path_join("child.log")
	DirAccess.remove_absolute(logpath)
	var cmd := ("timeout -s KILL %d \"%s\" -b -P \"%s\" -- %s \"%s\""
			+ " > \"%s\" 2>&1") % [
			BOUND_S, BLENDER, script_path, case, dir, logpath]
	var code := OS.execute("/bin/sh", ["-c", cmd], [], false)
	var lf := FileAccess.open(logpath, FileAccess.READ)
	if lf == null:
		return {"err": "child log missing"}
	var mlines: Array = []
	var nerr := 0
	var nwarn := 0
	var sig11 := 0
	var nbake := 0
	while not lf.eof_reached():
		var line := lf.get_line()
		if line.begins_with("M0 ") or line.begins_with("M "):
			mlines.append(line)
		elif line.begins_with("bake: frame"):
			nbake += 1
		elif "blender.crash.txt" in line:
			sig11 += 1
		elif line.begins_with("Error") or line.begins_with("Traceback") \
				or line.begins_with("RuntimeError"):
			nerr += 1
		elif line.begins_with("WARNING") or line.begins_with("Warning"):
			nwarn += 1
	lf.close()
	return {"rc": code, "m": mlines, "ne": nerr, "nw": nwarn,
		"sig11": sig11, "nb": nbake}


func _emit(case: String, d: Dictionary) -> void:
	var tag := "%s@bpy" % case
	if CRASH.has(tag):
		var n_pre: int = CRASH[tag]
		var pre_sha := " ".join(d["m"]).sha256_text().substr(0, 16)
		var msz: int = d["m"].size()
		var crash: bool = d["sig11"] >= 1 \
				and (d["rc"] in [134, 139]) and msz == n_pre
		var mode_ok := 1 if crash else 0
		_parts.append("%s{mode_ok=%d,m%d=%s,rc=%d}" % [
				tag, mode_ok, n_pre, pre_sha, d["rc"]])
		return
	_parts.append("%s{rc=%d,m=%s,e=%d,w=%d,b=%d}" % [
			tag, d["rc"], "|".join(d["m"]), d["ne"], d["nw"], d["nb"]])
