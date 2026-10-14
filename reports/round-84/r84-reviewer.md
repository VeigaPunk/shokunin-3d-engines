# game-dev-3d round 84 — reviewer (seat: reviewer, host: devin)

Wave `shokunin-train-20261101-w15`, lane `g3d`, arm `g3d-r84` (Godot backend
pinning). **Post-commit verify** of HEAD `01f7d4f` ("r84: backend pinning —
jolt_edge child re-exec + phase_delta first-class cell"), tree state
`git status --porcelain` = the three untracked sibling reports only
(`r84-boundary.md`, `r84-scout.md`, `r84-scribe.md`); every tracked byte below is
the committed tree.

Read: the commit diff (4 files, `+617/−6`), `reports/round-84/{r84-author,
r84-scout,r84-boundary,r84-scribe}.md`, the landed fixture and battery.

Runtime (every bound below is scoped to this): `/usr/bin/godot`
`4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`, 60 tps, this host;
`python3` 3.14.7.

**LSP unavailability recorded (checked this seat, not inherited):**
`mcp_list_servers` exposes only `rea` (Ghidra binary analysis) — no `lsp` device
serves this repo, so no `references`/`definition`/`diagnostics` request could be
made against `phys3d_events.gd`. Every symbol-level statement below is therefore
either engine-measured (Godot run receipts) or text-level (read/grep/`ast`), and
is **not** presented as semantic proof. Caller enumeration was done by
text-level repo-wide grep for `phys3d_events` / `--child` (hits only:
`run_battery.py` CASES, `corpus/fixtures/README.md`, `LOG.md`, `SCORECARD.md` —
no other executable caller of the fixture exists in-tree).

Leaf seat: no subagents, no git mutation, no fixture edit. Writes:
`corpus/live/r84-reviewer/` (gitignored via `corpus/.gitignore:1`) +
this report.

Scope note: this lane carries no UFO runtime, no registry/queue, and no resume
path, so the seat-card items "one canonical runtime", "same-identity rerouting"
and `resume_continuity_v1` have no counterpart here. The nearest analogue — a
single judge and no fabricated verdicts — is checked as claim 8 below.

## Recommendation (not an admission)

The commit's claims verify on the committed tree: **188/188 replay, seeds
unmodified, prior 186 rows byte-identical to the r83 anchor, insertion-only,
and the two new pins are earned (independently reproduced, including their
negative and impersonation controls).** Three Low-severity guard/diagnosability
items remain (F1–F3); none of them can produce a false PASS on the tracked row,
so none blocks admission. They are one-line folds for the next round.

## Findings by severity

### F1 — Low: a child-side **ObjectDB-only** leak is invisible to the parent's log scan, and the row still PASSes (measured)

`jolt_edge`'s parent scans `child.log` for `ERROR:` / `SCRIPT ERROR` /
`Parse Error` only (`corpus/fixtures/phys3d_events.gd:701-707`). Godot's two leak
witnesses are not symmetric: the RID-leak line begins `ERROR:`, but the
ObjectDB-leak line is a `WARNING:` on the child's stderr.

Measured, two injected children (both under a Jolt project, one line appended to
a scratch copy of `_child_jolt` at the end of the reduced sweep):

| injected defect | child.log tail | parent stdout / exit | tracked `classify()` |
|---|---|---|---|
| `PhysicsServer3D.box_shape_create()` un-freed | `ERROR: 1 RID allocations of type 'P11JoltShape3D' were leaked at exit.` | `_fail` → exit 1, no marker | **FAIL** (exit 1 + missing marker) |
| `var _leak_node := Node.new()` un-freed | `WARNING: 1 ObjectDB instance was leaked at exit` | **PASS marker printed, exit 0** | **passed=True, reasons=[]** |

Receipts: `corpus/live/r84-reviewer/scratch/out/proj_leakrid.{stdout,stderr,exit}.txt`,
`…/proj_leakobj.{stdout,stderr,exit}.txt`, child logs
`corpus/live/r84-reviewer/scratch/proj_leak{rid,obj}/joltproj/child.log`; the
`classify()` verdicts above were produced by importing the tracked classifier
from `corpus/fixtures/run_battery.py:491` and feeding it the captured streams.

So the RID half of the boundary's leak claim is confirmed end-to-end (boundary
§2.4/§8.6: "a leak is FAIL-class and lands on *stdout* as well as stderr"), but
the guard is not exhaustive: `classify()` itself rejects `LEAKED_OBJECTDB`
(`run_battery.py:516`), while the new parent-side scan does not mirror it.

