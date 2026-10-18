# Verdict Card — Gameplay (gameplay tags / GAS state / Game Feature Plugins / physics assets)

**Subsystem:** Gameplay (`README.md:109` — "manage gameplay tags, inspect GAS state, create Game Feature Plugins, edit physics assets")
**Label:** `static-only`
**Seat:** SEAT-40 EXEC
**Card 10 of the 13-subsystem set (C2)**
**Upstream pin:** `EpicGames/unreal-engine-skills-for-claude-code-plugin` @ `a6aa73ada02a9fb1f5415bec491f9942c519b297`
**Vendored at:** `corpus/knowledge/unreal-mcp/upstream/`
**Label basis:** every fact below is a document claim read from the vendored bytes; no Gameplay tool was ever executed, because no editor exists on this host. Nothing here has been observed at runtime.

---

## 1. Why this label, in one line

The Gameplay bucket's entire specification is **one 107-byte README line** (`README.md:109`) listing four capabilities, and the corpus names **no Gameplay toolset, no Gameplay tool, no GAS type, and no GAS asset prefix** anywhere in its 1022 lines. A reader can learn that gameplay tags, GAS state, Game Feature Plugins and physics assets are *claimed* to be drivable, and cannot name a single call, parameter, or return value to do it with. The corpus is sufficient to **route** a Gameplay request and insufficient to **execute** one.

---

## 2. Exhaustive mention sweep (the whole Gameplay surface)

Commands actually run, from `corpus/knowledge/unreal-mcp/upstream/` (case-insensitive, word-boundary, over `*.md`/`*.json`/`*.sh`, `.git` excluded).

```
$ grep -rIinE "\bgameplay\b" --include='*.md' --include='*.json' --include='*.sh' .
./README.md:3:...across 30+ toolsets: actors, blueprints, materials, Niagara, Control Rigs, Sequencer, State Trees, widgets, Gameplay Ability System, automation testing, and more.
./README.md:109:- **Gameplay** - manage gameplay tags, inspect GAS state, create Game Feature Plugins, edit physics assets
./.claude-plugin/plugin.json:4:  "description": "Control Unreal Editor directly from Claude Code via MCP. ... Gameplay Ability System, automation testing, and more.",
```

**3 lines, 4 occurrences** (`README.md:109` carries two: the bold label and "gameplay tags"). Of those three lines, two are the *same sentence* — `plugin.json:4` is a byte-for-byte copy of `README.md:3` (verified: `sed -n '3p' README.md` vs the `description` value). So the Gameplay bucket has **two distinct sentences** in the whole corpus, one of which is the bullet.

| token (word-boundary, `-i`) | lines | where |
|---|---|---|
| `gameplay` | 3 | `README.md:3`, `README.md:109`, `.claude-plugin/plugin.json:4` |
| `GAS` | 3 | `skills/unreal-mcp/SKILL.md:3`, `skills/unreal-mcp/SKILL.md:8`, `README.md:109` |
| `ability` | 3 (ci) / 1 (cs) | `README.md:3` and `.claude-plugin/plugin.json:4` ("Gameplay **Ability** System"); `skills/unreal-mcp/SKILL.md:3` ("GAS **ability**", the only lowercase occurrence) |
| `tags` | 1 | `README.md:109` |
| `game feature` (singular only; `game features` = 0) | 1 | `README.md:109` |
| `physics` | 1 | `README.md:109` |
| `attribute` / `attributes` | 2 | `skills/unreal-skill/SKILL.md:53`, `:56` — **Agent Skill class attributes, unrelated to GAS** |

Searched for and **absent entirely** (0 hits each, same sweep):

```
GameplayEffect   GameplayAbility   AbilitySystemComponent   FGameplayTag
GameplayTag      UGameplayEffect   UAbilitySystemComponent   AttributeSet
GAS ability (as a tool name)       physics asset (as a tool name)
GA_   GE_   DA_   DT_              # asset prefixes
```

`ability` occurs as a bare word **once** in lowercase — inside the skill's trigger sentence ("...Control Rig/Sequencer/Behavior Tree/GAS ability") — and twice more as the capitalised middle word of "Gameplay **Ability** System" (`README.md:3`, `plugin.json:4`). It never appears as a tool name or a type. `attribute` occurs twice, both about `UAgentSkill` class fields. There is **no GAS vocabulary** in the corpus at all.

