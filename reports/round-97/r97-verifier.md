# r97 verifier — wave-B gate on committed `ec27b78`

Seat: **VERIFIER** (non-author) for `game-dev-3d-shokunin` round 97. Assigned
tree: `ec27b782f8e1ed0337da75e3dcb1338d09241c83` ("r97 author: 8 nodelat rows
(324 total) — 79 cells/83 children, boundary-surviving claims only; 324/324 x2
green"). Author report `reports/round-97/r97-author.md`; boundary
`r97-boundary.md`; scout `r97-scout.md`.

Environment: `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`,
`/usr/bin/python3` `3.14`, 32-thread host; **1-min load average 52 → 90 across
the seat** (sibling lanes ran concurrently throughout: r97-scribe's
battery-committed, r97-critic's r97-only battery, r98/r99 authoring, an audio
lane; `pgrep -x yes` 48–60). **No `lsp` device is exposed to this seat's
toolset** (same recorded absence as r85–r96 lanes); this seat made no source
edits, so the hand-edit fallback was never in play. It wrote only
`corpus/live/r97-verifier/**` (gitignored via `corpus/.gitignore: live/`) and
this report. No commits, no tracked writes.

## Byte custody

- At seat start `git rev-parse HEAD` = `ec27b78`; `git status --porcelain`
  carried only the sibling untracked reports (`r94-reviewer`, `r95-reviewer`).
  At filing, the only tracked modification in the worktree is a **sibling r98
  lane's insertion-only edit** to `corpus/fixtures/run_battery.py` (+41 lines,
  0 deletions, no r97 line touched); all 11 `corpus/fixtures/r97_*` blobs
  re-hash **byte-identical to the `ec27b78` blobs (11/11 OK)** — the
  **committed** `run_battery.py` blob is
  `0db6f9229307efd7b7c815f2a76b6c5cdc023e4ce7f2eb8526446e6a6dc4fb4f`.
- **Fixture sha matches the author's table**: parent `r97_nodelat.gd`
  `c30aca993686733f43b4b0088f3613131cc25f2c65c7157bd6da3011907b36c5`; the ten
  `r97_probe_*.gd` copies are **byte-identical to the scout's/boundary's own
  probe sources** (`r97-scout/probes/*.gd`, `r97-boundary/probes/r97b_*.gd`,
  same sha256 — 10/10; the rename hazard is avoided by construction, not by
  claim).
- **CASES diff is insertion-only.** AST `literal_eval` on the committed blobs
  (`eb641c2` → `ec27b78`): **316 → 324**; `new[:316] == old` tuple-equal;
  removed = 0, changed = 0, duplicate names = 0; composition **265 ordinary +
  59 negative**; the 8 tail rows are `r97_nodelat_*` on `r97_nodelat.gd` with
  `expected_exit=0`.
- **79 pinned cells / 83 children per full pass** — counted statically from the
  fixture's declared spec table (24+7+6+11+6+13+8+4 = **79**) and dynamically
  (83 child dirs in every battery pass; 79 pinned + 4 deferred-pin census).
