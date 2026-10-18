# Shared CharacterBody3D actor for the deterministic-drive fixtures
# (body3d_slide.gd, area3d_chain.gd).
#
# Not a battery case on its own; it has no reproduction command and no exit
# signature. It moves inside _physics_process so that move_and_slide() always
# runs inside the physics step with the pinned delta of 1/60 (project.godot),
# and it records contact facts the fixtures assert on:
#   ticks               — completed _physics_process calls since the node entered the tree
#   contacts            — slide collisions accumulated over those ticks
#   first_contact_tick  — the tick on which the first slide collision appeared
#   first_contact_normal— the normal reported by that first slide collision
extends CharacterBody3D

signal contacted(tick: int, normal: Vector3, at: Vector3)

## Authored by the owning fixture; the actor never derives it.
var drive := Vector3.ZERO
var ticks := 0
var contacts := 0
var first_contact_tick := 0
var first_contact_normal := Vector3.ZERO


func _physics_process(_delta: float) -> void:
	ticks += 1
	velocity = drive
	move_and_slide()
	var slide_count := get_slide_collision_count()
	if slide_count == 0:
		return
	contacts += slide_count
	if first_contact_tick == 0:
		var collision := get_slide_collision(0)
		first_contact_tick = ticks
		first_contact_normal = collision.get_normal()
		contacted.emit(ticks, first_contact_normal, position)
