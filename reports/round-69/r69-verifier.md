# Game-dev-3d round 69 — independent non-author verification (host: devin)

Verifier did not author this round. Author report:
`.shokunin/game-dev-3d/reports/round-69/r69-author.md`.

## Rows executed

Independent full battery, absolute `--runs` per the author's caveat:

    python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
      --runs /home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/round-69 \
      --probe-failing --probe-crash-exit --probe-stream-attribution --probe-tree-timeout

Receipt `corpus/live/runs/round-69/20261013T165909014024Z/verdicts.json`:
**PASS, 85/85** (42 ordinary / 43 negative controls), `seeds_unchanged=true`,
godot `4.7.2.stable.arch_linux.ed1daf0bf` via `/usr/bin/godot`; all four probes
PASS (`crash-exit`, `stream-attribution`, `tree-timeout`, mutation
`detected=true seeds_unchanged=true`).

## Agreement with author's run `20261013T165524265085Z`

- All 85 result rows byte-identical on every raw field: `case`, `script`,
  `flags`, `expected_exit`, `actual_exit`, `error`, `kind`, `marker`,
  `verdict`, `reasons`, full `stdout` and `stderr` arrays. Case order equal.
- Seed digest map identical (51 keys). Verdict, totals, seeds_unchanged and
  all four probe verdicts equal.
- Prior-83 stability confirmed independently: every pre-r69 case row is
  byte-identical to baseline `corpus/live/runs/20261013T133935795023Z` on the
  same fields; seed map 50→51 with exactly one new key
  `navagent3d_distance.gd` and the expected `run_battery.py` digest change
  (`b2933b35…` → `b992c7a5…`).
- `git diff` on `run_battery.py` is exactly +4 lines: the two CASES tuples.
  `navagent3d_distance.gd` sha256 verified:
  `b820e469c35e68cf60d3f87bda94c1968cbc9b943b78513a6bf61bd0761c803a`.

## New-marker verification (independent)

- `navagent3d_distance`: exit 0, exact marker
  `PASS navagent3d_distance distance=2.828427 final=3.000,0.000,3.000 next=3.000,0.000,3.000 reached=false reachable=true finished=false`.
  Geometry check: agent (1,0,1) → target (3,0,3), Δ=(2,0,2), |Δ|=√8=
  2.8284271; measured 2.828427 is consistent. `get_final_position` and
  `get_next_path_position` asserted to (3,0,3) within 0.001 inside the
  fixture and bound by the exact marker; `is_target_reachable=true` required
  by both internal check and marker.
- `navagent3d_distance_wide_reach`: expected/actual exit **2**, exact marker
  `NEGATIVE REJECTED: navagent3d_distance wide_reach distance=2.828427 reached=true finished=true reachable=true`.
  `target_desired_distance=3.0` > 2.828427 flips reached/finished true while
  measured distance is unchanged; the setup assertion pins
  `actor.global_position` to spawn (1,0,1) within 1e-4, so the "zero
  movement" claim is measured, not assumed.
- Discrimination proof (verifier private mutant, /tmp only, seeds untouched):
  scratch copy with agent spawn moved to (2,0,1) exits **1** with measured
  `distance=2.236068` (=√5, |(1,0,2)|) — the distance value is engine-measured,
  not a restated literal.

## Author's caveats — checked

- `20261013T165007161683Z` FAIL: 85/85 cases, tree-timeout FAIL only;
  `verdicts.json` records a **relative** scratch path
  (`.shokunin/game-dev-3d/...`) with `witness_verified=false` and "Godot
  cleanup exceeded 3 seconds" — consistent with the author's relative
  `--runs` diagnosis. My absolute-path run's tree probe passes.
- `20261013T165315209679Z` FAIL 84/85: sole failure `navagent3d_retarget`,
  `before=(1.754246,0.0,1.754246)` vs expected 1.730676 (drift 0.0236) —
  matches the claimed load-sensitive flake; both new cases passed in that
  receipt. Nuance: at r68 the same case flaked via an external SDL gamepad
  stderr line, a different failure mode; case-level intermittence stands but
  the numeric-drift mode is newly observed this round.
- UNKNOWN scope honest: on a single convex 4x4 polygon the path is a
  straight line, so 2.828427 cannot discriminate Euclidean vs path-sum
  `distance_to_target` semantics; the author claims only the measured value
  at this geometry. Correctly scoped.

## Disagreements

None.

## Verifier verdict (claim-level, not marked)

Author's claims reproduce exactly in independent replay: 85/85 + 4 probes,
byte-identical rows and seed map, both new markers measured live, negative
control discriminates, prior-83 byte-stable. Depth-improved claim is
supported within the stated scope; no axis evidenced harmed.

## UNKNOWNs (verifier-scoped)

- Euclidean vs path-sum semantics of `distance_to_target` remain
  undiscriminated (single convex polygon, straight corridor).
- `navagent3d_retarget` load-sensitive intermittence is host-contention
  evidence, not proven bounded; it did not recur in the verifier run.
- No claim on agent motion/avoidance, baking, multi-polygon or off-mesh
  targets, other engines, or rendered output.
