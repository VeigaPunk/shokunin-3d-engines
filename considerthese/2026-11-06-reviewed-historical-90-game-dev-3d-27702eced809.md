# 3D: fracture with and without permanent deformation

[O'Brien and Hodgins, 1999](https://graphics.stanford.edu/courses/cs448-01-spring/papers/obrien.pdf) models brittle fracture with local remeshing to preserve fracture orientation. Mesh resolution and timestep constrain crack propagation and can introduce artifacts.

[O'Brien, Bargteil and Hodgins, 2002](https://jamesobrien.com/papers/Obrien-GMA-2002-08/Obrien-GMA-2002-08.pdf) directly extends that method with plastic strain. Permanent deformation changes energy dissipation and fracture behavior; ductility is not simply a larger toughness setting. The instantaneous plastic-update assumption excludes creep and relaxation; the work targets short failure events rather than complete long-term material behavior.

The earlier model remains useful for brittle behavior. The extension broadens the modeled material response but does not certify an interactive destruction system or prescribe which intermediate object a game should show.

Selected retained method and limitation passages only; formula extraction is imperfect, no derivation or implementation audit. Both copies carry conditional ACM permissions. Original commentary and links only; no figures, equations or code redistributed.

Optional exercises omitted; originals retained.
