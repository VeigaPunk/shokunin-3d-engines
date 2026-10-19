# SEAT-30 CENSUS-GLTF — r106

Axes: **depth** (one bounded `--only` rerun with a saved receipt), **coverage** (default env only, as assigned), **calibration** (expected marker vs stdout; CLI banner vs `eng=` token; no `node=` token).

Scope: one r98 glTF row, `r98_gltflat_cls` (`r98_gltflat.gd --arm=cls`). Chosen because it is the only `r98_gltflat_*` row whose expected marker carries an engine-version token (`eng=4.7.2-stable`). The other eight r98 arms were not rerun. `corpus/knowledge/engines.md` was not edited. This is a Godot lane-fixture result, not an Unreal runtime claim.

## Default env (this seat's run)

Preflight and run, cwd = lane repo, no PATH prefix (mise Node, not fnm):

```text
$ date -u +%Y-%m-%dT%H:%M:%SZ; git rev-parse HEAD; command -v node; node --version; command -v godot; godot --version; sha256sum corpus/fixtures/run_battery.py corpus/fixtures/r98_gltflat.gd
2026-10-18T21:32:02Z
0cc3f4162f8c319f8d01a69a174fe939f36701bd
/home/vgpnk/.local/share/mise/installs/node/latest/bin/node
v26.12.0
/usr/bin/godot
4.7.2.stable.arch_linux.ed1daf0bf
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
47998a95bb0401f7f8475bb0baf0828fa8f8559d2b2b3c174eff8221ab2835db  corpus/fixtures/r98_gltflat.gd

$ python3 corpus/fixtures/run_battery.py --only r98_gltflat_cls --runs reports/round-106/scratch/seat30-gltf; echo COMMAND_EXIT=$?
PASS r98_gltflat_cls: exit=0 expected=0

VERDICT  CASE                               SCRIPT                     FLAGS              EXIT      KIND
PASS     r98_gltflat_cls                    r98_gltflat.gd             --arm=cls          0/0       ordinary
totals: cases=1 pass=1 fail=0 ordinary=1 negative_controls=0 probes=0
PASS battery: /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/reports/round-106/scratch/seat30-gltf/20261018T213202370249Z/verdicts.json
COMMAND_EXIT=0
```

Receipt parse (`python3` `json.load` of that `verdicts.json`):

| field | observed |
|---|---|
| verdict | `PASS` |
| totals | `cases=1 pass=1 fail=0 ordinary=1 negative_controls=0` |
| row | `r98_gltflat_cls` `verdict=PASS` `actual_exit=0` `expected_exit=0` `reasons=[]` `elapsed_seconds=2.291` `kind=ordinary` |
| `seeds_unchanged` | `true` (seed map 131 paths, includes `PINNED-ENV.md`) |
| `case_timeout_seconds` | `20` |
| `only` | `r98_gltflat_cls` |
| `godot` | `/usr/bin/godot` |
| `godot_version` | `4.7.2.stable.arch_linux.ed1daf0bf` (`godot_version_exit=0`) |
| runner digest in receipt | `run_battery.py` = `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` |
| fixture digest in receipt | `r98_gltflat.gd` = `47998a95bb0401f7f8475bb0baf0828fa8f8559d2b2b3c174eff8221ab2835db` |
| receipt sha256 | `eb508d6df4334be4c4a08ee13c41b78c3a74de80f4aa5724c75751b113123387` |
| stderr | empty |

Post-check: `git status --short -- corpus/fixtures` printed no paths; `sha256sum corpus/fixtures/run_battery.py` still `f456bd00…f69f`. No fixture edit.

## Markers

The classifier requires the expected marker as an exact stdout line. It matched (`identical=true`, 1123 chars). Stdout also has a Godot banner line, which is not the marker:

```text
Godot Engine v4.7.2.stable.arch_linux.ed1daf0bf (2026-08-17 01:18:38 UTC) - https://godotengine.org
PASS r98_gltflat cls cls@gp{rc=0,sha=2dcbfe6689b25eac,eng=4.7.2-stable,srn=-,recps=tscn,res,scn,classes=18,gd=0} cls@jolt{…beq=1…} cls@dummy{…beq=1…} inv@gp{rc=0,sha=4aa74196469a860f,eng=4.7.2-stable,asked=18,exists=18,refc=1,gd=0} … props@gp{…srn=false,grn=false,docp=16,stp=40…} … exts@gp{rc=0,sha=a99966181343dcf5,sup=13,exglb=false,exgltf=false,exup=false,exabs=false,gd=0} …
```

Tokens on that PASS line (expected and actual are the same string):

- `eng=4.7.2-stable` on every `cls@*` and `inv@*` cell (gp/jolt/dummy). This is `Engine.get_version_info()["string"]`, not the CLI banner. Banner/receipt spelling is `4.7.2.stable.arch_linux.ed1daf0bf`. Both were observed; the row pins the Engine string, and that string matched. Not a mismatch.
- No `node=` token. Default Node v26.12.0 was on PATH, but this row does not read it. A pinned-Node rerun is not required to explain this marker, and this seat did not run one.
- `classes=18`, `asked=18`, `exists=18`, `refc=1`.
- `srn=-` on `cls@*`; `srn=false` and `grn=false` on `props@*`; `docp=16`, `stp=40`.
- `recps=tscn,res,scn`.
- `sup=13`, `exglb=false`, `exgltf=false`, `exup=false`, `exabs=false` on every `exts@*` cell. Those `false` flags are the pinned expected marker, not a fail. They say the recognized-extension list this arm prints does not include `.glb`/`.gltf`. They do not prove or disprove `GLTFDocument` import — that is the `doc` arm, not run here.
- Cell sha prefixes unchanged vs the expected marker: cls `2dcbfe6689b25eac`, inv `4aa74196469a860f`, props `319a4db84d5d69cc`, exts `a99966181343dcf5`. `beq=1` on jolt and dummy. `gd=0` on every cell.

## What this does not say

- Not a full r98 lattice rerun. Historical read only (not a rerun): `reports/round-104/physics/full-regression-runs/20261018T194637610772Z-verdicts.json` has all nine `r98_gltflat_*` rows `PASS` with `reasons=[]` and marker equality, inside a battery whose top-level verdict is `FAIL` (`350` cases, `337` pass, `13` fail, `seeds_unchanged=true`). Those 13 fails are outside this row.
- Does not move any `engines.md` row. One passing `--only` receipt is not a promotion.
- No Unreal editor, no Unreal runtime claim.
