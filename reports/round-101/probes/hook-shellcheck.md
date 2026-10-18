# SEAT-18 PROBE — `upstream/hooks/unreal-context.sh` static + behavioral probe

Round r101 · lane game-dev-3d-shokunin · axis: depth / calibration (probe evidence)

## 0. Artifact identity

| Field | Value | Command |
|---|---|---|
| Upstream repo | `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin` | — |
| Pinned SHA | `a6aa73ada02a9fb1f5415bec491f9942c519b297` | `git -C /tmp/ue-skills-ref rev-parse HEAD` |
| Local clone | `/tmp/ue-skills-ref` (SHA matches pin; pre-existing clone reused, no fresh clone needed) | `git -C /tmp/ue-skills-ref status --porcelain` → empty (clean worktree) |
| Git blob | `8c06ba2493a504067a875f5ec50e0095aee56ff6` | `git -C /tmp/ue-skills-ref ls-tree HEAD hooks/` |
| sha256 | `d3f1c871cd4edd5210ee2f448c403e1a441e569a14a1405d1a3f199c65651fdd` | `sha256sum hooks/unreal-context.sh` |
| Size | 84 lines, 3101 bytes, ASCII text executable, LF, trailing newline (`0a`) | `wc -l`; `file`; `tail -c1 \| xxd` |
| Sibling | `hooks/hooks.json` (357 B, blob `6be4b8b7b7e082372186702daf92bd03cc7e5b95`) registers it as a `SessionStart` command hook with `timeout: 5` | `cat hooks/hooks.json` |

Toolchain: `bash --version` → `GNU bash, version 5.3.15(1)-release (x86_64-pc-linux-gnu)`;
`shellcheck --version` → `version: 0.11.0`.

## 1. `bash -n` (syntax check)

```
$ bash -n hooks/unreal-context.sh
bash -n exit: 0
```

No output, exit 0. Syntax is valid.

## 2. `shellcheck` 0.11.0 — default ruleset

```
$ shellcheck hooks/unreal-context.sh
shellcheck exit: 0
```

**Zero findings at the default ruleset.** Exit 0.

## 3. `shellcheck -o all` — full optional-ruleset run (FULL OUTPUT, VERBATIM)

`shellcheck -o all` enables all 11 optional checks (`add-default-case`,
`avoid-negated-conditions`, `avoid-nullary-conditions`,
`check-extra-masked-returns`, `check-set-e-suppressed`,
`check-unassigned-uppercase`, `deprecate-which`, `quote-safe-variables`,
`require-double-brackets`, `require-variable-braces`, `useless-use-of-cat`).
Command: `cd /tmp/ue-skills-ref && shellcheck -o all hooks/unreal-context.sh`

