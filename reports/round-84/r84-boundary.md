# game-dev-3d round 84 — boundary (seat: boundary, host: devin)

Declared lane axis (dispatch brief, verbatim): "r84 BOUNDARY (g3d) — backend
cells' edges + negatives. Read SHARED.md + r84 author brief. Jolt-absent gate,
child-project spawn edges, constants-drift sensitivity, negative controls, kill
classes. Report -> reports/round-84/r84-boundary.md."

Wave `shokunin-train-20261101-w15`, lane g3d. This seat measures the boundary
lattice the r84 ARM implies — it does not implement the arm, fold cells, judge,
edit fixtures, or ship.

Lane root `~/Projects/shokunin/game-dev-3d-shokunin`, HEAD `c4b2fa2`
(r83 report-last). Runtime `/usr/bin/godot` =
`4.7.2.stable.arch_linux.ed1daf0bf` (2026-08-17), `--headless`, 60 tps, 32
cores, load ~0.6. **LSP unavailability recorded:** `mcp_list_servers` exposes
only `rea` (Ghidra binary analysis) — no `lsp` device serves this repo, so every
symbol fact below is engine-measured or text-level (read/grep), never presented
as semantic proof. Every probe arm wrapped `timeout -s KILL` (carried guard).

**Write scope respected:** `corpus/live/r84-boundary/` (gitignored,
`corpus/.gitignore:1`) + this report. No git mutation of any kind; no tracked
file touched by this seat. `git status --porcelain` at report time shows
` M corpus/fixtures/phys3d_events.gd`, ` M corpus/fixtures/run_battery.py`,
` M corpus/fixtures/README.md` — that is the **sibling author seat's in-flight
r84 work** (fixture numstat `+174/−6` at 14:37:25Z; `phase_delta` at `:576` and
`jolt_edge` at `:651` present, `_child_jolt()` not yet defined), not this
seat's. My probe is self-contained: `grep -c` for
`phys3d_events|run_battery|corpus/fixtures` in the probe and runner = **0**,
so nothing below depends on that in-flight tree. It is read below only to aim
the findings at the real implementation.

## (0) Viability, basis, and provenance

| check | command / receipt | exit | measured |
|---|---|---|---|
| lane tree | `git rev-parse HEAD`; `git status --porcelain` | — | `c4b2fa2`; only the author's in-flight fixture edit + untracked `reports/round-84/` |
| probe sha | `sha256sum proj/r84b_edges.gd` | — | `492cb278d0e9b11be12f359d3a7b6cd340a91448cffa5858847cd751ee94369e`, **identical in all 7 project copies** |
| backend arm syntax gate | `runs/v6-proj.backend.*` | 0 | one `BND backend` line, stderr 0 B |
| jolt gate sanity | `runs/v6-proj_jolt.backend.stdout.txt` | 0 | `jolt_class=true` — the class registry flips on this build |

**Revision provenance (recorded because the probe grew during the seat).**
Receipt groups were produced at script revisions v1…v6
(`1d1950e1…`→`c4ae0794…`→`7580fccf…`→`d49fde52…`→`c90b58bb…`→`492cb278…`).
Every banked number below was re-measured under the final revision v6
(`v6-*` receipts), and the unchanged arms are byte-identical across revisions
(`cmp`: `d-isect`, `d-cast`, `d-btm`, `d-contact_stale`, `d-static_nopair`,
`j-isect`, `j-static_nopair`, `x-static_nopair` — **8/8 IDENTICAL**). The one
arm whose *construction* changed is `static_nopair` (§6e, self-falsification).

Probe arms: `backend`, `isect`, `cast`, `cast_unguarded`, `btm`,
`contact_stale`, `static_nopair`, `mkproj`, `flush`, `clock`, `phase2`,
`phase`, plus the `_:` unknown-arm refusal. Projects: `proj` (DEFAULT),
`proj_jolt` (`3d/physics_engine="Jolt Physics"`), `proj_dummy` (`"Dummy"`),
`proj_badstr` (`"Jolt"`), `proj_badcase` (`"jolt physics"`), `proj_empty`
(`""`), `proj_godotps` (`"GodotPhysics3D"`). Runners `run_edges.sh`,
`spawn_edges.sh`, `orphan_probe.sh`; receipts under `runs/` (272 files).

