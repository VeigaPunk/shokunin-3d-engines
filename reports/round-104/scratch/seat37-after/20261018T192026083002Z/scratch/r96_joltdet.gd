extends SceneTree
# r96 Jolt fixed-fps / determinism lattice — parent fixture.
#
# Children are byte-identical copies of the r96 scout probes, run under their
# ORIGINAL res:// names (iters.gd, pen.gd, ...) so that a child receipt
# reproduces the scout's receipt byte-for-byte; the parent copies the source
# out of res://r96_probe_<name>.gd into a per-cell project dir.
#
# Digest cell:
#   <name>{rc=0,sha=<16 hex>,<field>=<value>,...}
# `sha` is sha256-16 over the child's NORMALIZED contract stream. Dropped
# before hashing (never pinned, censused in '#' diagnostics):
#   - the "Godot Engine v..." banner and empty lines;
#   - the exact 2-line Jolt job-system warning, allowlisted by text and
#     tolerated at ANY position (r96-boundary §3): a --fixed-fps artifact of
#     the Jolt job system, not physics, appearing 0/1x per receipt;
#   - the probe's own teardown notices ("ERROR: N RID allocations ... were
#     leaked at exit.") and kin.gd's benign "!is_inside_tree()" block.
# Anything else that lands on stderr/stdout (a SCRIPT ERROR, an unexpected
# ERROR:, a new warning) fails the arm: the cell is not printed as PASS.
#
# Laws landed (r96-scout lattice folded through r96-boundary falsifiers):
#   joint    solver_iterations / velocity_steps / position_steps are distinct
#            duties: GP's single knob is inert for a single joint; Jolt's
#            position_steps owns joint positional recovery (p0 never
#            recovers) while velocity_steps owns loaded-scene convergence.
#            The node-body joint trap: a joint built in _initialize() on node
#            bodies is silently dropped on GP (space_a=RID(0)) and binds on
#            Jolt.
#   contact  depenetration constants (GP setpoint = contact_max_allowed_
#            penetration, Jolt band = penetration_slop), the constant
#            support impulse m*g*dt, the one-tick contact break (GP
#            re-converges, Jolt rests 0.00272 lower forever) and the damping
#            law ratio = 1 - d*dt (clamped at d*dt >= 1, COMBINE/REPLACE
#            semantics).
#   restkin  the restitution combine rule is clamp(A+B,0,1) — NOT max — on
#            both backends; Jolt's bounce_velocity_threshold=1.0 kills the
#            low-speed bounce; the kinematic/static split is in contact
#            REPORTING (Jolt reports none without
#            generate_all_kinematic_contacts) and StaticBody3D.constant_
#            linear_velocity is a GP-only idiom.
#   tps      the dt laws at 30/60/120 tps: ratio 1-d*dt with the actual dt,
#            the clamp, the m*g*dt impulse, GP's 1/dt velocity spike with a
#            dt-invariant 0.7/tick gap ratio, Jolt's 0.64/tick gap ratio
#            with lv==0, the tps-invariant combine rule, the GP setpoint
#            being dt-conditional (0.010004 at 30 tps, 0.010001 at 120) and
#            sleep being wall-clock, not tick-counted (64/126/never GP,
#            73/144/never Jolt).
#   tscale   --time-scale is a stealth tick-rate knob: --time-scale 0.5 at 60
#            tps IS the 120-tps project and --time-scale 2.0 IS the 30-tps
#            project, byte-identical (normalized), for a joint-position
#            witness and a dt-scaled damping witness, on both backends.
#   ffps     the Jolt job-system warning is an allowlisted, optional,
#            position-variable expected class: every --fixed-fps receipt is
#            byte-identical to its no-flag twin after dropping it, and GP is
#            unaffected (no warning, raw byte-identical). The scanner itself
#            is gated: the exact 2-line text is dropped at any position, and
#            a near-miss (first line without its "at:" line) is NOT dropped.
#   dummy    the Dummy backend is a null physics world (body_get_state
#            returns a zero transform, no depenetration, no fall, no damping,
#            no kinematic contact reporting) and damp.gd's sleep1 probe HANGS
#            there (bounded: rc=137, no DSUM) — the vacuity preconditions for
#            any Dummy sweep. GP/Jolt live controls run in the same cells.
#   thread   run_on_separate_thread=true is receipt-identical to the
#            single-threaded baseline on both backends.
#   knobs    the physics/ key surface is backend-independent: the same 67
#            key NAMES on GP, Jolt and Dummy (only the values differ).
#   nc       the nocache contact-identity cell, re-run as a small fixed-fps
#            batch, is rep-stable AND reads the real contact-0 impulse (the
#            boundary's all-zero read is batch-shape-conditional, unpinned).
#   solver   the iteration-knob bakes (solver_iterations / velocity_steps /
#            position_steps).
#   mech     the one-knob mechanism bakes (contact_max_allowed_penetration,
#            default_contact_bias, penetration_slop, baumgarte, speculative
#            contact distance, contact_max_separation, bounce_velocity_
#            threshold).

const CHUNK := 8
const BOUND_S := 14
const HANG_BOUND_S := 2
const HANG_CAP_BYTES := 131072

const JOLT := "3d/physics_engine=\"Jolt Physics\"\n"
const DUMMY := "3d/physics_engine=\"Dummy\"\n"
const THR := "3d/run_on_separate_thread=true\n"

