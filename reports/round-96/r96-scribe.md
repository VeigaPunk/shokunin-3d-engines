# r96 scribe — custody + consistency audit of the committed r96 joltdet landing (`dd054a2`)

Seat: GAME-DEV-3D r96 SCRIBE. Repo `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`.
Audit window: HEAD **`dd054a24af91c3cac84826f5df5ce5efa9e88429`**
(`2026-10-15 21:55:12 -0300`, *"r96 author: 12 joltdet rows (316 total) — Jolt warning
expected-error class, ts=tps law both backends, Dummy vacuity w/ live controls;
316/316 green"*), `git status --porcelain --untracked-files=all` = **2 lines** at audit
start (`?? reports/round-94/r94-reviewer.md`, `?? reports/round-95/r95-reviewer.md` —
r94/r95 wave leftovers). Read-only audit plus **one fresh full battery run of the
committed bytes under self-owned load** (§4), **one r96-only run** (§5), **one
independent 4-cell provenance replay** (§6.3), and **one dispatched read-only `labrat`
probe that could not execute** (§8). No fixture, runner, contract, axis, or route
touched; **no commits**. Receipts: `corpus/live/r96-scribe/` (gitignored,
`corpus/.gitignore:1: live/`). No `lsp` device is exposed to this seat and this seat
made no source edit at all, so the hand-edit fallback was never in play.

**HEAD moved mid-audit (disclosed).** At 01:06:04Z — after this seat's full battery
run ended (01:05:08Z) and during the r96-only run — a sibling wave-B seat committed
`dda3e7e` (*"r96 simplifier: PASS — SP1-4 -14 proven …"*, `+370` lines,
`reports/round-96/r96-simplifier.md` only). **No fixture, runner, or probe byte
changed** in that commit, so the audited artifact set is still exactly the `dd054a2`
tree; `r96-reviewer.md` (untracked sibling report) also appeared during the window.

Commit contents (`git show dd054a2 --stat`): **11 files, 2402 insertions, 0 deletions** —
`r96_joltdet.gd` +873, eight `r96_probe_*.gd` +1275, `run_battery.py` +30,
`reports/round-96/r96-author.md` +224.

---

## 1. Custody — `sha256sum -c` over all three r96 manifests

| manifest | entries | OK | FAILED | census |
|---|---|---|---|---|
| `corpus/live/r96-scout/manifest.sha256` | 2112 | **2112** | 0 | no self-entry |
| `corpus/live/r96-boundary/manifest.sha256` | 3270 | **3270** | 0 | no self-entry |
| `corpus/live/r96-author/manifest.sha256` | 545 | **545** | 0 | no self-entry; excludes battery scratch (6656 files), `ftest/` (91), itself |

All three replays `rc=0` (`custody-{scout,boundary,author}-sha-check.log`). The
author manifest covers `RECEIPTS.md`, the 3 scripts, the 4 `battery-run*.log`, the 6
`battery/*/verdicts.json`, the 8 `probes/`, the 25 `proj*` bakes (9 files each) and
**all 298 `runs/` files** — 0 `runs/` file excluded (verified by set-difference).

**Tracked-bytes custody (fixture sha256 vs the report's own table):** all nine match —

```
8a77ecb4c29ab8b6…  corpus/fixtures/r96_joltdet.gd
06d80e50ac6fadc2…  corpus/fixtures/r96_probe_iters.gd
762e11b47552aa41…  corpus/fixtures/r96_probe_pen.gd
4228f7aee4d68cb5…  corpus/fixtures/r96_probe_warm.gd
d6ce9067499c1c5f…  corpus/fixtures/r96_probe_damp.gd
1d7bd6e7e4613916…  corpus/fixtures/r96_probe_rest.gd
ddc50d993d0ca6e5…  corpus/fixtures/r96_probe_kin.gd
db3447f6a94c5094…  corpus/fixtures/r96_probe_srvjoint.gd
e190adff97ac1d80…  corpus/fixtures/r96_probe_settings.gd
```

and **all 8 probe copies are byte-identical (`cmp`) to
`corpus/live/r96-scout/probes/*.gd`** — the provenance premise of the whole lattice.

**Seed custody:** the author's run-4 seed map has **83 entries**; every digest equals
the on-disk committed blob, re-verified after this seat's own runs at 01:07Z
(**0 bad, 0 missing**) — including `r96_joltdet.gd 8a77ecb4…`, the eight probe
copies, and `run_battery.py 935ed912…`. All four author full runs carry the same
83-entry map, so every author run ran the committed bytes.

---

## 2. Claim arithmetic — every author number re-measured

| claim (author report) | measured | verdict |
|---|---|---|
| "Before: 304 → After: 316 = +12 r96 rows" | AST census of `CASES` at `4fed8f3` = 304; at `dd054a2` = 316; the 304-name list is a strict **prefix**; field-compare of every pre-existing row = **0 modified**; added = exactly the 12 `r96_joltdet_*` rows | **verified** |
| totals "257 ordinary + 59 negative" | exit-code census: 257 × `exit 0` + 59 × `exit 2` | **verified** |
| `run_battery.py` "insertion-only — +30 lines, zero existing bytes touched" | `git diff --numstat 4fed8f3 dd054a2` = **30 + / 0 −**, appended after `r95_bullet_neg_shm_rt`; diff view shows the 12 tuples + the 6-line comment only | **verified** |
| "**160 children per battery pass**" | arm spec census: joint 12 + contact 16 + restkin 15 + tps 26 + solver 17 + mech 7 + tscale 12 + ffps 10 + dummy 18 + thread 20 + knobs 3 + nc 4 = **160**; my fresh run's scratch holds exactly **160 `r96t*` child dirs** | **verified** |
| "123 digest cells" | 12+16+15+26+17+7+6+3+6+10+4+1 = **123** | **verified** |
| pre-run 12/12 (`…T001410…`), run1 315/316, run2 313/316, run3 315/316, run4 **316/316**, all `seeds_unchanged=true` | each `verdicts.json` re-read: pre-runs 12/12 ×2 (`…T001054…`, `…T001410…`); run1 fail `navagent3d_retarget_fixed` (`before=1.754246` signature); run2 fails `navagent3d_retarget` + `phys3d_joints_free_ops` + `phys3d_joints_chain3` (20 s timeouts); run3 fail `navagent3d_retarget`; run4 all green. `…T001130…` is an **interrupted pre-run with no `verdicts.json`** | **verified** |
| "run 1 r96 rows 1.15–7.75 s (slowest `ffps`)" | run1 r96 elapsed census: min 1.15 s (`knobs`), max 7.75 s (`ffps`) | **verified** |
| "6 parent runs × 12 arms = 72 arm runs, all PASS, one distinct marker per arm" | `runs/sweep2/` = **72 files**, 6 reps × 12 arms; per arm exactly **one distinct marker line, byte-equal to its `CASES` pin**; non-`#` bodies byte-identical across reps (the `#` census lines are the only per-rep variation) | **verified** |
| warning census "13/36 (2,2,2,2,2,3) at positions 16–19" | sweep2 `#` notes: 2,2,3,2,2,2 = **13** of 6×6 Jolt receipts; recorded positions ∈ {16,17,18,19} | **verified** |
| "nocache all-zero readback in 3/6 parent runs (39/324 ticks each)" | sweep2 nc `#` notes: 39,39,0,0,39,0 → **3/6 reps at 39/324**; pose sha identical in all 6 | **verified** |
| "Jolt 5-cube tower identity instability (1/3 reps in the first sweep) → `psha`" | `sweep1/contact.r{1,2,3}`: full `warm_stack@jolt` sha `f07717ce…` ×2, `567e8d88…` ×1; the committed cell pins the pose-only `psha=fbab7c7a…` | **verified** |
| crosscheck "93/93 referenced cells byte-identical (normalized)" | author log `runs/crosscheck-run1.log` = `match=93 missing=0 differing=0`; **reproduced independently by this seat** on its own fresh-run scratch (§6.2) | **verified** |

---

## 3. The three mandated encodings (code-read against the committed fixture + pins)

**1. Jolt warning expected-error class with self-gate.** `WARN1`/`WARN2` are the
exact two lines; `_scan_lines` drops the pair **only** when `line == WARN1` and the
next line `== WARN2`, at any stream position, and drops nothing else into the
allowlist (`_scan_lines`, `r96_joltdet.gd:410-446`). The `ffps` arm runs 6 flagged
Jolt reps + a no-flag reference + 2 flagged GP reps + a GP reference and requires
`norm_eq=1`, `ref_eq=1` (normalized flagged == no-flag, sha `4492126f…`),
`raw_eq=1` for GP, and the synthetic **scanner self-gate** — the exact pair dropped
at head *and* middle (`allow=1`) while a near-miss (first line without its `at:`
line) is **not** dropped (`reject=1`) (`_run_ffps`, `:661-714`). The committed pin
carries all four predicates: `jolt_ffps{reps=6,norm_eq=1,ref_eq=1,sha=4492126f…}
gp_ffps{reps=2,raw_eq=1,sha=581274d6…} allowlist{allow=1,reject=1}`.

**2. `--time-scale` is the tps law, both backends.** `_run_tscale` runs 6 pairs,
each `--fixed-fps 60 --time-scale {0.5,2.0}` against its `--fixed-fps 60` tps-bake
reference and requires equal **normalized** sha (`eq`), both backends
(`:632-658`). The pinned shas are the *same shas the `tps` arm pins* for those
bakes — `pin_ts05 == it_pin@gp120 d24077db…`, `pin_ts20 == it_pin@gp30 b9a23707…`,
`jpin_ts05 == it_pin@jolt120 4492126f…`, `jpin_ts20 == it_pin@jolt30 4a7005fe…`,
`lin10_ts05 == lin10@gp120 e0963312…`, `lin10_ts20 == lin10@gp30 f9f0bcb9…` — so
the law is cross-pinned, not self-reported, and the boundary's not-tested
`--time-scale × --fixed-fps` interaction is measured for these cells (both sides
under `--fixed-fps 60`).

**3. Dummy vacuity with live in-cell controls; `sleep1` hang pinned `rc=137`.**
`_run_dummy` runs 5 cells with **Dummy + GP + Jolt in the same cell** and pins the
three readings side by side (`it_pin{d=-1.0,gp=0.0,jolt=0.0}`,
`pen_overlap{d=-0.3,gp=-0.010001,jolt=-0.02}`, `warm_rest{d=0.600000024,…}`,
`damp_lin10{d=10.0,gp=0.0,jolt=0.0}`, `kin_kcontact{d=0,gp=1,jolt=0}`), so a
Dummy-only degenerate value can never read as a law. The hang cell bounds the
child at **2 s** (`HANG_BOUND_S`), reads the log through a **128 KiB cap**
(`HANG_CAP_BYTES=131072`) and requires `rc=137` **and** `truncated` **and** no
`DSUM` **and** the `D0` header **and** a non-empty unexpected-error list (the
invalid-Variant SCRIPT ERROR loop), then removes the log (`:717-774`). The pin is
`sleep1{dummy_rc=137,hang=1,nodsum=1,d0=1,gp_slept=126,jolt_slept=144}`.
**Live re-verification by this seat** (§6.3): a fresh 2 s-bounded Dummy `damp.gd
sleep1` run gave `rc=137`, `D0` present, no `DSUM`, 16.56 MB / 339,952 lines of
error spam; the fixture's own hang child dir in my fresh run keeps
`project.godot` + `damp.gd` and **no `child.log`** (removed after the scan).

Thread (`10` cells × ref/thr on both backends) and nc (`4` reps, pose-only `psha`)
are likewise in-cell self-contained, matching the report's table.

**Header-comment precision (corroborating the sibling simplifier, §7 F8).** The
fixture header's line-19/20 sentence *"(a SCRIPT ERROR, an unexpected ERROR:, a new
warning) fails the arm"* is **not literally true for the plain-warning class** — a
line beginning `WARNING:` that is not the allowlisted pair has no rejection branch
in `_scan_lines` and lands in the normalized `m` stream (cell still ok, arm still
prints PASS); the **battery's exact-marker + sha pin** is what fails it. This seat
re-derived the mechanism by code-read; the sibling simplifier measured it live
(`dda3e7e`, §5.2). The two ERROR classes *do* fail the arm as the sentence says.

---

## 4. Fresh full battery on the committed bytes, under self-owned load

    python3 corpus/fixtures/run_battery.py \
      --runs corpus/live/r96-scribe/battery-committed      # 12 self-owned `yes` hogs

| measure | value |
|---|---|
| wall / load | **9 m 12 s** (00:55:56Z → 01:05:08Z); loadavg 54.2 at start → **91.7** at end (12 self-owned hogs + sibling-lane load) |
| receipt | `battery-committed/20261016T005556371137Z/verdicts.json` sha `79ae02d5c2eab568…` |
| totals | **316 cases, 315 PASS / 1 FAIL** (257 ordinary + 59 negative), `case_timeout_seconds=20` |
| FAIL | `navagent3d_retarget` — the documented one-tick pre-switch motion-mismatch flake class; this run's stderr value `before=(1.777816,…)` (the class reads 1.707105/1.730676/1.754246 across r93/r94/report runs) |
| **r96 rows** | **12/12 PASS**, exact `CASES` marker line, `stderr=[]`, `error=None` |
| r96 stdout vs author run 4 | **10/12 byte-identical** (stdout+stderr+exit); the 2 differing rows differ **only** in `#` census lines — `ffps` warn `1/6 pos=17` (run4: 2/6), `nc` zero-read `39/324` (run4: 78/324); all pinned parts identical |
| child census | exactly **160** `r96t*` child dirs; the Dummy hang dir has no `child.log` |
| seed flag | `seeds_unchanged=false` — **solely** the concurrent r97 author's new files (§7 F1); 0 of the 83 committed-era seeds added/removed/changed |
| hog hygiene | killed **by exact PID** at 01:05:08Z (12 recorded PIDs, all confirmed dead; no pattern-wide `pkill`) |

**Conclusion (full run):** the committed tree behaves as the author measured it —
the 12-row surface is green on fresh bytes under load, and the only red row is a
pre-existing flake row this round did not touch.

## 5. Fresh r96-only run (narrow behavioral check)

| measure | value |
|---|---|
| command | `run_battery.py --only r96_joltdet_joint,…,r96_joltdet_nc` |
| receipt | `battery-r96-only/20261016T010628205401Z/verdicts.json` sha `08c65d3404be77eb…` |
| totals | **12/12 PASS** |
| vs author run 4 | **10/12 byte-identical**; `ffps` (`warn=0/6`) and `nc` (`zero-read 0/324`) differ only in `#` census lines |
| seed flag | `seeds_unchanged=false` — `added=0, removed=0, changed=['r97_nodelat.gd']` (sibling r97 author edited it mid-run; no r96 seed involved) |

---

## 6. Provenance — the pins were re-derived, not restated

**6.1** The fixture copies the committed probe source into each per-cell child
project under its **original `res://` name** (`_child_prepare`, `:520-558`), which
avoids the boundary §7.1 rename hazard by construction; child dirs are
pid-namespaced (`run_prefix`), so a concurrent rep sweep cannot collide.

**6.2** This seat ran the author's crosscheck tool on **its own fresh full-run
scratch** (not the author's): `crosscheck: match=93 missing=0 differing=0`
(`crosscheck-fresh-run.log`) — the 93 referenced cells re-derive the scout's/boundary's
receipts byte-for-byte after warning normalization.

**6.3 Independent 4-cell replay (this seat, not the author's tooling):** the
committed probe copies were re-run in fresh scratch projects whose `project.godot`
bytes are copied from `corpus/live/r96-scout/proj{,jolt}/project.godot`, exactly as
the fixture child does (`--fixed-fps 60`, merged streams, `timeout -s KILL 25`), then
diffed against the scout's `r1` receipts after dropping the warning pair:

```
MATCH  it_pin_gp        rc=0 warn=0
MATCH  it_pin_jolt      rc=0 warn=0
MATCH  damp_sleep1_gp   rc=0 warn=0
MATCH  damp_sleep1_jolt rc=0 warn=1     <- warning pair observed live, normalized away
```

**4/4 MATCH** (`replay-provenance.log`, raw logs under `replay-provenance/`). This
also gives an independent sighting of the warning pair (1 of 4 fresh receipts) and
confirms the normalization is a no-op on the reference side.

---

## 7. Findings (ranked, for the canonical judge)

- **F1 (medium-low, environment / custody semantics).** Both fresh runs report
  `seeds_unchanged=false`, and the cause is **not** r96: a sibling lane (r97 author)
  wrote new untracked fixtures into `corpus/fixtures/` while the audits ran — 11
  `r97_*` files appeared during the full run, and `r97_nodelat.gd` was edited during
  the r96-only run (`added=0, removed=0, changed=['r97_nodelat.gd']` in that run's
  own diff census). **0 of the 83 committed-era seeds** were added/removed/changed,
  and all 83 digests still verify on disk. The battery's seed flag is fail-closed
  and correct; but a wave-B "green custody" run on this shared working tree cannot
  show `true` while another lane is authoring. Disposition: environmental, no r96
  defect; the flag should be read together with its added/removed/changed census.
- **F2 (low, claim precision).** The report's "its **27 MB** error-spam log" for the
  2 s-bounded Dummy hang child is not reproducible: this seat's identical run
  produced **16.56 MB / 339,952 lines** (sha `18d45e0c…`), and the author's own
  25 s-bounded receipt `runs/dummy_damp_sleep1.txt` is **54.7 MB / 1,120,261 lines**.
  The spam rate is wall-clock/load-dependent (the child is killed at 2 s), so the
  figure is a magnitude, not a constant. The **pinned** surface is unaffected
  (cap read + `truncated` + `rc=137` + log removal all verified).
- **F3 (low, receipts-doc lag).** `r96-author/RECEIPTS.md` describes `battery/` as
  "r96-only pre-run, full run 1, full run 2" and lists only `battery-run{1,2}.log`,
  while the tree holds 2 pre-runs (one interrupted, no `verdicts.json`) + **4** full
  runs + 4 logs; the report itself cites runs 3–4 correctly. The manifest's
  exclusions (battery scratch 6656, `ftest/` 91, itself) are not stated in
  `RECEIPTS.md` (r95-scribe's manifest-exclusion census class).
- **F4 (low, intended-variance observation).** The unpinned censuses move across
  runs exactly as designed: ffps warning 13/36 (sweep) → 1/6 (my full run) → 0/6
  (my r96-only); nc zero-read 39/324 / 78/324 / 0/324. Only the normalized sha is
  pinned; the census never enters a pin (verified: the 12 markers equal their
  `CASES` pins in every run).
- **F5 (expected, freshness).** `LOG.md`/`SCORECARD.md` carry no r96 section/row
  yet (last block = Round 95) — pre-adjudication, same class as r95 F5.
- **F6 (observation, cross-round attribution).** The report's flake attribution
  ("the same `before=1.754246` signature that failed r94's run 1 and the r93
  baseline") is corroborated at report level (`r94-author.md:47`, `r94-scribe.md`,
  `r93-baseline2.md:181`, `r93-scribe.md:135`); the surviving r93-baseline raw rows
  show the **same one-tick class** with other load-dependent values
  (`before=1.707105` in stderr, `1.730676` in the marker) and the r94 raw receipt
  dir is no longer present in `corpus/live/`. No contradiction — the value is
  run-dependent; the class is the pinned thing.
- **F7 (custody event, not a defect).** Sibling wave-B seats ran concurrently; the
  r97 author's files appeared mid-audit and a sibling committed `dda3e7e`
  (r96-simplifier report, `+370` lines, no fixture/runner byte) at 01:06:04Z.
  No tracked file was modified by this seat and no artifact byte changed; §1–§6
  remain valid for the `dd054a2` artifact set.
- **F8 (low, header-comment precision — corroborates the sibling simplifier's
  F-1/F-2/F-3 on `dda3e7e`).** Three fixture header-comment sentences overstate
  the code: (a) lines 19–20 "a new warning … fails the arm" — a plain
  non-allowlisted `WARNING:` line has no rejection branch and still prints PASS
  (the battery's exact-marker/sha check is the layer that fails it); (b) lines
  68–70 call the `nc` cell "reads the real contact-0 impulse" while the cell is
  pose-only and the impulse readback is census-only; (c) lines 11–18 "censused in
  `#` diagnostics" is true only for the Jolt warning — the `lk`/`pe` counters for
  the other dropped classes are returned and never read (write-only). This seat
  re-derived all three by code-read (`_scan_lines:410-446`, `_run_nc:838-873`,
  `"lk"`/`"pe"` occur only in the return literal) and its fresh runs independently
  saw the `nc` impulse census move (39/324, 0/324) while the pinned pose sha never
  moved. No behavior or pin is affected; the simplifier measured the warning case
  live. Disposition: report/comment accuracy, adjudicator's call.

---

## 8. Dispatched labrat probe (probeParent allowance: 1 of 1)

One read-only `labrat` probe was dispatched with the falsifiable hypothesis *"the
committed fixture probe copies reproduce the r96-scout receipts byte-for-byte
(warning-normalized) for `iters/pin` and `damp/sleep1` on both backends"*. It
returned **INCONCLUSIVE — its tool surface was read-only with no process execution
(only find/grep/read), so it could not launch Godot**; it verified statically that
the probe copies are line-identical, the bakes match, and all 4 reference receipts
exist and are well-formed. The allowance was **not** re-spent; this seat executed
the same 4-cell replay itself (§6.3) with **4/4 MATCH**.

## 9. Not tested / remaining risks

- The threaded gate in general (r87/r88 own it): only the 10 in-cell pairs.
- `--time-scale` × `--fixed-fps` is now measured for the 6 `tscale` cells only.
- The fresh runs cannot isolate "load vs idle" (the host was never quiet; ambient
  loadavg 54–92 plus sibling lanes).
- The Dummy hang's spam volume is load-dependent (§7 F2); only its pinned
  envelope is stable.
- The r97 author's concurrent landing means the shared `corpus/fixtures/` tree is
  a moving target for custody flags (§7 F1) until that lane lands.

**Verdict: AUDIT PASSES.** Custody is intact (2112/3270/545 manifest entries,
9/9 fixture shas, 8/8 probe copies byte-identical, 83/83 seed digests), every
author number re-measured (304→316, 257+59, +30 insertion-only, 160 children,
72-run sweep, 13/36 warning census), all three mandated encodings are in the code
and in the pins, and the committed bytes reproduce the r96 surface on fresh runs:
**12/12 r96 rows PASS in both this seat's full run and the r96-only run**, 10/12
byte-identical to author run 4 with the other 2 differing only in unpinned `#`
census lines, 93/93 provenance on this seat's own scratch, 4/4 independent replay.
Findings F1–F8 are environmental, precision, or expected-freshness items — none
touches a pinned cell (F8 is the header-comment accuracy class, independently
corroborating the sibling simplifier's filed F-1/F-2/F-3). No commit made, per
instruction.
