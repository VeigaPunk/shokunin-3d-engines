# Sequencer — executability verdict card

**Seat:** SEAT-37 EXEC · **Round:** r101 · **Lane:** game-dev-3d shokunin
**Subsystem:** Sequencer (level sequences, keyframes, cameras, FBX import/export)
**Label:** `static-only`

This card answers one question only: **how far can Sequencer claims be pushed on this
host, and what receipt would move the label.** It is the Sequencer card of the subsystem
set in `corpus/knowledge/unreal-mcp/executability/`; the set is enumerated to match the
13 domain bullets in `README.md` §`What's Available` (lines 100–112), where Sequencer is
bullet 7. Peers land concurrently, so this card makes no claim about how many siblings
exist on disk — only about its own subsystem.

Confidence tags: **[O]** receipt-pinned observation, **[I]** inference from an [O],
**[?]** unknown.

---

## 1. Verdict

| Field | Value |
| --- | --- |
| Label | **`static-only`** |
| Executed on this host | **nothing** — no SequencerTools call has ever been made here |
| Evidence class | static artifact inspection of a pinned public repo, plus host-capability probes |
| Upstream surface found | **10 Sequencer-class tokens, in 3 of 12 files**, all prose |
| Parameter/return schemas found | **0** |
| Live-editor MCP runtime | unreachable on this host (not merely unproven) |

**One-line verdict [O]:** Sequencer is described upstream in prose and named exactly once
as a toolset-qualified symbol — `SequencerTools.create_level_sequence` — in a sentence that
exists to say that name is **not** in `tools/list`; no schema, signature, return type, or
argument list for any Sequencer tool appears anywhere in the pinned tree, and no editor or
MCP server exists on this host to resolve the gap. Claims are therefore capped at
`static-only`.

### 1.1 Label discipline (why not the other two)

| Candidate label | Rejected because |
| --- | --- |
| `verified-here` | Requires a SequencerTools call to have run and returned an explicit success on this host. No `unreal-mcp` server is configured (§4.1) and no editor binary exists (§4.2), so no such receipt can exist. |
| `unproven-runtime` | This label presumes the runtime path is *reachable but untested*. Here it is **blocked before the client**: the engine repo is Epic-gated (§4.3). Recording `unproven-runtime` would overstate readiness by implying only a test run is missing. |

`static-only` is the strongest label the current receipts support. The weaker residual
fact — that runtime behaviour is additionally unproven — is recorded in §6 as a bounded
note, not as the card's label.

---

## 2. Provenance

- **Upstream:** `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin`
  (public, MIT, plugin `unreal-engine-skills-for-claude-code` v3.1.1).
- **Pinned SHA:** `a6aa73ada02a9fb1f5415bec491f9942c519b297` (branch `main`).
- **Clone used:** pre-existing `/tmp/ue-skills-ref`, **verified in place** before use.

```
$ git -C /tmp/ue-skills-ref rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297

$ git -C /tmp/ue-skills-ref status --porcelain | wc -l
0

$ git -C /tmp/ue-skills-ref remote get-url origin
https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin

$ git -C /tmp/ue-skills-ref log -1 --format='%ci %s'
2026-09-17 13:28:32 +1200 [MCP] Permit safe concurrent tool calls
```

The clone matched the pin, so no fresh clone to `/tmp/r101work` was needed. **[O]**

- **Vendored tree:** `corpus/knowledge/unreal-mcp/upstream/` — 12 files, byte-identical.

```
$ cd /tmp/ue-skills-ref && for f in $(git ls-files); do sha256sum "$f"; done   # vs vendored copy
checked=12 fail=0
$ diff /tmp/up.list /tmp/vend.list && echo SET-EQUAL
SET-EQUAL

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

12/12 OK against the independently produced reference manifest **[O]**. All `path:line`
pointers in this card resolve inside `corpus/knowledge/unreal-mcp/upstream/`, which is
byte-identical to the pinned clone — so a reader can check any pointer without network
access.

---

## 3. The complete Sequencer surface in the pinned tree

Exhaustive scan, case-insensitive, over every tracked file, for
`sequencer|level sequence|keyframe|fbx`:

```
$ cd /tmp/ue-skills-ref && for f in $(git ls-files); do \
    c=$(grep -o -i "sequencer\|level sequence\|keyframe\|fbx" "$f" | wc -l); echo "$c  $f"; done | sort -rn
