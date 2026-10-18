# Shared input-driven CharacterBody3D actor for input3d_move.gd.
#
# Not a battery case on its own; it has no reproduction command and no exit
# signature. It mirrors the predecessor suite's causal_actor.gd contract: a
# synthetic InputEventKey press sets intent, a matching release clears it, and
# _physics_process converts intent into exactly one move_and_slide() per
# physics tick with the pinned delta of 1/60 (project.godot).
#
# SPEED is the single authored speed constant; input3d_move.gd reads it from
# this script (Mover.SPEED) and hand-computes the expected displacement from it,
# so the two cannot drift apart silently.
extends CharacterBody3D

signal moved(count: int, x: float)

const SPEED := 6.0

var intent := false
var receipts := 0
var releases := 0
var ticks := 0


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_W:
		if event.pressed:
			receipts += 1
			intent = true
		else:
			releases += 1
			intent = false


func _physics_process(_delta: float) -> void:
	ticks += 1
	if intent:
		velocity = Vector3(SPEED, 0.0, 0.0)
		move_and_slide()
		moved.emit(ticks, position.x)
	else:
		velocity = Vector3.ZERO
