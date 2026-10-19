source: S004 — RenderingServer class reference — https://docs.godotengine.org/en/stable/classes/class_renderingserver.html — section `Headless mode` (stable docs 4.7); S005 — Command line tutorial — https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html — `Command line reference` → `--headless` (stable docs 4.7)
verified-at: 2026-10-19 — both pages opened and quoted (`corpus/lessons/round-108.md` `## Gate`); lane-side facts re-read at commit 7c4e589
recheck: on-release — re-open S004 `Headless mode` and S005 `--headless` on each Godot release; lane side: `grep -nE 'get_texture|get_image|RenderingServer|readPixels' corpus/fixtures/*.gd corpus/fixtures/three/*.mjs` must print nothing, and `grep -n '"--headless"' corpus/fixtures/run_battery.py` must still match

# Godot `--headless` is a no-render mode: the battery proves state, never pixels

**Claim (document fact, Godot 4.7 stable docs).** `--headless` selects the
headless display driver and a dummy audio driver (S005: "Enable headless mode
(`--display-driver headless --audio-driver Dummy`). Useful for servers and with
`--script`."), and in that mode "Most functions from RenderingServer will return
dummy values" (S004, `Headless mode`). A run under `--headless` therefore cannot
by itself show that anything was rendered.

**Lane fact (static, this repo at 7c4e589).** Every Godot battery case is
launched with `--headless` (`corpus/fixtures/run_battery.py`, the `execute()`
command list). No Godot or three.js fixture reads a texture, image or pixel
buffer (the recheck grep above prints nothing). The camera rows
(`camera3d_project`, `camera3d_depth`, `camera3d_ortho`) assert projection and
frustum state — `unproject_position`, `is_position_in_frustum`,
`is_position_behind` — and `corpus/fixtures/README.md` already disclaims
"rendered image or GPU culling proof" for the orthographic family. The one
image-producing row is Blender's `bpy_rbw3d_render` (Cycles 64×64 PNG, compared
by file hash, not decoded pixels), outside Godot.

**Decision.** A visual or render-regression claim about Godot needs a separate,
non-headless render path with its renderer and driver recorded (S003) and a
blank-output negative control; until such a receipt exists, render capture is
`frontier` in the coverage map, and the camera rows stay labelled
projection-math evidence.

**Does not reach.** Whether Godot's non-headless renderers produce identical
pixels across drivers (rejected lead S010 overclaims exactly this); any
behavior of the RenderingServer outside `--headless`.

**Admission.** Passes `corpus/QUALITY.md` Q1–Q5, Q7, Q16, Q17; Q6 not
applicable (no runtime claim). Pass list: `corpus/lessons/round-108.md` `## Gate`.
