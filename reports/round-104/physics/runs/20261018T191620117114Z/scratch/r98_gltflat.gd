extends SceneTree
# r98 GLTF/GLB runtime-import lattice — parent fixture.
#
# Children are byte-identical copies of the r98 scout probes (gltf.gd,
# gltf_tr.gd) and the r98 boundary probes (r98b_inv.gd, r98b_mode.gd), run
# under their ORIGINAL res:// names out of a per-cell project dir, so a
# child receipt reproduces the scout's/boundary's receipt byte-for-byte
# (the backtrace-name hazard is avoided by construction). Each child gets
# a fresh project dir plus a copy of the vendored res://r98assets/ set
# under res://assets/, so no .godot import cache can pre-exist a child
# (the cold premise; a post-run census pins .godot absent for every
# child). The user-data cells seed app_userdata/<APP> exactly the way the
# scout/boundary drivers did.
#
# Digest cell:
#   <name>{rc=<n>,sha=<16 hex>,<field>=<value>,...,ee=<n>,beq=<0|1>,gd=0}
# `sha` is sha256-16 over the child's NORMALIZED contract stream. Dropped
# or masked before hashing (declared normalizations, never
# content-changing):
#   - the "Godot Engine v..." banner and empty lines;
#   - the exact 2-line Jolt job-system warning, allowlisted by text and
#     tolerated at ANY position (never observed on this surface — counted
#     in w as a guard, per the r96/r97 hazard);
#   - runtime object ids `<Class#12345>` -> `<Class#N>` (allocation-order
#     artifacts; none observed on this surface);
#   - the user-data-dir absolute prefix -> `UD/` (the doc_abs/ext_bin_abs
#     receipts are $HOME-pinned; the claim is the path FORM, not the
#     host);
#   - crash-dump ASLR lines only (no crash cells exist on this surface):
#     "Load address:" -> "Load address: A" and "[n] ...0x..." -> "[n] F".
# Expected-error classes (per-cell `e` list) stay in the hashed stream
# and are counted in `ee`; any OTHER line matching ERROR:/SCRIPT ERROR/
# Parse Error/handle_crash/ObjectDB-leak lands in `ue` and fails the cell.
# `gd` is the post-run .godot census (0 = absent, pinned; a child that
# mints an import cache fails the premise).
#
# Laws landed (r98-scout folded through r98-boundary §0 verdicts):
#   load    The ResourceLoader dead-end, premise-scoped: no loader is
#           registered for .glb/.gltf under --headless without the import
#           cache — every load_* arm is `-> null` (valid, corrupt, empty,
#           missing, upper-case alike; only the missing file takes the
#           `Resource file not found` path instead of `No loader found`).
#   doc     The GLTFDocument door: append_from_file/append_from_buffer
#           work in a bare --headless --script SceneTree on res://,
#           absolute, user://, and cwd-relative paths; err=7
#           (ERR_FILE_CANT_OPEN) separates missing from err=43
#           (ERR_PARSE_ERROR); a structurally-empty GLB imports
#           (err=0, WARNING, unnamed empty Node3D); generate_scene roots
#           at a fresh Node3D named after the glTF *scene*; the
#           scene->GLB->scene round-trip keeps names/transforms but
#           realizes BoxMesh to ArrayMesh.
#   sniff   The container is content-sniffed on the 4-byte magic, the
#           extension ignored both directions (GLB-in-.gltf and
#           JSON-in-.glb both import); the 43 family is four distinct
#           message paths (JSON text _parse, binary JSON _parse_glb,
#           first-chunk _parse_glb, buffer _parse_buffers); declared
#           total length and container version are unvalidated.
#   extbin  External buffer URIs resolve against the file's own dir /
#           the append_from_buffer base; empty base + relative URI =
#           ERR_INVALID_PARAMETER surfaced as 43; a res:// URI is
#           blind-concatenated.
#   cls     18 GLTF-domain classes exist + instantiate (GLTFSkin is the
#           18th, methods=20); GLTFObjectModelProperty is the lone plain
#           RefCounted; set_root_nodes lives on GLTFState
#           (+ root_nodes property), GLTFDocument has root_node_mode
#           instead; 13 supported extensions; ResourceLoader.exists()
#           is false for the existing .glb/.gltf/.GLB assets.
#   write   write_to_filesystem works: .glb output byte-identical to
#           generate_buffer, .gltf writes a sidecar .bin, re-imports.
#   tr      Transform fidelity: TRS and matrix forms land with zero
#           drift (matrix PivotB -> pos (7,8,9)).
#   phys    An engine-authored OMI physics payload exports
#           byte-identically on all three backends and imports to
#           RigidBody3D+CollisionShape3D identically — backend-inert
#           even with a physics extension present.
#   var     The whole surface is tps-inert (30/120/5) and
#           rate-flag-inert (--fixed-fps 60/120, --time-scale 0.5).
#
# Deliberately NOT authored (premise or scope): the warm-cache
# PackedScene flip (boundary V12 — the lattice premise wipes .godot per
# child; warm-cache is the editor-pipeline surface), skins/animations/
# textures/cameras/lights payloads, GLTFDocumentExtension runtime hooks,
# exported-template context, and whether OMI bodies enter a physics
# space once tree-owned (the boundary measures import, not simulation).

