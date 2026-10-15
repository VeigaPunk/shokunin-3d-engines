# r92 adjudicator — RemoteTransform3D / anim×body / scheduler timing (orchestrator seat)

## Verdict: **ADMIT-corr**

Round 92 adds 23 CASES rows (235→258) covering RemoteTransform3D
remote/local propagation, AnimationPlayer×physics-body interaction,
and SceneTree/Engine timing probes — plus a required correction fold
after the verifier FAILED the authored timing rows.

## Seat ledger (11 reports on record)

| seat | verdict | commit |
|---|---|---|
| author | 23 rows, 369 cells (123/pass ×3 runs), 2 runs green | `dd32c3c` + `b6169f6` |
| baseline | 235/235 ×2 byte-identical, zero drift r91→r92 | `82afd7c` |
| boundary | `set_notify_transform(false)` freezes propagation all 3 backends; local-mode propagation synchronous at write; `time_scale=-1` splits GP (time-reversed, closed-form verified) vs Jolt (freeze) | `91ce055` |
| critic | CHANGES-RECOMMENDED — 5 rows scheduler-conditional; `Main::iteration()` batches physics steps so "next tick" = "next tick batch" | `23c89df` |
| verifier | FAILED — reproduced `r92_timing_steps` pre-write-delta leak under batching (`0.016667` vs `0.166667`) | `6f884ad` |
| simplifier | SP1–SP5 proven (~24 lines, zero marker delta); ~200-line triplication flagged below-bar | `b6a3e1a` |
| scribe | custody verified; corrections: "369 children" is 123/pass×3; idlemode range off-by-1e-4 | `17dc133` |
| fold | timing re-anchored to iteration boundary + 3 settled ticks; idlemode envelope widened to measured legal set x∈[0,3], y∈[1.8,2.0005]; SP1–5 applied; 7 markers re-pinned; 258/258 + 5/5 loaded | `75739bc` |
| verifier-r2 | VERIFIED — 4212 settled-delta samples 0 off-pin; 600/600 envelope admissions incl. 172 fresh starved hits; SP1–5 inert (251 byte-identical, exactly 7 re-pins) | `cee635b` |
| post-fold baseline (r93 seat) | 255+254/258 — all FAILs on-record flake classes, 0/14 r92 conditional failures | `455d9b1` |
| adjudicator | this report | this commit |

## Corrections admitted into the fold

1. Timing rows re-anchored: mutation → `process_frame` (iteration
   boundary) → 3 settled ticks each idle-sealed. The scheduler-
   conditional transient can still occur inside a batched iteration
   but can no longer reach a pinned row.
2. `idlemode` envelope widened from an aspirational band to the
   measured legal set (admits the starved scheduling mode, verified
   172 fresh hits in verifier-r2 — the fold's residual risk
   exercised and cleared).
3. SP1–SP5 dead-code deletions applied.
4. Author report arithmetic corrected on the record (369 → 123/pass).

## Correction ledger

- The r92 verifier FAILED pre-fold; the fold seat fixed the
  mechanism (not the symptom) — settled-tick predicates are
  count-independent, so heavier contention raises dpf but cannot
  flip a verdict.
- `phys3d_events_race_class` Jolt crash-envelope drift (`rc=134
  tear=0 abort=2` under ~load-100) observed by verifier-r2 on a
  non-r92 row — recorded as same-class pre-existing flake, not
  r92 scope.

## Residual risks (declared, accepted)

- `navagent3d_*` one-tick miss under load and `phys3d_events_*`
  size-gate granted-under-load remain on-record flakes (r93
  baseline-r2 measured frequency shift at load 122; r101+
  boundary follow-ups may re-address).
- `bpy_rbw3d_render` documented stochastic cell still active;
  a dedicated dissection seat is in flight.
- GP-vs-Jolt `time_scale=-1` divergence is backend-qualified,
  not universalized.

## Admission basis

Non-author verification on actual admitted bytes: verifier-r2 on
`75739bc` — all timing arms green under 191 loaded executions,
envelope exact, deletions inert, three full batteries 254–257/258
with zero new flake classes. Work `dd32c3c`, fold `75739bc`,
record this commit.
