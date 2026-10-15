# r98 boundary — attacking the r98-scout pins: verbatim replay, engine/tps/backend variation, 14-hog load, unstated modes

Lane: g3d · engine `4.7.2.stable.arch_linux.ed1daf0bf` · `--headless`, 60 tps
(plus tps 30/120/5 bakes) · backends swept **everywhere**:
GodotPhysics (`proj`), Jolt (`proj_jolt`), Dummy (`proj_dummy`) · every child
bounded `timeout -s KILL 25` · the load pass runs **14 CPU hogs** concurrently.

This seat attacks the r98 scout's pins. It does not restate them: it replays
them byte-for-byte, varies engine flags/tps/backends underneath them, re-runs
the whole matrix under hog load, and authors the discriminator assets the
scout's §8 explicitly left unmade. Pins that survive are pinned harder; pins
that move are named.

Evidence: `corpus/live/r98-boundary/` — `probes/` (the scout's `gltf.gd` and
`gltf_tr.gd` copied **byte-identical**, sha256
`18ba68b7065afdce…`/`4736126f3c148fb2…` equal to the scout's; new
`r98b_inv.gd`, `r98b_mode.gd`), `assets/` (the scout's six byte-identical +
11 authored discriminators, `gen_assets_r98b.py`), `driver.py`, `audit.py`,
`runs/` (**416 children, 416 rc=0**), `runs_hogs/` (**159 children under 14
hogs**), `evidence/` (`audit.json`, `audit.txt`, `cache_import.stdout.txt`,
`cache_import_tree.txt`, `phys_gen_sha.txt`, `key_shas.txt`), `hogload.log`,
`manifest.sha256` (**4252 entries**).

Reps: 180 cells carry a `.r1/.r2` (or `.r1/.r2/.r3`) triple from fresh
processes — **all 180 byte-identical**. Namespace: new probes and run tags are
`r98b_*`; the replay arms deliberately keep the scout's own tag names and its
`config/name="R98Scout"` bake so the `doc_abs` receipt (which embeds the
user-data path) is byte-comparable. `corpus/live/` is gitignored
(`corpus/.gitignore:1`).

Confidence: **[O]** receipt-pinned, rep-stable · **[I]** inference ·
**[?]** unknown / not decided by these cells.

---

## 0. Verdicts

