# r107-pindelta — PIN-DELTA seat (round 107, 3D side-round)

**Plan (5 lines).**
1. Establish both endpoints: old pin `a6aa73ad` (r101, PROVENANCE.md §1) and the new pin fetched fresh this round.
2. Clone both to `/var/tmp/r107-pindelta/` (old = the r101 reference clone if it still matches the pin; new = fresh `git clone` of upstream `main`).
3. `git log --oneline old..new` + `git diff --stat` + `git diff` per file → commit/file/plugin-version delta table for PROVENANCE.md §2.
4. Verify the new pin is reproducible: `git ls-remote` agreement + independent second clone SHA; record 12-file tracked census at both pins.
5. Write the delta table + exact commands/outputs; label every claim [O]/[I]/[?]; UNPROVEN stays UNPROVEN.

**Verdict: THERE IS NO PIN DELTA.** Upstream `main` still resolves to
`a6aa73ada02a9fb1f5415bec491f9942c519b297` — byte-for-byte the r101 pin. The delta
table for PROVENANCE.md §2 is therefore an all-rows-`no-change` table (§3 below), and
the substantive delta this round lives **outside** the pin, in the open-PR surface (§4),
where two PRs appeared after r101.

All commands below were run on this host, 2026-10-19, from
`/var/tmp/r107-pindelta/` and the lane cwd. Labels: **[O]** observed here, **[I]**
inference, **[?]** unknown.

---

## 1. Endpoint identity

The r101 reference clone `/tmp/ue-skills-ref` **no longer exists** on this host
(`ls: cannot access '/tmp/ue-skills-ref': No such file or directory` **[O]**) — `/tmp` was
cleared between rounds. The r101 pin is therefore re-established from two surviving
records rather than from that clone:

| endpoint | sha | source | label |
|---|---|---|---|
| old (r101 pin) | `a6aa73ada02a9fb1f5415bec491f9942c519b297` | `corpus/knowledge/unreal-mcp/PROVENANCE.md` §1, §2 table | [O] |
| old (r101 pin, second record) | `a6aa73ada02a9fb1f5415bec491f9942c519b297` | `reports/round-101/r101-critic-c1.md` §0 | [O] |
| new (r107, fresh clone) | `a6aa73ada02a9fb1f5415bec491f9942c519b297` | `git clone` → `git rev-parse HEAD` | [O] |

```
$ git clone --quiet https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin new-pin
clone exit=0
$ git -C new-pin rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
$ git -C new-pin log -1 --format='%s | %an <%ae> | %ai | %ci'
[MCP] Permit safe concurrent tool calls | Thomas Mansencal <thomas.mansencal@epicgames.com> | 2026-09-17 13:19:50 +1200 | 2026-09-17 13:28:32 +1200
```

Commit subject, author, author date and committer date all match PROVENANCE §1's
recorded values exactly **[O]**. The pin is 53 commits deep (`git rev-list --count HEAD`
→ `53` **[O]**); no tag exists (`git tag -l` → empty **[O]**); the only remote branch is
`main` (`git branch -a` → `main`, `remotes/origin/main` **[O]**).

## 2. Commit delta — `a6aa73ad..main` is empty

```
$ git log --oneline a6aa73a..origin/main
(no output)
$ git rev-list --count a6aa73a..origin/main
0
```

Zero commits, zero file changes, zero version change **[O]**. Nine independent
transports agree on the pin:

| # | transport | command | observed | label |
|---|---|---|---|---|
| A | protocol v2 ref advertisement | `git ls-remote <url> main` | `a6aa73ad…` | [O] |
| B | fresh full clone | `git -C new-pin rev-parse HEAD` | `a6aa73ad…` | [O] |
| C | **independent seat clone** | `git -C /var/tmp/r107-va/repo rev-parse HEAD` | `a6aa73ad…` | [O] |
| D | REST commits API | `gh api repos/…/commits/main --jq .sha` | `a6aa73ad…` | [O] |
| E | REST git-refs API | `gh api repos/…/git/ref/heads/main --jq .object.sha` | `a6aa73ad…` | [O] |
| F | in-clone remote ref | `git -C new-pin ls-remote origin main` | `a6aa73ad…` | [O] |
| G | raw file host | `curl -sL …/main/.claude-plugin/plugin.json \| sha256sum` | `5aa98484…` (= pin blob) | [O] |
| H | codeload tarball | `curl -sL …/tar.gz/refs/heads/main` → extract → `sha256sum` | 12/12 hashes = pin | [O] |
| I | vendored tree object ids | `git hash-object` over `corpus/…/upstream/` | 12/12 = pin `git ls-tree` | [O] |

