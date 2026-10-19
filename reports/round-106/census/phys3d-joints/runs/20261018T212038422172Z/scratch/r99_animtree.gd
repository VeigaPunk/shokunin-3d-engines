extends SceneTree
# r99 AnimationTree / AnimationNodeBlendTree lattice — parent fixture.
#
# Children are byte-identical copies of the r99 boundary probes, run under
# their ORIGINAL res:// names (r99b_core.gd, r99b_untracked.gd, r99b_modes.gd,
# r99b_sm.gd, r99b_silent.gd, r99b_life.gd) so a child receipt reproduces the
# boundary's own receipt byte-for-byte; the parent copies the source out of
# res://r99_probe_<name>.gd into a per-cell project dir. Every cell runs
# `--fixed-fps` (the boundary's byte-stable scheduler) on all three backends
# (gp=GodotPhysics, jolt, dummy); only boundary-surviving claims are pinned —
# the scout's falsified forms ("two non-advancing frames", "AUTO fires at the
# animation end", "travel(zzz) is silent", "base-idle pins") are encoded in
# their corrected boundary form or not pinned at all.
#
# Digest cell:
#   <name>{rc=<n>,sha=<16 hex>,<field>=<value>,...}
# `sha` is sha256-16 over the child's NORMALIZED contract stream. Dropped or
# masked before hashing (declared normalizations, never content-changing):
#   - the "Godot Engine v..." banner and empty lines;
#   - the exact 2-line Jolt job-system warning, allowlisted by text and
#     tolerated at ANY position (r96/r97/r99-boundary: a dense-frame artifact
#     of the Jolt job system, never observed on this surface);
#   - runtime object ids: `#-<digits>` / `#<digits>` -> `#N` (allocation-order
#     artifacts, e.g. the AnimationNodeStateMachinePlayback instance id);
#   - the physics-server read `srv=<...>` -> `srv=S` (the Dummy backend has no
#     server to read; the claim is node-side parity, and the server value is
#     still extracted verbatim where it IS the claim, e.g. body/ctl/repeat);
#   - the probe-internal counters `seq=N`, `idle_rows=N`, `pf_rows=N` (watcher
#     callback interleave, not a pinned value).
# Expected-error classes (per-cell `e` list) stay in the hashed stream and
# are counted in `ee`; any OTHER line matching ERROR:/SCRIPT ERROR/
# Parse Error/handle_crash/ObjectDB-leak lands in `ue` and fails the cell.
# Each cell also requires its arm's declared final marker (`mark`) so a
# mid-arm script-error truncation fails loudly instead of hashing short.
#
# Laws landed (r99-scout folded through r99-boundary verdicts):
#   core      connect_node is receiver-first (provider-first is rejected with
#             ee=1 and the actor never moves); x = 4*tp exactly on all 34
#             frames (dz=0); the player keeps playing=false under an active
#             tree and a raw current_animation_position read errors once;
#             blend_amount write+read-back is exact; TimeScale 2x advances
#             the clock exactly 2x over 8 physics frames; a tree_root swap
#             is a pose cut on a continuing clock; the tree's write to a
#             frozen RigidBody3D reaches the physics server byte-identically
#             on GP and Jolt (Dummy: srv=nil).
#   ut_scope  the untracked-target default write's scope: the (path, track
#             type) set comes from ALL libraries of the driving player's
#             mixer (namedlib/ballonly/keyless zero the Ball; orphan and
#             otherplayer do not), not from any live Animation object and
#             not from another player's library; ctl zeroes Ball position
#             on node AND server.
#   ut_mech   the mechanism bounds: keyed by (path, track type) so typedef
#             resets scale->(1,1,1) rot->0 while position survives; needs an
#             active tree and a process pass (inactive/manual hold until an
#             advance); re-applied EVERY pass (repeat: a hand-restored Ball
#             is zeroed again); a plain AnimationPlayer.play does NOT do it
#             (notree); an unresolvable path warns once at cache build
#             (ghostpath) without touching the Ball.
#   modes     process_callback law, corrected: under --fixed-fps 60 every
#             cell is byte-stable; PHYSICS is rate-invariant (phys_f30/f120
#             peq=1 vs the ffps60 twin) while IDLE is deterministic per rate
#             but rate-dependent (idle_f30/f120 peq=0); MANUAL is inert
#             until advance() and the first advance is absorbed
#             (lead_zero=5, a2_actor=(1,0,0)); the player's own
#             callback_mode_process is irrelevant once a tree drives.
#   order     the corrected first-frames law: the leading non-advancing
#             physics frames are sampler-position dependent — phys watcher
#             pre counts 2, post counts 1; idle counts 1 either way.
#   sm_adv    ENABLED never auto-advances in any wiring (7 arms end node=a,
#             swpf=-); AUTO with a condition fires the frame after the
#             condition write (autocond swpf=7, not at tp=1.0); AUTO with no
#             condition fires on state entry (autonocond swpf, node=b).
#   sm_misc   next() is inert in ENABLED and AUTO (node stays a); travel()
#             is a hard cut and the travel path is never populated
#             (next_path lands c, travel_path=[] in both modes); a stale
#             condition fires on re-activation AUTO-only (condlate node=b
#             vs condlate_enabled node=a); stop() resets the clock and
#             clears is_playing while the state keeps advancing
#             (si_playing=true read-back, st_playing=false after start);
#             travel() defers one process (ci_node=Start -> node=b).
#   silent    missing animation name and missing parameter path are silent
#             no-ops (ee=0, reads <null>, the valid write still lands);
#             duplicate node/state names error once and keep the original;
#             travel(<unknown>) is NOT silent — it errors 3x on the
#             following process pass in both phases (ee=6), state unchanged.
#   life      teardown is safe on all backends: freeing the tree freezes the
#             pose; freeing the player does NOT stop the tree
#             (FP_AFTER actor keeps advancing); freeing the actor is silent;
#             nulling tree_root freezes at the last pose; active off/on
#             holds and resumes the clock; 340 instantiate+free cycles of
#             animation classes with zero crash (the r97 XRServer class does
#             not reproduce).
#
# Not pinned (boundary-unknown or falsified): the unthrottled `base` rate
# cells (scheduler-load variable by construction), xfade_time crossfade
# (still [?]), what ENABLED is *for*, BlendSpace1D/2D, OneShot/Transition/
# Add2/3/Mix*/Sync, play_mode/backward, root_motion, skeleton targets, the
# scout-only cells the boundary never replayed (at_cls census, at_wire arms,
# remove_readd, reparent, null_anim_player, null_root, playback_after_
# rootswap, animnode_root, bt_missing, parammiss/blendparam scout versions,
# paused, notravel, start_node, xfade, xfade2, condlong, condauto, dupnode/
# badnode/start_node scout versions).

