# game-dev-3d round 85 — boundary (seat: boundary, host: devin)

Wave `shokunin-train-20261101-w16`, lane g3d. Assignment
(`.ufo/waves/shokunin-train-20261101-w16/tasks/g3d-boundary.md`, verbatim):
"r85 BOUNDARY (g3d) — adversarial backend edges … impersonation edges the guard
misses … the new total dispatch … stale-log forge re-test post-fold … ObjectDB
leak arm … phase_delta edge … Report -> reports/round-85/r85-boundary.md."

This seat measures the boundary lattice the r85 ARM implies. It does not
implement the arm, fold cells, judge, edit fixtures, or ship.

**Lane root** `~/Projects/shokunin/game-dev-3d-shokunin`, HEAD `ac025b2`.
**Runtime** `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf` (2026-08-17),
`--headless`, 60 tps, 32 cores. Every bound below is scoped to that build.
Every probe wrapped `timeout -s KILL`.

**LSP unavailability recorded.** `mcp_list_servers` exposes only `rea` (Ghidra
binary analysis) — no `lsp` device serves this repo, so no symbol fact below is
claimed as semantic proof; each is engine-measured or read/grep-level. All work
here is measurement, not symbol resolution, so no rename/reference operation
was needed.

**Write scope respected.** `corpus/live/r85-boundary/` (gitignored,
`corpus/.gitignore:1`) + this report. No tracked file touched; no git mutation;
no subagent (this seat is a plain executor, not the frozen probeParent).
`git status --porcelain` at report time = the two sibling fixture files
(` M corpus/fixtures/phys3d_events.gd`, ` M corpus/fixtures/run_battery.py`) +
untracked `reports/round-8{5,6}/` — none of it mine. **Nothing was written under
`corpus/fixtures/`** (the completion seat's concurrent territory): the battery
was run from a *copy* of the seed dir (`corpus/live/r85-boundary/bat/`) with
`--runs` redirected into this seat's scratch.

---

## (0) Revision provenance — two candidates, and the seat pivoted mid-flight

The worktree moved under this seat. Both revisions were measured; every claim
below names the one it belongs to.

| rev | `phys3d_events.gd` sha256 | mtime (local) | load gate | battery (phys3d set) |
|---|---|---|---|---|
| **v1** | `9c99b3068e0bfaf049d4963552b06931c7d31a221d8c39fe426b58338296f1e4` | 15:42:18 | **FAIL — parse error, every arm dead** | n/a (cannot run) |
| **v2** | `4bcde2bf39cd829887b7cea9da41fe6c3a528cbbfd9f62900b44c30c6db72355` | 16:22:49 | pass | **15/15 PASS** |

`corpus/fixtures/run_battery.py` at report time: sha
`991c6c8ac39a58a576dd9d1e1cc4d922a996dc9b978c9a5f435d325c2666add5`, mtime
16:23:48, **191 CASES rows** (188 prior + 3 new: `jolt_threaded`,
`dummy_refused`, `srv_phase_delta` at `:443-448`). v1 was a *mid-write*
snapshot of the author's file: it grew from 1196 → 1263 lines during the seat
and was rewritten at 16:22:49. **v2 is the landing candidate**; §1 is recorded
because it is the highest-severity observation of the seat and because it
defines which revision every other number belongs to.

Reproduce v1: `corpus/live/r85-boundary/proj/` (v1 + the two bodies this seat
appended, §1b). Reproduce v2: `corpus/live/r85-boundary/proj_v2/` (verbatim
copy, sha-identical to the candidate). HEAD control:
`corpus/live/r85-boundary/proj_head/` (`e09e30ee…`).

---

## (1) The load gate — v1 did not run at all; v2 does

### (a) v1: total failure, 188 prior rows included

```
$ godot --headless --path proj --script res://phys3d_events.gd -- --arm=isect
exit=1   stdout 101 B (banner only)   stderr 425 B
SCRIPT ERROR: Parse Error: Function "_child_jolt_threaded()" not found in base self.
          at: GDScript::reload (res://phys3d_events.gd:318)
SCRIPT ERROR: Parse Error: Function "_child_dummy()" not found in base self.
          at: GDScript::reload (res://phys3d_events.gd:320)
ERROR: Failed to load script "res://phys3d_events.gd" with error "Parse error".
   at: load (modules/gdscript/gdscript_resource_format.cpp:46)
```
Receipts `runs/load_isect.{stdout,stderr}.txt`, `runs/load_isect.exit`.

v1's dispatch (`:314-326`) routed to four child bodies; `_child_jolt_threaded`
and `_child_dummy` were **called but never defined** (v1 `grep -c '^func '` =
16; only `_child_threaded:911` and `_child_jolt:973` exist). GDScript resolves
that at *reload*, so the failure is not local to the two new arms: **the whole
script fails to load**, and all 188 prior cases plus all three new arms would
have read red on `exit 1 != expected 0` + `exact stdout marker missing` +
`Parse Error on stderr`. It is a total, not partial, regression.

HEAD control in the same shape: `exit=0`, `PASS phys3d_events isect …`,
stderr 0 B (`runs/head_isect.*`). The failure is attributable to the r85 diff.

### (b) v1 machinery probing (the load-repaired copy)

Because v1's parent-side refactor (`_spawn_child`) is what §4–§6 test, this
seat built a **load-repaired** v1 (`corpus/live/r85-boundary/proj/`, sha
`2d2231f3…`) by appending the two missing bodies (`repair.py`). The appended
bodies are **reconstructions, disclosed as such**: `_child_dummy` = the
`_child_jolt` body with the key prefix renamed; `_child_jolt_threaded` = the
same plus a `jt_threaded` witness. They are labelled so in the receipts. The
repaired copy is a *probe instrument*, never a claim about the author's bodies.

### (c) v2 loads and the whole arm set is green

`runs/arm_census.txt` (16 arms) — every arm reaches its authored verdict:

| arm | exit | stderr | verdict |
|---|---|---|---|
| isect, cast, btm, pp_queries, contact_stale, contact_sig, sync_cb, srv_area_cb | 0 | 0 B | each `PASS` with its prior marker |
| static_nopair | **2** | 0 B | `NEGATIVE REJECTED:` (the fixture's negative class) |
| phase_delta | 0 | 0 B | `PASS … proc_delta=2 phys_delta=1` |
| threaded_edge, jolt_edge | 0 | 0 B | `PASS … child_exit=0` |
| **jolt_threaded** | 0 | 0 B | `PASS … backend=Jolt threaded=true … child_exit=0` |
| **dummy_refused** | 0 | 0 B | `PASS … backend=Dummy isect=unexpected … child_exit=0` |
| **srv_phase_delta** | 0 | 0 B | `PASS … srv_proc_delta=2 srv_phys_delta=1` |
| nosucharm | 1 | 241 B | `ERROR: phys3d_events: unknown arm nosucharm` |

**Prior-row invariance holds.** `cmp` of stdout, HEAD vs v2, for the 12
pre-existing arms that spawn or measure: **12/12 IDENTICAL** (`runs/v2_census.txt`)
— isect, cast, btm, pp_queries, contact_stale, contact_sig, sync_cb,
srv_area_cb, static_nopair, phase_delta, threaded_edge, jolt_edge. The r85 diff
is insertion-only for every prior row, confirmed byte-level rather than by
numstat.

**Canonical classifier agrees.** The battery, run from a copy of the seed dir
against the v2 sha, restricted to the 15 `phys3d_events_*` rows:

```
totals: cases=15 pass=15 fail=0 ordinary=14 negative_controls=1 probes=0
PASS battery: corpus/live/r85-boundary/batruns/20261014T192626623218Z/verdicts.json
```
(`runs/battery_phys3d.log`). This is the canonical judge's own classifier on the
current candidate, not this seat's reading.

---

## (2) Impersonation edges — 15 engine strings, and the honest field is the class, not the setting

`runs/imp_*.{stdout,stderr}.txt`, census `runs/imp_census.txt`. Each cell is a
generated child project one `physics/3d/physics_engine` line apart, running the
**parent's own spawn shape** (`--child --arm=jolt_edge`, v2 body).

| `physics/3d/physics_engine` | exit | stderr | engine readback | `jolt_backend` | `dss_class` | effective backend |
|---|---|---|---|---|---|---|
| `"Jolt Physics"` | 0 | 0 B | `Jolt Physics` | `Jolt Physics` | `JoltPhysicsDirectSpaceState3D` | **Jolt** |
| `"Jolt Physics "` (trailing space) | 0 | **0 B** | `Jolt Physics ` | `unexpected` | `GodotPhysicsDirectSpaceState3D` | GodotPhysics3D |
| `" Jolt Physics"` (leading space) | 0 | **0 B** | ` Jolt Physics` | `unexpected` | `GodotPhysics…` | GodotPhysics3D |
| `"JOLT PHYSICS"` | 0 | **0 B** | `JOLT PHYSICS` | `unexpected` | `GodotPhysics…` | GodotPhysics3D |
| `"Jolt Physics\t"` | 0 | **0 B** | `Jolt Physics\t` | `unexpected` | `GodotPhysics…` | GodotPhysics3D |
| `"Jolt Physics X"` | 0 | **0 B** | `Jolt Physics X` | `unexpected` | `GodotPhysics…` | GodotPhysics3D |
| `"Jolt"` / `"jolt physics"` | 0 | **0 B** | as written | `unexpected` | `GodotPhysics…` | GodotPhysics3D |
| `""` (empty) | 0 | **0 B** | *(empty)* | `unexpected` | `GodotPhysics…` | GodotPhysics3D |
| `3` (int literal) | 0 | **0 B** | `3` | `unexpected` | `GodotPhysics…` | GodotPhysics3D |
| `true` (bool literal) | 0 | **0 B** | `true` | `unexpected` | `GodotPhysics…` | GodotPhysics3D |
| `"GodotPhysics3D"` | 0 | **0 B** | `GodotPhysics3D` | `unexpected` | `GodotPhysics…` | GodotPhysics3D |
| `"DEFAULT"` | 0 | **0 B** | `DEFAULT` | `unexpected` | `GodotPhysics…` | GodotPhysics3D |
| key **absent** | 0 | **0 B** | `DEFAULT` | `unexpected` | `GodotPhysics…` | GodotPhysics3D |
| `"Dummy"` | 0 | **0 B** | `Dummy` | **`Dummy`** | `PhysicsDirectSpaceState3DDummy` | Dummy |

1. **Eleven of the fourteen setting values are silent fallbacks** — exit 0, zero
   stderr bytes, no warning line. The four strings this round adds (trailing
   space, leading space, upper case, embedded tab) behave exactly like r84's
   three: the engine keeps the *requested* string in the readback and runs
   GodotPhysics3D. `ProjectSettings.get_setting()` therefore reports a request
   that can carry invisible whitespace and still be a lie — a **strictly
   stronger** version of the r84 §1 rule, because the readback is not merely
   stale, it is byte-different from anything a human would type.
2. **Non-string values are accepted.** `physics_engine=3` and `=true` parse as
   int/bool in `project.godot`, survive `get_setting()`, stringify to `3`/`true`,
   and still select GodotPhysics3D. A parent that string-compares its own
   generated setting line to `"Jolt Physics"` is comparing against a value the
   engine never validated.
3. **The child's two class fields are honest in all 15 cells.**
   `jolt_backend` (ClassDB pair, plus the v2 `PhysicsServer3DDummy` arm) and
   `jolt_dss_class` (the live object) both flip exactly with the effective
   backend, and neither is fooled by any spelling. The parent's map pins both
   (`phys3d_events.gd` `expect` map) and fails loudly on every fallback — the
   **only** detector, matching r84-critic §3. v2 adds one honest improvement:
   `_child_split` now reports `"Dummy"` rather than `"unexpected"` when
   `ClassDB.class_exists("PhysicsServer3DDummy")`, so the Dummy floor is named
   instead of being lumped with the typo class.
4. **No false-negative spelling was found.** There is no string that selects
   Jolt while reading `unexpected`: `jolt_backend` is keyed on the registry
   pair, not on the setting, so a correct Jolt run reads `Jolt Physics` under
   every spelling of the key that actually works (exactly one: `"Jolt Physics"`).
5. The build-level hint is invariant as r84 measured: `HINT
   [DEFAULT,Jolt Physics,GodotPhysics3D,Dummy] type=4` on every variant
   (`runs/hint.stdout.txt`), so `_engine_hint_has("Dummy")` — the new
   `dummy_refused` gate — is **always true** on this build. Its `BLOCKED`
   branch is dead code here, exactly like `jolt_edge`'s; that is an honest
   build gate (r84-critic §4), not a selection gate. Note the helper is a
   *substring* test on `hint_string`, so a future hint carrying
   `"Jolt Physics X"` would pass the `"Jolt Physics"` gate — defensive only.

---

## (3) Total dispatch — r84-critic §2 closed, and closed more strongly than proposed

`runs/imp_census.txt` + `runs/imp_disp_*.{stdout,stderr}.txt`. Under a Jolt
child project, `--child --arm=<each>`:

| `--arm=` | exit | stdout line |
|---|---|---|
| `jolt_edge` | 0 | `CHILD_NOTE jolt_class=true godot_class=false engine=Jolt Physics` + 7 `CHILD_RESULT jolt_*` |
| `jolt_threaded` | 0 | `CHILD_RESULT jt_threaded=false` + `jt_*` map |
| `dummy_refused` | 0 | `CHILD_RESULT dummy_backend=Jolt Physics` + `dummy_*` map |
| `threaded_edge` | 0 | `CHILD_RESULT pp_edge0=true proc_dss_refused=false srv_ok=true` |
| `isect`, `cast`, `btm`, `pp_queries`, `contact_stale`, `contact_sig`, `sync_cb`, `srv_area_cb`, `static_nopair`, `phase_delta`, `srv_phase_delta`, `nosucharm` | **2** | `CHILD_RESULT child_arm=unknown arm='<x>'` |
| *(bare, no `--arm`)* | **2** | `CHILD_RESULT child_arm=unknown arm=''` |

v2's dispatch is a total `match` with a `var bad:` default (`:323-325`) that
prints a machine-readable line and `quit(2)`. That closes r84-critic §2's
"silent wrong-body default" for **every** non-child arm — the twelve parent-only
arm names, an arbitrary typo, and the bare invocation. Two details worth
recording:

- The refusal uses **exit 2**, which is already this fixture's
  negative-rejection class (`static_nopair` uses it), not the `quit(1)` the
  r84 critic sketched. Both satisfy the parent's `code != 0` conjunct; exit 2
  additionally keeps the child's failure taxonomy consistent with the parent's.
- The refusal prints a `CHILD_RESULT` line rather than only `push_error`, so the
  class is visible in the **child log** — the artefact a hand-run reader or a
  future log scanner actually sees. r84-critic's finding was precisely that
  hand-runs had no such key.

**Arm/backend mismatches are all caught by the parent's map, none by the child.**
`--child --arm=dummy_refused` under a **Jolt** project (`runs/x_jolt_dummy_refused.*`,
`runs/x_jolt_thr_dummy_refused.*`) exits 0 with a clean stream and prints the
*full Jolt split* under `dummy_*` keys (`dummy_backend=Jolt Physics`,
`dummy_dss_class=JoltPhysicsDirectSpaceState3D`, `dummy_isect=same-signature`).
The `dummy_refused` child body has **no backend self-gate**: its honesty rests
entirely on the parent pinning `dummy_backend == "Dummy"`. Same shape for
`jolt_edge` under Dummy (now `jolt_backend=Dummy`) and `jolt_threaded` under a
non-threaded Jolt project (`jt_threaded=false`). This is the landed design
(r84-critic §3) and it works — but it means every new arm's discriminating power
lives in the parent's expect map, and a hand-run of any child body alone reads
plausible numbers under the wrong backend.

---

## (4) Stale-log forge — closed, and closed one step harder than r84 assumed

`runs/forge_*.{stdout,stderr}.txt`, census `runs/forge_census.txt`; seeded under
`proj_v2/{thrproj,joltproj}/child.log` with forged `CHILD_RESULT` lines, then
the spawning parent arm run against the v2 candidate.

| cell | pre-state of `child.log` | exit | what the log holds after the spawn |
|---|---|---|---|
| A | forged `CHILD_RESULT pp_edge0=true proc_dss_refused=true srv_ok=true`, 61 B | 0 | fresh child output; forged line **gone** |
| A2 | forged `CHILD_RESULT jolt_backend=Jolt Physics`, 39 B (`jolt_edge`) | 0 | fresh child output; forged line **gone** |
| B | forged + `chmod 400` (unwritable) | 0 | fresh child output; forged line **gone** |
| C | `child.log` is a **directory** | 0 | dir removed, replaced by the 4249 B log |
| E | no forge (control) | 0 | fresh child output |

1. **`DirAccess.remove_absolute(logpath)` closes the class** — the forged verdict
   never satisfies a compare in any cell.
2. **Cell B is the sharp one, and it is closed *harder* than r84-boundary §4
   predicted.** r84 measured that a `chmod 400` log makes the shell redirect
   fail (`exit 1`) while the pre-seeded line *survives verbatim*. Post-fold the
   unlink **deletes the file first** (the directory is writable, the file's own
   mode is irrelevant to `unlink`), so the redirect creates a fresh file and the
   stale content cannot survive even in the redirect-failure family. The guard
   is not merely "rc catches it" — the artefact is destroyed before the spawn.
3. **The two residual cells produce named failures, not silent passes.** A
   non-empty directory at the log path →
   `ERROR: phys3d_events: threaded_edge child log missing` (exit 1,
   `runs/forge_D.stderr.txt`); a read-only project dir →
   `ERROR: phys3d_events: threaded_edge cannot write child project` (exit 1,
   `runs/forge_F.stderr.txt`). Both are caught by the battery's
   any-stderr-line rule. The first message is *misleading* (the path exists but
   is a directory) — a diagnostics nit, not a hole, since the arm still fails.
4. `_spawn_child` does **not** check `remove_absolute`'s return value, and does
   not need to: every way the unlink can fail also fails the redirect or the
   `project.godot` write, and both are named failures. Worth one comment line so
   the invariant is not re-derived.

---

## (5) The ObjectDB leak scan — the parent mirror is complete; the *battery* regex is blind to one leak

`runs/leak_*.{stdout,stderr}.txt`, `runs/leak2_*`, `runs/leak3_*`,
`runs/leak_census.txt`, `runs/leak2_census.txt`; scanner comparison via
`scan_apply.py` (text-identical extractions of both real scanners).

**Measured leak texts on this build** (`core/object/object.cpp:2536`):

| leaked thing | stream | line |
|---|---|---|
| exactly **one** ObjectDB instance | stderr | ``WARNING: 1 ObjectDB instance was leaked at exit (run with `--verbose` for details).`` |
| **two or more** | stderr | ``WARNING: 12 ObjectDB instances were leaked at exit (run with `--verbose` for details).`` |
| a physics RID (`box_shape_create` never freed) | **stdout** | `ERROR: 1 RID allocations of type 'P12GodotShape3D' were leaked at exit.` |
| a `Node3D` added to the tree and never freed | — | **nothing** (the tree frees its children at teardown) |
| a `Resource` held only via `take_over_path` / the cache | — | **nothing** on this build |
| an Object created on a `Thread` and never freed | stderr | the singular form (threading does not change the text) |

Both real scanners, applied to those exact lines:

| line | parent mirror (`"ObjectDB" in line and "leaked" in line`) | battery `LEAKED_OBJECTDB` (`run_battery.py:462`) |
|---|---|---|
| `WARNING: 1 ObjectDB instance was leaked at exit …` | **caught** | **MISSED** |
| `WARNING: 12 ObjectDB instances were leaked at exit …` | caught | caught |
| `ERROR: 1 RID allocations … were leaked at exit.` | caught (ERROR arm) | caught (`"ERROR:" in line`) |

1. **The evasion the brief asks for does not exist for the parent mirror.** No
   real leak form on this build escapes `("ObjectDB" in line and "leaked" in
   line)`: the summary line is a single line, it is emitted on every exit path
   that reaches shutdown, and `--verbose` does not change it (`runs/leak_verbose.stderr.txt`
   is byte-identical to the non-verbose form). A resource-cache or Node leak
   prints nothing at all, so there is nothing to evade — those are *invisible*,
   not evaded.
2. **The battery's regex is the blind one, and it is blind to the common case.**
   `run_battery.py:462-464` requires `[1-9][0-9]* ObjectDB instances were leaked`
   — plural `instances were`. The engine's **singular** form is
   `1 ObjectDB instance was leaked`. So a case process that leaks **exactly one**
   ObjectDB instance passes the battery's leak scan silently. Every other count
   is caught. This is a *one-word* fix and it is in the battery, not the
   fixture: `instances? (was|were) leaked` (or drop the count clause). It is not
   a fabrication risk — a leaking fixture still fails its own marker checks in
   most cases — but it is exactly the r84 reviewer F1 class the mirror was built
   to close, still open on the classifier side.
3. Note the **direction of the asymmetry**: the parent's mirror is *wider* than
   the battery's regex on the singular form and *narrower* on nothing. The two
   scanners disagree on precisely one shape, and the shape is the likely one.

---

## (6) `allow_inaccessible` — narrow by text, total by count, position and source

`runs/x_*` cross-product, `scan_apply.py`, `runs/x_census.txt`. The carve-out in
`_spawn_child` is
`line.begins_with("ERROR:") and (not allow_inaccessible or "Space state is inaccessible" not in line)`.

Measured on real child logs:

| child body | child project | exit | stderr | refusal ERRORs | parent scan, `allow=false` | parent scan, `allow=true` |
|---|---|---|---|---|---|---|
| `jolt_threaded` | Jolt + threaded | 0 | **3558 B** | **12** | serr=True, **12 hits → FAIL** | serr=False → PASS |
| `jolt_threaded` | Jolt (not threaded) | 0 | 0 B | 0 | pass | pass |
| `jolt_threaded` | threaded (not Jolt) | 0 | 3618 B | 12 | FAIL | pass |
| `jolt_threaded` | Dummy | 0 | 0 B | 0 | pass | pass |
| `jolt_edge` | Jolt (not threaded) | 0 | **0 B** | 0 | pass | pass |
| `jolt_edge` | Jolt + threaded | 0 | **0 B** | 0 | pass | pass |
| `threaded_edge` | threaded | 0 | ~1 kB | 3 (v1 shape) / 11 (v2 log) | FAIL | pass |

1. **The carve-out is load-bearing, not hygiene.** Without it the threaded arms
   fail on their own expected witness (12 hits). So it cannot simply be deleted;
   the question is only how wide it is.
2. **It is narrow *by text* and total *by everything else*.** It admits any line
   beginning `ERROR:` that contains that substring — unbounded count, any
   position in the log, any source. Measured: of the 12 admitted lines, **11 are
   the intended witness loop** (`[0] _child_jolt_threaded (res://phys3d_events.gd:1004)`)
   and **1 is the arm's own retry fetch** (`[0] _child_split (res://phys3d_events.gd:1028)`,
   called from `:1008`) — i.e. the whitelist already covers a second, *different*
   site than the one it was written for. Nothing in the fixture distinguishes
   them.
3. **Answering the brief directly: yes, the allowance bleeds into
   `jolt_threaded`'s Jolt half — but the bleed is bounded by the fact that on
   this build the text is threading-specific.** A non-threaded Jolt child emits
   **zero** refusal ERRORs (measured, both `jolt_edge` rows above, 0 B stderr),
   so the *only* way to produce that text is to be threaded — which is exactly
   when it is expected. A genuine Jolt-side defect that surfaces as a
   *non*-refusal engine error is still caught (`ERROR:` with different text →
   `serr=True`). The residual is narrow but real: **a genuine fixture bug that
   performs an illegal space-state access from a wrong main-thread position
   inside the threaded child is invisible**, because the bug's error line and the
   witness's error line are the same string. The `jt_threaded` pin
   (`nulls >= 8 of 12`) is a *lower* bound and cannot detect extra refusals.
4. **`jolt_edge`'s `allow_inaccessible=false` is correct and not a false-failure
   risk** — measured 0 B stderr on a non-threaded Jolt child *and* on a
   Jolt+threaded child (the `_child_jolt` body never fetches at an illegal
   position). The two arms therefore apply *different* ERROR policies to the same
   child body shape, which is defensible but should be stated in the arm comment:
   `jolt_edge` strict, `jolt_threaded` lenient-by-text.
5. **A cheap tightening, if the judge wants it:** pin the refusal *count band*
   in the parent's expect map (the child already knows `nulls`; printing
   `jt_refusals=<n>` and pinning a band would turn the unbounded allowance into a
   bounded one). Not a defect today.

