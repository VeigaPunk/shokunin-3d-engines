# Case 5 — parent/child Transform3D composition and basis ordering.
#
# Reproduce (seeds are read-only; the battery copies this directory into
# corpus/live/runs/<ts>/scratch first):
#   python3 corpus/fixtures/run_battery.py                       # case transform3d_compose
#   python3 corpus/fixtures/run_battery.py                       # case transform3d_compose_wrong_order
# Direct invocation against a scratch copy of this directory:
#   godot --headless --path <scratch> --script res://transform3d_compose.gd
#   godot --headless --path <scratch> --script res://transform3d_compose.gd -- --wrong-order
#
# Expected exit signature (positive):
#   exit 0, stdout line:
#   PASS transform3d_compose parent_origin=2.000,0.000,0.000 child_local_origin=0.000,0.000,-3.000 global_origin=-1.000,0.000,0.000 basis_x=0.000,0.000,-1.000 basis_y=1.000,0.000,0.000 basis_z=0.000,-1.000,0.000 composition_identity=true determinant=1.000 wrong_order_rejected=true
# Expected exit signature (negative control --wrong-order):
#   exit 2, stdout line:
#   NEGATIVE REJECTED: transform3d_compose wrong_order_composition_rejected expected_origin=-1.000,0.000,0.000 wrong_order_origin=2.000,0.000,-3.000 expected_basis_x=0.000,0.000,-1.000 wrong_order_basis_x=0.000,1.000,0.000 correct_order_matches=true
# Setup/script error: exit 1 with an "ERROR: transform3d_compose: ..." line.
#
# Hand-derived constants, right-handed rotations, Godot Basis(axis, angle):
#   parent = R_y(90) at origin (2,0,0);  child local = R_x(90) at (0,0,-3)
#   R_y(90) maps +Z -> +X and +X -> -Z;  R_x(90) maps +Y -> +Z and +Z -> -Y
#   global origin = (2,0,0) + R_y(90)*(0,0,-3) = (2,0,0) + (-3,0,0) = (-1,0,0)
#   global basis columns are the world images of the child's local axes under
#   R_y(90) * R_x(90) (child rotation applied first, then the parent's):
#     local +X -> (1,0,0)  -> (0,0,-1)
#     local +Y -> (0,0,1)  -> (1,0,0)
#     local +Z -> (0,-1,0) -> (0,-1,0)
#   determinant of a pure rotation product = 1
#   the wrong-order hypothesis (translations summed, bases multiplied as
#   R_x(90) * R_y(90)) would give origin (2,0,-3) and columns
#     local +X -> (0,0,-1) -> (0,1,0)
#     local +Y -> (0,1,0)  -> (0,0,1)
#     local +Z -> (1,0,0)  -> (1,0,0)
#   which differs from the engine result on both origin and basis, so the
#   control is rejected by exact assertion rather than by exit code alone.
# Basis.get_row() is not exposed to GDScript in 4.7.2; basis[i] and basis.x/y/z
# are the columns, which is what the expectations above are written against.
extends SceneTree

const PARENT_ORIGIN := Vector3(2.0, 0.0, 0.0)
const PARENT_AXIS := Vector3(0.0, 1.0, 0.0)
const CHILD_ORIGIN := Vector3(0.0, 0.0, -3.0)
const CHILD_AXIS := Vector3(1.0, 0.0, 0.0)
const EXPECTED_GLOBAL_ORIGIN := Vector3(-1.0, 0.0, 0.0)
const EXPECTED_BASIS_X := Vector3(0.0, 0.0, -1.0)
const EXPECTED_BASIS_Y := Vector3(1.0, 0.0, 0.0)
const EXPECTED_BASIS_Z := Vector3(0.0, -1.0, 0.0)
const WRONG_ORDER_ORIGIN := Vector3(2.0, 0.0, -3.0)
const EXPECTED_DETERMINANT := 1.0
const EPSILON := 1.0e-6
const FRAME_BOUND := 1200

var frames := 0


func _initialize() -> void:
	call_deferred("_run")


func _process(_delta: float) -> bool:
	frames += 1
	if frames > FRAME_BOUND:
		push_error("transform3d_compose: process bound exceeded frames=%d" % frames)
		quit(1)
		return true
	return false


