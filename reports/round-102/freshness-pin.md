# r102 · SEAT-59 FRESHNESS-PIN — upstream `main` re-check

Round r102 · lane game-dev-3d-shokunin · written 2026-10-18.
Seat scope: re-run `git ls-remote <upstream-url> main` and decide whether the
r101 pin `a6aa73ad…` is still the tip of `main`, or whether upstream has moved.
Every claim carries the command that produced it and the verbatim output
observed on this host. Labels: **[O]** observed here, **[I]** inference.

Upstream URL (from `PROVENANCE.md` §1 **[O]**):
`https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin`
Pinned commit under test: `a6aa73ada02a9fb1f5415bec491f9942c519b297`.

---

## 1. Verdict

**The pin is still the tip of `main`. Upstream has NOT moved.** The vendored
copy in `corpus/knowledge/unreal-mcp/upstream/` is **fresh** as of
`2026-10-18T17:41:23Z` **[O]** — no re-fetch, re-pin, or decontamination is
required this round.

Three independent transports agree on the same SHA (git protocol, GitHub REST
API, and the HEAD symref), so this is not an artifact of one query path.

## 2. Observed refs (verbatim)

### 2.1 `git ls-remote <url> main` — the seat's primary command

```
$ date -u +%Y-%m-%dT%H:%M:%SZ
2026-10-18T17:41:23Z
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin main
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main
   exit=0
```

**[O]** Single ref returned, SHA equals the pin. `exit=0`.

### 2.2 All branch heads — is `main` alone, or has another branch appeared?

```
$ git ls-remote --heads https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main
   exit=0
```

**[O]** `main` is the only branch; no new branch head exists.

### 2.3 HEAD symref — confirms the default branch still resolves to the pin

```
$ git ls-remote --symref https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin HEAD
ref: refs/heads/main	HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297	HEAD
   exit=0
```

**[O]** `HEAD → refs/heads/main → a6aa73ad…`; default branch unchanged.

### 2.4 GitHub REST API corroboration

```
$ gh api repos/EpicGames/unreal-engine-skills-for-claude-code-plugin \
    --jq '{default_branch, pushed_at, updated_at, archived, private}'
{"archived":false,"default_branch":"main","private":false,
 "pushed_at":"2026-09-17T02:27:43Z","updated_at":"2026-10-18T17:38:27Z"}

$ gh api repos/EpicGames/unreal-engine-skills-for-claude-code-plugin/git/ref/heads/main \
    --jq '.object.sha'
a6aa73ada02a9fb1f5415bec491f9942c519b297
```

**[O]** API reports `default_branch: main`, `archived: false`, `private: false`,
and the `main` ref object SHA equals the pin. Note `pushed_at`
(`2026-09-17T02:27:43Z`) is older than the r101 fetch date — the branch has
received no commit since the pinned one; the newer `updated_at` is repo metadata
touched by read traffic, not a branch push **[I]**.

### 2.5 No tags

```
$ git ls-remote --tags https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
(no output)
   exit=0
```

**[O]** Upstream publishes no tags, so `main`-tip is the only freshness signal
that exists; it is unchanged.

## 3. Vendored copy still matches the pin

Freshness of the *pin* is separate from integrity of the *copy*; both were
re-checked so the "fresh" verdict covers the bytes actually vendored.

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

**[O]** 12/12 `OK`, `exit=0`. The 12 vendored files remain byte-identical to the
manifest recorded at the pin, and the pin is still `main`'s tip (§2) — so the
copy is fresh, not merely intact.

## 4. Freshness status per `PROVENANCE.md` §7

`PROVENANCE.md` §7 (line 336–338) states the pin is a moving target and that a
later upstream commit "would not invalidate this vendored copy, only its
freshness." Applying that rule to the observation above:

| question | answer | receipt |
|---|---|---|
| Has `main` moved since the r101 fetch? | **No** | §2.1, §2.4 |
| Is `a6aa73ad…` still the tip of `main`? | **Yes** | §2.1–§2.4 |
| Freshness status of the vendored copy | **FRESH — pin == tip** | §2 + §3 |
| Re-fetch / re-pin action needed? | **None** | — |

**[O]** No staleness note is owed this round: the vendored tree is at the current
tip, so `PROVENANCE.md` §7's "later upstream commit" contingency has not fired.

## 5. Out-of-pin surface: still open, unchanged

The unmerged contribution surface recorded in `PROVENANCE.md` §8 was
re-enumerated so the freshness picture is complete **[O]**:

```
$ gh pr list --repo EpicGames/unreal-engine-skills-for-claude-code-plugin \
    --state all --limit 20 --json number,title,state,mergedAt,headRefOid
#5 OPEN  Quote CLAUDE_PLUGIN_ROOT in SessionStart hook command   c64c6097…
#4 OPEN  feat: add marketplace manifest …                        83807c0e…
#8 OPEN  Add an OpenCode port                                    1a3476f7…
#2 OPEN  Add Marketplace.json                                    6dd839e9…
#1 OPEN  Add missing .claude-plugin/marketplace.json …           435522c0…
```

**[O]** All five PRs remain `OPEN` with `mergedAt: null`; none has landed on
`main`, so the §8 out-of-pin surface is unchanged in status (still recorded, not
vendored). PR #8 (`Add an OpenCode port`) is the only item not named in §8's
table — a newly observed open PR, not a change to the pin **[O]**. Whether it
enters the corpus remains a future-round decision, per §8.

## 6. What this file does not claim

- No Unreal Editor, MCP endpoint, or engine binary was involved; this seat ran
  only remote-ref queries and a local hash check. No runtime claim is made.
- "Fresh" here means *the pinned commit is still `main`'s tip* — it is not a
  claim that the vendored content is correct or executable; those verdicts live
  in `executability/` and the r101 evidence layer.
- The `pushed_at` reading in §2.4 is repo-level metadata; the branch-tip equality
  in §2.1–§2.3 is the load-bearing observation, and all four agree.
