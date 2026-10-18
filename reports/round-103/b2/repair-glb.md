# B2 — `glb-r12/README.md` dead-root repair

**Seat:** SEAT-23 REPAIR-GLB · round r103 · lane `game-dev-3d-shokunin`
**Owned path:** `corpus/artifacts/glb-r12/README.md` (only) + this file.
**Repo:** `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`, HEAD `c85a816` (work `c6f655d`)
**Date:** 2026-10-18 · all commands below were run by this seat from the repo root.

**Write scope.** This seat wrote exactly two files: the three-line command block in
`corpus/artifacts/glb-r12/README.md` and this report. Not touched: `LOG.md`, `SCORECARD.md`,
`SHONEN.md`, `SKILL.md`, `PROVINCE.md`, `corpus/fixtures/**`, `reports/round-101/**`,
`reports/round-102/**`, `corpus/knowledge/unreal-mcp/**` (incl. `upstream/` and `.manifest.d`),
and every other seat's file. No git commit/push/checkout/reset was run.

Two other files show as modified in the worktree — `corpus/artifacts/unity-r19/README.md` and
`corpus/fixtures/three/README.md` — both are **concurrent seats' own B2 repairs**, not this seat's
(confirmed by `git diff` scoping and by their own evidence files
`reports/round-103/b2/repair-unity.md` / `reports/round-103/b2/repair-three.md`).

**No Unreal runtime claim is made anywhere in this file.** The Unreal Editor is not installed on
this host and live-MCP behaviour is unproven by construction; nothing here is evidence of engine
behaviour. The three commands below exercise Godot 4.7.2 headless and three.js under Node.

---

## 1. The ruled disposition this seat applied

The repair class is bounded by two r103 artifacts, both re-read before acting:

- `reports/round-103/b2/adversary.md` §4/§5 (SEAT-30 DEADROOT-ADVERSARY) — the keep-list. Its
  ruled table row: *"class B command blocks in reproduction READMEs | 20 lines / 2 files | **REPAIR**,
  with a declared note"*, and §4 names `corpus/artifacts/glb-r12/README.md` as **3 hit lines,
  unfixed, `exit=2`**.
- `reports/round-102/fold-spec.md` §B2 — the acceptance: `grep -c "shokunin/game-dev-3d"` on the
  README → `0`, and the verbatim commands re-run from the repo root exit `0`.

**Form of the repair: mechanical command/path conformance, applied in place.** This follows the
r22 precedent the adversary file itself cites (`reports/round-102/repairs/F1a-r22-readme.md:4`:
*"mechanical command/path conformance fix, applied in place (not a historical factual claim, so no
dated correction note is required)"*). Only the three literal command lines changed; no narrative,
table row, digest, or historical claim was touched. The declaration the adversary file requires is
this file.

**Why glb-r12 is repair-eligible and not on the keep-list.** It is a reproduction README whose
fenced command block is the executable contract — the same class as the already-landed
`unity-r19` repair (`git status` shows ` M corpus/artifacts/unity-r19/README.md` from a sibling
seat). It is *not* a digest-pinned fixture seed (keep-list K4), a dated round report (K2), a
receipt (K5), or a ledger/scope declaration (K3):

```
$ git grep -l "0af4f3691e19f8588c54ceb494802dae7bd8e937e03c1bc121de071ca871dbe1" HEAD
(no output; exit=1)
$ grep -rn "glb-r12/README" corpus/lessons/
(no output; exit=1)
```

Neither the README's pre-repair blob hash nor its path is cited as evidence anywhere in the corpus,
so no cited value is invalidated by the edit — the K4 harm mode does not apply here.

---

## 2. The defect

`corpus/artifacts/glb-r12/README.md` presents its commands under the heading *"From the repo root
run:"* but rooted all three paths at `.shokunin/game-dev-3d/`, a prefix that does not resolve from
this repo root. The real repo root is `game-dev-3d-shokunin/`, so the repo-relative path is
`corpus/artifacts/glb-r12/`.

Defective lines (original README lines 6–8):

```sh
python3 .shokunin/game-dev-3d/corpus/artifacts/glb-r12/run_import.py
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py
node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs
```

### BEFORE (fail) — run from repo root

```
$ python3 .shokunin/game-dev-3d/corpus/artifacts/glb-r12/run_import.py
python3: can't open file '/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/.shokunin/game-dev-3d/corpus/artifacts/glb-r12/run_import.py': [Errno 2] No such file or directory
exit=2
```

`exit=2`, matching the fold-spec §B2 routing and the adversary file's §4 table.

