# Engine census — maintained by the lane

Standing host reality (mint, 2026-10-13). Update this file whenever a
tooling probe lands; every claim cites its probe. An installed /
executable-headless cell moves only with a saved bounded-fixture receipt
and a non-author verifier. r106 re-probed every existing row under the
r105 two-state model. No existing state cell moved. A Blender row was
added after `reports/round-106/census/bpy.md` landed; its
executable-headless cell is `partial`, not `yes`.

## Host environment — two states (r105 model, re-probed r106)

Battery totals are environment-dependent, not two counts of one run.
Default `PATH` selects mise Node. Thirteen positive `r94_cannon_*`
markers pin `node=v24.21.0`, selected by prepending the fnm installation
for that invocation only. The prefix does not change mise or fnm config.
After a prefixed command, plain `node --version` was still `v26.12.0`
(2026-10-18T21:29:20Z).

| state | selection | observed this seat | full-battery receipt (parsed, not re-run) |
|---|---|---|---|
| default | plain `node` | `v26.12.0`; `command -v node` → `/home/vgpnk/.local/share/mise/installs/node/latest/bin/node`; `process.execPath` → `/home/vgpnk/.local/share/mise/installs/node/26.12.0/bin/node`; sha256 `caa24debe02770c92a70677e2a62ca98890150e7ac1c17bcfe31bcc98cc89943` | `reports/round-104/physics/full-regression-runs/20261018T194637610772Z-verdicts.json`: cases=350 pass=337 fail=13, verdict FAIL, `seeds_unchanged=true`. All 13 fails are `r94_cannon_*` with `exact stdout marker missing` and token `node=v26.12.0`. Godot in that receipt: `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`. |
| pinned | `PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH"` | `v24.21.0`; `command -v node` → that `bin/node`; sha256 `7fde7b8afa198da66257f42ee2001d874c7355631e6d1579a5fb5ef1f246df4c` | Accepted: `reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json`: cases=350 pass=350 fail=0, verdict PASS, `seeds_unchanged=true`. 13 positive `r94_cannon_*` rows all PASS, token `node=v24.21.0`. The earlier capture `corpus/live/runs/20261018T202944290389Z/verdicts.json` is 350 row-passes but verdict FAIL / `seeds_unchanged=false` — not a clean PASS. |

Runner, re-hashed this seat: `sha256sum corpus/fixtures/run_battery.py` →
`f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`. Lane
HEAD at probe: `0cc3f4162f8c319f8d01a69a174fe939f36701bd`.

> **Correction note (r106, 2026-10-18) — Node `v26.11.1`.** Through r105
> the three.js installed cell said `(Node v26.11.1)` with no date. That
> string is a mint-time host fact. The r102 F5 repair left it untouched;
> `reports/round-102/engines-verify.md` flagged it against host `v26.12.0`;
> r106 `reports/round-106/census/verify.md` and
> `reports/round-106/census/three-default.md` queued the same drift. It is
> not the three.js package pin (`0.186.1`) and not the 2026-10-18 default
> (mise `v26.12.0`) or the pinned battery Node (fnm `v24.21.0`). The
> historical string is preserved in this note. Do not read it as the live
> default.

