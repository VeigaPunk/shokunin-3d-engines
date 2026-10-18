# Engine census — maintained by the lane

Standing host reality (mint, 2026-10-13). Update this file whenever a
tooling probe lands; every claim cites its probe.

| tooling | installed | executable headless | evidence | notes |
|---|---|---|---|---|
| Godot 4.7.2 | yes (`/usr/bin/godot`) | yes | r1 battery receipts under corpus/live/runs/ | primary executable runtime at mint; 2D-agnostic patterns inherited from games-engine-mechanics |
| Unity Editor | no | no | census at mint; r19 `corpus/artifacts/unity-r19/` static self-authored `.unity` sample and non-author review | no Linux editor installed; r19 local static reference checks do not prove Unity import, execution, or UnityYAML completeness |
| Unreal Engine | no | no | two static evidence classes, both `static-only` (0 `verified-here`; every runtime claim on this row stays `unproven-runtime`): (a) r22 self-authored `corpus/artifacts/unreal-r22/` `.uplugin` sample + non-author review; (b) r101 third-party pinned tree `corpus/knowledge/unreal-mcp/` — Epic `unreal-engine-skills-for-claude-code-plugin` @ `a6aa73ad`, MIT, 12/12 tracked files byte-identical (`sha256sum -c .manifest.d/audit-reference.sha256` → rc=0), 13 `executability/` cards (12 `static-only` / 1 `unproven-runtime` / 0 `verified-here`) | not installed; (a) and (b) are categorically different evidence classes — (a) is lane-authored, so it can only prove the lane can write a descriptor its own checker accepts, while (b) is someone else's bytes at a pinned upstream commit and carries an authority (a) structurally lacks; neither proves plugin load, UBT compilation or engine runtime; every live-editor claim in (b) is unproven by construction |
| three.js 0.186.1 | lane-local npm dependency pinned in `corpus/fixtures/three/package-lock.json` (Node v26.11.1) | partial — `Object3D` scene graph/math under Node; no GL context | `npm ci --prefix corpus/fixtures/three && node corpus/fixtures/three/run_cases.mjs` → 3/3, `seeds_unchanged=true`, exit 0, and named non-author r6 review (work commit in report) | requires the vendored lane-local `corpus/fixtures/three/node_modules/` layout: that dir is gitignored, so `node corpus/fixtures/three/run_cases.mjs` alone exits 1 on a fresh `git archive HEAD corpus/fixtures/three` tree — the `npm ci --prefix` above restores it from the committed lockfile (verified exit 0 from repo root on a clean tree); `require.resolve('three')` failed from repo root before scoped install; no rendering, pixels or browser claim |

Rules: an engine row may move to "executable headless" only with a saved
receipt of a bounded fixture run and a non-author verifier, like any
other axis-move. Absence of an engine never authorizes runtime claims;
static/format evidence is labeled as such.
