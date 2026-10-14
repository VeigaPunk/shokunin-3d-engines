# game-dev-3d round 83 — scribe report (recovery generation, seat `scribe`, host: devin)

Wave `shokunin-train-20261101-w14` (theme: consumer-class breadth + physics-server
interiors; arm g3d-r83 = Godot PhysicsServer3D two-tier lattice — generated events
bind at the physics tick vs edge-0 queries; `run_on_separate_thread` cell; Jolt
availability gate).

Declared lane axis (dispatch brief, verbatim): "r83 SCRIBE (g3d) — evidence ledger
+ parser/witness audit … Read SHARED.md + r83 author brief. Raw-stream vs
parsed-view audit, receipt hygiene, seat landings. Report -> reports/round-83/r83-scribe.md."

Recovery context (verbatim): "prior generation died ~16:10Z. An UNCOMMITTED prior
draft exists at reports/round-83/r83-scribe.md — never committed, so never filed:
read it, verify what still holds, supersede with your own report covering the
landed-state audit (author lands this wave — poll for integrator's commit after
HEAD f8a088c). Scratch: corpus/live/r83-scribe/ (r83s_* audit tools + runs/ JSON
outputs — verify before reuse)."

This seat does not implement the arm and does not judge. It re-measures the
raw-stream/parsed-view surface the arm's cells and pins will be read against,
re-sweeps receipt hygiene, and records seat landings at 16:29:40–16:31:15Z.
Wave registry (`~/Projects/shokunin/.ufo/waves/shokunin-train-20261101-w14/registry.json`)
names this seat `g3d-r83.scribe = a2962489` under `recovery_dispatch.at =
2026-10-14T16:20Z` (prior seat ids dead).

## Behavior (what this seat did)

1. Read `SHARED.md`, `tasks/g3d-author.md`, the wave registry/spec, and the
   uncommitted prior draft (476 lines, sha256
   `dbddb8c0186cf60b10ffa219682d524083b3c537323f10c2510d07869685dbf8`); copied it
   verbatim to `corpus/live/r83-scribe/prevgen-draft-r83-scribe.md` before
   superseding, so the dead generation's artifact stays auditable.
2. Archived the prior generation's 14 run receipts to
   `corpus/live/r83-scribe/runs/prevgen-1608Z/` and verified their sha256 values
   against the digests the draft cites (`arrival_snapshot.txt cc757c15…`,
   `godot_ledger.json b5c99cf8…`, `frontier_audit.json 2a9a00eb…`,
   `hygiene_r83.json 9491710d…`, `rawview_all_bpy.json 9836c5f2…`,
   `classifier_scan.json 822cbc9a…`, `landings.json 98e23755…`) — all identical.
3. Verified all 8 inherited scratch tools byte-identical to the draft's recorded
   shas before reuse (list in Artifact paths), then re-ran 7 of them on the
   current corpus and wrote one new tool (`r83s2_join_hazard.py`) so the
   line-join hazard is this generation's own measurement, not an inherited claim.
4. Swept landings + classifier scan three times to bracket the live write window
   (16:29:40Z snapshot archived to `runs/snap-1629Z/`, 16:31:0xZ archived to
   `runs/snap-1631Z/`, 16:32:5xZ canonical), because sibling seats were writing
   during the sweep.
5. Polled HEAD/report/author-scaffold state five times (16:29Z → 16:32:44Z) for
   the integrator's commit after `f8a088c`.
6. Caught the author's first run landing mid-window (`r83-author/runs/probe1.*`,
   mtime 16:32:36Z) and re-ran the classifier scan so the ledger covers it; the
   run is audited in §4.

## Commands and receipts (cwd repo root; all bounded)

| # | command | exit | receipt |
|---|---|---|---|
| 1 | `bash corpus/live/r83-scribe/scratch/r83s_snapshot.sh` | 0 | `runs/arrival_snapshot.txt` (+ `.exit`) |
| 2 | `timeout -s KILL 900 python3 …/scratch/r83s_godot_ledger.py` | 0 | `runs/godot_ledger.json` (107 receipts) |
| 3 | `timeout -s KILL 600 python3 …/scratch/r83s_hygiene.py` | 0 | `runs/hygiene_r83.json` |
| 4 | `timeout -s KILL 600 python3 …/scratch/r83s_landings.py` (×3: 16:29:40Z, 16:31:0xZ, 16:32:5xZ) | 0 | `runs/landings.json` + `runs/snap-1629Z/` + `runs/snap-1631Z/` |
| 5 | `timeout -s KILL 600 python3 …/scratch/r83s_classifier_scan.py` (×3) | 0 | `runs/classifier_scan.json` + `runs/snap-1629Z/` + `runs/snap-1631Z/` |
| 6 | `timeout -s KILL 300 python3 …/scratch/r83s_frontier_audit.py` | 0 | `runs/frontier_audit.json` (28 runs) |
| 7 | `timeout -s KILL 300 python3 …/scratch/r83s_rawview.py --roots corpus/live/r80-*…r83-* corpus/live/runs --json-out runs/rawview_all_bpy.json` | 0 | `runs/rawview_all_bpy.json` (164 streams) |
| 8 | `python3 …/scratch/r83s_rawview_summary.py` | 0 | `runs/rawview_summary.stdout.txt` |
| 9 | `timeout -s KILL 300 python3 …/scratch/r83s2_join_hazard.py` (new tool) | 0 | `runs/join_hazard.json` (107 receipts × 2 joins) |

