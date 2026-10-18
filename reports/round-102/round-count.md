# r102 round-count — the countable definition of done

**Seat:** SEAT-64 ROUND-COUNT-RECEIPT · round 102 · lane `game-dev-3d-shokunin`
**Owned path written:** this file only.
**Lane HEAD at every frame below:** `2c99b7b8155841617d844c609813afcba77aa207` (r101 report-last; work commit `1659c036`).
**Final frame:** `2026-10-18T17:43:14Z`.
**Scope:** count only. This seat wrote no other file, edited no source, and ran no `git` mutating command.

## 0. Read this before the table — the round was still landing while I counted

`reports/round-102/` was being written by ~60 concurrent seats during this seat's runtime. Observed file count went
`7 → 9 → 14 → 17 → 20 → 24 → 25 → 28 → 29 → 30` across my frames; `corpus/knowledge/engines.md` changed sha256
**twice** while I held the file (`b20e5a9b…` → `e6b42ecc…` → `d03907d3…`), and
`corpus/knowledge/unreal-mcp/gate/` went from **absent** to **present** between two consecutive tool calls.

So: **every number below carries the frame it was taken in, and is a snapshot, not a final state.** A row marked
**PENDING** is not a failure — it is work another seat owns that had not landed when the frame was taken. Re-run §5
at round close to get the closing numbers.

## 1. The count — one table, all commands pasted

Frame `2026-10-18T17:43:14Z`, HEAD `2c99b7b`.

| # | quantity | command (run from repo root) | observed output | target | status |
|---|---|---|---|---|---|
| A1 | r102 artifact files under `reports/round-102/` | `find reports/round-102 -type f \| wc -l` | `30` | ≥ the 33 r101 filed | **30 and still rising** |
| A2 | new files created under `corpus/` this round | `git status --porcelain -uall -- corpus/ \| grep -c '^??'` | `3` | — | 3 (gate `README.md` + `run_gate.sh` + none else) |
| A3 | modified tracked files under `corpus/` | `git status --porcelain -uall -- corpus/ \| grep -c '^ M'` | `5` | — | 5 (r22 README, engines.md, rea.md, subtree README, r22 lesson) |
| A4 | lesson files in `corpus/lessons/` | `ls corpus/lessons/*.md \| wc -l` | `91` | — | 91 (was 90 pre-round; +1) |
| B1 | gate `run_gate.sh` exists | `test -e corpus/knowledge/unreal-mcp/gate/run_gate.sh && echo yes \|\| echo NO` | `yes` | yes | **PASS** |
| B2 | gate exit code | `bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo $?` | `0` | 0 | **PASS** |
| B3 | gate checks passing | `bash …/run_gate.sh \| grep -c '^STEP=PASS'` | `4/4` | 4 | **PASS** |
| B4 | gate verdict line | `bash …/run_gate.sh \| tail -1` | `GATE RESULT: PASS (checks failed: 0)` | PASS | **PASS** |
| C1 | C1(b) lesson exists | `test -e corpus/lessons/r102-unreal-integration.md && echo PRESENT \|\| echo ABSENT` | `PRESENT` | PRESENT | **PASS** (landed mid-frame) |
| C2 | lesson size | `wc -c < corpus/lessons/r102-unreal-integration.md` ; `wc -l < …` | `11059` bytes / `178` lines | — | **PASS** |
| C3 | `engines.md` sha256 (short) | `sha256sum corpus/knowledge/engines.md \| cut -c1-16` | `d03907d3d63771c1` | ≠ `b20e5a9b3b964bf5` (pre-round) | **PASS — row updated** |
| C4 | C1(c) Unreal row carries the evidence-class update | `sed -n '10p' corpus/knowledge/engines.md \| grep -c 'two static evidence classes'` | `1` | 1 | **PASS** |
| C5 | three.js row carries the install step (F5 repair) | `sed -n '11p' corpus/knowledge/engines.md \| grep -c 'npm ci --prefix'` | `1` | 1 | **PASS** |
| D1 | F1a: phantom `.shokunin/game-dev-3d/` root in r22 README | `grep -c 'shokunin/game-dev-3d' corpus/artifacts/unreal-r22/README.md` | `0` | 0 | **GREEN** (was exit=2) |
| D2 | F1a positive command | `python3 corpus/artifacts/unreal-r22/verify_descriptor.py; echo $?` | `PASS local-static actual=accept expected=accept …` / `0` | 0 | **GREEN** |
| D3 | F1a negative command | `python3 …/verify_descriptor.py …/Headless3DFixture.bad-type.uplugin --expect-reject; echo $?` | `PASS local-static actual=reject expected=reject …` / `0` | 0 | **GREEN** |
| D4 | F1b: phantom root in r22 lesson | `grep -c 'shokunin/game-dev-3d' corpus/lessons/r22-unreal-review.md` | `0` | 0 | **GREEN** (7 lines fixed) |
| D5 | F2: cite of the absent `…/verdicts.json` | `grep -c '20261013T053632289732Z' corpus/lessons/r22-unreal-review.md` | `1` | 0 | **RED — PENDING** |
| D6 | F2: dated correction note present | `grep -ci 'correction' corpus/lessons/r22-unreal-review.md` | `0` | ≥1 | **RED — PENDING** |
| D7 | F3: stale `run_battery.py` digest `a065a56d…` | `grep -c 'a065a56db193228d' corpus/lessons/r22-unreal-review.md` | `1` | 0 | **RED — PENDING** |
| D8 | F6: `rea.md` dated correction note | `grep -c 'Correction note (r102' corpus/knowledge/rea.md` | `1` | ≥1 | **GREEN** |
| D9 | F6: stale clause preserved verbatim (discipline) | `grep -c 'no Ghidra, JADX, Binwalk/Unblob, pwntools' corpus/knowledge/rea.md` | `1` | 1 | **GREEN** |
| D10 | F8: subtree README 24-line wording fold | ``grep -c '24 lines, all `OK`' corpus/knowledge/unreal-mcp/README.md`` | `1` | 1 | **GREEN** |
| D11 | F5: repaired command on a **clean** tree | see §3 | `PASS … 3/3` / `0` | 0 | **GREEN** |
| D12 | F5: bare command on a clean tree (the defect, as a control) | see §3 | `FAIL positive … ` / `1` | 1 | **expected 1** — proves D11's fix is load-bearing |
| E1 | gate check 4, independent re-run | `bash reports/round-102/reruns/pointer-sweep.sh \| tail -2` | `POINTERS=47 … UNRESOLVED=0` / `STEP=PASS` | PASS | **PASS** |

