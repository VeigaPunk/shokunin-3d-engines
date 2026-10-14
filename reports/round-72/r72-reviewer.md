# Game-dev-3d round 72 — reviewer (non-author audit of round 71)

Reviewer did not author round 71. Audited artifacts:
`corpus/fixtures/navagent3d_detour.gd`, `corpus/fixtures/run_battery.py`,
`reports/round-71/r71-{author,verifier,adjudicator}.md`, commit `6888875`
(r71 integration) and `996ea37` (r71 adjudication, = HEAD).
All work read-only against seeds; receipts and scratch under
`corpus/live/r72-reviewer/` (gitignored, per lane convention).
Host: devin; `/usr/bin/godot` 4.7.2.stable.arch_linux.ed1daf0bf;
python 3.14.x; Node v24.21.0; canonical repo HEAD
`996ea376f1e5d7cc8be38429f7f97f1a8b7018c7`.

## Per-claim verdicts

| # | r71 claim | verdict | evidence |
|---|-----------|---------|----------|
| 1 | Default arm: exit 0, `distance=3.605551` (full marker `PASS navagent3d_detour distance=3.605551 semantic=euclidean final=2.500,0.000,3.500 next=2.000,0.000,1.000 pathlen=4.130649 reachable=true reached=false finished=false`) | **AGREE — byte-exact** | Tracked fixture invoked by absolute path against a scratch project (`corpus/live/r72-reviewer/spotcheck/`, copy of committed `project.godot`): `/usr/bin/godot --headless --path . -s …/corpus/fixtures/navagent3d_detour.gd` → exit 0, stdout byte-exact vs the CASES literal, stderr empty (`spotcheck/arm-default.out`/`.err`). |
| 2 | `--post-edgecentered`: exit 0, pinned `pathlen=4.707107`, invariant `distance=3.605551` + `final=2.500,0.000,3.500` | **AGREE — byte-exact** | Same invocation + `-- --post-edgecentered` → exit 0, verbatim `PASS navagent3d_detour post_edgecentered distance=3.605551 semantic=euclidean final=2.500,0.000,3.500 next=2.000,0.000,0.500 pathlen=4.707107 reachable=true reached=false finished=false` (`arm-post-edgecentered.out`). Path demonstrably reshaped (4 pts, next (2,0,0.5)) while distance/final invariant — the invariance discrimination is non-vacuous. |
| 3 | `--post-none`: exit 0, pinned `pathlen=4.549510`, invariant `distance=3.605551` + `final=2.500,0.000,3.500` | **AGREE — byte-exact** | `-- --post-none` → exit 0, verbatim `PASS navagent3d_detour post_none distance=3.605551 semantic=euclidean final=2.500,0.000,3.500 next=2.000,0.000,0.500 pathlen=4.549510 reachable=true reached=false finished=false` (`arm-post-none.out`). Distinct pathlen from edgecentered (~39× tol) separates the two post arms despite identical `next`. |
| 4 | `--assert-pathsum`: exit 2 (refuted-hypothesis negative) | **AGREE — byte-exact** | `-- --assert-pathsum` → exit 2, verbatim `NEGATIVE REJECTED: navagent3d_detour assert_pathsum distance=3.605551 expected_pathsum=4.130649 euclid=3.605551` (`arm-assert-pathsum.out`). |
| 5 | `--straight`: exit 2 with `2.828427` (non-discriminating control) | **AGREE — byte-exact** | `-- --straight` → exit 2, verbatim `NEGATIVE REJECTED: navagent3d_detour straight distance=2.828427 euclid=2.828427 pathlen=2.828427 discriminates=false` (`arm-straight.out`). |
| 6 | Full battery 90/90 + 4 probes on committed state | **AGREE** | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --godot /usr/bin/godot --runs …/corpus/live/r72-reviewer/runs --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → `PASS battery`, `totals: cases=90 pass=90 fail=0 ordinary=45 negative_controls=45 probes=4`. Receipt `runs/20261014T003502493594Z/verdicts.json`: `verdict=PASS`, `seeds_unchanged=true`, `godot_version=4.7.2.stable.arch_linux.ed1daf0bf`, `crash_probe_ok`/`stream_probe_ok`/`tree_probe_ok=true` (own receipts in the run dir), mutation probe `detected=true` verdict PASS (`mutant_body3d_contact` exit 1 with the authored contact-plane diagnostic). All five detour rows byte-exact (claim 1–5 markers). No mid-run seed drift this round — `git status --porcelain` showed zero modified tracked files before and after. |
| 7 | Node three.js suites 31/31 | **AGREE** | `cd corpus/fixtures/three && node run_{cases,layer_cases,order_cases,camera_cases,ortho_cases,ray_cases}.mjs --receipt …/runs/node/run_*.json` → 3/3, 4/4, 9/9, 5/5, 5/5, 5/5 = **31/31 PASS**, every suite `seeds_unchanged=true`, every exit 0. Receipts `corpus/live/r72-reviewer/runs/node/run_*.json`. Node v24.21.0, pre-provisioned three.js 0.186.1 node_modules — same environment as the r71 verifier. |
| 8 | Commits `6888875` / `996ea37` resolve and are ancestors of HEAD | **AGREE** | `git cat-file -t` → `commit` for both; full shas `6888875741143180f6b130321ce0a35a77518ef0` / `996ea376f1e5d7cc8be38429f7f97f1a8b7018c7`; `git merge-base --is-ancestor <c> HEAD` → true for both (`996ea37` *is* HEAD). Shapes: `6888875` = +933/−0 across 8 files (fixture +45 additive post arms, `run_battery.py` +4 = the two declared CASES tuples, six r71 reports); `996ea37` = +135/−2 (LOG +10, SCORECARD +4/−2, lesson +69, adjudicator +54). Between them `e89850e` added the three sibling reports (+745/−0). Hashes resolve only in the canonical repo `~/Projects/shokunin/game-dev-3d-shokunin`, not the `prymeagnt` worktree repo — carried-forward discoverability caveat. |
| 9 | Fixture/runner content at HEAD == r71 integration state | **AGREE** | `git diff 6888875 HEAD -- corpus/fixtures/` is empty (the two later commits touch only reports/LOG/SCORECARD/lesson). sha256 reproduced both from the working tree and `git cat-file blob HEAD:…`: fixture `5b873cd06a8f50cb98a97764eb914e2a80f8553edb9ae216543979624d531647`, runner `b4b314997177c0a53ebd9cdf1f94f4ba91f3e7e7d774f4f4154e9169b1513809` — identical to the r71 verifier's cited values. |
| 10 | Prior 90 rows field-stable | **AGREE** | `corpus/live/r72-reviewer/diff_baseline.py` over my receipt vs the r71 verifier receipt `corpus/live/r71-verifier/runs/20261013T235428282427Z/verdicts.json` on the 11 raw fields (case, script, flags, expected/actual exit, kind, marker, verdict, reasons, stdout, stderr): **0 mismatches over 90 shared cases × 11 fields**; ordering identical; seed map 52→52 with zero added/removed/changed keys. Caveat carried forward: both receipts are gitignored/on-disk artifacts. |

