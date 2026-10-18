extends SceneTree
# r97 adjacent edge (scout-finisher add-on): WHAT does
# ClassDB.instantiate("XRServer") return, and does an UNFREED instance
# still poison teardown? crashiso.gd showed instantiate+free -> SIGSEGV
# at quit. Three arms via --case=:
#   same   instance identity vs Engine.get_singleton("XRServer")
#   keep   instantiate, hold ref, never free -> still crashes at quit?
#   dbl    two instantiate() calls -> same object twice?

var hold: Array = []

func _initialize() -> void:
	var case := "same"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--case="):
			case = a.substr(7)
	match case:
		"same":
			var s = Engine.get_singleton("XRServer")
			var o = ClassDB.instantiate("XRServer")
			print("XR singleton=%s inst=%s identical=%s" % [s, o, s == o])
			hold.append(o)  # do not free: observe only
		"keep":
			var o = ClassDB.instantiate("XRServer")
			print("XR keep obj=%s" % o)
			hold.append(o)
		"dbl":
			var o1 = ClassDB.instantiate("XRServer")
			var o2 = ClassDB.instantiate("XRServer")
			print("XR dbl same=%s" % (o1 == o2))
			hold.append(o1)
			hold.append(o2)
	print("XR DONE case=%s" % case)
	quit(0)
