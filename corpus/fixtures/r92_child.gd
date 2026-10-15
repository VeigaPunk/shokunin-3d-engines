extends SceneTree
# r92 child probe — the RemoteTransform3D frame-boundary lattice, the
# AnimationPlayer x physics-body surface, and the SceneTree timing edges.
# Spawned per (case, backend) by r92_remote.gd / r92_animphys.gd /
# r92_timing.gd. Emits `M0 case=.. engine=..`, `M <case> <label> ..` rows,
# and `M DONE case=..` on stdout; parents merge stderr into the same log.
#
# argv: `-- <case>`
#
# Rep-stability contract (r92-scout receipt note): only pf-stamped physics
# observables and labelled summary rows cross this boundary — seq/n_e/n_f/
# anim_t stamps and F-row multiplicity are the scheduler's, never emitted.
# The one exception is `idlemode`, whose `post` line is a sample of a
# scheduler-dependent value validated by the parent against an invariant
# envelope (x bounded, y/z/lv/srv per-backend constants), never a constant.
#
# All animation cells pin callback_mode_process =
# ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS except `idlemode` (the contrast
# cell) — the scout's fixture-design law.

var case := ""
var stage: Node3D
var target: Node3D
var source: RemoteTransform3D
var ball: RB
var player: AnimationPlayer
var cap_f := false
var f_rows: Array = []


func f4(v: float) -> String:
	return "%.4f" % v


func v3(v: Vector3) -> String:
	return "(%.4f,%.4f,%.4f)" % [v.x, v.y, v.z]


func tf(n: Variant) -> String:
	if n == null or not is_instance_valid(n):
		return "FREED"
	var t: Transform3D = n.global_transform
	var s := t.basis.get_scale()
	return "O=%s X=%s S=%s" % [v3(t.origin), v3(t.basis.x), v3(s)]


func ltf(n: Variant) -> String:
	if n == null or not is_instance_valid(n):
		return "FREED"
	var t: Transform3D = n.transform
	var s := t.basis.get_scale()
	return "O=%s S=%s" % [v3(t.origin), v3(s)]


func srv(n: PhysicsBody3D) -> String:
	var v: Variant = PhysicsServer3D.body_get_state(n.get_rid(),
			PhysicsServer3D.BODY_STATE_TRANSFORM)
	if not (v is Transform3D):
		return "nil"
	return v3((v as Transform3D).origin)


func srv_o(n: PhysicsBody3D) -> String:
	var v: Variant = PhysicsServer3D.body_get_state(n.get_rid(),
			PhysicsServer3D.BODY_STATE_TRANSFORM)
	if not (v is Transform3D):
		return "null"
	return v3((v as Transform3D).origin)


func emit(label: String, body: String) -> void:
	print("M %s %s %s" % [case, label, body])


# ---------------------------------------------------------------------------
# shared node classes
# ---------------------------------------------------------------------------

class Watcher extends Node:
	# physics-callback sampler: one row per tick (pf-stamped, rep-stable)
	var probe
	func _physics_process(_d: float) -> void:
		probe.on_e()
	func _process(_d: float) -> void:
		if probe.cap_f:
			probe.cap_f = false
			probe.f_rows.append("pf=%d pos=%s lv=%s srv=%s" % [
					Engine.get_physics_frames(),
					probe.v3(probe.ball.global_position),
					probe.v3(probe.ball.linear_velocity),
					probe.srv(probe.ball)])


class PhaseWriter extends Node:
	var probe
	var mode := "E"
	var arm_at := 2
	var n_e := 0
	var n_f := 0
	var wrote_pf := -1
	var wrote_ox := 0.0
	func _physics_process(_d: float) -> void:
		n_e += 1
		if mode == "E" and n_e == arm_at:
			probe.source.position = Vector3(1, 0, 0)
			wrote_pf = Engine.get_physics_frames()
			wrote_ox = probe.target.global_position.x
	func _process(_d: float) -> void:
		n_f += 1
		if mode == "F" and n_f == arm_at:
			probe.source.position = Vector3(1, 0, 0)
			wrote_pf = Engine.get_physics_frames()
			wrote_ox = probe.target.global_position.x


class PhaseReader extends Node:
	var probe
	var n_e := 0
	var n_f := 0
	var e_rows: Array = []
	var f_rows2: Array = []
	func _physics_process(_d: float) -> void:
		n_e += 1
		e_rows.append([n_e, Engine.get_physics_frames(),
				probe.target.global_position.x])
	func _process(_d: float) -> void:
		n_f += 1
		f_rows2.append([n_f, Engine.get_physics_frames(),
				probe.target.global_position.x])


