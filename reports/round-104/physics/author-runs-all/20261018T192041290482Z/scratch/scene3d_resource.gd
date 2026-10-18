# Mesh resource isolation in two in-memory PackedScene instances.
# run_battery.py --only scene3d_resource_local,scene3d_resource_shared
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
	var first := packed.instantiate() as Node3D
	var second := packed.instantiate() as Node3D
	if first != null:
		owned_nodes.append(first)
	if second != null:
		owned_nodes.append(second)
	if first == null or second == null:
		return _fail("instantiate failed")
	root.add_child(first)
	root.add_child(second)
	var a := first.get_node_or_null("BoxVisual") as MeshInstance3D
	var b := second.get_node_or_null("BoxVisual") as MeshInstance3D
	if a == null or b == null or not (a.mesh is BoxMesh) or not (b.mesh is BoxMesh) or source_child.mesh != source_mesh:
		return _fail("mesh-bearing clone setup absent")
	var mesh_a := a.mesh as BoxMesh
	var mesh_b := b.mesh as BoxMesh
	if mesh_a.size != Vector3.ONE or mesh_b.size != Vector3.ONE or source_mesh.size != Vector3.ONE:
		return _fail("initial mesh size mismatch first=%s second=%s source=%s" % [mesh_a.size, mesh_b.size, source_mesh.size])
	if mesh_a.resource_local_to_scene == shared or mesh_b.resource_local_to_scene == shared:
		return _fail("resource locality flag mismatch")
	if shared:
		if mesh_a != mesh_b or mesh_a != source_mesh:
			return _fail("shared arm did not share source mesh")
	else:
		if mesh_a == mesh_b or mesh_a == source_mesh or mesh_b == source_mesh:
			return _fail("local arm did not isolate mesh resources")
	mesh_a.size = Vector3(2, 1, 1)
	if shared:
		if mesh_b.size != Vector3(2, 1, 1) or source_mesh.size != Vector3(2, 1, 1):
			return _fail("shared mutation did not propagate second=%s source=%s" % [mesh_b.size, source_mesh.size])
		_cleanup()
		print("NEGATIVE REJECTED: scene3d_resource shared_mesh_mutation second_size=2.000,1.000,1.000 source_size=2.000,1.000,1.000 same_resource=true")
		quit(2)
		return
	if mesh_b.size != Vector3.ONE or mesh_a.size != Vector3(2, 1, 1) or source_mesh.size != Vector3.ONE:
		return _fail("local mutation leaked first=%s second=%s source=%s" % [mesh_a.size, mesh_b.size, source_mesh.size])
	_cleanup()
	print("PASS scene3d_resource local_mesh_mutation first_size=2.000,1.000,1.000 second_size=1.000,1.000 distinct_resources=true")
	quit(0)

func _cleanup() -> void:
	for index in range(owned_nodes.size() - 1, -1, -1):
		var node := owned_nodes[index]
		if is_instance_valid(node):
			node.free()
	owned_nodes.clear()

func _fail(message: String) -> bool:
	_cleanup()
	push_error("scene3d_resource: " + message)
	quit(1)
	return true
