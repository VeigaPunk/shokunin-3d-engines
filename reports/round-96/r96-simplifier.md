# r96 simplifier — YAGNI/dead-code review of the committed r96 joltdet landing (`dd054a2`)

Seat: GAME-DEV-3D r96 SIMPLIFIER, read-only. Task:
`/home/vgpnk/Projects/shokunin/.ufo/waves/shokunin-train-20261015-w22/tasks/g3d-r96-simplifier.md`.
Scope: the committed work commit
`dd054a24af91c3cac84826f5df5ce5efa9e88429` only — `corpus/fixtures/r96_joltdet.gd`
(+873, new), the eight `corpus/fixtures/r96_probe_*.gd` copies (+1 275, new),
`corpus/fixtures/run_battery.py` (+30/-0, insertion-only; `git diff --numstat`
recomputed here), `reports/round-96/r96-author.md` (+224) — plus its receipts.
No fixture edit, no commit; the only **tracked** write this seat makes anywhere
is this report (receipts land under the gitignored `corpus/live/`). HEAD was
`dd054a2` at seat start and at seat end; the r97 lane dropped ten untracked
`corpus/fixtures/r97_probe_*.gd` files into the seed dir during the window —
none of them touched by this seat, and the ten committed r96 bytes were
re-hashed unchanged at the end (§1.1). Deletion probes ran on throwaway copies
of the seed under `corpus/live/r96-simplifier/trees/`, deleted after the runs
and **byte-reproducible** from `scripts/prepare_trees.sh`; the exact edited
fixtures that ran are kept under `probes/`.

Godot `4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`; `/usr/bin/python3`
`3.14.7`; 32-core host, **load 76–86 across every run** (four sibling lanes'
full batteries — `r96-verifier`, `r96-critic`, `r96-scribe`, `r96-reviewer` —
plus a sibling 2d lane were running; "load preferred" is satisfied, and every
pin below was re-measured under it).

**LSP device: unavailable to this seat.** The only MCP server bound to this
session is `rea` (Ghidra/REA binary analysis), which does not answer GDScript,
and no `lsp`/`references`/`definition` tool exists in this toolset — so every
call-site claim below is the **literal census, not semantic proof**. The
landing's shape narrows the gap: the parent has no reflective surface (no
`eval`, no dynamic-name access; its name-indexed tables are the literal
`ARMS`/`SUM_PREFIX`/`PROJECTS`; children are read by literal `res://` path), and
every deletion candidate was **executed** (§1.2–§1.4), with a detection control
that proves the comparator resolves a one-constant mutation (§1.4). One
`ufo-labrat` probe was dispatched (frozen probeParent, exactly one): its
environment had **no exec tool**, so it returned a static code-path trace only
and could not run the live experiment it was given; that experiment was run by
this seat instead (§5.2), and the labrat's trace agrees with the measurement.

## 0. Verdict

**PASS — no bar-meeting *simplifier* defect. The parent fixture carries 14 net
lines of removable dead weight (SP-1…SP-4) proven at 12/12 battery rows
byte-identical *and* 93/93 child receipts byte-identical to the scout/boundary
receipts; a further 5 lines of dead bindings live in four of the eight probe
copies (SP-5 — proven identical, but *take-or-drop*: it changes 4 of the 8 probe
sha256s the author's report pins). Seven non-mutant runs (3 committed, 2 probeA,
2 probeB) produced byte-identical markers for all 12 rows under load 76–86; the
detection control (probeC) reddened exactly one row and exactly one cell. Three
report-accuracy findings are filed (F-1 nc law text, F-2 scanner-class text —
both measured; F-3 the "censused in '#' diagnostics" claim), none behavioral.**

