# r107-kimi-adapt — KIMI-ADAPT-LEAD

Plan (5 lines):
1. Read `~/.kimi-code/config.toml` + host skill/plugin surfaces — cite exact paths/observations.
2. Read `adaptation-kimi.md` + r102/r103 shards for the stale-citation fold-spec.
3. Diff Claude-side claims against observed Kimi surfaces; produce updated mapping table.
4. Draft the refreshed table + dated note into this shard (orchestrator lands); label [O]/[I]/[?].
5. Note what stays UNPROVEN; keep <400 lines.

Status: COMPLETE. This seat wrote only this file + `/var/tmp/r107-kimi-adapt/`. Nothing landed in
`corpus/knowledge/unreal-mcp/` — §4 and §6 are drafts for the orchestrator.
Labels: **[O]** observed here (command + output below) · **[I]** inference · **[?]** unknown.

---

## 0. Headline verdict — table stale by *content*, anchors intact

| question | answer | command |
|---|---|---|
| upstream pin moved? | **no** — `a6aa73ad…`, plugin `3.1.1` | `gh api …/commits/main` + `git ls-remote … main` + 3 fresh clones (§1) |
| Kimi CLI changed? | **no** — byte-identical | `sha256sum ~/.kimi-code/bin/kimi` = `8ee7405d…`, BuildID `5e67bdf9…`, `2.2.0` |
| `config.toml` changed? | **yes, 4th time** — sole `[[hooks]]` now line **3538** | `grep -n '\[\[hooks\]\]' ~/.kimi-code/config.toml` |

§5's invalidation rule is **not** triggered: binary anchor intact, every strings-line pointer
re-resolves, strings dump byte-identical to r102's (§2).

But r102/r103 only repaired *citations*; **content** was left alone. Three gaps remain:

1. **The editor-written `.mcp.json` is behind a workspace-trust gate** (§3.3) — unmentioned in r101's
   rows *and* its §6 register. Without trust, the integration silently yields zero servers.
2. **`config.toml [mcp_servers.*]` is a trap** (§3.5) — a Codex idiom the v2 engine ignores.
3. **`sessionStart.skill` is now quotable** (§3.8) — the concrete Kimi-native replacement for row 4.

Plus one **promotion**: r101 §6 carried "the `"type": "http"` key … tolerated by Kimi's strict
schema" as `unproven-runtime`. It is now **PROVEN-HERE** (§3.4) and leaves the register.

*Self-correction:* an earlier draft of this shard said row 11 "omits" the third MCP layer. It does
not — row 11 names all three. The gap is the trust gate + path-coincidence caveat, not the list.

---

## 1. Pin + binary re-measurement [O]

```bash
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin main
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main
$ gh api repos/EpicGames/unreal-engine-skills-for-claude-code-plugin/commits/main \
    --jq '.sha, .commit.committer.date, .commit.message'
a6aa73ada02a9fb1f5415bec491f9942c519b297
2026-09-17T01:28:32Z
[MCP] Permit safe concurrent tool calls
$ for d in /var/tmp/r107-va/repo /var/tmp/r107-verify2/clone /var/tmp/r107-pindelta/new-pin; do git -C "$d" rev-parse HEAD; done
a6aa73ada02a9fb1f5415bec491f9942c519b297   # ×3
$ jq -r .version corpus/knowledge/unreal-mcp/upstream/.claude-plugin/plugin.json
3.1.1
$ sha256sum /home/vgpnk/.kimi-code/bin/kimi
8ee7405d82958f0a50a3aab0773aba9e01057978bad93ba379eaf89e5b6111af  kimi
$ readelf -n /home/vgpnk/.kimi-code/bin/kimi | grep -i 'Build ID'
    Build ID: 5e67bdf95c7646325b62decd0ca8d375d325ea19
$ stat -c '%s %y' /home/vgpnk/.kimi-code/bin/kimi
191892672 2026-10-14 19:58:50.344019494 -0300
```

