extends SceneTree
# r93 child probe — the Area3D signal-in-tick ordering lattice, folded from
# the r93-scout ordering rows through every r93-boundary falsification.
# Spawned per (case, backend) by res://r93_areasig.gd into generated child
# projects under --fixed-fps 60 (one idle frame per physics tick, so the
# receipt interleave is the engine's, not the scheduler's).
#
# argv: `-- <case>`
#
# Row dialect (raw lines are evidence; only M0/M rows cross into the
# battery digest):
#   PRE  case/engine/config header
#   IF   RigidBody3D._integrate_forces        body=<name>
#   SIG  an Area3D signal handler             sig=<A|B>.<name> ... ovA= ovn= mon=
#   E    Node._physics_process                t= by= ovA= ovB= ifc= (IFs since last E)
#   F    Node._process (idle)                 ovA= dE= dpf=
#   ACT  a case action                        msg
#   DONE / DONE_ALL counters
#
# Positional classes (computed at teardown over the buffered event stream,
# r93-boundary check.py semantics):
#   in_step   SIG after the tick's first IF row, before that tick's E row
#   no_if     SIG before the tick's E row but the tick has no IF row
#             (frozen body / post-free / Dummy-stepped boundary)
#   post_e    SIG after the tick's E row, before that tick's F rows —
#             the frame-end queue_free flush window
#   idle      SIG after an F row of that tick
#   pre_if    SIG before the tick's first IF row (law violation — never seen)
#   teardown  SIG emitted after the DONE row (probe's own queue_free)
#
# Rep-stability contract (folds the r92 + r93-boundary discipline):
#   * seq stamps and F-row multiplicity never cross into M rows; pf is a
#     physics stamp and stays.
#   * multi-overlap cases (`multi`, `areasig`, `monitoff`, `prio`) emit
#     only order-free pins: sig rows are canonical-sorted per physics
#     frame by (area, sig, target) with handler-time reads (ov/n/mon)
#     dropped, and fact lists are sorted. The emission ORDER is a
#     '#'-line diagnostic only — Jolt flips it ~12% under load
#     (r93-boundary §4), and the prio pf=2 entry order flips backends.
#   * Dummy cells pin vacuous truth (nsig=0, nif=0): no detection is the
#     backend-qualified fact, never an ordering claim.
#   * Engine ERROR lines are a pinned surface: the monitoring-off reads
#     ("Can't find overlapping bodies/areas when monitoring is off.") and
#     the in-dispatch write refusal ("Function blocked during in/out
#     signal.") land in the parent's e=/et= cell fields verbatim.
#
# Cases (argv[0]):
#   enter    ball falls in at pf=21, teleported out at E(34)
#   enter0   ball spawns overlapping -> entry pf=2, out at E(24)
#   tele     parked body teleported IN at E(24), OUT at E(34)
#   telefr   same but freeze=true: GP never detects; Jolt detects no_if
#   multi    two balls land in the same tick (order-free pins only)
#   freeq    queue_free at E(24): post-E exits with stale ovn + pf=25 null dup
#   freerid  free_rid at E(24): exits at pf=25 no_if
#   tif      transform written inside _integrate_forces(24): exit pf=25,
#            E(24) reads the stale overlap
#   tsig     teleport inside body_entered handler pf=21: dispatch continues
#            (shape_entered still fires), exit pf=22, no re-entry
#   monoff   monitoring=false at E(20): flush exits inside the write with
#            mon=false; re-enable at E(26) re-detects pf=27; OUT at E(34)
#   monif    monitoring=false inside IF(24): flush exits in-step with
#            mon=false; re-enable at E(30) re-detects pf=31
#   monsig   monitoring=false inside body_shape_entered handler pf=21:
#            REFUSED (e=1 refusal line), readback stays true, no flush
#   moncycle monitoring=false;true inside E(24): flush exits inside the
#            write; GP re-detects pf=25, Jolt does not re-detect
#   monoff0  monitoring=false from init; re-enable at E(30) re-detects
#            pf=31 on BOTH backends (contrast vs moncycle)
#   areasig  A/B overlap each other + ball; B_AWAY at E(24): paired-area
#            exit ordering at pf=25, per-backend
#   bodysig  two-shape ball: per-shape entry order splits GP(bsi=0,1) vs
#            Jolt(bsi=1,0); exit order body_exited between shape exits
#   monitoff B.monitorable=false at E(20): GP keeps the pair silently,
#            Jolt drops A.area_exited pf=21 and re-detects pf=27
#   prio     A(prio 0, gravity 0) + B(prio 1, gravity 30): signals fire on
#            BOTH areas at pf=2 regardless of priority; the override wins
#            the force split — swap at E(12) flips the fall direction

