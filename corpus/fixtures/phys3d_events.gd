# PhysicsServer3D two-tier lattice (round 83): query APIs bind edge-0
# same-turn; generated events (contact sets, area monitor callbacks,
# body_entered/exited signals, state_sync callbacks) bind at the physics tick.
#
# Measured on Godot 4.7.2 --headless, 60 tps, physics_engine=DEFAULT
# (GodotPhysics3D; Jolt is pinned in-battery by the jolt_edge child arm —
# the lattice holds on the query/event split while cast/btm differ on
# solver constants and static_nopair inverts; the r84 child runs the
# full 6-result map under Jolt clean-exit on this build).
#
# Arms (run one per case):
#   isect        intersect_shape sees a moved body same-turn, both directions
#   cast         cast_motion safe/unsafe fractions update same-turn
#   btm          body_test_motion hit->miss on a wall move, same-turn
#   pp_queries   the same three queries issued inside _physics_process
#   contact_stale get_contact_count stays stale at w0 while intersect_shape is
#                already live — the two-tier discriminant
#   contact_sig  Area3D.body_entered on a rigid teleport: never same-turn,
#                fires at the next physics tick (delta=1)
#   sync_cb      body_set_state_sync_callback fires once per tick while the
#                body is active; never fires on a static body
#   srv_area_cb  server-level area_set_monitor_callback: enter/exit land at
#                the next physics tick — delta=1 from a physics-phase write,
#                delta=2 from a process-phase write (write-phase-dependent,
#                critic C1; this fixture writes from the physics phase)
#   static_nopair NEGATIVE: a teleported STATIC body never re-pairs with a
#                settled Area3D (no signal, overlaps=0) — the pair only forms
#                when the AREA itself moves. GodotPhysics3D ONLY: under Jolt
#                the same cell fires (ov=1 sig=1, 3/3 — critic C2), so the
#                only-movers rule is backend-scoped, not universal
#   threaded_edge parent arm: spawns a second godot with
#                physics/3d/run_on_separate_thread=true and checks the
#                conversion — inside _physics_process the write->query edge is
#                still 0, while process-context direct-space-state access is
#                refused (server calls body_get_state/body_test_motion keep
#                answering mid-frame)
#   phase_delta  the write-phase discriminant as a first-class cell
#                (r83 critic C1): the same rigid teleport into the same
#                settled area fires body_entered at delta=2 when the
#                write issues from the process phase (await
#                process_frame continuation) vs delta=1 from the physics
#                phase — the frame owns the extra tick, not the solver
#   jolt_edge    parent arm: spawns a second godot under a generated
#                physics/3d/physics_engine="Jolt Physics" project and
#                pins the per-arm backend split {same-signature |
#                differs-constants | inverts} — isect/contact_stale keep
#                the DEFAULT signature, cast/btm keep the edge on
#                different solver constants, static_nopair INVERTS
#                (tp fires ov=1 sig=1 delta=1 under Jolt — critic C2).
#                Gated on the physics_engine hint containing "Jolt
#                Physics"; absent -> honest BLOCKED row, no fabrication
#   jolt_threaded cross-product arm (round 85): generated child carrying
#                BOTH physics_engine="Jolt Physics" AND
#                3d/run_on_separate_thread=true — pins whether the
#                backend split holds identically under the threaded
#                stepper. A threading witness (proc-context
#                space_get_direct_state refusals) is pinned in the map so
#                a silently-nonthreaded child fails loudly
#   dummy_refused negative-control arm (round 85): generated child under
#                physics_engine="Dummy" runs the SAME reduced sweep —
#                every arm must classify 'unexpected' (zero/silent reads
#                never earn a known-class label), proving the split is
#                backend-real, not a map coincidence
#   srv_phase_delta server-write phase delta (round 85 stretch):
#                PhysicsServer3D.body_set_state writes vs the
#                node-position writes of phase_delta — same event-tier
#                boundaries (proc-phase -> delta=2, physics-phase ->
#                delta=1): the write PATH is not a tier, the write PHASE
#                is. A raw server RID carries no instance id, so the
#                monitor is the server-level area_set_monitor_callback
#                (a node Area3D's body_entered cannot resolve it)
#   script_size_gate parent arm (round 86): the deferred process-context
#                direct-space-state fetch is released or refused by the
#                script's statement count, not by the fetch position — an
#                UNCALLED function body releases it too (r86 critic A3) —
#                and on this host that is a ~100-line STOCHASTIC
#                BAND (~475-575 lines), not a boundary (r86 boundary §1, 6
#                reps per point). One GENERATED probe source at two sizes in
#                the same threaded project: the 25-line body is refused
#                (deterministic, far below the band) and the 1025-line body
#                is granted (deterministic, far above it); the same minimal
#                body in an unthreaded project is granted, because the gate
#                does not exist without run_on_separate_thread. Every child
#                is corroborated by the engine's own refusal-line count in
#                its log, never by the child's self-report alone.
#                The fourth child is this fixture's own bare fetch at the
#                same position: it is granted, and the r86 boundary seat
#                showed 16 real-token shrinks down to 725 lines never flip
#                it. So this is a LATENT fragility, not a live defect — the
#                file would have to lose ~500 lines of real tokens to reach
#                the band — and the arm exists to make that trip loud
#                instead of silent.
#   deferred_hang parent arm (round 86): an unguarded deref of the refused
#                fetch inside the deferred _run coroutine aborts that
#                coroutine before quit(); the SceneTree is then left with
#                no exit condition and spins until the spawn bound kills
#                it (rc 137 = 128+SIGKILL through /bin/sh, no
#                CHILD_RESULT line at all). rc is the only detector: a
#                SIGKILLed process emits no at-exit leak report, so the
#                leak scan can never see the zombie RIDs (r86 boundary
#                §3.1). The identical body under Dummy+threaded is the
#                contrast: the silent floor grants every fetch, so it
#                exits 0 and can never witness the hang class. Bounded by
#                `timeout -s KILL` at 8 s.
#   backend_tier  parent arm (round 86): one tier sweep spawned under
#                {GodotPhysics, Jolt, Dummy} generated projects. The area
#                gravity/damping override INVERTS — GodotPhysics honours
#                it, Jolt silently ignores it (the body keeps the global
#                constant while the area parameter reads back 20.0); the
#                shape-query `margin` is the mirror split (inert on
#                GodotPhysics, honoured by Jolt); the separation ray
#                differs only in solver constants.
#   dummy_floor   parent arm (round 86): the Dummy silent floor as a
#                class. Every create returns RID(0), every read comes back
#                Nil / 0.0 / empty, one shape type is a WRONG constant, and
#                the two calls that are loud refusals on a real backend
#                (space_get_direct_state(RID()) and free_rid(RID())) are
#                silent no-ops. Pinned as an 11-token signature tuple plus
#                the real-backend refusal count, so "silent floor" can
#                never be read as "refusal". The Dummy child is armed for
#                the floor ONLY — the r86 boundary seat's 34-call sweep
#                found 0 errors and no loud refusal anywhere under Dummy,
#                so a Dummy child can never witness a refusal class.
#   body_handle  parent arm (round 87): the held-handle identity law — the
#                body-state object is ONE per-body singleton live handle, the
#                same instance _integrate_forces and
#                body_set_state_sync_callback are handed, and it survives
#                detach/reattach. Three generated children (GP/Jolt/Dummy);
#                the Dummy row is the floor contrast, never a hazard detector
#   acq_use      parent arm (round 87): the acquisition-vs-use split under
#                run_on_separate_thread — the FETCH is refused out of phase
#                while a HELD handle reads live and writes land at every
#                position: the gate controls acquisition, not use. The gate
#                witness doubles as the threading witness
#   step_stamp   parent arm (round 87): the object's own flush seams —
#                get_step is step-stamped on both real backends (init
#                constant -> real dt), gravity/damp only on GodotPhysics
#                (Jolt reports real values pre-first-solve), and the contact
#                buffer is last-step data that needs
#                body_set_max_contacts_reported > 0 to report anything
#   write_loss   parent arm (round 87): the out-of-phase held-handle write as
#                a BOUNDED repeated observation (8 reps) — the gate refusal
#                and the same-turn write are pinned, the landed/lost split is
#                evidence (the write path is ungated and unsynchronized), and
#                a loss is never claimed that was not witnessed
#   body_tier    parent arm (round 87): the backend split AT the body tier —
#                first-in-contact-step get_contact_impulse zero (GP) vs real
#                (Jolt), out-of-range contact_local_shape -1 vs 0,
#                set_sleep_state keeping vs zeroing velocity, and the
#                detached-impulse write silent vs LOUD (log-counted)
#   freed_space  parent arm (round 87, FATAL TAIL): the one crash surface at
#                this tier — a space-state object reached through a body
#                handle whose SPACE was free_rid'd. The crash site is
#                backend-specific on this host: GP dies INSIDE
#                held.get_space_state() (its `space=` note never prints),
#                Jolt's call returns and the kill is at intersect_ray.
#                GP reports signal 11 and
#                aborts through its own handler (rc 134 in ~1.5 s; a
#                load-slowed handler was measured at 44.2 s and is then
#                bound-killed at rc 137), Jolt's crash mode is heap-layout
#                dependent (uncaught std::system_error or the same signal-11
#                handler), Dummy returns {} and exits 0. Pinned per backend
#                as one crash line in the raw log plus the breadcrumb
#                prefix at that backend's site plus the ABSENCE of any
#                child marker
#   motion_split parent arm (round 88): the read family's motion semantics —
#                ONE PhysicsShapeQueryParameters3D per geometry, reused
#                across the four methods that accept it: cast_motion APPLIES
#                motion (a fraction in (0,1) — and a start overlap does NOT
#                pin the cast to 0), while collide_shape / get_rest_info /
#                intersect_shape ignore it (a clear-start -2z sweep that ENDS
#                embedded in the wall reports nothing; the in-place overlap
#                controls answer). The wall-contact bracket is a per-backend
#                ENVELOPE (GodotPhysics widens around the geometric 0.1 by
#                its margin handling, Jolt lands tight) — never a
#                cross-backend equality.
#   fetch_gate   parent arm (round 88): the access gate as a lattice. Under
#                run_on_separate_thread the fresh fetch is refused at EVERY
#                out-of-phase position (including _initialize, before the
#                first step) and granted only inside the physics tick, each
#                refusal printing one engine ERROR per acquisition path;
#                non-threaded backends hand the object out everywhere; Dummy
#                has no gate at all. The bypass cell: a held body handle's
#                get_space_state() returns the SAME dss object at refused
#                positions and queries through it answer.
#   inactive_space parent arm (round 88): the gate keys on the step cycle,
#                not on activation — space_create + space_set_active(false)
#                is fetched at every position on non-threaded backends, while
#                the threaded gate refuses it out of phase. A STASHED
#                never-stepped inactive-space handle answers everywhere
#                (its cs/ri zeros are geometric: the private space carries
#                only the wall).
#   race_class   parent arm (round 88): the threaded window as NAMED
#                non-deterministic classes. Each child measures the legal
#                channel values at an in-phase position and then requires
#                every out-of-phase sample to be either empty/zero or the
#                legal value — an ENVELOPE pin, never a distribution: no
#                class is required to appear, and a torn value (a channel
#                outside {empty, legal}) fails the row. The Jolt child's
#                outcome is bimodal — the same off-phase shape-query window
#                tears the Jolt shape registry (its own engine lines) and can
#                abort the process (rc 134/137, no child marker) — so the row
#                accepts the crash envelope OR the completed named-class
#                envelope, each with its own witnesses.
#   param_purity parent arm (round 88): the params objects are pure input —
#                no read method mutates transform/motion/margin/mask/shape/
#                shape_rid/exclude (fingerprinted before and after each
#                call); shape_rid beats shape when both are set; repeated
#                calls return fresh containers (not the same instance) with
#                equal contents.
#   body_inertia parent arm (round 88): the PhysicsDirectBodyState3D inertia
#                getters pinned as values — rigid box (half 2x0.5x0.5, mass
#                2) imass 0.5 / inverse inertia (3, 0.352941, 0.352941) on
#                both real backends, the world-space tensor R*diag*R^T
#                verified in-child against the measured local values, the
#                BODY_PARAM_INERTIA and BODY_PARAM_CENTER_OF_MASS writes
#                reflected, and the static/kinematic split (GodotPhysics
#                zeros, Jolt placeholders imass 1 + zero inertia + identity
#                tensor, Dummy imass 0 + identity) pinned per backend.
#   wrong_args   parent arm (round 88): the wrong-argument class — every
#                wrong-class / null / no-shape / non-positive max_results
#                cell is refused in the WRAPPER layer with rc=0 and a typed
#                empty (Array / PackedFloat32Array / Dictionary per method),
#                and the refusal TEXT is counted in each backend's raw log
#                and required equal across backends (the Dummy floor emits
#                no "Parameter shape is null" line, so that count is pinned
#                per backend instead).
#   geom_split   parent arm (round 88): the backend-geometry splits as
#                ENVELOPES, never cross-backend equality — the boundary-
#                touching intersect_point counts the containing wall only on
#                GodotPhysics and additionally the touched floor on Jolt;
#                the same wall-contact bracket that motion_split pins; the
#                same in-place floor penetration yields a tilted
#                depenetration normal on GodotPhysics and a pure-up normal
#                on Jolt; the overlap rest point is the query center on
#                GodotPhysics and offset on Jolt.
#   freed_space_methods parent arm (round 88, FATAL TAIL): the freed-space
#                postconditions PER METHOD x BACKEND, one child per method on
#                the real backends (a crash cannot be caught) plus one Dummy
#                child covering all six. GodotPhysics aborts (rc 134/137) on
#                every method at the POST bds.get_space_state() call;
#                Jolt's per-method outcome is process-sensitive (crash OR a
#                dead-handle path with the previously-freed SCRIPT ERROR and
#                rc=0), so the Jolt cells gate on "crash envelope OR dead
#                handle" with the rc+result conjuncts; Dummy answers typed
#                empties with rc=0. The children are spawned in ONE parallel
#                batch (the per-case 20 s bound), each still wrapped in
#                `timeout -s KILL` and the batch itself fail-closed.
#   if_phase     parent arm (round 89): the intra-tick PHASE LATTICE at the
#                contact surface, rebuilt in-fixture. The same tick is sampled
#                at _integrate_forces (IF), _physics_process (E) and _process
#                (F) through one body handle with `pf` + `seq` stamps, so the
#                order is read off the rows: IF is a PRE-step view (IF(pf=k) ==
#                E(pf=k) == F(pf=k-1)), the CURRENT step's contact record is
#                readable only at F or at the next tick's IF/E (never inside
#                IF), and the record's `impulse` is one solve late on
#                GodotPhysics while Jolt's holds its own step's impulse. Every
#                out-of-range contact index is a typed refusal (one engine
#                line per call, counted from the raw log), never a crash.
#   if_write     parent arm (round 89): the _integrate_forces INTERIOR rules,
#                one member per fresh free-falling ball. Velocity / angular
#                velocity / transform / impulse writes are immediate; force /
#                torque / constant-force writes are DEFERRED one step;
#                set_sleep_state(true) is honored now but GodotPhysics keeps
#                the velocity while Jolt zeroes it; a re-entrant
#                integrate_forces() silently double-integrates;
#                body_set_space(RID()) detaches and freezes the body (Jolt's
#                teardown then names the missing physics space, counted). No
#                member is refused — the in/out-phase refusal line is counted
#                as a witnessed zero.
#   joint_pin    parent arm (round 89): the pin constraint as a WITNESS — soft
#                by default, frozen at softness 0 with exactly zero velocity,
#                rigid at softness 1, sagging when the impulse clamp drops
#                below the support impulse — with the `nomake` control proving
#                the witness measures the joint, and
#                `joint_make_generic_6dof` compared against that control (on
#                Jolt the traces are identical: a silent no-op that still
#                reports type 4). Jolt drops every pin parameter write.
#   joint_param  parent arm (round 89): the per-parameter ROUND-TRIP table per
#                joint type: Jolt silently drops a per-type subset of
#                solver-tuning writes (pin 0-2; hinge 0,3,4,5; cone 2,3,4;
#                g6dof 2,4,13,14,15; slider but 0,1) while honoring
#                limits/motors, GodotPhysics honors the table except the
#                slider, whose getter is write-opaque and emits one wrong-type
#                guard per call (counted). Dummy drops everything.
#   joint_solver parent arm (round 89): joint_set_solver_priority (default 1,
#                `set 32` honored on GodotPhysics with a large behavioural
#                change, ignored on Jolt) and the joint RID lifecycle —
#                joint_clear releases from the very next step, a double clear
#                is a silent no-op, the RID is REUSABLE, and a free_rid'd
#                joint answers with a typed null-parameter refusal whose make
#                guard name is backend-specific (`prev_joint` vs `old_joint`).
#                Contrast with the freed-SPACE family: a freed JOINT never
#                crashes.
#   cross_space  parent arm (round 89): cross-space handle validity — a second
#                World3D (a SubViewport carrying its own world) and a raw
#                active server space both answer from the main world's physics
#                tick, each handle resolves to its OWN space, and each space
#                answers its own rays at its own height. The box-size
#                convention is pinned: server shape_set_data takes HALF
#                extents, a BoxShape3D.size is the FULL size. One measured
#                backend split: a server body in a non-main space is stepped
#                on GodotPhysics but not on Jolt unless a node shares the
#                world (the raw space's ball stays frozen there).
#   sleep_state  parent arm (round 89): the sleeping-body direct state as ONE
#                cell per process in a parallel batch (13 children). A slept
#                body's handle answers every read and the fetch never wakes
#                it; the handle's CONTACT VIEW reads the pre-sleep snapshot
#                (cc=1, support impulse 0.1633, frozen lv — a stale READ on
#                the held state object, nothing asserted about the backend's
#                internal buffer) and the IF callback stops on the sleep
#                tick; velocity and transform writes land, wake the body
#                and take effect; set_sleep_state(false) re-sleeps at the next
#                tick on GodotPhysics while Jolt stays awake-but-frozen;
#                moving the floor wakes the ball on GodotPhysics and not on
#                Jolt (frozen at y=-0.0110 with the same stale read); and the
#                state-sync callback never fires while asleep.
#
# Reproduce one arm:
#   godot --headless --path <scratch> --script res://phys3d_events.gd -- --arm=isect
extends SceneTree

const SETTLE := 4
const WALL_FAR := Vector3(0, 0, -30)
# r86 size-gate ladder. The r86 boundary seat measured the deferred
# process-context fetch as a ~100-line STOCHASTIC BAND, not a boundary:
# deterministically refused below ~475 lines of one-statement-per-line
# padding, deterministically granted above ~575, with a race inside (6 reps
# per point). 0 padding (25 lines) sits far below the band and 1000 padding
# (1025 lines) far above it, so both ends of this cell are on the
# deterministic side of the race rather than inside it. (This arm pins the
# release/refuse OUTCOME, not the boundary seat's `pf` observable: the
# generated probe prints `pf` after its own await, so the two readings are
# not the same measurement.)
const SIZE_PAD := 1000
# r86 hang arm: a healthy child of this size exits in ~0.5 s, so 8 s is a
# 16x margin on the abort, and 137 is what `/bin/sh` reports for the
# `timeout -s KILL` kill (128 + SIGKILL).
const HANG_BOUND_S := 8
const HANG_RC := 137
# r87 body-tier arms. BODY_REPS is the bounded repeated-observation length the
# acquisition/use and write-loss cells share: both cells are REPEATED so a
# single lucky frame can never carry them. CRASH_BOUND_S bounds the freed-space
# crash children. The GodotPhysics crash handler normally finishes its backtrace
# in ~1.5 s and aborts (rc 134 — measured 5/5 in this fixture form, 3/3 in the
# battery runs), but the SAME handler was measured taking 44.2 s under host
# load, so a bound can cut it short and the child then dies by the bound's
# SIGKILL (rc 137 through /bin/sh). The rc is therefore the handler's exit
# PATH, not the class: the row pins the crash CLASS (the engine's own crash
# line, no child marker, a signal-class rc) and accepts both.
const BODY_REPS := 8
const CRASH_BOUND_S := 6
# r88 query-tier arms. GATE_F_REPS bounds the `_process` (out-of-phase)
# firings each gate/race child samples; RACE_REPS bounds the threaded
# race-window samples (envelope pins only — no class is required to appear).
# FREED_BOUND_S bounds each freed-space child (a crashing child dumps its
# backtrace in ~1.5 s; the bound cuts a load-slowed handler short, rc 137).
# BATCH_BOUND_S bounds a whole parallel child batch as a fail-closed net on
# top of each child's own `timeout -s KILL` (a batch that outlives it is a
# named failure, never a silent partial row).
const GATE_F_REPS := 3
const RACE_REPS := 4
const FREED_METHODS := ["pt", "ray", "is", "cs", "cm", "ri"]
# the VM dead-handle line carries the real method name
# ("Nonexistent function 'intersect_point' in base 'previously freed'") —
# the parent counts the method-qualified line, not the bare token (r88 C1).
const FREED_METHOD_NAMES := {
	"pt": "intersect_point", "ray": "intersect_ray",
	"is": "intersect_shape", "cs": "collide_shape",
	"cm": "cast_motion", "ri": "get_rest_info"}
const FREED_BOUND_S := 6
const BATCH_BOUND_S := 12

var owned: Array[RID] = []
var owned_nodes: Array[Node] = []
var dss: PhysicsDirectSpaceState3D
var wspace: RID
var sig_log := []


func _initialize() -> void:
	# r88: the gate children sample position A — inside _initialize, before
	# the first step — so their setup runs here; every other arm still runs
	# its setup in _run (the r83-r87 behaviour, byte-identical).
	if _is_fetch_arm():
		_fetch_gate_setup()
		_sample_fetch("A")
	call_deferred("_run")


func _argval(prefix: String, dflt: String) -> String:
	for a in OS.get_cmdline_user_args():
		if a.begins_with(prefix):
			return a.substr(prefix.length())
	return dflt


func _frames(n: int) -> void:
	for i in range(n):
		await physics_frame


func _mk_body(pos: Vector3, mode := PhysicsServer3D.BODY_MODE_STATIC,
		ext := Vector3(1.0, 1.0, 1.0)) -> RID:
	var shape := PhysicsServer3D.box_shape_create()
	PhysicsServer3D.shape_set_data(shape, ext)
	var body := PhysicsServer3D.body_create()
	PhysicsServer3D.body_set_mode(body, mode)
	PhysicsServer3D.body_add_shape(body, shape)
	PhysicsServer3D.body_set_collision_layer(body, 1)
	PhysicsServer3D.body_set_collision_mask(body, 1)
	PhysicsServer3D.body_set_space(body, wspace)
	PhysicsServer3D.body_set_state(body,
			PhysicsServer3D.BODY_STATE_TRANSFORM, Transform3D(Basis(), pos))
	owned.append(body)
	owned.append(shape)
	return body


func _sphere_params(pos: Vector3, motion := Vector3.ZERO,
		mask := 1, with_shape := true) -> PhysicsShapeQueryParameters3D:
	var s := SphereShape3D.new()
	s.radius = 0.5
	var p := PhysicsShapeQueryParameters3D.new()
	if with_shape:
		p.shape = s
	p.transform = Transform3D(Basis(), pos)
	p.motion = motion
	p.collision_mask = mask
	p.collide_with_bodies = true
	return p


func _floor_isect_hits(exclude_body: RID) -> int:
	var b := BoxShape3D.new()
	b.size = Vector3(2, 2, 2)
	var p := PhysicsShapeQueryParameters3D.new()
	p.shape = b
	p.transform = Transform3D(Basis(), Vector3(0, 0.5, 0))
	p.collision_mask = 1
	p.collide_with_bodies = true
	p.exclude = [exclude_body]
	return dss.intersect_shape(p).size()


func _contacts(body: RID) -> int:
	var st: PhysicsDirectBodyState3D = PhysicsServer3D.body_get_direct_state(body)
	return st.get_contact_count() if st != null else -1


func _cleanup_nodes() -> void:
	for n in owned_nodes:
		if is_instance_valid(n):
			n.free()
	owned_nodes.clear()


func _cleanup_rids() -> void:
	for r in owned:
		PhysicsServer3D.free_rid(r)
	owned.clear()


func _fail(reason: String) -> bool:
	push_error("phys3d_events: " + reason)
	_quit_clean(1)
	return true


func _exit_ok(marker: String) -> void:
	_quit_clean(0, marker)


# r86 simplifier: the exit protocol — every exit path in this file cleans up
# its nodes/RIDs and quits with its own code, printing its report line (if
# any) after the cleanup (r84: "every exit path in the file cleans up").
func _quit_clean(code := 0, message := "") -> void:
	_cleanup_nodes()
	_cleanup_rids()
	if message != "":
		print(message)
	quit(code)


# r85: the jolt_threaded and dummy_refused arms are the third and fourth
# child-spawn sites, so the r84 simplifier's deferred V2 fold lands —
# _spawn_child single-sources the project generation, the
# `timeout -s KILL 30` /bin/sh spawn, the stale-log unlink, and the
# CHILD_RESULT/error scan. `allow_inaccessible` admits the refusal-class
# "Space state is inaccessible" ERROR lines a threaded child emits on
# its proc-context dss witness; every other ERROR: is a defect, as is
# any SCRIPT ERROR/Parse Error or ObjectDB-leak WARNING (r84 reviewer
# F1). Returns {code, verdicts, last, serr, errs} on spawn, or {err} where
# the caller fails with `err` verbatim (identical fail text to the unfolded
# arms — their receipts stay byte-identical).
#
# r86: `script_res` and `bound_s` are additive (defaulted to the r83-r85
# behaviour, so every existing call site and receipt is unchanged).
# `script_res` lets an arm spawn a GENERATED probe instead of this fixture
# (the size-gate arm cannot measure the fixture's own size with the
# fixture), and `bound_s` lets the hang arm bound its spin short of the
# 30 s that a healthy child never needs. `errs` is the list of the lines
# the scan below rejected, so an arm can pin an expected-witness class
# (a refusal count, an abort line) instead of only a boolean.
#
# r87: `allow_lines` is additive (defaulted empty, so every r83-r86 receipt
# stays byte-identical). The body-tier arms spawn children whose expected
# witness IS an engine ERROR line — the body-tier fetch refusal, the
# out-of-range contact-index refusal, Jolt's detached-impulse refusal — and
# a witness the scan rejects can never be asserted. The flag's own
# "Space state is inaccessible" carve-out is unchanged.
func _spawn_child(dirname: String, project_body: String, arm: String,
		allow_inaccessible: bool, script_res := "res://phys3d_events.gd",
		bound_s := 30, allow_lines := []) -> Dictionary:
	var prep := _child_prepare(dirname, project_body, arm, script_res, bound_s)
	if prep.has("err"):
		return prep
	var code := OS.execute("/bin/sh", ["-c", prep["cmd"]], [], false)
	return _child_scan(prep, code, allow_inaccessible, allow_lines)


# r88: the freed-space matrix spawns one child per method on the real
# backends, and the per-case bound is 20 s — a serial batch of 13 crash
# children would not fit. `_child_prepare` / `_child_scan` are the r83-r87
# `_spawn_child` body split at its two natural seams (project generation +
# stale-log unlink + command build; then the exit code + CHILD_RESULT/error
# scan), so the parallel batch reuses the SAME single-sourced conventions
# instead of opening a second spawn path. `_spawn_child` itself is the
# prepare -> OS.execute -> scan composition it always was, byte-identical.
func _child_prepare(dirname: String, project_body: String, arm: String,
		script_res := "res://phys3d_events.gd", bound_s := 30) -> Dictionary:
	# r89 (r88-sentinel S3 remediation, fail-closed): `dirname` is a spec field
	# and `globalize_path("res://" + dirname)` passes `..` and absolute
	# segments through unchanged, so an unsanitized spec could write
	# project.godot OUTSIDE the scratch subtree (the sentinel measured
	# `dirname="../escapeprobe"` landing a real project one level up). Every
	# r83-r88 call site passes a plain single-segment name (moplainproj,
	# fmplainpt, ...), so refusing empty / `..` / a path separator changes no
	# existing child and a bad spec fails named instead of escaping.
	if dirname.is_empty() or ".." in dirname or "/" in dirname \
			or "\\" in dirname or ":" in dirname:
		return {"err": "%s rejected dirname '%s' (unsafe: empty, '..', or a path segment)"
				% [arm, dirname]}
	# Whitelist continuation: shell metacharacters ($, `, {, }, ", ',
	# whitespace, ;, |, &, <, >, ~) are refused outright — the name is
	# interpolated into paths and log lines, so only [A-Za-z0-9_-] is safe.
	for i in dirname.length():
		var c := dirname.unicode_at(i)
		var ok := (c >= 0x30 and c <= 0x39) or (c >= 0x41 and c <= 0x5A) \
				or (c >= 0x61 and c <= 0x7A) or c == 0x5F or c == 0x2D
		if not ok:
			return {"err": "%s rejected dirname '%s' (unsafe: char U+%04X)"
					% [arm, dirname, c]}
	var dir := ProjectSettings.globalize_path("res://" + dirname)
	var mk := DirAccess.make_dir_recursive_absolute(dir)
	if mk != OK:
		return {"err": "%s cannot make %s err=%d" % [arm, dirname, mk]}
	var pf := FileAccess.open(dir.path_join("project.godot"), FileAccess.WRITE)
	if pf == null:
		return {"err": "%s cannot write child project" % arm}
	pf.store_string(project_body)
	pf.close()
	var selfpath := ProjectSettings.globalize_path(script_res)
	var logpath := dir.path_join("child.log")
	# `timeout -s KILL` bounds the child: without it a hung child
	# survives the battery's kill of the direct /bin/sh parent and is
	# orphaned (r83 reviewer F2). 30 s covers the ~2 s healthy run.
	var cmd := ("timeout -s KILL %d \"%s\" --headless --path \"%s\""
			+ " --script \"%s\" -- --child --arm=%s"
			+ " > \"%s\" 2>&1") % [
			bound_s, OS.get_executable_path(), dir, selfpath, arm, logpath]
	# r84 critic: child.log is a never-unlinked single slot -- a stale
	# log from a prior run would forge a verdict map, so remove it
	# before spawn (missing-after-spawn stays a named failure).
	DirAccess.remove_absolute(logpath)
	return {"dir": dir, "logpath": logpath, "cmd": cmd, "arm": arm}


func _child_scan(prep: Dictionary, code: int, allow_inaccessible: bool,
		allow_lines: Array) -> Dictionary:
	var res := {"code": code, "verdicts": {}, "last": "", "serr": false, "errs": []}
	var lf := FileAccess.open(prep["logpath"], FileAccess.READ)
	if lf == null:
		return {"err": "%s child log missing" % prep["arm"]}
	while not lf.eof_reached():
		var line := lf.get_line()
		if line.begins_with("CHILD_RESULT "):
			res["last"] = line
			var kv := line.substr(13).split("=", true, 1)
			if kv.size() == 2:
				res["verdicts"][kv[0]] = kv[1]
		elif "Parse Error" in line:
			res["serr"] = true
			res["errs"].append(line)
		# r88: the SCRIPT ERROR branch routes through the same admission
		# predicate as ERROR lines, so a freed-space arm can name its
		# expected witness class ("previously freed"). Parse Error stays
		# unconditional, and every r83-r87 arm passes no token that can
		# match a SCRIPT ERROR line, so their receipts are unchanged.
		elif "SCRIPT ERROR" in line \
				and not _error_allowed(line, allow_inaccessible, allow_lines):
			res["serr"] = true
			res["errs"].append(line)
		elif ("ObjectDB" in line and "leaked" in line):
			res["serr"] = true
			res["errs"].append(line)
		elif line.begins_with("ERROR:") \
				and not _error_allowed(line, allow_inaccessible, allow_lines):
			res["serr"] = true
			res["errs"].append(line)
	lf.close()
	return res


# r88: the parallel batch. Specs are the same fields `_spawn_child` takes,
# plus a per-child allow_lines. Every child still carries its own
# `timeout -s KILL` bound; the batch adds a fail-closed deadline on top
# (stragglers are SIGKILLed and the caller fails on `batch_timeout`).
func _spawn_batch(specs: Array) -> Array:
	var preps := []
	for spec in specs:
		var prep := _child_prepare(spec["dirname"], spec["project_body"],
				spec["arm"], spec.get("script_res", "res://phys3d_events.gd"),
				spec.get("bound_s", 30))
		if not prep.has("err"):
			var pid := OS.create_process("/bin/sh", ["-c", prep["cmd"]])
			if pid <= 0:
				prep = {"err": "%s cannot create child process" % spec["arm"]}
			else:
				prep["pid"] = pid
				prep["allow_inaccessible"] = spec.get("allow_inaccessible", false)
				prep["allow_lines"] = spec.get("allow_lines", [])
		preps.append(prep)
	var deadline := Time.get_ticks_msec() + BATCH_BOUND_S * 1000
	var running := true
	while running and Time.get_ticks_msec() < deadline:
		running = false
		for prep in preps:
			if prep.has("pid") and OS.is_process_running(prep["pid"]):
				running = true
		if running:
			OS.delay_msec(20)
	var out := []
	for prep in preps:
		if prep.has("err"):
			out.append(prep)
			continue
		if running and OS.is_process_running(prep["pid"]):
			OS.kill(prep["pid"])
		var code := OS.get_process_exit_code(prep["pid"])
		var res := _child_scan(prep, code, prep["allow_inaccessible"],
				prep["allow_lines"])
		res["batch_timeout"] = running
		out.append(res)
	return out


# r86 simplifier: one generator for all 13 child project bodies (four r83-r85
# arms + nine r86 arms); the 13 literals matched this shape byte-for-byte.
func _project_body(name: String, engine := "", threaded := false) -> String:
	var body := "[application]\n\nconfig/name=\"%s\"\n\n[physics]\n\ncommon/physics_ticks_per_second=60\n" % name
	if engine != "":
		body += "3d/physics_engine=\"%s\"\n" % engine
	if threaded:
		body += "3d/run_on_separate_thread=true\n"
	return body


# r86: the size-gate and hang arms need a probe whose SOURCE is generated —
# the gate is a property of the script's own size, so the child source
# cannot be this fixture. Writing the probe and then delegating keeps the
# project generation, the bounded spawn, the stale-log unlink and the error
# scan single-sourced in _spawn_child (the r84 simplifier's V2 rule).
func _spawn_probe(dirname: String, project_body: String, script_name: String,
		script_body: String, arm: String, allow_inaccessible: bool,
		bound_s := 30) -> Dictionary:
	var dir := ProjectSettings.globalize_path("res://" + dirname)
	var mk := DirAccess.make_dir_recursive_absolute(dir)
	if mk != OK:
		return {"err": "%s cannot make %s err=%d" % [arm, dirname, mk]}
	var sf := FileAccess.open(dir.path_join(script_name), FileAccess.WRITE)
	if sf == null:
		return {"err": "%s cannot write child probe" % arm}
	sf.store_string(script_body)
	sf.close()
	return _spawn_child(dirname, project_body, arm, allow_inaccessible,
			dir.path_join(script_name), bound_s)


# The generated probe: the deferred process-context fetch at the same
# position (call_deferred from _initialize) at two sizes. `--arm=guarded`
# null-checks the handle and names the outcome; `--arm=deref` dereferences
# it unguarded, which is the hang class whenever the fetch was refused.
# Padding is real file-scope statements, never comments or blank lines: the
# r86 size ladder measured the gate on compile work, not on line or byte
# count (2 026 blank lines and 256 KB of comments never released the fetch).
func _size_probe_body(pad: int) -> String:
	var pad_txt := str(pad)
	var body := "# r86 generated size probe: pad=" + pad_txt + " statements\n"
	body += "extends SceneTree\n\n\nfunc _initialize() -> void:\n"
	body += "\tcall_deferred(\"_run\")\n\n\n"
	for i in range(pad):
		body += "var v%d := %d\n" % [i, i]
	body += "\nfunc _run() -> void:\n"
	body += "\tvar mode := \"guarded\"\n"
	body += "\tfor a in OS.get_cmdline_user_args():\n"
	body += "\t\tif a.begins_with(\"--arm=\"):\n"
	body += "\t\t\tmode = a.substr(6)\n"
	body += "\tvar d = root.get_world_3d().direct_space_state\n"
	body += "\tvar refused := d == null\n"
	body += "\tawait physics_frame\n"
	body += "\tif mode == \"deref\":\n"
	body += "\t\tprints(\"CHILD_NOTE sz_deref pad=" + pad_txt + " null=%s\" % [str(refused)])\n"
	body += "\t\tprints(\"CHILD_RESULT sz_abort=%s\" % d.get_class())\n"
	body += "\t\tquit(0)\n"
	body += "\t\treturn\n"
	body += "\tprints(\"CHILD_NOTE sz_fetch pad=" + pad_txt + " pf=%d\" % [Engine.get_physics_frames()])\n"
	body += "\tprints(\"CHILD_RESULT sz_fetch=%s\" % (\"refused\" if refused else \"granted\"))\n"
	body += "\tquit(0)\n"
	return body


# The physics_engine hint gates child arms that need a named backend:
# absent -> honest BLOCKED row, never a fabricated split.
func _engine_hint_has(engine: String) -> bool:
	for prop in ProjectSettings.get_property_list():
		if prop.name == "physics/3d/physics_engine":
			return engine in prop.hint_string
	return false


# r87: the ERROR-line admission predicate for _spawn_child. The landed
# `allow_inaccessible` carve-out is preserved verbatim as its own branch; each
# `allow_lines` entry admits any line CONTAINING it, so a body-tier arm can
# name its expected witness class without widening any other arm.
func _error_allowed(line: String, allow_inaccessible: bool,
		allow_lines: Array) -> bool:
	if allow_inaccessible and "Space state is inaccessible" in line:
		return true
	for token in allow_lines:
		if token in line:
			return true
	return false


# r87: corroborate a child claim against the lines in the raw child log.
# The child log merges 2>&1 by design (position fidelity) — the child's own
# prints share that stream, so a text match ALONE is self-printable (r87
# critic F1): the crash rows therefore count the signature line AND require
# the breadcrumb prefix the real run leaves at each backend's crash site,
# and the refusal rows count the engine's ERROR lines == BODY_REPS. Returns
# -1 when the log is unreadable (a named failure, never a silent zero).
func _log_count(logpath: String, token: String) -> int:
	var lf := FileAccess.open(logpath, FileAccess.READ)
	if lf == null:
		return -1
	var n := 0
	while not lf.eof_reached():
		if token in lf.get_line():
			n += 1
	lf.close()
	return n


# r89 C5: the if_phase ordering claim pinned off the child-side seq counter
# gains a position witness — PHASEMK lines are printed inside each callback
# in real time (IF on the physics thread, E/F on the main thread), so the
# merged log's FILE ORDER is scheduler-mediated, not child arithmetic. For
# every pf where all three markers appear, IF must precede E precede F.
# Returns "true"/"false"/"absent" mirroring _phase_seq_order.
func _log_phase_order(logpath: String) -> String:
	var lf := FileAccess.open(logpath, FileAccess.READ)
	if lf == null:
		return "absent"
	var first_pos := {}
	var n := 0
	while not lf.eof_reached():
		var line := lf.get_line()
		if line.begins_with("PHASEMK "):
			n += 1
			var parts := line.split(" ")
			if parts.size() == 3:
				var key := "%s|%s" % [parts[2], parts[1]]
				if not first_pos.has(key):
					first_pos[key] = n
	lf.close()
	if n == 0:
		return "absent"
	var pfs := {}
	for key in first_pos:
		pfs[key.split("|")[0]] = true
	var seen := 0
	for pf in pfs:
		var i: int = first_pos.get("%s|IF" % pf, -1)
		var e: int = first_pos.get("%s|E" % pf, -1)
		var f: int = first_pos.get("%s|F" % pf, -1)
		if i < 0 or e < 0 or f < 0:
			continue
		seen += 1
		if not (i < e and e < f):
			return "false"
	return "true" if seen > 0 else "absent"


# r88 C6: counts `token<a>/<b>` lines whose two ids are equal — the
# parent-side identity witness for fetch_gate's held-handle bypass conjunct.
func _log_idpair_equal_count(logpath: String, token: String) -> int:
	var lf := FileAccess.open(logpath, FileAccess.READ)
	if lf == null:
		return -1
	var n := 0
	while not lf.eof_reached():
		var line := lf.get_line()
		var at := line.find(token)
		if at < 0:
			continue
		var pair := line.substr(at + token.length()).strip_edges().split("/")
		if pair.size() == 2 and pair[0] == pair[1] and pair[0] != "nil":
			n += 1
	lf.close()
	return n


# --- r88: the query-tier read family (shared child helpers) -----------------

# Fetch the world direct space state, retrying across frames: on a threaded
# backend the fetch is legal only inside the physics tick, so a child that
# arrives one frame early retries instead of failing.
func _fetch_world_dss() -> Variant:
	for i in range(24):
		var d: Variant = PhysicsServer3D.space_get_direct_state(wspace)
		if d != null:
			return d
		await physics_frame
	return null


# Guarded liveness. A Variant can hold a previously-freed Object, and the
# `is` operator itself raises on one ("Left operand of 'is' is a previously
# freed instance") — is_instance_valid() is the safe test, and the caller
# keeps this in its own frame so a freed handle is a named "dead", never a
# coroutine abort.
func _dss_live(v: Variant) -> Variant:
	if v == null or not is_instance_valid(v):
		return null
	if v is PhysicsDirectSpaceState3D:
		return v
	return null


# The freed-space children's value formatter: "t<typeof>,n<size>" for the
# container returns, "dead" for a freed handle, "nil" for a null Variant.
# typeof() dispatches first because `is` on a previously-freed instance
# raises, and is_instance_valid() is only meaningful for Objects.
func _fmt_read(v: Variant) -> String:
	if v == null:
		return "nil"
	if typeof(v) == TYPE_OBJECT:
		if not is_instance_valid(v):
			return "dead"
		return "t%d,%s" % [typeof(v), v.get_class()]
	if v is Array or v is Dictionary or v is PackedFloat32Array:
		return "t%d,n%d" % [typeof(v), v.size()]
	return "t%d,%s" % [typeof(v), str(v)]


# One plain-helper frame per risky call: the r88-scout's rev-1 lesson is that
# a script error inside the deferred _run coroutine aborts the coroutine (the
# r86 hang class), while the same error inside a callee only aborts the callee.
func _call_read(d: Variant, method: String) -> Variant:
	match method:
		"pt":
			return d.intersect_point(_pt_params(Vector3(0, 0, -3)))
		"ray":
			return d.intersect_ray(_ray_params())
		"is":
			return d.intersect_shape(_sphere_params(Vector3(0, 0, -2.2)))
		"cs":
			return d.collide_shape(
					_sphere_params(Vector3(0, 0, -1.0), Vector3(0, 0, -5)))
		"cm":
			return d.cast_motion(
					_sphere_params(Vector3(0, 0, -1.0), Vector3(0, 0, -5)))
		"ri":
			return d.get_rest_info(
					_sphere_params(Vector3(0, 0, -1.0), Vector3(0, 0, -5)))
	return null


func _pt_params(pos: Vector3) -> PhysicsPointQueryParameters3D:
	var p := PhysicsPointQueryParameters3D.new()
	p.position = pos
	p.collision_mask = 1
	return p


func _ray_params() -> PhysicsRayQueryParameters3D:
	return PhysicsRayQueryParameters3D.create(
			Vector3(0, 5, -3), Vector3(0, -5, -3))


# The params-object fingerprint for the purity cell: every writable field the
# read family could plausibly smuggle an out-param through.
func _params_fp(p: PhysicsShapeQueryParameters3D) -> String:
	return "x=%s m=%s mg=%s mask=%d b=%s a=%s s=%s rid=%s ex=%s" % [
			str(p.transform), str(p.motion), str(p.margin),
			p.collision_mask, str(p.collide_with_bodies),
			str(p.collide_with_areas),
			("nil" if p.shape == null else str(p.shape.get_instance_id())),
			str(p.shape_rid), str(p.exclude)]


# Write + same-tick query inside _physics_process (callsite-tier cell).
# Stores measured outcomes; never prints (the parent asserts the fields so
# the marker is earned, not claimed).
class PPQueries extends Node:
	var wall: RID
	var probe: RID
	var wspace: RID
	var dss: PhysicsDirectSpaceState3D  # null forces the in-callback fetch path
	var printed := false
	var ray_hit := true
	var isect_n := -1
	var safe := -1.0
	var btm_hit := true
	var travel_z := 0.0

	func result_ok() -> bool:
		return printed and not ray_hit and isect_n == 0 \
				and absf(safe - 1.0) < 0.0001 and not btm_hit \
				and absf(travel_z - (-10.0)) < 0.0001

	func _physics_process(_delta: float) -> void:
		if printed:
			return
		var d := dss
		if d == null:
			d = PhysicsServer3D.space_get_direct_state(wspace)
		if d == null:
			return  # legal-context fetch raced server start; retry next tick
		PhysicsServer3D.body_set_state(wall,
				PhysicsServer3D.BODY_STATE_TRANSFORM,
				Transform3D(Basis(), Vector3(0, 0, -30)))
		var ray := d.intersect_ray(PhysicsRayQueryParameters3D.create(
				Vector3(0, 5, -3), Vector3(0, -5, -3)))
		var s := SphereShape3D.new()
		s.radius = 0.5
		var p := PhysicsShapeQueryParameters3D.new()
		p.shape = s
		p.transform = Transform3D(Basis(), Vector3(0, 0, -2.5))
		p.collision_mask = 1
		p.collide_with_bodies = true
		var h := d.intersect_shape(p)
		p.motion = Vector3(0, 0, -10)
		p.transform = Transform3D(Basis(), Vector3.ZERO)
		var c := d.cast_motion(p)
		var params := PhysicsTestMotionParameters3D.new()
		params.from = Transform3D(Basis(), Vector3.ZERO)
		params.motion = Vector3(0, 0, -10)
		var res := PhysicsTestMotionResult3D.new()
		var rb := PhysicsServer3D.body_test_motion(probe, params, res)
		printed = true
		ray_hit = not ray.is_empty()
		isect_n = h.size()
		safe = c[0]
		btm_hit = rb
		travel_z = res.get_travel().z


func _run() -> void:
	# child modes: this same script is re-exec'd by the threaded_edge
	# parent under a generated run_on_separate_thread=true project, by
	# the jolt_edge parent under a generated physics_engine="Jolt
	# Physics" project, by the jolt_threaded parent under a generated
	# project carrying BOTH, and by the dummy_refused parent under a
	# generated physics_engine="Dummy" project (the --arm selects which
	# child body runs).
	if "--child" in OS.get_cmdline_user_args():
		# r84 critic: the child dispatch must be total -- a bare or
		# unknown --arm used to run the threaded body silently. The
		# threaded parent passes --arm=threaded_edge explicitly.
		# r88: the freed-space matrix is one child per method x backend, so
		# its 12 fm_* arm names are prefix-dispatched before the literal
		# table (the table stays the same closed set it always was; the
		# Dummy child fd_dummy is one of its literal arms).
		var arm_any := _argval("--arm=", "")
		if arm_any.begins_with("fm_"):
			await _child_freed_method(arm_any)
			return
		if arm_any.begins_with("sl_"):
			await _child_sleep(arm_any)
			return
		match _argval("--arm=", ""):
			"jolt_edge":
				await _child_jolt()
			"jolt_threaded":
				await _child_jolt_threaded()
			"dummy_refused":
				await _child_dummy()
			"threaded_edge":
				await _child_threaded()
			"size_probe":
				await _child_size()
			"tier_plain":
				await _child_tier("plain")
			"tier_jolt":
				await _child_tier("jolt")
			"tier_dummy":
				await _child_tier("dummy")
			"floor_dummy":
				await _child_floor("dummy")
			"floor_real":
				await _child_floor("real")
			"bh_plain":
				await _child_bh_identity("bh_plain")
			"bh_jolt":
				await _child_bh_identity("bh_jolt")
			"bh_dummy":
				await _child_bh_identity("bh_dummy")
			"au_plain":
				await _child_acq_use("au_plain")
			"au_jolt":
				await _child_acq_use("au_jolt")
			"ss_plain":
				await _child_step_stamp("ss_plain")
			"ss_jolt":
				await _child_step_stamp("ss_jolt")
			"wl_plain":
				await _child_write_loss("wl_plain")
			"bt_plain":
				await _child_body_tier("bt_plain")
			"bt_jolt":
				await _child_body_tier("bt_jolt")
			"bt_dummy":
				await _child_body_tier("bt_dummy")
			"fs_plain":
				await _child_freed_space("fs_plain")
			"fs_jolt":
				await _child_freed_space("fs_jolt")
			"fs_dummy":
				await _child_freed_space("fs_dummy")
			"mo_plain":
				await _child_motion_split("mo_plain")
			"mo_jolt":
				await _child_motion_split("mo_jolt")
			"mo_dummy":
				await _child_motion_split("mo_dummy")
			"fg_plain":
				await _child_fetch_gate("fg_plain")
			"fg_thr":
				await _child_fetch_gate("fg_thr")
			"fg_jolt_thr":
				await _child_fetch_gate("fg_jolt_thr")
			"fg_dummy":
				await _child_fetch_gate("fg_dummy")
			"fg_dummy_thr":
				await _child_fetch_gate("fg_dummy_thr")
			"ia_plain":
				await _child_inactive_space("ia_plain")
			"ia_thr":
				await _child_inactive_space("ia_thr")
			"ia_jolt_thr":
				await _child_inactive_space("ia_jolt_thr")
			"rc_plain":
				await _child_race_class("rc_plain")
			"rc_jolt":
				await _child_race_class("rc_jolt")
			"pq_plain":
				await _child_param_purity("pq_plain")
			"pq_jolt":
				await _child_param_purity("pq_jolt")
			"pq_dummy":
				await _child_param_purity("pq_dummy")
			"bi_plain":
				await _child_body_inertia("bi_plain")
			"bi_jolt":
				await _child_body_inertia("bi_jolt")
			"bi_dummy":
				await _child_body_inertia("bi_dummy")
			"wa_plain":
				await _child_wrong_args("wa_plain")
			"wa_jolt":
				await _child_wrong_args("wa_jolt")
			"wa_dummy":
				await _child_wrong_args("wa_dummy")
			"gs_plain":
				await _child_geom_split("gs_plain")
			"gs_jolt":
				await _child_geom_split("gs_jolt")
			"fd_dummy":
				await _child_freed_dummy("fd_dummy")
			"ip_plain", "ip_jolt", "ip_dummy":
				await _child_if_phase(arm_any)
			"jp_plain", "jp_jolt", "jp_dummy":
				await _child_joint_pin(arm_any)
			"jq_plain", "jq_jolt", "jq_dummy":
				await _child_joint_param(arm_any)
			"iw_plain", "iw_jolt", "iw_dummy":
				await _child_if_write(arm_any)
			"cx_plain", "cx_jolt", "cx_dummy":
				await _child_cross_space(arm_any)
			"js_plain", "js_jolt", "js_dummy":
				await _child_joint_solver(arm_any)
			var bad:
				_quit_clean(2, "CHILD_RESULT child_arm=unknown arm='%s'" % bad)
		return

	var arm := _argval("--arm=", "isect")
	wspace = root.get_world_3d().space
	dss = root.get_world_3d().direct_space_state
	# a null process-context fetch must fail named — a silent null would
	# hang the query arms to the harness timeout instead (reviewer F3)
	if dss == null:
		return _fail("dss null at process-context fetch")

	match arm:
		"isect":
			# wall box half=1 at z=-3 (face -2); sphere r=.5 at z=-2.5 overlaps.
			var wall := _mk_body(Vector3(0, 0, -3))
			await _frames(SETTLE)
			var q := _sphere_params(Vector3(0, 0, -2.5))
			var qmask := _sphere_params(Vector3(0, 0, -2.5), Vector3.ZERO, 2)
			var s0 := dss.intersect_shape(q).size()
			var m0 := dss.intersect_shape(qmask).size()
			if s0 != 1 or m0 != 0:
				return _fail("isect setup wrong s0=%d mask2=%d" % [s0, m0])
			PhysicsServer3D.body_set_state(wall,
					PhysicsServer3D.BODY_STATE_TRANSFORM, Transform3D(Basis(), WALL_FAR))
			var away := dss.intersect_shape(q).size()
			await _frames(1)
			var away_n1 := dss.intersect_shape(q).size()
			PhysicsServer3D.body_set_state(wall,
					PhysicsServer3D.BODY_STATE_TRANSFORM,
					Transform3D(Basis(), Vector3(0, 0, -3)))
			var back := dss.intersect_shape(q).size()
			if away != 0 or away_n1 != 0 or back != 1:
				return _fail("isect edge drift away=%d n1=%d back=%d"
						% [away, away_n1, back])
			_exit_ok("PASS phys3d_events isect settled=1 mask2=0 away_w0=0 away_n1=0 back_w0=1")

		"cast":
			# sphere r=.5 at origin cast (0,0,-10): wall face z=-2 gives
			# safe 0.14453125 / unsafe 0.150390625 on this build; wall -> -30
			# yields [1.0, 1.0] in the same turn.
			var wall := _mk_body(Vector3(0, 0, -3))
			await _frames(SETTLE)
			var q := _sphere_params(Vector3.ZERO, Vector3(0, 0, -10))
			var c0 := dss.cast_motion(q)
			if absf(c0[0] - 0.14453125) > 0.0001 or absf(c0[1] - 0.150390625) > 0.0001:
				return _fail("cast settled fractions drift safe=%s unsafe=%s"
						% [str(c0[0]), str(c0[1])])
			PhysicsServer3D.body_set_state(wall,
					PhysicsServer3D.BODY_STATE_TRANSFORM, Transform3D(Basis(), WALL_FAR))
			var c1 := dss.cast_motion(q)
			await _frames(1)
			var c2 := dss.cast_motion(q)
			if absf(c1[0] - 1.0) > 0.0001 or absf(c1[1] - 1.0) > 0.0001 \
					or absf(c2[0] - 1.0) > 0.0001 or absf(c2[1] - 1.0) > 0.0001:
				return _fail("cast edge drift w0=%s,%s n1=%s,%s"
						% [str(c1[0]), str(c1[1]), str(c2[0]), str(c2[1])])
			_exit_ok("PASS phys3d_events cast settled_safe=0.144531 settled_unsafe=0.150391 w0=1.000000 n1=1.000000")

		"btm":
			# kinematic probe at origin, motion (0,0,-10): wall at z=-3 gives
			# hit + truncated travel; wall -> -30 clears in the same turn.
			var wall := _mk_body(Vector3(0, 0, -3))
			var probe := _mk_body(Vector3.ZERO, PhysicsServer3D.BODY_MODE_KINEMATIC)
			await _frames(SETTLE)
			var params := PhysicsTestMotionParameters3D.new()
			params.from = Transform3D(Basis(), Vector3.ZERO)
			params.motion = Vector3(0, 0, -10)
			var res := PhysicsTestMotionResult3D.new()
			var r0 := PhysicsServer3D.body_test_motion(probe, params, res)
			if not r0 or absf(res.get_travel().z - (-0.9765625)) > 0.001:
				return _fail("btm setup wrong hit=%s travel=%s"
						% [str(r0), str(res.get_travel())])
			PhysicsServer3D.body_set_state(wall,
					PhysicsServer3D.BODY_STATE_TRANSFORM, Transform3D(Basis(), WALL_FAR))
			var res1 := PhysicsTestMotionResult3D.new()
			var r1 := PhysicsServer3D.body_test_motion(probe, params, res1)
			await _frames(1)
			var res2 := PhysicsTestMotionResult3D.new()
			var r2 := PhysicsServer3D.body_test_motion(probe, params, res2)
			if r1 or r2 or absf(res1.get_travel().z - (-10.0)) > 0.0001 \
					or absf(res2.get_travel().z - (-10.0)) > 0.0001:
				return _fail("btm edge drift w0=%s,%s n1=%s,%s"
						% [str(r1), str(res1.get_travel()),
						str(r2), str(res2.get_travel())])
			_exit_ok("PASS phys3d_events btm settled_hit=true settled_travel=-0.976562 w0_hit=false w0_travel=-10.000000 n1_hit=false")

		"pp_queries":
			# callsite tier: write + ray/isect/cast/btm inside _physics_process.
			var wall := _mk_body(Vector3(0, 0, -3))
			var probe := _mk_body(Vector3.ZERO, PhysicsServer3D.BODY_MODE_KINEMATIC)
			await _frames(SETTLE)
			var w := PPQueries.new()
			w.wall = wall
			w.probe = probe
			w.wspace = wspace
			w.dss = dss
			root.add_child(w)
			owned_nodes.append(w)
			var deadline := Engine.get_physics_frames() + 30
			while not w.printed and Engine.get_physics_frames() < deadline:
				await _frames(1)
			if not w.result_ok():
				return _fail("pp_queries drift printed=%s ray=%s isect=%d safe=%s btm=%s"
						% [str(w.printed), str(w.ray_hit), w.isect_n,
						str(w.safe), str(w.btm_hit)])
			_exit_ok("PASS phys3d_events pp_queries ray_hit=false isect=0 safe=1.000000 btm=false travel=-10.000000")

		"contact_stale":
			# two-tier discriminant: teleport INTO floor overlap -> w0 the
			# query (intersect_shape, body excluded) already sees the floor
			# while get_contact_count is still 0; generated contacts land at
			# the next tick (4). Teleport back UP -> w0 still reports 4
			# (stale generated data), cleared at the next tick.
			var floor_b := _mk_body(Vector3(0, -1, 0))
			var rig := _mk_body(Vector3(0, 8, 0), PhysicsServer3D.BODY_MODE_RIGID)
			PhysicsServer3D.body_set_param(rig,
					PhysicsServer3D.BODY_PARAM_GRAVITY_SCALE, 0.0)
			PhysicsServer3D.body_set_max_contacts_reported(rig, 8)
			await _frames(SETTLE)
			if _contacts(rig) != 0 or _floor_isect_hits(rig) != 1:
				return _fail("contact_stale setup c=%d isect=%d"
						% [_contacts(rig), _floor_isect_hits(rig)])
			PhysicsServer3D.body_set_state(rig,
					PhysicsServer3D.BODY_STATE_TRANSFORM, Transform3D(Basis(), Vector3(0, 0.5, 0)))
			var in_w0_c := _contacts(rig)
			var in_w0_i := _floor_isect_hits(rig)
			await _frames(1)
			var in_n1_c := _contacts(rig)
			if in_w0_c != 0 or in_w0_i != 1 or in_n1_c != 4:
				return _fail("contact_stale in-phase drift w0_c=%d w0_i=%d n1_c=%d"
						% [in_w0_c, in_w0_i, in_n1_c])
			PhysicsServer3D.body_set_state(rig,
					PhysicsServer3D.BODY_STATE_TRANSFORM, Transform3D(Basis(), Vector3(0, 8, 0)))
			var out_w0_c := _contacts(rig)
			await _frames(1)
			var out_n1_c := _contacts(rig)
			if out_w0_c != 4 or out_n1_c != 0:
				return _fail("contact_stale out-phase drift w0_c=%d n1_c=%d"
						% [out_w0_c, out_n1_c])
			_exit_ok("PASS phys3d_events contact_stale in_w0_c=0 in_w0_isect=1 in_n1_c=4 out_w0_c=4 out_n1_c=0")

		"contact_sig":
			# rigid node body teleported into a settled Area3D mid-frame:
			# body_entered never fires same-turn; it lands at the next tick.
			var area := Area3D.new()
			var ashape := CollisionShape3D.new()
			var abox := BoxShape3D.new()
			abox.size = Vector3(4, 4, 4)
			ashape.shape = abox
			area.add_child(ashape)
			area.collision_layer = 0
			area.collision_mask = 2
			area.monitoring = true
			area.body_entered.connect(func(_b):
				sig_log.append(Engine.get_physics_frames()))
			root.add_child(area)
			owned_nodes.append(area)
			var bshape := CollisionShape3D.new()
			var bbox := BoxShape3D.new()
			bbox.size = Vector3(1, 1, 1)
			bshape.shape = bbox
			var body := RigidBody3D.new()
			body.collision_layer = 2
			body.gravity_scale = 0.0
			body.add_child(bshape)
			body.position = WALL_FAR
			root.add_child(body)
			owned_nodes.append(body)
			await _frames(SETTLE)
			var f0 := Engine.get_physics_frames()
			body.position = Vector3.ZERO
			var w0_fired := sig_log.size() > 0
			var w0_ov := area.get_overlapping_bodies().size()
			await _frames(1)
			var n1_fired := sig_log.size() > 0
			var n1_ov := area.get_overlapping_bodies().size()
			var delta: int = -1
			if n1_fired:
				delta = sig_log[0] - f0
			if w0_fired or not n1_fired or delta != 1 or w0_ov != 0 or n1_ov != 1:
				return _fail("contact_sig drift w0=%s n1=%s delta=%d ov=%d,%d"
						% [str(w0_fired), str(n1_fired), delta, w0_ov, n1_ov])
			_exit_ok("PASS phys3d_events contact_sig w0_fired=false w0_overlaps=0 n1_entered=true delta=1 n1_overlaps=1")

		"sync_cb":
			# body_set_state_sync_callback fires once per physics tick while
			# the body is active; a STATIC body's callback never fires.
			var rig := _mk_body(Vector3(0, 5, 0), PhysicsServer3D.BODY_MODE_RIGID)
			PhysicsServer3D.body_set_param(rig,
					PhysicsServer3D.BODY_PARAM_GRAVITY_SCALE, 0.0)
			await _frames(SETTLE)
			var count := [0]
			PhysicsServer3D.body_set_state_sync_callback(rig, func(_s):
				count[0] += 1)
			var w0: int = count[0]
			await _frames(1)
			var n1: int = count[0]
			await _frames(2)
			var n3: int = count[0]
			var stbody := _mk_body(Vector3(0, 20, 0))
			var scount := [0]
			PhysicsServer3D.body_set_state_sync_callback(stbody, func(_s):
				scount[0] += 1)
			await _frames(2)
			var sstatic: int = scount[0]
			if w0 != 0 or n1 != 1 or n3 != 3 or sstatic != 0:
				return _fail("sync_cb drift w0=%d n1=%d n3=%d static=%d"
						% [w0, n1, n3, sstatic])
			_exit_ok("PASS phys3d_events sync_cb w0=0 n1=1 n3=3 static_cb=0")

		"srv_area_cb":
			# server-level monitor callback: rigid body teleport -> enter at
			# next tick; area moved off/on -> exit/enter each at next tick.
			var ashape := PhysicsServer3D.box_shape_create()
			PhysicsServer3D.shape_set_data(ashape, Vector3(2.0, 2.0, 2.0))
			var area := PhysicsServer3D.area_create()
			PhysicsServer3D.area_add_shape(area, ashape)
			PhysicsServer3D.area_set_collision_layer(area, 1)
			PhysicsServer3D.area_set_collision_mask(area, 1)
			PhysicsServer3D.area_set_space(area, wspace)
			PhysicsServer3D.area_set_transform(area, Transform3D(Basis(), Vector3.ZERO))
			owned.append_array([area, ashape])
			PhysicsServer3D.area_set_monitor_callback(area,
					func(status, _rid, _iid, _shape, _self_shape):
					sig_log.append("%d@%d" % [status, Engine.get_physics_frames()]))
			var rig := _mk_body(WALL_FAR, PhysicsServer3D.BODY_MODE_RIGID)
			PhysicsServer3D.body_set_param(rig,
					PhysicsServer3D.BODY_PARAM_GRAVITY_SCALE, 0.0)
			await _frames(SETTLE)
			var f0 := Engine.get_physics_frames()
			PhysicsServer3D.body_set_state(rig,
					PhysicsServer3D.BODY_STATE_TRANSFORM, Transform3D(Basis(), Vector3.ZERO))
			await _frames(1)
			var enter_ok := sig_log.has("0@%d" % (f0 + 1)) and sig_log.size() == 1
			PhysicsServer3D.area_set_transform(area, Transform3D(Basis(), WALL_FAR))
			var f1 := Engine.get_physics_frames()
			await _frames(1)
			var exit_ok := sig_log.has("1@%d" % (f1 + 1)) and sig_log.size() == 2
			PhysicsServer3D.area_set_transform(area, Transform3D(Basis(), Vector3.ZERO))
			var f2 := Engine.get_physics_frames()
			await _frames(1)
			var reenter_ok := sig_log.has("0@%d" % (f2 + 1)) and sig_log.size() == 3
			if not enter_ok or not exit_ok or not reenter_ok:
				return _fail("srv_area_cb drift log=%s" % str(sig_log))
			_exit_ok("PASS phys3d_events srv_area_cb enter=1 exit=1 reenter=1 all_delta1=true")

		"static_nopair":
			# NEGATIVE: static body teleported into a settled area never
			# re-pairs — no body_entered for 3 ticks, overlaps stays 0 —
			# while moving the AREA onto the same body fires at the next
			# tick, proving the setup is live and the event tier only
			# re-pairs movers.
			var area := Area3D.new()
			var ashape := CollisionShape3D.new()
			var abox := BoxShape3D.new()
			abox.size = Vector3(4, 4, 4)
			ashape.shape = abox
			area.add_child(ashape)
			area.collision_layer = 0
			area.collision_mask = 2
			area.monitoring = true
			area.body_entered.connect(func(_b):
				sig_log.append(Engine.get_physics_frames()))
			root.add_child(area)
			owned_nodes.append(area)
			var bshape := CollisionShape3D.new()
			var bbox := BoxShape3D.new()
			bbox.size = Vector3(1, 1, 1)
			bshape.shape = bbox
			var body := StaticBody3D.new()
			body.collision_layer = 2
			body.add_child(bshape)
			body.position = WALL_FAR
			root.add_child(body)
			owned_nodes.append(body)
			await _frames(SETTLE)
			body.position = Vector3.ZERO
			for i in range(3):
				await _frames(1)
			var tp_fired := sig_log.size() > 0
			var tp_ov := area.get_overlapping_bodies().size()
			area.position = WALL_FAR
			await _frames(1)
			area.position = Vector3.ZERO
			# Clear the tp-phase entries — without this the control's
			# mv_delta reads a stale first entry and prints a nonsense
			# negative delta on the failing path (critic C2).
			sig_log.clear()
			var f_mv := Engine.get_physics_frames()
			await _frames(2)
			var mv_fired := sig_log.size() > 0
			var mv_delta: int = -1
			if mv_fired:
				mv_delta = sig_log[0] - f_mv
			if tp_fired or tp_ov != 0 or not mv_fired or mv_delta != 1:
				return _fail("static_nopair drift tp=%s ov=%d mv=%s delta=%d"
						% [str(tp_fired), tp_ov, str(mv_fired), mv_delta])
			_quit_clean(2, "NEGATIVE REJECTED: phys3d_events static_nopair static_tp_fired=false ticks=3 area_move_delta=1")

		"threaded_edge":
			# conversion cell: same queries under run_on_separate_thread=true.
			# _spawn_child (r85 V2 fold) writes res://thrproj and re-execs
			# this script with --child through /bin/sh so the child's
			# stdout+stderr land in a log file (OS.execute's output array only
			# captured the startup banner on this build — measured hazard);
			# the child's ERROR diagnostics can then never reach the case
			# stream, and the log doubles as evidence. The refusal-class
			# "Space state is inaccessible" ERRORs are the expected witness
			# (allow_inaccessible); any other engine ERROR is a defect
			# (reviewer F4).
			var spawned := _spawn_child("thrproj",
					_project_body("ThrChild", "", true),
					"threaded_edge", true)
			if spawned.has("err"):
				return _fail(spawned["err"])
			var expect := ("CHILD_RESULT pp_edge0=true "
					+ "proc_dss_refused=true srv_ok=true")
			if spawned["code"] != 0 or spawned["serr"] or spawned["last"] != expect:
				return _fail("threaded_edge child mismatch exit=%d serr=%s verdict='%s'"
						% [spawned["code"], str(spawned["serr"]), spawned["last"]])
			_exit_ok("PASS phys3d_events threaded_edge pp_edge0=true proc_dss_refused=true srv_ok=true child_exit=0")

		"phase_delta":
			# write-phase discriminant as a first-class cell (r83 critic
			# C1): the SAME rigid teleport into the SAME settled area
			# fires body_entered at delta=2 when the write issues from the
			# process phase (await process_frame continuation) vs delta=1
			# from the physics phase — the frame owns the extra tick, not
			# the solver (replicated live-only under Jolt: identical
			# deltas on this build).
			var area := Area3D.new()
			var ashape := CollisionShape3D.new()
			var abox := BoxShape3D.new()
			abox.size = Vector3(4, 4, 4)
			ashape.shape = abox
			area.add_child(ashape)
			area.collision_layer = 0
			area.collision_mask = 2
			area.monitoring = true
			area.body_entered.connect(func(_b):
				sig_log.append(Engine.get_physics_frames()))
			root.add_child(area)
			owned_nodes.append(area)
			var bshape := CollisionShape3D.new()
			var bbox := BoxShape3D.new()
			bbox.size = Vector3(1, 1, 1)
			bshape.shape = bbox
			var body := RigidBody3D.new()
			body.collision_layer = 2
			body.gravity_scale = 0.0
			body.add_child(bshape)
			body.position = WALL_FAR
			root.add_child(body)
			owned_nodes.append(body)
			await _frames(SETTLE)
			# (a) process-phase write -> enter lands TWO ticks later.
			await process_frame
			var f0 := Engine.get_physics_frames()
			body.position = Vector3.ZERO
			var w0_fired := sig_log.size() > 0
			var w0_ov := area.get_overlapping_bodies().size()
			await _frames(1)
			var n1_fired := sig_log.size() > 0
			var n1_ov := area.get_overlapping_bodies().size()
			await _frames(1)
			var n2_fired := sig_log.size() > 0
			var n2_ov := area.get_overlapping_bodies().size()
			var proc_delta: int = -1
			if n2_fired:
				proc_delta = sig_log[0] - f0
			if w0_fired or n1_fired or not n2_fired or proc_delta != 2 \
					or w0_ov != 0 or n1_ov != 0 or n2_ov != 1:
				return _fail("phase_delta proc-phase drift w0=%s,%d n1=%s,%d n2=%s,%d delta=%d"
						% [str(w0_fired), w0_ov, str(n1_fired), n1_ov,
						str(n2_fired), n2_ov, proc_delta])
			# (b) dissolve the pair, then the physics-phase contrast. The
			# sig_log clear mirrors static_nopair: without it the delta
			# reads a stale first entry (critic C2 lesson folded in r83).
			body.position = WALL_FAR
			await _frames(6)
			var left := area.get_overlapping_bodies().size()
			sig_log.clear()
			var f1 := Engine.get_physics_frames()
			body.position = Vector3.ZERO
			var p0_fired := sig_log.size() > 0
			await _frames(1)
			var p1_fired := sig_log.size() > 0
			var p1_ov := area.get_overlapping_bodies().size()
			var phys_delta: int = -1
			if p1_fired:
				phys_delta = sig_log[0] - f1
			if left != 0 or p0_fired or not p1_fired or phys_delta != 1 \
					or p1_ov != 1:
				return _fail("phase_delta phys-phase drift left=%d w0=%s n1=%s,%d delta=%d"
						% [left, str(p0_fired), str(p1_fired), p1_ov, phys_delta])
			_exit_ok("PASS phys3d_events phase_delta proc_delta=2 phys_delta=1")

		"jolt_edge":
			# backend-split cell: re-exec this script under a generated
			# physics/3d/physics_engine="Jolt Physics" project (the
			# threaded_edge thrproj pattern -> joltproj, now through
			# _spawn_child) and pin the per-arm split {same-signature |
			# differs-constants | inverts}. static_nopair is the known
			# inverter (r83 critic C2: under Jolt the teleported static
			# body pairs and fires). Gate first: if this build's engine
			# hint lacks "Jolt Physics" the row reports BLOCKED, never a
			# fabricated split.
			if _gate("Jolt Physics", "jolt_edge", "jolt"): return
			var spawned := _spawn_child("joltproj",
					_project_body("JoltChild", "Jolt Physics", false),
					"jolt_edge", false)
			if spawned.has("err"):
				return _fail(spawned["err"])
			# no expected-witness error class under Jolt: any engine
			# ERROR: is a defect (r83 reviewer F4) — allow_inaccessible=0.
			var expect := {
				"jolt_backend": "Jolt Physics",
				"jolt_dss_class": "JoltPhysicsDirectSpaceState3D",
				"jolt_isect": "same-signature",
				"jolt_cast": "differs-constants",
				"jolt_btm": "differs-constants",
				"jolt_contact_stale": "same-signature",
				"jolt_static_nopair": "inverts",
			}
			if spawned["code"] != 0 or spawned["serr"] \
					or spawned["verdicts"] != expect:
				return _fail("jolt_edge child mismatch exit=%d serr=%s verdicts=%s"
						% [spawned["code"], str(spawned["serr"]),
						str(spawned["verdicts"])])
			_exit_ok("PASS phys3d_events jolt_edge backend=Jolt isect=same cast=constants btm=constants contact_stale=same static_nopair=inverts child_exit=0")

		"jolt_threaded":
			# cross-product cell (r85): generated child carrying BOTH
			# physics_engine="Jolt Physics" AND
			# 3d/run_on_separate_thread=true. Pins whether the backend
			# split {same-signature | differs-constants | inverts} holds
			# identically under the threaded stepper. The map additionally
			# pins jt_threaded=true — the child's process-context
			# space_get_direct_state refusals — so a project whose
			# threading flag was silently ignored fails loudly (those
			# refusal ERRORs are the expected witness class here).
			if _gate("Jolt Physics", "jolt_threaded", "jolt"): return
			var spawned := _spawn_child("joltthrproj",
					_project_body("JoltThrChild", "Jolt Physics", true),
					"jolt_threaded", true)
			if spawned.has("err"):
				return _fail(spawned["err"])
			var expect_jt := {
				"jt_backend": "Jolt Physics",
				"jt_threaded": "true",
				"jt_dss_class": "JoltPhysicsDirectSpaceState3D",
				"jt_isect": "same-signature",
				"jt_cast": "differs-constants",
				"jt_btm": "differs-constants",
				"jt_contact_stale": "same-signature",
				"jt_static_nopair": "inverts",
			}
			if spawned["code"] != 0 or spawned["serr"] \
					or spawned["verdicts"] != expect_jt:
				return _fail("jolt_threaded child mismatch exit=%d serr=%s verdicts=%s"
						% [spawned["code"], str(spawned["serr"]),
						str(spawned["verdicts"])])
			_exit_ok("PASS phys3d_events jolt_threaded backend=Jolt threaded=true isect=same cast=constants btm=constants contact_stale=same static_nopair=inverts child_exit=0")

		"dummy_refused":
			# negative control (r85): the SAME reduced sweep under
			# physics_engine="Dummy". Dummy answers every query with
			# zero/silent reads, so every arm must classify 'unexpected'
			# — never a known-class label. This cell proves the
			# {same|differs|inverts} split is backend-real: the verdict
			# map changes with the backend, not with the sweep code.
			if _gate("Dummy", "dummy_refused", "dummy"): return
			var spawned := _spawn_child("dummyproj",
					_project_body("DummyChild", "Dummy", false),
					"dummy_refused", false)
			if spawned.has("err"):
				return _fail(spawned["err"])
			var expect_dm := {
				"dummy_backend": "Dummy",
				"dummy_dss_class": "PhysicsDirectSpaceState3DDummy",
				"dummy_isect": "unexpected",
				"dummy_cast": "unexpected",
				"dummy_btm": "unexpected",
				"dummy_contact_stale": "unexpected",
				"dummy_static_nopair": "unexpected",
			}
			if spawned["code"] != 0 or spawned["serr"] \
					or spawned["verdicts"] != expect_dm:
				return _fail("dummy_refused child mismatch exit=%d serr=%s verdicts=%s"
						% [spawned["code"], str(spawned["serr"]),
						str(spawned["verdicts"])])
			_exit_ok("PASS phys3d_events dummy_refused backend=Dummy isect=unexpected cast=unexpected btm=unexpected contact_stale=unexpected static_nopair=unexpected child_exit=0")

		"srv_phase_delta":
			# server-write phase delta (r85 stretch): a
			# PhysicsServer3D-level body_set_state write vs the
			# node-position writes of phase_delta — the event tier lands
			# at the SAME boundaries (proc -> delta=2, physics -> delta=1):
			# the write PATH is not a tier, the write PHASE is. The
			# monitor must be the server-level area_set_monitor_callback:
			# a raw server RID carries no instance id, so a node Area3D's
			# body_entered / get_overlapping_bodies can never resolve it
			# (measured r85: node monitor stays silent under a
			# server-write pair).
			var srv_log := []
			var sashape := PhysicsServer3D.box_shape_create()
			PhysicsServer3D.shape_set_data(sashape, Vector3(2.0, 2.0, 2.0))
			var sarea := PhysicsServer3D.area_create()
			PhysicsServer3D.area_add_shape(sarea, sashape)
			PhysicsServer3D.area_set_collision_layer(sarea, 1)
			PhysicsServer3D.area_set_collision_mask(sarea, 1)
			PhysicsServer3D.area_set_space(sarea, wspace)
			PhysicsServer3D.area_set_transform(sarea,
					Transform3D(Basis(), Vector3.ZERO))
			owned.append_array([sarea, sashape])
			PhysicsServer3D.area_set_monitor_callback(sarea,
					func(status, _rid, _iid, _shape, _self_shape):
					srv_log.append("%d@%d" % [status, Engine.get_physics_frames()]))
			var srig := _mk_body(WALL_FAR, PhysicsServer3D.BODY_MODE_RIGID)
			PhysicsServer3D.body_set_param(srig,
					PhysicsServer3D.BODY_PARAM_GRAVITY_SCALE, 0.0)
			await _frames(SETTLE)
			# (a) process-phase server write -> enter lands TWO ticks
			# later (the phase_delta boundary, via the server path).
			await process_frame
			var f0 := Engine.get_physics_frames()
			PhysicsServer3D.body_set_state(srig,
					PhysicsServer3D.BODY_STATE_TRANSFORM,
					Transform3D(Basis(), Vector3.ZERO))
			var s_w0 := srv_log.size()
			await _frames(1)
			var s_n1 := srv_log.size()
			await _frames(1)
			var s_n2 := srv_log.size()
			if s_w0 != 0 or s_n1 != 0 or s_n2 != 1 \
					or srv_log != ["0@%d" % (f0 + 2)]:
				return _fail("srv_phase_delta proc drift w0=%d n1=%d n2=%d log=%s"
						% [s_w0, s_n1, s_n2, str(srv_log)])
			# (b) dissolve (exit at +1 from this in-phase write), clear,
			# then the physics-phase contrast: enter at +1.
			PhysicsServer3D.body_set_state(srig,
					PhysicsServer3D.BODY_STATE_TRANSFORM,
					Transform3D(Basis(), WALL_FAR))
			var fexit := Engine.get_physics_frames()
			await _frames(1)
			var exit_ok := srv_log.size() == 2 \
					and srv_log.has("1@%d" % (fexit + 1))
			await _frames(5)
			srv_log.clear()
			var f1 := Engine.get_physics_frames()
			PhysicsServer3D.body_set_state(srig,
					PhysicsServer3D.BODY_STATE_TRANSFORM,
					Transform3D(Basis(), Vector3.ZERO))
			var s_p0 := srv_log.size()
			await _frames(1)
			var s_p1 := srv_log.size()
			if not exit_ok or s_p0 != 0 or s_p1 != 1 \
					or srv_log != ["0@%d" % (f1 + 1)]:
				return _fail("srv_phase_delta phys drift exit=%s p0=%d p1=%d log=%s"
						% [str(exit_ok), s_p0, s_p1, str(srv_log)])
			_exit_ok("PASS phys3d_events srv_phase_delta srv_proc_delta=2 srv_phys_delta=1")

		"script_size_gate":
			# size-gate cell (r86): the deferred process-context fetch is
			# released or refused by the script's STATEMENT COUNT, NOT by
			# the fetch position — an uncalled function body releases it
			# too (r86 critic A3: dead code at 1000 statements granted
			# 7/7) — and on this host that is
			# a ~100-line STOCHASTIC BAND (~475-575 lines), not a boundary
			# (r86 boundary §1, 6 reps per point: deterministic refusal
			# below, deterministic grant above, a race inside). One
			# generated source at two sizes in the same threaded project
			# is the discriminating pair: the same `_run` body is refused
			# at 25 lines and granted at 1025, and both ends sit far
			# outside the band. The unthreaded child is the control — the
			# minimal body is granted without the threading flag, so the
			# gate needs the flag AND the small script. The fourth child
			# is this fixture itself (bare fetch, same position): it is
			# granted, which is the LATENT fragility this arm makes loud —
			# the r86 boundary seat shrank the fixture 16 times to 725
			# lines without flipping it, so the file would have to lose
			# ~500 lines of real tokens to reach the band.
			#
			# Witness discipline: every child here is a self-report, so
			# each is corroborated by the engine's own lines in its log —
			# exactly one refusal for the refused child, none for the three
			# granted ones — and the carve-out is NOT used, so an extra
			# refusal at any callsite fails the arm instead of hiding.
			var thr_proj := _project_body("SzThr", "", true)
			var plain_proj := _project_body("SzPlain", "", false)
			var min_body := _size_probe_body(0)
			var min_thr := _spawn_probe("szminproj", thr_proj, "szprobe.gd",
					min_body, "guarded", false)
			if min_thr.has("err"):
				return _fail(min_thr["err"])
			var min_plain := _spawn_probe("szplainproj", plain_proj, "szprobe.gd",
					min_body, "guarded", false)
			if min_plain.has("err"):
				return _fail(min_plain["err"])
			var pad_thr := _spawn_probe("szpadproj", thr_proj, "szprobe.gd",
					_size_probe_body(SIZE_PAD), "guarded", false)
			if pad_thr.has("err"):
				return _fail(pad_thr["err"])
			var fixture_thr := _spawn_child("szfxproj", thr_proj, "size_probe", false)
			if fixture_thr.has("err"):
				return _fail(fixture_thr["err"])
			var probes := [
				["min_thr", min_thr, "sz_fetch", "refused", 1,
						"ERROR: Space state is inaccessible"],
				["min_plain", min_plain, "sz_fetch", "granted", 0, ""],
				["pad_thr", pad_thr, "sz_fetch", "granted", 0, ""],
				["fixture_thr", fixture_thr, "sp_fetch", "granted", 0, ""],
			]
			for spec in probes:
				var spawn: Dictionary = spec[1]
				var errs: Array = spawn["errs"]
				var verdicts: Dictionary = spawn["verdicts"]
				var ok: bool = spawn["code"] == 0 and verdicts.size() == 1 \
						and verdicts.get(spec[2]) == spec[3] \
						and errs.size() == spec[4]
				if ok and spec[4] == 1:
					ok = str(errs[0]).begins_with(spec[5])
				if not ok:
					return _fail("script_size_gate %s drift exit=%d v=%s errs=%s"
							% [spec[0], spawn["code"], str(verdicts), str(errs)])
			# the refused child's own "ERROR: Space state is inaccessible"
			# print would satisfy the spec above (boundary MX4 / critic A4 —
			# the child log merges 2>&1 by design for position fidelity, so
			# corroborate by the ENGINE's provenance line in the raw log,
			# which a self-print cannot produce).
			var min_log := FileAccess.open(ProjectSettings.globalize_path(
					"res://szminproj/child.log"), FileAccess.READ)
			var saw_callsite := false
			if min_log != null:
				while not min_log.eof_reached():
					if "space_get_direct_state" in min_log.get_line():
						saw_callsite = true
				min_log.close()
			if not saw_callsite:
				return _fail("script_size_gate min_thr: no engine "
						+ "space_get_direct_state callsite line in the raw "
						+ "child log — the refusal could be self-printed")
			_exit_ok("PASS phys3d_events script_size_gate min_thr=refused min_plain=granted pad_thr=granted fixture_thr=granted child_exit=0")

		"deferred_hang":
			# hang-class cell (r86): an unguarded deref of the refused
			# fetch inside the deferred `_run` coroutine aborts the
			# coroutine before quit(), the SceneTree keeps running with
			# no exit condition, and the spawn bound kills it — rc 137
			# through /bin/sh, no CHILD_RESULT line at all. rc is the only
			# detector: a SIGKILLed process emits no at-exit report, so
			# the leak scan never runs and the zombie RIDs stay invisible
			# (r86 boundary §3.1). The witness is engine-level and
			# two-sided — the refusal that caused the abort AND the abort
			# line, both in the child log, plus the process-level rc —
			# never the killed child's own report, which cannot exist.
			# The Dummy+threaded child is the contrast and the class
			# boundary: the silent floor grants every fetch, so the
			# IDENTICAL body dereferences a real handle, prints its class
			# and exits 0 — the hang is reachable only where a refusal is,
			# never under Dummy.
			var hang_thr := _project_body("HangThr", "", true)
			var hang_dummy := _project_body("HangDummy", "Dummy", true)
			var hang_body := _size_probe_body(0)
			var hung := _spawn_probe("hangproj", hang_thr, "szprobe.gd",
					hang_body, "deref", false, HANG_BOUND_S)
			if hung.has("err"):
				return _fail(hung["err"])
			var floor_ok := _spawn_probe("hangdummyproj", hang_dummy, "szprobe.gd",
					hang_body, "deref", false, HANG_BOUND_S)
			if floor_ok.has("err"):
				return _fail(floor_ok["err"])
			var aborted := false
			var refused := false
			for line in hung["errs"]:
				# the landed abort text, not just the class: an unrelated
				# SCRIPT ERROR elsewhere in the child must not satisfy the
				# witness (r86 critic A1).
				if "SCRIPT ERROR" in line and "null instance" in line:
					aborted = true
				if str(line).begins_with("ERROR: Space state is inaccessible"):
					refused = true
			if hung["code"] != HANG_RC or not hung["verdicts"].is_empty() \
					or not aborted or not refused or hung["errs"].size() != 2:
				return _fail("deferred_hang drift exit=%d expected=%d marker=%s abort=%s refusal=%s errs=%s"
						% [hung["code"], HANG_RC, str(hung["verdicts"]),
						str(aborted), str(refused), str(hung["errs"])])
			if floor_ok["code"] != 0 or not floor_ok["errs"].is_empty() \
					or floor_ok["verdicts"] != {"sz_abort": "PhysicsDirectSpaceState3DDummy"}:
				return _fail("deferred_hang dummy-floor drift exit=%d errs=%s v=%s"
						% [floor_ok["code"], str(floor_ok["errs"]),
						str(floor_ok["verdicts"])])
			_exit_ok("PASS phys3d_events deferred_hang threaded_rc=137 abort=true no_marker=true dummy_rc=0 floor_no_hang=true child_exit=0")

		"backend_tier":
			# backend tier matrix (r86): the SAME tier sweep under the
			# three generated projects, so a class difference can never
			# be a code difference. Area gravity/damping overrides are
			# the new inverter — GodotPhysics honours them (the body
			# reads (0,20,0) / damp 2.0), Jolt silently ignores them
			# while the area parameter itself reads back 20.0 (the write
			# lands, the effect does not), and Dummy is the silent floor.
			# The shape-query margin splits the other way: inert on
			# GodotPhysics, honoured by Jolt, empty under Dummy. The
			# separation ray keeps the edge and differs only in solver
			# constants. Gated on both engine hints — absent means an
			# honest BLOCKED row, never a fabricated split.
			if _gate("Jolt Physics", "backend_tier", "jolt"): return
			if _gate("Dummy", "backend_tier", "dummy"): return
			var tier_plain := _spawn_child("tierplainproj",
					_project_body("TierPlain", "", false),
					"tier_plain", false)
			if tier_plain.has("err"):
				return _fail(tier_plain["err"])
			var tier_jolt := _spawn_child("tierjoltproj",
					_project_body("TierJolt", "Jolt Physics", false),
					"tier_jolt", false)
			if tier_jolt.has("err"):
				return _fail(tier_jolt["err"])
			var tier_dummy := _spawn_child("tierdummyproj",
					_project_body("TierDummy", "Dummy", false),
					"tier_dummy", false)
			if tier_dummy.has("err"):
				return _fail(tier_dummy["err"])
			var expect_plain := {
				"plain_backend": "DEFAULT",
				"plain_dss_class": "GodotPhysicsDirectSpaceState3D",
				"plain_area_override": "honors",
				"plain_margin": "inert",
				"plain_sepray": "same-signature",
			}
			var expect_jolt := {
				"jolt_backend": "Jolt Physics",
				"jolt_dss_class": "JoltPhysicsDirectSpaceState3D",
				"jolt_area_override": "ignores",
				"jolt_margin": "binds",
				"jolt_sepray": "differs-constants",
			}
			var expect_dummy := {
				"dummy_backend": "Dummy",
				"dummy_dss_class": "PhysicsDirectSpaceState3DDummy",
				"dummy_area_override": "floor",
				"dummy_margin": "empty",
				"dummy_sepray": "floor",
			}
			for probe in [[tier_plain, expect_plain, "plain"],
					[tier_jolt, expect_jolt, "jolt"],
					[tier_dummy, expect_dummy, "dummy"]]:
				var spawn: Dictionary = probe[0]
				if spawn["code"] != 0 or spawn["serr"] \
						or spawn["verdicts"] != probe[1]:
					return _fail("backend_tier %s drift exit=%d serr=%s v=%s"
							% [probe[2], spawn["code"], str(spawn["serr"]),
							str(spawn["verdicts"])])
			_exit_ok("PASS phys3d_events backend_tier plain=honors jolt=ignores dummy=floor margin=inert,binds,empty sepray=same,differs,floor child_exit=0")

		"dummy_floor":
			# silent-floor cell (r86): the Dummy backend as a class, not a
			# failure. The dummy child pins the 11-token floor signature —
			# creates come back RID(0), reads come back Nil / 0.0 /
			# empty, a box shape reports type 2, and a direct state comes
			# back for ANY argument including RID(0) — and produces zero
			# rejected lines. The real-backend child runs the IDENTICAL
			# body and produces exactly two loud refusals on the same two
			# calls, so the floor can never be read as a refusal: the
			# Dummy backend answers where a real backend errors.
			if _gate("Dummy", "dummy_floor", "dummy"): return
			var floor_dummy := _spawn_child("floordummyproj",
					_project_body("FloorDummy", "Dummy", false),
					"floor_dummy", false)
			if floor_dummy.has("err"):
				return _fail(floor_dummy["err"])
			var floor_real := _spawn_child("floorrealproj",
					_project_body("FloorReal", "", false),
					"floor_real", false)
			if floor_real.has("err"):
				return _fail(floor_real["err"])
			if floor_dummy["code"] != 0 \
					or floor_dummy["verdicts"] != {"dummy_backend": "Dummy",
							"dummy_floor": "silent-floor"} \
					or not floor_dummy["errs"].is_empty():
				return _fail("dummy_floor dummy drift exit=%d v=%s errs=%s"
						% [floor_dummy["code"], str(floor_dummy["verdicts"]),
						str(floor_dummy["errs"])])
			var real_errs: Array = floor_real["errs"]
			if floor_real["code"] != 0 \
					or floor_real["verdicts"] != {"real_backend": "DEFAULT",
							"real_floor": "real-values"} \
					or real_errs.size() != 2 \
					or not str(real_errs[0]).begins_with(
							"ERROR: Parameter \"space\" is null.") \
					or not str(real_errs[1]).begins_with("ERROR: Invalid ID."):
				return _fail("dummy_floor real-backend refusal drift exit=%d v=%s errs=%s"
						% [floor_real["code"], str(floor_real["verdicts"]),
						str(real_errs)])
			_exit_ok("PASS phys3d_events dummy_floor dummy=silent-floor dummy_errs=0 real=real-values real_errs=2 child_exit=0")

		"body_handle":
			# held-handle identity law (r87): the object
			# `body_get_direct_state` returns is ONE per-body singleton live
			# handle — the SAME instance the engine hands
			# RigidBody3D._integrate_forces and
			# body_set_state_sync_callback — and it survives detach/reattach.
			# Three generated children, one sweep: a class difference can
			# never be a code difference. Dummy is the floor contrast (its
			# callbacks never fire and its fetch answers for ANY RID), and
			# the row is never a Dummy hazard detector (scout directive 8).
			if _gate("Jolt Physics", "body_handle", "jolt"): return
			if _gate("Dummy", "body_handle", "dummy"): return
			var bh_plain := _spawn_child("bhplainproj",
					_project_body("BhPlain", "", false), "bh_plain", false)
			if bh_plain.has("err"):
				return _fail(bh_plain["err"])
			var bh_jolt := _spawn_child("bhjoltproj",
					_project_body("BhJolt", "Jolt Physics", false),
					"bh_jolt", false)
			if bh_jolt.has("err"):
				return _fail(bh_jolt["err"])
			var bh_dummy := _spawn_child("bhdummyproj",
					_project_body("BhDummy", "Dummy", false), "bh_dummy", false)
			if bh_dummy.has("err"):
				return _fail(bh_dummy["err"])
			var expect_bh_plain := {
				"bh_plain_backend": "DEFAULT",
				"bh_plain_if_same": "true",
				"bh_plain_if_fired": ">0",
				"bh_plain_ss_same": "true",
				"bh_plain_ss_fired": ">0",
				"bh_plain_detach": "nil",
				"bh_plain_held_live": "true",
				"bh_plain_reattach": "true",
				"bh_plain_twin": "true",
			}
			var expect_bh_jolt := {
				"bh_jolt_backend": "Jolt Physics",
				"bh_jolt_if_same": "true",
				"bh_jolt_if_fired": ">0",
				"bh_jolt_ss_same": "true",
				"bh_jolt_ss_fired": ">0",
				"bh_jolt_detach": "nil",
				"bh_jolt_held_live": "true",
				"bh_jolt_reattach": "true",
				"bh_jolt_twin": "true",
			}
			# Dummy: no callback ever fires, and the fetch answers for a
			# detached RID too — the floor contrast, pinned as its own dict
			# rather than folded into the real-backend law.
			var expect_bh_dummy := {
				"bh_dummy_backend": "Dummy",
				"bh_dummy_if_same": "false",
				"bh_dummy_if_fired": "0",
				"bh_dummy_ss_same": "false",
				"bh_dummy_ss_fired": "0",
				"bh_dummy_detach": "obj",
				"bh_dummy_held_live": "true",
				"bh_dummy_reattach": "true",
				"bh_dummy_twin": "true",
			}
			for probe in [[bh_plain, expect_bh_plain, "plain"],
					[bh_jolt, expect_bh_jolt, "jolt"],
					[bh_dummy, expect_bh_dummy, "dummy"]]:
				var spawn: Dictionary = probe[0]
				if spawn["code"] != 0 or spawn["serr"] \
						or spawn["verdicts"] != probe[1]:
					return _fail("body_handle %s drift exit=%d serr=%s v=%s"
							% [probe[2], spawn["code"], str(spawn["serr"]),
							str(spawn["verdicts"])])
			_exit_ok("PASS phys3d_events body_handle if_same=true ss_same=true detach=nil held_live=true reattach=true twin=true dummy_cb=never child_exit=0")

		"acq_use":
			# acquisition-vs-use split (r87): under
			# run_on_separate_thread the FETCH is gated (a fresh
			# body_get_direct_state at a process-frame position returns a
			# null-Object Variant and the engine prints "Body state is
			# inaccessible right now"), but a handle obtained ONCE at a
			# legal position reads live and its writes land at every later
			# position — the gate controls ACQUISITION, not USE. The gate
			# witness is also the threading witness: a child whose
			# run_on_separate_thread key was silently ignored would grant
			# every fetch and fail this row loudly instead of reprinting the
			# unthreaded map.
			if _gate("Jolt Physics", "acq_use", "jolt"): return
			var au_allow := ["Body state is inaccessible"]
			var au_plain := _spawn_child("auplainproj",
					_project_body("AuPlain", "", true), "au_plain", false,
					"res://phys3d_events.gd", 30, au_allow)
			if au_plain.has("err"):
				return _fail(au_plain["err"])
			var au_jolt := _spawn_child("aujoltproj",
					_project_body("AuJolt", "Jolt Physics", true),
					"au_jolt", false, "res://phys3d_events.gd", 30, au_allow)
			if au_jolt.has("err"):
				return _fail(au_jolt["err"])
			for probe in [[au_plain, "DEFAULT", "plain"],
					[au_jolt, "Jolt Physics", "jolt"]]:
				var spawn: Dictionary = probe[0]
				var want := {
					"au_%s_backend" % probe[2]: probe[1],
					"au_%s_gate" % probe[2]: "refused",
					"au_%s_use" % probe[2]: "ungated",
					"au_%s_out_of_phase" % probe[2]: str(BODY_REPS),
				}
				if spawn["code"] != 0 or spawn["serr"] \
						or spawn["verdicts"] != want:
					return _fail("acq_use %s drift exit=%d serr=%s v=%s errs=%s"
							% [probe[2], spawn["code"], str(spawn["serr"]),
							str(spawn["verdicts"]), str(spawn["errs"])])
			# r87 critic F3: allow_lines forgives the class; the count is
			# the conjunct. Each refused fresh fetch prints one engine
			# ERROR — == BODY_REPS in the raw log, so a silently-nil
			# fetch (the scout's class-3 shape) can never pass as a
			# gated refusal.
			for dirname in ["auplainproj", "aujoltproj"]:
				var refusals := _log_count(ProjectSettings.globalize_path(
						"res://%s/child.log" % dirname),
						"Body state is inaccessible")
				if refusals != BODY_REPS:
					return _fail("acq_use %s refusal lines=%d expected=%d"
							% [dirname, refusals, BODY_REPS])
			_exit_ok("PASS phys3d_events acq_use gate=refused out_of_phase=8 held_read=live write=ungated reps=8 child_exit=0")

		"step_stamp":
			# step-stamped getters (r87): the body-state object has its own
			# internal flush seams. `get_step` reads a backend INIT CONSTANT
			# before the first solve completes (0.0010000000475 on
			# GodotPhysics, 0.0 on Jolt) and the real dt (0.0166666675359)
			# after it; `get_total_gravity`/`get_total_linear_damp` are
			# step-stamped on GodotPhysics ONLY — Jolt reports the real
			# values before the first solve, which is a backend split INSIDE
			# the step-stamped class (the r87-scout-dss summary generalised
			# the GodotPhysics behaviour; its own ph_proj_jolt receipt shows
			# the split). The contact buffer is the one snapshot-semantics
			# field (last-step data) and reports nothing at all until
			# body_set_max_contacts_reported opts the body in.
			if _gate("Jolt Physics", "step_stamp", "jolt"): return
			var ss_plain := _spawn_child("ssplainproj",
					_project_body("SsPlain", "", false), "ss_plain", false)
			if ss_plain.has("err"):
				return _fail(ss_plain["err"])
			var ss_jolt := _spawn_child("ssjoltproj",
					_project_body("SsJolt", "Jolt Physics", false),
					"ss_jolt", false)
			if ss_jolt.has("err"):
				return _fail(ss_jolt["err"])
			var expect_ss_plain := {
				"ss_plain_backend": "DEFAULT",
				"ss_plain_step_pre": "0.0010000000475",
				"ss_plain_grav_pre": "zero",
				"ss_plain_damp_pre": "0.0",
				"ss_plain_step_post": "0.0166666675359",
				"ss_plain_damp_post": "0.10000000149012",
				"ss_plain_cc_off": "0",
				"ss_plain_cc_on": "4",
				"ss_plain_last_step": "4,0",
			}
			var expect_ss_jolt := {
				"ss_jolt_backend": "Jolt Physics",
				"ss_jolt_step_pre": "0.0",
				"ss_jolt_grav_pre": "real",
				"ss_jolt_damp_pre": "0.10000000149012",
				"ss_jolt_step_post": "0.0166666675359",
				"ss_jolt_damp_post": "0.10000000149012",
				"ss_jolt_cc_off": "0",
				"ss_jolt_cc_on": "4",
				"ss_jolt_last_step": "4,0",
			}
			for probe in [[ss_plain, expect_ss_plain, "plain"],
					[ss_jolt, expect_ss_jolt, "jolt"]]:
				var spawn: Dictionary = probe[0]
				if spawn["code"] != 0 or spawn["serr"] \
						or spawn["verdicts"] != probe[1]:
					return _fail("step_stamp %s drift exit=%d serr=%s v=%s"
							% [probe[2], spawn["code"], str(spawn["serr"]),
							str(spawn["verdicts"])])
			_exit_ok("PASS phys3d_events step_stamp gp_step_pre=0.001 gp_grav_pre=zero jolt_step_pre=0.0 jolt_grav_pre=real step_post=0.016667 cc_off=0 cc_on=4 last_step=4,0 child_exit=0")

		"write_loss":
			# out-of-phase write-loss race (r87): a held-handle write issued
			# out of phase is ungated and UNSYNCHRONIZED — nothing orders it
			# against the physics thread, so a lost update is possible in
			# principle. This row is the bounded repeated-observation form
			# the class demands: BODY_REPS reps, each asserting the
			# deterministic witnesses (the fresh fetch refused at every rep,
			# the write applied and same-turn visible at every rep, the
			# tally accounted) while the per-rep split stays EVIDENCE, not a
			# gate. The r87-scout-dss `fl_proj_thr` r1 loss was NOT
			# reproduced by this form (0 lost across 13 author child runs
			# and 4 landed/lost forms), so the row pins the precondition plus
			# the accounted tally and reports the split in the child log —
			# it never claims a loss it did not witness.
			var wl_allow := ["Body state is inaccessible"]
			var wl := _spawn_child("wlproj",
					_project_body("WlProj", "", true), "wl_plain", false,
					"res://phys3d_events.gd", 30, wl_allow)
			if wl.has("err"):
				return _fail(wl["err"])
			var wl_v: Dictionary = wl["verdicts"]
			var wl_landed := int(wl_v.get("wl_plain_landed", "-1"))
			var wl_lost := int(wl_v.get("wl_plain_lost", "-1"))
			var wl_ok: bool = wl["code"] == 0 and not wl["serr"] \
					and wl_v.get("wl_plain_backend") == "DEFAULT" \
					and wl_v.get("wl_plain_gate") == "refused" \
					and int(wl_v.get("wl_plain_same_turn", "-1")) == BODY_REPS \
					and wl_landed >= 1 and wl_landed + wl_lost == BODY_REPS
			if not wl_ok:
				return _fail("write_loss drift exit=%d v=%s errs=%s"
						% [wl["code"], str(wl_v), str(wl["errs"])])
			# r87 critic F3: the refusal count is the corroborating
			# conjunct — == BODY_REPS engine ERROR lines in the raw log.
			var wl_refusals := _log_count(ProjectSettings.globalize_path(
					"res://wlproj/child.log"),
					"Body state is inaccessible")
			if wl_refusals != BODY_REPS:
				return _fail("write_loss refusal lines=%d expected=%d"
						% [wl_refusals, BODY_REPS])
			_exit_ok("PASS phys3d_events write_loss gate=refused reps=8 same_turn=8 race=bounded child_exit=0")

		"body_tier":
			# backend split at the body tier (r87): three generated children,
			# one sweep. GodotPhysics reads the FIRST in-contact step's
			# get_contact_impulse(0) as exactly zero while Jolt reads the real
			# impact impulse (the impulse cell is pinned at that step in the
			# scout geometry — on GodotPhysics the same field oscillates
			# through zero at later steps, so "GP is always zero" is a
			# sampling artifact and is NOT claimed); the out-of-range
			# contact_local_shape reads -1 vs 0; set_sleep_state(true) keeps
			# the velocity on GodotPhysics and zeroes it on Jolt; and the
			# detached-body impulse write is a silent no-op on GodotPhysics
			# and a LOUD Jolt refusal, corroborated by the engine's own line
			# count in the raw child log. Dummy is the silent floor.
			if _gate("Jolt Physics", "body_tier", "jolt"): return
			if _gate("Dummy", "body_tier", "dummy"): return
			var bt_allow := ["Index p_contact_idx",
					"Failed to apply central impulse"]
			var bt_plain := _spawn_child("btplainproj",
					_project_body("BtPlain", "", false), "bt_plain", false,
					"res://phys3d_events.gd", 30, bt_allow)
			if bt_plain.has("err"):
				return _fail(bt_plain["err"])
			var bt_jolt := _spawn_child("btjoltproj",
					_project_body("BtJolt", "Jolt Physics", false),
					"bt_jolt", false, "res://phys3d_events.gd", 30, bt_allow)
			if bt_jolt.has("err"):
				return _fail(bt_jolt["err"])
			var bt_dummy := _spawn_child("btdummyproj",
					_project_body("BtDummy", "Dummy", false), "bt_dummy", false,
					"res://phys3d_events.gd", 30, bt_allow)
			if bt_dummy.has("err"):
				return _fail(bt_dummy["err"])
			var expect_bt_plain := {
				"bt_plain_backend": "DEFAULT",
				"bt_plain_cc": "4",
				"bt_plain_impulse": "zero",
				"bt_plain_lshape_oob": "-1",
				"bt_plain_sleep_lv": "kept",
			}
			var expect_bt_jolt := {
				"bt_jolt_backend": "Jolt Physics",
				"bt_jolt_cc": "4",
				"bt_jolt_impulse": "real",
				"bt_jolt_lshape_oob": "0",
				"bt_jolt_sleep_lv": "zeroed",
			}
			var expect_bt_dummy := {
				"bt_dummy_backend": "Dummy",
				"bt_dummy_cc": "0",
				"bt_dummy_impulse": "nil",
				"bt_dummy_lshape_oob": "absent",
				"bt_dummy_sleep_lv": "flat",
			}
			for probe in [[bt_plain, expect_bt_plain, "plain"],
					[bt_jolt, expect_bt_jolt, "jolt"],
					[bt_dummy, expect_bt_dummy, "dummy"]]:
				var spawn: Dictionary = probe[0]
				if spawn["code"] != 0 or spawn["serr"] \
						or spawn["verdicts"] != probe[1]:
					return _fail("body_tier %s drift exit=%d serr=%s v=%s"
							% [probe[2], spawn["code"], str(spawn["serr"]),
							str(spawn["verdicts"])])
			# the detached-impulse refusal is a LOG witness, never a child
			# self-report: 0 lines on GodotPhysics (silent no-op), exactly 1
			# on Jolt, 0 under Dummy.
			var loud := [
				["btplainproj", 0], ["btjoltproj", 1], ["btdummyproj", 0],
			]
			for spec in loud:
				var n := _log_count(ProjectSettings.globalize_path(
						"res://%s/child.log" % spec[0]),
						"Failed to apply central impulse")
				if n != spec[1]:
					return _fail("body_tier %s detached-impulse refusal count=%d expected=%d"
							% [spec[0], n, spec[1]])
			_exit_ok("PASS phys3d_events body_tier gp_impulse=zero jolt_impulse=real gp_lshape=-1 jolt_lshape=0 gp_sleep_lv=kept jolt_sleep_lv=zeroed dummy_cc=0 detach_write=silent,loud,silent child_exit=0")

		"freed_space":
			# freed-space crash class (r87, FATAL TAIL): the ONE crash
			# surface at this tier is not the body handle but the space
			# handle reached THROUGH it — reaching the space-state object
			# on a freed space kills the process. The crash SITE is
			# backend-specific on this host (r87 critic F2): GodotPhysics
			# dies inside held.get_space_state() itself (the `space=` note
			# never prints), while Jolt's get_space_state() returns the
			# object and the kill is at intersect_ray. GodotPhysics reports
			# signal 11 and then aborts
			# through its own handler; Jolt's crash mode is heap-layout
			# dependent (uncaught std::system_error OR the same signal-11
			# handler); Dummy returns an empty dict and exits 0. The pinned
			# class is one crash line in the raw child log plus the
			# breadcrumb prefix at that backend's site plus the
			# absence of any child marker; the rc is the handler's exit
			# PATH, not the class (GodotPhysics lands 134 in ~1.5 s when the
			# handler completes and 137 when a bound cuts a load-slowed
			# handler short), so both signal-class rcs are accepted and the
			# marker carries the class. Freed-BODY handles are benign
			# (silent nulls) — this is the freed-SPACE cell only.
			if _gate("Jolt Physics", "freed_space", "jolt"): return
			if _gate("Dummy", "freed_space", "dummy"): return
			var fs_plain := _spawn_child("fsplainproj",
					_project_body("FsPlain", "", false), "fs_plain", false,
					"res://phys3d_events.gd", CRASH_BOUND_S)
			if fs_plain.has("err"):
				return _fail(fs_plain["err"])
			var fs_jolt := _spawn_child("fsjoltproj",
					_project_body("FsJolt", "Jolt Physics", false),
					"fs_jolt", false, "res://phys3d_events.gd", CRASH_BOUND_S)
			if fs_jolt.has("err"):
				return _fail(fs_jolt["err"])
			var fs_dummy := _spawn_child("fsdummyproj",
					_project_body("FsDummy", "Dummy", false), "fs_dummy", false,
					"res://phys3d_events.gd", CRASH_BOUND_S)
			if fs_dummy.has("err"):
				return _fail(fs_dummy["err"])
			# a crashing child can leave no marker at all: verdicts must be
			# empty and the rc must be a signal-class exit (134 SIGABRT when
			# the handler finishes, 137 when the bound kills the hung
			# handler). The crash is corroborated by the child's own
			# breadcrumb PREFIX in the raw log at the backend-specific site
			# (r87 critic F1/F2): a bare printed crash line is forgeable —
			# the row requires the full envelope instead. On GodotPhysics
			# the crash fires INSIDE held.get_space_state(), so the log
			# ends at the `held=` note (no `space=` line); on Jolt the
			# space-state object returns and the crash is at
			# intersect_ray, so `space=` prints but `ray` never does.
			var fs_gp_log := ProjectSettings.globalize_path(
					"res://fsplainproj/child.log")
			var fs_gp_line := _log_count(fs_gp_log,
					"handle_crash: Program crashed with signal 11")
			if fs_plain["code"] != 134 and fs_plain["code"] != 137:
				return _fail("freed_space plain rc=%d not signal-class"
						% fs_plain["code"])
			if not fs_plain["verdicts"].is_empty() or fs_gp_line != 1:
				return _fail("freed_space plain marker=%s crash_lines=%d"
						% [str(fs_plain["verdicts"]), fs_gp_line])
			if _log_count(fs_gp_log, "CHILD_NOTE fs_plain held=") != 1 \
					or _log_count(fs_gp_log, "held=nil") != 0 \
					or _log_count(fs_gp_log,
							"CHILD_NOTE fs_plain space=") != 0:
				return _fail("freed_space plain crash-site envelope drift")

			# Jolt's crash MODE is heap-layout dependent, not fixed: the freed
			# space's memory is either still shaped enough like a live Jolt
			# system that the internal check fires and the uncaught throw
			# aborts, or it is not and the query dereferences it into
			# Godot's own SIGSEGV handler. The author measured BOTH modes on
			# this host (the r87-scout-dss probe script: std::system_error
			# 3/3; this fixture's larger child: signal 11 3/3). The row pins
			# the class — hard crash, no marker, exactly one engine crash
			# line, signal-class rc — and records which mode the run took,
			# never one mode as the law.
			var fs_jolt_log := ProjectSettings.globalize_path(
					"res://fsjoltproj/child.log")
			var fs_throw := _log_count(fs_jolt_log, "std::system_error")
			var fs_segv := _log_count(fs_jolt_log,
					"handle_crash: Program crashed with signal 11")
			if fs_jolt["code"] != 134 and fs_jolt["code"] != 137:
				return _fail("freed_space jolt rc=%d not signal-class"
						% fs_jolt["code"])
			if not fs_jolt["verdicts"].is_empty() \
					or fs_throw + fs_segv != 1:
				return _fail("freed_space jolt marker=%s throw=%d segv=%d"
						% [str(fs_jolt["verdicts"]), fs_throw, fs_segv])
			# Jolt site pin (r87 critic F2): get_space_state() returns the
			# object here, so `space=` prints; the crash is at
			# intersect_ray, so `ray_empty`/`ray` never appear.
			if _log_count(fs_jolt_log, "CHILD_NOTE fs_jolt held=") != 1 \
					or _log_count(fs_jolt_log, "held=nil") != 0 \
					or _log_count(fs_jolt_log,
							"CHILD_NOTE fs_jolt space=") != 1 \
					or _log_count(fs_jolt_log,
							"CHILD_NOTE fs_jolt ray") != 0:
				return _fail("freed_space jolt crash-site envelope drift")
			if fs_dummy["code"] != 0 or fs_dummy["serr"] \
					or fs_dummy["verdicts"] != {"fs_dummy_ray": "empty"}:
				return _fail("freed_space dummy drift exit=%d serr=%s v=%s"
						% [fs_dummy["code"], str(fs_dummy["serr"]),
						str(fs_dummy["verdicts"])])
			_exit_ok("PASS phys3d_events freed_space gp=crash jolt=crash dummy=empty child_exit=0")

		"motion_split":
			# r88: the read family's motion semantics. ONE params object per
			# geometry, four methods — cast_motion applies motion, the other
			# three ignore it — and the wall-contact bracket is a per-backend
			# envelope (never a cross-backend equality).
			if _gate("Jolt Physics", "motion_split", "jolt"): return
			if _gate("Dummy", "motion_split", "dummy"): return
			var mo_plain := _spawn_child("moplainproj",
					_project_body("MoPlain", "", false), "mo_plain", false)
			if mo_plain.has("err"):
				return _fail(mo_plain["err"])
			var mo_jolt := _spawn_child("mojoltproj",
					_project_body("MoJolt", "Jolt Physics", false),
					"mo_jolt", false)
			if mo_jolt.has("err"):
				return _fail(mo_jolt["err"])
			var mo_dummy := _spawn_child("modummyproj",
					_project_body("MoDummy", "Dummy", false), "mo_dummy", false)
			if mo_dummy.has("err"):
				return _fail(mo_dummy["err"])
			var expect_mo_plain := {
				"mo_plain_backend": "DEFAULT",
				"mo_plain_cm": "honored",
				"mo_plain_cm_bracket": "wide",
				"mo_plain_cm_pen": "same",
				"mo_plain_cm_shared": "honored",
				"mo_plain_cm_away": "miss",
				"mo_plain_cm_zero": "blocked",
				"mo_plain_cm_short": "blocked",
				"mo_plain_cs": "ignored",
				"mo_plain_ri": "ignored",
				"mo_plain_is": "ignored",
			}
			var expect_mo_jolt := {
				"mo_jolt_backend": "Jolt Physics",
				"mo_jolt_cm": "honored",
				"mo_jolt_cm_bracket": "tight",
				"mo_jolt_cm_pen": "same",
				"mo_jolt_cm_shared": "honored",
				"mo_jolt_cm_away": "miss",
				"mo_jolt_cm_zero": "blocked",
				"mo_jolt_cm_short": "blocked",
				"mo_jolt_cs": "ignored",
				"mo_jolt_ri": "ignored",
				"mo_jolt_is": "ignored",
			}
			var expect_mo_dummy := {
				"mo_dummy_backend": "Dummy",
				"mo_dummy_cm": "empty",
				"mo_dummy_cm_bracket": "drift",
				"mo_dummy_cm_pen": "empty",
				"mo_dummy_cm_shared": "empty",
				"mo_dummy_cm_away": "empty",
				"mo_dummy_cm_zero": "empty",
				"mo_dummy_cm_short": "empty",
				"mo_dummy_cs": "floor",
				"mo_dummy_ri": "floor",
				"mo_dummy_is": "floor",
			}
			for probe in [[mo_plain, expect_mo_plain, "plain"],
					[mo_jolt, expect_mo_jolt, "jolt"],
					[mo_dummy, expect_mo_dummy, "dummy"]]:
				var spawn: Dictionary = probe[0]
				if spawn["code"] != 0 or spawn["serr"] \
						or spawn["verdicts"] != probe[1]:
					return _fail("motion_split %s drift exit=%d serr=%s v=%s errs=%s"
							% [probe[2], spawn["code"], str(spawn["serr"]),
							str(spawn["verdicts"]), str(spawn["errs"])])
			_exit_ok("PASS phys3d_events motion_split gp=wide jolt=tight dummy=floor split=cm_only child_exit=0")

		"fetch_gate":
			# r88: the access gate lattice. Three acquisition paths per
			# sample, so a threaded refusal is counted per path in the raw
			# log; the held-handle bypass hands out the SAME dss object at
			# refused positions.
			if _gate("Jolt Physics", "fetch_gate", "jolt"): return
			if _gate("Dummy", "fetch_gate", "dummy"): return
			var fg_allow := ["Space state is inaccessible",
					"Body state is inaccessible",
					# the Jolt+thread bypass query can print this engine
					# error and still answer (a race observable, recorded
					# in the child log; never a pinned count)
					"must not be called while the physics space is being stepped"]
			var fg_plain := _spawn_child("fgplainproj",
					_project_body("FgPlain", "", false), "fg_plain", false,
					"res://phys3d_events.gd", 30, fg_allow)
			if fg_plain.has("err"):
				return _fail(fg_plain["err"])
			var fg_thr := _spawn_child("fgthrproj",
					_project_body("FgThr", "", true), "fg_thr", false,
					"res://phys3d_events.gd", 30, fg_allow)
			if fg_thr.has("err"):
				return _fail(fg_thr["err"])
			var fg_jolt_thr := _spawn_child("fgjoltthrproj",
					_project_body("FgJoltThr", "Jolt Physics", true),
					"fg_jolt_thr", false, "res://phys3d_events.gd", 30, fg_allow)
			if fg_jolt_thr.has("err"):
				return _fail(fg_jolt_thr["err"])
			var fg_dummy := _spawn_child("fgdummyproj",
					_project_body("FgDummy", "Dummy", false), "fg_dummy", false,
					"res://phys3d_events.gd", 30, fg_allow)
			if fg_dummy.has("err"):
				return _fail(fg_dummy["err"])
			var fg_dummy_thr := _spawn_child("fgdummythrproj",
					_project_body("FgDummyThr", "Dummy", true),
					"fg_dummy_thr", false, "res://phys3d_events.gd", 30, fg_allow)
			if fg_dummy_thr.has("err"):
				return _fail(fg_dummy_thr["err"])
			# A (in _initialize), B, C, D, E + GATE_F_REPS out-of-phase firings
			var fg_samples := 5 + GATE_F_REPS
			var expect_fg_plain := {
				"fg_plain_backend": "DEFAULT",
				"fg_plain_samples": str(fg_samples),
				"fg_plain_grant": str(fg_samples),
				"fg_plain_refuse": "0",
				"fg_plain_partial": "0",
				"fg_plain_gate": "open",
				"fg_plain_byp": "5/5",
				"fg_plain_byp_same": "5/5",
			}
			var expect_fg_thr := {
				"fg_thr_backend": "DEFAULT",
				"fg_thr_samples": str(fg_samples),
				"fg_thr_grant": "2",
				"fg_thr_refuse": "6",
				"fg_thr_partial": "0",
				"fg_thr_gate": "phase",
				"fg_thr_byp": "5/5",
				"fg_thr_byp_same": "5/5",
			}
			var expect_fg_jolt_thr := {
				"fg_jolt_thr_backend": "Jolt Physics",
				"fg_jolt_thr_samples": str(fg_samples),
				"fg_jolt_thr_grant": "2",
				"fg_jolt_thr_refuse": "6",
				"fg_jolt_thr_partial": "0",
				"fg_jolt_thr_gate": "phase",
				"fg_jolt_thr_byp": "5/5",
				"fg_jolt_thr_byp_same": "5/5",
			}
			var expect_fg_dummy := {
				"fg_dummy_backend": "Dummy",
				"fg_dummy_samples": str(fg_samples),
				"fg_dummy_grant": str(fg_samples),
				"fg_dummy_refuse": "0",
				"fg_dummy_partial": "0",
				"fg_dummy_gate": "open",
				"fg_dummy_byp": "5/5",
				"fg_dummy_byp_same": "5/5",
			}
			var expect_fg_dummy_thr := {
				"fg_dummy_thr_backend": "Dummy",
				"fg_dummy_thr_samples": str(fg_samples),
				"fg_dummy_thr_grant": str(fg_samples),
				"fg_dummy_thr_refuse": "0",
				"fg_dummy_thr_partial": "0",
				"fg_dummy_thr_gate": "open",
				"fg_dummy_thr_byp": "5/5",
				"fg_dummy_thr_byp_same": "5/5",
			}
			for probe in [[fg_plain, expect_fg_plain, "plain"],
					[fg_thr, expect_fg_thr, "thr"],
					[fg_jolt_thr, expect_fg_jolt_thr, "jolt_thr"],
					[fg_dummy, expect_fg_dummy, "dummy"],
					[fg_dummy_thr, expect_fg_dummy_thr, "dummy_thr"]]:
				var spawn: Dictionary = probe[0]
				if spawn["code"] != 0 or spawn["serr"] \
						or spawn["verdicts"] != probe[1]:
					return _fail("fetch_gate %s drift exit=%d serr=%s v=%s errs=%s"
							% [probe[2], spawn["code"], str(spawn["serr"]),
							str(spawn["verdicts"]), str(spawn["errs"])])
			# the refusal counts are the log conjunct: one ERROR per
			# acquisition path per refused sample (2 space paths + 1 body
			# path), so a silently-nil fetch can never pass as a refusal.
			for probe in [["fgthrproj", 6], ["fgjoltthrproj", 6]]:
				var logp := ProjectSettings.globalize_path(
						"res://%s/child.log" % probe[0])
				if _log_count(logp, "Space state is inaccessible") \
						!= 2 * int(probe[1]) \
						or _log_count(logp, "Body state is inaccessible") \
						!= int(probe[1]):
					return _fail("fetch_gate %s refusal lines=%d/%d expected=%d/%d"
							% [probe[0],
							_log_count(logp, "Space state is inaccessible"),
							_log_count(logp, "Body state is inaccessible"),
							2 * int(probe[1]), int(probe[1])])
			for dirname in ["fgplainproj", "fgdummyproj", "fgdummythrproj"]:
				var logp := ProjectSettings.globalize_path(
						"res://%s/child.log" % dirname)
				if _log_count(logp, "Space state is inaccessible") != 0:
					return _fail("fetch_gate %s unexpected refusal" % dirname)
			# C6 witness: every bypass sample's emitted id pair must be the
			# SAME id twice — a truthy regression can't mint the pair.
			for dirname in ["fgplainproj", "fgthrproj", "fgjoltthrproj",
					"fgdummyproj", "fgdummythrproj"]:
				var logp2 := ProjectSettings.globalize_path(
						"res://%s/child.log" % dirname)
				var pairs := _log_idpair_equal_count(logp2,
						"CHILD_NOTE byp_ids ")
				if pairs != 5:
					return _fail("fetch_gate %s byp_ids pairs=%d (want 5)"
							% [dirname, pairs])
			_exit_ok("PASS phys3d_events fetch_gate plain=open thr=phase jolt_thr=phase dummy=open byp=held_same child_exit=0")

		"inactive_space":
			# r88: the gate keys on the step cycle, not on activation.
			if _gate("Jolt Physics", "inactive_space", "jolt"): return
			var ia_plain := _spawn_child("iaplainproj",
					_project_body("IaPlain", "", false), "ia_plain", false)
			if ia_plain.has("err"):
				return _fail(ia_plain["err"])
			var ia_allow := ["Space state is inaccessible",
					"must not be called while the physics space is being stepped"]
			var ia_thr := _spawn_child("iathrproj",
					_project_body("IaThr", "", true), "ia_thr", false,
					"res://phys3d_events.gd", 30, ia_allow)
			if ia_thr.has("err"):
				return _fail(ia_thr["err"])
			var ia_jolt_thr := _spawn_child("iajoltthrproj",
					_project_body("IaJoltThr", "Jolt Physics", true),
					"ia_jolt_thr", false, "res://phys3d_events.gd", 30,
					ia_allow)
			if ia_jolt_thr.has("err"):
				return _fail(ia_jolt_thr["err"])
			var ia_sig := "pt1,is1,ray7,cs0,cmfrac,ri0,rv6"
			var expect_ia_plain := {
				"ia_plain_backend": "DEFAULT",
				"ia_plain_samples": "5",
				"ia_plain_open": "5",
				"ia_plain_refused": "0",
				"ia_plain_alts": "2/2",
				"ia_plain_f_bp": "1/1",
				"ia_plain_sig": ia_sig,
			}
			var expect_ia_thr := {
				"ia_thr_backend": "DEFAULT",
				"ia_thr_samples": "5",
				"ia_thr_open": "2",
				"ia_thr_refused": "3",
				"ia_thr_alts": "2/2",
				"ia_thr_f_bp": "1/1",
				"ia_thr_sig": ia_sig,
			}
			var expect_ia_jolt_thr := {
				"ia_jolt_thr_backend": "Jolt Physics",
				"ia_jolt_thr_samples": "5",
				"ia_jolt_thr_open": "2",
				"ia_jolt_thr_refused": "3",
				"ia_jolt_thr_alts": "2/2",
				"ia_jolt_thr_f_bp": "1/1",
				"ia_jolt_thr_sig": ia_sig,
			}
			for probe in [[ia_plain, expect_ia_plain, "plain"],
					[ia_thr, expect_ia_thr, "thr"],
					[ia_jolt_thr, expect_ia_jolt_thr, "jolt_thr"]]:
				var spawn: Dictionary = probe[0]
				if spawn["code"] != 0 or spawn["serr"] \
						or spawn["verdicts"] != probe[1]:
					return _fail("inactive_space %s drift exit=%d serr=%s v=%s errs=%s"
							% [probe[2], spawn["code"], str(spawn["serr"]),
							str(spawn["verdicts"]), str(spawn["errs"])])
			for dirname in ["iathrproj", "iajoltthrproj"]:
				var logp := ProjectSettings.globalize_path(
						"res://%s/child.log" % dirname)
				if _log_count(logp, "Space state is inaccessible") != 3:
					return _fail("inactive_space %s refusal lines=%d expected=3"
							% [dirname,
							_log_count(logp, "Space state is inaccessible")])
			if _log_count(ProjectSettings.globalize_path(
					"res://iaplainproj/child.log"),
					"Space state is inaccessible") != 0:
				return _fail("inactive_space plain unexpected refusal")
			_exit_ok("PASS phys3d_events inactive_space plain=open thr=phase jolt_thr=phase alts=answered sig=wall_only child_exit=0")

		"race_class":
			# r88: the threaded window as named classes with an ENVELOPE pin
			# (no class is required to appear; a value outside {empty, legal}
			# is the failure). The Jolt child's window can tear the Jolt
			# shape registry and abort — the row accepts the crash envelope
			# OR the completed envelope, each with its own witnesses.
			if _gate("Jolt Physics", "race_class", "jolt"): return
			var rc_allow := ["Space state is inaccessible",
					"must not be called while the physics space is being stepped"]
			var rc_plain := _spawn_child("rcplainproj",
					_project_body("RcPlain", "", true), "rc_plain", false,
					"res://phys3d_events.gd", 30, rc_allow)
			if rc_plain.has("err"):
				return _fail(rc_plain["err"])
			var rc_jolt := _spawn_child("rcjoltproj",
					_project_body("RcJolt", "Jolt Physics", true),
					"rc_jolt", false, "res://phys3d_events.gd", 30, rc_allow)
			if rc_jolt.has("err"):
				return _fail(rc_jolt["err"])
			var expect_rc_plain := {
				"rc_plain_backend": "DEFAULT",
				"rc_plain_e_legal": "6",
				"rc_plain_f": str(RACE_REPS),
				"rc_plain_refused": str(RACE_REPS),
				"rc_plain_envelope": "ok",
			}
			if rc_plain["code"] != 0 or rc_plain["serr"] \
					or rc_plain["verdicts"] != expect_rc_plain:
				return _fail("race_class plain drift exit=%d serr=%s v=%s errs=%s"
						% [rc_plain["code"], str(rc_plain["serr"]),
						str(rc_plain["verdicts"]), str(rc_plain["errs"])])
			var rc_plain_log := ProjectSettings.globalize_path(
					"res://rcplainproj/child.log")
			if _log_count(rc_plain_log, "Space state is inaccessible") \
					!= RACE_REPS:
				return _fail("race_class plain refusal lines=%d expected=%d"
						% [_log_count(rc_plain_log,
						"Space state is inaccessible"), RACE_REPS])
			# the Jolt child: completed envelope OR the crash class
			var rc_jolt_log := ProjectSettings.globalize_path(
					"res://rcjoltproj/child.log")
			var rc_tear := _log_count(rc_jolt_log,
					"Failed to build Jolt Physics sphere shape")
			var rc_abort := _log_count(rc_jolt_log, "pure virtual method called") \
					+ _log_count(rc_jolt_log,
					"terminate called without an active exception")
			if rc_jolt["code"] == 134 or rc_jolt["code"] == 137:
				# the crash mode is heap-layout dependent (r87's freed_space
				# split): the uncaught C++ exception path aborts through
				# `terminate` with NO Godot signal handler, while the other
				# mode lands in `handle_crash`. Both carry the tear line and
				# the abort line, and neither may leave a child marker.
				if not rc_jolt["verdicts"].is_empty() or rc_tear < 1 \
						or rc_abort < 1 \
						or _log_count(rc_jolt_log,
								"CHILD_NOTE rc_jolt stash=dss") != 1:
					return _fail("race_class jolt crash envelope drift rc=%d v=%s tear=%d abort=%d"
							% [rc_jolt["code"], str(rc_jolt["verdicts"]),
							rc_tear, rc_abort])
			elif rc_jolt["code"] == 0:
				# the completed branch: the same envelope as GodotPhysics,
				# with the Jolt tear lines admitted as the expected witness
				# class (the registry tears; the process survives and the
				# envelope holds). Any OTHER error line is a defect.
				var expect_rc_jolt := {
					"rc_jolt_backend": "Jolt Physics",
					"rc_jolt_e_legal": "6",
					"rc_jolt_f": str(RACE_REPS),
					"rc_jolt_refused": str(RACE_REPS),
					"rc_jolt_envelope": "ok",
				}
				var tear_only := true
				for line in rc_jolt["errs"]:
					if not ("Failed to build Jolt Physics sphere shape" in line
							or "Parameter \"jolt_shape\" is null." in line):
						tear_only = false
				if rc_jolt["verdicts"] != expect_rc_jolt or not tear_only:
					return _fail("race_class jolt envelope drift v=%s errs=%s"
							% [str(rc_jolt["verdicts"]),
							str(rc_jolt["errs"])])
			else:
				return _fail("race_class jolt rc=%d not crash-or-completed"
						% rc_jolt["code"])
			_exit_ok("PASS phys3d_events race_class gp=classes jolt=crash-or-classes reps=%d child_exit=0" % RACE_REPS)

		"param_purity":
			# r88: the params objects are pure input, shape_rid beats shape,
			# and repeated calls return fresh containers.
			if _gate("Jolt Physics", "param_purity", "jolt"): return
			if _gate("Dummy", "param_purity", "dummy"): return
			var pq_plain := _spawn_child("pqplainproj",
					_project_body("PqPlain", "", false), "pq_plain", false)
			if pq_plain.has("err"):
				return _fail(pq_plain["err"])
			var pq_jolt := _spawn_child("pqjoltproj",
					_project_body("PqJolt", "Jolt Physics", false),
					"pq_jolt", false)
			if pq_jolt.has("err"):
				return _fail(pq_jolt["err"])
			var pq_dummy := _spawn_child("pqdummyproj",
					_project_body("PqDummy", "Dummy", false), "pq_dummy", false)
			if pq_dummy.has("err"):
				return _fail(pq_dummy["err"])
			var expect_pq_plain := {
				"pq_plain_backend": "DEFAULT",
				"pq_plain_pure": "6/6",
				"pq_plain_prec": "1,0,1",
				"pq_plain_fresh": "3/3",
			}
			var expect_pq_jolt := {
				"pq_jolt_backend": "Jolt Physics",
				"pq_jolt_pure": "6/6",
				"pq_jolt_prec": "1,0,1",
				"pq_jolt_fresh": "3/3",
			}
			var expect_pq_dummy := {
				"pq_dummy_backend": "Dummy",
				"pq_dummy_pure": "6/6",
				"pq_dummy_prec": "0,0,0",
				"pq_dummy_fresh": "3/3",
			}
			for probe in [[pq_plain, expect_pq_plain, "plain"],
					[pq_jolt, expect_pq_jolt, "jolt"],
					[pq_dummy, expect_pq_dummy, "dummy"]]:
				var spawn: Dictionary = probe[0]
				if spawn["code"] != 0 or spawn["serr"] \
						or spawn["verdicts"] != probe[1]:
					return _fail("param_purity %s drift exit=%d serr=%s v=%s errs=%s"
							% [probe[2], spawn["code"], str(spawn["serr"]),
							str(spawn["verdicts"]), str(spawn["errs"])])
			_exit_ok("PASS phys3d_events param_purity pure=6/6 prec=rid fresh=3/3 child_exit=0")

		"body_inertia":
			# r88: the PhysicsDirectBodyState3D inertia getters as values.
			if _gate("Jolt Physics", "body_inertia", "jolt"): return
			if _gate("Dummy", "body_inertia", "dummy"): return
			var bi_plain := _spawn_child("biplainproj",
					_project_body("BiPlain", "", false), "bi_plain", false)
			if bi_plain.has("err"):
				return _fail(bi_plain["err"])
			var bi_jolt := _spawn_child("bijoltproj",
					_project_body("BiJolt", "Jolt Physics", false),
					"bi_jolt", false)
			if bi_jolt.has("err"):
				return _fail(bi_jolt["err"])
			var bi_dummy := _spawn_child("bidummyproj",
					_project_body("BiDummy", "Dummy", false), "bi_dummy", false)
			if bi_dummy.has("err"):
				return _fail(bi_dummy["err"])
			var bi_diag := "3.000000,0.000000,0.000000,0.000000,0.352941,0.000000,0.000000,0.000000,0.352941"
			var bi_y30 := "2.338235,0.000000,-1.146210,0.000000,0.352941,0.000000,-1.146210,0.000000,1.014706"
			var bi_ident := "1.000000,0.000000,0.000000,0.000000,1.000000,0.000000,0.000000,0.000000,1.000000"
			var bi_zero := "0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000"
			var expect_bi_plain := {
				"bi_plain_backend": "DEFAULT",
				"bi_plain_r_imass": "0.500000",
				"bi_plain_r_ii": "3.000000,0.352941,0.352941",
				"bi_plain_r_iit": bi_diag,
				"bi_plain_r_pax": bi_ident,
				"bi_plain_tensor": "world",
				"bi_plain_r_y30_iit": bi_y30,
				"bi_plain_r_y30_pax": "rot",
				"bi_plain_r_m4_imass": "0.250000",
				"bi_plain_r_m4_ii": "1.500000,0.176471,0.176471",
				"bi_plain_st": "0.000000/0.000000,0.000000,0.000000/" + bi_zero,
				"bi_plain_kn": "0.000000/0.000000,0.000000,0.000000/" + bi_zero,
				"bi_plain_iw": "1.000000/0.111111,0.250000,1.000000",
				"bi_plain_cb": "0.400000,0.000000,0.000000/6.000000,0.634250,0.634250",
			}
			var expect_bi_jolt := expect_bi_plain.duplicate()
			for k in expect_bi_plain.keys():
				if k.begins_with("bi_plain_"):
					expect_bi_jolt.erase(k)
			for k in expect_bi_plain.keys():
				if k.begins_with("bi_plain_"):
					expect_bi_jolt["bi_jolt_" + k.substr(9)] = expect_bi_plain[k]
			expect_bi_jolt["bi_jolt_backend"] = "Jolt Physics"
			# Jolt's principal-axes basis is magnitude-sorted, so even the
			# identity orientation comes back as a column permutation (the
			# r88-scout's y30 reading; measured here at identity too), and
			# its COM read-back carries a float error on the 0.4 write.
			expect_bi_jolt["bi_jolt_r_pax"] = "0.000000,1.000000,0.000000,0.000000,0.000000,1.000000,1.000000,0.000000,0.000000"
			expect_bi_jolt["bi_jolt_r_y30_pax"] = "perm"
			expect_bi_jolt["bi_jolt_st"] = "1.000000/0.000000,0.000000,0.000000/" + bi_ident
			expect_bi_jolt["bi_jolt_kn"] = "1.000000/0.000000,0.000000,0.000000/" + bi_ident
			expect_bi_jolt["bi_jolt_cb"] = "0.400002,0.000000,0.000000/6.000000,0.634249,0.634249"
			var expect_bi_dummy := {
				"bi_dummy_backend": "Dummy",
				"bi_dummy_r_imass": "0.000000",
				"bi_dummy_r_ii": "0.000000,0.000000,0.000000",
				"bi_dummy_r_iit": bi_ident,
				"bi_dummy_r_pax": bi_ident,
				"bi_dummy_tensor": "floor",
				"bi_dummy_r_y30_iit": bi_ident,
				"bi_dummy_r_y30_pax": "identity",
				"bi_dummy_r_m4_imass": "0.000000",
				"bi_dummy_r_m4_ii": "0.000000,0.000000,0.000000",
				"bi_dummy_st": "0.000000/0.000000,0.000000,0.000000/" + bi_ident,
				"bi_dummy_kn": "0.000000/0.000000,0.000000,0.000000/" + bi_ident,
				"bi_dummy_iw": "0.000000/0.000000,0.000000,0.000000",
				"bi_dummy_cb": "0.000000,0.000000,0.000000/0.000000,0.000000,0.000000",
			}
			for probe in [[bi_plain, expect_bi_plain, "plain"],
					[bi_jolt, expect_bi_jolt, "jolt"],
					[bi_dummy, expect_bi_dummy, "dummy"]]:
				var spawn: Dictionary = probe[0]
				if spawn["code"] != 0 or spawn["serr"] \
						or spawn["verdicts"] != probe[1]:
					return _fail("body_inertia %s drift exit=%d serr=%s v=%s errs=%s"
							% [probe[2], spawn["code"], str(spawn["serr"]),
							str(spawn["verdicts"]), str(spawn["errs"])])
			_exit_ok("PASS phys3d_events body_inertia gp=box jolt=box dummy=floor tensor=world st=zeros,placeholders child_exit=0")

		"wrong_args":
			# r88: the wrong-argument class — typed empties, rc=0, and the
			# refusal text counted from the raw log and equal across backends.
			if _gate("Jolt Physics", "wrong_args", "jolt"): return
			if _gate("Dummy", "wrong_args", "dummy"): return
			var wa_allow := ["Required object", "Parameter \"shape\" is null",
					"Condition \"p_size < 0\""]
			var wa_plain := _spawn_child("waplainproj",
					_project_body("WaPlain", "", false), "wa_plain", false,
					"res://phys3d_events.gd", 30, wa_allow)
			if wa_plain.has("err"):
				return _fail(wa_plain["err"])
			var wa_jolt := _spawn_child("wajoltproj",
					_project_body("WaJolt", "Jolt Physics", false),
					"wa_jolt", false, "res://phys3d_events.gd", 30, wa_allow)
			if wa_jolt.has("err"):
				return _fail(wa_jolt["err"])
			var wa_dummy := _spawn_child("wadummyproj",
					_project_body("WaDummy", "Dummy", false), "wa_dummy", false,
					"res://phys3d_events.gd", 30, wa_allow)
			if wa_dummy.has("err"):
				return _fail(wa_dummy["err"])
			var wa_cells := {
				"point_shapeparams": "t28,n0",
				"isect_pointparams": "t28,n0",
				"isect_rayparams": "t28,n0",
				"isect_null": "t28,n0",
				"cast_pointparams": "t32,n0",
				"collide_rayparams": "t28,n0",
				"rest_rayparams": "t27,n0",
				"isect_noshape": "t28,n0",
				"cast_noshape": "t32,n0",
				"rest_noshape": "t27,n0",
				"collide_maxres": "t28,n0",
				"isect_maxres0": "t28,n0",
				"point_maxres0": "t28,n0",
			}
			for probe in [[wa_plain, "plain", "DEFAULT"],
					[wa_jolt, "jolt", "Jolt Physics"],
					[wa_dummy, "dummy", "Dummy"]]:
				var spawn: Dictionary = probe[0]
				var want := {"wa_%s_backend" % probe[1]: probe[2]}
				for k in wa_cells:
					want["wa_%s_%s" % [probe[1], k]] = wa_cells[k]
				if spawn["code"] != 0 or spawn["serr"] \
						or spawn["verdicts"] != want:
					return _fail("wrong_args %s drift exit=%d serr=%s v=%s errs=%s"
							% [probe[1], spawn["code"], str(spawn["serr"]),
							str(spawn["verdicts"]), str(spawn["errs"])])
			# the refusal text is a log witness, counted per backend: the two
			# wrapper-layer strings are identical and identically counted on
			# all three backends; the shape-null line is the Dummy floor
			# split (absent there); the negative max_results condition is
			# identical everywhere.
			var wa_counts := []
			for dirname in ["waplainproj", "wajoltproj", "wadummyproj"]:
				var logp := ProjectSettings.globalize_path(
						"res://%s/child.log" % dirname)
				wa_counts.append([_log_count(logp,
						"Required object \"rp_shape_query\" is null."),
						_log_count(logp,
						"Required object \"rp_point_query\" is null."),
						_log_count(logp, "Parameter \"shape\" is null."),
						_log_count(logp,
						"Condition \"p_size < 0\" is true. Returning: ERR_INVALID_PARAMETER")])
			for i in range(1, 3):
				if wa_counts[i][0] != wa_counts[0][0] \
						or wa_counts[i][1] != wa_counts[0][1] \
						or wa_counts[i][3] != wa_counts[0][3]:
					return _fail("wrong_args refusal text drift counts=%s"
							% str(wa_counts))
			if wa_counts[0][0] != 6 or wa_counts[0][1] != 1 \
					or wa_counts[0][2] != 3 or wa_counts[0][3] != 1 \
					or wa_counts[1][2] != 3 or wa_counts[2][2] != 0:
				return _fail("wrong_args refusal counts=%s" % str(wa_counts))
			_exit_ok("PASS phys3d_events wrong_args cells=13 typed=empty rc=0 text=same,floor child_exit=0")

		"geom_split":
			# r88: the backend-geometry splits as per-backend envelopes.
			if _gate("Jolt Physics", "geom_split", "jolt"): return
			var gs_plain := _spawn_child("gsplainproj",
					_project_body("GsPlain", "", false), "gs_plain", false)
			if gs_plain.has("err"):
				return _fail(gs_plain["err"])
			var gs_jolt := _spawn_child("gsjoltproj",
					_project_body("GsJolt", "Jolt Physics", false),
					"gs_jolt", false)
			if gs_jolt.has("err"):
				return _fail(gs_jolt["err"])
			var expect_gs_plain := {
				"gs_plain_backend": "DEFAULT",
				"gs_plain_pt_boundary": "1",
				"gs_plain_pt_inside": "1",
				"gs_plain_cm": "frac",
				"gs_plain_normal": "tilt",
				"gs_plain_ri_n": "6",
				"gs_plain_ovp": "start",
				"gs_plain_cs": "2,neg",
			}
			var expect_gs_jolt := {
				"gs_jolt_backend": "Jolt Physics",
				"gs_jolt_pt_boundary": "2",
				"gs_jolt_pt_inside": "1",
				"gs_jolt_cm": "frac",
				"gs_jolt_normal": "up",
				"gs_jolt_ri_n": "6",
				"gs_jolt_ovp": "offset",
				"gs_jolt_cs": "2,neg",
			}
			for probe in [[gs_plain, expect_gs_plain, "plain"],
					[gs_jolt, expect_gs_jolt, "jolt"]]:
				var spawn: Dictionary = probe[0]
				if spawn["code"] != 0 or spawn["serr"] \
						or spawn["verdicts"] != probe[1]:
					return _fail("geom_split %s drift exit=%d serr=%s v=%s errs=%s"
							% [probe[2], spawn["code"], str(spawn["serr"]),
							str(spawn["verdicts"]), str(spawn["errs"])])
			_exit_ok("PASS phys3d_events geom_split gp=boundary1,wide,tilt jolt=boundary2,tight,up child_exit=0")

		"freed_space_methods":
			# r88, FATAL TAIL: the freed-space postcondition PER METHOD x
			# BACKEND. One child per method on the real backends (a crash
			# cannot be caught); the Dummy floor runs all six in one child.
			# The children are spawned as ONE parallel batch: each still
			# carries its own `timeout -s KILL` bound, and the batch's own
			# deadline is fail-closed.
			if _gate("Jolt Physics", "freed_space_methods", "jolt"): return
			if _gate("Dummy", "freed_space_methods", "dummy"): return
			var freed_allow := ["previously freed", "Parameter \"space\" is null",
					"has no owner", "were leaked at exit", "was leaked at exit"]
			var specs := []
			for m in FREED_METHODS:
				specs.append({
					"dirname": "fmplain" + m, "arm": "fm_plain_" + m,
					"project_body": _project_body("FmPlain" + m, "", false),
					"allow_lines": freed_allow, "bound_s": FREED_BOUND_S,
				})
			for m in FREED_METHODS:
				specs.append({
					"dirname": "fmjolt" + m, "arm": "fm_jolt_" + m,
					"project_body": _project_body("FmJolt" + m,
							"Jolt Physics", false),
					"allow_lines": freed_allow, "bound_s": FREED_BOUND_S,
				})
			specs.append({
				"dirname": "fmdummy", "arm": "fd_dummy",
				"project_body": _project_body("FmDummy", "Dummy", false),
				"allow_lines": freed_allow, "bound_s": FREED_BOUND_S,
			})
			var batch := _spawn_batch(specs)
			var jolt_crash := 0
			var jolt_dead := 0
			for i in range(FREED_METHODS.size()):
				var m: String = FREED_METHODS[i]
				var res: Dictionary = batch[i]
				if res.has("err") or res.get("batch_timeout", false):
					return _fail("freed_space_methods plain %s err=%s timeout=%s"
							% [m, str(res.get("err")), str(res.get("batch_timeout"))])
				var logp := ProjectSettings.globalize_path(
						"res://fmplain%s/child.log" % m)
				var crash := _log_count(logp,
						"handle_crash: Program crashed with signal 11")
				var pre := _log_count(logp, "previously freed")
				var sp_null := _log_count(logp,
						"Parameter \"space\" is null")
				if res["code"] != 134 and res["code"] != 137:
					return _fail("freed_space_methods plain %s rc=%d not signal-class"
							% [m, res["code"]])
				if not res["verdicts"].is_empty() or crash != 1 \
						or pre != 1 or sp_null != 1 \
						or not res["errs"].is_empty():
					return _fail("freed_space_methods plain %s envelope rc=%d marker=%s crash=%d pre=%d sp=%d errs=%s"
							% [m, res["code"], str(res["verdicts"]),
							crash, pre, sp_null, str(res["errs"])])
				if _log_count(logp,
						"Nonexistent function '%s' in base 'previously freed'"
						% FREED_METHOD_NAMES[m]) != 1:
					return _fail("freed_space_methods plain %s method-witness drift"
							% m)
				if _log_count(logp, "CHILD_NOTE fm_plain_%s alive=" % m) != 1 \
						or _log_count(logp, "CHILD_NOTE fm_plain_%s pre=" % m) != 1 \
						or _log_count(logp, "CHILD_NOTE fm_plain_%s refetch=" % m) != 1 \
						or _log_count(logp, "CHILD_NOTE fm_plain_%s post=" % m) != 0:
					return _fail("freed_space_methods plain %s breadcrumb drift"
							% m)
			for i in range(FREED_METHODS.size()):
				var m: String = FREED_METHODS[i]
				var res: Dictionary = batch[FREED_METHODS.size() + i]
				if res.has("err") or res.get("batch_timeout", false):
					return _fail("freed_space_methods jolt %s err=%s timeout=%s"
							% [m, str(res.get("err")), str(res.get("batch_timeout"))])
				var logp := ProjectSettings.globalize_path(
						"res://fmjolt%s/child.log" % m)
				var crash := _log_count(logp,
						"handle_crash: Program crashed with signal 11")
				# Jolt's abort modes: `pure virtual method called`,
				# `terminate called without an active exception`, and the
				# scout's `terminate called after throwing an instance of
				# 'std::system_error'` (measured in this arm) — one token
				# covers all three.
				var abort := _log_count(logp, "pure virtual method called") \
						+ _log_count(logp, "terminate called")
				var pre := _log_count(logp, "previously freed")
				var sp_null := _log_count(logp,
						"Parameter \"space\" is null")
				# the two class witnesses are unconditional: the stashed
				# handle's call raises the previously-freed SCRIPT ERROR and
				# the freed-space refetch names the null space — and the VM
				# line names THIS method (r88 C1: per-method identity).
				if pre != 1 or sp_null != 1 \
						or _log_count(logp,
						"Nonexistent function '%s' in base 'previously freed'"
						% FREED_METHOD_NAMES[m]) != 1:
					return _fail("freed_space_methods jolt %s witness pre=%d sp=%d"
							% [m, pre, sp_null])
				var post_tok: String = res["verdicts"].get(
						"fm_jolt_%s_post" % m, "")
				if res["code"] == 0:
					# dead-handle branch: no crash, the POST path hands back
					# nothing usable (post=nil) and the child completes.
					if crash != 0 or abort != 0 or post_tok != "nil" \
							or res["verdicts"].size() != 1 \
							or not res["errs"].is_empty():
						return _fail("freed_space_methods jolt %s dead envelope rc=0 v=%s crash=%d abort=%d errs=%s"
								% [m, str(res["verdicts"]), crash, abort,
								str(res["errs"])])
					jolt_dead += 1
				elif res["code"] == 134 or res["code"] == 137:
					# three measured crash shapes: the kill lands at
					# bds.get_space_state() (no token), after the POST path
					# handed back a dead handle (post=nil), or after it
					# handed back a LIVE wrapper whose query/teardown then
					# aborts (post=<dss class>). A marker, if present, is
					# exactly one post= token and no other claim.
					var marker_ok: bool = res["verdicts"].is_empty() \
							or (res["verdicts"].size() == 1 \
							and (post_tok == "nil" \
							or post_tok == "t24,JoltPhysicsDirectSpaceState3D"))
					if not marker_ok or crash + abort < 1 \
							or not res["errs"].is_empty():
						return _fail("freed_space_methods jolt %s crash envelope rc=%d v=%s crash=%d abort=%d errs=%s"
								% [m, res["code"], str(res["verdicts"]),
								crash, abort, str(res["errs"])])
					jolt_crash += 1
				else:
					return _fail("freed_space_methods jolt %s rc=%d not crash-or-dead"
							% [m, res["code"]])
			var dmy: Dictionary = batch[2 * FREED_METHODS.size()]
			if dmy.has("err") or dmy.get("batch_timeout", false):
				return _fail("freed_space_methods dummy err=%s timeout=%s"
						% [str(dmy.get("err")), str(dmy.get("batch_timeout"))])
			var dmy_shape := {"pt": "t28,n0", "ray": "t27,n0", "is": "t28,n0",
					"cs": "t28,n0", "cm": "t32,n0", "ri": "t27,n0"}
			var want_dmy := {}
			for m in FREED_METHODS:
				want_dmy["fd_dummy_%s_alive" % m] = dmy_shape[m]
				want_dmy["fd_dummy_%s_pre" % m] = dmy_shape[m]
				want_dmy["fd_dummy_%s_refetch" % m] = \
						"t24,PhysicsDirectSpaceState3DDummy"
				want_dmy["fd_dummy_%s_post" % m] = \
						"t24,PhysicsDirectSpaceState3DDummy"
				want_dmy["fd_dummy_%s_ret" % m] = dmy_shape[m]
			var dmy_log := ProjectSettings.globalize_path(
					"res://fmdummy/child.log")
			if dmy["code"] != 0 or dmy["serr"] \
					or dmy["verdicts"] != want_dmy \
					or _log_count(dmy_log,
							"handle_crash: Program crashed with signal 11") != 0:
				return _fail("freed_space_methods dummy drift exit=%d serr=%s v=%s"
						% [dmy["code"], str(dmy["serr"]),
						str(dmy["verdicts"])])
			# the marker is branch-stable (the per-method branch is a race
			# observable, recorded in each child log and counted here): every
			# Jolt method must land in exactly one of the two envelopes.
			if jolt_crash + jolt_dead != FREED_METHODS.size():
				return _fail("freed_space_methods jolt branches=%d+%d"
						% [jolt_crash, jolt_dead])
			_exit_ok("PASS phys3d_events freed_space_methods gp=crash6@post_fetch jolt=crash-or-dead@post_fetch dummy=empty child_exit=0")

		"if_phase":
			# r89: the intra-tick phase lattice at the contact surface — the
			# scout's §0/§1.3 cells. IF is a PRE-step view (IF(pf=k) == E(pf=k)
			# == F(pf=k-1)); the current step's record is readable at F or at
			# the next tick's IF, never inside IF; the record's `impulse` is
			# one solve late on GodotPhysics and same-step on Jolt; and every
			# out-of-range contact index is a typed refusal, counted per call
			# in the raw child log (never a crash).
			if _gate("Jolt Physics", "if_phase", "jolt"): return
			if _gate("Dummy", "if_phase", "dummy"): return
			var ip_allow := ["is out of bounds"]
			var ip_plain := _spawn_child("ipplainproj",
					_project_body("IpPlain", "", false), "ip_plain", false,
					"res://phys3d_events.gd", 30, ip_allow)
			if ip_plain.has("err"):
				return _fail(ip_plain["err"])
			var ip_jolt := _spawn_child("ipjoltproj",
					_project_body("IpJolt", "Jolt Physics", false),
					"ip_jolt", false, "res://phys3d_events.gd", 30, ip_allow)
			if ip_jolt.has("err"):
				return _fail(ip_jolt["err"])
			var ip_dummy := _spawn_child("ipdummyproj",
					_project_body("IpDummy", "Dummy", false), "ip_dummy",
					false, "res://phys3d_events.gd", 30, ip_allow)
			if ip_dummy.has("err"):
				return _fail(ip_dummy["err"])
			var expect_ip_plain := {
				"ip_plain_backend": "DEFAULT",
				"ip_plain_if_fires": "24",
				"ip_plain_cc_max": "1",
				"ip_plain_first_pf": "13",
				"ip_plain_if_eq_e": "true",
				"ip_plain_f_eq_next_if": "true",
				"ip_plain_seq_order": "true",
				"ip_plain_if_cc_first": "0",
				"ip_plain_e_cc_first": "0",
				"ip_plain_f_cc_first": "1",
				"ip_plain_if_cc_next": "1",
				"ip_plain_imp_first": "zero",
				"ip_plain_imp_first_mag": "0.0000",
				"ip_plain_imp_next_mag": "2.1022",
				"ip_plain_lvloc_first_mag": "2.1022",
				"ip_plain_oob_calls": "11",
				"ip_plain_oob_shape": "-1",
				"ip_plain_cc_after": "1",
			}
			var expect_ip_jolt := {
				"ip_jolt_backend": "Jolt Physics",
				"ip_jolt_if_fires": "24",
				"ip_jolt_cc_max": "1",
				"ip_jolt_first_pf": "13",
				"ip_jolt_if_eq_e": "true",
				"ip_jolt_f_eq_next_if": "true",
				"ip_jolt_seq_order": "true",
				"ip_jolt_if_cc_first": "0",
				"ip_jolt_e_cc_first": "0",
				"ip_jolt_f_cc_first": "1",
				"ip_jolt_if_cc_next": "1",
				"ip_jolt_imp_first": "real",
				"ip_jolt_imp_first_mag": "2.1022",
				"ip_jolt_imp_next_mag": "0.1633",
				"ip_jolt_lvloc_first_mag": "2.1022",
				"ip_jolt_oob_calls": "11",
				"ip_jolt_oob_shape": "0",
				"ip_jolt_cc_after": "1",
			}
			var expect_ip_dummy := {
				"ip_dummy_backend": "Dummy",
				"ip_dummy_if_fires": "0",
				"ip_dummy_cc_max": "0",
				"ip_dummy_first_pf": "-1",
				"ip_dummy_if_eq_e": "absent",
				"ip_dummy_f_eq_next_if": "absent",
				"ip_dummy_seq_order": "absent",
				"ip_dummy_if_cc_first": "-1",
				"ip_dummy_e_cc_first": "-1",
				"ip_dummy_f_cc_first": "-1",
				"ip_dummy_if_cc_next": "-1",
				"ip_dummy_imp_first": "absent",
				"ip_dummy_imp_first_mag": "0.0000",
				"ip_dummy_imp_next_mag": "0.0000",
				"ip_dummy_lvloc_first_mag": "0.0000",
				"ip_dummy_oob_calls": "0",
				"ip_dummy_oob_shape": "absent",
				"ip_dummy_cc_after": "-1",
			}
			for probe in [[ip_plain, expect_ip_plain, "plain"],
					[ip_jolt, expect_ip_jolt, "jolt"],
					[ip_dummy, expect_ip_dummy, "dummy"]]:
				var spawn: Dictionary = probe[0]
				if spawn["code"] != 0 or spawn["serr"] \
						or spawn["verdicts"] != probe[1]:
					return _fail("if_phase %s drift exit=%d serr=%s v=%s errs=%s"
							% [probe[2], spawn["code"], str(spawn["serr"]),
							str(spawn["verdicts"]), str(spawn["errs"])])
			# the out-of-range refusal is a LOG witness: one engine ERROR per
			# getter call, so a silently-default read can never mint the count.
			# The count is the 11 getters + the one extra read that pins the
			# out-of-range `get_contact_local_shape` default (-1 on
			# GodotPhysics, 0 on Jolt — the r87 body_tier split re-bound here).
			for dirname in ["ipplainproj", "ipjoltproj"]:
				var logp := ProjectSettings.globalize_path(
						"res://%s/child.log" % dirname)
				if _log_count(logp, "is out of bounds") \
						!= PHASE_GETTERS.size() + 1:
					return _fail("if_phase %s oob lines=%d expected=%d"
							% [dirname, _log_count(logp, "is out of bounds"),
							PHASE_GETTERS.size() + 1])
			# r89 C5: the seq token is child-assigned; the PHASEMK file
			# position is not. The raw-log order must corroborate the
			# pinned seq_order on both real backends.
			for probe in [["ipplainproj", "true"], ["ipjoltproj", "true"],
					["ipdummyproj", "absent"]]:
				var ph := _log_phase_order(ProjectSettings.globalize_path(
						"res://%s/child.log" % probe[0]))
				if ph != probe[1]:
					return _fail("if_phase %s log_seq=%s expected=%s"
							% [probe[0], ph, probe[1]])
			_exit_ok("PASS phys3d_events if_phase gp=lag jolt=same if_eq_e=true child_exit=0")

		"joint_pin":
			# r89: the pin constraint as a witness — soft by default, frozen at
			# softness 0, rigid at softness 1, sagging under a binding impulse
			# clamp, and the `nomake` control proving the witness measures the
			# joint. `joint_make_generic_6dof` is compared against the control:
			# on Jolt it is a silent no-op (the traces are identical).
			if _gate("Jolt Physics", "joint_pin", "jolt"): return
			if _gate("Dummy", "joint_pin", "dummy"): return
			var jp_plain := _spawn_child("jpplainproj",
					_project_body("JpPlain", "", false), "jp_plain", false)
			if jp_plain.has("err"):
				return _fail(jp_plain["err"])
			var jp_jolt := _spawn_child("jpjoltproj",
					_project_body("JpJolt", "Jolt Physics", false),
					"jp_jolt", false)
			if jp_jolt.has("err"):
				return _fail(jp_jolt["err"])
			var jp_dummy := _spawn_child("jpdummyproj",
					_project_body("JpDummy", "Dummy", false), "jp_dummy", false)
			if jp_dummy.has("err"):
				return _fail(jp_dummy["err"])
			var expect_jp_plain := {
				"jp_plain_backend": "DEFAULT",
				"jp_plain_pin_gap": "0.8885,0.8900",
				"jp_plain_pin_lv": "-0.0000",
				"jp_plain_pin_type": "0",
				"jp_plain_soft0_gap": "1.0000,1.0000",
				"jp_plain_soft0_lv": "0.0000",
				"jp_plain_soft0_type": "0",
				"jp_plain_soft1_gap": "0.0000,0.0000",
				"jp_plain_soft1_lv": "0.0000",
				"jp_plain_soft1_type": "0",
				"jp_plain_clamp2_gap": "1.0006,1.0043",
				"jp_plain_clamp2_lv": "-0.0396",
				"jp_plain_clamp2_type": "0",
				"jp_plain_nomake_gap": "1.0272,1.2110",
				"jp_plain_nomake_lv": "-1.9421",
				"jp_plain_nomake_type": "5",
				"jp_plain_g6dof_gap": "0.8869,0.8900",
				"jp_plain_g6dof_lv": "0.0000",
				"jp_plain_g6dof_type": "4",
				"jp_plain_pin_rb": "0.3000,1.0000,0.0000",
				"jp_plain_soft0_rb": "0.0000,1.0000,0.0000",
				"jp_plain_soft1_rb": "1.0000,1.0000,0.0000",
				"jp_plain_clamp2_rb": "0.3000,1.0000,0.0100",
				"jp_plain_coll_default": "true",
				"jp_plain_g6dof_eq_nomake": "false",
			}
			var expect_jp_jolt := {
				"jp_jolt_backend": "Jolt Physics",
				"jp_jolt_pin_gap": "0.3153,0.2032",
				"jp_jolt_pin_lv": "0.0000",
				"jp_jolt_pin_type": "0",
				"jp_jolt_soft0_gap": "0.3153,0.2032",
				"jp_jolt_soft0_lv": "0.0000",
				"jp_jolt_soft0_type": "0",
				"jp_jolt_soft1_gap": "0.3153,0.2032",
				"jp_jolt_soft1_lv": "0.0000",
				"jp_jolt_soft1_type": "0",
				"jp_jolt_clamp2_gap": "0.3153,0.2032",
				"jp_jolt_clamp2_lv": "0.0000",
				"jp_jolt_clamp2_type": "0",
				"jp_jolt_nomake_gap": "1.0272,1.2110",
				"jp_jolt_nomake_lv": "-1.9421",
				"jp_jolt_nomake_type": "5",
				"jp_jolt_g6dof_gap": "1.0272,1.2110",
				"jp_jolt_g6dof_lv": "-1.9421",
				"jp_jolt_g6dof_type": "4",
				"jp_jolt_pin_rb": "0.3000,1.0000,0.0000",
				"jp_jolt_soft0_rb": "0.3000,1.0000,0.0000",
				"jp_jolt_soft1_rb": "0.3000,1.0000,0.0000",
				"jp_jolt_clamp2_rb": "0.3000,1.0000,0.0000",
				"jp_jolt_coll_default": "false",
				"jp_jolt_g6dof_eq_nomake": "true",
			}
			var expect_jp_dummy := {
				"jp_dummy_backend": "Dummy",
				"jp_dummy_pin_gap": "0.0000,0.0000",
				"jp_dummy_pin_lv": "0.0000",
				"jp_dummy_pin_type": "0",
				"jp_dummy_soft0_gap": "0.0000,0.0000",
				"jp_dummy_soft0_lv": "0.0000",
				"jp_dummy_soft0_type": "0",
				"jp_dummy_soft1_gap": "0.0000,0.0000",
				"jp_dummy_soft1_lv": "0.0000",
				"jp_dummy_soft1_type": "0",
				"jp_dummy_clamp2_gap": "0.0000,0.0000",
				"jp_dummy_clamp2_lv": "0.0000",
				"jp_dummy_clamp2_type": "0",
				"jp_dummy_nomake_gap": "0.0000,0.0000",
				"jp_dummy_nomake_lv": "0.0000",
				"jp_dummy_nomake_type": "0",
				"jp_dummy_g6dof_gap": "0.0000,0.0000",
				"jp_dummy_g6dof_lv": "0.0000",
				"jp_dummy_g6dof_type": "0",
				"jp_dummy_pin_rb": "0.0000,0.0000,0.0000",
				"jp_dummy_soft0_rb": "0.0000,0.0000,0.0000",
				"jp_dummy_soft1_rb": "0.0000,0.0000,0.0000",
				"jp_dummy_clamp2_rb": "0.0000,0.0000,0.0000",
				"jp_dummy_coll_default": "false",
				"jp_dummy_g6dof_eq_nomake": "true",
			}
			for probe in [[jp_plain, expect_jp_plain, "plain"],
					[jp_jolt, expect_jp_jolt, "jolt"],
					[jp_dummy, expect_jp_dummy, "dummy"]]:
				var spawn: Dictionary = probe[0]
				if spawn["code"] != 0 or spawn["serr"] \
						or spawn["verdicts"] != probe[1]:
					return _fail("joint_pin %s drift exit=%d serr=%s v=%s errs=%s"
							% [probe[2], spawn["code"], str(spawn["serr"]),
							str(spawn["verdicts"]), str(spawn["errs"])])
			# the Jolt drops are not silent: exactly 3 "not supported when
			# using Jolt Physics" WARNINGs (2x pin bias, 1x impulse clamp);
			# GP and Dummy emit none.
			if _log_count(ProjectSettings.globalize_path(
					"res://jpjoltproj/child.log"),
					"not supported when using Jolt Physics") != 3:
				return _fail("joint_pin jolt warnings drift")
			for dirname in ["jpplainproj", "jpdummyproj"]:
				if _log_count(ProjectSettings.globalize_path(
						"res://%s/child.log" % dirname),
						"not supported when using Jolt Physics") != 0:
					return _fail("joint_pin %s unexpected jolt warning"
							% dirname)
			_exit_ok("PASS phys3d_events joint_pin gp=soft jolt=dropped dummy=flat child_exit=0")

		"joint_param":
			# r89: the per-parameter round-trip table per backend. Jolt
			# silently drops a per-type subset of solver-tuning writes while
			# honoring limits/motors; GodotPhysics honors the table except the
			# slider, whose getter is write-opaque (one wrong-type guard line
			# per call, counted from the raw log by the parent).
			if _gate("Jolt Physics", "joint_param", "jolt"): return
			if _gate("Dummy", "joint_param", "dummy"): return
			var jq_allow := ["Condition \"joint->get_type() != JOINT_TYPE_CONE_TWIST\""]
			var jq_plain := _spawn_child("jqplainproj",
					_project_body("JqPlain", "", false), "jq_plain", false,
					"res://phys3d_events.gd", 30, jq_allow)
			if jq_plain.has("err"):
				return _fail(jq_plain["err"])
			var jq_jolt := _spawn_child("jqjoltproj",
					_project_body("JqJolt", "Jolt Physics", false),
					"jq_jolt", false, "res://phys3d_events.gd", 30, jq_allow)
			if jq_jolt.has("err"):
				return _fail(jq_jolt["err"])
			var jq_dummy := _spawn_child("jqdummyproj",
					_project_body("JqDummy", "Dummy", false), "jq_dummy", false,
					"res://phys3d_events.gd", 30, jq_allow)
			if jq_dummy.has("err"):
				return _fail(jq_dummy["err"])
			var expect_jq_plain := {
				"jq_plain_backend": "DEFAULT",
				"jq_plain_pin_type": "0",
				"jq_plain_pin_hon": "0,1,2",
				"jq_plain_pin_drop": "-",
				"jq_plain_hinge_type": "1",
				"jq_plain_hinge_hon": "0,1,2,3,4,5,6,7",
				"jq_plain_hinge_drop": "-",
				"jq_plain_slider_type": "2",
				"jq_plain_slider_hon": "-",
				"jq_plain_slider_drop": "0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21",
				"jq_plain_cone_type": "3",
				"jq_plain_cone_hon": "0,1,2,3,4",
				"jq_plain_cone_drop": "-",
				"jq_plain_g6dof_type": "4",
				"jq_plain_g6dof_hon": "0,1,2,3,4,10,11,12,13,14,15,16,17",
				"jq_plain_g6dof_drop": "5,6,7,8,9,18,19,20,21",
				"jq_plain_hinge_flags": "2/2",
				"jq_plain_g6dof_flags": "3/6",
				"jq_plain_unmade_type": "5",
				"jq_plain_unmade_solver": "1",
				"jq_plain_coll_default": "true",
			}
			var expect_jq_jolt := {
				"jq_jolt_backend": "Jolt Physics",
				"jq_jolt_pin_type": "0",
				"jq_jolt_pin_hon": "-",
				"jq_jolt_pin_drop": "0,1,2",
				"jq_jolt_hinge_type": "1",
				"jq_jolt_hinge_hon": "1,2,6,7",
				"jq_jolt_hinge_drop": "0,3,4,5",
				"jq_jolt_slider_type": "2",
				"jq_jolt_slider_hon": "0,1",
				"jq_jolt_slider_drop": "2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21",
				"jq_jolt_cone_type": "3",
				"jq_jolt_cone_hon": "0,1",
				"jq_jolt_cone_drop": "2,3,4",
				"jq_jolt_g6dof_type": "4",
				"jq_jolt_g6dof_hon": "0,1,3,5,6,7,8,9,10,11,12,16,17,18,19,20,21",
				"jq_jolt_g6dof_drop": "2,4,13,14,15",
				"jq_jolt_hinge_flags": "2/2",
				"jq_jolt_g6dof_flags": "6/6",
				"jq_jolt_unmade_type": "5",
				"jq_jolt_unmade_solver": "1",
				"jq_jolt_coll_default": "false",
			}
			var expect_jq_dummy := {
				"jq_dummy_backend": "Dummy",
				"jq_dummy_pin_type": "0",
				"jq_dummy_pin_hon": "-",
				"jq_dummy_pin_drop": "0,1,2",
				"jq_dummy_hinge_type": "0",
				"jq_dummy_hinge_hon": "-",
				"jq_dummy_hinge_drop": "0,1,2,3,4,5,6,7",
				"jq_dummy_slider_type": "0",
				"jq_dummy_slider_hon": "-",
				"jq_dummy_slider_drop": "0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21",
				"jq_dummy_cone_type": "0",
				"jq_dummy_cone_hon": "-",
				"jq_dummy_cone_drop": "0,1,2,3,4",
				"jq_dummy_g6dof_type": "0",
				"jq_dummy_g6dof_hon": "-",
				"jq_dummy_g6dof_drop": "0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21",
				"jq_dummy_hinge_flags": "0/2",
				"jq_dummy_g6dof_flags": "0/6",
				"jq_dummy_unmade_type": "0",
				"jq_dummy_unmade_solver": "0",
				"jq_dummy_coll_default": "false",
			}
			for probe in [[jq_plain, expect_jq_plain, "plain"],
					[jq_jolt, expect_jq_jolt, "jolt"],
					[jq_dummy, expect_jq_dummy, "dummy"]]:
				var spawn: Dictionary = probe[0]
				if spawn["code"] != 0 or spawn["serr"] \
						or spawn["verdicts"] != probe[1]:
					return _fail("joint_param %s drift exit=%d serr=%s v=%s errs=%s"
							% [probe[2], spawn["code"], str(spawn["serr"]),
							str(spawn["verdicts"]), str(spawn["errs"])])
			# the slider getter's wrong-type guard is the write-opacity
			# witness: GodotPhysics prints one per call, Jolt and Dummy none.
			var jq_guard := _log_count(ProjectSettings.globalize_path(
					"res://jqplainproj/child.log"),
					"Condition \"joint->get_type() != JOINT_TYPE_CONE_TWIST\"")
			if jq_guard != JP_TYPES["slider"]:
				return _fail("joint_param plain slider guards=%d expected=%d"
						% [jq_guard, JP_TYPES["slider"]])
			for dirname in ["jqjoltproj", "jqdummyproj"]:
				if _log_count(ProjectSettings.globalize_path(
						"res://%s/child.log" % dirname),
						"Condition \"joint->get_type() != JOINT_TYPE_CONE_TWIST\"") != 0:
					return _fail("joint_param %s unexpected slider guard"
							% dirname)
			# the Jolt drop list is not silent either: the engine emits one
			# "<param> ... not supported when using Jolt Physics" WARNING per
			# refused write — 33 "is" + 2 "are" (slider angular limits) = 35,
			# matching the pinned drop rows exactly. Counted like the slider
			# guard so a drop-without-warning drift fails.
			var jq_jolt_warn := _log_count(ProjectSettings.globalize_path(
					"res://jqjoltproj/child.log"),
					"not supported when using Jolt Physics")
			if jq_jolt_warn != 35:
				return _fail("joint_param jolt warnings=%d expected=35"
						% jq_jolt_warn)
			for dirname in ["jqplainproj", "jqdummyproj"]:
				if _log_count(ProjectSettings.globalize_path(
						"res://%s/child.log" % dirname),
						"not supported when using Jolt Physics") != 0:
					return _fail("joint_param %s unexpected jolt warning"
							% dirname)
			_exit_ok("PASS phys3d_events joint_param gp=sliderblind jolt=drops dummy=drops child_exit=0")

		"sleep_state":
			# r89: the sleeping-body direct state, ONE cell per process in one
			# parallel batch (a natural sleep takes ~40 wall-clock physics
			# ticks, so a serial sweep of 13 cells would not fit the per-case
			# bound). Each child still carries its own `timeout -s KILL`; the
			# batch deadline is the fail-closed net on top.
			if _gate("Jolt Physics", "sleep_state", "jolt"): return
			if _gate("Dummy", "sleep_state", "dummy"): return
			var sl_specs := []
			for cell in SLEEP_CELLS:
				sl_specs.append({
					"dirname": "sl%splain" % cell,
					"arm": "sl_%s_plain" % cell,
					"project_body": _project_body("Sl%sPlain" % cell.capitalize(),
							"", false),
					"bound_s": 20,
				})
				sl_specs.append({
					"dirname": "sl%sjolt" % cell,
					"arm": "sl_%s_jolt" % cell,
					"project_body": _project_body("Sl%sJolt" % cell.capitalize(),
							"Jolt Physics", false),
					"bound_s": 20,
				})
			sl_specs.append({
				"dirname": "sldummy", "arm": "sl_dummy",
				"project_body": _project_body("SlDummy", "Dummy", false),
				"bound_s": 20,
			})
			var sl_batch := _spawn_batch(sl_specs)
			# Measured per cell (the r89-scout's §5 lattice, re-bound here):
			# the fetch and every read leave the body asleep and the held
			# state object's contact view reads the pre-sleep snapshot (cc=1,
			# the support impulse 0.1633, lv frozen — a stale READ, not a
			# claim about the backend's internal buffer); the IF
			# callback stops on the sleep tick (42 calls at slept=41 and still
			# 42 six ticks later); a velocity or transform write lands, wakes
			# the body and takes effect; `set_sleep_state(false)` re-sleeps at
			# the next tick on GodotPhysics while Jolt stays awake-but-frozen;
			# moving the floor wakes the ball on GodotPhysics and not on Jolt
			# (frozen at y=-0.0110 with the same stale read); and the state-sync
			# callback never fires while asleep.
			var sl_want := {
				"sl_reads_plain": {
					"sl_reads_plain_backend": "DEFAULT",
					"sl_reads_plain_slept": "41",
					"sl_reads_plain_if_calls": "42",
					"sl_reads_plain_cc": "1",
					"sl_reads_plain_imp": "0.1633",
					"sl_reads_plain_lv": "0.0000,-0.0000,0.0000",
					"sl_reads_plain_hdl_sleep": "true",
					"sl_reads_plain_awake_ticks": "0",
					"sl_reads_plain_if_calls_after": "42",
				},
				"sl_reads_jolt": {
					"sl_reads_jolt_backend": "Jolt Physics",
					"sl_reads_jolt_slept": "41",
					"sl_reads_jolt_if_calls": "42",
					"sl_reads_jolt_cc": "1",
					"sl_reads_jolt_imp": "0.1633",
					"sl_reads_jolt_lv": "0.0000,0.0000,0.0000",
					"sl_reads_jolt_hdl_sleep": "true",
					"sl_reads_jolt_awake_ticks": "0",
					"sl_reads_jolt_if_calls_after": "42",
				},
				"sl_wake_plain": {
					"sl_wake_plain_backend": "DEFAULT",
					"sl_wake_plain_slept": "41",
					"sl_wake_plain_if_calls": "42",
					"sl_wake_plain_same_lv": "0.0000,0.0000,2.0000",
					"sl_wake_plain_same_hdl": "false",
					"sl_wake_plain_srv_sleep": "false",
					"sl_wake_plain_moved": "true",
				},
				"sl_wake_jolt": {
					"sl_wake_jolt_backend": "Jolt Physics",
					"sl_wake_jolt_slept": "41",
					"sl_wake_jolt_if_calls": "42",
					"sl_wake_jolt_same_lv": "0.0000,0.0000,2.0000",
					"sl_wake_jolt_same_hdl": "false",
					"sl_wake_jolt_srv_sleep": "false",
					"sl_wake_jolt_moved": "true",
				},
				"sl_xform_plain": {
					"sl_xform_plain_backend": "DEFAULT",
					"sl_xform_plain_slept": "41",
					"sl_xform_plain_if_calls": "42",
					"sl_xform_plain_same_tr": "0.0000,0.9900,0.0000",
					"sl_xform_plain_same_hdl": "false",
					"sl_xform_plain_srv_sleep": "false",
					"sl_xform_plain_fell": "true",
				},
				"sl_xform_jolt": {
					"sl_xform_jolt_backend": "Jolt Physics",
					"sl_xform_jolt_slept": "41",
					"sl_xform_jolt_if_calls": "42",
					"sl_xform_jolt_same_tr": "0.0000,0.9890,0.0000",
					"sl_xform_jolt_same_hdl": "false",
					"sl_xform_jolt_srv_sleep": "false",
					"sl_xform_jolt_fell": "true",
				},
				"sl_toggle_plain": {
					"sl_toggle_plain_backend": "DEFAULT",
					"sl_toggle_plain_slept": "41",
					"sl_toggle_plain_if_calls": "42",
					"sl_toggle_plain_same_hdl": "false",
					"sl_toggle_plain_same_srv": "false",
					"sl_toggle_plain_next_srv": "true",
					"sl_toggle_plain_frozen": "true",
				},
				"sl_toggle_jolt": {
					"sl_toggle_jolt_backend": "Jolt Physics",
					"sl_toggle_jolt_slept": "41",
					"sl_toggle_jolt_if_calls": "42",
					"sl_toggle_jolt_same_hdl": "false",
					"sl_toggle_jolt_same_srv": "false",
					"sl_toggle_jolt_next_srv": "false",
					"sl_toggle_jolt_frozen": "true",
				},
				"sl_floor_plain": {
					"sl_floor_plain_backend": "DEFAULT",
					"sl_floor_plain_slept": "41",
					"sl_floor_plain_if_calls": "42",
					"sl_floor_plain_srv_sleep": "false",
					"sl_floor_plain_ball_tr": "0.0000,-0.0670,0.0000",
					"sl_floor_plain_cc": "0",
				},
				"sl_floor_jolt": {
					"sl_floor_jolt_backend": "Jolt Physics",
					"sl_floor_jolt_slept": "41",
					"sl_floor_jolt_if_calls": "42",
					"sl_floor_jolt_srv_sleep": "true",
					"sl_floor_jolt_ball_tr": "0.0000,-0.0110,0.0000",
					"sl_floor_jolt_cc": "1",
				},
				"sl_sync_plain": {
					"sl_sync_plain_backend": "DEFAULT",
					"sl_sync_plain_slept": "41",
					"sl_sync_plain_if_calls": "42",
					"sl_sync_plain_ss_count": "0",
					"sl_sync_plain_srv_sleep": "true",
				},
				"sl_sync_jolt": {
					"sl_sync_jolt_backend": "Jolt Physics",
					"sl_sync_jolt_slept": "41",
					"sl_sync_jolt_if_calls": "42",
					"sl_sync_jolt_ss_count": "0",
					"sl_sync_jolt_srv_sleep": "true",
				},
				"sl_dummy": {
					"sl_dummy_backend": "Dummy",
					"sl_dummy_slept": "never",
					"sl_dummy_cc": "0",
					"sl_dummy_if_fires": "0",
				},
			}
			var sl_bad := []
			for i in range(sl_specs.size()):
				var sl_arm: String = sl_specs[i]["arm"]
				var res: Dictionary = sl_batch[i]
				if res.has("err") or res.get("batch_timeout", false):
					sl_bad.append("%s err=%s timeout=%s" % [sl_arm,
							str(res.get("err")), str(res.get("batch_timeout"))])
					continue
				if not sl_want.has(sl_arm):
					sl_bad.append("%s no sl_want cell (unasserted row)" % sl_arm)
					continue
				if res["code"] != 0 or res["serr"] \
						or res["verdicts"] != sl_want[sl_arm]:
					sl_bad.append("%s exit=%d serr=%s v=%s errs=%s" % [sl_arm,
							res["code"], str(res["serr"]),
							str(res["verdicts"]), str(res["errs"])])
			if not sl_bad.is_empty():
				return _fail("sleep_state drift %s" % str(sl_bad))
			_exit_ok("PASS phys3d_events sleep_state stale_buf=retained writes=wake toggle=gp_resleeps,jolt_frozen floor=gp_wakes,jolt_not child_exit=0")

		"if_write":
			# r89: the _integrate_forces interior rules. Immediate members
			# (velocity, angular velocity, transform, impulses) are visible in
			# the same turn through the same handle and persist; force, torque
			# and constant-force members are deferred one step; the sleep write
			# is honored now but the two backends split on the velocity; a
			# re-entrant integrate_forces() silently double-integrates; and
			# body_set_space(RID()) detaches and freezes the body. No member is
			# refused on either real backend — the parent counts the engine's
			# in/out-phase refusal line in the raw log, so "legal" is a
			# witnessed zero, never an assumption.
			if _gate("Jolt Physics", "if_write", "jolt"): return
			if _gate("Dummy", "if_write", "dummy"): return
			# the detach member's teardown witness on Jolt: the node's inertia
			# read after body_set_space(RID()) fails loudly because the body
			# has no physics space (the engine's own line, counted by the
			# parent, never a fabricated claim)
			var iw_allow := ["without a physics space is not supported"]
			var iw_plain := _spawn_child("iwplainproj",
					_project_body("IwPlain", "", false), "iw_plain", false,
					"res://phys3d_events.gd", 30, iw_allow)
			if iw_plain.has("err"):
				return _fail(iw_plain["err"])
			var iw_jolt := _spawn_child("iwjoltproj",
					_project_body("IwJolt", "Jolt Physics", false),
					"iw_jolt", false, "res://phys3d_events.gd", 30, iw_allow)
			if iw_jolt.has("err"):
				return _fail(iw_jolt["err"])
			var iw_dummy := _spawn_child("iwdummyproj",
					_project_body("IwDummy", "Dummy", false), "iw_dummy", false,
					"res://phys3d_events.gd", 30, iw_allow)
			if iw_dummy.has("err"):
				return _fail(iw_dummy["err"])
			var expect_iw_plain := {
				"iw_plain_backend": "DEFAULT",
				"iw_plain_baseline_same": "0.0000,-0.6517,0.0000",
				"iw_plain_baseline_rel1": "0.0000,-0.6517,0.0000",
				"iw_plain_baseline_rel2": "0.0000,-0.8139,0.0000",
				"iw_plain_baseline_class": "control",
				"iw_plain_linvel_same": "1.0000,2.0000,3.0000",
				"iw_plain_linvel_rel1": "1.0000,2.0000,3.0000",
				"iw_plain_linvel_rel2": "0.9983,1.8333,2.9950",
				"iw_plain_linvel_class": "now",
				"iw_plain_angvel_same": "0.5000,1.0000,1.5000",
				"iw_plain_angvel_rel1": "0.5000,1.0000,1.5000",
				"iw_plain_angvel_rel2": "0.4992,0.9983,1.4975",
				"iw_plain_angvel_class": "now",
				"iw_plain_xform_same": "0.0000,8.0000,0.0000",
				"iw_plain_xform_rel1": "0.0000,8.0000,0.0000",
				"iw_plain_xform_rel2": "0.0000,7.9864,0.0000",
				"iw_plain_xform_class": "now",
				"iw_plain_cimpulse_same": "0.0000,2.3483,0.0000",
				"iw_plain_cimpulse_rel1": "0.0000,2.3483,0.0000",
				"iw_plain_cimpulse_rel2": "0.0000,2.1811,0.0000",
				"iw_plain_cimpulse_class": "now",
				"iw_plain_timpulse_same": "0.0000,0.0000,30.0000",
				"iw_plain_timpulse_rel1": "0.0000,0.0000,30.0000",
				"iw_plain_timpulse_rel2": "0.0000,0.0000,29.9500",
				"iw_plain_timpulse_class": "now",
				"iw_plain_cforce_same": "0.0000,-0.6517,0.0000",
				"iw_plain_cforce_rel1": "0.0000,-0.6517,0.0000",
				"iw_plain_cforce_rel2": "0.0000,0.1861,0.0000",
				"iw_plain_cforce_class": "deferred",
				"iw_plain_torque_same": "0.0000,0.0000,0.0000",
				"iw_plain_torque_rel1": "0.0000,0.0000,0.0000",
				"iw_plain_torque_rel2": "0.0000,0.0000,10.0000",
				"iw_plain_torque_class": "deferred",
				"iw_plain_setcforce_same": "0.0000,7.0000,0.0000",
				"iw_plain_setcforce_rel1": "0.0000,-0.6517,0.0000",
				"iw_plain_setcforce_rel2": "0.0000,-0.6973,0.0000",
				"iw_plain_setcforce_class": "deferred",
				"iw_plain_sleep_same": "true",
				"iw_plain_sleep_rel1": "true/0.0000,-0.6517,0.0000",
				"iw_plain_sleep_rel2": "true/0.0000,-0.6517,0.0000",
				"iw_plain_sleep_class": "kept",
				"iw_plain_reentrant_same": "0.0000,-0.8137,0.0000",
				"iw_plain_reentrant_rel1": "0.0000,-0.8137,0.0000",
				"iw_plain_reentrant_rel2": "0.0000,-0.9757,0.0000",
				"iw_plain_reentrant_class": "double",
				"iw_plain_detach_same": "RID(0)",
				"iw_plain_detach_rel1": "RID(0)",
				"iw_plain_detach_rel2": "RID(0)",
				"iw_plain_detach_class": "frozen",
			}
			var expect_iw_jolt := {
				"iw_jolt_backend": "Jolt Physics",
				"iw_jolt_baseline_same": "0.0000,-0.6517,0.0000",
				"iw_jolt_baseline_rel1": "0.0000,-0.6517,0.0000",
				"iw_jolt_baseline_rel2": "0.0000,-0.8139,0.0000",
				"iw_jolt_baseline_class": "control",
				"iw_jolt_linvel_same": "1.0000,2.0000,3.0000",
				"iw_jolt_linvel_rel1": "1.0000,2.0000,3.0000",
				"iw_jolt_linvel_rel2": "0.9983,1.8333,2.9950",
				"iw_jolt_linvel_class": "now",
				"iw_jolt_angvel_same": "0.5000,1.0000,1.5000",
				"iw_jolt_angvel_rel1": "0.5000,1.0000,1.5000",
				"iw_jolt_angvel_rel2": "0.4992,0.9983,1.4975",
				"iw_jolt_angvel_class": "now",
				"iw_jolt_xform_same": "0.0000,8.0000,0.0000",
				"iw_jolt_xform_rel1": "0.0000,8.0000,0.0000",
				"iw_jolt_xform_rel2": "0.0000,7.9864,0.0000",
				"iw_jolt_xform_class": "now",
				"iw_jolt_cimpulse_same": "0.0000,2.3483,0.0000",
				"iw_jolt_cimpulse_rel1": "0.0000,2.3483,0.0000",
				"iw_jolt_cimpulse_rel2": "0.0000,2.1811,0.0000",
				"iw_jolt_cimpulse_class": "now",
				"iw_jolt_timpulse_same": "0.0000,0.0000,30.0000",
				"iw_jolt_timpulse_rel1": "0.0000,0.0000,30.0000",
				"iw_jolt_timpulse_rel2": "0.0000,0.0000,29.9500",
				"iw_jolt_timpulse_class": "now",
				"iw_jolt_cforce_same": "0.0000,-0.6517,0.0000",
				"iw_jolt_cforce_rel1": "0.0000,-0.6517,0.0000",
				"iw_jolt_cforce_rel2": "0.0000,0.1861,0.0000",
				"iw_jolt_cforce_class": "deferred",
				"iw_jolt_torque_same": "0.0000,0.0000,0.0000",
				"iw_jolt_torque_rel1": "0.0000,0.0000,0.0000",
				"iw_jolt_torque_rel2": "0.0000,0.0000,10.0000",
				"iw_jolt_torque_class": "deferred",
				"iw_jolt_setcforce_same": "0.0000,7.0000,0.0000",
				"iw_jolt_setcforce_rel1": "0.0000,-0.6517,0.0000",
				"iw_jolt_setcforce_rel2": "0.0000,-0.6973,0.0000",
				"iw_jolt_setcforce_class": "deferred",
				"iw_jolt_sleep_same": "true",
				"iw_jolt_sleep_rel1": "true/0.0000,0.0000,0.0000",
				"iw_jolt_sleep_rel2": "true/0.0000,0.0000,0.0000",
				"iw_jolt_sleep_class": "zeroed",
				"iw_jolt_reentrant_same": "0.0000,-0.8139,0.0000",
				"iw_jolt_reentrant_rel1": "0.0000,-0.8139,0.0000",
				"iw_jolt_reentrant_rel2": "0.0000,-0.9759,0.0000",
				"iw_jolt_reentrant_class": "double",
				"iw_jolt_detach_same": "RID(0)",
				"iw_jolt_detach_rel1": "RID(0)",
				"iw_jolt_detach_rel2": "RID(0)",
				"iw_jolt_detach_class": "frozen",
			}
			var expect_iw_dummy := {
				"iw_dummy_backend": "Dummy",
				"iw_dummy_baseline_same": "-",
				"iw_dummy_baseline_rel1": "-",
				"iw_dummy_baseline_rel2": "-",
				"iw_dummy_baseline_class": "nowrite",
				"iw_dummy_linvel_same": "-",
				"iw_dummy_linvel_rel1": "-",
				"iw_dummy_linvel_rel2": "-",
				"iw_dummy_linvel_class": "nowrite",
				"iw_dummy_angvel_same": "-",
				"iw_dummy_angvel_rel1": "-",
				"iw_dummy_angvel_rel2": "-",
				"iw_dummy_angvel_class": "nowrite",
				"iw_dummy_xform_same": "-",
				"iw_dummy_xform_rel1": "-",
				"iw_dummy_xform_rel2": "-",
				"iw_dummy_xform_class": "nowrite",
				"iw_dummy_cimpulse_same": "-",
				"iw_dummy_cimpulse_rel1": "-",
				"iw_dummy_cimpulse_rel2": "-",
				"iw_dummy_cimpulse_class": "nowrite",
				"iw_dummy_timpulse_same": "-",
				"iw_dummy_timpulse_rel1": "-",
				"iw_dummy_timpulse_rel2": "-",
				"iw_dummy_timpulse_class": "nowrite",
				"iw_dummy_cforce_same": "-",
				"iw_dummy_cforce_rel1": "-",
				"iw_dummy_cforce_rel2": "-",
				"iw_dummy_cforce_class": "nowrite",
				"iw_dummy_torque_same": "-",
				"iw_dummy_torque_rel1": "-",
				"iw_dummy_torque_rel2": "-",
				"iw_dummy_torque_class": "nowrite",
				"iw_dummy_setcforce_same": "-",
				"iw_dummy_setcforce_rel1": "-",
				"iw_dummy_setcforce_rel2": "-",
				"iw_dummy_setcforce_class": "nowrite",
				"iw_dummy_sleep_same": "-",
				"iw_dummy_sleep_rel1": "-",
				"iw_dummy_sleep_rel2": "-",
				"iw_dummy_sleep_class": "nowrite",
				"iw_dummy_reentrant_same": "-",
				"iw_dummy_reentrant_rel1": "-",
				"iw_dummy_reentrant_rel2": "-",
				"iw_dummy_reentrant_class": "nowrite",
				"iw_dummy_detach_same": "-",
				"iw_dummy_detach_rel1": "-",
				"iw_dummy_detach_rel2": "-",
				"iw_dummy_detach_class": "nowrite",
			}
			for probe in [[iw_plain, expect_iw_plain, "plain"],
					[iw_jolt, expect_iw_jolt, "jolt"],
					[iw_dummy, expect_iw_dummy, "dummy"]]:
				var spawn: Dictionary = probe[0]
				if spawn["code"] != 0 or spawn["serr"] \
						or spawn["verdicts"] != probe[1]:
					return _fail("if_write %s drift exit=%d serr=%s v=%s errs=%s"
							% [probe[2], spawn["code"], str(spawn["serr"]),
							str(spawn["verdicts"]), str(spawn["errs"])])
			# "no member is refused" is a witnessed zero: the engine's own
			# in/out-phase refusal line is counted in each raw child log, and
			# the Jolt detach teardown witness is counted where it belongs
			# (one on Jolt, none on GodotPhysics and Dummy).
			for dirname in ["iwplainproj", "iwjoltproj", "iwdummyproj"]:
				if _log_count(ProjectSettings.globalize_path(
						"res://%s/child.log" % dirname),
						"Function blocked during in/out phase") != 0:
					return _fail("if_write %s in/out-phase refusal present"
							% dirname)
			if _log_count(ProjectSettings.globalize_path(
					"res://iwjoltproj/child.log"),
					"without a physics space is not supported") != 1:
				return _fail("if_write jolt detach witness=%d expected=1"
						% _log_count(ProjectSettings.globalize_path(
						"res://iwjoltproj/child.log"),
						"without a physics space is not supported"))
			for dirname in ["iwplainproj", "iwdummyproj"]:
				if _log_count(ProjectSettings.globalize_path(
						"res://%s/child.log" % dirname),
						"without a physics space is not supported") != 0:
					return _fail("if_write %s unexpected detach witness"
							% dirname)
			_exit_ok("PASS phys3d_events if_write immediate=vel,xform,impulse deferred=force,torque sleep=kept,jolt_zeroed child_exit=0")

		"cross_space":
			# r89: cross-space handle validity. A second World3D (a
			# SubViewport carrying its own World3D) and a raw active server
			# space are both serviceable from the main world's physics tick,
			# each handle resolves to its OWN space (and not the other's), and
			# the discriminating query is a ray whose hit height names the
			# space. The last cell pins the server-vs-node box convention: half
			# extents vs full size. One measured backend split is pinned as
			# values, never as a claim of universality: a server body placed in
			# a non-main space is stepped on GodotPhysics but NOT on Jolt when
			# no node lives in that world (the raw space's ball stays at y=2
			# on Jolt), while the same body DOES move once a node shares the
			# world (world B's ball and node both fall on Jolt) — the scout's
			# Jolt `bsfroma` receipt shows the same frozen raw body.
			if _gate("Jolt Physics", "cross_space", "jolt"): return
			if _gate("Dummy", "cross_space", "dummy"): return
			var cx_plain := _spawn_child("cxplainproj",
					_project_body("CxPlain", "", false), "cx_plain", false)
			if cx_plain.has("err"):
				return _fail(cx_plain["err"])
			var cx_jolt := _spawn_child("cxjoltproj",
					_project_body("CxJolt", "Jolt Physics", false),
					"cx_jolt", false)
			if cx_jolt.has("err"):
				return _fail(cx_jolt["err"])
			var cx_dummy := _spawn_child("cxdummyproj",
					_project_body("CxDummy", "Dummy", false), "cx_dummy", false)
			if cx_dummy.has("err"):
				return _fail(cx_dummy["err"])
			var expect_cx_plain := {
				"cx_plain_backend": "DEFAULT",
				"cx_plain_dss_a": "GodotPhysicsDirectSpaceState3D",
				"cx_plain_dss_b": "GodotPhysicsDirectSpaceState3D",
				"cx_plain_fetch_b": "GodotPhysicsDirectSpaceState3D",
				"cx_plain_bds_a": "GodotPhysicsDirectBodyState3D",
				"cx_plain_bds_b": "GodotPhysicsDirectBodyState3D",
				"cx_plain_a_ne_b": "true",
				"cx_plain_b_bound": "true",
				"cx_plain_b_find": "true",
				"cx_plain_ident_a": "true",
				"cx_plain_ident_b": "true",
				"cx_plain_cross_ident": "false",
				"cx_plain_ray_a": "hit=-0.5000",
				"cx_plain_ray_b": "hit=-10.5000",
				"cx_plain_ray_fetch_b": "hit=-10.5000",
				"cx_plain_fall_a": "1.6328",
				"cx_plain_fall_b": "-8.2838",
				"cx_plain_node_b_fall": "-8.2838",
				"cx_plain_raw_fetch": "GodotPhysicsDirectSpaceState3D",
				"cx_plain_raw_bds": "GodotPhysicsDirectBodyState3D",
				"cx_plain_raw_ident": "true",
				"cx_plain_raw_ray": "hit=1.0000",
				"cx_plain_raw_moves": "1.7160",
				"cx_plain_srv_box": "hit=1.0000",
				"cx_plain_node_box": "hit=0.5000",
			}
			var expect_cx_jolt := {
				"cx_jolt_backend": "Jolt Physics",
				"cx_jolt_dss_a": "JoltPhysicsDirectSpaceState3D",
				"cx_jolt_dss_b": "JoltPhysicsDirectSpaceState3D",
				"cx_jolt_fetch_b": "JoltPhysicsDirectSpaceState3D",
				"cx_jolt_bds_a": "JoltPhysicsDirectBodyState3D",
				"cx_jolt_bds_b": "JoltPhysicsDirectBodyState3D",
				"cx_jolt_a_ne_b": "true",
				"cx_jolt_b_bound": "true",
				"cx_jolt_b_find": "true",
				"cx_jolt_ident_a": "true",
				"cx_jolt_ident_b": "true",
				"cx_jolt_cross_ident": "false",
				"cx_jolt_ray_a": "hit=-0.5000",
				"cx_jolt_ray_b": "hit=-10.5000",
				"cx_jolt_ray_fetch_b": "hit=-10.5000",
				"cx_jolt_fall_a": "1.6328",
				"cx_jolt_fall_b": "-8.2407",
				"cx_jolt_node_b_fall": "-8.2892",
				"cx_jolt_raw_fetch": "JoltPhysicsDirectSpaceState3D",
				"cx_jolt_raw_bds": "JoltPhysicsDirectBodyState3D",
				"cx_jolt_raw_ident": "true",
				"cx_jolt_raw_ray": "hit=1.0000",
				"cx_jolt_raw_moves": "2.0000",
				"cx_jolt_srv_box": "hit=1.0000",
				"cx_jolt_node_box": "hit=0.5000",
			}
			var expect_cx_dummy := {
				"cx_dummy_backend": "Dummy",
				"cx_dummy_dss_a": "PhysicsDirectSpaceState3DDummy",
				"cx_dummy_dss_b": "PhysicsDirectSpaceState3DDummy",
				"cx_dummy_fetch_b": "PhysicsDirectSpaceState3DDummy",
				"cx_dummy_bds_a": "PhysicsDirectBodyState3DDummy",
				"cx_dummy_bds_b": "PhysicsDirectBodyState3DDummy",
				"cx_dummy_a_ne_b": "false",
				"cx_dummy_b_bound": "true",
				"cx_dummy_b_find": "true",
				"cx_dummy_ident_a": "true",
				"cx_dummy_ident_b": "true",
				"cx_dummy_cross_ident": "true",
				"cx_dummy_ray_a": "miss",
				"cx_dummy_ray_b": "miss",
				"cx_dummy_ray_fetch_b": "miss",
				"cx_dummy_fall_a": "0.0000",
				"cx_dummy_fall_b": "0.0000",
				"cx_dummy_node_b_fall": "-8.0000",
				"cx_dummy_raw_fetch": "PhysicsDirectSpaceState3DDummy",
				"cx_dummy_raw_bds": "PhysicsDirectBodyState3DDummy",
				"cx_dummy_raw_ident": "true",
				"cx_dummy_raw_ray": "miss",
				"cx_dummy_raw_moves": "0.0000",
				"cx_dummy_srv_box": "miss",
				"cx_dummy_node_box": "miss",
			}
			for probe in [[cx_plain, expect_cx_plain, "plain"],
					[cx_jolt, expect_cx_jolt, "jolt"],
					[cx_dummy, expect_cx_dummy, "dummy"]]:
				var spawn: Dictionary = probe[0]
				if spawn["code"] != 0 or spawn["serr"] \
						or spawn["verdicts"] != probe[1]:
					return _fail("cross_space %s drift exit=%d serr=%s v=%s errs=%s"
							% [probe[2], spawn["code"], str(spawn["serr"]),
							str(spawn["verdicts"]), str(spawn["errs"])])
			_exit_ok("PASS phys3d_events cross_space two_world=answers raw=answers ident=per_space box=half,full jolt_raw=frozen child_exit=0")

		"joint_solver":
			# r89: the solver-priority write and the joint RID lifecycle.
			# `prio` is a control-vs-write pair in separate patches;
			# `clear` releases mid-run and re-makes on the same RID; `freed`
			# is three members on a free_rid'd joint — a typed null-parameter
			# refusal, a silent clear, and a make whose guard name is
			# backend-specific and counted from the raw log. Contrast with the
			# freed-SPACE family (r87/r88): a freed JOINT never crashes.
			if _gate("Jolt Physics", "joint_solver", "jolt"): return
			if _gate("Dummy", "joint_solver", "dummy"): return
			# the freed-joint witness class: the two member calls name the
			# `joint` parameter, the make call names it backend-specifically
			# (`prev_joint` on GodotPhysics, `old_joint` on Jolt) — each token
			# is counted in the raw log by the parent
			var js_allow := ["Parameter \"joint\" is null",
					"Parameter \"prev_joint\" is null",
					"Parameter \"old_joint\" is null"]
			var js_plain := _spawn_child("jsplainproj",
					_project_body("JsPlain", "", false), "js_plain", false,
					"res://phys3d_events.gd", 30, js_allow)
			if js_plain.has("err"):
				return _fail(js_plain["err"])
			var js_jolt := _spawn_child("jsjoltproj",
					_project_body("JsJolt", "Jolt Physics", false),
					"js_jolt", false, "res://phys3d_events.gd", 30, js_allow)
			if js_jolt.has("err"):
				return _fail(js_jolt["err"])
			var js_dummy := _spawn_child("jsdummyproj",
					_project_body("JsDummy", "Dummy", false), "js_dummy",
					false, "res://phys3d_events.gd", 30, js_allow)
			if js_dummy.has("err"):
				return _fail(js_dummy["err"])
			var expect_js_plain := {
				"js_plain_backend": "DEFAULT",
				"js_plain_prio_before": "1",
				"js_plain_prio_after": "32",
				"js_plain_ctl_gap": "0.8900",
				"js_plain_pri_gap": "0.6473",
				"js_plain_ctl_lv": "-0.0000",
				"js_plain_pri_lv": "11.6509",
				"js_plain_prio_effect": "jump",
				"js_plain_clear_gap_before": "0.8899",
				"js_plain_clear_lv_before": "-0.0000",
				"js_plain_clear_type_after": "5",
				"js_plain_clear_gap_same": "0.8899",
				"js_plain_clear_lv_next": "-0.1633",
				"js_plain_clear_gap_end": "0.9876",
				"js_plain_double_clear": "ok",
				"js_plain_remade_type": "0",
				"js_plain_freed_type": "0",
				"js_plain_freed_clear": "ok",
				"js_plain_freed_make": "ok",
			}
			var expect_js_jolt := {
				"js_jolt_backend": "Jolt Physics",
				"js_jolt_prio_before": "1",
				"js_jolt_prio_after": "1",
				"js_jolt_ctl_gap": "0.2032",
				"js_jolt_pri_gap": "0.2032",
				"js_jolt_ctl_lv": "0.0000",
				"js_jolt_pri_lv": "0.0000",
				"js_jolt_prio_effect": "none",
				"js_jolt_clear_gap_before": "0.2472",
				"js_jolt_clear_lv_before": "0.0000",
				"js_jolt_clear_type_after": "5",
				"js_jolt_clear_gap_same": "0.2472",
				"js_jolt_clear_lv_next": "-0.1633",
				"js_jolt_clear_gap_end": "0.8556",
				"js_jolt_double_clear": "ok",
				"js_jolt_remade_type": "0",
				"js_jolt_freed_type": "0",
				"js_jolt_freed_clear": "ok",
				"js_jolt_freed_make": "ok",
			}
			var expect_js_dummy := {
				"js_dummy_backend": "Dummy",
				"js_dummy_prio_before": "0",
				"js_dummy_prio_after": "0",
				"js_dummy_ctl_gap": "0.0000",
				"js_dummy_pri_gap": "0.0000",
				"js_dummy_ctl_lv": "0.0000",
				"js_dummy_pri_lv": "0.0000",
				"js_dummy_prio_effect": "none",
				"js_dummy_clear_gap_before": "0.0000",
				"js_dummy_clear_lv_before": "0.0000",
				"js_dummy_clear_type_after": "0",
				"js_dummy_clear_gap_same": "0.0000",
				"js_dummy_clear_lv_next": "0.0000",
				"js_dummy_clear_gap_end": "0.0000",
				"js_dummy_double_clear": "ok",
				"js_dummy_remade_type": "0",
				"js_dummy_freed_type": "0",
				"js_dummy_freed_clear": "ok",
				"js_dummy_freed_make": "ok",
			}
			for probe in [[js_plain, expect_js_plain, "plain"],
					[js_jolt, expect_js_jolt, "jolt"],
					[js_dummy, expect_js_dummy, "dummy"]]:
				var spawn: Dictionary = probe[0]
				if spawn["code"] != 0 or spawn["serr"] \
						or spawn["verdicts"] != probe[1]:
					return _fail("joint_solver %s drift exit=%d serr=%s v=%s errs=%s"
							% [probe[2], spawn["code"], str(spawn["serr"]),
							str(spawn["verdicts"]), str(spawn["errs"])])
			# the freed-joint refusal is a LOG witness: the two member calls
			# print the null-parameter line, and the make call's guard names a
			# DIFFERENT parameter per backend (GP `prev_joint`, Jolt
			# `old_joint`) — so a silently-nil call can never pass as a refusal
			# and the per-backend name is pinned where it belongs.
			for probe in [["jsplainproj", "prev_joint", "old_joint"],
					["jsjoltproj", "old_joint", "prev_joint"]]:
				var logp := ProjectSettings.globalize_path(
						"res://%s/child.log" % probe[0])
				if _log_count(logp, "Parameter \"joint\" is null.") != 2 \
						or _log_count(logp, probe[1]) != 1 \
						or _log_count(logp, probe[2]) != 0:
					return _fail("joint_solver %s freed witnesses null=%d %s=%d %s=%d"
							% [probe[0],
							_log_count(logp, "Parameter \"joint\" is null."),
							probe[1], _log_count(logp, probe[1]),
							probe[2], _log_count(logp, probe[2])])
			if _log_count(ProjectSettings.globalize_path(
					"res://jsdummyproj/child.log"),
					"Parameter \"joint\" is null.") != 0:
				return _fail("joint_solver dummy unexpected freed refusal")
			# the Jolt "ignored" write is not silent either: the engine emits
			# exactly one "Joint solver priority is not supported when using
			# Jolt Physics" WARNING per refused set; GP and Dummy emit none.
			if _log_count(ProjectSettings.globalize_path(
					"res://jsjoltproj/child.log"),
					"not supported when using Jolt Physics") != 1:
				return _fail("joint_solver jolt warnings drift")
			for dirname in ["jsplainproj", "jsdummyproj"]:
				if _log_count(ProjectSettings.globalize_path(
						"res://%s/child.log" % dirname),
						"not supported when using Jolt Physics") != 0:
					return _fail("joint_solver %s unexpected jolt warning"
							% dirname)
			_exit_ok("PASS phys3d_events joint_solver prio=honored,ignored clear=immediate reuse=true freed=refusal child_exit=0")

		_:
			return _fail("unknown arm " + arm)


# --child mode body: runs entirely inside the threaded project. Pins are
# engine-semantic (fetch legality, callable results), never wall-clock.
func _child_threaded() -> void:
	wspace = root.get_world_3d().space
	# (b) pre-physics process-context dss fetch: refused under threading.
	var early_null := PhysicsServer3D.space_get_direct_state(wspace) == null

	var wall := _mk_body(Vector3(0, 0, -3))
	var probe := _mk_body(Vector3.ZERO, PhysicsServer3D.BODY_MODE_KINEMATIC)
	await _frames(SETTLE)

	# (a) inside _physics_process: write -> ray/isect/cast/btm same tick.
	var w := PPQueries.new()
	w.wall = wall
	w.probe = probe
	w.wspace = wspace
	w.dss = null  # force the in-callback fetch path (the conversion)
	root.add_child(w)
	owned_nodes.append(w)
	var deadline := Engine.get_physics_frames() + 30
	while not w.printed and Engine.get_physics_frames() < deadline:
		await _frames(1)
	var pp_edge0 := w.result_ok()

	# (b) process-context fresh fetches: refused for the dss object.
	var nulls := 0
	for i in range(12):
		var d: PhysicsDirectSpaceState3D = PhysicsServer3D.space_get_direct_state(wspace)
		if d == null:
			nulls += 1
		await process_frame
	var proc_dss_refused := nulls >= 8

	# (d) server object-truth + body_test_motion still answer mid-frame
	# (the wall sits at z=-30 after the in-callback move).
	var g: Transform3D = PhysicsServer3D.body_get_state(wall,
			PhysicsServer3D.BODY_STATE_TRANSFORM)
	var params := PhysicsTestMotionParameters3D.new()
	params.from = Transform3D(Basis(), Vector3.ZERO)
	params.motion = Vector3(0, 0, -10)
	var res := PhysicsTestMotionResult3D.new()
	var rb := PhysicsServer3D.body_test_motion(probe, params, res)
	var srv_ok := absf(g.origin.z - (-30.0)) < 0.001 and not rb \
			and absf(res.get_travel().z - (-10.0)) < 0.0001

	# early_null is racy (the startup window sometimes grants the fetch) —
	# reported as a note, never pinned.
	prints("CHILD_NOTE early_null=%s" % str(early_null))
	prints("CHILD_RESULT pp_edge0=%s proc_dss_refused=%s srv_ok=%s"
			% [str(pp_edge0), str(proc_dss_refused), str(srv_ok)])
	_quit_clean()


# --child --arm=size_probe body (r86): this fixture's OWN bare deferred
# fetch, nothing else. The generated pair in the parent arm measures the
# gate; this child is the fixture's own witness, so a fixture that shrank
# below the boundary fails the arm loudly instead of silently refusing the
# fetch everywhere under threading (latent fixture fragility).
func _child_size() -> void:
	var d = root.get_world_3d().direct_space_state
	prints("CHILD_NOTE sp pf=%d null=%s" % [Engine.get_physics_frames(),
			str(d == null)])
	_quit_clean(0, "CHILD_RESULT sp_fetch=%s" % ("refused" if d == null else "granted"))


# --- r85: the generated-project child bodies share one sweep ---------------
# jolt_edge (r84), jolt_threaded and dummy_refused (r85) share `_child_split`:
# a class difference between the three receipts can never be a difference in
# the sweep code (the bodies differ only in engine key, threading flag,
# prefix, plus jolt_threaded's pre-sweep witness loop + allow_inaccessible —
# the r84 simplifier's deferred V2 fold, landed). Each reduced arm replays
# its parent cell's geometry, prints the raw fields as CHILD_NOTE
# (child.log evidence), then one
# `CHILD_RESULT <prefix>_<arm>=<class>` where class is
# same-signature (raw tuple equals the DEFAULT signature) |
# differs-constants (the edge/structure holds; settled constants match the
# signature measured on this build) | inverts (the cell's verdict flips —
# static_nopair fires under Jolt) | unexpected (outside both known
# signatures; fails the parent's compare loudly).


# --child --arm=jolt_edge body (r84): the reduced split sweep under a
# generated physics_engine="Jolt Physics" project.
func _child_jolt() -> void:
	await _child_split("jolt")


# --child --arm=jolt_threaded body (r85 cross-product): the same sweep under
# a generated project carrying BOTH physics_engine="Jolt Physics" AND
# 3d/run_on_separate_thread=true. The split is expected identical to
# jolt_edge (r85 scout §1.1 measured the child route byte-identical under
# threading); the extra pin is the threading witness, so a child whose
# run_on_separate_thread key was silently ignored fails loudly instead of
# reprinting the Jolt map as if the flag had taken effect.
func _child_jolt_threaded() -> void:
	# Threading witness, measured before the sweep: an explicit
	# process-context space_get_direct_state from an idle-frame continuation
	# is refused under run_on_separate_thread=true and granted without it
	# (r85 author probe: 11/12 null on Jolt+threaded, 0/12 on DEFAULT). The
	# >=8-of-12 tolerance mirrors the landed threaded_edge arm's
	# proc_dss_refused witness. The refusal ERRORs are this arm's expected
	# witness class, so the parent spawns it with allow_inaccessible=true.
	var nulls := 0
	for i in range(12):
		if PhysicsServer3D.space_get_direct_state(root.get_world_3d().space) == null:
			nulls += 1
		await process_frame
	prints("CHILD_RESULT jt_threaded=%s" % str(nulls >= 8))
	await _child_split("jt")


# --child --arm=dummy_refused body (r85 negative control): the same sweep
# under a generated physics_engine="Dummy" project. Dummy answers every
# query with zero/silent reads (r85 scout §2.2), so every arm must classify
# 'unexpected' — a known class here would mean the {same|differs|inverts}
# split is a map coincidence, not backend truth. No proc-context fetch loop
# on this body: the Dummy server silently hangs a threaded child (r85 scout
# §2.3, rc 137 at the 20 s bound).
func _child_dummy() -> void:
	await _child_split("dummy")


# The shared reduced sweep: runs entirely inside the generated child project,
# prints `CHILD_RESULT <prefix>_<arm>=<class>` per arm, and terminates the
# child (cleanup + quit(0)); a refused direct space state bails named with
# exit 1 rather than reading every arm blind.
func _child_split(prefix: String) -> void:
	wspace = root.get_world_3d().space
	dss = root.get_world_3d().direct_space_state
	if dss == null:
		# r85: the deferred _run() fetch is refused under threading more
		# often than the r85 scout's size ladder predicted (measured: the
		# jolt_threaded child was refused at this fixture size, 10/10
		# refusals in the author probe). Retry on a bounded physics-frame
		# budget — the position the engine grants under
		# run_on_separate_thread — instead of inheriting a startup race.
		for i in range(8):
			await physics_frame
			dss = root.get_world_3d().direct_space_state
			if dss != null:
				break
	var jolt_cls := ClassDB.class_exists("JoltPhysicsServer3D")
	var godot_cls := ClassDB.class_exists("GodotPhysicsServer3D")
	var engine := str(ProjectSettings.get_setting("physics/3d/physics_engine"))
	prints("CHILD_NOTE %s_class=%s godot_class=%s engine=%s"
			% [prefix, str(jolt_cls), str(godot_cls), engine])
	# The child must really be running Jolt: a silent backend fallback
	# would let GodotPhysics impersonate the split. The ClassDB pair
	# swaps exactly one member per backend on this build (r83 gate).
	prints("CHILD_RESULT %s_backend=%s"
			% [prefix, ("Dummy" if ClassDB.class_exists("PhysicsServer3DDummy")
					else ("Jolt Physics" if jolt_cls and not godot_cls
					else "unexpected"))])
	if dss == null:
		# a null handle would read every query arm as blind — bail named
		prints("CHILD_NOTE %s dss_null=true" % prefix)
		_quit_clean(1)
		return
	# r84 critic: the ClassDB pair is registry-level evidence; the live
	# space-state object's class is the active-backend witness and is
	# pinned in the parent's verdict map.
	prints("CHILD_RESULT %s_dss_class=%s" % [prefix, dss.get_class()])

	# <prefix>_isect: the isect arm's wall/sphere pair, both directions.
	var wall := _mk_body(Vector3(0, 0, -3))
	await _frames(SETTLE)
	var q := _sphere_params(Vector3(0, 0, -2.5))
	var qmask := _sphere_params(Vector3(0, 0, -2.5), Vector3.ZERO, 2)
	var s0 := dss.intersect_shape(q).size()
	var m0 := dss.intersect_shape(qmask).size()
	PhysicsServer3D.body_set_state(wall,
			PhysicsServer3D.BODY_STATE_TRANSFORM, Transform3D(Basis(), WALL_FAR))
	var away := dss.intersect_shape(q).size()
	await _frames(1)
	var away_n1 := dss.intersect_shape(q).size()
	PhysicsServer3D.body_set_state(wall,
			PhysicsServer3D.BODY_STATE_TRANSFORM,
			Transform3D(Basis(), Vector3(0, 0, -3)))
	var back := dss.intersect_shape(q).size()
	prints("CHILD_NOTE %s_isect s0=%d m0=%d away=%d n1=%d back=%d"
			% [prefix, s0, m0, away, away_n1, back])
	var cls := "unexpected"
	if s0 == 1 and m0 == 0 and away == 0 and away_n1 == 0 and back == 1:
		cls = "same-signature"
	elif s0 == 1 and back == 1:
		# r84 critic: differs-constants must stand on positive evidence --
		# a backend that returns nothing at all (Dummy) would otherwise
		# earn a known class from zero reads
		cls = "differs-constants"
	prints("CHILD_RESULT %s_isect=%s" % [prefix, cls])

	# <prefix>_cast: settled fractions are solver constants; the wall->far
	# edge to [1,1] is the lattice signature.
	await _frames(2)  # let the wall re-settle at -3 before the sample
	var qc := _sphere_params(Vector3.ZERO, Vector3(0, 0, -10))
	var c0 := dss.cast_motion(qc)
	PhysicsServer3D.body_set_state(wall,
			PhysicsServer3D.BODY_STATE_TRANSFORM, Transform3D(Basis(), WALL_FAR))
	var c1 := dss.cast_motion(qc)
	await _frames(1)
	var c2 := dss.cast_motion(qc)
	cls = "unexpected"
	if c0.size() < 2 or c1.size() < 2 or c2.size() < 2:
		# r84 critic/reviewer F2: a backend can return a size-0 pair --
		# indexing it aborts with a SCRIPT ERROR instead of classifying
		prints("CHILD_NOTE %s_cast degenerate sizes=%d,%d,%d"
				% [prefix, c0.size(), c1.size(), c2.size()])
	else:
		prints("CHILD_NOTE %s_cast safe=%.6f unsafe=%.6f w0=%.6f,%.6f n1=%.6f,%.6f"
				% [prefix, c0[0], c0[1], c1[0], c1[1], c2[0], c2[1]])
		var cast_edge := absf(c1[0] - 1.0) < 0.0001 \
				and absf(c1[1] - 1.0) < 0.0001 \
				and absf(c2[0] - 1.0) < 0.0001 and absf(c2[1] - 1.0) < 0.0001
		if cast_edge:
			if absf(c0[0] - 0.14453125) < 0.0001 \
					and absf(c0[1] - 0.150390625) < 0.0001:
				cls = "same-signature"
			elif absf(c0[0] - 0.14984130859375) < 0.0001 \
					and absf(c0[1] - 0.1500244140625) < 0.0001:
				cls = "differs-constants"
	prints("CHILD_RESULT %s_cast=%s" % [prefix, cls])

	# <prefix>_btm: kinematic probe vs the same wall (returned to -3); the
	# settled travel is a solver constant, the hit->miss edge the
	# signature.
	var probe := _mk_body(Vector3.ZERO, PhysicsServer3D.BODY_MODE_KINEMATIC)
	PhysicsServer3D.body_set_state(wall,
			PhysicsServer3D.BODY_STATE_TRANSFORM,
			Transform3D(Basis(), Vector3(0, 0, -3)))
	await _frames(SETTLE)
	var params := PhysicsTestMotionParameters3D.new()
	params.from = Transform3D(Basis(), Vector3.ZERO)
	params.motion = Vector3(0, 0, -10)
	var res := PhysicsTestMotionResult3D.new()
	var r0 := PhysicsServer3D.body_test_motion(probe, params, res)
	var t0: float = res.get_travel().z
	PhysicsServer3D.body_set_state(wall,
			PhysicsServer3D.BODY_STATE_TRANSFORM, Transform3D(Basis(), WALL_FAR))
	var res1 := PhysicsTestMotionResult3D.new()
	var r1 := PhysicsServer3D.body_test_motion(probe, params, res1)
	var t1: float = res1.get_travel().z
	await _frames(1)
	var res2 := PhysicsTestMotionResult3D.new()
	var r2 := PhysicsServer3D.body_test_motion(probe, params, res2)
	var t2: float = res2.get_travel().z
	prints("CHILD_NOTE %s_btm r0=%s t0=%.6f r1=%s t1=%.6f r2=%s t2=%.6f"
			% [prefix, str(r0), t0, str(r1), t1, str(r2), t2])
	cls = "unexpected"
	var btm_edge := r0 and not r1 and absf(t1 + 10.0) < 0.0001 \
			and not r2 and absf(t2 + 10.0) < 0.0001
	if btm_edge:
		if absf(t0 + 0.9765625) < 0.0001:
			cls = "same-signature"
		elif absf(t0 + 0.99853515625) < 0.0001:
			cls = "differs-constants"
	prints("CHILD_RESULT %s_btm=%s" % [prefix, cls])
	_cleanup_rids()

	# <prefix>_contact_stale: the two-tier discriminant; the contact count is
	# a solver constant, the stale->live pattern the signature.
	var floor_b := _mk_body(Vector3(0, -1, 0))
	var rig := _mk_body(Vector3(0, 8, 0), PhysicsServer3D.BODY_MODE_RIGID)
	PhysicsServer3D.body_set_param(rig,
			PhysicsServer3D.BODY_PARAM_GRAVITY_SCALE, 0.0)
	PhysicsServer3D.body_set_max_contacts_reported(rig, 8)
	await _frames(SETTLE)
	var set_c := _contacts(rig)
	var set_i := _floor_isect_hits(rig)
	PhysicsServer3D.body_set_state(rig,
			PhysicsServer3D.BODY_STATE_TRANSFORM,
			Transform3D(Basis(), Vector3(0, 0.5, 0)))
	var in_w0_c := _contacts(rig)
	var in_w0_i := _floor_isect_hits(rig)
	await _frames(1)
	var in_n1_c := _contacts(rig)
	PhysicsServer3D.body_set_state(rig,
			PhysicsServer3D.BODY_STATE_TRANSFORM,
			Transform3D(Basis(), Vector3(0, 8, 0)))
	var out_w0_c := _contacts(rig)
	await _frames(1)
	var out_n1_c := _contacts(rig)
	prints("CHILD_NOTE %s_contact_stale set=%d,%d in=%d,%d,%d out=%d,%d"
			% [prefix, set_c, set_i, in_w0_c, in_w0_i, in_n1_c, out_w0_c, out_n1_c])
	cls = "unexpected"
	var stale_pat := set_c == 0 and set_i == 1 and in_w0_c == 0 \
			and in_w0_i == 1 and in_n1_c > 0 and out_w0_c == in_n1_c \
			and out_n1_c == 0
	if stale_pat:
		cls = "same-signature" if in_n1_c == 4 else "differs-constants"
	prints("CHILD_RESULT %s_contact_stale=%s" % [prefix, cls])
	_cleanup_rids()

	# <prefix>_static_nopair: the known inverter. Under GodotPhysics the
	# teleported STATIC body stays silent (no pair, no signal) while the
	# area-move control fires at delta=1; under Jolt the same cell fires
	# at delta=1 (sig/ov at n1+, measured this round). sig_log is
	# cleared before the control so mv_delta reads fresh entries (the
	# r83 fold for critic C2's control-independence defect).
	var jarea := Area3D.new()
	var jashape := CollisionShape3D.new()
	var jabox := BoxShape3D.new()
	jabox.size = Vector3(4, 4, 4)
	jashape.shape = jabox
	jarea.add_child(jashape)
	jarea.collision_layer = 0
	jarea.collision_mask = 2
	jarea.monitoring = true
	jarea.body_entered.connect(func(_b):
		sig_log.append(Engine.get_physics_frames()))
	root.add_child(jarea)
	owned_nodes.append(jarea)
	var sshape := CollisionShape3D.new()
	var sbox := BoxShape3D.new()
	sbox.size = Vector3(1, 1, 1)
	sshape.shape = sbox
	var sbody := StaticBody3D.new()
	sbody.collision_layer = 2
	sbody.add_child(sshape)
	sbody.position = WALL_FAR
	root.add_child(sbody)
	owned_nodes.append(sbody)
	await _frames(SETTLE)
	var f_tp := Engine.get_physics_frames()
	sbody.position = Vector3.ZERO
	var tp := [sig_log.size(), jarea.get_overlapping_bodies().size()]
	await _frames(1)
	tp.append_array([sig_log.size(), jarea.get_overlapping_bodies().size()])
	await _frames(1)
	tp.append_array([sig_log.size(), jarea.get_overlapping_bodies().size()])
	await _frames(1)
	tp.append_array([sig_log.size(), jarea.get_overlapping_bodies().size()])
	var tp_delta: int = -1
	if sig_log.size() > 0:
		tp_delta = sig_log[0] - f_tp
	# control: move the area off then back on — fires on both backends.
	jarea.position = WALL_FAR
	await _frames(1)
	jarea.position = Vector3.ZERO
	sig_log.clear()
	var f_mv := Engine.get_physics_frames()
	await _frames(2)
	var mv_sig := sig_log.size()
	var mv_ov := jarea.get_overlapping_bodies().size()
	var mv_delta: int = -1
	if mv_sig > 0:
		mv_delta = sig_log[0] - f_mv
	prints("CHILD_NOTE %s_static_nopair tp=%d,%d,%d,%d,%d,%d,%d,%d delta=%d mv=%d,%d,%d"
			% [prefix, tp[0], tp[1], tp[2], tp[3], tp[4], tp[5], tp[6], tp[7],
			tp_delta, mv_sig, mv_ov, mv_delta])
	cls = "unexpected"
	var silent: bool = tp[0] == 0 and tp[1] == 0 and tp[6] == 0 and tp[7] == 0
	var fired: bool = tp[0] == 0 and tp[1] == 0 and tp[6] >= 1 and tp[7] == 1 \
			and tp_delta == 1
	if mv_sig > 0 and mv_delta == 1:
		if silent:
			cls = "same-signature"
		elif fired:
			cls = "inverts"
	prints("CHILD_RESULT %s_static_nopair=%s" % [prefix, cls])
	_quit_clean()


# --- r86: the backend tier sweep and the Dummy floor signature -------------
# Both bodies are spawned under more than one generated project, so a class
# difference can never be a code difference. Every read is Variant-typed and
# null-checked: an unguarded error inside the deferred _run coroutine is the
# hang class (the r86 deferred_hang arm), never a failure.


# The three-way backend gate. Exactly one member of the ClassDB trio exists
# per generated project on this build (measured r86: DEFAULT -> godot only,
# Jolt -> jolt only, Dummy -> dummy only). `_child_split` keeps its own
# frozen two-way expression: its receipts are pinned and it never runs under
# DEFAULT, so this is a different predicate, not a duplicate of it.
func _backend_name() -> String:
	if ClassDB.class_exists("PhysicsServer3DDummy"):
		return "Dummy"
	if ClassDB.class_exists("JoltPhysicsServer3D") \
			and not ClassDB.class_exists("GodotPhysicsServer3D"):
		return "Jolt Physics"
	if ClassDB.class_exists("GodotPhysicsServer3D"):
		return "DEFAULT"
	return "unexpected"


# --child --arm=tier_plain / tier_jolt / tier_dummy body (r86): the tier
# sweep. (a) area gravity + linear-damping override on a gravity_scale=1.0
# rigid body — the new inverter (GodotPhysics honours, Jolt ignores while
# the area parameter reads back, Dummy is the floor); (b) the shape-query
# `margin` — the mirror split (inert on GodotPhysics, honoured by Jolt,
# empty under Dummy); (c) the separation ray — the edge holds, the solver
# constants differ, Dummy has no data at all.
func _child_tier(prefix: String) -> void:
	wspace = root.get_world_3d().space
	prints("CHILD_RESULT %s_backend=%s" % [prefix, _backend_name()])
	dss = root.get_world_3d().direct_space_state
	if dss == null:
		# a non-threaded child grants this at _run; a refusal here would
		# read every arm blind, so retry bounded and then bail named
		for i in range(8):
			await physics_frame
			dss = root.get_world_3d().direct_space_state
			if dss != null:
				break
	if dss == null:
		prints("CHILD_NOTE %s dss_null=true" % prefix)
		_quit_clean(1)
		return
	prints("CHILD_RESULT %s_dss_class=%s" % [prefix, dss.get_class()])

	# (a) area override, measured on the body's own direct state
	var ashape := PhysicsServer3D.box_shape_create()
	PhysicsServer3D.shape_set_data(ashape, Vector3(40.0, 40.0, 40.0))
	var area := PhysicsServer3D.area_create()
	PhysicsServer3D.area_add_shape(area, ashape)
	PhysicsServer3D.area_set_collision_layer(area, 1)
	PhysicsServer3D.area_set_collision_mask(area, 1)
	PhysicsServer3D.area_set_space(area, wspace)
	PhysicsServer3D.area_set_transform(area, Transform3D(Basis(), Vector3.ZERO))
	owned.append_array([area, ashape])
	var rig := _mk_body(Vector3.ZERO, PhysicsServer3D.BODY_MODE_RIGID)
	await _frames(3)
	var b0 = PhysicsServer3D.body_get_direct_state(rig)
	var base_g := Vector3.ZERO
	var base_d := -1.0
	if b0 != null:
		base_g = b0.get_total_gravity()
		base_d = b0.get_total_linear_damp()
	PhysicsServer3D.area_set_param(area,
			PhysicsServer3D.AREA_PARAM_GRAVITY_OVERRIDE_MODE, 3)
	PhysicsServer3D.area_set_param(area, PhysicsServer3D.AREA_PARAM_GRAVITY, 20.0)
	PhysicsServer3D.area_set_param(area, PhysicsServer3D.AREA_PARAM_GRAVITY_VECTOR,
			Vector3(0, 1, 0))
	PhysicsServer3D.area_set_param(area,
			PhysicsServer3D.AREA_PARAM_LINEAR_DAMP_OVERRIDE_MODE, 3)
	PhysicsServer3D.area_set_param(area, PhysicsServer3D.AREA_PARAM_LINEAR_DAMP, 2.0)
	await _frames(2)
	var b1 = PhysicsServer3D.body_get_direct_state(rig)
	var ov_g := Vector3.ZERO
	var ov_d := -1.0
	if b1 != null:
		ov_g = b1.get_total_gravity()
		ov_d = b1.get_total_linear_damp()
	var area_g = PhysicsServer3D.area_get_param(area,
			PhysicsServer3D.AREA_PARAM_GRAVITY)
	prints("CHILD_NOTE %s_area base=%s/%.6f override=%s/%.6f area_readback=%s" % [
			prefix, str(base_g), base_d, str(ov_g), ov_d, str(area_g)])
	var cls := "unexpected"
	if ov_g.is_equal_approx(Vector3(0, 20, 0)) and absf(ov_d - 2.0) < 0.0001:
		cls = "honors"
	elif base_g.is_equal_approx(Vector3(0, -9.8, 0)) \
			and absf(base_d - 0.1) < 0.0001 \
			and ov_g.is_equal_approx(base_g) and absf(ov_d - base_d) < 0.0001 \
			and area_g != null and absf(float(area_g) - 20.0) < 0.0001:
		cls = "ignores"
	elif ov_g.is_equal_approx(Vector3.ZERO) and absf(ov_d) < 0.0001 \
			and area_g == null:
		cls = "floor"
	prints("CHILD_RESULT %s_area_override=%s" % [prefix, cls])

	# (b) shape-query margin on the `cast` arm's geometry (wall face z=-2)
	var wall := _mk_body(Vector3(0, 0, -3))
	await _frames(SETTLE)
	var casts := []
	for m in [0.0, 0.04, 0.5]:
		var s := SphereShape3D.new()
		s.radius = 0.5
		var p := PhysicsShapeQueryParameters3D.new()
		p.shape = s
		p.transform = Transform3D(Basis(), Vector3.ZERO)
		p.motion = Vector3(0, 0, -10)
		p.collision_mask = 1
		p.collide_with_bodies = true
		p.margin = m
		casts.append(dss.cast_motion(p))
	prints("CHILD_NOTE %s_margin m0=%s m004=%s m05=%s" % [
			prefix, str(casts[0]), str(casts[1]), str(casts[2])])
	cls = "unexpected"
	if casts[0].size() == 0 and casts[1].size() == 0 and casts[2].size() == 0:
		cls = "empty"
	elif casts[0].size() >= 2 and casts[1].size() >= 2 and casts[2].size() >= 2:
		var same01 := absf(casts[0][0] - casts[1][0]) < 0.0001
		var same12 := absf(casts[1][0] - casts[2][0]) < 0.0001
		if same01 and same12:
			cls = "inert"
		elif not same01 and not same12 and casts[0][0] > casts[1][0] \
				and casts[1][0] > casts[2][0]:
			cls = "binds"
	prints("CHILD_RESULT %s_margin=%s" % [prefix, cls])

	# (c) separation ray: the data form and the solver constants
	var sep: RID = PhysicsServer3D.separation_ray_shape_create()
	PhysicsServer3D.shape_set_data(sep, {"length": 2.0, "slide_on_slope": false})
	owned.append(sep)
	var sep_data = PhysicsServer3D.shape_get_data(sep)
	var sep_type := PhysicsServer3D.shape_get_type(sep)
	var sr := PhysicsShapeQueryParameters3D.new()
	sr.shape_rid = sep
	sr.transform = Transform3D(Basis(), Vector3.ZERO)
	sr.motion = Vector3(0, 0, -10)
	sr.collision_mask = 1
	sr.collide_with_bodies = true
	var sep_cast := dss.cast_motion(sr)
	prints("CHILD_NOTE %s_sepray data=%s type=%d cast=%s" % [
			prefix, str(sep_data), sep_type, str(sep_cast)])
	cls = "unexpected"
	if sep_data == null:
		cls = "floor"
	elif sep_cast.size() >= 2:
		if absf(sep_cast[0] - 0.197265625) < 0.0001:
			cls = "same-signature"
		elif absf(sep_cast[0] - 0.1998291015625) < 0.0001:
			cls = "differs-constants"
	prints("CHILD_RESULT %s_sepray=%s" % [prefix, cls])
	_quit_clean()


# --child --arm=floor_dummy / floor_real body (r86): the Dummy silent floor
# as an 11-token signature, with the identical body under a real backend as
# the refusal contrast. Tokens are printed, never inferred. Two calls in
# here are loud refusals on a real backend and silent no-ops under Dummy —
# that pair is the whole class distinction, so "silent floor" can never be
# read as "refusal".
func _child_floor(prefix: String) -> void:
	wspace = root.get_world_3d().space
	prints("CHILD_RESULT %s_backend=%s" % [prefix, _backend_name()])
	var shape: RID = PhysicsServer3D.box_shape_create()
	PhysicsServer3D.shape_set_data(shape, Vector3(1.0, 1.0, 1.0))
	var shape_data = PhysicsServer3D.shape_get_data(shape)
	var shape_type := PhysicsServer3D.shape_get_type(shape)
	var fresh: RID = PhysicsServer3D.space_create()
	var space_param = PhysicsServer3D.space_get_param(fresh,
			PhysicsServer3D.SPACE_PARAM_SOLVER_ITERATIONS)
	var dss_rid0 = PhysicsServer3D.space_get_direct_state(RID())
	var rig := _mk_body(Vector3(0, 5, 0), PhysicsServer3D.BODY_MODE_RIGID)
	var area: RID = PhysicsServer3D.area_create()
	PhysicsServer3D.area_set_space(area, wspace)
	PhysicsServer3D.area_add_shape(area, shape)
	owned.append_array([shape, fresh, area])
	await _frames(2)
	var b_state = PhysicsServer3D.body_get_state(rig,
			PhysicsServer3D.BODY_STATE_TRANSFORM)
	var b_param = PhysicsServer3D.body_get_param(rig,
			PhysicsServer3D.BODY_PARAM_GRAVITY_SCALE)
	var b_count := PhysicsServer3D.body_get_shape_count(rig)
	var b_shape = PhysicsServer3D.body_get_shape(rig, 0)
	var a_param = PhysicsServer3D.area_get_param(area,
			PhysicsServer3D.AREA_PARAM_GRAVITY)
	# the two loud refusals on a real backend, silent no-ops here
	PhysicsServer3D.free_rid(RID())
	var tokens := PackedStringArray([
		"rid0" if str(shape) == "RID(0)" else "rid",
		"nil" if shape_data == null else "v3",
		str(shape_type),
		"rid0" if str(fresh) == "RID(0)" else "rid",
		("nil" if space_param == null else
				("zero" if float(space_param) == 0.0 else "pos")),
		"dummy" if dss_rid0 != null else "nil",
		"nil" if b_state == null else "xform",
		"nil" if b_param == null else "value",
		str(b_count),
		"rid0" if str(b_shape) == "RID(0)" else "rid",
		"nil" if a_param == null else "value",
	])
	prints("CHILD_NOTE %s_floor tokens=%s" % [prefix, str(tokens)])
	# r86 critic A5: solver_iterations is a TUNEABLE project default — pin
	# the zero-vs-positive axis (Dummy floor = 0.0, real backend = whatever
	# positive default/tuning), not the engine's literal 16.0, or a host
	# with solver_iterations=8 fails as "refusal drift".
	var floor_sig := PackedStringArray(["rid0", "nil", "2", "rid0", "zero",
			"dummy", "nil", "nil", "0", "rid0", "nil"])
	var real_sig := PackedStringArray(["rid", "v3", "3", "rid", "pos",
			"nil", "xform", "value", "1", "rid", "value"])
	var cls := "unexpected"
	if tokens == floor_sig:
		cls = "silent-floor"
	elif tokens == real_sig:
		cls = "real-values"
	prints("CHILD_RESULT %s_floor=%s" % [prefix, cls])
	_quit_clean()


# --- r87: the body-tier deferred-state arms ---------------------------------
# Six arms over the PhysicsDirectBodyState3D tier, every one of them a
# generated-project CHILD: the laws are backend-scoped, and the crash class
# must kill a child process, never the fixture. All reads are Variant-typed
# and null-checked — an unguarded deref inside a deferred coroutine is the
# r86 hang class, never a failure (and the Dummy backend returns Nil for
# reads a real backend answers, so the guard is load-bearing there too).


# The RigidBody3D the identity law needs: the callback receives the engine's
# own handle, and the law is that a fresh fetch inside the callback returns
# the SAME object.
class BHBody extends RigidBody3D:
	var fired := false
	var same_obj := false
	var state_obj: Variant = null

	func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
		if fired:
			return
		fired = true
		same_obj = PhysicsServer3D.body_get_direct_state(get_rid()) == state
		state_obj = state


# --child --arm=bh_plain / bh_jolt / bh_dummy (r87): the held-handle identity
# law. (1) inside RigidBody3D._integrate_forces the fresh fetch IS the handle
# the callback was handed; (2) body_set_state_sync_callback sees the same
# object every tick; (3) a handle obtained once survives detach
# (body_set_space(RID()) -> refetch nil, the held handle still reads the last
# transform) and reattach (refetch == the held handle); (4) get_space_state()
# on the handle is the SAME object as space_get_direct_state and
# World3D.direct_space_state. Dummy is the floor: neither callback ever fires
# and the fetch answers for a detached RID, so the law is real-backend-only
# and a Dummy child can never witness it (scout directive 8).
func _child_bh_identity(prefix: String) -> void:
	wspace = root.get_world_3d().space
	var rb := BHBody.new()
	var cs := CollisionShape3D.new()
	var bx := BoxShape3D.new()
	bx.size = Vector3(1, 1, 1)
	cs.shape = bx
	rb.add_child(cs)
	rb.gravity_scale = 0.0
	rb.position = Vector3(0, 4, 0)
	root.add_child(rb)
	owned_nodes.append(rb)
	await _frames(6)
	var if_held: Variant = rb.state_obj
	var if_refetch := false
	if if_held != null:
		if_refetch = PhysicsServer3D.body_get_direct_state(rb.get_rid()) == if_held
	var srig := _mk_body(Vector3(0, 12, 0), PhysicsServer3D.BODY_MODE_RIGID)
	PhysicsServer3D.body_set_param(srig,
			PhysicsServer3D.BODY_PARAM_GRAVITY_SCALE, 0.0)
	await _frames(2)
	var held: Variant = PhysicsServer3D.body_get_direct_state(srig)
	var ss := {"fired": 0, "same": 0}
	PhysicsServer3D.body_set_state_sync_callback(srig, func(st):
		ss["fired"] += 1
		if PhysicsServer3D.body_get_direct_state(srig) == st:
			ss["same"] += 1)
	await _frames(4)
	var detach_nil := false
	var held_live := false
	var reattach_same := false
	var twin := false
	if held != null:
		var t_before: Transform3D = held.get_transform()
		PhysicsServer3D.body_set_space(srig, RID())
		detach_nil = PhysicsServer3D.body_get_direct_state(srig) == null
		# a detached body does not step, so the held handle must still read
		# the SAME transform it read before the detach. r87 critic F5
		# caveat: this is a FROZEN-READ witness — a zombie handle serving
		# stale state satisfies it — not a liveness proof; the fs arm is
		# the row that probes read-past-lifetime.
		held_live = held.get_transform() == t_before
		PhysicsServer3D.body_set_space(srig, wspace)
		await _frames(1)
		reattach_same = PhysicsServer3D.body_get_direct_state(srig) == held
		var sp: Variant = held.get_space_state()
		twin = sp == PhysicsServer3D.space_get_direct_state(wspace) \
				and sp == root.get_world_3d().direct_space_state
	_note(prefix, "if_fired=%s if_same=%s if_refetch=%s ss=%d/%d detach_nil=%s held_live=%s reattach_same=%s twin=%s" % [str(rb.fired), str(rb.same_obj), str(if_refetch), ss["fired"], ss["same"], str(detach_nil), str(held_live), str(reattach_same), str(twin)])
	_emit(prefix, "backend", str(_backend_name()))
	_emit(prefix, "if_same", str(rb.same_obj and if_refetch))
	_emit(prefix, "ss_same", str(ss["fired"] > 0 and ss["fired"] == ss["same"]))
	# r87 critic F5: `ss_same` alone never saw the fired count — a backend
	# whose callbacks fire with a DIFFERENT object still reads ss_same=false,
	# so `dummy_cb=never` needed the count itself. Bucketed (0 vs >0): the
	# real-backend count is scheduling-dependent, the floor's is not.
	_emit(prefix, "ss_fired", "0" if ss["fired"] == 0 else ">0")
	# r88 scribe F5 completion: the integrate-forces half of dummy_cb=never
	# earns the same bucketed pin — a Dummy that fires ONLY _integrate_forces
	# would otherwise pass on ss_fired=0 alone.
	_emit(prefix, "if_fired", "0" if not rb.fired else ">0")
	_emit(prefix, "detach", str("nil" if detach_nil else "obj"))
	_emit(prefix, "held_live", str(held_live))
	_emit(prefix, "reattach", str(reattach_same))
	_emit(prefix, "twin", str(twin))
	_quit_clean()


# --child --arm=au_plain / au_jolt (r87): acquisition vs use. A handle is
# acquired at a legal (physics-frame) position, then exercised at BODY_REPS
# process-frame positions where a FRESH fetch is refused: the held handle's
# read is compared against the server read at the same instant, its write is
# read back through itself (same turn) and through the server at the next
# in-phase position (persistence). The refused fetch is the arm's expected
# witness class, so the parent spawns this child with allow_lines.
func _child_acq_use(prefix: String) -> void:
	wspace = root.get_world_3d().space
	var rig := _mk_body(Vector3(0, 8, 0), PhysicsServer3D.BODY_MODE_RIGID)
	PhysicsServer3D.body_set_param(rig,
			PhysicsServer3D.BODY_PARAM_GRAVITY_SCALE, 0.0)
	var held: Variant = null
	for i in range(24):
		await physics_frame
		held = PhysicsServer3D.body_get_direct_state(rig)
		if held != null:
			break
	if held == null:
		_note(prefix, "held=nil")
		_quit_clean(1)
		return
	var out_of_phase := 0
	var refused := 0
	var live := 0
	var same_turn := 0
	var persist := 0
	for i in range(BODY_REPS):
		await process_frame
		if not Engine.is_in_physics_frame():
			out_of_phase += 1
		if PhysicsServer3D.body_get_direct_state(rig) == null:
			refused += 1
		var srv_lv: Variant = PhysicsServer3D.body_get_state(rig,
				PhysicsServer3D.BODY_STATE_LINEAR_VELOCITY)
		if srv_lv != null and Vector3(srv_lv) == held.get_linear_velocity():
			live += 1
		held.set_linear_velocity(Vector3(0, 20.0 + i, 0))
		if absf(held.get_linear_velocity().y - (20.0 + i)) < 0.0001:
			same_turn += 1
		held.set_transform(Transform3D(Basis(), Vector3(0, 30.0 + i, 0)))
		await physics_frame
		var srv_t: Variant = PhysicsServer3D.body_get_state(rig,
				PhysicsServer3D.BODY_STATE_TRANSFORM)
		if srv_t is Transform3D \
				and absf(srv_t.origin.y - (30.0 + i)) < 0.0001:
			persist += 1
	_note(prefix, "reps=%d out_of_phase=%d refused=%d live=%d same_turn=%d persist=%d" % [BODY_REPS, out_of_phase, refused, live, same_turn, persist])
	_emit(prefix, "backend", str(_backend_name()))
	_emit(prefix, "gate", str("refused" if refused == BODY_REPS else "granted"))
	_emit(prefix, "use", str("ungated" if live == BODY_REPS and same_turn == BODY_REPS
					and persist == BODY_REPS else "gated"))
	_emit(prefix, "out_of_phase", "%d" % [out_of_phase])
	_quit_clean()


# --child --arm=ss_plain / ss_jolt (r87): the object's own flush seams.
# The PRE reads happen in this deferred child dispatch, before the first solve
# completes (the r86/r87 phase map's position B), and the POST reads after the
# body has fallen into contact. get_step is step-stamped on both real
# backends; gravity/damp only on GodotPhysics. The contact buffer is last-step
# data and needs body_set_max_contacts_reported > 0 to report anything.
func _child_step_stamp(prefix: String) -> void:
	wspace = root.get_world_3d().space
	var floor_b := _mk_body(Vector3(0, -1, 0))
	var rig := _mk_body(Vector3(0, 2.2, 0), PhysicsServer3D.BODY_MODE_RIGID)
	PhysicsServer3D.body_set_state(rig,
			PhysicsServer3D.BODY_STATE_CAN_SLEEP, false)
	var s0: Variant = PhysicsServer3D.body_get_direct_state(rig)
	var pre_step := -1.0
	var pre_grav := "absent"
	var pre_damp := -1.0
	if s0 != null:
		pre_step = s0.get_step()
		pre_grav = "zero" if s0.get_total_gravity().is_equal_approx(
				Vector3.ZERO) else "real"
		pre_damp = s0.get_total_linear_damp()
	# default max_contacts_reported is 0: a body resting on the floor reports
	# NO contacts at all until it opts in
	await _frames(90)
	var s1: Variant = PhysicsServer3D.body_get_direct_state(rig)
	var cc_off: int = s1.get_contact_count() if s1 != null else -1
	PhysicsServer3D.body_set_max_contacts_reported(rig, 8)
	await _frames(2)
	var s2: Variant = PhysicsServer3D.body_get_direct_state(rig)
	var cc_on: int = s2.get_contact_count() if s2 != null else -1
	var post_step := -1.0
	var post_damp := -1.0
	var stale_w0 := -1
	var stale_n1 := -1
	if s2 != null:
		post_step = s2.get_step()
		post_damp = s2.get_total_linear_damp()
		# last-step data: teleport out of contact -> the count still reads
		# the last step's value, and clears only on the next step
		PhysicsServer3D.body_set_state(rig,
				PhysicsServer3D.BODY_STATE_TRANSFORM,
				Transform3D(Basis(), Vector3(0, 8, 0)))
		stale_w0 = s2.get_contact_count()
		await _frames(1)
		stale_n1 = s2.get_contact_count()
	_note(prefix, "pre=%s/%s/%s off=%d on=%d post=%s/%s stale=%d,%d" % [str(pre_step), pre_grav, str(pre_damp), cc_off, cc_on, str(post_step), str(post_damp), stale_w0, stale_n1])
	_emit(prefix, "backend", str(_backend_name()))
	_emit(prefix, "step_pre", str(pre_step))
	_emit(prefix, "grav_pre", str(pre_grav))
	_emit(prefix, "damp_pre", str(pre_damp))
	_emit(prefix, "step_post", str(post_step))
	_emit(prefix, "damp_post", str(post_damp))
	_emit(prefix, "cc_off", "%d" % [cc_off])
	_emit(prefix, "cc_on", "%d" % [cc_on])
	_emit(prefix, "last_step", "%d,%d" % [stale_w0, stale_n1])
	_quit_clean()


# --child --arm=wl_plain (r87): the out-of-phase held-handle write, as a
# BOUNDED repeated observation. Each rep re-arms the body in phase (awake,
# moving), issues set_sleep_state(true) through the held handle at a
# process-frame position where a fresh fetch is refused, reads the handle back
# same-turn (was the write applied at all?) and reads the server at the next
# in-phase position (did it survive the step?). landed/lost are the tally the
# parent accounts; the split is evidence, never a pinned per-rep outcome —
# the write path is unsynchronized, so the class is a race class.
func _child_write_loss(prefix: String) -> void:
	wspace = root.get_world_3d().space
	var rig := _mk_body(Vector3(0, 8, 0), PhysicsServer3D.BODY_MODE_RIGID)
	PhysicsServer3D.body_set_param(rig,
			PhysicsServer3D.BODY_PARAM_GRAVITY_SCALE, 0.0)
	PhysicsServer3D.body_set_state(rig,
			PhysicsServer3D.BODY_STATE_CAN_SLEEP, false)
	var held: Variant = null
	for i in range(24):
		await physics_frame
		held = PhysicsServer3D.body_get_direct_state(rig)
		if held != null:
			break
	if held == null:
		_note(prefix, "held=nil")
		_quit_clean(1)
		return
	var refused := 0
	var same_turn := 0
	var landed := 0
	var lost := 0
	var rows := []
	for i in range(BODY_REPS):
		await physics_frame
		held.set_sleep_state(false)
		held.set_linear_velocity(Vector3(0, 5, 0))
		await physics_frame
		await process_frame
		if PhysicsServer3D.body_get_direct_state(rig) == null:
			refused += 1
		held.set_sleep_state(true)
		var same: bool = held.is_sleeping()
		if same:
			same_turn += 1
		await physics_frame
		var srv: Variant = PhysicsServer3D.body_get_state(rig,
				PhysicsServer3D.BODY_STATE_SLEEPING)
		if srv == true:
			landed += 1
		else:
			lost += 1
		rows.append("%d:%s>%s" % [i, "T" if same else "F", str(srv)])
	_note(prefix, "reps=%d refused=%d same_turn=%d landed=%d lost=%d rows=%s" % [BODY_REPS, refused, same_turn, landed, lost, str(rows)])
	_emit(prefix, "backend", str(_backend_name()))
	_emit(prefix, "gate", str("refused" if refused == BODY_REPS else "granted"))
	_emit(prefix, "same_turn", "%d" % [same_turn])
	_emit(prefix, "landed", "%d" % [landed])
	_emit(prefix, "lost", "%d" % [lost])
	_quit_clean()


# --child --arm=bt_plain / bt_jolt / bt_dummy (r87): the backend split at the
# body tier. The impulse cell is read at the FIRST in-contact step in the
# r87-scout-dss `mm_*` geometry (floor at y=0, rigid at 2.2): on GodotPhysics
# that step reads exactly (0,0,0) and on Jolt the real impact impulse. The
# same field OSCILLATES through zero on GodotPhysics at later steps in other
# geometries (measured: a 40-frame series with the floor at y=-1 reads
# (0,0,0) at two steps and up to 0.103 at others), so the row claims the
# first-in-contact-step split only — never "GodotPhysics is always zero".
func _child_body_tier(prefix: String) -> void:
	wspace = root.get_world_3d().space
	var floor_b := _mk_body(Vector3(0, 0, 0))
	var rig := _mk_body(Vector3(0, 2.2, 0), PhysicsServer3D.BODY_MODE_RIGID)
	PhysicsServer3D.body_set_max_contacts_reported(rig, 8)
	PhysicsServer3D.body_set_state(rig,
			PhysicsServer3D.BODY_STATE_CAN_SLEEP, false)
	var st: Variant = null
	var first_i := -1
	for i in range(60):
		await physics_frame
		st = PhysicsServer3D.body_get_direct_state(rig)
		if st != null and st.get_contact_count() > 0:
			first_i = i
			break
	var cc := -1
	var impulse := "nil"
	var impulse_raw := "-"
	var lshape_oob := "absent"
	var sleep_lv := "absent"
	if st != null:
		cc = st.get_contact_count()
		if cc > 0:
			var imp: Vector3 = st.get_contact_impulse(0)
			impulse_raw = "%.9f,%.9f,%.9f" % [imp.x, imp.y, imp.z]
			impulse = "zero" if imp.length() < 0.000001 else "real"
			lshape_oob = str(st.get_contact_local_shape(cc + 5))
		st.set_linear_velocity(Vector3(0, 44.0, 0))
		var kept: float = st.get_linear_velocity().y
		st.set_sleep_state(true)
		var after: float = st.get_linear_velocity().y
		# `flat` is the Dummy floor: the value never moved, so there was
		# nothing to keep or zero (a zero-vs-zero read must not earn the
		# real-backend "kept" token)
		if absf(kept) < 0.0001 and absf(after) < 0.0001:
			sleep_lv = "flat"
		elif absf(after - kept) < 0.0001:
			sleep_lv = "kept"
		else:
			sleep_lv = "zeroed"
	# detached-body impulse write: silent no-op on GodotPhysics, a LOUD
	# refusal on Jolt (the parent counts the engine's line in the raw log)
	var rig2 := _mk_body(Vector3(20, 8, 0), PhysicsServer3D.BODY_MODE_RIGID)
	PhysicsServer3D.body_set_param(rig2,
			PhysicsServer3D.BODY_PARAM_GRAVITY_SCALE, 0.0)
	await _frames(1)
	var held2: Variant = PhysicsServer3D.body_get_direct_state(rig2)
	PhysicsServer3D.body_set_space(rig2, RID())
	if held2 != null:
		held2.apply_central_impulse(Vector3(0, 1, 0))
	PhysicsServer3D.body_set_space(rig2, wspace)
	_note(prefix, "first_i=%d cc=%d impulse=%s lshape_oob=%s sleep_lv=%s detach_write=done" % [first_i, cc, impulse_raw, lshape_oob, sleep_lv])
	_emit(prefix, "backend", str(_backend_name()))
	_emit(prefix, "cc", "%d" % [cc])
	_emit(prefix, "impulse", str(impulse))
	_emit(prefix, "lshape_oob", str(lshape_oob))
	_emit(prefix, "sleep_lv", str(sleep_lv))
	_quit_clean()


# --child --arm=fs_plain / fs_jolt / fs_dummy (r87): the freed-SPACE crash
# cell, and the last thing this file does — a crash cannot be caught, so the
# child dies and the parent pins the log envelope. The body handle is
# fetched first (the crash is not the body handle: freed BODY handles degrade
# to silent nulls), then the world space is free_rid'd, then the space-state
# object reached THROUGH the body handle is queried. On this host the crash
# site is backend-specific: GodotPhysics dies inside `held.get_space_state()`
# below (the `space=` note never prints), Jolt survives that call and dies at
# `sp.intersect_ray`. Jolt's crash mode is heap-layout dependent (uncaught
# std::system_error or the same handler), Dummy answers an empty dict and
# exits 0.
func _child_freed_space(prefix: String) -> void:
	wspace = root.get_world_3d().space
	var rig := _mk_body(Vector3(0, 8, 0), PhysicsServer3D.BODY_MODE_RIGID)
	PhysicsServer3D.body_set_param(rig,
			PhysicsServer3D.BODY_PARAM_GRAVITY_SCALE, 0.0)
	await _frames(2)
	var held: Variant = PhysicsServer3D.body_get_direct_state(rig)
	_note(prefix, "held=%s" % ["nil" if held == null else held.get_class()])
	PhysicsServer3D.free_rid(wspace)
	var sp: Variant = held.get_space_state() if held != null else null
	_note(prefix, "space=%s" % ["nil" if sp == null else str(sp)])
	if sp != null and sp is PhysicsDirectSpaceState3D:
		var q := PhysicsRayQueryParameters3D.create(
				Vector3(0, 10, 0), Vector3(0, -10, 0))
		var hit: Variant = sp.intersect_ray(q)
		_note(prefix, "ray_empty=%s" % [str(hit.is_empty())])
		_emit(prefix, "ray", str("empty" if hit.is_empty() else "hits"))
		_quit_clean()
		return
	_emit(prefix, "ray", "nospace")
	_quit_clean()


# r87 simplifier: one BLOCKED gate for every arm (the r86 SP2 shape at the
# other repeated exit). The engine hint is reported verbatim in the gate's own
# line; the caller returns, so an absent backend can never fall through into a
# fabricated split.
func _gate(engine: String, arm: String, token: String) -> bool:
	if _engine_hint_has(engine):
		return false
	_quit_clean(1, "BLOCKED phys3d_events %s %s_absent=true" % [arm, token])
	return true


# r87 simplifier: one emitter for every child verdict/note line, so the
# "CHILD_RESULT <prefix>_<key>=<value>" / "CHILD_NOTE <prefix> <text>" shapes
# exist once (the r86 SP1 rule: no second convention). Text-identical: the
# same format string with the same args is formatted by the same `prints`
# call inside the helper.
func _emit(prefix: String, key: String, value: String) -> void:
	prints("CHILD_RESULT %s_%s=%s" % [prefix, key, value])


func _note(prefix: String, text: String) -> void:
	prints("CHILD_NOTE %s %s" % [prefix, text])


# --- r88: the query-tier read family (child bodies) --------------------------
# Every arm below is a generated-project CHILD: the laws are backend-scoped,
# the freed-space class kills a child process, and the gate/race cells are
# position-determined inside a live tree. Geometry is the r87/r88 canonical
# pair — wall box (half 1) at (0,0,-3), floor box (half 1) at (0,-1,0) with
# its top at y=0 — so the in-place contact controls are the floor (a sphere at
# (0,0,-1) overlaps the floor slab, never the wall) and the wall is reached
# only by motion.

# The `_physics_process` / `_process` sampler the gate, inactive-space and
# race children share: one node, one mode, the probe's `_q_sample` measures.
# `f_max` bounds the out-of-phase (`_process`) firings; `_physics_process`
# fires once (the in-phase control). One class, not three (r86 SP1).
class QNode extends Node:
	var probe
	var q_mode := "fetch"
	var f_max := 1
	var f_seen := 0
	var e_seen := 0

	func _physics_process(_d: float) -> void:
		if e_seen == 0:
			e_seen = 1
			probe._q_sample(q_mode, "E")

	func _process(_d: float) -> void:
		if f_seen < f_max:
			f_seen += 1
			probe.q_f_seen = f_seen
			probe._q_sample(q_mode, "F")


func _add_qnode(mode: String, f_max: int) -> void:
	var n := QNode.new()
	n.probe = self
	n.q_mode = mode
	n.f_max = f_max
	root.add_child(n)
	owned_nodes.append(n)


# One dispatcher so the three sampler modes cannot drift apart.
func _q_sample(mode: String, tag: String) -> void:
	match mode:
		"fetch":
			_sample_fetch(tag)
		"inactive":
			_sample_inactive(tag)
		"race":
			_sample_race(tag)


# --child --arm=mo_plain / mo_jolt / mo_dummy (r88): the motion split.
# ONE PhysicsShapeQueryParameters3D per geometry, reused across the four
# methods that accept it. cast_motion APPLIES motion (a fraction strictly
# inside (0,1), and a start overlap does NOT pin it to 0); collide_shape /
# get_rest_info / intersect_shape ignore it — the clear-start -2z sweep that
# ENDS embedded in the wall reports nothing, while the in-place controls
# answer. The wall-contact bracket is a per-backend envelope: GodotPhysics
# widens around the geometric 0.1 by its margin handling, Jolt lands tight.
func _child_motion_split(prefix: String) -> void:
	wspace = root.get_world_3d().space
	_mk_body(Vector3(0, 0, -3))
	_mk_body(Vector3(0, -1, 0))
	await _frames(4)
	var d: Variant = await _fetch_world_dss()
	if d == null:
		_note(prefix, "dss=nil")
		_quit_clean(1)
		return
	var clear := _sphere_params(Vector3(0, 0.6, -1.0), Vector3(0, 0, -5.0))
	var pen := _sphere_params(Vector3(0, 0, -1.0), Vector3(0, 0, -5.0))
	var away := _sphere_params(Vector3(0, 0, -1.0), Vector3(0, 0, 5.0))
	var zero := _sphere_params(Vector3(0, 0.6, -1.0), Vector3.ZERO)
	var short := _sphere_params(Vector3(0, 0.6, -1.0), Vector3(0, 0, -0.5))
	var sweep := _sphere_params(Vector3(0, 0.6, -1.0), Vector3(0, 0, -2.0))
	var inplace := _sphere_params(Vector3(0, 0, -2.2))
	var cm_clear: Variant = d.cast_motion(clear)
	var cm_pen: Variant = d.cast_motion(pen)
	var cm_away: Variant = d.cast_motion(away)
	var cm_shared: Variant = d.cast_motion(sweep)
	var cm_zero: Variant = d.cast_motion(zero)
	var cm_short: Variant = d.cast_motion(short)
	var cs_sweep: Variant = d.collide_shape(sweep)
	var cs_inplace: Variant = d.collide_shape(inplace)
	var ri_sweep: Variant = d.get_rest_info(sweep)
	var ri_inplace: Variant = d.get_rest_info(inplace)
	var is_sweep: Variant = d.intersect_shape(sweep)
	var is_inplace: Variant = d.intersect_shape(inplace)
	var cm_tok := "empty"
	var bracket := "drift"
	var pen_tok := "empty"
	var lo := -1.0
	var hi := -1.0
	if cm_clear is PackedFloat32Array and cm_clear.size() >= 2:
		lo = minf(cm_clear[0], cm_clear[1])
		hi = maxf(cm_clear[0], cm_clear[1])
		if lo > 0.0 and hi < 1.0:
			cm_tok = "honored"
		else:
			cm_tok = "blocked"
		if hi - lo <= 0.002 and lo >= 0.098 and hi <= 0.102:
			bracket = "tight"
		elif lo >= 0.09 and hi <= 0.11:
			bracket = "wide"
	if cm_pen is PackedFloat32Array and cm_pen.size() >= 2 and lo >= 0.0:
		pen_tok = "same" if (absf(cm_pen[0] - lo) < 0.01 \
				and absf(cm_pen[1] - hi) < 0.01) else "pinned"
	var away_tok := "empty"
	if cm_away is PackedFloat32Array and cm_away.size() >= 2:
		# a cast moving AWAY from the wall with nothing else in its path is
		# a clean miss ([1,1]) in this geometry. (The r88-scout's ~0.6 away
		# fraction came from its extra dynamic body sitting in the sweep —
		# not reproduced here, and not claimed.)
		away_tok = "miss" if (absf(cm_away[0] - 1.0) < 0.0001 \
				and absf(cm_away[1] - 1.0) < 0.0001) else "other"
	var shared_tok := "empty"
	if cm_shared is PackedFloat32Array and cm_shared.size() >= 2:
		# the SAME params object the three ignoring methods read: the cast
		# sees its motion, the others never do.
		shared_tok = "honored" if (cm_shared[0] > 0.0 and cm_shared[0] < 1.0) \
				else "blocked"
	var zero_tok := "empty"
	if cm_zero is PackedFloat32Array and cm_zero.size() >= 2:
		zero_tok = "blocked" if (absf(cm_zero[0] - 1.0) < 0.0001 \
				and absf(cm_zero[1] - 1.0) < 0.0001) else "open"
	var short_tok := "empty"
	if cm_short is PackedFloat32Array and cm_short.size() >= 2:
		short_tok = "blocked" if (absf(cm_short[0] - 1.0) < 0.0001 \
				and absf(cm_short[1] - 1.0) < 0.0001) else "open"
	var cs_tok := "floor"
	if cs_inplace is Array and cs_inplace.size() > 0:
		cs_tok = "ignored" if cs_sweep.size() == 0 else "applied"
	var ri_tok := "floor"
	if ri_inplace is Dictionary and ri_inplace.size() > 0:
		ri_tok = "ignored" if ri_sweep.size() == 0 else "applied"
	var is_tok := "floor"
	if is_inplace is Array and is_inplace.size() > 0:
		is_tok = "ignored" if is_sweep.size() == 0 else "applied"
	_note(prefix, "cm=%.4f,%.4f pen=%.4f,%.4f away=%.4f,%.4f shared=%.4f,%.4f cs=%d/%d ri=%d/%d is=%d/%d" % [
			lo, hi,
			(cm_pen[0] if cm_pen is PackedFloat32Array and cm_pen.size() >= 2 else -1.0),
			(cm_pen[1] if cm_pen is PackedFloat32Array and cm_pen.size() >= 2 else -1.0),
			(cm_away[0] if cm_away is PackedFloat32Array and cm_away.size() >= 2 else -1.0),
			(cm_away[1] if cm_away is PackedFloat32Array and cm_away.size() >= 2 else -1.0),
			(cm_shared[0] if cm_shared is PackedFloat32Array and cm_shared.size() >= 2 else -1.0),
			(cm_shared[1] if cm_shared is PackedFloat32Array and cm_shared.size() >= 2 else -1.0),
			(cs_sweep.size() if cs_sweep is Array else -1),
			(cs_inplace.size() if cs_inplace is Array else -1),
			(ri_sweep.size() if ri_sweep is Dictionary else -1),
			(ri_inplace.size() if ri_inplace is Dictionary else -1),
			(is_sweep.size() if is_sweep is Array else -1),
			(is_inplace.size() if is_inplace is Array else -1)])
	_emit(prefix, "backend", str(_backend_name()))
	_emit(prefix, "cm", cm_tok)
	_emit(prefix, "cm_bracket", bracket)
	_emit(prefix, "cm_pen", pen_tok)
	_emit(prefix, "cm_shared", shared_tok)
	_emit(prefix, "cm_away", away_tok)
	_emit(prefix, "cm_zero", zero_tok)
	_emit(prefix, "cm_short", short_tok)
	_emit(prefix, "cs", cs_tok)
	_emit(prefix, "ri", ri_tok)
	_emit(prefix, "is", is_tok)
	_quit_clean()


# --child --arm=fg_plain / fg_thr / fg_jolt_thr / fg_dummy / fg_dummy_thr
# (r88): the access gate. Three acquisition paths per sample — the server
# space fetch, the World3D property, and the body state — so a refusal is
# counted in the raw log per path. Non-threaded: every sample grants.
# Threaded: every out-of-phase sample (the deferred start, a process frame,
# and each `_process` firing) refuses all three paths; the in-phase samples
# (the physics_frame continuation and `_physics_process`) grant. Dummy has no
# gate. The bypass cell: a body state held from a legal position hands out
# the SAME dss object at refused positions, and a query through it answers.
var q_setup := false
var q_rig_set := false
var q_rig := RID()
var q_held: Variant = null
var q_stash: Variant = null
var q_samples := 0
var q_grant := 0
var q_refuse := 0
var q_partial := 0
var q_byp_seen := 0
var q_byp_ok := 0
var q_byp_same := 0
var q_rows := []
var q_f_seen := 0


func _is_fetch_arm() -> bool:
	if not ("--child" in OS.get_cmdline_user_args()):
		return false
	return _argval("--arm=", "").begins_with("fg_")


func _fetch_gate_setup() -> void:
	if q_setup:
		return
	q_setup = true
	wspace = root.get_world_3d().space
	q_rig = _mk_body(Vector3(0, 8, 0), PhysicsServer3D.BODY_MODE_RIGID)
	PhysicsServer3D.body_set_param(q_rig,
			PhysicsServer3D.BODY_PARAM_GRAVITY_SCALE, 0.0)
	# the RID itself is not a liveness test: under Dummy every create returns
	# RID(0), and the Dummy floor answers a fetch for RID() too — so the
	# body-path flag is "the setup ran", not "the RID is nonzero".
	q_rig_set = true


func _body_state(b: RID) -> Variant:
	return PhysicsServer3D.body_get_direct_state(b)


func _held_space(b: Variant) -> Variant:
	return b.get_space_state()


func _sample_fetch(tag: String) -> void:
	q_samples += 1
	var f := 1 if PhysicsServer3D.space_get_direct_state(wspace) != null else 0
	var w := 1 if root.get_world_3d().direct_space_state != null else 0
	var b := 1 if (q_rig_set and _body_state(q_rig) != null) else 0
	var paths := f + w + b
	if paths == 3:
		q_grant += 1
	elif paths == 0:
		q_refuse += 1
	else:
		q_partial += 1
	q_rows.append("%s:%d%d%d" % [tag, f, w, b])
	if q_held != null:
		var bs: Variant = _dss_live(_held_space(q_held))
		if bs != null:
			q_byp_seen += 1
			var hit: Variant = _call_read(bs, "pt")
			if hit is Array:
				q_byp_ok += 1
			# parent-visible identity witness: the two ids, not just the
			# count, so a truthy-regression (== -> != null) can't launder.
			var same: bool = bs == q_stash
			_note("byp_ids", "%s/%s" % [str((bs as Object).get_instance_id()),
					("nil" if q_stash == null
					else str((q_stash as Object).get_instance_id()))])
			if same:
				q_byp_same += 1


func _child_fetch_gate(prefix: String) -> void:
	_fetch_gate_setup()
	await process_frame
	_sample_fetch("B")
	await process_frame
	_sample_fetch("C")
	await physics_frame
	q_stash = _dss_live(PhysicsServer3D.space_get_direct_state(wspace))
	q_held = _body_state(q_rig)
	_sample_fetch("D")
	_add_qnode("fetch", GATE_F_REPS)
	var deadline := Engine.get_physics_frames() + 30
	while q_f_seen < GATE_F_REPS and Engine.get_physics_frames() < deadline:
		await physics_frame
	var gate_tok := "phase"
	if q_refuse == 0 and q_partial == 0:
		gate_tok = "open"
	_note(prefix, "rows=%s stash=%s held=%s" % [str(q_rows),
			("nil" if q_stash == null else "dss"),
			("nil" if q_held == null else "bds")])
	_emit(prefix, "backend", str(_backend_name()))
	_emit(prefix, "samples", "%d" % [q_samples])
	_emit(prefix, "grant", "%d" % [q_grant])
	_emit(prefix, "refuse", "%d" % [q_refuse])
	_emit(prefix, "partial", "%d" % [q_partial])
	_emit(prefix, "gate", gate_tok)
	_emit(prefix, "byp", "%d/%d" % [q_byp_ok, q_byp_seen])
	_emit(prefix, "byp_same", "%d/%d" % [q_byp_same, q_byp_seen])
	_quit_clean()


# --child --arm=ia_plain / ia_thr / ia_jolt_thr (r88): the never-activated
# private space. The gate keys on the step cycle, not on activation: on
# non-threaded backends the fetch of space_create + space_set_active(false)
# is granted at every sampled position, while the threaded gate refuses it
# out of phase. A handle STASHED at a legal position answers everywhere with
# the same signature; its cs/ri zeros are geometric (the private space
# carries only the wall, so the -5z sweep's in-place start does not overlap).
var alt_space := RID()
var ia_stash: Variant = null
var ia_open := 0
var ia_refused := 0
var ia_samples := 0
var ia_alts_ok := 0
var ia_alts_seen := 0
var ia_f_bp := 0
var ia_sig := ""


func _child_inactive_space(prefix: String) -> void:
	wspace = root.get_world_3d().space
	alt_space = PhysicsServer3D.space_create()
	PhysicsServer3D.space_set_active(alt_space, false)
	var s := PhysicsServer3D.box_shape_create()
	PhysicsServer3D.shape_set_data(s, Vector3(1, 1, 1))
	var alt_wall := PhysicsServer3D.body_create()
	PhysicsServer3D.body_set_mode(alt_wall, PhysicsServer3D.BODY_MODE_STATIC)
	PhysicsServer3D.body_add_shape(alt_wall, s)
	PhysicsServer3D.body_set_collision_layer(alt_wall, 1)
	PhysicsServer3D.body_set_space(alt_wall, alt_space)
	PhysicsServer3D.body_set_state(alt_wall,
			PhysicsServer3D.BODY_STATE_TRANSFORM,
			Transform3D(Basis(), Vector3(0, 0, -3)))
	# teardown order is load-bearing under Jolt: free_rid(space) while the
	# space still holds a live body aborts (measured: rc 134 inside
	# free_rid(space) with the order space->body->shape, 2/2; shape->body->
	# space and body->shape->space exit 0, 2/2 each). The private space is
	# therefore registered LAST, so _cleanup_rids frees contents first and
	# this arm measures the fetch lattice, not a teardown order artifact.
	owned.append_array([s, alt_wall, alt_space])
	await process_frame
	_sample_inactive("B")
	await process_frame
	_sample_inactive("C")
	await physics_frame
	ia_stash = _dss_live(PhysicsServer3D.space_get_direct_state(alt_space))
	_sample_inactive("D")
	_add_qnode("inactive", 1)
	var deadline := Engine.get_physics_frames() + 30
	while q_f_seen < 1 and Engine.get_physics_frames() < deadline:
		await physics_frame
	_note(prefix, "open=%d refused=%d samples=%d sig=%s" % [ia_open,
			ia_refused, ia_samples, ia_sig])
	_emit(prefix, "backend", str(_backend_name()))
	_emit(prefix, "samples", "%d" % [ia_samples])
	_emit(prefix, "open", "%d" % [ia_open])
	_emit(prefix, "refused", "%d" % [ia_refused])
	_emit(prefix, "alts", "%d/%d" % [ia_alts_ok, ia_alts_seen])
	_emit(prefix, "f_bp", "%d/1" % [ia_f_bp])
	_emit(prefix, "sig", ia_sig)
	_quit_clean()


func _sample_inactive(tag: String) -> void:
	ia_samples += 1
	if PhysicsServer3D.space_get_direct_state(alt_space) != null:
		ia_open += 1
	else:
		ia_refused += 1
	if ia_stash == null:
		return
	if tag == "F":
		# The out-of-phase firing is BROADPHASE-ONLY on purpose: the Jolt
		# shape channel in this window tears the shape registry (measured —
		# the r88-scout's gt_proj_jolt_thr.r1 aborted on exactly this
		# sequence, and this child aborted the same way before the split).
		# The shape-channel battery is taken at the in-phase positions and
		# the tear/crash class is pinned by the race_class row.
		var pt: Variant = _call_read(ia_stash, "pt")
		var ry: Variant = _call_read(ia_stash, "ray")
		if pt is Array and ry is Dictionary:
			ia_f_bp += 1
		return
	var sig := _alts_sig(ia_stash)
	ia_alts_seen += 1
	if ia_sig == "":
		ia_sig = sig
	if sig == ia_sig:
		ia_alts_ok += 1


func _alts_sig(d: Variant) -> String:
	var pt: Variant = _call_read(d, "pt")
	var ry: Variant = _call_read(d, "ray")
	var i_s: Variant = _call_read(d, "is")
	var cs: Variant = _call_read(d, "cs")
	var cm: Variant = _call_read(d, "cm")
	var ri: Variant = _call_read(d, "ri")
	var rv: Variant = d.get_rest_info(_sphere_params(Vector3(0, 0, -2.2)))
	return "pt%d,is%d,ray%d,cs%d,cm%s,ri%d,rv%d" % [
			(pt.size() if pt is Array else -1),
			(i_s.size() if i_s is Array else -1),
			(ry.size() if ry is Dictionary else -1),
			(cs.size() if cs is Array else -1),
			_cm_class(cm),
			(ri.size() if ri is Dictionary else -1),
			(rv.size() if rv is Dictionary else -1)]


func _cm_class(cm: Variant) -> String:
	if not (cm is PackedFloat32Array):
		return "other"
	if cm.size() == 0:
		return "empty"
	if cm.size() >= 2 and cm[0] > 0.0 and cm[0] < 1.0 \
			and cm[1] > 0.0 and cm[1] < 1.0:
		return "frac"
	if cm.size() >= 2 and cm[0] >= 0.9999 and cm[1] >= 0.9999:
		return "blocked"
	return "other"


# --child --arm=rc_plain / rc_jolt (r88): the threaded race window as NAMED
# classes with an ENVELOPE pin. The legal channel values are measured at the
# in-phase control (E, inside `_physics_process`); every out-of-phase sample
# (`_process`, RACE_REPS firings) must then report each COUNT channel either
# empty/zero or exactly the legal value, and the cast channel either empty, a
# mid-sweep fraction in (0,1), or a torn blocked [1,1] (the wall torn out of
# the sweep — named class since r88 C5) — a torn read (the r88-scout saw
# 0.197/0.156) is a named class, not a violation, but a value outside that
# union is. No
# class is REQUIRED to appear: this is an envelope, never a distribution.
# The Jolt child's window also tears the Jolt shape registry (its own engine
# lines) and can abort the process; the parent pins the crash envelope OR the
# completed envelope, each with its own witnesses.
var race_legal := {}
var race_env := "ok"
var race_bad := ""
var race_f := 0
var race_e_legal := 0
var race_refused := 0
var race_notes := []


func _child_race_class(prefix: String) -> void:
	wspace = root.get_world_3d().space
	_mk_body(Vector3(0, 0, -3))
	_mk_body(Vector3(0, -1, 0))
	await _frames(4)
	q_stash = _dss_live(PhysicsServer3D.space_get_direct_state(wspace))
	if q_stash == null:
		_note(prefix, "stash=nil")
		_quit_clean(1)
		return
	_note(prefix, "stash=dss")
	_add_qnode("race", RACE_REPS)
	var deadline := Engine.get_physics_frames() + 30
	while race_f < RACE_REPS and Engine.get_physics_frames() < deadline:
		await physics_frame
	_note(prefix, "legal=%s classes=%s" % [str(race_legal),
			str(race_notes)])
	_emit(prefix, "backend", str(_backend_name()))
	_emit(prefix, "e_legal", "%d" % [race_e_legal])
	_emit(prefix, "f", "%d" % [race_f])
	_emit(prefix, "refused", "%d" % [race_refused])
	_emit(prefix, "envelope", race_env)
	_quit_clean()


func _sample_race(tag: String) -> void:
	if PhysicsServer3D.space_get_direct_state(wspace) == null:
		race_refused += 1
	var row := _race_row(q_stash)
	if tag == "E":
		race_legal = row
		for k in ["pt", "ray", "is", "cs", "ri"]:
			if int(row[k]) > 0:
				race_e_legal += 1
		if String(row["cm"]) == "frac":
			race_e_legal += 1
		return
	race_f += 1
	var bad := _race_violation(row, race_legal)
	if bad != "" and race_env == "ok":
		race_env = "violation"
		race_bad = bad
	race_notes.append(_race_class(row, race_legal) if race_env == "ok"
			else race_bad)


func _race_row(d: Variant) -> Dictionary:
	var pt: Variant = _call_read(d, "pt")
	var ry: Variant = _call_read(d, "ray")
	var i_s: Variant = _call_read(d, "is")
	var cs: Variant = _call_read(d, "cs")
	var cm: Variant = _call_read(d, "cm")
	var ri: Variant = _call_read(d, "ri")
	return {
		"pt": (pt.size() if pt is Array else -1),
		"ray": (ry.size() if ry is Dictionary else -1),
		"is": (i_s.size() if i_s is Array else -1),
		"cs": (cs.size() if cs is Array else -1),
		"cm": _cm_class(cm),
		"ri": (ri.size() if ri is Dictionary else -1),
	}


func _race_violation(row: Dictionary, legal: Dictionary) -> String:
	for k in ["pt", "ray", "is", "cs", "ri"]:
		var v: int = row[k]
		var lv: int = int(legal.get(k, -1))
		if v != 0 and v != lv:
			return "%s=%d" % [k, v]
	if String(row["cm"]) != "empty" and String(row["cm"]) != "frac" \
			and String(row["cm"]) != "blocked":
		return "cm=%s" % String(row["cm"])
	return ""


func _race_class(row: Dictionary, legal: Dictionary) -> String:
	var empty := []
	for k in ["pt", "ray", "is", "cs", "ri"]:
		if int(row[k]) == 0:
			empty.append(k)
	if String(row["cm"]) == "empty":
		empty.append("cm")
	elif String(row["cm"]) != String(legal.get("cm", "frac")):
		empty.append("cm-torn")
	return "all" if empty.is_empty() else "+".join(empty)


# --child --arm=pq_plain / pq_jolt / pq_dummy (r88): params-object purity.
# Every read is fingerprinted before and after the call; shape_rid beats
# shape when both are set; repeated calls return fresh containers.
func _child_param_purity(prefix: String) -> void:
	wspace = root.get_world_3d().space
	_mk_body(Vector3(0, 0, -3))
	_mk_body(Vector3(0, -1, 0))
	await _frames(4)
	var d: Variant = await _fetch_world_dss()
	if d == null:
		_note(prefix, "dss=nil")
		_quit_clean(1)
		return
	var pure := 0
	var calls := 0
	var sp := _sphere_params(Vector3(0, 0, -2.2))
	var fp0 := _params_fp(sp)
	d.intersect_shape(sp)
	calls += 1
	if _params_fp(sp) == fp0:
		pure += 1
	d.collide_shape(sp)
	calls += 1
	if _params_fp(sp) == fp0:
		pure += 1
	d.cast_motion(sp)
	calls += 1
	if _params_fp(sp) == fp0:
		pure += 1
	d.get_rest_info(sp)
	calls += 1
	if _params_fp(sp) == fp0:
		pure += 1
	var pp := _pt_params(Vector3(0, 0, -3))
	var fpp := "pos=%s m=%d b=%s a=%s ex=%s" % [str(pp.position),
			pp.collision_mask, str(pp.collide_with_bodies),
			str(pp.collide_with_areas), str(pp.exclude)]
	d.intersect_point(pp)
	calls += 1
	if ("pos=%s m=%d b=%s a=%s ex=%s" % [str(pp.position),
			pp.collision_mask, str(pp.collide_with_bodies),
			str(pp.collide_with_areas), str(pp.exclude)]) == fpp:
		pure += 1
	var rp := _ray_params()
	var fpr := "from=%s to=%s m=%d b=%s a=%s fi=%s fb=%s ex=%s" % [
			str(rp.from), str(rp.to), rp.collision_mask,
			str(rp.collide_with_bodies), str(rp.collide_with_areas),
			str(rp.hit_from_inside), str(rp.hit_back_faces), str(rp.exclude)]
	d.intersect_ray(rp)
	calls += 1
	if ("from=%s to=%s m=%d b=%s a=%s fi=%s fb=%s ex=%s" % [
			str(rp.from), str(rp.to), rp.collision_mask,
			str(rp.collide_with_bodies), str(rp.collide_with_areas),
			str(rp.hit_from_inside), str(rp.hit_back_faces),
			str(rp.exclude)]) == fpr:
		pure += 1
	# shape_rid beats shape: at z=-1.7 the RID sphere (r=0.5) reaches the
	# wall face at z=-2 (near edge -2.2) while the tiny box (0.2 full, near
	# edge -1.8) does not, and neither touches the floor slab.
	var srv_sphere: RID = PhysicsServer3D.sphere_shape_create()
	PhysicsServer3D.shape_set_data(srv_sphere, 0.5)
	owned.append(srv_sphere)
	var tiny := BoxShape3D.new()
	tiny.size = Vector3(0.2, 0.2, 0.2)
	var both := PhysicsShapeQueryParameters3D.new()
	both.shape = tiny
	both.shape_rid = srv_sphere
	both.transform = Transform3D(Basis(), Vector3(0, 0, -1.7))
	both.collision_mask = 1
	var both_n: int = d.intersect_shape(both).size()
	var only_box := PhysicsShapeQueryParameters3D.new()
	only_box.shape = tiny
	only_box.transform = Transform3D(Basis(), Vector3(0, 0, -1.7))
	only_box.collision_mask = 1
	var box_n: int = d.intersect_shape(only_box).size()
	var only_rid := PhysicsShapeQueryParameters3D.new()
	only_rid.shape_rid = srv_sphere
	only_rid.transform = Transform3D(Basis(), Vector3(0, 0, -1.7))
	only_rid.collision_mask = 1
	var rid_n: int = d.intersect_shape(only_rid).size()
	# fresh containers: two identical calls, distinct instances, equal values
	var a1: Variant = d.intersect_shape(sp)
	var a2: Variant = d.intersect_shape(sp)
	var fresh := 0
	if not is_same(a1, a2) and a1 == a2:
		fresh += 1
	var y1: Variant = d.intersect_ray(rp)
	var y2: Variant = d.intersect_ray(rp)
	if not is_same(y1, y2) and y1 == y2:
		fresh += 1
	var c1: Variant = d.collide_shape(sp)
	var c2: Variant = d.collide_shape(sp)
	if not is_same(c1, c2) and c1 == c2:
		fresh += 1
	_note(prefix, "pure=%d/%d prec=%d,%d,%d fresh=%d" % [pure, calls,
			both_n, box_n, rid_n, fresh])
	_emit(prefix, "backend", str(_backend_name()))
	_emit(prefix, "pure", "%d/%d" % [pure, calls])
	_emit(prefix, "prec", "%d,%d,%d" % [both_n, box_n, rid_n])
	_emit(prefix, "fresh", "%d/3" % [fresh])
	_quit_clean()


# --child --arm=bi_plain / bi_jolt / bi_dummy (r88): the body-state inertia
# getters as values. The rigid box (half 2x0.5x0.5, mass 2) pins imass and
# the local inverse inertia; the y30 tensor is verified in-child against
# R*diag*R^T built from the MEASURED local values (the world-space claim is
# derived, not restated); the BODY_PARAM_INERTIA and CENTER_OF_MASS writes
# are read back; static and kinematic are pinned per backend (GodotPhysics
# zeros, Jolt's inconsistent placeholders, Dummy's identity tensor).
func _child_body_inertia(prefix: String) -> void:
	wspace = root.get_world_3d().space
	var r := _mk_body(Vector3(0, 8, 0), PhysicsServer3D.BODY_MODE_RIGID,
			Vector3(2.0, 0.5, 0.5))
	PhysicsServer3D.body_set_param(r,
			PhysicsServer3D.BODY_PARAM_MASS, 2.0)
	var st := _mk_body(Vector3(20, 8, 0), PhysicsServer3D.BODY_MODE_STATIC,
			Vector3(2.0, 0.5, 0.5))
	var kn := _mk_body(Vector3(40, 8, 0), PhysicsServer3D.BODY_MODE_KINEMATIC,
			Vector3(2.0, 0.5, 0.5))
	var iw := _mk_body(Vector3(60, 8, 0), PhysicsServer3D.BODY_MODE_RIGID,
			Vector3(2.0, 0.5, 0.5))
	PhysicsServer3D.body_set_param(iw,
			PhysicsServer3D.BODY_PARAM_INERTIA, Vector3(9.0, 4.0, 1.0))
	var cb := _mk_body(Vector3(80, 8, 0), PhysicsServer3D.BODY_MODE_RIGID,
			Vector3(2.0, 0.5, 0.5))
	PhysicsServer3D.body_set_param(cb,
			PhysicsServer3D.BODY_PARAM_CENTER_OF_MASS, Vector3(0.4, 0.0, 0.0))
	for b in [r, iw, cb]:
		PhysicsServer3D.body_set_param(b,
				PhysicsServer3D.BODY_PARAM_GRAVITY_SCALE, 0.0)
	await _frames(8)
	var rb: Variant = await _fetch_body_state(r)
	var r_imass := "nil"
	var r_ii := "nil"
	var r_iit := "nil"
	var r_pax := "nil"
	if rb != null:
		r_imass = "%.6f" % rb.get_inverse_mass()
		r_ii = _v3s(rb.get_inverse_inertia())
		r_iit = _bs(rb.get_inverse_inertia_tensor())
		r_pax = _bs(rb.get_principal_inertia_axes())
	PhysicsServer3D.body_set_state(r, PhysicsServer3D.BODY_STATE_TRANSFORM,
			Transform3D(Basis(Vector3(0, 1, 0), deg_to_rad(30.0)),
					Vector3(0, 8, 0)))
	await _frames(4)
	var ry30: Variant = PhysicsServer3D.body_get_direct_state(r)
	var r_y30_iit := "nil"
	var r_y30_pax := "nil"
	var tensor := "nil"
	if ry30 != null:
		r_y30_iit = _bs(ry30.get_inverse_inertia_tensor())
		r_y30_pax = _bs(ry30.get_principal_inertia_axes())
		tensor = _tensor_check(ry30)
	PhysicsServer3D.body_set_param(r, PhysicsServer3D.BODY_PARAM_MASS, 4.0)
	await _frames(2)
	var rm4: Variant = PhysicsServer3D.body_get_direct_state(r)
	var r_m4_imass := "nil"
	var r_m4_ii := "nil"
	if rm4 != null:
		r_m4_imass = "%.6f" % rm4.get_inverse_mass()
		r_m4_ii = _v3s(rm4.get_inverse_inertia())
	var st_b: Variant = await _fetch_body_state(st)
	var kn_b: Variant = await _fetch_body_state(kn)
	var iw_b: Variant = await _fetch_body_state(iw)
	var cb_b: Variant = await _fetch_body_state(cb)
	_note(prefix, "r=%s/%s/%s y30=%s m4=%s/%s st=%s kn=%s iw=%s cb=%s" % [
			r_imass, r_ii, r_iit, r_y30_iit, r_m4_imass, r_m4_ii,
			("nil" if st_b == null else _st_sig(st_b)),
			("nil" if kn_b == null else _st_sig(kn_b)),
			("nil" if iw_b == null else _iw_sig(iw_b)),
			("nil" if cb_b == null else _cb_sig(cb_b))])
	_emit(prefix, "backend", str(_backend_name()))
	_emit(prefix, "r_imass", r_imass)
	_emit(prefix, "r_ii", r_ii)
	_emit(prefix, "r_iit", r_iit)
	_emit(prefix, "r_pax", r_pax)
	_emit(prefix, "tensor", tensor)
	_emit(prefix, "r_y30_iit", r_y30_iit)
	_emit(prefix, "r_y30_pax", _pax_class(r_y30_pax))
	_emit(prefix, "r_m4_imass", r_m4_imass)
	_emit(prefix, "r_m4_ii", r_m4_ii)
	_emit(prefix, "st", ("nil" if st_b == null else _st_sig(st_b)))
	_emit(prefix, "kn", ("nil" if kn_b == null else _st_sig(kn_b)))
	_emit(prefix, "iw", ("nil" if iw_b == null else _iw_sig(iw_b)))
	_emit(prefix, "cb", ("nil" if cb_b == null else _cb_sig(cb_b)))
	_quit_clean()


func _fetch_body_state(b: RID) -> Variant:
	for i in range(24):
		var d: Variant = PhysicsServer3D.body_get_direct_state(b)
		if d != null:
			return d
		await physics_frame
	return null


func _v3s(v: Vector3) -> String:
	return "%.6f,%.6f,%.6f" % [v.x, v.y, v.z]


func _bs(b: Basis) -> String:
	return "%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f" % [
			b.x.x, b.x.y, b.x.z, b.y.x, b.y.y, b.y.z,
			b.z.x, b.z.y, b.z.z]


# The world-space tensor claim: R * diag(measured local ii) * R^T must equal
# the measured tensor of the y30 body. `diag` is the LOCAL inverse inertia
# read at identity, `rot` the body's own basis — the check derives the world
# tensor from those two measurements, it does not restate the tensor.
func _tensor_check(rb: Variant) -> String:
	var local: Vector3 = rb.get_inverse_inertia()
	var t: Transform3D = rb.get_transform()
	var r := t.basis
	var d := Basis(Vector3(local.x, 0, 0), Vector3(0, local.y, 0),
			Vector3(0, 0, local.z))
	var want := r * d * r.transposed()
	var got: Basis = rb.get_inverse_inertia_tensor()
	var err := 0.0
	for i in range(3):
		err = maxf(err, absf(want[i].x - got[i].x))
		err = maxf(err, absf(want[i].y - got[i].y))
		err = maxf(err, absf(want[i].z - got[i].z))
	if err < 0.00001:
		return "world"
	# the Dummy floor: zero local inertia and an identity tensor are the
	# "no data" placeholder convention (the Jolt static/kinematic pair uses
	# the same identity marker), so the derived-tensor claim does not apply.
	if local.length() < 0.000001 and got.is_equal_approx(Basis()):
		return "floor"
	return "drift"


func _pax_class(pax: String) -> String:
	if pax == "nil":
		return "nil"
	if pax == "1.000000,0.000000,0.000000,0.000000,1.000000,0.000000,0.000000,0.000000,1.000000":
		return "identity"
	if pax == "0.866025,0.000000,-0.500000,0.000000,1.000000,0.000000,0.500000,0.000000,0.866025":
		return "rot"
	if pax == "0.000000,1.000000,0.000000,0.500000,0.000000,0.866025,0.866025,0.000000,-0.500000":
		return "perm"
	return "other"


func _st_sig(b: Variant) -> String:
	return "%s/%s/%s" % ["%.6f" % b.get_inverse_mass(),
			_v3s(b.get_inverse_inertia()), _bs(b.get_inverse_inertia_tensor())]


func _iw_sig(b: Variant) -> String:
	return "%s/%s" % ["%.6f" % b.get_inverse_mass(),
			_v3s(b.get_inverse_inertia())]


func _cb_sig(b: Variant) -> String:
	return "%s/%s" % [_v3s(b.get_center_of_mass()),
			_v3s(b.get_inverse_inertia())]


# --child --arm=wa_plain / wa_jolt / wa_dummy (r88): the wrong-argument
# class. Every cell is refused in the WRAPPER layer: rc=0 and a typed empty
# (Array / PackedFloat32Array / Dictionary per method). One child runs all
# thirteen cells; the refusal TEXT is counted from the raw log by the parent
# and required equal across backends.
func _child_wrong_args(prefix: String) -> void:
	wspace = root.get_world_3d().space
	_mk_body(Vector3(0, 0, -3))
	await _frames(6)
	var d: Variant = await _fetch_world_dss()
	if d == null:
		_note(prefix, "dss=nil")
		_quit_clean(1)
		return
	var cells := {
		"point_shapeparams": d.intersect_point(_sphere_params(Vector3(0, 0, -3))),
		"isect_pointparams": d.intersect_shape(_pt_params(Vector3(0, 0, -3))),
		"isect_rayparams": d.intersect_shape(_ray_params()),
		"isect_null": d.intersect_shape(null),
		"cast_pointparams": d.cast_motion(_pt_params(Vector3(0, 0, -3))),
		"collide_rayparams": d.collide_shape(_ray_params()),
		"rest_rayparams": d.get_rest_info(_ray_params()),
		"isect_noshape": d.intersect_shape(_sphere_params(
				Vector3(0, 0, -3), Vector3.ZERO, 1, false)),
		"cast_noshape": d.cast_motion(_sphere_params(
				Vector3(0, 0, -1.0), Vector3(0, 0, -5), 1, false)),
		"rest_noshape": d.get_rest_info(_sphere_params(
				Vector3(0, 0, -1.0), Vector3(0, 0, -5), 1, false)),
		"collide_maxres": d.collide_shape(_sphere_params(
				Vector3(0, 0, -1.0), Vector3(0, 0, -5)), -1),
		"isect_maxres0": d.intersect_shape(_sphere_params(
				Vector3(0, 0, -2.2)), 0),
		"point_maxres0": d.intersect_point(_pt_params(Vector3(0, 0, -3)), 0),
	}
	var rows := []
	for k in cells:
		var v: Variant = cells[k]
		var tok := _fmt_read(v)
		rows.append("%s=%s" % [k, tok])
		_emit(prefix, k, tok)
	_note(prefix, "cells=%s" % str(rows))
	_emit(prefix, "backend", str(_backend_name()))
	_quit_clean()


# --child --arm=gs_plain / gs_jolt (r88): the backend-geometry splits, pinned
# as per-backend envelopes. The floor here is the wide slab (20 x 0.5 x 20 at
# (0,-0.5,0), top at y=0) so a point ON the boundary is the discriminant: the
# containing wall only on GodotPhysics, the touched floor too on Jolt.
func _child_geom_split(prefix: String) -> void:
	wspace = root.get_world_3d().space
	_mk_body(Vector3(0, 0, -3))
	_mk_body(Vector3(0, -0.5, 0), PhysicsServer3D.BODY_MODE_STATIC,
			Vector3(20, 0.5, 20))
	await _frames(4)
	var d: Variant = await _fetch_world_dss()
	if d == null:
		_note(prefix, "dss=nil")
		_quit_clean(1)
		return
	var pt_boundary: int = d.intersect_point(
			_pt_params(Vector3(0, 0, -3))).size()
	var pt_inside: int = d.intersect_point(
			_pt_params(Vector3(0, -0.25, 0))).size()
	var cm: Variant = d.cast_motion(
			_sphere_params(Vector3(0, 0, -1.0), Vector3(0, 0, -5)))
	var ri: Variant = d.get_rest_info(
			_sphere_params(Vector3(0, 0, -1.0), Vector3(0, 0, -5)))
	var ri_ov: Variant = d.get_rest_info(_sphere_params(Vector3(0, 0, -2.2)))
	var cs: Variant = d.collide_shape(
			_sphere_params(Vector3(0, 0, -1.0), Vector3(0, 0, -5)))
	var cm_tok := _cm_class(cm)
	var normal := Vector3.ZERO
	var ri_n := 0
	if ri is Dictionary and ri.size() > 0:
		ri_n = ri.size()
		normal = ri["normal"]
	var n_tok := "none"
	if ri_n > 0:
		n_tok = "up" if absf(normal.y) > 0.999 else "tilt"
	var ovp_tok := "none"
	if ri_ov is Dictionary and ri_ov.size() > 0:
		var p: Vector3 = ri_ov["point"]
		ovp_tok = "start" if p.distance_to(Vector3(0, 0, -2.2)) < 0.01 \
				else "offset"
	var cs_y := "none"
	if cs is Array and cs.size() > 0:
		cs_y = "neg" if cs[0].y < -0.0001 else "zero"
	_note(prefix, "pt=%d/%d cm=%s normal=%s ovp=%s cs=%d/%s" % [
			pt_boundary, pt_inside, cm_tok, _v3s(normal), ovp_tok,
			(cs.size() if cs is Array else -1), cs_y])
	_emit(prefix, "backend", str(_backend_name()))
	_emit(prefix, "pt_boundary", "%d" % [pt_boundary])
	_emit(prefix, "pt_inside", "%d" % [pt_inside])
	_emit(prefix, "cm", cm_tok)
	_emit(prefix, "normal", n_tok)
	_emit(prefix, "ri_n", "%d" % [ri_n])
	_emit(prefix, "ovp", ovp_tok)
	_emit(prefix, "cs", "%d,%s" % [(cs.size() if cs is Array else -1), cs_y])
	_quit_clean()


# --child --arm=fm_<backend>_<method> (r88): one freed-space postcondition
# per process, because a crash cannot be caught. The sequence is the r87
# freed_space one: fetch a live handle + body state, call ALIVE, free the
# space, call on the stashed handle (PRE), refetch the freed space RID, then
# the POST path through the held body state. Every risky call sits in its own
# helper frame, so a "previously freed" script error aborts the callee (not
# the deferred coroutine — the r88-scout's rev-1 hang class).
func _child_freed_method(arm: String) -> void:
	var parts := arm.split("_")
	var method: String = parts[2] if parts.size() > 2 else "pt"
	wspace = root.get_world_3d().space
	var rig := _mk_body(Vector3(0, 8, 0), PhysicsServer3D.BODY_MODE_RIGID)
	PhysicsServer3D.body_set_param(rig,
			PhysicsServer3D.BODY_PARAM_GRAVITY_SCALE, 0.0)
	await _frames(2)
	var stash: Variant = _dss_live(PhysicsServer3D.space_get_direct_state(wspace))
	var bds: Variant = _body_state(rig)
	_note(arm, "alive=%s" % _fmt_read(_call_read(stash, method)))
	PhysicsServer3D.free_rid(wspace)
	_note(arm, "freed")
	_note(arm, "pre=%s" % _fmt_read(_call_read(stash, method)))
	_note(arm, "refetch=%s" % _fmt_read(
			PhysicsServer3D.space_get_direct_state(wspace)))
	var sp: Variant = _dss_live(_held_space(bds)) if bds != null else null
	_note(arm, "post=%s" % _fmt_read(sp))
	if sp != null:
		_note(arm, "post_ret=%s" % _fmt_read(_call_read(sp, method)))
		_emit(arm, "post", _fmt_read(_call_read(sp, method)))
		_quit_clean()
		return
	_emit(arm, "post", "nil")
	_quit_clean()


# --- r89: the phase / write / sleep / joint / cross-space arms ---------------
# Shared child helpers. Every r89 child is a generated-project process: the
# laws are backend-scoped and position-determined inside a live tree, and the
# _integrate_forces-capable body must be a NODE (RigidBody3D._integrate_forces
# is a CollisionObject3D callback), never a raw server RID. The contact
# geometry is the r89-scout's probe shape reused verbatim: a floor slab whose
# top face is y=-0.5 and a ball r=0.5 dropped from y=0.2, so the first contact
# lands around step 13 and the same numbers can be compared against the
# scout's receipts.
class IFRB extends RigidBody3D:
	var probe
	func _integrate_forces(st: PhysicsDirectBodyState3D) -> void:
		probe.on_if(st)


class IFWatch extends Node:
	var probe
	func _physics_process(_d: float) -> void:
		probe.on_e()
	func _process(_d: float) -> void:
		probe.on_f()


const PHASE_GETTERS := ["lp", "ln", "imp", "ls", "lv", "col", "cp", "cid",
		"cob", "csh", "cv"]
const IW_WRITE_TICK := 4
const IW_MEMBERS := ["baseline", "linvel", "angvel", "xform", "cimpulse",
		"timpulse", "cforce", "torque", "setcforce", "sleep", "reentrant",
		"detach"]
const JP_VARIANTS := ["pin", "soft0", "soft1", "clamp2", "nomake", "g6dof"]
const JP_TICKS := 12
const JP_TYPES := {"pin": 3, "hinge": 8, "slider": 22, "cone": 5, "g6dof": 22}
const SLEEP_CELLS := ["reads", "wake", "xform", "toggle", "floor", "sync"]
const SLEEP_BOUND := 240

var ip_ball: IFRB = null
var ip_bds: Variant = null
var ip_seq := 0
var ip_if := 0
var ip_record := false
var ip_if_rows := []
var ip_e_rows := []
var ip_f_rows := []
var iw_member := ""
var iw_wrote := false
var iw_same := "-"
var iw_ball_rid := RID()
var sl_ball: IFRB = null
var sl_ball_rid := RID()
var sl_floor := RID()
var sl_ss := 0


func _v4s(v: Vector3) -> String:
	return "%.4f,%.4f,%.4f" % [v.x, v.y, v.z]


# The joint getters answer float32 (0.3 reads back 0.30000001192093), so the
# table is formatted rather than stringified: the same write and the same
# default must compare equal across backends.
func _f4(v: Variant) -> String:
	if v is float:
		return "%.4f" % v
	return str(v)


func _iw_write(st: Variant, m: String) -> void:
	match m:
		"baseline":
			# the no-write control: its same-turn readback IS the free-fall
			# velocity at the write tick, which the force members compare to
			iw_same = _v4s(st.get_linear_velocity())
		"linvel":
			st.set_linear_velocity(Vector3(1, 2, 3))
			iw_same = _v4s(st.get_linear_velocity())
		"angvel":
			st.set_angular_velocity(Vector3(0.5, 1, 1.5))
			iw_same = _v4s(st.get_angular_velocity())
		"xform":
			st.set_transform(Transform3D(Basis(), Vector3(0, 8, 0)))
			iw_same = _v4s(st.get_transform().origin)
		"cimpulse":
			st.apply_central_impulse(Vector3(0, 3, 0))
			iw_same = _v4s(st.get_linear_velocity())
		"timpulse":
			st.apply_torque_impulse(Vector3(0, 0, 3))
			iw_same = _v4s(st.get_angular_velocity())
		"cforce":
			st.apply_central_force(Vector3(0, 60, 0))
			iw_same = _v4s(st.get_linear_velocity())
		"torque":
			st.apply_torque(Vector3(0, 0, 60))
			iw_same = _v4s(st.get_angular_velocity())
		"setcforce":
			st.set_constant_force(Vector3(0, 7, 0))
			iw_same = _v4s(st.get_constant_force())
		"sleep":
			st.set_sleep_state(true)
			iw_same = str(st.is_sleeping())
		"reentrant":
			st.integrate_forces()
			iw_same = _v4s(st.get_linear_velocity())
		"detach":
			PhysicsServer3D.body_set_space(iw_ball_rid, RID())
			iw_same = str(PhysicsServer3D.body_get_space(iw_ball_rid))
		_:
			iw_same = "none"


# The server-side read each member's verdict turns on: the angular velocity for
# the torque family, the transform for the teleport, the sleep state plus the
# velocity it kept or zeroed, the space for the detach, and the linear velocity
# for everything else.
func _iw_srv(m: String) -> String:
	var v: Variant
	match m:
		"angvel", "timpulse", "torque":
			v = PhysicsServer3D.body_get_state(iw_ball_rid,
					PhysicsServer3D.BODY_STATE_ANGULAR_VELOCITY)
			return _v4s(v) if v is Vector3 else "nil"
		"xform":
			v = PhysicsServer3D.body_get_state(iw_ball_rid,
					PhysicsServer3D.BODY_STATE_TRANSFORM)
			return _v4s(v.origin) if v is Transform3D else "nil"
		"sleep":
			v = PhysicsServer3D.body_get_state(iw_ball_rid,
					PhysicsServer3D.BODY_STATE_SLEEPING)
			var lv: Variant = PhysicsServer3D.body_get_state(iw_ball_rid,
					PhysicsServer3D.BODY_STATE_LINEAR_VELOCITY)
			return "%s/%s" % ["nil" if v == null else str(v),
					(_v4s(lv) if lv is Vector3 else "nil")]
		"detach":
			return str(PhysicsServer3D.body_get_space(iw_ball_rid))
		_:
			v = PhysicsServer3D.body_get_state(iw_ball_rid,
					PhysicsServer3D.BODY_STATE_LINEAR_VELOCITY)
			return _v4s(v) if v is Vector3 else "nil"


func _iw_y(s: String) -> float:
	var parts := s.split("/")[0].split(",")
	return float(parts[1]) if parts.size() >= 2 else 0.0


func _iw_z(s: String) -> float:
	var parts := s.split("/")[0].split(",")
	return float(parts[2]) if parts.size() >= 3 else 0.0


# --child --arm=iw_plain / iw_jolt / iw_dummy (r89): the _integrate_forces
# interior rules, one member per fresh free-falling ball so no member can
# contaminate another. Each member writes at its 4th IF call and is then read
# three ways: the same-turn readback through the SAME handle inside IF, the
# server read at the next physics tick (rel=1) and two ticks later (rel=2/3).
# Velocity / angular-velocity / transform / impulse writes are immediate;
# force / torque / constant-force writes are DEFERRED one step (invisible
# same-turn, effective from the next step); `set_sleep_state(true)` is honored
# now but GodotPhysics keeps the velocity while Jolt zeroes it; a re-entrant
# `integrate_forces()` silently double-integrates; and `body_set_space(RID())`
# detaches the body, freezing it at its last state. No member is refused —
# the parent counts the engine's in/out-phase refusal line in the raw log.
func _child_if_write(prefix: String) -> void:
	wspace = root.get_world_3d().space
	var out := {}
	var base_same := "-"
	var base1 := "-"
	var base2 := "-"
	var iw_never := false
	for m in IW_MEMBERS:
		if iw_never:
			out[m + "_class"] = "nowrite"
			continue
		var ball := IFRB.new()
		ball.probe = self
		var col := CollisionShape3D.new()
		var sp := SphereShape3D.new()
		sp.radius = 0.5
		col.shape = sp
		ball.add_child(col)
		ball.position = Vector3(0, 3, 0)
		ball.can_sleep = true
		root.add_child(ball)
		owned_nodes.append(ball)
		iw_ball_rid = ball.get_rid()
		iw_member = m
		iw_wrote = false
		ip_if = 0
		iw_same = "-"
		var i := 0
		while i < 30 and not iw_wrote:
			await physics_frame
			i += 1
		if not iw_wrote:
			# The Dummy floor: `_integrate_forces` never fires, so no member
			# can be written. The remaining members are recorded as the same
			# floor class instead of re-waiting the 30-frame bound 11 more
			# times — measured, that wait alone was 6.6 s of this arm's 10.9 s
			# case elapsed against the 20 s per-case bound. The emitted dict is
			# unchanged (every member is `nowrite`, every readback `-`).
			iw_never = true
			out[m + "_class"] = "nowrite"
			iw_member = ""
			ball.free()
			continue
		var s1 := _iw_srv(m)
		await physics_frame
		var s2 := _iw_srv(m)
		await physics_frame
		var s3 := _iw_srv(m)
		if m == "baseline":
			base_same = iw_same
			base1 = s1
			base2 = s2
		var cls := "other"
		match m:
			"baseline":
				cls = "control"
			"linvel":
				cls = "now" if iw_same == "1.0000,2.0000,3.0000" and s1 == iw_same else "other"
			"angvel":
				cls = "now" if iw_same == "0.5000,1.0000,1.5000" and s1 == iw_same else "other"
			"xform":
				cls = "now" if iw_same == "0.0000,8.0000,0.0000" and s1 == iw_same else "other"
			"cimpulse":
				cls = "now" if _iw_y(s1) > 2.0 else "other"
			"timpulse":
				cls = "now" if iw_same == "0.0000,0.0000,30.0000" \
						and _iw_z(s1) > 29.0 else "other"
			"cforce":
				cls = "deferred" if iw_same == base_same \
						and _iw_y(s2) > 0.1 else "other"
			"torque":
				cls = "deferred" if iw_same == "0.0000,0.0000,0.0000" \
						and _iw_z(s2) > 1.0 else "other"
			"setcforce":
				cls = "deferred" if iw_same == "0.0000,7.0000,0.0000" \
						and _iw_y(s2) > _iw_y(base2) + 0.05 else "other"
			"sleep":
				var sparts := s1.split("/")
				if iw_same == "true" and sparts[0] == "true":
					var lvy := 0.0
					if sparts.size() > 1:
						var c := sparts[1].split(",")
						lvy = float(c[1]) if c.size() >= 2 else 0.0
					cls = "kept" if absf(lvy) > 0.1 else "zeroed"
			"reentrant":
				cls = "double" if absf(_iw_y(s1) - _iw_y(base1)) > 0.05 else "other"
			"detach":
				cls = "frozen" if s1 == "RID(0)" and s2 == s3 else "other"
		out[m + "_same"] = iw_same
		out[m + "_rel1"] = s1
		out[m + "_rel2"] = s2
		out[m + "_class"] = cls
		iw_member = ""
		ball.free()
	_note(prefix, "base_same=%s base1=%s base2=%s" % [base_same, base1, base2])
	_note(prefix, "classes=%s" % str(out))
	_emit(prefix, "backend", str(_backend_name()))
	for m in IW_MEMBERS:
		_emit(prefix, m + "_same", str(out.get(m + "_same", "-")))
		_emit(prefix, m + "_rel1", str(out.get(m + "_rel1", "-")))
		_emit(prefix, m + "_rel2", str(out.get(m + "_rel2", "-")))
		_emit(prefix, m + "_class", str(out.get(m + "_class", "-")))
	_quit_clean()


# --child --arm=cx_plain / cx_jolt / cx_dummy (r89): cross-space handle
# validity plus the server-vs-node box-size convention. THREE worlds in one
# process: A = the SceneTree root world, B = a SubViewport's own World3D, and a
# RAW server space created with space_create() + space_set_active(true). Each
# world carries a slab at a different height and a ball, and each discriminating
# query is a RAY whose hit height says WHICH space answered — so a handle that
# silently resolved to the other world could not pass. The last cell pins the
# two box conventions: `PhysicsServer3D.shape_set_data` takes HALF-extents
# (a (1,1,1) box's top face is y=1) while a `BoxShape3D.size` is the FULL size
# (its top face is y=0.5).
func _child_cross_space(prefix: String) -> void:
	wspace = root.get_world_3d().space
	# world A: slab top -0.5, a rigid ball at y=2 (rests at y=0)
	var floor_a := _mk_body(Vector3(0, -1, 0), PhysicsServer3D.BODY_MODE_STATIC,
			Vector3(10, 0.5, 10))
	var ball_a := _mk_body(Vector3(0, 2, 0), PhysicsServer3D.BODY_MODE_RIGID,
			Vector3(0.5, 0.5, 0.5))
	# world B: a SubViewport carrying an explicitly created World3D (the
	# scout's shape: `vp.world_3d = World3D.new()`), slab top -10.5, ball at
	# y=-8. `Viewport.own_world_3d` alone leaves `world_3d` null until the
	# viewport is drawn, which is why the world is constructed here.
	var vp := SubViewport.new()
	var world_b := World3D.new()
	vp.world_3d = world_b
	root.add_child(vp)
	owned_nodes.append(vp)
	await _frames(2)
	var space_b := world_b.space
	var floor_b := _mk_body(Vector3(0, -11, 0), PhysicsServer3D.BODY_MODE_STATIC,
			Vector3(10, 0.5, 10))
	PhysicsServer3D.body_set_space(floor_b, space_b)
	var ball_b := _mk_body(Vector3(0, -8, 0), PhysicsServer3D.BODY_MODE_RIGID,
			Vector3(0.5, 0.5, 0.5))
	PhysicsServer3D.body_set_space(ball_b, space_b)
	# a raw active server space with its own wall (top y=1) and ball. The
	# bodies are created BEFORE the space so that `owned`'s free order (the
	# append order) releases them first: freeing a space that still holds a
	# live body aborts Jolt inside free_rid (the r88 teardown-order rule,
	# re-measured here — this arm's first form crashed 134/134 in
	# _cleanup_rids).
	var wall_raw := _mk_body(Vector3(0, 0, -3))
	var ball_raw := _mk_body(Vector3(0, 2, 0), PhysicsServer3D.BODY_MODE_RIGID,
			Vector3(0.5, 0.5, 0.5))
	var raw_space := PhysicsServer3D.space_create()
	PhysicsServer3D.space_set_active(raw_space, true)
	PhysicsServer3D.body_set_space(wall_raw, raw_space)
	PhysicsServer3D.body_set_space(ball_raw, raw_space)
	owned.append(raw_space)
	# and a NODE body inside world B, so "a server body in a non-main space is
	# not stepped" (measured on Jolt) can be told apart from "the second world
	# is not stepped" (the scout's node-in-viewport cell, which falls on both)
	var node_b := IFRB.new()
	node_b.probe = self
	var nbcol := CollisionShape3D.new()
	var nbsp := SphereShape3D.new()
	nbsp.radius = 0.5
	nbcol.shape = nbsp
	node_b.add_child(nbcol)
	node_b.position = Vector3(0, -8, 0)
	vp.add_child(node_b)
	await _frames(12)
	var dss_a: Variant = root.get_world_3d().direct_space_state
	var dss_b: Variant = world_b.direct_space_state
	var fetch_b: Variant = PhysicsServer3D.space_get_direct_state(space_b)
	var bds_a: Variant = PhysicsServer3D.body_get_direct_state(ball_a)
	var bds_b: Variant = PhysicsServer3D.body_get_direct_state(ball_b)
	var bds_raw: Variant = PhysicsServer3D.body_get_direct_state(ball_raw)
	var raw_dss: Variant = PhysicsServer3D.space_get_direct_state(raw_space)
	var ident_a := "absent"
	var ident_b := "absent"
	var cross := "absent"
	if bds_a != null and dss_a != null:
		ident_a = str(bds_a.get_space_state() == dss_a)
		ident_b = str(bds_b.get_space_state() == dss_b)
		cross = str(bds_a.get_space_state() == dss_b)
	var raw_ident := "absent"
	if bds_raw != null and raw_dss != null:
		raw_ident = str(bds_raw.get_space_state() == raw_dss)
	# rays: same query shape, one per space, at x=3 so the slab (not the ball)
	# answers
	var ray_a := _cx_ray(dss_a, Vector3(3, 5, 0))
	var ray_b := _cx_ray(dss_b, Vector3(3, -5, 0))
	var ray_fetch_b := _cx_ray(fetch_b, Vector3(3, -5, 0))
	var ray_raw := _cx_ray(raw_dss, Vector3(0, 5, -3))
	# box-size convention: server half-extents vs node full size
	var sh := PhysicsServer3D.box_shape_create()
	PhysicsServer3D.shape_set_data(sh, Vector3(1, 1, 1))
	var sb := PhysicsServer3D.body_create()
	PhysicsServer3D.body_set_mode(sb, PhysicsServer3D.BODY_MODE_STATIC)
	PhysicsServer3D.body_add_shape(sb, sh)
	PhysicsServer3D.body_set_space(sb, wspace)
	PhysicsServer3D.body_set_state(sb,
			PhysicsServer3D.BODY_STATE_TRANSFORM, Transform3D(Basis(), Vector3(0, 0, 8)))
	owned.append(sb)
	owned.append(sh)
	var nb_node := StaticBody3D.new()
	var ncol := CollisionShape3D.new()
	var nbox := BoxShape3D.new()
	nbox.size = Vector3(1, 1, 1)
	ncol.shape = nbox
	nb_node.add_child(ncol)
	nb_node.position = Vector3(0, 0, -8)
	root.add_child(nb_node)
	owned_nodes.append(nb_node)
	await _frames(2)
	var srv_box := _cx_ray(dss_a, Vector3(0, 5, 8))
	var node_box := _cx_ray(dss_a, Vector3(0, 5, -8))
	_note(prefix, "A=%s B=%s raw=%s rays=%s,%s,%s,%s box=%s,%s" % [
			_cx_cls(dss_a), _cx_cls(dss_b), _cx_cls(raw_dss), ray_a, ray_b,
			ray_fetch_b, ray_raw, srv_box, node_box])
	_emit(prefix, "backend", str(_backend_name()))
	_emit(prefix, "dss_a", _cx_cls(dss_a))
	_emit(prefix, "dss_b", _cx_cls(dss_b))
	_emit(prefix, "fetch_b", _cx_cls(fetch_b))
	_emit(prefix, "bds_a", _cx_cls(bds_a))
	_emit(prefix, "bds_b", _cx_cls(bds_b))
	_emit(prefix, "a_ne_b", str(dss_a != dss_b))
	# r89 C7: the B-space witness requires the viewport to actually BIND the
	# constructed world — an orphan World3D whose assignment did not take
	# would still answer dss_b and fake the cross-space split. The readback
	# proves the set; find_world_3d proves the viewport resolves to it.
	_emit(prefix, "b_bound", str(vp.world_3d == world_b))
	_emit(prefix, "b_find", str(vp.find_world_3d() == world_b))
	_emit(prefix, "ident_a", ident_a)
	_emit(prefix, "ident_b", ident_b)
	_emit(prefix, "cross_ident", cross)
	_emit(prefix, "ray_a", ray_a)
	_emit(prefix, "ray_b", ray_b)
	_emit(prefix, "ray_fetch_b", ray_fetch_b)
	_emit(prefix, "fall_a", "%.4f" % _body_pos(ball_a).y)
	_emit(prefix, "fall_b", "%.4f" % _body_pos(ball_b).y)
	_emit(prefix, "node_b_fall", "%.4f" % node_b.position.y)
	_emit(prefix, "raw_fetch", _cx_cls(raw_dss))
	_emit(prefix, "raw_bds", _cx_cls(bds_raw))
	_emit(prefix, "raw_ident", raw_ident)
	_emit(prefix, "raw_ray", ray_raw)
	_emit(prefix, "raw_moves", "%.4f" % _body_pos(ball_raw).y)
	_emit(prefix, "srv_box", srv_box)
	_emit(prefix, "node_box", node_box)
	# teardown order (the r88 rule): the bodies living in a non-main space are
	# released BEFORE that space, and the raw space last of all. `owned`'s
	# append order cannot express this for world B (its space belongs to the
	# viewport node, which _cleanup_nodes releases first), so both space-bound
	# families are freed here explicitly.
	for r in [floor_b, ball_b, wall_raw, ball_raw]:
		PhysicsServer3D.free_rid(r)
		owned.erase(r)
	PhysicsServer3D.free_rid(raw_space)
	owned.erase(raw_space)
	_quit_clean()


func _cx_cls(v: Variant) -> String:
	if v == null:
		return "nil"
	return str(v.get_class())


# A downward ray whose hit height is the space's signature. `dss` is untyped:
# the Dummy backend hands out its own class and answers typed-empty.
func _cx_ray(dss: Variant, from: Vector3) -> String:
	if dss == null:
		return "nil"
	var q := PhysicsRayQueryParameters3D.create(from, from + Vector3(0, -60, 0))
	q.collision_mask = 1
	var h: Variant = dss.intersect_ray(q)
	if h is Dictionary:
		if h.is_empty():
			return "miss"
		return "hit=%.4f" % h["position"].y
	return "not_dict"


# --child --arm=js_plain / js_jolt / js_dummy (r89): the solver-priority write
# and the joint RID lifecycle. `prio` samples a pin witness with and without
# `joint_set_solver_priority(j, 32)` written mid-run (GodotPhysics honors the
# write and the constraint visibly changes; Jolt's getter returns the default
# and the trace is the control's). `clear` releases the constraint mid-run
# (the body falls from the very next step, the type reads 5, a double clear is
# a silent no-op, and the RID is REUSABLE). `freed` calls three members on a
# `free_rid`'d joint: the typed null-parameter refusal, the silent clear, and
# the make call whose guard name is backend-specific — the parent counts the
# guard token in the raw log. Contrast with the r87/r88 freed-SPACE family:
# a freed JOINT never crashes.
func _child_joint_solver(prefix: String) -> void:
	wspace = root.get_world_3d().space
	# prio: a control pair and a priority pair in separate patches
	var ctl_a := _mk_body(Vector3(0, 3, 0), PhysicsServer3D.BODY_MODE_STATIC,
			Vector3(0.4, 0.4, 0.4))
	var ctl_b := _mk_sphere_body(Vector3(0, 2, 0),
			PhysicsServer3D.BODY_MODE_RIGID, 0.5)
	var ctl_j := PhysicsServer3D.joint_create()
	_joint_make(ctl_j, "pin", ctl_a, ctl_b)
	var pri_a := _mk_body(Vector3(20, 3, 0), PhysicsServer3D.BODY_MODE_STATIC,
			Vector3(0.4, 0.4, 0.4))
	var pri_b := _mk_sphere_body(Vector3(20, 2, 0),
			PhysicsServer3D.BODY_MODE_RIGID, 0.5)
	var pri_j := PhysicsServer3D.joint_create()
	_joint_make(pri_j, "pin", pri_a, pri_b)
	var prio_before := str(PhysicsServer3D.joint_get_solver_priority(pri_j))
	var prio_after := "unset"
	for i in range(JP_TICKS):
		await physics_frame
		if i == 5:
			PhysicsServer3D.joint_set_solver_priority(pri_j, 32)
			prio_after = str(PhysicsServer3D.joint_get_solver_priority(pri_j))
	var ctl_gap := _body_pos(ctl_a).distance_to(_body_pos(ctl_b))
	var pri_gap := _body_pos(pri_a).distance_to(_body_pos(pri_b))
	var ctl_lv := _body_lv_y(ctl_b)
	var pri_lv := _body_lv_y(pri_b)
	PhysicsServer3D.free_rid(ctl_j)
	PhysicsServer3D.free_rid(pri_j)
	# clear: release mid-run, then re-make on the SAME RID
	var cl_a := _mk_body(Vector3(40, 3, 0), PhysicsServer3D.BODY_MODE_STATIC,
			Vector3(0.4, 0.4, 0.4))
	var cl_b := _mk_sphere_body(Vector3(40, 2, 0),
			PhysicsServer3D.BODY_MODE_RIGID, 0.5)
	var cl_j := PhysicsServer3D.joint_create()
	_joint_make(cl_j, "pin", cl_a, cl_b)
	var cl_gap_before := "unset"
	var cl_lv_before := "unset"
	var cl_type_after := "unset"
	var cl_gap_same := "unset"
	var cl_lv_next := "unset"
	var cl_gap_end := "unset"
	for i in range(JP_TICKS + 2):
		await physics_frame
		if i == 5:
			cl_gap_before = "%.4f" % _body_pos(cl_a).distance_to(_body_pos(cl_b))
			cl_lv_before = "%.4f" % _body_lv_y(cl_b)
			PhysicsServer3D.joint_clear(cl_j)
			cl_type_after = str(PhysicsServer3D.joint_get_type(cl_j))
			cl_gap_same = "%.4f" % _body_pos(cl_a).distance_to(_body_pos(cl_b))
		elif i == 6:
			cl_lv_next = "%.4f" % _body_lv_y(cl_b)
		elif i == JP_TICKS + 1:
			cl_gap_end = "%.4f" % _body_pos(cl_a).distance_to(_body_pos(cl_b))
	PhysicsServer3D.joint_clear(cl_j)
	var double_clear := "ok"
	_joint_make(cl_j, "pin", cl_a, cl_b)
	var remade_type := str(PhysicsServer3D.joint_get_type(cl_j))
	PhysicsServer3D.free_rid(cl_j)
	# freed: three members on a freed joint RID, one call each
	var fr_j := PhysicsServer3D.joint_create()
	PhysicsServer3D.free_rid(fr_j)
	var freed_type := str(PhysicsServer3D.joint_get_type(fr_j))
	PhysicsServer3D.joint_clear(fr_j)
	var freed_clear := "ok"
	_joint_make(fr_j, "pin", ctl_a, ctl_b)
	var freed_make := "ok"
	_note(prefix, "prio=%s/%s gap=%s,%s lv=%s,%s clear=%s/%s/%s/%s/%s remade=%s freed=%s/%s/%s" % [
			prio_before, prio_after, "%.4f" % ctl_gap, "%.4f" % pri_gap,
			"%.4f" % ctl_lv, "%.4f" % pri_lv, cl_gap_before, cl_lv_before,
			cl_type_after, cl_lv_next, cl_gap_end, remade_type, freed_type,
			freed_clear, freed_make])
	_emit(prefix, "backend", str(_backend_name()))
	_emit(prefix, "prio_before", prio_before)
	_emit(prefix, "prio_after", prio_after)
	_emit(prefix, "ctl_gap", "%.4f" % ctl_gap)
	_emit(prefix, "pri_gap", "%.4f" % pri_gap)
	_emit(prefix, "ctl_lv", "%.4f" % ctl_lv)
	_emit(prefix, "pri_lv", "%.4f" % pri_lv)
	_emit(prefix, "prio_effect", "jump" if absf(pri_lv - ctl_lv) > 1.0
			or absf(pri_gap - ctl_gap) > 0.05 else "none")
	_emit(prefix, "clear_gap_before", cl_gap_before)
	_emit(prefix, "clear_lv_before", cl_lv_before)
	_emit(prefix, "clear_type_after", cl_type_after)
	_emit(prefix, "clear_gap_same", cl_gap_same)
	_emit(prefix, "clear_lv_next", cl_lv_next)
	_emit(prefix, "clear_gap_end", cl_gap_end)
	_emit(prefix, "double_clear", double_clear)
	_emit(prefix, "remade_type", remade_type)
	_emit(prefix, "freed_type", freed_type)
	_emit(prefix, "freed_clear", freed_clear)
	_emit(prefix, "freed_make", freed_make)
	_quit_clean()


# --child --arm=sl_<cell>_<backend> / sl_dummy (r89): the sleeping-body direct
# state, ONE cell per process in one parallel batch (a sleep takes ~40 ticks of
# wall-clock physics, so a serial sweep would not fit the per-case bound). The
# geometry is the scout's: a sphere r=0.5 dropped from y=0.2 onto a slab whose
# top is y=-0.5, contacts opted in, can_sleep=true, and the body is allowed to
# fall asleep naturally. Cells: `reads` (a fetch plus every read while asleep,
# and the IF callback stopping on the sleep tick), `wake`/`xform` (a direct
# write lands, wakes the body and takes effect), `toggle` (set_sleep_state
# false: GodotPhysics re-sleeps at the next tick, Jolt stays awake-but-frozen),
# `floor` (teleporting the floor wakes the ball on GodotPhysics and not on
# Jolt), `sync` (the state-sync callback does not fire while asleep).
func _sl_on_ss(_st: PhysicsDirectBodyState3D) -> void:
	sl_ss += 1


func _sl_cc() -> int:
	var st: Variant = PhysicsServer3D.body_get_direct_state(sl_ball_rid)
	if st == null:
		return -1
	return st.get_contact_count()


func _sl_srv_sleep() -> String:
	var v: Variant = PhysicsServer3D.body_get_state(
			sl_ball_rid, PhysicsServer3D.BODY_STATE_SLEEPING)
	return "nil" if v == null else str(v)


func _child_sleep(arm: String) -> void:
	var parts := arm.split("_")
	var cell: String = parts[1] if parts.size() > 1 else "reads"
	wspace = root.get_world_3d().space
	sl_floor = _mk_body(Vector3(0, -1, 0), PhysicsServer3D.BODY_MODE_STATIC,
			Vector3(10, 0.5, 10))
	sl_ball = IFRB.new()
	sl_ball.probe = self
	var col := CollisionShape3D.new()
	var sp := SphereShape3D.new()
	sp.radius = 0.5
	col.shape = sp
	sl_ball.add_child(col)
	sl_ball.position = Vector3(0, 0.2, 0)
	sl_ball.can_sleep = true
	sl_ball.max_contacts_reported = 8
	root.add_child(sl_ball)
	owned_nodes.append(sl_ball)
	sl_ball_rid = sl_ball.get_rid()
	_emit(arm, "backend", str(_backend_name()))
	var slept := -1
	var null_seen := 0
	for i in range(SLEEP_BOUND):
		await physics_frame
		if i < 6:
			continue
		var v: Variant = PhysicsServer3D.body_get_state(
				sl_ball_rid, PhysicsServer3D.BODY_STATE_SLEEPING)
		if v == true:
			slept = i
			break
		if v == null:
			null_seen += 1
			if null_seen >= 30:
				break
	if slept < 0:
		# the Dummy floor: the body never sleeps, the handle answers false,
		# and the contact buffer never fills — a floor, never a hazard
		_emit(arm, "slept", "never")
		_emit(arm, "cc", "%d" % [_sl_cc()])
		_emit(arm, "if_fires", "%d" % [ip_if])
		_quit_clean()
		return
	var st: Variant = PhysicsServer3D.body_get_direct_state(sl_ball_rid)
	_emit(arm, "slept", "%d" % [slept])
	_emit(arm, "if_calls", "%d" % [ip_if])
	if st == null:
		_emit(arm, "handle", "nil")
		_quit_clean()
		return
	match cell:
		"reads":
			var cc0: int = st.get_contact_count()
			var imp0 := Vector3.ZERO
			var lv0: Vector3 = st.get_linear_velocity()
			if cc0 > 0:
				imp0 = st.get_contact_impulse(0)
			var hdl0: Variant = st.is_sleeping()
			# the fetch itself plus every read must leave it asleep
			var awake := 0
			for i in range(6):
				await physics_frame
				if _sl_srv_sleep() != "true":
					awake += 1
			_emit(arm, "cc", "%d" % [cc0])
			_emit(arm, "imp", "%.4f" % imp0.length())
			_emit(arm, "lv", _v4s(lv0))
			_emit(arm, "hdl_sleep", "nil" if hdl0 == null else str(hdl0))
			_emit(arm, "awake_ticks", "%d" % [awake])
			_emit(arm, "if_calls_after", "%d" % [ip_if])
		"wake":
			var tr0 := _v4s(st.get_transform().origin)
			st.set_linear_velocity(Vector3(0, 0, 2))
			_emit(arm, "same_lv", _v4s(st.get_linear_velocity()))
			_emit(arm, "same_hdl", str(st.is_sleeping()))
			for i in range(6):
				await physics_frame
			var tr1 := _v4s(_body_pos(sl_ball_rid))
			_emit(arm, "srv_sleep", _sl_srv_sleep())
			_emit(arm, "moved", "true" if tr1 != tr0 else "false")
		"xform":
			var p: Vector3 = st.get_transform().origin
			st.set_transform(Transform3D(Basis(), p + Vector3(0, 1, 0)))
			_emit(arm, "same_tr", _v4s(st.get_transform().origin))
			_emit(arm, "same_hdl", str(st.is_sleeping()))
			for i in range(6):
				await physics_frame
			_emit(arm, "srv_sleep", _sl_srv_sleep())
			_emit(arm, "fell", "true" if _body_pos(sl_ball_rid).y < p.y + 0.99
					else "false")
		"toggle":
			st.set_sleep_state(false)
			_emit(arm, "same_hdl", str(st.is_sleeping()))
			_emit(arm, "same_srv", _sl_srv_sleep())
			var tr0 := _v4s(st.get_transform().origin)
			var lv0 := _v4s(st.get_linear_velocity())
			await physics_frame
			_emit(arm, "next_srv", _sl_srv_sleep())
			for i in range(8):
				await physics_frame
			_emit(arm, "frozen", "true" if _v4s(_body_pos(sl_ball_rid)) == tr0
					and _v4s(st.get_linear_velocity()) == lv0 else "false")
		"floor":
			PhysicsServer3D.body_set_state(sl_floor,
					PhysicsServer3D.BODY_STATE_TRANSFORM,
					Transform3D(Basis(), Vector3(0, -20, 0)))
			for i in range(6):
				await physics_frame
			_emit(arm, "srv_sleep", _sl_srv_sleep())
			_emit(arm, "ball_tr", _v4s(_body_pos(sl_ball_rid)))
			_emit(arm, "cc", "%d" % [_sl_cc()])
		"sync":
			PhysicsServer3D.body_set_state_sync_callback(sl_ball_rid,
					Callable(self, "_sl_on_ss"))
			for i in range(6):
				await physics_frame
			_emit(arm, "ss_count", "%d" % [sl_ss])
			_emit(arm, "srv_sleep", _sl_srv_sleep())
	_quit_clean()


# One getter call per callee frame (the r88 lesson): an out-of-range index
# prints one engine ERROR and returns a typed default, and a script error would
# abort only this callee, never the deferred child coroutine.
func _phase_get(st: Variant, which: String, i: int) -> Variant:
	match which:
		"lp": return st.get_contact_local_position(i)
		"ln": return st.get_contact_local_normal(i)
		"imp": return st.get_contact_impulse(i)
		"ls": return st.get_contact_local_shape(i)
		"lv": return st.get_contact_local_velocity_at_position(i)
		"col": return st.get_contact_collider(i)
		"cp": return st.get_contact_collider_position(i)
		"cid": return st.get_contact_collider_id(i)
		"cob": return st.get_contact_collider_object(i)
		"csh": return st.get_contact_collider_shape(i)
		"cv": return st.get_contact_collider_velocity_at_position(i)
	return null


func _phase_row(st: Variant) -> Dictionary:
	var pf := Engine.get_physics_frames()
	if st == null:
		return {"pf": pf, "seq": ip_seq, "cc": -1, "tr": "nil", "lv": "nil",
				"imp": "nil", "imp_v": Vector3.ZERO, "lvloc": "nil",
				"lvloc_v": Vector3.ZERO}
	var cc: int = st.get_contact_count()
	var imp := Vector3.ZERO
	var lvloc := Vector3.ZERO
	var imp_s := "nil"
	var lvloc_s := "nil"
	if cc > 0:
		imp = st.get_contact_impulse(0)
		lvloc = st.get_contact_local_velocity_at_position(0)
		imp_s = _v4s(imp)
		lvloc_s = _v4s(lvloc)
	return {"pf": pf, "seq": ip_seq, "cc": cc,
			"tr": _v4s(st.get_transform().origin),
			"lv": _v4s(st.get_linear_velocity()),
			"imp": imp_s, "imp_v": imp, "lvloc": lvloc_s, "lvloc_v": lvloc}


# The callbacks every r89 child's probe role shares. `ip_record` selects the
# phase lattice (if_phase); `iw_member` selects the IF interior-write cell
# (if_write); the sleep child only counts IF firings (the callback stopping on
# the sleep tick is one of its claims), so it needs no branch here.
func on_if(st: PhysicsDirectBodyState3D) -> void:
	ip_seq += 1
	ip_if += 1
	if ip_record:
		# PHASEMK: a real-time marker so the merged child.log carries the
		# engine's own emission order — the seq counter is child-assigned,
		# the file position is not.
		print("PHASEMK IF %d" % Engine.get_physics_frames())
		ip_if_rows.append(_phase_row(st))
		return
	if iw_member != "" and not iw_wrote and ip_if == IW_WRITE_TICK:
		iw_wrote = true
		_iw_write(st, iw_member)


func on_e() -> void:
	ip_seq += 1
	if ip_bds == null and ip_ball != null:
		ip_bds = PhysicsServer3D.body_get_direct_state(ip_ball.get_rid())
	if ip_record:
		print("PHASEMK E %d" % Engine.get_physics_frames())
		ip_e_rows.append(_phase_row(ip_bds))


func on_f() -> void:
	ip_seq += 1
	if ip_record:
		print("PHASEMK F %d" % Engine.get_physics_frames())
		ip_f_rows.append(_phase_row(ip_bds))


func _phase_at(rows: Array, pf: int) -> Dictionary:
	for r in rows:
		if r["pf"] == pf:
			return r
	return {}


func _phase_same(a: Dictionary, b: Dictionary) -> bool:
	return a["cc"] == b["cc"] and a["tr"] == b["tr"] and a["lv"] == b["lv"] \
			and a["imp"] == b["imp"] and a["lvloc"] == b["lvloc"]


# IF(pf=k) == E(pf=k): the pre-step view (the same state left by step k-1).
func _phase_pairs_equal(a: Array, b: Array) -> String:
	var pairs := 0
	for r in a:
		var o := _phase_at(b, r["pf"])
		if o.is_empty():
			continue
		pairs += 1
		if not _phase_same(r, o):
			return "false"
	return "true" if pairs > 0 else "absent"


# F(pf=k) == IF(pf=k+1): the idle frame sees the record the step just wrote,
# which is the record the next tick's IF reports.
func _phase_next_equal(f_rows: Array, if_rows: Array) -> String:
	var pairs := 0
	for r in f_rows:
		var o := _phase_at(if_rows, int(r["pf"]) + 1)
		if o.is_empty():
			continue
		pairs += 1
		if not _phase_same(r, o):
			return "false"
	return "true" if pairs > 0 else "absent"


# IF -> E -> F inside one tick, read off the monotonic seq counter.
func _phase_seq_order() -> String:
	var seen := 0
	for r in ip_if_rows:
		var e := _phase_at(ip_e_rows, r["pf"])
		var f := _phase_at(ip_f_rows, r["pf"])
		if e.is_empty() or f.is_empty():
			continue
		seen += 1
		if not (int(r["seq"]) < int(e["seq"]) and int(e["seq"]) < int(f["seq"])):
			return "false"
	return "true" if seen > 0 else "absent"


# --child --arm=ip_plain / ip_jolt / ip_dummy (r89): the intra-tick phase
# lattice at the contact surface. The SAME tick is sampled at
# _integrate_forces (IF), _physics_process (E) and _process (F) through one
# body handle, every row stamped with `pf` (Engine.get_physics_frames) and
# `seq` (a counter bumped at the top of every callback), so the order is read
# off the rows instead of inferred. The lattice: IF is a PRE-step view — the
# rows at pf=k equal E's at pf=k and equal F's at pf=k+1 — so the CURRENT
# step's contact record is readable only at F(pf=k) or at the next tick's
# IF/E, never inside IF. The record's `impulse` field is one solve late on
# GodotPhysics (the first in-contact record reads exactly zero; the impact
# impulse appears in the following record) while Jolt's holds its own step's
# impulse; the contact-local velocity is the current pre-solve relative
# velocity on both. Never "GodotPhysics is always zero": r87's body_tier read
# the first in-contact step only, and this arm pins the lag as the mechanism.
func _child_if_phase(prefix: String) -> void:
	wspace = root.get_world_3d().space
	var floor_node := StaticBody3D.new()
	var fcol := CollisionShape3D.new()
	var fbox := BoxShape3D.new()
	fbox.size = Vector3(20, 1, 20)
	fcol.shape = fbox
	floor_node.add_child(fcol)
	floor_node.position = Vector3(0, -1, 0)
	root.add_child(floor_node)
	owned_nodes.append(floor_node)
	ip_ball = IFRB.new()
	ip_ball.probe = self
	var bcol := CollisionShape3D.new()
	var bsp := SphereShape3D.new()
	bsp.radius = 0.5
	bcol.shape = bsp
	ip_ball.add_child(bcol)
	ip_ball.position = Vector3(0, 0.2, 0)
	ip_ball.max_contacts_reported = 8
	ip_ball.can_sleep = false
	root.add_child(ip_ball)
	owned_nodes.append(ip_ball)
	var w := IFWatch.new()
	w.probe = self
	root.add_child(w)
	owned_nodes.append(w)
	ip_record = true
	# 24 ticks cover the drop (first contact ~step 13), the first in-contact
	# record at F and the two records after it on every backend.
	await _frames(24)
	ip_record = false
	var rid := ip_ball.get_rid()
	var st: Variant = PhysicsServer3D.body_get_direct_state(rid)
	# index-bounds cell: every getter outside [0, cc) is a typed refusal, not
	# a crash — the parent counts the engine's own line per call in the raw log
	var cc_now := 0
	var cc_after := -1
	var oob_calls := 0
	var oob_shape := "absent"
	if st != null:
		cc_now = st.get_contact_count()
		if cc_now > 0:
			for which in PHASE_GETTERS:
				_phase_get(st, which, cc_now)
				oob_calls += 1
			cc_after = st.get_contact_count()
			oob_shape = str(st.get_contact_local_shape(cc_now))
	var first := -1
	for r in ip_f_rows:
		if r["cc"] > 0:
			first = r["pf"]
			break
	var first_f := _phase_at(ip_f_rows, first)
	var first_if := _phase_at(ip_if_rows, first)
	var first_e := _phase_at(ip_e_rows, first)
	var next_if := _phase_at(ip_if_rows, first + 1)
	var next_f := _phase_at(ip_f_rows, first + 1)
	var if_eq_e := _phase_pairs_equal(ip_if_rows, ip_e_rows)
	var f_eq_next := _phase_next_equal(ip_f_rows, ip_if_rows)
	var seq_ok := _phase_seq_order()
	var cc_max := 0
	for r in ip_e_rows:
		cc_max = maxi(cc_max, int(r["cc"]))
	var imp_first := "absent"
	var imp_first_mag := "0.0000"
	var imp_next_mag := "0.0000"
	var lvloc_mag := "0.0000"
	if not first_f.is_empty():
		var m: Vector3 = first_f["imp_v"]
		imp_first = "zero" if m.length() < 0.000001 else "real"
		imp_first_mag = "%.4f" % m.length()
		lvloc_mag = "%.4f" % (first_f["lvloc_v"] as Vector3).length()
	if not next_f.is_empty():
		imp_next_mag = "%.4f" % (next_f["imp_v"] as Vector3).length()
	_note(prefix, "first=%d if_rows=%d e_rows=%d f_rows=%d if_eq_e=%s f_eq_next=%s seq=%s idx=%d/%s cc_after=%d cc_max=%d" % [
			first, ip_if_rows.size(), ip_e_rows.size(), ip_f_rows.size(),
			if_eq_e, f_eq_next, seq_ok, oob_calls, oob_shape, cc_after, cc_max])
	_emit(prefix, "backend", str(_backend_name()))
	_emit(prefix, "if_fires", "%d" % [ip_if])
	_emit(prefix, "cc_max", "%d" % [cc_max])
	_emit(prefix, "first_pf", "%d" % [first])
	_emit(prefix, "if_eq_e", if_eq_e)
	_emit(prefix, "f_eq_next_if", f_eq_next)
	_emit(prefix, "seq_order", seq_ok)
	_emit(prefix, "if_cc_first", "%d" % (first_if["cc"] if not first_if.is_empty() else -1))
	_emit(prefix, "e_cc_first", "%d" % (first_e["cc"] if not first_e.is_empty() else -1))
	_emit(prefix, "f_cc_first", "%d" % (first_f["cc"] if not first_f.is_empty() else -1))
	_emit(prefix, "if_cc_next", "%d" % (next_if["cc"] if not next_if.is_empty() else -1))
	_emit(prefix, "imp_first", imp_first)
	_emit(prefix, "imp_first_mag", imp_first_mag)
	_emit(prefix, "imp_next_mag", imp_next_mag)
	_emit(prefix, "lvloc_first_mag", lvloc_mag)
	_emit(prefix, "oob_calls", "%d" % [oob_calls])
	_emit(prefix, "oob_shape", oob_shape)
	_emit(prefix, "cc_after", "%d" % [cc_after])
	_quit_clean()


# --child --arm=fd_dummy (r88): the Dummy freed-space floor in ONE child —
# the silent backend never crashes, so all six methods run in one process.
# The world space is freed once; every subsequent call answers typed-empty
# and the refetch hands out a fresh Dummy dss.
func _child_freed_dummy(prefix: String) -> void:
	wspace = root.get_world_3d().space
	var rig := _mk_body(Vector3(0, 8, 0), PhysicsServer3D.BODY_MODE_RIGID)
	await _frames(2)
	var stash: Variant = _dss_live(PhysicsServer3D.space_get_direct_state(wspace))
	var bds: Variant = _body_state(rig)
	var alive := {}
	for m in FREED_METHODS:
		alive[m] = _fmt_read(_call_read(stash, m))
	PhysicsServer3D.free_rid(wspace)
	for m in FREED_METHODS:
		_emit(prefix, m + "_alive", str(alive[m]))
		_emit(prefix, m + "_pre", _fmt_read(_call_read(stash, m)))
		_emit(prefix, m + "_refetch", _fmt_read(
				PhysicsServer3D.space_get_direct_state(wspace)))
		var sp: Variant = _dss_live(_held_space(bds)) if bds != null else null
		_emit(prefix, m + "_post", _fmt_read(sp))
		if sp != null:
			_emit(prefix, m + "_ret", _fmt_read(_call_read(sp, m)))
	_quit_clean()


# --- r89: the joint family (shared child helpers) ---------------------------
# The scout's constraint geometry: a STATIC anchor A at (0,3,0) and a dynamic
# body B at (0,2,0) in free space (no floor), so gravity and the joint are the
# only actors and the witness is the anchor gap |B.pos - A.pos|. The shapes are
# small (half 0.2) so the two bodies never touch and the collision-default
# split is not confounded by a contact.
func _body_pos(rid: RID) -> Vector3:
	var v: Variant = PhysicsServer3D.body_get_state(
			rid, PhysicsServer3D.BODY_STATE_TRANSFORM)
	return v.origin if v is Transform3D else Vector3.ZERO


func _body_lv_y(rid: RID) -> float:
	var v: Variant = PhysicsServer3D.body_get_state(
			rid, PhysicsServer3D.BODY_STATE_LINEAR_VELOCITY)
	return v.y if v is Vector3 else 0.0


# The scout's witness body B is a sphere r=0.5 (mass 1) — a box B has a
# different inertia tensor and a different convergence, so the sphere is kept
# to make this arm's numbers comparable with the scout's receipts.
func _mk_sphere_body(pos: Vector3, mode := PhysicsServer3D.BODY_MODE_STATIC,
		radius := 0.5) -> RID:
	var shape := PhysicsServer3D.sphere_shape_create()
	PhysicsServer3D.shape_set_data(shape, radius)
	var body := PhysicsServer3D.body_create()
	PhysicsServer3D.body_set_mode(body, mode)
	PhysicsServer3D.body_add_shape(body, shape)
	PhysicsServer3D.body_set_collision_layer(body, 1)
	PhysicsServer3D.body_set_collision_mask(body, 1)
	PhysicsServer3D.body_set_space(body, wspace)
	PhysicsServer3D.body_set_state(body,
			PhysicsServer3D.BODY_STATE_TRANSFORM, Transform3D(Basis(), pos))
	owned.append(body)
	owned.append(shape)
	return body


func _joint_make(j: RID, t: String, a: RID, b: RID) -> void:
	match t:
		"pin":
			PhysicsServer3D.joint_make_pin(j, a, Vector3.ZERO, b, Vector3.ZERO)
		"hinge":
			PhysicsServer3D.joint_make_hinge(j, a, Transform3D(), b, Transform3D())
		"slider":
			PhysicsServer3D.joint_make_slider(j, a, Transform3D(), b, Transform3D())
		"cone":
			PhysicsServer3D.joint_make_cone_twist(j, a, Transform3D(), b,
					Transform3D())
		"g6dof":
			PhysicsServer3D.joint_make_generic_6dof(j, a, Transform3D(), b,
					Transform3D())


func _joint_set(j: RID, t: String, i: int, v: float) -> void:
	match t:
		"pin": PhysicsServer3D.pin_joint_set_param(j, i, v)
		"hinge": PhysicsServer3D.hinge_joint_set_param(j, i, v)
		"slider": PhysicsServer3D.slider_joint_set_param(j, i, v)
		"cone": PhysicsServer3D.cone_twist_joint_set_param(j, i, v)
		"g6dof": PhysicsServer3D.generic_6dof_joint_set_param(j, 0, i, v)


func _joint_get(j: RID, t: String, i: int) -> Variant:
	match t:
		"pin": return PhysicsServer3D.pin_joint_get_param(j, i)
		"hinge": return PhysicsServer3D.hinge_joint_get_param(j, i)
		"slider": return PhysicsServer3D.slider_joint_get_param(j, i)
		"cone": return PhysicsServer3D.cone_twist_joint_get_param(j, i)
		"g6dof": return PhysicsServer3D.generic_6dof_joint_get_param(j, 0, i)
	return null


func _idx_list(v: Array) -> String:
	if v.is_empty():
		return "-"
	var parts := PackedStringArray()
	for i in v:
		parts.append(str(i))
	return ",".join(parts)


# --child --arm=jp_plain / jp_jolt / jp_dummy (r89): the pin constraint as a
# WITNESS, one variant per fresh A/B pair so no variant contaminates another.
# A default pin is a SOFT constraint (it settles at a non-zero offset under a
# 1 g load), softness 0 freezes the body at its initial offset with exactly
# zero velocity, softness 1 closes the gap, and an impulse clamp below the
# support impulse makes the joint sag. `nomake` is the falsification control
# (the joint exists, is never made, and the body falls freely) — and
# `joint_make_generic_6dof` is compared against it: on Jolt the trace is the
# control's, which is the silent no-op. The r88-scout's softness/clamp
# parameter indices are re-used verbatim (p0 bias, p1 damping, p2 clamp).
func _child_joint_pin(prefix: String) -> void:
	wspace = root.get_world_3d().space
	var traces := {}
	var lvs := {}
	var types := {}
	var coll := "absent"
	var rb := {}
	var vi := 0
	for v in JP_VARIANTS:
		# Each variant gets its own patch of space: two bodies placed at the
		# SAME coordinates in different variants would collide with each other
		# (measured: the shared-position form pushed every variant's body and
		# the equilibrium never settled), and a joint is freed before the
		# bodies it references (the reverse order double-frees the engine's
		# constraint list).
		var base := Vector3(20.0 * vi, 0, 0)
		vi += 1
		var a := _mk_body(base + Vector3(0, 3, 0),
				PhysicsServer3D.BODY_MODE_STATIC, Vector3(0.4, 0.4, 0.4))
		var b := _mk_sphere_body(base + Vector3(0, 2, 0),
				PhysicsServer3D.BODY_MODE_RIGID, 0.5)
		var j := PhysicsServer3D.joint_create()
		match v:
			"pin":
				_joint_make(j, "pin", a, b)
			"soft0":
				_joint_make(j, "pin", a, b)
				PhysicsServer3D.pin_joint_set_param(j, 0, 0.0)
			"soft1":
				_joint_make(j, "pin", a, b)
				PhysicsServer3D.pin_joint_set_param(j, 0, 1.0)
			"clamp2":
				_joint_make(j, "pin", a, b)
				PhysicsServer3D.pin_joint_set_param(j, 2, 0.01)
			"g6dof":
				_joint_make(j, "g6dof", a, b)
		if v == "pin":
			coll = str(PhysicsServer3D.joint_is_disabled_collisions_between_bodies(j))
		types[v] = str(PhysicsServer3D.joint_get_type(j))
		# the pin parameter readback is only meaningful on a pin-family joint
		# (the getter's own type guard fires otherwise, which is not a claim
		# this arm makes)
		if v != "g6dof" and v != "nomake":
			rb[v] = "%s,%s,%s" % [
					_f4(PhysicsServer3D.pin_joint_get_param(j, 0)),
					_f4(PhysicsServer3D.pin_joint_get_param(j, 1)),
					_f4(PhysicsServer3D.pin_joint_get_param(j, 2))]
		var g4 := 0.0
		for i in range(JP_TICKS):
			await physics_frame
			if i == 3:
				g4 = _body_pos(a).distance_to(_body_pos(b))
		traces[v] = "%.4f,%.4f" % [g4,
				_body_pos(a).distance_to(_body_pos(b))]
		lvs[v] = "%.4f" % _body_lv_y(b)
		PhysicsServer3D.free_rid(j)
	_note(prefix, "types=%s traces=%s lvs=%s rb=%s coll=%s" % [
			str(types), str(traces), str(lvs), str(rb), coll])
	_emit(prefix, "backend", str(_backend_name()))
	for v in JP_VARIANTS:
		_emit(prefix, v + "_gap", traces[v])
		_emit(prefix, v + "_lv", lvs[v])
		_emit(prefix, v + "_type", types[v])
	_emit(prefix, "pin_rb", rb["pin"])
	_emit(prefix, "soft0_rb", rb["soft0"])
	_emit(prefix, "soft1_rb", rb["soft1"])
	_emit(prefix, "clamp2_rb", rb["clamp2"])
	_emit(prefix, "coll_default", coll)
	_emit(prefix, "g6dof_eq_nomake",
			"true" if traces["g6dof"] == traces["nomake"] else "false")
	_quit_clean()


# --child --arm=jq_plain / jq_jolt / jq_dummy (r89): the per-parameter
# round-trip table. Each joint type is written 0.5 at EVERY parameter index and
# read straight back: "honored" means the read returns the write, "dropped"
# means the backend kept its own default. Jolt silently drops a per-type
# subset (solver-tuning params) while honoring limits/motors; GodotPhysics
# honors the whole table except the slider, whose getter is write-opaque and
# emits a wrong-type guard per call. The guard line is counted by the parent
# from the raw log, so a silently-zero read can never pass as a write-opaque
# getter.
func _child_joint_param(prefix: String) -> void:
	wspace = root.get_world_3d().space
	var a := _mk_body(Vector3(0, 3, 0), PhysicsServer3D.BODY_MODE_STATIC,
			Vector3(0.2, 0.2, 0.2))
	var b := _mk_body(Vector3(0, 2, 0), PhysicsServer3D.BODY_MODE_RIGID,
			Vector3(0.2, 0.2, 0.2))
	await _frames(2)
	_emit(prefix, "backend", str(_backend_name()))
	for t in JP_TYPES:
		var j := PhysicsServer3D.joint_create()
		_joint_make(j, t, a, b)
		_emit(prefix, t + "_type", str(PhysicsServer3D.joint_get_type(j)))
		var hon := []
		var drop := []
		for i in range(JP_TYPES[t]):
			_joint_set(j, t, i, 0.5)
			var got: Variant = _joint_get(j, t, i)
			if got is float and absf(got - 0.5) < 0.0001:
				hon.append(i)
			else:
				drop.append(i)
		_emit(prefix, t + "_hon", _idx_list(hon))
		_emit(prefix, t + "_drop", _idx_list(drop))
		PhysicsServer3D.free_rid(j)
	# the flags round-trip separately from the float table
	var jh := PhysicsServer3D.joint_create()
	_joint_make(jh, "hinge", a, b)
	var hf := 0
	for f in range(2):
		PhysicsServer3D.hinge_joint_set_flag(jh, f, true)
		if PhysicsServer3D.hinge_joint_get_flag(jh, f) == true:
			hf += 1
	_emit(prefix, "hinge_flags", "%d/2" % [hf])
	PhysicsServer3D.free_rid(jh)
	var jg := PhysicsServer3D.joint_create()
	_joint_make(jg, "g6dof", a, b)
	var gf := 0
	for f in range(6):
		PhysicsServer3D.generic_6dof_joint_set_flag(jg, 0, f, true)
		if PhysicsServer3D.generic_6dof_joint_get_flag(jg, 0, f) == true:
			gf += 1
	_emit(prefix, "g6dof_flags", "%d/6" % [gf])
	PhysicsServer3D.free_rid(jg)
	# an UNMADE joint reads type 5 (JOINT_TYPE_MAX) and the default solver
	# priority on both real backends
	var ju := PhysicsServer3D.joint_create()
	_emit(prefix, "unmade_type", str(PhysicsServer3D.joint_get_type(ju)))
	_emit(prefix, "unmade_solver",
			str(PhysicsServer3D.joint_get_solver_priority(ju)))
	_emit(prefix, "coll_default", str(
			PhysicsServer3D.joint_is_disabled_collisions_between_bodies(ju)))
	PhysicsServer3D.free_rid(ju)
	_quit_clean()
