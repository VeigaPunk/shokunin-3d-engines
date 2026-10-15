# r101 navagent dissection — the 1-tick miss is a wall-clock map-publication race quantized by the tick grid

Lane: `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin` · engine
`4.7.2.stable.arch_linux.ed1daf0bf` (`/usr/bin/godot`) · `--headless` · tps 60
(project-pinned) · backends default.

Seat: g3d navagent dissection (execute-only). Task: dissect the
`navagent3d_retarget` / `navagent3d_follow` "miss by exactly N diagonal ticks
(√2/60) under load (r93 baseline F1)" flake — reproduce under controlled load,
isolate the mechanism (move-delta quantization? velocity projection?
path-recalc timing?), deliver verdict + fix spec.

Evidence: `corpus/live/navagent-dissection/` (gitignored) — `project/` (5
verbatim HEAD fixture blobs + 7 `r101n_*` probes), `tools/` (driver / analyzer /
manifest), `runs/` (**120 children**, sidecars `.stdout.txt` / `.stderr.txt` /
`.exit` / `.ms` / `.load` / `.cmd`), `logs/batch{1,2,3,4,4b,4c,4d,5}.log`,
`manifest.sha256` (768 entries). The only tracked-tree write is this report
(new, uncommitted). No fixture edits, no commits, no git mutation.

Confidence: **[O]** receipt-pinned observation, **[I]** inference, **[?]** unknown.

---

## 0. Method and provenance

- **Frozen bytes.** The 5 fixture blobs were extracted with `git show HEAD:` into
  the scratch project; their shas match the HEAD blobs exactly —
  `navagent3d_follow.gd` `2bdcca4a…`, `navfollow3d_driver.gd` `ec094e7f…`,
  `navagent3d_retarget.gd` `6ad85846…`, `navretarget3d_driver.gd` `310a1419…`,
  `project.godot` `1fda90d4…`. The live worktree's `run_battery.py` is
  sibling-modified (` M`) and was **not** used or touched; the dissection drives
  Godot directly with the runner's own invocation shape
  (`godot --headless --path <scratch> --script res://<f>.gd -- <flags>`).
- **Probes** (namespace `r101n_*`, all scratch-only): `r101n_follow_trace.gd`
  and `r101n_retarget_trace.gd` — instrumented mirrors of the two fixtures
  (identical construction order, identical forcing-getter cadence, identical
  sampling ticks; the only additions are observation), `r101n_mapready.gd` —
  server-clock poller with no agent, `r101n_follow_gated.gd` +
  `r101n_gated_driver.gd` — the fix prototype (§5).
- **Load control.** Host was ambient-saturated for the whole seat (load average
  74–90 on 32 CPUs, every core at 100 %; sibling lanes live). Every child was
  `taskset -c 30,31`-pinned; the *controlled* lever is `--hogs N` = N
  `yes > /dev/null` burners pinned to the **same** CPUs, killed in a `finally`
  block; load 1/5/15 is recorded before/after every child (`.load` sidecar).
  Rate is a second, fully owned lever: `--fixed-fps {60,600}` decouples the
  tick cadence from wall-clock while the physics delta stays exactly 1/60.
- **Accounting [O]:** **120 children**, all `timeout -s KILL`-bounded, no timeout
  and no kill; 76 rc=0, 2 rc=2 (the expected `--stationary` negative
  rejections), 42 rc=1 (11 verbatim-flake failures + 31 prototype-iteration
  failures — the latter are this seat's own assertion/bound bugs in the first
  four generations of the fix prototype, itemised in §5.5, not fix failures).

---

## 1. The flake, reproduced verbatim under load

Verbatim committed fixtures, ambient load 74–90, 2 CPUs pinned **[O]**:

| row | reps | PASS (pin) | observed misses | signature |
|---|---|---|---|---|
| `navagent3d_follow` | 8 | **2** | 5× `first=(1.636395,0,1.636395)`, 1× `first=(1.659965,0,1.659965)` | **+1 tick** (Δ=+0.023570=√2/60) and **+2 ticks** (Δ=+0.047140) |
| `navagent3d_retarget` | 6 | **1** | 5× `before=(1.754246,0,1.754246)` | **+1 tick** (Δ=+0.023570) |

