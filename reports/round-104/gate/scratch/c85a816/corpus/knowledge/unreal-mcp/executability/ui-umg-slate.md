# Executability card — UI (UMG widget blueprints, Slate automation)

**Seat:** SEAT-39 EXEC · **Round:** r101 · **Lane:** game-dev-3d shokunin
**Subsystem:** UI — UMG widget blueprints, Slate UI interaction
**Verdict:** `static-only`
**Upstream:** `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin`
**Pinned SHA:** `a6aa73ada02a9fb1f5415bec491f9942c519b297`

Confidence tags: **[O]** receipt-pinned observation (command + observed output
below), **[I]** inference from those observations, **[?]** unknown / unmeasured.

---

## 0. Verdict

**`static-only`.** The UI subsystem is documented in the vendored upstream bytes
and nowhere else. Every UI statement upstream makes is prose about a capability;
not one UI tool name, toolset name, parameter, or return schema is recoverable
from the pinned tree. There is no artifact on this host that can execute a UI
claim — no Unreal Editor, no `Engine/` tree, no MCP server on `:8000` — so no UI
capability in this corpus is verified-here, and none is even *unproven-runtime*,
because "unproven-runtime" would require a runtime path that was reachable and
not taken. Here the runtime path is absent by construction.

Why not `unproven-runtime`: that label would assert a live-editor MCP path
exists in this environment and that a bounded UI probe was declined or failed.
Neither is true. The engine is not installed (§5), so the UI capability surface
is readable but not reachable. `static-only` is the honest label.

Why not `verified-here`: nothing was executed. No UMG widget blueprint was
created, no Slate automation driver was driven, no widget asset was inspected.
A static grep of vendored prose cannot verify a runtime capability.

---

## 1. What the label means, precisely

| aspect | this card's status |
|---|---|
| existence of a UI capability claim in upstream | **[O] yes** — `README.md:108`, quoted in §2 |
| existence of a named UI toolset / tool | **[O] no** — enumeration in §3 returns zero UI names |
| schema (parameters, return types) for any UI tool | **[O] absent from pinned tree** |
| execution of any UI capability on this host | **[O] impossible** — no engine (§5) |
| runtime behavior, including the documented flakiness | **[?] unknown**, unreachable |

`static-only` claims exactly this: *the claim is in the bytes, and the bytes are
the only thing we have.* It claims nothing about whether the capability works,
what its signature is, or whether it exists in any given engine build.

---

## 2. The complete UI surface in the pinned tree

The whole UI story is **11 occurrences across 7 matching lines in 4 files**,
extracted exhaustively. Occurrence count is `grep -rho` (a line can hold more
than one match); the line set is `grep -rn` and is the 7 rows tabulated below.
No UI text exists outside this set.

```
$ cd /tmp/ue-skills-ref && grep -rn -i -E 'umg|slate|widget|WBP_' $(git ls-files)
.claude-plugin/plugin.json:4:  "description": "Control Unreal Editor directly from Claude Code via MCP. Hundreds of tools exposed via Unreal's ToolsetRegistry across 30+ toolsets: actors, blueprints, materials, Niagara, Control Rigs, Sequencer, State Trees, widgets, Gameplay Ability System, automation testing, and more.",
README.md:3:Control Unreal Editor directly from Claude Code via MCP. Hundreds of tools exposed via Unreal's ToolsetRegistry across 30+ toolsets: actors, blueprints, materials, Niagara, Control Rigs, Sequencer, State Trees, widgets, Gameplay Ability System, automation testing, and more.
README.md:13:- **SessionStart** (`hooks/unreal-context.sh`) - injects a short note identifying the repo as an Unreal Engine project so Claude defaults to UE conventions (C++/`UObject`, Slate, UHT) and prefers the `unreal-mcp` skill. Runs on `startup`, `resume`, and `clear`.
README.md:108:- **UI** - build UMG widget blueprints, automate Slate UI interaction
hooks/unreal-context.sh:72:context="$context Prefer Unreal Engine conventions (C++/UObject patterns, Slate, UHT reflection) when suggesting code."
skills/unreal-mcp/SKILL.md:3:description: "...create or edit a Blueprint/Widget/Material/Niagara/Control Rig/Sequencer/Behavior Tree/GAS ability... asset prefixes `BP_`, `WBP_`, `M_`, `MI_`, `NS_`, `CR_`, `SK_`, `SM_`, `ABP_`..."
skills/unreal-mcp/SKILL.md:33:- **Always check the result.** Blueprint compilation, widget creation, material edits: many tools return a status that flips between success and failure with no exception thrown on the wire. Read the response before moving on. Treat anything that isn't an explicit success as a stop.
```

