# Games R12 — synthetic E release stops physics movement

Research-only coverage candidate in isolated worktree `/home/vgpnk/Projects/prymeagnt-games-r12-release`, based on `540eb40ca1ecb4fa184f28db23b6deb5a5cae441`. One axis tested: **coverage**. The new fixture path extends the R11b synthetic input → real `Node._input` → physics movement chain through a matching E release, then asserts intent clears and movement stops over 10 physics frames. No handler is called directly: both events use `Input.parse_input_event`.

## Fixture and controls

Copied the canonical R11b `.shokunin/branch-directions/games-engine-mechanics` fixture into the permitted R12 research subtree. `causal_actor.gd` now accepts E press and release in `_input`; E release records a release receipt and clears intent. When intent is false, physics code sets velocity to zero and does not call `move_and_slide`. `causal_chain.gd` has `--release-test`, which dispatches E press, waits for the `_input` receipt, checks continued held movement, dispatches E release, checks its real callback receipt and cleared intent, then asserts the move count does not increase through 10 physics frames. Pickup collision mask is set to zero in release testing to prevent the original overlap/transition from invalidating the actor before release. Wrong-F control now dispatches matching F press and release; it remains unrelated to intent and movement. The original positive and mask-negative controls remain.

For a causal baseline, `baseline_actor.gd` preserves the R11b press-only handler (release ignored). `--baseline-release-test` runs the same release assertion against it. Its exit 2 is the intended assertion failure (`movement continued after release`), not a claim that the baseline passes. This demonstrates the new assertion distinguishes the missing release behavior.

## Native runs

Godot `/usr/bin/godot --version`: `4.7.2.stable.arch_linux.ed1daf0bf`, exit 0. Each run below was bounded with `timeout --signal=TERM --kill-after=2s 8s`.

```text
$ timeout --signal=TERM --kill-after=2s 8s /usr/bin/godot --headless --path .shokunin/games-engine-mechanics --script res://causal_chain.gd -- --release-test
exit 0
Godot Engine v4.7.2.stable.arch_linux.ed1daf0bf (2026-08-17 01:18:38 UTC) - https://godotengine.org
PASS release press_receipts=1 release_receipts=1 held_moves=3 post_release_moves=0 scene=A

$ timeout --signal=TERM --kill-after=2s 8s /usr/bin/godot --headless --path .shokunin/games-engine-mechanics --script res://causal_chain.gd -- --baseline-release-test
exit 2 (expected assertion failure)
Godot Engine v4.7.2.stable.arch_linux.ed1daf0bf (2026-08-17 01:18:38 UTC) - https://godotengine.org
ERROR: movement continued after release; expected baseline failure
   at: push_error (core/variant/variant_utility.cpp:1023)
GDScript backtrace (most recent call first):
    [0] _run (res://causal_chain.gd:101)

$ timeout --signal=TERM --kill-after=2s 8s /usr/bin/godot --headless --path .shokunin/games-engine-mechanics --script res://causal_chain.gd -- --wrong-key-negative
exit 1 (deliberate expected-negative status)
Godot Engine v4.7.2.stable.arch_linux.ed1daf0bf (2026-08-17 01:18:38 UTC) - https://godotengine.org
PASS wrong_key=F receipts=0 intent=false physics_moves=0 collections=0 scene=A old_alive=true frames=30

$ timeout --signal=TERM --kill-after=2s 8s /usr/bin/godot --headless --path .shokunin/games-engine-mechanics --script res://causal_chain.gd
exit 0
Godot Engine v4.7.2.stable.arch_linux.ed1daf0bf (2026-08-17 01:18:38 UTC) - https://godotengine.org
PASS positive input=1 physics_moves=10 collections=1 scene=B old_freed=true

$ timeout --signal=TERM --kill-after=2s 8s /usr/bin/godot --headless --path .shokunin/games-engine-mechanics --script res://causal_chain.gd -- --negative
exit 1 (deliberate expected-negative status)
Godot Engine v4.7.2.stable.arch_linux.ed1daf0bf (2026-08-17 01:18:38 UTC) - https://godotengine.org
PASS negative input=1 moves=30 x=300.000031 collections=0 scene=A old_alive=true
```

