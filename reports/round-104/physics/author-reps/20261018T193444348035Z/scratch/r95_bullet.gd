extends SceneTree
# r95 fixture — the Bullet/pybullet 3.2.7 physics lattice, authored from
# reports/round-95/r95-scout.md + r95-boundary.md. One arm per battery row:
#   godot --headless --path <scratch> --script res://r95_bullet.gd -- --arm=<name>
#
# The engine is not a Godot engine: the parent spawns /usr/bin/python3 children
# (`python3 res://r95_child.py <case> <res://r95vendor>`) that `import pybullet`
# from the vendored, sha-pinned extension module in res://r95vendor/
# (pybullet.cpython-314-x86_64-linux-gnu.so — the scout's venv build after
# `strip --strip-debug`; output-equivalence to the unstripped artifact is
# verified in the r95 authoring sweep).  The parent scans each child's merged
# log for `M`-prefix verdict lines (M0 header / M evidence / M DONE footer),
# `#` diagnostics (the child's captured fd-2 stream — pybullet build banner,
# b3Warning refusals, solver-switch notices, SHM pump thread logs — counted,
# never pinned verbatim), and every other non-empty line as `o` (must be 0 —
# any python traceback, stray print, or unexpected warning moves the digest),
# then prints ONE digest line per run.  `/usr/bin/python3` resolves by absolute
# path (this host's CPython 3.14.7); the version is pinned in each child's M0
# header and folded into the parent's PASS line.
#
# Authored ONLY from boundary-surviving claims, corrections folded:
#   * all hashes are build-scoped to the vendored btScalar=f64 build
#     (M0 carries api/dtBits/build stamp; the float rebuild is not authored);
#   * "no wall-clock path" is DIRECT-scoped: rt_inert/rt_idle/rt_paced pin
#     DIRECT inertness, while shm_step pins transport-neutrality at rt=0 and
#     shm_rtclass / neg_shm_rt pin the boundary's correction — SHM+rt=1
#     advances during a bare sleep and its stepped path is non-reproducible
#     (pinned as CLASSES fell/distinct/pinFree, never the moved amount);
#   * deterministicOverlappingPairs neutrality is 5-body-scoped (det_detpairs);
#     the 32-box pile pins the loud contrast (pile_lattice);
#   * bit-fixpoint is scene-dependent (freeze_scene 3000/3000 vs
#     freeze_ball freezes at step 80);
#   * equal-decimal friction products differ by 1 ulp (fr_bitexact);
#   * the >=0 write gate is a NaN filter (NaN dropped, +inf stored).
#
# Negative arms (exit 2): the child proves its live control, prints
# `NEGATIVE REJECTED: r95_bullet ...` and exits 2; the parent echoes that
# exact line and quits 2. Any other child outcome is a hard fail (exit 1).
#
# Arms (the `match` dispatch is the sole index):
#   det      13 children — canon h pin, rebuild/interleave/reset/restore
#            bit-determinism, creation-order sensitivity (corrected vs
#            cannon), iters/substeps lattices, scene-scoped detpairs,
#            1e-9 perturbation track, saturated non-fixpoint, neutral knobs
#   freeze   the scene-dependent fixpoint pair (scene never / ball step 80)
#   rt       DIRECT wall-clock inertness (stepped pin + idle + paced)
#   shm      SHM transport: rt=0 stepped == DIRECT pin; rt=1 class cells
#   sleep    solver-iterates-forever, velwrite/teleport instant, forced
#            sleep ignored on multibody path, EMPTY calibration (maximal)
#   sleep2   maximal-coord rest, disable-sleep equivalence, contact persist,
#            stale-manifold window
#   nan      dt lattice (neg/zero freeze; nan/inf poison widths) + field
#            poisons (gravity/pos/vel/quat, nan-vs-inf classes)
#   nan2     mass gate cells, unclamped damping, degenerate-shape/coincident/
#            teleport/ccd lattice
#   fric     9-digit combine lattice + 1-ulp bitexact + gate/mu0 mechanism
#   rest     restitution product lattice + bitexact hashes
#   knobs    boundary's neutral vs loud one-knob census
#   solver   constraintSolverType SI/PGS/DANTZIG + tick-rate lattice +
#            substep/halved-dt equivalence
#   pile     32-box 128-contact determinism stress lattice
#   misc     contact persist/order, mutation boundary, world defaults
#   neg_*    six negative controls (dt/order discrimination, shape/kwarg/
#            bad-id refusal classes, shm-rt non-reproducibility)

var arm := ""
const BOUND_S := 15

