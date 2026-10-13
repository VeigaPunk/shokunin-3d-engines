# three.js Object3D headless math fixture (round 6)

From the repository root:

```sh
npm ci --prefix .shokunin/game-dev-3d/corpus/fixtures/three
node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs
node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs --receipt .shokunin/game-dev-3d/corpus/live/three-r6.json
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py
```

The three-case runner uses the actual pinned three.js 0.186.1 `Object3D` API. A parent translated `(2,0,0)` and rotated `Y=90°` owns a child translated `(0,0,-3)` and rotated `X=90°`. World origin must be the hand-authored `(-1,0,0)`; parent multiplication must equal `child.matrixWorld`. The negative arm proves the parent/child setup is still intact then rejects reversed composition (exit 2). A scratch-like `--mutate-offset` run changes child Z to -4 while leaving the literal expectation fixed; it must exit 1 with a specific diagnostic. The runner enforces exit/stream/line signatures and unchanged seed SHA-256 values. No WebGL renderer is created, no pixels read, and no Unity/Unreal runtime inference is made. `node_modules/` is ignored and `npm ci` is lane-local.

## Perspective camera and frustum math (round 58)

From the repository root after the same lane-local `npm ci`:

```sh
node .shokunin/game-dev-3d/corpus/fixtures/three/run_camera_cases.mjs
node .shokunin/game-dev-3d/corpus/fixtures/three/run_camera_cases.mjs --receipt .shokunin/game-dev-3d/corpus/live/three-r58.json
```

This separate camera battery uses three.js `PerspectiveCamera`,
`Vector3.project`, and `Frustum.containsPoint` under Node. With near=1,
far=10, vertical FOV=90°, aspect=4/3 and camera at the origin, (2,1,-4)
is inside; (6,3,-12) has the same normalized x=0.375, y=0.25
(corresponding mathematically to 550,225 in an 800×600 viewport) but is
beyond the far plane. Round 59 adds (0.25,0.125,-0.5) at positive
forward depth 0.5: it has the same normalized x/y but lies before near=1.
The new near-negative checks the live inside and far controls; near=0.1
must fail on its measured frustum result before the fixed-depth check.
The deliberate far=20 flag must likewise fail on the live far-frustum
result before its depth-projection check. The runner checks exact
exit, stdout/stderr, no signal, five-second process bound and seed digests.
This is projection/frustum math only: no `WebGLRenderer`, GL context,
rendered pixels, browser, or claim about camera behavior in another engine.

## Orthographic depth-invariant projection/frustum (round 60)

```sh
node .shokunin/game-dev-3d/corpus/fixtures/three/run_ortho_cases.mjs
node .shokunin/game-dev-3d/corpus/fixtures/three/run_ortho_cases.mjs --receipt .shokunin/game-dev-3d/corpus/live/three-r60.json
```

The three-case runner uses three.js `OrthographicCamera` under Node with
left/right=-4/4, top/bottom=3/-3, near/far=1/10. World points
(2,1,-4), (2,1,-8), (2,1,-12) share NDC x=0.5 and y=1/3,
mathematically (600,200) for 800×600; the first two are in the live
frustum, the last is beyond far. The negative keeps both inside controls
live; far=20 must fail on the measured last-point frustum status before
literal depth checks. This is math-only evidence, not rendered pixels,
GL, GPU culling, browser or cross-engine equivalence.

## Exact Node output bytes (round 61)

The three Node runners compare the selected stdout or stderr byte string to
`expectedLine + "\n"`, require the other stream empty, and reject an extra
blank line even after an otherwise correct PASS marker. A private copied
fixture source can prepend a `console.log` wrapper that prints one extra
empty line only after `PASS`; the old `.trim()` runners accept it, while
the revised runners fail the positive arm with the child exit still 0.
This rule covers these scripts' UTF-8 newline output, not arbitrary engine
logging or portable terminal formatting.

## Orthographic near-plane exclusion (round 62)