const CANON_CASES := ["multi", "areasig", "monitoff", "prio"]

var case := ""
var seq := 0
var tick_e := 0
var tick_f := 0
var tick_if := 0
var ifc := 0
var nsig := 0
var done := false
var done_idx := -1
var ball_gone := false

var ev: Array = []
var balls: Array = []
var rids: Array = []
var home_x: Array = []
var floor_node: StaticBody3D
var area_a: Area3D
var area_b: Area3D
var rid_a: RID
var rid_b: RID


class RB extends RigidBody3D:
	var probe
	func _integrate_forces(st: PhysicsDirectBodyState3D) -> void:
		probe.on_if(self, st)


class Watcher extends Node:
	var probe
	func _physics_process(_d: float) -> void:
		probe.on_e()
	func _process(_d: float) -> void:
		probe.on_f()


func pf() -> int:
	return Engine.get_physics_frames()


func v3(v: Vector3) -> String:
	return "%.4f,%.4f,%.4f" % [v.x, v.y, v.z]


func ov(a: Area3D) -> String:
	return "%d/%d" % [a.get_overlapping_bodies().size(),
			a.get_overlapping_areas().size()]


func ovn(a: Area3D) -> String:
	var names: Array = []
	for b in a.get_overlapping_bodies():
		names.append(bn(b))
	return ",".join(names) if names.size() > 0 else "-"


func bn(b) -> String:
	return str(b.name) if b != null else "<null>"


func body_ys() -> String:
	if ball_gone:
		return "n/a"
	var out: Array = []
	for r in rids:
		var v: Variant = PhysicsServer3D.body_get_state(
				r, PhysicsServer3D.BODY_STATE_TRANSFORM)
		out.append("%.4f" % v.origin.y if v is Transform3D else "n/a")
	return "+".join(out)


func _rec(k: String, f: Dictionary = {}) -> void:
	ev.append({"k": k, "pf": pf(), "seq": seq, "f": f})


func sig_row(area: String, sig: String, extra: String, tgt: Dictionary) -> void:
	nsig += 1
	seq += 1
	var a: Area3D = area_a if area == "A" else area_b
	var f := {"area": area, "sig": sig, "ov": ov(a), "ovn": ovn(a),
			"mon": str(a.monitoring)}
	for k in tgt:
		f[k] = tgt[k]
	_rec("SIG", f)
	print("SIG sig=%s.%s pf=%d seq=%d %s ovA=%s ovn=%s mon=%s" % [
		area, sig, pf(), seq, extra, f["ov"], f["ovn"], f["mon"]])


func _act(msg: String) -> void:
	seq += 1
	_rec("ACT", {"msg": msg})
	print("ACT %s pf=%d seq=%d" % [msg, pf(), seq])


# ---------------------------------------------------------------- signal handlers
func _on_a_body_entered(b: Node3D) -> void:
	sig_row("A", "body_entered", "body=%s" % bn(b), {"body": bn(b)})
	if case == "tsig":
		PhysicsServer3D.body_set_state(rids[0],
				PhysicsServer3D.BODY_STATE_TRANSFORM,
				Transform3D(Basis(), Vector3(home_x[0], 5, 0)))
		_act("TSIG teleport-out inside body_entered handler")


func _on_a_body_exited(b: Node3D) -> void:
	sig_row("A", "body_exited", "body=%s" % bn(b), {"body": bn(b)})


func _on_a_body_shape_entered(_r: RID, b: Node3D, bsi: int, lsi: int) -> void:
	sig_row("A", "body_shape_entered", "body=%s bsi=%d lsi=%d" % [bn(b), bsi, lsi],
			{"body": bn(b), "bsi": bsi, "lsi": lsi})
	if case == "monsig":
		area_a.monitoring = false
		_act("MONSIG monitoring=false inside body_shape_entered handler readback=%s" %
				str(area_a.monitoring))


func _on_a_body_shape_exited(_r: RID, b: Node3D, bsi: int, lsi: int) -> void:
	sig_row("A", "body_shape_exited", "body=%s bsi=%d lsi=%d" % [bn(b), bsi, lsi],
			{"body": bn(b), "bsi": bsi, "lsi": lsi})


func _on_a_area_entered(a: Area3D) -> void:
	sig_row("A", "area_entered", "area=%s" % a.name, {"tgt": a.name})