## Disagreements

None. All eight audited claim families plus the two stability claims
re-measured fresh agree with the r71 record — including the honest
narrowing the adjudicator recorded (`final` postprocessing-invariant at
(2.5,0,3.5), the claim's "final changes" clause measured false).

## Reviewer conclusion (claim-level, not marked)

Every audited r71 claim reproduces on committed state at HEAD `996ea37`:
the five detour arms return byte-exact markers/exits (0/0/0/2/2) with the
pinned pathlens 4.130649 / 4.707107 / 4.549510 and invariant
distance/final, the battery is 90/90 + 4 probes with
`seeds_unchanged=true`, the Node suites are 31/31, both cited commits
resolve as ancestors of HEAD with the reported shapes, both cited sha256s
verify, and the 90×11 field comparison vs the r71 receipt is clean. The
Euclidean-invariance resolution of `distance_to_target` under
`path_postprocessing` stands on this engine build, as scoped.

## Residual risk / verification gaps

- The compared battery receipts are gitignored/on-disk only (carried from
  r70/r71); the 90-row field equality is a two-receipt comparison, not a
  tracked artifact.
- `navagent3d_retarget` intermittence (r68/r69) did not manifest in my
  full run — still open, not refuted.
- Bounded scope unchanged: stationary agent at path start, single region,
  cell_size 0.25, default desired-distances, Godot 4.7.2 headless,
  authored geometries only.
- The lane's r72 declared axis-move (pdd pop-index vs agent position;
  two-mode `is_navigation_finished` with equality edges) is the author's
  live work item; this audit neither confirms nor refutes it — I ran no
  pdd/navigation-finished arm.
- `next` is identical under edgecentered(1) and none(2) on this geometry;
  arm separation rides on `path[2]`/`pathlen` pins (4.707107 vs 4.549510),
  which the fixture enforces — sound, but worth noting for the r72 author
  extending this file.
- Report is a recommendation; admission belongs to the canonical judge.