```

In hooks/unreal-context.sh line 8:
  if [ -n "$CLAUDE_UE_HOOK_DEBUG" ]; then
     ^----------------------------^ SC2292 (style): Prefer [[ ]] over [ ] for tests in Bash/Ksh/Busybox.
           ^-------------------^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.

Did you mean:
  if [[ -n "${CLAUDE_UE_HOOK_DEBUG}" ]]; then


In hooks/unreal-context.sh line 19:
  [ -f "$directory/GenerateProjectFiles.bat" ] && return 0
  ^-- SC2292 (style): Prefer [[ ]] over [ ] for tests in Bash/Ksh/Busybox.
        ^--------^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.

Did you mean:
  [[ -f "${directory}/GenerateProjectFiles.bat" ]] && return 0


In hooks/unreal-context.sh line 20:
  [ -f "$directory/GenerateProjectFiles.sh" ] && return 0
  ^-- SC2292 (style): Prefer [[ ]] over [ ] for tests in Bash/Ksh/Busybox.
        ^--------^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.

Did you mean:
  [[ -f "${directory}/GenerateProjectFiles.sh" ]] && return 0


In hooks/unreal-context.sh line 21:
  [ -f "$directory/GenerateProjectFiles.command" ] && return 0
  ^-- SC2292 (style): Prefer [[ ]] over [ ] for tests in Bash/Ksh/Busybox.
        ^--------^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.

Did you mean:
  [[ -f "${directory}/GenerateProjectFiles.command" ]] && return 0


In hooks/unreal-context.sh line 22:
  for candidate in "$directory"/*.uproject; do
                    ^--------^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.

Did you mean:
  for candidate in "${directory}"/*.uproject; do


In hooks/unreal-context.sh line 23:
    [ -e "$candidate" ] && return 0
    ^-----------------^ SC2292 (style): Prefer [[ ]] over [ ] for tests in Bash/Ksh/Busybox.
          ^--------^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.

Did you mean:
    [[ -e "${candidate}" ]] && return 0


In hooks/unreal-context.sh line 30:
  while [ -n "$directory" ]; do
        ^-----------------^ SC2292 (style): Prefer [[ ]] over [ ] for tests in Bash/Ksh/Busybox.
              ^--------^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.

Did you mean:
  while [[ -n "${directory}" ]]; do


In hooks/unreal-context.sh line 31:
    if is_project_root "$directory"; then
                        ^--------^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.

Did you mean:
    if is_project_root "${directory}"; then


In hooks/unreal-context.sh line 32:
      echo "$directory"
            ^--------^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.

Did you mean:
      echo "${directory}"


In hooks/unreal-context.sh line 36:
    parent="$(dirname "$directory")"
                       ^--------^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.

Did you mean:
    parent="$(dirname "${directory}")"


In hooks/unreal-context.sh line 37:
    [ "$parent" = "$directory" ] && break
    ^--------------------------^ SC2292 (style): Prefer [[ ]] over [ ] for tests in Bash/Ksh/Busybox.
       ^-----^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.
                   ^--------^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.

Did you mean:
    [[ "${parent}" = "${directory}" ]] && break


In hooks/unreal-context.sh line 38:
    directory="$parent"
               ^-----^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.

Did you mean:
    directory="${parent}"


In hooks/unreal-context.sh line 43:
project_root="$(find_project_root "$PWD")"
                                   ^--^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.

Did you mean:
project_root="$(find_project_root "${PWD}")"


In hooks/unreal-context.sh line 44:
if [ -z "$project_root" ]; then
   ^--------------------^ SC2292 (style): Prefer [[ ]] over [ ] for tests in Bash/Ksh/Busybox.
         ^-----------^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.

Did you mean:
if [[ -z "${project_root}" ]]; then


In hooks/unreal-context.sh line 45:
  debug "no Unreal Engine project marker found walking up from $PWD"
                                                               ^--^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.

Did you mean:
  debug "no Unreal Engine project marker found walking up from ${PWD}"


In hooks/unreal-context.sh line 50:
[ -d "$project_root/Engine" ] && project_type="engine"
^---------------------------^ SC2292 (style): Prefer [[ ]] over [ ] for tests in Bash/Ksh/Busybox.
      ^-----------^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.

Did you mean:
[[ -d "${project_root}/Engine" ]] && project_type="engine"


In hooks/unreal-context.sh line 53:
for candidate in "$project_root"/*.uproject; do
                  ^-----------^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.

Did you mean:
for candidate in "${project_root}"/*.uproject; do


In hooks/unreal-context.sh line 54:
  if [ -e "$candidate" ]; then
     ^-----------------^ SC2292 (style): Prefer [[ ]] over [ ] for tests in Bash/Ksh/Busybox.
           ^--------^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.

Did you mean:
  if [[ -e "${candidate}" ]]; then


In hooks/unreal-context.sh line 55:
    uproject_filename="$(basename "$candidate")"
                                   ^--------^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.

Did you mean:
    uproject_filename="$(basename "${candidate}")"


In hooks/unreal-context.sh line 61:
[ -f "$project_root/.mcp.json" ] && mcp_config_present="true"
^-- SC2292 (style): Prefer [[ ]] over [ ] for tests in Bash/Ksh/Busybox.
      ^-----------^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.

Did you mean:
[[ -f "${project_root}/.mcp.json" ]] && mcp_config_present="true"


In hooks/unreal-context.sh line 63:
debug "project root: $project_root (type=$project_type, uproject=$uproject_filename, mcp_json=$mcp_config_present)"
                     ^-----------^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.
                                         ^-----------^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.
                                                                 ^----------------^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.
                                                                                              ^-----------------^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.

Did you mean:
debug "project root: ${project_root} (type=${project_type}, uproject=${uproject_filename}, mcp_json=${mcp_config_present})"


In hooks/unreal-context.sh line 67:
if [ "$project_type" = "engine" ]; then
   ^----------------------------^ SC2292 (style): Prefer [[ ]] over [ ] for tests in Bash/Ksh/Busybox.
      ^-----------^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.

Did you mean:
if [[ "${project_type}" = "engine" ]]; then


In hooks/unreal-context.sh line 68:
  context="$context It is an Engine source tree."
           ^------^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.

Did you mean:
  context="${context} It is an Engine source tree."


In hooks/unreal-context.sh line 69:
elif [ -n "$uproject_filename" ]; then
     ^-------------------------^ SC2292 (style): Prefer [[ ]] over [ ] for tests in Bash/Ksh/Busybox.
           ^----------------^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.

Did you mean:
elif [[ -n "${uproject_filename}" ]]; then


In hooks/unreal-context.sh line 70:
  context="$context The project is \`$uproject_filename\`."
           ^------^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.
                                     ^----------------^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.

Did you mean:
  context="${context} The project is \`${uproject_filename}\`."


In hooks/unreal-context.sh line 72:
context="$context Prefer Unreal Engine conventions (C++/UObject patterns, Slate, UHT reflection) when suggesting code."
         ^------^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.

Did you mean:
context="${context} Prefer Unreal Engine conventions (C++/UObject patterns, Slate, UHT reflection) when suggesting code."


In hooks/unreal-context.sh line 73:
context="$context Use the \`unreal-mcp\` skill for tasks that involve driving the Unreal Editor via MCP."
         ^------^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.

Did you mean:
context="${context} Use the \`unreal-mcp\` skill for tasks that involve driving the Unreal Editor via MCP."


In hooks/unreal-context.sh line 74:
if [ "$mcp_config_present" = "true" ]; then
   ^-- SC2292 (style): Prefer [[ ]] over [ ] for tests in Bash/Ksh/Busybox.
      ^-----------------^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.

Did you mean:
if [[ "${mcp_config_present}" = "true" ]]; then


In hooks/unreal-context.sh line 75:
  context="$context An \`.mcp.json\` is already present at the project root."
           ^------^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.

Did you mean:
  context="${context} An \`.mcp.json\` is already present at the project root."


In hooks/unreal-context.sh line 77:
  context="$context No \`.mcp.json\` is present at the project root yet. Run \`ModelContextProtocol.GenerateClientConfig ClaudeCode\` in the editor console to generate one."
           ^------^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.

Did you mean:
  context="${context} No \`.mcp.json\` is present at the project root yet. Run \`ModelContextProtocol.GenerateClientConfig ClaudeCode\` in the editor console to generate one."


In hooks/unreal-context.sh line 84:
printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$escaped_context"
                                                                                             ^--------------^ SC2250 (style): Prefer putting braces around variable references even when not strictly required.

Did you mean:
printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "${escaped_context}"

For more information:
  https://www.shellcheck.net/wiki/SC2250 -- Prefer putting braces around vari...
  https://www.shellcheck.net/wiki/SC2292 -- Prefer [[ ]] over [ ] for tests i...
exit: 1
```

