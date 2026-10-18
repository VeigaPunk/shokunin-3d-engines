extends SceneTree
# r100b_modes.gd — boundary seat: unstated-mode hunter with wall witnesses.
#
# Trajectory rig is identical to r100b_sched.gd (byte-identical copy of the
# r100 scout's rs_sched.gd), so `traj=` hashes are directly comparable.
# Extra witnesses:
#   BM_BOOT   knobs + argv split + engine-reported max_fps/time_scale
#   BM_PR     first rows_k and last rows_k process frames: delta, pf, ifr
#   BM_PH     first rows_k and last rows_k physics ticks: delta, y, vy, ifr
#   BM_END    counters + frames-per-tick histogram + steps_max + traj hash
#   BM_WF     per-frame wall us (own lines; dropped before byte-compare)
#   BM_WALL   wall histogram min/med/max (own line; dropped)
#   BM_FPS    engine-reported real fps (own line; dropped)
#   BM_TIME   wall ms (own line; dropped)
#
# Bounded: --ticks=N self-quit in _physics_process, --rows=K, frame guard.
# NOTE: _finalize() must not touch nodes (the tree is freed by then).

var n_pr := 0
var n_ph := 0
var ticks_target := 120
var rows_k := 8
var body: RigidBody3D
var fpt := []
var pr_at_tick := 0
var steps_this_frame := 0
var steps_max := 0
var traj := PackedStringArray()
var t0 := 0
var last_us := 0
var wall_us := []
var pr_head := []
var pr_tail := []
var ph_head := []
var ph_tail := []


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
	last_us = Time.get_ticks_usec()
	print("BM_BOOT tps=%d ip=%s maxfps=%d ts=%.6f jit=%.3f cap=%d ds=%s argz=%d userz=%d" % [
		Engine.physics_ticks_per_second,
		ProjectSettings.get_setting("physics/common/physics_interpolation", false),
		Engine.max_fps, Engine.time_scale,
		ProjectSettings.get_setting("physics/common/physics_jitter_fix", -1.0),
		ProjectSettings.get_setting("physics/common/max_physics_steps_per_frame", -1),
		ProjectSettings.get_setting("application/run/delta_smoothing", true),
		OS.get_cmdline_args().size(), ua.size()])
	print("BM_ARGV engine=%s user=%s" % [
		"|".join(OS.get_cmdline_args()), "|".join(ua)])


func _process(delta: float) -> bool:
	var now := Time.get_ticks_usec()
	n_pr += 1
	var wus := now - last_us
	last_us = now
	wall_us.append(wus)
	if n_pr <= rows_k * 5 or n_pr % 1000 == 0:
		print("BM_WF n=%d wus=%d" % [n_pr, wus])
	steps_max = maxi(steps_max, steps_this_frame)
	steps_this_frame = 0
	var row := "BM_PR n=%d pf=%d d=%.9f ifr=%.6f ts=%.6f" % [
		n_pr, Engine.get_physics_frames(), delta,
		Engine.get_physics_interpolation_fraction(), Engine.time_scale]
	if n_pr <= rows_k:
		pr_head.append(row)
	pr_tail.append(row)
	if pr_tail.size() > rows_k:
		pr_tail.remove_at(0)
	if n_pr > 400000:
		quit(9)
	return false


func _physics_process(delta: float) -> bool:
	n_ph += 1
	steps_this_frame += 1
	fpt.append(n_pr - pr_at_tick)
	pr_at_tick = n_pr
	traj.append("%.6f:%.6f" % [body.global_position.y, body.linear_velocity.y])
	var row := "BM_PH n=%d pf=%d d=%.9f y=%.6f vy=%.6f ifr=%.6f" % [
		n_ph, Engine.get_physics_frames(), delta,
		body.global_position.y, body.linear_velocity.y,
		Engine.get_physics_interpolation_fraction()]
	if n_ph <= rows_k:
		ph_head.append(row)
	ph_tail.append(row)
	if ph_tail.size() > rows_k:
		ph_tail.remove_at(0)
	if n_ph >= ticks_target:
		quit(0)
	return false


func _finalize() -> void:
	print("BM_HEAD_BEGIN")
	for r in pr_head:
		print(r)
	for r in ph_head:
		print(r)
	print("BM_TAIL_BEGIN")
	for r in pr_tail:
		print(r)
	for r in ph_tail:
		print(r)
	print("BM_TAIL_END")
	var hist := {}
	for v in fpt:
		hist[v] = hist.get(v, 0) + 1
	var keys := hist.keys()
	keys.sort()
	var hs := []
	for k in keys:
		hs.append("%d:%d" % [k, hist[k]])
	print("BM_END n_pr=%d n_ph=%d pf=%d ff=%d fpt=[%s] steps_max=%d traj=%s" % [
		n_pr, n_ph, Engine.get_physics_frames(), Engine.get_process_frames(),
		", ".join(hs), steps_max, "".join(traj).sha256_text().substr(0, 16)])
	var wall := {}
	for v in wall_us:
		var ms: int = int(v) / 1000
		wall[ms] = wall.get(ms, 0) + 1
	var wkeys := wall.keys()
	wkeys.sort()
	var ws := []
	for k in wkeys:
		ws.append("%dms:%d" % [k, wall[k]])
	var sorted_us := wall_us.duplicate()
	sorted_us.sort()
	var med := 0
	if sorted_us.size() > 0:
		med = sorted_us[sorted_us.size() / 2]
	var mn := 0
	var mx := 0
	if sorted_us.size() > 0:
		mn = sorted_us[0]
		mx = sorted_us[sorted_us.size() - 1]
	print("BM_WALL n=%d min_us=%d med_us=%d max_us=%d hist=[%s]" % [
		sorted_us.size(), mn, med, mx, ", ".join(ws)])
	print("BM_FPS real=%d" % Engine.get_frames_per_second())
	print("BM_TIME t=%d" % [Time.get_ticks_msec() - t0])
