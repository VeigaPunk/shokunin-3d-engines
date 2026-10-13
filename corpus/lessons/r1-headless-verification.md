# Round 1 — headless verification for 3D mechanics

Godot 4.7.2 (`/usr/bin/godot`, `4.7.2.stable.arch_linux.ed1daf0bf`), Linux,
`--headless`, no display, no GPU. Six 3D mechanic classes, each a positive
causal case plus a discriminating negative control: **12 cases, 6 ordinary + 6
negative controls**. Seeds: `corpus/fixtures/` (read-only at run time). Battery:
`corpus/fixtures/run_battery.py`.

## Exact commands

```
python3 corpus/fixtures/run_battery.py                  # all 12 cases; exit 0 only if all pass
python3 corpus/fixtures/run_battery.py --probe-failing  # + one adversarial mutation, must be detected
python3 corpus/fixtures/run_battery.py --only <case>[,<case>]
python3 run_battery.py --godot /usr/bin/godot --runs corpus/live/runs
```

The runner is path-independent (`HERE`-relative), verified from the lane root and
from `/tmp`. It copies the seed directory to `corpus/live/runs/<ts>/scratch`,
executes only the copy, and SHA-256-maps the seeds before and after: a changed
seed fails the battery. Per-case bound: 20 s subprocess timeout plus a
`FRAME_BOUND` of 1200 process frames inside every fixture. Single-fixture
reproduction, against a scratch copy:

```
godot --headless --path <scratch> --script res://<fixture>.gd [-- <flag>]
```

Each fixture header carries its own commands and expected exit signature.

## Exit contract and decision table

| Evidence observed | Classification | Next action |
|---|---|---|
| exit 0 and the exact `PASS <case> ...` line on **stdout** | PASS (ordinary case) | retain stdout/stderr and the scratch path in `verdicts.json` |
| exit 2 and the exact `NEGATIVE REJECTED: <case> <reason>` line on stdout | PASS (negative control, *not* a positive result) | verify the named absent effect and the setup-intactness fields, never the exit code alone |
| exit 1 with `ERROR: <fixture>: ...` | FAIL — setup error, bound breach, or an assertion that is not the intended negative | read the diagnostic; a negative that cannot discriminate is a defect, not a pass |
| timeout, crash (negative return code), missing marker, `SCRIPT ERROR:`, `Parse Error:`, any unexpected `ERROR:` line, ObjectDB leak warning | FAIL | inspect `reasons[]` in `verdicts.json` before touching a fixture |
| seed digest map differs before/after | FAIL | the runner or a human edited a seed; restore and re-run |

Sources: `corpus/fixtures/run_battery.py:124` (`classify`), `:101`
(`seed_digests`), `:30` (`CASES`), `:84` (`MUTATION`).

A `SCRIPT ERROR:` is never a pass even when the exit code is right — proven the
hard way in r1 (see `input3d_move` below, which exited 0 and 2 while emitting an
async-call script error).

## Per-case expected signatures

Full marker lines are the enforced contract in `CASES`
(`corpus/fixtures/run_battery.py:30`) and are duplicated in each fixture header.
Re-check header/table/actual agreement with:

```
python3 - <<'PY'   # every documented header marker must appear in the recorded stdout
import json, re, sys, importlib.util
from pathlib import Path
sys.dont_write_bytecode = True   # never leave a __pycache__ inside the read-only seeds
fx = Path("corpus/fixtures")
spec = importlib.util.spec_from_file_location("rb", fx / "run_battery.py")
rb = importlib.util.module_from_spec(spec); spec.loader.exec_module(rb)
runs = [p for p in sorted((fx.parent / "live" / "runs").glob("2*")) if (p / "verdicts.json").exists()]
full = [p for p in runs
        if (lambda d: d["verdict"] == "PASS" and d["totals"]["cases"] == len(rb.CASES) and not d["only"])
        (json.loads((p / "verdicts.json").read_text()))]
assert full, "no full battery run recorded"
actual = {r["case"]: [l.strip() for l in r["stdout"]]
          for r in json.loads((full[-1] / "verdicts.json").read_text())["results"]}
for path in sorted(fx.glob("*.gd")):
    header = "\n".join(l for l in path.read_text().splitlines() if l.startswith("#"))
    for doc in re.findall(r"^#\s{3}(PASS .*|NEGATIVE REJECTED:.*)$", header, re.M):
        table = [c[0] for c in rb.CASES if c[4] == doc]
        seen = [n for n, lines in actual.items() if doc in lines]
        assert table and seen, (path.name, doc[:60])
        print("OK", path.name, "->", seen, table)
PY
```