class Ticker extends Node:
	var probe
	func _physics_process(d: float) -> void:
		probe.on_tm_tick(d)


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var a := OS.get_cmdline_user_args()
	if a.size() > 0:
		case = a[0]
	print("M0 case=%s engine=%s" % [case,
			str(ProjectSettings.get_setting("physics/3d/physics_engine"))])
	match case:
		"sync":
			await c_sync()
		"lag":
			await c_lag()
		"phase":
			await c_phase()
		"flags":
			await c_flags()
		"stale":
			await c_stale()
		"path":
			await c_path()
		"chainlag":
			await c_chainlag()
		"srv":
			await c_srv()
		"parent":
			await c_parent()
		"local":
			await c_local()
		"driver":
			await c_driver()
		"rbpos":
			await c_rb(false)
		"rbfrozen":
			await c_rb(true)
		"animatable":
			await c_animatable()
		"reset":
			await c_reset()
		"idlemode":
			await c_idlemode()
		"manual":
			await c_manual()
		"animrb":
			await c_animrb()
		"empty_track":
			await c_empty()
		"badkey":
			await c_badkey()
		"badkey_reject":
			await c_badkey_reject()
		"iforder":
			await c_iforder()
		_ when case.begins_with("tm_"):
			await c_tm(case.substr(3))
	print("M DONE case=%s" % case)
	quit(0)


# ===========================================================================
# RemoteTransform3D lattice
# ===========================================================================

func build(pos := true, rot := true, scl := true, glob := true) -> void:
	stage = Node3D.new()
	stage.name = "Stage"
	root.add_child(stage)
	target = Node3D.new()
	target.name = "Target"
	stage.add_child(target)
	source = RemoteTransform3D.new()
	source.name = "Source"
	source.update_position = pos
	source.update_rotation = rot
	source.update_scale = scl
	source.use_global_coordinates = glob
	stage.add_child(source)
	source.remote_path = NodePath("../Target")


func set_src() -> void:
	source.position = Vector3(2, 1, -3)
	source.rotation = Vector3(0, PI / 2, 0)
	source.scale = Vector3(3, 3, 3)


func c_sync() -> void:
	build()
	await process_frame
	emit("pre", "tgt=%s src=%s" % [tf(target), tf(source)])
	source.position = Vector3(2, 1, -3)
	emit("pos_imm", "%s" % tf(target))
	source.rotation = Vector3(0, PI / 2, 0)
	source.scale = Vector3(3, 3, 3)
	emit("rotscale_imm", "%s" % tf(target))
	await process_frame
	emit("next_idle", "%s" % tf(target))
	source.position = Vector3(5, 5, 5)
	emit("pos2_imm", "%s" % tf(target))
	await physics_frame
	emit("next_phys", "%s" % tf(target))
	stage.free()


func c_lag() -> void:
	build()
	await process_frame
	for k in range(6):
		source.position = Vector3(float(k + 1), 0, 0)
		var imm := target.global_position.x
		await process_frame
		var a1 := target.global_position.x
		await process_frame
		var a2 := target.global_position.x
		emit("w%d" % (k + 1), "write=%.1f imm=%.1f after1=%.1f after2=%.1f" % [
				float(k + 1), imm, a1, a2])
	stage.free()


