# Round 2 — independent non-author replay of r1 Godot battery

Reviewer: `game-dev-3d-r2-review-retry` (not the r1 author). Timestamp: 2026-10-13T03:06:49.833077+00:00. Working tree: `/home/vgpnk/Projects/prymeagnt/game-dev-3d`. Scope: read-only seeds and r1 code; only this review file and ignored runner receipts were written by this reviewer. **PASS**, with bounded limits below.

## Reproduce and receipts

From repo root, with installed Godot `/usr/bin/godot` (`4.7.2.stable.arch_linux.ed1daf0bf`):

```sh
python3 corpus/fixtures/run_battery.py
python3 corpus/fixtures/run_battery.py --probe-failing
```

First invocation started 2026-10-13T03:05:46.431758+00:00 and returned exit **0**, duration 9.720 s; receipt `corpus/live/runs/20261013T030546459582Z/verdicts.json` (`started_utc=20261013T030546459582Z`). Second started 2026-10-13T03:06:02.839920+00:00, returned exit **0**, duration 10.935 s; receipts `corpus/live/runs/20261013T030602866163Z/verdicts.json` and `corpus/live/runs/20261013T030602866163Z/mutation-verdicts.json` (`started_utc=20261013T030602866163Z`). The receipts include the full command, separate `stdout` and `stderr` lists, actual/expected exit, exact marker and verdict for each case. Both battery payloads report PASS, 12/12 passed, **6 ordinary exit-0 and 6 intended negative exit-2**; all `error` fields null and reasons empty.

## Independent receipt inspection

Each row was compared with the runner's `CASES` declaration (case name/script/flags/expected exit/full exact marker); actual exit matches expected, marker occurs **once as a full stdout line** and never on stderr; stderr contains zero lines and neither stream contains `ERROR:`/ObjectDB leak diagnostics in these twelve seed cases. Godot's version banner is additional stdout, not mistaken for a case marker. The second replay has the same checks and outcome.

| Seeded case | Actual/expected exit | Exact marker stream | stderr lines |
|---|---:|---|---:|
| `body3d_contact` | 0/0 | stdout | 0 |
| `body3d_contact_far` | 2/2 | stdout | 0 |
| `area3d_chain` | 0/0 | stdout | 0 |
| `area3d_chain_no_overlap` | 2/2 | stdout | 0 |
| `camera3d_project` | 0/0 | stdout | 0 |
| `camera3d_project_behind` | 2/2 | stdout | 0 |
| `raycast3d_hit` | 0/0 | stdout | 0 |
| `raycast3d_miss` | 2/2 | stdout | 0 |
| `transform3d_compose` | 0/0 | stdout | 0 |
| `transform3d_compose_wrong_order` | 2/2 | stdout | 0 |
| `input3d_move` | 0/0 | stdout | 0 |
| `input3d_move_no_event` | 2/2 | stdout | 0 |

Fresh source SHA-256 digest map has **12 files**, exactly matches both replay `seed_digests`, original r1 `corpus/lessons/r1/clean-verdicts.json` digests, and mutation `seed_digests_before`/`seed_digests_after`; both replay payloads say `seeds_unchanged=true`. No fixture-seed edit observed. The mutation scratch copy differs at exactly `body3d_slide.gd` among its nine GDScript files; the old box constant occurs once in seed and replacement occurs once in scratch.

`--probe-failing` ran the twelve seeded cases plus a separate **uncounted** mutant. The mutated `body3d_contact` expects exit 0 and its original PASS marker, but actually exits **1**, classifier verdict FAIL, PASS marker absent on stdout. Exactly one expected `ERROR: body3d_slide: body did not stop at the contact plane final_z=3.500 expected=2.500` line appears on **stderr**, with GDScript backtrace also on stderr; there is no script/parse error. `mutation-verdicts.json` records `detected=true`, `seeds_unchanged=true`, and probe verdict PASS. This is detection of **one** authored constant change (box depth 4→6), not generic mutation coverage.

## Source cross-check and limits

The r1 claim of hand-derived contact plane and first-contact tick checks is consistent with `corpus/fixtures/body3d_slide.gd`: `BOX_SIZE=(4,4,4)` and `RUNNER_SIZE=(1,1,1)` yield Z plane 4/2+1/2=2.5; start Z 6, speed 10 and 60 Hz yield (6−2.5)/(10/60)=21 ticks. Source independently stores `EXPECTED_PLANE_Z=2.5`, `EXPECTED_CONTACT_TICK=21`, checks measured `runner.position.z` against plane with epsilon 0.001, checks recorded first contact tick, then prints marker. The scratch depth 6 instead predicts plane 3.5 and emitted diagnostic confirms the assertion rejects it. No contradicted r1 claim found in this cross-check.

Limits: reviewed receipt streams and code, not external GPU rendering, export, Unity/Unreal/three.js, process-tree timeout/crash injection, or all possible mutations. Runner's classifier requires exact marker as a line but does **not** prohibit unrelated non-error stdout; this review verifies presence once, not an exclusive-stdout promise. The prior r1 `adversarial-controls.json` is not itself independently rerun here. The Godot run is host/version-specific; physics results could differ on another version or platform.

<!-- r106-seat45-receipt-note -->

> **Non-resolvable receipt note (r106, 2026-10-18, SEAT-45).** Re-checked 2026-10-18: each path below is a concrete `corpus/live/runs` receipt cited in this lesson. The cited path is absent (`test -e` failed) and no durable copy exists under `reports/` (no receipt artifact whose path or `started_utc` is that run id; a prose mention is not a copy). Quoted receipt SHA-256 values on these lines do not match any tracked file or any `reports/` receipt artifact. `corpus/.gitignore` ignores `live/`, so these paths were never tracked. Historical sentences above are unchanged. Register: `reports/round-106/consistency/receipts.md`.
>
> - `corpus/live/runs/20261013T030546459582Z/verdicts.json`
> - `corpus/live/runs/20261013T030602866163Z/verdicts.json`
> - `corpus/live/runs/20261013T030602866163Z/mutation-verdicts.json`
