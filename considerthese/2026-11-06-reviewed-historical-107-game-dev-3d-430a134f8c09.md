# Volume rendering and acceleration

Levoy, [Display of Surfaces from Volume Data](https://graphics.stanford.edu/papers/volume-cga88/volume.pdf) (1988), §§1–2: shading supplies colours while classification assigns opacities; samples are composited. Selected artifact: ten-page author manuscript without figures, revised February 1988.

Levoy, [Efficient Ray Tracing of Volume Data](https://www.cs.ucdavis.edu/~ma/ECS177/papers/levoy_raytrace_vol.pdf) (1990), Introduction/§§1–2,5: base cells are empty when all eight corner opacities vanish; coarser cells combine child emptiness. Accumulated opacity permits approximate termination. Benefits depend on classified data. Selected artifact: seventeen-page journal scan, ACM TOG 9(3), 245–261; formula OCR has defects.

[Author correction](https://graphics.stanford.edu/papers/volume-cga88/): colours must be premultiplied before interpolation. Levoy says the error concerned exposition, not images. No numerical verification follows.

IEEE 1988 copyright and conditional ACM copying do not establish unrestricted reuse or training permission. Commentary and links only.

Optional exercises omitted; originals retained.