func c_phase() -> void:
	stage = Node3D.new()
	stage.name = "Stage"
	root.add_child(stage)
	target = Node3D.new()
	target.name = "Target"
	stage.add_child(target)
	source = RemoteTransform3D.new()
	source.name = "Source"
	stage.add_child(source)
	source.remote_path = NodePath("../Target")
	var w := PhaseWriter.new()
	w.probe = self
	root.add_child(w)
	var r := PhaseReader.new()
	r.probe = self
	root.add_child(r)
	await physics_frame
	# arm E: write inside the writer's 2nd _physics_process. The writer is
	# earlier in tree order than the reader, so the reader's same-tick
	# callback still sees the stale transform; the first post-boundary
	# reads see the pushed one.
	w.mode = "E"
	w.arm_at = 2
	w.n_e = 0
	w.n_f = 0
	r.n_e = 0
	r.n_f = 0
	r.e_rows.clear()
	r.f_rows2.clear()
	for i in range(4):
		await physics_frame
	await physics_frame
	await process_frame
	await process_frame
	var wpf := w.wrote_pf
	var same := -1.0
	var nexte := -1.0
	var nexte_dpf := -1
	var postf := -1.0
	for e in r.e_rows:
		if e[1] == wpf and same < 0:
			same = e[2]
		if e[1] > wpf and nexte_dpf < 0:
			nexte = e[2]
			nexte_dpf = e[1] - wpf
	for f in r.f_rows2:
		if f[1] >= wpf and postf < 0:
			postf = f[2]
	emit("e", "write_pf=%d imm=%.1f same_e=%.1f post_f=%.1f next_e_dpf=%d next_e=%.1f" % [
			wpf, w.wrote_ox, same, postf, nexte_dpf, nexte])
	# arm F: write inside the writer's 3rd _process. Whether an idle frame
	# interposes between the write and the next tick is scheduler's choice,
	# so we pin the ox semantics (stale in-frame / pushed post-boundary),
	# not pf stamps.
	source.position = Vector3(0, 0, 0)
	await process_frame
	await process_frame
	w.mode = "F"
	w.arm_at = 3
	w.n_e = 0
	w.n_f = 0
	r.n_e = 0
	r.n_f = 0
	r.e_rows.clear()
	r.f_rows2.clear()
	for i in range(6):
		await process_frame
	await physics_frame
	await physics_frame
	await process_frame
	wpf = w.wrote_pf
	var samef := -1.0
	var postf2 := -1.0
	var nexte2 := -1.0
	var nexte2_dpf := -1
	for f in r.f_rows2:
		if f[0] == w.arm_at and samef < 0:
			samef = f[2]
		if f[0] > w.arm_at and postf2 < 0:
			postf2 = f[2]
	for e in r.e_rows:
		if e[1] > wpf and nexte2_dpf < 0:
			nexte2 = e[2]
			nexte2_dpf = e[1] - wpf
	emit("f", "imm=%.1f same_f=%.1f post_f=%.1f next_e=%.1f" % [
			w.wrote_ox, samef, postf2, nexte2])
	r.free()
	w.free()
	stage.free()


func c_flags() -> void:
	var combos := [[true, true, true], [false, true, true],
			[true, false, true], [true, true, false], [false, false, true],
			[false, true, false], [true, false, false], [false, false, false]]
	for c in combos:
		build(c[0], c[1], c[2], true)
		await process_frame
		set_src()
		await process_frame
		emit("g%d%d%d" % [int(c[0]), int(c[1]), int(c[2])],
				"pos=%s rot=%s scl=%s glob=true %s" % [
				c[0], c[1], c[2], tf(target)])
		stage.free()
		await process_frame
	for c in [[true, true, true], [true, false, false], [false, false, false]]:
		stage = Node3D.new()
		root.add_child(stage)
		var holder := Node3D.new()
		holder.name = "Holder"
		holder.position = Vector3(10, 0, 0)
		stage.add_child(holder)
		target = Node3D.new()
		target.name = "Target"
		stage.add_child(target)
		source = RemoteTransform3D.new()
		source.name = "Source"
		source.update_position = c[0]
		source.update_rotation = c[1]
		source.update_scale = c[2]
		source.use_global_coordinates = false
		holder.add_child(source)
		source.remote_path = NodePath("../../Target")
		await process_frame
		source.position = Vector3(1, 2, 3)
		source.scale = Vector3(4, 4, 4)
		await process_frame
		emit("l%d%d%d" % [int(c[0]), int(c[1]), int(c[2])],
				"pos=%s rot=%s scl=%s glob=false %s src_glob=%s" % [
				c[0], c[1], c[2], tf(target), tf(source)])
		stage.free()
		await process_frame


func c_stale() -> void:
	build()
	await process_frame
	set_src()
	await process_frame
	emit("bound", "%s" % tf(target))
	target.free()
	emit("post_free", "valid=%s" % is_instance_valid(target))
	source.position = Vector3(9, 9, 9)
	emit("move_after_free_imm", "%s" % tf(target))
	await process_frame
	emit("after_frame1", "path=%s" % source.remote_path)
	source.force_update_cache()
	emit("after_forcecache", "(no error)")
	var t2 := Node3D.new()
	t2.name = "Target2"
	stage.add_child(t2)
	source.remote_path = NodePath("../Target2")
	await process_frame
	source.position = Vector3(4, 4, 4)
	await process_frame
	emit("rebound", "%s" % tf(t2))
	stage.remove_child(t2)
	emit("orphan_pre", "in_tree=%s local=%s" % [t2.is_inside_tree(), ltf(t2)])
	source.position = Vector3(5, 5, 5)
	await process_frame
	emit("orphan_after", "local=%s" % ltf(t2))
	stage.add_child(t2)
	await process_frame
	emit("reparented", "%s" % tf(t2))
	source.force_update_cache()
	await process_frame
	emit("reparented_cached", "%s" % tf(t2))
	source.remote_path = NodePath("../Target2")
	await process_frame
	emit("repath_same", "%s" % tf(t2))
	source.remote_path = NodePath("")
	await process_frame
	source.remote_path = NodePath("../Target2")
	await process_frame
	emit("repath_toggle", "%s" % tf(t2))
	stage.remove_child(source)
	source.position = Vector3(6, 6, 6)
	await process_frame
	emit("src_orphan", "%s" % tf(t2))
	stage.add_child(source)
	await process_frame
	emit("src_back", "%s" % tf(t2))
	stage.free()


