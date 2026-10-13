# Round 32 — independent 3D AnimationPlayer cross-fade review

**Verdict:** Depth improves narrowly for a live two-animation position cross-fade on one 3D target in headless Godot 4.7.2; coverage and calibration unchanged. The fade reaches an intermediate measured position and later X4, whereas a zero-duration switch reaches X4 at both samples. No implementation edits, push, or merge.

## Reproduction and preserved cases

From repository root:

```sh
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
# exit 0; 43/43 (20 ordinary, 23 intended negative); all four opt-in probes PASS; seeds_unchanged=true
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only animation3d_blend,animation3d_blend_cut
# exit 0; 2/2 (ordinary exit 0; cut control exit 2); seeds_unchanged=true
```

Full receipt `corpus/live/runs/20261013T062352175533Z/verdicts.json` SHA-256 `d539cab6e7a8b96e46598dbddf7b255f4ab0f446984c55fbce272d956979c28c`; paired receipt `corpus/live/runs/20261013T062352176861Z/verdicts.json` SHA-256 `363fdf82dd5b9ff839450c30fe24338f245b536e354fca0293488d3d702ecbcb`. Full opt-in receipt SHA-256: tree-timeout `1848a368c2c899785b809dd91f0e07bc3d2e77225fba8056a01c13354f4f1d1a`, crash-exit `9ee218d0c16c183777df48b4f92bb4007e0d81557db207447e00caff61dcaa8d`, stream-attribution `761d7cdf2350e16429a1ffbb87f32dbe67d02311a451777b42d7e335e7ec0f94`, built-in failing mutation `c2886150c4b83549bea2fa554245eb167e8d0ea8dc508c1c76aa8f4e6f0a6315`; all verdicts PASS. The full and paired seed maps match.

Compared by **case name** with previous complete r31 41-case `corpus/live/runs/20261013T061926092432Z/verdicts.json` (SHA-256 `0c8ecbbb43dc8f674c425e93f0d6153872074e0a721a796cf27b34854745884e`), all 41 prior records have identical `case/script/flags/expected_exit/actual_exit/error/kind/marker/verdict/reasons/stdout/stderr`. The two new records were inserted before older ones; index-wise comparison would be wrong. Run paths/elapsed times differ naturally. Prior seed hashes stay identical except README `eca94370c76b0b10a8a651b3595c15deae029cc5a425aa39d325b8742c9fa19e` → `84452475d28664f1e1269793c02cd22f8405fd87aff70a628c7bf06c83eaca00`, runner `cd9247ab35ca5a58775820a99e3f53a34b5e401eccacecd7c58e086a3258a72e` → `4afb54d3e62b36a0c12c3837d6f016acadcb386362aabc81f3430721651ee3b3`, plus new `animation3d_blend.gd` `4638ecc8c64891872594391bc1db38ac1d1ccb5145f21f56766fc87629d22925`. No prior seed disappeared.

Both new full and paired records have exact raw stdout lines consisting of `Godot Engine v4.7.2.stable.arch_linux.ed1daf0bf (2026-08-17 01:18:38 UTC) - https://godotengine.org`, an empty line, then respectively `PASS animation3d_blend fade_seconds=0.5 mid_x=1.931 end_x=4.000 physics_frames=15+30` (exit 0) and `NEGATIVE REJECTED: animation3d_blend instant_cut mid_x=4.000 end_x=4.000` (exit 2). Their raw stderr arrays are empty. Those printed markers are authored constants; actual position evidence is the predicates and the private measured-failure diagnostic below, not telemetry embedded in the markers.

## Source inspection and private endpoint mutation

`animation3d_blend.gd` creates one live `Stage/Actor: Node3D` and a sibling `AnimationPlayer` bound by `root_node=".."`; its callback mode is `ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS`. The same animation library holds `from` and `to`, each a length-2 constant two-key `TYPE_POSITION_3D` track at time 0 and 2 targeting `Actor`: X0 and X4. Following the first `physics_frame`, it calls `play("from")`, awaits four warm-up frames, then calls `play("to", 0.5)` or `play("to", 0.0)` for `--cut`; it awaits 15 frames for `mid` and 30 more for `end`. There is no `seek` or manual `actor.position` assignment. `project.godot` pins `physics/common/physics_ticks_per_second=60`. Player/library setup is checked through animation identity, each track's path/count, callback mode and `is_playing`; **the guard does not check track type, key count or values**, so the measured position assertions carry the behavior claim. Fade checks mid `(1.931034,0,0)` within 0.005, end `(4,0,0)` within 0.003 and strictly intermediate X, while cut checks both `(4,0,0)` within 0.003, before fixed markers. The fade mid/end predicate is compound: the private mutation does not isolate its terms independently.

A private ignored copy `corpus/live/runs/r32-private-blend-review/` changes **only the first occurrence** of `Vector3(4, 0, 0)` → `Vector3(6, 0, 0)` in `animation3d_blend.gd`, the second animation's track value, leaving cut/fade expected literals and guards unchanged. Original script SHA-256 `4638ecc8c64891872594391bc1db38ac1d1ccb5145f21f56766fc87629d22925`; mutant `521dd727b21f972920ee8a6dd11cfe1df80a1e2a05d0630e3c23774c8ac689df`. Reverse this single replacement and the script is byte-identical to the original. Exact command:

```sh
/usr/bin/godot --headless --path .shokunin/game-dev-3d/corpus/live/runs/r32-private-blend-review --script res://animation3d_blend.gd > .shokunin/game-dev-3d/corpus/live/runs/r32-private-blend-review/mutant.stdout 2> .shokunin/game-dev-3d/corpus/live/runs/r32-private-blend-review/mutant.stderr
# exit 1; ERROR: animation3d_blend: cross-fade position mismatch mid=(2.896552, 0.0, 0.0) end=(6.0, 0.0, 0.0)
```

Mutant stdout SHA-256 `1fb0f12cefe41f881cb436e6731d981084b95f8db9b1d6f3e25ac930f360a32e` contains only the Godot banner and blank line. Stderr SHA-256 `b4987fba7dfd9881ecdc4ad81ff0a767b422df2aba161cc088f2dfbbb606267e` contains that measured position mismatch, `push_error` location and GDScript backtrace. No `SCRIPT ERROR`, `Parse Error`, ObjectDB leak warning or PASS marker. Thus setup passed and the live fade arm rejected the changed endpoint at its measured position predicate; the cut mutant arm was not separately run.

**Limits:** One pair of constant-key positions, one 0.5-second transition, one zero-duration control and this pinned engine/build/frame schedule. The sample does not establish a universal blend curve, arbitrary animated poses or rendered pixels. It does not measure transition weights directly, and the cut arm's X4 does not imply a general sudden-cut guarantee beyond this setup.