Four transports (VENDOR-A clone, VENDOR-B codeload tarball, VERIFY-2 clone, PIN-DELTA clone) agree:
**the r107 "re-vendor" is a re-verification, not a delta.** Binary sha256, BuildID, size and **mtime**
are all identical to r101-r103, so §5's "a CLI upgrade invalidates every strings-line pointer" is not
triggered. [O]

---

## 2. Strings-line pointers re-resolve exactly [O]

```bash
$ strings -n 3 /home/vgpnk/.kimi-code/bin/kimi > /var/tmp/r107-kimi-adapt-strings.txt
$ wc -l …strings.txt ; sha256sum …strings.txt
2644877 /var/tmp/r107-kimi-adapt-strings.txt
380092949dc22e60778bd5dce77b5cbb9912ff87d662db3cace59e0e115e225d  …strings.txt
$ grep -n 'KIMI_PLUGIN_ROOT_PATH = \|KIMI_PLUGIN_DIR_PATH = \|async function resolveMcpJsonPaths' …strings.txt
1832505:	KIMI_PLUGIN_ROOT_PATH = "kimi.plugin.json";
1832506:	KIMI_PLUGIN_DIR_PATH = ".kimi-plugin/plugin.json";
1743845:async function resolveMcpJsonPaths(input) {
$ for p in enabledPlugins 'settings\.json' CLAUDE_PLUGIN_ROOT additionalContext hookEventName; do printf '%s=%s ' "$p" "$(grep -c "$p" …strings.txt)"; done
enabledPlugins=0 settings\.json=0 CLAUDE_PLUGIN_ROOT=0 additionalContext=0 hookEventName=1
$ grep -c enabledPlugins ~/.kimi-code/config.toml
0
```

Same line numbers as r101; the dump sha256 matches r102's exactly (`380092949dc2…`), so extraction is
reproducible byte-for-byte. All five §4 NONE-FOUND greps still 0; row 4's load-bearing claim
("exactly one `hookEventName`, at the input-payload construction site") reproduces at count = 1.
Rows 1, 4, 9 keep their verdicts. [O]

---

## 3. New / changed surfaces

### 3.1 `config.toml` drift — 4th observation, now a rule [O]

```bash
$ grep -n '\[\[hooks\]\]' ~/.kimi-code/config.toml ; wc -l ~/.kimi-code/config.toml
3538:[[hooks]]
3570 /home/vgpnk/.kimi-code/config.toml
$ sed -n '3538,3542p' ~/.kimi-code/config.toml
[[hooks]]
event = "Notification"
matcher = "task\\.completed"
command = "notify-send -a 'Kimi Code' 'Background task completed' 'A Kimi Code background task finished'"
timeout = 5
```

Line-number history: **2932** (r101) → **3219** (r102) → **3290** (r103) → **3538** (r107); file grew
3322 → 3570 lines in a day. Substance unchanged. Four points make this a *rule*: **cite the block,
never the number.** Row 13's `config.toml:1` is still `default_permission_mode = "auto"`. [O]

### 3.2 The three MCP layers, re-read in full [O]

```bash
$ awk 'NR>=1743845 && NR<=1743852' …strings.txt
async function resolveMcpJsonPaths(input) {
	const projectRoot = (await findGitWorkTree(input.fs, start))?.root ?? start;
	return { user: join$93(resolveKimiHome(input.homeDir), "mcp.json"),
	         projectRoot: join$93(projectRoot, ".mcp.json"),
	         project: join$93(input.cwd, ".kimi-code", "mcp.json") };
```

`loadMcpServersDetailed` reads all three and tags each server with its origin path. Row 11 already
names all three — confirmed, not corrected. The **new** caveat: `projectRoot` is the **git** root,
while the editor's write location is **build-kind** dependent (setup.md:61: workspace root next to
`Engine/` for source builds, next to the `.uproject` for installed builds). They coincide in the
common case; the divergent case is unverified → §5. **[I]**

### 3.3 Workspace-trust gate on project-level MCP — the missing row [O]

