# SEAT-27 ENGINES-VERIFY — r102 independent verification of the engines.md rows and the r101 unreal-mcp subtree

**Seat:** SEAT-27 ENGINES-VERIFY · round 102 · lane `game-dev-3d-shokunin`
**Date:** 2026-10-18
**Lane HEAD at run time:** `2c99b7b8155841617d844c609813afcba77aa207` (r101 report-last; work commit `1659c036`)
**Working dir:** `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`
**Owned write path:** this file only. No other path was modified by this seat.

This seat is a **verifier, not an author**. It ran, on this host, (a) every command
in the updated `corpus/knowledge/engines.md` rows that is executable here, (b) the
sha256 sweep of the byte-pinned r101 subtree, and (c) the host probes behind the
`installed` / `executable headless` state columns. It re-ran the gate and its
documented negative controls independently. Every verdict below carries the command
that produced it and the output observed.

**No Unreal runtime claim is made or implied anywhere in this file.** Unreal Editor
is not installed on this host; the live-MCP path is unproven by construction.

**File identities at verification time** (these are the bytes this report judges):

```
$ sha256sum corpus/knowledge/engines.md
d03907d3d63771c10558a2bc276d62c50bcdea1d02150d78e6d1a720a0c3bddf  corpus/knowledge/engines.md
```

`engines.md` was already in its repaired r102 state at first read (mtime
`2026-10-18 14:42:49 -0300`) and its sha256 did not change across the whole
verification run — re-checked after the last command in §2 and identical, so the
rows judged here are the rows that were on disk when the report was written.

---

## 0. Verdict summary

| # | claim under test | verdict | key observed signal |
|---|---|---|---|
| 1 | `engines.md` three.js row evidence command is reproducible from a clean tree | **CONFIRMED (fixed)** | `npm ci --prefix … && node …` → exit 0, 3/3; the pre-fix bare form → exit 1 |
| 2 | `engines.md` Unreal row evidence is real and cwd-safe | **PARTIAL — command is cwd-dependent** | `sha256sum -c …` → rc=0 from the subtree, **rc=1 from the repo root** |
| 3 | `engines.md` Godot row (`yes` / `yes`) | **CONFIRMED** | `/usr/bin/godot` present, `4.7.2.stable.arch_linux.ed1daf0bf`, battery exit 0 |
| 4 | `engines.md` Unity row (`no` / `no`) | **CONFIRMED, no state move** | no `unity`/`unityhub` on `PATH`; no editor dirs |
| 5 | `engines.md` Unreal row (`no` / `no`) | **CONFIRMED, no state move** | no `UnrealEditor`/`UnrealBuildTool`; no editor dirs; 0 listeners on `:8000` |
| 6 | sha256 sweep of `corpus/knowledge/unreal-mcp/` | **PASS** | 12/12 `OK`, 0 `FAILED`, exit 0; independent fresh clone matches 12/12 blobs |
| 7 | gate `corpus/knowledge/unreal-mcp/gate/run_gate.sh` | **PASS, cwd-independent** | exit 0 from repo root *and* from `/tmp`; four `STEP=PASS` |
| 8 | gate negative controls C1–C7 | **CONFIRMED** | every documented control reproduced its exit code and failing check |
| 9 | r101 subtree is byte-pinned and untouched by the wording fold | **CONFIRMED** | `upstream/` + `.manifest.d/` zero diff vs `HEAD`; per-file sha256 vs `HEAD` blobs: 0 drift |
| 10 | F2/F3 correction notes landed in the r22 lesson and preserve history | **CONFIRMED (existence + values only)** | file 50 → 85 lines, two dated r102 notes, r22 text verbatim above each; values agree with this seat's independent measurements |

Two defects are **flagged, not fixed** (this seat owns no repair path):
`engines.md:10`'s quoted command is cwd-dependent (row 2), and
`corpus/fixtures/three/README.md` still carries the dead `.shokunin/game-dev-3d/`
root on 17 lines, so the fixture's own declared install line still exits 1 (see §6).

