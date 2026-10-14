# game-dev-3d round 86 — author (seat: author, host: devin) — size gate, deferred-hang class, backend tier, Dummy floor

Wave `shokunin-train-20261101-w17`, lane g3d. Assignment
(`.ufo/waves/shokunin-train-20261101-w17/tasks/g3d-author.md`, verbatim):

> ARM — phys3d_events.gd + run_battery.py, insertion-only (prior 191 rows
> byte-identical; the jolt_threaded child.log is NOT byte-stable — map
> only): script-size ladder cell; deferred-coroutine hang class;
> backend-write tier matrix ext; Dummy silent-floor cell; OPTIONAL nav
> surface seed. Witness discipline: jt_threaded-style self-report needs a
> parent-side or engine-level corroboration where one exists (dss class,
> refusal counts); dummy_class NOTE key stays as-landed (pinned sha) —
> rename deferred.

Read before authoring: `reports/round-86/{r86-scout,nas-scout,bpx-scout}.md`,
`reports/round-85/r85-adjudicator.md`, and — once it landed mid-round — the
sibling `reports/round-86/r86-boundary.md`, which changed two of this seat's
pins (§5, §7). Base: `3d42f77` (post-r85). No commit, no push, no subagent,
no runtime other than the canonical battery.

**Runtime (every bound below is scoped to this):** `/usr/bin/godot`
`4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`, 60 tps, 32 cores,
GodotPhysics3D / Jolt Physics / Dummy backends on this host.

**LSP unavailability recorded.** `mcp_list_servers` exposes only `rea` for
this repo — no `lsp` device answers (same as every r85/r86 sibling lane). No
symbol-aware operation was needed or possible: the assigned diff is two
single-file seeds, and the semantic check that replaces a server here is the
engine's own GDScript compiler — a missing, renamed, or mistyped symbol is a
`Parse Error` at load, which `_spawn_child`'s scan and `run_battery.py`'s
`classify` both fail on. That is how the two anchor-miss mutations below were
caught (§6.3), and it is stronger than a text rename for this file.

**Measured vs predicted.** Everything below is **measured** unless a line
says **inference** or **unresolved**. Every new cell was run before it was
pinned: the generated-probe sizes, the hang bound, the three tier maps, the
floor tuple and the real-backend refusal count are all literals taken from
this seat's own runs, never recomputed from the constants that build the
geometry.

---

## 0. What landed

Four new arms in `corpus/fixtures/phys3d_events.gd`, four new rows in
`corpus/fixtures/run_battery.py` (191 → 195 cases; 145 → 149 ordinary), and
the two coupled documentation lines in `corpus/fixtures/README.md`.

| new row | arm | spawns | wall (final1/final2) |
|---|---|---|---|
| `phys3d_events_script_size_gate` | `script_size_gate` | 4 children | 2.04 / 2.32 s |
| `phys3d_events_deferred_hang` | `deferred_hang` | 2 children (one hung, 8 s bound) | 8.72 / 8.84 s |
| `phys3d_events_backend_tier` | `backend_tier` | 3 children | 2.13 / 2.10 s |
| `phys3d_events_dummy_floor` | `dummy_floor` | 2 children | 1.21 / 1.22 s |

| artifact | sha256 | size |
|---|---|---|
| `corpus/fixtures/phys3d_events.gd` | `66c92c38c9a1e0e981b3b2d6c871dbd3fc63c0b14fc646d2f62da047f1e14296` | 1870 lines (was 1262) |
| `corpus/fixtures/run_battery.py` | `e2df9f966d00c5637e051946c2c28e56ab629161e8f437d8648437aa0fdc69e4` | 195 `CASES` |
| `corpus/fixtures/README.md` | `d89e7be6758495c79d0756cad2dbd135f98478cc80cc7d1611ca284f514f96ca` | count + r86 section |

`git status --porcelain` at seat end: exactly those three ` M` entries, plus
the untracked `reports/round-86/*.md` of this and the sibling seats. **No
commit, no tracked-file deletion, no other tracked file touched.**

---

