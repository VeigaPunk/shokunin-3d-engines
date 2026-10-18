extends SceneTree
# r94 fixture — the cannon-es 0.20.0 / three 0.186.1 "cannon.js/PyBullet-
# style" physics lattice, authored from reports/round-94/r94-scout.md +
# r94-boundary.md. One arm per battery row:
#   godot --headless --path <scratch> --script res://r94_cannon.gd -- --arm=<name>
#
# The engines are not Godot engines; the parent spawns node children
# (`node res://r94_child.mjs <case>`) running the seed-digest-pinned
# vendored dist bundles in res://r94vendor/ (cannon-es.js +
# three.module.js/three.core.js, byte-identical to the scout's npm pins).
# The parent scans each child's merged log for `M`-prefix verdict lines
# (M0 header / M evidence / M DONE footer), `#` diagnostics (measured,
# never pinned), and every other non-empty line as `o` (must be 0 — any
# node warning, stack frame, or stray output moves the digest), then
# prints ONE digest line per run. `node` resolves via the inherited PATH
# (this host's fnm node v24.21.0); the version is pinned in the PASS line.
#
# Authored ONLY from claims that survived the boundary: fixed-step hashes
# are full physics+render witnesses (h); wall-clock modes pin CLASSES
# never counts (fixedStep ticks<calls, not a count); NaN states hash
# canonically (raw payload bits are flag-set dependent); add-order
# neutrality is pinned ONLY for the symmetric canon scene — asym2/stack3/
# tri pin their own forward/reverse hashes; the "15*mu*g" deceleration is
# replaced by the measured mass-inert/mu- and v0-dependent grid;
# GridBroadphase is a refusal class (negative arm neg_grid, live control
# at nx=1). Non-authored boundary measurements: accumulator substep
# spread 1..222 on this host, grid nx=10 hang, --no-opt NaN-payload flip.
#
# Negative arms (exit 2): the child proves its live control, prints
# `NEGATIVE REJECTED: r94_cannon ...` and exits 2; the parent echoes that
# exact line and quits 2. Any other child outcome is a hard fail (exit 1).
#
# Arms (the `match` dispatch is the sole index):
#   det       13 children — canon h pin, rebuild/interleave determinism,
#             canon-scene order neutrality + solver-eq signature,
#             naive-vs-SAP broadphase (axis-invariant), iterations/
#             tolerance variants, saturated-step invariance, 1e-9 ULP fork
#   det2      iteration histograms, perturbation growth track, ordered
#             contact-pair witness rows (forward/reverse)
#   varstep   accumulator mode: elapsed=dt physics equality but hash
#             inequality (interp buffers), uneven schedule, maxSubSteps,
#             interpolation fields, sleep-phase drift
#   bailout   the accumulator wall-budget edge (dt=1e-5 -> stepnumber=1)
#   nan       the 22-row boundary NaN lattice, canonical-hashed
#   sync      9 children — mesh-copy lattice incl. nested/scaled parent,
#             zero-quaternion identity, interp-sync trap, matrixAutoUpdate
#   material  14-mode material/contact-material lattice + friction sweep
#   friction  the corrected deceleration grid (mass-inert; NOT 15*mug)
#   parity    rest-contact/shape-write/shared-shape parity rows
#   parity2   sleep thresholds/wake/contact-rest/multishape order
#   modes     the corrected step-mode laws: internalStep clock dependence
#             (time=0 vs time+=dt), dt=0 NaN-freeze, negative dt, two-arg
#             default, elapsed<0 rewind, half-elapsed substeps, fixedStep
#             wall-clock class
#   order     the corrected add-order law: canon neutral vs asym2/stack3/
#             tri order-dependent hashes
#   backends  broadphase variants + solver backends (SplitSolver distinct)
#   neg_*     six negative controls (dt/gravity/steps/elapsed/wxyz/grid)

var arm := ""
const BOUND_S := 15

