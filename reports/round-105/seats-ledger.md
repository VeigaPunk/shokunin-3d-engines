# r105 SEAT-49 — SEATS-LEDGER

Axes: coverage (owner/path boundary), calibration (point-in-time byte comparison), depth (no runtime or battery validation by this seat).

## Protected-path sweep

Question: did the r105 worktree touch protected paths outside their declared-owner exceptions? HEAD under test: `1eaa5680c22a704ddf05f9b51ff3fcc731b9be8b` (`git rev-parse HEAD`). The final full hash walk completed before `date -u +%Y-%m-%dT%H:%M:%SZ` returned `2026-10-18T20:38:02Z`.

Protected set checked: `LOG.md`, `SCORECARD.md`, `SHONEN.md`, `PROVINCE.md`, `SKILL.md`, all tracked files under `corpus/fixtures/`, `corpus/knowledge/unreal-mcp/upstream/`, `corpus/knowledge/unreal-mcp/.manifest.d/`, and `reports/round-101/` through `reports/round-104/`. The hash walk was run as:

```python
import os, subprocess
sets = {
 'ledger-roots': ['LOG.md','SCORECARD.md','SHONEN.md','PROVINCE.md'],
 'skill-owner-exception': ['SKILL.md'],
 'fixtures': ['corpus/fixtures'],
 'upstream': ['corpus/knowledge/unreal-mcp/upstream'],
 'manifest': ['corpus/knowledge/unreal-mcp/.manifest.d'],
 'reports-101': ['reports/round-101'],
 'reports-102': ['reports/round-102'],
 'reports-103': ['reports/round-103'],
 'reports-104': ['reports/round-104'],
}
all_paths=[]; diffs=[]
for label,specs in sets.items():
 raw=subprocess.check_output(['git','ls-tree','-r','-z','HEAD','--',*specs])
 entries=[]
 for x in raw.split(b'\0'):
  if x: entries.append(x.split(b'\t',1)[1].decode())
 for p in entries:
  if not os.path.isfile(p): diffs.append((label,'MISSING',p)); continue
  wt=subprocess.check_output(['git','hash-object','--',p],text=True).strip()
  hd=subprocess.check_output(['git','rev-parse',f'HEAD:{p}'],text=True).strip()
  if wt != hd: diffs.append((label,'DIFFER',p))
 print(f'{label}: tracked={len(entries)} differences_or_missing={sum(1 for d in diffs if d[0]==label)}')
 all_paths.extend(entries)
print(f'total_tracked={len(all_paths)} differences_or_missing={len(diffs)}')
for row in diffs: print(*row)
untracked=[]
for specs in sets.values():
 raw=subprocess.check_output(['git','ls-files','--others','--exclude-standard','-z','--',*specs]).decode().split('\0')
 untracked.extend(p for p in raw if p)
untracked=sorted(set(untracked))
print(f'untracked_protected_additions={len(untracked)}')
for p in untracked: print('UNTRACKED',p)
```

Observed output:

```text
ledger-roots: tracked=4 differences_or_missing=0
skill-owner-exception: tracked=1 differences_or_missing=1
fixtures: tracked=146 differences_or_missing=0
upstream: tracked=12 differences_or_missing=0
manifest: tracked=12 differences_or_missing=0
reports-101: tracked=33 differences_or_missing=0
reports-102: tracked=61 differences_or_missing=0
reports-103: tracked=61 differences_or_missing=0
reports-104: tracked=21950 differences_or_missing=0
total_tracked=22280 differences_or_missing=1
skill-owner-exception DIFFER SKILL.md
untracked_protected_additions=1
UNTRACKED corpus/fixtures/PINNED-ENV.md
```

All 22,279 tracked files other than `SKILL.md` match their HEAD blobs; there are zero missing paths. The one tracked protected-path delta is the explicit owner exception: `SKILL.md` (SEAT-06 / SEAT-09 stamp-only ownership). `git diff -- SKILL.md` showed the heading expanded to include lane-fixture runtime claims and a single sixth row F added; this is the declared C1 fixture-runtime row, not a write by this seat. The sole untracked protected-path addition is `corpus/fixtures/PINNED-ENV.md`, the declared SEAT-11 fixture README/doc exception; it is documentation, not fixture code. No fixture code, upstream, manifest, frozen report, or ledger-root file differs.

## Worktree surface and ownership boundary

Commands run: `git diff --name-only HEAD`, `git diff --cached --name-only`, and `git status --short --untracked-files=all`.

Observed tracked paths were exactly `SKILL.md` and `corpus/knowledge/unreal-mcp/adaptation-kimi.md`; staged path output was empty. `git diff --stat HEAD -- SKILL.md corpus/knowledge/unreal-mcp/adaptation-kimi.md` reported `2 files changed, 10 insertions(+), 8 deletions(-)`. The adaptation diff is only the upstream URL correction, explicitly within SEAT-04/10 ownership; `reports/round-105/kimi404/author.md` records the SEAT-04 attribution and its URL probe. No `corpus/knowledge/unreal-mcp/gate/README.md` change appeared in `git diff --name-only HEAD`.

Two untracked paths were outside `reports/round-105/`: the C1-declared `corpus/lessons/r105-unreal-lifecycle.md` and `corpus/fixtures/PINNED-ENV.md`, the permitted SEAT-11 fixture README/doc exception. `Read` showed the latter is a short runbook, not fixture code; `Grep 'PINNED-ENV|SEAT-11' reports/round-105` matched `reports/round-105/n24/runbook.md`, headed `SEAT-11`, which names it as the companion instructions. All remaining untracked paths were under the current round's `reports/round-105/` evidence/output tree. This is a path/byte audit, not process-level authorship proof; owner attribution comes from the round declaration and seat artifacts. The lifecycle lesson's province/scope assessment is separately recorded in `reports/round-105/lesson/bleed.md` and is not a protected-path finding.

No fixture or environment mutation was performed by this seat. All audit commands were read-only; this file is the seat's only write. The snapshot is not a lock: rerun `git status --short --untracked-files=all` and the hash walk after peer seats finish for the close-time verdict.
