# r94 critic — adversarial review of the committed cannon.js landing (`05e72ef`)

Seat: **GAME-DEV-3D r94 CRITIC** (frozen `probeParent`). Attacked artifact: commit
`05e72ef968f218fc7c4f8b2e58a190d2eddd63fc` — `corpus/fixtures/r94_cannon.gd`
(+194, new), `corpus/fixtures/r94_child.mjs` (+1027, new),
`corpus/fixtures/r94vendor/` (4 files, +94349), `corpus/fixtures/run_battery.py`
(+38/−0), `reports/round-94/r94-author.md` (+71); 284 battery rows (231 ordinary
+ 53 negative controls), the 19 r94 rows are rows **266–284** (contiguous, last).
Author + scout + boundary reports and `corpus/live/r94-{author,scout,boundary}/`
receipts were read (never written).

Environment (`corpus/live/r94-critic/env.txt`): `/usr/bin/godot`
**4.7.2.stable.arch_linux.ed1daf0bf**, node **v24.21.0** (fnm, inherited PATH),
Python 3.14.7, kernel 7.2.3-arch1-3, AMD Ryzen 9 9950X (32 threads). The box ran
**under sustained sibling load for the whole seat** (load1 76–149: 16 `yes` hogs
from the audio lane, two sibling Godot batteries, an r94-reviewer seat, plus my
own probes; `contention.txt`).

**No `lsp`/symbol device is exposed to this seat's toolset** (the same recorded
absence as r85–r93). No source edit was needed or made: every mutation ran on
**copies under the gitignored receipt dir**, never on a tracked file. No commits.
The only tracked write would be this report; everything else lives under
`corpus/live/r94-critic/**` (gitignored via `corpus/.gitignore: live/`).

**probeParent seat:** exactly one `ufo-labrat` was dispatched (bounded NaN
canonical-hash probe) and returned **UNTESTED — the profile has no shell/exec
tool**. Its static reading was still useful and is credited in §1.9: `canonHash`
is payload-independent *by construction*, and `nan_all` emits **no raw payload
field**, so the raw-bit half of the hypothesis is unmeasurable from the battery
surface (the boundary measured it separately). No other descendants were
spawned; the empirical measurement was performed by this seat with `exec`.

---

## 0. Verdict

**PASS — the landing survives attack on the committed bytes, with one MEDIUM
finding.** Every r94 row reproduced on the frozen committed tree in six
independent passes (19/19 each), every `m=` cell in three independent receipts is
a verbatim rescan of the child log, the insertion is byte-level insertion-only,
and nine mutation probes prove the pins reject the defects they claim to reject.
**F1 falsifies the report's "load-invariant" claim**: four accumulator-mode
child cells are wall-clock-budget sensitive and can flip under load, which
*by construction* FAILs their battery row (measured child-flip rate ≈1.0 % of
1 340 targeted executions at load1 90–135; no full-row FAIL in 42 row
executions, consistent with a ≈2.8 %/run rate). The authored *values* are the
correct ones for the un-preempted path — the defect is the single-value pin on a
`performance.now()`-bounded code path plus the claim of invariance.

**Blockers: none.** The one permitted `labrat` probe was unusable (no shell in
that profile) and is recorded as such; its hypothesis was measured by this seat,
so no evidence gate is left open by that seat's failure.

