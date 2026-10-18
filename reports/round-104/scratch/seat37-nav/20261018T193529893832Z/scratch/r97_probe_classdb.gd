extends SceneTree
# r97 ClassDB surface probe — which candidate classes exist in this build,
# can they be instantiated headless, and what is their method count.

const CANDIDATES := [
	"VehicleBody3D", "VehicleWheel3D",
	"SoftBody3D",
	"PinJoint3D", "HingeJoint3D", "SliderJoint3D", "ConeTwistJoint3D",
	"Generic6DOFJoint3D", "Joint3D",
	"CharacterBody3D",
	"XRAnchor3D", "XRCamera3D", "XRController3D", "XROrigin3D",
	"XRServer", "XRInterface", "MobileVRInterface", "WebXRInterface",
	"XRBodyTracker", "XRHandTracker", "XRFaceTracker",
	"PhysicsServer3D", "PhysicsDirectSpaceState3D",
	"PhysicsShapeQueryParameters3D", "PhysicsRayQueryParameters3D",
	"PhysicsPointQueryParameters3D",
	"SpringBoneSimulator3D", "PhysicalBone3D", "PhysicalBoneSimulator3D",
	"BoneAttachment3D", "Skeleton3D",
	"RayCast3D", "ShapeCast3D", "SpringArm3D",
	"AnimatableBody3D", "StaticBody3D", "RigidBody3D", "Area3D",
	"CollisionShape3D", "CollisionPolygon3D",
	"ConcavePolygonShape3D", "ConvexPolygonShape3D", "HeightMapShape3D",
	"SeparationRayShape3D", "WorldBoundaryShape3D",
]

func _initialize() -> void:
	print("ENGINE " + Engine.get_version_info().get("string", "?"))
	for c in CANDIDATES:
		var ex := ClassDB.class_exists(c)
		var inst := "-"
		var nmeth := -1
		if ex:
			var can := ClassDB.can_instantiate(c)
			if can:
				var o = ClassDB.instantiate(c)
				if o == null:
					inst = "null"
				else:
					inst = "ok"
					if o is RefCounted:
						o.unreference()
					elif o is Object:
						o.free()
			else:
				inst = "no_instantiate"
			nmeth = ClassDB.class_get_method_list(c, true).size()
		print("CLS %s exists=%s inst=%s methods=%d" % [c, ex, inst, nmeth])
	# method-level spot checks for candidate surfaces
	_spot("Joint3D", ["set_node_a", "set_node_b", "get_node_a", "get_node_b",
		"set_exclude_nodes_from_collision", "get_exclude_nodes_from_collision"])
	_spot("PinJoint3D", ["set_param", "get_param"])
	_spot("HingeJoint3D", ["set_param", "get_param", "set_flag", "get_flag"])
	_spot("SliderJoint3D", ["set_param", "get_param"])
	_spot("ConeTwistJoint3D", ["set_param", "get_param"])
	_spot("Generic6DOFJoint3D", ["set_param", "get_param", "set_flag", "get_flag"])
	_spot("VehicleBody3D", ["set_engine_force", "set_brake", "set_steering"])
	_spot("VehicleWheel3D", ["is_in_contact", "get_contact_body",
		"get_skidinfo", "get_rpm"])
	_spot("SoftBody3D", ["pin_point", "unpin_point", "is_point_pinned",
		"set_simulation_precision", "get_simulation_precision",
		"set_total_mass", "get_collision_mask"])
	_spot("CharacterBody3D", ["move_and_slide", "is_on_floor",
		"is_on_floor_only", "is_on_wall", "is_on_wall_only",
		"is_on_ceiling", "is_on_ceiling_only", "get_floor_normal",
		"get_wall_normal", "get_platform_velocity", "get_last_motion",
		"get_slide_collision_count", "get_slide_collision",
		"get_floor_angle", "get_real_velocity"])
	_spot("XRServer", ["get_world_scale", "set_world_scale",
		"get_reference_frame", "get_primary_interface"])
	_spot("PhysicsServer3D", ["soft_body_create", "soft_body_update_rendering_server",
		"soft_body_set_mesh", "soft_body_pin_point"])
	quit(0)

func _spot(cls: String, names: Array) -> void:
	if not ClassDB.class_exists(cls):
		print("SPOT %s ABSENT" % cls)
		return
	var have := {}
	for m in ClassDB.class_get_method_list(cls, true):
		have[m["name"]] = true
	var line := "SPOT %s" % cls
	for n in names:
		line += " %s=%s" % [n, "Y" if have.has(n) else "-"]
	print(line)
