# Claude → Kimi adaptation: unreal-engine-skills-for-claude-code

Seat SEAT-13 (r101). Every Claude-Code-specific mechanism in the vendored plugin is mapped to its
Kimi Code CLI equivalent, or to `NONE-FOUND` with the search that failed.

- Upstream: `https://github.com/EpicGames/unreal-engine-skills-for-claude-code` pinned at
  `a6aa73ada02a9fb1f5415bec491f9942c519b297` (clone at `/tmp/ue-skills-ref`, `git rev-parse HEAD`
  returned exactly that SHA).
- Kimi side: CLI `2.2.0` (`/home/vgpnk/.kimi-code/bin/kimi`, BuildID
  `5e67bdf95c7646325b62decd0ca8d375d325ea19`).
- All source pointers below are **resolvable**: a pointer beginning `upstream/` names a file under
  the vendored copy at `corpus/knowledge/unreal-mcp/upstream/`, which is byte-identical to the
  pinned clone (verified, see Provenance).

Host receipts (from the round; re-derived only where noted): Arch Linux, 32 cores, 30G RAM, 780G
free on `/`; `jq`, `python3`, `node` present; shellcheck 0.11.0; **Unreal Editor NOT installed**;
AUR engine install blocked pending operator Epic-account linking. Consequently every row that
depends on a live editor is labeled `unproven-runtime` by construction and is never asserted. The
table's 15 rows are all host-side mechanisms (env vars, hooks, plugin install, MCP config, skill
paths), so none of them is editor-dependent and the `unproven-runtime` label does not appear in the
table itself; the editor-dependent claims are segregated into the register in §6.

---

## 1. Adaptation table

Status key: **verified-here** = reproduced by a command run on this host, output pasted in the row
notes; **static-only** = read from a shipped artifact (binary strings, official docs page, config
file) with a resolvable pointer, not executed; **unproven-runtime** = requires a running Unreal
Editor, which this host does not have.

