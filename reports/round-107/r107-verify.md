# r107-verify — 3-way byte verification (seat KEY=VERIFY-LEAD)

Round r107 (3D side-round) · lane `game-dev-3d-shokunin` · run 2026-10-19.
Artifacts: this shard + `reports/round-107/mutations/verify-manifest.json`.
Labels: **[O]** observed here, **[I]** inference, **[?]** unknown.

**Plan (5 lines).**
1. Resolve the remote pin independently: `git ls-remote <url> main` → transport R.
2. Fresh fetch A: `git clone` (https smart transport) into `/var/tmp/r107-verify/va`.
3. Fresh fetch B: independent transport — codeload tarball `curl` of the resolved SHA into `/var/tmp/r107-verify/vb` (no git protocol) + `gh api` commit corroboration.
4. Hash all 12 tracked files three ways (A worktree, B worktree, vendored `upstream/`) + git blob ids → table below → `verify-manifest.json`.
5. Count out-of-pin surface (PR-only paths) like PROVENANCE §8, re-derived from `ls-remote` + per-PR file lists.

---

## 0. Headline finding — the "fresh pin" equals the r101 pin

**[O]** The r107 re-vendor target resolved to the **same commit** as r101:

```
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin main
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main        exit 0
```

r101 `PROVENANCE.md` §1 records the identical `a6aa73ad…`. So the round's value
is an **independent re-derivation**, not a content delta. `pushed_at` on the repo
is `2026-09-17T02:27:43Z` **[O]** (`gh api repos/… --jq .pushed_at`), i.e. no
upstream push since the r101 pin date — consistent with the pin being unchanged.

| field | value | command |
|---|---|---|
| repo | `EpicGames/unreal-engine-skills-for-claude-code-plugin` | `gh api repos/… --jq .full_name` **[O]** |
| visibility / default branch | `public` / `main` | `gh api … --jq '{.visibility,.default_branch}'` **[O]** |
| license (API) | `MIT` | `gh api … --jq .license.spdx_id` **[O]** |
| pinned commit | `a6aa73ada02a9fb1f5415bec491f9942c519b297` | `git ls-remote … main` **[O]** |
| commit subject | `[MCP] Permit safe concurrent tool calls` (body: replace blanket parallel ban; bump plugin to `3.1.1`) | `gh api commits/<sha> --jq .commit.message` **[O]** |
| author / committer date | Thomas Mansencal / `2026-09-17T01:28:32Z` | `gh api … --jq .commit.author.name,.commit.committer.date` **[O]** |
| plugin version at pin | `3.1.1` | `jq -r .version va/.claude-plugin/plugin.json` **[O]** |
| tracked files | **12** (all mode `100644`; no symlinks/submodules/LFS) | `git -C va ls-files -s \| wc -l` **[O]** |

### Independent third-party corroboration of the pin

**[O]** The Anthropic official marketplace entry for this plugin carries the pin
in its `source.sha` — a channel *outside* Epic's repo agreeing on the commit:

```
$ curl -sSL https://raw.githubusercontent.com/anthropics/claude-plugins-official/main/.claude-plugin/marketplace.json \
  | python3 -c "…filter plugins for 'unreal'…"
{ "name": "unreal-engine-skills-for-claude-code",
  "author": {"name": "Epic Games"},
  "source": {"source": "url",
             "url": "https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin.git",
             "sha": "a6aa73ada02a9fb1f5415bec491f9942c519b297"},
  "homepage": "https://dev.epicgames.com/documentation/unreal-engine/unreal-mcp-in-unreal-editor" }
```

So three independent identities converge: remote ref (R), two local fetches
(A, B), and an external distribution channel. r101 §8 asserted this channel
existed **[I]**; r107 confirms it with the sha **[O]**.

---

## 1. Transport R — remote ref

**[O]** `git ls-remote <url>` full ref list, 2026-10-19:

| ref | sha |
|---|---|
| `HEAD` | `a6aa73ada02a9fb1f5415bec491f9942c519b297` |
| `refs/heads/main` | `a6aa73ada02a9fb1f5415bec491f9942c519b297` |
| `refs/pull/1/head` | `435522c0c66685049ac624fef04568ec313bebe7` |
| `refs/pull/1/merge` | `f425ff946c82cf602c754c69871bc23d233a0daa` |
| `refs/pull/2/head` | `6dd839e996900e226316b30a7fc00ee6f58a6772` |
| `refs/pull/2/merge` | `dba9b0161e01f948dba80f012ee934908170815a` |
| `refs/pull/4/head` | `83807c0ea52bef194537e8ccbe3028d4b9daedc9` |
| `refs/pull/4/merge` | `721993ece2ebcbadf711c05cfcc17857a4de02bc` |
| `refs/pull/5/head` | `c64c609745de466cecb184707ff5974fb9375339` |
| `refs/pull/5/merge` | `962126c7d5660f673c1375d32c92224a66738f09` |
| `refs/pull/8/head` | `1a3476f7a1f3676c78f0153014c3e48b8b8a2a68` |
| `refs/pull/8/merge` | `9f34125b1b44543c8b0b79ad39a12881134b8b06` |
| `refs/pull/9/head` | `a5180ccd03c2813682a7fa19ca25ee9967bfe1de` |
| `refs/pull/9/merge` | `3f35f9a6d4ae11fd031c61df4dbf98de5975a845` |

**[O]** One branch only (`main`); **no tags** advertised. Six open PRs
(1, 2, 4, 5, 8, 9). r101 §8 recorded only PRs 1 and 4, so its out-of-pin surface
is a **stale snapshot** — see §6.

## 2. Transport A — fresh `git clone` (https smart)

**[O]** `/var/tmp/r107-verify/va`, 2026-10-19:

```
$ git clone --quiet https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin va
exit 0
$ git -C va rev-parse HEAD                     → a6aa73ada02a9fb1f5415bec491f9942c519b297
$ git -C va rev-parse refs/remotes/origin/main → a6aa73ada02a9fb1f5415bec491f9942c519b297
$ git -C va ls-files | wc -l                   → 12
```

## 3. Transport B — codeload tarball (no git protocol)

**[O]** A *different* transport class — plain HTTPS object download, no git
wire protocol — so a protocol-layer fault in transport A cannot explain
agreement:

```
$ curl -sSL -o vb.tar.gz \
    "https://codeload.github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin/tar.gz/a6aa73ada02a9fb1f5415bec491f9942c519b297"
http_code=200 size=22990
$ sha256sum vb.tar.gz
d091941cc80bff11e3190c20611e6740680fde13daee0d00e9c6e659bd3618cf  vb.tar.gz
$ tar tzf vb.tar.gz | head -1
unreal-engine-skills-for-claude-code-plugin-a6aa73ada02a9fb1f5415bec491f9942c519b297/
$ find vb -type f | wc -l      → 12
```

**[O]** The tarball's **top-level directory name embeds the commit SHA**, so the
artifact self-identifies; and `gh api commits/<sha>` returns that same sha with
3 changed files — the commit that produced `3.1.1`. Tarball byte count 22990 is
smaller than the 3-file diff implies because codeload gzips a single tree
snapshot (no git objects/history).

## 4. Verification table — 12/12 byte-identical across A, B, and the vendored tree

**[O]** Three independent hash sweeps + git object ids. `shaA` = fresh clone A
worktree, `shaB` = codeload tarball B worktree, `shaVend` = already-vendored
`corpus/knowledge/unreal-mcp/upstream/`, `blob` = `git ls-files -s` object id.

| # | path (relative to upstream root) | bytes | shaA == shaB | shaA == shaVend | git blob |
|---|---|---|---|---|---|
| 1 | `.claude-plugin/plugin.json` | 487 | ✓ | ✓ | `ba4e660a` |
| 2 | `.gitignore` | 203 | ✓ | ✓ | `aa5fae26` |
| 3 | `CODEOWNERS` | 64 | ✓ | ✓ | `7ccb8b76` |
| 4 | `LICENSE` | 1073 | ✓ | ✓ | `4a38912a` |
| 5 | `README.md` | 8398 | ✓ | ✓ | `44c8dd3e` |
| 6 | `hooks/hooks.json` | 357 | ✓ | ✓ | `6be4b8b7` |
| 7 | `hooks/unreal-context.sh` | 3101 | ✓ | ✓ | `8c06ba24` |
| 8 | `skills/create-toolset/SKILL.md` | 23258 | ✓ | ✓ | `febf5d5a` |
| 9 | `skills/unreal-mcp/SKILL.md` | 7098 | ✓ | ✓ | `9cd2cc26` |
| 10 | `skills/unreal-mcp/references/operations.md` | 6497 | ✓ | ✓ | `e02d8d0e` |
| 11 | `skills/unreal-mcp/references/setup.md` | 6065 | ✓ | ✓ | `49a921a9` |
| 12 | `skills/unreal-skill/SKILL.md` | 6955 | ✓ | ✓ | `a1513865` |