| # | fold | weight | proof | call |
|---|------|--------|-------|------|
| **SP-1** | parent: `_scan_lines`'s `lk`/`pe` counters are **write-only outputs** — incremented, returned in the dict, and read by nobody (`"lk"`/`"pe"` occur exactly once each, in the return literal); drop both counters, their increments and the two keys | **−5 lines** (4 edits) | 2/2 probeA runs 12/12 rows byte-identical; probeA1 crosscheck 93/93 | **take** |
| **SP-2** | parent: `_run_nc` recompiles the identical `imp=[^ ]+ ` regex locally although the member `_imp_re` (compiled in `_initialize`, used by `_cell_text`) exists; use the member | **−2 lines** (2 edits) | same probes | **take** |
| **SP-3** | parent: `_sum_line(m, probe)` is `_line_with(m, SUM_PREFIX.get(probe, ""))` hand-inlined; delegate | **−4 lines** (1 edit) | same probes | **take** |
| **SP-4** | parent: `_run_dummy` hand-rolls a prefix scan for `"D0 case=sleep1"` where `_line_with` already exists | **−3 lines** (1 edit) | same probes | **take** |
| **SP-5** | probes: five dead bindings in four of the eight copies — `damp.gd prev` (declared, never touched), `pen.gd floor_body` (assigned 3× from `mk_floor()`, never read), `rest.gd floor_body` (same, 1×) + `floor_body2` (never used), `warm.gd if_tick` (assigned 1× in `on_if`, never read) | **−5 lines** (4 files, 5 rewrites) | 2/2 probeB runs 12/12 rows byte-identical; probeB1 crosscheck **93/93** byte-identical to the scout's | **take-or-drop (weak)** — behaviour-proven, but 4 of the 8 probe sha256s in the author's table stop matching the scout sources (§4) |
| **F-1** | parent header (lines 68–70): the `nc` law says the nocache cell "is rep-stable AND reads the real contact-0 impulse"; the cell is **pose-only** and the impulse readback is only censused — the code's own comment and the author's correction #6 say so, and the readback moved in 2 of 8 runs while the pinned pose sha never moved | LOW | code census + 8-run census (§5.1) | **file** (report accuracy) |
| **F-2** | parent header (lines 19–20): "Anything else … (a SCRIPT ERROR, an unexpected ERROR:, a new warning) fails the arm: the cell is not printed as PASS" is **false for the plain-warning class** — measured: an injected non-allowlisted `WARNING:` line still prints `PASS` (8 changed shas), and only the *battery* row fails on its exact-marker check | LOW | scanner probe, live (§5.2) | **file** (report accuracy) |
| **F-3** | parent header (lines 11–18): "Dropped before hashing (never pinned, **censused in '#' diagnostics**)" is true only for the Jolt warning; the banner/empty/leak/benign-block drops have no census surface at all (the `lk`/`pe` counters that held them were never read — §SP-1) | LOW | code census (§5.3) | **file** (report accuracy) |

## 1. Evidence base (all read-only, recomputed here — nothing taken on the author's word)

### 1.1 Committed bytes

