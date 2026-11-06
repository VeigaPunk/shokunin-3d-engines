# 3D: direct evaluation does not redesign the surface

[Catmull and Clark](https://people.eecs.berkeley.edu/~sequin/CS284/PAPERS/CatmullClark_SDSurf.pdf),1978, extend recursive surface construction to irregular connectivity. Their paper leaves continuity at extraordinary points unproved; pictures are not that proof.

[Stam](https://www.dgp.toronto.edu/public_user/stam/reality/Research/pdf/sig98.pdf) evaluates the limit surface using eigenbasis functions rather than repeated subdivision. Mesh updates require renewed projection. The described implementation uses finite precision and special handling near zero parameters.

This changes evaluation, not the artistic suitability of the shape. Recursive construction remains useful for understanding the surface being evaluated; direct evaluation does not certify a badge's placement, shading or game-engine delivery.

The original record identifies the manuscript as1998 through its project page; that attribution was not freshly refreshed. Selected abstract and implementation prose, plus the earlier first and final scan pages, were read. No geometry, renderer or proof executed.

The earlier scan bears IPC Business Press copyright; no open manuscript reuse grant established for either artifact. Original commentary only.

Optional exercises omitted; originals retained.