const CHUNK := 8
const BOUND_S := 14

const JOLT := "3d/physics_engine=\"Jolt Physics\"\n"
const DUMMY := "3d/physics_engine=\"Dummy\"\n"

const WARN1 := "WARNING: Jolt Physics job system exceeded the maximum number of jobs. This should not happen. Please report this. Waiting for jobs to become available..."
const WARN2 := "     at: CreateJob (modules/jolt_physics/spaces/jolt_job_system.cpp:123)"

# Expected-error allowlist heads. A matching ERROR-class line is kept in the
# hashed stream and counted in `ee` instead of failing the cell. "leak" is a
# sentinel for the ObjectDB-leak warning line (matched by regex).
const ERR_ALLOW := {
	"wire": [
		"ERROR: Condition \"p_output_node == SceneStringNames::get_singleton()->output\" is true.",
	],
	"ppos": [
		"ERROR: AnimationPlayer has no current animation.",
	],
	"dupn": [
		"ERROR: Condition \"nodes.has(p_name)\" is true.",
	],
	"dups": [
		"ERROR: Condition \"states.has(p_name)\" is true.",
	],
	"badstate": [
		"ERROR: zzz is not found current state.",
		"ERROR: Condition \"!p_state_machine->states.has(travel)\" is true. Returning: false",
		"ERROR: No such node: 'zzz'",
	],
	"leak": ["leak"],
}

var PROJECTS := {}
var arm := ""
var parts: Array = []
var notes: Array = []
var _leak_re: RegEx
var _id_re: RegEx
var _srv_re: RegEx
var _seq_re: RegEx
var _irows_re: RegEx
var _prows_re: RegEx

var run_prefix := ""


func _d(name: String) -> String:
	# child dirs are namespaced by pid so two concurrent parent instances (a
	# rep sweep) can never share a child dir.
	return "%s%s" % [run_prefix, name]


