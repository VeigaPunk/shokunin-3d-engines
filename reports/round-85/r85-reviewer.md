# game-dev-3d round 85 — reviewer (seat: reviewer, host: devin)

Post-commit verification of **`f230443`** (`r85: backend cross-product — jolt_threaded
+ dummy_refused + srv_phase_delta`), independent of the author/scout/boundary
reports. Every number below was re-derived from the commit's own bytes; no count
is inherited from a sibling seat.

**Runtime (every bound is scoped to this):** `/usr/bin/godot`
`4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`, 60 tps, this host, Python
3.14.7. HEAD `f230443`; worktree clean
(`git diff f230443 -- corpus/` empty; both fixture blobs sha-identical to the
worktree files).

**LSP unavailability recorded, first-hand.** `mcp_list_servers` exposes only
`rea` (Ghidra binary analysis) — no `lsp` device answers this repo, so no
`references`/`definition`/`diagnostics` request was possible. Nothing below is
presented as semantic proof. The substitute is stronger than grep for this file:
Godot's GDScript compiler resolves the whole script at reload (v1 of this round
proved that — a single undefined `_child_*` call made *every* arm dead with
`Parse Error`), so the fact that all 15 `phys3d_events` arms and all 4 `--child`
bodies run to their authored verdicts is engine-level resolution of the whole
symbol set, and the four `--child` bodies were each executed explicitly rather
than inferred.

**Write scope honoured.** `reports/round-85/r85-reviewer.md` +
`corpus/live/r85-reviewer/` (gitignored via `corpus/.gitignore:1`). No tracked
file touched, no git mutation, no subagent, no second runtime: `run_battery.py`
was the only judge invoked.

---

## 1. Replay — 191/191 PASS, exit 0 (assigned item 1)

```
python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
  --runs <abs>/corpus/live/r85-reviewer/runs/20261014T193426106570Z \
  --probe-failing --probe-crash-exit --probe-stream-attribution --probe-tree-timeout
```

| receipt | verdict | totals |
|---|---|---|
| `runs/20261014T193426106570Z/20261014T193426134676Z/verdicts.json` | **PASS** | `cases=191 pass=191 fail=0 ordinary=145 negative_controls=46 probes=4` |
| `runs/only-193913/13/…` (`--only` = the 10 r83 arms + the 3 new) | **PASS** | `13/13` |
| `runs/only15-193948/…` (`--only` = all 15 `phys3d_events` rows) | **PASS** | `15/15` |

`crash_probe_ok`/`stream_probe_ok`/`tree_probe_ok` = true, mutation probe PASS,
`seeds_unchanged=true`, `godot_version` = `4.7.2.stable.arch_linux.ed1daf0bf`,
battery exit **0**.

**Exact new case names** (read from `CASES`, not from a report): the three new
rows are appended immediately after `phys3d_events_jolt_edge` and are
`phys3d_events_jolt_threaded`, `phys3d_events_dummy_refused`,
`phys3d_events_srv_phase_delta` (`run_battery.py:443-448`). The `phys3d_events`
family is **15** rows, not 13: the 12 prior rows are the 10 non-spawning arms
(isect, cast, btm, pp_queries, contact_stale, contact_sig, sync_cb, srv_area_cb,
static_nopair, phase_delta) plus the two child-spawning arms (threaded_edge,
jolt_edge). The assignment's "10 phys3d cases" is the r83 README reproduce line
(`corpus/fixtures/README.md:563`), which names exactly those 10.

