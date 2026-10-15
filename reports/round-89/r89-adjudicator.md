# r89 adjudicator — body-state phase lattice + joint family

**Verdict: ADMIT-corr** — committed `c16f6ba`, pushed. 217/217 on final
folded bytes (`corpus/live/r89-fold-verify/`).

## Inputs

- Author (ds): 7 new cells — `if_phase` (IF→E→F ordering, GP
  one-solve-late impulse vs Jolt same-step), `if_write` deferred-force
  classes, `joint_pin`/`joint_param` Jolt drop lists, `joint_solver`,
  `cross_space` Jolt non-main-space split, `sleep_state` stale-read
  classes + sentinel S3 dirname remediation. 217/217 ×4, prior-210
  index-identical.
- Verifier (independent): 217/217 ×2, prior-210 index-identical, 3
  forge-kills live; F1 README count/path drift → corrected in fold.
- Critic (ds): C1 Jolt WARNING counts unpinned (35 joint_param / 3
  joint_pin / 1 joint_solver, all zero on GP/Dummy); C2 `_child_prepare`
  shell-metachar escape → whitelist `[A-Za-z0-9_-]`; C3 `sleep_state`
  unasserted-row `{}` trap → named failure; C5 PHASEMK merged-log
  ordering witness; C6 stale-buffer wording narrowed to held-state
  read; C7 `b_bound`/`b_find` world-binding pins.
- Boundary: no pinned value falsified; teardown `body_set_space`→freed
  space = Jolt SIGABRT 6/6 vs GP clean; Jolt `SLEEPING` at tick 1 marks
  the `slept=41` pin sampler-fragile; sleeping-body joint make wakes
  both on Jolt. Recorded, not folded.
- Simplifier: P1+P2+P3 proven folds applied; P4 declined (14-arm
  rewrite, residual auditability risk).

## Scribe

The r89 scribe seat died in the 09:0x rate-limit sweep before producing
a report (two dispatches). Record audit duties were absorbed into this
adjudicator: counts re-derived (217 = 171 ordinary + 46 negative),
README paths verified against the repository root layout, report claims
cross-checked against `corpus/live/r89-*/` receipts. A scribe retry may
still land post-hoc; any finding would queue for r90's record.

## Decisions

- ADMIT all 7 cells + the S3 guard.
- CORRECTIONS folded: C1–C3, C5–C7 (additive pins + guard tighten +
  wording); verifier F1 README fix.
- BOUNDED: Jolt teardown SIGABRT class, `slept=` sampler fragility,
  Jolt wake-on-joint-make, `apply_impulse`/`apply_force` zero call-site
  README overclaim (C4 → recorded, P3 wording).
- HELD-OUT: none this lane.

Host: Godot 4.7.2.stable arch_linux headless; GodotPhysics + Jolt +
Dummy backends.
