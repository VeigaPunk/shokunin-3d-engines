# game-dev-3d round 86 — bpx-scout (seat: BPX-SCOUT / g3d, host: devin)

Wave `shokunin-train-20261101-w17`, lane g3d. Assignment
(`.ufo/waves/shokunin-train-20261101-w17/tasks/g3d-bpy-scout.md`, verbatim):
"SEAT: g3d BPX-SCOUT — recon the bpy + three.js surfaces (idle while phys3d
churns) … bpy_battery.py: 83 cases — class/axis coverage map; when last
advanced; which classes (refused/deferred/ignored/anomaly analogs) exist there
vs the godot lattice. bpy_sync_probe.py: what does it do, what runtime does it
need (blender on PATH? bpy pip module?), can it run bounded here? three/: the
three.js battery — 31 cases — structure, runner, coverage classes; node version
pinned? Cross-pollination candidates: which phys3d findings (write-phase deltas,
query refusals, backend identity) have bpy/three analogs worth arming … Blender
version + bpy availability check (bounded, timeout-guarded). Deliver: coverage
matrix + ranked frontier list for g3d r87-r90."

**Runtime (every bound below is scoped to this):** `/usr/bin/blender`
`5.2.1 LTS` (hash `9e2066aef7ef`, build 2026-09-01, build commit 2026-08-24
16:50, branch `makepkg (modified)`); `node` `v24.21.0`; `/usr/bin/python3`
`3.14.7`; embedded CPython inside blender `3.14.7`. HEAD `f230443`
(`r85: backend cross-product`). 32 cores.

**LSP unavailability recorded.** `mcp_list_servers` exposes only `rea` — no
`lsp` device serves this repo (same as r85/r86). Every fact below is
engine-measured or read-level; nothing is claimed as semantic proof. No
symbol-aware operation (rename/reference/code action) was needed — this seat
measures, it does not edit fixtures.

**Write scope respected.** All writes went to `corpus/live/bpx-scout/`
(gitignored, `corpus/.gitignore:1`) and this report. **Zero tracked-file
edits.** The two files r85 wave-B is verifying are frozen at HEAD and untouched
by me: `corpus/fixtures/phys3d_events.gd` sha
`4bcde2bf39cd829887b7cea9da41fe6c3a528cbbfd9f62900b44c30c6db72355` (1263
lines) and `corpus/fixtures/run_battery.py` sha
`991c6c8ac39a58a576dd9d1e1cc4d922a996dc9b978c9a5f435d325c2666add5`; `git diff
--name-only` is empty. **Read `corpus/live/bpx-scout/RECEIPTS.md` first** — it
names seven reading hazards, including two superseded probes and a `rc`
capture artifact.

---

## 1. Blender + bpy availability (bounded, timeout-guarded)

| probe | command | result |
|---|---|---|
| binary on PATH | `command -v blender` | `/usr/bin/blender` |
| version | `timeout 25 blender --version` | `Blender 5.2.1 LTS`, build date 2026-09-01, build commit 2026-08-24 16:50 |
| **bpy as a pip module** | `python3 -c "import bpy"` | **`ModuleNotFoundError: No module named 'bpy'`** — absent for the system interpreter |
| embedded interpreter | `blender -b --python-expr "import sys;print(sys.version)"` | `EMBEDDED_PY 3.14.7` |
| headless probe runs | `blender -b -P <probe>.py` | works; rc 0; ~0.4–1.5 s per probe |

**So the bpy runtime is `blender`-the-binary only.** `bpy` is importable
*inside* blender's embedded CPython 3.14.7 (same minor version as the system
interpreter, different environment); there is no pip-installable bpy on this
host. Any bpy fixture must be launched as `blender -b -P <script>.py` and can
never be imported by `python3` — which is exactly what the tracked pair already
does (`bpy_battery.py` runs under `python3` as the *harness* and shells out to
blender for the *probe*; the stale `__pycache__/bpy_battery.cpython-314.pyc`
confirms the harness side).

Runtime-identity surfaces the fixture *could* gate on (measured, probe A):
`bpy.app.version_string=5.2.1 LTS`, `bpy.app.version_cycle=release`,
`bpy.app.build_hash=b'9e2066aef7ef'`, `bpy.app.build_commit_date=b'2026-08-24'`,
`bpy.app.build_branch=b'makepkg (modified)'`, `bpy.app.binary_path=/usr/bin/blender`,
`bpy.app.background=True`.

---

## 2. `bpy_battery.py` — 83 cases, coverage map, and when it last moved

**When last advanced: r82.** `git log -1 -- corpus/fixtures/bpy_battery.py` =
`e79e004` ("r82 simplifier-fold … stdout sha 6a98c570 byte-identical",
2026-10-14 12:49:30 -0300). The sibling probe `bpy_sync_probe.py` shares that
commit as its last touch. **The whole bpy surface has been idle for r83, r84
and r85** (three rounds) while the Godot lattice advanced `phase_delta` →
`jolt_edge` → `jolt_threaded`/`dummy_refused`/`srv_phase_delta`.

