# game-dev-3d round 88 — author (seat: author, host: devin) — the query-tier read family + body inertia getters

Round 88. Wave `shokunin-train-20261101-w20`, lane g3d. Assignment
(`.ufo/waves/shokunin-train-20261101-w20/tasks/g3d-r88-author.md`, verbatim):

> Arm the r88 scout's measured lattice: reports/round-88/r88-scout.md +
> receipts corpus/live/r88-scout/ … Fixture convention: extend
> corpus/fixtures/phys3d_events.gd with new arms OR add a sibling fixture —
> keep CASES appends insertion-only at the tail of run_battery.py (the crash
> row must remain last-or-later-than-it; crash-class rows go at the tail).
> [nine arm cells …] Run the full battery TWICE post-landing (use absolute
> --runs paths …); prior 201 rows must stay byte-identical on semantic
> fields (verify against corpus/live/r88-baseline/freeze/ tuples — 201
> rows). Report → reports/round-88/r88-author.md. Do NOT touch
> reports/round-87. Do NOT commit.

Runtime `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`,
60 tps, 32 cores. Base HEAD `db64943` (`r87 report-last`). Work tree at
submission: **three tracked files modified, nothing committed, nothing
pushed** (the host commits after verifying). Scratch under
`corpus/live/r88-author/` (`corpus/.gitignore`).

