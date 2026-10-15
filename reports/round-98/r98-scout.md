# r98 scout — the authored GLTF/GLB surface under --headless: runtime import without the import cache

Lane: g3d · engine `4.7.2.stable.arch_linux.ed1daf0bf` · `--headless`, 60 tps,
**no `--editor` and no `.godot` import cache** (wiped before every child; a
`--headless --script` child never re-creates one — 0/159, measured).
Backends swept: GodotPhysics (`proj`), Jolt (`proj_jolt`), Dummy
(`proj_dummy`) for **every** `gl_*` cell — all three byte-identical per
case, so the whole surface is measured backend-inert, not assumed.

This report **completes the dead r98 scout seat**: it left
`corpus/live/r98-scout/{assets,probes,runs}` with the probe and six
authored assets intact but `runs/` empty — every measurement here is a
fresh run on this host of the dead seat's own matrix (17 cases), plus two
disclosed finisher repairs (§H) and two adjacent edges
(`doc_missing`, `gltf_tr.gd` transform fidelity).

Evidence: `corpus/live/r98-scout/` — `probes/` (2 `.gd`), `assets/` (6
authored assets + `gen_assets.py`, re-mints byte-identical), `driver.py`,
`audit.py`, `runs/*` (**159 children, 159 rc=0**), `evidence/` (pre-repair
cls output), `manifest.sha256` (837 pinned files), `RECEIPTS.md`,
`fullrun.log`.

Reps: 53 cells carry a `.r1/.r2/.r3` triple from three fresh processes.
**All 53 are byte-identical.** No heap-sensitive or nondeterministic
signature was observed; nothing is a mode candidate this round.

Confidence labels: **[O]** observation (receipt-pinned, rep-stable),
**[I]** inference, **[?]** unknown / not decided by these cells.

---

## 0. The GLTF* ClassDB inventory under --headless (`cls` arm)

All 17 GLTF-domain classes exist under `ClassDB` and instantiate from a
plain `--headless --script` SceneTree — none are editor-gated:

| class | methods | | class | methods |
|---|---|---|---|---|
| GLTFState | 71 | | GLTFTextureSampler | 8 |
| GLTFNode | 32 | | GLTFAnimation | 6 |
| GLTFAccessor | 32 | | GLTFTexture | 4 |
| GLTFDocument | 25 | | GLTFSkeleton | 11 |
| GLTFDocumentExtension | 24 | | GLTFCamera | 14 |
| GLTFPhysicsBody | 20 | | GLTFLight | 18 |
| GLTFPhysicsShape | 20 | | GLTFBufferView | 15 |
| GLTFMesh | 10 | | GLTFObjectModelProperty | 18 |
| GLTFSpecGloss | 10 | | | |

`SPOT GLTFDocument append_from_file=Y append_from_buffer=Y
append_from_scene=Y generate_scene=Y generate_buffer=Y
write_to_filesystem=Y set_root_nodes=- get_supported_gltf_extensions=Y`
(`runs/gl_proj_cls.r1.stdout.txt`).

- **[O] `set_root_nodes` is absent** from `class_get_method_list
  ("GLTFDocument")` on this build while all seven other spotted verbs are
  present. **[?]** Whether a `root_nodes` property (or differently-named
  entry point) is reachable was not probed — authors must verify before
  scripting partial-scene export against that name.
- **[I]** `GLTFObjectModelProperty` is the only plain `RefCounted` in the
  list: it is the sole class whose `free()` aborted the dead seat's probe
  (§H); every other class took the `Node`/`Resource` branch without error.
- **[O]** `RECOG PackedScene=tscn,res,scn` and `RECOG
  GLTFDocument=tres,res` — **`glb`/`gltf` appear in neither list**: no
  `ResourceFormatLoader` is registered for either extension under
  headless. This is the mechanism behind §1.

---

## 1. `ResourceLoader.load` is a dead end for `.glb`/`.gltf` without an import cache

`load_*` calls `ResourceLoader.load(path)` on `res://assets/*`. **Every
call returns `null`** (six arms, three backends, byte-identical):

