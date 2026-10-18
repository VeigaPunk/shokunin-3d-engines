# r105 scribe-audit — inventory, naming, and live frames

**Axes:** coverage (round-tree inventory), depth (naming and workstream shape), calibration (frame-bounded claims). **Scope:** read-only audit of `reports/round-105/`; this seat writes only this audit. The counts below are snapshots, not a frozen round manifest.

## Headline

At the last pre-write snapshot, `2026-10-18T17:43:49-03:00`, `reports/round-105/` contained **50 files / 1,176,766 bytes** across six workstream directories. A five-second sampler had already returned different tree hashes on every frame, and new files continued to land. The pinned-Node stdout receipt completed with `350/350` case rows passing, but its durable JSON verdict is **FAIL** (`seeds_unchanged=false`); a second run was still in progress at 45 passing rows. Neither is a settled round-close frame.

## Frames

Sampler command run (sorted relative path, byte size, and per-file SHA-256 combined into a tree hash; three frames, five seconds apart):

```sh
python - <<'PY'
from pathlib import Path
from hashlib import sha256
from datetime import datetime
from time import sleep
import json
root=Path('reports/round-105')
run=root/'n24/runs/node24-full-20261018T202944Z.stdout'
receipt=Path('corpus/live/runs/20261018T202944290389Z/verdicts.json')
d=json.loads(receipt.read_text())
for i in range(3):
    rows=[]
    for p in sorted(root.rglob('*')):
        if p.is_file():
            b=p.read_bytes()
            rows.append((p.relative_to(root).as_posix(),len(b),sha256(b).hexdigest()))
    tree=sha256('\n'.join('\t'.join(map(str,r)) for r in rows).encode()).hexdigest()
    lines=run.read_text().splitlines()
    print('FRAME',datetime.now().astimezone().isoformat(timespec='seconds'),
          'files',len(rows),'bytes',sum(r[1] for r in rows),'tree',tree,
          'matrix_stdout_lines',len(lines),'verdict',d['verdict'],
          'totals',d['totals'],'seeds_unchanged',d['seeds_unchanged'])
    if i<2: sleep(5)
PY
```

Observed frames:

| Local time | files | bytes | tree SHA-256 | matrix case rows visible |
|---|---:|---:|---|---:|
| 17:43:03 | 48 | 1,150,033 | `5c8299e724f315a88dad2fbe4769f7e5a0df15454b9188ddbffa7fe5c56a6dcb` | 350 complete; receipt verdict FAIL |
| 17:43:08 | 48 | 1,151,140 | `75de31a23867d05fe29d2b2b2367cbabb56af11765f13cbbd38215a74034f901` | 350 complete; receipt verdict FAIL |
| 17:43:13 | 48 | 1,151,292 | `42a21cecefb754b194cf20a783737d020a7ebb5a8d9ec46f78d60e8a2ec7e572` | 350 complete; receipt verdict FAIL |

The subsequent pre-write frame at `17:43:49` counted 50 files / 1,176,766 bytes, tree hash `f2660ae3e8ca514c1a96976d3bed01c84ba5b3888846919c3e43d2ca61e0e021`; the rerun log then had 45 PASS rows and no FAIL rows. The hashes and byte counts establish that the directory was still changing; no stable frame was obtained. These frames exclude this audit, which is written after them.

## Inventory at the pre-write frame

Command run: `find reports/round-105 -type f -printf '%P\t%s bytes\n' | sort`.
Observed path inventory (50 files):

```text
freshness-pin.md
gate/final-run.md
gate/integrity.md
gate/pin-after-edits.md
gate/scratch/gate-run.rc
gate/scratch/gate-run.stderr
gate/scratch/gate-run.stdout
git-hygiene.md
install-recheck.md
kimi404/author.md
kimi404/verify.md
ledger-check.md
ledger-math.md
lesson/bleed.md
lesson/critic.md
lesson/verify.md
math-audit.md
n24/adversary.md
n24/fingerprint.md
n24/markers.md
n24/pre-state.md
n24/revert.md
n24/runbook-critic.md
n24/runbook.md
n24/runs/node24-full-20261018T202944Z.stdout
n24/runs/node24-full-20261018T202944Z.verdicts.json
n24/runs/node24-full-rerun-20261018T204240Z.stdout
n24/single-confirm.md
operator-package.md
pc/analyst-1.md
pc/analyst-2.md
pc/cards.md
pc/distiller.md
pc/history.md
pc/ledger.md
pc/review-3.md
pc/ruling-draft.md
physics-carry.md
r105-connector.md
r105-distiller.md
r105-report.md
r105-verification-protocol.md
scorecard-shape.md
seats-ledger.md
skill6/bleed.md
skill6/critic.md
skill6/review.md
skill6/stamps.md
stub-cleanness.md
subtree-integrity.md
```

