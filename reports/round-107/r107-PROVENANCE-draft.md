# PROVENANCE — vendored `unreal-engine-skills-for-claude-code-plugin`

Round r107 (3D side-round) · lane game-dev-3d-shokunin · seat KEY=PROVENANCE-WRITER.
Drafted 2026-10-19. Every claim below carries the command that produced it and
the output observed on this host. Labels: **[O]** observed here, **[I]**
inference, **[?]** unknown.

> **HEADLINE (r107).** The re-vendor target resolved this round is **byte-for-byte
> the same commit** as the r101 pin, `a6aa73ada02a9fb1f5415bec491f9942c519b297`.
> There is **no pin move**; the round's value is independent re-derivation of the
> pin and of the 12/12 byte-identity across four transports. The r101 pin record
> is preserved verbatim as a dated history note in §9 (append-only).

This file is the authoritative record of *where the content in this subtree came
from* and *why it may be redistributed here*. It asserts nothing about Unreal
Engine behavior; see `README.md` in this directory for the verification policy
and `executability/` for the per-subsystem verdicts.

---

## 1. Upstream identity and pin (r107 re-derivation)

| field | value | how it was obtained |
|---|---|---|
| repository | `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin` | `git ls-remote <url> main` **[O]** |
| visibility | public, `private: false` | `gh api repos/…` **[O]** |
| default branch | `main` | `gh api … --jq .default_branch` **[O]** |
| **pinned commit (r107)** | **`a6aa73ada02a9fb1f5415bec491f9942c519b297`** | `git ls-remote <url> main`; `gh api …/commits/main --jq .sha`; fresh `git clone` + `rev-parse HEAD` **[O]** |
| pin vs r101 | **identical — no move** | r101 PROVENANCE §1 records the same SHA (§9 below) **[O]** |
| commit subject | `[MCP] Permit safe concurrent tool calls` | `gh api …/commits/main --jq .commit.message` **[O]** |
| author / date | Thomas Mansencal, `2026-09-17T01:19:50Z` | `gh api …/commits/main --jq .commit.author` **[O]** |
| committer date | `2026-09-17T01:28:32Z` (`2026-09-17 13:28:32 +1200`) | `gh api …/commits/main --jq .commit.committer.date`; `git log -1 --format=%ci` **[O]** |
| plugin version | `3.1.1` | `jq -r .version upstream/.claude-plugin/plugin.json` **[O]** |
| **fetch date** | **2026-10-19** | this seat's clone/verify run, `2026-10-19T03:08:36Z` (VENDOR-A clone stamp) **[O]** |
| tracked files | **12** (all mode `100644`; no symlinks, no submodules, no LFS) | `git ls-files -s \| wc -l` **[O]** |
| branches / tags | one branch (`main`); **no tags advertised** | `git ls-remote <url>` **[O]** |

Verbatim pin resolution (2026-10-19):

```
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin main
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main

$ gh api repos/EpicGames/unreal-engine-skills-for-claude-code-plugin/commits/main --jq .sha
a6aa73ada02a9fb1f5415bec491f9942c519b297
```

**[O]** Because `main` still points at the r101 SHA, "re-vendor at a fresh pin"
re-establishes the *same* commit. This is a finding, not an assumption: three
independent seats (VENDOR-A, VERIFY-LEAD, PIN-DELTA) each resolved `a6aa73ad…`
from the wire this round.

## 2. Byte-identity of the vendored tree (4 transports, 12/12)

The round requires 3 independent transports. This seat additionally cross-checked
the vendored tree, giving four content sources that share no local state:

| # | transport | source path | mechanism |
|---|---|---|---|
| T1 | `git clone` (https smart protocol) | `/var/tmp/r107-va/repo` | git object store |
| T2 | **codeload tarball** (`curl`, no git protocol) | `/var/tmp/r107-vb/x/…-a6aa73ad…/` | raw tar.gz |
| T3 | independent `git clone` (VERIFY-2 seat) | `/var/tmp/r107-verify2/clone` | git object store |
| T4 | **vendored tree on disk** | `corpus/knowledge/unreal-mcp/upstream/` | the landed copy |

Commands and observed output (2026-10-19):

