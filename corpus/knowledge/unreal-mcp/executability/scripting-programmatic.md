# Executability verdict card — Scripting (`ProgrammaticToolset.execute_tool_script`)

**Subsystem:** Scripting — the batch escape hatch that collapses N tool calls into one
arbitrary-Python execution inside the editor process.
**Verdict label: `static-only`**
**Seat:** SEAT-43 EXEC (r101) · **Upstream:** `EpicGames/unreal-engine-skills-for-claude-code-plugin`
pinned at `a6aa73ada02a9fb1f5415bec491f9942c519b297` · **Card written:** 2026-10-18

Tags: **[O]** receipt-pinned observation · **[I]** inference · **[?]** unknown.

---

## 0. One-line verdict

The Scripting surface is **documented but not parameterized**: the only thing this repo
says about it is two prose paragraphs in `README.md`, one of which is a security warning.
The tool's name, its trust boundary and its blast radius are asserted upstream; its
**schema, return contract, and even the plugin it depends on are absent from the vendored
bytes**. Nothing here can be executed on this host, so the card is `static-only` and
stays `static-only` until an editor exists (§5).

---

## 1. Label and why

**`static-only`.**

The three permitted labels are `verified-here` | `static-only` | `unproven-runtime`.
`verified-here` would require a bounded run on this host; `unproven-runtime` would
require a runtime claim that the static bytes at least *fully* specify. Neither holds:
no Unreal Editor is installed (§4), **and** the static evidence is itself incomplete
(§3) — the card cannot even enumerate the tool's parameters. `static-only` is the only
label that is true at the byte level.

Scope of the claim: every statement below is about the **vendored upstream text**, not
about Unreal Engine's behaviour. Text saying a tool exists is not a receipt that it runs.

---

## 2. Provenance of the bytes this card reads

Clone verified against the pin before use:

```
$ git -C /tmp/ue-skills-ref rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
```

Vendored tree compared byte-for-byte against that clone — **12/12 files identical**:

```
$ for f in $(cd corpus/knowledge/unreal-mcp/upstream && find . -type f | sort); do \
    a=$(sha256sum "corpus/knowledge/unreal-mcp/upstream/$f" | cut -d' ' -f1); \
    b=$(sha256sum "/tmp/ue-skills-ref/$f" | cut -d' ' -f1); \
    [ "$a" = "$b" ] && echo "OK   $f" || echo "DIFF $f $a $b"; done
OK   ./.claude-plugin/plugin.json
OK   ./CODEOWNERS
OK   ./.gitignore
OK   ./hooks/hooks.json
OK   ./hooks/unreal-context.sh
OK   ./LICENSE
OK   ./README.md
OK   ./skills/create-toolset/SKILL.md
OK   ./skills/unreal-mcp/references/operations.md
OK   ./skills/unreal-mcp/references/setup.md
OK   ./skills/unreal-mcp/SKILL.md
OK   ./skills/unreal-skill/SKILL.md
```

Plugin identity **[O]**: `.claude-plugin/plugin.json` → `"name":
"unreal-engine-skills-for-claude-code"`, `"version": "3.1.1"`, author
`thomas.mansencal@epicgames.com`, MIT. The version matters: this card describes 3.1.1 only.

All line citations below are against the vendored copy under
`corpus/knowledge/unreal-mcp/upstream/`, which is byte-identical to the clone above.

---

## 3. Static evidence — the complete upstream surface for Scripting

The entire upstream footprint of this subsystem is **two lines of `README.md`**. Both
commands below are the whole search space; there is nothing to truncate:

```
$ grep -rn "execute_tool_script" . --exclude-dir=.git
./README.md:90:**`ProgrammaticToolset.execute_tool_script` executes arbitrary Python** inside the editor process. That script has full access to every toolset API, the project on disk, the asset database, and editor-privileged functions. Treat every invocation as a privileged operation that can mutate, move, or delete project content, and expect it to succeed without a second confirmation when approvals are disabled.
./README.md:92:**`--dangerously-skip-permissions` removes the per-tool approval gate.** In that mode Claude can drive the editor and run Python through `execute_tool_script` with no further consent. A bad prompt in that mode can reach into the project and modify a large amount of state before you notice. Prefer not to run Claude Code with `--dangerously-skip-permissions` while this plugin is loaded; if you do, keep the blast radius small (narrow prompts, read-heavy tasks, a throwaway sandbox project).

$ grep -rn "ProgrammaticToolset" . --exclude-dir=.git
./README.md:90:**`ProgrammaticToolset.execute_tool_script` executes arbitrary Python** inside the editor process. ...
```

