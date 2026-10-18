# Verdict Card — Animation (Control Rigs / State Trees / Behavior Trees)

**Subsystem:** Animation (`README.md:105` — "build Control Rigs, inspect State Trees and Behavior Trees")
**Label:** `static-only`
**Seat:** SEAT-36 EXEC
**Card 6 of the 13-subsystem set (C2)**
**Upstream pin:** `EpicGames/unreal-engine-skills-for-claude-code-plugin` @ `a6aa73ada02a9fb1f5415bec491f9942c519b297`
**Vendored at:** `corpus/knowledge/unreal-mcp/upstream/`
**Label basis:** every fact below is a document claim read from the vendored bytes; no Animation tool was ever executed, because no editor exists on this host. Nothing here has been observed at runtime.

---

## 1. Why this label, in one line

The Animation domain has **exactly one line of its own** in the entire 1022-line corpus — `README.md:105` — and that line is prose. The subsystem is the only one of the 13 with **no named toolset at all**: `ControlRig`, `StateTree` and `BehaviorTree` as tokens return **0 hits**, no Animation-domain tool name exists anywhere (corpus-wide there are only 2 tool-name tokens, both negative examples from other domains), and the words that would anchor an execution contract (montage, blend space, anim sequence, retarget, IK) are absent. The corpus is sufficient to **route** an Animation request and insufficient even to name a function.

## 2. Exhaustive mention sweep (the whole Animation surface)

Command actually run, from `corpus/knowledge/unreal-mcp/upstream/`:

```
$ grep -rnE 'Control ?Rig|State ?Tree|Behaviou?r ?Tree|[Aa]nimation|[Ss]keletal|[Bb]one' . | cut -d: -f1,2 | sort -u
./.claude-plugin/plugin.json:4
./README.md:104
./README.md:105
./README.md:106
./README.md:3
./skills/unreal-mcp/SKILL.md:3
./skills/unreal-mcp/SKILL.md:8
```

**7 matching lines, 3 files.** Four of the seven are `README.md` lines, and only **one** of them — `README.md:105` — belongs to the Animation domain; `README.md:104` is the *Meshes and Textures* bullet, `README.md:106` is the *Sequencer* bullet, and `README.md:3` / `plugin.json:4` / `SKILL.md:8` are the shared teaser sentence. So the Animation domain's unique textual footprint is **one line out of 1022** (0.10%).

Per-term counts, with the resolving location of every hit:

```
$ for t in 'ControlRig' 'Control Rig' 'StateTree' 'State Tree' 'BehaviorTree' 'Behavior Tree' \
           'AnimBlueprint' 'AnimMontage' 'BlendSpace' 'AnimSequence' 'SkeletalMesh' 'Skeleton' \
           'PhysicsAsset' 'IK' 'Retarget' 'Bone' 'CR_' 'ABP_' 'SK_'; do
    printf '%-16s %2s  %s\n' "$t" "$(grep -rnoF "$t" . | wc -l)" "$(grep -rnoF "$t" . | cut -d: -f1,2 | sort -u | tr '\n' ' ')"
  done
```

Observed output:

```
ControlRig        0
Control Rig       6  ./.claude-plugin/plugin.json:4 ./README.md:105 ./README.md:106 ./README.md:3 ./skills/unreal-mcp/SKILL.md:3 ./skills/unreal-mcp/SKILL.md:8
StateTree         0
State Tree        3  ./.claude-plugin/plugin.json:4 ./README.md:105 ./README.md:3
BehaviorTree      0
Behavior Tree     2  ./README.md:105 ./skills/unreal-mcp/SKILL.md:3
AnimBlueprint     0
AnimMontage       0
BlendSpace        0
AnimSequence      0
SkeletalMesh      0
Skeleton          0
PhysicsAsset      0
IK                0
Retarget          0
Bone              0
CR_               1  ./skills/unreal-mcp/SKILL.md:3
ABP_              1  ./skills/unreal-mcp/SKILL.md:3
SK_               1  ./skills/unreal-mcp/SKILL.md:3
```