const CHUNK := 8
const BOUND_S := 14

const JOLT := "3d/physics_engine=\"Jolt Physics\"\n"
const DUMMY := "3d/physics_engine=\"Dummy\"\n"
const APP := "R98Scout"

const WARN1 := "WARNING: Jolt Physics job system exceeded the maximum number of jobs. This should not happen. Please report this. Waiting for jobs to become available..."
const WARN2 := "     at: CreateJob (modules/jolt_physics/spaces/jolt_job_system.cpp:123)"

# Expected-error allowlist heads (exact line or prefix). A matching
# ERROR-class head is kept in the hashed stream and counted in `ee`;
# continuation `at:`/backtrace lines are not error-class and hash
# normally. Verbatim heads come from the r98-scout/boundary receipts.
const ERR_ALLOW := {
	"noload": [
		"ERROR: No loader found for resource:",
		"ERROR: Resource file not found:",
		"ERROR: Error loading resource: '",
	],
	"cantopen": [
		"ERROR: Can't open file at path",
	],
	"jsparse": [
		"ERROR: glTF: Error parsing .gltf JSON data:",
		"ERROR: Condition \"err != OK\" is true. Returning: err",
	],
	"glbparse": [
		"ERROR: glTF Binary: Error parsing .glb file's JSON data:",
		"ERROR: Condition \"err != OK\" is true. Returning: err",
	],
	"chunk": [
		"ERROR: Condition \"chunk_type != 0x4E4F534A\" is true.",
		"ERROR: Condition \"err != OK\" is true. Returning: err",
	],
	"extbuf": [
		"ERROR: glTF: Binary file not found:",
		"ERROR: Condition \"p_base_path.is_empty()\" is true.",
		"ERROR: Condition \"err != OK\" is true.",
	],
	"physbuf": [
		"ERROR: glTF: Buffer 0 has no data and cannot be loaded.",
	],
}

var PROJECTS := {}
var arm := ""
var parts: Array = []
var notes: Array = []
var _leak_re: RegEx
var _id_re: RegEx
var _load_re: RegEx
var _frame_re: RegEx
var ud_prefix := ""
var ud_dir := ""
var ud_pre_existed := false
var run_prefix := ""


func _d(name: String) -> String:
	# child dirs are namespaced by pid so two concurrent parent instances
	# (a rep sweep) can never share a child dir.
	return "%s%s" % [run_prefix, name]


func _base(tps: int) -> String:
	return ("[application]\n\nconfig/name=\"%s\"\n\n[physics]\n\n"
			+ "common/physics_ticks_per_second=%d\n") % [APP, tps]


func _build_projects() -> void:
	PROJECTS = {
		"gp60": _base(60),
		"jolt60": _base(60) + JOLT,
		"dummy60": _base(60) + DUMMY,
		"gp30": _base(30),
		"gp120": _base(120),
		"gp5": _base(5),
	}


func _initialize() -> void:
	_build_projects()
	run_prefix = "r98t%d_" % OS.get_process_id()
	ud_prefix = OS.get_user_data_dir().get_base_dir() + "/"
	ud_dir = ud_prefix.path_join(APP)
	ud_pre_existed = DirAccess.dir_exists_absolute(ud_dir)
	_leak_re = RegEx.new()
	_leak_re.compile("^WARNING: [1-9][0-9]* ObjectDB instances? (were|was) leaked at exit")
	_id_re = RegEx.new()
	_id_re.compile("#[0-9]+")
	_load_re = RegEx.new()
	_load_re.compile("^Load address:")
	_frame_re = RegEx.new()
	_frame_re.compile("^\\[(\\d+)\\] ")
	call_deferred("_run")


func _g(sub: String, f: Array = [], remap: Dictionary = {}) -> Dictionary:
	return {"sub": sub, "f": f, "as": remap}


func _glast(sub: String, name: String) -> Dictionary:
	return {"sub": sub, "last": name}


func _gtok(sub: String, idx: int, name: String) -> Dictionary:
	return {"sub": sub, "tok": idx, "as": name}


func _gbet(sub: String, l: String, r: String, name: String) -> Dictionary:
	return {"sub": sub, "between": [l, r], "as2": name}


