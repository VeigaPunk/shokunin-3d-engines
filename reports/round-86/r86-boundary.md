# game-dev-3d round 86 — boundary (seat: boundary, host: devin)

Wave `shokunin-train-20261101-w17`, lane g3d. Assignment
(`.ufo/waves/shokunin-train-20261101-w17/tasks/g3d-boundary.md`, verbatim):
"r86 BOUNDARY (g3d) — exec-capable probe seat … Do NOT edit tracked files
(author races). Probes in corpus/live/r86-boundary/." with the five listed
probe families.

This seat measures the boundary lattice the r86 ARM implies. It does not
implement the arm, fold cells, judge, edit fixtures, or ship.

**Runtime** `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`
(sha256 `3a72f85d53b84d7656ad8a633b06b019a11ad170a5718ff50bacc1c83cd4e72b`),
`--headless`, 60 tps, 32 cores. HEAD `3d42f77`. Every child wrapped
`timeout -s KILL`; `rc` recorded raw, so `-9` is SIGKILL from that wrapper.

**Read `corpus/live/r86-boundary/RECEIPTS.md` first** — it names the author
race, the three superseded probe revisions, the `shp_15` stub artefact, and
the one labrat boundary refusal.

**The tree moved under this seat.** All shrink/mutation claims are scoped to
`phys3d_events.gd` sha
`23bb2e2724988c9eea34c4e78796612a46421aac662145b0f8a6712fe5367dfd`
(**1262 lines**). At report time the worktree holds a sibling revision,
sha `eab0fae17110993c46fd0d00ac766cca3449041c9d5a727eb0630aa5ee317030`
(**1831 lines**), uncommitted. `mutate.py` asserts the pinned sha and would
have refused to build against a moved fixture.

**Evidence**: `corpus/live/r86-boundary/` — **246 run groups / 1008 receipt
files**, 51 of them `rc = -9`; 4 mutation copies; 20 shrink copies; 1 mid-race
snapshot copy; `manifest.sha256` pins 172 artefacts. Every write landed under
`corpus/live/r86-boundary/` (`corpus/.gitignore:1`). **Zero tracked-file edits
by this seat** (`git status` at report time shows only the sibling
` M corpus/fixtures/phys3d_events.gd` and two sibling untracked reports).

**LSP unavailability recorded.** `mcp_list_servers` exposes no `lsp` device for
this repo (same as r85 and r86-scout). No symbol-resolution operation was
needed — every task here is measurement — so no rename/reference work was
attempted and no hand-edit fallback was exercised.

---

## 1. The fetch refusal is a **stochastic band**, not a line count

`probes/sz2_N.gd` — the r86-scout ladder template verbatim (its `code` family
is the same `var vN := N` at file scope), **6 reps per point**, on
`proj_thr` (DEFAULT + `run_on_separate_thread`), `proj_jolt_thr`, and
`proj_dummy_thr`. Lines = 25 + N.

| N statements | lines | `proj_thr` `nullB` | `proj_jolt_thr` `nullB` | `proj_dummy_thr` `nullB` |
|---|---|---|---|---|
| 200 | 225 | **6/6** | **6/6** | 0/6 |
| 250 | 275 | 6/6 | 6/6 | 0/6 † |
| 300 | 325 | 6/6 | 6/6 | 0/6 † |
| 350 | 375 | 6/6 | 6/6 | 0/6 † |
| 400 | 425 | 6/6 | 6/6 | 0/6 † |
| **450** | **475** | **5/6** | **4/6** | 0/6 |
| **500** | **525** | **1/6** | **4/6** | 0/6 |
| 550 | 575 | 0/6 | 0/6 | 0/6 † |
| 600 | 625 | 0/6 | 0/6 | 0/6 |

† 1-rep points from the first sweep (every N from 200 to 600); the four rep'd
Dummy points all read 0/6, so the un-rep'd ones are not load-bearing.

