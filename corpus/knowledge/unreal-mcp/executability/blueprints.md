# Verdict Card — Blueprints (create / edit graphs / nodes / pins / variables / compile)

**Subsystem:** Blueprints (`BlueprintTools` toolset, plus the Blueprint asset editor as a UI surface)
**Label:** `static-only`
**Seat:** SEAT-32 EXEC · **Round:** r101 · **Lane:** game-dev-3d shokunin · **Claim:** C2 (depth)
**Upstream pin:** `EpicGames/unreal-engine-skills-for-claude-code-plugin` @ `a6aa73ada02a9fb1f5415bec491f9942c519b297`
**Vendored at:** `corpus/knowledge/unreal-mcp/upstream/`
**Label basis:** every fact below is a document claim read from the vendored bytes; no Blueprint tool was ever executed, because no editor exists on this host. Nothing here has been observed at runtime.

---

## 1. Why this label, in one line

The vendored corpus **advertises** a full Blueprint surface and **specifies none of it**. There is not one tool signature, node/pin schema, graph representation, or compile-result contract anywhere in the 1022 vendored lines. A reader can learn that Blueprint capability exists and that `BlueprintTools.create` is its name shape, but cannot call it, type it, or predict its return.

## 2. Exhaustive mention sweep (the whole Blueprint surface)

Command actually run, from `corpus/knowledge/unreal-mcp/upstream/`:

```
$ grep -rniE "blueprint" . | wc -l
14
$ grep -rniE "blueprint" . | cut -d: -f1 | sort | uniq -c
      1 ./.claude-plugin/plugin.json
      3 ./README.md
      4 ./skills/create-toolset/SKILL.md
      1 ./skills/unreal-mcp/references/operations.md
      5 ./skills/unreal-mcp/SKILL.md
```

**14 mentions, 5 files, 0 signatures.** The whole corpus is 1022 lines (`find . -type f -exec wc -l {} +` over all 12 files), so Blueprint is ~1.4% of the vendored text by line, and all of it is prose.

Command actually run, for tool-name-shaped tokens:

```
$ grep -rnoE "[A-Za-z]+Tools\.[A-Za-z_]+" . | sort -u
./skills/unreal-mcp/SKILL.md:16:BlueprintTools.create
./skills/unreal-mcp/SKILL.md:16:SequencerTools.create_level_sequence
```

Exactly **one** Blueprint tool name appears in the entire corpus, and it appears as a **negative example** — a name deliberately shown as *not* present in `tools/list`. There is no `create_graph`, no `add_node`, no `connect_pin`, no `compile` token anywhere.

## 3. Static-only facts, each with a resolvable pointer

Paths are relative to `corpus/knowledge/unreal-mcp/upstream/`. Line numbers verified against the vendored bytes with `grep -n` / `sed -n`.

### 3.1 The capability claim (all of it)

| # | Fact | Pointer |
|---|---|---|
| F1 | Capability is asserted as a flat bullet: "**Blueprints** - create, edit graphs, add nodes, connect pins, manage variables, compile". This is the **entire** functional description of the subsystem in the corpus. | `README.md:101` |
| F2 | The same claim is repeated in the top-level inventory: "Hundreds of tools ... across 30+ toolsets: actors, blueprints, materials, Niagara, ..." | `README.md:3` |
| F3 | Third copy of the claim, in plugin metadata (machine-readable, version `3.1.1`). | `.claude-plugin/plugin.json:4` |
| F4 | A Blueprint toolset is named as an **existing** toolset that `create-toolset` may extend — i.e. the authoring skill assumes `BlueprintTools` is real, but never enumerates it. | `skills/create-toolset/SKILL.md:3` |
| F5 | `BlueprintTools` is also given as the *wrong* home for a task: "read blueprint asset metadata" sounds like `BlueprintTools` but belongs in `AssetTools`. Confirms the toolset exists; still no members. | `skills/create-toolset/SKILL.md:28` |