## 1. `script_size_gate` — the deferred fetch is released/refused by startup work

**Claim pinned.** The deferred process-context direct-space-state fetch is
released or refused by how much work the script forces at startup, not by the
fetch position, and on this host that is a **~100-line stochastic band**
(~475–575 lines), not a boundary. One generated probe source
(`_size_probe_body`) is spawned at two sizes in the same
`3d/run_on_separate_thread=true` project; the same `_run` body is refused at
25 lines and granted at 1025, both far outside the band. The same minimal
body in an **unthreaded** project is granted — so the gate needs the flag
*and* the small script. A fourth child is this fixture's own bare fetch at
the same position.

**Why a generated source, and why `_spawn_probe`.** The gate is a property of
the child script's own size, so the child cannot be this fixture — the arm
writes a probe into the child project dir and then delegates to
`_spawn_child`, keeping project generation, the bounded spawn, the stale-log
unlink and the error scan single-sourced (the r84 simplifier's V2 rule).

**Witness discipline — engine-level corroboration, carve-out deliberately
unused.** Every child here is a `jt_threaded`-style self-report, so each is
corroborated by the engine's own lines in its log, read through the new
`errs` key:

```
szminproj/child.log      ERROR: Space state is inaccessible right now, …   + CHILD_RESULT sz_fetch=refused   (errs=1)
szplainproj/child.log    CHILD_RESULT sz_fetch=granted                                       (errs=0)
szpadproj/child.log      CHILD_RESULT sz_fetch=granted                                       (errs=0)
szfxproj/child.log       CHILD_RESULT sp_fetch=granted                                       (errs=0)
```

The pin is `code == 0 ∧ verdicts == {key: value} ∧ errs.size() == expected`,
and for the refused child additionally `errs[0]` begins with
`ERROR: Space state is inaccessible`. `allow_inaccessible` is **false** for
all four, so an extra refusal at *any* callsite fails the arm instead of
hiding under the carve-out the r86 boundary seat showed to be both too wide
(§6.3 MX1/MX4) and too narrow (MX2/MX3).

**Determinism.** 4 children × 2 reps, both full-battery runs: all four
markers and all four child logs byte-identical (§6.2). Independent
pre-measurement: the generated pair was measured 3/3 per side (0 and 1000
padding) on `thr`, `jolt_thr` and `plain` before the arm was written.

---

## 2. `deferred_hang` — the aborted-coroutine class, bounded and named

**Claim pinned.** An unguarded deref of the refused fetch inside the deferred
`_run` coroutine aborts that coroutine before `quit()`; the `SceneTree` is
left with no exit condition and spins until the spawn bound kills it. The
same generated body, same size, same position, under **Dummy+threaded** is
the contrast: the silent floor grants every fetch, so it dereferences a real
handle and exits 0.

**The witness is process-level plus engine-level, never self-reported** — a
killed child cannot report anything:

```
hangproj/child.log   ERROR: Space state is inaccessible right now, wait for iteration or physics process notification.
                     CHILD_NOTE sz_deref pad=0 null=true
                     SCRIPT ERROR: Attempt to call function 'get_class' in base 'null instance' on a null instance.
                     …no CHILD_RESULT line at all
pin: code == 137 (HANG_RC) ∧ verdicts == {} ∧ errs.size() == 2
     ∧ one errs line is the refusal ∧ one errs line is the SCRIPT ERROR
hangdummyproj/child.log   CHILD_RESULT sz_abort=PhysicsDirectSpaceState3DDummy   (errs=0, code 0)
```

`rc` is the **only** detector for this class and the arm says so: the r86
boundary seat's §3.1 shows a SIGKILLed process emits no at-exit report, so
the leak scan — the fixture's mirror and `run_battery.py`'s `LEAKED_OBJECTDB`
— can never see the zombie RIDs. The r83 reviewer F2 `timeout -s KILL`
wrapper is kept (its bound is now a defaulted parameter, never removed), and
the 137 is measured through the same `/bin/sh -c` wrapper the fixture uses
(`OS.execute` returns the shell's `128+SIGKILL`, verified directly before
authoring).

**Bound.** `HANG_BOUND_S = 8`; a healthy child of this size exits in
~0.5 s, so the bound is a ~16× margin on the abort and the row lands at
8.7–8.8 s inside the harness's 20 s `CASE_TIMEOUT_SECONDS`. The hang itself
was pre-measured 3/3 at a 12 s bound and 3/3 at 8 s before the arm was
written; the boundary seat independently measured the class as
await-shape-independent (§3), so the arm keeps the `await physics_frame`
before the deref to match the *documented* shape (the stale refused handle
captured before the await, then dereferenced after it).

---

## 3. `backend_tier` — the area override inverts; `margin` is a Jolt-only parameter

**Claim pinned.** One sweep body (`_child_tier`) spawned under the three
generated projects — so a class difference can never be a code difference.
All three children are byte-identical across the two runs, and their maps are:

| arm | GodotPhysics (DEFAULT) | Jolt | Dummy |
|---|---|---|---|
| `area_override` | `honors` — body reads `(0,20,0)` / damp `2.0` | **`ignores`** — body keeps `(0,-9.8,0)` / `0.1` **while `area_get_param(GRAVITY)` reads back `20.0`** | `floor` |
| `margin` (0.0/0.04/0.5 on `cast_motion`) | `inert` — all three `[0.144531, 0.150391]` | **`binds`** — `[0.149841,0.150025] → [0.145996,0.146179] → [0.099854,0.100037]` | `empty` (`[]` ×3) |
| `sepray` | `same-signature` — data `{length:2.0,…}`, cast `[0.197266,0.203125]` | `differs-constants` — cast `[0.199829,0.200012]` | `floor` — data `nil`, type `2`, cast `[]` |
| `dss_class` | `GodotPhysicsDirectSpaceState3D` | `JoltPhysicsDirectSpaceState3D` | `PhysicsDirectSpaceState3DDummy` |

The area gravity/damping override is the new **`inverts`** class and the
first surface where Jolt is *less* capable than GodotPhysics rather than
differently tuned: the write lands (the area parameter reads back `20.0`) and
the effect does not. The `margin` split runs the other way — inert on
GodotPhysics, honoured by Jolt — which is exactly the "pinned-constant cell
with the inertness as the claim" shape the r86 scout's directive 1 asked for.
The Dummy child is armed for the **floor only**, per the boundary seat's
directive 5 (34 calls, 0 errors, no loud refusal anywhere under Dummy).

**Gating.** Both engine hints are checked first (`Jolt Physics`, `Dummy`);
absent means an honest `BLOCKED` row, never a fabricated split. All three
children run with `allow_inaccessible=false` and produce zero rejected lines.

---

## 4. `dummy_floor` — the silent floor as a class, with the refusal contrast

**Claim pinned.** The Dummy backend's floor is an 11-token signature, and the
identical body on a real backend is loud on the same two calls — so "silent
floor" can never be read as "refusal".

```
floordummyproj/child.log  CHILD_RESULT dummy_backend=Dummy
                          CHILD_RESULT dummy_floor=silent-floor     (errs=0, code 0)
floorrealproj/child.log   CHILD_RESULT real_backend=DEFAULT
                          CHILD_RESULT real_floor=real-values
                          ERROR: Parameter "space" is null.
                          ERROR: Invalid ID.                        (errs=2, code 0)
```

The signature tuple is `[rid0, nil, 2, rid0, 0.0, dummy, nil, nil, 0, rid0,
nil]`: `box_shape_create`/`space_create` → `RID(0)`, `shape_get_data` → `nil`,
`shape_get_type` → **`2`** (a wrong constant for a box, not a zero),
`space_get_param(SOLVER_ITERATIONS)` → `0.0`, `space_get_direct_state(RID())`
→ **non-null Dummy**, `body_get_state` → `nil`, `body_get_param` → `nil`,
`body_get_shape_count` → `0`, `body_get_shape(0)` → `RID(0)`,
`area_get_param(GRAVITY)` → `nil`. All eleven are compared as one
`PackedStringArray`, so a single drift reads `unexpected` and fails.

The two refusal-triggering calls are `space_get_direct_state(RID())` and
`free_rid(RID())` — the same two the boundary seat's 34-call sweep found
silent under Dummy and loud on a real backend. The real arm pins the count
(2) **and** both prefixes, so a third refusal at any callsite fails the arm.
The `dummy_class` NOTE key is untouched, as instructed (its rename stays
deferred).

---

## 5. Harness changes, and the two pins the boundary seat changed

Insertion-only, as measured by the prior-row diff (§6.1):

- `_spawn_child` gains two **defaulted** parameters — `script_res`
  (`"res://phys3d_events.gd"`) and `bound_s` (`30`) — and returns one
  additive key, `errs` (the list of lines its scan rejected). Existing call
  sites pass 4 arguments and read neither, so their behaviour and receipts
  are unchanged; the two threaded arms keep `allow_inaccessible=true` exactly
  as landed.
- `_spawn_probe` (new) writes a generated probe into the child project dir
  and delegates to `_spawn_child`; `_size_probe_body(pad)` (new) generates
  that probe; `_backend_name()` (new) is the three-way ClassDB gate used by
  the two new child bodies. `_child_split` keeps its own frozen two-way
  expression — its receipts are pinned and it never runs under DEFAULT — so
  `_backend_name` is a different predicate, not a duplicate of it.
- Child dispatch stays **total**: the new arms are added to the `match` ahead
  of the `var bad:` catch-all, and every new arm body terminates the process
  on every branch (`_fail`, `_exit_ok`, or a named `quit(1)`/`quit(2)`), per
  the boundary seat's directive 3 — this fixture has no global watchdog.

**Two pins changed after the boundary report landed (disclosed, not
silently absorbed):**

1. **`SIZE_PAD` 600 → 1000.** The scout's two-point sample had suggested a
   boundary; the boundary seat's 6-reps-per-point ladder showed a ~100-line
   **stochastic band** (~475–575 lines, 50 % near 500). A 625-line padded
   child would have sat only ~50 lines past the granted edge of a *race*.
   1025 lines sits ~450 lines past it, on the deterministic side, and 25
   lines sits ~450 below the refused edge. Direct support for the 1000-point
   before it was pinned: this seat's pre-measurement (3/3 on `thr`,
   `jolt_thr` and `plain`) plus the scout's `code1000`/`code2000` (2/2, 4/4).
   Directive 1 is also honoured in the wording: nothing in the arm or the
   README calls this a boundary, and the arm pins the release/refuse
   **outcome**, not the boundary seat's `pf` observable (this probe prints
   `pf` after its own await, so the two readings are not the same
   measurement — said so in the const comment rather than implying a
   correlation this seat did not reproduce).