| # | scout pin (r98-scout §) | verdict here | receipt |
|---|---|---|---|
| V1 | the whole 17-case × 3-backend matrix + transform edge (§0–§5) | **SURVIVES verbatim** — 159/159 children byte-identical to the scout's receipts (stdout **and** exit) | `evidence/audit.json` → `replay.identical=159, differ=0` |
| V2 | backend-inert surface (§5) | **SURVIVES** — all 3 backends byte-identical per case, 159 replay cells + 88 new-arm comparisons (inv 16/16, mode 72/72, physgen 3/3) | `audit.json` → `cross_backend` |
| V3 | "no loader for `.glb`/`.gltf` under headless" (§0/§1) | **SURVIVES** and hardens: `ResourceLoader.exists()` is **false** for the *existing* `tri.glb`/`tri.gltf`; the all-loader extension union contains neither; an upper-case `.GLB` is refused too | `runs/r98b_inv_proj_exts.r1`, `runs/r98b_mode_proj_load_upper.r1` |
| V4 | error taxonomy `0/7/43` (§2) | **SURVIVES**; the 43 family is now split into **four distinct message paths** (see §3.2) | `runs/r98b_mode_proj_magic_*` |
| V5 | "a bad-magic `.glb` is fed to the JSON parser" (§2) | **SURVIVES**; mechanism pinned: the container is **content-sniffed on the 4-byte magic**, the extension is irrelevant in *both* directions | `runs/r98b_mode_proj_glb_as_gltf.r1`, `…json_as_glb.r1` |
| V6 | `set_root_nodes` absent from `GLTFDocument`'s method list (§0) | **SURVIVES**; the §0 `[?]` **resolves**: the entry point is **`GLTFState.set_root_nodes`/`get_root_nodes` + a `root_nodes` property**, not a `GLTFDocument` verb (which has `root_node_mode` instead) | `runs/r98b_inv_proj_props.r1` |
| V7 | "All 17 GLTF-domain classes" (§0 table) | **CORRECTED** — the scout's own receipt has **18** `CLS` lines; the report table dropped **GLTFSkin (methods=20)**. `INV n_asked=18 n_exists=18 n_refcounted=1` | `runs/r98b_inv_proj_inv.r1` vs `../r98-scout/runs/gl_proj_cls.r1` |
| V8 | `write_to_filesystem` untested (§4 `[?]`) | **RESOLVED** — works, `err=0`, file **byte-identical** to `generate_buffer` (`equal_to_gen=true`), both `.glb` and `.gltf` forms, re-imports cleanly | `runs/r98b_inv_proj_write.r1` |
| V9 | "base only matters for relative buffer URIs (untested)" (§4) | **RESOLVED** — file base = the file's own directory (res://, absolute, user://, cwd-relative all work); buffer base = the passed base path; **empty base + relative URI = `ERR_INVALID_PARAMETER`**; a `res://` URI is **blind-concatenated** and fails | §3.3 |
| V10 | physics payloads "could still interact with the backend — untested" (§5 `[?]`) | **RESOLVED at node level** — an engine-authored OMI payload imports to `RigidBody3D`+`CollisionShape3D` **byte-identically on GP/Jolt/Dummy** | `runs/r98b_physgen_proj*.stdout.txt`, `runs/r98b_mode_proj*_phys_import.r1` |
| V11 | "a child never re-creates `.godot`" (§5) | **SURVIVES** — 0/406 non-cache children created it (incl. the 159 hog children); the 10 warm-cache children are the deliberate exception | `audit.txt` `.godot re-created by child` |
| V12 | "behaviour *with* a `.godot` import cache present" (§8 deferred) | **NEW MODE** — with a warm editor cache `ResourceLoader.load("res://assets/tri.glb")` returns a **`PackedScene`** and instantiates the same tree; the refusal in §1 is therefore **premise-scoped**, and the cold `No loader found` line is replaced by `Failed loading resource` | §3.6 |
| V13 | "glTF node transforms are normalized or lost" (§6.7) | **SURVIVES** — transform edge byte-identical (TRS and `matrix` forms) | `runs/r98b_tr_proj_nodes.r1` |
| V14 | hazard: "rc=0 does not mean clean" (§7) | **SURVIVES** — 188/416 receipts carry engine `ERROR:` lines at rc=0; 0 `SCRIPT ERROR` here because the probe was repaired | §4 |

---

## 1. Verbatim replay: the scout's matrix is byte-reproducible, exactly

The strongest available test of the scout's pins is its own receipts. This seat
copied its two probes byte-identically (`sha256` equal, see header), reproduced
its `project.godot` bake and its `R98Scout` app name, kept its cold-cache guard
(`rm -rf <proj>/.godot` before every child), and re-ran the full matrix
3 reps × 3 backends.

```
children=416  rc!=0: 0 []
.godot re-created by child: 10  (all 10 are the deliberate warm-cache arm)
cells with >=2 reps: 180  byte-identical: 180  differing: 0
replay cells vs scout: 159 identical, 0 differ, 0 no-scout-receipt
```

- **[O] 159/159 replay children are byte-identical to
  `../r98-scout/runs/gl_*`/`tr_*` (stdout + `.exit`)** — including every
  verbatim error string, every `at: …cpp:NNNN` frame, every GDScript backtrace
  line, every tree dump, `RECOG` list, method count, `bytes=2696` round-trip
  byte count, and the host-pinned `doc_abs` path. Spot check by hand:
  `diff runs/r98b_gl_proj_doc_file.stdout.txt ../r98-scout/runs/gl_proj_doc_file.r1.stdout.txt`
  → empty.
- **[O] Rep identity is total**: 180 cells × their reps, zero diffs. No cell in
  this round is a mode candidate.
- **[O]** The scout's §0 method-count table and §1–§4 verbatim rows are
  therefore *receipt-correct* as published — the only §0 error is the row
  **count** (V7: 18 classes in the receipt, 17 rows in the table).

## 2. Variation: backend, tps, `--fixed-fps`, `--time-scale`, and load

Every variation arm re-runs the scout's probe against the same assets; a
variation is "inert" only if the receipt is byte-identical to the baseline.

