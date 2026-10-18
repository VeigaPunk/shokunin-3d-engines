# Pack one Node3D/MeshInstance3D subtree and instantiate twice in scratch.
# run_battery.py --only scene3d_instances,scene3d_instances_wrong_local
# Exit 0 PASS scene3d_instances; exit 2 NEGATIVE REJECTED: scene3d_instances.
extends SceneTree
const CHILD_LOCAL := Vector3(1, 2, -3)
var frames := 0
var owned_nodes: Array[Node3D] = []

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
	source.name = "ReusableRoot"
	var child := MeshInstance3D.new()
	child.name = "BoxVisual"
	child.mesh = BoxMesh.new()
	child.position = CHILD_LOCAL
	source.add_child(child)
	child.owner = source
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
	first.position = Vector3(10, 0, 0)
	second.position = Vector3(-10, 0, 5)
	root.add_child(first)
	root.add_child(second)
	var a := first.get_node_or_null("BoxVisual") as MeshInstance3D
	var b := second.get_node_or_null("BoxVisual") as MeshInstance3D
	if a == null or b == null or a.mesh == null or b.mesh == null or a == b or first == second:
		return _fail("clone setup absent")
	if wrong:
		b.position = Vector3(2, 2, -3)
	if a.position.distance_to(Vector3(1, 2, -3)) > 0.000001 or a.global_position.distance_to(Vector3(11, 2, -3)) > 0.000001:
		return _fail("first clone mismatch local=%s world=%s" % [a.position, a.global_position])
	if source.get_node("BoxVisual") != child or child.position.distance_to(Vector3(1, 2, -3)) > 0.000001:
		return _fail("source changed")
	if wrong:
		if b.position.distance_to(Vector3(2, 2, -3)) > 0.000001 or b.global_position.distance_to(Vector3(-8, 2, 2)) > 0.000001 or b.global_position.distance_to(Vector3(-9, 2, 2)) < 0.5:
			return _fail("wrong-local control setup invalid local=%s world=%s" % [b.position, b.global_position])
		_cleanup()
		print("NEGATIVE REJECTED: scene3d_instances wrong_second_local source_intact=true first_world=11.000,2.000,-3.000 second_world=-8.000,2.000,2.000 expected_second=-9.000,2.000,2.000")
		quit(2)
		return
	if b.position.distance_to(Vector3(1, 2, -3)) > 0.000001 or b.global_position.distance_to(Vector3(-9, 2, 2)) > 0.000001:
		return _fail("second clone mismatch local=%s world=%s" % [b.position, b.global_position])
	_cleanup()
	print("PASS scene3d_instances source_intact=true first_world=11.000,2.000,-3.000 second_world=-9.000,2.000,2.000 distinct_nodes=true")
	quit(0)

func _cleanup() -> void:
	for index in range(owned_nodes.size() - 1, -1, -1):
		var node := owned_nodes[index]
		if is_instance_valid(node):
			node.free()
	owned_nodes.clear()

func _fail(message: String) -> bool:
	_cleanup()
	push_error("scene3d_instances: " + message)
	quit(1)
	return true
