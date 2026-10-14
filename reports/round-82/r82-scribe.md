# game-dev-3d round 82 — scribe report (seat: scribe, host: devin)

Declared lane axis (dispatch brief, verbatim): "r82 SCRIBE (g3d) — evidence
ledger + parser/witness audit … Own the evidentiary layer: watch the probe's
raw stream vs the battery's parsed view — find lines the parser drops,
misattributes, or would forge-accept. Catalog the hazard surface honestly
(survival != safety). Cross-check receipt hygiene (paths/timestamps/ASLR
stability). Track seat landings and flag report-vs-receipt drift."

Scribe duty this round (wave `shokunin-train-20261101-w13`, theme: topology
depth + demuxer-breadth + parser-hazard pinning, xconnector X2/X4/X1/X6/X7):
the r82 author brief declares ARM A (evalcat residual fold, X7) and ARM B
(parser-hazard pinned cells, X6: forged `violations=0`, dup_flush forged
logical-last, binjunk non-UTF-8, detach-child EOF-hold). This seat does not
implement either arm; it independently measures the raw-stream/parsed-view
surface those pins will be written against, audits the receipts already on
disk, and records drift.

Report-only; not the judge. Leaf: no subagents, no git mutations; the only
tracked write is this report (`corpus/live/` is gitignored, `corpus/.gitignore:1`).

## Behavior (what this seat did)

1. Snapshotted HEAD, fixture hashes, the tracked CASES census, and the full
   receipt inventory (r80–r82 seats) without rerunning any product work.
2. Built `scratch/r82s_rawview.py`: a raw-line vs parsed-cell auditor that
   imports the TRACKED parser verbatim (`bpy_battery.parse_arms`,
   `bpy_battery.py:278-287`) plus the tracked `done_marker`/`fatals`
   predicates, and classifies every raw line (cell / ARM-prefixed-but-dropped
   / other) with duplicate-key overwrite tracking. Ran it over 7 r81 receipts
   and 8 r82 receipts.
3. Built `scratch/r82s_hazards.py`: the brief's ARM-B residual hazards as
   cells (A forged `violations=0` before/after the real row; B dup tie-break;
   C binjunk non-UTF-8; D detach) driven through the TRACKED `run_process`
   (`bpy_battery.py:264-275`) and the tracked case loop, with a part-0
   self-check that re-implements the tracked case model and must reproduce
   `verdicts.json` (74/74) before any mutation is judged.
4. Built `scratch/r82s_forge_live.py`: two LIVE cells under `blender -b -P`
   (E1 logical-last vs physical-last tie-break; E2 forge-accept with a real
   `violations=3` row), captured through the tracked `run_process`.
5. Sharpened the detach hazard: `scratch/r82s_detach.py` (2 topologies + raw
   `communicate()` control, grandchild liveness at return, no strays) and
   `scratch/r82s_latebytes.py` (bytes written after the capture returned).
   All bounded with `timeout -s KILL` per SHARED guard.
6. Receipt hygiene sweep: `scratch/r82s_hygiene.py` over all 31 tracked
   battery receipts (run-dir stamp vs `started_utc`, mtime ordering,
   byte-identity groups, payload identity modulo wall-time, ASLR-ish token
   scan, path hygiene) plus report-vs-receipt drift checks on r81 claims.
7. Seat-landing watch over `corpus/live/r82-*/`, `reports/round-82/`, HEAD.

## Landed state at measurement time (12:19–12:26 UTC-03, 15:19–15:26 UTC)

- HEAD `31cf56a6321cb406c181f190e3008fe7ce5dcf96` (r81 report-last); working
  tree clean (`git status --porcelain` empty). Fixtures:
  `corpus/fixtures/bpy_sync_probe.py` sha256
  `a4b1f94bff08af47c63b86df0fac3f9fa0e481ad5aa6d48aa81947d342a52023`
  (1262 lines),
  `corpus/fixtures/bpy_battery.py` sha256
  `111568eec55fe1e489cc8ec6d41b8c2934611466537749d0dace68601fb44e4e`
  (409 lines, 74 CASES, 33 evalcat rows, 14 bare `invoked=none` pins),
  `corpus/fixtures/run_battery.py` sha256
  `22a1966dac431a5dddcd071b990911254ac572f1942dd1d374027529938c8bdb`
  (untouched). These three hashes are identical to the r82-boundary arrival
  manifest (`corpus/live/r82-boundary/env_manifest.txt:4-6`) — independent
  cross-seat agreement.