| tooling | installed | executable headless | evidence | notes |
|---|---|---|---|---|
| Godot 4.7.2 | yes (`/usr/bin/godot`) | yes | r106 default-env bounded receipt `reports/round-106/scratch/seat38/20261018T213322137930Z/verdicts.json` (`python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops --runs reports/round-106/scratch/seat38`, timeout 20): PASS, exit 0/0, `seeds_unchanged=true`, godot `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf` version exit 0. `godot --version` the same string, rc 0 (2026-10-18T21:29:20Z). Peer default-env rows, parsed this seat: `reports/round-106/census/phys3d-joints/runs/20261018T212035512412Z/verdicts.json` (`free_pair`) and `reports/round-106/census/phys3d-joints/runs/20261018T212038422172Z/verdicts.json` (`free_ops`), both PASS / seeds true / same godot string. Full-battery godot identity is in both rows of the two-state table; the 13 default fails are cannon marker mismatches, not a missing Godot. | primary executable runtime at mint; 2D-agnostic patterns inherited from games-engine-mechanics. Headless `yes` is the Godot binary and Godot fixtures, not a claim that the default-env battery is 350/350 |
| Unity Editor | no | no | r106 absence: `command -v unity Unity UnityHub unityhub` → rc 1; no `/opt/unity`, `/opt/Unity`, `/usr/share/unity`, `~/Unity`, `~/UnityHub`. Static class unchanged: `uv run --no-project --with pyyaml python corpus/artifacts/unity-r19/verify_scene.py` → `PASS local-static actual=accept` rc 0; paired `--expect-reject` on `Hierarchy.broken-reference.unity` → `PASS local-static actual=reject` rc 0 (2026-10-18). | no Linux editor installed; r19 local static reference checks do not prove Unity import, execution, or UnityYAML completeness |
| Unreal Engine | no | no | editor absent (r106): `command -v UnrealEditor UnrealEditor-Cmd UE4Editor UnrealBuildTool` → rc 1; no `/opt/UnrealEngine`; `ss -ltn` `:8000` count 0. Two static classes, neither runtime (gate census `verified-here=0`): (a) `python3 corpus/artifacts/unreal-r22/verify_descriptor.py` → `PASS local-static actual=accept` rc 0, paired reject → `PASS local-static actual=reject` rc 0; (b) pinned tree `corpus/knowledge/unreal-mcp/` @ `a6aa73ada02a9fb1f5415bec491f9942c519b297` — `(cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256)` → 12× OK, rc 0. Gate re-run this seat, `GATE_WORKDIR=$HOME/scratch-r106-seat38/gate corpus/knowledge/unreal-mcp/gate/run_gate.sh` (2026-10-18T21:38:07Z) → rc 0, stderr 0, `MANIFEST_OK=12`, `CLONE_HEAD=` that pin, census `static-only=12 unproven-runtime=1 verified-here=0`, `POINTERS=103 POINTER_STRINGS=41 UNRESOLVED=0`, `GATE RESULT: PASS`. In-repo capture of the same summary, hash-checked, not launched by this seat: `reports/round-106/gate/scratch/gate-run.stdout` sha256 `c69c93614b99db75047bb174b0406323fb9801d400e055f8eaf12e5b3c159c2b`. | not installed; (a) is lane-authored, so it only proves the lane's checker accepts the lane's descriptor; (b) is someone else's bytes at the pinned commit. Neither proves plugin load, UBT, or editor runtime. A green gate is not a live-editor result. Every live-editor claim on (b) is unproven by construction |
| three.js 0.186.1 | lane-local npm dependency pinned at `three@0.186.1` in `corpus/fixtures/three/package-lock.json`. Host Node is the two-state table, not one version (historical parenthetical `Node v26.11.1` — correction note above) | partial — `Object3D` scene graph/math under Node; no GL context | clean-tree recovery remains `npm ci --prefix corpus/fixtures/three && node corpus/fixtures/three/run_cases.mjs` (r102). This seat did not repeat `npm ci` on the live tree. r106 re-probe on the existing `node_modules/three@0.186.1` (lock integrity `sha512-blFeqb49wRCSGUGj7gtpfnSGHy2lwDk94RhUmS1c/hTby70kvChbWpkJ4Pm1390LqzzvTmzgXKHPEafJwCb8jA==`), both states, repo root: `run_cases.mjs` 3/3 exit 0 and `run_camera_cases.mjs` 5/5 exit 0, `seeds_unchanged=true`, under default `v26.12.0` and under pinned `v24.21.0`. Peer default receipt, parsed: `reports/round-106/census/three-run_cases-20261018T212022Z.json` node `v26.12.0` three `0.186.1` verdict PASS seeds true. After the first r106 write, `reports/round-106/census/three-pinned.md` recorded an isolated `git archive` `npm ci` under both Node states (exit 0) then `run_cases.mjs` 3/3 exit 0; bare `node corpus/fixtures/three/run_cases.mjs` with no `node_modules` exits 1 under both states. That peer also re-ran camera 5/5 under the pin (agrees) and, not re-run here, ortho 5/5, ray 5/5, order 9/9, layer 4/4. | requires the gitignored `corpus/fixtures/three/node_modules/` layout; `npm ci --prefix` restores it from the lockfile. No rendering, pixels, or browser claim. These runners are not the battery's 13 cannon-marker failures |
| Blender 5.2.1 LTS | yes (`/usr/bin/blender`, pacman `17:5.2.1-2`) | partial — `blender -b` imports `bpy`; lane `bpy_battery.py` not re-run this round, so not `yes` | this seat 2026-10-18T21:51:20Z: `command -v blender` → `/usr/bin/blender` rc 0; `blender --version` → `Blender 5.2.1 LTS`, build hash `9e2066aef7ef`, build date 2026-09-01, rc 0; `pacman -Q blender` → `blender 17:5.2.1-2`. Import receipt read, not re-launched: `reports/round-106/census/bpy/bpy-import-default.stdout` and `reports/round-106/census/bpy/bpy-import-pinned.stdout` share sha256 `d2178ffadbf86939de18c09a0107b4cb7d3d885523df840ed4fc54da0239fe8c` and both print `bpy.app.version_string 5.2.1 LTS`, `bpy.app.background True`, `bpy.app.binary_path /usr/bin/blender`, `CENSUS_IMPORT_OK`. Peer write-up: `reports/round-106/census/bpy.md`. | Node PATH does not select this binary (both states resolve `/usr/bin/blender`; bundled Python 3.14.7). No render claim. Archived `bpy_rbw3d_*` 10/10 inside the r105 350/350 receipt is not a new bounded re-run and does not promote this cell to `yes` |

