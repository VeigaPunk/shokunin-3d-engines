extends SceneTree
# r100 --fixed-fps scheduler lattice — parent fixture (CAPSTONE).
#
# Children are byte-identical copies of the r100 boundary probes, run under
# their ORIGINAL res:// names (r100b_sched.gd, r100b_modes.gd, r100b_rt.gd,
# r100b_area.gd, r100b_life.gd, r100b_cls.gd) so a child receipt reproduces
# the boundary's own receipt byte-for-byte; the parent copies the source out
# of res://r100_probe_<name>.gd into a per-cell project dir. Engine args go
# BEFORE --script (the round's own hazard: a flag after `--` is inert, and
# the equals-form `--fixed-fps=N` is also inert — both are armed here as
# envelope cells, never single-value pins). Only boundary-surviving claims
# are pinned: the scout's `n_pr = 120*N/60 + 1` formula and the flat
# "delta = 1/N" claim are NOT pinned (falsified); the pinned forms are the
# measured per-cell n_pr/fpt/d0/ifr values.
#
# Digest cell:
#   <name>{rc=<n>,sha=<16 hex>,<field>=<value>,...}
# `sha` is sha256-16 over the child's NORMALIZED contract stream. Dropped or
# masked before hashing (declared normalizations, never content-changing):
#   - the "Godot Engine v..." banner and empty lines;
#   - the exact 2-line Jolt job-system warning, allowlisted by text and
#     tolerated at ANY position (r100-boundary: load-dependent rate 38%-92%,
#     counted in w, never pinned);
#   - wall-clock lines: RS_TIME, AR_TIME, BM_TIME, BM_WALL, BM_FPS and the
#     per-frame BM_WF rows (own-line convention, scout hazard 3);
#   - the --benchmark block: the `BENCHMARK:` head, tab-indented section
#     rows and every ` msec.` line (wall-clock injection; the probe receipt
#     underneath is pinned byte-identical to its ffps60 twin, eq=1);
#   - runtime object ids `#-<digits>`/`#<digits>` -> `#N`.
# Expected-error classes (per-cell `e` list) stay in the hashed stream and
# are counted in `ee`; any OTHER line matching ERROR:/SCRIPT ERROR/
# Parse Error/handle_crash/ObjectDB-leak lands in `ue` and fails the cell.
# Each cell also requires its arm's declared final marker (`mark`) so a
# mid-arm truncation fails loudly instead of hashing short.
#
# Laws landed (r100-scout folded through r100-boundary verdicts):
#   sched    the pinned interleave, measured per cell: fpt/n_pr are pure
#            functions of (N, tps, jitter); the trajectory hash is a pure
#            function of the tick delta (2311ff14cd04c227 at tps=60/jit=.5,
#            c9625c56/tps=30, c20df6e2/tps=120, a2d4de09/dummy-no-integrate);
#            d0 is the two-regime startup delta (1/tps for N<=2tps else
#            1/(2tps)); ifr is the tick phase on PH rows. proj_cap is inert
#            at the scheduler level, proj_jit0 shifts the N<tps phase by one
#            frame, proj_dsfalse changes only the ds=false readback.
#   qa       --quit-after M is a FRAME bound; at N=tps an exact tick budget
#            (M=1,7,30,100 -> n_ph=M), phase-shifted elsewhere (deterministic
#            per (N,M,tps)); --quit-after 0 and --quit-after -1 both disable.
#   modes    flag-trap and degenerate-N laws: `--fixed-fps=N` (equals form)
#            and `--fixed-fps` after `--` are inert — pinned via the argv
#            witness (argz/userz) plus the inert= envelope, never a receipt
#            pin; duplicate --fixed-fps last-wins; 59.94 truncates to 59;
#            N=0 freezes physics (d=inf, ifr=-nan, n_ph=0) while N<0 and
#            N=999999999 floor the slice at 1us (d=0.000001000); --quit is
#            one ITERATION (1 tick at ffps60, 11 at ffps5); --quiet emits a
#            0-byte receipt at rc=0, --check-only a banner-only one;
#            --write-movie SIGABRTs headless after the Movie Maker banner
#            (rc=134, hash truncated before the ASLR backtrace);
#            --single-threaded-scene/--disable-render-loop/--render-thread
#            separate/--disable-vsync/--audio-driver Dummy/--main-loop
#            SceneTree/--log-file/--no-header are scheduler-inert (eq=1).
#   compose  composition laws: --time-scale scales deltas and the
#            trajectory (traj=f(ts/tps)) without touching the interleave;
#            --max-fps in either argv order loses to --fixed-fps; the
#            jitter_fix=0.5 delta scaling at N=119/121 vs the exact-1/N
#            jit0 twins; cap inert at 60 steps/frame; the
#            physics_interpolation=true one-frame startup phase shift;
#            the frame-delay-200 twin pair (receipt byte-identical under
#            deterministic 200 ms frames); the N-tps boundary cells 59/61.
#   rt       the r92 frame-boundary law under a pinned rate: the
#            RemoteTransform3D write is visible to the idle phase of the
#            frame that ran the physics step (never synchronous, never to a
#            later node in the same tick); the lag law; the propagated
#            transform reaching the physics server by the next tick
#            (Dummy: srv=<null>, ray=miss — the expected null).
#   area     the r93 in-tick signal law under a pinned rate: enter at tick
#            29, exit at 35 (teleport written at 34), sig rows land between
#            _integrate_forces and _physics_process of the detecting tick
#            (Dummy: first=-1 last=-1, the expected null).
#   life     teardown outcomes are rate- and backend-inert: clean quit,
#            idle quit, mid-run tree free, a SCRIPT-ERROR run that still
#            exits rc=0 (rc=0-is-blind hazard, kept in the hash as ee=1),
#            --fixed-fps 60 --quit-after 20 ending an unbounded probe with
#            _finalize running, _finalize-after-free erroring (ee=1),
#            quit() being immediate; the unbound control arms as an
#            envelope (rc=137 + >=1 tick), never a receipt pin.
#   cls      census readbacks of the round's pivot settings (tps/jit/cap/
#            ds/ip/maxfps) per project, and the rate-surface class
#            inventory.
#
# Not pinned (boundary-unknown or nondeterministic by construction): every
# unpinned base-mode cell (the r92 idle-multiplicity defect — removing it
# is the round's own claim), the closed form of a(N) (best-fit only),
# --quit-after tick counts away from measured (N,M,tps) triples,
# --verbose/--benchmark wall chatter content, the --write-movie backtrace,
# --print-fps values, and the noquit_unbound kill instant.

