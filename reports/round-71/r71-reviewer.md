# Game-dev-3d round 71 — reviewer (non-author audit of round 70)

Reviewer did not author round 70. Audited artifacts:
`reports/round-70/r70-author.md`, `reports/round-70/r70-verifier.md`,
`reports/round-70/r70-adjudicator.md`, `corpus/fixtures/navagent3d_detour.gd`,
`corpus/fixtures/run_battery.py`, frozen baseline receipt
`corpus/live/r70-baseline/runs/20261013T215959381187Z/verdicts.json`.
All work read-only against seeds; receipts and scratch under
`corpus/live/r71-reviewer/` (gitignored, per lane convention).
Host: devin; `/usr/bin/godot` 4.7.2.stable.arch_linux.ed1daf0bf;
python 3.14.7; canonical repo HEAD `9458c183988c8428503b9287d51cd86f7a48378b`.

## Per-claim verdicts

| # | r70 claim | verdict | evidence |
|---|-----------|---------|----------|
| 1 | Default arm: exit 0, marker `distance=3.605551 semantic=euclidean` (full: `PASS navagent3d_detour distance=3.605551 semantic=euclidean final=2.500,0.000,3.500 next=2.000,0.000,1.000 pathlen=4.130649 reachable=true reached=false finished=false`) | **AGREE — byte-exact** | Fresh scratch project `corpus/live/r71-reviewer/spotcheck/` (copy of committed `project.godot` + `navagent3d_detour.gd`, copied 20:35:43 local, sha `669c539d…` = committed blob); `/usr/bin/godot --headless --path . --script res://navagent3d_detour.gd --` → exit 0, stdout byte-exact vs CASES marker, stderr empty (`arm-default.out`/`.err`). Ran 20:35:54, before any r71 working-tree edit (§incident). |
| 2 | `--assert-pathsum` arm: exit 2 (refuted-hypothesis negative) | **AGREE — byte-exact** | Same scratch + `-- --assert-pathsum` → exit 2, verbatim `NEGATIVE REJECTED: navagent3d_detour assert_pathsum distance=3.605551 expected_pathsum=4.130649 euclid=3.605551` (`arm-pathsum.out`). |
| 3 | `--straight` arm: exit 2 with `2.828427` (non-discriminating r69 reproduction control) | **AGREE — byte-exact** | Same scratch + `-- --straight` → exit 2, verbatim `NEGATIVE REJECTED: navagent3d_detour straight distance=2.828427 euclid=2.828427 pathlen=2.828427 discriminates=false` (`arm-straight.out`). |
| 4 | Full battery 88/88 + 4 probes on committed state | **AGREE** | Isolated committed-state replay (see §incident for why isolation was required): `git archive HEAD corpus/fixtures` → `corpus/live/r71-reviewer/baseline-tree/` (fixture sha `669c539d…`, runner sha `5a7d6c1…` in the archive copy), then `python3 corpus/live/r71-reviewer/baseline-tree/corpus/fixtures/run_battery.py --godot /usr/bin/godot --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r71-reviewer/runs --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing` → `PASS battery`, `totals: cases=88 pass=88 fail=0 ordinary=43 negative_controls=45 probes=4`. Receipt `corpus/live/r71-reviewer/runs/20261013T234014382944Z/verdicts.json`: `verdict=PASS`, `seeds_unchanged=true`, `godot_version=4.7.2.stable.arch_linux.ed1daf0bf`, `crash_probe_ok/stream_probe_ok/tree_probe_ok=true`, mutation probe `detected=true` verdict PASS. Three detour rows exit 0/2/2 byte-exact. |
| 5 | Commits `2a0e46f` / `0ea70cf` / `9458c18` resolve and are ancestors of HEAD | **AGREE** | In canonical repo: `git cat-file -t` → `commit` for all three; `git merge-base --is-ancestor <c> HEAD` → true for all three; HEAD *is* `9458c18`. Shapes verified: `2a0e46f` = +1084/−0 (fixture +137, `run_battery.py` +6, seven reports); `0ea70cf` = `r70-simplifier.md` +124 only; `9458c18` = +3135/−2 (adjudicator + verifier reports, two lesson files, LOG +9, SCORECARD +4/−2). Note: these hashes resolve in the canonical repo (`~/Projects/shokunin/game-dev-3d-shokunin`), not the `~/Projects/prymeagnt/game-dev-3d` worktree repo — same discoverability caveat the r70 reviewer recorded for `1e6199b`. |
| 6 | Fixture sha256 `669c539d…` | **AGREE** | `669c539d0bb38c82184f1b39df0a4d70059276e532def125438f352899a7fc45` reproduced four ways: `git show 2a0e46f:corpus/fixtures/navagent3d_detour.gd`, `git show HEAD:…` (blob), `git archive HEAD` extract, and my pre-edit working-tree/spotcheck copies. `run_battery.py` sha `5a7d6c13ac4a24960ce8f24bcc45b24a65da31919e78b5cc5934e3c248a79dee` likewise at HEAD and in archive. |
| 7 | Prior 85 rows byte-identical vs frozen baseline; seed map 51→52 adds only `navagent3d_detour.gd` (+ intended `run_battery.py` digest) | **AGREE** | Field compare of my replay receipt vs `corpus/live/r70-baseline/runs/20261013T215959381187Z/verdicts.json` over the 11 raw fields (case, script, flags, expected/actual exit, kind, marker, verdict, reasons, stdout, stderr): **0 mismatches over 85 shared cases**; new rows exactly the three declared (`navagent3d_detour{,_straight,_assert_pathsum}`); none missing. Seed map 51→52 keys/digests: only `navagent3d_detour.gd` added and `run_battery.py` changed — matches the verifier's finding. Caveat carried forward: the baseline receipt is gitignored/on-disk only. |

