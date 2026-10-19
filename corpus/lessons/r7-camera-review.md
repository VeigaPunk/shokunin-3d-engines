# Round 7 — independent Camera3D depth review (2026-10-13)

**Reviewer:** `game-dev-3d-r7-camera-review`, non-author. **Finding:** the bounded Godot Camera3D near/far-plane fixture passes independent replay and source-constant sensitivity. No rendering/GPU culling was tested.

## Replay and raw receipts

- `python3 corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing`: exit 0, `14/14` seeded PASS (7 ordinary, 7 negative); four opt-in probes PASS. Raw `corpus/live/runs/20261013T033627342120Z/{verdicts,tree-timeout-verdicts,crash-exit-verdicts,stream-attribution-verdicts,mutation-verdicts}.json`.
- `python3 corpus/fixtures/run_battery.py --only camera3d_depth,camera3d_depth_far`: exit 0, `2/2` PASS. Raw `corpus/live/runs/20261013T033627342105Z/verdicts.json`.
- Both new arms have exactly one expected marker on stdout after Godot's banner, no stderr, and exact exits 0/2 respectively: `PASS camera3d_depth camera=10.000,0.000,0.000 visible=14.000,1.000,2.000 screen=550.000,225.000 depth=4.000 far=10.000 near=1.000`; `NEGATIVE REJECTED: camera3d_depth far_point_depth=12.000 screen=550.000,225.000 in_frustum=false behind=false near_control_visible=true`.
- Against the earlier 12-case receipt `corpus/live/runs/20261013T033332300870Z/verdicts.json`, all 12 old names, markers, expected/actual exits, captured stdout and stderr match exactly. The old fixture seed digests match (14 unchanged seed files); only README and runner changed, while the new camera script adds one seed. Current full/subset 17-file SHA-256 maps agree exactly; full receipt `seeds_unchanged=true`, and recomputation from live fixture files agrees. The prior 12-case receipt preceded the new camera addition.
- Probe detail: crash control live SIGTERM exit `-15` rejected despite identical marker; stream pair has same stdout/exit 0, injected stderr rejected; tree timeout has logical exit `null`, cleanup exit `-9`, identified detached witness verified and gone; existing wall-box mutant exits 1 and is detected with original seeds unchanged. These are bounded probe claims, not general crash/tree guarantees.

## Independent geometry and sensitivity

`camera3d_depth.gd` uses camera `(10,0,0)`, Y rotation `-90°`, FOV 90°, `KEEP_HEIGHT`, viewport 800×600, near 1 and far 10. Rotation maps local `(x,y,z)` to `(-z,y,x)`, so local visible `(2,1,-4)` becomes `(14,1,2)` at forward depth 4; far `(6,3,-12)` becomes `(22,3,6)` at depth 12. With focal length 300 pixels (vertical FOV 90°), the visible point projects `(400+300·2/4,300-300·1/4)=(550,225)`; far point has the same ratios `(6/12,3/12)` and therefore the same pixel. Near control local `(0,0,-2)` has depth 2, inside near 1/far 10, and `is_position_in_frustum` confirms it. Far point's `is_position_behind=false` while `is_position_in_frustum=false`; the same-pixel projection does not establish far-plane membership. This does not independently exercise *near-plane rejection* (only a nearer valid control).

I copied fixtures into ignored `corpus/live/runs/r7-camera-review-private/scratch` excluding `three`, `node_modules`, and `__pycache__`, then changed **only** `LOCAL_VISIBLE` local Z `-4.0` to `-5.0`. Direct headless Godot exits 1, with no PASS marker and diagnostic `ERROR: camera3d_depth: rotated/translated camera coordinates mismatch visible=15.000,1.000,2.000 far=22.000,3.000,6.000` on stderr (raw `mutation-stdout.txt` and `mutation-stderr.txt` beside scratch). Seed SHA-256 remains `f7e7b7d597099444143d2b8c1df464965a8bbe7b9629d5b7c954c326a6875cf9`; only private scratch changed. This proves one literal expectation detects this particular source change, not exhaustive mutation sensitivity.

**Inference limit:** `Camera3D.is_position_in_frustum` tests the mathematical camera frustum membership; no render, GPU occlusion, draw-call culling or visible pixel was measured. Evidence supports a Camera3D depth/frustum math claim only. No tracked fixture, LOG, SCORECARD or report was edited by this reviewer.

<!-- r106-seat45-receipt-note -->

> **Non-resolvable receipt note (r106, 2026-10-18, SEAT-45).** Re-checked 2026-10-18: each path below is a concrete `corpus/live/runs` receipt cited in this lesson. The cited path is absent (`test -e` failed) and no durable copy exists under `reports/` (no receipt artifact whose path or `started_utc` is that run id; a prose mention is not a copy). Quoted receipt SHA-256 values on these lines do not match any tracked file or any `reports/` receipt artifact. `corpus/.gitignore` ignores `live/`, so these paths were never tracked. Historical sentences above are unchanged. Register: `reports/round-106/consistency/receipts.md`.
>
> - `corpus/live/runs/20261013T033627342120Z/{verdicts`
> - `corpus/live/runs/20261013T033627342105Z/verdicts.json`
> - `corpus/live/runs/20261013T033332300870Z/verdicts.json`
> - `corpus/live/runs/r7-camera-review-private/scratch`