Every run's rc is also stored beside the receipt (`runs/<name>.exit`, all `rc=0`).

## Landed state at measurement time (16:29:40–16:32:57Z)

- HEAD `f8a088c5ceb32552721100c59fb677de2eb1b6d7` (r82 report-last) at all five
  polls (16:29Z, 16:30Z, 16:31Z, 16:31:57Z, 16:32:44Z); `git status --porcelain`
  = `?? reports/round-83/` only; **no integrator commit after `f8a088c`** in the
  observed window; `reports/round-83/` contains only this seat's file (the prior
  draft, preserved to scratch).
- Fixtures at HEAD: `run_battery.py` sha256
  `22a1966dac431a5dddcd071b990911254ac572f1942dd1d374027529938c8bdb` (176 CASES),
  `bpy_battery.py` `045102a8514df96bda0c2268841ec0751de87f678f34cbdf981c3a7c6ff882ec`
  (83 CASES), `bpy_sync_probe.py`
  `07ec83e33512b6430b085dee9029163b41594b4e6e8608aab8b98d6c6c483a48`,
  `project.godot` `1fda90d46b0529aea0e75710a64f038cbf983adc8385285dd8bbe6202a8eac23`;
  53 fixture files (`.py/.gd/.godot` at `corpus/fixtures/` depth 1).
- Engines/toolchain (this host): `/usr/bin/godot` = `4.7.2.stable.arch_linux.ed1daf0bf`
  (2026-08-17); `/usr/bin/blender` = Blender 5.2.1 LTS; `python3` 3.14.7.
- **Author scaffold (prior generation's writes, 16:06:54–16:10:47Z; no runs, no
  report)** — `corpus/live/r83-author/`:
  `proj/project.godot` sha `1fda90d4…` (byte-identical to the tracked fixture seed),
  `proj/probe1.gd` `8a2a3b21cef3bdc66ce564872863a3f810a03178f064eafe4484bba90a182d31`,
  `proj/probe2.gd` `ac4988d1d270a33cd954df2023a099d4edd0e0e5176ca5bf2510e34cb61f20bb`,
  `proj/probe3.gd` `1f03359451b50db0b4ed3538502db67779127f441c4b67b6fbd192a0c0e52c0a`,
  `proj_threaded/project.godot`
  `df9a8da59b9d8d35388d45495e4ac0659442abcebc47d2344e7ba07f620e7b51`
  (`config/name="ThreadedPhysProbe"` + `physics/3d/run_on_separate_thread=true`;
  otherwise the same seed). `runs/` now holds the author's **first run**
  (`probe1.stdout.txt` sha `166cbd5c7cb25280c79e6c199ae7f519faf4bad4539e0fd4ffff50092880eb5b`,
  438 B; `probe1.stderr.txt` sha `1ba270c7effe9945053acd61f202fd4bd95efa9df1ee9c460285b2d152247251`,
  252 B; mtime 16:32:36Z; **no `.exit` file** → rc unobserved), audited in §4. The
  recovery author seat (`60c74320`, dispatched 16:20Z) was the writer; no author
  report exists.
- Sibling landings (files / run groups / battery receipts), 16:29:40Z → 16:31:0xZ → 16:32:5xZ:

| seat | files | runs | battery receipts (audited) | notes |
|---|---|---|---|---|
| author | 5 → 5 → 7 | 0 → 0 → 1 | — | scaffold + first probe1 run; no report |
| baseline | 1,754 → 1,754 → 1,755 | 1 | Godot PASS 176 (`runs/20261014T160506798300Z`) + bpy PASS 83 (`runs/bpy-20261014T160431295444Z`) | frozen-tree replay |
| boundary | 267 → 303 → 346 | 64 → 75 → 90 | Godot PASS 176 (`battery-runs/20261014T160748529914Z`) | exits {1,134,137}; stderr-nonzero 12 → 23; 6 named PID witnesses; new arms in flight |
| critic | 112 | 75 | — | all groups lack `.exit`; 2 stderr-nonzero |
| reviewer | 1,393 | 0 | Godot PASS 176 (`baseline-godot/20261014T160726979288Z`) | watch seat |
| scout | 277 → 462 → 570 | 88 → 146 → 183 | — | stderr-nonzero 1 → 23; 6 PID witnesses; Jolt project cells |
| simplifier | 153 | 0 | Godot PASS 176 (`baseline-runs/20261014T160221909855Z`) | YAGNI watch |
| verifier | 131 | 1 | bpy PASS 83 + Godot PASS 176 (`runs-baseline/{bpy,godot}/…`) | independent r83 replays |
| scribe | this seat | — | — | this report + `corpus/live/r83-scribe/` |

  **Writers were active throughout the sweep** (scout +95 run groups, boundary
  +26 between 16:29:40Z and 16:32:5xZ), so every count below is a bracket, not a
  terminal state. No sibling report had landed in `reports/round-83/`; sibling
  receipts are audited as *data* only.

