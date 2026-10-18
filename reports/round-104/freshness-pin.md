# r104 · SEAT-43 FRESHNESS-PIN — upstream `main` re-check

Round r104 · lane game-dev-3d-shokunin · written 2026-10-18.
Seat scope: re-run `git ls-remote <upstream-url> main` and decide whether the
pin `a6aa73ad…` is still the tip of `main`, or whether upstream has drifted.
Every claim carries the command that produced it and the verbatim output
observed on this host. Labels: **[O]** observed here, **[I]** inference.

Upstream URL (from `PROVENANCE.md` §1 **[O]**):
`https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin`
Pinned commit under test: `a6aa73ada02a9fb1f5415bec491f9942c519b297`.

Owned path: `reports/round-104/freshness-pin.md` (the only file this seat
wrote). Nothing under `corpus/` was written; `LOG.md`, `SCORECARD.md`,
`SHONEN.md`, `PROVINCE.md`, `SKILL.md`, `corpus/fixtures/**`,
`corpus/knowledge/unreal-mcp/upstream/**`,
`corpus/knowledge/unreal-mcp/.manifest.d/**`, `reports/round-101/**`,
`reports/round-102/**` and `reports/round-103/**` were not touched.

---

## 1. Verdict

**FRESH — no drift.** `main`'s tip is still `a6aa73ad…`, byte-for-byte equal to
the pin. Observed at `2026-10-18T19:17:14Z` **[O]**. No re-fetch, re-pin, or
decontamination is owed this round; the r102 and r103 freshness verdicts are
carried forward unchanged and are now re-confirmed at a later timestamp.

Four independent transports agree on the same SHA (git protocol `main`, the
`HEAD` symref, `--heads`, and the GitHub REST ref object), and a **fresh clone
made this round** re-derived the pin without reference to any earlier clone
(§3). This is not an artifact of one query path or one cached object store.

## 2. Primary command and corroborating transports

All blocks run in one session, same host. Timestamps bracket the run.

```
$ date -u +%Y-%m-%dT%H:%M:%SZ
2026-10-18T19:17:13Z
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin main
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main
exit=0
```

**[O]** One ref returned, SHA equals the pin exactly, `exit=0`. This is the
seat's primary command and it passes.

```
$ git ls-remote --symref https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin HEAD
ref: refs/heads/main	HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297	HEAD
exit=0

$ git ls-remote --heads https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main
exit=0

$ git ls-remote --tags https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
(no output)
exit=0
```

**[O]** `HEAD → refs/heads/main → a6aa73ad…`; `main` is still the only branch
head; upstream still publishes no tags, so `main`-tip remains the only freshness
signal that exists, and it is unchanged.

```
$ gh api repos/EpicGames/unreal-engine-skills-for-claude-code-plugin \
    --jq '{default_branch, pushed_at, updated_at, archived, private}'
{"archived":false,"default_branch":"main","private":false,
 "pushed_at":"2026-09-17T02:27:43Z","updated_at":"2026-10-18T19:08:16Z"}

$ gh api repos/EpicGames/unreal-engine-skills-for-claude-code-plugin/git/ref/heads/main \
    --jq '.object.sha'
a6aa73ada02a9fb1f5415bec491f9942c519b297
```

**[O]** `default_branch: main`, `archived: false`, `private: false`, and the
`main` ref object SHA equals the pin. `pushed_at` (`2026-09-17T02:27:43Z`) is
older than the pinned commit's committer date — the branch has received no
commit since the pinned one; the newer `updated_at` is repo metadata touched by
read traffic, not a branch push **[I]**.

```
$ date -u +%Y-%m-%dT%H:%M:%SZ
2026-10-18T19:17:14Z
```

**[O]** The four transports above were all issued inside a one-second window
(`19:17:13Z` → `19:17:14Z`), so they describe a single upstream state.

## 3. Fresh clone re-derives the pin — independent of any cached clone

