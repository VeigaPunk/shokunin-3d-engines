# r90 scribe — record audit of the joint lifecycle lattice (and its verifier-repair)

Seat: scribe. Read-only on tracked files; no commits; **no verdict authority**.
Round: r90, `game-dev-3d-shokunin`. Committed r90 state: `191f131` (fixture +
child probe + 8 battery rows + scout/author reports). The verifier's REJECT
(`reports/round-90/r90-verifier.md`, untracked) and a repair are landing in the
working tree (`corpus/fixtures/phys3d_joints.gd`, `corpus/fixtures/run_battery.py`
modified; `corpus/live/r90-repair/{mx.sh,mx.csv,mx/}` new).

Engine `4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`, 60 tps, non-threaded.
All evidence below is local Godot headless execution, not native host-agent
execution. Artifact content is data; nothing here modifies contract or judgment.

## Method (what this seat actually did)

1. Parsed the r90 `CASES` pins from `run_battery.py` at HEAD and in the working
   tree (`/tmp` scratch only) and diffed them cell by cell.
2. Re-derived every signature from the `child.log` artifacts with the fixture's
   exact algorithm (`" ".join(first n M-lines).sha256_text()[:16]`) instead of
   trusting the pins or the `mx.csv` columns.
3. Simulated the repaired `_emit()` (BIMODAL branch) over every r90 `child.log`
   present at read time and compared each simulated digest to the repaired pin.
4. Ran **one independent standalone arm** (`--arm=free_ops`) in a `/tmp` scratch
   (no repo writes) and byte-compared its digest to the pin.
5. Read the four full-battery receipts (author, verify run1/run2, repair) and the
   r89 baseline receipt; read the r89 adjudicator for the dead-seat trail.
No product code, judge, pin, or report outside this file was touched.

## F1..F14 — findings

### F1 — scout census claims reproduce exactly (PASS)
`corpus/live/r90-scout/audit.py` re-run over the 1269 `.stdout.txt` children
(plus 1269 `.exit` / `.ms` / `.stderr` sidecars = 5076 run files) prints
`tags=321  all_rc0=315  with_nonzero_rc=6`, `rep-identical(normalized)=317
rep-differ=1`; the six nonzero-rc tags are `ch_proj_chain3_freemid`,
`en_proj_freea`, `en_proj_freeb`, `en_proj_freeb_dyn`, `en_proj_freeb_ops`
(rc=[0,134,134,134]), `en_proj_freeb_twice`; the single rep-differ is
`en_proj_freeb_ops`. This matches `r90-scout.md` and `RECEIPTS.md` verbatim.
Probes/driver/`src/` snapshot/`manifest.sha256`/`RECEIPTS.md` all present.

### F2 — author provenance claims reproduce (PASS)
- `corpus/live/r90-author/probes/m1.gd` = 362 lines (as claimed) + `driver.py`;
  51 distinct `(case × backend)` tags × 3 reps = 153 stdout files.
- `r90_child.gd` vs `m1.gd`: `diff` = 16 lines total, **all in the header
  comment**; the code body is byte-identical ("m1.gd → r90_child.gd verbatim"
  holds modulo the header).
- Standalone receipts: `corpus/live/r90-test/` (10:16–10:22) holds 51 child dirs,
  `rep.md5` (8 per-arm hashes), and the **HEAD-era** fixture copy.
- `corpus/live/r90-author-battery/20261015T132309103031Z/verdicts.json` (sha256
  `0404a6fa…`): `225/225`, `seeds_unchanged=true`.

### F3 — verifier claims reproduce (PASS)
- run1 (`9275f656…`) `225/225`; run2 (`b7e9968a…`) `224/225`, the only failing
  case `phys3d_joints_free_ops` with reason `exact stdout marker missing`.
- run1↔run2 differ in **exactly one case** and, inside it, **exactly one token**:
  pin `freeb_twice@gp{rcc=sig,sig11=1,m4=e7c8b9cc20d38b1e,e=1,w=0}` vs run2
  `freeb_twice@gp{rcc=0,sig11=0,m4=e7c8b9cc20d38b1e,e=2,w=0}`.
