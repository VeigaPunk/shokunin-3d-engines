# Round 31 — independent frame-advanced AnimationPlayer review

**Verdict:** Depth improves narrowly: a live Godot 4.7.2 `AnimationPlayer` advances a 3D target during awaited headless physics frames, rather than only through r30 explicit `seek`. Coverage and calibration unchanged. No implementation edits, push, or merge.

## Reproduction and preservation

From repository root:

```sh
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
# exit 0: 41/41 (19 ordinary, 22 intended negatives), four opt-ins PASS, seeds_unchanged=true
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only animation3d_playback,animation3d_playback_still
# exit 0: 2/2 (ordinary exit 0, intact constant-track negative exit 2), seeds_unchanged=true
```

Independent full receipt `corpus/live/runs/20261013T061926092432Z/verdicts.json` SHA-256 `0c8ecbbb43dc8f674c425e93f0d6153872074e0a721a796cf27b34854745884e`; paired receipt `corpus/live/runs/20261013T061926093148Z/verdicts.json` SHA-256 `69c5dd771666f9ca7da0dc05d889570e08b63d15232442d71508b17c12176498`. Full probe receipt SHA-256: tree `729dcc51aa5da16383689b003d9ecebdd3abee53787948b97e985c9763087e4b`, crash `8bffb1f644a73179547fdd44454bc085bce705bd3624b1bbfcf8a10e1a81ef507455193d`, stream `8e09348ba2613e0162db84a38ef8401d24d384b8fcf8a10e1a81ef507455193d`, built-in mutation `ab37991fcc2532d360d03051b1de9f29cce23549287771da6c8846054a5057f2`; each probe PASS. Full and paired seed maps equal. Compared with r30 full `corpus/live/runs/20261013T061437321157Z/verdicts.json` (SHA-256 `ac5ea55cf39cbee9e071c3d93f402259b256e409c5b3d1aba6d2d712167eb4e8`), all previous 39 records preserve exact `case/script/flags/expected_exit/actual_exit/error/kind/marker/verdict/reasons/stdout/stderr` in order. Run paths and elapsed times naturally differ. Only seed-map changes: README `545d5ac864aaefd845a5c002163ba74fb0f59ff372360d0ebece5fd53120f736` → `eca94370c76b0b10a8a651b3595c15deae029cc5a425aa39d325b8742c9fa19e`, runner `65eddcb37c18ef54ec0924d8d5e0e1784fd63cc62e8c9e74a18b293cb647edf7` → `cd9247ab35ca5a58775820a99e3f53a34b5e401eccacecd7c58e086a3258a72e`, plus new script `animation3d_playback.gd` `1f6027cf153fe7b95721c0a5f02fa7ef61b8d12e0f6fc4f9c7f30e2d04affe38`; all other prior seed hashes identical. Both new records have only the Godot banner, blank line, exact marker on stdout and empty stderr: moving `PASS animation3d_playback mid_x=0.967 later_x=1.967 physics_frames=60 playing=true` (exit 0); intact still `NEGATIVE REJECTED: animation3d_playback constant_track mid_x=0.000 later_x=0.000 physics_frames=60` (exit 2).

## Source and private changed-endpoint control

`animation3d_playback.gd` builds a live `Stage/Actor: Node3D` and sibling `Player: AnimationPlayer`, binds `root_node=".."`, sets `callback_mode_process=AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS`, and constructs a two-second `TYPE_POSITION_3D` track bound to `Actor`, X0→X4 (or X0→X0 in the intact still arm). After one initial `await physics_frame`, it calls `play("travel")` exactly once, awaits 30 physics frames and samples actor.position/player.current_animation_position, then awaits another 30 and samples again. There is no `seek` call or manual `actor.position` assignment. It checks track count/path/key count, library identity and callback mode; the progression guard checks `is_playing` and times against **29/60 and 59/60 seconds**, each within 0.002; then the moving arm checks actual positions `(29/30,0,0)` and `(59/30,0,0)` each within 0.003, while still requires zero within 0.0001, *before* printing fixed markers. `project.godot` pins `common/physics_ticks_per_second=60`. There is no explicit track interpolation setting: observed positions fit Godot's default interpolation, not a separately asserted interpolation policy. The first awaited frame after `play` does not advance the newly started animation on this tested build; the measured guard captures that 29/59-step order. Both moving positions are nonzero and increase, with the same frame/time checks in the still arm. Fixed marker decimals are not raw telemetry.

A private ignored fixture project `corpus/live/runs/r31-private-playback-review/` copies the seed project, with *only* moving key endpoint `Vector3(4, 0, 0)` → `Vector3(6, 0, 0)` in `animation3d_playback.gd`; still key, expectations, guards and marker are untouched. Seed SHA-256 `1f6027cf153fe7b95721c0a5f02fa7ef61b8d12e0f6fc4f9c7f30e2d04affe38`; mutated script `fc4dab73d8802b0817b136e1aeec3630863f0aafa954acc68606eeabd5766fbb`; reversing this single replacement is byte-identical to the seed. Exact command:

```sh
/usr/bin/godot --headless --path .shokunin/game-dev-3d/corpus/live/runs/r31-private-playback-review --script res://animation3d_playback.gd > .shokunin/game-dev-3d/corpus/live/runs/r31-private-playback-review/mutant.stdout 2> .shokunin/game-dev-3d/corpus/live/runs/r31-private-playback-review/mutant.stderr
# exit 1; ERROR: animation3d_playback: frame-advanced position mismatch mid=(1.45, 0.0, 0.0) later=(2.95, 0.0, 0.0)
```

Mutant stdout SHA-256 `1fb0f12cefe41f881cb436e6731d981084b95f8db9b1d6f3e25ac930f360a32e` contains Godot banner and blank line only. Stderr SHA-256 `b137e19ea36995aa3b1ed9ae4a8de8c23232d7b5a65b9fd4e3f1572f6f1344cb` reports the measured position mismatch/backtrace, with no `SCRIPT ERROR`, `Parse Error`, leak warning, or PASS marker. The frame progression/setup guards passed and the changed endpoint failed the measured-position predicate. That compound predicate does not isolate its mid and later terms independently.

**Limits:** The exact 29/59 advancement order is tested only on this Linux headless Godot 4.7.2 build and explicit 60-Hz project setting; scheduling or different physics FPS can alter the literal frame/time results, so this is no universal frame-order promise or flakiness survey. These are live position samples, not rendered pixels. No blending, other track shapes, different frame rates, or other engine versions tested.
