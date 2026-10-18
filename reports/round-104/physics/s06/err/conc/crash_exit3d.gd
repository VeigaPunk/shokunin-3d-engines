# Opt-in signal-exit classifier fixture (never part of the default 12 cases).
# python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-crash-exit
# Normal: exit 1 + exact stdout CRASH_EXIT_3D: spatial node ready, silent stderr.
# --hold-open: same marker, still alive; parent sends SIGTERM; Python sees -15.
extends SceneTree

const MARKER := "CRASH_EXIT_3D: spatial node ready"

func _initialize() -> void:
	var spatial := Node3D.new()
	spatial.position = Vector3(2.0, 3.0, -4.0)
	get_root().add_child(spatial)
	if spatial.position != Vector3(2.0, 3.0, -4.0):
		printerr("ERROR: crash_exit3d: spatial setup failed")
		quit(3)
		return
	print(MARKER)
	if "--hold-open" in OS.get_cmdline_user_args():
		await create_timer(30.0).timeout
	quit(1)
