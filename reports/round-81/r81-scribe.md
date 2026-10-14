# game-dev-3d round 81 — scribe report (seat: scribe, host: devin)

Declared lane axis (dispatch brief, verbatim): "ROUND 81 — 3d lane. TWO arms
(xconnector X1 on bpy + evalcat extension rows per r80 critic): (1) reorder
fabrication on `blender -b -P`: a spawned descendant inherits blender's fd1;
buffered-python parent -> prefix reordering of ARM-stream bytes — live hazard
class for the battery's own ARM parser; pin parse-survival cells (the parser
must not misattribute reordered bytes). (2) evalcat extension rows: fold ~6
representative bare-class rows into the tracked catalogue (per r80 critic
fold-guidance — the tracked 8-class bare catalogue vs ~100 swept; pick from
critic's list: scene-prop write, hierarchy link, data swap, parent write,
objects.remove, orphans_purge). Claim: reorder topology falsifiable per
runtime; catalogue extension byte-stable."

Scribe duty: knowledge note + LOG/SCORECARD drafts, mechanism not narrative.
Lane practice (r76–r80 precedent): independently re-run the round's declared
claim shape under `corpus/live/r81-scribe/` with this seat's OWN harness — here
a fabricated-descendant cell matrix through the TRACKED capture path and the
TRACKED parser, plus a pre-landing byte-stability baseline for the catalogue
extension. Report-only; not the judge. Leaf: no subagents, no git mutations;
this report is the only tracked write (scratch is gitignored,
`corpus/.gitignore:1` = `live/`).

## Behavior (what this seat did)

1. Snapshotted the tree, fixture hashes, and the tracked catalogue.
2. Ran the tracked battery twice on the pre-landing tree (byte-stability
   baseline for arm 2).
3. Built an own cell matrix (`scratch/r81s_cells.py` + `scratch/r81s_child.py`
   + `scratch/r81s_drive.py`): 34 runs under `blender -b -P` and `python3`,
   every capture through the tracked `run_process` verbatim
   (`bpy_battery.py:197-208`), every stream parsed with the tracked
   `parse_arms` (`:211-220`) and the tracked `done_marker`/`fatals` predicates
   (`:248`, `:249`), imported read-only from `corpus/fixtures/bpy_battery.py`.
4. Localized the parent's first-flush boundary, the per-runtime contrast
   (`python3` vs blender-embedded python), and the `PYTHONUNBUFFERED` control.