| # | Claude Code mechanism | Kimi Code CLI equivalent | Status | Source pointer |
|---|---|---|---|---|
| 1 | `CLAUDE_PLUGIN_ROOT` env var | `KIMI_PLUGIN_ROOT` (plugin root abs path) + `KIMI_CODE_HOME` | static-only | `upstream/hooks/hooks.json:10` → `kimi` binary: `KIMI_PLUGIN_ROOT: pluginRoot`; docs `customization/plugins.html` §Hooks in Plugins |
| 2 | `hooks.json` + `SessionStart` hook | `[[hooks]]` in `config.toml`, `event = "SessionStart"` | verified-here | `upstream/hooks/hooks.json:4-5` → `~/.kimi-code/config.toml:2932-2937` (live `[[hooks]]` precedent); live probe §3.1 |
| 3 | Hook matcher `startup\|resume\|clear` | matcher is a **regex over `source`**, values `startup` / `resume` only — no `clear` | verified-here | `upstream/hooks/hooks.json:6` → live probe §3.1 (`source: "startup"`); docs `customization/hooks.html` event reference |
| 4 | Hook stdout `{"hookSpecificOutput":{"hookEventName":…,"additionalContext":…}}` | **NONE-FOUND** — Kimi parses only `{message, hookSpecificOutput{message, permissionDecision, permissionDecisionReason}}`; stdout text is not injected | verified-here | `upstream/hooks/unreal-context.sh:84` → live probe §3.2 + §3.3 |
| 5 | Hook exit code semantics | same 0 = allow, 2 = block; other non-zero = fail-open allow | static-only | `upstream/hooks/unreal-context.sh:47` → docs `customization/hooks.html` §Return Values |
| 6 | `/plugin install …@claude-plugins-official` + `/plugin marketplace add anthropics/claude-plugins-official` | `/plugins install <github-url>`, `/plugins marketplace [source]`; marketplace override via `KIMI_CODE_PLUGIN_MARKETPLACE_URL` | static-only | `upstream/README.md:39,45` → docs `customization/plugins.html` §Installation and Management; `kimi` binary `marketplace.ts` region |
| 7 | Plugin discovery surface (`/plugin` Installed tab) | `/plugins` panel + `/plugins list\|info\|enable\|disable\|remove\|reload` | static-only | `upstream/README.md:64` → docs `customization/plugins.html`; `~/.kimi-code/plugins/installed.json:1-13` |
| 8 | `.claude-plugin/plugin.json` manifest | `kimi.plugin.json` (or `.kimi-plugin/plugin.json`); field names differ | verified-here | `upstream/.claude-plugin/plugin.json:1` → live probe §3.4; docs `customization/plugins.html` §Plugin Manifest |
| 9 | `.claude/settings.json` → `enabledPlugins` (team install, project scope) | **NONE-FOUND** — Kimi plugins are per-user only; no project-scope install | verified-here | `upstream/README.md:50-57` → search §4.1 (0 hits in both config and binary) + docs note "Plugins are currently installed per-user and apply to all projects; project-level installation scope is not yet supported" |
| 10 | `/mcp` client command | `/mcp` (same name, connection status) + `/mcp-config` (edit/login) | static-only | `upstream/README.md:65`, `upstream/skills/unreal-mcp/references/setup.md:129` → docs `customization/mcp.html`; `kimi` binary `builtin/mcp-config` skill |
| 11 | Editor-generated `.mcp.json` (`GenerateClientConfig ClaudeCode`) | **Kimi reads project-root `.mcp.json` natively** — no adaptation needed; Kimi also reads `$KIMI_CODE_HOME/mcp.json` and `<cwd>/.kimi-code/mcp.json` | verified-here | `upstream/skills/unreal-mcp/references/setup.md:61,70-79`; `upstream/README.md:72` → live probe §3.5; `~/.kimi-code/mcp.json:1-11` |
| 12 | `GenerateClientConfig` target list `ClaudeCode\|Cursor\|VSCode\|Gemini\|Codex\|All` | **NONE-FOUND** — no Kimi target exists in the upstream plugin; use the `ClaudeCode` output as-is via row 11 | static-only | `upstream/skills/unreal-mcp/references/operations.md:14`, `upstream/skills/unreal-mcp/references/setup.md:61` → search §4.2 |
| 13 | `--dangerously-skip-permissions` (approval gate off) | permission modes `manual` / `yolo` / `auto`; `-y/--yolo`, `--auto` | static-only | `upstream/README.md:92` → `~/.kimi-code/config.toml:1` (`default_permission_mode = "auto"`); docs `configuration/config-files.html` §Top-level fields |
| 14 | `CLAUDE_UE_HOOK_DEBUG` (opt-in hook debug) | **NONE-FOUND** — no equivalent; set your own var and read it in the hook script (portable, since the hook runs `bash` either way) | static-only | `upstream/hooks/unreal-context.sh:5,8` → search §4.3 |
| 15 | Claude Code skills under `.claude/skills/` (referenced by the plugin's own prose) | Agent Skills: `~/.kimi-code/skills/`, `<project>/.kimi-code/skills/`, `~/.agents/skills/` | static-only | `upstream/skills/unreal-skill/SKILL.md:3` (explicitly scopes itself away from harness skills) → `~/.kimi-code/skills/` listing |

---

## 2. Row notes

### Rows 1, 8 — plugin root and manifest

Kimi's manifest search is `kimi.plugin.json` first, then `.kimi-plugin/plugin.json` (binary
constant `KIMI_PLUGIN_ROOT_PATH = "kimi.plugin.json"`). The upstream `.claude-plugin/plugin.json`
keys (`name`, `version`, `description`, `author`, `license`) are all valid Kimi manifest keys, so
the *content* ports; only the **directory/filename** must change. Kimi's manifest adds fields the
Claude one has no counterpart for: `sessionStart.skill`, `skillInstructions`, `systemPrompt`,
`systemPromptPath`, `mcpServers`, `hooks`, `commands`.