- prior-217 stability: the r89 baseline receipt (`739681024b…`) carries exactly
  217 rows; run1, run2, the author battery and the repair battery each add
  exactly the 8 `phys3d_joints_*` rows and have **0** mismatches on the prior
  217 (verdict, marker, actual exit all identical).
- bimodal r1–r6 (`--arm=free_ops` ×6): `freeb_ops@gp` digest identical in all 6
  (`mode_ok=1,m6=124dfece8083d80f,w=0`), crash in r1–r4/r6 (mid-ops truncation,
  6 M-lines) and clean in r5 (M DONE, 8 M-lines); `freeb_twice@gp` clean in
  r1/r3/r5/r6, crash in r2/r4 — matching the report's 5-clean/4-crash split
  once the two battery children are added.
- crashaudit: `freeb@jolt` and `freeb_dyn@jolt` SIGSEGV **post-DONE** (rc=134,
  sig11, `dumped core`) while pinned `rc=0`; crashaudit2: all Jolt cells clean
  (and `freea@gp` crashed there — a further realization of the same class).
- forge: `sA` (`joint_get_type+9` emission), `sB` (twopin priority swap),
  `batfix` (one-digit detach drift `2.1074`, 1 occurrence) + `batout` receipt
  (`1 case, 0 pass, 1 fail`, `exact stdout marker missing`, exit 1) all present.

### F4 — the repair is envelope-only and repins exactly 20 cells (PASS)
- `git diff` of `phys3d_joints.gd` touches only the header comment, the
  `GP_CRASH_CASES`/`GP_BIMODAL` → `BIMODAL` table, and the `_emit` branch; the
  `_run_child` boot convention, `BOUND_S`, arms and cases are untouched, and
  `r90_child.gd` is byte-identical to HEAD.
- Pin diff HEAD→worktree: **exactly 20 cells changed, 0 added, 0 removed**, all
  20 inside the `BIMODAL` table, **no legacy cell touched**.
- Content spot-check: the matrix's `freeb_make@gp` M-lines are byte-identical to
  the HEAD-era pin's M-lines (`made type=5`), i.e. the repair changed the
  *envelope*, not the measured stream.

### F5 — the 504-run matrix is internally consistent (PASS)
`mx.csv` = 14 cases × 3 backends × 12 reps = 504 rows. Recomputing every row
from `mx/<case>_<eng>_<rep>/child.log` (M-line count, ERROR/WARNING counts,
sig11 count, M-sha) reproduces the CSV fields with **0 mismatches**. The 14
matrix cases are the endpoint cases; `sweep`/`rid`/`api` quit in `_initialize`
and are (correctly) not in it.

### F6 — every BIMODAL table entry has a measured basis (PASS, with coverage caveat)
All 20 entries: the pinned prefix sha and the `[n_pre, full_msz]` pair are
traceable to the matrix logs, and **every one of the 504 matrix rows simulates
to a digest identical to the repaired pin** (0 outside-envelope, 0 sha
mismatches). Mode coverage at audit time (matrix | all r90 artifacts):

