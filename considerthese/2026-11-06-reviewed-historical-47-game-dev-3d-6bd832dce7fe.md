# Terrain detail requires both transition and residency

[De Boer](https://flipcode.com/archives/article_geomipmaps.pdf), October 2000, selects terrain block resolution using height error and distance thresholds, changing edge connectivity between resolutions. Heightfields exclude overhangs. Morphing and progressive streaming are proposed extensions, explicitly absent from the reported implementation.

[Losasso and Hoppe](https://hhoppe.com/geomclipmap.pdf) reorganize terrain into nested viewer-centered regular grids with incremental updates and spatial transitions. If updates exceed budget, active regions shrink to available data. Regularity sacrifices local adaptivity; tall narrow features can appear late. This is a structural tradeoff, not universal improvement or proof of direct influence.

The author record identifies the work as 2004; the served copy says draft, do not distribute, with an April 2013 timestamp. It is not verified final proceedings bytes. Conditional ACM copying does not establish an open license; earlier general reuse remains uncleared.

Separate missing detail from an open seam before choosing a method. Neither historical demonstration establishes current engine performance or loading behavior. Original commentary only; no source, assets, execution or proof verification.

Optional exercises omitted; originals retained.
