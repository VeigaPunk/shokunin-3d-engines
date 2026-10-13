# Games R13 — unrelated key release preserves E intent

Research-only calibration candidate in isolated worktree `/home/vgpnk/Projects/prymeagnt-games-r13-keyup`, based on `9e3e2151794511feb7642a38f0c57523e0a12808`. Axis: **calibration**. The fixture now holds E, injects an unrelated synthetic F release through `Input.parse_input_event` and real `_input`, confirms no release receipt/intent clearing and six bounded physics frames of continued movement, then injects matching E release and confirms one receipt, cleared intent, and zero movement across ten physics frames. Pickup collision is disabled for the mode so the actor remains available. A test-only any-key-up mutant routes every key release into the actor's release handler; the new test rejects it because movement stops on F-up. This explicitly discriminates the prior R12 gap (which checked only wrong-F press/release with no held E).

No direct handler calls. Every physics observation is bounded; the fixture retains its 180-process-frame global bound and callback waits are capped at 20 frames. Native controls run with `timeout --signal=TERM --kill-after=2s 8s`, `/usr/bin/godot` version `4.7.2.stable.arch_linux.ed1daf0bf`.

## Native runs

### New calibration test and explicit mutant

```text
$ godot --headless --path .shokunin/games-engine-mechanics --script res://causal_chain.gd -- --keyup-test
exit 0
Godot Engine v4.7.2.stable.arch_linux.ed1daf0bf (2026-08-17 01:18:38 UTC) - https://godotengine.org

PASS keyup E_press_receipts=1 F_release_receipts=0 E_release_receipts=1 unrelated_release_moves=6 post_E_release_moves=0 scene=A

$ godot --headless --path .shokunin/games-engine-mechanics --script res://causal_chain.gd -- --keyup-test --any-key-up-mutant
exit 2 (expected assertion failure; mutant witness)
Godot Engine v4.7.2.stable.arch_linux.ed1daf0bf (2026-08-17 01:18:38 UTC) - https://godotengine.org

ERROR: movement stopped after unrelated F release
   at: push_error (core/variant/variant_utility.cpp:1023)
   GDScript backtrace (most recent call first)
       [0] _run (res://causal_chain.gd:107)
```

### Existing chain controls

```text
$ godot --headless --path .shokunin/games-engine-mechanics --script res://causal_chain.gd -- --release-test
exit 0
PASS release press_receipts=1 release_receipts=1 held_moves=3 post_release_moves=0 scene=A

$ godot --headless --path .shokunin/games-engine-mechanics --script res://causal_chain.gd -- --baseline-release-test
exit 2 (expected baseline assertion failure)
ERROR: movement continued after release; expected baseline failure
   at: push_error (core/variant/variant_utility.cpp:1023)
GDScript backtrace (most recent call first)
    [0] _run (res://causal_chain.gd:144)

$ godot --headless --path .shokunin/games-engine-mechanics --script res://causal_chain.gd -- --wrong-key-negative
exit 1 (designed negative control)
PASS wrong_key=F receipts=0 intent=false physics_moves=0 collections=0 scene=A old_alive=true frames=30

$ godot --headless --path .shokunin/games-engine-mechanics --script res://causal_chain.gd
exit 0
PASS positive input=1 physics_moves=10 collections=1 scene=B old_freed=true

$ godot --headless --path .shokunin/games-engine-mechanics --script res://causal_chain.gd -- --negative
exit 1 (designed negative control)
PASS negative input=1 moves=29 x=290.000031 collections=0 scene=A old_alive=true
```

### Eight existing controls

Each ran in `.shokunin/games-engine-mechanics/controls` with the native timeout above. Exact PASS/error summary and exit:

```text
mechanic_test.gd: exit 0 — PASS first=true second=false consumed=true
negative_test.gd: exit 1 — ERROR: negative control: deliberate condition failed; at _initialize (res://negative_test.gd:6)
test_scene_signal.gd: exit 0 — PASS scene_loaded=true SceneTree_dispatched_event=E consumed=true signal_count=1 repeat_suppressed=true
test_scene_signal_negative.gd: exit 1 — ERROR: negative control: expected collected signal was absent (dispatch deliberately disabled); at _initialize (res://test_scene_signal_negative.gd:22)
overlap_probe.gd: exit 0 — PASS packed_scene=true area_shape=true layers=1/2 masks=2/0 pre_overlap_signals=0 overlap_signal_count=1 consumed=true
overlap_negative.gd: exit 1 — ERROR: negative control: expected collected signal was absent with disabled mask; at _run (res://overlap_negative.gd:28)
scene_transition_probe.gd: exit 0 — PASS valid_transition=true current_scene_replaced=true marker=B old_scene_freed=true frames=4
scene_transition_negative.gd: exit 1 — engine rejects null destination; PASS invalid_destination_rejected=true current_scene_preserved=true old_scene_alive=true frames=3; then ERROR: negative control: deliberately invalid scene destination rejected; at _run (res://scene_transition_negative.gd:30)
```

Expected negative-control exits are not passes for positive behavior. The mutant and baseline exit 2s are intentional assertion failures, and their error text is the discriminator. Evidence is synthetic, headless GDScript SceneTree only. It establishes no OS/device input, editor behavior, or player/full-game behavior. No provider/daemon action, specialist mint, push, merge, or files outside the two permitted subtree paths were used.

## Git evidence

Implementation commit: `bcd7777523f95d6dc83f91e77b2d53ce0310b55b`. Report is a separate report-only commit after all fixture/control runs. Required Git author and committer identity: `games-engine-mechanics-research <games-engine-mechanics-research@shokunin.local>`. No other paths are staged.


## Append-only correction — scheduling sensitivity and movement-count wording

The earlier `unrelated_release_moves=6` PASS field is a **literal label**, not a measured move count: the test captures `before_f_up_frames`, awaits six `physics_frame`s, then asserts only `actor.moves > before_f_up_frames`. The actual guarantee is continued physics movement during that six-frame window (at least one increment), not exactly six increments. The post-E-up assertion compares the move count before and after ten physics frames and requires equality (`post_E_release_moves=0`). Receipt assertions require E press count 1, F release count 0, and E release count 1.

These chain controls are startup/scheduling-sensitive under parallel Godot launches. Independent review observed 4/7 chain cases encountering `current_scene == null` or the global process-frame bound when launched in parallel; serial execution gave 7/7 expected outcomes, and the key-up case passed 5/5 serial repeats. Accordingly the reported PASS evidence is for bounded serial native runs, not parallel reliability. The original native outputs/exits are retained above; intermittent parallel failures should not be mistaken for a stable behavior result. No fixture changes were made for this correction.

Correction committed report-only after implementation. Required report-last author and committer remain `games-engine-mechanics-research <games-engine-mechanics-research@shokunin.local>`.
