# Round 35 named non-author mesh-derived physics review

**Verdict: bounded coverage improvement; depth and calibration unchanged.** On this Godot build, one procedural triangle produces a generated concave static collider queried successfully with an **explicit two-sided collision policy**. It does **not** demonstrate collision under default shape settings. The declared proposal's “nonzero face index” was falsified: the measured face index is **0**.

## Independent replay and previous-case compatibility

From repository root, Godot `/usr/bin/godot` reports `4.7.2.stable.arch_linux.ed1daf0bf`:

```sh
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only mesh3d_trimesh_hit,mesh3d_trimesh_outside
```

Both commands exited **0**. Full replay: **49/49** seeded cases (23 ordinary, 26 negative) and **4/4** separate opt-in probes PASS, with seeds unchanged. Full receipt `corpus/live/runs/20261013T064029016188Z/verdicts.json`, SHA-256 `bce65c9faf76b58a6e8436bbf7ac005b888afc5f068e98d0f7e1729f1bd74aac`. Its tree-timeout, crash-exit, stream-attribution and existing body-contact mutation receipts are respectively `fea8e3d82c4e64ae1af28bf086a52ca21cfef896ad8a1d3cfd4e93fd25d2ae03`, `f3859e3576d23fc6019d0298d863b8e93f2bdbced176b4309da9326c98e71fa0`, `f7e847d8d1fa22680fb9853e7e5915065589334b3d6e0609e2eeaa706c216b17`, `379939114ba9f0621e24da98e35a4adcaa851ad39619e35df29c1506db57537f` (all SHA-256). Pair replay: **2/2**, hit exit 0, outside exit 2, no unexpected stderr; `corpus/live/runs/20261013T064046858962Z/verdicts.json`, SHA-256 `b6da87911abd7f725e6df9c2308bc5b1619b210dfad6d0945247ed665d60df53`. Both runs have identical seed maps and the pair's complete raw records equal those in the full run for `case/script/flags/expected_exit/actual_exit/error/kind/marker/verdict/reasons/stdout/stderr`. Elapsed durations and scratch command paths naturally differ.

The prior r34 full **47/47** receipt is `corpus/live/runs/20261013T063353862680Z/verdicts.json` (SHA-256 `8c513b633abbf18531054460c827a8cda37d329889d396ea0bb9477476aa446f`). By case name, all 47 preceding raw records are **identical** across the same exact fields. Prior seed digests are unchanged except fixture README `82889cb446b89868282bc4ab85f38e2e0b06b555dfc473347851f40f50714d17` → `94b04ef42213f1564d864b119feaf966ad6edaa41de7abe0be46aab61769c6b6` and runner `75abc5c8949f775f2f98f2b35713e2afeefa1a02933eac894414d4a08db78838` → `d70bede71d492bdcf7ce1e305d2b74419f5754ab6c64ce37189562e3da5269dc`. Added `mesh3d_trimesh_hit.gd` seed digest `bae284fe0cafb162284d14072a0846897994d9cef725d014fbb9aedbcce27c93`; no earlier seed removed.

## Source and measured behavior

`mesh3d_trimesh_hit.gd` authors `ArrayMesh` with triangle `(0,0,0),(2,0,0),(0,3,0)`, calls `create_trimesh_shape()`, installs the result in `CollisionShape3D` under a live layer-1 `StaticBody3D`, and awaits **four** `physics_frame` signals. The setup requires generated type `ConcavePolygonShape3D`, `get_faces().size()==3`, one mesh surface, shape attachment and live body. It sets `generated.backface_collision=true` explicitly and **each** `PhysicsRayQueryParameters3D.hit_back_faces=true`, mask 1. The downward interior ray `(0.5,0.5,2)` → `(0.5,0.5,-2)` must return the same collider object and instance ID, point `(0.5,0.5,0)` within 0.0001, normal `(0,0,1)` within 0.0001 and `face_index==0`. A separate downward offset ray at x=3 must return an actually empty dictionary. The `--outside` arm does not alter either query or their checks: both arms first require the hit, then require the miss, and **only afterward** the flag changes the final marker/exit to intended negative rejection. This is not a dead-world negative. Markers are authored literals emitted after assertions, not independent measured telemetry; `get_faces` is checked for count rather than coordinate-by-coordinate readback.

