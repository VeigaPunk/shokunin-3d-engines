# SEAT-06 BASELINE — untouched-state integrity snapshot (round 102)

Round: r102 (gate integration + routed-defect repair).
Lane: game-dev-3d-shokunin. Seat: SEAT-06 BASELINE.
Captured (UTC): 2026-10-18T17:41:01Z.
Purpose: byte-stability reference for the round — the values below are what every
downstream r102 seat is measured against.

**Caveat that matters.** The work tree was **not clean at snapshot time**. Other
r102 seats had already written their own owned paths before this snapshot ran. So
each value below is given twice where it can differ: the **pristine-HEAD** value
(read straight out of the commit) and the **snapshot-time live** value. For every
item the two agree; the only tree-level drift is the three foreign files listed in
§5, none of which touch this seat's subject matter.

---

## 1. HEAD and tree state

| Item | Value | Command |
|---|---|---|
| HEAD | `2c99b7b8155841617d844c609813afcba77aa207` | `git rev-parse HEAD` |
| HEAD subject | `r101 report-last: verdict (all axes improved), LOG entry, SCORECARD block, adjudication addendum — work 1659c036` | `git log -1 --format='%H %s'` |
| `git status --porcelain -uall` rc | 0 | `git status --porcelain -uall` |
| Python | `Python 3.14.7` | `python3 -V` |

`git status --porcelain -uall` output at snapshot time (4 lines, 1 modified + 3 untracked):

```
 M corpus/artifacts/unreal-r22/README.md
?? reports/round-102/before/F2-verdicts-json.md
?? reports/round-102/before/F6-rea-census.md
?? reports/round-102/repairs/F1a-r22-readme.md
```

No `.gitignore` exists at repo root (`cat .gitignore` → `No such file or
directory`); `corpus/.gitignore` contains exactly `live/`, `__pycache__/`, `*.pyc`.
`git check-ignore -v reports/round-102/repairs/x.md` → rc=1 (reports/ is **not**
ignored; r102 report paths are tracked-visible).

## 2. `corpus/fixtures/run_battery.py` — AST row count and hash

| Item | Value | Command |
|---|---|---|
| sha256 (live) | `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` | `sha256sum corpus/fixtures/run_battery.py` |
| sha256 (HEAD blob) | `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` | `git show HEAD:corpus/fixtures/run_battery.py \| sha256sum` |
| CASES assignments | exactly **1** | `ast.parse` scan of module body |
| CASES value kind | `ast.List`, defined at **line 39** | `ast.parse` scan |
| CASES rows | **350** | `len(node.value.elts)` |
| first row kind | `ast.Tuple` | `ast.parse` scan |
| top-level statements | 27 | `len(ast.parse(src).body)` |

Live and HEAD blob hashes are identical — `run_battery.py` is untouched this round.
This `f456bd00…` value is the corrected citation that F3 replaces the stale
`a065a56db193228d2c5f3d0760c02972aee69d59c5c86480d7f9cf444a582570` with; the stale
string still appears at `corpus/lessons/r22-unreal-review.md:48` (and is quoted, as
history, in `reports/round-101/r101-critic-c3.md:201`) — both outside this seat.

Verbatim command and output:

```
$ python3 -c "import ast; t=ast.parse(open('corpus/fixtures/run_battery.py').read()); ..."
CASES assigns: 1
  type: List lineno: 39
  rows: 350
```

## 3. `corpus/knowledge/unreal-mcp` — sha256 sweep and manifest re-run

Scope: 40 files, 500K. 12 upstream files + 13 executability cards + 2 root docs
(`README.md`, `PROVENANCE.md`, `adaptation-kimi.md` = 3 root docs) + 12
`.manifest.d/*.sha256`.

