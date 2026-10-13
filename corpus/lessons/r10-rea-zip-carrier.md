# Round 10 — REA ZIP inventory of authored 3D artifact

Run from repo root:

```sh
npx -y rea-agents@6.4.0 inspect-artifact .shokunin/game-dev-3d/corpus/artifacts/zip-r10/triangle-carrier.zip --format json --full-output
npx -y rea-agents@6.4.0 inspect-artifact .shokunin/game-dev-3d/corpus/artifacts/zip-r10/triangle-invalid-carrier.zip --format json --full-output
python3 .shokunin/game-dev-3d/corpus/artifacts/zip-r10/verify_carrier.py
python3 .shokunin/game-dev-3d/corpus/artifacts/glb-r9/validate_glb.py
```

Saved REA positive inspection `ev_3f68dd303b85c61419e0bc6bb08015aa9dfcf906b3e9b26dfcceea22b109666d`, inventory `ev_289ef677b404333d1dde092987d65529261883c47fd81f40050402c7e4df0358`; negative inspection `ev_b38a3bc0d057ebaed618965112273a3303e3c544ae0e033645a20116dc03ba4c`, inventory `ev_d5d6b30d2aaf5dbc34efddf8f43bff8add3515043e684db0ec48759f2d87be2d`. Full retained JSON `corpus/artifacts/zip-r10/rea-{positive,negative}.json`; named non-author reproduction `corpus/lessons/r10-zip-review.md`.

**Observation:** REA inventories ZIP central-directory occurrences `triangle.glb` (generic `file`) and `truth.json`, with verified member hashes. Positive member SHA `78f51afa...65fbc`, negative `dad26ba...144b`. REA accepts both ZIPs. **Local inference/check:** positive bytes match authored truth; negative member differs at GLB byte 8 only (declared length 531 vs actual 532) and local validator rejects it. **Unknown:** whether GLB imports/renders in any engine. REA does not parse GLB geometry; ZIP inventory omits bytes after central directory. Never treat local structural rejection as a REA rejection.