const WARN1 := "WARNING: Jolt Physics job system exceeded the maximum number of jobs. This should not happen. Please report this. Waiting for jobs to become available..."
const WARN2 := "     at: CreateJob (modules/jolt_physics/spaces/jolt_job_system.cpp:123)"

const SUM_PREFIX := {
	"iters": "ITSUM", "pen": "PSUM", "warm": "WSUM", "damp": "DSUM",
	"rest": "RSUM", "kin": "KSUM", "srvjoint": "J0 ",
	"settings": "ST total_props",
}

# arm -> cell specs. n=name p=project pr=probe c=case f=SUM fields
# x={"pre":..., "f":[...]} extra line fields
const ARMS := {
	"joint": [
		{"n": "it_pin@gp", "p": "gp60", "pr": "iters", "c": "pin",
			"f": ["max_gap", "last_lv"]},
		{"n": "it_pin@jolt", "p": "jolt60", "pr": "iters", "c": "pin",
			"f": ["max_gap", "last_lv"]},
		{"n": "it_chain@gp", "p": "gp60", "pr": "iters", "c": "chain",
			"f": ["last_sum", "max_sum"]},
		{"n": "it_chain@jolt", "p": "jolt60", "pr": "iters", "c": "chain",
			"f": ["last_sum", "max_sum"]},
		{"n": "it_stack@gp", "p": "gp60", "pr": "iters", "c": "stack",
			"f": ["last_pen0", "last_xz4", "last_y4"]},
		{"n": "it_stack@jolt", "p": "jolt60", "pr": "iters", "c": "stack",
			"f": ["last_pen0", "last_xz4", "last_y4"]},
		{"n": "it_hinge@gp", "p": "gp60", "pr": "iters", "c": "hinge",
			"f": ["max_over", "last_over"]},
		{"n": "it_hinge@jolt", "p": "jolt60", "pr": "iters", "c": "hinge",
			"f": ["max_over", "last_over"]},
		{"n": "sj_node_init@gp", "p": "gp60", "pr": "srvjoint", "c": "node_init",
			"f": ["space_a", "space_b"]},
		{"n": "sj_node_init@jolt", "p": "jolt60", "pr": "srvjoint",
			"c": "node_init", "f": ["space_a", "space_b"]},
		{"n": "sj_srv@gp", "p": "gp60", "pr": "srvjoint", "c": "srv",
			"f": ["space_a", "space_b"]},
		{"n": "sj_srv@jolt", "p": "jolt60", "pr": "srvjoint", "c": "srv",
			"f": ["space_a", "space_b"]},
	],
	"contact": [
		{"n": "pen_overlap@gp", "p": "gp60", "pr": "pen", "c": "overlap",
			"f": ["sep_end", "lv1_end"]},
		{"n": "pen_overlap@jolt", "p": "jolt60", "pr": "pen", "c": "overlap",
			"f": ["sep_end", "lv1_end"]},
		{"n": "pen_approach@gp", "p": "gp60", "pr": "pen", "c": "approach",
			"f": ["first_mod_tick", "first_mod_gap", "y_end"]},
		{"n": "pen_approach@jolt", "p": "jolt60", "pr": "pen", "c": "approach",
			"f": ["first_mod_tick", "first_mod_gap", "y_end"]},
		{"n": "warm_rest@gp", "p": "gp60", "pr": "warm", "c": "rest",
			"f": ["y_end"], "x": {"pre": "W t=60 ", "f": ["imp", "lv"]}},
		{"n": "warm_rest@jolt", "p": "jolt60", "pr": "warm", "c": "rest",
			"f": ["y_end"], "x": {"pre": "W t=60 ", "f": ["imp", "lv"]}},
		{"n": "warm_break@gp", "p": "gp60", "pr": "warm", "c": "break",
			"f": ["y_end"]},
		{"n": "warm_break@jolt", "p": "jolt60", "pr": "warm", "c": "break",
			"f": ["y_end"]},
		{"n": "warm_stack@gp", "p": "gp60", "pr": "warm", "c": "stack",
			"f": [], "x": {"pre": "W t=60 ", "f": ["cc", "y0", "vmax"]}},
		{"n": "warm_stack@jolt", "p": "jolt60", "pr": "warm", "c": "stack",
			"pose": true, "f": [],
			"x": {"pre": "W t=60 ", "f": ["cc", "y0", "vmax"]}},
		{"n": "damp_lin10@gp", "p": "gp60", "pr": "damp", "c": "lin10",
			"f": ["lv_end"], "x": {"pre": "D t=2 ", "f": ["ratio"]}},
		{"n": "damp_lin10@jolt", "p": "jolt60", "pr": "damp", "c": "lin10",
			"f": ["lv_end"], "x": {"pre": "D t=2 ", "f": ["ratio"]}},
		{"n": "damp_sleep1@gp", "p": "gp60", "pr": "damp", "c": "sleep1",
			"f": ["slept_at", "lv_end"]},
		{"n": "damp_sleep1@jolt", "p": "jolt60", "pr": "damp", "c": "sleep1",
			"f": ["slept_at", "lv_end"]},
		{"n": "damp_lin0repl@gp", "p": "gp60", "pr": "damp", "c": "lin0repl",
			"f": ["lv_end"]},
		{"n": "damp_lin0comb@gp", "p": "gp60", "pr": "damp", "c": "lin0comb",
			"f": ["lv_end"]},
	],
	"restkin": [
		{"n": "rest_max@gp", "p": "gp60", "pr": "rest", "c": "max",
			"f": ["e_vel", "apex"]},
		{"n": "rest_sum@gp", "p": "gp60", "pr": "rest", "c": "sum",
			"f": ["e_vel", "v_out"]},
		{"n": "rest_mid@gp", "p": "gp60", "pr": "rest", "c": "mid",
			"f": ["e_vel", "v_out"]},
		{"n": "rest_low@gp", "p": "gp60", "pr": "rest", "c": "low",
			"f": ["e_vel", "v_out"]},
		{"n": "rest_sum@jolt", "p": "jolt60", "pr": "rest", "c": "sum",
			"f": ["e_vel", "apex"]},
		{"n": "rest_mid@jolt", "p": "jolt60", "pr": "rest", "c": "mid",
			"f": ["e_vel", "apex"]},
		{"n": "rest_low@jolt", "p": "jolt60", "pr": "rest", "c": "low",
			"f": ["e_vel", "v_out"]},
		{"n": "rest_pairlow@jolt", "p": "jolt60", "pr": "rest", "c": "pairlow",
			"f": ["v1_out", "v2_out"]},
		{"n": "kin_kcontact@gp", "p": "gp60", "pr": "kin", "c": "kcontact",
			"f": ["cc_end", "kin_first_cc"]},
		{"n": "kin_kcontact@jolt", "p": "jolt60", "pr": "kin", "c": "kcontact",
			"f": ["cc_end", "kin_first_cc"]},
		{"n": "kin_kcontact@jolt_kinct", "p": "jolt_kinct", "pr": "kin",
			"c": "kcontact", "f": ["cc_end", "kin_first_cc"]},
		{"n": "kin_carrystatic@gp", "p": "gp60", "pr": "kin", "c": "carrystatic",
			"f": ["y_end", "lv_end"]},
		{"n": "kin_carrystatic@jolt", "p": "jolt60", "pr": "kin",
			"c": "carrystatic", "f": ["y_end", "lv_end"]},
		{"n": "kin_carrykin@gp", "p": "gp60", "pr": "kin", "c": "carrykin",
			"f": ["y_end", "lv_end"]},
		{"n": "kin_carrykin@jolt", "p": "jolt60", "pr": "kin", "c": "carrykin",
			"f": ["y_end", "lv_end"]},
	],
	"tps": [
		{"n": "lin10@gp30", "p": "gp30", "pr": "damp", "c": "lin10",
			"f": ["lv_end"], "x": {"pre": "D t=2 ", "f": ["ratio"]}},
		{"n": "lin10@gp120", "p": "gp120", "pr": "damp", "c": "lin10",
			"f": ["lv_end"], "x": {"pre": "D t=2 ", "f": ["ratio"]}},
		{"n": "lin10@jolt30", "p": "jolt30", "pr": "damp", "c": "lin10",
			"f": ["lv_end"], "x": {"pre": "D t=2 ", "f": ["ratio"]}},
		{"n": "lin10@jolt120", "p": "jolt120", "pr": "damp", "c": "lin10",
			"f": ["lv_end"], "x": {"pre": "D t=2 ", "f": ["ratio"]}},
		{"n": "lin100@gp30", "p": "gp30", "pr": "damp", "c": "lin100",
			"f": ["lv_end"], "x": {"pre": "D t=2 ", "f": ["ratio"]}},
		{"n": "lin100@gp120", "p": "gp120", "pr": "damp", "c": "lin100",
			"f": ["lv_end"], "x": {"pre": "D t=2 ", "f": ["ratio"]}},
		{"n": "warm_rest@gp30", "p": "gp30", "pr": "warm", "c": "rest",
			"f": ["y_end"], "x": {"pre": "W t=60 ", "f": ["imp"]}},
		{"n": "warm_rest@gp120", "p": "gp120", "pr": "warm", "c": "rest",
			"f": ["y_end"], "x": {"pre": "W t=60 ", "f": ["imp"]}},
		{"n": "warm_rest@jolt30", "p": "jolt30", "pr": "warm", "c": "rest",
			"f": ["y_end"], "x": {"pre": "W t=60 ", "f": ["imp"]}},
		{"n": "warm_rest@jolt120", "p": "jolt120", "pr": "warm", "c": "rest",
			"f": ["y_end"], "x": {"pre": "W t=60 ", "f": ["imp"]}},
		{"n": "it_pin@gp30", "p": "gp30", "pr": "iters", "c": "pin",
			"f": ["last_gap", "last_lv"], "x": {"pre": "IT t=2 ", "f": ["lv"]}},
		{"n": "it_pin@gp120", "p": "gp120", "pr": "iters", "c": "pin",
			"f": ["last_gap", "last_lv"], "x": {"pre": "IT t=2 ", "f": ["lv"]}},
		{"n": "it_pin@jolt30", "p": "jolt30", "pr": "iters", "c": "pin",
			"f": ["last_gap", "last_lv"], "x": {"pre": "IT t=2 ", "f": ["lv"]}},
		{"n": "it_pin@jolt120", "p": "jolt120", "pr": "iters", "c": "pin",
			"f": ["last_gap", "last_lv"], "x": {"pre": "IT t=2 ", "f": ["lv"]}},
		{"n": "pen_overlap@gp30", "p": "gp30", "pr": "pen", "c": "overlap",
			"f": ["sep_end"]},
		{"n": "pen_overlap@gp120", "p": "gp120", "pr": "pen", "c": "overlap",
			"f": ["sep_end"]},
		{"n": "pen_overlap@jolt30", "p": "jolt30", "pr": "pen", "c": "overlap",
			"f": ["sep_end"]},
		{"n": "pen_overlap@jolt120", "p": "jolt120", "pr": "pen", "c": "overlap",
			"f": ["sep_end"]},
		{"n": "rest_sum@gp30", "p": "gp30", "pr": "rest", "c": "sum",
			"f": ["e_vel"]},
		{"n": "rest_sum@gp120", "p": "gp120", "pr": "rest", "c": "sum",
			"f": ["e_vel"]},
		{"n": "rest_mid@gp30", "p": "gp30", "pr": "rest", "c": "mid",
			"f": ["e_vel"]},
		{"n": "rest_mid@gp120", "p": "gp120", "pr": "rest", "c": "mid",
			"f": ["e_vel"]},
		{"n": "damp_sleep1@gp30", "p": "gp30", "pr": "damp", "c": "sleep1",
			"f": ["slept_at", "lv_end"]},
		{"n": "damp_sleep1@gp120", "p": "gp120", "pr": "damp", "c": "sleep1",
			"f": ["slept_at", "lv_end"]},
		{"n": "damp_sleep1@jolt30", "p": "jolt30", "pr": "damp", "c": "sleep1",
			"f": ["slept_at", "lv_end"]},
		{"n": "damp_sleep1@jolt120", "p": "jolt120", "pr": "damp", "c": "sleep1",
			"f": ["slept_at", "lv_end"]},
	],
	"solver": [
		{"n": "it1_chain@gp", "p": "it1", "pr": "iters", "c": "chain",
			"f": ["last_sum", "max_sum"]},
		{"n": "it64_chain@gp", "p": "it64", "pr": "iters", "c": "chain",
			"f": ["last_sum", "max_sum"]},
		{"n": "it1_stack@gp", "p": "it1", "pr": "iters", "c": "stack",
			"f": ["last_y4", "last_xz4"]},
		{"n": "it64_stack@gp", "p": "it64", "pr": "iters", "c": "stack",
			"f": ["last_y4", "last_xz4"]},
		{"n": "v1_chain@jolt", "p": "jolt_v1", "pr": "iters", "c": "chain",
			"f": ["last_sum"]},
		{"n": "v60_chain@jolt", "p": "jolt_v60", "pr": "iters", "c": "chain",
			"f": ["last_sum"]},
		{"n": "v1_stack@jolt", "p": "jolt_v1", "pr": "iters", "c": "stack",
			"f": ["last_pen0", "last_xz4"]},
		{"n": "v60_stack@jolt", "p": "jolt_v60", "pr": "iters", "c": "stack",
			"f": ["last_pen0", "last_xz4"]},
		{"n": "p0_chain@jolt", "p": "jolt_p0", "pr": "iters", "c": "chain",
			"f": ["last_sum"]},
		{"n": "p1_chain@jolt", "p": "jolt_p1", "pr": "iters", "c": "chain",
			"f": ["last_sum"]},
		{"n": "p8_chain@jolt", "p": "jolt_p8", "pr": "iters", "c": "chain",
			"f": ["last_sum"]},
		{"n": "p0_pin@jolt", "p": "jolt_p0", "pr": "iters", "c": "pin",
			"f": ["last_gap", "max_gap"]},
		{"n": "p1_pin@jolt", "p": "jolt_p1", "pr": "iters", "c": "pin",
			"f": ["last_gap", "max_gap"]},
		{"n": "p0_hinge@jolt", "p": "jolt_p0", "pr": "iters", "c": "hinge",
			"f": ["max_over", "last_over"]},
		{"n": "p1_hinge@jolt", "p": "jolt_p1", "pr": "iters", "c": "hinge",
			"f": ["max_over", "last_over"]},
		{"n": "p8_hinge@jolt", "p": "jolt_p8", "pr": "iters", "c": "hinge",
			"f": ["max_over", "last_over"]},
		{"n": "p8_stack@jolt", "p": "jolt_p8", "pr": "iters", "c": "stack",
			"f": ["last_pen0", "last_xz4"]},
	],
	"mech": [
		{"n": "pen_gp_pen", "p": "gp_pen", "pr": "pen", "c": "overlap",
			"f": ["sep_end"]},
		{"n": "pen_gp_bias", "p": "gp_bias", "pr": "pen", "c": "overlap",
			"f": ["sep_end"]},
		{"n": "pen_jolt_slop", "p": "jolt_slop", "pr": "pen", "c": "overlap",
			"f": ["sep_end"]},
		{"n": "pen_jolt_baum", "p": "jolt_baum", "pr": "pen", "c": "overlap",
			"f": ["sep_end"], "x": {"pre": "P t=2 ", "f": ["sep"]}},
		{"n": "pen_jolt_spec0", "p": "jolt_spec0", "pr": "pen", "c": "approach",
			"f": ["first_mod_tick", "first_mod_gap"]},
		{"n": "pen_gp_sep0", "p": "gp_sep0", "pr": "pen", "c": "approach",
			"f": ["first_mod_tick", "first_mod_gap"]},
		{"n": "rest_jolt_bthr0_low", "p": "jolt_bthr0", "pr": "rest", "c": "low",
			"f": ["e_vel", "v_out"]},
	],
}

