# game-dev-3d round 83 — reviewer (seat: reviewer, host: devin)

Reviewed artifact: commit `e9145d9` ("r83: PhysicsServer3D two-tier lattice …"),
landed 2026-10-14T16:57:26Z. Worktree at review time = HEAD `e9145d9`, clean
for `corpus/` (`git status --porcelain corpus/` empty), so the tree I replayed
is the tree I reviewed. `git show --numstat e9145d9`:

| path | +/- |
|---|---|
| `corpus/fixtures/README.md` | 28 / 0 |
| `corpus/fixtures/phys3d_events.gd` | 597 / 0 (new) |
| `corpus/fixtures/run_battery.py` | 20 / 0 |
| `reports/round-83/r83-author.md` | 222 / 0 |

Blob hashes (on-disk == `git show e9145d9:<path>`, both verified):
`phys3d_events.gd` sha256 `6ddf4aefde97d31673f337699ba1dedbe9e6caf4226917225577a36b8ac4fab3`;
`run_battery.py` `0381b7500d5e1b270fcab6d0e42d3d4682edbd96c9c9f29058ac7f0a9bf0f1f2`;
`README.md` `20115e923337c4a4f74daf6a1bd87247b384667fcda8b46a2df4af6fecf84830`.

Runtime: single canonical Godot `/usr/bin/godot` = `4.7.2.stable.arch_linux.ed1daf0bf`
(the only Godot on PATH; no `GODOT_*` env reroute surface), headless, 60 tps,
battery scratch project.

**LSP note (recorded unavailability).** No `lsp` device on this substrate — MCP
inventory is `rea` only (a Ghidra/RE server; no language-server capability), so
`references`/`definition`/`diagnostics` could not be requested for
`phys3d_events.gd`/`run_battery.py`. Caller/definition/diagnostic checks below
are **text-level** (read/grep/execution), explicitly not semantic proof. The
diagnostic surrogate is stronger than grep here: the battery's classifier
rejects any `SCRIPT ERROR:`/`Parse Error:`/`ERROR:` line on either stream and
any ObjectDB leak warning (`run_battery.py:487-514`), and the fixture loads and
runs, so it is parse-clean.

## Replay on the committed tree (the primary evidence)

```
python3 corpus/fixtures/run_battery.py \
  --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r83-reviewer/runs
```
→ `PASS battery: corpus/live/r83-reviewer/runs/20261014T165831902068Z/verdicts.json`,
process exit **0**; `verdict=PASS`, `seeds_unchanged=true`, 186 results
(140 ordinary + 46 negative), 186/186 PASS, `case_timeout_seconds=20`.
Full stdout: `corpus/live/r83-reviewer/replay-full.stdout.txt`.

Cross-checks against the author's two receipts
(`corpus/live/r83-author/runs/20261014T164612500349Z`, `…165207093423Z`):

- all 186 rows: stdout **byte-identical**, verdict and `actual_exit` identical
  across the two seats' runs (three independent full batteries total);
- `seed_digests` map identical (55 seed files) — the same seed set is hashed
  before and after in both runs;
- the author's `--only` subset receipt `…164604096927Z` = 10 results, 10 PASS,
  `only=` exactly the 10 new names.

## Verified claims (no actionable defect found)

1. **Pure insertion / prior 176 byte-identical.** Verified three ways:
   (a) `git show --numstat` shows 0 deletions anywhere in the commit;
   (b) byte reconstruction — `run_battery.py` current == prior with a single
   1725-byte block inserted at offset 45202 (inserted-block sha256
   `4845da2d5a96253fbf55f45e9a136fd66cb7614cb55f91054c7f50b04d8cc7f0`),
   reconstruction == prior exactly;
   (c) row-wise via the reused dead-seat tool
   `corpus/live/r83-reviewer/tools/cases_compare.py` → *"prior rows
   byte-identical as ordered subsequence: YES (176/176), inserted rows: 10"*.
   Same for `README.md`: removing the inserted lines 561-588 reproduces the
   prior blob byte-for-byte (sha `130c7bccedc75d74` both sides); single hunk
   `@@ -558,6 +558,34 @@`, 28/0.
