# SEAT-30 PROBE — Kimi Code CLI surfaces for the Claude→Kimi adaptation table

Round r101 · lane game-dev-3d-shokunin · axes: calibration / coverage
Upstream: `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin`
Pinned SHA: `a6aa73ada02a9fb1f5415bec491f9942c519b297` · date 2026-10-18

Read-only inspection of the local Kimi Code CLI installation. No file under
`~/.kimi-code/` was modified. No credential, OAuth, key, or token file was read;
`~/.kimi-code/credentials/`, `oauth/`, `server.token`, and `device_id` were
never opened. Every runtime probe ran against a **scratch** `KIMI_CODE_HOME`
under `/tmp/`, so the operator's live config, sessions, and trust records were
untouched.

Evidence labels: **[O]** receipt-pinned observation · **[I]** inference from
binary constants, not executed · **[?]** unknown. Per-seat standard: any row
whose verdict is not `verified-here` says so explicitly.

---

## 0. Instrument identity

| Field | Value | Command |
|---|---|---|
| CLI version | `2.2.0` | `~/.kimi-code/bin/kimi --version` |
| Binary path | `/home/vgpnk/.kimi-code/bin/kimi` | `readlink -f` |
| Binary size | `191892672` bytes | `stat -c '%s'` |
| Binary mtime | `2026-10-14 19:58:50 -0300` | `stat -c '%y'` |
| Binary sha256 | `8ee7405d82958f0a50a3aab0773aba9e01057978bad93ba379eaf89e5b6111af` | `sha256sum` |
| Data root | `~/.kimi-code` (`$KIMI_CODE_HOME` unset) | `echo "$KIMI_CODE_HOME"` → empty |
| `config.toml` | 2964 lines, 95470 B, md5 `6e9accb1168ce4eeceaa2bb5501ef256` | `md5sum` |
| `tui.toml` | 31 lines, 1300 B, md5 `4ab68c5fc8c36720d8e91c8c97da8138` | `md5sum` |
| `mcp.json` | 249 B, md5 `e6c3aee69b5976dedf6ff0ab94c868c8` | `md5sum` |
| `plugins/installed.json` | 390 B, md5 `42ca1de7946b7e60c08d508b18c637c4` | `md5sum` |
| `kimi.plugin.json` (webbridge) | 1273 B, md5 `c3540417d89682775a234ca3f8d6eff3` | `md5sum` |
| `bash` | `GNU bash, version 5.3.15(1)-release` | `bash --version` |

Data root resolution is `homeDir ?? $KIMI_CODE_HOME ?? ~/.kimi-code` **[O]** —
`resolveKimiHome` in the binary is literally
`return homeDir ?? env["KIMI_CODE_HOME"] ?? join$93(osHomeDir, ".kimi-code");`,
and the built-in `mcp-config` / `custom-theme` skills both instruct resolving
`$KIMI_CODE_HOME` first.

---

## 1. `ls ~/.kimi-code/` and `ls ~/.kimi-code/plugins/` — verbatim

```
$ ls -1 ~/.kimi-code/
agents
bin
cache
config.toml
config.toml.20261018-085645.bak
config.toml.20261018-114557.bak
credentials
device_id
file-history
logs
mcp.json
oauth
plugins
rc-qrcode.png
region
search-index
server
server.token
session_index.jsonl
sessions
skills
telemetry
tui.toml
tui.toml.bak
updates
user-history
workspaces.json
workspace-trust
```

```
$ ls -R ~/.kimi-code/plugins/
/home/vgpnk/.kimi-code/plugins/:
installed.json
managed

/home/vgpnk/.kimi-code/plugins/managed:
kimi-webbridge

/home/vgpnk/.kimi-code/plugins/managed/kimi-webbridge:
03-browser-extension.txt
04-headroom.txt
kimi.plugin.json
skills

/home/vgpnk/.kimi-code/plugins/managed/kimi-webbridge/skills:
kimi-webbridge

/home/vgpnk/.kimi-code/plugins/managed/kimi-webbridge/skills/kimi-webbridge:
references
SKILL.md

/home/vgpnk/.kimi-code/plugins/managed/kimi-webbridge/skills/kimi-webbridge/references:
operations.md
```

Exactly **one** plugin is installed, and it ships a `skills/` payload plus a
`references/` subdirectory inside the skill bundle — the same shape as the
upstream `unreal-mcp` bundle. That is a live, local precedent for the port.

`agents/` holds two profile sets (`secondary/` 18 files, `ufo/` 13 files);
`skills/` holds five symlinks into `/home/vgpnk/Projects/myskills/` and
`~/.agents/skills/`; `bin/` holds `kimi` and `fd`; `server/rc.json` holds a
local remote-control origin.

---

## 2. `config.toml` — the agent/runtime surface

Header lines (verbatim):

```toml
default_permission_mode = "auto"
default_model = "kimi-code/kimi-for-coding"
```

The file is 335 table headers, ~99% of them `[providers.*]` and
`[models.*]`. The surfaces that matter for adaptation, with exact line
numbers in `~/.kimi-code/config.toml`:

| Line | Key | Value here | Role in adaptation |
|---|---|---|---|
| 1 | `default_permission_mode` | `"auto"` | enum is `"yolo" \| "manual" \| "auto"` **[O]** |
| 2 | `default_model` | `"kimi-code/kimi-for-coding"` | default model alias |
| 2873 | `[thinking]` | `enabled`/`effort` | reasoning budget |
| 2877 | `[experimental]` | `tower`, `notify_user`, `subagent_fork` | feature flags |
| 2883 | `[loop_control]` | `max_steps_per_turn` etc. | turn loop |
| 2888 | `[subagent]` | `timeout_ms = 7200000` | subagent budget |
| 2891 | `[swarm]` | `timeout_ms = 7200000` | swarm budget |
| 2900 | `[secondary_model]` | pool + `default_model` | subagent model pool |
| **2932** | **`[[hooks]]`** | 1 live hook | **the hook surface** |
| 2938 | `[mcp_servers.rea]` | `npx -y rea-agents@6.7.0 mcp` | **ignored — see §3** |
| 2947 | `[services.moonshot_search]` | base_url + oauth | built-in web search |
| 2956 | `[services.moonshot_fetch]` | base_url + oauth | built-in web fetch |

The live hook, verbatim (`config.toml:2932-2936`):

```toml
[[hooks]]
event = "Notification"
matcher = "task\\.completed"
command = "notify-send -a 'Kimi Code' 'Background task completed' 'A Kimi Code background task finished'"
timeout = 5
```

This is a working in-the-wild example of the exact shape the port needs:
`event` + `matcher` + `command` + `timeout`, where `matcher` is a **regex**
tested against the event's matcher value (`new RegExp(pattern).test(value)` in
`matches$1`), and an empty matcher matches everything. Note the escape:
`task\\.completed` in TOML becomes the regex `task\.completed`.

`kimi doctor` accepts it and warns about exactly one thing:

```
$ ~/.kimi-code/bin/kimi doctor
Kimi doctor

OK config.toml  /home/vgpnk/.kimi-code/config.toml
  Unknown top-level key ignored by the v2 engine: mcp_servers.
OK tui.toml     /home/vgpnk/.kimi-code/tui.toml

All checked config files are valid.
```

## 3. MCP wiring — three JSON files, one dead TOML key

### 3.1 Where MCP servers are actually read from

`resolveMcpJsonPaths` in the binary returns exactly three paths **[O]**:

```
user:        <KIMI_CODE_HOME>/mcp.json            → /home/vgpnk/.kimi-code/mcp.json
projectRoot: <git work-tree root>/.mcp.json       → Claude-compatible
project:     <cwd>/.kimi-code/mcp.json            → Kimi-specific override
```