5. Recorded parse-survival outcomes per fabricated topology; drafted the
   knowledge note + LOG entry + SCORECARD delta (inside this seat's scope).

## Landed state at measurement time (14:35–14:40 UTC)

- HEAD `ae89c1308e982538d45b4ffbcb71e48a524b13f4` (r80 report-last). Working
  tree: only three untracked r80 seat reports (`r80-baseline.md`,
  `r80-reviewer.md`, `r80-verifier.md`) — no product change.
- **The r81 author's diff had NOT landed** (no `corpus/live/r81-author/`, no
  fixture hash change). Fixtures at measurement:
  `corpus/fixtures/bpy_sync_probe.py` sha256 `bfa80ed4bd296746242d1bd6bdb9cd932b570f632f0bcb06898e6b5a0c746780`
  (1041 lines; `emit` = plain `print`, `:56-58`; `arm_evalcat` `:1016`),
  `corpus/fixtures/bpy_battery.py` sha256
  `ae3b04b129555da72265576f4521c3e07a53ebe87f074cc3713fa702e2e08070`
  (302 lines; 64 CASES, 27 evalcat, **8 bare `invoked=none` rows**:
  rna_write, driver, driver_expr, keyframe, key_explicit, con_rna,
  conadd_target, walltime — r80-critic §4's count re-verified),
  `corpus/fixtures/run_battery.py` `22a1966d…` (untouched).
- Sibling scratch observed in flight (data, not relied on): `r81-scout/`
  (`bpy_reorder_probe.py`, `parse_survival.py`, `fold/`), `r81-boundary/`
  (`reorder_probe.py`, `run_cells.py`), `r81-critic/` (`reorder_parent.py`,
  `buffering_probe.py`), `r81-baseline/`, `r81-reviewer/`, `r81-simplifier/`,
  `r81-verifier/`. No `reports/round-81/` file existed when this report began.
- Toolchain: `/usr/bin/blender` = Blender 5.2.1 LTS (hash `9e2066aef7ef`,
  built 2026-09-01); `python3` = 3.14.7; `io.DEFAULT_BUFFER_SIZE` = 131072;
  pipe capacity = 65536 B (measured, `F_GETPIPE_SZ`).

## Commands and receipts

| # | command (cwd `~/Projects/shokunin/game-dev-3d-shokunin`) | exit | receipt |
|---|---|---|---|
| 1 | `python3 corpus/fixtures/bpy_battery.py --runs corpus/live/r81-scribe/runs-battery-pre` | 0 | `runs-battery-pre/bpy-20261014T143557312834Z/verdicts.json` (64/64) |
| 2 | same, `--runs …/runs-battery-pre2` | 0 | `runs-battery-pre2/bpy-20261014T143604001859Z/verdicts.json` (64/64) |
| 3 | `python3 corpus/live/r81-scribe/scratch/r81s_drive.py` | 0 | `corpus/live/r81-scribe/runs/<cell>.{stdout,stderr,exit,elapsed_ms}.txt` ×34 + `runs/analysis.json` |
| 4 | `R81S_CELL=cellM R81S_NB=2000 blender -b -P scratch/r81s_cells.py > runs/cellM_file2000_blender.txt` (+ `python3` twin) | 0 | `runs/cellM_file2000_{blender,py3}.txt` |
| 5 | `R81S_CELL=cellA PYTHONUNBUFFERED=1` under `blender -b -P` and `python3`, captured by tracked `run_process` | 0 | `runs/{blender,py3}_unbuffered.stdout.txt` |

All 34 driver runs: exit 0 except `cellK` (exit 3, deliberate abort), all
stderr byte-empty; `cellP`'s tracked capture raised (see §5). Scratch hashes:
`r81s_cells.py` `61a472870e571cabd16da29966464945d85b03396e5546d9a8012465ad0eb5da`,
`r81s_child.py` `fc84fcffea1c039b7002722c64bf05d8a831865cc0923d748960d04959a5af33`,
`r81s_drive.py` `0cd6a6c0661fcdef0ebef18441f4d52c9c92e8bd1d505ded10a6e4240860f465`,
`runs/analysis.json` `d05b0afaa25e4d506e5c1af45ca5119f053c662bdbd843caf826bb1e67b88ffd`.

## 1. Arm (1) — reorder topology: FABRICATED, deterministic, runtime-dependent

Mechanism (all refs measured, not inferred): `emit` prints without flushing
(`bpy_sync_probe.py:56-58`); the battery captures via
`subprocess.run(capture_output=True, text=True)` (`bpy_battery.py:197-208`) so
blender's fd1 is a pipe (65536 B); the probe's stdout is block-buffered
(`isatty=False line_buffering=False` — measured inside the cell, e.g.
`runs/cellA.stdout.txt` line 2); a descendant spawned with default
`close_fds=True` keeps fds 0/1/2, inherits the pipe, and its `os.write` bytes
reach it immediately. Consequence: the descendant's bytes precede the parent's
entire buffered prefix.

| cell | topology fabricated | measured stream order | child byte offset |
|---|---|---|---|
| cellA | parent `print` P1 → spawn descendant (`os.write`) → `print` P2 | child, cell, P1, P2, PROBE_DONE, banner, quit | 32 (line 0) |
| cellB | control: `flush()` before spawn | cell, P1, child, P2 | 156 (line 2) |
| cellC | control: descendant `stdout=DEVNULL` | cell, P1, P2 (no descendant bytes) | — |
| cellD | control: parent `os.write` P1/P2 (unbuffered fd1 path) | P1, child, P2, PROBE_DONE, then the *print*-buffered line | 67 (line 1) |
| cellE NB=60…1400 | parent stream ≤ ~118 KB, then spawn | child first, whole parent prefix after it | 13 (line 0) |
| cellE NB=1600/2000 | parent stream ≥ ~135 KB, then spawn | child's bytes land **mid-line** (line 1491) | 123235 |
| cellE NB=20000 | large stream, then spawn | child's bytes land mid-line (line 18945) | 1607261 |
| cellM NB=100/400/1400 (no descendant) | parent's own unbuffered marker | marker at line 0 → 0 B flushed | 13 |
| cellM NB=2000/20000 (no descendant) | same | marker mid-line at the first flush | 123238 / 1607262 |
| cellA_py3 | same cell under `python3` | identical prefix reorder (5 lines: no blender tail) | 32 |
| cellM_nb400/nb2000_py3 | `python3` twin | identical boundaries (13 / 123238) | — |
| blender_unbuffered | `PYTHONUNBUFFERED=1` + `blender -b -P` | **still reordered** (child first) | — |
| py3_unbuffered | `PYTHONUNBUFFERED=1` + `python3` | order preserved (cell, P1, child, P2) | — |

Boundary localization: the parent's first flush lands at 123,235 B (cellE) /
123,238 B (cellM) and is capture-independent (file-redirect twin receipts show
the same offsets), i.e. writer-side; the effective buffered prefix is ~128 KiB
(`io.DEFAULT_BUFFER_SIZE` = 131072 in this build). The tracked probe's own
stream is **9,657 B / 112 ARM rows** — below the boundary, so for the battery
the reorder is **total-prefix**: any descendant write would precede every ARM
row.

Live status of the hazard: the tracked probe spawns no descendant (no
`subprocess`/`Popen`/`fork` in `bpy_sync_probe.py`) — the topology is fabricated
per the brief, not live today. The reorder **already present** in every battery
receipt is blender's own C-level tail: `Blender 5.2.1 LTS (…)`, empty line,
`Blender quit` land after `PROBE_DONE` (my run receipts and the r80 receipts).

## 2. Arm (1) — parse-survival cells (tracked parser applied verbatim)

| cell | fabricated topology | tracked outcome | survives? |
|---|---|---|---|
| S1 cellA | descendant row first, parent rows later, distinct keys | all 4 keys parsed with correct values (dict is order-insensitive) | **yes** |
| S2 all cells | `PROBE_DONE` position moved (banner/quit after it) | `done_marker=True` (`:248` presence check) | **yes** |
| S3 cellF | duplicate key: descendant row first, parent row later | parsed `src=parent` (last-wins `:211-220`) | **no** |
| S3' cellF2 | duplicate key: parent row flushed first, descendant later | parsed `src=child` — value flips with byte order | **no** |
| S4 cellG | parent partial unbuffered write + descendant line → one merged line | row `scribe\|mid\|T` = `{a:9,b:9}`: the descendant's values replaced the parent's `a=1,b=2`; parent's tail ` tail=1` became a stray ignored line | **no** |
| S5 cellH3a | parent `evalcat\|closed\|EDGE violations=0`, then descendant `99` | parsed `99` → the tracked `evalcat_closed_set` pin would FAIL falsely | **no** |
| S5' cellH3c | parent `violations=3` (real violation), then descendant `0` | parsed `0` → a real violation is masked | **no** |
| S6 cellI | parent never prints `PROBE_DONE`; descendant does | `done_marker=True` (completion satisfiable by a descendant) | **no** |
| S7 cellJ | descendant writes `ARM … \| FATAL \|` | `fatals=1` → battery verdict FAIL | **no** |
| S8 cellP | descendant writes non-UTF-8 bytes (`\xff\xfe`) | tracked `run_process` raises `UnicodeDecodeError` (byte 0xff, position 0) — reproduced both in the cell and by calling the imported tracked function on a raw non-UTF-8 stream; raw receipt `runs/cellP.stdout.raw.bin` | **no** |
| S9 cellK | parent prints a row then `os._exit(3)` (no flush) | parent's row lost entirely; descendant's row durable; `done_marker=False`, exit 3 | **no** |

Reading: the parser's **ordering-insensitivity for distinct keys and its
presence-based completion check are genuine survival properties**; its
last-wins duplicate handling, its line-based body parsing, its verdict gates,
and its strict-UTF-8 capture are **not** robust to descendant bytes. The round's
"parser must not misattribute reordered bytes" requirement is therefore
**satisfied only for the distinct-key/marker-position subcase** and violated in
the five fabricated topologies above (all receipts cited).

## 3. Arm (2) — catalogue extension: pre-landing byte-stability baseline

- Tracked catalogue at measurement: 64 CASES, 27 evalcat, 8 bare
  `invoked=none` rows (list above) — the ~6-row fold (scene-prop write,
  hierarchy link, data swap, parent write, `objects.remove`, `orphans_purge`)
  **had not landed**, so the extension's own byte-stability is unverifiable
  this round by this seat; what is pinned is the baseline it must preserve.
- Battery ×2 (pre-landing): `cases=64 pass=64 fail=0 signal_fail=0
  quirk_drift=0 launch_ok=True done_marker=True fatals=0 exit=0`; probe 4.249 s
  / 4.245 s; full `probe.stdout.txt` **byte-identical** between runs
  (`diff` empty), sha256
  `fb336ae56f97c4fe9e56118bc8ed3a08b84ca258221986eaf0ee707224bc7d1b`;
  ARM-only stream (`^(ARM |PROBE_DONE)`, 112 ARM + `PROBE_DONE`) sha256
  `16978267e099ac713c62dc90406f23eff2ce729be54d32c0baed2dc8851a5480`;
  r79's 78 ARM lines sha256
  `08101bed2b07abdf1d060b8992cd3ac2526659993ef875a8b9fc399a1ede2fc8`
  — identical to the r80-author post-fold receipt's subset (and, per
  r80-critic §2, to the r79 pre-fold baseline).