| arm | cells | result |
|---|---|---|
| backends GP/Jolt/Dummy (replay) | 159 | identical per case (V2) |
| `proj_tps30` / `proj_tps120` / `proj_tps5` bakes | 42/42 | **byte-identical** to the 60-tps baseline |
| `--fixed-fps 60` (3 backends) | 42/42 | **byte-identical** |
| `--fixed-fps 120` | 14/14 | **byte-identical** |
| `--time-scale 0.5` | 14/14 | **byte-identical** |
| new arms on Jolt/Dummy | inv 16/16, mode 72/72 | **byte-identical** |

- **[O] The whole import surface is tps-inert and rate-flag-inert**: the probe
  runs one deferred call and quits, so `--fixed-fps 60/120` and
  `--time-scale 0.5` cannot move it — measured, not assumed. This also
  re-validates the r100 rate flags on a *non*-physics surface.
- **[O] Engine args were placed before `--script`** (r100 §7.1 hazard), and the
  exact command + cwd of every child is pinned in its `.cmd`/`.cwd` sidecars.
- **[O] The load pass**: the full matrix (153 gl + 6 tr children, 3 reps) was
  re-run with **14 `yes` hogs** SIGKILLed in a `finally` block
  (`hogload.log`: `hogs_started=14 … loadavg=(57.5, 40.4, 28.7)` →
  `hogs_killed=14 rcs=[-9 ×14] … loadavg=(71.9, 45.1, 30.6)`; a *second* lane's
  load arm was also running, host loadavg peaked ≈72 on 32 cores):

```
hog pass runs_hogs: 159 replay children, 159 identical vs scout,
                    159 identical vs baseline, 0 diffs, rc!=0: 0 []
```

  **[O]** Under ≥14 hogs the scout's receipts are reproduced byte-for-byte:
  the surface carries no heap-sensitive, thread-sensitive, or timing-sensitive
  signature. This seat's hogs are dead (all PIDs `kill -0` → dead; the
  surviving `/usr/bin/yes` processes on the host belong to another lane's
  `driver.py --arm load` and were left alone).

## 3. Unstated modes hunted

### 3.1 Inventory and the `root_nodes` entry point (scout §0 `[?]`)

```
INV n_asked=18 n_exists=18 n_refcounted=1
PROPS doc_rootlike_methods=get_root_node_mode,set_root_node_mode
PROPS state_rootlike_methods=get_root_nodes,set_root_nodes
PROPS has_set_root_nodes=false
PROPS GLTFDocument n_props=16 props=…,root_node_mode,…
PROPS GLTFState   n_props=40 props=…,root_nodes,…
```

- **[O]** All 18 classes exist, instantiate, and their ancestry is uniform:
  `GLTFDocument` and 16 siblings are `Resource<RefCounted<Object>`;
  **`GLTFObjectModelProperty` is the only plain `RefCounted`** — the scout's
  `[I]` about the free-trap is confirmed by measurement, not inference.
- **[O] CORRECTION**: the receipt holds **18** classes (`GLTFSkin`,
  `methods=20`, is in `../r98-scout/runs/gl_proj_cls.r1`); the scout's §0 prose
  ("All 17 … classes") and its table omit `GLTFSkin`. The 17 published method
  counts are all correct.
- **[O] `[?]` resolved**: `set_root_nodes` is a **`GLTFState`** verb
  (`get_root_nodes`/`set_root_nodes` + a `root_nodes` property);
  `GLTFDocument` instead exposes `root_node_mode` with
  `get_root_node_mode`/`set_root_node_mode`. `doc.set("root_nodes", [])` is a
  silent no-op on the document (`after_set_prop_root_nodes=<null>`) — an author
  following §0's "[?]" would have found nothing; the entry point exists one
  class down.
- **[O] New pin**: `get_supported_gltf_extensions()` returns 13 extensions —
  `EXT_texture_webp, GODOT_single_root, KHR_animation_pointer,
  KHR_lights_punctual, KHR_materials_emissive_strength,
  KHR_materials_pbrSpecularGlossiness, KHR_materials_unlit,
  KHR_node_visibility, KHR_texture_basisu, KHR_texture_transform, OMI_collider,
  OMI_physics_body, OMI_physics_shape` (`runs/r98b_inv_proj_exts.r1`).