# One cell per backend for `case`; jolt/dummy compare sha to the gp twin
# (beq) — the boundary measured every case byte-identical across
# GodotPhysics/Jolt/Dummy, so backend-invariance is pinned, not assumed.
func _be(case_name: String, probe: String, extra: Dictionary) -> Array:
	var out := []
	for be in ["gp", "jolt", "dummy"]:
		var spec := {"n": "%s@%s" % [case_name, be], "p": be + "60",
			"pr": probe, "c": case_name}
		spec.merge(extra)
		if be != "gp":
			spec["cmp"] = case_name + "@gp"
			spec["cmpf"] = "beq"
		out.append(spec)
	return out


func _doc_gets() -> Array:
	return [_g(" append_err=", ["append_err"], {"append_err": "err"}),
		_g(" nodes=", ["nodes", "meshes", "anims", "skel"]),
		_g("SCENE root=", ["root"]),
		_glast("MODESCENE ", "root")]


func _arm_cells() -> Dictionary:
	var load_gets := [_glast(" -> ", "res")]
	var cells := {}
	cells["load"] = (
		_be("load_glb", "gltf", {"e": ["noload"], "gets": load_gets})
		+ _be("load_gltf", "gltf", {"e": ["noload"], "gets": load_gets})
		+ _be("load_missing", "gltf", {"e": ["noload"], "gets": load_gets})
		+ _be("load_badmagic", "gltf", {"e": ["noload"], "gets": load_gets})
		+ _be("load_badjson", "gltf", {"e": ["noload"], "gets": load_gets})
		+ _be("load_empty", "gltf", {"e": ["noload"], "gets": load_gets})
		+ _be("load_upper", "r98b_mode", {"e": ["noload"], "gets": load_gets}))
	cells["doc"] = (
		_be("doc_file", "gltf", {"gets": _doc_gets()})
		+ _be("doc_gltf", "gltf", {"gets": _doc_gets()})
		+ _be("doc_nodes", "gltf", {"gets": _doc_gets()})
		+ _be("doc_empty", "gltf", {"gets": _doc_gets()})
		+ _be("doc_missing", "gltf", {"e": ["cantopen"],
			"gets": [_g(" append_err=", ["append_err"], {"append_err": "err"})]})
		+ _be("doc_badmagic", "gltf", {"e": ["jsparse"],
			"gets": [_g(" append_err=", ["append_err"], {"append_err": "err"})]})
		+ _be("doc_badjson", "gltf", {"e": ["jsparse"],
			"gets": [_g(" append_err=", ["append_err"], {"append_err": "err"})]})
		+ _be("doc_buf", "gltf", {"gets": [
			_g("DOCBUF append_err=", ["append_err", "bytes"],
				{"append_err": "err"}),
			_g("DOCBUF root=", ["root"])]})
		+ _be("doc_abs", "gltf", {"seedu": true, "gets": _doc_gets()})
		+ _be("doc_user", "r98b_mode", {"seedu": true, "gets": _doc_gets()})
		+ _be("doc_rel", "r98b_mode", {"cwdp": true, "gets": _doc_gets()})
		+ _be("roundtrip", "gltf", {"gets": [
			_g("RT append_scene_err=", ["append_scene_err", "nodes", "meshes"],
				{"append_scene_err": "serr"}),
			_g("RT gen_buffer bytes=", ["bytes"]),
			_g("RT reimport_err=", ["reimport_err"], {"reimport_err": "rerr"}),
			_g("RTSCENE root=", ["root"], {"root": "rtroot"})]}))
	cells["sniff"] = (
		_be("glb_as_gltf", "r98b_mode", {"gets": _doc_gets()})
		+ _be("json_as_glb", "r98b_mode", {"gets": _doc_gets()})
		+ _be("magic_truncated", "r98b_mode", {"gets": _doc_gets()})
		+ _be("glb_version3", "r98b_mode", {"gets": _doc_gets()})
		+ _be("magic_only", "r98b_mode", {"e": ["chunk"],
			"gets": [_g(" append_err=", ["append_err"], {"append_err": "err"})]})
		+ _be("magic_badjson", "r98b_mode", {"e": ["glbparse"],
			"gets": [_g(" append_err=", ["append_err"], {"append_err": "err"})]})
		+ _be("badmagic_badjson", "r98b_mode", {"e": ["jsparse"],
			"gets": [_g(" append_err=", ["append_err"], {"append_err": "err"})]}))
	cells["extbin"] = (
		_be("ext_bin_file", "r98b_mode", {"gets": _doc_gets()})
		+ _be("ext_bin_abs", "r98b_mode", {"seedu": true, "gets": _doc_gets()})
		+ _be("ext_bin_buf_good", "r98b_mode", {"gets": [
			_g(" append_err=", ["append_err"], {"append_err": "err"}),
			_g(" nodes=", ["nodes", "meshes"]),
			_glast("MODEBUFSCENE ", "root")]})
		+ _be("ext_bin_buf_wrong", "r98b_mode", {"e": ["extbuf"],
			"gets": [_g(" append_err=", ["append_err"], {"append_err": "err"})]})
		+ _be("ext_bin_buf_empty", "r98b_mode", {"e": ["extbuf"],
			"gets": [_g(" append_err=", ["append_err"], {"append_err": "err"})]})
		+ _be("ext_resuri_file", "r98b_mode", {"e": ["extbuf"],
			"gets": [_g(" append_err=", ["append_err"], {"append_err": "err"})]})
		+ _be("ext_resuri_buf_empty", "r98b_mode", {"e": ["extbuf"],
			"gets": [_g(" append_err=", ["append_err"], {"append_err": "err"})]}))
	cells["cls"] = (
		_be("cls", "gltf", {"gets": [
			_g("GLTFCLS engine=", ["engine"], {"engine": "eng"}),
			_g("SPOT GLTFDocument", ["set_root_nodes"],
				{"set_root_nodes": "srn"}),
			_g("RECOG PackedScene=", ["PackedScene"], {"PackedScene": "recps"}),
			{"count": "CLS ", "has": "exists=true", "as": "classes"}]})
		+ _be("inv", "r98b_inv", {"gets": [
			_g("INVBOUND engine=", ["engine"], {"engine": "eng"}),
			_g("INV n_asked=", ["n_asked", "n_exists", "n_refcounted"],
				{"n_asked": "asked", "n_exists": "exists",
				 "n_refcounted": "refc"})]})
		+ _be("props", "r98b_inv", {"gets": [
			_g("PROPS has_set_root_nodes=", ["has_set_root_nodes"],
				{"has_set_root_nodes": "srn"}),
			_g("PROPS has_get_root_nodes=", ["has_get_root_nodes"],
				{"has_get_root_nodes": "grn"}),
			_g("PROPS GLTFDocument n_props=", ["n_props"], {"n_props": "docp"}),
			_g("PROPS GLTFState n_props=", ["n_props"], {"n_props": "stp"})]})
		+ _be("exts", "r98b_inv", {"gets": [
			_g("EXTS supported_n=", ["supported_n"], {"supported_n": "sup"}),
			_g("EXTS res_exists_glb=", ["res_exists_glb"],
				{"res_exists_glb": "exglb"}),
			_g("EXTS res_exists_gltf=", ["res_exists_gltf"],
				{"res_exists_gltf": "exgltf"}),
			_g("EXTS res_exists_upper=", ["res_exists_upper"],
				{"res_exists_upper": "exup"}),
			_g("EXTS res_exists_absent=", ["res_exists_absent"],
				{"res_exists_absent": "exabs"})]}))
	cells["write"] = _be("write", "r98b_inv", {"gets": [
		_g("WRITE gen_bytes=", ["gen_bytes"], {"gen_bytes": "gen"}),
		_g("WRITE write_glb_err=", ["write_glb_err"], {"write_glb_err": "werr"}),
		_g("WRITE file_bytes=", ["file_bytes", "equal_to_gen"],
			{"file_bytes": "fb", "equal_to_gen": "eqg"}),
		_g("WRITE reimport_err=", ["reimport_err"], {"reimport_err": "rerr"}),
		_g("WRITE write_gltf_err=", ["write_gltf_err"], {"write_gltf_err": "w2"}),
		_g("WRITE gltf_bytes=", ["gltf_bytes"], {"gltf_bytes": "gb"})]})
	cells["tr"] = [
		{"n": "nodes", "p": "gp60", "pr": "gltf_tr", "c": "nodes", "gets": [
			_g(" append_err=", ["append_err"], {"append_err": "err"}),
			_gtok("TR ", 1, "root"),
			_gbet("PivotB:Node3D", "pos=", " rot=", "pbpos")]},
		{"n": "tri", "p": "gp60", "pr": "gltf_tr", "c": "tri", "gets": [
			_g(" append_err=", ["append_err"], {"append_err": "err"}),
			_gtok("TR ", 1, "root"),
			_gbet("TriMesh:MeshInstance3D", "pos=", " rot=", "tmpos")]},
	]
	cells["var"] = [
		{"n": "doc_file", "p": "gp60", "pr": "gltf", "c": "doc_file",
			"gets": _doc_gets()},
		{"n": "roundtrip", "p": "gp60", "pr": "gltf", "c": "roundtrip",
			"gets": [_g("RT append_scene_err=", ["append_scene_err"],
				{"append_scene_err": "serr"}),
				_g("RT gen_buffer bytes=", ["bytes"]),
				_g("RT reimport_err=", ["reimport_err"], {"reimport_err": "rerr"})]},
		{"n": "doc_file_t30", "p": "gp30", "pr": "gltf", "c": "doc_file",
			"gets": _doc_gets(), "cmp": "doc_file", "cmpf": "eq"},
		{"n": "doc_file_t120", "p": "gp120", "pr": "gltf", "c": "doc_file",
			"gets": _doc_gets(), "cmp": "doc_file", "cmpf": "eq"},
		{"n": "doc_file_t5", "p": "gp5", "pr": "gltf", "c": "doc_file",
			"gets": _doc_gets(), "cmp": "doc_file", "cmpf": "eq"},
		{"n": "doc_empty_t30", "p": "gp30", "pr": "gltf", "c": "doc_empty",
			"cmp": "doc_empty_gp", "cmpf": "eq",
			"gets": _doc_gets()},
		{"n": "doc_empty_gp", "p": "gp60", "pr": "gltf", "c": "doc_empty",
			"gets": _doc_gets()},
		{"n": "load_glb_t120", "p": "gp120", "pr": "gltf", "c": "load_glb",
			"e": ["noload"], "cmp": "load_glb_gp", "cmpf": "eq",
			"gets": [_glast(" -> ", "res")]},
		{"n": "load_glb_gp", "p": "gp60", "pr": "gltf", "c": "load_glb",
			"e": ["noload"], "gets": [_glast(" -> ", "res")]},
		{"n": "doc_file_ff60g", "p": "gp60", "pr": "gltf", "c": "doc_file",
			"eargs": "--fixed-fps 60", "cmp": "doc_file", "cmpf": "eq",
			"gets": _doc_gets()},
		{"n": "doc_file_ff60j", "p": "jolt60", "pr": "gltf", "c": "doc_file",
			"eargs": "--fixed-fps 60", "cmp": "doc_file", "cmpf": "eq",
			"gets": _doc_gets()},
		{"n": "doc_file_ff60d", "p": "dummy60", "pr": "gltf", "c": "doc_file",
			"eargs": "--fixed-fps 60", "cmp": "doc_file", "cmpf": "eq",
			"gets": _doc_gets()},
		{"n": "doc_file_ff120", "p": "gp60", "pr": "gltf", "c": "doc_file",
			"eargs": "--fixed-fps 120", "cmp": "doc_file", "cmpf": "eq",
			"gets": _doc_gets()},
		{"n": "doc_file_ts", "p": "gp60", "pr": "gltf", "c": "doc_file",
			"eargs": "--time-scale 0.5", "cmp": "doc_file", "cmpf": "eq",
			"gets": _doc_gets()},
		{"n": "roundtrip_ts", "p": "gp60", "pr": "gltf", "c": "roundtrip",
			"eargs": "--time-scale 0.5", "cmp": "roundtrip", "cmpf": "eq",
			"gets": [_g("RT gen_buffer bytes=", ["bytes"]),
				_g("RT reimport_err=", ["reimport_err"], {"reimport_err": "rerr"})]},
	]
	return cells