- **Mid-seat movement (documented, contained, none of it this seat's):** a
  sibling r98 lane wrote 22 new `r98_*`/`r98assets/*` files into
  `corpus/fixtures/` and then a `+41`-line insertion into `run_battery.py`.
  Both of my full batteries record `seeds_unchanged=false` because of that.
  Reconstructed at filing against each run's own before-map: **0 r97-file
  changed, 0 removed**; the only deltas are the sibling's additions.
- Every measurement below ran on the assigned `ec27b78` bytes (the two full
  batteries loaded the committed 324-row CASES at process start; the sibling's
  rows were inserted mid-run and are not in either run).

## Per-item verdict table

| # | assigned check | verdict |
|---|---|---|
| 1 | CASES insertion-only, +8 rows, 324 total (265+59) | **PASS** — strict-prefix tail insert, 0 removed/changed/dups, all 8 rows `r97_nodelat.gd` exit 0 |
| 2 | Fixture/probe custody (shas, probe copies = scout/boundary probes) | **PASS** — 11/11 fixture shas match the author table; 10/10 probe copies byte-identical to their sources |
| 3 | r97 rows on committed bytes | **PASS** — `--only` 8/8; all 8 in both full batteries; 1.17–8.43 s per row (20 s bound) |
| 4 | Full battery 324 rows on committed bytes | **PASS** — **run 1: 324/324, all rows green**; run 2: 323/324, the single failure is the pre-existing `navagent3d_retarget_fixed` one-tick load flake (see §2) |
| 5 | All 79 digest cells re-derived independently | **PASS** — 79/79 per pass × 3 passes: my own from-contract normalizer + independent cell builder rebuild every cell text identically |
| 6 | Child-level re-execution (rc + receipts) | **PASS** — 83/83 children re-run: 0 rc mismatches (79× rc=0, 4× rc=134), 0 normalized-receipt mismatches |
| 7 | Provenance vs scout/boundary receipts | **PASS** — 79/79: 69 byte-identical, 10 identical after the declared `SF setup` line extension, 0 differ, 0 missing (×3 passes) |
| 8 | Rep-stability of the 8 rows | **PASS** — my own 3-rep × 8-arm sweep: 24/24 PASS, exactly one distinct PASS line per arm (3/3 byte-identical) |
| 9 | Known risk: xr pins degenerate rc=134 (envelope phrased) | **PASS** — 160 stored scout/boundary receipts: crash set 100 % rc=134 with ONE normalized sha, clean/leak set 100 % rc=0 with one sha; all 8 pinned shas matched by every receipt; my runs 4/4 rc=134 |
| 10 | Known risk: softfloor two-valued census | **PASS** — `--pins=now` ⇒ pf=0 deterministic and equal to the pinned cell; deferred branch censused only (5× pf0 / 21× pf1 across my sessions; 9/1 in a direct 10-run census); no cell pins a deferred value |
| 11 | Known risk: ClassDB census corrected 44 → 45 | **PASS** — `classdb.gd` `CANDIDATES` = 45 entries (0 dups); 45 `CLS … exists=true`; exactly the 5 named `no_instantiate`; pinned `classes=45,noinst=5` |
| 12 | Row sensitivity (does the gate bite?) | **PASS** — probe mutation moves the receipt and reds the row; pinned-digit mutation reds the row; clean control green |
| 13 | Scanner fail-closed semantics (differential vs committed fixture) | **PASS** — the fixture's own `_scan_lines` executed on 17 synthetic streams agrees 17/17 with my re-implementation (counters + kept lines + sha) |
| 14 | Hygiene / red flags | **PASS with LOW findings** — bounded children, validated dirnames, scratch-confined writes, fail-closed cell gate (§9) |

## 1. Batteries executed (all on `ec27b78` bytes)

| run | dir | context | totals | seeds_unchanged |
|---|---|---|---|---|
| r97-only #1 | `battery/only1/20261016T062955799810Z` | load 61→66 | **8/8 PASS** | `true` (93 seeds) |
| full #1 | `battery/full1/20261016T063033254911Z` | load 69→76; r97-scribe + r97-critic + audio lanes | **324/324 PASS** | `false` — sibling's 22 new `r98_*` files; 0/93 prior seeds changed |
| full #2 | `battery/full2/20261016T064058294669Z` | load 64→61; same siblings | **323/324** (1 pre-existing flake, §2) | `false` — sibling's insertion-only `+41` into `run_battery.py`; 0 changed/removed of the 116-file baseline |
| arm sweep | `sweep/` | 3 reps × 8 arms, load ~76–85 (concurrent with full #1) | **24/24 PASS** | n/a |

r97-row wall times: Σ 30.9 s (full #1) / 31.1 s (full #2), max 8.43 s
(`softfloor`), min 1.17 s — inside the author's claimed 1.05–8.18 s band and
far inside the battery's 20 s per-case bound. 83 r97 children per pass
(counted: joint 24, soft 7, dss 6, cb 11, vehicle 6, softfloor 13+4, xr 8,
freegrain 4 = **83**, matching the author's claim exactly).

## 2. The one full-battery failure is pre-existing and load-shaped

Full run 2: `navagent3d_retarget_fixed` (negative control) — `exit 1 !=
expected 2`, `before=(1.754246, 0.0, 1.754246)`: the documented navagent
one-tick load flake, the **same signature** the r93/r94/r96 lanes recorded
(and that the r96 verifier saw in its own full run 1). It is not an r97 row,
its fixture was not touched by this round, and no r97 row reddened in any
context this seat ran (2 full batteries, 1 r97-only battery, 24 arm runs, 83
re-executed children). The other documented flake classes
(`phys3d_joints_*` 20 s knife-edge, `phys3d_events_race_class` drift) did not
fire in my runs.

## 3. Independent re-derivation of every digest cell

`corpus/live/r97-verifier/tools/norm.py` is a **from-contract**
re-implementation of the fixture's declared normalization (header lines
11–26), written independently of the fixture code. `tools/rederive.py` parses
the fixture's declared spec table (names/cases/fields only — never values),
locates the child log each parent wrote, rebuilds the whole cell text
(sha, x-fields, rsha/req/rdiff/feq, ee/lk, xr census fields, freegrain frame
fields) with its own code, and compares it to the pinned battery marker
(rc compared separately, §4).

- **79/79 cells rebuilt identically in each of the 3 battery passes** (237
  cell checks, zero mismatches).
- The two-valued census children are not part of any cell (their `pf` never
  enters a pin).
- My normalizer was itself validated against the committed fixture's own
  scanner on 17 synthetic streams (§6): counters, kept lines and sha agree
  17/17.

## 4. Child-level re-execution — rc and the two-valued census

`tools/childrerun.py` re-runs every child with the fixture's exact command
shape (`timeout -s KILL 14 godot --headless <eargs> --path <dir> --script
res://<probe>.gd -- <case>`), capturing the real exit code and a fresh
receipt:

- **83/83 children: 0 rc mismatches** — rc census `{0: 79, 134: 4}`; the four
  rc=134 are exactly `cls@gp`, `cls@jolt`, `iso_xrs@gp`, `iso_xrs@jolt`.
- **83/83 normalized receipts byte-identical** to the parent's own child logs
  (0 mismatches), i.e. the pinned values are reproducible outside the parent.
- Census children: `pf0=1 pf1=3` in that pass; a separate direct 10-run census
  of the deferred case gave **9× pf=1 (v4=0.00123,2.90701,-0.00033) and 1×
  pf=0 (v4=0.0001,2.92696,0.00145)** — both branches internally deterministic,
  and the pf=0 value equals the pinned `collide_now@gp` (`--pins=now`) value.
  Across my whole seat the census read 5× pf0 / 21× pf1; no census value ever
  entered a pinned cell.
- (Verifier-harness note, not a landing finding: my first two re-execution
  passes each carried a harness bug — a missing `--at=` for freegrain, a
  truncated `CLEAN_SET`, then over-quoting multi-arg cases — which produced
  receipt/rc "mismatches" that vanished once the command shape matched the
  fixture's own. The third pass is the clean one above. The bugs were caught
  by the fixture's own bounded-children behaviour, not by a value change.)

## 5. Provenance: the pins reproduce the scout's and boundary's own receipts

`tools/provenance.py` maps each of the 79 cells to the scout's or boundary's
own receipt for the same probe+case and compares the normalized streams:

```
== provenance: 79 checked, 69 identical, 10 identical-after-setup-strip, 0 differ, 0 missing
```

in all three passes. The 10 "setup-line extension" cells are exactly the
boundary's early `sf_*`/`pp_*` receipts whose `SF setup case=…` line predates
the final `r97b_softfloor.gd` (`… prec=-1` vs `… prec=-1 pins=deferred
pin=top`); the physics rows are byte-identical line-by-line, so the extension
is a receipt-shape normalization, not a physics claim. Corroborating
receipt-level checks:

- The boundary's §5 table says Jolt `plat_ride` is `fl=0`; the **scout's and
  boundary's own receipts** both read `fl=1` at t=120 — the author's
  correction §3.1 is corroborated, and the pinned split is the reported slide
  count (`n=1` GP / `n=0` Jolt).
- `cbedge.gd:187` does hardcode `var dt := 1.0 / 60.0`, so the CB `float`
  cells' `v.y=-19.6` is a 60-tps probe constant (author §3.6) — the pinned law
  is the `fl=0 wlo=1`-while-resting classification.
- `drop_unidx@gp` carries exactly 9 allowlisted ERROR lines (8× the index
  condition + 1× "mesh needs to have indices") → pinned `ee=9`.

## 6. Scanner fail-closed semantics, executed and differentially compared

`scanner/scanner_probe.gd` loads the **committed** `r97_nodelat.gd`, seeds its
regexes as the fixture does, and calls its own `_scan_lines` on 17 synthetic
streams. Measured:

```
head/mid/tail  w=1            (WARN pair dropped at any position)
nearmiss       w=0 kept       (WARN1 without its "at:" line is NOT dropped)
swapped        w=0 kept       (WARN2 before WARN1 is NOT dropped)
dup            w=2            (both pairs dropped)
loadaddr       kept=2         ("Load address:" -> "Load address: A")
frames         kept=3         ("[n] <hex>" -> "[n] F", n preserved)
err_allowed    ee=1 ue=0      (allowlisted ERROR stays in the hash, counted)
err_other      ue=1           (fail channel)
script_err     ue=1           (fail channel)
leak_xr        lk=1           (allowed with "xr")
leak_plain     ue=1           (fail channel)
crash          ee=1           (handle_crash allowlisted)
```

and `tools/scanner_diff.py` compares those to `norm.py` on the identical
streams: **17/17 agree** (counters + kept lines + sha). This is the
independent validation of both the fixture's normalization and my
re-derivation of the 79 cells.

## 7. The three named risks, measured

- **xr pins a degenerate rc=134 distribution, phrased as an envelope.** Across
  **160 stored receipts** from the scout and the boundary — including the
  `load16`/`load32` arms — the crash set (`cls_proj`, `cls_proj_jolt`,
  `iso_xrs_1`, `iso_xrs_jolt`) is **100 % rc=134 with a single normalized sha**
  (the pinned `1f797afd5a60b213` / `90e164358a6e264c`), and the clean/leak set
  (`iso_clean`, `xr_same`, `xr_keep`, `xr_dbl`) is **100 % rc=0 with a single
  sha** (the pinned `2f027270a931ffad` / `7e30f0a2b0579d1a` /
  `c62382279f80e8cb` / `a7e3e042022c4839`). Whole-tree rc censuses reproduce
  the boundary's claim exactly: boundary 1197×0 + 66×134 = 1263, scout
  1103×0 + 13×134 = 1116, **0 other codes**. My own runs add 4/4 rc=134 in
  every pass. The r90 bimodality did not reappear. Residual: the cell sha does
  pin the *normalized dump text* (frame count preserved), so a heap-layout
  change that altered the frame count would move it — the "envelope" phrasing
  is the correct reading, and it held under every load arm on record.
- **softfloor two-valued census.** The pinned cloth cells all use
  `--pins=now` (pf=0, deterministic, equal to the scout's branch and to the
  pf=0 deferred branch); the deferred case is run only as 4 census children
  whose `pf` is printed in a `#` diagnostic and never hashed. Both branches
  observed in my sessions; the fixture fails closed if a census child prints
  neither `pf=0` nor `pf=1`.
- **ClassDB census 44 → 45.** Static: 45 `CANDIDATES` entries, 0 dups.
  Dynamic: 45 `CLS … exists=true`, `noinst=5` for exactly `Joint3D`,
  `XRInterface`, `WebXRInterface`, `PhysicsServer3D`,
  `PhysicsDirectSpaceState3D`. The scout/boundary prose "44" is a miscount;
  the pinned cell is right.

## 8. Sensitivity: the rows are load-bearing

`mut/` (scratch copy of `corpus/fixtures`, restored byte-identical afterwards
— verified by re-hash):

- **M1 — probe mutation** (`r97_probe_dssparam.gd`, `ray_areason` ray length
  `6 → 2.5`): the receipt moves (`n=7,col=area,pos=2.75,1.0,0.0` →
  `n=0,col=-,pos=-`, sha `55cb526d… → 661e8472…`) and the battery row fails
  on its exact-marker check — the value surface is derived from the probe, not
  restated.
- **M2 — pinned-value mutation** (one sha digit in the `run_battery.py` row):
  `FAIL r97_nodelat_dss … exact stdout marker missing`, battery exit 1.
- **M3 — clean control** (same copy, no mutation): PASS with the pinned
  values, exit 0.

## 9. Hygiene, and LOW findings

Hygiene (verified in the committed fixture, not assumed): every child runs
under `timeout -s KILL 14` with the battery's 20 s per-case bound above it;
child dirnames are charset-validated (`..`/`/`/`\`/`:` and any non
`[A-Za-z0-9_-]` char rejected); child projects, probes and logs are written
under the scratch `res://` only; leftover children are killed and their exit
code read; a cell that is missing its log, carries any `ue` line or misses its
rc is not printed as PASS, so the battery's exact-marker check fails closed.
83 child dirs per pass; largest **r97** child log 4669 bytes (the 81 KB and
711-child figures elsewhere in the scratch belong to other fixtures' cases in
the full battery); the r97 children carried the Jolt job-system warning in
**1 of 249 child logs** across my three battery passes (a freegrain Jolt child
in full #1) — dropped by the declared normalization and counted in `w`; no
stray `godot`/driver process of this seat after the last run
(`pgrep -af r97-verifier` → 0).

**LOW-1 (report accuracy, not a landing defect).** The fixture header line 71
still reads "all **44** classes exist" while the pinned `cls` cell counts
`classes=45` and the author's §3.2 correction says 45. The value surface is
correct; the law comment is stale.

**LOW-2 (wording, not a landing defect).** Author §3.7 quotes the row comment
as "envelope, not a value invariant"; the actual comment says "the XRServer
crash/no-crash envelope", and the fixture header says "(rc=134 envelope,
pinned as crash-class not text)". "Not text" is imprecise: the sha does pin
the ASLR-masked dump text (frame count kept). Measured stable across 160
stored receipts plus every run of mine, so the practical risk is low.

**LOW-3 (same class as r96 LOW-1).** The fixture's `is_err` only catches
column-0 `ERROR:`, `SCRIPT ERROR`, `Parse Error`, `handle_crash`; an
indented `"  ERROR: …"` line goes to the hashed stream (`ue` stays empty).
Measured with the fixture's own scanner (`err_indent ue=0`). The battery's
exact-marker gate is the layer that fails; no r97 child emits such a line.

**LOW-4 (observation).** `_scan` has no size cap (r96 capped its hang log at
128 KiB); r97 has no Dummy-spam arm and the largest r97 child log measured is
4669 bytes, so this is latent only.

Also confirmed: the Dummy cells are vacuity controls pinned next to their
GP/Jolt twins (`getrid@dummy{prerid=false}`, `drop_t20@dummy{v4=0,0,0,
below=1}`); the boundary's still-not-armable list (`solver_priority`,
`hit_back_faces` semantics, `floor_snap_length`, `recovery_as_collision=false`,
the GP thickness-selection rule) appears in no cell.

## 10. Files changed / receipts

**No tracked file was written by this seat** beyond this report
(`reports/round-97/r97-verifier.md`); nothing committed. Receipts
(`corpus/live/r97-verifier/`, gitignored, **123 MB, 6295 files** hashed in
`MANIFEST.sha256`):

- `battery/{only1,full1,full2}/…/verdicts.json` — the three batteries
  (only1 `a9b2c5275d92164b…`, full1 `9bee3f1caa7c5f94…`, full2
  `6ec09083ef6cd302…`); `logs/only1.log`, `logs/full1.log`, `logs/full2.log`
  with the load context.
- `tools/{norm.py,rederive.py,provenance.py,childrerun.py,scanner_diff.py,xr_envelope.py}`
  — the independent re-implementations (shas in the manifest).
- `logs/rederive-{only1,full1,full2}.log` — 79/79 ×3;
  `logs/provenance-{only1,full1,full2}.log` — 79/79 ×3;
  `logs/childrerun-only1{-r2,-r3}.log|json` — the 83-child re-execution
  (r3 clean); `logs/xr-envelope.log` — the 160-receipt census;
  `logs/scanner-diff.log` — 17/17.
- `sweep/` — 24 arm runs (3 reps × 8 arms) + `rcs.txt` (24× rc=0), one
  distinct PASS line per arm.
- `scanner/` — the fixture's own scanner executed on 17 synthetic streams +
  the 17/17 differential.
- `mut/` — M1/M2/M3 and the restored-copy sha proof.
- `census/` — the 10-run deferred-pin census (9× pf=1 / 1× pf=0).
- `battery/*/scratch/**/child.log` + `verify-child.log` — the parent receipts
  and my re-executed receipts.

## Remaining risks / blockers

- **Sibling writes make `seeds_unchanged=false` in both full runs.** The r98
  lane added 22 files and then a `+41`-line insertion into `run_battery.py`
  mid-run; reconstructed deltas are additions only, 0 r97 bytes changed. The
  324-row verdicts themselves are unaffected (CASES are loaded at start), but
  any consumer re-running the battery now will see the r98 rows too.
- **Pre-existing flakes** (`navagent3d_retarget*` one-tick `before=1.754246`;
  `phys3d_joints_free_ops` 20 s knife-edge; `phys3d_events_race_class` drift)
  remain the only non-r97 ways a full battery reds; only the navagent one
  fired here.
- **xr is pinned as a degenerate envelope over normalized crash text**
  (§7): observed 100 % rc=134 with one sha across every stored load arm, but
  a heap-layout change that altered the dump's frame count would red the row.
- **Host-scoped pins**: `/usr/bin/godot 4.7.2.stable.arch_linux.ed1daf0bf`,
  32-thread host under 1-min load 52–90; the r97 rows measured 1.17–8.43 s
  under that load, well inside the fixture's 14 s chunk bound and the
  battery's 20 s case bound.
- **LOW-1 … LOW-4** above (stale law comment, envelope wording, indented-ERROR
  blind spot, uncapped log read). None affects the reproducibility of any
  pinned value.

No blockers.