`KIMI_PLUGIN_ROOT` is exported to plugin-declared MCP servers and plugin hook processes, mirroring
`CLAUDE_PLUGIN_ROOT`'s role. There is no `CLAUDE_PLUGIN_ROOT` in the binary at all (search §4.4),
so the upstream hook command line cannot be copied verbatim.

### Row 2/3 — the SessionStart hook runs, but its payload shape is wrong twice over

The upstream hook targets Claude Code's `SessionStart` with matcher `startup|resume|clear`. Kimi
also has a `SessionStart` event, but its `source` is only `startup` or `resume` — the binary has no
`clear` session-start source (`clear` appears only as a transcript `messages[]` entry source and as
the `/clear` slash command alias). A `startup|resume|clear` matcher is therefore *harmless but
partially dead* on Kimi: it still matches `startup` and `resume`, it just never matches a `clear`
that does not exist.

### Row 4 — the load-bearing adaptation gap

This is the one row that changes the recommendation. Kimi's hook-output parser is:

```js
HookSpecificOutputSchema = preprocess(v => isRecord(v) ? v : void 0, looseObject({
    message: OptionalStringSchema,
    permissionDecision: unknown().optional(),
    permissionDecisionReason: unknown().optional()
}).optional());
HookJsonOutputSchema = looseObject({
    message: OptionalStringSchema,
    hookSpecificOutput: HookSpecificOutputSchema
});
```

There is **no `additionalContext` field**, and the hook's own `hookEventName` key is not part of the
*output* schema either (the binary contains exactly one `hookEventName` occurrence, at the point
where the CLI builds the *input* payload). Because `looseObject` tolerates unknown keys, the
upstream JSON does not error — it simply parses to an object with no `message`, so nothing is
injected. The hook is silent, not broken.

Also relevant: `SessionStart` is an **observation-only** event in Kimi, so even a correct `message`
would not steer the turn (only `PreToolUse`, `Stop`, `UserPromptSubmit` are blockable).

### Row 9 — the team-install mechanism does not exist

`enabledPlugins` occurs 0 times in both `~/.kimi-code/config.toml` and the binary. Kimi's own
`/import-from-cc-codex` migration skill states its exclusions explicitly, and they line up with
what is missing:

> Do **not** migrate credentials, OAuth tokens, sessions, history, logs, hooks, plugins, plugin
> caches, output styles, or custom agents/subagents.

That single sentence independently corroborates the `NONE-FOUND` verdicts for the Claude **hooks**
mechanism (rows 2-5), the **plugins** mechanism (rows 6-9), and confirms Kimi treats these as
separate, non-ported surfaces. The only project-scoped config Kimi has is
`<project-root>/.kimi-code/local.toml`, whose sole documented table is `[workspace].additional_dir`
— it cannot express a plugin enablement.

### Row 11 — the good news, and why it matters more than the rest

The editor's `ModelContextProtocol.GenerateClientConfig ClaudeCode` writes a `.mcp.json` whose
`mcpServers` entry is `{"type": "http", "url": "http://127.0.0.1:8000/mcp"}`. Kimi resolves three
MCP config layers:

```js
async function resolveMcpJsonPaths(input) {
    const start = normalize$2(input.cwd);
    const projectRoot = (await findGitWorkTree(input.fs, start))?.root ?? start;
    return {
        user:        join$93(resolveKimiHome(input.homeDir), "mcp.json"),
        projectRoot: join$93(projectRoot, ".mcp.json"),
        project:     join$93(input.cwd, ".kimi-code", "mcp.json")
    };
}
```

`projectRoot` is `<git-root>/.mcp.json` — the **exact filename and location** the Unreal plugin
generates. So the MCP half of the integration needs no porting: point Kimi at a UE project and the
editor-written `.mcp.json` is picked up as-is.