**Cross-seat determinism (stronger than the report's ×2).** The author's run 1
(`20261014T192404847004Z`), the author's run 2 (`20261014T192747715686Z`) and my
replay are three independent 191-case runs: their `(case, script, flags,
expected_exit, actual_exit, verdict, marker)` tuple lists are **pairwise
identical** (`author1 == author2 == reviewer` → `True`).

## 2. Prior-row stability — 188/188, byte-level (assigned item 2)

Reference: `corpus/live/r85-baseline/runs/20261014T182310632331Z/verdicts.json`
(188 rows, `ac025b2`, frozen extract). I first proved the reference *is* the
`ac025b2` fixture tree rather than trusting the report: for every entry in its
`seed_digests`, `sha256(git show ac025b2:corpus/fixtures/<name>)` matched —
**0 mismatches over the 55-file map**.

| check | result |
|---|---|
| rows at identical positions (`results[0:188]`) | **188/188** |
| prior-188 tuple sha256 (baseline) | `987878f427ed315f41e0c6068b6ceafb3455e3bff75b1d68bd99596cfe07878f` |
| prior-188 tuple sha256 (my replay) | `987878f427ed315f41e0c6068b6ceafb3455e3bff75b1d68bd99596cfe07878f` |
| inserted rows | exactly 3, at indices 189–191 |
| prior 12 `phys3d_events` rows, stdout **and** stderr | **byte-identical** (12/12, no differing case) |
| `seeds_unchanged` | `true` |

My projection includes `kind` in addition to the author's four fields, so my hash
differs from the report's `bab5dc6f…`; the equality result is the same and is
re-established here under a projection defined in
`corpus/live/r85-reviewer/verify_prior188.py` (output
`verify_prior188.out.txt`), not in the report.

**Child receipts (re-measured, not re-read).** My replay's `scratch/joltproj/child.log`
is `cmp`-IDENTICAL to the frozen HEAD run's copy, sha256
`2f9900fd84990de3cabd298ef123a61f917e4c6e487dedd1b9ec1aeb97f98582` (the author's
cited sha, verified against the file). `scratch/thrproj/child.log` is
text-identical to the frozen copy modulo the embedded backtrace frames
(`res://phys3d_events.gd:776` at HEAD → `:936` here, i.e. the address shift from
the lines added above it; message text and structure unchanged).
`scratch/dummyproj/child.log` sha256 `b7ecd80a…` is **identical to the author's
cited sha and to my own run's** (that log carries no absolute path, so the
digest is path-independent — an exact cross-run byte match on a new receipt).

## 3. Diff audit (assigned item 3)

`git diff --numstat ac025b2 f230443 -- corpus/fixtures/` → `phys3d_events.gd`
**+373/−146**, `run_battery.py` **+6/−0**. The commit touches exactly three files
(the two fixtures + `reports/round-85/r85-author.md`), so no other surface
(bpy/three.js/Node) is affected by construction; `bpy_battery.py` is a sibling
runner that never reads `run_battery.py`.

**"Insertion-only" is true for the CASES rows and for prior *behaviour*, and
false for the fixture source — which is the honest reading.** `run_battery.py`'s
6 added lines are exactly the three 2-line CASES rows appended after
`phys3d_events_jolt_edge`; no prior row text is touched. `phys3d_events.gd` has
146 real deletions, and I classified all 103 deleted non-comment lines:

- the two inline spawn/scan sites (`threaded_edge` and `jolt_edge` at
  `ac025b2`) — variables, the three `_fail` texts, the log scan, `jolt_avail`;
- the `_child_jolt` body's `prints(...)` lines, replaced by
  `<prefix>`-parameterized versions in `_child_split`.

**No deleted line is prior-arm logic, classifier branch, geometry, `await`
sequence, or marker text.** Mechanically confirmed: every
`_exit_ok("PASS phys3d_events …")` string present at `ac025b2` is present
*verbatim* at `f230443` (`comm -23` empty) and exactly three new ones are added.

**`_spawn_child` preserves each named invariant** (landed `phys3d_events.gd`
lines cited):

| invariant | landed evidence |
|---|---|
| total child dispatch | `:313-325` — `match` with `var bad:` default → `CHILD_RESULT child_arm=unknown arm='<x>'` + `quit(2)`; parent-side `_:` → `_fail("unknown arm " + arm)` |
| stale-log unlink **before** spawn | `DirAccess.remove_absolute(logpath)` at `:211`, immediately before `OS.execute` at `:212` |
| `timeout -s KILL 30` wrapper | `:204-207` |
| SCRIPT ERROR / Parse Error scan | `:224` |
| ObjectDB-leak scan (`"ObjectDB" in line and "leaked" in line`) | `:226` |
| `ERROR:` whitelist gate | `:228-231` |
| error-path texts preserved | `:193/:196/:216` reproduce the unfolded texts exactly (`"%s cannot make %s err=%d"`, `"%s cannot write child project"`, `"%s child log missing"`) |

**`allow_inaccessible` does not bleed.** The four call sites are
`threaded_edge` → `true` (`:638-640`), `jolt_edge` → `false` (`:741-743`),
`jolt_threaded` → `true` (`:780-782`), `dummy_refused` → `false` (`:815-817`):
true **exactly** on the two arms whose generated child project carries
`3d/run_on_separate_thread=true`, false on both non-threaded arms. Measured
consequence: the jolt-only child log has **0** `ERROR:` lines and the dummy child
log **0**, while the threaded children have 12 (jt) and 11 (threaded_edge) — so
the flag is load-bearing where it is set and inert where it is not.