## 1. Raw-stream vs parsed-view ledger

### 1a. Godot battery surface — 107 receipts, 12,354 case records, 0 reproduction failures

Tracked gate (verbatim `run_battery.py`): a case PASSes iff `exit == expected`
∧ an exact stdout line equals the marker (`:479`) ∧ every stderr line empty
(`:481-483`) ∧ no `SCRIPT ERROR:`/`Parse Error:` (`:485-488`) ∧ no line containing
`ERROR:` and no ObjectDB-leak line (`:489-493`). Receipts store
`stdout.strip().splitlines()` / `stderr.strip().splitlines()` (`:782`) — a
**normalized line array, not raw bytes**.

| era | receipts | cases | case mismatches (recorded vs recomputed) | tracked-CASES drift |
|---|---|---|---|---|
| r70–r78 seats + adj/integ + `corpus/live/runs` | 87 | 8,834 | 0 | 3 (r77-era, below) |
| r80–r82 seats | 15 | 2,640 | 0 | 0 |
| r83-era (simplifier, verifier, baseline, reviewer, boundary) | 5 | 880 | 0 | 0 |
| **total** | **107** | **12,354** | **0** | **3** |

- Three receipts are new since the prior generation (104 → 107, +528 cases):
  `r83-baseline/runs/20261014T160506798300Z`,
  `r83-reviewer/baseline-godot/20261014T160726979288Z`,
  `r83-boundary/battery-runs/20261014T160748529914Z` — each PASS 176/176,
  `seeds_unchanged: true`, 0 case mismatches, 0 tracked drift, 0 stderr-nonempty
  cases, `case_timeout_seconds: 20`, `only: null`.
- **Line taxonomy across all stored case streams**: `marker` 12,343, `blank`
  12,343, `ignored` 12,354, `error_trigger` 0, `leak_trigger` 0. The only ignored
  stdout line per case is the engine banner; the 11 cases without a marker belong
  to failing receipts.
- 18 receipts carry verdict FAIL (era-legitimate negative/broken runs); 14
  stderr-nonempty case records, all inside those FAIL receipts, reproduce their
  recorded reason lists exactly.
- **Tracked-CASES drift is era-legitimate**: the 3 r77-era receipts pin
  `navagent3d_detour_mut_force_link` with marker `steps=3 idxs=1,1,1` while the
  tracked CASES now pins `steps=2 idxs=1,1`.
- **Cross-receipt stdout identity**: 7 cases have more than one stdout sha across
  receipts (`navagent3d_detour_link_oneway_fwd`, `…_link_pop_bank`,
  `…_link_pop_void`, `…_mut_force_link`, `navagent3d_follow`,
  `navagent3d_retarget`, `navagent3d_retarget_fixed`); in every one the odd sha is
  the banner-only stdout of a FAIL run (marker absent, diagnostics on stderr). No
  unexplained nondeterminism.

### 1b. Receipt-consumer line-join hazard — re-demonstrated on all 107 receipts

`runs/join_hazard.json` (new tool, this generation): reconstructing the classifier
input from the stored line arrays with `"\n".join(lines)` **without the trailing
newline splices the last stdout line onto the first stderr line** and forges
reasons. Measured over 107 receipts: **naive join → 14 spurious case-reason
mismatches in 6 receipts; boundary-preserving join → 0**. The forged reason is
visible verbatim, e.g.

`unexpected diagnostic: Godot Engine v4.7.2.stable.arch_linux.ed1daf0bf (2026-08-17 01:18:38 UTC) - https://godotengine.orgERROR: Corrupted navigation mesh set on region. …`

The 6 affected receipts: r73-author `…T015242466681Z` (6 cases), r77-author
`…T111441223732Z`, r77-boundary `…T111927336306Z`, r77-critic `…T111826354707Z`
(1 case each), r78-critic `…T120458704455Z` (2), r78-scribe `…T120524364454Z` (3).
This is a consumer-side hazard of the receipt format, not a battery defect (the
tracked runner feeds raw text with a trailing newline).

### 1c. bpy surface — 164 streams (159 receipts + 5 non-receipt scratch), era shapes

Against the tracked `bpy_battery.parse_arms` (`bpy_battery.py:372`, `ARM_LINE`
`:355`, 83 CASES `:56`). This generation extended the inherited root set to
include the r83 seats (prior generation swept 162 streams without r83; now 164,
the 2 additions being the two r83 bpy receipts).

| era (stream shape) | receipts | raw ARM-prefixed | parsed cells | dropped (glued) | dup-key lines | foreign (unpinned) cells |
|---|---|---|---|---|---|---|
| r80-era (78-cell) | 12 | 78 | 78 | 0 | 0 | — |
| r80-era (112-cell) | 32 | 112 | 112 | 0 | 0 | — |
| r81/r82 pre-fold (122-cell) | 34 | 123 | 122 | 1 | 1 (`reorder\|dup\|FD1`) | 49 |
| **r82 post-fold / r83 HEAD (131-cell)** | **43** | **134** | **131** | **1** | **3** | **49** |
| sibling scratch variants | 43 | 0–136 (one launch-failure stream carries no ARM line) | — | 0–2 | 0–3 | — |