Two caveats, both labeled: (a) Kimi's schema discriminates on `transport` and *infers* it —
`"command"` ⇒ stdio, `"url"` ⇒ http — so the Claude `"type": "http"` key is **not read**; whether
the strict variant rejects the extra key is `unproven-runtime` (not exercised with a live server).
(b) The hook script's `.mcp.json` presence check at `unreal-context.sh:61` already looks for the
right file, so that part of the hook logic stays correct on Kimi.

---

## 3. Live probes (reproduced on this host)

All probes used a throwaway `KIMI_CODE_HOME` and a synthetic project, so the operator's real config
was never touched.

### 3.1 SessionStart fires; `source` is `startup`

```bash
# temp home with default_model = "probe/probe-model" and a SessionStart hook that dumps stdin
cd /tmp/r101work/fakeproj && KIMI_CODE_HOME=$H timeout 25 kimi -p "hi"
cat /tmp/r101work/ss_stdin.json
```
```json
{"hook_event_name":"SessionStart","session_id":"session_5b93a628-0333-4cc6-b07f-849c25f15b88","cwd":"/tmp/r101work/fakeproj","client_type":"kimi_code_cli","source":"startup","model":"probe/probe-model","profile":"agent"}
```

Kimi passes the payload on **stdin** (not env) as JSON. `hook_event_name` (snake_case) is the input
field; the plugin's `hookEventName` (camelCase) belongs to the Claude *output* shape.

### 3.2 The upstream hook emits a shape Kimi does not read

```bash
cd /tmp/r101work/fakeproj/Source && bash /tmp/ue-skills-ref/hooks/unreal-context.sh; echo "exit=$?"
```
```json
{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"This working directory is an Unreal Engine project. The project is `MyGame.uproject`. Prefer Unreal Engine conventions (C++/UObject patterns, Slate, UHT reflection) when suggesting code. Use the `unreal-mcp` skill for tasks that involve driving the Unreal Editor via MCP. No `.mcp.json` is present at the project root yet. Run `ModelContextProtocol.GenerateClientConfig ClaudeCode` in the editor console to generate one."}}
exit=0
```

The script itself is sound: `bash -n` exit 0, `shellcheck 0.11.0` exit 0, correct root detection
from a subdirectory, correct `.mcp.json` branch when the file exists, silent no-op outside a
project, and `CLAUDE_UE_HOOK_DEBUG=1` prints `unreal-context.sh: no Unreal Engine project marker
found walking up from /tmp` to stderr. It just speaks a dialect Kimi does not.

### 3.3 End-to-end: hook ran, model answered, context absent

The real upstream hook was wired in as a Kimi `SessionStart` hook, with a side-effect file proving
execution:

```bash
KIMI_CODE_HOME=$H3 timeout 90 kimi -p "reply with the single word OK"
cat /tmp/r101work/hookran.txt
grep -c "Unreal" $H3/sessions/*/*/agents/main/wire.jsonl
```
```
• OK
To resume this session: kimi -r session_d7e99ff9-8e83-4bd2-bd05-69bd8d666f1a
RAN-1792343868          # ← the hook executed
0                       # ← the injected Unreal context never reached the model
```

`grep -rl "Unreal Engine project" $H3/sessions` returned nothing, on a 90685-byte transcript. The
same probe against a *successfully-answering* model is what makes this a real result rather than an
error artifact: an earlier probe on a closed provider port produced no assistant text at all.

### 3.4 Manifest constants

```bash
strings -n 6 /home/vgpnk/.kimi-code/bin/kimi | grep -n 'KIMI_PLUGIN_ROOT_PATH\|KIMI_PLUGIN_DIR_PATH'
# 1832505: KIMI_PLUGIN_ROOT_PATH = "kimi.plugin.json";
# 1832506: KIMI_PLUGIN_DIR_PATH  = ".kimi-plugin/plugin.json";
```

### 3.5 Kimi resolves project-root `.mcp.json`

`resolveMcpJsonPaths` extracted from the binary, strings line 1743845 (§Row 11 quote). Corroborated
by the shipped `mcp-config` builtin skill text in the same binary: "Project-root:
`<project root>/.mcp.json` … Use for Claude-compatible, repo-shared, or cross-agent servers."

