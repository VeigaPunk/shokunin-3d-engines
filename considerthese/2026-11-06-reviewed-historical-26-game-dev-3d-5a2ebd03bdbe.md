# Reused lighting needs an estimator contract

[Veach/Guibas](https://www.cs.jhu.edu/~misha/ReadingSeminar/Papers/Veach95.pdf) combines sampling techniques using weights summing to unity. Densities require a common measure; sample allocations are fixed beforehand. Balance weights account for allocations and densities, not duplicated contributions. Other techniques' densities cost evaluation.

[ReSTIR](https://cs.dartmouth.edu/~wjarosz/publications/bitterli20spatiotemporal-small.pdf) stores selected candidates and weighting statistics. Reuse across pixels needs reweighting; differing support can bias results. Unbiased reuse adds shadow rays when reusing visibility. Its image buffers constrain the method to primary camera hits, not arbitrary global illumination.

[GRIS](https://graphics.cs.utah.edu/research/projects/gris/sig22_GRIS.pdf) treats correlated samples and domain shifts. Successful shifts need inverses; convergence also needs support, weight and correlation conditions. Footnote11 calls the temporal-capping proof difficult, not established unconditionally. Independent spatial-only frames serve a different averaging objective.

Separate estimator guarantees, visible quality and measured local cost. No renderer, benchmark or proof validation performed. Publication chronology does not prove superiority. ACM copying terms are conditional; Veach reuse remains uncleared. Original commentary only. Optional exercises omitted; originals retained.
