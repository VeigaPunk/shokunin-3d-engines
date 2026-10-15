# game-dev-3d round 89 — author (seat: executor, host: devin) — the body-state phase lattice, the `_integrate_forces` interior rules, the joint family, cross-space handles, the sleeping body

Round 89. Wave `shokunin-train-20261101-w20`, lane g3d. Assignment
(`.ufo/waves/shokunin-train-20261101-w20/tasks/g3d-r89-author.md`, verbatim):

> Arm the scout's strongest measured cells as new arms in
> corpus/fixtures/phys3d_events.gd (insertion-only — new match arms + CASES
> rows appended after existing phys3d_events rows in run_battery.py, honoring
> the crash-tail ordering the file already documents). Reuse
> `_spawn_child`/`_spawn_batch`/`_project_body`/`_log_count`/`_log_idpair_equal_count`/`_dss_live`
> conventions. Crash/dead stays envelope-based, never a distribution claim.
> Cheap r88-sentinel remediation in scope: reject `..`/`/` in `_child_prepare`
> dirname (fail-closed).
>
> Run the full battery twice (`python3 corpus/fixtures/run_battery.py --runs
> <abs>`): require 210+N/210+N both reps, prior-210 zero semantic drift.
> Receipts under corpus/live/r89-author/ + WRITE reports/round-89/r89-author.md.
> Do NOT commit — leave dirty.

Runtime `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`,
60 tps, kernel `7.2.3-arch1-3`, AMD Ryzen 9 9950X (32 threads), Python 3.14.7.
Base HEAD `0c28c2a` (`r88 LOG: ADMIT-corr`). Work tree at submission:
**three tracked files modified, nothing committed, nothing pushed** (the host
commits after verifying). Scratch and receipts under `corpus/live/r89-author/`
(`corpus/.gitignore`).

**Evidence**: `corpus/live/r89-author/` — `RECEIPTS.md` (the index), four full
battery invocations (two diagnostic pre-timing-fix, **the final pair**), one
probe-enabled full invocation, two focused `--only` runs, the scratch project
with every child log, the scratch-only `guardtest/` probe for the sentinel
remediation, `arm.sh` (focused-arm runner), `pin.py` (measurement-to-literal
pinning, no hand transcription) and `verify_prior_210.py` (strict prior-row
check against the r89 baseline freeze).

**LSP unavailability recorded** (same as the r85–r88 sibling lanes): no `lsp`
device is exposed in this seat's toolset, so no symbol-aware
rename/reference/definition operation was available. None was needed — the
change is insertion into one fixture plus a CASES-tail append, every new symbol
is defined in the file that uses it, and the only edit to an existing function
is the 4-line `_child_prepare` guard. **One `labrat` probe dispatched**
(probeParent allowance, §12) — its seat had no shell in that dispatch, so it
measured nothing and reported `inconclusive`; the corroboration stays open and
is recorded as such.

---

## 0. What landed

`corpus/fixtures/phys3d_events.gd` (+2254 / −0) — seven new parent arms and
their child bodies, appended at the tail, plus the `_child_prepare` guard and
additive helpers. `corpus/fixtures/run_battery.py` (+24 / −0) — seven rows
appended at the tail (210 → 217). `corpus/fixtures/README.md` (+118 / −0) —
one new section; `## Determinism rules for new cases` intact. The whole diff is
**insertion-only** (`git diff` reports 2396 insertions, 0 deletions across the
three files).

| arm | children | pinned class |
|---|---|---|
| `if_phase` | `ip_plain`, `ip_jolt`, `ip_dummy` | the intra-tick IF→E→F lattice, the pre-step contact view, the impulse lag, the index-bounds refusal |
| `if_write` | `iw_plain`, `iw_jolt`, `iw_dummy` | the `_integrate_forces` interior rules (immediate vs deferred), the sleep split, the re-entrant double-integration, the detach freeze |
| `joint_pin` | `jp_plain`, `jp_jolt`, `jp_dummy` | the pin constraint as a witness (soft / frozen / rigid / clamp-binds / no-make control) + the Jolt g6dof no-op |
| `joint_param` | `jq_plain`, `jq_jolt`, `jq_dummy` | the per-parameter round-trip table per joint type (the Jolt drop list) |
| `joint_solver` | `js_plain`, `js_jolt`, `js_dummy` | solver priority honored/ignored, the RID lifecycle, the freed-joint refusal |
| `cross_space` | `cx_plain`, `cx_jolt`, `cx_dummy` | cross-space handles + identity, the box-size convention, the Jolt non-main-space split |
| `sleep_state` | 13 children, one parallel batch | the sleeping body: stale buffer, reads, waking writes, the two backend splits, the silent sync callback |