- **[O] `ResourceLoader.exists()` is not a presence test for glTF**:
  `res_exists_glb=false` and `res_exists_gltf=false` while the files are
  present (and `load()` on them fails) — existence is answered by the loader
  registry, not the filesystem.

### 3.2 Container sniffing and the four 43-paths (scout §2, §8)

The scout could not discriminate extension-driven from magic-driven parsing
("not authored"). Six authored discriminators settle it:

| asset (name → content) | `append_err` | first error line (verbatim) |
|---|---|---|
| `glb_as_gltf.gltf` → **GLB bytes** | **0** | — (imports fully: `TriScene`→`RootNode`→`TriMesh tris=1`) |
| `json_as_glb.glb` → **JSON text** | **0** | — (imports fully, same tree) |
| `magic_badjson.glb` → glTF magic + broken JSON chunk | 43 | `glTF Binary: Error parsing .glb file's JSON data: Expected key at line: 0` (`_parse_glb`, `gltf_document.cpp:289`) |
| `badmagic_badjson.glb` → `XXXX` magic + broken JSON | 43 | `glTF: Error parsing .gltf JSON data: Expected 'true', 'false', or 'null', got 'XXXX' at line: 0` (`_parse`, `:6696`) |
| `magic_only.glb` → 12-byte header, no chunks | 43 | `Condition "chunk_type != 0x4E4F534A" is true. Returning: ERR_PARSE_ERROR` (`_parse_glb`, `:279`) |
| `magic_truncated.glb` → declared length +4096 | **0** | — (imports fully) |
| `glb_version3.glb` → container version = 3 | **0** | — (imports fully) |

- **[O] The container format is content-sniffed on the 4-byte magic, and the
  file extension is ignored in both directions** — a `.gltf` holding GLB and a
  `.glb` holding JSON both import with `err=0`. The scout's §2 mechanism claim
  survives; its §8 unknown is closed.
- **[O] The `43` family is not one path but four**: JSON-text parse (`_parse`,
  `:6696`), binary JSON parse (`_parse_glb`, `:289`), missing/mis-typed first
  chunk (`_parse_glb`, `:279`), and unreadable buffer (`_parse_buffers`,
  `:787`) — all collapse to `ERR_PARSE_ERROR=43` on the return value, so a
  fixture must match the *message*, never the code, to separate them.
- **[O] Neither the declared total length nor the container version is
  validated** (both imports return `err=0`). This is not academic: the engine's
  **own exporter** emits a GLB whose header length exceeds the file by 8 bytes
  when the buffer is empty (§3.5), and its own importer tolerates it with a
  `WARNING: Reading less data than requested` + `ERROR: glTF: Buffer 0 has no
  data and cannot be loaded.` at **`err=0`**.

### 3.3 Buffer base-path semantics and path forms (scout §4)

| arm | base | `append_err` | note (verbatim where it fails) |
|---|---|---|---|
| `ext_bin_file` (`res://assets/ext_bin.gltf`, uri `ext.bin`) | file's dir | **0** | relative external `.bin` resolves next to the document |
| `ext_bin_buf_good` | `res://assets/` | **0** | same bytes via buffer |
| `ext_bin_buf_wrong` | `res://wrong/` | 43 | `glTF: Binary file not found: res://wrong/ext.bin` (`:787`) |
| `ext_bin_buf_empty` | `` | 43 | `Condition "p_base_path.is_empty()" is true. Returning: ERR_INVALID_PARAMETER` (`:784`) — a **distinct** first line, not "file not found" |
| `ext_resuri_file` (uri `res://assets/ext.bin`) | file's dir | 43 | `glTF: Binary file not found: res://assets/res://assets/ext.bin` — URIs are **blind-concatenated**; `res://` inside a URI is not special |
| `ext_bin_abs` (absolute path in `user://`-style dir) | file's dir | **0** | absolute paths get the same base rule |
| `doc_user` (`user://tri.glb`) | — | **0** | `user://` is an accepted path form |
| `doc_rel` (`assets/tri.glb`, child cwd = project dir) | — | **0** | cwd-relative paths work; the driver pins cwd in the `.cwd` sidecar |

