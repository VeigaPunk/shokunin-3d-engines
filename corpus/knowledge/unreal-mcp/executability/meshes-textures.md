# Verdict Card — Meshes and Textures (static/skeletal mesh inspect/edit, LODs, collisions, Nanite, sockets, bones)

**Subsystem:** Meshes and Textures (`StaticMeshTools` named upstream; skeletal-mesh toolset unnamed)
**Label:** `static-only`
**Seat:** SEAT-35 EXEC
**Card 5 of the 13-subsystem set (C2)**
**Upstream pin:** `EpicGames/unreal-engine-skills-for-claude-code-plugin` @ `a6aa73ada02a9fb1f5415bec491f9942c519b297`
**Vendored at:** `corpus/knowledge/unreal-mcp/upstream/`
**Label basis:** every fact below is a document claim read from the vendored bytes; no mesh or texture tool was ever executed, because no editor exists on this host. Nothing here has been observed at runtime.

---

## 1. Why this label, in one line

The whole subsystem occupies **four lines** of 1022 vendored lines (0.39%): it names **one** toolset (`StaticMeshTools`) with **zero** named members, and every capability it advertises — Nanite, LODs, collisions, sockets, bones — is stated once, in a single bullet, and never developed. The corpus is sufficient to **route** a mesh request and insufficient even to name a function.

**Where this sits among the 13 domains, measured rather than asserted.** Three comparative probes were run over the vendored tree; all are reproduced in §2.5 so the numbers can be re-derived. None of them yields a superlative for this domain, and none is needed: the label rests on the absence of a callable name, not on a ranking.

- *Not* the thinnest domain by mention count. Measured lines matching each domain's own bullet nouns: Sequencer 1, Materials 2, **Meshes and Textures 2**, Actors 3, UI 3, Gameplay 3, Scripting 3, Testing 5, Assets 6, Animation 6, VFX 6, Editor 6, Blueprints 7. Materials and Sequencer are equally thin or thinner by this measure.
- *Not* uniquely hapax. A one-occurrence count is the norm, not the exception, across this corpus: `material graph` 1, `material instance` 1, `level sequence` 1, `keyframe` 1, `FBX` 1, `UMG` 1, `dataflow` 1, `gameplay tag` 1, `physics asset` 1, `data table` 1 — each occurs exactly once, like `Nanite`, `LOD`, `socket` and `bone`.
- **The distinction, stated precisely.** **9** of the 13 domains name **zero** tool methods anywhere in the corpus (Actors and Scene, Assets and Content, Materials, Meshes and Textures, Animation, VFX, UI, Gameplay, Testing); only 4 do (Blueprints, Sequencer, Editor, Scripting). Among those 9, Meshes and Textures advertises **6** capability clauses:

  | zero-method domain | capability clauses | toolset named? |
  |---|---|---|
  | VFX | 1 | `NiagaraTools` |
  | Materials | 2 | `MaterialTools` |
  | Animation | 2 | — |
  | UI | 2 | — |
  | Testing | 3 | `AutomationTestToolset` |
  | Gameplay | 4 | — |
  | Actors and Scene | 5 | `LevelTools` |
  | **Meshes and Textures** | **6** | **`StaticMeshTools`** |
  | Assets and Content | 8 | `AssetTools`, `ObjectTools` |

  So Meshes and Textures is **second** on this measure, behind Assets and Content (8 clauses). It is not the maximum, and this card does not claim it is. What *is* exact and load-bearing is the conjunction at the bottom of the table: **6 advertised capabilities, a named toolset, and not one callable member name** — the corpus tells a reader that mesh capability exists and cannot name a single function to invoke it. That is the whole basis for `static-only`.

## 2. Exhaustive mention sweep (the whole Meshes-and-Textures surface)

Command actually run, from `corpus/knowledge/unreal-mcp/upstream/`:

```
$ grep -rniE 'mesh|texture|lod|nanite|socket|bone|skeleton|collision' . | cut -d: -f1,2 | sort | uniq -c
      1 ./README.md:104
      1 ./skills/create-toolset/SKILL.md:3
      1 ./skills/create-toolset/SKILL.md:30
      1 ./skills/unreal-mcp/references/operations.md:3
      1 ./skills/unreal-mcp/SKILL.md:3
```

**5 matching lines, 4 files, 0 signatures.** One of those five is a false positive on the keyword alone:

```
$ grep -n 'collision' skills/unreal-mcp/references/operations.md
3:Read this when something is misbehaving with the MCP server (tools missing, port collision, stale tool registry), or when you need a non-default configuration.
```

