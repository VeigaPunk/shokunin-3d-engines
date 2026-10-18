extends SceneTree
# r99b probe C — attack the r99 scout §4 pin:
#   "Advance conditions — AUTO fires, ENABLED did not ... Practical directive:
#    drive auto-transitions with ADVANCE_MODE_AUTO; ENABLED produced no advance
#    in this rig." and "What ENABLED does require is not identified".
#
# Hypothesis under test: ENABLED+advance_condition is evaluated against the
# *parent blend tree's* parameter namespace, so it can only fire when the state
# machine is nested inside an AnimationNodeBlendTree; as the tree root the
# condition parameter is stored on the state machine itself and the check reads
# nothing.  Arms:
#   enabled_ctl      verbatim replay: SM root, ENABLED + cond "go", 76 frames
#   enabled_nested   SM nested in a blend tree ("sm"); cond written to both
#                    parameters/sm/conditions/go and parameters/conditions/go
#   enabled_atend    SM root, ENABLED + SWITCH_MODE_AT_END + cond
#   enabled_nocond   SM root, ENABLED with no advance_condition at all
#   enabled_early    SM root, ENABLED + cond true 2 frames into state a
#   enabled_pre      SM root, cond true before travel("a")
#   enabled_reapply  SM root, properties re-applied after add_transition
#   autocond         SM root, AUTO + cond (control)
#   stopstart        verbatim replay of the stop()/start() cell
#   traveldefer      verbatim replay of the travel() deferral cell

var case := "enabled_ctl"
var stage: Node3D
var actor: Node3D
var player: AnimationPlayer
var tree: AnimationTree
var sm: AnimationNodeStateMachine
var bt: AnimationNodeBlendTree
var pb: AnimationNodeStateMachinePlayback
var cond_path := "parameters/conditions/go"
var cond2_path := "parameters/sm/conditions/go"
var nested := false

class Watcher extends Node:
	var probe
	func _physics_process(_d: float) -> void:
		probe.on_phys()

func _initialize() -> void:
	call_deferred("_run")

func _watchdog() -> void:
	print("WATCHDOG_TIMEOUT case=%s" % case)
	quit(3)

func _run() -> void:
	var wd := Timer.new()
	wd.one_shot = true
	wd.wait_time = 15.0
	wd.timeout.connect(_watchdog)
	root.add_child(wd)
	wd.start()
	for x in OS.get_cmdline_user_args():
		if x.begins_with("--case="):
			case = x.substr(7)
	var w := Watcher.new()
	w.probe = self
	root.add_child(w)
	match case:
		"enabled_ctl": await c_enabled(AnimationNodeStateMachineTransition.ADVANCE_MODE_ENABLED, "go", false, false)
		"enabled_nested": await c_nested()
		"enabled_atend": await c_enabled(AnimationNodeStateMachineTransition.ADVANCE_MODE_ENABLED, "go", true, false)
		"enabled_nocond": await c_enabled(AnimationNodeStateMachineTransition.ADVANCE_MODE_ENABLED, "", false, false)
		"enabled_early": await c_early()
		"enabled_pre": await c_pre()
		"enabled_reapply": await c_reapply()
		"autocond": await c_enabled(AnimationNodeStateMachineTransition.ADVANCE_MODE_AUTO, "go", false, false)
		"next_enabled": await c_next(AnimationNodeStateMachineTransition.ADVANCE_MODE_ENABLED)
		"next_auto": await c_next(AnimationNodeStateMachineTransition.ADVANCE_MODE_AUTO)
		"next_path": await c_next_path()
		"autonocond": await c_autonocond()
		"condlate": await c_condlate(AnimationNodeStateMachineTransition.ADVANCE_MODE_AUTO)
		"condlate_enabled": await c_condlate(AnimationNodeStateMachineTransition.ADVANCE_MODE_ENABLED)
		"stopstart": await c_stopstart()
		"traveldefer": await c_traveldefer()
	print("SM_DONE case=%s" % case)
	quit(0)

# ---- helpers ---------------------------------------------------------------
func v3(v: Vector3) -> String:
	return "(%.4f,%.4f,%.4f)" % [v.x, v.y, v.z]