- **[O]** The scout's §4 `[I]` ("the base only matters for resolving relative
  buffer URIs") is now measured, and the empty-base rejection is a *parameter*
  error surfaced as `43`, not a file error.
- **[O]** `doc_abs`'s "`res://` is not required" generalizes: `res://`,
  absolute, `user://`, and cwd-relative paths all import.

### 3.4 `write_to_filesystem` (scout §4 `[?]`)

```
WRITE append_err=0 nodes=2 meshes=1
WRITE gen_bytes=2692
WRITE write_glb_err=0
WRITE file_bytes=2692 equal_to_gen=true head=676c544602000000840a0000c4050000
WRITE reimport_err=0
WRITESCENE WRoot:Node3D
WRITESCENE   WBox:MeshInstance3D mesh=ArrayMesh tris=12
WRITE write_gltf_err=0
WRITE gltf_bytes=1500 head=7b226163636573736f7273223a5b7b22
```

- **[O]** Filesystem export is a real, working path: `.glb` output is
  byte-identical to `generate_buffer` (2692 B, magic `glTF`), `.gltf` output is
  JSON text (1500 B), and both re-import. The scout's in-memory byte path and
  the filesystem path agree exactly.
- **[O] The `.gltf` form is not self-contained**: it writes the buffer as a
  sibling sidecar (`write_export0.bin`, 1188 B, referenced by the relative URI
  `write_export0.bin`) — an author expecting one file must use `.glb`.
- **[O]** The written files are pinned by the manifest
  (`proj/out/write_export.glb` `44144d3e361048ba…`,
  `proj/out/write_export.gltf` `8b43fcacbe2a78a9…`,
  `proj/out/write_export0.bin` `b047d1f80ac842ce…`).

### 3.5 Physics payload across backends (scout §5 `[?]`)

The payload is authored **by the engine itself** (export of a scripted
`RigidBody3D`(mass 3.5) + `CollisionShape3D`(BoxShape3D 1×2×3)) so no
hand-written extension JSON is involved:

```
PHYSGEN append_err=0 nodes=3 meshes=0
PHYSGEN bytes=612
PHYSGEN json_extensionsUsed=["GODOT_single_root", "OMI_physics_body", "OMI_physics_shape"]
PHYSGEN reimport_err=0
PHYSGEN_SCENE PhysRoot:Node3D
PHYSGEN_SCENE   PhysBody:RigidBody3D body_class=RigidBody3D mass=3.5
PHYSGEN_SCENE     PhysShape:CollisionShape3D shape=BoxShape3D
```

- **[O]** The export is backend-inert: the three backends produced **identical
  bytes** (`sha256 cb0a74518de94092…`, 612 B; `evidence/phys_gen_sha.txt`), and
  the import receipt is byte-identical on GP/Jolt/Dummy (`72/72` cross-backend
  comparisons include `phys_import`).
- **[O]** So the scout's §5 `[I]` ("the importer never consults the physics
  backend") now extends past its asset class: even with a real OMI physics
  payload the import is observably backend-independent (node-level: the bodies
  are `Node3D`-tree objects until a tree owns them).
- **[O] New hazard**: the engine's own no-mesh export is **8 bytes shorter than
  its declared header length** (file 612, header 620, single JSON chunk, empty
  buffer, no BIN chunk). Its own importer answers with
  `WARNING: Reading less data than requested` (`file_access_memory.cpp:137`) +
  `ERROR: glTF: Buffer 0 has no data and cannot be loaded.`
  (`gltf_document.cpp:798`) **and `err=0`**. A mesh-bearing export is exact
  (file 2692 = header 2692, JSON+BIN chunks). Fixtures that hash engine-authored
  GLBs should expect this asymmetry.

### 3.6 Warm import cache: the premise boundary (scout §8 deferred mode)

`--headless --import` was run once on a dedicated project (`proj_cache`); it
minted `.godot/imported/*` and `*.import` files (pinned in
`evidence/cache_import_tree.txt`), after which the scout's own probe ran
**without** the cold-cache guard:

| arm | cold (baseline) | warm cache |
|---|---|---|
| `load_glb` | `ERROR: No loader found … (resource_loader.cpp:332)` → `null` | **`LOAD res://assets/tri.glb -> PackedScene`** + full `LOADINST` tree |
| `load_gltf` | same refusal | **`LOAD res://assets/tri.gltf -> PackedScene`** |
| `load_badmagic` | `No loader found` | `ERROR: Failed loading resource: res://assets/badmagic.glb.` (`resource_loader.cpp:317`) → `null` |
| `doc_file`, `cls` | — | byte-identical to the cold baseline (sha-equal receipts) |

- **[O] The scout's §1 is premise-scoped and says so**: with a warm editor
  import cache the loader **is** registered via the import remap and `load()`
  returns a `PackedScene` that instantiates the identical tree. The refusal
  mechanism differs too (registry miss → import/load failure). Authors who ship
  a project with an import cache must not read §1 as "glTF is unloadable".
- **[O]** The `GLTFDocument` path is cache-independent (`doc_file` and `cls`
  receipts byte-identical warm vs cold), so the two doors are cleanly
  separated: `ResourceLoader` needs the import pipeline; `GLTFDocument` does
  not.
- **[O]** `.godot` census: 0/406 non-cache children created it; the 10 warm
  cache children are the deliberate exception (their `.godotdir` sidecars say
  `created`).

## 4. Hazards re-confirmed

1. **rc=0 is blind** — **[O]**: 188/416 receipts carry `ERROR:` lines and 28
   carry `WARNING:` lines, all at `rc=0`; the hog pass is 159/159 `rc=0`.
   (0 `SCRIPT ERROR` in this seat: the probe under test is the repaired one.)
2. **Engine error backtraces embed `res://<probe>:<line>`** — **[O]**: every
   new-arm backtrace names `res://r98b_mode.gd:NN`/`r98b_inv.gd:NN`; the replay
   arms reproduce the scout's `res://gltf.gd:NN` frames exactly because the
   probe is byte-identical. Pin message text, never line numbers.
3. **`doc_abs` embeds `$HOME`** — **[O]**: the path is
   `/home/vgpnk/.local/share/godot/app_userdata/R98Scout/tri.glb`; host-pinned,
   which is why this seat reused the scout's app name.
4. **Expected-error arms are noisy** — **[O]**: the new failure arms print
   2–4 `ERROR:` lines before the probe's own verdict line; the
   `ext_bin_buf_empty` arm's first line is a *parameter* error, so matching
   `Binary file not found` alone would misclassify it.
5. **`generate_scene` returns an owned tree** — **[O]**: every probe arm frees
   it; nothing is added to the SceneTree.
6. **Timeout discipline** — **[O]**: all 575 children (`416 + 159`) were
   wrapped `timeout -s KILL 25`; zero children were killed (all `rc=0`), median
   child 707 ms (`runs/`, min 463 max 1276) and 929 ms under load (`runs_hogs/`,
   min 646 max 2055). No leaked `godot` child after the runs (the live `godot`
   processes on the host belong to other lanes); this seat's 14 hogs are dead.

## 5. The scout's own falsification list (its §6), re-judged

| scout §6 claim | this seat |
|---|---|
| 1 `.glb/.gltf` not loadable via `ResourceLoader` (cold) | survives (V3, V12 scopes it) |
| 2 refusal at extension level, not byte inspection | survives cold; **the mechanism is a registry miss** — warm cache flips it (V12) |
| 3 `GLTFDocument` needs no editor/cache | survives (warm/cold `doc_file` receipts sha-equal) |
| 4 `append_from_file` does not validate GLB magic | survives; now positive+negative proof of magic-sniffing (V5, §3.2) |
| 5 missing vs corrupt separable (`7` vs `43`) | survives verbatim; the `43` family is four paths (§3.2) |
| 6 empty glTF is not an error | survives verbatim |
| 7 transforms not normalized/lost | survives verbatim |
| 8 root is the glTF *scene*, not the file | survives verbatim |
| 9 round-trip is not a faithful clone (mesh type) | survives verbatim |
| 10 absolute paths import | survives; extends to `user://` and cwd-relative (§3.3) |
| 11 asset import is backend-invariant | survives, and extends to OMI physics payloads (§3.5) |
| 12 `set_root_nodes` absent from `GLTFDocument` | survives; the entry point is on `GLTFState` (V6) |

