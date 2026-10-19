# r108 seat output — src-godot-exec (agent W2RoundGameDev3d.R108SrcGodotR2)

**File changed:** `reports/round-108/sources/rows-godot.md` in the lane worktree. It contains 12 rows, G01–G12 (lines 7–18): **A=11, B=0, C=1**. Eleven are queued; G10 is retained as rejected with a reason and flip condition. The file also records a gate quote for each row, search counts, an unopened lead, and two study paths (lines 20–46).

**Retained evidence:** Godot’s `4.7-stable` source defines `FLOOR_ANGLE_THRESHOLD 0.01` at line 41 and applies the floor-angle comparison at lines 546 and 598, with floor-state assignments at 547 and 599. The stable 4.7 `CharacterBody3D` reference says “The default value equals 45 degrees.” and describes `is_on_floor()` using `up_direction` and `floor_max_angle`; it does not document the 0.01-radian allowance. The GdUnit4 and Godot CLI overlap with game-dev-2d’s S020 and S006 respectively (`game-dev-2d-shokunin/corpus/SOURCES.md:12,26`).

**Risks and blockers:** G10 rejects the Vulkan tutorial’s unqualified cross-machine determinism claim because the page provides no reproducible host/driver matrix; the row states what evidence would change that verdict (`rows-godot.md:16`). Stable/latest documentation can change, so the rows name the version or publication date where available. No blockers. No builds or tests were run; this was source curation only.