```bash
$ mkdir -p /var/tmp/r107-kimi-adapt/proj/.git ; cat /var/tmp/r107-kimi-adapt/proj/.mcp.json
{ "mcpServers": { "unreal-mcp": { "type": "http", "url": "http://127.0.0.1:8000/mcp" } } }
$ cd /var/tmp/r107-kimi-adapt/proj && KIMI_CODE_HOME=/var/tmp/r107-kimi-adapt/home kimi -p "reply with the single word OK"
Warning: this folder is not trusted; skipped 1 project-level MCP server: unreal-mcp (http: http://127.0.0.1:8000/mcp).
  Run `kimi` here and choose "Trust this folder", or set KIMI_CODE_TRUST_WORKSPACE=1, to enable them.
$ KIMI_CODE_TRUST_WORKSPACE=1 KIMI_CODE_HOME=… kimi -p "hi"
$ grep -i mcp /var/tmp/r107-kimi-adapt/home/logs/kimi-code.log | tail -1
ERROR mcp server unavailable  server=unreal-mcp transport=http status=failed reason="fetch failed"
```

Docs corroborate (mcp.html, `/en/`): *"Trust this folder; review the listed command and arguments or
remote URL before confirming. Trusting the folder enables the project-level MCP servers for that
workspace."* [O] — documented behaviour, not a probe artifact. **Consequence:** the recommended
"do nothing for MCP" path (row 11) has an unstated prerequisite — trust the UE project folder once,
or set `KIMI_CODE_TRUST_WORKSPACE=1`. Without it, zero servers.

### 3.4 PROMOTION — the editor's `"type": "http"` key is accepted [O]

r101 §6: *"whether the strict variant rejects the extra key is `unproven-runtime`"*. Settled
**without** a live server, because rejection would happen at parse time:

```bash
$ grep -i mcp …/logs/kimi-code.log | tail -3    # entries: type+url / bare url / stdio+snake
ERROR mcp server unavailable  server=editor-shaped       transport=http status=failed reason="fetch failed"
ERROR mcp server unavailable  server=no-transport-http   transport=http status=failed reason="fetch failed"
ERROR mcp server unavailable  server=stdio-snake         transport=stdio status=failed reason="write EPIPE"
```

Three things proven at once: (1) `"type": "http"` + `url` → parsed, `transport=http` — the extra key
is **ignored, not rejected**; (2) a bare `url` → `transport=http`, the preprocess inference firing as
quoted; (3) `startup_timeout_sec` on a stdio entry did **not** error — the entry reached the
transport layer (`status=failed` is a spawn failure, not a schema failure). `fetch failed` /
`write EPIPE` is *expected* — nothing listens on 8000 and `/bin/true` is not an MCP server. What is
proven is the **parse-and-register** step, the part in doubt.

### 3.5 `config.toml [mcp_servers.*]` is ignored by the v2 engine [O]

The host's own config carries two such tables, and they do nothing:

```bash
$ grep -n 'mcp_servers' ~/.kimi-code/config.toml ; sed -n '3544,3548p' ~/.kimi-code/config.toml
3544:[mcp_servers.rea]
3549:[mcp_servers.rea.env]
[mcp_servers.rea]
command = "npx"
args = [ "-y", "rea-agents@6.7.0", "mcp" ]
startup_timeout_sec = 30
$ kimi doctor config ~/.kimi-code/config.toml
OK config.toml  …
  Unknown top-level key ignored by the v2 engine: mcp_servers.
All checked config files are valid.
$ grep -c tomltest …/home/logs/kimi-code.log    # planted [mcp_servers.tomltest] never appears
0
```

`mcp_servers` occurs in the binary **only** inside the `/import-from-cc-codex` skill text (the Codex
*source* idiom to read from) — never as a Kimi config key. [O] This is the likeliest porter mistake,
because the import skill's own mapping table lists `[mcp_servers.<name>]` → Kimi fields. **Kimi MCP
config lives in `mcp.json`, never `config.toml`.**

### 3.6 Skill-surface census [O]

```bash
$ ls ~/.kimi-code/skills/ ; ls ~/.agents/skills/
cursor-lane  godspeed→  reverse-engineer-anything→  shokunin→  ufo→  wwkd→
godspeed  omarchy→  reverse-engineer-anything  shokunin→  swarm→  tower→  ufo→
$ ls ~/.kimi-code/plugins/managed/kimi-webbridge/
03-browser-extension.txt  04-headroom.txt  kimi.plugin.json  skills/
```

