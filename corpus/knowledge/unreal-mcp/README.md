# unreal-mcp — vendored upstream corpus + executability index

Deterministic index of this corpus subtree (round r101, seat SEAT-14). Everything
here describes the Epic Games *Unreal Engine Skills for Claude Code* plugin:
what was vendored, how its byte-identity is proven, and what — if anything —
can be executed on this host.

This subtree is a **read-only reference corpus**. It is not a live-editor
integration and it asserts no runtime behavior. See the verification policy
below before reusing any claim.

## Verification policy (read this first)

The policy is binary. Every **claim** in this subtree is either `proven` or
`unproven` — no middle ground, no "probably".

- **proven** — the claim is backed by (a) **byte-identical** vendored content:
  `sha256sum` of the file under `upstream/` equals the hash of the same path in
  a fresh clone of the pinned upstream commit; **and** (b) a **static check**
  that was actually run on this host: a checksum sweep, a JSON parse, a shell
  syntax/lint pass, or a line/byte count. Static means the tool ran here and its
  output is recorded; it does not mean the *content* is semantically correct.
- **unproven** — anything that requires a **live Unreal Editor**: starting the
  MCP server, `list_toolsets` / `describe_toolset` / `call_tool`, spawning or
  mutating actors, compiling via Live Coding, running automation tests, Niagara
  / Sequencer / Control Rig authoring, `ProgrammaticToolset.execute_tool_script`,
  and every other tool dispatch. **None of these can be proven on this host**,
  because Unreal Editor is not installed (see Host reality). Runtime claims are
  labeled, never asserted.

### How the binary policy maps onto the ternary card labels

The `executability/` cards are labeled from a **three-value** vocabulary, which
is finer than this policy because a card can prove its *document facts* while
being unable to prove its *subsystem behavior*. The mapping is:

| card label | what it means | policy state |
|---|---|---|
| `verified-here` | a bounded run of the subsystem actually happened on this host, with a saved receipt | `proven` |
| `static-only` | the vendored document facts are proven by a static check run here; **no** runtime observation was made | `proven` for the document facts, `unproven` for the subsystem's behavior |
| `unproven-runtime` | the claim needs the live editor and nothing was observed | `unproven` |

So `static-only` is **not** a third policy state — it is the honest split of a
card whose file-level claims are proven and whose behavior claims are not. The
binary policy still governs: a subsystem behavior claim is `unproven` unless a
`verified-here` receipt exists. On this host no such receipt can exist, so every
card is expected to resolve to `static-only` or `unproven-runtime`, and a
`verified-here` label would require a receipt of a bounded run on this host.

Corollary rules:

- A connected MCP client, a visible cached tool catalog, or a successful
  `unreal_mcp_status` **does not** prove Unreal is reachable. Only a successful
  read-only Unreal tool call would, and that is unproven here.
- Absence of the engine never authorizes a runtime claim; static/format evidence
  is always labeled as such.
- A static check proves the *files* it read, not the *behavior* they describe.
  Byte-identity of a vendored skill file proves the file is what upstream
  shipped; it says nothing about whether the editor honors it.

### Host reality (receipts)

- Arch Linux, 32 cores, 30 GB RAM, 780 GB free on `/`; `jq`, `python3`, `node`,
  `shellcheck` 0.11.0 present.
- **Unreal Editor is NOT installed.** `EpicGames/unreal-engine` `git ls-remote`
  → `Repository not found` (GitHub authed as `VeigaPunk`, not Epic-linked); the
  AUR `unreal-engine` 5.8.2-1 PKGBUILD requires SSH access to
  `git@github.com:EpicGames/UnrealEngine`, so engine install is **blocked**
  pending operator Epic-account linking.
- Consequence: **every live-editor claim in this subtree is unproven by
  construction.** It is not a gap that more local work can close; it is a
  property of the host.

## Upstream provenance

