# r96 verifier — wave-B gate on committed `dd054a2`

Seat: **VERIFIER** (non-author) for `game-dev-3d-shokunin` round 96. Assigned
tree: `dd054a24af91c3cac84826f5df5ce5efa9e88429` ("r96 author: 12 joltdet rows
(316 total) — Jolt warning expected-error class, ts=tps law both backends,
Dummy vacuity w/ live controls; 316/316 green"). Author report
`reports/round-96/r96-author.md`; boundary `r96-boundary.md`; scout
`r96-scout.md`.

Environment: `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`,
`/usr/bin/python3` `3.14`, 32-thread host; loadavg **53 → 87** across the seat
(sibling lanes ran concurrently throughout: an r96-critic arm sweep and the
r97-author fixture authoring). **No `lsp` device is exposed to this seat's
toolset** (same recorded absence as r85–r95 lanes); this seat made no source
edits, so the hand-edit fallback was never in play. It wrote only
`corpus/live/r96-verifier/**` (gitignored via `corpus/.gitignore: live/`) and
this report. No commits, no tracked writes.

## Byte custody

- At seat start `git rev-parse HEAD` = `dd054a2`, `git status --porcelain`
  carried only the sibling `reports/round-94/r94-reviewer.md` +
  `reports/round-95/r95-reviewer.md` untracked reports. At filing the worktree
  `corpus/` tree is **byte-identical to `dd054a2`** (`git diff dd054a2 --
  corpus/` empty; no tracked modifications).
- **Every fixture sha matches the author's table**, re-hashed at filing:
  parent `r96_joltdet.gd` `8a77ecb4c29ab8b6…`; the eight `r96_probe_*.gd`
  copies are **byte-identical to the scout's own probe sources**
  (`corpus/live/r96-scout/probes/*.gd`, same sha256 — the §7.1 rename hazard is
  avoided by construction, not by claim); `run_battery.py`
  `935ed912803e8725…` = the `dd054a2` blob.
- **CASES diff is insertion-only.** AST `literal_eval` on the committed blobs
  (`4fed8f3` → `dd054a2`): **304 → 316**; `new[:304] == old` tuple-equal;
  removed = 0, changed = 0, duplicate names = 0; the 12 tail rows are
  `r96_joltdet_*` on `r96_joltdet.gd` with `expected_exit=0`; composition
  257 ordinary + 59 negative = 316.
- **Mid-seat movement (documented, contained, none of it this seat's):**
  1. A sibling **r97-author** seat wrote 11 untracked `r97_*.gd` fixtures into
     `corpus/fixtures/` *during* my full run 1, so that run records
     `seeds_unchanged=false`. Reconstructed at filing: of the 83 seeds present
     at run start, **0 changed and 0 were removed**; the only delta is the 11
     added `r97_*` files. The clean re-run (`only2`) and full run 2 use the
     94-file baseline and record `seeds_unchanged=true`.
  2. Four **report-only** sibling commits landed mid-seat (`dda3e7e`
     simplifier, `de24ecc` scribe, `f6aa351` reviewer, `40f5d1d` critic):
     `git diff dd054a2 HEAD -- corpus/` is **empty**, and all r96 fixture shas
     re-verify byte-identical to the `dd054a2` blobs. HEAD moved, the assigned
     bytes did not.
- Every measurement below ran on the assigned `dd054a2` bytes.

## Per-item verdict table

| # | assigned check | verdict |
|---|---|---|
| 1 | CASES insertion-only, +12 rows, 316 total | **PASS** — strict-prefix tail insert, 0 removed/changed/dups, all 12 rows `r96_joltdet.gd` exit 0 |
| 2 | Fixture/probe custody (shas, probe copies = scout probes) | **PASS** — 9/9 shas match the author table; 8/8 probe copies byte-identical to `r96-scout/probes/` |
| 3 | r96 rows on committed bytes | **PASS** — `--only` 12/12 ×2 (seeds_unchanged=true), all 12 in both full batteries; 1.15–8.06 s per row (bound 20 s) |
| 4 | Full battery 316 rows on committed bytes | **PASS** — **run 2: 316/316, seeds_unchanged=true**; run 1: 314/316, both fails pre-existing flakes (see §2) |
| 5 | All 123 digest cells re-derived independently | **PASS** — 123/123 per pass × 4 passes: normalized sha (and pose-sha) recomputed with a from-contract re-implementation, zero mismatches |
| 6 | Aggregate cells (tscale/ffps/dummy/thread/knobs/nc) re-derived | **PASS** — all 4 passes: `FAILURES: none` |
| 7 | Encoding 1: Jolt warning expected-error class + self-gate | **PASS** — the fixture's own scanner executed on 12 synthetic streams; live census 38–48 pairs per 160-child pass, 0 orphans, positions 3–90 |
| 8 | Encoding 2: `--time-scale` is the tps law, both backends | **PASS** — 6/6 pairs `ts == ref == the tps-bake sha` from receipts |
| 9 | Encoding 3: Dummy vacuity w/ live in-cell controls; sleep1 hang rc=137 | **PASS** — 5 cells × 3 backends re-derived; hang reproduced outside the parent |
| 10 | Rep-stability of the 12 rows | **PASS** — 4 reps × 12 arms = 48/48, exactly one distinct marker per arm |
| 11 | Value provenance vs scout/boundary receipts | **PASS** — 70 cells re-derived against the scout's (54) and the boundary's (15) receipts + the nc pose surface; 0 diffs, 0 missing |
| 12 | Row sensitivity (does the gate bite?) | **PASS** — probe mutation moves the receipt, pinned-digit mutation reds the row, clean control green |
| 13 | Fixture hygiene / red flags | **PASS with LOW findings** — bounded children, validated dirnames, scratch-confined writes, fail-closed cell gate (§7) |

## 1. Batteries executed (all on `dd054a2` bytes)

| run | dir | context | totals | seeds_unchanged |
|---|---|---|---|---|
| r96-only #1 | `battery/only-20261016T005613Z/…` | load 57→77 | **12/12 PASS** | `true` (83) |
| full #1 | `battery/full-20261016T005655Z/…` | load 56→87; sibling critic sweep + r97 author | **314/316** (2 pre-existing flakes, §2) | `false` — sibling's 11 new `r97_*` files; 0/83 prior seeds changed |
| r96-only #2 | `battery/only2-20261016T054905Z/…` | load ~56 | **12/12 PASS** | `true` (94) |
| full #2 | `battery/full2-20261016T055002Z/…` | load ~56; sibling critic sweep | **316/316 PASS**, Σ 316 row elapsed 484.9 s | `true` (94) |
| arm sweep | `arms/` | 4 reps × 12 arms, load 76–86 | **48/48 PASS** | n/a |

r96-row wall times: Σ 32.6–36.2 s per pass, max 8.06 s (`ffps`), min 1.15 s —
inside the author's claimed 1.15–7.75 s band and far inside the battery's 20 s
per-case bound. 160 r96 children per battery pass (counted: joint 12, contact
16, restkin 15, tps 26, solver 17, mech 7, ts 12, ff 10, d 18, th 20, k 3,
nc 4 = **160**, matching the author's claim exactly).

## 2. The two full-battery failures are pre-existing and load-shaped

Full run 1, at loadavg 56→87 with two sibling lanes active:

- `navagent3d_retarget_fixed` (negative control) — `exit 1 != expected 2`,
  `before=(1.754246, 0.0, 1.754246)`: the documented navagent one-tick load
  flake, the same `before=1.754246` signature the author recorded in their runs
  1–3 and the r93/r94 baselines.
- `phys3d_joints_free_ops` — `TIMEOUT after 20 seconds`: the documented 20 s
  knife-edge row (15.2–20.0 s across ~50 recorded runs; the author saw it stall
  in their run 2 as well).

Neither row is an r96 row, neither fixture was touched by this round, and full
run 2 under the same kind of load was **316/316**. No r96 row ever reddened in
any context this seat ran (2 full batteries, 2 r96-only batteries, 48 arm runs).

## 3. Independent re-derivation of every digest cell

`corpus/live/r96-verifier/tools/norm.py` is a **from-contract** re-implementation
of the fixture's documented normalization (header lines 9–20): drop the banner
and empty lines, drop the exact adjacent 2-line Jolt warning at any position,
drop the benign `!is_inside_tree()` block, drop `ERROR: N RID allocations …
were leaked at exit.`; sha256-16 over `"\n".join(kept)`. It does not call the
fixture. `tools/crosscheck_run.py` maps each marker cell back to its child log,
recomputes the sha (and the pose-only sha for the two `pose` cells) and compares.

- **123/123 cells match their pins in each of the 4 battery passes** (492 cell
  checks, zero mismatches). The only three "mismatch" lines my tool prints are
  the `knobs` cell, where the fixture deliberately hashes the **key-name list**
  rather than the receipt; §5 re-derives that separately and it matches.
- Every pinned `name=value` token in the six per-child arms was also required to
  appear verbatim on the child's own receipt lines (provenance, not restatement)
  — zero violations.
- The three mandated laws were additionally re-derived numerically from the
  receipts, not just byte-compared: damping ratio `1 − d·dt` agrees to ≤1 ulp of
  float32 at 30/60/120 tps on both backends (`0.666666603 / 0.833333302 /
  0.916666698`); the support impulse equals `m·g·dt` (`0.326667 / 0.163333 /
  0.081667`, y-component, both backends); the clamp fires at `d·dt ≥ 1`
  (`lin100@30 → 0.0`, `@120 → 0.166666627`); the GP spike is ∝ 1/dt
  (`2.7 / 10.799998`); Jolt's `lv ≡ 0` at every rate; the sleep table is
  wall-clock (`64 / 126 / −1` GP, `73 / 144 / −1` Jolt); at 120 tps both
  backends end at `lv_end=0.094568834` (9 digits).

## 4. The three mandated encodings

### 4.1 Jolt warning = allowlisted expected-error class, with a real self-gate

**The fixture's own scanner was executed directly** (not read):
`corpus/live/r96-verifier/scanner/ftest/scanner_probe.gd` loads the committed
`r96_joltdet.gd`, seeds `_leak_re` as the fixture does, and calls
`_scan_lines` on synthetic streams. Measured:

```
head      w=1 m=M a|M b          (dropped at the head)
mid       w=1 m=M a|M b          (dropped mid-stream)
tail      w=1 m=M a|M b          (dropped at the tail)
nearmiss  w=0 W1 kept            (first line without its "at:" line is NOT dropped)
swapped   w=0 both kept          (W2 before W1 is NOT dropped)
case_mut  w=0 kept               (W1+"X" is NOT dropped — exact text, not a prefix)
dup       w=2                    (both pairs dropped)
errorline w=0 ue=ERROR: genuine failure     (fail channel)
script_error w=0 ue=SCRIPT ERROR: boom      (fail channel)
```

**Live census over the r96 children** (all children run `--fixed-fps 60`):
38 / 42 / 48 / 45 warning pairs per 160-child pass (24–30 %), positions ranging
**3 … 90** with 21–28 distinct positions per pass, and **zero orphan lines**
(every one of the 173 occurrences across the four passes was an adjacent
W1+W2 pair). So position tolerance is load-bearing, and the adjacency
requirement holds on live data.

**Normalized identity across warned/unwarned twins**: the `ffps` arm ran 6 Jolt
reps + a no-flag reference; the reps carried the warning **4/6** in only #1 and
**1/6** in each of the other three passes — with the warning seen at positions
16, 17 and 18 — and **all seven normalized shas were identical to the reference**
in every pass (`4492126fd9b2b3f3`), while GP was **raw**-byte-identical across
its two flagged reps and its reference (`581274d6aaf4b04c`, 0 warnings). The
raw bytes differ by exactly the two-line insertion (e.g. 2217 B warned vs
1990 B unwarned); the normalized receipt does not move.

### 4.2 `--time-scale` is the tps law, byte-identical on both backends

Re-derived from receipts (not from the parent's `eq` flag): all six pairs
`ts == ref`, and each equals the matching **tps-bake** sha in the same run:

```
pin_ts05  d24077db012d9045 == gp120 pin     jpin_ts05 4492126fd9b2b3f3 == jolt120 pin
pin_ts20  b9a237070b3ddf7b == gp30  pin     jpin_ts20 4a7005fe9791ed62 == jolt30  pin
lin10_ts05 e0963312a0e472cb == gp120 damp   lin10_ts20 f9f0bcb9f4cf4bec == gp30 damp
```

i.e. `--time-scale 0.5` at 60 tps **is** the 120-tps project and `2.0` **is**
the 30-tps project, on GP and Jolt, for a joint-position witness and a
dt-scaled damping witness. Both sides of every pair ran under `--fixed-fps 60`,
so the boundary's not-tested flag interaction is measured for these cells.

### 4.3 Dummy vacuity with live in-cell controls, and the `sleep1` hang

Each vacuity cell carries Dummy + GP + Jolt in the same cell; I re-extracted all
three readings from the three child receipts and they match the pins:

```
it_pin       d=-1.0            gp=0.0          jolt=0.0
pen_overlap  d=-0.3            gp=-0.010001    jolt=-0.02
warm_rest    d=0.600000024     gp=0.290008307  jolt=0.300000012
damp_lin10   d=10.0            gp=0.0          jolt=0.0
kin_kcontact d=0               gp=1            jolt=0
sleep1       gp_slept=126      jolt_slept=144
```

**The hang was reproduced outside the parent fixture**
(`hang/repro_hang.sh`: three one-file projects, committed probe copy, `timeout
-s KILL 2`):

| backend | rc | wall | log bytes | D0 header | DSUM | SCRIPT ERROR |
|---|---|---|---|---|---|---|
| Dummy | **137** | 2.00 s | **9,784,936** | 1 | **0** | 32,951 × `Invalid call. Nonexistent 'bool' constructor.` |
| GodotPhysics | 0 | 0.60 s | 11,326 | 1 | 1 (`slept_at=126`) | 0 |
| Jolt | 0 | 0.53 s | 11,096 | 1 | 1 (`slept_at=144`) | 0 |

This is exactly the pinned `sleep1{dummy_rc=137,hang=1,nodsum=1,d0=1,
gp_slept=126,jolt_slept=144}`. (The critic's F4 explains the magnitude spread
vs the boundary's 431 KB: `--fixed-fps` runs unthrottled, so the same probe
spams ~10 MB in 2 s here.)

## 5. Aggregate arms re-derived (all four passes, `FAILURES: none`)

- **knobs** — the 67 `physics/` key *names* hash to `874d8759ff135309` on GP,
  Jolt **and** Dummy (my own key-list extraction), matching the pin; 67 keys,
  67 props on each.
- **tscale** — 6/6 equality + cross-arm identity with the tps bakes (§4.2).
- **ffps** — 6 reps + reference: one normalized sha; GP raw-identical, 0 warnings.
- **dummy** — 5 vacuity cells × 3 backends + the two `sleep1` controls (§4.3).
- **nc** — 4 concurrent reps, pose shas identical (`298e8a9a00657651`), and the
  pose surface equals the scout's three own receipts while the *full* sha does
  not (scout r1 `368736d524799091` vs r2/r3 `e6ff0381b3ecba1d`) — the pose-only
  choice is necessary and correct, re-confirmed independently.
- **thread** — 10/10 `ref == thr` from receipts.

## 6. Provenance: the pins reproduce the scout's and boundary's own receipts

`norm.py` applied to the scout's stored receipts (`corpus/live/r96-scout/runs/`)
and the boundary's (`corpus/live/r96-boundary/runs/`), compared to my run's
child logs:

- **54 scout cells** (all six probe families, GP and Jolt, including the
  node-body joint, the solver bakes, the mechanism bakes, the kinematic
  classes): **54 MATCH, 0 differing, 0 missing**.
- **15 boundary `tps30`/`tps120` cells** (a second harness, second bake): **15
  MATCH, 0 differing, 0 missing** — the 30/120-tps rows reproduce the
  boundary's own tps receipts byte-for-byte under my normalizer.
- **nc pose surface** matches the scout's 3/3 receipts (`298e8a9a00657651`).

This is my own sample (the author's `crosscheck-run1.log` claims 93/93
referenced cells; my 70 are independent re-derivations, all green).

## 7. Hygiene, hazards, and three LOW report-accuracy findings

Hygiene (verified in the committed fixture, not assumed): every child runs
under `timeout -s KILL` (14 s batch bound, 2 s for the hang cell) with the
battery's 20 s per-case bound above it; child dirnames are charset-validated
and `..`/`/`/`:` rejected; child projects and logs are written under the scratch
`res://` only; the hang log is read through a 128 KiB cap and removed; leftover
children are killed; a cell that is not rc=0 or carries an unexpected
ERROR/SCRIPT ERROR is not printed as PASS, so the battery's exact-marker check
fails closed. 160 child dirs per pass, 159 logs (hang removed), no stray files
in the scratch root beyond the fixture copies.

**LOW-1 (report accuracy, not a landing defect).** The fixture header
(lines 19–20) says an unexpected "new warning" fails the arm. Measured false:
a non-allowlisted `WARNING:` line goes to the **hashed stream** (`ue` stays
empty), so the arm still prints PASS — the exact-marker check is the layer that
fails. Same for a space-indented `ERROR:` line; only a column-0 `ERROR:`/
`SCRIPT ERROR` reaches the fail channel. (Independently corroborates the
sibling simplifier's F-2.) The landing is still fail-closed *at the battery
layer*: any value change moves the marker.

**LOW-2 (blind spot).** `_scan_lines` computes `lk`/`pe` counters but they are
never printed, so the dropped classes (banner, allowlist pair, kin block,
RID-leak notice) have no census on the pinned surface: a *new* leak-shaped
notice would be dropped silently without changing the sha. The regexes are
narrow and no physics is affected. (Same observation as the simplifier's SP1-4.)

**LOW-3 (coverage, future-refactor risk).** `r96_joltdet_thread` pins only
`ref == thr`; it never pins the effective knob value, so a refactor that dropped
the `THR` line would keep the row green. I verified the knob **is** effective in
this landing: with `[physics]` + `3d/run_on_separate_thread=true` the settings
dump reads `physics/3d/run_on_separate_thread = true`; the alternate spelling
`physics/3d/...` *inside* the `[physics]` section is the no-op (it becomes
`physics/physics/3d/...` and leaves the real key false). This confirms the
critic's F1 mitigation and adds the spelling precision.

Also confirmed (critic F2): the `node_init` cells' pinned `space_a`/`space_b`
are `RID(0)` on **both** backends, so those two fields do not discriminate; the
drop-vs-bind difference lives in the hashed trajectory (the sha differs). The
pin is real, the compressed wording is the risk.

## 8. Sensitivity: the rows are load-bearing

`mut/mutation_checks.sh`, bounded, on scratch copies:

- **M1 — probe mutation** (`r96_probe_iters.gd`, teleport `1.7 → 1.71`): the
  receipt moves (`max_gap 0.3 → 0.29`, sha `581274d6… → 6c1c30d1…`); the
  fixture still prints PASS (its gate is "no unexpected error lines"), and the
  **battery row fails on its exact-marker check** — the value surface is derived
  from the probe, not restated.
- **M2 — pinned-value mutation** (one sha digit in `run_battery.py`):
  `FAIL r96_joltdet_joint … exact stdout marker missing`, battery exit 1.
- **M3 — clean control** (same copy, no mutation): PASS with the pinned values.

## 9. Files changed / receipts

**No tracked file was written by this seat** beyond this report
(`reports/round-96/r96-verifier.md`); nothing committed. Receipts
(`corpus/live/r96-verifier/`, gitignored, **11,619 files, 221 MB**, hashed in
`MANIFEST.sha256`):

- `battery/{only-…,full-…,only2-…,full2-…}/…/verdicts.json` — the four
  batteries; full run 2 = 316/316. Sha256s: only
  `772f271f502df234…`, full `06c8bc406f4e9911…`, only2 `9d21a5e42fe62e3a…`,
  full2 `0629adb6c85af248…`.
- `tools/{norm.py,crosscheck_run.py,independent_arms.py,marker_stability.py}` —
  the independent re-implementations (shas in the manifest).
- `logs/{crosscheck-*,independent-arms-*,marker-stability}.log` — 123/123 ×4,
  `FAILURES: none`, 48/48 markers.
- `arms/` — 4 reps × 12 arms (48 `.out`/`.err` + `sweep.log`), one distinct
  marker per arm, rc=0 everywhere; `#` diagnostics show the expected variation
  (ffps `warn=1/6,2/6,4/6`, nc `0/324` ×3 and `39/324` ×1).
- `scanner/scanner-probe{,2}.log` — the fixture's own scanner executed on 12
  synthetic streams.
- `hang/` — the out-of-fixture hang reproduction (dummy 9.78 MB → 1 MiB head
  sample + `child-dummy.stats.txt`, GP/Jolt controls, `repro-*.log`).
- `mut/` — M1/M2/M3 and their outputs.
- `thread/` — the knob-key check (§7 LOW-3).

## Remaining risks / blockers

- **The allowlist is probabilistic and normalization is mandatory.** 24–30 % of
  r96 children carried the warning in these four passes, at positions 3–90; a
  raw-byte audit that does not normalize will report false divergence on ~1 in
  4 Jolt `--fixed-fps` receipts (re-measured, same class as boundary §3). The
  rows themselves normalize, so this is a fleet-consumer hazard, not an r96 one.
- **LOW-1/LOW-2/LOW-3** above (report wording, dropped-class census, thread-knob
  coverage). None affects the reproducibility of any pinned value.
- **Pre-existing flakes** (`navagent3d_retarget*` one-tick `before=1.754246`;
  `phys3d_joints_free_ops` 20 s knife-edge) remain the only rows observed red in
  a full battery; neither is an r96 row, and full run 2 was 316/316.
- **Host-scoped pins**: `/usr/bin/godot 4.7.2.stable.arch_linux.ed1daf0bf`,
  this gcc/float build, this 32-thread host — same host-pin class as prior
  rounds.
- **Sibling lanes** (r97 author fixtures; r96 critic sweep) ran concurrently
  throughout; contained and attributed in Byte custody. No stray process of
  this seat remained at filing; all children were under `timeout -s KILL`.

## Verdict

The insertion is clean (304 → 316, strict-prefix append, zero prior rows
touched, 59 negatives preserved), the eight probe copies are byte-identical to
the scout's own probes and the parent fixture's sha matches the author's claim,
all 123 digest cells re-derive **independently** (492/492 across four battery
passes) with matching shas and verbatim field provenance, all three mandated
encodings hold under live attack — the allowlist is exact-text, position-
tolerant and self-gated (the fixture's scanner executed directly; 173 live
occurrences, 0 orphans), `--time-scale` is byte-identical to the tps bakes on
both backends, and the Dummy vacuity carries live GP/Jolt controls with the
`sleep1` hang reproduced outside the parent at rc=137 / no DSUM / 9.78 MB spam
— and 70 pinned cells reproduce the scout's and boundary's own receipts. The
committed fixture is byte-stable: 48/48 arm runs (one marker per arm), 12/12
r96 rows in two `--only` batteries, and a **316/316 full battery with
`seeds_unchanged=true`**. The two full-run-1 failures are the documented
pre-existing load-shaped flakes on rows this round did not touch. The three LOW
findings are report-accuracy/coverage notes, all fail-closed at the battery
layer.

**VERIFIED** — committed `dd054a2` clears the wave-B gate.
