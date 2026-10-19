# SEAT-98 ENGINE-COUNT — r106

Axes: **calibration** (state cells vs live probes; no promotion without a receipt), **coverage** (every census row counted, not a prose total), **depth** (both Node states re-resolved; three.js `partial` re-probed, not inherited).

This seat does **not** own `corpus/knowledge/engines.md` (SEAT-38 does). No edit was made to it. No fixture code was written. No Unreal runtime claim: the editor is not installed.

## Verdict

`ENGINE_ROWS=4`. All four `installed` / `executable headless` cells are **unchanged** versus `HEAD` and versus the live probes. **Promotions: 0.** No row may move.

| # | tooling | installed (file) | executable headless (file) | probe agrees | promotion |
|---|---|---|---|---|---|
| 1 | Godot 4.7.2 | `yes (`/usr/bin/godot`)` | `yes` | yes | none |
| 2 | Unity Editor | `no` | `no` | yes | none |
| 3 | Unreal Engine | `no` | `no` | yes | none |
| 4 | three.js 0.186.1 | lane-local pin (parenthetical `Node v26.11.1`) | `partial` — Object3D math, no GL | yes (`partial` holds under both Node states) | none |

The `Node v26.11.1` parenthetical is a **stale host string**, not a state cell. Live default is `v26.12.0`. It does not authorize rewriting `installed` or `executable headless`. Queued for SEAT-38 as a dated correction note, not applied here.

## File identity

Probe window `2026-10-18T21:21:14Z`–`2026-10-18T21:21:45Z`. Lane `HEAD` `0cc3f4162f8c319f8d01a69a174fe939f36701bd`.

```text
$ git rev-parse HEAD
0cc3f4162f8c319f8d01a69a174fe939f36701bd
$ sha256sum corpus/knowledge/engines.md
d03907d3d63771c10558a2bc276d62c50bcdea1d02150d78e6d1a720a0c3bddf  corpus/knowledge/engines.md
$ git hash-object corpus/knowledge/engines.md; git rev-parse HEAD:corpus/knowledge/engines.md
5eef89d484b60e26ab78c29dd86a64781b0df86f
5eef89d484b60e26ab78c29dd86a64781b0df86f
$ git diff --stat HEAD -- corpus/knowledge/engines.md
0
$ git status --porcelain -- corpus/knowledge/engines.md
(empty)
$ stat -c 'mtime=%y size=%s' corpus/knowledge/engines.md
mtime=2026-10-18 14:42:49.295040755 -0300 size=2768
```

Worktree bytes equal the `HEAD` blob (`worktree_eq_HEAD True`). Same sha as the r102 verifier stamp and the r105 `SKILL.md` §6 stamp of this file. mtime is the r102 repair (`14:42:49 -0300`), not an r106 rewrite. Rechecked at `2026-10-18T21:21:45Z`: sha and mtime unchanged, `ENGINE_ROWS` still 4.

Row count is an enumeration of data rows (header and separator excluded), not a prose claim:

```text
$ python3 - <<'PY'
from pathlib import Path
text=Path('corpus/knowledge/engines.md').read_text().splitlines()
n=0
for i,l in enumerate(text,1):
    if not l.startswith('|'): continue
    if set(l.replace('|','').strip())<=set('-: '): continue
    cells=[c.strip() for c in l.strip().strip('|').split('|')]
    if cells[0]=='tooling':
        print(f'header L{i} cols={len(cells)}')
        continue
    n+=1
    print(f'L{i} {cells[0]} | {cells[1]} | {cells[2]}')
print('ENGINE_ROWS', n)
PY
header L6 cols=5
L8 Godot 4.7.2 | yes (`/usr/bin/godot`) | yes
L9 Unity Editor | no | no
L10 Unreal Engine | no | no
L11 three.js 0.186.1 | lane-local npm dependency pinned in `corpus/fixtures/three/package-lock.json` (Node v26.11.1) | partial — `Object3D` scene graph/math under Node; no GL context
ENGINE_ROWS 4
```

