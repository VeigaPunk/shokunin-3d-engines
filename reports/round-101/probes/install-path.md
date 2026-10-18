# SEAT-26 PROBE — documented install paths vs this host

Round r101 · lane game-dev-3d-shokunin · axis: coverage / depth / calibration
Seat: SEAT-26 PROBE → `reports/round-101/probes/install-path.md`
Date: 2026-10-18

**Scope.** Audit every install step the upstream `README.md` and
`skills/unreal-mcp/references/setup.md` document — the marketplace id, the
`.claude/settings.json` `enabledPlugins` block, single-dev vs team flow, and
`ModelContextProtocol.GenerateClientConfig ClaudeCode` — and label each step
**REPRODUCIBLE-HERE** or **NOT-REPRODUCIBLE** with the observed command output
that decides it. No runtime/editor claim is made anywhere in this file.

## 0. Verdict table

| # | Documented step | Label | Deciding observation |
|---|---|---|---|
| 1 | `/plugin marketplace add anthropics/claude-plugins-official` | **REPRODUCIBLE-HERE** | `✔ Successfully added marketplace: claude-plugins-official (declared in user settings)` |
| 2 | `/plugin install unreal-engine-skills-for-claude-code@claude-plugins-official` | **REPRODUCIBLE-HERE** (after step 1) | `outcome:"ok"`, v3.1.1, `Status: ✔ enabled` |
| 3 | README "official marketplace … is available automatically when you start Claude Code" | **NOT-REPRODUCIBLE** on this host, and the premise is false | `claude plugin marketplace list` in a fresh HOME lists only `anthropic-plugin-directory`; install from that marketplace by the documented *name* fails `not_found` |
| 4 | Single-dev `/plugin install` (one-command variant, `--marketplace`) | **REPRODUCIBLE-HERE** — better than documented | `claude plugin install <name> --marketplace anthropics/claude-plugins-official` → `outcome:"ok"` with no prior `marketplace add` |
| 5 | Team flow: commit `enabledPlugins` to `.claude/settings.json`, "prompted to install automatically" | **NOT-REPRODUCIBLE non-interactively** (prompt cannot be exercised here); the *file* is written by `-s project` | bare `enabledPlugins` in project settings → `claude plugin list --json` → `[]`, even with marketplace pre-added **and** `hasTrustDialogAccepted: true` |
| 6 | `.mcp.json` hand-write (setup.md §3, editor-free path) | **REPRODUCIBLE-HERE** | Claude Code parsed the file: `unreal-mcp: http://127.0.0.1:8000/mcp (HTTP) - ⏸ Pending approval` |
| 7 | `ModelContextProtocol.GenerateClientConfig ClaudeCode` (setup.md §3 preferred path) | **NOT-REPRODUCIBLE** | no Unreal Editor on host (`command -v UnrealEditor` → not found); no engine repo access |
| 8 | Editor-side prerequisites (`.uproject` plugin enable, `bAutoStartServer`, `StartServer`) | **NOT-REPRODUCIBLE** | all editor-console/`.uproject` steps; editor absent by construction |
| 9 | Optional proxy `unreal_mcp_proxy install` | **NOT-REPRODUCIBLE** | no proxy binary anywhere on host; engine tree absent |
| 10 | Hook `SessionStart` (`hooks/unreal-context.sh`) | **REPRODUCIBLE-HERE** (behavior, not Claude wiring) | valid JSON on a fake `.uproject`; `shellcheck -s bash` exit 0 |

## 1. Source resolution (pin confirmed before any read)

| Field | Value | Command |
|---|---|---|
| Upstream | `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin` | — |
| Pinned SHA | `a6aa73ada02a9fb1f5415bec491f9942c519b297` | `git -C /tmp/ue-skills-ref rev-parse HEAD` |
| Clone state | pre-existing `/tmp/ue-skills-ref`, SHA **equals** pin → reused, no fresh clone | `git -C /tmp/ue-skills-ref rev-parse HEAD` |
| Vendored copy | `corpus/knowledge/unreal-mcp/upstream/` | `diff -r --brief . /tmp/ue-skills-ref --exclude=.git` → clean |
| Vendored file count | 12 | `find . -type f \| wc -l` |

`diff -r` over the whole tree is clean, and the three spot-checked sha256 pairs
agree exactly (`README.md 483693ad…`, `setup.md bd16206e…`,
`plugin.json 5aa98484…`).

