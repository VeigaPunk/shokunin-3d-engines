# r95 critic — adversarial review of the committed bullet/pybullet landing (`0767b59`)

Seat: **GAME-DEV-3D r95 CRITIC** (frozen `probeParent`). Attacked artifact: commit
`0767b5900f38949b6e077b0ab8317480f66166f8` — `corpus/fixtures/r95_bullet.gd` (+196, new),
`corpus/fixtures/r95_child.py` (+1673, new),
`corpus/fixtures/r95vendor/pybullet.cpython-314-x86_64-linux-gnu.so` (7 063 864 B, new),
`corpus/fixtures/run_battery.py` (+40/−0), `reports/round-95/r95-author.md` (+81);
**304 battery rows** (245 ordinary + 59 negative controls), the 20 r95 rows are rows
**285–304** (contiguous, last). Author + scout + boundary reports, `corpus/live/r95-{author,scout,boundary}/`
receipts, and the sibling `r95-scribe.md` were read (never written).

Environment (`corpus/live/r95-critic/env.txt`): `/usr/bin/godot`
**4.7.2.stable.arch_linux.ed1daf0bf**, `/usr/bin/python3` **3.14.7**, kernel 7.2.3-arch1-3,
AMD Ryzen 9 9950X (32 threads). The box ran **under sustained sibling load for the whole
seat** (load1 **53–86**; concurrent seats observed: `r95-verifier` (spot r95 children),
`r95-reviewer`, `r95-scribe` batteries, `r92-author`, g2d `r91-simplifier`, `r91-verifier`,
`r91-critic`, plus 16 audio-lane hog processes).

**No `lsp`/symbol device is exposed to this seat's toolset** (the same recorded absence as
r85–r94); no source edit was needed or made — every mutation ran on **copies under the
gitignored receipt dir**, never on a tracked file. No commits. The only tracked write is
this report; everything else lives under `corpus/live/r95-critic/**` (gitignored via
`corpus/.gitignore: live/`).