Not reachable on today's paths — every landed child path calls
`_cleanup_nodes()`/`_cleanup_rids()` (verified: the tracked-path child.log has
**0** `ERROR:`/`WARNING:` lines and 6 `CHILD_RESULT` lines, sha256
`4b8c0e881cc70ff5a7f14684853ab0e4fbacb155ecd503fe1b28e564ba76dfbb`), and the
early-bail `dss == null` path cleans up too (`:804-810`). It is a
guard-coverage gap: a future edit that leaks a Node (not a RID) in the child
would be banked green. Fold: add the leak-warning arm to the parent scan,
mirroring the classifier's `LEAKED_OBJECTDB` regex.

### F2 — Low: `cast_motion()` is indexed without a size guard in the new child body; on a size-0 backend the child dies by kill (exit 137) instead of classifying (measured)

`_child_jolt` reads `c0[0]`, `c0[1]`, `c1[0]`, `c1[1]`, `c2[0]`, `c2[1]`
(`corpus/fixtures/phys3d_events.gd:841-848`) with no length check. Under a
`physics/3d/physics_engine="Dummy"` project the same child body aborts:

```
SCRIPT ERROR: Out of bounds get index '0' (on base: 'PackedFloat32Array')
          at: _child_jolt (res://phys3d_events.gd:847)
CHILD_RESULT jolt_isect=differs-constants   # last line before the abort
```

exit **137** (harness `timeout -s KILL`), parent stderr carries the SCRIPT ERROR
and the backtrace, and the tracked classifier returns
`passed=False` — receipts
`corpus/live/r84-reviewer/scratch/out/proj_dummy.{stdout,stderr,exit}.txt`.

