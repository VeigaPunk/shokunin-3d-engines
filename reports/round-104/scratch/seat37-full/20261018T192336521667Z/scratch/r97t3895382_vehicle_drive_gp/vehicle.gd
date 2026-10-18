extends SceneTree
# r97 probe: VehicleBody3D + VehicleWheel3D raycast wheels — never measured.
#
# Rig: a 4-wheel "car": VehicleBody3D (box 1.6x0.4x0.8 at y=1.0) with four
# VehicleWheel3D children at (±0.7, 0, ±0.35), wheel radius 0.3,
# rest_length 0.4, travel 0.2, on a static floor at y=0.
# Wheel local position is the suspension TOP; ray cast downward.
#
# Cases:
#   drop      just drop — contact flags, settle height
#   drive     engine_force=400 on traction wheels from t=5 — velocity+
#   brake     drive to t=40 then brake=50 — deceleration
#   steer     steering=0.4 on front wheels + engine — heading change
#   skid      engine_force then read get_skidinfo/get_rpm
#   susp      suspension_stiffness=5 vs 50 vs 0 (--susp= param)
#   nowheel   no wheels at all — does the body fall through / error?
#   noroll    roll_influence=0.0 vs 0.1 — does it still roll?
#
# Rows: "VH t=.. pos=.. v=.. yawdeg=.. contact=4 rpm=.. skid=.."

var case := "drop"
var tick := 0
var car: VehicleBody3D
var wheels: Array = []
var susp := 50.0

class Watcher extends Node:
	var probe
	func _physics_process(_d: float) -> void:
		probe.on_tick()

func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--case="):
			case = a.substr(7)
		elif a.begins_with("--susp="):
			susp = float(a.substr(7))
	var w := Watcher.new()
	w.probe = self
	get_root().add_child(w)
	var f := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	var sh := BoxShape3D.new()
	sh.size = Vector3(200, 0.2, 200)
	cs.shape = sh
	f.add_child(cs)
	get_root().add_child(f)
	car = VehicleBody3D.new()
	car.position = Vector3(0, 1.0, 0)
	car.mass = 100.0
	car.can_sleep = false
	var ccs := CollisionShape3D.new()
	var csh := BoxShape3D.new()
	csh.size = Vector3(1.6, 0.4, 0.8)
	ccs.shape = csh
	car.add_child(ccs)
	if case != "nowheel":
		for i in 4:
			var wh := VehicleWheel3D.new()
			# x = front/back (+/-0.7), z = left/right (+/-0.35)
			wh.position = Vector3(0.7 if i < 2 else -0.7,
				0.0, 0.35 if i % 2 == 0 else -0.35)
			wh.wheel_radius = 0.3
			wh.wheel_rest_length = 0.4
			wh.suspension_travel = 0.2
			wh.suspension_stiffness = susp
			wh.suspension_max_force = 60000.0
			wh.damping_compression = 10.0
			wh.damping_relaxation = 12.0
			wh.wheel_friction_slip = 10.0
			wh.use_as_traction = (i >= 2)  # rear wheels drive
			wh.use_as_steering = (i < 2)   # front wheels steer
			if case == "noroll":
				wh.wheel_roll_influence = 0.0
			car.add_child(wh)
			wheels.append(wh)
	get_root().add_child(car)
	print("VH setup case=%s susp=%s wheels=%d" % [case,
		String.num(susp, 2), wheels.size()])

func on_tick() -> void:
	tick += 1
	match case:
		"drop", "nowheel", "susp", "noroll":
			if tick in [10, 30, 60, 120]:
				report()
			if tick == 120:
				fin()
		"drive":
			if tick == 5:
				car.engine_force = 400.0
			if tick in [10, 30, 60, 120]:
				report()
			if tick == 120:
				fin()
		"brake":
			if tick == 5:
				car.engine_force = 400.0
			if tick == 40:
				car.engine_force = 0.0
				car.brake = 50.0
			if tick in [30, 50, 80, 120]:
				report()
			if tick == 120:
				fin()
		"steer":
			if tick == 5:
				car.engine_force = 400.0
				car.steering = 0.4
			if tick in [30, 60, 90, 150]:
				report()
			if tick == 150:
				fin()
		"skid":
			if tick == 5:
				car.engine_force = 800.0
			if tick in [10, 30, 60]:
				report()
			if tick == 60:
				fin()

func report() -> void:
	var ncon := 0
	var rpm := 0.0
	var skid := 0.0
	for wh in wheels:
		if wh.is_in_contact():
			ncon += 1
		rpm += wh.get_rpm()
		skid += wh.get_skidinfo()
	var yaw := rad_to_deg(car.transform.basis.get_euler().y)
	print("VH t=%d pos=%s,%s,%s v=%s yawdeg=%s contact=%d rpm=%s skid=%s" % [
		tick, _f(car.position.x), _f(car.position.y), _f(car.position.z),
		_f(car.linear_velocity.length()), _f(yaw), ncon,
		_f(rpm / max(1, wheels.size())), _f(skid / max(1, wheels.size()))])

func _f(x: float) -> String:
	return String.num(x, 4)

func fin() -> void:
	print("VHSUM case=%s" % case)
	quit(0)
