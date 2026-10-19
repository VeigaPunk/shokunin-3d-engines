extends Node3D
const SPEED := 2.0
var agent: NavigationAgent3D
var retarget := false
var ticks := 0
var delta_sum := 0.0
var first_next := Vector3.ZERO
var before_switch := Vector3.ZERO
var after_path := PackedVector3Array()
var after_next := Vector3.ZERO
var final := Vector3.ZERO

func _physics_process(delta: float) -> void:
	if ticks >= 120:
		return
	if ticks == 35:
		before_switch = global_position
		if retarget:
			agent.target_position = Vector3(1, 0, 3)
	var next := agent.get_next_path_position()
	if ticks == 0:
		first_next = next
	if ticks == 35:
		after_next = next
		after_path = agent.get_current_navigation_path()
	global_position = global_position.move_toward(next, SPEED * delta)
	delta_sum += delta
	ticks += 1
	if ticks == 120:
		final = global_position