| field | value |
|---|---|
| repository | `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin` |
| pinned commit | `a6aa73ada02a9fb1f5415bec491f9942c519b297` (branch `main`) |
| commit subject | `[MCP] Permit safe concurrent tool calls` |
| commit author | Thomas Mansencal `<thomas.mansencal@epicgames.com>` |
| commit date | 2026-09-17 13:19:50 +1200 |
| plugin version | `3.1.1` (from `upstream/.claude-plugin/plugin.json`) |
| license | MIT (see `upstream/LICENSE`) |
| tracked files | **12** (all mode `100644`; no symlinks, no submodules, no LFS, no `.gitattributes`) |
| vendored | 12/12 byte-identical under `upstream/` |

Reproduce the pin and the byte-identity check:

```sh
git clone https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin /tmp/ue-skills-ref
git -C /tmp/ue-skills-ref rev-parse HEAD   # expect a6aa73ada02a9fb1f5415bec491f9942c519b297
cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256
```

`sha256sum -c` over all manifests prints `OK` for every path and exits `0`.

> Round brief note: the round context says "all 11 vendored paths". Upstream
> actually tracks **12** files. The `seat01`–`seat11` manifests cover them as 10
> single-file manifests plus one two-file manifest (`seat11` = `CODEOWNERS` +
> `.gitignore`); `audit-reference.sha256` is the independent 12/12 reference.
> This index lists all 12.

## Layout

```
corpus/knowledge/unreal-mcp/
├── README.md              ← this index
├── PROVENANCE.md          ← provenance manifest (SEAT-12)
├── adaptation-kimi.md     ← Claude→Kimi adaptation table + verification policy (SEAT-13)
├── .manifest.d/           ← per-seat sha256 manifests + the 12/12 audit reference
├── upstream/              ← 12 vendored upstream files, byte-identical, read-only
└── executability/         ← subsystem verdict cards (13 intended; seats land them)
```

## `upstream/` — the 12 vendored paths

All paths are relative to `corpus/knowledge/unreal-mcp/`. Every row is `proven`:
byte-identical to the pinned clone **and** `sha256sum -c` verified here.

| # | path | bytes | lines | sha256 (short) |
|---|---|---|---|---|
| 1 | `upstream/README.md` | 8398 | 112 | `483693ad…46b40e` |
| 2 | `upstream/LICENSE` | 1073 | 21 | `5b337be0…314a6` |
| 3 | `upstream/CODEOWNERS` | 64 | 2 | `653d3725…550f0f` |
| 4 | `upstream/.gitignore` | 203 | 4 | `0fad2f57…81e538` |
| 5 | `upstream/.claude-plugin/plugin.json` | 487 | 10 | `5aa98484…b4d44` |
| 6 | `upstream/hooks/hooks.json` | 357 | 17 | `259124f0…b5ebdc0c` |
| 7 | `upstream/hooks/unreal-context.sh` | 3101 | 84 | `d3f1c871…5651fdd` |
| 8 | `upstream/skills/unreal-mcp/SKILL.md` | 7098 | 56 | `7ef8b991…d038fa` |
| 9 | `upstream/skills/unreal-mcp/references/setup.md` | 6065 | 133 | `bd16206e…8a3b8a` |
| 10 | `upstream/skills/unreal-mcp/references/operations.md` | 6497 | 51 | `dbed002b…7c3113` |
| 11 | `upstream/skills/create-toolset/SKILL.md` | 23258 | 420 | `e9d05008…c1f7b1c` |
| 12 | `upstream/skills/unreal-skill/SKILL.md` | 6955 | 112 | `7a0af781…f435087` |

Full hashes: `.manifest.d/audit-reference.sha256` (12/12 reference) and the
per-seat manifests. What each file is:

- **`README.md`** — plugin overview: prerequisites (Editor + `ModelContextProtocol`
  and `AllToolsets` plugins), platform support, install via the
  `claude-plugins-official` marketplace, security model, and the "What's
  Available" domain list that seeds the 13 `executability/` cards.
- **`LICENSE`** — MIT. **`CODEOWNERS`** — `*  @Thomas.Mansencal`.
  **`.gitignore`** — ignores `skills/*-workspace/` skill-creator artifacts.
