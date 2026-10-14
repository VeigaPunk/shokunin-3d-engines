# R86 adjudicator — size-gate / deferred-hang / backend-tier / dummy-floor

Round: 86. Wave: `shokunin-train-20261101-w17`. Work commit `4e65726`,
folds commit `dd1737a`.

## Declared move

Four cells on the generated-probe harness (`_spawn_probe` delegates to
`_spawn_child`): `script_size_gate` (threaded fetch refused below a
stochastic ~475-575-statement band, granted above — the gate is
statement COUNT, not fetch position), `deferred_hang` (unguarded deref
of the refused fetch aborts the coroutine; SceneTree lives on; the
timeout bound kills it — rc 137, no CHILD_RESULT), `backend_tier`
(GodotPhysics honors / Jolt inverts / Dummy floors on the same sweep),
`dummy_floor` (34-call silent-floor signature vs 2 real-backend
refusals). Total 191 -> 195 (149 ordinary, 46 negative).

## Claim adjudication

- **All four cells CONFIRMED.** 195/195 across author x2, reviewer x2,
  verifier x2, integrator fold run; tuple sha stable; prior 191 rows
  byte-identical at identical positions (stdout+stderr as bytes,
  verifier's 11-field x 191 x 4-receipt matrix = 0 mismatches).
- **Verifier re-derived every arm with ITS OWN generated children**:
  size-gate 9/9 per side in three padding shapes; hang rc 137 + refusal
  + abort + no marker; tier sweep raw floats identical including the
  Jolt area-inversion; floor signature + 2 refusals reproduced.
- **Mutation coverage**: author 9/9 load-bearing; verifier's own
  4-mutation set 3 detected + V-M2 no-detect with mechanism proven
  (double-free re-emits from `_cleanup_rids`).
- **Baseline zero-drift both phases**; exactly 4 inserted rows
  @192-195; seed digests differ in exactly the 3 declared files.
- **Boundary** correctly mapped the stochastic band (~475-575, verified
  50%-point session-dependent — the band is real, its center is not a
  constant) and the leak-scan blindness to KILLed children.

## Fold `dd1737a` — what landed

- **Simplifier SP1** (replay-proven, 195/195 + 191/191 + 15/15
  project.godot byte-identical): all 13 child project literals ->
  `_project_body(name, engine, threaded)`; the generator is now the
  only way a child project body exists.
- **SP2** (replay-proven): 17 exit tails -> `_quit_clean(code, msg)`.
- **Critic A1**: `deferred_hang` abort witness requires the landed
  `"null instance"` text, not just the SCRIPT ERROR class — an
  unrelated abort previously satisfied it.
- **A2**: the Dummy contrast spawn now passes `HANG_BOUND_S` — an
  unbounded 30 s contrast could exceed the 20 s case bound.
- **A3**: statement-count wording (header + arm + README) — the
  variable is count, not "startup work" (uncalled 1000-statement body
  grants 7/7).
- **A4 / boundary MX4**: `min_thr` refusal now requires the engine's
  `space_get_direct_state` callsite line in the RAW child log — a
  self-printed ERROR passes text match in the merged 2>&1 stream.
- **A5**: `dummy_floor` token 4 pins zero-vs-positive on
  solver_iterations, not the engine's literal default 16.0 — a host
  tuned to 8 previously failed as "refusal drift".

## Record corrections (no landed byte affected)

- **The parked nav cell was NOT a scout falsehood.** Reviewer F1 +
  verifier independently reproduced BOTH sides: scout's `safe_n=10`
  byte-identical whenever a `project.godot` exists (17/17 incl. an
  EMPTY project file), author's `safe_n=0` only in the project-less
  harness layout (11/11). The replication harness lacked the project
  file; the battery always copies one in. The park decision stays
  correct on procedure (unreplicated-under-harness), but the recorded
  ground was wrong — the witness is real; r87 may re-arm it via the
  battery path, not via re-deriving pins.
- Reviewer F2: `r86-baseline.md` phase-2 said PENDING while its own
  green post-commit receipts existed — noted, report is the seat's own.
- Author's "each new child log byte-identical" needs the scratch-path
  carve-out (verifier: floorrealproj varies by embedded path; 10/11
  hold).

## Residual risks

- Band is stochastic and load-sensitive; the two pinned points sit ~450
  statements clear on both sides (two-point ladder cannot see inside).
- `HANG_BOUND_S=8` is wall-clock; the row is ~9.1 s of its 20 s bound.
- Jolt/Dummy splits are one build (`4.7.2.stable.arch_linux.ed1daf0bf`).
- The merged child.log stream is a deliberate position-fidelity
  tradeoff; provenance now needs the callsite line (A4).

## Verdict

ADMIT-corr. Seats: author, boundary, baseline, scribe, critic,
reviewer, verifier, simplifier — all landed, all deepseek-flash.
