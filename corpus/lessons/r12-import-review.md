# Round 12 — independent Godot GLB import review (non-author)

Scope: reviewed the standing brief, LOG r11 falsified control and r12 declaration/failing classifier receipt, r9 truth/review, `inspect_import.gd`, both r12 artifact and runner. Independently executed the declared runner and regressions on Godot 4.7.2. I edited no authored artifacts, runner, LOG, or report. Fresh receipts are ignored under `corpus/live/`.

## Byte identity and controls

All three source files are 532 bytes. The valid GLB SHA-256 is `78f51afa040c1066f10c47f22bd4ea9c812005351493acda3f62cae9eec65fbc`; r11 tolerated-length SHA-256 is `dad26ba782d5977d8179edfa8bd78904ced9c71342f8b67205cd8cc89e7c144b`; bad-magic SHA-256 is `beef50211ceacdff74e1dd20f6191e2ddf1ae217b5f7e5c995559c366a36a517`. Independent byte-for-byte comparison proves valid and bad-magic differ **only at offsets 0–3**, `glTF` → `BAD!` (`67 6c 54 46` → `42 41 44 21` hex); bytes 4–531 are equal. Valid vs tolerated-length differs only at offset 8 (`0x14` → `0x13`, declared total length 532→531). r9 truth/source shows the authored triangle; r9 local strict length rejection is not a Godot rejection. Scratch files' SHA-256 each match their respective sources.

## Fresh independent execution

`python3 .shokunin/game-dev-3d/corpus/artifacts/glb-r12/run_import.py` exited **0 / PASS**. Full raw per-process commands, exit codes, stdout and stderr (including editor progress and engine messages), source hashes and scratch directories are stored at `/home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/r12-import-20261013T035505061535Z/verdicts.json`. Every case got a distinct new scratch project, the same copied `project.godot` and `inspect_import.gd`, and its respective GLB copied as `triangle.glb`. I inspected raw receipt streams and actual `.godot/imported/*.scn` files:

| case | editor exit / stderr | script exit / stderr | `.scn` | script output |
| --- | --- | --- | --- | --- |
| valid | 0 / empty | 0 / empty | present | root `triangle` with one child; `TriangleNode` MeshInstance3D position `(2.0, 0.0, -3.0)`; one surface, three vertices [(0,0,0),(0,1,0),(1,0,0)] |
| r11 tolerated-length | 0 / empty | 0 / empty | present | same three `IMPORT_*` lines **byte-for-byte** as valid |
| r12 bad magic | **0 / glTF parse and import ERROR lines** | **2 / failed resource load and `IMPORT_REJECTED: no PackedScene`** | **absent** | engine version only; no `IMPORT_*` lines |

The bad editor's stderr includes `ERROR: glTF: Error parsing .gltf JSON data: Expected 'true', 'false', or 'null', got 'BAD' at line: 0` and `ERROR: Error importing 'res://triangle.glb'.`; the bad script's stderr has `ERROR: Failed loading resource: res://triangle.glb.` and `IMPORT_REJECTED: no PackedScene`. These messages are **stderr**, not stdout. The bad editor's exit **0** and progress `[ DONE ]` are not evidence of asset acceptance. In the same naming/setup, the load fails and there is no imported `.scn`; valid and tolerated controls genuinely load the same inspected mesh. This proves rejection of this four-byte corrupted file on this Godot host, not rejection of the r11 length corruption or of arbitrary malformed GLBs, and not rendered output.

The first author runner receipt `.shokunin/game-dev-3d/corpus/live/runs/r12-import-20261013T035411717883Z/verdicts.json` is **FAIL** despite identical bad-magic engine behavior: initial classifier searched editor stdout for diagnostics that Godot put on stderr. The corrected runner searches stderr for both error lines and scene stderr for `IMPORT_REJECTED`, requires script exit 2/no `.scn`, and requires successful editor/script exits, silent stderr, `.scn`, and exact three tail output lines for both accepted controls. Its fresh classification is supported. Limit: the runner itself only hashes the three files and checks displayed lines; it does **not** assert the four-byte source delta (established by my independent comparison), validate full mesh geometry beyond the inspection script's output, or prove a general magic-header validation branch. The engine error actually describes a failed glTF JSON parse of `BAD!`; do not call it a specific explicit “bad magic” diagnostic. `.scn` absence is specifically a glob under `.godot/imported`; script-level null `PackedScene` and resource error make the narrower failure convincing. It is not an arbitrary import rejection test.

## Existing battery regression

Independent `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py` exited 0, **15/15 PASS** (seven ordinary, eight negative controls), `seeds_unchanged=true`, receipt `/home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/20261013T035508839241Z/verdicts.json`. Independent `node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs` exited 0, **3/3 PASS** (positive, wrong-order negative, mutation), `seeds_unchanged=true`. I did not rerun the optional Godot fault probes or rendering tests.

## Verdict

**Coverage improved** narrowly for Godot 4.7.2 headless asset import/load discrimination: the self-authored valid triangle and r11 tolerated-length control load, while precisely four changed magic bytes trigger attributable importer/load errors, no PackedScene and no imported `.scn`. **Depth unchanged; calibration unchanged** in the declared axes; fixing the stdout/stderr classifier repaired a failed runner, not a new broad calibrated policy. One proved axis improved and none harmed in the measured scope; **admit r12**, with the limitations above. No REA GLB parsing, rendered pixels, Unity/Unreal import or generic GLB-invalidity claim follows.