const CHUNK := 8
const BOUND_S := 15

const JOLT := "3d/physics_engine=\"Jolt Physics\"\n"
const DUMMY := "3d/physics_engine=\"Dummy\"\n"
const IPB := "common/physics_interpolation=true\n"
const CAP1 := "common/max_physics_steps_per_frame=1\n"
const JIT0 := "common/physics_jitter_fix=0.0\n"

const WARN1 := "WARNING: Jolt Physics job system exceeded the maximum number of jobs. This should not happen. Please report this. Waiting for jobs to become available..."
const WARN2 := "     at: CreateJob (modules/jolt_physics/spaces/jolt_job_system.cpp:123)"

# Wall-clock line prefixes dropped before hashing (own-line convention).
const WALL_PREFIX := ["RS_TIME", "AR_TIME", "BM_TIME", "BM_WALL", "BM_FPS",
	"BM_WF", "FPS:"]

# Expected-error allowlist heads. A matching ERROR-class line is kept in the
# hashed stream and counted in `ee` instead of failing the cell. "leak" is a
# sentinel for the ObjectDB-leak warning line (matched by regex).
const ERR_ALLOW := {
	"wm": [
		'ERROR: Parameter "t" is null.',
	],
	"lerr": [
		"SCRIPT ERROR: Invalid call. Nonexistent function 'no_such_method_at_all' in base 'RigidBody3D'.",
	],
	"lfin": [
		"SCRIPT ERROR: Invalid access to property or key 'global_position' on a base object of type 'previously freed'.",
	],
	"arerr": [
		"ERROR: Error calling from signal 'body_shape_entered' to callable: 'SceneTree(r100b_area.gd)::_on_shape_enter': Cannot convert argument 1 from RID to Object.",
	],
	"leak": ["leak"],
}

var PROJECTS := {}
var arm := ""
var parts: Array = []
var notes: Array = []
var _leak_re: RegEx
var _id_re: RegEx
var _msec_re: RegEx
var _fpt_re: RegEx

var run_prefix := ""


func _d(name: String) -> String:
	# child dirs are namespaced by pid so two concurrent parent instances (a
	# rep sweep) can never share a child dir.
	return "%s%s" % [run_prefix, name]


func _base(tps := 60) -> String:
	return ("[application]\n\nconfig/name=\"R100Fixture\"\n\n[physics]\n\n"
			+ "common/physics_ticks_per_second=%d\n" % tps
			+ "common/max_physics_steps_per_frame=8\n"
			+ "common/physics_jitter_fix=0.5\n")


func _build_projects() -> void:
	PROJECTS = {
		"gp60": _base(),
		"jolt60": _base() + JOLT,
		"dummy60": _base() + DUMMY,
		"cap1": _base() + CAP1,
		"jit0": _base() + JIT0,
		"dsf": ("[application]\n\nconfig/name=\"R100Fixture\"\n"
				+ "run/delta_smoothing=false\n\n[physics]\n\n"
				+ "common/physics_ticks_per_second=60\n"
				+ "common/max_physics_steps_per_frame=8\n"
				+ "common/physics_jitter_fix=0.5\n"),
		"t30": _base(30),
		"t120": _base(120),
		"t30j": _base(30) + JOLT,
		"ip": _base() + IPB,
	}


