# r88 BOUNDARY (g3d) — audit-level (labrat, substrate read-only)

Read-only receipt forensics over corpus/live/r88-scout/runs/ (980 files)
plus independent arithmetic re-derivation. No live reps (no exec tool on
this dispatch substrate); report landed verbatim by the parent.

## Verdicts

- **Motion split (cast_motion honors, others ignore): CORROBORATED** —
  is_withmotion=2 ≡ is=2; cw/rw end-embedded sweeps empty; cm_zero=[1,1],
  cm_away≈0.598/0.600 (GP/Jolt) measured. Open falsification surface:
  margin+motion on collide/intersect, shape_rid+motion, rotated-basis
  transforms, area targets, mask=0.
- **Fetch-gate: CORROBORATED + sharpened** — refusal keys on `in_phys`,
  NOT frame parity (F refused at pf=1,2,3,4; deferred position B
  in-phase fetches fine on threaded). D-seam rep-stable cs=0/ri=0@D vs
  cs=2/ri=6@E. BYP bypass confirmed on both threaded backends. Gaps:
  _ready position unsampled; inactive-then-activated space untested.
- **Jolt freed-space: framing FALSIFIED** — 18 lives: 12 abort/6 benign,
  but 11/12 aborts die INSIDE the shared `bds.get_space_state()` fetch
  (crash.gd:61 SIGSEGV) before the queried method runs; only one life
  reached a live wrapper (std::system_error in the query). The honest
  claim: post-free `bds.get_space_state()` is a per-process-life coin
  flip (SIGSEGV vs dead handle); the "which methods abort" table is
  unproven — 17/18 lives never ran the method post-free. GP: 18/18
  SIGSEGV at _getspace (deterministic, same fetch). Dummy: 18/18
  typed-empty incl. live wrappers answering n=0.
- **Param purity: CORROBORATED where exercised** — before/after byte-
  identical on GP+Jolt; exclude/mask=0 fingerprints still missing.
  Side datum: assigning p.shape auto-populates shape_rid
  (shape_rid_valid=true everywhere; is_bothset=1 corroborates
  RID-beats-shape).
- **Inertia: tensor claim VERIFIED arithmetically** — R·diag·Rᵀ
  re-derived independently: rot-Y-30 degenerate exact; Euler(0.3,0.5,0.7)
  agrees ≤3e-4; custom (9,4,1)@rotY30 exact. **paxes "sorted" hypothesis
  FALSIFIED** — Jolt paxes are byte-identical to GP on the all-distinct
  tensor; divergence is confined to the degenerate eigenspace (y≡z
  eigenvector tie), not a magnitude sort. Same-step inertia reflection:
  no receipt — gap.

## Disposition

Core semantics survive adversarial audit. Fold-relevant corrections:
(1) pin the Jolt crash SITE as the shared fetch (breadcrumb envelope
    already proves this shape — extend wording, not structure);
(2) drop any per-method abort distribution in the author arm;
(3) note paxes divergence is eigenspace-tie only.
Named open surface (needs exec): margin/RID/rotated motion probes,
_ready+activated-space gate, ≥10-rep Jolt split under load/heap
manipulation, exclude/mask=0 purity, same-step inertia.
