extends SceneTree
# r97b (r97-boundary): does the SoftBody3D <-> static-floor interaction depend
# on floor THICKNESS?  The r97 scout pinned "GodotPhysics: an indexed soft body
# simulates but does not collide (falls through the floor)" and "Jolt collides,
# but mass=10 and precision=50 fall through the same floor" -- both scoped to a
# 0.1 m slab.  This probe sweeps the slab.
#
# Rig: 3x3 indexed patch (SurfaceTool + index(), 9 deduped verts) at y=3,
# identical to soft.gd --indexed.  Static box floor size (6, T, 6) placed so
# its TOP face is y=0.05, matching soft.gd (box (6,0.1,6) at origin).  thick=0.1
# therefore reproduces the scout's rig exactly.
#
# Cases: drop (free fall onto the slab), collide (pinned corners + 2 kg ball)
# Rows: "SF t=.. v4=.. v0=.. top=.. below=.. ball=.."

var case := "drop"
var thick := 0.1
var mass := 1.0
var prec := -1
var pins := "deferred"
var pin := "top"
var tick := 0
var sb: SoftBody3D
var ball: RigidBody3D

class Watcher extends Node:
	var probe
	func _physics_process(_d: float) -> void:
		probe.on_tick()

func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--case="):
			case = a.substr(7)
		elif a.begins_with("--thick="):
			thick = float(a.substr(8))
		elif a.begins_with("--mass="):
			mass = float(a.substr(7))
		elif a.begins_with("--prec="):
			prec = int(a.substr(7))
		elif a.begins_with("--pins="):
			pins = a.substr(7)
		elif a.begins_with("--pin="):
			pin = a.substr(6)
	var w := Watcher.new()
	w.probe = self
	get_root().add_child(w)
	_build_patch()
	_build_floor()
	if case == "collide":
		# scout's soft.gd defers this; the deferred flush lands either before
		# (pf=0) or after (pf=1) the first physics step -- a startup race.
		# --pins=now forces the pre-first-step branch deterministically.
		if pins == "now":
			_do_pins()
		else:
			call_deferred("_do_pins")
		_build_ball()
	print("SF setup case=%s thick=%s mass=%s prec=%d pins=%s pin=%s" % [case,
		String.num(thick, 3), String.num(mass, 3), prec, pins, pin])

func _build_patch() -> void:
	sb = SoftBody3D.new()
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 2:
		for j in 2:
			var x0 := i * 0.5 - 0.5
			var x1 := (i + 1) * 0.5 - 0.5
			var z0 := j * 0.5 - 0.5
			var z1 := (j + 1) * 0.5 - 0.5
			st.add_vertex(Vector3(x0, 3, z0))
			st.add_vertex(Vector3(x0, 3, z1))
			st.add_vertex(Vector3(x1, 3, z0))
			st.add_vertex(Vector3(x0, 3, z1))
			st.add_vertex(Vector3(x1, 3, z1))
			st.add_vertex(Vector3(x1, 3, z0))
	st.generate_normals()
	st.index()
	sb.mesh = st.commit()
	get_root().add_child(sb)
	sb.total_mass = mass
	if prec > 0:
		sb.simulation_precision = prec

func _build_floor() -> void:
	var f := StaticBody3D.new()
	f.position = Vector3(0, 0.05 - thick * 0.5, 0)
	var cs := CollisionShape3D.new()
	var sh := BoxShape3D.new()
	sh.size = Vector3(6, thick, 6)
	cs.shape = sh
	f.add_child(cs)
	get_root().add_child(f)

func _do_pins() -> void:
	if not is_instance_valid(sb):
		return
	if pin == "mid":
		sb.set_point_pinned(3, true, NodePath(""))
	else:
		sb.set_point_pinned(0, true, NodePath(""))
		sb.set_point_pinned(8, true, NodePath(""))
	# deferred-call phase: how many physics ticks elapsed before the deferred
	# setup actually ran (wall-clock dependent -- see the boundary report)
	print("SF pins applied at pf=%d tick=%d" % [Engine.get_physics_frames(),
		tick])

func _build_ball() -> void:
	ball = RigidBody3D.new()
	ball.position = Vector3(0, 4.5, 0)
	ball.mass = 2.0
	ball.can_sleep = false
	var cs := CollisionShape3D.new()
	var sh := SphereShape3D.new()
	sh.radius = 0.2
	cs.shape = sh
	ball.add_child(cs)
	get_root().add_child(ball)

func on_tick() -> void:
	tick += 1
	if tick in [10, 30, 60, 120]:
		report()
	if tick == 120:
		fin()

func report() -> void:
	var v4 := "-"
	var v0 := "-"
	var b := "-"
	var below := -1
	if is_instance_valid(sb):
		var p4: Vector3 = sb.get_point_transform(3)
		var p0: Vector3 = sb.get_point_transform(0)
		v4 = _f3(p4)
		v0 = _f3(p0)
		below = int(p4.y < 0.04)
	if is_instance_valid(ball):
		b = _f3(ball.position)
	print("SF t=%d v4=%s v0=%s top=%s below=%d ball=%s" % [tick, v4, v0,
		_f3(Vector3(0, 0.05, 0)), below, b])

func _f3(v: Vector3) -> String:
	return "%s,%s,%s" % [_f(v.x), _f(v.y), _f(v.z)]

func _f(x: float) -> String:
	return String.num(x, 5)

func fin() -> void:
	print("SFSUM case=%s thick=%s" % [case, String.num(thick, 3)])
	quit(0)