const ARM_CASES := {
	"det": ["det_base", "det_rebuild", "det_interleave", "det_order",
		"det_iters", "det_iters0", "det_substeps", "det_detpairs",
		"det_reset", "det_restore", "det_perturb", "det_saturated",
		"det_neutral"],
	"freeze": ["freeze_scene", "freeze_ball"],
	"rt": ["rt_inert", "rt_idle", "rt_paced"],
	"shm": ["shm_step", "shm_rtclass"],
	"sleep": ["sl_iters", "sl_velwrite", "sl_teleport", "sl_force_mb",
		"sl_force_max"],
	"sleep2": ["sl_rest_max", "sl_disable_pair", "sl_persist", "sl_stale"],
	"nan": ["nan_dt", "nan_fields"],
	"nan2": ["nan_mass", "nan_damp", "nan_shape"],
	"fric": ["fr_combine", "fr_bitexact", "fr_gate"],
	"rest": ["rest_all"],
	"knobs": ["kn_neutral", "kn_loud"],
	"solver": ["sv_backends", "sv_tps"],
	"pile": ["pile_lattice"],
	"misc": ["ms_contacts", "ms_mutate", "ms_defaults"],
}

# Negative arms: arm name == child case name. The child must exit 2 with
# exactly one `NEGATIVE REJECTED: r95_bullet ` line after proving its
# live control; the parent echoes that line verbatim and quits 2.
const NEGATIVE := [
	"neg_dt", "neg_order", "neg_radius", "neg_simtime", "neg_badid",
	"neg_shm_rt",
]

var _parts: Array = []
var _py_version := ""


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--arm="):
			arm = a.substr(6)
	call_deferred("_run")


func _run() -> void:
	_py_version = _py_version_probe()
	if NEGATIVE.has(arm):
		_run_negative(arm)
		return
	if not ARM_CASES.has(arm):
		_fail("unknown_arm")
		return
	for case in ARM_CASES[arm]:
		var d := _run_child(case)
		if d.has("err"):
			_fail("%s@py %s" % [case, d["err"]])
			return
		_emit(case, d)
	_finish()


func _py_version_probe() -> String:
	var out: Array = []
	OS.execute("/bin/sh", ["-c", "/usr/bin/python3 --version"], out, true)
	if out.is_empty():
		return "missing"
	return str(out[0]).strip_edges().replace("Python ", "")


func _fail(reason: String) -> void:
	print("FAIL r95_bullet %s reason=%s" % [arm, reason])
	quit(1)


func _finish() -> void:
	print("PASS r95_bullet %s py=%s %s" % [
		arm, _py_version, " ".join(_parts)])
	quit(0)


func _run_negative(case: String) -> void:
	var d := _run_child(case)
	if d.has("err"):
		_fail("%s@py %s" % [case, d["err"]])
		return
	var rejected: Array = []
	for line in d["m"]:
		if line.begins_with("NEGATIVE REJECTED: r95_bullet "):
			rejected.append(line)
	if d["rc"] == 2 and rejected.size() == 1 and d["o"] == 0:
		print(rejected[0])
		quit(2)
		return
	_fail("%s@py rc=%d rejected=%d o=%d (negative control did not reject cleanly)"
		% [case, d["rc"], rejected.size(), d["o"]])


func _run_child(case: String) -> Dictionary:
	var dirname := "r95ch_%s" % case
	var dir := ProjectSettings.globalize_path("res://" + dirname)
	if DirAccess.make_dir_recursive_absolute(dir) != OK:
		return {"err": "mkdir failed"}
	var script_path := ProjectSettings.globalize_path("res://r95_child.py")
	var vendor_path := ProjectSettings.globalize_path("res://r95vendor")
	var logpath := dir.path_join("child.log")
	DirAccess.remove_absolute(logpath)
	var cmd := ("timeout -s KILL %d /usr/bin/python3 \"%s\" %s \"%s\""
			+ " > \"%s\" 2>&1") % [
			BOUND_S, script_path, case, vendor_path, logpath]
	var code := OS.execute("/bin/sh", ["-c", cmd], [], false)
	var lf := FileAccess.open(logpath, FileAccess.READ)
	if lf == null:
		return {"err": "child log missing"}
	var mlines: Array = []
	var nother := 0
	var ndiag := 0
	while not lf.eof_reached():
		var line := lf.get_line()
		if line.begins_with("M0 ") or line.begins_with("M ") \
				or line.begins_with("NEGATIVE REJECTED:"):
			mlines.append(line)
		elif line.begins_with("#"):
			ndiag += 1
		elif line.strip_edges() != "":
			nother += 1
	lf.close()
	return {"rc": code, "m": mlines, "o": nother, "d": ndiag}


func _emit(case: String, d: Dictionary) -> void:
	_parts.append("%s{rc=%d,m=%s,o=%d,d=%d}" % [
			case, d["rc"], "|".join(d["m"]), d["o"], d["d"]])
