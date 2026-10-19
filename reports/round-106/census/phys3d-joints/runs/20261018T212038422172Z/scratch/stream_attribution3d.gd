# Opt-in stream-attribution probe, not a default 12-case fixture.
# python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-stream-attribution
# Both arms: stdout exact STREAM_3D_STDOUT: spatial node ready, exit 0.
# --emit-stderr also prints STREAM_3D_STDERR to stderr; classifier rejects.
extends SceneTree

const MARKER := "STREAM_3D_STDOUT: spatial node ready"
const DIAGNOSTIC := "STREAM_3D_STDERR"

func _initialize() -> void:
	var spatial := Node3D.new()
	spatial.position = Vector3(2.0, 3.0, -4.0)
	get_root().add_child(spatial)
	if spatial.position != Vector3(2.0, 3.0, -4.0):
		printerr("ERROR: stream_attribution3d: spatial setup failed")
		quit(3)
		return
	print(MARKER)
	if "--emit-stderr" in OS.get_cmdline_user_args():
		printerr(DIAGNOSTIC)
	quit(0)
