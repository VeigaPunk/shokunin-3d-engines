# Game-dev-3d round 71 — simplifier report (minimal-design critique, report-only)

Seat: simplifier. Judged the landed diff for the r71 depth move —
`NavigationAgent3D.path_postprocessing` {edgecentered, none} invariance of
`distance_to_target` on the r70 L-corridor detour geometry. Simplifier did
not author this round. All probes/mutants ran in own write scope
(`corpus/live/r71-simplifier/`); seeds untouched. Host devin,
`/usr/bin/godot` 4.7.2.stable.arch_linux.ed1daf0bf, physics 60 tps.

Landed diff at critique time (uncommitted, per lane convention):
`M corpus/fixtures/navagent3d_detour.gd` +45 lines,
`M corpus/fixtures/run_battery.py` +4 lines = 2 CASES tuples
(`navagent3d_detour_post_edgecentered`, `navagent3d_detour_post_none`,
both exit-0 ordinary). Nothing else tracked touched.

## Independent ground truth (own sweep probe, before reading the diff closely)

`corpus/live/r71-simplifier/proj/pp_probe.gd` — same 3-quad L-corridor,
spawn (0.5,0,0.5), target (2.5,0,3.5), one `--pp=sweep` process rebuilding
the agent per value (`godot --headless --path proj --script
res://pp_probe.gd`, output in `proj/pp.out` via earlier run):

| pp value | distance_to_target | next | npts | pathlen | final | path |
|---|---|---|---|---|---|---|
| corridorfunnel(0) | 3.605551 | (2,0,1) | 3 | 4.130649 | (2.5,0,3.5) | (0.5,0.5)(2,1)(2.5,3.5) |
| edgecentered(1) | 3.605551 | (2,0,0.5) | 4 | 4.707107 | (2.5,0,3.5) | (0.5,0.5)(2,0.5)(2.5,1)(2.5,3.5) |
| none(2) | 3.605551 | (2,0,0.5) | 4 | 4.549510 | (2.5,0,3.5) | (0.5,0.5)(2,0.5)(2,1)(2.5,3.5) |

pathlen values internally consistent with hand derivation: edge =
1.5+sqrt(0.5)+2.5 = 4.707107; none = 1.5+0.5+sqrt(6.5) = 4.549510;
funnel = sqrt(2.5)+sqrt(6.5) = 4.130649.

Same probe with `--straight` (r69 4x4 single-poly control): all three pp
rows byte-identical — `dist=2.828427 next=(3,0,3) npts=2` under every
value. Postprocessing is fully invisible on straight geometry.

## The discrimination lattice this diff had to respect

- `distance_to_target`: measured invariant 3.605551 across all three
  values — the invariance half of the declared claim holds on this build.
- `get_next_path_position`: partitions {funnel} vs {edge, none} but
  **cannot separate edgecentered from none** (both next=(2,0,0.5)).
- `npts`/`pathlen`/waypoint[2]: only the full-path pins separate all
  three (4.707107 vs 4.549510, gap 0.157597 ≈ 39x DIST_TOL 0.004).
- `get_final_position`: measured **invariant** (2.5,0,3.5) under all
  three values on this geometry — the declared claim's "changing
  get_final_position" half does not hold here; a fixture asserting a
  final change would fail on measurement.

## Verdict

**Minimal envelope; no deletion demanded.** 2 new arms for the 2
uncovered values; corridorfunnel coverage reuses the existing
`navagent3d_detour` arm — the author did not add a symmetry corridorfunnel
row (trap avoided). No per-pp straight arms (my probe proves they would
be pp-invariant noise). No redundant arms present.

## Adequate discrimination — the load-bearing pin is pathlen, not next

The post-arm block (`navagent3d_detour.gd:125-145`) pins
`path.size()==4` AND `next==(2,0,0.5)` AND per-arm `post_pathlen`
(4.707107 edge / 4.549510 none, line 129) AND final AND reachable. Since
`next` is identical under edge and none, the per-arm pathlen constant is
what makes the two new rows non-interchangeable — the author pinned it.
Had the arms pinned `next` alone, an edge↔none constant swap would pass
silently; they don't.

Falsification path is live code, not decoration: `semantic != "euclidean"`
→ `_fail("invariance falsified ...")` (line 133), and the bounded-UNKNOWN
branch is retained (line 131). Correct ordering — semantic classification
and falsification fire BEFORE the path pins, so a non-Euclidean world is
reported as falsified, not as a path-shape mismatch.

Subtle correctness: the semantic classifier's `path_sum` candidate is the
postprocessed `pathlen` measured on the queried path (line 89-92 compute
from the live `path`), not the funnel constant — under edgecentered a
path-sum world yields distance=4.707107, and m4 below shows exactly that
diagnostic. The classifier tracks the queried postprocessing.

## Mutation coverage — demonstrated (private scratch mutants, real exits)

Mutants in `corpus/live/r71-simplifier/detour-check/` (copy of the landed
fixture; godot exit codes captured directly, stderr quoted):

