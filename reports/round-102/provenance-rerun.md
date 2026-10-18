# SEAT-52 PROVENANCE-RERUN — spot-check of `PROVENANCE.md` §8 out-of-pin hashes

- Round r102 · lane game-dev-3d-shokunin · seat SEAT-52 (provenance re-run).
- Repo HEAD at run: `2c99b7b` (`2c99b7b8155841617d844c609813afcba77aa207`).
- Run timestamp: `2026-10-18T17:41:47Z` (all commands below executed on this host, this session).
- Target under test: `corpus/knowledge/unreal-mcp/PROVENANCE.md` §8 "Known out-of-pin upstream
  surface (recorded, not vendored)" — 6 recorded rows, adopted from
  `reports/round-101/r101-critic-c1.md` §3b/§3d and labeled **[I]** there.
- Scope of this seat: **re-derive, do not edit.** The r101 subtree
  (`corpus/knowledge/unreal-mcp/`) is byte-pinned and was **not modified** by this seat. This
  file is the only artifact written.
- Network: allowed and used. All upstream access is **read-only** (`git clone`, `git fetch`,
  `git ls-remote`, `gh api`, `git archive`). No push, no PR mutation, no fork.

**Headline verdict: MATCHES — 6/6 recorded hashes re-derive exactly. Two `PRESENT-DIFFERENT`
observations on the *surface*, not on the hashes: a divergent sibling `marketplace.json` in PR 2
(not in §8's table), and a new PR 8 that did not exist when §8 was written.**

---

## 1. Method

Two independent resolution paths, so a stale or poisoned local ref cannot fake a match:

- **Path A — ref-name resolution.** Fresh clone of the public repo, then
  `git fetch origin 'refs/pull/*/head:refs/remotes/pr/*'`; content read with
  `git show <ref>:<path> | sha256sum`.
- **Path B — SHA resolution in a second clean clone.** PR head SHAs resolved via the GitHub API
  (`gh api …/pulls/<n> --jq .head.sha`), then fetched **by SHA** in a *different* fresh clone;
  content read the same way.

Both paths also confirm the pin itself: a fresh clone's `HEAD` is
`a6aa73ada02a9fb1f5415bec491f9942c519b297`, i.e. the pin is still the tip of `main` on
2026-10-18 (`gh api … --jq '.default_branch, .private, .pushed_at'` → `main`, `false`,
`2026-09-17T02:27:43Z` — repo untouched since the pin, so no pin drift).

### Clone and fetch (Path A)

```
$ git clone --quiet https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin /tmp/r102-pr-probe
$ cd /tmp/r102-pr-probe && git rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297

$ git fetch --quiet origin 'refs/pull/*/head:refs/remotes/pr/*'
$ git for-each-ref --format='%(refname) %(objectname:short) %(subject)' refs/remotes/pr/
refs/remotes/pr/1 435522c Add .claude-plugin/marketplace.json so the repo installs as a marketplace
refs/remotes/pr/2 6dd839e Add Marketplace.json
refs/remotes/pr/4 83807c0 Add PowerShell companion hook, test suite, and CI workflow
refs/remotes/pr/5 c64c609 Quote CLAUDE_PLUGIN_ROOT in SessionStart hook command
refs/remotes/pr/8 1a3476f Add OpenCode port of the Unreal Engine skills plugin

$ git status --porcelain
(empty)          # worktree clean: what was hashed is what the ref contains
```

`git ls-remote origin | grep refs/pull` (verbatim, 2026-10-18T17:41Z):

```
435522c0c66685049ac624fef04568ec313bebe7	refs/pull/1/head
f425ff946c82cf602c754c69871bc23d233a0daa	refs/pull/1/merge
6dd839e996900e226316b30a7fc00ee6f58a6772	refs/pull/2/head
dba9b0161e01f948dba80f012ee934908170815a	refs/pull/2/merge
83807c0ea52bef194537e8ccbe3028d4b9daedc9	refs/pull/4/head
721993ece2ebcbadf711c05cfcc17857a4de02bc	refs/pull/4/merge
c64c609745de466cecb184707ff5974fb9375339	refs/pull/5/head
962126c7d5660f673c1375d32c92224a66738f09	refs/pull/5/merge
1a3476f7a1f3676c78f0153014c3e48b8b8a2a68	refs/pull/8/head
9f34125b1b44543c8b0b79ad39a12881134b8b06	refs/pull/8/merge
```

The five PR head SHAs match `r101-critic-c1.md` §3b byte for byte, and the four PRs the critic
saw are still **OPEN / unmerged** (`gh pr view <n> --json state,mergedAt` → `OPEN merged=null`
for 1, 2, 4, 5), so the out-of-pin surface §8 recorded is still live, not merged away.

## 2. The two required spot-checks — both **MATCHES**

### Spot-check 1 — `.claude-plugin/marketplace.json` (recorded: PR 1, 908 B, `390e7e9c…`)

Path A (ref-name):

```
$ git show refs/remotes/pr/1:.claude-plugin/marketplace.json | sha256sum
390e7e9c9a4f21d7835541bb3b79ebb7afb5392d6ba0ce1e090b7a17ba6a77d8  -
$ git cat-file -s refs/remotes/pr/1:.claude-plugin/marketplace.json
908
```

Path B (API-resolved SHA, second clean clone):

```
$ gh api repos/EpicGames/unreal-engine-skills-for-claude-code-plugin/pulls/1 --jq .head.sha
435522c0c66685049ac624fef04568ec313bebe7
$ git -C /tmp/r102-pr-probe2 fetch --quiet origin 435522c0c66685049ac624fef04568ec313bebe7
$ git -C /tmp/r102-pr-probe2 show 435522c0c66685049ac624fef04568ec313bebe7:.claude-plugin/marketplace.json | sha256sum
390e7e9c9a4f21d7835541bb3b79ebb7afb5392d6ba0ce1e090b7a17ba6a77d8  -
```

Recorded `390e7e9c9a4f21d7835541bb3b79ebb7afb5392d6ba0ce1e090b7a17ba6a77d8` == re-derived.
**MATCHES**, size 908 B == recorded 908 B.

A third, independent extraction path (archive, no `git show`):

```
$ git archive refs/remotes/pr/1 | tar -x -C /tmp/r102-arch --one-top-level=pr1
$ sha256sum /tmp/r102-arch/pr1/.claude-plugin/marketplace.json
390e7e9c9a4f21d7835541bb3b79ebb7afb5392d6ba0ce1e090b7a17ba6a77d8  /tmp/r102-arch/pr1/.claude-plugin/marketplace.json
```

### Spot-check 2 — `hooks/unreal-context.ps1` (recorded: PR 4, 3322 B, `eaf782fe…`)

Path A:

```
$ git show refs/remotes/pr/4:hooks/unreal-context.ps1 | sha256sum
eaf782fecd4430f0d04a50179742841eb5922c08162758b5de7cf7fc343f1c7f  -
$ git cat-file -s refs/remotes/pr/4:hooks/unreal-context.ps1
3322
```

Path B:

```
$ gh api repos/EpicGames/unreal-engine-skills-for-claude-code-plugin/pulls/4 --jq .head.sha
83807c0ea52bef194537e8ccbe3028d4b9daedc9
$ git -C /tmp/r102-pr-probe2 fetch --quiet origin 83807c0ea52bef194537e8ccbe3028d4b9daedc9
$ git -C /tmp/r102-pr-probe2 show 83807c0ea52bef194537e8ccbe3028d4b9daedc9:hooks/unreal-context.ps1 | sha256sum
eaf782fecd4430f0d04a50179742841eb5922c08162758b5de7cf7fc343f1c7f  -
```

Recorded `eaf782fecd4430f0d04a50179742841eb5922c08162758b5de7cf7fc343f1c7f` == re-derived.
**MATCHES**, size 3322 B == recorded 3322 B.

## 3. Full-sweep result — all 6 rows, for completeness

Beyond the required 2, every row of §8's table was re-derived (same command shape:
`git show <ref>:<path> | sha256sum`). No row is stale or wrong.