Full sha256 values are in `mutations/verify-manifest.json` (`files[].shaA`,
`shaB`, `shaVendored`, `git_blob`, plus `shaA_eq_shaB` / `shaA_eq_vendored`
booleans and a top-level `all_12_byte_identical: true`). The 12 shaA values
match r101's `PROVENANCE.md` §2 per-file table **and**
`.manifest.d/audit-reference.sha256` exactly **[O]** — the r101 record was not
drifting.

**Whole-tree corroboration (stronger than per-file, catches stray/extra files):**

```
$ diff -rq va <vb-tarball-root> --exclude=.git          → (no output) exit 0
$ diff -rq corpus/knowledge/unreal-mcp/upstream va --exclude=.git  → (no output) exit 0
$ diff -rq corpus/knowledge/unreal-mcp/upstream <vb-root>          → (no output) exit 0
```

**[O]** Exit 0 with no output means no differing *and no extra* files in either
direction — so B carries nothing A lacks (the tarball excludes `.git`, which is
why `--exclude=.git` appears in the A comparison only).

**Vendored-tree re-check from inside the subtree:**

```
$ cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256
upstream/.claude-plugin/plugin.json: OK
… (12 lines, all OK) …
   exit 0
```

**[O]** 12× OK, exit 0. (Note: the manifest paths are relative to
`corpus/knowledge/unreal-mcp/`, **not** the repo root — running it from the root
fails with `No such file or directory` for all 12. Worth a one-line usage note in
the landed copy.)

### Transport D — tree SHA (identity above the file level)

**[O]** A fourth, coarser identity check: the git **tree** object that commits the
whole 12-file snapshot. It matches across the clone, the tarball, and GitHub's API:

```
$ git -C va rev-parse HEAD^{tree}
b5b9624b00fc90217240e823406699d0ab78b959
$ gh api repos/EpicGames/unreal-engine-skills-for-claude-code-plugin/commits/a6aa73ad… --jq .commit.tree.sha
b5b9624b00fc90217240e823406699d0ab78b959
$ (VENDOR-B, reconstructing a tree from the extracted tarball) git write-tree
b5b9624b00fc90217240e823406699d0ab78b959
```

**[I]** Tree-SHA agreement is stronger than per-file agreement in one respect:
it is a single object covering *exactly* the 12 paths and their modes, so a
missing or extra file would break it. It is weaker in another: it does not prove
the file *bytes* hash the way sha256 does, so both checks are kept.

### Negative control — the check can fail

**[O]** A verification that cannot fail proves nothing. Corrupting one byte is
detected:

```
$ cp -a va negctl && printf 'X' >> negctl/LICENSE
$ cd negctl && sha256sum -c <12-line manifest, upstream/ prefix stripped>
LICENSE: FAILED
sha256sum: WARNING: 1 computed checksum did NOT match        exit 1
```

So the 12× `OK` above is a real pass, not a vacuous one.

### Verdict

**[O]** 12/12 tracked files are byte-identical across fresh-A, fresh-B, and the
vendored tree; the remote ref, both fetches, an external distribution channel, and
the tree object all name the same commit; the check is falsifiable. **The
re-vendored tree is verifiably identical to `a6aa73ad`, so the r107 re-vendor is a
no-op on content** — the round proves reproducibility, not change.

### Cross-seat agreement (independent manifests, machine-compared)

**[O]** Three seats produced manifests without reading each other's values. I
compared them programmatically (path × sha256 × git-blob):

```
12 paths × (sha256, git-blob[:8]) across VERIFY-LEAD + VENDOR-A + VENDOR-B:
ALL AGREE = True
```

