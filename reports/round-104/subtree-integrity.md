# r104 SEAT-41 — SUBTREE-INTEGRITY

Scope: prove `corpus/knowledge/unreal-mcp/upstream/` and `corpus/knowledge/unreal-mcp/.manifest.d/`
are byte-stable for this round — (a) `sha256` sweep rc=0, (b) `git diff --stat` on the subtree
outside `gate/` empty. Read-only: the only file this seat wrote is this report (plus a scratch
clone dir, deleted before close — §7).

- HEAD under test: `88c3b2ca70fc83ec47a931d7b6dcff85a111c04e` (`r103 report-last`; work `8c9d9ad`),
  re-read at close and unchanged.
- Upstream pin under test: `a6aa73ada02a9fb1f5415bec491f9942c519b297`
- Check window (UTC): `2026-10-18T19:16:12Z` – `2026-10-18T19:17:48Z`
- **No Unreal runtime claim** anywhere in this file. Every check is a filesystem/byte operation:
  no editor launched, no live MCP connection attempted. Nothing here promotes an
  `unproven-runtime` card.
- Related: `reports/round-103/subtree-integrity.md` (SEAT-54) is the r103 baseline this round
  re-runs against the new HEAD; §6 below confirms its consolidated digests reproduce exactly.

## 1. sha256 sweep — PASS (rc=0)

`sha256sum -c` run with the subtree as cwd, as the manifest header and gate README prescribe:

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
```

12/12 `OK`, 0 `FAILED`, rc=0. All 11 per-seat shard manifests sweep clean too:

```
$ for f in .manifest.d/*.sha256; do sha256sum -c "$f"; done
audit-reference.sha256  rc=0 OK=12 FAILED=0
seat01.sha256           rc=0 OK=1  FAILED=0
seat02.sha256           rc=0 OK=1  FAILED=0
seat03.sha256           rc=0 OK=1  FAILED=0
seat04.sha256           rc=0 OK=1  FAILED=0
seat05.sha256           rc=0 OK=1  FAILED=0
seat06.sha256           rc=0 OK=1  FAILED=0
seat07.sha256           rc=0 OK=1  FAILED=0
seat08.sha256           rc=0 OK=1  FAILED=0
seat09.sha256           rc=0 OK=1  FAILED=0
seat10.sha256           rc=0 OK=1  FAILED=0
seat11.sha256           rc=0 OK=1  FAILED=0
seat11.sha256           rc=0 OK=2  FAILED=0      ← seat11 carries 2 entries
```

14/14 shard entries `OK`, 0 `FAILED`, every rc=0.

Shard set vs audit reference, set difference in both directions:

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

## 2. `git diff --stat` on the subtree — PASS (empty)

```
$ git diff --stat -- corpus/knowledge/unreal-mcp/
(no output)

$ git diff --stat -- corpus/knowledge/unreal-mcp/ ':!corpus/knowledge/unreal-mcp/gate'
(no output)                                    ← subtree outside gate/ empty, as required

$ git status --porcelain -uall -- corpus/knowledge/unreal-mcp/
(empty)                                        ← no untracked strays in the subtree

$ git diff --cached --stat
(empty)                                        ← nothing staged
```

The empty diff is **substantive, not vacuous** — both trees are fully tracked, the on-disk set
equals the tracked set, and no ignore rule masks either tree:

```
$ git ls-files corpus/knowledge/unreal-mcp/upstream | wc -l        → 12
$ find corpus/knowledge/unreal-mcp/upstream -type f | wc -l        → 12
$ git ls-files corpus/knowledge/unreal-mcp/.manifest.d | wc -l     → 12
$ find corpus/knowledge/unreal-mcp/.manifest.d -type f | wc -l     → 12

$ diff <(git ls-files … upstream | sed 's|.*/upstream/||' | sort) \
       <(cd …/upstream && find . -type f | sed 's|^\./||' | sort)
UPSTREAM_SET_IDENTICAL_TO_TRACKED
$ diff <(git ls-files … .manifest.d | sed 's|.*/.manifest.d/||' | sort) \
       <(cd …/.manifest.d && find . -type f | sed 's|^\./||' | sort)
MANIFEST_SET_IDENTICAL_TO_TRACKED

$ git check-ignore -v corpus/knowledge/unreal-mcp/upstream/README.md \
                    corpus/knowledge/unreal-mcp/.manifest.d/seat01.sha256
