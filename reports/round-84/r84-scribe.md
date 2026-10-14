# game-dev-3d round 84 — scribe report (seat `scribe`, host: devin)

Wave `shokunin-train-20261101-w15` (theme: capture-side consumers (audio),
deferred physics cells (g2d), backend pinning (g3d); arm g3d-r84 = Godot
backend pinning — `jolt_edge` child re-exec under `physics_engine="Jolt
Physics"` pinning per-arm {same|differs-constants|inverts}; `phase_delta` arm
pinning process-phase write → delta=2).

Declared lane axis (dispatch brief, verbatim): "r84 SCRIBE (g3d) — receipt
hygiene audit … Read SHARED.md. Audit raw-vs-parsed evidence, seed/receipt byte
stability, seat landings, report integrity. Report -> reports/round-84/r84-scribe.md."

Wave registry (`~/Projects/shokunin/.ufo/waves/shokunin-train-20261101-w15/registry.json`,
`dispatched: 2026-10-14T17:45Z`) names this seat `g3d-r84.scribe = 023ecedd`.

This seat does not implement the arm and does not judge. It re-measures the
raw-stream/parsed-view surface the arm's cells and pins will be read against,
re-sweeps receipt hygiene over the r84 landings, and brackets the seat landings
in the window 17:30:18Z–17:32:5xZ.

## Behavior (what this seat did)

1. Read `SHARED.md`, `spec.json`, `registry.json`, `tasks/g3d-{author,baseline,boundary,scout,scribe}.md`,
   and the w14 closeout / w12 xconnector references named in SHARED.md.
2. Verified the 9 inherited r83-scribe audit tools byte-identical to the shas
   the r83 report recorded, then carried them into this seat's scope as
   `r84s_*` with a single mechanical substitution (`r83`→`r84`, `r83s`→`r84s`);
   lineage re-verified by reverse-substitution diff (all 9 byte-identical
   modulo the substitution). No inherited claim is re-used unmeasured.
3. Took an arrival snapshot (17:30:18Z) and ran the full sweep: Godot
   raw-vs-parsed receipt ledger, receipt line-join hazard, bpy raw→parsed
   audit, hygiene/drift, classifier hazard scan, seat landings — all read-only,
   all with `.exit` rc files.
4. Re-swept landings/classifier three times as siblings wrote (17:30:1xZ,
   17:31:3xZ, 17:32:2xZ) so every count is an explicit bracket.
5. Audited the r84 landings that exist at this bracket: scout per-arm backend
   matrix (54 run groups), boundary backend-gate + arm matrix + phase cells
   (32 run groups), baseline freeze artifacts (1703 files), author scaffold
   (2 files) — plus the fixture's own `threaded_edge` child-re-exec parse,
   which is the pattern the `jolt_edge` arm mirrors.

## Commands and receipts (cwd repo root; all bounded)

| # | command | exit | receipt |
|---|---|---|---|
| 1 | `bash corpus/live/r84-scribe/scratch/r84s_snapshot.sh` | 0 | `runs/arrival_snapshot.txt` |
| 2 | `timeout -s KILL 900 python3 …/scratch/r84s_godot_ledger.py` | 0 | `runs/godot_ledger.json` (140 receipts) |
| 3 | `timeout -s KILL 600 python3 …/scratch/r84s2_join_hazard.py` | 0 | `runs/join_hazard.json` |
| 4 | `timeout -s KILL 600 python3 …/scratch/r84s_hygiene.py` | 0 | `runs/hygiene_r84.json` |
| 5 | `timeout -s KILL 600 python3 …/scratch/r84s_classifier_scan.py` (×3) | 0 | `runs/classifier_scan.json` |
| 6 | `timeout -s KILL 600 python3 …/scratch/r84s_landings.py` (×4) | 0 | `runs/landings.json` |
| 7 | `timeout -s KILL 900 python3 …/scratch/r84s_rawview.py --roots <38 seat roots + runs> --json-out runs/rawview_all_bpy.json` | 0 | `runs/rawview_all_bpy.json` (169 streams) |
| 8 | `python3 …/scratch/r84s_rawview_summary.py` | 0 | `runs/rawview_all_bpy.stdout.txt` |
| 9 | `python3 -c …` ad-hoc receipt joins (seed-revision map, sha families, fixture deltas) | 0 | stdout recorded in this report; no separate file |

