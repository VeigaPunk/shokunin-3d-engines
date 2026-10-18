extends SceneTree
# r97 probe: CharacterBody3D edge classes beyond the fixture set
# (floor3d/slope3d/body3d cover grounded slide, floor_max_angle,
# floor_stop_on_slope, basic motion_mode). These arms measure the params
# the corpus never touched.
#
# Rig: capsule CharacterBody3D (r=0.25, h=1.0, spawn varies per case),
# static floor slab / ramp / wall / ceiling / moving platform per case.
# Each tick sets .velocity then calls move_and_slide(); we print position,
# is_on_floor/wall/ceiling flags, get_real_velocity(), slide count.
#
# Cases:
#   snap_def      default floor_snap_length, walk off a 0.2 step while grounded
#   snap_big      floor_snap_length=1.0, same step — stays on floor?
#   snap0         floor_snap_length=0, walk down a 20 deg ramp — loses floor?
#   snap_ramp     snap=0.3 walking down same ramp — glued?
#   ceil_on       jump into a ceiling, slide_on_ceiling=true — slides?
#   ceil_off      slide_on_ceiling=false — vy zeroed on ceiling hit?
#   plat_leave    stand on moving platform, walk off it — velocity inherit?
#   plat_jump     jump straight up on moving platform — land back?
#   plat_ride     platform rises — rider carried? real velocity vs platform?
#   wallslide     wall_min_slide_angle=0.2 vs 0.8 into an angled wall
#   margin_lo     safe_margin=0.001 vs margin_hi 0.1 — floor detect, collide
#   float         motion_mode=FLOATING on floor — is_on_floor?
#   constspd      floor_constant_speed=true on a 20 deg downslope — vx same?
#   constspd_off  false — downslope accelerates?
#   blockwall     floor_block_on_wall=false — grounded drive THROUGH wall?
#   blockwall_on  true — stops?
#   maxslides     max_slides=1 crossing a V-groove (two walls)
#   realvel       run into wall head-on — velocity stays 5, real_velocity->0?
#   updir         up_direction=+Z on a Z-tilted floor — is_on_floor?
#   recovery      teleport INTO the floor, recovery_as_collision on vs off
#   stop_on_ceil  floor_stop_on_slope doesn't apply to ceilings; measure vy
#
# Rows: "CB t=.. pos=.. rv=.. fl=.. wl=.. ce=.. n=.."

var case := "snap_def"
var tick := 0
var cb: CharacterBody3D
var plat: AnimatableBody3D
var plat_v := Vector3.ZERO

class Watcher extends Node:
	var probe
	func _physics_process(_d: float) -> void:
		probe.on_tick()

func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--case="):
			case = a.substr(7)
	var w := Watcher.new()
	w.probe = self
	get_root().add_child(w)
	_build()

func _slab(nm: String, pos: Vector3, size: Vector3, rot_deg := 0.0) -> StaticBody3D:
	var b := StaticBody3D.new()
	b.name = nm
	b.position = pos
	b.rotation_degrees = Vector3(0, 0, rot_deg)
	var cs := CollisionShape3D.new()
	var sh := BoxShape3D.new()
	sh.size = size
	cs.shape = sh
	b.add_child(cs)
	get_root().add_child(b)
	return b

func _cb(pos: Vector3) -> CharacterBody3D:
	var b := CharacterBody3D.new()
	b.name = "cb"
	b.position = pos
	b.motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
	b.floor_stop_on_slope = false
	b.max_slides = 6
	b.safe_margin = 0.08
	var cs := CollisionShape3D.new()
	var sh := CapsuleShape3D.new()
	sh.radius = 0.25
	sh.height = 1.0
	cs.shape = sh
	b.add_child(cs)
	get_root().add_child(b)
	return b

func _platform(pos: Vector3) -> AnimatableBody3D:
	var b := AnimatableBody3D.new()
	b.name = "plat"
	b.position = pos
	b.sync_to_physics = true
	var cs := CollisionShape3D.new()
	var sh := BoxShape3D.new()
	sh.size = Vector3(4, 0.2, 4)
	cs.shape = sh
	b.add_child(cs)
	get_root().add_child(b)
	return b