Table lines = 6 (1 header + 1 separator + 4 data). File is 16 lines, 2768 bytes. Promotion rule is still in the file (`executable headless` + `non-author verifier`; "Absence of an engine never authorizes runtime claims").

## Two-state environment (re-resolved, not inherited)

```text
$ date -u +%Y-%m-%dT%H:%M:%SZ
2026-10-18T21:21:14Z
$ node --version; command -v node; readlink -f "$(command -v node)"
v26.12.0
/home/vgpnk/.local/share/mise/installs/node/latest/bin/node
/home/vgpnk/.local/share/mise/installs/node/26.12.0/bin/node
$ test -x /home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node && echo PINNED_BIN_EXISTS=yes
PINNED_BIN_EXISTS=yes
$ PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" node --version
v24.21.0
$ PATH="…/v24.21.0/installation/bin:$PATH" command -v node
/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node
```

Default state is mise Node **v26.12.0**. Pinned state is fnm Node **v24.21.0** at the path named in the round brief. The PATH prefix was command-scoped; after it, plain `node --version` was still `v26.12.0` (recheck `2026-10-18T21:21:45Z`).

## State-cell probes

Full transcript: `reports/round-106/scratch/seat98/host-probe.txt` and `reports/round-106/scratch/seat98/three-probe.txt`.

### Godot — `yes` / `yes` — holds

```text
$ command -v godot; echo rc=$?
/usr/bin/godot
rc=0
$ godot --version; echo rc=$?
4.7.2.stable.arch_linux.ed1daf0bf
rc=0
$ godot --headless --version; echo rc=$?
4.7.2.stable.arch_linux.ed1daf0bf
rc=0
```

Version string matches the row label `Godot 4.7.2`. Executable path matches the installed cell. Headless flag returns the same version, exit 0. This seat did not rerun the battery (other seats own those receipts). A same-window census receipt already on disk agrees and is cited, not treated as this seat's run: `reports/round-106/census/phys3d-joints.md` records `phys3d_joints_free_pair` and `phys3d_joints_free_ops` PASS under default env, Godot `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`. That receipt supports keeping `yes`/`yes`. It is not a new engine and not a promotion.

### Unity — `no` / `no` — holds

```text
$ command -v unity Unity UnityHub unityhub; echo rc=$?
(no output)
rc=1
$ ls -d /opt/unity* /opt/Unity* /usr/share/unity* "$HOME/Unity"* "$HOME/UnityHub"*; echo rc=$?
(no output)
rc=2
```

`command -v` summary: `ABSENT unity`, `ABSENT Unity`, `ABSENT UnityHub`, `ABSENT unityhub`. Static artifact still present (`corpus/artifacts/unity-r19/` lists `Hierarchy.unity`, `Hierarchy.broken-reference.unity`, `README.md`, `verify_scene.py`). Static files do not move `installed` or `executable headless`. **No promotion.**

### Unreal — `no` / `no` — holds

```text
$ command -v UnrealEditor UnrealEditor-Cmd UE4Editor UnrealBuildTool; echo rc=$?
(no output)
rc=1
$ ls -d /opt/UnrealEngine /opt/unreal* /usr/share/unreal* "$HOME/UnrealEngine"*; echo rc=$?
(no output)
rc=2
$ ss -ltn | grep -c ':8000'
0
```

`ABSENT UnrealEditor`, `ABSENT UnrealEditor-Cmd`, `ABSENT UE4Editor`, `ABSENT UnrealBuildTool`. Zero listeners on `:8000`. Static artifact `corpus/artifacts/unreal-r22/` is present (`Headless3DFixture.uplugin`, `Headless3DFixture.bad-type.uplugin`, `verify_descriptor.py`, `README.md`). That is evidence class (a) in the row: lane-authored, static-only. It is not an editor and not a bounded fixture run of Unreal. **No promotion. No runtime claim.**

### three.js — lane-local pin / `partial` — holds under both Node states

