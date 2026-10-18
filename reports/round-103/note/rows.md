# r103 · SEAT-02 ROW-REPRODUCER — all 15 adaptation rows re-run

Round r103 · lane game-dev-3d-shokunin · written 2026-10-18.
Seat scope: re-run every Kimi-side verification command the 15 rows of
`corpus/knowledge/unreal-mcp/adaptation-kimi.md` cite, at this runtime, and record
REPRODUCED / NOT-REPRODUCED with an observed-output digest. No file outside this seat's
write scope was modified. `adaptation-kimi.md` was read only.

Runtime identity used for every line below (all re-derived here, none reused):

```
$ /home/vgpnk/.kimi-code/bin/kimi --version
2.2.0
$ sha256sum /home/vgpnk/.kimi-code/bin/kimi
8ee7405d82958f0a50a3aab0773aba9e01057978bad93ba379eaf89e5b6111af  kimi
$ readelf -n /home/vgpnk/.kimi-code/bin/kimi | grep -i 'Build ID'
    Build ID: 5e67bdf95c7646325b62decd0ca8d375d325ea19
$ stat -c '%s %y' /home/vgpnk/.kimi-code/bin/kimi
191892672 2026-10-14 19:58:50.344019494 -0300
```

Binary anchor **intact** → §5's invalidation rule is not triggered. Fresh strings extraction
was byte-identical to r102's, so every cited line number re-resolves at the same number:

```
$ strings -n 3 /home/vgpnk/.kimi-code/bin/kimi > /tmp/r103work/kimi_strings.txt
$ wc -l /tmp/r103work/kimi_strings.txt && sha256sum /tmp/r103work/kimi_strings.txt
2644877 /tmp/r103work/kimi_strings.txt
380092949dc22e60778bd5dce77b5cbb9912ff87d662db3cace59e0e115e225d  /tmp/r103work/kimi_strings.txt
```

Upstream pin and the whole vendored tree re-verified (12/12, first 16 hex):

```
$ git -C /tmp/ue-skills-ref rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
$ # sha256 /tmp/ue-skills-ref/<f> vs corpus/knowledge/unreal-mcp/upstream/<f>, all 12 rows of the Provenance block
MATCH .claude-plugin/plugin.json 5aa984848f0fd48c   MATCH hooks/hooks.json 259124f0631b7d4b
MATCH CODEOWNERS 653d372559bee26d                   MATCH hooks/unreal-context.sh d3f1c871cd4edd52
MATCH .gitignore 0fad2f57a9fac18a                   MATCH LICENSE 5b337be051359edc
MATCH README.md 483693ad0e14d027                    MATCH skills/create-toolset/SKILL.md e9d050087f36de51
MATCH skills/unreal-mcp/references/operations.md dbed002b4a46ab10
MATCH skills/unreal-mcp/references/setup.md bd16206ea142dc9c
MATCH skills/unreal-mcp/SKILL.md 7ef8b991a82f591c   MATCH skills/unreal-skill/SKILL.md 7a0af781c458c7d1
```

---

## Verdict table — one line per row