## 4. `jolt_threaded` — the pinned values are measured, 5/5 (assigned item 4)

The arm re-run by hand five times in a generated `Jolt + run_on_separate_thread`
parent project: **5/5 rc 0** with the exact pinned marker, and every rep's child
log is **65 lines with 11 witness refusals + 1 retry refusal**:

```
PASS phys3d_events jolt_threaded backend=Jolt threaded=true isect=same
  cast=constants btm=constants contact_stale=same static_nopair=inverts child_exit=0
```

| pinned key | measured value | witness |
|---|---|---|
| `jt_threaded` | `true` | `nulls=11 >= 8` over 12 idle-frame `space_get_direct_state` fetches (`:1003-1007`); 11 ERROR lines attributed `[0] _child_jolt_threaded …:1004` |
| `jt_backend` | `Jolt Physics` | `ClassDB` trio |
| `jt_dss_class` | `JoltPhysicsDirectSpaceState3D` | live object |
| `jt_isect` / `jt_cast` / `jt_btm` / `jt_contact_stale` / `jt_static_nopair` | `same-signature` / `differs-constants` / `differs-constants` / `same-signature` / `inverts` | raw `CHILD_NOTE` fields in the log |

The 12th refusal line is the retry fetch at `_child_split:1028` (called from
`:1008`), not a 12th witness iteration. **This resolves the one thing that looks
like a stale number in the landed fixture:** the comment at `:998` says
"(r85 author probe: 12/12 null on Jolt+threaded, 0/12 on DEFAULT)" while the
landed arm measures 11/12. It is an **accurate citation of the dead seat's probe**,
not a stale claim — `corpus/live/r85-author/out/probe_joltthr.stdout.txt` and
`probe2_joltthr.stdout.txt` both print `PROBE proc_nulls=12of12`, and
`probe_def.stdout.txt` prints `0of12`. The report's §3.1 documents the arm's own
11/12 and the `>= 8 of 12` tolerance; the two instruments differ, both numbers
are true. No defect.

## 5. Pin-earnedness — no pin is satisfied by an absent key (assigned item 5)

Mechanical, not by eye: `_child_split` prints exactly **seven** `<prefix>_*` keys
(`backend`, `dss_class`, `isect`, `cast`, `btm`, `contact_stale`,
`static_nopair`); `_child_jolt_threaded` adds `jt_threaded` at `:1007`; no other
`CHILD_RESULT` key exists on those paths. The expect maps are `7/7` (jolt_edge),
`8/8` (jolt_threaded), `7/7` (dummy_refused) and the comparison is **exact
dictionary equality** (`spawned["verdicts"] != expect_*`) — an absent key cannot
satisfy a pin, and a *surplus* key fails too (a forged extra key is exactly what
my forge cell A plants).

**Both halves of the `jolt_threaded` pin are independently load-bearing** —
verified with the two counterexamples the report does not contain:

| child project | `jt_threaded` | backend keys | outcome |
|---|---|---|---|
| Jolt + threaded (the arm's project) | `true` | Jolt split | PASS |
| **Jolt, not threaded** | **`false`** | **identical Jolt split** | map passes, witness fails |
| **DEFAULT + threaded** | **`true`** | **`jt_backend=unexpected`, `jt_dss_class=GodotPhysicsDirectSpaceState3D`, DEFAULT class map** | witness passes, map fails |
| Dummy | `false` | all `unexpected` | both fail |

So neither half is decorative: the witness is the *only* key that catches a
silently-ignored `run_on_separate_thread` (the rest of the map is byte-identical
without it), and the map is the *only* thing that catches a silently-ignored
engine key (the witness is `true` without it).

**`dummy_refused` is a real negative control, not a sweep coincidence** — the
*same child body* under three projects: Jolt → `same-signature /
differs-constants / differs-constants / same-signature / inverts` under
`dummy_*` keys; DEFAULT → `same-signature ×5`; Dummy → `unexpected ×5` with
`dummy_cast degenerate sizes=0,0,0` (the r84 size guard fires, no unguarded
index). Its parent map is the only gate, as boundary §3 says.

**`srv_phase_delta`'s marker is earned by exact-frame assertions**, not by a
literal: `srv_log != ["0@%d" % (f0 + 2)]` (process-phase write),
`has("1@%d" % (fexit + 1))` (dissolve), `srv_log != ["0@%d" % (f1 + 1)]`
(physics-phase write), each with its `size()` conjuncts. 3/3 hand reps + battery
PASS. The absolute frame numbers in the report's §3.3 table are illustrative;
the three deltas are asserted in the landed arm.

**Total dispatch re-measured** on the child path: `--child --arm=nosucharm` →
rc **2** + `CHILD_RESULT child_arm=unknown arm='nosucharm'`; bare `--child` →
rc 2 + `arm=''`; `--child --arm=isect` (a parent-only name) → rc 2 + unknown.
All three, on the landed bytes.

## 6. Adjudication of the boundary findings (assigned item 6)

**#5 — the `LEAKED_OBJECTDB` singular hole: CONFIRMED, and it is the battery's,
not the fixture's.** Landed `run_battery.py:468-470` requires
`[1-9][0-9]* ObjectDB instances were leaked` (plural `instances were`).
Direct evaluation of that exact pattern: `WARNING: 1 ObjectDB instance was leaked
at exit (run with \`--verbose\` for details).` → **no match**;
`WARNING: 12 ObjectDB instances were leaked at exit …` → match. The engine's
singular form is therefore invisible to the battery's leak scan. The finding is
pre-existing (identical at `ac025b2:462-464`) and outside f230443's diff (the
battery change is `+6/−0` CASES rows), and the **parent mirror is wider** —
`("ObjectDB" in line and "leaked" in line)` catches both forms — so the three new
arms' *children* are protected; the blind spot is only on a case process's own
stream. Smallest fix: `instances? (was|were) leaked`. **Citation nit:** boundary
cites `run_battery.py:462`, which is the `ac025b2` line; the landed line is
**468** (the 6-line CASES insertion shifted it).

**#6 — `allow_inaccessible` admits 12 lines, one of which is not the witness:
CONFIRMED by my own count.** In my replay's `scratch/joltthrproj/child.log`:
12 `ERROR: Space state is inaccessible …` lines = **11** with backtrace
`[0] _child_jolt_threaded (…:1004)` + **1** with `[0] _child_split (…:1028)`
(called from `:1008`) — i.e. the arm's own retry fetch, a second site the
whitelist was not written for. The allowance is narrow by text and unbounded by
count/position/source; the `>= 8 of 12` witness is a lower bound and cannot
detect extra refusals. Bounded and disclosed; not a defect today.

**#7 — the Dummy type hazards: confirmed latent, and not this diff's.** They live
in `PPQueries._physics_process` (unguarded `cast_motion()[0..1]`) and
`_child_threaded` (`body_get_state` `Nil` → typed `Transform3D` assignment),
both untouched by f230443 (all 103 deletions are elsewhere), and unreachable from
any landed parent arm (no Dummy parent exists in the battery). Boundary's
finding stands; the round's own `dummy_refused` arm does not close it.

**#4/#12/#13** are reproduced above (forge cells re-run on the *new* arms in §7;
12/12 prior byte-identical; 15/15 canonical battery on the current candidate).

## 7. Forge and error paths on the **new** arms (boundary tested the r84 arms)

| cell | pre-state of `joltthrproj/child.log` | rc | result |
|---|---|---|---|
| A | forged full `expect_jt` map **plus** `jt_forged_extra=1` | 0 | PASS; forged content gone (fresh 65-line log) |
| B | same forge + `chmod 400` | 0 | PASS; forged content gone — the unlink destroys the artefact before the redirect, so an unwritable file cannot survive in the redirect-failure family |
| C | path is a non-empty **directory** | 1 | `ERROR: phys3d_events: jolt_threaded child log missing` |
| D | same cell, `dummy_refused` | 1 | `ERROR: phys3d_events: dummy_refused child log missing` |
| E | read-only project dir | 1 | `ERROR: phys3d_events: jolt_threaded cannot make joltthrproj err=20` |

All five are named failures or clean passes; none silently passes. Cell C's
message is *misleading* (the path exists, as a directory) — a diagnostics nit,
not a hole. `DirAccess.remove_absolute`'s return value is still ignored, which is
safe for the same reason the cells show: every way the unlink can fail also fails
the redirect or the `project.godot` write.

Also measured: `--arm=srv_phase_delta` under a **Dummy parent** → rc 1 with the
named reason `srv_phase_delta proc drift w0=0 n1=0 n2=0 log=[]` — no hang, no
silent pass.

---

## Findings

### F1 — `corpus/fixtures/README.md` still states the pre-r85 battery count, and the round has no README section (medium: tracked documentation contract; no behaviour impact)

