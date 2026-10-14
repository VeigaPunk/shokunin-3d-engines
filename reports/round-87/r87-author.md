# game-dev-3d round 87 — author (seat: author, host: devin) — the body-tier deferred-state lattice

Round 87. Wave `shokunin-train-20261101-w18`, lane g3d. Assignment
(`.ufo/waves/shokunin-train-20261101-w18/tasks/g3d-r87-author.md`, verbatim):

> ARM — phys3d_events.gd + run_battery.py insertion-only (prior 195 rows
> byte-identical at positions; new cells appended): held-handle cell;
> acquisition-vs-use split; step-stamped getters cell; write-loss race cell;
> backend split at body tier; freed-space crash. Keep every gate fail-closed;
> run full battery + bpy/three.js siblings. Report -> reports/round-87/r87-author.md.

Runtime `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`,
60 tps, 32 cores. Base HEAD `af15a52` (`r86 report-last`). Work tree at
submission: three tracked files modified, **nothing committed, nothing
pushed** (the host commits after verifying). Scratch under
`corpus/live/r87-author/` (`corpus/.gitignore:1`).

**Evidence**: `corpus/live/r87-author/` — scratch probe + driver, 3 full
battery receipts, 1 focused receipt, 2 sibling receipts, the mutation harness
and the prior-row comparator. All of it is gitignored, as the scout's
receipts are; the landed evidence is the fixture, the rows and the markers.

**LSP unavailability recorded** (same as r85/r86/r87-scout): no `lsp` device
is exposed, so no symbol-aware rename/reference operation was available or
needed. The change is pure insertion into two files plus a section append in
the fixtures README; every new symbol is defined in the file that uses it.

---

## 0. What landed

`corpus/fixtures/phys3d_events.gd` (+880/-4) — six new parent arms and their
child bodies, appended at the tail:

| arm | children | pinned class |
|---|---|---|
| `body_handle` | `bh_plain`, `bh_jolt`, `bh_dummy` | the held-handle identity law |
| `acq_use` | `au_plain`, `au_jolt` (both threaded) | the gate controls acquisition, not use |
| `step_stamp` | `ss_plain`, `ss_jolt` | the object's own flush seams |
| `write_loss` | `wl_plain` (threaded) | the out-of-phase write as a bounded race |
| `body_tier` | `bt_plain`, `bt_jolt`, `bt_dummy` | the backend split at the body tier |
| `freed_space` | `fs_plain`, `fs_jolt`, `fs_dummy` | the freed-space crash class (fatal tail) |

`corpus/fixtures/run_battery.py` (+14/-0) — six rows appended at the tail
(195 → 201), the crash row last. `git diff` shows **zero deletions** in that
file: the prior 195 rows are byte-identical at identical positions.