| # | Verdict | Observed-output digest |
|---|---|---|
| 1 | **REPRODUCED** | `upstream/hooks/hooks.json:10` = `"command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/unreal-context.sh"`. Binary `KIMI_PLUGIN_ROOT` at strings 1832086/1832092/1832500/1832505/1833038; the cited binding `KIMI_PLUGIN_ROOT: pluginRoot` is at **1833038**. `grep -c CLAUDE_PLUGIN_ROOT` = **0**. |
| 2 | **PARTIAL — pointer NOT-REPRODUCED, substance REPRODUCED** | `hooks.json:4-5` = `"SessionStart": [` / `{` (ok). But cited `~/.kimi-code/config.toml:2932-2937` is now a `[models."opencode-go-7/longcat-2.0"]` table — **void**. The file's **sole** `[[hooks]]` is at **line 3290** (r102 wrote 3219; file grew 3251→3322 lines), event `Notification`. A live `[[hooks]]` precedent with the same field vocabulary does exist (§3.1 probe proves it fires). |
| 3 | **REPRODUCED** | `hooks.json:6` = `"matcher": "startup\|resume\|clear"`. Live probe `source` = `"startup"` only. Docs `en/customization/hooks.html`: "SessionStart **startup or resume**". Binary `source: "startup"` (1805854), `source: "resume"` (1805990), `source: "clear"` (1949603) — the last is a transcript `messages[]` entry source, exactly as §2 states. |
| 4 | **REPRODUCED** | `unreal-context.sh:84` = `printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n'`. `HookSpecificOutputSchema` at 1841256 carries only `message`/`permissionDecision`/`permissionDecisionReason`; `grep -c additionalContext` = **0**; `grep -c hookEventName` = **1**, at 1841291 (`hookEventName: event`, the *input* payload). Load-bearing gap intact. |
| 5 | **REPRODUCED** | `unreal-context.sh:47` = `fi` (the silent `exit 0` no-project branch). Docs `en/customization/hooks.html` §Return Values anchor present: "exit code 2 means block", "fail-open, preventing hook errors from becoming blockers". |
| 6 | **REPRODUCED** | `README.md:39` = `/plugin install unreal-engine-skills-for-claude-code@claude-plugins-official`; `:45` = `/plugin marketplace add anthropics/claude-plugins-official`. Docs `en/customization/plugins.html` §Installation and Management anchor present; `KIMI_CODE_PLUGIN_MARKETPLACE_URL` at binary 1834775. |
| 7 | **REPRODUCED** | `README.md:64` = `/plugin` Installed-tab text. `installed.json:1-13` parses (`version 1`, 1 plugin `kimi-webbridge`). Dispatcher at strings 2092103+ handles `sub` ∈ {list, install, marketplace, info, mcp, enable, disable}; token counts `plugins.enable` 8, `plugins.list` 5, `plugins.marketplace` 6, `plugins.reload` 7, `plugins.remove` 4, `plugins.info` 2. |
| 8 | **REPRODUCED** | `upstream/.claude-plugin/plugin.json:1` = `{`; keys `name`/`version`/`description`/`author`/`license` present. Binary `KIMI_PLUGIN_ROOT_PATH = "kimi.plugin.json"` at **1832505**, `KIMI_PLUGIN_DIR_PATH = ".kimi-plugin/plugin.json"` at **1832506** (cited lines exact). |
| 9 | **REPRODUCED** | `README.md:50-57` = `.claude/settings.json` + `enabledPlugins` block. `grep -c enabledPlugins` config.toml = **0**, strings = **0**; `grep -c settings.json` = **0**; `.claude/settings[a-z.]*` = empty. Binary `/import-from-cc-codex` text (2170146): "Do \*\*not\*\* migrate credentials, OAuth tokens, sessions, history, logs, hooks,". Docs: "per-user and apply to all projects; project-level installation scope is not yet supported". |
| 10 | **REPRODUCED** | `README.md:65` = `/mcp`; `setup.md:129` = `/mcp` connected-server line. Binary `/mcp-config` (2019478), `name: "mcp"` (1941682), plus `/mcp/servers`, `/mcp/auth::begin|complete|cancel|reset`; builtin `mcp-config` skill at 1757762. Docs `en/customization/mcp.html` contains `/mcp`, `/mcp-config`, "connection status". |
| 11 | **REPRODUCED** | `setup.md:61` = `GenerateClientConfig ClaudeCode`; `setup.md:70-79` = `{"mcpServers":{"unreal-mcp":{"type":"http","url":"http://127.0.0.1:8000/mcp"}}}`; `README.md:72` = the static-`.mcp.json` note. Binary `resolveMcpJsonPaths` at **1743845**, body byte-for-byte as quoted (user / projectRoot `.mcp.json` / project `.kimi-code/mcp.json`). `~/.kimi-code/mcp.json:1-11` parses. |
| 12 | **REPRODUCED** | `operations.md:14` = the client-arg row listing `ClaudeCode, Cursor, VSCode, Gemini, Codex, All`. `grep -o "GenerateClientConfig [A-Za-z]*"` over `upstream/.../references/*.md` → `ClaudeCode` (plus a bare prose `GenerateClientConfig ` header on ops.md:14). `grep -rn "Kimi\|kimi" upstream/ --include=*.md --include=*.json` → **exit 1, 0 matches**. |
| 13 | **REPRODUCED** | `README.md:92` = the `--dangerously-skip-permissions` warning. `~/.kimi-code/config.toml:1` = `default_permission_mode = "auto"` (still line 1 — not stale). Binary `"manual"`/`"yolo"`/`"auto"` all present, `--yolo` at 2016191. Docs `en/configuration/config-files.html` §Top-level fields: `default_permission_mode = "manual"`, "…`yolo`, or `auto`". |
| 14 | **REPRODUCED** | `unreal-context.sh:5,8` = `# Opt-in debug logging: set CLAUDE_UE_HOOK_DEBUG…` / `if [ -n "$CLAUDE_UE_HOOK_DEBUG" ]; then`. `grep -o "CLAUDE_[A-Z_]*"` on the fresh dump → exactly `CLAUDE_FAMILY_WORD_RE`, `CLAUDE_THINKING_VISION_TOOL_PREFIXES`, `CLAUDE_VISION_TOOL_PREFIXES`. |
| 15 | **REPRODUCED** | `upstream/skills/unreal-skill/SKILL.md:3` explicitly scopes itself away from "Claude Code's harness skills under `.claude/skills/`". `~/.kimi-code/skills/` = godspeed, reverse-engineer-anything, shokunin, ufo, wwkd; `~/.agents/skills/` = godspeed, omarchy, reverse-engineer-anything, shokunin, swarm, tower, ufo. Both cited dirs exist and are populated. |