```
$ for d in /var/tmp/r107-va/repo /var/tmp/r107-verify2/clone /var/tmp/r107-provenance/clone; do
    git -C "$d" rev-parse HEAD; done
a6aa73ada02a9fb1f5415bec491f9942c519b297
a6aa73ada02a9fb1f5415bec491f9942c519b297
a6aa73ada02a9fb1f5415bec491f9942c519b297

$ diff -rq /var/tmp/r107-va/repo /var/tmp/r107-vb/x/…-a6aa73ad… --exclude=.git
(no output)   exit 0
$ diff -rq /var/tmp/r107-va/repo /var/tmp/r107-verify2/clone --exclude=.git
(no output)   exit 0
$ diff -rq /var/tmp/r107-provenance/clone corpus/knowledge/unreal-mcp/upstream --exclude=.git
(no output)   exit 0

# per-path sha256 across T1/T2/T4/vendored:
4-way identical=12 mismatched=0 of 12
```

`sha256sum -c .manifest.d/audit-reference.sha256` (run from the subtree) prints
`OK` for all 12 paths and exits `0` **[O]**; `sha256sum -c .manifest.d/seat*.sha256`
prints `12` `OK` lines across the 11 seat manifests (seat11 holds 2 files) **[O]**.
The vendored copy is therefore byte-identical to the pinned upstream commit, and
all four transports agree.

### Per-file hash table (r107)

`git-blob` is the upstream object id (`git ls-files -s`), kept so a future round
can re-check content against the object store without a working tree. All values
re-derived this round from a fresh clone.

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

**[O]** Every value above is unchanged from r101's table (same pin ⇒ same bytes).
Reproduce the pin and the whole sweep in one block:

```sh
git clone https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin /tmp/ue-skills-ref
git -C /tmp/ue-skills-ref rev-parse HEAD    # expect a6aa73ada02a9fb1f5415bec491f9942c519b297
cd corpus/knowledge/unreal-mcp
sha256sum -c .manifest.d/audit-reference.sha256   # expect 12× OK, exit 0
diff -rq /tmp/ue-skills-ref upstream --exclude=.git   # expect no output, exit 0
```

### Brief-vs-observed: 11 paths vs 12 files

Unchanged from r101. Upstream tracks **12** files; the split is **11 vendoring
seats** (`seat01`–`seat10` one file each; `seat11` two: `CODEOWNERS` + `.gitignore`).
`wc -l .manifest.d/seat11.sha256` → `2` **[O]**, `seat01`–`seat10` are 1 line each
**[O]**. "11" is the seat count, "12" the file count.

## 3. License and vendoring rights

| field | value | receipt |
|---|---|---|
| **LICENSE file name** | **`LICENSE`** (no extension) at `upstream/LICENSE` | `find upstream -maxdepth 1 -name 'LICENSE*'` → `upstream/LICENSE` **[O]** |
| license | **MIT License**, `Copyright (c) 2026 Epic Games, Inc.` | `head -3 upstream/LICENSE` **[O]** |
| size / sha256 | 1073 bytes / `5b337be051359edcdec510103aee15f5f870efb38b6d42eecd685dc3582314a6` | `sha256sum upstream/LICENSE` **[O]** |
| corroboration | `"license": "MIT"` in `plugin.json`; GitHub API reports `license: MIT` | `gh api repos/… --jq .license.spdx_id` → `MIT` **[O]** |
| other terms in the tree | none — no `NOTICE`, `COPYING`, third-party dir, or per-file SPDX header | sweep recorded in the license audit below |

**Vendoring-rights pointer:** the operative MIT grant, the notice-retention
condition, and the verdict that vendoring these copies into this corpus is
**PERMITTED** are established in
[`reports/round-101/probes/license-audit.md`](../../../reports/round-101/probes/license-audit.md)
(SEAT-28 PROBE) — its §1 (identification), §2 (quoted clause with line numbers),
and §3 (verdict, incl. the scope caveat that MIT covers only the plugin repo's own
files and does **not** extend to Unreal Engine itself, under Epic's separate EULA,
which is not vendored here). That audit remains authoritative; this section only
records the file name and hash, re-derived this round.

Consequence recorded, not asserted: because `upstream/LICENSE` is itself vendored
byte-identically, the copyright and permission notices travel with the copies.

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
below so the round's install status is recorded in the corpus.

## 5. The three install receipts (re-run 2026-10-19)

All three re-run this round; observed output is verbatim.

### R1 — EpicGames/unreal-engine is unreachable from this account: 404

