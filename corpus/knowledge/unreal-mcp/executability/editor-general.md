# Editor domain — executability verdict card

**Subsystem:** Editor (screenshots, camera control, actor/asset selection, content browser, log inspection)
**Label:** `static-only`
**Seat:** SEAT-42 EXEC · **Round:** r101 · **Lane:** game-dev-3d shokunin · **Claim:** C2 (depth)
**Upstream pin:** `EpicGames/unreal-engine-skills-for-claude-code-plugin` @ `a6aa73ada02a9fb1f5415bec491f9942c519b297`
**Vendored at:** `corpus/knowledge/unreal-mcp/upstream/` (byte-identical — receipt R2)
**Label basis:** every fact below is a document claim read from the vendored bytes; no Editor tool
was ever executed, because no Unreal Editor exists on this host. Declared write path for this
seat: this file only.

Confidence tags: **[O]** receipt-pinned observation · **[I]** inference · **[?]** unknown.
Runtime status: **Unreal Editor is not installed on this host**, so no live tool call was
possible and none is asserted.

**Path shorthand used throughout.** Every pointer in this card is relative to the vendored
mirror root `corpus/knowledge/unreal-mcp/upstream/`. The two `references/*.md` files cited
constantly are shortened for readability:

- `references/setup.md` → `skills/unreal-mcp/references/setup.md`
- `references/operations.md` → `skills/unreal-mcp/references/operations.md`

So `references/setup.md:31` resolves to
`corpus/knowledge/unreal-mcp/upstream/skills/unreal-mcp/references/setup.md:31` (sha
`bd16206ea142dc9cc1950b88af526a3137072ea152c5662e8549d21bc18a3b8a`), and
`references/operations.md:34` to
`corpus/knowledge/unreal-mcp/upstream/skills/unreal-mcp/references/operations.md:34` (sha
`dbed002b4a46ab104274a31eb6682c3d277ce669216d0378df709f51567c3113`). All other pointers name
their full path from that root. **[O]**

---

## 1. Verdict

**`static-only`**

The Editor domain is **named** in the upstream plugin and its five advertised capabilities are
**enumerable from the pinned text**, but **no concrete Editor toolset class, no tool name, and
no tool schema exists anywhere in the plugin**. Nothing about this domain was executed, and
nothing here can be executed on this host. Every statement in this card is read from the
vendored bytes at the pinned SHA.

- Not `verified-here`: no command in this card exercises an Editor tool. (The only
  `verified-here` claims in this repo's r101 upstream work concern the *files* — pinned-SHA
  identity and the 12-file hash set — not the Editor domain's behaviour.)
- Not `unproven-runtime` **as the card label**: `unproven-runtime` correctly labels the
  *live-call* sub-claim (§5), but the card's own content is a static reading of pinned text, and
  the seat declares `static-only`. §5 states the runtime sub-claim explicitly so it is not lost.

The card is `static-only` because the evidence class is static and the domain is
under-specified upstream — a runtime attempt would first have to discover whether an Editor
toolset is registered at all (§6).

---

## 2. What the Editor domain claims (source of record)

The domain appears in **exactly one** place in the plugin: the `What's Available` bullet list in
`README.md`.

`README.md:111` — **[O]**

```
- **Editor** - screenshots, camera control, actor/asset selection, content browser, log inspection
```

That single line is the entire upstream specification of the domain. It is a *capability prose
bullet*, not a toolset manifest.

- `README.md` is 112 lines total; §`What's Available` is the bullet list at lines **100–112** and
  contains exactly 13 bullets — the Editor row is #12 of 13 (`grep -n "^- \*\*Editor\*\*" README.md`
  → `111:`; `sed -n '100,112p' README.md | grep -c '^- \*\*'` → `13`). **[O]**
- The sibling census seat (`reports/round-101/probes/toolset-census.md`, E3) records the same
  row and labels the 13 rows *coverage buckets*, not a 1:1 toolset list. **[O]**

---

## 3. Per-capability evidence

Five capabilities are claimed. For each: every occurrence of the concept in the plugin, with
the line, and what it actually is.

