# SEAT-24 PROBE — Trust-boundary inventory of the vendored unreal-mcp docs

**Scope:** every trust-boundary fact in the 12 upstream content files vendored at
`corpus/knowledge/unreal-mcp/upstream/`, each with a resolvable `file:line` pointer.
**Upstream:** `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin`
**Pin:** `a6aa73ada02a9fb1f5415bec491f9942c519b297`

## 0. Provenance receipt (run before any line number below is trusted)

Line numbers are only meaningful if the local bytes are the pinned bytes, so this was
re-derived rather than assumed.

```
$ git -C /tmp/ue-skills-ref rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
$ git -C /tmp/ue-skills-ref log -1 --format='%H%n%ad%n%s'
a6aa73ada02a9fb1f5415bec491f9942c519b297
Thu Sep 17 13:19:50 2026 +1200
[MCP] Permit safe concurrent tool calls
$ git -C /tmp/ue-skills-ref remote -v
origin  https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin (fetch)
```

All 12 vendored files were compared to that clone both by `diff -q` and by SHA-256:

```
$ find corpus/knowledge/unreal-mcp/upstream -type f | sort | while read f; do
    r="/tmp/ue-skills-ref/${f#corpus/knowledge/unreal-mcp/upstream/}"
    [ "$(sha256sum "$f" | cut -d' ' -f1)" = "$(sha256sum "$r" | cut -d' ' -f1)" ] \
      && echo "OK  ${f#corpus/knowledge/unreal-mcp/}" || echo "MISMATCH $f"; done
OK  upstream/.claude-plugin/plugin.json
OK  upstream/CODEOWNERS
OK  upstream/.gitignore
OK  upstream/hooks/hooks.json
OK  upstream/hooks/unreal-context.sh
OK  upstream/LICENSE
OK  upstream/README.md
OK  upstream/skills/create-toolset/SKILL.md
OK  upstream/skills/unreal-mcp/references/operations.md
OK  upstream/skills/unreal-mcp/references/setup.md
OK  upstream/skills/unreal-mcp/SKILL.md
OK  upstream/skills/unreal-skill/SKILL.md
$ find corpus/knowledge/unreal-mcp/upstream -type f | wc -l
12
```

Cross-checked independently against the sibling audit manifest written this round by
SEAT-15 (`sha256sum -c .manifest.d/audit-reference.sha256` → 12/12 `OK`). Both
independent checks agree, so the pointers below resolve against pinned bytes.

SHA-256 of the five files that carry the trust-boundary text:

| file | sha256 |
|---|---|
| `upstream/README.md` | `483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e` |
| `upstream/hooks/unreal-context.sh` | `d3f1c871cd4edd5210ee2f448c403e1a441e569a14a1405d1a3f199c65651fdd` |
| `upstream/skills/unreal-mcp/SKILL.md` | `7ef8b991a82f591c5776bb5fa167c2bc2269fd00338ed3e8534eacc551d038fa` |
| `upstream/skills/unreal-mcp/references/setup.md` | `bd16206ea142dc9cc1950b88af526a3137072ea152c5662e8549d21bc18a3b8a` |
| `upstream/skills/unreal-mcp/references/operations.md` | `dbed002b4a46ab104274a31eb6682c3d277ce669216d0378df709f51567c3113` |

Paths below are relative to `corpus/knowledge/unreal-mcp/`.

## 1. Required facts

### F1 — `localhost:8000` binding + the origin-validation caveat

Primary: **`upstream/README.md:88`**

> **Localhost is not a trust boundary.** The MCP server binds to `localhost:8000` with
> origin validation. Origin validation protects against a browser tab talking to the
> server, but any process running as the same user on the same machine can connect. Do
> not run the MCP server on shared or untrusted machines, and do not expose the port
> outside the loopback interface.

The caveat is stated in the same sentence as the mechanism: origin validation is a
browser-origin control, **not** a same-user/other-process control. The doc's own framing
("Localhost is not a trust boundary") is the strongest security statement in the corpus
and is the one the rest of the surface hangs off.

Corroborating pointers:

- `upstream/README.md:70` — "The default port is **8000** with URL path `/mcp`. If the
  port is in use, run `ModelContextProtocol.StartServer <port>` in the console with a
  different port number."