2. **Every new arm now uses `allow_inaccessible=false` and pins exact
   engine-line counts.** The first draft used the carve-out for the refused
   children. The boundary seat's §6 shows the carve-out admits a forged line
   and rejects two sibling texts from the same gate family; the new cells are
   therefore corroborated by refusal *counts and prefixes* with no carve-out
   at all. The hang arm's conjunction (`rc 137` ∧ no marker ∧ the refusal
   line ∧ the abort line) is the strongest shape available for that class:
   the process-level `rc` corroborates the text, so the text alone cannot
   forge it.

**Deliberate non-refactor (simplifier input, not a claim).** The nine new
child-project bodies are inline string literals, matching the four the
r83–r85 arms already carry. A `_project_body(name, engine, threaded)` helper
would remove the repetition, but the existing four literals are frozen by
their pinned receipts, so a helper used only by the new arms would leave two
ways to write the same thing. The tradeoff is named here so a simplifier can
decide with the evidence rather than guess.

---

## 6. Behavioral evidence

### 6.1 Prior 191 rows are byte-identical, at identical positions

Pristine baseline built from `git archive HEAD` into `/tmp/r86base` (so it
cannot carry this seat's edits), run once: **191/191 PASS, rc 0, 3m13s**,
`verdicts.json` sha `84f90ff2cca41b90483a254ea52cca36c062da330a190dfb57a887aec6f15aa0`
(copied to `corpus/live/r86-author/pristine-baseline/`).

Both final runs were compared to it field-by-field over **11 fields × 191
rows** (`case`, `script`, `flags`, `expected_exit`, `actual_exit`, `kind`,
`marker`, `verdict`, `reasons`, `stdout`, `stderr`):

| run | cases | verdict | shared-row diffs | new rows |
|---|---|---|---|---|
| `final1/20261014T202932153128Z` | 195 | PASS (rc 0, 3m04s) | **0** | 4/4 PASS |
| `final2/20261014T203238679926Z` | 195 | PASS (rc 0, 3m03s) | **0** | 4/4 PASS |

Seed digests: 55 keys, **exactly 3 changed** (`README.md`,
`phys3d_events.gd`, `run_battery.py`) and the other 52 identical — no file
added, none removed. The four new rows are byte-identical between the two
runs (marker, stdout, stderr, exit).

**Superseded receipts were deleted, not left to be misread.** Four
intermediate runs preceded these two: an initial baseline that a mid-run
fixture edit invalidated (its own seed-digest guard turned it `FAIL`), a
clean 195/195 receipt from before the `SIZE_PAD` change, a run killed
mid-flight for the same reason, and a partial run started before the final
`SIZE_PAD` edit. All four were removed from `corpus/live/r86-author/`. The
receipts of record are the pristine baseline, `final1` and `final2`; every
sha this report cites is one of those three.

**"Insertion-only" stated exactly.** `git diff --numstat` is 682 insertions
against 8 deletions, and all 8 "deletions" are lines *replaced in place* by
their extended forms, never removed behaviour:

- `phys3d_events.gd` (7): the `_spawn_child` doc line and its continuation;
  the signature's `allow_inaccessible: bool) -> Dictionary:` line; the
  `selfpath := …("res://phys3d_events.gd")` line; the `cmd := ("timeout -s
  KILL 30 …")` line and its argument-array line; the `res := {…}` line. Each
  is the same statement with the new parameter or key threaded through.
- `README.md` (1): `191 registered cases (145 ordinary and 46` →
  `195 registered cases (149 ordinary and 46`.
- `run_battery.py`: **0** — the four rows are a pure append after the
  `srv_phase_delta` row.

No existing arm body, no `CASES` row, no `classify` rule and no existing
child body was edited, which is what the zero shared-row diff above measures
from the other side.

Prior child logs, `final1` vs `final2`: `joltproj` and `dummyproj`
byte-identical; `thrproj` and `joltthrproj` differ **only** in the scratch
run-dir path inside the GDScript backtrace (`…/final1/<ts>/scratch/…` vs
`…/final2/<ts>/scratch/…`), never in a verdict or a `CHILD_NOTE` field —
consistent with the r85 adjudicator's note that `jolt_threaded`'s child.log
is not byte-stable and the **map** is the witness.

### 6.2 The new cells are deterministic

Each new row's stdout, stderr and exit are byte-identical across the two
runs, and each new child log is byte-identical too (shas below, from
`final1`, pinned in `corpus/live/r86-author/manifest.sha256`):

| child log | sha256 (first 16) |
|---|---|
| `szminproj` | `14cda9b8e3f4b163` |
| `szplainproj` | `064d9bdfda54dfa3` |
| `szpadproj` | `1e7ede06d623d03d` |
| `szfxproj` | `863031c46bba63e9` |
| `hangproj` | `587aefa41655c0c1` |
| `hangdummyproj` | `02ce8a505fda0e78` |
| `tierplainproj` | `0c08e2e109a465e1` |
| `tierjoltproj` | `9ccc1ee5da913215` |
| `tierdummyproj` | `26cab28e282badea` |
| `floordummyproj` | `4cfd961bba126109` |
| `floorrealproj` | `bfa952c53bae455217` |

### 6.3 Mutation matrix — 9/9 load-bearing

`corpus/live/r86-author/mutate.py` (tooling, not a fixture): one authored
constant of one new arm per mutation, applied to a scratch copy, then the
arm run with that arm's own seeded expectation. **Every mutation is
detected**, and each drift message names the right child:

| # | mutation | arm | drift |
|---|---|---|---|
| M1 | `SIZE_PAD` 1000 → 0 (padded child becomes minimal) | `script_size_gate` | `pad_thr … sz_fetch=refused` |
| M2 | min_thr expected refusal count 1 → 0 | `script_size_gate` | `min_thr … errs=[the refusal]` |
| M3 | the unthreaded control project made threaded | `script_size_gate` | `min_plain … sz_fetch=refused` |
| M4 | `HANG_RC` 137 → 0 | `deferred_hang` | `exit=137 expected=0 … abort=true refusal=true` |
| M5 | hung-child `errs.size()` 2 → 3 | `deferred_hang` | `exit=137 expected=137 … errs=[2 lines]` |
| M6 | Jolt `area_override` pin → `honors` | `backend_tier` | `jolt drift … "jolt_area_override": "ignores"` |
| M7 | Dummy `margin` pin → `binds` | `backend_tier` | `dummy drift … "dummy_margin": "empty"` |
| M8 | real-backend refusal count 2 → 3 | `dummy_floor` | `real-backend refusal drift … errs=[2 lines]` |
| M9 | floor signature shape-type `2` → `3` | `dummy_floor` | `dummy drift … "dummy_floor": "unexpected"` |

M1 and M3 are the load-bearing pair for the claim's two halves (size and
threading); M2/M5/M8 are the load-bearing pins for the engine-level
corroboration this round's witness discipline demanded; M6/M7/M9 show the
child classifiers themselves are real rather than restating their own inputs.