func _run() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--arm="):
			arm = a.substr(6)
	var ok := false
	var cells := _arm_cells()
	if cells.has(arm):
		ok = _run_cells(cells[arm])
	elif arm == "phys":
		ok = _run_phys()
	else:
		print("FAIL r98_gltflat unknown arm=%s" % arm)
		_cleanup_userdir()
		quit(0)
		return
	for n in notes:
		print("# r98_gltflat %s %s" % [arm, n])
	_cleanup_userdir()
	if ok:
		print("PASS r98_gltflat %s %s" % [arm, " ".join(parts)])
	else:
		print("FAIL r98_gltflat %s %s" % [arm, " ".join(parts)])
	quit(0)


# --- user-data seed/cleanup ---------------------------------------------------

func _seed_userdir() -> void:
	DirAccess.make_dir_recursive_absolute(ud_dir)
	for f in ["tri.glb", "ext_bin.gltf", "ext.bin"]:
		var src := FileAccess.open("res://r98assets/" + f, FileAccess.READ)
		if src == null:
			continue
		var dst := FileAccess.open(ud_dir.path_join(f), FileAccess.WRITE)
		if dst == null:
			src.close()
			continue
		dst.store_buffer(src.get_buffer(src.get_length()))
		src.close()
		dst.close()


func _rm_rf(path: String) -> void:
	var d := DirAccess.open(path)
	if d == null:
		return
	for f in d.get_files():
		DirAccess.remove_absolute(path.path_join(f))
	for s in d.get_directories():
		_rm_rf(path.path_join(s))
	DirAccess.remove_absolute(path)


