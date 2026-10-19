# r106 SEAT-25 — CENSUS-GODOT

Axes: depth (default-env Godot re-probe plus one bounded battery row), coverage (row classified against the r105 marker-audit token set), calibration (CLI string, API string, and the one `eng=` pin kept distinct).

This seat wrote this report only. It did not edit `corpus/knowledge/engines.md` (another seat refreshed that file while this probe was in flight). No fixture was edited. No pinned-Node rerun: the seat asked for the default environment.

HEAD at probe: `0cc3f4162f8c319f8d01a69a174fe939f36701bd`. Capture window: `2026-10-18T21:20:31Z` through `2026-10-18T21:57:08Z`.

## Verdict

Default-env Godot is installed and headless-executable. `godot --headless --version` is `4.7.2.stable.arch_linux.ed1daf0bf` (rc 0). `r100_fpslat_cls` PASS, exit 0/0, `seeds_unchanged=true`, elapsed 2.487s. The row is **node-state-inert**: it is outside the r105 env-token census. It is not an explicit Godot version pin.

## Default environment

```text
$ date -u +%Y-%m-%dT%H:%M:%SZ
2026-10-18T21:20:31Z
$ git rev-parse HEAD
0cc3f4162f8c319f8d01a69a174fe939f36701bd
$ command -v node; node --version
/home/vgpnk/.local/share/mise/installs/node/latest/bin/node
v26.12.0
$ command -v godot
/usr/bin/godot
$ readlink -f /usr/bin/godot
/usr/bin/godot
$ pacman -Q godot
godot 4.7.2-1
$ stat -c 'size=%s mtime=%y' /usr/bin/godot
size=182015704 mtime=2026-08-18 14:19:08.000000000 -0300
$ sha256sum /usr/bin/godot
3a72f85d53b84d7656ad8a633b06b019a11ad170a5718ff50bacc1c83cd4e72b  /usr/bin/godot
$ sha256sum corpus/fixtures/run_battery.py
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
```

`node` resolved to mise `v26.12.0` before and after the battery. The fnm `v24.21.0` prefix was not applied. Godot is `/usr/bin/godot` either way; the two-state model selects Node, not this binary.

## Version strings (three shapes, one build)

CLI, both forms, rc 0:

```text
$ godot --version
4.7.2.stable.arch_linux.ed1daf0bf
$ godot --headless --version
4.7.2.stable.arch_linux.ed1daf0bf
```

API string, scratch project `reports/round-106/scratch/seat25-godot-verinfo` (not a fixture), rc 0:

```text
$ godot --headless --path reports/round-106/scratch/seat25-godot-verinfo --script res://verinfo.gd --quit
Godot Engine v4.7.2.stable.arch_linux.ed1daf0bf (2026-08-17 01:18:38 UTC) - https://godotengine.org
string=4.7.2-stable (arch_linux)
major=4 minor=7 patch=2 status=stable build=arch_linux hash=ed1daf0bf001b61586d9930840f2f1394092c079
hex=263938
executable=/usr/bin/godot
```

| surface | observed 2026-10-18 | role |
|---|---|---|
| package | `godot 4.7.2-1` | pacman identity |
| `godot --version` / `--headless --version` | `4.7.2.stable.arch_linux.ed1daf0bf` | CLI; also the battery receipt's `godot_version` and the parent stdout banner |
| `Engine.get_version_info()["string"]` | `4.7.2-stable (arch_linux)` | API string; first whitespace token is `4.7.2-stable` |
| engines.md label | `Godot 4.7.2` | major.minor.patch only; still true; this seat did not rewrite it |

## Battery row — `r100_fpslat_cls`

```text
$ python3 corpus/fixtures/run_battery.py --only r100_fpslat_cls
PASS r100_fpslat_cls: exit=0 expected=0
PASS     r100_fpslat_cls                    r100_fpslat.gd             --arm=cls          0/0       ordinary
totals: cases=1 pass=1 fail=0 ordinary=1 negative_controls=0 probes=0
PASS battery: .../corpus/live/runs/20261018T212035261095Z/verdicts.json
battery_rc=0
```

Stdout copy: `reports/round-106/scratch/seat25-r100_fpslat_cls.stdout` sha256 `5b482603f99b410640ab71a879747b4d8c97fa3c5c9905ccca11021e810bcb3d`.

Receipt (runner default, under gitignored `corpus/live/runs/`; byte-identical copy under scratch):

```text
$ python3 -c "<parse verdicts.json>"
receipt=corpus/live/runs/20261018T212035261095Z/verdicts.json
verdict=PASS
godot=/usr/bin/godot
godot_version='4.7.2.stable.arch_linux.ed1daf0bf'
godot_version_exit=0
godot_version_error=None
started_utc=20261018T212035261095Z
only='r100_fpslat_cls'
seeds_unchanged=True
totals={'cases': 1, 'pass': 1, 'fail': 0, 'ordinary': 1, 'negative_controls': 0}
case_timeout_seconds=20
elapsed=2.487
reasons=[]
marker_match=True
stderr_lines=0
```