| # | attack | verdict | anchor |
|---|---|---|---|
| 1 | insertion-only, prior rows untouched | **CONFIRMED** (byte level) | §1.1: old `CASES` body = exact ordered subsequence, 622/622 lines consumed in order, **38 inserted, 0 modified, 0 deleted** |
| 2 | row/cell arithmetic vs the report | **CONFIRMED** (one wording nit, F5) | §1.2: 19 rows (13 positive + 6 negative), **60** digest cells, 66 child processes/pass, 284 total |
| 3 | reproduce the 19 rows on the committed bytes | **CONFIRMED** | §1.3: my frozen-tree full battery **281/284, 19/19 r94** + **5 × `--only` passes 19/19** + author run1 (280/284, 19/19) + author run2 (**284/284**, 19/19) |
| 4 | is the evidence real (cells = child logs)? | **CONFIRMED** | §1.4: 3 receipts × (60 cells, 66 logs, **319 M-lines**) re-scanned with the parent's own rules — **0 problems** |
| 5 | are the pins load-bearing (not vacuous)? | **CONFIRMED** | §1.5: **9/9** mutation probes as expected (physics, stray `o`, negative non-vacuity, `d` count, live control, timeout rc=137, stderr, vendored-package rationale) |
| 6 | is the pinned surface load-invariant? | **FALSIFIED for 4 accumulator-mode cells** | §1.6/§1.7: **13 child flips in 1 340 targeted executions**; mechanism reproduced (12/960 calls broke early, all ≥16.68 ms vs the 16.67 ms budget) |
| 7 | is the fixedStep class pin honest? | **CONFIRMED, weaker than measured** | §1.8: `#` body stable in 18/18 of my runs (+9/9 boundary) but only `d=1`/`ticks_lt_calls` pinned → F2 |
| 8 | NaN canonical hashing is the right mitigation | **CONFIRMED** | §1.9: 8 default + 8 `--no-opt` children → 1 distinct M surface; boundary's 99-process payload flips cited; labrat static check |
| 9 | vendored engine bytes are the scout/boundary deps | **CONFIRMED** | §1.10: 3 dist bundles byte-identical (sha256) to `r94-boundary/scout-replay/…/node_modules`; all four covered by `seed_digests` |
| 10 | FAILs outside the documented flake list | **NONE** | §1.11: my 3 FAILs = size_gate, deferred_hang, joints_free_ops(20 s) — all on the r93-baseline2 list; no pre-r94 fixture byte touched |
| 11 | report-accuracy spot checks | **CONFIRMED** (2 wording nits) | §1.12: every cited number present verbatim in the committed markers; F3/F5 wording |

---

## 1. What I verified (and how)

### 1.1 Byte-level insertion-only

`git show 7f84e66:corpus/fixtures/run_battery.py` vs the committed file: the old
`CASES` body is an **exact ordered subsequence** of the new body — 622/622 old
lines consumed in order, **38 lines inserted** (comment block + 19 tuples), and
**zero old lines modified or deleted** (the r93 landing needed one trailing-comma
fix; this one needed none). `git show --stat` agrees: 8 files, 94 659 insertions,
**0 deletions**. The 19 r94 rows are the last 19 (`CASES` = 284 rows, 231
ordinary + 53 negative controls; r94 = 13 positive + 6 negative).

### 1.2 Row/cell arithmetic (report claim vs artifact)

| measure | report says | measured |
|---|---|---|
| r94 rows | 19 | 19 (rows 266–284, contiguous) |
| digest cells / pass | "66 child cells" | **60** digest cells + 6 negative child runs = **66 node processes** (F5: the six negatives emit no `{rc,m,o,d}` cell — the parent echoes their line instead) |
| node children per pass | 66, fresh process each | 66 |
| positive arms / cases | 13 arms, 60 cases | 13 arms, 60 cases |
| `d≠0` cells | mod_fixedstep only | exactly one cell in the whole landing pins `d=1`; all other 59 cells pin `d=0` |

### 1.3 Frozen-tree reproduction on the committed bytes

`git archive 05e72ef` → `corpus/live/r94-critic/frozen-tree/` (498 files;
`run_battery.py b230d29c…`, `r94_cannon.gd d40a1f75…`, `r94_child.mjs c84a8e8a…`,
`cannon-es.js f0700cbd…`), then the runner's own paths:

| run | tree | wall (UTC) | verdict | FAILs |
|---|---|---|---|---|
| my `runs1` (full 284) | frozen 05e72ef | 22:11 → 22:20 | **281/284** | `phys3d_events_script_size_gate`, `phys3d_events_deferred_hang`, `phys3d_joints_free_ops` (20 s timeout) |
| my `r94only1..5` (19 rows ×5) | frozen 05e72ef | 22:21 → 22:27 | **19/19 ×5** | none |
| author run1 (`corpus/live/runs/20261015T215239880004Z`) | worktree@author | 21:52 | 280/284 | the 4 documented (navagent ×2, size_gate, deferred_hang) |
| author run2 (`…T220110895172Z`) | worktree@author | 22:01 | **284/284** | none |

