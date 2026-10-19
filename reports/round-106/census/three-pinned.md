# SEAT-27 CENSUS-THREE-PINNED — r106

Axes: depth (same three.js suites as SEAT-26, re-run under fnm Node v24.21.0, receipts saved), calibration (pinned state is fnm v24.21.0, not mise v26.12.0 and not the engines.md `v26.11.1` string; receipt diffs are only the node identity fields), coverage (scene-graph 3/3 and camera 5/5 under the pin, plus the cited `npm ci` restore on an isolated archive).

State: **pinned node only for the census claim**. Comparison controls were the same commands with the pin prefix removed, plus SEAT-26's already-written default receipts. No `engines.md` edit (outside this chunk). No fixture code written. No Unreal/Unity/Godot runtime claim. No renderer, GL context, pixels, or browser claim — both runners' `boundedClaim` fields say the same, and no renderer was constructed.

## Result

| suite | command | node recorded in receipt | result | runner exit | seeds |
|---|---|---|---|---:|---|
| Object3D scene graph | `PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" node corpus/fixtures/three/run_cases.mjs --receipt reports/round-106/scratch/seat27/paired/run_cases.json` | v24.21.0 | **3/3 PASS** (positive exit 0, negative_wrong_order exit 2, mutation exit 1) | 0 | `seeds_unchanged=true` |
| PerspectiveCamera / frustum | same PATH prefix, `node corpus/fixtures/three/run_camera_cases.mjs --receipt reports/round-106/scratch/seat27/paired/run_camera_cases.json` | v24.21.0 | **5/5 PASS** (inside exit 0, far_outside exit 2, near_outside exit 2, mutate_far exit 1, mutate_near exit 1) | 0 | `seeds_unchanged=true` |

Installed three is **0.186.1**, matching `package.json`, lock `packages["node_modules/three"].version`, and `node_modules/three/package.json`. Lock resolved `https://registry.npmjs.org/three/-/three-0.186.1.tgz`, integrity `sha512-blFeqb49wRCSGUGj7gtpfnSGHy2lwDk94RhUmS1c/hTby70kvChbWpkJ4Pm1390LqzzvTmzgXKHPEafJwCb8jA==`. Live `npm ci` was not re-run against `corpus/fixtures/three/node_modules` (gitignored, already present, shared with other seats). An isolated `git archive` copy was installed under the pin; see below.

## Byte comparison vs default-env outputs