`git status --porcelain` at seat start: two pre-existing untracked sibling
reports (`reports/round-94/r94-reviewer.md`, `reports/round-95/r95-reviewer.md`);
at seat end: those two plus the r97 lane's ten untracked `r97_probe_*.gd` seeds.
HEAD `dd054a24af91c3cac84826f5df5ce5efa9e88429` at both ends. sha256 recomputed
here (all ten equal the author's report where it pins them):

```
8a77ecb4c29ab8b69b7e95efb4f7c9f54bb6edcff333153ba77167589719cf33  r96_joltdet.gd
06d80e50ac6fadc2ef73e859ad3d60079d9d8312a15b987bd9887e5200692e15  r96_probe_iters.gd
762e11b47552aa41d633b957f8de16acd7846165a1beb540af4fd0ef38658857  r96_probe_pen.gd
4228f7aee4d68cb5138612992e40ddab3c016463b7660835c9098d93184bc47a  r96_probe_warm.gd
d6ce9067499c1c5f3b5156dab7adeb39bbf2b025b2d7d2e8359dbc4622e32568  r96_probe_damp.gd
1d7bd6e7e46139162fac418f0919f482bcf8df33ffbd9917272bffbdd5fba981  r96_probe_rest.gd
ddc50d993d0ca6e56903e1e122c0ac7b15d68dbf61444593fd4c7dd021e375c5  r96_probe_kin.gd
db3447f6a94c5094a97441893173ce1c5d9d1afe4836634ad5820e35f310ee82  r96_probe_srvjoint.gd
e190adff97ac1d80612f8b6e932959cc86b0b1f9687f397f8f7bb6876316556e  r96_probe_settings.gd
935ed912803e872506a834185cf57329468dfbe8a9be2dfcdc746594ca18297e  run_battery.py
```

Every probe sha **equals the matching `corpus/live/r96-scout/probes/*.gd`**
(recomputed) — the "byte-identical copies" claim holds at this HEAD.
`run_battery.py` `--numstat` = `30 0`: the 12 r96 tuples + a 6-line comment were
appended after `r95_bullet_neg_shm_rt`; no existing byte moved, so no other
round's row can be affected by the insertion.

### 1.2 Battery runs (12 r96 rows each, `--only r96_joltdet_*`)

| run | tree | load start→end | verdict | marker diffs vs ref1 | notes diffs |
|---|---|---|---|---|---|
| `ref1` | committed | 76.3→76.6 | **12/12 PASS** | *reference* | — |
| `ref2` | committed | 76.6→85.4 | 12/12 PASS | **0** | 1 (ffps) |
| `ref3` | committed | 85.4→85.5 | 12/12 PASS | **0** | 1 (ffps) |
| `probeA1` | probeA (−14) | 85.5→85.7 | 12/12 PASS | **0** | 1 (ffps) |
| `probeA2` | probeA (−14) | 85.7→82.6 | 12/12 PASS | **0** | 1 (ffps) |
| `probeB1` | probeB (−5 in probes) | 82.6→81.8 | 12/12 PASS | **0** | 1 (ffps) |
| `probeB2` | probeB (−5 in probes) | 81.8→82.9 | 12/12 PASS | **0** | 2 (ffps + nc) |
| `probeC1` | probeC (mutant) | 82.9→84.3 | **11/12** (mech red) | **1 cell** (mech/`pen_gp_pen`) | 2 |

`scripts/compare.py` compares, per case: the marker line (the battery's
contract), the `#` notes, stderr and the exit code.

```
reference: runs/ref1/…/verdicts.json  cases=12 seeds_unchanged=True verdict=PASS
compare runs/ref2/…    : markerDiff=0 noteDiff=1 stderrDiff=0 rcDiff=0
compare runs/ref3/…    : markerDiff=0 noteDiff=1 stderrDiff=0 rcDiff=0
compare runs/probeA1/… : markerDiff=0 noteDiff=1 stderrDiff=0 rcDiff=0
compare runs/probeA2/… : markerDiff=0 noteDiff=1 stderrDiff=0 rcDiff=0
compare runs/probeB1/… : markerDiff=0 noteDiff=1 stderrDiff=0 rcDiff=0
compare runs/probeB2/… : markerDiff=0 noteDiff=2 stderrDiff=0 rcDiff=0
compare runs/probeC1/… : markerDiff=1 noteDiff=2 stderrDiff=0 rcDiff=0
  cells moved (1): r96_joltdet_mech/pen_gp_pen
TOTAL marker/stderr/rc diffs: 1
```

So the 12 marker lines are byte-identical across all **7 non-mutant runs
(84/84)**, and probeC1's 11 non-mutated rows are byte-identical to ref1 as well
(**95/95** marker comparisons), all under load 76–86, with
`seeds_unchanged=true` in every run. No `rc` or stderr ever moved.

### 1.3 Receipt provenance — the author's own crosscheck, re-run

`corpus/live/r96-author/crosscheck.py` maps 93 fixture cells to the
r96-scout/r96-boundary receipts and compares the **child logs** the fixture left
in a battery scratch, normalized:

```
ref1    (committed)     crosscheck: match=93 missing=0 differing=0
probeA1 (parent −14)    crosscheck: match=93 missing=0 differing=0
probeB1 (probes −5)     crosscheck: match=93 missing=0 differing=0
```

This is stronger than the marker comparison for SP-5: the edited probe files
reproduce the *scout's own receipts* byte-for-byte, not just the fixture's
pinned shas.

### 1.4 The detection control is not vacuous (probeC)

probeC = committed + one authored constant in the `gp_pen` project bake
(`3d/solver/contact_max_allowed_penetration` `0.2 → 0.3`). Result: exactly one
cell moved and exactly one row reddened, mechanistically:

```
FAIL r96_joltdet_mech: exit=0 expected=0 reasons=['exact stdout marker missing']
PASS r96_joltdet mech pen_gp_pen{rc=0,sha=db0740bd5ded5180,sep_end=-0.3} …
  (committed: pen_gp_pen{…,sha=483778527811c9f2,sep_end=-0.200001})
```

All 11 other rows are byte-identical to ref1. The comparator therefore resolves
*which* cell moved, not just "stdout differs" — a "0 diffs" result from
probeA/probeB means what it says. (Note the fixture itself still prints `PASS`
for that arm: the knob mutation changes a pinned *value*, and the battery's
exact-marker check is the layer that catches it — the same structure as F-2.)

### 1.5 Run-variable surfaces (census, both documented as unpinned)

| run | ffps Jolt warning census | nc impulse zero-read census |
|---|---|---|
| ref1 / ref2 / ref3 | 3/6 / 2/6 / 2/6 | 0/324 / 0/324 / 0/324 |
| probeA1 / probeA2 | 2/6 / 3/6 | 0/324 / 0/324 |
| probeB1 / probeB2 | 3/6 / 3/6 | 0/324 / **39/324** |
| probeC1 | 3/6 | **39/324** |

The warning fired on 21/48 fixed-fps Jolt receipts here (the author measured
13/36) and the all-zero impulse class on 39/324 ticks in 2/8 runs (author:
39/324 in 3/6) — both reproduce as **variable and unpinned**. No pinned cell
ever moved with them — the ffps marker pins `norm_eq/ref_eq` and the sha; the nc
marker pins `pose_eq/pose_sha/y0/vmax` only. This is exactly the author's
disclosure, re-measured.

## 2. Census: what in the landing is dead

`scripts/census.py` (textual, no GDScript parser in this seat's toolset) and
`scripts/deadvars.py` (read/write census), outputs `census.txt` /
`deadvars.txt` / `cases-census.txt`:

- **Parent `r96_joltdet.gd`: 42 top-level declarations, zero unused.** Every
  const/var/func has ≥1 use outside its definition; no function-scope local is
  write-only.
- **`SUM_PREFIX` (8 keys) ↔ spec probes (8): exact.** Every key is used, no spec
  probe missing.
- **`PROJECTS` (25 bodies) ↔ spec bodies: exact.** All 25 project bakes are
  referenced; no dead bake.
- **`ARMS` (6 arms, 93 cells) + 6 special arms (30 cells) = 123 cells ↔ the 12
  battery rows: exact.** Every arm has a row, every row's arm is handled, no
  duplicate row name; the 12 rows spawn 160 children per pass.
- **Dead outputs (SP-1):** `"lk"` and `"pe"` occur exactly once each in the
  whole fixture (the return literal) — the leak/benign-block counters are
  written, returned, and never read. (The header's "censused in '#' diagnostics"
  is therefore wrong for them — F-3.)
- **Duplicated logic (SP-2/3/4, taken):** the `imp=` regex compile in `_run_nc`
  vs the member `_imp_re`; `_sum_line` vs `_line_with`; the `D0` prefix scan in
  `_run_dummy` vs `_line_with`.
- **Duplicated logic (not taken — line-neutral):** `_cell_text`'s pose-surface
  block and `_run_nc`'s pose extraction are the same 6-line operation
  (`W t=` filter + `imp=` strip + `_sha16`). A `_pose_sha(m)` helper would be
  **net 0 lines** (−4 in `_cell_text`, −2 in `_run_nc`, +6 for the helper), so
  it is not a YAGNI deletion; filed here only so the adjudicator knows it was
  seen (F-4, COSMETIC).
- **Probe copies: 4 files with 5 dead bindings (SP-5); 39 case arms handled,
  25 driven by the fixture, 14 extra.** The extra surface (`damp` lin05/ang10/
  grav10; `kin` static/anim/kinfreeze/kinstatic/kinmode; `pen` staticpen/rest;
  `rest` min/both/pair; `srvjoint` node_late) is the scout's standalone probe
  surface, kept because the copies must stay byte-identical to the scout
  sources. Not YAGNI-dead in this landing's terms; deleting the *cases* would
  break the byte-identity contract for no line win the fixture can observe.
- **`run_battery.py` insertion: 12 unique rows, insertion-only, all arms known.**
  The expected markers are exactly the committed outputs (re-derived by ref1).

## 3. Taken deletions — SP-1…SP-4 (−14 lines, 8 edits, parent only)

`scripts/apply_probeA.py` (each anchor asserted unique/counted, aborts
otherwise); diff `probes/probeA.diff` (−18/+4, net **−14**, 873 → 859);
sha256 of the edited fixture `74231148b72f18c06aa1d6e0ed8835c55fcaf75b9992cbb1d53862c9a116e7f3`.

| edit | Δ | what |
|---|---|---|
| SP-1 counters | −2 | `var lk := 0` / `var pe := 0` |
| SP-1 `pe` increment | −1 | the `!is_inside_tree()` skip keeps working |
| SP-1 `lk` increment | −1 | the leak-line skip keeps working |
| SP-1 return keys | −1 | `"lk": lk, "pe": pe` out of the dict |
| SP-2 local regex | −2 | `imp_re` compile deleted; call site uses `_imp_re` |
| SP-2 call site | 0 | `pose.append(_imp_re.sub(line, "", true))` |
| SP-3 `_sum_line` | −4 | body → `return _line_with(m, SUM_PREFIX.get(probe, ""))` |
| SP-4 `d0` scan | −3 | 4-line loop → `var d0 := _line_with(hang.get("m", []), "D0 case=sleep1") != ""` |

**Proof:** probeA1 + probeA2 = 12/12 rows PASS, marker lines byte-identical to
ref1 (0 diffs), stderr/rc identical, `seeds_unchanged=true`, **and** the
author's crosscheck 93/93 against the scout/boundary receipts. SP-2's call-site
rewrite is exercised by the `nc` row (4 reps); SP-3 by every row with pinned SUM
fields; SP-4 by the dummy hang cell; SP-1 by every row (the scanner runs on
every child).

## 4. SP-5 — dead bindings in four probe copies (−5 lines) — take-or-drop

`scripts/apply_probeB.py`; diff `probes/probeB.diff` (−10/+5, net **−5**, 4 files):

| file | dead binding | Δ |
|---|---|---|
| `r96_probe_damp.gd` | `prev` — declared, never touched | −1 |
| `r96_probe_pen.gd` | `floor_body` — assigned 3× from `mk_floor()` (which adds the body to the tree itself), never read | −1 (+3 rewrites) |
| `r96_probe_rest.gd` | `floor_body` (same, 1×) and `floor_body2` (never used) | −2 (+1 rewrite) |
| `r96_probe_warm.gd` | `if_tick` — assigned 1× in `on_if`, never read (the ordering comment it carried is kept) | −1 (+1 rewrite) |

**Proof:** probeB1 + probeB2 = 12/12 rows PASS with 0 marker diffs **and**
crosscheck 93/93 — the child receipts are byte-identical to the scout's even
after the deletions, i.e. the bindings are dead in the executed surface, not
just textually.

**Call: take-or-drop (weak).** The deletions are proven no-ops, but they change
4 of the 8 probe sha256s that `reports/round-96/r96-author.md` pins as
"fixture copy == scout source". The *receipts* (the actual contract) are
unaffected; the *file-level provenance table* would need a one-line update. The
adjudicator can take it or leave it — unlike SP-1…SP-4 it is not dead weight in
the parent, and the probe copies are deliberately frozen.

## 5. Findings (filed, not this seat's call)

### 5.1 F-1 (LOW) — the `nc` header law contradicts the cell it describes

`r96_joltdet.gd` lines 68–70:

```
#   nc       the nocache contact-identity cell, re-run as a small fixed-fps
#            batch, is rep-stable AND reads the real contact-0 impulse (the
#            boundary's all-zero read is batch-shape-conditional, unpinned).
```

The cell is **pose-only**: `_run_nc` pins `pose_eq`, `pose_sha`, `y0`, `vmax`
and only *censuses* the impulse readback in a `#` note. The code's own comment
(lines 839–844) says the readback "is not rep-stable: … can come back as the
all-zero sentinel or as a different contact's impulse", and the author's
correction #6 says the same. Measured here: the zero-read census moved (0/324
in 6 runs, 39/324 in 2) while the pinned `pose_sha` never moved (8/8). So the
header sentence describes the *boundary's* observation, not this cell's pin.

### 5.2 F-2 (LOW) — the scanner-class sentence is false for the plain-warning class (measured)

`r96_joltdet.gd` lines 19–20: "Anything else that lands on stderr/stdout (a
SCRIPT ERROR, an unexpected ERROR:, a new warning) fails the arm: the cell is
not printed as PASS."