- Provenance nuance for the verifier: the r80-author receipt
  `corpus/live/r80-author/runs/bpy-20261014T142321446240Z/probe.stdout.txt`
  differs from the current tree **only** in the 3 `evalcat | walltime_s*` rows
  (its `slept=` kwarg, dropped by commit `e32e2de`) — do not cite its ARM hash
  as the current baseline; use the hashes above.
- Recommended insertion-only check for the landed diff (cheap, deterministic):
  every pre-landing ARM line must appear **byte-identical and in order as a
  subsequence** of the post-landing stream (new bare rows will be inserted
  inside `arm_evalcat`, before the `closed` row), with `PROBE_DONE` still last
  in the python-level stream and the full stream otherwise unchanged.

## Findings

1. **The reorder topology is real, deterministic, and runtime-dependent.**
   Descendant bytes on the inherited fd1 precede the parent's whole buffered
   prefix for streams ≤ ~118 KB (byte offset 13, line 0, in 8 independent
   cells); at ≥ ~135 KB they land mid-line at the ~123 KB first flush. Controls
   isolate the cause to the parent's python-level buffering: flush-before-spawn,
   `stdout=DEVNULL`, and unbuffered parent writes all preserve order.
2. **`PYTHONUNBUFFERED=1` is not a mitigation under `blender`** (still
   reordered) though it is one under `python3` — a per-runtime falsifier result:
   the class is falsifiable per runtime, and blender's embedded runtime keeps
   its buffering.