Paired against SEAT-26 receipts `reports/round-106/census/three-run_cases-20261018T212022Z.json` (sha256 `1668bb85c370d6bdfd578981f61a64d78a5cb17bb8ff5f89250aa9f712120611`, matches that seat's published hash) and `reports/round-106/census/three-run_camera_cases-20261018T212022Z.json` (sha256 `d5b99f3ce533c388df43cc1a152592ec1e7b3e7755d3a3b8926ed7f03d210298`, likewise).

Runner stdout is byte-identical to the text SEAT-26 recorded, and to this seat's own default-PATH rerun of the same commands:

| stream | bytes | sha256 | cmp vs default |
|---|---:|---|---|
| `run_cases` stdout | 157 | `f5139774c2930711f05773672c1639265e793180953c23314d9dceba844050b0` | identical (stderr 0 bytes both) |
| `run_camera_cases` stdout | 228 | `7c4d44125d16b3ad75d777afdab5918a587f5bcb59f8a0fea6d4411083b0af94` | identical (stderr 0 bytes both) |

Receipt JSON is **not** byte-identical. Field walk of the two pairs found only these differences (4 fields in the scene-graph receipt, 6 in the camera receipt):

- `node`: default `v26.12.0`, pinned `v24.21.0`
- `results[i].command[0]`: default `/home/vgpnk/.local/share/mise/installs/node/26.12.0/bin/node`, pinned `/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node`

Everything else matched: `three=0.186.1`, `verdict=PASS`, `seedsUnchanged=true`, seed digests, expected lines, exits, stdout/stderr bodies, `boundedClaim`. Pinned receipt hashes: scene-graph `46bb981a37fd6d1ecfdfd38ebe7fabf8be2b64144fe0140b932a74792f4ddfcd` (2520 bytes vs default 2481); camera `de99bbedcc17fc13f874aa2e73828d779b44671c47fe4de94f19cd9a3524d622` (3957 bytes vs default 3892).

Seed digests inside the pinned receipts (same values SEAT-26 recorded):

| file | sha256 |
|---|---|
| `scene_graph.mjs` | `e4bb0a136391cb42baafcbab4905e1c4004d316cec44f5f67519f37a2ab075af` |
| `run_cases.mjs` | `97eca1b2e26db106e5ab7efe71767b533d99abdc1ee9ff80156ac402e11458e5` |
| `camera_frustum.mjs` | `5201644570fb056c1916884135c0be1fa3577dd0b9431a7a6350d4387238bded` |
| `run_camera_cases.mjs` | `b6aee605bf63fff2b3c5ee843bf4231c2f4c82bc3be80bbc252e359923bf8f6c` |
| `package.json` | `799216c1e1574c14848ba79c752e11ef63ed208a73954dc7024f4866b45367fe` |
| `package-lock.json` | `1a8e6ee2341eb4e3bcf764ad0c14973c89afee0a613bb14d41ea2fa5851c19b8` |

## Pinned-state identity (probed, not inherited)

```text
$ PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" node --version; PATH=... command -v node; PATH=... readlink -f "$(PATH=... command -v node)"
v24.21.0
/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node
/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node
```

`ls -l` shows a regular file, not a symlink (126595440 bytes, mtime 2026-09-07 20:56). `sha256sum` of that binary: `7fde7b8afa198da66257f42ee2001d874c7355631e6d1579a5fb5ef1f246df4c`. `node --version` bytes: `76 32 34 2e 32 31 2e 30 0a` (`v24.21.0\n`). `process.versions`: node 24.21.0, v8 13.6.233.17-node.53, uv 1.52.1, openssl 3.5.8, modules 137. npm 11.19.0 at the same fnm `bin`. Host `Linux 7.2.3-arch1-3 x86_64`. Identity probe 2026-10-18T21:31:27Z / 2026-10-18T18:31:27-0300. Full identity dump: `reports/round-106/scratch/seat27/paired/identity.txt`.

The prefix is command-scoped. Immediately after the pinned `node --version` printed `v24.21.0`, an unprefixed `node --version` still printed `v26.12.0`. Child commands inside both pinned receipts are `process.execPath` equal to the fnm binary above, so the 3/3 and 5/5 counts are that binary.

## Cited install command, isolated archive (not the live tree)

`corpus/knowledge/engines.md` evidence cell is `npm ci --prefix corpus/fixtures/three && node corpus/fixtures/three/run_cases.mjs`. Re-run on two `git archive HEAD corpus/fixtures/three` trees under `reports/round-106/scratch/seat27/ci-pinned` and `ci-default`, `TMPDIR` set to `reports/round-106/scratch/seat27/tmp` (not `/tmp`). Live `corpus/fixtures/three/node_modules` was not the install target; after the runs `git status --short -- corpus/fixtures/three` was empty and installed three there was still 0.186.1.

```text
$ PATH=".../v24.21.0/installation/bin:$PATH" npm ci --prefix corpus/fixtures/three
added 1 package, and audited 2 packages in 366ms
found 0 vulnerabilities
pinned_npm_ci_exit=0

$ PATH=".../v24.21.0/installation/bin:$PATH" node corpus/fixtures/three/run_cases.mjs
PASS positive: exit=0 expected=0
PASS negative_wrong_order: exit=2 expected=2
PASS mutation: exit=1 expected=1
PASS three battery: 3/3, seeds_unchanged=true
pinned_after_ci_exit=0
```

Default-PATH `npm ci` in the sibling archive also exited 0 (`added 1 package, and audited 2 packages in 349ms`). `npm ci` stdout is **not** byte-identical: the only diff is the timing token `349ms` vs `366ms`. Post-install `run_cases.mjs` stdout/stderr **are** byte-identical across the two archives, sha256 `f5139774c2930711f05773672c1639265e793180953c23314d9dceba844050b0`, both exits 0. Install finished 2026-10-18T21:36:37Z.

Bare `node corpus/fixtures/three/run_cases.mjs` on a fresh archive with no `node_modules` exits 1 under both PATH states. Stdout is byte-identical (157 bytes, sha256 `c984c3dc4b5d1994e5a99ea09d5356ea37fbc1cfdff3697b7b1e7f4a4d902dd4`), stderr 0 bytes both:

```text
FAIL positive: exit=1 expected=0
FAIL negative_wrong_order: exit=1 expected=2
FAIL mutation: exit=1 expected=1
FAIL three battery: 3/3, seeds_unchanged=true
```

The summary still says `3/3` on failure. That text is the runner's own line (`run_cases.mjs` prints a fixed `3/3`), and it is the same under both nodes — not a pin regression. The camera runner on the same empty archive exits 1 both states with byte-identical stdout (sha256 `de917bbc13c82ddd1fb88a0d11998ae7b2e94cc7608b45d358fd1553ec280946`) and correctly prints `FAIL three camera battery: 0/5`.

`require.resolve('three')` from the repo root exits 1 under both nodes. Stdout is byte-identical: `code=MODULE_NOT_FOUND` / `Cannot find module 'three'`. From `corpus/fixtures/three`, both nodes resolve the same path: `.../corpus/fixtures/three/node_modules/three/build/three.cjs`. Repo-root ESM `import('three')` is `ERR_MODULE_NOT_FOUND`. From the fixture directory both nodes import three `REVISION=186` with `Object3D` and `WebGLRenderer` both `function`. No renderer was constructed.

## Extension beyond the SEAT-26 pair (same PATH prefix, live tree)

Not part of the paired receipt set. Stdout and stderr were byte-identical to an unprefixed rerun, all runner exits 0, stderr 0 bytes. Hashes are the shared stdout sha256:

| runner | summary line | stdout sha256 |
|---|---|---|
| `run_ortho_cases.mjs` | `PASS three ortho battery: 5/5, seeds_unchanged=true` | `702f360c071e31a0144d274641862ead170fcaa158b4e31ac4a0948cbb1f5ba8` |
| `run_ray_cases.mjs` | `PASS three ray battery: 5/5, seeds_unchanged=true` | `7f79f9f6b13b9a6643f88070741318a0cd87dff51b705d09441e3ba5097c283f` |
| `run_order_cases.mjs` | `PASS three order battery: 9/9, seeds_unchanged=true` | `f05831136de0cf54328763bd1e25f9d1e76ed1d038551fff370b3bbc4dccb5f1` |
| `run_layer_cases.mjs` | `PASS three layer battery: 4/4, seeds_unchanged=true` | `86ba00a278aa0f2ffa8d4e67e8acfac2b623ff35ac6a5a9d70274fc6670b81de` |

## Calibration note (queued, not edited) — dated 2026-10-18

`corpus/knowledge/engines.md` line 11 still contains the parenthetical `Node v26.11.1` (file sha256 `d03907d3d63771c10558a2bc276d62c50bcdea1d02150d78e6d1a720a0c3bddf` at this probe; this seat did not modify it). That string is not the current default (mise v26.12.0, SEAT-26) and not the pinned state (fnm v24.21.0, this seat). Dated correction, not a silent rewrite: the three.js headless math stdout for the cited runner is byte-identical under both live states, so the parenthetical is environment metadata, not a functional pin for `run_cases.mjs` or `run_camera_cases.mjs`. Census owner of `engines.md` should date-correct the node string rather than leave `v26.11.1` as if it were either current state. Do not collapse this pin pass into the r105 battery 350/350 count — that count is `run_battery.py`, which this seat did not run.

## Commands actually run

HEAD at probe: `0cc3f4162f8c319f8d01a69a174fe939f36701bd`. Repo root unless noted.

Pinned suites (stdout reproduced in the result table; exits 0):

```text
$ PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" node corpus/fixtures/three/run_cases.mjs --receipt reports/round-106/scratch/seat27/paired/run_cases.json
PASS positive: exit=0 expected=0
PASS negative_wrong_order: exit=2 expected=2
PASS mutation: exit=1 expected=1
PASS three battery: 3/3, seeds_unchanged=true
run_cases_exit=0

$ PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" node corpus/fixtures/three/run_camera_cases.mjs --receipt reports/round-106/scratch/seat27/paired/run_camera_cases.json
PASS inside: exit=0 expected=0
PASS far_outside: exit=2 expected=2
PASS near_outside: exit=2 expected=2
PASS mutate_far: exit=1 expected=1
PASS mutate_near: exit=1 expected=1
PASS three camera battery: 5/5, seeds_unchanged=true
camera_exit=0
```

Receipt field walk (observed): `RAW_DIFFER` both files; scene-graph `field_diffs 4`; camera `field_diffs 6`; only `node` and `results[*].command[0]` differed. Default receipt hashes re-checked and matched the hashes printed in `reports/round-106/census/three-default.md`.

`node_modules` is gitignored (`corpus/fixtures/three/.gitignore:1:node_modules/`) and `git ls-files corpus/fixtures/three/node_modules | wc -l` printed `0`. Paths named by the engines.md row exist: `corpus/fixtures/three/package-lock.json`, `corpus/fixtures/three/run_cases.mjs`, `corpus/fixtures/three/package.json`.

## Not claimed

- Not a WebGL, pixel, or browser result. `WebGLRenderer` is an exported function; it was not constructed.
- Not a battery total. `run_battery.py` was not invoked.
- Not a rewrite of `engines.md`. The `v26.11.1` parenthetical is queued above.
- Not an Unreal, Unity, or Godot runtime claim.
- `npm ci` timing differs by milliseconds across npm 11.19.0 (pin) and npm 11.20.0 (default). That is not a three.js result difference; the following runner stdout matched.
