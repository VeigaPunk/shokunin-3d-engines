# r108 seat output — pre-reviewer (agent W2RoundGameDev3d.R108PreReviewer-5)

**Verdict summary:** Most base-state facts reproduce at 7c4e589. Corrections: D8 depth last-change is r70, not r71. D13 has 2 live SCORECARD axis-command lines, not 3. D15 is not reproducible in the current tree. M4's pointer is line 231, not 233. C3 is confirmed: the threshold is in radians and the prediction of 45.573° holds for the cited code. I wrote nothing.

## Corpus table (§3), base 7c4e589
- **CONFIRMED:** knowledge md 26; entry docs 0/6 for `source:`/`verified-at:`/`recheck:`; executability 13; upstream 12; lessons 92, all `r<N>-*.md`, 0 `round-*.md`; `## Gate` 0/92; capital "Gate" 0; lowercase "gate" in 21; QUALITY.md and SOURCES.md absent; Frontier 0 in README; PROVINCE Core/Frontier/Adjacent 0; fixtures tracked 147; CASES 350 (`grep -cE '^\s+\("'`); slope3d_angle rows 2; run_battery sha256 `f456bd00…`, blob `dd2d9b74…`; LOG 1500 lines (284,959 B); SCORECARD 345 lines, 30 blocks; SHONEN 1 `[x]` / 3 `[ ]`; `reports/round-104` 21,950 tracked (physics 15,495); receipt `…rerun-20261018T204240Z.verdicts.json` 350 results = 291 ordinary + 59 negative, PASS, seeds_unchanged=true.
- **CONFIRMED (scope-dependent):** unique external URLs = 2 (EpicGames/unreal-engine, VeigaPunk/prymeagnt-games-engine-mechanics) over flat docs + SKILL + PROVINCE. A wider pathspec including `unreal-mcp/` returns 27 because of `127.0.0.1` URLs. State the scope.
- **WT, not base (drifted):** `du reports` = 455M now (dossier 456M). `reports/round-104` 410M and `corpus/live` 1.7G match.
- **UNVERIFIABLE:** `corpus/fixtures/three/node_modules` 23M. It is gitignored and not in the base tree.

## Defects D1–D17
| # | Verdict | Evidence |
|---|---|---|
| D1 | CONFIRMED | `corpus/QUALITY.md` absent at base |
| D2 | CONFIRMED | `corpus/SOURCES.md` absent |
| D3 | CONFIRMED | 0/0/0 on all six docs |
| D4 | CONFIRMED | 0/92 `## Gate`; 0/92 `round-*.md` |
| D5 | CONFIRMED | README: 0 Frontier; only `## Correction note (r106, 2026-10-18)` |
| D6 | CONFIRMED | PROVINCE:46 "Only writes `.shokunin/game-dev-3d/**`…"; :25 same root; base tree has no `.shokunin` entry |
| D7 | CONFIRMED | README:16 "`QUALITY.md` (the admission bar)" |
| D8 | **WRONG** | Depth last-change at SCORECARD:8 is **r70**, not r71. Coverage r68 (:9) and calibration r61 (:10) are correct. |
| D9 | CONFIRMED | SCORECARD:279 `— none yet —`; :283–285 saturation placeholder |
| D10 | CONFIRMED | 30 blocks. Missing 90, 91, 99, 100; r92 is only an inline row (:213). Block "87" at :150 precedes 85 (:162) and 86 (:174). 81/82 dated 2026-11-01 at :109, :119. |
| D11 | CONFIRMED | No ROUND 90/91/107 in LOG; last is ROUND 106 at LOG:1473 |
| D12 | CONFIRMED | Fleet MANIFEST lane rounds [70,71,72,73]; minted 2026-10-11; `.ufo/state/game-dev-3d.round` = 1; 13 lane files under `.ufo/reports` (found by path match, not content grep) |
| D13 | **PARTLY WRONG** | 306 files ✓; 231 reports + 72 corpus ✓ (lessons 64, fixtures 4, artifacts 3, README 1); 4 fixture files ✓. Live SCORECARD axis commands are **2** (:8, :9), not 3; :341 is historical prose. PROVINCE has 2 (:25 sources, :46 scope). |
| D14 | PARTLY UNVERIFIABLE | Tracked counts ✓. Sizes are WT: 410M ✓, 455M (not 456M), 1.7G ✓. node_modules unverifiable. |
| D15 | **NOT REPRODUCIBLE NOW** | `reports/round-107/` absent in WT. `git status --porcelain --untracked-files=all` shows 1 entry: `?? reports/round-108/before.md`. At base the committed `reports/round-107-aborted-swarm/r107-planner.md` is 10 lines ✓. The 79-file/988K snapshot is not observable. |
| D16 | CONFIRMED | fixtures README:5 "235 … 189 ordinary and 46"; receipt 291/59 |
| D17 | CONFIRMED | MANIFEST minted 2026-10-11; corpus/README.md:3-4 "minted 2026-10-13" |

