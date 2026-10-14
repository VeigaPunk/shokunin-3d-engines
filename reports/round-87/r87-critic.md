# game-dev-3d round 87 — critic (seat: critic, host: devin)

Wave `shokunin-train-20261101-w19`, lane g3d. Assignment
(`.ufo/waves/shokunin-train-20261101-w19/tasks/g3d-r87-critic.md`, verbatim):
adversarial gate review of c57fa40 — reproduce every gate from receipts; try to
forge PASSes; check write-loss honesty, the freed_space two-mode crash
disjunction, and stale-satisfaction of held-handle identity pins.

Runtime `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`,
60 tps. Scratch `corpus/live/r87-critic/` (gitignored). **Zero tracked-file
edits by this seat.**

**Reproduction**: `run_battery.py --only` on the six new rows → **6/6 PASS** on
this host (`runs/20261014T220540514419Z/verdicts.json`). Prior-row
byte-stability claim verified by inspection: `git show c57fa40` touches
`run_battery.py` only by appending six tuples at the tail, and the single
non-insertion edit is the additive `allow_lines := []` parameter +
`_error_allowed` predicate, which for the default `[]` reduces to the landed
`allow_inaccessible` semantics. `unthreaded au_plain` control run: `gate=granted`
— the threading-witness claim is scout-consistent and survives on this host.

---

## F1 — COUNTEREXAMPLE (demonstrated live): `freed_space`'s "engine's own line" is fully self-printable

The row's entire witness triple — (a) the signature crash line counted in the
raw `child.log`, (b) empty `verdicts`, (c) signal-class `rc ∈ {134,137}` — is
manufactured by a child that does **no engine work at all**:

```gdscript
# forged _child_freed_space (fs_plain / fs_jolt):
prints("handle_crash: Program crashed with signal 11")
quit(134)
```

Receipt: `corpus/live/r87-critic/forge/` — patched copy, `godot --headless
--path forge --script res://phys3d_events.gd -- --arm=freed_space` printed the
exact pinned marker:

```
PASS phys3d_events freed_space gp=crash jolt=crash dummy=empty child_exit=0
```

Mechanism: `_spawn_child` runs `> child.log 2>&1` — the log is the child's own
merged stdout+stderr. `_log_count` counts a substring in that stream; a
`prints()`/`printerr()` of the same text is indistinguishable from the engine's
line, and `quit(134)` yields the signal-class rc through `timeout`. The
`_log_count` comment and author §7 claim this count is "a signature line in the
raw child log … which a self-print cannot manufacture" — **that is false**: the
merged stream IS the child's print surface. The same attack forges
`body_tier`'s `detach_write=loud` corroboration (the `Failed to apply central
impulse` token is additionally allow-listed, so a printed `ERROR:`-prefixed fake
is both forgiven and counted), and every `CHILD_RESULT` verdict map in all six
arms is self-report by design. The gate still detects *accidental* drift (M2:
skip the free → rc 0 → fail; line-text change → count fails), so the row is not
worthless — but its claimed witness class ("the engine's own line") is not
established by the mechanism, and the comment/report say otherwise.

## F2 — Missing conjunct + documented mechanism falsified for GP: crash site is blind, and on GP the crash is inside `get_space_state()`, not `intersect_ray`

The gate requires only: signature line ==1, verdicts empty, rc signal-class.
**Nothing binds the crash to the freed-space query.** Any SIGSEGV anywhere in
the child (startup regression, `_mk_body`, `free_rid` itself) produces the
identical gate state — F1's forge is only the degenerate case; an *honest*
early crash also PASSes.

Worse, the GDScript backtraces in my reproduced logs falsify the landed
narrative for GP:

- `fsplainproj/child.log` — `CHILD_NOTE fs_plain held=…` at line 3, then the
  crash banner; **no `space=` note**. GDScript backtrace pins line **2739**:
  `var sp: Variant = held.get_space_state() …`. On GodotPhysics the crash is
  **inside `get_space_state()`** — the space-state object is never returned.
- `fsjoltproj/child.log` — `space=<JoltPhysicsDirectSpaceState3D#…>` prints,
  then crash at line **2745**: `sp.intersect_ray(q)`. Matches the narrative.

README/author-report/fixture comments all claim the object "still answers, and
querying it kills the process" for both backends. For GP that is measurably
wrong on this host: it is the body handle's `get_space_state()` reach that
segfaults. The crash *class* (hard crash on the freed-space reach) survives;
the documented *site/mechanism* does not, and the gate has no conjunct that
could notice the difference.

## F3 — `acq_use`/`write_loss`: the expected-witness refusal lines are allow-listed but never counted

Each `au_*`/`wl` child log contains **exactly 8** `ERROR: Body state is
inaccessible…` lines (verified: `grep -c` = 8 in all three logs). The parent
never counts them — `allow_lines` forgives the class, and `gate=refused` is the
child's self-report of null returns. Consequence: the row cannot distinguish
the class-1 **gated refusal** (nil + ERROR) from the scout's class-3 **silent
nil** (freed/detached-RID semantics). A regression that made the threaded
out-of-phase fetch return nil *silently* PASSes identically. The author built
`_log_count` for exactly this corroboration and applied it to `body_tier` and
`freed_space` — inconsistent application of their own standard; the data to
bind it is already in the log (`== BODY_REPS`).

## F4 — `write_loss`: verdict — **honest about measuring non-loss**

