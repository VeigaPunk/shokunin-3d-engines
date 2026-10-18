# SEAT-21 PROBE — cross-document consistency of transport / setup facts

Round r101 · Seat SEAT-21 PROBE · Date 2026-10-18
Lane axes: depth / coverage / calibration — this probe serves **coverage** (C1).

Scope: reconcile the transport and setup facts stated in three files —
`README.md`, `skills/unreal-mcp/references/setup.md`, `skills/unreal-mcp/references/operations.md` —
on six fact families: **default port 8000**, **URL path `/mcp`**, **the tool-search meta-tools
(`list_toolsets` / `describe_toolset` / `call_tool`)**, **`bEnableToolSearch`**, **proxy behavior**,
and the setup prerequisites that bracket them. Every contradiction is flagged with `file:line`
pointers against the pinned upstream SHA.

Everything below is **verified-here** unless a line explicitly says otherwise. No claim about
live-editor MCP runtime is made anywhere in this report.

---

## 0. Verdict

**The three documents agree on all six fact families at the semantic level. No hard contradiction
was found in port, path, meta-tool names, or `bEnableToolSearch` default.** Four divergences exist.
One (D1) is a real contradiction in wording; two (D2, D3) are notation drift; one (D4) is a
reproducible divergence between a document and the shipped hook. No divergence changes a stated
technical value.

| # | Divergence | Severity | Status |
|---|---|---|---|
| D1 | `operations.md:46` says check for **both** `unreal-mcp` **and** `unreal-mcp-proxy`; `setup.md:115` says configure **one Unreal connection, not both** | **real contradiction** | open |
| D2 | `README.md:88` names the bind as `localhost:8000`; `setup.md:75` uses `127.0.0.1:8000` | hostname-form drift | open, low |
| D3 | `README.md:70` writes the port argument as `<port>` (required-looking); `operations.md:11` writes `[port]` (optional) | notation drift | open, low |
| D4 | Hook's "project root" (`README.md:13` → `hooks/unreal-context.sh:61`) is the `.uproject` dir, but `setup.md:65` puts `.mcp.json` at the *workspace* root for source builds — the hook then reports the file absent | **reproducible false negative** | open, secondary |

| Metric | Count |
|---|---|
| documents reconciled | 3 (+ `skills/unreal-mcp/SKILL.md` and `hooks/unreal-context.sh` as corroborating witnesses) |
| fact families checked | 6 |
| fact families with full semantic agreement | 6 / 6 |
| divergences flagged | 1 hard (D1) + 2 notation (D2, D3) + 1 doc-vs-hook (D4) |
| stray port literals other than 8000 | **0** |

---

## 1. Preconditions — pin and byte-identity

The pinned SHA is `a6aa73ada02a9fb1f5415bec491f9942c519b297`. Before citing any line number:

```
$ git -C /tmp/ue-skills-ref rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
```

Equal to the pin; no fresh clone was needed and `/tmp/r101work` was not created.

The vendored tree is byte-identical to the clone, so every `file:line` below is valid for both
`/tmp/ue-skills-ref/…` and `corpus/knowledge/unreal-mcp/upstream/…`:

```
$ diff -r --brief --exclude=.git . corpus/knowledge/unreal-mcp/upstream/
(no output)
$ echo $?
0
$ find . -path ./.git -prune -o -type f -print | wc -l   # 12
$ find corpus/knowledge/unreal-mcp/upstream -type f | wc -l   # 12
```

