# game-dev-3d — round-1 headless 3D fixture battery

Bounded, deterministic Godot 4.7.2 `--headless` fixtures for six 3D mechanic
classes. Each class is one positive causal case plus one discriminating
negative control that runs the *same* assertion machinery against a different
arrangement, so an absent effect is attributable to the arrangement and never to
a broken setup.

Everything in this directory is a **seed** and is treated read-only at run time.
`run_battery.py` copies the directory into `corpus/live/runs/<ts>/scratch` and
executes only the copy; it records a SHA-256 map of the seeds before and after
and fails the battery if any seed changed. Nothing here writes into the seeds,
and Godot's `.godot/` import cache is created inside the scratch copy only.

## Running

```
python3 corpus/fixtures/run_battery.py                     # all 12 cases
python3 corpus/fixtures/run_battery.py --probe-failing     # + one adversarial mutation
python3 corpus/fixtures/run_battery.py --only raycast3d_hit,raycast3d_miss
python3 run_battery.py --godot /path/to/godot --runs /path/to/receipts
```

The battery prints a per-case PASS/FAIL table plus totals and exits 0 only when
every case passes. Receipts land in `corpus/live/runs/<ts>/`: `verdicts.json`
(per-case command, exit codes, exact marker, full stdout/stderr, rejection
reasons, seed digests), `battery-output.txt`, and with `--probe-failing` also
`mutation-verdicts.json`. That tree is disposable; the seeds are not.

Single fixtures can be reproduced directly against a scratch copy:

```
godot --headless --path <scratch> --script res://<fixture>.gd [-- <flag>]
```

Each fixture's header comment carries its own exact commands and expected exit
signature.

## Exit contract

| situation | exit | stdout | battery verdict |
|---|---|---|---|
| positive holds | 0 | one exact `PASS <case> ...` line | PASS |
| negative control rejects as intended | 2 | one exact `NEGATIVE REJECTED: <case> <reason>` line | PASS |
| setup/script error, bound breach, assertion that is not the intended negative | 1 | no marker, one `ERROR: <fixture>: ...` line | FAIL |
| crash, timeout, missing marker, `SCRIPT ERROR:`, `Parse Error:`, any unexpected `ERROR:` line, ObjectDB leak warning | any | — | FAIL |

Exit 2 is a *passing* negative control, not a failure: it means the fixture
proved the effect absent under an arrangement that is otherwise identical. The
battery requires the exact marker line on stdout — never the exit code alone —
and classifies stdout and stderr separately.

## Cases

| case | fixture | flag | exit | mechanic |
|---|---|---|---|---|
| `body3d_contact` | `body3d_slide.gd` | — | 0 | `CharacterBody3D.move_and_slide()` stops at the hand-derived contact plane `z=2.5` (box half-depth 2.0 + body half-depth 0.5) on tick 21 with normal `+Z` |
| `body3d_contact_far` | `body3d_slide.gd` | `--far-body` | 2 | same assertions, body starts at `z=40`; zero contacts, travels the authored 10.0, wall proven intact |
| `area3d_chain` | `area3d_chain.gd` | — | 0 | `Area3D.body_entered` → domain `collected` chain fires exactly once with payload `Runner3D`/layer 2 at or past the derived entry threshold `x=4.0` |
| `area3d_chain_no_overlap` | `area3d_chain.gd` | `--no-overlap` | 2 | pickup relocated to `x=40`; zero signals while `monitoring`, mask/layer match and runner travel are proven live |
| `camera3d_project` | `camera3d_project.gd` | — | 0 | `unproject_position(2,1,-4)` → `(550,225)` on an authored 800×600 `SubViewport`, fov 90, `KEEP_HEIGHT`; `f_x=0.75`, `f_y=1.0`; centre and mirror controls |
| `camera3d_project_behind` | `camera3d_project.gd` | `--behind-camera` | 2 | behind-camera point `(2,1,4)` rejected by `is_position_behind`/frustum gate; its raw projection aliases the legitimate mirror pixel `(250,375)`; lateral off-frustum point projects to `x=3400`, outside the viewport rect |
| `raycast3d_hit` | `raycast3d.gd` | — | 0 | `PhysicsDirectSpaceState3D.intersect_ray` hits `(0,2,0)` with normal `(0,1,0)` on the authored collider; offset ray returns an empty Dictionary |
| `raycast3d_miss` | `raycast3d.gd` | `--miss-ray` | 2 | hitting control ray proves the space is live, then the `z=9` offset ray (7.0 clear of the box half-depth) returns zero hits |
| `transform3d_compose` | `transform3d_compose.gd` | — | 0 | parent `R_y(90)` at `(2,0,0)` ∘ child `R_x(90)` at `(0,0,-3)` → global origin `(-1,0,0)`, basis columns `(0,0,-1) (1,0,0) (0,-1,0)`, determinant 1, composition identity holds, reversed order rejected |
| `transform3d_compose_wrong_order` | `transform3d_compose.gd` | `--wrong-order` | 2 | correct-order expectation still matches, and the reversed hypothesis (`R_x·R_y`, summed translations → `(2,0,-3)`) is rejected by exact assertion |
| `input3d_move` | `input3d_move.gd` | — | 0 | synthetic `InputEventKey` W press → `1.000` on +X over exactly 10 physics ticks (`6.0 × 10 / 60`), zero on Y/Z, and motion stops after the matching release |
| `input3d_move_no_event` | `input3d_move.gd` | `--no-input` | 2 | no event injected → zero displacement over the same 10 live ticks, then a late control press moves the same body `0.500`, proving the zero was caused by the absent event |