Run it from the lane root (`.shokunin/game-dev-3d/`). At r1 it printed 12 `OK`
lines with no assertion failure: header comment, enforced `CASES` entry and
recorded stdout agree for every case.

| case | fixture | flag | exit | hand-derived expectation asserted |
|---|---|---|---|---|
| `body3d_contact` | `body3d_slide.gd:118` | — | 0 | contact plane `z=2.5` = box half-depth 2.0 + body half-depth 0.5; first contact on tick 21 = (6.0−2.5)/(10/60); normal `+Z`; `on_wall` |
| `body3d_contact_far` | `body3d_slide.gd:139` | `--far-body` | 2 | start `z=40`, travel 10.0 → `z=30`, 27.5 short of the plane; `contacts=0`, `on_wall=false`, wall proven intact |
| `area3d_chain` | `area3d_chain.gd:133` | — | 0 | `body_entered` → `collected` exactly once (`entries=1`), payload `Runner3D`/layer 2, fired at `x≥4.0` = 6.0 − radius 1.5 − half-width 0.5, one overlapping body |
| `area3d_chain_no_overlap` | `area3d_chain.gd:154` | `--no-overlap` | 2 | pickup at `x=40`; `collected=0 entries=0 overlapping=0` while `monitoring=true`, mask↔layer match, and runner travel to `x=6.0` are proven |
| `camera3d_project` | `camera3d_project.gd:51` | — | 0 | `unproject_position(2,1,-4)=(550,225)`; `f_y=1/tan45°=1.0`, `f_x=f_y/(800/600)=0.75`; centre `(400,300)`, mirror `(250,375)`; authored 800×600 `SubViewport` |
| `camera3d_project_behind` | `camera3d_project.gd:145` | `--behind-camera` | 2 | `(2,1,4)`: `is_position_behind=true`, `in_frustum=false`; raw projection `(250,375)` **aliases the legitimate mirror pixel**; lateral `(40,0,-4)` → `x=3400 = (7.5·0.5+0.5)·800`, outside the 0..800 rect; in-front control still accepted |
| `raycast3d_hit` | `raycast3d.gd:97` | — | 0 | `intersect_ray((0,6,0)→(0,-6,0))` hits `(0,2,0)` (top face of a 4×4×4 box at the origin) with normal `(0,1,0)`, collider identity matches; `z=9` offset ray returns an empty Dictionary |
| `raycast3d_miss` | `raycast3d.gd:110` | `--miss-ray` | 2 | hitting control ray proves the space is live, then the offset ray 7.0 clear of the box half-depth returns zero hits |
| `transform3d_compose` | `transform3d_compose.gd:111` | — | 0 | parent `R_y(90)`@(2,0,0) ∘ child `R_x(90)`@(0,0,−3) → origin `(−1,0,0)`, basis columns `(0,0,−1) (1,0,0) (0,−1,0)`, determinant 1, `parent.global_transform * child.transform == child.global_transform`, reversed order rejected |
| `transform3d_compose_wrong_order` | `transform3d_compose.gd:128` | `--wrong-order` | 2 | correct order still matches, and `R_x·R_y` with summed translations `(2,0,−3)` is rejected by exact assertion |
| `input3d_move` | `input3d_move.gd:131` | — | 0 | synthetic `InputEventKey` W → `+1.000` on X over exactly 10 physics ticks (6.0×10/60), `0.000` on Y/Z, motion stops after the matching release over 5 more ticks |
| `input3d_move_no_event` | `input3d_move.gd:163` | `--no-input` | 2 | `receipts=0 intent=false`, zero displacement over the same 10 **live** ticks, then a late control press moves the same body `0.500` (6.0×5/60) |