The r101 reference clone `/tmp/ue-skills-ref` is **gone** (§4), so this seat made
its own clone rather than trusting a surviving one. A bare clone into a path on
the durable `/` filesystem:

```
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
```

**[O]** The freshly fetched commit is the pin, and its subject / author / dates
match `PROVENANCE.md` §1 exactly. So the pin is reproducible from the remote
today, not merely a surviving artifact.

## 4. The r101 reference clone is gone — a standing citation now falsified

The subtree's documented reference clone no longer exists:

```
$ git -C /tmp/ue-skills-ref rev-parse HEAD
fatal: cannot change to '/tmp/ue-skills-ref': No such file or directory
exit=128

$ df -h /tmp
Filesystem      Size  Used Avail Use% Mounted on
tmpfs            16G   13G  3.1G  80% /tmp
```

**[O]** `/tmp` is a 16G tmpfs at 80% and the r101 clone has been swept.

This is exactly the contingency `corpus/knowledge/unreal-mcp/adaptation-kimi.md`
C3 warned about. That note (line 446) reads:

> "They happen to be **currently live** (`/tmp/ue-skills-ref` still exists and
> `git -C /tmp/ue-skills-ref rev-parse HEAD` still returns the pin `a6aa73a…`)"

**[O]** — and that parenthetical is now **false**. The note's own recommended
substitute is the load-bearing path, and it holds: every §3.2/§3.3/§4.2 command
that cites `/tmp/ue-skills-ref` should be read against
`corpus/knowledge/unreal-mcp/upstream/` (§5 proves the substitution is sound).
Reported here, not repaired: `adaptation-kimi.md` is outside this seat's scope,
and the note's *conclusion* — "cite the vendored path, not `/tmp`" — is only
strengthened by the observation. **[I]** A future round owning that file may wish
to append a dated note recording that the `/tmp` clause has fired.

## 5. Vendored copy is byte-identical to live upstream — the strongest check

Freshness of the *pin* is separate from integrity of the *copy*. This round
checked both, and went one step further than the manifest: it diffed the
**live** upstream tree against the vendored bytes.

```
$ cd corpus/knowledge/unreal-mcp
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
exit=0
```

**[O]** 12/12 `OK`, `exit=0`.

```
$ git -C fresh.git archive HEAD | tar -x -C tree
$ diff -rq tree corpus/knowledge/unreal-mcp/upstream
(no output)
DIFF_EXIT=0
```

**[O]** The tree materialized from the freshly fetched upstream commit is
**byte-identical** to the vendored copy — no output, `exit=0`. Because the source
of that tree is a clone made this round at the live `main` tip, this is a
stronger statement than the manifest check alone: it ties the vendored bytes to
*upstream as it stands now*, not only to the r101 manifest.

Per-file git blobs from the fresh clone match `PROVENANCE.md` §2's table
(`git rev-parse HEAD:<path>`, 8-char prefix) **[O]**:

| # | path | blob | §2 says | # | path | blob | §2 says |
|---|---|---|---|---|---|---|---|
| 1 | `README.md` | `44c8dd3e` | `44c8dd3e` | 7 | `hooks/unreal-context.sh` | `8c06ba24` | `8c06ba24` |
| 2 | `LICENSE` | `4a38912a` | `4a38912a` | 8 | `skills/unreal-mcp/SKILL.md` | `9cd2cc26` | `9cd2cc26` |
| 3 | `CODEOWNERS` | `7ccb8b76` | `7ccb8b76` | 9 | `…/references/setup.md` | `49a921a9` | `49a921a9` |
| 4 | `.gitignore` | `aa5fae26` | `aa5fae26` | 10 | `…/references/operations.md` | `e02d8d0e` | `e02d8d0e` |
| 5 | `.claude-plugin/plugin.json` | `ba4e660a` | `ba4e660a` | 11 | `skills/create-toolset/SKILL.md` | `febf5d5a` | `febf5d5a` |
| 6 | `hooks/hooks.json` | `6be4b8b7` | `6be4b8b7` | 12 | `skills/unreal-skill/SKILL.md` | `a1513865` | `a1513865` |

