extends SceneTree
# r98-boundary probe (namespace r98b): inventory pin + unstated-mode arms the
# r98-scout report left at "[?]" — the root_nodes entry point, the supported
# extension list, ResourceLoader.exists vs load, and write_to_filesystem.
# usage: godot --headless --path <proj> --script res://r98b_inv.gd -- <case>

const CLASSES := [
	"GLTFDocument", "GLTFState", "GLTFNode", "GLTFMesh", "GLTFAnimation",
	"GLTFSkeleton", "GLTFSkin", "GLTFBufferView", "GLTFAccessor",
	"GLTFTexture", "GLTFTextureSampler", "GLTFCamera", "GLTFLight",
	"GLTFPhysicsBody", "GLTFPhysicsShape", "GLTFSpecGloss",
	"GLTFDocumentExtension", "GLTFObjectModelProperty",
]

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	call_deferred("_run", args[0] if args.size() > 0 else "inv")

func _run(case: String) -> void:
	match case:
		"inv": _inv()
		"props": _props()
		"exts": _exts()
		"write": _write()
		_:
			print("INV unknown case=%s" % case)
			quit(1)
			return
	quit(0)

func _cat(o: Object) -> String:
	if o is Node:
		return "Node"
	if o is Resource:
		return "Resource"
	if o is RefCounted:
		return "RefCounted"
	return "Object"

func _chain(c: String) -> String:
	var s := c
	var p := String(ClassDB.get_parent_class(c))
	while p != "":
		s += "<" + p
		p = String(ClassDB.get_parent_class(p))
	return s

func _inv() -> void:
	print("INVBOUND engine=%s" % Engine.get_version_info()["string"])
	var n_ex := 0
	var n_ref := 0
	for c in CLASSES:
		var ex := ClassDB.class_exists(c)
		var can := false
		var cat := "-"
		if ex:
			n_ex += 1
			can = ClassDB.can_instantiate(c)
			if can:
				var o = ClassDB.instantiate(c)
				if o == null:
					cat = "null"
				else:
					cat = _cat(o)
					if cat == "RefCounted":
						n_ref += 1
					if o is Node:
						o.free()
		print("INV %s exists=%s can=%s inst=%s chain=%s" % [
			c, ex, can, cat, _chain(c)])
	print("INV n_asked=%d n_exists=%d n_refcounted=%d" % [
		CLASSES.size(), n_ex, n_ref])

func _props() -> void:
	var doc := GLTFDocument.new()
	var names := []
	for p in doc.get_property_list():
		names.append(String(p["name"]))
	names.sort()
	print("PROPS GLTFDocument n_props=%d props=%s" % [names.size(), ",".join(names)])
	var rootlike := []
	for m in ClassDB.class_get_method_list("GLTFDocument", true):
		if String(m["name"]).contains("root"):
			rootlike.append(String(m["name"]))
	rootlike.sort()
	print("PROPS doc_rootlike_methods=%s" % ",".join(rootlike))
	var st_rootlike := []
	for m in ClassDB.class_get_method_list("GLTFState", true):
		if String(m["name"]).contains("root"):
			st_rootlike.append(String(m["name"]))
	st_rootlike.sort()
	print("PROPS state_rootlike_methods=%s" % ",".join(st_rootlike))
	print("PROPS has_set_root_nodes=%s" % doc.has_method("set_root_nodes"))
	print("PROPS has_get_root_nodes=%s" % doc.has_method("get_root_nodes"))
	print("PROPS get_prop_root_nodes=%s" % str(doc.get("root_nodes")))
	doc.set("root_nodes", [])
	print("PROPS after_set_prop_root_nodes=%s" % str(doc.get("root_nodes")))
	print("PROPS classdb_has_class_get_property_list=%s" %
		ClassDB.has_method("class_get_property_list"))
	var st := GLTFState.new()
	var sn := []
	for p in st.get_property_list():
		sn.append(String(p["name"]))
	sn.sort()
	print("PROPS GLTFState n_props=%d props=%s" % [sn.size(), ",".join(sn)])

