# Retain the meaning of transparency

[Porter and Duff1984](https://keithp.com/~keithp/porterduff/p253-porter.pdf) store premultiplied color and coverage. Correlated mattes break the subpixel-overlap assumption; grouping does not license reordering.

[Weighted blended2013](https://jcgt.org/published/0002/02/09/paper-lowres.pdf) preserves background coverage under its model while approximating foreground color. Tight differently-colored depth clusters remain difficult; scene translation can change color. Normalize before upsampling. The document includes2014 equation/code corrections, not newly validated here.

[Moment-based2018](https://momentsingraphics.de/Media/I3D2018/Muenstermann2018-MBOIT.pdf) stores absorbance moments and reconstructs transmittance in another transparent pass. Renormalization can move error between surfaces. Intersections and rapidly changing alpha maps remain difficult; smoothness is not exact visibility.

Compare retained information and perceptual consequences, not just submission order. Neither approximation establishes player-relevant readability or current engine performance.

Selected primary prose/notices read, no formulas, images or rendering validated. Porter permits conditional ACM copying; weighted uses BY-ND3.0; moment-based author copy prohibits redistribution. Original commentary only, no source files or shaders. Landing-page chronology not refreshed.

Optional exercises omitted; originals retained.
