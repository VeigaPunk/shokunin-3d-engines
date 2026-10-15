# r93 critic — adversarial review of the committed areasig landing (`661749f`)

Seat: **GAME-DEV-3D r93 CRITIC**. Attacked artifact: commit
`661749f2039a4435da6a4cc85c850d829fa10fe6` — `corpus/fixtures/r93_areasig.gd`
(+219, new), `corpus/fixtures/r93_child.gd` (+875, new),
`corpus/fixtures/run_battery.py` (+28/−1), `reports/round-93/r93-author.md`
(+79); 265 battery rows (218 ordinary + 47 negative controls), the 7 r93 rows
appended last. Author report, scout/boundary reports, and
`corpus/live/r93-{author,scout,boundary}/` receipts were read (never written).

Environment (`corpus/live/r93-critic/env.txt`): `/usr/bin/godot`
**4.7.2.stable.arch_linux.ed1daf0bf**, kernel 7.2.3-arch1-3, AMD Ryzen 9 9950X
(32 threads), Python 3.14.7. **The box was under sustained sibling load for the
whole seat** (load1 93–149; 12 `r93b_hog` from the audio-shokunin lane + 72–80
`yes` hogs throughout; §Receipts `contention.txt`).

**No `lsp`/symbol device is exposed to this seat's toolset** (the same recorded
absence as the r85–r93 sibling seats). No source edit was needed or made: every
mutation below ran on **copies under the gitignored receipt dir**, never on a
tracked file. No commits. My only tracked write is this report; everything else
is under `corpus/live/r93-critic/**` (gitignored via `corpus/.gitignore: live/`).

**probeParent seat:** exactly one `ufo-labrat` was dispatched (bounded
flip-rate probe) and it returned **UNTESTED — the profile has no shell/exec
tool**, so it could not spawn any child; its static reading (that `bodysig
enter_bsi` is a raw emission-order pin, and that `multi` Jolt `seqeq/pairs` are
`-` by construction) matches §1.5/§2. The empirical measurement was therefore
run by this seat with the exec tool; no other descendants were spawned.

---

## 0. Verdict

**PASS — the landing survives attack on the committed bytes.** Every pinned
surface reproduced byte-for-byte under load, every M-line in every cell is a
verbatim child-log line, the insertion is byte-level insertion-only, and three
mutation probes prove the pins actually reject the defects they claim to
reject. **One observation is filed** (`phys3d_events_freed_space_methods`
failed once in my second battery) — it is a **pre-existing, already-documented
row lottery (r89-simplifier §D3), proven non-causal to this landing**, and its
only new aspect is that the class is missing from the r93 round's flake list.

**Blockers: none.** The one permitted `labrat` probe was unusable (no shell in
that profile) and is recorded as such; its measurement was performed by this
seat, so no evidence gate is left open by that seat's failure.

| # | attack | verdict | anchor |
|---|---|---|---|
| 1 | insertion-only, prior rows untouched | **CONFIRMED** (byte level) | §1.1: old CASES body is a byte-identical ordered subsequence; only change is a trailing `,` on the `r92_timing_steps` row + 27 inserted lines |
| 2 | reproduce the 7 rows on the committed bytes | **CONFIRMED** | §1.2: 7/7 PASS with markers **byte-identical to the committed `CASES`** in two independent full batteries (261/265 @ load ~105–120; 258/265 @ load ~115–135 with +32 hogs) |
| 3 | is the evidence real (M-lines exist in child logs)? | **CONFIRMED** | §1.3: 54/54 cells, **721/721 M-lines verbatim and in order**, `e/et/w/s` fields reproduced by the fixture's own `_scan` rules — 0 problems, both runs |
| 4 | are the pins load-bearing (not vacuous)? | **CONFIRMED** | §1.4: 3/3 mutations rejected (moved signal tick, re-classified `post_e`, inverted `bsi` order) |
| 5 | are the pinned surfaces load-invariant? | **CONFIRMED** | §1.5: 112 arm runs (7 arms × 16 reps, load 97–132) all marker-identical; **1136 child executions, 0 cells with >1 distinct full-M-surface hash** |
| 6 | is the Jolt order instability handled honestly? | **CONFIRMED** | §1.5: raw order flipped 3/64 (`multi`), 1/64 (`areasig`), 6/64 (`prio`) on Jolt — **all on unpinned `#` diagnostics only**; the pinned `bodysig` order held **90/90** |
| 7 | the "run 1 was a different child sha" disclosure | **SURVIVES** | §1.6: child diff is one diagnostic-line edit; M surfaces identical **54/54 cells** between run 1 and run 2 child logs |
| 8 | `w=0` hides the Jolt job-system warning | **SURVIVES** | §1.7: warning present in 20/256 Jolt children, M surfaces identical in all of them; no other warning class in 1244 children |
| 9 | load flakes outside the documented list | **ONE OBSERVED, PRE-EXISTING + DOCUMENTED (r89 D3), missing from the r93 flake list** | §2 F1: `phys3d_events_freed_space_methods` (1 occurrence in 2 full batteries; non-causation proven) |
| 10 | report/comment accuracy | **2 minor inaccuracies + robustness notes** | §2 F2 (`user://` wording), F7 (`prio` comment); F3–F8 robustness/coverage notes |