Row 15's three roots confirmed, and a **fourth** is now live: `<plugin-root>/skills/`, declared by
the manifest's `"skills": "./skills/"` field. Binary counts: `.kimi-code/skills` ×7,
`.claude/skills` ×6, `.claude/commands` ×4, `.agents/skills` ×3 — the `.claude/*` paths are import
sources, not live config (unchanged from §4.1). [O]

### 3.7 Manifest schema — live reference + new detail [O]

`~/.kimi-code/plugins/managed/kimi-webbridge/kimi.plugin.json`:

```json
{ "$schema": "https://kimi.com/schemas/kimi.plugin.schema.json",
  "name": "kimi-webbridge", "version": "1.11.3", "description": "…",
  "keywords": ["browser","webbridge","cdp","automation","web","scraping"],
  "author": "Moonshot AI", "license": "Proprietary", "skills": "./skills/",
  "interface": { "displayName": "…", "shortDescription": "…", "longDescription": "…",
                 "developerName": "Moonshot AI", "websiteURL": "…" } }
```

New vs. r101 Row 8: a **`skills`** field pointing at a skill directory, and an **`interface`** block
the row's field list omits. `$schema` is a 302 to `www.kimi.com` (`curl -sIL … -w '%{http_code}'` →
`200 https://www.kimi.com/`) — decorative; the binary constant is the real contract. New constants
alongside r101's pair: [O]

```bash
$ awk 'NR>=1832500 && NR<=1832513' …strings.txt
	PLUGIN_SYSTEM_PROMPT_MAX_BYTES = 32 * 1024;
	UNSUPPORTED_RUNTIME_FIELDS = [ "tools", "apps", "inject", "configFile", "config_file", "bootstrap" ];
```

Over-limit `systemPrompt`/`systemPromptPath` is **ignored with a warning**, not fatal (`1832281`,
`1832308`). `UNSUPPORTED_RUNTIME_FIELDS` is six manifest fields Kimi accepts syntactically but does
not implement — a porter copying a Claude manifest using `tools`/`apps`/`inject` gets **silence**. [O]

### 3.8 Plugin `sessionStart.skill` — the portable hook replacement [O]

```bash
$ grep -n 'sessionStart' …strings.txt | grep -v sessionStarted | head -2
1832169:			sessionStart: readSessionStart(raw["sessionStart"], diagnostics),
1832266:			message: "\"sessionStart.skill\" is required when sessionStart is present"
$ awk 'NR==1896697' …strings.txt
	return `<plugin_session_start plugin="${…}" skill="${…}">\n${skillContent}\n</plugin_session_start>`;
```

`sessionStart.skill` is **required** when `sessionStart` is present; the rendered block is
`<plugin_session_start plugin=… skill=…>`, with a `SUPERSEDES_SUFFIX` so a later block wins. [O]
This is the Kimi-native route to replace the upstream hook's dead `additionalContext` — better than
rewriting the hook's printf.

### 3.9 Hook events + MCP schema [O]

```bash
$ awk … …strings.txt   # HOOK_EVENT_TYPES$1
PreToolUse, PostToolUse, PostToolUseFailure, PermissionRequest, PermissionResult,
UserPromptSubmit, Stop, StopFailure, Interrupt, SessionStart, SessionEnd,
SubagentStart, SubagentStop, PreCompact, PostCompact, Notification
$ awk 'NR>=1743801 && NR<=1743841' …strings.txt
	McpServerHttpConfigSchema = object({ transport: literal("http"), url: string().url(), … });
	McpServerConfigSchema = preprocess((raw) => { … if ("transport" in obj) return obj;
		if (typeof obj["command"] === "string") return { …obj, transport: "stdio" };
		if (typeof obj["url"] === "string") return { …obj, transport: "http" }; return obj; }, …);
```

