# Reachability does not guarantee a usable pose

[Aristidou and Lasenby](https://joanllobera.github.io/teaching/animation-foundations/12.02.fabrik_article.pdf),2011: FABRIK moves joint positions along lines in alternating inward and outward passes. Joint restrictions already appear in this paper; they are not a later invention.

[Aristidou, Chrysanthou and Lasenby](https://joanllobera.github.io/teaching/animation-foundations/12.03.fabrikconstraints_article.pdf),2015 online/2016 issue, extend model-specific treatments. An outer reach test can miss an inner unreachable region when one link exceeds the others combined. Strict constraints can trap iterations even when a different solution exists. The convergence argument concerns unconstrained chains with an available solution, not every constrained rig.

The earlier solver remains useful for understanding positional iteration; the later account sharpens model assumptions and failure handling. A contact target alone does not specify an acceptable pose. Neither historical demonstrations nor shared authorship establish local performance or collision safety.

Selected primary sections and notices read from teaching-mirror journal copies. Elsevier and Wiley copyright; general reuse uncleared. No solver, rendering or proof verification performed. Original commentary and links only.

Optional exercises omitted; originals retained.
