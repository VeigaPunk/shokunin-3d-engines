# PROVENANCE — vendored `unreal-engine-skills-for-claude-code-plugin`

Round r101 · lane game-dev-3d-shokunin · seat SEAT-12 WRITER.
Written 2026-10-18. Every claim below carries the command that produced it and
the output observed on this host. Labels: **[O]** observed here, **[I]**
inference, **[?]** unknown.

This file is the authoritative record of *where the content in this subtree came
from* and *why it may be redistributed here*. It asserts nothing about Unreal
Engine behavior; see `README.md` in this directory for the verification policy
and `executability/` for the per-subsystem verdicts.

---

## 1. Upstream identity and pin

| field | value | how it was obtained |
|---|---|---|
| repository | `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin` | `git -C /tmp/ue-skills-ref remote -v` **[O]** |
| visibility | public, `private: false` | `gh api repos/…` **[O]** |
| default branch | `main` | `gh api … --jq .default_branch` **[O]** |
| pinned commit | `a6aa73ada02a9fb1f5415bec491f9942c519b297` | `git -C /tmp/ue-skills-ref rev-parse HEAD` **[O]** |
| remote agrees on the pin | yes — `a6aa73ada02a9fb1f5415bec491f9942c519b297  refs/heads/main` | `git ls-remote <url> main` **[O]** |
| commit subject | `[MCP] Permit safe concurrent tool calls` | `git log -1 --format=%s` **[O]** |
| author / date | Thomas Mansencal `thomas.mansencal@epicgames.com`, 2026-09-17 13:19:50 +1200 | `git log -1 --format='%an %ai'` **[O]** |
| committer date | 2026-09-17 13:28:32 +1200 | `git log -1 --format=%ci` **[O]** |
| plugin version | `3.1.1` | `jq -r .version upstream/.claude-plugin/plugin.json` **[O]** |
| **fetch date** | **2026-10-18** | this seat's clone/verify run, `2026-10-18T17:17:31Z` **[O]** |
| tracked files | **12** (all mode `100644`; no symlinks, no submodules, no LFS) | `git -C /tmp/ue-skills-ref ls-files -s \| wc -l` **[O]** |

Reference clone used by this seat: `/tmp/ue-skills-ref`, re-verified against the
pin before any read (pre-existing clone matched the pin, so no fresh clone was
needed):

```
$ git -C /tmp/ue-skills-ref rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
```

An independent fresh clone produced by SEAT-15 at `/tmp/r101-audit` reports the
same SHA **[O]**, so the pin is not an artifact of one clone.

## 2. Byte-identity of the vendored tree

Two independent checks, both run from `corpus/knowledge/unreal-mcp/`:

```
$ diff -rq /tmp/ue-skills-ref corpus/knowledge/unreal-mcp/upstream --exclude=.git
(no output)   exit 0

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
   exit 0
```

`sha256sum -c .manifest.d/seat*.sha256` likewise prints `OK` for all 12 paths and
exits `0` **[O]**. The vendored copy is therefore byte-identical to the pinned
upstream commit, and the per-seat manifests and the 12/12 audit reference agree.

### Per-file hash table

`git-blob` is the upstream object id (`git ls-tree`), kept so a future round can
re-check content against the object store without a working tree.

