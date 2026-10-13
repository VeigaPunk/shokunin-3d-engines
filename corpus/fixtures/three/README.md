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

This separate three-case battery uses three.js `PerspectiveCamera`,
`Vector3.project`, and `Frustum.containsPoint` under Node. With near=1,
far=10, vertical FOV=90°, aspect=4/3 and camera at the origin, (2,1,-4)
is inside; (6,3,-12) has the same normalized x=0.375, y=0.25
(corresponding mathematically to 550,225 in an 800×600 viewport) but is
beyond the far plane. The deliberate far=20 flag must fail on the live
frustum result before its depth-projection check. The runner checks exact
exit, stdout/stderr, no signal, five-second process bound and seed digests.
This is projection/frustum math only: no `WebGLRenderer`, GL context,
rendered pixels, browser, or claim about camera behavior in another engine.