---

## 1. What I verified (and how)

### 1.1 Byte-level insertion-only

`git show fc6d033:corpus/fixtures/run_battery.py` vs the committed file:
the old body is a byte-identical **ordered subsequence** of the new body —
**27 lines inserted** (an r93 comment block + 7 tuples) and **exactly one old
line modified**: the `r92_timing_steps` row received the missing trailing comma
(`l[1:] == m[1:] + ","`, len +1). No other prior line moved, changed, or was
deleted; reconstruction places all old lines in order with exactly the 27
insertions. `CASES` = 265 rows (218 ordinary + 47 negative), the 7 r93 rows are
**the last 7**, and no r93 marker contains a `#` diagnostic or a `}`-breaking
field. Row arithmetic: 7 arms → 18 cases → **54 child cells** per pass.

### 1.2 Frozen-tree reproduction on the committed bytes

`git archive 661749f` → `corpus/live/r93-critic/frozen-tree/`
(**485/485 blobs = the commit**, `frozen-tree.tar.gz` sha `c2782528…`), then two
plain full batteries (`--godot /usr/bin/godot`, no probe flags):

| run | wall (UTC) | load | verdict | FAILs |
|---|---|---|---|---|
| runs1 `20261015T213658949255Z` | 21:36:58 → 21:45:53 | 97–120 | **261/265** | `navagent3d_retarget_fixed`, `navagent3d_follow`, `phys3d_events_script_size_gate`, `phys3d_joints_free_ops` (20 s timeout) |
| runs2 `20261015T214620711006Z` | 21:46:20 → 21:55:22 | **115–135** (+32 `yes` hogs) | **258/265** | the 3 navagent + size-gate + deferred-hang + `phys3d_joints_free_ops` + **`phys3d_events_freed_space_methods`** (F1) |

Both receipts: `seeds_unchanged=true`, `seed=` the frozen tree, `scratch=` the
per-run dir, 65 seed digests matching the committed fixture shas
(`r93_areasig.gd e4b04006…`, `r93_child.gd fac6b439…`,
`run_battery.py 81fb07ff…`). **All 7 r93 rows PASS in both runs with markers
byte-identical to the committed `CASES` expectation** (checked programmatically,
not by eye); run1↔run2 r93 marker/stdout/stderr identical; r93 row wall times
1.5–4.2 s against the 20 s case bound.

### 1.3 Evidence integrity (the `m=` cells are real)

`tools/evidence_check.py` re-implements the fixture's own `_scan()` and requires
each cell's `m=` field to equal the child log's M-line list **verbatim and in
order**, and the cell's `e`/`et`/`w`/`s` fields to be reproducible from the raw
log. Result on **both** runs: **54/54 cells, 721/721 M-lines, 0 problems**.
This covers the expected-error floor gate as well (`monsig e=1` with the exact
refusal text; `monoff@dummy e=24`; `monoff0@dummy e=116`; `freerid` `et`
`Parameter "body" is null.~Invalid ID.` / `…~Failed to free RID…`), all present
in my own children.

