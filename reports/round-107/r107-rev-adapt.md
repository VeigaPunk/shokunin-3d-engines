# r107-rev-adapt — REV-ADAPT (independent verification of adaptation rows)

Plan (5 lines):
1. Pick 5 adaptation rows from `corpus/knowledge/unreal-mcp/adaptation-kimi.md` (§1 table) and re-run their cited commands on THIS host, independently of the r101/r103 authors.
2. For each row: reproduce the exact command, paste observed output, label [O]/[I]/[?], and state whether the row's Status class survives.
3. Re-verify the anchor chain that every row depends on (pin SHA, CLI BuildID, binary sha256, vendored `upstream/` digest prefixes).
4. Flag any row where the r101/r103 verdict is not reproducible as written, with the exact command that falsifies it.
5. Write this shard only (orchestrator lands); keep <400 lines; do not touch `corpus/knowledge/unreal-mcp/`.

Status: **COMPLETE** (5/5 rows re-measured; 1 citation-reproduction nit found, verdict unchanged).

## 0. Seat scope and method

KEY=REV-ADAPT. Task: verify 5 adaptation rows against this host, *independently* — every
command re-run from scratch; no value copied from the r101 table, the r103 note, or a
sibling shard. Rows chosen for their load: **1** (plugin root), **3** (hook matcher /
source enum), **4** (the `additionalContext` gap — the row that changes the
recommendation), **9** (team-install `NONE-FOUND`), **11** (project-root `.mcp.json`).
Labels: **[O]** observed here with the command shown, **[I]** inference, **[?]** unknown.
A row "survives" only if a *fresh* command reproduces it. Scratch:
`/var/tmp/r107-rev-adapt/`; nothing written inside `corpus/knowledge/unreal-mcp/`.

## 1. Anchor chain re-verified first (every row depends on it)

Rows 1/3/4/9/11 all cite either the `kimi` binary or the vendored `upstream/` tree.
If either anchor moved, every row is void by §5's invalidation rule. Re-measured:

```
$ /home/vgpnk/.kimi-code/bin/kimi --version
2.2.0
$ sha256sum /home/vgpnk/.kimi-code/bin/kimi
8ee7405d82958f0a50a3aab0773aba9e01057978bad93ba379eaf89e5b6111af  /home/vgpnk/.kimi-code/bin/kimi
$ file /home/vgpnk/.kimi-code/bin/kimi | grep -o 'BuildID[^,]*'
BuildID[sha1]=5e67bdf95c7646325b62decd0ca8d375d325ea19
```
[O] CLI version, BuildID and binary sha256 are **identical** to the values r101 recorded
and r103 re-confirmed, so §5's invalidation rule is not triggered and the "binary strings
line N" citations remain valid.

```
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin main
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main
```
[O] The remote still serves the r101 pin on `main`; the pin did not move.

```
$ cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256
upstream/.claude-plugin/plugin.json: OK
upstream/CODEOWNERS: OK
upstream/.gitignore: OK
upstream/hooks/hooks.json: OK
upstream/hooks/unreal-context.sh: OK
upstream/LICENSE: OK
upstream/README.md: OK
upstream/skills/create-toolset/SKILL.md: OK
upstream/skills/unreal-mcp/references/operations.md: OK
upstream/skills/unreal-mcp/references/setup.md: OK
upstream/skills/unreal-mcp/SKILL.md: OK
upstream/skills/unreal-skill/SKILL.md: OK
exit=0
```
[O] 12/12 vendored files match the shipped reference manifest. Independently, a direct
`sha256sum` of all 12 paths reproduces the first-16 prefixes r101's Provenance lists
(`5aa984848f0fd48c`, `653d372559bee26d`, `0fad2f57a9fac18a`, `259124f0631b7d4b`,
`d3f1c871cd4edd52`, `5b337be051359edc`, `483693ad0e14d027`, `e9d050087f36de51`,
`dbed002b4a46ab10`, `bd16206ea142dc9c`, `7ef8b991a82f591c`, `7a0af781c458c7d1`) — the
bytes the rows quote are the pinned bytes.