Row 10 was not in this seat's brief; it is recorded because the F2/F3 repairs landed
while this seat was running, and a verification report that ignored a live change to
a file it had already read would be stale on arrival.

---

## 1. The r101 subtree — sha256 sweep

### 1a. Reference manifest, run from the subtree

```
$ cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256
upstream/.claude-plugin/plugin.json: OK
upstream/CODEOWNERS: OK
upstream/.gitignore: OK
upstream/hooks/hooks.json: OK
upstream/hooks/unreal-context.sh: OK
upstream/LICENSE: OK
upstream/README.md: OK
upstream/skills/create-toolset/SKILL.md: OK
upstream/skills/unreal-mcp/references/operations.md: OK
upstream/skills/unreal-mcp/references/setup.md: OK
upstream/skills/unreal-mcp/SKILL.md: OK
upstream/skills/unreal-skill/SKILL.md: OK
exit=0
```

**12/12 `OK`, zero `FAILED`, exit 0.** Line count confirmed independently:
`… | grep -c ': OK$'` → `12`.

### 1b. The glob form and its true count

```
$ cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/*.sha256 | grep -c ': OK$'
24
```

The glob covers all 12 files **twice** — once via `audit-reference.sha256`, once via
the `seatNN.sha256` shard (11 shard files carrying 12 entries, because `seat11`
covers two paths). This is exactly the F8 wording fold that the r102 repair applied
to `corpus/knowledge/unreal-mcp/README.md`; the repaired text now says 24 and shows
both halves, and the number observed here matches the repaired text. This seat
re-derived it rather than taking it from the README.

### 1c. Set-equality and byte-identity against a fresh clone at the pin

A **new** clone made by this seat (not the pre-existing `/tmp/ue-skills-ref`):

```
$ git clone -q https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin /tmp/seat27-clone
clone-rc=0
$ git -C /tmp/seat27-clone rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
$ git -C /tmp/seat27-clone status --porcelain | wc -l
0
$ git -C /tmp/seat27-clone ls-files | wc -l
12
```

Path-set equality both ways, and per-file byte-identity against the clone's blobs at
the pinned commit:

```
$ (cd corpus/knowledge/unreal-mcp && find upstream -type f | sed 's|^upstream/||' | sort) > /tmp/seat27-vendored.txt
$ git -C /tmp/seat27-clone ls-files | sort > /tmp/seat27-upstream.txt
$ comm -23 /tmp/seat27-vendored.txt /tmp/seat27-upstream.txt    # EXTRA
(no output)
$ comm -13 /tmp/seat27-vendored.txt /tmp/seat27-upstream.txt    # MISSING
(no output)
$ # per-file sha256 vs `git show <pin>:<path>`
BLOB_DIFFS=0
```

Independent transport, `diff -rq` against a second clone:

```
$ diff -rq /tmp/ue-skills-ref corpus/knowledge/unreal-mcp/upstream --exclude=.git
(no output)
diff-rc=0
```

**Verdict: the vendored tree is byte-identical to the pinned upstream commit, and
the path set is equal in both directions. `sha256sum -c` alone cannot see an extra
unlisted file; the `comm` comparison closes that gap.**

### 1d. The pinned region was not perturbed by the r102 wording fold

The r102 fold edited `corpus/knowledge/unreal-mcp/README.md` (a non-pinned file).
Proof that `upstream/` and `.manifest.d/` are untouched:

```
$ git diff --stat HEAD -- corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d
(no output)   exit 0
$ git status --porcelain corpus/knowledge/unreal-mcp/
 M corpus/knowledge/unreal-mcp/README.md
?? corpus/knowledge/unreal-mcp/gate/
$ # recompute every vendored file's sha256 against its HEAD blob
drift-check-done          # no DRIFT line printed → 0 drift
```

Only `README.md` is modified and `gate/` is new; the pinned `upstream/` and
`.manifest.d/` are byte-identical to `HEAD`.