| # | Capability | All upstream occurrences | Verdict |
|---|---|---|---|
| 1 | screenshots | `README.md:111` (domain bullet); `skills/create-toolset/SKILL.md:144,150–173` | `static-only` — **no shipped tool** |
| 2 | camera control | `README.md:111`; `README.md:106` (Sequencer "manage cameras") | `static-only` — **no shipped tool** |
| 3 | actor/asset selection | `README.md:111` **only** | `static-only` — **prose only** |
| 4 | content browser | `README.md:111`; `skills/unreal-skill/SKILL.md:35,90,97` | `static-only` — **prose only** |
| 5 | log inspection | `README.md:111`; `README.md:63`; `references/setup.md:127`; `references/operations.md:40,46,47` | `static-only` — **prose only** |

### 3.1 screenshots — the one capability with any adjacent artifact

`screenshot` occurs in the plugin exactly **twice**, and neither is an Editor tool: **[O]**

```
$ grep -rn -i "screenshot" --include="*.md" --include="*.json" --include="*.sh" .
./skills/create-toolset/SKILL.md:144:Most tools are synchronous: they run on the game thread and return a value directly. Use async for long-running operations such as capturing a screenshot or waiting for an editor state change.
./README.md:111:- **Editor** - screenshots, camera control, actor/asset selection, content browser, log inspection
```

The `create-toolset` hit is an **illustrative async-tool example**, in a document about *authoring
a new toolset*. The sample tool is a template placeholder, not a shipped Editor tool: **[O]**

```
$ grep -n "capturing a screenshot\|CaptureThingImage\|IsRenderingEnabled\|UToolCallAsyncResultImage" skills/create-toolset/SKILL.md
144:Most tools are synchronous: they run on the game thread and return a value directly. Use async for long-running operations such as capturing a screenshot or waiting for an editor state change.
157:static UToolCallAsyncResultImage* CaptureThingImage(UMyThing* Thing);
163:UToolCallAsyncResultImage* UMyToolset::CaptureThingImage(UMyThing* Thing);
165:    UToolCallAsyncResultImage* Result = NewObject<UToolCallAsyncResultImage>();
167:    if (!IsRenderingEnabled())
```

`UMyToolset`, `MyToolset`, and `UMyThing` are the file's running placeholder names
(`skills/create-toolset/SKILL.md:112–264` uses `UMyToolset` throughout). So the async/screenshot
passage establishes that a screenshot tool **could** be declared as an async tool returning
`UToolCallAsyncResultImage` — it does **not** establish that one exists, and it names no
registered Editor toolset. **[I]**

The one *runtime-relevant* fact in that passage is the guard
`if (!IsRenderingEnabled())` → `SetError("Rendering is not enabled.")`
(`skills/create-toolset/SKILL.md:167–169`): any real screenshot capability depends on rendering
being enabled in the editor process. **[O]** (as sample code).

### 3.2 camera control

`camera` occurs twice, and the two hits are **different domains**: **[O]**

```
$ grep -rn -i "camera" --include="*.md" .
./README.md:106:- **Sequencer** - create and edit Level Sequences, keyframe animation, manage cameras, Control Rig integration, FBX import/export
./README.md:111:- **Editor** - screenshots, camera control, actor/asset selection, content browser, log inspection
```

Line 106 is the **Sequencer** domain's camera management; line 111 is the Editor domain's
"camera control". Upstream gives no tool name, no distinction, and no schema for either. Whether
the Editor-domain "camera control" means the viewport camera, a level camera actor, or a
camera-move API is **`[?]` unknown** — the pinned text does not say. **[I]**

### 3.3 actor/asset selection

`select` matches **one line in the whole plugin**, the domain bullet itself: **[O]**

```
$ grep -rn -i "select" --include="*.md" --include="*.json" --include="*.sh" .
./README.md:111:- **Editor** - screenshots, camera control, actor/asset selection, content browser, log inspection
```

No selection toolset, tool, or parameter appears. "actor/asset selection" is therefore a
**capability claim with zero supporting artifacts** in-repo. **[O]**

### 3.4 content browser

`content browser` matches **5 lines** in the plugin, in two distinct senses, neither of which is
a browser-control tool: **[O]**

- **As a trigger phrase** for the whole `unreal-mcp` skill —
  `skills/unreal-mcp/SKILL.md:3` lists "Content Browser; Outliner; PlayerStart" among signals
  that a request is Unreal context. That is *routing*, not a tool.
