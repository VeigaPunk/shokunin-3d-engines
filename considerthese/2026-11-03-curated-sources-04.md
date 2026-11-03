# game-dev-3d: curated source to consider, batch 4 — 2026-11-03

**Status: unassimilated post-hyaku reading.** No training, installation, integration or candidate execution.

## MikkTSpace: tangent frames are per-corner data

**Source and revision:** [MikkTSpace header](https://github.com/mmikk/MikkTSpace/blob/3e895b49d05ea07e4c2133156cfa94369e19e409/mikktspace.h), header version 1.0 at [commit 3e895b49](https://github.com/mmikk/MikkTSpace/commit/3e895b49d05ea07e4c2133156cfa94369e19e409), dated 2020-03-25 at 19:05:59 UTC. Opened 2026-11-03. Its age is explicit; no recent-maintenance claim is made.

**Source summary:** The interface accepts triangle/quad positions, normals and UVs, returning unindexed tangent-space results. Its basic callback supplies a tangent and orientation sign. The header warns against averaging or overwriting these outputs through an existing index list. Vertex-level order independence does not remove dependence on a quad's triangulation during interpolation. Normal-map sampling and rendering must use matching transformations and triangulation.

**Read first:** mikktspace.h: version/design comment; SMikkTSpaceInterface input callbacks; m_setTSpaceBasic and m_setTSpace warnings; final normal-map sampler and quad-triangulation notes.

**Domain gap and novelty:** meshoptimizer addresses simplification, xatlas UV creation and remapping, and glTF the interchange container. This source adds the tangent-frame contract needed after those transformations. MikkTSpace/mmikk/mikktspace aliases were absent from the reviewed inventories; shared mesh subject matter does not duplicate the earlier algorithms.

**License:** The [header's embedded zlib-style notice](https://github.com/mmikk/MikkTSpace/blob/3e895b49d05ea07e4c2133156cfa94369e19e409/mikktspace.h) permits commercial use, modification and redistribution with origin, altered-source and notice restrictions. Source licensing does not clear meshes, normal maps or AI-training inputs.

**Original future question, not performed:** Can two corners sharing position but crossing a mirrored UV seam retain distinct orientation signs through export? After hyaku, propose an original mirrored two-triangle fixture and a quad with two diagonal choices. Inspect per-corner records and a deliberately invalid position-only weld. Require any later test to separate numeric tangent agreement from rendered normal-map agreement.

**Limits:** Reading the reference does not prove a particular engine uses this revision. Headless tangent checks cannot certify visible shading, material conventions or renderer parity.