- **`.claude-plugin/plugin.json`** — plugin manifest, name
  `unreal-engine-skills-for-claude-code`, version `3.1.1`.
- **`hooks/hooks.json`** — declares one `SessionStart` hook (matcher
  `startup|resume|clear`) invoking `bash ${CLAUDE_PLUGIN_ROOT}/hooks/unreal-context.sh`
  with a 5 s timeout.
- **`hooks/unreal-context.sh`** — walks upward from `$PWD` for a UE project
  marker (`GenerateProjectFiles.*` or a `*.uproject`), then prints a short
  `SessionStart` JSON note steering the agent to UE conventions and the
  `unreal-mcp` skill. Plain bash; lintable with `shellcheck` here.
- **`skills/unreal-mcp/SKILL.md`** — the core skill: live-editor MCP workflow
  (`list_toolsets` → `describe_toolset` → `call_tool`), safety rules, project
  Agent Skills, and pointers to the two reference files.
- **`skills/unreal-mcp/references/setup.md`** — first-time setup: enable the two
  plugins, enable auto-start, generate `.mcp.json`, optional proxy install.
- **`skills/unreal-mcp/references/operations.md`** — console commands
  (`ModelContextProtocol.StartServer` etc.), tool-search mode, proxy recovery,
  and a troubleshooting matrix.
- **`skills/create-toolset/SKILL.md`** — authoring guide for new AI-callable
  toolsets (C++ and Python), incl. documentation, error handling, tests.
- **`skills/unreal-skill/SKILL.md`** — authoring guide for in-editor Agent
  Skills (Python class or UAsset paths).

## `.manifest.d/` — byte-identity manifests

`sha256sum -c .manifest.d/audit-reference.sha256` → **12** `OK` lines, exit `0`; the
full glob `*.sha256` → **24** (same 12 files twice). Manifests are relative to `corpus/knowledge/unreal-mcp/`.

| manifest | covers | sha256 (short) |
|---|---|---|
| `audit-reference.sha256` | all **12** tracked files (SEAT-15 audit reference) | see file |
| `seat01.sha256` | `upstream/README.md` | `483693ad…46b40e` |
| `seat02.sha256` | `upstream/LICENSE` | `5b337be0…314a6` |
| `seat03.sha256` | `upstream/.claude-plugin/plugin.json` | `5aa98484…b4d44` |
| `seat04.sha256` | `upstream/hooks/hooks.json` | `259124f0…b5ebdc0c` |
| `seat05.sha256` | `upstream/hooks/unreal-context.sh` | `d3f1c871…5651fdd` |
| `seat06.sha256` | `upstream/skills/unreal-mcp/SKILL.md` | `7ef8b991…d038fa` |
| `seat07.sha256` | `upstream/skills/unreal-mcp/references/operations.md` | `dbed002b…7c3113` |
| `seat08.sha256` | `upstream/skills/unreal-mcp/references/setup.md` | `bd16206e…8a3b8a` |
| `seat09.sha256` | `upstream/skills/create-toolset/SKILL.md` | `e9d05008…c1f7b1c` |
| `seat10.sha256` | `upstream/skills/unreal-skill/SKILL.md` | `7a0af781…f435087` |
| `seat11.sha256` | `upstream/CODEOWNERS` + `upstream/.gitignore` | `653d3725…`, `0fad2f57…` |

Observed output of `sha256sum -c .manifest.d/audit-reference.sha256` (12 lines, all `OK`; the `*.sha256` glob prints 24 — the same 12 paths, each covered twice):