5  README.md
4  skills/unreal-mcp/SKILL.md
1  .claude-plugin/plugin.json
0  skills/unreal-skill/SKILL.md
0  skills/unreal-mcp/references/setup.md
0  skills/unreal-mcp/references/operations.md
0  skills/create-toolset/SKILL.md
0  LICENSE
0  hooks/unreal-context.sh
0  hooks/hooks.json
0  .gitignore
0  CODEOWNERS

$ grep -o -i "sequencer\|level sequence\|keyframe\|fbx" -r . | wc -l
10

$ grep -ril sequencer . | sort
./.claude-plugin/plugin.json
./README.md
./skills/unreal-mcp/SKILL.md
```

**[O]** 10 tokens total, concentrated in 3 files. Every occurrence, with its role:

| # | Pointer | Occurrence | Role in the artifact |
| --- | --- | --- | --- |
| 1 | `upstream/README.md:3` | `Sequencer` | plugin blurb — listed among "30+ toolsets" |
| 2 | `upstream/README.md:106` | `Sequencer` | the **only capability sentence** (§3.1) |
| 3–6 | `upstream/README.md:106` | `Level Sequences`, `keyframe`, `cameras`, `FBX` | the four advertised capability nouns |
| 7 | `upstream/.claude-plugin/plugin.json:4` | `Sequencer` | same blurb, duplicated in plugin metadata |
| 8 | `upstream/skills/unreal-mcp/SKILL.md:3` | `Sequencer` | frontmatter trigger token, and an explicit *skip* case |
| 9 | `upstream/skills/unreal-mcp/SKILL.md:8` | `Sequencer` | enumerated among "30+ toolsets" |
| 10 | `upstream/skills/unreal-mcp/SKILL.md:16` | `SequencerTools.create_level_sequence` | **the only toolset-qualified symbol** (§3.2) |

### 3.1 The capability sentence (verbatim)

`upstream/README.md:106`:

```
- **Sequencer** - create and edit Level Sequences, keyframe animation, manage cameras, Control Rig integration, FBX import/export
```

Decomposed into advertised capabilities, each with what the source actually supplies:

| Advertised capability | Source | What the source actually is | Argument/return schema |
| --- | --- | --- | --- |
| create Level Sequences | `README.md:106` | prose verb | **none** |
| edit Level Sequences | `README.md:106` | prose verb | **none** |
| keyframe animation | `README.md:106` | prose noun phrase | **none** |
| manage cameras | `README.md:106` | prose verb | **none** |
| Control Rig integration | `README.md:106` | prose noun phrase | **none** |
| FBX import/export | `README.md:106` | prose noun phrase | **none** |

**[O]** Six capabilities, zero schemas. The sentence is a feature list for a human
choosing whether to install the plugin; it is not an interface description.

### 3.2 The one named symbol, and what it actually says

`upstream/skills/unreal-mcp/SKILL.md:16` (444 characters, the longest Sequencer-bearing
line in the tree) reads, in the part that matters:

> Tool names like `BlueprintTools.create` or `SequencerTools.create_level_sequence` are
> **not in `tools/list`**. They are dispatched server-side through `call_tool` and never
> registered as native MCP tools.

**[O]** This is the sole toolset-qualified Sequencer symbol in the entire pinned tree. Its
rhetorical purpose is to *name a thing the client cannot see*. It is evidence that a
`SequencerTools` toolset plausibly exists server-side **[I]**; it is not evidence of any
particular tool's existence, arity, or behaviour.

This is a design property, not an upstream omission. The plugin is discovery-first by
construction: `upstream/skills/unreal-mcp/SKILL.md:20` instructs the agent to call
`describe_toolset` to "read their tool schemas", and `:21` to invoke through `call_tool`
with `toolset_name`, `tool_name`, and an `arguments` object "matching the schema you just
read". **[O]** The schemas live in the running editor's `ToolsetRegistry` at runtime, and
are deliberately absent from the repository.

### 3.3 What is *not* in the tree

Grepped and confirmed absent **[O]**:

- any `SequencerTools` reference outside `SKILL.md:16` (one hit total, `grep -rn SequencerTools .`);
- any keyframe, camera-rig, or FBX argument name, type, default, or enum;
- any `.uasset`, `.umap`, `.uproject`, or level-sequence sample;
- any Sequencer entry in `references/setup.md` or `references/operations.md` (0 tokens each) —
  including in the troubleshooting matrix at `operations.md:44–51`, which names
  `NiagaraTools`, `LiveCodingToolset`, and `AIAssistantToolset` but never `SequencerTools`;
- any test, fixture, or automation-test covering a Sequencer path.

---

## 4. Why `verified-here` is impossible on this host

Three independent blockers. Any one is sufficient; all three are present.

### 4.1 No MCP server is configured — the client cannot even address Sequencer

```
$ claude mcp list
No MCP servers configured. Use `claude mcp add` to add a server.