func tp() -> String:
	if tree == null or not is_instance_valid(tree) or tree.tree_root == null:
		return "-"
	var v: Variant = tree.get("parameters/current_position")
	if v == null:
		return "null"
	return "%.4f" % float(v)

func on_phys() -> void:
	pass

func condv() -> String:
	var v: Variant = tree.get(cond_path)
	return str(v)

func cond2v() -> String:
	if not nested:
		return "-"
	return str(tree.get(cond2_path))

func node_now() -> String:
	if pb == null:
		return "-"
	return str(pb.get_current_node())

func fade_now() -> String:
	if pb == null:
		return "-"
	return str(pb.get_fading_from_node())

func row() -> String:
	return "S pf=%d node=%s actor=%s tp=%s fading=%s cond=%s cond2=%s" % [
			Engine.get_physics_frames(), node_now(), v3(actor.global_position),
			tp(), fade_now(), condv(), cond2v()]

func frames(n: int) -> void:
	for i in range(n):
		await physics_frame
		print(row())

func anim_node(nm: String) -> AnimationNodeAnimation:
	var an := AnimationNodeAnimation.new()
	an.animation = nm
	return an

func mk(path: NodePath, v0: Vector3, v1: Vector3, length := 1.0) -> Animation:
	var a := Animation.new()
	a.length = length
	var t := a.add_track(Animation.TYPE_POSITION_3D)
	a.track_set_path(t, path)
	a.track_insert_key(t, 0.0, v0)
	a.track_insert_key(t, length, v1)
	return a

func build() -> void:
	stage = Node3D.new()
	stage.name = "Stage"
	root.add_child(stage)
	actor = Node3D.new()
	actor.name = "Actor"
	stage.add_child(actor)
	player = AnimationPlayer.new()
	player.name = "Player"
	player.root_node = NodePath("..")
	player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS
	stage.add_child(player)
	var lib := AnimationLibrary.new()
	lib.add_animation("a", mk(NodePath("Actor"), Vector3.ZERO, Vector3(4, 0, 0)))
	lib.add_animation("b", mk(NodePath("Actor"), Vector3.ZERO, Vector3(0, 4, 0)))
	player.add_animation_library("", lib)
	tree = AnimationTree.new()
	tree.name = "Tree"
	tree.process_callback = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS
	stage.add_child(tree)
	tree.anim_player = tree.get_path_to(player)

func sm_build(mode: int, cond: String, switch_mode: int,
		xfade := 0.0) -> AnimationNodeStateMachine:
	sm = AnimationNodeStateMachine.new()
	sm.add_node("a", anim_node("a"))
	sm.add_node("b", anim_node("b"))
	var tr := AnimationNodeStateMachineTransition.new()
	tr.advance_mode = mode
	if cond != "":
		tr.advance_condition = cond
	tr.switch_mode = switch_mode
	tr.xfade_time = xfade
	sm.add_transition("a", "b", tr)
	return sm

func link_root() -> void:
	nested = false
	cond_path = "parameters/conditions/go"
	tree.tree_root = sm
	pb = tree.get("parameters/playback")
	print("SM_LINK root=%s pb=%s nodes=%s params=%s" % [
			tree.tree_root.get_class(), pb, sm.get_node_list(),
			tree_params()])

func link_nested() -> void:
	nested = true
	cond_path = "parameters/sm/conditions/go"
	bt = AnimationNodeBlendTree.new()
	bt.add_node("sm", sm)
	bt.connect_node("output", 0, "sm")
	tree.tree_root = bt
	pb = tree.get("parameters/sm/playback")
	print("SM_LINK root=%s pb=%s nodes=%s params=%s" % [
			tree.tree_root.get_class(), pb, sm.get_node_list(),
			tree_params()])

func tree_params() -> String:
	var out: Array = []
	for p in tree.get_property_list():
		var n := str(p["name"])
		if n.begins_with("parameters/"):
			out.append(n)
	return "n=%d %s" % [out.size(), ",".join(out)]

