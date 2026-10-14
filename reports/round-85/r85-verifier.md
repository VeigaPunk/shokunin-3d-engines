# game-dev-3d round 85 — verifier (seat: verifier, host: devin) — independent post-commit verification of `f230443`

Wave `shokunin-train-20261101-w16`, lane g3d. Assignment (`.ufo/waves/shokunin-train-20261101-w16/tasks/g3d-verifier.md`,
verbatim): r85 VERIFIER — independent post-commit verification of `f230443`;
claim-by-claim AGREE/DISAGREE on the six claims; writes
`reports/round-85/r85-verifier.md` + `corpus/live/r85-verifier/`; no tracked
edits, no git mutation.

**Verdict: AGREE 5/6 outright, AGREE-with-caveat 1/6 (claim 4, imprecise
phrasing in the author's §3.1 — the underlying measurement is correct). 0
DISAGREE. No claim was found false.**

**Runtime (every bound below is scoped to this):** `/usr/bin/godot`
`4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`, 60 tps, Jolt Physics /
GodotPhysics3D / Dummy backends of this build, this host. Verified commit
`f23044360e8b063329b7d128b63cd38f0d512963` (HEAD, unmutated by me).
Verified bytes = committed bytes:

    git show f230443:corpus/fixtures/phys3d_events.gd | sha256sum
      4bcde2bf39cd829887b7cea9da41fe6c3a528cbbfd9f62900b44c30c6db72355   (1263 lines)
    git show f230443:corpus/fixtures/run_battery.py   | sha256sum
      991c6c8ac39a58a576dd9d1e1cc4d922a996dc9b978c9a5f435d325c2666add5   (191 CASES rows)

Both match the author's declared landed bytes (§6) exactly.

**LSP unavailability recorded (per seat card).** `mcp_list_servers` exposes
only `rea`; no `lsp` device for this repo, and no LSP binary on `PATH`. No
symbol-aware rename was needed for a verification pass, so this is a
recorded absence, not a workaround. Every symbol resolution below is
behavioural: Godot's GDScript compiler resolves each call at load, so a
missing/renamed symbol is a `Parse Error` — the same mechanism the author
used to catch F1.

---

## 0. Claim table

| # | claim | verdict | one-line evidence |
|---|---|---|---|
| 1 | battery 191/191 PASS exit 0, twice; all 191 tuples identical run-to-run | **AGREE** | 2 fresh runs, exit 0 both, `cases=191 pass=191 fail=0`, tuple sha256 `efb81318…` identical, stdout+stderr byte-identical 191/191 |
| 2 | 188 prior rows byte-identical vs frozen r84 receipts, 0 undeclared drift | **AGREE** | 188/188 identical positions + 188/188 stdout **and** stderr byte-identical vs 3 independent frozen receipts; only 3 appended rows |
| 3 | new arms live-run independently; pinned expectations hold | **AGREE** | own scratch project, 3/3 reps each, markers exact; raw frames reproduced by my own instrumented probe |
| 4 | `jolt_threaded` child map == `jolt_edge` child map (raw logs) | **AGREE (map) / caveat on phrasing** | map lines identical modulo prefix + the one declared `jt_threaded` key; **whole file is not** "byte-identical modulo prefix" (12 extra refusal ERROR blocks, disclosed by the author) |
| 5 | `threaded_edge`/`jolt_edge` child logs byte-comparable to r84 frozen copies | **AGREE** | `jolt_edge` byte-identical to post-fold r84; `threaded_edge` identical modulo scratch path + `.gd:776→936`; `jolt_edge` vs pre-fold r84 = exactly the declared `jolt_dss_class` line |
| 6 | scratch-disk hygiene: no leftover godot, child dirs bounded | **AGREE** | 0 orphan godot (no ppid 1); 4 child dirs/run × 2 files each; 3.5 MB (verifier) / 3.8 MB (author), all under gitignored `corpus/live/` |

---

## 1. Claim 1 — AGREE. 191/191 PASS ×2, all tuples identical

Two fresh full batteries from the committed bytes, same flags as the author
(`--probe-failing --probe-crash-exit --probe-stream-attribution
--probe-tree-timeout`), absolute `--runs`:

| run | run dir | exit | verdict | totals | probes | seeds |
|---|---|---|---|---|---|---|
| verifier run 1 | `runs/20261014T193427386137Z` | **0** | PASS | `cases=191 pass=191 fail=0 ordinary=145 negative_controls=46` | crash/stream/tree all `true`; mutation `detected=true` | `seeds_unchanged=true` |
| verifier run 2 | `runs/20261014T193753739226Z` | **0** | PASS | identical | identical | `seeds_unchanged=true` |

- `godot_version` = `4.7.2.stable.arch_linux.ed1daf0bf` in both (matches the
  author's declared build).
- **Run-to-run identity, all 191 rows** (`corpus/live/r85-verifier/tuple_identity.py`,
  tuple = `(case, verdict, actual_exit, marker)`):
  run 1 sha256 `efb81318804621389dd5a1bfe0cb0226d1ec3988652d02bb475ec6e777604e6d`,
  run 2 sha256 `efb81318804621389dd5a1bfe0cb0226d1ec3988652d02bb475ec6e777604e6d`
  → `ALL 191 TUPLES IDENTICAL: True`, and `stdout/stderr byte-identical rows:
  191/191`.
- **Cross-seat identity:** the author's run-2 receipt hashes to the *same*
  tuple sha256 `efb81318…` as both of mine — four independent executions
  (author ×2, verifier ×2) over the same 191 tuples.
- The three new rows carry the pinned markers exactly:

      PASS phys3d_events jolt_threaded backend=Jolt threaded=true isect=same cast=constants btm=constants contact_stale=same static_nopair=inverts child_exit=0
      PASS phys3d_events dummy_refused backend=Dummy isect=unexpected cast=unexpected btm=unexpected contact_stale=unexpected static_nopair=unexpected child_exit=0
      PASS phys3d_events srv_phase_delta srv_proc_delta=2 srv_phys_delta=1

---

## 2. Claim 2 — AGREE. 188 prior rows byte-identical, 0 undeclared drift

Compared against **three** independent frozen receipts, not one
(`corpus/live/r85-verifier/compare_prior188.py`):

| frozen receipt | commit / role | tuple-sequence identical | identical positions | stdout **and** stderr byte-identical |
|---|---|---|---|---|
| `r85-baseline/runs/20261014T182310632331Z` | `ac025b2` (r85 freeze) | **True** | **188/188** | **188/188** |
| `r84-verifier/runs/20261014T175211547739Z` | r84 pre-fold | **True** | **188/188** | **188/188** |
| `r84-verifier/runs2/20261014T175525729401Z` | r84 pre-fold (2nd) | **True** | **188/188** | **188/188** |

- `r85-baseline/frozen/frozen-head.txt` = `ac025b26a7ad41507736a7bd6837b167cb1c36e6`
  → the author's "commit `ac025b2`" claim for the freeze is confirmed.
- prior-188 tuple sha256 `8c72ccf5dfd5df46f763a48fb5d66f2f1a1874c3e4bb88fa946a76c3fe0bb280`
  on **both** sides, for all three frozen receipts. (My hash is a different
  serialization from the author's `bab5dc6f…`, so the *values* are not
  comparable to theirs — the *candidate-equals-frozen* equality is the
  measurement.)
- Exactly **3 inserted rows at the tail** (indices 189–191), named
  `phys3d_events_jolt_threaded`, `phys3d_events_dummy_refused`,
  `phys3d_events_srv_phase_delta`. No row appears at a shifted position.
- **Wider than the author's check:** the author per-row-compared stdout and
  stderr for the 12 prior `phys3d_events` cases; I compared **stdout and
  stderr for all 188** — 188/188 byte-identical.
- **Seed-level drift sweep.** Every non-`phys3d_events` seed copy in the run
  scratch (56 files) is byte-identical between the frozen `r85-baseline`
  scratch and mine. The only 4 non-identical names are
  `phys3d_events.gd` (the changed fixture) plus three **runtime-generated
  outputs** — `generated-resource3d.tscn`, `generated-scene3d.tscn`
  (random `unique_id=` values), `timeout-descendant.json` (a pid record).
  None of the three exists under `corpus/fixtures/`; they are run products,
  not seeds, and their variation is by construction. **0 undeclared drift.**

`jolt_edge` child.log, r85 vs the frozen r84 receipts:

    corpus/live/integrator-r84-fold/runs-full/…/scratch/joltproj/child.log   IDENTICAL (cmp -s)
    corpus/live/r84-verifier/runs/…/scratch/joltproj/child.log               DIFFERS by exactly 1 line:
        > CHILD_RESULT jolt_dss_class=JoltPhysicsDirectSpaceState3D

"Identical to pre-refactor" resolves cleanly under either reading: the
`jolt_edge` child log is **byte-identical to the r84 post-fold receipt** and
differs from the r84 pre-fold receipt by **exactly the one declared r85
addition** and nothing else. Its sha256 `2f9900fd84990de3cabd298ef123a61f917e4c6e487dedd1b9ec1aeb97f98582`
matches the author's §4.3 claim, and reproduces byte-for-byte in **both** of
my runs (same sha256 in `runs/20261014T193427386137Z` and `runs/20261014T193753739226Z`).

---

## 3. Claim 3 — AGREE. New arms live-run independently; expectations hold

Own scratch project (`corpus/live/r85-verifier/scratch/proj/`), a fresh copy
of the committed fixture + the seed `project.godot`, driven directly:

    /usr/bin/godot --headless --path <my scratch>/proj --script res://phys3d_events.gd -- --arm=<arm>

| arm | reps | rc | marker |
|---|---|---|---|
| `jolt_threaded` | 3/3 (+8 more) | **0** | `PASS phys3d_events jolt_threaded backend=Jolt threaded=true isect=same cast=constants btm=constants contact_stale=same static_nopair=inverts child_exit=0` |
| `dummy_refused` | 3/3 | **0** | `PASS phys3d_events dummy_refused backend=Dummy isect=unexpected cast=unexpected btm=unexpected contact_stale=unexpected static_nopair=unexpected child_exit=0` |
| `srv_phase_delta` | 3/3 | **0** | `PASS phys3d_events srv_phase_delta srv_proc_delta=2 srv_phys_delta=1` |

All three markers are **character-exact** to the `CASES` rows the battery
pins, and all three are earned by the arm's own internal assertions (the arm
calls `_fail` on any deviation), not merely printed.

### 3a. `dummy_refused` — `unexpected ×5`, 0 diagnostics, exact raw fields

My child log `scratch/proj/dummyproj/child.log`, sha256
`b7ecd80a9ce87ff7a2a8da2b773286fd028c4f622c1c7fdbb859c632cfd774dd`:

    CHILD_NOTE dummy_class=false godot_class=false engine=Dummy
    CHILD_RESULT dummy_backend=Dummy
    CHILD_RESULT dummy_dss_class=PhysicsDirectSpaceState3DDummy
    CHILD_NOTE dummy_isect s0=0 m0=0 away=0 n1=0 back=0
    CHILD_RESULT dummy_isect=unexpected
    CHILD_NOTE dummy_cast degenerate sizes=0,0,0
    CHILD_RESULT dummy_cast=unexpected
    CHILD_NOTE dummy_btm r0=false t0=0.000000 r1=false t1=0.000000 r2=false t2=0.000000
    CHILD_RESULT dummy_btm=unexpected
    CHILD_NOTE dummy_contact_stale set=0,0 in=0,0,0 out=0,0
    CHILD_RESULT dummy_contact_stale=unexpected
    CHILD_NOTE dummy_static_nopair tp=0,0,0,0,0,0,0,0 delta=-1 mv=0,0,-1
    CHILD_RESULT dummy_static_nopair=unexpected

**0 `ERROR:`/`WARNING`/`SCRIPT ERROR` lines**, and this sha256 is
**byte-identical across all four runs** — author ×2 and verifier ×2. All five
arms classify `unexpected`; no known-class label is earned from a zero read;
the r84-critic size guard fires (`degenerate sizes=0,0,0`) with no unguarded
index. The author's §3.2 map is reproduced exactly, constants included.

### 3b. `srv_phase_delta` — raw frames, independently instrumented

The arm's own assertion pins the frame boundaries, but to test the *numbers*
rather than the arm's own verdict I built an instrumented copy that prints
the raw physics-frame counters (`corpus/live/r85-verifier/build_srv_probe.py`
→ `probe/phys3d_events.gd`, 1268 lines; **no tracked file touched**), 3/3 reps:

| probe | raw output (3/3 identical) | derived delta |
|---|---|---|
| (a) process-phase `body_set_state` | `PROBE_A proc f0=5 w0=0 n1=0 n2=1 log=["0@7"]` | **2** |
| (b) dissolve write | `PROBE_B exit fexit=7 log=["0@7", "1@8"]` | **1** |
| (c) physics-phase write | `PROBE_C phys f1=13 p0=0 p1=1 log=["0@14"]` | **1** |

This is the author's §3.3 table reproduced first-hand, frame for frame
(`f0=5→7`, `fexit=7→8`, `f1=13→14`), and it agrees with the r84 `phase_delta`
cell's pinned `proc_delta=2 phys_delta=1`. The arm's marker is earned, not
claimed.

### 3c. Threading witness discriminates (negative control, my own)

Same `jolt_threaded` child body in a **non-threaded** Jolt project
(`corpus/live/r85-verifier/ctl_jolt_nothr/`, rc 0, **0 diagnostic lines**):

    CHILD_RESULT jt_threaded=false
    CHILD_NOTE jt_class=true godot_class=false engine=Jolt Physics
    CHILD_RESULT jt_backend=Jolt Physics
    CHILD_RESULT jt_dss_class=JoltPhysicsDirectSpaceState3D
    … same five classes, same constants …

So the witness is not a constant: it reads `true` under threading and `false`
without it, while the split map is unchanged. That is what makes claim 4
meaningful rather than a map coincidence.

---

## 4. Claim 4 — AGREE on the map; the §3.1 phrasing is imprecise

**The claim as assigned ("`jolt_threaded` child map == `jolt_edge` child
map", from raw logs): AGREE.** Prefix-normalized `CHILD_RESULT`/`CHILD_NOTE`
lines from the two raw child logs differ by **exactly one line**, the
declared threading witness:

    --- jolt_edge
    +++ jolt_threaded
    +CHILD_RESULT K_threaded=true      # K = jt_ / jolt_ normalized

Every other line, including every solver constant, is identical:

| raw field | `jolt_edge` | `jolt_threaded` |
|---|---|---|
| `isect` | `s0=1 m0=0 away=0 n1=0 back=1` | identical |
| `cast` | `safe=0.149841 unsafe=0.150024 w0=1.000000,1.000000 n1=1.000000,1.000000` | identical |
| `btm` | `r0=true t0=-0.998535 r1=false t1=-10.000000 r2=false t2=-10.000000` | identical |
| `contact_stale` | `set=0,1 in=0,1,4 out=4,0` | identical |
| `static_nopair` | `tp=0,0,1,1,1,1,1,1 delta=1 mv=1,1,1` | identical |

Independently reproduced in my own scratch project, not read from the
report.

**Caveat — the author's §3.1 sentence is broader than the measurement.** The
report says the `jolt_edge` child log "is **byte-identical modulo the key
prefix**". That is true of the *map lines* and **false of the whole file**:
the `jolt_threaded` child log carries **12 additional `ERROR: Space state is
inaccessible right now` blocks** (11 from the witness loop, backtraced to
`_child_jolt_threaded`, + 1 from the deferred fetch, backtraced to
`_child_split`) that the `jolt_edge` log does not have. The author discloses
those refusals in the same section and in §5.1, and the arm's own
`_spawn_child(…, allow_inaccessible=true)` tolerates exactly that class
(any other `ERROR:` still sets `serr`), so this is imprecise wording around a
correct measurement — not a false claim. **Not a DISAGREE.**

Supporting measurement: my `jolt_threaded` child log is **path-normalized
identical** to the author's two battery-run copies (author ×2 + verifier ×1),
so the two seats measured the same artifact.

**Cross-run reproducibility of the child receipts** (my independent runs):

| artifact | sha256 / result |
|---|---|
| `joltproj/child.log` | `2f9900fd…` — identical in **both** my runs, author ×2, and the frozen post-fold r84 receipt |
| `dummyproj/child.log` | `b7ecd80a…` — identical across **all four** runs (author ×2, verifier ×2) |
| `joltthrproj/child.log` | path-normalized identical to author ×2; 12 `ERROR:` blocks in 8/8 of my reps and both author battery runs |
| `thrproj/child.log` | 48 lines, identical to frozen r84 modulo scratch path + `.gd` line numbers |

---

## 5. Claim 5 — AGREE. `_spawn_child` fold is behavior-preserving

Static: the five folds the author enumerated in §2 all exist once, at one
call site (`phys3d_events.gd:188–233` `_spawn_child`), and all four arms route
through it — `threaded_edge` (`:638`, `allow_inaccessible=true`), `jolt_edge`
(`:741`, `false`), `jolt_threaded` (`:780`, `true`), `dummy_refused`
(`:815`, `false`). The five folds are present: total `--arm` dispatch (arm
passed explicitly), `DirAccess.remove_absolute(logpath)` before spawn
(`:211`), `timeout -s KILL 30` (`:204`), the `SCRIPT ERROR`/`Parse Error` +
`ObjectDB … leaked` scan (`:224–227`), and the `ERROR:` whitelist
(`:228–231`). The `err` strings are unchanged (`"%s child log missing"`).

Behavioural, per child log:

- **`jolt_edge`** — byte-identical to the r84 **post-fold** receipt
  (`integrator-r84-fold/runs-full/…/joltproj/child.log`, `cmp -s`), and vs
  the r84 **pre-fold** receipt differs by **exactly the declared
  `jolt_dss_class` line**. Nothing else moved.
- **`threaded_edge`** — 48 lines in both; identical after normalizing the
  scratch path and the `.gd` backtrace line numbers. The **only** delta is
  `_child_threaded (…:776)` → `(…:936)`, 11 occurrences, all the same symbol
  — the address shift from the lines added above it, exactly the r84
  precedent's "documented child-log delta" class. Message text, block count
  and structure unchanged.
- **Strongest available check** (the author's own argument, and I agree with
  it): all 188 prior rows have **byte-identical stdout *and* stderr**
  (§2). A fold that changed any spawned-child observable would have to
  surface in the case stream of `threaded_edge`/`jolt_edge`, and none did.

The V2 fold itself is real: `_child_jolt` / `_child_jolt_threaded` /
`_child_dummy` are one-line `await _child_split("<prefix>")` wrappers
(`:983`, `:994`, `:1018`); the sweep body — geometry, constants, classifiers,
size guards, cleanup — exists **once** (`:1026` onward). A class difference
between the three receipts therefore cannot be a difference in sweep code.

**Property test of the stale-log unlink** (my own, `scratch/proj`): I
pre-seeded `joltthrproj/child.log` with a forged map
(`CHILD_RESULT jt_backend=FORGED` etc.), then ran `--arm=jolt_threaded`:
post-run the log contains **0** `FORGED` lines and the arm still prints the
correct pinned marker. A stale forgery cannot reach a receipt.

---

## 6. Claim 6 — AGREE. Hygiene clean

- **No leftover godot processes.** Zero godot processes with `ppid == 1`
  (orphan check), and zero godot processes whose cmdline points at
  `r85-author` or `r85-verifier` scratch. Every live `godot --headless`
  during the window was a child of a *currently running* sibling battery
  (`r85-reviewer`, `r85-simplifier`, `r85-baseline runs-post`, and mine).
  The author's manual 13+3+3-rep sweep left nothing behind.
- **Child dirs bounded.** 4 child project dirs per run
  (`joltproj`, `joltthrproj`, `dummyproj`, `thrproj`), each containing
  **exactly two files** — `project.godot` and `child.log` — verified for all
  8 dirs across both my runs. `joltproj` 8 K, `dummyproj` 8 K,
  `joltthrproj` 12 K, `thrproj` 12 K.
- **Disk.** `corpus/live/r85-verifier` 3.5 MB (2 runs + scratch + controls +
  probe), `corpus/live/r85-author` 3.8 MB (matches the author's §6 claim of
  3.8 MB exactly). All under the gitignored `corpus/live/`; nothing deleted,
  nothing cleaned into a claim.

---

## 7. Write scope and repository state

Writes: `reports/round-85/r85-verifier.md` and everything under
`corpus/live/r85-verifier/` (two battery run dirs, `run1.log`/`run2.log`,
`run1.exit`/`run2.exit`, `scratch/`, `ctl_jolt_nothr/`, `probe/`,
`probe_proj/`, and the three helper scripts `compare_prior188.py`,
`tuple_identity.py`, `build_srv_probe.py`). **No tracked file edited, no git
mutation.** Final state:

    $ git rev-parse HEAD
    f23044360e8b063329b7d128b63cd38f0d512963
    $ git status --porcelain
    ?? reports/round-85/r85-baseline.md   (not mine)
    ?? reports/round-85/r85-boundary.md   (not mine)
    ?? reports/round-85/r85-critic.md     (not mine)
    ?? reports/round-85/r85-scout.md      (not mine)
    ?? reports/round-85/r85-scribe.md     (not mine)
    ?? reports/round-86/                  (not mine)

`corpus/fixtures/phys3d_events.gd` and `corpus/fixtures/run_battery.py` still
hash to the committed values, so the battery's seed-immutability contract
held across my four runs.

---

## 8. Residual risk and what I did NOT verify

1. **`jolt_threaded` child.log is not a byte-stable artifact.** Its refusal
   block count is a function of how many of the 12 witness fetches the engine
   grants. I measured 12 `ERROR:` blocks in 8/8 of my reps and in both author
   battery runs; the author reports the manual sweep also seeing 12/12
   refusals (13 blocks). The **map** is stable and the arm is insensitive by
   design (`allow_inaccessible=true`, exact map compare), but a future
   byte-diff of this log across runs is not a valid regression signal. The
   `dummy_refused` and `jolt_edge` child logs *are* byte-stable (verified).
2. **The `>=8 of 12` witness tolerance was not stressed.** I observed 11/12
   refusals in every rep (8) I counted, so the author's claim that a strict
   `==12` pin would be flaky is consistent with my data — but I did not
   reproduce a run where the witness fell below 8, and I did not falsify the
   author's §5.2 non-claim ("does not prove the physics thread is stepping
   the world").
3. **The fetch-fallback mechanism is still an inference.** The deferred
   position-B fetch is refused under Jolt+threaded at this fixture size; the
   bounded 8-physics-frame retry is what makes the cell pass. I confirmed the
   arm passes (3/3 + 8 reps) but did **not** isolate *why* the window is
   refused here, nor reproduce the r85-scout §1.4 size ladder.
4. **The stale-log unlink's mechanism is only property-tested.** My forged-log
   test proves the *property* (a pre-seeded forgery cannot survive into a
   receipt); it does not discriminate `DirAccess.remove_absolute` from the
   shell's truncating `>` redirect. The call site is present and single
   (`:211`), but a test that separates the two was not constructed.
5. **Concurrency is not quiesced.** Three sibling batteries ran concurrently
   with mine on a 32-core host (`r85-reviewer`, `r85-simplifier`,
   `r85-baseline runs-post`). Every result above is consistent with the
   author's, so no perturbation is visible — but this is not a
   single-battery-on-idle-host measurement.
6. **No new falsification of the author's §5 risk list.** The unarmed surfaces
   (the four missing query surfaces, `node_write_query` contrast, area-query
   contrast, Dummy×threading, node-level monitor for `srv_phase_delta`) remain
   unarmed. My pass adds evidence, not coverage.
7. **Everything above is scoped** to Godot
   `4.7.2.stable.arch_linux.ed1daf0bf`, this host, `--headless`, 60 tps, the
   named project variants, and the arms as landed at `f230443`.

---

## 9. Bounded claim

On the verified commit `f230443`, on Godot
`4.7.2.stable.arch_linux.ed1daf0bf`, this host, `--headless`, 60 tps: the
battery is **191/191 PASS in two independent fresh runs** with all 191
`(case, verdict, exit, marker)` tuples identical run-to-run and across seats;
the **prior 188 rows are byte-identical at identical positions against three
independent frozen receipts, including stdout and stderr for every row**, with
only the three declared rows appended; the three new arms reproduce their
pinned markers and raw child maps **in an independent scratch project**,
including the raw `srv_phase_delta` frames (`proc → 2`, `physics → 1`) via an
independently instrumented copy; the backend split is identical under the
threaded stepper at the map **and** constant level, with the witness shown to
discriminate; the `_spawn_child` fold leaves the r84 child receipts
byte-comparable modulo the two declared deltas; and scratch hygiene is clean.
The one imprecision found is a sentence in the author's §3.1 that overstates
"byte-identical" to the whole child log rather than the map lines. No claim
in the author's report was falsified.
