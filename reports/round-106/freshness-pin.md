# SEAT-73 · FRESHNESS-PIN

Round r106 · lane `game-dev-3d-shokunin` · checked 2026-10-18 UTC.
Seat scope: `git ls-remote` versus the recorded pin. Owned write:
`reports/round-106/freshness-pin.md` only. Nothing under `corpus/` was written.
`LOG.md`, `SCORECARD.md`, `SHONEN.md`, `PROVINCE.md`, `SKILL.md`,
`reports/round-101/**` … `reports/round-105/**`,
`corpus/knowledge/unreal-mcp/upstream/**`,
`corpus/knowledge/unreal-mcp/.manifest.d/**`,
`corpus/knowledge/unreal-mcp/gate/**`, and `corpus/fixtures/**` were not touched.

Axes: **coverage** (the pin citation in `PROVENANCE.md` resolves to live `main`),
**depth** (four transports plus a fresh clone and a byte diff), **calibration**
(quoted SHA / subject / dates / blob prefixes versus the live tip; out-of-pin
delta recorded, not silently rewritten). Labels: **[O]** observed here, **[I]**
inference. No Unreal Editor, MCP endpoint, or engine binary was involved. The
editor is not installed; no runtime claim is made.

Upstream URL (`PROVENANCE.md:19` **[O]**):
`https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin`
Pinned commit under test (`PROVENANCE.md:22` **[O]**):
`a6aa73ada02a9fb1f5415bec491f9942c519b297`

---

## 1. Verdict

**FRESH — no pin drift.** At `2026-10-18T21:20:18Z`–`21:20:19Z`, `refs/heads/main`
and symbolic `HEAD` both resolved to the recorded pin. A bare clone made this
round re-derived the same SHA. The vendored tree is byte-identical to that tip
(`diff -rq` empty, `DIFF_EXIT=0`, re-checked `2026-10-18T21:29:15Z`). No re-fetch,
re-pin, or decontamination is owed for the pin itself.

What did move, and did **not** land on `main`: open PR **#9**
(`[MCP] Document 5.8.3 toolset quirks, bump to 3.1.2`, head
`a5180ccd03c2813682a7fa19ca25ee9967bfe1de`, `mergedAt: null`). It was created
`2026-10-18T20:06:45Z` (after the r104 freshness check at `19:17:14Z`, before the
r105 pin check at `20:31:23Z`) and its head commit was updated
`2026-10-18T21:13:26Z` (after r105). `main`'s tip is still the pin. §6 queues the
citation notes; this seat did not edit them.

## 2. Primary transports

```
$ date -u '+%Y-%m-%dT%H:%M:%SZ'; git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin refs/heads/main
2026-10-18T21:20:18Z
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main
exit_main=0

$ git ls-remote --symref https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin HEAD
ref: refs/heads/main	HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297	HEAD
exit_head=0

$ git ls-remote --heads https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main
exit_heads=0

$ git ls-remote --tags https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
(no output)
exit_tags=0

$ date -u '+%Y-%m-%dT%H:%M:%SZ'
2026-10-18T21:20:19Z
```

**[O]** One branch head. `HEAD → refs/heads/main → a6aa73ad…`. No tags. SHA equals
the pin exactly. Window is one second.

Recorded pin, worktree and `HEAD` (`0cc3f4162f8c319f8d01a69a174fe939f36701bd`). Commands as run:

```
$ python3 - <<'PY'
import re
text=open("corpus/knowledge/unreal-mcp/PROVENANCE.md").read()
m=re.search(r"\| pinned commit \| `([0-9a-f]{40})`", text)
print("worktree_pin="+m.group(1))
print("line22_present", "a6aa73ada02a9fb1f5415bec491f9942c519b297" in text.splitlines()[21])
PY
worktree_pin=a6aa73ada02a9fb1f5415bec491f9942c519b297
line22_present True

$ git show HEAD:corpus/knowledge/unreal-mcp/PROVENANCE.md | python3 -c 'import re,sys; t=sys.stdin.read(); m=re.search(r"\| pinned commit \| `([0-9a-f]{40})`", t); print("head_pin="+m.group(1)); print("worktree_vs_head_same", open("corpus/knowledge/unreal-mcp/PROVENANCE.md").read()==t)'
head_pin=a6aa73ada02a9fb1f5415bec491f9942c519b297
worktree_vs_head_same True
```

