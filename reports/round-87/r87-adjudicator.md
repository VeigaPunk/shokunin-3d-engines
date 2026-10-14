# R87 adjudicator — body-tier direct-state lattice

Round: 87. Wave: `shokunin-train-20261101-w19`. Work commit `c57fa40`,
fold commit `a11e1ad`.

## Declared move

Six appended cells on `PhysicsDirectBodyState3D`
(`body_get_direct_state`): `body_handle` (per-body singleton identity;
survives detach/reattach; `get_space_state()` ≡
`space_get_direct_state` ≡ `World3D.direct_space_state`),
`acq_use` (threading gates ACQUISITION not use — held handle reads
live and writes land at every out-of-phase position), `step_stamp`
(object's own flush seams; GP/Jolt split inside the class),
`write_loss` (ungated unsynchronized write as bounded observation),
`body_tier` (first-in-contact impulse GP=zero/Jolt=real; lshape −1/0;
sleep_lv kept/zeroed; detached write silent/loud/silent), and
`freed_space` (fatal tail — freed space reached through a held body
handle crashes the process).

## Claim adjudication

- **CONFIRMED.** 201/201 folded battery; 195/195 prior rows
  byte-identical (semantic fields incl. stdout/stderr — only scratch
  path + elapsed differ). bpy 83/83, three.js 31/31, all
  `seeds_unchanged`.
- **Baseline** zero-drift both phases, exactly 6 inserted rows
  @196–201, child-log maps identical. **Reviewer** AGREE on all 11
  claims. **Verifier** (swe-2) AGREE on all landed claims with
  record-precision notes.
- **Author correctly refused the scout's nav cell** — replication gave
  `safe_n=0` 8/8 vs the scout's claimed 10; parked with evidence. The
  reviewer found the non-replication itself was a harness artifact
  (missing `project.godot` in the replication project), and the
  verifier re-derived 17/17 line-identical with it present — recorded
  as a record correction, nav cell disposition deferred to r88 scope.

## Fold corrections (simplifier + critic + verifier record items)

- **Simplifier fold (proven, replay-verified):** P1 redundant
  `two_fetch`, P2 redundant `tally`, P3 unused `post_grav`, G repeated
  `BLOCKED` gates → `_gate()`, E emit/note fold — `+85/−117`.
- **F1 (critic, demonstrated live):** the `freed_space` crash-line
  count was fully self-printable — `prints(crash banner); quit(134)`
  passed the row. Corrected: each backend now requires its real
  crash-site breadcrumb prefix in the raw log — GP `held=` present /
  `space=` absent (crash inside `get_space_state()`), Jolt `held=` +
  `space=` present / `ray` absent. The critic's forge was replayed on
  the folded tree and **fails** (`crash-site envelope drift`).
- **F2:** GP crash-site pin corrected (was documented at
  `intersect_ray`; it is inside `held.get_space_state()` — backtrace
  evidence, corroborated by the verifier).
- **F3:** `acq_use`/`write_loss` now count the engine's refusal ERROR
  lines `== BODY_REPS` in the raw child log — a silently-nil fetch can
  no longer pass as a gated refusal.
- **F5:** `ss_fired` emitted bucketed (`0`/`>0`) and pinned —
  `bh_dummy_ss_fired=0` makes `dummy_cb=never` honest; `held_live`
  documented as a frozen-read witness, not a liveness proof.
- **Record fixes:** author's `+880/−4` is `+876/−4`; `ss_same` runs
  5/5 not 4/4; `_log_count` docstring no longer claims self-print
  impossibility; child `child_exit=0` convention noted.

## Verdict

**ADMIT-corr.** Residuals: forge-resistance is now envelope-level, not
absolute (a fully replayed fake note sequence could still satisfy the
count — bounded acceptance, flagged for the r88 mutation pass);
`dss` refusal remains a stochastic band ~475–575 lines (documented);
hang detection rides on rc/timeout (leak scan blind to hung
children — named class). Bounded to
`4.7.2.stable.arch_linux.ed1daf0bf` on this host.

## Files

- Work `c57fa40` (+876/−4, six arms), fold `a11e1ad`.
- Reports: `reports/round-87/r87-{author,baseline,reviewer,verifier,
  critic,scribe,simplifier}.md`; receipts under `corpus/live/`.