`README.md:5` reads *"later rounds extend the battery to **188 registered cases
(142 ordinary and 46 negative controls)**"*. The landed battery registers
**191 (145 ordinary, 46 negative controls)** — my replay's own totals line, and
`git show f230443:corpus/fixtures/README.md` still carries the old number.

This is a maintained contract, not prose: `a56f683` (the r84 fold) explicitly
changed this line and its commit message names the change — *"Simplifier V3:
… **README case count corrected to 188**"* — and there is a standalone precedent
commit `6202ae5 game-dev-3d r56: correct battery count in README`. At
`ac025b2 → f230443` the line moves 83 → 188 → 188, i.e. the r85 arm did not carry
it. The r83 and r84 arms each also added a per-round README section (r83 at
`:561-597` with the 10-name reproduce line at `:563`; r84 at `:599-626` with
`--only phys3d_events_phase_delta,phys3d_events_jolt_edge` at `:601`); no r85
section exists, so the three new cells have no reproduce line in the fixture
README.

Smallest safe correction (one diff, no fixture change): `188 registered cases
(142 ordinary` → `191 registered cases (145 ordinary`, plus an r85 section with
`--only phys3d_events_jolt_threaded,phys3d_events_dummy_refused,phys3d_events_srv_phase_delta`
in the r83/r84 shape. Per the r83→r84 precedent this may legitimately land in the
fold commit; it is open at `f230443`.

### F2 — `r85-author.md` §6 cites manual-rep receipts that are not retained (medium-low: provenance / reproducibility)

§6 says *"Manual arms + controls: `corpus/live/r85-author/scratch/` (13 jt reps,
3 dummy, 3 srv, prior-arm replays), `ctl_jolt_nothr/`, `ctl_thr_nothr/`
(threading controls), `scratch_probe/` (instrumented `srv_phase_delta` frames)"*.
Retained tree, measured: `scratch/` holds **one** fixture copy + the four
generated child project dirs (one `child.log` each — last write wins, so it
cannot evidence 13 reps); `ctl_jolt_nothr/` and `ctl_thr_nothr/` hold only
`phys3d_events.gd` + `project.godot`; `scratch_probe/` holds only the instrumented
fixture copy + `project.godot`. `find corpus/live/r85-author -maxdepth 2 -type f
\( -name '*.txt' -o -name '*.exit' -o -name '*.json' \) | grep -v /runs/` returns
**only** the dead seat's `out/probe*.{stdout,stderr}.txt`. So the counts
"13/13 reps", "3/3", the two threading controls' "rc 0 / 0 diagnostic lines", and
the §3.3 frame table are assertions without retained receipts.

**No claim is falsified** — I re-derived every one of them independently (§4, §5,
§7: 5/5 jt reps, 3/3 dummy, 3/3 srv, both controls, 11+1 refusal accounting, the
exact-frame assertions) — but the report's evidence index overstates what a
successor can re-check from the tree. The two *battery* runs are properly
receipted and re-verified. Smallest correction: retain per-rep stdout/exit files,
or cite only receipted runs.

### F3 — `r85-author.md` §5.4 generalises the Dummy×threading hang beyond what was measured (low: report rationale)