The harness's own `--probe-failing` adversarial probe was also re-run on a
subset including two of the new rows
(`--only body3d_contact,phys3d_events_script_size_gate,phys3d_events_dummy_floor`):
3/3 PASS, mutant detected, `seeds_unchanged=true`.

---

## 7. The OPTIONAL nav seed: **not landed** — the pre-measured witness does not replicate

The assignment offered one cell from the nas-scout's §9 Cell A
(`navagent3d_set_velocity_inert`) "if clean". This seat built it — a
single-file fixture with an inner `Driver extends Node3D` (the `PPQueries`
pattern, so no extra driver file), map/region/mesh authored in script, three
arms (node setter / server RID / forced) — and measured it **before** writing
any tracked file. It is **not clean**, and it is not landed.

**The server half replicates exactly.** Node-setter writes never reach the
server (`srv_vel` all `(0,0,0)` while `node_vel=(2,0,0)`); the same agent's
RID written directly lands from the next read onward (`(0,0,0)` then
`(2,0,0)` ×9, `same_tick_srv=(2,0,0)`); `agent_set_velocity_forced` is inert;
`in_map=true`, `avoidance_enabled=true`, `has_cb=true`, `srv_pos=(0.5,0,2)`
correct. Deterministic: 3/3 byte-identical full-file sha.