# ---- enabled_ctl / enabled_atend / enabled_nocond / autocond ----------------
func c_enabled(mode: int, cond: String, at_end: bool, _x: bool) -> void:
	build()
	sm_build(mode, cond,
			AnimationNodeStateMachineTransition.SWITCH_MODE_AT_END if at_end
			else AnimationNodeStateMachineTransition.SWITCH_MODE_IMMEDIATE)
	link_root()
	print("SM_MODE mode=%d cond='%s' switch=%d" % [
			mode, cond, sm.get_transition(0).switch_mode])
	await physics_frame
	print("SM_PRE %s" % [row()])
	pb.travel("a")
	await frames(4)
	print("COL_ENTRY %s" % [row()])
	if cond != "":
		tree.set("parameters/conditions/go", true)
		print("COL_SET read=%s %s" % [tree.get("parameters/conditions/go"),
				row()])
	await frames(76)
	print("COL_END %s" % [row()])
	stage.free()

# ---- enabled_nested --------------------------------------------------------
func c_nested() -> void:
	build()
	sm_build(AnimationNodeStateMachineTransition.ADVANCE_MODE_ENABLED, "go",
			AnimationNodeStateMachineTransition.SWITCH_MODE_IMMEDIATE)
	link_nested()
	await physics_frame
	print("SM_PRE %s" % [row()])
	pb.travel("a")
	await frames(4)
	print("COL_ENTRY %s" % [row()])
	tree.set("parameters/sm/conditions/go", true)
	print("COL_SET_SM read=%s outer=%s %s" % [
			tree.get("parameters/sm/conditions/go"),
			tree.get("parameters/conditions/go"), row()])
	await frames(40)
	print("COL_END %s" % [row()])
	stage.free()

# ---- enabled_early: condition true while state a is still young ------------
func c_early() -> void:
	build()
	sm_build(AnimationNodeStateMachineTransition.ADVANCE_MODE_ENABLED, "go",
			AnimationNodeStateMachineTransition.SWITCH_MODE_IMMEDIATE)
	link_root()
	await physics_frame
	pb.travel("a")
	await frames(2)
	print("EARLY_ENTRY %s" % [row()])
	tree.set("parameters/conditions/go", true)
	await frames(30)
	print("EARLY_END %s" % [row()])
	stage.free()

# ---- enabled_pre: condition true before the travel -------------------------
func c_pre() -> void:
	build()
	sm_build(AnimationNodeStateMachineTransition.ADVANCE_MODE_ENABLED, "go",
			AnimationNodeStateMachineTransition.SWITCH_MODE_IMMEDIATE)
	link_root()
	await physics_frame
	tree.set("parameters/conditions/go", true)
	print("PRE_SET read=%s %s" % [tree.get("parameters/conditions/go"), row()])
	pb.travel("a")
	await frames(30)
	print("PRE_END %s" % [row()])
	stage.free()

# ---- enabled_reapply: re-apply the transition properties after add ---------
func c_reapply() -> void:
	build()
	sm_build(AnimationNodeStateMachineTransition.ADVANCE_MODE_ENABLED, "go",
			AnimationNodeStateMachineTransition.SWITCH_MODE_IMMEDIATE)
	var tr: AnimationNodeStateMachineTransition = sm.get_transition(0)
	tr.advance_condition = "go"
	tr.advance_mode = AnimationNodeStateMachineTransition.ADVANCE_MODE_ENABLED
	link_root()
	await physics_frame
	pb.travel("a")
	await frames(4)
	print("REAP_ENTRY %s" % [row()])
	tree.set("parameters/conditions/go", true)
	print("REAP_SET cond='%s' adv=%s %s" % [tr.advance_condition,
			tr.advance_mode, row()])
	await frames(40)
	print("REAP_END %s" % [row()])
	stage.free()

# ---- next_enabled / next_auto: the manual advance path ---------------------
func c_next(mode: int) -> void:
	build()
	sm_build(mode, "", AnimationNodeStateMachineTransition.SWITCH_MODE_IMMEDIATE)
	link_root()
	print("NX_MODE mode=%d" % mode)
	await physics_frame
	pb.travel("a")
	await frames(6)
	print("NX_BEFORE %s" % [row()])
	pb.next()
	print("NX_CALL_IMMEDIATE node=%s" % node_now())
	await frames(8)
	print("NX_AFTER %s" % [row()])
	stage.free()


