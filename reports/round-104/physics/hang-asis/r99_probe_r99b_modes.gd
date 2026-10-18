extends SceneTree
# r99b probe B — the r99 scout §5 process_callback law and §1.2's
# "first two physics frames do not advance", under a --fixed-fps matrix.
#
# Claims under attack:
#   §5  "an AnimationTree cell must pin process_callback = PHYSICS; the default
#        IDLE makes the value at a fixed physics frame depend on how many
#        rendered frames the unthrottled headless scheduler granted"
#        -> is IDLE still rep-unstable under --fixed-fps 60/30/120?
#   §1.2 "the first two physics frames do not advance (tp=0.0000 at pf=2 and
#        pf=3)" -> count the leading non-advancing physics frames exactly,
#        from the first live row, per rate mode.
#
# Cases: phys idle manual phys_player_idle idle_player_phys
# Script args: --case=<c> --ticks=N (default 40)

var case := "phys"
var seq := 0
var ticks := 40
var watcher_after := false
var watcher: Node = null
var stage: Node3D
var actor: Node3D
var player: AnimationPlayer
var tree: AnimationTree
var rows: Array = []
var live := false
var x_pf10 := "-"
var x_pf20 := "-"
var x_pf30 := "-"
var t_pf30 := "-"
var x_idle10 := "-"
var x_idle20 := "-"
var idle_rows := 0
var pf_rows := 0
# leading-non-advance census (from the first live physics row)
var lead_zero := 0
var lead_done := false
var pf_first_move := -1
var pf_first_live := -1

class Watcher extends Node:
	var probe
	func _physics_process(_d: float) -> void:
		probe.on_phys()
	func _process(_d: float) -> void:
		probe.on_idle()

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
		elif x.begins_with("--ticks="):
			ticks = int(x.substr(8))
		elif x == "--watcher=post":
			watcher_after = true
	if not watcher_after:
		mk_watcher()
	match case:
		"phys": await c_run("phys")
		"idle": await c_run("idle")
		"phys_player_idle": await c_run("phys_player_idle")
		"idle_player_phys": await c_run("idle_player_phys")
		"manual": await c_manual()
	print("MODE_DONE case=%s" % case)
	quit(0)

func ppos_raw() -> float:
	# Guarded: an active tree assigns the player no current animation, so a raw
	# read raises an engine ERROR (r99 scout §1.2; replayed in probe D pposerr).
	if player == null or not is_instance_valid(player):
		return -1.0
	if String(player.current_animation) == "":
		return 0.0
	return player.current_animation_position

func v3(v: Vector3) -> String:
	return "(%.4f,%.4f,%.4f)" % [v.x, v.y, v.z]

func xnow() -> float:
	if actor == null or not is_instance_valid(actor):
		return -1.0
	return actor.global_position.x

func mk_watcher() -> void:
	var w := Watcher.new()
	w.probe = self
	root.add_child(w)
	watcher = w

func flush() -> void:
	for r in rows:
		print(r)
	rows.clear()

func on_phys() -> void:
	seq += 1
	pf_rows += 1
	if actor == null or not is_instance_valid(actor):
		return
	var pf := Engine.get_physics_frames()
	if pf_first_live < 0:
		pf_first_live = pf
	if live:
		rows.append("E pf=%d seq=%d x=%.4f actor=%s tp=%s" % [pf, seq,
				xnow(), v3(actor.global_position), tps()])
		if not lead_done:
			if xnow() == 0.0:
				lead_zero += 1
			else:
				lead_done = true
				pf_first_move = pf
	if x_pf10 == "-" and pf >= 10:
		x_pf10 = "%.4f" % xnow()
	if x_pf20 == "-" and pf >= 20:
		x_pf20 = "%.4f" % xnow()
	if x_pf30 == "-" and pf >= 30:
		x_pf30 = "%.4f" % xnow()
		t_pf30 = tps()

func on_idle() -> void:
	seq += 1
	idle_rows += 1
	if actor == null or not is_instance_valid(actor):
		return
	if live and idle_rows <= 10:
		rows.append("F seq=%d x=%.4f actor=%s tp=%s" % [seq, xnow(),
				v3(actor.global_position), tps()])
	if idle_rows == 10:
		x_idle10 = "%.4f" % xnow()
	if idle_rows == 20:
		x_idle20 = "%.4f" % xnow()