Transport C is a different seat's clone (`/var/tmp/r107-va/repo`, `meta.txt` →
`a6aa73ada02a9fb1f5415bec491f9942c519b297`, `2026-10-19T03:08:36Z`, branch `main` **[O]**), so the
agreement is not an artifact of one clone. Transport H is a **non-git** transport: the
GitHub-generated tarball of `main` (22 990 bytes, sha256
`d887155e1f967c87d58586a19d0fdde2a5dbbdcc330c8ac9b0896405ddd10ded`) extracted to a fresh
directory yields all 12 file hashes equal to the pin, and `diff -rq` against the fresh
clone is empty (exit 0) **[O]**. Transport I hashes the **vendored corpus copy** and
recovers the upstream git blob ids verbatim — i.e. the corpus still carries the pin's
content without needing a network round trip at all **[O]**.

## 3. Delta table for PROVENANCE.md §2 — old pin vs new pin

Byte-identity of the vendored tree, re-derived this round against a **fresh** clone of
`main`. `sha256` column is the r107 observation; the r101 column is transcribed from
PROVENANCE §2's per-file table for comparison. `git blob` is `git ls-tree -r HEAD`.

| # | path (relative to `upstream/`) | r101 sha256 (recorded) | r107 sha256 (fresh clone) | git blob | Δ |
|---|---|---|---|---|---|
| 1 | `README.md` | `483693ad…b40e` | `483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e` | `44c8dd3e` | none |
| 2 | `LICENSE` | `5b337be0…14a6` | `5b337be051359edcdec510103aee15f5f870efb38b6d42eecd685dc3582314a6` | `4a38912a` | none |
| 3 | `CODEOWNERS` | `653d3725…0f0f` | `653d372559bee26d75fcee330142276c7d9cbccba214ef008ff5392b99550f0f` | `7ccb8b76` | none |
| 4 | `.gitignore` | `0fad2f57…e538` | `0fad2f57a9fac18ab4a66ac23d44485544bdabb5057c99b684d485f27b81e538` | `aa5fae26` | none |
| 5 | `.claude-plugin/plugin.json` | `5aa98484…4d44` | `5aa984848f0fd48c94394651c66f5b200ee1e2583d8df8caeecc22bb550b4d44` | `ba4e660a` | none |
| 6 | `hooks/hooks.json` | `259124f0…dc0c` | `259124f0631b7d4b92e9e744003e8798b910c00dac201656b97906b3b5ebdc0c` | `6be4b8b7` | none |
| 7 | `hooks/unreal-context.sh` | `d3f1c871…1fdd` | `d3f1c871cd4edd5210ee2f448c403e1a441e569a14a1405d1a3f199c65651fdd` | `8c06ba24` | none |
| 8 | `skills/unreal-mcp/SKILL.md` | `7ef8b991…38fa` | `7ef8b991a82f591c5776bb5fa167c2bc2269fd00338ed3e8534eacc551d038fa` | `9cd2cc26` | none |
| 9 | `skills/unreal-mcp/references/setup.md` | `bd16206e…3b8a` | `bd16206ea142dc9cc1950b88af526a3137072ea152c5662e8549d21bc18a3b8a` | `49a921a9` | none |
| 10 | `skills/unreal-mcp/references/operations.md` | `dbed002b…3113` | `dbed002b4a46ab104274a31eb6682c3d277ce669216d0378df709f51567c3113` | `e02d8d0e` | none |
| 11 | `skills/create-toolset/SKILL.md` | `e9d05008…7b1c` | `e9d050087f36de51f7eeef49adb0ba9ebc603b65f74f475bc53a6debfc1f7b1c` | `febf5d5a` | none |
| 12 | `skills/unreal-skill/SKILL.md` | `7a0af781…5087` | `7a0af781c458c7d192d6b23c16b5737922dc482470e2e4ef617bcda80f435087` | `a1513865` | none |

**12/12 rows `none`.** Every `git blob` id also matches PROVENANCE §2's recorded
column **[O]**, and the whole sweep is reproduced by a single command:

```
$ diff -rq /var/tmp/r107-pindelta/new-pin corpus/knowledge/unreal-mcp/upstream --exclude=.git
diff exit=0
```

Other pin-level fields, old vs new:

| field | r101 | r107 | Δ |
|---|---|---|---|
| pinned commit | `a6aa73ad…b297` | `a6aa73ad…b297` | none |
| `refs/heads/main` | same | same | none |
| tracked files | 12 (all `100644`) | 12 (all `100644`) | none |
| plugin version | `3.1.1` | `3.1.1` | none |
| commit subject | `[MCP] Permit safe concurrent tool calls` | same | none |
| author date | 2026-09-17 13:19:50 +1200 | same | none |
| committer date | 2026-09-17 13:28:32 +1200 | same | none |
| history depth | not recorded | 53 commits | n/a |
| repo `pushed_at` | not recorded | `2026-09-17T02:27:43Z` | n/a |
| repo `updated_at` | not recorded | `2026-10-19T03:02:43Z` | n/a |
| open issues | not recorded | 9 | n/a |
| stars | not recorded | 1052 | n/a |
| archived / disabled | not recorded | `false` / `false` | n/a |
| releases | not recorded | none (`gh release list` empty) | n/a |

The `updated_at` stamp is *today* while `pushed_at` is the pin's day — that gap is the
signature of **PR activity, not of new commits to `main`** (§4) **[I]**.

**Consequence for PROVENANCE.md.** §1's pin row, §2's hash table and the plugin-version
row are all **still correct as written**; nothing in them needs to change. The only row
that should be refreshed is the **fetch date** (`2026-10-18` → `2026-10-19`), and even
that is a re-verification stamp, not a content change: re-fetching today returned the
same bytes. The freshness caveat in §7 ("the pin is a moving target upstream") stands
unchanged and was not exercised this round.

## 4. Where the real delta is: the out-of-pin PR surface

Upstream `main` did not move, but the repository did. Two PRs are **new since r101**:

```
$ gh pr list --repo EpicGames/unreal-engine-skills-for-claude-code-plugin --state all \
    --json number,state,title,headRefName,createdAt,updatedAt
```

| PR | state | title | head ref | created | updated | commits vs pin | files | lines |
|---|---|---|---|---|---|---|---|---|
| **9** | OPEN (`MERGEABLE`, `CLEAN`) | `[MCP] Document 5.8.3 toolset quirks, bump to 3.1.2` | `docs/mcp-toolset-quirks` | 2026-10-18T20:06:45Z | 2026-10-18T21:13:37Z | 1 | 3 | +9/−2 |
| **8** | OPEN | `Add an OpenCode port` | `feat/opencode-port` | 2026-10-18T17:34:13Z | 2026-10-18T17:34:13Z | 1 | 15 | +959/−10 |
| 5 | OPEN | `Quote CLAUDE_PLUGIN_ROOT in SessionStart hook command` | `fix/quote-hook-path` | 2026-09-30 | 2026-09-30 | 1 | 1 | +1/−1 |
| 4 | OPEN | `feat: add marketplace manifest …` | `main` | 2026-09-28 | 2026-09-28 | 2 | 6 | +361/−2 |
| 2 | OPEN | `Add Marketplace.json` | `add-marketplace` | 2026-07-20 | 2026-08-19 | 1 | 2 | +6/−6 |
| 1 | OPEN | `Add missing .claude-plugin/marketplace.json …` | `fix/add-marketplace-manifest` | 2026-06-27 | 2026-06-27 | 1 | 1 | +1/−1 |

Both new PRs are authored by **non-Epic contributors** and carry **one commit each on top
of the pin**, so neither is a rebase of existing upstream work **[O]**:

```
--- PR 8 ---  1a3476f7a1f3676c78f0153014c3e48b8b8a2a68
Add OpenCode port of the Unreal Engine skills plugin
chuma-beep <wisboynelson123@gmail.com> · 2026-10-18 18:33:58 +0100
--- PR 9 ---  a5180ccd03c2813682a7fa19ca25ee9967bfe1de
[MCP] Document 5.8.3 toolset quirks, bump to `3.1.2`
codingsh <codingsh@pm.me> · 2026-10-18 22:13:26 +0100
```

**Neither is merged.** `main` is unchanged, so the pin remains the freshest *released*
state and no re-vendor is triggered by these PRs. Their file-level deltas:

PR 9 (plugin `3.1.1` → `3.1.2`) — `.claude-plugin/plugin.json` (+1/−1),
`skills/unreal-mcp/SKILL.md` (`5a32f5f7…`, +1/−1), and
`skills/unreal-mcp/references/operations.md` (`4c6702f9…`, +7/−0, a new
`## Known toolset quirks` section). PR 8 leaves `plugin.json` at `3.1.1` and adds a
whole `opencode/` subtree (11 new files: `index.ts`, `project.ts`, `skills.ts`,
`package.json`, `README.md`, `scripts/sync-skills.mjs`, three `test/*.test.ts`,
`.gitignore`) plus edits to `README.md`, `setup.md`, `operations.md`,
`create-toolset/SKILL.md`, `unreal-skill/SKILL.md` **[O]**.