| # | path (relative to this directory) | bytes | lines | sha256 | git blob |
|---|---|---|---|---|---|
| 1 | `upstream/README.md` | 8398 | 112 | `483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e` | `44c8dd3e` |
| 2 | `upstream/LICENSE` | 1073 | 21 | `5b337be051359edcdec510103aee15f5f870efb38b6d42eecd685dc3582314a6` | `4a38912a` |
| 3 | `upstream/CODEOWNERS` | 64 | 2 | `653d372559bee26d75fcee330142276c7d9cbccba214ef008ff5392b99550f0f` | `7ccb8b76` |
| 4 | `upstream/.gitignore` | 203 | 4 | `0fad2f57a9fac18ab4a66ac23d44485544bdabb5057c99b684d485f27b81e538` | `aa5fae26` |
| 5 | `upstream/.claude-plugin/plugin.json` | 487 | 10 | `5aa984848f0fd48c94394651c66f5b200ee1e2583d8df8caeecc22bb550b4d44` | `ba4e660a` |
| 6 | `upstream/hooks/hooks.json` | 357 | 17 | `259124f0631b7d4b92e9e744003e8798b910c00dac201656b97906b3b5ebdc0c` | `6be4b8b7` |
| 7 | `upstream/hooks/unreal-context.sh` | 3101 | 84 | `d3f1c871cd4edd5210ee2f448c403e1a441e569a14a1405d1a3f199c65651fdd` | `8c06ba24` |
| 8 | `upstream/skills/unreal-mcp/SKILL.md` | 7098 | 56 | `7ef8b991a82f591c5776bb5fa167c2bc2269fd00338ed3e8534eacc551d038fa` | `9cd2cc26` |
| 9 | `upstream/skills/unreal-mcp/references/setup.md` | 6065 | 133 | `bd16206ea142dc9cc1950b88af526a3137072ea152c5662e8549d21bc18a3b8a` | `49a921a9` |
| 10 | `upstream/skills/unreal-mcp/references/operations.md` | 6497 | 51 | `dbed002b4a46ab104274a31eb6682c3d277ce669216d0378df709f51567c3113` | `e02d8d0e` |
| 11 | `upstream/skills/create-toolset/SKILL.md` | 23258 | 420 | `e9d050087f36de51f7eeef49adb0ba9ebc603b65f74f475bc53a6debfc1f7b1c` | `febf5d5a` |
| 12 | `upstream/skills/unreal-skill/SKILL.md` | 6955 | 112 | `7a0af781c458c7d192d6b23c16b5737922dc482470e2e4ef617bcda80f435087` | `a1513865` |

Reproduce the pin and the whole sweep in one block:

```sh
git clone https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin /tmp/ue-skills-ref
git -C /tmp/ue-skills-ref rev-parse HEAD    # expect a6aa73ada02a9fb1f5415bec491f9942c519b297
cd corpus/knowledge/unreal-mcp
sha256sum -c .manifest.d/audit-reference.sha256   # expect 12× OK, exit 0
diff -rq /tmp/ue-skills-ref upstream --exclude=.git   # expect no output, exit 0
```

### Brief-vs-observed: 11 paths vs 12 files

The round brief says "all upstream content files … (11 upstream paths)". Upstream
actually tracks **12** files. The split is **11 vendoring seats**: `seat01`–`seat10`
each hold one file, and `seat11` holds two (`upstream/CODEOWNERS` +
`upstream/.gitignore`) — visible in
`wc -l corpus/knowledge/unreal-mcp/.manifest.d/seat11.sha256` → `2` **[O]**, while
`seat01`–`seat10` are 1 line each **[O]**. So "11" is the seat count and "12" is
the file count; both are correct about different things, and this file records
all 12.

## 3. License and vendoring rights

| field | value | receipt |
|---|---|---|
| **LICENSE file name** | **`LICENSE`** (no extension) at `upstream/LICENSE` | `find upstream -maxdepth 1 -name 'LICENSE*'` → `upstream/LICENSE` **[O]** |
| license | **MIT License**, `Copyright (c) 2026 Epic Games, Inc.` | `head -3 upstream/LICENSE` **[O]** |
| size / sha256 | 1073 bytes / `5b337be051359edcdec510103aee15f5f870efb38b6d42eecd685dc3582314a6` | `sha256sum upstream/LICENSE` **[O]** |
| corroboration | `"license": "MIT"` in `upstream/.claude-plugin/plugin.json`; GitHub API reports `license: MIT` | `jq -r .license upstream/.claude-plugin/plugin.json`; `gh api repos/… --jq .license.spdx_id` **[O]** |
| other terms in the tree | none — no `NOTICE`, no `COPYING`, no third-party dir, no per-file SPDX header | sweep recorded in the license audit below |

