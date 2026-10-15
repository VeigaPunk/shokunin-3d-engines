# r92 critic — adversarial review of the landed diff (`dd32c3c`)

Seat: **GAME-DEV-3D r92 CRITIC**. Attacked artifact: work commit `dd32c3c`
(`corpus/fixtures/r92_{remote,animphys,timing,child}.gd` + `run_battery.py`
tail-append), author report `reports/round-92/r92-author.md`, boundary report,
baseline report, scout report, `corpus/live/r92-*`.

Environment: `/usr/bin/godot` = **4.7.2.stable.arch_linux.ed1daf0bf**, kernel
7.2.3-arch1-3, AMD Ryzen 9 9950X (32 threads), single host. **The box was
shared for this whole seat** — sibling seats were live throughout
(`r92-verifier` battery in a frozen tree, `game-dev-2d` r88 batteries, the
boundary/scribe/simplifier/reviewer seats). All my writes are under
`corpus/live/r92-critic/` + `/tmp/r92crit/` + this report. **No commits.**

## 0. Headline

The *content* of the round survives attack: the 23 new rows reproduce, the
three-engine splits are real, the negative control really rejects, the
insertion is byte-level insertion-only, and every new evidence string exists
verbatim in the child logs. **What does not survive is the claim that the new
pins are stable.** Five of the 23 rows carry markers that are *scheduler-
conditional*: they hold on an idle box and fail on a CPU-saturated box. One of
them (`r92_timing_steps`) **already failed in the sibling `r92-verifier` seat's
own battery run** (`257/258`), and I reproduced the whole class under
controlled `yes`-hog load, including a dose–response (16/32/64 hogs) and a
mechanism probe that refutes the obvious "jitter_fix" explanation.