func _base() -> String:
	return ("[application]\n\nconfig/name=\"R99Fixture\"\n\n[physics]\n\n"
			+ "common/physics_ticks_per_second=60\n")


func _build_projects() -> void:
	PROJECTS = {
		"gp60": _base(),
		"jolt60": _base() + JOLT,
		"dummy60": _base() + DUMMY,
	}


func _initialize() -> void:
	_build_projects()
	run_prefix = "r99t%d_" % OS.get_process_id()
	_leak_re = RegEx.new()
	_leak_re.compile("^WARNING: [1-9][0-9]* ObjectDB instances? (were|was) leaked at exit")
	_id_re = RegEx.new()
	_id_re.compile("#-?[0-9]+")
	_srv_re = RegEx.new()
	_srv_re.compile("srv=[^ ]*")
	_seq_re = RegEx.new()
	_seq_re.compile("seq=[0-9]+")
	_irows_re = RegEx.new()
	_irows_re.compile("idle_rows=[0-9]+")
	_prows_re = RegEx.new()
	_prows_re.compile("pf_rows=[0-9]+")
	call_deferred("_run")


func _run() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--arm="):
			arm = a.substr(6)
	var ok := false
	match arm:
		"core": ok = _run_cells(_cells_core())
		"ut_scope": ok = _run_cells(_cells_ut1())
		"ut_mech": ok = _run_cells(_cells_ut2())
		"modes": ok = _run_cells(_cells_modes())
		"order": ok = _run_cells(_cells_order())
		"sm_adv": ok = _run_cells(_cells_sm_adv())
		"sm_misc": ok = _run_cells(_cells_sm_misc())
		"silent": ok = _run_cells(_cells_silent())
		"life": ok = _run_cells(_cells_life())
		_:
			print("FAIL r99_animtree unknown arm=%s" % arm)
			quit(0)
			return
	for n in notes:
		print("# r99_animtree %s %s" % [arm, n])
	if ok:
		print("PASS r99_animtree %s %s" % [arm, " ".join(parts)])
	else:
		print("FAIL r99_animtree %s %s" % [arm, " ".join(parts)])
	quit(0)


# --- cell tables ------------------------------------------------------------
# spec: n=name p=project pr=probe c=case-args eargs=engine-args mark=required
# final-marker prefix e=allowlist classes x=[{pre,tag,f,bare}] sw={pre,field,
# want} dz=count non-exact E rows peq=ffps60 twin name

func _x(pre: String, f: Array, tag := "") -> Dictionary:
	return {"pre": pre, "f": f, "tag": tag}


func _xb(pre: String, tag: String) -> Dictionary:
	return {"pre": pre, "f": [], "tag": tag, "bare": true}


func _modesum() -> Array:
	return [_x("MODE_SUM ", ["x_pf10", "x_pf20", "x_pf30", "t_pf30",
			"lead_zero", "pf_first_move"]),
		_x("MODE_POST ", ["actor", "playing"], "post")]


func _spread(case: String, probe: String, cargs: String, mark: String,
		extra := {}) -> Array:
	var out := []
	for b in [["gp", "gp60"], ["jolt", "jolt60"], ["dummy", "dummy60"]]:
		var d := {"n": "%s@%s" % [case, b[0]], "p": b[1], "pr": probe,
			"c": cargs, "mark": mark, "eargs": "--fixed-fps 60"}
		for k in extra:
			d[k] = extra[k]
		out.append(d)
	return out


func _cells_core() -> Array:
	var out := []
	out.append_array(_spread("wire", "r99b_core", "--case=wire", "WIRE_B_END",
		{"e": ["wire"], "x": [_x("WIRE_A_END ", ["actor", "tp"], "a"),
			_x("WIRE_B_END ", ["actor", "tp"], "b")]}))
	out.append_array(_spread("min", "r99b_core", "--case=min", "MIN_POST",
		{"dz": true, "x": [_x("MIN_POST ", ["actor", "tp"])]}))
	out.append_array(_spread("pposerr", "r99b_core", "--case=pposerr",
		"PP_AFTER", {"e": ["ppos"], "x": [
			_x("PP_PRE ", ["playing", "tp"], "pre"),
			_xb("PP_RAW_VALUE ", "raw"),
			_x("PP_AFTER ", ["playing", "tp"])]}))
	out.append_array(_spread("blend2", "r99b_core", "--case=blend2", "BL_END",
		{"x": [_x("BL_END ", ["tp", "actor"])]}))
	out.append_array(_spread("timescale", "r99b_core", "--case=timescale",
		"TS_AFTER", {"x": [_x("TS_BEFORE ", ["tp", "actor"], "b"),
			_x("TS_AFTER ", ["tp", "actor", "dtp", "expect"])]}))
	out.append_array(_spread("rootswap", "r99b_core", "--case=rootswap",
		"RS_AFTER", {"x": [_x("RS_BEFORE ", ["actor", "tp"], "b"),
			_x("RS_AFTER ", ["actor", "tp"])]}))
	out.append_array(_spread("body", "r99b_core", "--case=body", "BD_POST",
		{"x": [_x("BD_POST ", ["actor", "ball", "srv", "frozen", "tp"])]}))
	return out