var PROJECTS := {}
var arm := ""
var parts: Array = []
var notes: Array = []
var _leak_re: RegEx
var _imp_re: RegEx


var run_prefix := ""


func _d(name: String) -> String:
	# child dirs are namespaced by pid so two concurrent parent instances (a
	# rep sweep) can never share a child dir.
	return "%s%s" % [run_prefix, name]


func _base(tps: int) -> String:
	return ("[application]\n\nconfig/name=\"R96Scout\"\n\n[physics]\n\n"
			+ "common/physics_ticks_per_second=%d\n") % tps


func _build_projects() -> void:
	PROJECTS = {
		"gp60": _base(60),
		"jolt60": _base(60) + JOLT,
		"dummy60": _base(60) + DUMMY,
		"gp30": _base(30),
		"gp120": _base(120),
		"jolt30": _base(30) + JOLT,
		"jolt120": _base(120) + JOLT,
		"gp_thr": _base(60) + THR,
		"jolt_thr": _base(60) + JOLT + THR,
		"jolt_nocache": _base(60) + JOLT +
			"jolt_physics_3d/simulation/body_pair_contact_cache_enabled=false\n",
		"jolt_bthr0": _base(60) + JOLT +
			"jolt_physics_3d/simulation/bounce_velocity_threshold=0.0\n",
		"jolt_kinct": _base(60) + JOLT +
			"jolt_physics_3d/simulation/generate_all_kinematic_contacts=true\n",
		"jolt_spec0": _base(60) + JOLT +
			"jolt_physics_3d/simulation/speculative_contact_distance=0.0\n",
		"jolt_slop": _base(60) + JOLT +
			"jolt_physics_3d/simulation/penetration_slop=0.1\n",
		"jolt_baum": _base(60) + JOLT +
			"jolt_physics_3d/simulation/baumgarte_stabilization_factor=0.05\n",
		"gp_pen": _base(60) + "3d/solver/contact_max_allowed_penetration=0.2\n",
		"gp_bias": _base(60) + "3d/solver/default_contact_bias=0.2\n",
		"gp_sep0": _base(60) + "3d/solver/contact_max_separation=0.0\n",
		"it1": _base(60) + "3d/solver/solver_iterations=1\n",
		"it64": _base(60) + "3d/solver/solver_iterations=64\n",
		"jolt_v1": _base(60) + JOLT + "jolt_physics_3d/simulation/velocity_steps=1\n",
		"jolt_v60": _base(60) + JOLT + "jolt_physics_3d/simulation/velocity_steps=60\n",
		"jolt_p0": _base(60) + JOLT + "jolt_physics_3d/simulation/position_steps=0\n",
		"jolt_p1": _base(60) + JOLT + "jolt_physics_3d/simulation/position_steps=1\n",
		"jolt_p8": _base(60) + JOLT + "jolt_physics_3d/simulation/position_steps=8\n",
	}


