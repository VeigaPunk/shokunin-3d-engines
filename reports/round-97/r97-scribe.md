# r97 scribe — custody + consistency audit of the committed r97 nodelat landing (`ec27b78`)

Seat: GAME-DEV-3D r97 SCRIBE. Repo `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`.
Audit window: HEAD **`ec27b782f8e1ed0337da75e3dcb1338d09241c83`**
(`2026-10-16 03:27:36 -0300` = 06:27:36Z, *"r97 author: 8 nodelat rows (324
total) — 79 cells/83 children, boundary-surviving claims only; 324/324 x2
green"*). `git status --porcelain=v1` at audit start = **2 lines**
(`?? reports/round-94/r94-reviewer.md`,
`?? reports/round-95/r95-reviewer.md` — r94/r95 wave leftovers; no untracked
`corpus/fixtures/` entry existed then). Read-only
audit plus **one fresh full battery run of the committed bytes under
self-owned load** (§4), **one r97-only run** (§5), **two crosscheck
reproductions on this seat's own scratch** (§6.1–6.2), **one independent
4-cell replay with this seat's own normalizer** (§6.3), and **one dispatched
read-only `labrat` probe** (§8). No fixture, runner, contract, axis, or route
touched; **no tracked write, no commit**. Receipts:
`corpus/live/r97-scribe/` (gitignored, `corpus/.gitignore:1: live/`). No `lsp`
device is exposed to this seat and this seat made no source edit, so the
hand-edit fallback was never in play.