| arm | file exists? | engine error (verbatim) | `LOAD` line |
|---|---|---|---|
| `load_glb` | yes (valid GLB) | `No loader found for resource: res://assets/tri.glb` | `-> null` |
| `load_gltf` | yes (valid JSON+dataURI) | `No loader found for resource: res://assets/tri.gltf` | `-> null` |
| `load_badmagic` | yes (corrupt) | `No loader found for resource` | `-> null` |
| `load_badjson` | yes (corrupt) | `No loader found for resource` | `-> null` |
| `load_empty` | yes (valid empty) | `No loader found for resource` | `-> null` |
| `load_missing` | no | `Resource file not found: res://assets/absent.glb` | `-> null` |

- **[O] The refusal is at extension level, before any byte is read**: a
  corrupt `badmagic.glb`, a broken `badjson.gltf`, and a valid `tri.glb`
  fail with the identical `No loader found` — only a *missing* file takes
  the different `Resource file not found` path (existence check precedes
  loader lookup).
- **[O]** A second `ERROR: Error loading resource: '<path>'` from
  `core_bind.cpp:82` follows every arm — two error lines per refused load.
- **Authorability**: any fixture that runtime-loads authored glTF must go
  through `GLTFDocument` (§2); `load()`/`ResourceLoader` on `.glb`/`.gltf`
  is not a fallback — on this build it is a guaranteed null plus two error
  lines in the log.

---

## 2. `GLTFDocument.append_from_file`: the error taxonomy is three-valued

`doc_*` arms: `GLTFDocument.new()`, `GLTFState.new()`,
`doc.append_from_file(path, state)`, then `generate_scene(state)` on
`err==OK`. Measured return codes (Godot `Error` enum values):

| arm | `append_err` | enum | state filled? |
|---|---|---|---|
| `doc_file` (tri.glb) | `0` | OK | nodes=2 meshes=1 anims=0 skel=0 |
| `doc_gltf` (tri.gltf) | `0` | OK | nodes=2 meshes=1 anims=0 skel=0 |
| `doc_nodes` (nodes_only.glb) | `0` | OK | nodes=3 meshes=0 anims=0 skel=0 |
| `doc_empty` (empty.glb) | `0` | OK | nodes=0 meshes=0 anims=0 skel=0 |
| `doc_missing` (**edge**) | `7` | ERR_FILE_CANT_OPEN | — |
| `doc_badmagic` | `43` | ERR_PARSE_ERROR | — |
| `doc_badjson` | `43` | ERR_PARSE_ERROR | — |

- **[O] `.gltf` JSON-with-data-URI and `.glb` binary are equally loadable**
  — identical state counts and identical generated trees (§3).
- **[O] A bad-magic `.glb` is fed to the JSON parser**, not rejected on
  magic: verbatim error `glTF: Error parsing .gltf JSON data: Expected
  'true', 'false', or 'null', got 'XXXX' at line: 0`
  (`gltf_document.cpp:6696`). Parser selection does not validate the
  4-byte `glTF` magic; bad-magic and bad-JSON converge on `err=43`.
- **[O] `doc_missing` answers `err=7` with** `Can't open file at path
  "res://assets/absent.glb"` (`gltf_document.cpp:7347`) — a distinct code
  from parse failure (43), so a fixture can separate "no file" from
  "unparseable file" on the return value alone.
- **[O] A structurally-empty GLB imports successfully**: `err=0`, zeroed
  state, and `generate_scene` emits only `WARNING: glTF: This glTF file
  has no nodes, the generated Godot scene will be empty.`
  (`gltf_document.cpp:7221`), returning an **unnamed** empty `Node3D`
  (`DOCSCENE root=:Node3D`). "Empty" is not an error path.
- **[O] `doc_abs`**: an absolute filesystem path
  (`~/.local/share/godot/app_userdata/R98Scout/tri.glb`, seeded by the
  driver) loads identically (`err=0`, same state/tree) — `res://` is not
  required; `user://`-style absolute paths work.

---

## 3. `generate_scene`: root = glTF scene name, transforms byte-exact