func _initialize() -> void:
	_build_projects()
	run_prefix = "r96t%d_" % OS.get_process_id()
	_leak_re = RegEx.new()
	_leak_re.compile("^ERROR: [0-9]+ RID allocations of type .* were leaked at exit\\.$")
	_imp_re = RegEx.new()
	_imp_re.compile("imp=[^ ]+ ")
	call_deferred("_run")


func _run() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--arm="):
			arm = a.substr(6)
	var ok := false
	match arm:
		"joint", "contact", "restkin", "tps", "solver", "mech":
			ok = _run_cells(ARMS[arm])
		"tscale":
			ok = _run_tscale()
		"ffps":
			ok = _run_ffps()
		"dummy":
			ok = _run_dummy()
		"thread":
			ok = _run_thread()
		"knobs":
			ok = _run_knobs()
		"nc":
			ok = _run_nc()
		_:
			print("FAIL r96_joltdet unknown arm=%s" % arm)
			quit(0)
			return
	for n in notes:
		print("# r96_joltdet %s %s" % [arm, n])
	if ok:
		print("PASS r96_joltdet %s %s" % [arm, " ".join(parts)])
	else:
		print("FAIL r96_joltdet %s %s" % [arm, " ".join(parts)])
	quit(0)


# --- scanner ----------------------------------------------------------------