func _cleanup_userdir() -> void:
	if ud_pre_existed:
		# The dir outlived this fixture: remove only the seeded files;
		# engine logs a pre-existing dir collects are not ours to reap.
		for f in ["tri.glb", "ext_bin.gltf", "ext.bin"]:
			DirAccess.remove_absolute(ud_dir.path_join(f))
	elif DirAccess.dir_exists_absolute(ud_dir):
		_rm_rf(ud_dir)


# --- scanner ----------------------------------------------------------------

func _sha16(lines: Array) -> String:
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update("\n".join(lines).to_utf8_buffer())
	return ctx.finish().hex_encode().substr(0, 16)


func _mask_ids(line: String) -> String:
	return _id_re.sub(line, "#N", true)


func _allowed(line: String, allow: Array) -> bool:
	for cls in allow:
		for head in ERR_ALLOW.get(cls, []):
			if line == head or line.begins_with(head):
				return true
	return false


func _scan_lines(src: Array, allow: Array) -> Dictionary:
	var m: Array = []
	var w := 0
	var lk := 0
	var ee := 0
	var ue: Array = []
	var i := 0
	while i < src.size():
		var line: String = src[i]
		if line.is_empty() or line.begins_with("Godot Engine v"):
			i += 1
			continue
		if line == WARN1 and i + 1 < src.size() and src[i + 1] == WARN2:
			w += 1
			i += 2
			continue
		if not ud_prefix.is_empty() and line.contains(ud_prefix):
			line = line.replace(ud_prefix, "UD/")
		if _load_re.search(line) != null:
			m.append("Load address: A")
			i += 1
			continue
		var fm := _frame_re.search(line)
		if fm != null and line.contains("0x"):
			m.append("[%s] F" % fm.get_string(1))
			i += 1
			continue
		var is_err: bool = line.begins_with("ERROR:") \
				or "SCRIPT ERROR" in line or "Parse Error" in line \
				or "handle_crash" in line
		if is_err:
			if _allowed(line, allow):
				ee += 1
				m.append(_mask_ids(line))
			else:
				ue.append(line.strip_edges())
			i += 1
			continue
		if _leak_re.search(line) != null:
			ue.append(line.strip_edges())
			i += 1
			continue
		m.append(_mask_ids(line))
		i += 1
	return {"m": m, "sha": _sha16(m), "w": w, "lk": lk, "ee": ee, "ue": ue}