**All 19 r94 rows PASS in all six of my passes and in both author runs**, with
markers byte-identical to the committed `CASES` (the battery's own check). Max
r94 row wall 2.835 s (`det`) against the 20 s case bound and the parent's 15 s
child bound → ≈7× headroom. `seeds_unchanged=true` in every receipt.

Run-2 nuance: the author describes run 2 as "load ~60–100"; its **r94 rows were
22 % slower than run 1's** (19.26 s vs 15.82 s total across the 19 rows) while
the whole battery was 10 % faster — the fully green pass was *not* the easier one
for this surface. Both green runs are genuine; neither is explained by "run 1 was
the loaded one".

### 1.4 Evidence integrity (the `m=` cells are real)

`tools/evidence_check.py` re-implements the fixture's own `_scan()` (r94_cannon.gd
lines 176–189) and requires, per cell: the `m=` field to equal the child log's
M-line list **verbatim and in order**, `o`/`d` to equal a rescan of the raw log,
`rc` to match, positives to end with `M DONE`, negatives to be exactly
`[M0, NEGATIVE REJECTED]`. Result on **three independent receipts** (author run1,
author run2 — including the 284/284 green one — and my `runs1`):

```
cases=19  cells_checked=60  logs_checked=66  m_lines_checked=319  problems=[]  verdict=PASS
```

**319/319 M-lines verbatim, 60/60 cells, 0 problems, in each of the three.**
This covers the negative rows too (their logs are exactly the M0 header plus the
committed `NEGATIVE REJECTED:` line, rc 2).

### 1.5 Pin sensitivity (mutation battery, copies only)

`tools/mutation_sensitivity.py` — each mutation applied to a throwaway copy, then
judged by the real runner with `--only`:

| mutation | expectation | observed |
|---|---|---|
| M1 drop height 5 → 5.001 in `buildWorld` | det row FAILs | **FAIL** (`exact stdout marker missing`) — the pins measure engine physics |
| M2 one stray stdout line in `det_base` | det row FAILs | **FAIL** — the `o=0` gate is load-bearing |
| M3 remove the `neg_dt` defect (`dt` back to 1/60) | neg row FAILs | **FAIL** (exit 1 ≠ 2, no marker) — the negative is non-vacuous |
| M4 second `#` line in `mod_fixedstep` | modes row FAILs | **FAIL** — the `d` count is load-bearing |
| M5 rewrite the `#` diagnostic body (`stepnumber=999999 ph=fake`) | **not** detected | **PASS** — the diagnostic *body* is deliberately unpinned (F2 evidence) |
| M6 force the `neg_grid` live control to fail | neg row FAILs | **FAIL** — the control is checked before the refusal class |
| M7 busy-wait 20 s in `det_base` (timeout path) | det row FAILs | **FAIL** (`rc=137` cell) — the 15 s KILL bound is load-bearing |
| M8 one stderr-only line in `det_base` | det row FAILs | **FAIL** (`o=1`) — stderr is merged into the counted log |
| M9 remove `r94vendor/package.json` | det row FAILs | **FAIL** (`o=4`; every child warns) — resolves scribe F1, §F8 |

**9/9 as expected.** M5 is the only "expected non-detection" and documents the
intended bound.

### 1.6 Load invariance — arm level (the author's claim, extended)

- `tools/arm_stress.py`: the 19 arms run exactly as the battery runs them,
  **6 reps = 114 arm runs = 396 child processes** at load1 90–135 → **114/114
  markers byte-identical to `CASES`, all stderr empty**, max arm 4.899 s.
- Author rep sweep re-verified by this seat from their raw receipts
  (`/tmp/r94test/reps/`, 190 files): **19/19 arms × 5 reps identical stdout,
  empty stderr, markers == committed `CASES`** — their claim is exact.

So the *arm-level* surface is stable; §1.7 shows what the arm-level sample size
cannot see.

### 1.7 Load invariance — child level (F1) and its mechanism

`tools/flip_probe.py` runs the committed child directly, N times per case, and
hashes the **entire M surface** the parent scans:

| probe | cases × reps | executions | cells with >1 surface |
|---|---|---|---|
| flip1 | 66 × 12 | 792 | **0** (rc 0/2 as expected) |
| flip2 | 8 accumulator cases × 40 | 320 | var_interp 2, var_sleep_phase 2, mod_two_arg 3 |
| flip3 | 7 accumulator cases × 60 | 420 | var_interp 1, var_maxsub 2 |
| flip4 | 4 accumulator cases × 150 | 600 | mod_two_arg 3 |
| **targeted total** | | **1 340** | **13 flips (≈1.0 %/execution)** |

Every flip is in the accumulator branch, and every flipped value is consistent
with the engine's **wall-clock bail-out** (`r94vendor/cannon-es.js:12529`:
`if (performance.now() - t0 > dt * 1000) break;` inside the substep loop, with
`dt*1000` = 16.67 ms for `dt = 1/60`):

```
normal : M var_maxsub maxsub stepnumber=10 time=0.500000000 accumulator=4.163336e-17 ball.y=4.850047582139
flipped: M var_maxsub maxsub stepnumber= 4 time=0.500000000 accumulator=2.081668e-17 ball.y=4.972726790637
normal : M var_interp frac acc=1.666667e-2 interpPos.y=1.499020405350 pos.y=1.499020405350 prevPos.y=1.498636322432
flipped: M var_interp frac acc=1.666667e-2 interpPos.y=1.498636322432 pos.y=1.498636322432 prevPos.y=1.497943696520
```

`0.5 − 4·dt` reduced mod `dt` gives exactly the flipped residue, i.e. the loop
broke after 4 substeps instead of running the `maxSubSteps=10` cap — the same
arithmetic the boundary measured for its own accumulator probe (§7 there), now
inside an **authored, pinned** cell.

**Mechanism reproduced directly** (`mech/mech_probe.mjs`, a copy that rebuilds
the child's 4-body scene and times `step(DT, 0.5, 10)` per fresh world):

- serial, 2 × 240 calls: **0 short calls**, max wall 9.6 ms (budget 16.67 ms);
- **8 concurrent instances, 960 calls: 12 short calls** (`stepnumber` 2–9), and
  **every** short call has wall ≥ **16.683 ms** (up to 26.4 ms) — above the
  16.67 ms budget. `stepnumber=4, y=4.972726791` reproduces the child's flipped
  surface to the digit.

So the flip is CPU-contention (preemption) inside a `performance.now()`-bounded
loop, not a physics change: the child's *pinned* `stepnumber`/`ball.y`/`interpPos`
fields move, the marker no longer matches, and **the row FAILs** (proved by M1/M4
— any marker mismatch is a FAIL). Row-level rate estimate from the per-child
rates: `varstep` ≈2.8 %/run, `modes` ≈2.4 %/run at load1 90–135.
`tools/row_flip.py` ran the rows through the real runner **14 × {varstep, modes,
bailout} = 42 row executions: 0 FAILs** — consistent with those rates (P(0)≈0.7)
and the reason the author's 2 battery runs and my 6 passes were green.

**This is the one substantive finding (F1): the report's "the r94 surface is
load-invariant on this host" is falsified.** The author's 5-rep sweep (5 samples
per child case) was under-powered for a ≈1–2 %/execution event, and the
boundary's own §7 caution ("any accumulator-mode cell is unportable") applies to
four cells the author chose to pin as single values.

### 1.8 The `fixedStep` class pin (F2)

`mod_fixedstep` pins only `calls=240 class=wallclock mode_ok=1
ticks_lt_calls=true` and puts the measured count in a `#` diagnostic (`d=1`
pinned as a count, body unpinned — M5). Measured here: the `#` body is
**`stepnumber=1 ph=a3ec872defc812b2` in 18/18 of my runs** (12 default + 6
`--no-opt`), matching the boundary's 9/9. So the body is in fact stable on this
host and a stricter class pin (e.g. `ticks <= 5`) would add real discriminating
power — the current pin can only reject `stepnumber ≥ 240`. Conservative, not
wrong; filed as a coverage recommendation, not a defect.

### 1.9 NaN canonical hashing

- 8 default + 8 `--no-opt` direct `nan_all` children: **1 distinct M surface**,
  `h=152fc9d393846ae3` for `nan_payload` — the canonical pin holds under the flag
  set that flips raw payload bits.
