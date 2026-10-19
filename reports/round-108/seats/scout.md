# r108 seat output — scout (agent W2RoundGameDev3d.R108Scout-5)

## Observed

**Viewport/render API use.** In `corpus/fixtures/*.gd`, `SubViewport` appears in `camera3d_depth.gd:42-44`, `camera3d_ortho.gd:18,39-49`, `camera3d_project.gd:19-21,80-83`, and `phys3d_events.gd:6287-94`. The last uses it to host a separate `World3D` for physics-space queries, not to read an image. A scoped search of those `.gd` files and `corpus/fixtures/three/*.mjs` found no `get_texture`, `get_image`, `RenderingServer`, `WebGLRenderer`, or `readPixels` calls. The three.js camera fixtures describe projection/frustum math without a renderer (`three/README.md:35-36`; `three/camera_frustum.mjs:1,25-28`).

**There is a separate Blender render fixture.** `bpy_rbw3d.gd` includes a `render` arm (`:46-47,62-64`); its child invokes Cycles to write 64×64 PNGs (`r91_child.py:481-505,532-559`), and `run_battery.py` has a `bpy_rbw3d_render` row (`:564-565`). It checks file-written and PNG-hash comparison results, not decoded pixel values (`r91_child.py:508-529,549-559`).

**Camera/ortho rows assert projection and camera classification, not rendered pixels.** For example, the ortho fixture compares `Camera3D.unproject_position` results and checks `is_position_in_frustum` / `is_position_behind` (`camera3d_ortho.gd:55-60`). Expected CASES markers (`run_battery.py:314-333`):

- `PASS camera3d_ortho far_boundary_exact depth=10.000 screen=550.000,225.000 in_frustum=true api_behind=false inside_control=true outside_control=false`
- `PASS camera3d_ortho far_boundary_inside depth=9.990 screen=550.000,225.000 in_frustum=true outside_control=false`
- `NEGATIVE REJECTED: camera3d_ortho far_boundary_outside depth=10.010 screen=550.000,225.000 in_frustum=false api_behind=false inside_control=true`
- `PASS camera3d_ortho near_boundary_exact depth=1.000 screen=550.000,225.000 in_frustum=true api_behind=false inside_control=true outside_control=false`
- `PASS camera3d_ortho near_boundary_inside depth=1.010 screen=550.000,225.000 in_frustum=true outside_control=false`
- `NEGATIVE REJECTED: camera3d_ortho near_boundary_outside depth=0.990 screen=550.000,225.000 in_frustum=false api_behind=true inside_control=true`
- `PASS camera3d_ortho viewport=800,600 front_screen=550.000,225.000 deep_screen=550.000,225.000 near=1.000 far=10.000`
- `NEGATIVE REJECTED: camera3d_ortho lateral_outside screen=850.000,225.000 in_frustum=false controls_same_pixel=true`
- `NEGATIVE REJECTED: camera3d_ortho near_plane_depth=0.500 screen=550.000,225.000 in_frustum=false api_behind=true geometric_front=true controls_same_pixel=true`
- `NEGATIVE REJECTED: camera3d_ortho far_plane_depth=12.000 screen=550.000,225.000 in_frustum=false api_behind=false geometric_front=true controls_same_pixel=true`

Expected perspective/depth camera markers (`run_battery.py:370-387`):

- `PASS camera3d_project viewport=800,600 fov=90.000 proj_x_scale=0.750 proj_y_scale=1.000 world=2.000,1.000,-4.000 screen=550.000,225.000 center_screen=400.000,300.000 mirror_screen=250.000,375.000 behind=false in_frustum=true`
- `NEGATIVE REJECTED: camera3d_project behind_camera_projection_rejected point=2.000,1.000,4.000 is_position_behind=true in_frustum=false raw_screen=250.000,375.000 collides_with_mirrored_control=true lateral_screen=3400.000,300.000 lateral_in_frustum=false in_front_control_accepted=true`
- `PASS camera3d_depth camera=10.000,0.000,0.000 visible=14.000,1.000,2.000 screen=550.000,225.000 depth=4.000 far=10.000 near=1.000`
- `NEGATIVE REJECTED: camera3d_depth far_point_depth=12.000 screen=550.000,225.000 in_frustum=false behind=false near_control_visible=true`
- `NEGATIVE REJECTED: camera3d_depth near_point_depth=0.500 screen=550.000,225.000 in_frustum=false api_behind=true geometric_front=true near_control_visible=true`

**Godot invocation and engine setting.** The battery builds each Godot command with `--headless` (`run_battery.py:1267-1269`). `project.godot` has no explicit `physics/3d/physics_engine` setting; its physics section pins the tick rate (`project.godot:18-20`). The physics fixture identifies its default as `GodotPhysics3D` (`phys3d_events.gd:5-9`).

## Prose and coverage

The potentially misleading wording is the heading “Orthographic Camera3D depth-invariant pixels” and “authored pixel scale” (`corpus/fixtures/README.md:186,190-193`). The same passage limits the result to “projection/frustum math, not a rendered image or GPU culling proof” (`:194-195`); the r23–r25 reviews also disclaim rendered pixels (`r23-ortho-review.md:26`, `r24-ortho-near-review.md:35`, `r25-ortho-far-review.md:34`). I found no affirmative rendered-output or visual-correctness claim in the requested prose. The corpus README’s rendering-tooling wording is a directive, not a result claim (`corpus/README.md:9-10`); its fixture README says headless checks do not establish rendered output (`corpus/fixtures/README.md:7-8`).

Named zero-coverage findings are limited to these fixture files and the searched API tokens: **Godot/three viewport image readback or pixel-level validation** (scoped API search above); **NavigationServer navmesh baking** (no `NavigationMeshSourceGeometryData3D`, `bake_from_source_geometry_data`, or navmesh bake API matches); **multiplayer APIs** and **3D-audio APIs** (no `MultiplayerAPI`/peer or `AudioStreamPlayer3D`/`AudioListener3D`/`AudioServer` matches). Navigation queries do exist: `navigation3d_path` uses a hand-authored region (`corpus/fixtures/README.md:70-71`). **Jolt-vs-default physics differentials are not zero**: the `phys3d_events_jolt_edge` case explicitly runs a Jolt child and pins backend differences (`corpus/fixtures/README.md:601-623`).

## `reports/frontier/*.md`

- `reports/frontier/navagent-dissection.md:1` — NavigationAgent/NavigationServer 1-tick miss dissection.
- `reports/frontier/bpy-boundary.md:1` — Blender render-metadata boundary probe.
- `reports/frontier/unknowns-map.md:1` — post-r100 frontier unknowns map.
- `reports/frontier/fb-physserver.md:1` — PhysicsServer3D direct-API edge measurements.
- `reports/frontier/fa-bpy-evalcat.md:1` — Blender dependency-graph evaluation-event catalogue.

**Remaining limit:** These are static-source findings; I did not execute an engine or assess rendered images.
