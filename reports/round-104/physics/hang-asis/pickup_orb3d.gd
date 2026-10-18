# Shared Area3D trigger for area3d_chain.gd.
#
# Not a battery case on its own; it has no reproduction command and no exit
# signature. It carries the causal chain under test: a PhysicsBody3D entering
# the area fires Area3D.body_entered exactly once, which the script converts
# into a domain-level `collected` signal with an inspectable payload
# (body name, body collision_layer, area origin). `entries` counts raw
# body_entered deliveries so a fixture can prove the chain fired once rather
# than merely "at least once".
extends Area3D

signal collected(body_name: String, body_layer: int, at: Vector3)

var consumed := false
var entries := 0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	entries += 1
	if consumed:
		return
	consumed = true
	collected.emit(body.name, body.collision_layer, global_position)
