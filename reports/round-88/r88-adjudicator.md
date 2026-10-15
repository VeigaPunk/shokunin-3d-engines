# R88 adjudicator — PhysicsDirectSpaceState3D read family, fetch gate, body-state inertia

Round: 88. Wave: `shokunin-train-20261101-w21/w22` mixed ds-flash /
swe-2 / Sol / zfl seats. Work commit `3028263` (+2024 lines, nine
cells); fold lands in this commit.

## Declared move

Nine query/body-state cells on `phys3d_events.gd`:
`motion_split`, `fetch_gate`, `inactive_space`, `param_purity`,
`body_inertia`, `wrong_args`, `geom_split`, `race_class`,
`freed_space_methods` — plus the `_child_prepare`/`_child_scan` split
and `_spawn_batch` (13 crash children in ~3 s, own `timeout -s KILL`
bounds + a fail-closed batch deadline).

## Claim adjudication

- **Read-family split CONFIRMED** — `cast_motion` alone applies
  `motion`; the other five query methods ignore it in the tested
  shared-parameter setup. Author 210/210 ×2; verifier independent
  210/210 ×2 with 0 tuple mismatches over 210×6 fields.
- **Fetch gate CONFIRMED** — threaded acquisition is phase-gated
  (grant=2/refuse=6, one ERROR per acquisition path per refused
  sample, log-counted); a held handle bypasses refusal with the SAME
  dss object — now parent-witnessed by emitted id pairs (C6).
- **Inactive space CONFIRMED** — gated by step cycle, not activation.
- **Backend envelopes CONFIRMED + per-method identity ARMED** —
  freed-space outcome is the shared post-free `bds.get_space_state()`
  fetch (boundary falsified the per-method framing; marker now reads
  `@post_fetch`); the per-method dimension lives at the VM dead-handle
  line, which the fold counts method-qualified (C1).
- **Prior-row stability CONFIRMED** — 201/201 index-identical on both
  verifier runs; 14/14 spawn-heavy prior rows byte-identical under
  the prepare/scan split.
- **Forges** — verifier killed expected-token/breadcrumb/torn-channel
  forges + row-deletion isolation; critic's FORGE A (all-six-`pt`)
  passes pre-fold → killed by the C1 method-witness conjunct;
  FORGE B truthy bypass → killed by C6 id pairs; FORGE C Jolt
  shape-null 3→4 → killed by C3 count pin; REPLAY-5 unadmitted-ERROR
  dead-branch → killed by C2 `errs` conjuncts.

## Corrections folded

Simplifier C9 (−27-line proven vfold: dead `gp_ok`, tautological
motion_split re-check, contradictory comment pair, 12→13 census
wording; sha `74399b0a…`, tuple-identical) + critic C1 (per-method
`Nonexistent function` witness), C2 (`errs.is_empty()` on the three
real-backend envelopes), C3 (`wa_counts[1][2]==3`), C4 (`exclude`
fingerprint now `str(p.exclude)` — injective), C5 (`blocked [1,1]`
named as a torn class, not a violation), C6 (`byp_ids` parent-visible
identity witness), C7/C8 (marker/README wording vs measured sites),
scribe F5 completion (`if_fired` bucketed pin — `dummy_cb=never` now
earns both callback halves).

## Sentinel findings → r89 queue (recorded, not folded)

S1 sibling-log forgery (batch children share the parent's `res://`
tree — a forged sibling `child.log` is indistinguishable); S2
deadline kills the `/bin/sh` wrapper not the payload (`ECHILD` +
`code=0` misreport); S3 `dirname="../…"` path traversal reaches
outside the project root incl. `../phys3d_events.gd` self-trojan;
S4 last-match-wins verdict parser; S5 kill-by-pid without identity.
All five live-reproduced; remediations named (scan-at-exit,
dirname validation, `setsid`+group kill, `bound_s ≤ BATCH_BOUND_S`).
These are harness-hardness classes for the next round's fold — the
engine-level claims stand independent of them.

## Record notes

- rep-run `seeds modified` FAIL at 06:04 was the fold landing
  mid-battery (the integrity gate working); the clean re-run
  (`corpus/live/r88-fold/runs/20261015T061055708245Z`) is 210/210.
- Crash/dead Jolt branches stay envelope-pinned — branch-stable, no
  distribution over-claim.

## Verdict

**ADMIT-corr** — the r88 read family is pinned with method-qualified
witnesses, injective fingerprints, admitted-error conjuncts, and
parent-visible identity proofs. Seats: scout, author (ds-flash),
baseline, boundary, critic (ds-flash retry after empty Sol), verifier
(swe-2), simplifier, sentinel (swe-2), scribe; fold + adjudicator
swe-2.
