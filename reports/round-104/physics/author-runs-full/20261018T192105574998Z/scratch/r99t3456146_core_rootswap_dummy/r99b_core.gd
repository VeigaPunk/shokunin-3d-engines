extends SceneTree
# r99b probe D — verbatim replays of the r99 scout §1.1/§1.2/§2/§3 cells under
# --fixed-fps 60, plus the §1.2 player-position error claim.
#
# Cases:
#   wire       connect_node argument order: provider-first (rejected) vs
#              receiver-first (works)  [§1.1]
#   min        minimal tree, per-frame pf/tp/x relation: is the pose exactly
#              4 u/s of the tree clock, frame by frame?  [§1.2]
#   blend2     AnimationNodeBlend2 blend_amount 0/0.5/1 + read-back  [§2]
#   timescale  AnimationNodeTimeScale scale 1->2, dtp over 8 physics frames [§2]
#   rootswap   tree_root replaced mid-run: pose cut, clock continues  [§2]
#   body       the tree's write to a frozen RigidBody3D reaches the server [§3]
#   pposerr    player.current_animation_position under an active tree [§1.2]

var case := "min"
var stage: Node3D
var stage2: Node3D
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
		"wire": await c_wire()
		"min": await c_min()
		"blend2": await c_blend2()
		"timescale": await c_timescale()
		"rootswap": await c_rootswap()
		"body": await c_body()
		"pposerr": await c_pposerr()
	print("CORE_DONE case=%s" % case)
	quit(0)

# ---- helpers ---------------------------------------------------------------
func v3(v: Vector3) -> String:
	return "(%.4f,%.4f,%.4f)" % [v.x, v.y, v.z]

func srv(n: Node3D) -> String:
	var v: Variant = PhysicsServer3D.body_get_state(n.get_rid(),
			PhysicsServer3D.BODY_STATE_TRANSFORM)
	if v == null:
		return "nil"
	return v3((v as Transform3D).origin)

func tp() -> float:
	if tree == null or not is_instance_valid(tree) or tree.tree_root == null:
		return -1.0
	var v: Variant = tree.get("parameters/current_position")
	if v == null:
		return -2.0
	return float(v)

func tps() -> String:
	return "%.4f" % tp()

func on_phys() -> void:
	pass

func mk(path: NodePath, v0: Vector3, v1: Vector3, length := 1.0) -> Animation:
	var a := Animation.new()
	a.length = length
	var t := a.add_track(Animation.TYPE_POSITION_3D)
	a.track_set_path(t, path)
	a.track_insert_key(t, 0.0, v0)
	a.track_insert_key(t, length, v1)
	return a

func mk2(a0: Vector3, a1: Vector3, b0: Vector3, b1: Vector3,
		length := 1.0) -> Animation:
	var a := Animation.new()
	a.length = length
	var t := a.add_track(Animation.TYPE_POSITION_3D)
	a.track_set_path(t, NodePath("Actor"))
	a.track_insert_key(t, 0.0, a0)
	a.track_insert_key(t, length, a1)
	var t2 := a.add_track(Animation.TYPE_POSITION_3D)
	a.track_set_path(t2, NodePath("Ball"))
	a.track_insert_key(t2, 0.0, b0)
	a.track_insert_key(t2, length, b1)
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
	lib.add_animation("b", mk(NodePath("Actor"), Vector3.ZERO, Vector3(0, 4, 0)))
	lib.add_animation("ab", mk2(Vector3.ZERO, Vector3(4, 0, 0),
			Vector3(0, 3, 0), Vector3(4, 3, 0)))
	player.add_animation_library("", lib)
	tree = AnimationTree.new()
	tree.name = "Tree"
	tree.process_callback = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS
	stage.add_child(tree)
	tree.anim_player = tree.get_path_to(player)

func bt_one(nm: String) -> AnimationNodeBlendTree:
	var t := AnimationNodeBlendTree.new()
	var an := AnimationNodeAnimation.new()
	an.animation = nm
	t.add_node("anim", an)
	t.connect_node("output", 0, "anim")
	return t

# ---- wire ------------------------------------------------------------------
func c_wire() -> void:
	build()
	# arm A: provider-first (the form the scout measured as rejected)
	var ta := AnimationNodeBlendTree.new()
	var ana := AnimationNodeAnimation.new()
	ana.animation = "a"
	ta.add_node("anim", ana)
	print("WIRE_A_CALL connect_node(\"anim\", 0, \"output\")")
	ta.connect_node("anim", 0, "output")
	tree.tree_root = ta
	await physics_frame
	print("WIRE_A_FRAME1 actor=%s tp=%s" % [v3(actor.global_position), tps()])
	for i in range(8):
		await physics_frame
	print("WIRE_A_END actor=%s tp=%s" % [v3(actor.global_position), tps()])
	# arm B: receiver-first
	var tb := AnimationNodeBlendTree.new()
	var anb := AnimationNodeAnimation.new()
	anb.animation = "a"
	tb.add_node("anim", anb)
	tb.connect_node("output", 0, "anim")
	tree.tree_root = tb
	await physics_frame
	print("WIRE_B_FRAME1 actor=%s tp=%s" % [v3(actor.global_position), tps()])
	for i in range(8):
		await physics_frame
	print("WIRE_B_END actor=%s tp=%s" % [v3(actor.global_position), tps()])
	stage.free()

