# Adjudicator report — round 96 (Jolt determinism lattice)

DECISION: **ADMIT** on `dd054a2`. 12 rows (304→316), all five wave-B gates landed clean:
verifier VERIFIED (316/316 full run, 492/492 cells re-derived), critic PASS, reviewer
ADMIT-recommend, simplifier PASS (SP1-4 −14 queued), scribe AUDIT PASSES.

Encodings that survived attack:
- Jolt warning = expected-error class (allowlist + near-miss self-gate, mutation-proven in vivo)
- --time-scale = tps law, byte-identical on both backends under --fixed-fps
- Dummy vacuity with in-cell live GP/Jolt controls; sleep1 hang pinned rc=137 w/ 128KiB cap

Fold queue:
1. SP1-4 simplifier deletions (−14 parent lines, proven byte-identical)
2. Critic F1: thread row can't detect a dropped 3d/run_on_separate_thread line — fold
   `thr_knob=1` diagnostic.
3. Header-precision fixes (3-seat consensus): "new warning fails the arm" is wrong (exact-marker
   check is the gate); nc impulse is pose-only; "censused" applies to Jolt warning only.
4. Reviewer F1: rare thread-child stall under batch-spawn+load (~1/13) — file the class.