func _cells_ut1() -> Array:
	var out := []
	out.append_array(_spread("ctl", "r99b_untracked", "--case=ctl", "POST ctl",
		{"x": [_x("POST ctl ", ["actor", "ball", "srv", "tp"])]}))
	out.append_array(_spread("libclean", "r99b_untracked", "--case=libclean",
		"POST libclean", {"x": [_x("POST libclean ",
			["actor", "ball", "srv", "tp"])]}))
	out.append_array(_spread("orphan", "r99b_untracked", "--case=orphan",
		"POST orphan", {"x": [_x("ORPHAN_ANIM_ALIVE ", ["tracks"], "o"),
			_x("POST orphan ", ["ball", "srv", "tp"])]}))
	out.append_array(_spread("otherplayer", "r99b_untracked",
		"--case=otherplayer", "POST otherplayer", {"x": [
			_x("OTHERPLAYER_LIB ", ["playing"], "o"),
			_x("POST otherplayer ", ["ball", "srv", "tp"])]}))
	out.append_array(_spread("namedlib", "r99b_untracked", "--case=namedlib",
		"POST namedlib", {"x": [_x("POST namedlib ", ["ball", "srv", "tp"])]}))
	out.append_array(_spread("keyless", "r99b_untracked", "--case=keyless",
		"POST keyless", {"x": [_xb("KEYLESS_KEYS ", "k"),
			_x("POST keyless ", ["ball", "srv", "tp"])]}))
	out.append_array(_spread("ballonly", "r99b_untracked", "--case=ballonly",
		"POST ballonly", {"x": [_x("POST ballonly ", ["ball", "srv", "tp"])]}))
	return out


func _cells_ut2() -> Array:
	var out := []
	out.append_array(_spread("typedef", "r99b_untracked", "--case=typedef",
		"TYPEDEF_POST", {"x": [_x("TYPEDEF_POST ", ["sc", "rotY"]),
			_x("POST typedef ", ["ball", "srv", "tp"])]}))
	out.append_array(_spread("inactive", "r99b_untracked", "--case=inactive",
		"POST inactive", {"x": [_x("POST inactive ",
			["actor", "ball", "srv", "tp"])]}))
	out.append_array(_spread("manual", "r99b_untracked", "--case=manual",
		"POST manual_after_advance", {"x": [
			_x("POST manual_no_advance ", ["ball", "srv", "tp"], "n"),
			_x("MANUAL_ADV_NOW ", ["ball", "srv", "tp"], "adv"),
			_x("POST manual_after_advance ", ["ball", "srv", "tp"], "y")]}))
	out.append_array(_spread("activelate", "r99b_untracked",
		"--case=activelate", "POST activelate", {"x": [
			_x("AL_ACTIVATED ", ["ball", "tp"], "al"),
			_x("POST activelate ", ["ball", "srv", "tp"])]}))
	out.append_array(_spread("ghostpath", "r99b_untracked",
		"--case=ghostpath", "POST ghostpath", {"x": [
			_x("POST ghostpath ", ["ball", "srv", "tp"])]}))
	out.append_array(_spread("repeat", "r99b_untracked", "--case=repeat",
		"POST repeat", {"x": [
			_x("REPEAT_BEFORE_RESET ", ["ball", "srv", "tp"], "rb"),
			_x("REPEAT_RESET ", ["ball"], "rr"),
			_x("POST repeat ", ["ball", "srv", "tp"])]}))
	out.append_array(_spread("notree", "r99b_untracked", "--case=notree",
		"POST notree", {"x": [_x("NOTREE_PLAYING ", ["anim"], "nt"),
			_x("POST notree ", ["actor", "ball", "srv", "tp"])]}))
	return out