Lock and install (read, not `npm ci`):

```text
$ python3 -c "… package.json / package-lock.json / node_modules/three/package.json …"
pkg_dep 0.186.1
lock_version 0.186.1
lock_resolved https://registry.npmjs.org/three/-/three-0.186.1.tgz
node_modules_present True
installed_version 0.186.1
```

`require.resolve('three')` from the repo root fails in both states (`MODULE_NOT_FOUND`). That matches the row's "scoped install" note. No GL context in either state:

```text
$ node --version
v26.12.0
$ node -e "console.log(typeof globalThis.WebGLRenderingContext, typeof globalThis.document, typeof globalThis.window)"
undefined undefined undefined
$ PATH="…/v24.21.0/installation/bin:$PATH" node --version
v24.21.0
$ PATH="…/v24.21.0/installation/bin:$PATH" node -e "console.log(typeof globalThis.WebGLRenderingContext)"
undefined
```

Object3D math runs from the vendored module under both binaries (not a renderer):

```text
$ node --input-type=module -e "import * as THREE from './corpus/fixtures/three/node_modules/three/build/three.module.js'; const o=new THREE.Object3D(); o.position.set(1,2,3); console.log('Object3D', o.position.x, o.position.y, o.position.z, 'rev', THREE.REVISION);"
Object3D 1 2 3 rev 186
# same command with PATH prefixed to fnm v24.21.0:
Object3D 1 2 3 rev 186
```

`partial` is the correct cell: scene-graph math under Node, no GL, no pixels, no browser. Neither Node state supplies a GL context, so the two-state model does **not** move this cell. A same-window census receipt (`reports/round-106/census/three-default.md`, default node only) records `run_cases.mjs` 3/3 and `run_camera_cases.mjs` 5/5, exit 0, `seeds_unchanged=true`, node `v26.12.0`, three `0.186.1`. That is additional fixture evidence for `partial`, not a promotion to `yes`. This seat did not run those suites and does not claim the pinned-env suite result (SEAT-27's `census/three-pinned.md` was not on disk at `2026-10-18T21:21:40Z`).

## What would be required to promote (none met)

The file's own rule: a row moves to `executable headless` = `yes` only with a saved bounded-fixture receipt **and** a non-author verifier.

| row | missing for a `yes` move |
|---|---|
| Godot | already `yes`; no move available |
| Unity | editor absent; static checker is not a Unity run |
| Unreal | editor absent; no bounded Unreal fixture receipt can exist here |
| three.js | `partial` is accurate; a GL/renderer receipt does not exist and was not produced |

Cannon (`reports/round-106/census/cannon.md`) is a Godot-headless lane fixture driving vendored cannon-es under pinned Node. It is not an engine row and was not used to add one.

## Queued (not fixed — not this seat's file)

1. **Stale Node parenthetical.** `engines.md` three.js `installed` cell says `Node v26.11.1`. Live default at this probe is mise `v26.12.0` (`/home/vgpnk/.local/share/mise/installs/node/26.12.0/bin/node`). Same staleness r102 flagged (`v26.11.1` vs then-host `v26.12.0`) and r105 `reports/round-105/default-state.md` recorded. State cells do not move. Owner: SEAT-38. Fix shape: dated correction note, not a silent rewrite. Do not collapse this into the pinned-env battery count.
2. **Census still in flight at this read.** `ls reports/round-106/census/*.md` at `2026-10-18T21:21:40Z` → `cannon.md`, `phys3d-joints.md`, `three-default.md` only. Later census files are not inputs to this verdict. A later receipt cannot promote a row unless it is a bounded run of that engine plus a non-author verifier — which none of the declared census seats are chartered to be for Unity or Unreal.

## Not claimed

- Not a full battery. Default-env 337/350 and pinned-env 350/350 are r105 facts; this seat did not rerun `run_battery.py`.
- Not an Unreal or Unity runtime result.
- Not a rewrite of `engines.md`. Sha `d03907d3…c3bddf` at write time.
