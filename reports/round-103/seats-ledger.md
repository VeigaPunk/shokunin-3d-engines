# r103 SEAT-55 — SEATS-LEDGER

Question put to this seat: **did any r103 seat write a protected path** — `LOG.md`,
`SCORECARD.md`, `SHONEN.md`, `SKILL.md`, `PROVINCE.md`, or anything under
`corpus/fixtures/`? Answer: **no. All protected paths are byte-identical to HEAD.**

- HEAD under test: `c85a816e227984272a3c29b58aa7f7c1a76f1e9c`
  (`r102 report-last: verdict … — work c6f655d`)
- Snapshot timestamps (UTC): first sweep `2026-10-18T18:31:54Z`, confirming sweep
  `2026-10-18T18:32:22Z` (re-run after two concurrent peer seats landed edits; the
  conclusion is unchanged across both snapshots — see §5)
- Method: per-file blob comparison, worktree `git hash-object` vs `HEAD:<path>`, over
  every tracked file in each protected tree. This is strictly stronger than mtime or
  `git diff --name-only`: it catches modification, deletion, *and* addition, and it
  cannot be fooled by an edit that restores a file's size or mtime.
- No writes by this seat outside `reports/round-103/seats-ledger.md`. All commands
  below are read-only.

## 1. Ledger root files — PASS

```
$ for f in LOG.md SCORECARD.md SHONEN.md PROVINCE.md; do
    wt=$(git hash-object -- "$f"); hb=$(git rev-parse "HEAD:$f")
    echo "$f wt=$wt head=$hb $( [ "$wt" = "$hb" ] && echo MATCH || echo DIFFER )"
  done
LOG.md wt=8e762af047896c727012edf8dc2fb97b7a8506a9 head=8e762af047896c727012edf8dc2fb97b7a8506a9 MATCH
SCORECARD.md wt=d4b73d776da20ae65421b45653a789d49aef8d4c head=d4b73d776da20ae65421b45653a789d49aef8d4c MATCH
SHONEN.md wt=8d85902c19010deb4fa154e16a2c12ad56ff10d1 head=8d85902c19010deb4fa154e16a2c12ad56ff10d1 MATCH
PROVINCE.md wt=cde5e8f518bb05149ab62e4ea5aa44f547e8aa69 head=cde5e8f518bb05149ab62e4ea5aa44f547e8aa69 MATCH
```

Independent sha256 of the worktree copies, for cross-seat reproduction:

```
$ sha256sum LOG.md SCORECARD.md SHONEN.md PROVINCE.md
f73ec78ccdf343a215b82846f93a7eae08a9878e97728be7a0f12e5122a2fd37  LOG.md
b3b09e5216d197432d906bb8861f1288b73dcec403a567e04c3807906f68d67f  SCORECARD.md
b44667ff4f0d4cfd8700eab2523b97ba3b254e440abde06d4214e9834d6a6062  SHONEN.md
1932f0fd7103dcc33e0b0c9f835adfe681e6ce4d765d4673bcc925c5d8230eac  PROVINCE.md
```

`LOG.md` / `SCORECARD.md` were last written by `c85a816` itself (the r102 report-last
commit) and `SHONEN.md` / `PROVINCE.md` date to `a6b944d` (2026-10-13); their mtimes in
the worktree (15:20:52 and 16:40:46 on 2026-10-13) are consistent with that history and
predate the r103 start. mtime alone is not the evidence here — the blob ids are.

## 2. `SKILL.md` — PASS (none exists outside the pinned upstream)

The only `SKILL.md` files in the repository are the three vendored ones inside the
protected upstream tree, and those are pinned separately (§3):

```
$ find . -name 'SKILL.md' -not -path './.git/*' \
    -not -path './corpus/knowledge/unreal-mcp/upstream/*'
(no output)
```

There is no lane-level or seat-level `SKILL.md` to have been written, so the "no seat
wrote SKILL.md" claim is vacuously satisfied and additionally covered by the upstream
tree walk below.

## 3. Protected subtrees — PASS, zero differing, zero missing

```
$ for d in LOG.md SCORECARD.md SHONEN.md PROVINCE.md corpus/fixtures \
           corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d \
           reports/round-101 reports/round-102; do
    # walk every blob in git ls-tree -r HEAD -- "$d", compare git hash-object of worktree
  done
LOG.md            identical=1   differing=0 missing=0
SCORECARD.md      identical=1   differing=0 missing=0
SHONEN.md         identical=1   differing=0 missing=0
PROVINCE.md       identical=1   differing=0 missing=0
corpus/fixtures   identical=146 differing=0 missing=0
corpus/knowledge/unreal-mcp/upstream      identical=12 differing=0 missing=0
corpus/knowledge/unreal-mcp/.manifest.d   identical=12 differing=0 missing=0
reports/round-101 identical=33  differing=0 missing=0
reports/round-102 identical=61  differing=0 missing=0
```

No `DIFFER` or `MISSING` line was emitted in any walk. Subtree object ids under HEAD,
so a later re-run can be compared against the same anchors:

```
corpus/fixtures                          4ebcc2db628de576904fe54ae1d8037d499b19c1
corpus/knowledge/unreal-mcp/upstream     b5b9624b00fc90217240e823406699d0ab78b959
corpus/knowledge/unreal-mcp/.manifest.d  87bde5b7bc9517664cfbdae46d3cfeaded62e3e2
reports/round-101                        a28869fcf749c34fbd91edc485afde86fae37841
reports/round-102                        92d4dc84dd979ecff01fe050436811c43453ada8
```

The upstream pin is unchanged and the manifest verifies against the vendored bytes
independently of git:

```
$ cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256
upstream/.claude-plugin/plugin.json: OK   … (12 lines) …   upstream/skills/unreal-skill/SKILL.md: OK
exit=0
```

`audit-reference.sha256` header still records `pinned SHA:
a6aa73ada02a9fb1f5415bec491f9942c519b297 (main)`, matching the round's declared pin.

## 4. No additions smuggled into a protected tree

A tracked-file walk would miss a *new* file dropped into a pinned directory, so both
untracked and gitignored files were enumerated there:

```
$ git ls-files --others --exclude-standard -- \
    LOG.md SCORECARD.md SHONEN.md PROVINCE.md corpus/fixtures \
    corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d \
    reports/round-101 reports/round-102
(none)

$ git status --short -- <same paths>
(empty)
```

Ignored-but-present files inside `corpus/fixtures/` are limited to build/test residue
and are not seat writes to pinned fixtures: `corpus/fixtures/__pycache__/`
(dir mtime `2026-10-18 14:41:15 -0300`, from a battery import) and
`corpus/fixtures/three/node_modules/` (dir mtime `2026-10-18 14:46:31 -0300`, from the
`three` fixture install). Both predate the r103 start and neither is a fixture source
file. The newest tracked file in `corpus/fixtures/` is `three/package-lock.json` at
`2026-10-18 14:22:42 -0300` — also pre-r103, and byte-identical to HEAD.

## 5. Round-wide worktree status, and the two peer writes that are *not* protected

At the confirming snapshot the entire non-clean surface of the worktree is:

```
$ git status --porcelain=v1
 M corpus/artifacts/unity-r19/README.md
?? reports/round-103/

$ git ls-files --others --exclude-standard
reports/round-103/gate/clean.raw.txt
reports/round-103/ledger-check.md
reports/round-103/note/configline.md
reports/round-103/note/urls.md
```

Two tracked files were modified during r103, both by concurrent seats, neither
protected:

- `corpus/artifacts/unity-r19/README.md` — the C3 (calibration) seat's dead-root repair:
  the runnable command examples drop the stale `.shokunin/game-dev-3d/` prefix
  (2-line hunk). This path is not on the protected list.
- `corpus/knowledge/unreal-mcp/adaptation-kimi.md` — the C1 (coverage) seat's freshness
  note, +117 insertions, additive only (`git diff --stat` → `1 file changed, 117
  insertions(+)`, no deletions). This file is the declared target of that claim and is
  not on the protected list.

Neither is `LOG.md`, `SCORECARD.md`, `SHONEN.md`, `SKILL.md`, `PROVINCE.md`, or under
`corpus/fixtures/`. The re-run of the protected-tree check after both edits landed still
returns `protected-diff-exit=0`, so the verdict holds at the later snapshot as well:

```
$ git diff --quiet HEAD -- LOG.md SCORECARD.md SHONEN.md PROVINCE.md corpus/fixtures \
    corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d \
    reports/round-101 reports/round-102
exit=0
```

Also observed and outside this seat's scope: `corpus/live/runs/` accumulated run
scratch after 15:31 (`20261018T181301123479Z/scratch/…`, `r12-import-…Z/`) from other
seats executing the battery and the glb import probe. `corpus/live/` is not a protected
path.

## 6. Verdict

| Protected path | Files walked | Differing | Missing | Verdict |
|---|---|---|---|---|
| `LOG.md` | 1 | 0 | 0 | clean |
| `SCORECARD.md` | 1 | 0 | 0 | clean |
| `SHONEN.md` | 1 | 0 | 0 | clean |
| `PROVINCE.md` | 1 | 0 | 0 | clean |
| `SKILL.md` (lane-level) | 0 exist | — | — | clean (none exists) |
| `corpus/fixtures/` | 146 | 0 | 0 | clean |
| `corpus/knowledge/unreal-mcp/upstream/` | 12 | 0 | 0 | clean |
| `corpus/knowledge/unreal-mcp/.manifest.d/` | 12 | 0 | 0 | clean |
| `reports/round-101/` | 33 | 0 | 0 | clean |
| `reports/round-102/` | 61 | 0 | 0 | clean |

**No r103 seat wrote a protected path.** The only round-103 writes are the untracked
files under `reports/round-103/` plus the two non-protected peer repairs listed in §5.
Overlap note: SEAT-39's `reports/round-103/ledger-check.md` covers a subset of this
scope (`LOG`/`SCORECARD`/`SHONEN` and rounds 101/102) and reports the same ids; this
seat adds `PROVINCE.md`, the `SKILL.md` search, `corpus/fixtures/`, the upstream and
manifest trees, and the addition/ignored-file sweep. Both agree on every path they
share.
