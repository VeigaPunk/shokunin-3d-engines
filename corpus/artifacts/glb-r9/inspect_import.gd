# Scratch-only Godot imported scene inspection; no rendering.
extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene := load("res://triangle.glb") as PackedScene
	if scene == null:
		printerr("IMPORT_REJECTED: no PackedScene")
		quit(2)
		return
	var instance := scene.instantiate()
	if instance == null:
		printerr("IMPORT_REJECTED: failed to instantiate")
		quit(2)
		return
	root.add_child(instance)
	print("IMPORT_ROOT name=%s children=%d" % [instance.name, instance.get_child_count()])
	for child in instance.get_children():
		print("IMPORT_CHILD name=%s type=%s position=%s children=%d" % [child.name, child.get_class(), str(child.position) if child is Node3D else "n/a", child.get_child_count()])
		if child is MeshInstance3D and child.mesh != null:
			var mesh: Mesh = child.mesh
			var arrays: Array = mesh.surface_get_arrays(0)
			var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			print("IMPORT_MESH surfaces=%d vertices=%d points=%s" % [mesh.get_surface_count(), mesh.surface_get_array_len(0), str(verts)])
		for grandchild in child.get_children():
			print("IMPORT_GRANDCHILD name=%s type=%s position=%s" % [grandchild.name, grandchild.get_class(), str(grandchild.position) if grandchild is Node3D else "n/a"])
			if grandchild is MeshInstance3D and grandchild.mesh != null:
				print("IMPORT_MESH surfaces=%d vertices=%d" % [grandchild.mesh.get_surface_count(), grandchild.mesh.surface_get_array_len(0)])
	quit(0)
