# F1b + F2 — r22 lesson path-root and non-resolvable-receipt repair

- Seat: SEAT-08 REPAIR (owned path: `corpus/lessons/r22-unreal-review.md` only)
- Round: r102, date 2026-10-18
- Repo: `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`, HEAD `2c99b7b` (work commit `1659c036`)
- Lesson after repair: SHA-256 `03e879f0fbb4056ecc5cba83536c659c5680fe1ea9b3774bccb3f6806090a7cf`
  (final state, after the battery caveat bullet was added)
- Files written by this seat: `corpus/lessons/r22-unreal-review.md`,
  `reports/round-102/repairs/F1b-F2-r22-lesson.md`
- Not touched: `corpus/knowledge/unreal-mcp/**` (byte-pinned r101 subtree, incl. `upstream/` and
  `.manifest.d`), `LOG.md`, `SCORECARD.md`, `SHONEN.md`, `PROVINCE.md`, `reports/round-101/**`,
  any other seat's file. No git commit/push/checkout/reset was run.
- No Unreal runtime claim is made anywhere in this repair: the editor is not installed and
  live-MCP behavior remains unproven by construction.

---

## F1 — `.shokunin/game-dev-3d/` path roots never existed

### Defect

`corpus/lessons/r22-unreal-review.md` rooted every cited path at `.shokunin/game-dev-3d/`, a
directory that has never existed in this repo. The real repo root is `game-dev-3d-shokunin/`
(cwd), so the same targets are repo-relative without that prefix. Seven occurrences, on lines
7, 23, 25, 29, 42, 44 and 48 of the r22 file (the F1a sibling report at
`reports/round-102/repairs/F1a-r22-readme.md` fixed the identical defect in the artifact README
and explicitly left the lesson for this seat).

### BEFORE (fail) — run from repo root

```
$ python3 .shokunin/game-dev-3d/corpus/artifacts/unreal-r22/verify_descriptor.py
python3: can't open file '/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/.shokunin/game-dev-3d/corpus/artifacts/unreal-r22/verify_descriptor.py': [Errno 2] No such file or directory
exit=2

$ python3 .shokunin/game-dev-3d/corpus/artifacts/unreal-r22/verify_descriptor.py .shokunin/game-dev-3d/corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin --expect-reject
python3: can't open file '/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/.shokunin/game-dev-3d/corpus/artifacts/unreal-r22/verify_descriptor.py': [Errno 2] No such file or directory
exit=2

$ ls -d .shokunin
ls: cannot access '.shokunin': No such file or directory
exit=2
```

### Fix (mechanical conformance, applied in place)

Dropped the `.shokunin/game-dev-3d/` prefix at all seven sites, making the paths repo-relative
and consistent with the lesson's own framing. This is a command/path conformance fix, not a
historical factual claim, so no dated correction note is required for it (a one-line provenance
sentence was nevertheless added inside the F2 note below). Nothing else in the file was
reworded by this step.

### AFTER — the four commands the lesson documents, re-run from repo root

Three of the four pass (the Godot battery is treated separately below):

```
$ python3 corpus/artifacts/unreal-r22/verify_descriptor.py
PASS local-static actual=accept expected=accept path=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/artifacts/unreal-r22/Headless3DFixture.uplugin reason=one fixed-scope Unreal-style Runtime module descriptor (local static JSON)
exit=0

$ python3 corpus/artifacts/unreal-r22/verify_descriptor.py corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin --expect-reject
PASS local-static actual=reject expected=reject path=corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin reason=unsupported module Type: 'Unknown'
exit=0

$ node corpus/fixtures/three/run_cases.mjs
PASS positive: exit=0 expected=0
PASS negative_wrong_order: exit=2 expected=2
PASS mutation: exit=1 expected=1
PASS three battery: 3/3, seeds_unchanged=true
exit=0

$ node corpus/fixtures/three/scene_graph.mjs
PASS three3d scene_graph world=-1.000,0.000,0.000 parent_intact=true reverse_rejected=true
exit=0
```

The positive/negative pair still discriminates (accept vs reject on the `Type: Unknown` variant).

### Residual scan

```
$ grep -n "shokunin/game-dev-3d" corpus/lessons/r22-unreal-review.md
55:> The two command blocks in this lesson were re-rooted in r102 from a never-existent `.shokunin/game-dev-3d/` prefix ...
grep-exit=0
```

The only remaining hit is the provenance sentence inside the correction note; no command or
cited path carries the bad root any more. Before the fix the same scan returned 7 hits.

---

## F2 — cited Godot receipt is absent, gitignored, and never tracked

### Defect

`corpus/lessons/r22-unreal-review.md:48` (unchanged line number after repair) cites:

> Godot receipt `corpus/live/runs/20261013T053632289732Z/verdicts.json`, SHA-256 `a806b9e4…3d8fc`

### BEFORE (fail)

```
$ ls corpus/live/runs/20261013T053632289732Z/verdicts.json
ls: cannot access 'corpus/live/runs/20261013T053632289732Z/verdicts.json': No such file or directory
exit=2

$ git check-ignore -v corpus/live/runs/20261013T053632289732Z/verdicts.json
corpus/.gitignore:1:live/	corpus/live/runs/20261013T053632289732Z/verdicts.json
```

