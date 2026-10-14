# R71 — NavigationAgent3D path_postprocessing: `distance_to_target` is Euclidean-invariant (Godot 4.7.2)
>
## Decision and evidence
>
`path_postprocessing` reshapes the queried path corridor — never the
scalar. `distance_to_target()` returns the identical Euclidean distance
to raw `target_position` under every value while the path itself
provably changes (r70 L-corridor, S=(0.5,0,0.5) → T=(2.5,0,3.5)):
>
| `path_postprocessing` | `distance_to_target` | `get_next_path_position` | path pts | pathlen | `get_final_position` |
|---|---|---|---|---|---|
| 0 CORRIDORFUNNEL (default) | **3.605551** = √13 | (2,0,1) corner | 3 | 4.130649 | (2.5,0,3.5) |
| 1 EDGECENTERED | **3.605551** | (2,0,0.5) edge midpoint | 4 via (2,0,0.5),(2.5,0,1) | 4.707107 = 1.5+√0.5+2.5 | (2.5,0,3.5) |
| 2 NONE | **3.605551** | (2,0,0.5) | 4 via (2,0,0.5),(2,0,1) | 4.549510 = 1.5+0.5+√6.5 | (2.5,0,3.5) |
>
`reachable=true`, `reached`/`finished=false` throughout. The Euclidean
figure holds even on a **reachable-clamped** arm — off-mesh T=(2.5,0,5)
gives `reachable=true` with `final=(2.5,0,4)` yet `distance=4.924429`
= euclid(raw T), not 4.031129 = euclid(final): the referent is the
authored target under all postprocessing (12/12 arms, 4 geometries —
critic). `get_final_position` is itself postprocessing-invariant (path
endpoint = clamped target, structurally exempt); only `next` and the
intermediate path array/length move.
>
Discrimination map for future arms: `next` separates {funnel} from
{edge, none} but cannot separate edge from none on this corridor —
use `path[2]` position or `pathlen` (gap 0.157597 ≈ 39× tol). A
single-polygon control is postprocessing-invisible (byte-identical
rows) — only multi-portal geometry discriminates.
>
Companion facts (scout/scribe, measured): the `PathPostProcessing`
enum lives on `NavigationPathQueryParameters3D` —
`NavigationAgent3D.PATH_POSTPROCESSING_*` is a parse error (the class
carries no enums). `agent.path_postprocessing` = plain int property,
default 0. Setting the flag does **not** requery a cached path — set
before `target_position`, or re-set the target. `map_get_path` takes
≤5 args (no params arg); `NavigationServer3D.query_path(qp, qr)` is
synchronous, fills `NavigationPathQueryResult3D`, and returned
point-identical paths to the agent under all three values.
`get_current_navigation_path()` read before the first
`get_next_path_position()` returns empty (measured `npts_pre=0`, all
arms) — query `next` first. `simplify_path` collapses the bend witness
at eps≥~1.0.
>
Fixture: `navagent3d_detour.gd` arms `--post-edgecentered` /
`--post-none` (CASES `navagent3d_detour_post_*`, exit 0, sha `5b873cd0…`,
runner `b4b31499…`). Each arm classifies distance (euclidean /
path_sum / bounded-unknown), fails exit 1 with `invariance falsified`
on a changed distance, and pins `path.size()==4` + `next=(2,0,0.5)` +
per-arm pathlen so a flag that did not take effect cannot pass.
Mutation evidence (simplifier): setter-swap, setter-deletion,
constant-swap and `distance:=pathlen` mutants all exit 1 on measured
diagnostics. Battery 90/90 + 4 probes, `seeds_unchanged=true`;
prior 88 rows byte-identical vs frozen baseline.
>
Receipts: `corpus/live/r71-author/runs/20261013T233731295600Z/`
(90/90), `corpus/live/r71-baseline/runs/20261013T233444776454Z/`
(frozen 88/88), `corpus/live/r71-scribe/runs/20261013T234701309638844Z/`
(independent agent+server sweep, 5-arm fixture replay), seat reports `reports/round-71/r71-*.md` incl. `r71-verifier.md` (AGREE all claims) + `r71-adjudicator.md`.
>
## Not established
>
Non-default `path_metadata_flags`; moving agent / mid-path retarget /
repath windows under postprocessing; `simplify_path` mapping;
`path_max_distance`, `path_desired_distance`, `path_return_max_*`,
`path_search_max_*`, region filter RID arrays, links, multi-region
maps; whether `final` can ever move under postprocessing; reach-gate
behavior under blocking geometry + raised `target_desired_distance`;
other engine builds, baked region meshes, avoidance, rendering.