`node .shokunin/game-dev-3d/corpus/fixtures/three/run_ortho_cases.mjs`
now includes (2,1,-0.5) at positive forward depth 0.5, before near=1.
It shares asserted NDC x=0.5/y=1/3 with depths 4,8,12 but has live
`Frustum.containsPoint=false`; the negative retains both in-frustum
controls and the far-outside control. Near=0.1 must fail on the measured
near-point inclusion before fixed setting/depth checks. This is a bounded
Node math result, not a rendered pixel or general precision threshold.

## Translated triangle Raycaster (round 63)

```sh
node .shokunin/game-dev-3d/corpus/fixtures/three/run_ray_cases.mjs
node .shokunin/game-dev-3d/corpus/fixtures/three/run_ray_cases.mjs --receipt .shokunin/game-dev-3d/corpus/live/three-r63.json
```

Real three.js `BufferGeometry` triangle vertices (-1,-1,0),(1,-1,0),
(0,1,0) live in a `Mesh` translated to (2,0,-5). A ray from (2,0,0)
down -Z must hit its interior at hand-derived (2,0,-5), distance 5;
parallel ray from x=5 misses while the first hit remains live. A runtime
mesh x-offset 2→3 must make the original interior ray lose its hit and
exit 1 on observed hit count. The exact-stream runner hashes its four
seeds. No renderer, GL, pixels, browser or arbitrary-mesh guarantee.

## Raycast front/back material side (round 64)

`node .shokunin/game-dev-3d/corpus/fixtures/three/run_ray_cases.mjs`
adds a `FrontSide` negative using the same translated triangle. Its winding
normal is +Z; the ray from (2,0,0) down -Z hits at z=-5, while the
reverse ray from (2,0,-10) up +Z reaches the same interior point but
has zero intersections under `FrontSide`. `--backface --double-side`
changes only material side and must fail on measured reverse hit count=1,
with the forward hit still live. This is CPU-side Raycaster material-side
behavior, not rendered backface culling or all mesh winding regimes.

## Ordered Raycaster hits across two meshes (round 65)

```sh
node .shokunin/game-dev-3d/corpus/fixtures/three/run_order_cases.mjs
node .shokunin/game-dev-3d/corpus/fixtures/three/run_order_cases.mjs --receipt .shokunin/game-dev-3d/corpus/live/three-r65.json
```

Two separate translated triangle Mesh objects share a ray at x=2,y=0,
placed at depths 3 and 5. `Raycaster.intersectObjects` receives them in
reverse argument order yet must report nearest mesh first with measured
points/distances (2,0,-3)/3 and (2,0,-5)/5. Moving only the near mesh
to x=5 leaves the far hit live and yields the negative marker. Swapping
their depths must fail on measured object identity/order even though two
hits remain. This is Node CPU ray geometry, not rendered occlusion,
transparency, GPU behavior or arbitrary scene ordering.

## Raycaster near/far distance gates (round 66)

`node .shokunin/game-dev-3d/corpus/fixtures/three/run_order_cases.mjs`
now adds two controls with both original triangles intact. Ray near=4,
far=10 excludes depth3 but retains depth5; ray near=0,far=4 retains
depth3 but excludes depth5. Each checks measured object identity, point
and distance before exact negative marker. `--mutate-near-clip` changes
near4→2, yielding two measured hits and exit1 rather than a false
single-far hit. These are sampled numeric distance gates, not exact
boundary precision or rendered occlusion.

## Sampled inclusive Raycaster bounds (round 67)

`run_order_cases.mjs` also checks exact near=5 and far=3 on the
unchanged two-triangle geometry. Each boundary invocation first recasts
under default near=0/far=10 and checks both object identities, exact
points and distances in the same process, then checks the one-hit
filtered result. `--mutate-near-boundary` changes near5→5.25; actual
zero hits must exit1 with a measured diagnostic while baseline stays two.
These integer-coordinate samples are exactly representable here; no
claim extends to arbitrary floating-point boundary precision or rendering.
