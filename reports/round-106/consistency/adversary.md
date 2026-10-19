# r106 SEAT-47 — CONSIST-ADVERSARY

**Question put to this seat:** argue dated-note fatigue (too many notes degrade
readability); deliver the ruling: when is a correction note wrong and a silent
fix right, with precedents.

- Host / lane: `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`, HEAD `0cc3f41`
- Probe date: **2026-10-18** (frame 1 `2026-10-18T21:22:08Z`; recount `2026-10-18T21:35:07Z`)
- Owned path: `reports/round-106/consistency/adversary.md` (only file this seat wrote)
- Label: `verified-here` = a command run on this host with the output pasted below.
- No Unreal runtime claim is made anywhere here. The editor is not installed, so
  live-MCP behavior stays `unproven-runtime`. Nothing here touches the plugin pin
  `a6aa73ada02a9fb1f5415bec491f9942c519b297`. This seat edited no corpus file.

---

## 0. Ruling (short form)

**The fatigue argument is ADOPTED as a placement and stacking rule, and REJECTED
as a license to stop dating factual corrections.** A silent fix is right only
when the edit changes no fact a later reader could check. Everything else keeps
the note — but the note lives in the round report, and the living file gets one
line, not a second essay.

| # | Ruling | Status |
|---|---|---|
| **S1** | A silent in-place fix is right, and a correction note is the wrong instrument, when the edit is **path/command conformance**, **spelling/markup**, or a **pointer-to-bytes typo whose only checkable fact is the pointer itself** — and the round report already records the before/after. | **ADOPTED.** Precedent: r102 F1, applied in place, explicitly "no dated correction note is required." |
| **S2** | A dated note is mandatory, and a silent fix is a defect, when the sentence was **true at its own revision** and is now false: a digest, a count, a census, a pass/fail, a "not installed." Rewriting it destroys the round's record. | **ADOPTED — unchanged from r102 law #4 and D1.** |
| **S3** | A note is the wrong *shape* — even when S2 says the fact must be preserved — when it is a **second note on the same claim**, or when it **restates a number the body already rewrote**. Cap: one dated note per claim per file. Further drift is a one-line continuation that cites the round report, or it belongs only in the round report. | **ADOPTED.** The current tree already violates this twice. |
| **S4** | A living operational file (`engines.md`, a how-to, a command block) does not accumulate notes. It carries the **current** value plus a one-line back-pointer. The essay, the old number, and the command that falsified it live in `reports/`. | **ADOPTED as the form for the r106 census refresh.** `engines.md` is 16 lines and has zero notes; do not make it the third `rea.md`. |
| **S5** | Fatigue is a per-file ratio and a replication rate, not a round count. Frame 21:22Z: 6 files, 14 hits, two files past 0.45 note-fraction. Frame 21:35Z: 14 files, 22 hits — eight copies of one path-root essay (exhibit E). Judge by bytes-in-the-file and by copies of the same paragraph. | **ADOPTED.** Measured in §2. |

The one-sentence test, applied before either instrument:

> **Would a reader who trusts the file and never opens git be told a different fact?**
> If yes, the old fact stays and a dated note (or a one-line pointer to one) is required.
> If no — the old bytes were a path that never resolved, a typo, or a pointer whose
> checkable content is unchanged — fix the bytes and record the edit in the round
> report. Do not also narrate it inside the file.

---

## 1. The precedents, both directions (quoted, then checked)

### 1.1 The law that forbids the silent factual rewrite — still in force

`corpus/lessons/r102-unreal-integration.md:206`:

> Repair by dated correction note, never by silent rewrite.

`corpus/lessons/r105-unreal-lifecycle.md:67-70` restates it as a lifecycle law, and
correctly: a historical sentence that was true at its revision is history. D1, the
rule that made that sentence load-bearing, is `reports/round-102/lesson-critic.md:426-429`:

> **D1 (blocking).** Replace "`grep -c 'shokunin/game-dev-3d'` now 0 in both r22
> files" with the per-file counts (0 and 1) and the note that the single
> occurrence is the correction note's quotation. Do not change the number to 1
> silently — the distinction is the finding.

