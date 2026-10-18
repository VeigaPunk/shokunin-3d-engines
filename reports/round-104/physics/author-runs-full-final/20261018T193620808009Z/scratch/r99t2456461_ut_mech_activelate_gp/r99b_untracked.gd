extends SceneTree
# r99b probe A — falsify / bound the r99 scout §1.4 headline.
#
# Claim under attack: "When the playing animation does not drive a path that
# exists anywhere in the AnimationPlayer's library, the tree writes the track
# type's default (Vector3.ZERO for TYPE_POSITION_3D) to that path on its first
# process."  Scout open question: library-wide path set vs per-path cache.
#
# Arms (--case=):
#   ctl          replay: lib {a,b,ab}, tree plays "a"   -> scout: Ball 3->0
#   libclean     lib {a} only                           -> scout: Ball stays 3
#   orphan       lib {a}; Ball track only in a never-added Animation (kept alive)
#   otherplayer  lib {a}; Ball track only in a *second* AnimationPlayer's lib
#   namedlib     lib {a} + named library "extra" holding a Ball-track animation
#   typedef      lib {a,sr}; sr = Ball SCALE(2,2,2)+ROT(90deg) tracks; Ball
#                preset scale (3,3,3) / rot 45deg -> which default is written?
#   keyless      lib {a,k}; k = KEYLESS Ball position track (r92 empty_track)
#   notree       no AnimationTree at all; plain player.play("a") on lib {a,b,ab}
#   inactive     tree.active=false, lib {a,b,ab}
#   manual       tree process_callback=MANUAL, lib {a,b,ab}, no advance() then one
#   activelate   tree.active=false -> true at pf=6, lib {a,b,ab}
#   ballonly     lib {a,bb}; bb drives only Ball (no Actor path)
#   ghostpath    lib {a,g}; g's track path is "Ghost" (nonexistent node)
#   repeat       lib {a,b,ab}; Ball restored to (0,3,0) at pf=8 -> snap back?
#
# Deterministic arms: run with `--fixed-fps 60` (r100 scout: byte-stable).

var case := "ctl"
var stage: Node3D
var actor: Node3D
var ball: RigidBody3D
var player: AnimationPlayer
var player2: AnimationPlayer
var tree: AnimationTree
var keep: Array = []

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
		"ctl": await a_ctl()
		"libclean": await a_libclean()
		"orphan": await a_orphan()
		"otherplayer": await a_otherplayer()
		"namedlib": await a_namedlib()
		"typedef": await a_typedef()
		"keyless": await a_keyless()
		"notree": await a_notree()
		"inactive": await a_inactive()
		"manual": await a_manual()
		"activelate": await a_activelate()
		"ballonly": await a_ballonly()
		"ghostpath": await a_ghostpath()
		"repeat": await a_repeat()
	print("UT_DONE case=%s" % case)
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

func tp() -> String:
	if tree == null or not is_instance_valid(tree) or tree.tree_root == null:
		return "-"
	var v: Variant = tree.get("parameters/current_position")
	if v == null:
		return "null"
	return "%.4f" % float(v)

func on_phys() -> void:
	pass

func row(extra := "") -> String:
	return "E pf=%d actor=%s ball=%s srv=%s tp=%s%s" % [
			Engine.get_physics_frames(), v3(actor.global_position),
			v3(ball.global_position), srv(ball), tp(), extra]

func frames(n: int, extra := false) -> void:
	for i in range(n):
		await physics_frame
		if extra:
			print(row(" sc=%s rotY=%.2f" % [v3(ball.scale),
					ball.rotation_degrees.y]))
		else:
			print(row())

func anim_pos(path: NodePath, v0: Vector3, v1: Vector3,
		length := 1.0, keyless := false) -> Animation:
	var a := Animation.new()
	a.length = length
	var t := a.add_track(Animation.TYPE_POSITION_3D)
	a.track_set_path(t, path)
	if not keyless:
		a.track_insert_key(t, 0.0, v0)
		a.track_insert_key(t, length, v1)
	return a

func anim_ab() -> Animation:
	var a := Animation.new()
	a.length = 1.0
	var t := a.add_track(Animation.TYPE_POSITION_3D)
	a.track_set_path(t, NodePath("Actor"))
	a.track_insert_key(t, 0.0, Vector3.ZERO)
	a.track_insert_key(t, 1.0, Vector3(4, 0, 0))
	var t2 := a.add_track(Animation.TYPE_POSITION_3D)
	a.track_set_path(t2, NodePath("Ball"))
	a.track_insert_key(t2, 0.0, Vector3(0, 3, 0))
	a.track_insert_key(t2, 1.0, Vector3(4, 3, 0))
	return a