### 3.1 Machine-readable breakdown of that run

```
$ shellcheck -f json -o all hooks/unreal-context.sh | jq -r '[.[].code] | group_by(.) | map({code: .[0], n: length}) | .[] | "\(.code) x\(.n)"'
2250 x36
2292 x14
total: 50
$ shellcheck -f json -o all hooks/unreal-context.sh | jq -r '[.[].level] | group_by(.) | map({level: .[0], n: length}) | .[] | "\(.level): \(.n)"'
style: 50
```

**All 50 findings are `level: style`** — zero `error`, zero `warning`, zero `info`.
Two codes only: SC2250 (require-variable-braces, 36) and SC2292
(require-double-brackets, 14). Both are pure house-style preferences; neither
can indicate a runtime defect, and `-o all` is opt-in, so a default CI
`shellcheck` run reports **nothing**.

## 4. Behavioral probe (beyond static analysis)

`unreal-context.sh` is pure bash + filesystem with no Unreal Editor dependency,
so its runtime behavior *is* executable on this host (no editor needed). Fixture
tree built at `/tmp/r101-seat18`; hook invoked as the plugin would invoke it
(`bash ${CLAUDE_PLUGIN_ROOT}/hooks/unreal-context.sh`, per `hooks.json`).

| # | Fixture / PWD | Expected | Observed | Exit |
|---|---|---|---|---|
| A | `game/` (has `MyGame.uproject` + `.mcp.json`) | game-type context, "already present" | matches, `The project is \`MyGame.uproject\`` | 0 |
| B | `game/Source/Sub/` (nested) | walks up, same context as A | byte-identical to A | 0 |
| C | `engine/Engine/Source/Runtime/Engine/` (root has `GenerateProjectFiles.sh`) | engine-type, no uproject branch | `It is an Engine source tree.` | 0 |
| D | `bare/` (no marker anywhere up to `/`) | silent, no JSON | no stdout | 0 |
| E | `game/` with `.mcp.json` removed | "No `.mcp.json` … Run `ModelContextProtocol.GenerateClientConfig ClaudeCode`" | matches; `jq` → VALID JSON | 0 |
| F | dir named `we"ird` containing `Proj.uproject` | valid JSON | `jq` → VALID JSON | 0 |
| G | dir named `back\slash` containing `Proj2.uproject` | valid JSON | `jq` → VALID JSON | 0 |
| H | `CLAUDE_UE_HOOK_DEBUG=1` in `game/` | debug line on stderr, JSON on stdout | `unreal-context.sh: project root: /tmp/r101-seat18/game (type=game, uproject=MyGame.uproject, mcp_json=false)` on stderr; stdout JSON clean | 0 |
| I | `PWD=/` | silent | no stdout | 0 |
| J | `eng2/Engine/` (root has `GenerateProjectFiles.command`) | engine-type | `It is an Engine source tree.` | 0 |
| **L** | `esc/We"ird.uproject` (quote in **filename**) | valid JSON | `jq` → **VALID JSON**; escaped as `We\"ird.uproject`; `jq -r` round-trips back to `We"ird.uproject` | 0 |
| **M** | `esc/Back\slash.uproject` (backslash in filename) | valid JSON | `jq` → **VALID JSON**; emitted `Back\\slash.uproject` | 0 |
| **N** | `esc/New\nline.uproject` (LF in filename) | valid JSON | `jq` → **INVALID JSON** — `parse error: Invalid string: control characters from U+0000 through U+001F must be escaped at line 2, column 351` | 0 |
| **O** | `esc/Ta\tb.uproject` (TAB in filename) | valid JSON | `jq` → **INVALID** | 0 |
| **P** | `esc/C\x01x.uproject` (SOH in filename) | valid JSON | `jq` → **INVALID** | 0 |