| source | generated tree (verbatim `TREE` lines) |
|---|---|
| `tri.glb` / `tri.gltf` / buffer / abs | `TriScene:Node3D` → `RootNode:Node3D` → `TriMesh:MeshInstance3D mesh=ArrayMesh tris=1` |
| `nodes_only.glb` | `NodeScene:Node3D` → `PivotA:Node3D` → `ChildA:Node3D`; `PivotB:Node3D` (second root-level node) |
| `empty.glb` | `:Node3D` (single unnamed node, warning above) |

- **[O] The generated root is a fresh `Node3D` named after the glTF
  *scene* (`TriScene`/`NodeScene`)**, not the file or the first node;
  authored scene members become its children. Multiple glTF-scene roots
  flatten to siblings under it (`PivotB`).
- **[O] Meshes arrive as `ArrayMesh`** with the authored primitive count
  (`tris=1` for the mode-4 triangle primitive).
- **[O] Transform fidelity is exact** (finisher edge `gltf_tr.gd`,
  `tr_proj_*` runs): `PivotA pos=(5,0,0)`, `ChildA scale=(2,2,2)` with
  identity rotation, `TriMesh pos=(1,2,3)`, and the **`matrix`-form node
  `PivotB` decomposes to `pos=(7,8,9)`** identically — both authored
  transform forms land with zero drift.
- **[O]** `generate_scene` allocates a tree the caller owns — the probe
  `free()`s it; nothing registers it in the SceneTree.

---

## 4. Buffer path and the scene→GLB→scene round-trip

- **[O] `append_from_buffer(bytes, "res://assets/", state)` on the raw
  GLB bytes is equivalent to `append_from_file`**: `err=0`, same state,
  same generated tree (`DOCBUF` block byte-identical tree to `DOCSCENE`).
  An **empty base path also works** for a GLB: the `roundtrip` arm
  re-imports with `append_from_buffer(bytes, "", st2)` → `err=0` —
  embedded buffers need no base; the base only matters for resolving
  relative buffer URIs (untested here: all authored buffers are embedded).
- **[O] Round-trip**: a script-built `Node3D`(`RTSource`, pos (3,4,5)) +
  `MeshInstance3D`(`RTBox`, `BoxMesh`) → `append_from_scene` `err=0`
  (`nodes=2 meshes=1`) → `generate_buffer` `bytes=2696` →
  `append_from_buffer` `err=0` → `generate_scene` reproduces
  `RTSource:Node3D pos=(3,4,5)` + `RTBox:MeshInstance3D tris=12`.
  **Names and transforms round-trip exactly; the mesh does not**: the
  parametric `BoxMesh` returns as a realized `ArrayMesh` (12 tris). [I]
  The glTF format has no parametric-box concept — realization into
  indexed triangles is the expected conversion, consistent with the
  `ArrayMesh` landing in §3.
- **[O]** `write_to_filesystem` is present in the method list but was
  **not** exercised — the byte path (`generate_buffer`) covers in-memory
  export; filesystem export remains untested [?].

---

## 5. Cross-backend and host facts

- **[O] Every case is byte-identical across `proj`/`proj_jolt`/
  `proj_dummy`** (per-case normalized digests equal; `audit.py` output).
  GLTF class registration, parse errors, scene generation, and the
  `GLTFPhysicsBody`/`GLTFPhysicsShape` classes are all reachable with the
  physics server on `Dummy` — **[I]** the importer never consults the
  physics backend for this asset class. **[?]** Physics-extension
  payloads inside a glTF (no authored asset carries one) could still
  interact with the backend — untested.
- **[O] A `--headless --path <p> --script` child never creates
  `<p>/.godot`** — 0/159 runs re-created it (`.godotdir` sidecars all
  `absent`). The no-import-cache premise is self-maintaining on this
  build; no per-run cache hygiene is actually needed (kept anyway as a
  guard).
- **[O] `OS.get_user_data_dir()` under this project resolves to
  `~/.local/share/godot/app_userdata/R98Scout`** (keyed on
  `config/name`), and the engine writes `logs/` there on every run —
  residue to clean (§H, cleanup).