func tps() -> String:
	# the AnimationTree clock (parameters/current_position)
	if tree == null or not is_instance_valid(tree) or tree.tree_root == null:
		return "-"
	var v: Variant = tree.get("parameters/current_position")
	if v == null:
		return "null"
	return "%.4f" % float(v)

func mk(path: NodePath, v0: Vector3, v1: Vector3, length := 1.0) -> Animation:
	var a := Animation.new()
	a.length = length
	var t := a.add_track(Animation.TYPE_POSITION_3D)
	a.track_set_path(t, path)
	a.track_insert_key(t, 0.0, v0)
	a.track_insert_key(t, length, v1)
	return a

func build(tcb: int, pcb: int) -> void:
	stage = Node3D.new()
	stage.name = "Stage"
	root.add_child(stage)
	actor = Node3D.new()
	actor.name = "Actor"
	stage.add_child(actor)
	player = AnimationPlayer.new()
	player.name = "Player"
	player.root_node = NodePath("..")
	player.callback_mode_process = pcb
	stage.add_child(player)
	var lib := AnimationLibrary.new()
	lib.add_animation("a", mk(NodePath("Actor"), Vector3.ZERO, Vector3(4, 0, 0)))
	player.add_animation_library("", lib)
	tree = AnimationTree.new()
	tree.name = "Tree"
	tree.process_callback = tcb
	stage.add_child(tree)
	tree.anim_player = tree.get_path_to(player)
	var bt := AnimationNodeBlendTree.new()
	var an := AnimationNodeAnimation.new()
	an.animation = "a"
	bt.add_node("anim", an)
	bt.connect_node("output", 0, "anim")
	tree.tree_root = bt
	if watcher_after:
		mk_watcher()

func summary(tag: String) -> void:
	print("MODE_SUM case=%s tag=%s watcher=%s tree_cb=%d player_cb=%d x_pf10=%s x_pf20=%s x_pf30=%s t_pf30=%s x_idle10=%s x_idle20=%s idle_rows=%d pf_rows=%d lead_zero=%d pf_first_live=%d pf_first_move=%d active=%s pactive=%s" % [
			case, tag, "post" if watcher_after else "pre",
			tree.process_callback, player.callback_mode_process,
			x_pf10, x_pf20, x_pf30, t_pf30, x_idle10, x_idle20,
			idle_rows, pf_rows, lead_zero, pf_first_live, pf_first_move,
			tree.active, player.active])

func c_run(kind: String) -> void:
	var tcb := AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS
	var pcb := AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS
	match kind:
		"idle":
			tcb = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_IDLE
		"phys_player_idle":
			pcb = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_IDLE
		"idle_player_phys":
			tcb = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_IDLE
	build(tcb, pcb)
	print("MODE_PRE case=%s tree_cb=%d player_cb=%d active=%s pactive=%s playing=%s pf=%d" % [
			kind, tree.process_callback, player.callback_mode_process,
			tree.active, player.active, player.is_playing(),
			Engine.get_physics_frames()])
	live = true
	for i in range(ticks):
		await physics_frame
	live = false
	flush()
	summary("end")
	print("MODE_POST case=%s actor=%s t=%.4f playing=%s pactive=%s" % [kind,
			v3(actor.global_position), ppos_raw(),
			player.is_playing(), player.active])
	stage.free()

func c_manual() -> void:
	build(AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL,
			AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS)
	print("MA_PRE tree_cb=%d active=%s actor=%s pf=%d" % [tree.process_callback,
			tree.active, v3(actor.global_position),
			Engine.get_physics_frames()])
	live = true
	for i in range(6):
		await physics_frame
	live = false
	flush()
	print("MA_IDLE actor=%s t=%.4f" % [v3(actor.global_position), ppos_raw()])
	tree.advance(0.25)
	print("MA_ADV1 actor=%s t=%.4f" % [v3(actor.global_position), ppos_raw()])
	await physics_frame
	print("MA_ADV1_FRAME actor=%s t=%.4f" % [v3(actor.global_position),
			ppos_raw()])
	tree.advance(0.25)
	print("MA_ADV2 actor=%s t=%.4f" % [v3(actor.global_position), ppos_raw()])
	summary("manual")
	stage.free()