Also corrected: §0's class count 17 → **18** (V7). Resolved from §8:
magic-vs-extension (closed), `write_to_filesystem` (closed), warm cache
(closed), OMI payload (closed at node level). Still `[?]`: skins/animations/
textures/cameras/lights payloads, `GLTFDocumentExtension` runtime hooks,
imported-scene behaviour in an exported template, and whether the OMI bodies
enter a physics space once added to a running tree.

## 6. Reproducing

```
cd corpus/live/r98-boundary
python3 assets/gen_assets_r98b.py            # re-mints the 11 discriminators
python3 driver.py --batch replay --reps 3 --jobs 8      # 153 children
python3 driver.py --batch tr     --reps 3 --jobs 8      #   6 children
python3 driver.py --batch inv    --reps 2 --jobs 8      #  24 children
python3 driver.py --batch mode   --reps 2 --jobs 8      # 108 children (prepares physgen first)
python3 driver.py --batch tps    --reps 2 --jobs 8      #  42 children
python3 driver.py --batch ffps   --reps 2 --jobs 8      #  42 children
python3 driver.py --batch ffps120 --reps 2 --jobs 8     #  14 children
python3 driver.py --batch ts     --reps 2 --jobs 8      #  14 children
python3 driver.py --batch cache  --reps 2 --jobs 3      #  10 children (--import prep first)
python3 driver.py --batch replay --reps 3 --jobs 6 --hogs 14 --runs-dir runs_hogs
python3 driver.py --batch tr     --reps 3 --jobs 6 --hogs 14 --runs-dir runs_hogs
python3 audit.py --dir runs --hog-dir runs_hogs         # verdict census + byte compares
python3 driver.py --cleanup                             # user dir + .godot hygiene, stray census
```

Single cells: `--only r98b_mode_proj_magic_badjson`, `--proj proj_jolt`, etc.
(`--only` matches the tag substring). Expected signatures are the verbatim
rows quoted above; the three backends are byte-identical per case.

## 7. Observation / inference / unknown

Observation (receipt-pinned, rep-stable): every byte-identity verdict, error
string, error code, tree dump, transform row, property list, extension list,
method count, export size/sha, `.godot` census row, hog PID/load row, and rc
above.

Inference (labelled): the registry-miss reading of the cold `No loader found`
(grounded in the extension-union `EXTS recog_empty` list, which contains
neither `glb` nor `gltf`, and in the warm-cache flip); the 8-byte export
over-declaration being an empty-BIN-chunk header the exporter counts but does
not write (file/chunk arithmetic); the OMI bodies being tree-level objects at
import (no physics space involved until a tree owns them).

Unknown / deferred:
- Payload classes the scout left untested (skins, animations, cameras, lights,
  textures, KHR_animation_pointer) — untouched here.
- `GLTFDocumentExtension`/`GLTFObjectModelProperty` runtime hooks —
  instantiated, not exercised.
- Whether an imported OMI body behaves differently once added to a live tree
  on each backend (this seat measures import, not simulation).
- Whether the warm-cache `PackedScene` path differs from the runtime
  `GLTFDocument` path in a scene-level detail beyond the tree dump (e.g.
  resource UIDs, `.import` flags).
- Exported-template context (no export templates were built here).

## 8. Receipts pointer and provenance