### 1e. A transient, observed and resolved — worth recording

Mid-run, one command observed the two largest pinned files briefly truncated:

```
$ wc -c corpus/knowledge/unreal-mcp/upstream/README.md corpus/knowledge/unreal-mcp/upstream/skills/unreal-mcp/SKILL.md
   54 corpus/knowledge/unreal-mcp/upstream/README.md
   54 corpus/knowledge/unreal-mcp/upstream/skills/unreal-mcp/SKILL.md
$ (cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256 | grep -c FAILED)
2
```

A sibling seat was writing those files at that moment. 20 s later the same probe read
the correct sizes (`8398` and `7098` bytes — equal to the `HEAD` blob sizes), the
sweep returned 0 `FAILED`, and the gate went green. **Every verdict in this report is
from a post-restoration run.** This is recorded because a gate run that lands inside
another seat's write window will legitimately fail closed — the failure is real at
that instant and not a gate defect.

---

## 2. The gate — run, and adversarially calibrated

### 2a. Green run, from the repo root

```
$ corpus/knowledge/unreal-mcp/gate/run_gate.sh
SUBTREE=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/knowledge/unreal-mcp
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
STEP=PASS
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_TRACKED=12
PATH_EXTRA=0 PATH_MISSING=0
BLOB_DIFFS=0
STEP=PASS
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
STEP=PASS
POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
GATE RESULT: PASS (checks failed: 0)
EXIT=0
```

Every value matches the pinned expectations in `gate/README.md` §"Expected output"
(`MANIFEST_OK=12`, clone HEAD = pin, `CLONE_TRACKED=12`, `CARDS=13`, census
`12/1/0`, `POINTERS=40`, `UNRESOLVED=0`).

### 2b. cwd-independence

Run from `/tmp` with an absolute path — the gate resolves the subtree from its own
location:

```
$ cd /tmp && /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/knowledge/unreal-mcp/gate/run_gate.sh
SUBTREE=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/knowledge/unreal-mcp
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
STEP=PASS
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
BLOB_DIFFS=0
STEP=PASS
CARDS=13 EXPECTED=13 BAD=0
STEP=PASS
POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
GATE RESULT: PASS (checks failed: 0)
EXIT=0
```

Same `SUBTREE=` line, same result. The r101 checks lived in `/tmp/r101-closeout/`
and in the protocol's inline blocks (lesson hook 2 of `r102-unreal-integration.md`);
this gate is genuinely self-contained and path-independent, which is the C1(a) move
the lesson asked for.

### 2c. Negative controls — every documented control reproduced

Run on throwaway `cp -r` copies; the pinned tree was never mutated.

| control | mutation | expected exit | observed exit | observed signal |
|---|---|---|---|---|
| C1 | append one byte to `upstream/README.md` | 1 | **1** | `MANIFEST_OK=11 EXPECTED=12 FAILED=1 RC=1`; `BLOB-DIFF README.md`; `BLOB_DIFFS=1`; 2 checks failed |
| C2 | delete `upstream/LICENSE` | 1 | **1** | `MANIFEST_OK=11 … FAILED=0 RC=1`; `PATH_MISSING=1`; `BLOB-DIFF LICENSE`; 2 checks failed |
| C3 | plant `upstream/README.md:200` | 1 | **1** | `LINE-OOR … :: upstream/README.md:200 (max 112)`; `POINTERS=41 UNRESOLVED=1` |
| C4 | duplicate a label token on the label line | 1 | **1** | `FAIL multi-label …`; `CARDS=13 BAD=1` |
| C5 | relabel a card `unproven-runtime` | 1 | **1** | `CARDS=13 BAD=0` but census `11 / 2 / 0` vs expected `12 / 1 / 0` |
| C6 | remove `executability/sequencer.md` | 1 | **1** | `CARDS=12 EXPECTED=13 BAD=1` |
| C7 | plant **only** the exact sentinels | **0** | **0** | `POINTERS=40 SKIPPED_CONTROL_SENTINELS=3 UNRESOLVED=0` |

