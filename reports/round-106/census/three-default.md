# SEAT-26 CENSUS-THREE-DEFAULT — r106

Axes: depth (both three.js suites re-run under the live default node, receipts saved), calibration (default state is mise Node v26.12.0, not the engines.md `v26.11.1` string and not the pinned fnm v24.21.0), coverage (scene-graph 3/3 and camera 5/5, not one runner standing in for the other).

State: **default node only**. This seat did not prepend the fnm pin and did not rerun under v24.21.0. No `engines.md` edit (that file is outside this seat's chunk). No fixture code written. No Unreal/Unity/Godot runtime claim. No renderer, GL context, pixels, or browser claim — both runners' own `boundedClaim` fields say the same.

## Result

| suite | command | node recorded in receipt | result | runner exit | seeds |
|---|---|---|---|---:|---|
| Object3D scene graph | `node corpus/fixtures/three/run_cases.mjs --receipt reports/round-106/census/three-run_cases-20261018T212022Z.json` | v26.12.0 | **3/3 PASS** (positive exit 0, negative_wrong_order exit 2, mutation exit 1) | 0 | `seeds_unchanged=true` |
| PerspectiveCamera / frustum | `node corpus/fixtures/three/run_camera_cases.mjs --receipt reports/round-106/census/three-run_camera_cases-20261018T212022Z.json` | v26.12.0 | **5/5 PASS** (inside exit 0, far_outside exit 2, near_outside exit 2, mutate_far exit 1, mutate_near exit 1) | 0 | `seeds_unchanged=true` |

Installed three is **0.186.1**, matching `package.json` `dependencies.three`, lock `packages["node_modules/three"].version`, and `node_modules/three/package.json`. Lock resolved `https://registry.npmjs.org/three/-/three-0.186.1.tgz`, integrity `sha512-blFeqb49wRCSGUGj7gtpfnSGHy2lwDk94RhUmS1c/hTby70kvChbWpkJ4Pm1390LqzzvTmzgXKHPEafJwCb8jA==`. `npm ci` was not re-run; the gitignored `node_modules/three` tree was already present and the suites resolved it.

## Default-state identity (probed, not inherited)

```text
$ node --version; command -v node; readlink -f "$(command -v node)"
v26.12.0
/home/vgpnk/.local/share/mise/installs/node/latest/bin/node
/home/vgpnk/.local/share/mise/installs/node/26.12.0/bin/node
```

```text
$ sha256sum "$(readlink -f "$(command -v node)")"
caa24debe02770c92a70677e2a62ca98890150e7ac1c17bcfe31bcc98cc89943  /home/vgpnk/.local/share/mise/installs/node/26.12.0/bin/node
```

`node --version` bytes: `76 32 36 2e 31 32 2e 30 0a` (`v26.12.0\n`). `process.versions`: node 26.12.0, v8 14.6.202.34-node.39, uv 1.52.1, openssl 3.5.9, modules 147. npm 11.20.0 at the same mise `latest/bin`. mise 2026.9.1 (`/usr/bin/mise`); `mise ls node` shows `node 26.12.0` from `~/.config/mise/config.toml` as `latest`. Host `Linux 7.2.3-arch1-3 x86_64`. Probe time 2026-10-18T21:20:15Z / 2026-10-18T18:20:15-0300; suite stamp 20261018T212022Z.

PATH head includes `/home/vgpnk/.local/share/mise/installs/node/latest/bin` before any fnm entry. The pinned binary exists and was **not** selected:

```text
$ /home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node --version; node --version
v24.21.0
v26.12.0
```

Child commands inside both receipts are `process.execPath` = `/home/vgpnk/.local/share/mise/installs/node/26.12.0/bin/node`, so the 3/3 and 5/5 counts are that binary, not a PATH lookup that could have flipped mid-run.

## Calibration note (queued, not edited)

`corpus/knowledge/engines.md` three.js row still says "Node v26.11.1" and cites only `run_cases.mjs` → 3/3. Live default on 2026-10-18 is **v26.12.0** (same as r105 `reports/round-105/default-state.md`). This seat does not own `engines.md`. Census owner should date-correct the node string to v26.12.0 and may add the camera suite: under this default state, `run_camera_cases.mjs` is 5/5 exit 0, `seeds_unchanged=true`. Do not treat v26.11.1 as the current default. Do not collapse this default-state pass into the pinned-env 350/350 battery count — that count is a different PATH (fnm v24.21.0) and a different runner (`run_battery.py`).

## Commands actually run

Suites (repo root, default PATH, no `npm ci`):

```text
$ node corpus/fixtures/three/run_cases.mjs --receipt reports/round-106/census/three-run_cases-20261018T212022Z.json
PASS positive: exit=0 expected=0
PASS negative_wrong_order: exit=2 expected=2
PASS mutation: exit=1 expected=1
PASS three battery: 3/3, seeds_unchanged=true
run_cases_exit=0

$ node corpus/fixtures/three/run_camera_cases.mjs --receipt reports/round-106/census/three-run_camera_cases-20261018T212022Z.json
PASS inside: exit=0 expected=0
PASS far_outside: exit=2 expected=2
PASS near_outside: exit=2 expected=2
PASS mutate_far: exit=1 expected=1
PASS mutate_near: exit=1 expected=1
PASS three camera battery: 5/5, seeds_unchanged=true
run_camera_exit=0
```

Installed three vs lock (read, not install):

```text
$ python3 -c "import json; from pathlib import Path; inst=json.loads(Path('corpus/fixtures/three/node_modules/three/package.json').read_text()); lock=json.loads(Path('corpus/fixtures/three/package-lock.json').read_text()); pkg=json.loads(Path('corpus/fixtures/three/package.json').read_text()); nm=lock['packages']['node_modules/three']; print(inst['version'], pkg['dependencies']['three'], nm['version']); print(nm['resolved']); print(nm['integrity'])"
0.186.1 0.186.1 0.186.1
https://registry.npmjs.org/three/-/three-0.186.1.tgz
sha512-blFeqb49wRCSGUGj7gtpfnSGHy2lwDk94RhUmS1c/hTby70kvChbWpkJ4Pm1390LqzzvTmzgXKHPEafJwCb8jA==
```

Receipt digests:

```text
$ sha256sum reports/round-106/census/three-run_cases-20261018T212022Z.json reports/round-106/census/three-run_camera_cases-20261018T212022Z.json
1668bb85c370d6bdfd578981f61a64d78a5cb17bb8ff5f89250aa9f712120611  reports/round-106/census/three-run_cases-20261018T212022Z.json
d5b99f3ce533c388df43cc1a152592ec1e7b3e7755d3a3b8926ed7f03d210298  reports/round-106/census/three-run_camera_cases-20261018T212022Z.json
```

Seed digests recorded inside the receipts (runner-computed, unchanged across each run):

| file | sha256 |
|---|---|
| `corpus/fixtures/three/scene_graph.mjs` | `e4bb0a136391cb42baafcbab4905e1c4004d316cec44f5f67519f37a2ab075af` |
| `corpus/fixtures/three/run_cases.mjs` | `97eca1b2e26db106e5ab7efe71767b533d99abdc1ee9ff80156ac402e11458e5` |
| `corpus/fixtures/three/camera_frustum.mjs` | `5201644570fb056c1916884135c0be1fa3577dd0b9431a7a6350d4387238bded` |
| `corpus/fixtures/three/run_camera_cases.mjs` | `b6aee605bf63fff2b3c5ee843bf4231c2f4c82bc3be80bbc252e359923bf8f6c` |
| `corpus/fixtures/three/package.json` | `799216c1e1574c14848ba79c752e11ef63ed208a73954dc7024f4866b45367fe` |
| `corpus/fixtures/three/package-lock.json` | `1a8e6ee2341eb4e3bcf764ad0c14973c89afee0a613bb14d41ea2fa5851c19b8` |

HEAD at probe: `0cc3f4162f8c319f8d01a69a174fe939f36701bd`. Scoped status after the runs showed only untracked `reports/round-106/`. Fixture runners were not modified.

## Not claimed

- Not a WebGL / pixel / browser result.
- Not a statement about three.js under fnm Node v24.21.0 (not run here).
- Not a battery total. `run_battery.py` was not invoked.
- `engines.md` "Node v26.11.1" was not rewritten; it is stale relative to this probe.