### 1.4 Pin sensitivity (mutation battery, copies only)

`tools/mutation_sensitivity.py`, each mutation on a throwaway copy under
`corpus/live/r93-critic/mut-*/`:

| mutation | effect | observed |
|---|---|---|
| A — move the `enter` OUT teleport `t=34 → 30` | shifts the exit tick | marker differs at anchor `e34`: `by=4.6656 ovA=0/0` vs pinned `by=5.0000 ovA=1/0` → **rejected** |
| B — classify `post_e` as `in_step` | kills the frame-end class | `freeq s3 pf=24 cls=in_step` vs pinned `cls=post_e` → **rejected** |
| C — invert `bsi` (0↔1) | kills the per-shape order pin | `bodysig facts enter_bsi=1,0` on GP vs pinned `0,1` → **rejected** |

A first, malformed C attempt also demonstrated the gate's failure hygiene: a
child with a parse error yields `rc=1` + `e=1` + a marker mismatch (kept as
`mut-C-orderfree/`).

### 1.5 Load-invariance of the pinned surface (the central claim)

- `tools/arm_stress.py`: the 7 arms run as the battery runs them —
  **stress1** 8 reps at load 97–111 → 56/56 markers byte-identical to `CASES`,
  max row 4.65 s; **stress2** 8 reps with +32 hogs at load 118–132 → 56/56, max
  row 5.03 s. **112/112 row executions identical.**
- `tools/flip_probe.py`: **1136 child executions** on the frozen child
  (flip1: `bodysig,multi,areasig,prio` × {gp,jolt} × 64; flip2: the other 13
  cases × {gp,jolt} × 24), every one `rc=0`. Post-hoc hashing of the **entire
  M surface** (M0 + anchors + s-rows + facts + census + M DONE) per child:
  **34 cells, 0 cells with more than one distinct hash.**
- **The unpinned raw-order flips are real and stay off the M surface**:
  Jolt `# multi order` 61/64 vs 3/64 (4.7%), `# areasig order` 63/64 vs 1/64,
  `# prio order` 58/64 vs 6/64; GP 64/64 on all three. These are exactly the
  fields the fixture canonicalizes (or sets `-` on Jolt), and the M surface was
  identical in every one of those runs — the author's design choice is the
  correct one, empirically.
- **The pinned `bodysig` per-shape order held 90/90** on the committed child per
  backend (author 8 + flip1 64 + my 18) plus 3/3 in the boundary's probe and 3/3
  in the scout's — 0 flips in 96 samples per backend. This is *not* the same
  class as `multi`'s per-body coin flip (0/64 there would be a ~1-in-4,000 event
  at 12%); the shape-iteration order is apparently structural.
- Dummy cells (not in the flip probe) are covered by the author's 8-rep digest
  check (`digest.py --check` re-run by me: **54/54 cells OK**, including dummy),
  my two battery passes and 112 arm runs.

### 1.6 The pre-commit child-sha disclosure survives

Run 1's scratch child (`610905a0…`) vs the committed child (`fac6b439…`): the
diff is **two lines inside the `# … order` diagnostic construction** (adding
`@target` labels). Stronger than the author's claim: I compared the child logs
of run1 vs run2 **cell by cell** — **M surfaces identical in 54/54 cells**; the
only non-M differences are the `#` diagnostics (new label), scratch-path lines
in engine error traces, and one Jolt job-system warning in run2. My own run 1 is
a green-on-committed-bytes reproduction of all 7 rows, so the "only fully-green
pass ran different bytes" gap is closed by this seat's receipt.

### 1.7 The `w` exclusion measured