### 3a. Manifest re-run (the rc that matters)

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
audit-rc=0
```

All 11 seat manifests re-verify as well (`sha256sum -c` per file, rc=0 each):

```
.manifest.d/seat01.sha256      OK      .manifest.d/seat07.sha256      OK
.manifest.d/seat02.sha256      OK      .manifest.d/seat08.sha256      OK
.manifest.d/seat03.sha256      OK      .manifest.d/seat09.sha256      OK
.manifest.d/seat04.sha256      OK      .manifest.d/seat10.sha256      OK
.manifest.d/seat05.sha256      OK      .manifest.d/seat11.sha256      OK
.manifest.d/seat06.sha256      OK
```

13 executability cards confirmed (`ls corpus/knowledge/unreal-mcp/executability/*.md | wc -l` → 13).

### 3b. Aggregate tree hash (stability reference)

```
$ find corpus/knowledge/unreal-mcp -type f | sort | xargs sha256sum > /tmp/r102_sweep.txt
sweep-rc=0
$ wc -l /tmp/r102_sweep.txt
40 /tmp/r102_sweep.txt
$ sha256sum /tmp/r102_sweep.txt
be1895e3f19421c62853109075fccf3c7653638be1389ca92d6402942d65c0b0  /tmp/r102_sweep.txt
```

The aggregate `be1895e3…` is the hash **of the sorted `sha256sum` listing** (i.e. of
the 40 per-file digests), not of file contents. It is the single value that must be
reproduced unchanged at r102 close for the subtree to count as byte-stable.

### 3c. Live index vs HEAD tree — byte-identical

```
$ git ls-tree -r HEAD corpus/knowledge/unreal-mcp --format='%(objectname) %(path)' | sort -k2 > /tmp/head_tree_unreal.txt
$ git ls-files -s corpus/knowledge/unreal-mcp | awk '{print $2"  "$4}' | sort -k2 > /tmp/live_idx_unreal.txt
$ diff /tmp/head_tree_unreal.txt /tmp/live_idx_unreal.txt && echo IDENTICAL_TO_HEAD
IDENTICAL_TO_HEAD
```

40 entries each; blob object ids match pairwise. Every file in the r101 unreal-mcp
subtree — including all 13 executability cards, `README.md`, `PROVENANCE.md`,
`adaptation-kimi.md`, and the 12 `.manifest.d` manifests — is byte-identical to the
HEAD commit. The r101 subtree is therefore still **byte-pinned and clean** as of
this snapshot; no r102 seat had modified it yet.

### 3d. Per-file sha256 sweep (40 lines, snapshot-time)

```
e0f8ca9b757d645221cc01d4508098b9c48ffc7a93619754d188a4fb67b4b981  corpus/knowledge/unreal-mcp/adaptation-kimi.md
3bba50abff45da0cb3b8d8fe2e909692adda5600bf4c6e7871ceaec4180bf9ff  corpus/knowledge/unreal-mcp/executability/actors-scene.md
2411f081a4f41967e6161c649b6b8f6895358492b431a4c493f65710a55c18de  corpus/knowledge/unreal-mcp/executability/animation-controlrig.md
d612f03f99db88af7c686f78de59ce9edb316deaefa90ad2c32771bec9c9d2b9  corpus/knowledge/unreal-mcp/executability/assets-content.md
f971ee1e4c74b251184a293c36c5868e04ad5c8acb5fc8caa6814123623ea660  corpus/knowledge/unreal-mcp/executability/blueprints.md
c9451497384e2616e59ee71e41c84b6e69ff6ce1acb816c61079bfaf82c2e58d  corpus/knowledge/unreal-mcp/executability/editor-general.md
a56cb31100123d1164128752fc1c68c0e7fe8656128cdb261956e7b86b608efd  corpus/knowledge/unreal-mcp/executability/gameplay-gas.md
f5d18a9848a026db032fad9127b637f99562fdc07280cabfc79ddfaa6a576f70  corpus/knowledge/unreal-mcp/executability/materials.md
7f33c3727ca52d51237ded97795601b017fbd3f4388472415a786047e169f777  corpus/knowledge/unreal-mcp/executability/meshes-textures.md
83c129e502f65ff99a8b730a63d31fe4e7866ce955c1cef57988b8722ee8190a  corpus/knowledge/unreal-mcp/executability/scripting-programmatic.md
8ca709e1bb6ebb7ad16a0dba348dddc34d05e66c9ba6150e44e43db80b3b723f  corpus/knowledge/unreal-mcp/executability/sequencer.md
0a0c85f5f896a1388cff01a8966c2ae375a0b2eba0184c59fc8b1c51014631aa  corpus/knowledge/unreal-mcp/executability/testing-automation.md
d908779d0f510907bd30705276b4452dc73b199abbee41ea6b7a6c709fa84727  corpus/knowledge/unreal-mcp/executability/ui-umg-slate.md
3eb04469551106a6368175229512dcc8e7932fbfb86092f30463f9d95a572251  corpus/knowledge/unreal-mcp/executability/vfx-niagara-dataflow.md
fe3906c5cc98cc62dabc4ef2a737694a76265c2ba14c12963512d4d887bc323a  corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256
3ad108c74406a7458c209353c9cf8bb6fff8dc1fb3d7b2a7fed3e035f217f4f4  corpus/knowledge/unreal-mcp/.manifest.d/seat01.sha256
d06036f41c11389291e3894d6a8af930689e1ce7f78bf28295af44321c43af6f  corpus/knowledge/unreal-mcp/.manifest.d/seat02.sha256
c8ab8cae7f24635c03df892ad0cb930dd038f1578fb36c5df10ebbc585e05971  corpus/knowledge/unreal-mcp/.manifest.d/seat03.sha256
abf8df4e1c3055fa76862b343c1879841d48d809693f4406138263bc632a926f  corpus/knowledge/unreal-mcp/.manifest.d/seat04.sha256
773fbbd2cc6ecb460684a65a73e836c2650f0f7bc9c498cfb091f8b53cc26f7d  corpus/knowledge/unreal-mcp/.manifest.d/seat05.sha256
7876c99c18ed740a9f105fa8c63a93e954f6fea226d92b4065328a7f5efbaf75  corpus/knowledge/unreal-mcp/.manifest.d/seat06.sha256
fcff225a0ae84f5475e233d70d183e58dfc3286f2b4d8500162355c8c402bfba  corpus/knowledge/unreal-mcp/.manifest.d/seat07.sha256
a01f03f0a68b74b0993a9402850d31edf0ecb3eafa4e3d9afd77ec83d88db724  corpus/knowledge/unreal-mcp/.manifest.d/seat08.sha256
f8409f8f94d575a761a92d3c4e00955e9fc24fe8cc5b4a7319a2d7f4ce47a3d7  corpus/knowledge/unreal-mcp/.manifest.d/seat09.sha256
b8c0492ff2ecc156b1b4612b437aec987b82e4ba48339dc481885dcc340d149e  corpus/knowledge/unreal-mcp/.manifest.d/seat10.sha256
86dbe11f32d00a91a9a0be61f7bca040fc115e5db8faad5e011791de0309f318  corpus/knowledge/unreal-mcp/.manifest.d/seat11.sha256
36938c71a0f5b1296b60ed505274d0b19fd87308eac61983525c2b2b44387f01  corpus/knowledge/unreal-mcp/PROVENANCE.md
2004a9e5aadcdc825c15f60e34e76a70cc0930556fc63f3b15e2ce0f371b17b9  corpus/knowledge/unreal-mcp/README.md
5aa984848f0fd48c94394651c66f5b200ee1e2583d8df8caeecc22bb550b4d44  corpus/knowledge/unreal-mcp/upstream/.claude-plugin/plugin.json
653d372559bee26d75fcee330142276c7d9cbccba214ef008ff5392b99550f0f  corpus/knowledge/unreal-mcp/upstream/CODEOWNERS
0fad2f57a9fac18ab4a66ac23d44485544bdabb5057c99b684d485f27b81e538  corpus/knowledge/unreal-mcp/upstream/.gitignore
259124f0631b7d4b92e9e744003e8798b910c00dac201656b97906b3b5ebdc0c  corpus/knowledge/unreal-mcp/upstream/hooks/hooks.json
d3f1c871cd4edd5210ee2f448c403e1a441e569a14a1405d1a3f199c65651fdd  corpus/knowledge/unreal-mcp/upstream/hooks/unreal-context.sh
5b337be051359edcdec510103aee15f5f870efb38b6d42eecd685dc3582314a6  corpus/knowledge/unreal-mcp/upstream/LICENSE
483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e  corpus/knowledge/unreal-mcp/upstream/README.md
e9d050087f36de51f7eeef49adb0ba9ebc603b65f74f475bc53a6debfc1f7b1c  corpus/knowledge/unreal-mcp/upstream/skills/create-toolset/SKILL.md
dbed002b4a46ab104274a31eb6682c3d277ce669216d0378df709f51567c3113  corpus/knowledge/unreal-mcp/upstream/skills/unreal-mcp/references/operations.md
bd16206ea142dc9cc1950b88af526a3137072ea152c5662e8549d21bc18a3b8a  corpus/knowledge/unreal-mcp/upstream/skills/unreal-mcp/references/setup.md
7ef8b991a82f591c5776bb5fa167c2bc2269fd00338ed3e8534eacc551d038fa  corpus/knowledge/unreal-mcp/upstream/skills/unreal-mcp/SKILL.md
7a0af781c458c7d192d6b23c16b5737922dc482470e2e4ef617bcda80f435087  corpus/knowledge/unreal-mcp/upstream/skills/unreal-skill/SKILL.md
```

Pinned upstream SHA for reference: `a6aa73ada02a9fb1f5415bec491f9942c519b297`
(recorded in `.manifest.d/audit-reference.sha256` header, clone at `/tmp/r101-audit`).

## 4. r102 deliverable existence at snapshot time (expected-absent)

| Path | State | Owner |
|---|---|---|
| `corpus/knowledge/unreal-mcp/gate/run_gate.sh` | **ABSENT** | C1(a) seat |
| `corpus/lessons/r102-unreal-integration.md` | **ABSENT** | C1(b) seat |

Verified with `test -e <path> && echo PRESENT || echo ABSENT` → `GATE_ABSENT`,
`LESSON_ABSENT`. Both are other seats' deliverables; recorded here only so the
r102 close can show they were created during the round, not before it.

`corpus/knowledge/engines.md` sha256 `b20e5a9b3b964bf5d8bd8fdba6f0349cf1c9fc30d949d8432e10a111a85cd06e`
(live) equals the HEAD blob sha256 — **untouched at snapshot time**. Its Unreal row
is currently `engines.md:10`:

```
| Unreal Engine | no | no | census at mint; r22 `corpus/artifacts/unreal-r22/` static authored `.uplugin` sample and non-author review | not installed; local JSON checks do not prove plugin load, UBT compilation or engine runtime |
```

This is the row C1(c) is scheduled to update with the r101 evidence class; the
hash above is the pre-update reference.

## 5. Foreign (other-seat) drift present at snapshot — for the round record

Not this seat's to fix, listed only because it makes the tree non-clean and must be
accounted for at round close:

- `corpus/artifacts/unreal-r22/README.md` — **modified** (F1 repair, in progress).
  HEAD blob `26a126047b7fb7671f5216313ee8938a6076a4c3de5cfd06fb11b4338c751cba`;
  snapshot-time live `1c0d30355b34a76dc45ff27e9e684e9fe9595973e09bbc48519ad3618fea574b`.
  Diff replaces the phantom `.shokunin/game-dev-3d/` prefix with repo-root-relative
  paths on two lines (this is F1's before→after).
- `reports/round-102/before/F2-verdicts-json.md` — untracked, new.
- `reports/round-102/before/F6-rea-census.md` — untracked, new.
- `reports/round-102/repairs/F1a-r22-readme.md` — untracked, new.

## 6. Stale-defect observations confirmed while snapshotting

Recorded as baseline context only; these are other seats' repair targets.

- **F3 (stale `run_battery.py` sha).** Stale string
  `a065a56db193228d2c5f3d0760c02972aee69d59c5c86480d7f9cf444a582570` survives at
  `corpus/lessons/r22-unreal-review.md:48` (grep hit; rc=0). Correct value is
  `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` (§2). The same
  stale string is also *quoted as history* at `reports/round-101/r101-critic-c3.md:201`
  — that one is a historical record, not a live citation.
- **F6 (`rea.md` tool census).** `corpus/knowledge/rea.md:8` still reads
  `(no Ghidra, JADX, Binwalk/Unblob, pwntools on this host — census as of …)`, but at
  snapshot time all three named tools resolve:
  `jadx /usr/bin/jadx`, `binwalk /usr/bin/binwalk`, `unblob /home/vgpnk/.local/bin/unblob`.
  The claim is stale in the tree's favour (tools are now present), which is exactly
  what F6 is routed to correct.

## 7. Reproduction block

Every number above is re-runnable from repo root (`/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`):

```sh
git rev-parse HEAD
git log -1 --format='%H %s'
git status --porcelain -uall
sha256sum corpus/fixtures/run_battery.py
git show HEAD:corpus/fixtures/run_battery.py | sha256sum
python3 -c "import ast;t=ast.parse(open('corpus/fixtures/run_battery.py').read());print([(n.lineno,len(n.value.elts)) for n in t.body if isinstance(n,ast.Assign) and any(getattr(x,'id',None)=='CASES' for x in n.targets)])"
cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256
cd corpus/knowledge/unreal-mcp && for f in .manifest.d/seat*.sha256; do sha256sum -c "$f" >/dev/null 2>&1 && echo "$f OK" || echo "$f FAIL"; done
find corpus/knowledge/unreal-mcp -type f | sort | xargs sha256sum > /tmp/r102_sweep.txt; sha256sum /tmp/r102_sweep.txt
git ls-files -s corpus/knowledge/unreal-mcp | awk '{print $2"  "$4}' | sort -k2 > /tmp/live_idx_unreal.txt
git ls-tree -r HEAD corpus/knowledge/unreal-mcp --format='%(objectname) %(path)' | awk '{print $1"  "$2}' | sort -k2 | diff - /tmp/live_idx_unreal.txt && echo IDENTICAL_TO_HEAD
```

Expected: HEAD `2c99b7b…`; `run_battery.py` sha `f456bd00…` both live and in HEAD;
one CASES list of 350 rows at line 39; 12/12 audit OK; 11/11 seat manifests OK;
aggregate sweep hash `be1895e3f19421c62853109075fccf3c7653638be1389ca92d6402942d65c0b0`;
`IDENTICAL_TO_HEAD`.

---

## 8. POST-SNAPSHOT NOTE (added 2026-10-18, after the snapshot in §1–§7)

§1–§7 describe the tree **as it stood at 2026-10-18T17:41:01Z**. Round work
continued after that instant, so the §7 block no longer reproduces verbatim. The
divergence is expected and is recorded here rather than by rewriting §1–§7, which
remain the frozen baseline record.

- **§3b aggregate sweep hash moved.** It is now
  `08477100ba5572635f8b08cd73c57e520c06af08fd06472376ce268d0e3e028f` (was
  `be1895e3f19421c62853109075fccf3c7653638be1389ca92d6402942d65c0b0`). Re-ran
  `find corpus/knowledge/unreal-mcp -type f | sort | xargs sha256sum | sha256sum`
  → `08477100…`. Cause: one file changed.
- **Cause: the F8 wording fold landed** in `corpus/knowledge/unreal-mcp/README.md`
  (the file's owning seat). sha256 `2004a9e5aadcdc825c15f60e34e76a70cc0930556fc63f3b15e2ce0f371b17b9`
  → `ef17c7759c69888f57376603fbaeed79f9ab9eed73d03a39d4fee22b701b71cb`. The diff
  resolves the `:187` "12 lines" ambiguity by documenting both sweeps (12 `OK` from
  `audit-reference.sha256`, 24 `OK` from `.manifest.d/*.sha256`) and relabels the
  observed-output block accordingly. All other 39 subtree files are unchanged, and
  every manifest still re-verifies (`sha256sum -c .manifest.d/audit-reference.sha256`
  rc=0; 11/11 seat shards OK), so the pin holds — only the aggregate listing digest
  moves.
- **§5 foreign drift grew.** `corpus/knowledge/unreal-mcp/README.md` and
  `corpus/lessons/r22-unreal-review.md` (7 insertions / 7 deletions, F3 sha
  correction) are now also modified; new untracked files
  `reports/round-102/battery-integrity.md`, `reports/round-102/before/F3-sha-drift.md`,
  `reports/round-102/before/F5-engines-threejs.md` appeared. None are this seat's.
- **Still unchanged and still valid:** HEAD `2c99b7b…`, `run_battery.py` sha
  `f456bd00…` (live = HEAD blob), CASES 350 rows at line 39, all 12 audit-reference
  entries OK, all 11 seat manifests OK, and the pre-fold subtree index vs HEAD tree
  identity in §3c.

At r102 close, the byte-stability check should therefore assert the **post-fold**
sweep hash `08477100…` for the subtree, and may additionally assert that the only
subtree file whose digest differs from §3d is `README.md`.

---

No Unreal runtime claim is made anywhere in this document. The Unreal Editor and
UnrealBuildTool are not installed on this host; all Unreal statements above are
file-level facts (hashes, paths, static text) only, and prove nothing about plugin
load, compilation, or engine runtime behaviour.