Line 66 is elided (the source line is 1031 chars); both quoted fragments were
confirmed present in it by separate `grep -c` probes (1 each). Every other line
in this block is the full line verbatim.

Per-file counts **[O]** (`grep -ric`, zero-count files omitted):

```
.claude-plugin/plugin.json:1
README.md:3
hooks/unreal-context.sh:1
skills/unreal-mcp/SKILL.md:2
```

Counts are case-insensitive match lines per file. `README.md` is 3 rather than 2
because `README.md:13` capitalises `Slate`; the case-sensitive `grep -rc` returns
2 for that file and misses it.

Resolvable in-repo pointers (vendored, byte-identical to the clone — §6):

| # | occurrence | vendored path:line | what it establishes | label |
|---|---|---|---|---|
| 1 | UI domain bullet | `corpus/knowledge/unreal-mcp/upstream/README.md:108` | the *only* capability statement for this subsystem | `static-only` |
| 2 | plugin description | `corpus/knowledge/unreal-mcp/upstream/.claude-plugin/plugin.json:4` | "widgets" as one word in a 30+ toolset marketing list | `static-only` |
| 3 | README overview | `corpus/knowledge/unreal-mcp/upstream/README.md:3` | same list, duplicated prose | `static-only` |
| 4 | hook convention note | `corpus/knowledge/unreal-mcp/upstream/hooks/unreal-context.sh:72` | "Slate" as a *coding convention* hint, not a tool | `static-only` |
| 5 | README hook doc | `corpus/knowledge/unreal-mcp/upstream/README.md:13` | same, in prose | `static-only` |
| 6 | skill trigger list | `corpus/knowledge/unreal-mcp/upstream/skills/unreal-mcp/SKILL.md:3` | "Widget" as a trigger word; `WBP_` as an asset prefix | `static-only` |
| 7 | skill safety rule | `corpus/knowledge/unreal-mcp/upstream/skills/unreal-mcp/SKILL.md:33` | widget creation *can* return a status that flips | `static-only` |

The 7 rows are the complete surface. Row 7 is the closest thing upstream has to
a runtime observation, and it is a *warning about* nondeterministic status, not a
measured result — it carries no command, no version, no reproducer. It is
therefore static evidence of a documented risk, not runtime evidence of a defect.

---

## 3. Discriminating negative — no UI toolset or tool is named anywhere

The strongest available falsifier for "this subsystem is executable-verifiable":
if a UMG/Slate toolset existed in the documented registry surface, its class name
would appear the way other toolsets do. It does not.

Full enumeration of every `*Tools` / `*Toolset` token in the pinned tree **[O]**:

```
$ cd /tmp/ue-skills-ref && grep -rhoE '\b[A-Z][A-Za-z]*(Tools|Toolset)\b' $(git ls-files) | sort -u
AgentSkillToolset
AIAssistantToolset
AssetTools
AutomationTestToolset
BlueprintTools
LevelTools
LiveCodingToolset
MaterialTools
MyToolset
NiagaraTools
ObjectTools
ProgrammaticToolset
RefreshTools
SequencerTools
StaticMeshTools
UMyToolset
```