Every expected value is a hand-authored literal, deliberately *not* recomputed
from the constants that build the geometry (`body3d_slide.gd:37`,
`camera3d_project.gd:51`, `raycast3d.gd:32`, `transform3d_compose.gd:44`,
`input3d_move.gd:42`). A fixture that re-derives its own expectation cannot
detect a changed constant — the adversarial mutation below is what proves that
discipline is load-bearing.

## Error-pattern table from the first real runs

The first manual pass over the twelve invocations failed 4 (both camera arms,
both input arms); after these repairs the battery passed 12/12 on its first run.

| Pattern / observed fixture | Cause | Response, proven by the next run |
|---|---|---|
| `Parse Error: Function "get_row()" not found in base Basis` | `Basis.get_row()` is not exposed to GDScript in 4.7.2; `basis[i]` and `basis.x/y/z` are **columns** | assert on columns as the world images of the local axes; documented in the `transform3d_compose.gd` header |
| `ERROR: camera3d_project: authored viewport/frustum is not in place`, exit 1, both arms | `Camera3D.near`/`far` are stored 32-bit: the authored `0.05` reads back `0.05000000074506`, so `camera.near != NEAR` | compare with `FRUSTUM_EPSILON = 1e-6` (`camera3d_project.gd:58`, `:126`); both arms then produced the hand-derived pixels |
| `ERROR: input3d_move: mover collision setup is not the authored arrangement`, exit 1, both arms | `get_physics_process_delta_time()` is still `0.0` before the first physics step completes; `is_processing()` is false for a script that only defines `_physics_process` | assert liveness through `is_physics_processing()`/`is_processing_input()` and the exact tick budget instead of delta (`input3d_move.gd:108-120`) |
| `SCRIPT ERROR: Trying to call an async function without "await"` while the case still exited 0 / 2 | `_displacement_verdict` and `_zero_verdict` await, so they are coroutines; called bare, they ran detached | `await` both at the call site (`input3d_move.gd:99-105`). This is the reason the battery rejects any `SCRIPT ERROR:` regardless of exit code |
| `NameError: name 're' is not defined` in `run_battery.py` | missing import | the runner exits 1 before any case runs; a broken runner is never a silent pass |
| root `Window` reports 64×64 and ignores `display/window/size` | Godot `--headless` display default | the camera fixture authors its own 800×600 `SubViewport`, so the viewport is a fixture constant, not a host default |
| `collected=0` in the first Area3D smoke | the runner was driven 30 ticks (3.0 units) but the entry threshold is `x≥4.0` | drive past the derived threshold and assert `entry_x ≥ 4.0` (`area3d_chain.gd:39`), so a short drive fails loudly instead of looking like a dead trigger |
| 10 awaited physics frames produced only 9 `_physics_process` calls | `SceneTree.physics_frame` is emitted at the **start** of a step, before `Node._physics_process` | snapshot right after `await physics_frame`, then await N more → exactly N calls, asserted through the actor's own tick counter (`input3d_move.gd:91-98`) |

## Adversarial mutation and its rejection