```
$ git ls-remote https://github.com/EpicGames/unreal-engine
remote: Repository not found.
fatal: repository 'https://github.com/EpicGames/unreal-engine/' not found
   exit 128

$ gh api repos/EpicGames/UnrealEngine
{"message":"Not Found",…,"status":"404"}
gh: Not Found (HTTP 404)

$ gh auth status
github.com
  ✓ Logged in to github.com account VeigaPunk (keyring)
  - Active account: true
```

**[O]** The account is authenticated with `repo` scope, so the 404 is not an
auth-token failure — it is the expected consequence of `VeigaPunk` not being
Epic-linked. The engine source tree cannot be fetched.

### R2 — AUR route hits the same wall, in SSH form

AUR `unreal-engine` (RPC: `5.8.2-1`) PKGBUILD gates `prepare()` on
`git ls-remote git@github.com:EpicGames/UnrealEngine`, aborting before compile.
Observed:

```
$ git ls-remote git@github.com:EpicGames/UnrealEngine
git@github.com: Permission denied (publickey).
fatal: Could not read from remote repository.
   exit 128
```

**[O]** **Engine install is BLOCKED pending operator Epic-account linking.** Note
the AUR package downloads ~200 MiB of source plus ~11 GiB of dependencies and "may
take several hours to compile" — an operator decision, not this seat's.

### R3 — Lutris route is available as software but operator-gated on credentials

```
$ pacman -Si lutris
Repository      : extra
Name            : lutris
Version         : 0.5.22-3
$ pacman -Qi lutris
error: package 'lutris' was not found        # not installed
$ docker --version
Docker version 29.7.2, build a7dcaa6fdb
```

**[O]** Lutris is one `pacman -S lutris` away and `docker` is present, so the
*mechanism* exists. The blocking step is the **Epic Games Store account login**, an
operator-owned credential: **OPERATOR-GATED**, not host-blocked.

### Host state at time of writing (2026-10-19)

```
$ ss -ltnp | grep -c ':8000'      → 0        # no MCP server listening
$ command -v UnrealEditor UnrealEditor-Cmd UE4Editor   → (none)
$ ls -d /opt/unreal* /usr/share/unreal*                → No such file or directory
$ nproc → 32 ; free -g → 30 GB ; df -h / → 747G free (19% used)
$ jq-1.8.2 · Python 3.14.7 · node v26.12.0 · ShellCheck 0.11.0
```

**[O]** Unreal Editor is not installed, no editor process or MCP endpoint is
listening, no engine binary exists on `PATH`. Combined with R1–R3 this makes every
live-editor claim in this subtree **unproven by construction** — a property of the
host, not a gap more local work can close. Live-editor MCP runtime claims are
labeled, never asserted.

### Container unlock attempt (r107) — UNPROVEN-with-attempt-log

A bounded `docker pull wukakuki/unreal-engine:dev-slim-5.8.3` was launched before
the swarm (nohup, log `/var/tmp/ue-pull.log`) to test whether a UE runtime could be
smoke-probed in a container. At this seat's last check the pull was **still running**
(`ps` shows the `docker pull` process; `docker images | grep -i unreal` → **no
image**), so no `docker image inspect` and no container probe were possible. The
runtime is therefore **UNPROVEN-with-attempt-log**; the unlock seats
(`r107-unlock*.md`) own the final label. No license acceptance, no engine build, no
editor launch occurred.