Every observed value is **byte-identical to an on-record occurrence**:
`1.754246` is r78-scribe's recorded value; `1.636395` (+1) and `1.659965` (+2)
are r92-verifier2's recorded values; `1.777816` (+2 on retarget) is
r93-baseline2's. The committed pin (`first=1.612825`, `before=1.730676`)
corresponds to exactly **26 moves in 30 ticks** and **31 moves in 35 ticks**
(0.612825/0.0235702 = 26.0, 0.730676/0.0235702 = 31.0), i.e. the pin encodes
**4 leading no-move ticks** — one sample of the distribution, not a constant.

Failure rate here: follow 6/8, retarget 5/6. The record's other samples sit on
the same lattice: r93-baseline pre-fold run 2 saw 5 leading ticks
(`1.707105`/`1.589254`), r93-baseline2 run 2 saw 2 and 3, r92-verifier2 saw 3
and 2. So the *pin* (4) is neither the floor nor the mode.

---

## 2. Mechanism: the navigation map's two-stage dirty sync, resolved asynchronously

Per-tick trace of the instrumented mirror (`r101n_follow_trace.gd --full`),
one ambient rep **[O]**:

```
SUM stall=3 stall_us=58775 moves=85 t30=1.636395 t90=3.000000 first_next=1.000000,0.000000,1.000000 delta_sum=1.5000000 t_path2=3
MI0-9 0,1,1,2,2,2,2,2,2,2
T tick=0 moved=0.0000000 next=1.000000,0.000000,1.000000 pos=1.000000,0.000000,1.000000 psz=0 mi=0
T tick=1 moved=0.0000000 next=1.000000,0.000000,1.000000 pos=1.000000,0.000000,1.000000 psz=0 mi=1
T tick=2 moved=0.0000000 next=1.000000,0.000000,1.000000 pos=1.000000,0.000000,1.000000 psz=0 mi=1
T tick=3 moved=0.0333333 next=3.000000,0.000000,3.000000 pos=1.023570,0.000000,1.023570 psz=2 mi=2
T tick=4 moved=0.0333333 next=3.000000,0.000000,3.000000 pos=1.047140,0.000000,1.047140 psz=2 mi=2
```

- **[O] The stall is a no-op, not a slow move.** On every leading tick the
  forcing getter serves `next = (1,0,1)` — the agent's **own position** (the
  empty-path fallback) — so `move_toward(own_pos, SPEED·delta)` moves 0.0 m.
  The stored path (pure reader) is size 0. From tick `stall` on, `next` is the
  target and every step is exactly `0.0333333/0.0333334` m.
- **[O] The gate is the map's rebuild clock.** `map_get_iteration_id` must reach
  **2** before a path is served: iteration 1 is the sync that takes the region
  assignment, iteration 2 the sync that publishes the region's built navmesh
  (**[I]** — the two-stage reading; the counter and the path-served edge are
  both measured, the stage split is not source-verified). Every traced rep's
  sequence is a variant of `0 → 1 → 2` with the two syncs landing on different
  ticks: `0,1,2` (1 rep), `0,1,1,2` (5), `1,1,2` (1), `0,0,1,1,2` (1).
- **[O] The floor is 2 ticks** — the two syncs cannot be collapsed into one
  (observed in a 136 µs-gate `--fixed-fps 600` rep: `0,1,2`, first move at tick
  2). **[I]** the first sync can only apply a region that was assigned in an
  earlier frame, and the publish sync can only follow the build.
- **[O] The build/publication is asynchronous and wall-clock-bound.** The
  wall-clock from tick 0 to the first move spans three orders of magnitude:
  0.136 ms (`--fixed-fps 600`, fast path), 3.4 ms (`--fixed-fps 60`, one rep),
  33–85 ms (real-time ambient), 83–85 ms (12 hogs). Because the fixture samples
  at fixed **tick** indices, that wall-clock race is quantized by the tick grid.
