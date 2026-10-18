extends SceneTree
# r100-scout probe 5: census for the rate surface — Engine knobs, the argv split,
# the ProjectSettings keys this round pivots on, and the rate-relevant ClassDB
# rows. One child per backend, 3 reps.

func _initialize() -> void:
	print("CLS_ENGINE maxfps=%d ts=%.6f tps=%d ipf=%s ffps=%s pframes=%d pframes=%d" % [
		Engine.max_fps, Engine.time_scale, Engine.physics_ticks_per_second,
		Engine.has_method("get_physics_interpolation_fraction"),
		Engine.has_method("set_physics_interpolation_enabled"),
		Engine.get_process_frames(), Engine.get_physics_frames()])
	var keys := [
		"application/run/max_fps",
		"application/run/delta_smoothing",
		"physics/common/physics_ticks_per_second",
		"physics/common/max_physics_steps_per_frame",
		"physics/common/physics_jitter_fix",
		"physics/common/physics_interpolation",
		"physics/common/enable_object_picking",
		"debug/settings/fps/force_fps",
	]
	for k in keys:
		var v: Variant = ProjectSettings.get_setting(k, "<absent>")
		print("CLS_SET %s = %s (%s)" % [k, str(v), type_string(typeof(v))])
	print("CLS_ARGV engine=%s" % "|".join(OS.get_cmdline_args()))
	print("CLS_USER user=%s" % "|".join(OS.get_cmdline_user_args()))
	for c in ["PhysicalBoneSimulator3D", "PhysicalBone3D", "Skeleton3D",
			"RemoteTransform3D", "Area3D", "SceneTree", "MainLoop"]:
		print("CLS_CLASS %s exists=%s inst=%s" % [c, ClassDB.class_exists(c),
			ClassDB.can_instantiate(c) if ClassDB.class_exists(c) else false])
	print("CLS_DONE")
	quit(0)
