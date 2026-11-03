# game-dev-3d: curated source to consider, batch 2 — 2026-11-03

**Status: unassimilated candidate for post-hyaku review.** Reading queue only, not training, admission or capability evidence. No candidate code was installed, run or integrated. This note contains original summaries; no third-party code or prose is reproduced.

## meshoptimizer: boundary-preserving simplification and error units

- **Primary source:** [meshoptimizer: boundary-preserving simplification and error units](https://github.com/zeux/meshoptimizer).
- **Verified reading anchor:** [9e1f07b159d3cb777f1c67ed31fc11fd117986f4](https://github.com/zeux/meshoptimizer/blob/9e1f07b159d3cb777f1c67ed31fc11fd117986f4/README.md). [Release v1.3](https://github.com/zeux/meshoptimizer/releases/tag/v1.3) published 2026-09-25T15:36:13Z; tag resolved through the GitHub commits API, not inferred from neighboring CI activity. Opened 2026-11-03.
- **Source summary:** The simplifier exposes border locking, absolute versus relative error, and attribute-aware controls. Locks may prevent reaching the requested index count. Material subsets need explicit boundary handling; permissive mode can cross attribute discontinuities. Its efficiency analyzers are estimates, not target-GPU timings.
- **Read first:** README.md: Simplification, Attribute-aware simplification, Advanced simplification, and Efficiency analyzers; specifically meshopt_SimplifyLockBorder, meshopt_SimplifyErrorAbsolute and material-boundary discussion.
- **Why useful here:** Adds an inspectable geometry-reduction contract to existing glTF import/validation and first-batch navigation baking, without treating a smaller artifact as automatically valid.
- **License:** [MIT](https://github.com/zeux/meshoptimizer/blob/9e1f07b159d3cb777f1c67ed31fc11fd117986f4/LICENSE.md). Retain applicable copyright/license notices on later reuse; inspect dependencies and individual asset terms separately. Attribution, redistribution and AI-training permission remain separate; no training or input-asset rights determination is made.
- **Hard limits:** Do not infer rendered similarity, animation integrity, collision equivalence or GPU speed from triangle counts. This queue selects simplification, not the release's experimental voxel remesher. No asset rights clearance, engine mutation or production integration.

## Original lane-specific evaluation proposal, not performed

**Future question:** Which boundary and error checks are needed before accepting a simplified 3D asset as structurally equivalent for its declared use?

After hyaku and separate authorization, propose an original two-material strip with a shared border, duplicated UV seam and a small isolated feature. Compare locked/unlocked boundaries under one fixed error budget and report achieved counts, units, retained components and boundary correspondence separately. Include a permissive-mode counterexample. Require independent geometric checks, and defer any rendering/performance conclusion until a separately declared real-render measurement.

## Duplicate and selection review

New zeux/meshoptimizer family across supplied context. Existing glTF-Transform/Khronos sources are adjacent consumers/formats, not this implementation. First-batch Recast addresses navigation connectivity rather than visual-mesh reduction.

Reviewed existing-urls.json and all four assigned lane contexts, including their published first-batch notes; candidate names/paths were also searched across all supplied lane contexts. This is source-inventory dedup, not a claim that every private corpus file was read. One focused candidate was retained; no broader framework adoption is implied. Re-open the pinned source and define an authorized, lane-local admission gate before future execution.