**Anchor verdict: INTACT.** All five rows below are testable as written.

### 1.1 The `/tmp` working trees are gone (r103 C3's prediction, confirmed)

```
$ git -C /tmp/ue-skills-ref rev-parse HEAD
fatal: ... (exit 128)
$ ls /tmp/kimi_strings.txt
(no such file)
```
[O] Both r101 `/tmp` artifacts (`/tmp/ue-skills-ref`, `/tmp/kimi_strings.txt`) are
**absent**. r103's C3 predicted exactly this ("a reboot or `tmpfiles` sweep removes
them"). Consequence for this shard: §3/§4's `/tmp` commands are **not** re-runnable as
written; I rebuilt the strings dump into my own scratch and used the vendored
`upstream/` tree in place of the clone, which is what C3 already designated as the
durable substitute.

```
$ strings -n 3 /home/vgpnk/.kimi-code/bin/kimi > /var/tmp/r107-rev-adapt/strings.txt
$ wc -l /var/tmp/r107-rev-adapt/strings.txt
2644877
$ sha256sum /var/tmp/r107-rev-adapt/strings.txt
380092949dc22e60778bd5dce77b5cbb9912ff87d662db3cace59e0e115e225d
```
[O] **Line numbers in this shard are from THIS dump** (`strings -n 3`, 2 644 877 lines,
sha256 above), which is the same extraction parameters r101 used — and it reproduces
r101's line numbers exactly where r101 gave them (1832505/1832506, 1743845). Any future
reader must regenerate with the same `-n 3`; a different `-n` shifts every offset.

---

## 2. Row 1 — `CLAUDE_PLUGIN_ROOT` → `KIMI_PLUGIN_ROOT` (static-only)

Cited command: `grep -c "CLAUDE_PLUGIN_ROOT" <strings>`; constants `KIMI_PLUGIN_ROOT_PATH`,
`KIMI_PLUGIN_DIR_PATH`.

```
$ grep -c "CLAUDE_PLUGIN_ROOT" /var/tmp/r107-rev-adapt/strings.txt
0
$ grep -n 'KIMI_PLUGIN_ROOT_PATH\|KIMI_PLUGIN_DIR_PATH' /var/tmp/r107-rev-adapt/strings.txt
1832086:	const rootJsonPath = node_path.default.join(pluginRoot, KIMI_PLUGIN_ROOT_PATH);
1832087:	const dirJsonPath = node_path.default.join(pluginRoot, KIMI_PLUGIN_DIR_PATH);
1832092:		message: `No manifest at ${KIMI_PLUGIN_ROOT_PATH} or ${KIMI_PLUGIN_DIR_PATH}`
1832500:var KIMI_PLUGIN_ROOT_PATH, KIMI_PLUGIN_DIR_PATH, PLUGIN_SYSTEM_PROMPT_MAX_BYTES, UNSUPPORTED_RUNTIME_FIELDS;
1832505:	KIMI_PLUGIN_ROOT_PATH = "kimi.plugin.json";
1832506:	KIMI_PLUGIN_DIR_PATH = ".kimi-plugin/plugin.json";
$ grep -c "KIMI_PLUGIN_ROOT" /var/tmp/r107-rev-adapt/strings.txt
10
```
[O] `CLAUDE_PLUGIN_ROOT` occurs **0 times**; the Kimi manifest constants exist with
exactly the values the row states (`kimi.plugin.json`, `.kimi-plugin/plugin.json`), and
`KIMI_PLUGIN_ROOT` occurs 10 times. My line numbers 1832505/1832506 are **identical** to
r101 §3.4's, independently reproducing the citation.
[I] `CLAUDE_PLUGIN_ROOT` being absent means the upstream hook command line
(`bash ${CLAUDE_PLUGIN_ROOT}/hooks/unreal-context.sh`, `upstream/hooks/hooks.json:10`)
cannot be copied verbatim onto Kimi — the row's conclusion.
**Verdict: row 1 survives as `static-only`.** Not promoted: I read the binary, I did not
install a plugin and observe `KIMI_PLUGIN_ROOT` being exported to a hook process (§5's
promotion rule — reading the binary twice is not verification).