Two things are load-bearing here. First, the **concatenated class-name spellings are all zero** — `ControlRig`, `StateTree`, `BehaviorTree` never appear as identifiers, only as two-word English prose. Second, `Control Rig` is the only Animation term that escapes the domain bullet: it appears in the *Sequencer* bullet (`README.md:106`, "Control Rig integration") and twice in the shared teaser. **The Animation domain does not own its own headline capability.**

Corpus-wide tool-name-shaped tokens (`.`-qualified, i.e. what a call would look like):

```
$ grep -rnoE "[A-Za-z]+Tools\.[A-Za-z_]+" . | sort -u
./skills/unreal-mcp/SKILL.md:16:BlueprintTools.create
./skills/unreal-mcp/SKILL.md:16:SequencerTools.create_level_sequence
```

**Exactly two, and both are negative examples** shown deliberately as *not* in `tools/list`. There is **no** `ControlRigTools.*`, `StateTreeTools.*`, `BehaviorTreeTools.*`, or any other Animation-domain tool name in the corpus.

Every real toolset class token present, for contrast:

```
$ grep -rhoE "\b[A-Z][A-Za-z]*Toolset\b" . | sort -u
AgentSkillToolset
AIAssistantToolset
AutomationTestToolset
LiveCodingToolset
MyToolset
ProgrammaticToolset
UMyToolset
```

`MyToolset`/`UMyToolset` are `create-toolset` placeholders, not real. **No Animation toolset class appears.**

## 3. Static-only facts, each with a resolvable pointer

Paths are relative to `corpus/knowledge/unreal-mcp/upstream/`. Line numbers verified against the vendored bytes with `grep -n` / `awk`.

Short forms resolve as: `README.md` → `upstream/README.md`; `plugin.json` → `upstream/.claude-plugin/plugin.json`; `SKILL.md` → `upstream/skills/unreal-mcp/SKILL.md`; `create-toolset/SKILL.md` → `upstream/skills/create-toolset/SKILL.md`; `references/setup.md` and `references/operations.md` → `upstream/skills/unreal-mcp/references/…`. Every one of these was checked to exist at the cited line with the verification harness in §6.

### 3.1 The capability claim (all of it)

| # | Fact | Pointer |
|---|---|---|
| F1 | The **entire** functional description of the subsystem: "**Animation** - build Control Rigs, inspect State Trees and Behavior Trees". One verb pair, three nouns, no tool, no schema, no return contract. | `README.md:105` |
| F2 | The domain is counted in the aggregate inventory: "Hundreds of tools exposed via Unreal's ToolsetRegistry across 30+ toolsets: actors, blueprints, materials, Niagara, **Control Rigs**, Sequencer, **State Trees**, widgets, Gameplay Ability System, automation testing, and more." Note the top-level list names Control Rigs and State Trees but **not** Behavior Trees. | `README.md:3` |
| F3 | Third copy of the claim, in plugin metadata (machine-readable, version `3.1.1`), identical wording to F2. | `.claude-plugin/plugin.json:4` |
| F4 | Fourth copy, in the core skill body: "The server exposes hundreds of tools across 30+ toolsets (actors, blueprints, materials, Niagara, Sequencer, **Control Rigs**, GAS, automation tests, Live Coding, and more)". Here State Trees and Behavior Trees drop out entirely. | `skills/unreal-mcp/SKILL.md:8` |

The four statements do not agree on the subsystem's own inventory: `README.md:3`/`plugin.json:4` name Control Rigs + State Trees, `SKILL.md:8` names Control Rigs only, and only `README.md:105` mentions Behavior Trees at all. There is no canonical enumeration to anchor against.

### 3.2 The dispatch contract (how an Animation call would be addressed)