**probeParent seat:** exactly one `ufo-labrat` was dispatched (bounded depth-2 static
probe of "no pinned M-surface value is a function of wall-clock/scheduling"). It returned
**FALSIFIED (strict form), static reading only — its profile has no shell/exec tool**
(the same recorded limitation as the r94 critic's and the r95 boundary's labrat probes). Its
clean half ("no raw clock/environment
value reaches `emit`") is confirmed; its counterexample (`rt_paced`'s pinned hash sits on a
sleep-paced path, `rt_idle`'s pinned `z`s on a 0.6 s idle path) was **measured by this seat**
and does **not** reproduce as a flake (§1.10) — the boundary's DIRECT-scoping of the
real-time flag is what makes those pins inert. No other descendants; nothing edited.

---

## 0. Verdict

**PASS — the landing survives attack on the committed bytes, with one MEDIUM finding.**
Every r95 row reproduced on the frozen committed tree (full battery **301/304, 20/20 r95**;
four independent r95-only passes **20/20 each**), every one of the **202** `m=` M-lines in
five independent receipts is a verbatim rescan of the child logs, the insertion is
byte-level insertion-only, the vendored engine bytes are output-equivalent to the
unstripped artifact on all 52 cases, and thirteen mutation probes prove the pins reject the
defects they claim to reject.

**F1 (MEDIUM) is the one substantive defect: the two SHM cells pin a `#`-diagnostic *count*
that is not reproducible.** `shm_step` emits `d ∈ {8,10}` and `shm_rtclass`
`d ∈ {42,44,46}`; the M-surface (the pinned hash) never moves. Through the **real runner on
the frozen bytes**, `r95_bullet_shm` FAILed **8/12** row executions in one loaded window
("exact stdout marker missing", every failure a `d` diff only) and 0/12 in a later, quieter
one — **8/24 = 33 %** overall, in bursts. The author documents the *class* but with a
**false mechanism** ("the total byte count — and thus the line count — is fixed"): the
captured `#` payload is **440 B (`d=8`) vs 682 B (`d=10`)** — the SHM teardown prints are
partial-line writes whose tail lands after the child's single end-of-run drain, so the byte
count is exactly what is *not* fixed. The sibling `r95-scribe` filed the same class as
"low/documented"; the measured row-level rate says otherwise (§1.6, §2 F1).

**Blockers: none.** The one permitted `labrat` probe was usable only as a static lead and is
recorded as such; its hypothesis was measured by this seat, so no evidence gate is left open.

| # | attack | verdict | anchor |
|---|---|---|---|
| 1 | insertion-only, prior rows untouched | **CONFIRMED** (byte level) | §1.1: old `CASES` body = exact ordered subsequence, 1170/1170 lines consumed in order, **40 inserted, 0 modified, 0 deleted** |
| 2 | row/cell arithmetic vs the report | **CONFIRMED** (one wording nit, F2) | §1.2: 20 rows (14 positive + 6 negative), **46** digest cells, 52 child processes/pass, 304 total |
| 3 | reproduce the 20 rows on the committed bytes | **CONFIRMED** | §1.3: full battery **301/304, 20/20 r95** + **4 × r95-only 20/20** + author run1/run2 **304/304** |
| 4 | is the evidence real (cells = child logs)? | **CONFIRMED** | §1.4: **5 receipts** × (46 cells, 52 logs, 202 M-lines) re-scanned with the parent's own rules — **0 problems** |
| 5 | are the pins load-bearing (not vacuous)? | **CONFIRMED** | §1.5: **13/13** mutation probes as expected |
| 6 | is the pinned surface load-invariant? | **FALSIFIED for the 2 SHM `d` pins** | §1.6: `r95_bullet_shm` **8/12 FAIL** in a loaded window (0/12 in a quiet one); `shm_step` 8/64, `shm_rtclass` 4/26 off-pin; M-surface never moved |
| 7 | "creation order is not bit-neutral" (the corrected law) | **CONFIRMED** — but the reports' *argument* is not probative (F3) | §1.7: permutation-invariant re-test, 4/5 (canon) and 32/33 (pile) bodies differ; ball Δz = 1.04e-4 |
| 8 | vendored bytes ≡ the scout's build | **CONFIRMED** | §1.8: 52/52 cases byte-identical (rc + M-lines) stripped vs unstripped; `.so` inside `seed_digests` |
| 9 | SHM transport is process-self-contained (no cross-run contamination) | **CONFIRMED** | §1.9: a concurrent process's `connect(SHARED_MEMORY_SERVER)` sees 0 bodies while a holder has 1; 0 after it exits |
| 10 | wall-clock/liveness cells (`rt_paced`, `rt_idle`, `fell`/`froze`) | **CONFIRMED stable** | §1.10: `rt` row 0/8 FAIL, `neg_shm_rt` row 0/8 FAIL, all 52 cases ×6 reps stable on the M-surface |
| 11 | FAILs outside the documented flake list | **NONE** | §1.11: my 3 FAILs = `navagent3d_retarget_fixed` (F1 signature `before=1.754246`), `navagent3d_follow` (one-tick `1.636395`), `phys3d_events_deferred_hang` — all on the r93-baseline2 catalog |
| 12 | report-accuracy spot checks | **CONFIRMED** (one overbroad sentence, F1) | §1.12: all 16 hex16 tokens + all cited numbers present verbatim; `dtBits` arithmetic verified |

---

## 1. What I verified (and how)

### 1.1 Byte-level insertion-only

`git show f8946a8:corpus/fixtures/run_battery.py` vs the committed file
(`corpus/live/r95-critic/tools/insertion_check.py`, `insertion_check.json`): the old `CASES`
body is an **exact ordered subsequence** of the new body — **1170/1170 old lines consumed in
order**, **40 lines inserted** (the contiguous 40-line block at lines 699–738: the 20 tuples,
2 lines each), **0 old lines modified or deleted**. `git show --stat` agrees: 5 files, 1 990
insertions, **0 deletions**. The 20 r95 rows are the last 20 of 304.

### 1.2 Row/cell arithmetic (report claim vs artifact)

| measure | report says | measured |
|---|---|---|
| r95 rows | 20 | 20 (rows 285–304, contiguous) |
| digest cells / pass | "52 child cells" | **46** digest cells + 6 negative child runs = **52 child processes** (F2) |
| positive arms / cases | 14 arms | 14 arms, 46 cases |
| child processes / pass | 52, fresh each | 52 |
| `d≠1` cells | not stated | `sv_backends` `d=4`; `shm_step` `d=8`; `shm_rtclass` `d=44`; all other 43 cells `d=1` (the import banner) |
| negatives | 6 | 6 (all six prove an **in-child live control**, unlike r94's 2/6) |

### 1.3 Frozen-tree reproduction on the committed bytes

`git archive 0767b59` → `corpus/live/r95-critic/frozen-tree/` (507 files;
`run_battery.py 0b9b7035…`, `r95_bullet.gd f988ba86…`, `r95_child.py 8821ebd5…`,
`r95vendor/…so eca749a0…` — all equal to my own `sha256sum` of the tracked files), then the
runner's own paths:

| run | tree | verdict | notes |
|---|---|---|---|
| my `runs1` (full 304) | frozen 0767b59 | **301/304**, **20/20 r95** | 492 s wall; `seeds_unchanged=true`; FAILs = `navagent3d_retarget_fixed`, `navagent3d_follow`, `phys3d_events_deferred_hang` |
| my `r95only` pass1..4 (20 rows ×4) | frozen 0767b59 | **20/20 ×4** | 26.2/26.3/26.4/26.4 s; max row `rt` 3.95 s vs the 20 s bound; `seeds_unchanged=true` ×4 |
| author run1 (`corpus/live/runs/20261015T224443567926Z`) | worktree@author | **304/304** | 454 s, `seeds_unchanged=true` |
| author run2 (`corpus/live/runs/20261015T232218926492Z`) | worktree@author | **304/304** | 500 s, `seeds_unchanged=true` |
| author r95-only pre-run (`…T224412369946Z`) | worktree@author | **20/20** | 26 s |

The author's "304/304 ×2" claim is exact. My full run's three FAILs are all on the
documented flake catalog (§1.11) and **no r95 row failed** in it.

### 1.4 Evidence integrity (the `m=` cells are real)

`tools/evidence_check.py` re-implements the fixture's own `_run_child()` scan
(`r95_bullet.gd` lines 162–191, splitting on `\n` exactly as Godot's `FileAccess.get_line()`
does) and requires, per cell: the `m=` field to equal the child log's M-line list **verbatim
and in order**, `o`/`d` to equal a rescan of the raw log, and the cell to re-parse. It also
re-derives the whole `PASS r95_bullet <arm> py=<ver> …` line. Result on **five independent
receipts** (author run1, author run2, author pre-run, my full run, my r95-only pass 1):

```
rows=20  cells_checked=46  logs_checked=52  m_lines_checked=202  problems=[]  verdict=PASS
```

**202/202 M-lines verbatim, 46/46 cells, 0 problems, in each of the five.** This covers the
negative rows too (log = exactly `[M0, NEGATIVE REJECTED]`, `o=0`, rc 2).

### 1.5 Pin sensitivity (mutation battery, copies only)

`tools/mutation_sensitivity.py` + `tools/mutation_followup.py` — each mutation applied to a
throwaway copy of the frozen fixtures, then judged by the **real runner** with `--only`:

| mutation | expectation | observed |
|---|---|---|
| M1b shift `PIN_BASE` (rt row) | rt row FAILs | **FAIL** — `rt_paced … eq=True` is a real comparison against the constant |
| M2 `_real.write("o-inject\n")` in `det_base` | det row FAILs | **FAIL** — the `o=0` gate is load-bearing |
| M3 extra `diag("extra diagnostic")` | det row FAILs | **FAIL** — the `d` **count** is load-bearing |
| M4b rewrite the `shm_rtclass` `#` body (`z0=999 z1=999`) | not detected | **PASS ×3** — the diagnostic *body* is deliberately unpinned |
| M5 break `neg_shm_rt`'s live control (`zd != z0`) | neg row FAILs | **FAIL** — the in-child control is load-bearing |
| M6 `time.sleep(20)` in `det_base` | det row FAILs | **FAIL** — the 15 s `KILL` bound is load-bearing |
| M7 `os.write(1, b"raw-fd1-line\n")` in `det_base` | det row FAILs | **FAIL** — fd-1 bytes are captured as `#`, never as `o` |
| M8 `dtbits = raw(0.5)` (M0 identity) | det row FAILs | **FAIL** — the engine-identity pin is load-bearing |
| M9 forge `M det_base …` via `owrite` | det row FAILs | **FAIL** — the M-surface is compared verbatim |
| M10 edit the committed marker in the *parent* | det row FAILs | **FAIL** — the marker check is a real comparison, not vacuous |
| (M1 on the det row — my mis-target) | — | PASS, correctly: `c_det_base` never reads `PIN_BASE`; recorded so the receipt is honest |

**13/13 probes behaved as designed.** M4b is the only "expected non-detection" and documents
the intended bound.

### 1.6 Load invariance — the SHM `d` pins (F1)

**Child level.** `tools/flip_probe.py` runs the committed child exactly as the parent does
(fresh process, `timeout -s KILL 15`, stdout+stderr merged) and hashes the parent-visible
surfaces separately. 52 cases × 6 reps = **312 child executions**: **51/52 cases byte-stable
on `rc`/`m`/`o`/`d`**; the single exception is `shm_step` (`d ∈ {8,10}`, `m` identical in all
6). Targeted sweeps (`tools/shm_diag_bytes.py`, `tools/shm_diag_probe.py`, 64 + 26
executions):

| case | pinned `d` | observed `d` | off-pin | captured `#` payload |
|---|---|---|---|---|
| `shm_step` | 8 | 8 (56), 10 (8) | **8/64 = 12.5 %** | **440 B vs 682 B** |
| `shm_rtclass` | 44 | 44 (22), 42 (2), 46 (2) | **4/26 = 15 %** | 1947–1956 B vs 2189–2199 B |
| every other case | 1 / 4 | 1 / 4 | 0/312 | — |

The `m` surface (the pinned hash `h=02309c52da41ef33`, `eqPin=True`, `fell=True`, …) was
**identical in every one of those runs** — the drift is confined to the diagnostic *count*.
The drift is **bursty, not uniform**: 8/32 off-pin in the 21:00–21:03 window (load1 53–86,
sibling r95 verifier/reviewer/scribe batteries plus my own two jobs running) versus **0/32**
in the two later
windows (16 quiet reps + 16 reps with a separate process churning SHM
connect/disconnect every 50 ms — `tools/shm_noise.py`). So the driver is **in-process
scheduling pressure, not cross-process SHM churn**; the later windows also show that the
event is rare when the box is calm.

**Mechanism (measured, not inferred).** `tools/shm_payload_capture.py` (60 reps) captured both
variants and diffed them: the `d=10` payload carries **two extra
`PosixSharedMemory::releaseSharedMemory …` segments** that the `d=8` payload never emitted.
The engine's SHM teardown writes are **partial-line writes** (note the concatenated
`…removed shared memoryPosixSharedMemory::releaseSharedMemory detached shared memory`), and
the child drains the capture buffer once, at the end, after `time.sleep(0.05)`. Under load
the 50 ms settle overruns, so more teardown output lands **before** the drain (`d=10`);
otherwise the tail lands after it and is lost. Either way the emitted byte count — and
therefore the newline count — is *not* fixed, and the author's stated rationale ("the total
byte count — and thus the line count — is fixed, and 50 ms settle sleeps … land the prints
before the drain") is **falsified by the byte counts themselves**.

**Row level, through the real runner on the frozen bytes** (`tools/row_flip.py`, each rep a
fresh scratch copy):

| row | reps | FAILs | failure signature |
|---|---|---|---|
| `r95_bullet_shm` (window 1, 21:02) | 12 | **8** (67 %) | `exact stdout marker missing`; every diff is `shm_step d=8→10` and/or `shm_rtclass d=44→46/42`; `o`, `rc` and all `m` fields identical |
| `r95_bullet_shm` (window 2, 21:06) | 12 | 0 | — |
| `r95_bullet_rt` | 8 | 0 | — |
| `r95_bullet_det` | 8 | 0 | — |
| `r95_bullet_neg_shm_rt` | 8 | 0 | (the negative path never checks `d` — the row is immune by construction) |

Row-level total **8/24 = 33 %**, all in one window. At the child-level rates measured there,
the implied row-level rate is ≈36 % (P(0 FAILs in the author's 3 green passes) ≈ 0.26); the
point is not the exact percentage but that the row is **not reproducible under load**, while
the author's three green passes and the sibling seats' runs all sat in calmer windows.
Receipts: `rowflip-shm/`, `rowflip-shm2/`, `flip1.jsonl`, `shmdiag.jsonl`, `shmbytes.jsonl`,
`shm_payloads.json`, `shm_noise.log`.

### 1.7 The "creation order is not bit-neutral" law — permutation-invariant re-test

The child's witness (`state_hash`, `r95_child.py:172`) iterates **engine body ids** and
appends `struct.pack(">i", bid)`, so *any* creation-order change permutes the hash input. The
scout/boundary/author argument ("the 64-bit witnesses differ from the first byte, not by an
ulp") is therefore **not probative** (F3). I re-tested the claim properly
(`tools/order_probe.py`, `tools/order_magnitude.py`), importing the child's own scene builders
and matching bodies by their **creation descriptor** (verified id→descriptor by reading every
body before the first step; 0 mismatches):

| scene | id-indexed hashes | per-descriptor bits | detail |
|---|---|---|---|
| canon 5-body, 480 steps | `02309c52da41ef33` vs `76988acc55682c1a` (matches the committed pins) | **4/5 bodies differ** | ground identical (static); ball `z` `1.499977819` vs `1.499976272` (**Δ = 1.04e-4**, not an ulp) |
| 32-box pile, 600 steps, `det=0` | `daf67ba7bdfb7f80` vs `38cb12317d6644da` (matches the committed pins) | **32/33 bodies differ** | — |

So the corrected law is **true as physics**, and the r94-cannon non-transfer is real — but
the *reason* the reports give for it is a witness artifact argument that happens to be
rescued by the physics. The recommended fold is to record the invariant comparison alongside
the pinned hashes (the r94 child's `physHash`-over-logical-order style) so the claim is
carried by evidence rather than by a confounded digest.

### 1.8 Vendored engine bytes and seeds

- `tools/vendor_equiv.py`: all **52 cases** run against the **stripped** vendored
  `.so` (`eca749a0…`, 7 063 864 B) **and** the scout's **unstripped** venv artifact
  (`c035ebaf…`, 91 047 408 B): **52/52 identical** `rc` + M-lines, 0 diffs — the author's
  output-equivalence claim is exact (it is also the only claim in the landing that could
  have hidden a strip-induced behaviour change).
- The vendored `.so` is inside the run receipts' `seed_digests` (74 seeds) with the
  committed sha256; `seeds_unchanged=true` in every run I read.
- `dtBits=3f71111111111111` = IEEE-754 bits of `1/240` (`struct.pack(">d", 1/240)`), and the
  report's float-rebuild discriminator `3f71111120000000` is exactly the f64 bits of the
  float32-rounded `1/240` — the arithmetic behind the build-scoping claim checks out.

### 1.9 SHM transport is process-self-contained

`tools/shm_crosstalk.py`: a holder process connects `SHARED_MEMORY_SERVER`, plants a body
(`nbodies=1`) and holds it; a second process connecting the same way sees
**`nbodies_at_connect=0`** (its own create → 1), and still 0 after the holder exits. The
server lives in the creating process, dies with it, and **cannot be attached across
processes** — so concurrent sibling batteries (r95-verifier/reviewer/scribe were all running
r95 children during this seat) cannot contaminate the `shm_*` cells, and rows cannot leak
state into each other. The boundary's "no external server process" is confirmed.

### 1.10 Wall-clock / liveness cells

- `rt_inert` / `rt_idle` / `rt_paced` are **liveness pins**: they assert the DIRECT real-time
  flag stays dead even with real sleeps (0.6 s idle, 120 × 4 ms paced, 480 × 4 ms paced).
  Measured: `rt_paced` and `rt_idle` byte-stable 6/6 in the child sweep, the `rt` row
  **0/8 FAIL** at row level. The labrat's concern is therefore a **tested-and-refuted lead**
  (if DIRECT ever acquired a pump, the row would fail — that is the cell's purpose, not a
  flake).
- `shm_rtclass`'s `fell=True` and `neg_shm_rt`'s `froze=True`/`fell=True` are threshold
  classes (`z<5.0`, `zd==z0`) that only flip if the SHM pump stalls >2 s or DIRECT starts
  pumping; the `neg_shm_rt` row is 0/8 FAIL and `fell=True` held in every one of my SHM runs.
- Slowest child observed: **3.2 s** (`neg_shm_rt`) vs the 15 s `KILL` bound (4.7× headroom);
  slowest row 3.95 s (`rt`) vs the 20 s case bound (5×).

### 1.11 Flake list and non-causation

My three FAILs in the full 304-row run are exactly on-record classes:
`navagent3d_retarget_fixed` — the internal `before=1.754246` misfire signature recorded in
`r93-verifier.md:85` / `r94-verifier.md:84`; `navagent3d_follow` — the one-tick-late
`first=(1.636395,…)` signature in the r93-baseline2 catalog; `phys3d_events_deferred_hang` —
the documented hang class. **No FAIL outside the catalog; no r95 row among them.**

Non-causation: `git diff --name-only f8946a8 0767b59 -- corpus/fixtures/` = **only**
`run_battery.py` + the three new `r95*` paths — no pre-existing fixture byte moved.
Custody: HEAD was `0767b59` when the frozen tree was extracted and moved mid-seat to
`a042e49` (r95-scribe, report-only); `git diff 0767b59..HEAD -- corpus/fixtures/` is
**empty**, so the judged fixture bytes are still HEAD's bytes. These receipts must not be
reused for later fixture bytes.

### 1.12 Report-accuracy spot checks

Every hex16 token in `r95-author.md` (16) is present **verbatim** in the committed markers
except `3f71111120000000`, which is explicitly the *hypothetical float rebuild* value and
correctly absent; every cited number (`1.49997782`, `0.520632014`, `9.66585442`,
`4.27577737`, `0.110300828`, `0.851578572`, `12.5`, `2.42374526`,
`0.004166666666666667`, `4.466e-14`, `6.804e-13`, `-10.6855237`, `1.94289029e-16`,
`-1e-05`, `9.82`, …) is present. 20 of the 43 pinned hashes are independently corroborated
by the boundary report; 5 are new-probe evidence (`fr_bitexact`'s three per-pair hashes,
`neg_dt`'s variant hash, `numSubSteps=-1`) — the same "authored-only" set the scribe's F2
flagged. `getDynamicsInfo` really returns a 12-field tuple with **no activation field** and
no `getActivationState` exists in the API (only the `ACTIVATION_STATE_*` constants), so
"sleep is API-unobservable" holds at the API-surface level. All ten scout/boundary
corrections are encoded in the authored form (DIRECT-scoped purity, SHM pump-live class,
scene-scoped `detpairs`, scene-dependent fixpoint, 1-ulp friction, `>=0` NaN gate, fd-1
`b3Warning` capture, no Godot-side claims).

---

## 2. Findings (ranked)

**F1 — MEDIUM (a non-reproducible pin + a falsified rationale).** `r95_bullet_shm` pins two
`#`-diagnostic **counts** that drift: `shm_step d ∈ {8,10}` (8/64 child executions off-pin)
and `shm_rtclass d ∈ {42,44,46}` (4/26). Through the real runner on the frozen bytes the row
FAILed **8/12** executions in one loaded window (load1 53–86; 0/12 in a later, calmer one;
**8/24 = 33 %** overall), always with `exact stdout marker missing` and always with the `d`
field as the only diff (`o`, `rc` and every `m` field identical, including the pinned hash).
Mechanism: the SHM teardown prints are **partial-line writes** whose tail lands relative to
the child's single end-of-run drain — captured `#` payload **440 B (`d=8`) vs 682 B
(`d=10`)**, 1947 B vs 2189 B (`shm_rtclass`) — so the report's "the total byte count — and
thus the line count — is fixed" is **false in both halves**. `reports/round-95/r95-author.md`
§"Known flake classes" discloses the class but frames it as "pathological scheduling"; the
measured per-cell rate in the loaded window is 15–25 %, which makes the row — not the class —
the thing that is not reproducible, and the author's three green passes plus the sibling
seats' runs all sat in calmer windows (16 quiet reps and 16 reps under cross-process SHM
churn were 0/32 off-pin, so the driver is in-process scheduling, not cross-process SHM
contention). **Recommended fold (author/adjudicator call, not this seat's):** pin the count
as a class/envelope (`d ∈ {8,10}` for `shm_step`, `d ∈ {42,44,46}` for `shm_rtclass`), or
make the drain deterministic (drain twice around a longer settle, or discard the partial-line
tail before counting). Non-impact: the physics, the transport-neutrality pin and the
pump-liveness class are unaffected — only the diagnostic count moves.

**F2 — LOW (arithmetic wording).** "20 CASES rows → **52 child cells** per battery pass":
the six negative arms emit **no** `{rc,m,o,d}` digest cell (the parent echoes their rejected
line instead), so the landing has **46 digest cells + 6 negative child runs = 52 child
processes**. The same nit the r94 critic filed as F5; the author's own prose elsewhere
distinguishes the two.

**F3 — LOW (claim carried by a confounded argument).** The corrected "creation order is not
bit-neutral" law is **true** (§1.7), but the scout/boundary/author evidence for it is the
**id-indexed** witness, which changes under any creation-order permutation *by construction*
— "the 64-bit witnesses differ from the first byte, not by an ulp" is not evidence of a
physics difference. My permutation-invariant re-test (bodies matched by creation descriptor)
confirms the law with real magnitudes (ball Δz = 1.04e-4; 4/5 canon bodies, 32/33 pile
bodies), and also shows the r94-cannon non-transfer is genuine. Recommend recording the
invariant comparison next to the hashes (and, for `neg_order`, that the rejection is a
witness-level, not physics-level, discrimination).

**F4 — INFO (environment pins).** 14 rows pin `py=3.14.7` in the parent's `PASS` line and
every child's `M0` pins `build="Oct 15 2026 03:47:36"`. Both are deliberate identity pins
(host CPython; the vendored build stamp), but a host python bump or a rebuild reddens 14 rows
at once. Worth a line in the round's portability notes, not a defect.

**F5 — INFO (reconciliation with the sibling `r95-scribe`).** The scribe's **F3** files the
same SHM `d`-count class as "low, documented flake class … reproduced both counts under
load"; my measurement (§1.6) shows the class reddening the row **8/12** executions in a
loaded window (33 % across 24 row executions) and that the documented rationale is wrong, so
I rank it **MEDIUM**. The scribe's
**F1** (`sl_force_mb`'s forced-rest tail ≠ the scout's `sleep-force` numbers) is **confirmed
statically by this seat**: the committed cell reads `forcedRest z=0.49998583 velwrite
z+1=0.510221593 z+31=0.735970268` vs the scout's `z=0.49999 … z+1=0.510225597 …
z+31=0.735969337`; the child's own values are deterministic (6/6 reps, all batteries) — a
report-precision correction, as the scribe concluded.

**F6 — INFO (the negatives are stronger than r94's).** All six r95 negative arms prove an
**in-child** live control before rejecting (`neg_dt`/`neg_order` compute the control hash
live; `neg_radius`/`neg_simtime`/`neg_badid` require a control + a refusal count;
`neg_shm_rt` requires `d_froze and fell`), and M5 shows the control is load-bearing — so the
report's "6 negative arms require the child's live-control" is literal here (it was literal
for only 2/6 in r94).

---

## 3. Residual risks (bounded, not findings)

- **F1's rate is bursty and load-dependent.** 8/32 off-pin child executions in the loaded
  window, 0/32 in two later windows (quiet and cross-process-SHM-churn); the author's green
  passes and the scribe's/verifier's runs sat in calmer windows. On a quiet box the class is
  rare — the defect is the single-value pin on a lossy drain, not the observed percentage.
  Whether the same burst recurs in the *next* wave depends on how many seats share the box.
- **`#`-diagnostic bodies are unpinned anywhere** (M4b). A future drift in a measured
  diagnostic (e.g. the SHM stepped `distinct=`/`pinFree=` values, the `rt-idle` measured `z`s)
  passes silently until someone reads the scratch logs. Deliberate, but it means the
  "measured" half of several claims has no battery-level guard.
- **Environment pins** (F4): host python version and the build stamp.
- **The `sl_persist` `froze~101` heuristic** (`i > 100` guard) and `freeze_scene`'s
  3000-step horizon are single-value pins on long loops; they held in all my runs but have
  no envelope.
- **Un-authored axes** (correctly left out): TCP/UDP transports, SHM+rt=1 with
  `numSubSteps>0`, cross-`-march`/FMA rebuilds, raw NaN payload bits, the float-`btScalar`
  rebuild's hashes (discriminated by `dtBits`).
- **Scope.** My batteries ran plain (no `--probe-*` flags), like the baselines. Sibling
  seats' receipts were not reused; only their published reports were read.
- **Custody.** The judged bytes are `0767b59`; HEAD moved mid-seat to `a042e49`
  (report-only) and `git diff 0767b59..HEAD -- corpus/fixtures/` is empty, but wave-B seats
  are still writing (untracked reports). These receipts must not be reused for any later
  fixture bytes.

---

## 4. Receipts

All under gitignored `corpus/live/r95-critic/`:

- `env.txt` · `frozen-tree/` (`git archive 0767b59`, 507 files) · `run_battery_parent.py`,
  `run_battery_r95.py` (the two compared parents)
- `runs1/20261015T233412147660Z/{verdicts.json,scratch/}` (my full battery **301/304, 20/20
  r95**, `seeds_unchanged=true`) · `runs1.log`
- `r95only/pass1..4/{runs/*/verdicts.json,scratch/}` (**20/20 ×4**) · `r95only.log` ·
  `r95only/summary.json`
- `flip1.jsonl` + `flip1.log` (52 cases × 6 reps, 51/52 stable) · `shmdiag.jsonl` ·
  `shmbytes.jsonl` · `shm_payloads.json` + `.log` (60 reps, both `d` payloads) ·
  `shm_payload_d10.json` · `shmrtclass.log`
- `rowflip-shm/` + `rowflip-shm.json` (**8/12 FAIL**, window 1) · `rowflip-shm2/` +
  `rowflip-shm2.json` (**0/12**, window 2) ·
  `rowflip-r95_bullet_{rt,det,neg_shm_rt}/` (**0/8** each) · `rowflip-extra.log`
- `shm_noise.py` + `shm_noise.log` (cross-process SHM-churn control: 0/16 off-pin)
- `mut/` (M1–M10) · `mut2/` (M1b, M4b ×3) · `mutations.json` · `mutations2.json` +
  `mutations.log`, `mutations2.log`
- `order_probe.json` · `order_magnitude.json` (permutation-invariant order re-test)
- `vendor_equiv.json` + `.log` (**52/52 identical**) · `origvendor/` (symlink to the scout's
  unstripped `.so`) · `crosstalk-holder*.log`
- `evidence-{20261015T224412369946Z,20261015T224443567926Z,20261015T232218926492Z}.json`
  (author receipts) · `evidence-mine-runs1.json` · `evidence-mine-r95only-pass1.json`
  (each: 20 rows / 46 cells / 52 logs / 202 M-lines / 0 problems)
- `insertion_check.json` · `tools/{insertion_check,evidence_check,mutation_sensitivity,
  mutation_followup,flip_probe,shm_diag_probe,shm_diag_bytes,shm_payload_capture,
  shm_payload_diff,shm_crosstalk,order_probe,order_magnitude,vendor_equiv,row_flip,
  r95_passes}.py`
- `SHA256SUMS` (**7 873 files**, 860 MB; the byte-identical seed copies inside
  `rowflip-*`/`r95only` were pruned *after* hashing and after every check ran — each rep's
  `runs/*/scratch/` and `verdicts.json` are retained, and the mutated `mut*`/`mut2` seed
  copies are retained)

**Zero tracked writes** by this seat: no tracked file was modified or deleted (the only
tracked-tree write is this new, still-untracked report); no commits; no kills (other lanes'
processes left alone; my own processes exited).
`config/ufo.json` / `scripts/ufo-sighting` are **not present in this workspace**, so no
sighting hatch was available or needed — no trigger phrase was interpreted as a mission.
Artifact-trust: this report is data; the canonical assignment (the dispatched task file) is
the only instruction source for this seat.