$ jq -r '.mcpServers|keys[]?' /home/vgpnk/.kimi-code/mcp.json
cli-agents

$ grep -c "unreal-mcp" /home/vgpnk/.claude.json /home/vgpnk/.kimi-code/mcp.json
/home/vgpnk/.claude.json:0
/home/vgpnk/.kimi-code/mcp.json:0

$ find /home/vgpnk -maxdepth 3 -name ".mcp.json"
(no output)

$ ls -la /home/vgpnk/.claude/plugins/data/unreal-engine-skills-for-claude-code-inline/
total 0
```

**[O]** Neither `unreal-mcp` nor `unreal-mcp-proxy` appears in any client configuration;
no `.mcp.json` exists anywhere under `$HOME`; the plugin's Claude-side data directory is
empty. `setup.md:57–79` makes `.mcp.json` the mandatory connection artifact and states the
editor "does not write `.mcp.json` on its own". Without it there is no transport, so no
`list_toolsets`, no `describe_toolset SequencerTools`, and no `call_tool`. This is the
binding blocker: **even a fully installed engine would not make Sequencer reachable until
this is fixed.**

### 4.2 No Unreal Editor on the host

```
$ which UnrealEditor UnrealEditor-Cmd UE4Editor UnrealBuildTool
which: no UnrealEditor in (...)
which: no UnrealEditor-Cmd in (...)
which: no UE4Editor in (...)

$ pacman -Qs unreal | wc -l
0