(no output)  rc=1   ← nothing ignored
```

`upstream/` also holds no symlink, no `.git`, no submodule: `find … -type l | wc -l` → `0`, matching
the manifest's own header claim ("no symlinks, no submodules, no LFS, no .gitattributes").

**State caveat for the L1.** At this seat's check window the *entire* subtree is clean, including
`gate/` — `git status --porcelain -uall -- corpus/knowledge/unreal-mcp/gate` is empty and
`run_gate.sh` is still sha `577c8b54…`, i.e. the r103 scanner. The round brief expects `gate/` and
`SKILL.md` to be dirty; those seats (C2/C3) had not landed their edits yet when this snapshot was
taken (`19:16–19:17Z`). My empty diff therefore reads "clean as of 19:17Z", not "clean at close" —
git-hygiene must re-run after the last seat exits. Nothing outside `gate/` is claimed to have been
edited by any r104 seat, and that part of the claim is stable regardless of when the gate work lands.

## 3. Blob walk worktree-vs-HEAD — PASS (12/12 + 12/12)

Per-file `git hash-object` of the worktree against the HEAD blob (catches both modification and
deletion of tracked files):

```
$ while IFS=$'\t' read -r meta path; do sha=$(echo "$meta" | awk '{print $3}'); \
    cur=$(git hash-object -- "$path"); … ; done < <(git ls-tree -r HEAD -- <dir>)
corpus/knowledge/unreal-mcp/upstream:    identical=12 differing=0 missing=0
corpus/knowledge/unreal-mcp/.manifest.d: identical=12 differing=0 missing=0
```

Subtree object ids (unchanged from r103, where the same two trees were recorded):

```
$ git ls-tree HEAD corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d
040000 tree 87bde5b7bc9517664cfbdae46d3cfeaded62e3e2	corpus/knowledge/unreal-mcp/.manifest.d
040000 tree b5b9624b00fc90217240e823406699d0ab78b959	corpus/knowledge/unreal-mcp/upstream
```

Both tree ids are identical to the r103 report's values, so the r103→r104 HEAD advance
(`c85a816` → `88c3b2c`) did not touch either tree.

## 4. Strongest form — vendored bytes vs the pinned clone — PASS (12/12)

The manifest is only as trustworthy as the reference it encodes, so each vendored file's sha256 was
independently re-derived from the pinned upstream rather than trusting the manifest.

**The r103 clone `/tmp/r101-audit` no longer exists** (`ls: cannot access '/tmp/r101-audit': No such
file or directory`) — the same `/tmp` tmpfs churn that C2 is chasing this round, see §5. So the pin
was re-fetched and the cross-check rebuilt from scratch:

```
$ git clone --no-checkout --depth 1 <url> reports/round-104/scratch/pin-clone
CLONE_RC=0
$ git -C reports/round-104/scratch/pin-clone rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297     → PIN_MATCH=yes
$ git -C reports/round-104/scratch/pin-clone ls-tree -r HEAD --name-only | wc -l
12

$ for f in $(cd upstream && find . -type f | sed 's|^\./||' | sort); do
    a=$(sha256sum "upstream/$f" | cut -d' ' -f1)
    b=$(git -C <clone> show "HEAD:$f" | sha256sum | cut -d' ' -f1); … done
MATCH .claude-plugin/plugin.json / CODEOWNERS / .gitignore / hooks/hooks.json /
      hooks/unreal-context.sh / LICENSE / README.md / skills/create-toolset/SKILL.md /
      skills/unreal-mcp/references/operations.md / skills/unreal-mcp/references/setup.md /
      skills/unreal-mcp/SKILL.md / skills/unreal-skill/SKILL.md
FILES_CHECKED=12 CROSSCHECK_FAIL=0
```

All 12 vendored files are byte-identical to `git show <pin>:<path>`, and the vendored path set is
identical to the pin's tracked path set:

```
$ diff <(cd upstream && find . -type f | sed 's|^\./||' | sort) \
       <(git -C <clone> ls-tree -r HEAD --name-only | sort)
UPSTREAM_SET_IDENTICAL_TO_PIN
```

This is independent of the committed manifest, so a corrupted-then-regenerated manifest could not
hide here. The pin also still resolves upstream at check time:

```
$ git ls-remote <url> main
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main     rc=0
```

**Consolidated digests of the two subtrees, for cross-seat reproduction.** These reproduce the r103
values byte-for-byte, which ties r103's check and this one to the same bytes:

```
$ (cd upstream && find . -type f | sed 's|^\./||' | sort | while read -r f; do
     printf '%s  %s\n' "$(sha256sum "$f" | cut -d' ' -f1)" "$f"; done) | sha256sum
16dfaa66647c40cfe0420ddef9e385378e1b7f2f90f5e4790236f9a619743963  -   ← r103: same
$ (cd .manifest.d && … same …) | sha256sum
0c36de92e9c362d6911efa053586c32e7bd3e0d93956b8017e470e357b507102  -   ← r103: same
$ (cd <clone> && git ls-tree -r HEAD --name-only | sort | while read -r f; do
     printf '%s  %s\n' "$(git show "HEAD:$f" | sha256sum | cut -d' ' -f1)" "$f"; done) | sha256sum