**Vendoring-rights pointer:** the operative MIT grant, the notice-retention
condition, and the verdict that vendoring these copies into this corpus is
**PERMITTED** are established in
[`reports/round-101/probes/license-audit.md`](../../../reports/round-101/probes/license-audit.md)
(SEAT-28 PROBE) — specifically its §1 (identification), §2 (quoted clause with
line numbers), and §3 (verdict, incl. the scope caveat that MIT covers only the
plugin repo's own files and does **not** extend to Unreal Engine itself, which is
under Epic's separate EULA and is not vendored here). That audit is the
authoritative rights analysis; this section only records the file name and hash.

Consequence recorded, not asserted: because `upstream/LICENSE` is itself vendored
byte-identically, the copyright and permission notices travel with the copies
rather than being stripped.

## 4. Operator install directive

Standing directive this round operates under, quoted with location:

> "Installing new engines/tooling is allowed only within a declared round scope
> with operator-visible setup receipts; setup never silently installs unrelated
> software."
> — `PROVINCE.md:42-44` **[O]**

Supporting context for *why Unreal is in scope at all*: the lane is engine-neutral
by operator directive — "Godot, Unity, Unreal Engine, three.js, and any further 3D
rendering tooling the lane discovers and validates on its shonen path"
(`corpus/README.md:9-11`) **[O]**.

The directive permits a scoped install attempt; it does not waive the receipts
requirement. This seat attempted no install — it re-derived the three receipts
below so the round's install status is recorded in the corpus rather than only in
a report.

## 5. The three install receipts

All three were re-run by this seat on 2026-10-18; observed output is verbatim.

### R1 — EpicGames/unreal-engine is unreachable from this account: 404

```
$ git ls-remote https://github.com/EpicGames/unreal-engine
remote: Repository not found.
fatal: repository 'https://github.com/EpicGames/unreal-engine/' not found
   exit 128

$ gh api repos/EpicGames/UnrealEngine
{"message":"Not Found","documentation_url":"https://docs.github.com/rest/repos/repos#get-a-repository","status":"404"}
gh: Not Found (HTTP 404)

$ gh auth status
github.com
  ✓ Logged in to github.com account VeigaPunk (keyring)
  - Token scopes: 'gist', 'read:org', 'repo', 'workflow'
```

**[O]** The account is authenticated and has `repo` scope, so the 404 is not an
auth-token failure — it is the expected consequence of `VeigaPunk` not being
Epic-linked. The engine source tree cannot be fetched.

### R2 — AUR route hits the same wall, in SSH form

AUR `unreal-engine` 5.8.2-1 PKGBUILD (fetched to `/tmp/r101seat12-aur-PKGBUILD`,
527 lines; `pkgver=5.8.2`, `pkgrel=1`). Line 280 **[O]**:

```bash
  # Check access to the repository
  if ! git ls-remote git@github.com:EpicGames/UnrealEngine &>/dev/null; then
    error 'You must register at unrealengine.com and link your github account to access this private repo. See the wiki for more info: https://wiki.archlinux.org/index.php/Unreal_Engine_4'
    exit 1
  fi
```

The gate is `prepare()`-time, so the build aborts before compiling. Observed:

```
$ git ls-remote git@github.com:EpicGames/UnrealEngine
git@github.com: Permission denied (publickey).
fatal: Could not read from remote repository.
   exit 128
```

**[O]** Line 327/336/341 of the same PKGBUILD clone
`git@github.com:EpicGames/UnrealEngine` at branch `${pkgver}-release`, confirming
the whole AUR path is SSH-bound to the Epic-linked account. **Engine install is
BLOCKED pending operator Epic-account linking.** Note also that this PKGBUILD
downloads ~200 MiB of source plus ~11 GiB of dependencies and "may take several
hours to compile" (header comment) — a decision for the operator, not this seat.

### R3 — Lutris route is available as software but operator-gated on credentials

```
$ pacman -Si lutris
Repository      : extra
Name            : lutris
Version         : 0.5.22-3
Description     : Open Gaming Platform
Licenses        : GPL-3.0-only

$ pacman -Qi lutris
error: package 'lutris' was not found        # not installed

$ docker --version
Docker version 29.7.2, build a7dcaa6fdb
```

**[O]** Lutris is one `pacman -S lutris` away and `docker` is present, so the
*mechanism* exists on this host. The blocking step is the **Epic Games Store
account login**, which is an operator-owned credential: the install is
**OPERATOR-GATED**, not host-blocked. Nothing this seat can run closes it.

### Host state at time of writing

```
$ ss -ltnp | grep -c ':8000'      → 0        # no MCP server listening
$ command -v UnrealEditor UnrealEditor-Cmd UE4Editor   → (none)
$ ls -d /opt/unreal* /usr/share/unreal*                → No such file or directory
$ nproc → 32 ; free -g → 30 GB ; df -h / → 780G free (15% used)
$ jq-1.8.2 · Python 3.14.7 · node v26.12.0 · ShellCheck 0.11.0
```

**[O]** Unreal Editor is not installed, no editor process or MCP endpoint is
listening, and no engine binary exists on `PATH`. Combined with R1–R3 this makes
every live-editor claim in this subtree **unproven by construction** — a property
of the host, not a gap that more local work can close. Live-editor MCP runtime
claims are labeled, never asserted.

## 6. Declared file tree

The subtree as declared by this seat, with what is actually present at
2026-10-18T17:18:24Z:

```
corpus/knowledge/unreal-mcp/
├── README.md                     ← index + verification policy (SEAT-14)
├── PROVENANCE.md                 ← this file (SEAT-12)
├── .manifest.d/                  ← 12 files: audit-reference.sha256 + seat01..seat11
├── upstream/                     ← 12 vendored upstream files, byte-identical, read-only
│   ├── README.md  LICENSE  CODEOWNERS  .gitignore
│   ├── .claude-plugin/plugin.json
│   ├── hooks/hooks.json  hooks/unreal-context.sh
│   └── skills/
│       ├── unreal-mcp/SKILL.md
│       ├── unreal-mcp/references/setup.md
│       ├── unreal-mcp/references/operations.md
│       ├── create-toolset/SKILL.md
│       └── unreal-skill/SKILL.md
└── executability/                ← 13 subsystem verdict cards
```

The 12 upstream paths are listed in §2. The 13 `executability/` cards, each
labeled exactly one of `verified-here` | `static-only` | `unproven-runtime`
(the label and its evidence live in the card, not here):

| # | card | # | card |
|---|---|---|---|
| 1 | `executability/actors-scene.md` | 8 | `executability/vfx-niagara-dataflow.md` |
| 2 | `executability/blueprints.md` | 9 | `executability/ui-umg-slate.md` |
| 3 | `executability/assets-content.md` | 10 | `executability/gameplay-gas.md` |
| 4 | `executability/materials.md` | 11 | `executability/testing-automation.md` |
| 5 | `executability/meshes-textures.md` | 12 | `executability/editor-general.md` |
| 6 | `executability/animation-controlrig.md` | 13 | `executability/scripting-programmatic.md` |
| 7 | `executability/sequencer.md` | | |

`ls -1 executability/ | wc -l` → **13** **[O]**.

### `probes/` — declared, but it lives outside this subtree

The seat declaration names `probes/` as part of this tree. **No such directory
exists under `corpus/knowledge/unreal-mcp/`** (`ls -d
corpus/knowledge/unreal-mcp/probes` → `No such file or directory` **[O]**). The
round's probe notes are written to `reports/round-101/probes/` instead.

That directory is **live**: sibling seats were still writing to it while this file
was authored (observed count `12` at 17:17Z and `14` at 17:18:24Z on 2026-10-18
**[O]**), so any list here is a snapshot, not a fixed claim. Re-derive with:

```sh
ls -1 reports/round-101/probes/ | wc -l   # → 14 at 2026-10-18T17:18:24Z
```

Snapshot at `2026-10-18T17:18:24Z` (14 files):

```
reports/round-101/probes/
├── byte-identity-reference.md   ← SEAT-15, produced .manifest.d/audit-reference.sha256
├── doc-consistency.md
├── hook-shellcheck.md           ← SEAT-18
├── install-path.md
├── license-audit.md             ← SEAT-28  (rights analysis cited in §3)
├── md-links.md                  ← SEAT-20
├── operations-inventory.md      ← SEAT-22
├── plugin-json.md               ← SEAT-16
├── prereq-matrix.md
├── r22-relation.md
├── security-surface.md
├── skill-frontmatter.md         ← SEAT-19
├── toolset-census.md            ← SEAT-25
└── ue-version-matrix.md
```

**[I]** The probe notes are the evidence layer for this subtree, but they are
round reports, so they sit under `reports/round-101/` rather than in the corpus.
The declaration's `probes/` should be read as "the round's probe notes, at
`reports/round-101/probes/`" — not as a missing directory. Whether to move or
mirror them into the corpus is an L1/round decision, not this seat's.

## 7. What this file does not claim

- No Unreal Editor, UnrealBuildTool, or MCP tool call was run; none can be on this
  host (§5). Nothing here is runtime evidence.
- Byte-identity and static checks prove *the files* — that they are what upstream
  shipped — and say nothing about whether the editor honors them.
- The MIT analysis in §3 is a reading of the license text with receipts, not legal
  advice; the authoritative treatment is the cited license audit.
- The pin is a moving target upstream: `main` agreed with the pin when checked on
  2026-10-18 **[O]**, and a later upstream commit would not invalidate this
  vendored copy, only its freshness.

## 8. Known out-of-pin upstream surface (recorded, not vendored)

Adopted scope wording at adjudication: C1 covers **all files tracked at the
pinned commit** — 12/12, byte-identical. Adversarial review
(`reports/round-101/r101-critic-c1.md` §3) found upstream content **outside**
the pin; it is recorded here, not vendored. Hashes below are as recorded by
that review, each with its reproducing command **[I]** (re-derive per its §3):

| path | where it lives | bytes | sha256 (recorded) |
|---|---|---|---|
| `.claude-plugin/marketplace.json` | open PR 1 | 908 | `390e7e9c9a4f21d7835541bb3b79ebb7afb5392d6ba0ce1e090b7a17ba6a77d8` |
| `.github/workflows/ci.yml` | open PR 4 | 1116 | `4bac0081914d78f80be04c1776fe2244b53c6c4334116309f4ba5b83c04cc38d` |
| `hooks/unreal-context.ps1` | open PR 4 | 3322 | `eaf782fecd4430f0d04a50179742841eb5922c08162758b5de7cf7fc343f1c7f` |
| `tests/test_hooks.sh` | open PR 4 | 2778 | `35215587a86fd593bb53c0c90ccbc7f7a13a5179744e9616ef9670be5e9caa65` |
| `tests/test_hooks.ps1` | open PR 4 | 3796 | `755befe2e509ae3a3c384ded7fd7ace68b501611eb6d10dc1218b23d6f3c06a8` |
| `skills/unreal-mcp/references/toolsets.md` | history-only (deleted in `823f598`) | 8306 | blob `eaf2e838a259fb41be10309f9373bca8778607c5` |

Two further recorded facts **[I]**: a second distribution channel exists
(`anthropics/claude-plugins-official` marketplace entry, whose `source.sha`
independently corroborates the pin), and one reachable Epic doc page is not
pointed at by this corpus. Whether any of these surfaces enters the corpus is
a future-round decision, not this round's claim.
