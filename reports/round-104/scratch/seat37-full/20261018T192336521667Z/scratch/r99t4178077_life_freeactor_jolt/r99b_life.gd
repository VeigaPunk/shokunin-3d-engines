extends SceneTree
# r99b probe E — the r99 scout §6 lifecycle/teardown pins, replayed under
# --fixed-fps 60 with 6 reps (the r90 bimodal lesson) on three backends.
#
# Claims under attack:
#   freetree    freeing the tree freezes the pose, no error, no crash
#   freeplayer  "the tree keeps animating after the AnimationPlayer is freed"
#   freeactor   freeing the animated target is silent and harmless
#   rootnull    nulling the root freezes at the last pose (no reset to default)
#   activeoff   active=false freezes; active=true resumes from the same pose
#   clsloop     r97-style instantiate+free of every AnimationNode* class
#               (32/32) - the r97 XRServer SIGSEGV class did not reproduce for
#               animation objects; replayed 20x per class under load

var case := "freetree"
var stage: Node3D
var actor: Node3D
var ball: RigidBody3D
var player: AnimationPlayer
var tree: AnimationTree
var bt: AnimationNodeBlendTree

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
		"freetree": await c_freetree()
		"freeplayer": await c_freeplayer()
		"freeactor": await c_freeactor()
		"rootnull": await c_rootnull()
		"activeoff": await c_activeoff()
		"clsloop": await c_clsloop()
	print("LIFE_DONE case=%s" % case)
	quit(0)

func v3(v: Vector3) -> String:
	return "(%.4f,%.4f,%.4f)" % [v.x, v.y, v.z]

func on_phys() -> void:
	pass

func srv(n: Node3D) -> String:
	if n == null or not is_instance_valid(n):
		return "invalid"
	var v: Variant = PhysicsServer3D.body_get_state(n.get_rid(),
			PhysicsServer3D.BODY_STATE_TRANSFORM)
	if v == null:
		return "nil"
	return v3((v as Transform3D).origin)

func tps() -> String:
	if tree == null or not is_instance_valid(tree) or tree.tree_root == null:
		return "-"
	var v: Variant = tree.get("parameters/current_position")
	if v == null:
		return "null"
	return "%.4f" % float(v)

func pos(n: Node3D) -> String:
	if n == null or not is_instance_valid(n):
		return "invalid"
	return v3(n.global_position)

func frames(n: int) -> void:
	for i in range(n):
		await physics_frame

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
	ball = RigidBody3D.new()
	ball.name = "Ball"
	ball.freeze = true
	ball.can_sleep = false
	ball.position = Vector3(0, 3, 0)
	stage.add_child(ball)
	var cs := CollisionShape3D.new()
	var sp := SphereShape3D.new()
	sp.radius = 0.2
	cs.shape = sp
	ball.add_child(cs)
	player = AnimationPlayer.new()
	player.name = "Player"
	player.root_node = NodePath("..")
	player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS
	stage.add_child(player)
	var lib := AnimationLibrary.new()
	lib.add_animation("a", mk(NodePath("Actor"), Vector3.ZERO, Vector3(4, 0, 0)))
	player.add_animation_library("", lib)
	tree = AnimationTree.new()
	tree.name = "Tree"
	tree.process_callback = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS
	stage.add_child(tree)
	tree.anim_player = tree.get_path_to(player)
	bt = AnimationNodeBlendTree.new()
	var an := AnimationNodeAnimation.new()
	an.animation = "a"
	bt.add_node("anim", an)
	bt.connect_node("output", 0, "anim")
	tree.tree_root = bt

# ---- arms ------------------------------------------------------------------
func c_freetree() -> void:
	build()
	await physics_frame
	await frames(7)
	print("FT_BEFORE actor=%s tp=%s" % [pos(actor), tps()])
	tree.free()
	tree = null
	print("FT_FREED tree_invalid=%s pactive=%s" % [
			not is_instance_valid(tree), player.active])
	await frames(8)
	print("FT_AFTER actor=%s tp=%s" % [pos(actor), tps()])
	stage.free()

func c_freeplayer() -> void:
	build()
	await physics_frame
	await frames(7)
	print("FP_BEFORE actor=%s tp=%s" % [pos(actor), tps()])
	player.free()
	player = null
	print("FP_FREED player_invalid=%s" % [not is_instance_valid(player)])
	await frames(8)
	print("FP_AFTER actor=%s tp=%s" % [pos(actor), tps()])
	stage.free()

func c_freeactor() -> void:
	build()
	await physics_frame
	await frames(7)
	print("FA_BEFORE actor=%s tp=%s" % [pos(actor), tps()])
	actor.free()
	actor = null
	print("FA_FREED actor_invalid=%s" % [not is_instance_valid(actor)])
	await frames(8)
	print("FA_AFTER actor=%s tp=%s" % [pos(actor), tps()])
	stage.free()

func c_rootnull() -> void:
	build()
	await physics_frame
	await frames(7)
	print("TN_BEFORE actor=%s tp=%s" % [pos(actor), tps()])
	tree.tree_root = null
	print("TN_NULLED root=%s" % str(tree.tree_root))
	await frames(8)
	print("TN_AFTER actor=%s tp=%s" % [pos(actor), tps()])
	stage.free()

func c_activeoff() -> void:
	build()
	await physics_frame
	await frames(7)
	print("AO_BEFORE actor=%s tp=%s" % [pos(actor), tps()])
	tree.active = false
	await frames(6)
	print("AO_OFF actor=%s tp=%s active=%s" % [pos(actor), tps(), tree.active])
	tree.active = true
	await frames(8)
	print("AO_ON actor=%s tp=%s active=%s" % [pos(actor), tps(), tree.active])
	stage.free()

func c_clsloop() -> void:
	# the r99 scout's 32-class candidate list, verbatim
	var names := [
		"AnimationTree", "AnimationMixer", "AnimationPlayer", "Animation",
		"AnimationLibrary",
		"AnimationNode", "AnimationRootNode",
		"AnimationNodeAnimation", "AnimationNodeBlendTree", "AnimationNodeBlend2",
		"AnimationNodeBlend3", "AnimationNodeAdd2", "AnimationNodeAdd3",
		"AnimationNodeSub2", "AnimationNodeMix", "AnimationNodeMix2",
		"AnimationNodeMix3", "AnimationNodeSync", "AnimationNodeOutput",
		"AnimationNodeOneShot", "AnimationNodeTransition",
		"AnimationNodeTimeScale", "AnimationNodeTimeSeek",
		"AnimationNodeBlendSpace1D", "AnimationNodeBlendSpace2D",
		"AnimationNodeStateMachine", "AnimationNodeStateMachinePlayback",
		"AnimationNodeStateMachineTransition", "AnimationNodeExtension",
	]
	var made := 0
	var skipped := 0
	for rnd in range(20):
		for nm in names:
			if not ClassDB.class_exists(nm) or not ClassDB.can_instantiate(nm):
				skipped += 1
				continue
			var o: Object = ClassDB.instantiate(nm)
			if o == null:
				skipped += 1
				continue
			made += 1
			if o is RefCounted:
				(o as RefCounted).unreference()
			else:
				o.free()
	print("CLS_LOOP made=%d skipped=%d rounds=20 names=%d" % [made, skipped,
			names.size()])
	print("CLS_LOOP_ALIVE ok=true")