- The current-era shape now spans 43 receipts **including both r83 bpy receipts**
  (`r83-baseline/runs/bpy-20261014T160431295444Z`,
  `r83-verifier/runs-baseline/bpy/bpy-20261014T160330511843Z`): 139 raw lines,
  134 ARM-prefixed, 131 parsed cells, the glued `REORDERGLUE::ARM reorder | …`
  line dropped (not misattributed), 3 duplicate-key lines
  (`evalcat|closed|EDGE`, `reorder|dup|FD1`, `hazard|dup_flush|PARSE`) resolving
  physical last-wins.
- **49 of 131 parsed cells (37.4%) are not pinned by any CASES key** — injection
  into an unpinned cell remains invisible to the battery (r82 §2 A4, carried).
- **`n_arm_lines` semantics**: in 158 of 159 receipts
  `n_arm_lines == len(parse_arms(stdout))` (131) — not the raw ARM-prefixed count
  (134). One corpus receipt disagrees:
  `r81-critic/runs/lax2/bpy-20261014T145756399825Z` records 123 vs 122 parsed
  (= its raw ARM-prefixed count); a reader taking the field as "lines emitted"
  under-counts by 4 on the current stream.
- One `bpy-*` directory carries no `verdicts.json`
  (`r82-boundary/runs/detach-d2_s75/bpy-20261014T152429540415Z`, the aborted
  sibling of the `s75b` run) — 160 `bpy-*` dirs on disk vs 159 receipts.

### 1d. Frontier-physserver surface — 28 runs, all claims check out (2 nuances, re-measured)

Raw receipts `corpus/live/frontier-physserver/runs/<arm>[.r2].{stdout,stderr,exit}`:
14 arms × 2 reps = 28 runs; **all exit 0, all 28 stderr files 0 bytes, all reps
byte-identical** (re-measured this generation; `frontier_audit.json` is
byte-identical to the prior generation's, sha `2a9a00ebbe4f02…`). Wording drift:
`fb-physserver.md:15-16` says "all stderr banner-only"; measured: stderr is empty
in all 28 files and the banner is stdout line 1.
**vel_step arithmetic (raw)**: `x = 0.099833 / 0.1995 / 0.299001 / 0.398336` at
n1..n4 (the report quotes 0.0998/0.1995/0.2990/0.3983 — max rounding gap 3.6e-5);
per-tick increments `0.099833 / 0.099667 / 0.099501 / 0.099335` with ratios
`0.998337 / 0.998334 / 0.998332`, i.e. a constant ~0.998334/tick decay matching
`exp(-0.1/60) = 0.99833472` to ~2e-6. The sibling scout receipt measures
`INV ps physics/3d/default_linear_damp = 0.1` on this build
(`r83-scout/runs/inv.stdout.txt:41`), so the frontier's "factor ~0.9983
unexplained — damp or integrator detail" is *consistent with the default linear
damping* (inference; the engine-internal damping form is not measured here). The
report's factor is the increment-decay ratio, not a position factor.

## 2. Receipt hygiene (paths / stamps / identity / ASLR)

All checks in `runs/hygiene_r83.json` (byte-identical to the prior generation's
sweep, sha `9491710dad7c96…` — deterministic over an unchanged corpus).

- **Stamps (H1)**: 159/159 bpy receipt dir stamps == `verdicts.started_utc`; all
  `probe.stdout.txt` mtimes ≤ `verdicts.json` mtimes; 2/2 legacy Godot receipt
  stamps match; frontier run triples ordered stdout ≤ exit.
- **Determinism / ASLR stability (H2)**: 45 distinct stdout shas over 159 bpy
  receipts. The largest shared group `6a98c570dbae…` now holds **23 receipts
  spanning r82→r83** (r82-author/baseline/reviewer/simplifier/verifier, r83-baseline,
  r83-verifier, `runs`) and resolves to **7 distinct payloads modulo
  `{probe_elapsed_s, started_utc}`**, each difference labeled by field diff:
  5 scratch probe-path variants (`corpus/live/r82-simplifier/scratch/{bat_M1,bat_M2,bat_M3,landing_AB}/bpy_sync_probe.py`,
  `corpus/live/r83-baseline/frozen-extract/corpus/fixtures/bpy_sync_probe.py`),
  the tracked-fixture path, and one mutant timing witness
  (`hazard_detail.eof_hold_wall_s = 3.004` vs `3.003`). No unexplained
  within-group difference. Also labeled across the corpus: one mutant receipt with
  byte-identical stdout but `probe_error = TIMEOUT after 60 seconds`,
  `probe_exit = None`, `verdict = FAIL` (stdout sha alone is not a verdict), and
  one receipt with 162 stderr bytes (`r81-critic/runs/lax/…`).
- **ASLR-ish tokens (H3)**: 0 hex-address hits and 0 `/tmp/` hits in probe
  stdout; 4 PID-token hits, all deliberate named witnesses
  (`ARM detach | spawn | FD1 | pid=…` at line 125 of the four r82-boundary
  `detach-d*` receipts). Scope note: this scan covers probe stdout of receipts;
  the boundary Jolt crash receipts' stderr carries engine crash backtraces (34
  address lines) — a crash artifact, not a verdict stream.