| tag | [n_pre,full] | matrix clean/crash | all-artifact clean/crash | pinned prefix sha |
|---|---|---|---|---|
| `chain3_freemid@gp` | 2,3 | 0/12 | 0/33 | `c1b063fbc58a5718` |
| `chain3_freemid@jolt` | 3,3 | 12/0 | 33/0 | `544e2fc5305c356f` |
| `detachb_free@gp` | 4,4 | 12/0 | 38/0 | `c293b8d7f2669a3f` |
| `detachb_free@jolt` | 4,4 | 12/0 | 38/0 | `e260e2a3c6282b25` |
| `freea@gp` | 11,11 | 11/1 | 32/2 | `2b5f33bc87de0b0f` |
| `freea@jolt` | 11,11 | 12/0 | 34/0 | `affcca5e5e877587` |
| `freeb@gp` | 11,11 | 12/0 | 32/2 | `d42ece23b296d594` |
| `freeb@jolt` | 11,11 | 0/12 | 21/13 | `90fa3f626053dcff` |
| `freeb_afterclear@gp` | 4,4 | 12/0 | 38/0 | `a31ec35bc29873fb` |
| `freeb_afterclear@jolt` | 4,4 | 12/0 | 38/0 | `0aadc67976644396` |
| `freeb_dyn@gp` | 8,11 | 0/12 | 0/34 | `c3d61244e5e1dc35` |
| `freeb_dyn@jolt` | 11,11 | 0/12 | 21/13 | `ce6c02c7734d56e3` |
| `freeb_make@gp` | 4,4 | 12/0 | 38/0 | `5a1b9bded3cbf88b` |
| `freeb_make@jolt` | 4,4 | 12/0 | 38/0 | `22e9399210234fe5` |
| `freeb_ops@gp` | 6,8 | 0/12 | 1/37 | `124dfece8083d80f` |
| `freeb_ops@jolt` | 6,8 | 0/12 | 26/12 | `0b9af1d2f64aad4a` |
| `freeb_twice@gp` | 4,4 | 9/3 | 20/18 | `e7c8b9cc20d38b1e` |
| `freeb_twice@jolt` | 4,4 | 0/12 | 26/12 | `c42295756101d8d6` |
| `freej_then_b@gp` | 4,4 | 12/0 | 38/0 | `606a01100dfc83f1` |
| `freej_then_b@jolt` | 4,4 | 12/0 | 38/0 | `70d825f7cce91132` |

