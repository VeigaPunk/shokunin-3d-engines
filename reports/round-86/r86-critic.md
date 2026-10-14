# game-dev-3d round 86 — critic (seat: critic, host: devin) — attack on `4e65726`

Wave `shokunin-train-20261101-w17`, lane g3d. Assignment (`tasks/g3d-critic.md`,
verbatim):

> r86 CRITIC (g3d) — attack commit 4e65726 (4 arms: script_size_gate,
> deferred_hang, backend_tier, dummy_floor; 191->195). Read
> reports/round-86/{r86-author,r86-boundary,r86-scribe}.md. Boundary already
> proved the `allow_inaccessible` whitelist is substring-only (MX4) and extra
> illegal accesses pass (MX1). Hunt the new arms: script_size_gate band
> testability / size-padded gaming / two-point ladder; deferred_hang
> unrelated-rc137 and abort-path proof; backend_tier tolerance bands and Dummy
> specificity; dummy_floor 11-token signature and real-backend failure. Mutate
> probes + replays; prior 191 rows byte-identical check.

This seat attacks; it does not judge, admit, edit fixtures, commit, or ship.
**Zero tracked files were modified** (`git status --porcelain` shows only the
sibling's untracked `reports/round-86/r86-baseline.md`); every write landed
under `corpus/live/r86-critic/` (`corpus/.gitignore:1`).

**Runtime (every bound below is scoped to this):** `/usr/bin/godot`
`4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`, 60 tps, 32 cores, at HEAD
`4e65726` (`phys3d_events.gd` sha `66c92c38c9a1e0e981b3b2d6c871dbd3fc63c0b14fc646d2f62da047f1e14296`,
`run_battery.py` sha `e2df9f966d00c5637e051946c2c28e56ab629161e8f437d8648437aa0fdc69e4`,
both verified against `git show 4e65726:`).

**The machine was NOT idle.** Sibling `r86-reviewer`, `r86-verifier`,
`r86-baseline` and `r86sim` battery runs were live for the whole of this seat
(measured: `pgrep` shows their `run_battery.py` process trees). Every
timing-sensitive claim below is therefore either interleaved A/B/A inside one
sequence (§1.1) or a within-session contrast that the load can only push the
*wrong* way. This is recorded, not corrected for.

**LSP unavailability recorded.** `mcp_list_servers` exposes no `lsp` device for
this repo (same as every r85/r86 sibling lane). No symbol operation was needed:
the work is measurement and text substitution, and the substitutions are
validated by the engine's own compiler (`Parse Error` at load, caught below).

---

## 0. Verdict summary

Five attacks landed; two of them make a landed arm **pass while its named claim
is false or unproven**. Nothing found makes a landed arm *silently* accept a
false physics verdict — the arms are tighter than the r85 cells in that respect.

| # | arm | counterexample | outcome | class |
|---|---|---|---|---|
| **A1** | `deferred_hang` | fetch deref guarded; an **unrelated** null call aborts the deferred coroutine | arm **PASSES** | fixable defect |
| **A2** | `deferred_hang` | contrast child hangs | case reports `TIMEOUT after 20 seconds`, no drift, orphan survives the case kill | fixable defect |
| **A3** | `script_size_gate` | 1000 statements in an **uncalled** function (zero startup work) | releases the fetch 7/7 → the named mechanism is false | fixable defect (wording) |
| **A4** | `script_size_gate` | probe that **never fetches**, prints the refusal text itself | arm **PASSES** | fixable defect (witness claim) |
| **A5** | `dummy_floor` | contrast project sets `physics/3d/solver/solver_iterations=8` | arm FAILS, message blames *refusals* | fixable defect (brittle pin + misattribution) |

Verified sound (no false pass found, with the mutation that would have exposed
one): `backend_tier`'s tolerance bands and backend identity (M6/M7), and
`dummy_floor`'s real-backend failure path (M2).

---

## 1. `script_size_gate` — the cell is sound, the claim attached to it is not

### 1.1 The named independent variable is false (A3)

**Counterexample.** The landed pad is `var vN := N` at file scope, and the arm
comment plus README say the fetch is "released or refused by how much work the
script **forces at startup**". A generated probe of the landed shape whose
1000 padding statements sit in a **function that is never called** — zero
startup work, zero runtime work — releases the fetch just as the landed pad
does.

**Evidence** (`corpus/live/r86-critic/{size-ladder2.json,ab-interleave.json}`,
probe `probes/size_ladder2.py`, same threaded project, same `_run` body, same
fetch position, 1000-statement pad in every variant):

| variant | lines | pad is | fetch | `pf` |
|---|---|---|---|---|
| `v0_min` | 16 | — (the landed `min_thr` shape; my template is 9 lines shorter) | **refused** 4/4 | 1 |
| `v1_comment` | 2016 | 1000 `#` + 1000 blank lines | **refused** 4/4 | 1 |
| `v2_const` | 1016 | 1000 file-scope `const cN := N` | granted 4/4 | 2 |
| `v3_var` | 1016 | 1000 file-scope `var vN := N` (**landed**) | granted 4/4 | 2 |
| `v5_postinit` | 1016 | 1000 stmts in `_initialize` **after** `call_deferred` | granted 4/4 | 2 |
| `v6_runpad_pre` | 1016 | 1000 stmts in `_run` **before** the fetch | granted 4/4 | 2 |
| `v7_runpad_post` | 1016 | 1000 stmts in `_run` **after** the fetch | granted 4/4 | 2 |
| `v9_uncalled` | 1018 | 1000 stmts in an **uncalled function** | **granted 7/7** | 2 |

Interleaved A/B/A inside one sequence (the load control — `ab-interleave.json`):
`v0_min` refused 3/3, `v1_comment` refused 2/2, `v9_uncalled` granted 7/7,
`v3_var` granted 2/2. A session-wide load shift cannot produce that
alternation; the contrast is within-session.

Two consequences:

1. **The variable is statement count (work the compiler does), not work the
   script executes.** `v9` executes nothing and `v2` executes nothing at
   startup, yet both release the fetch; `v1` adds 2000 lines and 0 statements
   and does not. The generator's own comment already says the right thing
   ("the gate on compile work, not on line or byte count"); the arm comment and
   the README's `script_size_gate` bullet say the wrong thing.
2. **`v6 == v7`** (same file size, pad on opposite sides of the fetch) rules out
   the fetch's local context as the variable; **`v5`** (work after
   `call_deferred`, before the flush) rules out "work before the deferred call
   is queued". So the landed phrase "not by the fetch position" survives — the
   phrase that fails is "work the script forces at startup".