---

## 6. Falsification list (claims this round tested)

1. **"`.glb`/`.gltf` under `res://` are loadable through
   `ResourceLoader.load` like `.tscn`/`.res`."** FALSIFIED — no loader is
   registered for either extension under `--headless` (`RECOG
   PackedScene=tscn,res,scn`); every arm returns `null` (§1).
2. **"`ResourceLoader` inspects the file and refuses only corrupt
   assets."** FALSIFIED — refusal is at extension level: valid, corrupt,
   and empty files fail identically; only missing files differ (§1).
3. **"`GLTFDocument` needs the editor or a `.godot` import cache."**
   FALSIFIED — `append_from_file`/`append_from_buffer`/`generate_scene`
   work in a bare `--headless --script` SceneTree, and the child never
   mints a `.godot` dir (§2, §5).
4. **"`append_from_file` validates GLB magic."** FALSIFIED — a bad-magic
   `.glb` is parsed as JSON text (`got 'XXXX'`), error `43` (§2).
5. **"Missing and corrupt files are indistinguishable to the importer."**
   FALSIFIED — `err=7` (ERR_FILE_CANT_OPEN) vs `err=43` (ERR_PARSE_ERROR)
   (§2).
6. **"An empty glTF is an import failure."** FALSIFIED — `err=0`, a
   WARNING, and an unnamed empty `Node3D` (§2, §3).
7. **"glTF node transforms are normalized or lost on import."**
   FALSIFIED — TRS and `matrix` forms land with zero drift, including a
   matrix→pos `(7,8,9)` decomposition (§3).
8. **"The generated scene is rooted at the file's first node."**
   FALSIFIED — a synthesized `Node3D` named after the glTF *scene* roots
   the output; multi-root scenes flatten to siblings (§3).
9. **"A scene→GLB→scene round-trip is a faithful clone."** FALSIFIED on
   mesh type — names/transforms round-trip exactly but `BoxMesh` returns
   as `ArrayMesh` (§4).
10. **"Absolute paths outside `res://` cannot be imported."** FALSIFIED —
    `doc_abs` loads `~/.local/share/godot/app_userdata/R98Scout/tri.glb`
    with `err=0` (§2).
11. **"Asset import behaviour varies with the physics backend."**
    FALSIFIED — byte-identical cells on GodotPhysics/Jolt/Dummy (§5).
12. **"`set_root_nodes` is a callable `GLTFDocument` method on this
    build."** ABSENT from `class_get_method_list` while all seven sibling
    verbs are present (§0) — [O] for list absence; property-style access
    unprobed [?].

---

## 7. Hazards for authors and harnesses **[O]**

- **`rc=0` does not mean the script ran clean.** The dead seat's `cls`
  arm hit `SCRIPT ERROR: Attempted to free a RefCounted object`, lost its
  SPOT/RECOG tail, and still exited 0 (pre-repair evidence:
  `evidence/cls_refcnt_bug.stdout.txt`, `…exit`=`0`). Harnesses must grep
  stdout for `SCRIPT ERROR`/`ERROR:` — `.exit` alone is blind.
- **`ClassDB.instantiate()` returns can be `RefCounted`.**
  `o is Object → o.free()` is a script-aborting trap — check
  `o is RefCounted` (or `Resource`) first. `GLTFObjectModelProperty` is
  the observed instance on this build.
- **Engine ERROR backtraces embed `res://<probe>:<line>`** — every
  error-path signature moves when the probe file is edited (measured:
  all `doc_*`/pre-repair `cls` digests shifted between run sets). Pin the
  message text, never the line number.
- **`doc_abs` output embeds the host `$HOME` path** — verbatim signatures
  for that arm are host-pinned, not portable.
- **Every `load_*`/`doc_*` failure prints engine `ERROR:` lines before
  the probe's own verdict line** — a clean-failure arm is still a noisy
  log; expected-error fixtures should match both lines.
