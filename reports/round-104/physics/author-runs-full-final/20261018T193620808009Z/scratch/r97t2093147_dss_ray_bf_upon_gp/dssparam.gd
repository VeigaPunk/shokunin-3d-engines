extends SceneTree
# r97 probe: PhysicsDirectSpaceState3D PARAM-BEHAVIOR matrix. r88 pinned the
# defaults and the motion split; this round measures what the flags DO.
#
# Rig (built per case):
#   W  static wall box at z=-2 (layer 1)
#   W2 static wall box at z=-4 (layer 2)
#   AR Area3D + box at x=+3 (monitorable, layer 4)
#   TM static trimesh bowl: a triangle at y=1 facing +y (for backface tests)
#   SPH static sphere r=0.5 at origin (for inside-ray tests)
#
# Query helper prints "Q <case> n=<count> ids=<collider_id list> ..." or the
# ray dict's keys. All queries run ONCE inside _physics_process t=2.
#
# Cases:
#   ray_plain       ray (0,1,0)->(0,1,-10): hits W (z=-2)
#   ray_excl        same ray, exclude=[W rid]
#   ray_excl2       same ray, exclude=[W rid, W2 rid] -> what remains?
#   ray_mask        ray, mask=2 -> hits W2 only
#   ray_mask0       ray, mask=0
#   ray_areas       ray toward Area3D, collide_with_areas left default(true)
#   ray_areasoff    same, collide_with_areas=false
#   ray_hfi_in      from INSIDE SPH to outside, hit_from_inside=true
#   ray_hfi_inoff   same, hit_from_inside=false
#   ray_hfi_out     from outside into SPH centre, hfi=true (does it matter?)
#   ray_bf_down     ray DOWN at the upward triangle, hit_back_faces=true
#   ray_bf_upoff    ray UP into the triangle's backface, hit_back_faces=false
#   ray_bf_upon     same, hit_back_faces=true
#   pt_areas        intersect_point inside AR, collide_with_areas=true/false
#   pt_excl         intersect_point at SPH centre, exclude=[SPH rid]
#   pt_mask         mask=2 -> SPH(layer1) invisible
#   is_excl         intersect_shape sphere at SPH centre, exclude=[SPH]
#   is_mask         intersect_shape at W2's box, mask=1 vs mask=2
#   cs_excl         collide_shape at SPH centre, exclude=[SPH]
#   cm_excl         cast_motion sphere at origin moving -z into W, exclude=[W]
#   ri_mask         get_rest_info sphere in SPH, mask=0
#   excl_mut        same params reused: does exclude persist/mutate?
#   excl_id         exclude=[ObjectID-as-RID?] — pass collider_id via
#                   PhysicsServer3D.body_get... actually exclude takes RIDs;
#                   test exclude with the BODY's rid vs a wrong rid
#   maxres          intersect_point where 2 bodies stack, max_results=1
#
# Rows: "Q <case> <payload>"

var case := "ray_plain"
var tick := 0
var W: StaticBody3D
var W2: StaticBody3D
var SPH: StaticBody3D
var AR: Area3D
var TM: StaticBody3D

class Watcher extends Node:
	var probe
	func _physics_process(_d: float) -> void:
		probe.on_tick()

func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--case="):
			case = a.substr(7)
	var w := Watcher.new()
	w.probe = self
	get_root().add_child(w)
	_build()

func _static_box(nm: String, pos: Vector3, size: Vector3, layer: int) -> StaticBody3D:
	var b := StaticBody3D.new()
	b.name = nm
	b.position = pos
	b.collision_layer = layer
	b.collision_mask = 0
	var cs := CollisionShape3D.new()
	var sh := BoxShape3D.new()
	sh.size = size
	cs.shape = sh
	b.add_child(cs)
	get_root().add_child(b)
	return b

func _build() -> void:
	W = _static_box("wall", Vector3(0, 0, -2), Vector3(4, 4, 0.2), 1)
	W2 = _static_box("wall2", Vector3(0, 0, -4), Vector3(4, 4, 0.2), 2)
	SPH = StaticBody3D.new()
	SPH.name = "sph"
	SPH.position = Vector3(0, 1, 0)
	SPH.collision_layer = 1
	SPH.collision_mask = 0
	var scs := CollisionShape3D.new()
	var ssh := SphereShape3D.new()
	ssh.radius = 0.5
	scs.shape = ssh
	SPH.add_child(scs)
	get_root().add_child(SPH)
	AR = Area3D.new()
	AR.name = "area"
	AR.position = Vector3(3, 1, 0)
	AR.collision_layer = 4
	AR.collision_mask = 0
	var acs := CollisionShape3D.new()
	var ash := BoxShape3D.new()
	ash.size = Vector3(0.5, 0.5, 0.5)
	acs.shape = ash
	AR.add_child(acs)
	get_root().add_child(AR)
	# upward-facing triangle (trimesh) at y=1
	TM = StaticBody3D.new()
	TM.name = "tri"
	TM.position = Vector3(-3, 1, 0)
	TM.collision_layer = 1
	TM.collision_mask = 0
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.add_vertex(Vector3(-0.5, 0, -0.5))
	st.add_vertex(Vector3(0.5, 0, -0.5))
	st.add_vertex(Vector3(0, 0, 0.7))
	st.generate_normals()
	var mesh := st.commit()
	var tcs := CollisionShape3D.new()
	var tsh := ConcavePolygonShape3D.new()
	tsh.set_faces(mesh.get_faces())
	tcs.shape = tsh
	TM.add_child(tcs)
	get_root().add_child(TM)