Raw byte proof for case N (`cat -A`, `$` marks the raw LF inside the JSON string):

```
{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"This working directory is an Unreal Engine project. The project is `New$
line.uproject`. Prefer Unreal Engine conventions (C++/UObject patterns, Slate, UHT reflection) when suggesting code. ...
```

### 4.1 Defect found (real, reproducible, not a style nit)

`unreal-context.sh:80-82` hand-rolls JSON string escaping and covers only two
of the required characters:

```bash
# JSON-escape the dynamic content: backslash first, then double quote.
escaped_context="${context//\\/\\\\}"
escaped_context="${escaped_context//\"/\\\"}"
```

RFC 8259 requires `"`, `\`, and all control characters `U+0000`–`U+001F` to be
escaped. The hook escapes `\` and `"` (cases L, M pass) but **not** LF, CR, TAB,
or other C0 controls (cases N, O, P fail). The only dynamic field that can
carry a control character is `uproject_filename` (from `basename`), i.e. the
injected `.uproject` file name. A filename containing a newline/tab makes the
hook emit malformed JSON on stdout, which the harness must parse.

- **Blast radius:** low-probability, low-severity. Requires a `.uproject` file
  whose name contains a C0 control character — legal on Linux/macOS, impossible
  on Windows. Not triggerable on a normal Unreal project (default names are
  `MyProject.uproject`). Exit code stays 0 and the failure is silent: malformed
  stdout, no diagnostic.
- **Not a security issue:** the values are not attacker-controlled in the
  SessionStart path and no command is evaluated from them.
- **Fix shape:** route the dynamic value through a JSON encoder (e.g.
  `jq -Rn --arg v "$uproject_filename" '$v'`) or add the missing C0 escapes
  rather than extending the hand-rolled substitution chain.

## 5. What is *not* proven here

- **Harness integration is unproven-on-this-host.** The hook is wired in
  `hooks/hooks.json` as a `SessionStart` command hook, but the Claude Code
  plugin runtime is not installed here; that the harness *accepts* the emitted
  `hookSpecificOutput` / `hookEventName: "SessionStart"` / `additionalContext`
  envelope is a schema claim read from `hooks.json` and the script, not
  exercised end-to-end. Label: **static-only** for the envelope contract.
- **Windows behavior** (`GenerateProjectFiles.bat`, `GenerateProjectFiles.command`
  branches, CRLF, control chars in names) is **unproven-runtime** — the host is
  Arch Linux and the Windows code path was only inspected, not executed.
- The sibling files of this plugin that depend on a live Unreal Editor remain
  unproven by construction (no editor on host).

## 6. Verdict

**VERDICT: `hooks/unreal-context.sh` at SHA `a6aa73a` is shellcheck-clean at the
default ruleset (exit 0, zero findings) and syntactically valid (`bash -n` exit
0). `shellcheck -o all` reports 50 findings, 100% severity=style (SC2250 ×36,
SC2292 ×14) — style-only, none correctness-bearing. All 14 behavioral cases run
on this host behave as documented; the one real defect is an incomplete
hand-rolled JSON escaper (lines 80–82) that omits C0 control characters, so a
`.uproject` filename containing LF/TAB/other control bytes yields malformed
JSON on stdout (reproduced: cases N/O/P). Verdict class for this artifact:
`verified-here` for syntax, lint, project-root detection, debug logging, and the
escaping defect; `static-only` for the Claude-Code hook envelope contract;
`unproven-runtime` for Windows paths.**