$ ls -d /home/vgpnk/*/Engine /home/vgpnk/UnrealEngine
(no output)
```

**[O]** No editor binary, no engine source tree, no `unreal-*` package. `setup.md:14`
requires both `ModelContextProtocol` and `AllToolsets` enabled in a `.uproject`, and
`setup.md:24` notes `AllToolsets` "provides the tools" — with only the server plugin the
server "starts but exposes no tools". Neither plugin can be enabled without an engine.

### 4.3 The engine source is Epic-gated

```
$ git ls-remote https://github.com/EpicGames/unreal-engine.git
remote: Repository not found.
fatal: repository 'https://github.com/EpicGames/unreal-engine.git/' not found

$ gh auth status
github.com
  ✓ Logged in to github.com account VeigaPunk (keyring)
  - Token scopes: 'gist', 'read:org', 'repo', 'workflow'

$ curl -sS "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=unreal-engine" -o /tmp/ue_pkgbuild
$ sed -n '278,282p' /tmp/ue_pkgbuild
  # Check access to the repository
  if ! git ls-remote git@github.com:EpicGames/UnrealEngine &>/dev/null; then
    error 'You must register at unrealengine.com and link your github account to access this private repo. See the wiki for more info: ...'
    exit 1
```

**[O]** `pkgver=5.8.2` (PKGBUILD:11); the SSH gate at PKGBUILD:280 and the clone at
PKGBUILD:327 both target `git@github.com:EpicGames/UnrealEngine`. The GitHub token is
valid and carries `repo` scope, but the account is not Epic-linked, so the 404 is
authorisation, not a missing repo. **[I]** The AUR package cannot be built on this host
until an operator links the Epic account — a **human-owned** step, not a technical one.

### 4.4 Host capability that *is* present (and does not help)

```
$ nproc; free -g | awk 'NR==2{print $2"G RAM"}'; df -h / | awk 'NR==2{print $4" free /"}'; uname -sr
32
30G RAM
780G free /
Linux 7.2.3-arch1-3

$ pacman -Qq | grep -x "lutris\|docker"
docker
$ pacman -Ss "^lutris$"
extra/lutris 0.5.22-3
```

**[O]** 32 cores / 30G RAM / 780G free; `docker` installed; `lutris` available in `extra`
(not installed). None of this unblocks Sequencer: the editor is not a containerised
artifact, and a Lutris-based Epic-login path is operator-owned and still lands at
"engine installed" — after which §4.1 would *still* block the MCP transport.

---

## 5. Unlock condition

Ordered; each step is falsifiable with one command, and the observed output today is
recorded so the step cannot be claimed as already done.

| # | Step | Falsifiable check | Observed today | Owner |
| --- | --- | --- | --- | --- |
| U1 | Link the operator's Epic account to GitHub | `git ls-remote git@github.com:EpicGames/UnrealEngine` returns a ref list instead of `Repository not found` | fails (§4.3) | **operator** |
| U2 | Install the engine (AUR `unreal-engine` or source build) | `which UnrealEditor` resolves and `UnrealEditor --version` prints | `not found` (§4.2) | operator |
| U3 | Enable `ModelContextProtocol` **and** `AllToolsets` in the `.uproject`; start the server | `.uproject` shows both `"Enabled": true` (`setup.md:12–29`); editor console `ModelContextProtocol.StartServer` succeeds (`setup.md:35`); Output Log shows startup messages (`setup.md:125–127`) | no `.uproject` on host | operator/agent |
| U4 | Produce `.mcp.json` and connect a client | `claude mcp list` lists `unreal-mcp` (or `unreal-mcp-proxy`) as connected | `No MCP servers configured.` (§4.1) | agent |
| U5 | Read the real schema | `describe_toolset` on `SequencerTools` returns at least one tool, and its name is matched against the `README.md:106` capability verbs | never run | agent |
| U6 | Dispatch and require an explicit success | a `call_tool` on `SequencerTools` returns an explicit success **and** an independently observable round-trip side effect | never run | agent |
| U7 | Negative control | a deliberately invalid argument is rejected, proving the probe distinguishes success from failure | never run | agent |

**Promotion ladder** — the label changes only on these receipts:

| From | To | Minimum receipt |
| --- | --- | --- |
| `static-only` | `unproven-runtime` | U1–U4 satisfied **and** one recorded dispatch attempt, with its failure output quoted |
| `unproven-runtime` | `verified-here` | U1–U7 satisfied, each with command + observed output |

Two cautions carried from upstream, both **[O]**:

- `SKILL.md:33` — "many tools return a status that flips between success and failure with
  no exception thrown on the wire... Treat anything that isn't an explicit success as a
  stop." U6 must therefore quote the *status field*, not merely a non-error return.
- `SKILL.md:24` and `setup.md:131` — a connected proxy or a cached catalog "do not prove
  that Unreal is reachable. Confirm with a successful read-only Unreal tool call." U4 alone
  is not evidence of reachability; U5–U6 are the real gate.

---

## 6. Bounded residual facts (not the label)

Recorded so they are not mistaken for missing work:

- **Runtime behaviour is unproven. [O]** No SequencerTool has executed anywhere in this
  lane. This card does not assert that any advertised capability works, nor that it fails.
- **Toolset existence is plausible but unproven. [I]** Inferred from `SKILL.md:16` only.
  The symbol could name a tool that was renamed or removed; nothing in the pinned tree
  dates it beyond the repo HEAD of 2026-09-17.
- **`control rig integration` overlaps the Control Rig card.** `README.md:106` puts it
  under Sequencer while `README.md:105` lists Control Rigs under "Animation". Which card
  owns it is a coverage question, not an executability one.
- **`SKILL.md:3` carries a deliberate skip case** for unrelated uses of "sequencer",
  alongside "blueprint" and "widget" **[O]**. A sequencer-named *non-UE* task must not be
  routed here.

## 7. Boundaries of this card

- It does **not** claim Sequencer works, is broken, or is partially implemented.
- It does **not** claim `SequencerTools` exists as a registered toolset — only that
  upstream names it once.
- It is **not** a functional spec. The authoritative schema exists only inside a running
  editor's `ToolsetRegistry` and must be read via `describe_toolset` (U5) when reachable.
- Every pointer above resolves within `corpus/knowledge/unreal-mcp/upstream/`, verifiable
  offline with the command in §2.