func _build() -> void:
	match case:
		"snap_def", "snap_big", "snap0", "snapx_def", "snapx_0":
			# 0.2-high step at x=+2: floor y=0 then a step down to -0.2
			# NB dead-scout flaw: spawn x=-2 reaches the edge only at the
			# last tick (2 m/s, 120 t = 4 m) -> snap arms never diverge.
			# snapx_* spawns at x=1.5 (edge crossed ~t=15).
			_slab("f1", Vector3(0, -0.05, 0), Vector3(4, 0.1, 4))
			_slab("f2", Vector3(4, -0.25, 0), Vector3(8, 0.1, 4))
			if case.begins_with("snapx"):
				cb = _cb(Vector3(1.5, 0.5, 0))
				if case == "snapx_0":
					cb.floor_snap_length = 0.0
			else:
				cb = _cb(Vector3(-2, 0.5, 0))
				if case == "snap_big":
					cb.floor_snap_length = 1.0
				elif case == "snap0":
					cb.floor_snap_length = 0.0
		"snap_ramp":
			_slab("ramp", Vector3(0, -0.3, 0), Vector3(8, 0.1, 4), -20.0)
			cb = _cb(Vector3(-2, 1.0, 0))
			cb.floor_snap_length = 0.3
		"ceil_on", "ceil_off":
			_slab("floor", Vector3(0, -0.05, 0), Vector3(8, 0.1, 8))
			_slab("ceil", Vector3(0, 1.3, 0), Vector3(8, 0.1, 8))
			cb = _cb(Vector3(0, 0.55, 0))
			cb.slide_on_ceiling = (case == "ceil_on")
		"plat_leave", "plat_jump", "plat_ride":
			plat = _platform(Vector3(0, -0.05, 0))
			plat_v = Vector3(2.0, 0, 0) if case != "plat_ride" \
				else Vector3(0, 2.0, 0)
			cb = _cb(Vector3(0, 0.55, 0))
			cb.floor_snap_length = 0.5
		"wallslide":
			_slab("floor", Vector3(0, -0.05, 0), Vector3(8, 0.1, 8))
			# angled wall: 45 deg about Y
			var wl := _slab("wall", Vector3(2, 1, 0), Vector3(0.2, 4, 8))
			wl.rotation_degrees = Vector3(0, 45, 0)
			cb = _cb(Vector3(0, 0.55, 0))
		"margin_lo", "margin_hi":
			_slab("floor", Vector3(0, -0.05, 0), Vector3(8, 0.1, 8))
			cb = _cb(Vector3(0, 0.55, 0))
			cb.safe_margin = 0.001 if case == "margin_lo" else 0.1
		"float":
			_slab("floor", Vector3(0, -0.05, 0), Vector3(8, 0.1, 8))
			cb = _cb(Vector3(0, 0.55, 0))
			cb.motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
		"constspd", "constspd_off":
			_slab("ramp", Vector3(0, -0.3, 0), Vector3(8, 0.1, 4), -20.0)
			cb = _cb(Vector3(-2, 1.0, 0))
			cb.floor_constant_speed = (case == "constspd")
		"blockwall", "blockwall_on":
			_slab("floor", Vector3(0, -0.05, 0), Vector3(8, 0.1, 8))
			_slab("wall", Vector3(2, 1, 0), Vector3(0.2, 4, 8))
			cb = _cb(Vector3(0, 0.55, 0))
			cb.floor_block_on_wall = (case == "blockwall_on")
		"maxslides":
			_slab("floor", Vector3(0, -0.05, 0), Vector3(8, 0.1, 8))
			var w1 := _slab("v1", Vector3(2, 1, -0.6), Vector3(0.2, 4, 4))
			w1.rotation_degrees = Vector3(0, 30, 0)
			var w2 := _slab("v2", Vector3(2, 1, 0.6), Vector3(0.2, 4, 4))
			w2.rotation_degrees = Vector3(0, -30, 0)
			cb = _cb(Vector3(0, 0.55, 0))
			cb.max_slides = 1
		"realvel":
			_slab("floor", Vector3(0, -0.05, 0), Vector3(8, 0.1, 8))
			_slab("wall", Vector3(2, 1, 0), Vector3(0.2, 4, 8))
			cb = _cb(Vector3(0, 0.55, 0))
		"updir":
			_slab("floor", Vector3(0, -0.05, 0), Vector3(8, 0.1, 8))
			cb = _cb(Vector3(0, 0.55, 0))
			cb.up_direction = Vector3(0, 0, 1)
		"recovery":
			_slab("floor", Vector3(0, -0.05, 0), Vector3(8, 0.1, 8))
			cb = _cb(Vector3(0, 0.55, 0))
		"stop_on_ceil":
			_slab("floor", Vector3(0, -0.05, 0), Vector3(8, 0.1, 8))
			_slab("ceil", Vector3(0, 1.3, 0), Vector3(8, 0.1, 8))
			cb = _cb(Vector3(0, 0.55, 0))
			cb.floor_stop_on_slope = true