This is exactly the hazard r84-boundary §3 measured and recommended against
("`cast_motion()` returns a **size-0** `PackedFloat32Array` on this backend …
Any arm indexing `cast_motion()[0..1]` needs the size guard"), and the
recommendation is not folded in the landed child. Consequences, precisely:
the failure stays **loud** (exit != 0 + SCRIPT ERROR scan → FAIL, never a
fabricated PASS), but the class is a kill/hang rather than the documented
"`unexpected` (outside both signatures — fails loudly, named)" classification,
and a hung child is the orphan-class shape (see residual risk R2). Reachability
is off the tracked path only: the parent writes `physics_engine="Jolt Physics"`
verbatim into the generated project, and all three real backends I probed return
a size-2 array. Pre-existing analogue (not introduced here): the parent `cast`
arm indexes `c0[0]` unguarded at `:266-267` under a project the battery never
sets to Dummy.

### F3 — Low: the scout's phase-witness directive (#8) is not folded; a delta=1 failure cannot distinguish "phase slipped" from "latency changed"

`grep -c is_in_physics_frame corpus/fixtures/phys3d_events.gd` = **0**. The
`phase_delta` arm places its process-phase write on the `await process_frame`
continuation (`:610-628`) and never asserts the phase it actually wrote from,
although r84-scout §3 measured `Engine.is_in_physics_frame()` as present on this
build and an exact phase witness, and directed ("Author directives … 8"): "The
`phase_delta` arm can therefore **assert its own write phase** instead of
trusting the await idiom — a silent phase slip would otherwise turn the cell
into an unexplained delta=1."

The pin itself is still earned, not claimed: the arm requires
`w0_fired/n1_fired/n2_fired` + overlap counts **and** `proc_delta == 2` in one
cell against the physics-phase contrast `left == 0 … phys_delta == 1`
(`:622-648`), and a phase slip fails named. The gap is diagnostic: r84-boundary
§6b measured that a *legitimate* process-phase write reads `delta_pf = 1` in a
different loop position, so on such a drift the failure text
(`phase_delta proc-phase drift … delta=1`) would not tell the reader which of
the two happened. My own 6 reps of the arm (3 DEFAULT + 3 Jolt) all read
`proc_delta=2`, so the landed construction is stable today.

### Nits (non-blocking, recorded for evidence hygiene)

- `r84-author.md` cites `_child_jolt()` as `(:791-1003)`; the function ends at
  `:1001` (file length 1001). Other cited ranges I checked are exact:
  `phase_delta` `:576-649`, `jolt_edge` `:651-721`, backend pin `:794-803`,
  `_exit_ok` `:649`/`:721`, mismatch gate `:718`. The BLOCKED branch is
  `:661-669` (report says `:660-669`).
- `corpus/fixtures/README.md:5` ("extend the battery to 83 registered cases") is
  stale — but **pre-existing and carried** (LOG.md:598 records it as an
  unchecked stale top-level instruction), untouched by r84, and the new r84
  section introduces no case-count claim, so r84 neither fixes nor worsens it.

## Verified claims (each with its receipt)

**1. Battery replay — 188/188, seeds unmodified.**
`python3 corpus/fixtures/run_battery.py --runs
/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r84-reviewer/runs-battery1`
→ `totals: cases=188 pass=188 fail=0 ordinary=142 negative_controls=46`,
`verdict=PASS`, `seeds_unchanged=True`, godot
`4.7.2.stable.arch_linux.ed1daf0bf`, case timeout 20 s
(`corpus/live/r84-reviewer/battery1.log`,
`runs-battery1/20261014T175139313039Z/verdicts.json`). New rows:
`phys3d_events_phase_delta` 0.802 s and `phys3d_events_jolt_edge` 1.543 s vs the
20 s budget (~13× headroom; author reported 0.783/1.419 s — same class, jitter).
My run's `seed_digests` map is identical to the author's run-1 map.

**2. Prior 186 rows byte-identical / insertion-only — verified at three levels.**
- *Source*: `git show 01f7d4f -- corpus/fixtures/run_battery.py` is `+4/−0` at
  list end; `phys3d_events.gd` has exactly 5 hunks and exactly 6 deleted lines
  (3 header "Jolt live-only" doc lines, 3 `--child` dispatch lines) — no prior
  arm body touched.
- *Data*: `ast`-extracted `CASES` = 186 at `01f7d4f^`, 188 at HEAD, and
  `HEAD[:186] == prev` byte-for-byte; the two appended rows are the declared
  `["--arm=phase_delta"]` / `["--arm=jolt_edge"]` pairs.
- *Observable contract*: my 188 rows vs the r83-era full receipt
  `corpus/live/integrator-r83-fold-full/20261014T171754562593Z/verdicts.json`
  (a different commit's tree) → **0 diffs on the 186 prior rows** across
  `verdict, actual_exit, stdout, stderr, reasons, marker, expected_exit, kind`.
  My run vs both author runs (`r84-author/runs/20261014T173849346559Z`,
  `…174318041429Z`) → **0 diffs on all 188 rows** (three independent
  executions, byte-identical).

**3. `phase_delta` pin is earned, non-vacuous, and backend-invariant.**
The arm's own conjuncts force the reading: `w0_fired`/`n1_fired` false ⇒ the
signal log was empty at write and at +1 frame, so `sig_log[0] - f0 == 2` cannot
be a stale entry; the physics-phase contrast additionally requires the pair to
have dissolved (`left == 0`) before clearing the log — the r83 critic-C2 fold is
present (`:634-635`). Independent replay of the arm outside the battery, 3 reps
per backend: DEFAULT and Jolt both exit 0 with
`PASS phys3d_events phase_delta proc_delta=2 phys_delta=1`, 3/3 byte-identical
within each backend and identical across backends, stderr 0 B
(`scratch/out/proj_{default,jolt}.phase_delta.r{1,2,3}.{stdout,stderr,exit}.txt`).
This independently confirms the README's "the same deltas replicate live-only
under Jolt on this build".

**4. `jolt_edge` pins are earned — impersonation guard reproduced on four
backends.** Direct `--child --arm=jolt_edge` runs (bounded `timeout -s KILL 20`):

| project | `CHILD_RESULT jolt_backend` | arm verdicts | exit / stderr |
|---|---|---|---|
| DEFAULT (`engine=DEFAULT`) | `unexpected` | all five `same-signature` | 0 / 0 B |
| near-miss `physics_engine="Jolt"` (silent GodotPhysics fallback) | `unexpected` | all five `same-signature` | 0 / 0 B |
| `"Jolt Physics"` | `Jolt Physics` | the pinned six-entry split | 0 / 0 B |
| `"Dummy"` | `unexpected` | abort at `:847` (see F2) | 137 / SCRIPT ERROR |

The parent's expectation map is the exact six entries
(`:710-717`); DEFAULT and the near-miss both mismatch on **two** entries
(`jolt_backend` + `jolt_static_nopair`), so a silent backend fallback cannot
fabricate a PASS. Raw fields for every arm are in the child's `CHILD_NOTE`
lines, so the classes are derived from printed evidence, not asserted.
Receipts `scratch/out/proj_{default,nearmiss,jolt,dummy}.*`; child logs
`scratch/proj_*/joltproj/child.log`.

**5. `CHILD_RESULT` exactness — negative controls measured, not argued.**
- child printing a **subset** (5 of 6 results; scratch copy with the
  `jolt_contact_stale` result line removed) → parent `_fail`
  `jolt_edge child mismatch exit=0 serr=false verdicts={…}` → exit 1, no marker
  (`scratch/out/proj_subset.*`).
- child printing an injected `ERROR:` line → `serr=true` → `_fail` → exit 1
  (`scratch/out/proj_errdirty.*`). The scan is load-bearing here: all six
  results were still correct, so only the ERROR line caught it.
- extras are symmetric (dictionary equality on a 6-entry map, `:718`).

**6. RID cleanup on every reachable child path.** Tracked-path child.log
(battery scratch) and all three non-Dummy probe logs carry **0**
`ERROR:`/`WARNING:` lines; the tracked-path child.log is byte-identical
(sha256 `4b8c0e881cc70ff5a7f14684853ab0e4fbacb155ecd503fe1b28e564ba76dfbb`,
764 B) to my independent direct run — the child evidence reproduces exactly. The
RID-leak detection itself is live (F1 table). The `dss == null` bail
(`:804-810`) and the parent's `mk != OK` / `jf == null` / `lf == null` /
mismatch paths all route through cleanup (`_fail` at `:142-147`).

**7. README consistency.** The new "PhysicsServer3D backend split + write-phase
delta (round 84)" section sits ahead of `## Determinism rules for new cases`,
which remains the last section; its command path prefix matches the r83
section's convention; every quoted constant matches my measurements
(`safe 0.149841`, `unsafe 0.150024`, `travel -0.998535`); "BLOCKED rather than
fabricating", "`jolt_backend=unexpected` … would fail", and "any child-side
`ERROR:` line is a defect" are each reproduced above (the last one with F1's
scope qualifier). It introduces no case-count claim, so it does not add to the
carried README:5 staleness.

**8. Honest saturation / no fabrication.** The BLOCKED branch
(`:661-669`) prints a named line and `quit(1)` → the tracked case FAILs
(exit != expected, marker missing) rather than skipping or passing; the
impersonation, subset and ERROR-injection paths all fail named. No verdict in
this lane is produced by anything but the tracked battery + `classify()`; this
seat invokes no other runtime and makes no judgment.

## Residual risk (not findings)

- **R1 — the row is host/build-dependent by design.** On a Jolt-less build the
  hint gate fails and the case reports `BLOCKED`/exit 1: honest, but the
  battery has no skip semantics, so the 188-row all-green total is bound to a
  build with Jolt compiled in. Additionally, the availability gate reads the
  property *hint*, which r84-boundary §1 measured is invariant across all seven
  of its project variants — it proves "compiled in", never "selected". The
  load-bearing check is the child-side class assertion, which I reproduced on
  four backends.
- **R2 — inner child bound (30 s) exceeds the case budget (20 s).** On a hung
  child the battery kills the parent godot first (`subprocess.run` timeout kills
  only the direct child); the orphaned grandchild is then reaped by its own
  `timeout -s KILL 30`, i.e. up to ~10 s later. The r83-F2 fold bounds the
  orphan, it does not eliminate the window (r84-boundary §5 measured the
  orphan class for this spawn shape). Carried unchanged from `threaded_edge`.
- **R3 — the frame-counter conjunct is the fragile half of the `phase_delta`
  pin.** r84-boundary §6b measured the process-phase frame delta as 1 **or** 2
  depending on where the write lands in the main loop. The landed construction
  read 2 in all 6 of my reps and in the battery, and the arm's sample-index
  conjuncts are the robust part, but the counter conjunct adds no discriminating
  power and is the one that can flip (F3's missing phase witness is what would
  make such a flip hard to attribute).
- **R4 — `--child` dispatch is arm-keyed with an ST default.** `--child
  --arm=jolt_edge` runs the Jolt body; every other arm value silently runs
  `_child_threaded()`. r84-scout §2.1 recommended "a distinct flag (or a keyed
  dispatch)", so this is compliant, and both landed parents pass the right
  flags — but the silent-wrong-body shape survives for any future arm value.