Supporting scripts are not cases and carry no exit signature: `runner3d.gd`
(deterministic-drive `CharacterBody3D` actor), `input_mover3d.gd` (key-intent
actor), `pickup_orb3d.gd` (`Area3D` trigger with the `collected` chain).

## Optional stdout/stderr attribution (round 4)

`python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-stream-attribution`
adds an uncounted pair using the same `stream_attribution3d.gd` script. Both
set up a Node3D, exit 0 and print exactly `STREAM_3D_STDOUT: spatial node ready`
on stdout. Only `--emit-stderr` also prints `STREAM_3D_STDERR` on stderr;
`classify` rejects any nonempty stderr line. The raw paired streams, exit,
reasons and verdict are recorded in ignored `corpus/live/runs/<timestamp>/stream-attribution-verdicts.json`;
rerun the command. Default twelve cases remain unchanged.

## Optional direct-child signal classification (round 3)

`python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-crash-exit`
adds a **separate, uncounted** pair using `crash_exit3d.gd`. Both arms set up
a Node3D and print the exact `CRASH_EXIT_3D: spatial node ready` line. The
normal arm `quit(1)` passes the existing classifier when expecting exit 1;
the `--hold-open` arm remains live after printing, receives parent SIGTERM,
and must return -15 and be rejected by the same classifier despite the
marker. The paired streams, liveness, exit, and cleanup are in ignored
`corpus/live/runs/<timestamp>/crash-exit-verdicts.json`; rerun the command
for evidence. Eight seconds bounds marker observation; three seconds bounds
cleanup before forced kill. This is not a spontaneous crash or process-tree
guarantee. The twelve default cases are unchanged.

## Determinism rules for new cases

- Fixed tick budgets only. Count ticks through the actor's own counter and
  assert the budget exactly; never read a wall clock.
- `project.godot` pins `physics/common/physics_ticks_per_second=60`, so the
  authored delta is `1/60`.
- `SceneTree.physics_frame` is emitted at the **start** of a physics step, before
  `Node._physics_process`. Snapshot right after `await physics_frame`, then await
  N further physics frames to span exactly N `_physics_process` calls.
- No randomness, no `randf`, no OS/device input, no network, no display.
- Bound every wait (`FRAME_BOUND`) and exit through `SceneTree.quit(code)`.
- Expected values are hand-derived **literals** in the fixture, not recomputed
  from the same constants that build the geometry. Otherwise a mutated constant
  re-derives its own expectation and the assertion proves nothing — this is what
  `--probe-failing` checks.
- `--headless` pins the root `Window` to 64×64 and ignores
  `display/window/size`; author a `SubViewport` when a viewport size matters.
- `Camera3D.near`/`far` are stored as 32-bit floats (`0.05` reads back as
  `0.05000000074506`): compare with a tolerance. `Basis.get_row()` is not exposed
  to GDScript, and `basis[i]`, `basis.x/y/z` are columns.
- Format marker floats through `snappedf(v, 0.001) + 0.0` so `-0.0` and
  sub-tolerance noise print as `0.000` while genuine negatives stay signed.

## Scope

Headless Godot 4.7.2 on this Linux host: physics, spatial queries, projection
math, transform composition, scene-graph signals and synthetic input. It proves
nothing about rendering or GPU behaviour, exported builds, other engines, editor
tooling, multiplayer, or navigation baking. See
`corpus/lessons/r1-headless-verification.md`.