- **Paths (H4)**: all `probe` fields absolute (31 distinct values corpus-wide);
  frozen-extract receipts still produce the identical stdout sha.
- **Godot seed digests**: the two legacy receipts differ from HEAD fixtures in
  exactly 4 files (04:42Z) and 2 files (14:03Z), all changed by later rounds —
  era-legitimate, no unexplained drift.
- **Exit conventions (new census this generation)**: 298 run groups at 16:31Z
  (351 at 16:32:5xZ); **87 (105) carry no `.exit` file at all** (critic 75/75,
  scout `bid_eng_*/bid_proj*/thr_proj*` and `bid2_*`/`thr2_*`, boundary kill
  groups whose semantics live in `.report.txt`, baseline/verifier 2 bpy `probe`
  groups whose exit is recorded as `probe_exit` inside `verdicts.json`, and the
  author's `probe1`); 0 empty `.exit` files. `rc` is therefore unobserved for the
  critic's whole r83 sweep — and rc alone is never a verdict anyway.
- **Tool artifact, recorded so it is not misread**: `r83s_landings.py` compares
  receipt dir name == `started_utc`, so bpy receipt dirs (prefixed `bpy-`) always
  report `stamp_matches: false`; hygiene scope A measured all 159 bpy stamps
  matching with the prefix stripped. No drift.

## 3. Tracked-classifier hazard scan on landed r83 streams (342 streams at 16:32:5xZ; 298 at 16:31Z; 229 at 16:29:40Z)

`runs/classifier_scan.json` (+ `runs/snap-1629Z/`, `runs/snap-1631Z/` for the
earlier brackets). **39 of 342 landed r83 sibling streams are "dirty"** under the
tracked classifier — folding any of them into CASES as-is would FAIL on the
strict predicates (`run_battery.py:481-493`). Classes and readings (the
bracket-to-bracket growth 9 → 32 → 39 dirty streams is itself the finding: dirty
streams are landing faster than they can be adjudicated):

| stream(s) | trigger | reading |
|---|---|---|
| author `probe1` | stderr + SCRIPT ERROR `Nonexistent function 'get_server_count (via call)' … at: _run (res://probe1.gd:26)`; no `.exit` | the author's own gate probe dies on the manager API surface (§4) |
| boundary `dummy-sleep` | stderr + SCRIPT ERROR (`Nil` → `Transform3D` at `r83b_edges.gd:105`) | probe defect in flight |
| boundary `fps_zero`, `fps_negative`, `rep2-fps_zero`, `rep2-fps_negative` | stderr + `ERROR: Engine iterations per second must be greater than 0.` | intentional negative controls |
| boundary `jolt-multi_space`, `jolt-space_free_order`, `jolt-world3d_free`, `jolt-space_off.crash-forward-cleanup`, `jolt-multi_space.crash-forward-cleanup`, `jolt-space_precond_nodss`, `jolt-jf_space_then_body`, `jolt-jf_world3d_drop` | stderr `handle_crash: Program crashed with signal 11` / crash block; exit **134** (or 137) | Jolt-selected runs crash (SIGSEGV → abort) |
| boundary `jolt-jf_double_free` | `ERROR: Failed to free RID: The specified RID has no owner.` | Jolt free-order arm, named negative witness |
| boundary `thread-inventory`, `thread-dss_stress`, `thread-dss_hole` | stderr + `ERROR: Space state is inaccessible right now, wait for iteration or physics process notification.` | `run_on_separate_thread=true` process-context DSS access |
| boundary `space_precond_querydss_after` | `ERROR: Parameter "space" is null.` | DSS-precondition arm |
| boundary `thread-space_precond` | SCRIPT ERROR `Invalid type in function '_hit' in base 'SceneTree (r83b_edges2.gd)'` | probe defect in flight |
| boundary `dss_hole`, `gen_edges`, `gen_edges_space`, `gen_edges_pp`, `jf_body_then_space`, `jf_double_free`, `jf_shape_free_order`, `jf_space_then_body`, `jf_world3d_drop`, `neg_controls`, `space_precond` | stderr + `ERROR: r83b_edges: unknown arm …` (`r83b_edges.gd:577`); exit **1** | arms landed before the probe revision supports them — mid-flight, not claim evidence |
| scout `proj_jolt_`, `proj_jolt_.r2`, `proj_jolt_st_`, `proj_jolt_st_.r2`, `proj_jolt_sync_cb`, `proj_jolt_sync_cb.r2` | stderr `Failed to call {force integration,state synchronization} callback … Method expected N argument(s), but called with 1` at `modules/jolt_physics/objects/jolt_body_3d.cpp:1085/1098`; exit 0 | Jolt backend enforces callback arity; Godot-side cells may not transfer verbatim |
| scout `proj_e1`, `proj_jolt_e1` | `ERROR: Parameter "body->get_space()" is null.` / `Parameter "space" is null.` | engine-side null-parameter witnesses |
| scout `proj_t_contact_pp[.r2]`, `proj_t_query_pp[.r2]` | `ERROR: Parameter "shape" is null.` | same class |
| scout `wrap_proj`, `wrap_proj_st` | `ERROR: Class 'GodotPhysicsServer3D' isn't exposed.` | backend-class exposure (arm-relevant raw data) |
| critic `authp2.contact_sig` | ObjectDB leak warning (3 instances) | probe leak |
| critic `probe1_replay` | stderr + SCRIPT ERROR `Nonexistent function 'get_server_count (via call)' …` | see §4 |
| scout `inv` | ObjectDB leak warning (1 instance) | probe leak |

- **32 of 342 streams carry process-local `RID()` tokens** (boundary
  `inventory`/`multi_space`/`jolt-*`/`sleep`/`omit`/`motion_edges`/`server_off`/
  `space_off`/`world3d_free`/`cross_space_free` and their `rep2-*` variants,
  `thread-inventory`, `thread-sleep`). RIDs differ across receipts for the same
  body role and no tracked CASES marker embeds one (no battery receipt's stored
  stdout contains `RID(`). **Any new r83 CASES marker embedding a RID would be
  nondeterministic under the exact-marker gate.**
- Additional nondeterministic-token class observed this generation: the critic's
  `probe1_replay` and the author's `probe1` both print a process-local object
  handle `<PhysicsServer3DManager#3103785120>` — the same hazard as `RID()`, for
  any marker that would print a singleton/object.
- No stream in the scan carries `Parse Error:`.

## 4. Author arm — landed scaffold, first run, and the critic's replay witness

- The landed author scaffold (shas in "Landed state") contains the arm's
  pre-measurement probes: `probe1.gd` (backend gate + `PhysicsServer3DManager`
  API surface), `probe2.gd` (two-tier arms — query tier `intersect_shape`/
  `cast_motion`/`body_test_motion` mid-frame same-turn vs event tier
  `Area3D.body_entered`/state-sync/`contact_count`, e.g. the `cc w0_sameturn`
  arm), `probe3.gd` (contact-signal timing detail, `move_out w0`), and the
  `proj_threaded/project.godot` overlay for the separate-thread cell.
- **First run landed at 16:32:36Z** (`r83-author/runs/probe1.{stdout,stderr}.txt`,
  shas in "Landed state"; **no `.exit` → rc unobserved**). stdout verbatim (438 B):
  banner; `godot 4.7.2-stable (arch_linux)`; `physics_engine setting = DEFAULT`;
  `has physics_engine = true`; `run_on_separate_thread = false`;
  `has run_on_separate_thread = true`; `class JoltPhysicsServer3D = false`;
  `class PhysicsServer3DManager = true`; `PSM method: register_server`;
  `PSM method: set_default_server`; `PSM singleton = <PhysicsServer3DManager#3103785120>`.
  stderr (252 B): `SCRIPT ERROR: Invalid call. Nonexistent function
  'get_server_count (via call)' in base 'PhysicsServer3DManager'. at: _run
  (res://probe1.gd:26)` + GDScript backtrace.
  Reading (observed on this build, bounded to this receipt): the DEFAULT-backend
  gate line the arm needs (`class JoltPhysicsServer3D = false`) *is* measured,
  but the probe dies at `probe1.gd:26` before its `singletons with 'hysics'`
  enumeration; the manager's exposed method list here is exactly
  {`register_server`, `set_default_server`} — `get_server_count`/`get_server_id`/
  `get_server_name` are absent, so probe1's server-enumeration path cannot
  produce evidence on this build. The stream is dirty under the tracked
  classifier (§3) and must not be folded into CASES as-is.
- The critic's replay (`r83-critic/proj/probe1_replay.gd` sha `d41faac4…`; run
  group `r83-critic/runs/probe1_replay.{stdout,stderr}.txt`, **no `.exit`**)
  predicted exactly this: `P1R class PhysicsServer3DManager = true`,
  `P1R singleton = <PhysicsServer3DManager#3103785120>`,
  `P1R has get_server_count = false`, then the same SCRIPT ERROR at
  `probe1_replay.gd:18`. The identical singleton handle appears in both
  independent processes — observed equal here, still a process-local token class
  for marker purposes.