func c_path() -> void:
	build()
	var plain := Node.new()
	plain.name = "Plain"
	stage.add_child(plain)
	var cases := [
		["self", NodePath(".")],
		["plain_node", NodePath("../Plain")],
		["missing", NodePath("../Nope")],
		["empty", NodePath("")],
		["abs_root", NodePath("/root")],
		["stage_parent", NodePath("..")],
		["child_of_target", NodePath("../Target/Ghost")],
	]
	for c in cases:
		source.remote_path = c[1]
		source.position = Vector3(7, 7, 7)
		await process_frame
		emit("pt_%s" % c[0], "path=%s tgt=%s src=%s" % [
				source.remote_path, tf(target), tf(source)])
		source.position = Vector3(0, 0, 0)
		await process_frame
	source.remote_path = NodePath("../Target")
	source.position = Vector3(1, 1, 1)
	await process_frame
	emit("valid_again", "%s" % tf(target))
	stage.free()


func c_chainlag() -> void:
	for order in ["fwd", "rev"]:
		stage = Node3D.new()
		root.add_child(stage)
		var a := RemoteTransform3D.new()
		a.name = "A"
		var b := RemoteTransform3D.new()
		b.name = "B"
		var c := RemoteTransform3D.new()
		c.name = "C"
		var leaf := Node3D.new()
		leaf.name = "Leaf"
		for n in ([a, b, c, leaf] if order == "fwd" else [leaf, c, b, a]):
			stage.add_child(n)
		a.remote_path = NodePath("../B")
		b.remote_path = NodePath("../C")
		c.remote_path = NodePath("../Leaf")
		await process_frame
		for k in range(4):
			a.position = Vector3(float(k + 1), 0, 0)
			var line := "order=%s write=%.1f" % [order, float(k + 1)]
			for i in range(4):
				await process_frame
				line += " f%d[b=%.1f c=%.1f leaf=%.1f]" % [i + 1,
						b.global_position.x, c.global_position.x,
						leaf.global_position.x]
			emit("w%d_%s" % [k + 1, order], line)
		stage.free()
		await process_frame


func c_srv() -> void:
	stage = Node3D.new()
	root.add_child(stage)
	var body := StaticBody3D.new()
	body.name = "Target"
	stage.add_child(body)
	var cs := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1, 1, 1)
	cs.shape = box
	body.add_child(cs)
	var source2 := RemoteTransform3D.new()
	source2.name = "Source"
	stage.add_child(source2)
	source2.remote_path = NodePath("../Target")
	await physics_frame
	emit("s0", "node_o=%s srv_o=%s" % [v3(body.global_position), srv_o(body)])
	source2.position = Vector3(5, 0, 0)
	emit("s1_imm", "node_o=%s srv_o=%s" % [v3(body.global_position), srv_o(body)])
	await physics_frame
	var space := body.get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(Vector3(5, 3, 0), Vector3(5, -3, 0))
	var hit := space.intersect_ray(q)
	emit("s2_afterphys", "node_o=%s srv_o=%s ray=%s" % [
			v3(body.global_position), srv_o(body),
			("hit@%.3f,%.3f,%.3f" % [hit.position.x, hit.position.y,
					hit.position.z]) if hit else "miss"])
	await process_frame
	emit("s3_afteridle", "node_o=%s srv_o=%s" % [v3(body.global_position), srv_o(body)])
	stage.free()