**The witness the cell is built on does not replicate.** Cell A's
discriminating field is `last_safe`, delivered by `velocity_computed`. In
this seat's harness that signal **never fires** (`safe_n=0`, `TAIL_SAFE []`)
for all three arms. That is not a harness defect: the scout's **own probe,
byte-identical to its pinned manifest entry**
(`probe_nav_node_rid.gd` sha `68f0b843…`, driver sha `1c6a60ff…`), re-run
here gives `safe_n=0` in **8/8** fresh processes (6 plain, 2 under
`taskset -c 0` to emulate a slow/loaded host) — against its own receipt
`corpus/live/nas-scout/runs/p6/nav_node_rid.stdout.txt`, which records
`safe_n=10` and `TAIL_SAFE [(2,0,0) ×10]` for the same source.

So the cell's central witness is **unreproducible on this host today**, and
the assignment's condition ("one cell if clean") is not met. Landing it would
have shipped a flaky row whose failure a future seat would misread as a
physics regression. Recorded instead: **the nas-scout's Cell A is
pre-measured but not yet reproducible; its `last_safe` pins must be
re-derived before any r87 author arms it, and the honest sub-claim available
today is the server-side one only** (the RID push lands, the node setter does
not — both 8/8 deterministic). This is the same class of hazard the seat card
names: a self-report witness that no second seat corroborated.

