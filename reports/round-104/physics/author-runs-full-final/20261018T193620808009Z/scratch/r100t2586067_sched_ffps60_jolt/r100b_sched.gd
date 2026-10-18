extends SceneTree
# r100-scout probe 1: the headless main-loop rate surface.
#
# Witnesses, per run:
#   RS_BOOT  project/Engine rate knobs + the raw argv split (engine vs user)
#   RS_PR    the first K process frames: delta, physics frame, interp fraction
#   RS_PH    the first K physics ticks + every 30th: delta, y, vy
#   RS_END   counters + the process-frames-per-physics-tick histogram +
#            a sha256 of the whole per-tick trajectory ("%.6f:%.6f" y:vy)
#   RS_TIME  wall ms (separate line so reps can be byte-compared without it)
#
# Bounded two ways: --ticks=N (self-quit from _physics_process) and, for the
# --quit-after cells, a ticks target large enough that the engine flag is what
# ends the run.
# NOTE: _finalize() must not touch nodes (the tree is freed by then).

var n_pr := 0
var n_ph := 0
var ticks_target := 120
var rows_k := 6
var body: RigidBody3D
var fpt := []
var pr_at_tick := 0
var traj := PackedStringArray()
var t0 := 0
var pr_rows := []
var ph_rows := []


func _initialize() -> void:
	var ua := OS.get_cmdline_user_args()
	for x in ua:
		if x.begins_with("--ticks="):
			ticks_target = int(x.get_slice("=", 1))
		if x.begins_with("--rows="):
			rows_k = int(x.get_slice("=", 1))
	var stage := Node3D.new()
	stage.name = "Stage"
	root.add_child(stage)
	body = RigidBody3D.new()
	body.name = "Ball"
	var cs := CollisionShape3D.new()
	var sp := SphereShape3D.new()
	sp.radius = 0.5
	cs.shape = sp
	body.add_child(cs)
	body.position = Vector3(0, 5, 0)
	stage.add_child(body)
	t0 = Time.get_ticks_msec()
	print("RS_BOOT tps=%d ip=%s maxfps=%d ts=%.6f jit=%.3f cap=%d ds=%s argz=%d userz=%d" % [
		Engine.physics_ticks_per_second,
		ProjectSettings.get_setting("physics/common/physics_interpolation", false),
		Engine.max_fps, Engine.time_scale,
		ProjectSettings.get_setting("physics/common/physics_jitter_fix", -1.0),
		ProjectSettings.get_setting("physics/common/max_physics_steps_per_frame", -1),
		ProjectSettings.get_setting("application/run/delta_smoothing", true),
		OS.get_cmdline_args().size(), ua.size()])
	print("RS_ARGV engine=%s user=%s" % [
		"|".join(OS.get_cmdline_args()), "|".join(ua)])


func _process(delta: float) -> bool:
	n_pr += 1
	if n_pr <= rows_k:
		pr_rows.append("RS_PR n=%d pf=%d d=%.9f ifr=%.6f ts=%.6f" % [
			n_pr, Engine.get_physics_frames(), delta,
			Engine.get_physics_interpolation_fraction(), Engine.time_scale])
	if n_pr > 200000:
		quit(9)
	return false


func _physics_process(delta: float) -> bool:
	n_ph += 1
	fpt.append(n_pr - pr_at_tick)
	pr_at_tick = n_pr
	traj.append("%.6f:%.6f" % [body.global_position.y, body.linear_velocity.y])
	if n_ph <= rows_k or n_ph % 30 == 0:
		ph_rows.append("RS_PH n=%d pf=%d d=%.9f y=%.6f vy=%.6f ifr=%.6f" % [
			n_ph, Engine.get_physics_frames(), delta,
			body.global_position.y, body.linear_velocity.y,
			Engine.get_physics_interpolation_fraction()])
	if n_ph >= ticks_target:
		quit(0)
	return false


func _finalize() -> void:
	for r in pr_rows:
		print(r)
	for r in ph_rows:
		print(r)
	var hist := {}
	for v in fpt:
		hist[v] = hist.get(v, 0) + 1
	var keys := hist.keys()
	keys.sort()
	var hs := []
	for k in keys:
		hs.append("%d:%d" % [k, hist[k]])
	print("RS_END n_pr=%d n_ph=%d pf=%d ff=%d fpt=[%s] traj=%s" % [
		n_pr, n_ph, Engine.get_physics_frames(), Engine.get_process_frames(),
		", ".join(hs), "".join(traj).sha256_text().substr(0, 16)])
	print("RS_TIME t=%d" % [Time.get_ticks_msec() - t0])