| row | failure mode | observed rate under load | verdict |
|---|---|---|---|
| `r92_timing_tps` | `E pf=6 delta=` = pre-mutation step | 3/24 cells @64 hogs, 10/48 @64 hogs (2nd sweep) | **HIGH** |
| `r92_timing_tscale` | same | 2/36 cells @64 hogs | **HIGH** |
| `r92_timing_steps` | same | 0/54 mine; **1 recorded FAIL** (verifier's run) | **HIGH** |
| `r92_animphys_iforder` | idle-phase `I` row advances ≥2 ticks | 7/18 cells @64 hogs | **HIGH** |
| `r92_animphys_idlemode` | envelope rejects the starved mode | 18/18 cells @64, 6/12 @32, 1/12 @16, 0/15 ambient | **HIGH** |

Everything else I could falsify, I failed to falsify (§2).

## 1. What I verified (and how)

**V1 — insertion-only. PASS (byte level, not just `numstat`).**
`git diff 9c6a76b dd32c3c -- corpus/fixtures/run_battery.py` = `+57/-0`.
Stronger: the whole `CASES` body of `HEAD~2` (87 327 B, sha256 prefix
`ce08ba43…`) is a **byte-identical prefix** of the landed body; the 61 226 B
added is appended *after* it. No prior row line moved. 235 → 258 rows counted
by regex on both revisions. No pre-existing fixture enumerates `res://`, so
the new child dirs written into the shared scratch cannot contaminate any
earlier case.

**V2 — fresh battery run.** `timeout 1200 python3 corpus/fixtures/run_battery.py
--runs corpus/live/r92-critic/runs1` → `corpus/live/r92-critic/runs1/20261015T180755801918Z/verdicts.json`,
wall `18:07:55Z → 18:15:24Z` (15:07:55→15:15:24 local, ~7 m 30 s, serial).
**`cases=258 pass=256 fail=2`; all 23 r92 rows PASS.**
The two failures are **pre-existing** rows timing out at the 20 s case bound
(`phys3d_joints_free_pair`, `phys3d_joints_free_ops` — the two slowest rows in
the corpus at baseline, 15.3 s / 16.7 s). The receipt also carries
`seeds_unchanged=false`. Neither is an r92 regression; see F6.

**V3 — every new row's evidence exists in the probe outputs. PASS.**
From my own run's scratch: **123 `r92*/child.log`** files, i.e. exactly the
123 child invocations/pass the fixture arithmetic predicts (33 remote + 54
animphys + 36 timing). For all 96 non-idlemode marker cells I extracted the
`m=` field, located the corresponding `child.log`, and required **every `M`
line to be present verbatim**: **96/96 found, 0 missing**. The 3 idlemode
cells are aggregate-only by design; their 24 per-rep child logs are present
(8/8 per backend). Note `r92_timing_*` cells are 100 % evidence in the
`m=` field; nothing is asserted that is not in a child log.

**V4 — the negative arm really rejects. PASS.**
My battery: `r92_animphys_badkey_insert` → `exit=2/2`,
`NEGATIVE REJECTED: r92_animphys badkey_insert ins=-1,-1 keys=0
destroyed=false on=gp,jolt,dummy`. Also re-run 3× under 64 hogs: 3/3
`NEGATIVE REJECTED`. The predicate is the strict form (all three backends,
`e=2`, exact `reject` row), and the broken-predicate branch exits 0 with
`FAIL …` — so a weakened fixture cannot masquerade as a rejection.

**V5 — backend splits pinned. PASS.** From my run's child logs: `srv`/`ray`
gp+jolt `srv_o=(…)` + `hit@5.000,0.500,0.000` vs dummy `null`/`miss`;
`animatable` gp/jolt move under both `sync_to_physics` values, dummy only
under `false`; `empty_track` resting depth 0.3920 / 0.0800 / 0.0000; rider
settle 2.9973 (gp) vs 3.0000 (jolt/dummy); `idlemode` lv `(0,-1.1376,0)` vs
`(0,0,0)`, srv `(x,2,0)` vs `nil`. All as the author reports.

**V6 — "no unpinned volatile tokens". PASS with one exception class.**
No absolute paths, hex addresses, PIDs, timestamps or wall-times appear in any
of the 23 markers. The only tokens with a scheduler dependence are (a) the
absolute `pf=` stamps (`write_pf=3`, `mut pf=5`, `done pf=13`, `E pf=2…9`) and
(b) the first-post-mutation `delta=` values. **(a) is refuted as a defect**
(§2/F5: it held in every one of the >700 child invocations this seat ran,
including every deviating cell); **(b) is F1.**

**V7 — the author's two-run claim.** Not re-derived here; the scribe
(`17dc133`) and reviewer already verified both receipts row-for-row
(257/258 with the `bpy_rbw3d_render` distribution flip, 258/258, 23/23 r92
rows byte-identical run1↔run2, 234/235 prior-row identity). I independently
confirmed the two `r92`-relevant receipt totals and the 123-child census in
all three of the author's run dirs.

## 2. Findings

Severity is about the *battery contract* (a FAIL must mean a regression), not
about the physics content — the physics content is fine everywhere.

---

**F1 [HIGH] — `r92_timing_tps` / `r92_timing_tscale` / `r92_timing_steps` pin
the delta of the *first post-mutation tick*, which is a property of the
main-loop tick batching, not of the law.**

*Counterexample.* Under 64 `yes` hogs the landed marker fails. Verbatim, one
`tm_tps30@dummy` cell from my sweep (`/tmp/r92crit/B_tps.out`):

```
pinned:  …|M tm_tps30 E pf=6 delta=0.033333|M tm_tps30 E pf=7 delta=0.033333|M tm_tps30 E pf=8 delta=0.033333|…
actual:  …|M tm_tps30 E pf=6 delta=0.016667|M tm_tps30 E pf=7 delta=0.016667|M tm_tps30 E pf=8 delta=0.016667|…
```

and a weaker variant (`E pf=6 delta=0.016667` then `0.033333` at pf=7/8)
appears on gp and jolt in the same sweep. `mut pf=5` and `done pf=13` were
correct in **every** deviating cell.

*Independent witness (not mine).* The sibling verifier's frozen-tree battery
(`corpus/live/r92-verifier/runs1/20261015T180956122238Z/verdicts.json`) is
**257/258** with

```
FAIL r92_timing_steps: exit=0 expected=0 reasons=['exact stdout marker missing']
  tm_maxsteps@gp   E pf=6 delta=0.016667   (pinned 0.166667), pf=7/8 correct
  tm_maxsteps@jolt  E pf=6/7/8 delta=0.166667  (pinned)
  tm_maxsteps@dummy E pf=6/7/8 delta=0.166667  (pinned)
```

*Rate matrix* (deviating cells / cells; a cell = one (run, case, backend)):

| sweep | load | cells | deviating |
|---|---|---|---|
| `tm_maxsteps`, `tm_tps30` child ×14 each (control) | no hogs, ambient load avg 30–44 | 28 | **0** |
| `steps` ×6, `tps` ×4 | 64 hogs | 54 + 24 | 0 + **3** |
| `tps` ×8, `tscale` ×4 | 64 hogs | 48 + 36 | **10** + **2** |
| `tps` ×6 | 32 hogs | 36 | 0 |

*Mechanism probe (refutes the obvious explanation).* I hypothesised
`physics_jitter_fix` smoothing. Direct test, `tm_maxsteps` child ×14 under 64
hogs: `jitter_fix=0.5` (the engine default the round runs under) → **2/14**
deviations; `jitter_fix=0.0` → **7/14**. The jitter fix *stabilises* the
transition; it is not the cause. The cause is that `Main::iteration()` reads
the physics step once per iteration and every tick in that iteration's batch
gets the same value: a mutation delivered inside tick *k* is only visible from
the **next iteration's batch**, and how many ticks are in the mutation's batch
(1 unloaded, up to `max_physics_steps_per_frame=8` starved) is the scheduler's
choice. The author's law sentence — "physics_ticks_per_second writes take
effect on the NEXT tick" — is therefore only true when exactly one tick runs
per iteration, which is exactly the regime the author sampled.

*Impacted axes.* `r92_timing_tps`, `r92_timing_tscale`, `r92_timing_steps`
(3 of 23 rows = 13 % of the round's new surface), the fixture headers
`r92_timing.gd:14-19`, and the author report's law statements (lines 36-40).
Also the round's evidence value: a reader will treat "effect on the next tick"
as a hard engine law.

*Smallest safe correction.* Do not pin the transient. Either
(a) force an iteration boundary between the mutation and the sampled window —
mutate, then `await process_frame` before the first sampled tick (the ticks
after that are guaranteed to be in a later iteration), and emit the sampled
ticks with **relative** labels (`E0/E1/E2`) so no absolute index is pinned; or
(b) keep the window and pin only the settled value plus the transition, e.g.
`settled=0.033333 transient=old,new` computed in the child (the child already
knows the pre-mutation step). Either way the *law* is preserved and the
marker becomes load-invariant. (b) is a ~6-line child change and no marker
arithmetic beyond the new field names.

---

**F2 [HIGH] — `r92_animphys_iforder` pins an idle-phase read whose tick
distance is the scheduler's.**

*Counterexample.* Under 64 hogs, **7 of 18 cells** deviate (gp 4/6, dummy 2/6,
jolt 1/6; the row fails in 4 of 6 runs); verbatim
(`/tmp/r92crit/arm_F64_iforder.raw`, 6 runs, 72 `I` rows: 12× `0.0500`,
16× `0.1000`, 18× `0.1500`, 18× `0.2000`, 7× `0.2500`, 1× `0.3000`), the gp
cell:

```
pinned:  …|M iforder E pf=2 pos=(0.0000,2.0000,0.0000) srv=(0.0000,2.0000,0.0000)|M iforder I pos=(0.0500,…)|M iforder E pf=3 pos=(0.0500,…)|…
actual:  …|M iforder E pf=2 pos=(0.0000,2.0000,0.0000) srv=(0.0000,2.0000,0.0000)|M iforder I pos=(0.1000,…)|M iforder E pf=4 pos=(0.1000,…)|…
```

The `I` row is emitted after `await physics_frame` + `await process_frame`
(`r92_child.gd:984-990`). Under batching (F1's mechanism) the idle phase can
arrive several ticks after the awaited physics frame, so `I = E + 0.05·dt`
with `dt ∈ {1,2,3}` — the cell pins `dt = 1`. Under ambient load the cell is
stable (my battery run + the author's 2 runs + reviewer's pass: pinned); under
64 hogs the row fails in **4 of 6 runs**. The `E` rows themselves are
tick-locked and stayed correct.

*Impacted axes.* `r92_animphys_iforder`; the fixture's stated law ("the idle
read sees this tick's pushed value"); the round's claim that the `E`/`I`
phase contrast is a measured law rather than a same-frame accident.

*Smallest safe correction.* Emit the *predicate* instead of the raw value: the
child knows `pf` at `E` and at `I`, so emit
`I dt=<pf_I-pf_E> ok=<I.pos == E.pos + 0.05*dt>` and pin `ok=1` (the phase
law, load-invariant) while leaving `dt` free. One-line emit change plus a
marker rewrite of the `I`/`E` rows. (Alternative, heavier: sample the idle read
from a `_process` callback on a node that records the physics-frame delta, so
the tick distance is measured, not assumed.)

---

**F3 [HIGH] — the `idlemode` "envelope" rejects the one mode that proves the
cell's own law; the median-bucket pin is a distribution pin, not an envelope.**

*Counterexample.* 64 hogs, 6 runs, all 18 backend-aggregates deviate from the
pinned `reps=8,ok=8,xband=0.2-0.5`; verbatim cells observed
(`/tmp/r92crit/B_idle.out`): `ok=1,2,3,4,5,6,7` with `xband=0.05-0.2`. The
child logs show **why** (`/tmp/r92crit/dev/proj/r92a_idlemode_*/child.log`):

```
M idlemode post x=0.0000 y=1.9240 z=0.0000 lv=(0.0000,-1.1376,0.0000) srv=(0.0000,1.9240,0.0000) playing=true
M idlemode post x=0.2013 y=2.0000 z=0.0000 lv=(0.0000,-1.1376,0.0000) srv=(0.2013,2.0000,0.0000) playing=true
```

The starved mode is `x=0.0000`, `y∈{1.9240,1.9810}` (the body free-falls
because **no idle frame ran between `play()` and the sample**, so the
IDLE-mode mixer never advanced) — the textbook demonstration of the cell's
thesis, and `_env_idlen` (`r92_animphys.gd:157-159`) rejects it on
`y == "2.0000"` and `x >= 0.05`. The pinned `xband` is then computed over the
survivors, so the row fails twice over.

*Dose–response* (aggregate cells, one per backend per run):

| load | runs | aggregate cells | pinned `ok=8,xband=0.2-0.5` |
|---|---|---|---|
| none (ambient, phase A) | 5 | 15 | **15** |
| 16 `yes` | 4 | 12 | 11 |
| 32 `yes` | 4 | 12 | 6 |
| 64 `yes` | 6 | 18 | **0** |

*Envelope-mode enumeration.* Observed modes across all my samples:
`x≈0.2686–0.2895` (normal, `y=2.0000`), `x≈0.13–0.25` (partial advance),
`x=0.0000` (`y<2.0000`, starved). The envelope admits only the first. Two
`_xband` labels are unreachable in the passing branch: `none` (only when
`ok=0`, which already fails) and `hi` (`med>=1.2`, above the envelope's own
`x<=1.2` cap).

*Impacted axes.* `r92_animphys_idlemode` (the round's only "envelope" cell),
the author report's §"idlemode envelope", the corpus's known-distribution
list. Secondary, already filed elsewhere and confirmed here: the stated range
`0.2686–0.2895` is 1e-4 above the stored maximum (my 24 samples from the
author's two runs: max 0.2884; scribe F3 and reviewer F6 record the same).

*Smallest safe correction.* Make the predicate assert the **law**, not the
scheduler: keep the per-backend constants (`lv`, `srv`, `z`, `playing`, one
M0/DONE, `e=w=s=0`) and accept the starved mode as valid
(`y == "2.0000" or y <= 2.0000`; `x` already has a `[0.05,1.2]`… which also
needs `x >= 0.0`), then pin the aggregate as a *set* — e.g.
`ok=8,mode={full,partial,starved}` — and drop the median-bucket pin or widen
it to `0.0-1.2`. That preserves the contrast the round actually wants
(IDLE mode is not tick-locked, PHYSICS mode is) and removes the
false-positive generator. If the judge prefers a narrow band, the cell must
then be documented as a distribution cell in the `bpy_rbw3d_render` class, and
the battery's PASS/FAIL contract must exempt it.

---

**F4 [INFO] — `r92_timing_edge` and `r92_timing_refuse` are *not* fragile;
do not "fix" them.** Both survived 64 hogs untouched (`edge` 3 runs / 18
cells, `refuse` 4 runs / 24 cells, plus the battery). This is structural: for
`ts=0` the delivered delta is `0.000000` under either step, and for `ts=-1` the
sign-only value `-0.016667` is step-independent, so the transition lag F1
describes is invisible in these two rows. Recording it here so a repair pass
does not over-reach.

**F5 [INFO] — the absolute `pf=` stamps are load-robust; the "r87 api_press"
hypothesis is refuted.** 0 of 235 pre-r92 rows pin a `pf=` token, so the r92
round does introduce a new pinned-token class — but it is *not* fragile:
`write_pf=3`, `mut pf=5`, `done pf=13` and the `E pf=2…9` series held in
every one of the >700 child invocations this seat ran, including all four
deviating classes above, all sweeps up to 64 hogs, and the verifier's failing
run (whose three cells all still read `mut pf=5`/`done pf=13`). The child's
startup phase (deferred `_run` landing at `pf=1`) is structural, not
wall-clock dependent. No action.

**F6 [INFO] — my own battery receipt's two non-r92 FAILs and
`seeds_unchanged=false` are environment artifacts; the round is not
implicated.**
(a) `phys3d_joints_free_pair` / `free_ops` exceeded the 20 s case bound while
the box carried four other lanes' batteries plus my sweeps (baseline elapsed
15.3 s / 16.7 s). Pre-existing rows, pre-existing margin.
(b) `seeds_unchanged=false` because `corpus/fixtures/r92_remote.gd` changed
under me: HEAD moved `b6169f6 → 27fba42` **during** my run — the `fold-a`
commit (`15:15:01`) rewrote the file at `15:14:28`, restoring the reviewer-F1
comment qualification. `git diff` of that commit is comment-only (7 insertions
/ 3 deletions in the header block) and cannot change behaviour; the last
`r92_remote_*` cases (chainlag/srv/drive, ≈15:14:23–15:14:32) straddle the
rewrite and still matched their markers byte-for-byte, which is the direct
check that the comment-only claim holds. I verified the pre/post digests
explicitly (receipt-before `3544c2e4…` = the verifier's frozen-tree copy; now
`795b093f…` = the `HEAD` blob).
This is worth one line in the corpus's operational notes: a battery run is not
valid across a mid-run fixture commit, and this wave commits while batteries
run.

**F7 [INFO] — corroborations of already-filed items, verified independently.**
`369 child cells per battery pass` → **123/pass** (my census: 123 `child.log`
in every author run dir and in my own; the report's own Children column sums
to 123; 369 = 3 × 123 across dev + run1 + run2). Filed by scribe `17dc133`
(F2) and reviewer F2; the author file is still uncorrected. The reviewer's F1
(local-mode synchronous propagation and `set_notify_transform(false)` kill
unarmed) is real and now half-closed by the `fold-a` comment; the two cells
are still unarmed.

**F8 [INFO] — dead code in the new child.** `cap_f` / `f_rows` /
`Watcher._process` (`r92_child.gd:27,79-91,733-737`) never produce a row: the
`F_post` emit sits immediately after `await process_frame`, which resumes
before that frame's node callbacks, so `f_rows` is always empty at the read.
`grep -c F_post` on my run's `r92a_rbpos_gp_rbpos/child.log` = **0**. Harmless
for the pinned cells (and lucky: had it fired, the F rows would have been the
same scheduler-dependent multiplicity the scout's §6 warns about). Consistent
with the simplifier's dead-code list.

## 3. Verdict recommendation (the canonical runtime judges)

**CHANGES-RECOMMENDED on the battery contract; the round's physics content is
admissible.** Specifically:

1. `r92_timing_tps`, `r92_timing_tscale`, `r92_timing_steps` — re-anchor the
   sampled window past an iteration boundary, or pin the settled value +
   transition instead of the first post-mutation tick (F1). Also correct the
   law sentence in `r92_timing.gd` / `r92-author.md` to "next main-loop
   iteration's tick batch".
2. `r92_animphys_iforder` — pin the phase predicate, not the raw idle value
   (F2).
3. `r92_animphys_idlemode` — admit the starved mode; stop pinning a median
   bucket over a scheduler-dependent sample (F3), or reclassify the cell as a
   documented distribution cell like `bpy_rbw3d_render`.
4. Text-only: the 369→123 correction in `r92-author.md` (F7).

If the judge's contract is "a green battery on an idle box is sufficient",
the diff is admissible as-is and these are hardening items. If the contract is
"a FAIL means a regression" — which is the corpus's stated exit contract —
then F1–F3 must land first: as of this review the round has already produced
one such false-positive FAIL in a sibling seat's run, and the mechanism is
proven, not inferred. I do not judge; the runtime decides.

## 4. Residual uncertainty and disclosure

- **I perturbed the environment I measured.** My sweeps (up to 64 `yes` hogs,
  and 24-concurrent-child idlemode arms) overlapped the verifier's battery:
  its failing `r92_timing_steps` case ran ≈15:16:0x, and my idlemode sweep
  started ≈15:15:5x. So the verifier's FAIL is *not* an independent,
  load-free sighting — it is evidence that the row can fail in the wave's real
  concurrent environment, and my controlled hog matrix is the primary
  evidence. Sibling `game-dev-2d` lanes were also running batteries
  throughout.
- **No-hog control is ambient-loaded, not idle**: 0/28 deviations at load
  average 30–44 (sibling lanes). I could not obtain a truly idle box; the
  ambient level never fell below ~6.
- **Not re-derived by me**: the two author battery receipts row-for-row
  (scribe/reviewer did), the boundary report's probe lattice, the
  `bpy_rbw3d_render` flip attribution, the dev-sweep artifact hygiene
  (reviewer F5).
- **Cross-build tolerance**: every claim above is for
  `4.7.2.stable.arch_linux.ed1daf0bf` on this host; the load-sensitivity
  itself is a scheduler property and should be read as host/load-conditional.
- **Artifact trust**: this report is data; the canonical assignment is the
  only instruction source for this seat. No tracked writes other than this
  file; no commits; every Godot child was `timeout`-bounded.

Stopping after the assigned review.