`corpus/fixtures/README.md` (+90/-0) — one new section documenting the six
arms, appended after the round-86 section; the `## Determinism rules for new
cases` heading is intact (r83's post-insert repair is not needed here).

The only non-insertion edit anywhere is 4 lines of `_spawn_child` (below).

## 1. `body_handle` — the identity law, and its Dummy floor

`body_get_direct_state(rid)` is ONE per-body singleton live handle, and the
law is literal object identity across every accessor:

- inside `RigidBody3D._integrate_forces`, a fresh fetch **is** the handle the
  callback was handed (`if_same=true`), and it is still that object when the
  callback returns (`if_refetch=true`);
- `body_set_state_sync_callback` sees the same object every tick
  (`ss_same=true`, 4/4 ticks);
- the held handle **survives detach**: after `body_set_space(rid, RID())` the
  refetch is `nil` (`detach=nil`) and the held handle still reads the exact
  transform it read before the detach (`held_live=true`, compared as a
  Transform3D — a detached body does not step, so the read must be identical);
- it **survives reattach**: `body_set_space(rid, wspace)` → the refetch is
  `==` the held handle (`reattach=true`);
- `held.get_space_state()` is the same object as
  `space_get_direct_state(world_space)` **and** `World3D.direct_space_state`
  (`twin=true`) — the "three-tier twin" is object identity, not a
  look-alike;
- two fetches in the same frame are equal (`two_fetch=true`).

Identical on GodotPhysics and Jolt; Dummy is pinned as its own dict because
the law is real-backend-only: neither callback ever fires
(`dummy_cb=never`) and the fetch answers for a **detached** RID too
(`bh_dummy_detach=obj`), which is exactly why a Dummy row can never be armed
as a hazard detector (scout directive 8).

## 2. `acq_use` — the gate controls acquisition, not use

Two threaded children (GP+thread, Jolt+thread), 8 reps each. At every rep the
child is at a **process-frame** position (`out_of_phase=8`, verified with
`Engine.is_in_physics_frame()`), where:

- a fresh `body_get_direct_state` returns a null-Object Variant — 8/8
  (`gate=refused`), each refusal printing the engine's
  `ERROR: Body state is inaccessible right now, wait for iteration or physics
  process notification.`;
- the handle acquired once at a legal position reads **live** — its
  `get_linear_velocity()` equals the server's `body_get_state` read at the
  same instant, 8/8 (`held_read=live`);
- its writes land: `set_linear_velocity` is visible same-turn through the
  handle, 8/8; `set_transform` persists to the next in-phase server read
  exactly, 8/8 (`write=ungated`).

The gate witness doubles as the **threading witness**: a child whose
`run_on_separate_thread` key was silently ignored would grant every fetch and
the row would fail loudly rather than reprint the unthreaded map.

## 3. `step_stamp` — the object's own flush seams, and one refinement

The PRE reads happen in the deferred child dispatch, before the first solve
completes; the POST reads after the body has fallen into contact.

| token | GodotPhysics | Jolt |
|---|---|---|
| `step_pre` | `0.0010000000475` | `0.0` |
| `grav_pre` | `zero` | **`real`** |
| `damp_pre` | `0.0` | **`0.10000000149012`** |
| `step_post` | `0.0166666675359` | `0.0166666675359` |
| `damp_post` | `0.10000000149012` | `0.10000000149012` |
| `cc_off` (default `max_contacts_reported`) | `0` | `0` |
| `cc_on` (after `body_set_max_contacts_reported(rig, 8)`) | `4` | `4` |
| `last_step` (teleport out of contact: `w0`,`n1`) | `4,0` | `4,0` |

**Refinement of the scout's directive 6**: `get_step` is step-stamped on both
real backends, but `get_total_gravity` / `get_total_linear_damp` are
step-stamped on **GodotPhysics only** — Jolt reports the real values before
the first solve. The scout's summary generalised the GodotPhysics behaviour;
its own `ph_proj_jolt` receipt already shows the split
(`R A.get_total_gravity -> (0.0, -9.8, 0.0)` at position A), and the landed
child reproduces it byte-for-byte. The contact buffer is the one
snapshot-semantics field (last-step data) and reports **nothing at all** until
the body opts in.

## 4. `write_loss` — a race class, pinned as a bounded observation

The row is deliberately **not** a per-rep pin. Eight reps, each asserting the
deterministic part:

- the fresh fetch is refused at every rep (`gate=refused`);
- the write is applied and same-turn visible through the handle
  (`same_turn=8`);
- the tally is accounted (`landed + lost = tally = 8`) and the write is never
  dropped entirely (`landed >= 1`).

The landed/lost split is **evidence, not a gate**: the child prints it in its
log (`landed=8 lost=0 rows=[…]`), and the marker carries `race=bounded` — a
claim about the row, not about the run. The write path is ungated and
unsynchronized (proved by the `acq_use` arm), so a lost update is possible in
principle.

**The scout's measured loss did not replicate.** Across 18 child runs / 144
out-of-phase writes and four landed/lost forms (CAN_SLEEP=false ×5,
CAN_SLEEP default ×3, a `await process_frame` phase-offset ladder ×3, and the
scout's own `fl_*` write ladder ×4), `lost` was **0 every time**. The row
therefore claims the precondition and the accounted tally and never claims a
loss it did not witness. This is recorded as a *not-reproduced* class, not as
a refutation: the scout's r1/r2 receipts are real, and the window (a write
landing inside the physics thread's processing of that body) is narrow and
load-dependent.

## 5. `body_tier` — the backend split, three children, one sweep

| token | GodotPhysics | Jolt | Dummy |
|---|---|---|---|
| `cc` | `4` | `4` | `0` |
| `impulse` at the first in-contact step | `zero` | `real` | `nil` |
| `lshape_oob` (idx `cc+5`) | `-1` | `0` | `absent` |
| `sleep_lv` after `set_sleep_state(true)` | `kept` | `zeroed` | `flat` |
| detached-impulse refusal lines in the raw log | `0` | `1` | `0` |

The raw impulse triples (child-log evidence) reproduce the scout's `mm_*`
receipt exactly: GodotPhysics
`-0.000000000,-0.000000000,-0.000000000` vs Jolt
`-0.006821907,0.647047877,0.013493819` (scout: `(0,0,0)` /
`(-0.006822, 0.647048, 0.013494)`), both at `first_i=12`.

**Correction of the scout's framing.** "GodotPhysics zeros, Jolt real" is
true **at the first in-contact step in the scout geometry** — and false as a
general law. With the floor at `y=-1` instead of `y=0`, GodotPhysics's
`get_contact_impulse(0)` oscillates: a 40-frame series reads exactly
`(0,0,0)` at two steps and up to `0.103` at others. The cell is therefore
pinned at that one step, and mutation M3 (read the impulse four steps later
instead of at the first in-contact step) is **detected**, which is the
load-bearing proof of the pin.

Two further measured facts behind the tokens: the out-of-range
`get_contact_local_shape` refusal prints *different strings for the same
class* (`(body->contact_count = 4)` on GodotPhysics vs
`((int)body->get_contact_count() = 4)` on Jolt), so both are admitted by an
`allow_lines` substring that matches neither backend's text exactly; and the
detached-impulse refusal is a **log witness**, counted in the raw child log
(0/1/0) rather than trusted from the child's own print.

Side-measurement (not landed, but it explains the r83 fixture's geometry):
the **server** box shape's `shape_set_data(box, Vector3(1,1,1))` behaves as
half-extents on this build — a floor at `y=-1` contacts a rigid box up to
`y≈0.95` and not at `y=1.0`, and the free-fall rest is `y=0.99001` — while
the `BoxShape3D` **resource**'s `size` is the full size. Both the r83
`contact_stale` geometry (rig at `y=0.5`, floor at `y=-1` → 4 contacts) and
the scout's `mm_*` geometry (body at 2.2, floor at 0 → contact at `y<2.0`)
follow from that reading.

## 6. `freed_space` — the crash class, pinned per backend, in the fatal tail

The one crash surface at this tier is **not** the body handle (freed *body*
handles degrade to silent nulls — measured) but the space-state object reached
*through* it. The child fetches a body handle, `free_rid`s the world space,
gets `held.get_space_state()` — which still answers — and calls
`intersect_ray`.

- **GodotPhysics**: `handle_crash: Program crashed with signal 11`, then the
  handler dumps a 45-line backtrace and aborts → `rc 134` in ~1.5 s
  (measured 5/5 in this fixture form, 3/3 in the battery runs). The same
  handler was measured taking **44.2 s** under host load, at which point a
  6 s bound kills it → `rc 137`. So `rc` is the handler's exit *path*, not the
  class: the row accepts 134 or 137 and requires the engine's signal line.
- **Jolt**: the crash **mode is heap-layout dependent**. The scout's probe
  script threw an uncaught `std::system_error` (`what(): Invalid argument`)
  3/3; this fixture's larger child SIGSEGVs into Godot's own handler 3/3 (and
  3/3 again in the battery runs). The row requires **exactly one** of the two
  engine lines (`throw + segv == 1`) and never claims one mode as the law.
- **Dummy**: `{}` and `rc 0` — the floor, and proof that a Dummy child can
  never witness a crash class.
- Both crashing children must leave **no** `CHILD_RESULT` at all — a crash
  cannot be caught, so the absence of a marker is half the witness.

## 7. Harness changes, and the one non-insertion edit

`_spawn_child` gains an additive, defaulted `allow_lines := []` parameter and
its ERROR scan is restructured into one predicate:

```gdscript
elif line.begins_with("ERROR:") \
        and not _error_allowed(line, allow_inaccessible, allow_lines):
```

`_error_allowed` preserves the landed `allow_inaccessible` carve-out verbatim
as its own branch. This is the only non-insertion edit in the round (4 lines)
and it is load-bearing: the body-tier arms' **expected witnesses** are engine
ERROR lines — the body-tier fetch refusal (8 per `acq_use` child), the
out-of-range contact-index refusal, and Jolt's detached-impulse refusal — and
a witness the scan rejects can never be asserted. Every existing call site
passes at most 6 positional arguments, so every r83–r86 receipt is
unchanged; that is confirmed empirically in §9.1, not just by inspection.

`_log_count(logpath, token)` is new: it counts a signature line in the raw
child log so a claim that is an engine line (the crash signatures, Jolt's
detached-impulse refusal) can never be satisfied by a child's own print — the
r86 A4 discipline extended to the new arms.

## 8. Gates are fail-closed

- `body_handle`, `acq_use`, `step_stamp`, `body_tier`, `freed_space` each
  require `_engine_hint_has("Jolt Physics")` (and, where a Dummy child is
  spawned, `_engine_hint_has("Dummy")`); absent → `BLOCKED … jolt_absent=true`
  with exit 1, never a fabricated split.
- Every child verdict dict is compared **whole** (`spawn["verdicts"] != want`),
  so an extra or missing token fails the row; the write-loss arm's fields are
  asserted individually *and* accounted.
- The crash rows accept a disjunction only where the measurement is genuinely
  bimodal (the two `rc`s; Jolt's two crash modes), and in both cases a second
  independent witness is required (the engine line, the empty marker set).
- The Dummy rows are floor rows; no Dummy child is armed as a hazard detector.

## 9. Behavioral evidence

### 9.1 Prior 195 rows byte-identical at identical positions

`corpus/live/r87-author/prior_rows.py` compares the first 195 result records
of a run against the r86 post-commit reference
(`corpus/live/r86-baseline/runs-post/20261014T203735129154Z/verdicts.json`)
at identical positions, field by field — 12 fields
(`case, script, flags, expected_exit, actual_exit, error, kind, marker,
verdict, reasons, stdout, stderr`), raw bytes; `command` is excluded because
it embeds the per-run scratch path, `elapsed_seconds` because it is wall
clock.

```
prior rows=195 fields=12 mismatches=0 names_identical=True
appended rows=6: ['phys3d_events_body_handle', 'phys3d_events_acq_use',
  'phys3d_events_step_stamp', 'phys3d_events_write_loss',
  'phys3d_events_body_tier', 'phys3d_events_freed_space']
```

Run against all three full receipts (runs-battery, runs-battery2,
runs-final): 0 mismatches each. `git diff` independently shows 0 deletions in
`run_battery.py`.

### 9.2 Full battery ×3, and the new rows are deterministic

```
run 1  corpus/live/r87-author/runs-battery/20261014T213028552587Z  201/201 PASS  5m11s
run 2  corpus/live/r87-author/runs-battery2/20261014T213609598591Z 201/201 PASS  5m15s
final  corpus/live/r87-author/runs-final/20261014T214355942770Z     201/201 PASS  4m15s
       totals cases=201 pass=201 fail=0 ordinary=155 negative_controls=46
       seeds_unchanged=true, verdict PASS
```

Run 1 vs run 2: **0 mismatches over 12 fields × 201 rows** (all 201 rows,
including the six new ones, byte-identical). Run 2 vs the post-comment-edit
`runs-final`: **0 mismatches** — the comment-only freeze changed no observable.
Runs 1–2 were taken before that freeze, `runs-final` after it; all three agree
row-for-row, and `runs-final`'s `seed_digests` match the submitted bytes
(55 seed files, 0 drift).

Focused receipt: `runs-only87/20261014T214129889119Z` — the six new rows run
alone, 6/6 PASS. New-row wall clock 1.99–5.49 s each (case bound is 20 s).

New-row markers (exact, as pinned):

```
PASS phys3d_events body_handle if_same=true ss_same=true detach=nil held_live=true reattach=true twin=true two_fetch=true dummy_cb=never child_exit=0
PASS phys3d_events acq_use gate=refused out_of_phase=8 held_read=live write=ungated reps=8 child_exit=0
PASS phys3d_events step_stamp gp_step_pre=0.001 gp_grav_pre=zero jolt_step_pre=0.0 jolt_grav_pre=real step_post=0.016667 cc_off=0 cc_on=4 last_step=4,0 child_exit=0
PASS phys3d_events write_loss gate=refused reps=8 same_turn=8 tally=8 race=bounded child_exit=0
PASS phys3d_events body_tier gp_impulse=zero jolt_impulse=real gp_lshape=-1 jolt_lshape=0 gp_sleep_lv=kept jolt_sleep_lv=zeroed dummy_cc=0 detach_write=silent,loud,silent child_exit=0
PASS phys3d_events freed_space gp=crash jolt=crash dummy=empty child_exit=0
```

### 9.3 Mutation matrix — 6/6 load-bearing

`corpus/live/r87-author/mutations.py`: each mutation edits exactly one
authored interaction in a scratch copy and runs the affected arm; detection
means the parent now rejects the mutated measurement.

| id | arm | mutation | detected |
|---|---|---|---|
| M1 | `acq_use` | 8 reps → 4 reps | yes (`acq_use plain drift`) |
| M2 | `freed_space` | do not free the space before the query | yes (`rc=0 not signal-class`) |
| M3 | `body_tier` | read the impulse 4 steps after first contact | yes (`body_tier plain drift`) |
| M4 | `step_stamp` | drop `body_set_max_contacts_reported` | yes (`step_stamp plain drift`) |
| M5 | `body_handle` | drop the detach | yes (`body_handle plain drift`) |
| M6 | `write_loss` | write in phase instead of out of phase | yes (`write_loss drift`) |

M3 is also the empirical proof of §5's correction: reading the same field
later makes GodotPhysics report a *real* impulse, so the "GP zeros" token
would be wrong if the pin were not step-scoped.

### 9.4 Sibling batteries — untouched surfaces, still green

- **bpy** `corpus/fixtures/bpy_battery.py --blender /usr/bin/blender`:
  `totals cases=83 pass=83 fail=0 (signal_fail=0 quirk_drift=0)`,
  `launch_ok=true done_marker=true fatals=0 exit=0`, `n_arm_lines=131`;
  `probe.stdout.txt` sha256
  `6a98c570dbaec6f33f23c684ae2938470a251c229cb50d4451c23eb1d07defc3` —
  **identical to the frozen r86 baseline**, the 10th identical receipt.
  `corpus/live/r87-author/bpy-final/bpy-20261014T214816011070Z/`.
- **three.js** (six suites, three@0.186.1, node v24.21.0): 3/3 + 4/4 + 9/9 +
  5/5 + 5/5 + 5/5 = **31/31 PASS, seeds_unchanged=true**; receipts
  `corpus/live/r87-author/three-final-*.json`.
- No `bpy_*`, `three/`, or prior-`.gd` file was touched: `git status` lists
  exactly the three declared tracked files.

## 10. Files changed

| file | delta | note |
|---|---|---|
| `corpus/fixtures/phys3d_events.gd` | +880 / −4 | six arms, six child bodies, one inner class, two helpers, `_spawn_child`'s additive `allow_lines` |
| `corpus/fixtures/run_battery.py` | +14 / −0 | six rows appended at the tail, crash row last; prior 195 rows untouched |
| `corpus/fixtures/README.md` | +90 / −0 | one section appended; `## Determinism rules` heading intact |

Working-tree sha256 at submission:
`phys3d_events.gd 0e5e64f42e99652fadedaf1459278e5d7a460ef9b9341c3aac34d8661f2f0d12`,
`run_battery.py 45b1ea867259cbb5ff452652e1ace62602ee59215e0f251e202714cccc2f6083`,
`README.md 45ec89a2166af0ee7ab82862675461bdb5c420a47ad433a88236eb109188dd5e`.

Scratch (gitignored, not a deliverable): `probes/btier.gd` (7-arm scratch
probe), `driver.py`, `mutations.py`, `prior_rows.py`, `runs/`, `runs-battery/`,
`runs-battery2/`, `runs-only87/`, `runs-final/`, `bpy-runs/`, `bpy-final/`,
`three-*.json`, `battery-*.log`, `bpy.log`, `fxcheck/`, `mutation-scratch/`.

## 11. Remaining risks, unresolved, blockers

1. **The write-loss class is not reproduced.** 0 lost in 144 out-of-phase
   writes over four forms. The row pins the precondition and the accounted
   tally, and a loss, if it ever lands, will *change the child log, not the
   marker* — the row cannot fail because of it, and cannot claim it either.
   A future round with a stress form (a `_process`-tick writer racing a
   narrow window) may pin the loss itself.
2. **Two disjunctions are deliberate.** The crash rows accept `rc ∈ {134,
   137}` and Jolt's two crash modes. Both are measured bimodalities, both
   carry a second witness, and both are documented in the fixture comments —
   but they are weaker than a single-value pin.
3. **Jolt's crash mode is not understood, only characterised.** Both modes
   were reproduced 3/3 in their respective scripts; the mechanism (freed
   memory still shaped like a live Jolt system vs not) is inference from the
   two receipts.
4. **`body_tier`'s impulse pin is geometry- and step-scoped** — it is exact
   at the first in-contact step of the scout geometry and *wrong* elsewhere.
   The arm comment and the README both say so; a reader who lifts the token
   out of that scope will misread it.
5. **The identity law's `held_live` token compares transforms.** A body that
   moves while detached would fail it; the arm uses a gravity-free, static
   server body for exactly that reason.
6. **All of this is one host, one build** (`4.7.2.stable.arch_linux.ed1daf0bf`),
   `--headless`, 60 tps, and six generated project variants.
7. **The Dummy rows are floor rows only.** No Dummy child in this round is
   armed as a hazard detector, per scout directive 8.
8. **Blockers: none.** The batteries are green, the rows are inserted, the
   siblings are untouched. The host owns the commit.

**Seat output complete.** No commit, no push, no deployment; no runtime other
than the fixture battery was invoked.