The round's own audit manifest independently confirms all 12 vendored files:

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
$ echo $?
0
```

sha256 of the three reconciled files (from the vendored tree, matching the manifest):

| File | lines | sha256 |
|---|---|---|
| `README.md` | 112 | `483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e` |
| `skills/unreal-mcp/references/setup.md` | 133 | `bd16206ea142dc9cc1950b88af526a3137072ea152c5662e8549d21bc18a3b8a` |
| `skills/unreal-mcp/references/operations.md` | 51 | `dbed002b4a46ab104274a31eb6682c3d277ce669216d0378df709f51567c3113` |

---

## 2. Fact family A — default port `8000`

All four statements give 8000 as the default, and none names a different default anywhere.

| Statement | Location | Value |
|---|---|---|
| "The default port is **8000** with URL path `/mcp`." | `README.md:70` | 8000 |
| `ServerPortNumber=8000` | `setup.md:51` | 8000 |
| `"url": "http://127.0.0.1:8000/mcp"` | `setup.md:75` | 8000 |
| "Pass a port to override the default (e.g. when 8000 is in use)." | `operations.md:11` | 8000 |
| "binds to `localhost:8000`" | `README.md:88` | 8000 |

Exhaustive sweep for any other port literal in the whole vendored tree:

```
$ grep -rn -E '\b(80|443|3000|5000|8001|8080|9000|1234|7777)\b' --include='*.md' .
(no output)
$ grep -rn -F '8000' .
./README.md:70  ./README.md:88
./skills/unreal-mcp/references/operations.md:11
./skills/unreal-mcp/references/setup.md:51  ./skills/unreal-mcp/references/setup.md:75
```

**Result: consistent.** No second default exists to contradict 8000.

Scope caveat (coverage gap, not a contradiction): `setup.md` never *states* that 8000 is the
default in prose. It appears only inside the block at `setup.md:48-53` introduced as "Optional
overrides if the defaults conflict with another local service", i.e. the reader is shown the default
value in the position of an override. A reader of `setup.md` alone cannot learn the default port;
they must read `README.md:70` or `operations.md:11`. The value is right; only its framing is odd.

---

## 3. Fact family B — URL path `/mcp`

| Statement | Location | Sense |
|---|---|---|
| "URL path `/mcp`" | `README.md:70` | HTTP path |
| `ServerUrlPath=/mcp` | `setup.md:52` | setting value |
| `"url": "http://127.0.0.1:8000/mcp"` | `setup.md:75` | literal endpoint |
| "Run `/mcp`" | `README.md:65`, `setup.md:129` | **Claude Code slash command**, not the HTTP path |

```
$ grep -rn -F '/mcp' .
./README.md:65  ./README.md:70
./skills/unreal-mcp/references/setup.md:52  ./skills/unreal-mcp/references/setup.md:75  ./skills/unreal-mcp/references/setup.md:129
```

**Result: consistent.** The single literal `/mcp` carries two distinct meanings (`README.md:65` /
`setup.md:129` = the `/mcp` slash command; `README.md:70` / `setup.md:52` / `setup.md:75` = the HTTP
path), and each site's surrounding sentence disambiguates. No site conflates them.

---

## 4. Fact family C — the tool-search meta-tools

The same trio — `list_toolsets`, `describe_toolset`, `call_tool` — appears in every document, with no
variant spelling anywhere (no `list_tool`, `describe_tools`, `call_tools`):

```
$ grep -rn -oE '\b(list_tool|list_toolsets|list_tools|describe_toolset|describe_tools|call_tool|call_tools|unreal_mcp_status|unreal-mcp-status)\b' --include='*.md' . | sort -u
(only exact forms: list_toolsets, describe_toolset, call_tool, unreal_mcp_status)
```

| Statement | Location | Content |
|---|---|---|
| "the MCP server exposes three meta-tools (`list_toolsets`, `describe_toolset`, `call_tool`) instead of the full tool catalog" | `README.md:82` | trio, "three meta-tools" |
| "advertises only three meta-tools … `list_toolsets`, `describe_toolset`, and `call_tool`" | `skills/unreal-mcp/SKILL.md:16` | trio, "three meta-tools" |
| "`tools/list` returns only `list_toolsets`, `describe_toolset`, `call_tool`" | `operations.md:20` | trio (True mode) |
| "`list_toolsets` (one of the three tool-search meta-tools) returns successfully" | `setup.md:128` | "three tool-search meta-tools" |
| "(`list_toolsets`, `describe_toolset`, `call_tool`)" | `skills/unreal-skill/SKILL.md:45` | trio |

**Result: consistent**, including the count ("three") and the "instead of the full catalog"
semantics. Dispatch contract also agrees: `SKILL.md:21` says `call_tool` takes
`toolset_name`/`tool_name`/`arguments`; `operations.md:20` says toolset tools are "dispatched
server-side through `call_tool`". No document claims the toolset tools appear in `tools/list`.

---

## 5. Fact family D — `bEnableToolSearch`

Default is `true` (tool search on) in every statement; the `False` branch means "everything
registered upfront".

| Statement | Location | Value / semantics |
|---|---|---|
| "**Tool search** is enabled by default" | `README.md:82` | default on |
| "`bEnableToolSearch` UPROPERTY … (default `true`)" | `operations.md:18` | default `true` |
| "Tool search is on by default" | `skills/unreal-mcp/SKILL.md:16` | default on |
| `False` → "every toolset tool is registered as a native MCP tool at startup" | `operations.md:21` | off = full catalog |
| `False` → "when disabled, every tool is registered upfront (path used by the hash-mapping commandlet)" | `README.md:82` | off = full catalog |

The ini section literal is byte-identical across all three documents — same 65-character string,
verified by hashing the extracted occurrence from each file:

```
$ for f in README.md skills/unreal-mcp/references/setup.md skills/unreal-mcp/references/operations.md; do
    grep -o -F '[/Script/ModelContextProtocolEngine.ModelContextProtocolSettings]' "$f" | head -1 | md5sum
  done
