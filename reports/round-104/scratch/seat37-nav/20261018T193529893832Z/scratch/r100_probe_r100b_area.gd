extends SceneTree
# r100-scout probe 3: the r93 Area3D signal-timing law under a pinned rate mode.
# Does collapsing the idle multiplicity (--fixed-fps) move the signal inside the
# physics tick (r93: after _integrate_forces, before _physics_process)?
#
# Cases (user arg): enter | exit
# Rows: AR p=IF|A|E with pf (physics frame), ff (process frame), seq, ovA.

var case := "enter"
var seq := 0
var stage: Node3D
var area: Area3D
var ball: RigidBody3D
var rows: Array = []
var teleport_at := 34
var t0 := 0
var t_first := -1
var t_last := -1
var n_e := 0

class Ball extends RigidBody3D:
	var probe
	func _integrate_forces(_s: PhysicsDirectBodyState3D) -> void:
		probe.seq += 1
		probe.if_row()

class Watcher extends Node:
	var probe
	func _physics_process(_d: float) -> void:
		probe.seq += 1
		probe.e_row()


func if_row() -> void:
	if n_e <= 40 or n_e % 10 == 0:
		print("AR p=IF pf=%d ff=%d seq=%d ovA=%d by=%.4f" % [
			Engine.get_physics_frames(), Engine.get_process_frames(), seq,
			area.get_overlapping_bodies().size(), ball.global_position.y])


func e_row() -> void:
	if n_e <= 40 or n_e % 10 == 0:
		print("AR p=E pf=%d ff=%d seq=%d ovA=%d by=%.4f" % [
			Engine.get_physics_frames(), Engine.get_process_frames(), seq,
			area.get_overlapping_bodies().size(), ball.global_position.y])


func _initialize() -> void:
	var ua := OS.get_cmdline_user_args()
	if ua.size() > 0:
		case = ua[0]
	stage = Node3D.new()
	stage.name = "Stage"
	root.add_child(stage)
	area = Area3D.new()
	area.name = "A"
	area.position = Vector3(0, 3, 0)
	var acs := CollisionShape3D.new()
	var abox := BoxShape3D.new()
	abox.size = Vector3(1, 1, 1)
	acs.shape = abox
	area.add_child(acs)
	stage.add_child(area)
	area.body_entered.connect(_on_enter)
	area.body_shape_entered.connect(_on_shape_enter)
	area.body_exited.connect(_on_exit)
	ball = Ball.new()
	ball.probe = self
	ball.name = "Ball"
	var bcs := CollisionShape3D.new()
	var bsp := SphereShape3D.new()
	bsp.radius = 0.5
	bcs.shape = bsp
	ball.add_child(bcs)
	ball.position = Vector3(0, 5, 0)
	stage.add_child(ball)
	var w := Watcher.new()
	w.probe = self
	root.add_child(w)
	t0 = Time.get_ticks_msec()
	print("AR_BOOT case=%s tps=%d" % [case, Engine.physics_ticks_per_second])


func _on_enter(body: Node3D) -> void:
	seq += 1
	t_first = Engine.get_physics_frames()
	print("AR p=A sig=body_entered pf=%d ff=%d seq=%d by=%.4f" % [
		Engine.get_physics_frames(), Engine.get_process_frames(), seq,
		ball.global_position.y])


func _on_shape_enter(body: Node3D, _bid: int, _sid: int, _lid: int) -> void:
	seq += 1
	print("AR p=A sig=body_shape_entered pf=%d ff=%d seq=%d" % [
		Engine.get_physics_frames(), Engine.get_process_frames(), seq])


func _on_exit(body: Node3D) -> void:
	seq += 1
	t_last = Engine.get_physics_frames()
	print("AR p=A sig=body_exited pf=%d ff=%d seq=%d by=%.4f" % [
		Engine.get_physics_frames(), Engine.get_process_frames(), seq,
		ball.global_position.y])


func _physics_process(_d: float) -> bool:
	n_e += 1
	if case == "exit" and n_e == teleport_at:
		ball.position = Vector3(0, 8, 0)
		print("AR p=MUT pf=%d ff=%d seq=%d teleport_to_y=8" % [
			Engine.get_physics_frames(), Engine.get_process_frames(), seq])
	if n_e >= 60:
		print("AR_END case=%s n_e=%d first=%d last=%d ovA=%d" % [
			case, n_e, t_first, t_last, area.get_overlapping_bodies().size()])
		print("AR_TIME t=%d" % [Time.get_ticks_msec() - t0])
		quit(0)
	return false
