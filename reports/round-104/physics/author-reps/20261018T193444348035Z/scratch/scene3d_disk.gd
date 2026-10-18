# Authored PackedScene .tscn save/reload with one valid and one loadable wrong-local control.
# run_battery.py --only scene3d_disk,scene3d_disk_wrong_local
extends SceneTree
const CHILD_LOCAL := Vector3(1, 2, -3)
const SCENE_PATH := "res://generated-scene3d.tscn"
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
	var wrong := "--wrong-local" in OS.get_cmdline_user_args()
	var source := Node3D.new()
	owned_nodes.append(source)
	source.name = "DiskRoot"
	var child := MeshInstance3D.new()
	child.name = "BoxVisual"
	child.mesh = BoxMesh.new()
	child.position = CHILD_LOCAL
	source.add_child(child)
	child.owner = source
	var packed := PackedScene.new()
	if packed.pack(source) != OK or ResourceSaver.save(packed, SCENE_PATH) != OK:
		return _fail("pack or save failed")
	var file := FileAccess.open(SCENE_PATH, FileAccess.READ)
	if file == null:
		return _fail("saved text file absent")
	var text := file.get_as_text()
	file.close()
	var original := "transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, %d, 2, -3)" % int(CHILD_LOCAL.x)
	var corrupted := "transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, %d, 2, -3)" % (int(CHILD_LOCAL.x) + 1)
	if text.count(original) != 1 or text.find("BoxVisual") < 0:
		return _fail("serialized child transform absent")
	if wrong:
		var write := FileAccess.open(SCENE_PATH, FileAccess.WRITE)
		if write == null:
			return _fail("cannot write wrong-local control")
		write.store_string(text.replace(original, corrupted))
		write.close()
	var loaded := ResourceLoader.load(SCENE_PATH, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE) as PackedScene
	if loaded == null:
		return _fail("saved scene did not load")
	var instance := loaded.instantiate() as Node3D
	if instance == null:
		return _fail("saved scene did not instantiate")
	owned_nodes.append(instance)
	instance.position = Vector3(10, 0, 5)
	root.add_child(instance)
	var loaded_child := instance.get_node_or_null("BoxVisual") as MeshInstance3D
	if loaded_child == null or loaded_child.mesh == null or source.get_node_or_null("BoxVisual") != child:
		return _fail("loaded or source subtree absent")
	if wrong:
		if loaded_child.position.distance_to(Vector3(2, 2, -3)) > 0.000001 or loaded_child.global_position.distance_to(Vector3(12, 2, 2)) > 0.000001 or loaded_child.global_position.distance_to(Vector3(11, 2, 2)) < 0.5:
			return _fail("wrong-local control did not load expected transform local=%s world=%s" % [loaded_child.position, loaded_child.global_position])
		if child.position.distance_to(Vector3(1, 2, -3)) > 0.000001:
			return _fail("source geometry changed")
		_cleanup()
		print("NEGATIVE REJECTED: scene3d_disk loadable_wrong_local source_intact=true loaded_world=12.000,2.000,2.000 expected_world=11.000,2.000,2.000 mesh_present=true")
		quit(2)
		return
	if loaded_child.position.distance_to(Vector3(1, 2, -3)) > 0.000001 or loaded_child.global_position.distance_to(Vector3(11, 2, 2)) > 0.000001:
		return _fail("loaded transform mismatch local=%s world=%s" % [loaded_child.position, loaded_child.global_position])
	if child.position.distance_to(Vector3(1, 2, -3)) > 0.000001:
		return _fail("source geometry changed")
	_cleanup()
	print("PASS scene3d_disk loaded_world=11.000,2.000,2.000 source_intact=true mesh_present=true")
	quit(0)

func _cleanup() -> void:
	for index in range(owned_nodes.size() - 1, -1, -1):
		var node := owned_nodes[index]
		if is_instance_valid(node):
			node.free()
	owned_nodes.clear()

func _fail(message: String) -> bool:
	_cleanup()
	push_error("scene3d_disk: " + message)
	quit(1)
	return true