## 6. Declared file tree

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
├── executability/                ← 13 subsystem verdict cards
├── gate/                         ← close-out gate (run_gate.sh + README)
└── adaptation-kimi.md            ← Claude → Kimi mapping table
```

The 13 `executability/` cards (`ls -1 executability/ | wc -l` → **13** **[O]**),
each labeled exactly one of `verified-here` | `static-only` | `unproven-runtime`
(label + evidence live in the card): actors-scene, blueprints, assets-content,
materials, meshes-textures, animation-controlrig, sequencer, vfx-niagara-dataflow,
ui-umg-slate, gameplay-gas, testing-automation, editor-general, scripting-programmatic.

### `probes/` — declared, but lives outside this subtree

As in r101: no `probes/` directory exists under this subtree. The round's probe
notes live at `reports/round-101/probes/` (r101) and `reports/round-107/` (this
round). The declaration's `probes/` should be read as "the round's probe notes, in
the round report" — not a missing directory.

## 7. What this file does not claim

- No Unreal Editor, UnrealBuildTool, or MCP tool call was run; none can be on this
  host (§5). Nothing here is runtime evidence.
- Byte-identity and static checks prove *the files* — that they are what upstream
  shipped — and say nothing about whether the editor honors them.
- The MIT analysis in §3 is a reading of the license text with receipts, not legal
  advice; the authoritative treatment is the cited license audit.
- The pin is a moving target upstream: `main` agreed with the pin when checked on
  2026-10-19 **[O]**, and a later upstream commit would not invalidate this
  vendored copy, only its freshness.

## 8. Known out-of-pin upstream surface (refreshed r107)

Adopted scope wording at adjudication: C1 covers **all files tracked at the pinned
commit** — 12/12, byte-identical. Everything below is **outside** the pin; it is
recorded here, **not vendored**.

### 8a. Open PR refs (r107 re-derivation)

**[O]** `git ls-remote <url>` now advertises **six** open PRs (r101 §8 recorded
only PRs 1 and 4, so r101's census was a stale snapshot). All six confirmed
`state=open merged=null`:

| PR | head SHA | title |
|---|---|---|
| 1 | `435522c0c66685049ac624fef04568ec313bebe7` | Add missing `.claude-plugin/marketplace.json` so the documented install paths work |
| 2 | `6dd839e996900e226316b30a7fc00ee6f58a6772` | Add Marketplace.json |
| 4 | `83807c0ea52bef194537e8ccbe3028d4b9daedc9` | feat: add marketplace manifest … |
| 5 | `c64c609745de466cecb184707ff5974fb9375339` | Quote `CLAUDE_PLUGIN_ROOT` in SessionStart hook command |
| 8 | `1a3476f7a1f3676c78f0153014c3e48b8b8a2a68` | **Add an OpenCode port** (new this round) |
| 9 | `a5180ccd03c2813682a7fa19ca25ee9967bfe1de` | **[MCP] Document 5.8.3 toolset quirks, bump to 3.1.2** (new this round) |

### 8b. Unvendored path identities

`ever-existed-minus-at-pin` = **16 paths** (was 6 in r101). Re-derived:

```
$ comm -23 <(git log --all --pretty=format: --name-only | sort -u | grep -v '^$') \
           <(git ls-tree -r HEAD --name-only | sort) | wc -l