`corpus/.gitignore:1` is `live/`, so the whole `corpus/live/` tree is untrackable. History and
disk were checked for any surviving copy:

```
$ git ls-files corpus/live                 # exit=0, no output — nothing tracked, ever
$ git log --all --oneline -- corpus/live/runs/20261013T053632289732Z/verdicts.json   # exit=0, no output
$ git log --all --oneline -- corpus/live   # exit=0, no output
$ git log --all --diff-filter=A --name-only --pretty=format: | grep -c "^corpus/live"
0
$ git ls-files -z | xargs -0 sha256sum | grep -i "^a806b9e4"     # exit=1, no match
$ git log --all --oneline -S "a806b9e4d2928ac2c01ba463804ad55f7e14086b72d7846a458f91e271e3d8fc"
8b21cae game-dev-3d r22: verify Unreal-style static descriptor
$ find . -name verdicts.json -not -path './.git/*'    # no output
$ find /home/vgpnk -maxdepth 8 -name 20261013T053632289732Z 2>/dev/null   # no hits
```

So the digest text was **written into the r22 lesson by the r22 commit** (`8b21cae`) — it is a
citation of a run receipt, not a copy of one — and no blob with that digest exists in any ref or
anywhere on this machine. The digest survives only as text, in this lesson and in
`reports/round-101/r101-critic-c3.md:181`. It is uncheckable by construction.

### Fix — correction-note discipline (historical line kept verbatim)

The r22 sentence is a historical factual claim and was **not** rewritten. A dated, block-quoted
correction note was appended directly beneath it (lesson lines 50–55). The note:

- states that `corpus/live/…/verdicts.json` is a non-resolvable live receipt, why (gitignored
  `live/`, never tracked, absent from tree and machine), and that a fresh battery run writes a
  *new* timestamped receipt with a *different* digest — so the r22 number cannot be re-derived;
- names where the digest does survive: text only, in this lesson and
  `reports/round-101/r101-critic-c3.md:181`, and nowhere as a file;
- records the same class for the other stale digests on that line (see below);
- notes the r102 path re-rooting as a provenance line.

### AFTER (pass)

```
$ grep -c "a806b9e4d2928ac2c01ba463804ad55f7e14086b72d7846a458f91e271e3d8fc" corpus/lessons/r22-unreal-review.md
2                                  # historical line + correction note — claim preserved
$ grep -c "Correction note (r102, 2026-10-18)" corpus/lessons/r22-unreal-review.md
1
$ grep -c "r101-critic-c3.md:181" corpus/lessons/r22-unreal-review.md
1                                  # surviving-location pointer present
```

---

## Adjacent staleness found while verifying (folded into the same note)

Verification of the note's own claims exposed three more digests on the same line and one in the
table above it. All are recorded in the note; none of them was silently rewritten.

| Cited value (r22) | Status today | Evidence |
|---|---|---|
| `run_battery.py` seed `a065a56d…` | history-only (r21/r22 blob) | tree `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`; `git show 490e710d\|8b21cae\|7804a69:corpus/fixtures/run_battery.py` → `a065a56d…` |
| `run_cases.mjs` runner `f9f40d47…` | history-only (r21/r22 blob) | tree `97eca1b2e26db106e5ab7efe71767b533d99abdc1ee9ff80156ac402e11458e5`; same three commits → `f9f40d47…` |
| `scene_graph.mjs` `e4bb0a13…` | reproduces | `sha256sum corpus/fixtures/three/scene_graph.mjs` |
| `package-lock.json` `1a8e6ee2…` | reproduces | `sha256sum corpus/fixtures/three/package-lock.json` |
| table row `Headless3DFixture.uplugin` / `.bad-type.uplugin` / `verify_descriptor.py` | reproduce exactly | `2543b337…`, `b56a356e…`, `ce07e9d5…` |
| table row `README.md` (1460 B, `26a12604…`) | shifted by the sibling F1a repair | now 1394 B, `1c0d30355b34a76dc45ff27e9e684e9fe9595973e09bbc48519ad3618fea574b`; `git show 8b21cae:corpus/artifacts/unreal-r22/README.md` → `26a12604…` |

Note on scope: the F1a README repair changed only two command lines, but that necessarily moved
the README's byte count and digest, which the r22 table pins. The lesson's `README.md` row is a
historical pin, so the note states the r22 value, the current value, and the cause — rather than
editing the table.

## Godot battery re-run (the lesson's fourth evidence command)

`python3 corpus/fixtures/run_battery.py` re-run from repo root at r102. Two independent findings:

1. **The documented case count is stale.** The lesson says `29/29 PASS (14 ordinary, 15
   negative)`. The current fixture defines **350** case entries (counted from `CASES = [...]` in
   `corpus/fixtures/run_battery.py`, a 346,248-byte file; the r22-era blob was 34,239 bytes).
   The r22 number describes the r22-era battery, not today's.
2. **A green 350-case run was not achieved under this machine's load.** With load average ~15
   (multiple r102 seats running batteries concurrently), one case failed on its own 20-second
   wall bound:

```
$ grep -n "^FAIL" /tmp/r102-seat08-battery.txt
222:FAIL phys3d_joints_free_ops: exit=None expected=0 reasons=['TIMEOUT after 20 seconds', 'no exit code (process killed or timed out)', 'exact stdout marker missing']
```

Final outcome of this r102 re-run:

```
$ python3 corpus/fixtures/run_battery.py
totals: cases=350 pass=335 fail=15 ordinary=291 negative_controls=59 probes=0
FAIL battery: /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/runs/20261018T174432492194Z/verdicts.json
exit=1
```

`seeds_unchanged: true` (the fixture tree was not mutated). The 15 failures split into three
groups, each with a mechanism read out of the run's own receipt:

1. **13 × `r94_cannon_*` — Node version drift, not a physics regression.** The r94 markers pin
   `node=v24.21.0`; this machine now runs `node v26.12.0`
   (`node --version` → `v26.12.0`, from mise `latest`). Every one of the 13 cases shows
   `node_seen=['node=v26.12.0']` with reason `exact stdout marker missing`, and their stdout
   otherwise matches the expected shape (e.g. `r94_cannon_det` still prints
   `engine=cannon-es-0.20.0+three-0.186.1`, `eq=true` rebuild equality and the `det_ulp` 1e-9
   perturbation discriminator). This is a **portability defect in `run_battery.py`'s marker
   table** (a version-pinned string), not an r22 claim and not this seat's file.
2. **1 × `phys3d_joints_free_ops` — wall-clock timeout under load.** `exit=None`,
   reasons `['TIMEOUT after 20 seconds', ...]`, while load average was ~15 with several r102
   seats running batteries concurrently. Load-sensitive, in a case that did not exist at r22.
3. **1 × `r98_gltflat_doc` — marker missing plus six unexpected `ERROR: Can't open file at path
   "UD/R98Scout/tri.glb"` / `"user://tri.glb"` diagnostics** from the `doc_abs@*` / `doc_user@*`
   sub-arms.

This is reported as observed, not as a regression verdict: none of the three groups is caused by
this seat's edits (the seat touched only a Markdown lesson, and `seeds_unchanged=true`), and no
r22 claim is affected by them. It does mean the lesson's "exit 0, 29/29 PASS" line is a historical
r22 record and must not be read as a statement about today's 350-case battery. Items 1 and 3 are
routed to the L1 as **new findings outside this seat's ownership** (`corpus/fixtures/run_battery.py`
is not writable by SEAT-08), not repaired here.

---

## Concurrent write to the same file (SEAT-09)

While this seat was working, SEAT-09 appended a separate `## F3 correction — 2026-10-18 (r102)`
section at the end of `corpus/lessons/r22-unreal-review.md`. Both seats' edits are present and
mutually consistent in the final file (the sibling section confirms every digest value in this
seat's note, and independently counts `CASES` = 29 at `8b21cae` vs 350 today). This seat did not
touch that section and did not rewrite it. Two consequences for the record:

- The lesson file is now 83 lines and hashes to
  `03e879f0fbb4056ecc5cba83536c659c5680fe1ea9b3774bccb3f6806090a7cf`; that digest covers both
  seats' text, so it must not be used to attribute content to SEAT-08 alone.
- The F3 section covers the stale pass count from the history angle (29 rows at `8b21cae`); this
  seat's bullet covers it from the execution angle (a 350-case re-run that exits 1). The two are
  complementary, not contradictory — SEAT-09's `350` matches this seat's count exactly.

## Per-axis effect (this seat only)

- **coverage** — the two routed lesson defects are closed and re-verified by command: the three
  non-battery documented commands now exit 0 from a clean invocation (the battery command is
  reported honestly as exit 1, with its three failure groups attributed), and the one unresolvable
  citation is now explicitly labelled unresolvable with its surviving text locations named. No new
  capability or artifact is added.
- **depth** — no new behavioral claim; the Unreal static descriptor work is untouched and no
  Unreal runtime claim is made (editor not installed).
- **calibration** — improved for this file: three digest classes (tree-reproducible, history-only,
  non-resolvable) are now distinguished in place, so a reader can tell which numbers to expect to
  reproduce from a clone. No axis is harmed.

## Reproduce

```
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
grep -n "shokunin/game-dev-3d" corpus/lessons/r22-unreal-review.md
python3 corpus/artifacts/unreal-r22/verify_descriptor.py                                              # exit=0
python3 corpus/artifacts/unreal-r22/verify_descriptor.py corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin --expect-reject   # exit=0
node corpus/fixtures/three/run_cases.mjs                                                              # exit=0, 3/3
node corpus/fixtures/three/scene_graph.mjs                                                            # exit=0
ls corpus/live/runs/20261013T053632289732Z/verdicts.json                                              # exit=2
git check-ignore -v corpus/live/runs/20261013T053632289732Z/verdicts.json
git log --all --oneline -- corpus/live/runs/20261013T053632289732Z/verdicts.json                      # no output
git ls-files -z | xargs -0 sha256sum | grep -i "^a806b9e4"                                            # exit=1
```
