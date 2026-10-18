# F5 — before-capture: the `engines.md` three.js evidence command fails from a clean tree

- Seat: SEAT-04 (before capture only; **no edits made to any file**)
- Round: r102
- Repo HEAD at capture: `2c99b7b8155841617d844c609813afcba77aa207`
- Working dir: `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`
- Date: 2026-10-18
- Claim under test: F5 — the three.js evidence command in `corpus/knowledge/engines.md` fails when
  run from the repository root on the committed tree.
- Verdict at capture: **CONFIRMED (exit=1 on the committed tree; exit=0 only in a working dir that
  carries an untracked `node_modules/`)**.

## 1. The citation

`corpus/knowledge/engines.md:11` (sha256 of the file: `b20e5a9b3b964bf5d8bd8fdba6f0349cf1c9fc30d949d8432e10a111a85cd06e`),
verbatim, single line:

```
| three.js 0.186.1 | lane-local npm dependency pinned in `corpus/fixtures/three/package-lock.json` (Node v26.11.1) | partial — `Object3D` scene graph/math under Node; no GL context | `node corpus/fixtures/three/run_cases.mjs` → 3/3 and named non-author r6 review (work commit in report) | `require.resolve('three')` failed from repo root before scoped install; no rendering, pixels or browser claim |
```

The evidence command, exactly as written, is:

```
node corpus/fixtures/three/run_cases.mjs
```