---

## 3. The fix (in place, 3 lines)

Dropped the `.shokunin/game-dev-3d/` prefix so the commands are genuinely repo-relative and
consistent with the README's own "From the repo root run:" heading:

```sh
python3 corpus/artifacts/glb-r12/run_import.py
python3 corpus/fixtures/run_battery.py
node corpus/fixtures/three/run_cases.mjs
```

The resulting diff is exactly that block — 3 insertions, 3 deletions, nothing else:

```
$ git diff --stat -- corpus/artifacts/glb-r12/README.md
 corpus/artifacts/glb-r12/README.md | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

$ git diff -- corpus/artifacts/glb-r12/README.md
@@ -3,9 +3,9 @@
 From the repo root run:
 
 ```sh
-python3 .shokunin/game-dev-3d/corpus/artifacts/glb-r12/run_import.py
-python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py
-node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs
+python3 corpus/artifacts/glb-r12/run_import.py
+python3 corpus/fixtures/run_battery.py
+node corpus/fixtures/three/run_cases.mjs
 ```
```

Line count is unchanged (19 → 19), so the surrounding prose, the three-row GLB contrast table and
the limits paragraph are byte-identical to HEAD apart from the three command lines.

Blob identity before and after:

```
$ git show HEAD:corpus/artifacts/glb-r12/README.md | sha256sum
0af4f3691e19f8588c54ceb494802dae7bd8e937e03c1bc121de071ca871dbe1  -
$ sha256sum corpus/artifacts/glb-r12/README.md
d87774dcfc3c6265957e2850b4fc2f29a72eabef9697424009d6355d05b8582b  corpus/artifacts/glb-r12/README.md
```

---

## 4. AFTER — every repaired command re-run, with observed output

Host toolchain used by these commands (read, not assumed):

```
$ godot --version
4.7.2.stable.arch_linux.ed1daf0bf
$ node --version
v26.12.0
```

### Command 1 — the glb import runner (exit=0)

```
$ python3 corpus/artifacts/glb-r12/run_import.py
PASS Godot GLB import: valid/tolerated load, bad magic diagnosed and not loaded; receipt=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/runs/r12-import-20261018T183354762168Z/verdicts.json
exit=0
```

The runner's own receipt confirms the discrimination still holds after the edit — the accepted
controls load and the corrupted control is rejected, with the source seeds unchanged:

```
$ python3 -c "import json; d=json.load(open('corpus/live/runs/r12-import-20261018T183354762168Z/verdicts.json')); print('verdict:', d['verdict']); print('good:', d['positive_and_tolerated_control_same_scene'], 'rejected:', d['bad_magic_rejected'], 'unchanged:', d['source_digests_unchanged']); [print(k, 'editor_exit=', d[k]['editor']['exit'], 'script_exit=', d[k]['scene']['exit'], 'scn=', d[k]['imported_scene_exists']) for k in ('valid','tolerated_header','bad_magic')]"
verdict: PASS
good: True rejected: True unchanged: True
valid editor_exit= 0 script_exit= 0 scn= True
tolerated_header editor_exit= 0 script_exit= 0 scn= True
bad_magic editor_exit= 0 script_exit= 2 scn= False
```

### Command 3 — the three.js case suite (exit=0)

```
$ node corpus/fixtures/three/run_cases.mjs
PASS positive: exit=0 expected=0
PASS negative_wrong_order: exit=2 expected=2
PASS mutation: exit=1 expected=1
PASS three battery: 3/3, seeds_unchanged=true
exit=0
```

### Command 2 — the Godot battery (see §5 for the observed result)

The battery resolves and runs green on a bounded subset, run from the repo root after the edit:

```
$ python3 corpus/fixtures/run_battery.py --only floor3d_ground,camera3d_project
PASS floor3d_ground: exit=0 expected=0
PASS camera3d_project: exit=0 expected=0
totals: cases=2 pass=2 fail=0 ordinary=2 negative_controls=0 probes=0
PASS battery: /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/runs/20261018T184049463588Z/verdicts.json
exit=0
```

That proves the path defect is gone — the command now resolves and executes the battery. The
full 350-row run takes ~13 minutes and is reported in §5; **that row is the one the seat must not
paper over**: the battery is *not* green on this host for reasons independent of the path repair
(pre-existing `r94_cannon` node-version markers and one routed timeout), so the honest statement is
that command 2 now *resolves and runs*, while its exit code reflects a pre-existing,
separately-routed battery condition.

---

