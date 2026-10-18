# Verdict Card — Materials (material graphs, material instances)

**Subsystem:** Materials — material graph authoring and Material Instance configuration
**Label:** `static-only`
**Seat:** SEAT-34 EXEC
**Card 4 of the 13-subsystem set (C2)**
**Upstream pin:** `EpicGames/unreal-engine-skills-for-claude-code-plugin` @ `a6aa73ada02a9fb1f5415bec491f9942c519b297`
**Vendored at:** `corpus/knowledge/unreal-mcp/upstream/`
**Label basis:** every fact below is a document claim read from the vendored bytes (or from the pinned repository's own reachable history); no Material tool was ever executed, because no editor exists on this host. Nothing here has been observed at runtime.

---

## 1. Why this label, in one line

The pinned tree names the Materials toolset **once**, as an example in a `description:` string, and specifies nothing about it; the only Material-specific surface the repository ever published — two toolset summaries and a four-step instance workflow — was **deleted upstream before the pin**. A reader can learn that Materials capability is claimed to exist and that `MaterialTools` / `MaterialInstanceTools` are the name shapes, but cannot call them, type them, or predict their return.

## 2. Exhaustive mention sweep (the whole Materials surface in the pinned tree)

Command actually run, from `corpus/knowledge/unreal-mcp/upstream/`:

```
$ grep -rniE "material" . | wc -l
8
$ grep -rniE "material" . | cut -d: -f1 | sort | uniq -c
      1 ./.claude-plugin/plugin.json
      2 ./README.md
      1 ./skills/create-toolset/SKILL.md
      1 ./skills/unreal-mcp/references/operations.md
      3 ./skills/unreal-mcp/SKILL.md
```

**8 mentions, 5 files, 0 signatures.** The whole vendored corpus is 1022 lines (`find . -type f -exec wc -l {} +` over all 12 files), so Materials is ~0.8% of the vendored text by line, and all of it is prose.

Command actually run, for tool-name-shaped tokens:

```
$ grep -rnoE "[A-Za-z]+Tools(et)?\.[A-Za-z_]+" . | sort -u
./README.md:90:ProgrammaticToolset.execute_tool_script
./skills/create-toolset/SKILL.md:234:LiveCodingToolset.CompileLiveCoding
./skills/create-toolset/SKILL.md:360:MyToolset.find_things
./skills/create-toolset/SKILL.md:365:MyToolset.find_things
./skills/create-toolset/SKILL.md:371:MyToolset.find_things
./skills/unreal-mcp/references/operations.md:49:LiveCodingToolset.CompileLiveCoding
./skills/unreal-mcp/references/operations.md:50:AIAssistantToolset.GetDockedContext
./skills/unreal-mcp/SKILL.md:16:BlueprintTools.create
./skills/unreal-mcp/SKILL.md:16:SequencerTools.create_level_sequence
./skills/unreal-mcp/SKILL.md:31:LiveCodingToolset.CompileLiveCoding
./skills/unreal-mcp/SKILL.md:42:AgentSkillToolset.ListSkills
./skills/unreal-mcp/SKILL.md:43:AgentSkillToolset.GetSkills
```

Twelve tool-name-shaped tokens corpus-wide, and **not one of them is a Material tool**. There is no `MaterialTools.<anything>` and no `MaterialInstanceTools.<anything>` in the pinned tree. Confirming directly:

```
$ grep -rn "MaterialTools\." .
(no output)
$ grep -rc "MaterialInstanceTools" README.md skills/unreal-mcp/SKILL.md \
    skills/unreal-mcp/references/operations.md skills/create-toolset/SKILL.md
README.md:0
skills/unreal-mcp/SKILL.md:0
skills/unreal-mcp/references/operations.md:0
skills/create-toolset/SKILL.md:0
```

The token `MaterialInstanceTools` does not occur in the pinned tree at all. `MaterialTools` occurs exactly once — see F5 — and it is an *example name in a trigger description*, not a call site.

## 3. Static-only facts, each with a resolvable pointer

Paths are relative to `corpus/knowledge/unreal-mcp/upstream/`. Line numbers verified against the vendored bytes with `grep -n` / `sed -n`.

### 3.1 The capability claim (all of it)

| # | Fact | Pointer |
|---|---|---|
| F1 | Capability is asserted as a flat bullet: "**Materials** - author material graphs, create and configure material instances". This is the **entire** functional description of the subsystem in the pinned corpus. | `README.md:103` |
| F2 | The same claim is repeated in the top-level inventory: "Hundreds of tools ... across 30+ toolsets: actors, blueprints, materials, Niagara, ..." | `README.md:3` |
| F3 | Third copy of the claim, in plugin metadata (machine-readable, version `3.1.1`). | `.claude-plugin/plugin.json:4` |
| F4 | Fourth copy, in the skill body: "The server exposes hundreds of tools across 30+ toolsets (actors, blueprints, materials, Niagara, ...)". | `skills/unreal-mcp/SKILL.md:8` |
| F5 | The **only** occurrence of the concrete token `MaterialTools` in the pinned tree: a list of toolsets that `create-toolset` may extend — "`BlueprintTools`, `StaticMeshTools`, `ObjectTools`, `LevelTools`, or `MaterialTools`". Confirms the name exists; gives no members. | `skills/create-toolset/SKILL.md:3` |

Note on F1–F5: these are four repetitions of a single unsupported sentence. The corpus never expands the Materials claim anywhere.

### 3.2 Triggering (when the agent is told to reach for Materials at all)

| # | Fact | Pointer |
|---|---|---|
| F6 | The skill triggers on the asset prefixes `M_` (Material) and `MI_` (Material Instance) — the only Material-specific trigger signals, listed among `BP_`, `WBP_`, `NS_`, `CR_`, `SK_`, `SM_`, `ABP_`. | `skills/unreal-mcp/SKILL.md:3` |
| F7 | The same description carries the verb form: "create or edit a Blueprint/Widget/**Material**/Niagara/Control Rig/Sequencer/Behavior Tree/GAS ability". | `skills/unreal-mcp/SKILL.md:3` |
| F8 | Explicit skip condition: unrelated uses of the words "blueprint"/"sequencer"/"widget" must not trigger the skill. A disambiguation rule; the word "material" is *not* in the skip list, so `M_`/`MI_` are the operative signals. | `skills/unreal-mcp/SKILL.md:3` |

There is **no** Material-specific workflow, step list, or worked example anywhere in the pinned corpus. Compare Blueprints, where `SKILL.md:33` at least names a Blueprint compile failure mode (see §3.4 F13); Materials has no equivalent beyond a shared warning.

### 3.3 The dispatch contract (how a Material call would be addressed)

| # | Fact | Pointer |
|---|---|---|
| F9 | Toolset tools are **not** in `tools/list`. "Tool names like `BlueprintTools.create` or `SequencerTools.create_level_sequence` are **not in `tools/list`**. They are dispatched server-side through `call_tool`". The same rule would govern any `MaterialTools.*` name. | `skills/unreal-mcp/SKILL.md:16` |
| F10 | The intended first move is discovery, not a memorized call: call `list_toolsets`, then `describe_toolset` on the candidate "to read their tool schemas", then invoke via `call_tool` with `toolset_name`, `tool_name`, `arguments`. **Signatures are knowable only from a live editor**, never from this corpus. | `skills/unreal-mcp/SKILL.md:20`, `skills/unreal-mcp/SKILL.md:21` |
| F11 | Tool search is on by default: `tools/list` returns only the three meta-tools. Setting `bEnableToolSearch=False` registers every toolset tool as a native MCP tool upfront — the switch that would make `MaterialTools.*` names visible in `tools/list`. | `README.md:82`, `references/operations.md:18`, `references/operations.md:19` |
| F12 | A toolset that seems missing (the doc's own example is `NiagaraTools`) is repaired with `ModelContextProtocol.RefreshTools`; if still missing, the toolset's **plugin** may not be enabled in the `.uproject`. Same procedure would govern a missing Materials toolset. | `references/operations.md:13`, `references/operations.md:48` |

### 3.4 Behavioral hazards that name Materials

| # | Fact | Pointer |
|---|---|---|
| F13 | "**Always check the result.** Blueprint compilation, widget creation, **material edits**: many tools return a status that flips between success and failure with no exception thrown on the wire. Read the response before moving on. Treat anything that isn't an explicit success as a stop." Material edits are named as a silent-failure surface, with no detail on what the status looks like. | `skills/unreal-mcp/SKILL.md:33` |
| F14 | The Claude Code tab must be **docked inside an asset editor (Blueprint, Material, etc.)** for `AIAssistantToolset.GetDockedContext` to return anything. The only place a Material **asset editor** is treated as a first-class UI surface. | `references/operations.md:50` |
| F15 | MCP edits are "not always undoable, especially across compilation boundaries" — and `MaterialTools` recompiles shaders (per the deleted summary, §4 F19), so a Material edit can cross that boundary. Save before and after any bulk change. | `skills/unreal-mcp/SKILL.md:30` |
| F16 | Tool calls hang or fail confusingly while C++ or shader compilation is in flight. `LiveCodingToolset.CompileLiveCoding` is the *only* compile tool named in the corpus, and it is the **C++** path, not the shader/material compile path. | `skills/unreal-mcp/SKILL.md:31`, `references/operations.md:49` |
| F17 | Concurrency: serialize dependent calls and mutations that can affect the same asset. Multiple agents may share one editor and conflict — directly relevant to multi-node material graph edits. | `skills/unreal-mcp/SKILL.md:32`, `references/operations.md:51` |
| F18 | PIE changes editor-only behavior: "asset creation in particular". A Material or Material Instance creation call made while Play-in-Editor is active can behave differently. | `skills/unreal-mcp/SKILL.md:34` |

### 3.5 The deleted Materials surface — reachable from the pin, absent from the tree

The pinned repository **once** documented Materials concretely, then removed that documentation in two commits that are both ancestors of the pin. Both artifacts remain reachable from the pinned clone, so they are citable — but they are **not part of the vendored corpus**, and the live editor would not be governed by them.

Verification that these are in the pin's own history:

```
$ git cat-file -e eaf2e838a259fb41be10309f9373bca8778607c5 && echo "blob REACHABLE"
blob REACHABLE
$ git merge-base --is-ancestor 823f598 a6aa73a && echo "deletion is in pinned history"
deletion is in pinned history
```

**(a) `skills/unreal-mcp/references/toolsets.md` — a per-toolset capability reference, deleted before the pin.**

```
$ git rev-parse 823f598^:skills/unreal-mcp/references/toolsets.md
eaf2e838a259fb41be10309f9373bca8778607c5
$ git cat-file -s eaf2e838a259fb41be10309f9373bca8778607c5
8306
$ git show 823f598^:skills/unreal-mcp/references/toolsets.md | sha256sum
1b184bbb31836319ef50ad0661306f7e22bbcf19bf71bed70b6a58d60da69cec  -
```

Its `## Materials` section, lines 31–35 of that blob:

| # | Fact | Pointer |
|---|---|---|
| F19 | "**MaterialTools** authors Materials: add expression nodes (constants, parameters, texture samples, math ops), connect expressions to each other and to material outputs, delete expressions, auto-layout, and recompile shaders." The fullest description of the material-graph surface that ever existed upstream. | `toolsets.md:33` @ `823f598^` (blob `eaf2e838`) |
| F20 | "**MaterialInstanceTools** creates and edits Material Instances: set/get scalar, vector, texture, and static switch parameters. List exposed parameters, change parent, and clear overrides." | `toolsets.md:35` @ `823f598^` (blob `eaf2e838`) |

**(b) `skills/unreal-mcp/SKILL.md` — a four-step Material Instance workflow, deleted before the pin.**

Present from the initial commit through `be8c183`; dropped at `6514615`. Blob carrying it: `f3a6d614d37d6e1f42e443549d71867d3259668b` (`be8c1833d4e3b8412c5dfde9d0a1e67bb2a671d1:skills/unreal-mcp/SKILL.md`), lines 68–73:

| # | Fact | Pointer |
|---|---|---|
| F21 | `### Material Instances` — 1. `MaterialInstanceTools.create` against an existing parent material. 2. `MaterialInstanceTools.list_parameters` to see what is exposed. 3. `MaterialInstanceTools.set_scalar_parameter` / `set_vector_parameter` / `set_texture_parameter` for the values you want. 4. Assign the instance to meshes via `ObjectTools.set_properties`. | `SKILL.md:68-73` @ `be8c183` (blob `f3a6d614`) |

Exact observed output of that block:

```
$ git show be8c1833d4e3b8412c5dfde9d0a1e67bb2a671d1:skills/unreal-mcp/SKILL.md | sed -n '68,73p'
### Material Instances

1. `MaterialInstanceTools.create` against an existing parent material.
2. `MaterialInstanceTools.list_parameters` to see what is exposed.
3. `MaterialInstanceTools.set_scalar_parameter` / `set_vector_parameter` / `set_texture_parameter` for the values you want.
4. Assign the instance to meshes via `ObjectTools.set_properties`.
```

**History of the two deletions (both ancestors of the pin):**

| # | Fact | Command output |
|---|---|---|
| F22 | `references/toolsets.md` was added at `74dba95` (2026-04-21, "Strengthen skill description and split Toolset Reference into `references/`."), blob `e3ced5941a5a2161c2ad10eb7d1782eb2587904e`; last non-removal touch `cd1365a` (blob `eaf2e838`); removed at `823f598` "Remove/references toolsets.md (#19)" (2026-05-05). | `git log --oneline --all -- skills/unreal-mcp/references/toolsets.md` → `823f598`, `cd1365a`, `74dba95` |
| F23 | The removal commit also deleted the `SKILL.md` pointer to that file: "If you don't know which toolset owns a capability, consult `references/toolsets.md`". | `git show 823f598 -- skills/unreal-mcp/SKILL.md` |
| F24 | The `### Material Instances` workflow existed from the **initial commit** `5a73624` (2026-04-07) to `be8c183` (2026-05-19) and was dropped at `6514615` "Trim toolset-specific skill content and drop the Agent Skill toolsets field." (2026-06-01). | `git log -1 --format='%H%n%ci%n%s' 6514615` → `65146159d6a2fffcedcefa7662b942361dbbf461`, `2026-06-01 22:16:17 -0700` |
| F25 | Across **every** revision in the repository's history, `MaterialTools.<method>` occurs **zero** times: `git grep -n -E "MaterialTools\." $(git rev-list --all) \| wc -l` → `0`. The only Material tool names ever published are the five `MaterialInstanceTools.*` methods in F21. | see command above |

So: the pinned tree's Materials surface is a single unsourced bullet plus one example token; the deleted history adds two capability paragraphs and five method names for Material *Instances*, and **never** names a single `MaterialTools` method.

## 4. What is conspicuously absent (the gap that forces `static-only`)

Searched for and **not found** anywhere in the 1022 vendored lines:

- Any `MaterialTools` or `MaterialInstanceTools` method name (`grep -rnoE "[A-Za-z]+Tools(et)?\.[A-Za-z_]+"` → 12 hits corpus-wide, none Material).
- Any parameter list, return type, or JSON schema for a Material tool.
- Any representation of a **material expression**, an **expression graph**, or a **material output**. `grep -rniE "expression" .` → **no output**; `grep -rniE "graph" .` → 4 hits, all in capability bullets (`README.md:101`, `README.md:103`, `README.md:107`, `create-toolset/SKILL.md:18`), none defining a graph type. The words are specified only in the deleted `toolsets.md:33` (F19), never in the vendored corpus.
- Any statement of what a material shader recompile returns, or how a Material edit failure is surfaced beyond the generic "check the result" warning (F13).
- Any Material Instance parameter **type** contract in the vendored corpus. The deleted summary lists them in prose ("scalar, vector, texture, and static switch parameters", F20) and the deleted workflow lists three setter names (F21); neither is a schema, and neither is vendored.
- Any toolset member count. "Hundreds of tools ... 30+ toolsets" (`README.md:3`) is aggregate and unverifiable from here.
- Any Material-specific troubleshooting row. The operations matrix has rows for missing toolsets, port collisions, hangs, and empty docked context, but none for Materials.

Consequence: the corpus is sufficient to **route** a Material request (F6–F8, F9–F12) and to **warn** about it (F13–F18), and insufficient to **execute** it. Hence `static-only`, not `verified-here`.

## 5. Why not `verified-here`, and why not `unproven-runtime`

- **Not `verified-here`:** no Material tool call was made. No editor is installed (§6), so no `describe_toolset` result exists to cite. Nothing about Material behavior was observed.
- **Not `unproven-runtime`:** that label would assert a real, identified runtime path that merely went untested. Here the path is not identified — the signatures are unknown by construction, because the corpus defers them to a live `describe_toolset` (F10), and the one surface that ever named Material methods was deleted upstream (F19–F21). The correct statement is weaker: the subsystem is documented as existing and is not specified. That is `static-only`.

The distinction matters for calibration: `unproven-runtime` invites "someone just needs to run it"; `static-only` correctly says "running it is necessary *and* the artifacts to run it against are not in hand."

## 6. Host receipts (re-derived this round, not quoted)

All commands run on this host; observed output recorded.

| Check | Command | Observed |
|---|---|---|
| Editor binary absent | `which UnrealEditor UnrealEditor-Cmd` | `which: no UnrealEditor in (...)`; `which: no UnrealEditor-Cmd in (...)` |
| Engine tree absent | `ls -d /opt/UnrealEngine /opt/unreal-engine ~/UnrealEngine` | `No such file or directory` ×3 |
| No MCP server listening | `ss -ltnp \| grep -E ':8000'` | no output — no listener on 8000 |
| No generated client config | `ls -la .mcp.json` (lane root) | `No such file or directory` |
| No Unreal project in lane | `find . -name '*.uproject'` | no output |
| Host capacity | `nproc` / `free -g` / `df -h /` | 32 cores; 30G RAM (`Mem: 30`); 780G free on `/` (`930G 133G 780G 15%`) |
| Toolchain | `command -v jq python3 node shellcheck docker` | all present; `shellcheck --version` → `version: 0.11.0` |
| Engine fetch blocked (SSH) | `curl -s "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=unreal-engine" \| grep -n "git@github.com\|git ls-remote"` | `280:  if ! git ls-remote git@github.com:EpicGames/UnrealEngine &>/dev/null; then`; `327:` and `336:` — `git clone --depth=1 --branch=${pkgver}-release git@github.com:EpicGames/UnrealEngine` |
| AUR version probed | same PKGBUILD | `pkgver=5.8.2`, `pkgrel=1` |
| Epic repo unreachable | `gh auth status`; `git ls-remote https://github.com/EpicGames/unreal-engine` | `✓ Logged in to github.com account VeigaPunk`; `remote: Repository not found.` / `fatal: repository ... not found` |
| Upstream pin confirmed | `git -C /tmp/ue-skills-ref rev-parse HEAD` | `a6aa73ada02a9fb1f5415bec491f9942c519b297` — equals the pin; `git status --porcelain` empty (clean) |
| Vendoring byte-identical | per-file `sha256sum` list of `/tmp/ue-skills-ref` vs `upstream/`, then `diff` | `files ref=12 ven=12`; `diff` empty; `VERDICT: all vendored bytes identical to pinned clone`; aggregate digest of the 12 hash lines `16dfaa66647c40cfe0420ddef9e385378e1b7f2f90f5e4790236f9a619743963` |

Per-file hashes of the vendored corpus (for cross-checking against `.manifest.d/seat01…seat11.sha256`):

```
5aa984848f0fd48c94394651c66f5b200ee1e2583d8df8caeecc22bb550b4d44  .claude-plugin/plugin.json
653d372559bee26d75fcee330142276c7d9cbccba214ef008ff5392b99550f0f  CODEOWNERS
0fad2f57a9fac18ab4a66ac23d44485544bdabb5057c99b684d485f27b81e538  .gitignore
259124f0631b7d4b92e9e744003e8798b910c00dac201656b97906b3b5ebdc0c  hooks/hooks.json
d3f1c871cd4edd5210ee2f448c403e1a441e569a14a1405d1a3f199c65651fdd  hooks/unreal-context.sh
5b337be051359edcdec510103aee15f5f870efb38b6d42eecd685dc3582314a6  LICENSE
483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e  README.md
e9d050087f36de51f7eeef49adb0ba9ebc603b65f74f475bc53a6debfc1f7b1c  skills/create-toolset/SKILL.md
dbed002b4a46ab104274a31eb6682c3d277ce669216d0378df709f51567c3113  skills/unreal-mcp/references/operations.md
bd16206ea142dc9cc1950b88af526a3137072ea152c5662e8549d21bc18a3b8a  skills/unreal-mcp/references/setup.md
7ef8b991a82f591c5776bb5fa167c2bc2269fd00338ed3e8534eacc551d038fa  skills/unreal-mcp/SKILL.md
7a0af781c458c7d192d6b23c16b5737922dc482470e2e4ef617bcda80f435087  skills/unreal-skill/SKILL.md
```

The AUR PKGBUILD requires **SSH** access to the private `EpicGames/UnrealEngine` repository (lines 280, 327, 336), which requires an Epic account linked to GitHub. That link is operator-owned and is not in place: the authenticated GitHub account is `VeigaPunk`, and the Epic repo answers `Repository not found`. Therefore the engine cannot be built here, and the prerequisites in F26–F28 can never be satisfied on this host as configured.

## 7. Unlock condition

The label flips from `static-only` to `unproven-runtime` / `verified-here` only through this chain, in order:

1. **Operator action (blocking, not automatable here):** link the Epic Games account to the GitHub account so `git@github.com:EpicGames/UnrealEngine` becomes reachable. Nothing downstream can be attempted before this.
2. Build or install the engine — e.g. the AUR `unreal-engine` package (`pkgver=5.8.2`, the PKGBUILD probed in §6).
3. Create/open a `.uproject` with **both** `ModelContextProtocol` and `AllToolsets` enabled. `AllToolsets` is editor-only with `EnabledByDefault` off and must be enabled explicitly; without it the server starts and exposes no tools — Materials included. | `references/setup.md:14`, `references/setup.md:24`, `references/setup.md:31`, `README.md:17`
4. Launch the editor and start the server: `ModelContextProtocol.StartServer` | `references/operations.md:11`, or `bAutoStartServer=True` | `references/setup.md:45`, `README.md:18`.
5. Generate the client config: `ModelContextProtocol.GenerateClientConfig ClaudeCode` | `references/setup.md:61`, producing `.mcp.json` at the location matching the build kind (`references/setup.md:63-66`). Default endpoint is `localhost:8000`, path `/mcp` (`README.md:70`, `references/setup.md:75`).
6. **First real verification, the cheapest possible:** `list_toolsets`, then `describe_toolset` on `MaterialTools` **and** `MaterialInstanceTools`. These two calls convert the entire §4 gap — signatures, parameter types, return shapes, and whether `MaterialInstanceTools` exists at all — from unknown to known. Nothing cheaper is available: the corpus itself defers signatures to `describe_toolset` (F10), and the only historical Material method names (F21) are from a deleted, five-revisions-stale revision.
7. Only then can any claim about material graphs, expression nodes, connections, auto-layout, shader recompile, or instance parameters be tested, and each would still need its own `call_tool` receipt before it could be called verified.

Until step 1 happens, every Materials claim in this card remains a document claim. **No Material tool has been executed on this host, and none can be.**

## 8. Cross-references

- Upstream corpus (vendored, byte-identical): `corpus/knowledge/unreal-mcp/upstream/`
- Per-file hashes: `corpus/knowledge/unreal-mcp/.manifest.d/seat01.sha256` … `seat11.sha256`
- Round unknowns map: `reports/round-101/r101-unknowns-map.md`
- Domain census probe (README "What's Available", 13 domains): `reports/round-101/probes/toolset-census.md` — its Materials row is `README.md:103` / toolset `MaterialTools` / `skills/create-toolset/SKILL.md:3`
- Adjacent subsystems dissected this round: `reports/round-101/bpy-dissection.md`, `reports/round-101/navagent-dissection.md`
- Sibling cards in the 13-subsystem set: `corpus/knowledge/unreal-mcp/executability/` (peers are filed by their own seats during r101; this card claims only its own number, 4)
