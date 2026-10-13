# Engine census — maintained by the lane

Standing host reality (mint, 2026-10-13). Update this file whenever a
tooling probe lands; every claim cites its probe.

| tooling | installed | executable headless | evidence | notes |
|---|---|---|---|---|
| Godot 4.7.2 | yes (`/usr/bin/godot`) | yes | r1 battery receipts under corpus/live/runs/ | primary executable runtime at mint; 2D-agnostic patterns inherited from games-engine-mechanics |
| Unity Editor | no | no | census at mint; r19 `corpus/artifacts/unity-r19/` static self-authored `.unity` sample and non-author review | no Linux editor installed; r19 local static reference checks do not prove Unity import, execution, or UnityYAML completeness |
| Unreal Engine | no | no | census at mint | not installed; format-level/static only until installed |
| three.js 0.186.1 | lane-local npm dependency pinned in `corpus/fixtures/three/package-lock.json` (Node v26.11.1) | partial — `Object3D` scene graph/math under Node; no GL context | `node corpus/fixtures/three/run_cases.mjs` → 3/3 and named non-author r6 review (work commit in report) | `require.resolve('three')` failed from repo root before scoped install; no rendering, pixels or browser claim |

Rules: an engine row may move to "executable headless" only with a saved
receipt of a bounded fixture run and a non-author verifier, like any
other axis-move. Absence of an engine never authorizes runtime claims;
static/format evidence is labeled as such.
