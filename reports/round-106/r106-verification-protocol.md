# r106 close-out verification protocol

**Seat:** SEAT-62 VERIFIER-CHAIR · lane `game-dev-3d-shokunin`
**Owned path:** this file only. Scratch used for the write-time gate probe was removed after the lines below were copied; it is not a close receipt.
**Axes:** coverage (C1) / depth (C2) / calibration (C3).
**Written:** 2026-10-18, last measurement `2026-10-18T21:44:11Z`, against worktree `HEAD=0cc3f4162f8c319f8d01a69a174fe939f36701bd` (r105 report-last; work `3634bc0`).
**This is a protocol, not a close verdict.** Run the ordered checks on the final bytes after writers stop. A missing artifact, a stale review, a wrong output, or an unrun step is **not passed**. No average. A dispatched reviewer does not promote the lane.

Do not `git commit`, `push`, `checkout`, or `reset`. Do not write into `reports/round-101` … `reports/round-105`, `LOG.md`, `SCORECARD.md`, `SHONEN.md`, `PROVINCE.md`, `SKILL.md`, `corpus/knowledge/unreal-mcp/upstream/**`, `.manifest.d/**`, `gate/**`, or any `corpus/fixtures/**` code. Scratch for these checks goes under `reports/round-106/scratch/close-protocol/` or `$HOME`. Never `/tmp` (per-user quota exhausted; tmpfs was 13G/16G, 80% full, at protocol-write).

## 0. What a green close must show

| claim | axis | green only if |
|---|---|---|
| **C1** | coverage | 18 sweep chunks plus the required sweep audits exist; every path-root edit carries a dated r106 note; historical counts and 64-hex digests are not dropped; sweepable fenced `.shokunin/game-dev-3d` commands are 0; judgment defects are queued, not silently rewritten |
| **C2** | depth | `engines.md` differs from HEAD and records the two-state model; all 4 installed/headless cells are the same classes as HEAD; every census probe file exists and its cited receipt resolves; the closer's own default-cannon / pinned-cannon / free_ops spot checks match the classes below; no new engine row; no Unreal or Unity runtime claim |
| **C3** | calibration | 4 consistency chunks plus receipt/two-state/verify reports exist; quoted shas and battery totals match the live tree or carry a dated note; receipt citations resolve or are dated non-resolvable; `337/350` is never paired with the pinned env and `350/350` is never paired with the default env |

**Guards** (block admission even if a claim looks green): protected paths byte-identical to `0cc3f41`; runner and `phys3d_joints.gd` hashes unchanged; gate live `POINTERS` equals the protected README pin; card census stays `12/1/0`; r105 N24 receipt bytes unchanged.

**Not claims.** The jolt class (SEAT-49/50/51) is a routed investigation. The P/C package stays proposed. `citation-form-rule.md` is a proposal and must not have been applied to `SKILL.md`. A green gate is not an Unreal Editor result.