## M1–M15 evidence pointers
- **M1** CONFIRMED: r90-verifier "Round verdict | **REJECT**" (table row has a leading empty cell); cbc52eb message "r90/r91 skipped (no adjudicator yet)".
- **M2** CONFIRMED: r91-author.md "Seat completion note … dispatched author died"; b6ba234 "235/235".
- **M3** CONFIRMED: SCORECARD:213 "verifier FAILED pre-fold". The 0.016667 / 0.166667 figures are not checked.
- **M4** **POINTER WRONG**: "accumulator cells flip ~1% under contention" is at SCORECARD.md:**231**, not 233.
- **M5** CONFIRMED: SCORECARD:241.
- **M6** CONFIRMED: LOG:1279 inside ROUND 99 block (1274–1280).
- **M7** CONFIRMED: LOG:1337 (wrapped), "11/11" at :1341.
- **M8** CONFIRMED: LOG:1386, inside ROUND 103 block.
- **M9** CONFIRMED: LOG:1400–1402 "CONFORMANCE DEFECT (recorded, ruled accepted)".
- **M10** CONFIRMED: LOG:1425–1426.
- **M11** CONFIRMED: LOG:1458–1459 (wrapped), inside ROUND 105.
- **M12** CONFIRMED: LOG:1474–1478 "47/128", "Cursor Pro … rate limit"; SCORECARD:337–345.
- **M13** CONFIRMED: HEAD 7c4e589 message. The 79-file count is not reproducible now (D15).
- **M14** CONFIRMED: reports/round-104/lessons-carry.md:81 exact quote. SKILL.md has 0 "quality" hits.
- **M15** CONFIRMED: fixtures README:5.
- **Not re-run:** the SKILL keyword sweep counts in §4 other than the two above.

## C3: Godot CharacterBody3D floor boundary
- **Tags fetched:** `4.7-stable` and `4.7.2-stable` (raw GitHub, `scene/3d/physics/character_body_3d.cpp`). Both are 968 lines and byte-identical (sha256 prefix `f957ef0bbe67bcde`). Tag commit SHAs could not be obtained: GitHub API returned 403 rate limit. I did not establish whether a newer stable tag exists.
- **Constant:** L41 `#define FLOOR_ANGLE_THRESHOLD 0.01`. Comment at L40. It is in **radians**, and `floor_max_angle` is radians too (`set_floor_max_angle(radians)`, L825–826). 0.01 rad = 0.5730°, so the effective boundary is 45.573°.
- **Entry:** `bool CharacterBody3D::move_and_slide()` L43. Grounded branch dispatches to `_move_and_slide_grounded` at L119 (`motion_mode == MOTION_MODE_GROUNDED`).
- **Primary floor classification:** `_set_collision_direction` L528. L545 `floor_angle = collision.get_angle(up_direction)`; **L546 `if (floor_angle <= floor_max_angle + FLOOR_ANGLE_THRESHOLD)`**; L547 `r_state.floor = true`; L548–549 sets `collision_state.floor` only if `p_apply_state.floor`.
- **Other places the threshold can flip the result:**
  - Ceiling: L558–559, `get_angle(-up) <= floor_max_angle + thr`. Irrelevant at 45° for upward slopes.
  - Combined-wall floor: L592–608. When ≥2 wall contacts and no floor, L597–598 `acos(combined_wall_normal·up) <= floor_max_angle + thr` makes it a floor and clears wall (L599–600). This is a second floor path for corners/wedges.
  - Wall min-slide: L432 `< wall_min_slide_angle + FLOOR_ANGLE_THRESHOLD`. Not a floor test.
  - Snap: `apply_floor_snap` L459 and `_snap_on_floor` L495–501 go through `_set_collision_direction` with floor-only apply state (L476), so L546 decides snap-floor. `_on_floor_if_snapped` L503–520 likewise.
  - `floor_block_on_wall` L219–231 uses `motion_angle < .5*PI` (L224). It has **no** threshold term.
  - `get_floor_angle` L699–701 is raw `acos(floor_normal·up)` with no threshold. At 45.1–45.57° `is_on_floor()` is true while `get_floor_angle()` exceeds `floor_max_angle`. The fixture should not assert the two agree.
- **Prediction check:** 45.1° ≤ 45.573° → floor. 45.5° → floor. 45.65° > 45.573° → wall. Matches the stated prediction, subject to the snap/combined-wall caveats above.

No files written. The `cd` / stray-write notice does not apply to this read-only run: all commands used absolute paths or the worktree as `cwd`, and nothing was written outside it.