Total mentions repo-wide: **2**, both in `README.md`. The subsystem is named once more as
a capability row:

```
$ grep -rn "Scripting" . --exclude-dir=.git
./README.md:112:- **Scripting** - batch multiple tool calls into a single Python script execution
```

### 3.1 What the bytes establish **[O]**

| claim | source | strength |
|---|---|---|
| A toolset named `ProgrammaticToolset` exists | `README.md:90` | asserted by upstream text only |
| It exposes a tool named `execute_tool_script` | `README.md:90` | asserted by upstream text only |
| That tool executes **arbitrary Python** in the editor process | `README.md:90` | asserted by upstream text only |
| The executed script reaches every toolset API, the project on disk, the asset database, and editor-privileged functions | `README.md:90` | asserted by upstream text only |
| Invocations are "a privileged operation" that may mutate/move/delete project content | `README.md:90` | asserted |
| With approvals disabled, invocation proceeds **without a second confirmation** | `README.md:90` | asserted |
| `--dangerously-skip-permissions` removes the per-tool approval gate entirely | `README.md:92` | asserted |
| Scripting is one of the 13 listed capability domains | `README.md:112` | **[O]** — enumerated |

The 13-domain enumeration **[O]**, scoped to the "What's Available" block — the bare
`grep -c '^- \*\*' README.md` returns **17** because the Contents/Platform-Support bullets
share the shape, so the count must be section-scoped:

```
$ awk '/^## What.s Available/,0' README.md | grep -c '^- \*\*'
13
$ sed -n '100,112p' README.md | grep -c '^- \*\*'
13
```

The rows (lines 100–112): Actors and Scene, Blueprints, Assets and Content, Materials,
Meshes and Textures, Animation, Sequencer, VFX, UI, Gameplay, Testing, Editor, Scripting
— **13 rows**, Scripting last. This is the same 13-subsystem set the C2 claim requires
cards for; this card is the Scripting member.

### 3.2 What the bytes do NOT establish — the gaps **[?]**

These are the load-bearing absences. Each is a real search over the full clone, not an
assumption:

- **No schema.** `execute_tool_script` appears in **zero** `SKILL.md` files:
  `grep -rln "execute_tool_script" skills/` → no output (0 files). The dispatch flow that
  every other tool follows (`skills/unreal-mcp/SKILL.md:14-24`: `list_toolsets` →
  `describe_toolset` → `call_tool` with `toolset_name`/`tool_name`/`arguments`) never
  names this tool. Its parameter list is **unknown**: is the script a string argument
  named `script`? Is there a timeout, a return-serialization mode, an output cap? **[?]**
- **No return contract.** `skills/unreal-mcp/SKILL.md:33` states that many tools "return a
  status that flips between success and failure with no exception thrown on the wire."
  Whether that applies to a *Python script's* result (its stdout? a pickled value? a
  status enum?) is unstated. **[?]**
- **No dependency declaration.** `skills/unreal-mcp/references/setup.md:12-31` names
  exactly two required plugins — `ModelContextProtocol` (server/transport) and
  `AllToolsets` (the tools). Python execution is *implied* by "executes arbitrary Python"
  but **no vendored byte requires or names a Python plugin**. The sibling skill
  `skills/create-toolset/SKILL.md:36` does name an unrelated Python prerequisite —
  **Developer Mode** in `Edit → Project Settings → Plugins → Python`, needed for the
  `Intermediate/PythonStub/unreal.py` stub — but that is about *authoring* toolsets, not
  about the runtime executing a script. **Whether `execute_tool_script` works with only
  `ModelContextProtocol` + `AllToolsets` enabled is [?].** This is the single most
  consequential gap: it decides whether the Scripting domain is usable in a default setup
  or needs a third plugin.
