# game-dev-3d round 85 — author (seat: author, host: devin) — backend × threading cross-product + refused shapes

Wave `shokunin-train-20261101-w16`, lane g3d. Assignment
(`.ufo/waves/shokunin-train-20261101-w16/tasks/g3d-author.md`, verbatim): r85
AUTHOR — `phys3d_events.gd` extension: `jolt_threaded` cross-product arm,
Dummy-backend refused-shape cells, server-write phase-delta (stretch);
insertion-only, all 188 prior cases byte-identical, child arms keep total
dispatch + stale-log unlink + timeout-KILL + ObjectDB scan; fold the r84
simplifier's deferred V2 (`_spawn_child` single-sourcing) if the third
child-spawn site justifies it. Report → `reports/round-85/r85-author.md`.

**Runtime (every bound below is scoped to this):** `/usr/bin/godot`
`4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`, 60 tps, Jolt
Physics / GodotPhysics3D / Dummy backends on this host. HEAD `ac025b2`
(`r84 report-last`, the r85 baseline freeze commit). No git mutation, no
subagent, no runtime other than the canonical battery.

**LSP unavailability recorded.** `mcp_list_servers` exposes only `rea` — there
is no `lsp` device for this repo, so no symbol-aware rename/reference pass was
available. The semantic checker used instead is the engine itself: Godot's
GDScript compiler resolves every call, so a missing/renamed symbol is a
`Parse Error` at load (this is exactly how finding F1 below was caught, and it
is stronger than a text-level rename check for this file).

---

## 0. Landing status — the arriving diff was a hard parse error

A prior author seat implemented the fixture diff and died on a model rate
limit. On arrival the worktree carried an **uncommitted** `phys3d_events.gd`
diff (+270/−110) and an untouched `run_battery.py`; no `r85-author.md`
existed. Reviewing it first (as instructed — it is unverified author output):