| sibling seat | its independent claim | my re-derivation | verdict |
|---|---|---|---|
| `r107-VENDOR-A.md` | pin `a6aa73ad…`, 12 paths, all `100644` | same | **AGREE** [O] |
| `r107-VENDOR-A.md` | sha256 column, all 12 | identical to mine | **AGREE** [O] |
| `r107-VENDOR-A.md` | **size column** | **contradicted** — see below | **DISAGREE** [O] |
| `r107-VENDOR-B.md` | tarball transport, 12/12, tree sha | same; tarball sha256 `d091941c…` identical | **AGREE** [O] |
| `r107-verify2.md` | transports A/B/C, own manifests | same three transports, same result | **AGREE** [O] |
| `r107-rev-pin.md` | pin confirmed by 4 transports, 12/12, both manifest families green | reproduced; `audit-reference` 12× OK exit 0 | **AGREE** [O] |

**Confirmed sibling defect — VENDOR-A markdown size column [O].** VENDOR-A's shard
table records `.claude-plugin/plugin.json` = `178`, `LICENSE` = `11357`,
`README.md` = `7085`. Ground truth from a fresh clone:

```
$ cd /var/tmp/r107-verify/va && stat -c%s LICENSE README.md .claude-plugin/plugin.json
1073
8398
487
```

The correct values (1073 / 8398 / 487) also appear in PROVENANCE §2, in
`audit-reference.sha256`'s companion data, and in **VENDOR-A's own
`mutations/va-manifest.json`** (`size_bytes` = 1073 / 8398 / 487). **[I]** So the
defect is confined to VENDOR-A's *prose table*; its JSON, hashes, and pin are
correct. Recommended action: the orchestrator should not propagate VENDOR-A's
size column into PROVENANCE §2; PROVENANCE §2's existing sizes are right.

---

## 5. What this seat does NOT prove

- No Unreal Editor / UnrealBuildTool / MCP tool call was run. Byte-identity
  proves *the files*; it says nothing about engine behavior. Runtime stays
  **UNPROVEN** (see `r107-unlock.md` for the attempt log).
- Hash agreement proves content identity, **not** provenance of the commit's
  authorship or license beyond what §0 records (`gh api` license field + the
  vendored MIT `LICENSE` text). The rights analysis stays r101
  `probes/license-audit.md`.
- The pin is a moving target upstream: `main` agreed at 2026-10-19T00:08Z **[O]**;
  a later upstream commit would not invalidate these copies, only their freshness.

## 6. Out-of-pin surface (PROVENANCE §8 re-derivation)

**[O]** Six open PRs, re-derived from `refs/pull/*/head` + per-PR file lists.
15 distinct paths exist **outside** the pin. Hashes below are computed from each
PR's codeload tarball (new this round; r101 §8 had only 6 rows and no reproducible
command for most).

| PR | state | path | bytes | sha256 |
|---|---|---|---|---|
| 1 | open | `.claude-plugin/marketplace.json` | 908 | `390e7e9c9a4f21d7835541bb3b79ebb7afb5392d6ba0ce1e090b7a17ba6a77d8` |
| 4 | open | `.github/workflows/ci.yml` | 1116 | `4bac0081914d78f80be04c1776fe2244b53c6c4334116309f4ba5b83c04cc38d` |
| 4 | open | `hooks/unreal-context.ps1` | 3322 | `eaf782fecd4430f0d04a50179742841eb5922c08162758b5de7cf7fc343f1c7f` |
| 4 | open | `tests/test_hooks.ps1` | 3796 | `755befe2e509ae3a3c384ded7fd7ace68b501611eb6d10dc1218b23d6f3c06a8` |
| 4 | open | `tests/test_hooks.sh` | 2778 | `35215587a86fd593bb53c0c90ccbc7f7a13a5179744e9616ef9670be5e9caa65` |
| 8 | open | `opencode/.gitignore` | 82 | `c418e00935c8785c78b15adb0a14a0d502b98200429924c05f44bade627c120a` |
| 8 | open | `opencode/README.md` | 8466 | `5f36bc34d24772de51c2ed5d6e564d38b65ff9c6506bf96828eb6c63162e6776` |
| 8 | open | `opencode/index.ts` | 3640 | `82341c50550781285a0fdd925f4c8f515d586511885d49ffc2171386f95f6e3f` |
| 8 | open | `opencode/package.json` | 691 | `7142423866e0f8805fcefbae5272167b6e9146cc33706f0fa1ba562fad41f912` |
| 8 | open | `opencode/project.ts` | 3294 | `579bdfd134254d1e8ac057bda3b8f4b596ae6c8ea5f78320f4b4d60f516a781e` |
| 8 | open | `opencode/scripts/sync-skills.mjs` | 652 | `eed3bc9ea80069325272d8069461163b08c9f0d703d6e429797672fd338c2191` |
| 8 | open | `opencode/skills.ts` | 2820 | `8c0762021c04a7e3cabf7109ce11cf38f5340c61ad0382cfdace9e33a90b255c` |
| 8 | open | `opencode/test/plugin.test.ts` | 4729 | `5ae1bcf8f26b9b45e1523363aed3635c886e37df67d39e75b3ad7e0d2284e626` |
| 8 | open | `opencode/test/project.test.ts` | 3340 | `b14d519a210125e6f619bf8a31b553707ac3909bbf75ba06958d695fb95e614f` |
| 8 | open | `opencode/test/skills.test.ts` | 2981 | `1e9a4ac508fb13d6f99d41c5a32ea9e6c1c66a89dce7b30efe392c385791abf9` |