### 0.1 Pinned constants — re-derive, do not inherit

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
BASE=0cc3f4162f8c319f8d01a69a174fe939f36701bd
N24=/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
RUNNER_SHA=f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f
JOINTS_SHA=80bf44c53255a0a33b2282ca4e6278d42d82be4f616252925e128c928eca81e6
SKILL_SHA=8ea7ae5c306913d44340454ca242579ff1f6c9ba29007efdb7943757bbf36371
GATE_SHA=390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf
GATE_README_SHA=e3bc66b7f5d981a1128dc60ae910ec7c53dac85107c67802134e32bc7c0e98bf
R104_JSON=reports/round-104/physics/full-regression-runs/20261018T194637610772Z-verdicts.json
R105_CLEAN=reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json
R105_FIRST=reports/round-105/n24/runs/node24-full-20261018T202944Z.verdicts.json
```

Write-time hashes of those four files, from `sha256sum` in this seat: runner `f456bd00…1ef69f`; joints `80bf44c5…eca81e6`; SKILL `8ea7ae5c…bbf36371`; gate script `390a25ae…e57b2cf`; gate README `e3bc66b7…7c0e98bf`. `R105_CLEAN` sha256 `54b7140de9a24ab6422e9391376d0134c3bafdc29ff21fa45197afc2338046e5`. `R105_FIRST` sha256 `cca760d3f12d753e126adb759eeefc6923b6c5b80bab91893114c5e28bd5d0d5`. HEAD engines blob was `5eef89d484b60e26ab78c29dd86a64781b0df86f` (sha256 `d03907d3d63771c10558a2bc276d62c50bcdea1d02150d78e6d1a720a0c3bddf`). Do not require the worktree engines blob to stay at that value — C2 requires it to move, with state cells unmoved.

## 1. Write-time observations — not acceptance

Commands this seat actually ran, and what they printed. The tree was moving (lesson diffs and an `engines.md` rewrite landed during this write). None of these lines close a claim.

- `git rev-parse HEAD` → `0cc3f4162f8c319f8d01a69a174fe939f36701bd`. `git status --porcelain` on LOG/SCORECARD/SHONEN/PROVINCE/SKILL, `reports/round-101`…`105`, `corpus/knowledge/unreal-mcp`, and `corpus/fixtures` → empty at `2026-10-18T21:34:51Z`.
- `node --version` → `v26.12.0` at `/home/vgpnk/.local/share/mise/installs/node/latest/bin/node`. `PATH="$N24:$PATH" node --version` → `v24.21.0` at `$N24/node`. `godot --headless --version` → `4.7.2.stable.arch_linux.ed1daf0bf`. `blender --version` first line → `Blender 5.2.1 LTS`. `command -v UnrealEditor`, `UnrealEditor-Cmd`, `unity`, `Unity`, `UnityHub` → absent. `ls /opt/UnrealEngine` and `ls /opt/Unity` → absent. `ls -d .shokunin` → exit 2.
- AST count of `CASES` in `corpus/fixtures/run_battery.py` → `CASES=350`. `git ls-tree -r --name-only HEAD -- corpus/lessons` → 92 `.md` + 4 `.json` (96). `corpus/knowledge/engines.md` tooling table at HEAD → 4 rows: Godot installed `yes` / headless `yes`; Unity `no`/`no`; Unreal `no`/`no`; three.js `0.186.1` lane-local / headless `partial`. Package and lock both say three `0.186.1`.
- Python parse of `R104_JSON` → top-level `verdict=FAIL`, `seeds_unchanged=True`, 350 results, `PASS=337`, `FAIL=13`, all 13 named `r94_cannon_*`, timeout 20, runner sha the pin above, `PINNED-ENV.md` absent from that seed map. Parse of `R105_CLEAN` → `verdict=PASS`, `seeds_unchanged=True`, 350/350, timeout 20, same runner sha, `PINNED-ENV.md` present. Parse of `R105_FIRST` → row verdicts 350 PASS but top-level `verdict=FAIL` and `seeds_unchanged=False`. That first capture is not a clean pass.
- Card label read of `corpus/knowledge/unreal-mcp/executability/*.md` → 13 cards, `static-only=12`, `unproven-runtime=1` (`actors-scene.md`), `verified-here=0`. Exact ``Not `unproven-runtime` `` hits in 6 files: `animation-controlrig.md`, `blueprints.md`, `editor-general.md`, `gameplay-gas.md`, `materials.md`, `meshes-textures.md`.
- Active README section `## Expected output — pinned summary` contains `POINTERS=103`. This seat then ran `GATE_WORKDIR=$PWD/reports/round-106/scratch/seat62-gate bash corpus/knowledge/unreal-mcp/gate/run_gate.sh` at HEAD `0cc3f41`. Observed: `GATE_RC=0`, four `STEP=PASS`, `MANIFEST_OK=12 EXPECTED=12 FAILED=0`, `CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297`, `CARDS=13`, `CENSUS static-only=12 unproven-runtime=1 verified-here=0`, `POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0`, `GATE RESULT: PASS (checks failed: 0)`, stderr empty. That is one snapshot, not the final-byte rerun in §7.
- Dead-root classifier at `2026-10-18T21:34Z` (before the sweep finished): `corpus/lessons/*.md` 80 files, 129 fenced hits, 168 prose hits. `corpus/knowledge/**/*.md`, artifact READMEs, and fixture READMEs: 0. Protected and therefore not a sweep edit target: `PROVINCE.md:25` and `:46`; `LOG.md` 73 hits; `SCORECARD.md` 2 hits; fixture code comments in `crash_exit3d.gd`, `stream_attribution3d.gd`, `timeout_tree3d.gd`, `three/scene_graph.mjs`.
- In-flight, not final: `git diff --numstat HEAD -- corpus/lessons` showed r61–r68 path-root edits plus an r105 environment-pairing insertion. The observed fix idiom keeps the historical count in place and appends ``> **Correction note (r106, 2026-10-18) — path root only.**``. The observed total-pairing idiom is `**Environment pairing (r106, 2026-10-18).**` and still contains `337/350`. At `2026-10-18T21:44:11Z`, `engines.md` was already dirty (`105 insertions, 5 deletions`, blob `6ba513fd20d39cac156b5370b64b8a1c02cb8b19`, sha256 `62a70d04…023af19d`) and its tooling cells were still yes/yes, no/no, no/no, partial. That blob is not a close hash. `SKILL.md:184` still stamps engines.md at `d03907d3…`; SKILL is protected, so that stamp goes stale when engines.md lands. Queue it. Do not edit SKILL to refresh it.

## 2. Freeze and allowlist — run first

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
BASE=0cc3f4162f8c319f8d01a69a174fe939f36701bd
git rev-parse HEAD
git merge-base --is-ancestor "$BASE" HEAD; echo ancestor_rc=$?
git status --porcelain -- LOG.md SCORECARD.md SHONEN.md PROVINCE.md SKILL.md \
  reports/round-101 reports/round-102 reports/round-103 reports/round-104 reports/round-105 \
  corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d \
  corpus/knowledge/unreal-mcp/gate corpus/fixtures/run_battery.py \
  corpus/fixtures/phys3d_joints.gd
sha256sum corpus/fixtures/run_battery.py corpus/fixtures/phys3d_joints.gd SKILL.md \
  corpus/knowledge/unreal-mcp/gate/run_gate.sh corpus/knowledge/unreal-mcp/gate/README.md
git diff --name-only "$BASE" -- corpus/fixtures
```