- **F1 (blocker, fixed).** The diff added the `--child` dispatch arms
  `"jolt_threaded": await _child_jolt_threaded()` and
  `"dummy_refused": await _child_dummy()` **but never wrote those two
  functions**. Measured consequence, not inferred:

      $ godot --headless --path <scratch> --script res://phys3d_events.gd -- --arm=isect
      SCRIPT ERROR: Parse Error: Function "_child_jolt_threaded()" not found in base self.
                at: GDScript::reload (res://phys3d_events.gd:318)
      SCRIPT ERROR: Parse Error: Function "_child_dummy()" not found in base self.
                at: GDScript::reload (res://phys3d_events.gd:320)
      ERROR: Failed to load script "res://phys3d_events.gd" with error "Parse error".

  The arriving tree therefore **failed all 13 `phys3d_events` rows**
  (12 prior + the arm it added), not only the two new ones. I wrote the two
  missing bodies (and, on the evidence below, the fallback and the shared
  sweep they need) rather than re-implementing the landed parent arms.
- **F2 (would have failed the new cell deterministically, fixed).** The
  arriving `jolt_threaded` parent pins `jt_threaded=true`, but no child body
  produced that key; and the shared child fetch at the deferred `_run()`
  position is **refused under Jolt+threaded at this fixture size, 10/10
  reps** (§3.1). Without a fetch fallback the child would print
  `CHILD_NOTE jt dss_null=true` and exit 1 → parent `child mismatch`. Fixed by
  a bounded physics-frame retry in the shared child body.
- **F3 (classification, kept).** The arriving Dummy child body was to be
  `_child_jolt` with a `dummy_` key prefix, but `dummy_backend` was pinned
  `"Dummy"` while the inherited backend expression could only ever print
  `"Jolt Physics"`/`"unexpected"` (it never tested the Dummy server class).
  Fixed in the arm, not in the expectation: the backend witness is now a
  3-way ClassDB test (r85-scout §2.1 / directive 5), so
  `dummy_backend=Dummy` is a real positive witness and a silent backend
  fallback still fails loudly.
- Everything else in the arriving diff was kept: the four parent arms, the
  `_spawn_child` fold, the `_engine_hint_has` gate, and the total `--child`
  dispatch. The parent-side code is byte-unchanged by me except the three
  `CASES` rows it needs.

---

## 1. Declared move

Three cells on the landed `phys3d_events.gd` battery, plus the deferred V2
fold:

1. **`jolt_threaded`** — generated child carrying BOTH
   `3d/physics_engine="Jolt Physics"` AND `3d/run_on_separate_thread=true`;
   pins whether the backend split `{same-signature | differs-constants |
   inverts}` holds identically under the threaded stepper, and pins a
   threading witness so a silently-nonthreaded child fails loudly.
2. **`dummy_refused`** — negative control: the SAME reduced sweep under
   `physics_engine="Dummy"`; every arm must classify `unexpected` (zero/silent
   reads never earn a known-class label), proving the split is backend-real
   rather than a map coincidence.
3. **`srv_phase_delta`** (stretch) — `PhysicsServer3D.body_set_state` writes
   vs the node-position writes of `phase_delta`: do they land on different
   tier boundaries?
4. **V2 fold** — `_spawn_child` (already landed) + `_child_split`: the third
   and fourth child-spawn sites justify single-sourcing the reduced sweep, so
   a class difference between the three child receipts can never be a
   difference in the sweep code.

Files changed (worktree, **uncommitted** — the integrator commits):

    corpus/fixtures/phys3d_events.gd   +519/−146   (1196 → 1263 lines)
    corpus/fixtures/run_battery.py     +6          (188 → 191 CASES rows)

---

## 2. Review of the landed fold and the child paths (item 1 of the brief)

`_spawn_child` was reviewed against the two arms it replaced, behavior by
behavior — all five r84 folds survive:

| fold | threaded_edge (r84 → r85) | jolt_edge (r84 → r85) |
|---|---|---|
| total `--arm` dispatch | unchanged (`--arm=threaded_edge` passed explicitly) | unchanged |
| stale-log unlink | `DirAccess.remove_absolute(logpath)` before spawn | same call site |
| timeout-KILL | `timeout -s KILL 30` | same |
| SCRIPT ERROR / Parse Error scan | unchanged | unchanged |
| ObjectDB-leak WARNING scan | unchanged | unchanged |
| `ERROR:` whitelist | `allow_inaccessible=true` (refusal class only) | `allow_inaccessible=false` (any `ERROR:` is a defect) |
| missing-log path | `_fail("threaded_edge child log missing")` — identical text via `{"err"}` | `_fail("jolt_edge child log missing")` |
| verdict compare | `last` line exact (`spawned["last"]`) | 7-key map exact (`spawned["verdicts"]`) |

The strongest available check that the fold is behavior-preserving is that the
**r84 `jolt_edge` child receipt is byte-identical to the frozen HEAD receipt**
(§4.3) and the r84 row's stdout/stderr are byte-identical (§4.2).

---

## 3. Per-arm claims with measured values

### 3.1 `jolt_threaded` — the split IS threading-invariant; the *fetch* is not

Child map, `corpus/live/r85-author/runs/…192404847004Z/scratch/joltthrproj/child.log`
(sha256 `33632fd07bccbdc712bc348a1061c0f0aeb17eb0407c79725b1193c1387b7aeb`):

    CHILD_RESULT jt_threaded=true
    CHILD_RESULT jt_backend=Jolt Physics
    CHILD_RESULT jt_dss_class=JoltPhysicsDirectSpaceState3D
    CHILD_RESULT jt_isect=same-signature
    CHILD_RESULT jt_cast=differs-constants
    CHILD_RESULT jt_btm=differs-constants
    CHILD_RESULT jt_contact_stale=same-signature
    CHILD_RESULT jt_static_nopair=inverts

The `jolt_edge` child log (non-threaded Jolt, same run) is **byte-identical
modulo the key prefix** — including every solver constant, not only the
classes:

| raw field | jolt_edge (non-threaded) | jolt_threaded |
|---|---|---|
| `cast safe/unsafe` | `0.149841 / 0.150024` | identical |
| `btm t0` | `-0.998535` | identical |
| `contact_stale` | `set=0,1 in=0,1,4 out=4,0` | identical |
| `static_nopair` | `tp=0,0,1,1,1,1,1,1 delta=1 mv=1,1,1` | identical |
| `isect` | `s0=1 m0=0 away=0 n1=0 back=1` | identical |

**Answer to the assigned question: the backend split is invariant under the
threaded stepper at the map *and* constant level.** Two independent controls
bound that claim:

- **Threading negative control** — the *same* `jolt_threaded` child body in a
  non-threaded Jolt project (`corpus/live/r85-author/ctl_jolt_nothr/`, rc 0,
  **0 diagnostic lines**) prints `CHILD_RESULT jt_threaded=false` with the
  *same five classes*. The witness therefore discriminates, and the split is
  not a function of the witness.
- **Backend negative control** — `jolt_edge` body in the same non-threaded
  Jolt project prints the same map (so the threaded/non-threaded pair is not
  confounded with the engine key).

**The fetch is the real finding.** The shared child body's deferred `_run()`
fetch is refused under Jolt+threaded at this fixture size:

| probe | measurement |
|---|---|
| deferred position-B `direct_space_state` fetch | **refused, 10/10 reps** (`ERROR: Space state is inaccessible` attributed to `_child_split`) |
| threading witness (12 idle-frame `space_get_direct_state` fetches) | **11/12 refusals** (not 12/12) |
| same witness, non-threaded Jolt control | **0/12 refusals** (0 diagnostics) |
| arm verdict after the bounded retry | **13/13 reps rc=0 PASS**, byte-identical markers |

So the r85-scout §1.4 size ladder ("≥638 script lines grants the fetch") does
**not** reproduce for the child process at 1263 lines; the arm passes because
of the bounded physics-frame retry, and the `>=8 of 12` witness tolerance is
load-bearing (a strict `==12` pin would be flaky at 11/12). Both are
documented in the fixture.

Pinned marker (exact, from the run):

    PASS phys3d_events jolt_threaded backend=Jolt threaded=true isect=same cast=constants btm=constants contact_stale=same static_nopair=inverts child_exit=0

### 3.2 `dummy_refused` — every arm `unexpected`; the split is backend-real

Child log (`…/scratch/dummyproj/child.log`, sha256
`b7ecd80a9ce87ff7a2a8da2b773286fd028c4f622c1c7fdbb859c632cfd774dd`), **0
diagnostic lines**:

    CHILD_NOTE dummy_class=false godot_class=false engine=Dummy
    CHILD_RESULT dummy_backend=Dummy
    CHILD_RESULT dummy_dss_class=PhysicsDirectSpaceState3DDummy
    CHILD_RESULT dummy_isect=unexpected
    CHILD_RESULT dummy_cast=unexpected
    CHILD_RESULT dummy_btm=unexpected
    CHILD_RESULT dummy_contact_stale=unexpected
    CHILD_RESULT dummy_static_nopair=unexpected

- **All five arms are `unexpected`** — no known-class label is earned from
  zero/silent reads. Raw evidence: `isect s0=0 m0=0 away=0 n1=0 back=0`;
  `cast degenerate sizes=0,0,0` (the r84-critic size guard fires, no
  unguarded index); `btm r0=false t0=0.000000 …`; `contact_stale
  set=0,0 in=0,0,0 out=0,0`; `static_nopair tp=0,0,0,0,0,0,0,0 delta=-1
  mv=0,0,-1`.
- The cell is double-armed: `dummy_backend=Dummy` is the registry witness
  (ClassDB server trio, mutually exclusive 6/6 per r85-scout §2.1) and
  `dummy_dss_class=PhysicsDirectSpaceState3DDummy` is the live-object
  witness. Note `jolt_class=false godot_class=false` here — the trio gate is
  what names Dummy at all.
- **The negative control is exactly as strong as claimed**: the same sweep
  code produced `same-signature/differs-constants/inverts` under Jolt and
  `unexpected ×5` under Dummy, so the split tracks the backend, not the sweep.
- Determinism 3/3 rc=0, 0 diagnostics, ~1.7–1.9 s (case timeout 20 s). No
  threaded Dummy path is armed anywhere (r85-scout §2.3 rc-137 hang).

Pinned marker:

    PASS phys3d_events dummy_refused backend=Dummy isect=unexpected cast=unexpected btm=unexpected contact_stale=unexpected static_nopair=unexpected child_exit=0

### 3.3 `srv_phase_delta` — the write PATH is not a tier, the write PHASE is

The arm pins the tier boundary with an exact-frame assertion
(`srv_log != ["0@%d" % (f0 + 2)]` / `["0@%d" % (f1 + 1)]`), so the marker is
earned, not claimed. Raw frames, measured first-hand with an instrumented
scratch copy of the landed arm (`corpus/live/r85-author/scratch_probe/`),
3/3 identical:

| phase of the `body_set_state` write | write at frame | enter callback at | delta |
|---|---|---|---|
| process phase | `f0=5` | `7` (`0@7`) | **2** |
| process phase (dissolve) | `fexit=7` | `8` (`1@8`) | **1** |
| physics phase | `f1=13` | `14` (`0@14`) | **1** |

So a **raw server write lands on the same tier boundaries as the node-position
writes of the r84 `phase_delta` cell** (`proc_delta=2 phys_delta=1`,
byte-identical values). The monitor must be the server-level
`area_set_monitor_callback`: a raw server RID carries no instance id, so a
node `Area3D`'s `body_entered`/`get_overlapping_bodies` cannot resolve it
(recorded in the arm comment as the r85 measurement that forced this design).
Determinism 3/3 rc=0, 0 diagnostics, ~0.9 s.

Pinned marker:

    PASS phys3d_events srv_phase_delta srv_proc_delta=2 srv_phys_delta=1

### 3.4 V2 fold — one sweep, three child bodies

`_child_jolt` / `_child_jolt_threaded` / `_child_dummy` are now three-line
wrappers over `_child_split(prefix)`; the sweep body (geometry, constants,
classifiers, size guards, cleanup) exists once. The r84 `jolt_edge` child log
is **byte-identical to the frozen HEAD receipt** (§4.3), which is the evidence
that the fold did not rot the landed arm.

---

## 4. Verification

### 4.1 Battery ×2, all PASS

    python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
      --runs <abs>/corpus/live/r85-author/runs \
      --probe-failing --probe-crash-exit --probe-stream-attribution \
      --probe-tree-timeout            (cwd = the live worktree)

- Run 1 `runs/20261014T192404847004Z/verdicts.json`: **PASS**, `totals:
  cases=191 pass=191 fail=0 ordinary=145 negative_controls=46`, 4/4 probes ok
  (`crash_probe_ok`/`stream_probe_ok`/`tree_probe_ok` true, mutation probe
  PASS), `seeds_unchanged=true`, `godot_version`
  `4.7.2.stable.arch_linux.ed1daf0bf`.
- Run 2 `runs/20261014T192747715686Z/verdicts.json`: **PASS**, same totals and
  probes; **all 191 `(case, verdict, exit, marker)` tuples identical to
  run 1**; both child logs identical modulo the scratch path.

### 4.2 Prior 188 rows byte-identical to the HEAD receipts

Against the r85-baseline freeze (`runs/20261014T182310632331Z/verdicts.json`,
commit `ac025b2`, same host/build):

    prior-188 tuple sha256  bab5dc6f2f4b4d322048acd8b5c6c35d3ba8e124be09cffeb2da66a5987a5ac3
    frozen-188 tuple sha256 bab5dc6f2f4b4d322048acd8b5c6c35d3ba8e124be09cffeb2da66a5987a5ac3

- `results[0:188]` **identical, at identical positions** (not merely an
  ordered subsequence); exactly **3 inserted rows at indices 189–191**;
  `postcommit_verify_godot_188.py` reports `ordered-subsequence PASS
  (188/188)`, `rows at identical positions: 188/188`, `inserted/new rows: 3`,
  no DRIFT line.
- Stronger per-row check on the 12 prior `phys3d_events` cases: **stdout and
  stderr byte-identical** to the frozen receipt for all 12 (including
  `jolt_edge`, `threaded_edge`, `static_nopair` at exit 2).

### 4.3 Child receipts

- `scratch/joltproj/child.log` (r84 `jolt_edge` child):
  `cmp` **IDENTICAL to the frozen HEAD run's copy**, sha256
  `2f9900fd84990de3cabd298ef123a61f917e4c6e487dedd1b9ec1aeb97f98582` —
  byte-identical in both of my runs too.
- `scratch/thrproj/child.log` (r84 `threaded_edge` child): identical text
  **except the embedded backtrace line numbers** of the expected refusal
  ERRORs (`_child_threaded` `:776` → `:936`), i.e. an address shift from the
  lines added above it — the r84 precedent's "documented child-log delta"
  class. Message text and structure unchanged.
- `scratch/joltthrproj/child.log`, `scratch/dummyproj/child.log`: the two new
  receipts quoted in §3.

---

## 5. Risks, unpinned drift, and what is NOT claimed

1. **The fetch fallback is load-bearing, and its mechanism is inference.** The
   deferred position-B fetch is refused 10/10 under Jolt+threaded at 1263
   lines, contradicting the r85-scout §1.4 ladder for the child process; the
   retry (bounded at 8 physics frames) is what makes the cell pass. *Why* the
   window is refused here is not isolated. Bounded claim: the retry makes the
   arm deterministic on this build/host; a future engine change to fetch
   legality inside a physics-frame continuation would surface as a named
   `jt dss_null=true` + exit 1, never as a silent wrong map.
2. **The witness is 11/12, not 12/12** (one idle-frame continuation was
   granted inside the loop). The `>=8 of 12` tolerance mirrors the landed
   `threaded_edge` arm and is deliberately not tightened. The witness proves
   the child's main loop is in the threaded configuration; it does **not**
   prove the physics thread is stepping the world (a hypothetical
   "refusing-but-not-stepping" state would pass). Not falsified here.
3. **Fixture size hazard** (r85-scout §1.4). Handled both ways, documented:
   the fixture grew (1196 → **1263** lines; every edit additive), *and* the
   child-side fetch now has an explicit bounded guard. The parent-side
   position-B fetch remains size-dependent only for a **threaded parent
   project**, which the battery never runs (seed `project.godot` is
   non-threaded, default engine).
4. **Dummy × threading is unmeasured and deliberately unarmed** — the Dummy
   server silently hangs a threaded child (scout §2.3, rc 137). No r85 arm
   takes that path; `dummy_refused` is non-threaded by construction.
5. **`srv_phase_delta` monitors at the server level only.** The node-level
   monitor path is not armed (a raw server RID has no instance id); the
   area-level query→area contrast the scout flagged (§5.3) is still open.
6. **Exit-code blindness is unchanged** (r84 residual): Godot `OS.execute`
   returns 0 when the shell itself is SIGKILLed. Bounded as before by
   timeout-KILL + stale-log unlink + exact verdict-map compare — and now by
   the `jt_threaded` witness, which is a map key rather than an exit code.
7. **Constants are build-scoped.** `0.149841/0.150024`, `-0.998535`,
   `in_n1_c == 4` are Jolt's solver constants on this build, exactly as in
   r84; a Jolt version bump fails loudly via the map compare.
8. **Unpinned drift:** the r85-scout's four missing query surfaces
   (ray/point/collide_shape/rest_info), the `node_write_query` contrast, and
   the area-query contrast remain unarmed. `jolt_threaded` pins one child
   geometry per arm (1 rep per arm, 13 reps of the whole arm) — not a
   multi-geometry sweep.

---

## 6. Evidence index, scratch, write scope

- Battery receipts: `corpus/live/r85-author/runs/20261014T192404847004Z/` and
  `…/20261014T192747715686Z/` (`verdicts.json`, `scratch/`, child logs,
  `mutation-verdicts.json`).
- Manual arms + controls: `corpus/live/r85-author/scratch/` (13 jt reps, 3
  dummy, 3 srv, prior-arm replays), `ctl_jolt_nothr/`, `ctl_thr_nothr/`
  (threading controls), `scratch_probe/` (instrumented `srv_phase_delta`
  frames). The dead seat's own scratch (`out/`, `proj_*`, `r85_probe.gd`) is
  left in place as prior evidence.
- Scratch total **3.8 MB** (`du -sh corpus/live/r85-author`), all under the
  gitignored `corpus/live/`; nothing deleted, nothing cleaned into a claim.
- **Landed bytes verified** (the state both battery runs measured):
  `corpus/fixtures/phys3d_events.gd` sha256
  `4bcde2bf39cd829887b7cea9da41fe6c3a528cbbfd9f62900b44c30c6db72355` (1263
  lines); `corpus/fixtures/run_battery.py` sha256
  `991c6c8ac39a58a576dd9d1e1cc4d922a996dc9b978c9a5f435d325c2666add5` (191
  CASES rows). A final fresh-copy replay of `--arm=srv_phase_delta` from those
  bytes prints the pinned marker at rc 0.
- **Write scope honoured:** only `corpus/fixtures/phys3d_events.gd`,
  `corpus/fixtures/run_battery.py`, `corpus/live/r85-author*/`, and this
  report. `git status --porcelain` = the two fixture files modified +
  `reports/round-85/` (pre-existing, untracked) + `reports/round-86/`
  (not mine, untouched). **No commit, no push, no git mutation** — the
  worktree diff is left in place for the integrator.

## 7. Bounded claim

On Godot `4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`, 60 tps, on this
host, with the Jolt/GodotPhysics3D/Dummy backends of this build: the r84
backend split is **threading-invariant** (identical classes *and* solver
constants under `run_on_separate_thread`), the split is **backend-real** (a
Dummy negative control earns no known class from zero reads), and the
server-write event tier is a function of the **write phase** (proc → 2,
physics → 1), not of the write path. Prior 188 rows byte-identical at
identical positions; 191/191 PASS twice. No claim above extends past this
build, this host, the named project variants, and the arms as landed.