3. **For the tracked battery the reorder would be total-prefix**, because its
   own ARM stream (9,657 B) sits far below the flush boundary; the hazard is
   latent (the probe spawns no descendant today), and the only live measured
   reorder in receipts is blender's C-level tail after `PROBE_DONE`.
4. **Parse survival is partial**: distinct-key reorder and marker position
   survive; duplicate keys, merged lines, injected rows in the tracked
   namespace, fabricated `PROBE_DONE`, injected `FATAL`, aborts, and non-UTF-8
   bytes all misattribute or crash the tracked path (table §2, receipts cited).
   The two tracked-namespace cells (`evalcat|closed|EDGE` 0→99 and 3→0) show the
   closure pin itself is writable by descendant bytes.
5. **Byte-stability baseline is clean pre-landing** (two byte-identical runs;
   r79 subset identical to the r80 post-fold subset), and the extension rows
   were not landed at measurement time — the committed-tree replay remains the
   verifier lane's check.

## Gates

- Battery verdict gate (tracked): `signal_fail==0 ∧ launch_ok ∧ done_marker ∧
  fatals==0` (`bpy_battery.py:283-284`). Measured pre-landing: PASS, 64/64.
- Round claim gates: (1) reorder topology falsifiable per runtime — measured
  (topology confirmed; falsifier surface = unbuffered/`PYTHONUNBUFFERED`
  runtime, flush-before-spawn, non-inherited fd1); (2) catalogue extension
  byte-stable — **unverifiable at measurement time** (author diff absent);
  baseline recorded. The "parser must not misattribute" sub-requirement is
  **not met** in five fabricated topologies (§2) — reportable verbatim to the
  canonical judge as a hazard-class finding, not a product defect (no tracked
  probe spawns descendants today).