- `proj/project.godot` is byte-identical to the tracked fixture seed
  (`1fda90d4…`); the threaded overlay differs only by `config/name` and
  `physics/3d/run_on_separate_thread=true`. `probe2`/`probe3` remain unrun: no
  stream exists yet for any two-tier cell or for the separate-thread cell, so
  both round claim gates remain unverifiable by this seat.

## Findings

1. **The Godot battery's stored line arrays reproduce the recorded verdict and
   reason list exactly for 107/107 receipts (12,354 case records) — but only if
   the stdout→stderr line boundary is preserved.** Re-demonstrated this
   generation: naive `"\n".join(lines)` forges 14 reasons across 6 receipts;
   boundary-preserving join gives 0 (`runs/join_hazard.json`). Consumer-side
   hazard of the receipt format, not a battery defect.
2. **Receipt storage is a normalized view**: `stdout.strip().splitlines()`
   (`run_battery.py:782`) drops trailing whitespace/blank tails; a case's raw
   stdout bytes are not preserved. Pins depending on trailing whitespace or exact
   byte counts must not be read off receipts.
3. **Five independent r83 seats' battery receipts agree**: simplifier (16:02:22),
   verifier (16:03:31), baseline (16:05:07), reviewer (16:07:27), boundary
   (16:07:49) — each PASS 176/176 with `seeds_unchanged: true`, 0 case
   mismatches, 0 tracked-CASES drift; plus bpy PASS 83/83 from two independent
   r83 seats (baseline, verifier) on the byte-identical stdout sha
   `6a98c570dbae…`. Zero-drift evidence at r83 HEAD, bounded to this host/build.
