# r103 SEAT-39 — LEDGER-CHECK

Scope: verify (a) `LOG.md` / `SCORECARD.md` / `SHONEN.md` unchanged vs HEAD, (b) `reports/round-101/` and `reports/round-102/` untouched vs HEAD. All checks are read-only; no writes outside this file.

- HEAD under test: `c85a816e227984272a3c29b58aa7f7c1a76f1e9c` (`r102 report-last: verdict … — work c6f655d`)
- Check timestamp (UTC): `2026-10-18T18:31:36Z`

## 1. Ledger files unchanged vs HEAD — PASS

Content-hash comparison (worktree blob vs `HEAD:<path>`), which is stronger than mtime:

```
$ for f in LOG.md SCORECARD.md SHONEN.md; do wt=$(git hash-object -- "$f"); hb=$(git rev-parse "HEAD:$f"); echo "$f worktree=$wt HEAD=$hb $( [ "$wt" = "$hb" ] && echo IDENTICAL || echo DIFFER )"; done
LOG.md worktree=8e762af047896c727012edf8dc2fb97b7a8506a9 HEAD=8e762af047896c727012edf8dc2fb97b7a8506a9 IDENTICAL
SCORECARD.md worktree=d4b73d776da20ae65421b45653a789d49aef8d4c HEAD=d4b73d776da20ae65421b45653a789d49aef8d4c IDENTICAL
SHONEN.md worktree=8d85902c19010deb4fa154e16a2c12ad56ff10d1 HEAD=8d85902c19010deb4fa154e16a2c12ad56ff10d1 IDENTICAL
```

`git diff --stat HEAD` and `git diff --name-only HEAD` over the three paths both returned empty (exit 0), no output.

Independent sha256 of the worktree copies, for cross-seat reproduction:

```
$ sha256sum LOG.md SCORECARD.md SHONEN.md
f73ec78ccdf343a215b82846f93a7eae08a9878e97728be7a0f12e5122a2fd37  LOG.md
b3b09e5216d197432d906bb8861f1288b73dcec403a567e04c3807906f68d67f  SCORECARD.md
b44667ff4f0d4cfd8700eab2523b97ba3b254e440abde06d4214e9834d6a6062  SHONEN.md
```

## 2. reports/round-101 and reports/round-102 untouched vs HEAD — PASS

Per-file blob walk over the committed subtrees (catches both modification and deletion of tracked files):

```
$ for d in reports/round-101 reports/round-102; do ... done < <(git ls-tree -r HEAD -- "$d")
reports/round-101: identical=33 differing=0 missing=0
reports/round-102: identical=61 differing=0 missing=0
```

- `reports/round-101`: 33/33 tracked files byte-identical to HEAD.
- `reports/round-102`: 61/61 tracked files byte-identical to HEAD.
- No `DIFF` or `MISSING` lines emitted.

Subtree object ids confirmed:

```
$ git ls-tree HEAD reports/round-101
040000 tree a28869fcf749c34fbd91edc485afde86fae37841	reports/round-101
$ git ls-tree HEAD reports/round-102
040000 tree 92d4dc84dd979ecff01fe050436811c43453ada8	reports/round-102
```

Untracked-file check inside those two directories (would catch new files dropped into a pinned round):

```
$ git status --porcelain -- reports/round-101 reports/round-102
(empty)
```

## 3. Whole-worktree status — only round-103 is new

```
$ git status --porcelain
?? reports/round-103/
```

No staged changes (`git diff --cached --stat` empty), no unstaged tracked changes (`git diff HEAD --stat` empty). The sole working-tree delta vs HEAD is the untracked `reports/round-103/` directory for the current round — expected and in-bounds.

## 4. Protected pinned paths (spot-check, cross-seat safety) — PASS

```
$ for p in corpus/fixtures corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d; do ... done
== corpus/fixtures ==
  tracked-clean rc=0
== corpus/knowledge/unreal-mcp/upstream ==
  tracked-clean rc=0
== corpus/knowledge/unreal-mcp/.manifest.d ==
  tracked-clean rc=0
```

All three are tracked-clean vs HEAD (no porcelain entries, `git diff --quiet HEAD` exit 0). This is a corroborating spot-check, not the byte-pin audit owned by other seats.

## Verdict

PASS. `LOG.md`, `SCORECARD.md`, `SHONEN.md` are byte-identical to HEAD `c85a816`; `reports/round-101` (33 files) and `reports/round-102` (61 files) are byte-identical to HEAD with no added files. The only working-tree change is the untracked `reports/round-103/` round directory. No blockers.