---

## (7) `phase_delta` third-class hunt — nine write positions, still exactly two classes

`runs/p3_*`, `runs/cb_*`, `runs/p3_census.txt`. Standalone probe
(`pproj/phase3.gd` + `pproj/phase3_ctl.gd`, `pproj/cbwrite.gd`): a **server-level**
area (`area_set_monitor_callback`) watches a wall; the write moves the wall onto
the area; the event tier is the callback's frame minus the write frame. The
landed arm writes from `await process_frame` / `await physics_frame`; every
position below is one the landed arm does **not** write from.

| write position | `is_in_physics_frame()` at the write | event delta | class |
|---|---|---|---|
| `_initialize` body, **pre-first-frame** (wf=0) | false | **2** | process |
| `Node._ready` | true | **1** | physics |
| `Node._physics_process` (control) | true | **1** | physics |
| `Node._process` (control) | false | **2** | process |
| `call_deferred` **from the physics phase** | true | **1** | physics |
| `call_deferred` **from the process phase** | false | **2** | process |
| `await process_frame` inside `_physics_process` | false | **2** | process |
| inside `area_set_monitor_callback` | true | **1** | physics |
| inside a node `Area3D.body_entered` handler | true | **1** | physics |

1. **No third class.** Every position lands on `{1, 2}` and the discriminator is
   `Engine.is_in_physics_frame()` at the write — the landed rule, now confirmed
   on five positions the landed arm does not exercise.