| path (as recorded) | recorded where | recorded bytes | recorded sha256 | re-derived | bytes | verdict |
|---|---|---|---|---|---|---|
| `.claude-plugin/marketplace.json` | open PR 1 | 908 | `390e7e9c…a77d8` | `390e7e9c9a4f21d7835541bb3b79ebb7afb5392d6ba0ce1e090b7a17ba6a77d8` | 908 | **MATCHES** |
| `.github/workflows/ci.yml` | open PR 4 | 1116 | `4bac0081…4cc38d` | `4bac0081914d78f80be04c1776fe2244b53c6c4334116309f4ba5b83c04cc38d` | 1116 | **MATCHES** |
| `hooks/unreal-context.ps1` | open PR 4 | 3322 | `eaf782fe…f1c7f` | `eaf782fecd4430f0d04a50179742841eb5922c08162758b5de7cf7fc343f1c7f` | 3322 | **MATCHES** |
| `tests/test_hooks.sh` | open PR 4 | 2778 | `35215587…9caa65` | `35215587a86fd593bb53c0c90ccbc7f7a13a5179744e9616ef9670be5e9caa65` | 2778 | **MATCHES** |
| `tests/test_hooks.ps1` | open PR 4 | 3796 | `755befe2…3c06a8` | `755befe2e509ae3a3c384ded7fd7ace68b501611eb6d10dc1218b23d6f3c06a8` | 3796 | **MATCHES** |
| `skills/unreal-mcp/references/toolsets.md` | history-only (deleted in `823f598`) | 8306 | blob `eaf2e838…` | blob `eaf2e838a259fb41be10309f9373bca8778607c5` | 8306 | **MATCHES** |