Everything for that investigation is pinned in
`corpus/live/r86-author/nav-replication/`: byte-identical copies of both
scout probes (shas matching `corpus/live/nas-scout/manifest.sha256`), two
saved re-run logs, and `RERUN.md` with the exact command. The generated-probe
prototypes are in `corpus/live/r86-author/proto/`; the nav fixture prototype
lives in `/tmp/r86v/scratch/navproto*.gd`, which is outside the repo and
therefore **not** pinned — the reproducible evidence for the finding is the
`nav-replication/` tree, not the prototype.

---

## 8. Remaining risks, unresolved, blockers

- **The band is stochastic; this seat's pins are on the deterministic
  sides, but that is a two-point argument.** 25 lines (refused) and 1025
  lines (granted) are ~450 lines clear of the boundary seat's refused and
  granted edges, and both sides were measured 3/3 before pinning — but no
  seat has measured 1025 lines specifically. If a future round moves
  `SIZE_PAD`, re-measure it repeated, not once (directive 1).
- **`HANG_BOUND_S = 8` is a wall-clock bound inside a 20 s case timeout.**
  It is a ~16× margin on a 0.5 s healthy child, but on a much slower or
  heavily loaded host the child could be killed before it reaches the abort,
  which fails the arm with `abort=false` — a **named** failure, not a silent
  one, and the drift message prints the log lines it did see.
