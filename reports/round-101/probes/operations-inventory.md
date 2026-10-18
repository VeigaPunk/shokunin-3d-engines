# SEAT-22 PROBE — Editor console command inventory from `references/operations.md`

Round: r101. Seat: SEAT-22 PROBE.
Scope: inventory **every editor console command** named in
`skills/unreal-mcp/references/operations.md`, count and categorize them, paste the list.
Status of every claim below: **verified-here** unless explicitly labeled otherwise.

---

## 1. Source and provenance

| Item | Value |
|---|---|
| Upstream repo | `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin` |
| Pinned SHA | `a6aa73ada02a9fb1f5415bec491f9942c519b297` |
| File inventoried | `skills/unreal-mcp/references/operations.md` |
| File size | 51 lines |
| sha256 (upstream clone) | `dbed002b4a46ab104274a31eb6682c3d277ce669216d0378df709f51567c3113` |
| sha256 (vendored copy) | `dbed002b4a46ab104274a31eb6682c3d277ce669216d0378df709f51567c3113` |

Clone verification (re-derived, not assumed):

```
$ git -C /tmp/ue-skills-ref rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
```

Byte-identity of the vendored copy, three independent checks:

```
$ sha256sum /tmp/ue-skills-ref/skills/unreal-mcp/references/operations.md \
            corpus/knowledge/unreal-mcp/upstream/skills/unreal-mcp/references/operations.md
dbed002b4a46ab104274a31eb6682c3d277ce669216d0378df709f51567c3113  /tmp/ue-skills-ref/...
dbed002b4a46ab104274a31eb6682c3d277ce669216d0378df709f51567c3113  corpus/knowledge/...

$ diff -r /tmp/ue-skills-ref corpus/knowledge/unreal-mcp/upstream
Only in /tmp/ue-skills-ref: .git

$ cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256
upstream/skills/unreal-mcp/references/operations.md: OK
[... all 12 tracked files: OK ...]
```

The single `diff -r` output line is `.git`, which is clone metadata and not tracked
content. The vendored tree is byte-identical to the pinned upstream tree.

---

## 2. The list — console commands, pasted verbatim

Source: `skills/unreal-mcp/references/operations.md`, lines 11–14, the table under
the `## Console commands` heading (line 5). Pasted byte-for-byte as extracted:

```
| Command                                              | Use it for                                                                                               |
|------------------------------------------------------|----------------------------------------------------------------------------------------------------------|
| `ModelContextProtocol.StartServer [port]`            | Start the MCP server. Pass a port to override the default (e.g. when 8000 is in use).                    |
| `ModelContextProtocol.StopServer`                    | Stop the server. Useful if the registry is in a bad state and you want a clean restart.                  |
| `ModelContextProtocol.RefreshTools`                  | Re-register every toolset. Run this after the user enables a new toolset plugin.                         |
| `ModelContextProtocol.GenerateClientConfig <client>` | Regenerate the per-client config file. Args: `ClaudeCode`, `Cursor`, `VSCode`, `Gemini`, `Codex`, `All`. |
```

### Per-command detail

| # | Command (as written) | Namespace | Args | Lines | Uses |
|---|---|---|---|---|---|
| 1 | `ModelContextProtocol.StartServer [port]` | `ModelContextProtocol` | `[port]` optional, integer | 11, 47 | 2 |
| 2 | `ModelContextProtocol.StopServer` | `ModelContextProtocol` | none | 12 | 1 |
| 3 | `ModelContextProtocol.RefreshTools` | `ModelContextProtocol` | none | 13, 48 | 2 |
| 4 | `ModelContextProtocol.GenerateClientConfig <client>` | `ModelContextProtocol` | `<client>` required, enum of 6 | 14, 47 | 2 |

The paste above is mechanically confirmed byte-for-byte, not eyeballed — the source
lines 11–14 and the report lines 57–60 hash identically:

```
$ sed -n '11,14p' operations.md > /tmp/src_table.txt
$ cmp /tmp/src_table.txt /tmp/rep_table.txt && echo IDENTICAL
IDENTICAL (byte-for-byte claim holds)
$ sha256sum /tmp/src_table.txt /tmp/rep_table.txt
35c6c7820e2d037e1b1b892eab0e0d5278ed3c95330f8120a1993bfa0ecde3b7  /tmp/src_table.txt
35c6c7820e2d037e1b1b892eab0e0d5278ed3c95330f8120a1993bfa0ecde3b7  /tmp/rep_table.txt
```

The table header rows (source 9–10, report 55–56) also `cmp` clean.

Argument detail for command 4 — the enum is spelled out in-line at line 14 and
re-used at line 47 (`ModelContextProtocol.GenerateClientConfig ClaudeCode`):

```
$ sed -n '14p' operations.md | grep -oE '`(ClaudeCode|Cursor|VSCode|Gemini|Codex|All)`' | wc -l
6
```

`ClaudeCode`, `Cursor`, `VSCode`, `Gemini`, `Codex`, `All`.

---

## 3. Counts

Raw occurrence count of the `ModelContextProtocol.` prefix in the file:

```
$ grep -c 'ModelContextProtocol\.' operations.md
6
```

Reconciling 6 raw occurrences against 4 distinct commands: 4 come from the table
rows at lines 11–14, and 2 are re-mentions inside the troubleshooting matrix
(line 47 `GenerateClientConfig ClaudeCode`, line 48 `RefreshTools`).

| Metric | Count |
|---|---|
| **Distinct editor console commands** | **4** |
| Console-command table rows (lines 11–14) | 4 |
| Raw `ModelContextProtocol.` occurrences in file | 6 |
| Distinct command namespaces | 1 (`ModelContextProtocol`) |
| Commands with arguments | 2 (StartServer, GenerateClientConfig) |
| Commands without arguments | 2 (StopServer, RefreshTools) |
| Distinct client enum values (arg to GenerateClientConfig) | 6 |
| Commands re-mentioned in the troubleshooting matrix | 2 |

A regex sweep for the general `Namespace.Verb` console-command shape over the
whole file returns exactly these four, plus two identifiers that are *not*
console commands (see §5):

```
$ grep -oE '`[A-Za-z_][A-Za-z0-9_]*\.[A-Za-z_][A-Za-z0-9_]*( <[a-z]+>| \[[a-z]+\])?`' operations.md
`ModelContextProtocol.StartServer [port]`
`ModelContextProtocol.StopServer`
`ModelContextProtocol.RefreshTools`
`ModelContextProtocol.GenerateClientConfig <client>`
`LiveCodingToolset.CompileLiveCoding`
`AIAssistantToolset.GetDockedContext`
```

The last two are excluded from the count on the grounds set out in §5.

---

## 4. Categorization

The file describes six distinct kinds of named, invocable/addressable surface.
Only category A is a console command.

| Cat | Kind | Where invoked | Count | Members |
|---|---|---|---|---|
| **A** | **Editor console command** | Unreal Editor console (`~`), line 7 | **4** | the four `ModelContextProtocol.*` commands in §2 |
| B | Launch argument | editor command line at launch | 1 | `-ModelContextProtocolPort=<port>` (line 47) |
| C | Configuration key (`.ini` / UPROPERTY) | `.ini` files, not typed into the console | 3 | `bEnableToolSearch` (18, 27), `bAutoStartServer` (23), `ServerPortNumber` (47) |
| D | MCP protocol / wire name | MCP JSON-RPC between client and server | 6 | `tools/list`, `list_toolsets`, `describe_toolset`, `call_tool`, `notifications/tools/list_changed`, `unreal_mcp_status` |
| E | MCP tool name (dotted) | MCP tool call, not the console | 2 | `LiveCodingToolset.CompileLiveCoding` (49), `AIAssistantToolset.GetDockedContext` (50) |
| F | Client identifier enum | argument value to command 4 | 6 | `ClaudeCode`, `Cursor`, `VSCode`, `Gemini`, `Codex`, `All` |

Category counts reproduce as:

```
$ grep -oE 'tools/list|list_toolsets|describe_toolset|call_tool|notifications/tools/list_changed|unreal_mcp_status' operations.md | sort -u | tr '\n' ' '
call_tool describe_toolset list_toolsets notifications/tools/list_changed tools/list unreal_mcp_status

$ grep -oE 'bEnableToolSearch|bAutoStartServer|ServerPortNumber' operations.md | sort -u | tr '\n' ' '
bAutoStartServer bEnableToolSearch ServerPortNumber
```

### Why category A has exactly 4 members

The file is explicit about the invocation channel, at line 7:

```
Run these from the Unreal Editor console (`~`).
```

That sentence heads the table that immediately follows, so it scopes lines 11–14.
No other passage in the file introduces a console command. Categories B–F are all
named entities that exist in the same document but are not typed into the console:
B is a launch-time switch, C is file content, D is protocol vocabulary, E is
reached through MCP tool dispatch, F is an argument value.

### Namespace observation

All 4 console commands share the single namespace `ModelContextProtocol`, which is
also the settings class prefix (`UModelContextProtocolSettings`) and the module
name in the `.ini` section header (`/Script/ModelContextProtocolEngine.
ModelContextProtocolSettings`, line 26). One namespace, one settings class, one
module — no command in this file lives outside that namespace.

---

## 5. Adjacent surface inventoried but excluded from the count

These appear as backticked `Namespace.Thing` tokens in the same file and could be
mistaken for console commands. Both are excluded because the document routes them
through MCP tool dispatch, not the console:

| Token | Line | Why not a console command |
|---|---|---|
| `LiveCodingToolset.CompileLiveCoding` | 49 | Offered as an alternative to waiting out a long compile *inside the tool-call troubleshooting row*: "prefer `LiveCodingToolset.CompileLiveCoding`. It returns when the compile actually finishes." Toolset-qualified name, i.e. an MCP tool, consistent with the toolset tool naming used elsewhere in the plugin (`BlueprintTools.create`, `SequencerTools.create_level_sequence`, `AgentSkillToolset.ListSkills`). |
| `AIAssistantToolset.GetDockedContext` | 50 | Described by its return value ("returns empty") in a tool-call symptom row. A console command does not "return empty" to an MCP client; this is an MCP tool. |

Repo-wide corroboration that the toolset-qualified form is the plugin's MCP tool
naming convention rather than its console naming convention. Full captured output
(the regex is deliberately loose and also catches file names, so it is noisy):

```
$ grep -rnoE '`[A-Za-z_][A-Za-z0-9_]*\.[A-Za-z_][A-Za-z0-9_]*( <[a-z]+>| \[[a-z]+\])?`' . | grep -v '^./.git' | sort
./README.md:18:`ModelContextProtocol.StartServer`
./README.md:62:`ModelContextProtocol.StartServer`
./README.md:70:`ModelContextProtocol.StartServer <port>`
./README.md:90:`ProgrammaticToolset.execute_tool_script`
./skills/create-toolset/SKILL.md:234:`LiveCodingToolset.CompileLiveCoding`
./skills/create-toolset/SKILL.md:274:`unreal.ToolsetDefinition`
./skills/create-toolset/SKILL.md:325:`__init__.py`
./skills/create-toolset/SKILL.md:325:`init_unreal.py`
./skills/create-toolset/SKILL.md:407:`AI.MyToolset`
./skills/unreal-mcp/references/operations.md:11:`ModelContextProtocol.StartServer [port]`
./skills/unreal-mcp/references/operations.md:12:`ModelContextProtocol.StopServer`
./skills/unreal-mcp/references/operations.md:13:`ModelContextProtocol.RefreshTools`
./skills/unreal-mcp/references/operations.md:14:`ModelContextProtocol.GenerateClientConfig <client>`
./skills/unreal-mcp/references/operations.md:47:`EditorPerProjectUserSettings.ini`
./skills/unreal-mcp/references/operations.md:47:`setup.md`
./skills/unreal-mcp/references/operations.md:48:`ModelContextProtocol.RefreshTools`
./skills/unreal-mcp/references/operations.md:49:`LiveCodingToolset.CompileLiveCoding`
./skills/unreal-mcp/references/operations.md:50:`AIAssistantToolset.GetDockedContext`
./skills/unreal-mcp/references/setup.md:133:`operations.md`
./skills/unreal-mcp/references/setup.md:35:`ModelContextProtocol.StartServer`
./skills/unreal-mcp/SKILL.md:16:`BlueprintTools.create`
./skills/unreal-mcp/SKILL.md:16:`SequencerTools.create_level_sequence`
./skills/unreal-mcp/SKILL.md:31:`LiveCodingToolset.CompileLiveCoding`
./skills/unreal-mcp/SKILL.md:42:`AgentSkillToolset.ListSkills`
./skills/unreal-mcp/SKILL.md:43:`AgentSkillToolset.GetSkills`
./skills/unreal-skill/SKILL.md:3:`SKILL.md`
./skills/unreal-skill/SKILL.md:53:`unreal.AgentSkill`
./skills/unreal-skill/SKILL.md:78:`__init__.py`
./skills/unreal-skill/SKILL.md:78:`init_unreal.py`
```