func _run() -> void:
	var wrong_order := "--wrong-order" in OS.get_cmdline_user_args()
	var parent := Node3D.new()
	parent.name = "ParentRig"
	parent.transform = Transform3D(Basis(PARENT_AXIS, PI / 2.0), PARENT_ORIGIN)
	root.add_child(parent)
	var child := Node3D.new()
	child.name = "ChildSocket"
	child.transform = Transform3D(Basis(CHILD_AXIS, PI / 2.0), CHILD_ORIGIN)
	parent.add_child(child)
	await process_frame
	if not _setup_intact(parent, child):
		return _fail("authored local transforms were not preserved by parenting")

	var actual := child.global_transform
	var composed := parent.global_transform * child.transform
	var identity_holds := (composed.origin.distance_to(actual.origin) <= EPSILON
			and _basis_close(composed.basis, actual.basis))
	var correct_matches := (actual.origin.distance_to(EXPECTED_GLOBAL_ORIGIN) <= EPSILON
			and actual.basis.x.distance_to(EXPECTED_BASIS_X) <= EPSILON
			and actual.basis.y.distance_to(EXPECTED_BASIS_Y) <= EPSILON
			and actual.basis.z.distance_to(EXPECTED_BASIS_Z) <= EPSILON)
	var wrong_basis := Basis(CHILD_AXIS, PI / 2.0) * Basis(PARENT_AXIS, PI / 2.0)
	var wrong_matches := (WRONG_ORDER_ORIGIN.distance_to(actual.origin) <= EPSILON
			and _basis_close(wrong_basis, actual.basis))
	if wrong_order:
		return _wrong_order_verdict(wrong_basis, identity_holds, correct_matches, wrong_matches)
	return _composition_verdict(actual, identity_holds, correct_matches, wrong_matches)


func _setup_intact(parent: Node3D, child: Node3D) -> bool:
	if not parent.is_inside_tree() or not child.is_inside_tree():
		return false
	if child.get_parent() != parent:
		return false
	if parent.transform.origin.distance_to(PARENT_ORIGIN) > EPSILON:
		return false
	if child.transform.origin.distance_to(CHILD_ORIGIN) > EPSILON:
		return false
	return parent.global_transform.origin.distance_to(PARENT_ORIGIN) <= EPSILON


func _composition_verdict(actual: Transform3D, identity_holds: bool, correct_matches: bool, wrong_matches: bool) -> void:
	if not identity_holds:
		return _fail("parent.global_transform * child.transform is not child.global_transform")
	if not correct_matches:
		return _fail("composed global transform disagrees with the hand-derived expectation origin=%s basis_x=%s basis_y=%s basis_z=%s"
				% [_v(actual.origin), _v(actual.basis.x), _v(actual.basis.y), _v(actual.basis.z)])
	if wrong_matches:
		return _fail("the reversed-order composition also matched; the assertion does not discriminate order")
	var determinant := actual.basis.determinant()
	if absf(determinant - EXPECTED_DETERMINANT) > EPSILON:
		return _fail("composed basis is not a proper rotation determinant=%0.9f" % determinant)
	print("PASS transform3d_compose parent_origin=%s child_local_origin=%s global_origin=%s basis_x=%s basis_y=%s basis_z=%s composition_identity=true determinant=%s wrong_order_rejected=true"
			% [_v(PARENT_ORIGIN), _v(CHILD_ORIGIN), _v(actual.origin), _v(actual.basis.x),
				_v(actual.basis.y), _v(actual.basis.z), _f(determinant)])
	quit(0)


func _wrong_order_verdict(wrong_basis: Basis, identity_holds: bool, correct_matches: bool, wrong_matches: bool) -> void:
	# The correct-order expectation must still hold, otherwise rejecting the
	# reversed order would prove nothing about ordering.
	if not identity_holds or not correct_matches:
		return _fail("correct-order composition failed; the wrong-order control would not be discriminating")
	if wrong_matches:
		return _fail("reversed-order composition matched the engine result; ordering is not discriminated")
	print("NEGATIVE REJECTED: transform3d_compose wrong_order_composition_rejected expected_origin=%s wrong_order_origin=%s expected_basis_x=%s wrong_order_basis_x=%s correct_order_matches=true"
			% [_v(EXPECTED_GLOBAL_ORIGIN), _v(WRONG_ORDER_ORIGIN),
				_v(EXPECTED_BASIS_X), _v(wrong_basis.x)])
	quit(2)


func _basis_close(a: Basis, b: Basis) -> bool:
	return (a.x.distance_to(b.x) <= EPSILON and a.y.distance_to(b.y) <= EPSILON
			and a.z.distance_to(b.z) <= EPSILON)


func _fail(message: String) -> void:
	push_error("transform3d_compose: " + message)
	quit(1)


func _f(value: float) -> String:
	# snappedf + 0.0 keeps marker text stable: it folds -0.0 and sub-tolerance
	# noise to 0.000 while leaving genuine negatives such as -1.000 intact.
	return "%0.3f" % (snappedf(value, 0.001) + 0.0)


func _v(value: Vector3) -> String:
	return _f(value.x) + "," + _f(value.y) + "," + _f(value.z)