- **As a folder/asset location** in the Agent Skill docs — `skills/unreal-skill/SKILL.md:35`
  ("Create it directly in the Content Browser using `CreateSkill` via MCP"),
  `:90` ("saved as a Content Browser asset"), `:97` (`` `FolderPath`: Content Browser folder,
  e.g. `/Game/Skills/` ``). Here "Content Browser" denotes *where a `.uasset` lives*
  (`/Game/...`), not a UI surface being driven.

The README domain bullet at `README.md:111` is the only place "content browser" is listed as an
Editor *capability*. So the domain's content-browser capability is **unnamed and unspecified**;
the two concrete mentions belong to other domains (skill routing; Agent Skill asset storage).
**[I]**

### 3.5 log inspection

`log` matches **16 lines** across the plugin. Not one of them names a log-reading tool: the
matches are either human-facing diagnostics text (the Output Log, the editor's startup log) or
the unrelated word "catalog". **[O]** (listing abridged below — 7 of the 16 shown. Of the other
9: eight are `log` inside "catalog"/"cached catalog" at `operations.md:20,35,36,37`,
`setup.md:121`, `README.md:78,80,82` — the *tool catalog*, a different sense of the word — and
one is the hook script's own debug logging, `hooks/unreal-context.sh:5`, discussed below.)

```
$ grep -rn -i "log" --include="*.md" --include="*.sh" . | grep -v '^\./\.git'
skills/unreal-mcp/references/setup.md:127:- The Output Log shows MCP server startup messages.
skills/unreal-mcp/references/operations.md:40:If calls still fail, check the editor's MCP startup log, the configured endpoint, and proxy stderr. ...
skills/unreal-mcp/references/operations.md:46:| Unreal tools are missing, or `list_toolsets` errors | ... Check the editor's MCP startup log and configured endpoint. ...
skills/unreal-mcp/references/operations.md:47:| Editor logs "Failed to listen on port" | ... restart the editor ...
skills/unreal-mcp/SKILL.md:24:Missing tools do not prove that the editor is stopped. ... `unreal_mcp_status` reports the proxy's session state, not current reachability. ...
README.md:63:2. Check the Output Log for MCP server startup messages.
README.md:111:- **Editor** - screenshots, camera control, actor/asset selection, content browser, log inspection
```

Every one of these instructs a **human** to look at the Output Log (or reports what the editor
logs). None names a log-reading tool. The closest tool-shaped thing is `unreal_mcp_status`, and
upstream is explicit that it reports the *proxy's session state*, **not** editor reachability
(`skills/unreal-mcp/SKILL.md:24`, `references/operations.md:34`). **[O]**

Note also `hooks/unreal-context.sh:5` — "Opt-in debug logging: set `CLAUDE_UE_HOOK_DEBUG` to any
non-empty value." That is the *hook script's* own debug logging, unrelated to editor log
inspection. **[O]**

---

## 4. Named toolsets near this domain

The Editor domain has **no** concrete toolset class name. The only Editor-adjacent *named* tool
in the entire plugin is `AIAssistantToolset.GetDockedContext`, and it does not implement any of
the five capabilities above: **[O]**

```
$ grep -rn -E "AIAssistantToolset" .
./skills/unreal-mcp/references/operations.md:50:| `AIAssistantToolset.GetDockedContext` returns empty   | The Claude Code tab must be docked inside an asset editor (Blueprint, Material, etc.) to provide docked context. If undocked, that tool has nothing to report. |
```

That is an **asset-editor docking context** query — it surfaces what the user has docked, and
returns empty unless the Claude Code tab is docked inside an asset editor. It is neither
screenshot, camera, selection, content-browser, nor log tooling. The sibling census seat assigns
this name to the Editor row (`reports/round-101/probes/toolset-census.md:166`) as the nearest
in-repo anchor; this card records it as **adjacent, not covering**. **[I]**

Two further names that matter for *reaching* an Editor capability, both cross-cutting: **[O]**

| Name | Line | Role |
|---|---|---|
| `AllToolsets` | `README.md:17`; `references/setup.md:6,14,24,31` | editor-only aggregator plugin that **provides the tools**; server exposes none without it; `EnabledByDefault` off |
| `ProgrammaticToolset.execute_tool_script` | `README.md:90` | executes arbitrary Python inside the editor process — the only documented path that could reach editor-privileged functions regardless of which toolsets are registered |

`AllToolsets` being an **editor-only** plugin (`references/setup.md:31`) is the structural reason
this domain cannot be exercised headlessly: the tool surface does not exist without a running
editor. **[O]**

---

## 5. Runtime status — what would have to be true

**`unproven-runtime`** applies to every live-call claim about this domain. Specifically, on this
host: **[O]** (host receipts, as cited to this seat)

- **Unreal Editor is not installed.**
- `gh` is authed as `VeigaPunk`; the account is **not** Epic-linked, so
  `gh repo view EpicGames/unreal-engine` / `git ls-remote` returns **"Repository not found"**.
- The AUR `unreal-engine` 5.8.2-1 `PKGBUILD` requires SSH access to
  `git@github.com:EpicGames/UnrealEngine` (~line 280) — engine install is **BLOCKED** pending
  operator Epic-account linking.
- Live-editor MCP runtime claims are **unproven-on-this-host by construction** and are labelled,
  never asserted.

Consequently, for this domain, all of the following are **unproven**, and none may be asserted
downstream: that an Editor toolset is registered at runtime; that any of the five capabilities is
callable; that `list_toolsets` returns an Editor entry; that a screenshot call returns an image.
**[O]**

---

## 6. Unlock condition

The card flips from `static-only` to a runtime label only when **both** a live Editor tool surface
and a live MCP session exist. The gating chain, each link with its source: **[O]**

1. **Operator action (not agent-solvable):** link the Epic Games account so GitHub grants access
   to the private `EpicGames/unreal-engine` repo. Until then the engine source cannot be fetched
   (AUR `PKGBUILD` ~line 280 needs `git@github.com:EpicGames/UnrealEngine`). The Lutris route
   also needs an Epic login, which is operator-owned. — host receipt.
2. **Install the engine** (AUR `unreal-engine` 5.8.2-1, or an Epic/Lutris install) so a real
   Unreal Editor binary exists. — host receipt: *Editor NOT installed*.
3. **Enable both plugins in the project `.uproject`** — `ModelContextProtocol` (server/transport)
   and `AllToolsets` (provides the tools; editor-only aggregator, off by default). With only the
   server enabled it "starts but exposes no tools". — `references/setup.md:6,14,24,31`.
4. **Launch the editor** and start the MCP server — `ModelContextProtocol.StartServer [port]`, or
   enable `bAutoStartServer` in
   `<Project>/Saved/Config/<Platform>Editor/EditorPerProjectUserSettings.ini`.
   — `references/operations.md:11`; `references/setup.md` §2.
5. **Generate the client config** — `ModelContextProtocol.GenerateClientConfig ClaudeCode` (the
   plugin ships no static `.mcp.json`). — `README.md:72`; `references/operations.md:14`.
6. **Discover the tools** — `list_toolsets`, then `describe_toolset` on the Editor entry, then
   dispatch with `call_tool`. Under the default tool-search mode these three are the only
   advertised meta-tools; concrete tool names are deliberately absent from `tools/list`.
   — `README.md:82`; `skills/unreal-mcp/SKILL.md:16–24`.

**First experiment once unblocked** (cheapest discriminating probe, and the one that decides
whether this domain is a toolset at all): run `list_toolsets` and check whether an Editor-domain
toolset is present. Only if it is does the five-capability list get tested — and only then does
`describe_toolset` reveal whether any of screenshots / camera / selection / content browser / log
has a real tool behind it. Until that call is made, the domain's executability is **`[?]`**.
**[I]**

Also required before any screenshot claim can be made: rendering must be enabled in the editor
process (`IsRenderingEnabled()` guard, `skills/create-toolset/SKILL.md:167`), which a headless or
`-nullrhi` launch would defeat. **[I]**

---

## 7. Verification receipts (commands actually run)

All run from `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin` unless noted.

**R1 — upstream clone is at the pinned SHA** **[O]**

```
$ git -C /tmp/ue-skills-ref rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
```

**R2 — vendored mirror is byte-identical to the pinned clone** **[O]**

```
$ diff -r /tmp/ue-skills-ref corpus/knowledge/unreal-mcp/upstream -x .git && echo "DIFF_RC=$? (0=identical)"
DIFF_RC=0 (0=identical)
```

**R3 — hashes of the files cited by this card** (from the vendored mirror) **[O]**

```
$ cd corpus/knowledge/unreal-mcp/upstream && sha256sum README.md skills/unreal-mcp/SKILL.md \
    skills/create-toolset/SKILL.md skills/unreal-skill/SKILL.md \
    skills/unreal-mcp/references/operations.md skills/unreal-mcp/references/setup.md
483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e  README.md
7ef8b991a82f591c5776bb5fa167c2bc2269fd00338ed3e8534eacc551d038fa  skills/unreal-mcp/SKILL.md
e9d050087f36de51f7eeef49adb0ba9ebc603b65f74f475bc53a6debfc1f7b1c  skills/create-toolset/SKILL.md
7a0af781c458c7d192d6b23c16b5737922dc482470e2e4ef617bcda80f435087  skills/unreal-skill/SKILL.md
dbed002b4a46ab104274a31eb6682c3d277ce669216d0378df709f51567c3113  skills/unreal-mcp/references/operations.md
bd16206ea142dc9cc1950b88af526a3137072ea152c5662e8549d21bc18a3b8a  skills/unreal-mcp/references/setup.md
```

**R4 — the domain bullet is the only Editor-domain specification** **[O]**

```
$ cd corpus/knowledge/unreal-mcp/upstream && grep -n "^- \*\*Editor\*\*" README.md
111:- **Editor** - screenshots, camera control, actor/asset selection, content browser, log inspection
```

**R5 — capability keyword sweeps** (the greps quoted in §3, run over `/tmp/ue-skills-ref`,
`--include="*.md" --include="*.json" --include="*.sh"`): `screenshot` → 2 hits; `camera` → 2
hits; `select` → 1 hit; `content.browser` → 5 hits; `log` → 16 hits; `viewport` → **0 hits**;
`capture` → 5 hits (4 in the `create-toolset` async sample at lines 153, 157, 163, 173; the 5th
is `skills/unreal-mcp/SKILL.md:38`, "named bundles of instructions that **capture** workflow
knowledge" — unrelated to screenshots). **[O]**

**R6 — no Editor toolset class name exists in-repo** **[O]**

Two distinct naming families appear in the plugin. Every real name, with its hit count
(`grep -rh -o -E "[A-Z][A-Za-z]*Toolset\b"` / `...*Tools\b` over the pinned clone):

```
# *Toolset family:   AgentSkillToolset(4)  LiveCodingToolset(3)  ProgrammaticToolset(1)
#                    AutomationTestToolset(1)  AIAssistantToolset(1)
# *Tools family:     ObjectTools(3)  BlueprintTools(3)  StaticMeshTools(2)  AssetTools(2)
#                    SequencerTools(1)  NiagaraTools(1)  MaterialTools(1)  LevelTools(1)
# Template placeholders (create-toolset doc only): MyToolset(14) UMyToolset(8) FMyToolsetModule/
#                    FMyToolsetSpec
```

`RefreshTools` is excluded from that list on purpose: the two hits are
`ModelContextProtocol.RefreshTools` (`references/operations.md:13,48`) — a **console command** on
the server module, not a toolset class. **[O]**

`AllToolsets` is deliberately **absent** from the `*Toolset` list: it is the **plugin** name
(`grep -c AllToolsets` → 7 hits, all spelled `AllToolsets`, never `AllToolset`), not a toolset
class. **[O]**

**No name in either family is Editor / Screenshot / Camera / Selection / Log.** A sweep for
classes matching `[A-Z][A-Za-z]*(Editor|Screenshot|Camera|Selection|Log)[A-Za-z]*` returns only
`UnrealEditor` (the product name). The Editor domain's five capabilities therefore have **no
corresponding class in the plugin at all** — the strongest single piece of evidence for the
`static-only` verdict. **[O]**

**R7 — the 12 tracked content files** (the whole plugin; no `.uproject`, no toolset source):
`README.md`, `LICENSE`, `.gitignore`, `CODEOWNERS`, `.claude-plugin/plugin.json`,
`hooks/hooks.json`, `hooks/unreal-context.sh`, `skills/unreal-mcp/SKILL.md`,
`skills/unreal-mcp/references/operations.md`, `skills/unreal-mcp/references/setup.md`,
`skills/create-toolset/SKILL.md`, `skills/unreal-skill/SKILL.md`. **[O]**

---

## 8. Calibration rows (Claude→Kimi adaptation; every row with a resolvable pointer)

Read these as: the Claude-Code-shaped instruction upstream, and the Kimi-Code reading of it.
Each row carries a pointer into the vendored tree that resolves.

| # | Upstream (Claude Code) | Kimi reading | Pointer |
|---|---|---|---|
| 1 | Plugin install via `/plugin install …@claude-plugins-official` or `.claude/settings.json` `enabledPlugins` | Not a Kimi mechanism. Only the **content** (skills, reference text) ports; the install channel does not. Treat upstream as a *specification of the UE MCP surface*, not as an installable Kimi plugin. | `README.md:34–58` |
| 2 | `SessionStart` hook injects UE context via `bash ${CLAUDE_PLUGIN_ROOT}/hooks/unreal-context.sh` | Hook is a plain bash script, so it is portable; `${CLAUDE_PLUGIN_ROOT}` is the only Claude-specific variable and must be re-pointed at whatever root Kimi uses. | `hooks/hooks.json:10`; `hooks/unreal-context.sh:1–8`; `README.md:23–28` |
| 3 | Three meta-tools `list_toolsets` / `describe_toolset` / `call_tool` under tool-search mode | Transport-level, not client-level. Ports unchanged; the client only needs to dispatch `call_tool` with `{toolset_name, tool_name, arguments}`. | `README.md:82`; `skills/unreal-mcp/SKILL.md:16–24` |
| 4 | `/mcp` verification step in Claude Code | Client-specific UI. Kimi equivalent is "did `list_toolsets` return" — the *observable*, not the UI. | `README.md:65`; `references/setup.md:127–131` |
| 5 | `GenerateClientConfig ClaudeCode` (client enum: `ClaudeCode`, `Cursor`, `VSCode`, `Gemini`, `Codex`, `All`) | A Kimi client would need its own enum value or a hand-written `.mcp.json`; upstream ships **no** static `.mcp.json`. | `references/operations.md:14`; `README.md:72` |
| 6 | "Confirm the file path first. Do not skip the user's `.uproject` edit silently." | Behavioural rule, client-agnostic; carries over verbatim as a policy for an agent editing project files. | `references/setup.md:10` |
| 7 | Safety rules (save before/after, wait for compilation, serialize dependent calls, always check the result, mind PIE) | Client-agnostic; these are the *domain* rules for driving a live UE editor and port unchanged. | `skills/unreal-mcp/SKILL.md:28–34` |
| 8 | `--dangerously-skip-permissions` removes the per-tool approval gate | Maps to whatever "skip approvals / yolo" mode the host CLI has. The *risk* statement ports; the flag name does not. | `README.md:92` |

**Verification policy for this card (proven vs unproven):** **[O]**

- **Proven here (static):** the pinned SHA; the byte-identity of the vendored mirror; the
  existence and exact wording of every quoted line; the *absence* of any Editor toolset/tool name
  in the plugin; the 12-file inventory.
- **Unproven (runtime, labelled not asserted):** that the Editor domain exists as a registered
  toolset; that any of its five capabilities is callable; that a screenshot returns an image;
  that log inspection is a tool rather than prose; that `AIAssistantToolset` is reachable at all.
- **Unknown (`[?]`):** whether "camera control" in the Editor row means viewport camera, level
  camera actor, or a camera-move API; whether "content browser" is a browser-driving tool or an
  asset-location concept; whether the domain is one toolset or several.
- **Rule applied:** no row in this card asserts a runtime fact. Every runtime sentence is either
  marked `unproven-runtime`, or written as a *precondition* ("would require …").

---

## 9. Boundaries

- **Sole write of this seat:** this file. No other path was created or modified.
- `LOG.md`, `SCORECARD.md`, `SHONEN.md`, `SKILL.md`, `PROVINCE.md` untouched.
- The 3 pre-existing `reports/round-101/` files (`bpy-dissection.md`, `navagent-dissection.md`,
  `r101-unknowns-map.md`) untouched.
- No commits, no pushes.
- The upstream clone at `/tmp/ue-skills-ref` was read-only (verified at the pinned SHA, R1); no
  engine, no editor, no MCP server was launched.
