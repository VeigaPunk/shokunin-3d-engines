# three.js Object3D headless math fixture (round 6)

From the repository root:

```sh
npm ci --prefix .shokunin/game-dev-3d/corpus/fixtures/three
node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs
node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs --receipt .shokunin/game-dev-3d/corpus/live/three-r6.json
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py
```

The three-case runner uses the actual pinned three.js 0.186.1 `Object3D` API. A parent translated `(2,0,0)` and rotated `Y=90°` owns a child translated `(0,0,-3)` and rotated `X=90°`. World origin must be the hand-authored `(-1,0,0)`; parent multiplication must equal `child.matrixWorld`. The negative arm proves the parent/child setup is still intact then rejects reversed composition (exit 2). A scratch-like `--mutate-offset` run changes child Z to -4 while leaving the literal expectation fixed; it must exit 1 with a specific diagnostic. The runner enforces exit/stream/line signatures and unchanged seed SHA-256 values. No WebGL renderer is created, no pixels read, and no Unity/Unreal runtime inference is made. `node_modules/` is ignored and `npm ci` is lane-local.
