# SEAT-25 PROBE — Toolset Domain Census (README "What's Available")

**Round:** r101 · **Lane:** game-dev-3d shokunin · **Axis served:** coverage (lowest non-retired)
**Upstream:** `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin`
**Pinned SHA:** `a6aa73ada02a9fb1f5415bec491f9942c519b297` (verified in-place, see E1)
**Source of truth for this census:** `README.md` §`What's Available`, lines 96–112.

---

## E0 — Provenance / clone verification

Command actually run and observed output:

```
$ ls -la /tmp/ue-skills-ref && git -C /tmp/ue-skills-ref rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
```

Pre-existing clone matched the pinned SHA, so no fresh clone to `/tmp/r101work` was needed.
Supporting receipts:

```
$ git -C /tmp/ue-skills-ref log -1 --format='%H%n%ci%n%s'
a6aa73ada02a9fb1f5415bec491f9942c519b297
2026-09-17 13:28:32 +1200
[MCP] Permit safe concurrent tool calls

$ git -C /tmp/ue-skills-ref status --porcelain
(empty — working tree clean)

$ git -C /tmp/ue-skills-ref remote -v
origin  https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin (fetch)
origin  https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin (push)
```

Plugin identity, from `.claude-plugin/plugin.json`:

```
$ cat /tmp/ue-skills-ref/.claude-plugin/plugin.json
{ "name": "unreal-engine-skills-for-claude-code", "version": "3.1.1",
  "author": { "name": "Thomas Mansencal", "email": "thomas.mansencal@epicgames.com" },
  "license": "MIT" }
```

---

## E1 — Domain count

The README section is bounded and the row count is exact:

```
$ grep -n "^## What's Available" /tmp/ue-skills-ref/README.md
96:## What's Available

$ wc -l /tmp/ue-skills-ref/README.md
112 README.md          # section body ends at line 112 = EOF

$ awk 'NR>=100 && NR<=112' /tmp/ue-skills-ref/README.md | grep -c '^- \*\*'
13
```

**Result: exactly 13 bullet domains**, matching the 13 expected rows. No 14th domain exists
anywhere in the section.

---

## Census table — 13 toolset domains

Capabilities text is the README bullet text verbatim after the em-dash, split on `;` into
capability clauses. Nothing is paraphrased; see E2 for the raw extraction command.

| # | Domain (README label) | README line | Capabilities (exact, clause-split) |
|---|---|---|---|
| 1 | Actors and Scene | 100 | spawn, transform, inspect, and delete actors; manage components and outliner folders |
| 2 | Blueprints | 101 | create, edit graphs, add nodes, connect pins, manage variables, compile |
| 3 | Assets and Content | 102 | find, load, save, move, duplicate assets; edit Data Tables, Curve Tables, String Tables |
| 4 | Materials | 103 | author material graphs, create and configure material instances |
| 5 | Meshes and Textures | 104 | inspect/edit static and skeletal meshes, LODs, collisions, Nanite, sockets, bones |
| 6 | Animation | 105 | build Control Rigs, inspect State Trees and Behavior Trees |
| 7 | Sequencer | 106 | create and edit Level Sequences, keyframe animation, manage cameras, Control Rig integration, FBX import/export |
| 8 | VFX | 107 | author Niagara systems and Dataflow graphs |
| 9 | UI | 108 | build UMG widget blueprints, automate Slate UI interaction |
| 10 | Gameplay | 109 | manage gameplay tags, inspect GAS state, create Game Feature Plugins, edit physics assets |
| 11 | Testing | 110 | discover, run, and inspect C++ automation tests with detailed results |
| 12 | Editor | 111 | screenshots, camera control, actor/asset selection, content browser, log inspection |
| 13 | Scripting | 112 | batch multiple tool calls into a single Python script execution |

Header context (line 98), verbatim: *"All tools are auto-discovered by Claude Code via MCP. No
manual configuration needed. Tools cover the full editor surface across these domains:"*

---

## E2 — Raw extraction command and output

```
$ grep -n "" /tmp/ue-skills-ref/README.md | sed -n '95,130p'
95:
96:## What's Available
97:
98:All tools are auto-discovered by Claude Code via MCP. No manual configuration needed. Tools cover the full editor surface across these domains:
99:
100:- **Actors and Scene** - spawn, transform, inspect, and delete actors; manage components and outliner folders
101:- **Blueprints** - create, edit graphs, add nodes, connect pins, manage variables, compile
102:- **Assets and Content** - find, load, save, move, duplicate assets; edit Data Tables, Curve Tables, String Tables
103:- **Materials** - author material graphs, create and configure material instances
104:- **Meshes and Textures** - inspect/edit static and skeletal meshes, LODs, collisions, Nanite, sockets, bones
105:- **Animation** - build Control Rigs, inspect State Trees and Behavior Trees
106:- **Sequencer** - create and edit Level Sequences, keyframe animation, manage cameras, Control Rig integration, FBX import/export
107:- **VFX** - author Niagara systems and Dataflow graphs
108:- **UI** - build UMG widget blueprints, automate Slate UI interaction
109:- **Gameplay** - manage gameplay tags, inspect GAS state, create Game Feature Plugins, edit physics assets
110:- **Testing** - discover, run, and inspect C++ automation tests with detailed results
111:- **Editor** - screenshots, camera control, actor/asset selection, content browser, log inspection
112:- **Scripting** - batch multiple tool calls into a single Python script execution
```