func _exts() -> void:
	var doc := GLTFDocument.new()
	var se: PackedStringArray = doc.get_supported_gltf_extensions()
	print("EXTS supported_n=%d list=%s" % [se.size(), ",".join(se)])
	print("EXTS res_exists_glb=%s" % ResourceLoader.exists("res://assets/tri.glb"))
	print("EXTS res_exists_gltf=%s" % ResourceLoader.exists("res://assets/tri.gltf"))
	print("EXTS res_exists_upper=%s" % ResourceLoader.exists("res://assets/tri_upper.GLB"))
	print("EXTS res_exists_absent=%s" % ResourceLoader.exists("res://assets/nope.tscn"))
	print("EXTS recog_ps=%s" % ",".join(
		ResourceLoader.get_recognized_extensions_for_type("PackedScene")))
	print("EXTS recog_gltfdoc=%s" % ",".join(
		ResourceLoader.get_recognized_extensions_for_type("GLTFDocument")))
	print("EXTS recog_resource=%s" % ",".join(
		ResourceLoader.get_recognized_extensions_for_type("Resource")))
	print("EXTS recog_empty=%s" % ",".join(
		ResourceLoader.get_recognized_extensions_for_type("")))

func _walk(n: Node, depth: int, tag: String) -> void:
	if n == null:
		print("%s null" % tag)
		return
	var extra := ""
	if n is MeshInstance3D and n.mesh != null:
		extra = " mesh=%s tris=%d" % [n.mesh.get_class(),
			n.mesh.get_faces().size() / 3]
	print("%s %s%s:%s%s" % [tag, " ".repeat(depth * 2), n.name, n.get_class(),
		extra])
	for c in n.get_children():
		_walk(c, depth + 1, tag)

func _write() -> void:
	print("WRITE mkdir_err=%d" % DirAccess.make_dir_recursive_absolute("res://out"))
	var root := Node3D.new()
	root.name = "WRoot"
	root.position = Vector3(1, 1, 1)
	var mi := MeshInstance3D.new()
	mi.name = "WBox"
	mi.mesh = BoxMesh.new()
	mi.position = Vector3(-1, 0, 2)
	root.add_child(mi)
	mi.owner = root
	var doc := GLTFDocument.new()
	var state := GLTFState.new()
	var err := doc.append_from_scene(root, state)
	print("WRITE append_err=%d nodes=%d meshes=%d" % [
		err, state.get_nodes().size(), state.get_meshes().size()])
	var buf := doc.generate_buffer(state)
	print("WRITE gen_bytes=%d" % buf.size())
	var werr := doc.write_to_filesystem(state, "res://out/write_export.glb")
	print("WRITE write_glb_err=%d" % werr)
	var f := FileAccess.open("res://out/write_export.glb", FileAccess.READ)
	if f == null:
		print("WRITE read_err=%d" % FileAccess.get_open_error())
	else:
		var filebytes := f.get_buffer(f.get_length())
		f.close()
		print("WRITE file_bytes=%d equal_to_gen=%s head=%s" % [
			filebytes.size(), str(filebytes == buf),
			filebytes.slice(0, 16).hex_encode()])
		var doc2 := GLTFDocument.new()
		var st2 := GLTFState.new()
		var rerr := doc2.append_from_file("res://out/write_export.glb", st2)
		print("WRITE reimport_err=%d" % rerr)
		if rerr == OK:
			var scene := doc2.generate_scene(st2)
			_walk(scene, 0, "WRITESCENE")
			if scene != null:
				scene.free()
	var werr2 := doc.write_to_filesystem(state, "res://out/write_export.gltf")
	print("WRITE write_gltf_err=%d" % werr2)
	var g := FileAccess.open("res://out/write_export.gltf", FileAccess.READ)
	if g == null:
		print("WRITE gltf_read_err=%d" % FileAccess.get_open_error())
	else:
		print("WRITE gltf_bytes=%d head=%s" % [g.get_length(),
			g.get_buffer(16).hex_encode()])
		g.close()
	root.free()
