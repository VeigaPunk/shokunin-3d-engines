# r101 frontier navagent dissection — the 1-tick miss is a wall-clock map-publication race; the motion law is exactly pinnable

Lane: `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin` · engine
`4.7.2.stable.arch_linux.ed1daf0bf` (`/usr/bin/godot`) · `--headless` · project
tps 60 · default backends · host 32 CPUs, ambient load 53–70 for the whole seat.

Seat: g3d navagent dissection (execute-only, independent re-dissection).
Assignment (dispatch): live-probe the NavAgent/NavigationServer3D surface,
evidence under `corpus/live/navagent-dissection/`, report at
`reports/frontier/navagent-dissection.md`, zero tracked writes outside that
report path, no commits. The wave task file
`.ufo/waves/shokunin-train-20261015-w22/tasks/g3d-navagent-dissection.md` names
the same evidence dir but a different report path
(`reports/round-101/navagent-dissection.md`, where an earlier seat's committed
report already sits at `fc6d033`); the dispatch path was followed and the
conflict is recorded here as data.

Question: `navagent3d_retarget` / `navagent3d_follow` miss by exactly N diagonal
ticks (√2/60) under load (r93 baseline F1). Reproduce under controlled load,
isolate the mechanism (move-delta quantization? velocity projection?
path-recalc timing?), deliver verdict (pinnable / envelope / stochastic) + fix
spec.

Evidence: `corpus/live/navagent-dissection/frontier/` (gitignored) —
`project/` (7 verbatim HEAD fixture blobs + 8 `r101n_f_*` probes),
`tools/` (driver / analyzer / frame-check / manifest), `runs/` (**169 children**,
56 run dirs, sidecars `.stdout.txt` `.stderr.txt` `.exit` `.ms` `.load` `.cmd`),
`logs/batch{1,2,3,4,4b,5,5b,6,7}.log` + `logs/analysis.log`,
`manifest.sha256` (1100 entries). The only tracked-tree write is this report.

Confidence: **[O]** receipt-pinned observation, **[I]** inference, **[?]** unknown.

---

## 0. Method and provenance

- **Frozen bytes.** The 7 fixture blobs were extracted with `git show HEAD:`
  into the scratch project; shas equal the HEAD blobs —
  `navagent3d_follow.gd` `2bdcca4a…`, `navagent3d_retarget.gd` `6ad85846…`,
  `navfollow3d_driver.gd` `ec094e7f…`, `navretarget3d_driver.gd` `310a1419…`,
  `navagent3d_next.gd` `f0ea0fbb…`, `navagent3d_distance.gd` `b820e469…`,
  `navagent3d_detour.gd` `66c097e4…`; `project.godot` `1fda90d4…` (tps 60).
  The live worktree's `run_battery.py` is sibling-modified (` M`) and was **not**
  read for behavior, used, or touched; children are driven directly with the
  runner's own invocation shape
  (`godot --headless --path <scratch> [engine args] --script res://<f>.gd -- <flags>`).
- **Probes** (namespace `r101n_f_*`, scratch-only): `r101n_f_trace.gd` +
  `r101n_f_trace_driver.gd` and `r101n_f_retarget_trace.gd` +
  `r101n_f_retarget_trace_driver.gd` — instrumented mirrors of the two committed
  fixtures (identical construction order, forcing-getter cadence and sample
  ticks; observation only: per-tick map iteration id, process frame, stored path
  size, `next`, moved distance, first-move tick/wall-clock, displacement
  histogram, direction residual); `r101n_f_mapready.gd` — server-clock poller
  with no agent; `r101n_f_gate.gd` / `r101n_f_retarget_gate.gd` — fix prototypes;
  `r101n_f_order.gd` — authoring-order lever.
- **Load control.** Every child is `taskset -c`-pinned to 2 CPUs (30,31 or
  28,29) and `timeout -s KILL 60`-bounded; the controlled lever is `--hogs N`
  = N `yes > /dev/null` burners pinned to the **same** CPUs, killed in a
  `finally` block; load 1/5/15 is recorded before/after every child
  (`.load` sidecar). Rate is the second lever: `--fixed-fps {60,600}` decouples
  the tick cadence from wall-clock while the physics delta stays exactly 1/60.
