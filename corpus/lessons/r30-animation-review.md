# Round 30 — independent AnimationPlayer review

**Verdict:** Coverage improves narrowly: headless Godot 4.7.2 samples a live `Node3D` position track through `AnimationPlayer`, with a constant-track control. Depth and calibration unchanged. No implementation edit, push, or merge.

## Reproduction and preservation

From repository root:

```sh
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
# exit 0: 39/39 (18 ordinary, 21 intended negatives), four opt-ins PASS, seeds_unchanged=true
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only animation3d_keys,animation3d_keys_still
# exit 0: 2/2 (ordinary exit 0, constant-key negative exit 2), seeds_unchanged=true
```

Independent full receipt `corpus/live/runs/20261013T061437321157Z/verdicts.json` SHA-256 `ac5ea55cf39cbee9e071c3d93f402259b256e409c5b3d1aba6d2d712167eb4e8`; pair `corpus/live/runs/20261013T061437322230Z/verdicts.json` SHA-256 `ac1250820207b8a2909891de71beefcfd8dddeab9a277178f8cd75e937d039ed`. Full probe receipt SHA-256: tree `bf73901abf6f841b9cede28e39ab70502226c66caf1614f0086ac5e4b6b4348b`, crash `f19c52b27e4a34374d5a7cf9d5d7ec5baacb186314bc4747ce462978754598af`, stream `a21808bf11120b9def08566afc0c021713d13047bb8592e43425e8d47040b6b0`, built-in mutation `9518addcdc42508874ab7b743761b844cc951b88890e2c91058b9983408b1f2a`; each says PASS. Full/pair seed maps identical.

Against r29 full `corpus/live/runs/20261013T060936691334Z/verdicts.json` (SHA-256 `499795216eb13b73e99298f45a95d94043e69e3d1f5ac8a8c3e7140ea698b839`), all 37 prior case records have identical order and exact `case/script/flags/expected_exit/actual_exit/error/kind/marker/verdict/reasons/stdout/stderr`. Run paths and elapsed times differ. Only seed-map changes: README `e2ae8435e6f167771ac84972711c32ee159ff31518b058215296115aa60ace7f` → `545d5ac864aaefd845a5c002163ba74fb0f59ff372360d0ebece5fd53120f736`, runner `a7fb30dcdd8df03fca46394ac9fa352440c298f626fc3530bc9e6e6aebf0672c` → `65eddcb37c18ef54ec0924d8d5e0e1784fd63cc62e8c9e74a18b293cb647edf7`, and new `animation3d_keys.gd` `5c4cec8830aff171cd2ac8981c226f55036d6fea4c1f37435829ff29d0e4121b`; all other prior seed hashes identical. Full and pair animation records have stdout Godot banner, blank line, then their single exact marker, with empty stderr: moving `PASS animation3d_keys position_track mid_x=2.000 end_x=4.000 seek_update=true` (exit 0), still `NEGATIVE REJECTED: animation3d_keys constant_track mid_x=0.000 end_x=0.000` (exit 2).

## Source and private changed-endpoint control

`animation3d_keys.gd` attaches `Actor: Node3D` and sibling `Player: AnimationPlayer` under live `Stage`, sets `player.root_node = NodePath("..")`, constructs a one-second `Animation.TYPE_POSITION_3D` track at `NodePath("Actor")` with keys X0→X4, or intact still X0→X0. It confirms track count/path/key count and animation identity after `process_frame`; then `play("travel")`, `seek(0.5, true)` and `seek(1.0, true)` capture actual `actor.position` at each sample. The moving literal distance checks require (2,0,0) and (4,0,0), and still requires zero at both samples (tolerance 0.0001), before fixed marker printing and exit. Source selects the position-track type; no explicit interpolation-type setter is present, but measured half/end positions fit linear default evaluation.

Private ignored copy `corpus/live/runs/r30-private-animation-review/animation3d_keys.gd`: *only* moving endpoint in the key insertion changed `Vector3(4, 0, 0)` → `Vector3(6, 0, 0)`; the still key, literal expectations and PASS text remain unchanged. Exact seeded script SHA-256 `5c4cec8830aff171cd2ac8981c226f55036d6fea4c1f37435829ff29d0e4121b`, mutant `ae17a82d59d01b89555c0b53575ebc6275510cd3a4ba1f21e6f4ccc78d2827b3`; restoring that one line yields byte-identical seeded script. Command:

```sh
/usr/bin/godot --headless --path .shokunin/game-dev-3d/corpus/live/runs/r30-private-animation-review --script res://animation3d_keys.gd > .shokunin/game-dev-3d/corpus/live/runs/r30-private-animation-review/mutant.stdout 2> .shokunin/game-dev-3d/corpus/live/runs/r30-private-animation-review/mutant.stderr
# exit 1; ERROR: animation3d_keys: animated position mismatch mid=(3.0, 0.0, 0.0) end=(6.0, 0.0, 0.0)
```

Stdout SHA-256 `1fb0f12cefe41f881cb436e6731d981084b95f8db9b1d6f3e25ac930f360a32e` has only Godot banner and blank line; stderr SHA-256 `f335689a1e20b1a1a078dfb3aaa69bd5531a4ab62ac60033a95657bf72ae54ed` has measured mismatch/backtrace, no `SCRIPT ERROR`, `Parse Error`, ObjectDB leak or PASS marker. This failure passes setup and reaches observed-position assertion, rather than merely detecting altered track setup.

**Limits and guard caveat.** LOG records failed author guards for `current_animation == "travel"`/`current_animation_position == 1` at the exact endpoint despite correct observed transforms, including failure with only the exact-time check removed. The accepted fixture does not assert current-animation state after seeking exact end; its check `is_instance_valid(actor)` does not establish that state, and marker numbers are fixed text printed *after* measured assertions. Explicit seeks demonstrate two sampled evaluations only: no natural timed playback, blending, rendered pixels, arbitrary key paths/animations or portability beyond this headless Godot build. The still arm is an intact constant track, not an absent track. The private mutation shows the compound mid/end predicate rejects changed samples; it does not separately isolate midpoint and endpoint predicates.
