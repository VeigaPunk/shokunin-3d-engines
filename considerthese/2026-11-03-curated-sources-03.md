# game-dev-3d: source candidate, batch 3 — 2026-11-03

**Unassimilated, post-hyaku reading queue.** No installation, execution, training or capability admission. Original summary only; no source code reproduced.

## xatlas: UV seams, vertex remapping and texel units

**Question:** Can a lightmap-UV transformation preserve source attributes when chart seams duplicate vertices, without confusing texel coordinates with normalized UVs?

**Primary source and pin:** [xatlas](https://github.com/jpcy/xatlas) at [f700c7790aaa030e794b52ba7791a05c085faf0c](https://github.com/jpcy/xatlas/commit/f700c7790aaa030e794b52ba7791a05c085faf0c), dated 2022-07-25T23:06:01Z. Opened 2026-11-03. This older upstream revision is a deliberate reading anchor, not evidence of active maintenance.

**Source summary:** Atlas generation can increase vertex count through seams while retaining index count. Output vertices carry an input-vertex reference; UV values are in atlas texel units. Chart computation and packing are separate stages. Packing options expose padding, resolution and texels-per-unit, whose combinations change atlas allocation.

**Reading path:** [README](https://github.com/jpcy/xatlas/blob/f700c7790aaa030e794b52ba7791a05c085faf0c/README.md), simple versus tools/editor APIs → [xatlas.h](https://github.com/jpcy/xatlas/blob/f700c7790aaa030e794b52ba7791a05c085faf0c/source/xatlas/xatlas.h), Vertex/Atlas → MeshDecl → PackOptions. [MIT license](https://github.com/jpcy/xatlas/blob/f700c7790aaa030e794b52ba7791a05c085faf0c/LICENSE); preserve notices, including relevant inherited notices. Example models and dependencies need separate rights review; training permission is not inferred.

**Original later exercise, not performed:** Propose a small original mesh with differently marked source vertices and a deliberate hard seam. Before execution, define expected attribute reconstruction through the reference mapping, index-range validity, atlas assignment and normalized-coordinate bounds. Compare correct reconstruction against a negative control that copies attributes by output index. Sweep padding and resolution independently, preserving units in every receipt. Record omitted or unassigned faces explicitly rather than silently dropping them. A useful test must expose the incorrect mapping even when the mesh remains superficially recognizable.

**Novelty and limits:** Alias searches for xatlas/thekla_atlas across supplied contexts and remote source inventories found no prior candidate. This adds UV parameterization and lightmap preparation, distinct from navigation baking, glTF validation and meshoptimizer simplification. Mathematical checks do not establish baked-light quality, filtering safety at every mip level, engine import behavior or production readiness. No new rendering toolchain is proposed for automatic installation.