- **Accounting [O]:** 169 children / 41 arms — 143 rc=0, 20 rc=1, 6 rc=2
  (expected `NEGATIVE REJECTED` arms); **zero timeouts, zero kills** (no rc 124/137).
  One early smoke child (`20261016T054551…_trace_follow`) has an unsubstituted
  `SUM` format string (a probe bug fixed before batch 1; its `T` tick lines are
  valid and are used).

---

## 1. The flake, reproduced verbatim under load

Committed fixtures, unmodified, ambient load 53–70 **[O]**:

| row | arm | reps | rc=0 | rc=1 | observed failing value | signature |
|---|---|---|---|---|---|---|
| `navagent3d_follow` | ambient | 8 | **7** | 1 | `first=(1.636395,0,1.636395)` | **+3 ticks** over the pin |
| `navagent3d_follow` | +12 hogs | 6 | 4 | **2** | `first=(1.589254,0,1.589254)` | **+5 ticks** |
| `navagent3d_retarget` | ambient | 6 | 4 | **2** | `before=(1.754246,0,1.754246)` | **+1 tick** over the pin |
| `navagent3d_retarget` | +12 hogs | 4 | 4 | 0 | — | (gate 4–6; pin survives) |
| `navagent3d_follow` | `--fixed-fps 60` | 3 | 1 | **2** | `first=(1.683535,0,1.683535)` / `agent path setup absent path=[]` | gate at tick 1 or never |
| `navagent3d_retarget --fixed` (negative control) | ambient | 2 | 0 | **1** | `before=(1.754246,…)` | control fails **before** its own negative branch |

Exact failure texts (stderr):

```
ERROR: navagent3d_follow: agent-guided actor motion mismatch first=(1.636395, 0.0, 1.636395) final=(3.0, 0.0, 3.0) reached=true finished=true
ERROR: navagent3d_retarget: pre-switch callbacks/motion mismatch ticks=120 first_next=(1.0, 0.0, 1.0) before=(1.754246, 0.0, 1.754246)
```

The pin is **not** a constant: the committed `first=1.612825` and
`before=1.730676` are exactly `1 + 26·√2/60` and `1 + 31·√2/60`, i.e. the pin
encodes **4 leading no-move ticks** (30−26, 35−31). Every observed miss is an
exact whole-tick shift of that lattice — measured values across the seat's
59 instrumented/lever children: `1.612825` (stall 4, 14), `1.636395` (3, 14),
`1.659965` (2, 2), `1.589254` (5, 4), `1.565684` (6, 3), `1.683535` (1, 2 under
`--fixed-fps 60`), and `1.0` (never moved, 5).
On the retarget row: `1.730676` (stall 4, 5), `1.754246` (3, 1), `1.707105`
(5, 2), `1.683535` (6, 1). So the row samples one draw of a distribution; the
pin is neither floor nor mode.

---

## 2. Mechanism: the navigation map publishes asynchronously and the getter
## serves an own-position fallback until it does

Per-tick trace of the instrumented mirror (`r101n_f_trace.gd --full`) **[O]**:

```
T tick=0 mi=0 pf=5  psz=0 moved=0.0000000 next=1.000000,0.000000,1.000000 pos=1.000000,0.000000,1.000000
T tick=1 mi=1 pf=9  psz=0 moved=0.0000000 next=1.000000,0.000000,1.000000 pos=1.000000,0.000000,1.000000
T tick=2 mi=1 pf=12 psz=0 moved=0.0000000 next=1.000000,0.000000,1.000000 pos=1.000000,0.000000,1.000000
T tick=3 mi=2 pf=14 psz=0 moved=0.0333333 next=3.000000,0.000000,3.000000 pos=1.023570,0.000000,1.023570
T tick=4 mi=2 pf=17 psz=2 moved=0.0333333 next=3.000000,0.000000,3.000000 pos=1.047140,0.000000,1.047140
```

- **[O] The stall is a no-op, not a slow move.** Below the gate the forcing
  getter serves `next` = the agent's **own position** (empty-path fallback), so
  `move_toward(own_pos, SPEED·delta)` moves 0.0 m. At the tick where
  `map_get_iteration_id` reaches 2 the getter serves the target and every step
  is exactly `SPEED·delta`.