- **R5 — the child's `jolt_backend` guard is build-scoped.** It requires
  `JoltPhysicsServer3D` present **and** `GodotPhysicsServer3D` absent; the exact
  swap is measured on this build (mine and the scout's/boundary's), but a build
  registering both would read `unexpected` and fail closed (loud, not silent).

## Verification gaps

- The **BLOCKED branch is unexecuted on this host** (the hint always contains
  `Jolt Physics`): reviewed by code read only. The nearest measured analogue is
  the near-miss spelling, which silently selects GodotPhysics — i.e. the
  *availability* check and the *selection* check are independent, and only the
  latter is measured here. No GDScript witness separates "compiled in but not
  selected" from "absent" (r84-scout §1, carried).
- The **`dss == null` bail** (`:804-810`) was not reached on any of my four
  projects (Dummy has a non-null `direct_space_state`, and it dies later at F2's
  index instead); its cleanup is code-read only.
- **`static_nopair` inversion is pinned for one latency**: the child accepts
  `inverts` only for the measured `delta=1`/`ov=1` pattern; a different Jolt
  latency classifies `unexpected` (loud, would need re-measure to re-pin). Same
  bound the author records.
- **`jolt_edge` covers five reduced arms**; `pp_queries`, `contact_sig`,
  `sync_cb`, `srv_area_cb`, `threaded_edge` under Jolt remain unprobed
  in-battery, as does the `Jolt × run_on_separate_thread` cross product.