## 3. Row 3 — hook matcher `startup|resume|clear` (verified-here)

Cited claim: Kimi's `SessionStart` `source` is `startup` or `resume` only; there is no
`clear`. Three independent lines of evidence, all re-derived:

**(a) Live wire payload, fresh session** — throwaway `KIMI_CODE_HOME` (`home2`), a
`SessionStart` hook whose command is `cat > …/ss_stdin.json`, synthetic project
`/var/tmp/r107-rev-adapt/fakeproj`, probe model routed at the local cursor shim:

```
$ cd /var/tmp/r107-rev-adapt/fakeproj
$ KIMI_CODE_HOME=/var/tmp/r107-rev-adapt/home2 timeout 60 kimi -p "reply with the single word OK"
• OK
$ cat /var/tmp/r107-rev-adapt/ss_stdin.json
{"hook_event_name":"SessionStart","session_id":"session_e5062055-9b01-47d3-87de-dcc828b69b5d","cwd":"/var/tmp/r107-rev-adapt/fakeproj","client_type":"kimi_code_cli","source":"startup","model":"probe/probe","profile":"agent"}
```

**(b) Live wire payload, resumed session** — same home, `-r <id>`:

```
$ KIMI_CODE_HOME=/var/tmp/r107-rev-adapt/home2 timeout 60 kimi -r session_e5062055-… -p "…"
• Ready when you are.
$ cat /var/tmp/r107-rev-adapt/ss_stdin.json
{"hook_event_name":"SessionStart","session_id":"session_e5062055-9b01-47d3-87de-dcc828b69b5d","cwd":"/var/tmp/r107-rev-adapt/fakeproj","client_type":"kimi_code_cli","source":"resume","model":"probe/probe","profile":"agent"}
```
[O] Both legal values observed **on the wire**: `"source":"startup"` on create,
`"source":"resume"` on resume. The payload shape (stdin JSON, `hook_event_name`
snake_case) matches r101 §3.1 too.

**(c) Code path for the source enum** — the trigger site and its two callers:

```
$ sed -n '1805849,1805856p' strings.txt        # session create
			await this.announceCreated({ sessionId, handle, source: "startup" });
$ sed -n '1805986,1805991p' strings.txt        # session resume
				await this.announceCreated({ sessionId, handle, source: "resume" });
$ sed -n '1841505,1841509p' strings.txt        # what reaches SessionStart
				if (event.sessionId !== this.context.sessionId) return;
				if (event.source !== "fork") event.waitUntil(this.triggerSessionStart(event.source));
```
[O] Only `startup` and `resume` are ever passed to `announceCreated`, and the
`SessionStart` trigger **explicitly excludes `"fork"`**. The exhaustive scan of string
literals `source: "<word>"` across the whole dump returns exactly two session-lifecycle
sources — `1805854: source: "startup"` and `1805990: source: "resume"` — and **no**
`source: "clear"`:
```
$ grep -no 'source: "[a-z]*"' strings.txt | sort -u -t: -k2
… (38 distinct) … 1805854:source: "startup" … 1805990:source: "resume" …
```
[O] The only `"clear"` near session handling is a **transcript entry** source, not a
session-start source:
```
$ sed -n '1949603,1949608p' strings.txt
					source: "clear",
					message: { role: "assistant", content: [], toolCalls: [] },
```
**Verdict: row 3 survives as `verified-here`, strengthened** — r101 had only a `startup`
probe; this run adds the `resume` value on the wire and the code-level proof that
neither `fork` nor `clear` can reach the matcher. The row's "harmless but partially dead"
characterization is exactly right: `startup|resume` match, `clear` never fires.

## 4. Row 4 — `additionalContext` is not read (verified-here, the load-bearing row)

**(a) The output schema, verbatim from the binary:**