- Boundary §3 measured 34 payload flips in 99 `--no-opt` processes **with the
  canonical hash identical in every flip** — the author's mitigation is the right
  one, and the fixture emits **no** raw-payload field (labrat's static check
  confirms: `canonHash` maps NaN to the literal `'NaN'` before hashing).
- The 22-case lattice matches the report exactly: `cases=22 nan=7
  [nan_dt,nan_gravity,nan_mass,damping_gt1,angdamping_gt1,nan_quat,nan_payload]
  inf_only=0`, `neg_radius` = constructor refusal, `coincident_spheres
  ni=0,0,0 cC=2.000110769`, `iters0 y=-72.845`.

### 1.10 Vendor bytes and seeds

`r94vendor/{cannon-es.js,three.module.js,three.core.js}` are **byte-identical**
(sha256) to the boundary's `scout-replay/proj/node_modules` copies
(`f0700cbd…`, `9052042d…`, `9edde002…`); `package.json {"type":"module","private":true}`
silences `MODULE_TYPELESS_PACKAGE_JSON`. All four appear in the run receipts'
`seed_digests` (71 seeds), so the vendored bytes are inside the battery's
before/after mutation guard. No `node_modules`, no npm at battery time.

### 1.11 Flake list and non-causation

My three FAILs are exactly the on-record classes (r93-baseline2: navagent
one-tick miss, size-gate granted-under-load, bpy render, `phys3d_joints_free_*`
20 s pair); my `size_gate` reason is the documented `{"sz_fetch": "granted"}`
signature. Non-causation: `git diff --name-only 7f84e66..05e72ef --
corpus/fixtures/` = **only `run_battery.py` + the new `r94*` files** — no
pre-existing fixture byte moved. `phys3d_events_freed_space_methods` (the r93
critic's F1 segv lottery) did not fail in my run. HEAD was `05e72ef` when the
frozen tree was extracted; it moved mid-seat to `7cd5ec8` (r94-scribe,
report-only) and `git diff 05e72ef..HEAD -- corpus/fixtures/` is empty, so the
judged fixture bytes are still HEAD's bytes (only untracked sibling reports
appeared).

### 1.12 Report-accuracy spot checks