## 2. Host receipts (re-derived, not quoted)

```
$ nproc                                  32
$ free -g | head -2                      Mem: 30 (13 used, 17 available)
$ df -h / | tail -1                      /dev/mapper/root 930G 132G 780G 15% /
$ uname -r                               7.2.3-arch1-3
$ jq --version                           jq-1.8.2
$ python3 -V                             Python 3.14.7
$ node -v                                v26.12.0
$ shellcheck --version                   version: 0.11.0
$ command -v UnrealEditor                (not found)
$ ss -ltn | grep -c ":8000"              0
```

All five host receipts in the round brief are confirmed on this seat.

### 2.1 The Claude Code CLI *is* present — this is what makes the audit possible

```
$ claude --version
2.1.302 (Claude Code)
```

The round brief lists this host as a Kimi Code host and does not mention a
Claude Code binary, but `/usr/bin/claude` exists at 2.1.302. Every
**REPRODUCIBLE-HERE** label below is a receipt from that real binary, executed
in a throwaway `HOME` so the operator's own config was never touched
(`/tmp/fakehome2`, `/tmp/bih`, `/tmp/mph1`, … — all `rm -rf`-able).

## 3. Single-dev flow — REPRODUCIBLE-HERE

Documented two-step (`README.md:39-46`). Run in `HOME=/tmp/fakehome2`:

```
$ claude plugin marketplace add anthropics/claude-plugins-official
Adding marketplace…SSH not configured, cloning via HTTPS: https://github.com/anthropics/claude-plugins-official.git
✔ Successfully added marketplace: claude-plugins-official (declared in user settings)

$ claude plugin install unreal-engine-skills-for-claude-code@claude-plugins-official --json
{"command":"install","outcome":"ok","plugin":"unreal-engine-skills-for-claude-code@claude-plugins-official",
 "pluginId":"unreal-engine-skills-for-claude-code@claude-plugins-official","scope":"user",
 "message":"Successfully installed plugin: … (scope: user)"}

$ claude plugin list
  ❯ unreal-engine-skills-for-claude-code@claude-plugins-official
    Version: 3.1.1
    Scope: user
    Status: ✔ enabled
```

Both steps reproduce exactly as documented. **REPRODUCIBLE-HERE.**

### 3.1 The install is byte-identical to the pinned clone

`cmp` over all 12 files between
`/tmp/fakehome2/.claude/plugins/cache/claude-plugins-official/unreal-engine-skills-for-claude-code/3.1.1`
and `/tmp/ue-skills-ref`:

```
IDENTICAL  README.md
IDENTICAL  .claude-plugin/plugin.json
IDENTICAL  hooks/hooks.json
IDENTICAL  hooks/unreal-context.sh
IDENTICAL  skills/unreal-mcp/SKILL.md
IDENTICAL  skills/unreal-mcp/references/setup.md
IDENTICAL  skills/unreal-mcp/references/operations.md
IDENTICAL  skills/create-toolset/SKILL.md
IDENTICAL  skills/unreal-skill/SKILL.md
IDENTICAL  CODEOWNERS
IDENTICAL  LICENSE
IDENTICAL  .gitignore
```

So the marketplace-delivered artifact equals the SHA-pinned source. The
installer independently records the same pin:

```json
"gitCommitSha": "a6aa73ada02a9fb1f5415bec491f9942c519b297"
```
(`/tmp/fakehome2/.claude/plugins/installed_plugins.json`)

That is a third, independent corroboration of the pin — the marketplace
catalog, the installed-plugin record, and the clone all agree.

## 4. The marketplace id — a documentation defect, corrected by measurement

`README.md:32` claims the plugin "is published in Anthropic's official Claude
Code plugin marketplace, `claude-plugins-official`, which is available
automatically when you start Claude Code."

**On this host the `claude-plugins-official` marketplace is not present until
you add it.** Fresh `HOME=/tmp/fakehome`, no prior state:

```
$ claude plugin marketplace list
Configured marketplaces:
  ❯ anthropic-plugin-directory
    Source: Built in (Anthropic Directory)

$ claude plugin install unreal-engine-skills-for-claude-code@claude-plugins-official --json
{"outcome":"failed","failureCode":"not_found",
 "message":"Plugin \"unreal-engine-skills-for-claude-code\" not found in marketplace \"claude-plugins-official\". Your local copy may be out of date — try `claude plugin marketplace update claude-plugins-official`."}
```