Rules: an engine row may move to "executable headless" only with a saved
receipt of a bounded fixture run and a non-author verifier, like any
other axis-move. Absence of an engine never authorizes runtime claims;
static/format evidence is labeled as such.

## Correction notes — r106, 2026-10-18

Historical cells are not silently rewritten. The table above is the
current reading; the sentences below keep the previous reading.

> **Godot evidence pointer.** The evidence cell previously said only "r1
> battery receipts under corpus/live/runs/". The cited r1 directory
> `corpus/live/runs/20261013T053632289732Z` is not in this tree (`ls` →
> No such file or directory, 2026-10-18T21:29:20Z). `corpus/live/` is
> gitignored. The resolvable headless receipts are the r106 paths in the
> Godot row and the two full-battery verdict files in the two-state table.
> The r1 pointer is history; it does not resolve here.

> **Unreal manifest command, cwd.** The evidence cell previously quoted
> `sha256sum -c .manifest.d/audit-reference.sha256` with no working
> directory. From the repo root that command exits 1 (`sha256sum:
> .manifest.d/audit-reference.sha256: No such file or directory`, observed
> 2026-10-18). A repo-root-relative manifest path also exits 1, because the
> manifest lists `upstream/…` paths. The cwd-correct form is
> `(cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256)`
> → 12× OK, rc 0, same probe. The gate invocation is cwd-independent and
> was re-run this seat (rc 0).

> **three.js Node parenthetical.** See the correction note under Host
> environment. The installed cell no longer presents `Node v26.11.1` as
> current.

> **Blender row (added, not a promotion).** The pre-r106 table had no
> Blender row (0 mentions). `reports/round-106/census/bpy.md` queued
> installed `yes` and executable-headless `partial`, and said not to write
> `yes` without a new `bpy_battery.py` or `bpy_rbw3d_*` receipt plus a
> non-author verifier. This seat confirmed the binary and version, read
> the import stdout, and did not launch `blender -b` or the battery. The
> new cell is `partial`, not `yes`.

## r106 census files this seat read

First `reports/round-106/census/` listing that contained markdown
(2026-10-18T21:21:13Z): `cannon.md`, `three-default.md`.
`phys3d-joints.md`, `n24-state.md`, and `verify.md` landed after that
read and were read before the first r106 write of this file. At the gate
re-run (2026-10-18T21:38:07Z) the markdown set was exactly those five.
None of them warranted a state-cell move.