- **[O] Invariant scan over all 16 full traces (958 moving ticks):** moving
  ticks with `mi < 2`: **0**; moving ticks whose `next` is not the target: **0**;
  pre-gate no-move ticks serving `next == own position`: **467**. Moves happen
  **iff** `mi ≥ 2`.
- **[O] The path array materializes one read late:** on the first serving tick
  `psz` is still 0 while `next` is already the target; from the next read on
  `psz = 2` (corridor). `get_current_navigation_path()` is a stored-array read,
  not the serve edge; the tick loop's `--nopath` variant is stall-identical
  (3,3,3 vs the ambient 2–4 spread of the path-reading variant), so the
  observer does not create the gate.
- **[O] The counter advances on main-loop frames, and ticks are its sampling
  grid.** `Engine.get_process_frames()` per tick (ambient: ~2.5 process frames
  per physics tick; under 12 hogs: 1–3) and `mi` per tick: every set of ticks
  sharing one process frame carries exactly **one** `mi` value (**0**
  multi-`mi` frames over all full traces, including the two h12 traces where a
  frame carries two ticks). `mi` transitions land at process frames 6–10
  (0→1) and 11–15 (1→2); the first move is always at the tick where `mi`
  first reads 2. **[I]** the server's dirty-sync/publish runs per main-loop
  frame, so the tick index of the gate is a *quantization of a frame/wall-clock
  race*.