**Fresh run, this host, this round (bounded, receipt-pinned):**

```
$ python3 corpus/fixtures/bpy_battery.py --runs corpus/live/bpx-scout/runs
totals: cases=83 pass=83 fail=0 (signal_fail=0 quirk_drift=0)
        launch_ok=True done_marker=True fatals=0 exit=0
PASS battery: …/runs/bpy-20261014T194721184607Z/verdicts.json
real 0m7.775s
```

| receipt | value |
|---|---|
| stdout | 13 495 B, 134 `ARM` lines, sha256 `6a98c570dbaec6f33f23c684ae2938470a251c229cb50d4451c23eb1d07defc3` |
| stderr | **0 bytes** |
| verdict | 83/83 PASS, `signal_fail=0`, `quirk_drift=0` |
| probe timeout guard | `TIMEOUT_S = 60` (7.8 s wall for the whole battery incl. the version call) |

**The stdout sha is the r82 commit's own pinned sha.** The r82 commit message
records "stdout sha 6a98c570 byte-identical"; a fresh run four rounds later
reproduces `6a98c570…` exactly. That is a byte-stability receipt across
r82→r86 on the same Blender build, and it means the fixture's determinism claim
survives a completely different wall-clock/session.

### Class / axis coverage map (83 rows, parsed from the tracked `CASES`)

| arm | rows | layer(s) | what it pins |
|---|---|---|---|
| `transform` | 7 | RNA/DEG | tier-0 written RNA fresh at w0; tier-1 derived RNA (`matrix_world`) stale; held handle stale at w0; fresh get flushes; `dg.update()` flushes the derived edge |
| `hide` | 3 | RNA/DEG | written flag visible on RNA; evaluated flags are the **non-signal** (1 row) |
| `modifier` | 3 | DEG | held handle misses the eval (16 verts), fresh get runs SUBSURF (49) |
| `collink` | 2 | RNA | collection membership is immediate (tier 0) |
| `membership` | 7 | DEG/RNA | `object_instances` is the staleness witness; relink edge |
| `draincheck` | 3 | DEG | **no implicit eval between statements** (no drain) |
| `shared` | 4 | DEG | one shared graph; a fresh get flushes previously-held handles |
| `freshhandle` | 4 | DEG/RNA | consecutive fresh gets consistent; `frame_set` evaluates |
| `vis` | 4 | RNA/DEG | the evaluated-visibility quirk (2 non-signal rows) |
| **`evalcat`** | **41** | EDGE/DEG | the eval-event catalogue + closed-set falsifier |
| `hazard` | 1 | PARSE | parser-hazard contract pin (`dup_flush` physical last-wins) |
| `reorder` | 4 | FD1 | second-Python-runtime fd1 inheritance, per-cell attribution |

Layer census: `EDGE` 35, `DEG` 33, `RNA` 10, `FD1` 4, `PARSE` 1.
`non_signal=True` rows: 4 (`hide_w0_deg_flag_nonsignal`,
`hide_wU_deg_flag_nonsignal`, `vis_hidden_deg_nonsignal`,
`vis_relinked_deg_nonsignal`) — reported as `quirk_drift`, never as a verdict
gate.

**`evalcat` edge-label census (the class vocabulary that already exists):**

| label | rows | meaning |
|---|---|---|
| `edge=0` | 12 | the action *is* an eval event (`bpy.ops`, explicit tagged eval) |
| `edge=1` | 17 | bare write: held stale at write+0, one tagged eval binds it |
| `edge=cond` | 2 | enumerated event is conditional — a clean graph fires nothing |
| `edge=frame` | 1 | inert through tagged evals; binds only at `frame_set` |
| `edge=absent` | 2 | no eval event on this axis at all (wall-time; data-layer purge) |
| `edge=FALSIFIED` | 0 | auto-computed closed-set violation (none this run) |

Census arithmetic: 41 `evalcat` rows = 34 edge-labelled EDGE rows + the
closing `evalcat_closed_set` EDGE row (carries only `violations=0`, no `edge`
key) + 6 `DEG` documentary side cells (freed-ID `ReferenceError`, unlinked-ID
same-object read, mesh `instance_type` enum `TypeError`, …). The run also
computes 6 `order_checks` and 7 `hazard_checks` on raw stdout.