So the README's fallback branch ("If the official marketplace is not present,
add it first") is the *actual* path here, and the primary claim is wrong for
2.1.302 on this host. Note the failure message is misleading — it suggests the
catalog is stale, when the real cause is that the marketplace was never
registered.

### 4.1 The same plugin is in the built-in directory under a *different* name

`claude plugin list --available --json` in a bare fresh HOME reports 3505
available plugins, including:

```json
{"pluginId": "unreal-engine-skills@anthropic-plugin-directory",
 "name": "unreal-engine-skills",
 "marketplaceName": "anthropic-plugin-directory",
 "version": "3.1.1",
 "source": {"source":"url",
   "url":"https://github.com/epicgames/unreal-engine-skills-for-claude-code-plugin.git",
   "sha":"a6aa73ada02a9fb1f5415bec491f9942c519b297"}}
```

Installing it needs no `marketplace add` at all:

```
$ claude plugin install unreal-engine-skills@anthropic-plugin-directory --json
{"outcome":"ok", …}
$ claude plugin list
  ❯ unreal-engine-skills@anthropic-plugin-directory
    Version: 3.1.1-a6aa73ada02a
    Scope: user
    Status: ✔ enabled
```

Its cache is byte-identical to the pinned clone for all 12 files (`cmp` again),
and `installed_plugins.json` again records
`gitCommitSha a6aa73ada02a9fb1f5415bec491f9942c519b297`. `claude plugin
details` resolves the display name to the upstream one:

```
Unreal Engine Skills (unreal-engine-skills-for-claude-code) 3.1.1
  Skills (3)  create-toolset, unreal-mcp, unreal-skill
  Agents (0)  Hooks (1) SessionStart  MCP servers (0)  LSP servers (0)
  Always-on: ~813 tok
```

**Why this matters for the lane.** The README's install id and the built-in
directory's id differ (`unreal-engine-skills-for-claude-code` vs
`unreal-engine-skills`), and `anthropic-plugin-directory` is a *separate*
marketplace from `claude-plugins-official` — the same commit is catalogued in
both. Anyone following the README verbatim on a machine that lacks the
`claude-plugins-official` registration gets `not_found`; the zero-prerequisite
route is the built-in name. Adding the GitHub marketplace also works and yields
the same bytes, so the two routes are equivalent in content but not in
prerequisites.

### 4.2 `MCP servers (0)` confirms there is no shipped `.mcp.json`

Both installs report `MCP servers (0)` in the component inventory, which
matches `README.md:72` ("This plugin does not ship a static `.mcp.json` file").
Verified structurally too: the plugin repo's `.claude-plugin/` contains only
`plugin.json`, and `find` for `marketplace.json` in the plugin repo returns
nothing.

## 5. One-command install variant — REPRODUCIBLE-HERE, undocumented upstream

`claude plugin install` accepts `--marketplace <source>` and adds the
marketplace itself if absent. Fresh `HOME=/tmp/mh1`:

```
$ claude plugin install unreal-engine-skills-for-claude-code --marketplace anthropics/claude-plugins-official --json
{"outcome":"ok","scope":"user", …}
$ claude plugin list
  ❯ unreal-engine-skills-for-claude-code@claude-plugins-official   Version: 3.1.1   Status: ✔ enabled
```

The user `settings.json` afterwards contains both blocks:

```json
{
  "extraKnownMarketplaces": {
    "claude-plugins-official": {"source": {"source":"github","repo":"anthropics/claude-plugins-official"}}
  },
  "enabledPlugins": {
    "unreal-engine-skills-for-claude-code@claude-plugins-official": true
  }
}
```

The upstream docs describe the two-step form only. This one-command form is
REPRODUCIBLE-HERE and is the cheapest verified path on this host.

## 6. Team flow — the file is right, the auto-install does not fire non-interactively

`README.md:48-58` says to commit the `enabledPlugins` block to
`.claude/settings.json` and that "Anyone who trusts the project folder is
prompted to install it automatically".

**The exact block is correct.** Running `claude plugin install … -s project`
in `/tmp/ps1` writes precisely the documented JSON:

```
$ cat /tmp/ps1/.claude/settings.json
{
  "enabledPlugins": {
    "unreal-engine-skills-for-claude-code@claude-plugins-official": true
  }
}
$ python3 -c "…documented block is a subset of written file…"
documented block is a subset of written file: True
written keys: ['enabledPlugins']
```