---

## 4. NONE-FOUND searches (exact commands and results)

Binary strings were extracted once with `strings -n 3 /home/vgpnk/.kimi-code/bin/kimi > /tmp/kimi_strings.txt`.

### 4.1 `enabledPlugins` (row 9)

```bash
grep -c enabledPlugins ~/.kimi-code/config.toml   # 0
grep -c enabledPlugins /tmp/kimi_strings.txt      # 0
grep -c "settings.json" /tmp/kimi_strings.txt     # 0
grep -o "\.claude/settings[a-z.]*" /tmp/kimi_strings.txt | sort -u   # (empty)
```
No `.claude/settings.json` surface exists at all; the only `.claude*` paths the binary knows are
`~/.claude/AGENTS.md`, `~/.claude/CLAUDE.md`, `~/.claude/skills/`, `~/.claude/commands/` and
`~/.claude.json` — all of them *import sources* for `/import-from-cc-codex`, not live config.

### 4.2 A Kimi client target in `GenerateClientConfig` (row 12)

```bash
grep -o "GenerateClientConfig [A-Za-z]*" /tmp/ue-skills-ref/skills/unreal-mcp/references/*.md | sort -u
# GenerateClientConfig ClaudeCode
grep -rn "Kimi\|kimi" /tmp/ue-skills-ref --include=*.md --include=*.json   # (no matches)
```
The upstream plugin has no Kimi awareness whatsoever. The client list is fixed inside the Unreal
engine (`ClaudeCode`, `Cursor`, `VSCode`, `Gemini`, `Codex`, `All`), so extending it is an engine
change, not a plugin change.

### 4.3 `CLAUDE_UE_HOOK_DEBUG` equivalent (row 14)

```bash
grep -o "CLAUDE_[A-Z_]*" /tmp/kimi_strings.txt | sort -u
# CLAUDE_FAMILY_WORD_RE
# CLAUDE_THINKING_VISION_TOOL_PREFIXES
# CLAUDE_VISION_TOOL_PREFIXES
```
The only `CLAUDE_*` names in the binary are model-vision heuristics for the Anthropic provider —
nothing hook-related. The variable is purely a convention *inside* the upstream bash script, so it
keeps working if the script keeps working; it simply is not a Kimi-recognized name.

### 4.4 `CLAUDE_PLUGIN_ROOT` (row 1)

```bash
grep -c "CLAUDE_PLUGIN_ROOT" /tmp/kimi_strings.txt   # 0
```

### 4.5 `additionalContext` (row 4)

```bash
grep -c "additionalContext" /tmp/kimi_strings.txt    # 0
```

---

## 5. Verification policy — proven vs unproven

Round axes are depth / coverage / calibration; this section is the calibration contract for the
whole file.

**Three admissible evidence classes.**

1. **PROVEN-HERE** — reproduced by a command executed on this host, with the command *and* its
   observed output recorded in this document. Promotions to this class are the only ones that may
   be stated as fact. Examples in this file: rows 2, 3, 4, 8, 9, 11.
2. **STATIC-ONLY** — read from a shipped artifact with a resolvable pointer (a binary strings line,
   an official docs page, a config file path + line). True of the artifact as read, but never
   executed here. Examples: rows 1, 5, 6, 7, 10, 12, 13, 14, 15.
3. **UNPROVEN-RUNTIME** — depends on a running Unreal Editor. This host has no editor and the
   engine install is blocked pending operator Epic-account linking, so no such claim may be
   asserted, only labeled. See §6.

**Promotion rule.** A `static-only` row becomes `verified-here` only when someone runs the
equivalent command and pastes the output. Reading the binary twice is not verification.

**Invalidation rule.** Any pointer of the form "`kimi` binary strings line N" is valid **only** for
BuildID `5e67bdf95c7646325b62decd0ca8d375d325ea19` (v2.2.0). A CLI upgrade invalidates every such
pointer; re-run §4's greps rather than trusting the line numbers. Likewise, every `upstream/...`
pointer is anchored to SHA `a6aa73a` and is void if the pin moves.

