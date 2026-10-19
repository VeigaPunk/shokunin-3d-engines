# r15 independent non-author slope review (2026-10-13)

**Verdict: PASS for a narrow headless Godot 4.7.2 slope-contact classification claim, with measurement limits below.** I did not author or edit fixture implementation. At review start `craft/game-dev-3d-r1` HEAD `1772b71663a0c9a950c781644abee26e899b4c01` (`game-dev-3d-shokunin <game-dev-3d@shokunin.local>`); author changes were still uncommitted. Godot `/usr/bin/godot --version` = `4.7.2.stable.arch_linux.ed1daf0bf`. Read standing mission `/tmp/mission-game-dev-3d-standing.md` and round-15 declaration in `.shokunin/game-dev-3d/LOG.md`.

## Independent execution and raw evidence

From repository root:

```sh
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only slope3d_floor,slope3d_steep
```

Both commands exited **0**. Full receipt: `.shokunin/game-dev-3d/corpus/live/runs/20261013T050139735344Z/verdicts.json` (21/21 ordinary/negative = 10/11; four opt-ins PASS). Paired receipt: `.shokunin/game-dev-3d/corpus/live/runs/20261013T050139735433Z/verdicts.json` (2/2). Their `seeds_unchanged=true`; all 20 full-receipt seed digests match current fixture seed bytes, and the paired receipt matches them. New seed `slope3d_angle.gd` SHA-256 `da332f721dc2c7edecbba153280c075c95452a8cb9d78134c60598c7917659f8`. Full stdout for each slope arm has Godot's version banner, a blank line, then exactly its one marker; stderr is empty:

- `slope3d_floor`: actual exit **0**, `PASS slope3d_floor normal_y=0.866 floor_limit=45.000 on_floor=true on_wall=false live_contact=true`.
- `slope3d_steep`: actual exit **2**, `NEGATIVE REJECTED: slope3d_angle steep_contact_not_floor normal_y=0.500 floor_limit=45.000 on_floor=false on_wall=true live_contact=true`.

All **19 prior r14 cases** match `.shokunin/game-dev-3d/corpus/live/runs/20261013T042316520026Z/verdicts.json` on case name, flags, raw stdout/stderr lines, exits and verdicts. Among 19 old seed files, only `README.md` and `run_battery.py` changed digest; 17 other previous seed digests match r14. Full opt-ins: identified descendant timed out with logical `actual_exit=null`, cleanup `-9`, marker seen, verified witness terminated via SIGTERM and classifier rejected; direct SIGTERM crash-exit probe PASS; same stdout/exit with extra stderr rejected in stream probe; existing body-contact mutation detected. Exact streams/exits live in corresponding `*-verdicts.json` next to full receipt; these are bounded opt-ins, not spontaneous crash or general process-tree claims.

Private angle mutation copied fixture seeds only to `.shokunin/game-dev-3d/corpus/live/runs/review-r15-ba25b29d96/private-slope-mutant/` and replaced one exact `const SHALLOW_ANGLE := 30.0` with `const SHALLOW_ANGLE := 60.0`; seeded SHA remained `da332f721dc2c7edecbba153280c075c95452a8cb9d78134c60598c7917659f8` and mutant SHA became `a6c4a0d93554a5552085635dfe809238b2fa8274ddedf3846b89c378c9adf097`. Direct command:

```sh
godot --headless --path .shokunin/game-dev-3d/corpus/live/runs/review-r15-ba25b29d96/private-slope-mutant --script res://slope3d_angle.gd
```

Actual exit **1**, stdout version banner only, stderr `ERROR: slope3d_angle: normal mismatch normal=(-0.866025, 0.5, 0.0) expected=(-0.5, 0.866025, 0.0)` and `_fail` backtrace; no success marker, `SCRIPT ERROR` or `Parse Error`. Raw captured output and command in ignored `.shokunin/game-dev-3d/corpus/live/runs/review-r15-ba25b29d96/private-slope-mutant.json`. This is literal normal rejection, **not** a parser failure. Extra independent optional control copied seeds to `.shokunin/game-dev-3d/corpus/live/runs/review-r15-ba25b29d96/private-floor-limit/`, changed `FLOOR_LIMIT := 45.0` to `15.0` only, and ran the same command against that directory: exit **1**, actual normal `(-0.5, 0.866025, 0.0)` but `shallow classification floor=false wall=true`; raw `.shokunin/game-dev-3d/corpus/live/runs/review-r15-ba25b29d96/private-floor-limit.json`. It demonstrates classification is read live and can fail independently of the normal assertion, but does not prove every angle boundary.