- **No safety-net text in the skill.** `skills/unreal-mcp/SKILL.md:26-34` ("Safety rules")
  covers save-first, compilation waits, concurrent-call serialization, result checking and
  PIE — and **never mentions `execute_tool_script`**. The one place the agent is told
  Scripting exists is the README the agent is not instructed to read. **[O]** for the
  absence; the consequence is **[I]**.
- **No shipped artifact.** `find . -name '*.py' | wc -l` → **0**; `find . -name '.mcp.json' | wc -l`
  → **0**. There is no runnable harness, no example script, no `.mcp.json` to hand the
  client (setup.md:59 confirms the file is generated by the editor, not shipped). **[O]**

**Consequence [I].** A reader of the vendored bytes can learn the *risk* of
`execute_tool_script` but not its *calling convention*. The plugin's own security section
is richer than its usage documentation. Any lane attempt to write a fixture against this
tool would be guessing at the argument shape — which is exactly the state `static-only`
exists to record.

### 3.3 The trust boundary, as stated

The upstream text draws the boundary in three places and they are consistent **[O]**:

1. **Process boundary is not a boundary.** `README.md:88` — "**Localhost is not a trust
   boundary.** The MCP server binds to `localhost:8000` with origin validation. Origin
   validation protects against a browser tab talking to the server, but any process
   running as the same user on the same machine can connect."
2. **The Python tool is the widest hole.** `README.md:90` — full toolset API + project on
   disk + asset DB + editor-privileged functions, no second confirmation when approvals
   are off.
3. **The client flag removes the last gate.** `README.md:92` — `--dangerously-skip-permissions`
   turns the per-tool approval gate off, so "a bad prompt in that mode can reach into the
   project and modify a large amount of state before you notice."

For a Kimi Code seat, (3) maps to a **different flag name** — the adaptation is a C3
concern, not a C2 one, but the boundary shape (an approval gate that a client flag can
disable, in front of a tool that runs arbitrary in-process code) transfers unchanged **[I]**.

---

## 4. Host reality — why this card cannot be `verified-here`

Re-derived this seat, not inherited **[O]**:

| probe | command | observed |
|---|---|---|
| editor binary | `which UnrealEditor unreal-editor` | `no UnrealEditor in (...)` / `no unreal-editor in (...)` |
| engine install dir | `ls /opt/unreal-engine` | `No such file or directory` |
| Epic source repo | `timeout 25 git ls-remote https://github.com/EpicGames/unreal-engine.git` | `remote: Repository not found.` / `fatal: repository ... not found` |
| GitHub auth identity | `gh auth status` | logged in as `VeigaPunk`; scopes `gist, read:org, repo, workflow` — **not Epic-linked** |
| AUR build path | `curl -sL .../PKGBUILD?h=unreal-engine` → `grep -n ssh` | `PKGBUILD:280: if ! git ls-remote git@github.com:EpicGames/UnrealEngine &>/dev/null; then` → `error 'You must register at unrealengine.com and link your github account ...'` |
| AUR version | `grep -n '^pkgver' PKGBUILD` | `pkgver=5.8.2` |

The AUR route is **not** a workaround for the Epic gate: the PKGBUILD's own `prepare()`
fails hard at line 280 unless the operator's GitHub account is linked to an Epic Games
account, and lines 327/336 clone over SSH (`git@github.com:EpicGames/UnrealEngine`).
**Engine install is blocked on an operator-owned account action, not on a command this
seat can run.**

There is therefore **no path** to a live `execute_tool_script` call from this seat: the
tool lives inside the editor process (`README.md:90`), and the editor cannot be installed.
Every runtime claim about Scripting is unprovable on this host **by construction** — which
is why it is labeled, never asserted.

---

## 5. Unlock condition — what would move this card off `static-only`

The card moves when a bounded run replaces the assertions in §3.1 with receipts. Ordered,
each step independently checkable:

1. **Operator action (unblockable only by the operator).** Register at unrealengine.com
   and link the GitHub account to the Epic account, so
   `git ls-remote git@github.com:EpicGames/UnrealEngine` succeeds. Receipt: that command
   returning refs instead of the PKGBUILD's line-280 error. **This is the sole blocker
   for everything below.**
2. **Engine on disk.** Either the AUR `unreal-engine` 5.8.2-1 package or a source build.
   Receipt: an editor binary on `PATH` or at a known install root, plus its version string.
3. **Project opt-in.** A `.uproject` with both `ModelContextProtocol` and `AllToolsets`
   enabled (`setup.md:12-31`), plus `bAutoStartServer=True` in
   `Saved/Config/<Platform>Editor/EditorPerProjectUserSettings.ini` (`setup.md:33-46`).
   Receipt: the Output Log's MCP startup lines.
4. **Client config.** `.mcp.json` with `http://127.0.0.1:8000/mcp` (`setup.md:68-79`), or
   the proxy installed (`setup.md:83-121`). Receipt: `/mcp` listing the connection.
5. **Resolve §3.2 first, or measure it.** Before any script is run, settle the
   Python-plugin question: call `describe_toolset` on `ProgrammaticToolset` and record the
   real schema. Receipt: the schema text. **If the toolset is absent from
   `list_toolsets`, that is itself the answer to the dependency gap.**
6. **First bounded probe.** One read-only script (e.g. enumerate the level's actors via
   the toolset API), run with `--arm`-style bounding and a wall-clock timeout, comparing
   the result against the same query made through `call_tool` directly. Receipt: both
   outputs. **Only then** can the label move — and only to `verified-here` if the outputs
   agree, or to `unproven-runtime` if the tool is reachable but misbehaves.

Until step 6 has a receipt, this card stays `static-only` and no lane fixture may depend
on Scripting.

---

## 6. Adjacent observation for the C2 13-card set **[I]**

Scripting is structurally different from the other 12 rows in `README.md:100-112`. Every
other row names concrete editor objects ("spawn/move/duplicate actors", "create and edit
Level Sequences", "inspect GAS state"). Scripting names a **mechanism** — "batch multiple
tool calls into a single Python script execution" — and its only detailed documentation
lives in the *Security* section. A card set that treats all 13 rows as equally
specifiable will over-credit this one. Flagging so the set-level verdict does not inherit
a false symmetry.

---

## 7. Reproduction

```bash
# provenance
git -C /tmp/ue-skills-ref rev-parse HEAD          # expect a6aa73ada02a9fb1f5415bec491f9942c519b297
# vendored-vs-clone identity (expect 12 × OK, 0 × DIFF)
for f in $(cd corpus/knowledge/unreal-mcp/upstream && find . -type f | sort); do \
  a=$(sha256sum "corpus/knowledge/unreal-mcp/upstream/$f" | cut -d' ' -f1); \
  b=$(sha256sum "/tmp/ue-skills-ref/$f" | cut -d' ' -f1); \
  [ "$a" = "$b" ] && echo "OK   $f" || echo "DIFF $f"; done
# the entire static surface (expect 2 hits, both README.md:90,92)
grep -rn "execute_tool_script\|ProgrammaticToolset" corpus/knowledge/unreal-mcp/upstream --exclude-dir=.git
# the absences
grep -rln "execute_tool_script" corpus/knowledge/unreal-mcp/upstream/skills/   # expect: no output
find corpus/knowledge/unreal-mcp/upstream -name '*.py' -o -name '.mcp.json'    # expect: no output
# the 13-domain enumeration (expect 13; the bare grep over the whole file gives 17)
awk '/^## What.s Available/,0' corpus/knowledge/unreal-mcp/upstream/README.md | grep -c '^- \*\*'
# host reality
which UnrealEditor unreal-editor ; ls /opt/unreal-engine ; gh auth status
```

**Artifact identity:** vendored tree sha256 manifest digest
`3786eb7c0e48a7018a28e31fa9fb12903a1b93d3d35bfdd433c4ffa2edd9a463` (12 entries,
`find . -type f | sort | xargs sha256sum`). Individual blobs for the two load-bearing
lines: `upstream/README.md` =
`483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e` (matches
`.manifest.d/seat01.sha256`).