func c_parent() -> void:
	stage = Node3D.new()
	root.add_child(stage)
	var holder := Node3D.new()
	holder.name = "Holder"
	stage.add_child(holder)
	target = Node3D.new()
	target.name = "Target"
	stage.add_child(target)
	source = RemoteTransform3D.new()
	source.name = "Source"
	holder.add_child(source)
	source.remote_path = NodePath("../../Target")
	await process_frame
	emit("pre", "tgt=%s src=%s" % [tf(target), tf(source)])
	holder.position = Vector3(0, 4, 0)
	emit("imm", "%s" % tf(target))
	await process_frame
	emit("frame", "tgt=%s src=%s" % [tf(target), tf(source)])
	holder.scale = Vector3(2, 2, 2)
	await process_frame
	emit("pscale", "tgt=%s src=%s" % [tf(target), tf(source)])
	stage.free()


func c_local() -> void:
	stage = Node3D.new()
	root.add_child(stage)
	var holder := Node3D.new()
	holder.name = "Holder"
	holder.position = Vector3(10, 0, 0)
	stage.add_child(holder)
	target = Node3D.new()
	target.name = "Target"
	stage.add_child(target)
	source = RemoteTransform3D.new()
	source.name = "Source"
	holder.add_child(source)
	source.use_global_coordinates = false
	source.remote_path = NodePath("../../Target")
	await process_frame
	source.position = Vector3(1, 2, 3)
	await process_frame
	emit("localmode", "loc=%s glob=%s src_glob=%s" % [ltf(target), tf(target), tf(source)])
	source.use_global_coordinates = true
	await process_frame
	emit("toggle_global", "loc=%s glob=%s" % [ltf(target), tf(target)])
	source.use_global_coordinates = false
	source.remote_path = NodePath("")
	await process_frame
	emit("unbind", "glob=%s" % tf(target))
	source.remote_path = NodePath("../../Target")
	await process_frame
	emit("rebind", "glob=%s" % tf(target))
	stage.free()


func c_driver() -> void:
	for mode in ["process_off", "physics_off", "both_off"]:
		build()
		await process_frame
		match mode:
			"process_off":
				source.set_process(false)
			"physics_off":
				source.set_physics_process(false)
			"both_off":
				source.set_process(false)
				source.set_physics_process(false)
		source.position = Vector3(2, 1, -3)
		await process_frame
		await process_frame
		emit(mode, "%s" % tf(target))
		stage.free()
		await process_frame


# ===========================================================================
# AnimationPlayer x physics bodies
# ===========================================================================

var watcher: Watcher
var live_e := false
var e_emit_from := -1
var e_emit_to := -1


func on_e() -> void:
	var pf := Engine.get_physics_frames()
	if live_e and pf >= e_emit_from and pf <= e_emit_to:
		emit("E", "pf=%d pos=%s lv=%s srv=%s" % [pf,
				v3(ball.global_position), v3(ball.linear_velocity), srv(ball)])


func floor_build() -> void:
	var fl := StaticBody3D.new()
	fl.name = "Floor"
	fl.position = Vector3(0, -0.5, 0)
	stage.add_child(fl)
	var cs := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(20, 1, 20)
	cs.shape = box
	fl.add_child(cs)


func lib() -> AnimationLibrary:
	if player.has_animation_library(""):
		return player.get_animation_library("")
	var l := AnimationLibrary.new()
	player.add_animation_library("", l)
	return l


func put(name: String, anim: Animation) -> void:
	var l := lib()
	if l.has_animation(name):
		l.remove_animation(name)
	l.add_animation(name, anim)


func mk_anim(target_path: NodePath, v0: Vector3, v1: Vector3, length := 1.0) -> void:
	var anim := Animation.new()
	anim.length = length
	var t := anim.add_track(Animation.TYPE_POSITION_3D)
	anim.track_set_path(t, target_path)
	anim.track_insert_key(t, 0.0, v0)
	anim.track_insert_key(t, length, v1)
	put("travel", anim)


func mk_empty(target_path: NodePath) -> void:
	var anim := Animation.new()
	anim.length = 1.0
	var t := anim.add_track(Animation.TYPE_POSITION_3D)
	anim.track_set_path(t, target_path)
	put("travel", anim)


func mk_reset(x: float) -> void:
	var anim := Animation.new()
	anim.length = 0.0
	var t := anim.add_track(Animation.TYPE_POSITION_3D)
	anim.track_set_path(t, NodePath("Ball"))
	anim.track_insert_key(t, 0.0, Vector3(x, 0, 0))
	put("RESET", anim)