## (1) The Jolt-absent gate: the setting is a request, never a report

`runs/v6-<proj>.backend.*` — the same probe, one `project.godot` line apart,
seven variants:

| `physics/3d/physics_engine` | exit | stderr | `jolt_class` | `godot_class` | `singleton` | `space_rid` |
|---|---|---|---|---|---|---|
| absent (reads back `DEFAULT`) | 0 | **0 B** | false | true | `PhysicsServer3D` | `RID(98784247808)` |
| `"Jolt Physics"` | 0 | **0 B** | **true** | false | `PhysicsServer3D` | `RID(98784247808)` |
| `"Dummy"` | 0 | **0 B** | false | false | **`PhysicsServer3DDummy`** | **`RID(0)`** |
| `"Jolt"` (wrong string) | 0 | **0 B** | false | true | `PhysicsServer3D` | `RID(98784247808)` |
| `"jolt physics"` (wrong case) | 0 | **0 B** | false | true | `PhysicsServer3D` | `RID(98784247808)` |
| `""` (empty) | 0 | **0 B** | false | true | `PhysicsServer3D` | `RID(98784247808)` |
| `"GodotPhysics3D"` | 0 | **0 B** | false | true | `PhysicsServer3D` | `RID(98784247808)` |

1. **Three wrong spellings fall back to GodotPhysics3D silently** — exit 0,
   zero stderr bytes, no warning line. `ProjectSettings.get_setting(
   "physics/3d/physics_engine")` reads back the *requested* string, so a parent
   that trusts its own generated setting line banks a Jolt cell measured on
   GodotPhysics. The only honest gate is a read **inside the child**:
   `ClassDB.class_exists("JoltPhysicsServer3D")` flips exactly with the
   effective backend (true only on the Jolt run, 7/7 variants), and
   `PhysicsServer3D.get_class()` names the third state (`PhysicsServer3DDummy`).
2. An unset key reads back `"DEFAULT"`, never a sentinel — so "key absent" is
   not observable from the setting either; the class registry is the sole
   discriminator.
3. **The build-level hint is not a selection gate.** The property hint string
   is `DEFAULT,Jolt Physics,GodotPhysics3D,Dummy` in **all seven** variants
   (`grep -ho 'hint=\[[^]]*\]' runs/backend-*.stdout.txt | sort | uniq -c` →
   `7 hint=[…]`). It proves "Jolt is compiled in", never "this run is on Jolt".
   The in-flight `jolt_edge` arm's `jolt_avail` loop (`phys3d_events.gd:660-668`)
   tests exactly this hint, so it is true on every variant including Dummy and
   the typo projects: it can never detect a mis-selected child. The child-side
   `jolt_backend` field (`:711`) is the load-bearing one, and its *value* must
   come from the class registry, not from the setting string.
4. The `blocked` branch is reachable and named: any project without a valid
   Jolt selection gives `jolt_class=false`; Dummy additionally gives
   `space_rid=RID(0)`. Nothing in this ladder needs a fabricated absence.

## (2) Per-arm backend split and constants-drift sensitivity

Reduced arms, DEFAULT vs Jolt vs Dummy, final revision
(`runs/v6-proj.<arm>.*`, `runs/v6-proj_jolt.<arm>.*`, `runs/v6-proj_dummy.<arm>.*`):

| arm | DEFAULT (GodotPhysics3D) | Jolt | split |
|---|---|---|---|
| `isect` | `settled=1 mask2=0 away_w0=0 away_n1=0 back_w0=1` | identical | **same-signature** |
| `cast` | `safe=0.144531250 unsafe=0.150390625`; `w0/n1` both `1.0/1.0` | `safe=0.149841309 unsafe=0.150024414`; `w0/n1` identical | **differs-constants** |
| `btm` | `hit=1 travel=-0.976562500`; `w0/n1 hit=0 travel=-10.0` | `hit=1 travel=-0.998535156`; `w0/n1` identical | **differs-constants** |
| `contact_stale` | `0/1/4/4/0` | identical | **same-signature** |
| `static_nopair` | `tp_fired=false tp_ov=0`, control `mv_fired=true mv_delta=1` | `tp_fired=true tp_ov=1`, control `mv_fired=true mv_delta=1` | **inverts** |