### Tally

| bucket | green | red/pending |
|---|---|---|
| C1(a) gate | 4 of 4 checks | 0 |
| C1(b) lesson | 1 of 1 | 0 |
| C1(c) engines.md | 2 of 2 rows | 0 |
| C2 repair lattice (F1a, F1b, F2, F3, F5, F6, F8) | **5** (F1a, F1b, F5, F6, F8) | **2** (F2, F3) |
| round artifact files | 30 | — |

**Repair targets green: 5 of 7.** F2 and F3 are both on `corpus/lessons/r22-unreal-review.md` and both call for the
same repair shape (a dated correction note), so they are one seat's remaining work, not two independent blockers.

## 2. Every command in §1, pasted as one block

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
date -u +%Y-%m-%dT%H:%M:%SZ; git rev-parse HEAD
find reports/round-102 -type f | wc -l
git status --porcelain -uall -- corpus/ | grep -c '^??'
git status --porcelain -uall -- corpus/ | grep -c '^ M'
ls corpus/lessons/*.md | wc -l
test -e corpus/knowledge/unreal-mcp/gate/run_gate.sh && echo yes || echo NO
bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "GATE_RC=$?"
bash corpus/knowledge/unreal-mcp/gate/run_gate.sh 2>&1 | grep -c '^STEP=PASS'
bash corpus/knowledge/unreal-mcp/gate/run_gate.sh 2>&1 | tail -1
test -e corpus/lessons/r102-unreal-integration.md && echo PRESENT || echo ABSENT
wc -c < corpus/lessons/r102-unreal-integration.md; wc -l < corpus/lessons/r102-unreal-integration.md
sha256sum corpus/knowledge/engines.md | cut -c1-16
sed -n '10p' corpus/knowledge/engines.md | grep -c 'two static evidence classes'
sed -n '11p' corpus/knowledge/engines.md | grep -c 'npm ci --prefix'
grep -c 'shokunin/game-dev-3d' corpus/artifacts/unreal-r22/README.md
python3 corpus/artifacts/unreal-r22/verify_descriptor.py; echo "rc=$?"
python3 corpus/artifacts/unreal-r22/verify_descriptor.py corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin --expect-reject; echo "rc=$?"
grep -c 'shokunin/game-dev-3d' corpus/lessons/r22-unreal-review.md
grep -c '20261013T053632289732Z' corpus/lessons/r22-unreal-review.md
grep -ci 'correction' corpus/lessons/r22-unreal-review.md
grep -c 'a065a56db193228d' corpus/lessons/r22-unreal-review.md
grep -c 'Correction note (r102' corpus/knowledge/rea.md
grep -c 'no Ghidra, JADX, Binwalk/Unblob, pwntools' corpus/knowledge/rea.md
grep -c '24 lines, all `OK`' corpus/knowledge/unreal-mcp/README.md
bash reports/round-102/reruns/pointer-sweep.sh | tail -2
```

Verbatim transcript of the run that produced §1 (frame `2026-10-18T17:43:14Z`):

```
FRAME 2026-10-18T17:43:14Z  HEAD=2c99b7b
A1 reports/round-102 files      30
A2 new files under corpus/      3
A3 modified tracked under corpus/ 5
A4 lessons corpus/lessons/*.md  91
--- B gate ---
B1 gate/run_gate.sh present     yes
B2 gate exit code               0 (want 0)
B3 gate STEP=PASS lines         4/4
B4 gate final line              GATE RESULT: PASS (checks failed: 0)
--- C C1(b)/C1(c) ---
C1 lesson r102-unreal-integration.md PRESENT
C2 lesson size/lines            11059 bytes / 178 lines
C3 engines.md sha256 (short)    d03907d3d63771c1
C4 engines.md Unreal row updated (evidence-class wording) 1 (want 1)
C5 engines.md three.js row updated (install step)         1 (want 1)
--- D repair targets: before(fail) -> after(pass) ---
D1  F1a r22 README phantom root  0 (was fail; want 0)
D2  F1a positive cmd rc          0 (want 0)
D3  F1a negative cmd rc          0 (want 0)
D4  F1b r22 lesson phantom root  0 (was fail; want 0)
D5  F2 absent verdicts.json cite 1 (was fail; want 0)
D6  F2 correction note in lesson 0 (want >=1)
D7  F3 stale digest a065a56d     1 (was fail; want 0)
D8  F6 rea.md correction note    1 (want >=1)
D9  F6 rea.md stale clause kept  1 (want 1)
D10 F8 subtree README 24-line wording 1 (want 1)
D11 F5 repaired cmd, clean tree  0 (want 0)
D12 F5 bare cmd, clean tree      1 (was fail=1; still 1 until node_modules present)
--- E gate check 4 cross-check ---
FILES_SCANNED=16 POINTERS=47 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
```

## 3. The gate, run at this runtime — full output

The gate landed **between two of this seat's tool calls**, so this is the first receipt of it actually being run
from the lane root by a non-author seat.

```sh
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "GATE_RC=$?"
GATE unreal-mcp subtree
SUBTREE=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/knowledge/unreal-mcp
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
LANE_HEAD=2c99b7b8155841617d844c609813afcba77aa207

CHECK 1 manifest-byte-identity
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
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
STEP=PASS

CHECK 2 clone-equivalence
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0
CLONE_TRACKED=12
PATH_EXTRA=0 PATH_MISSING=0
BLOB_DIFFS=0
STEP=PASS

CHECK 3 verdict-card-scan
OK   unproven-runtime actors-scene.md                line 5
OK   static-only      animation-controlrig.md        line 4
OK   static-only      assets-content.md              line 15
OK   static-only      blueprints.md                  line 4
OK   static-only      editor-general.md              line 4
OK   static-only      gameplay-gas.md                line 4
OK   static-only      materials.md                   line 4
OK   static-only      meshes-textures.md             line 4
OK   static-only      scripting-programmatic.md      line 5
OK   static-only      sequencer.md                  line 5
OK   static-only      testing-automation.md          line 5
OK   static-only      ui-umg-slate.md               line 5
OK   static-only      vfx-niagara-dataflow.md       line 6
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
STEP=PASS

CHECK 4 pointer-sweep
POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS

GATE RESULT: PASS (checks failed: 0)
GATE_RC=0
```

The gate's own three negative controls are recorded in `reports/round-102/gate/controls.txt` and each turns it red
(byte-flip → `MANIFEST_OK=11 … FAILED=1`, `checks failed: 2`; deleted file → `PATH_MISSING=1`, `checks failed: 2`;
out-of-range pointer → `checks failed: 1`), so a green gate is discriminating, not vacuous.

**Note on the pointer count.** The gate prints `POINTERS=40`; the standalone re-run `reports/round-102/reruns/pointer-sweep.sh`
prints `POINTERS=47` over the same tree. Both report `UNRESOLVED=0`. The difference is the gate's extra
`gate/README.md` exclusion plus the fact that the standalone scanner runs after more seats wrote more markdown.
Both are green; the two numbers are not contradictory, they are different denominators.

## 4. F5: the repair target, before → after, captured

The defect is that the cited evidence command in `engines.md:11` did not reproduce from a committed tree.
Reproduced both ways from a read-only `git archive HEAD` export (no working-tree mutation):

```sh
$ T=$(mktemp -d); git archive HEAD corpus/fixtures/three | tar -x -C "$T"
$ (cd "$T" && node corpus/fixtures/three/run_cases.mjs); echo "rc=$?"
FAIL positive: exit=1 expected=0
FAIL negative_wrong_order: exit=1 expected=2
FAIL mutation: exit=1 expected=1
FAIL three battery: 3/3, seeds_unchanged=true
rc=1                                  # BEFORE — the defect, still reproducible (D12)

$ T=$(mktemp -d); git archive HEAD corpus/fixtures/three | tar -x -C "$T"
$ (cd "$T" && npm ci --prefix corpus/fixtures/three >/dev/null 2>&1; echo "npm-rc=$?")
npm-rc=0
$ (cd "$T" && node corpus/fixtures/three/run_cases.mjs); echo "rc=$?"
PASS positive: exit=0 expected=0
PASS negative_wrong_order: exit=2 expected=2
PASS mutation: exit=1 expected=1
PASS three battery: 3/3, seeds_unchanged=true
rc=0                                  # AFTER — the repaired evidence command in engines.md:11
```

The `rc=1` control is kept in the table on purpose: it is what makes the `rc=0` row mean something. Without the
install step the runner still fails, so the repaired command is doing real work and is not passing by accident.

## 5. Re-run this receipt at round close

The whole of §1–§4 is re-derivable. Paste §2's block; a closing run should differ from the frame above **only** in:

- `A1` — higher (more seats filing);
- `D5`, `D6`, `D7` — the F2/F3 rows on `corpus/lessons/r22-unreal-review.md`, expected to flip to `0 / ≥1 / 0`;
- `A3` — if a seat repairs the r22 lesson, it stays `5` (the file is already in the modified set).

Everything else — the gate's `4/4`, the lesson, both `engines.md` rows, F1a/F1b/F5/F6/F8 — should hold. If the gate
regresses, that is the one row worth escalating immediately, because the gate is the round's only self-contained
re-runnable check.

## 6. Post-write frame — the count moved again, as §0 predicted

Taken immediately after this file landed, to make the drift explicit rather than leave §1 as the last word:

```
$ date -u +%Y-%m-%dT%H:%M:%SZ
2026-10-18T17:43:36Z
$ find reports/round-102 -type f | wc -l
32                        # §1 A1 read 30; this file is +1, another seat +1
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh 2>&1 | tail -1
GATE RESULT: PASS (checks failed: 0)     # gate still green
$ grep -c 'a065a56db193228d' corpus/lessons/r22-unreal-review.md          # F3
1                         # still red
$ grep -c '20261013T053632289732Z' corpus/lessons/r22-unreal-review.md   # F2
1                         # still red
```

`A1` and `A3` are the only rows that move with the round still running; the gate, the lesson, both `engines.md`
rows and the five green repairs are stable across frames. F2/F3 remain the round's two open repair targets.

## 7. Boundaries

- **No Unreal runtime claim** is made anywhere in this file. Unreal Editor is not installed on this host; the gate's
  `verified-here=0` census is a property of the host, not an achievement. `unproven-runtime` stays `unproven-runtime`.
- This receipt counts artifacts and re-runs their commands. It does **not** judge whether any card's label is
  consistent with its evidence — that is a read-the-cards judgement, and the gate's own README says so.
- The `r101` subtree `corpus/knowledge/unreal-mcp/upstream/` and `.manifest.d/` were read-only to this seat. The
  only file this seat wrote is `reports/round-102/round-count.md`.
- The frame discipline in §0 is the honest caveat on every number here: a concurrent round means these are snapshots.
  `reports/round-102/reports-index.md` and `reports/round-102/ledger-check.md` reached the same conclusion independently.