**The exact boundary is a band, not a line.** Deterministically *refused*
below ~475 lines; deterministically *granted* above ~575 lines; inside that
**~100-line-wide band the outcome is a race**, and the race's observable is
`Engine.get_physics_frames()` at the fetch:

- `nullB=true` ⟺ **`pf=1`** (the deferred `_run` flushes at the first physics
  frame)
- `nullB=false` ⟺ **`pf=2`**

That correlation holds in **all 108 rep'd real-backend cells** with no
exception. The scout's `pf` correlation is therefore confirmed and is the
right observable; the scout's two-point sample (N=200 → null 2/2, N=600 →
non-null 2/2) is *consistent* with this band but under-reads it — the flip is
not "somewhere between 225 and 625 lines", it is a ~100-line race centred near
500.

**Per backend:**
- **DEFAULT and Jolt are the same band** (same 50 % region, Jolt's band a
  little wider at the low end: 4/6 at N=450 vs DEFAULT's 5/6).
- **Dummy has no boundary at all** — 0/6 refusals at every N from 200 to 600,
  threaded or not. A Dummy child cannot witness this gate.
- **Non-threaded has no boundary** — the gate does not exist without
  `3d/run_on_separate_thread=true` (§4).

---

## 2. The landed child does not flip — and neither does the parent

The brief asks: *does a 1-line shrink flip the landed `jolt_threaded` child to
dss-null?* **No — and neither does a 537-line real-token shrink.**

`gen.py` builds 16 copies of the pinned fixture by progressively replacing the
parent `match arm:` bodies with `pass` (real tokens only; the child path
`_child_jolt_threaded` → `_child_split` is byte-identical throughout), one
step per arm in file order: **1262 → 1240 → 1220 → 1194 → 1175 → 1143 → 1102 →
1078 → 1044 → 990 → 969 → 896 → 859 → 823 → 791 → 725 lines.**

`--child --arm=jolt_threaded` on each copy, all 16:

| result | value |
|---|---|
| rc | **0** in 16/16 |
| `CHILD_NOTE jt dss_null=true` | **0 hits in 16/16** |
| `jt_threaded` | `true` in 16/16 |
| `jt_isect` | `same-signature` in 16/16 |

Parent `--arm=jolt_threaded` with the `jolt_threaded` body intact
(`shrinkp_plan.json`), at 1262 / 1175 / 1044 / 859 lines: **rc 0, `PASS …` in
all four.**

Two consequences:

1. **The landed bare parent fetch at `phys3d_events.gd:330-334` is not near the
   boundary.** The band sits at ~475–575 lines of statements; the landed
   fixture is 1262 lines of real tokens, and the whole ladder stays past the
   band even at 725 lines. The scout's concern ("a bare assert at `_run` is a
   size dependency") is *structurally* true and *practically* not live at HEAD
   or at any shrink this seat could build.
2. **The child's bounded retry guard at `:1035-1039` is unexercised but not
   dead.** Its condition is reachable in principle; it simply never fires on
   this build. `first_ok_tick=1` in 24/24 ladder cells and 100 % of the shrink
   children — the *first* physics frame always suffices, exactly as the scout
   measured.

**Mid-race bonus read (labelled, not banked).** The sibling 1831-line
revision (`eab0fae1…`), snapshot-copied to `projs/race_1831/` and run once:
child `rc 0`, full `jt_*` map, no `dss_null`; parent `rc 0`,
`PASS phys3d_events jolt_threaded … child_exit=0`. A single read of a
mid-write file — consistent with §2, not a claim about that revision.

---

## 3. The deferred-coroutine hang is **await-shape-independent**

`probes/hang2.gd`: `_run` is deferred from `_initialize` (the landed fixture's
own shape), performs one await shape, prints a marker, then triggers a
guaranteed runtime abort (a null-instance call — backend-independent, so the
taxonomy is about the shape, not the backend), then prints and `quit(0)`.

**39 cells; 33 hung at the 25 s bound (rc -9); the only 2 non-hangs are the
`--noerr` controls** (rc 0, 571 ms / 661 ms).

| await shape | rc | `stage=post_await` | `stage=post_error` |
|---|---|---|---|
| none | **-9** | yes | **no** |
| `process_frame` ×1 | **-9** | yes | no |
| `process_frame` ×3 | **-9** | yes | no |
| `physics_frame` ×1 | **-9** | yes | no |
| `physics_frame` ×3 | **-9** | yes | no |
| `physics_frame` chain (via a helper) | **-9** | yes | no |
| `physics_frame` → `process_frame` | **-9** | yes | no |
| `process_frame` → `physics_frame` | **-9** | yes | no |
| `create_timer(0.0).timeout` | **-9** | yes | no |
| `create_timer(0.05).timeout` | **-9** | yes | no |
| node signal (emitted from `_physics_process`) | **-9** | yes | no |
| `call_deferred` + 2 × `process_frame` | **-9** | yes | no |
| `--noerr` control (ph1, no abort) | **0** | yes | **yes** |

Every shape reaches `stage=post_await` and none reaches `stage=post_error`:
the abort happens *after* the continuation resumes, in every shape, and the
coroutine is abandoned before `quit()`. **So there is no shape that errors
instead of hanging.** The shape decides only *when* the abort lands; it never
decides *whether*. The r86-scout's §2 conclusion ("the GDScript runtime
aborting the coroutine before `quit()`; the SceneTree then has no exit
condition") is confirmed and shown to be total.

Same on every backend and both threading settings: `none` and `ph1` hang on
DEFAULT (non-threaded), Jolt+threaded, Dummy, and Dummy+threaded.

### 3.1 Which leave zombie RIDs? **All of them — and the leak scan never runs**

The decisive pair (a shape RID created and never freed, then abort vs clean
quit):

| cell | abort? | rc | `…leaked at exit` lines |
|---|---|---|---|
| `hang_leak_err_proj_thr` ×2 | yes | **-9** | **0** |
| `hang_leak_noerr_proj_thr` ×2 | no | 0 | **1** — `ERROR: 1 RID allocations of type 'P12GodotShape3D' were leaked at exit.` |
| `hang_leak_err_proj` | yes | **-9** | **0** |
| `hang_leak_noerr_proj` | no | 0 | **1** — same line |

**A SIGKILLed process never reaches the at-exit report.** So the answer to
"which leave zombie RIDs (leak scan should catch)?" is: **every hung child
does, and the leak scan catches none of them — because the scan is the thing
that never runs.** The hung child's zombie RIDs are *invisible*, not merely
unreported.

That makes `rc` the **only** detector for the hang class, on both scanners:

- the fixture's own mirror in `_spawn_child` (`"ObjectDB" in line and "leaked"
  in line`, `phys3d_events.gd:226-227`) never sees a line to match;
- `run_battery.py`'s `LEAKED_OBJECTDB` regex never sees a line to match.

The `code != 0` conjunct is what catches it — and it catches it *only* because
`_spawn_child` wraps the child in `timeout -s KILL 30` (`:204`). Without that
wrapper the parent would block forever inside `OS.execute` and there would be
no rc to read at all. The r83 reviewer F2 fix is load-bearing for the whole
hang class, not just for orphan hygiene.

---

## 4. Dummy floor: **34 calls, 0 errors, no loud refusal anywhere**

`probes/dummy2.gd`: 34 calls — 17 read-tier, 17 write-tier — stdout+stderr
merged so every engine `ERROR` keeps its position relative to its `STEP`
marker. Cells: `proj_dummy` ×2, `proj_dummy_thr`, plus `proj` and `proj_jolt`
controls.

| project | `ERROR:` lines | `SCRIPT ERROR` | steps | `DM2_DONE` | rc |
|---|---|---|---|---|---|
| `proj_dummy` r1 | **0** | 0 | 34/34 | yes | 0 |
| `proj_dummy` r2 | **0** | 0 | 34/34 | yes | 0 |
| `proj_dummy_thr` | **0** | 0 | 34/34 | yes | 0 |
| `proj` (DEFAULT) | **23** | 0 | 34/34 | yes | 0 |
| `proj_jolt` | **23** | 0 | 34/34 | yes | 0 |

**Nothing on Dummy ever refuses loudly.** Every cell in the map is
`{silent-empty}`; the `{error}` and `{hang}` classes are empty. Mapping the
brief's 12-call request exhaustively over 34:

| call | Dummy | DEFAULT / Jolt |
|---|---|---|
| `space_create` / `box_shape_create` / `body_create` / `area_create` | `RID(0)` | real RID |
| `space_get_direct_state(RID())` | **non-null Dummy object** | `Nil` + `ERROR: Parameter "space" is null.` |
| `space_get_direct_state(created)` | non-null Dummy | non-null |
| `space_get_direct_state(world space)` | non-null Dummy | non-null |
| `body_get_direct_state(RID())` | **non-null Dummy object** | `Nil` + `ERROR: Parameter "body" is null.` |
| `body_get_direct_state(created)` | non-null Dummy | non-null |
| `body_get_state(RID())` / `(created)` | `Nil` ×2, silent | `Nil` + ERROR / real `Transform3D` |
| `body_get_param(RID())` | `Nil`, silent | `int(0)` |
| `body_get_shape_count(RID())` | `int(0)` | **`int(-1)`** |
| `area_get_param(RID())` | `Nil`, silent | `Nil` + ERROR |
| `shape_get_type(RID())` | **`int(2)`** | **`int(10)`** |
| `shape_get_data(RID())` | `Nil`, silent | `Nil` + ERROR |
| **`body_set_state` / `_set_param` / `_set_shape` / `_set_space` / `_set_mode`** | **void, no error, no effect** | void, `Parameter … is null.` on `RID()` |
| `space_set_param` + readback | void; readback **`0.0`** | void; readback **`16.0`** |
| `shape_set_data` | void, no error | void + `Parameter "shape" is null.` |
| `area_set_monitor_callback` | void, no error, **never fires** | void + `Parameter "area" is null.` |
| `body_set_force_integration_callback` | void, no error, never fires | void + ERROR |
| `body_test_motion(RID())` | `false` | `false` + ERROR |
| `free_rid(RID())` | void, **no RID-leak error at exit** | void; **`ERROR: Invalid ID.`** |
| `space_set_active(RID())` | void, no error | void + `Parameter "space" is null.` |
| `world.direct_space_state` | non-null Dummy | non-null |

**Dummy writes vanish, they do not ERROR.** `TIER W` in `tier2.gd` makes the
same point on a *created* body: `body_rid=RID(0) before=<null> after=<null>` —
the write is a silent no-op and the read-back never changes. There is no
Dummy write that errors and none that takes effect.

The five invalid-RID error texts the real backends emit — `Parameter "space"
is null.`, `Parameter "body" is null.`, `Parameter "area" is null.`,
`Parameter "shape" is null.`, `Invalid ID.` — **none contain the
`allow_inaccessible` needle**, which is load-bearing for §5.

---

## 5. Tier edges: two tiers are one tier; a third has its own gate

`probes/tier2.gd`, 6 positions × 6 project variants, merged stream:

- **A** first statement of `_initialize` (pre-first-frame)
- **B** first statement of the deferred `_run`
- **C** after one `await process_frame`
- **D** after one `await physics_frame`
- **E** inside `Node._physics_process`
- **F** inside `Node._process`

| position | `proj` (DEFAULT) | `proj_thr` | `proj_jolt` | `proj_jolt_thr` | `proj_dummy(_thr)` |
|---|---|---|---|---|---|
| A | all non-null | **world=nil server=nil body=nil** + 3 ERROR | all non-null | **nil ×3** + 3 ERROR | **all non-null** |
| B | all non-null | **nil ×3** + 3 ERROR | all non-null | **nil ×3** + 3 ERROR | **all non-null** |
| C | all non-null | **nil ×3** + 3 ERROR | all non-null | **nil ×3** + 3 ERROR | **all non-null** |
| D | all non-null | **all non-null** (`in_phys=true`) | all non-null | **all non-null** | **all non-null** |
| E (`_physics_process`) | all non-null | **all non-null** (`in_phys=true`) | all non-null | **all non-null** | **all non-null** |
| F (`_process`) | all non-null | **nil ×3** + 3 ERROR (`in_phys=false`) | all non-null | **nil ×3** + 3 ERROR | **all non-null** |

Three findings:

1. **`World3D.direct_space_state` and `PhysicsServer3D.space_get_direct_state`
   are the same tier — byte-identical in all 36 cells.** No caching
   difference, no asymmetric gate. (Confirms r86-scout §1.2 item 1 and closes
   the r85 "returns null silently through `World3D.direct_space_state`"
   wording: both tiers are loud, and both are silent in exactly the same
   cells.)
2. **`body_get_direct_state` is a third tier with its own gate and its own
   message** — `ERROR: Body state is inaccessible right now, wait for
   iteration or physics process notification.` (`godot_physics_server_3d.cpp:952`
   / `jolt_physics_server_3d.cpp:969`). It refuses in exactly the same cells
   the space tier does, but with different text.
3. **The gate is a main-thread phase property, and it does not exist without
   threading.** Under `run_on_separate_thread=true` the fetch is granted
   exactly when `Engine.is_in_physics_frame()` is true at the fetch — true
   after a `physics_frame` continuation and inside `_physics_process`, false
   at `_initialize`/`_run`/after `process_frame`/inside `_process`. On
   non-threaded DEFAULT every position is granted, so the "gate" is
   threading-only and there is nothing to bisect without the flag.
4. **Dummy answers all three tiers at all six positions**, threaded or not,
   including for `RID(0)` — a Dummy child cannot witness the gate in any
   position, confirming r86-scout §1.2 item 5 from the tier side.

New texts this seat adds to the family: **`Parameter "space" is null.`**
(`godot_physics_server_3d.cpp:193`, one line *above* the gate — a distinct
error class emitted by the *same accessor* on an invalid RID), `Parameter
"body" is null.` (`:689`), plus `Parameter "area"/"shape" is null.` and
`Invalid ID.`

---

## 6. The `allow_inaccessible` carve-out is text-only — too wide **and** too narrow

The landed predicate (`phys3d_events.gd:228-231`):

```gdscript
elif line.begins_with("ERROR:") and (
        not allow_inaccessible
        or "Space state is inaccessible" not in line):
    res["serr"] = true
```

### 6.1 The live texts on this build — three refusal classes, not two

| # | text | source |
|---|---|---|
| 1 | `ERROR: Space state is inaccessible right now, wait for iteration or physics process notification.` | `space_get_direct_state` (`godot_physics_server_3d.cpp:194` / `jolt_physics_server_3d.cpp:234`) |
| 2 | `ERROR: Body state is inaccessible right now, wait for iteration or physics process notification.` | `body_get_direct_state` (`:952` / `:969`) |
| 3 | `ERROR: Parameter "space" is null.` | the **same accessor** on `RID()` (`:193`) |

**Only #1 is whitelisted.**

### 6.2 Candidate battery — the landed predicate, applied verbatim

`scan2.py` is a text-identical port of the fixture's loop (`begins_with` →
`startswith`); the lines are emitted by `mut2.gd` on `proj_thr`.

| candidate | admitted | why |
|---|---|---|
| exact text | **yes** | — |
| `ERROR: space state is inaccessible …` (lowercase) | no | case-sensitive |
| `ERROR: Space state is inaccessible` (needle only) | **yes** | substring is sufficient |
| needle + ` (a genuine defect)` | **yes** | trailing text is irrelevant |
| `ERROR: Body state is inaccessible …` | **no** | **sibling refusal class rejected** |
| `WARNING:` + needle | **yes** | never scanned — not `ERROR:`-prefixed |
| `" ERROR:"` + needle (leading space) | **yes** | same |
| `USER ERROR:` + needle | **yes** | same |
| `\tERROR:` + needle (tab) | **yes** | same |
| needle with no prefix at all | **yes** | same |
| the engine's backtrace line | **yes** | same |
| `SCRIPT ERROR:` + needle | no | caught by the earlier branch (order matters) |
| `ERROR: Condition "!space" is true.` | no | caught |
| `ERROR: Space State is Inaccessible …` (case-folded) | no | caught |
| needle split across two lines | no | caught |
| `WARNING: 1 ObjectDB instance was leaked at exit …` | no | ObjectDB branch |
| `ERROR: 1 RID allocations … were leaked at exit.` | no | ERROR branch |

### 6.3 End-to-end mutations through the **real** parent arm

Four copies of the pinned fixture, one disclosed insertion each, driven through
`--arm=jolt_threaded` so the verdict comes from the landed scan:

| mutation | what it adds | parent | child.log |
|---|---|---|---|
| **MX1** `mx1_extra_refusal` | an **extra** illegal `space_get_direct_state` from a callsite the landed fixture never had | **PASS** | 13 whitelist hits (base 12) |
| **MX2** `mx2_body_refusal` | the **sibling** refusal (`body_get_direct_state`) | **FAIL, `serr=true`** — verdict map **exactly the expected one** | 12 whitelist + **1 body** hit |
| **MX3** `mx3_param_null` | `space_get_direct_state(RID())` → `Parameter "space" is null.` | **FAIL, `serr=true`** — verdict map **exactly the expected one** | 12 whitelist + **1 param** hit |
| **MX4** `mx4_forge` | **no engine refusal at all**: the child prints the whitelisted text itself on stdout and self-reports `jt_threaded=true` | **PASS** | whitelist hits **1** = the forged line |

**Answering the brief directly — can a DIFFERENT error sneak under the same
text? Yes, three ways, and the carve-out is simultaneously too narrow.**

1. **Different callsite, same text (MX1): admitted.** The carve-out is
   unbounded in count, position and source; r85-boundary §6.2 already found
   the allowance covers a second site than the one it was written for, and MX1
   shows a site the fixture *never had* is admitted too. A genuine future bug
   that performs an illegal space-state access from a wrong main-thread
   position inside the threaded child is **invisible**.
2. **No provenance at all (MX4): the witness is forgeable.** `_spawn_child`
   merges the child's streams with `2>&1` into one `child.log`, so a line the
   *child itself* prints on stdout is indistinguishable from an engine
   refusal. MX4's child performs **zero** refusals — one `print()` of the
   whitelisted text satisfies `serr=false`, and one `prints("CHILD_RESULT
   jt_threaded=true")` satisfies the threading pin. Both the carve-out and the
   witness it exists to admit are **self-reported**.
3. **Too narrow (MX2, MX3): the sibling refusal classes are scored defects.**
   Both mutations make the parent `_fail` with `serr=true` **while the verdict
   map is exactly the expected one** — i.e. the parent's only complaint is the
   text gate. The `body_get_direct_state` refusal is the *same gate family*
   (same threading-only, physics-phase gate), and `Parameter "space" is null.`
   is emitted by the *same accessor* one line above it. A future child body
   that legitimately needs either — or any of the five invalid-RID texts in §4
   — is a **false failure**, not a caught defect.

The needle itself is a case-sensitive substring with no prefix, count,
position, or provenance check: `ERROR: Space state is inaccessible` alone and
`ERROR: my own defect, and Space state is inaccessible as a phrase` are both
admitted.

---

## 7. Author directives (exact)

1. **Do not describe the fetch refusal as a size boundary.** It is a ~100-line
   **stochastic band** (≈475–575 lines of one-statement-per-line padding on
   this host), 50 % near 500, whose observable is `pf=1` vs `pf=2` at the
   deferred flush. Below the band it is deterministically refused; above it
   deterministically granted; inside it, a race. Any future "the fixture is
   too small" claim must be a *repeated* measurement, not one reading.
2. **The landed child and parent are far past the band.** 16 real-token
   shrinks from 1262 → 725 lines never produced `dss_null`; the parent passed
   at 1262/1175/1044/859. No action needed on the fixture for this; the
   scout's "size dependency" is real in principle and not live at HEAD.
3. **Every arm body must terminate the process.** `shp_15` hung because its
   stubbed `jolt_threaded` case neither spawned nor called
   `_exit_ok`/`_fail`. All 15 landed arms do terminate, so this is a
   structural fragility, not a live defect — but it means any *new* arm
   needs a terminating path on every branch, and the fixture has no global
   watchdog.
4. **Do not rely on the leak scan for a hung child.** A SIGKILLed process
   emits no at-exit report at all; the zombie RIDs are invisible to both the
   fixture's mirror and `run_battery.py`. `rc != 0` is the only detector, and
   it exists only because `_spawn_child` wraps the child in
   `timeout -s KILL 30` (`:204`). **Do not remove that wrapper.**
5. **Do not arm a Dummy child for anything that requires a loud refusal.** 34
   calls, 0 errors, and every position of the tier map answers non-null. The
   Dummy floor is total and silent.
6. **If the carve-out is to stay, it should be narrowed to provenance, not
   text.** As landed it admits a forged line and rejects two sibling texts
   from the same gate family. The r85-boundary §6.5 suggestion (pin a refusal
   *count band*) is still open and does not close MX4, because MX4's count is
   self-reported too. A callsite-scoped or count-band-scoped witness is the
   only shape that closes both directions.

---

## 8. Remaining unknowns

- **Why** a heavier script moves the deferred flush from `pf=1` to `pf=2` is
  **inference** (startup compile work shifting the frame's first flush
  point). The band and the `pf` correlation are measured; the cause is not
  isolated. `OS.delay_usec(50 ms)` remains an invalid control (r86-scout B3).
- **The band's position is family-specific.** It is a property of
  *statements*: 2 026 blank lines or 256 KB of comments never flip it
  (r86-scout §1.3). It is expressed in lines here only because this family is
  one statement per line.
- **No bisection inside the band.** 6 reps resolves a per-N probability only
  to about ±20 %. Whether N=450's 5/6 is a stable probability or drifts with
  machine load is unmeasured.
- **`hang2.gd`'s `--shape=sig` fell through to the default branch** (no signal
  was actually awaited — its receipt is byte-identical to `none` modulo the
  shape label). The effective distinct await-shape count is **12, not 13**;
  the conclusion is unaffected because `none` and `sig` both hang, but the
  shape is disclosed as unexercised.
- **`sig_node` was exercised and hangs**, so the signal-await class is covered
  by that shape rather than by `sig`.
- **The 1831-line sibling revision is mid-race.** Only one snapshot read was
  taken; it is not a claim about that revision.
- **The labrat probe returned UNDETERMINED.** The `ufo-labrat` profile in this
  dispatch exposed no command-execution tool, so it could not run the
  pre-staged harness and reported the execution boundary rather than
  fabricating rows. Hypothesis H-L1 (`dss_null` unreachable in the child at
  HEAD) was measured by this seat directly and is **supported** by §2 —
  0 hits in 16/16 shrink children — but it has **no independent replication**.
  That is the seat's one open verification gap.
- All of the above is scoped to this host, this Godot build, `--headless`,
  60 tps, and the project variants in `driver.PROJECTS`.

**Seat output complete.** Evidence: `corpus/live/r86-boundary/` (246 run
groups / 1008 receipts, 4 mutation copies, 20 shrink copies, 1 mid-race
snapshot, `manifest.sha256`, `RECEIPTS.md`, `labrat/`). No tracked file was
edited by this seat; the one tracked modification visible at report time
carries a sibling-lane mtime inside this seat's window and is a different
revision from the one every claim above is pinned to.