func _scan(path: String, allow: Array, cap := 0) -> Dictionary:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {"err": "child log missing"}
	var n := f.get_length()
	var txt := ""
	if cap > 0 and n > cap:
		txt = f.get_buffer(cap).get_string_from_utf8()
	else:
		txt = f.get_as_text()
	f.close()
	var res := _scan_lines(txt.split("\n"), allow)
	res["truncated"] = cap > 0 and n > cap
	return res


func _field(line: String, name: String) -> String:
	var key := " " + name + "="
	var i := line.find(key)
	if i < 0:
		return ""
	var rest := line.substr(i + key.length())
	var j := rest.find(" ")
	return rest if j < 0 else rest.substr(0, j)


func _first_with(m: Array, sub: String) -> String:
	for line in m:
		if line.contains(sub):
			return line
	return ""


# --- cell text / extraction ---------------------------------------------------

func _extract(res: Dictionary, spec: Dictionary, txt: String) -> String:
	for rule in spec.get("gets", []):
		if rule.has("count"):
			var n := 0
			for line in res.get("m", []):
				if line.contains(rule["count"]) \
						and line.contains(rule.get("has", "")):
					n += 1
			txt += ",%s=%d" % [rule["as"], n]
			continue
		var line := _first_with(res.get("m", []), rule["sub"])
		if line.is_empty():
			continue
		if rule.has("f"):
			for fn in rule["f"]:
				var emit: String = rule.get("as", {}).get(fn, fn)
				txt += ",%s=%s" % [emit, _field(line, fn)]
		if rule.has("last"):
			var toks := line.split(" ", false)
			txt += ",%s=%s" % [rule["last"],
				toks[toks.size() - 1] if toks.size() else ""]
		if rule.has("tok"):
			var toks := line.split(" ", false)
			txt += ",%s=%s" % [rule["as"],
				toks[rule["tok"]] if toks.size() > int(rule["tok"]) else ""]
		if rule.has("between"):
			var val := ""
			var i := line.find(rule["between"][0])
			if i >= 0:
				var rest := line.substr(i + rule["between"][0].length())
				var j := rest.find(rule["between"][1])
				val = rest if j < 0 else rest.substr(0, j)
			txt += ",%s=%s" % [rule["as2"], val.replace(", ", ",")]
	return txt


func _cell_text(name: String, res: Dictionary, spec: Dictionary,
		byname: Dictionary) -> String:
	if res.has("err"):
		return "%s{err=%s}" % [name, res["err"]]
	var txt := "%s{rc=%d,sha=%s" % [name, res["rc"], res["sha"]]
	txt = _extract(res, spec, txt)
	if res.get("ee", 0) > 0:
		txt += ",ee=%d" % res["ee"]
	if res.get("lk", 0) > 0:
		txt += ",lk=%d" % res["lk"]
	if spec.has("pg"):
		txt += ",pgsha=%s" % res.get("pgsha", "-")
	if spec.has("cmp"):
		var other: Dictionary = byname.get(spec["cmp"], {})
		var src: String = spec.get("cmpsrc", "sha")
		var mine = res.get(src, res.get("sha", "-"))
		var theirs = other.get(src, other.get("sha", "-"))
		txt += ",%s=%d" % [spec.get("cmpf", "eq"), 1 if mine == theirs else 0]
	txt += ",gd=%d" % res.get("gd", -1)
	return txt + "}"