So the schema, key, and `plugin@marketplace` value form are all confirmed
against a real Claude Code 2.1.302 write. **The block is REPRODUCIBLE-HERE.**

**The automatic install is NOT.** Three variants, all negative:

| Variant | Project settings | Marketplace pre-added | Trust flag | `plugin list --json` |
|---|---|---|---|---|
| A | `enabledPlugins` only | no | no | `[]` |
| B | `enabledPlugins` only | yes | no | `[]` |
| C | `enabledPlugins` only | yes | `hasTrustDialogAccepted: true` | `[]` |
| D | `enabledPlugins` + `extraKnownMarketplaces` | (in-file) | `hasTrustDialogAccepted: true` | `[]` |
| E | `enabledPlugins` for `unreal-engine-skills@anthropic-plugin-directory` | built-in, always present | `hasTrustDialogAccepted: true` | `[]` |

Variant E is the sharpest control: the marketplace is *built in*, so it needs
no registration, and the trust flag is pre-accepted — and still nothing
installs. A malformed `settings.json` behaves identically (`[]`), consistent
with the CLI help note that "Settings files that fail validation are silently
ignored in this mode".

**Why NOT-REPRODUCIBLE, precisely.** The README describes an *interactive
prompt* ("prompted to install it automatically"). This seat can only drive the
CLI non-interactively: every attempt to reach an interactive session dies at
`Not logged in · Please run /login` (`claude`, `claude -p`, and
`printf "y\n" | claude` all return that). The prompt itself is therefore
**unproven-runtime** — not shown to work, and not shown to fail. What *is*
established is that no non-interactive code path auto-installs from
`enabledPlugins`, so a scripted/bootstrap flow (the lane's actual use) cannot
rely on the team flow as written.

One related gate, worth recording because it defeats naive provisioning: the
marketplace name is reserved.

```
$ claude plugin marketplace add /tmp/mktprobe   # a local clone of the marketplace
✘ Failed to add marketplace: The name 'claude-plugins-official' is reserved for official
  Anthropic marketplaces and can only be used with GitHub sources from the 'anthropics' organization.
```

And the plugin repo itself is not a marketplace:

```
$ claude plugin marketplace add /tmp/ue-skills-ref
✘ Failed to add marketplace: Marketplace file not found at /tmp/ue-skills-ref/.claude-plugin/marketplace.json
$ claude plugin install /tmp/ue-skills-ref --json
{"outcome":"failed","failureCode":"not_found","message":"Plugin \"/tmp/ue-skills-ref\" not found in any configured marketplace"}
```

So there is no local-directory install route for this plugin. `--plugin-dir`
exists but is session-only and needs an authenticated session
(`claude --plugin-dir /tmp/ue-skills-ref -p "hi"` → `Not logged in`).

## 7. `ModelContextProtocol.GenerateClientConfig ClaudeCode` — NOT-REPRODUCIBLE

`README.md:72` and `setup.md:57-81` make this the *preferred* way to produce
`.mcp.json`, with a hand-write fallback. This host cannot run the preferred
path:

```
$ command -v UnrealEditor
(not found)
$ git ls-remote https://github.com/EpicGames/UnrealEngine
remote: Repository not found.
fatal: repository 'https://github.com/EpicGames/UnrealEngine/' not found
```

No editor binary, no engine source, no `unreal_mcp_proxy` binary
(`find / -name "unreal_mcp_proxy*"` → nothing), and nothing listening on 8000
(`ss -ltn | grep -c ":8000"` → 0). The command is an editor-console command, so
it is **NOT-REPRODUCIBLE** on this host by construction — the same conclusion
the round brief states as a standing constraint, re-derived here rather than
assumed.

### 7.1 The hand-write fallback IS reproducible — and Claude Code really parses it

`setup.md:68-79` gives the editor-free fallback. Written to
`/tmp/mcpprobe/.mcp.json`:

```json
{"mcpServers": {"unreal-mcp": {"type": "http", "url": "http://127.0.0.1:8000/mcp"}}}
```

Claude Code read it:

```
$ claude mcp list
Checking MCP server health…
unreal-mcp: http://127.0.0.1:8000/mcp (HTTP) - ⏸ Pending approval (run `claude` to approve)
```

The entry is discovered and typed correctly — the config *format* is confirmed
against a real client. The server is of course unreachable (no editor), so this
proves config parsing only, **not** connectivity. `claude mcp add --transport
http unreal-mcp-2 …` likewise registered, then reported the honest failure:

```
unreal-mcp-2: http://127.0.0.1:8000/mcp (HTTP) - ✘ Failed to connect — ECONNREFUSED
```

That `ECONNREFUSED` is the expected receipt on a host with no editor, and it
demonstrates the client's own health check works. Note `--mcp-config` is **not**
a valid top-level flag on 2.1.302 (`error: unknown option '--mcp-config'`),
though it is accepted via `--settings`; the setup.md instructions do not use it,
so this is a side observation only.

## 8. Hook step — REPRODUCIBLE-HERE as a behavior, not as Claude wiring

`hooks/unreal-context.sh` is registered as a `SessionStart` command hook
(`hooks/hooks.json`, valid JSON, `timeout: 5`). Run directly:

```
$ shellcheck -s bash hooks/unreal-context.sh      → exit 0 (no findings)
$ bash -n hooks/unreal-context.sh                 → exit 0
```

Behavioral probes, all exit 0:

| CWD | Emitted `additionalContext` (abridged) |
|---|---|
| `/tmp` (no project) | *(no output — correct no-op)* |
| `/tmp/fakeue` (`MyGame.uproject`) | `…The project is \`MyGame.uproject\`. … No \`.mcp.json\` is present …` |
| `/tmp/fakeue2` (`.uproject` + `.mcp.json`) | `…An \`.mcp.json\` is already present at the project root.` |
| `/tmp/fakeue2/Source/MyGame` | same as above — upward walk from a subdirectory works |
| `/tmp/fakeeng` (`GenerateProjectFiles.sh`) | `…Prefer Unreal Engine conventions…` (engine-tree marker) |

All five outputs are well-formed single-line JSON with correctly escaped
payload. The script's behavior is **REPRODUCIBLE-HERE**. Whether Claude Code
actually invokes it on `startup|resume|clear` is a harness-level claim this seat
did **not** exercise (it requires an authenticated interactive session), so the
*wiring* stays **unproven-runtime**.

## 9. Calibration — what the upstream docs get right and wrong

Adaptation table for this lane's substrate (Kimi Code CLI, not Claude Code).
Every row carries the command that produced it.

| # | Upstream statement | Location | Measured reality on this host | Status |
|---|---|---|---|---|
| 1 | Marketplace "available automatically when you start Claude Code" | `README.md:32` | fresh HOME lists only `anthropic-plugin-directory`; documented id install → `not_found` | **WRONG** (2.1.302) |
| 2 | `marketplace add anthropics/claude-plugins-official` | `README.md:45` | succeeds verbatim | correct |
| 3 | `/plugin install <id>@claude-plugins-official` | `README.md:39` | succeeds after step 2; `outcome:"ok"` | correct, order-dependent |
| 4 | `.claude/settings.json` `enabledPlugins` block | `README.md:52-58` | byte-for-byte what `-s project` writes | schema correct |
| 5 | Team members "prompted to install it automatically" | `README.md:50` | no non-interactive path installs it; interactive prompt unreachable (not logged in) | **unproven-runtime** |
| 6 | Plugin ships no static `.mcp.json` | `README.md:72` | `MCP servers (0)`; `.claude-plugin/` has only `plugin.json` | correct |
| 7 | Hand-written `.mcp.json` shape | `setup.md:68-79` | parsed by `claude mcp list` as HTTP `127.0.0.1:8000/mcp` | correct |
| 8 | `GenerateClientConfig ClaudeCode` is the preferred path | `setup.md:61` | editor absent; engine repo inaccessible | **NOT-REPRODUCIBLE** |
| 9 | `.uproject` plugin enable + `bAutoStartServer` ini + `StartServer` | `setup.md:12-55` | all editor-side; no editor | **NOT-REPRODUCIBLE** |
| 10 | Optional proxy `unreal_mcp_proxy … install` | `setup.md:83-121` | no binary on host | **NOT-REPRODUCIBLE** |
| 11 | Hook runs via `bash ${CLAUDE_PLUGIN_ROOT}/hooks/unreal-context.sh` | `hooks/hooks.json` | script valid and behaves correctly when invoked directly | script correct; wiring unproven |
| 12 | AUR `unreal-engine` needs SSH access to the private Epic repo | round brief (host receipt) | re-derived verbatim: PKGBUILD line 280 `if ! git ls-remote git@github.com:EpicGames/UnrealEngine &>/dev/null; then` … `error 'You must register at unrealengine.com and link your github account…'` | correct |
| 13 | Epic engine repo is private to this account | round brief (host receipt) | `git ls-remote` → `Repository not found.` | correct |

### 9.1 Adaptation to the Kimi substrate

The plugin is Claude-Code-shaped (`.claude-plugin/plugin.json`, `enabledPlugins`,
`/plugin`, `CLAUDE_PLUGIN_ROOT`). On the Kimi host the analogues are
`~/.kimi-code/plugins/installed.json` and `~/.kimi-code/skills/`, and **there is
no plugin-marketplace CLI**:

```
$ kimi mcp list
unknown command 'mcp'. See 'kimi --help'.
```

`kimi --help` exposes no `plugin`/`mcp` subcommand group (commands are
`export`, `fork`, `provider`, `session`, `acp`, `web`, `server`, `rc`, `login`,
`doctor`, `vis`, …). Kimi MCP servers are declared in
`~/.kimi-code/config.toml` under `[mcp_servers.<name>]` (one such server, `rea`,
is configured there). The **only** Kimi-native route for the *content* is
`--skills-dir`, which works:

```
$ kimi --skills-dir /tmp/ue-skills-ref/skills -p "Reply with exactly: PROBE_OK"
• PROBE_OK
```

So: the three skill bodies load on Kimi through `--skills-dir`; the Claude
marketplace/plugin machinery does not transfer, and `hooks/unreal-context.sh`
has no Kimi equivalent (Kimi's skills dir carries no hooks). Note
`--skills-dir` loads the 3 skills only — the hook and the plugin manifest are
inert on Kimi.

### 9.2 Verification policy (proven / unproven) for this lane

- **proven-here** requires a receipt from a real command on this host whose
  output decides the claim. Labels used in this file: REPRODUCIBLE-HERE /
  NOT-REPRODUCIBLE, each with the deciding command inline.
- **unproven-runtime** is the mandatory label for anything needing a live
  Unreal Editor, an authenticated interactive Claude session, or a reachable
  MCP endpoint. This seat asserts none of those. Specifically still
  unproven-runtime: editor-side setup (§7), the team-flow auto-install prompt
  (§6), hook wiring (§8), and any tool call through `unreal-mcp`.
- A successful *config* parse never implies connectivity. `.mcp.json` parsing
  (§7.1) and `MCP servers (0)` (§4.2) are static/config facts; the
  `ECONNREFUSED` and `Pending approval` states are the correct labels for the
  runtime half.

## 10. Reproduction recipe (all steps, verified)

```bash
# isolated HOME — the operator's config is never touched
export HOME=$(mktemp -d)

# route A (zero prerequisites, uses the built-in directory)
claude plugin install unreal-engine-skills@anthropic-plugin-directory --json

# route B (the README's, order matters)
claude plugin marketplace add anthropics/claude-plugins-official
claude plugin install unreal-engine-skills-for-claude-code@claude-plugins-official --json

# route C (one command, undocumented upstream)
claude plugin install unreal-engine-skills-for-claude-code --marketplace anthropics/claude-plugins-official --json

claude plugin list          # → v3.1.1, Status: ✔ enabled
claude plugin details <id>  # → Skills (3), Hooks (1), MCP servers (0)
```

## 11. Limitations

- The **team-flow auto-install prompt is untested**, not disproven: this seat
  cannot reach an authenticated interactive session (`Not logged in · Please
  run /login` on every non-interactive invocation). Only the non-interactive
  absence of auto-install is established (§6, variants A–E).
- `anthropic-plugin-directory` is Anthropic's built-in directory. Its listing of
  `unreal-engine-skills` at the pinned SHA is observed; whether that listing is
  curated by Epic or mirrors the GitHub catalog is **not** established here.
- Marketplace contents move. The catalog was read 2026-10-18
  (`anthropics/claude-plugins-official` HEAD `ea10b213…`, `pushedAt`
  2026-10-18T17:04:56Z); every claim above is pinned to the observed catalog and
  the SHA `a6aa73a`.
- No live-editor, proxy, or MCP-tool claim is made anywhere in this file.