**[O]** 12/12 blobs equal. The fresh clone tracks exactly 12 files
(`git ls-tree -r HEAD --name-only | wc -l` → `12`), matching §1's tracked-file
count — upstream has neither gained nor lost a tracked file since the pin.

## 6. Out-of-pin surface: still open, unchanged

```
$ gh pr list --repo EpicGames/unreal-engine-skills-for-claude-code-plugin \
    --state all --limit 20 --json number,title,state,mergedAt,headRefOid
#8 OPEN merged=null 1a3476f7 Add an OpenCode port
#5 OPEN merged=null c64c6097 Quote CLAUDE_PLUGIN_ROOT in SessionStart hook command
#4 OPEN merged=null 83807c0e feat: add marketplace manifest to enable local directory and fork installation
#2 OPEN merged=null 6dd839e9 Add Marketplace.json
#1 OPEN merged=null 435522c0 Add missing .claude-plugin/marketplace.json so the documented install paths work
```

**[O]** All five PRs remain `OPEN` with `mergedAt: null`, and their head SHAs are
unchanged from the r102 enumeration (`c64c6097`, `83807c0e`, `1a3476f7`,
`6dd839e9`, `435522c0`). None has landed on `main`, so the
`PROVENANCE.md` §8 out-of-pin surface is unchanged in status — still recorded,
not vendored. Whether any of it enters the corpus remains a future-round
decision, per §8.

## 7. Repository-URL form re-check (carried forward from r103)

The r103 note recorded that the no-suffix URL is a 404 and the real repository
name carries `-plugin`. Re-confirmed this round **[O]**:

```
$ curl -sIL --max-time 20 -o /dev/null -w '%{http_code}\n' \
    https://github.com/EpicGames/unreal-engine-skills-for-claude-code
404
$ curl -sIL --max-time 20 -o /dev/null -w '%{http_code}\n' \
    https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
200
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin main
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main
exit=0
```

**[O]** The `-plugin` form is the live repository and resolves to the pin; the
no-suffix form is still 404. `adaptation-kimi.md:6`'s one-token display defect is
unchanged and remains uncorrected (out of this seat's scope).

## 8. Freshness status per `PROVENANCE.md` §7

§7 (lines 336–338) states the pin is a moving target and that a later upstream
commit "would not invalidate this vendored copy, only its freshness." Applying
that rule to the observations above:

| question | answer | receipt |
|---|---|---|
| Has `main` moved since the r101 fetch? | **No** | §2 |
| Is `a6aa73ad…` still the tip of `main`? | **Yes** | §2, §3 |
| Does the vendored tree equal live upstream today? | **Yes, byte-identical** | §5 |
| Freshness status of the vendored copy | **FRESH — pin == tip** | §2–§5 |
| Re-fetch / re-pin action needed? | **None** | — |

**[O]** No staleness note is owed this round: the vendored tree is at the current
tip, so §7's "later upstream commit" contingency has not fired.

## 9. What this file does not claim

- No Unreal Editor, MCP endpoint, or engine binary was involved; this seat ran
  only remote-ref queries, a fresh clone, and local hash/diff checks. No runtime
  claim is made. The editor is not installed on this host, so live-MCP behavior
  stays `unproven-runtime`.
- "Fresh" here means *the pinned commit is still `main`'s tip and the vendored
  bytes equal live upstream* — it is not a claim that the vendored content is
  correct or executable; those verdicts live in `executability/` and the r101
  evidence layer.
- The `pushed_at` reading in §2 is repo-level metadata; the branch-tip equality
  in §2–§3 is the load-bearing observation, and every transport agrees.
- The fresh clone and extracted tree lived at
  `.r104seat43/` inside the work tree for the duration of this seat and were
  removed afterward; §3–§5 give the commands to reproduce them.