func _cell_ok(res: Dictionary, spec: Dictionary) -> bool:
	if res.has("err") or not res.get("ue", []).is_empty():
		return false
	return res.get("rc", -1) == spec.get("rc", 0)


# --- child spawn machinery ----------------------------------------------------

func _child_prepare(spec: Dictionary) -> Dictionary:
	var dirname: String = spec["dir"]
	if dirname.is_empty() or ".." in dirname or "/" in dirname \
			or "\\" in dirname or ":" in dirname:
		return {"err": "rejected dirname '%s'" % dirname}
	for i in dirname.length():
		var c := dirname.unicode_at(i)
		var ok := (c >= 0x30 and c <= 0x39) or (c >= 0x41 and c <= 0x5A) \
				or (c >= 0x61 and c <= 0x7A) or c == 0x5F or c == 0x2D
		if not ok:
			return {"err": "rejected dirname char U+%04X" % c}
	var dir := ProjectSettings.globalize_path("res://" + dirname)
	var mk := DirAccess.make_dir_recursive_absolute(dir)
	if mk != OK:
		return {"err": "cannot make %s err=%d" % [dirname, mk]}
	var pf := FileAccess.open(dir.path_join("project.godot"), FileAccess.WRITE)
	if pf == null:
		return {"err": "cannot write child project"}
	pf.store_string(PROJECTS[spec["body"]])
	pf.close()
	var src := FileAccess.open("res://r98_probe_%s.gd" % spec["probe"],
			FileAccess.READ)
	if src == null:
		return {"err": "probe source missing"}
	var dst := FileAccess.open(dir.path_join(spec["probe"] + ".gd"),
			FileAccess.WRITE)
	if dst == null:
		return {"err": "cannot write child probe"}
	dst.store_buffer(src.get_buffer(src.get_length()))
	src.close()
	dst.close()
	var adir := dir.path_join("assets")
	DirAccess.make_dir_absolute(adir)
	var assets := DirAccess.open("res://r98assets")
	if assets != null:
		for f in assets.get_files():
			var asrc := FileAccess.open("res://r98assets/" + f, FileAccess.READ)
			if asrc == null:
				continue
			var adst := FileAccess.open(adir.path_join(f), FileAccess.WRITE)
			if adst == null:
				asrc.close()
				continue
			adst.store_buffer(asrc.get_buffer(asrc.get_length()))
			asrc.close()
			adst.close()
	if spec.get("seedu", false):
		_seed_userdir()
	var logpath := dir.path_join("child.log")
	var bound: int = spec.get("bound", BOUND_S)
	var cwd := 'cd "%s" && ' % dir if spec.get("cwdp", false) else ""
	var cmd := ("timeout -s KILL %d \"%s\" --headless %s --path \"%s\""
			+ " --script \"res://%s.gd\" -- %s > \"%s\" 2>&1") % [
			bound, OS.get_executable_path(), spec.get("eargs", ""), dir,
			spec["probe"], spec["case"], logpath]
	DirAccess.remove_absolute(logpath)
	return {"dir": dir, "logpath": logpath, "cmd": cwd + cmd}


func _spawn_batch(specs: Array) -> Array:
	var preps := []
	for spec in specs:
		var prep := _child_prepare(spec)
		if not prep.has("err") and spec.has("post_prep"):
			# second-phase injection (phys_import): drop the engine-authored
			# export into the prepared child's assets before launch.
			var pp: Dictionary = spec["post_prep"]
			var src := FileAccess.open(pp["src"], FileAccess.READ)
			if src == null:
				prep = {"err": "post_prep source missing"}
			else:
				var dst := FileAccess.open(
						prep["dir"].path_join("assets").path_join(pp["name"]),
						FileAccess.WRITE)
				if dst == null:
					prep = {"err": "post_prep dst unwritable"}
				else:
					dst.store_buffer(src.get_buffer(src.get_length()))
				src.close()
				if dst != null:
					dst.close()
		if not prep.has("err"):
			var pid := OS.create_process("/bin/sh", ["-c", prep["cmd"]])
			if pid <= 0:
				prep = {"err": "cannot create child process"}
			else:
				prep["pid"] = pid
		preps.append(prep)
	var deadline := Time.get_ticks_msec() + BOUND_S * 1000
	var running := true
	while running and Time.get_ticks_msec() < deadline:
		running = false
		for prep in preps:
			if prep.has("pid") and OS.is_process_running(prep["pid"]):
				running = true
		if running:
			OS.delay_msec(20)
	var out := []
	for i in preps.size():
		var prep: Dictionary = preps[i]
		if prep.has("err"):
			out.append(prep)
			continue
		if OS.is_process_running(prep["pid"]):
			OS.kill(prep["pid"])
		var res := _scan(prep["logpath"], specs[i].get("e", []),
				specs[i].get("cap", 0))
		res["rc"] = OS.get_process_exit_code(prep["pid"])
		res["gd"] = 1 if DirAccess.dir_exists_absolute(
				prep["dir"].path_join(".godot")) else 0
		out.append(res)
	return out