- No judgment, admission, or promotion is made by this seat.

## Touched surfaces

- Written (this seat's scope only):
  `reports/round-81/r81-scribe.md`,
  `corpus/live/r81-scribe/` (scratch: 3 harness files, 3 draft files, 38 stdout
  receipts + stderr/exit/elapsed sidecars + `analysis.json` + raw non-UTF-8
  receipt + 2 file-redirect receipts + 2 `PYTHONUNBUFFERED` receipts + 2
  battery run trees).
- Read-only: `corpus/fixtures/bpy_battery.py` (imported verbatim for
  `run_process`/`parse_arms`), `corpus/fixtures/bpy_sync_probe.py`,
  `corpus/fixtures/run_battery.py`, r80 receipts, sibling r81 scratch (data).
- Untouched: all tracked fixtures, `LOG.md`, `SCORECARD.md`, git state (no
  mutations; `git status` unchanged apart from the three pre-existing untracked
  r80 reports).

## Out-of-scope items

- The author's r81 diff (fixture edits, extension rows, any parser hardening)
  — not landed at measurement time; not implemented, not replayed, not judged
  by this seat.
- The verifier's committed-tree replay and AGREE/PARTIAL/DISAGREE.
- The critic's falsification of the landed diff; the adjudicator's verdict.
- Any product-code change (this seat may not edit fixtures), any commit/push.
- Cross-build tolerance: no claim beyond Blender 5.2.1 LTS / Python 3.14.7 /
  this host.

## Conflicts / disagreements with sibling evidence

- No sibling *report* existed at measurement time to compare against. Sibling
  scratch data observed in flight (r81-critic `reorder_parent.py`/`buffering_probe.py`
  receipts) shows the same miniature topology (child bytes first; parent lines
  after) — consistent with my cells; my measurements extend it with the
  boundary localization, the tracked-parser outcome table, and the
  `PYTHONUNBUFFERED`/`python3` contrast. If any landed seat's numbers disagree
  with the tables above, the receipts under `corpus/live/r81-scribe/runs/` are
  the independent baseline for the canonical judge.

## Known limits

- The ~123 KB first-flush boundary is an **effective measured threshold** for
  these line shapes (boundaries 123,235 B and 123,238 B in two different
  generators; identical with file capture), not a derived constant; the
  writer's buffer size is not exposed as an attribute. `io.DEFAULT_BUFFER_SIZE`
  = 131072 is reported as the build's block size, not as the measured boundary.
- Cell K used a python-level abort (`os._exit(3)`), not SIGKILL; a
  SIGKILL/segfault variant of the durability asymmetry is unmeasured.
- The fabricated cells use `ARM scribe` keys (plus `evalcat|closed|EDGE` in the
  two tracked-namespace cells); they do not run the tracked probe's own code
  path, so the cells demonstrate the *parser/capture* behavior, not a live
  probe failure.
- All pins are for this host's Blender 5.2.1 build; no cross-build tolerance
  story (inherited from r79/r80).

## Draft: knowledge note (`corpus/lessons/r81-arm-stream-reorder-fabrication.md`)

```markdown
# R81 — the ARM stream is a deferred prefix: a spawned descendant that inherits blender's fd1 jumps ahead of it (fabricated on `blender -b -P`; the tracked parser survives distinct-key reorder and marker position, and misattributes on duplicate keys, mid-line merges, injected tracked rows, fabricated PROBE_DONE, and non-UTF-8 bytes)

## Decision and evidence

Claim tested: "reorder topology falsifiable per runtime; the parser must not
misattribute reordered bytes". On `blender -b -P` (Blender 5.2.1 LTS, Python
3.14.7, this host) the topology reproduces deterministically: `emit` is a
plain `print` with no flush (`bpy_sync_probe.py:56-58`), the battery captures
with `subprocess.run(capture_output=True, text=True)`
(`bpy_battery.py:197-208`) so fd1 is a pipe (capacity 65536 B measured), and
CPython block-buffers (`isatty=False line_buffering=False`; this build's
`io.DEFAULT_BUFFER_SIZE` = 131072). A descendant spawned with default
`close_fds` keeps fd 0/1/2, inherits that pipe, and its `os.write` bytes reach
the pipe immediately — ahead of the parent's entire buffered prefix.

- Fabricated cells (own harness `corpus/live/r81-scribe/`, receipts
  `runs/cell*.stdout.txt`): with a parent stream up to ~118 KB the descendant's
  line lands at byte offset 13 (line 0) — zero parent bytes flushed first
  (cellE NB=60..1400). At NB≥1600 the parent's first flush lands at 123,235 B
  and the descendant's bytes land **mid-line**, producing one merged line
  written by two processes. Controls: flush-before-spawn preserves order
  (cellB); `stdout=DEVNULL` removes the bytes (cellC); unbuffered parent writes
  preserve order (cellD); plain `python3` shows the identical topology
  (cellA_py3, cellM_nb2000_py3); `PYTHONUNBUFFERED=1` removes it under
  `python3` but **not** under `blender` (blender keeps buffering).
- The battery's own ARM stream is 9,657 B (112 ARM rows, post-fold r80
  receipt) — far below the ~123 KB first-flush boundary, so for the tracked
  probe the reorder is **total-prefix**, not partial. The tracked probe spawns
  no descendant today (no `subprocess`/`Popen`/`fork` in `bpy_sync_probe.py`),
  so the hazard is latent; the live reorder already present in every receipt
  is blender's C-level tail (version banner + `Blender quit`) landing *after*
  `PROBE_DONE`.
- Parse survival, tracked parser applied to the captured streams
  (`bpy_battery.py:211-220`, `:248`, `:249`): distinct-key reorder is
  parse-neutral and the completion marker is position-insensitive (presence
  check) — both survive. Five fabricated topologies misattribute:
  duplicate-key last-wins flips with byte order; a mid-line merge silently
  rewrites a row's values; a descendant row in the tracked namespace
  (`evalcat|closed|EDGE`) can fail the pin or mask a real `violations>0`;
  a descendant can fabricate `PROBE_DONE`; and a descendant can inject
  `| FATAL |` (false FAIL). Non-UTF-8 descendant bytes make the tracked
  capture path raise `UnicodeDecodeError` (strict, `text=True`) — the battery
  crashes instead of reporting a FAIL.

## Parse-survival cells (measured, tracked parser verbatim)

| cell | fabricated topology | tracked outcome | survives? |
|---|---|---|---|
| cellA | descendant row first, parent rows later (distinct keys) | all 4 rows parsed with correct values | yes |
| every cell | `PROBE_DONE` followed by blender banner/quit | `done_marker=True` (presence check) | yes |
| cellF | duplicate key, descendant first | parsed `src=parent` (last-wins) | no |
| cellF2 | duplicate key, parent first (flush) | parsed `src=child` | no |
| cellG | parent partial unbuffered write + descendant line, merged | `scribe\|mid\|T` = `{a:9,b:9}` (parent's `a=1,b=2` gone) | no |
| cellH3a | parent `evalcat\|closed\|EDGE violations=0`, then descendant `99` | parsed `99` (pin would FAIL falsely) | no |
| cellH3c | parent `violations=3` (real), then descendant `0` | parsed `0` (violation masked) | no |
| cellI | parent never prints `PROBE_DONE`; descendant does | `done_marker=True` | no |
| cellJ | descendant writes `ARM … \| FATAL \|` | `fatals=1` → battery FAILs | no |
| cellK | parent aborts (`os._exit`) with a buffered row | parent's row lost entirely; descendant's durable; exit 3, marker False | no |
| cellP | descendant writes non-UTF-8 bytes | tracked `run_process` raises `UnicodeDecodeError` | no |

## Authoring consequences

- Any arm that spawns a helper must not let it inherit fd1: pass
  `stdout=subprocess.PIPE`/`DEVNULL`, or flush before spawning and write
  unbuffered — `PYTHONUNBUFFERED=1` is not a mitigation under `blender`.
- Keep `(arm, point, layer)` keys unique across the whole stream (last-wins),
  and keep rows newline-terminated single writes (merged lines rewrite values
  silently rather than failing).
- Do not treat `PROBE_DONE` presence as proof that the parent emitted it; pair
  it with row completeness (missing rows already FAIL).
- A helper's stderr/stdout bytes are attacker-shaped data for the battery's
  pins: never route helper output into the ARM stream.

## Recheck conditions

Re-measure on engine/interpreter rebuild, on a change to `emit`/capture
(flush, `-u`, `PYTHONUNBUFFERED`), or if any arm starts spawning descendants.
The ~123 KB first-flush boundary is an effective measured threshold for these
line shapes, not a derived constant. Bounded: Blender 5.2.1 LTS, Python 3.14.7,
this host's 64 KiB pipe; no cross-build tolerance story.
```

(Verbatim copy also written to `corpus/live/r81-scribe/drafts/r81-knowledge-note.md`.)

## Draft: LOG.md round-81 entry

    ## Round 81 — 3d lane (wave-12) — arm-stream reorder fabrication + catalogue-extension baseline

    - Declared (dispatch brief): (1) reorder fabrication on `blender -b -P` —
      a spawned descendant inherits blender's fd1, buffered-python parent ->
      prefix reordering of ARM-stream bytes; pin parse-survival cells (parser
      must not misattribute); (2) evalcat extension rows — fold ~6
      representative bare-class rows (r80-critic fold-guidance) into the
      tracked catalogue; claim "reorder topology falsifiable per runtime;
      catalogue extension byte-stable".
    - At scribe-measurement time (14:35–14:40 UTC) HEAD was `ae89c13` (r80
      report-last); the author's r81 diff had NOT landed (no
      `corpus/live/r81-author/`); fixtures: `bpy_sync_probe.py` sha256
      `bfa80ed4…`, `bpy_battery.py` `ae3b04b1…` (64 CASES, 27 evalcat, 8 bare
      `invoked=none` rows).
    - Scribe independent harness (`corpus/live/r81-scribe/`, 34 blender/python3
      cells through the TRACKED capture path + tracked parser): reorder topology
      CONFIRMED — descendant bytes land ahead of the parent's whole buffered
      prefix (child byte offset 13 for streams <= ~118 KB), mid-line merge at
      the ~123 KB first flush (offset 123,235 B), order preserved with
      flush-before-spawn / DEVNULL / unbuffered writes; `PYTHONUNBUFFERED=1`
      fixes it under `python3` but NOT under `blender`.
    - Parse survival (tracked `parse_arms` + `:248`/`:249` predicates):
      distinct-key reorder and marker position survive; duplicate-key
      last-wins flips with byte order (F/F2), mid-line merge rewrites values
      (G), descendant row in the tracked namespace can false-FAIL (`H3a`
      0->99) or mask a real violation (`H3c` 3->0), fabricated `PROBE_DONE`
      accepted (I), injected `| FATAL |` false-FAILs (J), abort loses the
      buffered prefix while descendant bytes stay durable (K), non-UTF-8
      descendant bytes raise `UnicodeDecodeError` in the tracked capture path
      (P).
    - Byte-stability (arm 2 baseline, pre-landing): battery x2 = 64/64 PASS,
      full stdout byte-identical (sha256 `fb336ae5…`), ARM-only stream
      (112 ARM + PROBE_DONE) `16978267…`, r79's 78 ARM lines `08101bed…` =
      the r80 post-fold receipt's subset. Note: the r80-author receipt differs
      only in the 3 `walltime` rows (`slept=` kwarg, dropped by `e32e2de`) —
      not the current baseline.
    - The extension rows (~6 bare classes) and any parser hardening were NOT
      landed at measurement time; the verifier's committed-tree replay is the
      gate. Reorder hazard is latent for the tracked probe (it spawns no
      descendant); blender's C-level banner/`Blender quit` after `PROBE_DONE`
      is the live measured reorder in every receipt.