func _initialize() -> void:
	_build_projects()
	run_prefix = "r100t%d_" % OS.get_process_id()
	_leak_re = RegEx.new()
	_leak_re.compile("^WARNING: [1-9][0-9]* ObjectDB instances? (were|was) leaked at exit")
	_id_re = RegEx.new()
	_id_re.compile("#-?[0-9]+")
	_msec_re = RegEx.new()
	_msec_re.compile(" msec\\.")
	_fpt_re = RegEx.new()
	_fpt_re.compile("fpt=\\[[^\\]]*\\]")
	call_deferred("_run")


func _run() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--arm="):
			arm = a.substr(6)
	var ok := false
	match arm:
		"sched": ok = _run_cells(_cells_sched())
		"qa": ok = _run_cells(_cells_qa())
		"modes": ok = _run_cells(_cells_modes())
		"compose": ok = _run_cells(_cells_compose())
		"rt": ok = _run_cells(_cells_rt())
		"area": ok = _run_cells(_cells_area())
		"life": ok = _run_cells(_cells_life())
		"cls": ok = _run_cells(_cells_cls())
		_:
			print("FAIL r100_fpslat unknown arm=%s" % arm)
			quit(0)
			return
	for n in notes:
		print("# r100_fpslat %s %s" % [arm, n])
	if ok:
		print("PASS r100_fpslat %s %s" % [arm, " ".join(parts)])
	else:
		print("FAIL r100_fpslat %s %s" % [arm, " ".join(parts)])
	quit(0)


# --- cell tables ------------------------------------------------------------
# spec: n=name p=project pr=probe c=case-args eargs=engine-args mark=required
# final-marker prefix e=allowlist classes rc=expected-exit bound=timeout-s
# done=hash-truncate prefix x=[{pre,tag,f,bare}] eq=twin-name env=envelope
# bytes=print log size

func _x(pre: String, f: Array, tag := "") -> Dictionary:
	return {"pre": pre, "f": f, "tag": tag}


func _xb(pre: String, tag: String) -> Dictionary:
	return {"pre": pre, "f": [], "tag": tag, "bare": true}


func _endx() -> Array:
	return [_x("RS_END ", ["n_pr", "n_ph"], ""), _x("RS_END ", ["fpt", "traj"])]


func _bendx() -> Array:
	return [_x("BM_END ", ["n_pr", "n_ph", "steps_max"], ""),
		_x("BM_END ", ["fpt", "traj"])]


func _sched_cell(n: String, proj: String, n_fps: int, extra := {}) -> Dictionary:
	var d := {"n": n, "p": proj, "pr": "r100b_sched", "c": "--ticks=120",
		"eargs": "--fixed-fps %d" % n_fps, "mark": "RS_END",
		"x": _endx() + [_x("RS_PR n=1 ", ["d"], "p1"),
			_x("RS_PH n=30 ", ["ifr"], "h30")]}
	for k in extra:
		d[k] = extra[k]
	return d


func _cells_sched() -> Array:
	var out := []
	for b in [["gp", "gp60"], ["jolt", "jolt60"], ["dummy", "dummy60"]]:
		out.append(_sched_cell("ffps60@%s" % b[0], b[1], 60))
	for n in [5, 10, 30, 90, 120, 240]:
		out.append(_sched_cell("ffps%d@gp" % n, "gp60", n))
	for n in [5, 30]:
		out.append(_sched_cell("cap_ffps%d@gp" % n, "cap1", n,
			{"x": _endx() + [_x("RS_BOOT ", ["cap"], "b")]}))
		out.append(_sched_cell("jit0_ffps%d@gp" % n, "jit0", n,
			{"x": _endx() + [_x("RS_BOOT ", ["jit"], "b")]}))
	for n in [30, 60]:
		out.append(_sched_cell("dsf_ffps%d@gp" % n, "dsf", n,
			{"x": _endx() + [_x("RS_BOOT ", ["ds"], "b")]}))
	for n in [30, 60, 120]:
		out.append(_sched_cell("t30_ffps%d" % n, "t30", n))
	for n in [60, 120]:
		out.append(_sched_cell("t120_ffps%d" % n, "t120", n))
	out.append(_sched_cell("t30j_ffps60", "t30j", 60))
	return out