**Expected:** ancestor rc `0`. Protected porcelain empty. Runner sha `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`. Joints sha `80bf44c53255a0a33b2282ca4e6278d42d82be4f616252925e128c928eca81e6`. SKILL sha `8ea7ae5c306913d44340454ca242579ff1f6c9ba29007efdb7943757bbf36371`. Gate script sha `390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf`. Gate README sha `e3bc66b7f5d981a1128dc60ae910ec7c53dac85107c67802134e32bc7c0e98bf`. Fixture diff empty or only `corpus/fixtures/README.md` and/or `corpus/fixtures/PINNED-ENV.md`.

Worktree mode (pre-commit, what SEAT-128 runs) may be dirty. Landed mode (after the operator commits) must have empty `git status --porcelain` and `git diff --check "$BASE"..HEAD` silent. Either mode, every tracked or untracked path outside `reports/round-106/` must be on this allowlist:

- `corpus/lessons/` existing files only (no new path, no deletion)
- `corpus/knowledge/engines.md`
- `corpus/knowledge/rea.md`
- `corpus/knowledge/seed.md`
- `corpus/README.md`
- `corpus/artifacts/**/*.md` only
- `corpus/fixtures/README.md`
- `corpus/fixtures/PINNED-ENV.md`

```sh
python3 - <<'PY'
import subprocess
from pathlib import Path
base = '0cc3f4162f8c319f8d01a69a174fe939f36701bd'
out = subprocess.check_output(['git','status','--porcelain','-uall'], text=True)
bad = []
for line in out.splitlines():
    path = line[3:].split(' -> ')[-1]
    if path.startswith('reports/round-106/'):
        continue
    ok = (
        path.startswith('corpus/lessons/')
        or path in {
            'corpus/knowledge/engines.md','corpus/knowledge/rea.md',
            'corpus/knowledge/seed.md','corpus/README.md',
            'corpus/fixtures/README.md','corpus/fixtures/PINNED-ENV.md'}
        or (path.startswith('corpus/artifacts/') and path.endswith('.md'))
    )
    if not ok:
        bad.append(line)
print('ALLOWLIST_VIOLATIONS=%d' % len(bad))
for b in bad:
    print(b)
# lesson set equality
head = subprocess.check_output(['git','ls-tree','-r','--name-only',base,'--','corpus/lessons'], text=True).split()
head_md = sorted(p for p in head if p.endswith('.md'))
now_md = sorted(str(p) for p in Path('corpus/lessons').glob('*.md'))
print('LESSON_MD_HEAD=%d LESSON_MD_NOW=%d LESSON_NEW=%d LESSON_MISSING=%d' % (
    len(head_md), len(now_md), len(set(now_md)-set(head_md)), len(set(head_md)-set(now_md))))
shrunk = []
for p in head_md:
    old = subprocess.check_output(['git','show',f'{base}:{p}'])
    new = Path(p).read_bytes()
    if len(new.splitlines()) < len(old.splitlines()):
        shrunk.append(p)
print('LESSON_SHRUNK=%d' % len(shrunk))
for p in shrunk:
    print('SHRUNK', p)
PY
```

**Expected:** `ALLOWLIST_VIOLATIONS=0`, `LESSON_MD_HEAD=92`, `LESSON_MD_NOW=92`, `LESSON_NEW=0`, `LESSON_MISSING=0`, `LESSON_SHRUNK=0`. A new lesson file, a deleted lesson, a shrunk lesson, or a fixture `.gd`/`.py`/`.mjs` diff is RED.

## 3. C1 — sweep artifacts and the dated-note rule

These files must exist, be non-empty, and name at least one command that was run:

`reports/round-106/sweep/chunk-01.md` … `chunk-18.md`, `skill-audit.md`, `province-audit.md`, `verify-sample.md`, `verify-queue.md`, `adversary.md`, `math.md`, `fix-leader-1.md`, `fix-leader-2.md`, `queue-distill.md`, `crosscheck-a.md`, `crosscheck-b.md`, `crosscheck-c.md`, `crosscheck-d.md`, `sentinel.md`, `bleed.md`, `lesson-integrity.md`, `hygiene.md`, `close-grep.md`, `stats.md`, plus `reports/round-106/citation-form-rule.md`.

`fix-leader-1.md` / `fix-leader-2.md` may say no cross-chunk fix was queued. That sentence is a pass for that file. Silence is not. `citation-form-rule.md` must stay a proposal: `SKILL.md` sha remains the constant above.

`verify-sample.md` must re-test `max(8, ceil(0.2 * files_fixed))` fixed files, or every fixed file if fewer than 8 were fixed. If it names zero fixes, §4's fence count must still be 0. A sample that only re-reads the chunk report is not a re-test.

Dated-note discipline, on the final lesson bytes:

```sh
python3 - <<'PY'
import re, subprocess
from pathlib import Path
base = '0cc3f4162f8c319f8d01a69a174fe939f36701bd'
names = subprocess.check_output(['git','diff','--name-only',base,'--','corpus/lessons'], text=True).split()
silent_path = dropped_counts = dropped_sha = 0
count_re = re.compile(r'\b\d+/\d+\b')
sha_re = re.compile(r'\b[0-9a-f]{64}\b')
for rel in names:
    old = subprocess.check_output(['git','show',f'{base}:{rel}'], text=True, errors='replace')
    new = Path(rel).read_text(errors='replace')
    noted = ('r106' in new) and ('2026-10-18' in new)
    if '.shokunin/game-dev-3d' in old and old.count('.shokunin/game-dev-3d') != new.count('.shokunin/game-dev-3d') and not noted:
        silent_path += 1
        print('SILENT_PATH', rel)
    miss_c = set(count_re.findall(old)) - set(count_re.findall(new))
    miss_s = set(sha_re.findall(old)) - set(sha_re.findall(new))
    if miss_c or miss_s:
        dropped_counts += len(miss_c)
        dropped_sha += len(miss_s)
        print('DROPPED', rel, 'counts', sorted(miss_c), 'sha', len(miss_s))
print('FILES_CHANGED=%d SILENT_PATH_REWRITE=%d DROPPED_COUNTS=%d DROPPED_SHA=%d' % (
    len(names), silent_path, dropped_counts, dropped_sha))
PY
```

**Expected:** `SILENT_PATH_REWRITE=0`, `DROPPED_COUNTS=0`, `DROPPED_SHA=0`. A path-root edit without `r106` and `2026-10-18` in that file is RED. A historical `N/M` or 64-hex digest that the new file no longer contains anywhere — including inside the dated note — is RED. Rewording a command from `.shokunin/game-dev-3d/corpus/...` to `corpus/...` is allowed only with that note. Changing a verdict, a count, or a digest in place without keeping the old token in the note is a silent rewrite.

Same rule if `corpus/knowledge/rea.md`, `seed.md`, `corpus/README.md`, artifact READMEs, `corpus/fixtures/README.md`, or `PINNED-ENV.md` changed: dated note required for any dropped count or sha. `PINNED-ENV.md` must still contain the command-scoped `PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH"` form. It must not say the default environment is 350/350.

`sweep/sentinel.md` must say the landed edits are citation-path or dated-note class. If sentinel and this script disagree, the script wins and C1 is RED.

## 4. C1 — dead-root runnable contexts

Sweepable set: `corpus/lessons/*.md`, `corpus/knowledge/**/*.md` except `unreal-mcp/upstream/**` and `unreal-mcp/gate/**`, `corpus/artifacts/**/*.md`, `corpus/README.md`, `corpus/fixtures/README.md`, `corpus/fixtures/PINNED-ENV.md`. Do not edit protected ledgers or fixture code to make this count zero.

```sh
python3 - <<'PY'
from pathlib import Path
token = '.shokunin/game-dev-3d'
roots = [Path('corpus/lessons'), Path('corpus/knowledge'), Path('corpus/artifacts'), Path('corpus/README.md'), Path('corpus/fixtures/README.md'), Path('corpus/fixtures/PINNED-ENV.md')]
files = []
for r in roots:
    if r.is_file():
        files.append(r)
    else:
        files.extend(p for p in r.rglob('*.md') if 'upstream' not in p.parts and 'gate' not in p.parts and p.suffix == '.md')
fence = unnoted = noted = 0
for p in files:
    text = p.read_text(errors='replace')
    in_fence = False
    has_note = ('r106' in text and '2026-10-18' in text)
    for i, line in enumerate(text.splitlines(), 1):
        if line.strip().startswith('```'):
            in_fence = not in_fence
            continue
        if token not in line:
            continue
        if in_fence:
            fence += 1
            print(f'FENCE {p}:{i}')
        elif line.lstrip().startswith('>') or 'Correction note (r106' in line:
            noted += 1
        elif has_note and ('historical' in line.lower() or 'was `' in line or 'prefix' in line.lower()):
            noted += 1
        else:
            unnoted += 1
            print(f'UNNOTED {p}:{i} {line.strip()[:160]}')
