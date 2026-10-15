# r89 fold — corrections applied, verified on the folded bytes

Verification: full battery **217/217 PASS**
(`corpus/live/r89-fold-verify/20261015T083635374793Z/verdicts.json`);
the six touched arms re-run standalone 6/6 first
(`corpus/live/r89-fold-arms/`). Author's claim (217/217 x4,
prior-210 index-identical) reproduced; verifier AGREE'd on the
pre-fold landing.

## Simplifier vfold (proven, applied)

- P1: five write-only r89 class vars + single writes (-10 lines).
- P2: 18 literal child-dispatch entries -> 6 grouped-label branches
  (-24 lines; totality preserved — the labels are a denser spelling
  of the same table).
- P3: README `if_write` bullet drops the never-measured
  `apply_impulse`/`apply_force` names (critic C4 — same fix).
- P4 DECLINED: `_spawn_triple` for 14 shape-uniform arms would rewrite
  8 prior-round arms with three argument-tail variants — residual risk
  for −136 lines; recorded as a future candidate, not applied.
- D1 (found, not folded): the r84 "dispatch must be total" comment is
  false for `fm_`/`sl_` prefixes (`sl_bogus` rc 0 + partial map,
  `fm_bogus` rc 134); queued for a later repair.
- D3 (pre-existing, disclosed): `phys3d_events_freed_space_methods`
  (r88 row) is a crash-mode/ASLR lottery — 5/10 fail dirty, 2/10
  folded, independent of this fold; the segv-mode token belongs in
  that arm's `freed_allow`. Queued for r90; this round's 217/217 holds
  on both verified reps.

## Critic C1-C7 (all applied, all verified live)

- C1: Jolt's "drops" are NOT silent — `not supported when using Jolt
  Physics` WARNINGs counted like the slider guard: joint_param 35
  (33 "is" + 2 "are" slider angular limits — equals the pinned drop
  rows exactly), joint_pin 3 (2x pin bias + 1x impulse clamp),
  joint_solver 1 (solver priority). Negative side pinned: zero such
  warnings in every plain/dummy child log.
- C2: `_child_prepare` hardened — a whitelist continuation refuses any
  dirname char outside [A-Za-z0-9_-]; `$()`, `${}`, backticks, quotes,
  whitespace can no longer pass the slash/dot check and escape the
  project (the critic's `h2` escape is now refused named).
- C3: `sl_want.get(sl_arm, {})` -> explicit `no sl_want cell
  (unasserted row)` failure; a missing expected cell can no longer
  pass silently.
- C5: the if_phase ordering claim gains a position witness —
  PHASEMK lines are printed inside each callback in real time
  (IF on the physics thread, E/F on main), so the merged child.log's
  FILE ORDER is scheduler-mediated, not the child-assigned seq
  counter. `_log_phase_order` verifies IF<E<F per pf on both real
  backends; dummy = absent. Live-verified in the standalone run.
- C6: stale-buffer wording bounded — the pinned class is a stale
  READ on the held state object's contact view (cc=1, imp 0.1633,
  frozen lv), not a claim about the backend's internal buffer.
  Both claim sites corrected.
- C7: cross_space now emits `b_bound` (vp.world_3d == world_b
  readback — the assignment took) and `b_find`
  (vp.find_world_3d() == world_b — the viewport resolves to it);
  an orphan World3D can no longer satisfy the B-space rows.
  Pinned "true" on all three backends.

## Verifier F1 (applied)

README: 195 -> 217 registered cases (171 ordinary + 46 negative
controls — the rc!=0 census still holds exactly) and the stale
`.shokunin/game-dev-3d/` path prefix corrected to
`corpus/fixtures/` (the directory does not exist on this layout).

## Boundary classes (recorded for the adjudicator, not pinned)

- Jolt `body_set_space` onto a freed space -> signal 11 at teardown
  (6/6) vs GP clean detach — boundary class, no r89 cell claims it.
- Jolt reports SLEEPING at tick 1 in the air — the `slept=41` pin is
  sampler-fragile per B-side note; documented as host/timing-bound.
- Sleeping-body joint make wakes both on Jolt vs GP silent-then-
  cascade; detach `RID()` nils the handle on both.
- The r90 Dummy clause flagged unsupported — handed to the r90 author.

Scribe report still in flight at fold time; the adjudicator
incorporates it on landing.