- `upstream/skills/unreal-mcp/references/setup.md:51` — `ServerPortNumber=8000` (the
  per-user `.ini` override).
- `upstream/skills/unreal-mcp/references/setup.md:75` — the concrete endpoint written
  into `.mcp.json`: `"url": "http://127.0.0.1:8000/mcp"`.
- `upstream/skills/unreal-mcp/references/operations.md:11` — `ModelContextProtocol.StartServer [port]`
  "Pass a port to override the default (e.g. when 8000 is in use)."

Boundary note: the loopback interface is the *entire* access control on the HTTP
transport. There is no token, no key, no per-client auth anywhere in the 12 files — this
was checked explicitly. `grep -rn -iE "credential|secret|token|authentication|authoriz"`
returns a single unrelated hit (`unreal-skill/SKILL.md:24`, "Every token costs context"),
and every `auth` substring in the corpus is the word `author*` (13 hits: `authoring`,
`Authoring`, `author`, `AUTHORS`). The only named control is origin validation,
and `README.md:88` says outright it does not cover local processes.

### F2 — `ProgrammaticToolset.execute_tool_script` runs arbitrary Python

Primary: **`upstream/README.md:90`**

> **`ProgrammaticToolset.execute_tool_script` executes arbitrary Python** inside the
> editor process. That script has full access to every toolset API, the project on disk,
> the asset database, and editor-privileged functions. Treat every invocation as a
> privileged operation that can mutate, move, or delete project content, and expect it
> to succeed without a second confirmation when approvals are disabled.

Four distinct capability grants are enumerated in that one line: every toolset API, the
project on disk, the asset database, and editor-privileged functions. The string
`execute_tool_script` appears in exactly two places in the whole corpus — `README.md:90`
and `README.md:92` — so this line is the only description of the tool anywhere in the
vendored set. `ProgrammaticToolset` appears once (`README.md:90`).

This is the capability that converts F1's transport weakness into project damage: a
same-user local process reaching port 8000 (F1) can reach this tool.

### F3 — `--dangerously-skip-permissions` removes the per-tool approval gate

Primary: **`upstream/README.md:92`**

> **`--dangerously-skip-permissions` removes the per-tool approval gate.** In that mode
> Claude can drive the editor and run Python through `execute_tool_script` with no
> further consent. A bad prompt in that mode can reach into the project and modify a
> large amount of state before you notice. Prefer not to run Claude Code with
> `--dangerously-skip-permissions` while this plugin is loaded; if you do, keep the blast
> radius small (narrow prompts, read-heavy tasks, a throwaway sandbox project).

The doc names the approval gate as the control and states its removal consequence
directly. Note the causal chain the doc builds across `:88 → :90 → :92`: loopback is not
a boundary → the Python tool is arbitrary → this flag removes the only remaining human
gate. F2's text also forward-references this flag ("expect it to succeed without a
second confirmation when approvals are disabled"), so the two lines are deliberately
coupled.

### F4 — Proxy cached-catalog caveat

The caveat is "a visible/cached catalog is not evidence of a working connection," and it
is asserted in four independent places:

- `upstream/README.md:78` — "It stores Unreal's native tool catalog as a temporary
  fallback. **Cached tools do not prove that live calls can succeed.** Without a cache,
  it exposes only `unreal_mcp_status` until the client fetches the recovered catalog."
- `upstream/skills/unreal-mcp/references/operations.md:35` — "Visible tools can come from
  a stored catalog. Verify live access with a read-only Unreal tool call."
- `upstream/skills/unreal-mcp/references/operations.md:37` — "A client that ignores it
  can keep the status-only catalog, or an older cached catalog."
- `upstream/skills/unreal-mcp/references/setup.md:131` — "A connected proxy or visible
  cached tools do not prove that Unreal is reachable. Confirm with a successful read-only
  Unreal tool call."

Supporting mechanism pointers:

- `upstream/skills/unreal-mcp/references/setup.md:121` — the cache is on disk in the OS
  user cache directory, scoped by "configuration path, proxy path, engine build identity,
  and client protocol version," and the upstream `Extras/Proxy/README.md` is deferred to
  for real cache behavior.
- `upstream/skills/unreal-mcp/references/operations.md:34` — `unreal_mcp_status` "reports
  whether the proxy holds an initialized upstream session. It does not test current
  reachability."