| # | Fact | Pointer |
|---|---|---|
| F5 | Animation tool names are **not** in `tools/list`. Toolset tools are dispatched server-side through `call_tool` with `toolset_name`, `tool_name`, `arguments`. `BlueprintTools.create` and `SequencerTools.create_level_sequence` are the corpus's two worked examples of that name shape. | `skills/unreal-mcp/SKILL.md:16` |
| F6 | The intended first move is discovery: "Call `list_toolsets` to see what's registered, then `describe_toolset` on the candidate(s) to read their tool schemas." **The Animation schemas are only knowable from a live editor**, never from this corpus. | `skills/unreal-mcp/SKILL.md:20` |
| F7 | Meta-tool set is exactly three: `list_toolsets`, `describe_toolset`, `call_tool`; top-level dispatch omitting `toolset_name` is rejected for `call_tool` itself. | `skills/unreal-mcp/SKILL.md:16`, `:22` |
| F8 | Tool search is on by default via `bEnableToolSearch` on `UModelContextProtocolSettings`; setting it `False` registers every toolset tool as a native MCP tool upfront with schemas visible. This is the switch that would make Animation tool names visible in `tools/list`. | `README.md:82`, `references/operations.md:18–21` |
| F9 | A toolset that seems missing (the doc's own example is `NiagaraTools`) is repaired with `ModelContextProtocol.RefreshTools`; if still missing, the toolset's **plugin** may not be enabled in the `.uproject`. Same procedure would govern any Control Rig / State Tree / Behavior Tree toolset. | `references/operations.md:13`, `:48` |

### 3.3 Prerequisites and gating (what must be true before an Animation call can work)

| # | Fact | Pointer |
|---|---|---|
| F10 | Two plugins are required and `AllToolsets` is the one that "provides the tools; the server exposes none without it". `AllToolsets` is an editor-only aggregator with `EnabledByDefault` off, so it must be enabled explicitly in the `.uproject`. To expose only a subset, enable the specific toolset plugins instead. | `README.md:17`, `references/setup.md:14`, `:31` |
| F11 | Editor must be **running** with the MCP server started (`ModelContextProtocol.StartServer`, or `bAutoStartServer=True`). The optional proxy keeps the *client* session open while the editor is down but does not make tools callable. | `README.md:18`, `references/setup.md:35–46`, `README.md:78` |
| F12 | Default endpoint `localhost:8000`, path `/mcp`; no static `.mcp.json` ships — it is generated by `ModelContextProtocol.GenerateClientConfig ClaudeCode`. | `README.md:70–72`, `references/setup.md:57–79` |
| F13 | Linux is a supported platform for the client side (macOS / Linux / Windows-via-Git-Bash-or-WSL). The only bash dependency is the SessionStart hook. | `README.md:23–28` |

### 3.4 Behavioral hazards relevant to Animation work

The corpus's only operational statements that touch rigs, skeletons or graph-authored assets are **warnings**. None is Animation-specific; each is a generic live-editor rule that an Animation call would inherit.

| # | Fact | Pointer |
|---|---|---|
| F14 | "**Save first, then save again.** ... MCP edits are not always undoable, especially across compilation boundaries. Treat anything that touches multiple assets as a destructive operation that needs a recovery point." A Control Rig graph edit is exactly a multi-asset, compile-adjacent edit. | `skills/unreal-mcp/SKILL.md:30` |
| F15 | "**Always check the result.** ... many tools return a status that flips between success and failure with no exception thrown on the wire. Read the response before moving on. Treat anything that isn't an explicit success as a stop." The named examples are Blueprint compile, widget creation, material edits — **not** rig or tree compilation, so no Animation-specific failure signature is documented. | `skills/unreal-mcp/SKILL.md:33` |
| F16 | Tool calls hang or fail confusingly while C++ or shader compilation is in flight; `LiveCodingToolset.CompileLiveCoding` blocks until the compile actually finishes. This is the only compile tool named in the corpus and it is **not** any Animation compile path. | `skills/unreal-mcp/SKILL.md:31`, `references/operations.md:49` |
| F17 | Concurrency: "Serialize dependent calls and mutations that can affect the same asset or editor state. ... Multiple agents can use one editor, but their conflicting changes can cause adverse effects." Directly relevant to graph edits on one rig or tree asset. | `skills/unreal-mcp/SKILL.md:32`, `references/operations.md:51` |
| F18 | "**Mind PIE.** Editor-only tools (asset creation in particular) behave differently while Play-in-Editor is active." | `skills/unreal-mcp/SKILL.md:34` |
| F19 | `ProgrammaticToolset.execute_tool_script` executes arbitrary Python inside the editor with "full access to every toolset API" — the documented escape hatch that would reach an Animation toolset even if no named tool surfaced. Treated as privileged, not as an Animation capability. | `README.md:90` |

### 3.5 Triggering (when the agent is told to reach for Animation at all)

| # | Fact | Pointer |
|---|---|---|
| F20 | The skill triggers on "create or edit a ... **Control Rig**/Sequencer/**Behavior Tree**/GAS ability" and on the asset prefixes `` `BP_`, `WBP_`, `M_`, `MI_`, `NS_`, `CR_`, `SK_`, `SM_`, `ABP_` ``. `CR_` (Control Rig), `ABP_` (Animation Blueprint) and `SK_` (Skeletal Mesh) are the only Animation-adjacent identifiers in the corpus — each appears **once**, in this one trigger list. | `skills/unreal-mcp/SKILL.md:3` |
| F21 | Explicit skip condition: unrelated uses of the word "sequencer"/"widget"/"blueprint" must not trigger the skill. A disambiguation rule, not a capability. | `skills/unreal-mcp/SKILL.md:3` |
| F22 | When no editor is available, the authoring skill's fallback is to "search the codebase for folders named `Toolsets` and read the C++ headers or Python toolset files there". **This is the only documented route to Animation tool signatures without a live editor** — and it requires the engine source, which this host does not have. | `skills/create-toolset/SKILL.md:26` |
| F23 | The Python route to rig/animation APIs is a stub file at `<project_root>/Intermediate/PythonStub/unreal.py`, which exists only after **Developer Mode** is enabled in the editor and the editor restarted. Not available here, and not a corpus artifact. | `skills/create-toolset/SKILL.md:36–37` |

## 4. What is conspicuously absent (the gap that forces `static-only`)

Searched for and **not found** anywhere in the 1022 vendored lines:

- **Any Animation toolset name.** `ControlRigToolset`, `ControlRigTools`, `StateTreeToolset`, `StateTreeTools`, `BehaviorTreeToolset`, `BehaviorTreeTools` → 0 hits each. The domain is the only one of the 13 with no toolset named for it; contrast `SequencerTools` (`SKILL.md:16`), `BlueprintTools` (`create-toolset/SKILL.md:3`), `StaticMeshTools` (`create-toolset/SKILL.md:3`).
- **Any Animation tool method.** Zero `.`-qualified names. The corpus's only two tool names are the negative examples `BlueprintTools.create` / `SequencerTools.create_level_sequence` (`SKILL.md:16`).
- **Any parameter list, return type, or JSON schema** for a rig, state-tree, or behavior-tree tool.
- **Any representation of a rig, a graph, a state, a transition, a task, or a blackboard.** The words "graph"/"node"/"pin" exist only in the Blueprints bullet (`README.md:101`); none of them is tied to Animation.
- **Any statement of what compiling or inspecting a rig/tree returns.** F15's silent-failure warning names Blueprint compile, widget creation and material edits — Animation compilation is never mentioned.
- **The supporting vocabulary entirely.** `AnimBlueprint`, `AnimMontage`, `BlendSpace`, `AnimSequence`, `SkeletalMesh`, `Skeleton`, `PhysicsAsset`, `IK`, `Retarget` → 0 hits each. `skeletal` and `bone` occur once each, and in the **Meshes and Textures** bullet (`README.md:104`), not here.
- **Any toolset member count.** "Hundreds of tools ... 30+ toolsets" (`README.md:3`) is aggregate and unverifiable from here.

Consequence: the corpus is sufficient to **route** an Animation request (F6, F20) and to **warn** about it (F14–F19), and insufficient to **execute** it. Hence `static-only`, not `verified-here`.

## 5. Why not `verified-here`, and why not `unproven-runtime`

- **Not `verified-here`:** no Animation tool call was made. No editor is installed (see §6), so no `describe_toolset` result for a rig/tree toolset exists to cite. Nothing about Animation behavior was observed. The only things proven here are static and are listed in §6.
- **Not `unproven-runtime`:** that label would assert a real, identified runtime path that merely went untested. Here the path is not even identified — the toolset name is unknown by construction, because the corpus defers signatures to a live `describe_toolset` (F6). The correct statement is weaker: the surface is documented as existing and is not specified. That is `static-only`.

The distinction matters for calibration: `unproven-runtime` invites "someone just needs to run it"; `static-only` correctly says "running it is necessary *and* the artifacts to run it against are not in hand."

## 6. Host receipts (re-derived this round, not quoted)

All commands run on this host; observed output recorded.

| Check | Command | Observed |
|---|---|---|
| Editor binary absent | `which UnrealEditor UnrealEditor-Cmd UnrealEditor-Linux-Shipping` | `which: no UnrealEditor in (...)`; same for `UnrealEditor-Cmd`, `UnrealEditor-Linux-Shipping` |
| Engine tree absent | `ls -d /opt/UnrealEngine /opt/unreal-engine ~/UnrealEngine /usr/share/unreal-engine` | `No such file or directory` ×4 |
| No engine package | `pacman -Qq \| grep -iE '^unreal'` | no output — no unreal package installed |
| No MCP server listening | `ss -ltnp \| grep -E ':8000'` | no output — no listener on 8000 |
| No generated client config | `ls -la .mcp.json` | `No such file or directory` |
| Host capacity | `nproc` / `free -g` / `df -h /` | 32 cores; 30 G RAM; 780 G free on `/` |
| Toolchain | `command -v jq python3 node shellcheck docker` | all present (`jq` 1.8.2, Python 3.14.7, Node v26.12.0, `shellcheck` 0.11.0) |
| Engine fetch blocked | `gh auth status` + `git ls-remote https://github.com/EpicGames/unreal-engine` | authed as `VeigaPunk` (not Epic-linked); `remote: Repository not found.` |
| Engine build blocked | AUR `unreal-engine` PKGBUILD, line 280 | `if ! git ls-remote git@github.com:EpicGames/UnrealEngine &>/dev/null; then` (also 327, 336 — `git clone --depth=1 --branch=${pkgver}-release git@github.com:EpicGames/UnrealEngine`) |
| Upstream pin confirmed | `git -C /tmp/ue-skills-ref rev-parse HEAD` | `a6aa73ada02a9fb1f5415bec491f9942c519b297` — equals the pin |
| Pin commit | `git -C /tmp/ue-skills-ref log -1 --format='%ci %s'` | `2026-09-17 13:28:32 +1200 [MCP] Permit safe concurrent tool calls` |
| Vendoring byte-identical | file-list `diff` vs `/tmp/ue-skills-ref`; `sha256sum -c .manifest.d/audit-reference.sha256` | `FILELIST-IDENTICAL`; **12/12 `OK`**, 0 failures |
| Vendored README hash | `sha256sum upstream/README.md` | `483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e` (matches clone) |
| Pointer harness (this card) | Python over the card's own text: parse every `` `path:line` `` and assert the cited line of the cited vendored file contains the quoted substring | **35/35 line pointers OK, 0 failures**; short forms resolved per §3's key (`SKILL.md`→`skills/unreal-mcp/SKILL.md`, `plugin.json`→`.claude-plugin/plugin.json`, `references/*`→`skills/unreal-mcp/references/*`, `create-toolset/SKILL.md`→`skills/create-toolset/SKILL.md`) |

The AUR PKGBUILD requires **SSH** access to the private `EpicGames/UnrealEngine` repository (lines 280, 327, 336), which requires an Epic account linked to GitHub. That link is operator-owned and is not in place. Therefore the engine cannot be built here, and F10–F12 can never be satisfied on this host as configured.

## 7. Unlock condition

The label flips from `static-only` to `unproven-runtime`/`verified-here` only through this chain, in order:

1. **Operator action (blocking, not automatable here):** link the Epic Games account to the GitHub account so `git@github.com:EpicGames/UnrealEngine` becomes reachable. Nothing downstream can be attempted before this.
2. Build or install the engine — e.g. the AUR `unreal-engine` package, whose PKGBUILD is the one probed in §6.
3. Create/open a `.uproject` with **both** `ModelContextProtocol` and `AllToolsets` enabled (`references/setup.md:14–31`). Without `AllToolsets`, the server starts and exposes no tools — Animation included.
4. Launch the editor and start the server: `ModelContextProtocol.StartServer` (`references/operations.md:11`), or `bAutoStartServer=True` (`references/setup.md:43–46`).
5. Generate the client config: `ModelContextProtocol.GenerateClientConfig ClaudeCode` (`references/setup.md:61`), producing `.mcp.json` at the location matching the build kind (`references/setup.md:63–66`).
6. **First real verification, the cheapest possible — and here it is unusually load-bearing:** call `list_toolsets`, then `describe_toolset` on the candidate Animation toolset. **The toolset's own name is unknown from this corpus** (§4), so the unlock requires reading the returned catalog to *find* it, not just to read its schema. This one step converts both the name and the entire signature gap from unknown to known.
7. Only then can any claim about Control Rigs, State Trees or Behavior Trees be tested, and each would still need its own `call_tool` receipt before it could be called verified.

Until step 1 happens, every Animation claim in this card remains a document claim. **No Animation tool has been executed on this host, and none can be.**

## 8. Cross-references

- Upstream corpus (vendored, byte-identical): `corpus/knowledge/unreal-mcp/upstream/`
- Per-file hashes: `corpus/knowledge/unreal-mcp/.manifest.d/seat01.sha256` … `seat11.sha256` + `audit-reference.sha256`
- Corpus index (card set, verification policy, host reality): `corpus/knowledge/unreal-mcp/README.md`
- Round unknowns map: `reports/round-101/r101-unknowns-map.md`
- Adjacent subsystems dissected this round: `reports/round-101/bpy-dissection.md`, `reports/round-101/navagent-dissection.md`
- Sibling cards in this set: `corpus/knowledge/unreal-mcp/executability/` (this is card 6 of 13)
- **Overlap boundaries to respect when reading adjacent cards:**
  - **Sequencer (card 7)** also claims Control Rig — `README.md:106` says "Control Rig integration". `executability/sequencer.md` flags the same collision from its side and calls it "a coverage question, not an executability one". The split agreed here: this card covers rig *authoring* (`README.md:105`, "build Control Rigs"); keyframing a rig inside a Level Sequence stays with the Sequencer card. Neither card's **label** turns on the split — both are `static-only` on independent evidence.
  - **Meshes and Textures (card 5)** owns `skeletal` and `bone` — both words occur only in `README.md:104`, and `executability/meshes-textures.md` counts them as hapax legomena in its own sweep. Skeleton/bone *inspection* is that card's surface, not this one.

## 9. Boundary note (scope honesty)

This card is a **depth** artifact for C2. It does not attempt the C3 Claude→Kimi adaptation table, which is the C3 seat's deliverable at `corpus/knowledge/unreal-mcp/adaptation-kimi.md` (the path is declared in the corpus index, `corpus/knowledge/unreal-mcp/README.md:110`, which itself marks it `← Claude→Kimi adaptation table (pending: another seat)`; the file was **not present on disk when this card was written** — `ls` → `No such file or directory` — so this is a forward pointer, not a citation of existing bytes). The generic mapping rows (plugin install channel, `SessionStart` hook, the three meta-tools, `/mcp` vs `list_toolsets`, `GenerateClientConfig` client enum, safety rules, `--dangerously-skip-permissions`) are client-level and identical for every subsystem, so restating them here would add no Animation-specific information.

One Animation-specific calibration consequence *is* recorded here because it changes how the card must be read: upstream's own four capability statements disagree about what the Animation domain contains (F1–F4). A downstream consumer must not treat `README.md:3`, `plugin.json:4`, `SKILL.md:8` and `README.md:105` as a redundant enumeration of the same set — they name three different sets, and only `README.md:105` mentions Behavior Trees.