- **`generate_scene` returns an owned tree** — leak if not freed/added.
- **Timeout discipline**: all 159 children wrapped `timeout -s KILL 60`;
  median child ≈0.55 s. No leaked godot processes after the run.

## 8. Observation / inference / unknown

Observation (receipt-pinned, rep-stable): every verdict line, error
string, tree dump, transform row, error code, method count, RECOG list,
byte count, and byte-identity claim above.

Inference (labelled): the extension-level refusal mechanism behind §1
(grounded in the `RECOG` lists — loader registration, not byte
inspection); `GLTFObjectModelProperty` being the lone plain RefCounted
(from which class tripped the free trap); the ArrayMesh realization being
a format necessity (no parametric primitive in glTF); the importer never
consulting the physics backend for this asset class (consistent
byte-identity across three backends including Dummy).

Unknown / deferred:
- `set_root_nodes`/`root_nodes` reachability via property syntax (only
  method-list absence measured) — §0.
- `write_to_filesystem`, `append_from_buffer` flags, and
  `GLTFDocumentExtension`/`GLTFObjectModelProperty` runtime hooks —
  instantiated, not exercised.
- Whether the bad-magic→JSON fallback is keyed on extension or on a
  magic-sniff-fallback (a `.gltf` containing GLB binary, or a `.glb` with
  valid magic but corrupt chunks, would discriminate — not authored).
- GLTF assets carrying skins/animations, physics-extension payloads
  (`GLTFPhysicsBody`/`Shape` classes exist; no payload authored), cameras,
  lights, textures, or external `.bin` URIs — the authored corpus is
  deliberately minimal (one triangle, three bare nodes).
- Behaviour *with* a `.godot` import cache present (the premise keeps it
  absent; the cached path is editor-pipeline territory).
- Whether ResourceLoader recognition differs in an `--editor` or exported
  template context.

---

## 9. Reproducing

```
cd corpus/live/r98-scout
python3 driver.py --batch gltf --reps 3 --jobs 6   # §0–§5 (153 children)
python3 driver.py --batch tr   --reps 3 --jobs 6   # transform edge (6)
python3 audit.py                                  # rc + identity census
python3 driver.py --cleanup                       # user-dir + .godot hygiene
python3 assets/gen_assets.py                      # re-mints assets byte-identically
```

Single cells: `python3 driver.py --batch gltf --reps 3 --only
gl_proj_doc_missing`, `--only gl_proj_jolt_doc_badmagic`, `--proj
proj_dummy`, … (`--only` matches the tag substring). Expected signatures
are the verbatim rows quoted in §0–§4; the three backend variants are
byte-identical per case.

## Receipts pointer

`corpus/live/r98-scout/`: `probes/gltf.gd` (dead seat's probe + two
disclosed finisher repairs), `probes/gltf_tr.gd` (finisher edge),
`assets/` (+`gen_assets.py`), `driver.py`, `audit.py`, `runs/` (159
children + rc/ms/godotdir sidecars), `evidence/cls_refcnt_bug.*`,
`RECEIPTS.md` (probe inventory, repairs, confounds), `manifest.sha256`
(837 pinned files), `fullrun.log`. `corpus/live/` is gitignored —
scratch only, per lane contract.

Provenance note: this lane wrote **only** `corpus/live/r98-scout/**` and
`reports/round-98/r98-scout.md`. The dead seat's probe and assets were
used as found; the two probe repairs are disclosed inline and in
RECEIPTS.md. Driver/audit/manifest conventions follow r96-scout; backend
bake strings follow r89/r92.

## H. Finisher's note on the dead seat

The dead scout's design was sound: the case matrix cleanly separates the
`ResourceLoader` dead end (§1) from the `GLTFDocument` door (§2–§4), and
its authored assets cover valid/corrupt/empty/missing-adjacent in both
container formats. Its probe carried one latent bug (the RefCounted free,
§7) that would have silently truncated the `cls` arm — the seat died
before its first run, so the bug was discovered here, preserved under
`evidence/`, and repaired minimally. The `doc_missing` edge and the
`gltf_tr.gd` transform probe complete the two holes its matrix left.
