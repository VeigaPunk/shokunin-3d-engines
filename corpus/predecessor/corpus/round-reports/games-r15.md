# Games R15 — input receiver process-mode toggle

Research-only one-axis **calibration** candidate, isolated worktree `/home/vgpnk/Projects/prymeagnt-games-r15-toggle`, base `2eecc8ca25bcf9fe0efc9bf222e51fd7290a7c3d`. Fixture commit: `03a5158f94b6066699c0f50ff3037aa5152e8799`. This report is a separate, last commit.

## Claim and fixture

R14's positive route and permanently disabled negative control did not establish that the *same* `Node._input` receiver can be reenabled without delivering the first queued event or duplicating the second. `controls/input_route_toggle.gd` loads and verifies R14's `res://controls/input_route_receiver.gd`, assigns `route_owner`, sets `Node.PROCESS_MODE_DISABLED`, and adds that receiver once to `root`. It sends a synthetic pressed R with `Input.parse_input_event`; eight process frames require zero receipts. It then changes the *same node* to `Node.PROCESS_MODE_INHERIT`, waits two process frames requiring zero late first receipts, sends a fresh pressed R, waits at most eight frames for exactly one receipt, then checks two further frames for no duplicate or queued receipt. The receiver itself is unchanged. The global process-frame ceiling is 120; every native invocation has a separate 8-second timeout.

A temporary **private** mutated copy replaced the reenable assignment and its verification with `receiver.process_mode = Node.PROCESS_MODE_DISABLED`. With otherwise identical assertions it exited 1 and emitted `ERROR: input route toggle: reenabled receiver did not receive second R within 8 frames; receipt_count=0` (`_run` line 47 of temporary mutant). The mutant copy was deleted; the committed fixture was not changed by the mutation. This explicitly discriminates the missing reenable behavior by its error string, not merely its exit code.

## Native serial checks

`/usr/bin/godot --version`: `4.7.2.stable.arch_linux.ed1daf0bf`, exit 0. Runs were **serial**, from this worktree, using `timeout --signal=TERM --kill-after=2s 8s /usr/bin/godot --headless --path .shokunin/games-engine-mechanics --script SCRIPT [-- FLAGS]`. For each of three serial rounds, results were:

| Script / flags | Exits, rounds 1/2/3 | Diagnostic each run |
|---|---|---|
| `controls/input_route_toggle.gd` | 0/0/0 | `PASS toggle=disabled-to-inherit first_receipts=0 second_receipts=1 late_receipts=0 frames=15` |
| R14 `controls/input_route.gd` | 0/0/0 | `PASS route=parse_input_event-to-Node._input key=R receipt_count=1 frames=3` |
| R14 `controls/input_route_negative.gd` | 1/1/1, intentional negative | `PASS negative_route=disabled_node receipt_count=0 frames=10 expected_exit=1 (intentional negative-control status)` |
| R12 `causal_chain.gd -- --release-test` | 0/0/0 | `PASS release press_receipts=1 release_receipts=1 held_moves=3 post_release_moves=0 scene=A` |
| R12 `causal_chain.gd -- --baseline-release-test` | 2/2/2, expected baseline assertion | `ERROR: movement continued after release; expected baseline failure` |
| R12 `causal_chain.gd -- --wrong-key-negative` | 1/1/2 | First two: `PASS wrong_key=F receipts=0 intent=false physics_moves=0 collections=0 scene=A old_alive=true frames=30`; third: `ERROR: process bound exceeded`. A **fourth serial rerun** exited 1 with the expected `PASS wrong_key=F receipts=0 intent=false physics_moves=0 collections=0 scene=A old_alive=true frames=30`; the third-run bound failure remains a recorded limitation, not a pass. |
| R13 `causal_chain.gd -- --keyup-test` | 0/0/0 | `PASS keyup E_press_receipts=1 F_release_receipts=0 E_release_receipts=1 unrelated_release_moves=6 post_E_release_moves=0 scene=A` |
| R13 `causal_chain.gd -- --keyup-test --any-key-up-mutant` | 2/2/2, expected mutant assertion | `ERROR: movement stopped after unrelated F release` |

Additional R12/R13 chain positive and mask-negative controls, run serial once each after the table: default `causal_chain.gd` exited 0 with `PASS positive input=1 physics_moves=10 collections=1 scene=B old_freed=true`; `--negative` exited intentional 1 with `PASS negative input=1 moves=29 x=290.000031 collections=0 scene=A old_alive=true`. The R13 `unrelated_release_moves=6` field is the existing fixture's label, not a measured exact movement delta; the R12 wrong-key round-three global process-bound failure shows the older chain can be scheduling-sensitive even in serial runs. The R15 toggle itself passed all three runs and its private mutant failed with the exact targeted second-receipt diagnostic.

## Axis and limits

**Calibration: improved** for the narrow R14 synthetic `Node._input` fixture: previously separate always-active and always-disabled nodes could not distinguish successful enablement of the same receiver or delayed/duplicate receipts; now bounded assertions and a reenable-suppressed mutant do. This does not claim improved overall chain reliability. **Coverage: unchanged** as an axis judgement: no OS/device input, editor, full-game/player, or parallel-reliability behavior is inferred. This is synthetic, headless SceneTree evidence only. The R12 wrong-key intermittent serial bound is reported rather than silently treated as success.

No games mint, manifest/global harness/provider/daemon edits, merge, push, or files outside the fixture and this report. `git diff --check` was clean. Both fixture and report commits use exact author and committer `games-engine-mechanics-shokunin <games-engine-mechanics@shokunin.local>`.

## Append-only correction — independent chain reproducibility review

A separate reviewer reran the existing chain controls serially and observed R12 `--wrong-key-negative` exits **1/2/1/2**: the exit-1 cases had the expected negative-control result, while exit-2 cases hit the process-frame bound. The reviewer also observed an exit **2** for the default `causal_chain.gd` positive control, with a null `get_instance_id` error followed by the process-frame bound. This differs from my earlier single default-positive exit 0 and reinforces the serial scheduling sensitivity already recorded for wrong-key. These independent outcomes are not evidence of overall chain regression clearance or stable R12 positive/negative behavior; an expected negative exit cannot be substituted for the bound failure. The R15 toggle's narrower three-run result and private mutant discrimination stand as reported, without any change to the **calibration improved (narrow fixture)** and **coverage unchanged** judgements. No fixture was changed for this correction.