Brief question answered: yes, the row is honest. The marker claims
`gate=refused reps=8 same_turn=8 tally=8 race=bounded` — no landed/lost claim;
the split is evidence-only in `CHILD_NOTE` (this run: `landed=8 lost=0`).
Conjuncts: `refused==8` (real precondition — transitively pins out-of-phase
position), `same_turn==8` (write applied to the handle-visible state),
`landed+lost==8` and `landed>=1` — so an all-lost run **fails** (landed=0), and
no loss is claimed that was not witnessed. `race=bounded` names the class; the
scout's non-replicated `fl_proj_thr` loss is disclosed in comment, README, and
author §4/§11. Thin spots (disclosed or harmless): `tally=8` is
near-tautological (each rep increments exactly one counter — it pins loop
completion only); `same_turn` reads `held.is_sleeping()` — the handle's own
view — while server survival rides on the evidence-only landed/lost pair; and
`landed>=1` admits `landed=1 lost=7` under the same marker (defensible: the
marker claims boundedness, not a landed fraction). Not a defect.

## F5 — `body_handle`: identity pins are genuine `==`; two conjunct gaps

- `if_same`, `ss_same`, `reattach`, `twin`, `two_fetch` are strict instance
  identity — **a different object cannot satisfy them**; a fresh-fetch
  singleton-vs-wrapper regression would fail loudly. The forge angle asked by
  the brief ("identity pins a different object could satisfy") does not exist.
- **`held_live` is stale-satisfiable**: `held.get_transform()==t_before` is met
  by any handle still serving frozen state — and this same commit's fs arm
  proves objects answer past backing lifetime (Jolt's `get_space_state()`
  returned a live-looking object on a *freed* space). A detached body supplies
  no current truth to diverge, so the pin measures "still reads the same
  transform" — exactly what README claims — but the token name `held_live`
  connotes liveness the test cannot establish (zombie handles pass). Author
  risk #5 discloses the moving-detached angle, not the stale-serving one.
- **`dummy_cb=never` is not pinned**: the Dummy dict asserts only
  `if_same=false` + `ss_same=false` — satisfied by a Dummy that *fires*
  callbacks with non-singleton objects (`fired>0, same<fired` → `ss_same=false`;
  a refetch that returns a different instance → `if_same=false`; detach/reattach/
  twin/two_fetch all still pass on a consistent non-singleton). The fired count
  exists only in `CHILD_NOTE` (`ss=%d/%d`), unasserted — the marker's `never`
  outruns the gate.

## Verified clean

Whole-dict verdict compares (extra/missing tokens fail); engine-hint `BLOCKED`
gates fail-closed and never fabricate splits; `step_stamp` whole-dict pins
including the inside-class GP/Jolt gravity split (the author's correction of
the scout summary is real — `ss_jolt_grav_pre=real`); `body_tier`'s `flat` vs
`kept` zero-vs-zero guard is load-bearing; `freed_space` Dummy arm pins
`{"fs_dummy_ray":"empty"}` exactly; threading-witness claim in `acq_use`
reproduced (unthreaded child → `gate=granted`, 0 refusal lines).

## Impacted axes

- **witness-provenance** (F1): the crash/refusal "engine line" claims are not
  enforceable from the merged log — forge demonstrated end-to-end.
- **claim-fidelity** (F2): documented GP crash mechanism wrong on this host
  (site: `get_space_state()`, not `intersect_ray`).
- **conjunct-completeness** (F2 site-pin, F3 refusal-count, F5a fired-count):
  three cheap, unpinned conjuncts, each closing a real false-PASS path.
- **determinism/insertion-only** (clean): 6/6 reproduce; prior-row byte-stability
  claim holds by diff inspection.
- **honesty-of-bounds** (F4 honest; F5b thin naming only).

## Smallest safe corrections

1. **F1** — provenance cannot be fixed inside a merged `2>&1` log. (a) Delete
   the false claims: the `_log_count` comment's "which a self-print cannot
   manufacture" and the parallel wording in README/author §7; state that the
   count corroborates *presence*, not provenance. (b) To raise the bar cheaply,
   require the crash **envelope**, not one line: `Dumping the backtrace`,
   `-- END OF C++ BACKTRACE --`, `GDScript backtrace`, and `timeout: the
   monitored command dumped core` each `>=1` alongside the signature line —
   still forgeable by a determined author, but no longer by a one-line print.
2. **F2** — pin progression per backend: require `CHILD_NOTE fs_*_held=` ==1
   for both crash children (binds the crash to after the arm's fetch); require
   `space=` ==0 for GP and ==1 for Jolt (the measured site split), ray verdict
   absent as today. Correct the README/report text: on GP the crash is inside
   `get_space_state()`; on Jolt the object answers and `intersect_ray` kills.
3. **F3** — `_log_count(child_log, "Body state is inaccessible") == BODY_REPS`
   for `au_plain`, `au_jolt`, `wl_plain` (all measured exactly 8 this run) —
   binds the refusal to the engine's loud class, distinguishing it from the
   class-3 silent nil.
4. **F5a** — emit `bh_dummy_ss_fired`/`bh_dummy_if_fired` verdicts and pin both
   `0` so `dummy_cb=never` is a conjunct, not commentary. **F5b** — rename
   `held_live` to `held_readable` or add a post-reattach write→server-readback
   conjunct; at minimum disclose stale-satisfiability in README.
5. **F4** — no change required; if tightening is wanted later, `landed` could
   join the marker as evidence (it is already a verdict token).

**Seat output complete.** Read-only on tracked files honored; all scratch
under `corpus/live/r87-critic/` (`runs/` reproduction receipt, `forge/`
counterexample, `au-unthreaded/` control). No commit, no push, no runtime
invoked beyond the fixture battery and the Godot binary under test.