const ARM_CASES := {
	"det": ["det_base", "det_rebuild", "det_interleave", "det_order_swap",
		"det_order_probe", "det_sap", "det_iters1", "det_iters5",
		"det_iters20", "det_tol0", "det_tol1e3", "det_steps_saturated",
		"det_ulp"],
	"det2": ["det_iters_hist", "det_perturb_track", "det_contacts_fwd",
		"det_contacts_rev"],
	"varstep": ["var_fixed", "var_exact", "var_uneven", "var_maxsub",
		"var_interp", "var_sleep_phase"],
	"bailout": ["var_bailout"],
	"nan": ["nan_all"],
	"sync": ["sync_full", "sync_pos_only", "sync_quat_only", "sync_nested",
		"sync_scale_parent", "sync_zero_quat", "sync_interp",
		"sync_matrix_auto", "sync_lag"],
	"material": ["mat_all", "mat_fric_sweep"],
	"friction": ["fric_corrected"],
	"parity": ["par_defaults", "par_shrink", "par_grow", "par_shared"],
	"parity2": ["par_sleep_nat", "par_sleep_wake", "par_contact_rest",
		"par_multishape", "par_sleep_thresh"],
	"modes": ["mod_internal", "mod_internal_clocked", "mod_dt_zero_acc",
		"mod_dt_neg_acc", "mod_two_arg", "mod_elapsed_half",
		"mod_elapsed_neg", "mod_fixedstep"],
	"order": ["ord_canon", "ord_asym2", "ord_stack3", "ord_tri"],
	"backends": ["be_broadphase", "be_solver"],
}

# Negative arms: arm name == child case name. The child must exit 2 with
# exactly one `NEGATIVE REJECTED: r94_cannon ` line after proving its
# live control; the parent echoes that line verbatim and quits 2.
const NEGATIVE := [
	"neg_dt", "neg_gravity", "neg_steps_early", "neg_elapsed", "neg_wxyz",
	"neg_grid",
]

var _parts: Array = []
var _node_version := ""


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--arm="):
			arm = a.substr(6)
	call_deferred("_run")


func _run() -> void:
	_node_version = _node_version_probe()
	if NEGATIVE.has(arm):
		_run_negative(arm)
		return
	if not ARM_CASES.has(arm):
		_fail("unknown_arm")
		return
	for case in ARM_CASES[arm]:
		var d := _run_child(case)
		if d.has("err"):
			_fail("%s@node %s" % [case, d["err"]])
			return
		_emit(case, d)
	_finish()


func _node_version_probe() -> String:
	var out: Array = []
	OS.execute("/bin/sh", ["-c", "node --version"], out, true)
	if out.is_empty():
		return "missing"
	return str(out[0]).strip_edges()


func _fail(reason: String) -> void:
	print("FAIL r94_cannon %s reason=%s" % [arm, reason])
	quit(1)


func _finish() -> void:
	print("PASS r94_cannon %s node=%s %s" % [
		arm, _node_version, " ".join(_parts)])
	quit(0)


func _run_negative(case: String) -> void:
	var d := _run_child(case)
	if d.has("err"):
		_fail("%s@node %s" % [case, d["err"]])
		return
	var rejected: Array = []
	for line in d["m"]:
		if line.begins_with("NEGATIVE REJECTED: r94_cannon "):
			rejected.append(line)
	if d["rc"] == 2 and rejected.size() == 1 and d["o"] == 0:
		print(rejected[0])
		quit(2)
		return
	_fail("%s@node rc=%d rejected=%d o=%d (negative control did not reject cleanly)"
		% [case, d["rc"], rejected.size(), d["o"]])


func _run_child(case: String) -> Dictionary:
	var dirname := "r94ch_%s" % case
	var dir := ProjectSettings.globalize_path("res://" + dirname)
	if DirAccess.make_dir_recursive_absolute(dir) != OK:
		return {"err": "mkdir failed"}
	var script_path := ProjectSettings.globalize_path("res://r94_child.mjs")
	var logpath := dir.path_join("child.log")
	DirAccess.remove_absolute(logpath)
	var cmd := ("timeout -s KILL %d node \"%s\" %s"
			+ " > \"%s\" 2>&1") % [
			BOUND_S, script_path, case, logpath]
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
