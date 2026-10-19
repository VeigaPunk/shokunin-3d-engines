# r108 battery receipts — floor-angle boundary (claim C3)

Host: Godot `4.7.2.stable.arch_linux.ed1daf0bf`, `/usr/bin/godot`, Node pinned
`v24.21.0` (fnm, `corpus/fixtures/PINNED-ENV.md`). All commands from the lane
worktree root. The executor seat for this work died twice of provider rate
limits before writing anything; the L1 wrote and ran everything below.

## What changed

- New seed `corpus/fixtures/slope3d_boundary.gd` (sha256
  `6f5af99d8373055dab918bca54d7b769cfc5a9ff8cddd9a9dcd5ef9c76103e2d`): the
  `slope3d_angle.gd` slab/actor/runner setup with the slab tilt taken from
  `--tilt <deg>`, `floor_max_angle = 45°`, and the contact normal angle and the
  engine threshold `45° + 0.01 rad = 45.5730°` printed in the marker.
- `corpus/fixtures/run_battery.py`: five CASES tuples inserted after
  `slope3d_steep` (`git diff -U0` shows only added lines). sha256 before
  `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`, after: see
  `sha256sum corpus/fixtures/run_battery.py` at the r108 commit.
- `slope3d_angle.gd` untouched (`git diff corpus/fixtures/slope3d_angle.gd` empty).

## Boundary scan (scratch, before the rows were written)

`boundary-scan.txt` — tilts 45.0, 45.1, 45.5, 45.55, 45.56, 45.57, 45.58,
45.6, 45.65, 46.0 in two scratch copies of the seed project: DEFAULT engine
(`ProjectSettings physics/3d/physics_engine = DEFAULT`, i.e. GodotPhysics3D;
`project.godot` sets no engine key) and Jolt (`3d/physics_engine="Jolt Physics"`
appended to the copied `project.godot`). Both backends: floor through 45.57°,
wall from 45.58°. Source prediction (Godot `4.7-stable`
`scene/3d/physics/character_body_3d.cpp`, `FLOOR_ANGLE_THRESHOLD 0.01`,
`floor_angle <= floor_max_angle + FLOOR_ANGLE_THRESHOLD`; SOURCES S011): 45.573°.
The W1 dossier's earlier prediction (45.1° = wall) is superseded: 45.1° is floor.

| row | tilt | expected | measured marker fields |
|---|---|---|---|
| `slope3d_bound_naive` | 45.1 | exit 0 floor | `normal_deg=45.1000 on_floor=true on_wall=false` |
| `slope3d_bound_in` | 45.5 | exit 0 floor | `normal_deg=45.5000 on_floor=true on_wall=false` |
| `slope3d_bound_edge_in` | 45.57 | exit 0 floor | `normal_deg=45.5700 on_floor=true on_wall=false` |
| `slope3d_bound_edge_out` | 45.58 | exit 2 wall | `normal_deg=45.5800 on_floor=false on_wall=true` |
| `slope3d_bound_out` | 45.65 | exit 2 wall | `normal_deg=45.6500 on_floor=false on_wall=true` |

The battery rows run the DEFAULT engine only; the Jolt result is the scratch
scan above (one project setting cannot vary per row).

## Runs

1. Slope rows only — `PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" python3 corpus/fixtures/run_battery.py --only slope3d_floor,slope3d_steep,slope3d_bound_naive,slope3d_bound_in,slope3d_bound_edge_in,slope3d_bound_edge_out,slope3d_bound_out`
   → `totals: cases=7 pass=7 fail=0` (`slope-only.verdicts.json`).
2. Full pinned battery — same `PATH` prefix, `python3 corpus/fixtures/run_battery.py`
   → `totals: cases=355 pass=353 fail=2 ordinary=294 negative_controls=61`,
   `seeds_unchanged=true`, wall clock 672.8 s (`full-run-20261019T220450573107Z.verdicts.json`,
   `full-run.stdout.txt`). All five new rows PASS.
3. Prior-row comparison — `python3 reports/round-108/battery/compare_prior.py reports/round-108/battery/full-run-20261019T220450573107Z.verdicts.json reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json`
   → 350/350 prior CASES definitions unchanged (0 changed marker/exit/flags/script);
   2 prior rows changed verdict PASS→FAIL: `r95_bullet_shm`, `r95_bullet_solver`.

## The two FAIL rows are host drift, not this change

Both fail on `exact stdout marker missing`; the only difference is the child
diagnostic-line count `d` (lines beginning `#` in the pybullet child log,
`r95_bullet.gd` `_run_child`): `shm_step d=16` vs pinned `8`, `shm_rtclass d=52`
vs `44`, `sv_backends d=5` vs `4`. This is lane mistake class M5 (SHM teardown
diagnostic-count race, `SCORECARD.md:241`; `corpus/lessons/round-108.md` M5),
here stable rather than racy: an isolated rerun fails identically
(`r95-rerun.verdicts.json`), and the **base commit's own runner and seeds**
(`git archive 7c4e589 corpus/fixtures` into `$XDG_RUNTIME_DIR`, `--only
r95_bullet_shm,r95_bullet_solver`) fail identically (`base-7c4e589-r95-rows.verdicts.json`,
`d=16` twice). Host observation at the time: `/dev/shm` held 303 entries.
Routed: the r95 SHM `d` count is not a stable pin on this host; the fix belongs
to a round that re-scopes that marker (envelope or drop `d`), not to C3.

## Unreal-MCP gate (capability demonstration)

`GATE_WORKDIR=$XDG_RUNTIME_DIR/r108gate bash corpus/knowledge/unreal-mcp/gate/run_gate.sh`
→ `GATE RESULT: PASS (checks failed: 0)`, `rc=0`, `POINTERS=103 UNRESOLVED=0`
(`gate-run.txt`).