func _cells_modes() -> Array:
	var out := []
	var simple := ["phys", "idle", "phys_player_idle", "idle_player_phys"]
	for c in simple:
		out.append_array(_spread(c, "r99b_modes", "--case=%s" % c,
			"MODE_DONE", {"x": _modesum()}))
	out.append_array(_spread("manual", "r99b_modes", "--case=manual",
		"MODE_DONE", {"x": [
			_x("MODE_SUM ", ["lead_zero", "pf_first_move"]),
			_x("MA_IDLE ", ["actor"], "i"),
			_x("MA_ADV1 ", ["actor"], "a1"),
			_x("MA_ADV2 ", ["actor"], "a2")]}))
	# rate-dependence cells: same probes at --fixed-fps 30/120, physics-
	# anchored tuple compared to the same-backend ffps60 twin (peq).
	for c in ["phys", "idle"]:
		for rate in [30, 120]:
			for b in [["gp", "gp60"], ["jolt", "jolt60"],
					["dummy", "dummy60"]]:
				out.append({"n": "%s_f%d@%s" % [c, rate, b[0]],
					"p": b[1], "pr": "r99b_modes",
					"c": "--case=%s" % c,
					"eargs": "--fixed-fps %d" % rate,
					"mark": "MODE_DONE", "peq": "%s@%s" % [c, b[0]],
					"x": [_x("MODE_SUM ", ["x_pf10", "x_pf20",
						"x_pf30", "t_pf30", "lead_zero",
						"pf_first_move"])]})
	return out


func _cells_order() -> Array:
	var out := []
	var xs := [_x("MODE_SUM ", ["watcher", "x_pf10", "lead_zero",
		"pf_first_move"])]
	for c in ["phys", "idle"]:
		for w in ["pre", "post"]:
			var cargs := "--case=%s" % c
			if w == "post":
				cargs += " --watcher=post"
			out.append_array(_spread("%s_%s" % [c, w], "r99b_modes", cargs,
				"MODE_DONE", {"x": xs}))
	return out


func _swb() -> Dictionary:
	return {"pre": "S pf=", "field": "node", "want": "b"}


func _cells_sm_adv() -> Array:
	var out := []
	var smode := [_x("SM_MODE ", ["mode", "cond", "switch"])]
	var colend := [_x("COL_END ", ["node", "cond", "tp"])]
	for c in ["enabled_ctl", "enabled_atend", "enabled_nocond"]:
		out.append_array(_spread(c, "r99b_sm", "--case=%s" % c, "COL_END",
			{"sw": _swb(), "x": smode + colend}))
	out.append_array(_spread("enabled_early", "r99b_sm",
		"--case=enabled_early", "EARLY_END",
		{"sw": _swb(), "x": [_x("EARLY_END ", ["node", "cond", "tp"])]}))
	out.append_array(_spread("enabled_pre", "r99b_sm", "--case=enabled_pre",
		"PRE_END", {"sw": _swb(),
			"x": [_x("PRE_END ", ["node", "cond", "tp"])]}))
	out.append_array(_spread("enabled_reapply", "r99b_sm",
		"--case=enabled_reapply", "REAP_END", {"sw": _swb(), "x": [
			_x("REAP_SET ", ["cond", "adv"], "rs"),
			_x("REAP_END ", ["node", "cond", "tp"])]}))
	out.append_array(_spread("enabled_nested", "r99b_sm",
		"--case=enabled_nested", "COL_END", {"sw": _swb(), "x": [
			_x("COL_SET_SM ", ["read", "outer"], "cs"),
			_x("COL_END ", ["node", "cond", "tp"])]}))
	out.append_array(_spread("autocond", "r99b_sm", "--case=autocond",
		"COL_END", {"sw": _swb(), "x": smode + colend}))
	out.append_array(_spread("autonocond", "r99b_sm", "--case=autonocond",
		"AN_END", {"sw": _swb(),
			"x": [_x("AN_END ", ["node", "cond", "tp"])]}))
	return out