C5 and C6 are the two controls that catch a *censored* rather than *corrupted* tree,
and both fired — a count-only check would have missed C5 entirely, since the card
count stayed 13 and `BAD=0`; only the census line caught it.

**One correction this seat owes about its own method.** My first C7 run returned
`SKIPPED_CONTROL_SENTINELS=3 UNRESOLVED=1` / exit 1. That was **my test error, not a
gate defect**: I appended the sentinels to a copy that still carried the C3 planted
pointer, so the residual `UNRESOLVED=1` was the C3 artifact, not a masked sentinel.
Re-run on a fresh copy, C7 returns exit 0 with `UNRESOLVED=0` and all three sentinels
skipped — the exclusion is exact and does not mask real pointers.

`SKIPPED_CONTROL_SENTINELS=3` here versus the README's recorded `2`: the README's C7
table row says `2` for the three-sentinel plant. The count is a *printed diagnostic*,
not a pinned pass/fail value, and the gate's own expectation for a clean subtree is
`0` (which the clean run gives). Flagged as a documentation nit, not a gate failure —
the sentinel regex has three alternatives (`nope.md:N`, `README.md:9999`,
`README.md:500`) and the plant supplies one match for each, so `3` is the arithmetically
correct count for that plant and `2` in the README looks like an authoring slip.

**Verdict: the gate is not vacuously green.** It fails closed on every corruption and
censorship class it claims to detect, and its sentinel exclusion is exact.

---

## 3. `engines.md` row commands, run as written

### Row 1 — Godot 4.7.2 · `installed: yes` · `executable headless: yes`

Evidence cell: "r1 battery receipts under corpus/live/runs/".

```
$ command -v godot
/usr/bin/godot
$ godot --version
4.7.2.stable.arch_linux.ed1daf0bf
$ python3 corpus/fixtures/run_battery.py
… (per-case PASS lines) …
rc=0
```

The battery ran to completion with exit 0 and every printed case line `PASS`
(spot-checked across the `phys3d_events_*` family; no `FAIL` line appeared in the
captured tail). **The `installed: yes` cell is confirmed by the binary and its
version string; the `yes` headless cell is confirmed by the battery exiting 0.**

Caveat on the row's *evidence pointer*, not on the cell values: the cell points at
"r1 battery receipts under `corpus/live/runs/`", and that directory is gitignored
(`corpus/.gitignore:1: live/`). The cited r1 run directory
`20261013T053632289732Z` does **not** exist here — only `2026-10-18` run directories
from r101/r102 re-runs are present, and `find corpus/live -name verdicts.json` → 0.
So the Godot row is *reproducible by command* but its *cited receipt* is not
resolvable from this tree. That is the same class as the routed F2 defect and is
already routed; recorded here because it touches a row I was asked to verify.

### Row 2 — Unity Editor · `installed: no` · `executable headless: no`

Evidence cell: "census at mint; r19 `corpus/artifacts/unity-r19/` static self-authored
`.unity` sample and non-author review".

```
$ command -v unity Unity UnityHub unityhub
(no output)   rc=1
$ ls -d /opt/unity* /usr/share/unity* ~/Unity*
(no output)
$ ls corpus/artifacts/unity-r19/
Hierarchy.broken-reference.unity  Hierarchy.unity  README.md  verify_scene.py
```

**`no` / `no` confirmed.** The cited artifact exists. Its own verifier, run
repo-relative under the declared isolated environment, discriminates:

```
$ uv run --no-project --with pyyaml python corpus/artifacts/unity-r19/verify_scene.py
PASS local-static actual=accept expected=accept … reason=two GameObjects and two Transforms; reciprocal fileIDs; parent-child world=(11,2,-3) (local static derivation)
rc=0
$ uv run --no-project --with pyyaml python corpus/artifacts/unity-r19/verify_scene.py corpus/artifacts/unity-r19/Hierarchy.broken-reference.unity --expect-reject
PASS local-static actual=reject expected=reject … reason=child father reference broken: {'fileID': 999}
rc=0
```