sha256 `bbc8ddb2273d2ce0d0d06c74cb67138294dc399fa24d43725e8949abb7fb810f` for both `corpus/live/runs/20261018T212035261095Z/verdicts.json` and `reports/round-106/scratch/seat25/r100_fpslat_cls-20261018T212035Z.verdicts.json` (`cmp` identical). Parent stdout was the banner plus the exact PASS line; stderr empty. `classify` (`run_battery.py:964-977`) requires the marker as an exact stdout line and does not reject the banner.

After the run: `git diff --exit-code -- corpus/fixtures` → `fixture_diff_exit=0`. `git status --short -- corpus/fixtures` was empty. Runner hash unchanged.

## Env-exposure class (r105 marker-audit taxonomy)

Taxonomy source: `reports/round-105/n24/markers.md`. Its classes, applied to expected-marker tokens, are: explicit toolchain pin (`node=v24.21.0`, Cannon/Three label, PyBullet engine/API, Godot `eng=`), host-drift-exposed runtime metadata (`py=`, PyBullet `build=`, Blender `engine=`/`version=`), and a non-version fingerprint (`dtBits`). Same AST/regex scan, this seat, on the live `CASES` table (`CASES=350`):

```text
r100_fpslat_cls: node semver NONE; Cannon/Three NONE; PyBullet engine NONE;
PyBullet API NONE; host Python NONE; build stamp NONE; Blender engine NONE;
Blender version NONE; Godot eng= NONE
godot_eng_rows=['r98_gltflat_cls']
```

**Class: outside the r105 token census. Node-state-inert. Not a Godot version pin.** Residual exposure is implicit engine-behavior (ProjectSettings defaults and ClassDB existence), not a named r105 version class.

Provenance, not just the regex miss:

- Expected marker pins `tps`/`jit`/`cap`/`ds`/`ip` and `PhysicalBoneSimulator3D` exists/inst, plus sha16 of the normalized child stream (`run_battery.py` case `r100_fpslat_cls`; cells in `r100_fpslat.gd` `_cells_cls`). No `eng=`, `node=`, `py=`, or `build=`.
- Child `r100_probe_r100b_cls.gd` prints Engine knobs, ProjectSettings, `OS.get_cmdline_args()`, `OS.get_cmdline_user_args()`, and ClassDB. It does not exec `node` and does not print a version string.
- Spawn uses `OS.get_executable_path()` (`r100_fpslat.gd` `_child_prepare`), not a PATH lookup of `godot` or `node`. Observed child argv: `CLS_ARGV engine=--script|res://r100b_cls.gd` (9/9 `child.log` files under the run scratch). The absolute scratch path is not in the hashed stream.
- Parent `_scan_lines` drops lines beginning `Godot Engine v` before hashing (`r100_fpslat.gd`). The banner that carries `v4.7.2.stable.arch_linux.ed1daf0bf` is therefore not part of the pinned sha. A version-string-only change that left settings and ClassDB alone would still match this marker.
- Observed child banner on all 9 logs: `Godot Engine v4.7.2.stable.arch_linux.ed1daf0bf (2026-08-17 01:18:38 UTC)`. No `node=` token.

This seat did not re-run the row under fnm `v24.21.0`. The inert classification is from the marker and the child logs, plus a default-env pass with mise `v26.12.0` on PATH. It is not a pinned-env battery claim.

## Dated note — r105 `eng=` wording (not a rewrite)

`reports/round-105/n24/markers.md` says `eng=4.7.2-stable` on `r98_gltflat_cls` is obtained from `Engine.get_version_info()["string"]` (`r98_probe_gltf.gd:47`). That file is protected; this is a dated correction, not an edit.

Observed 2026-10-18, the full API string is `4.7.2-stable (arch_linux)`, not `4.7.2-stable`. The marker value is the first whitespace-delimited token after `engine=`: `r98_gltflat.gd` `_field` (`:525-532`) stops at the next space, and the cls arm asks for that field (`_g("GLTFCLS engine=", ["engine"], {"engine": "eng"})`). The live expected marker still contains `eng=4.7.2-stable` and does not contain `(arch_linux)`. The parenthetical stays in the child line and therefore in that row's sha. This seat did not re-run `r98_gltflat_cls`, so this is not a pass/fail claim for that row.

## engines.md

Read at close, not edited. The Godot row already says installed `yes` at `/usr/bin/godot`, headless `yes`, CLI string `4.7.2.stable.arch_linux.ed1daf0bf`, from another seat's `phys3d_joints_free_ops` receipt. This cls row agrees and does not move that cell. It does not make the default-env battery 350/350. No Unreal runtime claim.