The per-arm expectation map in the in-flight arm (`phys3d_events.gd:710-717`)
matches these independent measurements exactly.

**The classifier's tolerance is the whole risk.** Per-field deltas (derived
arithmetic on the measured values, not a separate measurement):
`Δcast.safe = 5.310e-3`, `Δcast.unsafe = 3.662e-4`, `Δbtm.travel = 2.197e-2`;
all *edge* fields (`away_w0/away_n1/back_w0`, `w0/n1` fractions, contact counts,
`hit`) are exactly 0. Tolerance ladder:

| tolerance | classification outcome |
|---|---|
| `0` (exact, at the printed `%.9f` precision) | clean 3-valued split: same ×2, differs ×2, inverts ×1 |
| `1e-4` | unchanged (`Δcast.unsafe = 3.66e-4 > 1e-4`) |
| `1e-3` | **`cast`'s two fields straddle**: `Δunsafe = 3.66e-4 < 1e-3` while `Δsafe = 5.31e-3 > 1e-3` — a classifier comparing one field (the natural choice: the "far/unsafe" fraction) reads `same-signature` for a real constant difference; comparing every field still reads `differs` |
| `1e-2` | `cast` folds to `same-signature` on both fields — a false same on a 3.7 %-relative difference |
| `5e-2` | `btm` folds too; the constants axis collapses and only the inverter remains distinguishable |

Bounded recommendation for the child-side classifier: **compare the edge fields
at exact equality (they are exactly equal across backends) and treat any
nonzero constant-field delta as `differs-constants`** — i.e. use `tol = 0` on
the full-precision print and keep the per-field deltas as data. Any tolerance
≥ `1e-3` needs a per-field decision table; ≥ `1e-2` silently folds
`differs-constants` into `same-signature`. (Derivation from measured values;
the ladder itself was not run as a separate experiment.)

## (3) The Dummy floor is a third state, not an inversion

`runs/v6-proj_dummy.*` — every arm reads the floor because nothing is
simulated: `isect 0/0/0/0/0`; `cast` **size 0** at all three samples;
`btm hit=0 travel=0`; `contact_stale setup_isect=0` and all contacts 0;
`static_nopair tp_fired=false mv_fired=false srv_z=-999.0` (the server
`body_get_state` returned null) `isect_A=0`.

- A classifier comparing Dummy against DEFAULT labels **all five** arms
  "differs" — a same-infra wall, i.e. the carried guard's vacuous invariance
  ("a verdict group of ONE identical-errored signature"). The honest label is
  `unavailable`, keyed on `space_rid == RID(0)` / `singleton ==
  PhysicsServer3DDummy` (§1), never `inverts`.
- Consumer hazard, measured: `cast_motion()` returns a **size-0
  `PackedFloat32Array`** on this backend, and the unguarded `c[0]` read raises
  `SCRIPT ERROR: Out of bounds get index '0' (on base: 'PackedFloat32Array')`
  (`runs/x-cast_unguarded.stderr.txt`), the arm aborts before `quit()`, the tree
  spins, and the harness bound ends it → **exit 137**. That is the r83 §5(a)
  abort-without-quit class with a second, cheaper trigger: a *backend* can turn
  an unguarded array read into a kill-class "hang". Any arm indexing
  `cast_motion()[0..1]` needs the size guard.

## (4) Child-project spawn edges