Note `python3` alone fails this verifier (`ModuleNotFoundError: No module named
'yaml'`, exit 1) — the row is honest in calling the evidence *static*, and the
declared `uv run --with pyyaml` form is the one that works. **No state move.**

### Row 3 — Unreal Engine · `installed: no` · `executable headless: no`

Evidence cell (r102-updated): two static evidence classes; (b) the r101 pinned tree,
with the quoted check `sha256sum -c .manifest.d/audit-reference.sha256` → rc=0.

```
$ command -v UnrealEditor UnrealEditor-Cmd UE4Editor UnrealBuildTool
(no output)   rc=1
$ ls -d /opt/unreal* /usr/share/unreal* ~/UnrealEngine*
(no output)
$ ss -ltn | grep -c ':8000'
0
```

**`no` / `no` confirmed. The state columns have not moved.** The row's own rule
(`engines.md:13-16`) allows a move only with a saved bounded-fixture receipt *and* a
non-author verifier; no such receipt exists and none can on this host, so the row is
correct to stay put.

The quoted evidence command is **cwd-dependent**, and this is the one substantive
finding of this seat:

```
$ sha256sum -c .manifest.d/audit-reference.sha256          # from the repo root
sha256sum: .manifest.d/audit-reference.sha256: No such file or directory
rc=1
$ cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256 >/dev/null
rc=0
```