4135988624cbbbf86a93c2d40d9329b5  -   # README.md:82
4135988624cbbbf86a93c2d40d9329b5  -   # setup.md:44
4135988624cbbbf86a93c2d40d9329b5  -   # operations.md:26
```

`setup.md:44-46` places `bAutoStartServer=True` in that section; `operations.md:26-27` places
`bEnableToolSearch=False` in the same section. Same key, same section — a reader can set both in one
ini block. `operations.md:23` ("Override in the same `.ini` used for `bAutoStartServer`") makes that
explicit.

**Result: consistent.**

---

## 6. Fact family E — proxy behavior

Five claims are made about the proxy; all five agree across documents.

| Claim | `README.md` | `setup.md` | `operations.md` | `SKILL.md` |
|---|---|---|---|---|
| Keeps the client session open while Unreal is down | `:78` | `:3`, `:115` | `:32` | `:12` |
| Connection is named `unreal-mcp-proxy` | `:65` | `:115`, `:129` | `:32`, `:46` | `:12`, `:24` |
| Cached/visible tools do **not** prove live reachability | `:78` | `:121`, `:131` | `:35` | `:24` |
| Status-only fallback is `unreal_mcp_status` | `:78` | — | `:34`, `:36` | `:24` |
| Proxy lives at `Engine/Plugins/Experimental/ModelContextProtocol/Extras/Proxy` | `:76` | `:87`, `:91` | `:40` (refers to the engine README) | — |

The plugin-path literal is byte-identical in the two files that spell it out:

```
$ for f in README.md skills/unreal-mcp/references/setup.md; do
    grep -o -F 'Engine/Plugins/Experimental/ModelContextProtocol/Extras/Proxy' "$f" | head -1 | md5sum
  done
8ec85a241a030be7a9118a59f69540a7  -   # README.md:76
8ec85a241a030be7a9118a59f69540a7  -   # setup.md:87
```

The proxy-entry install contract agrees too: `setup.md:115` says the installer replaces the HTTP
entry with a STDIO `unreal-mcp-proxy` entry and keeps the original under `_upstreamEntry`;
`operations.md:32` says the client then connects to `unreal-mcp-proxy` instead of directly to
`unreal-mcp`. `README.md:80` links to both of those sections, and the anchors resolve
(§7).

Minor scope asymmetry (not a contradiction): `README.md:78` says "Without a cache, it exposes only
`unreal_mcp_status`", while `operations.md:36` states the condition as "With no stored catalog **and
no upstream session**". `operations.md:36` is the more precise of the two — if an upstream session
exists, the real catalog is exposed, so `README.md:78`'s cache-only condition is under-specified.
The stronger document (`operations.md:36`) contains the weaker one's case.

**Result: consistent**, with one scope asymmetry noted.

### D1 — the one hard contradiction

`operations.md:46` and `setup.md:115` disagree on the *cardinality* of configured connections:

```
$ sed -n '46p' skills/unreal-mcp/references/operations.md
| Unreal tools are missing, or `list_toolsets` errors | Check for both `unreal-mcp` and `unreal-mcp-proxy` in the client configuration. …