`corpus/live/r98-boundary/` (gitignored): `probes/` (`gltf.gd`, `gltf_tr.gd`
byte-identical to the scout's; `r98b_inv.gd`, `r98b_mode.gd`),
`assets/` (scout six byte-identical + `gen_assets_r98b.py` + 11
discriminators), `driver.py`, `audit.py`, `runs/` (416 children ×
stdout/exit/ms/godotdir/cmd/cwd/stderr sidecars), `runs_hogs/` (159 children),
`evidence/` (`audit.txt`, `audit.json`, `key_shas.txt`, `cache_import.stdout.txt`,
`cache_import_tree.txt`, `phys_gen_sha.txt`), `hogload.log`,
`manifest.sha256` (4252 entries).

Key receipt digests (sha256, first 16 hex; full list in
`evidence/key_shas.txt`):

```
c1fb48832df2e3ce  runs/r98b_gl_proj_cls.r1.stdout.txt        (== r98b_cache_cls.r1)
25dc900bea63f344  runs/r98b_gl_proj_doc_file.r1.stdout.txt   (== r98b_cache_doc_file.r1)
cc64c8c7f7267e35  runs/r98b_gl_proj_doc_missing.r1.stdout.txt
f989bc1c51312f61  runs/r98b_gl_proj_doc_badmagic.r1.stdout.txt
66516c6ad9f15d3c  runs/r98b_gl_proj_doc_empty.r1.stdout.txt
37d15fb8132b24c8  runs/r98b_gl_proj_roundtrip.r1.stdout.txt
0a1bb08077a1850d  runs/r98b_gl_proj_doc_abs.r1.stdout.txt
828f760c6323d40f  runs/r98b_tr_proj_nodes.r1.stdout.txt
490e33411e129dac  runs/r98b_inv_proj_inv.r1.stdout.txt
7bc185f50b45f9d2  runs/r98b_inv_proj_props.r1.stdout.txt
c5fd9b5738a9e6ad  runs/r98b_inv_proj_exts.r1.stdout.txt
2615e1256dc992c7  runs/r98b_inv_proj_write.r1.stdout.txt
37e1fcfb6b879bc7  runs/r98b_mode_proj_glb_as_gltf.r1.stdout.txt
60bf5d4149af58b8  runs/r98b_mode_proj_json_as_glb.r1.stdout.txt
6109c788211a3249  runs/r98b_mode_proj_magic_only.r1.stdout.txt
3c66302a2b7443dd  runs/r98b_mode_proj_magic_badjson.r1.stdout.txt
f23b6ab12a492a69  runs/r98b_mode_proj_magic_truncated.r1.stdout.txt
06c47add53656830  runs/r98b_mode_proj_glb_version3.r1.stdout.txt
9279ed1e46043e1d  runs/r98b_mode_proj_ext_bin_file.r1.stdout.txt
697ad5aff571ce23  runs/r98b_mode_proj_ext_resuri_file.r1.stdout.txt
a6a912c2b3a0ce66  runs/r98b_mode_proj_ext_bin_buf_empty.r1.stdout.txt
2168cf7e30780ee9  runs/r98b_mode_proj_doc_rel.r1.stdout.txt
eb3d03e237f235d5  runs/r98b_mode_proj_doc_user.r1.stdout.txt
0f509a2ad56a9932  runs/r98b_physgen_proj.stdout.txt
9cdd6392333eddbd  runs/r98b_mode_proj_phys_import.r1.stdout.txt
8d657de196ece0f1  runs/r98b_cache_load_glb.r1.stdout.txt
9419cf222970cf2f  runs/r98b_cache_load_gltf.r1.stdout.txt
7d14b4bd0502b8c8  runs/r98b_cache_load_badmagic.r1.stdout.txt
31cd69c1988b8cbe  probes/r98b_inv.gd
fadcf86c0c9dbd71  probes/r98b_mode.gd
a7d0b95d3efa4cf9  driver.py
d633dde02781cb97  audit.py
ccdebd3d32124d7f  assets/gen_assets_r98b.py
cb0a74518de94092  proj/out/phys_gen.glb      (engine-authored, sha256 first 16)
3ea1d882ee576a72  evidence/audit.txt
604638a1b7bf9f2d  evidence/audit.json
cd80b73e537537a4  evidence/cache_import.stdout.txt
980e0ffe7fe47736  evidence/cache_import_tree.txt
672608a95b42ebda  evidence/phys_gen_sha.txt
25daa4aa69c22713  hogload.log
```

Provenance note: this seat wrote **only** `corpus/live/r98-boundary/**`
(gitignored scratch) and `reports/round-98/r98-boundary.md`. The scout's
corpus was read, never written; its probes were copied byte-identically and
re-used; its app name and project bake were reproduced deliberately so the
`doc_abs` receipt stays byte-comparable. Engine flags sit before `--script`;
every child is bounded `timeout -s KILL 25`; hog processes were SIGKILLed in a
`finally` block and verified dead. Driver/audit/manifest conventions follow
r98-scout/r100-scout.