func on_tick() -> void:
	tick += 1
	if tick != 2:
		return
	var dss = get_root().get_world_3d().direct_space_state
	var sph_rid := SPH.get_rid() if is_instance_valid(SPH) else RID()
	var w_rid := W.get_rid()
	var w2_rid := W2.get_rid()
	match case:
		"ray_plain", "ray_excl", "ray_excl2", "ray_mask", "ray_mask0", \
		"ray_areas", "ray_areasoff", "ray_areason", "ray_hfi_in", \
		"ray_hfi_inoff", "ray_hfi_out", "ray_bf_down", "ray_bf_downoff", \
		"ray_bf_upoff", "ray_bf_upon":
			_ray(dss, sph_rid, w_rid, w2_rid)
		"pt_areas", "pt_areasoff", "pt_excl", "pt_mask":
			_point(dss, sph_rid)
		"is_excl", "is_mask", "maxres":
			_ishape(dss, sph_rid, w2_rid)
		"cs_excl":
			_cshape(dss, sph_rid)
		"cm_excl":
			_cmotion(dss, w_rid)
		"ri_mask":
			_restinfo(dss)
		"excl_mut":
			_excl_mut(dss, w_rid)
		"excl_id":
			_excl_id(dss, w_rid)
	fin()

func _ray(dss, sph_rid: RID, w_rid: RID, w2_rid: RID) -> void:
	var q := PhysicsRayQueryParameters3D.new()
	match case:
		"ray_plain":
			q.from = Vector3(0, 1, 0); q.to = Vector3(0, 1, -10)
		"ray_excl":
			q.from = Vector3(0, 1, 0); q.to = Vector3(0, 1, -10)
			q.exclude = [w_rid]
		"ray_excl2":
			q.from = Vector3(0, 1, 0); q.to = Vector3(0, 1, -10)
			q.exclude = [w_rid, w2_rid]
		"ray_mask":
			q.from = Vector3(0, 1, 0); q.to = Vector3(0, 1, -10)
			q.collision_mask = 2
		"ray_mask0":
			q.from = Vector3(0, 1, 0); q.to = Vector3(0, 1, -10)
			q.collision_mask = 0
		"ray_areas", "ray_areasoff", "ray_areason":
			# NB: dead scout assumed collide_with_areas defaults true —
			# ray_areas (default) measured n=0; ray_areason sets it
			# explicitly to test whether rays can see areas at all.
			q.from = Vector3(0, 1, 0); q.to = Vector3(6, 1, 0)
			if case == "ray_areasoff":
				q.collide_with_areas = false
			elif case == "ray_areason":
				q.collide_with_areas = true
		"ray_hfi_in", "ray_hfi_inoff":
			q.from = Vector3(0, 1, 0); q.to = Vector3(0, 1, 5)
			q.hit_from_inside = (case == "ray_hfi_in")
		"ray_hfi_out":
			q.from = Vector3(0, 1, 5); q.to = Vector3(0, 1, 0)
			q.hit_from_inside = true
		"ray_bf_down", "ray_bf_downoff":
			# NB: winding gives the triangle a -y front face (see report).
			q.from = Vector3(-3, 3, 0); q.to = Vector3(-3, 0, 0)
			if case == "ray_bf_downoff":
				q.hit_back_faces = false
		"ray_bf_upoff", "ray_bf_upon":
			q.from = Vector3(-3, 0, 0); q.to = Vector3(-3, 3, 0)
			q.hit_back_faces = (case == "ray_bf_upon")
	var h = dss.intersect_ray(q)
	var id := "-"
	var pos := "-"
	var nrm := "-"
	var col := "-"
	if h.size() > 0:
		id = str(h.get("collider_id", "?"))
		pos = _v(h.get("position", Vector3()))
		nrm = _v(h.get("normal", Vector3()))
		var co = h.get("collider")
		col = co.name if co != null else "null"
	print("Q %s n=%d col=%s pos=%s nrm=%s" % [case, h.size(), col, pos, nrm])