## Incident: concurrent r71 seed edit mid-run (resolved by isolation)

My first battery attempt ran directly on the live worktree seeds:
`python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --godot /usr/bin/godot --runs …/corpus/live/r71-reviewer/runs --probe-*` from `~/Projects/prymeagnt/game-dev-3d`, started `20261013T233606Z` (20:36:06 local).

- Result: `totals: cases=88 pass=88 fail=0` but **`FAIL battery`** — receipt
  `runs/20261013T233606077794Z/verdicts.json` has `verdict=FAIL`,
  `seeds_unchanged=false`.
- Cause, not r70 defect: the r71 author seat concurrently landed uncommitted
  working-tree edits to `corpus/fixtures/navagent3d_detour.gd` (mtime
  20:37:13) and `run_battery.py` (mtime 20:37:19) — the declared r71
  postprocessing arms (`--post-edgecentered`, `--post-none`) — *after* the
  runner snapshotted seeds into scratch but *before* its post-run digest
  recheck. Proof of non-contamination: the run's own scratch copy
  `runs/20261013T233606077794Z/scratch/navagent3d_detour.gd` hashes
  `669c539d…` (committed r70 blob) and `run_battery.py`'s CASES were loaded
  pre-edit (88 rows, not the post-edit 90). All 88 case verdicts are
  therefore valid committed-state results; only the seed-drift guard fired.
- Positive side observation: this is a live demonstration that
  `seeds_unchanged` catches a real mid-run seed mutation — the guard is not
  decorative.
- Resolution: replayed the battery on a `git archive HEAD` fixture tree
  (claim 4 above) → clean `PASS battery`, `seeds_unchanged=true`. I did not
  touch the author's uncommitted edits (leaf: no git checkout/stash; outside
  write scope); `git status --porcelain corpus/fixtures` still shows `M` on
  both files at report time, which is the concurrent wave's in-flight state.

Consistency note (not a claim verification): the in-flight r71 diff quotes
edgecentered `pathlen=4.707107`, matching the r70 author's disclosed
prediction ("edge-centered postproc would land ~4.707 on this mesh").

## Disagreements

None. All six audited claim families re-measured fresh agree with the r70
record.

## Reviewer conclusion (claim-level, not marked)

Every audited r70 claim reproduces on committed state: the three detour arms
return byte-exact markers/exits (0/2/2), the battery is 88/88 + 4 probes
with `seeds_unchanged=true` under archive isolation, all three cited commits
resolve as ancestors of HEAD with exactly the reported shapes, both cited
sha256s verify, and the prior-85 field comparison vs the frozen baseline is
clean. The Euclidean-to-raw-`target_position` resolution stands on this
engine build under default CORRIDORFUNNEL, as scoped.

## Residual risk / verification gaps

- The frozen baseline receipt is gitignored; my 85-row comparison used the
  on-disk artifact (same caveat as r70-verifier).
- `navagent3d_retarget` intermittence (r68/r69) did not manifest in my two
  full runs — still open, not refuted.
- Bounded scope unchanged: stationary agent, path-start query, default
  postprocessing, Godot 4.7.2 headless, authored geometries only. The r71
  postprocessing-invariance question is the author's live work item; this
  audit neither confirms nor refutes it (I ran no postprocessing arm).