---

## 3. Static-only facts, each with a resolvable pointer

Paths are relative to `corpus/knowledge/unreal-mcp/upstream/`; line numbers re-verified against the vendored bytes with `grep -n` / `sed -n`.

### 3.1 The capability claim (all of it)

| # | Fact | Pointer |
|---|---|---|
| F1 | The bucket's **entire** functional description is a flat four-clause bullet: "manage gameplay tags, inspect GAS state, create Game Feature Plugins, edit physics assets". 107 bytes including the newline; the four clauses are comma-separated. (Comma separation is the norm — only 2 of the 13 domain bullets use `;` at all: Actors and Scene, Assets and Content.) | `README.md:109` |
| F2 | The domain is counted in the aggregate inventory, which is the only place "Gameplay Ability System" is spelled out: "Hundreds of tools exposed via Unreal's ToolsetRegistry across 30+ toolsets: actors, blueprints, materials, Niagara, Control Rigs, Sequencer, State Trees, widgets, **Gameplay Ability System**, automation testing, and more." Note the long form is used here and the short form `GAS` in the skill body (F4) — the two are never tied together. | `README.md:3` |
| F3 | Third copy of the same sentence, in machine-readable plugin metadata (version `3.1.1`). Byte-identical text to F2. | `.claude-plugin/plugin.json:4` |
| F4 | The core skill's own toolset list uses the short form and drops the long one: "The server exposes hundreds of tools across 30+ toolsets (actors, blueprints, materials, Niagara, Sequencer, Control Rigs, **GAS**, automation tests, Live Coding, and more)". | `skills/unreal-mcp/SKILL.md:8` |
| F5 | `README.md:98` frames all 13 bullets as a claim of what the *tools* cover — "Tools cover the full editor surface across these domains:" — so F1 reads as a tool claim, not a docs claim. | `README.md:98` |

### 3.2 The dispatch contract (how a Gameplay call *would* be addressed)

The transport is specified generically and is domain-agnostic; nothing Gameplay-specific is added to it.