func ball_build(y: float, freeze: bool, mode := 0) -> void:
	ball = RB.new()
	ball.name = "Ball"
	ball.probe = self
	ball.freeze = freeze
	ball.position = Vector3(0, y, 0)
	ball.can_sleep = false
	stage.add_child(ball)
	var cs := CollisionShape3D.new()
	var sp := SphereShape3D.new()
	sp.radius = 0.5
	cs.shape = sp
	ball.add_child(cs)
	player = AnimationPlayer.new()
	player.name = "Player"
	player.root_node = NodePath("..")
	player.callback_mode_process = mode
	stage.add_child(player)
	mk_anim(NodePath("Ball"), Vector3(0, 2, 0), Vector3(3, 2, 0))


class RB extends RigidBody3D:
	var probe


func anim_watch() -> void:
	watcher = Watcher.new()
	watcher.probe = self
	root.add_child(watcher)


func c_rb(freeze: bool) -> void:
	stage = Node3D.new()
	stage.name = "Stage"
	root.add_child(stage)
	floor_build()
	ball_build(2.0, freeze)
	anim_watch()
	await physics_frame
	emit("pre", "freeze=%s pos=%s srv=%s lv=%s" % [freeze,
			v3(ball.global_position), srv(ball), v3(ball.linear_velocity)])
	player.play("travel")
	live_e = true
	var pf0 := Engine.get_physics_frames()
	e_emit_from = pf0
	e_emit_to = pf0 + 7
	for i in range(8):
		await physics_frame
	live_e = false
	cap_f = true
	await process_frame
	for fr in f_rows:
		emit("F_post", fr)
	emit("post", "freeze=%s pos=%s srv=%s lv=%s playing=%s" % [
			freeze, v3(ball.global_position), srv(ball),
			v3(ball.linear_velocity), player.is_playing()])
	ball.position = Vector3(0, 9, 0)
	emit("tp_imm", "node=%s srv=%s" % [v3(ball.global_position), srv(ball)])
	await physics_frame
	emit("tp_next", "node=%s srv=%s" % [v3(ball.global_position), srv(ball)])
	stage.free()


func c_animatable() -> void:
	for sync in [true, false]:
		stage = Node3D.new()
		root.add_child(stage)
		floor_build()
		var ab := AnimatableBody3D.new()
		ab.name = "Ball"
		ab.sync_to_physics = sync
		ab.position = Vector3(0, 2, 0)
		stage.add_child(ab)
		var cs := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = Vector3(1, 1, 1)
		cs.shape = box
		ab.add_child(cs)
		var rider := RigidBody3D.new()
		rider.name = "Rider"
		rider.position = Vector3(0, 3, 0)
		rider.can_sleep = false
		stage.add_child(rider)
		var rcs := CollisionShape3D.new()
		var rsp := SphereShape3D.new()
		rsp.radius = 0.5
		rcs.shape = rsp
		rider.add_child(rcs)
		var p := AnimationPlayer.new()
		p.name = "Player"
		p.root_node = NodePath("..")
		p.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS
		stage.add_child(p)
		var anim := Animation.new()
		anim.length = 1.0
		var t := anim.add_track(Animation.TYPE_POSITION_3D)
		anim.track_set_path(t, NodePath("Ball"))
		anim.track_insert_key(t, 0.0, Vector3(0, 2, 0))
		anim.track_insert_key(t, 1.0, Vector3(6, 2, 0))
		var l := AnimationLibrary.new()
		l.add_animation("travel", anim)
		p.add_animation_library("", l)
		await physics_frame
		emit("pre", "sync=%s ab=%s srv=%s rider=%s" % [sync,
				v3(ab.global_position), srv(ab), v3(rider.global_position)])
		p.play("travel")
		for i in range(6):
			await physics_frame
		var space := ab.get_world_3d().direct_space_state
		var q := PhysicsRayQueryParameters3D.create(
				Vector3(ab.global_position.x, 5, 0),
				Vector3(ab.global_position.x, -1, 0))
		var hit := space.intersect_ray(q)
		emit("post", "sync=%s ab=%s srv=%s rider=%s ray=%s t=%.4f" % [sync,
				v3(ab.global_position), srv(ab), v3(rider.global_position),
				("hit@%.3f,%.3f,%.3f" % [hit.position.x, hit.position.y,
						hit.position.z]) if hit else "miss",
				p.current_animation_position])
		stage.free()
		await physics_frame