- `reports/round-106/census/three-default.md` — default-env three.js 3/3
  and camera 5/5 under `v26.12.0`. Agrees. Camera 5/5 was also re-run by
  this seat under both states.
- `reports/round-106/census/cannon.md` — one pinned-env `r94_cannon_det`
  PASS, token `node=v24.21.0`. Parsed
  (`reports/round-106/census/cannon-r94_cannon_det-20261018T212035Z.verdicts.json`:
  PASS, seeds true, exit 0). Not a 350-case claim. No cannon engine row
  added (judgment below).
- `reports/round-106/census/phys3d-joints.md` — two default-env Godot rows
  PASS. Parsed. Supports headless `yes`; does not move it.
- `reports/round-106/census/n24-state.md` — fnm path exists,
  command-scoped `v24.21.0`, default remains `v26.12.0`. Agrees with this
  seat's probe. It reuses the cannon receipt; this seat did not treat that
  reuse as a second run.
- `reports/round-106/census/verify.md` — state columns no drift; queued
  the `v26.11.1` correction this file now carries.

Landed after the first write, read before this revision
(listing 2026-10-18T21:51:20Z). Read, not re-run, except the Blender
version probe and the three.js suites already run by this seat. No
existing state cell moved.

- `reports/round-106/census/three-pinned.md` — pinned three.js 3/3 and
  camera 5/5, plus isolated `npm ci`. Cited in the three.js row. `partial`
  stays.
- `reports/round-106/census/animtree.md` — `r99_animtree_core` PASS both
  states. Godot fixture. Does not move Godot.
- `reports/round-106/census/gltf.md` — `r98_gltflat_cls` PASS, default
  env, `eng=4.7.2-stable`. Godot fixture. Does not move Godot.
- `reports/round-106/census/navagent.md` — 99/99 PASS, default env. The
  report says navagent is not a separate engine. No row added.
- `reports/round-106/census/bpy.md` — Blender row above. Import only.
  Executable-headless stays `partial`, not `yes`.
- `reports/round-106/census/bullet.md` — 20/20 `r95_bullet_*` PASS,
  default env, marker `engine=pybullet-3.2.7`. The report says this is
  not a new `engines.md` row (vendored `.so` under a Godot fixture). No
  row added.
- `reports/round-106/census/phys3d-events.md` —
  `phys3d_events_inactive_space` PASS both states. Godot fixture. Does
  not move Godot.
- `reports/round-106/census/area3d.md` — landed after the 21:51:20Z
  listing. `r93_areasig_edges` PASS both states. Godot fixture. Does
  not move Godot. Not re-run by this seat.

Census markdown was still arriving while this file was being written.
A `reports/round-106/census/*.md` file not named above had not been
read at this revision. It does not move a state cell until a later
pass reads it.

## Judgment queue (not applied as state moves)

- No `cannon-es` row. It is a vendored library driven by a Godot fixture,
  not an installed engine. One ordinary row PASS does not meet the
  executable-headless promotion rule.
- No pybullet row. `reports/round-106/census/bullet.md` says the 20-row
  PASS is not a new census row. Same class as cannon: vendored bytes
  under a Godot fixture, not an installed editor.
- Blender is the one added row, and it is `partial`, not `yes`. Promoting
  it needs a new saved `bpy_battery.py` or `bpy_rbw3d_*` receipt and a
  non-author verifier. Not done here.
- `SKILL.md` §6 still stamps this file at
  `d03907d3d63771c10558a2bc276d62c50bcdea1d02150d78e6d1a720a0c3bddf` (the
  pre-r106 bytes). That file is protected this round; the stamp is stale
  once this edit lands. Re-hash before acting on it.
- `PROVINCE.md` standing host fact still names Godot / Unity / Unreal /
  three.js and not Blender. Protected this round. Not edited.
- r105 `reports/round-105/r105-connector.md` told a later census to keep
  `v26.11.1` as three.js evidence context. That report is protected. This
  note supersedes that reading for the installed cell: keep the string as
  a dated historical fact, not as the live default.