print(f'DEAD_ROOT_FENCE_SWEEPABLE={fence} DEAD_ROOT_PROSE_UNNOTED={unnoted} DEAD_ROOT_NOTED={noted}')
PY
```

**Expected:** `DEAD_ROOT_FENCE_SWEEPABLE=0` and `DEAD_ROOT_PROSE_UNNOTED=0`. Remaining hits are allowed only on a correction-note quote. Protected leftovers are not C1 failures if untouched: `PROVINCE.md` (2), `LOG.md`, `SCORECARD.md`, and the four fixture-code files named in §1. A diff against those protected paths is a guard failure, not a successful sweep.

**C1 close line:** `C1=PASS` only if §3 artifacts exist, `SILENT_PATH_REWRITE=0`, `DROPPED_COUNTS=0`, `DROPPED_SHA=0`, both dead-root counts are 0, and `sweep/queue-distill.md` lists every unfixed judgment defect the chunk reports named. Otherwise `C1=RED`.

## 5. C2 — census files and state cells

These files must exist and each must name a command plus an observed verdict or absence:

`reports/round-106/census/godot.md`, `three-default.md`, `three-pinned.md`, `cannon.md`, `bullet.md`, `gltf.md`, `navagent.md`, `phys3d-events.md`, `phys3d-joints.md`, `area3d.md`, `animtree.md`, `bpy.md`, `n24-state.md`, `adversary.md`, `verify.md`, `bleed.md`, plus `reports/round-106/engine-count.md` and `reports/round-106/engine-cmd-regression.md`.

`census/verify.md` must record four independent re-runs, not a reread of the author transcript. `engine-cmd-regression.md` must list zero unexplained failures. A failure that engines.md has already date-corrected may stand; an uncorrected red command is C2 RED.

State cells against the HEAD blob, not against this protocol's snapshot:

```sh
python3 - <<'PY'
import subprocess
from pathlib import Path
base = '0cc3f4162f8c319f8d01a69a174fe939f36701bd'
old = subprocess.check_output(['git','show',f'{base}:corpus/knowledge/engines.md'], text=True)
new = Path('corpus/knowledge/engines.md').read_text()
print('ENGINES_CHANGED=%s' % ('yes' if old != new else 'no'))

def tooling(text):
    rows = []
    for line in text.splitlines():
        if not line.startswith('| ') or line.startswith('| tooling') or line.startswith('|---') or line.startswith('| state '):
            continue
        cells = [c.strip() for c in line.strip().strip('|').split('|')]
        if cells and cells[0].split()[0] in {'Godot','Unity','Unreal','three.js'}:
            rows.append(cells)
    return rows
o, n = tooling(old), tooling(new)
print('ENGINE_ROWS=%d' % len(n))
promotions = 0
for a, b in zip(o, n):
    # installed / headless are cells 1 and 2
    same = (a[1] == b[1] and a[2] == b[2]) or (
        a[0].startswith('three.js') and b[2].startswith('partial') and 'yes' not in b[1][:4]
        and a[1].startswith('lane-local') and '0.186.1' in b[1] and not b[1].startswith('yes'))
    # Godot/Unity/Unreal must be exact on the two state cells
    if not a[0].startswith('three.js'):
        same = (a[1] == b[1] and a[2] == b[2])
    print(('SAME' if same else 'MOVED'), a[0], '|', b[1][:60], '|', b[2][:60])
    if not same:
        promotions += 1
print('STATE_CELLS_UNMOVED=%d/4 ENGINE_PROMOTIONS=%d' % (4-promotions, promotions))
row = next(r for r in n if r[0].startswith('three.js'))
print('THREE_TABLE_HAS_V26_11_1=%s' % ('yes' if 'v26.11.1' in row[1] or 'v26.11.1' in row[2] else 'no'))
print('HAS_DEFAULT_NODE=%s HAS_PINNED_NODE=%s' % ('v26.12.0' in new, 'v24.21.0' in new))
print('CLAIMS_UNREAL_RAN=%s' % ('yes' if 'Unreal Editor ran' in new or 'verified-here=1' in new else 'no'))
# citations
missing = []
scratch_only = 0
for token in __import__('re').findall(r'reports/round-10[456]/[A-Za-z0-9_./+-]+\.(?:json|md|stdout)', new):
    path = token.split()[0].rstrip(').,;')
    if not Path(path).is_file():
        missing.append(path)
    elif '/scratch/' in path:
        scratch_only += 1
print('ENGINES_CITATIONS_MISSING=%d ENGINES_SCRATCH_CITATIONS=%d' % (len(missing), scratch_only))
for m in missing:
    print('MISSING', m)
PY
```

**Expected:** `ENGINES_CHANGED=yes`. `ENGINE_ROWS=4`. `STATE_CELLS_UNMOVED=4/4`. `ENGINE_PROMOTIONS=0`. Godot installed cell still `yes (`/usr/bin/godot`)`, headless cell still `yes`. Unity and Unreal installed and headless cells still `no`. three.js headless cell still begins with `partial` and does not become `yes`. `THREE_TABLE_HAS_V26_11_1=no` (the string may survive only inside a dated correction note, not in the tooling row). `HAS_DEFAULT_NODE=True`, `HAS_PINNED_NODE=True`. `CLAIMS_UNREAL_RAN=no`. `ENGINES_CITATIONS_MISSING=0`.

Scratch citations are WEAK. They pass only while the file still exists **and** `reports/round-106/receipt-durability.md` names a sha-matched copy outside a `scratch` directory. A missing cited path is RED. No fifth tooling row (`cannon-es` is not an engine row). `census/adversary.md` may tighten this ceiling; it may not loosen a state cell. If adversary says a receipt is too weak to support a sentence in engines.md, that sentence must be marked bounded or C2 is RED.

Do not require a new 350-case battery. The full-run facts are the frozen receipts in §6.

## 6. C2 — closer spot checks and the frozen totals

Identity, then three bounded rows. Receipts go under `reports/round-106/scratch/close-protocol/`, not `/tmp` and not a frozen round directory.

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
N24=/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin
node --version
command -v node
PATH="$N24:$PATH" node --version
PATH="$N24:$PATH" command -v node
sha256sum corpus/fixtures/run_battery.py
mkdir -p reports/round-106/scratch/close-protocol
python3 corpus/fixtures/run_battery.py --only r94_cannon_nan \
  --runs reports/round-106/scratch/close-protocol/default-cannon
PATH="$N24:$PATH" python3 corpus/fixtures/run_battery.py --only r94_cannon_det \
  --runs reports/round-106/scratch/close-protocol/pinned-cannon
python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops \
  --runs reports/round-106/scratch/close-protocol/free-ops
```