Loaded in that order, later layers overriding earlier on name collision **[O]**.
This is corroborated verbatim by the built-in `mcp-config` skill text embedded
in the binary ("Config lives in three files; on key collision, later entries in
this precedence order override earlier ones").

Live `~/.kimi-code/mcp.json` (249 B, verbatim):

```json
{
  "mcpServers": {
    "cli-agents": {
      "transport": "stdio",
      "command": "/usr/bin/python3",
      "args": ["/home/vgpnk/.local/share/cli-agents-mcp/server.py"],
      "startupTimeoutMs": 20000,
      "toolTimeoutMs": 660000
    }
  }
}
```

The accepted server shape **[O]** (`McpServerStdioConfigSchema$1` /
`McpServerHttpConfigSchema$1` / `McpServerSseConfigSchema$1`, discriminated on
`transport`, plus `McpServerCommonFields$1`):

- `transport`: `"stdio"` (default when absent), `"http"`, `"sse"`
- stdio: `command` (required, min length 1), `args`, `env`, `cwd`
- http/sse: `url` (must parse as a URL), plus `headers`, `auth: "oauth"`, `bearerTokenEnvVar`
- common: `enabled`, `startupTimeoutMs`, `toolTimeoutMs`, `enabledTools`, `disabledTools`

A bare `{ "command": ... }` with no `transport` is normalized to
`transport: "stdio"` — so a Claude-generated `.mcp.json` entry is accepted as-is.

### 3.2 `[mcp_servers.*]` in `config.toml` is DEAD

Two independent receipts:

1. `kimi doctor` prints `Unknown top-level key ignored by the v2 engine: mcp_servers.`
2. A live run with a `[mcp_servers.probetoml]` block pointing at a marker
   script produced **no** spawn — `/tmp/mcp-marker.txt` did not exist after the
   run, while the same marker script spawned correctly via `.mcp.json` (below).

**[O] verified-here (negative).** Any port that copies the `[mcp_servers.*]`
block from the operator's existing config would silently get nothing.

### 3.3 Project `.mcp.json` — verified live, but **trust-gated**

Untrusted project (`/tmp/mcp-probe`, `.mcp.json` declaring `probemarker`):

```
$ kimi -p "reply with exactly: OK"
kimi version 2.2.0
Warning: this folder is not trusted; skipped 1 project-level MCP server: probemarker (stdio: /tmp/mcp-probe/mcpmarker.sh).
  Run `kimi` here and choose "Trust this folder", or set KIMI_CODE_TRUST_WORKSPACE=1, to enable them.
```

Same directory with trust enabled:

```
$ KIMI_CODE_TRUST_WORKSPACE=1 kimi -p "reply with exactly: OK"
• OK
$ cat /tmp/mcp-marker.txt
MCP_SPAWNED pid=79600 cwd=/tmp/mcp-probe
```

Project-local file (`/tmp/mcp-probe2/.kimi-code/mcp.json`), trust enabled:

```
$ cat /tmp/mcp-marker.txt
MCP_SPAWNED pid=219700 cwd=/tmp/mcp-probe2
```

**[O] verified-here.** The stdio server is genuinely spawned at session start,
from both the Claude-compatible `.mcp.json` and the Kimi-specific
`.kimi-code/mcp.json`. Trust records live in `~/.kimi-code/workspace-trust/`
(one file per workspace id, mode `0600`).

> **Calibration note for the port.** Upstream's README tells the user to run
> `ModelContextProtocol.GenerateClientConfig ClaudeCode` and expects the
> resulting `.mcp.json` to work. On Kimi it works **only after the folder is
> trusted**. In an untrusted repo the plugin silently loses its entire tool
> surface — the only signal is a one-line warning at startup.

### 3.4 Plugin-declared MCP servers — static-only

`readMcpServers` parses `mcpServers` out of the plugin manifest, and
`enabledMcpServers()` renames each to `plugin-<pluginId>:<serverName>`, then
`withPluginMcpRuntime` injects `KIMI_CODE_HOME` and `KIMI_PLUGIN_ROOT` into the
child env and rewrites a bare `node` command to `process.execPath` **[O]**.
Relative `./` commands and `cwd` are resolved against the plugin root; a
command containing `/` but not starting with `./` is rejected with a warning.

I could not reach the MCP-connect stage in a scratch home (no credentials, so
the run aborts before/around server connect), and I will not copy OAuth tokens
to force it. **Verdict: static-only.** The mechanism is fully legible in the
binary; the runtime claim is unproven.

---

## 4. Hooks — the native surface, verified live

### 4.1 Schema

```toml
[[hooks]]
event   = "<one of 20>"
matcher = "<regex>"      # optional; empty matches everything
command = "<shell command>"   # required, min length 1
timeout = <int seconds>  # optional, min 1, max 600; default 30
```

`HookDefSchema` is `.strict()` — an unknown key is a validation error, not a
warning **[O]**.

The event enum, printed verbatim by `kimi doctor` on a deliberately bad event:

```
$ KIMI_CODE_HOME=/tmp/kimi-home-probe kimi doctor
ERROR config.toml  /tmp/kimi-home-probe/config.toml
  Invalid configuration in /tmp/kimi-home-probe/config.toml.
  Validation issues:
    hooks[0].event: Invalid option: expected one of "PreToolUse"|"PostToolUse"|"PostToolUseFailure"|"PermissionRequest"|"PermissionResult"|"UserPromptSubmit"|"UserPromptQueued"|"TurnStarted"|"Stop"|"StopFailure"|"Interrupt"|"SessionStart"|"SessionEnd"|"SessionHeartbeat"|"SubagentStart"|"SubagentStop"|"TaskStarted"|"PreCompact"|"PostCompact"|"Notification"
```

**20 events** (counted from the line above with `grep -oE '"[A-Za-z]+"' | wc -l`
→ `20`). Kimi has more events than the Claude Code set upstream targets
(that comparison is background knowledge, not a receipt here). Kimi additionally has
`PostToolUseFailure`, `PermissionRequest`, `PermissionResult`,
`UserPromptQueued`, `TurnStarted`, `StopFailure`, `Interrupt`,
`SessionHeartbeat`, `SubagentStart`, `TaskStarted`, `PostCompact`.

**[O]** the 20-name list above is Kimi's, printed by `kimi doctor`. The
comparison "Claude Code has 9" is **background knowledge, not a receipt from
this probe** — no Claude Code installation was inspected. What *is* receipted:
every event name upstream's `hooks.json` uses (`SessionStart`) is in Kimi's
list, and Kimi's list is strictly longer.

### 4.2 Hooks fire — verified live

Scratch home with one `SessionStart` hook:

```toml
[[hooks]]
event = "SessionStart"
matcher = "startup|resume|clear"
command = "bash -c 'echo HOOK_FIRED_SessionStart >> /tmp/hook-marker.txt'"
timeout = 5
```

```
$ cd /tmp/fake-ue && KIMI_CODE_HOME=/tmp/kimi-home-probe5 kimi -p "reply OK"
kimi version 2.2.0
error: failed to run prompt: provider managed:kimi-code has no credential configured
$ cat /tmp/hook-marker.txt
HOOK_FIRED_SessionStart
```

**[O] verified-here.** The hook ran before the credential failure, proving the
`SessionStart` → `matcher="startup"` → `command` path end to end on this host.
The same command shape as upstream's `bash ${CLAUDE_PLUGIN_ROOT}/hooks/...`
executes unchanged.

### 4.3 Hook stdin contract (captured, not inferred)

With a hook whose command was `cat > /tmp/hook-stdin.txt`, run in a directory
containing a real `.uproject`:

```
{"hook_event_name":"SessionStart","session_id":"session_4bf9b269-c651-4e8b-965b-ab114de462de","cwd":"/tmp/ue-fake2","client_type":"kimi_code_cli","source":"startup","model":"kimi-code/kimi-for-coding","profile":"agent"}
```

**[O] verified-here.** Keys are `snake_case` (`camelToSnake$2` is applied to
every input key) and include `hook_event_name`, `session_id`, `cwd`,
`client_type`, plus the event-specific fields. For `SessionStart` those are
`source`, `session_title`, `model`, `profile`. **There is no
`transcript_path`**, and no `CLAUDE_PROJECT_DIR` analogue.

The event's *matcher value* is separate from stdin: `SessionStart` matches on
`source` (`startup` / `resume` / `clear`), `PreToolUse` on the tool name,
`UserPromptSubmit` on the prompt text, `PreCompact` on the trigger.

### 4.4 Hook stdout contract — and the headline finding

`HookJsonOutputSchema` accepts **[O]**:

```
{ "message"?: string,
  "hookSpecificOutput"?: { "message"?: string,
                           "permissionDecision"?: unknown,
                           "permissionDecisionReason"?: unknown } }
```

`additionalContext` appears **0 times** in the entire 191 MB binary
(`strings … | grep -c additionalContext` → `0`). A block is signalled by
`hookSpecificOutput.permissionDecision === "deny"`, or by **exit code 2** with
the reason on stderr.

Worse than a schema mismatch: in `triggerSessionStart` the runner's return
value is discarded —

```js
async triggerSessionStart(source) {
    await this.runner.trigger("SessionStart", { ... });
}
```

— no assignment, no `append`, no `HookResult` dispatch. I confirmed no other
call site consumes a `SessionStart` hook result. Only `UserPromptSubmit`
results are rendered into the conversation (`renderUserPromptHookResult` →
`<hook_result hook_event="UserPromptSubmit">…</hook_result>`) and only `Stop`
results feed a continuation **[O]**.

**Therefore:** upstream's `hooks/unreal-context.sh`, which emits

```json
{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"This working directory is an Unreal Engine project. …"}}
```

(observed by running it in `/tmp/ue-fake2`; `hso keys: ['hookEventName', 'additionalContext']`)
does **nothing on Kimi** — twice over. The `hookEventName` key is not in the
schema at all, and `additionalContext` is not a field Kimi reads, and even if
it were, `SessionStart` output is thrown away.

**[O] verified-here (negative).** This is the single most important row for the
adaptation table: a naive port of the hook produces a silent no-op, not an
error.

### 4.5 The working replacement: `sessionStart.skill`

Kimi's equivalent is declared in the **plugin manifest**, not in a hook:

```json
"sessionStart": { "skill": "<skill-name>" }
```

`readSessionStart` requires `sessionStart.skill` to be a non-empty string;
`enabledSessionStarts()` collects it; `renderPluginSessionStartReminder` looks
the skill up in the catalog and injects its **rendered body** wrapped as:

```
<plugin_session_start plugin="<id>" skill="<name>">
…skill content…
</plugin_session_start>
```

A missing skill logs `plugin sessionStart skill not found` and injects nothing
**[O]**. Injection is reconciled when idle and re-rendered on plugin reload;
the content is neutralized after a compaction summary **[O]**.

**Verdict: static-only.** The code path is unambiguous in the binary, but the
end-to-end injection did not complete in my scratch homes — they abort at the
credential check before a model turn is assembled, and I did not find the
injection in `sessions/**/wire.jsonl`. Confirming it needs a credentialed
session, which is out of my seat's read-only remit.

### 4.6 Hook environment and cwd

Plugin-sourced hooks get extra env; captured verbatim:

```
$ cat /tmp/plugin-hook-env.txt
KIMI_CODE_HOME=/tmp/kimi-home-probe10
KIMI_PLUGIN_ROOT=/tmp/kimi-home-probe10/plugins/envplugin
/tmp/kimi-home-probe10/plugins/envplugin
```

(the third line is `pwd`). **[O] verified-here.** So `KIMI_PLUGIN_ROOT` exists
and behaves like `CLAUDE_PLUGIN_ROOT`, and the hook's cwd is the plugin root.
Config-sourced hooks receive only `KIMI_CODE_HOME` in my capture (the ambient
environment otherwise passes through). `CLAUDE_PLUGIN_ROOT` and
`CLAUDE_PROJECT_DIR` appear **0 times** in the binary.

A hook that fires is proof of the manifest path, and I have one **[O]**:

```
$ cat /tmp/plugin-hook-marker.txt
PLUGIN_HOOK_FIRED
```

— produced by a scratch home whose `plugins/myplugin/kimi.plugin.json` declared
a `SessionStart` hook inline. **Plugin-declared hooks are verified-here.**

### 4.7 Claude-shaped plugin hooks do NOT work

A plugin whose only manifest is `.claude-plugin/plugin.json` plus a
`hooks/hooks.json` in Claude's shape produced **no** hook run:

```
$ ls -R /tmp/kimi-home-probe9/plugins/claudeplugin
/tmp/kimi-home-probe9/plugins/claudeplugin:
hooks

/tmp/kimi-home-probe9/plugins/claudeplugin/hooks:
hooks.json
$ cat /tmp/claude-style-marker.txt
cat: /tmp/claude-style-marker.txt: No such file or directory
```

`.claude-plugin` appears **0 times** in the binary. **[O] verified-here
(negative).** Upstream's hook is reachable on Kimi only after being rewritten
into a manifest `hooks` array.

---

## 5. Plugin manifests

| Field | Kimi | Upstream (Claude) |
|---|---|---|
| Root manifest | `kimi.plugin.json` | — |
| Dir manifest | `.kimi-plugin/plugin.json` | `.claude-plugin/plugin.json` |
| Manifest kind enum | `"kimi-plugin-root" \| "kimi-plugin-dir"` | — |

`KIMI_PLUGIN_ROOT_PATH = "kimi.plugin.json"`, `KIMI_PLUGIN_DIR_PATH =
".kimi-plugin/plugin.json"`; if neither exists the loader errors with
`No manifest at kimi.plugin.json or .kimi-plugin/plugin.json` **[O]**. The
manifest **name** must match `/^[a-z0-9][a-z0-9_-]{0,63}$/` **[O]**.

Accepted fields **[O]** (from `parseManifest` + `recordUnsupportedRuntimeFields`):

| Field | Type | Notes |
|---|---|---|
| `name` | string | required, regex above |
| `version`, `description`, `homepage`, `license`, `keywords` | string / string[] | metadata |
| `author` | string or `{name,email}` | normalized |
| `skills` | string \| string[] | dir list, resolved against plugin root; falls back to the root itself if `SKILL.md` sits at plugin root |
| `agents` | string \| string[] | falls back to `agents/` if present |
| `mcpServers` | object | see §3.4 |
| `hooks` | array | inline hook defs — see §4 |
| `commands` | string \| string[] | path list |
| `interface` | object | `displayName`, `shortDescription`, `longDescription`, `developerName`, `websiteURL` |
| `sessionStart` | `{skill: string}` | see §4.5 |
| `systemPrompt` / `systemPromptPath` | string | inline capped at 32 KiB |
| `skillInstructions` | string | — |

**Unsupported** (logged as `"<field>" is present but not supported by Kimi plugins`):
`tools`, `apps`, `inject`, `configFile`, `config_file`, `bootstrap` **[O]**.

The one installed plugin confirms the shape in the wild **[O]** —
`~/.kimi-code/plugins/managed/kimi-webbridge/kimi.plugin.json` has top-level
keys `['$schema', 'author', 'description', 'interface', 'keywords', 'license',
'name', 'skills', 'version']`, with `"skills": "./skills/"`.

Installed-plugin registry: `~/.kimi-code/plugins/installed.json`, shape
`{version: 1, plugins: [{id, root, source, enabled, installedAt, updatedAt,
originalSource}]}` **[O]**. `source` enum includes `local-path`, `zip-url`, and
git/URL forms. A plugin record with `enabled: true` and a valid manifest is
what makes its skills, hooks, MCP servers, and sessionStart take effect.

> The binary also contains a marketplace catalogue path
> (`plugins/marketplace.json`, tiers `official` / `curated`) and a
> `/plugins` panel with per-plugin `skillCount` / `mcpServerCount` /
> `hookCount` / `commandCount`. A local copy exists at
> `/home/vgpnk/Projects/kimi-code/plugins/marketplace.json` **[O]**; its
> entries are third-party sources, none related to Unreal.

---

## 6. Skills

Discovery roots **[O]** (constants `USER_BRAND_DIRS$1`, `USER_GENERIC_DIRS$1`,
`PROJECT_BRAND_DIRS$1`, `PROJECT_GENERIC_DIRS$1`):

| Scope | Roots |
|---|---|
| user | `<KIMI_CODE_HOME>/skills`, then `~/.agents/skills` (first existing) |
| project | `<project root>/.kimi-code/skills`, then `<project root>/.agents/skills` |
| plugin | each enabled plugin's `skills` dirs, plus `agents` dirs |
| configured | `extraSkillDirs` from config |
| explicit | `--skills-dir` CLI flag |

Project root is the nearest ancestor containing `.git`. **`~/.claude/skills`
and `<project>/.claude/skills` are NOT auto-discovered** — they appear only in
the `/import-from-cc-codex` migration skill text, never in `skillRoots.ts`
**[O]**. The importer skill itself explicitly lists `hooks`, `plugins`, and
`.claude/commands/**` as out of scope.

`mergeAllAvailableSkills` (default `true`) controls whether *all* brand dirs are
merged or only the first existing one.

Parsing rules **[O]** (`parseSkillText`):

- A directory skill's file **must** be named `SKILL.md` and **must** open with a
  `---` frontmatter fence; otherwise `Missing frontmatter in <path>`.
- Directory skills **require** non-empty `name` and `description`; otherwise
  `Missing required frontmatter field "name"|"description"`.
- Frontmatter is parsed as YAML. Aliases are normalized:
  `when-to-use` / `when_to_use` → `whenToUse`, `disable-model-invocation` /
  `disable_model_invocation` → `disableModelInvocation` **[O]**.
- `type` must be a user-activatable type or `"reference"`.
- Body is trimmed and stored as content; `mermaid` and `d2` fenced flowcharts
  are extracted.
- Skill dir scan skips `node_modules` and any entry starting with `.`.
- `${KIMI_SKILL_DIR}` and `${KIMI_SESSION_ID}` are substituted into rendered
  skill content **[O]**.

Upstream's three `SKILL.md` files carry exactly `['name', 'description']`
frontmatter (checked with a Python walk over the pinned clone) — the **minimum
required set**, so all three load on Kimi without edits **[O]** for the
frontmatter claim; the load itself was not exercised.

Relevant sizing: `unreal-mcp/SKILL.md` is 7098 bytes with a **1017-character**
description. Kimi's `descriptionFromBody$1` fallback truncates a derived
description at 240 chars, but that fallback only applies when `description` is
absent; an explicit long description is kept as-is. The 32 KiB limit that Kimi
does enforce is on `AGENTS.md` totals and plugin `systemPrompt`, not skill
descriptions **[O]**.

`Skill` tool names from the session listing map to these roots: user-scope
skills `godspeed`, `shokunin`, `ufo`, `wwkd`, `reverse-engineer-anything` are
the five symlinks in `~/.kimi-code/skills/`; `omarchy`, `swarm`, `tower` come
from `~/.agents/skills/`; `kimi-webbridge` from the plugin root. The binary
also compiles **six** built-in skills under `/builtin/skills/`
(`check-kimi-code-docs`, `custom-theme`, `import-from-cc-codex`, `mcp-config`,
`update-config`, `write-goal`); only three of those surfaced as `builtin:`
entries in this session, which is the `disable-model-invocation: true`
frontmatter at work — `import-from-cc-codex` and `mcp-config` both carry it and
are therefore user-invocable only **[O]** for the count and the frontmatter;
**[I]** for the causal link.

---

## 7. Instructions, agents, and other equivalents

| Claude Code surface | Kimi equivalent | Path |
|---|---|---|
| `CLAUDE.md` (project) | `AGENTS.md`, `agents.md` | walked root→leaf: `.kimi-code/AGENTS.md`, then `AGENTS.md`/`agents.md` |
| `~/.claude/CLAUDE.md` | `AGENTS.md` | `<KIMI_CODE_HOME>/AGENTS.md` |
| — | `AGENTS.md` | `~/.agents/AGENTS.md` or `~/.agents/agents.md` (first existing) |
| `.claude/skills/` | `.kimi-code/skills/`, `.agents/skills/` | see §6 |
| subagents | agent profiles | `~/.kimi-code/agents/<set>/*.md`, `--agent-file`, plugin `agents` |
| `.claude/settings.json` `enabledPlugins` | `plugins/installed.json` | `enabled: true` per record |
| `.claude/settings.json` `hooks` | `[[hooks]]` in `config.toml` + plugin `hooks` | see §4 |
| custom slash commands | plugin `commands` / skills | `/skill:<name>`, `/<pluginId>:<command>` |
| `--dangerously-skip-permissions` | `-y/--yolo`, `--auto` | see below |

`AGENTS.md` loading **[O]**: user brand file first, then the `~/.agents`
generic file, then every directory from the git work-tree root down to the
working directory. Total content over 32 KiB triggers a warning.

`~/.kimi-code/AGENTS.md` **does not exist** on this host, and neither does
`~/.agents/AGENTS.md`; this repo has no `.kimi-code/` or `.agents/` directory
**[O]** — so the lane currently supplies instructions only through the
`AGENTS.md` block the parent passes to subagents.

Permission modes **[O]**: `PermissionModeSchema` is `"yolo" | "manual" |
"auto"`, set by `default_permission_mode` (here `"auto"`), `-y`, or `--auto`.
A finer-grained `[permission]` section exists with `rules = [{decision:
"allow"|"deny"|"ask", scope: "turn-override"|"session-runtime"|"project"|
"user" (default `"user"`), pattern: <regex>, reason}]`
**[O]**. `[experimental]` is an open `record(string, boolean)` — this host sets
`tower`, `notify_user`, `subagent_fork`.

---

## 8. Calibration table — every row carries its exact source path

`K` = `~/.kimi-code/…` (data root, resolved via `$KIMI_CODE_HOME`); `U` =
upstream clone `/tmp/ue-skills-ref` at the pinned SHA; `B` = the `kimi` binary
at `K/bin/kimi` (sha256 in §0), the ground truth for embedded schemas.

| # | Upstream Claude surface (path) | Kimi equivalent (exact path) | Verdict | Evidence |
|---|---|---|---|---|
| 1 | `U/hooks/hooks.json` (`SessionStart` → `bash ${CLAUDE_PLUGIN_ROOT}/hooks/unreal-context.sh`) | `K/config.toml` `[[hooks]]` `event`/`matcher`/`command`/`timeout`; or plugin `hooks` array in `K/plugins/managed/*/kimi.plugin.json` | **port-required** | §4.2, §4.6 live receipts |
| 2 | `U/hooks/unreal-context.sh` emits `hookSpecificOutput.additionalContext` | **no equivalent field**; `B` `HookSpecificOutputSchema` = `{message, permissionDecision, permissionDecisionReason}`; `additionalContext` count = 0 | **port-required (silent no-op otherwise)** | §4.4 |
| 3 | `SessionStart` result consumed by Claude as context | `B` `triggerSessionStart` discards the result; use `sessionStart.skill` in the manifest instead | **port-required** | §4.4, §4.5 |
| 4 | `${CLAUDE_PLUGIN_ROOT}` in `U/hooks/hooks.json` | `KIMI_PLUGIN_ROOT` (and `KIMI_CODE_HOME`); `CLAUDE_PLUGIN_ROOT` count in `B` = 0 | **port-required** | §4.6 captured env |
| 5 | `U/.claude-plugin/plugin.json` | `K/plugins/managed/kimi-webbridge/kimi.plugin.json` (or `<root>/.kimi-plugin/plugin.json`) | **port-required**; `.claude-plugin` count in `B` = 0 | §5; §4.7 negative receipt |
| 6 | `U/skills/unreal-mcp/SKILL.md` (`name`,`description`) | `K/plugins/managed/kimi-webbridge/skills/kimi-webbridge/SKILL.md` (same bundle shape incl. `references/`) | **compatible as-is** | §6; both carry `name`+`description` |
| 7 | `U/skills/unreal-skill/SKILL.md` | same roots | **compatible as-is** | §6 |
| 8 | `U/skills/create-toolset/SKILL.md` | same roots | **compatible as-is** | §6 |
| 9 | `.mcp.json` generated by `ModelContextProtocol.GenerateClientConfig ClaudeCode` | `<git work-tree root>/.mcp.json` — read, Claude-compatible, **trust-gated**; or `<cwd>/.kimi-code/mcp.json` | **compatible with caveat** | §3.3 two live receipts |
| 10 | (none — upstream ships no static `.mcp.json`) | `K/mcp.json` (user-global) and plugin `mcpServers` → `plugin-<id>:<name>` | **compatible** | §3.1, §3.4 |
| 11 | Claude project instructions `CLAUDE.md` | `AGENTS.md` / `.kimi-code/AGENTS.md` walked root→leaf; `K/AGENTS.md` (absent here) | **compatible (renamed)** | §7 |
| 12 | Claude hook event names | `B` `HOOK_EVENT_TYPES` — 20 names, superset of the 9 upstream uses | **compatible (superset)** | §4.1 doctor output |
| 13 | hook `matcher` (Claude alternation syntax) | `B` `matches$1` = `new RegExp(pattern).test(value)` | **compatible** | §2 live `[[hooks]]` uses `task\.completed` |
| 14 | hook exit code 2 = block | `B` `resultFromExitCode`: `exitCode === 2` → `action: "block"`, stderr as reason | **compatible** | §4.4 |
| 15 | `--dangerously-skip-permissions` | `-y/--yolo` or `--auto`; `K/config.toml:1` `default_permission_mode = "auto"` | **compatible (renamed)** | §7 |
| 16 | upstream `README.md` install via `/plugin marketplace add anthropics/claude-plugins-official` | `K/plugins/installed.json` + local-path/zip install; marketplace catalogue `plugins/marketplace.json` | **port-required** | §5 |
| 17 | upstream `README.md` verification step `/plugin`, `/mcp` | `/plugins` panel; `/mcp` built-in command (`B` `ACP_BUILTIN_SLASH_COMMANDS`) | **compatible** | §5, §7 |
| 18 | upstream requires a live Unreal Editor | unchanged — Unreal Editor is not installed on this host; engine install blocked | **unproven-runtime (host-level)** | r101 host receipts |

### 8.1 Port sketch (derived, not executed)

A Kimi-native port of upstream would be one directory with:

1. `kimi.plugin.json` at the root, `name: "unreal-engine-skills-for-claude-code"`,
   `"skills": "./skills/"`.
2. The three `SKILL.md` files copied verbatim — frontmatter already satisfies
   Kimi's `name`+`description` requirement.
3. The `SessionStart` context note moved out of `hooks.json` and into either
   (a) `"sessionStart": {"skill": "unreal-mcp"}` in the manifest, or (b) a
   `[[hooks]]` block whose script writes a field Kimi actually reads. Option (a)
   is the idiomatic Kimi form; note it injects the *whole skill body*, not a
   one-line note, so the equivalent of upstream's short note is a small
   dedicated skill.
4. The `.mcp.json` the user generates stays as-is, with a README addition:
   **trust the folder first**, or the server is skipped.

Steps 1–3 are unexecuted here: they would write outside this seat's declared
path. They are **[I]** inference from the receipts above.

---

## 9. Proven / unproven verification policy

### 9.1 Policy

- **verified-here** — I ran a command on this host and the observed output is
  quoted in this report. The claim may be asserted.
- **static-only** — the mechanism is fully legible in a pinned artifact (the
  sha256-pinned binary or the SHA-pinned clone) but was not executed. State it
  as "the code says X"; never as "X happens".
- **unproven-runtime** — the claim requires a live Unreal Editor, a credentialed
  Kimi session, or another resource this host does not have. It stays
  unproven-on-this-host **by construction**, and no amount of local probing
  changes that.
- **port-required** — a mapping exists but needs a rewrite; treat any unported
  surface as *absent*, because Kimi fails silently (no `additionalContext`
  error, no `.claude-plugin` error, no `mcp_servers` error beyond one doctor
  line).

### 9.2 Register for this probe

| Claim | Verdict |
|---|---|
| `[[hooks]]` in `config.toml` fires, with regex `matcher`, on `SessionStart` | **verified-here** (§4.2) |
| Plugin-manifest `hooks` array fires | **verified-here** (§4.6) |
| Hook stdin key names and `SessionStart` payload | **verified-here** (§4.3) |
| Plugin hooks get `KIMI_PLUGIN_ROOT`; cwd = plugin root | **verified-here** (§4.6) |
| `<git root>/.mcp.json` is read and spawns a stdio server | **verified-here** (§3.3) |
| `<cwd>/.kimi-code/mcp.json` is read and spawns a stdio server | **verified-here** (§3.3) |
| Untrusted folders skip project MCP servers | **verified-here** (§3.3) |
| `[mcp_servers.*]` in `config.toml` is ignored | **verified-here, negative** (§3.2) |
| `.claude-plugin/plugin.json` + `hooks/hooks.json` are not read | **verified-here, negative** (§4.7) |
| `additionalContext` is not a Kimi hook output field | **verified-here, negative** (§4.4) |
| `SessionStart` hook stdout is discarded by `triggerSessionStart` | **static-only** (read from the pinned binary) |
| `sessionStart.skill` injects a skill body as `<plugin_session_start>` | **static-only** (§4.5) |
| Plugin `mcpServers` spawn as `plugin-<id>:<name>` | **static-only** (§3.4) |
| `kimi doctor` validates hooks and prints the 20-event enum | **verified-here** (§4.1) |
| Upstream's three `SKILL.md` frontmatters satisfy Kimi's required fields | **verified-here** (static parse of the pinned clone; not loaded) |
| The ported plugin actually loads in a real Kimi session | **unproven-runtime** (needs a credentialed session; port not written) |
| Any Unreal MCP tool call against a live editor | **unproven-runtime** (no Unreal Editor on this host; engine install blocked pending Epic account linking) |

---

## 10. Method, and what a reader should not trust

Commands run, in order: `ls -R` over `~/.kimi-code`; `cat` of `mcp.json`,
`installed.json`, `kimi.plugin.json`, `tui.toml`; `sed`/`grep` over
`config.toml`; `kimi --version`, `kimi --help`, `kimi doctor` (clean and
deliberately broken); `strings` over the pinned binary (dumped once to
`/tmp/kimi-strings.txt`, 1,558,463 lines, then grepped); seven scratch
`KIMI_CODE_HOME` trees under `/tmp/kimi-home-probe*` exercising hooks, plugin
hooks, Claude-shaped plugin hooks, plugin MCP, and project MCP; `sha256sum` /
`md5sum` for artifact pins; a Python walk over `/tmp/ue-skills-ref` for skill
frontmatter.

Caveats a reader should carry forward:

1. **Version-scoped.** Everything here is `kimi` **2.2.0**, binary sha256
   `8ee7405d…`. Schemas are embedded in the binary, so they move with the
   binary, not with a config file. `~/.kimi-code/updates/latest.json` reports
   `2.2.0` as latest, so this is current as of 2026-10-18.
2. **`strings`-derived constants are static-only** even when quoted verbatim.
   Minified identifiers such as `McpServerStdioConfigSchema$1` are the bundler's
   names, not public API.
3. **Scratch homes abort before the model turn.** Every `/tmp/kimi-home-probe*`
   run ended in `provider managed:kimi-code has no credential configured`. That
   is why hook firing and MCP spawning are verified (they happen earlier) but
   `sessionStart` injection and plugin MCP connect are not. I deliberately did
   **not** copy OAuth state from `~/.kimi-code/oauth/` or `credentials/` to
   close that gap.
4. **The binary is a fat Node bundle** (191 MB, contains a full Node runtime,
   grammars, and bundled JS). Absence of a string is meaningful only when the
   search is unambiguous — I checked `additionalContext` (0), `.claude-plugin`
   (0), `CLAUDE_PLUGIN_ROOT` (0), `CLAUDE_PROJECT_DIR` (0), and
   `.claude/settings` (0), each of which would have appeared if supported.
5. **No file under `~/.kimi-code/` was modified.** No credential, OAuth, token,
   or key file was read. `config.toml` md5 `6e9accb1168ce4eeceaa2bb5501ef256`
   was identical before and after this probe.
6. **Only this report was written** — `reports/round-101/probes/kimi-surfaces.md`.
   No commit was made.

---

## 11. Top findings, ranked

1. **The `SessionStart` hook port is a silent no-op** — twice over: no
   `additionalContext` field, and the result is discarded. Fix:
   `"sessionStart": {"skill": "<name>"}` in the manifest. (§4.4, §4.5)
2. **`.claude-plugin/plugin.json` is not read.** The manifest must become
   `kimi.plugin.json`, and `hooks/hooks.json` must become an inline `hooks`
   array. (§4.7, §5)
3. **Project `.mcp.json` works but is trust-gated.** Untrusted repos lose the
   entire Unreal tool surface with one startup warning. (§3.3)
4. **`[mcp_servers.*]` in `config.toml` is dead** — a port that carries it over
   from the operator's config gets nothing, with only a `doctor` line as
   evidence. (§3.2)
5. **The three upstream skills need no frontmatter edits** — `name` +
   `description` is exactly Kimi's required set, and the bundle shape
   (`SKILL.md` + `references/`) matches the installed `kimi-webbridge` plugin.
   (§6)
6. **Kimi's hook event set is larger** (20 names, all receipted), and
   `KIMI_PLUGIN_ROOT` is the `CLAUDE_PLUGIN_ROOT` analogue, so the command line
   inside `hooks.json` survives with a variable rename. (§4.1, §4.6)