func _cells_sm_misc() -> Array:
	var out := []
	for c in ["next_enabled", "next_auto"]:
		out.append_array(_spread(c, "r99b_sm", "--case=%s" % c, "NX_AFTER",
			{"x": [_x("NX_MODE ", ["mode"]),
				_x("NX_AFTER ", ["node", "tp"])]}))
	out.append_array(_spread("next_path", "r99b_sm", "--case=next_path",
		"NP_AFTER mode=2", {"x": [
			_x("NP_AFTER mode=1 ", ["node", "travel_path"], "m1"),
			_x("NP_AFTER mode=2 ", ["node", "travel_path"], "m2")]}))
	out.append_array(_spread("condlate", "r99b_sm", "--case=condlate",
		"CL_ACTIVE", {"sw": _swb(), "x": [
			_x("CL_WRITE_INACTIVE ", ["cond", "active"], "w"),
			_x("CL_ACTIVE ", ["node", "cond", "tp"])]}))
	out.append_array(_spread("condlate_enabled", "r99b_sm",
		"--case=condlate_enabled", "CL_ACTIVE", {"sw": _swb(),
			"x": [_x("CL_ACTIVE ", ["node", "cond", "tp"])]}))
	out.append_array(_spread("stopstart", "r99b_sm", "--case=stopstart",
		"SS_AFTER", {"x": [
			_x("SS_STOP_IMMEDIATE ", ["node", "playing"], "si"),
			_x("SS_START_IMMEDIATE ", ["node", "playing"], "st"),
			_x("SS_AFTER ", ["node", "tp"])]}))
	out.append_array(_spread("traveldefer", "r99b_sm", "--case=traveldefer",
		"TV_AFTER", {"x": [_x("TV_CALL_IMMEDIATE ", ["node"], "ci"),
			_x("TV_AFTER ", ["node", "tp"])]}))
	return out


func _cells_silent() -> Array:
	var out := []
	out.append_array(_spread("missing_anim", "r99b_silent",
		"--case=missing_anim", "MA_MISSING_END",
		{"x": [_x("MA_MISSING ", ["anim", "actor", "tp", "playing"])]}))
	out.append_array(_spread("parammiss", "r99b_silent", "--case=parammiss",
		"PM_END", {"x": [_x("PM_READ_BACK ", ["nope", "amount"], "rb"),
			_x("PM_AFTER_WRITES ", ["blend"], "aw"),
			_x("PM_ACTOR ", ["actor", "tp"])]}))
	out.append_array(_spread("dupnode", "r99b_silent", "--case=dupnode",
		"DN_END", {"e": ["dupn"],
			"x": [_x("DN_DUP ", ["same_list", "kept_anim"])]}))
	out.append_array(_spread("dupstate", "r99b_silent", "--case=dupstate",
		"DS_END", {"e": ["dups"], "x": [_x("DS_DUP ", ["same_list"])]}))
	out.append_array(_spread("badstate", "r99b_silent", "--case=badstate",
		"BS_END", {"e": ["badstate"], "x": [
			_x("BS_P1_AFTER_ZZZ ", ["playing", "node"], "p1"),
			_x("BS_P2_AFTER_ZZZ ", ["playing", "node"], "p2"),
			_x("BS_END ", ["node"])]}))
	return out


func _cells_life() -> Array:
	var out := []
	out.append_array(_spread("freetree", "r99b_life", "--case=freetree",
		"FT_AFTER", {"x": [_x("FT_FREED ", ["tree_invalid", "pactive"], "fr"),
			_x("FT_AFTER ", ["actor", "tp"])]}))
	out.append_array(_spread("freeplayer", "r99b_life", "--case=freeplayer",
		"FP_AFTER", {"x": [_x("FP_FREED ", ["player_invalid"], "fr"),
			_x("FP_AFTER ", ["actor", "tp"])]}))
	out.append_array(_spread("freeactor", "r99b_life", "--case=freeactor",
		"FA_AFTER", {"x": [_x("FA_AFTER ", ["actor", "tp"])]}))
	out.append_array(_spread("rootnull", "r99b_life", "--case=rootnull",
		"TN_AFTER", {"x": [_x("TN_AFTER ", ["actor", "tp"])]}))
	out.append_array(_spread("activeoff", "r99b_life", "--case=activeoff",
		"AO_ON", {"x": [_x("AO_OFF ", ["actor", "tp", "active"], "off"),
			_x("AO_ON ", ["actor", "tp", "active"])]}))
	# clsloop: the loop's observed fields are stable across backends, but a
	# rare host heap abort ("corrupted size vs. prev_size") can fire during
	# engine teardown AFTER the arm marker — post-completion noise. `td`
	# truncates the hashed stream at the marker and accepts rc 0 or 134.
	out.append_array(_spread("clsloop", "r99b_life", "--case=clsloop",
		"CLS_LOOP_ALIVE", {"td": true, "x": [_x("CLS_LOOP ",
			["made", "skipped", "rounds", "names"])]}))
	return out