- **[O] The latency is wall-clock, not frame- or tick-count.** Server-clock
  witness with **no agent** (`r101n_f_mapready.gd`, 11/11 real-time reps):
  `mi` sequence `0,0,1,1,2,2,…`, ready at tick 4, **89–91 ms**; identical with
  `--noquery` (the poller's own queries do not create the gate). Under 12 hogs
  the same latency pushes the gate to ticks 4–6; under `--fixed-fps` the window
  simply runs out of wall-clock before the publish (below).

### 2.1 Candidate mechanisms, adjudicated

**Move-delta quantization — REJECTED [O].** Across all 36 follow-shaped
children that completed the corridor (every lever arm and both load regimes) the
per-tick displacement multiset is **identical**:
`{0.028425520×1, 0.033333268×42, 0.033333436×42}` — 84 steady steps of
`2·delta` plus the final `move_toward` clamp
(`2√2 − 84·2/60 = 0.0284271`); the 3 children that never arrived (stall 6) show
the same two steady values with no clamp step, with `delta_sum` exactly
`1.5000000` (90 ticks) / `2.0000000` (120 ticks) in every child that moved, and
direction residual `|x − z| = 0.000000000` on every moving tick. Step size has
no load or wall-clock dependence.

**Velocity projection — REJECTED [O].** The drivers step by
`global_position.move_toward(next, SPEED·delta)`; there is no velocity vector,
no sliding, and no projection on the straight corridor. The only non-steady
step is the terminal clamp.

**Path-recalc / map-publication timing — CONFIRMED [O].** 100 % of the observed
variance is the tick index at which the map first serves a path (`mi` 1→2,
`psz` 0→2, `next` own-position → target). Nothing else in the trace varies.

---

## 3. Controlled load and the rate lever

**[O]** stall (leading no-move ticks) by arm, this seat's children:

| arm | n | stall distribution | sampled t30 | note |
|---|---|---|---|---|
| ambient traces | 11 | 2,3,3,3,3,3,3,4,4,4,4 | 1.612825…1.659965 | gate wall-clock 41–83 ms |
| +12 hogs on the same CPUs | 10 | 3,4,4,5,5,5,5,6,6,6 | 1.565684…1.636395 | **stall 6 ⇒ `t90`=2.979900 (84 moves)** |
| `--fixed-fps 60` | 4 | 1,1,∞,∞ | 1.683535 / never moved | gate = 2 ticks or never |
| `--fixed-fps 600` | 4 | 4,65,∞,∞ | 1.612825 / 1.589254 (25 moves) | gate 4/65/∞ |
| `--fixed-fps 60`, mapready (no agent) | 3 | ∞ | `mi` frozen at **0** | 20-tick window, ~10 ms |

Two consequences:

1. **The gate has no finite tick envelope.** Under 12 pinned hogs the gate
   reaches 6–7 ticks; the 90-tick window has only **5 ticks of slack** over the
   85-move minimum travel, so at stall 6 the row fails a **second way** —
   `t90 = 2.979900` (84 moves, `final`/`is_target_reached`) — which is not the
   recorded "N diagonal ticks" signature. At `--fixed-fps 600` one rep had
   stall 65 (25 moves).
2. **`--fixed-fps` does not make the row safer; it makes it inert or
   catastrophic.** Under an unthrottled loop the same publish latency is 2–8 ms
   (measured directly by the gate prototype, §4), so a 90-tick window can end
   before the map has published at all (`moves=0`, `t90=1.0`, `t90_psz=0`) or
   the publish can land at tick 1 (`t30=1.683535`, one move *more* than the
   pin). No tick count is safe.

**Authoring-order lever — REJECTED as a fix [O].** Assigning the region's
navmesh **before** the region joins the map (`--order meshfirst`) leaves the
same distribution (stall 2,3,3,4,4,4,4; n=7); a one-shot
`NavigationServer3D.map_force_update(map)` after authoring also leaves it
unchanged (3,4,4; n=3) against the committed order (3,4; n=2). Neither
collapses the two-stage startup sync.

---

## 4. Verdict

**STOCHASTIC (startup gate) + PINNABLE (motion law).**

- The startup gate is a contention- and rate-dependent **wall-clock race**
  (2 ms … 89 ms measured) inside the navigation server's two-stage dirty
  sync / asynchronous navmesh publication. Sampled on the tick grid it has a
  floor of **1–2** leading no-move ticks (2 in real time; 1 when the publish
  lands inside the first frames of an unthrottled loop — the two counter
  transitions were never observed on one process frame) and an **unbounded
  tail** (2–7 in real time here; 65 and ∞ under rate decoupling). It is **not
  pinnable**, and **no finite tick envelope exists**: the sound fix is to move
  the race out of the measured window, not to widen a tolerance or re-pin a
  modal value.
- The motion law is exactly pinnable: `2·delta` per tick along the corridor,
  `delta_sum` exact, direction exact, terminal clamp closed-form.
- The two flaky rows fail in two ways: (i) the recorded early-sample miss
  (`first` / `before_switch`), (ii) at stall ≥ 6 the endpoint sample misses too
  (`t90` = 2.979900). The negative control `navagent3d_retarget --fixed` is
  exposed to (i) as well: it samples `before_switch` at tick 35 before its own
  negative branch, so it can return rc=1 instead of the expected rc=2.

---

## 5. Fix spec (independently validated)

### 5.1 Primary — phase re-anchor the measured window (mandatory)

Before the actor enters the tree (before the window's tick 0), wait for the map
to be live, bounded **by wall-clock**, with a loud setup failure:

```gdscript
var t_gate := Time.get_ticks_msec()
var gate := 0
while NavigationServer3D.map_get_iteration_id(map) < 2 and Time.get_ticks_msec() - t_gate < 5000:
    await physics_frame
    gate += 1
if NavigationServer3D.map_get_iteration_id(map) < 2:
    return _fail(actor, "navigation map not live within 5000 ms (%d frames)" % gate)
```

`map_get_iteration_id(map) >= 2` is the readiness predicate (pure server read;
no query, no perturbation). **The bound must be wall-clock, not a frame count
[O]:** under `--fixed-fps 60` the same gate costs **670–1688 frames** (2–8 ms)
where real time costs **3–8 frames** (58–83 ms); a frame bound is rate-fragile
for exactly the reason the flake exists.

Measured prototype results (`r101n_f_gate.gd` = byte-faithful follow fixture +
gate + re-pins + steady assertion; `r101n_f_retarget_gate.gd` the same for
retarget) **[O]**:

| arm | reps | result |
|---|---|---|
| follow, ambient | 6 | **6/6 PASS** — `gate=3..4` (63–83 ms), `first=1.707106` exactly, `steady=1.3333372` |
| follow, +12 hogs | 6 | **6/6 PASS** — `gate=7..8` (58–83 ms) |
| follow, `--fixed-fps 60` | 4 | **4/4 PASS** — `gate=670..1688` frames (2–8 ms), window armed |
| follow `--stationary` control | 2 | 2/2 `NEGATIVE REJECTED` (rc=2), `stall=-1`, never moved |
| retarget, ambient | 4 | **4/4 PASS** — `before=1.824957` exactly, `after_end=final=(1,0,3)` |
| retarget, +12 hogs | 4 | **4/4 PASS** — `gate=6..7` |

`stall = 0` in every armed window (first physics tick already moves);
`first_next = (3,0,3)` (a live map serves the target at tick 0, not the
empty-path fallback).

### 5.2 Re-pins the gate forces (measured, not cosmetic)

| pin | committed | under the gate | why it moves |
|---|---|---|---|
| follow `first` | 1.612825 | **1.707106** | 30 moves instead of 26 |
| follow `first_next` | (1,0,1) | **(3,0,3)** | pre-fix value is the empty-path fallback = the agent's own position |
| follow `path[0]` | ≈(1,0,1) | corridor check | stored path snapshots at the agent's last lazy recompute; assert `size()==2`, `path[1] ≈ (3,0,3)`, `path[0]` on the diagonal |
| retarget `before_switch` | 1.730676 | **1.824957** | 35 moves instead of 31 |
| retarget `after_path[0]` | 1.730676 | **1.824957** | `path[0]` is the live position at the switch tick; asserted equal to `before_switch` |
| stationary control (follow) | — | shared setup check re-pinned; behaviour unchanged | `--stationary` rc=2 2/2 under the gate, `stall=-1`; the `--fixed` control under the gate is a prediction, not measured here |

### 5.3 Secondary — pin the motion law, not an early absolute position

Assert a steady-state displacement (tick 40 → tick 80:
`|p80 − p40| = 40·SPEED/60` within 1e-4; measured 1.3333372 vs 1.3333333
analytic, float32 accumulation ≈ 4e-6) plus diagonal `|x − z| < 1e-6`. This
keeps the row's evidentiary claim (agent-guided motion at exactly
`SPEED·delta` per tick) even if a future gate regresses.

### 5.4 What not to do

- **`NavigationServer3D.map_force_update(map)` alone is not a fix [O]** —
  leading-tick distribution unchanged (3,4,4 vs 3,4).
- **Re-ordering the authoring (mesh before map assignment) is not a fix [O]** —
  distribution unchanged (2,3,3,4,4,4,4; n=7).
- **Do not widen the tolerance / re-pin to the mode:** the tail is unbounded in
  ticks (§3); a wider band only moves the failure.
- **Do not add `--fixed-fps` to a nav row without the gate:** under it the
  window can end before the server publishes at all (§3, §6).

---

## 6. Frontier: the tick-30 nav fixtures are rate-fragile, not gate-immune

The earlier seat's report left the rest of the nav family unprobed ("if any of
them samples absolute motion from tick 0 they carry the same gate"). This seat
tested the neighbouring rows directly **[O]**:

| fixture arm | ambient | +12 hogs | `--fixed-fps 60` | failure text (ff60) |
|---|---|---|---|---|
| `navagent3d_next` | 6/6 | 3/3 | **5/6** (1 fail) | `agent route setup failed path=[]` |
| `navagent3d_next --alternate` | — | — | **1/3** (2 fail) | same (1 rep still rc=2) |
| `navagent3d_distance` | 4/4 | 3/3 | **1/4** (3 fail) | `distance/final/next mismatch distance=2.828427 final=(0,0,0) next=(1,0,1) reachable=false` |
| `navagent3d_detour` | 4/4 | 3/3 | **1/4** (3 fail) | `detour path absent or unbent next=(0.5,0,0.5) path=[] pathlen=0.000000 final=(0,0,0)` |
| `navagent3d_detour --arm=mv_walk` | 3/3 | — | **2/3** (1 fail) | `mv_walk idx=0 expected=1` |

Reading: these rows sample at **tick 30**, which absorbs the gate in real time
(≤ 7 ticks, even with 12 pinned hogs — next 9/9, distance 7/7, detour 7/7,
mv_walk 3/3), but **not** under rate
decoupling: with `--fixed-fps 60` the unthrottled loop reaches tick 30 in ~1 ms
of wall-clock, before the publish, so `path=[]`, `final=(0,0,0)` and
`reachable=false`. They are therefore *gate-lucky* in real time, not gated: the
same wall-clock race sits inside their setup, one rate lever away. They also
share the fix (§5.1 gate before the window), not a longer wait.

---

## 7. Limits, risks, unknowns

- **[?] Why the publish sometimes never lands inside a run** (`--fixed-fps`
  arms: 2/4 at ff60, 2/4 at ff600, 3/3 mapready at ff60) is not observable from
  script; engine source is absent on this host (same recorded absence as
  r100/r101). The gate predicate is measured, not source-derived; the
  two-stage reading (sync #1 takes the region assignment, sync #2 publishes the
  built navmesh) is **[I]** — the counter, the serve edge and the frame
  alignment are measured.
- **[?]** The rule deciding whether sync #1 lands at process frame 8, 9 or 10
  is unmeasured; the gate deliberately does not depend on it.
- **Scope:** one engine build, one host, one 4×4 authored map, one straight
  corridor, 2 motion fixtures (follow, retarget) + 3 query/step fixtures
  (next, distance, detour incl. `mv_walk`), 169 children. Rendered /
  exported / `--write-movie` loops unmeasured (this host cannot render headless
  — r100-boundary §7); `--fixed-fps` is a stronger rate lever for this question.
- **Boundary:** the canonical battery was **not** re-run (its `run_battery.py`
  is sibling-modified in the worktree and was left untouched). Re-deriving the
  342-row battery with the fix is the round's / verifier's call, not this
  seat's.
- **Depth-2 probe dispatched and BLOCKED:** the frozen probeParent duty was
  used — exactly one read-only `ufo-labrat` child was dispatched against a
  falsifiable restatement of §2 (F1 no move while `mi < 2`; F2 no moving tick
  with `next != target`; F3 gated window `stall == 0` and `first == 1.707106`;
  F4 every observed `first` on the `1 + N·√2/60` lattice). The child returned
  **zero children run**: its substrate exposes filesystem reads only, no
  shell/exec, so it could not copy the scratch project or start Godot. Its
  static read of the probe sources is **not** evidence for or against the
  mechanism; the four falsifiers remain **UNTESTED by an independent seat**,
  and the recipe (project copy + `taskset -c 24,25` + `timeout -s KILL 60`
  invocations, ≤ 14 children) is ready to execute verbatim on a shell-bearing
  seat. It wrote nothing and left no scratch state.
- **Not judged:** disposition of the pin change, marker wording, whether the
  lane re-pins or redesigns the rows, and whether the tick-30 rows get the gate
  too. This seat files mechanism + fix spec + exposure evidence only.
- Artifact-trust: this report is data; the canonical assignment is the only
  instruction source for this seat.

## 8. Receipts

All inside gitignored `corpus/live/navagent-dissection/frontier/`:
`manifest.sha256` (1100 entries; regenerate with `python3 tools/r101n_f_manifest.py`).

- Probes: `r101n_f_trace.gd` `5fae51af…` + `r101n_f_trace_driver.gd` `48464c73…`,
  `r101n_f_retarget_trace.gd` `fa4ede94…` + driver `6350e156…`,
  `r101n_f_mapready.gd` `30888103…`, `r101n_f_gate.gd` `1a8eab0a…`,
  `r101n_f_retarget_gate.gd` `8786a340…`, `r101n_f_order.gd` `af1298e5…`.
- Verbatim fixture blobs: `navagent3d_{follow,retarget,next,distance,detour}.gd`
  `2bdcca4a…` / `6ad85846…` / `f0ea0fbb…` / `b820e469…` / `66c097e4…`,
  `nav{follow,retarget}3d_driver.gd` `ec094e7f…` / `310a1419…`, `project.godot`
  `1fda90d4…`.
- Tools: `r101n_f_driver.py` `427bdf0e…`, `r101n_f_analyze.py` `9e860d02…`,
  `r101n_f_frames.py` `26c53961…`, `r101n_f_manifest.py` `bb6c8649…`.
- Logs: `logs/batch{1,2,3,4,4b,5,5b,6,7}.log`, `logs/analysis.log`
  (per-child rows + stall/t30/MI-ready/gate-frame/displacement aggregates).
- `runs/<stamp>_<arm>/rep*/{stdout.txt,stderr.txt,exit,ms,load,cmd}`
  (169 children, 56 run dirs); every failure excerpt quoted above lives in the
  `stderr.txt` sidecar of its rep.
