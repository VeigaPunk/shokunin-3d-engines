# Renewing camera samples

Hachisuka, Ogaki and Jensen’s [Progressive Photon Mapping](https://cs.uwaterloo.ca/~thachisu/ppm.pdf), 2008, §§3–4 and 6, refines estimates at fixed hit points without storing every photon. Formal convergence analysis remains unfinished in this paper.

Hachisuka and Jensen’s [Stochastic Progressive Photon Mapping](https://cs.uwaterloo.ca/~thachisu/sppm.pdf), 2009, §§3 and 6, renews hit points and shares regional statistics to address distributed effects. More photons and more camera samples therefore address different sampling needs. The formulation concerns surfaces; a volume extension is not established. Nonadaptive photon sampling and shared regional parameter assumptions matter.

These are author manuscripts associated with SIGGRAPH Asia; equivalence to final proceedings bytes is unverified. The shared lineage is refinement, not independent validation. Unrestricted reuse or training permission is not established.

Optional exercises omitted; originals retained.