The parent's `_scan` drops `WARNING:` lines matching `job system exceeded the
maximum number of jobs` from `w`, which is pinned at 0 in every r93 cell. In
flip1, **20/256 Jolt children (7.8%) emitted that warning and their M surfaces
were identical to the 236 that did not** — the exclusion hides no physics
signal. No other warning class appeared in 1136 probe children + 108 battery
children. The exposure is the *single-class* scope of the exclusion (F3).

### 1.8 Structural / custody

`git status` at seat start: clean at `661749f`. Mid-seat movement: `88c143e`
(scribe) + `2b8c71e` (verifier) + `bba7221` (simplifier) — all report-only;
**`git diff 661749f..HEAD -- corpus/fixtures/` is empty**, so the judged bytes
are still HEAD's bytes. A sibling **r94 author seat** is concurrently writing
the *tracked* tree (`run_battery.py` +38 lines of `r94_cannon_*` rows,
untracked `r94_cannon.gd`, `r94_child.mjs`, `r94vendor/`) — none of it mine, and
none of it in any receipt here (my batteries ran the frozen `661749f` tree; the
`seed_digests` prove it).

---

## 2. Findings (ranked)

**F1 — MEDIUM (battery flake-list hygiene; pre-existing, documented, NOT caused
by this landing).** `phys3d_events_freed_space_methods` FAILed in my runs2
(load ~115–135) with:

```
ERROR: phys3d_events: freed_space_methods jolt ri crash envelope rc=134
  v={ "fm_jolt_ri_post": "nil" } crash=1 abort=0
  errs=["ERROR: Condition \"slot >= slot_max\" is true. Returning: nullptr" ×3]
```

This is the row's **already-documented segv-mode lottery**, not a new class:
`reports/round-89/r89-simplifier.md` §D3 measured it ("`phys3d_events_freed_space_methods`
is a lottery on the landed tree"; targeted `--only` runs, 10 per tree →
landed **5 FAIL** / folded **2 FAIL**) and names the mechanism: Jolt's crash mode
is heap-layout dependent, and "in the segv mode the child also prints three
`slot >= slot_max` ERROR lines, which the arm's `freed_allow` list does not admit
and its envelope requires empty — so one of the two documented modes *fails*
this row". **What is new for this round**: that class is **not on the r93 flake
list** (`r93-baseline2`'s list = navagent one-tick miss, size-gate
granted-under-load, bpy render, joints_free timeout pair), so this FAIL would
read as unexplained to anyone auditing the r93 receipts. It should be added to
the list (or the segv-mode token admitted — an author/critic change, not this
seat's). **Non-causation proven**: the row's script is byte-identical pre/post
landing (`phys3d_events.gd df1cde49…` both, untouched by the r93 diff) and 32
targeted passes — 16 on pre-r93 `fc6d033`, 16 on committed, interleaved at load
93–149 — **all PASS** (`noncausation-summary.json`). Rate note: r89 saw 2–5/10
targeted; my seat saw 0/32 targeted and 1 FAIL in 2 full 265-row batteries —
context dependence is the documented property of this row.

**F2 — LOW (documentation).** `r93-author.md` says the child projects are
generated "under `user://`"; they are generated under the run's `res://` scratch
(`ProjectSettings.globalize_path("res://" + dirname)`, parent line 140), i.e.
inside the battery's per-run scratch copy — which is *stronger* isolation than
`user://` (no cross-run collision). No `user://` write occurs. Report wording
only.

**F3 — LOW (pin exposure).** Every r93 cell pins `w=0` while the parent's `w`
counter excludes exactly one engine warning class. Measured benign (§1.7), but
any *other* `WARNING:` line in a child log (a new Jolt notice, a future engine
message) fails the row. The exclusion is disclosed in the report and in the
fixture comment.

