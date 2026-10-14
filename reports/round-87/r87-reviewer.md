# game-dev-3d round 87 — reviewer (seat: reviewer, host: devin) — independent re-derivation of the r87 arm

Round 87 · wave `shokunin-train-20261101-w19` · lane g3d. Assignment
(`.ufo/waves/shokunin-train-20261101-w19/tasks/g3d-r87-reviewer.md`, verbatim):

> Re-run the author's claims on c57fa40 with YOUR OWN executions: 201/201
> battery, prior-195 stability (stdout+stderr bytes), the 6 new arms' witnesses
> (handle identity ==, gate refused-vs-held-live split, Jolt/GP impulse
> partition, freed-space crash classes, Dummy floor), 6/6 mutation detection,
> sibling bpy/three.js batteries. Verdict AGREE/DISAGREE per claim with
> receipts. Report -> reports/round-87/r87-reviewer.md.

Reviewed commit `c57fa40` (base `af15a52`, `r86 report-last`). Runtime
`/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`, 60 tps,
Blender 5.2.1 LTS, Node v24.21.0 / three 0.186.1, 32 cores.

**Read-only on tracked files.** Every execution and every tool this seat wrote
lives under gitignored `corpus/live/r87-reviewer/`; the only file this seat
added to the repository is this report. `git status --porcelain` at the end of
the review lists only untracked report paths — this report plus the three
sibling artifacts that were already untracked before this seat started
(`r87-baseline.md`, `r87-scribe.md`, `reports/round-88/`) — **no tracked file
was modified** and HEAD is still `c57fa40`.

**LSP unavailability recorded** (same as r85/r86/r87-scout): no `lsp` device is
exposed to this seat. No symbol-aware operation was available or needed — the
change under review is a fixture insertion, and this seat made no edits at all
(the review itself is text-level comparison plus fresh executions).

**No labrat probe dispatched.** The probeParent allowance is a bound, not a
duty: every claim below was re-derived by direct execution in this seat
(batteries, raw child logs, direct child re-runs, a purpose-written mutation
harness and a purpose-written identity probe).

**Every tool used to compare or mutate is this seat's own** — an independent
comparator (`tools/compare_rows.py`), an independent witness extractor
(`tools/extract_witnesses.py`), an independent mutation harness
(`tools/mutations.py`) and an independent identity-discrimination probe
(`tools/identity_discriminate.gd`). The author's own tools were read for intent
but never executed and never reused.

---

## Verdict table

| # | claim (author §) | verdict | my receipt |
|---|---|---|---|
| C1 | full battery 201/201 (×3) | **AGREE** | `runs-full/20261014T215230695674Z/verdicts.json` sha256 `25987af8…f7caca` — 201/201 PASS, ordinary=155, negative=46 |
| C2 | prior 195 rows byte-identical at identical positions, 6 appended | **AGREE** | three independent comparisons, 0 mismatches; plus a true pre/post pair of my own runs |
| C3a | `body_handle` identity law (`==`) + Dummy floor | **AGREE** | my raw child logs + discrimination probe (both backends) |
| C3b | `acq_use` gate refused vs held-live split, 8/8, threaded | **AGREE** | 8 engine refusal lines per child log + marker |
| C3c | `step_stamp` GP/Jolt split inside the step-stamped class | **AGREE** | my raw pre/post tokens; scout's own `ph_proj_jolt` receipt confirms the refinement |
| C3d | `write_loss` bounded race; loss not reproduced | **AGREE** (one scope note) | my run: `landed=8 lost=0`; the tally conjunct is a construction identity |
| C3e | `body_tier` GP-vs-Jolt impulse partition at the first in-contact step | **AGREE** | raw triples; M3 mutation proves the step scope |
| C3f | `freed_space` crash classes (rc disjunction, Jolt two modes, Dummy floor) | **AGREE** | direct child re-runs (rc 134) + both Jolt modes reproduced 3/3 |
| C4 | 6/6 mutation detection | **AGREE** | `mutations-20261014T220033Z.json` — `detected 6/6` |
| C5 | sibling bpy 83/83 (stdout sha frozen) + three.js 31/31 | **AGREE** | `bpy/bpy-20261014T215451557399Z` (stdout sha `6a98c570…`), `three/run_*.json` |
| C6 | the author's own receipts reproduce (audit) | **AGREE** | my comparator over the author's 4 receipts |

