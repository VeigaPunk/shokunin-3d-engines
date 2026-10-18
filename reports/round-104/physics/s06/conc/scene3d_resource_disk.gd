# Mesh resource isolation after .tscn save/load across three PackedScene instances.
# run_battery.py --only scene3d_resource_disk_local,scene3d_resource_disk_shared
extends SceneTree
const INITIAL_SIZE := Vector3.ONE
var owned_nodes: Array[Node3D] = []
var frames := 0

func _initialize() -> void:
	call_deferred("_run")

func _process(_delta: float) -> bool:
	frames += 1
	if frames > 1200:
		return _fail("frame bound exceeded")
	return false

func _run() -> void:
	var shared := "--shared" in OS.get_cmdline_user_args()
	var source := Node3D.new()
	owned_nodes.append(source)
	source.name = "ResourceRoot"
	var source_child := MeshInstance3D.new()
	source_child.name = "BoxVisual"
	var source_mesh := BoxMesh.new()
	source_mesh.size = INITIAL_SIZE
	source_mesh.resource_local_to_scene = not shared
	source_child.mesh = source_mesh
	source.add_child(source_child)
	source_child.owner = source
	var packed := PackedScene.new()
	if packed.pack(source) != OK:
		return _fail("pack failed")
	var scene_path := "res://generated-resource3d.tscn"
	if ResourceSaver.save(packed, scene_path) != OK:
		return _fail("save failed")
	var file := FileAccess.open(scene_path, FileAccess.READ)
	if file == null:
		return _fail("saved scene text missing")
	var saved_text := file.get_as_text()
	file.close()
	var flag_written := saved_text.contains("resource_local_to_scene = true")
	if flag_written == shared or not saved_text.contains("BoxMesh"):
		return _fail("saved mesh locality flag mismatch present=%s shared=%s" % [flag_written, shared])
	var loaded := ResourceLoader.load(scene_path, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE) as PackedScene
	if loaded == null:
		return _fail("load failed")
	var loaded_source := loaded.instantiate() as Node3D
	if loaded_source != null:
		owned_nodes.append(loaded_source)
	var first := loaded.instantiate() as Node3D
	var second := loaded.instantiate() as Node3D
	if first != null:
		owned_nodes.append(first)
	if second != null:
		owned_nodes.append(second)
	if first == null or second == null or loaded_source == null:
		return _fail("instantiate failed")
	root.add_child(loaded_source)
	root.add_child(first)
	root.add_child(second)
	var a := first.get_node_or_null("BoxVisual") as MeshInstance3D
	var b := second.get_node_or_null("BoxVisual") as MeshInstance3D
	if a == null or b == null or not (a.mesh is BoxMesh) or not (b.mesh is BoxMesh) or source_child.mesh != source_mesh:
		return _fail("mesh-bearing clone setup absent")
	var loaded_child := loaded_source.get_node_or_null("BoxVisual") as MeshInstance3D
	if loaded_child == null or not (loaded_child.mesh is BoxMesh):
		return _fail("loaded source mesh absent")
	var loaded_mesh := loaded_child.mesh as BoxMesh
	var mesh_a := a.mesh as BoxMesh
	var mesh_b := b.mesh as BoxMesh
	if mesh_a.size != Vector3.ONE or mesh_b.size != Vector3.ONE or loaded_mesh.size != Vector3.ONE:
		return _fail("initial mesh size mismatch first=%s second=%s loaded=%s" % [mesh_a.size, mesh_b.size, loaded_mesh.size])
	if mesh_a.resource_local_to_scene == shared or mesh_b.resource_local_to_scene == shared or loaded_mesh.resource_local_to_scene == shared:
		return _fail("resource locality flag mismatch")
	if shared:
		if mesh_a != mesh_b or mesh_a != loaded_mesh:
			return _fail("shared arm did not share source mesh")
	else:
		if mesh_a == mesh_b or mesh_a == loaded_mesh or mesh_b == loaded_mesh:
			return _fail("local arm did not isolate mesh resources")
	mesh_a.size = Vector3(2, 1, 1)
	if shared:
		if mesh_b.size != Vector3(2, 1, 1) or loaded_mesh.size != Vector3(2, 1, 1):
			return _fail("shared mutation did not propagate second=%s loaded=%s" % [mesh_b.size, loaded_mesh.size])
		_cleanup()
		print("NEGATIVE REJECTED: scene3d_resource_disk shared_mesh_mutation second_size=2.000,1.000,1.000 loaded_size=2.000,1.000,1.000 same_resource=true")
		quit(2)
		return
	if mesh_b.size != Vector3.ONE or mesh_a.size != Vector3(2, 1, 1) or loaded_mesh.size != Vector3.ONE:
		return _fail("local mutation leaked first=%s second=%s loaded=%s" % [mesh_a.size, mesh_b.size, loaded_mesh.size])
	_cleanup()
	print("PASS scene3d_resource_disk local_mesh_mutation first_size=2.000,1.000,1.000 second_size=1.000,1.000 distinct_resources=true")
	quit(0)

func _cleanup() -> void:
	for index in range(owned_nodes.size() - 1, -1, -1):
		var node := owned_nodes[index]
		if is_instance_valid(node):
			node.free()
	owned_nodes.clear()

func _fail(message: String) -> bool:
	_cleanup()
	push_error("scene3d_resource_disk: " + message)
	quit(1)
	return true
