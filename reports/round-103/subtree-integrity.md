# r103 SEAT-54 — SUBTREE-INTEGRITY

Scope: prove `corpus/knowledge/unreal-mcp/upstream/` and `corpus/knowledge/unreal-mcp/.manifest.d/`
are byte-stable for this round — (a) `sha256` sweep rc=0, (b) `git diff --stat` on those paths empty.
All checks are read-only; the only file written by this seat is this report.

- HEAD under test: `c85a816e227984272a3c29b58aa7f7c1a76f1e9c` (`r102 report-last: verdict … — work c6f655d`)
- Upstream pin under test: `a6aa73ada02a9fb1f5415bec491f9942c519b297`
- Check timestamp (UTC): `2026-10-18T18:32:24Z`
- No Unreal runtime claims are made anywhere in this report: the checks are pure filesystem/byte
  operations. No editor was launched, no live MCP connection was attempted.

## 1. sha256 sweep — PASS (rc=0)

`sha256sum -c` run with the subtree as cwd, exactly as the gate README prescribes:

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
SWEEP_RC=0
```

12/12 `OK`, 0 `FAILED`. The sweep covers every tracked file (no symlinks, no submodules, no LFS,
matching the manifest's own header claim).

All 12 per-seat shard manifests in `.manifest.d/` sweep clean as well:

```
$ cd corpus/knowledge/unreal-mcp && for f in .manifest.d/*.sha256; do
    out=$(sha256sum -c "$f" 2>&1); rc=$?; ...
  done
audit-reference.sha256   rc=0 OK=12 FAILED=0
seat01.sha256            rc=0 OK=1  FAILED=0
seat02.sha256            rc=0 OK=1  FAILED=0
seat03.sha256            rc=0 OK=1  FAILED=0
seat04.sha256            rc=0 OK=1  FAILED=0
seat05.sha256            rc=0 OK=1  FAILED=0
seat06.sha256            rc=0 OK=1  FAILED=0
seat07.sha256            rc=0 OK=1  FAILED=0
seat08.sha256            rc=0 OK=1  FAILED=0
seat09.sha256            rc=0 OK=1  FAILED=0
seat10.sha256            rc=0 OK=1  FAILED=0
seat11.sha256            rc=0 OK=2  FAILED=0
```

14/14 shard entries `OK`, 0 `FAILED`, all rc=0.

Cross-consistency of the shard set against the audit reference (set difference, both directions):

```
$ comm -23 <(cat .manifest.d/*.sha256 | grep -v '^#' | grep -v '^$' | sort -u) \
           <(grep -v '^#' .manifest.d/audit-reference.sha256 | grep -v '^$' | sort -u)
(empty)
$ comm -13 <(cat .manifest.d/*.sha256 | grep -v '^#' | grep -v '^$' | sort -u) \
           <(grep -v '^#' .manifest.d/audit-reference.sha256 | grep -v '^$' | sort -u)
(empty)
$ cat .manifest.d/*.sha256 | grep -v '^#' | grep -v '^$' | awk '{print $2}' | sort -u | wc -l
12
```

The 11 seat shards cover exactly the same 12 `(sha256, path)` pairs as the audit reference: no extra
entry, no uncovered entry, no disagreement.

## 2. `git diff --stat` on the protected paths — PASS (empty, rc=0)

```
$ git diff --stat -- corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d
(no output)
GITDIFF_RC=0

$ git diff --exit-code --stat -- corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d
DIFF_EXITCODE_RC=0

$ git status --porcelain -- corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d
(empty)
STATUS_RC=0
```

The empty diff is **meaningful**, not vacuous — both trees are fully tracked and the on-disk set
equals the tracked set (checked, since an all-untracked subtree would also diff empty):

```
$ git ls-files corpus/knowledge/unreal-mcp/upstream | wc -l      → 12
$ find corpus/knowledge/unreal-mcp/upstream -type f | wc -l      → 12
$ git ls-files corpus/knowledge/unreal-mcp/.manifest.d | wc -l   → 12
$ find corpus/knowledge/unreal-mcp/.manifest.d -type f | wc -l   → 12

$ diff <(git ls-files … upstream | sed 's|.*/upstream/||' | sort) \
       <(cd …/upstream && find . -type f | sed 's|^\./||' | sort)