The row writes the command as a bare relative path with no working directory, while
`engines.md`'s own three.js row is written repo-root-relative (`corpus/fixtures/…`)
and its prose says "from repo root". A reader who follows the file's established
convention — run it from the repo root — gets exit 1 and may read that as a broken
pin. The underlying claim is true; the *pointer* is under-specified. Minimum honest
fix (for the row's owner, not this seat): prefix with
`cd corpus/knowledge/unreal-mcp &&`, or quote the `gate/run_gate.sh` invocation
instead, which is cwd-independent and was verified green from two working
directories in §2.

**No Unreal runtime claim is made here.** The editor is absent; `unproven-runtime`
stays `unproven-runtime`.

### Row 4 — three.js 0.186.1 · `partial` — the F5 repair

The repaired row now reads:

```
`npm ci --prefix corpus/fixtures/three && node corpus/fixtures/three/run_cases.mjs` → 3/3, `seeds_unchanged=true`, exit 0
```

**After (pass), run exactly as written from a pristine export of `HEAD`** — no
untracked `node_modules`, nothing added:

```
$ git archive HEAD | tar -x -C /tmp/seat27-clean2
$ cd /tmp/seat27-clean2
$ ls corpus/fixtures/three/node_modules
ls: cannot access 'corpus/fixtures/three/node_modules': No such file or directory
$ npm ci --prefix corpus/fixtures/three    # rc=0
$ node corpus/fixtures/three/run_cases.mjs
PASS positive: exit=0 expected=0
PASS negative_wrong_order: exit=2 expected=2
PASS mutation: exit=1 expected=1
PASS three battery: 3/3, seeds_unchanged=true
rc=0
```

**Before (fail), the pre-repair form on the same clean tree:**

```
$ node corpus/fixtures/three/run_cases.mjs
FAIL positive: exit=1 expected=0
FAIL negative_wrong_order: exit=1 expected=2
FAIL mutation: exit=1 expected=1
FAIL three battery: 3/3, seeds_unchanged=true
rc=1
```

Also verified on the working tree from the repo root (exit 0, 3/3), and confirmed
that the three installed bytes are the pinned version —
`node_modules/three/package.json` → `"version": "0.186.1"`, lockfile integrity
`sha512-blFeqb49wRCSGUGj7gtpfnSGHy2lwDk94RhUmS1c/hTby70kvChbWpkJ4Pm1390LqzzvTmzgXKHPEafJwCb8jA==`
resolved from `registry.npmjs.org/three/-/three-0.186.1.tgz`, `npm ci` → `added 1
package`.

**Verdict: the F5 repair is real and discriminating.** `npm ci --prefix <dir>` from
the repo root is the correct install shape, and the row's own note now states the
gitignored-`node_modules` precondition. One residual documentation discrepancy, in
the *other* direction from F5: the row's version parenthetical still says
**`Node v26.11.1`**, while the host now reports `v26.12.0`. The claim that matters
(the three.js version pin and the 3/3 result) is unaffected; the Node version is a
stale host fact in the row. Flagged, not fixed — the row is not this seat's.

Also flagged, per the F5 adversary's P1: the *evidence cell* now quotes
`3/3, seeds_unchanged=true, exit 0`, which is discriminating — `3/3` alone is
printed identically on a failing run (see the BEFORE block above, whose last line
also reads `3/3`). Quoting the exit code as the row now does is the right call.

---

## 4. Host state for the state columns — one probe block

```
godot              PRESENT     (/usr/bin/godot, 4.7.2.stable.arch_linux.ed1daf0bf)
unity              ABSENT
unityhub           ABSENT
UnrealEditor       ABSENT
UnrealEditor-Cmd   ABSENT
UnrealBuildTool    ABSENT
port8000-listeners: 0
unreal dirs: 0
unity dirs: 0
```

State-column cells in the file, read directly:

```
$ awk -F'|' 'NR>=8 && NR<=11 {print NR": "$2"|"$3"|"$4}' corpus/knowledge/engines.md
8:  Godot 4.7.2 | yes (`/usr/bin/godot`) | yes
9:  Unity Editor | no | no
10: Unreal Engine | no | no
11: three.js 0.186.1 | lane-local npm dependency pinned in `corpus/fixtures/three/package-lock.json` (Node v26.11.1) | partial — …
```

**Confirmed: no state column moved.** Godot stays `yes`/`yes` (probe agrees), Unity
and Unreal stay `no`/`no` (probes agree), three.js stays `partial` (probe agrees: the
`Object3D` math runs under Node, there is no GL context and no rendering claim).

---

## 5. What this seat did **not** verify

- **Nothing about Unreal Editor behavior.** Not installed; no server; no tool call.
  The gate's `verified-here` count of `0` is the correct value and the census
  `12 / 1 / 0` is the correct shape for this host.
- **Not the semantics of the 13 card labels.** Check 3 enforces one-label-per-card
  mechanically; whether a given `static-only` card actually rests on a static check
  that ran here is a read-the-cards judgement. The gate README says so explicitly,
  and this seat did not make that judgement — the F7 label-collision question from
  `r102-unreal-integration.md` Law 3 is still open and still worth a future round.
- **Not the markdown links inside the subtree, JSON well-formedness of
  `plugin.json` / `hooks.json`, or `shellcheck` cleanliness of `unreal-context.sh`.**
  Those are r101 protocol steps 6 and 9, not among this gate's four checks. Their
  absence from the gate must not be read as their having passed. (The `jq -e` parse
  of both JSON files and the shellcheck pass were recorded in the r101 probes; this
  seat did not re-run them and makes no claim about them.)
- **Not the F2/F3 corrections — they landed mid-run and were re-checked, not
  verified in depth.** At first read the r22 lesson still cited the absent
  `corpus/live/runs/20261013T053632289732Z/verdicts.json` and the stale
  `run_battery.py` sha `a065a56d…`, with no correction note. By the end of this
  seat's run the file had grown from 50 to 85 lines and carried two dated
  correction notes (r102, 2026-10-18), one per defect. Re-checked afterwards:

  ```
  $ wc -l corpus/lessons/r22-unreal-review.md
  85 corpus/lessons/r22-unreal-review.md
  $ grep -n -iE "correction note|f456bd00" corpus/lessons/r22-unreal-review.md | head -3
  50:> **Correction note (r102, 2026-10-18).** The paragraph above is left verbatim …
  53:> - Three digests are **r21/r22-era blobs** … the `run_battery.py` seed `a065a56d…`
        (tree now `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` …)
  59:## Correction note — 2026-10-18 (r102)
  ```

  Both notes preserve the r22 text verbatim above them, as the correction-note
  discipline requires. The values they state agree with what this seat measured
  independently (`sha256sum corpus/fixtures/run_battery.py` →
  `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`; the cited run
  directory absent; `grep -c a065a56d corpus/lessons/r22-unreal-review.md` → 6, all
  inside the correction notes, which quote the historical value deliberately).
  **This seat checked that the notes exist, quote the right current values, and do
  not rewrite history — it did not audit every digest in them.**

---

## 6. Routed findings (not this seat's to fix)

1. **`engines.md:10` Unreal-row command is cwd-dependent** — exit 1 from the repo
   root, exit 0 from the subtree. Suggest `cd corpus/knowledge/unreal-mcp && …` or
   the cwd-independent `gate/run_gate.sh`.
2. **`engines.md:11` says `Node v26.11.1`; host reports `v26.12.0`.** Stale host
   fact; the three.js pin and the 3/3 result are unaffected.
3. **`corpus/fixtures/three/README.md` still carries the dead
   `.shokunin/game-dev-3d/` root on 17 lines**, including its declared install line:

   ```
   $ npm ci --prefix .shokunin/game-dev-3d/corpus/fixtures/three
   npm error Run "npm help ci" for more info
   rc=1
   ```

   This is the F5 adversary's routed P3, still open. The fixture's *declared*
   recovery path fails while the repo-root-relative one succeeds — the most likely
   reason a reader following the docs lands on F5's `exit=1`. Same F1 class
   (mechanical path conformance), so a correction note is not required, but the
   install-command shape is an r6-era convention and the owner should confirm intent.
4. **`corpus/artifacts/unity-r19/README.md:10-11` carries the same dead root** on its
   two `uv run` lines. The commands themselves work when the root is corrected
   (verified in §3, row 2), so this is a documentation-only defect in the same class.
5. **Gate README C7 row says `SKIPPED_CONTROL_SENTINELS=2`; the three-sentinel plant
   yields `3`.** Cosmetic; the clean-subtree expectation of `0` is what matters and
   the clean run gives `0`.

---

## 7. Reproduce

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin

# 1. subtree sha256 sweep (expect 12× OK, exit 0)
(cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256)

# 2. the gate, cwd-independent (expect GATE RESULT: PASS, exit 0)
corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "exit=$?"
(cd /tmp && /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/knowledge/unreal-mcp/gate/run_gate.sh)

# 3. engines.md row commands
godot --version
uv run --no-project --with pyyaml python corpus/artifacts/unity-r19/verify_scene.py
command -v UnrealEditor UnrealEditor-Cmd UnrealBuildTool; echo "rc=$?"   # expect none, rc=1
(cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256)   # rc=0
rm -rf /tmp/clean && mkdir -p /tmp/clean && git archive HEAD | tar -x -C /tmp/clean
(cd /tmp/clean && npm ci --prefix corpus/fixtures/three && node corpus/fixtures/three/run_cases.mjs)  # exit 0

# 4. one negative control (expect exit 1)
T=$(mktemp -d); cp -r corpus/knowledge/unreal-mcp "$T/sub"
printf 'X' >> "$T/sub/upstream/README.md"; "$T/sub/gate/run_gate.sh"; echo "exit=$?"
```

---

**Seat conclusion.** The r101 subtree's byte-pin holds (12/12, two independent
transports, path-set equality both ways), the new gate is self-contained, green from
two working directories, and fails closed on all seven documented corruption and
censorship controls; the `engines.md` state columns have not moved and every
executable row command was re-run. Two documentation-class defects are flagged
(`engines.md` cwd-dependent Unreal command, stale Node version) and three adjacent
dead-path/stale-count items are routed. No Unreal runtime claim is made or implied.
