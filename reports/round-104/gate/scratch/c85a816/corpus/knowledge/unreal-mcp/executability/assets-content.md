# SEAT-33 — Verdict card: **Assets and Content**

Round: r101 · Lane: game-dev-3d-shokunin · Axis served: depth (C2) — one of the 13 subsystem
verdict cards.
Upstream: `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin`
Pinned SHA: `a6aa73ada02a9fb1f5415bec491f9942c519b297` (re-derived in-place, §1)
Subsystem as labelled upstream: README.md:102, bullet 3 of 13 in §`What's Available`
Card path: `corpus/knowledge/unreal-mcp/executability/assets-content.md`
Date: 2026-10-18

---

## Verdict

**`static-only`**

The subsystem's label is **`static-only`** — exactly one label, and this is it. Every claim in
this card about the Assets and Content subsystem is derived by reading the byte-identical vendored
upstream tree; nothing in this card was observed executing. The subsystem's capabilities are
asserted upstream and are **not** reachable for execution on this host, so the label cannot be
`verified-here`; and it is not `unproven-runtime` either — see §5 for why that distinction is
load-bearing rather than pedantic.

Label accounting, so the single label is unambiguous:

| Subject of the label | Label | Note |
|---|---|---|
| **The Assets and Content subsystem** (this card's subject) | **`static-only`** | the one verdict this card carries |
| The *artifact-level* provenance checks in §1–§2 (clone identity, byte-identity, hashes) | `verified-here` | these are claims about the vendored **files**, not about subsystem behaviour — recorded separately, and not a second label on the subsystem |
| Any claim that a named asset tool exists, registers, or runs | *withheld* | no label is possible without the unlock in §7 |

---

## 1. Provenance (re-derived, not assumed)

The pre-existing clone was checked against the pin before any read:

```bash
ls -d /tmp/ue-skills-ref 2>/dev/null && git -C /tmp/ue-skills-ref rev-parse HEAD
```

```
/tmp/ue-skills-ref
a6aa73ada02a9fb1f5415bec491f9942c519b297
```

Observed `HEAD` equals the pinned SHA, so the pre-existing clone was used as-is and no fresh clone
to `/tmp/r101work` was needed. Pin identity and origin:

```bash
git -C /tmp/ue-skills-ref log -1 --format='%H%n%ad%n%s'
git -C /tmp/ue-skills-ref remote -v
```

```
a6aa73ada02a9fb1f5415bec491f9942c519b297
Thu Sep 17 13:19:50 2026 +1200
[MCP] Permit safe concurrent tool calls

origin  https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin (fetch)
origin  https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin (push)
```

Tracked content is 12 files (`git ls-files | wc -l` → `12`); the pin is on `main`.

## 2. Byte-identity of the vendored tree

Every line citation below points into `corpus/knowledge/unreal-mcp/upstream/`. That tree is
byte-identical to the pinned clone — three independent checks:

```bash
diff -r --brief corpus/knowledge/unreal-mcp/upstream /tmp/ue-skills-ref --exclude=.git
```

```
(no output — the trees are identical apart from .git)
```

```bash
cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256
```

```
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
```

The three files this card cites most, with digests:

```
483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e  upstream/README.md
7ef8b991a82f591c5776bb5fa167c2bc2269fd00338ed3e8534eacc551d038fa  upstream/skills/unreal-mcp/SKILL.md
bd16206ea142dc9cc1950b88af526a3137072ea152c5662e8549d21bc18a3b8a  upstream/skills/unreal-mcp/references/setup.md
```

**Citation convention.** Every `path:line` in this card is relative to
`corpus/knowledge/unreal-mcp/upstream/`. `README.md` means `upstream/README.md`;
a bare `SKILL.md:N` means `upstream/skills/unreal-mcp/SKILL.md` (the skill this subsystem's
discovery flow lives in), while `create-toolset/SKILL.md:N` and `unreal-skill/SKILL.md:N` name
those skills explicitly.

The **one exception** is the corpus index, which is outside `upstream/` and is therefore always
written with its full path: `corpus/knowledge/unreal-mcp/README.md:N`. It is cited only in §5,
where it supplies the authoritative label definitions. A bare `README.md:N` never means the
index.

All 16 `upstream/` file:line citations in this card were resolved by script against the vendored
tree at the pin — see §8. The four index citations were resolved the same way; the index is a
lane-authored file, not vendored content, so it is not covered by the manifest sweep in §2.

## 3. The subsystem, as upstream states it — verbatim

The entire upstream statement of this subsystem is **one line**, `README.md:102`:

```
- **Assets and Content** - find, load, save, move, duplicate assets; edit Data Tables, Curve Tables, String Tables
```

That line sits in §`What's Available`, whose framing sentence is `README.md:98`:

```
All tools are auto-discovered by Claude Code via MCP. No manual configuration needed. Tools cover the full editor surface across these domains:
```

The section runs 96–112 and contains exactly 13 bullets (lines 100–112). This card covers bullet 3.

**Decomposition — 8 capability clauses**, split on `;` and `,` without paraphrase:

| # | Clause (verbatim fragment) | Evidence for the clause | Occurrences of that exact phrase in the whole tree |
|---|---|---|---|
| C1 | `find … assets` | README.md:102 | 1 |
| C2 | `load … assets` | README.md:102 | 1 |
| C3 | `save … assets` | README.md:102; corroborated by SKILL.md:30 (`AssetTools` save APIs) | 1 (+1 prose mention) |
| C4 | `move … assets` | README.md:102; the *mutation* sense recurs at README.md:94 ("mutate, move, or delete VCS-tracked assets") | 1 (+1 prose mention) |
| C5 | `duplicate assets` | README.md:102 only — see §4.3 | 1 |
| C6 | `edit Data Tables` | README.md:102 | 1 |
| C7 | `edit Curve Tables` | README.md:102 | 1 |
| C8 | `edit String Tables` | README.md:102 | 1 |

## 4. Evidence for the verdict (commands run and their output)

### 4.1 No tool name, no schema, no signature exists to verify against

The plugin deliberately keeps toolset tools out of the advertised catalog, so there is no static
surface to check. `skills/unreal-mcp/SKILL.md:16`:

```bash
grep -n "not in \`tools/list\`" corpus/knowledge/unreal-mcp/upstream/skills/unreal-mcp/SKILL.md
```

```
16:Tool search is on by default, so the MCP server advertises only three meta-tools for the whole session: `list_toolsets`, `describe_toolset`, and `call_tool`. Tool names like `BlueprintTools.create` or `SequencerTools.create_level_sequence` are **not in `tools/list`**. They are dispatched server-side through `call_tool` and never registered as native MCP tools. This is deliberate. It keeps your context window small and the prompt cache warm.
```

The consequence for this card: **no asset tool name is published anywhere**, so no claim such as
"`AssetTools.find_asset` exists" can be checked statically — there is nothing to check. Discovery
is a runtime act (`list_toolsets` → `describe_toolset` → `call_tool`, SKILL.md:20–21), and no
engine is present on this host (§5).

### 4.2 `AssetTools` is named, but only ever in prose — never as a callable surface

```bash
grep -rn "AssetTools" corpus/knowledge/unreal-mcp/upstream/
```

```
upstream/skills/unreal-mcp/SKILL.md:30:- **Save first, then save again.** Tell the user to save the project (or call `AssetTools` save APIs) before any bulk change, and again after. MCP edits are not always undoable, especially across compilation boundaries. Treat anything that touches multiple assets as a destructive operation that needs a recovery point.
upstream/skills/create-toolset/SKILL.md:28:**2. Is the request more general than it sounds?** Users often ask for something domain-specific that is actually an instance of a broader pattern. Before looking for a domain toolset, ask whether the capability truly belongs to that domain or whether it applies more widely. For example, a request for "read blueprint asset metadata" sounds like it belongs in `BlueprintTools`, but metadata applies to all assets, so the right place is `AssetTools`. Solving it generically is almost always better than solving it narrowly.
```

Two hits, both prose. Neither is a tool call, an argument list, or a return schema. `AssetTools` is
*the only* candidate name for this subsystem anywhere in the tree — contrast the other domains,
where callable forms with a method do appear (SKILL.md:16 `BlueprintTools.create`,
`SequencerTools.create_level_sequence`; SKILL.md:42–43 `AgentSkillToolset.ListSkills`,
`AgentSkillToolset.GetSkills`). Repo-wide dotted-token sweep:

```bash
grep -rhoE '`[A-Za-z_][A-Za-z0-9_]*\.[A-Za-z_][A-Za-z0-9_]*`' corpus/knowledge/unreal-mcp/upstream/ | sort -u
```

```
`AgentSkillToolset.GetSkills`
`AgentSkillToolset.ListSkills`
`AIAssistantToolset.GetDockedContext`
`BlueprintTools.create`
`LiveCodingToolset.CompileLiveCoding`
`ModelContextProtocol.RefreshTools`
`ModelContextProtocol.StartServer`
`ModelContextProtocol.StopServer`
`ProgrammaticToolset.execute_tool_script`
`SequencerTools.create_level_sequence`
… (plus file names `operations.md`, `setup.md`, `SKILL.md`, `__init__.py`, `init_unreal.py`,
   `EditorPerProjectUserSettings.ini`, and Python symbols `unreal.AgentSkill`,
   `unreal.ToolsetDefinition`)
```

There is **no `AssetTools.<method>` token**. For the Assets and Content subsystem the plugin
publishes a domain label and nothing more granular.

### 4.3 The Data/Curve/String Table clauses have exactly one occurrence — this one

```bash
grep -rn -iE "data tables|curve tables|string tables" corpus/knowledge/unreal-mcp/upstream/
```

```
upstream/README.md:102:- **Assets and Content** - find, load, save, move, duplicate assets; edit Data Tables, Curve Tables, String Tables
```

Singular forms and UE type names are equally absent:

```bash
grep -rn -iE "UDataTable|FDataTableRowHandle|UCurveTable|UStringTable|UDataAsset|FTableRowBase" corpus/knowledge/unreal-mcp/upstream/ | wc -l
```

```
0
```

So clauses C6–C8 rest on a single unelaborated mention: no row-struct type, no row-handle type, no
row-editing semantics, no import path, nothing that would let a reader predict what "edit a Data
Table" means through MCP.

`duplicate` (C5) is the same shape — the word appears in the asset sense only on line 102; the
other three hits are unrelated prose about *tool duplication*:

```bash
grep -rn -i "duplicate" corpus/knowledge/unreal-mcp/upstream/ | grep -v -i "connection"
```

```
upstream/README.md:102:… find, load, save, move, duplicate assets; …
upstream/skills/create-toolset/SKILL.md:45:- **Don't duplicate existing tools.** …
upstream/skills/create-toolset/SKILL.md:413:- **Duplicated boilerplate.** …
upstream/skills/create-toolset/SKILL.md:415:- **Duplicate functionality.** …
```

### 4.4 Adjacent evidence that *does* exist (context, not a capability proof)

These are the only other places the tree says anything about asset-shaped operations. All are
warnings or failure modes, i.e. they confirm assets are mutable through this plugin without
confirming any specific capability clause:

| Pointer | Verbatim fragment | What it supports |
|---|---|---|
| `README.md:94` | "MCP tools edit live `UObject` state and can mutate, move, or delete VCS-tracked assets in a single call." | move/delete are real hazards ⇒ the subsystem is destructive, not read-only |
| `README.md:90` | "`ProgrammaticToolset.execute_tool_script` … full access to every toolset API, the project on disk, **the asset database**, and editor-privileged functions." | an escape hatch exists that reaches the asset database; it is a Python-arbitrary-code path, not an asset API |
| `README.md:88` | "The MCP server binds to `localhost:8000` with origin validation." | the transport the subsystem would be reached through |
| `skills/unreal-mcp/SKILL.md:30` | "call `AssetTools` save APIs … before any bulk change, and again after." | C3 (save) is the one clause with a second, independent mention |
| `skills/unreal-mcp/SKILL.md:34` | "Editor-only tools (**asset creation in particular**) behave differently while Play-in-Editor is active." | asset operations are PIE-sensitive — a behaviour caveat with no stated mechanism |
| `skills/unreal-mcp/SKILL.md:3` | asset prefixes `BP_`, `WBP_`, `M_`, `MI_`, `NS_`, `CR_`, `SK_`, `SM_`, `ABP_` | the plugin's trigger vocabulary is asset-prefix based; no Data/Curve/String Table prefix is listed |

The prefix list is worth noting for calibration: 9 prefixes are enumerated and **none of them
covers Data Tables, Curve Tables, or String Tables**. The trigger vocabulary that decides whether
the plugin activates at all has a gap exactly where clauses C6–C8 live.

### 4.5 Setup chain the subsystem would depend on

`skills/unreal-mcp/references/setup.md` (133 lines) fixes the prerequisite chain. Two plugins are
required and `AllToolsets` is the one that provides tools (setup.md:14, section §1 spans 12–31):

> "With only `ModelContextProtocol` enabled the server starts but exposes no tools." — setup.md:14

and the first prerequisite in `README.md:17` (section §`Prerequisites` spans 15–20):

> "**Unreal Editor** with the **ModelContextProtocol** and **AllToolsets** plugins enabled (`AllToolsets` provides the tools; the server exposes none without it)"

So the Assets and Content subsystem is downstream of three gates: plugin enablement →
editor process → MCP server started. None of the three exists on this host (§5).

## 5. Why this card is `static-only` and not something else — host receipts

The round's host receipts are re-derived here rather than quoted, so this card stands on its own:

```bash
for b in UnrealEditor UnrealEditor-Cmd UnrealEditor-Cmd-Linux UE4Editor UnrealBuildTool RunUAT; do
  printf '%-22s %s\n' "$b" "$(command -v $b 2>/dev/null || echo ABSENT)"; done
ls -d /opt/unreal-engine /opt/UnrealEngine "$HOME/UnrealEngine"
find / -xdev -maxdepth 7 -type d \( -name 'AllToolsets' -o -name 'ModelContextProtocol' -o -name 'ToolsetRegistry' \) 2>/dev/null
```

```
UnrealEditor           ABSENT
UnrealEditor-Cmd       ABSENT
UnrealEditor-Cmd-Linux ABSENT
UE4Editor              ABSENT
UnrealBuildTool        ABSENT
RunUAT                 ABSENT
ls: cannot access '/opt/unreal-engine': No such file or directory
ls: cannot access '/opt/UnrealEngine': No such file or directory
ls: cannot access '/home/vgpnk/UnrealEngine': No such file or directory
(find: no output — no AllToolsets / ModelContextProtocol / ToolsetRegistry directory anywhere)
```

No engine binary, no engine tree, and — decisively — **no plugin source for `AllToolsets`,
`ModelContextProtocol`, or `ToolsetRegistry` on this host**.

The label is applied against the authoritative definition in the corpus index
(`corpus/knowledge/unreal-mcp/README.md:37–41`), not against a private reading:

| index line | definition (verbatim) |
|---|---|
| `corpus/knowledge/unreal-mcp/README.md:40` | `static-only` \| "the vendored document facts are proven by a static check run here; **no** runtime observation was made" \| "`proven` for the document facts, `unproven` for the subsystem's behavior" |
| `corpus/knowledge/unreal-mcp/README.md:41` | `unproven-runtime` \| "the claim needs the live editor and nothing was observed" \| "`unproven`" |

Both rows describe a claim that is `unproven` for behaviour. The distinguishing clause is in the
first column: `unproven-runtime` is for a claim that **needs the live editor** — i.e. the
dispatch route and its destination are specified, and only execution is missing. For this
subsystem the destination is not specified: no tool name, no schema, no signature (§4.1–§4.2),
and the implementation is not on disk to read. What this card proves is a set of *document
facts* (the 8 clauses, their single-occurrence census, the absence of any tool name), which is
exactly the `static-only` row.

The two neighbouring cases make the boundary concrete:

- `unproven-runtime` *would* fit the `ModelContextProtocol.*` console commands — named and
  argument-shaped in `operations.md:11–14`, console absent here. A named path, unexecuted.
- `unproven-runtime` *would* fit a card whose claim is "`AssetTools` can move an asset" — that
  claim names the destination toolset and needs the editor. **This card deliberately does not
  make that claim** (§6), so it cannot borrow that label.

The index also fixes who decides: `corpus/knowledge/unreal-mcp/README.md:237` — "A card's label
is set by that card's author from that card's own evidence." This card's evidence is
document-level, so its label is `static-only`.

**Noted divergence for the reviewer (not resolved here).** Of the 13 cards in this directory,
12 declare `static-only` and one (`actors-scene.md`) declares `unproven-runtime`, reasoning that
its domain is live-editor state with no static substitute. That card's reading is defensible —
its claim does name the destination (live actor state) and needs the editor. The two readings
differ over whether an *unnamed* destination counts as "needs the live editor" or as "no
document facts beyond prose". Both are within the index's definitions; the lane may want a
single convention, and that call belongs to the round's adjudicator, not to this seat.

The `static-only` reading is the one this card stands on, because the strongest thing this card
can honestly say is: *the upstream prose is fully inventoried and every clause's evidence count
is measured* — which is what `static-only` asserts.

Engine install is blocked upstream of any probe attempt (re-derived):

```bash
git ls-remote https://github.com/EpicGames/unreal-engine
gh auth status
```

```
remote: Repository not found.
fatal: repository 'https://github.com/EpicGames/unreal-engine/' not found

github.com
  ✓ Logged in to github.com account VeigaPunk (keyring)
  - Token scopes: 'gist', 'read:org', 'repo', 'workflow'
```

The account is authenticated to GitHub but is not Epic-linked, so the private engine repo is
invisible. The AUR path is blocked at the same place — `PKGBUILD` line 280:

```
if ! git ls-remote git@github.com:EpicGames/UnrealEngine &>/dev/null; then
```

and lines 327/336 clone over SSH from the same URL. Host capacity for a build is not the
constraint (32 cores, 30G RAM, 780G free on `/`); the SSH authorization is.

**One operational hazard observed while taking these receipts.** The documented default port was
transiently occupied by a non-Unreal process during this probe:

```
LISTEN 0      5          127.0.0.1:8000       0.0.0.0:*    users:(("python3",pid=3543867,fd=3))
```

A re-check seconds later returned nothing on `:8000` and `curl http://127.0.0.1:8000/` returned
`http_code=000`, and the pid had exited. Reported as observed-and-transient, not as a standing
conflict. It matters for the unlock because a busy `:8000` is upstream's documented first failure
mode (`references/operations.md:47`, "Editor logs \"Failed to listen on port\"") — a would-be
verifier must confirm the port is free *and* re-run
`ModelContextProtocol.GenerateClientConfig ClaudeCode`, since the port is baked into `.mcp.json`.

## 6. What this card does and does not assert

**Asserted (static-only, every one carrying a pointer):**

- The subsystem exists as README bullet 3 of 13 and consists of 8 capability clauses (§3).
- Its total upstream specification is **13 words on one line** (`README.md:102`; `wc -w` on the
  line's text after the `**Assets and Content** - ` label); the Table clauses have exactly one
  occurrence each and no supporting type names (§4.3).
- `AssetTools` is the only candidate toolset name, mentioned twice, both times in prose (§4.2).
- No tool name for this subsystem is published, because tool names are deliberately excluded from
  `tools/list` (§4.1).
- The subsystem is destructive by upstream's own account — move/delete of VCS-tracked assets in a
  single call is called out as a hazard (§4.4).

**Not asserted (and must not be read in):**

- That any asset tool exists, is registered, or is callable. `list_toolsets` was never called; no
  MCP server was reachable.
- That "find/load/save/move/duplicate assets" is complete, or that these are 5 tools rather than
  1, 12, or 40 — upstream gives no count, and the same README says "hundreds of tools … across
  30+ toolsets" (`README.md:3`) without any per-domain breakdown.
- That Data/Curve/String Table editing has any particular semantics, granularity, or safety
  property. The single mention is unelaborated.
- That the PIE caveat (SKILL.md:34) has any specific mechanism; upstream states the behaviour
  without explaining it.
- Anything about performance, determinism, or failure modes of the subsystem.

## 7. Unlock condition

This card becomes promotable to `verified-here` only when a **live-editor MCP probe** can be run
against a real project. The chain, with the gate that is currently closed on each link:

| Step | Action | Status on this host | Gate |
|---|---|---|---|
| 1 | Operator links the Epic account so `git@github.com:EpicGames/UnrealEngine` resolves | **BLOCKED** | operator-owned credential action; `gh` is authed as `VeigaPunk` but not Epic-linked (§5) |
| 2 | Obtain a UE build containing `Engine/Plugins/Experimental/ModelContextProtocol` + `AllToolsets` | **BLOCKED** | follows from step 1 (AUR `unreal-engine` PKGBUILD:280; `Lutris`/Epic-login route is also operator-owned) |
| 3 | Create/open a project with both plugins enabled in the `.uproject` | not attempted | requires step 2 (setup.md:14, §1) |
| 4 | Start the editor and the server (`ModelContextProtocol.StartServer`, or `bAutoStartServer`) | not attempted | requires step 3; also confirm `:8000` is free (§5) |
| 5 | `ModelContextProtocol.GenerateClientConfig ClaudeCode` → `.mcp.json` at the right location for the build kind | not attempted | requires step 4; source builds write it next to `Engine/`, installed builds next to the `.uproject` (setup.md:65–66) |
| 6 | Call `list_toolsets`, then `describe_toolset` on the asset toolset, and record the returned schemas | not attempted | requires step 5 — **this is the step that turns clauses C1–C8 into `verified-here` or `unproven-runtime`** |
| 7 | Execute one read-only call per clause (e.g. a find/list on a throwaway asset) and record the wire result | not attempted | requires step 6; do it in a throwaway project per README.md:92 |

Steps 1–2 are the operator's to unblock; everything from step 3 on is mechanical once an engine
exists. **What step 6 must capture is the toolset's own schema output** — that is the only
artifact that can settle the open questions in §4.2–§4.3, because upstream publishes no schema.

A partial unlock exists and is worth naming: if a `describe_toolset` dump for the asset toolset is
ever captured anywhere (even on another host), the *names and signatures* in that dump would let
clauses C1–C8 be checked statically against real schemas, promoting the card's evidence base
without any engine on this host. That is the cheapest route to depth here.

## 8. Reproduction

```bash
# provenance and byte-identity
git -C /tmp/ue-skills-ref rev-parse HEAD                 # a6aa73ada02a9fb1f5415bec491f9942c519b297
diff -r --brief corpus/knowledge/unreal-mcp/upstream /tmp/ue-skills-ref --exclude=.git   # empty
cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256          # 12/12 OK

# the subsystem statement and its clause census
cd corpus/knowledge/unreal-mcp/upstream
grep -n "Assets and Content" README.md                    # 102
sed -n '102p' README.md                                   # the whole subsystem, verbatim
grep -rn -iE "data tables|curve tables|string tables" .    # 1 hit
grep -rn "AssetTools" .                                    # 2 hits, both prose
grep -rhoE '`[A-Za-z_][A-Za-z0-9_]*\.[A-Za-z_][A-Za-z0-9_]*`' . | sort -u   # no AssetTools.<method>
grep -rn -iE "UDataTable|UCurveTable|UStringTable|FDataTableRowHandle" . | wc -l   # 0

# the host gate
for b in UnrealEditor UnrealBuildTool; do command -v $b || echo ABSENT; done
find / -xdev -maxdepth 7 -type d \( -name AllToolsets -o -name ToolsetRegistry \) 2>/dev/null   # empty
git ls-remote https://github.com/EpicGames/unreal-engine    # Repository not found
```

Every `file:line` citation in this card is machine-checkable. The resolver used:

```bash
cd corpus/knowledge/unreal-mcp/upstream
CARD=../executability/assets-content.md
grep -oE '(README\.md|skills/[a-z-]+/SKILL\.md|skills/unreal-mcp/references/[a-z]+\.md):[0-9]+(–[0-9]+)?' "$CARD" \
  | sort -u | while read c; do
      f="${c%%:*}"; rest="${c##*:}"; l1="${rest%%–*}"; l2="${rest##*–}"
      tot=$(wc -l < "$f")
      if [ "$l1" -le "$tot" ] && [ "$l2" -le "$tot" ]
      then printf 'OK   %-50s %s\n' "$c" "$(sed -n "${l1}p" "$f" | cut -c1-44)"
      else printf 'FAIL %-50s (%s lines)\n' "$c" "$tot"; fi
    done
```

Observed output — all 16 resolved, none out of range:

```
OK   README.md:102                     - **Assets and Content** - find, load, save,
OK   README.md:17                      1. **Unreal Editor** with the **ModelContext
OK   README.md:3                       Control Unreal Editor directly from Claude C
OK   README.md:88                      **Localhost is not a trust boundary.** The M
OK   README.md:90                      **`ProgrammaticToolset.execute_tool_script`
OK   README.md:92                      **`--dangerously-skip-permissions` removes t
OK   README.md:94                      **Source-control hygiene.** MCP tools edit l
OK   README.md:98                      All tools are auto-discovered by Claude Code
OK   skills/create-toolset/SKILL.md:28  **2. Is the request more general than it sou
OK   skills/create-toolset/SKILL.md:413 - **Duplicated boilerplate.** Similar patter
OK   skills/create-toolset/SKILL.md:415 - **Duplicate functionality.** A tool that d
OK   skills/create-toolset/SKILL.md:45  - **Don't duplicate existing tools.** For ex
OK   skills/unreal-mcp/SKILL.md:16      Tool search is on by default, so the MCP ser
OK   skills/unreal-mcp/SKILL.md:3       description: "Use this skill to perform acti
OK   skills/unreal-mcp/SKILL.md:30      - **Save first, then save again.** Tell the
OK   skills/unreal-mcp/SKILL.md:34      - **Mind PIE.** Editor-only tools (asset cre
```

Bare-name citations (`setup.md:N`, `operations.md:N`, `SKILL.md:N`) resolve under the convention
stated in §2 and were checked the same way. The bare `SKILL.md:N` forms resolve against
`skills/unreal-mcp/SKILL.md` (56 lines), so the two out-of-range line numbers in that skill's
file (413, 415) appear in this card only in their full `create-toolset/SKILL.md:N` form.

The index citations in §5 resolve against `corpus/knowledge/unreal-mcp/README.md` (278 lines):

```
OK   corpus/knowledge/unreal-mcp/README.md:237   - **A card's label is set by that card's author from
OK   corpus/knowledge/unreal-mcp/README.md:37–41 | card label | what it means | policy state |
OK   corpus/knowledge/unreal-mcp/README.md:40    | `static-only` | the vendored document facts are pr
OK   corpus/knowledge/unreal-mcp/README.md:41    | `unproven-runtime` | the claim needs the live edit
```

Ambiguity guard, run as a check rather than asserted: every **bare** `README.md:N` in this card
(27 occurrences) has `N ≤ 112`, so all of them belong to `upstream/README.md`; the index is
reached only through its full path. Verify with:

```bash
grep -oP '(?<![/a-zA-Z._-])README\.md:[0-9]+' executability/assets-content.md | sort -u -t: -k2n
# expect a maximum of 102, i.e. nothing above upstream/README.md's 112 lines
```

## 9. Scope / limits

- Read-only with respect to `corpus/`: this card created no vendored file and edited none. The
  only path written by this seat is this file.
- Every line number is against the vendored tree at the pinned SHA, whose digests are in §2. Line
  numbers are meaningless without that pin.
- The 8-clause decomposition in §3 is a split of the upstream sentence on `;` and `,`; it is
  presented as *clause count*, not as a claim about how many tools or toolsets implement them
  (explicitly disclaimed in §6).
- This card is one of 13 subsystem cards. It does not restate the other 12; the README 13-row
  census lives in `reports/round-101/probes/toolset-census.md`.
- No claim about the subsystem's runtime behaviour of any kind. See §6 and §7.