func _cells_qa() -> Array:
	var out := []
	var xs := _endx()
	for m in [1, 7, 30, 100]:
		out.append({"n": "qa%d_ffps60@gp" % m, "p": "gp60",
			"pr": "r100b_sched", "c": "--ticks=100000",
			"eargs": "--fixed-fps 60 --quit-after %d" % m,
			"mark": "RS_END", "x": xs})
	for cell in [["qa31_ffps120", 120, 31], ["qa61_ffps240", 240, 61],
			["qa101_ffps90", 90, 101], ["qa121_ffps120", 120, 121]]:
		out.append({"n": "%s@gp" % cell[0], "p": "gp60", "pr": "r100b_sched",
			"c": "--ticks=100000",
			"eargs": "--fixed-fps %d --quit-after %d" % [cell[1], cell[2]],
			"mark": "RS_END", "x": xs})
	out.append({"n": "t30_quit30@gp", "p": "t30", "pr": "r100b_sched",
		"c": "--ticks=100000",
		"eargs": "--fixed-fps 60 --quit-after 30",
		"mark": "RS_END", "x": xs})
	out.append({"n": "t120_quit30@gp", "p": "t120", "pr": "r100b_sched",
		"c": "--ticks=100000",
		"eargs": "--fixed-fps 60 --quit-after 30",
		"mark": "RS_END", "x": xs})
	# --quit-after 0 disables the frame bound: 4000 ticks run to completion
	# on both backends (backend-equal sha). Sized for the battery's 20 s
	# per-case cap — Jolt grinds ~4x slower than GodotPhysics here.
	for b in [["gp", "gp60"], ["jolt", "jolt60"]]:
		out.append({"n": "quit0_t4k@%s" % b[0], "p": b[1],
			"pr": "r100b_sched", "c": "--ticks=4000",
			"eargs": "--fixed-fps 60 --quit-after 0",
			"mark": "RS_END", "x": xs})
	out.append({"n": "qaneg1_t2k@gp", "p": "gp60", "pr": "r100b_sched",
		"c": "--ticks=2000", "eargs": "--fixed-fps 60 --quit-after -1",
		"mark": "RS_END", "x": xs})
	return out


func _cells_modes() -> Array:
	var out := []
	var xs := _bendx()
	# twin anchor for the eq cells of this arm.
	out.append({"n": "ffps60", "p": "gp60", "pr": "r100b_modes",
		"c": "--ticks=120", "eargs": "--fixed-fps 60", "mark": "BM_END",
		"x": xs})
	# flag-trap envelopes: argz/userz are the deterministic argv witness;
	# `inert` is the envelope predicate (NOT the pinned-60 triple), never a
	# receipt pin — the unpinned receipt itself is nondeterministic.
	out.append({"n": "ffpseq60", "p": "gp60", "pr": "r100b_modes",
		"c": "--ticks=120", "eargs": "--fixed-fps=60", "mark": "BM_END",
		"env": "inert60",
		"x": [_x("BM_BOOT ", ["argz", "userz"], "b")]})
	out.append({"n": "afterdashes_ffps60", "p": "gp60", "pr": "r100b_sched",
		"c": "--fixed-fps 60 --ticks=120", "eargs": "", "mark": "RS_END",
		"env": "inert60",
		"x": [_x("RS_BOOT ", ["argz", "userz"], "b")]})
	out.append({"n": "ffpsdup_30_60", "p": "gp60", "pr": "r100b_modes",
		"c": "--ticks=120", "eargs": "--fixed-fps 30 --fixed-fps 60",
		"mark": "BM_END", "x": xs, "eq": "ffps60"})
	out.append({"n": "ffpsfloat", "p": "gp60", "pr": "r100b_modes",
		"c": "--ticks=120", "eargs": "--fixed-fps 59.94",
		"mark": "BM_END", "x": xs})
	# degenerate N: identical BM_END counters, distinct per-frame deltas.
	for cell in [["ffps0_qa20", "0"], ["ffpsneg_qa20", "-5"],
			["ffpshuge_qa20", "999999999"]]:
		out.append({"n": cell[0], "p": "gp60", "pr": "r100b_modes",
			"c": "", "eargs": "--fixed-fps %s --quit-after 20" % cell[1],
			"mark": "BM_END", "x": xs + [
				_x("BM_PR n=1 ", ["d", "ifr"], "p1"),
				_x("BM_PR n=2 ", ["d", "ifr"], "p2")]})
	out.append({"n": "quit_ffps60", "p": "gp60", "pr": "r100b_modes",
		"c": "--ticks=100000", "eargs": "--fixed-fps 60 --quit",
		"mark": "BM_END", "x": xs})
	out.append({"n": "quit_ffps5", "p": "gp60", "pr": "r100b_modes",
		"c": "--ticks=100000", "eargs": "--fixed-fps 5 --quit",
		"mark": "BM_END", "x": xs})
	# output-surface flags: --quiet is a 0-byte receipt at rc=0,
	# --check-only a banner-only one; --benchmark/--no-header/--log-file
	# leave the probe receipt identical to the ffps60 twin (eq=1).
	out.append({"n": "quiet", "p": "gp60", "pr": "r100b_modes",
		"c": "--ticks=120", "eargs": "--fixed-fps 60 --quiet",
		"bytes": true})
	out.append({"n": "checkonly", "p": "gp60", "pr": "r100b_modes",
		"c": "--ticks=120", "eargs": "--fixed-fps 60 --check-only",
		"bytes": true})
	for cell in [["benchmark", "--benchmark"], ["noheader", "--no-header"],
			["logfile", "--log-file LF"], ["singlethread", "--single-threaded-scene"],
			["norender", "--disable-render-loop"],
			["renderthread", "--render-thread separate"],
			["vsyncoff", "--disable-vsync"],
			["audiodummy", "--audio-driver Dummy"],
			["mainloop", "--main-loop SceneTree"]]:
		var ea: String = "--fixed-fps 60 " + cell[1]
		if cell[1] == "--log-file LF":
			ea = "--fixed-fps 60 --log-file \"%s\"" % (
				ProjectSettings.globalize_path(
					"res://" + _d("modes_logfile")) + "/engine.log")
		out.append({"n": cell[0], "p": "gp60", "pr": "r100b_modes",
			"c": "--ticks=120", "eargs": ea, "mark": "BM_END",
			"x": xs, "eq": "ffps60"})
	# --write-movie crashes headless: rc=134, Movie Maker banner pinned,
	# hash truncated at the deterministic at: line before the ASLR
	# backtrace; the ERROR head is an expected class.
	out.append({"n": "writemovie", "p": "gp60", "pr": "r100b_modes",
		"c": "", "eargs": "--fixed-fps 60 --write-movie \"%s\" --quit-after 10"
			% (ProjectSettings.globalize_path("res://" + _d("modes_writemovie"))
				+ "/movie.avi"),
		"mark": "Movie Maker mode enabled", "rc": 134,
		"done": "   at: texture_2d_get", "e": ["wm"],
		"x": [_xb("Movie Maker mode enabled", "movie")]})
	return out