- Both modes measured: 8/20 (`freea@gp`, `freeb@gp`, `freeb@jolt`,
  `freeb_dyn@jolt`, `freeb_ops@gp`, `freeb_ops@jolt`, `freeb_twice@gp`,
  `freeb_twice@jolt`). Crash-only: 2/20 (`chain3_freemid@gp`, `freeb_dyn@gp`,
  whose GP crash is deterministic across three lanes' probes: 33/33 and 34/34).
  Clean-only: 10/20. The unobserved branch is *admitted but unmeasured*; for the
  four tags with `n_pre < full_msz` the clean branch additionally requires a run
  that prints exactly `full_msz` M-lines (never yet observed, structurally
  expected: the crash only truncates the tail).
- The first `freeb@gp` crash observations in the whole r90 artifact set arrived
  **during this audit** from the live simplifier lane (`vf-extra-base/r6`,
  `vf-extra-fold/r5`, both post-DONE, msz=11), which is why the "crash realized"
  set is 10/20 rather than 9/20 as in the matrix alone.

### F7 — no exposed case is missing from the table (PASS)
Exposure derived from `r90_child.gd`: teardown frees `[joint, joint2] + joints +
bodies + shapes` and `RID.is_valid()` stays true for a freed RID, so the exposed
set is exactly the cases that free a RID mid-run = the 10 case names in
`BIMODAL` (`freeb`, `freea`, `freeb_dyn`, `freeb_ops`, `freeb_twice`,
`freeb_make`, `freeb_afterclear`, `freej_then_b`, `detachb_free`,
`chain3_freemid`) × {gp, jolt}. The excluded endpoint cases are measured clean:
`freeb_world`/`detachb`/`twopin_hi1`/`twopin_hi2` are 12/12 rc=0 sig11=0 in the
matrix and have 0 crashes across all artifacts (22–27 observations each);
`sweep`/`rid`/`api` `quit()` in `_initialize` (verified in source) and show 0
crashes in 9–10 observations each. Dummy is 12/12 clean everywhere, consistent
with its inert `free_rid`.

### F8 — repaired pins vs the fresh battery (PASS)
`corpus/live/runs/20261015T141445740636Z/` (started 11:14:45 local, 14 s after
the pin file's last write at 11:14:31; verdicts 11:19:46, sha256 `2634bab5…`):
**225/225 PASS, seeds_unchanged=true**, and the 8 joint rows are exact-marker
matches. The battery's markers equal the **current** working-tree pins for all
225 cases (0 mismatches), so this receipt judged exactly the pins in the tree.
Realizations in that run: crash for `chain3_freemid@gp`, `freea@gp`,
`freeb_dyn@gp`, `freeb_ops@gp`, `freeb_twice@gp`; clean for the rest.

### F9 — independent standalone arm run (PASS)
This seat ran `godot --headless --path /tmp/r90scribe/scratch --script
res://phys3d_joints.gd -- --arm=free_ops` on byte-identical copies of the
working-tree fixture/child (`phys3d_joints.gd` sha256 `cd9f05fb…`, `r90_child.gd`
sha256 `05b2380b…`). Result: exit 0, one PASS line, **byte-identical (3921 bytes)
to the pin**. All 21 children were clean in this run, including `freeb_ops@gp`
and `freeb_twice@gp` whose matrix basis is crash-only — so the cross-mode
prefix-sha stability is *measured* for those tags by an independent run, not
assumed.

### F10 — every observed realization of every BIMODAL cell fits the envelope (PASS)
Simulating the repaired `_emit()` over **726** `child.log` files with BIMODAL
tags from every r90 lane (scout/author/author-battery/verify run1+run2+bimodal+
crashaudit+crashaudit2/test/critic/boundary/repair/simplifier, including the
live fold runs): **0 rows outside the envelope, 0 digest mismatches**. No legal
realization observed anywhere fails the repaired pins. This is the property the
verifier's REJECT asked for; as far as measurement can tell, it now holds.

### F11 — counts (PASS)
`CASES` = 225 rows, 179 exit-0 (ordinary) + 46 exit-2 (negative controls); the
r90 delta is exactly 8 ordinary rows. r89 baseline = 217 (171 + 46, matching
`LOG.md` "…→ 217 (171 ordinary + 46 negative)"). 217 + 8 = 225. The 8 new rows
are `phys3d_joints_{sweep,rid,api,free_pair,free_ops,detach,chain3,twopin}`.

### F12 — README consistency (FAIL — stale)
`corpus/fixtures/README.md:5` still says "**217** registered cases (171 ordinary
and 46 negative)". The tree registers **225 (179 ordinary + 46 negative)**. The
r89 fold corrected the same line to 217 (r89-adjudicator F1); r90's +8 needs the
same correction. Top-level `README.md` carries no count. `LOG.md` has r88/r89
sections and no r90 section (round unsealed — expected). `SCORECARD.md`'s round
table and verdict blocks stop at r87 (stale by r88 and r89) — recorded, not this
seat's call.

### F13 — dead-seat attribution, r89 scribe (recorded)
`reports/round-89/r89-adjudicator.md`: the r89 scribe died in the **09:0x
rate-limit sweep** (two dispatches) before reporting; its record duties were
absorbed into that adjudicator, and "a scribe retry may still land post-hoc; any
finding would queue for r90's record". This seat is that retry; the r89 record
items were re-derived where cheap (counts 217 = 171+46 ✓; r89 baseline receipt
index-identical to r90's runs ✓). The only file written anywhere in the repo
between 08:00 and 10:16 today is that adjudicator (10:06).

### F14 — dead-seat attribution, r90 author (consistent, partially evidenced)
`r90-author.md`'s seat-completion note attributes probe+driver+51 measurements
to the dispatched ds author and the fixture port to the parent. Artifact
timeline supports the split: author artifacts 05:52–05:55
(`r90-author/{probes/m1.gd,driver.py,runs}`), then a **4h20m gap**, then the
parent's completion 10:16–10:28 (child probe 10:16, standalone receipts
10:16–10:22, author battery 10:23–10:27, report 10:28, commit `191f131`
10:28:28 whose message itself says "(dead-seat completion)"). The **death time
(09:0x) has no r90 artifact of its own**; it is asserted by the author report
and corroborated only by the r89 adjudicator's sweep statement plus the artifact
gap. Wave-B reports: `r90-verifier.md` landed 10:45 (untracked);
`r90-simplifier.md` landed 11:23, after this audit's artifact window (its
artifacts are counted, its claims are not audited here); critic / boundary
artifacts exist (10:39–10:46) with no reports yet, and the simplifier lane was
still live at audit time (786 child logs, fold diffs).

## Blocking flags

- **B1 (fold) — README count is wrong**: `corpus/fixtures/README.md:5` says 217
  (171 ordinary + 46 negative); the tree registers 225 (179 + 46). Fix in the
  fold, same correction class the r89 verifier raised and the r89 fold applied.