- **The hang arm's class claim is one backend pair.** It pins
  DEFAULT+threaded (hangs) vs Dummy+threaded (grants). The boundary seat
  measured the class as backend- and await-shape-independent; this arm does
  not re-derive that, it cites it.
- **`area_override` `honors`/`ignores` rests on two floats and a vector
  compared with `is_equal_approx` + `1e-4`.** The measured values are exact
  (`(0,20,0)`/`2.0` vs `(0,-9.8,0)`/`0.1`) and byte-stable across both runs,
  so the tolerances are not load-bearing today; a Jolt solver-constant change
  would show as `unexpected`, not as a false `ignores`.
- **The `margin` `binds` classifier requires strict monotonicity** across
  the three margin values. That is the measured order on this build; a Jolt
  change that flattened it would read `unexpected` rather than silently
  passing.
- **Nine new inline project-body literals** (see §5) — a disclosed
  simplifier tradeoff, not a defect.
- **The tree moved under this seat, and this seat moved under its siblings.**
  The boundary seat snapshotted an earlier revision of this diff (1831 lines,
  sha `eab0fae1…`) mid-write; its findings are scoped to the HEAD fixture
  (1262 lines, sha `23bb2e27…`), so nothing in its report contradicts the
  landed revision. The landed revision is `66c92c38…` (1870 lines).
- **No blockers.** All four assigned phys3d cells landed and verified; the
  optional nav cell is a measured non-replication, not a blocker.

---

## 9. Files changed

| file | change | tracked |
|---|---|---|
| `corpus/fixtures/phys3d_events.gd` | +4 parent arms, +3 child bodies, +2 helpers, +3 consts, `_spawn_child` gains `script_res`/`bound_s`/`errs`, header contract extended | modified (insertion-only) |
| `corpus/fixtures/run_battery.py` | +4 `CASES` rows appended (191 → 195) | modified (insertion-only) |
| `corpus/fixtures/README.md` | count 191/145 → 195/149; new r86 section | modified (coupled to the rows) |
| `reports/round-86/r86-author.md` | this report | new, untracked |
| `corpus/live/r86-author/**` | prototypes, mutation tool, pristine baseline receipt, both final receipts, both runs' child logs, nav replication, `manifest.sha256` (360 pinned files; `*.log` excluded from the manifest) | gitignored (`corpus/.gitignore:1`) |

Not committed — the integrator commits.