16 names. `MyToolset` / `UMyToolset` are `create-toolset` template placeholders.
**Zero of the 16 contain `UI`, `UMG`, `Slate`, or `Widget`.**

Deeper probe — UE type and tool identifiers that a UI toolset would have to
mention **[O]**:

```
$ cd /tmp/ue-skills-ref && grep -rn 'WidgetBlueprint\|UWidget\|UUserWidget\|SlateAutomation\|AutomationDriver\|SWidget' $(git ls-files)
(none — zero hits)
```

Zero hits. No `WidgetBlueprint` asset class, no `UUserWidget`, no
`SlateAutomation` driver, no `SWidget` — not even in the `create-toolset`
conventions document that names real types for other domains.

This is a *discriminating* negative rather than mere absence: the same probe
returns hits for the domains that do have named toolsets (`BlueprintTools`,
`SequencerTools`, `NiagaraTools`, `MaterialTools`, `StaticMeshTools`,
`LevelTools`, `AssetTools`), so the probe is sensitive. UI is the only domain
that comes back empty at both the toolset-name and the type-identifier level.

Cross-check against the sibling seat's census **[O]**:
`reports/round-101/probes/toolset-census.md:163` records the same finding
independently — `| UI | *(none named)* — UMG/Slate toolset unnamed | — |`.

---

## 4. Per-capability assessment

`README.md:108` is the entire capability claim, and it splits on `;` into two
clauses. Both inherit the card's `static-only` label; neither can be executed.

| # | capability clause (verbatim) | source pointer | named tool | schema known | verdict | why |
|---|---|---|---|---|---|---|
| 1 | `build UMG widget blueprints` | `upstream/README.md:108` | **[O] none** | **[O] no** | `static-only` | prose claim; zero toolset/type names (§3) |
| 2 | `automate Slate UI interaction` | `upstream/README.md:108` | **[O] none** | **[O] no** | `static-only` | prose claim; `Slate` appears only as a coding convention (rows 4–5) |

Supporting static facts that constrain future runtime work **[O]**:

- `skills/unreal-mcp/SKILL.md:3` makes `WBP_` (the widget-blueprint asset
  prefix) a *skill-trigger* token. So the skill is designed to fire on widget
  work — routing exists; tooling behind it is undocumented here.
- `skills/unreal-mcp/SKILL.md:33` puts "widget creation" in the same sentence as
  "Blueprint compilation" and "material edits" for the flaky-status warning. **[I]**
  whoever wrote the skill observed widget creation returning a non-throwing
  failure status at least once. That is a *report of* an observation, not an
  observation this seat made; it does not upgrade the label.
- `references/setup.md` and `references/operations.md` — the two files that
  document transport, ports, recovery, and the troubleshooting matrix — contain
  **zero** UI mentions:

  ```
  $ cd /tmp/ue-skills-ref && grep -c -i -E 'umg|slate|widget' skills/unreal-mcp/references/setup.md skills/unreal-mcp/references/operations.md
  skills/unreal-mcp/references/setup.md:0
  skills/unreal-mcp/references/operations.md:0
  ```

  **[I]** There is no UI-specific setup step, no UI toolset to enable, and no UI
  row in the troubleshooting matrix. Whatever UI toolset exists is not one the
  plugin's own documentation asks the operator to enable.

---

## 5. Why execution is impossible here — host receipts

Re-derived for this seat (not inherited) **[O]**:

```
$ ls /usr/bin/UnrealEditor /opt/unreal-engine /usr/share/unreal-engine
ls: cannot access '/usr/bin/UnrealEditor': No such file or directory
ls: cannot access '/opt/unreal-engine': No such file or directory
ls: cannot access '/usr/share/unreal-engine': No such file or directory

$ which UnrealEditor UnrealEditor-Cmd
which: no UnrealEditor in (...)
which: no UnrealEditor-Cmd in (...)

$ ls -d /home/vgpnk/*/Engine
(no Engine/ dir anywhere in home)

$ ls /home/vgpnk/.config/Epic
ls: cannot access '/home/vgpnk/.config/Epic': No such file or directory

$ ss -ltn | grep -c 8000
0

$ pacman -Qs unreal
(no output; rc=1 — no unreal package installed)
```

