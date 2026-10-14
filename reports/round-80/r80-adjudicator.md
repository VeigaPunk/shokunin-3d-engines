# R80 adjudicator (Sol) — bpy eval-event catalogue folded into the lattice

Round: 80. Wave: `shokunin-train-20261101-w11`. Work commits `faae4e0` + `e32e2de`.

## Declared move (depth)

Fold the frontier-measured eval-event catalogue into `bpy_sync_probe.py`
(`arm_evalcat`, 10 sub-probes) + 27 pinned battery cases. Claim under
test: "the eval-event set is enumerable and closed" — mechanical
falsifier armed (any bare/uninvoked row that flushes held or fires a
watched handler → edge=FALSIFIED, violations counter).

## Claim adjudication — bounded closure CONFIRMED

Union of four independent screens: author's own falsifier (violations=0),
boundary's 45-class graph-global sweep (hits=0), critic's 37-class sweep
(hits=0), simplifier's 12+2 sweep (0), scout's 10-class closure probe.
**Bounded over ~100 probed mutation classes** — no falsifier found.
"Closed" holds only over the probed surface (library linking, node-tree
sockets, 5.x action/slot assignment, render-engine writes unprobed) —
per critic, scorecard says *bounded*, and the `faae4e0` subject line's
"45+ classes" over-attributes the falsifier's own coverage (the falsifier
covers the 8 invoked=none rows; the class counts are the sweeps').

## In-set refinements measured

- `bpy.ops` event = the CALL not the mutation: CANCELLED ops, all-False
  FINISHED, and poll-failed RuntimeError all flush the shared graph
  (dup≥1 pinned, never exact — multiplicity jittered).
- `scene.frame_current = n` is a TAG, not a frame event — leaves the
  graph dirty; next tagged `get` flushes it with NO frame_change handlers
  (frame_set incl. same-frame fires fc only). Closes r79's open cell.
- Tagging ≠ evaluating (`update_tag` leaves held stale); ID removal is
  not an eval event; msgbus/undo_post dead headless.

## Corrections folded

- simplifier D1: `slept=` kwarg dropped — it was the ONLY inter-run
  stdout diff; replay now byte-identical ×2.
- critic: `non_signal` quirk rows already split from the verdict gate at
  r79's 9afcdc2; RNA witness rows relabeled.
- critic fold-guidance: ~6 representative bare-row classes land in the
  tracked catalogue — deferred to r81 (evalcat extension rows), noted.

## Seat accounting

8/8 seats + verifier-capable sweeps landed: scout built the verified
fold spec (67/67), boundary screened 45 classes pre-land, author ran
64/64 + falsifier liveness (0→1→1→1→2 on synthetic flush), critic 37-class
+ parser-hazard demo, simplifier independent 83/83 refold + D1 drift
catch, scribe cross-verified byte-identical battery hashes vs the r79
verifier's. Operator integration replayed 64/64 twice.

## Verdict

**ADMIT** — bounded closure confirmed, lattice extended by a measured
event catalogue; falsifier remains armed in the tracked fixture.