func _cells_compose() -> Array:
	var out := []
	var xs := _bendx()
	# fdelay pair FIRST so its 8 s wall rides the longest chunk.
	out.append({"n": "qa40", "p": "gp60", "pr": "r100b_modes",
		"c": "--ticks=100000", "eargs": "--fixed-fps 60 --quit-after 40",
		"mark": "BM_END", "x": xs})
	out.append({"n": "fdelay200_qa40", "p": "gp60", "pr": "r100b_modes",
		"c": "--ticks=100000",
		"eargs": "--fixed-fps 60 --frame-delay 200 --quit-after 40",
		"mark": "BM_END", "x": xs, "eq": "qa40", "bound": 13})
	out.append({"n": "ffps60", "p": "gp60", "pr": "r100b_modes",
		"c": "--ticks=120", "eargs": "--fixed-fps 60", "mark": "BM_END",
		"x": xs})
	# --time-scale composition: traj = f(ts/tps), interleave untouched.
	for cell in [["ts05", "0.5"], ["ts2", "2.0"], ["ts4", "4.0"]]:
		out.append({"n": "ffps60_%s" % cell[0], "p": "gp60",
			"pr": "r100b_modes", "c": "--ticks=120",
			"eargs": "--fixed-fps 60 --time-scale %s" % cell[1],
			"mark": "BM_END", "x": xs + [
				_x("BM_PH n=2 ", ["d"], "h2")]})
	out.append({"n": "ffps30_ts2", "p": "gp60", "pr": "r100b_modes",
		"c": "--ticks=120", "eargs": "--fixed-fps 30 --time-scale 2.0",
		"mark": "BM_END", "x": xs})
	out.append({"n": "ffps30_ts05", "p": "gp60", "pr": "r100b_modes",
		"c": "--ticks=120", "eargs": "--fixed-fps 30 --time-scale 0.5",
		"mark": "BM_END", "x": xs})
	out.append({"n": "ts0_qa20", "p": "gp60", "pr": "r100b_modes",
		"c": "--ticks=100000",
		"eargs": "--fixed-fps 60 --time-scale 0 --quit-after 20",
		"mark": "BM_END", "x": xs})
	out.append({"n": "jolt_ts2", "p": "jolt60", "pr": "r100b_modes",
		"c": "--ticks=120", "eargs": "--fixed-fps 60 --time-scale 2.0",
		"mark": "BM_END", "x": xs})
	out.append({"n": "dummy_ts2", "p": "dummy60", "pr": "r100b_modes",
		"c": "--ticks=120", "eargs": "--fixed-fps 60 --time-scale 2.0",
		"mark": "BM_END", "x": xs})
	# --max-fps loses to --fixed-fps in both argv orders; the readback pins.
	for cell in [["maxfps30", "--fixed-fps 60 --max-fps 30"],
			["maxfps_first", "--max-fps 30 --fixed-fps 60"],
			["maxfps0", "--fixed-fps 60 --max-fps 0"]]:
		out.append({"n": cell[0], "p": "gp60", "pr": "r100b_modes",
			"c": "--ticks=120", "eargs": cell[1], "mark": "BM_END",
			"x": xs + [_x("BM_BOOT ", ["maxfps"], "b")], "eq": "ffps60"})
	out.append({"n": "dsenable", "p": "gp60", "pr": "r100b_modes",
		"c": "--ticks=120",
		"eargs": "--fixed-fps 60 --delta-smoothing enable",
		"mark": "BM_END", "x": xs, "eq": "ffps60"})
	# the jitter_fix delta law at N=119/121 (default vs jit0 bakes).
	for cell in [["ffps119", "gp60", "119"], ["ffps121", "gp60", "121"],
			["jit0_ffps119", "jit0", "119"], ["jit0_ffps121", "jit0", "121"]]:
		out.append({"n": cell[0], "p": cell[1], "pr": "r100b_modes",
			"c": "--ticks=120", "eargs": "--fixed-fps " + cell[2],
			"mark": "BM_END", "x": xs + [
				_x("BM_PR n=1 ", ["d"], "p1"),
				_x("BM_PR n=2 ", ["d"], "p2"),
				_x("BM_BOOT ", ["jit"], "b")]})
	# cap is inert even at 60 steps/frame.
	for cell in [["cap1_ffps1", "cap1", "1"], ["cap8_ffps1", "gp60", "1"],
			["cap1_ffps5", "cap1", "5"], ["cap8_ffps5", "gp60", "5"]]:
		out.append({"n": cell[0], "p": cell[1], "pr": "r100b_modes",
			"c": "--ticks=120", "eargs": "--fixed-fps " + cell[2],
			"mark": "BM_END", "x": xs + [
				_x("BM_BOOT ", ["cap"], "b")]})
	out.append({"n": "cap1_ffps0_qa20", "p": "cap1", "pr": "r100b_modes",
		"c": "", "eargs": "--fixed-fps 0 --quit-after 20",
		"mark": "BM_END", "x": xs})
	# physics_interpolation=true shifts the startup phase one frame.
	for n in [60, 120, 5]:
		out.append({"n": "ip_ffps%d" % n, "p": "ip", "pr": "r100b_modes",
			"c": "--ticks=120", "eargs": "--fixed-fps %d" % n,
			"mark": "BM_END", "x": xs + [
				_x("BM_BOOT ", ["ip"], "b")]})
	# the N ladder and the N=tps boundary cells.
	for n in [45, 75, 150, 300, 600, 59, 61]:
		out.append({"n": "ffps%d" % n, "p": "gp60", "pr": "r100b_modes",
			"c": "--ticks=120", "eargs": "--fixed-fps %d" % n,
			"mark": "BM_END", "x": xs + [
				_x("BM_PR n=1 ", ["d"], "p1")]})
	return out