### 4a. r101's out-of-pin table: re-verified, and two rows are stale

PROVENANCE §8 recorded six out-of-pin artifacts with hashes "as recorded by that review,
each with its reproducing command **[I]**". I re-derived them from the PR refs. **Four
reproduce exactly; two rows are missing from r101's table entirely.**

| path | r101 recorded | r107 re-derived | verdict |
|---|---|---|---|
| `.claude-plugin/marketplace.json` (PR 1) | `390e7e9c…77d8`, 908 B | `390e7e9c9a4f21d7835541bb3b79ebb7afb5392d6ba0ce1e090b7a17ba6a77d8`, 908 B | **matches** [O] |
| `.github/workflows/ci.yml` (PR 4) | `4bac0081…c38d` | `4bac0081914d78f80be04c1776fe2244b53c6c4334116309f4ba5b83c04cc38d` | **matches** [O] |
| `hooks/unreal-context.ps1` (PR 4) | `eaf782fe…1c7f` | `eaf782fecd4430f0d04a50179742841eb5922c08162758b5de7cf7fc343f1c7f` | **matches** [O] |
| `tests/test_hooks.sh` (PR 4) | `35215587…a65` | `35215587a86fd593bb53c0c90ccbc7f7a13a5179744e9616ef9670be5e9caa65` | **matches** [O] |
| `tests/test_hooks.ps1` (PR 4) | `755befe2…6a8` | `755befe2e509ae3a3c384ded7fd7ace68b501611eb6d10dc1218b23d6f3c06a8` | **matches** [O] |
| `skills/unreal-mcp/references/toolsets.md` | blob `eaf2e838…`, 8306 B | `git cat-file -t` → `blob`; `-s` → `8306` | **matches** [O] |
| `.claude-plugin/marketplace.json` (PR 2) | *absent* | `1de11f5620043f9a3168da232d3dc0e9a736c45d5557564d9fa8e6542124551f`, 907 B | **new row** [O] |
| `hooks/hooks.json` (PR 5) | *absent* | `55b2e24c67cde000aab116e2b3a51c37674d465a6c5904080c5f4e1e104df27a` | **new row** [O] |
| `opencode/**` (11 files, PR 8) | *absent* | see `git ls-tree -r refs/remotes/pr/8` | **new row** [O] |
| PR 9's three files | *absent* | `5d6ea7b3…`, `5a32f5f7…`, `4c6702f9…` | **new row** [O] |

Two nuances worth recording. PR 4's `marketplace.json` is **byte-identical to PR 1's**
(`diff` → `IDENTICAL` **[O]**), so the two PRs are the same artifact by different routes —
PROVENANCE §8 should not count them twice. And PR 2's marketplace.json differs from
PR 1/PR 4's (907 B vs 908 B, different sha) **[O]**.

### 4b. Distribution-channel corroboration still holds, and is now stronger

PROVENANCE §8 records a second channel (`anthropics/claude-plugins-official`) whose
`source.sha` "independently corroborates the pin". Re-checked today, it still does:

```
$ gh api repos/anthropics/claude-plugins-official/contents/.claude-plugin/marketplace.json
  … "source": { "source": "url",
                "url": "https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin.git",
                "sha": "a6aa73ada02a9fb1f5415bec491f9942c519b297" } …
```

The vendor-agnostic marketplace pins the **same** SHA as our own clone **[O]** — a
seventh independent endpoint, and one operated by a different organization. That repo
was pushed `2026-10-18T17:04:56Z`, i.e. also during r101 **[O]**.

## 5. Intersection with this round's other seats

**PR 9 is about UE 5.8.3, and UE 5.8.3 is the docker image this round is pulling.**
PR 9's new section is titled *"Engine-side behaviours seen in UE 5.8.3 that look like tool
failures but are not"* and documents two quirks **[O]**:

- **Optional struct parameters cannot be omitted.** A parameter absent from the schema's
  `required` list can still fail with `input param "<name>" needs a default value`; pass
  an explicit `null`. Worked example given:
  `EditorToolset.EditorAppToolset.CaptureViewport` with
  `{"captureTransform": null, "annotations": null}`.
- **`SceneTools.take_screenshot` does not exist.** `SlateInspectorToolset.Screenshot`'s
  description tells you to use it for the 3D viewport; use
  `EditorToolset.EditorAppToolset.CaptureViewport` instead, and keep
  `SlateInspectorToolset.Screenshot` for Editor UI.