- **Constants are geometry-scoped**: the Jolt `cast`/`btm` values are pinned on
  this one fixture geometry (sphere r=0.5, motion (0,0,−10), box half-extent 1
  at z=−3) and this build; the child's 1e-4 tolerance sits just inside the
  boundary-measured ladder (Δunsafe = 3.66e-4, a 2.7× margin — a build with
  shifted constants would classify `unexpected`, loud).
- **No cross-host, cross-build, or cross-version claim**; all timings are jitter
  and used only as bounds. The sibling receipts I read as data
  (`r84-author/runs/*`, `integrator-r83-fold-full`, `integrator-r84-verify`
  (a 2-row `--only` run)) are never treated as verdicts — every number above
  that carries a claim is re-measured by this seat or compared against my own
  run.

## Evidence index

- `corpus/live/r84-reviewer/battery1.log` — full replay transcript.
- `corpus/live/r84-reviewer/runs-battery1/20261014T175139313039Z/verdicts.json`
  — 188 rows + seed digests (sha256 `e3d08745…`).
- `corpus/live/r84-reviewer/scratch/` — 8 project variants (`proj_default`,
  `proj_jolt`, `proj_nearmiss`, `proj_dummy`, `proj_subset`, `proj_errdirty`,
  `proj_leakrid`, `proj_leakobj`), their `joltproj/child.log`, and
  `out/*.{stdout,stderr,exit}.txt` for every probe.
- `corpus/live/r84-reviewer/manifest.sha256` — 60-line digest of the above
  (transcript, receipt, every probe stream, all five child logs, and the eight
  scratch fixture copies — the four modified copies are exactly the negative
  controls named in F1/F2 and claim 5).
- Fixture at HEAD: `corpus/fixtures/phys3d_events.gd` sha256
  `255dcab56e5db479aa27e8d0cada0773c8547027cfe7e12464063d3191d536e6` (matches
  the author's claim). The four backend probes (`proj_default`, `proj_jolt`,
  `proj_nearmiss`, `proj_dummy`) carry that byte-identical copy; the four
  injected-control copies (`proj_subset`, `proj_errdirty`, `proj_leakrid`,
  `proj_leakobj`) differ only by the single disclosed line named in F1/F2 and
  claim 5, and their digests are in the manifest.

Report only; I do not judge, admit, fold, edit fixtures, commit, or ship.
Stopping here.