**Negative-claim rule.** `NONE-FOUND` means "the searches in §4 returned 0", not "the feature cannot
exist". Each `NONE-FOUND` row names the exact command that failed, so a future reader can re-run it
and falsify the row cheaply.

**Live-editor rule.** No claim about tool availability, `list_toolsets` behavior, proxy recovery, or
any Unreal-side effect may be written in the indicative mood on this host. The upstream docs
themselves supply the correct posture: "A connected proxy or visible cached tools do not prove that
Unreal is reachable. Confirm with a successful read-only Unreal tool call."

---

## 6. Unproven-runtime register

Labeled, never asserted. Each item states what would settle it.

| Item | Why unproven | What would settle it |
|---|---|---|
| Kimi connects to `unreal-mcp` over HTTP and lists it | no editor, no MCP server to connect to | editor running + `/mcp` shows `unreal-mcp` connected |
| `list_toolsets` / `describe_toolset` / `call_tool` round-trip | server exposes no tools without `AllToolsets` and a live editor | one successful read-only `call_tool` |
| The `"type": "http"` key in the editor-written `.mcp.json` is tolerated by Kimi's strict schema | Kimi's loader infers `transport` from `url` and never reads `type`; not exercised against a live entry | start a Kimi session with the real `.mcp.json` present and observe whether the server registers |
| `unreal-mcp-proxy` stdio entry works under Kimi | proxy binary ships with the engine build | proxy installed + `/mcp` shows `unreal-mcp-proxy` |
| `AIAssistantToolset.GetDockedContext` | upstream requires the **Claude Code** tab docked in an asset editor | reimplemented against a Kimi docked surface, or accepted as lost |

---

## 7. Recommended adaptation, ranked by cost

1. **Do nothing for MCP.** The editor-generated `.mcp.json` is already Kimi-native (§Row 11). This
   covers the majority of the plugin's value — the tool surface.
2. **Replace the hook's output contract, not the hook.** Keep `unreal-context.sh`'s detection logic
   (it is correct and shellcheck-clean); change the final `printf` to emit Kimi's shape. Since
   `SessionStart` is observation-only and Kimi injects no context from hook stdout, the portable
   route is either (a) a plugin manifest `sessionStart.skill`, which Kimi *does* render into the
   session (`<plugin_session_start …>` block), or (b) a `UserPromptSubmit` hook whose stdout is
   appended to context.
3. **Port the three `SKILL.md` files as-is.** Their frontmatter is `name` + `description`, which is
   exactly what Kimi requires for directory skills; no rewrite needed.
4. **Do not attempt** the marketplace/team-install path (row 9) or a Kimi `GenerateClientConfig`
   target (row 12); neither has a Kimi-side counterpart today.

---

## Provenance

Pinned SHA re-checked before use:

```
$ git -C /tmp/ue-skills-ref rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
```

All 12 upstream files compared against the vendored copy (SHA-256, first 16 hex):

```
MATCH    .claude-plugin/plugin.json  5aa984848f0fd48c
MATCH    CODEOWNERS  653d372559bee26d
MATCH    .gitignore  0fad2f57a9fac18a
MATCH    hooks/hooks.json  259124f0631b7d4b
MATCH    hooks/unreal-context.sh  d3f1c871cd4edd52
MATCH    LICENSE  5b337be051359edc
MATCH    README.md  483693ad0e14d027
MATCH    skills/create-toolset/SKILL.md  e9d050087f36de51
MATCH    skills/unreal-mcp/references/operations.md  dbed002b4a46ab10
MATCH    skills/unreal-mcp/references/setup.md  bd16206ea142dc9c
MATCH    skills/unreal-mcp/SKILL.md  7ef8b991a82f591c
MATCH    skills/unreal-skill/SKILL.md  7a0af781c458c7d1
```

Every one matched; the vendored tree is byte-identical to the pin.