Every number the author report cites is present **verbatim** in the committed
markers: `b95c69cacf7f74c7`, `c37c514dfccc07f3`, `1@132`/`6@134`, `125.505`,
`0.956939`, `8.939521`, `fixedErr=0`, `detScale=1.000000`, `objWorld.y=5.0`,
`bodyPos.y=0.421`, `0.108755`, `1.035024e-9`, `1e-9@52`, `maxN=13`, `0.653801`,
`yAfter=0.249998`, `stepnumber=5`, `h=4c92fce24d8d7f58`, `distinctHashes=8`,
`nx1_ok_y=4.997272222`, `ticks_lt_calls=true`, the whole friction grid
(15.173/15.172/3.053/15.668/9.048/17.273 — the boundary's independently measured
3.053…17.27 range, its 15.669 vs the pinned 15.668 being a 3-dp rounding of the
same value), and the order hashes (`2e65cf…`/`d02da5…`/`4caaad…`/`d3795d…`/
`f1a92e…`/`a8ad93…` = boundary §8's table). All four boundary falsifications
plus all four new modes are folded in the authored form (§0 of the author report
matches the child's own header comments).

---

## 2. Findings (ranked)

**F1 — MEDIUM (load-flake class + a falsified report claim).** Four pinned cells
live on the engine's wall-clock bail-out and flip under contention:
`var_maxsub` (2/250), `var_interp` (3/250), `var_sleep_phase` (2/250),
`mod_two_arg` (6/250) — **13 flips in 1 340 targeted child executions (≈1.0 %)
at load1 90–135**, all with values matching the `performance.now() - t0 >
dt*1000` break (12/960 mechanism-probe calls ≥16.68 ms vs the 16.67 ms budget).
By construction each flip FAILs `r94_cannon_varstep` (≈2.8 %/run) or
`r94_cannon_modes` (≈2.4 %/run); I observed **0 FAILs in 42 row executions**, so
the event is rare but real. `reports/round-94/r94-author.md` §"Rep-stability
contract" states "the r94 surface is load-invariant on this host" — that is
**false for these four cells** (the 5-rep sweep could not see a 1 %/execution
event: P(0 flips in 5 samples) ≈ 0.95). **Recommended fold (author/adjudicator
call, not this seat's):** either pin an envelope for the multi-substep calls
(e.g. `stepnumber` ∈ [1..10] plus the exact `time=0.500000000` and the
`physEq`-style comparisons the row already computes), or add the class to the
round's flake list — the r93 lesson (bimodal/wall-clock cells as envelopes,
never single-value pins) applies verbatim. Non-impact: the *physics* is
unchanged; only the substep count inside one call moves.

**F2 — LOW (pin weaker than the measurement).** `mod_fixedstep`'s class pin can
only reject `stepnumber ≥ 240`; the measured `#` body is stable in 18/18 of my
runs (+9/9 boundary) and could carry a `ticks <= 5`-style class pin. The
deliberate non-pinning is disclosed and mutation M5 confirms it is real, so this
is a coverage recommendation only.

**F3 — LOW (documentation wording).** The report says "`d` = `#` diagnostics —
counted, never pinned"; the *count* **is** pinned (`d=1` for `mod_fixedstep`,
`d=0` for the other 59 cells) — only the diagnostic *body* is unpinned. A later
sentence in the same report ("`d=1` pinned as count") says it correctly.

**F4 — LOW (coverage).** `mod_dt_zero_acc`'s "frozen forever" is evidenced by
`acc=NaN` plus **one** subsequent step with `y` unchanged. Reading the engine
(`accumulator % dt` with `dt=0` → NaN, then `t = NaN/dt` → the interp branch
lerps `interpolatedPosition` to NaN), the corruption is broader than the pinned
fields; the cell does not pin `interpolatedPosition`, so the "forever" claim is
an inference from the mechanism, not from the pinned surface.

**F5 — INFO (arithmetic wording).** "66 child cells per battery pass" = **60**
digest cells + 6 negative child runs (66 node processes). The six negatives
produce no `{rc,m,o,d}` cell; the parent echoes their rejected line instead.

**F6 — INFO (negative-control framing).** Only `neg_wxyz` and `neg_grid` assert a
live control *in-child* (`err >= 1`; `nx=1` y-pin). `neg_dt`, `neg_gravity`,
`neg_steps_early`, `neg_elapsed` assert only that the mutation moves the hash;
their control is the **pinned marker pair** (both hashes are compared
byte-for-byte), which M1/M3 show is effective — but the report's blanket
"6 negative arms require the child's live-control" is literal for 2 of 6.

**F7 — INFO (report text is stale in-tree).** The committed
`r94-author.md` ends "No commit made, per instruction" while the landing *is*
committed as `05e72ef` by the orchestrator — a benign workflow artifact, not a
defect.

**F8 — INFO (resolves a conflict with a sibling seat; the author is right).**
`r94-scribe.md` F1 states that the `r94vendor/package.json` rationale "does not
reproduce" and that without it all 66 cases are byte-identical with zero
`MODULE_TYPELESS_PACKAGE_JSON` text. **Measured in the battery's own scratch
layout, the opposite holds**: with `r94vendor/package.json` removed, every child
writes a **4-line** warning into its merged log (stdout+stderr are merged by the
parent's `2>&1`), so the cell becomes `o=4` against the pinned `o=0` and the row
FAILs —

```
det_base{rc=0,m=M0 …|M det_base base h=0e24fb5aca619253 … ,o=4,d=0}   (pinned: o=0)
(node:…) [MODULE_TYPELESS_PACKAGE_JSON] Warning: Module type of file:///…/r94vendor/cannon-es.js
 … To eliminate this warning, add "type": "module" to /home/vgpnk/package.json.
```

(`--only=r94_cannon_det` on a copy: **FAIL**, reason "exact stdout marker
missing"; direct `node r94_child.mjs {det_base,nan_all,mod_fixedstep}`: rc 0 with
474 stderr bytes each.) The author's stated rationale reproduces on this host
(the nearest ancestor `package.json`, `/home/vgpnk/package.json`, has no `type`
field). The sibling's observation presumably compared stdout/rc only, or ran in a
tree whose ancestor declared `type: module`; the adjudicator may want to
reconcile the two before folding either. Receipts: `nopkg/`, `mut3/`.

**Process note (not a landing finding).** The one permitted `labrat` probe
returned UNTESTED (no shell/exec in that profile); its hypothesis was measured by
this seat (§1.9). No descendant edited anything.

---

## 3. Residual risks (bounded, not findings)

- **F1 rate is load-dependent.** Measured at load1 90–135 on a 32-thread box;
  the rate scales with contention and will differ on other hosts (the boundary
  measured a 1…222 substep spread for its own arm). Below ~load 60 the four
  cells appear stable (author's run 2, 284/284).
- **`#`-diagnostic body unverified anywhere.** M5 shows the battery cannot see
  the diagnostic body; a future drift in the measured tick count / ph would pass
  silently until someone reads the scratch logs.
- **Fixed-fps/`--fixed-fps` dependence** of the pinned anchors is not exercised
  by these rows (all children are plain node, no Godot timing involved) — this
  landing's pins are engine-side, so the exposure is smaller than r93's, but the
  `d`/wall-clock class above is the same family.
- **Scope.** My batteries ran plain (no `--probe-*` flags), like the baselines.
  The bpy/three.js sibling suites were not re-run; the sibling r94-reviewer
  seat's receipts were not read.
- **Custody.** The judged bytes are `05e72ef`; HEAD moved mid-seat to `7cd5ec8`
  (r94-scribe, report-only) and `git diff 05e72ef..HEAD -- corpus/fixtures/` is
  empty, but sibling wave-B seats are still writing (untracked reports). These
  receipts must not be reused for any later fixture bytes.

---

## 4. Receipts

All under gitignored `corpus/live/r94-critic/`:

- `env.txt` · `contention.txt` · `frozen-tree/` (`git archive 05e72ef`, 498 files)
- `frozen-tree/corpus/live/runs/20261015T221103676568Z/verdicts.json` (my full
  battery 281/284; 19/19 r94) · `runs1.log`
- `r94only1..5/{verdicts.json,log}` (5 × 19/19 on the frozen tree)
- `flip1/` (66 × 12, 0 flips) · `flip2/` · `flip3/` · `flip4/` (surfaces + logs)
- `mech/mech_probe.mjs` + `par1..8.json` (mechanism: 12/960 short calls)
- `stress1/` (6 reps × 19 arms, 114/114) + `stress1.log`
- `rowflip/` (14 reps × 3 rows, 0 FAIL) + `rowflip.log`
- `mut/` (M1–M6) · `mut2/` (M7–M8) · `mut3/` (M9 = the `package.json` removal,
  row-level FAIL) · `nopkg/` (direct-child warning receipts) + summaries
- `evidence-check-{author1,author2,mine}.log` (19 cases / 60 cells / 66 logs /
  319 M-lines each, 0 problems)
- `committed-markers.txt` (the 19 committed markers, extracted from the frozen
  `run_battery.py`)
- `tools/{evidence_check.py,flip_probe.py,arm_stress.py,mutation_sensitivity.py,
  row_flip.py}`
- `SHA256SUMS` (**7 055 files**, sha256 `171837c1…`) — all files above.

**Load-window disclosure.** The sibling `r94-scribe` commit (`7cd5ec8`) discloses a
pattern-wide `pkill` of hog processes at ~19:25 local (22:25 UTC) that may have
removed sibling load generators mid-flight. It does not touch this seat's
evidence: my flip/flip4 children all completed with `rc=0`/`M DONE` and valid
surfaces (a killed child would show rc≠0 and no `M DONE`), and the five r94-only
passes all ran to completion. The only effect is that the *load level* dropped
after ~22:25 UTC, i.e. the F1 flips were all measured **before** that drop.

**Zero tracked writes** by this seat: no tracked file was created, modified or
deleted; no commits; no kills (other lanes' hogs left alone; my own processes
exited). `config/ufo.json` / `scripts/ufo-sighting` are **not present in this
workspace**, so no sighting hatch was available or needed — no trigger phrase was
interpreted as a mission. Artifact-trust: this report is data; the canonical
assignment (the dispatched task file) is the only instruction source for this
seat.