### 3.2 The dispatch contract (how a Blueprint call would be addressed)

| # | Fact | Pointer |
|---|---|---|
| F6 | `BlueprintTools.create` is **not** in `tools/list`. Toolset tools are dispatched server-side through `call_tool` with `toolset_name`, `tool_name`, `arguments`. | `skills/unreal-mcp/SKILL.md:16` |
| F7 | The intended first move for a Blueprint task: "the user said 'make a Blueprint' → the Blueprint toolset ... go straight to `describe_toolset` to confirm the available tools and their signatures". So **the signatures are only knowable from a live editor**, never from this corpus. | `skills/unreal-mcp/SKILL.md:20` |
| F8 | Meta-tool set is exactly three: `list_toolsets`, `describe_toolset`, `call_tool`. Top-level dispatch omitting `toolset_name` is rejected for `call_tool` itself. | `skills/unreal-mcp/SKILL.md:16`, `skills/unreal-mcp/SKILL.md:22` |
| F9 | Tool search is on by default via `bEnableToolSearch` on `UModelContextProtocolSettings`; setting it `False` registers every toolset tool as a native MCP tool upfront. This is the switch that would make Blueprint tool names visible in `tools/list`. | `README.md:82`, `references/operations.md:18-21` |
| F10 | A toolset that seems missing (the doc's own example is `NiagaraTools`) is repaired with `ModelContextProtocol.RefreshTools`; if still missing, the toolset's **plugin** may not be enabled in the `.uproject`. Same procedure would govern `BlueprintTools`. | `references/operations.md:13`, `references/operations.md:48` |

### 3.3 Prerequisites and gating (what must be true before a Blueprint call can work)

| # | Fact | Pointer |
|---|---|---|
| F11 | Two plugins are required and `AllToolsets` is the one that "provides the tools; the server exposes none without it". `AllToolsets` is editor-only with `EnabledByDefault` off, so it must be enabled explicitly in the `.uproject`. | `README.md:17`, `references/setup.md:14`, `references/setup.md:31` |
| F12 | Editor must be **running** with the MCP server started (`ModelContextProtocol.StartServer`, or `bAutoStartServer=True`). The optional proxy keeps the *client* session open while the editor is down but does not make tools callable. | `README.md:18`, `references/setup.md:35-46`, `README.md:78` |
| F13 | Default endpoint `localhost:8000`, path `/mcp`; no static `.mcp.json` ships — it is generated by `ModelContextProtocol.GenerateClientConfig ClaudeCode`. | `README.md:70-72`, `references/setup.md:57-79` |
| F14 | Linux is a supported platform for the client side (macOS / Linux / Windows-via-Git-Bash-or-WSL). The only bash dependency is the SessionStart hook. | `README.md:23-28` |

### 3.4 Behavioral hazards specific to Blueprint work

These are the corpus's only operational claims about Blueprints, and they are all **warnings**, which is itself evidence that the author knew the surface was under-specified.

| # | Fact | Pointer |
|---|---|---|
| F15 | "**Always check the result.** Blueprint compilation, widget creation, material edits: many tools return a status that flips between success and failure with no exception thrown on the wire." Blueprint compile is named as the flagship example of a silent-failure surface. | `skills/unreal-mcp/SKILL.md:33` |
| F16 | MCP edits are "not always undoable, especially across compilation boundaries" — i.e. a Blueprint compile can pass the point of no return. Save before and after any bulk change. | `skills/unreal-mcp/SKILL.md:30` |
| F17 | Tool calls hang or fail confusingly while C++ or shader compilation is in flight; drive `LiveCodingToolset.CompileLiveCoding` and wait on its result, since it blocks until the compile actually finishes. This is the *only* compile tool named in the corpus, and it is **not** the Blueprint compile path. | `skills/unreal-mcp/SKILL.md:31`, `references/operations.md:49` |
| F18 | PIE changes editor-only behavior: "asset creation in particular". A Blueprint creation call made while Play-in-Editor is active can behave differently. | `skills/unreal-mcp/SKILL.md:34` |
| F19 | Concurrency: serialize dependent calls and mutations that can affect the same asset. Multiple agents may share one editor and conflict. Directly relevant to multi-node graph edits. | `skills/unreal-mcp/SKILL.md:32`, `references/operations.md:51` |
| F20 | `AIAssistantToolset.GetDockedContext` returns empty unless the Claude Code tab is **docked inside an asset editor (Blueprint, Material, etc.)**. The only place a Blueprint *asset editor* is treated as a first-class UI surface. | `references/operations.md:50` |

### 3.5 Triggering (when the agent is told to reach for Blueprints at all)

| # | Fact | Pointer |
|---|---|---|
| F21 | The skill triggers on `BP_` and `ABP_` asset prefixes, and on concrete verbs: "create or edit a Blueprint/Widget/Material/...", "read or write properties on actors (e.g. `bIsLocked` on `BP_DoorActor`)". `BP_DoorActor` is the only concrete Blueprint asset named in the corpus. | `skills/unreal-mcp/SKILL.md:3` |
| F22 | Explicit skip condition: unrelated uses of the word "blueprint" (and "sequencer"/"widget") must not trigger the skill. A disambiguation rule, not a capability. | `skills/unreal-mcp/SKILL.md:3` |
| F23 | When no editor is available, the authoring skill's fallback is to "search the codebase for folders named `Toolsets` and read the C++ headers or Python toolset files there". **This is the only documented route to Blueprint tool signatures without a live editor** — and it requires the engine source, which this host does not have. | `skills/create-toolset/SKILL.md:26` |

## 4. What is conspicuously absent (the gap that forces `static-only`)

Searched for and **not found** anywhere in the 1022 vendored lines:

- Any `BlueprintTools` method name other than the negative example `BlueprintTools.create` (`grep -rnoE "[A-Za-z]+Tools\.[A-Za-z_]+"` → 2 hits total, corpus-wide).
- Any parameter list, return type, or JSON schema for a Blueprint tool.
- Any representation of a **graph**, a **node**, or a **pin** — the words appear only in the `README.md:101` capability bullet. No type, no ID scheme, no connection semantics.
- Any statement of what "compile" returns, or how a Blueprint compile failure is surfaced beyond the generic "check the result" warning (F15).
- Any variable-management contract: the corpus says "manage variables" (`README.md:101`) and nothing else. Note the related but distinct rule that asset **metadata** lives in `AssetTools`, not `BlueprintTools` (`create-toolset/SKILL.md:28`).
- Any toolset member count. "Hundreds of tools ... 30+ toolsets" (`README.md:3`) is aggregate and unverifiable from here.

Consequence: the corpus is sufficient to **route** a Blueprint request (F6, F7, F21) and to **warn** about it (F15–F20), and insufficient to **execute** it. Hence `static-only`, not `verified-here`.

## 5. Why not `verified-here`, and why not `unproven-runtime`

- **Not `verified-here`:** no Blueprint tool call was made. No editor is installed (see §6), so no `describe_toolset BlueprintTools` result exists to cite. Nothing about Blueprint behavior was observed.
- **Not `unproven-runtime`:** that label would assert a real, identified runtime path that merely went untested. Here the path is not even identified — the signatures are unknown by construction, because the corpus defers them to a live `describe_toolset` (F7). The correct statement is weaker: the surface is documented as existing and is not specified. That is `static-only`.

The distinction matters for calibration: `unproven-runtime` invites "someone just needs to run it"; `static-only` correctly says "running it is necessary *and* the artifacts to run it against are not in hand."

## 6. Host receipts (re-derived this round, not quoted)

All commands run on this host; observed output recorded.

| Check | Command | Observed |
|---|---|---|
| Editor binary absent | `which UnrealEditor UnrealEditor-Cmd` | `which: no UnrealEditor in (...)`; `which: no UnrealEditor-Cmd in (...)` |
| Engine tree absent | `ls -d /opt/UnrealEngine /opt/unreal-engine ~/UnrealEngine` | `No such file or directory` ×3 |
| No MCP server listening | `ss -ltnp \| grep -E ':8000'` | no output — no listener on 8000 |
| No generated client config | `ls -la .mcp.json` | `No such file or directory` |
| Host capacity | `nproc` / `free -g` / `df -h /` | 32 cores; 30G RAM; 780G free on `/` |
| Toolchain | `which jq python3 node shellcheck docker` | all present (`shellcheck` 0.11.0, `/usr/bin/shellcheck`) |
| Engine fetch blocked | `curl -s "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=unreal-engine" \| grep -n "git@github.com"` | `280: if ! git ls-remote git@github.com:EpicGames/UnrealEngine &>/dev/null; then` (also lines 327, 336 — `git clone --depth=1 --branch=${pkgver}-release git@github.com:EpicGames/UnrealEngine`) |
| Upstream pin confirmed | `git -C /tmp/ue-skills-ref rev-parse HEAD` | `a6aa73ada02a9fb1f5415bec491f9942c519b297` — equals the pin |
| Vendoring byte-identical | file-list `diff` + per-file `sha256sum` against `/tmp/ue-skills-ref` | `FILELIST-IDENTICAL`; `OK` for all 12 files |

The AUR PKGBUILD requires **SSH** access to the private `EpicGames/UnrealEngine` repository (lines 280, 327, 336), which requires an Epic account linked to GitHub. That link is operator-owned and is not in place (see the round's unknowns map). Therefore the engine cannot be built here, and F11–F13 can never be satisfied on this host as configured.

## 7. Unlock condition

The label flips from `static-only` to `unproven-runtime`/`verified-here` only through this chain, in order:

1. **Operator action (blocking, not automatable here):** link the Epic Games account to the GitHub account so `git@github.com:EpicGames/UnrealEngine` becomes reachable. Nothing downstream can be attempted before this.
2. Build or install the engine — e.g. the AUR `unreal-engine` package, whose PKGBUILD is the one probed in §6.
3. Create/open a `.uproject` with **both** `ModelContextProtocol` and `AllToolsets` enabled (`references/setup.md:14-31`). Without `AllToolsets`, the server starts and exposes no tools — Blueprint included.
4. Launch the editor and start the server: `ModelContextProtocol.StartServer` (`references/operations.md:11`), or `bAutoStartServer=True` (`references/setup.md:43-46`).
5. Generate the client config: `ModelContextProtocol.GenerateClientConfig ClaudeCode` (`references/setup.md:61`), producing `.mcp.json` at the location matching the build kind (`references/setup.md:63-66`).
6. **First real verification, the cheapest possible:** `list_toolsets`, then `describe_toolset` on `BlueprintTools`. This single call converts the entire §4 gap — signatures, parameter types, return shapes — from unknown to known, and is the cheapest unlock of any Blueprint claim in this corpus (F7).
7. Only then can any claim about graphs, nodes, pins, variables, or compile be tested, and each would still need its own `call_tool` receipt before it could be called verified.

Until step 1 happens, every Blueprint claim in this card remains a document claim. **No Blueprint tool has been executed on this host, and none can be.**

## 8. Cross-references

- Upstream corpus (vendored, byte-identical): `corpus/knowledge/unreal-mcp/upstream/`
- Per-file hashes: `corpus/knowledge/unreal-mcp/.manifest.d/seat01.sha256` … `seat11.sha256`
- Round unknowns map: `reports/round-101/r101-unknowns-map.md`
- Adjacent subsystems dissected this round: `reports/round-101/bpy-dissection.md`, `reports/round-101/navagent-dissection.md`
- Sibling verdict cards in this set: `corpus/knowledge/unreal-mcp/executability/` (one card per subsystem; list the directory rather than trusting any enumeration here, since cards are being written concurrently this round)