**Evidence**: `corpus/live/r88-author/` — 3 full battery receipts + 1
focused smoke receipt, the two post-landing child-log trees (inside each
receipt's `scratch/`), the bpy and six three.js sibling receipts, and the
teardown-order probe (`scratch/orderprobe.gd`). All of it is gitignored, as
the scout's receipts are; the landed evidence is the fixture, the rows and
the markers.

**LSP unavailability recorded** (same as the r85–r88 sibling lanes): no
`lsp` device is exposed in this seat's toolset, so no symbol-aware
rename/reference operation was available. None was needed — the change is
insertion into one fixture plus a CASES-tail append, and every new symbol is
defined in the file that uses it. **No `labrat` probe dispatched**: the
probeParent allowance was unused; the one new empirical question (the Jolt
teardown-order abort) was answered directly with a 4-mode scratch probe.

---

## 0. What landed

`corpus/fixtures/phys3d_events.gd` (+2024/−8) — nine new parent arms and
their child bodies, appended at the tail, plus three additive helper
changes (§7):

| arm | children | pinned class |
|---|---|---|
| `motion_split` | `mo_plain`, `mo_jolt`, `mo_dummy` | the motion semantic split + the per-backend bracket |
| `fetch_gate` | `fg_plain`, `fg_thr`, `fg_jolt_thr`, `fg_dummy`, `fg_dummy_thr` | the access-gate lattice + the held-handle bypass |
| `inactive_space` | `ia_plain`, `ia_thr`, `ia_jolt_thr` | the never-activated private space |
| `param_purity` | `pq_plain`, `pq_jolt`, `pq_dummy` | params purity, `shape_rid` precedence, fresh containers |
| `body_inertia` | `bi_plain`, `bi_jolt`, `bi_dummy` | the inertia getters as values + the static/kinematic split |
| `wrong_args` | `wa_plain`, `wa_jolt`, `wa_dummy` | the wrong-argument class (typed empties, identical text) |
| `geom_split` | `gs_plain`, `gs_jolt` | the backend-geometry splits as envelopes |
| `race_class` | `rc_plain`, `rc_jolt` | the threaded window as named classes + envelope pin |
| `freed_space_methods` | 13 children, one parallel batch | the freed-space postcondition per method × backend (fatal tail) |

`corpus/fixtures/run_battery.py` (+29/−0 **by this seat**) — nine rows
appended at the tail (201 → 210), the two child-crash rows last and the
freed-space matrix last of all. `git diff` for this seat's edit is
insertion-only. (The working tree also carries another lane's 5-line
harness edit — the `--runs` docstring and `run_dir = args.runs.resolve()`
— which predates this seat's edit and is **not** this seat's diff; it was
already present in all three of this seat's battery receipts, digest
`5047742930…`.)

`corpus/fixtures/README.md` (+133/−0) — one new section documenting the
nine arms; the `## Determinism rules for new cases` heading is intact.

## 1. `motion_split` — the semantic split, and the bracket envelope

ONE `PhysicsShapeQueryParameters3D` per geometry, reused across the four
methods that accept it. Measured (child notes, run 3):

| token | GodotPhysics | Jolt | Dummy |
|---|---|---|---|
| clear-start -5z cast | `0.0977,0.1035` (`wide`) | `0.0999,0.1002` (`tight`) | empty |
| penetrating-floor start cast | `0.0977,0.1035` (`same`) | `0.0999,0.1002` (`same`) | empty |
| the SHARED -2z sweep object, cast | `0.2500,0.2539` | `0.2485,0.2500` | empty |
| same object, `collide_shape` | `0` (in-place control `2`) | `0` (`2`) | `0/0` |
| same object, `get_rest_info` | `0` keys (control `6`) | `0` (`6`) | `0/0` |
| same object, `intersect_shape` | `0` (control `1`) | `0` (`1`) | `0/0` |
| away / zero / short | `miss` / `blocked` / `blocked` | same | empty |

So within one params object `motion` is honored by exactly ONE of the four
methods, and a start overlap does NOT pin the cast to 0. The bracket is a
**per-backend envelope** — the row never claims a cross-backend equality.

**One scout framing corrected.** The r88 scout's "moving AWAY reports
`~0.598`" (`cm_away=0.5977,0.6016`) is not an overlap-exit semantics: the
scout's probe had an extra dynamic body (`dyn` at `(0,0.5,3)`) sitting in
that sweep, and the sphere reaches it at `(2.0−(−1))/5 = 0.6`. In this
arm's two-body geometry the away cast is a clean miss (`[1,1]`), pinned as
`cm_away=miss`; the `~0.6` reading is not reproduced and not claimed. The
scout's "same fraction for a penetrating start" IS reproduced
(`cm_pen=same`, both fractions within 0.01).

## 2. `fetch_gate` — the gate lattice and the bypass

Three acquisition paths per sample (server space fetch, `World3D`
property, body state). Sample map (`f,w,b` = path granted):

```
fg_plain      A:111 B:111 C:111 D:111 E:111 F:111 F:111 F:111   gate=open  grant=8 refuse=0
fg_thr        A:000 B:000 C:000 D:111 E:111 F:000 F:000 F:000   gate=phase grant=2 refuse=6
fg_jolt_thr   A:000 B:000 C:000 D:111 E:111 F:000 F:000 F:000   gate=phase grant=2 refuse=6
fg_dummy      A:111 B:111 C:111 D:111 E:111 F:111 F:111 F:111   gate=open  grant=8 refuse=0
fg_dummy_thr  (identical to fg_dummy)
```

Positions: A = inside `_initialize` (before the first step), B = deferred
start, C = a process frame, D = the `physics_frame` continuation, E =
`_physics_process`, F ×3 = `_process` firings. Under
`run_on_separate_thread=true` **every** out-of-phase position refuses all
three paths — including `_initialize` — and only the two in-phase positions
grant; non-threaded backends and Dummy grant everywhere.

Log conjuncts (raw child logs, `_log_count`): the threaded children carry
exactly `2 × refuse = 12` `Space state is inaccessible` lines and
`1 × refuse = 6` `Body state is inaccessible` lines; the non-threaded and
Dummy children carry 0. A silently-nil fetch (a null without an engine
line) can therefore never pass as a refusal.

**Bypass**: a body state held from D hands out the SAME dss object at
refused positions (`byp_same=5/5` on every child) and a query through it
answers (`byp=5/5`). One Jolt+thread nuance is admitted but never
count-pinned: that query can print `ERROR: intersect_point must not be
called while the physics space is being stepped` and still answer (observed
once in 5 samples).

## 3. `inactive_space` — the gate keys on the step cycle

`space_create` + `space_set_active(false)` + a wall body in it:

```
ia_plain     open=5 refused=0   alts=2/2 f_bp=1/1  sig=pt1,is1,ray7,cs0,cmfrac,ri0,rv6
ia_thr       open=2 refused=3   alts=2/2 f_bp=1/1  sig=…  (3 engine refusal lines)
ia_jolt_thr  open=2 refused=3   alts=2/2 f_bp=1/1  sig=…  (3 engine refusal lines)
```

So on non-threaded backends the fetch of a never-activated space succeeds
at **every** sampled position — the gate is the step cycle, not activation —
while the threaded gate refuses it out of phase. A handle stashed at a legal
position answers everywhere with one signature; `cs/ri` zeros are geometric
(the private space carries only the wall; `rv=6` is the in-place wall
overlap). The out-of-phase F firing is deliberately **broadphase-only**: the
full battery there tore the Jolt shape registry and aborted the child at
rc 134 (measured, and the same class as the scout's `gt_proj_jolt_thr.r1`);
that tear/crash class is pinned by `race_class` instead. The in-phase
shape-channel battery (D, E) is unaffected.

## 4. `race_class` — named non-deterministic classes, envelope-pinned

Each child measures the legal channel values at an in-phase control and then
requires every out-of-phase sample to report each count channel either
empty/zero or exactly the legal value, and the cast channel either empty or
a mid-sweep fraction in `(0,1)`. **No class is required to appear** — this
is an envelope, never a distribution.

Run 3 (the two post-landing runs differ here by design; both passed):

```
rc_plain  legal={pt:1, ray:7, is:1, cs:2, cm:frac, ri:6}
          classes=["all","all","all","all"]           envelope=ok refused=4
rc_jolt   legal={… same …}
          classes=["is+cs+cm","is+cs+ri+cm","cs+cm","is+cs+ri+cm"]
          envelope=ok refused=4, tear lines=13, no crash
```

The Jolt child's window also tears the Jolt shape registry
(`Failed to build Jolt Physics sphere shape…`, `Parameter "jolt_shape" is
null.`) and can abort the process. The row accepts the **crash envelope**
(rc ∈ {134,137}, tear line ≥1, abort line ≥1, no child marker, breadcrumb
`CHILD_NOTE rc_jolt stash=dss` present) **OR the completed envelope** (rc 0,
the five-token dict, tear lines admitted and no other error). The marker is
branch-stable: `jolt=crash-or-classes`. Both branches were observed across
this seat's runs (the first three arm runs aborted, later ones completed).

## 5. `param_purity` — pure input, RID precedence, fresh containers

| token | GodotPhysics | Jolt | Dummy |
|---|---|---|---|
| params unchanged across the 6 reads | `6/6` | `6/6` | `6/6` |
| both-set / box-only / rid-only hits | `1,0,1` | `1,0,1` | `0,0,0` |
| fresh containers (not `is_same`, `==` equal) | `3/3` | `3/3` | `3/3` |

The fingerprint covers transform, motion, margin, mask, bodies/areas flags,
shape, `shape_rid` and exclude. `shape_rid` beats `shape` at `z=-1.7` (the
RID sphere reaches the wall face at `z=-2`; the 0.2 box does not).

## 6. `body_inertia` — the getters as values

Rigid box (half `2×0.5×0.5`, mass 2): `imass 0.5`, `inverse_inertia
(3, 0.352941, 0.352941)` on **both** real backends; mass 4 → `0.25` /
`(1.5, 0.176471, 0.176471)`; `BODY_PARAM_INERTIA (9,4,1)` → inverse
`(0.111111, 0.25, 1.0)`. The rot-Y-30 tensor reads
`(2.338235,0,-1.146210 / 0,0.352941,0 / -1.146210,0,1.014706)` and the
child **derives** it in-run as `R · diag(measured local) · Rᵀ`
(`tensor=world`) rather than restating the numbers.

Backend splits, pinned per backend:

| body | GodotPhysics | Jolt | Dummy |
|---|---|---|---|
| static / kinematic | `imass 0`, zero tensor | `imass 1`, zero inertia, **identity** tensor | `imass 0`, identity |
| principal axes at identity | identity | **column permutation** `0,1,0 / 0,0,1 / 1,0,0` | identity |
| principal axes at rot-Y-30 | `rot` (x-col `0.866,0,-0.5`) | `perm` (x-col `0,1,0`) | `identity` |
| COM write `(0.4,0,0)` | `0.400000` | `0.400002` (float error) | ignored |
| tensor check | `world` | `world` | `floor` |

The scout's §7 "Jolt returns a differently-ordered basis (likely sorted by
inertia magnitude; inference)" is refined: the permutation is present even
at the **identity** orientation, so it is a fixed basis convention, not a
response to the rotation. Jolt's `static`/`kinematic` placeholders stay
internally inconsistent (`imass 1` + zero inertia + identity tensor), and
Dummy's identity tensor is the `floor` class — never a derived world tensor.

## 7. `wrong_args` — typed empties, identical text

Thirteen cells (wrong-class params ×6, `null`, no-shape ×3, `max_results`
−1/0 ×3) all exit 0 with a typed empty (`Array` `t28,n0` /
`PackedFloat32Array` `t32,n0` / `Dictionary` `t27,n0`), token-for-token
identical on all three backends. Log counts (raw child logs):

| line | GP | Jolt | Dummy |
|---|---|---|---|
| `Required object "rp_shape_query" is null.` | 6 | 6 | 6 |
| `Required object "rp_point_query" is null.` | 1 | 1 | 1 |
| `Parameter "shape" is null.` | 3 | 3 | **0** |
| `Condition "p_size < 0" is true. Returning: ERR_INVALID_PARAMETER` | 1 | 1 | 1 |

The row requires the two `Required object` counts and the `p_size` count
**equal across backends** (the scout's "identical error text" claim,
log-witnessed) and pins the `shape` line per backend (the Dummy floor
split).

## 8. `geom_split` — the backend-geometry envelopes

```
gs_plain  pt=1/1 cm=frac normal=-0.000000,0.447214,-0.894427 ovp=start  cs=2/neg
gs_jolt   pt=2/1 cm=frac normal= 0.000000,1.000000, 0.000000 ovp=offset cs=2/neg
```

Boundary-touching `intersect_point` counts the containing wall only on
GodotPhysics and additionally the touched floor on Jolt; the wall-contact
bracket is wide vs tight; the same in-place floor penetration returns a
tilted depenetration normal on GodotPhysics and pure-up on Jolt; the overlap
rest point is the query centre (`start`) vs offset. Never a cross-backend
equality.

## 9. `freed_space_methods` — per method × backend, in one parallel batch

One child per method on the real backends (a crash cannot be caught) plus
one Dummy child covering all six, spawned as ONE parallel batch
(`_spawn_batch`): 13 crash children in ~3.1 s wall (run 3: 3.089 s) against
the 20 s per-case bound. Every child still carries its own
`timeout -s KILL 6`; the batch adds a fail-closed 12 s deadline that fails
the row named (`batch_timeout`) rather than passing a partial matrix.

- **GodotPhysics** (6/6): `rc` 134, `handle_crash: Program crashed with
  signal 11` ×1, the `previously freed` SCRIPT ERROR ×1, the null-space
  refetch ×1, breadcrumb `alive=`/`pre=`/`refetch=` present and `post=`
  absent, **no** child marker. 18/18 standalone reps + all batch runs.
- **Jolt** (process-sensitive, three measured crash shapes + a dead-handle
  path): the kill lands at `bds.get_space_state()` (no marker at all), after
  a dead `post=nil`, or after a **live** wrapper whose query aborts — the
  last one ending in `terminate called after throwing an instance of
  'std::system_error' / what(): Invalid argument`. The dead-handle path
  (`rc=0`, `post=nil`, no crash/abort line) was measured by the scout and is
  accepted; every branch requires the two class witnesses (`previously
  freed` ×1, `Parameter "space" is null.` ×1) and, in the crash branch, at
  least one engine crash/abort line. Observed in this seat's runs: 6/6 crash
  (run 3), 6/6 crash with one `post=nil` marker (an earlier batch run), and
  the `std::system_error` abort (standalone reps).
- **Dummy**: one child, all six methods, `rc=0`, `alive/pre/ret` typed-empty
  and `refetch/post` a fresh `PhysicsDirectSpaceState3DDummy`, 30 tokens
  compared as one whole dict, 0 crash lines.

**New measured Jolt fact (teardown order).** `free_rid(space)` while a
never-activated private space still holds a live body aborts
(`rc 134` inside `free_rid(space)`; `space→body→shape` 2/2), while
`shape→body→space` and `body→shape→space` both exit 0 (2/2 each) — measured
with the 4-mode scratch probe `scratch/orderprobe.gd` on both a Jolt and a
Jolt+thread project. That is why the `inactive_space` child registers its
private space LAST in `owned`. It is recorded here as a measured class, not
landed as a row (outside the assigned cells; the freed-space family's own
crash rows are the landed ones).

## 10. Harness changes (all additive or behavior-preserving)

1. `_spawn_child` split into `_child_prepare` (project generation, stale-log
   unlink, command build) + `_child_scan` (exit code + CHILD_RESULT/error
   scan) + the composition it always was. The only behavioral edit inside:
   the SCRIPT ERROR branch now routes through the same `_error_allowed`
   predicate as ERROR lines, so an arm can name an expected SCRIPT ERROR
   class (`previously freed`); `Parse Error` stays unconditional, and no
   r83–r87 arm passes a token that can match a SCRIPT ERROR line.
2. `_spawn_batch` — the parallel spawner (specs of the same fields), each
   child still `timeout -s KILL`-wrapped, with a fail-closed batch deadline.
3. `_mk_body` gained a defaulted `ext` (box half-extents) and
   `_sphere_params` a defaulted `with_shape`; `_initialize` samples position
   A for the `fg_*` arms only. All defaulted, so every existing call site is
   unchanged — confirmed empirically by the 201/201 prior-row identity, not
   by inspection.
4. New shared child helpers: `_fetch_world_dss`, `_dss_live`, `_fmt_read`,
   `_call_read`, `_pt_params`, `_ray_params`, `_params_fp`, the `QNode`
   sampler, `_cm_class`, `_v3s`/`_bs`/`_tensor_check`/`_pax_class`/… .

Gates are fail-closed: each backend-split arm calls `_gate("Jolt Physics"
…)` / `_gate("Dummy" …)` (absent hint → `BLOCKED … _absent=true`, exit 1,
never a fabricated split); every child verdict dict is compared **whole**;
every engine-line claim is counted in the raw child log; the two crash rows
require a second independent witness (the engine line + the empty marker
set + the breadcrumb envelope).

## 11. Behavioral evidence

### 11.1 Full battery ×3, two of them post-landing

```
run 1  20261015T050432984582Z  210/210 PASS, probes 4/4 — INVALID as a
       post-landing run: this seat edited README.md mid-run (seed digests
       drift, seeds_unchanged=false). Kept as diagnostic evidence.
run 2  20261015T051039925318Z  210/210 PASS  5m07s  seeds_unchanged=true
run 3  20261015T051707077779Z  210/210 PASS  5m14s  seeds_unchanged=true
       totals cases=210 pass=210 fail=0 ordinary=164 negative_controls=46
       probes: crash_exit PASS, stream_attribution PASS, tree_timeout PASS
       (witness_verified=true, witness_gone=true, cleanup="SIGTERM to
       verified detached witness"), mutation detected=true
```

Run 2 vs run 3: **0 mismatches over 12 fields × 210 rows** (all rows,
including the nine new ones, byte-identical). New-row wall clock 2.47–5.69 s
each (case bound 20 s); `freed_space_methods` is the cheapest of the
multi-child rows at ~3.1 s thanks to the parallel batch.

Receipt shas: run 2 `1fd4e0cab5f2372dff885f20a456056934adae96ba5040956132f712ddeef39d`,
run 3 `5146ebe4f7c1ab39ce7033bbe9d6cf6cc15f2cfd1a67464d86f4a66a8a8edfd9`,
run 1 (diagnostic) `3757a1932941bfc7df5749470425675c777d28b80f2f6716c958b09c6af5e016`.

### 11.2 Prior 201 rows byte-identical at identical positions

`corpus/live/r88-baseline/tools/verify_prior_rows_full.py` against the
frozen 201-row 6-tuple (`prior-201-godot-rows-full.json`, the r88 baseline's
post-fold reference at `db64943`):

```
run 2: index-identical prior rows 201/201, inserted rows 9, RESULT PASS
run 3: index-identical prior rows 201/201, inserted rows 9, RESULT PASS
```

The strict tool compares `[case, verdict, actual_exit, marker, stdout-lines,
stderr-lines]` index-by-index. The wider
`r88_compare_prior.py` view agrees: **201/201 strict-tuple identical, 0
semantic drift rows, 0 declared marker re-pins, 9 inserted rows at the
tail**, and with `--cases-dir corpus/fixtures` it reports **210 CASES
entries, 0 cross-check mismatches** (every receipt row's case/marker/
expected/actual equals the committed table).

### 11.3 Sibling batteries untouched and green

- **bpy**: 83/83, `probe.stdout.txt` sha256
  `6a98c570dbaec6f33f23c684ae2938470a251c229cb50d4451c23eb1d07defc3` —
  **byte-identical to the frozen baseline** (the 14th identical receipt).
- **three.js** (three@0.186.1, node v24.21.0): 3/3 + 4/4 + 9/9 + 5/5 + 5/5 +
  5/5 = **31/31, seeds_unchanged=true** on every suite.

No `bpy_*`, `three/` or prior-`.gd` file was touched: `git status` lists
exactly the three declared tracked files.

## 12. Files changed

| file | delta | note |
|---|---|---|
| `corpus/fixtures/phys3d_events.gd` | +2024 / −8 | nine arms + child bodies + helpers; the 8 deleted lines are the three additive helper signatures and the `_spawn_child` split |
| `corpus/fixtures/run_battery.py` | +29 / −0 (this seat) | nine rows appended at the tail, child-crash rows last; another lane's 5-line `--runs` harness edit is also in the tree and is not this seat's diff |
| `corpus/fixtures/README.md` | +133 / −0 | one section appended; `## Determinism rules` heading intact |

Working-tree sha256 at submission:
`phys3d_events.gd fd72730b4150c21fc12c55e5921f3f0250013a63aec64c86f98ca61d3db373e7`,
`run_battery.py 50477429307000f03193bec9790d18aa5235476833b82afe51862796771794f0`,
`README.md 34282953735702af57465756e4bc97e85a9df3da4cc68b52a94dddd19bc5b136`.

Scratch (gitignored, not a deliverable): `scratch/` (the focused scratch
project + `dictcheck.gd` + `orderprobe.gd` + generated child projects),
`runs/` (three full receipts + `runs-smoke/`), `battery-run{1,2,3}.log`,
`bpy-runs/`, `bpy.log`, `three-*.log`.

## 13. Remaining risks, unresolved, blockers

1. **Two rows are deliberately disjunctive.** `race_class` accepts the Jolt
   crash envelope or the completed envelope, and `freed_space_methods`
   accepts crash-or-dead per Jolt method. Both are measured bimodalities,
   both carry second witnesses (engine lines + marker-shape + breadcrumb),
   and both markers are branch-stable — but they are weaker than a
   single-value pin. The Jolt branch *distribution* is not claimed anywhere.
2. **The Jolt crash mode is characterised, not explained.** Three crash
   shapes (no marker / dead `post=nil` / live wrapper + `std::system_error`)
   were all measured; which one lands is load- and heap-dependent.
3. **The `inactive_space` F firing is broadphase-only** because the full
   battery there aborts the Jolt child. The out-of-phase shape-channel
   behaviour is pinned by `race_class` instead; a reader must not read the
   inactive arm as "the shape channel is safe out of phase" (it is not).
4. **`race_class` never requires the race to be observed.** A run where all
   four out-of-phase samples answer `all` passes (measured on GodotPhysics
   3/3). The claim is the envelope, and the observed class set is evidence
   in the child log, never a gate — that is the assignment's "never pin a
   distribution" rule taken literally.
5. **Jolt's principal-axes permutation and COM float error are pinned as
   literals** (`0,1,0/0,0,1/1,0,0` and `0.400002`). A Jolt update that
   changes either fails the row loudly — correct, but it is a
   version-bound literal like every other numeric pin here.
6. **The prior-row identity depends on the harness's error-scan shape.**
   The SCRIPT ERROR branch now routes through `_error_allowed`; the 201/201
   identity across two runs is the empirical proof that no existing arm is
   affected, but a future arm that passes a broad `allow_lines` token could
   silently admit a SCRIPT ERROR class. The `allow_lines` doc-comment says
   so.
7. **All of this is one host, one build**
   (`4.7.2.stable.arch_linux.ed1daf0bf`), `--headless`, 60 tps, and the
   generated project variants. No cross-version inference.
8. **The Dummy rows are floor rows only** — no Dummy child is armed as a
   hazard detector (scout directive 8).
9. **Blockers: none.** The batteries are green, the rows are inserted, the
   siblings are untouched, the prior 201 rows are byte-identical. The host
   owns the commit.

**Seat output complete.** No commit, no push, no deployment; no runtime
other than the fixture battery was invoked.