func c_reset() -> void:
	stage = Node3D.new()
	root.add_child(stage)
	floor_build()
	ball_build(2.0, true)
	mk_reset(7.0)
	await physics_frame
	emit("list", "%s ros=%s" % [player.get_animation_list(),
			player.is_reset_on_save_enabled()])
	emit("pre", "pos=%s anim=%s" % [v3(ball.global_position),
			player.current_animation])
	player.play("travel")
	for i in range(4):
		await physics_frame
	emit("after_travel", "pos=%s t=%.4f" % [v3(ball.global_position),
			player.current_animation_position])
	player.play("RESET")
	await physics_frame
	emit("after_reset", "pos=%s t=%.4f anim=%s playing=%s" % [
			v3(ball.global_position), player.current_animation_position,
			player.current_animation, player.is_playing()])
	player.play("travel")
	for i in range(4):
		await physics_frame
	emit("travel2", "pos=%s t=%.4f" % [v3(ball.global_position),
			player.current_animation_position])
	player.seek(0.0, true)
	await physics_frame
	emit("seek0", "pos=%s t=%.4f" % [v3(ball.global_position),
			player.current_animation_position])
	stage.free()


func c_idlemode() -> void:
	stage = Node3D.new()
	root.add_child(stage)
	floor_build()
	ball_build(2.0, false, AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_IDLE)
	await physics_frame
	emit("pre", "mode=%s pos=%s" % [player.callback_mode_process,
			v3(ball.global_position)])
	player.play("travel")
	for i in range(6):
		await physics_frame
	var s := srv(ball)
	emit("post", "x=%.4f y=%.4f z=%.4f lv=%s srv=%s playing=%s" % [
			ball.global_position.x, ball.global_position.y,
			ball.global_position.z, v3(ball.linear_velocity), s,
			player.is_playing()])
	stage.free()


func c_manual() -> void:
	stage = Node3D.new()
	root.add_child(stage)
	floor_build()
	ball_build(2.0, true, AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL)
	await physics_frame
	player.play("travel")
	for i in range(3):
		await physics_frame
	emit("frozen", "pos=%s srv=%s t=%.4f" % [v3(ball.global_position),
			srv(ball), player.current_animation_position])
	player.advance(0.5)
	await physics_frame
	emit("adv", "pos=%s srv=%s t=%.4f" % [v3(ball.global_position),
			srv(ball), player.current_animation_position])
	stage.free()


func c_animrb() -> void:
	stage = Node3D.new()
	root.add_child(stage)
	ball_build(10.0, false)
	anim_watch()
	await physics_frame
	emit("pre", "pos=%s lv=%s srv=%s" % [v3(ball.global_position),
			v3(ball.linear_velocity), srv(ball)])
	player.play("travel")
	live_e = true
	var pf0 := Engine.get_physics_frames()
	e_emit_from = pf0
	e_emit_to = pf0 + 5
	for i in range(6):
		await physics_frame
	live_e = false
	emit("post", "pos=%s lv=%s srv=%s" % [v3(ball.global_position),
			v3(ball.linear_velocity), srv(ball)])
	stage.free()


func c_empty() -> void:
	stage = Node3D.new()
	root.add_child(stage)
	floor_build()
	ball_build(2.0, false)
	mk_empty(NodePath("Ball"))
	anim_watch()
	await physics_frame
	emit("pre", "pos=%s srv=%s lv=%s" % [v3(ball.global_position),
			srv(ball), v3(ball.linear_velocity)])
	player.play("travel")
	live_e = true
	var pf0 := Engine.get_physics_frames()
	e_emit_from = pf0 + 1
	e_emit_to = pf0 + 1
	for i in range(6):
		await physics_frame
	live_e = false
	emit("post", "pos=%s srv=%s lv=%s" % [v3(ball.global_position),
			srv(ball), v3(ball.linear_velocity)])
	stage.free()


func c_badkey() -> void:
	stage = Node3D.new()
	root.add_child(stage)
	floor_build()
	ball_build(2.0, true)
	var anim := Animation.new()
	anim.length = 1.0
	var t := anim.add_track(Animation.TYPE_POSITION_3D)
	anim.track_set_path(t, NodePath("Ball"))
	var r1 := anim.track_insert_key(t, 0.0, 0.0)
	var r2 := anim.track_insert_key(t, 1.0, 1.0)
	put("travel", anim)
	emit("insert", "r1=%d r2=%d" % [r1, r2])
	var a2 := player.get_animation("travel")
	emit("tracks", "n=%d keys=%d type=%d" % [a2.get_track_count(),
			a2.track_get_key_count(0), a2.track_get_type(0)])
	await physics_frame
	emit("pre", "pos=%s" % v3(ball.global_position))
	player.play("travel")
	for i in range(4):
		await physics_frame
	emit("post", "pos=%s srv=%s t=%.4f playing=%s" % [
			v3(ball.global_position), srv(ball),
			player.current_animation_position, player.is_playing()])
	stage.free()


