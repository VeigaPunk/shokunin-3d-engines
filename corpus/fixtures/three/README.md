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
