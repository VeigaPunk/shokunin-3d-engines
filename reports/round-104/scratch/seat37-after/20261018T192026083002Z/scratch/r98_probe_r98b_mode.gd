extends SceneTree
# r98-boundary probe (namespace r98b): attack the r98-scout unstated modes.
#   * magic-vs-extension discrimination (scout §8: "not authored")
#   * external relative buffer URI + append_from_buffer base-path semantics
#   * path forms: user://, relative-to-cwd, upper-case extension
#   * engine-authored physics payload (OMI extensions) across backends
# usage: godot --headless --path <proj> --script res://r98b_mode.gd -- <case>

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	call_deferred("_run", args[0] if args.size() > 0 else "help")

func _run(case: String) -> void:
	match case:
		"glb_as_gltf": _file("res://assets/glb_as_gltf.gltf")
		"json_as_glb": _file("res://assets/json_as_glb.glb")
		"magic_only": _file("res://assets/magic_only.glb")
		"magic_badjson": _file("res://assets/magic_badjson.glb")
		"magic_truncated": _file("res://assets/magic_truncated.glb")
		"badmagic_badjson": _file("res://assets/badmagic_badjson.glb")
		"glb_version3": _file("res://assets/glb_version3.glb")
		"ext_bin_file": _file("res://assets/ext_bin.gltf")
		"ext_resuri_file": _file("res://assets/ext_resuri.gltf")
		"ext_bin_buf_good": _buf("res://assets/ext_bin.gltf", "res://assets/")
		"ext_bin_buf_wrong": _buf("res://assets/ext_bin.gltf", "res://wrong/")
		"ext_bin_buf_empty": _buf("res://assets/ext_bin.gltf", "")
		"ext_resuri_buf_empty": _buf("res://assets/ext_resuri.gltf", "")
		"ext_bin_abs": _file(OS.get_user_data_dir().path_join("ext_bin.gltf"))
		"doc_user": _file("user://tri.glb")
		"doc_rel": _file("assets/tri.glb")
		"load_upper": _load_res("res://assets/tri_upper.GLB")
		"phys_gen": _phys_gen()
		"phys_import": _file("res://assets/phys_gen.glb")
		_:
			print("MODE unknown case=%s" % case)
			quit(1)
			return
	quit(0)

func _walk(n: Node, depth: int, tag: String) -> void:
	if n == null:
		print("%s null" % tag)
		return
	var extra := ""
	if n is MeshInstance3D and n.mesh != null:
		extra = " mesh=%s tris=%d" % [n.mesh.get_class(),
			n.mesh.get_faces().size() / 3]
	if n is CollisionShape3D and n.shape != null:
		extra = " shape=%s" % n.shape.get_class()
	if n is PhysicsBody3D:
		extra += " body_class=%s" % n.get_class()
	if n is RigidBody3D:
		extra += " mass=%s" % str(n.mass)
	print("%s %s%s:%s%s" % [tag, " ".repeat(depth * 2), n.name, n.get_class(),
		extra])
	for c in n.get_children():
		_walk(c, depth + 1, tag)

func _file(path: String) -> void:
	var doc := GLTFDocument.new()
	var state := GLTFState.new()
	var err := doc.append_from_file(path, state)
	print("MODE %s append_err=%d" % [path, err])
	if err != OK:
		return
	print("MODE %s nodes=%d meshes=%d anims=%d skel=%d" % [path,
		state.get_nodes().size(), state.get_meshes().size(),
		state.get_animations().size(), state.get_skeletons().size()])
	var scene := doc.generate_scene(state)
	_walk(scene, 0, "MODESCENE")
	if scene != null:
		scene.free()

func _buf(path: String, base: String) -> void:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		print("MODEBUF %s open_err=%d" % [path, FileAccess.get_open_error()])
		return
	var bytes := f.get_buffer(f.get_length())
	f.close()
	var doc := GLTFDocument.new()
	var state := GLTFState.new()
	var err := doc.append_from_buffer(bytes, base, state)
	print("MODEBUF %s base=[%s] append_err=%d" % [path, base, err])
	if err != OK:
		return
	print("MODEBUF %s nodes=%d meshes=%d" % [path,
		state.get_nodes().size(), state.get_meshes().size()])
	var scene := doc.generate_scene(state)
	_walk(scene, 0, "MODEBUFSCENE")
	if scene != null:
		scene.free()

func _load_res(path: String) -> void:
	var res = ResourceLoader.load(path)
	print("MODE LOAD %s -> %s" % [path, res.get_class() if res != null else "null"])

func _phys_gen() -> void:
	print("PHYSGEN mkdir_err=%d" % DirAccess.make_dir_recursive_absolute("res://out"))
	var root := Node3D.new()
	root.name = "PhysRoot"
	var body := RigidBody3D.new()
	body.name = "PhysBody"
	body.mass = 3.5
	var cs := CollisionShape3D.new()
	cs.name = "PhysShape"
	var box := BoxShape3D.new()
	box.size = Vector3(1, 2, 3)
	cs.shape = box
	body.add_child(cs)
	cs.owner = body
	root.add_child(body)
	body.owner = root
	var doc := GLTFDocument.new()
	var state := GLTFState.new()
	var err := doc.append_from_scene(root, state)
	print("PHYSGEN append_err=%d nodes=%d meshes=%d" % [err,
		state.get_nodes().size(), state.get_meshes().size()])
	var bytes := doc.generate_buffer(state)
	print("PHYSGEN bytes=%d" % bytes.size())
	var js: Dictionary = state.get_json()
	var keys := []
	for k in js.keys():
		keys.append(String(k))
	keys.sort()
	print("PHYSGEN json_keys=%s" % ",".join(keys))
	print("PHYSGEN json_extensionsUsed=%s" % str(js.get("extensionsUsed", [])))
	var f := FileAccess.open("res://out/phys_gen.glb", FileAccess.WRITE)
	if f == null:
		print("PHYSGEN write_err=%d" % FileAccess.get_open_error())
	else:
		f.store_buffer(bytes)
		f.close()
		print("PHYSGEN wrote_bytes=%d" % bytes.size())
	var doc2 := GLTFDocument.new()
	var st2 := GLTFState.new()
	var rerr := doc2.append_from_buffer(bytes, "", st2)
	print("PHYSGEN reimport_err=%d" % rerr)
	if rerr == OK:
		var scene := doc2.generate_scene(st2)
		_walk(scene, 0, "PHYSGEN_SCENE")
		if scene != null:
			scene.free()
	root.free()