(Verbatim copy also written to `corpus/live/r81-scribe/drafts/r81-log-entry.md`.)

## Draft: SCORECARD round-81 delta

    ## Round 81 verdict — 2026-10-14

    | axis | verdict | evidence |
    |---|---|---|
    | coverage | **unchanged locally** | no tracked fixture change landed at scribe-measurement time; 64 CASES / 27 evalcat / 8 bare `invoked=none` rows unchanged; the ~6-row bare-catalogue fold (scene-prop write, hierarchy link, data swap, parent write, `objects.remove`, `orphans_purge`) is the author's pending move |
    | depth | **improved locally (hazard class mapped, fabricated)** | arm-stream reorder topology measured on `blender -b -P`: descendant inheriting fd1 jumps ahead of the parent's whole buffered prefix (child byte offset 13 for streams <= ~118 KB; mid-line merge at the 123,235 B first flush; `PYTHONUNBUFFERED` ineffective under blender); tracked parser survives distinct-key reorder + marker position, misattributes on duplicate keys / mid-line merges / injected tracked rows / fabricated `PROBE_DONE` / injected `FATAL`, and raises `UnicodeDecodeError` on non-UTF-8 descendant bytes |
    | calibration | **unchanged** | thresholds and pins untouched; pre-landing byte-stability baseline recorded (full stdout `fb336ae5…`, ARM-only `16978267…`, r79 subset `08101bed…`); no verdict-gate change proposed |

    Bounded: Blender 5.2.1 LTS / Python 3.14.7, this host (64 KiB pipe,
    `io.DEFAULT_BUFFER_SIZE` 131072); fabricated cells only — the tracked probe
    spawns no descendant today; no product-code change by this seat. Author
    diff not landed at measurement; verifier replay is the gate.

(Verbatim copy also written to `corpus/live/r81-scribe/drafts/r81-scorecard-delta.md`.)

## Artifact paths

- Report: `reports/round-81/r81-scribe.md` (this file).
- Scratch root: `corpus/live/r81-scribe/` — harness
  `scratch/r81s_cells.py`, `scratch/r81s_child.py`, `scratch/r81s_drive.py`;
  drafts `drafts/r81-knowledge-note.md`, `drafts/r81-log-entry.md`,
  `drafts/r81-scorecard-delta.md`; analysis `runs/analysis.json`; cell
  receipts `runs/<cell>.{stdout,stderr,exit,elapsed_ms}.txt` (34 runs);
  boundary/file-capture receipts `runs/cellM_file2000_{blender,py3}.txt`;
  `PYTHONUNBUFFERED` receipts `runs/{blender,py3}_unbuffered.stdout.txt`;
  raw non-UTF-8 receipt `runs/cellP.stdout.raw.bin`; battery receipts
  `runs-battery-pre/bpy-20261014T143557312834Z/` and
  `runs-battery-pre2/bpy-20261014T143604001859Z/`.

Report only; I do not judge, admit, edit fixtures, commit, or ship. Stopping
here.
