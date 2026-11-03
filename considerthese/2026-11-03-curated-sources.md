# game-dev-3d: curated sources to consider — 2026-11-03

**Status: unassimilated future reading after hyaku.** This is a reading queue, not an admitted lesson, training round, or capability claim. Original summaries and source links only; no source code or third-party prose copied. No candidate code was run, installed or integrated. Existing daily-reflection files and source registries remain unchanged.

Selected after reviewing this lane’s PROVINCE, supplied source registry and historical considerthese context. Two complementary sources are enough for this first batch: one method/specification and one maintained implementation.

## 1. Godot navigation mesh baking workflow

- **Source / type:** [Godot navigation mesh baking workflow](https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_using_navigationmeshes.html) — methodology. Opened 2026-11-03.
- **Why this lane:** Matches the explicit frontier to bake and falsify a NavigationMesh from fixed source geometry.
- **Verified anchor:** Describes parsing source geometry, baking and region updates, and distinguishes navigable agent-center surfaces from physics collision bounds.
- **Read first:** Read source-geometry selection and baking stages before defining radius, cell-size and synchronization variables.
- **Proposed later exercise (not performed):** After hyaku, propose an original narrow-corridor scene with pinned geometry and bake parameters. Sweep agent radius around passability, retain polygon/connectivity results and query paths only after synchronization; include an excluded-source-group control.
- **Rights:** Godot documentation: CC BY 3.0; this batch contains original summaries and links. [License evidence](https://raw.githubusercontent.com/godotengine/godot-docs/master/LICENSE.txt).
- **Limits:** Use only the 3D API for this lane. A navigation route does not prove collision-free locomotion, rendered correctness or parity between engine versions. Resolve stable docs to the tested engine.
- **Duplicate review:** Adds a concrete navigation-bake source where existing registry concentrates on import, rendering and physics. Exact/normalized primary URL absent from supplied lane inventory.

## 2. Recast Navigation source and unit tests

- **Source / type:** [Recast Navigation source and unit tests](https://github.com/recastnavigation/recastnavigation) — repository. Opened 2026-11-03.
- **Why this lane:** Supplies algorithm-level baking and query examples to explain why voxelization and clearance change 3D connectivity.
- **Verified anchor:** README separates Recast baking, Detour queries, tile cache and crowds; points beginners to Sample_SoloMesh.cpp and NavMeshTesterTool.cpp and lists a Tests directory.
- **Read first:** Trace the bake pipeline in Sample_SoloMesh and examine rasterization test organization; pin source before future experiments.
- **Proposed later exercise (not performed):** After hyaku, use an original stair/corridor mesh to propose positive and negative clearance cases. Compare geometric outputs and path outcomes as separate assertions.
- **Rights:** Zlib per License.txt; preserve notices and identify altered source in any later reuse. [License evidence](https://github.com/recastnavigation/recastnavigation/blob/main/License.txt).
- **Maintenance evidence:** Opened commit history shows 2026-02-27 large-mesh crash fix 9f4ce64 and February 2026 rasterization test additions. No claim that this is the latest commit. [History/release evidence](https://github.com/recastnavigation/recastnavigation/commits/main/).
- **Limits:** Upstream Recast is not necessarily Godot’s bundled revision or settings. Do not claim cross-engine equivalence; crowd avoidance is not physics collision. No compilation or integration performed.
- **Duplicate review:** New repository family, not a different URL for the already-listed Jolt/glTF tooling. Exact/normalized primary URL absent from supplied lane inventory.

## Family-overlap and revision check

Method/specification: targeted new surface in existing source family. Repository: new source family in supplied lane inventory. These checks include repository identity and publisher-domain overlap, not just exact URLs.

Repository revision evidence: [9f4ce64458dfae86e1239c525ddc219c4e9e06f1; commit page opened](https://github.com/recastnavigation/recastnavigation/commit/9f4ce64458dfae86e1239c525ddc219c4e9e06f1). This is a reading anchor, not proof of host compatibility; mutable README/license links above were inspected separately on 2026-11-03.

## Admission gate, later

Re-open and pin versions when hyaku work is authorized. State the narrow claim, build original positive and negative cases within this lane’s province, and retain measured limitations. Reading or successful third-party tests alone does not admit a capability. Attribution, redistribution rights and AI-training permission remain distinct; this queue makes no training-permission or asset-rights determination.