func _chunks(specs: Array) -> Array:
	var out := []
	var i := 0
	while i < specs.size():
		out.append(specs.slice(i, min(i + CHUNK, specs.size())))
		i += CHUNK
	return out


func _run_all(specs: Array) -> Array:
	var out := []
	for chunk in _chunks(specs):
		out.append_array(_spawn_batch(chunk))
	return out


# --- generic arm --------------------------------------------------------------

func _run_cells(cells: Array) -> bool:
	var specs := []
	for c in cells:
		specs.append({"dir": _d("%s_%s" % [arm, c["n"].replace("@", "_")]),
			"body": c["p"], "probe": c["pr"], "case": c["c"],
			"e": c.get("e", []), "eargs": c.get("eargs", ""),
			"seedu": c.get("seedu", false), "cwdp": c.get("cwdp", false)})
	var out := _run_all(specs)
	var ok := true
	var byname := {}
	for i in cells.size():
		byname[cells[i]["n"]] = out[i]
	for i in cells.size():
		var res: Dictionary = out[i]
		parts.append(_cell_text(cells[i]["n"], res, cells[i], byname))
		if not _cell_ok(res, cells[i]):
			ok = false
			notes.append("%s ue=%s" % [cells[i]["n"],
					",".join(res.get("ue", []))])
	return ok


# --- phys arm: engine-authored OMI payload, two phases -------------------------

func _run_phys() -> bool:
	var gens := []
	var imps := []
	var gcells := []
	var icells := []
	for be in ["gp", "jolt", "dummy"]:
		gcells.append({"n": "physgen@%s" % be, "pg": true, "gets": [
			_g("PHYSGEN bytes=", ["bytes"]),
			_g("PHYSGEN reimport_err=", ["reimport_err"],
				{"reimport_err": "rerr"})]})
		icells.append({"n": "imp@%s" % be, "gets": [
			_g(" append_err=", ["append_err"], {"append_err": "err"}),
			_g(" nodes=", ["nodes", "meshes", "anims", "skel"]),
			_g("PhysBody:RigidBody3D", ["body_class", "mass"],
				{"body_class": "body"}),
			_g("PhysShape:CollisionShape3D", ["shape"])]})
		if be != "gp":
			gcells[-1]["cmp"] = "physgen@gp"
			gcells[-1]["cmpf"] = "pgeq"
			gcells[-1]["cmpsrc"] = "pgsha"
			icells[-1]["cmp"] = "imp@gp"
			icells[-1]["cmpf"] = "beq"
	for i in 3:
		var be: String = ["gp", "jolt", "dummy"][i]
		gens.append({"dir": _d("phys_gen_%s" % be), "body": be + "60",
			"probe": "r98b_mode", "case": "phys_gen", "e": ["physbuf"]})
		imps.append({"dir": _d("phys_imp_%s" % be), "body": be + "60",
			"probe": "r98b_mode", "case": "phys_import", "e": ["physbuf"],
			"post_prep": {"name": "phys_gen.glb",
				"src": ProjectSettings.globalize_path(
					"res://" + _d("phys_gen_%s" % be)).path_join("out")
					.path_join("phys_gen.glb")}})
	var gout := _run_all(gens)
	for i in 3:
		# pin the engine-authored export itself (backend-inert bytes).
		var f := FileAccess.open(imps[i]["post_prep"]["src"], FileAccess.READ)
		if f != null:
			var ctx := HashingContext.new()
			ctx.start(HashingContext.HASH_SHA256)
			ctx.update(f.get_buffer(f.get_length()))
			f.close()
			gout[i]["pgsha"] = ctx.finish().hex_encode().substr(0, 16)
		else:
			gout[i]["pgsha"] = "missing"
	var iout := _run_all(imps)
	var ok := true
	var byname := {}
	for i in gcells.size():
		byname[gcells[i]["n"]] = gout[i]
	for i in icells.size():
		byname[icells[i]["n"]] = iout[i]
	for i in gcells.size():
		parts.append(_cell_text(gcells[i]["n"], gout[i], gcells[i], byname))
		if not _cell_ok(gout[i], gcells[i]):
			ok = false
			notes.append("%s ue=%s" % [gcells[i]["n"],
					",".join(gout[i].get("ue", []))])
	for i in icells.size():
		parts.append(_cell_text(icells[i]["n"], iout[i], icells[i], byname))
		if not _cell_ok(iout[i], icells[i]):
			ok = false
			notes.append("%s ue=%s" % [icells[i]["n"],
					",".join(iout[i].get("ue", []))])
	return ok