2. **`call_deferred` does not escape the phase label.** A deferred call made from
   the physics phase still reports `is_in_physics_frame() == true` and produces
   delta 1; from the process phase, delta 2. So deferral is not a phase-laundering
   path.
3. **A pre-first-frame write is the process class**, not a third value: at
   `wf=0` the write produces delta 2, matching `is_in_physics_frame()==false`.
   Consistent with the rule rather than an exception to it.
4. **A write from inside a physics callback is legal and is the physics class.**
   Both the server monitor callback and a node signal handler performed a
   `body_set_state` mid-callback without error, reported `phase=phys`, and the
   event they caused landed at delta 1. This closes the brief's "write during a
   callback" question with a measured answer rather than an inference.
5. Probe self-correction recorded: the first driver read `delta=none` for five
   arms because the result was printed on the **write** frame, before the event
   could land. The fix (settle 6 frames after the write) is in the probe; the
   first reading is not banked. Same class as r84-boundary §6(e).

---

## (8) Dummy arms — `srv_phase_delta` fails named, `dummy_refused` is clean, `threaded_edge` hangs

`runs/dm_*`, `runs/x_dummy_*`, `runs/dm_census.txt`.

### (a) `srv_phase_delta` under Dummy: every `*_create()` is `RID(0)`; named failure, no hang