No claim is DISAGREE. Three non-blocking observations are recorded in §11.

---

## 1. C1 — full battery, my own execution

```
python3 corpus/fixtures/run_battery.py \
  --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r87-reviewer/runs-full
```

```
totals: cases=201 pass=201 fail=0 ordinary=155 negative_controls=46 probes=0
PASS battery: …/corpus/live/r87-reviewer/runs-full/20261014T215230695674Z/verdicts.json
```

Receipt `verdict=PASS`, `seeds_unchanged=true`, `godot_version`
`4.7.2.stable.arch_linux.ed1daf0bf`, `seed` = the live `corpus/fixtures` (the
committed bytes). The receipt's `seed_digests` map (55 files) was cross-checked
by this seat against `git show HEAD:corpus/fixtures/<name>` blobs:
**55/55 identical, 0 mismatches** — the battery measured the committed bytes,
not a stale copy.

A second, focused execution of the six new rows
(`--only phys3d_events_body_handle,…,phys3d_events_freed_space`) is
`6/6 PASS` (`runs-only87/20261014T215745466937Z`, sha256 `1ed6f301…cce3b24c`),
and the six new rows are **byte-identical between the two runs** (0 mismatches
over every stable field) — the new cells are deterministic run-to-run.

New-row wall clock in my run: 1.84 s (`write_loss`) … 5.47 s (`step_stamp`),
against the 20 s case bound — consistent with the author's 1.99–5.49 s claim.

---

## 2. C2 — prior-195 stability, three ways

Comparator: `corpus/live/r87-reviewer/tools/compare_rows.py` (this seat's own).
It compares two receipts row-for-row at identical positions over **every**
recorded field except `command` (embeds the timestamped scratch path) and
`elapsed_seconds` (wall clock) — i.e. `case, script, flags, expected_exit,
actual_exit, error, kind, marker, verdict, reasons, stdout, stderr`, with
`stdout`/`stderr` compared as their raw line lists (bytes). That is exactly the
12 fields the author declares — nothing is dropped, and no field is normalised.

| comparison | result |
|---|---|
| my run (c57fa40) vs `r86-baseline/runs-post/20261014T203735129154Z` (r86 post-commit reference) | **195/195 identical, 0 mismatches, names_identical=True**, appended = the 6 declared rows |
| my run (c57fa40) vs `r87-baseline/runs/20261014T212001121842Z` (the frozen `af15a52` receipt) | **195/195 identical, 0 mismatches**, same 6 appended |
| my run (c57fa40) vs **my own run of the pre-r87 tree** | **195/195 identical, 0 mismatches**, same 6 appended |

The third row is the strongest form: this seat extracted `af15a52` with
`git archive` (archive sha256 `91921c10c91edf935d6d3c21002bb3c67e48d5db98e16801025ba634b5b08765`
— **identical to the r87-baseline seat's frozen archive**, an independent
confirmation of the frozen tree identity), ran the full battery there
(`runs-pre87/20261014T215354772466Z`, 195/195 PASS, ordinary=149,
negative=46), and compared that pre-tree execution against this seat's
post-tree execution. The r87 diff moved **no** prior row and changed **no**
captured stdout/stderr byte.

Source-level cross-check: `git diff af15a52 c57fa40 --numstat` gives
`run_battery.py +14/−0` (one hunk at the tail, `@@ -454,6 +454,20 @@`, six rows
appended, the crash row last), `README.md +90/−0`, and
`phys3d_events.gd +876/−4` where the four deleted lines are **exactly** the
`_spawn_child` signature line and the 3-line `ERROR:`-scan restructure the
author declared. No other deletion exists in the round's diff. The README's
`## Determinism rules for new cases` heading is intact after the appended
section.

Audit of the author's own receipts with the same comparator (their data, my
code): `runs-battery` vs `runs-battery2` vs `runs-final` → **201/201 identical
over all 201 rows, 0 mismatches**; `runs-final` vs the r86 post reference →
**195/195 identical + exactly the 6 declared appended rows**; totals
`201/201 PASS` (ordinary=155, negative=46) in all three.

---

## 3. C3a — `body_handle`: the identity law is literal, and it discriminates