**Expected:**

- default node `v26.12.0` at the mise `latest/bin/node` path; pinned node `v24.21.0` at `$N24/node`; runner sha unchanged.
- default `r94_cannon_nan`: row `FAIL`, `actual_exit=0`, reason `exact stdout marker missing`, observed node token `v26.12.0` not `v24.21.0`, `seeds_unchanged=true`. Battery exit may be non-zero. This is the FAIL class. A PASS here is RED (the default env was not actually selected).
- pinned `r94_cannon_det`: row `PASS`, `actual_exit=0`, `reasons=[]`, stdout contains `node=v24.21.0`, `seeds_unchanged=true`, cases `1/1`. Battery exit 0.
- default `phys3d_joints_free_ops`: row `PASS`, `actual_exit=0`, `reasons=[]`, `seeds_unchanged=true`, `case_timeout_seconds=20`, elapsed under 20s. Battery exit 0. This does not re-prove the r104 2.9s figure and must not be written up as an engine-wide physics claim.

After the pinned command, plain `node --version` must again be `v26.12.0`. No mise/fnm config write.

Frozen totals, re-parsed, not re-run:

```sh
python3 - <<'PY'
import json
from collections import Counter
from pathlib import Path
def load(p):
    d = json.loads(Path(p).read_text())
    res = d['results']
    vc = Counter(r['verdict'] for r in res)
    fails = [r['case'] for r in res if r['verdict'] != 'PASS']
    print(p)
    print('  verdict=%s seeds=%s n=%d %s timeout=%s runner=%s pin_in_seeds=%s fails=%d' % (
        d.get('verdict'), d.get('seeds_unchanged'), len(res), dict(vc),
        d.get('case_timeout_seconds'), d.get('seed_digests', {}).get('run_battery.py'),
        'PINNED-ENV.md' in d.get('seed_digests', {}), len(fails)))
    return fails
f = load('reports/round-104/physics/full-regression-runs/20261018T194637610772Z-verdicts.json')
assert len(f)==13 and all(x.startswith('r94_cannon_') for x in f)
load('reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json')
load('reports/round-105/n24/runs/node24-full-20261018T202944Z.verdicts.json')
print('FROZEN_PARSE=ok')
PY
sha256sum reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json \
  reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.stdout \
  reports/round-105/n24/runs/node24-full-20261018T202944Z.verdicts.json \
  reports/round-105/n24/runs/node24-full-20261018T202944Z.stdout
```

**Expected:** `FROZEN_PARSE=ok`. R104: `verdict=FAIL`, `seeds=True`, `PASS=337`, `FAIL=13`, runner pin, no `PINNED-ENV.md` in the seed map. R105 clean: `verdict=PASS`, `seeds=True`, `PASS=350`, `FAIL=0`, runner pin, sha256 `54b7140de9a24ab6422e9391376d0134c3bafdc29ff21fa45197afc2338046e5`. R105 first: row passes 350 but `verdict=FAIL` and `seeds=False`, sha256 `cca760d3f12d753e126adb759eeefc6923b6c5b80bab91893114c5e28bd5d0d5`. Citing the first capture as the clean 350/350 is RED. Stdout shas, if unchanged: rerun `f80d61001c51e1380ddfdeb66b530bc805c2e5960406f49fe5e87e2934839286`; first `adf138203fa5898f5e839602ea15812e56f7ff1efcef5968cbf70d92f2793999`. The r105 `reports-index.md` rerun-stdout row is a known mid-write frame (`7f76f1d7…`, 10377 bytes). Do not use that index row as the receipt identity.

**C2 close line:** `C2=PASS` only if §5 and this section match, census files exist, and engines.md does not promote a row or call the default env 350/350. Otherwise `C2=RED`.

## 7. C3 — lesson digests, counts, receipts

Required files: `reports/round-106/consistency/chunk-01.md` … `chunk-04.md`, `receipts.md`, `two-state.md`, `adversary.md`, `verify.md`, plus `reports/round-106/consistency.md`, `lesson-drift.md`, `lesson-freshness.md`.

`consistency/verify.md` must re-check 10 edited lesson lines on the final bytes and say the digests match, the notes are dated, and no silent rewrite was found. A verify file bound to a pre-final hash is stale and does not count; re-run it.

Mechanical re-derivation:

```sh
python3 - <<'PY'
import re, subprocess
from pathlib import Path
base = '0cc3f4162f8c319f8d01a69a174fe939f36701bd'
# runner pin quoted as current must match the live file
live = subprocess.check_output(['sha256sum','corpus/fixtures/run_battery.py'], text=True).split()[0]
text_files = list(Path('corpus/lessons').glob('*.md')) + [
    Path('corpus/knowledge/engines.md'), Path('corpus/fixtures/PINNED-ENV.md'), Path('SKILL.md')]
undated = 0
for p in text_files:
    if not p.is_file():
        continue
    text = p.read_text(errors='replace')
    if 'f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f' in text:
        continue
    # a shortened runner pin presented as the current runner, with no dated note, is a mismatch
    if re.search(r'run_battery\.py.{0,80}f456bd00', text) and live.startswith('f456bd00'):
        pass
print('RUNNER_SHA_LIVE=%s' % live)
# battery totals must name their environment in the same paragraph
pair_bad = 0
for p in list(Path('corpus/lessons').glob('*.md')) + [Path('corpus/knowledge/engines.md'), Path('corpus/fixtures/PINNED-ENV.md'), Path('corpus/README.md')]:
    if not p.is_file():
        continue
    lines = p.read_text(errors='replace').splitlines()
    for i, line in enumerate(lines):
        window = ' '.join(lines[max(0,i-3):i+4]).lower()
        if '337/350' in line and not any(k in window for k in ('default', 'v26', 'mise', 'unpinned')):
            pair_bad += 1
            print('UNPAIRED_337', p, i+1)
        if '350/350' in line and not any(k in window for k in ('pinned', 'v24.21.0', 'fnm', 'node 24', 'node-24')):
            pair_bad += 1
            print('UNPAIRED_350', p, i+1)
        if '336/350' in line and not any(k in window for k in ('default', 'r104', 'before', 'prior', 'historical')):
            pair_bad += 1
            print('UNPAIRED_336', p, i+1)
print('TOTALS_UNPAIRED=%d' % pair_bad)
PY
```

**Expected:** `RUNNER_SHA_LIVE=f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`, `TOTALS_UNPAIRED=0`. `337/350` sits with the default/mise/v26 state. `350/350` sits with pinned/fnm/v24.21.0. `336/350`, if it survives, is historical (pre-fix or pre-r104), not a current total.

Receipt rule, from `consistency/receipts.md` plus a closer spot check of every `corpus/live/runs/` path still cited as if it resolves:

- the path exists on disk, or
- a durable copy exists under `reports/` and the lesson names that copy, or
- the lesson carries a dated r106 note that the receipt is gitignored and absent.

A citation that asserts a missing `corpus/live/` file is still on disk is RED. `consistency/receipts.md` must list each such citation. SKILL.md's engines.md stamp `d03907d3…` is a protected stale stamp once engines.md has moved: record `SKILL_ENGINES_STAMP_STALE=yes`. Do not treat that as a license to edit SKILL.md, and do not let a later reader use the SKILL stamp as the current engines hash.

`lesson-drift.md` must sample 5 edited lessons and say original claims remain, with dated notes where a fact changed. `lesson-freshness.md` must cover `r102-unreal-integration.md` and `r105-unreal-lifecycle.md`. Both files must still exist. r105 must still contain `337/350` paired with the default environment and must not call that figure the pinned total.

**C3 close line:** `C3=PASS` only if the four chunks and the verify/receipts/two-state files exist, `TOTALS_UNPAIRED=0`, `DROPPED_SHA=0` from §3, and every live-run citation is resolvable or dated. Otherwise `C3=RED`.

## 8. Guard — gate pin on the final tree

The gate tree is protected. A sweep of lessons must not move `POINTERS`. If it moved, find the mover; that is a guard failure, not a new pin.

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
WORK=reports/round-106/scratch/close-protocol/gate
mkdir -p "$WORK"
GATE_WORKDIR="$PWD/$WORK" bash corpus/knowledge/unreal-mcp/gate/run_gate.sh \
  > reports/round-106/scratch/close-protocol/gate.stdout
