# game-dev-3d — fixture corpus

Reference corpus of the **game-dev-3d** shokunin lane (campaign prymeagnt,
minted 2026-10-13): a headless **3D** fixture battery — movement
and collision, spatial queries, camera projection, scene structure,
transform composition, input-driven 3D mechanics — with discriminating
negative controls, plus the inherited games-engine-mechanics suite, an
REA static-inspection reference, and an engine census. Engine-neutral by
operator directive: Godot, Unity, Unreal Engine, three.js, and any
further 3D rendering tooling the lane discovers and validates on its
shonen path.

Purposes: (1) reference guide — every fixture carries its exact reproduction
command and expected exit signature; (2) discovery corpus for new 3D
mechanics moves; (3) inspiration source — failed fits and rejected probes
are preserved as negative results under lessons/ and live/runs/.

Upstream: https://github.com/VeigaPunk/prymeagnt-game-dev-3d (branch main
carries this corpus; craft/* branches carry round-by-round history). Local
execution references it with: git fetch game-dev-3d main

Layout:
- fixtures/ — the round-1 3D battery seeds (read-only) plus run_battery.py,
  which copies seeds to an ignored scratch run before execution.
- predecessor/ — games-engine-mechanics r15 corpus (2D-agnostic headless
  patterns: synthetic input, physics overlap, causal chains, scene
  transitions, discriminating negatives), inherited read-only.
- knowledge/ — seed provenance, the REA tooling reference, and the
  engine census (Godot/Unity/Unreal/three.js execution reality).
- lessons/ — round lesson files with cited receipts.
- live/runs/ — ignored, disposable execution receipts.