func _point(dss, sph_rid: RID) -> void:
	var q := PhysicsPointQueryParameters3D.new()
	match case:
		"pt_areas":
			q.position = Vector3(3, 1, 0)
			q.collide_with_areas = true
			q.collide_with_bodies = true
		"pt_areasoff":
			q.position = Vector3(3, 1, 0)
			q.collide_with_areas = false
			q.collide_with_bodies = true
		"pt_excl":
			q.position = Vector3(0, 1, 0)
			q.exclude = [sph_rid]
		"pt_mask":
			q.position = Vector3(0, 1, 0)
			q.collision_mask = 2
	var r = dss.intersect_point(q, 32)
	var names := []
	for h in r:
		var co = h.get("collider")
		names.append(co.name if co != null else "null")
	print("Q %s n=%d cols=%s" % [case, r.size(), ",".join(names)])

func _ishape(dss, sph_rid: RID, w2_rid: RID) -> void:
	var q := PhysicsShapeQueryParameters3D.new()
	var sh := SphereShape3D.new()
	sh.radius = 0.3
	q.shape = sh
	match case:
		"is_excl":
			q.transform = Transform3D.IDENTITY.translated(Vector3(0, 1, 0))
			q.exclude = [sph_rid]
		"is_mask":
			q.transform = Transform3D.IDENTITY.translated(Vector3(0, 0, -4))
			q.collision_mask = 1  # W2 is layer 2 -> invisible
		"maxres":
			sh.radius = 3.0
			q.shape = sh
			q.transform = Transform3D.IDENTITY.translated(Vector3(0, 1, -2))
	var r = dss.intersect_shape(q, 2 if case == "maxres" else 32)
	var names := []
	for h in r:
		var co = h.get("collider")
		names.append(co.name if co != null else "null")
	print("Q %s n=%d cols=%s" % [case, r.size(), ",".join(names)])

func _cshape(dss, sph_rid: RID) -> void:
	var q := PhysicsShapeQueryParameters3D.new()
	var sh := SphereShape3D.new()
	sh.radius = 0.3
	q.shape = sh
	q.transform = Transform3D.IDENTITY.translated(Vector3(0, 1, 0))
	q.exclude = [sph_rid]
	var r = dss.collide_shape(q)
	print("Q %s npts=%d" % [case, r.size()])

func _cmotion(dss, w_rid: RID) -> void:
	var q := PhysicsShapeQueryParameters3D.new()
	var sh := SphereShape3D.new()
	sh.radius = 0.3
	q.shape = sh
	q.transform = Transform3D.IDENTITY.translated(Vector3(0, 1, 0))
	q.motion = Vector3(0, 0, -10)
	q.exclude = [w_rid]
	var r = dss.cast_motion(q)
	print("Q %s cast=[%s,%s]" % [case, _f(r[0] if r.size() > 0 else -1),
		_f(r[1] if r.size() > 1 else -1)])

func _restinfo(dss) -> void:
	var q := PhysicsShapeQueryParameters3D.new()
	var sh := SphereShape3D.new()
	sh.radius = 0.3
	q.shape = sh
	q.transform = Transform3D.IDENTITY.translated(Vector3(0, 1, 0))
	q.collision_mask = 0
	var r = dss.get_rest_info(q)
	print("Q %s n=%d keys=%s" % [case, r.size(), str(r.keys())])

func _excl_mut(dss, w_rid: RID) -> void:
	# does a query mutate/copy the exclude array? reuse the same params
	var q := PhysicsRayQueryParameters3D.new()
	q.from = Vector3(0, 1, 0); q.to = Vector3(0, 1, -10)
	var ex: Array = [w_rid]
	q.exclude = ex
	var h1 = dss.intersect_ray(q)
	var ex_after := q.exclude
	var h2 = dss.intersect_ray(q)  # same params again
	ex_after.append(w_rid)  # append to the array AFTER assignment
	var h3 = dss.intersect_ray(q)
	print("Q %s h1=%d h2=%d exlen=%d h3=%d" % [case, h1.size(), h2.size(),
		ex_after.size(), h3.size()])

func _excl_id(dss, w_rid: RID) -> void:
	# exclude by a WRONG rid (W2) then the right one
	var q := PhysicsRayQueryParameters3D.new()
	q.from = Vector3(0, 1, 0); q.to = Vector3(0, 1, -3)
	q.exclude = [W2.get_rid()]
	var h1 = dss.intersect_ray(q)
	var q2 := PhysicsRayQueryParameters3D.new()
	q2.from = Vector3(0, 1, 0); q2.to = Vector3(0, 1, -3)
	q2.exclude = [w_rid]
	var h2 = dss.intersect_ray(q2)
	print("Q %s wrong_rid_hit=%d right_rid_hit=%d" % [case, h1.size(),
		h2.size()])

func _v(v: Vector3) -> String:
	return "%s,%s,%s" % [_f(v.x), _f(v.y), _f(v.z)]

func _f(x: float) -> String:
	return String.num(x, 4)

func fin() -> void:
	print("QSUM case=%s" % case)
	quit(0)