- **B2 (fold) — fixture header comment asserts an unmeasured claim**:
  `corpus/fixtures/phys3d_joints.gd` says the 504-run matrix "shows the window
  reachable on gp+jolt for **every** exposed case". Measured: the window is
  realized on 9/20 tags in the matrix itself and 10/20 across all artifacts
  (the other 10 are clean-only). The pins are *safer* than the comment claims
  (they admit the unobserved branch), but a tracked file must not state a
  measurement that does not exist. One-line wording fix (e.g. "mechanism shared
  by all 20 exposed tags; realized in 10/20 in the matrix+artifact set").
- **B3 (record integrity) — `r90-scout.md` carries artifact-untraceable or
  contradicted claims** (details and verbatim quotes in "Conflicts" below). The
  scout's §1/§2/§3/§4 are otherwise well corroborated (PRIO-1 substance, PRIO-3
  `gap=0.4811 lv.y=19.3930`, HM-2 `set=ABSENT`, EN-1/EN-3 rc classes, G6-a
  `bx=0.9553,0.2955,0`, DC-1 `prio32 gap=0.6473` vs `pnocoll32 gap=0.0198`,
  BF-1 `joint_set_breakable=false`), so these look like localized provenance
  slips — but the round's committed knowledge record must be corrected or the
  three items withdrawn before sealing.

The repaired pins themselves carry **no blocking defect found by this audit**:
726/726 observed realizations fit, 4 full batteries pass (3 of them on the
repaired bytes), and one independent standalone arm run is byte-identical. The
judge decides; this seat does not.

## Recorded, non-blocking

- **N1 calibration narrowing**: the 20 BIMODAL cells no longer emit `e`/`w`
  (they are mode-dependent: e.g. `freeb@gp` e=5 clean vs e=4 crash). The
  envelope pins rc-class + sig11 + `msz`-class + prefix sha, so a run with any
  `e`/`w` inside a named realization passes. If the calibration axis wants the
  error/warning counts, pin per-mode `(rc,e,w)` tuples alongside `mode_ok`.
- **N2 coverage**: 2 crash-only + 10 clean-only tags (F6 table). The unobserved
  branches are structurally admitted (post-DONE crashes keep the full M stream;
  clean runs extend the same deterministic prefix) but never measured.
- **N3 provenance**: `r90-test/rep.md5`'s hashed payload is undocumented and not
  reproducible from the artifacts (8 per-arm hashes; none equals the md5 of the
  arm's PASS line at HEAD or repaired, nor of concatenated child M-lines in the
  orders tried). The "verified rep-stable ×2 standalone" claim therefore rests
  on one set of 51 child dirs; rep-stability itself is corroborated by four
  batteries and this seat's independent run.
- **N4 wording**: `r90_child.gd`'s inline comment "# make on fresh j2 works"
  sits above a pinned read of `fresh type=0` (0 = `JOINT_TYPE_PIN`, while an
  unmade joint reads 5 = `JOINT_TYPE_MAX`); comment vs token mismatch, wording
  only.
- **N5 cross-lane rate divergence (not a conflict)**: the scout's own
  `jend.gd` `freeb_twice` probe crashed 4/4 (all post-DONE) while the fixture's
  `freeb_twice@gp` is bimodal (20 clean / 18 crash at census time). Same class,
  different probe and different realization rate.
- **N6 live lane**: the simplifier's fold runs (786 child logs, `fold-child.diff`
  / `fold-parent.diff`) reproduce every BIMODAL pin (0 mismatches), but the
  fold's own claims are not audited here.

## Conflicts (verbatim, for the canonical judge)