Measured with three one-line injections into `r96_probe_iters.gd`
(`scripts/scanner_probe.sh`, receipt `scanner-probe.txt`):

| injected line | fixture's own line | battery row |
|---|---|---|
| `WARNING: injected non-allowlisted warning` | **`PASS r96_joltdet joint …`** — 8 `iters` cells' shas changed (`581274d6…`→`b1ea24f2…`, etc.), the 4 `srvjoint` cells unchanged (`95c47e9d…`, `58a3d94c…`) | `FAIL … reasons=['exact stdout marker missing']` |
| `ERROR: injected unexpected error line` | **`FAIL r96_joltdet joint …`** (shas unchanged — the line is routed to `ue`, not `m`) | `FAIL … ['exact stdout marker missing', 'unexpected diagnostic: # … ue=ERROR: injected…']` |
| `SCRIPT ERROR: injected` | **`FAIL r96_joltdet joint …`** (same routing) | `FAIL … ['exact stdout marker missing', 'SCRIPT ERROR on stdout', …]` |

All three rows also report `seeds_unchanged=true`.

A plain unknown `WARNING:` line has no rejection branch in `_scan_lines`; it
lands in the normalized `m` stream, so the cell stays ok and the arm still
prints PASS. Only the battery's exact-marker check (and the sha pin) catches it.
The sentence is right for the two ERROR classes and wrong for the warning class.
The labrat's static trace reached the same conclusion (it could not execute).

