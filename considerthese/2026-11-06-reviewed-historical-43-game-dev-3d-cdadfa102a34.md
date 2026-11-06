# Triangle boundaries need more than speed

[Möller's author analysis](https://fileadmin.cs.lth.se/cs/Personal/Tomas_Akenine-Moller/raytri/), updated June2000, compares computation ordering on three processors. Division placement and hit proportion change the winner. This is historical workload evidence, not the unavailable original journal body or current hardware advice.

[Woop, Benthin and Wald](https://jcgt.org/published/0002/01/05/paper.pdf), published June2013, instead address shared boundaries with a ray-dependent transformation and conservative edge tests. Zero edge results trigger double precision. The mesh excludes T-vertices; coplanar and degenerate cases receive miss treatment. Transformed consistency is not exact world-space intersection: traversal bounds need conservative enlargement too.

Separate an optimization's timing claim from a selection tool's boundary behavior. Neither reading verifies this engine's query implementation. No rendering, implementation, benchmark or proof audit performed.

The later copy records a July2013 bibliography correction and CC BY-ND3.0 terms, not unrestricted adaptation. No open reuse grant established for the earlier analysis. Original commentary and links only; no source, code or figures redistributed.

Optional exercises omitted; originals retained.
