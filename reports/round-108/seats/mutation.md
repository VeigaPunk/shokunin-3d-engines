# r108 seat output — mutation (agent W2RoundGameDev3d.R108Mutation)

**Probe: `slope3d_bound**` rows discriminate — 5/5 mutants KILLED.** Scratch `$XDG_RUNTIME_DIR/g3d-r108-mut-{0..5}` (copies of project.godot, runner3d.gd, slope3d_boundary.gd; lane worktree never written).

Detector = the two CASES rows' classify contract from `corpus/fixtures/run_battery.py` (extracted verbatim, asserted byte-exact): `slope3d_bound_edge_in` t=45.57 exit 0 + exact `PASS slope3d_boundary tilt=45.570 …threshold_deg=45.5730 on_floor=true on_wall=false`; `slope3d_bound_edge_out` t=45.58 exit 2 + exact `NEGATIVE REJECTED: … tilt=45.580 … on_floor=false on_wall=true`; err non-blank / ERROR / SCRIPT / Parse lines fail. Command per run: `/usr/bin/godot --headless --path <dir> --script res://slope3d_boundary.gd -- --tilt <t>` (Godot 4.7.2.stable.arch_linux.ed1daf0bf).

Baseline (pristine, mut-0): both rows pass exactly (exit 0 line / exit 2 line identical to CASES).

- **M1** FLOOR_LIMIT 45.0→45.01 (sha 7afea1d2…): row_FAIL both — t=45.57 `limit=45.010 threshold_deg=45.5830` (exit 0, marker mismatch); t=45.58 exit 0≠2 `margin` → **KILLED**
- **M2** ENGINE_FLOOR_ANGLE_THRESHOLD 0.01→0.0 (sha cb5c23b4…): row_FAIL both — `threshold_deg=45.0000` replaces 45.5730 in both markers (exits unchanged) → **KILLED**
- **M3** actor-only `floor_max_angle=deg_to_rad(44.99)` (sha 5a41d922…): row_FAIL both — exit 1, `ERROR: slope3d_boundary: setting mismatch floor_limit=44.990 tilt=45.570 expected_tilt=45.570` (guard fires before classification) → **KILLED**
- **M4** swapped PASS/NEGATIVE branches (sha 6db0ad7d…): row_FAIL both — t=45.57 exit 2 prints `NEGATIVE REJECTED: … on_floor=true on_wall=false`; t=45.58 exit 0 prints `PASS … on_floor=false on_wall=true` → **KILLED**
- **M5** expected_normal sign flip (sha 483b92f0…): row_FAIL both — exit 1, `normal mismatch normal=(-0.714106, 0.700037, 0.0) expected=(0.714106, 0.700037, 0.0)` → **KILLED**

Restoration: each mutant file overwritten with pristine bytes, sha256 == `6f5af99d8373055dab918bca54d7b769cfc5a9ff8cddd9a9dcd5ef9c76103e2d` for all 6 dirs; re-run of both tilts → 12/12 row_pass with the exact CASES lines. Scratch deleted (`rm -rf /run/user/1000/g3d-r108-mut`, dir absent); lane `corpus/fixtures/slope3d_boundary.gd` sha now still `6f5af99d…` (115 fixture files intact).

Limits: one Godot 4.7.2 host build; kill set limited to these five authored mutants; no claim about other rows/scripts. All five mutations are behavior-bearing at the two measured points — the edge rows kill every plausible single-point defect I applied.
