# Round 56 exact orthographic near-plane — independent review (2026-10-13)

**Verdict: PASS, bounded.** I did not author work commit `3f48f71ce41c285cf410a9a53b3a46438d45bb80`; HEAD was that commit and the tracked tree was clean before this review. I read its r56 LOG declaration, fixture README, `camera3d_ortho.gd` and runner. Godot reports `4.7.2.stable.arch_linux.ed1daf0bf` on this Linux host. The declaration's new depth observation is reproduced, with all prior 81 case records unchanged. At the reviewed work commit, the README opening said **81 registered cases (39 ordinary/42 negative)**, though the runner registered **82 (40 ordinary/42 negative)**. Its r56-specific section and reproduction command were correct; the stale opening count was a documentation flaw, not a failed case. A subsequent correction and independent focused recheck are recorded below.

## Independent execution and raw records

From repository root:

```sh
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only camera3d_ortho_near_boundary_exact,camera3d_ortho_near_boundary_inside,camera3d_ortho_near_boundary_outside
```

Both process exits were **0**. Full receipt: `/home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/20261013T122425975429Z/verdicts.json`: **82/82**, 40 ordinary/42 negatives, four uncounted probes PASS, `seeds_unchanged=true`. Focused receipt: `/home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/20261013T122432066745Z/verdicts.json`: **3/3**, two ordinary/one negative, no probes, `seeds_unchanged=true`. All 82 full raw records have `verdict=PASS`, actual exit equal to expected, exact marker as a stdout line after the engine banner, `stderr=[]`, `reasons=[]`, `error=null`. For the three focused cases, raw stdout/stderr and actual/expected exits are:

- exact: **0/0**, stdout `PASS camera3d_ortho near_boundary_exact depth=1.000 screen=550.000,225.000 in_frustum=true api_behind=false inside_control=true outside_control=false`; stderr empty.
- inside: **0/0**, stdout `PASS camera3d_ortho near_boundary_inside depth=1.010 screen=550.000,225.000 in_frustum=true outside_control=false`; stderr empty.
- outside: **2/2**, stdout `NEGATIVE REJECTED: camera3d_ortho near_boundary_outside depth=0.990 screen=550.000,225.000 in_frustum=false api_behind=true inside_control=true`; stderr empty.

The other stdout lines are the Godot version banner and an empty line. All three records agree verbatim between full and focused receipts. Probe raw JSON in the full run directory reports: crash normal exit 1 accepted versus signaled -15 rejected; stream stdout-only exit 0 accepted versus stdout + `STREAM_3D_STDERR` exit 0 rejected; tree normal exit 0 accepted versus timed-out logical `actual_exit=null`, cleanup -9, rejected; intentional scratch `body3d_contact` mutant exit 1, measured contact-plane diagnostic, detected=true. Each probe JSON has `verdict=PASS`. Probe success is not a 3D camera assertion.

Compared with the r55 non-author receipt `.shokunin/game-dev-3d/corpus/live/runs/20261013T120600873587Z/verdicts.json` cited by `corpus/lessons/r55-far-review.md`, all **81 previous cases** retain identical `script`, `flags`, `expected_exit`, `actual_exit`, `error`, `kind`, `marker`, `verdict`, `reasons`, `stdout`, `stderr`; the sole new case is the exact one. The full/focused maps contain the same **50 SHA-256 seed digests**; all match the present files on disk. Against r55, only the three authored seed files changed digests: `README.md` `a5a40c5e1fa40d721756d9a084bc844bfa233c0b579581be7eb6c9b46d7e842c` → `744e0fafd27a29490ccc38e991073096df18e5cd2cd4acc10b6cddc64dc9135f`, `camera3d_ortho.gd` `be5c8f9ea999e61d7eb3d5a62ec768cef604c3360c3e2bf25300d2230514c8e4` → `e81716583d0f0555a2404c4506b06b093b91d73c3d755739adfe7c69a812178a`, `run_battery.py` `925bda61a2f68d4e3ade54b19505712e1509ec2c48bfe2ed688619b9942cef20` → `404431bbfffef34be9cf75bee6bded5749e9b115598325ef9265da531cac771d`. This difference across commits is not runtime seed mutation.

## Source predicate and private counterfactual