**[O]** at `2026-10-18T21:21:22Z`–`21:21:23Z`. The citation and the committed blob
name the same 40-hex pin the remote just returned.

## 3. GitHub REST and URL form

```
$ gh api repos/EpicGames/unreal-engine-skills-for-claude-code-plugin \
    --jq '{default_branch, pushed_at, updated_at, archived, private}'
{"archived":false,"default_branch":"main","private":false,
 "pushed_at":"2026-09-17T02:27:43Z","updated_at":"2026-10-18T21:20:17Z"}
exit_meta=0

$ gh api repos/EpicGames/unreal-engine-skills-for-claude-code-plugin/git/ref/heads/main \
    --jq '.object.sha'
a6aa73ada02a9fb1f5415bec491f9942c519b297
exit_ref=0

$ gh api "repos/EpicGames/unreal-engine-skills-for-claude-code-plugin/commits?sha=main&per_page=3" \
    --jq '.[] | {sha, date: .commit.committer.date, msg: .commit.message|split("\n")[0]}'
{"date":"2026-09-17T01:28:32Z","msg":"[MCP] Permit safe concurrent tool calls",
 "sha":"a6aa73ada02a9fb1f5415bec491f9942c519b297"}
{"date":"2026-09-10T23:03:32Z","msg":"Document MCP proxy setup and recovery, bump to `3.1.0`",
 "sha":"d1b05809e4f089bd0ef174532c692fbcf1562eb7"}
{"date":"2026-07-22T19:18:50Z","msg":"Merge pull request #31 from docs/point-install-at-claude-marketplace",
 "sha":"7e3b09bbf6d2984c155233f9d3de5fcf523d2d42"}
exit_commits=0

$ curl -sIL --max-time 20 -o /dev/null -w 'no_suffix=%{http_code}\n' \
    https://github.com/EpicGames/unreal-engine-skills-for-claude-code
no_suffix=404
$ curl -sIL --max-time 20 -o /dev/null -w 'plugin=%{http_code}\n' \
    https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
plugin=200
```

**[O]** Bracket `2026-10-18T21:20:27Z`–`21:20:29Z` for the API/HTTP block; commits
listing in the `21:21:22Z` block. `default_branch` is `main`. `pushed_at`
(`2026-09-17T02:27:43Z`) is unchanged from the r104 reading and is older than this
check; the newer `updated_at` is repo metadata, not a branch push **[I]**. The
load-bearing fact is the ref SHA, which matches the pin, and the commits listing,
whose first entry is the pin. The no-suffix URL is still 404; the `-plugin` URL
is 200.

## 4. Fresh clone re-derives the pin

Scratch was `$HOME/r106-seat73` (not `/tmp`; host `/tmp` quota note). Bare clone:

```
$ date -u '+%Y-%m-%dT%H:%M:%SZ'
2026-10-18T21:20:26Z
$ git clone --quiet --bare \
    https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin fresh.git
CLONE_EXIT=0
$ git -C fresh.git rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
$ git -C fresh.git rev-parse refs/heads/main
a6aa73ada02a9fb1f5415bec491f9942c519b297
$ git -C fresh.git log -1 --format='%H%n%s%n%an <%ae>%n%ai%n%ci'
a6aa73ada02a9fb1f5415bec491f9942c519b297
[MCP] Permit safe concurrent tool calls
Thomas Mansencal <thomas.mansencal@epicgames.com>
2026-09-17 13:19:50 +1200
2026-09-17 13:28:32 +1200
TRACKED=12
```

**[O]** Subject, author, author date, and committer date match `PROVENANCE.md` §1
(lines 24–26). Twelve tracked paths, same set as §2. Blob prefixes
(`git ls-tree -r HEAD`, first 8 hex) match §2's git-blob column 12/12:

| path | blob | §2 |
|---|---|---|
| `.claude-plugin/plugin.json` | `ba4e660a` | `ba4e660a` |
| `.gitignore` | `aa5fae26` | `aa5fae26` |
| `CODEOWNERS` | `7ccb8b76` | `7ccb8b76` |
| `LICENSE` | `4a38912a` | `4a38912a` |
| `README.md` | `44c8dd3e` | `44c8dd3e` |
| `hooks/hooks.json` | `6be4b8b7` | `6be4b8b7` |
| `hooks/unreal-context.sh` | `8c06ba24` | `8c06ba24` |
| `skills/create-toolset/SKILL.md` | `febf5d5a` | `febf5d5a` |
| `skills/unreal-mcp/SKILL.md` | `9cd2cc26` | `9cd2cc26` |
| `skills/unreal-mcp/references/operations.md` | `e02d8d0e` | `e02d8d0e` |
| `skills/unreal-mcp/references/setup.md` | `49a921a9` | `49a921a9` |
| `skills/unreal-skill/SKILL.md` | `a1513865` | `a1513865` |

Vendored bytes versus that clone (archive extracted to `$HOME/r106-seat73/tree`):

```
$ date -u '+%Y-%m-%dT%H:%M:%SZ'
2026-10-18T21:29:15Z
$ diff -rq "$HOME/r106-seat73/tree" corpus/knowledge/unreal-mcp/upstream
(no output)
DIFF_EXIT=0
clone_tracked=12
archive_files=12
vendored_files=12
```

**[O]** Live tip tree equals the vendored copy. Manifest check, cwd
`corpus/knowledge/unreal-mcp/`, same invocation as the first `diff -rq`
(`DIFF_EXIT=0`, no diff output). That invocation's trailing `date` did not
print: `set -e` stopped on the `/tmp` probe (exit 128, §6). The `OK` lines
below were observed before that stop. The `21:29:15Z` re-diff above is the
timestamped byte-identity receipt.

```
$ sha256sum -c .manifest.d/audit-reference.sha256
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
MANIFEST_EXIT=0
```

**[O]** 12/12 `OK`. Vendored `plugin.json` version is still `3.1.1`. Command as run,
at `2026-10-18T21:22:59Z`:

```
$ python3 -c 'import json; print(json.load(open("corpus/knowledge/unreal-mcp/upstream/.claude-plugin/plugin.json"))["version"])'
3.1.1
```

PR #9's version bump has not entered the pin.

Scratch removal, after the `21:29:15Z` re-diff:

```
$ rm -rf "$HOME/r106-seat73" && test ! -e "$HOME/r106-seat73" && echo "REMOVED $HOME/r106-seat73"
REMOVED /home/vgpnk/r106-seat73
$ date -u '+%Y-%m-%dT%H:%M:%SZ'
2026-10-18T21:35:16Z
```

**[O]** Reproduce the clone with the commands above; the scratch directory is gone.

## 5. Out-of-pin surface — pin unchanged, PR set grew

```
$ gh pr list --repo EpicGames/unreal-engine-skills-for-claude-code-plugin \
    --state all --limit 20 --json number,title,state,mergedAt,headRefOid
#9 OPEN merged=null a5180ccd03c2813682a7fa19ca25ee9967bfe1de
   [MCP] Document 5.8.3 toolset quirks, bump to 3.1.2
#8 OPEN merged=null 1a3476f7a1f3676c78f0153014c3e48b8b8a2a68
#5 OPEN merged=null c64c609745de466cecb184707ff5974fb9375339
#4 OPEN merged=null 83807c0ea52bef194537e8ccbe3028d4b9daedc9
#2 OPEN merged=null 6dd839e996900e226316b30a7fc00ee6f58a6772
#1 OPEN merged=null 435522c0c66685049ac624fef04568ec313bebe7
exit_pr=0
```

**[O]** at `2026-10-18T21:20:27Z`. Heads of #1, #2, #4, #5, #8 match the SHAs
printed in `reports/round-104/freshness-pin.md` §6. None merged.

PR #9 detail. Commands as run, `2026-10-18T21:21:22Z`–`21:22:59Z`:

```
$ gh pr view 9 --repo EpicGames/unreal-engine-skills-for-claude-code-plugin \
    --json number,title,state,mergedAt,createdAt,updatedAt,baseRefName,headRefName,headRefOid,commits,additions,deletions,changedFiles,isDraft
$ gh pr view 9 --repo EpicGames/unreal-engine-skills-for-claude-code-plugin \
    --json files --jq '.files[] | {path, additions, deletions}'
```

Observed fields:

- `state: OPEN`, `isDraft: false`, `mergedAt: null`, `baseRefName: main`,
  `headRefName: docs/mcp-toolset-quirks`
- `createdAt: 2026-10-18T20:06:45Z`, `updatedAt: 2026-10-18T21:13:37Z`
- one commit `a5180ccd03c2813682a7fa19ca25ee9967bfe1de`, authored/committed
  `2026-10-18T21:13:26Z`, author `codingsh` / `developerfred`
- `changedFiles: 3`, `additions: 9`, `deletions: 2`
- files: `.claude-plugin/plugin.json` (+1/−1), `skills/unreal-mcp/SKILL.md`
  (+1/−1), `skills/unreal-mcp/references/operations.md` (+7/−0)

**[O]** Not on `main`. **[I]** `PROVENANCE.md` §8's r101 out-of-pin table (PRs 1
and 4, plus a history-only path) is a point-in-time record, not a claim that no
later PR can open. It does not mention #9. Freshness of the vendored pin is
unaffected. Whether #9 enters the corpus remains a future-round decision, same
rule as §8.

## 6. Queued citation defects (not repaired here)

These files are outside this seat's write chunk. Dated notes, not silent
rewrites, belong to their owners.

1. **`adaptation-kimi.md:446-447` liveness claim is false.** The C3 note says
   `/tmp/ue-skills-ref` is currently live and that
   `git -C /tmp/ue-skills-ref rev-parse HEAD` still returns the pin. Re-check:

   ```
   $ git -C /tmp/ue-skills-ref rev-parse HEAD
   fatal: cannot change to '/tmp/ue-skills-ref': No such file or directory
   exit=128
   $ df -h /tmp
   tmpfs  16G  13G  3.1G  80%  /tmp
   ```

   **[O]** at the manifest-check invocation (path missing) and again
   `df` at `2026-10-18T21:22:59Z`. Same contingency r104 recorded. The note's own
   recommendation — cite `corpus/knowledge/unreal-mcp/upstream/` — still holds
   (§4). `rg -c /tmp/ue-skills-ref` → `adaptation-kimi.md:10`, `PROVENANCE.md:9`,
   `README.md:3`. The README hits (lines 91–92, 273) and the PROVENANCE hits read
   as clone recipes / r101 historical method, not as a "currently live" claim.
   Only the adaptation C3 parenthetical asserts current liveness, and that
   assertion is false.

2. **`adaptation-kimi.md:486-503` describes a defect that the committed header no
   longer has.** That note says line 6 cites
   `https://github.com/EpicGames/unreal-engine-skills-for-claude-code` (404).
   Committed and worktree line 6 is the `-plugin` URL
   (`git diff --exit-code HEAD -- corpus/knowledge/unreal-mcp/adaptation-kimi.md`
   → `diff_exit=0`; `sed -n '6p'` shows the `-plugin` form). **[O]** The r101-era
   note should gain a dated correction that the header URL was repaired (r105
   work, present at `HEAD` `0cc3f41`); do not silently rewrite the original note.
   Residual display string, not a resolvable URL: the H1 on line 1 still omits
   `-plugin`. The no-suffix URL itself is still 404 (§3).

## 7. What this file does not claim

- "Fresh" means the pinned commit is still `main`'s tip and the vendored bytes
  equal that tip at the timestamps above. It is not a claim that the content is
  executable. Executability stays `unproven-runtime`.
- It does not assert upstream state after `2026-10-18T21:29:15Z`.
- `pushed_at` / `updated_at` are repo metadata. Branch-tip equality is the
  load-bearing observation.
- PR #9 is recorded, not reviewed for correctness, and not vendored.