$ sed -n '115p' skills/unreal-mcp/references/setup.md
The installer replaces the HTTP entry with a STDIO `unreal-mcp-proxy` entry. It keeps the original entry under `_upstreamEntry`. Configure one Unreal connection, not both the proxy and a duplicate direct HTTP connection.
```

`operations.md:46` instructs the troubleshooting reader to look for **both** entries present;
`setup.md:115` says to configure **one**, "not both". `README.md:65` and `setup.md:129` both use the
disjunctive "or" form ("`unreal-mcp`, or `unreal-mcp-proxy`"), siding with `setup.md:115` — so
`operations.md:46` is the lone dissenter.

Reading `setup.md:115` in full, the apparent conflict softens: the installer *retains* the original
entry under the `_upstreamEntry` key, so a literal search of the config would find both strings while
only one is active. Under that reading `operations.md:46`'s "check for both" is a
*diagnostic search* ("look for either name") and `setup.md:115`'s "not both" is a
*configuration instruction*. The two are reconcilable, but neither sentence says so, and
`operations.md:46` never mentions `_upstreamEntry` (the string appears in exactly one place in the
whole repo — `setup.md:115`):

```
$ grep -rn -F '_upstreamEntry' .
./skills/unreal-mcp/references/setup.md:115
```

**Flagged as a real contradiction** in wording, resolvable by adding one clause to
`operations.md:46`. Fix is editorial, not technical.

---

## 7. Fact family F — setup prerequisites bracketing the transport

These are the facts a setup reader is told first; they agree across documents.

| Fact | `README.md` | `setup.md` | Verdict |
|---|---|---|---|
| Both `ModelContextProtocol` and `AllToolsets` required | `:17` | `:14` | agree |
| Server exposes no tools without `AllToolsets` | `:17` ("the server exposes none without it") | `:14` ("the server starts but exposes no tools") | agree |
| Server default state is **stopped** | `:18`, `:62` (manual `StartServer`) | `:35` ("default is … to stay stopped") | agree |
| Auto-start via `bAutoStartServer` in per-user ini | `:18` | `:44-46`, file path at `:39` | agree |
| `-ModelContextProtocolStartServer` / `-ModelContextProtocolPort` CLI alternative | — | `:55` | `-ModelContextProtocolPort` also at `operations.md:47`; no conflict |
| Plugin ships **no** static `.mcp.json` | `:72` | `:59` ("does not write `.mcp.json` on its own") | agree |
| `.mcp.json` generated by `ModelContextProtocol.GenerateClientConfig ClaudeCode` | `:72` | `:61` | agree |
| Source build → workspace root; installed → next to `.uproject` | — | `:65-66` | only in `setup.md` |
| Port collision → `ServerPortNumber` or `-ModelContextProtocolPort` | `:70` | `:48-53`, `:55` | agree |

Independently confirmed that no `.mcp.json` ships and that `plugin.json` carries no `mcpServers`
key — so `README.md:72`'s claim is true, not aspirational:

```
$ find . -name '.mcp.json' -not -path './.git/*'
(no output)
$ python3 -c "import json;print(sorted(json.load(open('.claude-plugin/plugin.json'))))"
['author', 'description', 'license', 'name', 'version']
```

### D4 — hook "project root" vs `setup.md:65` "workspace root"

`README.md:13` describes the `SessionStart` hook as injecting a note "identifying the repo as an
Unreal Engine project". The hook decides the project root by walking upward from `$PWD` and stopping
at the first directory containing `GenerateProjectFiles.{sh,bat,command}` or a `*.uproject`
(`hooks/unreal-context.sh:13-26`), then probes `"$project_root/.mcp.json"`
(`hooks/unreal-context.sh:61`).

`setup.md:65` says a source build writes `.mcp.json` "to the workspace root, alongside `Engine/`.
Not next to the `.uproject`."

In the standard UE source layout the engine root holds `GenerateProjectFiles.sh` and `Engine/`, and
the game `.uproject` sits one level down. Reproduced that layout:

```
$ mkdir -p $T/UnrealEngine/Engine/Source/Runtime/Engine $T/UnrealEngine/MyProject
$ : > $T/UnrealEngine/GenerateProjectFiles.sh ; : > $T/UnrealEngine/MyProject/MyProject.uproject
$ echo '{"mcpServers":{"unreal-mcp":{"type":"http","url":"http://127.0.0.1:8000/mcp"}}}' > $T/UnrealEngine/.mcp.json
```

Hook run from the directory holding the `.uproject` (i.e. `.mcp.json` is one level up, exactly where
`setup.md:65` puts it):

```
$ cd $T/UnrealEngine/MyProject && CLAUDE_UE_HOOK_DEBUG=1 bash hooks/unreal-context.sh
unreal-context.sh: project root: …/UnrealEngine/MyProject (type=game, uproject=MyProject.uproject, mcp_json=false)
{"hookSpecificOutput":{…"additionalContext":"… No `.mcp.json` is present at the project root yet. Run `ModelContextProtocol.GenerateClientConfig ClaudeCode` in the editor console to generate one."}}
```

(In the two lines above, `…` marks text elided by this report for width: the debug line's `$T`
prefix and the middle of the JSON. The decisive fields — `project root`, `type=game`,
`mcp_json=false`, and the "No `.mcp.json` is present" sentence — are verbatim.)

The hook reports `mcp_json=false` and tells the agent to generate a file that already exists. Run
from the engine root of that same tree it is correct (`mcp_json=true`).

Twelve hook invocations were run in total across four distinct directory-tree shapes:

| # | Tree shape | Invocations | cwd used | Hook result |
|---|---|---|---|---|
| 1 | Engine root: `GenerateProjectFiles.sh` + `Engine/`, game `.uproject` in a **subdirectory** | 6 | engine root; the `.uproject` subdir; `Engine/Source/Runtime/Engine` | **`mcp_json=false` from the subdirs when `.mcp.json` is at the workspace root** — the D4 false negative |
| 2 | Canonical single-root source build (`GenerateProjectFiles.sh` + `.uproject` + `Engine/` all at root) | 2 | root; `Engine/Source/Runtime/Engine` | `mcp_json=true`, correct |
| 3 | Installed/launcher build (no `Engine/`) | 3 | root; `Content/Maps`; a variant with no `.mcp.json` | `mcp_json=true` / `false` respectively, both correct |
| 4 | Directory with no project markers | 1 | the empty dir | exits 0, prints nothing — correct |

Only shape 1 produces the false negative, and only when the session's cwd is a subdirectory rather
than the workspace root.

**Flagged as D4** — a doc-vs-implementation divergence between `setup.md:65` (where the file is
written) and `hooks/unreal-context.sh:61` (where the hook looks). Impact is limited to one injected
sentence in the session-start note; the MCP connection itself is unaffected. Note the hook's own
header comment (`hooks/unreal-context.sh:4-5`) claims it "Walks upward from `$PWD` so sessions
started in subdirectories … are still detected" — detection does work, but the `.mcp.json` probe
stops at the first `.uproject` marker rather than continuing to the workspace root.

---

## 8. Divergences D2 and D3 (wording only)

**D2 — bind name.** `README.md:88` writes `localhost:8000`; `setup.md:75` writes
`127.0.0.1:8000`. Both name loopback, and the two are not interchangeable in general (on a
dual-stack host `localhost` may resolve to `::1`). The only literal endpoint the docs give a client
is the `127.0.0.1` form. Low severity: a reader copying the `README.md:88` form into a client URL
would usually still connect, but the docs never state which family the server actually binds.

**D3 — port-argument notation.** The same console command is written three ways:

```
$ grep -rn -oE 'ModelContextProtocol\.StartServer( <port>| \[port\])?' .
./README.md:18:ModelContextProtocol.StartServer
./README.md:62:ModelContextProtocol.StartServer
./README.md:70:ModelContextProtocol.StartServer <port>
./skills/unreal-mcp/references/operations.md:11:ModelContextProtocol.StartServer [port]
./skills/unreal-mcp/references/setup.md:35:ModelContextProtocol.StartServer
```

The port is optional (`setup.md:35`, `README.md:18`/`:62` all invoke it bare), so `[port]`
(`operations.md:11`) is the accurate notation and `<port>` (`README.md:70`) over-reads as required.
`setup.md:55`'s `-ModelContextProtocolPort=<port>` is a CLI flag, a different surface, and not part
of this divergence.

---

## 9. Cross-checks that came back clean

Recorded so a later seat does not re-derive them:

- **Tool counts.** "Hundreds of tools … 30+ toolsets" is stated identically in `README.md:3`,
  `.claude-plugin/plugin.json:4`, and `skills/unreal-mcp/SKILL.md:8`. Consistent, and unverifiable
  here (no editor) — see §10.
- **Hash-mapping commandlet.** Named in `README.md:82` and `operations.md:21` as the consumer of the
  `bEnableToolSearch=False` path; no third document contradicts.
- **`RefreshTools` / registry-repair flow.** `operations.md:13` and `:48` agree; no other document
  describes registry repair.
- **`GenerateClientConfig` client list.** `operations.md:14` lists
  `ClaudeCode, Cursor, VSCode, Gemini, Codex, All`; `setup.md:61` lists the same set. Consistent.
  Of the five call sites in the tree, four use the literal `ClaudeCode` and one uses the placeholder
  `<client>` — correct, since that row documents the argument:

  ```
  $ grep -rn -oE 'GenerateClientConfig [A-Za-z<>]+' .
  ./README.md:72:GenerateClientConfig ClaudeCode
  ./hooks/unreal-context.sh:77:GenerateClientConfig ClaudeCode
  ./skills/unreal-mcp/references/operations.md:14:GenerateClientConfig <client>
  ./skills/unreal-mcp/references/operations.md:47:GenerateClientConfig ClaudeCode
  ./skills/unreal-mcp/references/setup.md:61:GenerateClientConfig ClaudeCode
  ```
- **"Connected ≠ reachable" caveat.** Stated in `README.md:65`, `README.md:78`, `setup.md:131`,
  `operations.md:34` ("does not test current reachability"), `operations.md:40`, and
  `skills/unreal-mcp/SKILL.md:24`. Six independent sites, no dissent.

  ```
  $ grep -rn -iE 'do(es)? not (prove|test)' .
  ./README.md:65  ./README.md:78  ./skills/unreal-mcp/SKILL.md:24
  ./skills/unreal-mcp/references/operations.md:34  ./skills/unreal-mcp/references/operations.md:40
  ./skills/unreal-mcp/references/setup.md:131
  ```
- **Anchor targets of `README.md:80`.** Both fragments resolve against the vendored headings:
  `#4-optional-install-the-proxy` → `setup.md:83` (`## 4. Optional: install the proxy`);
  `#proxy-recovery` → `operations.md:30` (`## Proxy recovery`). Confirmed by slugifying every `##`
  heading in both files and matching.