The exact branch reads an authored 800×600 SubViewport and orthographic Camera3D size 8/near 1/far 10, verifies depth-4/-8 projection/frustum setup, then measures `unproject_position(NEAR_EXACT)`, `is_position_in_frustum(NEAR_EXACT)` and `is_position_behind(NEAR_EXACT)`. It checks the adjacent 1.01/0.99 controls have the same (550,225) screen projection and opposite frustum statuses; the exact branch fails if measured exact frustum is false **or** API-behind is true before it can print PASS. The depth printed in its marker is from `-NEAR_EXACT.z`, while the frustum/behind booleans are live Godot API returns.

Only in an independent temporary directory (`/tmp/game-dev-3d-r56-exact-review-lt8t5zqm`), I copied `project.godot` and `camera3d_ortho.gd` and changed `const NEAR_EXACT := Vector3(2, 1, -1.0)` to `const NEAR_EXACT := Vector3(2, 1, -0.99)`. Reproduce (choose your own temp directory):

```sh
mkdir -p /tmp/r56-near-review
cp .shokunin/game-dev-3d/corpus/fixtures/project.godot .shokunin/game-dev-3d/corpus/fixtures/camera3d_ortho.gd /tmp/r56-near-review/
sed -i 's/const NEAR_EXACT := Vector3(2, 1, -1.0)/const NEAR_EXACT := Vector3(2, 1, -0.99)/' /tmp/r56-near-review/camera3d_ortho.gd
godot --headless --path /tmp/r56-near-review --script res://camera3d_ortho.gd -- --near-boundary-exact > /tmp/r56-near-review.stdout 2> /tmp/r56-near-review.stderr
```

The mutant exited **1**. Captured stdout contains **only** the Godot banner and blank line, no PASS/NEGATIVE marker. Stderr begins `ERROR: camera3d_ortho: near exact measured contradiction depth=0.990 in_frustum=false api_behind=true`, then the `_fail`/`_run` `push_error` backtrace; no `Parse Error:` or `SCRIPT ERROR:`. Thus the same-position 0.99 sample passes setup and is rejected by the measured frustum/behind predicate, not merely a parser/marker check. This single counterfactual does not separately isolate the two booleans or establish arbitrary-point precision.

**Axis verdict:** depth improved for this one exact-near sampled classification with live neighboring controls; coverage unchanged (existing orthographic Camera3D feature/host), calibration unchanged (existing classifier and one private constant sensitivity check). No harmed axis observed in this finite replay. Exact sample inclusion at near=1 here is **not** a general floating-point boundary guarantee, rendered pixel/GPU-culling result, portable engine behavior, or a statement about other lateral positions/transforms. Apart from this lesson and ignored live receipts, no repository source, fixtures, LOG, report or SCORECARD were modified; no commit, push or merge.

## README correction and final-revision focused recheck (2026-10-13)

After the full battery/probe and first focused replay above, the author committed **`69cf9b2e101223bd245362d15a956145d4900f3d`**, changing only the README opening count `81/39` → `82/40`. I independently inspected current `run_battery.py` `CASES`: **82 registered cases, 40 expected-exit-0 ordinary and 42 expected-exit-2 negative**. The corrected README now says exactly “82 registered cases (40 ordinary and 42 negative controls).” This resolves the opening-count flaw noted above; it does not retroactively change the earlier full battery/probe receipts, which were generated on work commit `3f48f71` and its old README seed digest.

I reran from repository root on HEAD `69cf9b2`:

```sh
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only camera3d_ortho_near_boundary_exact,camera3d_ortho_near_boundary_inside,camera3d_ortho_near_boundary_outside
```

Process exit **0**; receipt `/home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/20261013T122710965811Z/verdicts.json`: **3/3 PASS** (ordinary 2, negative 1), exact 0/0, inside 0/0, outside 2/2. Each case retains the exact stdout marker, empty stderr, empty reasons and no runner error, with all compared raw case fields unchanged from my first focused receipt `/home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/20261013T122432066745Z/verdicts.json`. `seeds_unchanged=true`; 50 seed digests match the current files and only `README.md` differs from the prior focused digest: `744e0fafd27a29490ccc38e991073096df18e5cd2cd4acc10b6cddc64dc9135f` → `8ff28c04fa9ccf317288efecb23913f1178f152f753ad81ee4f580210c5eb7cf`. The 49 other seed digests are identical. I did **not** rerun all 82 cases/four probes after this README-only correction; the complete battery evidence remains specifically attributed to the preceding revision. Only this review file and ignored live receipts were written by the reviewer; no commit/push/merge.