UPSTREAM_SET_IDENTICAL
$ diff <(git ls-files … .manifest.d | sed 's|.*/.manifest.d/||' | sort) \
       <(cd …/.manifest.d && find . -type f | sed 's|^\./||' | sort)
MANIFEST_SET_IDENTICAL

$ git check-ignore -v <a vendored file> <a shard manifest>   → rc=1 (nothing ignored)
```

No ignore rule masks either tree, so the empty diff cannot be an artifact of `.gitignore`.

## 3. Blob walk worktree-vs-HEAD — PASS (12/12 + 12/12)

Per-file `git hash-object` of the worktree compared against the HEAD blob (catches both modification
and deletion of tracked files):

```
$ while IFS=$'\t' read -r meta path; do sha=$(echo "$meta" | awk '{print $3}'); …
  done < <(git ls-tree -r HEAD -- <dir>)
corpus/knowledge/unreal-mcp/upstream:    identical=12 differing=0 missing=0
corpus/knowledge/unreal-mcp/.manifest.d: identical=12 differing=0 missing=0
```

Subtree object ids:

```
$ git ls-tree HEAD corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d
040000 tree 87bde5b7bc9517664cfbdae46d3cfeaded62e3e2	corpus/knowledge/unreal-mcp/.manifest.d
040000 tree b5b9624b00fc90217240e823406699d0ab78b959	corpus/knowledge/unreal-mcp/upstream
```

## 4. Strongest form — vendored bytes vs the pinned clone's blobs — PASS (12/12)

The manifest is only as trustworthy as the reference it encodes, so this seat independently
re-derived each vendored file's sha256 from the pinned clone rather than trusting the manifest:

```
$ cd /tmp/r101-audit && git rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297   → PIN_MATCH=yes

$ for f in $(cd upstream && find . -type f | sed 's|^\./||'); do
    a=$(sha256sum "upstream/$f" | cut -d' ' -f1)
    b=$(cd /tmp/r101-audit && git show "HEAD:$f" | sha256sum | cut -d' ' -f1)
    …
  done
MATCH README.md / .claude-plugin/plugin.json / hooks/hooks.json / hooks/unreal-context.sh /
      skills/unreal-mcp/SKILL.md / skills/unreal-mcp/references/operations.md /
      skills/unreal-mcp/references/setup.md / skills/unreal-skill/SKILL.md /
      skills/create-toolset/SKILL.md / CODEOWNERS / .gitignore / LICENSE
FILES_CHECKED=12 CROSSCHECK_FAIL=0
```

All 12 vendored files are byte-identical to `git show <pin>:<path>` from the clone. This is
independent of the committed manifest, so a corrupted-then-regenerated manifest could not hide here.

Consolidated digests of the two subtrees, for cross-seat reproduction:

```
$ (cd upstream && find . -type f | sed 's|^\./||' | sort | while read -r f; do
     printf '%s  %s\n' "$(sha256sum "$f" | cut -d' ' -f1)" "$f"; done) | sha256sum
16dfaa66647c40cfe0420ddef9e385378e1b7f2f90f5e4790236f9a619743963  -

$ (cd .manifest.d && … same …) | sha256sum
0c36de92e9c362d6911efa053586c32e7bd3e0d93956b8017e470e357b507102  -
```

## 5. No mid-round mutation — PASS (mtime evidence)

Byte identity at check time does not by itself exclude a write that happened and was reverted during
the round, so mtimes were inspected:

```
$ find corpus/knowledge/unreal-mcp/upstream -type f -printf '%TY-%Tm-%TdT%TH:%TM:%TS\n' | sort | sed -n '1p;$p'
  2026-10-18T14:06:49.9250259800     ← oldest (LICENSE)
  2026-10-18T14:43:32.6028366480     ← newest (skills/unreal-mcp/SKILL.md)

