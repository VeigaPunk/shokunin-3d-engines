extends SceneTree
# r99b probe F — the r99 scout §1.3/§4 silent-vs-error classes, replayed under
# --fixed-fps 60 on three backends.
#
# Claims under attack:
#   missing_anim  AnimationNodeAnimation.animation="ghost" -> completely silent,
#                 actor static, ZERO error/warning lines
#   parammiss     set("parameters/nope/amount") etc -> silent no-op, reads <null>
#   dupnode       AnimationNodeBlendTree.add_node twice -> ERROR nodes.has(...),
#                 node list unchanged
#   dupstate      AnimationNodeStateMachine.add_node twice -> same ERROR class
#   badstate      pb.travel("zzz") on a live playback -> silent

var case := "missing_anim"
var stage: Node3D
var actor: Node3D
var player: AnimationPlayer
var tree: AnimationTree
var bt: AnimationNodeBlendTree
var sm: AnimationNodeStateMachine

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
		"missing_anim": await c_missing_anim()
		"parammiss": await c_parammiss()
		"dupnode": await c_dupnode()
		"dupstate": await c_dupstate()
		"badstate": await c_badstate()
	print("SILENT_DONE case=%s" % case)
	quit(0)

func v3(v: Vector3) -> String:
	return "(%.4f,%.4f,%.4f)" % [v.x, v.y, v.z]

func on_phys() -> void:
	pass

func tps() -> String:
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

func frames(n: int) -> void:
	for i in range(n):
		await physics_frame

func c_missing_anim() -> void:
	build()
	var an := AnimationNodeAnimation.new()
	an.animation = "ghost"
	tree.tree_root = an
	await physics_frame
	await frames(12)
	print("MA_MISSING root=%s anim='%s' actor=%s tp=%s playing=%s" % [
			tree.tree_root.get_class(), an.animation,
			v3(actor.global_position), tps(), player.is_playing()])
	print("MA_MISSING_END ok=true")
	stage.free()

func c_parammiss() -> void:
	build()
	bt = AnimationNodeBlendTree.new()
	var na := AnimationNodeAnimation.new()
	na.animation = "a"
	var nb := AnimationNodeAnimation.new()
	nb.animation = "b"
	var b2 := AnimationNodeBlend2.new()
	bt.add_node("a", na)
	bt.add_node("b", nb)
	bt.add_node("blend", b2)
	bt.connect_node("blend", 0, "a")
	bt.connect_node("blend", 1, "b")
	bt.connect_node("output", 0, "blend")
	tree.tree_root = bt
	await physics_frame
	print("PM_GET_NOPE %s" % [tree.get("parameters/nope")])
	print("PM_GET_AMOUNT_NOPE %s" % [tree.get("parameters/nope/amount")])
	tree.set("parameters/nope/amount", 1.0)
	tree.set("parameters/blend/nope", 1.0)
	print("PM_READ_BACK nope=%s amount=%s" % [
			tree.get("parameters/nope/amount"),
			tree.get("parameters/blend/nope")])
	tree.set("parameters/blend/blend_amount", 0.5)
	print("PM_AFTER_WRITES blend=%s" % [
			tree.get("parameters/blend/blend_amount")])
	await frames(6)
	print("PM_ACTOR actor=%s tp=%s" % [v3(actor.global_position), tps()])
	print("PM_END ok=true")
	stage.free()

func c_dupnode() -> void:
	build()
	bt = AnimationNodeBlendTree.new()
	var an := AnimationNodeAnimation.new()
	an.animation = "a"
	bt.add_node("anim", an)
	var before := str(bt.get_node_list())
	var an2 := AnimationNodeAnimation.new()
	an2.animation = "b"
	bt.add_node("anim", an2)
	var after := str(bt.get_node_list())
	var keep: Variant = bt.get_node("anim")
	print("DN_DUP before=%s after=%s same_list=%s kept_anim='%s'" % [
			before, after, before == after, (keep as AnimationNodeAnimation).animation])
	print("DN_END ok=true")
	stage.free()

func c_dupstate() -> void:
	build()
	sm = AnimationNodeStateMachine.new()
	var a1 := AnimationNodeAnimation.new()
	a1.animation = "a"
	sm.add_node("a", a1)
	var before := str(sm.get_node_list())
	var a2 := AnimationNodeAnimation.new()
	a2.animation = "b"
	sm.add_node("a", a2)
	var after := str(sm.get_node_list())
	print("DS_DUP before=%s after=%s same_list=%s" % [before, after,
			before == after])
	print("DS_END ok=true")
	stage.free()

func c_badstate() -> void:
	build()
	sm = AnimationNodeStateMachine.new()
	sm.add_node("a", mk_an("a"))
	sm.add_node("b", mk_an("b"))
	tree.tree_root = sm
	var pb: AnimationNodeStateMachinePlayback = tree.get("parameters/playback")
	await physics_frame
	# phase 1: at Start, never travelled (not playing)
	print("BS_P1_BEFORE playing=%s node=%s" % [pb.is_playing(),
			str(pb.get_current_node())])
	pb.travel("zzz")
	print("BS_P1_AFTER_ZZZ playing=%s node=%s path=%s" % [pb.is_playing(),
			str(pb.get_current_node()), str(pb.get_travel_path())])
	await frames(3)
	# phase 2: after a real travel (playing)
	pb.travel("a")
	await frames(4)
	print("BS_P2_BEFORE playing=%s node=%s" % [pb.is_playing(),
			str(pb.get_current_node())])
	pb.travel("zzz")
	print("BS_P2_AFTER_ZZZ playing=%s node=%s path=%s" % [pb.is_playing(),
			str(pb.get_current_node()), str(pb.get_travel_path())])
	await frames(3)
	print("BS_END node=%s ok=true" % str(pb.get_current_node()))
	stage.free()

func mk_an(nm: String) -> AnimationNodeAnimation:
	var an := AnimationNodeAnimation.new()
	an.animation = nm
	return an