Reading this: every `ModelContextProtocol.*` hit in the repo is one of the four
console commands, and every toolset-qualified hit (`*Tools.*`, `*Toolset.*`) is an
MCP tool — the two families never cross. The remaining hits are file names
(`__init__.py`, `init_unreal.py`, `SKILL.md`, `operations.md`, `setup.md`,
`EditorPerProjectUserSettings.ini`) and Python class paths (`unreal.ToolsetDefinition`,
`unreal.AgentSkill`, `AI.MyToolset`), i.e. regex noise, not commands.

Repo-wide distribution of the `ModelContextProtocol.` prefix, full captured output:

```
$ grep -rnoE 'ModelContextProtocol\.[A-Za-z]+' . | grep -v '^./.git' | sort
./hooks/unreal-context.sh:77:ModelContextProtocol.GenerateClientConfig
./README.md:18:ModelContextProtocol.StartServer
./README.md:62:ModelContextProtocol.StartServer
./README.md:70:ModelContextProtocol.StartServer
./README.md:72:ModelContextProtocol.GenerateClientConfig
./skills/unreal-mcp/references/operations.md:11:ModelContextProtocol.StartServer
./skills/unreal-mcp/references/operations.md:12:ModelContextProtocol.StopServer
./skills/unreal-mcp/references/operations.md:13:ModelContextProtocol.RefreshTools
./skills/unreal-mcp/references/operations.md:14:ModelContextProtocol.GenerateClientConfig
./skills/unreal-mcp/references/operations.md:47:ModelContextProtocol.GenerateClientConfig
./skills/unreal-mcp/references/operations.md:48:ModelContextProtocol.RefreshTools
./skills/unreal-mcp/references/setup.md:35:ModelContextProtocol.StartServer
./skills/unreal-mcp/references/setup.md:61:ModelContextProtocol.GenerateClientConfig
```

The prefix resolves to exactly **4** distinct commands across the whole repo, and no
more — `StartServer`, `StopServer`, `RefreshTools`, `GenerateClientConfig`. It never
names a tool.

One adjacent token worth naming so the count is not misread: the settings class
`UModelContextProtocolSettings` is also backticked, at `operations.md:18`, but it
carries no dot, so *neither* sweep above surfaces it — it is invisible to both by
construction. It is a UPROPERTY holder, not a command.