func lib_a() -> AnimationLibrary:
	var lib := AnimationLibrary.new()
	lib.add_animation("a", anim_pos(NodePath("Actor"), Vector3.ZERO,
			Vector3(4, 0, 0)))
	return lib

func lib_std() -> AnimationLibrary:
	var lib := AnimationLibrary.new()
	lib.add_animation("a", anim_pos(NodePath("Actor"), Vector3.ZERO,
			Vector3(4, 0, 0)))
	lib.add_animation("b", anim_pos(NodePath("Actor"), Vector3.ZERO,
			Vector3(0, 4, 0)))
	lib.add_animation("ab", anim_ab())
	return lib

func build(with_tree := true,
		cb := AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS) -> void:
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
	if with_tree:
		tree = AnimationTree.new()
		tree.name = "Tree"
		tree.process_callback = cb
		stage.add_child(tree)
		tree.anim_player = tree.get_path_to(player)

func root_one(nm: String) -> AnimationNodeAnimation:
	var an := AnimationNodeAnimation.new()
	an.animation = nm
	return an

func head(arm: String) -> void:
	print("ARM %s lib=%s tree=%s active=%s cb=%d" % [arm,
			player.get_animation_list(),
			tree != null and is_instance_valid(tree),
			tree.active if tree != null and is_instance_valid(tree) else "-",
			tree.process_callback if tree != null and is_instance_valid(tree) else -1])
	print("PRE pf=%d actor=%s ball=%s srv=%s tp=%s" % [
			Engine.get_physics_frames(), v3(actor.global_position),
			v3(ball.global_position), srv(ball), tp()])

func post(arm: String) -> void:
	print("POST %s actor=%s ball=%s srv=%s tp=%s" % [arm,
			v3(actor.global_position), v3(ball.global_position), srv(ball),
			tp()])

# ---- arms ------------------------------------------------------------------
func a_ctl() -> void:
	build()
	player.add_animation_library("", lib_std())
	tree.tree_root = root_one("a")
	head("ctl")
	await physics_frame
	await frames(10)
	post("ctl")
	stage.free()

func a_libclean() -> void:
	build()
	player.add_animation_library("", lib_a())
	tree.tree_root = root_one("a")
	head("libclean")
	await physics_frame
	await frames(10)
	post("libclean")
	stage.free()

func a_orphan() -> void:
	build()
	player.add_animation_library("", lib_a())
	var c := anim_ab()          # Ball track, never added to any library
	keep.append(c)
	tree.tree_root = root_one("a")
	head("orphan")
	print("ORPHAN_ANIM_ALIVE %s tracks=%d" % [c, c.get_track_count()])
	await physics_frame
	await frames(10)
	post("orphan")
	stage.free()

func a_otherplayer() -> void:
	build()
	player.add_animation_library("", lib_a())
	player2 = AnimationPlayer.new()
	player2.name = "Player2"
	player2.root_node = NodePath("..")
	player2.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS
	stage.add_child(player2)
	var l2 := AnimationLibrary.new()
	l2.add_animation("abx", anim_ab())
	player2.add_animation_library("", l2)
	tree.tree_root = root_one("a")
	head("otherplayer")
	print("OTHERPLAYER_LIB %s playing=%s" % [player2.get_animation_list(),
			player2.is_playing()])
	await physics_frame
	await frames(10)
	post("otherplayer")
	stage.free()

func a_namedlib() -> void:
	build()
	player.add_animation_library("", lib_a())
	var l2 := AnimationLibrary.new()
	l2.add_animation("abx", anim_ab())
	player.add_animation_library("extra", l2)
	tree.tree_root = root_one("a")
	head("namedlib")
	await physics_frame
	await frames(10)
	post("namedlib")
	stage.free()

