# r97 reviewer — surgical correctness review of the committed nodelat landing (`ec27b78`)

Seat: **GAME-DEV-3D r97 REVIEWER**. Task:
`/home/vgpnk/Projects/shokunin/.ufo/waves/shokunin-train-20261015-w22/tasks/g3d-r97-reviewer.md`.
Reviewed artifact: `ec27b782f8e1ed0337da75e3dcb1338d09241c83` ("r97 author: 8
nodelat rows (324 total) — 79 cells/83 children, boundary-surviving claims
only; 324/324 x2 green") — `corpus/fixtures/r97_nodelat.gd` (+847, new), ten
`corpus/fixtures/r97_probe_*.gd` (+1 704, new), `corpus/fixtures/run_battery.py`
(+38/−0), `reports/round-97/r97-author.md` (+218). Claim document:
`reports/round-97/r97-author.md`; context documents `reports/round-97/r97-scout.md`
and `reports/round-97/r97-boundary.md`; sibling gate `reports/round-97/r97-simplifier.md`
(landed mid-seat, report-only).

**No commits, no tracked writes by this seat.** Receipts live under
`corpus/live/r97-reviewer/**` (gitignored via `corpus/.gitignore: live/`; a
hardlink mirror of `/home/vgpnk/.cache/r97-reviewer`, where every measurement
ran). The only new tracked file is this report.

**Byte custody.** At seat start `HEAD = ec27b78`; `git status --porcelain` was
clean of tracked modifications except untracked sibling reports
(`reports/round-94/r94-reviewer.md`, `reports/round-95/r95-reviewer.md`). The
measured tree is `git archive ec27b78` extracted to
`/home/vgpnk/.cache/r97-reviewer/tree`; **every sha256 in the archive equals
`git show ec27b78:<path>`** for all thirteen changed paths (`r97_nodelat.gd`
`c30aca993686733f…`, the ten probes `3a2697d9…`/`61a0a702…`/`89bc3a7f…`/
`9a7e61f1…`/`3df22045…`/`3fa05680…`/`d6988ea7…`/`0a262545…`/`9c190ace…`/
`487ca4d3…`, `run_battery.py` `0db6f9229307efd7…`, `r97-author.md`
`23f8e442…`). Every measurement below ran from that archive, from a scratch
copy of it, or from a seat-owned mutant of it; the worktree was never used as a
seed source. Scratch stayed under `/home/vgpnk/.cache/r97-reviewer` (`/tmp` not
used).

**Mid-seat drift (sibling lanes, contained).** HEAD moved during the seat, from
`ec27b78` to `7c2b540` ("r97 simplifier: PASS — SP1-6 −40 parent lines proven
byte-identical; probeD control moved exactly one cell") and then to `20b8b19`
("r97 scribe: AUDIT PASSES on ec27b78 — manifests complete, 79/79 crosscheck,
114 crash children 0 escapes; F5: r92 rbpos is load-drift envelope") — **both
report-only**: `git diff --name-only ec27b78..HEAD` = `reports/round-97/
r97-simplifier.md` and `reports/round-97/r97-scribe.md` only, and the
`r97_nodelat.gd` / `r97_probe_*.gd` / `run_battery.py` / `r97-author.md` blobs
at the final HEAD are sha-identical to `ec27b78`'s, so the reviewed bytes are
still the committed bytes. The worktree additionally carries a **concurrent
lane's uncommitted** r98 insertion in `corpus/fixtures/run_battery.py` (+41
lines, r98 GLTF rows) and untracked r98 seeds (`r98_gltflat.gd`, five
`r98_probe_*.gd`, `r98assets/`) — not this seat's, and not present in the
archive the measurements ran from.

**Runtime.** `which -a godot` → `/usr/bin/godot` only,
`4.7.2.stable.arch_linux.ed1daf0bf`; `/usr/bin/python3` → 3.14.7; no `GODOT_*`
env; 32-core host, load **54.9–101.2** across this seat's runs (per-run load
recorded in the receipts), no quiet baseline.

**LSP note (recorded gap).** MCP inventory on this substrate = the `rea` server
only; no `lsp` device answers these files. This seat made no edits, so no
symbol-level work was required; the substitutes used were `--check-only`,
`py_compile`, an independent GDScript-literal parser for the `ARMS`/cell
tables, an independent re-implementation of the fixture's normalizer, and
battery-level mutants.

**probeParent seat.** Exactly one `ufo-labrat` was dispatched (frozen
probeParent, bounded read-only probe: "is the ClassDB census correction
(44→45) internally consistent and derivable from the committed bytes?"). It
returned a **usable** result this round — 45 `CANDIDATES` entries (independent
manual count), the counting logic verified, and one finding (the fixture
header still says 44; filed below as F1, independently re-verified by this
seat). Advisory only, no edits. No other descendants were spawned.

**Method.** (1) Committed-diff shape (numstat + char-level prefix/suffix +
line-level opcodes). (2) Parse checks on the canonical runtime. (3) Census of
`CASES` (AST) and of the fixture's arms/cells (literal parser + marker tokens).
(4) **Probe provenance**: ten `r97_probe_*.gd` sha256 vs the scout/boundary
sources. (5) **Author-receipt custody**: the 11 r97 seed digests in all four
author battery receipts recomputed against the committed blobs. (6) **Author
sweep audit** (48 runs / 498 children, marker equality, census variation).
(7) **Fresh arm sweep**: 8 arms × 3 reps = 24 runs from clean scratch copies of
the archive. (8) **Independent normalizer**: a from-scratch re-implementation
of the fixture's declared drop rules, recomputing every pinned cell (sha,
fields, `ee`, `lk`, `rsha`, `req`/`rdiff`/`feq`, and the xr/freegrain derived
extras) from raw child logs. (9) **All-79-cell crosscheck** of this seat's
children against the scout/boundary receipts. (10) **Six battery-level
mutation probes** in seat-owned mutant trees. (11) **Two full 324-case
batteries** from the clean archive plus a focused 8-row `--only` pass.
(12) **Known-risk surfaces**: the xr `rc=134` envelope, the softfloor
two-valued census, the ClassDB 44→45 correction. (13) **Claim audit**: every
hex/decimal/int token in the author report machine-matched. (14) **Cross-seat
convergence** with the sibling simplifier and the boundary's prose corrections.

---

## Verified independently

1. **Diff shape — insertion-only, zero existing bytes touched.**
   `git diff --numstat ec27b78^ ec27b78` = 847/0, 256/0, 84/0, 30/0, 323/0,
   377/0, 89/0, 152/0, 217/0, 142/0, 34/0, 38/0, 218/0 — twelve `A` and one
   `M`, no deletions. A char-level comparison of the two `run_battery.py`
   blobs gives **common prefix 257 985 chars, common suffix 26 317, old middle
   0, new middle 7 340**; line-level opcodes = exactly one
   `insert old[768:768] new[768:806]` (the 14-line comment + 8 tuples) after
   `r96_joltdet_nc`. The r97 block is contiguous at `CASES` indices **316–323**,
   so no other round's row can be affected.

2. **Parse.** `godot --headless --check-only --script res://<f>` → rc 0 with no
   `Parse Error` for all eleven r97 fixtures; `python3 -m py_compile
   run_battery.py` → rc 0.

3. **Census — exact, and bijective with the markers.** `CASES` = **324 = 265
   ordinary + 59 negative**; r97 = **8 rows** (`joint, soft, dss, cb, vehicle,
   softfloor, xr, freegrain`), indices 316–323. The arm tables give **24 + 7 +
   6 + 11 + 6 = 54** generic cells, **13** softfloor + **8** xr + **4**
   freegrain = **79 pinned cells**, plus the 4 deferred-pin census children =
   **83 children per pass**. Each row marker's cell tokens are bijective with
   its arm list (24/7/6/11/6/13/8/4), exactly as claimed.

4. **Probe provenance — the ten copies are the scout's/boundary's bytes, run
   under their original names.** Every `corpus/fixtures/r97_probe_<n>.gd`
   sha256 equals `corpus/live/r97-scout/probes/<n>.gd` (eight) or
   `corpus/live/r97-boundary/probes/r97b_<n>.gd` (two: `softfloor`, `free`);
   the boundary's own `r97b_*` copies hash the same again, so the boundary §1
   rename hazard is avoided by construction. The fixture writes each copy into
   the per-cell project under its original `res://<probe>.gd` name.

5. **The author's four battery receipts are receipts for the committed bytes.**
   Recomputing the 11 r97 seed digests in each `verdicts.json` against the
   archive blobs gives **0 mismatches** in all four runs:
   `battery-pre` 8/8, `battery1` **324/324**, `battery2` **323/324**
   (`phys3d_events_race_class` only), `battery3` **324/324** — every one
   `seeds_unchanged=true`, and all 8 r97 rows PASS in every run (row wall
   times 1.052–8.183 s against the 20 s case bound, matching the report's
   "1.05–8.18 s"). The single battery2 failure is byte-identical in signature
   to the documented pre-existing r92-verifier2 run-B observation
   (`race_class jolt crash envelope drift rc=134 v={  } tear=0 abort=2`,
   adjudicated "same-class pre-existing flake, not r92 scope") on an r88-era
   row this change does not touch.

6. **The author's sweep audit holds.** `corpus/live/r97-author/sweep1/` = 48
   parent runs (6 reps × 8 arms) / **498 children** (6 × 83; per-pid child
   counts are exactly the per-arm cell counts, namespaced by pid). **48/48
   PASS**, **one distinct `PASS` line per arm, 6/6 byte-identical, equal to
   the committed marker** in every arm. The only per-rep variation is the
   declared softfloor census `#` line — my extraction of the six reps reads
   `2/2, 1/3, 2/2, 2/2, 0/4, 3/1` = exactly the report's
   "0/4, 1/3, 2/2 ×3, 3/1" multiset.

7. **Fresh arm sweep reproduces the committed markers byte-for-byte under
   load.** 8 arms × 3 reps = **24/24 runs rc=0, stdout marker == committed
   marker, one distinct marker per arm, stderr empty**, at load 58.7–72.6
   (32 cores). Wall times 1.23–8.56 s (slowest: `softfloor` 8.51–8.56 s;
   `joint` 5.4–5.7 s), all far inside the 20 s bound. Receipts: `receipts/sweep/`.

8. **An independent normalizer reproduces every pinned cell from raw child
   logs.** A from-scratch re-implementation of the documented rules
   (banner/empty, the exact 2-line warning at any position, `Load address:` →
   `A`, `[n] <hex>` → `[n] F` with frame count preserved, `<Class#n>` → `#N`,
   per-cell allowlist and leak routing) recomputes **79/79 cells in each of 3
   reps (237/237 cell re-derivations), 0 mismatches** — including `ee`/`lk`,
   the row-prefix `rsha`, the `req`/`rdiff`/`feq` relations, the xr derived
   extras (`classes=45,noinst=5,fatal=…`, `done=…`, `identical=false`,
   `same=false`) and the freegrain `same_frame=1,gone_next=1`. Receipts:
   `tools/verify_cells.py`, per-rep runs.

9. **All 79 pinned cells reproduce the scout's/boundary's own receipts from
   this seat's children.** Using my own children and my own normalizer against
   the author's `crosscheck.py` map: **69/79 byte-identical + 10/79 identical
   under the declared setup-line extension (the boundary's early `sf_*`/`pp_*`
   receipts predate the final `r97b_softfloor.gd`), 0 differ, 0 missing** —
   independently confirming the author's "79 checked, 79 identical" claim.
   Receipt: `receipts/crosscheck-all-r1.txt`.

10. **The pins are live — six battery-level mutants, six detections.**
    In seat-owned mutant trees of the archive (never the worktree), each
    mutation reddened exactly its row (battery exact-marker assertion), and
    the moved values show the mechanism:
    - `M1` `drop_t02@gp` thickness `0.2 → 0.25`: `748ce1acea5c7817`
      `v4=0.0,0.1018,0.0,below=0` (rest) → `7156d69fc791c688`
      `v4=0.07933,-7.81311,0.10547,below=1` (tunnel) — the thickness-selective
      law is measured, not restated.
    - `M2` remove the `handle_crash` allowlist head: the four crash cells
      redden with `ue=handle_crash: Program crashed with signal 11`; the
      census counts stay `classes=45,noinst=5` but `fatal=0` — the crash-class
      allowlist is load-bearing.
    - `M3` drop `--pins=now` from `collide_now@gp`: the row reddens; that run's
      census read `pf0=0 pf1=4` and the un-pinned cell took the deferred
      branch value (`1014cada2abcbce5`) while the neighbouring
      `pinmid_now@gp` (still `--pins=now`) stayed sha-identical — the
      two-valued hazard, demonstrated in vivo.
    - `M4` hinge motor target `5.0 → 2.5`: `hmot@gp` `avb` `0.0,0.0,-2.5` →
      `0.0,0.0,-1.25` (`hmot@jolt` `-2.5019 → -1.2505`) — the pin measures the
      engine.
    - `M5` `ray_areason` `collide_with_areas true → false`: `n=7,col=area,pos=2.75`
      → `n=0,col=-,pos=-` — the flag matrix is measured.
    - `M6` remove `J.queue_free()`: `gone_next` `1 → 0` — the step-granular
      deletion pin is measured.
    Receipts: `receipts/mutants/` (logs + verdicts).

11. **Full batteries from the clean archive.** Run 1 (load 54.9 → 101.2):
    **322/324**, `seeds_unchanged=true` — the two failures are the documented
    pre-existing load flakes, not r97: `navagent3d_retarget_fixed` with the
    exact documented one-tick signature (`before=1.754246`, r92-verifier2
    F1 / r93-baseline F1/F2) and `phys3d_joints_free_ops` at the documented
    20 s knife-edge bound. Run 2 (load 73.1 → 62.5): **324/324 PASS, fully
    green**, `seeds_unchanged=true`. Focused `--only` pass of the 8 r97 rows:
    **8/8 PASS** in 1.2–8.4 s, load 73–80. **All 8 r97 rows PASS in all three
    runs** (1.1–8.6 s). Receipts: `receipts/batt-full/run{1,2}`, `receipts/batt-only/run1`.

12. **Known-risk surfaces, re-measured.**
    - **xr `rc=134` distribution.** 4 cells pin `rc=134` (`cls@gp`, `cls@jolt`,
      `iso_xrs@gp`, `iso_xrs@jolt`) and 4 pin `rc=0` (`iso_clean@gp`,
      `xr_same`, `xr_keep`, `xr_dbl`). This seat observed **24/24 crash
      children at `rc=134`, 0 escapes** (12 in the sweep + 4 in each of the two
      full batteries + 4 in the `--only` pass); the sibling simplifier saw 32/32,
      the sibling scribe 114/114, and the boundary 66/66. The "envelope" phrasing is present in the fixture header
      and the row comment; the pinned class is the observed degenerate
      distribution and the row is **fail-closed** (any escape reddens; `M2`
      shows even the crash-class *text* is enforced). Filed as F3.
    - **softfloor two-valued census.** Only the census `#` line varies
      (`0/4, 1/3, 0/4` in my three sweep reps; the author saw the full
      two-valued spread); across my 24 sweep runs + 2 batteries + 1 `--only`
      pass + 6 mutant-tree runs, **no pinned cell ever moved except the ones a
      mutant deliberately moved**. Every pinned
      cloth cell uses `--pins=now` and **the `SF pins applied at pf=0 tick=0`
      line is inside the hashed stream**, so the phase is asserted by the sha
      as well as by the value. `M3` shows the hazard is real if un-pinned.
    - **ClassDB 44→45.** `CANDIDATES` has exactly **45** entries (this seat's
      script + the labrat's independent manual count agree; 0 duplicates);
      `CLEAN_SET` has **39** = 45 − 5 non-instantiable − `XRServer`, and the
      five non-instantiable names are `Joint3D`, `XRInterface`, `WebXRInterface`,
      `PhysicsServer3D`, `PhysicsDirectSpaceState3D`. The pinned
      `classes=45,noinst=5` is right; the fixture's own header still says 44
      (F1). The author's correction #2 is accurate.
    - **The boundary prose corrections are real.** The `plat_ride@jolt` replay
      receipt (`r97b_replay_cb_proj_jolt_plat_ride.r1.stdout.txt`) and the
      scout's receipt both read `fl=1` on all 8 reported ticks, so the
      boundary's "Jolt fl=0" prose is wrong and the author's correction #1
      (pin the reported slide count `n=1` vs `n=0`) is right. The 10
      setup-line-extension cells are exactly the boundary's early receipts.

13. **Claim audit — the report's values are accurate.** Every hex token in
    `r97-author.md` appears in a committed marker or a committed fixture sha
    (the only unmatched token is the date `20261015`). Of the decimal/int
    tokens not present in markers, all are explained: wall-clock times
    (`1.05`, `8.18`, `8.2`), boundary-cited values (`0.2985`, `16.18` for
    `-16.17986`), code references (`12345`, `148`, `187`), runner census
    (`257`, `59`, `316`, `323`), and probe parameters (`400`). The sweep,
    battery, census and crosscheck numbers quoted in the report all match the
    receipts (§5–§6, §9).

14. **Cross-seat convergence.** The sibling simplifier (`7c2b540`, read-only,
    independent) reports the same three observations this seat filed
    independently — its F-1 = my F1 (stale "44"), its F-2 = my F2 (the `w`
    census has no consumer), its F-3 = my F3 (xr wording vs strict pin) — and
    its probeD1 mutant (`clampbig` `impulse_clamp 0.1 → 0.2`, one cell moved,
    one row red) is a seventh live-pin demonstration on the same landing. Its
    SP-1…SP-6 folds are report-only and **not** in the committed tree, so the
    reviewed bytes are unchanged. The sibling scribe's audit (`20b8b19`,
    "AUDIT PASSES on ec27b78 — manifests complete, 79/79 crosscheck, 114 crash
    children 0 escapes") independently lands on the same crosscheck and crash
    census this seat measured (its F5 concerns an r92 row, outside this scope).

---

## Findings (severity order)

**F1 (LOW — comment accuracy; convergent with sibling simplifier F-1).** The
committed fixture header still says "all **44** classes exist"
(`r97_nodelat.gd:71`) while the code and the pinned `cls` cell say **45**
(`classes=45,noinst=5`). The author's correction #2 landed in the report but
not in the fixture comment. Comments are not hashed and no cell reads them, so
nothing behavioral is affected; the hazard is a future reader trusting the
header over the pin. Fold: one-line comment fix for the author/adjudicator.
Independently found by the dispatched labrat and re-verified here.

**F2 (LOW — report/comment accuracy; convergent with sibling simplifier F-2).**
Both the fixture header (`r97_nodelat.gd:18`) and the runner comment
(`run_battery.py:785`) say the Jolt warning is "counted in `w`", but **`w` has
no consumer**: `_scan_lines` declares, increments and returns it, and
`_cell_text` never reads it, so no cell or diagnostic ever surfaces the count.
The *drop* is load-bearing (my normalizer reproduces every pinned sha only
with the 2-line warning removed); the *count* is not. No pinned byte affected.
Fold: reword both comments (or emit `w` in a `#` diagnostic), author/adjudicator.

**F3 (NOTE — wording risk vs pin strictness; convergent with sibling
simplifier F-3).** The xr row pins `rc=134` exactly on four cells while the
fixture header and the row comment call it an "envelope". Measured
degenerate: boundary 66/66, simplifier 32/32, scribe 114/114, this seat 24/24
crash children at `rc=134`. The row is fail-closed (an escape reddens it; `M2` shows the
crash-class allowlist is enforced), so this is a disclosure rather than a
tolerance. Residual: a heap-layout change that makes the teardown crash
bimodal would produce a **false red, never a false green**. Recorded so the
adjudicator can decide whether to widen the envelope; no change recommended by
this seat.

**F4 (NOTE — context-document prose, already superseded).** The boundary's §8
says "`iso_clean` (the other 40 instantiable classes)"; the actual set is
**39** (45 − 5 non-instantiable − `XRServer`), which is what `CLEAN_SET` has
and what the author report says. The committed landing is right; only the
context prose is off by one.

**F5 (NOTE — timeout layering; same family as r96 F6).** Each child carries a
`timeout -s KILL 14` inside the battery's 20 s per-case bound. The softfloor
row is 8.4–8.6 s nominal in my runs, so one stalled child still fits; **two**
stalled children in one row would turn it into a battery-level TIMEOUT. Worth a
flake-list note rather than a change.

**F6 (NOTE — dead config in the parent; convergent with sibling simplifier
SP-2/§2).** `ERR_ALLOW["jolt_soft"]` (4 heads) is unreachable (no cell passes
the class), and the spec knobs `cap`/`bound`/`f` are never set by any of the
85 spec literals, so `_scan`'s truncation branch, the `f`-loop/`_sum_line`/
`SUM_PREFIX` chain and the `bound` override are dead. The sibling simplifier
has quantified and proven the folds (−34 lines, report-only); nothing here is
a correctness defect, and the conservative direction of the dead allowlist
(unused allowlist ⇒ unexpected errors still fail the cell) is the safe one.

---

## Residual risk / verification gaps

- **No LSP device** (`rea` only): symbol-level checks unavailable; none needed
  (this seat made no edits; all eleven fixtures parse and execute).
- **Cross-build.** Every pin is receipt-derived for
  `4.7.2.stable.arch_linux.ed1daf0bf` on this host; the report is honest that
  hashes are build-scoped (the corpus convention from r89–r97). No tolerance
  story, inherited.
- **The xr crash class** is a teardown-ordering destructor crash (the r90
  bimodality lesson's home ground). It is pinned strictly (F3); the failure
  mode is fail-closed.
- **The two-valued softfloor branch** is controlled by `--pins=now` in every
  pinned cell and the `pf=0` line is hashed, but the fixture does not assert
  the phase in a dedicated field; a regression that kept the same trajectory
  would still be caught by the sha, and `M3` demonstrates the un-pinned
  hazard.
- **Unpinned run-variable surface** (by design, documented): the deferred-pin
  census `#` line only — never a pinned cell, in any receipt of any seat.
- **Not re-measured here:** the ten probes' non-pinned cases (the boundary's
  not-replayed list: `methods.gd`, the `slider`/`cone`/`g6`/`prio_*` set, the
  DSS `pt_*`/`is_*`/`cs_*`/`cm_*`/`ri_mask`/`excl_*`/`ray_mask*` set, the CB
  `snap_*`/`ceil_*`/`blockwall*`/`realvel`/`recovery` set, `sbx_*_impulse`,
  vehicle `brake`/`steer`/`skid`/`nowheel`/`noroll`), and the two open `[?]`s
  (the GP thickness-selection rule, Jolt's soft-body penetration mechanism).
- **Concurrency disclosure.** Three to five batteries and other lanes ran on
  the same 32-core host throughout (load 54.9–101.2); per-run load is recorded
  in every receipt. My battery run 1's two failures are the documented
  pre-existing flakes observed in that window; run 2 was fully green.

## Recommendation (not a judgment — the canonical runtime judges)

**ADMIT-recommend.** The committed landing is sound as scoped. The diff is
insertion-only with zero existing bytes touched and the r97 rows are the last
eight of 324; all eleven fixtures parse and the runner compiles; the census is
exact (324 = 265+59, 8 rows, 79 cells, 83 children/pass) and the ten probe
copies are byte-identical to the scout/boundary sources; the author's four
battery receipts are for the committed bytes (11/11 r97 seed digests each) with
all 8 r97 rows green in every one; the committed markers reproduce byte-for-byte
in **24/24** fresh arm runs (3 reps × 8 arms) and in a **fully green 324/324**
battery from the clean archive (plus 322/324 in a heavier run whose only
failures are the two documented pre-existing flakes, and 8/8 in the focused
`--only` pass); an **independent normalizer** recomputes **237/237** pinned
cells from raw child logs; an **independent all-79 crosscheck** against the
scout's/boundary's own receipts is **79/79** (69 exact + 10 declared
setup-extension); and the pins are **live** — six battery-level mutations, six
mechanistic detections, with a seventh from the sibling simplifier's probeD1.
The known-risk surfaces are as declared: the xr pin is a disclosed degenerate
envelope and fail-closed (F3), the softfloor two-valued branch is censused and
never pinned (with the `pf=0` line hashed into the pinned cells), and the
ClassDB census is 45 with the author's correction accurate (F1 is the stale
header comment). The findings are two LOW comment/claim-precision items
(F1/F2), one wording-vs-pin NOTE (F3), and three notes (F4–F6). **No finding
touches a physics pin or the committed behavior.** The F1/F2 folds belong to
the author/adjudicator, not to this seat.

**Blockers:** none. The dispatched `ufo-labrat` probe was usable this round
(read-only; it produced the independent ClassDB count and the F1 observation) —
the four-seat "no exec tool" blocker from the r96 train did not recur.

Stopping here.

---

## Receipts index

`corpus/live/r97-reviewer/` (gitignored; hardlink mirror of
`/home/vgpnk/.cache/r97-reviewer`, 452 MB): `tree/` (verified `git archive
ec27b78`), `tools/` (`sweep.py`, `verify_cells.py`, `crosscheck_sample.py`,
`mutants.py`), `receipts/` — `RECEIPTS.md` (index), `sweep/` (24 arm runs ×
3 reps with 249 child dirs + `child.log` each), `crosscheck-all-r1.txt`
(79/79), `batt-full/run{1,2}/` (two full 324-case batteries, load-stamped),
`batt-only/run1/` (focused 8-row pass), `mutants/` (M1–M6 trees, logs,
verdicts), `parse/` (`--check-only` results).