`operations.md:3` is a **port** collision, not a mesh collision — it is the troubleshooting intro, and contains no mesh content. Dropping it, the genuine mesh/texture surface is exactly **four lines**:

```
$ grep -rniE 'mesh|texture|lod|nanite|socket|bone|skeleton' . | cut -d: -f1,2
./README.md:104
./skills/unreal-mcp/SKILL.md:3
./skills/create-toolset/SKILL.md:3
./skills/create-toolset/SKILL.md:30
```

Four lines out of **1022** total vendored lines (12 files; 884 of them Markdown) — **0.39%** of the corpus by line. Every one of the four is prose.

Per-keyword occurrence counts (`grep -rio … | wc -l` over all 12 files):

| token | occurrences | where |
|---|---|---|
| `Nanite` | **1** | `README.md:104` only |
| `LOD` / `LODs` | **1** | `README.md:104` only |
| `socket` / `sockets` | **1** | `README.md:104` only |
| `bone` / `bones` | **1** | `README.md:104` only |
| `texture` | **1** | `README.md:104` only |
| `SkeletalMesh` (identifier form) | **0** | — (only lowercase prose "skeletal mesh") |
| `SkeletalMeshTools` | **0** | — |
| `StaticMeshTools` | **2** | `create-toolset/SKILL.md:3`, `:30` |
| `mesh` (any case) | **6** | the 4 lines above, README:104 carrying two |

The distinctive capabilities each appear **once**: Nanite, LODs, sockets and bones occur exactly one time in the whole vendored tree, all inside the single capability bullet, and are never mentioned again in any skill, reference, hook, or manifest. There is no second sentence anywhere that develops any of them.

**Caveat, measured:** one-occurrence is *not* a distinguishing property of this domain — it is the corpus's house style. A cross-domain sweep of distinctive nouns gives `material graph` 1, `material instance` 1, `level sequence` 1, `keyframe` 1, `FBX` 1, `UMG` 1, `dataflow` 1, `gameplay tag` 1, `physics asset` 1, `data table` 1, `curve table` 1. Only `niagara` (6), `control rig` (6), `automation test` (5), `slate` (3), `GAS` (3), `state tree` (3) and `outliner` (2) rise above one. So "every capability is a hapax" is evidence of an under-specified corpus in general, not of Meshes and Textures being specially thin. The domain-specific claim is in §1 and §2.5: 6 advertised capabilities with no callable member name.

### 2.5 Comparative position among the 13 domains (measured)

Three probes, all run over the vendored tree. None of them yields a superlative for this domain; they are here to keep §1's comparative statements honest and re-derivable.

**(a) Claimed capabilities per named method.**

```
$ awk 'NR>=100 && NR<=112' README.md | while IFS= read -r l; do
    d=$(echo "$l" | sed 's/^.* - //'); n=$(echo "$d" | awk -F'[;,]' '{print NF}'); ...
```

| domain | capability clauses | dotted tool method named? | toolset named? |
|---|---|---|---|
| VFX | 1 | no | `NiagaraTools` |
| Scripting | 1 | yes (`ProgrammaticToolset.execute_tool_script`) | `ProgrammaticToolset` |
| Materials | 2 | no | `MaterialTools` |
| Animation | 2 | no | — |
| UI | 2 | no | — |
| Testing | 3 | no (bare methods only: `DiscoverTests`, `ListTests`, `RunTests`, `GetTestStatus`, `GetTestResults`) | `AutomationTestToolset` |
| Gameplay | 4 | no | — |
| Actors and Scene | 5 | no | `LevelTools` |
| Sequencer | 5 | yes (`SequencerTools.create_level_sequence`) | `SequencerTools` |
| Editor | 5 | yes (`AIAssistantToolset.GetDockedContext`) | `AIAssistantToolset` |
| Blueprints | 6 | yes (`BlueprintTools.create`) | `BlueprintTools` |
| **Meshes and Textures** | **6** | **no** | **`StaticMeshTools`** |
| Assets and Content | 8 | no | `AssetTools`, `ObjectTools` |