| mutant | run | exit | measured diagnostic |
|---|---|---|---|
| m1: edge setter EDGECENTERED→NONE | `--post-edgecentered` | **1** | `post_edgecentered path outputs unexpected ... pathlen=4.549510` — pathlen pin catches the swap |
| m1 same mutant | `--post-none` | **0 PASS** | mutant is a no-op on the none arm — pins isolate the tampered arm correctly |
| m2: pp setter block deleted (flag lands on default funnel) | both arms | **1/1** | `path outputs unexpected ... npts=3 next=(2,0,1) pathlen=4.130649` — the "flag did not take effect" trap is caught by npts+next pins |
| m3: `post_pathlen` constants swapped | both arms | **1/1** | measured 4.707107/4.549510 vs tampered pins — literal-tamper caught on measurement |
| m4: `distance := pathlen` (simulates a path-sum world) | both arms | **1/1** | `invariance falsified under post_* semantic=path_sum distance=4.707107/4.549510 euclid=3.605551` — the falsification branch fires with measured values |

Four mutants, seven failing runs, zero literal-only rejections. Mutation
coverage: adequate.

## Arm replay — exact markers byte-match CASES

All five detour arms run in `detour-check/` scratch copy; stdout
identical to the bound CASES strings; exits 0/2/2/0/0. Focused battery:

    python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
      --runs <abs r71-simplifier>/runs \
      --only navagent3d_detour,navagent3d_detour_straight,navagent3d_detour_assert_pathsum,navagent3d_detour_post_edgecentered,navagent3d_detour_post_none
    → totals: cases=5 pass=5 fail=0
    receipt: runs/20261013T233854937978Z/verdicts.json

## Claim-handling honesty

The brief's claim said next/**and final** change; measurement shows final
invariant. The author neither forced a final-change assert nor dropped
the final pin — it is pinned as an invariance witness (line 139) and the
header comment records "get_final_position stays (2.5,0,3.5) under all
values" (line 30). The partially-false declared claim is corrected in the
record, not enacted. The falsification side is honest too: each post arm
fails red (not green-negative) on a changed distance — matching the
brief's "a measured change falsifies the invariance claim" contract.

## Considered-and-rejected smaller expressions

- **Single `--post-sweep` arm** (one CASES row sweeping both values in
  one process — my probe proves it works mechanically): saves 1 CASES
  row, ~0 fixture lines (a loop replaces flag gating), but couples both
  values' fates into one red and breaks the one-value-per-row marker
  convention. Not demanded.
- **One `--pp=<int>` flag** instead of two booleans: saves 1 var + 3
  setter lines, adds parse logic — a wash.
- **Per-pp refuted-hypothesis negative rows** (e.g. assert
  distance==4.707107 under edgecentered, exit-2 NEGATIVE REJECTED):
  parallel to r70's `assert_pathsum`; would record the refutation as a
  green row. The r70 arm already refutes the path-sum hypothesis once,
  and the in-arm falsification branch carries the r71 direction — nice-to-
  have, not required for falsifiability. Not demanded.

## Nits (cosmetic, non-blocking)

- The 13-line header comment block (lines 21-33) is heavy; the file's
  documentary convention carries measured values in headers and this
  matches it. Largest trimmable surface in the diff, comments only.
- r70's dead `const DETOUR_EUCLID` (line 28) remains — outside this diff,
  still cosmetic, still the author's call.
- Flag-combo edges (`--straight --post-edgecentered`, double post flags)
  are unguarded but deterministic (post_edge wins via elif; straight
  returns early) — consistent with r70's unguarded combos; no CASES row
  combines flags.

## Contract preserved

`call_deferred`/`_run` shape, 30-frame settle, exact-match arg flags,
setup-pin block, `_fail`/`_cleanup` with full-RID teardown, PASS /
NEGATIVE REJECTED / exit-0-1-2 grammar, `%.6f` markers — all consistent
with the `navagent3d_*` family. `git diff` shows pure addition inside the
existing skeleton; no prior assertion touched.

## Evidence index

- Sweep probe + outputs: `corpus/live/r71-simplifier/proj/pp_probe.gd`,
  `pp.out` (3 PROBE rows, exit 0), `--straight` run in `pp_straight.out`
  (3 pp-invariant rows, exit 0).
- Mutant sources/outputs/exits: `corpus/live/r71-simplifier/detour-check/m{1-4}.{gd,out,err}`.
- Focused battery receipt:
  `corpus/live/r71-simplifier/runs/20261013T233854937978Z/verdicts.json`.

## Scope notes

- No full-battery or Node suite run — verifier/baseline scope. Baseline's
  frozen 88/88 + 31/31 stands; my replay covers the detour family only.
- `distance_to_target` invariance is confirmed for {edgecentered, none}
  on this stationary-agent L-corridor build; other geometries/agents in
  motion are outside this round's claim.
- Next deletion would remove a discriminating pin or an exercised
  falsification branch — it would harm an axis. Stopping.