$ find corpus/knowledge/unreal-mcp/.manifest.d -type f -printf … | sort | sed -n '1p;$p'
  2026-10-18T14:13:32.2620551510     ← oldest
  2026-10-18T14:14:07.5243641970     ← newest (audit-reference.sha256)

$ find <both dirs> -type f -newermt '2026-10-18 14:44:00'
(empty)

$ git log -1 --format='%cI'
2026-10-18T15:27:40-03:00     ← HEAD commit (r102 report-last)
```

No file in either subtree was touched after `14:44`, i.e. at any point during round r103 — both trees
froze during the r101/r102 window and HEAD (`15:27:40-03:00`) landed afterwards without changing them.
Nothing was rewritten, so there is no silent rewrite to disclose and no correction note is owed.

## 6. Installed gate as corroboration — PASS (rc=0)

The gate was run against the live subtree (read-only; it writes nothing):

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
GATE unreal-mcp subtree
SUBTREE=…/corpus/knowledge/unreal-mcp
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
LANE_HEAD=c85a816e227984272a3c29b58aa7f7c1a76f1e9c
MANIFEST_FILES=12
CHECK 1 manifest-byte-identity   → MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0   STEP=PASS
CHECK 2 clone-equivalence        → CLONE_HEAD=a6aa73ad… CLONE_DIRTY=0 CLONE_TRACKED=12
                                   PATH_EXTRA=0 PATH_MISSING=0 BLOB_DIFFS=0    STEP=PASS
CHECK 3 verdict-card-scan        → CARDS=13 EXPECTED=13 BAD=0
                                   CENSUS static-only=12 unproven-runtime=1 verified-here=0
                                   STEP=PASS
CHECK 4 pointer-sweep            → POINTERS=88 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
                                   STEP=PASS
GATE RESULT: PASS (checks failed: 0)
GATE_RC=0
```

CHECK 2 independently confirms clone-equivalence (`BLOB_DIFFS=0`, `CLONE_DIRTY=0`) from the gate's
own path, agreeing with §4 above. Note the gate prints `POINTERS=88` at this moment, against the
`POINTERS=87` recorded for the pre-round gate — that is a concurrent seat's in-round edit to
`adaptation-kimi.md` (C1), not a change to either subtree under this seat's scope; §1–§5 are the
seats' proof and they are unaffected. `MANIFEST_FILES=12` and `MANIFEST_OK=12` confirm the manifest
set was not perturbed.

## Verdict

PASS. `upstream/` (12 files, tree `b5b9624b`) and `.manifest.d/` (12 files, tree `87bde5b7`) are
byte-stable for round r103 on every independent axis:

- `sha256sum -c .manifest.d/audit-reference.sha256` → **rc=0, 12/12 OK**; all 11 seat shards rc=0, 14/14 OK.
- `git diff --stat` and `git diff --exit-code` on both paths → **empty / rc=0**, with both trees
  fully tracked and not ignored, so the emptiness is substantive.
- Blob walk worktree-vs-HEAD → **12/12 + 12/12 identical**, 0 differing, 0 missing.
- Vendored bytes vs pinned clone `a6aa73ad…` → **12/12 match**, manifest-independent.
- No file in either subtree has an mtime after `14:44`, so no mid-round write-and-revert occurred.
- Installed gate → **PASS (rc=0)**, CHECK 1 `MANIFEST_OK=12 FAILED=0`, CHECK 2 `BLOB_DIFFS=0`.

No blockers. No corrections to prior claims are owed by this seat; nothing in the protected subtrees
was written by this seat.
