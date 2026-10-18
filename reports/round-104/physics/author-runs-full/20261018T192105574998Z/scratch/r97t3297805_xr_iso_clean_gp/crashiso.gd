extends SceneTree
# Bisect which ClassDB.instantiate() crashes headless at quit.
# arg: comma-separated class names

func _initialize() -> void:
	var names := PackedStringArray()
	for a in OS.get_cmdline_user_args():
		names = a.split(",")
	for c in names:
		if not ClassDB.class_exists(c):
			print("B %s absent" % c)
			continue
		if not ClassDB.can_instantiate(c):
			print("B %s no_instantiate" % c)
			continue
		var o = ClassDB.instantiate(c)
		if o == null:
			print("B %s null" % c)
			continue
		if o is RefCounted:
			print("B %s refcounted" % c)
			o.unreference()
		elif o is Node:
			print("B %s node" % c)
			o.free()
		else:
			print("B %s object" % c)
			o.free()
	print("B DONE")
	quit(0)