### 5.3 F-3 (LOW) — "censused in '#' diagnostics" overstates the dropped classes

`r96_joltdet.gd` lines 11–18 present the whole dropped set — banner/empty lines,
the Jolt warning, the leak notices, the `!is_inside_tree()` block — as "never
pinned, **censused in '#' diagnostics**". Only the Jolt warning is censused
(`w`/`wp` → the ffps note); the leak and benign-block drops were counted into
`lk`/`pe`, which no caller ever read (SP-1 removes them). After SP-1 the claim
is further from the code, though behaviour-neutral either way. If the counts
were meant to be a diagnostic, the fix is to *emit* them (a note), not to keep
the dead keys.

### 5.4 F-4 (COSMETIC) — duplicated pose extraction, line-neutral

`_cell_text`'s pose block and `_run_nc`'s pose loop are the same operation.
A `_pose_sha(m)` helper is **net 0 lines** (−4/−2/+6), so it is not filed as a
deletion — noted so the adjudicator can decide on clarity grounds if desired.

## 6. Limits / not done

- **No full 316-row battery was run by this seat.** The r96 landing is
  `--arm`-scoped: `r96_joltdet.gd` is named by exactly the 12 r96 rows, and
  `run_battery.py`'s change is insertion-only (`30 0`), so the narrow check
  (12 rows) covers the change. Four sibling lanes were running full batteries
  during this window (`r96-verifier`, `r96-critic`, `r96-scribe`, `r96-reviewer`);
  the full-battery evidence belongs to those seats.
