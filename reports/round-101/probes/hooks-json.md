# SEAT-17 PROBE — `upstream/hooks/hooks.json` validation, event enumeration, and SessionStart wiring

Round r101 · lane game-dev-3d-shokunin · axis: coverage / depth / calibration

Seat scope: validate `hooks/hooks.json` with `jq`; enumerate every hook event and its command;
confirm the `SessionStart` hook wiring and the bash `${CLAUDE_PLUGIN_ROOT}` expansion.

**Verdict: `verified-here`** — not static-only. The hook was executed through the real Claude Code
plugin loader end-to-end and its output was observed arriving in the outgoing model request.

## 0. Artifact identity

| Field | Value | Command actually run |
|---|---|---|
| Upstream | `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin` | — |
| Pinned SHA | `a6aa73ada02a9fb1f5415bec491f9942c519b297` | `git -C /tmp/ue-skills-ref rev-parse HEAD` |
| Clone SHA matches pin | yes | `a6aa73ada02a9fb1f5415bec491f9942c519b297` (identical string) |
| Clone worktree | clean | `git -C /tmp/ue-skills-ref status --porcelain` → empty |
| Git blob | `6be4b8b7b7e082372186702daf92bd03cc7e5b95` | `git -C /tmp/ue-skills-ref ls-tree HEAD hooks/hooks.json` |
| sha256 | `259124f0631b7d4b92e9e744003e8798b910c00dac201656b97906b3b5ebdc0c` | `sha256sum hooks/hooks.json` |
| Size | 357 bytes | `wc -c hooks/hooks.json` → `357 hooks/hooks.json` |
| Canonical (jq -c) sha256 | `1f1990af1de9131fcdf02dd87c24e6f221c30492917c9cebd3474f858793c862` | `jq -c . hooks/hooks.json \| sha256sum` |
| Sibling script | `hooks/unreal-context.sh`, 3101 B, blob `8c06ba2493a504067a875f5ec50e0095aee56ff6`, sha256 `d3f1c871…51fdd` | `sha256sum hooks/unreal-context.sh` |

Toolchain: `jq-1.8.2` (`jq --version`), `bash 5.3.15(1)-release`, `shellcheck 0.11.0`.
Harness under test: **Claude Code 2.1.302** — `claude --version` → `2.1.302 (Claude Code)`;
`/usr/bin/claude` is a POSIX shim to `/opt/claude-code/bin/claude`.

> Scope note: the loader evidence below is for **Claude Code 2.1.302 on this host**. It is real
> runtime evidence, but it is *Claude Code's* runtime, not Kimi Code's. Whether Kimi Code honours
> `hooks/hooks.json` at all is a separate, still-open question — see §9.

## 1. `jq` validation

```
$ jq -e . hooks/hooks.json
exit 0
```

`jq -e` exits 0 only for a successfully parsed non-`false`/non-`null` document, so the file is
**valid JSON**. Type assertions, all evaluated together:

```
$ jq -e '(.hooks|type)=="object"
         and (.hooks.SessionStart|type)=="array"
         and (.hooks.SessionStart[0].hooks[0].type=="command")
         and (.hooks.SessionStart[0].hooks[0].timeout==5)' hooks/hooks.json
ALL_ASSERTIONS_TRUE   (exit 0)
```

`.timeout | type` → `number`. Top-level keys are exactly `description` (string) and `hooks` (object):

```
$ jq -r 'keys[]' hooks/hooks.json
description
hooks
```

## 2. Every hook event and its command

The file declares **exactly one event**:

```
$ jq -r '.hooks | keys[]' hooks/hooks.json
SessionStart

$ jq -r '.hooks | length' hooks/hooks.json
1
```

Full enumeration, one line per event → matcher → handler:

```
$ jq -r '.hooks | to_entries[] | .key as $ev | .value[] |
         "\($ev) | matcher=\(.matcher // "-") | hooks=\(.hooks|length) | " +
         ([.hooks[] | "type=\(.type) timeout=\(.timeout // "none") cmd=\(.command)"] | join("; "))' hooks/hooks.json
SessionStart | matcher=startup|resume|clear | hooks=1 | type=command timeout=5 cmd=bash ${CLAUDE_PLUGIN_ROOT}/hooks/unreal-context.sh
```

Complete inventory — there is nothing else in the file:

| Event | Matcher | Handler `type` | `timeout` | Command |
|---|---|---|---|---|
| `SessionStart` | `startup\|resume\|clear` | `command` | `5` (seconds) | `bash ${CLAUDE_PLUGIN_ROOT}/hooks/unreal-context.sh` |

`timeout` is in seconds: the bundle documents the field as
`"Seconds to wait for the command before giving up (default: 60)"`, and a 20-second hook with
`timeout: 5` was cancelled at **5.698 s wall** (§7). So the declared 5 s budget is real, and the
hook's measured ~1.5 ms runtime leaves ~3300× headroom.

There is **no** `PreToolUse`, `PostToolUse`, `UserPromptSubmit`, `Stop`, `SessionEnd`, or
`PreCompact` entry. The full set of event names Claude Code 2.1.302 knows about is much larger —
extracted from the bundle, these all appear as recognised hook events:
`ConfigChange, Elicitation, ElicitationResult, Notification, PermissionRequest, PostToolBatch,
PostToolUse, PreCompact, PreModelSwitch, PreToolUse, SessionEnd, SessionStart, Setup, Stop,
SubagentStop, TaskCreated, UserPromptExpansion, UserPromptSubmit, WorktreeCreate, WorktreeRemove`.
This plugin registers **1 of ~20**. The plugin's blast radius is therefore a single
`SessionStart` context injection; it registers no gating hook (`gatingHooks: []` in the
validator's JSON report, §3).

## 3. Authoritative validation — `claude plugin validate`

This is the strongest static evidence available: Anthropic's own validator, which parses the file
with the same schema the loader uses. It found **zero errors** and **one warning**:

```
$ claude plugin validate /tmp/ue-skills-ref
Validating plugin manifest: /tmp/ue-skills-ref/.claude-plugin/plugin.json
⚠ Found 1 warning:
  ❯ name: Plugin name "unreal-engine-skills-for-claude-code" reads as one of Anthropic's own. …
Validating hooks: /tmp/ue-skills-ref/hooks/hooks.json
⚠ Found 1 warning:
  ❯ hooks.SessionStart: Shell command uses ${CLAUDE_PLUGIN_ROOT} without quotes: bash ${CLAUDE_PLUGIN_ROOT}/hooks/unreal-context.sh. If the expanded path contains a space the command can split into several words and fail. Wrap the placeholder in double quotes, or use exec form: {"command": "<executable>", "args": ["${CLAUDE_PLUGIN_ROOT}/..."]}.
✔ Validation passed with warnings
exit 0
```

Exit codes: default `0`; `--strict` (warnings → errors) `1`. Machine-readable form:

```
$ claude plugin validate /tmp/ue-skills-ref --json | jq -c '{errors: ([.contents[].errors[]?]|length), warnings: [.contents[].warnings[].message]}'
{"errors":0,"warnings":["Shell command uses ${CLAUDE_PLUGIN_ROOT} without quotes: …"]}
```

The `hooks.json` content entry carries `"type":"hooks"`, `"errors":[]`, `"gatingHooks":[]`, and the
single warning above. Note the validator *does* parse and specifically recognise
`hooks.SessionStart` — the warning's `path` is `hooks.SessionStart`, so the event name and the
handler are schema-valid.

## 4. `SessionStart` wiring — confirmed by real execution

Static validation proves the schema. To prove the *wiring* (that the harness actually discovers,
spawns, and consumes this hook), the plugin was loaded through the real loader against a local mock
Anthropic endpoint, with `--include-hook-events`:

```
$ cd /tmp/r101work/seat17/projA   # a synthetic UE project: MyGame.uproject + .mcp.json
$ ANTHROPIC_BASE_URL=http://127.0.0.1:8899 ANTHROPIC_API_KEY=sk-ant-dummy \
  claude --plugin-dir /tmp/ue-skills-ref --verbose --debug hooks --include-hook-events \
         --output-format stream-json -p "reply with the single word OK"
```

Observed lifecycle events (verbatim, truncated to the fields that matter):

```json
{"subtype":"hook_started","hook_name":"SessionStart:startup","hook_event":"SessionStart", …}
{"subtype":"hook_response","hook_name":"SessionStart:startup",
 "output":"{\"hookSpecificOutput\":{\"hookEventName\":\"SessionStart\",\"additionalContext\":\"This working directory is an Unreal Engine project. The project is `MyGame.uproject`. … An `.mcp.json` is already present at the project root.\"}}\n",
 "stdout":"…same…", "stderr":"", "exit_code":0, "outcome":"success", …}
```

So the loader: matched the event, ran the command, captured the script's stdout, and recorded
`exit_code: 0` / `outcome: "success"`. The plugin also appears in the session `init` line:

```json
{"type":"system","subtype":"init", "plugins":[{"name":"unreal-engine-skills-for-claude-code","path":"/tmp/ue-skills-ref","source":"unreal-engine-skills-for-claude-code@inline","version":"3.1.1"}, …], "slash_commands":["unreal-engine-skills-for-claude-code:create-toolset","unreal-engine-skills-for-claude-code:unreal-mcp","unreal-engine-skills-for-claude-code:unreal-skill", …]}
```

**All three matcher branches fire**, each with a distinct `source` value in the hook's stdin
(captured by swapping in an instrumented script, §5):

| Trigger | Observed `hook_name` | Observed stdin `source` |
|---|---|---|
| plain `-p` run | `SessionStart:startup` | `"startup"` |
| `--resume <session-id>` | `SessionStart:resume` | `"resume"` |
| `-p "/clear"` | `SessionStart:clear` | `"clear"` |

All three returned `exit_code: 0`, `outcome: "success"`. The matcher string is interpreted as an
alternation regex — `python3 -c 're.compile("startup|resume|clear").search(...)'` matches
`startup`, `resume`, `clear` and does not match `compact`, `logout`, or the empty string.

### 4.1 The injected context really reaches the model

The mock endpoint logged the outgoing request bodies. Searching every request for the injection
marker shows it landing in the conversation, prefixed by the harness:

```
$ python3 … # walk the logged request bodies for "SessionStart hook additional context"
===== POSITIVE(projA)
  req0 PATH=.messages[1].content[0].text
    SessionStart hook additional context: This working directory is an Unreal Engine project. The project is `MyGame.uproject`. …
  req1 PATH=.messages[1].content[0].text
    SessionStart hook additional context: This working directory is an Unreal Engine project. …
  total hook-injection hits: 2
```

Note it lands in `.messages[1].content[0].text`, **not** in `.system` — the injected text is
prepended as a user-role message, and the harness adds the `SessionStart hook additional context: `
label itself (that prefix is not in the script's output). The request's `.system` is a 3-block
array with no Unreal text.

### 4.2 Negative control — the detector is real

Repeating the identical run in `/tmp/r101work/seat17/plain` (a directory with **no** Unreal
marker anywhere up the tree):

```
STARTED SessionStart:startup
RESPONSE name=SessionStart:startup exit=0 outcome=success stdout=''
```

The hook still fires and still exits 0, but emits **empty stdout**, and:

```
===== NEGATIVE(plain dir)
  total hook-injection hits: 0
```

Zero injection reaches the request. This confirms both that the script's project detection is
genuine (not unconditional) and that the §4.1 hits are caused by the hook rather than by some
constant harness preamble.

## 5. `${CLAUDE_PLUGIN_ROOT}` expansion — mechanism and runtime contract

### 5.1 It is a plain string substitution, not shell expansion

From the bundle (`/opt/claude-code/bin/claude`), the substitution function is:

```js
function tie(e,r){let n=(s)=>s,
  i=e.replace(/\$\{CLAUDE_PLUGIN_ROOT\}/g,()=>n(r.path));
  if(i=i.replace(/\$\{CLAUDE_PROJECT_DIR\}/g,()=>n(to()??Qr())),r.source){…
    i=i.replace(/\$\{CLAUDE_PLUGIN_DATA\}/g,()=>{…})}
  return i}
```

`String.prototype.replace` with a **function** replacement: the replacement text is inserted
literally and `$`-sequences in it are *not* re-expanded. `${CLAUDE_PLUGIN_ROOT}` is replaced
verbatim with the plugin's path; `${CLAUDE_PROJECT_DIR}` and `${CLAUDE_PLUGIN_DATA}` are handled
the same way. The schema documentation in the bundle confirms the intent:
*"Path placeholders like `${CLAUDE_PLUGIN_ROOT}` are substituted per-element as plain strings, so
paths with quotes, `$`, or backticks never reach a shell parser"* — that guarantee is documented for
**exec form** (`args`), which is exactly why exec form is the safe recommendation.

### 5.2 The runtime contract, captured from inside the hook

An instrumented copy of the script (dumping its environment and stdin) was loaded through the real
loader. Observed:

```
=== argv0=/tmp/r101work/seat17/sp3/hooks/unreal-context.sh
=== cwd=/tmp/r101work/seat17/projA
=== CLAUDE_PLUGIN_ROOT=/tmp/r101work/seat17/sp3
=== env keys ===
CLAUDECODE=1
CLAUDE_CODE_CHILD_SESSION=1
CLAUDE_CODE_ENTRYPOINT=sdk-cli
CLAUDE_CODE_MESSAGING_SOCKET=/run/user/1000/cc-socks/289987.sock
CLAUDE_CODE_MESSAGING_TOKEN=…            (redacted here)
CLAUDE_CODE_SESSION_ATTENDED=0
CLAUDE_CODE_SESSION_ID=072af9df-36bc-43f2-9987-c1b7225d2e9e
CLAUDE_ENV_FILE=/home/vgpnk/.claude/session-env/072af9df-…/sessionstart-hook-0.sh
CLAUDE_PID=289987
CLAUDE_PLUGIN_DATA=/home/vgpnk/.claude/plugins/data/unreal-engine-skills-for-claude-code-inline
CLAUDE_PLUGIN_ROOT=/tmp/r101work/seat17/sp3
CLAUDE_PROJECT_DIR=/tmp/r101work/seat17/projA
=== stdin (raw) ===
{"session_id":"072af9df-36bc-43f2-9987-c1b7225d2e9e","transcript_path":"/home/vgpnk/.claude/projects/-tmp-r101work-seat17-projA/072af9df-….jsonl","cwd":"/tmp/r101work/seat17/projA","hook_event_name":"SessionStart","source":"startup"}
```

Three findings that materially update the static picture:

1. **`CLAUDE_PLUGIN_ROOT` is exported as a real environment variable** *and* substituted into the
   command string. So the hook works by either route. Confirmed independently: running the command
   with the variable unset fails, with it set it succeeds (§5.3).
2. **The hook receives a JSON payload on stdin** —
   `{"session_id", "transcript_path", "cwd", "hook_event_name", "source"}`. `unreal-context.sh`
   **ignores stdin entirely**; it never reads `cwd` from the payload and instead walks up from
   `$PWD`. That is correct here (the loader sets `cwd` to the project dir anyway) but it means the
   script is coupled to `$PWD` rather than to the documented interface. If a harness ever spawned
   hooks with a different working directory, the payload's `cwd` — the contractually correct source
   — would be silently unused and the hook would mis-detect.
3. `cwd` is the session's project directory, not the plugin directory: the payload's `cwd` and
   `CLAUDE_PROJECT_DIR` both read `/tmp/r101work/seat17/projA`. The script's reliance on `$PWD` is
   therefore sound *under this loader*.

### 5.3 Set vs unset

```
$ cd projA && CLAUDE_PLUGIN_ROOT=/tmp/ue-skills-ref bash -c 'bash ${CLAUDE_PLUGIN_ROOT}/hooks/unreal-context.sh'
{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"This working directory is an Unreal Engine project. …"}}
exit=0

$ cd projA && env -u CLAUDE_PLUGIN_ROOT bash -c 'bash ${CLAUDE_PLUGIN_ROOT}/hooks/unreal-context.sh'
bash: /hooks/unreal-context.sh: No such file or directory
exit=127
```

With the variable unset the command degenerates to `/hooks/unreal-context.sh` and dies with 127.
In the real loader the variable is always set, so this is a robustness note, not a live defect.

### 5.4 The unquoted-path defect is real, not cosmetic

The validator's warning predicts a concrete failure. It reproduces, both in a shell and through the
real loader. A plugin installed at a path containing a space (e.g. a user profile directory, a
mounted volume, or a plugin zip extracted under a name with a space):

```
$ # plugin at "/tmp/r101work/seat17/plug in root", hooks.json verbatim
$ CLAUDE_PLUGIN_ROOT="$SP" bash -c 'bash ${CLAUDE_PLUGIN_ROOT}/hooks/unreal-context.sh'
exit=127                                   # bash tried to run "/tmp/r101work/seat17/plug"

$ CLAUDE_PLUGIN_ROOT="$SP" bash -c 'bash "${CLAUDE_PLUGIN_ROOT}/hooks/unreal-context.sh"'
{"hookSpecificOutput":{…}}                 # exit=0, correct output
```

Through the real loader, the failure is **silent** — the session starts normally, and only the
hook-response event reveals it:

```json
{"subtype":"hook_response","hook_name":"SessionStart:startup",
 "output":"bash: /tmp/r101work/seat17/plug: No such file or directory\n",
 "stdout":"", "stderr":"bash: /tmp/r101work/seat17/plug: No such file or directory\n",
 "exit_code":127, "outcome":"error"}
```

and consequently `requests with hook injection: 0` — the project-context note never arrives, with
no user-visible error. Severity is bounded (the skills still work; only the context note is lost,
as `README.md` §Platform Support also concedes for the Windows case) but the failure mode is
*silent*, which is the part worth recording.

### 5.5 Fixes verified

Both fixes the validator suggests were applied to copies and run through the real loader with a
space in the plugin path:

| Fix | `hooks.json` handler | Loader result | Validator |
|---|---|---|---|
| A: quote the placeholder | `"command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/unreal-context.sh\""` | `"output":"RAN_QUOTED\n"` — works | errors 0, warnings **[]** |
| B: exec form | `"command": "bash", "args": ["${CLAUDE_PLUGIN_ROOT}/hooks/unreal-context.sh"]` | `"output":"RAN_EXECFORM\n"` — works | errors 0, warnings **[]** |
| (baseline, unpatched) | — | 127, no output | errors 0, warnings `["Shell command uses ${CLAUDE_PLUGIN_ROOT} without quotes…"]` |

Both clear the warning entirely. **Recommended upstream fix: exec form** — it also satisfies the
bundle's own documented guarantee that placeholders "never reach a shell parser", so it stays
correct for paths containing `$`, backticks, or quotes as well as spaces.

### 5.6 Security probe — the substitution is not a command-injection sink

Because substitution is a literal string replace followed by shell-form execution, the obvious
worry is that a hostile plugin *path* could inject shell syntax. Tested through the real loader
with the path itself carrying metacharacters:

| Plugin path contains | Command executed | Hook `output` | Payload executed? |
|---|---|---|---|
| a space (`…/sp ace`) | unquoted, verbatim | `bash: …/sp: No such file or directory`, exit 127 | no |
| `;echo B_SEMI_RAN;` | unquoted, verbatim | `bash: …/semi;echo: No such file or directory`, exit 127 | **no** — `B_SEMI_RAN` never printed |
| `$(touch …/PWNED)` | unquoted, verbatim | `bash: …/p$(touch: No such file or directory`, exit 127 | **no** — `PWNED` not created |
| `` `touch …/PWNED2` `` | unquoted, verbatim | `bash: …/bt\`touch: No such file or directory`, exit 127 | **no** — `PWNED2` not created |
| `$HOME` | unquoted, verbatim | script ran; `$0` printed literally `/…/d$HOME/hooks/unreal-context.sh` | n/a — **not** expanded |

```
$ ls -la /tmp/r101work/seat17/PWNED /tmp/r101work/seat17/PWNED2
ls: cannot access '…/PWNED': No such file or directory
ls: cannot access '…/PWNED2': No such file or directory
```

**Result: no command injection via the substituted path.** The reason is that the replacement
value is inserted *inside a single word* of the command (directly after `bash `), so shell word
splitting plus the `/hooks/…` suffix truncates the word at the first metacharacter — the whole
construct is consumed as a path fragment, and `bash` then fails to find it. The `$HOME` case is the
decisive one: a literal `$HOME` in the path was **not** expanded, confirming the replacement text
is inserted verbatim (consistent with §5.1's function-replacement semantics).

Separately, and importantly, **the command string itself is shell-form and is genuinely
shell-parsed**. Feeding metacharacters through the `command` field (not the path) shows they are
honoured:

```
command="bash ${CLAUDE_PLUGIN_ROOT}/hooks/unreal-context.sh; echo SHELL_METACHAR_RAN"
  → "output":"SCRIPT_RAN argc=0 args=\nSHELL_METACHAR_RAN\n"     # `;` honoured

…unreal-context.sh $HOME       → ARGV[0]=/home/vgpnk            # variable expansion honoured
…unreal-context.sh *.md        → ARGV[0]=*.md                   # glob NOT expanded (no match)
…unreal-context.sh "a b" c     → ARGC=2  ARGV[0]="a b" ARGV[1]="c"  # quoting honoured
…unreal-context.sh `echo SUBST`  → ARGV[0]=SUBST                # backticks honoured
…unreal-context.sh $(echo SUBST2) → ARGV[0]=SUBST2              # $( ) honoured
```

So shell form runs a shell — as designed. The security-relevant conclusion is narrower and worth
stating precisely: **the substituted plugin path is inert, but a plugin author's `command` string
is arbitrary shell by construction.** For this plugin that is benign (the string is a static
literal in a repo pinned at a known SHA), but it is the correct reason to prefer exec form when
auditing third-party plugins: exec form removes the shell from the path entirely.

## 6. Behavioural matrix (script invoked directly, 5 fixtures)

All fixtures under `/tmp/r101work/seat17/`. Command in every case:
`cd <fixture> && bash /tmp/ue-skills-ref/hooks/unreal-context.sh`.

| # | Fixture | Layout | Resulting `additionalContext` | stdout B | exit |
|---|---|---|---|---|---|
| A | `projA` | `MyGame.uproject` + `.mcp.json` at root | project named, `.mcp.json` present | 405 | 0 |
| A2 | `projA/Source/MyGame/Private` | same, invoked from a nested subdir | identical to A — walk-up works | 405 | 0 |
| B | `projB` | `ProjB.uproject`, **no** `.mcp.json` | project named, "No `.mcp.json` is present … Run `ModelContextProtocol.GenerateClientConfig ClaudeCode`" | 498 | 0 |
| C | `engtree/Engine/Source/Runtime/Engine` | `GenerateProjectFiles.sh` at root, `Engine/` present | "It is an Engine source tree." | 494 | 0 |
| D | `plain` | no marker anywhere | **empty stdout** | 0 | 0 |

Every non-empty output parses as JSON and is schema-shaped:

```
$ cd projA && bash …/unreal-context.sh | jq -e .
{ "hookSpecificOutput": { "hookEventName": "SessionStart", "additionalContext": "…" } }
JSON_OK exit=0

$ … | jq -r '{keys: (keys|join(",")), ev: .hookSpecificOutput.hookEventName, ctxlen: (.hookSpecificOutput.additionalContext|length)}'
{ "keys": "hookSpecificOutput", "ev": "SessionStart", "ctxlen": 326 }
```

The object has exactly one key, `hookSpecificOutput`, and `hookEventName` is `"SessionStart"` —
matching the harness's expected response shape (the bundle's schema for this event is
`{hookEventName:"SessionStart", additionalContext?, initialUserMessage?, sessionTitle?, watchPaths?}`,
so `additionalContext` is a valid field and the shape is exactly right).

### 6.1 Edge cases exercised

| Case | Setup | Result |
|---|---|---|
| `.uproject` via symlink | `Link.uproject → target/Real.uproject` | detected: "The project is `Link.uproject`" — `[ -e ]` follows symlinks |
| `Engine/` must not be a marker | game project with `Engine/Source/Runtime/Engine`, root has `Game.uproject` | walked past the nested `Engine` to the real root, then reported "It is an Engine source tree." (root has an `Engine/` dir) — the comment's documented pitfall is genuinely avoided |
| `.mcp.json` only in a subdir | `Source/Sub/.mcp.json`, none at root | correctly reports *absent* — root-scoped check, not a recursive search |
| walk-up termination at `/` | run from `/` and from `/tmp` | exit 0, no output, no hang (`timeout 10` not hit) |
| JSON escaping | dir/name containing `"` and `\` | `"The project is `Pro\"j\\ect.uproject`."` — escaped, and `jq -e .` parses it (`JSON_OK`). A `we"ird` directory and a `back\slash` directory both parse. |
| `CLAUDE_UE_HOOK_DEBUG` | `CLAUDE_UE_HOOK_DEBUG=1` | `unreal-context.sh: project root: /tmp/r101work/seat17/projA (type=game, uproject=MyGame.uproject, mcp_json=true)` on **stderr** only; stdout unchanged |

### 6.2 Performance

20 consecutive invocations, measured in-process:

```
n=20  min=1.31ms  median=1.46ms  max=2.14ms
```

Against the declared `timeout: 5` (seconds) this is ~3300× headroom, so the hook will never
time out on this host. For contrast, a deliberately slow 20-second hook under `timeout: 5` was
cancelled by the loader at **5.698 s** with `exit_code: 1`, `outcome: "cancelled"` — confirming the
timeout is enforced, and that enforcement is non-fatal to the session.

`shellcheck 0.11.0` is clean on the sibling script (`exit=0`), and `bash -n` is clean (`exit=0`).
Static script quality is covered in depth by the sibling probe `probes/hook-shellcheck.md`
(SEAT-18); this seat does not duplicate it.

## 7. Verdict and calibration

| Claim | Verdict | Basis |
|---|---|---|
| `hooks/hooks.json` is valid JSON | **verified-here** | `jq -e .` exit 0 |
| Exactly one event, `SessionStart`, matcher `startup\|resume\|clear`, one command handler, `timeout: 5` | **verified-here** | `jq` enumeration §2 |
| Schema accepted by the harness | **verified-here** | `claude plugin validate` → 0 errors; `--json` report has `errors: []`, `gatingHooks: []` |
| Hook is discovered, spawned, and its stdout consumed | **verified-here** | real loader run, `hook_started` → `hook_response` `exit_code: 0` |
| Injected context reaches the model request | **verified-here** | mock endpoint logged it at `.messages[1].content[0].text`, 2/2 requests; negative control 0/2 |
| All three matcher branches fire | **verified-here** | `SessionStart:startup`, `:resume`, `:clear` all observed with matching stdin `source` |
| `${CLAUDE_PLUGIN_ROOT}` expands | **verified-here** | literal-replace function extracted from bundle; env var observed set inside the hook; unset → 127 |
| Unquoted placeholder is a real defect | **verified-here** | 127 through the real loader with a space in the path; both suggested fixes verified working |
| Path substitution is not a shell-injection sink | **verified-here** | 4 hostile-path probes; no payload executed; `$HOME` not expanded |
| Kimi Code honours `hooks/hooks.json` | **unproven-runtime** | No Kimi Code plugin-hook loader was exercised; see §9 |

Everything asserted here was produced by a command in this report. The one runtime dimension that
is *not* verified — and must not be asserted — is any live-Unreal-Editor behaviour: no MCP server
was contacted, and per host receipts Unreal Editor is not installed on this machine. The hook
touches only the filesystem (`$PWD` walk-up + a `.mcp.json` stat) and never reaches the editor, so
its verdict is independent of that blocker — but the `unreal-mcp` *skill* it advertises remains
unproven-runtime, exactly as the round's C2 cards state.

## 8. Defects and follow-ups for the lane

1. **F1 (low, real, silent) — unquoted `${CLAUDE_PLUGIN_ROOT}` in `hooks/hooks.json:10`.**
   Confirmed by the vendor's own validator and reproduced end-to-end as a silent 127 (§5.4). Fix:
   exec form `{"command":"bash","args":["${CLAUDE_PLUGIN_ROOT}/hooks/unreal-context.sh"]}`,
   verified to validate clean and run correctly (§5.5). Candidate C2 card line item.
2. **F2 (informational) — the hook ignores its stdin contract.** It derives context from `$PWD`
   rather than the payload's `cwd` (§5.2). Correct under this loader; a portability hazard for any
   other harness. Worth a line in the adaptation table: a Kimi-side reimplementation should read
   `cwd` from stdin.
3. **F3 (informational) — validator name warning** on `.claude-plugin/plugin.json`
   ("reads as one of Anthropic's own"). Not a defect; noted because `--strict` fails on it, so any
   CI that runs `claude plugin validate --strict` against this repo will exit 1 for reasons
   unrelated to correctness.
4. **Coverage note for the round:** `hooks.json` registers 1 of ~20 events the harness supports
   (§2). The plugin's runtime surface is therefore *narrow* — one context injection, no gating
   hooks. Any coverage model that scores "hook events" as a fraction of the total should record
   this as a deliberate design choice by upstream, not as missing content to be vendored.

## 9. Reproduce

```bash
# identity
git -C /tmp/ue-skills-ref rev-parse HEAD          # a6aa73ada02a9fb1f5415bec491f9942c519b297
sha256sum /tmp/ue-skills-ref/hooks/hooks.json     # 259124f0…3b5ebdc0c

# static
jq -e . /tmp/ue-skills-ref/hooks/hooks.json
jq -r '.hooks | keys[]' /tmp/ue-skills-ref/hooks/hooks.json
claude plugin validate /tmp/ue-skills-ref          # exit 0, 1 hooks warning
claude plugin validate /tmp/ue-skills-ref --strict # exit 1

# runtime (mock endpoint needed so no real API call is made)
python3 /tmp/r101work/seat17/mock/server2.py &     # REQLOG=… PORT=8911
cd /tmp/r101work/seat17/projA
ANTHROPIC_BASE_URL=http://127.0.0.1:8911 ANTHROPIC_API_KEY=sk-ant-dummy \
  claude --plugin-dir /tmp/ue-skills-ref --verbose --include-hook-events \
         --output-format stream-json -p "say OK" | grep hook_response
```

All fixture directories, the mock server (`mock/server2.py`), and the captured logs live under
`/tmp/r101work/seat17/` and are ephemeral scratch, not lane artifacts.