2. **Behavioral invariance of the insertion.** The dead seat's pre-landing run
   `corpus/live/r83-reviewer/baseline-godot/20261014T160726979288Z` (tree
   `f8a088c`, 176 results = 131 ordinary + 45 negative, all PASS) matches my
   post-landing replay on **all 176** rows (stdout, verdict, rc identical,
   0 differing, 0 missing). The commit changes nothing observable in the
   pre-existing battery.
3. **Markers are earned, not claimed.** Every one of the 10 new CASES markers
   equals an in-fixture `print`/`_exit_ok` literal (`run_battery.py:419-438` ↔
   `phys3d_events.gd:231,253,281,302,336,379,405,441,492,537`), and every field
   in every marker is gated by a failing assertion before the print — e.g.
   `isect` gates `s0==1 and m0==0` (:217) before `away/away_n1/back` (:228);
   `contact_stale` gates the setup `c==0, isect==1` (:316) then
   `0/1/4` (:325) then `4/0` (:333); `srv_area_cb` requires the exact frame
   string *and* `sig_log.size()==1|2|3` (:430,:434,:438); `static_nopair`
   requires the negative *and* the positive control `mv_delta==1` (:487);
   `threaded_edge` requires `code==0`, no SCRIPT/Parse error in the child log,
   and the child's verdict line to equal the expected string exactly (:534).
   No marker prints an ungated value.
4. **Partition pins match raw stdout lines.** The measured partition is exactly
   as reported: query tier edge-0 (`isect` both directions `away_w0=0`,
   `back_w0=1`; `cast` `w0=1.000000`; `btm` `w0_hit=false`; `pp_queries`
   in-callback `isect=0 safe=1.0 btm=false`) vs event tier delta-1
   (`contact_sig delta=1`; `srv_area_cb` enter/exit/reenter each at
   `f+1`; `sync_cb` `0→1→3` once per tick, static `0`; `contact_stale`
   stale `0→4` in and `4→0` out). The two-tier split is measured *inside one
   fixture family on one backend*, and the brief's grouping correction
   (`body_test_motion`/`cast_motion`/`intersect_shape` are tier-0, not
   generated events) is supported by the pins, not asserted.
5. **ST cells are legal and non-vacuous.** The child's query path forces the
   fetch *inside* `_physics_process` (`phys3d_events.gd:561` sets `w.dss=null`;
   `:163-167` fetches and retries), and a permanently-null fetch leaves
   `printed=false` → `result_ok()==false` → `CHILD_RESULT pp_edge0=false` →
   parent `_fail` (:534). `proc_dss_refused` is a genuine witness of the
   conversion: the non-threaded parent never sees refusals, so `nulls>=8` can
   only come from `run_on_separate_thread=true` taking effect. `srv_ok`
   independently proves the child's world/space is live (it reads back the wall
   transform *the child itself moved* at :168-170 and runs `body_test_motion`),
   so the nulls are the access-window gate, not a dead world. My replay's child
   log (`runs/20261014T165831902068Z/scratch/thrproj/child.log`): 11 ERROR lines,
   all `Space state is inaccessible right now, wait for iteration or physics
   process notification.` (`godot_physics_server_3d.cpp:194`), plus
   `CHILD_NOTE early_null=false` and `CHILD_RESULT pp_edge0=true
   proc_dss_refused=true srv_ok=true`.
6. **The null-DSS hazard is not silent in this fixture.** `_contacts()` returns
   **-1** (not 0) when `body_get_direct_state` is null (`:105-107`), so the
   `in_w0_c=0` pin cannot be satisfied by a null read; and the query arms'
   setup assertions require a *hit* before the write (`:217`, `:316`), so a
   blind handle cannot masquerade as "query tier blind". Measured under a
   forced-null mutation — see F3.
7. **`static_nopair` is a real negative on the pinned backend.** The control
   move (`area.position = WALL_FAR` then back, `:478-482`) fires `body_entered`
   at `f_mv+1`, which *also* proves the teleported static body really is at
   `Vector3.ZERO` — otherwise the control could not fire. So "no pair" is not a
   setup artifact on GodotPhysics3D. (It is backend-dependent — F1.)
