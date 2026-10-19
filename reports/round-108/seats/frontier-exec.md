# r108 seat output — frontier-exec (agent W2RoundGameDev3d.R108FrontierR2)

**Axis addressed:** coverage.

**Files changed, append-only**
- `corpus/README.md:141-184` — added the coverage map and eight ordered frontier probes.
- `PROVINCE.md:48-81` — added Core, Frontier, and Adjacent sections, plus the r108 correction note.

**Counts recorded**
- Surface status histogram: **13 core, 7 frontier, 5 adjacent** (25 total).
- Base CASES counts are pinned to commit `7c4e589` in the map: movement/collision 12; spatial queries 6; camera 15; scene structure/instancing 8; transform composition 4; input 2; headless battery 350; explicit Jolt rows 2; animation 6; mesh 8; navigation 101; glTF 9; Blender render 1.
- Added heading counts: README **2**; PROVINCE **3**. These are authored counts, not post-edit grep results.

**Evidence retained:** `reports/frontier/unknowns-map.md:48-55,145-153,212,239-249`; `corpus/fixtures/README.md:186-195`; `corpus/fixtures/run_battery.py:451-454,564-565,1267-1269`; and the referenced lessons, scorecard, and sibling province files. The map distinguishes Blender’s PNG-hash case from decoded-pixel evidence and marks the C3 floor-angle sweep as in progress, not as a verdict.

**Risks/blockers:** Core counts are explicitly baseline-pinned and exclude the in-progress C3 additions. I did not run acceptance greps, a diff, or tests; the parent’s post-integration gate should check them. No blocker.
