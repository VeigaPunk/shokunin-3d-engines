extends SceneTree
# r98-scout: GLTF/GLB authored-asset surface under --headless (no --editor,
# no .godot import cache). One argv case selects one arm.
# usage: godot --headless --path <proj> --script res://gltf.gd -- <case>

const CLASSES := [
	"GLTFDocument", "GLTFState", "GLTFNode", "GLTFMesh", "GLTFAnimation",
	"GLTFSkeleton", "GLTFSkin", "GLTFBufferView", "GLTFAccessor",
	"GLTFTexture", "GLTFTextureSampler", "GLTFCamera", "GLTFLight",
	"GLTFPhysicsBody", "GLTFPhysicsShape", "GLTFSpecGloss",
	"GLTFDocumentExtension", "GLTFObjectModelProperty",
]

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var case := args[0] if args.size() > 0 else "cls"
	call_deferred("_run", case)

func _run(case: String) -> void:
	match case:
		"cls": _cls()
		"load_glb": _load_res("res://assets/tri.glb")
		"load_gltf": _load_res("res://assets/tri.gltf")
		"load_missing": _load_res("res://assets/absent.glb")
		"load_badmagic": _load_res("res://assets/badmagic.glb")
		"load_badjson": _load_res("res://assets/badjson.gltf")
		"load_empty": _load_res("res://assets/empty.glb")
		"doc_file": _doc_file("res://assets/tri.glb")
		"doc_gltf": _doc_file("res://assets/tri.gltf")
		"doc_nodes": _doc_file("res://assets/nodes_only.glb")
		"doc_badmagic": _doc_file("res://assets/badmagic.glb")
		"doc_badjson": _doc_file("res://assets/badjson.gltf")
		"doc_empty": _doc_file("res://assets/empty.glb")
		# r98 finisher edge: GLTFDocument on a missing file (ResourceLoader
		# missing was covered; append_from_file missing was not).
		"doc_missing": _doc_file("res://assets/absent.glb")
		"doc_buf": _doc_buf()
		"doc_abs": _doc_file(OS.get_user_data_dir().path_join("tri.glb"))
		"roundtrip": _roundtrip()
		_:
			print("GLTF unknown case=%s" % case)
			quit(1)
			return
	quit(0)

func _cls() -> void:
	print("GLTFCLS engine=%s" % Engine.get_version_info()["string"])
	for c in CLASSES:
		var ex := ClassDB.class_exists(c)
		var inst := "-"
		var nmeth := -1
		if ex:
			var can := ClassDB.can_instantiate(c)
			if can:
				var o = ClassDB.instantiate(c)
				if o == null:
					inst = "null"
				else:
					inst = "ok"
					if o is Node:
						o.free()
					elif o is Resource:
						pass
					elif o is RefCounted:
						# r98 finisher repair: RefCounted is an Object but
						# must not be free()'d — the dead ordering hit
						# "Attempted to free a RefCounted object" on
						# GLTFObjectModelProperty and aborted _cls before
						# SPOT/RECOG (rc still 0). Evidence:
						# evidence/cls_refcnt_bug.stdout.txt
						pass
					elif o is Object:
						o.free()
			else:
				inst = "no_instantiate"
			nmeth = ClassDB.class_get_method_list(c, true).size()
		print("CLS %s exists=%s inst=%s methods=%d" % [c, ex, inst, nmeth])
	var have := {}
	if ClassDB.class_exists("GLTFDocument"):
		for m in ClassDB.class_get_method_list("GLTFDocument", true):
			have[m["name"]] = true
		var line := "SPOT GLTFDocument"
		for n in ["append_from_file", "append_from_buffer",
				"append_from_scene", "generate_scene", "generate_buffer",
				"write_to_filesystem", "set_root_nodes", "get_supported_gltf_extensions"]:
			line += " %s=%s" % [n, "Y" if have.has(n) else "-"]
		print(line)
	# Does ResourceLoader even list .gltf/.glb as recognized load types?
	var rec := ResourceLoader.get_recognized_extensions_for_type("PackedScene")
	print("RECOG PackedScene=%s" % ",".join(rec))
	var recg := ResourceLoader.get_recognized_extensions_for_type("GLTFDocument")
	print("RECOG GLTFDocument=%s" % ",".join(recg))