# ---- autonocond: AUTO mode with no advance condition ----------------------
func c_autonocond() -> void:
	build()
	sm_build(AnimationNodeStateMachineTransition.ADVANCE_MODE_AUTO, "",
			AnimationNodeStateMachineTransition.SWITCH_MODE_IMMEDIATE)
	link_root()
	await physics_frame
	pb.travel("a")
	await frames(12)
	print("AN_END %s" % [row()])
	stage.free()


# ---- next_path: is next() a transition walk or a travel-path walk? ---------
func c_next_path() -> void:
	for mode in [AnimationNodeStateMachineTransition.ADVANCE_MODE_ENABLED,
			AnimationNodeStateMachineTransition.ADVANCE_MODE_AUTO]:
		build()
		sm = AnimationNodeStateMachine.new()
		sm.add_node("a", anim_node("a"))
		sm.add_node("b", anim_node("b"))
		sm.add_node("c", anim_node("a"))
		for pair in [["a", "b"], ["b", "c"]]:
			var tr := AnimationNodeStateMachineTransition.new()
			tr.advance_mode = mode
			sm.add_transition(pair[0], pair[1], tr)
		link_root()
		print("NP_NODES mode=%d %s ntr=%d" % [mode, sm.get_node_list(),
				sm.get_transition_count()])
		await physics_frame
		pb.travel("a")
		await frames(3)
		print("NP_AT_A mode=%d %s travel_path=%s" % [mode, row(),
				str(pb.get_travel_path())])
		pb.travel("c")
		await frames(3)
		print("NP_TRAVEL_C mode=%d %s travel_path=%s" % [mode, row(),
				str(pb.get_travel_path())])
		pb.next()
		print("NP_NEXT_IMMEDIATE mode=%d node=%s path=%s" % [mode, node_now(),
				str(pb.get_travel_path())])
		await frames(4)
		print("NP_AFTER mode=%d %s travel_path=%s" % [mode, row(),
				str(pb.get_travel_path())])
		stage.free()


# ---- condlate: a condition true while the tree is inactive ----------------
func c_condlate(mode: int) -> void:
	build()
	sm_build(mode, "go", AnimationNodeStateMachineTransition.SWITCH_MODE_IMMEDIATE)
	link_root()
	print("CL_MODE mode=%d" % mode)
	tree.active = false
	tree.set("parameters/conditions/go", true)
	pb.travel("a")
	await frames(4)
	print("CL_WRITE_INACTIVE cond=%s active=%s %s" % [
			tree.get("parameters/conditions/go"), tree.active, row()])
	await frames(6)
	print("CL_INACTIVE %s" % [row()])
	tree.active = true
	await frames(10)
	print("CL_ACTIVE %s" % [row()])
	stage.free()


# ---- stopstart (verbatim shape of the r99 scout cell) ----------------------
func c_stopstart() -> void:
	build()
	sm_build(AnimationNodeStateMachineTransition.ADVANCE_MODE_DISABLED, "",
			AnimationNodeStateMachineTransition.SWITCH_MODE_IMMEDIATE)
	link_root()
	await physics_frame
	pb.travel("b")
	await frames(6)
	print("SS_BEFORE %s" % [row()])
	pb.stop()
	print("SS_STOP_IMMEDIATE node=%s playing=%s" % [node_now(),
			pb.is_playing()])
	await frames(5)
	print("SS_STOPPED %s" % [row()])
	pb.start("b")
	print("SS_START_IMMEDIATE node=%s playing=%s" % [node_now(),
			pb.is_playing()])
	await frames(5)
	print("SS_AFTER %s" % [row()])
	stage.free()

# ---- traveldefer -----------------------------------------------------------
func c_traveldefer() -> void:
	build()
	sm_build(AnimationNodeStateMachineTransition.ADVANCE_MODE_DISABLED, "",
			AnimationNodeStateMachineTransition.SWITCH_MODE_IMMEDIATE)
	link_root()
	await physics_frame
	await frames(6)
	print("TV_BEFORE %s" % [row()])
	pb.travel("b")
	print("TV_CALL_IMMEDIATE node=%s" % node_now())
	await frames(6)
	print("TV_AFTER %s" % [row()])
	stage.free()
