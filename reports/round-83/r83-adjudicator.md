# R83 adjudicator (Sol) — PhysicsServer3D two-tier lattice

Round: 83. Wave: `shokunin-train-20261101-w14` (recovery dispatch — the
first seat generation died with its parent session ~16:10Z; all landed
work is the 16:20Z+ respawn generation). Work commit `e9145d9`, folds
commit `4c1c100` (post-fold fixture sha `1e042bcf…`; the author report's
`6ddf4aef…` citation describes the pre-fold tree — recorded here).

## Declared move

Arm `phys3d_events.gd` with ten CASES rows pinning the PhysicsServer3D
two-tier lattice: same-turn edge-0 queries (`intersect_shape`,
`cast_motion`, `body_test_motion`, `intersect_ray` via `pp_queries`) vs
tick-bound generated events (`get_contact_count` staleness,
`body_entered`/`body_exited`, `area_set_monitor_callback`,
`body_set_state_sync_callback`), plus `static_nopair` negative and
`threaded_edge` ST conversion.

## Claim adjudication

- **Two-tier split CONFIRMED, by event kind** — 186/186 on the landed
  tree, verifier AGREE 18/18 (case tables byte-identical ×4 across
  author+verifier runs, `c0c3fcbb…` normalized hash; prior 176 rows
  byte-identical to the r82-verifier receipt — cross-round zero drift).
  The scout's premise-correction stands: the partition is not
  "direct-state vs server" but query APIs (edge-0 anywhere) vs
  server-generated events (next-tick).
- **critic C1 CONFIRMED + folded** — tick-tier latency is
  write-phase-dependent: `delta=1` from a physics-phase write, `delta=2`
  from process-phase (`phase.*`/`sphase`/`cphase` probes, 5/5 ×3,
  DEFAULT/threaded/Jolt byte-identical). README/header "exactly one
  tick" was false as stated → qualified.
- **critic C2 CONFIRMED + folded** — `static_nopair` is
  GodotPhysics3D-scoped: under Jolt the teleported static pairs
  (ov=1 sig=1, 3/3, on copied seeds). The "only re-pairs movers" rule
  does not transfer. Fixture defect folded too: `sig_log` is now
  cleared before the control so `mv_delta` can't read stale entries.
- **reviewer F2 folded** — `threaded_edge` child spawn wrapped in
  `timeout -s KILL 30`; a hung child previously orphaned past the
  battery's kill of the `/bin/sh` parent (receipt: orphan-evidence).
- **reviewer F3/F4 folded** — null process-context `dss` now fails
  named instead of hanging to the 20 s bound; child-log scan fails on
  any unexpected `ERROR:` class (the 11 refusal lines remain the
  expected witness).
- **simplifier D1/D2/D4/D5/V6 folded** — dead `tries` store, vestigial
  `sh_out` binding, `early_null` collapse, `_fail`-form normalize. All
  five replay-identical under the simplifier's full-battery diff
  (`FULL_BATTERY_IDENTICAL`); integrator re-verified 186/186 on
  `4c1c100`.
- **ST hedge corrected** — process-context `space_get_direct_state`
  refusal is a deterministic context gate (the one granted sample is
  always the in-physics one, 12/12), not a race; README reworded,
  pinned bound stays `nulls >= 8` for host variance.
- **Recorded, not folded** — Jolt-pinned backend rows (additive cells)
  → r84 frontier, along with contact-signal timing depth and the DSS
  startup-window usability hole.

## Seat accounting

9/9 reported: author (10 CASES rows + new fixture + README; 186/186 ×2
author receipts; Jolt fingerprints + threaded rebind measured);
scout — premise-correction (partition by event kind; Jolt present;
ST = access-window gate not deferral) steered the author mid-flight;
boundary; baseline (bpy 83/83 + Godot 186/186 + three.js 31/31, prior
rows preserved on freeze `f8a088c`); scribe (archived dead draft,
flagged stdout→stderr join hazard pre-landing); critic 3dc2c9d7
C1/C2 counterexamples landed; reviewer 844244ab F1–F6 (MED F1/F2,
LOW F3–F6; replay byte-identical); simplifier e647f5e0 five proven
deletions; verifier e1230ad8 AGREE 18/18.

## Verdict

**ADMIT-corr** — lattice confirmed with backend scope honestly named
(GodotPhysics3D-pinned, Jolt inversion recorded); all folded corrections
verified by integrator re-run (186/186 on folded tree). Bounded:
Godot 4.7.2.stable.arch_linux.ed1daf0bf, GodotPhysics3D/Jolt pair,
this host. Jolt-specific constants and the timing-depth frontier are
r84 material.