Every run's rc is stored beside the receipt (`runs/<name>.exit`, all `rc=0`).
Tool lineage: `r84s_*` sha256 = `4c8b7c8c…` (hygiene), `d059f3d4…` (ledger),
`0c3cc9e4…` (join hazard), `dc331f38…` (classifier scan), `96d425e3…`
(landings), `7345d340…` (rawview), `ee793c5e…` (rawview summary),
`b4467125…` (frontier audit, unused this round), `074c267f…` (snapshot).

## Landed state at measurement time (17:30:18Z–17:32:5xZ)

- HEAD `c4b2fa2ae1b20becd83a15e1ad4fe5e17e4c54db` ("r83 report-last: 9/9 seats
  — AGREE 18/18, ADMIT-corr") at every poll; `git status --porcelain` **empty**
  (no tracked modification; `corpus/live/` is gitignored). **No integrator
  commit after `c4b2fa2` in the observed window.**
- `reports/round-84/` existed and was **empty** at 17:31:53Z and 17:32:29Z —
  no sibling report has landed; nothing is adopted from any sibling.
- Fixtures at HEAD (54 seed-tracked files + `README.md` = 55):
  `phys3d_events.gd` `1e042bcfcac0245b3e94597abf5d3f710d46d64a397510621a8531b0f11857e5`,
  `run_battery.py` `0381b7500d5e1b270fcab6d0e42d3d4682edbd96c9c9f29058ac7f0a9bf0f1f2`,
  `bpy_battery.py` `045102a8514df96bda0c2268841ec0751de87f678f34cbdf981c3a7c6ff882ec`,
  `bpy_sync_probe.py` `07ec83e33512b6430b085dee9029163b41594b4e6e8608aab8b98d6c6c483a48`,
  `project.godot` `1fda90d46b0529aea0e75710a64f038cbf983adc8385285dd8bbe6202a8eac23`
  (byte-identical to the scout's and the boundary's copied project seeds).
- Engines/toolchain (this host, carried): `/usr/bin/godot`
  `4.7.2.stable.arch_linux.ed1daf0bf` (2026-08-17), `python3` 3.14.7.
- r84 seat landings at the final bracket: **author** 2 files / 0 runs
  (`proj_default/project.godot`, `proj_jolt/project.godot` — scaffold only);
  **baseline** 1703 files / 1 run group / 1 bpy battery receipt
  (`runs/bpy-20261014T173207689455Z`, PASS 83); **boundary** 115 files /
  32 run groups / exits {0, 1, 137} / 6 streams with non-empty stderr;
  **scout** 214 files / 54 run groups / exits {0, 1, 2} / 9 streams with
  non-empty stderr; **scribe** (this seat) `corpus/live/r84-scribe/`.
- Provenance references in SHARED.md check out: w12 `xconnector.md` exists;
  w14 `closeout.md` exists; **`c1b7a4f` is the w14 closeout commit in the WAVE
  repo (`~/Projects/shokunin`), not in the lane repo** — `git cat-file -t
  c1b7a4f` fails in `game-dev-3d-shokunin` and resolves to
  `c1b7a4fb84adeed1ab683b72b92994e976c0f595` ("w14 closeout: r75/r74/r83 all
  ADMIT-corr") in the wave repo. Stated for provenance clarity; not a conflict.

## 1. Raw-vs-parsed ledger (Godot battery receipts)

- **Every one of the 140 battery receipts replays exactly**: re-deriving each
  case's verdict *and reason list* from the receipt's own stored lines through
  the tracked `run_battery.classify` (boundary-preserving join) yields
  **0 case mismatches** across **14,355 case records**
  (`runs/godot_ledger.json`). Tracked `CASES` = 186 at HEAD.
- r83 → r84 delta: receipts 107 → 140 (+33), case records 12,354 → 14,355,
  cross-receipt stdout-diff cases 7 → 13, receipts with tracked-CASES drift
  3 → 3 (unchanged: the three r77-era receipts whose
  `navagent3d_detour_mut_force_link` marker differs from the reworded tracked
  marker — era-legitimate, recorded not reconciled).
- **The line-join hazard reproduces at r84 and is still the receipt format's
  consumer-side hazard**: naive `"\n".join(lines)` (no trailing newline)
  forges reason-list mismatches in **33 of 140 receipts**; the
  boundary-preserving join gives **0** (`runs/join_hazard.json`). Mechanism
  unchanged from r83: the last stdout line (the engine banner) is spliced onto
  the first stderr line and read as an `unexpected diagnostic`.
- **All 13 cross-receipt stdout-difference cases have exactly two families**,
  and in every case the second family is the *banner-only* stdout of a run
  whose arm legitimately failed or was a negative control (`4f7f5ee0…`). No
  case shows a third family. The 6 new diff cases this round are the
  `phys3d_events_*` rows the r83 folds added (`btm`, `cast`, `contact_stale`,
  `isect`, `static_nopair`, `threaded_edge`).
- **Ignored surface of the tracked verdict gate**: across the 140 receipts,
  line classes are `marker 14,323 / blank 14,323 / ignored 14,355 /
  error_trigger 0 / leak_trigger 0` — i.e. every stored case stream's
  non-marker line is exactly one blank line; no `ERROR:`/ObjectDB-leak trigger
  fires in any *stored PASS* stream.

## 2. bpy raw→parsed audit (169 streams)

Shape histogram `(raw ARM-prefixed, parsed cells, glued/dropped, dup keys)`:

| shape | n | note |
|---|---|---|
| (134, 131, 1, 3) | 44 | current era (r83: 43); 49 foreign cells |
| (112, 112, 0, 0) | 34 | pre-fold era |
| (123, 122, 1, 1) | 34 | pre-fold era |
| (78, 78, 0, 0) | 14 | |
| (0, 0, 0, 0) | 1 | `r81-critic/runs/lax/…` — 3 raw lines, no `PROBE_DONE`, 162 B stderr (dead probe) |

- The current-era shape is unchanged in kind: 3 duplicate keys resolve
  physical-last-wins, 1 glued line (`REORDERGLUE::ARM reorder | gluevictim |
  FD1 | …`) is dropped by the `^ARM` parser, 49 cells remain outside the
  tracked namespace. 168 of 169 streams carry `PROBE_DONE`; 1 does not (above).
- The `n_arm_lines` semantics outlier persists unchanged: `r81-critic/runs/lax2`
  records 123 raw ARM-prefixed lines vs 122 parsed cells.

## 3. Seed / receipt byte stability

- **The 186-row receipt population spans three recorded revisions of
  `phys3d_events.gd`**, all self-reporting `seeds_unchanged: true`: 8 receipts
  on the pre-fold `6ddf4aef…`, 1 on the mid-fold `d398e7ca…`
  (`r83-simplifier/runs/VALL-full/20261014T170058883201Z`), and 1 on the
  sealed post-fold `1e042bcf…` = HEAD
  (`corpus/live/integrator-r83-fold-full/20261014T171754562593Z`, 186/186 PASS,
  55 seed digests). The r83 author's report sha `6ddf4aef…` is the pre-fold
  revision and the r83 adjudicator's `1e042bcf…` is the post-fold one — both
  correct, different revisions.
- **The folds are replay-identical at byte level.** For each of the 10
  `phys3d_events_*` cases, the passing-family stdout sha256 is a *single value*
  across all 9 recorded fixture revisions (`076bce41`, `1e042bcf`, `4791b15d`,
  `5ae059ee`, `6ddf4aef`, `a7ec1aca`, `ae36c368`, `c6443a17`, `d398e7ca`) —
  e.g. `cast` = `3c1a0100…` in every revision, `btm` = `b44f35fc…`. The only
  off-family value anywhere is the banner-only `4f7f5ee0…` of failing /
  negative-control runs. So a "prior rows byte-identical" claim is true
  *within the passing family* and must name the receipt it is anchored on; the
  only anchored-on-HEAD (post-fold, full-186) receipt is
  `integrator-r83-fold-full/20261014T171754562593Z`.
- Fixture-set delta vs the r83-era receipts: `phys3d_events.gd` is absent from
  the r83-era seed sets entirely (it postdates them), and
  `README.md`, `bpy_battery.py`, `bpy_sync_probe.py`, `run_battery.py` differ
  from the r83-era recorded digests — era-legitimate; the two receipts under
  `corpus/live/runs/` therefore show 6 and 5 seed-drift keys (r83 sweep: 4 and 2).
- **The r84-baseline freeze verifies independently**: `frozen/frozen-head.txt`
  = `c4b2fa2…` = HEAD; the extracted `frozen-extract/corpus/fixtures` is
  byte-identical to the tracked fixtures (55/55 files, 0 differ, no
  extra/missing); `frozen/fixture-digests.txt` has 54 rows whose *names* equal
  the tracked seed set (README.md excluded) and whose digests match the extract
  (0 mismatches); `frozen/git-files.txt` = 367 rows = `git ls-files | wc -l`;
  `frozen/frozen-tree.tar` lists cleanly (`tar -tf` rc 0).
- Hygiene sweep (`runs/hygiene_r84.json`): bpy seat receipts 159 → 160 since
  the r83 bracket; stamps all match directory names; stdout mtime ≤ verdicts
  mtime for all; identity groups 45 and distinct probe paths 31 (both
  unchanged); ASLR-token hits **4, all carried** (the four `r82-boundary`
  `detach-*` receipts printing `pid=<n>`); one bpy receipt with non-empty
  stderr carried (`r81-critic/runs/lax`, 162 B). Frontier-physserver claim set:
  28 runs, all exit 0, stderr 0 bytes, replicas byte-identical — re-verified.
- **r84 receipt hygiene is clean on completeness and ordering**: every r84
  stdout receipt has a matching `.exit` (bare-integer convention, no mixed
  styles), no future mtimes, and no stdout-after-exit mtime inversion.

## 4. Backend pinning surface (r84's arm) — raw readings, no verdict

Two independent seats measured the per-arm backend split; both agree on the
same three classes and the same constants:

| arm | DEFAULT (`proj`) | Jolt (`proj_jolt`) | class |
|---|---|---|---|
| `isect` | `settled=1 mask2=0 away_w0=0 away_n1=0 back_w0=1` | identical stdout | **same** |
| `contact_stale` | `setup_isect=1 in_n1_c=4 out_w0_c=4` | identical stdout | **same** |
| `cast` | `safe=0.14453125` (`settled_safe=0.144531`) | `safe=0.149841309` (`0.14984130859375`) | **differs-constants** |
| `btm` | `travel=-0.9765625` | `travel=-0.998535156` | **differs-constants** |
| `static_nopair` | `tp_fired=false tp_ov=0 pre_clear=0` → exit 0 | `tp_fired=true tp_ov=1 pre_clear=1` → exit 1 `drift … delta=1` | **inverts** |

Sources: scout `runs/{jj,pj}_<arm>.{1,2}` (2 reps each) and boundary
`runs/{d,j}-<arm>` (1 rep each), plus the boundary's 7-project gate probe.
`contact_sig`, `pp_queries`, `srv_area_cb`, `sync_cb`, `threaded_edge` are
identical across backends in the scout's 2-rep runs.

- **Backend-availability gate, measured per project setting** (boundary
  `runs/backend-proj*.backend.stdout.txt`, all exit 0, stderr 0 bytes):

| `3d/physics_engine` value | `jolt_class` | `godot_class` | singleton | space RID |
|---|---|---|---|---|
| `DEFAULT` | false | true | `PhysicsServer3D` | `RID(98784247808)` |
| `Jolt Physics` | **true** | false | `PhysicsServer3D` | `RID(98784247808)` |
| `jolt physics` | false | true | `PhysicsServer3D` | `RID(…)` |
| `Jolt` | false | true | `PhysicsServer3D` | `RID(…)` |
| `GodotPhysics3D` | false | true | `PhysicsServer3D` | `RID(…)` |
| `Dummy` | false | false | `PhysicsServer3DDummy` | `RID(0)` |
| `""` | false | true | `PhysicsServer3D` | `RID(…)` |

  So on this build Jolt availability is **not** a property of the engine alone:
  `class_exists("JoltPhysicsServer3D")` is false from the DEFAULT project and
  true only inside a project whose setting is the exact string `Jolt Physics`;
  any near-miss string (`Jolt`, `jolt physics`) silently yields GodotPhysics3D
  with no error. The scout's own `w_proj*` probes agree (`setting_hint=
  DEFAULT,Jolt Physics,GodotPhysics3D,Dummy`; `w_proj_bogus` with
  `setting_value=Jolt Physics X` reports `space_state
  class=GodotPhysicsDirectSpaceState3D` and GodotPhysics constants).
- **Receipt-identity hazard (verbatim)**: the scout's `jj_*` prefix denotes the
  **Jolt-pinned** project and `pj_*` the **plain** project — the intuitive
  reading is inverted. Measured, not inferred: `pj_cast.1` prints the tracked
  DEFAULT marker `settled_safe=0.144531 settled_unsafe=0.150391`, and
  `jj_cast.1` fails with `drift safe=0.14984130859375 unsafe=0.1500244140625`,
  the exact constants the scout's `w_proj_jolt` probe and the boundary's
  `j-cast`/`backend-proj_jolt` receipts measure for Jolt. A reader of the
  receipts alone can therefore invert every backend cell.
- **Phase cells**: the boundary's `d-phase` receipt carries the process-phase
  evidence: `A_phys … delta_pf=1`, `B_proc … delta_pf=1`, and
  `C decoy_wf=7 treated_wf=7 treated_of=19 first_sig=7 last_sig=9
  first_delta_pf=0 keyed_delta_pf=2 decoy_delta_pf=0 n=4`, plus
  `M1_phys_contacts w0=0 n1=8 n2=8 wf=8` vs `M2_proc_contacts w0=0 n1=0 n2=4
  wf=10 of=27` and `sig_counts A=4 B=4 C=4`. `d-phase2`/`d-p2-node-phys`:
  `kind=node phase=phys wf=6 of=17 w0=0 sig=7 delta_pf=1 n=1`. The delta=2
  reading exists **only** on the keyed sub-cell (`keyed_delta_pf=2`);
  `first_delta_pf` and `decoy_delta_pf` read 0.
- **Mangled receipts**: five boundary run groups
  (`d---`, `d---kind=node`, `d---kind=srv`, `d---phase=phys`, `d---phase=proc`)
  are exit 1 with `ERROR: r84b_edges: unknown arm --phase=phys` /
  `unknown arm --kind=node` / `unknown arm --` on stderr. They are honest
  unknown-arm rejections, but their file stems look like measured
  `phase=phys`/`phase=proc` cells and are not. Distinct cells did not collide
  onto one stem in this bracket (no duplicate stems observed), but the runner's
  `out="runs/${PREFIX}${arm}"` concatenation is the collision surface.
- **Negative controls present**: boundary `x-cast` (`size0=0 … safe=-1.0`),
  `x-btm` (all zeros), `x-isect` (`settled=0 back_w0=0`), `x-contact_stale`
  (all zero), `x-static_nopair` (`srv_z=-999.0 mv_fired=false mv_delta=-1`),
  and `x-cast_unguarded` = **exit 137** with
  `SCRIPT ERROR: Out of bounds get index '0' (on base: 'PackedFloat32Array')`
  (crash-class; the only non-scout dirty stream in the r84 classifier scan).

## 5. The child-re-exec parse surface the `jolt_edge` arm mirrors

The tracked fixture's `threaded_edge` (phys3d_events.gd:504-553, :561-611) is
the pattern the brief tells the author to mirror as `thrproj` → `joltproj`.
Read verbatim from the fixture, the parse is:

- child spawned through `/bin/sh -c "timeout -s KILL 30 <godot> … > child.log 2>&1"`
  (`:526-529`) — the `timeout -s KILL` bound and the log redirection are both
  the r83 reviewer F2 fold;
- the parent scans the log line-by-line and takes **the last line that
  `begins_with("CHILD_RESULT ")`** as `verdict` (`:534-537`, last-wins);
- `script_err` is set on `SCRIPT ERROR`/`Parse Error` anywhere, or on any line
  beginning `ERROR:` **except** one containing `Space state is inaccessible`
  (`:538-544`) — a substring exemption;
- the case passes only if `code == 0 and not script_err and verdict == expect`
  with `expect` the full pinned `CHILD_RESULT` string (`:548-552`).

Measured at r84 (scout receipts): both backends' child logs contain exactly
**one** `CHILD_RESULT` line, the expected one, preceded by 12
`ERROR: Space state is inaccessible right now…` lines and a
`CHILD_NOTE early_null=false` line; the parent's stdout marker prints
`proc_dss_refused=true … child_exit=0` under both DEFAULT and Jolt, 2 reps each.

**Receipt-hygiene consequence**: `child.log` lives inside the *project*
directory (`res://thrproj/child.log`, `:522`), so it is a **single mutable
slot** — N reps overwrite it and only the last run's raw child log survives;
the per-run evidence is the parent's stdout line. The scout's two
`jj_threaded_edge`/`pj_threaded_edge` reps share one log each. Any `jolt_edge`
mirror inherits this: child-log evidence cannot be replayed per rep from the
receipt set, and the `Space state is inaccessible` exemption is a substring
test that would mask an unrelated ERROR line containing that phrase.

## 6. r84 classifier hazard scan (77 streams)

- 12 of 77 r84 streams are **dirty under the tracked classify** (they would
  FAIL as CASES rows): scout `jj_btm.{1,2}`, `jj_cast.{1,2}`,
  `jj_static_nopair.{1,2}` (Jolt-side genuine failures), scout
  `w_proj`, `w_proj_jolt`, `w_proj_bogus` (probe's own
  `ERROR: 3 RID allocations … leaked at exit` + ObjectDB leak warning on
  stderr), boundary `x-cast_unguarded` (crash-class).
- 7 streams carry process-local `RID()` tokens — all boundary
  `backend-proj*` probes (`RID(98784247808)` ×6, `RID(0)` for `Dummy`). No
  r84 stream carries a `RID()` token in the scout's arm matrix. The scout's
  `w_proj`/`w_proj_jolt` streams additionally carry the direct-state handle
  `<GodotPhysicsDirectBodyState3D#26591888846>` /
  `<JoltPhysicsDirectBodyState3D#26591888846>` — the same object-handle class
  as r83's `<PhysicsServer3DManager#3103785120>`, i.e. process-local tokens
  that must not appear in an exact-marker row.

## Findings

1. **All 140 landed Godot battery receipts replay exactly (0 case mismatches /
   14,355 records) only under the boundary-preserving line join**; the naive
   join forges reasons in 33 receipts. The format hazard is unchanged at r84
   and is a consumer-side property, not a battery defect.
2. **The 186-row baseline is revision-scoped**: 8 receipts sit on pre-fold
   `6ddf4aef…`, 1 on `d398e7ca…`, and exactly 1
   (`integrator-r83-fold-full/20261014T171754562593Z`) on the post-fold
   `1e042bcf…` = HEAD. The passing-family stdout sha is single-valued across all
   9 recorded revisions for all 10 `phys3d_events_*` cases, so the folds were
   byte-replay-identical — but a zero-drift claim must name which receipt
   anchors it.
3. **The r84-baseline freeze verifies independently and completely**: frozen
   HEAD = HEAD, extract fixtures 55/55 byte-identical, 54 digest rows = the
   seed set with 0 mismatches, git-files 367 = `git ls-files`, tar lists rc 0.
4. **The backend partition the arm is pinning is already measured by two
   independent seats and agrees**: `isect`/`contact_stale` same;
   `cast`/`btm` differs-constants; `static_nopair` inverts (`tp_ov` 0→1,
   `pre_clear` 0→1, DEFAULT exit 0 vs Jolt exit 1 with `delta=1`). The
   wave-14 carried guard "GodotPhysics claims are backend-scoped; Jolt inverts
   `static_nopair`" is re-confirmed at r84 on a second fixture surface.
5. **Jolt availability is a per-project property on this build**: the class is
   invisible from the DEFAULT project and appears only under the exact setting
   string `Jolt Physics`; `Jolt`, `jolt physics`, `GodotPhysics3D`, `""` all
   silently yield GodotPhysics3D, and `Dummy` yields a null space (`RID(0)`).
   A backend gate that probes from the default project answers "absent" while
   Jolt is in fact selectable — the r83 `probe1` `jolt_class=false` reading and
   the r83 scout's "Jolt is present" reading are both correct and measure
   different projects.
6. **The scout's `jj_`/`pj_` receipt prefixes denote Jolt / plain respectively
   — the inverse of the intuitive reading** (proved by the measured constants,
   §4). Any per-arm backend table read off receipt names alone inverts.
7. **Five boundary receipts with `phase=`/`kind=` in their stems are
   unknown-arm rejections, not measurements** (`ERROR: r84b_edges: unknown arm
   --phase=phys`), while the real process-phase evidence sits in `d-phase`'s
   keyed sub-cell (`keyed_delta_pf=2`, with `first_delta_pf=0` and
   `decoy_delta_pf=0`).
8. **The child-re-exec parse is last-`CHILD_RESULT`-wins with a substring
   ERROR exemption, and its child log is a single mutable slot inside the
   project dir** — so per-rep child-log evidence is not recoverable from
   receipts, and the exemption is maskable by any ERROR line containing
   `Space state is inaccessible`.
9. **12 of 77 r84 streams are dirty under the tracked classify and 7 carry
   `RID()` tokens**; mid-flight or negative-control receipts must not be folded
   into CASES rows as-is.
10. **Hygiene is clean on the r84 receipt surface**: complete `.exit` coverage
    (bare convention), no future mtimes, no stdout-after-exit inversions, no
    ASLR-ish tokens in arm streams; the carried ASLR hits (4, `r82-boundary`
    `pid=`) and the `n_arm_lines` outlier are unchanged from r83.
11. **No sibling report has landed** (`reports/round-84/` empty through
    17:32:29Z), so no claim from any r84 seat is adopted here; the arm's two
    cells (`jolt_edge` child re-exec under Jolt; `phase_delta` as a first-class
    CASES row) have **no author receipt** at this bracket — the author had
    landed only two `project.godot` scaffolds (2 files, 0 runs).
12. **Sibling writers were live throughout** (scout 49→54 run groups, boundary
    7→32 between 17:30:1xZ and 17:32:2xZ, baseline 374→1703 files, author
    scaffold appearing) — every count here is a bracket.

## Gates

- Godot battery at HEAD: **140/140 receipts replay exactly** (0 case
  mismatches, 0 reason mismatches, 14,355 records) under the
  boundary-preserving join; 3 receipts carry the era-legitimate r77
  marker drift; tracked `CASES` = 186.
- bpy at HEAD: 169 landed streams parsed with the tracked `parse_arms`; current
  era 44 streams at (134, 131, 1, 3) + 49 foreign cells; 1 dead-probe stream.
- Frontier claim gate: 28/28 runs exit 0 ∧ stderr 0 bytes ∧ replicas
  byte-identical (re-verified by this seat's re-run).
- r84 receipt-hygiene gate: `.exit` present for every r84 run group; bare-exit
  convention throughout; no future mtimes; no mtime inversions.
- **Round claim gates (jolt_edge child re-exec under Jolt pinning; phase_delta
  delta=2 CASES row): unverifiable at this bracket** — no author receipt
  exists for either cell, no sibling report has landed, and `reports/round-84/`
  is empty. The per-arm backend partition and the process-phase delta readings
  exist only as sibling receipts (§4), which are data, not verdicts.
- No judgment, admission, or promotion is made by this seat.

## Conflicts / disagreements

- **No conflict between this seat's measurements and any landed sibling
  report** — no sibling report exists in `reports/round-84/` at 17:32:29Z.
- Recorded verbatim rather than silently corrected, in the landings I audited:
  - the scout's `jj_`/`pj_` prefix convention reads as the inverse of its
    measured backend (§4);
  - the boundary's `d---phase=phys` / `d---phase=proc` / `d---kind=*` / `d---`
    stems are unknown-arm rejections, not phase/kind cells (§4, finding 7);
  - `w_proj`/`w_proj_bogus` report `vinfo_keys=[]` while printing a
    `version=4.7.2-stable (arch_linux)` line — the two lines come from
    different version-info paths; recorded, not reconciled;
  - the r83 reviewer's pre-fold Jolt receipts read `static_nopair drift …
    delta=-3` while the post-fold r84 readings are `delta=1` — a
    receipt-visible consequence of the critic C2 `sig_log`-clear fold, not a
    contradiction.
- Open ledger-form items carried unresolved: the `n_arm_lines` semantics
  outlier (`r81-critic/runs/lax2`, 123 vs 122) and the bpy `stamp_matches`
  tool artifact noted at r83.

## Known limits

- Every count is a bracket: sibling writers were active through the whole
  window (17:30:18Z snapshot → final poll 17:32:29Z). Later landings will
  revise them.
- Battery receipts are normalized line arrays (`stdout.strip().splitlines()`);
  raw bytes, trailing whitespace, and byte-exact counts are outside what
  receipts support.
- The backend partition table is read from receipts of scripts not reviewed
  line-by-line by this seat (scout `run_arms.sh`, boundary `run_edges.sh`);
  only stream hygiene, quoted lines, and constants were audited. They are data,
  never verdicts.
- The `jj_`/`pj_` mapping is established from measured constants in three
  independent receipt families, not from the scouts' invocation record (the
  invocation is not itself receipted).
- The `d-phase` keyed sub-cell reading (`keyed_delta_pf=2`) is one receipt,
  one rep; no replica exists in this bracket.
- The child-re-exec parse description is a reading of the tracked fixture at
  HEAD (`1e042bcf…`) plus the scout's two backend receipts; no Jolt-pinned
  `jolt_edge` child receipt exists yet.
- Every claim is bounded to this host, Godot
  `4.7.2.stable.arch_linux.ed1daf0bf`, Python 3.14.7, and the fixtures at HEAD
  `c4b2fa2`. No cross-host or cross-build claim is offered.
- ASLR/token stability is evidenced by byte-identity across seats on one
  host/build; timing values are jitter and are used only as bounds.

## Touched surfaces

- Written (this seat's scope only): `reports/round-84/r84-scribe.md`;
  `corpus/live/r84-scribe/` — `scratch/` (9 carried tools, r83→r84 substitution
  lineage-verified), `runs/` (arrival snapshot, godot ledger, join hazard,
  hygiene, classifier scan ×3, landings ×4, rawview + summary, `.exit` rc files
  for each).
- Read-only: `corpus/fixtures/{run_battery.py,bpy_battery.py,bpy_sync_probe.py,phys3d_events.gd,project.godot}`
  (imported verbatim for `classify`/`parse_arms`/`CASES`), all r70–r84 receipts
  under `corpus/live/`, sibling r84 scratch/receipts (`r84-scout`, `r84-boundary`,
  `r84-baseline`, `r84-author` — data only), the wave registry/spec/tasks, the
  w14 closeout and w12 xconnector.
- Untouched: all tracked fixtures, `LOG.md`, `SCORECARD.md`, git state (no
  mutation; `git status --porcelain` empty before and after; HEAD `c4b2fa2`
  unchanged; no integrator commit observed).

## Out-of-scope items

- The author's r84 arm (`jolt_edge` child re-exec, `phase_delta` CASES rows,
  pins) — not implemented, not replayed, not judged; only the scaffold's two
  `project.godot` files exist.
- Sibling verdicts and claims (scout premise readings, boundary edge/negative
  claims, baseline zero-drift claim, critic/reviewer/simplifier/verifier, which
  are deferred post-commit in the registry) — their receipts are audited as
  landed data only.
- Any product-code edit, commit, push, publication, or sibling-seat dispatch.
- Audio (r76) and g2d (r75) lanes — other lanes' receipts were not swept
  except where they appear in the shared `corpus/live/runs/` receipt root.

## Artifact paths (sha256)

Scratch (carried, lineage-verified): `r84s_hygiene.py` `4c8b7c8c…`,
`r84s_godot_ledger.py` `d059f3d4…`, `r84s2_join_hazard.py` `0c3cc9e4…`,
`r84s_classifier_scan.py` `dc331f38…`, `r84s_landings.py` `96d425e3…`,
`r84s_rawview.py` `7345d340…`, `r84s_rawview_summary.py` `ee793c5e…`,
`r84s_frontier_audit.py` `b4467125…`, `r84s_snapshot.sh` `074c267f…`.
Runs: `godot_ledger.json` `df651fd1…`, `join_hazard.json` `e235551d…`,
`hygiene_r84.json` `1887835d…`, `classifier_scan.json` `a6595bc8…`,
`landings.json` `7f54d6e2…`, `rawview_all_bpy.json` `d5993f62…`,
`rawview_r84_scout.json` `ca3d163b…`, `arrival_snapshot.txt` `fc1528a6…`,
`classifier_scan.stdout.txt` `6723c441…`, `godot_ledger.stdout.txt`
`817958a5…`, `hygiene_r84.stdout.txt` `36c8436c…`, `join_hazard.stdout.txt`
`02d1a54e…`, `landings.stdout.txt` `41472078…`, `rawview_all_bpy.stdout.txt`
`d5993f62…`, `rawview.stdout.txt` `ca3d163b…`. Full 64-hex digests:
`sha256sum corpus/live/r84-scribe/scratch/* corpus/live/r84-scribe/runs/*`.

Final poll before this file was sealed: 17:32:29Z, HEAD `c4b2fa2`, clean tree,
`reports/round-84/` empty, no integrator commit. Post-write poll 17:33:15Z:
HEAD `c4b2fa2` unchanged, `git status --porcelain` = `?? reports/round-84/`
only, `reports/round-84/` = this file only (30,082 B), sibling file counts had
grown again (author 3, baseline 1715, boundary 139, scout 278) — the bracket
statement above stands and later landings revise the counts, not the HEAD or
report-landing state. This report's own sha256
(`f7361344b14f8e212e82faddfbdb0ee343561ff96bbec35677e797fd426f7e9d`, 480
lines, pre-seal) is recorded in the seat transcript
(`sha256sum reports/round-84/r84-scribe.md`).

Report only; I do not judge, admit, edit fixtures, commit, or ship. Stopping here.