func _on_a_area_exited(a: Area3D) -> void:
	sig_row("A", "area_exited", "area=%s" % a.name, {"tgt": a.name})


func _on_a_area_shape_entered(_r: RID, a: Area3D, asi: int, lsi: int) -> void:
	sig_row("A", "area_shape_entered", "area=%s asi=%d lsi=%d" % [a.name, asi, lsi],
			{"tgt": a.name, "asi": asi, "lsi": lsi})


func _on_a_area_shape_exited(_r: RID, a: Area3D, asi: int, lsi: int) -> void:
	sig_row("A", "area_shape_exited", "area=%s asi=%d lsi=%d" % [a.name, asi, lsi],
			{"tgt": a.name, "asi": asi, "lsi": lsi})


func _on_b_body_entered(b: Node3D) -> void:
	sig_row("B", "body_entered", "body=%s" % bn(b), {"body": bn(b)})


func _on_b_body_exited(b: Node3D) -> void:
	sig_row("B", "body_exited", "body=%s" % bn(b), {"body": bn(b)})


func _on_b_area_entered(a: Area3D) -> void:
	sig_row("B", "area_entered", "area=%s" % a.name, {"tgt": a.name})


func _on_b_area_exited(a: Area3D) -> void:
	sig_row("B", "area_exited", "area=%s" % a.name, {"tgt": a.name})


# ---------------------------------------------------------------- callbacks
func on_if(b: Node3D, st: PhysicsDirectBodyState3D) -> void:
	if done:
		return
	ifc += 1
	tick_if += 1
	seq += 1
	_rec("IF", {"body": b.name})
	print("IF pf=%d seq=%d body=%s" % [pf(), seq, b.name])
	if case == "tif" and pf() == 24:
		st.transform = Transform3D(Basis(), Vector3(home_x[0], 5, 0))
		_act("TIF state.transform=(%s,5.0000) written inside _integrate_forces" %
				("%.4f" % home_x[0]))
	if case == "monif" and pf() == 24:
		area_a.monitoring = false
		_act("MONIF monitoring=false inside _integrate_forces readback=%s" %
				str(area_a.monitoring))


func on_f() -> void:
	if done:
		return
	tick_f += 1
	seq += 1
	var ova := ov(area_a)
	_rec("F", {"ovA": ova})
	print("F pf=%d seq=%d ovA=%s" % [pf(), seq, ova])


func budget() -> int:
	match case:
		"enter", "multi", "tele", "telefr", "monif", "monsig", "moncycle", \
				"monoff0", "monoff", "monitoff":
			return 44
		"enter0", "freeq", "freerid", "tif", "tsig", "areasig", "bodysig":
			return 34
		"prio":
			return 24
	return 20


func _teleport(idx: int, p: Vector3, tag: String) -> void:
	PhysicsServer3D.body_set_state(rids[idx],
			PhysicsServer3D.BODY_STATE_TRANSFORM, Transform3D(Basis(), p))
	_act("%s idx=%d ball=%s" % [tag, idx, v3(p)])


func _teleport_area_b(p: Vector3, tag: String) -> void:
	PhysicsServer3D.area_set_transform(rid_b, Transform3D(Basis(), p))
	_act("%s areaB=%s" % [tag, v3(p)])