Whether the causal chain is *compile latency* or the *deferred-flush timing
that follows it* is **inference**, not measured here — this probe separates
neither. What is measured is which knob moves the outcome.

**Impacted axes:** claim accuracy / provenance (a landed fixture comment and a
README contract line state a mechanism the fixture's own generator can falsify);
the cell's *pin* is unaffected (it pins outcomes, and it stayed 5/5 PASS under
load, §1.3).

**Smallest safe correction:** reword one clause in the `script_size_gate` arm
comment (`phys3d_events.gd:1052-1055`) and one in README's `script_size_gate`
bullet — "how much work the script forces at startup" →
"how many statements the script contains (the pad is statement count, not lines
or bytes: an uncalled function body releases the fetch too)". No behaviour
change, no re-pin.

### 1.2 The "engine corroboration" is a text match in a merged stream (A4)

**Counterexample.** The arm's witness discipline (§1 of the author report:
"each is corroborated by the engine's own lines in its log") is not engine
provenance. `_spawn_child` merges the child's streams with `2>&1`
(`phys3d_events.gd:283-284`), so a line the *child itself* prints is
indistinguishable from an engine `ERROR`. A generated probe that sets
`var d = null` — **no fetch at all** — and prints the refusal text itself
passes the whole arm.

**Evidence** (`mutations.json` → `M4_size_gate_forged_probe`): the only fixture
edit is the generator's fetch/`refused` pair, replaced by a null literal, a
threading read and a self-printed refusal. Battery, through the harness's own
classifier:

```
PASS phys3d_events script_size_gate min_thr=refused min_plain=granted pad_thr=granted fixture_thr=granted child_exit=0
```

and the forged `szminproj/child.log` differs from the landed one **only** by the
three engine lines the scan ignores:

```
<    at: space_get_direct_state (modules/godot_physics_3d/godot_physics_server_3d.cpp:194)
<    GDScript backtrace (most recent call first):
<        [0] _run (res://szprobe.gd:15)
```

So the r86 change that dropped the `allow_inaccessible` carve-out
("corroborated by refusal *counts and prefixes* with no carve-out at all")
narrowed **which texts count**, not **who wrote them**. This is the r86
boundary seat's MX4 class, inherited unchanged by a cell that cites MX4 as its
reason for existing. The `errs.size() == 1` + prefix pin is a *stricter string
match*, not a stronger witness.

**Impacted axes:** witness provenance. The residual risk is low *today* — the
probe source is generated by the fixture, so a forgery cannot appear by
accident — but the claim in the report, the fixture comment and the README
outruns the mechanism.

**Smallest safe correction:** the landed refused log carries the engine's
`at: space_get_direct_state (…cpp:194)` line and the forgery does not; require
it in the `min_thr` conjunction (one term, next to the existing prefix check),
and state the limit in the README bullet ("the child log is a merged stream:
these pins corroborate shape and count, never provenance"). Structural
separation (`2>` to a second file) is a **tradeoff**, not a correction — the
`2>&1` merge is deliberate so that every engine line keeps its position
relative to its `STEP`/`CHILD_*` marker.

### 1.3 What the two-point ladder does and does not witness

- **It does witness monotone release with statement count** at two points ~1000
  statements apart, plus the threading control and the fixture's own child.
  Landed arm, 5/5 PASS under load, `min_thr` refused at `pf=1` and `pad_thr`
  granted at `pf=2` in every rep — the boundary seat's `pf` correlation
  reproduces on the landed fixture, and in my own ladder it holds **46/46**
  (32 runs in `size-ladder2.json` + 14 in `ab-interleave.json`), no exception:
  `refused ⟺ pf=1`, `granted ⟺ pf=2`.
- **It does not witness a boundary, and cannot.** Both points sit ~450
  statements clear of the cited band and no rep is taken inside it, so the pin
  is consistent with a boundary anywhere in `(25, 1025)`. The band is *cited*
  from the r86 boundary seat, and the author discloses this in §8 ("that is a
  two-point argument"). **Tradeoff, disclosed, not a defect** — but the cell's
  name and its marker (`min_thr=refused … pad_thr=granted`) should not be read
  as a band measurement, and the fixture comment should keep saying "band" only
  where it cites the boundary seat (it does).
- **"Can a size-padded script game the cell?"** Two answers, both measured:
  yes by *shape* (A3 — any statement-count pad, including dead code, satisfies
  the pin while falsifying the named mechanism), and yes by *witness* (A4 — a
  probe that never fetches satisfies it). The pin is an outcome pin; it is not
  a mechanism pin and cannot be made into one without sampling the band.

---

## 2. `deferred_hang` — the pin does not localize the abort, and the contrast child's bound is the wrong way round

### 2.1 Any script error in the deferred coroutine satisfies the pin (A1)

**Counterexample.** The pin is
`code == 137 ∧ verdicts empty ∧ aborted ∧ refused ∧ errs.size() == 2`, where
`aborted` is set by `"SCRIPT ERROR" in line`
(`phys3d_events.gd:1144-1148`). Nothing in the pin ties the abort to the fetch
deref. Guard the deref, add an unrelated null call, and the arm still passes.

**Evidence** (`mutations.json` → `M1_hang_unrelated_abort`). The only fixture
edit is inside `_size_probe_body`'s deref branch: `d.get_class()` is replaced by

```gdscript
if refused:
    var zz = null
    zz.get_class()
prints("CHILD_RESULT sz_abort=%s" % d.get_class())
```

so when the fetch was refused the abort is `zz`, never `d`. Battery result:

```
PASS phys3d_events deferred_hang threaded_rc=137 abort=true no_marker=true dummy_rc=0 floor_no_hang=true child_exit=0
```

with the mutated `hangproj/child.log` differing from the landed log exactly at
the abort, in both text and line:

```
< SCRIPT ERROR: Attempt to call function 'get_class' in base 'null instance' on a null instance.
<           at: _run (res://szprobe.gd:20)
> SCRIPT ERROR: Invalid call. Nonexistent function 'get_class' in base 'Nil'.
>           at: _run (res://szprobe.gd:22)
```

The Dummy contrast child is byte-identical to the landed one
(`CHILD_RESULT sz_abort=PhysicsDirectSpaceState3DDummy`), so the pair the arm
compares is unchanged. The arm proves *"an abort inside the deferred coroutine
abandons it and the tree has no exit condition"* — a real and useful class — but
not the sentence it is named and documented for, "the refusal **that caused the
abort**" (README `deferred_hang` bullet).

**Impacted axes:** witness strength / class localization. A future refactor that
guards the deref and introduces any other runtime error keeps the cell green
while the class it pins has changed.

**Smallest safe correction:** add one conjunction term to the same loop — the
abort line must carry the landed abort text, e.g.
`if "SCRIPT ERROR" in line and "base 'null instance'" in line: aborted = true`.
The mutant above (`base 'Nil'`) is rejected by that term and the landed child is
not. Cost: one re-run of the arm (8.8 s).

### 2.2 The contrast child's bound exceeds the case timeout (A2)

**Counterexample.** The expected-hang child is spawned with
`bound_s = HANG_BOUND_S = 8`; the Dummy contrast child is spawned with the
**default 30** (`phys3d_events.gd:1138-1139` vs `:1134-1135`). Worst case
`8 + 30 = 38 s` inside `CASE_TIMEOUT_SECONDS = 20`
(`run_battery.py:36`). When the contrast child hangs, the arm's own drift
message never runs.

**Evidence** (`mutations.json` → `M3_hang_contrast_child_hangs`; the contrast
project simply drops `3d/physics_engine="Dummy"`, so it runs DEFAULT+threaded
and behaves like the hung child):

| | value |
|---|---|
| `hangproj/child.log` | refusal + `Attempt to call function 'get_class' in base 'null instance'` |
| `hangdummyproj/child.log` | **byte-identical** to `hangproj` (both hung) |
| case verdict | `FAIL`, `error = "TIMEOUT after 20 seconds"`, `actual_exit = null`, stdout empty |
| elapsed | 20.023 s |

The same failure path was captured live by the accidental first M1 run, whose
`godot_alive_after` snapshot — the **first `M1_hang_unrelated_abort` record in
`mutations.json`**, which is its surviving evidence because the second M1 run
overwrote that run directory — shows the contrast child **still running** at the
moment the battery recorded the verdict (4 lines of the process tree, quoted
verbatim):

```
3383275 sh -c -- "/bin/sh" "-c" "timeout -s KILL 30 "/usr/bin/godot" --headless --path
        ".../scratch/hangdummyproj" --script ".../hangdummyproj/szprobe.gd" -- --child --arm=deref
        > ".../hangdummyproj/child.log" 2>&1"
3383277 timeout -s KILL 30 /usr/bin/godot --headless --path .../hangdummyproj ...
3383278 /usr/bin/godot --headless --path .../hangdummyproj ...
```

That is the r83 reviewer F2 orphan class: the `timeout -s KILL 30` bound the
reviewer added is what keeps the orphan finite, and 30 > 20 means the orphan
outlives the case by up to ~18 s — and the *next* battery case runs while it
does. The author's own §8 names the opposite risk ("the child could be killed
before it reaches the abort … a **named** failure") and that risk is indeed
named; this one is not, because the bound that is wrong belongs to the child
that is not expected to hang.

**Impacted axes:** diagnosability (a row that says `TIMEOUT` instead of naming
the child), orphan hygiene.

**Smallest safe correction:** pass the arm's own bound to the contrast spawn —
`_spawn_probe("hangdummyproj", hang_dummy, "szprobe.gd", hang_body, "deref", false, HANG_BOUND_S)`
— making the arm's worst case `8 + 8 = 16 s` inside the 20 s case timeout, and
the orphan window 0.

---

## 3. `backend_tier` — tolerances are not the weakness; identity is genuine

**Question asked:** are the tolerance bands wide enough to pass a wrong backend?
**Measured answer: no — a wrong backend fails on five independent tokens.**

**Evidence** (`mutations.json` → `M6_tier_jolt_falls_back`,
`M7_tier_dummy_falls_back`). Making the Jolt child's engine name bogus (a
silent fallback to GodotPhysics, measured in §4.1) or the Dummy child's bogus
turns the whole map into the GodotPhysics map:

```
ERROR: phys3d_events: backend_tier jolt drift exit=0 serr=false v={
  "jolt_backend": "DEFAULT", "jolt_dss_class": "GodotPhysicsDirectSpaceState3D",
  "jolt_area_override": "honors", "jolt_margin": "inert", "jolt_sepray": "same-signature" }
```

The verdict maps are compared for **exact equality**
(`phys3d_events.gd:1226-1227`), so identity, dss class and all three
behavioural classes must hold at once.

Band arithmetic from the landed logs, for the record:

| class | tolerance | measured separation | ratio |
|---|---|---|---|
| `margin` `inert` vs `binds` | `< 1e-4` | 0.003845 (m0→m0.04), 0.046142 (m0.04→m0.5) | 38×, 461× |
| `sepray` `same-signature` vs `differs-constants` | `< 1e-4` | 0.002563 | 26× |
| `area_override` `honors` vs `ignores` | `is_equal_approx` (≈1e-5·20 = 2e-4 on `g_y`) | `(0,20,0)`/`2.0` vs `(0,-9.8,0)`/`0.1` — separated by the physics, not by the tolerance | n/a |

Two residuals, both *false-failure* rather than false-pass, both low severity:

- **`ignores` hardcodes the project defaults.** `base_g ≈ (0,-9.8,0)` and
  `|base_d - 0.1| < 1e-4` (`:1742-1744`) pin the engine's default gravity
  vector and default linear damp. A host or engine-default change reads
  `unexpected` → named FAIL. The child project sets no gravity, so this is
  an inherited engine default, not a cell constant.
- **`sepray`'s class names overstate the classifier.** `same-signature` /
  `differs-constants` are the r84/r85 vocabulary for a whole-tuple comparison;
  this classifier reads `sep_cast[0]` only (`:1800-1804`). The ray's *data*
  signature (`{"length":2.0,…}` vs `nil`) is printed in a `CHILD_NOTE` and
  never classified. The README wording ("keeps the edge on different solver
  constants") is accurate; the class names are inherited, not re-derived.

**Impacted axes:** claim vocabulary (minor). **Smallest safe correction:** none
required; if the class names are kept, note in the child comment that
`same-signature` here means "the pinned `cast_motion` constant", not the r84
tuple signature.

---

## 4. `dummy_floor` — the real-backend path is sound; the contrast pins two engine defaults

### 4.1 It does fail when the engine gets a real backend (verified)

**Question asked:** does the arm fail if the engine gets a REAL backend?
**Measured answer: yes, with a named and informative drift.**

**Evidence** (`mutations.json` → `M2_floor_real_backend`). Making the Dummy
child project's engine key bogus (`"DummyX"`) — measured in
`backend-identity.json` to fall back to GodotPhysics **silently, with no
warning on either stream** — gives:

```
ERROR: phys3d_events: dummy_floor dummy drift exit=0 v={
  "dummy_backend": "DEFAULT", "dummy_floor": "real-values" }
  errs=["ERROR: Parameter \"space\" is null.", "ERROR: Invalid ID."]
```

So the Dummy child is caught by *both* the identity token and the floor
signature. `backend_tier`'s Dummy child has the same two tokens in its expected
map and fails identically (M7). **No false pass.**

### 4.2 Backend identity rests on `_backend_name()`, and it is genuine

**Evidence** (`probes/backend_identity.py`, `backend-identity.json`; five
generated projects, one run each):

| project | `PhysicsServer3DDummy` | `JoltPhysicsServer3D` | `GodotPhysicsServer3D` | `_backend_name()` | `direct_space_state.get_class()` |
|---|---|---|---|---|---|
| default | false | false | true | `DEFAULT` | `GodotPhysicsDirectSpaceState3D` |
| `"Jolt Physics"` | false | true | false | `Jolt Physics` | `JoltPhysicsDirectSpaceState3D` |
| `"Dummy"` | true | false | false | `Dummy` | `PhysicsDirectSpaceState3DDummy` |
| `"DummyX"` (bogus) | false | false | true | `DEFAULT` | `GodotPhysicsDirectSpaceState3D` |
| `"dummy"` (lowercase) | false | false | true | `DEFAULT` | `GodotPhysicsDirectSpaceState3D` |

The trio is exclusive **per resolved engine** on this build, and the resolved
engine is what the registration reflects (the bogus and lower-case names
resolve to DEFAULT). The comment's claim ("Exactly one member of the ClassDB
trio exists per generated project on this build") is therefore a measured host
property, correctly scoped to "on this build", and it is the linchpin the r86
backend pins actually stand on. It holds here. Note also that a mis-set engine
name is silent on both streams, so the `*_backend` token is the *only* signal
for that failure mode — which is why M2/M6/M7 matter.

### 4.3 The 11-token signature is a *floor* class, not a *Dummy* class

**Question asked:** is any token satisfiable by a non-Dummy backend?
**Answer: yes — nine of the eleven are generic-empty, and the one named
`dummy` is a null check.**

Landed tokens (`final1-children/{floordummyproj,floorrealproj}/child.log`):

```
dummy: ["rid0","nil","2","rid0","0.0","dummy","nil","nil","0","rid0","nil"]
real:  ["rid","v3","3","rid","16.0","nil","xform","value","1","rid","value"]
```

- tokens 0,1,3,4,6,7,8,9,10 are `nil` / `0` / `rid0` / `0.0` — the **empty
  floor**: any backend that silently answers with empty values satisfies them;
- token 5 is `"dummy" if dss_rid0 != null else "nil"` (`:1850`) — a hardcoded
  literal produced by a **non-null check** on `space_get_direct_state(RID())`.
  It names a backend it never inspects. Today only Dummy answers there, so it
  discriminates; a future silent backend answering `RID(0)` would produce the
  same token;
- token 2 is `str(shape_type)` = `"2"` for a box (a wrong constant, not a
  zero) — weakly characteristic but not Dummy-specific.

So the Dummy identity of the cell comes from `dummy_backend=Dummy` (ClassDB,
§4.2), not from the signature. Both the fixture comment and the README describe
the token semantics accurately ("a direct state comes back for any argument
including `RID(0)`"), so this is a **label** issue, not a false claim.
**Smallest safe correction (optional, re-pins both token lists):** make token 5
carry the class — `str(dss_rid0.get_class())` — so the signature itself
witnesses the backend instead of a hardcoded literal.

### 4.4 The real-backend contrast pins two engine defaults, and misattributes the failure (A5)

**Counterexample.** `real_sig` (`:1860-1861`) contains `"16.0"` — the value of
`space_get_param(SPACE_PARAM_SOLVER_ITERATIONS)` on a **fresh space**, i.e. the
project/engine default — and `"3"`, the box shape type. Neither is part of the
Dummy-floor claim. Setting the contrast project's
`physics/3d/solver/solver_iterations=8` (a legitimate project setting; measured
directly: the fresh-space param moves `16.0 → 8.0`) fails the cell.

**Evidence** (`mutations.json` → `M5_floor_real_solver_default`):

```
real_floor tokens=["rid", "v3", "3", "rid", "8.0", "nil", "xform", "value", "1", "rid", "value"]
CHILD_RESULT real_floor=unexpected
ERROR: phys3d_events: dummy_floor real-backend refusal drift exit=0 v={
  "real_backend": "DEFAULT", "real_floor": "unexpected" }
  errs=["ERROR: Parameter \"space\" is null.", "ERROR: Invalid ID."]
```

Every Dummy-floor pin is intact, both refusals are intact, and the message
still says **"real-backend refusal drift"** — a future seat would read that as
"the real backend's refusals changed" and hunt in the wrong place.

**Impacted axes:** false failure (brittle pin) + failure-message provenance.
**Smallest safe correction:** token 4 records the *class* of the value, not the
default — `"num" if space_param != null else "nil"` — keeping the contrast
(Dummy: null; real: a number) while dropping the engine default from the pin.
Cost: one re-pin of both token lists.

---

## 5. Prior 191 rows — the insertion-only claim reproduces

**(a) The author's receipts re-derive clean.** Re-derived from the receipts' own
bytes (`case, script, flags, expected_exit, actual_exit, kind, marker, verdict,
reasons, stdout, stderr`):

| receipt | rows | shared with pristine baseline | differing fields | new rows | 191-row tuple sha |
|---|---|---|---|---|---|
| `pristine-baseline` (`3d42f77`, `23bb2e27…`) | 191 | — | — | — | `517941ef0c264de4` |
| `final1/…202932153128Z` | 195 | 191 | **0** | 4/4 PASS | `517941ef0c264de4` |
| `final2/…203238679926Z` | 195 | 191 | **0** | 4/4 PASS | `517941ef0c264de4` |

(`final3/…203541779814Z` is the `--probe-failing` subset run, `--only
body3d_contact,phys3d_events_script_size_gate,phys3d_events_dummy_floor`, not a
superseded battery receipt — it is in the author's `manifest.sha256` and matches
the report's §6.3 sentence. No undeclared receipt was left behind; the report's
"four superseded receipts were deleted" holds for the battery receipts.)

**(b) Independent replay.** This seat re-ran the full 195-case battery at
`4e65726` from the committed bytes into
`corpus/live/r86-critic/replay/20261014T204201435300Z/` (`replay.log`), on the
loaded host described in §0, and compared the 191 shared rows against the
pristine baseline receipt field-by-field: **195/195 PASS, rc 0, 0 differing
fields across the 191 shared rows, tuple sha `517941ef0c264de4` on both sides,
`seeds_unchanged: true`, fixture sha `66c92c38…`, and all four new rows
`exit 0 / PASS`.** Details in §6.

---

## 6. Replay result

**Run:** `python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot --runs
/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r86-critic/replay`
at HEAD `4e65726`, started 20:42:01Z, finished under the four sibling battery
runs of §0.

**Receipt:** `corpus/live/r86-critic/replay/20261014T204201435300Z/verdicts.json`
(`replay.log` beside it; `EXIT=0`).

| measure | value |
|---|---|
| totals | `cases=195 pass=195 fail=0 ordinary=149 negative_controls=46 probes=0` |
| battery verdict | `PASS battery`, rc 0 |
| shared rows vs `pristine-baseline` | 191 |
| differing fields (11 fields × 191 rows) | **0** |
| 191-row tuple sha (replay / pristine) | `517941ef0c264de4` / `517941ef0c264de4` |
| four new rows | `script_size_gate`, `deferred_hang`, `backend_tier`, `dummy_floor` all `exit 0 / PASS` |
| `seeds_unchanged` | true |
| `seed_digests["phys3d_events.gd"]` | `66c92c38c9a1e0e981b3b2d6c871dbd3fc63c0b14fc646d2f62da047f1e14296` (the committed fixture) |
| `case_timeout_seconds` | 20 |

The insertion-only claim is therefore independently reproduced on the committed
bytes, and — because the host was loaded for the whole run — the two new
time-bound arms (`script_size_gate`'s 4 children, `deferred_hang`'s 8 s bound)
survived a *contended* host, which is the harder direction for them. The
`deferred_hang` row's own fragility (§2.2) is in its *failure* path, which this
run did not exercise.

---

## 7. What this seat did not find, and its limits

- **No false *physics* verdict.** Every mutation that should have been caught
  was caught (M2, M5, M6, M7); no mutation of a physics constant passes
  silently. The defects above are about the *class-localization* and
  *mechanism* claims, and about failure diagnostics — not about accepting a
  wrong engine result.
- **`backend_tier`'s `honors`/`ignores`/`floor` are behaviour classes, not
  identity classes.** They are pinned *together with* the identity token, so
  the pair is sound; read alone, `floor`/`empty`/`inert` are absence classes
  that a broken real backend could also produce (it would then fail the pin,
  not pass it).
- **`BLOCKED …` + `quit(1)` is classified as a plain FAIL** — `run_battery.py`
  has no BLOCKED kind (`grep BLOCKED` → no hits). The two new gated arms extend
  an existing r84/r85 host dependency (four `BLOCKED` sites predate this
  commit) rather than introducing one, but the README wording "absent means
  `BLOCKED`" describes an exit-1 FAIL on a Jolt-less or Dummy-less host.
- **Not measured here:** the band's shape (cited from the boundary seat; my
  ladder only samples the deterministic sides), the `v8` variant (my own
  generator bug — pad emitted twice — reported for completeness as rc 1, not
  used for any claim), the `--probe-failing`/crash/stream/tree probes (the
  author's `final3` covers the first; my replay did not re-run them), and
  `jolt_threaded`'s child-log byte-stability (the author's own §6.1 says the
  map, not the bytes, is the witness — consistent with r85).
- **Load caveat.** The host was loaded for the whole seat (§0). The two new
  time-bound arms are the only load-sensitive rows; the replay passed them, and
  the landed `script_size_gate` arm was additionally 5/5 PASS in a dedicated
  loop.

---

## 8. Evidence

| path | what |
|---|---|
| `corpus/live/r86-critic/probes/size_ladder.py` | round-1 ladder (format-string bug in my probe, verdicts valid) |
| `corpus/live/r86-critic/probes/size_ladder2.py`, `size-ladder2.json` | the 9-variant ladder, 4 reps |
| `corpus/live/r86-critic/probes/ab_interleave.py`, `ab-interleave.json` | interleaved A/B/A load control, 14 runs |
| `corpus/live/r86-critic/probes/backend_identity.py`, `backend-identity.json` | ClassDB trio + `_backend_name()` per project |
| `corpus/live/r86-critic/probes/mutations.py`, `mutations.json` | M1–M7, each driven through `run_battery.py --only`; the M1/M4 first attempts and the first-M1 orphan capture are records here |
| `corpus/live/r86-critic/mut/<M>/MUTATION.txt` | the exact anchor + replacement + rationale |
| `corpus/live/r86-critic/mut/<M>/phys3d_events.gd.mutated` | the mutated fixture |
| `corpus/live/r86-critic/mut/<M>/runs/<ts>/verdicts.json` | the battery's own classification of the mutated run |
| `corpus/live/r86-critic/mut/<M>/logs/*.child.log` | that run's child logs (the diffs in §1.2/§2.1 are against the author's `final1-children/`) |
| `corpus/live/r86-critic/replay.log`, `replay/<ts>/` | the independent 195-row replay |
| `corpus/live/r86-critic/manifest.sha256` | digests of the 296 surviving files |
| `corpus/live/r86-critic/PRUNE.md` | what was removed after measurement and how to regenerate it |

**Pruning, disclosed.** The per-mutation seed copies (each a full
`corpus/fixtures` copy including `three/node_modules`) and the battery's
per-run `scratch/` trees — ~166 MB together — were removed once the measurements
and the child logs were saved; `probes/mutations.py` rebuilds any of them
exactly. The surviving 296 files are pinned in `manifest.sha256`.

No commit, no push, no subagent, no runtime other than the canonical battery
and `/usr/bin/godot`.