## 5. Command 2 result, and why it is not a path defect

The full 350-row battery was run by this seat after the edit, from the repo root, output captured
verbatim (`/tmp/seat23-battery.out`; receipt `corpus/live/runs/20261018T184232181419Z/verdicts.json`):

```
$ python3 corpus/fixtures/run_battery.py; echo "exit=$?"
...
totals: cases=350 pass=335 fail=15 ordinary=291 negative_controls=59 probes=0
FAIL battery: /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/runs/20261018T184232181419Z/verdicts.json
exit=1
```

So **command 2 resolves and runs the whole battery** — 350 rows, 335 PASS — and its non-zero exit is
the pre-existing battery condition, not the path defect. My run's receipt records
`seeds_unchanged=True`, the battery's own guard that no seed was mutated:

```
$ python3 -c "import json; d=json.load(open('corpus/live/runs/20261018T184232181419Z/verdicts.json')); rs=d['results']; print('verdict=',d['verdict'],'n=',len(rs),'seeds_unchanged=',d.get('seeds_unchanged')); bad=[r for r in rs if r.get('verdict')!='PASS']; print('non-pass:',len(bad)); [print(' ', r['case'], 'actual_exit=',r.get('actual_exit'), 'expected=',r.get('expected_exit'), str(r.get('reasons'))[:90]) for r in bad]"
verdict= FAIL n= 350 seeds_unchanged= True
non-pass: 15
  phys3d_joints_free_ops actual_exit= None expected= 0 ['TIMEOUT after 20 seconds', 'no exit code (process killed or timed out)', 'exact stdout m
  bpy_rbw3d_render actual_exit= 0 expected= 0 ['exact stdout marker missing']
  r94_cannon_det actual_exit= 0 expected= 0 ['exact stdout marker missing']
  r94_cannon_det2 actual_exit= 0 expected= 0 ['exact stdout marker missing']
  r94_cannon_varstep actual_exit= 0 expected= 0 ['exact stdout marker missing']
  r94_cannon_bailout actual_exit= 0 expected= 0 ['exact stdout marker missing']
  r94_cannon_nan actual_exit= 0 expected= 0 ['exact stdout marker missing']
  r94_cannon_sync actual_exit= 0 expected= 0 ['exact stdout marker missing']
  r94_cannon_material actual_exit= 0 expected= 0 ['exact stdout marker missing']
  r94_cannon_friction actual_exit= 0 expected= 0 ['exact stdout marker missing']
  r94_cannon_parity actual_exit= 0 expected= 0 ['exact stdout marker missing']
  r94_cannon_parity2 actual_exit= 0 expected= 0 ['exact stdout marker missing']
  r94_cannon_modes actual_exit= 0 expected= 0 ['exact stdout marker missing']
  r94_cannon_order actual_exit= 0 expected= 0 ['exact stdout marker missing']
  r94_cannon_backends actual_exit= 0 expected= 0 ['exact stdout marker missing']
```

Three observations, all independent of the path root:

- **The 13 `r94_cannon_*` rows** have `actual_exit=0` and `expected_exit=0` — the engine ran and
  exited correctly; only the *exact stdout marker* is missing. The marker text is pinned to
  `node=v24.21.0` while this host runs `node v26.12.0` (a marker the round's own LOG entry already
  records as routed: *"Battery r94_cannon markers pin node=v24.21.0 while the host runs v26.12.0;
  fresh full runs are red on those rows"*). The battery source confirms the pin is baked into the
  expected string:

  ```
  $ grep -c "node=v24.21.0" corpus/fixtures/run_battery.py
  13
  ```

- **`phys3d_joints_free_ops`** is a 20-second `TIMEOUT` (`actual_exit=None`, `elapsed_seconds=20.022`,
  empty stderr, stdout carrying only the Godot banner). It is the **exact row the round routed to
  investigation, not repair** — the brief assigns `phys3d_joints_free_ops` to a separate
  investigation and explicitly says *"investigation (NOT repair)"*. This seat does **not** touch it
  and makes no claim about its cause beyond the observed timeout.

- **`bpy_rbw3d_render` appears in this run but not in the earlier `20261018T181301123479Z` run**
  (14 non-PASS there vs 15 here). It is `actual_exit=0`/`expected_exit=0` with `['exact stdout
  marker missing']` — the same *class* as the `r94_cannon` rows, and its stdout shows the `shot` and
  `rdet` sub-cases completing (`DONE case=shot,e=0,w=0,b=0`). This is a **flakiness observation
  offered for the routed battery work, not a repair target**: the two runs differ by exactly this
  one row, which is a fact about the battery's determinism rather than about any path. This seat
  does not touch the battery.

**The distinction that matters for the acceptance.** The fold-spec §B2 acceptance asks that the
verbatim commands re-run from the repo root exit `0`. Commands 1 and 3 do, and are pasted in §4. For
command 2, the honest statement is split: the *path defect is gone* — the command resolves and runs
all 350 rows from the repo root, and the same command with the dead prefix did not run at all
(`[Errno 2]`) — while the battery's exit code is a **separate, already-routed condition** that this
seat must neither absorb into its claim nor "fix" by editing fixtures it does not own. **No fixture
was modified:** `git status` shows no change under `corpus/fixtures/**` attributable to this seat
(the `three/README.md` modification in the worktree is SEAT-25's separate B2 repair), and my run's
own `seeds_unchanged=True` is the mechanism that proves it.

---

## 6. Residual scan — the acceptance

```
$ grep -c "shokunin/game-dev-3d" corpus/artifacts/glb-r12/README.md
0
exit=1

$ grep -rn "shokunin/game-dev-3d" corpus/artifacts/glb-r12/
(no output; grep exit=1)
```

The README reads `0` and the whole owned directory contains no hit. The three remaining
`.shokunin/game-dev-3d` hits under `corpus/artifacts/` are the REA receipts, which the adversary
keep-list rules **KEEP** (raw machine-printed tool output, correct on its day):

```
$ grep -rln "shokunin/game-dev-3d" corpus/artifacts/
corpus/artifacts/glb-r9/rea-inspect-error.json
corpus/artifacts/zip-r10/rea-negative.json
corpus/artifacts/zip-r10/rea-positive.json
```

---

## 7. What is NOT repaired, and is not this seat's

- `corpus/fixtures/three/README.md` — 17 hit lines, the other repair-eligible file
  (`reports/round-103/b2/adversary.md` §4). **Different seat's ownership**; left untouched. Its
  repair carries the K5 caveat (declared path-conformance change with its own note).
- `corpus/artifacts/unity-r19/README.md` — already repaired in the worktree by a sibling seat
  (`reports/round-103/b2/verify-unity.md` is that seat's evidence). Not re-dispatched here.
- The keep-list classes K1–K5 — untouched by construction.

---

## 8. Reproduce

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin

# the defect, and the acceptance
grep -c "shokunin/game-dev-3d" corpus/artifacts/glb-r12/README.md    # 0
git diff --stat -- corpus/artifacts/glb-r12/README.md                # 1 file, 3 insertions(+), 3 deletions(-)

# the three repaired commands, run from the repo root
python3 corpus/artifacts/glb-r12/run_import.py; echo "exit=$?"        # PASS ... exit=0
python3 corpus/fixtures/run_battery.py --only floor3d_ground,camera3d_project; echo "exit=$?"   # exit=0
python3 corpus/fixtures/run_battery.py;          echo "exit=$?"        # see §5 — 335/350, pre-existing rows
node corpus/fixtures/three/run_cases.mjs;        echo "exit=$?"        # PASS three battery: 3/3 ... exit=0

# blob identity
git show HEAD:corpus/artifacts/glb-r12/README.md | sha256sum          # 0af4f369…
sha256sum corpus/artifacts/glb-r12/README.md                          # d87774dc…
```

---

## 9. Independent verification of this repair (not by this seat)

Two other r103 seats re-derived this repair independently, and both agree with §2–§6 above:

- `reports/round-103/b2/verify-glb.md` (SEAT-26 REPAIR-VERIFY-GLB) — **PASS** on the two commands
  the fold-spec accepts as exit-0 and on the diff-scope audit; reproduces the same blob pair
  (`0af4f369…` → `d87774dc…`), the same 19→19 line count, and the same 1693→1627 byte drop
  (= `3 × len('.shokunin/game-dev-3d/')` = 66). It independently reached the same split verdict on
  line 7 that §5 records, and routed `bpy_rbw3d_render` as a *new* flaky row.
- `reports/round-103/b2/ruling.md` §3.1 (SEAT-22 B2-RULING) — rules glb-r12 **"in-place mechanical
  repair — clean"**, owner **SEAT-23**, **no correction note required**, because the deciding test
  returns `cited in HEAD → 0`. It also names this seat's exact ownership:
  *"`corpus/artifacts/glb-r12/README.md` — **lines 6, 7, 8 only**"* + this report.

Neither verification is this seat's own work, and both were read after this file was first written.