`--probe-failing` copies the scratch project to
`corpus/live/runs/<ts>/mutation-scratch` and mutates **exactly one authored
constant in one fixture**: `body3d_slide.gd`'s `const BOX_SIZE := Vector3(4.0,
4.0, 4.0)` → `Vector3(4.0, 4.0, 6.0)` (`run_battery.py:84`). The mutant is then
judged with the *seeded* case's own expectation (exit 0 plus the full `PASS
body3d_contact ...` marker), so "detected" means the same classifier that passes
the seed now rejects it.

Observed: exit **1**, no `PASS` marker on stdout, and exactly one stderr line

```
ERROR: body3d_slide: body did not stop at the contact plane final_z=3.500 expected=2.500
```

`3.500` is the new physical plane (box half-depth 3.0 + body half-depth 0.5)
while `EXPECTED_PLANE_Z` stayed the hand-authored `2.5`. Detection also requires
no `SCRIPT ERROR:`/`Parse Error:`, so a crash cannot masquerade as detection, and
`seeds_unchanged` must be true. Receipt:
`corpus/live/runs/20261013T025219873184Z/mutation-verdicts.json` (+ human-readable
`mutation-output.txt`).

Battery-level rejection controls (same receipt directory,
`adversarial-controls.json`): a SIGSEGV stub substituted for `--godot` → every
case `process died on signal 11`, battery exit 1; `/usr/bin/false` substituted →
every case `exit 1 != expected N` + `exact stdout marker missing`, battery exit
1; an unknown `--only` name → battery exit 1; a valid `--only` subset → exit 0.

Determinism: three consecutive full runs of the final seed set produced
byte-identical per-case stdout markers (one digest) and one seed digest map
(`determinism.json` in the same directory). Same host, same Godot build only.

## Agent checklist

1. Keep every seed read-only. Run `python3 corpus/fixtures/run_battery.py` and
   read the printed table plus `corpus/live/runs/<ts>/verdicts.json`: overall
   verdict, per-case exit code, exact marker, `reasons[]`, `seeds_unchanged`.
2. Exit 2 on a negative control is intentional. Confirm the *named absent
   effect* and the setup-intactness fields (`wall_intact`, `monitoring`,
   `mask_matches_layer`, `in_front_control_accepted`, `control_hits=1`,
   `correct_order_matches`, `late_control_*`) — a negative that passes because
   the whole scene is dead is worthless.
3. On FAIL, read `reasons[]` before touching a fixture, and check the table
   above for the known headless traps.
4. Any new case must add both arms, hand-derive its expectation as a literal,
   state its tick budget, and keep the marker deterministic (`snappedf + 0.0`).
5. Do not claim rendering, GPU, export, editor, other-engine, multiplayer or
   navigation coverage from this battery: no case measures them.

## Honest limits — what this battery does NOT prove

- **No rendering or GPU evidence.** `--headless` has no rasterizer, no GL/Vulkan
  context and no framebuffer. `camera3d_project` proves projection *math* and
  frustum classification against hand-computed pixels; it proves nothing about
  what a camera renders, about shading, materials, lighting, occlusion, or
  on-screen framing. Nothing here reads a pixel.
- **No exported-build or player evidence.** No export preset, no launched
  binary, no startup scene, no packaging. The 2D lane's export/launch probes are
  not ported.
- **No other engines.** Godot 4.7.2 only. Unity, Unreal and three.js behaviour is
  unprobed here (census: `corpus/knowledge/engines.md`); no claim transfers.
- **No cross-version or cross-platform determinism.** One host, one Godot build,
  one arch. Tick counts are exact by construction, but floating-point residuals
  (e.g. the 0.000292 safe-margin stop) are engine-version-specific.
- **No editor, asset-pipeline, serialization-format or REA evidence.** Round 1
  runs no REA route; `.glb`/`.gltf`/`.obj` and scene-container inspection remain
  unprobed (`corpus/knowledge/rea.md`).
- **No OS/device input.** `Input.parse_input_event` is synthetic; no keyboard,
  mouse, gamepad, focus or window-manager behaviour is proven.
- **No solver-edge regimes.** Resting contacts, stacking, continuous collision
  detection, tunneling at high speed, joints, ragdolls, soft bodies, character
  floor/slope/step handling and `motion_mode` transitions are untested; case 1
  proves one wall stop in one axis.
- **No navigation, AI, multiplayer/replication, audio, UI/Control-in-3D, particles
  or animation coverage.**
- **Calibration probes not yet ported.** The 2D lane's fault-injection,
  stream-attribution, crash-exit and process-tree-timeout probes exist there, not
  here; this battery's crash/timeout handling is exercised only by the two
  substitution controls above, and its timeout kills the direct child only.
- **One mutation is one mutation.** A single detected constant mutation does not
  establish mutation coverage; five of six classes have not been mutation-probed.
- **Non-author verification is outstanding.** Everything above is author-run; the
  SHONEN box for a named non-author verifier stays unchecked until someone else
  replays it.