16 events; `SessionStart` is present (row 2's mechanism exists). Docs (hooks.html, `/en/`) give its
matcher as `startup or resume` — **no `clear`** — so row 3's verdict stands. The binary's only
`source: "startup"` literal sits at the session-creation site (`1805854`). The MCP schemas are built
with `object(...)`, **not** `strictObject` — that is *why* `"type"` is ignored (§3.4). [O]

---

## 4. Draft — refreshed adaptation table (drop-in for §1)

18 rows (was 15). Rows 1-15 keep their verdicts except row 15 (adds a 4th root); rows 16-18 are new;
the §6 `"type"` item is promoted into row 11 and removed from the register.

| # | Claude Code mechanism | Kimi Code CLI equivalent | Status | Source pointer |
|---|---|---|---|---|
| 1 | `CLAUDE_PLUGIN_ROOT` | `KIMI_PLUGIN_ROOT` + `KIMI_CODE_HOME` | static-only | `upstream/hooks/hooks.json:10` → binary `KIMI_PLUGIN_ROOT: pluginRoot`; `/en/customization/plugins.html` §Hooks in Plugins |
| 2 | `hooks.json` + `SessionStart` | `[[hooks]]` in `config.toml`, `event = "SessionStart"` | verified-here | `hooks.json:4-5` → `~/.kimi-code/config.toml`, the file's **sole** `[[hooks]]` block (line 3538 @ 2026-10-19 — moving target, locate with `grep -n`); §3.9 |
| 3 | Matcher `startup\|resume\|clear` | regex over `source`, values `startup`/`resume` only — no `clear` | verified-here | `hooks.json:6` → `/en/customization/hooks.html`; §3.9 |
| 4 | Hook stdout `{hookSpecificOutput:{hookEventName,additionalContext}}` | **NONE-FOUND** — Kimi parses only `{message, hookSpecificOutput{message, permissionDecision, permissionDecisionReason}}`; stdout is not injected | verified-here | `unreal-context.sh:84` → §2 (`hookEventName`=1) + r101 §3.2/§3.3 |
| 5 | Hook exit-code semantics | same 0 = allow, 2 = block; other non-zero = fail-open allow | static-only | `unreal-context.sh:47` → `/en/customization/hooks.html` §Return Values |
| 6 | `/plugin install …@claude-plugins-official` + `/plugin marketplace add` | `/plugins install <github-url>`, `/plugins marketplace [source]`; `KIMI_CODE_PLUGIN_MARKETPLACE_URL` | static-only | `upstream/README.md:39,45` → `/en/customization/plugins.html` §Installation and Management |
| 7 | `/plugin` Installed tab | `/plugins` panel + `list\|info\|enable\|disable\|remove\|reload` | static-only | `README.md:64` → `/en/customization/plugins.html`; `~/.kimi-code/plugins/installed.json` |
| 8 | `.claude-plugin/plugin.json` | `kimi.plugin.json` (or `.kimi-plugin/plugin.json`); adds `skills`, `interface` | verified-here | `upstream/.claude-plugin/plugin.json:1` → live manifest §3.7 |
| 9 | `.claude/settings.json` → `enabledPlugins` | **NONE-FOUND** — plugins are per-user only; no project-scope install | verified-here | `README.md:50-57` → §2 greps (0 hits) + docs "per-user … project-level installation scope is not yet supported" |
| 10 | `/mcp` | `/mcp` (status) + `/mcp-config` (edit/login) | static-only | `README.md:65`, `setup.md:129` → `/en/customization/mcp.html` |
| 11 | Editor `.mcp.json` (`GenerateClientConfig ClaudeCode`) | Kimi reads project-root `.mcp.json` natively — **but only in a trusted folder**; plus `$KIMI_CODE_HOME/mcp.json` and `<cwd>/.kimi-code/mcp.json` | verified-here | `setup.md:61,70-79`; `README.md:72` → §3.2, §3.3, §3.4 |
| 12 | `GenerateClientConfig` targets `ClaudeCode\|Cursor\|VSCode\|Gemini\|Codex\|All` | **NONE-FOUND** — no Kimi target upstream; use the `ClaudeCode` output via row 11 | static-only | `operations.md:14`, `setup.md:61` → r102 §4.2 re-run |
| 13 | `--dangerously-skip-permissions` | modes `manual`/`yolo`/`auto`; `-y/--yolo`, `--auto` | static-only | `README.md:92` → `config.toml:1`; `kimi --help` |
| 14 | `CLAUDE_UE_HOOK_DEBUG` | **NONE-FOUND** — set your own var and read it in the hook (portable: the hook runs `bash` either way) | static-only | `unreal-context.sh:5,8` → §2 (`CLAUDE_*` census) |
| 15 | `.claude/skills/` (per the plugin's own prose) | `~/.kimi-code/skills/`, `<project>/.kimi-code/skills/`, `~/.agents/skills/`, `<plugin-root>/skills/` | verified-here | `upstream/skills/unreal-skill/SKILL.md:3` → §3.6 (four roots) |
| 16 | *(new)* hook `additionalContext` injection | `<plugin-root>/kimi.plugin.json` → `sessionStart.skill`, rendered as `<plugin_session_start plugin=… skill=…>` | verified-here | §3.8; the recommended replacement for row 4 |
| 17 | *(new)* — | Project-level MCP servers are gated by a **workspace-trust** prompt; `KIMI_CODE_TRUST_WORKSPACE=1` overrides | verified-here | §3.3; `/en/customization/mcp.html` |
| 18 | *(new)* Codex idiom `[mcp_servers.<name>]` in `config.toml` | **ignored by the v2 engine** — a Kimi MCP server belongs in `mcp.json` | verified-here | §3.5 (`kimi doctor config`) |

**Row 11's caveat block, as it should read** — replacing r101's §2 row-11 caveat (a):

> (a) **Resolved.** The editor writes `{"type": "http", "url": "…"}`. Kimi's `McpServerConfigSchema`
> is a non-strict `object()` whose preprocess infers `transport` from `url`, so `type` is **ignored,
> not rejected** — verified by registering the exact editor shape and reading `transport=http` (§3.4).
> (b) unchanged: the hook's `.mcp.json` presence check at `unreal-context.sh:61` looks for the right
> file. **New:** the entry loads only in a **trusted** workspace (§3.3), and Kimi's `projectRoot` is
> the **git** root while the editor's write location is **build-kind** dependent (setup.md:61) — §5.

---

## 5. Unproven-runtime register (updated)

| Item | Why unproven | What would settle it |
|---|---|---|
| Kimi connects to `unreal-mcp` over HTTP and lists it | no editor, no server; probe got `fetch failed` (expected) | editor running + `/mcp` shows `unreal-mcp` connected |
| `list_toolsets` / `describe_toolset` / `call_tool` round-trip | server exposes no tools without `AllToolsets` and a live editor | one successful read-only `call_tool` |
| ~~`"type": "http"` tolerated by the strict schema~~ | **SETTLED this round** — §3.4, promoted into row 11 | — |
| Editor's `.mcp.json` write location == Kimi's `projectRoot` in a **source** build | editor writes to the workspace root next to `Engine/` (setup.md:61); Kimi uses `findGitWorkTree`; equal in the common case, unverified when they differ | a source-build UE project whose git root ≠ workspace root, `.mcp.json` present, `/mcp` shows the server |
| `unreal-mcp-proxy` stdio entry under Kimi | proxy binary ships with the engine build | proxy installed + `/mcp` shows `unreal-mcp-proxy` |
| `AIAssistantToolset.GetDockedContext` | upstream requires the **Claude Code** tab docked in an asset editor | reimplemented against a Kimi docked surface, or accepted as lost |

**Removed:** the `"type": "http"` item (promoted). **Added:** the source-build path coincidence.
Net: 5 items.

---

## 6. Proposed dated note for `adaptation-kimi.md`

Dated correction note, not a rewrite — matches the r103 house style. Orchestrator lands; this seat
writes nothing into `corpus/`.

```md
## Correction note — 2026-10-19 (r107)

Re-measured on this host. **No row above this heading is altered.**
Evidence: `reports/round-107/r107-kimi-adapt.md`.

**Anchor intact.** `kimi --version` = `2.2.0`; BuildID `5e67bdf95c7646325b62decd0ca8d375d325ea19`;
binary sha256 `8ee7405d…` and mtime unchanged since r101. Every strings-line pointer re-resolves
(`KIMI_PLUGIN_ROOT_PATH` 1832505, `resolveMcpJsonPaths` 1743845); the strings dump is byte-identical
to r102's. §5's invalidation rule is **not** triggered. Upstream pin unmoved: `a6aa73ad…`, plugin
`3.1.1`.

**C1 (r103) is now a 4-point series.** The file's sole `[[hooks]]` block moved again:
2932 (r101) → 3219 (r102) → 3290 (r103) → **3538** (r107, file 3570 lines). Substance unchanged.
Cite the block, never the number.

**C2 (r103) holds.** The four cited docs paths still 404 at root and 200 under `/en/`.

**Three content additions — new rows 16-18:**
1. `sessionStart.skill` in a plugin manifest renders `<plugin_session_start …>` into the session —
   the Kimi-native replacement for row 4's dead `additionalContext`.
2. Project-level MCP servers are gated by a workspace-trust prompt; `KIMI_CODE_TRUST_WORKSPACE=1`
   overrides. Without trust, the editor-written `.mcp.json` yields **zero** servers.
3. `[mcp_servers.<name>]` in `config.toml` is **ignored by the v2 engine** (`kimi doctor config`:
   "Unknown top-level key ignored by the v2 engine: mcp_servers"). Kimi MCP config lives in
   `mcp.json`. This is a Codex source idiom; the `/import-from-cc-codex` mapping table reads as
   though Kimi accepts it — it does not.

**One promotion out of §6.** "The `"type": "http"` key is tolerated by Kimi's strict schema" is
**settled**: the schema is a non-strict `object()` and `type` is ignored, not rejected. Register item
removed; row 11 now carries the resolved caveat.

**One addition to §6.** The editor writes `.mcp.json` at a **build-kind-dependent** location
(setup.md:61: workspace root for source builds, next to the `.uproject` for installed builds), while
Kimi resolves `projectRoot` as the **git** root. These coincide in the common case; the divergent
case is unverified. `unproven-runtime`.

**Live-editor posture unchanged.** Unreal Editor is still not installed on this host (the r107 docker
unlock attempt had produced no image at time of writing), so no Unreal runtime claim is made here.
```

---

## 7. What this seat did NOT do

- **No writes into `corpus/knowledge/unreal-mcp/`** — §4 and §6 are drafts. Only this shard and
  `/var/tmp/r107-kimi-adapt/` were written. Verified: `git status --short corpus/` → empty.
- **No Unreal runtime claim.** The editor is absent; the docker pull
  (`wukakuki/unreal-engine:dev-slim-5.8.3`) had produced no image
  (`docker images | grep -ci unreal` → `0`), so the unlock verdict belongs to UNLOCK-LEAD. [O]
- **No live model probe re-run.** r101 §3.3's end-to-end probe was not repeated — it needs a working
  model config, and the throwaway home's synthetic provider is deliberately unreachable. §2's binary
  evidence already carries that row. **[?]** labeled, not asserted.
- **`kimi doctor` does not validate `mcp.json`.** It has only `config` and `tui` subcommands, so an
  `mcp.json` schema error is observable only at session start. Follow-up: any static validator? **[?]**

### Reproducibility

| Artifact | Path | Note |
|---|---|---|
| fresh strings dump | `/var/tmp/r107-kimi-adapt-strings.txt` | 2 644 877 lines, sha256 `380092949dc2…` (identical to r102) |
| probe home | `/var/tmp/r107-kimi-adapt/home` | throwaway `KIMI_CODE_HOME`; operator config never touched |
| probe project | `/var/tmp/r107-kimi-adapt/proj` | synthetic `.git` + editor-shaped `.mcp.json` |
| mcp receipt | `/var/tmp/r107-kimi-adapt/home/logs/kimi-code.log` | `transport=http` lines, §3.3/§3.4 |

All `/var/tmp` paths are transient; re-derive with the commands in §1-§3.
