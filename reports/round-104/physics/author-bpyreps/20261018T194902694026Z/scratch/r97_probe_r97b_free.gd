extends SceneTree
# r97b (r97-boundary): granularity of deferred deletion.
#
# Queue a Joint3D `queue_free()` from a physics tick and report on every
# following tick whether the node is still alive, together with the process
# frame counter `ff` (so the receipt itself shows whether the free tick and the
# next tick are inside the same process frame).
#
# Hypothesis under test: Godot flushes the delete queue at the end of the
# PROCESS frame, so under tick batching (several physics steps inside one frame)
# a free issued from the first tick of a frame would not take effect until the
# next frame.  Measured verdict: REJECTED -- the node is always gone on the
# next tick, even when both ticks share one frame (see the boundary report).
#
# --at=<tick>  tick that queues the free (default 7)
# Rows: "FR t=.. ff=.. alive=.. jrid=.. b=.."  (ff = process frames elapsed)

var at := 7
var tick := 0
var ff := 0
var A: Node3D
var B: RigidBody3D
var J: Joint3D

class Watcher extends Node:
	var probe
	func _process(_d: float) -> void:
		probe.ff += 1
	func _physics_process(_d: float) -> void:
		probe.on_tick()

func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--at="):
			at = int(a.substr(5))
	var w := Watcher.new()
	w.probe = self
	get_root().add_child(w)
	A = _ball("bodyA", Vector3(-0.25, 2, 0))
	B = _ball("bodyB", Vector3(0.25, 2, 0))
	J = PinJoint3D.new()
	J.position = Vector3(0, 2, 0)
	get_root().add_child(J)
	J.node_a = NodePath("../bodyA")
	J.node_b = NodePath("../bodyB")
	print("FR setup at=%d jrid=%s" % [at, str(J.get_rid().is_valid())])

func _ball(nm: String, pos: Vector3) -> RigidBody3D:
	var b := RigidBody3D.new()
	b.name = nm
	b.position = pos
	b.mass = 1.0
	b.can_sleep = false
	var cs := CollisionShape3D.new()
	var sh := SphereShape3D.new()
	sh.radius = 0.1
	cs.shape = sh
	b.add_child(cs)
	get_root().add_child(b)
	return b

func on_tick() -> void:
	tick += 1
	if tick == at:
		print("FR freeing at t=%d ff=%d" % [tick, ff])
		J.queue_free()
	if (tick >= at - 1 and tick <= at + 6) or tick == 30:
		report()
	if tick == 30:
		fin()

func report() -> void:
	var alive := "false"
	var jrid := "gone"
	if is_instance_valid(J):
		alive = "true"
		jrid = str(J.get_rid().is_valid())
	var b := "-"
	if is_instance_valid(B):
		b = "%s,%s,%s" % [_f(B.position.x), _f(B.position.y),
			_f(B.position.z)]
	print("FR t=%d ff=%d alive=%s jrid=%s b=%s" % [tick, ff, alive, jrid, b])

func _f(x: float) -> String:
	return String.num(x, 4)

func fin() -> void:
	print("FRSUM at=%d" % at)
	quit(0)
