# Round 57 exact orthographic far-plane — independent non-author review (2026-10-13)

**Bounded PASS** at work commit `a87e1a4c8edfcf138e884f351b305ba5c210dbfe`; I did not author the fixture. I read the r57 declaration in `.shokunin/game-dev-3d/LOG.md`, `corpus/fixtures/README.md`, `camera3d_ortho.gd`, and `run_battery.py`. Godot is `4.7.2.stable.arch_linux.ed1daf0bf` here. The reviewed worktree was clean before this review.

## Reproduction and independent raw evidence

Run from repository root:

```sh
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only camera3d_ortho_far_boundary_exact,camera3d_ortho_far_boundary_inside,camera3d_ortho_far_boundary_outside
```

Both process exits **0**. Full receipt `/home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/20261013T123250681582Z/verdicts.json` (SHA-256 `a9c027cd3b41289ac75815617a0504c4ee4c77c02584c8c82e7de587845bbabb`): **83/83 PASS, 41 ordinary/42 negative**, four optional probes PASS (tree timeout, crash exit, stream attribution, existing contact-plane mutation). Focused receipt `/home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/20261013T123250682146Z/verdicts.json` (SHA-256 `685d758878ed3bb9a3cbbf4fc8caabb0349e100a2d095c063d432369b6c5a5fb`): **3/3 PASS, two ordinary/one negative**. In both, `seeds_unchanged=true`, all **50** seed SHA-256 values equal between full and focused runs and equal current seed files. For all 83 full records, actual exit equals expected exit, exact marker occurs once in stdout, stderr/reasons are empty, and `error=null`. The exact case alone exited **0** with stdout `PASS camera3d_ortho far_boundary_exact depth=10.000 screen=550.000,225.000 in_frustum=true api_behind=false inside_control=true outside_control=false`. The adjacent inside case exited **0** at depth 9.990 with `in_frustum=true`; outside exited **2** at depth 10.010 with `in_frustum=false api_behind=false` and its exact `NEGATIVE REJECTED:` marker. No raw parse errors or unexpected diagnostics in successful cases.

Compared to r56 final author receipt `/home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/20261013T122708416300Z/verdicts.json` (SHA-256 `af3b6abafcf1c2ec5337739a9a91db49c9473e80b94aac01ba9e40b9fa8ac69c`), **all 82 prior named cases** have exactly the same `case`, `script`, `flags`, `expected_exit`, `actual_exit`, `error`, `kind`, `marker`, `verdict`, `reasons`, full `stdout` and full `stderr` fields. Run-specific scratch path in `command` and elapsed time necessarily differ. Only new named case: `camera3d_ortho_far_boundary_exact`. The 50-seed map differs from r56 only for `README.md`, `run_battery.py`, and `camera3d_ortho.gd`, matching the bounded change. The README opening count **83 total/41 ordinary/42 negative** agrees with 83 unique CASES entries and actual runner totals.

## Independent private counterfactual

Copied **only** `project.godot` and `camera3d_ortho.gd` into `/tmp/g3d-r57-far-oaay0ukn` outside the tracked tree, and changed only `const FAR_EXACT := Vector3(2, 1, -10.0)` to `const FAR_EXACT := Vector3(2, 1, -10.01)` there. Command:

```sh
godot --headless --path /tmp/g3d-r57-far-oaay0ukn --script res://camera3d_ortho.gd -- --far-boundary-exact
```

Exit **1**; stdout contains only Godot's banner, **no success marker**; stderr's diagnostic is `ERROR: camera3d_ortho: far exact measured contradiction depth=10.010 in_frustum=false api_behind=false`. No `SCRIPT ERROR:` or `Parse Error:`. This reaches the live measured frustum predicate after the projection and both adjacent controls passed; it is not merely a literal, marker, or parser rejection. Scratch is disposable and not a registered case.

## Source check and limits

The exact branch creates a live 800×600 `SubViewport` and orthographic `Camera3D` (`KEEP_HEIGHT`, size 8, near 1, far 10), awaits two process frames, checks live settings and accepted depth-4/depth-8 controls, then reads exact and 9.99/10.01 projected screen positions, both adjacent frustum states, exact frustum state and `is_position_behind`. It rejects failed setup separately from the exact measured contradiction; `quit(0)` and its exact marker follow measurement. The inside/outside branches independently test adjacent frustum statuses, same projected pixel and rejected depth-12 control. The runner checks exit, one exact stdout marker, stderr, parse/script diagnostics and leaks rather than trusting exit alone. The expectation is pinned to this host and one exact point; it does **not** establish portable floating-point boundary behavior, rendered pixels, GPU culling or another engine. This reviewer did not commit, push, merge or alter implementation, LOG, report or SCORECARD.