`runs/dm_srv.*` (the landed arm's construction, verbatim, inside a Dummy project):

```
NOTE engine=Dummy server=PhysicsServer3DDummy space=RID(0)
NOTE srv area=RID(0) shape=RID(0)
NOTE srv body=RID(0)
RESULT srv arm=srv w0=0 n1=0 n2=0 log=[] f0=4 expect=['0@6']   → exit 1
```
Dummy returns `RID(0)` from `area_create`/`box_shape_create`/`body_create`, the
monitor callback **never fires**, and the arm's own conjunct `s_n2 != 1` fails it
with a named reason. **No hang, no crash, no silent pass** — the arm is
Dummy-safe by accident of its own strictness. `runs/dm_setup.*` shows the
DEFAULT control (real RIDs, `cast_motion` size 2, `body_get_state` a real
`Transform3D`), so the Dummy column is a genuine backend difference, not a probe
artefact.

### (b) `dummy_refused` under Dummy: the negative control works

`runs/x_dummy_dummy_refused.*` — exit 0, **stderr 0 B**, five verdicts:

```
CHILD_RESULT dummy_backend=Dummy
CHILD_RESULT dummy_dss_class=PhysicsDirectSpaceState3DDummy
dummy_isect=unexpected   (s0=0 m0=0 away=0 n1=0 back=0)
dummy_cast=unexpected    (degenerate sizes=0,0,0)
dummy_btm=unexpected     (r=false t=0.0 ×3)
dummy_contact_stale=unexpected (all counts 0)
dummy_static_nopair=unexpected (tp all 0, delta=-1, mv=0)
```
Both r84-critic §5 corrections are **landed** in v2 and visible here: the
`jolt_isect`/`<prefix>_isect` branch now requires positive evidence
(`elif s0 == 1 and back == 1`), and `cast_motion` is size-guarded
(`degenerate sizes=0,0,0` instead of an abort). The cell is a real
negative-control row: the split changes with the backend, not with the sweep.

### (c) `threaded_edge` under Dummy still hangs — rc 137, reproduced twice

`runs/x_dummy_threaded_edge.*` (exit **137** at the 40 s bound, stdout 101 B =
banner only) and `runs/dm_thr_dummy.*` (exit **137**, same class):

```
SCRIPT ERROR: Out of bounds get index '0' (on base: 'PackedFloat32Array')
          at: PPQueries._physics_process (res://phys3d_events.gd:297)
SCRIPT ERROR: Trying to assign value of type 'Nil' to a variable of type 'Transform3D'.
          at: _child_threaded (res://phys3d_events.gd:944)
```
This is r85-scout §2.3 confirmed on the v2 candidate, and it is the sharpest
residual defect of the round: **r84-critic §5.2's guard landed in `_child_split`
but not in the two other places that read the same two Dummy type hazards.**
`PPQueries._physics_process:297` still indexes `cast_motion()[0..1]` unguarded
(this is also the parent `cast` arm's hazard, r84-boundary §3), and
`_child_threaded:944` still assigns `body_get_state(...)` — a `Nil` on Dummy —
to a typed `Transform3D`, which aborts the coroutine *before* `quit()` and turns
a FAIL into a harness kill. Consequences: the failure reads as a TIMEOUT/kill
class rather than a named `unexpected`, the inner `timeout -s KILL 30` bounds a
grandchild the battery's 20 s case timeout has already abandoned, and the
diagnosis is only visible in the child log. Dummy is not reachable from any
landed parent arm today (no Dummy parent exists), so this is a *latent* class,
not a live battery failure — but it is the same defect the round's own
`dummy_refused` arm was built to make classifiable, still live in the two bodies
that were not swept.

---

## (9) Impacted axes and findings

Axes named for this seat: **B1** load integrity (does the candidate run at all),
**B2** impersonation honesty (setting vs effective backend), **B3** dispatch
totality, **B4** spawn-artefact provenance (stale log, leak scan), **B5** witness
scope (`allow_inaccessible`), **B6** phase-class completeness, **B7** backend
negative-control integrity (Dummy).

| # | finding | axis | evidence | smallest safe correction | status |
|---|---|---|---|---|---|
| 1 | v1 (`9c99b306`) did not load: `_child_jolt_threaded`/`_child_dummy` called at `:318/:320`, undefined → **every arm dead** | **B1 ↑↑** | `runs/load_isect.*`; HEAD control passes | define both bodies (v2 does) | **closed in v2** |
| 2 | 11 of 14 `physics_engine` values silently run GodotPhysics3D, incl. trailing/leading space, tab, upper, `3`, `true`, absent; readback echoes the request verbatim | B2 | `runs/imp_*`, census | none — the child's class fields are honest and the parent pins both | measured, no defect |
| 3 | `--child` dispatch is total: 4 known arms, everything else `child_arm=unknown` + exit 2 | **B3 ↑** | `runs/imp_disp_*`, `runs/imp_census.txt` | none (r84-critic §2 closed, stronger than proposed) | **closed** |
| 4 | stale-log forge closed in all 5 cells; `chmod 400` case now closed by the unlink itself, not only by rc | **B4 ↑** | `runs/forge_*`, `runs/forge_census.txt` | one comment noting the invariant (no code change needed) | **closed** |
| 5 | **battery `LEAKED_OBJECTDB` regex misses the singular form** `1 ObjectDB instance was leaked`; the parent mirror catches it | **B4 ↑** | `runs/leak_object.stderr.txt`, `runs/leak3_many.stderr.txt`, `scan_apply.py` | `run_battery.py:462`: `instances? (was|were) leaked` | **open** (battery side) |
| 6 | `allow_inaccessible` admits 12 lines for the threaded child, one of which is the arm's own retry fetch (`_child_split:1028`), not the witness; count/position unpinned | **B5** | `runs/x_jolt_thr_jolt_threaded.stderr.txt`, `scan_apply.py` | optionally print `jt_refusals=<n>` and pin a band | **open, low severity** |
| 7 | `threaded_edge`/`PPQueries` Dummy type hazards still live: rc 137 hang at `:297` and `:944`; the r84-critic §5.2 guard landed only in `_child_split` | **B7 ↑**, **B4** | `runs/x_dummy_threaded_edge.*`, `runs/dm_thr_dummy.*` | size-guard `cast_motion` at `:297`; Variant-typed read + null check at `:944` | **open** |
| 8 | `dummy_refused` child body has no backend self-gate (runs under a Jolt project and reports the Jolt split under `dummy_*` keys) | B2, B3 | `runs/x_jolt_dummy_refused.*` | none — the parent map catches it; note it in the arm comment | measured, by design |
| 9 | `_engine_hint_has("Dummy")` is always true on this build (hint invariant), so the `dummy_refused` `BLOCKED` branch is dead code | B2 | `runs/hint.stdout.txt` | none — honest build gate, same as `jolt_edge` | measured, no defect |
| 10 | `srv_phase_delta` under Dummy: all `RID(0)`, monitor never fires, **named** exit 1 | B7 | `runs/dm_srv.*` | none | measured, no defect |
| 11 | no `phase_delta` third class across 11 write positions incl. `call_deferred` and in-callback writes | B6 | `runs/p3_*`, `runs/cb_*` | none — the landed two-class rule is confirmed, not extended | measured |
| 12 | prior-row invariance: **12/12 byte-identical** HEAD vs v2 | B1 | `runs/v2_census.txt` | none | confirmed |
| 13 | canonical battery on v2: **15/15 PASS** (phys3d set, incl. all three new arms) | B1 | `runs/battery_phys3d.log`, `batruns/…/verdicts.json` | none | confirmed |

**No correction proposed above requires a fixture edit by this seat; all are
recorded for the author/judge.** The one that is squarely in the battery's own
territory (#5) is flagged rather than fixed, because `run_battery.py` is the
completion seat's concurrent file.

---

## (10) Remaining unknowns

- Finding #1 is a **snapshot** fact about `9c99b306`. If v2 is the revision that
  lands, the load failure is a provenance note (the author's file was observed
  mid-write), not a defect in the landing diff. If any downstream receipt was
  taken against `9c99b306`, it is invalid.
- The `allow_inaccessible` analysis is bounded to **this build**: the refusal
  text is the engine's, and a build that words it differently (or a Jolt
  revision that raises a *different* error for an illegal fetch) would change
  both the witness and the whitelist together. The `file:line` in the refusal's
  `at:` clause is already backend-dependent (scout §6.2) while the message is
  not — the whitelist correctly keys on the text, but the text is not
  version-stable by contract.
- The Dummy type hazards (#7) were measured under `--headless`, 60 tps, one
  geometry. The `Nil`-vs-zeroed `Transform3D` distinction is a Dummy property of
  this build; a build returning a zeroed transform would turn the abort into a
  silent wrong value, which the arm would then have to catch by value.
- The leak-text census covers ObjectDB instances, RIDs, `Node3D` and cached
  resources. It does not enumerate every `WARNING` the engine can emit at
  shutdown; the claim is "no measured leak form escapes the parent mirror",
  not "no leak form exists".
- The `phase_delta` probe used a **server-level** monitor for a uniform event
  tier; the node-`Area3D` tier was measured only for the in-callback arm (#7 in
  §7). r85-scout §3.2 already established the two tiers agree, so this is a
  scope note, not a gap.
- The v1 machinery results (§1b, §4, §5) were measured on the **load-repaired
  reconstruction**, not on the author's bodies. Where a result depends on the
  body's *content* (the exact verdict map) it is labelled; where it depends on
  `_spawn_child` (spawn, unlink, scan, rc) it is revision-independent and was
  re-measured on v2 for §4 and §6.

**Seat output complete.** Evidence: `corpus/live/r85-boundary/` — 8 probe
scripts, 6 drivers/scanners, 4 project trees (`proj` = load-repaired v1,
`proj_v2` = verbatim v2, `proj_head` = HEAD control, `pproj*` = standalone
probes), **17** generated child projects, a **32**-cell impersonation + dispatch
matrix, a **16**-cell child×project cross-product, a **5**-cell forge matrix, a
**9**-arm phase probe, `manifest.sha256`, and `runs/` (268 files) with `.exit`
and census files.
No claim above extends past this host, `/usr/bin/godot`
`4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`, 60 tps, and the named project
variants. **Zero tracked-file edits by this seat; no git mutation; no subagent.**