1. `r90-scout.md` §2 HM-1 / F3 vs artifacts —
   report: "Jolt `flag=true`, `av.z≈0` steady — motor flag accepted, zero
   effect"; falsifier: "Jolt |av.z|>0.1 at t=24".
   artifact `runs/fl_proj_jolt_hmot.r1.stdout.txt` (and `.r2`, `.r3`):
   `FL hmot tv=5.0 mi=50.0 flag=true` … `t=24 … av=0.0000,0.0000,-5.0000` —
   identical to `runs/fl_proj_hmot.r1.stdout.txt` (GP). The likely source of the
   slip is the disclosed stale-named `runs/fl_proj_jolt_hmot_jolt_flag.r1.stdout.txt`,
   whose header is `FL0 case=hmot_jolt_flag jtype=pin engine=Jolt Physics` (a
   plain-pin trace with `av=0`), and/or the linear-motor `g6_motor_y` trace.
2. `r90-scout.md` §1 PRIO-1 vs artifacts and source —
   report quotes `WARNING: "1" is the only supported value for solver priority
   in Jolt. Ignoring provided value "N".`
   No file under `corpus/live` contains that string; `src/jolt_physics/jolt_joint_3d.cpp:182`
   and every run say: `WARNING: Joint solver priority is not supported when using
   Jolt Physics. Any such value will be ignored. This joint connects
   '<unknown>' and '<unknown>'.` (the substantive claim — `get_after=1` on every
   set, one warning per non-1 call, none for prio1 — is verified).
3. `r90-scout.md` §5 CH-1 vs artifacts —
   report: "chain3_mixed (pin+hinge+slider) … GP e.g. chain3_mixed t=30
   `c=(-0.6396,-0.3221,1.7553)` … Jolt same traces"; witness "chain3_swing GP
   t=30 `b≈(0.937,-0.026,-0.155)`"; and "chain3_off (offset pivots)".
   Artifacts: `grep -rl` for `-0.6396`, `1.7553`, `2.3946`, `0.9370`, `-0.0260`,
   `1.1550` over `runs/` returns **0 hits**. `CH0 case=chain3_mixed … nbodies=2
   njoints=2`, t=30 `b1=(0,3.3000,0) b2=(0,2.7000,0)`; `chain3_swing` t=30
   `b1=(0.0673,3.3068,0) b2=(0.1936,2.7182,0)`; per `probes/jchain.gd`,
   `chain3_mixed` is J1 pin + J2 hinge (no slider) and `chain3_off` is
   `disable_collisions=true` (not "offset pivots").

## Out of scope / not audited

- No verdict on the round's admissibility; no axis scoring.
- The simplifier's fold contents, the critic's and boundary's findings, the
  verifier's verdict, and the r91+ / other-fleet artifacts present as untracked
  dirs (`reports/round-1-20261015/`, `reports/round-91..96/`) are outside this
  seat's audit.
- Engine-semantics adjudication (e.g. what a freed RID's `joint_get_type=0`
  means); only artifact-to-claim consistency was checked.
- The repair lane's pin-edit *intent*; only its measured effect is recorded.

## Artifact paths and provenance

- Pins: `corpus/fixtures/run_battery.py` (working tree sha256 `be5663f7…`;
  HEAD `191f131`), fixture `corpus/fixtures/phys3d_joints.gd` (`cd9f05fb…`),
  child `corpus/fixtures/r90_child.gd` (`05b2380b…`).
- Matrix: `corpus/live/r90-repair/mx.sh` (`6a9e70f3…`), `mx.csv`
  (`e1331e33…`), 504 logs under `corpus/live/r90-repair/mx/`.
- Batteries: repair `corpus/live/runs/20261015T141445740636Z/verdicts.json`
  (`2634bab5…`); author `…/r90-author-battery/20261015T132309103031Z` (`0404a6fa…`);
  verify run1 (`9275f656…`), run2 (`b7e9968a…`); r89 baseline
  `corpus/live/r89-fold-verify/20261015T083635374793Z` (`73968102…`).
- Scout: `corpus/live/r90-scout/{audit.py,driver.py,probes/,runs/,src/,RECEIPTS.md,manifest.sha256}`.
- Verifier: `corpus/live/r90-verify/{run1,run2,bimodal,crashaudit,crashaudit2,forge}`.
- This seat's scratch (untracked, `/tmp`): `/tmp/r90scribe/` (parsers, census,
  envelope simulation, `scribe_free_ops.out`).
- Reports: `reports/round-90/{r90-scout.md,r90-author.md,r90-verifier.md}`;
  this file.