Private ignored scratch `corpus/live/runs/r35-private-trimesh-review/` copies only `project.godot` and the script; the only script mutation is `Vector3(2, 0, 0)` → `Vector3(0.2, 0, 0)` (script SHA-256 `d5f9d5e3e981f40ad52a7df2adb56d824d55ab4da39a5ef94b63de9d23d54740`). The ray at x=.5,y=.5 lies outside that contracted triangle. Command:

```sh
/usr/bin/godot --headless --path .shokunin/game-dev-3d/corpus/live/runs/r35-private-trimesh-review --script res://mesh3d_trimesh_hit.gd
```

It exits **1** with `ERROR: mesh3d_trimesh_hit: interior ray missed generated mesh` at `_run` line 33, not the authored setup guard (which has already passed). No PASS, parse error, `SCRIPT ERROR`, or ObjectDB leak appeared. The downstream hit-field and outside predicates are not mutation-isolated by this specific change because the missing-control-hit check short-circuits first. Direct private command did not enforce the battery's 20-second per-case timeout; it completed in roughly 0.55 seconds.

An additional scratch check removed only `generated.backface_collision = true`: the unchanged explicit setup guard rejects this with exit 1 as `generated collision setup absent`, so **that run alone is not behavioral default-policy evidence**. In the same private copy, removing *only* the corresponding `or not generated.backface_collision` setup conjunct as well lets the default-valued generated shape pass setup; the same interior query then misses, exits 1 on `interior ray missed generated mesh` (script SHA-256 `b192da6954afd31f7fa8adada9c3c72caf3c9564c407f0ca9144470fa9e733fe`). Both changes are private scratch only. This independently corroborates the LOG's adverse initial default-shape misses; never describe the default as working.

**Limits:** One planar triangle, two rays and one static generated shape under explicit two-sided flags, on headless Godot 4.7.2. No default backface guarantee, arbitrary mesh/topology support, moving-body collision, continuous motion, GPU winding, rasterization or pixels. Coverage improves over r33/r34's CPU-visible mesh data and indexed cross products because physics space is now queried against a mesh-derived collider. Depth remains bounded to this single configuration; calibration remains the existing exit/marker classifier and opt-in probes.

> **Correction note (r106, 2026-10-18, SEAT-42).** Live-tree digest check. Quoted SHA-256 values above are the 2026-10-13 review record and are not rewritten; quoted `run_battery.py` digests match historical git blobs, not live `sha256sum` `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`. `mesh3d_trimesh_hit.gd` digest `bae284fe0caf…` still matches the live fixture. Absent `corpus/live/runs/` receipts and private mutant copies were not re-hashed.

<!-- r106-seat45-receipt-note -->

> **Non-resolvable receipt note (r106, 2026-10-18, SEAT-45).** Re-checked 2026-10-18: each path below is a concrete `corpus/live/runs` receipt cited in this lesson. The cited path is absent (`test -e` failed) and no durable copy exists under `reports/` (no receipt artifact whose path or `started_utc` is that run id; a prose mention is not a copy). Quoted receipt SHA-256 values on these lines do not match any tracked file or any `reports/` receipt artifact. `corpus/.gitignore` ignores `live/`, so these paths were never tracked. Historical sentences above are unchanged. Register: `reports/round-106/consistency/receipts.md`.
>
> - `corpus/live/runs/20261013T064029016188Z/verdicts.json`
> - `corpus/live/runs/20261013T064046858962Z/verdicts.json`
> - `corpus/live/runs/20261013T063353862680Z/verdicts.json`
> - `corpus/live/runs/r35-private-trimesh-review/`
> - `corpus/live/runs/r35-private-trimesh-review`