func _walk(n: Node, depth: int, acc: Array) -> void:
	var extra := ""
	if n is MeshInstance3D:
		var m: Mesh = n.mesh
		extra = " mesh=%s tris=%d" % [m.get_class(),
			m.get_faces().size() / 3 if m else -1]
	acc.append("%s%s:%s%s" % [" ".repeat(depth * 2), n.name,
		n.get_class(), extra])
	for c in n.get_children():
		_walk(c, depth + 1, acc)

func _report_scene(root: Node, tag: String) -> void:
	if root == null:
		print("%s scene=null" % tag)
		return
	var acc: Array = []
	_walk(root, 0, acc)
	print("%s root=%s:%s pos=%s" % [tag, root.name, root.get_class(),
		str(root.position) if root is Node3D else "-"])
	for line in acc:
		print("%s TREE %s" % [tag, line])
	root.free()

func _load_res(path: String) -> void:
	var res = ResourceLoader.load(path)
	print("LOAD %s -> %s" % [path,
		res.get_class() if res != null else "null"])
	if res is PackedScene:
		var inst = res.instantiate()
		_report_scene(inst, "LOADINST")
	elif res != null:
		print("LOADSTATE class=%s" % res.get_class())
		if res.has_method("get_nodes"):
			print("LOADSTATE nodes=%d anims=%d" % [res.get_nodes().size(),
				res.get_animations().size() if res.has_method("get_animations") else -1])

func _doc_file(path: String) -> void:
	var doc = GLTFDocument.new()
	var state = GLTFState.new()
	var err = doc.append_from_file(path, state)
	print("DOC %s append_err=%d" % [path, err])
	if err != OK:
		return
	print("DOC %s state nodes=%d meshes=%d anims=%d skel=%d" % [
		path, state.get_nodes().size(), state.get_meshes().size(),
		state.get_animations().size(), state.get_skeletons().size()])
	var scene = doc.generate_scene(state)
	_report_scene(scene, "DOCSCENE")

func _doc_buf() -> void:
	var f := FileAccess.open("res://assets/tri.glb", FileAccess.READ)
	if f == null:
		print("DOCBUF open_err=%d" % FileAccess.get_open_error())
		return
	var bytes := f.get_buffer(f.get_length())
	f.close()
	var doc = GLTFDocument.new()
	var state = GLTFState.new()
	var err = doc.append_from_buffer(bytes, "res://assets/", state)
	print("DOCBUF append_err=%d bytes=%d" % [err, bytes.size()])
	if err != OK:
		return
	var scene = doc.generate_scene(state)
	_report_scene(scene, "DOCBUF")

func _roundtrip() -> void:
	# Build a small authored scene, export to GLB bytes, re-import.
	var src := Node3D.new()
	src.name = "RTSource"
	src.position = Vector3(3, 4, 5)
	var mi := MeshInstance3D.new()
	mi.name = "RTBox"
	mi.mesh = BoxMesh.new()
	mi.position = Vector3(-1, 0, 2)
	src.add_child(mi)
	mi.owner = src
	var doc = GLTFDocument.new()
	var state = GLTFState.new()
	var err = doc.append_from_scene(src, state)
	print("RT append_scene_err=%d nodes=%d meshes=%d" % [
		err, state.get_nodes().size(), state.get_meshes().size()])
	var gerr = -1
	var bytes := PackedByteArray()
	if err == OK:
		bytes = doc.generate_buffer(state)
		gerr = 0
		print("RT gen_buffer bytes=%d" % bytes.size())
	if bytes.size() > 0:
		var doc2 = GLTFDocument.new()
		var st2 = GLTFState.new()
		var rerr = doc2.append_from_buffer(bytes, "", st2)
		print("RT reimport_err=%d" % rerr)
		if rerr == OK:
			_report_scene(doc2.generate_scene(st2), "RTSCENE")
	src.free()
