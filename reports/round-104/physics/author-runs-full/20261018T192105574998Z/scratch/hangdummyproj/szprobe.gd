# r86 generated size probe: pad=0 statements
extends SceneTree


func _initialize() -> void:
	call_deferred("_run")



func _run() -> void:
	var mode := "guarded"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--arm="):
			mode = a.substr(6)
	var d = root.get_world_3d().direct_space_state
	var refused := d == null
	await physics_frame
	if mode == "deref":
		prints("CHILD_NOTE sz_deref pad=0 null=%s" % [str(refused)])
		prints("CHILD_RESULT sz_abort=%s" % d.get_class())
		quit(0)
		return
	prints("CHILD_NOTE sz_fetch pad=0 pf=%d" % [Engine.get_physics_frames()])
	prints("CHILD_RESULT sz_fetch=%s" % ("refused" if refused else "granted"))
	quit(0)
