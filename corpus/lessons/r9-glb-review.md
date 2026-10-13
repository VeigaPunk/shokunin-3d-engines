# Round 9 — independent GLB review (non-author)

Scope: reviewed the declared r9 move and REA failure in `LOG.md`, `/tmp/mission-game-dev-3d-standing.md`, and the authored GLB fixture/truth/validator. No artifact, validator, LOG, or report edits by this reviewer. Review receipts are ignored under `corpus/live/`.

## REA outcome (independent rerun)

`npx -y rea-agents@6.4.0 inspect-artifact .shokunin/game-dev-3d/corpus/artifacts/glb-r9/triangle.glb --format json --full-output` exited **1**. Parsed JSON has envelope `ok:true`, but `data.code="target_unavailable"`, `data.category="unavailable"`, `data.message="Cannot open artifact: unsupported binary format. Check that the path exists, is readable, and points to a supported file."`; `data.details.reason="unsupported binary format"`. There is **no Evidence ID** or inspected GLB carrier. Independent payload exactly matches `artifacts/glb-r9/rea-inspect-error.json`. Full response and process exit: `corpus/live/r9-review-rea.json`. The `ok:true` envelope does not turn this into an inspection success.

## Local static parser outcome (not REA evidence)

`python3 .shokunin/game-dev-3d/corpus/artifacts/glb-r9/validate_glb.py --receipt .shokunin/game-dev-3d/corpus/live/r9-review-local.json` exited **0**, `PASS`; positive dictionary equals `truth.json` fields and rejection returned the expected header-length error. Independent byte inspection: `triangle.glb` is 532 bytes, SHA-256 `78f51afa040c1066f10c47f22bd4ea9c812005351493acda3f62cae9eec65fbc`. Header `glTF`, version 2, declared length 532. JSON chunk header at 12, payload offset 20, length 468, type `JSON`; BIN header offset 488, payload offset 496, length 36, type `BIN\0`, ending at 532. JSON scene 0 references node 0 `TriangleNode` translated `[2,0,-3]`, mesh 0 `Triangle`, primitive mode 4, POSITION accessor 0, float32 VEC3 count 3. Decoded local positions: `(0,0,0)`, `(1,0,0)`, `(0,1,0)`. These are static local byte observations, not runtime render/import or REA results. Invalid file is also 532 bytes; SHA-256 `dad26ba782d5977d8179edfa8bd78904ced9c71342f8b67205cd8cc89e7c144b`; it differs at exactly **one byte**, offset 8 (`0x14` to `0x13`), changing the little-endian header declared length from 532 to 531. The parser rejected that exact mismatch.

Validator limits: the positive fixture has a SHA-256 comparison to truth, which pins these authored bytes, but the validator itself does not prove the negative file differs in exactly one header byte or pin the negative SHA-256; that exactness required the independent byte comparison above. Its generic GLB parser also does not validate JSON scene/mesh/POSITION reference links, accessor byte offsets/stride, or accessor extrema, so it is not a general glTF validator. These limits do not negate its narrow fixed-fixture positive/truth and observed header rejection.

## Independent regression replay

Godot `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py` exited 0: **15/15 PASS**, seven ordinary and eight negative controls, unchanged seeds; receipt `/home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/live/runs/20261013T034437417052Z/verdicts.json`. Node `node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs` exited 0: **3/3 PASS**, seeds unchanged (positive, wrong-order negative, mutation). Neither battery is REA evidence for this GLB.

## Verdict

**Coverage unprovable/unchanged; do not admit r9.** The declared criterion requires REA Evidence identifying the 3D carrier. REA rejects `.glb` as an unsupported binary format; the local parser's pass and stable Godot/Node batteries cannot substitute for that missing REA Evidence. **Depth unchanged; calibration unchanged** in measured scope; no rendering, import, or Unity/Unreal execution inference. A separately declared future ZIP/archive route might be tested but is not an r9 success.
