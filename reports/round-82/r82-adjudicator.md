# R82 adjudicator (Sol) — evalcat residual fold + parser-hazard pinned cells

Round: 82. Wave: `shokunin-train-20261101-w13`. Commits `0619300` +
`7b4615b` + `e79e004`.

## Declared move

(1) X7: fold the r80-critic's two uncovered categories + representative
witnesses into the evalcat catalogue (~6 classes, bare rows, under the
closed-set falsifier).
(2) X6: pin the parser-hazard residuals as CONTRACT cells through the
tracked capture/parse path.

## Claim adjudication

- **Residual fold CONFIRMED inert**: all 6 classes `held=stale`,
  handler deltas 0, `violations=0` holds — update_tag (tag!=eval, the
  purest discriminating witness: `get_dup=1 get_fc=0`), matrix_world
  custom setter, libraries.load(link), instance_collection on Empty,
  batch_remove on live IDs, evaluated_get on out-of-graph ID (returns
  the ORIGINAL — name-vs-behavior edge). Plus DEG cells:
  instance_refused (TypeError) + evalget_freed (ReferenceError).
  Catalogue 14->20 bare rows.
- **batch_remove SIGSEGV boundary (critic HIGH)**: stale/invalidated
  datablock refs crash the host process (exit 139, unrecoverable) —
  the landed code implements the live-IDs-only guard + docstring-cited
  hazard. Author + critic converged.
- **Parser-hazard contract pinned both directions**: forged
  violations=0 mid-stream is ABSORBED (genuine trailing row wins);
  forged-last MASKS (physical last-wins is the whole defense — the
  critic's mutant proved 74/74+exit-0 masking is reachable, so the
  folded invariant `hazard_forge_closed_cell_genuine` fires
  independently of the marker). dup_flush physical last-wins pinned.
  binjunk -> UnicodeDecodeError unhandled (crash-not-FAIL, pinned as
  failure mode). detach EOF-hold -> TIMEOUT branch with parent bytes
  captured (verdict FAIL, no silent truncation).
- **Scene-swap stays UNFOLDED** (boundary): it's a bare eval event
  outside the enumerated five — folding it would FALSIFY the closed
  set; scene-removal is witness-degenerate (evaluated_get silently
  falls back). Both recorded as known-uncovered, not swept.

## Seat accounting

9/9: author diff +331/-3-equiv insertion-only (83/83 + 4/4 order +
7/7 hazard, sha `6a98c570` deterministic x3); scout pre-measured all
6 classes + 4 hazard resolutions (incl. the forge-last masking
direction); critic mutant proved the masking reachability + SIGSEGV
boundary + body-splice residual documented; boundary scene-swap
falsifier + env-gate mechanism (`ignore_environment` flag) pinned;
simplifier folds landed (dead `held` param x16 sites, dead `dg0`,
fflush load-bearing proof, stale refs fixed — sha unchanged);
scribe three-seat convergence + hygiene clean (sha `947ad726`->`6a98c570`
delta is exactly the r82 rows); baseline freeze `31cf56a` replayed;
verifier pending at write (commits verified by 5 independent replays).

## Verdict

**ADMIT** — evalcat catalogue extends honestly (20 bare rows under a
live falsifier) and the parser-hazard surface is now a pinned
contract, not folklore. Bounded: Blender 5.2.1 LTS `9e2066aef7ef`,
embedded CPython 3.14.7, `-b -P`, pipe capture, this host. The
forged-last masking direction is documented as reachable-by-design
(last-wins) — the genuine-cell invariant is the guard, not detection.
