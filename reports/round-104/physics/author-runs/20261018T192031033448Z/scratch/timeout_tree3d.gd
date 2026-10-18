# Opt-in 3D process-group timeout contrast, not a seeded default case.
# python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout
# Clean: exact stdout TREE_TIMEOUT_3D: spatial node ready, exit 0.
# --hold-open: child witness pidfile appears, marker prints, timer holds 30s.
extends SceneTree

const MARKER := "TREE_TIMEOUT_3D: spatial node ready"

func _initialize() -> void:
	var spatial := Node3D.new()
	spatial.position = Vector3(2.0, 3.0, -4.0)
	get_root().add_child(spatial)
	if spatial.position != Vector3(2.0, 3.0, -4.0):
		printerr("ERROR: timeout_tree3d: spatial setup failed")
		quit(3)
		return
	if "--hold-open" in OS.get_cmdline_user_args():
		var helper := ProjectSettings.globalize_path("res://timeout_descendant.py")
		var pidfile := ProjectSettings.globalize_path("res://timeout-descendant.json")
		var spawned := OS.create_process("/usr/bin/python3", PackedStringArray([helper, pidfile]), false)
		if spawned <= 0:
			printerr("ERROR: timeout_tree3d: descendant launch failed")
			quit(3)
			return
		var deadline := Time.get_ticks_msec() + 2000
		while not FileAccess.file_exists(pidfile) and Time.get_ticks_msec() < deadline:
			await create_timer(0.02).timeout
		if not FileAccess.file_exists(pidfile):
			printerr("ERROR: timeout_tree3d: descendant witness absent")
			quit(3)
			return
	print(MARKER)
	if "--hold-open" in OS.get_cmdline_user_args():
		await create_timer(30.0).timeout
	quit(0)