The same pre-write scan reported six top-level folders: `gate`, `kimi404`, `lesson`, `n24`, `pc`, `skill6`. The named artifact groups cover the gate, corrected Kimi URL, lifecycle lesson review, Node-24 matrix/runbook, P/C package, and sixth fixture-runtime row; this is an inventory observation, not a content adjudication of those reports.

## Naming and readability

Commands run:

```sh
python - <<'PY'
from pathlib import Path
from collections import Counter
root=Path('reports/round-105')
files=sorted(p for p in root.rglob('*') if p.is_file())
print('files',len(files),'bytes',sum(p.stat().st_size for p in files))
print('dirs',','.join(sorted(p.name for p in root.iterdir() if p.is_dir())))
print('rootfiles',','.join(p.name for p in files if p.parent==root))
print('r105_root',','.join(p.name for p in files if p.parent==root and p.name.startswith('r105-')))
print('duplicate_basenames',','.join(sorted(n for n,c in Counter(p.name for p in files).items() if c>1)) or '(none)')
print('extensions',dict(sorted(Counter(p.suffix or '(none)' for p in files).items())))
PY
```

Observed at `17:43:49`: 50 files; 16 root files; root `r105-*` files were `r105-connector.md`, `r105-distiller.md`, `r105-report.md`, and `r105-verification-protocol.md`. The other root reports use subject names. Duplicate basenames were `bleed.md`, `critic.md`, and `verify.md`, each in separate workstream folders. The extension census was 44 `.md`, one `.json`, one `.rc`, one `.stderr`, and three `.stdout` files. The adjacent timestamped `.stdout` / `.verdicts.json` pair is the full Node-24 run receipt; the `-rerun-` output was still growing.

Readability command outcome: a Python UTF-8/NUL scan of all 44 Markdown files printed `markdown_files 44 readability_issues none`. A transient earlier partial-write frame briefly showed two NUL bytes in `pc/analyst-1.md`; a later scan found that file valid UTF-8 with zero NULs, and no persistent Markdown readability issue remained.

## Matrix receipt and integrity boundary

Commands run: parsed `reports/round-105/n24/runs/node24-full-20261018T202944Z.verdicts.json` and its corresponding `corpus/live/runs/20261018T202944290389Z/verdicts.json`; counted the captured stdout rows. Observed in both JSON files: `totals={'cases': 350, 'pass': 350, 'fail': 0, 'ordinary': 291, 'negative_controls': 59}`, `verdict=FAIL`, `seeds_unchanged=false`. The full stdout ends `FAIL battery: .../corpus/live/runs/20261018T202944290389Z/verdicts.json`. Thus the case totals are green, but the runner did **not** accept the run. At the `17:43:49` frame, `node24-full-rerun-20261018T204240Z.stdout` had 45 PASS case lines and no FAIL lines; no rerun result was yet present.

Read-only seed comparison actually run against that receipt:

```text
receipt_seed_files=130 current_files=1412 new=1282 missing=0 changed=0
new_top_level={'PINNED-ENV.md': 1, '__pycache__': 1, 'three': 1280}
```

The command compared SHA-256 values for all 130 receipt-listed paths against current `corpus/fixtures/`; none were missing or digest-changed. `git status --short --untracked-files=normal -- corpus/fixtures` printed only `?? corpus/fixtures/PINNED-ENV.md`, the explicitly permitted fixture documentation file. `stat` showed `three/node_modules` and `__pycache__` timestamps before the battery started; those 1,280 `three/` paths were absent from the receipt's seed map but this audit does not establish when they entered the tree. Therefore the receipt's `seeds_unchanged=false` is real and blocks a clean accepted result, but the evidence here does **not** show a changed byte among the 130 recorded seeds or prove that the battery run created the pre-existing ignored tree. No fixture or environment path was changed by this seat.

## Close-out boundary

This audit records moving snapshots, naming, and receipt state only. It does not declare the round tree settled, infer a clean C2 acceptance from the 350/350 case totals, or claim Unreal runtime behavior. At the last observed frame, the rerun and other report writes were still active; a later scribe frame would be needed for round-close counts.