4. **The current-era bpy stream shape (134 raw ARM-prefixed / 131 parsed / 1
   glued dropped / 3 dup keys / 49 foreign cells) now spans 43 receipts including
   both r83 bpy receipts**; 49/131 cells remain unpinned (the r82-pinned forge
   surface persists), and the `n_arm_lines` semantics outlier (r81-critic lax2,
   123 vs 122) persists.
5. **The tracked gate's ignored surface is exactly the banner line** in all
   12,354 stored case streams (`marker` 12,343 = cases with a marker; the 11
   without are FAIL runs); `ERROR:`/leak/`SCRIPT ERROR`/`Parse Error:` triggers
   never fire in stored PASS streams. **39 of 342 landed r83 streams would FAIL
   it as-is** (§3), including the author's own `probe1` stream — mid-flight
   receipts must not be folded.
6. **`RID()` tokens appear in 32 landed streams and an object handle
   (`<PhysicsServer3DManager#3103785120>`) in two more** — neither can appear in
   an exact-marker CASES row; no tracked marker does.
7. **Hygiene is clean on stamps, mtimes, paths, and ASLR tokens**; all payload
   differences within byte-identity groups are labeled (probe path, battery
   revision, mutant verdict, `eof_hold_wall_s` timing). **Run groups without any
   `.exit` file grew 87 → 105 across the two full brackets** (351 run groups at
   16:32:5xZ; critic 75/75, scout 19 `bid*_*`/`thr*_*`, boundary 8, the author's
   `probe1`, and the two bpy `probe` groups whose exit lives inside
   `verdicts.json`), so rc is unobserved for those — no verdict may be read from
   a missing rc.
8. **The frontier's 28-run claim set verifies again** (exit 0, stderr 0 bytes,
   rep byte-identity; audit JSON byte-identical to the prior generation); two
   wording/arithmetic nuances stand: "stderr banner-only" should read "stderr
   empty, banner on stdout", and vel_step's "factor ~0.9983" is the
   increment-decay ratio matching `exp(-0.1/60)` with the measured default linear
   damp 0.1 (inference).
9. **The author's `PhysicsServer3DManager` API assumption is falsified on this
   build — now observed on the author's own probe1 run, not only the critic's
   replay**: `get_server_count` is absent (exposed methods: `register_server`,
   `set_default_server`), and `probe1.gd:26` raises SCRIPT ERROR, so the probe
   dies before its singleton enumeration (bounded: stdout/stderr only, no `.exit`).
10. **The r83 author's arm is only one run deep** (probe1 landed 16:32:36Z;
    `probe2`/`probe3` unrun; no author report). No claim is offered for the
    two-tier lattice, the separate-thread cell, or the Jolt gate; §1/§3 define
    the surface its cells and pins will be read against.
11. **Sibling writers were live throughout the sweep** (scout +95 run groups,
    boundary +26 between 16:29:40Z and 16:32:5xZ; the author's probe1 landed
    mid-window at 16:32:36Z) — all counts are a bracket.

## Gates

- bpy battery at r83 HEAD: PASS 83/83, two independent r83 seats, stdout sha
  `6a98c570dbae…` (reproduced from receipts by this seat's hygiene/rawview
  sweeps). Godot battery at r83 HEAD: PASS 176/176 from five independent r83
  seats (audited in §1a, 0 case mismatches).