Elision note: the two `ls`-derived lines above are condensed — the literal
outputs are `ls: cannot access '/home/vgpnk/*/Engine': No such file or
directory` (rc=2) and `ls: cannot access '/home/vgpnk/.config/Epic': No such
file or directory` (rc=2). The `which` output is elided at the PATH list, which
is long; the operative fragment `which: no UnrealEditor in (` is verbatim.

The MCP endpoint the UI tools would arrive through (`http://127.0.0.1:8000/mcp`,
per `upstream/skills/unreal-mcp/references/setup.md` step 3) has **nothing
listening**. Combined with the absent engine, both halves of the UI execution
path — server and client — are missing.

The upstream plugin's own "no running editor" escape hatch does not help either.
`skills/create-toolset/SKILL.md` offers `UnrealEditor-Cmd ... -Unattended -NullRHI`
as the headless automation route **[O]**:

```
$ sed -n '399,404p' /tmp/ue-skills-ref/skills/create-toolset/SKILL.md
When no editor is running, the command line launches a headless editor instance, runs the specified tests, and exits. It's slower due to startup time (~30 seconds) but requires no running editor and is useful in CI or when the editor isn't available.

UnrealEditor-Cmd.exe <Project>.uproject -ExecCmds="Automation RunTests AI.MyToolset;quit" -Unattended -NullRHI
```

That binary does not exist on this host either (§5 probe above), and the route is
Windows-shaped (`UnrealEditor-Cmd.exe`). **[I]** It is not an available
workaround here.

**Engine-install blocker (inherited, cited not re-derived):** the AUR
`unreal-engine` 5.8.2-1 PKGBUILD requires SSH access to
`git@github.com:EpicGames/UnrealEngine` (~line 280), and
`gh` is authed as `VeigaPunk` without an Epic-linked account, so
`EpicGames/unreal-engine` git ls-remote returns "Repository not found". Engine
install is **BLOCKED pending operator Epic-account linking**.

---

## 6. Provenance of the bytes this card reads

Clone verified in place at the pinned SHA **[O]**:

```
$ git -C /tmp/ue-skills-ref rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297

$ git -C /tmp/ue-skills-ref log -1 --format='%H%n%ci%n%s'
a6aa73ada02a9fb1f5415bec491f9942c519b297
2026-09-17 13:28:32 +1200
[MCP] Permit safe concurrent tool calls

$ git -C /tmp/ue-skills-ref remote -v
origin  https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin (fetch)
origin  https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin (push)

$ git -C /tmp/ue-skills-ref status --porcelain
(empty — working tree clean)

$ git -C /tmp/ue-skills-ref ls-files | wc -l
12
```

Vendored corpus copy is byte-identical, all 12 tracked files **[O]**:

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