func _cells_rt() -> Array:
	var out := []
	for b in [["gp", "gp60"], ["jolt", "jolt60"], ["dummy", "dummy60"]]:
		for c in ["phase", "lag", "srv"]:
			var d := {"n": "%s@%s" % [c, b[0]], "p": b[1],
				"pr": "r100b_rt", "c": c, "eargs": "--fixed-fps 60",
				"mark": "RT_DONE"}
			if c == "phase":
				d["rtw"] = true
			elif c == "lag":
				d["x"] = [_x("LG write=4.0 ", ["imm", "after1", "ff1"], "lg")]
			else:
				d["x"] = [_x("SRV_S2_AFTERPHYS ", ["pf", "ff", "ray"], "s2")]
			out.append(d)
	for n in [30, 120]:
		out.append({"n": "phase_ffps%d@gp" % n, "p": "gp60", "pr": "r100b_rt",
			"c": "phase", "eargs": "--fixed-fps %d" % n, "mark": "RT_DONE",
			"rtw": true})
	return out


func _cells_area() -> Array:
	var out := []
	for b in [["gp", "gp60"], ["jolt", "jolt60"], ["dummy", "dummy60"]]:
		for c in ["enter", "exit"]:
			out.append({"n": "%s@%s" % [c, b[0]], "p": b[1],
				"pr": "r100b_area", "c": c, "eargs": "--fixed-fps 60",
				"mark": "AR_END", "e": ["arerr"],
				"x": [_x("AR_END ", ["first", "last"], "e")]})
	for c in ["enter", "exit"]:
		out.append({"n": "%s_ffps120@gp" % c, "p": "gp60",
			"pr": "r100b_area", "c": c, "eargs": "--fixed-fps 120",
			"mark": "AR_END", "e": ["arerr"],
			"x": [_x("AR_END ", ["first", "last"], "e")]})
	return out


func _cells_life() -> Array:
	var out := []
	for b in [["gp", "gp60"], ["jolt", "jolt60"], ["dummy", "dummy60"]]:
		for c in ["clean", "quit_idle", "freetree", "err", "noquit_bound",
				"noquit_unbound", "finalize_touch", "quit_double"]:
			var d := {"n": "%s@%s" % [c, b[0]], "p": b[1],
				"pr": "r100b_life", "c": c, "eargs": "--fixed-fps 60",
				"mark": "LF_END"}
			match c:
				"err":
					d["e"] = ["lerr"]
				"finalize_touch":
					d["e"] = ["lfin"]
					d["mark"] = "LF_FIN_TOUCH"
				"noquit_bound":
					d["eargs"] = "--fixed-fps 60 --quit-after 20"
				"noquit_unbound":
					d["eargs"] = ""
					d["env"] = "unbound"
					d["bound"] = 5
					d["rc"] = 137
					d["mark"] = "LF_BOOT"
			out.append(d)
	return out