```
$ sed -n '1841245,1841264p' strings.txt
var DEFAULT_TIMEOUT_SECONDS, KILL_GRACE_MS$1, OptionalStringSchema, HookSpecificOutputSchema, HookJsonOutputSchema;
	OptionalStringSchema = preprocess((value) => {
	HookSpecificOutputSchema = preprocess((value) => isRecord$15(value) ? value : void 0, looseObject({
		message: OptionalStringSchema,
		permissionDecision: unknown().optional(),
		permissionDecisionReason: unknown().optional()
	}).optional());
	HookJsonOutputSchema = looseObject({
		message: OptionalStringSchema,
		hookSpecificOutput: HookSpecificOutputSchema
	});
```
[O] The parsed output schema has `message`, `permissionDecision`,
`permissionDecisionReason` — **no `additionalContext`**. It is `looseObject`, so the
upstream JSON parses without error to an object with no `message`: silent, not broken.

```
$ grep -c "additionalContext" /var/tmp/r107-rev-adapt/strings.txt
0
$ grep -c 'hookEventName' /var/tmp/r107-rev-adapt/strings.txt
1
$ sed -n '1841291p' strings.txt
		hookEventName: event,
```
[O] `additionalContext` occurs **0 times** in the whole binary. `hookEventName` occurs
**exactly once**, at the point where the CLI builds the *input* payload — it is not a key
of the *output* schema. Both match the row's text precisely.

**(b) End-to-end, real upstream hook wired into a real Kimi session** — synthetic UE
project `/var/tmp/r107-rev-adapt/ueproj` (contains `MyGame.uproject`), hook runs the
**vendored** `upstream/hooks/unreal-context.sh` and captures its stdout, plus a side-effect
file proving execution:

```
$ cd /var/tmp/r107-rev-adapt/ueproj/Source
$ KIMI_CODE_HOME=/var/tmp/r107-rev-adapt/home4 timeout 90 kimi -p "reply with the single word OK"
• OK
$ cat /var/tmp/r107-rev-adapt/hookout.json
{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"This working directory is an Unreal Engine project. The project is `MyGame.uproject`. Prefer Unreal Engine conventions (C++/UObject patterns, Slate, UHT reflection) when suggesting code. Use the `unreal-mcp` skill for tasks that involve driving the Unreal Editor via MCP. No `.mcp.json` is present at the project root yet. Run `ModelContextProtocol.GenerateClientConfig ClaudeCode` in the editor console to generate one."}}
$ cat /var/tmp/r107-rev-adapt/hookran4.txt
RAN
$ find $H/sessions -name wire.jsonl -path '*main*' -exec grep -c "Unreal" {} \;
0
$ grep -rl "Unreal Engine project" $H/sessions
(none)
```
[O] The hook **executed** (side-effect file written) and emitted the **correct** upstream
context — correctly detecting `MyGame.uproject` from the `Source/` subdirectory — yet
`Unreal` appears **0 times** in the main agent transcript. The model answered normally
(`• OK`), which makes this a real negative rather than an error artifact. A **full
independent reproduction** of the row's load-bearing claim.
**Verdict: row 4 survives as `verified-here`.**

## 5. Row 9 — `enabledPlugins` / project-scope install `NONE-FOUND` (verified-here)

```
$ grep -c enabledPlugins ~/.kimi-code/config.toml
0
$ grep -c "enabledPlugins" /var/tmp/r107-rev-adapt/strings.txt
0
$ grep -c "settings.json" /var/tmp/r107-rev-adapt/strings.txt
0
$ grep -o "\.claude/settings[a-z.]*" /var/tmp/r107-rev-adapt/strings.txt | sort -u
(empty)
```
[O] `enabledPlugins` occurs **0 times** in both the operator's live config and the binary;
`settings.json` **0 times**; no `.claude/settings*` path exists. The row's `NONE-FOUND`
and its exact search commands reproduce. The docs quotation it relies on is verbatim too
(with the `/en/` prefix r103 C2 requires):