```
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

## `executability/` — 13 subsystem verdict cards

One card per editor subsystem, mirroring the domains in `upstream/README.md`
under *What's Available*. Each card carries a verdict labeled exactly one of
`verified-here` | `static-only` | `unproven-runtime`, with the evidence behind
it. This index does **not** restate the labels: the binding verdict and its
evidence live in each card, and only the card is authoritative. Read the card,
not this table.

| # | card path | subsystem (per `upstream/README.md` → *What's Available*) |
|---|---|---|
| 1 | `executability/actors-scene.md` | Actors and Scene — spawn/transform/inspect/delete, components, outliner folders |
| 2 | `executability/blueprints.md` | Blueprints — create, edit graphs, nodes, pins, variables, compile |
| 3 | `executability/assets-content.md` | Assets and Content — find/load/save/move/duplicate, Data/Curve/String Tables |
| 4 | `executability/materials.md` | Materials — material graphs, material instances |
| 5 | `executability/meshes-textures.md` | Meshes and Textures — static/skeletal meshes, LODs, collisions, Nanite, sockets, bones |
| 6 | `executability/animation-controlrig.md` | Animation — Control Rigs, State Trees, Behavior Trees |
| 7 | `executability/sequencer.md` | Sequencer — Level Sequences, keyframes, cameras, Control Rig, FBX I/O |
| 8 | `executability/vfx-niagara-dataflow.md` | VFX — Niagara systems, Dataflow graphs |
| 9 | `executability/ui-umg-slate.md` | UI — UMG widget blueprints, Slate automation |
| 10 | `executability/gameplay-gas.md` | Gameplay — gameplay tags, GAS state, Game Feature Plugins, physics assets |
| 11 | `executability/testing-automation.md` | Testing — discover/run/inspect C++ automation tests |
| 12 | `executability/editor-general.md` | Editor — screenshots, camera, selection, content browser, log inspection |
| 13 | `executability/scripting-programmatic.md` | Scripting — batch tool calls into one Python script (`execute_tool_script`) |

Two caveats on the card set, both observed here:

- **Cards are authored by other seats and land concurrently**, so a card may be
  absent at the moment you read this index; the table is the intended set, not a
  guarantee that all 13 files exist yet. Enumerate what is actually present with
  `ls executability/` rather than trusting a count written into this file — the
  directory grows as sibling seats land their cards, and any snapshot here goes
  stale within minutes.
- **A card's label is set by that card's author from that card's own evidence.**
  A card that only reads vendored text and runs a local static check is expected
  to be `static-only`; a card whose claims need the live editor is expected to be
  `unproven-runtime`. Neither the expectation nor this index overrides the card.

## `PROVENANCE.md` and `adaptation-kimi.md`

Both are authored by other seats and are forward references from this index; if
either is absent when you read this, the seat has not landed it yet.

- **`PROVENANCE.md`** — the provenance manifest: upstream repo + pinned commit,
  clone/verify commands, and the per-file hash table. Authoritative record of
  where this content came from.
- **`adaptation-kimi.md`** — the Claude→Kimi adaptation table plus the
  proven/unproven verification policy. Each row carries a resolvable source
  pointer (a path and line/section in this subtree). Maps Claude Code plugin
  concepts (`/plugin` marketplace install, `CLAUDE_PLUGIN_ROOT`, harness
  `.claude/skills/`) onto the Kimi Code equivalents, and marks which mappings
  are proven here versus unproven.

## Reproducing the checks

From `corpus/knowledge/unreal-mcp/`:

```sh
# 1. Byte-identity of all 12 vendored files (expect all OK, exit 0)
sha256sum -c .manifest.d/audit-reference.sha256
sha256sum -c .manifest.d/*.sha256

# 2. Static parse of the vendored JSON (expect jq to succeed)
jq -e . upstream/.claude-plugin/plugin.json upstream/hooks/hooks.json

# 3. Static lint of the vendored bash hook (informational)
shellcheck upstream/hooks/unreal-context.sh

# 4. Confirm the pinned commit matches upstream
git -C /tmp/ue-skills-ref rev-parse HEAD   # a6aa73ada02a9fb1f5415bec491f9942c519b297
```

Checks 1–2 establish byte-identity and well-formedness only. They say nothing
about whether the plugin loads, whether any MCP tool works, or whether any
editor behavior described upstream is real — all of which are `unproven` here.
