# r101 SEAT-23 PROBE — prerequisites matrix: `references/setup.md` vs this host

Lane: g3d shokunin · upstream `EpicGames/unreal-engine-skills-for-claude-code-plugin`
pinned **`a6aa73ada02a9fb1f5415bec491f9942c519b297`** ("[MCP] Permit safe
concurrent tool calls", 2026-09-17 13:28:32 +1200), tree
`b5b9624b00fc90217240e823406699d0ab78b959`.

Seat task: enumerate every prerequisite asserted by
`skills/unreal-mcp/references/setup.md` (plus the `Prerequisites` section of
`README.md`, which is the same set stated at one level of abstraction up) and
label each row against **this host's measured state** as exactly one of
`PRESENT` | `MISSING` | `OPERATOR-WALL`.

Confidence: **[O]** receipt-pinned observation (command + output below),
**[I]** inference from an observation, **[?]** unknown / not measurable here.

---

## 0. Method and provenance

Clone verified before use, per seat instructions:

```
$ git -C /tmp/ue-skills-ref rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
$ git -C /tmp/ue-skills-ref status --porcelain      # (empty output)
$ git -C /tmp/ue-skills-ref rev-parse HEAD^{tree}
b5b9624b00fc90217240e823406699d0ab78b959
```

Clone matches the pinned SHA, worktree clean. The local corpus copy is
byte-identical to that clone, so every source pointer below is also a pointer
into `corpus/knowledge/unreal-mcp/upstream/`:

```
$ diff -r --brief /tmp/ue-skills-ref corpus/knowledge/unreal-mcp/upstream -x .git
                                                      # (no output, rc=0)
```

Source surface read in full (11 files, the whole repo minus `.git`):

```
$ find /tmp/ue-skills-ref -path ./.git -prune -o -type f -print | sort
./.claude-plugin/plugin.json
./CODEOWNERS
./.gitignore
./hooks/hooks.json
./hooks/unreal-context.sh
./LICENSE
./README.md
./skills/create-toolset/SKILL.md
./skills/unreal-mcp/references/operations.md
./skills/unreal-mcp/references/setup.md      <- primary source for this matrix
./skills/unreal-mcp/SKILL.md
./skills/unreal-skill/SKILL.md
```

**Label semantics used here.** A row is `PRESENT` only when a command run on
this host returned evidence of it. A row is `MISSING` when it is measured absent
*and* a purely local action could still satisfy it. A row is `OPERATOR-WALL`
when no local action can satisfy it — it needs an operator-held identity
(Epic account / GitHub link), an Epic-owned login, or an interactive GUI
editor session. Where a row is both absent and walled, the label is
`OPERATOR-WALL` and the measured-absent evidence is still shown, because the
wall is the binding constraint. Rows are numbered `A..H`; `[O]`/`[I]` as above.

Live-editor MCP runtime claims are **unproven-on-this-host by construction**
(no editor installed). Every such row is labelled, never asserted.

---

## A. Client / plugin layer (README "Installation", "Verification" step 3)

| # | Prerequisite | Source pointer | Check run | Observed | Label |
|---|---|---|---|---|---|
| A1 | Claude Code CLI, to load the plugin at all | `README.md` §Installation | `claude --version` | `2.1.302 (Claude Code)` | **PRESENT** [O] |
| A2 | Plugin installed into the client (`/plugin install unreal-engine-skills-for-claude-code@claude-plugins-official`) | `README.md` §Install for a single developer | `ls ~/.claude/plugins` | `No such file or directory`; `~/.claude/` holds only `agents backups skills` | **MISSING** [O] — installable locally, public marketplace |
| A3 | Marketplace `claude-plugins-official` registered | `README.md` §Install for a single developer | `ls ~/.claude/`; no marketplace cache present | only `agents`, `backups`, `skills` | **MISSING** [O] — needs one interactive `/plugin marketplace add` |
| A4 | Upstream skill bodies available locally to read/port | `skills/*/SKILL.md` | `head -1` on all 3 → all open `---` (frontmatter intact); files vendored under `corpus/knowledge/unreal-mcp/upstream/skills/` | 3/3 present with `name:`/`description:` frontmatter | **PRESENT** [O] — source-side only; *loaded* into a session is A2 |

## B. Shell / hook prerequisites (README "Prerequisites" 3, "Platform Support")

| # | Prerequisite | Source pointer | Check run | Observed | Label |
|---|---|---|---|---|---|
| B1 | A working `bash` on `PATH` (hook is invoked as `bash ${CLAUDE_PLUGIN_ROOT}/hooks/unreal-context.sh`) | `README.md` §Prerequisites 3, §Platform Support; `hooks/hooks.json` | `command -v bash`; `bash --version \| head -1` | `/usr/bin/bash`; `GNU bash, version 5.3.15(1)-release (x86_64-pc-linux-gnu)` | **PRESENT** [O] |
| B2 | The hook script actually runs under that bash | `hooks/unreal-context.sh` | executed it directly, all 4 branches + `shellcheck -S warning` | see §B.1 below — 4/4 branches behave as documented, `shellcheck rc=0` | **PRESENT** [O] — *the only upstream artifact executable on this host* |
| B3 | `CLAUDE_PLUGIN_ROOT` set at hook time | `hooks/hooks.json` command string | `env \| grep -i claude` | unset in this shell; `~/.claude/` has no plugin install to define it | **MISSING** [O] — harness-supplied; arrives only with A2 |
| B4 | (probe tooling) `jq`, used here to parse hook output | — (not an upstream requirement) | `jq --version` | `jq-1.8.2` | **PRESENT** [O] |

### B.1 Hook executability probe — the one verified-here artifact

Fixture built under `/tmp/seat23-probe/` (outside the repo). Four branches
driven, all matching the script's documented behaviour:

```
$ cd /tmp/seat23-probe/MyGame/Source   # project root one level up, has MyGame.uproject
$ CLAUDE_PLUGIN_ROOT=/tmp/ue-skills-ref bash /tmp/ue-skills-ref/hooks/unreal-context.sh
{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"This working
 directory is an Unreal Engine project. The project is `MyGame.uproject`. Prefer Unreal
 Engine conventions (C++/UObject patterns, Slate, UHT reflection) when suggesting code.
 Use the `unreal-mcp` skill for tasks that involve driving the Unreal Editor via MCP.
 No `.mcp.json` is present at the project root yet. Run
 `ModelContextProtocol.GenerateClientConfig ClaudeCode` in the editor console to
 generate one."}}
rc=0

$ bash /tmp/ue-skills-ref/hooks/unreal-context.sh | jq -r '.hookSpecificOutput.additionalContext'
   # ...same string -> output is valid JSON [O]

$ cd /tmp/seat23-probe/MyGame   # .mcp.json now written
$ bash .../unreal-context.sh | jq -r ...
   # ... "An `.mcp.json` is already present at the project root."   <- present-branch [O]

$ cd /tmp/seat23-probe/EngineTree/Engine/Source   # GenerateProjectFiles.sh + Engine/
$ bash .../unreal-context.sh | jq -r ...
   # ... "It is an Engine source tree."                            <- engine-branch [O]

$ cd /tmp && bash .../unreal-context.sh ; echo rc=$?
rc=0                                   # no marker found -> silent, exit 0 [O]

$ CLAUDE_UE_HOOK_DEBUG=1 bash .../unreal-context.sh 2>&1 >/dev/null | head -1
unreal-context.sh: project root: /tmp/seat23-probe/MyGame (type=game,
 uproject=MyGame.uproject, mcp_json=true)                              # debug path [O]

$ shellcheck -S warning /tmp/ue-skills-ref/hooks/unreal-context.sh ; echo "shellcheck rc=$?"
shellcheck rc=0                                                        # clean [O]
```

The upward walk from `Source/` to the project root, the `Engine/`-tree
disambiguation (the script's own comment about `Engine/Source/Runtime/Engine`
not being a root marker), the `mcp_json` signal, the no-project silent path and
the `CLAUDE_UE_HOOK_DEBUG` channel are all confirmed against live output, not
against the source comments.

## C. Engine layer (README "Prerequisites" 1; setup.md §4)

| # | Prerequisite | Source pointer | Check run | Observed | Label |
|---|---|---|---|---|---|
| C1 | **Unreal Editor** installed | `README.md` §Prerequisites 1 | `which UnrealEditor UnrealEditor-Cmd`; `ls -d /opt/unreal* /usr/share/unreal* ~/UnrealEngine ~/Epic*`; `find / -xdev -maxdepth 6 -name 'UnrealEditor*' -type f` | `no UnrealEditor in (...)`; all `No such file or directory`; `find` → empty | **MISSING** [O] — remedy is G3, i.e. walled |
| C2 | `ModelContextProtocol` plugin on disk | `setup.md:14`, `README.md` §Prerequisites 1 | `find / -xdev -type d -name ModelContextProtocol` | empty | **MISSING** [O] — ships with the engine (C1) |
| C3 | `AllToolsets` plugin on disk (`EnabledByDefault` off, must be enabled explicitly) | `setup.md:31` | `find / -xdev -type d -name AllToolsets` | empty | **MISSING** [O] — ships with the engine (C1) |
| C4 | Engine Python stub `Intermediate/PythonStub/unreal.py` (needed by the `create-toolset` path) | `skills/create-toolset/SKILL.md` §Choose the implementation language | `test -e ~/Intermediate/PythonStub/unreal.py` | `ABSENT` | **MISSING** [O] — project-scoped, arrives with D1 |
| C5 | `import unreal` works in a host interpreter | `skills/create-toolset/SKILL.md` §Python Specifics | `python3 -c "import unreal"` | `ModuleNotFoundError: No module named 'unreal'` | **MISSING** [O] — expected: `unreal` exists only inside the editor process |
| C6 | ToolsetRegistry reload helper `.../toolset_registry/tests/reload_remote.py` | `skills/create-toolset/SKILL.md` §Python Specifics; `skills/unreal-skill/SKILL.md` §Reloading | `test -e` | `ABSENT` | **MISSING** [O] |
| C7 | An Unreal project file (`*.uproject`) to configure | `setup.md:10` ("Confirm the file path first"), `setup.md:16` | `find /home/vgpnk -maxdepth 5 -name '*.uproject'` | empty | **MISSING** [O] |

## D. Project config layer (setup.md steps 1–2)

| # | Prerequisite | Source pointer | Check run | Observed | Label |
|---|---|---|---|---|---|
| D1 | `.uproject` `Plugins` array containing `{"Name":"ModelContextProtocol","Enabled":true}` (create the array if absent, flip `false`→`true` if present) | `setup.md:12-29` | no `.uproject` exists (C7) → nothing to edit | n/a | **MISSING** [O] — blocked on C7/C1 |
| D2 | Same array containing `{"Name":"AllToolsets","Enabled":true}` | `setup.md:16-31` | as D1 | n/a | **MISSING** [O] — blocked on C7/C1 |
| D3 | Auto-start snippet in `<Project>/Saved/Config/<Platform>Editor/EditorPerProjectUserSettings.ini`: `[/Script/ModelContextProtocolEngine.ModelContextProtocolSettings]` + `bAutoStartServer=True` (per-user, not source-controlled) | `setup.md:37-46` | no project exists → no `Saved/Config/` path; `find ~ -name 'EditorPerProjectUserSettings.ini'` not attempted — path is under C7 | n/a | **MISSING** [O] — blocked on C7/C1 |
| D4 | Default MCP port `8000` free on loopback (so the default `ServerPortNumber`/`ServerUrlPath=/mcp` need no override) | `setup.md:48-53`, `operations.md` §Troubleshooting ("Failed to listen on port") | `ss -ltnp \| grep :8000` (rc=1, no match); then `python3 -c "socket.bind(('127.0.0.1',8000))"` | `bind 127.0.0.1:8000 OK` | **PRESENT** [O] — nothing is listening, and the port is bindable |

## E. Client config layer (setup.md step 3)

| # | Prerequisite | Source pointer | Check run | Observed | Label |
|---|---|---|---|---|---|
| E1 | `.mcp.json` at the project root (source build) or next to the `.uproject` (installed build), containing `mcpServers.unreal-mcp` `{type: http, url: http://127.0.0.1:8000/mcp}` | `setup.md:57-81` | `find /home/vgpnk -maxdepth 4 -name '.mcp.json'` | only `/home/vgpnk/.grok/installed-plugins/...` — none for any Unreal project | **MISSING** [O] — blocked on C7/C1 |
| E2 | Preferred generator: console command `ModelContextProtocol.GenerateClientConfig ClaudeCode` from a running editor | `setup.md:61-66` | requires a live editor process | — | **OPERATOR-WALL** [O] — editor GUI session is operator-run |
| E3 | Fallback: hand-write `.mcp.json` without launching the editor (documents a "fresh-project bootstrap" path) | `setup.md:68-81` | file format is plain JSON, writable anywhere; but the destination depends on the build kind, which depends on C1/C7 | n/a | **MISSING** [O] — no editor-free blocker in the *writing*, only in knowing the root |
| E4 | MCP endpoint live at `http://127.0.0.1:8000/mcp` | `setup.md:123-131` §Verifying | `ss -ltnp \| grep :8000` → rc=1 | nothing listening | **OPERATOR-WALL** [O] — needs the editor running with the server started |

## F. Optional proxy (setup.md step 4)

| # | Prerequisite | Source pointer | Check run | Observed | Label |
|---|---|---|---|---|---|
| F1 | Engine ships `Engine/Plugins/Experimental/ModelContextProtocol/Extras/Proxy` | `setup.md:87` | `test -e ~/Engine/Plugins/Experimental/ModelContextProtocol/Extras/Proxy` | `ABSENT` | **MISSING** [O] — the doc's own fallback applies: "If it is absent, keep the direct HTTP setup" |
| F2 | Platform binary — this host is `x86_64`, so `Bin/Linux/unreal_mcp_proxy` | `setup.md:89-96`; `uname -m` → `x86_64` | `find / -xdev -name 'unreal_mcp_proxy*'` | empty | **MISSING** [O] |
| F3 | `unreal_mcp_proxy --mcp-json <path> install` / `uninstall` | `setup.md:98-121` | cannot invoke — binary absent (F2) | — | **MISSING** [O] — optional feature; direct HTTP path is the documented fallback |

## G. Engine acquisition on this host — the binding constraint

The matrix above bottoms out at C1. These rows measure whether C1 is reachable
from this host at all.

| # | Prerequisite | Source pointer | Check run | Observed | Label |
|---|---|---|---|---|---|
| G1 | An AUR recipe for the engine exists (`unreal-engine`) | round context; AUR | `yay -Gp unreal-engine`; AUR RPC `info?arg[]=unreal-engine` | recipe fetched; RPC `resultcount:1`, `Name: unreal-engine`, maintainer `alexbelm48`, 75 votes | **PRESENT** [O] — a *recipe*, not the engine |
| G2 | Engine in official repos | — | `pacman -Si unreal-engine` | `error: package 'unreal-engine' was not found` | **MISSING** [O] — AUR-only, confirming G1 is the only route |
| G3 | **Epic Games ↔ GitHub account link** (access to the private engine repo) | AUR `PKGBUILD` line 280 | `git ls-remote git@github.com:EpicGames/UnrealEngine.git`; `gh api repos/EpicGames/UnrealEngine` | `git@github.com: Permission denied (publickey).` / `fatal: Could not read from remote repository.`; `gh: Not Found (HTTP 404)`; `gh auth status` → logged in as `VeigaPunk`, not Epic-linked | **OPERATOR-WALL** [O] — the PKGBUILD itself gates on exactly this, and aborts with "You must register at unrealengine.com and link your github account to access this private repo" |
| G4a | AUR `depends` satisfied except one: `sdl3 python dotnet-runtime vulkan-icd-loader lld xdg-user-dirs dos2unix openssl steam coreutils findutils`, plus `makedepends git openssh sed grep glibc wget rsync` | AUR `PKGBUILD` lines 18-19 | `pacman -Q` per package (16/16) | all reported installed, e.g. `sdl3 3.4.16-1`, `python 3.14.7-1`, `dotnet-runtime-10.0 10.0.11.sdk111-1`, `vulkan-icd-loader 1.4.357.0-1`, `lld 22.1.8-1`, `steam 1.0.0.87-3`, `git 2.55.0`, `openssh 10.5p1-1` | **PRESENT** [O] |
| G4b | `dotnet-sdk` (in that same `depends` list) | AUR `PKGBUILD` line 19 | `pacman -Q dotnet-sdk`; `dotnet --list-sdks` | `NOT-INSTALLED`; `--list-sdks` empty (`dotnet-host` + `dotnet-runtime-10.0` only; runtimes 9.0.19 and 10.0.11 present) | **MISSING** [O] — installable from official repos, no wall |
| G5 | GPU + Vulkan ICDs for an editor that must render | `setup.md` (editor is a GUI app); README §Security implies live editor | `which vulkaninfo`; `ls /usr/share/vulkan/icd.d/`; `lspci \| grep -i vga` | `/usr/bin/vulkaninfo`; `lvp_icd.json nvidia_icd.json radeon_icd.json`; `NVIDIA GB205 [GeForce RTX 5070]`, `AMD Granite Ridge [Radeon Graphics]` | **PRESENT** [O] |
| G6 | Alternative launcher route (Lutris + Epic Games Store login) | round context | `pacman -Si lutris`; `pacman -Qi lutris` | repo `extra`, `Version 0.5.22-3`, "Open Gaming Platform"; `-Qi` → `error: package 'lutris' was not found` (not installed) | **MISSING** [O] — one `pacman -S lutris` away |
| G7 | Epic Games Store account login (Lutris route) | round context | — | — | **OPERATOR-WALL** [O] — operator-owned credential |
| G8 | Host arch / capacity for an engine build | AUR `arch=`; round context | `uname -m`; `nproc`; `free -h`; `df -h /` | `x86_64` (AUR also lists `x86_64_v2/v3/v4`, `aarch64`); 32 cores; 30 GiB RAM (15 GiB available); `/dev/mapper/root 930G … 780G avail (15%)` | **PRESENT** [O] |

## H. Verification gates (setup.md §Verifying, README §Verification)

All four rows need a live editor; none is assertible here.

| # | Prerequisite | Source pointer | Check run | Observed | Label |
|---|---|---|---|---|---|
| H1 | Output Log shows MCP server startup messages | `setup.md:127`; `README.md` §Verification 2 | needs a running editor | — | **OPERATOR-WALL** [O] |
| H2 | `list_toolsets` (one of the three meta-tools) returns successfully | `setup.md:128`; `skills/unreal-mcp/SKILL.md` | needs a live MCP connection (E4) | — | **OPERATOR-WALL** [O] |
| H3 | `/mcp` in Claude Code lists `unreal-mcp` (or `unreal-mcp-proxy`) as connected | `setup.md:129`; `README.md` §Verification 4 | needs A2 + E4 | — | **OPERATOR-WALL** [O] |
| H4 | A successful **read-only Unreal tool call** — the doc's own bar for proving Unreal is reachable (a connected proxy or cached tools do *not* prove it) | `setup.md:131`; `README.md` §Verification 4-5; `operations.md` §Proxy recovery | needs a running editor | — | **OPERATOR-WALL** [O] — this is exactly the claim this round must never assert |

---

## I. Tally and the shape of the wall

Row counts, measured:

| Label | Rows | Count |
|---|---|---|
| **PRESENT** | A1, A4, B1, B2, B4, D4, G1, G4a, G5, G8 | **10** |
| **MISSING** | A2, A3, B3, C1–C7, D1–D3, E1, E3, F1–F3, G2, G4b, G6 | **21** |
| **OPERATOR-WALL** | E2, E4, G3, G7, H1–H4 | **8** |
| **Total** | | **39** |

Three readings that matter for the coverage/depth/calibration axes:

1. **The host is a clean client, not a clean editor.** Every prerequisite that
   lives on the *client* side of the MCP boundary is already satisfied: bash
   5.3.15, Claude Code 2.1.302, git, jq, 32 cores, a Vulkan-capable GPU, and
   port 8000 free and bindable. What is missing is entirely the *editor* side.
2. **The wall is a single row, G3.** C1 (no editor) is the direct cause of 21
   `MISSING` rows, but C1 itself is not independently actionable: G2 rules out
   the official repos, and G3 rules out the AUR route with a real authentication
   failure (`Permission denied (publickey)` / HTTP 404), matching the PKGBUILD's
   own abort message at line 280. G4b (`dotnet-sdk`) and G6 (`lutris`) are the
   only two `MISSING` rows that are one local package install each — and neither
   is the binding constraint.
3. **The only thing actually executable from this upstream on this host is the
   SessionStart hook** — and it was executed, in all four branches, with a clean
   `shellcheck`. That is the sole `verified-here` artifact the setup path
   offers a host without an editor; everything downstream of `.uproject`
   (D1–D3, E1–E4, F1–F3, H1–H4) is either blocked or walled by construction.

## J. Reproduction

Everything above is re-runnable; no repo state was mutated. The only writes were
this report and a scratch fixture under `/tmp/seat23-probe/` (a synthetic
`MyGame.uproject`, a `.mcp.json`, and an `EngineTree/` with
`GenerateProjectFiles.sh`, used to drive the hook's branches). No commit, no
`LOG.md`/`SCORECARD.md`/`SHONEN.md`/`SKILL.md`/`PROVINCE.md` touch, no edit to
the three pre-existing `reports/round-101/` files.
