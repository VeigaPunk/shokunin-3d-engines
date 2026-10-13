# Round 8 — Camera3D near-plane classification under rotation

Run `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only camera3d_depth,camera3d_depth_far,camera3d_depth_near` from repository root. Source: `corpus/fixtures/camera3d_depth.gd`, exact signatures in `run_battery.py:CASES`, independent reproduction/scratch sensitivity `corpus/lessons/r8-near-review.md`. Ignored raw receipts regenerate via command.

| Local point, rotated Camera3D at (10,0,0), near1/far10 | World | Forward depth | Screen | Frustum | API `is_position_behind` | Exit |
|---|---|---:|---|---|---|---:|
| (2,1,-4) visible | (14,1,2) | 4 | (550,225) | inside | false | 0 |
| (6,3,-12) beyond far | (22,3,6) | 12 | (550,225) | outside | false | 2 |
| (0.25,0.125,-0.5) before near | (10.5,0.125,0.25) | **+0.5** | (550,225) | outside | **true** | 2 |

Godot 4.7 `Camera3D::is_position_behind` compares forward dot to `_near`, so API-behind need not mean geometrically behind camera origin. This was observed on installed Godot 4.7.2; upstream 4.7 source is explanatory, not binary provenance. The first incorrect API assumption and a temporary parse error both produced exit1 and are preserved in LOG, not counted as passes. Private Z -0.5→-0.75 mutation detects literal world-coordinate mismatch exit1. No rendering/GPU, near-boundary precision or other-engine claim.