---

## E3 — Corroboration: toolset class names actually named upstream

The README domains are prose groupings, not literal `ToolsetRegistry` class names. The repo
names concrete toolsets elsewhere; this is the bridge between the 13 prose domains and the
actual registry surface. Command:

```
$ grep -rhoE '\b[A-Z][A-Za-z]*Tools(et)?\b|\b[A-Z][A-Za-z]*Toolset\b' \
    --include='*.md' --include='*.json' --include='*.sh' /tmp/ue-skills-ref | sort | uniq -c | sort -rn
```

Observed output:

```
     14 MyToolset            # create-toolset template placeholder — NOT a real toolset
      8 UMyToolset           # C++ template placeholder — NOT a real toolset
      4 AgentSkillToolset
      3 ObjectTools
      3 LiveCodingToolset
      3 BlueprintTools
      2 StaticMeshTools
      2 RefreshTools
      2 AssetTools
      1 SequencerTools
      1 ProgrammaticToolset
      1 NiagaraTools
      1 MaterialTools
      1 LevelTools
      1 AutomationTestToolset
      1 AIAssistantToolset
```

Real named toolsets (excluding the two template placeholders) map onto the README domains as:

| Domain | Upstream-named toolset(s) | Evidence pointer (path:line) |
|---|---|---|
| Actors and Scene | `LevelTools` | `skills/create-toolset/SKILL.md:3` |
| Blueprints | `BlueprintTools` | `skills/create-toolset/SKILL.md:3`, `skills/unreal-mcp/SKILL.md:16` |
| Assets and Content | `AssetTools` | `skills/unreal-mcp/SKILL.md:30`, `skills/create-toolset/SKILL.md:28` |
| Materials | `MaterialTools` | `skills/create-toolset/SKILL.md:3` |
| Meshes and Textures | `StaticMeshTools` | `skills/create-toolset/SKILL.md:3`, `skills/create-toolset/SKILL.md:30` |
| Animation | *(none named)* — Control Rig / State Tree toolsets unnamed | — |
| Sequencer | `SequencerTools` | `skills/unreal-mcp/SKILL.md:16` (`SequencerTools.create_level_sequence`) |
| VFX | `NiagaraTools` | `skills/unreal-mcp/references/operations.md:48` |
| UI | *(none named)* — UMG/Slate toolset unnamed | — |
| Gameplay | *(none named)* — GAS / Game Feature toolsets unnamed | — |
| Testing | `AutomationTestToolset` | `skills/create-toolset/SKILL.md:390` (`DiscoverTests`) |
| Editor | `AIAssistantToolset` | `skills/unreal-mcp/references/operations.md:50` (`GetDockedContext`) |
| Scripting | `ProgrammaticToolset` | `README.md:90` (`execute_tool_script`) |

Cross-cutting, not one of the 13 domains: `ObjectTools` (generic UObject property get/set,
reused by other toolsets — `skills/create-toolset/SKILL.md:20`, `:45`), `LiveCodingToolset`
(`CompileLiveCoding` — `skills/unreal-mcp/SKILL.md:31`, `skills/create-toolset/SKILL.md:234`,
`references/operations.md:49`), `AgentSkillToolset` (project Agent Skills, reached outside
`list_toolsets` — `skills/unreal-mcp/SKILL.md:38`, `:42`, `:43`).

Note: `ModelContextProtocol.RefreshTools` (`references/operations.md:13`, `:48`) is an editor
**console command**, not a toolset class — the `grep` in E3 matched it as `RefreshTools` only
because of the dotted suffix. It is excluded from the toolset-name column above.

**Calibration note for downstream seats:** 8 of 13 domains have at least one concrete toolset
class name pinned in-repo; 3 (Animation, UI, Gameplay) have domain prose only, and 2 of the
13 rows' wording (Animation covers Control Rig *and* State Trees/Behavior Trees; Gameplay
covers gameplay tags, GAS, Game Feature Plugins, and physics assets) are multi-toolset domains
compressed into one README bullet. Treat the 13 rows as *coverage buckets*, not as a
1:1 toolset list.

---

## E4 — Corpus integrity hashes (for C1 vendoring cross-check)

`sha256sum` over every tracked file, so a vendored copy under
`corpus/knowledge/unreal-mcp/upstream/` can be proven byte-identical:

```
$ cd /tmp/ue-skills-ref && sha256sum README.md skills/unreal-mcp/SKILL.md \
    skills/create-toolset/SKILL.md skills/unreal-skill/SKILL.md \
    skills/unreal-mcp/references/setup.md skills/unreal-mcp/references/operations.md \
    .claude-plugin/plugin.json hooks/hooks.json hooks/unreal-context.sh \
    CODEOWNERS LICENSE .gitignore
```

```
483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e  README.md
7ef8b991a82f591c5776bb5fa167c2bc2269fd00338ed3e8534eacc551d038fa  skills/unreal-mcp/SKILL.md
e9d050087f36de51f7eeef49adb0ba9ebc603b65f74f475bc53a6debfc1f7b1c  skills/create-toolset/SKILL.md
7a0af781c458c7d192d6b23c16b5737922dc482470e2e4ef617bcda80f435087  skills/unreal-skill/SKILL.md
bd16206ea142dc9cc1950b88af526a3137072ea152c5662e8549d21bc18a3b8a  skills/unreal-mcp/references/setup.md
dbed002b4a46ab104274a31eb6682c3d277ce669216d0378df709f51567c3113  skills/unreal-mcp/references/operations.md
5aa984848f0fd48c94394651c66f5b200ee1e2583d8df8caeecc22bb550b4d44  .claude-plugin/plugin.json
259124f0631b7d4b92e9e744003e8798b910c00dac201656b97906b3b5ebdc0c  hooks/hooks.json
d3f1c871cd4edd5210ee2f448c403e1a441e569a14a1405d1a3f199c65651fdd  hooks/unreal-context.sh
653d372559bee26d75fcee330142276c7d9cbccba214ef008ff5392b99550f0f  CODEOWNERS
5b337be051359edcdec510103aee15f5f870efb38b6d42eecd685dc3582314a6  LICENSE
0fad2f57a9fac18ab4a66ac23d44485544bdabb5057c99b684d485f27b81e538  .gitignore
```

`README.md` byte size: `8398` (`wc -c`). Total tracked content files (excluding `.git`):
12 (`find /tmp/ue-skills-ref -type f -not -path '*/.git/*' | wc -l`).

---

## E5 — Runtime status of this census (honest labelling)

This census is **static-only**. It was derived by reading the vendored upstream Markdown and
JSON at the pinned SHA. No Unreal Editor exists on this host (host receipt: *Unreal Editor NOT
installed*; `AllToolsets` is an editor-only plugin), so:

- The 13 rows describe what upstream **claims** the tool surface covers — not verified live
  toolset registration.
- The concrete toolset class names in E3 are names **mentioned in upstream prose**, not
  confirmed registrations. `list_toolsets` was never called; no MCP server was reachable.
- Anything asserting "these 13 domains exist as registered toolsets at runtime" is
  **unproven-on-this-host by construction** and must not be asserted downstream.

Prerequisite chain that gates any live verification (README §Prerequisites, `references/setup.md`):
`ModelContextProtocol` + `AllToolsets` plugins enabled → editor running → MCP server started
(`ModelContextProtocol.StartServer`) → `list_toolsets` returns. Every link after the first is
blocked here because the engine is not installed (AUR `unreal-engine` needs Epic SSH access;
`gh` account not Epic-linked).

---

## Row-level verdicts (per C2 labelling scheme)

| Row | Verdict | Basis |
|---|---|---|
| 13 domain rows (capabilities text) | `static-only` | Read from README lines 100–112 at pinned SHA; no editor on host |
| 12-file hash set (E4) | `verified-here` | `sha256sum` executed on clean tree at pinned SHA |
| Pinned-SHA identity (E0) | `verified-here` | `git rev-parse HEAD` == `a6aa73ada02a9fb1f5415bec491f9942c519b297` |
| Concrete toolset names (E3) | `static-only` | `grep` over upstream files; registration not exercised |
| Any `list_toolsets` / live-call claim | `unproven-runtime` | No engine, no MCP server, no editor on this host |

---

## Handoff notes

- This file is the **input** to C1's coverage claim: it fixes the 13-row domain list and the
  12-file hash set that a vendored `corpus/knowledge/unreal-mcp/upstream/` copy must match.
- `README.md` §`What's Available` is lines **96–112** and contains **exactly 13** bullets —
  use that as the C1 row-count assertion.
- Downstream depth work should not assume the 13 prose domains are 13 toolsets; E3 shows
  multi-toolset domains (Animation, Gameplay) and unnamed domains (Animation, UI, Gameplay).
- No files outside this seat's declared path were created or modified. `LOG.md`,
  `SCORECARD.md`, `SHONEN.md`, `SKILL.md`, `PROVINCE.md`, and the 3 pre-existing
  `reports/round-101/` files were untouched.