Raw child logs of my own run
(`tools/extract_witnesses.py runs-full/20261014T215230695674Z`):

```
bh_plain  CHILD_NOTE if_fired=true if_same=true if_refetch=true ss=5/5 detach_nil=true held_live=true reattach_same=true twin=true two_fetch=true
bh_jolt   CHILD_NOTE if_fired=true if_same=true if_refetch=true ss=5/5 detach_nil=true held_live=true reattach_same=true twin=true two_fetch=true
bh_dummy  CHILD_NOTE if_fired=false if_same=false if_refetch=false ss=0/0 detach_nil=false held_live=true reattach_same=true twin=true two_fetch=true
```

So on both real backends: a fresh fetch inside `_integrate_forces` **is** the
handle the callback was handed (and still is on refetch), the sync callback sees
the same object on 5/5 ticks, the refetch after `body_set_space(RID())` is
`nil`, the held handle still reads the pre-detach transform, reattach returns
the *same* object, the three-tier twin is identity, and two fetches in one frame
are equal. Dummy is the floor: neither callback fires (`ss=0/0`,
`if_fired=false`) and the fetch answers for a detached RID
(`detach_nil=false` → token `detach=obj`) — so the law is real-backend-only,
pinned as its own dict, and no Dummy child is armed as a hazard detector.