## Source audit and limits

`slope3d_angle.gd` constructs a 12×1×12 intact `StaticBody3D` slab, rotated around Z by 30° or 60°, in layer 1; `Runner` `CharacterBody3D` starts at (0,3,0) with 1³ box, layer 2/mask 1, grounded motion mode, +Y up, floor limit 45°, vertically driven -6. Both arms check shapes, tree membership, mask overlap, a bounded 30-frame contact, `contacts >= 1` and `first_contact_tick > 0` from actual `get_slide_collision_count`; no missing-geometry surrogate. `runner3d.gd` stores `get_slide_collision(0).get_normal()` on first contact. Separately, fixture checks that this observed normal is within 0.001 of hand-authored (-0.5, 0.8660254, 0) or (-0.8660254, 0.5, 0), then separately queries both `actor.is_on_floor()` and `actor.is_on_wall()`; shallow requires true/false, steep false/true. Both are real contacts with discriminating floor/wall classification in the observed runs.

**Temporal caveat:** `physics_frame` fires *before* the physics step. `first_contact_tick` and `first_contact_normal` were stored during a completed `_physics_process`, then `_run` resumes at the following `physics_frame` and immediately checks `is_on_floor/is_on_wall` before the next `_physics_process`; the first collision and queried flags thus refer to the preceding solver step under the current loop structure, not an as-yet-unprocessed future frame. However, the fixture does **not** assert `get_slide_collision_count()` or the contact normal afresh at the classification snapshot; first-contact counters/normals are cumulative historical fields. If the loop's timing changed or contact were transient, a historic contact and flags could be attributed to different steps. Current source and runs support the narrower first-contact classification, not persistent grounded contact or a tick-exact dwell claim.

**Fixed-marker caveat:** `normal_y=0.866/0.500`, `floor_limit=45.000`, booleans and `live_contact=true` are hardcoded strings, **not telemetry formatted from queried values**. The normal tolerance and floor/wall predicates are independently checked beforehand, and the private angle and floor-limit mutations reject, but no runtime readback asserts `actor.floor_max_angle == 45°`, `slab.rotation.z`, collision normal at print time, or an exact contact count. A mutated floor limit still allowing both classifications could silently print 45°. Claim observed bounded classification with source-pinned settings and tolerant normals; not an exact printed-measurement audit, general boundary proof, downhill sliding, gravity, friction, rendered geometry, or other engines.

<!-- r106-seat45-receipt-note -->

> **Non-resolvable receipt note (r106, 2026-10-18, SEAT-45).** Re-checked 2026-10-18: each path below is a concrete `corpus/live/runs` receipt cited in this lesson. The cited path is absent (`test -e` failed) and no durable copy exists under `reports/` (no receipt artifact whose path or `started_utc` is that run id; a prose mention is not a copy). Quoted receipt SHA-256 values on these lines do not match any tracked file or any `reports/` receipt artifact. `corpus/.gitignore` ignores `live/`, so these paths were never tracked. Historical sentences above are unchanged. Register: `reports/round-106/consistency/receipts.md`.
>
> - `corpus/live/runs/20261013T050139735344Z/verdicts.json`
> - `corpus/live/runs/20261013T050139735433Z/verdicts.json`
> - `corpus/live/runs/20261013T042316520026Z/verdicts.json`
> - `corpus/live/runs/review-r15-ba25b29d96/private-slope-mutant/`
> - `corpus/live/runs/review-r15-ba25b29d96/private-slope-mutant`
> - `corpus/live/runs/review-r15-ba25b29d96/private-slope-mutant.json`
> - `corpus/live/runs/review-r15-ba25b29d96/private-floor-limit/`
> - `corpus/live/runs/review-r15-ba25b29d96/private-floor-limit.json`