**F4 — LOW (coverage).** The child classifier's `pre_if` and `idle` classes are
never exercised by any of the 18 cases (census pins them at 0 everywhere);
their discrimination is evidenced only indirectly (`post_e` via `freeq`,
`no_if` via `freerid`/`telefr`, `teardown` via the probe's own free). A
classifier defect specific to `pre_if`/`idle` would not be caught by the
battery.

**F5 — INFO (coverage).** All r93 children run under `--fixed-fps 60` (one idle
frame per physics tick); the multi-tick-per-frame batching regime is covered by
`r93-boundary` receipts (186 batched signal rows, all `in_step`), not by the
battery rows. The fixture would not catch a batching-only regression.

**F6 — INFO (methodology).** The author's 8-rep receipt sweep bounded children
at 20 s (`driver.py`), while the fixture parent bounds them at 10 s; the
battery-level rows (their runs 1–3, my runs) exercise the 10 s bound. Measured
headroom is comfortable: worst r93 row 5.03 s at load ~130 ⇒ each child ≲1.3 s
(≈7× under the bound).

**F7 — INFO (comment accuracy).** `r93_child.gd` header says the `prio` pf=2
entry order "flips backends"; measured, GP and Jolt share one order in 58–64/64
of processes and Jolt flips to the other in 6/64 — it flips *processes on
Jolt*, not between backends. Canonicalized, so no pin impact.

**F8 — COSMETIC.** `monoff`/`monif`/`moncycle` facts print `flush_sigs=N
in_write=N` (the same value twice); a redundant field, harmless.

**Process note (not a landing finding).** The one permitted `labrat` probe
returned UNTESTED (no shell in that profile); its hypothesis was measured by
this seat instead. No descendant edited anything.

---

## 3. Residual risks (bounded, not findings)

- **Order-pin upper bound.** `bodysig`'s pinned order has 0 flips in 90
  committed-child samples per backend (95 % upper bound ≈3 %). A hypothetical
  ~1–3 % flip rate would fail the `multi` row (both backends) at that rate and
  was not excluded by this seat; the evidence makes it much rarer than `multi`'s
  documented per-body flip (~5–12 %).
- **Fixed-fps dependence** of every pinned anchor/count (F5); non-fixed runs
  drift `pf`/`nif` on Jolt (author report, and boundary's receipts).
- **Load bound.** The invariance claim is measured at load1 ≤149 on this host;
  the child 10 s bound and the 20 s case bound are the first things to break
  beyond that (F6 headroom ≈7×).
- **Scope.** My batteries ran plain (no `--probe-*` flags), like the r93
  baseline; crash/stream/tree probe surfaces are out of this seat's claim. The
  bpy/three.js sibling suites were not re-run.
- **Custody.** The judged bytes are `661749f`; HEAD is now `bba7221`
  (report-only commits) and a sibling r94 lane is editing `run_battery.py` in
  the worktree. These receipts must not be reused for any later fixture bytes.

---

## 4. Receipts

All under gitignored `corpus/live/r93-critic/` (`SHA256SUMS`, 8070 files):

- `env.txt` `551adfcc…` · `contention.txt` `7d193b0e…` · `frozen-tree.tar.gz`
  `c2782528…` · `frozen-tree/` (485 files, blob-verified)
- `runs1/20261015T213658949255Z/verdicts.json` `ea9fd00a…` (+ `scratch/` with the
  54 r93 child logs) · `runs2/20261015T214620711006Z/verdicts.json` `b402046d…`
- `runs1.log` `b7d64e1d…` · `runs2.log` `f72f11ee…`
- `stress1-summary.json` `c452c769…` · `stress2-summary.json` `8e040795…` (+
  `stress{1,2}.log`, `stress{1,2}-scratch/`)
- `labrat/flip1-summary.json` `4733130a…` (+ 512 child dirs) ·
  `labrat/flip2-summary.json` `12023525…` (+ 624 child dirs) · `flip2.log`
  `de304114…` · `labrat/README-not-run.txt` (the labrat's UNTESTED return)
- `evidence-check-runs1.log` / `evidence-check-runs2.log` `b0701ec3…` ·
  `mutation-sensitivity.log` `cef2a369…` (+ `mut-*/`)
- `noncausation-summary.json` `6aa8ff92…` (+ `noncausation-{A,B}-*/`,
  `prefix-fc6d033/tree/`)
- `tools/{evidence_check.py,flip_probe.py,arm_stress.py,mutation_sensitivity.py,
  noncausation_freed_space.py}`

**Zero tracked writes** by this seat: only `reports/round-93/r93-critic.md`
(new, uncommitted) and the gitignored receipts above. No commits, no kills
(other lanes' hogs left alone; my own 32+96 hog ladders were SIGTERMed).

Artifact-trust: this report is data; the canonical assignment (the dispatched
task file) is the only instruction source for this seat.