§5.4: *"the Dummy server silently hangs a threaded child (scout §2.3, rc 137)"*.
Measured counterexample: `--child --arm=dummy_refused` inside a project carrying
**`3d/physics_engine="Dummy"` and `3d/run_on_separate_thread=true`** exits **0**
cleanly (15-line log, 0 diagnostics) with the same five `unexpected` verdicts and
`dummy_backend=Dummy`. The rc-137 class belongs to the `_child_threaded` /
`PPQueries` bodies (the two type hazards in boundary #7), not to Dummy×threading
as such. Consequence for planning: a threaded Dummy cell is *feasible* for the
shared split body, so "deliberately unarmed" is a scope decision, not a forced
constraint. The landed fixture is not defective — no threaded Dummy path is armed
— and the scout's directive (§6.3) that produced this choice was itself scoped to
the `threaded_edge` body.

### F4 — two diagnostics nits in the new spawn path (low)

1. The `"<arm> child log missing"` message is emitted when the log path exists
   but is a **directory** (cells C/D above) — accurate class, misleading text.
2. `DirAccess.remove_absolute`'s return value is ignored (safe; cells A/B/C/E).

Both are comment-or-nothing fixes; neither is a hole.

### F5 — boundary's `run_battery.py:462` is the `ac025b2` line (info)

The landed line is `468` (the 6-line CASES insertion shifts it). The finding
content is unaffected; recorded so the next seat does not chase a line that no
longer exists.

## Residual risk and verification gaps

1. **The witness is a lower bound.** `nulls >= 8 of 12` cannot detect extra
   refusals and cannot distinguish 8/12 from 12/12; a hypothetical
   "refusing-but-not-stepping" threaded state would pass. Disclosed by the author;
   not falsified here. Measured rate is stable at 11/12 in every run where I
   counted the split (7: the battery replay, the 5 hand reps, and the first
   standalone hand-run) and in both author battery runs.
2. **`allow_inaccessible` is by-text and unbounded** (12 admitted lines, 1 of
   them a different site). A genuine fixture bug that illegally fetches from the
   same wrong position inside a threaded child is invisible. A cheap tightening
   (print `jt_refusals=<n>` and pin a band) remains available.
3. **The bounded fetch retry is load-bearing and its mechanism is inference.**
   If the window never opened, the child bails named (`CHILD_NOTE jt dss_null=true`,
   exit 1) and the parent fails on `code != 0` — never a silent wrong map.
4. **Build-scoped constants/classes.** `0.149841/0.150024`, `-0.998535`,
   `JoltPhysicsDirectSpaceState3D`, `PhysicsDirectSpaceState3DDummy`, and the
   refusal message text are this build's. The refusal message is *not* keyed on
   the `at:` file path — measured: `jolt_physics_server_3d.cpp:234` under Jolt vs
   `godot_physics_server_3d.cpp:194` under DEFAULT+threaded — which is why the
   text-keyed whitelist is the right choice, and also why it is version-fragile.
5. **Boundary #7 stays open** (latent Dummy type hazards in `_child_threaded` /
   `PPQueries`); not introduced by f230443, not reachable from any landed parent
   arm.
6. **Threaded parent-side fetch legality is size-dependent** (scout §1.4); the
   battery never runs a threaded *parent* project, so the landed parent arms are
   insulated.
7. **Not verified by me, by scope:** the bpy (Blender) and three.js suites, and
   the per-round LOG/SCORECARD entries. The commit's file list (3 files) makes
   them unreachable from this diff; that is the evidence, not an omission.
8. **Single host, single build, `--headless`, 60 tps.** Every claim above is
   scoped to `/usr/bin/godot 4.7.2.stable.arch_linux.ed1daf0bf`.

**Canonical-runtime / identity / saturation statement.** One judge was invoked:
`corpus/fixtures/run_battery.py` (the only executable consumer of
`phys3d_events.gd`; `bpy_battery.py` never reads it; the diff adds no runner, no
route, no fallback). No rerouting or identity construct exists in the diff, so
same-identity rerouting is not applicable. Saturation is not a concept in this
battery; the closest analogues are checked instead — the `BLOCKED` branches are
reachable but unexercised on this build (honest build gate, fail-loud on the
battery rather than a silent pass) and no case is skipped, padded, or
short-circuited (`--only` selects by exact name and fails on an unknown name).

**Zero-mutation statement (the analogue of a failed-preflight rule).** No resume
or preflight path exists in this diff. The substitute property, verified on the
canonical run logic: `run_battery.py` hashes the seed tree before and after and
fails if any seed changed; `seeds_unchanged=true` in all three runs, the fixture
writes only `res://<dirname>` inside the scratch copy, and
`git status --porcelain -- corpus/fixtures` is empty after all of my runs — a
failing arm (`_fail` → cleanup → `quit(1)`) leaves no partial seed mutation and
no partial verdict claim.

**Seat output complete.** Evidence: `corpus/live/r85-reviewer/` — 3 battery
receipts (`runs/`), 30 hand-run/forge receipts (`hand/*.out.txt` + per-cell
project trees), 5 drivers (`verify_prior188.py`, `handrun.sh`, `controls.sh`,
`forge.sh`, `selfcheck.py`), `controls.out.txt`, `forge.out.txt`,
`verify_prior188.out.txt`. **Every headline number above is machine-re-derived**
by `selfcheck.py` straight from the artefacts (191/145/46 totals, 188-row
positional identity, the three inserted rows, the child-log digests and the
11+1 refusal split, the four `allow_inaccessible` call sites, the 191 CASES
count, the README count line, the regex singular/plural behaviour): **29 checks,
0 failed** (`selfcheck.out.txt`).
`git status --porcelain` at report time = the sibling seats' untracked reports
only; **no tracked-file edit, no git mutation by this seat.** This is a seat
recommendation, not an admission.