func c_badkey_reject() -> void:
	# negative control: the SAME two wrong-typed inserts, but the author
	# honours the -1 return and refuses to play the track — the transform
	# survives. The parent emits NEGATIVE REJECTED when every backend shows
	# refused + not destroyed.
	stage = Node3D.new()
	root.add_child(stage)
	floor_build()
	ball_build(2.0, true)
	var anim := Animation.new()
	anim.length = 1.0
	var t := anim.add_track(Animation.TYPE_POSITION_3D)
	anim.track_set_path(t, NodePath("Ball"))
	var r1 := anim.track_insert_key(t, 0.0, 0.0)
	var r2 := anim.track_insert_key(t, 1.0, 1.0)
	var keys := anim.track_get_key_count(0)
	var refused := r1 == -1 and r2 == -1 and keys == 0
	if not refused:
		put("travel", anim)
		player.play("travel")
	for i in range(4):
		await physics_frame
	var destroyed := ball.global_position.distance_to(Vector3(0, 2, 0)) > 0.001
	emit("reject", "r1=%d r2=%d keys=%d pos=%s destroyed=%s" % [
			r1, r2, keys, v3(ball.global_position), destroyed])
	stage.free()


func c_iforder() -> void:
	stage = Node3D.new()
	root.add_child(stage)
	floor_build()
	ball_build(2.0, true)
	anim_watch()
	await physics_frame
	player.play("travel")
	for i in range(4):
		var pf := Engine.get_physics_frames()
		emit("E", "pf=%d pos=%s srv=%s" % [pf,
				v3(ball.global_position), srv(ball)])
		await physics_frame
		await process_frame
		emit("I", "pos=%s srv=%s" % [v3(ball.global_position), srv(ball)])
	emit("post", "pos=%s srv=%s playing=%s" % [v3(ball.global_position),
			srv(ball), player.is_playing()])
	stage.free()


# ===========================================================================
# SceneTree timing edges
# ===========================================================================

var tm_case := ""
var tm_mutated := false
var tm_ne := 0


func on_tm_tick(d: float) -> void:
	tm_ne += 1
	var pf := Engine.get_physics_frames()
	if pf <= 4 or pf >= 9:
		return
	if tm_ne == 4 and not tm_mutated:
		tm_mutated = true
		emit("mut", "pf=%d" % pf)
		match tm_case:
			"tps30":
				Engine.physics_ticks_per_second = 30
			"tps120":
				Engine.physics_ticks_per_second = 120
			"ts05":
				Engine.time_scale = 0.5
			"ts0":
				Engine.time_scale = 0.0
			"tsneg":
				Engine.time_scale = -1.0
			"tsbig":
				Engine.time_scale = 10.0
			"ts2big":
				Engine.time_scale = 2.0
			"tps0":
				Engine.physics_ticks_per_second = 0
			"tpsneg":
				Engine.physics_ticks_per_second = -60
			"interpf":
				ProjectSettings.set_setting(
						"physics/common/physics_interpolation", true)
			"jitfix0":
				Engine.physics_jitter_fix = 0.0
			"maxsteps":
				Engine.max_physics_steps_per_frame = 1
				Engine.time_scale = 10.0
		emit("mutpost", "tsc=%.4f tps=%d jit=%.4f mps=%d interp=%s" % [
				Engine.time_scale, Engine.physics_ticks_per_second,
				Engine.physics_jitter_fix, Engine.max_physics_steps_per_frame,
				ProjectSettings.get_setting(
						"physics/common/physics_interpolation")])
		return
	if pf >= 5 and pf <= 8:
		emit("E", "pf=%d delta=%.6f" % [pf, d])


func c_tm(sub: String) -> void:
	tm_case = sub
	emit("pre", "tsc=%.4f tps=%d jit=%.4f mps=%d interp=%s" % [
			Engine.time_scale, Engine.physics_ticks_per_second,
			Engine.physics_jitter_fix, Engine.max_physics_steps_per_frame,
			ProjectSettings.get_setting(
					"physics/common/physics_interpolation")])
	var t := Ticker.new()
	t.probe = self
	root.add_child(t)
	for i in range(12):
		await physics_frame
	emit("done", "pf=%d tsc=%.4f tps=%d jit=%.4f mps=%d" % [
			Engine.get_physics_frames(), Engine.time_scale,
			Engine.physics_ticks_per_second, Engine.physics_jitter_fix,
			Engine.max_physics_steps_per_frame])