func _sha16(lines: Array) -> String:
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update("\n".join(lines).to_utf8_buffer())
	return ctx.finish().hex_encode().substr(0, 16)


func _scan_lines(src: Array) -> Dictionary:
	var m: Array = []
	var w := 0
	var wp: Array = []
	var lk := 0
	var pe := 0
	var ue: Array = []
	var i := 0
	while i < src.size():
		var line: String = src[i]
		if line.is_empty() or line.begins_with("Godot Engine v"):
			i += 1
			continue
		if line == WARN1 and i + 1 < src.size() and src[i + 1] == WARN2:
			w += 1
			wp.append(i)
			i += 2
			continue
		if line.begins_with("ERROR: Condition \"!is_inside_tree()\" is true."):
			pe += 1
			i += 1
			while i < src.size() and src[i].begins_with(" "):
				i += 1
			continue
		if _leak_re.search(line) != null:
			lk += 1
			i += 1
			continue
		if line.begins_with("ERROR:") or "SCRIPT ERROR" in line \
				or "Parse Error" in line or "handle_crash" in line:
			ue.append(line.strip_edges())
			i += 1
			continue
		m.append(line)
		i += 1
	return {"m": m, "sha": _sha16(m), "w": w, "wp": wp, "lk": lk,
			"pe": pe, "ue": ue}