func a_typedef() -> void:
	build()
	var lib := AnimationLibrary.new()
	lib.add_animation("a", anim_pos(NodePath("Actor"), Vector3.ZERO,
			Vector3(4, 0, 0)))
	var sr := Animation.new()
	sr.length = 1.0
	var ts := sr.add_track(Animation.TYPE_SCALE_3D)
	sr.track_set_path(ts, NodePath("Ball"))
	sr.track_insert_key(ts, 0.0, Vector3(2, 2, 2))
	sr.track_insert_key(ts, 1.0, Vector3(2, 2, 2))
	var tr := sr.add_track(Animation.TYPE_ROTATION_3D)
	sr.track_set_path(tr, NodePath("Ball"))
	sr.track_insert_key(tr, 0.0, Quaternion(Vector3.UP, deg_to_rad(90.0)))
	sr.track_insert_key(tr, 1.0, Quaternion(Vector3.UP, deg_to_rad(90.0)))
	lib.add_animation("sr", sr)
	player.add_animation_library("", lib)
	ball.scale = Vector3(3, 3, 3)
	ball.rotation_degrees = Vector3(0, 45, 0)
	tree.tree_root = root_one("a")
	head("typedef")
	print("TYPEDEF_PRESET sc=%s rotY=%.2f" % [v3(ball.scale),
			ball.rotation_degrees.y])
	await physics_frame
	await frames(10, true)
	post("typedef")
	print("TYPEDEF_POST sc=%s rotY=%.2f" % [v3(ball.scale),
			ball.rotation_degrees.y])
	stage.free()

func a_keyless() -> void:
	build()
	var lib := lib_a()
	lib.add_animation("k", anim_pos(NodePath("Ball"), Vector3.ZERO,
			Vector3.ZERO, 1.0, true))
	player.add_animation_library("", lib)
	tree.tree_root = root_one("a")
	head("keyless")
	print("KEYLESS_KEYS %d" % lib.get_animation("k").get_track_count())
	await physics_frame
	await frames(10)
	post("keyless")
	stage.free()

func a_notree() -> void:
	build(false)
	player.add_animation_library("", lib_std())
	head("notree")
	player.play("a")
	print("NOTREE_PLAYING %s anim=%s" % [player.is_playing(),
			player.current_animation])
	await physics_frame
	await frames(10)
	post("notree")
	stage.free()

func a_inactive() -> void:
	build()
	player.add_animation_library("", lib_std())
	tree.tree_root = root_one("a")
	tree.active = false
	head("inactive")
	await physics_frame
	await frames(10)
	post("inactive")
	stage.free()

func a_manual() -> void:
	build(true, AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL)
	player.add_animation_library("", lib_std())
	tree.tree_root = root_one("a")
	head("manual")
	await physics_frame
	await frames(8)
	post("manual_no_advance")
	tree.advance(0.1)
	print("MANUAL_ADV_NOW actor=%s ball=%s srv=%s tp=%s" % [
			v3(actor.global_position), v3(ball.global_position), srv(ball),
			tp()])
	await frames(4)
	post("manual_after_advance")
	stage.free()

func a_activelate() -> void:
	build()
	player.add_animation_library("", lib_std())
	tree.tree_root = root_one("a")
	tree.active = false
	head("activelate")
	await physics_frame
	await frames(6)
	print("AL_BEFORE_ACTIVATE ball=%s srv=%s tp=%s" % [v3(ball.global_position),
			srv(ball), tp()])
	tree.active = true
	print("AL_ACTIVATED ball=%s tp=%s" % [v3(ball.global_position), tp()])
	await frames(8)
	post("activelate")
	stage.free()

func a_ballonly() -> void:
	build()
	var lib := lib_a()
	lib.add_animation("bb", anim_pos(NodePath("Ball"), Vector3(0, 3, 0),
			Vector3(4, 3, 0)))
	player.add_animation_library("", lib)
	tree.tree_root = root_one("a")
	head("ballonly")
	await physics_frame
	await frames(10)
	post("ballonly")
	stage.free()

func a_ghostpath() -> void:
	build()
	var lib := lib_a()
	lib.add_animation("g", anim_pos(NodePath("Ghost"), Vector3.ZERO,
			Vector3(9, 9, 9)))
	player.add_animation_library("", lib)
	tree.tree_root = root_one("a")
	head("ghostpath")
	await physics_frame
	await frames(8)
	post("ghostpath")
	stage.free()

func a_repeat() -> void:
	build()
	player.add_animation_library("", lib_std())
	tree.tree_root = root_one("a")
	head("repeat")
	await physics_frame
	await frames(6)
	print("REPEAT_BEFORE_RESET ball=%s srv=%s tp=%s" % [
			v3(ball.global_position), srv(ball), tp()])
	ball.position = Vector3(0, 3, 0)
	print("REPEAT_RESET ball=%s" % [v3(ball.global_position)])
	await frames(6)
	post("repeat")
	stage.free()
