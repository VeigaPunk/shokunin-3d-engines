extends Node3D
const SPEED := 3.0
var follower: PathFollow3D
var marker: Node3D
var stationary := false
var ticks := 0
var delta_sum := 0.0
var first := Vector3.ZERO
var second := Vector3.ZERO
var marker_second := Vector3.ZERO

func _physics_process(delta: float) -> void:
	if ticks >= 60:
		return
	if not stationary:
		follower.progress += SPEED * delta
	delta_sum += delta
	ticks += 1
	if ticks == 30:
		first = follower.global_position
	if ticks == 60:
		second = follower.global_position
		marker_second = marker.global_position