**Discrimination probe** (this seat's own, `tools/identity_discriminate.gd`,
run under GodotPhysics and Jolt in this seat's own scratch projects): if `==`
were a value-equality that returns true for any two state objects, every pin
above would be vacuous. Measured on **both** backends:

```
CHILD_RESULT distinct_bodies=true       (two bodies -> different state objects)
CHILD_RESULT self_identity=true         (refetch == held handle)
CHILD_RESULT distinct_spaces=true       (two spaces -> different space states)
CHILD_RESULT twin_world=true            (held.get_space_state() == World3D.direct_space_state)
CHILD_RESULT twin_server=true           (… == space_get_direct_state(wspace))
CHILD_RESULT freed_fetch=nil
CHILD_RESULT freed_same_as_held=false   (a stale held handle != the fresh (nil) fetch)
```

The operator discriminates across objects and across spaces, and the pins are
not satisfiable by a stale object after a free. The scout's own `ph_proj` receipt
independently carries the same twin reading
(`TWIN A … eq_srv=true eq_world=true`).

---

## 4. C3b — `acq_use`: the gate controls acquisition, not use

My raw logs:

```
au_plain  CHILD_NOTE reps=8 out_of_phase=8 refused=8 live=8 same_turn=8 persist=8
          CHILD_RESULT au_plain_gate=refused / au_plain_use=ungated / au_plain_out_of_phase=8
          engine-line count 'Body state is inaccessible' = 8
au_jolt   (identical shape, backend=Jolt Physics, engine-line count = 8)
```

The refusal is the **engine's own** line, counted in the raw child log 8 times
per child — not a silent nil, and not the child's self-report. Every rep is at a
process-frame position (`out_of_phase=8`, measured with
`Engine.is_in_physics_frame()`); the held handle still reads live (matched
against the server read at the same instant) and its write lands same-turn *and*
persists to the next in-phase server read, 8/8, on both threaded backends. The
witness doubles as the threading witness, as claimed: an unthreaded child would
grant every fetch (`gate=granted`) and fail the row — which is exactly what the
M1 mutation below produces.

---

## 5. C3c — `step_stamp`: the split, and the author's refinement is the honest reading

My raw logs:

```
ss_plain  CHILD_NOTE pre=0.0010000000475/zero/0.0 off=0 on=4 post=0.0166666675359/real/0.10000000149012 stale=4,0
ss_jolt   CHILD_NOTE pre=0.0/real/0.10000000149012 off=0 on=4 post=0.0166666675359/real/0.10000000149012 stale=4,0
```

`get_step` is step-stamped on both backends (init constant 0.0010000000475 /
0.0 → real dt), while `get_total_gravity` / `get_total_linear_damp` are
step-stamped on GodotPhysics only. The author's §3 refinement of the scout's
directive 6 is confirmed by the **scout's own receipt**, which this seat read
directly:

```
ph_proj.stdout.txt       R A.get_step -> 0.0010000000475   R A.get_total_gravity -> (0.0, 0.0, 0.0)
ph_proj_jolt.stdout.txt  R A.get_step -> 0.0               R A.get_total_gravity -> (0.0, -9.8, 0.0)
```

— i.e. the scout's own `ph_proj_jolt` already shows the split its summary
generalised away, exactly as the author states. The contact buffer reports
nothing until the opt-in (`cc_off=0` while resting → `cc_on=4` after
`body_set_max_contacts_reported(rig, 8)`), and the teleport-out-of-contact
series reads `stale=4,0` (last-step data, clearing on the next step).

---

## 6. C3d — `write_loss`: honest about not witnessing a loss

My raw log:

```
wl_plain  CHILD_NOTE reps=8 refused=8 same_turn=8 landed=8 lost=0
          rows=["0:T>true", "1:T>true", "2:T>true", "3:T>true", "4:T>true", "5:T>true", "6:T>true", "7:T>true"]
          CHILD_RESULT wl_plain_gate=refused / same_turn=8 / landed=8 / lost=0 / tally=8
          engine-line count 'Body state is inaccessible' = 8
```

The scout's measured loss is real — this seat verified the scout's own receipts
directly (`fl_proj_thr.r1.stdout.txt:74 SLEEP srv_sleeping=false` vs
`r2:74 SLEEP srv_sleeping=true`: the same write landing differently across two
runs). The author's form did not reproduce it (my run also reads `lost=0`), and
the row does **not** claim it: the marker carries `race=bounded` and the
landed/lost split stays in the child log. The row's gates are the refusal at
every rep, `same_turn=8`, `landed>=1` and the accounted tally.

Scope note (§11.2): `landed + lost == BODY_REPS` is true **by construction**
(each rep increments exactly one of the two counters), so that conjunct is a
bookkeeping identity, not an independent witness. The load-bearing conjuncts are
`gate=refused` and `landed>=1` — both real. The claim "the tally is accounted"
is true, but a reader should not count it as a measurement.

---

## 7. C3e — `body_tier`: the impulse partition, step-scoped, and its proof

My raw logs:

```
bt_plain  CHILD_NOTE first_i=12 cc=4 impulse=-0.000000000,-0.000000000,-0.000000000 lshape_oob=-1 sleep_lv=kept
bt_jolt   CHILD_NOTE first_i=12 cc=4 impulse=-0.006821907,0.647047877,0.013493819 lshape_oob=0 sleep_lv=zeroed
bt_dummy  CHILD_NOTE first_i=-1 cc=0 impulse=- lshape_oob=absent sleep_lv=flat
engine-line counts: 'Failed to apply central impulse' = 0 / 1 / 0
                    'Index p_contact_idx'              = 1 / 1 / 0
```

The Jolt triple is the scout's `mm_*` value to 6+ digits
(`(-0.006822, 0.647048, 0.013494)`) — an independent reproduction of the
scout's receipt. The detached-impulse refusal is counted in the raw child log
(0/1/0), so it is the engine's line, not a child self-report. The Dummy floor
never contacts (`cc=0`, impulse `nil`, `sleep_lv=flat` — the "flat" token
correctly refuses to award `kept` to a zero-vs-zero read).

The impulse pin's step scope is load-bearing and provable: mutation M3 (read the
same field four steps after first contact) makes **GodotPhysics report a real
impulse** and the row fails —

```
ERROR: phys3d_events: body_tier plain drift exit=0 serr=false v={ …
  "bt_plain_impulse": "real", … }
```

— which is exactly the §5 correction ("GodotPhysics zeros, Jolt real" is a
first-in-contact-step fact in this geometry, not a general law).

---

## 8. C3f — `freed_space`: the crash classes, reproduced by hand

Raw logs of my own run:

```
fsplainproj  1 × 'handle_crash: Program crashed with signal 11', 0 × 'std::system_error', no CHILD_RESULT at all
fsjoltproj   1 × 'handle_crash: Program crashed with signal 11', 0 × 'std::system_error', no CHILD_RESULT at all
fsdummyproj  CHILD_NOTE ray_empty=true; CHILD_RESULT fs_dummy_ray=empty (rc 0)
```

The `rc` is the one piece of evidence a log cannot show, so this seat re-ran the
three children **directly**, by hand, from its own run's scratch (same command
shape `_spawn_child` uses, `timeout -s KILL 6`):