The pre-existing eight native controls from the canonical R11b directory were copied under `.shokunin/games-engine-mechanics/controls/` and rerun with the same timeout and Godot binary. Native exits, in order, were `mechanic_test.gd` 0, `negative_test.gd` 1, `test_scene_signal.gd` 0, `test_scene_signal_negative.gd` 1, `overlap_probe.gd` 0, `overlap_negative.gd` 1, `scene_transition_probe.gd` 0, `scene_transition_negative.gd` 1. Stdout/stderr summaries:

```text
mechanic_test.gd (0): PASS first=true second=false consumed=true
negative_test.gd (1): ERROR: negative control: deliberate condition failed
  at: push_error (core/variant/variant_utility.cpp:1023)
  GDScript backtrace: [0] _initialize (res://negative_test.gd:6)
test_scene_signal.gd (0): PASS scene_loaded=true SceneTree_dispatched_event=E consumed=true signal_count=1 repeat_suppressed=true
test_scene_signal_negative.gd (1): ERROR: negative control: expected collected signal was absent (dispatch deliberately disabled)
  at: push_error (core/variant/variant_utility.cpp:1023)
  GDScript backtrace: [0] _initialize (res://test_scene_signal_negative.gd:22)
overlap_probe.gd (0): PASS packed_scene=true area_shape=true layers=1/2 masks=2/0 pre_overlap_signals=0 overlap_signal_count=1 consumed=true
overlap_negative.gd (1): ERROR: negative control: expected collected signal was absent with disabled mask
  at: push_error (core/variant/variant_utility.cpp:1023)
  GDScript backtrace: [0] _run (res://overlap_negative.gd:28)
scene_transition_probe.gd (0): PASS valid_transition=true current_scene_replaced=true marker=B old_scene_freed=true frames=4
scene_transition_negative.gd (1): ERROR: Can't change to a null scene. Use unload_current_scene() if you wish to unload it.
  at: change_scene_to_packed (scene/main/scene_tree.cpp:1714)
  GDScript backtrace: [0] _run (res://scene_transition_negative.gd:24)
PASS invalid_destination_rejected=true current_scene_preserved=true old_scene_alive=true frames=3
ERROR: negative control: deliberately invalid scene destination rejected
  at: push_error (core/variant/variant_utility.cpp:1023)
  GDScript backtrace: [0] _run (res://scene_transition_negative.gd:30)
```

All exit-1 controls are designed negative cases; exit 2 on the baseline is the deliberate R12 differentiator. The fixture is synthetic, headless GDScript SceneTree evidence only. It establishes neither OS/device input, editor behavior, nor player/full-game behavior. No manual handler shortcut, provider/daemon action, push, merge, MANIFEST edit, or global harness change was made.

## Git evidence

Required Git author and committer: `games-engine-mechanics-research <games-engine-mechanics-research@shokunin.local>`. Implementation/fixture commit precedes this report-only commit. Hashes recorded after commit.


## Append-only correction — baseline comparison semantics

The preceding baseline description overstates the comparison. `--baseline-release-test` dispatches E press and release, but the press-only `baseline_actor.gd` has no release counter, so the harness does **not** observe or assert a baseline release receipt. It snapshots the move count after dispatching release, waits 10 physics frames, and expects movement to have continued; continuation then emits `ERROR: movement continued after release; expected baseline failure` and exits 2. If movement had stopped unexpectedly, the alternate branch would also exit 2, with distinct stderr `baseline unexpectedly stopped after release`. Therefore exit status alone does not distinguish these baseline outcomes; the captured stderr is required. The observed baseline run had the continuation diagnostic above. This is a press-only behavior comparison after release dispatch, not proof of an observed baseline release callback nor an identical release-receipt assertion.

The positive release run reported `held_moves=3`, but this value is timing-dependent: the test checks `held_moves >= 3`, so it may vary across runs. The assertion is that movement continues while held and the count does not increase in the 10 physics frames after the new actor observes release and clears intent. There is no LOG file in the R12 research subtree to correct.