- The 14 extra probe case arms (scout standalone surface) were not executed;
  they are unreachable from the fixture by construction.
- Receipt provenance depends on the gitignored `corpus/live/r96-scout` and
  `r96-boundary` trees; if those are lost, §1.3 is not re-runnable (the
  marker pins in §1.2 remain re-runnable).
- SP-5's provenance cost (4 probe sha256s) is a documentation change in
  `r96-author.md`, which this seat does not edit.

## 7. Commands (repro)

    # trees + edited fixtures
    bash corpus/live/r96-simplifier/scripts/prepare_trees.sh
    # one 12-row battery run (label, seed, runs-dir)
    bash corpus/live/r96-simplifier/scripts/run_all.sh ref1 corpus/fixtures \
         corpus/live/r96-simplifier/runs/ref1
    # the whole 8-run sequence used above
    bash corpus/live/r96-simplifier/scripts/run_sequence.sh
    # per-case marker/notes/stderr/rc comparison
    python3 corpus/live/r96-simplifier/scripts/compare.py \
        corpus/live/r96-simplifier/runs/ref1/*/verdicts.json <other>…
    # receipt provenance (the author's tool, unmodified)
    python3 corpus/live/r96-author/crosscheck.py <battery-run>/scratch
    # scanner-class probe (three injections)
    bash corpus/live/r96-simplifier/scripts/scanner_probe.sh

## 8. Receipts pointer

`corpus/live/r96-simplifier/` (gitignored): `census.txt`, `deadvars.txt`,
`cases-census.txt`, `notes-census.txt`, `ref1-markers.txt`,
`compare-refs-probeA.txt`, `compare-probeB-probeC.txt`,
`crosscheck-{ref1,probeA1,probeB1}.txt`, `scanner-probe.txt`,
`scanner-runs/{warn,err,script}/`, `{ref1,ref2,ref3,probeA1,probeA2,probeB1,probeB2,probeC1}.log`,
`runs/<label>/<ts>/verdicts.json` (+ scratch child receipts), `trees/` (throwaway
probe trees), `probes/probe{A,B,C}.diff` + the edited fixtures that ran,
`scripts/` (`census.py`, `deadvars.py`, `apply_probe{A,B,C}.py`,
`prepare_trees.sh`, `run_all.sh`, `run_sequence.sh`, `compare.py`,
`scanner_probe.sh`), `manifest.sha256`. Provenance: this lane wrote only
`reports/round-96/r96-simplifier.md` (tracked) and the `corpus/live/r96-simplifier/`
scratch; it did not touch any fixture, seed, or other round's receipts, and made
no commit.