func _cells_cls() -> Array:
	var out := []
	for cell in [["gp", "gp60"], ["jolt", "jolt60"], ["dummy", "dummy60"],
			["t30", "t30"], ["t120", "t120"], ["ip", "ip"],
			["jit0", "jit0"], ["cap1", "cap1"], ["dsf", "dsf"]]:
		out.append({"n": "census@%s" % cell[0], "p": cell[1],
			"pr": "r100b_cls", "c": "", "eargs": "", "mark": "CLS_DONE",
			"x": [_xb("CLS_SET physics/common/physics_ticks_per_second = ",
					"tps"),
				_xb("CLS_SET physics/common/physics_jitter_fix = ", "jit"),
				_xb("CLS_SET physics/common/max_physics_steps_per_frame = ",
					"cap"),
				_xb("CLS_SET application/run/delta_smoothing = ", "ds"),
				_xb("CLS_SET physics/common/physics_interpolation = ", "ip"),
				_x("CLS_CLASS PhysicalBoneSimulator3D ",
					["exists", "inst"], "pbs")]})
	return out


# --- scanner ----------------------------------------------------------------

func _sha16(lines: Array) -> String:
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	# update() rejects a zero-length buffer; an empty normalized stream
	# (quiet child) is still a real signature — e3b0c44298fc1c14.
	var buf := "\n".join(lines).to_utf8_buffer()
	if not buf.is_empty():
		ctx.update(buf)
	return ctx.finish().hex_encode().substr(0, 16)


func _mask(line: String) -> String:
	return _id_re.sub(line, "#N", true)


func _wall(line: String) -> bool:
	for pre in WALL_PREFIX:
		if line.begins_with(pre):
			return true
	return false


func _bench(line: String) -> bool:
	return line == "BENCHMARK:" or line.begins_with("\t") \
		or _msec_re.search(line) != null


func _allowed(line: String, allow: Array) -> bool:
	for cls in allow:
		for head in ERR_ALLOW.get(cls, []):
			if head == "leak":
				continue
			if line == head or line.begins_with(head):
				return true
	return false


func _scan_lines(src: Array, allow: Array, done := "") -> Dictionary:
	var m: Array = []      # masked stream (hashed)
	var raw: Array = []    # same lines, unmasked (field extraction)
	var w := 0
	var ee := 0
	var ue: Array = []
	var i := 0
	while i < src.size():
		var line: String = src[i]
		if line.is_empty() or line.begins_with("Godot Engine v") \
				or _wall(line) or _bench(line):
			i += 1
			continue
		if line == WARN1 and i + 1 < src.size() and src[i + 1] == WARN2:
			w += 1
			i += 2
			continue
		var is_err: bool = line.begins_with("ERROR:") \
				or "SCRIPT ERROR" in line or "Parse Error" in line \
				or "handle_crash" in line
		if is_err:
			if _allowed(line, allow):
				ee += 1
				m.append(_mask(line))
				raw.append(line)
			else:
				ue.append(line.strip_edges())
			i += 1
			continue
		if _leak_re.search(line) != null:
			if allow.has("leak"):
				m.append(_mask(line))
				raw.append(line)
			else:
				ue.append(line.strip_edges())
			i += 1
			continue
		m.append(_mask(line))
		raw.append(line)
		i += 1
		if not done.is_empty() and line.begins_with(done):
			break
	return {"m": m, "raw": raw, "sha": _sha16(m), "w": w, "ee": ee, "ue": ue}


func _scan(path: String, allow: Array, done := "") -> Dictionary:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {"err": "child log missing"}
	var txt := f.get_as_text()
	# to_utf8_buffer() errors on the empty string (quiet child → 0-byte log).
	var nbytes: int = 0 if txt.is_empty() else txt.to_utf8_buffer().size()
	f.close()
	var res := _scan_lines(txt.split("\n"), allow, done)
	res["bytes"] = nbytes
	return res


func _field(line: String, name: String) -> String:
	var key := " " + name + "="
	var i := line.find(key)
	if i < 0:
		return ""
	var rest := line.substr(i + key.length())
	var j := rest.find(" ")
	return rest if j < 0 else rest.substr(0, j)


func _bfield(line: String) -> String:
	var hit := _fpt_re.search(line)
	return hit.get_string().substr(4) if hit else ""


func _line_with(lines: Array, pre: String) -> String:
	for line in lines:
		if line.begins_with(pre):
			return line
	return ""


# --- cell rendering ---------------------------------------------------------

func _extract(res: Dictionary, spec: Dictionary) -> String:
	var txt := ""
	for blk in spec.get("x", []):
		var ln := _line_with(res.get("raw", []), blk["pre"])
		if blk.get("bare", false):
			var rest := ""
			if not ln.is_empty():
				rest = ln.substr((blk["pre"] as String).length())
			txt += ",%s=%s" % [blk.get("tag", "v"), rest]
			continue
		for fname in blk.get("f", []):
			var key: String = fname
			if not (blk.get("tag", "") as String).is_empty():
				key = "%s_%s" % [blk["tag"], fname]
			var val := _bfield(ln) if fname == "fpt" else _field(ln, fname)
			txt += ",%s=%s" % [key, val]
	return txt