```
fs_plain  rc=134  signal11_lines=1  system_error_lines=0  child_result_lines=0
fs_jolt   rc=134  signal11_lines=1  system_error_lines=0  child_result_lines=0
fs_dummy  rc=0    signal11_lines=0  system_error_lines=0  child_result_lines=1
```

Both real backends crash with a signal-class rc and **no marker**, and the Dummy
floor returns an empty dict and exits 0. The row's `rc ∈ {134, 137}` disjunction
is not a loophole: the crash line count must be exactly 1 **and** the marker set
must be empty, so a bare 137 without the engine's line cannot pass.

The Jolt **two-mode** claim is real, and this seat reproduced **both** modes on
this host with its own executions:

- fixture child (larger script): `handle_crash: Program crashed with signal 11`,
  rc 134 — 1/1 in my run, 3/3 in the author's;
- scout's probe script (copied into this seat's own Jolt scratch project):
  `terminate called after throwing an instance of 'std::system_error'`, rc 134 —
  **3/3 in my runs**, 0 signal-11 lines.

So the mode is heap-layout/script dependent, and the row's
`throw + segv == 1` disjunction records the class without claiming one mode as
the law.

---

## 9. C4 — mutation detection, my own harness, 6/6

`corpus/live/r87-reviewer/tools/mutations.py` (independent implementations of
the six interactions; each mutation edits **one** authored interaction in a
scratch copy, runs only the affected case, and detection = the affected row now
FAILs). Consolidated run receipt `mutations-20261014T220033Z.json`:

```
SUMMARY {"M1": true, "M2": true, "M3": true, "M4": true, "M5": true, "M6": true}
detected 6/6
```

| id | arm | my mutation | detected | parent's rejection (mutant stderr) |
|---|---|---|---|---|
| M1 | `acq_use` | child sweep 8 → 4 reps (parent still expects 8) | yes | `acq_use plain drift … "au_plain_gate": "granted", "au_plain_out_of_phase": "4"` |
| M2 | `freed_space` | do not `free_rid` the space before the query | yes | `freed_space plain rc=0 not signal-class` |
| M3 | `body_tier` | read the impulse 4 steps after first contact | yes | `body_tier plain drift … "bt_plain_impulse": "real"` |
| M4 | `step_stamp` | drop `body_set_max_contacts_reported` | yes | `step_stamp plain drift … "ss_plain_cc_on": "0", "ss_plain_last_step": "0,0"` |
| M5 | `body_handle` | drop the detach | yes | `body_handle plain drift … "bh_plain_detach": "obj"` |
| M6 | `write_loss` | write in phase instead of out of phase | yes | `write_loss drift … "wl_plain_gate": "granted"` |

Disclosure: my first harness pass mis-designed two mutations and reported 4/6 —
M1 mutated the shared `BODY_REPS` constant (the parent's expectation is derived
from the same constant, so the mutation was tautological) and M3's anchor had
wrong indentation (anchor absent, nothing mutated). Both were harness defects,
not row defects; corrected, both are detected as shown. The failure texts above
are from the corrected runs and name exactly the mutated token, which is the
load-bearing evidence that each row measures the interaction it claims.

---

## 10. C5 — sibling batteries, my own executions

**bpy** (`python3 corpus/fixtures/bpy_battery.py --blender /usr/bin/blender`):
`totals: cases=83 pass=83 fail=0 (signal_fail=0 quirk_drift=0)`,
`launch_ok=True done_marker=True fatals=0 exit=0`, `n_arm_lines=131`.
`probe.stdout.txt` sha256
`6a98c570dbaec6f33f23c684ae2938470a251c229cb50d4451c23eb1d07defc3` — **identical
to the frozen r86/r87-baseline value** (the same sha the r87-baseline seat
recorded for the frozen and post-frozen runs); `probe.stderr.txt` empty
(`e3b0c442…`). Receipt
`bpy/bpy-20261014T215451557399Z/verdicts.json` sha256 `592a9acb…f8cb1`.

**three.js** (six suites, three@0.186.1, node v24.21.0): 3 + 4 + 9 + 5 + 5 + 5 =
**31/31 PASS, seedsUnchanged=true** in every suite
(`three/run_*.json`, shas in the Receipts section). No `bpy_*`, `three/`, or
prior-`.gd` file was touched by the round — `git show --stat c57fa40` names
exactly `phys3d_events.gd`, `run_battery.py`, `README.md` and the author report.