| # | Fact | Pointer |
|---|---|---|
| F6 | Gameplay tool names are **not** in `tools/list`. Toolset tools are dispatched server-side through `call_tool` with `toolset_name`, `tool_name`, `arguments`. | `skills/unreal-mcp/SKILL.md:16`, `:21` |
| F7 | The intended first move for any domain task is `list_toolsets` → `describe_toolset` "to confirm the available tools and their signatures" — i.e. **signatures are only knowable from a live editor**, never from this corpus. | `skills/unreal-mcp/SKILL.md:20` |
| F8 | Meta-tool set is exactly three: `list_toolsets`, `describe_toolset`, `call_tool`; top-level dispatch omitting `toolset_name` is rejected for `call_tool` itself. | `skills/unreal-mcp/SKILL.md:16`, `:22` |
| F9 | A toolset that seems missing (the doc's own example is `NiagaraTools`) is repaired with `ModelContextProtocol.RefreshTools`; if still missing, the toolset's **plugin** may not be enabled in the `.uproject`. | `references/operations.md:13`, `:48` |
| F10 | Under the default tool-search mode (`bEnableToolSearch=True`) the catalog never changes mid-session; setting it `False` registers every toolset tool as a native MCP tool upfront — the switch that would make Gameplay tool names visible in `tools/list`. | `README.md:82`, `references/operations.md:18-21` |
| F11 | `ProgrammaticToolset.execute_tool_script` runs arbitrary Python inside the editor process with access to "every toolset API, the project on disk, the asset database, and editor-privileged functions" — the one documented path that could reach a Gameplay capability **regardless** of which toolsets are registered. It is a generic escape hatch, not a Gameplay tool. | `README.md:90` |

### 3.3 Prerequisites and gating (what must be true before a Gameplay call can work)

| # | Fact | Pointer |
|---|---|---|
| F12 | Two plugins are required; `AllToolsets` is the one that "provides the tools; the server exposes none without it". It is editor-only with `EnabledByDefault` off, so it must be enabled explicitly in the `.uproject`. | `README.md:17`, `references/setup.md:14`, `:31` |
| F13 | The editor must be **running** with the MCP server started (`ModelContextProtocol.StartServer`, or `bAutoStartServer=True`). The optional proxy keeps the *client* session open while the editor is down but does not make tools callable. | `README.md:18`, `references/setup.md:35-46` |
| F14 | Default endpoint `localhost:8000`, path `/mcp`; no static `.mcp.json` ships — it is generated by `ModelContextProtocol.GenerateClientConfig ClaudeCode`. | `README.md:70-72`, `references/setup.md:57-79` |
| F15 | **Game Feature Plugins have no construction route in this corpus.** The only plugin-authoring guidance is about *toolsets* and *Agent Skills*; `create-toolset` covers `*Tools.cpp/.h/.py` files under a `Toolsets/` folder and registration via `unreal.ToolsetRegistry.register_toolset_class`, and `unreal-skill` covers `UAgentSkill` classes and UAsset skills. Neither is a Game Feature Plugin. The corpus tracks **zero** `.uplugin` files (`find . -name '*.uplugin' -not -path './.git/*'` → 0) and zero `.uproject` files. | `skills/create-toolset/SKILL.md:3`, `:325-331`; `skills/unreal-skill/SKILL.md:34-35`, `:49`, `:78` |
| F16 | The only documented route to tool signatures without a live editor is "search the codebase for folders named `Toolsets` and read the C++ headers or Python toolset files there" — which requires the engine source, absent on this host. | `skills/create-toolset/SKILL.md:26` |
| F17 | The Python route is gated on `Developer Mode` (Edit → Project Settings → Plugins → Python) plus an editor restart, producing `<project_root>/Intermediate/PythonStub/unreal.py`; verification of Python changes needs **Remote Execution** enabled and a plugin-package reload. All three are live-editor operations. | `skills/create-toolset/SKILL.md:36-37`, `:374`; `skills/unreal-skill/SKILL.md:82` |

### 3.4 Behavioral hazards that would apply to Gameplay work

The corpus's operational claims are domain-generic; none is Gameplay-specific, which is itself part of the gap.

| # | Fact | Pointer |
|---|---|---|
| F18 | MCP edits are "not always undoable, especially across compilation boundaries". Save before and after any bulk change. | `skills/unreal-mcp/SKILL.md:30` |
| F19 | Tool calls hang or fail confusingly while C++ or shader compilation is in flight; drive `LiveCodingToolset.CompileLiveCoding` and wait on its result. This matters for GAS because ability/attribute code is C++. | `skills/unreal-mcp/SKILL.md:31`, `references/operations.md:49` |
| F20 | "Always check the result. Blueprint compilation, widget creation, material edits: many tools return a status that flips between success and failure with no exception thrown on the wire." Gameplay is **not** named in this list, so there is no documented failure surface for a Gameplay call. | `skills/unreal-mcp/SKILL.md:33` |
| F21 | PIE changes editor-only behavior; serialize dependent calls and mutations that can affect the same asset; multiple agents on one editor can conflict. | `skills/unreal-mcp/SKILL.md:32`, `:34`, `references/operations.md:51` |
| F22 | MCP tools "can mutate, move, or delete VCS-tracked assets in a single call" — the reason any Gameplay experiment needs a save/commit recovery point. | `README.md:94` |

### 3.5 Triggering (when the agent is told to reach for Gameplay at all)

| # | Fact | Pointer |
|---|---|---|
| F23 | Exactly **one** Gameplay trigger phrase exists: "...create or edit a Blueprint/Widget/Material/Niagara/Control Rig/Sequencer/Behavior Tree/**GAS ability**". It names GAS abilities and nothing else in the bucket — not tags, not Game Feature Plugins, not physics assets. | `skills/unreal-mcp/SKILL.md:3` |
| F24 | **No GAS asset prefix is listed.** The prefix list is `` `BP_`, `WBP_`, `M_`, `MI_`, `NS_`, `CR_`, `SK_`, `SM_`, `ABP_` `` — nine prefixes, none of them GAS (`GA_` = 0 hits, `GE_` = 0 hits corpus-wide). So a file named `GA_Fireball` or `GE_Burn` matches **no** rule in the trigger list; the only GAS routing signal is the literal word "GAS" in a user sentence. | `skills/unreal-mcp/SKILL.md:3` |
| F25 | The trigger description's `Skip for:` clause disambiguates unrelated uses of "blueprint"/"sequencer"/"widget" but has no GAS/Gameplay carve-out. | `skills/unreal-mcp/SKILL.md:3` |

---

## 4. Per-capability breakdown (the four clauses of `README.md:109`)

Each of the four capabilities is graded on its own, because they are four different things compressed into one bullet and the corpus supports them unequally.

| # | Capability (verbatim) | What the bytes give it | Independent support | Verdict |
|---|---|---|---|---|
| 1 | `manage gameplay tags` | The words "gameplay tags" appear once (`README.md:109`). `GameplayTag`/`FGameplayTag`/`GameplayTags` as types → 0 hits. No tag-hierarchy, container, or query vocabulary. | none — one prose phrase | `static-only` |
| 2 | `inspect GAS state` | `GAS` appears 3 times, all as a domain name-drop (`README.md:109`, `SKILL.md:3`, `SKILL.md:8`). No `AbilitySystemComponent`, `GameplayAbility`, `GameplayEffect`, or `AttributeSet` anywhere. "State" is never defined for GAS. | none — the word `GAS` only | `static-only` |
| 3 | `create Game Feature Plugins` | `Game Feature` appears **once**, in this bullet. The corpus tracks 0 `.uplugin` and 0 `.uproject` files, and its plugin-authoring skills (toolset, Agent Skill) describe neither. There is no descriptor schema, no enable/disable contract, no directory convention. | none — one prose phrase | `static-only` |
| 4 | `edit physics assets` | `physics` appears **once**, in this bullet. `PhysicsAsset`/`UPhysicsAsset` → 0 hits. The nearest adjacent corpus text is `README.md:104` ("Meshes and Textures — ... collisions ..."), which belongs to **card 5**, not this card. | none — one prose phrase, and its one adjacent mention belongs to another card | `static-only` |

**Cross-card boundary note (for the set adjudicator).** "edit physics assets" sits in the Gameplay bullet but `collisions` sits in the Meshes and Textures bullet (`README.md:104`), and `collision` occurs in exactly 2 lines corpus-wide (the other being `references/operations.md:3`, a *port* collision — unrelated). The two domains overlap on physics authoring and the corpus never resolves the boundary. This card claims the bullet clause; it does not claim the Meshes card's collision tooling. **[I]**

---

## 5. What is conspicuously absent (the gap that forces `static-only`)

Searched for and **not found** anywhere in the 1022 vendored lines:

- **Any Gameplay toolset name.** `GameplayTools`, `GameplayToolset`, `AbilityTools`, `AbilityToolset`, `TagTools`, `GameplayTagsTools`, `PhysicsAssetTools`, `GameFeatureTools` → 0 hits each. Corpus-wide there are exactly **14** toolset-shaped tokens excluding the `MyToolset`/`UMyToolset` create-toolset placeholders, and none is Gameplay-shaped: `AgentSkillToolset`, `AIAssistantToolset`, `AssetTools`, `AutomationTestToolset`, `BlueprintTools`, `LevelTools`, `LiveCodingToolset`, `MaterialTools`, `NiagaraTools`, `ObjectTools`, `ProgrammaticToolset`, `RefreshTools`, `SequencerTools`, `StaticMeshTools`. Of those 14, `RefreshTools` is an editor **console command** (`ModelContextProtocol.RefreshTools`), not a toolset class, so the real toolset-class count is **13**. **[I]**
- **Any Gameplay tool method.** Corpus-wide there are exactly **8** distinct `.`-qualified names, and none is Gameplay: `LiveCodingToolset.CompileLiveCoding`, `MyToolset.find_things` (template placeholder), `SequencerTools.create_level_sequence`, `ProgrammaticToolset.execute_tool_script`, `BlueprintTools.create`, `AIAssistantToolset.GetDockedContext`, `AgentSkillToolset.ListSkills`, `AgentSkillToolset.GetSkills`. **Two** of them — `BlueprintTools.create` and `SequencerTools.create_level_sequence` — are shown as *negative* examples of names deliberately absent from `tools/list`.
- **Any parameter list, return type, or JSON schema** for a tag, GAS, Game Feature, or physics-asset operation.
- **Any GAS type name** — `GameplayEffect`, `GameplayAbility`, `AbilitySystemComponent`, `AttributeSet`, `FGameplayTag` all 0.
- **Any GAS asset prefix** — `GA_` and `GE_` both 0; the nine-prefix list (`SKILL.md:3`) has no GAS entry.
- **Any representation of a tag hierarchy, an ability, an effect, an attribute set, a Game Feature Plugin descriptor, or a physics asset.** Not even the nouns.
- **Any toolset member count.** "Hundreds of tools ... 30+ toolsets" (`README.md:3`) is aggregate and unverifiable from here.

**Consequence.** The corpus is sufficient to **route** a Gameplay request (F5, F23) and insufficient to **name** or **execute** anything in it. Hence `static-only`, not `verified-here`.

---

## 6. Why not `verified-here`, and why not `unproven-runtime`

- **Not `verified-here`:** no Gameplay tool call was made. No editor is installed (see §7), so no `describe_toolset` result exists to cite. Nothing about tag management, GAS state, Game Feature Plugins, or physics assets was observed.
- **Not `unproven-runtime`:** that label asserts a real, identified runtime path that merely went untested. Here the path is not identified — the toolset name is unknown by construction, because the corpus defers signatures to a live `describe_toolset` (F7), and unlike Actors-and-Scene there is no specified asset-level residue to reason from either. The correct statement is weaker: the surface is documented as existing and is not specified. That is `static-only`.

**Sibling-label reconciliation.** All 13 cards in the set now exist; 12 are `static-only` and one (`actors-scene.md`) is `unproven-runtime`. `actors-scene.md` §5 records that it chose the looser label because its runtime path is identified but its state is live-only with no static residue, and explicitly flags the tension for the adjudicator. This card follows the **stricter** test (as `blueprints.md` and `animation-controlrig.md` do): the tool surface is unspecified, so `static-only`. If the adjudicator prefers `unproven-runtime` for the whole set, this card is one whose reasoning would need to change, and the change would be a one-line relabel — no evidence below moves.

---

## 7. Host receipts (re-derived this round, not quoted)

All commands run on this host; observed output recorded.

| Check | Command | Observed |
|---|---|---|
| Upstream clone at pin | `git -C /tmp/ue-skills-ref rev-parse HEAD` | `a6aa73ada02a9fb1f5415bec491f9942c519b297` — equals the pin |
| Vendored == clone | `diff -rq /tmp/ue-skills-ref corpus/knowledge/unreal-mcp/upstream -x .git` | no output; `DIFF_RC=0` |
| Manifest sweep | `sha256sum -c .manifest.d/audit-reference.sha256` (from `corpus/knowledge/unreal-mcp`) | 12 lines, all `OK`, exit `0` |
| Corpus size | `find . -path ./.git -prune -o -type f -print0 \| xargs -0 wc -l` | `1022 total` across 12 files; `63556` bytes |
| Editor binary absent | `which UnrealEditor UnrealEditor-Cmd` | `which: no UnrealEditor in (...)`; `rc=2` |
| Engine tree absent | `ls -d /opt/UnrealEngine /opt/unreal-engine ~/UnrealEngine /usr/share/unreal-engine` | `No such file or directory` ×4 |
| No editor process | `pgrep -af -i UnrealEditor` | no output; `rc=1` |
| No MCP server listening | `ss -ltn \| grep -cE ':8000'` | `0` — no listener on 8000 |
| MCP endpoint refused | `curl -s -m 3 -o /dev/null -w 'exit=%{exitcode}' http://127.0.0.1:8000/mcp` | `exit=7` (connection refused) |
| No generated client config | `ls -la .mcp.json` | `No such file or directory` |
| Engine fetch blocked | `git ls-remote https://github.com/EpicGames/unreal-engine` | `remote: Repository not found.` / `fatal: repository ... not found` |
| Engine build blocked | `grep -n "git@github.com" /tmp/r101seat12-aur-PKGBUILD` | `280:  if ! git ls-remote git@github.com:EpicGames/UnrealEngine &>/dev/null; then` (AUR `unreal-engine` `pkgver=5.8.2`, `pkgrel=1`) |
| GitHub account | `gh auth status` | logged in as `VeigaPunk`; not Epic-linked (hence the `ls-remote` failure) |
| Host capacity | `nproc` / `free -g` / `df -h /` | 32 cores; 30 GB RAM; 780 G free on `/` |
| Toolchain | `which jq python3 node shellcheck docker` | all present; `shellcheck` GNU GPLv3 build |

**Transient observation, recorded for honesty.** During this seat, one `ss -ltn` sample showed `127.0.0.1:8000` in `LISTEN` and a `curl` to `/mcp` returned `exit=0`; five consecutive re-samples minutes later showed **0** listeners on 8000 and `curl exit=7`, and `pgrep -af -i UnrealEditor` was empty throughout. The listener was **not** an Unreal editor (no editor binary exists on this host) — it was a sibling seat's short-lived local capture server, and the concurrent `/tmp/r101sentinel/` directory contains exactly that pattern (an `echo_srv.py` plus `req.log` entries against `127.0.0.1:8000`). This card's runtime receipts are therefore the **re-sampled** ones: port closed, endpoint refused. Any future card quoting "port 8000 is open" on this host should re-check rather than trust a single sample.

---

## 8. Unlock condition

The label moves off `static-only` only through this chain, in order. Steps 1–2 are **not agent-solvable on this host**.

1. **Operator action (blocking):** link the Epic Games account to the GitHub account so `git@github.com:EpicGames/UnrealEngine` becomes reachable. Nothing downstream can be attempted before this; the AUR PKGBUILD hard-fails at line 280 without it. The Lutris/Epic-launcher route needs an Epic login, which is also operator-owned. *Receipt:* `ls-remote` → `Repository not found`.
2. **Install the engine** — AUR `unreal-engine` 5.8.2-1, or an Epic/Lutris install — so a real Unreal Editor binary exists. *Receipt:* `which UnrealEditor` → not found.
3. **Create/open a `.uproject`** with **both** `ModelContextProtocol` and `AllToolsets` enabled (`references/setup.md:14-31`). Without `AllToolsets` the server starts and exposes no tools — Gameplay included. For this domain specifically, the GAS and Game Feature toolset plugins (if separate) must also be enabled; F9 is the recovery path if one is missing.
4. **Launch the editor and start the server:** `ModelContextProtocol.StartServer [port]` (`references/operations.md:11`), or `bAutoStartServer=True` (`references/setup.md:43-46`). The port must stop refusing.
5. **Generate the client config:** `ModelContextProtocol.GenerateClientConfig ClaudeCode` (`references/setup.md:61`), producing `.mcp.json` at the location matching the build kind (`references/setup.md:63-66`).
6. **First real verification, and the cheapest one:** `list_toolsets`, then `describe_toolset` on whatever Gameplay-domain entry appears. This single call converts §5's entire gap — names, parameter types, return shapes — from unknown to known. It is also the call that decides whether this bucket is **one** toolset or several, since the bullet compresses four capabilities that live in different UE subsystems (GameplayTags, GAS, Game Feature Plugins, PhysicsAsset). **[I]**
7. **Then, per capability and one at a time:** a read-only call first (list tags; read an ASC's state), then a minimal mutation in a **throwaway** project with a save/commit recovery point (`README.md:94`). Each capability needs its own `call_tool` receipt before it can be called verified — four capabilities, four receipts, since the corpus gives them no shared contract.

**Partial unlock.** Step 6 alone would raise this card to a *documented-contract* level while leaving it `unproven-runtime`; only step 7 with receipts reaches `verified-here`. Until step 1 happens, every Gameplay claim in this card remains a document claim. **No Gameplay tool has been executed on this host, and none can be.**

---

## 9. Consumer notes (calibration-relevant; pointers resolve)

Compact rows for the C3 adaptation work; each carries a pointer that resolves in this subtree.

| # | Upstream (Claude Code) assumption | Kimi reading | Pointer |
|---|---|---|---|
| 1 | Gameplay capability is auto-discovered: "All tools are auto-discovered by Claude Code via MCP. No manual configuration needed." | **False for the agent.** Nothing is auto-discovered *from this corpus*; the agent must issue `list_toolsets` at runtime, and the Gameplay toolset name is not knowable beforehand. Treat `README.md:98` as a client-side claim, not an agent-side guarantee. | `README.md:98`; `skills/unreal-mcp/SKILL.md:20` |
| 2 | The Gameplay bullet reads as a capability inventory. | Read it as a **coverage bucket**, not a toolset list: four capabilities across four UE subsystems, no shared toolset implied. The sibling census seat reached the same conclusion independently. | `README.md:109`; `reports/round-101/probes/toolset-census.md` §E3 |
| 3 | "inspect GAS state" presumes an in-editor agent with ASC access. | Any Kimi-side GAS reasoning is **document-only** here. Do not let a Gameplay claim enter a fixture, test, or lesson without a live-editor receipt. | `README.md:109`; `corpus/knowledge/engines.md` (Unreal row: `installed = no`) |
| 4 | `--dangerously-skip-permissions` / approval gates govern Gameplay blast radius. | Maps to whatever skip-approval mode the host CLI has; the *risk* statement ports, the flag name does not. Relevant to Gameplay because `execute_tool_script` (F11) can reach GAS state regardless of registered toolsets. | `README.md:90-92` |
| 5 | `SessionStart` hook injects UE context via `bash ${CLAUDE_PLUGIN_ROOT}/...`. | The hook is plain bash and portable; `${CLAUDE_PLUGIN_ROOT}` is the only Claude-specific variable. The hook detects a project by `GenerateProjectFiles.{bat,sh,command}` or a `*.uproject` file — neither exists in this corpus, so the hook would not fire here. | `hooks/hooks.json:8`; `hooks/unreal-context.sh:13-28` |

**Verification policy applied by this card.**

- **Proven here (static):** the pinned SHA; the byte-identity of the vendored mirror; the existence and exact wording of every quoted line; every count in §2 and §5; the absence of any Gameplay toolset/tool/GAS type/GAS prefix; the 12-file inventory.
- **Unproven (runtime, labelled not asserted):** that a Gameplay toolset exists at all; that gameplay tags are queryable or mutable; that GAS state is inspectable; that a Game Feature Plugin can be created; that a physics asset can be edited; that `AllToolsets` registers any of them.
- **Unknown (`[?]`):** whether the bucket is one toolset or four; what "GAS state" denotes (ASC runtime state, ability-grant state, or effect stacks); whether "physics assets" means `UPhysicsAsset` editing or something else; whether Game Feature Plugin creation is a tool or only a `.uproject` edit.
- **Rule applied:** no row in this card asserts a runtime fact. Every runtime sentence is either marked unproven, or written as a precondition ("would require …").

---

## 10. Boundaries

- **Sole write of this seat:** this file. No other path was created or modified.
- `LOG.md`, `SCORECARD.md`, `SHONEN.md`, `SKILL.md`, `PROVINCE.md` untouched; the 3 pre-existing `reports/round-101/` files (`bpy-dissection.md`, `navagent-dissection.md`, `r101-unknowns-map.md`) untouched.
- No commits, no pushes.
- The upstream clone at `/tmp/ue-skills-ref` was read-only at the pinned SHA (§7); no engine, no editor, no MCP server was launched or started by this seat.
- **Not owned by this card:** `corpus/knowledge/unreal-mcp/README.md` (the index, authored by another seat) and `.manifest.d/` manifests. This card neither edits nor contradicts them; the index already reserves row 10 for this filename.

## 11. Cross-references

- Upstream corpus (vendored, byte-identical): `corpus/knowledge/unreal-mcp/upstream/`
- Per-file hashes: `corpus/knowledge/unreal-mcp/.manifest.d/seat01.sha256` … `seat11.sha256`, plus `audit-reference.sha256`
- Sibling cards: `corpus/knowledge/unreal-mcp/executability/` — `blueprints.md` (card 2), `animation-controlrig.md` (card 6, the other no-toolset domain), `meshes-textures.md` (card 5, the physics/collision boundary), `actors-scene.md` (card 1, the `unproven-runtime` contrast), `scripting-programmatic.md` (card 13, the `execute_tool_script` escape hatch)
- Engine execution reality: `corpus/knowledge/engines.md` — Unreal Engine row `installed = no`, `executable headless = no`
- Domain census: `reports/round-101/probes/toolset-census.md` (§E3 records Gameplay as one of 3 domains with no named toolset)
- Round unknowns map: `reports/round-101/r101-unknowns-map.md`

Confidence marks: **[O]** receipt-pinned observation (every count, hash and probe above), **[I]** inference (the one-toolset-vs-several reading of the bullet; the physics/collision cross-card boundary), **[?]** unknown (every runtime fact, and every GAS semantics question).