- **The r82 author's diff had NOT landed** at measurement time: no
  `corpus/live/r82-author/`, no `reports/round-82/` file, no fixture hash
  change.
- Sibling scratch observed in flight (data, not relied on): `r82-baseline`
  (1 receipt), `r82-boundary` (harness + env cells + 2 battery receipts),
  `r82-critic` (p1 fold-candidate probes, p1b batch-instance crash, p2 forged
  probe, 1 prebaseline receipt), `r82-reviewer` (1 baseline receipt),
  `r82-scout` (empty dir), `r82-simplifier` (watch + arrival shas + 1
  baseline receipt), `r82-verifier` (1 receipt).
- Toolchain: `/usr/bin/blender` = Blender 5.2.1 LTS (hash `9e2066aef7ef`,
  built 2026-09-01); `python3` = 3.14.7; `io.DEFAULT_BUFFER_SIZE` = 131072
  (this build's constant, not a measured boundary).

## Commands and receipts

| # | command (cwd repo root; all bounded) | exit | receipt |
|---|---|---|---|
| 1 | `python3 corpus/live/r82-scribe/scratch/r82s_rawview.py --roots corpus/live/r81-{author,verifier,baseline} --json-out …/runs/rawview-r81.json` | 0 | `runs/rawview-r81.json` (7 receipts) |
| 2 | same, `--roots corpus/live/r82-{baseline,boundary,critic,reviewer,simplifier,verifier} --json-out …/runs/rawview-r82.json` | 0 | `runs/rawview-r82.json` (8 receipts) |
| 3 | `timeout -s KILL 120 python3 …/scratch/r82s_hazards.py` | 0 | `runs/hazards/hazard_cells.json` + 7 stdout cells + `runs/hazards.stdout.txt` |
| 4 | `timeout -s KILL 90 python3 …/scratch/r82s_forge_live.py` | 0 | `runs/forge-live/forge_live.json` + `e1_tiebreak.*` + `e2_forge.*` |
| 5 | `timeout -s KILL 90 python3 …/scratch/r82s_detach.py` | 0 | `runs/detach/detach_cells.json` + 2 holder scripts + pidfiles |
| 6 | `timeout -s KILL 60 python3 …/scratch/r82s_latebytes.py` | 0 | `runs/latebytes/latebytes_cell.json` + `grandchild_report.json` |
| 7 | `timeout -s KILL 60 python3 …/scratch/r82s_eofhold_raw.py` (raw `communicate()` control) | 0 | `runs/eofhold_raw.stdout.txt` |
| 8 | `timeout -s KILL 120 python3 …/scratch/r82s_hygiene.py` | 0 | `runs/hygiene.json` |
| 9 | `python3 …/scratch/r82s_rawview.py corpus/live/r82-critic/runs/p2-{post_flush,detach}-*/probe.stdout.txt --json-out …/runs/rawview-r82-critic-forged.json` | 0 | `runs/rawview-r82-critic-forged.json` (§5 sibling-receipt audit) |

Scratch hashes: `r82s_rawview.py` `62694a2c05733d865244f42f2d3da9a7b13c30742a9449e29fcd510bd0c7e78b`,
`r82s_hazards.py` `59d61ba8188a5931d7618c267b95c5e2fa2d1833a5c8d61f32c4bd1dd0f3a107`,
`r82s_forge_live.py` `ff89864caa3200b1d134970ab1ec8ef75442990c5d96be03d1b3f1161aa43a44`,
`r82s_hygiene.py` `59fc16cbf31911408593c52aaf1ac97d741c400ace9c9cb28a86bfdfafb0e51b`,
`r82s_detach.py`, `r82s_latebytes.py`, `r82s_eofhold_raw.py` (hashes in
`runs/` receipts of this seat's own `sha256sum`, re-derivable). JSON receipts:
`hazard_cells.json` `01f61922f33797bafb1f2be458c9e344c89e03babd747b98bba2578d5817cda4`,
`forge_live.json` `58df11576f12d893b939a7e5590ff2f051a2e999d845198a027b58bb9d9ea109`,
`hygiene.json` `fc19fd036fd45b729ae1741f828e711e63cf4acac56005bf8109518df034db41`,
`rawview-r81.json` `8e4ac271dfcba189154e5dafc8c8b050b580f19d83e2f55ef7e9e6b6a036f3aa`,
`rawview-r82.json` `004d695185ddd8b7e4b71668fd3fbf66b5b70e12789c23dd2e4093e9d659b6c0`,
`rawview-r82-critic-forged.json` `04bf416087b3bf3d919db4ac8fd1ebc9dd2c70d666f2adc3407011f1fc23b6f3`,
`eofhold_raw.stdout.txt` `dcab7205048d04d203d2e33a463a959f2397d9a136c1cedb12b8a5aeeafc50f2`.

No product file, tracked fixture, LOG.md or SCORECARD.md was modified by this
seat; every capture above is scratch.

## 1. Raw-stream vs parsed-view ledger

The tracked parser is line-anchored and order-insensitive for distinct keys:
`ARM_LINE = ^ARM (\S+) \| (\S+) \| (\S+) \| (.*)$` (`bpy_battery.py:261`),
dict assignment `arms[(arm, point, layer)] = kv` (`:286`) → **physical
last-wins per cell**; non-matching lines are silently skipped (`:282-283`).

| receipt (seat) | raw lines | ARM-prefixed | parsed cells | dropped | dup overwrite | done | verdict |
|---|---|---|---|---|---|---|---|
| r81-author `…T145803952150Z` | 128 | 123 | 122 | 1 (line 121, glued) | `reorder\|dup\|FD1` (line 123 wins) | True | PASS 74/74 |
| r81-verifier `…T150635802704Z`, `…T150706154984Z` | 128 | 123 | 122 | 1 | same | True | PASS 74/74 |
| r81 pre-landing (`…T145213656637Z`, fb336ae5 group ×9 receipts) | 116 | 112 | 112 | 0 | — | True | PASS 64/64 |
| r82 six-seat baselines (sha `947ad72643d2` ×6) | 128 | 123 | 122 | 1 (line 121) | `reorder\|dup\|FD1` (line 123) | True | PASS 74/74 |
| r82-boundary `envcollapse` (sha `72ca016403c9`) | 128 | 123 | **123** | 1 (line **124**, the parent's `dup` row, glued) | **none** | True | **FAIL** (2 cases, 2 order-checks) |
| r82-critic `p2-realonly` (scratch probe, critic judge) | 124 | 124 | 123 | 1 (line 122, glued) | `reorder\|dup\|FD1` (line 124) | True | FAIL (violations=1) |

Raw→parsed deltas that hold on every tracked receipt (receipts cited above):

- **Exactly one ARM-prefixed line is dropped per run** in the r81+ stream: the
  glued `REORDERGLUE::…` line, which fails the `^ARM ` anchor because the
  descendant's unterminated tail is spliced onto the parent's first buffered
  row. It is **dropped, not misattributed** — the casualty row's cell is
  simply absent (r81 `reorder_splice_dropped` pin, re-verified here).
- **The splice casualty is regime-dependent** (new, measured by audit of the
  boundary seat's receipt): under the collapsed/write-through regime
  (`envcollapse`) the *parent's* `dup src=parent` row is the one that gets
  glued and dropped (line 124), the child's forged `src=child_inj` survives as
  the only cell value, and the tracked `reorder_dup_lastwins` pin FAILS
  (`src='child_inj' != pinned 'parent'`) together with two order-checks. Same
  stream shape, opposite casualty. Both regimes lose exactly one line.
- **Duplicate cells exist in the live stream**: `reorder|dup|FD1` appears twice
  (child line 120, parent line 123) → 1 cell, parent value. The parser has no
  provenance field, so a receipt cannot distinguish a parent row from a
  descendant row; the only provenance evidence is byte order plus the
  `post_spawn` precondition pins (`line_buf`, `write_through`, `fd1_fifo`).
- **Coverage / forge-accept surface**: of the 122 parsed cells, **73 are
  pinned by CASES (59.8%) and 49 are unpinned** (`runs/rawview-r82.json`
  `foreign_cells`; the 74 CASES rows map to 73 distinct keys —
  `transform|w0|RNA` is pinned twice, two rows checking different keys of the
  same cell). Injection into any unpinned cell is invisible to the battery —
  measured, not inferred (§2 A4).
- **Labeling drift**: `verdicts.json:396` records `n_arm_lines = len(arms)` =
  **122 parsed cells**, while the receipt stream carries **123 ARM-prefixed
  lines** (124 in the critic's probe variant). A reader taking `n_arm_lines`
  as "lines emitted" under-counts by the dropped line. No receipt today
  records the raw ARM-prefixed count.
- **Blender's C-level tail** lands after `PROBE_DONE` in every receipt
  (`Blender 5.2.1 LTS (…)`, blank, `Blender quit` — 3 raw lines, 78 B);
  `done_marker` is a presence check (`bpy_battery.py:315`) and is
  position-insensitive, so this tail is parse-neutral.

## 2. Hazard catalogue update (X6/X7) — measured resolutions

Wording discipline: each row is "the demonstrated hazard resolves as X on this
build/host" — never "the parser is safe". All cells ran through the TRACKED
capture/parse code, imported read-only. The r82 additions to the r80/r81
catalogue (14 bare classes + 6 parse-survival classes) are A–E below.

| # | hazard class (brief) | measured resolution | evidence |
|---|---|---|---|
| A1 | forged `violations=0` row injected **after** a real `violations=3` row | **MASKS — forge-accepted**: tracked case loop returns 74/74 PASS with the real violation still in the stream | `runs/hazards/A1_forged_after_real_violation.stdout.txt`, `hazard_cells.json` |
| A2 | same forgery injected **before** the real row | **not masked**: 73/74, `evalcat_closed_set` FAILs on `violations='3'` | `A2_…stdout.txt` |
| A3 | control: real `violations=3`, no forgery | 73/74 FAIL → the pin is live (not constant-True) | `A3_…stdout.txt` |
| A4 | injected **unpinned** cell (`evalcat \| forged_extra \| EDGE`) | **invisible**: 74/74 PASS; `reorder_no_extra_cells` is scoped to `arm == "reorder"` (`bpy_battery.py:358-360`) | `A4_…stdout.txt` |
| B1/B2 | duplicate-key tie-break (child value first vs last) | **physical (byte) last-wins** is the contract: parsed value flips with line order only | `B1/B2_…stdout.txt` |
| B3 | duplicate key delivered as a spliced/glued line | **dropped, not misattributed**: the earlier cell value is retained | `B3_…stdout.txt` |
| E1 | forged **logical-last** dup under `blender -b -P` (parent emits first into the block buffer, child writes after, parent flushes last) | **the forged logical-last loses**: raw order = child, parent, parent → parsed `src=parent`. Tie-break is physical, not emission order | `runs/forge-live/e1_tiebreak.stdout.txt` |
| E2 | **live forge-accept**: real `violations=3` row flushed, then a descendant writes forged `violations=0` (physically last) | **the battery does not detect the forgery**: `evalcat_closed_set` PASSes; parsed `violations=0` while the real row is on the wire | `runs/forge-live/e2_forge.stdout.txt`, `forge_live.json` |
| C1 | binjunk / non-UTF-8 bytes on the captured stream | tracked `run_process` **raises `UnicodeDecodeError`** (`'utf-8' codec can't decode byte 0xff … position 29`); the tracked error handling catches only `TimeoutExpired`/`OSError` (`bpy_battery.py:269-275`) → the battery **crashes instead of reporting FAIL** | `hazard_cells.json` `part_c_binjunk` |
| D1b/D1c | detach-child EOF-hold under the battery timeout (fd1 held by a live detached grandchild) | tracked `run_process(timeout=3)` **returns at the bound** (3.004 / 3.003 s) with partial bytes captured; wall time did **not** extend. The raw `Popen.communicate()` control on the same topology **blocked 9.009 s** on EOF (total 12.012 s). Cause is the stdlib timeout path on POSIX: `subprocess.run` calls `process.wait()` (not `communicate()`) after `kill()` — verified in this build's source (`python3 3.14.7`, `/usr/lib/python3.14/subprocess.py:566-570`) | `runs/detach/detach_cells.json`, `runs/eofhold_raw.stdout.txt` |
| D-late | descendant bytes written **after** the capture returned | **lost**: late row absent from the capture; the descendant's write raises `BrokenPipeError`. Complementary case (critic `p2-detach`, §5): a descendant row written after `Blender quit` **is** captured when the capture has not yet returned — the hold delays EOF, the timeout bounds it | `runs/latebytes/latebytes_cell.json`, `grandchild_report.json` |
| D-reap | detached descendant after the timeout kill | **survives** (alive at return in both detach cells; this seat killed it by pidfile). `run_process` reaps only the direct child | `detach_cells.json` (`grandchild_alive_at_return: true`) |
| E-receipt | hand-written ("canned") receipt | a receipt can carry a byte-identical stream, a PASS verdict and an absolute probe path with **no execution behind it**. The r82-boundary harness does exactly this and self-labels: `probe_elapsed_s = 4e-06`, `blender_version = "Blender 5.2.1 LTS (canned harness banner)"` | `runs/canned-baseline/bpy-20261014T152031784068Z/verdicts.json`, `corpus/live/r82-boundary/harness/harness.py:49-54` |

Reading: the parser's drop behavior is consistent (drop-not-misattribute) and
its tie-break is deterministic (physical last-wins), but the *verdict* surface
is writable by anything that can write to the inherited fd1: a physically-later
forged row wins its cell (E1/B1), a forged `violations=0` after a real
violation is accepted (A1/E2), unpinned cells are unprotected (A4), and the
closed-set pin therefore has a demonstrated forge-accept path whenever a
descendant's bytes can land after the parent's flush. The r81 topology (child
bytes *before* the parent's buffered prefix) does **not** produce that path;
the path needs a descendant writing after the parent's flush — the critic's
`R82_FORGERY_POS=post_flush|detach` cells (`corpus/live/r82-critic/p2_probe_forged.py`)
target exactly that and had not landed a receipt at measurement time.

## 3. Receipt hygiene (paths / timestamps / ASLR stability)

All checks in `runs/hygiene.json`; scope = the 31 tracked battery receipts
directly under `corpus/live/r80-*,r81-*,r82-*/…/runs/bpy-*/`. Receipts nested
one level deeper (sibling seats' `runs/baseline/`, `runs/prebaseline/`,
`runs/canned-baseline/`, `runs/envcollapse/`, `runs/p2-*/` trees) are outside
that glob and are audited separately where relevant (§1, §2, §5).

- **Stamps (H1)**: `run_dir` name stamp == `verdicts.json.started_utc` for
  **31/31** receipts (exact string, e.g. `bpy-20261014T145803952150Z` ↔
  `20261014T145803952150Z`). `probe.stdout.txt` mtime ≤ `verdicts.json` mtime
  for 31/31. Run-dir mtime is *later* than stdout (it is bumped by writing
  `verdicts.json`) — my first ordering predicate was wrong and is recorded as
  an artifact, not a defect. `probe_elapsed_s` ranges 0.53–4.67 s across the
  112/122-line streams (jitter; never a signal).
- **Determinism / ASLR (H2)**: 5 byte-identity groups over `probe.stdout.txt`.
  Within-group payload identity modulo `{probe_elapsed_s, started_utc}` holds
  for 3/5 groups (e.g. `947ad726…`: 4 receipts, 2 seats, 1 distinct payload;
  `70944761…`: 9 receipts, 5 seats, 1 payload; `f191b680…`: 3 receipts, 1
  payload). The two "2 distinct payloads" groups are explained exactly by the
  `probe` path field (frozen-extract copies vs the tracked fixture) —
  payload-diff verified, not a nondeterminism. **Byte-identical streams from 6
  independent r82 seats** (baseline, boundary, critic, reviewer, simplifier,
  verifier) reproduce the r81 post-landing sha `947ad72643d2…` → strong
  same-build ASLR/replay stability evidence.
- **ASLR-ish tokens (H3)**: 0 hits for `0x[0-9a-f]{4,}`, `pid[=:]\d+`,
  `/tmp/…` in all tracked ARM streams → the receipt text carries no
  addresses/PIDs/temp paths. (Counter-example outside the stream: the
  r82-critic batch-instance probe crashed blender and produced
  `/tmp/blender.crash.txt` with ASLR addresses — a crash artifact, not an ARM
  receipt; `corpus/live/r82-critic/runs/p1b_crash.txt`.)
- **Paths (H4)**: `probe` is absolute in 31/31; 4 distinct values (tracked
  fixture; r80-baseline and r81-baseline `frozen-extract` copies;
  r80-simplifier scratch copy) → the receipt records which probe path ran,
  and frozen-extract receipts still produce the identical stdout sha.
- **Report-vs-receipt drift (H5)**: r81-author's claims verified from receipts
  — 74/74, 4/4 order-checks, stdout sha `947ad726…` ×2, all 112 prior ARM
  rows an ordered subsequence of the 123 ARM-prefixed post lines, r79 78-line
  prefix sha `08101bed…`, pre-landing sha `fb336ae5…`. Two drift items:
  1. `reports/round-81/r81-scribe.md:113` (repeated `:189`, `:298`) states the
     tracked probe's stream is **"9,657 B / 112 ARM rows"**. Measured from the
     receipts: full stream
     **9,624 B**, ARM-only stream (112 ARM + `PROBE_DONE`) **9,546 B** — the
     sha claim `16978267…` matches, the byte count does not (no artifact of
     that size exists in `corpus/live/`; the discrepancy is +111 B vs ARM-only,
     +33 B vs full).
  2. `n_arm_lines` = parsed cells ≠ raw ARM-prefixed lines (122 vs 123) — see
     §1. Both are reporting-level; neither touches the r81 verdict.
  Also recorded: the r82-boundary `canned-baseline` receipt is a *labeled*
  synthetic receipt (elapsed 4e-06, synthetic banner) — good hygiene practice,
  and the reason it is detectable.

## 4. Seat landings and drift watch (state at 12:26)

| seat | scratch landed | tracked report | receipt evidence | note |
|---|---|---|---|---|
| author | **no** (`corpus/live/r82-author/` absent) | **no** | — | ARM A/B not landed; both arms unverified by this seat |
| baseline | yes | no | sha `947ad726…` PASS 74/74 | zero-drift baseline reproduced |
| boundary | yes (harness, env cells, mutants) | no | `947ad726…` PASS; `envcollapse` FAIL (2 cases/2 order-checks) | provides the round's falsifier-liveness receipt; canned receipt self-labeled |
| critic | yes (p1 fold probes, p1b crash, p2 forged probe, p7 pin-forge) | **yes (12:24)** — audited in §5 | `p2-realonly` (FAIL `violations=1`); `p2-post_flush` / `p2-detach` PASS 74/74 with a real violation on the wire (forgery receipts) | forgery-position cells landed and verified |
| reviewer | yes | no | `947ad726…` PASS | |
| scout | yes | **yes (12:25)** — audited in §5 | hazards.json + mutant cells; H1–H4 agree with this seat | pre-measurement lattice |
| simplifier | yes (watch, arrival shas, tools) | no | `947ad726…` PASS | |
| verifier | yes | no | `947ad726…` PASS | |
| scribe | this seat | this file | — | |

HEAD did not move during the watch (31cf56a throughout). **Open drift watch for
the verifier/adjudicator**: (a) whether the author's ARM-B pins pin A1/E2 as
forge-accept (masking) or claim detection — the measured behavior is masking,
independently confirmed by the scout and critic receipts (§5); (b) whether the
*tracked* receipt payload ever records raw ARM-prefixed vs parsed counts — the
critic's scratch `judge.json` already carries both (`n_raw_arm_lines: 126`,
`n_arm_lines_parsed: 124`), the tracked `verdicts.json` carries only
`n_arm_lines` (= parsed cells); (c) whether `n_arm_lines`/9,657 B-style
labeling drift recurs in r82 reports.

## 5. Post-draft sibling landings audited (12:24–12:26)

Two sibling reports landed after this report's first draft; both were audited
against their own receipts (not taken on trust):

- **`reports/round-82/r82-critic.md`** (F2/F3): its forged-row table is
  **confirmed by its receipts** — `runs/p2-post_flush-20261014T152144795003Z/judge.json`:
  real `violations=1` at byte offset 10841, forged `violations=0 forged=post_flush`
  at 11332 (physically later), parsed cell `{violations:0, forged:post_flush}`,
  **verdict PASS 74/74, 4/4 order-checks**; `runs/p2-detach-…`:
  forged row captured at **line 132, after `Blender quit` (line 131)** — the
  detached descendant's bytes are captured post-hoc because it holds fd1, and
  the run still PASSes. My auditor on those two streams: 126 ARM-prefixed →
  124 parsed cells, 1 dropped (line 122, glued), and a **second dup-overwrite
  on `evalcat\|closed\|EDGE`** — the forge-accept mechanism shows up in the
  ledger as a duplicate on the verdict-carrying cell. Their
  `runs/p7_forge_any_pin.json` generalization (clean → no fails; broken regime
  → `reorder_dup_lastwins` fails; broken+forged dup → forged wins;
  real violation → fails; real+forged closed → 0 fails, cell carries
  `forged=yes`) matches my B1/B2/E1 and A1/E2 values exactly.
- **`reports/round-82/r82-scout.md`** (§2): H1/H2/H3/H4 directions are
  **identical to this seat's cells** — real(3)+forged(0) → masked PASS,
  forged-first → detected; physical last-wins with both flush orders; strict
  decode raises `UnicodeDecodeError` (they add the battery-level consequence:
  uncaught driver → exit 1, no `verdicts.json`); detach EOF-hold T=3 s cell →
  wall 3.003 s, `rc=None`, TIMEOUT error, partial stdout — the same bound this
  seat measured, plus their T=60 s end-to-end cell (all 74 cases PASS yet
  `launch_ok=False` → verdict FAIL at exactly `TIMEOUT_S`).
- **Convergence**: three independent seats (scribe, scout, critic) agree on
  all four ARM-B resolutions. Differences are scope, not values — this seat
  adds: the raw/parsed ledger (dropped line, dup overwrite, 59.8% pin coverage,
  49 unpinned cells), the regime-dependent splice casualty (boundary
  `envcollapse`: the *parent's* `dup` row is the casualty, flipping the pin),
  the post-bound byte loss (`BrokenPipeError`, `runs/latebytes/`), the
  stdlib-source reason the tracked timeout path does not hang (POSIX
  `run()` → `process.wait()`), and the receipt-hygiene/drift sweep.
- **No conflict found** to escalate on the hazard resolutions. Wording caution
  for the ledger: the brief's ARM-B phrasing "parser must NOT let it mask a
  real violation" is measured **not met in the masking direction** (A1/E2,
  scout H1, critic F2/F3); the brief's own instruction — "measure and pin
  whichever behavior exists, honestly" — is what the pins must carry.

## Findings

1. **A forged `violations=0` row physically after a real violation is
   accepted (74/74 PASS) — measured twice: raw-stream cell A1 and live
   `blender -b -P` cell E2** where a descendant writes the forgery after the
   parent's flush. The same forgery placed *before* the real row does not mask
   (A2), and the real violation alone is detected (A3) — so the pin is live
   and the failure mode is directional.
2. **The dup tie-break is physical last-wins, not logical last-wins** (B1/B2
   raw cells + live E1: a descendant writing *after* the parent's emit still
   loses because the parent's buffered bytes land later). This is the
   contract wording the author's `dup_flush` pin should carry.
3. **Drop-not-misattribute holds, and the casualty is regime-dependent**: one
   ARM-prefixed line is lost per run in both the block-buffered and the
   collapsed regime, but a different line (gluevictim vs the parent's `dup`
   row) — so a "which row survives" claim is only meaningful with the
   buffering regime named (the fd1-owner's mode).
4. **59.8% of parsed cells are pinned; 49 cells are unprotected** and an
   injected row in an unpinned evalcat cell passes unnoticed (A4).
5. **binjunk resolves as a crash**: non-UTF-8 bytes raise `UnicodeDecodeError`
   out of the tracked `run_process` (only `TimeoutExpired`/`OSError` are
   handled) → the battery aborts instead of failing.
6. **The detach-child EOF-hold does not extend the tracked capture** on this
   build (3.003–3.004 s at a 3 s bound) although the raw `communicate()` path
   blocks 9.009 s on the same topology; bytes written after the bound are lost
   and the writer sees `BrokenPipeError`; the detached descendant survives the
   timeout kill. "Survival" here is bounded to the capture, not to process
   hygiene.
7. **Receipt hygiene is clean on stamps, paths and ASLR tokens**, with 6-seat
   byte-identity of the 122-cell stream at HEAD; the only receipt-level
   hazards are semantic (`n_arm_lines` labeling, a hand-written receipt being
   indistinguishable from a real one without its self-labeling).
8. **Two r81 reporting drifts** (stream byte count 9,657 B vs 9,546/9,624 B;
   `n_arm_lines` semantics) — verdict-neutral, recorded for the ledger.

## Gates

- Tracked battery verdict gate: `signal_fail==0 ∧ launch_ok ∧ done_marker ∧
  fatals==0 ∧ order_failed==[]` (`bpy_battery.py:388-389`). Measured at HEAD
  by six sibling seats and re-verified from their receipts by this seat:
  PASS 74/74, 4/4 order-checks, byte-identical stdout `947ad726…`.
- Falsifier liveness (round claim "pins discriminate, per runtime"): witnessed
  in the r82-boundary `envcollapse` receipt (2 cases + 2 order-checks flip) —
  audited here, produced by a sibling seat.
- Round claim gates (ARM A fold / ARM B hazard pins): **unverifiable at
  measurement time** — the author's diff and report had not landed. This seat
  provides the independent lattice (hazard resolutions A–E) the pins will be
  read against; no verdict is offered.
- No judgment, admission, or promotion is made by this seat.

## Touched surfaces

- Written (this seat's scope only): `reports/round-82/r82-scribe.md`,
  `corpus/live/r82-scribe/` (scratch: 7 harness files, 2 holder scripts,
  9 JSON receipts, 15 stdout/sidecar receipts, drafts).
- Read-only: `corpus/fixtures/bpy_battery.py` (imported verbatim for
  `parse_arms`/`run_process`/`CASES`), `corpus/fixtures/bpy_sync_probe.py`,
  `corpus/fixtures/run_battery.py`, r80/r81/r82 receipts, sibling r82 scratch
  (data), `reports/round-81/*`.
- Untouched: all tracked fixtures, `LOG.md`, `SCORECARD.md`, git state (no
  mutations; `git status --porcelain` empty before and after this seat's work).

## Out-of-scope items

- The author's r82 diff (ARM A fold rows, ARM B pins, parser hardening) — not
  landed, not implemented, not replayed, not judged here.
- The verifier's committed-tree replay/AGREE-DISAGREE; the critic's
  falsification of the landed diff; the reviewer's/adjudicator's verdicts.
- Any product-code edit, commit, push, or publication; any sibling-seat
  dispatch.
- Cross-build tolerance: every claim is bounded to Blender 5.2.1 LTS, Python
  3.14.7, this host (64 KiB pipe measured in r81; `io.DEFAULT_BUFFER_SIZE`
  131072 = this build's constant).
- The `p1b` blender crash (a sibling scratch probe's failure mode, with
  `/tmp/blender.crash.txt` addresses) and the sibling seats' own judgments —
  their forgery-position receipts landed after this seat's cells and are
  audited in §5, but their verdicts are not adopted here.

## Conflicts / disagreements with sibling evidence

- No sibling **report** existed while this seat's cells were measured; the two
  that landed afterwards (`r82-critic.md` 12:24, `r82-scout.md` 12:25) are
  audited in §5 — **no conflict** on any of the four hazard resolutions
  (three-seat agreement). Sibling **receipts** audited here agree with this
  seat's numbers: r82-boundary's baselines (sha `947ad726…`, 122 cells) and
  r82-critic's `p2-realonly` (124 raw ARM-prefixed / 123 cells / 1 dropped
  glued line) — same raw-vs-parsed delta shape I measure, one extra row from
  their probe variant.
- The r82-critic `p2-realonly` receipt shows a **real** `violations=1` row and
  a FAIL verdict with **no forged `violations=0` line in the stream** (grep
  over the receipt: only `evalcat | critic_forced_violation`). If a later
  critic receipt claims the forgery was present in that run, that receipt and
  this observation disagree; the byte stream is the arbiter.
- r81-scribe's 9,657 B figure disagrees with the receipts (9,546 B ARM-only /
  9,624 B full) — reported verbatim as drift, not corrected silently.

## Known limits

- The hazard cells A1–A4 and B1–B3 are **parser-level** (fabricated raw
  streams fed to the tracked parser/case loop); they demonstrate the
  parser/verdict surface, not a live probe defect. E1/E2 are live under
  `blender -b -P` but use this seat's scratch probes (not the tracked probe's
  own arms), so they demonstrate the capture/parse/verdict surface.
- E2's forging descendant is a short-lived `/bin/sh`+`printf`; a long-lived
  Python descendant adds its own withholding layer (r81-scout note) and is
  unmeasured here.
- The EOF-hold resolution is measured on `python3`-spawned descendants under
  the tracked `run_process`; the explanation (POSIX `run()` → `process.wait()`)
  is verified in this build's stdlib source, but the interaction with blender's
  own exit path (SIGTERM handling, C-level tail) is not measured.
- ASLR stability is evidenced by byte-identity across 6 seats on one host and
  one build; no cross-host or cross-build claim.
- Timing values (`probe_elapsed_s`, cell walls) are jitter and are used only as
  bounds (`wall_s > timeout`), never as verdicts.

## Artifact paths

- Report: `reports/round-82/r82-scribe.md` (this file).
- Scratch root: `corpus/live/r82-scribe/` —
  `scratch/r82s_rawview.py`, `scratch/r82s_hazards.py`,
  `scratch/r82s_forge_live.py`, `scratch/r82s_detach.py`,
  `scratch/r82s_latebytes.py`, `scratch/r82s_eofhold_raw.py`,
  `scratch/r82s_hygiene.py`;
  `runs/rawview-r81.json`, `runs/rawview-r82.json`,
  `runs/rawview-r82-critic-forged.json`, `runs/hygiene.json`,
  `runs/hazards/hazard_cells.json` (+7 stdout cells),
  `runs/forge-live/{forge_live.json,e1_tiebreak.*,e2_forge.*}`,
  `runs/detach/{detach_cells.json,*.py,*.pid.json}`,
  `runs/latebytes/{latebytes_cell.json,grandchild_report.json}`,
  `runs/eofhold_raw.stdout.txt`, `runs/*.stdout.txt`;
  `drafts/r82-knowledge-note.md`, `drafts/r82-log-entry.md`,
  `drafts/r82-scorecard-delta.md`.

Report only; I do not judge, admit, edit fixtures, commit, or ship. Stopping
here.