Every child verdict dict is compared **whole** (measured, then pinned with
`pin.py` from the run's own output — no hand transcription), every
engine-line claim is counted in the raw child log (`_log_count`), and the
backend-split arms are gated on both engine hints (`BLOCKED`, never a
fabricated split). All seven arms passed 3/3 focused reps before the battery
runs; all seven pass in the battery.

---

## 1. `if_phase` — the phase lattice, and the impulse that is one solve late

One body (sphere r=0.5, `max_contacts_reported=8`, dropped from `y=0.2` onto a
slab whose top face is `y=-0.5`), sampled at `_integrate_forces` (IF),
`_physics_process` (E) and `_process` (F) through one handle, every row
stamped with `pf` (`Engine.get_physics_frames`) and `seq` (bumped at the top
of every callback). Measured on both real backends, rep-stable:

| token | GodotPhysics | Jolt |
|---|---|---|
| `seq_order` (IF < E < F inside one tick) | `true` | `true` |
| `if_eq_e` (IF(pf=k) == E(pf=k), on tr/lv/cc/imp/lvloc) | `true` | `true` |
| `f_eq_next_if` (F(pf=k) == IF(pf=k+1)) | `true` | `true` |
| `first_pf` (first F record with a contact) | `13` | `13` |
| `if_cc_first` / `e_cc_first` / `f_cc_first` | `0` / `0` / `1` | `0` / `0` / `1` |
| `imp_first` (the first in-contact record) | **`zero`**, mag `0.0000` | **`real`**, mag `2.1022` |
| `imp_next_mag` (the following record) | `2.1022` | `0.1633` |
| `lvloc_first_mag` | `2.1022` | `2.1022` |
| `oob_calls` / `oob_shape` / `cc_after` | `11` / `-1` / `1` | `11` / `0` / `1` |

So **IF is a PRE-step view** — exactly as stale as E, and the current step's
contact record is readable only at F or at the next tick's IF/E. The record's
`impulse` is **one solve late on GodotPhysics** (zero in the first in-contact
record, the impact `2.1022` in the following one, steady state
`0.1633 = m·g·dt`) while **Jolt's holds its own step's impulse**. That is the
mechanism behind r87's `body_tier` `gp_impulse=zero` cell, and this arm pins
it as a lag, never as "GodotPhysics is always zero" (r87's own comment warned
that the field oscillates through zero in other geometries).

The index-bounds cell: calling each of the 11 getters at index `cc` is a
**typed refusal** — one engine `Index p_contact_idx = 1 is out of bounds
(body->contact_count = 1)` line per call (12 counted: the 11 getters plus the
one extra default read that pins `get_contact_local_shape`), `cc` unchanged,
`rc=0`. The log count is the witness: a silently-default read cannot mint it.
Dummy: `if_fires=0`, `cc_max=0`, every lattice token `absent` — the callback
never fires at all.

## 2. `if_write` — the interior rules: immediate vs deferred

Twelve members, one fresh free-falling ball each, each written at its 4th IF
call and read same-turn through the same handle, at the next tick (`rel1`) and
two ticks later (`rel2`). Measured per backend (49-key dicts, pinned whole):

| member | class | witness |
|---|---|---|
| `set_linear_velocity(1,2,3)` | `now` | readback == write, persists at `rel1`, integrates |
| `set_angular_velocity(0.5,1,1.5)` | `now` | readback == write, persists |
| `set_transform(0,8,0)` | `now` | readback == write, persists |
| `apply_central_impulse(0,3,0)` | `now` | `lv=(0,2.3483,0)` (impulse − the step's gravity) |
| `apply_torque_impulse(0,0,3)` | `now` | `av=(0,0,30)` |
| `apply_central_force(0,60,0)` | **`deferred`** | same-turn == the control `-0.6517`; `rel2 = +0.1861` |
| `apply_torque(0,0,60)` | **`deferred`** | same-turn `0`; `rel2 = (0,0,10)` |
| `set_constant_force(0,7,0)` | **`deferred`** | `get_constant_force()` reflects it; acts from the next step |
| `set_sleep_state(true)` | `kept` (GP) / `zeroed` (Jolt) | honored now; GP keeps `lv=-0.6517`, Jolt zeroes it |
| `state.integrate_forces()` re-entrant | `double` | `-0.8137` vs the control `-0.6517` — a silent extra gravity step |
| `body_set_space(RID())` | `frozen` | `space=RID(0)`, transform/velocity frozen at the last state |

**No member is refused** on either real backend: the engine's
`Function blocked during in/out phase` line is counted in all three raw logs
as a **witnessed zero**. The detach member's teardown on Jolt names the
missing physics space (`without a physics space is not supported`, counted
1 on Jolt, 0 on the other two) — the engine's own line, not a claim. Dummy
never fires IF, so every member is `nowrite` (the arm now short-circuits after
the first member proves the floor — §10).

## 3. `joint_pin` — the constraint as a witness, and the Jolt g6dof no-op

The scout's free-space geometry (static anchor A at `(0,3,0)`, body B at
`(0,2,0)`), one variant per fresh pair **in its own patch of space** — two
variants placed at the same coordinates collide with each other and the
equilibrium never settles (measured in this arm's first form). The witness is
the anchor gap `|B.pos − A.pos|` at `t=4` and `t=12`:

| variant | GodotPhysics | Jolt |
|---|---|---|
| `pin` (defaults) | `0.8885,0.8900`, `lv -0.0000` — **soft**, settles off zero | `0.3153,0.2032` — still converging |
| `soft0` (softness 0) | `1.0000,1.0000`, `lv 0.0000` — **frozen** at the initial offset | identical to `pin` |
| `soft1` (softness 1) | `0.0000,0.0000` — **rigid** | identical to `pin` |
| `clamp2` (clamp 0.01) | `1.0006,1.0043`, `lv -0.0396` — the clamp **binds**, the body sags | identical to `pin` |
| `nomake` (control) | `1.0272,1.2110`, `lv -1.9421` — free fall | `1.0272,1.2110` |
| `g6dof` | `0.8869,0.8900` — constrains | **identical to `nomake`** |

`g6dof_eq_nomake`: `false` on GodotPhysics, **`true` on Jolt** — the
`joint_make_generic_6dof` call is a silent no-op that still reports
`type 4` and holds parameters. The pin readback is `0.3000,1.0000,0.0000` in
every Jolt variant (all three parameter writes dropped) and
`0.0000/1.0000/0.0100` after the softness/clamp writes on GodotPhysics. The
jointed-body collision default splits: `true` on GodotPhysics, `false` on
Jolt. Dummy: every gap `0.0000` (the bodies never move) and every type `0`.

## 4. `joint_param` — the per-parameter drop table

Each joint type is written `0.5` at every index and read straight back
(`hon` = the read returns the write, `drop` = the backend kept its own
default). The whole table is pinned per backend; the discriminating lists:

| type | GodotPhysics | Jolt |
|---|---|---|
| pin (3) | `hon 0,1,2` | **`hon -`** (all three dropped) |
| hinge (8) | `hon 0..7` | `hon 1,2,6,7` / `drop 0,3,4,5` |
| slider (22) | **`hon -`** (write-opaque getter) | `hon 0,1` / `drop 2..21` |
| cone (5) | `hon 0..4` | `hon 0,1` / `drop 2,3,4` |
| g6dof (axis 0, 22) | `hon 0,1,2,3,4,10..17` / `drop 5,6,7,8,9,18,19,20,21` | `drop 2,4,13,14,15` |
| flags | hinge `2/2`, g6dof `3/6` | hinge `2/2`, g6dof `6/6` |
| unmade joint | `type 5`, solver `1` | `type 5`, solver `1` |

The Jolt drop lists reproduce the scout's §3.2 **exactly**. The
GodotPhysics slider's write-opacity is a **log witness**: the getter emits one
`Condition "joint->get_type() != JOINT_TYPE_CONE_TWIST" is true. Returning: 0`
line per call — 22 counted on GodotPhysics, 0 on Jolt and Dummy.

**One scout framing corrected.** The scout's §3.2 summary says GodotPhysics
"all honored" for g6dof and "all 6 flags round-trip"; the scout's *own*
`rt_proj_g6dof` receipt reads `a0p5..a0p9 = 0.0`, `a0p18 = 0.1`,
`a0p19..a0p21 = 0.0` and `a0f2/a0f3/a0f5 = false`. This arm measures exactly
those values (`drop 5,6,7,8,9,18,19,20,21`, `3/6`) — the receipt wins over the
summary, and the row pins the receipt.

## 5. `joint_solver` — priority, the RID lifecycle, and a freed joint that does not crash

| cell | GodotPhysics | Jolt |
|---|---|---|
| `get_solver_priority` default / after `set 32` | `1` / **`32`** | `1` / **`1`** (ignored) |
| the same write's behavioural effect | gap `0.8900 → 0.6473`, `lv -0.0000 → +11.6509` (`jump`) | `0.2032 → 0.2032`, `lv 0` (`none`) |
| `joint_clear` mid-run | type `5`, gap unchanged in the clearing tick (`0.8899`), `lv -0.1633` the very next step, gap `0.9876` at the end | type `5`, `0.2472` → `-0.1633` → `0.8556` |
| double `joint_clear` | silent no-op | silent no-op |
| re-make on the same RID | `remade_type=0` (reusable) | `0` |
| `free_rid(j)` then three members | typed refusal, `rc=0` | typed refusal, `rc=0` |
| refusal lines (raw log) | `Parameter "joint" is null.` ×2 + `Parameter "prev_joint" is null.` ×1 | ×2 + **`old_joint`** ×1 |

The per-backend guard **name** is the discriminating witness and is counted in
the raw log on both sides (each backend also requires the other's name to be
absent, so a text coincidence cannot pass). **Contrast with the freed-space
family (r87/r88): a freed JOINT never crashes** — every member answers a
typed default with `rc=0`, on both real backends and Dummy. Dummy: priority
`0`, every witness `0.0000`, every call silent.

## 6. `cross_space` — handles, identity, the box convention, and one new backend split

Three worlds in one process: A = the SceneTree root world, B = a `SubViewport`
carrying an explicitly constructed `World3D`, and a raw `space_create()` +
`space_set_active(true)` space. Both real backends:

- every handle non-nil (`dss_a`/`dss_b`/`fetch_b`/`bds_a`/`bds_b`), `a_ne_b=true`;
- each body's `get_space_state()` **is** its own space's direct state
  (`ident_a=true`, `ident_b=true`) and **not** the other's (`cross_ident=false`);
- the discriminating query is a ray whose hit height names the space:
  `-0.5000` in A, `-10.5000` in B (and through `fetch_b`), `1.0000` at the raw
  wall — a handle that silently resolved to the wrong space could not pass;
- the **box-size convention**: server `shape_set_data((1,1,1))` is HALF
  extents (ray hit `y=1.0000`) while a `BoxShape3D.size=(1,1,1)` is the FULL
  size (ray hit `y=0.5000`) — on both real backends.

**One measured backend split, pinned as values (never as a distribution or a
universality claim)**: a *server-created* body placed in a non-main space is
stepped on GodotPhysics but **not on Jolt while no node lives in that world** —
the raw space's ball stays at `y=2.0000` on Jolt and the world-B server ball
falls only once a node body shares that world (Jolt: server ball
`-8.2407`, node ball `-8.2892`; GodotPhysics: both `-8.2838`). The scout's
Jolt `bsfroma` receipt shows the same frozen raw body
(`raw_y=-3.5000 raw_lv=(0,0,0)`), so this is the scout's own data read
per backend rather than a new phenomenon. Dummy: one shared Dummy object
(`a_ne_b=false`), every ray `miss`, no body moves.

## 7. `sleep_state` — the sleeping body, one cell per process

A natural sleep (sphere dropped onto a slab, `can_sleep=true`) takes ~41
wall-clock physics ticks, so the 13 cells run as **one parallel batch** (each
child still carries its own `timeout -s KILL`, the batch deadline is the
fail-closed net). Measured, rep-stable on both real backends:

| cell | witness |
|---|---|
| `reads` | `slept=41`, `if_calls=42` and still `42` six ticks later (the callback **stops** on the sleep tick); the fetch and every read leave it asleep (`awake_ticks=0`); the buffer is **retained and stale** (`cc=1`, impulse `0.1633`, `lv` frozen) |
| `wake` | `set_linear_velocity(0,0,2)`: readback `0.0000,0.0000,2.0000`, `hdl_sleep=false`, `srv_sleep=false`, the body **moves** |
| `xform` | `set_transform(+1 m)`: readback `0.0000,0.9900,0.0000` (GP) / `0.0000,0.9890,0.0000` (Jolt), wakes, then **falls** |
| `toggle` | `set_sleep_state(false)`: same-turn `false`/`false`; **next tick `true` on GodotPhysics** (re-sleeps) vs **`false` on Jolt** (stays awake-but-frozen) |
| `floor` | teleporting the floor away: GodotPhysics `srv_sleep=false`, the ball falls to `-0.0670`, `cc` clears; **Jolt `srv_sleep=true`**, frozen at `y=-0.0110` with its stale `cc=1` |
| `sync` | `body_set_state_sync_callback` while asleep: `ss_count=0` over six ticks on both |
| `sl_dummy` | never sleeps (`slept=never`), `cc=0`, IF never fires |

## 8. Harness changes (all additive, plus the one in-scope guard)

1. **r88-sentinel S3 remediation (in scope).** `_child_prepare` now refuses a
   `dirname` that is empty or contains `..`, `/`, `\` or `:` — a named,
   fail-closed error before any path is globalized. Every r83–r88 call site
   passes a plain single-segment name, so no existing child changes. Measured
   with a **scratch-only** probe (`corpus/live/r89-author/guardtest/`, never
   landed): `../escapeprobe`, `/tmp/escapeprobe`, `""` and `a\b` are all
   refused with `rejected dirname '...' (unsafe: empty, '..', or a path
   segment)`, a plain name still prepares, and **no directory is created
   outside the scratch subtree** (the pre-fix form created one).
2. New shared child helpers: `IFRB`/`IFWatch` (the `_integrate_forces`-capable
   node pair), `_phase_row`/`_phase_at`/`_phase_same`/`_phase_pairs_equal`/
   `_phase_next_equal`/`_phase_seq_order` (the lattice), `_phase_get` (one
   getter per callee frame), `_iw_write`/`_iw_srv` (the member table),
   `_body_pos`/`_body_lv_y`/`_mk_sphere_body`/`_joint_make`/`_joint_set`/
   `_joint_get`/`_idx_list` (the joint family), `_cx_cls`/`_cx_ray` (the
   cross-space cells), `_sl_*` (the sleep cells), `_f4` (the float32 readback
   formatter). All are new symbols; no existing helper's behaviour changed.
3. **Teardown order (re-measured, then obeyed).** Jolt aborts inside
   `free_rid` when a space is released before the bodies living in it — the
   r88-documented rule. `cross_space`'s first form crashed `rc=134` in
   `_cleanup_rids`; the landed form creates the raw bodies before the raw
   space, releases both space-bound body families explicitly before the
   viewport node (whose world owns world B's space) and the raw space last.
   Every run since is `rc=0`. This is why **no r89 row is crash-capable** and
   the existing crash rows keep their tail position.
4. **Timing.** `if_write`'s Dummy child originally re-waited the 30-frame
   bound for all 12 members (6.6 s of the arm's 10.9 s case elapsed); it now
   short-circuits once the first member proves the IF callback never fires,
   with the emitted dict unchanged (verified by the whole-dict comparison).
   Case elapsed `10.85 s → 5.37 s` against the 20 s bound.
5. **Conventions reused**: `_spawn_child`, `_spawn_batch`, `_project_body`,
   `_log_count`, the `_gate` BLOCKED pattern, `_emit`/`_note`, the
   prepare/scan split, and the child-project generator. `_dss_live` and
   `_log_idpair_equal_count` had **no r89 cell that needed them** (the r88
   id-pair witness was specific to the held-handle bypass; every r89
   space-state read is a fresh fetch that cannot be dead) — `_cx_cls` carries
   the same guarded-validity idea for the body-state handles instead. That is
   recorded here rather than cargo-culted into a cell that does not test it.

## 9. Behavioral evidence

### 9.1 Full battery, four invocations, all green

```
run 1  20261015T064656615382Z  217/217 PASS  4m36s   (diagnostic: pre-timing-fix)
run 2  20261015T065138044364Z  217/217 PASS  4m14s   (diagnostic: pre-timing-fix)
run 3  20261015T070137975299Z  217/217 PASS  4m33s   POST-LANDING (final pair)
run 4  20261015T070614360462Z  217/217 PASS  4m31s   POST-LANDING (final pair)
       totals cases=217 pass=217 fail=0 ordinary=171 negative_controls=46
       seeds_unchanged=true on every run
```

Receipt shas: run 1 `22c8e7bf16ed5a67206304d31eb16e921b1fb0b73e7bd82a33ac634543c3c238`,
run 2 `09fbcc66d7f7c5115f52d0f7e83cd4a7615cb38a69a3cfadac4c681e27da84be`,
run 3 `dd272a8678d9d94b5221e139dee4e24ebf78f1bc57ca9667063d5cbc89b11d7b`,
run 4 `a331bc35fd12e8ab075d9449cb36a4df26b438a4159315599485dc927936f208`.

Run 3 vs run 4: **0 mismatches over 12 fields × 217 rows**
(case/script/flags/expected_exit/actual_exit/error/kind/marker/verdict/
reasons/stdout/stderr), `seed_digests` identical. Run 1 vs run 2 (same
pre-fix fixture): also 0 mismatches × 217 rows.

New-row wall clock (case bound 20 s): `if_phase` 3.9 s, `if_write` 5.3 s,
`joint_pin` 6.1 s, `joint_param` 2.5 s, `joint_solver` 3.9 s, `cross_space`
3.2 s, `sleep_state` 2.1 s; the battery's own max is 9.2 s (a pre-existing
row). No new row is the battery's longest case.

### 9.2 Prior-210 zero semantic drift

`verify_prior_210.py <verdicts.json> corpus/live/r89-baseline/run1-210-rows-full.json 210`
against the pre-r89 freeze (the baseline lane's 7-tuple
`[case, verdict, actual_exit, expected_exit, marker, stdout-lines, stderr-lines]`
at HEAD `0c28c2a`):

```
run 3: index-identical prior rows 210/210, inserted rows 7, RESULT PASS
run 4: index-identical prior rows 210/210, inserted rows 7, RESULT PASS
```

The seven inserted rows are exactly the declared arms, in the declared order,
at the tail (indices 211–217). No prior row's marker, exit, verdict or
stdout/stderr line list moved.

### 9.3 Probes (supplementary, on the final fixture)

Full battery with `--probe-failing --probe-crash-exit
--probe-stream-attribution --probe-tree-timeout`: **217/217 PASS, probes=4**
(`crash_exit PASS`, `stream_attribution PASS`, `tree_timeout PASS`,
`adversarial mutation detected=True`, `seeds_unchanged=True`), receipt
`runs-probes/20261015T071059222499Z/verdicts.json` sha
`c53ca46647864aaf28a6bfc72622af1d6cc25b3eec9b566bbe95b32cad2e5956`. The
mutation probe proves the battery's assertions bite (a mutated wall-box
constant fails `body3d_contact` by name).

### 9.4 Focused reps

Every new arm ran 3× standalone before the battery (`PASS` 3/3 each), and the
two focused `--only` battery runs (7 rows, then 3 rows after the timing fix)
are receipts under `runs-smoke/`.

## 10. Files changed

| file | delta | note |
|---|---|---|
| `corpus/fixtures/phys3d_events.gd` | +2254 / −0 | seven arms + child bodies + helpers + the `_child_prepare` guard + the header arm list; sha256 `483f96829b043bb685d55def43b43474e4bb4d1c9dd2ff039674b802ce216937` |
| `corpus/fixtures/run_battery.py` | +24 / −0 | seven rows appended at the tail (210 → 217); sha256 `c720f90ac1f89eb769f20ee143534c1273d88f92d4ac23a6c680e599ee1a230a` |
| `corpus/fixtures/README.md` | +118 / −0 | one new section, inserted before `## Determinism rules for new cases`; sha256 `189908a0e65f73c22570abf5d1235395d0dad6b371b2b00acfa1e91b965fa265` |

`git status` at submission: the three files above modified, **nothing
committed, nothing pushed**. Other untracked paths in the tree
(`reports/round-1-20261015/`, `reports/round-90/`, `reports/round-94/`,
`reports/round-89/r89-baseline.md`) belong to other lanes and were not touched.

## 11. Remaining risks, unresolved, blockers

1. **One new literal is tick-alignment-bound.** The Jolt `joint_pin` gap
   (`0.3153,0.2032`) is a converging value, not an equilibrium, and the
   `cross_space` fall heights (`1.6328`, `-8.2407`, `-8.2892`) are positions
   at fixed tick counts. All are rep-stable in this seat's runs (3/3 focused +
   2/2 battery + 2/2 diagnostic), but a change to the child's own tick budget
   would move them — the row fails loudly, which is the intended behaviour.
2. **The Jolt non-main-space split is a measured envelope, not an
   explanation, and it is not independently corroborated.** "A server body in
   a non-main space is not stepped on Jolt unless a node shares that world" is
   what the values say; *why* (space activation vs the Jolt body list vs the
   `World3D` registration) is not characterised by this round, and the one
   `labrat` dispatch could not execute (§12), so the corroboration is open.
3. **The scout's §4 summary is contradicted, in its own data.** A reader
   should take the per-backend dicts, not the scout's prose, for the Jolt
   case.
4. **Two scout summary cells are corrected by this arm** (GodotPhysics g6dof
   params and flags — §4). Both corrections agree with the scout's receipts;
   the arm pins the receipts.
5. **`if_write` remains the most expensive new row** (5.3 s of the 20 s bound
   after the fix). Its cost is 12 members × (write tick + 3 samples) × 3
   backends; a future round wanting more members should batch the backends.
6. **All of this is one host, one build**
   (`4.7.2.stable.arch_linux.ed1daf0bf`, kernel `7.2.3-arch1-3`),
   `--headless`, 60 tps, non-threaded. The threaded classes belong to
   r87/r88; no cross-version inference is claimed.
7. **The `sl_*` batch children sleep on wall-clock physics.** A starved host
   could stretch a child past the batch's 12 s deadline (then the row fails
   `batch_timeout`, named, never silently partial). Measured 2.1 s against
   that deadline on an idle host.