Generation (`runs/d-mkproj.stdout.txt`, stderr 296 B):
`make_dir_recursive_absolute` → fresh `0` (OK), repeat `0` (idempotent),
**file-in-the-way `0` (OK!)** — a *file* occupying the target path is not an
error at this call — under-a-file `20` (`ERR_CANT_CREATE`) with a loud
`ERROR: Could not create directory: … (core/io/dir_access.cpp:179)`. The silent
file-in-the-way state surfaces one step later only: `FileAccess.open(
dir/project.godot, WRITE)` returns **null** (also null when the parent dir is
missing, and when the path is a directory). The in-flight arm keeps both
checks (`:671-677`), which is the shape that survives this edge; the `mk != OK`
branch alone would not fire.

Spawn/exit classes, parent-side view (`/bin/sh -c '<cmd> > log 2>&1'`,
`runs/spawn-census.txt`):

| cell | exit | log the parent would scan |
|---|---|---|
| healthy child (prints verdict) | 0 | 130 B, verdict present |
| quiet child (exits 0, no verdict) | 0 | 101 B, **0** verdict lines → the verdict check must carry the case |
| `OS.crash()` child | **134** | 1758 B, crash banner |
| hung child + inner `timeout -s KILL 3` | **137** | child's last print retained |
| missing project path | **1** | `Invalid project path specified: "…", aborting.` |
| valid project, missing script | **1** | banner + `ERROR: Attempt to open script 'res://no_such_script.gd' … 'File not found'.` |
| missing binary | **127** | `/bin/sh: line 1: … No such file or directory` |
| unknown arm (probe `_:` branch) | **1** | `ERROR: r84b_edges: unknown arm nosucharm` — named loud refusal |

