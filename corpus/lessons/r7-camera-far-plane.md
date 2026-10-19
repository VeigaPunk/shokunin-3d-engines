# Round 7 — rotated Camera3D far-plane classification

Run `python3 corpus/fixtures/run_battery.py --only camera3d_depth,camera3d_depth_far` from repo root. Source `corpus/fixtures/camera3d_depth.gd`, enforced markers in `run_battery.py:CASES`, named independent reproduction and scratch mutation in `corpus/lessons/r7-camera-review.md`. Raw receipts under ignored `corpus/live/runs/<timestamp>/verdicts.json`; rerun for fresh values.

| Local point from camera (10,0,0), Y=-90°, FOV90, near1/far10, viewport800×600 | World point | Screen pixel | Frustum | Exit |
|---|---|---|---|---|
| (2,1,-4), depth4 | (14,1,2) | (550,225) | inside | 0 |
| (6,3,-12), depth12 | (22,3,6) | (550,225) | outside far plane, despite same pixel | 2 |

A depth-2 control stays inside; no near-plane rejection is tested. The reviewer changed only LOCAL_VISIBLE Z to -5 in a private scratch copy: fixed expected world (14,1,2) rejected measured (15,1,2) at exit1. This tests frustum/projection math, not rendered visibility, GPU culling or occlusion.