This is the **only** three.js evidence cite in the tree (`grep -rn "run_cases.mjs" corpus/knowledge/ README.md SCORECARD.md`
returns exactly this one hit). The file was last touched by `7804a69` (2026-10-13, "game-dev-3d r22:
record Unreal static coverage boundary").

## 2. Command run exactly as written, from the repo root

### 2a. On the current working directory (what a reader of `engines.md` would do today)

```
$ cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
$ node corpus/fixtures/three/run_cases.mjs
PASS positive: exit=0 expected=0
PASS negative_wrong_order: exit=2 expected=2
PASS mutation: exit=1 expected=1
PASS three battery: 3/3, seeds_unchanged=true
exit=0
```

### 2b. On the **committed tree** — a pristine export of HEAD, nothing added

`node_modules/` is gitignored, so a fresh clone/export has none. Method: read-only export, no
working-tree mutation of the lane repo.

```
$ rm -rf /tmp/r102-f5-pristine && mkdir -p /tmp/r102-f5-pristine
$ cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
$ git archive HEAD | tar -x -C /tmp/r102-f5-pristine
$ cd /tmp/r102-f5-pristine
$ ls -d corpus/fixtures/three/node_modules
ls: cannot access 'corpus/fixtures/three/node_modules': No such file or directory
$ node corpus/fixtures/three/run_cases.mjs
FAIL positive: exit=1 expected=0
FAIL negative_wrong_order: exit=1 expected=2
FAIL mutation: exit=1 expected=1
FAIL three battery: 3/3, seeds_unchanged=true
exit=1
```

stdout is the four `FAIL` lines above, **verbatim**; stderr is **empty**. The runner's summary
line is itself misleading — `three battery: 3/3` is hard-coded text emitted after the `FAIL`
verdict prefix (`run_cases.mjs:39`), so on failure it reads `FAIL three battery: 3/3`.

### 2c. Root cause — the cited dependency is not on disk

```
$ cd /tmp/r102-f5-pristine
$ node corpus/fixtures/three/scene_graph.mjs
node:internal/modules/esm/resolve:989
    throw error;
    ^

Error [ERR_MODULE_NOT_FOUND]: Cannot find package 'three' imported from /tmp/r102-f5-pristine/corpus/fixtures/three/scene_graph.mjs
    ...
exit=1
```

Each of the three arms is a `spawnSync` of `scene_graph.mjs`; every arm dies with
`ERR_MODULE_NOT_FOUND`, which the runner records as `exit=1` and `FAIL`. So all three arms fail
for the same single reason, and the "3/3 PASS" claim in `engines.md:11` is unreproducible from a
clone.

## 3. Why the dependency is missing — tracking facts

```
$ git ls-files corpus/fixtures/three/node_modules | wc -l
0
$ git check-ignore -v corpus/fixtures/three/node_modules corpus/fixtures/three/node_modules/three
corpus/fixtures/three/.gitignore:1:node_modules/	corpus/fixtures/three/node_modules
corpus/fixtures/three/.gitignore:1:node_modules/	corpus/fixtures/three/node_modules/three
$ cat corpus/fixtures/three/.gitignore
node_modules/
```

Tracked, and therefore present in a clone:

```
corpus/fixtures/three/.gitignore
corpus/fixtures/three/package.json
corpus/fixtures/three/package-lock.json
corpus/fixtures/three/README.md
corpus/fixtures/three/{scene_graph,camera_frustum,orthographic_frustum,raycast_layers,raycast_order,raycast_triangle}.mjs
corpus/fixtures/three/run_{cases,camera_cases,ortho_cases,ray_cases,order_cases,layer_cases}.mjs
```

`package.json` pins `"three": "0.186.1"`; `package-lock.json` pins the same version with integrity
`sha512-blFeqb49wRCSGUGj7gtpfnSGHy2lwDk94RhUmS1c/hTby70kvChbWpkJ4Pm1390LqzzvTmzgXKHPEafJwCb8jA==`.
Both are committed, so the failure is **not** a missing pin — it is a missing **install step**: the
committed tree ships no `node_modules/` and no script that performs the install.

## 4. Isolation control — restoring only `node_modules` flips the result

Same pristine export, with only the untracked `node_modules/` copied in (**no tracked file
changed**; `git status --porcelain` in the lane repo stayed clean apart from other seats' files):

```
$ cp -r /home/vgpnk/.../corpus/fixtures/three/node_modules /tmp/r102-f5-clean/corpus/fixtures/three/node_modules
$ cd /tmp/r102-f5-clean
$ node corpus/fixtures/three/run_cases.mjs
PASS positive: exit=0 expected=0
PASS negative_wrong_order: exit=2 expected=2
PASS mutation: exit=1 expected=1
PASS three battery: 3/3, seeds_unchanged=true
exit=0
```

This pins the defect to the **dependency presence**, not to the fixture, the runner, the Node
version, or the path form.

## 5. Candidate repair path (probe only — not applied by this seat)

`npm ci` in the fixture directory succeeds and makes the cited command pass, from a pristine export:

```
$ cd /tmp/r102-f5-clean2/corpus/fixtures/three
$ npm ci --offline
added 1 package, and audited 2 packages in 215ms
found 0 vulnerabilities
NPM_EXIT=0
$ cd /tmp/r102-f5-clean2 && node corpus/fixtures/three/run_cases.mjs
PASS positive: exit=0 expected=0
PASS negative_wrong_order: exit=2 expected=2
PASS mutation: exit=1 expected=1
PASS three battery: 3/3, seeds_unchanged=true
exit=0
```

`--offline` was used because the tarball is already in the npm cache; a plain `npm ci` would need
registry access. So the minimal self-contained repair is one of:
(i) state the install step in the evidence cell (`cd corpus/fixtures/three && npm ci`, then the run),
or (ii) make the run self-contained (a wrapper that installs on demand). Either way the
`engines.md:11` evidence cell currently presents a bare `node …` invocation as if it were
re-runnable from the committed tree, and it is not.

## 6. Supporting facts for the repair seat

- Toolchain at capture: `node v26.12.0`, `npm 11.20.0`. Note the row's own parenthetical says
  "Node v26.11.1" — the host has moved on; the fixture itself is version-tolerant (it reads
  `process.version` into its receipt payload).
- Seed digests at capture (unchanged by this seat):
  - `corpus/fixtures/three/run_cases.mjs` = `97eca1b2e26db106e5ab7efe71767b533d99abdc1ee9ff80156ac402e11458e5`
  - `corpus/fixtures/three/scene_graph.mjs` = `e4bb0a136391cb42baafcbab4905e1c4004d316cec44f5f67519f37a2ab075af`
  - `corpus/fixtures/three/package.json` = `799216c1e1574c14848ba79c752e11ef63ed208a73954dc7024f4866b45367fe`
  - `corpus/fixtures/three/package-lock.json` = `1a8e6ee2341eb4e3bcf764ad0c14973c89afee0a613bb14d41ea2fa5851c19b8`
- Before/after command pair for the repairing seat:
  - before: `git archive HEAD | tar -x -C /tmp/x && (cd /tmp/x && node corpus/fixtures/three/run_cases.mjs)` → **exit=1**
  - after: the same, with the documented install step present → must be **exit=0, 3/3 PASS**.
- Discipline: `engines.md:11`'s "→ 3/3" is a historical factual claim tied to an r6 work commit, so
  it should not be silently rewritten. The defect here is a **missing precondition** in a
  mechanical evidence command; adding the install step (or a dated note naming it) is the
  in-place/conformance repair, consistent with the lane's correction-note discipline.

## 7. Boundary notes

- **No Unreal runtime claim** is made or implied here; this report touches only the three.js row.
- The r101 unreal-mcp subtree was not read or modified by this seat.
- Overlap with other seats (not fixed here, reported for routing): `corpus/fixtures/three/README.md:7-8`
  and `corpus/artifacts/glb-r12/README.md:8` cite the same command through a
  `.shokunin/game-dev-3d/` prefix — that prefix is F1's subject, and the same install
  precondition applies there.
- Files written by this seat: this file only (`reports/round-102/before/F5-engines-threejs.md`).
  No file under `corpus/` was modified; `git status --porcelain` shows no change attributable to
  this seat.