Reproduce:

```sh
for pr in 1 2 4 5 8 9; do
  sha=$(gh api repos/EpicGames/unreal-engine-skills-for-claude-code-plugin/pulls/$pr --jq .head.sha)
  curl -sSL -o /var/tmp/pr$pr.tar.gz \
    "https://codeload.github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin/tar.gz/$sha"
done
```

### r101 §8 hash reproduction — and why the list was incomplete

**[O]** The two §8 hashes that *were* recorded still reproduce bit-for-bit
against PR-4's head `83807c0e`:

```
$ curl -sSL https://raw.githubusercontent.com/…/83807c0ea52bef194537e8ccbe3028d4b9daedc9/.claude-plugin/marketplace.json | sha256sum
390e7e9c9a4f21d7835541bb3b79ebb7afb5392d6ba0ce1e090b7a17ba6a77d8   # matches §8
$ curl -sSL https://raw.githubusercontent.com/…/83807c0ea52bef194537e8ccbe3028d4b9daedc9/hooks/unreal-context.ps1 | sha256sum
eaf782fecd4430f0d04a50179742841eb5922c08162758b5de7cf7fc343f1c7f   # matches §8
```

So §8 was **accurate for the PRs it looked at, but not exhaustive**: it missed
PRs 2, 5, 8, 9 entirely. Concrete drift:

- **PR 2** also adds `.claude-plugin/marketplace.json` (a competing duplicate of
  PR 1's file, same 21-line content) — §8 lists only PR 1.
- **PR 5** modifies `hooks/hooks.json` (1+/1−, quote `CLAUDE_PLUGIN_ROOT`) — an
  in-pin file changed by an open PR; §8 does not record modified-in-PR files.
- **PR 8** ("Add an OpenCode port") adds a whole `opencode/` subtree (10 files)
  and edits 4 in-pin skills — the largest out-of-pin surface, absent from §8.
- **PR 9** (`[MCP] Document 5.8.3 toolset quirks, bump to 3.1.2`) bumps
  `plugin.json` to **3.1.2** and edits `unreal-mcp/SKILL.md` +
  `operations.md` — a version ahead of the pin, absent from §8.

**[O]** PR tracked-file counts (in-pin baseline is 12): PR1 → 13, PR2 → 13,
PR4 → 17, PR5 → 12, PR8 → 22, PR9 → 12. PRs 5 and 9 change content without
changing the count — the case per-file hashing catches and a count check misses.

**[I]** Recommended r107 §8 wording: the pin's 12/12 is closed and verified; the
**out-of-pin surface is 15 paths across 6 open PRs**, with PR 9 (v3.1.2) the one
that will move the pin if merged. None of it is vendored this round.
`mutations/verify-manifest.json` carries the machine-readable copy.

## 7. Environment / limits

**[O]** `gh 2.102.0`, Docker 29.7.2 (overlayfs, root `/var/lib/docker`), repo
`pushed_at 2026-09-17T02:27:43Z`, 1052 stars, repo size 97 KB. All fetches ran
2026-10-19 from `/var/tmp/r107-verify/`; scratch is outside the lane tree per the
hard rules. No writes to `corpus/` — drafts/shard only.

**[?]** The background `docker pull wukakuki/unreal-engine:dev-slim-5.8.3` was
still running at this seat's close (no `unreal-engine` image present); the UE
runtime verdict belongs to `r107-unlock.md`, not here.