This lands directly on the r101 `executability/editor-general.md` card, which is labeled
`static-only` and whose §3.1 concludes that screenshots are the one Editor capability with
**"no shipped tool"**, derived from the pin's bytes where `screenshot` occurs exactly
twice and neither is an Editor tool **[O]**. PR 9's text asserts a shipped tool
(`CaptureViewport`) and a second one (`SlateInspectorToolset.Screenshot`) exists. Three
things follow, and they are **recorded, not adjudicated here**:

- The r101 card's conclusion is correct **about the pin** — its own command
  (`grep -rn -i "screenshot" …`) is a pinned-bytes search and PR 9 is out of pin **[I]**.
- PR 9 is **open and unmerged**, authored by a non-Epic contributor, so it is not
  upstream-vouched engine truth; it is a third-party claim **[I]**.
- The union — "a viewport capture tool may exist under `EditorToolset.EditorAppToolset`"
  — is a **testable prediction for the docker smoke probe** if that image unlocks. If the
  probe can enumerate toolsets, the single highest-value call this round is a
  `describe_toolset` / `list_toolsets` on `EditorAppToolset`. Until then it stays **[?]**.

`grep -rn '5\.8\.3' corpus/knowledge/unreal-mcp/` returns nothing **[O]**: the corpus
carries no 5.8.3-specific note today, so PR 9's quirk text has no counterpart there yet.

## 6. Docker unlock attempt — status (not this seat's artifact)

The orchestrator's UE image pull was already running when this seat started; I did not
start or stop it. Read-only observations **[O]**:

```
$ ps aux | grep '[d]ocker pull'
vgpnk 596299 … docker pull wukakuki/unreal-engine:dev-slim-5.8.3
$ tail -6 /var/tmp/ue-pull.log
e4b50e50cef4: Pull complete
36c02ffbf517: Pull complete
84bd5dd0f39b: Download complete
c62d70f5fb7b: Download complete
19b66c2667d8: Download complete
991ca4b0b8b2: Download complete
$ docker images | grep -i unreal
(empty)
```

At 2026-10-19T03:09Z the pull was **still in progress** (several layers `Download
complete` but not yet `Pull complete`; image not yet in `docker images`). **UNPROVEN
stays UNPROVEN**: no Unreal runtime claim is made or implied by this shard, and nothing
here depends on the pull finishing. Note the coincidence recorded above — the image tag
`5.8.3` is exactly the engine version PR 9's quirks note is about (§5) **[O]**.

## 7. What this shard does not claim

- No Unreal Editor, UnrealBuildTool or MCP tool call was made. Nothing here is runtime
  evidence; §5's tool-existence question is **[?]** and stays so.
- The PR refs I fetched (`refs/pull/N/head`) are **not** the pin and are not vendored;
  they are recorded as delta context for a future round to decide on.
- PR 8/PR 9 being `MERGEABLE`/`CLEAN` is GitHub's mergeability computation, not a
  statement that the changes are correct or desirable **[O]** for the status, **[?]** for
  their merit.
- `updated_at`/`pushed_at` are GitHub's own stamps and are **[O]** as returned; the
  reading "PR activity, not commits" is **[I]**.
- I did not re-verify PROVENANCE §5's three install receipts (R1–R3) — out of this
  seat's scope, and unchanged by a zero pin delta.

## 8. Reproduction block

```sh
# endpoints
git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin main
git clone --quiet https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin /var/tmp/r107-pindelta/new-pin
git -C /var/tmp/r107-pindelta/new-pin rev-parse HEAD    # a6aa73ada02a9fb1f5415bec491f9942c519b297

# zero commit delta
git -C /var/tmp/r107-pindelta/new-pin log --oneline a6aa73a..origin/main   # empty
git -C /var/tmp/r107-pindelta/new-pin diff -rq . /var/tmp/r107-pindelta/new-pin

# byte identity vs the vendored corpus
diff -rq /var/tmp/r107-pindelta/new-pin \
     corpus/knowledge/unreal-mcp/upstream --exclude=.git     # empty, exit 0

# non-git transport
curl -sL https://codeload.github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin/tar.gz/refs/heads/main \
  | tar -xz -C /var/tmp/r107-pindelta/tgz
find /var/tmp/r107-pindelta/tgz -type f | xargs sha256sum   # 12/12 == pin

# out-of-pin surface
git -C /var/tmp/r107-pindelta/new-pin fetch origin refs/pull/9/head:refs/remotes/pr/9
git -C /var/tmp/r107-pindelta/new-pin diff --stat a6aa73a refs/remotes/pr/9
gh pr list --repo EpicGames/unreal-engine-skills-for-claude-code-plugin --state all
```