func on_e() -> void:
	if done:
		return
	tick_e += 1
	var t := tick_e
	match case:
		"enter":
			if t == 34:
				_teleport(0, Vector3(home_x[0], 5, 0), "OUT")
		"enter0":
			if t == 24:
				_teleport(0, Vector3(home_x[0], 5, 0), "OUT")
		"multi":
			if t == 34:
				for i in range(balls.size()):
					_teleport(i, Vector3(home_x[i], 5, 0), "OUT")
		"tele", "telefr":
			if t == 24:
				for i in range(balls.size()):
					_teleport(i, Vector3(home_x[i], 0.5, 0), "IN")
			if t == 34:
				for i in range(balls.size()):
					_teleport(i, Vector3(home_x[i], 5, 0), "OUT")
		"freeq":
			if t == 24:
				ball_gone = true
				balls[0].queue_free()
				_act("FREEQ queue_free(ball) mid-overlap")
		"freerid":
			if t == 24:
				ball_gone = true
				PhysicsServer3D.free_rid(rids[0])
				_act("FREERID PhysicsServer3D.free_rid(ball) mid-overlap")
		"monoff":
			if t == 20:
				area_a.monitoring = false
				_act("MONOFF monitoring=false readback=%s" % str(area_a.monitoring))
			if t == 26:
				area_a.monitoring = true
				_act("MONOFF monitoring=true readback=%s" % str(area_a.monitoring))
			if t == 34:
				_teleport(0, Vector3(home_x[0], 5, 0), "OUT")
		"monitoff":
			if t == 20:
				area_b.monitorable = false
				_act("MONITOFF monitorable=false readback=%s" %
						str(area_b.monitorable))
			if t == 26:
				area_b.monitorable = true
				_act("MONITOFF monitorable=true readback=%s" %
						str(area_b.monitorable))
			if t == 34:
				_teleport_area_b(Vector3(100, 0, 0), "B_AWAY")
		"prio":
			if t == 12:
				area_a.priority = 5
				area_b.priority = 0
				_act("PRIO swap A=%d B=%d" % [area_a.priority, area_b.priority])
		"tif":
			pass
		"tsig":
			pass
		"monif":
			if t == 30:
				area_a.monitoring = true
				_act("MONIF monitoring=true readback=%s" % str(area_a.monitoring))
		"monsig":
			if t == 30:
				area_a.monitoring = true
				_act("MONSIG monitoring=true readback=%s" % str(area_a.monitoring))
		"moncycle":
			if t == 24:
				area_a.monitoring = false
				area_a.monitoring = true
				_act("MONCYCLE monitoring=false;true readback=%s" %
						str(area_a.monitoring))
		"monoff0":
			if t == 30:
				area_a.monitoring = true
				_act("MONOFF0 monitoring=true readback=%s" %
						str(area_a.monitoring))
		"areasig":
			if t == 24:
				_teleport_area_b(Vector3(100, 0, 0), "B_AWAY")
		"bodysig":
			if t == 24:
				_teleport(0, Vector3(home_x[0], 5, 0), "OUT")

	seq += 1
	var by := body_ys()
	var ova := ov(area_a)
	var ovb := ov(area_b)
	_rec("E", {"t": t, "by": by, "ovA": ova, "ovB": ovb,
			"ifc": ifc, "monA": str(area_a.monitoring)})
	print("E pf=%d seq=%d t=%d by=%s ovA=%s ovB=%s ifc=%d monA=%s monB=%s" % [
		pf(), seq, t, by, ova, ovb, ifc,
		str(area_a.monitoring), str(area_b.monitorable)])
	ifc = 0
	if t >= budget() and not done:
		done = true
		done_idx = ev.size()
		print("DONE case=%s engine=%s nif=%d nsig=%d ne=%d nf=%d seq=%d" % [
			case, str(ProjectSettings.get_setting("physics/3d/physics_engine")),
			tick_if, nsig, tick_e, tick_f, seq])
		_finish()


func _finish() -> void:
	for b in balls:
		if is_instance_valid(b):
			b.queue_free()
	await process_frame
	print("DONE_ALL case=%s seq=%d" % [case, seq])
	_digest()
	print("M DONE case=%s" % case)
	quit(0)


# ---------------------------------------------------------------- digest
func _sig_cls(sidx: int) -> String:
	var s = ev[sidx]
	if done_idx >= 0 and sidx >= done_idx:
		return "teardown"
	var T: int = s["pf"]
	var e_idx := -1
	var if_first := -1
	for i in ev.size():
		var e: Dictionary = ev[i]
		if e["k"] == "E" and e["pf"] == T:
			e_idx = i
			break
	for i in ev.size():
		var e: Dictionary = ev[i]
		if e["k"] == "IF" and e["pf"] == T:
			if_first = i
			break
	if e_idx < 0:
		return "other"
	if sidx < e_idx:
		if if_first < 0:
			return "no_if"
		return "in_step" if sidx > if_first else "pre_if"
	for i in range(e_idx + 1, sidx):
		var e: Dictionary = ev[i]
		if e["k"] == "F" and e["pf"] == T:
			return "idle"
	return "post_e"


func _anchor(tpf: int) -> void:
	for e in ev:
		if e["k"] == "E" and e["pf"] == tpf:
			var f: Dictionary = e["f"]
			print("M %s e%d by=%s ovA=%s ovB=%s ifc=%d" % [
					case, tpf, f["by"], f["ovA"], f["ovB"], f["ifc"]])
			return


