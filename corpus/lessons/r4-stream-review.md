# Round 4 — named non-author stream-attribution review

Reviewer: `game-dev-3d-r4-stream-review` (did not implement r4). Independently read the standing mission, LOG r4 before-state, fixture README, `stream_attribution3d.gd`, and `run_battery.py`, then executed from the repository root:

```sh
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-stream-attribution --probe-crash-exit --probe-failing
```

Both commands returned 0 using `/usr/bin/godot` 4.7.2.stable.arch_linux.ed1daf0bf. Raw ignored receipts (rerun commands to reproduce):

- Default: `.shokunin/game-dev-3d/corpus/live/runs/20261013T031350433906Z/verdicts.json`
- Opt-in: `.shokunin/game-dev-3d/corpus/live/runs/20261013T031350434030Z/verdicts.json`, `stream-attribution-verdicts.json`, `crash-exit-verdicts.json`, `mutation-verdicts.json` in that same directory.

## Direct receipt checks

- Both batteries: `PASS`, 12/12 seeded cases (six ordinary exit 0, six intended-negative exit 2), zero failures; each case has its exact expected marker once on stdout, correct exit, empty stderr, and no reasons. Corresponding case streams/exits agree across both runs. Opt-in probes remain uncounted.
- Stream probe `PASS`: both arms execute the same `res://stream_attribution3d.gd` in the same scratch project, with only the reject arm adding `--emit-stderr`. Both exit 0 with no runner error and **byte-identical stdout**, including exactly one `STREAM_3D_STDOUT: spatial node ready` line. Accept stderr is empty, classified `true`, reasons `[]`. Reject stderr is exactly `STREAM_3D_STDERR\n`, classified `false`, reasons exactly `['unexpected stderr line: STREAM_3D_STDERR']`. Source creates and checks a Node3D, prints the marker, optionally calls `printerr(DIAGNOSTIC)`, then calls `quit(0)`; this is a real Godot run, not a manufactured subprocess transcript.
- `git show 1802d4f:.shokunin/game-dev-3d/corpus/fixtures/run_battery.py` confirms the pre-r4 classifier checked code and exact stdout marker, `SCRIPT ERROR:`, `Parse Error:`, `ERROR:`, and ObjectDB warning, but **did not reject arbitrary nonempty stderr**. Applying that old `classify` function to the actual r4 reject-arm `(stdout, stderr, exit=0, error=None, marker)` yields `(True, [])`; r4's new nonempty-stderr check is the causal policy difference.
- Crash-exit probe remains `PASS`: normal arm marker on stdout, stderr empty, exit 1 and classification `true`; signal arm observes marker while live, sends SIGTERM, stdout has the same marker, stderr empty, returns -15 and classification `false` with exact reason `process died on signal 15`. This is direct-child signal attribution, not process-tree or spontaneous-crash evidence.
- Mutation probe remains `PASS`: scratch-only `BOX_SIZE` depth 4.0→6.0 mutant exits 1 and is rejected against seeded exit-0/marker expectation, with exact diagnostic `ERROR: body3d_slide: body did not stop at the contact plane final_z=3.500 expected=2.500` once on stderr; `detected=true`. Its additional unexpected-stderr reasons are consistent with the r4 policy and do not erase the intended diagnostic.
- `seeds_unchanged=true` on both battery receipts and the mutation receipt. Their before/after maps agree across both runs: all 14 seed file SHA-256 digests identical.

**Verdict:** no observed default or retained-probe regression; the declared stdout/stderr attribution contrast is independently reproduced. Calibration improves for this one Node3D fixture on this host. Depth and coverage of the seeded 12-case battery remain unchanged. No inference about rendering, other engines, general logging policy, process-tree cleanup, or spontaneous crashes is supported. The new rule rejects *all* nonempty stderr lines, including benign engine output if encountered in future fixtures; that is a policy choice, not evidence that all stderr is an error.