- Frontier claim gate: 28/28 runs exit 0 ∧ stderr 0 bytes ∧ reps byte-identical
  (this seat's re-run).
- Round claim gates (two-tier lattice / separate-thread cell / Jolt availability
  gate): **unverifiable at measurement time** — the author arm is one probe run
  deep (no probe2/probe3 streams, no author report); sibling receipts exist for
  discriminating cells but no sibling report has landed, so nothing is adopted.
- No judgment, admission, or promotion is made by this seat.

## Conflicts / disagreements

- **No conflict** between this seat's measurements and any landed sibling report
  (none landed; `reports/round-83/` held only this seat's file at 16:32:44Z).
- Recorded verbatim rather than silently corrected: `fb-physserver.md:15-16`
  "all stderr banner-only" vs measured 28/28 stderr files 0 bytes (banner is
  stdout line 1); `fb-physserver.md:38` rounded x values and the "factor ~0.9983"
  phrasing vs the raw values and the increment-decay reading (§1d).
- Two ledger-form items stay open: the `n_arm_lines` field semantics outlier and
  the bpy `stamp_matches` tool artifact (§2) — both stated, neither reconciled.
- The prior draft's 6-receipt line-join mismatches are recorded as *that
  generation's* first-pass artifact; this generation reproduces the mechanism
  (14 forged reasons) with the corrected ledger at 0 (§1b).

## Known limits

- Every count is a bracket: sibling writers were active throughout the sweep
  (16:29:40Z → `runs/snap-1629Z/`, 16:31:0xZ → `runs/snap-1631Z/`, canonical
  receipts at 16:32:5xZ). Later landings will revise them.
- Receipts are normalized line arrays (no raw bytes); whitespace-tail and
  byte-exact claims are outside what receipts support.
- The Godot ledger re-classifies era receipts with the *current* tracked
  classifier; era-legitimate differences (marker drift, battery revisions) are
  reported, not reconciled.
- The author's arm is one probe run deep: `probe2`/`probe3` have no streams, and
  `probe1`'s stdout/stderr carry no `.exit`, so the `get_server_count` finding is
  bounded to the two observed streams (author's probe1 + critic's replay) with rc
  unobserved.
- Sibling raw observations (Jolt crashes, thread-cell errors, generated-event
  cells) are receipts of probes whose scripts were not reviewed line-by-line;
  only stream hygiene and quoted lines were audited. They are data, never
  verdicts.
- ASLR stability is evidenced by byte-identity across seats on one host/build;
  no cross-host or cross-build claim. Timing values are jitter and are used only
  as bounds.
- No future mtimes were observed (0 files newer than the poll clock; one
  verifier scratch tree carries preserved 2026-10-13 stamps from its frozen
  source — a sorting artifact of time-of-day strings, not drift).

## Touched surfaces

- Written (this seat's scope only): `reports/round-83/r83-scribe.md`;
  `corpus/live/r83-scribe/` — `scratch/` (9 tools: the 8 inherited +
  `r83s2_join_hazard.py`), `runs/` (arrival snapshot, godot ledger, hygiene,
  landings, classifier scan, frontier audit, rawview + summary, join hazard,
  `.exit` rc files), `runs/prevgen-1608Z/` (14 archived prior-generation
  receipts), `runs/snap-1629Z/` (2 bracketing receipts), `runs/snap-1631Z/`
  (2 bracketing receipts), `prevgen-draft-r83-scribe.md` (preserved superseded
  draft).
- Read-only: `corpus/fixtures/{run_battery.py,bpy_battery.py,bpy_sync_probe.py,project.godot}`
  (imported verbatim for `classify`/`parse_arms`/CASES), r70–r83 receipts under
  `corpus/live/`, `reports/frontier/fb-physserver.md`, the wave registry/tasks,
  sibling r83 scratch (data).
- Untouched: all tracked fixtures, `LOG.md`, `SCORECARD.md`, git state (no
  mutations; `git status --porcelain` = `?? reports/round-83/` before and after;
  HEAD `f8a088c` unchanged; no integrator commit observed).

## Out-of-scope items

- The author's r83 arm (probe family, CASES rows, pins) — only `probe1`'s raw
  stdout/stderr audited; not implemented, not replayed, not judged here.
- Sibling verdicts (critic falsification, boundary edge claims, verifier
  AGREE/DISAGREE, reviewer/adjudicator) — their receipts are audited as landed
  data only.
- Any product-code edit, commit, push, publication, or sibling-seat dispatch.
- Cross-build tolerance: every claim is bounded to Godot
  `4.7.2.stable.arch_linux.ed1daf0bf`, Blender 5.2.1 LTS, Python 3.14.7, this
  host.

## Artifact paths (sha256)

Scratch (inherited, verified unchanged): `r83s_godot_ledger.py` `aeef4973…`,
`r83s_frontier_audit.py` `a8a11462…`, `r83s_hygiene.py` `7fd0312c…`,
`r83s_rawview.py` `bfc5259f…`, `r83s_rawview_summary.py` `f9d28a54…`,
`r83s_classifier_scan.py` `0367d11f…`, `r83s_landings.py` `9bf31a28…`,
`r83s_snapshot.sh` `f0481ec5…`; new: `r83s2_join_hazard.py` `6b0be4c8…`.
Runs (this generation): `godot_ledger.json` `dfb25416…`, `hygiene_r83.json`
`9491710d…`, `frontier_audit.json` `2a9a00eb…`, `rawview_all_bpy.json`
`814d9f83…`, `join_hazard.json` `2485af25…`, `arrival_snapshot.txt` `5b74454c…`,
`rawview_summary.stdout.txt` `3c3f335a…`; final-bracket `landings.json`
`3f154a3c…`, `classifier_scan.json` `e334da87…`; `runs/snap-1629Z/landings.json`
`f0694a67…`, `runs/snap-1629Z/classifier_scan.json` `77d0aa40…`;
`runs/snap-1631Z/landings.json` `0a77f5a5…`, `runs/snap-1631Z/classifier_scan.json`
`6c6374b8…`; `prevgen-draft-r83-scribe.md` `dbddb8c0…`. Full 64-hex digests:
`sha256sum corpus/live/r83-scribe/scratch/* corpus/live/r83-scribe/runs/*`.

Final poll before this file was sealed: 16:32:44Z, HEAD `f8a088c`, no integrator
commit, `reports/round-83/` = this file only. This report's own sha256 is
recorded in the seat transcript (`sha256sum reports/round-83/r83-scribe.md`).

Report only; I do not judge, admit, edit fixtures, commit, or ship. Stopping here.