func _emit_sig(sidx: int, cls: String, nlabel: int, canon: bool) -> void:
	var f: Dictionary = ev[sidx]["f"]
	var tgt := ""
	if f.has("body"):
		tgt += " body=%s" % f["body"]
	if f.has("tgt"):
		tgt += " area=%s" % f["tgt"]
	if f.has("bsi"):
		tgt += " bsi=%d lsi=%d" % [f["bsi"], f["lsi"]]
	if f.has("asi"):
		tgt += " asi=%d lsi=%d" % [f["asi"], f["lsi"]]
	if canon:
		print("M %s s%d pf=%d cls=%s sig=%s.%s%s" % [
				case, nlabel, ev[sidx]["pf"], cls, f["area"], f["sig"], tgt])
	else:
		var nms: Array = f["ovn"].split(",")
		nms.sort()
		print("M %s s%d pf=%d cls=%s sig=%s.%s%s ov=%s n=%s m=%s" % [
				case, nlabel, ev[sidx]["pf"], cls, f["area"], f["sig"], tgt,
				f["ov"], "-".join(nms), f["mon"]])


func _facts(sigs: Array, clsmap: Dictionary) -> void:
	match case:
		"enter", "enter0", "tele", "tif", "tsig":
			var en := 0
			var ex := 0
			for i in sigs:
				var f: Dictionary = ev[i]["f"]
				if f["sig"] == "body_entered" and en == 0:
					en = ev[i]["pf"]
				if f["sig"] == "body_exited" and ex == 0:
					ex = ev[i]["pf"]
			print("M %s facts entry=%s exit=%s" % [
					case, str(en) if en else "-", str(ex) if ex else "-"])
		"telefr":
			var en := 0
			var ex := 0
			for i in sigs:
				var f: Dictionary = ev[i]["f"]
				if f["sig"] == "body_entered" and clsmap[i] != "teardown" and en == 0:
					en = ev[i]["pf"]
				if f["sig"] == "body_exited" and clsmap[i] != "teardown" and ex == 0:
					ex = ev[i]["pf"]
			print("M %s facts detected=%d entry=%s exit=%s" % [
					case, 1 if en else 0, str(en) if en else "-",
					str(ex) if ex else "-"])
		"freeq":
			var dup_pf := 0
			var dup_cls := "-"
			var stale := "-"
			for i in sigs:
				var f: Dictionary = ev[i]["f"]
				if clsmap[i] == "post_e" and f["sig"] == "body_exited":
					stale = f["ovn"]
				if f["sig"] == "body_shape_exited" and f["body"] == "<null>":
					dup_pf = ev[i]["pf"]
					dup_cls = clsmap[i]
			print("M %s facts stale_ovn=%s dup=%s dup_cls=%s" % [
					case, stale,
					"body_shape_exited@%d" % dup_pf if dup_pf else "-", dup_cls])
		"freerid":
			var ex := 0
			var ex_cls := "-"
			for i in sigs:
				var f: Dictionary = ev[i]["f"]
				if f["sig"] == "body_exited" and ex == 0:
					ex = ev[i]["pf"]
					ex_cls = clsmap[i]
			print("M %s facts exit=%s exit_cls=%s" % [
					case, str(ex) if ex else "-", ex_cls])
		"monoff", "monif":
			var flush_n := 0
			var redet := 0
			for i in sigs:
				var f: Dictionary = ev[i]["f"]
				if f["mon"] == "false":
					flush_n += 1
				if f["sig"] == "body_entered" and ev[i]["pf"] > 20:
					redet = ev[i]["pf"]
			print("M %s facts flush_sigs=%d in_write=%d redetect=%s" % [
					case, flush_n, flush_n,
					str(redet) if redet else "none"])
		"monsig":
			var redet := 0
			var tried := 0
			for i in sigs:
				var f: Dictionary = ev[i]["f"]
				if f["sig"] == "body_entered" and ev[i]["pf"] > 21:
					redet = ev[i]["pf"]
			for e in ev:
				if e["k"] == "ACT" and "MONSIG monitoring=false" in e["f"]["msg"]:
					tried = 1
			print("M %s facts refused=%d readback=%s flush_sigs=0 redetect=%s" % [
					case, tried, str(area_a.monitoring),
					str(redet) if redet else "none"])
		"moncycle":
			var flush_n := 0
			var redet := 0
			for i in sigs:
				var f: Dictionary = ev[i]["f"]
				if f["mon"] == "false":
					flush_n += 1
				if f["sig"] == "body_entered" and ev[i]["pf"] > 24 \
						and clsmap[i] != "teardown":
					redet = ev[i]["pf"]
			print("M %s facts flush_sigs=%d in_write=%d redetect=%s" % [
					case, flush_n, flush_n,
					str(redet) if redet else "none"])
		"monoff0":
			var redet := 0
			for i in sigs:
				var f: Dictionary = ev[i]["f"]
				if f["sig"] == "body_entered":
					redet = ev[i]["pf"]
			print("M %s facts off_from_init=1 redetect=%s" % [
					case, str(redet) if redet else "none"])
		"multi":
			var grow: Array = []
			var shrink: Array = []
			var entry_bodies: Array = []
			var exit_bodies: Array = []
			var adjacent := 1
			var prev_idx := -1
			var prev_pair := ""
			for i in sigs:
				var f: Dictionary = ev[i]["f"]
				if ev[i]["pf"] == 21 and f["sig"] == "body_entered":
					entry_bodies.append(f["body"])
					grow.append(f["ov"].split("/")[0])
				if ev[i]["pf"] == 35 and f["sig"] == "body_exited":
					exit_bodies.append(f["body"])
					shrink.append(f["ov"].split("/")[0])
				var pair: String = "%s|%s|%s" % [ev[i]["pf"], f["body"],
						f["sig"].trim_prefix("body_shape_").trim_prefix("body_")]
				if f["sig"].begins_with("body_shape_") \
						and (prev_idx != i - 1 or prev_pair != pair):
					adjacent = 0
				if f["sig"].begins_with("body_"):
					prev_idx = i
					prev_pair = pair
			var eb := entry_bodies.duplicate()
			eb.sort()
			var xb := exit_bodies.duplicate()
			xb.sort()
			# Order-free facts pin on every backend; emission-order
			# correlations (seqeq = entry order == exit order, pairs =
			# each body's exit pair emitted adjacently) are stable on
			# GodotPhysics only — Jolt flips body order ~12% under load
			# (r93-boundary §4), so those fields stay '-' there.
			var eng := str(ProjectSettings.get_setting(
					"physics/3d/physics_engine"))
			var order_pin := eng == "Default" or eng == "DEFAULT" \
					or eng == "GodotPhysics" or eng == ""
			var seteq := "-"
			if eb:
				seteq = str(1 if eb == xb else 0)
			print("M %s facts entry_bodies=%s grow=%s shrink=%s seteq=%s "
					% [case, ",".join(eb) if eb else "-",
					",".join(grow) if grow else "-",
					",".join(shrink) if shrink else "-", seteq]
					+ "seqeq=%s pairs=%s" % [
					str(1 if entry_bodies == exit_bodies else 0)
						if (order_pin and entry_bodies) else "-",
					str(adjacent) if order_pin else "-"])
		"areasig", "monitoff":
			var entry_seq: Array = []
			var exits := {}
			var drop := 0
			var reenter := 0
			for i in sigs:
				var f: Dictionary = ev[i]["f"]
				var lbl := "%s.%s" % [f["area"], f["sig"]]
				var p: int = ev[i]["pf"]
				if p == 2:
					entry_seq.append(lbl)
				elif p == 25 or (case == "monitoff" and p in [21, 27, 35]):
					if not exits.has(p):
						exits[p] = []
					exits[p].append(lbl)
				if case == "monitoff":
					if f["sig"] == "area_exited" and p == 21:
						drop = 21
					if f["sig"] == "area_entered" and p == 27:
						reenter = 27
			entry_seq.sort()
			var epfs: Array = exits.keys()
			epfs.sort()
			var esegs: Array = []
			for p in epfs:
				var lst: Array = exits[p]
				lst.sort()
				esegs.append("pf%d:%s" % [p, ",".join(lst)])
			var extra := ""
			if case == "monitoff":
				extra = " drop=%s reenter=%s" % [
						str(drop) if drop else "none",
						str(reenter) if reenter else "none"]
			print("M %s facts entry=%s exit=%s%s" % [
					case, ",".join(entry_seq) if entry_seq else "-",
					";".join(esegs) if esegs else "-", extra])
		"bodysig":
			var bsi_in: Array = []
			var exit_seq: Array = []
			for i in sigs:
				var f: Dictionary = ev[i]["f"]
				if ev[i]["pf"] == 2 and f["sig"] == "body_shape_entered":
					bsi_in.append(str(f["bsi"]))
				elif ev[i]["pf"] == 25:
					var lbl: String = f["sig"]
					if f["sig"].begins_with("body_shape_"):
						lbl += "(%s)" % str(f["bsi"])
					exit_seq.append(lbl)
			print("M %s facts enter_bsi=%s exit=%s" % [
					case, ",".join(bsi_in) if bsi_in else "-",
					",".join(exit_seq) if exit_seq else "-"])
		"prio":
			var bys := {}
			for e in ev:
				if e["k"] == "E":
					bys[e["f"]["t"]] = e["f"]["by"]
			var d := {}
			for t in [3, 11, 13, 14, 24]:
				if bys.has(t) and bys.has(t - 1):
					d[t] = "%.4f" % (float(bys[t]) - float(bys[t - 1]))
			print("M %s facts swap_t=12 dby3=%s dby11=%s dby13=%s dby14=%s" % [
					case, d.get(3, "-"), d.get(11, "-"),
					d.get(13, "-"), d.get(14, "-")])