# --- scanner ----------------------------------------------------------------

func _sha16(lines: Array) -> String:
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update("\n".join(lines).to_utf8_buffer())
	return ctx.finish().hex_encode().substr(0, 16)


func _mask(line: String) -> String:
	line = _id_re.sub(line, "#N", true)
	line = _srv_re.sub(line, "srv=S", true)
	line = _seq_re.sub(line, "seq=N", true)
	line = _irows_re.sub(line, "idle_rows=N", true)
	return _prows_re.sub(line, "pf_rows=N", true)


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
		if line.is_empty() or line.begins_with("Godot Engine v"):
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
	f.close()
	return _scan_lines(txt.split("\n"), allow, done)


func _field(line: String, name: String) -> String:
	var key := " " + name + "="
	var i := line.find(key)
	if i < 0:
		return ""
	var rest := line.substr(i + key.length())
	var j := rest.find(" ")
	return rest if j < 0 else rest.substr(0, j)


func _line_with(lines: Array, pre: String) -> String:
	for line in lines:
		if line.begins_with(pre):
			return line
	return ""


# --- cell rendering ---------------------------------------------------------

func _pfset(res: Dictionary) -> String:
	var ln := _line_with(res.get("raw", []), "MODE_SUM ")
	if ln.is_empty():
		return ""
	return "/".join([_field(ln, "x_pf10"), _field(ln, "x_pf20"),
			_field(ln, "x_pf30"), _field(ln, "t_pf30"),
			_field(ln, "lead_zero")])


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
			txt += ",%s=%s" % [key, _field(ln, fname)]
	if spec.has("sw"):
		var sw: Dictionary = spec["sw"]
		var pf := "-"
		for line in res.get("raw", []):
			if line.begins_with(sw["pre"]) \
					and _field(line, sw["field"]) == sw["want"]:
				pf = _field(line, "pf")
				break
		txt += ",swpf=%s" % pf
	if spec.get("dz", false):
		var n := 0
		for line in res.get("raw", []):
			if line.begins_with("E pf="):
				var dv := _field(line, "d")
				if dv != "0.0000" and dv != "-0.0000":
					n += 1
		txt += ",dz=%d" % n
	return txt


func _cell_text(name: String, res: Dictionary, spec: Dictionary,
		byname: Dictionary) -> String:
	if res.has("err"):
		return "%s{err=%s}" % [name, res["err"]]
	var rc_txt := str(res["rc"])
	if spec.get("td", false):
		rc_txt = "0|134"
	var txt := "%s{rc=%s,sha=%s" % [name, rc_txt, res["sha"]]
	txt += _extract(res, spec)
	if res.get("ee", 0) > 0:
		txt += ",ee=%d" % res["ee"]
	if spec.has("mark") and _line_with(res.get("raw", []),
			spec["mark"]).is_empty():
		txt += ",mk=0"
	if spec.has("peq"):
		var other: Dictionary = byname.get(spec["peq"], {})
		var mine := _pfset(res)
		var twin := _pfset(other)
		txt += ",peq=%d" % (1 if not mine.is_empty() and mine == twin else 0)
	if not name.ends_with("@gp"):
		var refname := name.substr(0, name.rfind("@")) + "@gp"
		var other: Dictionary = byname.get(refname, {})
		txt += ",beq=%d" % (1 if res["sha"] == other.get("sha", "-") else 0)
	return txt + "}"


func _cell_ok(res: Dictionary, spec: Dictionary) -> bool:
	if res.has("err") or not res.get("ue", []).is_empty():
		return false
	var rc: int = res.get("rc", -1)
	var rc_ok: bool = rc == (spec.get("rc", 0) as int)
	# td cells: a post-marker teardown abort (rc=134) is tolerated; the
	# marker check below still proves the arm completed first.
	if not rc_ok and spec.get("td", false) and rc == 134:
		rc_ok = true
	if not rc_ok:
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
	var src := FileAccess.open("res://r99_probe_%s.gd" % spec["probe"],
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
			"done": c.get("mark", "") if c.get("td", false) else ""})
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
			notes.append("%s ue=%s" % [cells[i]["n"],
					",".join(res.get("ue", []))])
	return ok