- **[O] The server clock alone shows it** (`r101n_mapready.gd`, no agent):
  `mi` 0 → 1 → 2 at t = 1 → 3 with the query poller, and identically with
  `--noquery` (so the poller's own queries do not create the gate).

### 2.1 Controlled load and the rate lever **[O]**

| arm | n | leading no-move ticks | sampled t30 | note |
|---|---|---|---|---|
| ambient (trace) | 8 | **2,2,3,3,3,3,3,4** | 1.659965 / 1.636395 / **1.612825 (pin)** | wall-clock gate 34–86 ms |
| ambient + **12 hogs on the same CPUs** | 6 | **6,6,7,7,7,7** | 1.565684 / 1.542114 | **`t90`=2.956330/2.979900 ≠ 3.0** — the endpoint assertion fails too |
| `--fixed-fps 60` | 4 | **∞,∞,∞,65** | 1.0 (never moved) / — | the map never reached iteration 2 in 3/4 reps |
| `--fixed-fps 600` | 5 | **2,2,∞,∞,∞** | 1.659965 | gate 136 µs in the fast path; `mi` frozen at 1 in the rest |

Two consequences, both load-bearing for the verdict:

1. **The gate has no finite tick envelope.** The 90-tick window has only
   **5 ticks of slack** over the 85-move minimum travel; 12 pinned hogs push the
   gate to 6–7 ticks and the row then fails on `final`/`is_target_reached`
   (t90 = 2.956330), a **second failure mode** that is not the recorded
   "N diagonal ticks" signature. Under a decoupled rate the gate consumes the
   whole window (or 65 of 95 ticks) — no tick count is safe.
2. **`--fixed-fps` does not make it safer — it makes it catastrophic.** Any
   future rate-pinned fixture that samples nav-agent motion from tick 0 is
   measuring the race, not the motion.

---

## 3. Candidate mechanisms, adjudicated

**Move-delta quantization — REJECTED [O].** Across every full trace (30+ reps,
3 arms, both load regimes) the steady per-tick displacement is bit-constant
`{0.0333333, 0.0333334}` m = `2·delta` = 0.0333333, with exactly one other
value, `0.0284255`, which is the final `move_toward` **clamp** (remaining
distance 2√2 − 84·0.0333333 = 0.0284271). `delta_sum` is exactly `1.5000000`
(90 ticks) / `2.0000000` (120 ticks) in **113/113** children. The direction is
exact: `x == z` to <1e-6 on every moving tick, and the sampled positions are
exact integer multiples of `√2/60` (0.023570226) — which is why every recorded
miss is a whole-tick delta.

**Velocity projection — REJECTED [O].** The driver has no velocity vector; it
steps by `move_toward(next, SPEED·delta)`. The path is a 2-point straight
corridor ((1,0,1) → (3,0,3)); there is no projection, sliding or clamping other
than the final arrival step, and no load-dependent geometry.

**Path-recalc / map-publication timing — CONFIRMED [O].** 100 % of the observed
variance is the tick index at which the map first serves a path (iteration ≥ 2,
`psz` 0 → 2, `next` own-position → target). Nothing else in the trace varies.

---

## 4. Verdict

**STOCHASTIC (startup gate) + PINNABLE (motion law).**

- The startup gate is a contention-dependent **wall-clock race** (0.14 ms …
  85 ms measured) inside the navigation server's two-stage dirty-sync /
  async navmesh publication. Quantized by the tick grid it yields a floor of
  **2** leading no-move ticks and an **unbounded tail** (2–7 in real time here;
  65 and ∞ in rate-decoupled arms). It is **not pinnable** and admits **no
  finite tick envelope** — the sound fix is to move the race out of the measured
  window, not to widen a tolerance or re-pin to a modal value.
- The motion law itself is exactly **pinnable**: `2·delta` per tick along the
  corridor, `delta_sum` exact, direction exact. The only reason the row is
  flaky is that it samples an *absolute position at a fixed early tick*.
- The row can fail in two ways: (i) the recorded "N diagonal ticks" miss on the
  early sample (`first`/`before_switch`), and (ii) at gate ≥ 6 the endpoint
  sample misses as well (`t90` = 2.956330, 83/85 moves) — the window's 5-tick
  slack is thinner than the gate's observed tail.

---

## 5. Fix spec

### 5.1 Primary — phase re-anchor the measured window (mandatory)

Before the actor enters the tree (i.e. before the measured window's tick 0),
wait for the map to be live, bounded **by wall-clock**, with a loud setup
failure:

```gdscript
var t_gate := Time.get_ticks_msec()
var gate := 0
while NavigationServer3D.map_get_iteration_id(map) < 2 and Time.get_ticks_msec() - t_gate < 5000:
    await physics_frame
    gate += 1
if NavigationServer3D.map_get_iteration_id(map) < 2:
    return _fail(actor, "navigation map not live within 5000 ms (%d frames)" % gate)
```

`map_get_iteration_id(map) >= 2` is the readiness predicate (a pure server
read; no query, no perturbation).

**The bound must be wall-clock, not a frame count [O]:** a 120-frame bound
passed 2/2 at 60 tps real-time but was hit in 1/2 `--fixed-fps 60` reps — under
`--fixed-fps 60` the gate took **819 and 522 frames** (the same ~3.4 ms
wall-clock latency as the ungated arm's 65-tick stall) where real-time needs
**4–7**. A frame bound is rate-fragile for exactly the reason the flake exists.

Evidence for the fix **[O]**: `stall = 0` in **12/12** trace reps (6 ambient +
6 under 12 pinned hogs) with `t30 = 1.707105` exactly (30 moves); retarget
4/4 with `t35 = 1.824956` exactly (35 moves); `first_next = (3,0,3)`. Gate cost
3–7 frames in real time (22 trace reps), 4–7 frames for the prototype.

### 5.2 Re-pins the gate forces (all measured, not cosmetic)

| pin | committed | under the gate | why it moves |
|---|---|---|---|
| follow `first` | 1.612825 | **1.707106** | 30 moves instead of 26 |
| follow `first_next` | (1,0,1) | **(3,0,3)** | the pre-fix value is the **empty-path fallback = the agent's own position**; a live map serves the target at tick 0 |
| follow `path[0]` | ≈(1,0,1) | corridor check | the stored path is snapshotted at the agent's last lazy recompute; under the gate it is the first-step position `(1.02357,0,1.02357)`. Assert shape: `path.size()==2`, `path[1] ≈ (3,0,3)`, `path[0]` on the diagonal with `x ∈ [1,3]` |
| retarget `before_switch` | 1.730676 | **1.824957** | 35 moves instead of 31 |
| retarget `first_next` | (1,0,1) | **(3,0,3)** | same fallback |
| stationary/fixed controls | — | shared setup check re-pinned; behaviour unchanged | `--stationary` still `NEGATIVE REJECTED` 2/2, actor never moves |

### 5.3 Secondary — pin the motion law, not an early absolute position

Add a steady-state displacement assertion, e.g. positions at tick 40 and tick 80
must satisfy `|p80 − p40| = 40·SPEED·delta` (within 1e-4; measured 1.3333372 vs
1.3333333, float32 accumulation ≈ 4e-6) and both must lie on the diagonal
(`|x − z| < 1e-6`). This keeps the row's evidentiary claim (agent-guided motion
at exactly `SPEED·delta` per tick) even if a future gate regresses, and it is
the part of the assertion that is genuinely pinnable.

### 5.4 What not to do

- **`NavigationServer3D.map_force_update(map)` alone is not a fix [O]:** with it
  the leading-tick distribution is unchanged (2,2,3,3,3,4 vs 2,2,3,3,3,3,3,4)
  and the `mi` sequences keep the same shapes — it cannot collapse the async
  build→publish stage.
- **Do not widen the tolerance / re-pin to the mode:** the gate's tail is
  unbounded in ticks (§2.1); a wider band only moves the failure.
- **Do not add `--fixed-fps` to a nav-motion row without the gate** (§2.1).
- Do not size the window to the observed tail: 12 pinned hogs already put the
  ungated gate at 6–7 ticks against the window's 5-tick slack.

### 5.5 Prototype (end-to-end, scratch)

`r101n_follow_gated.gd` = byte-copy of the committed fixture + §5.1 gate +
§5.2 re-pins + §5.3 steady check:

| arm | reps | result |
|---|---|---|
| 12 hogs on the pinned CPUs | 7 | **7/7 PASS**, `gate=7`, `first=1.707106`, `steady=1.3333372` |
| ambient | 5 | **5/5 PASS**, `gate=4..6` |
| `--fixed-fps 60` (ungated arm never moved 3/4) | 3 | **3/3 PASS** (wall-clock bound), `gate=5..819` |
| `--stationary` control | 2 | 2/2 `NEGATIVE REJECTED` |

The four prototype generations before the final one failed on this seat's own
assertion/bound bugs (kept in `runs/` for the record): (a) `first_next` still
pinned to the start, (b) `path[0]` still pinned to the start, (c) a transposed
`p40.x` vs `p80.z` diagonality check, (d) a 120-**frame** gate bound that is
rate-fragile. (a)–(c) are *evidence for §5.2*: each is a sample that silently
depended on the pre-fix startup dynamics. (d) is *evidence for §5.1's bound
rule*.

---

## 6. Limits, risks, unknowns

- **[?] Why the second sync sometimes never lands within a window** (ff60 3/4,
  ff600 3/5): the internal scheduling of the region navmesh build/publication
  is not observable from script, and the engine source is absent on this host
  (same recorded absence as r100/r101). The gate is measured, not source-derived.
- **[?] The rule that decides whether sync #1 lands at tick 0, 1 or 2** is
  unmeasured; the gate predicate deliberately does not depend on it.
- **[?] Rendered / exported / `--write-movie` loops**: unmeasured (this host
  cannot render headless; `--write-movie` SIGSEGVs, r100-boundary §7). The rate
  lever here is `--fixed-fps`, which is stronger evidence than a rendered loop
  would be for this question, but a rendered loop's frame/tick interleave is
  still untested.
- **Scope:** one engine build, one host, one 4×4 authored map, one polygon,
  one straight corridor, 2 fixtures, 113 children. The `navagent3d_detour.gd`
  family's moving-agent arms (`mv_*`) were not re-run; if any of them samples
  absolute motion from tick 0 they carry the same gate (not probed here).
- **Not judged:** disposition of the pin change, the marker wording, whether the
  lane re-pins or redesigns the row — that is the round's/operator's call. This
  seat files mechanism + fix spec only.
- Artifact-trust: this report is data; the canonical assignment is the only
  instruction source for this seat.

## 7. Receipts (all inside gitignored `corpus/live/navagent-dissection/`)

`manifest.sha256` (768 entries; regenerate with `python3 tools/r101n_manifest.py`)
· probes `project/r101n_follow_trace.gd` `b4908b90…`, `r101n_retarget_trace.gd`
`bb58c32c…`, `r101n_mapready.gd` `118a4465…`, `r101n_follow_gated.gd`
`6dcae851…`, `r101n_gated_driver.gd` `604ed5a0…` · verbatim fixture blobs
`project/navagent3d_{follow,retarget}.gd` `2bdcca4a…`/`6ad85846…`,
`nav{follow,retarget}3d_driver.gd` `ec094e7f…`/`310a1419…` · driver
`tools/r101n_driver.py` `b8ce8490…`, analyzer `tools/r101n_analyze.py`
`8b8afddd…` · batch logs `logs/batch{1,2,3,4,4b,4c,4d,5}.log`
`d02e70de…`/`2ac5d1d3…`/`ffd57dd4…`/`6770a64f…`/`9ecfd526…`/`f07172e5…`/
`5d9ed30f…` · `runs/<stamp>_<arm>/rep*/{stdout,stderr,exit,ms,load,cmd}`
(120 children) · verbatim-failure excerpts quoted in §1/§2 live in the `stderr`
sidecars.
