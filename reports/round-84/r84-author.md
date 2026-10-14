# game-dev-3d round 84 — author (seat: author, host: devin)

## Declared move (verbatim)

r84 AUTHOR (g3d) — Jolt-pinned backend cells + write-phase deltas.
ARM — `phys3d_events.gd` extension (insertion-only; prior 10 rows +
prior batteries byte-identical):
- `jolt_edge` parent arm: generate a `physics_engine="Jolt Physics"`
  child project (mirror `threaded_edge`'s thrproj pattern -> joltproj),
  re-exec this script `-- --child --arm=jolt_edge`, child prints
  `CHILD_RESULT jolt_<arm>=<outcome>` per reduced arm
  (isect/cast/btm/contact_stale/static_nopair minimum). Parent pins
  the per-arm backend split {same-signature | differs-constants |
  inverts} — `static_nopair` is the known inverter (ov=1 sig=1 under
  Jolt). Jolt availability gate first: absent -> honest `blocked`
  row, never fabricate.
- `phase_delta` arm: a process-phase write followed by the event-tier
  measurement pinning delta=2 (critic C1's correction as a first-class
  cell), contrasted against the physics-phase delta=1 already armed.
- `timeout -s KILL` on the child spawn (F2 fold already landed — keep
  the pattern); child log scan keeps the unexpected-ERROR class check.
Report -> reports/round-84/r84-author.md.

Runtime: `/usr/bin/godot` = `4.7.2.stable.arch_linux.ed1daf0bf`, headless,
60 tps, this host. No subagents, no git mutation. Write scope:
`corpus/fixtures/`, `corpus/live/r84-author/`, this report.

## Landed changes

- `corpus/fixtures/phys3d_events.gd` — 396 insertions / 6 deletions
  (sha256 `255dcab56e5db479aa27e8d0cada0773c8547027cfe7e12464063d3191d536e6`).
  The 6 deletions are doc/dispatch lines only: the header's
  "Jolt live-only" note (:5-9, now states Jolt is pinned in-battery),
  and the `--child` dispatch comment+line (:215-224) which now selects
  `_child_jolt` when `--arm=jolt_edge` is passed. Every pre-existing
  arm's code is byte-identical.
  - `"phase_delta"` arm (:576-649): the same rigid node teleport into
    the same settled `Area3D`, written once from the process phase
    (`await process_frame` continuation, :610-628) and once from the
    physics phase (:630-648). Pins `body_entered` delta=2 vs delta=1.
    The `sig_log.clear()` + `left==0` gate (:634-635) before the
    physics-phase contrast carries the r83 control-independence fold:
    the second `enter` can only be a re-pair, not a stale first entry.
  - `"jolt_edge"` parent arm (:651-721): gate on the
    `physics/3d/physics_engine` property hint containing `"Jolt
    Physics"` (:660-669) → `BLOCKED ... jolt_absent=true` + exit 1 on a
    Jolt-less build (honest non-fabrication); generates
    `res://joltproj/project.godot` (:670-679), re-execs via `/bin/sh -c
    'timeout -s KILL 30 … > child.log 2>&1'` (:686-690, the r83-F2
    pattern), scans the log collecting every `CHILD_RESULT
    jolt_<key>=<val>` into a verdict map and flagging any
    `SCRIPT ERROR`/`Parse Error`/`ERROR:` line (:691-709 — under Jolt
    there is no expected-witness error class, so ANY `ERROR:` is a
    defect), then requires `child_exit==0` and the verdict map to equal
    the pinned six-entry split exactly (:710-720).
  - `_child_jolt()` (:791-1003): runs inside the Jolt project. First
    pins the backend itself — `CHILD_RESULT jolt_backend=Jolt Physics`
    only when `ClassDB.class_exists("JoltPhysicsServer3D") and not
    class_exists("GodotPhysicsServer3D")` (:794-803), so a silent
    fallback to GodotPhysics prints `jolt_backend=unexpected` and fails
    the parent's compare (verified live: see Evidence). Each reduced
    arm then emits `CHILD_NOTE jolt_<arm> <raw fields>` + `CHILD_RESULT
    jolt_<arm>=<class>` where the class is `same-signature` (raw tuple =
    DEFAULT signature), `differs-constants` (edge/structure holds,
    settled constants = the Jolt values measured this round), `inverts`
    (static_nopair only: teleport fires at delta=1 with ov=1), or
    `unexpected` (outside both signatures — fails loudly, named).
- `corpus/fixtures/run_battery.py` — +4/0 rows appended at list end
  (:439-442): `phys3d_events_phase_delta` (exit 0) and
  `phys3d_events_jolt_edge` (exit 0). Prior 186 rows byte-identical
  (`git diff --numstat` = `4 0`).
- `corpus/fixtures/README.md` — +28/0: new "PhysicsServer3D backend
  split + write-phase delta (round 84)" section (:599-625) ahead of the
  determinism rules, which remain the last section.
- Probe + projects + receipts under `corpus/live/r84-author/`
  (`r84_probe.gd`, `proj_jolt/`, `proj_default/`, `runs/`, `batt*.log`,
  `scratch_smoke/`, `scratch_fakechild/`).

## Measured result

### Pre-pinning probe (raw values, 3+ reps, byte-identical)

`corpus/live/r84-author/r84_probe.gd` under `proj_jolt/` and
`proj_default/` (`runs/{jolt,def}_*.stdout.txt`, `.stderr.txt`, `.exit`):

| arm | DEFAULT signature | Jolt signature | split class |
|---|---|---|---|
| isect | `s0=1 m0=0 away=0 n1=0 back=1` | identical | **same-signature** |
| cast | `0.14453125/0.150390625 → w0,n1=[1,1]` | `0.14984130859375/0.1500244140625 → w0,n1=[1,1]` | **differs-constants** |
| btm | `hit=true t=-0.9765625 → miss/-10` | `hit=true t=-0.99853515625 → miss/-10` | **differs-constants** |
| contact_stale | `set 0,1 in 0,1,4 out 4,0` | identical | **same-signature** |
| static_nopair | tp silent ×3 ticks (sig=0 ov=0), control fires delta=1 | tp `n1 sig=1 ov=1` delta=1, control fires delta=1 | **inverts** |
| phase_delta | proc-write `w0=0,0 n1=0,0 n2=1,1` delta=2; phys-write delta=1 | identical deltas | (cell pins DEFAULT) |

Gate: hint `DEFAULT,Jolt Physics,GodotPhysics3D,Dummy` on both projects;
`jolt_class`/`godot_class` swap exactly one member per backend
(`runs/{jolt,def}_gate.stdout.txt`).

### Battery

- Subset: `--only phys3d_events_phase_delta,phys3d_events_jolt_edge` →
  2/2 PASS (`runs/20261014T173843058582Z/verdicts.json`).
- Full: `runs/20261014T173849346559Z/verdicts.json` — **188/188 PASS**
  (142 ordinary + 46 negative), `seeds_unchanged=true`, verdict PASS.
- Full #2: `runs/20261014T174318041429Z/verdicts.json` — **188/188
  PASS**, `seeds_unchanged=true`. Cross-run diff of all 188 rows
  (stdout + exit + verdict): **zero differences**; seed digest maps
  identical.
- New rows' elapsed: `phase_delta` 0.783 s, `jolt_edge` 1.419 s vs the
  20 s case timeout — ~14× headroom on the nested-engine row (the r83
  critic measured the same margin class for `threaded_edge`).

### jolt_edge child receipt (battery run's scratch)

`runs/20261014T173849346559Z/scratch/joltproj/child.log`:

```
CHILD_NOTE jolt_class=true godot_class=false engine=Jolt Physics
CHILD_RESULT jolt_backend=Jolt Physics
CHILD_NOTE jolt_isect s0=1 m0=0 away=0 n1=0 back=1
CHILD_RESULT jolt_isect=same-signature
CHILD_NOTE jolt_cast safe=0.149841 unsafe=0.150024 w0=1.000000,1.000000 n1=1.000000,1.000000
CHILD_RESULT jolt_cast=differs-constants
CHILD_NOTE jolt_btm r0=true t0=-0.998535 r1=false t1=-10.000000 r2=false t2=-10.000000
CHILD_RESULT jolt_btm=differs-constants
CHILD_NOTE jolt_contact_stale set=0,1 in=0,1,4 out=4,0
CHILD_RESULT jolt_contact_stale=same-signature
CHILD_NOTE jolt_static_nopair tp=0,0,1,1,1,1,1,1 delta=1 mv=1,1,1
CHILD_RESULT jolt_static_nopair=inverts
```

No `ERROR:`/`SCRIPT ERROR`/`Parse Error` lines — the zero-expected-class
scan is vacuous-free here because the log's content is fully accounted:
banner + NOTE/RESULT pairs only.

### Negative / impersonation witness

`--child --arm=jolt_edge` run against a DEFAULT project copy
(`scratch_fakechild/child.log`): prints `jolt_backend=unexpected` and
all-`same-signature` — the parent's expected map then mismatches on two
entries (`jolt_backend`, `jolt_static_nopair`), so a silent
GodotPhysics fallback cannot fabricate a PASS.

## Hazards / notes recorded

- **GDScript `:=` cannot infer through Variant indexing** — `var silent
  := tp[0] == 0 …` on an untyped `Array` literal parse-errors
  (`Cannot infer the type … value doesn't have a set type`). Annotated
  `: bool`. Caught by direct arm run before battery.
- **BLOCKED path is compile-gated, not exercisable on this host** —
  the hint always contains `Jolt Physics` here, so the
  `jolt_absent=true` branch (:664-669) is reviewed but unexecuted;
  its failure mode is a named FAIL row (exit 1 + `BLOCKED` stdout
  line), never a fabricated PASS.
- `jolt_edge`'s parent parses `CHILD_RESULT` lines into a map — a child
  printing a *subset* of arms (crash mid-run) mismatches the six-entry
  expectation and fails named; a child printing extras likewise.
- The two new probes (`phase_delta` part (b)) rely on re-pairing after
  pair dissolution: measured live that 6 frames suffice for overlaps to
  reach 0 and the re-enter to fire delta=1 (`runs/def_phase_delta*`).
- `res://joltproj` is created inside the battery's scratch copy —
  seeds are never touched (`seeds_unchanged=true` on both receipts).

## Remaining risks / unprobed

- `static_nopair` inversion under Jolt is pinned as `inverts` with
  delta=1 + ov=1; a Jolt build firing at a *different* latency would
  classify `unexpected` — loud, but would need re-measure to re-pin.
- `jolt_edge` covers five reduced arms; `pp_queries`, `contact_sig`,
  `sync_cb`, `srv_area_cb`, `threaded_edge` under Jolt remain
  live-only/unprobed in-battery (r83 reviewer F1's "silently re-bound"
  class — the assignment's minimum set was extended to nothing beyond
  the five required).
- `Jolt × run_on_separate_thread` still unprobed (cross product,
  carried from r83).
- `phase_delta` pins node-write (`body.position`) deltas; the
  server-write (`body_set_state`) process-phase path was measured by
  the r83 critic (`sphase`/`cphase`, delta=2) but has no battery cell.
- `body_exited` remains unmeasured at node level (r83 reviewer F5).
- All bounds: this host, `4.7.2.stable.arch_linux.ed1daf0bf`,
  headless, 60 tps; Jolt via generated project on the same binary.

Files changed: `corpus/fixtures/phys3d_events.gd` (+396/6: two arms +
`_child_jolt` + doc/dispatch), `corpus/fixtures/run_battery.py` (+4/0),
`corpus/fixtures/README.md` (+28/0), `corpus/live/r84-author/`
(probe/projects/receipts), this report. Prior 186 CASES rows
byte-identical; prior arm code byte-identical. Leaf seat: no subagent
dispatch, no git mutation — all work left uncommitted for the
integrator. Stopping here.