---

## 10. Explicit non-claims

- **No runtime claim.** Unreal Editor is not installed on this host, so nothing here asserts that
  port 8000 is served, that `/mcp` responds, that the three meta-tools exist, or that
  `bEnableToolSearch` toggles anything. All statements are about **what the documents say**, plus
  what the vendored shell hook and JSON files literally do. Every such runtime fact remains
  **unproven-on-this-host** by construction.
- **No engine-side cross-check.** The engine source is unavailable here
  (`git ls-remote` on `EpicGames/unreal-engine` → "Repository not found"), so the defaults
  `ServerPortNumber=8000` / `ServerUrlPath=/mcp` and the `bEnableToolSearch` UPROPERTY cannot be
  confirmed against `ModelContextProtocolSettings.h`. Their consistency *across the three documents*
  is confirmed; their truth against the engine is not.
- **No edit to `corpus/`.** This probe is read-only with respect to the vendored tree; the only file
  written is this report.
- **Scope.** Only the six named fact families were reconciled. `skills/create-toolset/SKILL.md` and
  `skills/unreal-skill/SKILL.md` were consulted only where they corroborate a meta-tool name
  (§4); they were not audited.

---

## 11. Reproduction

```
cd corpus/knowledge/unreal-mcp/upstream
git -C /tmp/ue-skills-ref rev-parse HEAD                    # a6aa73ada02a9fb1f5415bec491f9942c519b297
diff -r --brief --exclude=.git . /tmp/ue-skills-ref    # 0 diffs vs the pinned clone
grep -rn -E '\b(80|443|3000|5000|8001|8080|9000)\b' --include='*.md' .   # no stray ports
grep -rn -F '8000' .                                        # README:70,88 ops:11 setup:51,75
grep -rn -F 'bEnableToolSearch' .                           # README:82 ops:18,27
grep -rn -F 'list_toolsets' .                               # 9 sites, all exact
grep -rn -F '_upstreamEntry' .                              # setup.md:115 only
sed -n '46p' skills/unreal-mcp/references/operations.md     # "check for both"   (D1)
sed -n '115p' skills/unreal-mcp/references/setup.md         # "not both"          (D1)
bash hooks/unreal-context.sh                                # D4: build the layout in §7
```

## 12. Recommended follow-ups (for the lane, not this seat)

1. **D1** — add a clause to `operations.md:46` distinguishing the diagnostic search from the
   one-connection configuration rule; the docs are one sentence away from fully consistent.
2. **D4** — either `setup.md:65` should say the hook probes the `.uproject` directory, or the hook
   should continue walking to the workspace root before concluding `.mcp.json` is absent. This is a
   probe finding, not a proposed edit; `corpus/` is frozen for this round.
3. **§2 scope gap** — `setup.md` could state the default port in prose rather than only inside the
   override block.
