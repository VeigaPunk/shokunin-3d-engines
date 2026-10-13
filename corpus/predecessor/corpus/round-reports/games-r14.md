# Games R14 — input route path repair

Research-only fixture result, based on `119f010` in the isolated R14 route worktree. This is one calibration-axis candidate; coverage is unchanged. Scope is only the existing synthetic headless `Node._input` route fixture and its disabled-node control.

## Baseline and change

Before editing, native Godot 4.7.2 (`godot --headless --path .shokunin/games-engine-mechanics --script controls/input_route.gd`, serial) exited 1 after failing to load `res://input_route_receiver.gd` (file not found), then reporting no receipt. `input_route_negative.gd` also logged the missing-file errors, printed its zero-receipt PASS line, and exited 1. Thus its zero was not a discriminating result: the receiver had not loaded.

Both scripts now load `res://controls/input_route_receiver.gd`, fail explicitly if the script load returns null, and verify the assigned script and `route_owner` before dispatch. The negative control documents that exit 1 is intentional after a discriminating zero-receipt result.

## Bounded serial evidence

After the repair, three serial active runs each printed `PASS route=parse_input_event-to-Node._input key=R receipt_count=1 frames=3`, exited 0, and had no load/error output. Three serial disabled-control runs each printed `PASS negative_route=disabled_node receipt_count=0 frames=10 expected_exit=1 (intentional negative-control status)`, exited 1, and had no load/error output. The expected exit 1 is deliberate negative-control semantics, not a successful active test exit.

An active-route mutant was tested by disabling receiver input processing after setup. It produced the explicit `dedicated Node._input did not receive synthetic R within 8 frames` assertion and exit 1. The mutation was removed before commit; final active rerun passed.

## Axis assessment and limits

**Calibration: improved** for this narrow fixture. The old negative PASS could be mistaken for correct discrimination despite the missing script; now both controls require successful receiver loading/setup before injecting input, and the active route has a measured one-receipt positive plus a demonstrated receipt-suppression mutant. **Coverage: unchanged**; this repairs and clarifies existing test evidence, without adding a new engine behavior domain.

Evidence is limited to bounded serial native Godot 4.7.2 headless GDScript/SceneTree runs in this fixture. It does not establish OS/device input, editor, full-game/player, parallel reliability, or general input-route behavior.

Implementation commit: `3e21ae2cf76c452d3e166ce34dfaab6886a88bda`. The report is committed separately and last. No manifest/global harness, provider/daemon, merge, or push action was performed.