# ---- min -------------------------------------------------------------------
func c_min() -> void:
	build()
	tree.tree_root = bt_one("ab")
	print("MIN_PRE pf=%d actor=%s ball=%s srv=%s tp=%s" % [
			Engine.get_physics_frames(), v3(actor.global_position),
			v3(ball.global_position), srv(ball), tps()])
	for i in range(34):
		await physics_frame
		var t := tp()
		var x := actor.global_position.x
		print("E pf=%d x=%.4f tp=%.4f x4tp=%.4f d=%.4f ball=%s" % [
				Engine.get_physics_frames(), x, t, 4.0 * t, x - 4.0 * t,
				v3(ball.global_position)])
	print("MIN_POST actor=%s ball=%s srv=%s tp=%s" % [v3(actor.global_position),
			v3(ball.global_position), srv(ball), tps()])
	stage.free()

# ---- blend2 ----------------------------------------------------------------
func c_blend2() -> void:
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
	for w in [0.0, 0.25, 0.5, 0.75, 1.0]:
		tree.set("parameters/blend/blend_amount", w)
		print("BL_SET w=%.2f read=%.4f" % [w,
				tree.get("parameters/blend/blend_amount")])
		for i in range(4):
			await physics_frame
		print("BL_ROW w=%.2f tp=%s actor=%s" % [w, tps(),
				v3(actor.global_position)])
	print("BL_END tp=%s actor=%s" % [tps(), v3(actor.global_position)])
	stage.free()

# ---- timescale -------------------------------------------------------------
func c_timescale() -> void:
	build()
	bt = AnimationNodeBlendTree.new()
	var an := AnimationNodeAnimation.new()
	an.animation = "a"
	var ts := AnimationNodeTimeScale.new()
	bt.add_node("anim", an)
	bt.add_node("ts", ts)
	bt.connect_node("ts", 0, "anim")
	bt.connect_node("output", 0, "ts")
	tree.tree_root = bt
	await physics_frame
	for i in range(6):
		await physics_frame
	var t0 := tp()
	print("TS_BEFORE tp=%.4f actor=%s scale=%s" % [t0,
			v3(actor.global_position), str(tree.get("parameters/ts/scale"))])
	tree.set("parameters/ts/scale", 2.0)
	print("TS_SET read=%s" % str(tree.get("parameters/ts/scale")))
	for i in range(8):
		await physics_frame
	var t1 := tp()
	print("TS_AFTER tp=%.4f actor=%s dtp=%.4f expect=%.4f" % [t1,
			v3(actor.global_position), t1 - t0, 2.0 * 8.0 / 60.0])
	stage.free()

# ---- rootswap --------------------------------------------------------------
func c_rootswap() -> void:
	build()
	tree.tree_root = bt_one("a")
	await physics_frame
	for i in range(9):
		await physics_frame
	print("RS_BEFORE actor=%s tp=%s" % [v3(actor.global_position), tps()])
	var bt2 := AnimationNodeBlendTree.new()
	var an2 := AnimationNodeAnimation.new()
	an2.animation = "b"
	bt2.add_node("anim", an2)
	bt2.connect_node("output", 0, "anim")
	tree.tree_root = bt2
	print("RS_ASSIGN root=%s tp=%s" % [tree.tree_root.get_class(), tps()])
	await physics_frame
	print("RS_FRAME1 actor=%s tp=%s" % [v3(actor.global_position), tps()])
	for i in range(8):
		await physics_frame
	print("RS_AFTER actor=%s tp=%s" % [v3(actor.global_position), tps()])
	stage.free()

# ---- body ------------------------------------------------------------------
func c_body() -> void:
	build()
	tree.tree_root = bt_one("ab")
	await physics_frame
	print("BD_PRE actor=%s ball=%s srv=%s tp=%s" % [v3(actor.global_position),
			v3(ball.global_position), srv(ball), tps()])
	for i in range(20):
		await physics_frame
		print("E pf=%d actor=%s ball=%s srv=%s tp=%s" % [
				Engine.get_physics_frames(), v3(actor.global_position),
				v3(ball.global_position), srv(ball), tps()])
	print("BD_POST actor=%s ball=%s srv=%s frozen=%s tp=%s" % [
			v3(actor.global_position), v3(ball.global_position), srv(ball),
			ball.freeze, tps()])
	stage.free()

# ---- pposerr ---------------------------------------------------------------
func c_pposerr() -> void:
	build()
	tree.tree_root = bt_one("a")
	await physics_frame
	for i in range(6):
		await physics_frame
	print("PP_PRE active=%s playing=%s anim='%s' tp=%s" % [tree.active,
			player.is_playing(), player.current_animation, tps()])
	print("PP_RAW_READ (engine ERROR expected: no current animation assigned)")
	var v := player.current_animation_position
	print("PP_RAW_VALUE %.4f" % v)
	print("PP_AFTER anim='%s' playing=%s tp=%s" % [player.current_animation,
			player.is_playing(), tps()])
	stage.free()