func _env_fields(res: Dictionary, kind: String) -> String:
	match kind:
		"inert60":
			# NOT the pinned-60 triple (n_ph==120, n_pr==120,
			# fpt == [0:1, 1:119]): an envelope, never a receipt pin.
			var ln := _line_with(res.get("raw", []), "RS_END ")
			if ln.is_empty():
				ln = _line_with(res.get("raw", []), "BM_END ")
			var pinned := _field(ln, "n_ph") == "120" \
				and _field(ln, "n_pr") == "120" \
				and _bfield(ln) == "[0:1, 1:119]"
			return ",inert=%d" % (0 if pinned else 1)
		"unbound":
			var boot := 0
			var ticks := 0
			for line in res.get("raw", []):
				if line.begins_with("LF_BOOT"):
					boot = 1
				if line.begins_with("LF_TICK"):
					ticks += 1
			return ",boot=%d,tickge1=%d" % [boot, 1 if ticks > 0 else 0]
	return ""


func _rtw_fields(res: Dictionary) -> String:
	# the r92 frame-boundary claim, pinned arithmetically: the write lands
	# in the idle phase of the frame that ran the physics step — the first
	# R_F row at the write's pf already carries the new transform.
	var wln := _line_with(res.get("raw", []), "RT write_at_E W_E ")
	if wln.is_empty():
		return ",rtw=0"
	var wpf := _field(wln, "pf")
	for line in res.get("raw", []):
		if line.begins_with("RT arm=write_at_E p=R_F ") \
				and _field(line, "pf") == wpf:
			return ",w_pf=%s,w_ff=%s,rf_ff=%s,rf_O=%s" % [
				wpf, _field(wln, "ff"), _field(line, "ff"),
				_field(line, "O")]
	return ",rtw=0"


func _cell_text(name: String, res: Dictionary, spec: Dictionary,
		byname: Dictionary) -> String:
	if res.has("err"):
		return "%s{err=%s}" % [name, res["err"]]
	var env := spec.get("env", "") as String
	var txt := "%s{rc=%s" % [name, str(res["rc"])]
	if env.is_empty():
		txt += ",sha=%s" % res["sha"]
	else:
		txt += _env_fields(res, env)
	if spec.get("bytes", false):
		txt += ",b=%d" % res.get("bytes", -1)
	txt += _extract(res, spec)
	if spec.get("rtw", false):
		txt += _rtw_fields(res)
	if res.get("ee", 0) > 0:
		txt += ",ee=%d" % res["ee"]
	if spec.has("mark") and _line_with(res.get("raw", []),
			spec["mark"]).is_empty():
		txt += ",mk=0"
	if spec.has("eq"):
		var other: Dictionary = byname.get(spec["eq"], {})
		txt += ",eq=%d" % (1 if res["sha"] == other.get("sha", "-") else 0)
	# envelope cells (env: the stream end is a timeout SIGKILL, so its
	# normalized hash is load-dependent): never assert stream equality —
	# the envelope fields are the claim.
	if not name.ends_with("@gp") and "@" in name and env.is_empty():
		var refname := name.substr(0, name.rfind("@")) + "@gp"
		var other: Dictionary = byname.get(refname, {})
		txt += ",beq=%d" % (1 if res["sha"] == other.get("sha", "-") else 0)
	return txt + "}"


func _cell_ok(res: Dictionary, spec: Dictionary) -> bool:
	if res.has("err") or not res.get("ue", []).is_empty():
		return false
	var rc: int = res.get("rc", -1)
	if rc != (spec.get("rc", 0) as int):
		return false
	if spec.has("mark") and _line_with(res.get("raw", []),
			spec["mark"]).is_empty():
		return false
	return true


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
	var src := FileAccess.open("res://r100_probe_%s.gd" % spec["probe"],
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
	var cmd := ("timeout -s KILL %d \"%s\" --headless --path \"%s\" %s"
			+ " --script \"res://%s.gd\" -- %s > \"%s\" 2>&1") % [
			bound, OS.get_executable_path(), dir, spec.get("eargs", ""),
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
	var mbound := BOUND_S
	for spec in specs:
		mbound = maxi(mbound, spec.get("bound", BOUND_S) as int)
	var deadline := Time.get_ticks_msec() + mbound * 1000
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
		var res := _scan(prep["logpath"], specs[i].get("e", []),
				specs[i].get("done", ""))
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


# --- generic arm ------------------------------------------------------------

func _run_cells(cells: Array) -> bool:
	var specs := []
	for c in cells:
		specs.append({"dir": _d("%s_%s" % [arm, c["n"].replace("@", "_")]),
			"body": c["p"], "probe": c["pr"], "case": c["c"],
			"e": c.get("e", []), "eargs": c.get("eargs", ""),
			"bound": c.get("bound", BOUND_S),
			"done": c.get("done", "")})
	var out := _run_all(specs)
	var ok := true
	var byname := {}
	for i in cells.size():
		byname[cells[i]["n"]] = out[i]
	for i in cells.size():
		var res: Dictionary = out[i]
		parts.append(_cell_text(cells[i]["n"], res, cells[i], byname))
		if not _cell_ok(res, cells[i]):
			ok = false
			notes.append("%s ue=%s rc=%s" % [cells[i]["n"],
					",".join(res.get("ue", [])), str(res.get("rc", "-"))])
	return ok