- `upstream/skills/unreal-mcp/references/operations.md:36` — with no catalog and no
  session, only `unreal_mcp_status` is exposed; recovery sends
  `notifications/tools/list_changed`.
- `upstream/README.md:65` and `upstream/skills/unreal-mcp/SKILL.md:24` — the same caveat
  restated for the client-facing surface ("A connected proxy does not prove that Unreal
  is reachable").

Why this is a trust boundary and not just a UX note: a stale catalog is **attacker-
influenced or operator-stale state that the client presents as live capability**. The
mitigation the docs prescribe is uniform and cheap — one read-only live call — and the
fact that upstream restates the caveat repeatedly is itself the finding. Exact
repetition counts (reproducible):

- the literal phrase `do(es) not prove` occurs **5× across 4 files** —
  `README.md:65`, `README.md:78`, `skills/unreal-mcp/SKILL.md:24`,
  `skills/unreal-mcp/references/operations.md:40`,
  `skills/unreal-mcp/references/setup.md:131`
  (`grep -rn -icE "do(es)? not prove" upstream` → README 2, SKILL 1, operations 1, setup 1).
- the narrower "cached catalog is not live capability" claim appears at
  `README.md:78`, `operations.md:35`, `operations.md:37`, `setup.md:131` — 4 pointers in
  3 files — plus the client-facing restatements at `README.md:65` and
  `skills/unreal-mcp/SKILL.md:24`.

Note that `operations.md:40`'s hit is adjacent but distinct in subject ("A running editor
alone does not prove that the proxy targets its MCP server"); it is included in the
count because it uses the same phrase, and called out here so the number is not read as
six identical statements.

### F5 — VCS-mutation warning

Primary: **`upstream/README.md:94`**

> **Source-control hygiene.** MCP tools edit live `UObject` state and can mutate, move,
> or delete VCS-tracked assets in a single call. Save and commit (or shelve) before any
> long MCP-driven session so the working copy is recoverable if Claude produces an
> unexpected result. Review the diff before submitting.

The threat model is destructive change to tracked content **in a single call**; the word
"irreversible" does not appear (the corpus never uses `irreversib*` anywhere), and the
named control is a pre-session recovery point rather than prevention. `VCS` appears
exactly once in the corpus (`README.md:94`); the phrase `version control` (with a space)
appears **zero** times. The only related hits are the hyphenated `version-controlled`,
both in an unrelated sense, at `upstream/skills/unreal-skill/SKILL.md:34` and `:49`.

Reinforced inside the runtime skill:

- `upstream/skills/unreal-mcp/SKILL.md:30` — "**Save first, then save again.** …
  MCP edits are not always undoable, especially across compilation boundaries. Treat
  anything that touches multiple assets as a destructive operation that needs a recovery
  point."
- `upstream/skills/unreal-mcp/SKILL.md:33` — "many tools return a status that flips
  between success and failure with no exception thrown on the wire. … Treat anything
  that isn't an explicit success as a stop."

## 2. Additional trust-boundary facts found (not in the seat brief)

Recorded because they are load-bearing and a reader trusting only §1 would miss them.

### F6 — Plugin install itself is framed as arbitrary code execution

`upstream/README.md:86` — "Installing this plugin gives Claude broad, live access to the
running Unreal Editor. Treat that access the same way you would treat running arbitrary
code from an assistant, because in practice it is."

This is the top-level framing sentence for the whole `## Security` section
(`upstream/README.md:84`). F1–F5 are elaborations of it.

### F7 — Team install path is gated on project-folder trust

`upstream/README.md:50` — "Commit this to `.claude/settings.json` in the project that
should use the plugin. **Anyone who trusts the project folder is prompted to install it
automatically**". The trust decision is delegated to Claude Code's folder-trust prompt;
the doc does not add a second gate. This is a supply-chain surface: whoever controls the
committed `.claude/settings.json` controls who is prompted.

### F8 — Hook execution path (`SessionStart`, bash, 5s timeout)

- `upstream/hooks/hooks.json:10` — `"command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/unreal-context.sh"`
- `upstream/hooks/hooks.json:6` — matcher `"startup|resume|clear"` (fires on all three)
- `upstream/hooks/hooks.json:11` — `"timeout": 5`
- `upstream/README.md:19` / `:25` — requires a working `bash` on `PATH`;
  `upstream/README.md:28` — on native Windows PowerShell the hook silently does not run
  ("The plugin's MCP tools still work; you just lose the short project-context note").

The hook runs automatically at session start, outside any per-tool approval gate. It is
the only artifact in the vendored set that executes on the host without a tool call.

### F9 — Hook has no capability beyond context injection (verified here)

Read in full (`upstream/hooks/unreal-context.sh`, 84 lines). It performs no network I/O,
no writes, and no `eval`; it walks up from `$PWD` looking for
`GenerateProjectFiles.{bat,sh,command}` or `*.uproject` (`:19-25`), stats
`$project_root/.mcp.json` for existence only (`:61`), and `printf`s one JSON line
(`:84`). Its only external commands are `dirname` (`:36`) and `basename` (`:55`); the
only redirect is `>&2` on the opt-in debug path (`:9`). It does not read the contents
of `.mcp.json` — `:61` is a `[ -f ]` existence test only. Its output is a *string*, so
its real risk is the injection channel in F10.

### F10 — Hook JSON escaper is incomplete: newline in a `.uproject` basename produces invalid JSON

**This is a defect verified by running the vendored hook, not a quote from the docs.**

The escaper is at `upstream/hooks/unreal-context.sh:80-82`:

```bash
# JSON-escape the dynamic content: backslash first, then double quote.
escaped_context="${context//\\/\\\\}"
escaped_context="${escaped_context//\"/\\\"}"
```

It escapes backslash and double quote but **not control characters** (newline, tab, and
the rest). The interpolated value `$uproject_filename` comes from
`basename` of a filesystem entry (`:53-58`) and is injected at `:70`. Reproduction:

```
$ T=$(mktemp -d); cd "$T"; printf '{}' > "$(printf 'A\nB').uproject"
$ bash <hook> > a.json; jq -e . a.json
CASE-A newline-in-name : INVALID     # jq exit != 0
CASE-B quote-in-name   : VALID       # 'Q"uote.uproject' — escaper handles this
CASE-C plain-name      : VALID       # 'plain.uproject' — control
```

Raw bytes of the failing case confirm a literal LF inside the JSON string:

```
{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"...The project is `evil$
name.uproject`. ..."}}
```

`shellcheck` (0.11.0, installed this round) reports **exit 0, no warnings** on this file,
so the standard linter does not catch it — worth noting for anyone who treats a clean
shellcheck as evidence of correctness.

Severity: **low**. It requires a `.uproject` filename containing a newline, which no
normal project has, and the worst outcome is a malformed hook payload (the context note
is dropped) rather than code execution. It is reported because it is the one place where
this seat could produce *runtime* evidence about a vendored artifact rather than a
citation, and because the fix is one line (`jq -Rs` or an explicit control-char pass).

### F11 — `.mcp.json` is rewritten by tooling, with two named hazards

- `upstream/skills/unreal-mcp/references/setup.md:115` — the proxy installer "replaces
  the HTTP entry with a STDIO `unreal-mcp-proxy` entry. It keeps the original entry under
  `_upstreamEntry`. Configure one Unreal connection, not both…"
- `upstream/skills/unreal-mcp/references/setup.md:117` — "If an editor integration
  automatically replaces `.mcp.json`, disable that integration's automatic
  client-configuration writes."
- `upstream/skills/unreal-mcp/references/setup.md:61` — `GenerateClientConfig` "merges
  into the existing JSON"; Codex is the exception and "the writer refuses to overwrite an
  existing `.codex/config.toml`."

Client config is a mutable, multi-writer file that determines which endpoint the agent
talks to. Two writers on one file is the classic misconfiguration path to pointing the
agent at the wrong server.

### F12 — `AllToolsets` is the breadth knob, and it is off by default

- `upstream/skills/unreal-mcp/references/setup.md:14` — "With only `ModelContextProtocol`
  enabled the server starts but exposes no tools."
- `upstream/skills/unreal-mcp/references/setup.md:31` — "`AllToolsets` is an editor-only
  aggregator with `EnabledByDefault` off… To expose only a subset of tools, enable the
  specific toolset plugins you want instead of `AllToolsets`."

Least-privilege guidance that is present in the doc but never labeled as security
guidance. Relevant to F2: the reach of `execute_tool_script` is set by which toolsets are
enabled, so F12 is the practical mitigation for F2.

### F13 — Tool search keeps the tool catalog out of the prompt (context, not access, control)

- `upstream/skills/unreal-mcp/SKILL.md:16` — tool names "are **not in `tools/list`**.
  They are dispatched server-side through `call_tool` and never registered as native MCP
  tools."
- `upstream/skills/unreal-mcp/references/operations.md:20` — default `bEnableToolSearch=True`
  returns only `list_toolsets`, `describe_toolset`, `call_tool`.

Included only to be explicit that this is **not** a security control: it reduces prompt
size, not reach. The same tools are callable either way.

### F14 — No destructive-operation confirmation exists in the docs

Checked and found absent. Across all 12 files there is no described mechanism that
confirms a destructive tool call beyond the Claude Code per-tool approval gate named at
`upstream/README.md:92`. The corpus's own answer to "how do I prevent damage" is
recovery-oriented rather than prevention-oriented: `upstream/README.md:94`
(commit/shelve first), `upstream/skills/unreal-mcp/SKILL.md:30` (save before and after,
treat multi-asset edits as destructive), and `upstream/skills/unreal-mcp/SKILL.md:33`
(treat any non-explicit-success as a stop). Grep evidence:
`grep -rn -iE "destructive|irreversib|undo"` returns exactly 2 hits —
`skills/unreal-mcp/SKILL.md:30` ("not always undoable", "a destructive operation") and
`skills/unreal-mcp/references/operations.md:50` (a false positive: "undocked"). No
`irreversib*` match exists anywhere in the corpus. `README.md:90` and `README.md:94`
describe destructive outcomes but do not use any of these three words; they are cited
above on meaning, not on lexical match.

## 3. Fact → control matrix

| # | Fact | Primary pointer | Named control | Control strength per docs |
|---|---|---|---|---|
| F1 | Loopback bind, origin validation only | `upstream/README.md:88` | origin validation; "do not run on shared/untrusted machines" | partial — doc states it does **not** cover local processes |
| F2 | `execute_tool_script` = arbitrary Python | `upstream/README.md:90` | treat as privileged operation | none — advisory only |
| F3 | `--dangerously-skip-permissions` | `upstream/README.md:92` | the per-tool approval gate (removed by this flag) | binary — absent when flag used |
| F4 | Cached catalog ≠ live capability | `upstream/README.md:78`, `operations.md:35,37`, `setup.md:131` | one read-only live call | strong — cheap, repeatable |
| F5 | VCS-tracked assets mutated in one call | `upstream/README.md:94` | commit/shelve + review diff | strong — recoverable, operator-owned |
| F6 | Install = broad live access | `upstream/README.md:86` | treat as arbitrary code execution | framing only |
| F7 | Team install via folder trust | `upstream/README.md:50` | Claude Code folder-trust prompt | delegated |
| F8 | Hook runs at session start, ungated | `upstream/hooks/hooks.json:6,10,11` | 5s timeout; bash required | minimal |
| F10 | Hook JSON escaper misses control chars | `upstream/hooks/unreal-context.sh:80-82` | none | defect (low severity, verified here) |
| F11 | `.mcp.json` rewritten by tooling | `setup.md:115,117` | disable integrations' auto-writes | advisory only |
| F12 | `AllToolsets` breadth, off by default | `setup.md:14,31` | enable a subset instead | strong — least privilege |

## 4. Evidence ledger

Every command below was run in this round against the pinned bytes.

| Claim | Command | Observed |
|---|---|---|
| Clone at pin | `git -C /tmp/ue-skills-ref rev-parse HEAD` | `a6aa73ada02a9fb1f5415bec491f9942c519b297` |
| Vendored == upstream | per-file `diff -q` | 12/12 IDENTICAL |
| Vendored == upstream (hash) | per-file `sha256sum` compare | 12/12 OK |
| Independent cross-check | `sha256sum -c .manifest.d/audit-reference.sha256` | 12/12 `OK` |
| F1 line text | `grep -rn "binds to" upstream` | `README.md:88` |
| F2 line text | `grep -rn "execute_tool_script" upstream` | exactly 2 hits: `README.md:90`, `:92` |
| F3 line text | `grep -rn "dangerously" upstream` | 1 hit: `README.md:92` |
| F4 caveat | `grep -rn -iE "cached\|stored catalog" upstream` | `README.md:78,80`; `operations.md:35,36,37`; `setup.md:121,131` |
| F4 repetition count | `grep -rn -icE "do(es)? not prove" upstream` | 5 hits / 4 files: README 2, SKILL 1, operations 1, setup 1 |
| F5 line text | `grep -rn "VCS" upstream` | 1 hit: `README.md:94` |
| F5 `version control` space-form | `grep -rn "version control" upstream` | exit 1 — **0 hits**; only `version-controlled` at `unreal-skill/SKILL.md:34,49` |
| F14 destructive-word grep | `grep -rn -iE "destructive\|irreversib\|undo" upstream` | exactly 2 hits: `skills/unreal-mcp/SKILL.md:30`, `skills/unreal-mcp/references/operations.md:50` (false positive "undocked"); 0 `irreversib*` |
| No auth mechanism anywhere | `grep -rn -iE "credential\|secret\|token\|authentication\|authoriz" upstream` | 1 hit, unrelated: `unreal-skill/SKILL.md:24` ("Every token costs context") |
| All `auth` hits are the `author*` substring | `grep -rn -io "auth[a-z]*" upstream \| sort \| uniq -c` | `authoring`/`Authoring`/`author`/`AUTHORS` only — 13 hits, zero auth mechanisms |
| Hook lints clean | `shellcheck upstream/hooks/unreal-context.sh` | exit 0, no warnings (v0.11.0) |
| F10 defect | `printf '{}' > "$(printf 'A\nB').uproject"; bash hook \| jq -e .` | `INVALID`; quote and plain controls `VALID` |
| F10 line numbers | `sed -n '80,84p' upstream/hooks/unreal-context.sh` | escaper escapes `\\` and `"` only |

## 5. What is NOT verified here

Stated explicitly so no reader upgrades a doc quote into a runtime fact.

- **No live editor exists on this host.** Unreal Editor is not installed; engine install
  is blocked pending operator Epic-account linking (AUR `unreal-engine 5.8.2-1` PKGBUILD
  needs SSH to `git@github.com:EpicGames/UnrealEngine`, ~line 280;
  `git ls-remote` on `EpicGames/unreal-engine` → "Repository not found"). Therefore:
  - F1's bind behaviour is **documented, not observed**. Nothing here shows the server
    actually binds only to loopback.
  - F2's tool is **documented, not observed**. `execute_tool_script` was never invoked;
    the file contains no implementation of it — the vendored repo is skills/docs only.
  - F3's flag semantics are Claude Code's, quoted from the doc, not exercised.
  - F4's proxy was never run; `unreal_mcp_proxy` is not on this host.
- **The origin-validation implementation is not in this repo.** The docs assert it
  exists; the code that performs it lives in the engine's
  `ModelContextProtocol` plugin, which is not vendored and not obtainable here. So F1's
  control is *claimed by upstream* and unverifiable from the corpus.
- **F10 was verified on Linux/bash only.** The hook is documented to be skipped entirely
  on native Windows PowerShell (`upstream/README.md:28`), so the defect has a narrower
  real-world reach than a Linux-first reading suggests.
- **Severity judgments in §3 are this seat's, not upstream's.** Upstream supplies no
  severity labels; only F10 carries runtime evidence.

## 6. Handoff notes for the calibration seat

Rows worth carrying into the Claude→Kimi adaptation table, since each changes behaviour
under a different harness:

1. **F3 is Claude-Code-specific.** `--dangerously-skip-permissions` is a Claude Code
   flag. Under Kimi Code the equivalent is the permission mode; the *fact* (approval
   gate is the only human control over F2) transfers, the *flag name* does not.
2. **F7's folder-trust prompt** is a Claude Code mechanism; the underlying "installing
   the plugin is a trust decision" fact transfers.
3. **F8/F9 hook contract** — `SessionStart`, `${CLAUDE_PLUGIN_ROOT}`, and the
   `hookSpecificOutput` JSON envelope at `unreal-context.sh:84` are Claude Code harness
   shapes. Any port must re-target the envelope or the injected context is discarded.
4. **F10's fix** should be re-verified after porting, since the escaper is harness glue
   and a rewrite is the likely port.
5. **F4's verification ritual** (one read-only live call) is harness-neutral and should
   be policy, not prose, in any adaptation.