8. **Timeout headroom.** New rows' `elapsed_seconds` = 0.4-1.1 s against
   `CASE_TIMEOUT_SECONDS = 20` (`run_battery.py:36`); the child's own waits are
   bounded (30 physics frames at `:295`/`:564`, 12 `process_frame` fetches at
   `:571-575`).

## Findings

### F1 (MEDIUM) — the Jolt gate is answered in prose but not pinned in the fixture; 7/10 rows silently re-bind and the `static_nopair` negative *inverts* under Jolt

The brief ordered the backend gate **first**, and the author answers it first in
the report (`r83-author.md:32-53`; I re-read the receipt
`corpus/live/r83-author/runs/probe1.stdout.txt:4,8,11-15` —
`physics_engine setting = DEFAULT`, `class JoltPhysicsServer3D = false`,
`PSM method: register_server` / `set_default_server` and no other method),
correctly: `ClassDB.class_exists("JoltPhysicsServer3D")` false under DEFAULT,
`GodotPhysicsServer3D` true, hint string `DEFAULT,Jolt Physics,GodotPhysics3D,Dummy`,
`PhysicsServer3DManager` has no enumeration API. But **no cell in
`phys3d_events.gd` checks the backend**: `grep -n "class_exists\|physics_engine\|Jolt" corpus/fixtures/phys3d_events.gd`
matches only the header comment (`:5-8`). The pinned cells therefore do not bind
the configuration they claim to describe.

Measured consequence — I ran the committed seeds with one line added to a
*copy* of `project.godot` (`3d/physics_engine="Jolt Physics"`; copy at
`corpus/live/r83-reviewer/x-jolt/seed`, seeds untouched; the setting demonstrably
took effect because three rows changed behaviour):

| case | DEFAULT (committed) | Jolt Physics (same seeds) |
|---|---|---|
| isect, pp_queries, contact_stale, contact_sig, sync_cb, srv_area_cb, threaded_edge | PASS | **PASS (silently re-bound)** |
| cast | PASS | FAIL (`cast settled fractions drift`, constants) |
| btm | PASS | FAIL (`btm setup wrong`, constants) |
| **static_nopair** | PASS (negative rejected) | **FAIL: `static_nopair drift tp=true ov=1 mv=true delta=-3`** |

