extends SceneTree
# r97 probe: SoftBody3D — compiled-in, instantiable, never measured.
# GodotPhysics has no soft-body implementation (server stubs); Jolt does.
#
# Rig: a SoftBody3D with an ArrayMesh — a 3x3 grid cloth patch in the XZ
# plane at y=3 (9 vertices, 8 quad triangles... we emit 2 tris/quad over a
# 1x1 m patch: verts (i*0.5-0.5, 3, j*0.5-0.5) for i,j in 0..2).
# Optional static floor at y=0 and/or a rigid ball.
#
# Cases:
#   drop        free-fall — does vertex 4 (centre) drop? does it land?
#   pin_top     verts 0 and 2 pinned at spawn — hangs as a hammock?
#   pin_mid     centre vert pinned
#   impulse     apply_central_impulse +y at t=4 — COM rises?
#   pt_impulse  apply_impulse on vert 8 only — asymmetric deformation?
#   mass        total_mass=0.1 vs 10 (two arms via --mass=)
#   prec        simulation_precision=50 vs 1 (--prec=)
#   collide     rigid ball dropped onto pinned patch — does it rest on it?
#   ray         ray_pickable + intersect_ray through patch centre
#   freeme      free the softbody node mid-run
#   nomesh      SoftBody3D with no mesh — error class?
#
# Rows: "SB t=.. v4=(x,y,z) v0=(x,y,z) pinned=.. errn=.."

var case := "drop"
var tick := 0
var sb: SoftBody3D
var ball: RigidBody3D
var mass := 1.0
var prec := -1
var errn := 0
# finisher: --indexed adds st.index() before commit. Unindexed (as the dead
# scout wrote it) is rejected on BOTH backends (GP: "mesh needs to have
# indices"; Jolt: mesh_indices.is_empty() -> shared_settings null) -> inert.
# Indexed: 9 deduped verts; v0/v8 are opposite corners, v3 is the centre.
var indexed := false
var VC := 4     # centre vert for reporting (unindexed emit order)
var VPIN := 22  # second pin corner (unindexed)
var VIMP := 22  # pt_impulse target

class Watcher extends Node:
	var probe
	func _physics_process(_d: float) -> void:
		probe.on_tick()

func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--case="):
			case = a.substr(7)
		elif a.begins_with("--mass="):
			mass = float(a.substr(7))
		elif a.begins_with("--prec="):
			prec = int(a.substr(7))
		elif a == "--indexed":
			indexed = true
			VC = 3
			VPIN = 8
			VIMP = 8
	var w := Watcher.new()
	w.probe = self
	get_root().add_child(w)
	if case != "nomesh" and case != "ray":
		_build_patch()
	elif case == "ray":
		_build_patch()
	else:
		sb = SoftBody3D.new()
		get_root().add_child(sb)
	if case in ["pin_top", "pin_mid", "collide"]:
		call_deferred("_do_pins")
	if case == "collide":
		_build_floor_and_ball()
	elif case == "drop" or case == "ray":
		_build_floor()

func _build_patch() -> void:
	sb = SoftBody3D.new()
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# 3x3 grid over x,z in [-0.5,0.5] at y=3
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
	if indexed:
		st.index()
	sb.mesh = st.commit()
	get_root().add_child(sb)
	sb.total_mass = mass
	if prec > 0:
		sb.simulation_precision = prec
	print("SB setup case=%s mass=%s prec=%d idx=%d" % [case,
		String.num(mass, 3), prec, int(indexed)])

func _do_pins() -> void:
	if not is_instance_valid(sb):
		return
	if case == "pin_top" or case == "collide":
		# opposite corners: unindexed v0/v22, indexed v0/v8
		sb.set_point_pinned(0, true, NodePath(""))
		sb.set_point_pinned(VPIN, true, NodePath(""))
	elif case == "pin_mid":
		sb.set_point_pinned(VC, true, NodePath(""))

func _build_floor() -> void:
	var f := StaticBody3D.new()
	f.position = Vector3(0, 0, 0)
	var cs := CollisionShape3D.new()
	var sh := BoxShape3D.new()
	sh.size = Vector3(6, 0.1, 6)
	cs.shape = sh
	f.add_child(cs)
	get_root().add_child(f)

func _build_floor_and_ball() -> void:
	_build_floor()
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
	match case:
		"drop", "mass", "prec", "nomesh":
			if tick in [10, 30, 60, 120]:
				report()
			if tick == 120:
				fin()
		"pin_top", "pin_mid":
			if tick in [10, 30, 60]:
				report()
			if tick == 60:
				fin()
		"impulse":
			if tick == 4 and is_instance_valid(sb):
				sb.apply_central_impulse(Vector3(0, 3, 0))
			if tick in [8, 20, 40]:
				report()
			if tick == 40:
				fin()
		"pt_impulse":
			if tick == 4 and is_instance_valid(sb):
				sb.apply_impulse(VIMP, Vector3(0, 5, 0))
			if tick in [8, 20, 40]:
				report()
			if tick == 40:
				fin()
		"collide":
			if tick in [10, 30, 60, 90]:
				report()
			if tick == 90:
				fin()
		"ray":
			if tick == 10:
				var dss = get_root().get_world_3d().direct_space_state
				var q := PhysicsRayQueryParameters3D.new()
				q.from = Vector3(0, 5, 0)
				q.to = Vector3(0, -1, 0)
				q.hit_back_faces = true
				var hit = dss.intersect_ray(q)
				print("SB ray n=%d pos=%s" % [hit.size(),
					str(hit.get("position", "-"))])
				report()
			if tick == 12:
				fin()
		"freeme":
			if tick == 8:
				report()
				sb.queue_free()
			if tick in [16, 30]:
				report()
			if tick == 30:
				fin()

func report() -> void:
	var v4 := "-"
	var v0 := "-"
	var b := "-"
	var pinned := "-"
	if is_instance_valid(sb):
		v4 = _pt(VC)
		v0 = _pt(0)
		pinned = str(sb.is_point_pinned(0)) + "," + \
			str(sb.is_point_pinned(VPIN))
	if is_instance_valid(ball):
		b = "%s,%s,%s" % [_f(ball.position.x), _f(ball.position.y),
			_f(ball.position.z)]
	print("SB t=%d v4=%s v0=%s pinned=%s ball=%s" % [tick, v4, v0, pinned, b])

func _pt(i: int) -> String:
	# 4.7.2: get_point_transform returns Vector3 (point position), not
	# Transform3D — dead-scout latent parse bug, fixed by finisher.
	var t: Vector3 = sb.get_point_transform(i)
	return "%s,%s,%s" % [_f(t.x), _f(t.y), _f(t.z)]

func _f(x: float) -> String:
	return String.num(x, 5)

func fin() -> void:
	print("SBSUM case=%s" % case)
	quit(0)