**9 of the 13 domains name no dotted tool method.** Among those 9, Meshes and Textures advertises the **second**-most capabilities (6, behind Assets and Content's 8). So the correct comparative statement is bounded: this domain is **one of nine unnamed domains and the second-largest of them** — not the largest, and not uniquely thin. What is exact and load-bearing is the conjunction on the Meshes row: **6 advertised capabilities, a named toolset, and not one callable member name.** That alone is the basis for `static-only`; the comparison adds context, not force.

**(b) Mention density — where this domain is *not* the minimum.**

```
$ run(){ grep -rniE "$2" . | wc -l; }   # per domain, its own bullet nouns
```

| domain | matching lines |
|---|---|
| Sequencer | 1 |
| Materials | 2 |
| **Meshes and Textures** | **2** |
| Actors and Scene / UI / Gameplay / Scripting | 3 |
| Testing | 5 |
| Assets and Content / Animation / VFX / Editor | 6 |
| Blueprints | 7 |

Meshes and Textures ties with Materials for second-thinnest and is beaten by Sequencer. An earlier draft of this card called it "the thinnest surface in the entire corpus"; **that reading is falsified by this probe** and has been removed.

**(c) The complete dotted-method inventory** — the basis for the "zero" column above (8 unique tokens corpus-wide):

```
$ grep -rhoE "[A-Za-z]+(Tools|Toolset)\.[A-Za-z_]+" . | sort -u
AgentSkillToolset.GetSkills
AgentSkillToolset.ListSkills
AIAssistantToolset.GetDockedContext
BlueprintTools.create
LiveCodingToolset.CompileLiveCoding
MyToolset.find_things
ProgrammaticToolset.execute_tool_script
SequencerTools.create_level_sequence
```

`MyToolset.find_things` is the `create-toolset` template placeholder, not a real toolset. Filtering the list for `mesh|texture` returns **empty**: no mesh or texture method name exists anywhere in the corpus.

## 3. Static-only facts, each with a resolvable pointer

Paths are relative to `corpus/knowledge/unreal-mcp/upstream/`. Line numbers verified against the vendored bytes with `grep -n` / `sed -n`.

### 3.1 The capability claim (all of it)

| # | Fact | Pointer |
|---|---|---|
| F1 | Capability is asserted as one flat bullet: "**Meshes and Textures** - inspect/edit static and skeletal meshes, LODs, collisions, Nanite, sockets, bones". This single line is the **entire** functional description of the subsystem in the corpus. Six capability nouns, six commas, zero verbs of contract. | `README.md:104` |
| F2 | The domain is counted in the aggregate inventory: "Hundreds of tools exposed via Unreal's ToolsetRegistry across 30+ toolsets: actors, blueprints, materials, Niagara, Control Rigs, Sequencer, State Trees, widgets, Gameplay Ability System, automation testing, and more." Meshes are **not** even named in this top-level list — they appear only in the later bullet list. | `README.md:3` |
| F3 | The same aggregate claim is repeated in machine-readable plugin metadata (version `3.1.1`). Meshes and Textures are not named here either. | `.claude-plugin/plugin.json:4` |
| F4 | The one toolset name: `StaticMeshTools`, listed as an **existing** toolset that `create-toolset` may extend. Names the toolset; enumerates nothing. | `skills/create-toolset/SKILL.md:3` |
| F5 | `StaticMeshTools` named a second time as the canonical home for a mesh-domain query: "e.g. you're adding a mesh query to `StaticMeshTools`". This is the corpus's only statement about what belongs in the toolset — and it is about *authoring new* members, not about existing ones. | `skills/create-toolset/SKILL.md:30` |

That is the complete set of statements the corpus makes about this subsystem. **F1 is the capability; F4–F5 are the only two mentions of any toolset name, and both name the same toolset; nothing else exists.**

### 3.2 The dispatch contract (how a mesh call would be addressed)

| # | Fact | Pointer |
|---|---|---|
| F6 | Tool search is on by default, so the MCP server advertises only three meta-tools: `list_toolsets`, `describe_toolset`, `call_tool`. Toolset tools such as `BlueprintTools.create` are **not** in `tools/list`; they are dispatched server-side through `call_tool`. | `skills/unreal-mcp/SKILL.md:16` |
| F7 | The intended first move: `list_toolsets`, then `describe_toolset` on the candidate toolset "to read their tool schemas". So **any** mesh tool signature is knowable only from a live editor — by construction, never from this corpus. | `skills/unreal-mcp/SKILL.md:20` |
| F8 | Invocation shape: `call_tool` with `toolset_name`, `tool_name`, and an `arguments` object "matching the schema you just read". Top-level dispatch omitting `toolset_name` is rejected for `call_tool` itself. | `skills/unreal-mcp/SKILL.md:21`, `:22` |
| F9 | Tool search is controlled by the `bEnableToolSearch` UPROPERTY on `UModelContextProtocolSettings` (default `true`). Setting it `False` registers every toolset tool as a native MCP tool at startup — the switch that would make `StaticMeshTools.*` names visible in `tools/list`. | `references/operations.md:18-21`, `README.md:82` |
| F10 | A toolset that seems missing (the doc's own worked example is `NiagaraTools`) is repaired with `ModelContextProtocol.RefreshTools`; if it is still missing, the toolset's **plugin** may not be enabled in the `.uproject`. The same procedure would govern `StaticMeshTools`. | `references/operations.md:13`, `references/operations.md:48` |

### 3.3 Prerequisites and gating (what must be true before a mesh call can work)

| # | Fact | Pointer |
|---|---|---|
| F11 | Two plugins are required and `AllToolsets` is the one that "provides the tools; the server exposes none without it". `AllToolsets` is editor-only with `EnabledByDefault` off, so it must be enabled explicitly. **With only `ModelContextProtocol`, a mesh toolset does not exist to be called.** | `README.md:17`, `references/setup.md:14`, `references/setup.md:31` |
| F12 | The editor must be **running** with the MCP server started (`ModelContextProtocol.StartServer`, or `bAutoStartServer=True`). The optional proxy keeps the *client* session open while the editor is down but does not make tools callable. | `README.md:18`, `references/setup.md:35-46`, `README.md:78` |
| F13 | Default endpoint `localhost:8000`, path `/mcp`; no static `.mcp.json` ships — it is generated by `ModelContextProtocol.GenerateClientConfig ClaudeCode`. | `README.md:70-72`, `references/setup.md:57-79` |
| F14 | The only documented route to tool signatures **without** a live editor: "search the codebase for folders named `Toolsets` and read the C++ headers or Python toolset files there". This requires the **engine source**, which this host does not have. | `skills/create-toolset/SKILL.md:26` |

### 3.4 Behavioral hazards that would apply to mesh work

The corpus states no mesh-specific hazard. What it does state is a set of generic warnings that would bind any mesh mutation, and two of them are materially worse for meshes than for other domains because mesh edits are bulk asset rewrites.

| # | Fact | Pointer |
|---|---|---|
| F15 | "**Save first, then save again.** … MCP edits are not always undoable, especially across compilation boundaries. Treat anything that touches multiple assets as a destructive operation that needs a recovery point." | `skills/unreal-mcp/SKILL.md:30` |
| F16 | "**Always check the result.** … many tools return a status that flips between success and failure with no exception thrown on the wire. … Treat anything that isn't an explicit success as a stop." The named examples are Blueprint compile, widget creation, material edits — **no mesh example is given**. | `skills/unreal-mcp/SKILL.md:33` |
| F17 | Tool calls hang or fail confusingly while C++ or shader compilation is in flight; drive `LiveCodingToolset.CompileLiveCoding` and wait on its result. Shader compilation is directly implicated in material/mesh rendering changes. | `skills/unreal-mcp/SKILL.md:31`, `references/operations.md:49` |
| F18 | PIE changes editor-only behavior, "asset creation in particular". | `skills/unreal-mcp/SKILL.md:34` |
| F19 | Concurrency: "Serialize dependent calls and mutations that can affect the same asset or editor state." A mesh edit is the archetype of a single asset mutated by several calls. | `skills/unreal-mcp/SKILL.md:32`, `references/operations.md:51` |
| F20 | Source-control hygiene: "MCP tools edit live `UObject` state and can mutate, move, or delete VCS-tracked assets in a single call. Save and commit (or shelve) before any long MCP-driven session." Mesh assets are typically large binary VCS-tracked files. | `README.md:94` |

### 3.5 Triggering (when the agent is told to reach for meshes at all)

| # | Fact | Pointer |
|---|---|---|
| F21 | The skill's description names mesh work as a concrete trigger: "…or modify Static/Skeletal Mesh assets". It also lists the mesh asset prefixes `SK_` (skeletal mesh) and `SM_` (static mesh) among the strings that make a prompt count as Unreal context. This is the corpus's **only** per-domain vocabulary for meshes. | `skills/unreal-mcp/SKILL.md:3` |
| F22 | The capability bullet's verbs are "inspect/edit" — the corpus never distinguishes which of the six nouns is inspectable and which is editable, nor whether "edit" means mutate the asset or only its import settings. | `README.md:104` |

`SM_` / `SK_` at `skills/unreal-mcp/SKILL.md:3` are the two most concrete mesh-domain artifacts in the whole tree, and they are **filename prefixes**, not tool names or schemas.

## 4. What is conspicuously absent (the gap that forces `static-only`)

Searched for and **not found** anywhere in the 1022 vendored lines:

- **Any `StaticMeshTools` method name.** Corpus-wide there are **12** dotted-tool occurrences, collapsing to **8** unique tokens, and **none** belongs to a mesh toolset:

  ```
  $ grep -rnoE "[A-Za-z]+Tools\.[A-Za-z_]+|[A-Za-z]+Toolset\.[A-Za-z_]+" . | sort -u
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

  Filtering that set for `mesh|texture` returns **empty**. `BlueprintTools` gets a tool name, `SequencerTools` gets a tool name, `LiveCodingToolset` gets one, `AIAssistantToolset` gets one — **Meshes and Textures gets none.**
- **Any skeletal-mesh toolset at all.** `SkeletalMeshTools` occurs **0** times. The README bullet claims "static and skeletal meshes", and the trigger line names `SK_`, but the corpus names **no** skeletal toolset and never says whether skeletal meshes live in `StaticMeshTools` or somewhere else.
- Any parameter list, return type, or JSON schema for a mesh tool.
- Any statement of what an LOD is in the tool vocabulary — no index scheme, no level count, no screen-size mapping.
- Any Nanite contract: whether it is a boolean toggle, a per-asset setting, a build step, or a fallback policy. The word occurs once and is never developed.
- Any collision contract: no shape vocabulary (box/sphere/convex/UCX_ naming), no trace-vs-simple distinction, no body-setup notion.
- Any socket or bone contract: no attachment semantics, no transform space, no naming rule, no parenting model. Both words occur once, adjacent, and never again.
- Any texture tool, texture format, import-settings, or streaming contract. `texture` occurs **once**, in the domain *label*, and no capability clause mentions textures at all — the bullet's clause list ("static and skeletal meshes, LODs, collisions, Nanite, sockets, bones") contains no texture item.

Consequence: the corpus is sufficient to **route** a mesh request (F6, F7, F21, F22) and **warn** about it (F15–F20), and insufficient to name, type, or call a single mesh function. Hence `static-only`, not `verified-here`.

## 5. Why not `verified-here`, and why not `unproven-runtime`

- **Not `verified-here`:** no mesh tool call was made, and no `describe_toolset` result exists to cite. Nothing about mesh or texture behavior was observed on this host.
- **Not `unproven-runtime`:** that label would assert a real, identified runtime path that merely went untested. Here the path is not identified at all — the signatures are unknown **by construction**, because the corpus defers them to a live `describe_toolset` (F7). The correct statement is weaker: the surface is documented as existing and is not specified.

This card is deliberately the *stronger* of the two negative labels. The distinction matters for calibration:

- `unproven-runtime` invites "someone just needs to run it".
- `static-only` correctly says "running it is necessary **and** the artifacts to run it against are not in hand".

For Meshes and Textures specifically, the corpus is thinner than for Blueprints: Blueprints at least yields a toolset name plus a negative tool-name example (`BlueprintTools.create`), whereas here the two `StaticMeshTools` mentions carry no member name at all. A mesh card labeled `unproven-runtime` would overstate how much is known.

### Note on the index's card table

`corpus/knowledge/unreal-mcp/README.md:213-227` lists this card as row 5 (`executability/meshes-textures.md`) with its subsystem description. That table deliberately carries **no** verdict column — the index states at `README.md:209`: "This index does **not** restate the labels: the binding verdict and its evidence live in each card, and only the card is authoritative. Read the card, not this table."

So this card is the sole authority for its own label, and its binding verdict is **`static-only`** for the reason in §5. That matches the label this seat was assigned. Nothing in the index needs changing, and it is not this seat's file to edit.

## 6. Host receipts (re-derived this round, not quoted)

All commands run on this host; observed output recorded.

| Check | Command | Observed |
|---|---|---|
| Editor binary absent | `which UnrealEditor UnrealEditor-Cmd UE4Editor` | `which: no UnrealEditor in (...)`; `which: no UnrealEditor-Cmd in (...)`; `which: no UE4Editor in (...)`; exit `3` |
| Engine tree absent | `find / -maxdepth 5 -type d -iname 'UnrealEngine' -not -path '/proc/*'` | no output — no engine tree anywhere |
| No `.uproject` on host | `find /home -maxdepth 4 -name '*.uproject'` | no output — no project to open |
| No MCP server listening | `(ss -ltnp \|\| netstat -ltnp) \| grep -E ':8000\|:800[0-9]'` | `NO LISTENER on 8000-8009` |
| Endpoint unreachable | `curl -sS -m 5 -o /dev/null -w 'http_code=%{http_code}\n' http://127.0.0.1:8000/mcp` | `curl: (7) Failed to connect to 127.0.0.1:8000 after 0 ms: Could not connect to server`; `http_code=000`; rc `7` |
| No unreal-mcp client config | `find /home/vgpnk -maxdepth 4 -name '.mcp.json'` | only two unrelated plugin files (`.grok/installed-plugins/…`); no Unreal entry |
| Host capacity | `nproc` / `free -g` / `df -h /` | 32 cores; 30G RAM; 780G free on `/` |
| Toolchain | `which jq python3 node shellcheck docker` | all present (`shellcheck` 0.11.0) |
| Upstream pin confirmed | `git -C /tmp/ue-skills-ref rev-parse HEAD` | `a6aa73ada02a9fb1f5415bec491f9942c519b297` — equals the pin |
| Vendoring byte-identical | per-file `sha256sum` of `upstream/` vs `/tmp/ue-skills-ref` | `OK` for all **12** files (loop over the sorted file list; 12/12 `OK`, no `DIFF`) |
| Vendored line count | `find . -type f \| sort \| xargs wc -l \| tail -1` | `1022 total` (12 files; 884 Markdown) |

The engine fetch is blocked for an operator-owned reason (recorded in the round's unknowns map and in `corpus/knowledge/unreal-mcp/README.md` §Host reality): the AUR `unreal-engine` PKGBUILD requires SSH access to the private `EpicGames/UnrealEngine` repository, and the GitHub account is not Epic-linked. Therefore F11–F13 cannot be satisfied on this host as configured, and no mesh tool call is possible.

## 7. Unlock condition

The label flips from `static-only` to `unproven-runtime` / `verified-here` only through this chain, in order:

1. **Operator action (blocking, not automatable here):** link the Epic Games account to the GitHub account so `git@github.com:EpicGames/UnrealEngine` becomes reachable. Nothing downstream can be attempted before this.
2. Build or install the engine — e.g. the AUR `unreal-engine` package.
3. Create/open a `.uproject` with **both** `ModelContextProtocol` and `AllToolsets` enabled (`references/setup.md:14-31`). Without `AllToolsets`, the server starts and exposes no tools — mesh tools included (F11).
4. Launch the editor and start the server: `ModelContextProtocol.StartServer` (`references/operations.md:11`), or `bAutoStartServer=True` (`references/setup.md:43-46`).
5. Generate the client config: `ModelContextProtocol.GenerateClientConfig ClaudeCode` (`references/setup.md:61`), producing `.mcp.json` at the location matching the build kind (`references/setup.md:63-66`).
6. **First real verification, the cheapest possible and the highest-yield for this card:** `list_toolsets`, then `describe_toolset` on `StaticMeshTools`. This single call closes the largest gap in §4 — it converts "no member name exists" into a full member list with parameter types and return shapes, and it resolves the open question of whether a separate skeletal-mesh toolset exists (F4 vs the "skeletal" clause of F1). No mesh behavior needs to be exercised for this step.
7. Only then can any claim about LODs, collisions, Nanite, sockets, bones, or textures be tested, and each would still need its own `call_tool` receipt before it could be called verified.

Until step 1 happens, every Meshes-and-Textures claim in this card remains a document claim. **No mesh or texture tool has been executed on this host, and none can be.**

## 8. Cross-references

- Upstream corpus (vendored, byte-identical): `corpus/knowledge/unreal-mcp/upstream/`
- Per-file hashes: `corpus/knowledge/unreal-mcp/.manifest.d/seat01.sha256` … `seat11.sha256`
- Corpus index + verification policy: `corpus/knowledge/unreal-mcp/README.md`
- Sibling card in this set: `corpus/knowledge/unreal-mcp/executability/blueprints.md` (card 2; also `static-only`)
- Toolset-domain census for this round: `reports/round-101/probes/toolset-census.md` (row 5 = this subsystem; pins `StaticMeshTools` to `create-toolset/SKILL.md:3`, `:30`)
- Round unknowns map: `reports/round-101/r101-unknowns-map.md`
- Adjacent subsystems dissected this round: `reports/round-101/bpy-dissection.md`, `reports/round-101/navagent-dissection.md`