echo GATE_RC=$?
python3 - <<'PY'
import re
from pathlib import Path
readme = Path('corpus/knowledge/unreal-mcp/gate/README.md').read_text()
section = readme.split('## Expected output — pinned summary', 1)[1]
pin = re.search(r'^POINTERS=(\d+)\b', section, re.M).group(1)
out = Path('reports/round-106/scratch/close-protocol/gate.stdout').read_text()
live = re.search(r'^POINTERS=(\d+)\b', out, re.M).group(1)
unres = re.search(r'UNRESOLVED=(\d+)', out).group(1)
result = re.search(r'^GATE RESULT: (.+)$', out, re.M).group(1)
census = re.search(r'^CENSUS (.+)$', out, re.M).group(1)
print(f'README_POINTERS_PIN={pin} GATE_POINTERS_LIVE={live} POINTERS_PIN_MATCH={pin==live} UNRESOLVED={unres}')
print('CENSUS', census)
print('GATE_RESULT', result)
assert pin == '103' and live == pin and unres == '0' and result.startswith('PASS')
assert 'static-only=12 unproven-runtime=1 verified-here=0' in census
print('GATE_GUARD=PASS')
PY
sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh
```

**Expected:** `README_POINTERS_PIN=103`, `GATE_POINTERS_LIVE=103`, `POINTERS_PIN_MATCH=True`, `UNRESOLVED=0`, census `12/1/0`, `GATE RESULT: PASS (checks failed: 0)`, `GATE_RC=0`, gate sha still `390a25ae…e57b2cf`. Four `STEP=PASS`. `CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297`. Stderr empty. A `Disk quota exceeded` line invalidates the run; rerun with `GATE_WORKDIR` off `/tmp`.

Negative paths, if `reports/round-106/gate/blocked-check.md` is the evidence instead of a fresh pair, are acceptable only when that file records a command on the final gate sha. Otherwise rerun: dead `REPO` URL, `GATE_REF` unset → exit 2 and `GATE RESULT: BLOCKED`; `GATE_REF` pointing at a missing directory → exit 1 and `STEP=FAIL`, not `BLOCKED`.

## 9. Carry guards — not substitutes for C1–C3

Run these. A RED here is `GUARDS=RED` even if the three claims passed.

1. **No Unreal runtime.** `command -v UnrealEditor UnrealEditor-Cmd` absent; `ls /opt/UnrealEngine` fails. `rg -n 'verified-here' corpus/knowledge/unreal-mcp/executability` finds no card whose label line is `verified-here`. engines.md Unreal row stays installed `no`. Grep of `reports/round-106/*.md` and `census/*.md` for a sentence that the editor ran must be empty. **Expected:** `UNREAL_EDITOR=absent`, `verified-here=0`.
2. **P/C unapplied.** The six dissent files in §1 still contain ``Not `unproven-runtime` ``. `git diff --quiet "$BASE" -- corpus/knowledge/unreal-mcp/executability corpus/knowledge/unreal-mcp/README.md reports/round-105/pc` exits 0. No seat marks SHONEN box 1. **Expected:** `PC_UNAPPLIED=yes`.
3. **r22 pair still discriminates.** `python3 corpus/artifacts/unreal-r22/verify_descriptor.py` → `PASS local-static actual=accept`, exit 0. The bad-type file with `--expect-reject` → `PASS local-static actual=reject`, exit 0. Checker sha may not change (`git diff --quiet -- corpus/artifacts/unreal-r22/verify_descriptor.py`). **Expected:** `R22_ACCEPT_RC=0`, `R22_REJECT_RC=0`.
4. **r105 receipts unmodified.** `git diff --quiet "$BASE" -- reports/round-105/n24/runs` exits 0. Clean JSON sha remains `54b7140d…`.
5. **Jolt is not a claim.** `reports/round-106/jolt/investigate.md` must exist with 5 default-env `free_ops` runs. `jolt/adversary.md` and `jolt/ledger.md` must exist. Whatever class they rule, it must not add an engine row, must not flip Godot's headless cell, and must not be cited as Unreal evidence. **Expected:** `JOLT_NOT_A_CLAIM=yes`. A missing jolt file is a routed-item RED, not a C2 pass and not a C2 fail by itself.
6. **Editor absence for Unity** stays `no`/`no`. A static `unity-r19` accept/reject pair does not promote the row.

## 10. Tokens the closer prints

Print this block last. Any line that does not match is RED for its claim or guard. Do not fill a token from a seat transcript you did not re-run.

```text
MODE=worktree|landed
BASE=0cc3f4162f8c319f8d01a69a174fe939f36701bd
ALLOWLIST_VIOLATIONS=0
LESSON_MD=92
LESSON_MISSING=0
LESSON_SHRUNK=0
RUNNER_SHA=f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f
CASES=350
SILENT_PATH_REWRITE=0
DROPPED_COUNTS=0
DROPPED_SHA=0
DEAD_ROOT_FENCE_SWEEPABLE=0
DEAD_ROOT_PROSE_UNNOTED=0
SWEEP_CHUNKS=18/18
ENGINES_CHANGED=yes
ENGINE_ROWS=4
STATE_CELLS_UNMOVED=4/4
ENGINE_PROMOTIONS=0
ENGINES_CITATIONS_MISSING=0
DEFAULT_NODE=v26.12.0
PINNED_NODE=v24.21.0
DEFAULT_CANNON=FAIL_CLASS
PINNED_CANNON=PASS
FREE_OPS_DEFAULT=PASS
R104_PARSE=337/13 FAIL seeds_true
R105_CLEAN=350/350 PASS seeds_true
R105_FIRST=FAIL seeds_false
TOTALS_UNPAIRED=0
POINTERS_PIN=103
POINTERS_LIVE=103
POINTERS_PIN_MATCH=True
UNRESOLVED=0
GATE_RC=0
CENSUS=12/1/0
UNREAL_EDITOR=absent
PC_UNAPPLIED=yes
JOLT_NOT_A_CLAIM=yes
C1=PASS|RED
C2=PASS|RED
C3=PASS|RED
GUARDS=PASS|RED
```

## Close verdict rule

C1, C2, and C3 are reported separately. Gate PASS does not hide a blocked claim. A worktree-mode pass is not a landed close and is not a promotion. No Unreal Editor or Unreal runtime result is asserted by a green run of this protocol. The operator, not a seat, admits the round.