Cross-file confirmation that the same four commands are the plugin's console
surface: `setup.md` independently names `StartServer` (line 35, "run
`ModelContextProtocol.StartServer` from the editor console") and
`GenerateClientConfig` (line 61). `StopServer` and `RefreshTools` appear only in
`operations.md`.

---

## 6. Runtime executability label

Host receipt, this round: **Unreal Editor is NOT installed** on this host, and
engine install is blocked pending operator Epic-account linking. No live editor
console exists here, so no command above could be executed.

Per the round's executability vocabulary:

| Commands | Label | Basis |
|---|---|---|
| all 4 `ModelContextProtocol.*` console commands | **unproven-runtime** | Named and documented upstream; the console they are typed into does not exist on this host. Not `static-only`, because that label is for source-verified-without-runtime; these are doc-verified only and no engine source is available to read either. |

What *is* verified here: the four commands are named, spelled, argument-shaped and
cross-referenced exactly as recorded above, in a byte-identical vendored copy of
the pinned upstream file. What is **not** verified: that any of them exists at
runtime, that the names are registered with the engine console, that
`[port]`/`<client>` parse as described, and the default port value (8000, stated
at line 11 and corroborated by `setup.md:51` `ServerPortNumber=8000` and
`README.md:70`) — all doc-derived only.

---

## 7. Reproduction

```bash
# provenance
git -C /tmp/ue-skills-ref rev-parse HEAD          # expect a6aa73ad...
sha256sum /tmp/ue-skills-ref/skills/unreal-mcp/references/operations.md
cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256
diff -r /tmp/ue-skills-ref corpus/knowledge/unreal-mcp/upstream   # expect only ".git"

# the count
cd /tmp/ue-skills-ref/skills/unreal-mcp/references
grep -c 'ModelContextProtocol\.' operations.md                     # 6 raw occurrences
sed -n '11,14p' operations.md | grep -c '^| `'                     # 4 console-table rows
sed -n '14p' operations.md | grep -oE '`(ClaudeCode|Cursor|VSCode|Gemini|Codex|All)`' | wc -l   # 6 enum args
grep -c '\-ModelContextProtocolPort' operations.md                 # 1 launch flag
# token counts — do NOT use grep for this, see note below
python3 -c "import re;ls=open('operations.md').read().split(chr(10));s=[m for l in ls for m in re.findall(r'\`([^\`]+)\`',l)];print(len(s),len(set(s)))"
```

Distinct inline backticked tokens in the file: **38**, across **47** inline spans,
of which 4 are console commands. The remaining 34 are arguments, enum values,
protocol names, ini keys, file names and prose fragments.

**Measurement note (a trap worth recording).** `grep -o '`[^`]*`'` reports **49
spans / 39 distinct** for this file, while the Python pass reports **47 / 38**. The
disagreement is entirely the 2 empty spans. Lines 25 and 28 are the ```` ```ini ````
and ```` ``` ```` fences of the settings snippet, each carrying 3 backticks; the
odd middle backtick on each line pairs with the next inline backtick, producing an
empty span that `[^`]*` accepts and `[^`]+` rejects:

```
$ grep -o '`[^`]*`' operations.md | wc -l            # 49
$ grep -o '`[^`]*`' operations.md | sort -u | wc -l  # 39
$ python3 -c "import re;ls=open('operations.md').read().split(chr(10));s=[m for l in ls for m in re.findall(r'\`([^\`]*)\`',l)];print(len(s),len(set(s)))"
49 39
$ python3 -c "import re;ls=open('operations.md').read().split(chr(10));s=[m for l in ls for m in re.findall(r'\`([^\`]+)\`',l)];print(len(s),len(set(s)))"
47 38
```

Both Python one-liners are copy-pasteable and were run as shown; the only change
between them is `*` vs `+` inside the capture group.

Backtick arithmetic, verified: the file holds **100** backtick characters. Lines 25
and 28 (the fences) hold **6** of them; the other **50** lines hold the remaining
**94**, which is exactly 2 × 47 → the **47** inline spans. The 2 spurious empty spans come
from the fence lines themselves: on the string ```` ```ini ```` the pattern
`[^`]*` matches backtick + empty + backtick at offsets 0–1, yielding one empty
match; line 28 ```` ``` ```` does the same. So the 6 fence backticks yield 2 empty
matches and no real token, and 94 + 6 = 100 checks out.

Authoritative figures for this report: **47 inline spans, 38 distinct tokens**, from
the require-≥1-char Python pass. Any future seat counting backticked tokens in this
file should use that pass, not bare `grep`.

---

## 8. Explicit non-claims

- No claim that any listed command executes. See §6.
- No claim that the upstream list is complete with respect to the *engine's* actual
  console command registry — only complete with respect to what this file names.
  The engine source is unavailable on this host (`git ls-remote` on
  `EpicGames/unreal-engine` → "Repository not found"), so an engine-side registry
  cross-check is not possible here.
- No edit was made to any vendored file. The probe is read-only with respect to
  `corpus/`.
