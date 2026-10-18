# r105 SEAT-14 — N24 marker audit

**Axes:** depth (whole-table marker census), coverage (all environment/version tokens), calibration (separate expected pins from runtime-derived host metadata).

Scope: static audit of the expected marker strings in `CASES` from `corpus/fixtures/run_battery.py`. No battery was run and no fixture was edited. This report is the only path written by this seat.

## Census method and result

`CASES` was parsed with Python `ast` + `ast.literal_eval`; regular expressions were applied to each row's expected marker, counting distinct case rows rather than repeated marker cells. The source hash and broad census were checked with:

```text
$ sha256sum corpus/fixtures/run_battery.py
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
$ python3 - <<'PY'
import ast, pathlib, re
src=pathlib.Path('corpus/fixtures/run_battery.py').read_text()
t=ast.parse(src)
a=next(n for n in t.body if isinstance(n,ast.Assign) and any(isinstance(x,ast.Name) and x.id=='CASES' for x in n.targets))
rows=ast.literal_eval(a.value)
checks={
 'node semver': re.compile(r'\bnode=(v\d+\.\d+\.\d+(?:[-+][A-Za-z0-9.-]+)?)'),
 'Cannon/Three engine': re.compile(r'\bengine=(cannon-es-[^ |}]+)'),
 'PyBullet engine': re.compile(r'\bengine=(pybullet-[^ |}]+)'),
 'PyBullet API': re.compile(r'\bapi=(\d{6,})'),
 'host Python': re.compile(r'\bpy=(\d+\.\d+\.\d+)'),
 'build stamp': re.compile(r'\bbuild="([^"]+)"'),
 'Blender engine': re.compile(r'\bengine=(blender-[^ |}]+)'),
 'Blender runtime version': re.compile(r'\bversion=(\d+\.\d+\.\d+)'),
 'Godot engine version': re.compile(r'\beng=(\d+\.\d+\.\d+-[A-Za-z0-9.-]+)'),
}
print(f'CASES={len(rows)}')
for label,rx in checks.items():
 hit=[]
 for name,_,_,_,marker in rows:
  vals=sorted(set(rx.findall(marker)))
  if vals: hit.append((name,vals))
 distinct=sorted({v for _,vs in hit for v in vs})
 print(f'{label}: {len(hit)} rows; values={distinct}')
 for name,vals in hit: print(' ',name,','.join(vals))
PY
```

Observed headline output: `CASES=350`; Node version `13` rows (`v24.21.0`); Cannon/Three `13` (`cannon-es-0.20.0+three-0.186.1`); PyBullet engine/API/Python/build stamp each `14`; Blender engine `10`; Blender `version=` field `1`; Godot version `1`. The semver-shaped literals across the whole table are exactly `v24.21.0`, `0.20.0+three-0.186.1`, `3.2.7`, `3.14.7`, `5.2.1`, and `4.7.2-stable`. A separate AST/regex count found `dtBits=3f71111111111111` on the same 14 PyBullet rows; this is a runtime fixed-timestep fingerprint, not a software version.

## Node marker rows

The regex specifically matches `node=v<version>` (not other marker fields named `node`, such as animation node identifiers or vectors). It found **exactly these 13 rows and no others**:

`r94_cannon_det`, `r94_cannon_det2`, `r94_cannon_varstep`, `r94_cannon_bailout`, `r94_cannon_nan`, `r94_cannon_sync`, `r94_cannon_material`, `r94_cannon_friction`, `r94_cannon_parity`, `r94_cannon_parity2`, `r94_cannon_modes`, `r94_cannon_order`, `r94_cannon_backends`.

Every one also carries the `cannon-es-0.20.0+three-0.186.1` engine identity. Source provenance: `corpus/fixtures/r94_cannon.gd:125-140` executes `node --version` and prints its result as `node=...`; `corpus/fixtures/r94_child.mjs:81` emits the fixed Cannon/Three engine label. Thus the Node field is runtime/PATH-dependent against a literal expected pin, while Cannon/Three is a fixed toolchain label.

## Remaining environment/version tokens

| Marker token(s) | Rows | Classification and provenance |
|---|---|---|
| `engine=pybullet-3.2.7`; `api=202010061` | All 14 `r95_bullet_*` rows: `det`, `freeze`, `rt`, `shm`, `sleep`, `sleep2`, `nan`, `nan2`, `fric`, `rest`, `knobs`, `solver`, `pile`, `misc` | PyBullet/toolchain identity pins. `r95_child.py:1649-1651` emits the engine label and obtains the API value from `getAPIVersion()`. |
| `py=3.14.7`; `build="Oct 15 2026 03:47:36"`; `dtBits=3f71111111111111` | Same 14 `r95_bullet_*` rows | Host/build-drift-exposed runtime metadata. Python comes from `platform.python_version()`; `corpus/fixtures/r95_bullet.gd:17-19` says `/usr/bin/python3` resolves to this host's CPython 3.14.7. `r95_child.py:1625-1635` extracts the PyBullet build time from its import banner; lines 1649-1651 emit it and the fixed-timestep bits. These values happen to be literal-pinned in the expected markers, but are not portable host-independent toolchain identities. |
| `engine=blender-5.2.1` | All 10 Blender rows: `bpy_rbw3d_det`, `bpy_rbw3d_bake`, `bpy_rbw3d_window`, `bpy_rbw3d_order`, `bpy_rbw3d_resim`, `bpy_rbw3d_knobs`, `bpy_rbw3d_ops`, `bpy_rbw3d_io`, `bpy_rbw3d_render`, `bpy_rbw3d_ptr` | Host-runtime-derived version metadata; `r91_child.py:91-92` reads `bpy.app.version_string`. `bpy_rbw3d_ops` additionally has `version=5.2.1` from the same runtime value (`r91_child.py:356-359`). The current expected literals therefore expose Blender-version drift. |
| `eng=4.7.2-stable` | `r98_gltflat_cls` only | Explicit Godot toolchain/version pin in this expected marker; the fixture obtains the value from `Engine.get_version_info()["string"]` (`r98_probe_gltf.gd:47`). This is the only Godot version string found in the 350 markers. |

The classification is about provenance and intended pinning, not whether `CASES` currently compares the literal exactly: every token above is part of its row's expected marker. Node/Cannon/Three, PyBullet/API, and Godot are explicit toolchain pins; Python, Blender, and the PyBullet build timestamp are host-drift-exposed runtime metadata. `dtBits` is a separate runtime configuration fingerprint, not a version string.

## Read-only boundary

Commands run after the census:

```text
$ git status --short -- corpus/fixtures
?? corpus/fixtures/PINNED-ENV.md
$ git diff --exit-code -- corpus/fixtures
$ printf 'fixture_diff_exit=%s\n' "$?"
fixture_diff_exit=0
$ sha256sum corpus/fixtures/run_battery.py
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
```

The untracked `PINNED-ENV.md` is another seat's file and was not touched. The tracked fixture tree has no diff, the runner hash remains unchanged, and this seat ran no battery; the findings are static marker evidence only.