**Line-vs-cell arithmetic (134 ARM lines for 83 pinned cells).** The surplus
lines are deliberate decoys the contract checks read, and they are the reason
the checks exist: the forged `ARM evalcat | closed | EDGE | violations=0
forged=parent_midstream` row, the child's forged `ARM reorder | dup | FD1 |
src=child_inj` row, the live `ARM hazard | dup_flush | PARSE | src=row1
v=first` row that loses to the later forged one, and the `gluevictim` line
whose *absence* as a cell is the splice-drop assertion.

### Which godot-lattice classes exist here, and which do not

| godot class (phys3d_events.gd / r85-r86 scouts) | bpy analog today | verdict |
|---|---|---|
| edge-0 same-turn | 12 `edge=0` rows | **present** |
| edge-1 one-eval | 17 `edge=1` rows | **present** |
| deferred (binds at a later phase) | `evalcat_keyframe_edge_frame` | **present** |
| conditional event | 2 `edge=cond` rows | **present** |
| absent / no event on the axis | 2 `edge=absent` rows | **present** |
| value-collision ⇒ `na` witness | `_ec_held()` returns `na` when a handler fired | **present** |
| non-signal witness | 4 `non_signal` rows | **present** |
| closed-set falsifier | `violations=0` + auto-`FALSIFIED` predicate | **present (stronger than godot's)** |
| parser / partial-output hazard | 7 `hazard_checks` + 1 `hazard` row | **present** |
| second-runtime reorder | 4 `reorder` rows + 4 `order_checks` | **present** |
| **refused** (godot: dss fetch gate, loud stderr ERROR) | **only 1 documentary `DEG` row** (`ext2_instance_refused`, an RNA enum `TypeError`) — **no EDGE row, no dup/flush witness** | **GAP** |
| **write-phase delta** (process=2 / physics=1) | **absent** — bpy has one script phase; the analog is a write *inside* an eval handler | **GAP** |
| **inert / ignored** (godot: `hit_back_faces`, `margin`, `recovery_as_collision`; `custom_integrator` silent under Dummy) | **absent as a pin** — `dund` is emitted on every row for the receipt but `msgbus`/`undo_post` are never pinned as dead surfaces | **GAP** |
| **backend identity gate** (godot: 3-way ClassDB + `{same-signature\|differs-constants\|inverts}`) | **absent** — `blender_version` is *recorded* in the payload, never *asserted* by the verdict | **GAP** |
| **abort / hang class** (godot: coroutine abort ⇒ spin ⇒ 137/-9) | **absent** | **GAP** |
| **stderr gate** (godot `classify()` fails on any non-empty stderr line) | **absent** — the verdict reads stdout only | **GAP** |

The verdict formula is the proof of the last two:
`verdict = PASS iff signal_failed == 0 and launch_ok and done_marker and not
fatals and not order_failed and not hazard_failed` — no version conjunct, no
stderr conjunct (`bpy_battery.py:583-585`).

---

## 3. `bpy_sync_probe.py` — what it is, what it needs, can it run bounded

**What it does.** A 1611-line probe run *inside* blender. It emits
machine-parseable `ARM <name> | <point> | <layer> | k=v …` lines only; the
battery parses them into `(arm, point, layer)` cells and asserts pinned
key=value pairs. Arms: `transform`, `hide`, `modifier`, `collink`,
`membership`, `draincheck`, `shared`, `freshhandle`, `vis` (the r79 two-layer
lattice), `evalcat` (r80–r82: 21 sub-probes + a closure row), `reorder`
(r81 fd1), `hazards` (r82 parser contract). Sample points are `w0` (write+0),
`wU` (post-`view_layer.update`), `wF` (post-`frame_set`), `wD`
(post-`dg.update`), plus per-arm held/fresh handle variants; layers are `RNA`
(original-object attribute), `DEG` (`evaluated_get(dg)`), `EDGE` (catalogue),
`FD1`/`PARSE` (stream contract).

**Runtime it needs.** `blender` on PATH (or `--blender <path>`, default
`/usr/bin/blender` when that exists, else `blender`). It is launched as
`blender -b -P <probe>`; it needs no `bpy` pip module, no display, no GPU. The
battery is the harness and runs under plain `python3`.

**Can it run bounded here — yes.** Measured this round: full battery 7.775 s
wall, probe stderr byte-empty, `PROBE_DONE` present, 134 ARM lines, exit 0.
The probe's own sleeps are inside `arm_evalcat`'s wall-time sub-probe (3.5 s in
the frontier measurement); the tracked fixture is faster than the frontier
probe it was promoted from.

---

## 4. `three/` — 31 cases, runner structure, and what is (not) pinned

**Last advanced: r68** (`3e3f04f`, 2026-10-13 10:37:13 -0300, "measure
Raycaster layer masks"). **Idle for 18 rounds** (r69 → r86) while the Godot
lattice advanced through r69–r85 and bpy moved r79–r82. The Godot battery
deliberately excludes this directory from its seed digests
(`run_battery.py:473-479`, `parts[0] != "three"`), so the two surfaces are
independent by construction.

**Structure.** Six runners + one child per surface; each runner
`spawnSync(process.execPath, [child, ...flags], {timeout: 5000})` and asserts:

1. `proc.error` absent, `proc.status === expectedExit`, `proc.signal === null`;
2. **exact byte equality** of the selected stream with `expectedLine + "\n"`,
   **and the other stream empty** (r61's rule — no `.trim()`);
3. four **seed sha256 digests** (`child.mjs`, `runner.mjs`, `package.json`,
   `package-lock.json`) identical before/after;
4. optional `--receipt <file>` JSON payload, then `console.log` of the
   per-case verdict lines and `process.exit(verdict === 'PASS' ? 0 : 1)`.

**Case census (31 total, all PASS this round, `seeds_unchanged=true` in all
six receipts):**

| runner | cases | names |
|---|---|---|
| `run_cases.mjs` (scene graph) | 3 | positive, negative_wrong_order, mutation |
| `run_camera_cases.mjs` (perspective frustum) | 5 | inside, far_outside, near_outside, mutate_far, mutate_near |
| `run_ortho_cases.mjs` (ortho frustum) | 5 | same five |
| `run_ray_cases.mjs` (raycast) | 5 | hit, lateral_miss, backface, mutate_offset, double_side |
| `run_order_cases.mjs` (order + distance gates + bounds) | 9 | ordered, near_off_axis, near_clip, far_clip, near_boundary, far_boundary, swap_depths, mutate_near_clip, mutate_near_boundary |
| `run_layer_cases.mjs` (layer masks) | 4 | default, far_only, both, mutate_far_layer |

Each battery pairs a **positive** arm (exit 0), a **negative control** that
proves the setup is still live before rejecting (exit 2), and one or more
**mutation** arms (exit 1, diagnostic on stderr) — the same three-verdict shape
as the Godot battery's `expected_exit`/marker discipline.

**Runtime material present and live.** `corpus/fixtures/three/node_modules/`
is installed on this host (`three.module.js` = 662 772 B, mtime 2026-10-14
14:51) and all six runners executed successfully this round. It is **gitignored**
(`corpus/fixtures/three/.gitignore:1:node_modules/`), and the repo's file-search
device honours ignore files: `find_file_by_name "**/three.module.js"` under that
directory returns **"No files found"** while the path exists and imports. A
dispatched probe seat hit exactly this and reported the runtime as "absent" —
recorded and falsified in `corpus/live/bpx-scout/labrat/BLOCKED.md`. **An empty
glob result on a gitignored path is not an absence.**

**Version pinning — split answer.**

| pin | state | evidence |
|---|---|---|
| three.js library | **pinned exactly** | `package.json` `"three": "0.186.1"`; installed `node_modules/three/package.json` = `0.186.1`; `THREE.REVISION` = `186` |
| **node runtime** | **NOT pinned** | no `engines` field in any `package.json`, no `.nvmrc`/`*.node-version` anywhere in the repo; `process.version` is *recorded* in the receipt payload but never asserted (`run_*.mjs:35`, `verdict = seedsUnchanged && rows all PASS`) |
| blender runtime (bpy side) | **NOT pinned** | `blender_version` is recorded in `verdicts.json`; the verdict formula has no version conjunct |

Both sibling batteries therefore *record* runtime identity and *gate* on
nothing — the exact opposite of the Godot fixture's ClassDB backend gate.

---

## 5. Cross-pollination — the phys3d findings and their bpy/three analogs

All rows below are **measured this round**, 2/2 byte-identical where a second
run exists (see `RECEIPTS.md` §7).

### 5.1 Query refusals ⇒ the bpy **ops-context refusal** class (measured, new)

Probe A2, one factory-reset + one bare write + one held handle per row
(handlers re-registered after each reset):

| op | outcome | refusal subclass | dpre/dpost | held after op |
|---|---|---|---|---|
| `screen.frame_jump()` | `{'FINISHED'}` | — | 2/2 | **flushed** |
| `ed.undo()` | **refused** | **poll-refusal**, named reason: `RuntimeError: Operator bpy.ops.ed.undo.poll() Undo disabled at startup in background-mode …` | 1/1 | **flushed** |
| `view3d.camera_to_view_selected()` | **refused** | **execute-refusal**: `RuntimeError: Error: No active camera` + a `Error: No active camera` line on **stderr** | 1/1 | **flushed** |
| `view3d.view_selected()` | **refused** | poll-refusal: `… Expected a view3d region` | 1/1 | **flushed** |
| `screen.area_split()` | `{'CANCELLED'}` — a **third outcome class** | — | 1/1 | **flushed** |
| `object.select_all(DESELECT)` | `{'FINISHED'}` | — | 2/2 | **flushed** |
| `object.transform_apply(location=True)` | `{'FINISHED'}` | — (witness value-collides ⇒ `na`) | 2/2 | `na` |
| `object.mode_set(EDIT)` | `{'FINISHED'}` | — | 2/2 | **flushed** |
| `object.mode_set(OBJECT)` | `{'FINISHED'}` | — | 1/1 | **flushed** |

**Headline: a refused op is still an eval event.** Every refusal fired
`depsgraph_update_pre` **and** `post` at least once and flushed the held
handle — i.e. the eval happens *around* the refusal, and the refusal is not an
eval suppressor. That is a new `edge=0` sub-class the current catalogue does
not name (the existing 12 `edge=0` rows all pin `ret=FINISHED`).

Two structural facts support the analogy with phys3d's "the gate is *which
position you are in*" (r86 §1.2):

- **The background context is partially populated, not empty.** Probe A:
  `C.window` = `Window`, `C.screen` = `Screen`, `C.workspace` = `WorkSpace`,
  `C.scene`/`view_layer`/`collection` real — but `C.area`, `C.region`,
  `C.space_data` = **None**, and `wm_windows = 1`. Ops that need a region
  refuse (`Expected a view3d region`); ops that don't, don't.
- **The refusal channel is stderr, and the bpy battery does not gate stderr.**
  `view3d.camera_to_view_selected()` wrote `Error: No active camera` to stderr
  while the run's verdict is computed from stdout only. Contrast: the Godot
  `classify()` fails on *any* non-empty stderr line (`run_battery.py:511-513`)
  and on `ERROR:` anywhere; the three runners require the non-selected stream
  to be empty. **Strictness ladder measured: godot > three > bpy.**

### 5.2 Write-phase deltas ⇒ the bpy **re-entrant write** (measured, new)

Probe D: a `depsgraph_update_post` handler writes `ob.location` while the eval
that fired it is still running.

```
ARM reentry | pre              | DEG | held_loc=(1.000,0.000,0.000) writes=1 fires=1
ARM reentry | post_one_eval    | DEG | held_loc=(2.000,0.000,0.000) rna_loc=(2.000,0.000,0.000) writes=2 fires=2 trace=1|2
ARM reentry | post_second_eval | DEG | held_loc=(2.000,0.000,0.000) rna_loc=(2.000,0.000,0.000) writes=2 fires=2
ARM reentry | fresh_get        | DEG | loc=(2.000,0.000,0.000)
```

- **No recursion.** One `view_layer.update()` fired the handler exactly once
  (`trace=1|2`, `fires` 1→2 for one eval).
- **The handler's write binds in the same eval** — the held handle read right
  after that eval already shows the handler's value (2,0,0), and the RNA
  agrees. So a write issued *inside* the phase is **edge-0**, while the same
  write issued *outside* is **edge-1** (`evalcat_rna_write_edge1`).
- The second `view_layer.update()` fired nothing (`fires` stayed 2) — the
  **conditional** `edge=cond` row applies to the handler path too.

This is the structural twin of the Godot write-phase discriminant
(`phase_delta` / `srv_phase_delta`: process=2, physics=1) and of the
`_integrate_forces` same-turn write (r86 §5: server write inside the
integrator → same-turn query). Same conclusion, different mechanism: **the
phase the write is issued from decides the edge, not the write's type.**

### 5.3 Backend identity ⇒ bpy/three **runtime-identity gates** (measured, absent)

phys3d has a 3-way ClassDB gate plus a per-arm `{same-signature |
differs-constants | inverts}` map, and r85 §4 found that a *runtime
`ProjectSettings.set_setting` makes the readback lie* (the setting is a
request, never a state). The sibling batteries have the same-shaped identity
surfaces and use none of them as a gate:

| runtime | identity surfaces measured | gated today? |
|---|---|---|
| bpy | `version_string=5.2.1 LTS`, `version_cycle=release`, `build_hash=9e2066aef7ef`, `build_commit_date=2026-08-24`, `build_branch=makepkg (modified)`, `binary_path=/usr/bin/blender`, `background=True` | **no** (recorded in `verdicts.json` only) |
| three | `process.version=v24.21.0`, `THREE.REVISION=186`, package pin `0.186.1`, `typeof document=undefined` | **no** (recorded in the receipt only) |

### 5.4 Silent floor ⇒ three.js **disposal** (measured, new)

Godot's Dummy backend is a "silent floor, not an error surface" (r85 §2.2).
The three.js analog, measured:

```
ARM dispose | geo_disposed        | RAY | hits_before=1 hits_after=1 dist_after=5.000 pos_attr_present=True index_present=True
ARM dispose | mat_disposed        | RAY | hits_after=1
ARM dispose | removed_from_parent | RAY | hits_after=1 parent_is_null=True
ARM refuse  | raycast_after_dispose | RAY | n=1 dist=5.000
```

`geometry.dispose()`, `material.dispose()` and `removeFromParent()` all leave
the CPU Raycaster hitting at distance 5.000, with the attribute arrays intact
— dispose is a GPU-side release with **no CPU-observable effect and no error**.
Exactly the Dummy shape: a class that cannot be detected by value, only by
refusing to classify.

### 5.5 The three.js **two-layer lattice** (measured, new — the biggest find)

```
ARM lattice | w0                     | MW  | held_matrixWorld=(-1.000,0.000,-0.000) rna_position=(0.000,0.000,-5.000)
ARM lattice | w0-fresh               | GET | fresh_getWorldPosition=(-3.000,0.000,-0.000)
ARM lattice | w0-held-after-fresh    | MW  | held_matrixWorld=(-3.000,0.000,-0.000)
ARM lattice | drain-held-1           | MW  | v=(0.000,0.000,0.000)
ARM lattice | drain-held-2           | MW  | v=(0.000,0.000,0.000)
ARM lattice | wU                     | MW  | held_matrixWorld=(-7.000,0.000,-9.000)
```

`Object3D.matrixWorld` is a **held handle**: after `child.position.set(0,0,-5)`
it still reports the pre-write world origin `(-1,0,0)` while `position` already
reads `(0,0,-5)`. `getWorldPosition()` is a **fresh get**: it returns
`(-3,0,0)` and **flushes the previously-held `matrixWorld`** to the same value
(shared-graph flush, identical in shape to bpy's
`shared_held_flushed_by_fresh`). Two unrelated reads in between did **not**
flush (`drain-held-1 == drain-held-2`, no implicit drain), and
`updateMatrixWorld(true)` is the explicit eval event.

**The tracked `scene_graph.mjs` does not measure any of this** — it calls
`parent.updateMatrixWorld(true)` at line 17 *before* reading, so the staleness
window is never opened. This is a third runtime showing the same
write-through / evaluation-gated split the Godot lattice and the bpy lattice
already have, measured in pure Node CPU math with no GL, no renderer, no
pixels — squarely inside the repo's bounded claim.

### 5.6 Inert parameters ⇒ three.js (measured, new) and bpy (absent)

Godot has measured-inert parameters (`hit_back_faces`, `margin`,
`recovery_as_collision`; `custom_integrator` silent under Dummy). three.js:

| row | measurement | class |
|---|---|---|
| `raycaster.params.Points.threshold` | point at lateral offset 0.400: default 1 → **1 hit**; `0.1` → **0 hits**; `0.5` → **1 hit**, `dist=5.000` | **binds** (the discriminating control) |
| `raycaster.params.Mesh.threshold` | lateral miss at the same offset: threshold `100` → **still 0 hits** | **accepted and ignored** |
| `Object3D.matrixAutoUpdate = false` | write `position=(4,0,0)` → `updateMatrixWorld(true)` → still `(0,0,0)`; `getWorldPosition()` (fresh get) → also `(0,0,0)`; manual `updateMatrix()` + eval → `(4,0,0)`; re-enabling the flag → fresh get `(6,0,0)` | **the write→matrix step is inert** |
| `matrixWorldNeedsUpdate = true` alone (with `matrixAutoUpdate=false`) | eval → still `(0,0,0)` | **dirty tag insufficient without the matrix step** |
| `Object3D.layers` inheritance | `parent.layers.set(1)` → `child_mask=1`, `parent_mask=2`; `child.layers.set(2)` → `child_mask=4` | **per-object, NOT hierarchical** (raw masks; see RECEIPTS hazard 5 on the label) |

### 5.7 Abort / hang class ⇒ bpy vs godot, opposite failure modes (measured, new)

Godot r86 §2: a runtime error in the deferred `_run` aborts the coroutine
before `quit()`, the tree spins, and the harness records `rc 137` / `-9` at the
bound. bpy, four modes of probe C, rc captured **without a pipe**:

| mode | rc | stdout | stderr | `PROBE_DONE` |
|---|---|---|---|---|
| `raise` (unhandled exception) | **0** | 119 B (banner only) | **260 B traceback** | absent |
| `arm_then_raise` (one ARM row, then raise) | **0** | 165 B (**the ARM row is present**) | 262 B | absent |
| `quit_early` (`sys.exit(3)`) | **3** | 146 B | 0 B | absent |
| `ok` | **0** | 159 B | 0 B | **present** |

**The blender exit code does not distinguish a clean run from an aborted
script** (both rc 0); the only discriminators are the `PROBE_DONE` marker
(which the tracked battery *does* gate on, `done_marker` conjunct) and a
non-empty stderr (which it does **not** gate on). A partial-output hazard
follows: an abort after some ARM rows leaves those rows in stdout, so
case-level pins still evaluate while the run is aborted — the `done_marker`
conjunct is the only guard, and it is the right one.

### 5.8 The one class bpy already owns that godot does not

The `hazard`/`reorder` block: 7 `hazard_checks` + 4 `order_checks` + 4 `reorder`
CASES rows pin parser-level contracts (physical last-wins, forged `violations=0`
masking, `UnicodeDecodeError` on non-UTF-8 fd1, detached-descendant EOF hold →
`TIMEOUT`, glued-line splice drop) and the second-Python-runtime byte order.
The godot battery's `classify()` is stricter on stderr but has no equivalent
parser-contract block. This is the bpy surface's export back to the godot side,
not the other way round.

---

## 6. Ranked frontier list for g3d r87–r90

Ranked by (discrimination value × cheapness × fit with the existing lattice).
Each row names its falsifier — the measurement that would kill the claim.

| # | round | move | cost | falsifier |
|---|---|---|---|---|
| **R1** | r87 | **bpy refusal class as first-class EDGE rows + a stderr gate.** New `arm_refuse` sub-probe (in `evalcat`, before `closed`) folding the three measured refusal subclasses + the `CANCELLED` outcome, each pinning `dup≥1` + held-flush (`edge=0`) and the exact refusal string prefix; plus port the godot `classify()` stderr rule into `bpy_battery`'s verdict. | ~40 lines probe, ~10 CASES rows, 1 `hazard_check`; +0.3 s runtime | a refused op that does **not** flush the held handle or fire `dup` ⇒ the "refusal is an eval event" claim dies |
| **R2** | r87 | **bpy re-entrant write cell** (write inside `depsgraph_update_post`): pin `fires=1 per eval` (no recursion) and same-eval binding (`edge=0`), with the conditional second-eval row. Pre-measured 2/2. | ~25 lines, 3–4 rows | a re-entrant write that needs its own eval, or a recursive `dup` fire |
| **R3** | r88 | **three.js two-layer lattice battery** — new `transform_lattice.mjs` child + `run_lattice_cases.mjs` runner (held `matrixWorld` stale / `getWorldPosition` fresh + flush / no-drain / explicit `updateMatrixWorld`) using the existing exact-stream + 4-seed-digest discipline. Gives the repo a **third runtime** with the same lattice shape. | one child + one runner, ~5 cases | a fresh get that does *not* flush the held `matrixWorld` ⇒ the shared-graph claim dies |
| **R4** | r88 | **runtime-identity gate on both sibling batteries** (bpy: `version_string`+`build_hash`; three: `process.version`+`three`). Convert a *recorded* field into a *named* gate: a mismatch must emit a named BLOCKED row (godot's `jolt_edge` "honest BLOCKED, no fabrication" pattern), never a silent FAIL. | ~6 lines each | operator call — a hard gate would fail on any other host build; this is the one item that needs an explicit decision |
| **R5** | r89 | **inert-parameter class rows on three** (`Mesh.threshold` ignored vs `Points.threshold` binds; `matrixAutoUpdate=false` makes the eval inert; `matrixWorldNeedsUpdate` alone insufficient; `layers` is per-object, not hierarchical). | 1 child arm, ~5 cases | a `Mesh.threshold` that starts binding (library drift) or a `matrixAutoUpdate=false` eval that *does* publish |
| **R6** | r89 | **disposal silent floor on three** (`geo.dispose`/`mat.dispose`/`removeFromParent` leave the CPU raycast hitting at 5.000). Pairs with R5 as the "no error, no observable effect" class. | 1 case | a dispose that changes the CPU hit count |
| **R7** | r90 | **abort-class parity row in the bpy harness** (inject a raising probe, pin `rc=0` + stderr non-empty + `PROBE_DONE` absent) so the bpy↔godot opposite failure modes (silent rc vs 137 spin) are documented as a contract, not folklore. | 1 harness case | blender starting to propagate a non-zero rc on script abort |
| **R8** | r90 | **bpy `edge=absent` third axis** — the two `edge=absent` rows today are wall-time and a data-layer purge; the `orphans_purge`/`libraries.load`/`batch_remove` family suggests a data-layer axis (no eval, real effect). Lower value; only after R1–R4 land. | ~4 rows | — |

**Do not arm (measured dead surfaces, would be fabrication):** `msgbus`
callbacks (subscription accepted, 0 fires headless), `undo_post` (0 fires,
`ed.undo` poll-refuses), any claim about rendered pixels/GL, and any
`bpy.ops` eval *count* (×1/×2 varies — pin `dup≥1` only, the existing
discipline).

---

## 7. Author directives (exact)

1. **Do not advance `bpy_battery.py` before r87's refusal arm** — the fixture
   is byte-stable (`6a98c570…`) and every prior row is a live pin. Any edit
   must be insertion-only inside `arm_evalcat` before the `closed` row so the
   closed-set falsifier keeps covering the new classes.
2. **Re-register handlers after every `read_factory_settings`.** Probe A's
   `dup_fired=0` across every op row is that bug; the tracked `_ec_register()`
   already does it correctly, so any new sub-probe must call `_ec_reset()` and
   never `read_factory_settings` bare.
3. **A refused op is `edge=0`, not `edge=absent`.** The measured evidence is
   `dpre≥1 ∧ dpost≥1 ∧ held=flushed` for all three refusal subclasses. Pin
   `dup_fired=True` + `held=flushed` + the refusal-string prefix; do **not**
   pin an eval count.
4. **Pin the refusal string as a prefix, not verbatim.** The messages carry
   build-specific tails (`… in background-mode (cal[lback])`) — probe A2's
   output was itself truncated at 80 chars. A `startswith` assertion on
   `Operator bpy.ops.ed.undo.poll()` / `Expected a view3d region` /
   `Error: No active camera` survives a message-tail change; a full-string pin
   does not.
5. **Port the stderr gate as a *separate* verdict conjunct** and expect it to
   fire on the execute-refusal row only (the poll-refusal subclass wrote
   nothing to stderr in either run). Do not make the gate silent-fail; name
   the offending line in the payload.
6. **`bpy.app.build_hash` is bytes (`b'9e2066aef7ef'`), not `str`.** Any
   identity gate must decode first; `version_string` is `str`.
7. **On the three side, add the lattice runner as a *new* runner**, do not
   extend `run_cases.mjs`: the seed-digest list is per-runner
   (`child`, `runner`, `package.json`, `package-lock.json`), and widening an
   existing runner changes its seed set (and therefore its receipts) for a
   claim that has nothing to do with the scene-graph battery.
8. **Never import three via a bare specifier from outside `three/`.** The
   seat probes imported `…/three/node_modules/three/build/three.module.js` by
   absolute path; a tracked child must use the directory-relative import the
   existing children use so `npm ci` lane-local installs keep working.
9. **State the three.js bounded claim verbatim** in any new runner's payload:
   "CPU-side math under Node, no renderer, GL context, pixels or browser" —
   the disposal and refusal rows are boundary documentation, not rendering
   claims.

---

## 8. Confidence, unknowns, hazards

**Confidence — high (measured).** bpy availability and the pip-module absence;
the 83/83 fresh run and its byte-identical stdout sha; the whole class
census; the three.js 31/31 run; the refusal subclasses and their `dup`/flush
witnesses; the re-entrant write; the three.js held-vs-fresh lattice and the
disposal floor; the abort rc table; determinism 2/2 on probes A2/B/D.

**Medium.** The `object_transform_apply` cell is a value-collision (`na`)
rather than a positive flush — the *fixture's* classifier resolves it, my
probe's did not (RECEIPTS hazard 2). The refusal-string tails are truncated at
80 chars in the receipts. `layers` inheritance is stated from raw masks only.

**Unknowns (named, not inferred).**
- Whether a *deeper* refusal taxonomy exists beyond the three subclasses
  (poll-refusal with reason, execute-refusal, `CANCELLED`) — 9 ops sampled of
  a much larger namespace; the class is established, the census is not
  exhaustive.
- Whether the re-entrant write's same-eval binding survives a **nested** eval
  (a handler that itself calls `view_layer.update()`) — recursion depth was
  guarded at 3 writes and never approached.
- Whether the three.js `matrixWorld` staleness is observable through
  `Raycaster` (it reads `matrixWorld` directly — a disposed/stale mesh may
  raycast at its old position); not measured.
- Whether `bpy.app.background` can ever be `False` on this host (no display
  probe run); the refusal classes are scoped to `-b -P`.
- `bpy` version drift: everything is pinned to `5.2.1 LTS / 9e2066aef7ef`;
  nothing here predicts another build.

**Labrat (bounded depth-2 probe, exactly one, read-only).** Dispatched to
independently replicate H1 (refusal is an eval event) and H2 (three.js
held/fresh lattice) with its own probes. Child verdict: **BLOCKED — its tool
surface exposed no exec and no write tool**, so it created nothing and
measured nothing; H1/H2 remain **unreplicated and unrefuted** by a second seat,
and this seat's 2/2 determinism receipts stand alone. Its *secondary* claim
("`node_modules/` is absent … `find_file_by_name` returns 0 hits") is
**falsified**: the file exists at 662 772 B and imported in three separate runs;
the glob returns nothing **because the path is gitignored**. Both the BLOCKED
verdict and the falsified absence claim are receipt-pinned in
`corpus/live/bpx-scout/labrat/BLOCKED.md`.

**Hazards.**
- **The bpy verdict does not gate stderr** — a refusal line, or a traceback
  from an aborted sub-probe, passes the current verdict as long as
  `PROBE_DONE` is present. (An abort removes `PROBE_DONE`, so the battery does
  fail; a *refusal* does not.)
- **A gitignore-blind file search reports live runtimes as absent.** The three
  runtime lives under an ignored `node_modules/`; the search device returns "No
  files found" for it. Any seat that "confirms" a runtime's absence by glob
  will produce a false BLOCKED — verify with `ls`/`git check-ignore`, never with
  an empty glob alone.
- **The three.js battery has no runtime pin** — a node upgrade changes
  `process.version` in the receipt with no verdict effect, and the seed digests
  cover the library and the runners but not the interpreter.
- **The three surface is 18 rounds stale** — its last 12 commits are r58–r68;
  the Godot lattice has moved 17 rounds since. Any cross-engine claim that
  cites "three 31/31" is citing a 2026-10-13 revision.
- **`bpy_battery.py` writes into `corpus/live/runs/` by default** — this seat
  redirected with `--runs corpus/live/bpx-scout/runs` to keep every write
  inside its own scope; an author must do the same or accept the default path.
