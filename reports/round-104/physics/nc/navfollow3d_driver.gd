extends Node3D
const SPEED := 2.0
var agent: NavigationAgent3D
var stationary := false
var ticks := 0
var delta_sum := 0.0
var first := Vector3.ZERO
var final := Vector3.ZERO
var first_next := Vector3.ZERO

func _physics_process(delta: float) -> void:
	if ticks >= 90:
		return
	var next := agent.get_next_path_position()
	if ticks == 0:
		first_next = next
	if not stationary:
		global_position = global_position.move_toward(next, SPEED * delta)
	delta_sum += delta
	ticks += 1
	if ticks == 30:
		first = global_position
	if ticks == 90:
		final = global_position