16dfaa66647c40cfe0420ddef9e385378e1b7f2f90f5e4790236f9a619743963  -   ← vendored == pinned
```

The upstream digest computed from the pinned clone's blobs equals the digest computed from the
vendored worktree files — a third, manifest-free route to the same conclusion.

## 5. No mid-round mutation — PASS (mtime evidence) + a C2 corroboration

Byte identity at check time does not exclude a write that happened and was reverted, so mtimes were
inspected:

```
$ find corpus/knowledge/unreal-mcp/upstream -type f -printf '%TY-%Tm-%TdT%TH:%TM:%TS %p\n' | sort | sed -n '1p;$p'
  2026-10-18T14:06:49.9250259800  .claude-plugin/plugin.json   ← oldest
  2026-10-18T14:43:32.6028366480  skills/unreal-mcp/SKILL.md   ← newest

$ find corpus/knowledge/unreal-mcp/.manifest.d -type f -printf … | sort | sed -n '1p;$p'
  2026-10-18T14:13:32.2620551510  seat01.sha256
  2026-10-18T14:14:07.5243641970  audit-reference.sha256

$ find <both dirs> -type f -newermt '2026-10-18 15:32:00'
(empty)                                    ← nothing touched during round r104

$ git log -1 --format='%cI'
2026-10-18T16:13:38-03:00                  ← HEAD commit (r103 report-last)
```

No file in either subtree has an mtime inside the r104 window, so there was no write-and-revert and
no silent rewrite to disclose.

**Corroboration for C2 (reported, not a claim of this seat's fix).** While working, this seat
observed the environment condition the C2 brief names:

```
$ df -h /tmp
tmpfs  16G  13G  3.1G  80%  /tmp          ← /tmp is a 16G tmpfs at 80%, the r103 root cause
$ ls -d /tmp/r101-audit
ls: cannot access '/tmp/r101-audit': No such file or directory   ← r103's pinned clone is gone
$ grep -n 'mktemp' corpus/knowledge/unreal-mcp/gate/run_gate.sh
74:MANLOG=$(mktemp)
86:WORK=$(mktemp -d)                        ← still bare mktemp; no GATE_WORKDIR variable at 19:17Z
$ sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh
577c8b5489577b948536005a170da14ae3d4e13c11776aeca8f803bfb5fcefa0   ← unchanged from r103
$ T=$(TMPDIR=$PWD/reports/round-104/scratch/gate-tmp mktemp -d); echo "$T"
/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/reports/round-104/scratch/gate-tmp/tmp.8dtG4fwdp9
```

Two facts worth carrying into the C2 ruling: (i) the gate at this snapshot still calls bare
`mktemp` with no `GATE_WORKDIR`, so if C2 lands a workdir override it had not landed by `19:17Z`;
(ii) `mktemp` **already honours `TMPDIR`** on this host, so redirecting the gate's scratch away from
the pressured tmpfs needs no code change at all — an exported `TMPDIR` is sufficient, and a
`GATE_WORKDIR` variable would be additive convenience, not the load-bearing mechanism. This seat
used exactly that route for §6.

## 6. Installed gate as corroboration — PASS (rc=0)

The gate was run against the live subtree (read-only; it writes nothing into the subtree), with
`TMPDIR` pointed at a scratch dir outside `/tmp` per §5:

```
$ mkdir -p reports/round-104/scratch/gate-tmp
$ TMPDIR=$PWD/reports/round-104/scratch/gate-tmp bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
GATE unreal-mcp subtree
SUBTREE=…/corpus/knowledge/unreal-mcp
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
LANE_HEAD=88c3b2ca70fc83ec47a931d7b6dcff85a111c04e
MANIFEST_FILES=12
CHECK 1 manifest-byte-identity   → MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0            STEP=PASS
CHECK 2 clone-equivalence        → CLONE_HEAD=a6aa73ad… CLONE_DIRTY=0 CLONE_TRACKED=12
                                   PATH_EXTRA=0 PATH_MISSING=0 BLOB_DIFFS=0           STEP=PASS
CHECK 3 verdict-card-scan        → CARDS=13 EXPECTED=13 BAD=0
                                   CENSUS static-only=12 unproven-runtime=1 verified-here=0
                                   NAME_SET=OK NAME_BAD=0                             STEP=PASS
CHECK 4 pointer-sweep            → POINTERS=101 POINTER_STRINGS=41
                                   SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0           STEP=PASS