func on_tick() -> void:
	tick += 1
	if not is_instance_valid(cb):
		fin()
		return
	var dt := 1.0 / 60.0
	match case:
		"snap_def", "snap_big", "snap0", "snapx_def", "snapx_0":
			cb.velocity = Vector3(2, 0, 0)
			if tick == 1:
				cb.velocity.y = -2.0
			cb.move_and_slide()
		"snap_ramp", "constspd", "constspd_off":
			cb.velocity = Vector3(2, cb.velocity.y - 9.8 * dt, 0)
			cb.move_and_slide()
		"ceil_on", "ceil_off", "stop_on_ceil":
			if tick == 1:
				cb.velocity = Vector3(0, 4, 1.5)
			else:
				cb.velocity.y -= 9.8 * dt
				if case == "stop_on_ceil":
					cb.velocity.x = 1.0
			cb.move_and_slide()
		"plat_leave":
			plat.position += plat_v * dt
			cb.velocity = Vector3(1, cb.velocity.y - 9.8 * dt, 0)
			cb.move_and_slide()
		"plat_jump":
			plat.position += plat_v * dt
			if tick == 20:
				cb.velocity = Vector3(0, 5, 0)
			elif tick > 20:
				cb.velocity.y -= 9.8 * dt
			cb.move_and_slide()
		"plat_ride":
			plat.position += plat_v * dt
			cb.velocity.y = 0
			cb.move_and_slide()
		"wallslide":
			cb.velocity = Vector3(2, -1, 0).normalized() * 3.0
			cb.move_and_slide()
		"margin_lo", "margin_hi", "float", "updir":
			cb.velocity = Vector3(0, cb.velocity.y - 9.8 * dt, 0)
			cb.move_and_slide()
		"blockwall", "blockwall_on", "realvel", "maxslides":
			cb.velocity = Vector3(2, cb.velocity.y - 9.8 * dt, 0)
			cb.move_and_slide()
		"recovery":
			if tick == 10:
				cb.position.y -= 0.4  # teleport INTO floor
			cb.velocity = Vector3.ZERO
			cb.move_and_slide()
	if tick in [2, 10, 20, 30, 45, 60, 90, 120]:
		report()
	if tick == 120:
		fin()

func report() -> void:
	print("CB t=%d pos=%s,%s,%s rv=%s,%s,%s v=%s,%s,%s fl=%d wlo=%d ce=%d n=%d pvel=%s,%s,%s" % [
		tick,
		_f(cb.position.x), _f(cb.position.y), _f(cb.position.z),
		_f(cb.get_real_velocity().x), _f(cb.get_real_velocity().y),
		_f(cb.get_real_velocity().z),
		_f(cb.velocity.x), _f(cb.velocity.y), _f(cb.velocity.z),
		int(cb.is_on_floor()), int(cb.is_on_wall_only()),
		int(cb.is_on_ceiling_only()), cb.get_slide_collision_count(),
		_f(cb.get_platform_velocity().x), _f(cb.get_platform_velocity().y),
		_f(cb.get_platform_velocity().z)])

func _f(x: float) -> String:
	return String.num(x, 4)

func fin() -> void:
	print("CBSUM case=%s" % case)
	quit(0)