```
$ curl -s https://moonshotai.github.io/kimi-code/en/customization/plugins.html | grep -o 'per-user[^<]*'
per-user and apply to all projects; project-level installation scope is not yet supported.
```
**Verdict: row 9 survives as `verified-here`.** `NONE-FOUND` is a *negative* claim: it
means these searches returned 0, not that no such feature can exist.

## 6. Row 11 — Kimi reads project-root `.mcp.json` (verified-here)

```
$ sed -n '1743845,1743853p' strings.txt
async function resolveMcpJsonPaths(input) {
	const start = normalize$2(input.cwd);
	const projectRoot = (await findGitWorkTree(input.fs, start))?.root ?? start;
	return {
		user: join$93(resolveKimiHome(input.homeDir), "mcp.json"),
		projectRoot: join$93(projectRoot, ".mcp.json"),
		project: join$93(input.cwd, ".kimi-code", "mcp.json")
	};
```
[O] Reproduced at **the same line 1743845** r101 cited: `projectRoot` is
`<git-root>/.mcp.json` — the exact filename and location the Unreal editor's
`GenerateClientConfig ClaudeCode` writes. The three-layer resolution
(`user` / `projectRoot` / `project`) is unchanged.

Corroborating shipped-skill text in the same binary:
```
$ grep -n 'Project-root' strings.txt | head -1
1757772:… - Project-root: `<project root>/.mcp.json`, where project root is found
  by walking up from `<cwd>` to the nearest `.git`. Use for
  Claude-compatible, repo-shared, or cross-agent servers. …
```
[O] The `mcp-config` builtin skill states the same three scopes and explicitly names
project-root `.mcp.json` as the Claude-compatible, repo-shared surface.
**Verdict: row 11 survives as `verified-here`.** The row's own caveat (a) — that Kimi
infers `transport` from `command` vs `url` and does **not** read the Claude
`"type": "http"` key, so tolerance of the extra key is `unproven-runtime` — is *not*
settled here: I did not start a session against a live `unreal-mcp` server. It stays
`unproven-runtime`, correctly labeled.

---

## 7. Findings — one citation nit, no verdict change

**F1 — r103 C3's `GenerateClientConfig` grep is incomplete (not wrong).** C3 printed the
§4.2 re-run against the vendored copy as exactly two lines:
```
upstream/skills/unreal-mcp/references/operations.md:GenerateClientConfig ClaudeCode
upstream/skills/unreal-mcp/references/setup.md:GenerateClientConfig ClaudeCode
```
My re-run of the same command produces **three** matches — the extra one is the table
row's placeholder `<client>`:
```
$ grep -o "GenerateClientConfig [A-Za-z]*" upstream/skills/unreal-mcp/references/*.md | sort -u
upstream/skills/unreal-mcp/references/operations.md:GenerateClientConfig 
upstream/skills/unreal-mcp/references/operations.md:GenerateClientConfig ClaudeCode
upstream/skills/unreal-mcp/references/setup.md:GenerateClientConfig ClaudeCode
$ sed -n '14p' upstream/skills/unreal-mcp/references/operations.md
| `ModelContextProtocol.GenerateClientConfig <client>` | Regenerate the per-client config file. Args: `ClaudeCode`, `Cursor`, `VSCode`, `Gemini`, `Codex`, `All`. |
```
[O] The third match (`GenerateClientConfig ` with an empty target, from
`` `GenerateClientConfig <client>` ``) is real and `sort -u` keeps it, so C3's printed
output is **not byte-exact**. **The conclusion is unaffected**: the only *concrete* target
anywhere in the plugin is `ClaudeCode`; the full client list lives in the engine doc
string, and `grep -rn "Kimi\|kimi" upstream/ --include=*.md --include=*.json` still exits
1 (no matches). Row 12's `NONE-FOUND` for a Kimi target therefore stands; only the
*reproduction transcript* in r103 C3 is incomplete. [I] This is a reporting nit, not a
content defect — worth a one-line correction note if the orchestrator folds r103's C3
forward.

