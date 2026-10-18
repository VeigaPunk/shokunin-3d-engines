# r96-scout probe 0: the actual ProjectSettings surface for the solver-internals
# axis. Every downstream bake keys off the names printed here. Prints
# name=value(hint) so the report can state the legal range of every knob.
extends SceneTree


func _initialize() -> void:
	print("ST engine_setting=%s version=%s" % [
			str(ProjectSettings.get_setting("physics/3d/physics_engine",
					"<unset>")),
			Engine.get_version_info()["string"]])
	var all := ProjectSettings.get_property_list()
	var names: Array = []
	for p in all:
		var n: String = p["name"]
		if n.begins_with("physics/"):
			names.append(n)
	names.sort()
	print("ST total_props=%d physics_props=%d" % [all.size(), names.size()])
	for n in names:
		var v: Variant = ProjectSettings.get_setting(n)
		var hint := ""
		for p in all:
			if String(p["name"]) == n:
				hint = "%d:%s" % [int(p["hint"]), str(p["hint_string"])]
				break
		print("ST P %s = %s (%s) h=%s" % [n, str(v), type_string(typeof(v)),
				hint])
	# Effective server-side reads for the two body knobs this axis touches.
	var b := PhysicsServer3D.body_create()
	PhysicsServer3D.body_set_mode(b, PhysicsServer3D.BODY_MODE_RIGID)
	print("ST SRV body_get_param LINEAR_DAMP=%s ANGULAR_DAMP=%s BOUNCE=%s" % [
			str(PhysicsServer3D.body_get_param(b,
					PhysicsServer3D.BODY_PARAM_LINEAR_DAMP)),
			str(PhysicsServer3D.body_get_param(b,
					PhysicsServer3D.BODY_PARAM_ANGULAR_DAMP)),
			str(PhysicsServer3D.body_get_param(b,
					PhysicsServer3D.BODY_PARAM_BOUNCE))])
	PhysicsServer3D.free_rid(b)
	quit(0)