**HEAD moved mid-audit (disclosed).** At 06:39:06Z — after this seat's full
battery ended (06:38:05Z) and after the r97-only run — a sibling wave-B seat
committed `7c2b540` (*"r97 simplifier: PASS — SP1-6 −40 parent lines proven
byte-identical; probeD control moved exactly one cell"*). `git show 7c2b540
--stat` = **1 file, +412**, `reports/round-97/r97-simplifier.md` only;
`git diff --numstat ec27b78 7c2b540 -- corpus/fixtures/` is **empty**, and
`r97_nodelat.gd` still hashes `c30aca99…`. The audited artifact set is
therefore still exactly the `ec27b78` tree.

Commit contents (`git show ec27b78 --stat`): **13 files, 2807 insertions, 0
deletions** — `r97_nodelat.gd` +847, ten `r97_probe_*.gd` +1704,
`run_battery.py` +38, `reports/round-97/r97-author.md` +218.

---

## 1. Custody — manifests, tracked bytes, seed maps

| manifest | entries | OK | FAILED | census |
|---|---|---|---|---|
| `corpus/live/r97-scout/manifest.sha256` | 4507 | **4507** | 0 | no self-entry |
| `corpus/live/r97-boundary/manifest.sha256` | 6389 | **6389** | 0 | no self-entry; covers `runs/` 6293, `proj*` 69, `probes/` 13, and 14 driver/log/receipt files |

Both replays `rc=0` (`custody-scout-sha-check.log`,
`custody-boundary-sha-check.log`). **The author tree has no manifest** (the r96
author shipped one; r97 does not) — the author's custody rests on the
`RECEIPTS.md` sha table (§1.3) and the four battery seed maps (§1.4).

**Tracked-bytes custody (fixture sha256 vs the report's own table):** the
parent matches the report exactly, and all ten probe copies are byte-identical
(`cmp`) to their scout/boundary sources:

```
c30aca993686733f43b4b0088f3613131cc25f2c65c7157bd6da3011907b36c5  r97_nodelat.gd   (report: same)
3a2697d97cbd52d4…  r97_probe_cbedge.gd      == scout/probes/cbedge.gd
61a0a7028a5420e1…  r97_probe_classdb.gd     == scout/probes/classdb.gd
89bc3a7f586d82a7…  r97_probe_crashiso.gd    == scout/probes/crashiso.gd
9a7e61f1dfa62dca…  r97_probe_dssparam.gd    == scout/probes/dssparam.gd
3df22045c2e67d28…  r97_probe_njoint.gd      == scout/probes/njoint.gd
3fa05680ebbff930…  r97_probe_r97b_free.gd   == boundary/probes/r97b_free.gd
d6988ea7ce55865e…  r97_probe_r97b_softfloor.gd == boundary/probes/r97b_softfloor.gd
0a2625455d6b1cb7…  r97_probe_soft.gd       == scout/probes/soft.gd
9c190acea4e13acd…  r97_probe_vehicle.gd    == scout/probes/vehicle.gd
487ca4d375d8d117…  r97_probe_xrkeep.gd     == scout/probes/xrkeep.gd
```

**1.3 `RECEIPTS.md` sha table — one malformed digest (finding F2).** The table
has 11 rows; 10 digests are 64-hex and verify against the on-disk bytes. The
`r97_probe_r97b_softfloor.gd` row carries a **62-hex** digest
`d6988ea7ce55865e4f40a7fb7cbf47dc81393b74d98fdb10481430a3d5c82d`; the file's
true sha256 is `d6988ea7ce55865e4f40a7fb7cbf47dc81393b74d98fdb10481430a3d5cac82d`
(the row is missing `ac`). A `sha256sum -c`-style replay of the table would
fail on that row; byte-identity (`cmp`) and the battery seed map are
unaffected.

**1.4 Seed custody.** Each of the author's four battery runs carries a
**94-entry** `seed_digests` map; this seat re-hashed all 94 files on disk per
run — **0 bad, 0 missing** — including `run_battery.py` itself
(`0db6f9229307efd7…` at audit start). The r96-era map had 83 entries; 94 = 83
+ the 11 new `r97_*` files. `seeds_unchanged=true` in all four author runs.

---

## 2. Claim arithmetic — every author number re-measured

| claim (author report) | measured | verdict |
|---|---|---|
| "Before: 316 cases (257 ordinary + 59 negative) · After: 324 (265 ordinary + 59 negative) = +8 r97 rows" | AST census of `CASES`: `4fed8f3` = 304 (245+59), `dd054a2` = 316 (257+59), `ec27b78` = **324 (265+59)**; the 316-name list is a strict prefix of the 324 list | **verified** |
| "`run_battery.py` — +8 rows, insertion-only (`git diff --numstat` = 38 insertions, 0 deletions, after `r96_joltdet_nc`)" | `git diff --numstat dda3e7e ec27b78 -- corpus/fixtures/run_battery.py` = **38 + / 0 −**; the hunk is the r97 comment block + 8 tuples appended after the `r96_joltdet_nc` tuple (the r96-era delta 4fed8f3→dd054a2 is 30 + / 0 −, total 68 + / 0 −) | **verified** |
| "the parent fixture … **79 pinned cells**, **83 bounded children per battery pass** (79 + 4 deferred-pin census children)" | `ARMS` census: joint 24 + soft 7 + dss 6 + cb 11 + vehicle 6 = 54, plus `_run_softfloor` 13, `_run_xr` 8, `_run_freegrain` 4 = **79**; the softfloor arm appends exactly 4 `sf_def_r*` census children → **83**. Confirmed live: 83 `r97t*` child dirs in all four author battery scratches and in **both** of this seat's scratches; this seat's run stdout carries exactly 79 digest cells | **verified** |
| "Authoring sweep … 48 parent runs / 498 children … 48/48 PASS, one distinct PASS line per arm (6/6 byte-identical)" | `sweep1/` holds 48 `.stdout.txt` + 48 `.stderr.txt`; per arm 6 runs, 6/6 PASS, **exactly 1 distinct PASS line**; children 498 = 6 × 83 | **verified** |
| "the only per-rep variation is the softfloor deferred-pin census `#` line (`pf0/pf1` = 0/4, 1/3, 2/2×3, 3/1)" | census lines over the 6 reps: **0/4 ×1, 1/3 ×1, 2/2 ×3, 3/1 ×1** | **verified** |
| "Crosscheck: `79 checked, 79 identical (10 via the declared setup-line extension), 0 differ, 0 missing`" | reproduced with the author's tool on the author's scratch **and on this seat's own fresh full-run scratch** (§6.1) — identical output both times | **verified** |
| "r97-only pre-run: 8/8 PASS"; "Full run 1: 324/324"; "run 2: 323/324 (pre-existing `phys3d_events_race_class` flake)"; "run 3: 324/324"; all `seeds_unchanged=true` | each `verdicts.json` re-read: pre 8/8; run1 324/324; run2 **323/324** with the single failure `phys3d_events_race_class` — stderr `ERROR: phys3d_events: race_class jolt crash envelope drift rc=134 v={  } tear=0 abort=2`, byte-equal to the r92-verifier2 run-B signature (`reports/round-92/r92-verifier2.md:160`, entered by `r92-adjudicator.md:45`); run3 324/324; seeds flag `true` in all four | **verified** |
| "battery-row wall times 1.05–8.18 s (20 s per-case bound) in run 1" | run-1 r97 elapsed: min **1.052 s** (`freegrain`), max **8.183 s** (`softfloor`) | **verified** |
| "Child budget: 83 children per pass, 8-way chunks, each `timeout -s KILL 14`" | `CHUNK := 8`, `BOUND_S := 14`, `_chunks`/`_spawn_batch` as described; `CASE_TIMEOUT_SECONDS = 20` in the runner | **verified** |
| "one distinct `PASS` line per arm … including the `sha` digests, which are the row markers the battery pins" | the 8 `CASES` r97 markers are the exact `PASS r97_nodelat <arm> …` lines; this seat re-compared the author's four runs field-by-field: **7/8 rows byte-identical across pre/run1/run2/run3, softfloor differs only in the `#` census line** (3/1, 4/0, 3/1, 2/2) | **verified** |
| "the ten probe copies … copied into each child project under their ORIGINAL `res://` names" | `_child_prepare` copies `res://r97_probe_<name>.gd` → `<child>/<name>.gd` and runs `--script res://<name>.gd` (`:554-566`) | **verified** |

---

## 3. The three corrections vs the named reports — all three verified

**3.1 `plat_ride@jolt` is `fl=1`, not `fl=0` (author correction #1).**
Re-counted directly on both corpora's own receipts: the scout's
`cb_proj_jolt_plat_ride.r1.stdout.txt` has **8 × `fl=1`, 0 × `fl=0`** across
t=2…120 (t=120 row: `pos=0.0,4.5967,0.0 rv=0.0,2.0,0.0 fl=1 wlo=0 ce=0 n=0
pvel=0.0,2.0,0.0`), and the boundary's
`r97b_replay_cb_proj_jolt_plat_ride.r1.stdout.txt` is the same 8/8. The
**prose** in `r97-boundary.md:235` ("Jolt fl=0 n=0") and `r97-scout.md:216`
("carried but fl=0, n=0") contradicts its own receipts. The fixture pins the
receipts (`plat_ride@jolt{rc=0,sha=7a9b0b685c818491,fl=1,n=0,pvel=0.0,2.0,0.0,rv=0.0,2.0,0.0}`)
— the surviving GP/Jolt split is the **reported slide count** (`n=1` vs
`n=0`), which is what the author's report says.

**3.2 The ClassDB census is 45, not 44 (author correction #2).**
`r97_probe_classdb.gd` `CANDIDATES` = **45** entries, no duplicates; the
scout's own `cls_proj.r1.stdout.txt` prints **45** `CLS` lines with
`inst=no_instantiate` on exactly 5 (`Joint3D`, `XRInterface`,
`WebXRInterface`, `PhysicsServer3D`, `PhysicsDirectSpaceState3D`); the fixture
pins `classes=45,noinst=5` on both backends; `CLEAN_SET` is exactly the
remaining **39** classes (45 − 5 non-instantiable − `XRServer`), matching the
author's "other 39 instantiable classes". The scout (§0: "44 candidates", "All
44 classes exist") and the boundary (§8: "all 44 classes") prose both carry
the stale number. **The fixture's own header line 71 still says 44** — see F4.

**3.3 The 10 "setup-line extension" cells are a probe-revision artifact
(author correction #3).** The committed `r97_probe_r97b_softfloor.gd:59`
always prints `SF setup case=… pins=%s pin=%s`; the extension list produced by
the crosscheck is **exactly 10 cells, all softfloor** (8 `sf_*` + the 2
`pinphase *_now` cells), and the only difference in those pairs is the
trailing `pins=`/`pin=` fields (`crosscheck-extensions.txt`). Physics rows are
byte-identical; `sfth` t02/t04 and `pinmid_now` match verbatim (not extended).

**3.4 Boundary headline reproduced.** `cmp.py --scout` re-run by this seat:
`== replay vs scout: 64 identical, 3 differ, 18 no-scout-cell` — and the same
in `load16` and `ffps60` (`cmp-scout-repro.log`). The boundary's rc census
reproduced from the `.exit` sidecars: **1197 × rc=0, 66 × rc=134, 0 others**;
the crash set is exactly `cls_proj`, `cls_proj_jolt`, `iso_xrs_1`,
`iso_xrs_jolt` — i.e. the degenerate distribution the author pins, with the
r90 bimodality absent (as the boundary §3 and the author's #7 both state).

**3.5 One pinned cell is not boundary-replayed (finding F3).** The crosscheck
maps 79 cells → **62 scout-sourced + 17 boundary-sourced**. Of the 62 scout
tags, 57 appear by name in the boundary's `replay` arm and 4 more through the
`cmp.py` alias table (`nj_proj_clampbig`, `nj_proj_exclx_on/off`,
`q_proj_hfi_in`) = **61/62 replayed**. The one exception is
**`nj_proj_jolt_hmot`** (the Jolt hinge-motor reading the fixture pins as
`hmot@jolt{avb=0.0,0.0,-2.5019}`): the boundary's replay/load16/ffps60 arms
contain only the **GP** `nj_proj_hmot` cell. The cell is rep-stable in the
scout's own corpus (3/3 byte-identical), the boundary's §9 declares the joint
node lattice armable as-is on GP+Jolt, and its GP twin was replayed
byte-identically — so the pinned value is not in doubt; but the fixture
header's "Only cells the r97 boundary verified are pinned" is over-broad for
this one cell.

---

## 4. Fresh full battery on the committed bytes, under self-owned load

    bash corpus/live/r97-scribe/run-full-load.sh      # 12 self-owned `yes` hogs
    # -> python3 corpus/fixtures/run_battery.py --runs corpus/live/r97-scribe/battery-committed

| measure | value |
|---|---|
| wall / load | **9 m 24 s** (06:28:41Z → 06:38:05Z); 1-min loadavg 51.03 at start → **104.72** at end (12 self-owned hogs + sibling lanes' own full batteries, see §7 F1/F7) |
| receipt | `battery-committed/20261016T062841366622Z/verdicts.json` sha `2da362ecd90c4334…` |
| totals | **324 cases, 322 PASS / 2 FAIL** (265 ordinary + 59 negative), `case_timeout_seconds=20` |
| **r97 rows** | **8/8 PASS**, exact `CASES` marker, `stderr=[]`, `error=None`; cells 24/7/6/11/6/13/8/4 = **79** |
| r97 stdout vs author run 1 | **7/8 byte-identical** (exit+stdout+stderr); the 1 differing row is `softfloor`, differing **only** in the `#` deferred-pin census (`mine pf0=0 pf1=4` vs author `pf0=4 pf1=0`) |
| child census | exactly **83** `r97t*` child dirs; 4 of the 8 xr children carry the allowlisted `handle_crash` line (the 4 strict `rc=134` cells) |
| r97 elapsed | 1.39–9.24 s |
| seed flag | `seeds_unchanged=false` — **solely** the concurrent r98 author lane (§7 F1); **0 of the 94 r97-era seeds** added/removed/changed |
| hog hygiene | killed **by exact PID** (12 recorded PIDs, all confirmed dead; no pattern-wide `pkill`) |

**The two failures are both outside r97 and both load-class:**

1. `navagent3d_retarget` — the documented one-tick pre-switch motion-mismatch
   flake; this run's stderr `before=(1.754246, 0.0, 1.754246)` is byte-identical
   to the signature the same row carried in two r96-era receipts
   (`r96-author/battery/20261016T002412448214Z`, `…T003435704003Z`), and one of
   the family the r96 scribe cited (1.707105 / 1.730676 / 1.754246).
2. `r92_animphys_rbpos` — **not previously filed** (F5): the fixture's own gate
   printed `PASS` (envelope-legal `x=0.5500` inside its `[0,3]` reach), but the
   battery's exact-marker gate failed: **2 of 40 digest rows** differ, both the
   GP `post` row and its `tp_imm` mirror (`pos=(0.5500,…) lv=(0.0000,-1.9421,…)`
   vs pinned `pos=(0.4000,…) lv=(0.0000,-1.4602,…)`, i.e. 3 extra animation
   ticks before the post read under load); all E rows, Jolt and Dummy are
   byte-identical. Not r97-scoped.

**Conclusion (full run):** the committed tree reproduces the r97 surface under
load — 8/8 rows green, 7/8 byte-identical to the author's run 1 with the 1
differing row differing only in the unpinned census; the two red rows are a
documented flake and a newly observed load-conditional r92 row, neither of
which this change touched.

## 5. Fresh r97-only run (narrow behavioral check)

| measure | value |
|---|---|
| command | `run_battery.py --only r97_nodelat_joint,…,r97_nodelat_freegrain --runs corpus/live/r97-scribe/battery-r97-only` |
| receipt | `battery-r97-only/20261016T063859679516Z/verdicts.json` sha `ebb1d9a9171704c6…` |
| totals | **8/8 rows PASS** (32 s wall, ambient load ≈ 82) |
| vs author pre-run | **7/8 byte-identical**; `softfloor` differs only in the `#` census line |
| child census | exactly **83** `r97t*` child dirs; 4 `handle_crash` children |
| r97 elapsed | 1.23–8.54 s |
| seed flag | `seeds_unchanged=false` — a sibling r98 file (`r98assets/badmagic_badjson.glb`) **changed mid-run**; the before-map (116 entries) otherwise verifies on disk |

**Battery verdict is FAIL on the seed flag alone** (`8 pass / 0 fail`); every
r97 row passed. Same environmental cause as §4.

---

## 6. Provenance — the pins were re-derived, not restated

**6.1** The author's crosscheck re-run **on this seat's own fresh full-run
scratch**: `== crosscheck: 79 checked, 79 identical (10 via the declared
setup-line extension), 0 differ, 0 missing` (`crosscheck-fresh-run.log`). The
children compared are the ones this seat's own battery spawned from the
committed bytes — so the 79/79 provenance premise holds on a second,
independent execution.

**6.2** The same tool on the author's `sweep1` scratch reproduces their number
exactly (`79 checked, 79 identical (10 …), 0 differ, 0 missing`), and the
extension list is the 10 softfloor cells (`crosscheck-extensions.txt`).

**6.3 Independent 4-cell replay (this seat's own scratch, normalizer and
command shape — not the author's tooling):** the committed probe copies were
copied into fresh projects whose `project.godot` bytes are built from the
fixture's own `_base()` shape, run `timeout -s KILL 25 godot --headless
[--fixed-fps N] --path <dir> --script res://<probe>.gd -- <args>`, then diffed
against the scout's/boundary's own receipts after re-implementing the declared
normalizations (banner/blank drop, the 2-line Jolt warning, `<Class#N>`,
ASLR fields with frame count preserved):

```
MATCH  nj_bind_jolt          rc=0    src=nj_proj_jolt_bind.r1.stdout.txt
MATCH  cb_plat_ride_jolt     rc=0    src=cb_proj_jolt_plat_ride.r1.stdout.txt   <- the corrected cell
MATCH  cls_gp_crash          rc=134  src=cls_proj.r1.stdout.txt                 <- crash envelope, dump text equal modulo ASLR
MATCH  fg_ffps60_at8_gp120   rc=0    src=r97b_freegrain_fg_proj120_ffps60_at8.r1.stdout.txt
```

**4/4 MATCH** (`replay-provenance.log`, raw children under `replay/`).

**6.4 Crash-envelope census across every seat this audit can see:** boundary
**66/66** `rc=134` in the crash set with 0 escapes (re-verified), authoring
sweep **24** crash children (6 reps × 4), author batteries **16**, this seat's
two runs **8** — **114 crash children, 0 escapes, 0 `rc=0` in the crash set**,
and `iso_clean`/`xr_*` clean in every run.

---

## 7. Findings (ranked, for the canonical judge)

- **F1 (medium-low, environment / custody semantics).** Both of this seat's
  runs report `seeds_unchanged=false`, and the cause is **not r97**: the
  concurrent **r98 author lane** wrote 22 new untracked files into
  `corpus/fixtures/` during the full run (`r98_gltflat.gd`, 4 `r98_probe_*.gd`,
  `r98assets/*` ×17 — all present in `git status` at audit end) and changed
  `r98assets/badmagic_badjson.glb` during the r97-only run. **0 of the 94
  r97-era seeds** were added, removed, or modified; all 94 digests still verify
  on disk. The battery's flag is fail-closed and correct, but a wave-B
  "green custody" run on this shared working tree cannot show `true` while
  another lane is authoring — same class as the r96 scribe's F1. Disposition:
  environmental, no r97 defect; read the flag together with its
  added/removed/changed census.
- **F2 (low, receipts-doc accuracy).** `corpus/live/r97-author/RECEIPTS.md`
  carries a **62-hex** digest for `r97_probe_r97b_softfloor.gd`
  (`d6988ea7…a3d5c82d`) instead of the file's 64-hex sha256
  (`d6988ea7…a3d5cac82d`); the other 10 rows are correct 64-hex digests. The
  copy's byte-identity to `boundary/probes/r97b_softfloor.gd` and the battery
  seed map are unaffected; only a table-replay would fail.
- **F3 (low, verification-scope precision).** `hmot@jolt` is the one pinned
  cell (of 79) whose source receipt the boundary did not re-run (§3.5): the
  boundary's replay arms hold the GP `nj_proj_hmot` only. The value is
  rep-stable in the scout's corpus (3/3) and the boundary declares the joint
  lattice armable on GP+Jolt, so the pin stands — but the parent header's
  "Only cells the r97 boundary verified are pinned" is one cell too broad.
- **F4 (low, header-comment precision — corroborates the sibling simplifier's
  F-1/F-3).** Two parent-header sentences are stale/imprecise: (a) line 71
  "all **44** classes exist" while the code and the pinned cell say **45**
  (the author's correction #2 landed in the report, not the comment); (b) line
  75 "(rc=134 envelope, pinned as crash-class not text)" — `_cell_ok` requires
  `rc == 134` **strictly** on 4 cells (a value pin, not an envelope), and the
  cell `sha` is taken over the normalized crash-dump text (ASLR masked, frame
  count preserved), so the dump text *is* pinned, not "class only". The
  envelope phrasing the author promised is present where they said it is — the
  row comment `run_battery.py:782-783` reads "the XRServer crash/no-crash
  envelope". No behaviour or pin is affected.
- **F5 (medium-low, new observation, not r97-scoped).** `r92_animphys_rbpos`
  is an r92 **envelope arm** (its own gate validates a `[0,3]` reach and pins
  only `ok=REPS`) whose *battery marker* nevertheless pins the exact `post`
  reading. Under this seat's load (1-min loadavg 51→105) the GP post read
  advanced 3 extra ticks — the fixture printed `PASS`, the battery's
  exact-marker gate failed (`2/40` digest rows). The fixture's own comment
  already warns that idle-scheduled advance is "a distribution, not a
  constant". Not observed in any r93–r96 report; file for the canonical judge /
  flake list. Disposition: pre-existing row, outside r97 scope.
- **F6 (expected, freshness).** `LOG.md`/`SCORECARD.md` still end at **Round
  96** (no r97 block/row) — pre-adjudication, same class as r95/r96 F5.
- **F7 (custody events, not defects).** Sibling wave-B seats ran concurrently:
  the r98 author wrote into `corpus/fixtures/` mid-audit (F1), the r97-reviewer
  and r97-critic ran their own full batteries from **frozen copies** outside
  the working tree (observed via `pgrep`), and a sibling committed `7c2b540`
  (r97-simplifier report, +412 lines, **no fixture byte**) at 06:39:06Z. No
  tracked file was modified by this seat; §1–§6 remain valid for the `ec27b78`
  artifact set.

---

## 8. Dispatched labrat probe (probeParent allowance: 1 of 1)

One read-only `labrat` probe was dispatched with the falsifiable hypothesis
*"the three author corrections in `r97-author.md` §3 are exactly right and are
the only receipt-level discrepancies, and the pinned digest values match the
source receipts"*. It returned **CONFIRMED** on all four sub-claims, from the
receipts alone:

- (a) `cb_proj_jolt_plat_ride.r1.stdout.txt` and
  `r97b_replay_cb_proj_jolt_plat_ride.r1.stdout.txt` each show **8 `fl=`, all
  `fl=1`, zero `fl=0`** — the prose, not the receipts, is wrong;
- (b) `CANDIDATES` = **45**, and the scout's `cls_proj.r1.stdout.txt` prints 45
  `CLS` lines with `inst=no_instantiate` on exactly 5;
- (c) the 10 extension cells reconstruct statically from
  `SETUP_EXT_RE`/`r97_probe_r97b_softfloor.gd:59` (8 `sf_*` + 2 `pinphase
  *_now`);
- (d) spot-checked pinned fields (`collide_now@gp/@jolt`, `pinmid_now@gp`, the
  thickness sweep `t02/t04/t05`, vehicle `drop`, `xr_same`) all match their
  receipts.

**Caveat it declared:** no process execution was available to it, so the
universality of (c)/(d) was inference; this seat's own crosscheck on its own
fresh scratch (§6.1) measures that universality — **79/79 identical**. The
allowance was not re-spent.

## 9. Not tested / remaining risks

- The boundary's still-not-armable list remains open: `solver_priority`
  dominance, trimesh `hit_back_faces` semantics, `floor_snap_length`,
  `recovery_as_collision=false`, and the GP thickness-selection rule `[?]`.
  The fixture pins the **measured null** for the `hit_back_faces` up-ray
  (`ray_bf_upon@gp{n=0}`), not the semantics.
- The deferred-pin race's **trigger** remains `[?]`; only the `pf=0` branch is
  pinned and the `pf=1` branch is censused.
- The `xr` cells pin `rc=134` **strictly** while the comments say "envelope"
  (F4b); the 114-crash-child census is degenerate today but the r90 lesson
  (teardown-ordering crashes can go bimodal under different heap states) is a
  standing risk the row comment discloses.
- Neither of this seat's runs isolates "load vs idle": the host was never
  quiet (ambient 51 plus sibling full batteries plus 12 self-owned hogs;
  1-min loadavg peaked at ~105).
- F5's `r92_animphys_rbpos` drift class is a single observation here; its
  trigger (idle-frame scheduling under load) was not isolated.
- The parent header's 44→45 comment lag (F4a) is comment-only and left as
  filed; fixing it would be a tracked write this seat is not assigned.

**Verdict: AUDIT PASSES.** Custody is intact (4507/4507 and 6389/6389 manifest
entries, parent + 10/10 probe copies byte-identical to their sources, 94/94
seed digests in each of the author's four runs, 83 children/pass in every
scratch), every author number re-measured (304→316→324, 265+59, +38/−0
insertion-only, 79 cells/83 children, 48-run sweep with a single distinct PASS
line per arm, 1.05–8.18 s rows), all three corrections confirmed against the
receipts (Jolt `plat_ride` `fl=1`, ClassDB 45, the 10 setup-line extensions),
the boundary's headline re-derived (64/3/18, rc census 1197/66/0), and the
committed bytes reproduce the r97 surface on fresh runs: **8/8 r97 rows PASS in
both the full run and the r97-only run**, 7/8 byte-identical to the author's
runs with the one differing row differing only in the unpinned census, **79/79
provenance on this seat's own scratch** and **4/4 independent replay**.
Findings F1–F7 are environmental, documentation, scope-precision, or
expected-freshness items — none changes a pinned r97 value. No commit made, per
instruction.