- **Exit-code provenance.** The shell returns the **last** command's status:
  `'<child>; true'` → **0** (the child's failure masked); `'true; <child>'` → 1
  (propagates). The fixture's single-command `cmd` string is safe today; any
  appended shell verb would silently disable the parent's `code != 0` gate.
- **Stale-log hazard, measured.** With the log file unwritable (`chmod 400`),
  the redirect fails, the shell exits **1**, and the pre-seeded
  `CHILD_RESULT jolt_isect=same` line **survives verbatim** (29 B,
  `runs/spawn-census.txt` cell I2): a parent that scans the log *without* the
  exit code reads a verdict from a child that never ran. The landed pattern's
  `code != 0` conjunct (`phys3d_events.gd:718`) catches exactly this cell — the
  carried "rc alone is never a verdict" guard now has its dual: **the log alone
  is never a verdict either.** Control (writable log + missing binary): the
  redirect truncates, 64 B of shell error, no stale read. Variant: a log path
  that is a *directory* leaks the shell's error to the **parent's stderr**
  (`Is a directory`) — which the battery classifier fails on, so a
  filesystem-state fault surfaces as a case failure rather than a silent pass.
- **Cost.** The reduced 5-arm Jolt set as 5 sequential child processes =
  **3.54 s wall** (~0.7 s/arm); the r83 threaded child was ~1.5 s and the case
  budget ~20 s, so a per-arm-spawn Jolt child has ~5.6× headroom (more if the
  arms share one child process).
- **Jolt stderr is clean:** 27/27 Jolt receipts (both revisions incl. `v6-*`),
  **0 total stderr bytes**, and
  the in-flight arm's strict `ERROR:` scan (no whitelist, `:703-706`) is
  therefore safe on this build — Jolt itself emits nothing for these arms.

## (5) Kill classes and the orphan class

| class | exit | witness |
|---|---|---|
| clean | 0 | healthy child |
| named script failure | 1 | `push_error`+`quit(1)`; missing project; missing script; unwritable log redirect; unknown arm |
| negative rejection | 2 | fixture's `static_nopair` path (prior rounds) |
| crash (abort/segv class) | **134** | `OS.crash()` child; r83's Jolt free-order cells |
| harness kill (SIGKILL) | **137** | `timeout -s KILL`; **also** the abort-without-quit spin (Dummy `cast_unguarded`) |
| TERM timeout | **124** | `timeout 3` without `-s KILL` — the child did die on TERM here, but the class differs from the KILL bound; SHARED.md's `-s KILL` stays the carried bound |
| shell-level launch failure | **127** | missing binary |

**Orphan class confirmed** (`runs/orphan-census.txt`, PID-based): with the
fixture's spawn shape and *no* inner timeout, `kill -9` of the `/bin/sh` parent
leaves the godot child alive and reparented — `pid 2628270 ppid 1203171 state
Sl etime 00:03`. The battery's `subprocess` timeout kills only the direct child,
so the r83 reviewer F2 fold (inner `timeout -s KILL 30`) is load-bearing, not
hygiene. Counter-cell: when the kill is issued to the whole process group (an
outer `timeout` whose group signal caught the child) the child dies with the
parent — the orphan class is a function of *how* the parent is killed, and the
battery path is the PID-directed one.

Census hazard recorded: `pgrep -f <script>` matches the **harness's own**
command line (`pkill -f 'hang.gd'` killed my own shell wrapper → exit −1) and
can match a *foreign* lane's leftovers — a `godot … corpus/live/r75-baseline/…`
process was observed alive ~3.5 h on this host during the census (not this
lane's, not touched). Any process census must be PID-scoped, never
pattern-scoped.

## (6) Negative controls for the r84 pins

### (a) `phase_delta`: the paired control, both tiers, one receipt

`runs/v6-{proj,proj_jolt}.phase.*` — one run, both phases, both tiers,
DEFAULT and Jolt byte-identical in every physics field:

| cell | write phase | query tier `w0/n1/n2` | event tier `w0/n1/n2` | event delta |
|---|---|---|---|---|
| M1 | physics-frame continuation | **1 / 1 / 1** (edge-0) | 0 / 8 / 8 | **+1 sample** |
| M2 | process frame | **1 / 1 / 1** (edge-0) | 0 / 0 / 4 | **+2 samples** |

Absolute timeline (`runs/v6-<proj>.flush-{phys,proc}.*`): physics write at
`pf=6` → contacts at `pf 6,7,8,9` = `0,4,4,4`; process write at `pf=5` →
`0,0,4,4`; the query tier reads `1` at **every** sample in both. Identical
under Jolt; `flush --phase=phys` and `flush --phase=proc` are each 3/3
byte-identical.

**The sharpest form of the r84 pin:** the event tier is +1 from a physics-phase
write and +2 from a process-phase write, while **the query tier stays edge-0 in
both phases** — the phase rule is event-tier-only. Per-phase, per-write-path
confirmation (`runs/v6-<proj>.p2-<kind>-<phase>.*`): node-position writes and
server `body_set_state` writes give the *same* split (phys 1 / proc 2, 8/8),
so the r83 critic's §5 write-path confound does **not** reach this cell: the
node path is a legitimate vehicle for the `phase_delta` pin.

### (b) Falsifier found: a bare `delta == 2` frame-counter pin is construction-dependent

In the same-run arm, the process-frame **node** write (cell B) measured
`delta_pf = 1` (`wf=6 of=16 sig=7`), 3/3 reps byte-identical, while the
one-write-per-process arm measured `delta_pf = 2` (`wf=5 of=13 sig=7`), 8/8.
Same build, same script, same backend, same nominal phase — the frame-counter
delta for a process-phase write is **1 or 2 depending on where the write lands
in the main loop**. So the sample-index pattern (`w0=false, n1=false,
n2=true` for the process phase; `w0=false, n1=true` for the physics phase) is
the robust pin, and the counter arithmetic is at best a reported field.

Applied to the in-flight arm (`phys3d_events.gd:576-649`): its conjuncts
`w0_fired/n1_fired/n2_fired` + `w0_ov/n1_ov/n2_ov` (and the mirror on the
physics-phase contrast) are exactly the robust form and are independently
supported by §6a; the conjuncts `proc_delta != 2` (`:624`) and
`phys_delta != 1` (`:645`) are the fragile ones — my same-run cell would fail
the former while every sample-index conjunct passes. Its `await process_frame`
write after `_frames(SETTLE)` is the same shape as my one-write-per-process
cell (which measures 2), so the arm should pass as drafted on this build; the
finding is that the counter conjunct adds no discriminating power over the
sample-index conjuncts and is the one that can flip.

### (c) Decoy / indexing control

`runs/v6-<proj>.phase.*` cell C: a decoy body entering the same area one
physics frame before the treated write makes `log[0]` read the *decoy's* frame
(`first_sig=7`, `first_delta_pf=0`) while the treated event is `last_sig=9`
(`keyed_delta_pf=2`). A pin that reads the first log entry after the treated
write reports the decoy's frame — the r83 critic-C2 bug class, demonstrated on
the r84 cell shape. The treated event must be keyed (by body RID) or the log
cleared immediately before the treated write. The in-flight arm clears
`sig_log` before its physics-phase contrast (`:635`), which is sufficient for
its single-body construction.

### (d) `static_nopair` control independence, verified on the *firing* backend

With the log cleared before the area move, the control reads `mv_delta=1` on
**Jolt too**, where the treated cell fires (`tp_fired=true tp_ov=1`,
`pre_clear=1`) — the r83 fold holds on the failing path, not only on the silent
one. Non-vacuity witnesses carried in the same line: the static body's server
transform is at the overlap (`srv_z=0.0000`) and a geometric query finds it
(`isect_A=1`) on both real backends.

### (e) Self-falsification: a probe confound caught before banking

The first draft of the `static_nopair` arm reused a helper that left a
`RigidBody3D` at the far position the area moves onto. The control then fired
on **every** backend (`pre_clear=1`, `mv_fired=true` on DEFAULT) — i.e. the
control's firing was attributable to that stray rigid body, not to the static
body under test, making it **vacuous**. The arm now builds the area alone
(`pre_clear=0` DEFAULT / `1` Jolt) and the control is attributable. Recorded
because the first reading would have banked a vacuous control as a witness.

### (f) Dummy-column vacuity

§3: the floor must not be read as an inversion; a Dummy-vs-DEFAULT group is a
same-infra wall.

## (7) Determinism / byte-stability

- `flush --phase=phys` 3/3 byte-identical; `flush --phase=proc` 3/3
  byte-identical; the combined `phase` arm 3/3 byte-identical on DEFAULT.
- **`Engine.get_physics_frames()` is byte-stable across runs;
  `Engine.get_process_frames()` is not.** The same logical point read `of=17`
  in one revision's reps and `of=16` (and `13` vs `14` in the flush cells) in
  another, on both backends, while `wf`/`sig` stayed fixed. **No landed pin may
  carry a process-frame counter**; delta pins must use physics frames and the
  sample index. (`clock` arm, `runs/d-clock.stdout.txt`: the physics counter is
  identical at the `physics_frame` and the following `process_frame`
  continuations — `pf=2 of=5`, `pf=2 of=5`, `pf=3 of=9`, … — while the process
  counter advances ~4 per physics frame in headless.)
- All DEFAULT receipts are stderr-clean except the deliberate cells
  (unknown-arm 191 B, `mkproj` 296 B, Dummy `cast_unguarded`); all Jolt
  receipts are 0 B (§4).
- Exit conventions inside this scratch are uniform (one writer, bare integer
  `.exit` files) — the r83-scribe cross-harness convention hazard does not
  recur here.

## (8) Deltas vs prior rounds

1. **The Jolt gate ladder is new**: the setting string is not validated
   (three wrong spellings → silent GodotPhysics fallback, exit 0, 0 B stderr),
   and the build hint string is invariant across selections. The gate must be a
   class-registry read inside the child.
2. **A tolerance ladder for the `{same|differs-constants|inverts}` pin is new**,
   with the `cast` field straddle at `1e-3` and the fold to a false `same` at
   `1e-2`.
3. **The Dummy floor is characterized as a third state** (r83 named the floor
   for the count/query side; this seat adds the `space_rid=RID(0)` /
   `PhysicsServer3DDummy` key and the size-0 `cast_motion` consumer hazard →
   exit 137).
4. **The phase rule is narrowed to the event tier** and its paired control
   measured in one receipt: the query tier stays edge-0 from the process phase
   too (r83 critic C1 stated the event-tier latency only).
5. **The process-phase delta is construction-dependent** (1 or 2) — a
   falsifier for any bare `delta == 2` frame-arithmetic pin.
6. **Spawn-edge and kill-class census is new** for this fixture family:
   generation error codes (file-in-the-way returns OK), exit classes
   {0,1,2,127,134,137,124}, exit-code masking by a trailing shell verb, the
   stale-log fabrication hazard, and the orphan class confirmed by PID.

## (9) Remaining unknowns

- The **mechanism** behind the 1-vs-2 loop-position dependence is unresolved;
  the counters are measured, not explained. The critic's
  `sync()→flush_queries()→physics_process()→end_sync()→step()` attribution is
  inference that my data neither confirms nor refutes. What is measured: the
  counter at each await point, the per-frame sample timeline, and the
  construction dependence.
- The in-flight arm's dissolve window for its physics-phase contrast
  (`body.position = WALL_FAR; await _frames(6)`, `:632-633`) is not
  independently measured here; the arm asserts the dissolve (`left != 0`), so a
  shortfall fails named rather than silently re-pairing.
- `static_nopair` on Dummy is vacuously silent (no simulation) — the negative
  is meaningless there, not falsified.
- Only body/space-level cells were exercised; area/soft-body RIDs and the Jolt
  × `run_on_separate_thread` cross product remain unprobed (the r83 list
  stands). The r83 Jolt free-order crash matrix was not re-exercised — all 14
  Jolt arms here exited 0 with 0 B stderr.
- `_child_jolt()` was undefined in the author's in-flight tree at the time of
  this report, so the child-side classification implementation could not be
  read; findings are aimed at the parent's gate/scan/expect-map and at the
  classifier's tolerance requirement.
- No cross-build or cross-version claim: every value is bounded to Godot
  `4.7.2.stable.arch_linux.ed1daf0bf` and this host.

## (10) Artifacts

- Report: `reports/round-84/r84-boundary.md` (this file).
- Scratch root `corpus/live/r84-boundary/` (gitignored): probe
  `proj/r84b_edges.gd` sha256 `492cb278d0e9b11be12f359d3a7b6cd340a91448cffa5858847cd751ee94369e`
  (identical in all 7 project copies); 7 `project.godot` variants; runners
  `run_edges.sh`, `spawn_edges.sh`, `orphan_probe.sh`; children
  `child_probes/{hang,quiet,crash,verdict}.gd`; receipts `runs/` (272 files,
  `v6-*` = final revision); censuses `runs/spawn-census.txt`,
  `runs/orphan-census.txt`.
- `manifest-r84b.sha256` — 140 lines, sha256 `da5fa346499d833ce08d3286fe2803befff000390eb1beef0a39f8098c89068b`
  (probe + all project copies + runners + children + project variants +
  censuses + every `v6-*` receipt + the deliberate hazard/refusal cells).

## Scope guards carried (from SHARED.md)

- reorder topology = fd1-OWNER's buffering mode — untouched (no bpy runs this
  seat).
- fifo-adjacent cells: `timeout -s KILL` is the kill bound — applied to every
  arm; receipt completeness is the verdict carrier (§4 stale-log cell is the
  counterexample that justifies it).
- `alive_after_term1` = ONE-TERM survival only — not exercised here; the
  TERM-class cell (§5) records the *exit class* (124), not signal immunity.
- A verdict group of one identical-errored signature is vacuous — applied to the
  Dummy column (§3f).
- GodotPhysics claims are backend-scoped: this seat re-measured the inverter on
  both backends rather than inheriting the scope (§2, §6d).
- Wire order + write order + exit are all three needed as witnesses: the
  stale-log cell is invisible in the child's stream and visible only in the exit
  code; the abort-without-quit cell is visible only in stderr + exit class.
- **rc alone is never a verdict** — and its dual, demonstrated here: the log
  alone is never a verdict either (§4).

Report only; I do not judge, admit, edit fixtures, commit, or ship. Stopping
here.
