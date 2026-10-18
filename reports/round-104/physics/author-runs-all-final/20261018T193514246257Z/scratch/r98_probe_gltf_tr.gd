extends SceneTree
# r98-scout finisher edge probe: transform fidelity through
# GLTFDocument.generate_scene. The dead seat's _walk() reports names/classes
# only; this probe prints each Node3D's position/scale so the authored TRS
# and matrix forms are measured, not assumed.
# usage: godot --headless --path <proj> --script res://gltf_tr.gd -- <case>

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var case := args[0] if args.size() > 0 else "nodes"
	call_deferred("_run", case)

func _run(case: String) -> void:
	match case:
		"nodes": _tr("res://assets/nodes_only.glb")
		"tri": _tr("res://assets/tri.glb")
		_:
			print("TR unknown case=%s" % case)
			quit(1)
			return
	quit(0)

func _walk(n: Node, depth: int) -> void:
	var t := ""
	if n is Node3D:
		var o: Node3D = n
		t = " pos=%s rot=%s scale=%s" % [o.position, o.rotation, o.scale]
	print("TR %s%s:%s%s" % [" ".repeat(depth * 2), n.name, n.get_class(), t])
	for c in n.get_children():
		_walk(c, depth + 1)

func _tr(path: String) -> void:
	var doc = GLTFDocument.new()
	var state = GLTFState.new()
	var err = doc.append_from_file(path, state)
	print("TRDOC %s append_err=%d" % [path, err])
	if err != OK:
		return
	var scene = doc.generate_scene(state)
	if scene == null:
		print("TRDOC scene=null")
		return
	_walk(scene, 0)
	scene.free()