func _scan(path: String, cap := 0) -> Dictionary:
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
	var res := _scan_lines(txt.split("\n"))
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


func _cell_text(name: String, res: Dictionary, spec: Dictionary) -> String:
	if res.has("err"):
		return "%s{err=%s}" % [name, res["err"]]
	var sha: String = res["sha"]
	var key := "sha"
	if spec.get("pose", false):
		# pose-only surface: the impulse readback is dropped
		var pose: Array = []
		for line in res["m"]:
			if line.begins_with("W t="):
				pose.append(_imp_re.sub(line, "", true))
		sha = _sha16(pose)
		key = "psha"
	var txt := "%s{rc=%d,%s=%s" % [name, res["rc"], key, sha]
	var sum := _sum_line(res["m"], spec["pr"])
	for fname in spec.get("f", []):
		txt += ",%s=%s" % [fname, _field(sum, fname)]
	if spec.has("x"):
		var ln := _line_with(res["m"], spec["x"]["pre"])
		for fname in spec["x"]["f"]:
			txt += ",%s=%s" % [fname, _field(ln, fname)]
	return txt + "}"


func _cell_ok(res: Dictionary) -> bool:
	return not res.has("err") and res["rc"] == 0 and res["ue"].is_empty()


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
	var src := FileAccess.open("res://r96_probe_%s.gd" % spec["probe"],
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
		var res := _scan(prep["logpath"], specs[i].get("cap", 0))
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


# --- generic arms -----------------------------------------------------------

func _run_cells(cells: Array) -> bool:
	var specs := []
	for c in cells:
		specs.append({"dir": _d("%s_%s" % [arm, c["n"].replace("@", "_")]),
			"body": c["p"], "probe": c["pr"], "case": c["c"],
			"eargs": "--fixed-fps 60"})
	var out := _run_all(specs)
	var ok := true
	for i in specs.size():
		var res: Dictionary = out[i]
		parts.append(_cell_text(cells[i]["n"], res, cells[i]))
		if not _cell_ok(res):
			ok = false
			notes.append("%s ue=%s" % [cells[i]["n"], ",".join(res.get("ue", []))])
	return ok


# --- special arms -----------------------------------------------------------

func _run_tscale() -> bool:
	var pairs := [
		["pin_ts05", "iters", "pin", "0.5", "gp120", "gp60"],
		["pin_ts20", "iters", "pin", "2.0", "gp30", "gp60"],
		["jpin_ts05", "iters", "pin", "0.5", "jolt120", "jolt60"],
		["jpin_ts20", "iters", "pin", "2.0", "jolt30", "jolt60"],
		["lin10_ts05", "damp", "lin10", "0.5", "gp120", "gp60"],
		["lin10_ts20", "damp", "lin10", "2.0", "gp30", "gp60"],
	]
	var specs := []
	for p in pairs:
		specs.append({"dir": _d("ts_%s_ts" % p[0]), "body": p[5],
			"probe": p[1], "case": p[2],
			"eargs": "--fixed-fps 60 --time-scale %s" % p[3]})
		specs.append({"dir": _d("ts_%s_ref" % p[0]), "body": p[4],
			"probe": p[1], "case": p[2], "eargs": "--fixed-fps 60"})
	var out := _run_all(specs)
	var ok := true
	for i in pairs.size():
		var ts: Dictionary = out[i * 2]
		var ref: Dictionary = out[i * 2 + 1]
		var eq: bool = _cell_ok(ts) and _cell_ok(ref) and ts["sha"] == ref["sha"]
		parts.append("%s{eq=%d,sha=%s,ref=%s}" % [pairs[i][0], 1 if eq else 0,
				ts.get("sha", "-"), ref.get("sha", "-")])
		if not eq:
			ok = false
	return ok


func _run_ffps() -> bool:
	var reps := 6
	var specs := []
	for i in reps:
		specs.append({"dir": _d("ff_jolt_r%d" % (i + 1)), "body": "jolt60",
			"probe": "iters", "case": "pin", "eargs": "--fixed-fps 60"})
	specs.append({"dir": _d("ff_jolt_ref"), "body": "jolt60",
		"probe": "iters", "case": "pin", "eargs": ""})
	specs.append({"dir": _d("ff_gp_r1"), "body": "gp60",
		"probe": "iters", "case": "pin", "eargs": "--fixed-fps 60"})
	specs.append({"dir": _d("ff_gp_r2"), "body": "gp60",
		"probe": "iters", "case": "pin", "eargs": "--fixed-fps 60"})
	specs.append({"dir": _d("ff_gp_ref"), "body": "gp60",
		"probe": "iters", "case": "pin", "eargs": ""})
	var out := _run_all(specs)
	var jreps := out.slice(0, reps)
	var jref: Dictionary = out[reps]
	var g1: Dictionary = out[reps + 1]
	var g2: Dictionary = out[reps + 2]
	var gref: Dictionary = out[reps + 3]
	var jnorm := true
	var warned := 0
	var pos := []
	for r in jreps:
		if not _cell_ok(r) or r["sha"] != jreps[0]["sha"]:
			jnorm = false
		warned += r.get("w", 0)
		for p in r.get("wp", []):
			pos.append(str(p))
	var jref_eq: bool = _cell_ok(jref) and jref["sha"] == jreps[0]["sha"]
	var graw: bool = _cell_ok(g1) and _cell_ok(g2) and _cell_ok(gref) \
			and g1["sha"] == g2["sha"] and g1["sha"] == gref["sha"] \
			and g1.get("w", 0) == 0 and g2.get("w", 0) == 0 \
			and gref.get("w", 0) == 0
	# scanner self-gate: the exact 2-line text is dropped at any position; a
	# near-miss (first line without its "at:" line) is NOT dropped.
	var s1 := _scan_lines([WARN1, WARN2, "M a", "M b"])
	var s2 := _scan_lines(["M a", WARN1, WARN2, "M b"])
	var s3 := _scan_lines(["M a", WARN1, "M b"])
	var allow_ok: bool = s1["w"] == 1 and s1["m"] == ["M a", "M b"] \
			and s2["w"] == 1 and s2["m"] == ["M a", "M b"]
	var reject_ok: bool = s3["w"] == 0 and s3["m"].size() == 3 and s3["m"][1] == WARN1
	notes.append("ffps jolt warn=%d/%d pos=%s" % [warned, reps,
			",".join(pos) if not pos.is_empty() else "-"])
	notes.append("ffps jolt sha=%s ref=%s" % [jreps[0].get("sha", "-"),
			jref.get("sha", "-")])
	notes.append("ffps gp sha=%s" % g1.get("sha", "-"))
	parts.append("jolt_ffps{reps=%d,norm_eq=%d,ref_eq=%d,sha=%s}" % [reps,
			1 if jnorm else 0, 1 if jref_eq else 0, jreps[0].get("sha", "-")])
	parts.append("gp_ffps{reps=2,raw_eq=%d,sha=%s}" % [
			1 if graw else 0, g1.get("sha", "-")])
	parts.append("allowlist{allow=%d,reject=%d}" % [
			1 if allow_ok else 0, 1 if reject_ok else 0])
	return jnorm and jref_eq and graw and allow_ok and reject_ok


func _run_dummy() -> bool:
	# (cell, probe, case, field) — dummy + gp + jolt live controls.
	var cells := [
		["it_pin", "iters", "pin", "last_gap"],
		["pen_overlap", "pen", "overlap", "sep_end"],
		["warm_rest", "warm", "rest", "y_end"],
		["damp_lin10", "damp", "lin10", "lv_end"],
		["kin_kcontact", "kin", "kcontact", "cc_end"],
	]
	var specs := []
	for c in cells:
		for bk in [["dummy", "dummy60"], ["gp", "gp60"], ["jolt", "jolt60"]]:
			specs.append({"dir": _d("d_%s_%s" % [c[0], bk[0]]),
				"body": bk[1], "probe": c[1], "case": c[2],
				"eargs": "--fixed-fps 60"})
	# the hang cell: damp.gd sleep1 under Dummy never reaches its quit; the
	# probe loops on an invalid Variant until the short bound KILLs it.
	specs.append({"dir": _d("d_sleep1_dummy"), "body": "dummy60",
		"probe": "damp", "case": "sleep1", "eargs": "--fixed-fps 60",
		"bound": HANG_BOUND_S, "cap": HANG_CAP_BYTES})
	specs.append({"dir": _d("d_sleep1_gp"), "body": "gp60",
		"probe": "damp", "case": "sleep1", "eargs": "--fixed-fps 60"})
	specs.append({"dir": _d("d_sleep1_jolt"), "body": "jolt60",
		"probe": "damp", "case": "sleep1", "eargs": "--fixed-fps 60"})
	var out := _run_all(specs)
	var ok := true
	for i in cells.size():
		var d: Dictionary = out[i * 3]
		var g: Dictionary = out[i * 3 + 1]
		var j: Dictionary = out[i * 3 + 2]
		var fname: String = cells[i][3]
		parts.append("%s{d=%s,gp=%s,jolt=%s}" % [cells[i][0],
				_field(_sum_line(d.get("m", []), cells[i][1]), fname),
				_field(_sum_line(g.get("m", []), cells[i][1]), fname),
				_field(_sum_line(j.get("m", []), cells[i][1]), fname)])
		if not _cell_ok(d) or not _cell_ok(g) or not _cell_ok(j):
			ok = false
			notes.append("%s ue=%s" % [cells[i][0],
					",".join(d.get("ue", []) + g.get("ue", []) + j.get("ue", []))])
	var hang: Dictionary = out[cells.size() * 3]
	var hgp: Dictionary = out[cells.size() * 3 + 1]
	var hjolt: Dictionary = out[cells.size() * 3 + 2]
	var nodsum := _sum_line(hang.get("m", []), "damp") == ""
	var d0 := false
	for line in hang.get("m", []):
		if line.begins_with("D0 case=sleep1"):
			d0 = true
	var hang_ok: bool = hang.get("rc", 0) == 137 and hang.get("truncated", false) \
			and not hang.has("err") and nodsum and d0 \
			and not hang.get("ue", []).is_empty()
	parts.append("sleep1{dummy_rc=%d,hang=%d,nodsum=%d,d0=%d,gp_slept=%s,jolt_slept=%s}" % [
			hang.get("rc", -1), 1 if hang_ok else 0, 1 if nodsum else 0,
			1 if d0 else 0,
			_field(_sum_line(hgp.get("m", []), "damp"), "slept_at"),
			_field(_sum_line(hjolt.get("m", []), "damp"), "slept_at")])
	DirAccess.remove_absolute(ProjectSettings.globalize_path(
			"res://%s/child.log" % _d("d_sleep1_dummy")))
	return ok and hang_ok


func _run_thread() -> bool:
	var cells := [
		["it_pin", "iters", "pin"], ["it_stack", "iters", "stack"],
		["warm_rest", "warm", "rest"], ["pen_overlap", "pen", "overlap"],
		["damp_lin10", "damp", "lin10"],
	]
	var specs := []
	for c in cells:
		for bk in [["gp", "gp60", "gp_thr"], ["jolt", "jolt60", "jolt_thr"]]:
			specs.append({"dir": _d("th_%s_%s_ref" % [c[0], bk[0]]),
				"body": bk[1], "probe": c[1], "case": c[2],
				"eargs": "--fixed-fps 60"})
			specs.append({"dir": _d("th_%s_%s_thr" % [c[0], bk[0]]),
				"body": bk[2], "probe": c[1], "case": c[2],
				"eargs": "--fixed-fps 60"})
	var out := _run_all(specs)
	var ok := true
	for i in cells.size():
		for b in 2:
			var ref: Dictionary = out[(i * 2 + b) * 2]
			var thr: Dictionary = out[(i * 2 + b) * 2 + 1]
			var bk := "gp" if b == 0 else "jolt"
			var eq: bool = _cell_ok(ref) and _cell_ok(thr) and ref["sha"] == thr["sha"]
			parts.append("%s@%s{eq=%d,sha=%s}" % [cells[i][0], bk,
					1 if eq else 0, ref.get("sha", "-")])
			if not eq:
				ok = false
	return ok


func _run_knobs() -> bool:
	var specs := []
	for bk in [["gp", "gp60"], ["jolt", "jolt60"], ["dummy", "dummy60"]]:
		specs.append({"dir": _d("k_%s" % bk[0]), "body": bk[1],
			"label": bk[0], "probe": "settings", "case": "dump",
			"eargs": "--fixed-fps 60"})
	var out := _run_all(specs)
	var ok := true
	var shas := []
	for i in specs.size():
		var res: Dictionary = out[i]
		var names: Array = []
		var props := ""
		for line in res.get("m", []):
			if line.begins_with("ST P physics/"):
				names.append(line.substr(0, line.find(" = ")))
			elif line.begins_with("ST total_props="):
				props = _field(line, "physics_props")
		var sh := _sha16(names)
		shas.append(sh)
		parts.append("%s{props=%s,keys=%d,sha=%s}" % [specs[i]["label"],
				props, names.size(), sh])
		if not _cell_ok(res):
			ok = false
	var eq_gj: bool = shas.size() == 3 and shas[0] == shas[1]
	var eq_gd: bool = shas.size() == 3 and shas[0] == shas[2]
	parts.append("keys{eq_gp_jolt=%d,eq_gp_dummy=%d}" % [
			1 if eq_gj else 0, 1 if eq_gd else 0])
	return ok and eq_gj and eq_gd


func _run_nc() -> bool:
	# With the Jolt contact cache off, contact-0's IDENTITY is not rep-stable:
	# the per-tick impulse readback can come back as the all-zero sentinel or
	# as a different contact's impulse. The pose surface (y0/vmax per tick) is
	# rep-stable, so that is what this cell pins; the impulse readback is
	# censused as a class in '#' diagnostics and never pinned (r96-boundary
	# §5 — here it also fires inside a small --fixed-fps batch).
	var specs := []
	for i in 4:
		specs.append({"dir": _d("nc_r%d" % (i + 1)), "body": "jolt_nocache",
			"probe": "warm", "case": "stack", "eargs": "--fixed-fps 60"})
	var out := _run_all(specs)
	var imp_re := RegEx.new()
	imp_re.compile("imp=[^ ]+ ")
	var pose_shas := []
	var zero_ticks := 0
	var ticks := 0
	for r in out:
		var pose: Array = []
		for line in r.get("m", []):
			if line.begins_with("W t="):
				ticks += 1
				if "imp=0.000000,0.000000,0.000000" in line:
					zero_ticks += 1
				pose.append(imp_re.sub(line, "", true))
		pose_shas.append(_sha16(pose))
	var eq := true
	for i in out.size():
		if not _cell_ok(out[i]) or pose_shas[i] != pose_shas[0]:
			eq = false
	notes.append("nc impulse zero-read ticks=%d/%d" % [zero_ticks, ticks])
	var ln := _line_with(out[0].get("m", []), "W t=60 ")
	parts.append("nocache_stack{reps=4,pose_eq=%d,pose_sha=%s,y0=%s,vmax=%s}" % [
			1 if eq else 0, pose_shas[0], _field(ln, "y0"),
			_field(ln, "vmax")])
	return eq