16
```

Five are the r101 PR-ref paths (unchanged identities), plus **11 new `opencode/*`
files from PR8** and the history-only `toolsets.md`:

| path | where it lives | git blob | bytes | sha256 |
|---|---|---|---|---|
| `.claude-plugin/marketplace.json` | PR1 (PR2 variant: 907 B / `1de11f56…`) | `199814c301d081e8035a4ab3aa8c463d92c3ab1a` | 908 | `390e7e9c9a4f21d7835541bb3b79ebb7afb5392d6ba0ce1e090b7a17ba6a77d8` |
| `.github/workflows/ci.yml` | PR4 | `31193716cc234f0e72a05ec8f80ab615b1824b9f` | 1116 | `4bac0081914d78f80be04c1776fe2244b53c6c4334116309f4ba5b83c04cc38d` |
| `hooks/unreal-context.ps1` | PR4 | `0dab1245aa06a1d99a06aaf2abc56c1d64b6a46c` | 3322 | `eaf782fecd4430f0d04a50179742841eb5922c08162758b5de7cf7fc343f1c7f` |
| `tests/test_hooks.sh` | PR4 | `853f1f4c344e9e765ff65590ca9176ef6bb5322f` | 2778 | `35215587a86fd593bb53c0c90ccbc7f7a13a5179744e9616ef9670be5e9caa65` |
| `tests/test_hooks.ps1` | PR4 | `ce2e220e7e9e39da6c617066e3027b390fb6bcf9` | 3796 | `755befe2e509ae3a3c384ded7fd7ace68b501611eb6d10dc1218b23d6f3c06a8` |
| `opencode/README.md` | PR8 | `bc12cc19d31fe6ce18c29700bcd24a75232292ad` | 8466 | `5f36bc34d24772de51c2ed5d6e564d38b65ff9c6506bf96828eb6c63162e6776` |
| `opencode/package.json` | PR8 | `7b1d058cdeb20ffcefbd720ee211956cc048e9a9` | 691 | `7142423866e0f8805fcefbae5272167b6e9146cc33706f0fa1ba562fad41f912` |
| `opencode/index.ts` | PR8 | `1cc7c2956079109d5b77718b95be43bc71918d3c` | 3640 | `82341c50550781285a0fdd925f4c8f515d586511885d49ffc2171386f95f6e3f` |
| `opencode/project.ts` | PR8 | `32766d700ccc8f6743550c07fcaebc6d03c9bc84` | 3294 | `579bdfd134254d1e8ac057bda3b8f4b596ae6c8ea5f78320f4b4d60f516a781e` |
| `opencode/skills.ts` | PR8 | `635c6d9b829d051ceb32240b0c57e679ac20b791` | 2820 | `8c0762021c04a7e3cabf7109ce11cf38f5340c61ad0382cfdace9e33a90b255c` |
| `opencode/scripts/sync-skills.mjs` | PR8 | `47c7d0c1093aa35d453b3a9342d9a9e7737a706c` | 652 | `eed3bc9ea80069325272d8069461163b08c9f0d703d6e429797672fd338c2191` |
| `opencode/.gitignore` | PR8 | `d257efd9dbdb039ef9af5b180bce482d85932708` | 82 | `c418e00935c8785c78b15adb0a14a0d502b98200429924c05f44bade627c120a` |
| `opencode/test/plugin.test.ts` | PR8 | `0d93d9716d7f91ef78a9a1ab2a050339695907cc` | 4729 | `5ae1bcf8f26b9b45e1523363aed3635c886e37df67d39e75b3ad7e0d2284e626` |
| `opencode/test/project.test.ts` | PR8 | `ef5101ef9171d08c869b4e74d2e7361efb1b087c` | 3340 | `b14d519a210125e6f619bf8a31b553707ac3909bbf75ba06958d695fb95e614f` |
| `opencode/test/skills.test.ts` | PR8 | `6473032837849aa970b0b9ee34c6bef45dae4aa1` | 2981 | `1e9a4ac508fb13d6f99d41c5a32ea9e6c1c66a89dce7b30efe392c385791abf9` |
| `skills/unreal-mcp/references/toolsets.md` | history-only (deleted in `823f598`) | `eaf2e838a259fb41be10309f9373bca8778607c5` | 8306 | `1b184bbb31836319ef50ad0661306f7e22bbcf19bf71bed70b6a58d60da69cec` |

**[I]** Why this matters: `hooks/unreal-context.ps1` is a second, fully-implemented
hook and `tests/test_hooks.{sh,ps1}` are the repo's only test suite; PR5 fixes a
quoting bug in the very `hooks/hooks.json` this corpus vendors (unquoted
`${CLAUDE_PLUGIN_ROOT}`); PR8 adds a whole non-Claude port (`opencode/`); PR9
documents UE 5.8.3 toolset quirks and bumps the plugin to `3.1.2`. A reader of the
corpus alone cannot discover any of this.

### 8c. Second distribution channel

**[I]** A second channel exists: `anthropics/claude-plugins-official` marketplace
entry, whose `source.sha` independently corroborates the pin (recorded in r101
`r101-critic-c1.md` §3e). Whether any of these surfaces enters the corpus is a
future-round decision, not this round's claim.

## 9. r101 pin record — preserved (append-only history)

Per the lane's dated-note discipline, the r101 record is **not rewritten**. Its
state on the day it was written:

> **r101 (written 2026-10-18).** Pin `a6aa73ada02a9fb1f5415bec491f9942c519b297`,
> resolved from the reference clone `/tmp/ue-skills-ref`
> (`git -C /tmp/ue-skills-ref rev-parse HEAD` → that SHA) and corroborated by an
> independent fresh clone at `/tmp/r101-audit`. Fetch date **2026-10-18**
> (`2026-10-18T17:17:31Z`). Tracked files **12**. Plugin version `3.1.1`. r101 §8
> recorded **6** out-of-pin paths across PRs 1, 2, 4, 5, plus history-only
> `toolsets.md` (i.e. four PR refs: 1, 2, 4, 5). r101 PROVENANCE.md sha256 at
> read time this round: `36938c71a0f5b1296b60ed505274d0b19fd87308eac61983525c2b2b44387f01`
> (361 lines).

**r107 delta vs r101:** pin **unchanged**; fetch date **2026-10-19**; verification
transports **4** (was 2); out-of-pin census **6 → 16** paths (six open PRs, was
four); runtime still **UNPROVEN** (docker pull in flight, no image). No content
bytes moved, because no commit moved.
