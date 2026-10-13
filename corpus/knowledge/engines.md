# Engine census — maintained by the lane

Standing host reality (mint, 2026-10-13). Update this file whenever a
tooling probe lands; every claim cites its probe.

| tooling | installed | executable headless | evidence | notes |
|---|---|---|---|---|
| Godot 4.7.2 | yes (`/usr/bin/godot`) | yes | r1 battery receipts under corpus/live/runs/ | primary executable runtime at mint; 2D-agnostic patterns inherited from games-engine-mechanics |
| Unity Editor | no | no | census at mint | no Linux editor installed; any Unity work until installation is format-level/static (scene YAML, asset containers) |
| Unreal Engine | no | no | census at mint | not installed; format-level/static only until installed |
| three.js | runtime available (node via mise) | partial — scene graph/math under node; no GL context | census at mint | rendering claims require a GL context and are unproven headless |

Rules: an engine row may move to "executable headless" only with a saved
receipt of a bounded fixture run and a non-author verifier, like any
other axis-move. Absence of an engine never authorizes runtime claims;
static/format evidence is labeled as such.
