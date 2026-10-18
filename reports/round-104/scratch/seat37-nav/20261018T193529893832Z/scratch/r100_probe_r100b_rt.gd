extends SceneTree
# r100-scout probe 2: the r92 frame-boundary law under a pinned rate mode.
#
# Replicates r92-scout §0.1 (RemoteTransform3D write latency) and §0.3 (the
# propagated transform reaching the physics server) with the *idle-frame
# multiplicity* now controlled by --fixed-fps, so "the next frame boundary"
# becomes pinned arithmetic instead of a scheduler accident.
#
# Cases (user arg): phase | lag | srv
# Rows carry pf (physics frame), ff (process frame) and seq so the reader can
# locate the write and the first read that shows it.

var case := "phase"
var seq := 0
var stage: Node3D
var target: Node3D
var source: RemoteTransform3D
var rows: Array = []
var arm := ""

class Watcher extends Node:
	var probe
	func _physics_process(_d: float) -> void:
		probe.seq += 1
		probe.sample("E")
	func _process(_d: float) -> void:
		probe.seq += 1
		probe.sample("F")

class Writer extends Node:
	var probe
	var mode := "E"
	var arm_at := 2
	var n_e := 0
	var n_f := 0
	func _physics_process(_d: float) -> void:
		n_e += 1
		if mode == "E" and n_e == arm_at:
			probe.seq += 1
			probe.source.position = Vector3(1, 0, 0)
			probe.rows.append("RT %s W_E n=%d pf=%d ff=%d seq=%d IMM %s" % [
				probe.arm, n_e, Engine.get_physics_frames(),
				Engine.get_process_frames(), probe.seq, probe.tf(probe.target)])
	func _process(_d: float) -> void:
		n_f += 1
		if mode == "F" and n_f == arm_at:
			probe.seq += 1
			probe.source.position = Vector3(1, 0, 0)
			probe.rows.append("RT %s W_F n=%d pf=%d ff=%d seq=%d IMM %s" % [
				probe.arm, n_f, Engine.get_physics_frames(),
				Engine.get_process_frames(), probe.seq, probe.tf(probe.target)])

class Reader extends Node:
	var probe
	var n_e := 0
	var n_f := 0
	func _physics_process(_d: float) -> void:
		n_e += 1
		probe.seq += 1
		probe.sample("R_E n=%d" % n_e)
	func _process(_d: float) -> void:
		n_f += 1
		probe.seq += 1
		probe.sample("R_F n=%d" % n_f)


func f4(v: float) -> String:
	return "%.4f" % v


func tf(n: Variant) -> String:
	if n == null or not is_instance_valid(n):
		return "FREED"
	var t: Transform3D = n.global_transform
	return "O=(%s,%s,%s)" % [f4(t.origin.x), f4(t.origin.y), f4(t.origin.z)]


func sample(p: String) -> void:
	if arm != "" and target != null and is_instance_valid(target):
		rows.append("RT arm=%s p=%s pf=%d ff=%d seq=%d %s" % [arm, p,
			Engine.get_physics_frames(), Engine.get_process_frames(), seq,
			tf(target)])


func flush() -> void:
	for r in rows:
		print(r)
	rows.clear()


func build() -> void:
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


func _initialize() -> void:
	var ua := OS.get_cmdline_user_args()
	if ua.size() > 0:
		case = ua[0]
	call_deferred("_run")


func _run() -> void:
	match case:
		"phase":
			await c_phase()
		"lag":
			await c_lag()
		"srv":
			await c_srv()
	print("RT_DONE case=%s" % case)
	quit(0)


func c_phase() -> void:
	build()
	var w := Writer.new()
	w.probe = self
	root.add_child(w)
	var r := Reader.new()
	r.probe = self
	root.add_child(r)
	await physics_frame
	arm = "write_at_E"
	w.mode = "E"
	w.arm_at = 2
	for i in range(6):
		await physics_frame
	flush()
	arm = "reset"
	source.position = Vector3(0, 0, 0)
	await process_frame
	await process_frame
	flush()
	arm = "write_at_F"
	w.mode = "F"
	w.arm_at = 3
	for i in range(6):
		await process_frame
	flush()
	arm = ""
	r.free()
	w.free()
	stage.free()


func c_lag() -> void:
	build()
	await process_frame
	for k in range(4):
		source.position = Vector3(float(k + 1), 0, 0)
		var imm := target.global_position.x
		await process_frame
		var a1 := target.global_position.x
		var ff1 := Engine.get_process_frames()
		await process_frame
		var a2 := target.global_position.x
		print("LG write=%.1f imm=%.1f after1=%.1f after2=%.1f ff1=%d" % [
			float(k + 1), imm, a1, a2, ff1])
	stage.free()


func c_srv() -> void:
	stage = Node3D.new()
	stage.name = "Stage"
	root.add_child(stage)
	var body := StaticBody3D.new()
	body.name = "Target"
	stage.add_child(body)
	var cs := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1, 1, 1)
	cs.shape = box
	body.add_child(cs)
	var src2 := RemoteTransform3D.new()
	src2.name = "Source"
	stage.add_child(src2)
	src2.remote_path = NodePath("../Target")
	await physics_frame
	var rid := body.get_rid()
	print("SRV_S0 node=%s srv=%s" % [tf(body), str(PhysicsServer3D.body_get_state(
		rid, PhysicsServer3D.BODY_STATE_TRANSFORM))])
	src2.position = Vector3(5, 0, 0)
	print("SRV_S1_IMMEDIATE node=%s srv=%s" % [tf(body),
		str(PhysicsServer3D.body_get_state(rid,
			PhysicsServer3D.BODY_STATE_TRANSFORM))])
	await physics_frame
	var space := body.get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(Vector3(5, 3, 0), Vector3(5, -3, 0))
	var hit := space.intersect_ray(q)
	print("SRV_S2_AFTERPHYS pf=%d ff=%d node=%s ray=%s" % [
		Engine.get_physics_frames(), Engine.get_process_frames(), tf(body),
		("hit@%.3f,%.3f,%.3f" % [hit.position.x, hit.position.y, hit.position.z])
			if hit else "miss"])
	await process_frame
	print("SRV_S3_AFTERIDLE pf=%d ff=%d node=%s" % [
		Engine.get_physics_frames(), Engine.get_process_frames(), tf(body)])
	stage.free()
