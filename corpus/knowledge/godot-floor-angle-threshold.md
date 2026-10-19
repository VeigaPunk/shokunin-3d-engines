source: S011 — Godot `CharacterBody3D` source — https://raw.githubusercontent.com/godotengine/godot/4.7-stable/scene/3d/physics/character_body_3d.cpp — `#define FLOOR_ANGLE_THRESHOLD 0.01` (line 41) and the floor predicate (lines 546, 598), tag `4.7-stable`; S035 — own-work boundary scan `reports/round-108/battery/boundary-scan.txt` + battery rows `slope3d_bound_*`; S012 — CharacterBody3D class reference (`floor_max_angle`), stable 4.7
verified-at: 2026-10-19 — source opened at `4.7-stable`; scan and battery run on Godot 4.7.2.stable.arch_linux.ed1daf0bf headless, GodotPhysics3D (DEFAULT) and Jolt
recheck: on-release — `PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" python3 corpus/fixtures/run_battery.py --only slope3d_bound_naive,slope3d_bound_in,slope3d_bound_edge_in,slope3d_bound_edge_out,slope3d_bound_out` must print `totals: cases=5 pass=5 fail=0`; re-open S011 at the new tag and re-read the define

# Godot CharacterBody3D: `floor_max_angle` is not the floor/wall boundary

**Claim.** In Godot 4.7.2 (headless, this host), a `CharacterBody3D` in
`MOTION_MODE_GROUNDED` with `floor_max_angle = 45°` classifies a contact as
floor up to a contact-normal angle of **45° + 0.01 rad = 45.573°**, not 45°.
Measured: a slab tilted 45.1°, 45.5° or 45.57° gives `is_on_floor()=true,
is_on_wall()=false`; 45.58°, 45.65° or 46° gives `is_on_floor()=false,
is_on_wall()=true` — identically under GodotPhysics3D and Jolt Physics
(`reports/round-108/battery/boundary-scan.txt`).

**Why (document/source fact, S011).** The 4.7-stable implementation defines
`FLOOR_ANGLE_THRESHOLD 0.01` and sets the floor state when
`floor_angle <= floor_max_angle + FLOOR_ANGLE_THRESHOLD`. The class reference
(S012) documents only the 45° default; it does not mention the allowance. The
comparison lives in scene code, after the physics server returns the normal,
which is consistent with the backend-invariant flip measured above
[INFERENCE for backends other than the two measured].

**Decision.** Author floor/wall fixtures and level geometry with the effective
boundary `floor_max_angle + 0.573°`: a slope meant to be unclimbable at a 45°
limit must exceed 45.573°; a test that expects 45.1° to be a wall fails. Keep a
bracket pair within 0.01° of the effective boundary (45.57°/45.58°) as the
discriminating control.

**Does not reach.** Other `floor_max_angle` values (the allowance is a
constant 0.01 rad by source, but only 45° was measured); `MOTION_MODE_FLOATING`;
`floor_block_on_wall`, `floor_snap_length` and moving-platform interactions;
the ceiling predicate (same threshold in source, not measured); Godot versions
other than 4.7.2.

**Evidence.** Runtime: `reports/round-108/battery/README.md` — five rows
`slope3d_bound_{naive,in,edge_in,edge_out,out}` PASS in the full pinned run
(355 cases, `seeds_unchanged=true`; the run's two FAIL rows are pre-existing
r95 host drift reproduced on the base commit). Non-author replay (SKILL.md §1
row F): reviewer seat `W2RoundGameDev3d.R108PostReviewer` re-ran the five rows
plus the two `slope3d_angle` rows → `totals: cases=7 pass=7 fail=0`,
`seeds_unchanged=true` (`reports/round-108/battery/replay-nonauthor-20261019T222103636356Z.verdicts.json`).
The orchestrator's post-round re-run is the external check.

**Admission.** `corpus/QUALITY.md` Q1–Q6, Q16, Q17 pass; Q7 not applicable.
Pass list: `corpus/lessons/round-108.md` `## Gate`.
