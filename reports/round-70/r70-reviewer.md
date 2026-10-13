# Game-dev-3d round 70 — reviewer (non-author audit of round 69)

Reviewer did not author round 69. Audited artifacts:
`reports/round-69/r69-author.md`, `reports/round-69/r69-verifier.md`,
`corpus/fixtures/navagent3d_distance.gd`, `corpus/fixtures/run_battery.py`.
All work read-only against seeds; receipts under
`corpus/live/r70-reviewer/` (gitignored, per lane convention).
Host: devin; `/usr/bin/godot` 4.7.2.stable.arch_linux.ed1daf0bf; python 3.14.7.

## Per-claim verdicts

| # | r69 claim | verdict | evidence |
|---|-----------|---------|----------|
| 1 | Default arm: exit 0, marker `distance=2.828427 final=3.000,0.000,3.000 next=3.000,0.000,3.000 reached=false reachable=true finished=false` | **AGREE** | Fresh direct run `/usr/bin/godot --headless --path corpus/live/r70-reviewer/scratch --script res://navagent3d_distance.gd --` → exit 0, byte-exact marker, empty stderr (`corpus/live/r70-reviewer/arm-default.out`). Δ=(2,0,2), √8=2.8284271 — measured value consistent. |
| 2 | `--wide-reach` (target_desired_distance 3.0): exit 2, `reached=true finished=true`, identical `distance=2.828427` | **AGREE** | Same command + `-- --wide-reach` → exit 2, byte-exact `NEGATIVE REJECTED: navagent3d_distance wide_reach distance=2.828427 reached=true finished=true reachable=true` (`corpus/live/r70-reviewer/arm-wide.out`). Threshold flip without movement confirmed; setup pin `actor.global_position` to (1,0,1) ±1e-4 at fixture line 49 makes zero-movement measured, not assumed. |
| 3 | Battery 85/85 on committed state (42 ordinary / 43 negative), seeds_unchanged=true, 4 probes PASS | **AGREE** | Fresh full run `python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r70-reviewer/runs --probe-failing --probe-crash-exit --probe-stream-attribution --probe-tree-timeout` → `PASS battery`, `totals: cases=85 pass=85 fail=0 ordinary=42 negative_controls=43 probes=4`, receipt `corpus/live/r70-reviewer/runs/20261013T220023340494Z/verdicts.json`: verdict PASS, seeds_unchanged=true, crash/stream/tree probes ok, mutation probe `detected=true`. Ran on HEAD `e054cfe`; `git diff 1e6199b HEAD -- corpus/` = 0 lines, so committed corpus state is exactly the r69 work. |
| 4 | Work hash `1e6199b` resolves / is ancestor | **AGREE, scoped** | In canonical lane repo `~/Projects/shokunin/game-dev-3d-shokunin`: `git cat-file -t 1e6199b` → commit; `git merge-base --is-ancestor 1e6199b HEAD` → true (HEAD `e054cfe`; intermediates are README/HOURS.md commits, corpus-untouched). Commit stat matches report exactly: fixture +79, run_battery.py +4, LOG +7, SCORECARD +1, two reports. Note: `1e6199b` does **not** resolve in the prymeagnt worktree repo (`git cat-file -t` → fatal there; r69-equivalent commit is `a5e52e45`). The cited hash lives in the canonical repo that `.shokunin/game-dev-3d/` resolves into — consistent with the brief's prefix semantics, but a reader working only in the worktree repo cannot resolve it. |
| 5 | Fixture sha256 `b820e469…` | **AGREE** | `sha256sum corpus/fixtures/navagent3d_distance.gd` → `b820e469c35e68cf60d3f87bda94c1968cbc9b943b78513a6bf61bd0761c803a` at working tree AND via `git show 1e6199b:corpus/fixtures/navagent3d_distance.gd`. run_battery.py sha `b992c7a5f135b2e4fd83104eae41deaaf93f4e7c74ea5af2361b3a8a650b46ea` likewise verified at `1e6199b` and HEAD. |
| 6 | run_battery.py diff exactly +4 lines | **AGREE** | `git show 1e6199b -- corpus/fixtures/run_battery.py` → exactly 4 added lines: the two CASES tuples (`navagent3d_distance` exit 0, `navagent3d_distance_wide_reach` flags `["--wide-reach"]` exit 2), no other changes. |
| 7 | Distance is engine-measured, not a literal (verifier mutant: spawn→(2,0,1) → exit 1, `distance=2.236068`=√5) | **AGREE — independently replicated** | Own scratch mutant (`corpus/live/r70-reviewer/mutant-scratch/`, `sed 's/Vector3(1, 0, 1)/Vector3(2, 0, 1)/g'` covering spawn line 31 + setup pin line 49): exit 1, stderr `navagent3d_distance: measured distance/final/next mismatch distance=2.236068 final=(3.0, 0.0, 3.0) next=(3.0, 0.0, 3.0) reachable=true` (`arm-mutant.err`). \|(1,0,2)\|=√5=2.2360679 — value is measured per-geometry. Note: the pin literal must move with the spawn or the setup check (`live navigation agent/map setup absent`) fires first; the verifier's "(2,0,1)" shorthand implies the same paired edit. |
| 8 | Prior-83 rows byte-stable vs baseline `20261013T133935795023Z`; seed map 50→51 adds only `navagent3d_distance.gd` | **AGREE, partial evidence** | r69 receipts under `corpus/live/runs/` are gitignored and no longer on disk — direct byte-diff vs the author's run impossible. Substitute evidence: all 85 of my rows are byte-identical on every raw field (case, script, flags, expected/actual exit, error, kind, marker, verdict, reasons, full stdout/stderr) vs `corpus/live/r70-baseline/runs/20261013T215959381187Z` (independent same-committed-state run this round, also 85/85 PASS); seed digest map identical, 51 keys. Both new markers byte-exact as quoted. The 50→51 seed-map claim itself is consistent with my 51-key map but I did not recount against a pre-r69 map. |
| 9 | Caveat honesty: `165007161683Z` tree-timeout FAIL = relative `--runs` artifact; `165315209679Z` 84/85 = `navagent3d_retarget` load flake | **AGREE (not re-observed)** | Diagnoses are internally consistent with the verifier's receipt readings. In my run `navagent3d_retarget` passed clean (exit 0, expected marker) — the intermittence remains a documented host-contention UNKNOWN, not reproduced or refuted here. Absolute `--runs` used throughout per the author's rule; tree-timeout probe passed. |
| 10 | UNKNOWN honestly scoped: Euclidean vs path-sum indiscriminable on single convex 4x4 polygon | **AGREE** | Fixture authors one convex quad polygon (`mesh.add_polygon([0,3,2,1])` on 4x4 vertices, line 25); straight corridor (1,0,1)→(3,0,3) lies inside it, so path-sum and Euclidean coincide at 2.828427. Claim is correctly bounded to the measured value at this geometry — exactly the UNKNOWN r70's `navagent3d_detour.gd` is declared to resolve. |

## Disagreements

None. One documentation nuance (claim 4): the work hash resolves only in the
canonical lane repo, not the `~/Projects/prymeagnt/game-dev-3d` worktree repo —
a reader must resolve `1e6199b` through the `.shokunin/game-dev-3d/` canonical
path. Not a falsification; a discoverability note.

## Reviewer conclusion (claim-level, not marked)

Every r69 claim re-measured fresh on the committed state agrees: both
`navagent3d_distance` arms reproduce byte-exact markers and exit codes,
85/85 + 4 probes PASS with `seeds_unchanged=true`, `1e6199b` resolves as an
ancestor carrying exactly the reported diff, both cited shas verify, and the
engine-measured distance discriminates under mutation. The Euclidean-vs-
path-sum UNKNOWN is honestly scoped and correctly motivating the r70 detour
fixture. No axis evidenced harmed.

## Residual risk / verification gaps

- Author's r69 run receipts are gitignored and absent; prior-83 byte-stability
  was checked against a same-state independent run, not the author's files.
- `navagent3d_retarget` intermittence (two distinct modes across r68/r69)
  unexercised this pass — still open.
- No claim replayed beyond scope: motion/avoidance, baking, multi-polygon,
  off-mesh targets, other engines, rendered output — all remain unprobed.