**Tally: 14 REPRODUCED, 1 PARTIAL (row 2 — citation line moved, verdict unchanged), 0 NOT-REPRODUCED.**

---

## §3 live probes — re-run at this runtime

§3.1 (throwaway `KIMI_CODE_HOME`, synthetic project, unreachable provider port — hook fires
before the model call, so a timeout is expected):

```
$ cd /home/vgpnk/.cache/r103probe/fakeproj && KIMI_CODE_HOME=$W/home_ss timeout 25 kimi -p "hi"
kimi exit=124
$ cat $W/ss_stdin.json
{"hook_event_name":"SessionStart","session_id":"session_95a827e6-0b0b-43ea-9051-0ef9f3335c6d",
 "cwd":"/home/vgpnk/.cache/r103probe/fakeproj","client_type":"kimi_code_cli",
 "source":"startup","model":"probe/probe-model","profile":"agent"}
$ cat $W/ss_fired.txt
fired
```

REPRODUCED — same shape and key set as `adaptation-kimi.md:159`, `source` = `startup`,
payload on **stdin** as JSON.

§3.2 (the upstream hook's own output, both branches):

```
$ cd <proj>/Source && bash corpus/knowledge/unreal-mcp/upstream/hooks/unreal-context.sh; echo exit=$?
{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"This working
 directory is an Unreal Engine project. The project is `MyGame.uproject`. … No `.mcp.json`
 is present at the project root yet. Run `ModelContextProtocol.GenerateClientConfig
 ClaudeCode` in the editor console to generate one."}}
exit=0
$ # same hook where .mcp.json exists → "…An `.mcp.json` is already present at the project root."
$ cd /tmp && CLAUDE_UE_HOOK_DEBUG=1 bash /tmp/ue-skills-ref/hooks/unreal-context.sh; echo exit=$?
unreal-context.sh: no Unreal Engine project marker found walking up from /tmp
exit=0
```

REPRODUCED — the row's quoted string is the **no-`.mcp.json`** branch; both branches and the
silent outside-project no-op reproduce, as does the debug line. Static hygiene re-checked:

```
$ bash -n upstream/hooks/unreal-context.sh          # exit=0
$ shellcheck --version | head -2                     # version: 0.11.0
$ shellcheck upstream/hooks/unreal-context.sh        # exit=0
$ cmp /tmp/ue-skills-ref/hooks/unreal-context.sh upstream/hooks/unreal-context.sh  # IDENTICAL
```

§3.3 (end-to-end, real answering model — the devin shim on `127.0.0.1:8787` is live this
runtime, so this is a genuine answer and not an error artifact):

```
$ cd $W/fakeproj && KIMI_CODE_HOME=$W/home timeout 120 kimi -p "reply with the single word OK"
• OK
To resume this session: kimi -r session_48c635ea-1abc-4941-8e3e-0e6aa881d923
kimi exit=0
$ cat $W/hookran.txt
RAN-1792348359
$ grep -c "Unreal" $W/home/sessions/*/*/agents/main/wire.jsonl
0
$ grep -rl "Unreal Engine project" $W/home/sessions ; echo exit=$?
exit=1
$ wc -c $W/home/sessions/*/*/agents/main/wire.jsonl
102001
```

REPRODUCED — hook executed (`RAN-…`), model answered (`OK`), and the injected Unreal context
never reached the model (count **0** on a 102001-byte transcript, `grep -rl` empty). Same
result as the r101 row.

§3.4 / §3.5 pointer re-resolution:

```
$ grep -n 'KIMI_PLUGIN_ROOT_PATH\|KIMI_PLUGIN_DIR_PATH' /tmp/r103work/kimi_strings.txt
1832500:var KIMI_PLUGIN_ROOT_PATH, KIMI_PLUGIN_DIR_PATH, PLUGIN_SYSTEM_PROMPT_MAX_BYTES, …
1832505:	KIMI_PLUGIN_ROOT_PATH = "kimi.plugin.json";
1832506:	KIMI_PLUGIN_DIR_PATH = ".kimi-plugin/plugin.json";
$ grep -n 'async function resolveMcpJsonPaths' /tmp/r103work/kimi_strings.txt
1743845:async function resolveMcpJsonPaths(input) {
```

Both cited line numbers exact. §3.5's corroborating builtin text also reproduces at 1757772:
"Project-root: `<project root>/.mcp.json`, where project root is found by walking up from
`<cwd>` to the nearest `.git`. Use for Claude-compatible, repo-shared, or cross-agent servers."

---

## §4 NONE-FOUND greps — all still 0 / unchanged

```
$ grep -c enabledPlugins /tmp/r103work/kimi_strings.txt        # 0
$ grep -c enabledPlugins ~/.kimi-code/config.toml              # 0
$ grep -c 'settings\.json' /tmp/r103work/kimi_strings.txt      # 0
$ grep -o '\.claude/settings[a-z.]*' /tmp/r103work/kimi_strings.txt | sort -u   # (empty)
$ grep -c CLAUDE_PLUGIN_ROOT /tmp/r103work/kimi_strings.txt    # 0
$ grep -c additionalContext /tmp/r103work/kimi_strings.txt     # 0
$ grep -o 'CLAUDE_[A-Z_]*' /tmp/r103work/kimi_strings.txt | sort -u
CLAUDE_FAMILY_WORD_RE
CLAUDE_THINKING_VISION_TOOL_PREFIXES
CLAUDE_VISION_TOOL_PREFIXES
$ grep -c hookEventName /tmp/r103work/kimi_strings.txt         # 1  (at 1841291)
```

All five §4 verdicts stand. §4.2 re-run against the **vendored** copy (durable substitute for
`/tmp/ue-skills-ref`, per r102's S3): `ClaudeCode` is the only target; `grep -rn "Kimi\|kimi"`
over `upstream/` exits 1 with zero matches.

---

## §2 row-note claims spot-checked

- Row 11's `resolveMcpJsonPaths` quote — byte-exact (see §3.5 above).
- Row 11's caveat (a): Kimi infers transport from `url` and never reads `type`; not exercised
  against a live server → still `unproven-runtime`, correctly labeled.
- Row 2/3's "`clear` appears only as a transcript `messages[]` entry source and as the
  `/clear` slash command alias" — reproduced: `source: "clear"` at 1949603 sits inside a
  `messages.push({… source: "clear", message: {role: "assistant", …}})` transcript reset
  block, not a session-start source.
- Row 13's `config.toml:1` — not stale (see row 13 line).

---

## Blockers / notes for the parent seat

1. **Row 2's `config.toml:2932-2937` citation is void at this runtime** and the correct line
   has moved twice (r102 saw 3219; now **3290**, file 3322 lines). Any freshness note landing
   in `adaptation-kimi.md` should either cite line 3290 or, better, say "the file's sole
   `[[hooks]]` block" — the operator edits this file continuously, so a literal line number is
   stale the same day. Row 2's *verdict* is unaffected.
2. **The row-4 doc URL class is confirmed stale**, matching r102's C1: all four
   `moonshotai.github.io/kimi-code/{customization,configuration}/*.html` paths return **404**,
   while every `/en/` and `/zh/` variant returns **200**. Content anchors named by the rows
   (`§Return Values`, `§Plugin Manifest`, `§Installation and Management`, `§Hooks in Plugins`,
   `§Top-level fields`, "connection status") all resolve on the `/en/` pages.
3. **`/tmp` is a quota-limited tmpfs and it filled mid-run** (`Disk quota exceeded`; 13G/16G,
   IUse 69%). My first probe home was unwritable; all live probes were re-run under
   `/home/vgpnk/.cache/r103probe/`. The strings dump at `/tmp/r103work/kimi_strings.txt`
   completed before the fill. Future seats should not assume `/tmp` has room.
4. `reports/round-103/note/rows.md` was created by this seat; no other path was written.
5. No Unreal Editor is installed and no live-MCP call was attempted — every row above is a
   host-side (env/config/binary/docs/script) probe. The `unproven-runtime` register is
   untouched and no Unreal runtime claim is made here.