func _digest() -> void:
	var anchors := {
		"enter": [1, 20, 21, 34, 35, 44],
		"enter0": [1, 2, 24, 25, 34],
		"tele": [23, 24, 25, 34, 35, 44],
		"telefr": [23, 24, 25, 34, 35, 44],
		"multi": [20, 21, 34, 35, 44],
		"freeq": [23, 24, 25, 34],
		"freerid": [23, 24, 25, 34],
		"tif": [23, 24, 25, 34],
		"tsig": [20, 21, 22, 34],
		"monoff": [19, 20, 26, 27, 34, 35, 44],
		"monif": [23, 24, 30, 31, 44],
		"monsig": [20, 21, 30, 31, 44],
		"moncycle": [23, 24, 25, 44],
		"monoff0": [29, 30, 31, 44],
		"areasig": [1, 2, 24, 25, 34],
		"bodysig": [1, 2, 24, 25, 34],
		"monitoff": [19, 20, 21, 26, 27, 34, 35, 44],
		"prio": [1, 2, 3, 11, 12, 13, 23, 24],
	}
	var sigs: Array = []
	for i in ev.size():
		if ev[i]["k"] == "SIG":
			sigs.append(i)
	var clsmap := {}
	var census := {"in_step": 0, "no_if": 0, "post_e": 0, "pre_if": 0,
			"idle": 0, "other": 0, "teardown": 0}
	for i in sigs:
		clsmap[i] = _sig_cls(i)
		census[clsmap[i]] += 1
	for tpf in anchors.get(case, []):
		_anchor(tpf)
	if case in CANON_CASES:
		# Canonical, order-free sig set: sorted by (pf, area, sig, target).
		# Emission order is '#' diagnostic only — never a pin.
		var canon := sigs.duplicate()
		canon.sort_custom(func(a, b):
			var fa: Dictionary = ev[a]["f"]
			var fb: Dictionary = ev[b]["f"]
			var ka := "%03d|%s|%s|%s" % [ev[a]["pf"], str(fa["area"]),
					str(fa["sig"]), str(fa.get("body", fa.get("tgt", "-")))]
			var kb := "%03d|%s|%s|%s" % [ev[b]["pf"], str(fb["area"]),
					str(fb["sig"]), str(fb.get("body", fb.get("tgt", "-")))]
			return ka < kb)
		var k := 0
		for i in canon:
			k += 1
			_emit_sig(i, clsmap[i], k, true)
		var by_pf := {}
		for i in sigs:
			var f: Dictionary = ev[i]["f"]
			var p: int = ev[i]["pf"]
			if not by_pf.has(p):
				by_pf[p] = []
			var tgt: String = str(f.get("body", f.get("tgt", "")))
			by_pf[p].append("%s.%s%s" % [f["area"], f["sig"],
					"@%s" % tgt if tgt else ""])
		var keys: Array = by_pf.keys()
		keys.sort()
		var segs: Array = []
		for p in keys:
			segs.append("pf%d=[%s]" % [p, ",".join(by_pf[p])])
		print("# %s order %s" % [case, " ".join(segs)])
	else:
		var k := 0
		for i in sigs:
			k += 1
			_emit_sig(i, clsmap[i], k, false)
	_facts(sigs, clsmap)
	print("M %s census in_step=%d no_if=%d post_e=%d pre_if=%d idle=%d "
			% [case, census["in_step"], census["no_if"], census["post_e"],
			census["pre_if"], census["idle"]]
			+ "other=%d teardown=%d nif=%d ne=%d nf=%d nsig=%d" % [
			census["other"], census["teardown"], tick_if, tick_e, tick_f, nsig])


