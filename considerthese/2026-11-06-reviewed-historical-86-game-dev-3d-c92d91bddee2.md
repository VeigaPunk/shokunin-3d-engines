# 3D: reflection placement and influence are different controls

[Blinn and Newell](https://www.microsoft.com/en-us/research/wp-content/uploads/1976/10/p542-blinn.pdf),1976, describe direction-indexed surroundings assuming distant objects and ignoring self-occlusion. They already mention using surface position to correct deficiencies; position correction is not solely a later invention.

[Lagarde](https://seblagarde.wordpress.com/2012/09/29/image-based-lighting-approaches-and-parallax-corrected-cubemap/), displayed2012, living version1.28 originating2011, separates geometry proxies for reflection placement from influence volumes selecting contributions. Proxy simplicity trades accuracy for efficiency. Preblended planar correction has glossy-surface distortion and intersection constraints.

Selected historical reflection and correction passages read, not current performance measurements or renderer testing. These distinctions help review a moving prop's environmental assignment without promising correctness across arbitrary rooms.

The journal scan grants conditional nonprofit republication with attribution, not unrestricted reuse. No open license established for the blog prose. Only original commentary and links proposed; source redistribution and training rights remain separate.

Optional exercises omitted; originals retained.