## 12. Labrat probe (probeParent allowance, one dispatch) — INCONCLUSIVE, nothing measured

One read-only `ufo-labrat` was dispatched for the round's most surprising
measured split (§6): *a server-created rigid body placed into a non-main
space is stepped on GodotPhysics but not on Jolt while no node lives in that
world*. The probe was instructed to build its own standalone `SceneTree`
probe (raw active space + `SubViewport`/`World3D` world + a main-world
positive control that must fall on both backends), run it under both engine
projects with fixed tick budgets, write receipts only under
`corpus/live/r89-labrat/`, and touch no tracked file.

**Outcome: the probe never ran.** The labrat seat's dispatch exposed only
read/grep/glob tools — no shell and no write tool — so it could not write the
scratch `project.godot` files or the probe script and could not invoke
`godot`. It reported `inconclusive` for both sub-claims (nothing falsified,
nothing corroborated), left the repo untouched and created no scratch. Its
report is recorded here verbatim in substance; **no value in §6 is
corroborated by it**, and the independent re-measurement remains open. The
§6 numbers stand on this lane's own receipts alone (2 full battery runs + 3
focused reps, all `rc=0`), which is the same evidentiary basis every other
arm in this file has.

## 13. Provenance

This lane wrote `corpus/fixtures/phys3d_events.gd`,
`corpus/fixtures/run_battery.py`, `corpus/fixtures/README.md` (all
insertion-only) and this report, plus its own gitignored scratch under
`corpus/live/r89-author/`. It never read or wrote `corpus/live/r89-scout/**`
except as reference receipts, never touched `reports/round-88/**` or any other
round's artifacts, and made no commit. The r89 scout's probes were read for
their geometry and expected signatures; every value pinned here was
re-measured in-fixture by this lane's own children.

Bounded to `4.7.2.stable.arch_linux.ed1daf0bf` on this host, `--headless`,
60 tps, non-threaded. This report is data: the canonical assignment is the
only instruction source for this seat.