---

## 11. Observations (non-blocking, no claim is DISAGREE)

1. **Report delta nit.** The author's §10 table says `phys3d_events.gd
   +880/−4`; `git diff --numstat af15a52 c57fa40` says **+876/−4** (880 is the
   combined churn figure `git show --stat` prints). Documentation-only.
2. **`write_loss` tally conjunct is a construction identity** (§6). The row is
   honest (`race=bounded`, no loss claimed), but a future fold should label the
   tally as bookkeeping rather than a gate, so a reader does not read it as an
   independent witness.
3. **Disjunction strength.** The two deliberate disjunctions (`rc ∈ {134, 137}`,
   Jolt's two modes) are real and both carry a second, independent witness (the
   engine line count and the empty marker set). I could not produce a 137 in my
   own runs (all three crash re-runs landed 134); the disjunction is a superset
   acceptance, and its fail-closed companions are what keep it honest.

## 12. Limits

- One host, one Godot build (`4.7.2.stable.arch_linux.ed1daf0bf`), `--headless`,
  60 tps; one Blender build, one Node/three pair. Every backend-scoped token is
  this build's answer.
- The batteries ran concurrently with the r87-baseline seat's Phase-2 battery
  and an audio lane's probe (host contention only; verdicts are step/phase
  based, and the two prior-row references were reproduced byte-for-byte under
  that load).
- The Jolt crash-mode mechanism remains inference (heap layout), not measured
  mechanism — the author says so too; my contribution is that both modes are
  real on this host.
- `corpus/live/` is gitignored: every receipt cited here is an on-disk artifact,
  not a committed blob.

## Receipts (all under `corpus/live/r87-reviewer/`)

| artifact | sha256 |
|---|---|
| `runs-full/20261014T215230695674Z/verdicts.json` (201/201) | `25987af8f721830af690acf3fad8cd7c8aab889e8136b028e576a26680f7caca` |
| `runs-only87/20261014T215745466937Z/verdicts.json` (6/6) | `1ed6f301d5b86ed86711d6ebff80a5365a46a05351030fb27c05ea27cce3b24c` |
| `runs-pre87/20261014T215354772466Z/verdicts.json` (pre-tree 195/195) | `70a07ffdc1612164c64467c31760e3aacfc32fa418f64481b4cdb68a028a24b6` |
| `bpy/bpy-20261014T215451557399Z/verdicts.json` | `592a9acbeeb2b7d04081efca7b7529812397dbf888c06113575a92286bff8cb1` |
| `three/run_cases.json` / `run_layer_cases.json` / `run_order_cases.json` | `46bb981a…f4ddfcd` / `85cbde53…ca4d4c` / `ab821db3…5482427` |
| `three/run_camera_cases.json` / `run_ortho_cases.json` / `run_ray_cases.json` | `de99bbed…524d622` / `5bf3093f…16f48127` / `5ccaaafc…89653d7e` |
| `mutations-20261014T220033Z.json` (6/6) | `07944decf68b0a4174246988873a5eb58b3a21527c0f604f9902e7d14cdf417f` |
| `pre87/pre87-tree.tar` (af15a52 archive) | `91921c10c91edf935d6d3c21002bb3c67e48d5db98e16801025ba634b5b08765` |
| `battery-full.log`, `battery-pre87.log`, `battery-only87.log`, `bpy.log`, `mutations*.log` | full stdout logs |
| `probe-gp.log`, `probe-jolt.log`, `probe-proj-{gp,jolt}/` | identity-discrimination probe |
| `direct-reruns/r87rev-fs_{plain,jolt,dummy}.log`, `direct-reruns/r87rev-fsmode-{1,2,3}.log` | direct child re-runs (rc + crash modes) |
| `tools/{compare_rows.py,extract_witnesses.py,mutations.py,identity_discriminate.gd}` | this seat's own tools |

**Seat output complete.** Verdict: **AGREE on all eleven claims**, with three
non-blocking observations. No commit, no push, no tracked-file edit, no runtime
other than the fixture batteries, Godot, Blender and Node was invoked.