Receipts: `corpus/live/r83-reviewer/x-jolt/jolt-only.log` +
`x-jolt/runs/20261014T170109780306Z/verdicts.json`; reproduced 3/3
(`x-jolt/runs-rep1`, `x-jolt/runs-rep2`, identical diagnostic). `tp=true ov=1`
means the teleported **STATIC** body *did* produce the area pair under Jolt — the
cell's semantics invert, they do not merely shift by a solver constant. This is
new information: the author's Jolt replication list (`r83-author.md:140-148`)
does not include `static_nopair`, yet the report's summary sentence
(`r83-author.md:52-53`) and `README.md:585` ("same lattice, different solver
constants") generalise over it, and `README.md:576` states the negative as a
proven rule ("proves the generated-event tier only re-pairs movers") without the
backend qualifier that the measurement now demands.

Why this is a defect and not a nit: a battery-wide or host-level default change
flips 1 row's *meaning* and re-binds 7 rows' meaning with no named diagnostic
(the 2 rows that do fail report a constant drift, not "wrong backend"). Minimal
fix (author's call): a `_run()` preamble asserting
`ProjectSettings.get_setting("physics/3d/physics_engine")` is absent/DEFAULT and
`ClassDB.class_exists("GodotPhysicsServer3D") and not class_exists("JoltPhysicsServer3D")`,
failing with a named reason; and either drop `static_nopair` from the
"same lattice" sentence or state "refuted under Jolt (`tp=true ov=1`)".
Corroboration that the pinned backend is what the pins were measured on: my
replay and both author receipts agree byte-for-byte on DEFAULT.

### F2 (MEDIUM) — `threaded_edge` spawns its child with no timeout envelope; a hung child leaks an orphan process tree and costs the full 20 s case timeout

`phys3d_events.gd:514-518` builds `sh -c "<godot> … > <log> 2>&1"` and calls
`OS.execute` with no timeout, and the battery's timeout kills only the direct
child (`run_battery.py:474` `subprocess.run(..., timeout=…)`). Reproduced with a
*scratch copy* whose `_child_threaded` hangs (seeds untouched):
`corpus/live/r83-reviewer/x-hang/orphan-evidence.txt` — the battery reports
`FAIL phys3d_events_threaded_edge … ['TIMEOUT after 20 seconds', 'no exit code']`,
and 3 s after the battery process exits the `/bin/sh` → `/bin/sh` → `godot`
chain is **still alive** (reparented to ppid 1203171, 3 processes; reaped by me
with `pkill -f x-hang`, 0 survivors after). The author already names this hazard
class for probes (`r83-author.md:175-179`: "every probe needs either a quit on
all paths or a `timeout -s KILL` envelope") and applies it nowhere inside the
fixture — this child invocation is the one place in the landed diff that lacks
it. Impact is resource hygiene, not verdict correctness (the case still FAILs;
the orphan writes only inside the run's scratch, and the seed digest is computed
over `corpus/fixtures/`, so no verdict is corrupted). Minimal fix: prefix the sh
command with `timeout -s KILL 15`.

### F3 (LOW) — no explicit `dss != null` assertion: the scout's §5.3 directive is met by the harness classifier, not by the fixture, and costs a 20 s hang

Scout blockage (`r83-scout.md:185-196`): the deferred-`_run()` capture point is
phase-dependent, and `dss.intersect_shape` on a null handle reads like a
legitimate "query blind" row. Directive: *"Any ST arm must therefore assert
`dss != null` … and fail loudly"*. The landed fixture asserts it nowhere
(capture at `:206`, child capture at `:549`).

Forced-null mutation (copy at `corpus/live/r83-reviewer/x-nulldss/seed`,
`dss = null` injected at the capture site; seeds untouched),
`x-nulldss/runs/20261014T170001563837Z/verdicts.json`:

- `isect` → `SCRIPT ERROR: Cannot call method 'intersect_shape' on a null value.`
  at `phys3d_events.gd:215` → `_run()` never reaches `quit` → **TIMEOUT after
  20 seconds** (loud, but by hang, with a 20 s cost and no named reason);
- `contact_stale` → `SCRIPT ERROR` in `_floor_isect_hits` (`:102`) → the setup
  assertion trips → named `_fail` `contact_stale setup c=0 isect=0`, exit 1;
- `pp_queries`, `contact_sig`, `sync_cb` → **PASS** (they never touch the
  captured handle; `pp_queries` falls back to the legal in-callback fetch) —
  correct, no silent false negative.

So the requirement "a null handle must not silently read as no-hit" **is**
satisfied in this fixture (no arm can pass with a null handle), but the loudness
is inherited from `classify()` rather than asserted. The committed configuration
is not exposed (scout measured the capture legal 36/36 arms; my two batteries
agree), hence LOW. A `dss != null` guard at `:206`/`:549` converts a 20 s
timeout into an instant named failure.

### F4 (LOW) — `threaded_edge` cannot distinguish the counted refusals from any other child-side engine ERROR

The parent's log scan (`phys3d_events.gd:522-529`) rejects only `SCRIPT ERROR`
and `Parse Error`; any other `ERROR:` line in the child log is tolerated *by
design* (the 11 refusal errors must not fail the case). Nothing is hidden today —
my replay's child log contains exactly the 11 refusal lines, the `CHILD_NOTE`,
and `CHILD_RESULT` (verified by `grep -v ERROR:` over the log) — but a child-side
regression emitting a different engine error would pass the case. Defense in
depth: require the refusal text count `>= 8` and reject any ERROR line whose text
is not the refusal string.

### F5 (LOW) — README claim precision (landed text, `README.md:561-588`)

- `:567` "answer in the same turn as a `body_set_state` write, **in both
  directions**": both directions is measured only for `intersect_shape`
  (`isect`: `away_w0=0` *and* `back_w0=1`). `cast` (`:244-252`) and `btm`
  (`:269-280`) measure the away direction only; no "back to hit" cell exists.
- `:572` "`Area3D.body_entered`/`body_exited` … each land exactly one tick after
  their triggering write": node-level **`body_exited` is not measured anywhere**
  in the fixture (`grep -n "body_exited"` matches only the header comment `:3`);
  the delta-1 exit is measured at the *server* level (`srv_area_cb` status `1@f1+1`).
- `:576` + `r83-author.md:52` "only re-pairs movers" / "same lattice, different
  solver constants" — see F1 (falsified for the negative cell under Jolt).

### F6 (LOW) — dead store `tries` in `PPQueries`

`phys3d_events.gd:146` `var tries := 0`, `:162` `tries += 1`, never read (the
retry bound is the caller's deadline at `:295`/`:564`). Same class the r81/r82
simplifier folds removed. It is the only unused binding I found — I checked
`printed`, `travel_z`, `sig_log`, `owned`, `owned_nodes`, `mk`, `early`,
`early_null`, `wspace`, `_frames`, `WALL_FAR`, `_sphere_params.motion`.

## Residual risk and verification gaps

- **Backend cross-product**: Jolt × `run_on_separate_thread` unprobed (author's
  own gap). F1 raises its value: at least one cell's *semantics* invert across
  backends, so "backend-invariant" is not a safe default for unprobed arms.
- **`proc_dss_refused` threshold** `nulls >= 8` (`:576`): 11/12 in my replay's
  child log, 11/12 ×3 in the author's, 149/150 in boundary's stress. A regime
  with >4 legal fetches flips it; the claim says "majority", not absolute, and
  the marker hides the count (the raw log is the witness).
- **`in_n1_c=4`** is solver-specific (`max_contacts_reported=8` → observed 4);
  the pin asserts the tick, not the value's universality. Stable across 3 full
  batteries on this host.
- **`static_nopair` scope**: pinned for area↔static monitor pairs on
  GodotPhysics3D only; body-body contact pairs unprobed (author), and F1 shows
  the area class is backend-dependent.
- **`early_null`** is racy and deliberately unpinned (`CHILD_NOTE` only); my
  replay 1/1 `false`. Correctly not a pin.
- **Not re-verified by me**: the author's live-only Jolt receipts
  (`corpus/live/r83-author/runs/jolt_*`, `proj_jolt/`) and the sibling receipts
  they cite (scout/boundary). I verified the Jolt question by re-running the
  *battery rows* against a Jolt project copy, which is the stronger test for the
  gate question but does not re-execute their live probe scripts.
- **Host bound**: this container, `/usr/bin/godot`
  `4.7.2.stable.arch_linux.ed1daf0bf`, headless, 60 tps, battery scratch; no
  claim extends beyond it. Sibling seats were running batteries concurrently
  during my replay (CPU contention observed) — the byte-identical agreement with
  the author's earlier receipt shows no contention effect on these rows.
- **No `lsp`**: caller/definition/diagnostics are text-level, not semantic proof
  (see the LSP note above).

## Evidence index

- Replay (committed tree): `corpus/live/r83-reviewer/runs/20261014T165831902068Z/verdicts.json`,
  `…/scratch/thrproj/child.log`; stdout `corpus/live/r83-reviewer/replay-full.stdout.txt`.
- Insertion proofs: `git show --numstat e9145d9`;
  `corpus/live/r83-reviewer/tools/cases_compare.py` (dead-seat tool, reused and
  independently re-derived in-session); README lines 561-588 removal test.
- Pre/post invariance: `corpus/live/r83-reviewer/baseline-godot/20261014T160726979288Z/verdicts.json`
  (dead-seat pre-landing 176 PASS) vs my replay.
- F1: `corpus/live/r83-reviewer/x-jolt/{jolt-only.log, runs/, runs-rep1/, runs-rep2/}`.
- F2: `corpus/live/r83-reviewer/x-hang/{orphan-evidence.txt, runs/, runs-rep/}`.
- F3: `corpus/live/r83-reviewer/x-nulldss/runs/20261014T170001563837Z/verdicts.json`.
- Author receipts cross-checked: `corpus/live/r83-author/runs/{20261014T164612500349Z,
  20261014T165207093423Z, 20261014T164604096927Z}`.

All scratch writes are confined to `reports/round-83/r83-reviewer.md` and
`corpus/live/r83-reviewer/`; the three seed fixtures are byte-unchanged
(`sha256sum` re-verified after every mutation experiment; mutations were applied
only to copies). Leaf seat: no subagent dispatch, no git mutation, no
integration, no verdict. Findings above are recommendations; the canonical
runtime remains the only judge.

**Seat output complete.**