# ---------------------------------------------------------------- setup
func _mk_area(nm: String, size: Vector3, pos: Vector3) -> Area3D:
	var a := Area3D.new()
	a.name = nm
	var cs := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	cs.shape = box
	a.add_child(cs)
	a.position = pos
	root.add_child(a)
	return a


func _mk_ball(nm: String, pos: Vector3) -> RB:
	var b := RB.new()
	b.name = nm
	b.probe = self
	var col := CollisionShape3D.new()
	var sp := SphereShape3D.new()
	sp.radius = 0.5
	col.shape = sp
	b.add_child(col)
	b.position = pos
	b.max_contacts_reported = 8
	if case == "tele":
		b.gravity_scale = 0.0
		b.can_sleep = false
	if case == "telefr":
		b.freeze = true
	if case == "prio":
		b.can_sleep = false
	root.add_child(b)
	return b


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		case = args[0]

	floor_node = StaticBody3D.new()
	var fcol := CollisionShape3D.new()
	var fbox := BoxShape3D.new()
	fbox.size = Vector3(20, 1, 20)
	fcol.shape = fbox
	floor_node.add_child(fcol)
	floor_node.position = Vector3(0, -1, 0)
	root.add_child(floor_node)

	match case:
		"prio":
			area_a = _mk_area("A", Vector3(6, 6, 6), Vector3(0, 3, 0))
			area_b = _mk_area("B", Vector3(4, 4, 4), Vector3(0, 3, 0))
			area_a.gravity_space_override = Area3D.SPACE_OVERRIDE_REPLACE
			area_a.gravity = 0.0
			area_a.priority = 0
			area_b.gravity_space_override = Area3D.SPACE_OVERRIDE_REPLACE
			area_b.gravity = 30.0
			area_b.gravity_direction = Vector3(0, -1, 0)
			area_b.priority = 1
		"monitoff", "areasig":
			area_a = _mk_area("A", Vector3(6, 2, 6), Vector3(0, 0.6, 0))
			area_b = _mk_area("B", Vector3(2, 2, 2), Vector3(0, 0.6, 0))
		_:
			area_a = _mk_area("A", Vector3(6, 2, 6), Vector3(0, 0.6, 0))
			area_b = _mk_area("B", Vector3(2, 2, 2), Vector3(100, 0, 0))
	rid_a = area_a.get_rid()
	rid_b = area_b.get_rid()

	var y0 := 2.6
	if case in ["enter0", "monitoff", "areasig", "bodysig", "monoff"]:
		y0 = 0.2
	if case == "prio":
		y0 = 3.0
	if case == "multi":
		for i in range(2):
			var x := -1.0 if i == 0 else 1.0
			home_x.append(x)
			var b := _mk_ball("b%d" % (i + 1), Vector3(x, y0, 0))
			balls.append(b)
			rids.append(b.get_rid())
	else:
		home_x.append(0.0)
		var p := Vector3(100, 5, 0) if (case == "tele" or case == "telefr") \
				else Vector3(0, y0, 0)
		var b := _mk_ball("ball", p)
		balls.append(b)
		rids.append(b.get_rid())
	if case == "bodysig":
		var bcol2 := CollisionShape3D.new()
		var bsphere2 := SphereShape3D.new()
		bsphere2.radius = 0.4
		bcol2.shape = bsphere2
		bcol2.position = Vector3(0, 0.35, 0)
		balls[0].add_child(bcol2)
	if case == "monoff0":
		area_a.monitoring = false

	area_a.body_entered.connect(_on_a_body_entered)
	area_a.body_exited.connect(_on_a_body_exited)
	area_a.body_shape_entered.connect(_on_a_body_shape_entered)
	area_a.body_shape_exited.connect(_on_a_body_shape_exited)
	area_a.area_entered.connect(_on_a_area_entered)
	area_a.area_exited.connect(_on_a_area_exited)
	area_a.area_shape_entered.connect(_on_a_area_shape_entered)
	area_a.area_shape_exited.connect(_on_a_area_shape_exited)
	area_b.body_entered.connect(_on_b_body_entered)
	area_b.body_exited.connect(_on_b_body_exited)
	area_b.area_entered.connect(_on_b_area_entered)
	area_b.area_exited.connect(_on_b_area_exited)

	var w := Watcher.new()
	w.probe = self
	root.add_child(w)

	print("M0 case=%s engine=%s" % [
		case, str(ProjectSettings.get_setting("physics/3d/physics_engine"))])
	print("PRE case=%s engine=%s threaded=%s a_mon=%s a_monable=%s balls=%d" % [
		case, str(ProjectSettings.get_setting("physics/3d/physics_engine")),
		str(ProjectSettings.get_setting("physics/3d/run_on_separate_thread", false)),
		str(area_a.monitoring), str(area_a.monitorable), balls.size()])