**F2 — the row-2 `config.toml` line number drifted again, exactly as r103 warned.** The
file's sole `[[hooks]]` block is now at **line 3538** (file is 3570 lines), vs r103's 3290
(3322 lines), r102's 3219 (3251 lines), r101's 2932. Same field vocabulary
(`event`/`matcher`/`command`/`timeout`), same event `Notification`:
```
$ grep -n '\[\[hooks\]\]' ~/.kimi-code/config.toml
3538:[[hooks]]
$ sed -n '3538,3542p' ~/.kimi-code/config.toml
[[hooks]]
event = "Notification"
matcher = "task\\.completed"
command = "notify-send -a 'Kimi Code' 'Background task completed' 'A Kimi Code background task finished'"
timeout = 5
```
[O] Confirms r103 C1's instruction to locate the block with `grep -n` and **never** cite
the number. Row 13's `config.toml:1` is still `default_permission_mode = "auto"` [O].
(Row 2 is not one of my five assigned rows; recorded because it is a live drift the
orchestrator will want, and it costs nothing.)

**F3 — docs `/en/` prefixes still required (r103 C2 holds).** `curl` to all four
`https://moonshotai.github.io/kimi-code/en/{customization/{plugins,hooks,mcp},configuration/config-files}.html`
returns **200** [O]. r103 measured the root-relative forms at 404; the `/en/` forms are
what the rows must cite, and they resolve.

## 8. What this shard does NOT claim

- **No runtime claim about Unreal.** No editor is installed; §6 of `adaptation-kimi.md`
  stays entirely `unproven-runtime`. In particular row 11's caveat (a) (Kimi tolerating the
  `"type": "http"` key from a live editor-written `.mcp.json`) is **not** settled here.
- **No promotion of any `static-only` row.** Rows 1 and 9 rest on binary strings and config
  reads; I reproduced those reads, which re-verifies the *citation*, not the *mechanism*.
  §5's promotion rule is explicit that reading the binary twice is not verification, and I
  did not install a plugin (row 1) or attempt a project-scope install (row 9).
- **No row was found to be wrong.** All five reproduce as written; the only defect found
  (F1) is in a *prior round's transcript*, not in any table row.

## 9. Reproduction kit (so a future seat can falsify this shard)

```
strings -n 3 /home/vgpnk/.kimi-code/bin/kimi > /tmp/strings.txt   # -n 3 is load-bearing
grep -c CLAUDE_PLUGIN_ROOT /tmp/strings.txt                       # 0   (row 1)
grep -n 'KIMI_PLUGIN_ROOT_PATH\|KIMI_PLUGIN_DIR_PATH' /tmp/strings.txt   # 1832505/1832506
grep -c additionalContext /tmp/strings.txt                        # 0   (row 4)
grep -c hookEventName /tmp/strings.txt                            # 1   (input-only)
sed -n '1805854p;1805990p' /tmp/strings.txt                       # startup / resume (row 3)
grep -c enabledPlugins ~/.kimi-code/config.toml                   # 0   (row 9)
sed -n '1743845,1743853p' /tmp/strings.txt                        # resolveMcpJsonPaths (row 11)
cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256   # 12/12 OK
```
Live probes: a throwaway `KIMI_CODE_HOME` with a `probe/probe` model at
`http://127.0.0.1:8788/v1` and a `SessionStart` hook that `cat >` its stdin; run
`kimi -p` (source=startup) then `kimi -r <id> -p` (source=resume). For row 4, point the
hook at the vendored `upstream/hooks/unreal-context.sh` from a dir holding a `*.uproject`
and grep the transcript for `Unreal` (expect 0).

## 10. Status

- [O] 5/5 assigned rows re-measured; all reproduce as written; anchor chain INTACT.
- [O] 1 citation-reproduction nit (F1), no verdict change; 1 live drift (F2, row 2's hooks line).
- [O] Docker pull still running; no UE editor work performed or attempted (out of scope).
- Draft only. Orchestrator lands; nothing written inside `corpus/knowledge/unreal-mcp/`.