$ find corpus/knowledge/unreal-mcp/upstream -type f | wc -l
12
```

12/12 `OK`, 12 vendored files, 12 tracked files — the vendored tree is exactly
the pinned tree. Every line pointer in §2 and §4 resolves inside that tree.

Shas for the four files this card quotes **[O]**:

```
483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e  upstream/README.md
7ef8b991a82f591c5776bb5fa167c2bc2269fd00338ed3e8534eacc551d038fa  upstream/skills/unreal-mcp/SKILL.md
bd16206ea142dc9cc1950b88af526a3137072ea152c5662e8549d21bc18a3b8a  upstream/skills/unreal-mcp/references/setup.md
dbed002b4a46ab104274a31eb6682c3d277ce669216d0378df709f51567c3113  upstream/skills/unreal-mcp/references/operations.md
```

---

## 7. Unlock condition

`static-only` → any higher label requires a **live Unreal Editor with the MCP
server reachable**. Concretely, all four must hold:

1. **Engine present.** An Unreal Engine 5.x install on this host. Blocked:
   AUR PKGBUILD needs SSH access to the private `EpicGames/UnrealEngine` repo;
   the `gh` account is not Epic-linked (§5). Operator action required.
2. **Plugins enabled.** `ModelContextProtocol` **and** `AllToolsets` both
   `"Enabled": true` in the project `.uproject` — the source of the two-plugin
   requirement is `upstream/skills/unreal-mcp/references/setup.md` §1, which
   states that with only `ModelContextProtocol` enabled the server starts but
   exposes no tools.
3. **Server reachable.** `ss -ltn` shows the configured port bound
   (default `8000`, `upstream/skills/unreal-mcp/references/setup.md` §2), and a
   `.mcp.json` exists at the build-appropriate root (§3). Note upstream's own
   warning that a connected proxy or cached tool list does **not** prove
   reachability — the confirmation must be a successful read-only tool call.
4. **UI toolset discovered, not assumed.** `list_toolsets` must actually return
   a UI/UMG/Slate toolset, then `describe_toolset` on it must return the schemas.
   This is the load-bearing step: §3 shows the pinned tree never names such a
   toolset, so its existence is **unconfirmed**, not merely unexecuted. If
   `list_toolsets` comes back without one, this card's `static-only` label stays
   correct and the README's UI bullet is unbacked by the registry.

### The first bounded probe to run once unlocked

Smallest probe that could move this card off `static-only`, in order:

1. `list_toolsets` → record the returned set verbatim; check for a UI/UMG/Slate
   entry. **This alone is the highest-value result**: it resolves the §3
   unknown — whether the README's UI bullet maps to a real toolset at all.
2. `describe_toolset` on the UI toolset (if any) → capture the tool names and
   full argument/return schemas into a new receipt; that converts every
   "schema unknown" cell in §4.
3. A read-only call only — e.g. list or inspect an existing `WBP_` widget asset
   in a scratch project. No widget creation, no asset mutation, until the
   read-only round-trip is proven.
4. Only then a bounded creation probe, and per
   `upstream/skills/unreal-mcp/SKILL.md:33`, the probe **must** read the returned
   status explicitly and treat anything other than an explicit success as a stop.
   A `static-only` → `verified-here` promotion requires the recorded status from
   a real call, not a `rc=0`.

### What would falsify this card

- A `list_toolsets` output naming a UI/UMG/Slate toolset → §3's discriminating
  negative was an artifact of upstream documentation, and the card's *coverage*
  claim narrows to "documentation gap" rather than "surface absent".
- A toolset name containing UMG/Slate/Widget appearing in a **newer** upstream
  revision than the pinned SHA → this card is SHA-scoped and would need
  re-issue against the new pin, not amendment in place.
- A `WidgetBlueprint` / `UUserWidget` / `SlateAutomation` token found in the
  pinned tree by a wider probe than the one in §3 → the probe was
  under-sensitive; §3's command is the one to re-run and extend.

---

## 8. Bounded scope of this card

- One of 13 subsystem verdict cards (C2). Covers **UI only**; the other 12
  domains are other seats' cards.
- SHA-scoped: every claim is against
  `a6aa73ada02a9fb1f5415bec491f9942c519b297`. It does not describe `main` at any
  other time.
- Static-only claims about *documentation*, not about Unreal Engine itself. The
  absence of a UI toolset name from this plugin's README does not mean Unreal
  lacks UI tooling; UMG and Slate automation plainly exist as engine features.
  It means **this plugin's pinned bytes do not document how to reach them**.
- No runtime claim is made or implied. `verified-here` and `unproven-runtime`
  are both inapplicable until the §7 unlock condition is met.