GATE RESULT: PASS (checks failed: 0)
GATE_RC=0
```

Cross-checks against the round brief's pins, all reproducing:

- `POINTERS=101 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0` — exactly the
  `POINTERS=101` the gate README pins (gate README sha `834f468d…`, scanner sha `577c8b54…`, both
  unchanged from r103). `adaptation-kimi.md` sha256 is `084a34cd94806caa497de1ab80df84f95876114048ead83bc158b4d50de8c879`,
  matching the README's `084a34cd…` stamp — so the 101 pin reproduces on the exact bytes it was
  measured against.
- `LANE_HEAD=88c3b2ca…` — the gate itself confirms the HEAD under test.
- Exit code `0` = PASS on the A4 convention (0 PASS / 1 FAIL / 2 BLOCKED); no BLOCKED path taken.
- `CARDS=13 … verified-here=0` — the gate's own census carries **zero** runtime-verified cards,
  consistent with this report's no-runtime-claim posture. Unreal Editor is not installed on this
  host, so `verified-here=0` is the correct and expected value, not a gap this seat can close.
- CHECK 2 independently confirms clone-equivalence (`BLOB_DIFFS=0`, `CLONE_DIRTY=0`) from the gate's
  own path, agreeing with §4.

## 7. Scratch hygiene

This seat's only non-report write was the scratch dir `reports/round-104/scratch/` (pin clone,
gate output, `TMPDIR` target). It was removed before close and is not part of the deliverable:

```
$ rm -rf reports/round-104/scratch && ls reports/round-104/
freshness-pin.md  gate  ledger-check.md  physics
```

The clone was deliberately placed under the repo (untracked) rather than in `/tmp` because `/tmp`
was at 80% and the round's own C2 subject is `/tmp` exhaustion — placing a full clone there would
have been the failure mode under study. No pinned-subtree byte and no other seat's report was
written or modified by this seat. No `git commit/push/checkout/reset` was run.

## Verdict

**PASS.** `upstream/` (12 files, tree `b5b9624b`) and `.manifest.d/` (12 files, tree `87bde5b7`) are
byte-stable for round r104 on every independent axis, at HEAD `88c3b2ca70fc83ec47a931d7b6dcff85a111c04e`:

- `sha256sum -c .manifest.d/audit-reference.sha256` → **rc=0, 12/12 OK**; all 11 seat shards rc=0,
  14/14 OK; shard set == audit set (both `comm` diffs empty).
- `git diff --stat` on the whole subtree **and** on the subtree outside `gate/` → **empty**; nothing
  staged, no untracked strays, both trees fully tracked and not ignored, so the emptiness is
  substantive.
- Blob walk worktree-vs-HEAD → **12/12 + 12/12 identical**, 0 differing, 0 missing; tree ids equal to
  r103's.
- Vendored bytes vs a **freshly re-cloned** pin `a6aa73ad…` → **12/12 match**, manifest-independent;
  path set identical to the pin's tracked set; consolidated digests reproduce r103 exactly
  (`16dfaa66…` upstream, `0c36de92…` `.manifest.d`) and the clone-derived digest equals the
  vendored one.
- No file in either subtree has an mtime inside the r104 window → no mid-round write-and-revert.
- Installed gate → **PASS (rc=0)**, CHECK 1 `MANIFEST_OK=12 FAILED=0`, CHECK 2 `BLOB_DIFFS=0`,
  CHECK 4 `POINTERS=101 … UNRESOLVED=0`, all matching the round brief's pins.

**Blockers / notes for the L1 (not blockers to this verdict):**

1. `/tmp/r101-audit` (r103's pinned clone) **is gone**, and `/tmp` is a 16G tmpfs at **80%** — the
   exact r103 root cause C2 is chasing. §4 was rebuilt from a fresh clone under the repo instead.
   Anything that depends on a `/tmp` clone surviving between rounds is not durable on this host.
2. At my check window (`19:16–19:17Z`) `gate/` is **still clean** and `run_gate.sh` is still the r103
   scanner (`577c8b54…`, bare `mktemp` at lines 74 and 86, **no `GATE_WORKDIR`**). The round brief
   expects `gate/` + `SKILL.md` dirty; C2/C3 had not landed when this snapshot was taken. This
   report's empty-diff result is timestamped, and git-hygiene must re-run `git status --porcelain
   -uall` after the last seat exits.
3. `mktemp` already honours `TMPDIR` here (verified, §5), so C2's `/tmp`-resilience goal is
   achievable with an exported `TMPDIR` alone; a `GATE_WORKDIR` variable would be a convenience
   layer over that, not the mechanism. Worth stating plainly in the C2 ruling so the fix is not
   over-engineered.
4. `SKILL.md` **does not exist at the repo root** (`ls SKILL.md` → rc=2) as of this snapshot; the
   only `SKILL.md` files in the tree are the three vendored upstream ones under
   `corpus/knowledge/unreal-mcp/upstream/skills/**`, which are pinned bytes and must not be touched
   to satisfy C3. No runtime claim is made or implied anywhere in this report.