Verbatim for the four rows not covered above:

```
$ git show refs/remotes/pr/4:.github/workflows/ci.yml | sha256sum
4bac0081914d78f80be04c1776fe2244b53c6c4334116309f4ba5b83c04cc38d  -
$ git show refs/remotes/pr/4:tests/test_hooks.sh | sha256sum
35215587a86fd593bb53c0c90ccbc7f7a13a5179744e9616ef9670be5e9caa65  -
$ git show refs/remotes/pr/4:tests/test_hooks.ps1 | sha256sum
755befe2e509ae3a3c384ded7fd7ace68b501611eb6d10dc1218b23d6f3c06a8  -
```

History-only row, re-derived exactly as §8 records it (blob id, size, and — added here — the
blob's own sha256, which §8 does not carry):

```
$ git rev-parse 823f598^:skills/unreal-mcp/references/toolsets.md
eaf2e838a259fb41be10309f9373bca8778607c5
$ git cat-file -s eaf2e838a259fb41be10309f9373bca8778607c5
8306
$ git cat-file blob eaf2e838a259fb41be10309f9373bca8778607c5 | sha256sum
1b184bbb31836319ef50ad0661306f7e22bbcf19bf71bed70b6a58d60da69cec  -
```

Note the sha256 `1b184bbb…` is the *deleted* file's content hash, not the blob id; §8 records
only the blob id (`eaf2e838…`), which is correct for a history-only row and is confirmed above.
`r101-critic-c1.md` §3d carries the same sha256 — the two records agree.

**Every recorded hash reproduces. §8's hash table is trustworthy as of 2026-10-18T17:41Z.**

## 4. PRESENT-DIFFERENT observations on the recorded *surface*

These do not falsify any hash. They concern §8's framing of the surface as a fixed list.

### 4a. PR 2 carries a *different* `marketplace.json` — the table names only PR 1

§8 records `.claude-plugin/marketplace.json` once, "open PR 1", 908 B, `390e7e9c…`. PR 2
carries the same path at a **different** size and hash, and PR 4 carries the same 908 B blob as
PR 1:

```
$ for r in pr/1 pr/2 pr/4; do printf '%s  %s  bytes=%s\n' "$r" \
    "$(git show refs/remotes/$r:.claude-plugin/marketplace.json | sha256sum | cut -d' ' -f1)" \
    "$(git cat-file -s refs/remotes/$r:.claude-plugin/marketplace.json)"; done
pr/1  390e7e9c9a4f21d7835541bb3b79ebb7afb5392d6ba0ce1e090b7a17ba6a77d8  bytes=908
pr/2  1de11f5620043f9a3168da232d3dc0e9a736c45d5557564d9fa8e6542124551f  bytes=907
pr/4  390e7e9c9a4f21d7835541bb3b79ebb7afb5392d6ba0ce1e090b7a17ba6a77d8  bytes=908
```

**PRESENT-DIFFERENT** (additive): the same path exists in **two distinct versions** across live
refs; §8 lists one row. `r101-critic-c1.md` §3b recorded only PR 1's identity too, so §8 is a
faithful copy of its source — this is an under-enumeration inherited from the critic, not a
transcription error. Also `PR 4` is a third carrier of the PR-1 blob, so "open PR 1" is not the
only location.

### 4b. A new PR 8 appeared 16 minutes *after* §8's snapshot

`refs/pull/8/head` = `1a3476f7a1f3676c78f0153014c3e48b8b8a2a68`, "Add OpenCode port of the
Unreal Engine skills plugin", committed `2026-10-18 18:33:58 +0100` (= `17:33:58Z`), created
`2026-10-18T17:34:13Z` per the API — i.e. after `PROVENANCE.md` §6's snapshot timestamp
`17:18:24Z` and after the critic's run. Ten new-in-ref paths, all absent at the pin and absent
from §8:

```
$ git ls-tree -r refs/remotes/pr/8 --name-only | sort -u | while read p; do
    git cat-file -e HEAD:$p 2>/dev/null || echo "NEW-IN-REF: $p"; done
NEW-IN-REF: opencode/.gitignore
NEW-IN-REF: opencode/index.ts
NEW-IN-REF: opencode/package.json
NEW-IN-REF: opencode/project.ts
NEW-IN-REF: opencode/README.md
NEW-IN-REF: opencode/scripts/sync-skills.mjs
NEW-IN-REF: opencode/skills.ts
NEW-IN-REF: opencode/test/plugin.test.ts
NEW-IN-REF: opencode/test/project.test.ts
NEW-IN-REF: opencode/test/skills.test.ts
```

**PRESENT-DIFFERENT** (surface drift, expected): the upstream repo is live. §8 explicitly frames
its rows as a recorded snapshot ("Hashes below are as recorded by that review"), so a later PR is
not a defect in §8 — but a reader must not treat the six-row table as the complete out-of-pin
surface. It was complete for the four refs that existed at r101, and is not complete now.

### 4c. The out-of-pin surface is still entirely unvendored (positive control)

§8 claims these paths are "recorded, not vendored". Re-checked against the pinned subtree:

```
$ cd corpus/knowledge/unreal-mcp
$ for p in .claude-plugin/marketplace.json .github/workflows/ci.yml hooks/unreal-context.ps1 \
           tests/test_hooks.sh tests/test_hooks.ps1 opencode/index.ts; do
    printf '%s -> ' "$p"; [ -e upstream/$p ] && echo PRESENT || echo ABSENT; done
.claude-plugin/marketplace.json -> ABSENT
.github/workflows/ci.yml -> ABSENT
hooks/unreal-context.ps1 -> ABSENT
tests/test_hooks.sh -> ABSENT
tests/test_hooks.ps1 -> ABSENT
opencode/index.ts -> ABSENT

$ sha256sum -c .manifest.d/audit-reference.sha256 | tail -3
upstream/skills/unreal-mcp/references/setup.md: OK
upstream/skills/unreal-mcp/SKILL.md: OK
upstream/skills/unreal-skill/SKILL.md: OK
exit=0
```

12/12 `OK`, exit 0: this seat's read-only re-run did not disturb the byte-pinned subtree, and the
claim "recorded, not vendored" holds for both the six §8 rows and the new PR-8 paths.

## 5. What this seat did not claim

- No Unreal Editor, UnrealBuildTool, or MCP tool call was run; none can be on this host
  (`PROVENANCE.md` §5). Nothing here is runtime evidence — the editor is not installed and
  live-MCP behavior remains **unproven by construction**.
- Re-deriving a hash proves *what bytes a ref contains today*; it does not prove the ref will
  still contain them later, nor that any PR will merge. PR state was OPEN at
  `2026-10-18T17:41Z` and is re-checkable with `gh pr view <n>`.
- §8's rows remain **[I]** (inference, copied from the critic) in `PROVENANCE.md`; this run is
  independent **[O]** corroboration of their hash values, not a rewrite of that file. No edit was
  made to `corpus/knowledge/unreal-mcp/` — the byte-pinned subtree is untouched by this seat.
- The blob id `eaf2e838…` and the sha256 `1b184bbb…` for the history-only row are different
  identity spaces; this report records both so neither is mistaken for the other.

## 6. Reproduce in one block

```sh
git clone https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin /tmp/r102-pr-probe
cd /tmp/r102-pr-probe
git rev-parse HEAD                     # expect a6aa73ada02a9fb1f5415bec491f9942c519b297
git fetch origin 'refs/pull/*/head:refs/remotes/pr/*'
git show refs/remotes/pr/1:.claude-plugin/marketplace.json | sha256sum
#   expect 390e7e9c9a4f21d7835541bb3b79ebb7afb5392d6ba0ce1e090b7a17ba6a77d8
git show refs/remotes/pr/4:hooks/unreal-context.ps1 | sha256sum
#   expect eaf782fecd4430f0d04a50179742841eb5922c08162758b5de7cf7fc343f1c7f
```