D1 is not a style rule. The defect was that rewriting `0` to `1` in place would
erase the only evidence that the repair and the documentation of the repair are
different events. That distinction is still the reason S2 exists. This seat does
not weaken it.

### 1.2 The precedent that already authorizes the silent fix — and names it

`reports/round-102/repairs/F1b-F2-r22-lesson.md:45-51`, the seat that actually did it:

> ### Fix (mechanical conformance, applied in place)
>
> Dropped the `.shokunin/game-dev-3d/` prefix at all seven sites, making the paths
> repo-relative and consistent with the lesson's own framing. This is a
> command/path conformance fix, not a historical factual claim, so no dated
> correction note is required for it (a one-line provenance sentence was
> nevertheless added inside the F2 note below).

That is the ruling this seat was asked to write, already executed once and already
worded. Three properties made the silent edit right, and all three are checkable:

1. **The old bytes were never a fact.** `.shokunin/game-dev-3d/` has never existed
   in this repo. The BEFORE block in that same repair (`:32-42`) shows the command
   exiting 2 with `No such file or directory`. There is no revision at which the
   sentence was true.
2. **The edit changes resolution, not a claim.** The same verifier, the same
   fixture, the same expected accept/reject. AFTER exits 0 (`:58-65`).
3. **The round report holds the before/after.** The provenance did not need to
   live in the lesson. The one-line sentence that *was* added inside the F2 note
   is exactly the residue S3 now forbids repeating: it is why
   `grep -c 'shokunin/game-dev-3d'` still returns 1 in that lesson, which is the
   D1 finding. The note created the grep hit it then had to explain.

S1 is this precedent, stated as a rule rather than a one-off.

### 1.3 The second silent-fix precedent — r105, one line, no note, and it was right

`reports/round-105/kimi404/verify.md:28` records the r105 URL fold:

> the unified-zero diff shows exactly one replacement on line 6: the bare
> repository URL gains `-plugin`; `--numstat` is `1 1` … No other line moved.

`corpus/knowledge/unreal-mcp/adaptation-kimi.md:6` now reads the `-plugin` URL.
The r103 correction note below line 367 was **left untouched**. That is the right
split, and it is the split S1 describes:

- the old URL was a **pointer**, not a historical finding (it 404'd; the corrected
  URL 200'd — `kimi404/verify.md:14`);
- the checkable fact the row asserted (this is the Epic plugin repo, at the pin)
  did not change;
- the before/after, both status codes, and the `1 1` diff live in the round
  report, not in a fourth subsection of the r103 note.

A dated note inside `adaptation-kimi.md` saying "line 6 used to lack `-plugin`"
would have been the wrong instrument. The file is a citation table. The report is
the log.

### 1.4 The counter-example that shows why S2 still binds — the census sentence

`corpus/knowledge/rea.md:7-9` (mint text, preserved above the note):

> Provider readiness: native-provider install remains blocked
> (no Ghidra, JADX, Binwalk/Unblob, pwntools on this host — census as of
> mint).

That sentence was true at mint. It is now false for JADX, Binwalk, Unblob, and
pwntools (`corpus/knowledge/rea.md:36-46`). Silently rewriting "blocked" to
"present" would destroy the mint census — the only record of what the lane
believed when it scoped REA out. The note was the right instrument. S2 holds.
What is wrong about this file is not that the note exists. It is the **ratio**
(§2) and the fact that the note is an essay inside the reference rather than a
one-line pointer at a report that already holds the essay
(`reports/round-102/repairs/F6-rea-census.md`, cited by the note itself at `:34`).

---

## 2. The fatigue, measured (not asserted)

`verified-here`, 2026-10-18. Marker regex was
`correction note|pin correction|pin continuation|F3 correction` (case-insensitive).
Region sizes split the file at its first note heading.

```text
$ python3 - << 'PY'
# files, marker lines, and note-region byte fractions — output below
PY
```

Observed:

| file | lines | bytes | marker lines | note fraction of bytes |
|---|---:|---:|---|---:|
| `corpus/knowledge/rea.md` | 63 | 3343 | 29 | **0.585** (note 1955 B, body 1386 B) |
| `corpus/lessons/r22-unreal-review.md` | 83 | 11620 | 50, 59 | **0.489** (note 5677 B, body 5941 B) |
| `corpus/knowledge/unreal-mcp/adaptation-kimi.md` | 506 | 29983 | 367, 369 | 0.274 (note 8225 B, body 21756 B) |
| `corpus/knowledge/unreal-mcp/gate/README.md` | 461 | 29251 | 42, 258, 394, 435 | 0.164 from the pin-note heading; the body *also* narrates the same supersession |
| `corpus/knowledge/engines.md` | 16 | 2768 | none | 0 |
| `corpus/lessons/r102-unreal-integration.md` | 217 | 13743 | 201, 203, 206 | law statement, not a stacked repair |
| `corpus/lessons/r105-unreal-lifecycle.md` | 162 | 10415 | (quotes the law) | law statement, not a stacked repair |

```text
$ rg -c -i 'correction note|pin correction|pin continuation|F3 correction' corpus --glob '*.md'
# frame 1, 2026-10-18T21:22Z — six files, 4+3+2+2+2+1 = 14 hits
corpus/knowledge/unreal-mcp/gate/README.md:4
corpus/lessons/r102-unreal-integration.md:3
corpus/lessons/r105-unreal-lifecycle.md:2
corpus/knowledge/unreal-mcp/adaptation-kimi.md:2
corpus/lessons/r22-unreal-review.md:2
corpus/knowledge/rea.md:1
```

Frame 1 is not a corpus-wide pile. A ruling that said "stop writing notes, there
are too many" would have been answering a problem that frame did not have. The
problem that frame did have is local. The recount thirteen minutes later is a
different problem, and it is the one this round is creating — exhibit E below.

**Fatigue exhibit A — the note outweighs the record.** `rea.md` is a 28-line
reference with a 35-line correction under it. A reader who opens the file for the
authorized-use rules reads the stale census first and the correction second. The
note is 58.5% of the file. That is the readability failure, and it arrived at
note count = 1. Fatigue is a ratio, not a count.

**Fatigue exhibit B — two notes, one claim, one round.** `r22-unreal-review.md:50`
is the r102 correction note. Nine lines later, `:59` is `## F3 correction —
2026-10-18 (r102)`, which opens by admitting the redundancy:

> Appended by r102 SEAT-09 (F3 repair). Deliberately narrow in scope: the sibling
> note above already tabulates the drifted digests and their current values, and
> this seat independently confirms every value in it.

The second note's only new claim is the pass count (29 vs 350), which the first
note already states at `:55` ("`run_battery.py` now defines 350 cases (not 29)").
Two seats each did the disciplined thing — append, don't rewrite — and the file
got two essays confirming each other. S3 exists because discipline-per-seat
composes into unreadability-per-file. The receipt for the confirmation belonged
in `reports/round-102/`, which is where SEAT-09's evidence already was.

**Fatigue exhibit C — the note restates a number the body already changed.**
`corpus/knowledge/unreal-mcp/gate/README.md` carries the current pin in the body
(`:42` says `POINTERS=103`; `:248` and `:271` print `POINTERS=103`) **and** a
48-line pin correction note (`:394-441`) whose job is to explain that `87` became
`101` became `103`. The `87` no longer appears as a live expected value anywhere
in the file — only inside the note that supersedes it. The note is a changelog
sitting under the current value. A reader who wants the pin reads `:248`. A reader
who wants the history should be in `reports/round-103/note/gate-pin.md` and
`reports/round-104/gate/workdir.md`, both of which the note already cites.

The same file also shows the cost the r103 adversary measured and this seat does
not re-litigate: a backtick path inside the swept subtree moves `POINTERS`
(`reports/round-103/note/adversary.md` §3; the gate README's own warning at
`:258`). Every extra sentence of in-subtree narration is a gate input. That is a
second, mechanical reason the essay belongs in `reports/` and the subtree file
gets a pointer.

**Fatigue exhibit D — a note that cites a moving target is stale on arrival.**
`adaptation-kimi.md:411` gives the corrected citation as "line 3290 as of
2026-10-18." Re-measured this seat, same calendar day:

```text
$ grep -n '\[\[hooks\]\]' ~/.kimi-code/config.toml
3149:[[hooks]]
$ wc -l ~/.kimi-code/config.toml
3181 /home/vgpnk/.kimi-code/config.toml
```

r101 said 2932, r102 said 3219, r103 said 3290, and at `2026-10-18T21:22Z` the
block is at **3149** in a file of 3181 lines. The note's own warning ("a moving
target — locate it with `grep`") is the part that survived; the number it was
written to publish did not survive the day. This is the strongest case in the
tree for S4's one-line form: a living file should carry the **locator command**,
not a line number that a note will have to re-correct next round. Writing a
second note ("3290 is now 3149") would be the fatigue the question asks about,
and it would be false again by the next edit to `config.toml`.

**Fatigue exhibit E — the replication, measured while this note was open.**
Frame 1 above is not the tree this ruling closes against. At `2026-10-18T21:35:07Z`
the same marker command returned **14 files, 22 hits**. The eight new files are
`corpus/lessons/r61-stream-review.md` through `r68-ray-layers-review.md`, each
with count 1, each a blockquote headed `Correction note (r106, 2026-10-18) —
path root only.`

```text
$ date -u +%Y-%m-%dT%H:%M:%SZ
2026-10-18T21:35:07Z
$ rg -l 'Correction note \(r106' corpus --glob '*.md' | wc -l
8
$ rg -c -i 'correction note|pin correction|pin continuation|F3 correction' corpus --glob '*.md'
# 14 files; the eight new rows are r61–r68, each :1; the frame-1 six are unchanged
```

What those notes do, read on `r68-ray-layers-review.md:27` and the same shape on
the other seven:

1. They label themselves a mechanical conformance fix — the S1 case, for which
   r102 already ruled "no dated correction note is required"
   (`reports/round-102/repairs/F1b-F2-r22-lesson.md:45-51`).
2. They quote `.shokunin/game-dev-3d/` back into a file whose commands no longer
   use it. In all eight files the only remaining hits of that prefix are on the
   note line (`r61` quotes it three times, `r62` twice, `r63`–`r68` once). That
   is the D1 grep trap, reproduced eight times in one round: a bare
   `grep shokunin/game-dev-3d` cannot tell "fixed" from "fixed and documented."
3. They are the same essay eight times. A reader of r61 through r68 reads the
   path-root paragraph, the node `v26.12.0` clause, and the gitignored-receipt
   clause once per file. Fatigue here is not age. It is copies.
4. The note's evidence pointer, `reports/round-106/sweep/chunk-05.md`, was
   **absent** at this probe. `reports/round-106/sweep/` contained
   `province-audit.md`, `hygiene.md`, and `chunk-13.md` only. A note that cites
   a sibling file which does not exist yet is the r103 gate-flip mechanism
   (`reports/round-103/note/adversary.md` §3) pointed at lessons instead of the
   subtree. These files sit outside `$SUB`, so they do not move `POINTERS`;
   they still fail a citation sweep until that path lands.

The notes are not pure S1 waste. Buried in the same line is real S2 content:
r66's `6/6` is the r66 record and the current runner is `9/9`; cited
`corpus/live/` receipts are gitignored and absent; the review recorded node
`v26.11.1` and the re-probe saw `v26.12.0`. Those facts must not be silently
deleted. They also must not be copied into eight files. The right shape, which
this round has already missed, was: silent re-root (S1), one report holding the
before/after and the count/receipt drift, and at most a one-line pointer in
each lesson. Eight essays is the fatigue argument, demonstrated rather than
predicted.

This seat does not edit those files. They are another seat's chunk. Deleting
the notes now would be a silent rewrite of a mixed S1/S2 record. The ruling for
them is in §5: do not add a ninth, and do not "correct the correction" with a
second heading.

---

## 3. The test, applied to the three r106 claim classes

This seat rules the instrument. It does not apply it — every corpus path below is
another seat's chunk.

### 3.1 C1 — citation sweep, path and command resolution

| Defect shape | Instrument | Why |
|---|---|---|
| Path prefix that never resolved (the F1 shape: a root that `ls` cannot find at any commit) | **Silent fix.** Record before/after in the round report. | S1. Precedent `F1b-F2-r22-lesson.md:45-51`. A note inside the file re-introduces the dead string and recreates the D1 grep trap. |
| Command missing a required prefix (`npm ci --prefix` before `node …`) where the command as written exits non-zero on a clean tree | **Silent fix of the command block**, plus one line in the report. | The command block is an instrument, not a historical finding. `engines.md:11` already did exactly this in r102 (the cell now contains `npm ci --prefix corpus/fixtures/three && node …`) and did not grow a note. That edit is the precedent; it is also why `engines.md` is still 16 lines. |
| A quoted digest, count, or pass/fail that was true at the cited revision and is false now | **Dated note, not a silent fix.** | S2. D1. Rewriting the number deletes the round's record. |
| The same claim already has a dated note in this file | **Do not add another.** One-line continuation, or report-only. | S3. The r22 double note is the precedent for what not to do. |

### 3.2 C2 — `engines.md` census refresh (the file this ruling is for)

`engines.md` is the file S4 was written against. It is 16 lines, 2768 bytes, zero
notes, and its own header says "Update this file whenever a tooling probe lands"
(`:3-4`). That header is an instruction to **edit the row**, not to append an
essay. The r105 two-state environment model collides with the three.js cell as
written:

```text
$ command -v node; node --version
/home/vgpnk/.local/share/mise/installs/node/latest/bin/node
v26.12.0
$ /home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node --version
v24.21.0
```

The cell still says `Node v26.11.1` (`engines.md:11`). That version string is a
host-probe claim, and it is stale — but it is not a historical finding the way
the r22 `29/29` is. Nobody cites `v26.11.1` as evidence of a round. The census
file's job, per its own header and per its own row-move rule (`:13-16`), is to
say what is true **now**.

**Ruled form for the census seat (not applied here):**

1. Replace the version string in the cell with the two-state fact: default
   `node` is mise `v26.12.0`; pinned `v24.21.0` is the fnm path above. Name both
   as probe results with the date. Do not append a "Correction note" under the
   table.
2. One back-pointer line in the notes column or under the table:
   `r105 two-state re-probe: reports/round-105/n24/ ; r106 census receipt: <the census seat's report>`.
3. The old `v26.11.1` string, the command that observed it, and the command that
   falsified it belong in that r106 receipt — not in `engines.md`.
4. Do **not** move the Unreal or Unity status cells. Both still read
   `installed: no / executable headless: no` (`:9-10`). This seat re-confirms no
   editor probe was run here; absence is not a license to touch those cells
   (`engines.md:13-16` — a row moves only with a saved receipt and a non-author
   verifier, and none exists).

A note under `engines.md` would be wrong for a reason the other files do not
share: the file is the census, not the archive. Its readers are future probe
seats who need the current command. A 35-line note under a 4-row table (the
`rea.md` ratio) would make the next probe seat quote the note instead of the
row — which is how `POINTERS=87` survived in prose after the body had moved on.

### 3.3 C3 — lesson numeric and digest consistency

| Shape | Instrument |
|---|---|
| Quoted sha that still matches the tree | No edit. No note. |
| Quoted sha that matches a named historical blob (`git show <rev>:` reproduces it) and the lesson presents it as that revision's record | **Leave it.** If a later sentence implies it is current, add **one** dated clause, and only if the file does not already have a note covering that sha. |
| Quoted sha presented as current that matches nothing (`git show` and the worktree both miss) | **Dated note.** S2. This is the r22 `a806b9e4…` case: the digest survives only as text, and silently deleting it deletes the only record that the receipt was ever claimed. |
| A lesson that already carries a note covering the drift, and a new seat has re-derived the same numbers | **Report-only.** Cite the existing note. Do not append "F4 correction" under "F3 correction." The r22 file is the worked example of why. |

`run_battery.py` sha, re-derived this seat because C3 seats will quote it:

```text
$ sha256sum corpus/fixtures/run_battery.py
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f
```

That matches the r105 consistency seat's re-derivation
(`reports/round-105/consistency.md` r101 R3 row) and the r22 note's "tree now"
value (`r22-unreal-review.md:53`). It is current. A lesson that quotes it as
current needs nothing. A lesson that quotes `a065a56d…` as current needs a note
if it lacks one, and needs nothing further if it already has the r22 note.

---

## 4. What this ruling refuses

1. **It refuses a blanket "notes are noise, edit in place."** That reading of the
   fatigue argument would repeal law #4 and D1. The r22 receipt digest and the
   rea.md mint census are facts a silent rewrite would destroy. S2 is not
   optional and not soft.
2. **It refuses a blanket "always append."** That reading is how the r22 lesson
   grew two notes for one claim in one round, and how a gate README ended up
   explaining a number its body no longer uses. Append-only is the right
   constraint on **historical sentences**. It is the wrong constraint on
   **commands, paths, and current-value cells**.
3. **It refuses a new note whose only content is a line number in a file the
   operator edits.** `config.toml`'s `[[hooks]]` block moved 3290 → 3149 between
   the r103 note and this probe, on the same date the note was written. The
   durable citation is the locator (`grep -n '\[\[hooks\]\]'`), which the r103
   note already gives. A fresh note publishing 3149 would be false on the same
   terms, possibly before the round closes.
4. **It refuses to treat fatigue as a license to stop S2 notes.** The 21:22Z
   frame was six files and fourteen hits. The 21:35Z recount is fourteen files
   and twenty-two hits, because one seat copied one path-root essay into eight
   lessons (exhibit E). That is a replication defect, not evidence that digests
   and censuses should be rewritten in place. `engines.md`, `PROVENANCE.md`, and
   the subtree README still carry no correction note. Treat the copies. Do not
   mint a policy that makes the next real factual correction harder to land.

---

## 5. Apply this way (for the seats landing r106 edits)

Before editing a corpus file, write down which row of §3 the defect is. Then:

- **S1 row** — edit the bytes. Put the BEFORE command and the AFTER command in
  the round report. Do not add a correction note. If a one-line provenance
  sentence seems necessary, it goes in the report, not in the file: the r22
  one-liner is why `grep` still finds a path that no command uses.
- **S2 row** — do not edit the historical sentence. If the file has no note for
  that claim, append one dated note with the new command and its output, or
  (preferred when the essay is long, as `rea.md` now shows) append two lines —
  the date, the direction of the drift, and the report path that holds the
  commands — and keep the essay in `reports/`.
- **S3 row** — the file already has a note for this claim. Stop. Add the
  re-derivation to the round report and, at most, one clause on the existing
  note ("re-confirmed r106, receipt `<path>`"). A second heading is a defect
  even when every word in it is true.
- **S4 row** (`engines.md` and any file whose header says to update it) — edit
  the cell to the current probed value, leave a one-line back-pointer, put the
  history in the report. Do not create the file's first correction note for a
  current-value refresh.

**Already landed, do not stack on it.** Eight `Correction note (r106) — path
root only` blockquotes are in `corpus/lessons/r61-stream-review.md` through
`r68-ray-layers-review.md` (exhibit E, counted at 21:35Z). They are another
seat's bytes. This ruling does not delete them: each line mixes an S1
path-root narration (wrong instrument) with S2 facts (runner count drift,
gitignored receipts absent, node `v26.11.1` recorded vs `v26.12.0` re-probed),
and deleting the line would silently drop the S2 facts. Do not add a second
heading to "fix" them. If a later round touches one of these files, the
allowed collapse is: drop the path-root sentence once the sweep report holds
the before/after, and leave at most one clause for the count/receipt drift
pointing at that report. Until `reports/round-106/sweep/chunk-05.md` exists,
that pointer is unresolved — it was absent at 21:35Z, when `sweep/` held only
`province-audit.md`, `hygiene.md`, and `chunk-13.md`.

No axis of the lane moves by picking the wrong instrument: a silent factual
rewrite harms calibration, and a note on a command block harms coverage (the
next reader copies the dead command, or copies the note's quotation of it).
Both failure modes are already in the tree. The test in §0 separates them.
