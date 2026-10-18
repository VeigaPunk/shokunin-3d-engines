# Verdict Card — Actors and Scene (spawn / transform / inspect / delete, components, outliner folders)

**Subsystem:** Actors and Scene (README domain 1 of 13) — the live-level actor set and its
organizational surfaces
**Label:** `unproven-runtime`
**Seat:** SEAT-31 EXEC
**Card 1 of the 13-subsystem set (C2)**
**Upstream pin:** `EpicGames/unreal-engine-skills-for-claude-code-plugin` @ `a6aa73ada02a9fb1f5415bec491f9942c519b297`
**Vendored at:** `corpus/knowledge/unreal-mcp/upstream/`
**Label basis:** every capability named for this domain is a mutation or read of *live editor
session state*. There is no on-disk artifact, file format, or schema in this domain to inspect
statically, so no part of the surface can be reduced to a local check. The dispatch path that
would carry a call is identified and fully specified in the vendored bytes; only its execution
is missing. That is `unproven-runtime` by the lane's own criterion
(`corpus/knowledge/unreal-mcp/README.md:41`: "`unproven-runtime` | the claim needs the live
editor and nothing was observed | `unproven`").

**Pointer convention (applies to the whole card).** A bare relative path resolves under
`corpus/knowledge/unreal-mcp/upstream/`; a path beginning with `corpus/` is repo-relative.
Shorthand forms used in §2–§4 and §6 expand as follows:

| shorthand in this card | resolves to |
|---|---|
| `README.md:NN` | `upstream/README.md:NN` (the vendored upstream README — the subject of this card) |
| `SKILL.md:NN` | `upstream/skills/unreal-mcp/SKILL.md:NN` |
| `create-toolset/SKILL.md:NN` | `upstream/skills/create-toolset/SKILL.md:NN` |
| `unreal-skill/SKILL.md:NN` | `upstream/skills/unreal-skill/SKILL.md:NN` |
| `references/operations.md:NN` | `upstream/skills/unreal-mcp/references/operations.md:NN` |
| `references/setup.md:NN` | `upstream/skills/unreal-mcp/references/setup.md:NN` |
| `plugin.json:NN` | `upstream/.claude-plugin/plugin.json:NN` |
| `hooks/unreal-context.sh:NN` | `upstream/hooks/unreal-context.sh:NN` |
| `corpus/knowledge/unreal-mcp/README.md:NN` | this subtree's own index (outside `upstream/`) |

The last row is the only non-vendored file quoted in this card, and it is always written in
full so it cannot be confused with the upstream README. §7 spells every path in full.

---

## 1. Why this label, in one line

The domain's entire advertised surface — spawn, transform, inspect, delete actors; manage
components; manage outliner folders — is live-level state that exists only inside a running
editor, and **no static substitute exists for any of it**: not a serialized format, not a
schema, not a signature. The route a call would take is fully documented; the destination is
absent from this host.

## 2. What is verifiable on this host (static, and actually run)

Static verification here establishes **the contract and the routing**, never the behavior. All
paths below are relative to `corpus/knowledge/unreal-mcp/upstream/`.

### 2.1 Byte-identity of every file that mentions the domain

The five files carrying this domain's text were confirmed byte-identical to the pinned clone
(§4, check R1). Full sweep, run from `corpus/knowledge/unreal-mcp/`:

```
$ sha256sum -c .manifest.d/audit-reference.sha256
upstream/skills/create-toolset/SKILL.md: OK
upstream/skills/unreal-mcp/references/operations.md: OK
upstream/skills/unreal-mcp/references/setup.md: OK
upstream/skills/unreal-mcp/SKILL.md: OK
upstream/skills/unreal-skill/SKILL.md: OK
   (12/12 files OK, exit 0)
```

Consequence: every pointer in this card resolves to bytes that provably came from the pin. It
says nothing about whether the behavior described is real.

### 2.2 The capability claim — all of it, in one bullet

| # | Fact | Pointer |
|---|---|---|
| F1 | The **entire** functional description of this subsystem: "**Actors and Scene** - spawn, transform, inspect, and delete actors; manage components and outliner folders". Four verb-groups; no tool name, no parameter, no return shape. | `README.md:100` |
| F2 | The domain is restated as the first item of a flat inventory: "Hundreds of tools ... across 30+ toolsets: actors, blueprints, materials, ...". Aggregate, unverifiable here. | `README.md:3` |
| F3 | Third copy of the claim, in machine-readable plugin metadata (version `3.1.1`). | `.claude-plugin/plugin.json:4` |
| F4 | `actors` heads the toolset-family list inside the core skill: "hundreds of tools across 30+ toolsets (actors, blueprints, materials, ...) registered through Unreal's `ToolsetRegistry`". | `skills/unreal-mcp/SKILL.md:8` |

That is the whole claim. Three prose copies plus one list mention, and nothing operational.

### 2.3 The dispatch contract (how an Actors and Scene call would be addressed)

This is the part of the domain that *is* fully specified — and it is specified uniformly for
all 30+ toolsets, so it applies here verbatim.

| # | Fact | Pointer |
|---|---|---|
| F5 | Tool search is on by default, so the server advertises exactly three meta-tools for the session: `list_toolsets`, `describe_toolset`, `call_tool`. Toolset tools "are **not in `tools/list`**"; they are dispatched server-side through `call_tool` with `toolset_name`, `tool_name`, `arguments`. | `skills/unreal-mcp/SKILL.md:16` |
| F6 | Top-level dispatch (omitting `toolset_name`) is reserved for tools registered directly on the MCP server, and is **rejected** for `call_tool` itself. | `skills/unreal-mcp/SKILL.md:22` |
| F7 | Signatures are knowable only from a live editor: "go straight to `describe_toolset` to confirm the available tools and their signatures". The corpus defers them by construction. | `skills/unreal-mcp/SKILL.md:20` |
| F8 | Tool-search mode is the switch that would make tool names visible upfront: `bEnableToolSearch` on `UModelContextProtocolSettings`, default `true`; `False` registers every toolset tool as a native MCP tool (the hash-mapping commandlet path). | `README.md:82`, `references/operations.md:18-21` |
| F9 | A missing toolset is repaired with `ModelContextProtocol.RefreshTools`; if still missing, its **plugin** may not be enabled in the `.uproject`. | `references/operations.md:13`, `references/operations.md:48` |
| F10 | Default endpoint `localhost:8000`, path `/mcp`. No static `.mcp.json` ships; it is generated by `ModelContextProtocol.GenerateClientConfig ClaudeCode`. | `README.md:70-72`, `references/setup.md:57-79` |

### 2.4 The named toolset(s) this domain would land on — and the naming gap

Upstream never writes `ActorTools`, and never states which toolset owns actors. A
case-sensitive sweep over the whole corpus returns nothing:

```
$ grep -rn "ActorTools" .
$ echo $?
1
```

Two toolsets are named elsewhere in the corpus as *existing* ones, and both are plausible
homes for this domain — but the mapping is a reader's inference, not an upstream statement:

| # | Fact | Pointer |
|---|---|---|
| F11 | `LevelTools` is listed among existing toolsets that the authoring skill may extend — "existing one such as `BlueprintTools`, `StaticMeshTools`, `ObjectTools`, `LevelTools`, or `MaterialTools`". This is the **only** occurrence of `LevelTools` in the entire corpus: one name, zero members. | `skills/create-toolset/SKILL.md:3` |
| F12 | `ObjectTools` "already provides generic UObject property get/set" and must not be reimplemented — twice stated, and the corpus's only concrete statement of where generic object property access lives. Actors are UObjects, so actor property read/write plausibly routes here. | `skills/create-toolset/SKILL.md:20`, `skills/create-toolset/SKILL.md:45` |
| F13 | The one concrete actor-property example in the corpus: "read or write properties on actors (e.g. `bIsLocked` on `BP_DoorActor`)". Names a property and an asset; names no tool. | `skills/unreal-mcp/SKILL.md:3` |
| F14 | The only transform-typed artifact in the corpus is a serialization converter, not a tool: `FToolsetTransformConverter` "exposes `FTransform` location, rotation, and scale as optional fields". This is the closest the corpus comes to specifying the *shape* of a transform, and it is a C++-authoring detail for people writing new toolsets. | `skills/create-toolset/SKILL.md:211` |

**Naming gap, stated plainly:** the domain is asserted to exist; the toolset serving it is
not pinned by upstream. `LevelTools` (F11) is the best candidate by name and appears exactly
once, in a different skill's trigger description. A reader can therefore say *"an Actors and
Scene surface exists and is reached through `call_tool`"* and cannot say *"it is
`LevelTools`"*.

### 2.5 The one upstream artifact that does execute here (adjacent, not domain)

The SessionStart hook is the only upstream code that runs on this host. It is **not** part of
the Actors and Scene domain — it injects project-context steering — but it is the sole
executable receipt available in this corpus and it does mention `Outliner` and `PlayerStart`
in the trigger vocabulary it helps route (F16). Reported here as an adjacent, honestly-scoped
receipt:

```
$ shellcheck upstream/hooks/unreal-context.sh
   (no output)
$ echo $?
0

$ cd /tmp/r101seat31/Source/MyGame   # fake UE project: MyGame.uproject one level up
$ bash upstream/hooks/unreal-context.sh | jq -e '.hookSpecificOutput.hookEventName == "SessionStart"'
true
```

So the *harness* half of the plugin is exercised end-to-end here; the *tool* half cannot be.
That asymmetry is the whole shape of this card.

### 2.6 Triggering (when the agent is told to reach for actors at all)

| # | Fact | Pointer |
|---|---|---|
| F15 | The skill triggers on concrete actor verbs: "spawn/move/duplicate/transform actors in a level, open a `.uproject`, add things around a PlayerStart". The first trigger listed for the whole plugin is this domain. | `skills/unreal-mcp/SKILL.md:3` |
| F16 | Trigger vocabulary also includes `Outliner`, `PlayerStart`, and UE C++ types (`AActor`, `UMyComponent::Method`, `UPROPERTY`). Upstream: "Treat as Unreal context even without the word" — the literal word *Unreal* that follows is YAML-escaped in the frontmatter as `\"Unreal\"`. | `skills/unreal-mcp/SKILL.md:3` |
| F17 | The plugin's own end-to-end smoke test is an Actors and Scene call. Upstream, verbatim: `5. Try: "List all actors in the current level".` The vendor's cheapest proof that the integration works at all is a read of this domain. | `README.md:66` |
| F18 | Adjacent but a different card: the **Editor** domain covers "actor/asset selection", i.e. selection is *not* in this card. Keep the boundary at mutation/inspection of the actor set. | `README.md:111` |

### 2.7 Behavioral hazards that apply to actor mutation

These are the corpus's only operational claims touching this domain, and all of them are
warnings.

| # | Fact | Pointer |
|---|---|---|
| F19 | "**Save first, then save again.** ... MCP edits are not always undoable, especially across compilation boundaries. Treat anything that touches multiple assets as a destructive operation that needs a recovery point." Directly governs bulk actor deletion. | `skills/unreal-mcp/SKILL.md:30` |
| F20 | "**Control concurrent calls.** ... Serialize dependent calls and mutations that can affect the same asset or editor state. ... Multiple agents can use one editor, but their conflicting changes can cause adverse effects." Actor transforms are the canonical shared mutable state. | `skills/unreal-mcp/SKILL.md:32`, `references/operations.md:51` |
| F21 | "**Always check the result.** ... many tools return a status that flips between success and failure with no exception thrown on the wire. ... Treat anything that isn't an explicit success as a stop." | `skills/unreal-mcp/SKILL.md:33` |
| F22 | "**Mind PIE.** Editor-only tools (asset creation in particular) behave differently while Play-in-Editor is active." (PIE = Play-in-Editor, the in-editor game preview.) A spawn issued under PIE is a different situation from one issued on the level. | `skills/unreal-mcp/SKILL.md:34` |
| F23 | Calls "hang or return errors" while the editor is busy "compiling, loading a level, or in PIE" — loading a level is named as a hang cause, which is exactly the state an actor operation runs against. | `references/operations.md:49` |
| F24 | C++ must be compiled before dependent work: drive `LiveCodingToolset.CompileLiveCoding`, which blocks until the compile finishes. | `skills/unreal-mcp/SKILL.md:31`, `skills/create-toolset/SKILL.md:234` |

### 2.8 Prerequisites and gating (what must be true before any actor call can work)

| # | Fact | Pointer |
|---|---|---|
| F25 | Two plugins are required and `AllToolsets` is the one that "provides the tools; the server exposes none without it". It is editor-only with `EnabledByDefault` off, so it must be enabled explicitly in the `.uproject`. With only `ModelContextProtocol`, the server starts and exposes nothing — this domain included. | `README.md:17`, `references/setup.md:12-31` |
| F26 | The editor must be **running** with the MCP server started (`ModelContextProtocol.StartServer`, or `bAutoStartServer=True`). The optional proxy keeps the *client* session open while the editor is down, but it does not make the tools callable: "The editor must still run for live tool calls." | `README.md:18`, `references/setup.md:35-46`, `references/setup.md:85` |
| F27 | A connected proxy, a visible cached catalog, or a successful `unreal_mcp_status` **does not** prove Unreal is reachable; only a successful read-only Unreal tool call would. Stated four times in the corpus — the strongest repeated warning it contains. | `README.md:65`, `README.md:78`, `skills/unreal-mcp/SKILL.md:24`, `references/operations.md:34`, `references/setup.md:131` |
| F28 | Linux is a supported client platform (macOS / Linux / Windows-via-Git-Bash-or-WSL); the only bash dependency is the SessionStart hook. | `README.md:23-28` |
| F29 | When no editor is available, the authoring skill's fallback is to "search the codebase for folders named `Toolsets` and read the C++ headers or Python toolset files there" — the only documented route to signatures without a live editor, and it requires engine source this host does not have. | `skills/create-toolset/SKILL.md:26` |

## 3. What needs a live editor — the whole domain, item by item

Every clause of F1, with what would have to exist to test it. There is no static half in this
table; that is the point of the card.

| Capability (F1 clause) | What is required | Can a static check substitute? |
|---|---|---|
| **spawn** actors | A loaded level + a spawnable class; `call_tool` with the owning toolset; a level to observe the result in | No — a spawned actor is session state. No spawn API signature is in the corpus (F5, F7). |
| **transform** actors | The same, plus a way to read back location/rotation/scale to prove the write landed | No. The only transform-*shaped* artifact is a JSON converter for toolset authors (F14), not a tool contract. |
| **inspect** actors | `list_toolsets` → `describe_toolset` to learn the tool, then a read call against a known actor | No — but this is the **cheapest** unlock (F17, §6). |
| **delete** actors | A recovery point first (F19); then a call; then a read-back to confirm absence | No. Destructive, and "not always undoable" (F19). |
| **manage components** | A live actor to attach/detach on; the component API surface, which is unnamed in the corpus | No. Zero component tool names anywhere (§3.1 sweep). |
| **manage outliner folders** | The editor's outliner — pure editor-UI organizational state, not part of any saved asset | No. This is the *most* runtime-only item in the card: outliner folders have no file representation to inspect at all. |

### 3.1 Exhaustive mention sweep — the size of the whole documented surface

Command run from `corpus/knowledge/unreal-mcp/upstream/` (word-anchored, `\b`):

```
$ for t in actor scene outliner component spawn transform level playerstart pie; do
    printf "%s: %s mentions / %s files\n" "$t" \
      "$(grep -rniE "\b$t" . | wc -l)" "$(grep -rliE "\b$t" . | wc -l)"; done
actor: 7 mentions / 3 files
scene: 1 mentions / 1 files
outliner: 2 mentions / 2 files
component: 2 mentions / 2 files
spawn: 2 mentions / 2 files
transform: 2 mentions / 2 files
level: 11 mentions / 6 files
playerstart: 1 mentions / 1 files
pie: 2 mentions / 2 files
```

The anchor matters: **without** it, `actor` reports 8 mentions / 4 files, because
`grep -rniE "actor"` also matches "generic re**factor**s that happen to touch a toolset file"
in `skills/create-toolset/SKILL.md:3` — a false positive, and the one that would otherwise
inflate this domain's footprint. With `\b` the exact hit set is:

```
$ grep -rniE "\bactor" . | cut -d: -f1-2
./README.md:3
./README.md:66
./README.md:100
./README.md:111
./.claude-plugin/plugin.json:4
./skills/unreal-mcp/SKILL.md:3
./skills/unreal-mcp/SKILL.md:8
```

Interpretation, with each hit read:

- **`actor` (7/3):** `README.md:3` (inventory), `:66` (smoke-test prompt), `:100` (the
  domain bullet), `:111` (the **Editor** card's "actor/asset selection" — not this one,
  F18); `plugin.json:4` (metadata copy of `:3`); `SKILL.md:3` (one line, the trigger list,
  containing "actors" three times but counted once) and `SKILL.md:8` (toolset-family list).
  Every hit is prose; none names a tool.
- **`scene` (1/1):** only inside the domain's own bullet, `README.md:100`.
- **`outliner` (2/2):** `README.md:100` and `SKILL.md:3` (trigger vocabulary). No tool, no
  folder model, no parent/child semantics.
- **`component` (2/2):** `README.md:100` ("manage components") and
  `create-toolset/SKILL.md:211` ("location, rotation, and scale as optional fields" —
  the word means *transform component*, not an actor component). **So the corpus contains no
  actor-component concept at all beyond one verb in a bullet.**
- **`spawn` / `transform` (2/2 each):** both only in `README.md:100` and `SKILL.md:3`, both
  as trigger verbs.
- **`level` (11/6):** the most scattered term, and it splits into three groups:
  - *Domain-relevant (3):* `README.md:66` ("current level", the smoke test), `SKILL.md:3`
    ("actors in a level", trigger), and `create-toolset/SKILL.md:3` — which is the
    **`LevelTools`** token itself, i.e. the F11 pointer. That the only "level" hit in a
    toolset-name position is inside a *different* skill's prose is the naming gap of §2.4.
  - *Hazard-relevant (1):* `references/operations.md:49` — "Editor may be busy compiling,
    loading a level, or in PIE", the F23 hang cause. Loading a level is precisely the state
    an actor operation runs against, so this one belongs to the domain.
  - *Unrelated (7):* `create-toolset/SKILL.md:54` ("at every level"), `:108`/`:283` ("in the
    current level", template docstrings about a fictional `MyThing`), `hooks/unreal-context.sh:14`
    ("top-level markers"), `SKILL.md:22` ("Top-level dispatch"), `unreal-skill/SKILL.md:3`
    ("harness-level"), `README.md:106` (Level *Sequences* — the Sequencer card's scope).
- **`playerstart` (1/1)** and **`pie` (2/2):** trigger vocabulary and the PIE hazard (F22).

Tool-name-shaped tokens across the entire corpus:

```
$ grep -rnoE "[A-Za-z]+Tools\.[A-Za-z_]+" . | sort -u
./skills/unreal-mcp/SKILL.md:16:BlueprintTools.create
./skills/unreal-mcp/SKILL.md:16:SequencerTools.create_level_sequence
```

**Two, corpus-wide, and neither belongs to this domain.** Both appear as negative examples of
names deliberately *absent* from `tools/list`. There is no `spawn_actor`, no `delete_actor`,
no `set_transform`, no `create_folder` token anywhere in the 995 content lines.

## 4. Host receipts (re-derived this round, not quoted)

| # | Check | Command actually run | Observed |
|---|---|---|---|
| R1 | Vendored bytes match the pin | `sha256sum -c .manifest.d/audit-reference.sha256` | 12/12 `OK`, exit 0 |
| R1b | Vendored tree equals the clone | `diff -r --brief corpus/knowledge/unreal-mcp/upstream /tmp/ue-skills-ref -x .git` | no output, exit 0; `find -type f` → 12 = 12 |
| R2 | Clone is at the pinned SHA | `git -C /tmp/ue-skills-ref rev-parse HEAD` | `a6aa73ada02a9fb1f5415bec491f9942c519b297` — equals the pin |
| R3 | Editor binary absent | `which UnrealEditor UnrealEditor-Cmd ue4editor` | `which: no UnrealEditor in (...)`, `no UnrealEditor-Cmd`, `no ue4editor` |
| R4 | No engine tree anywhere | `find / -xdev \( -name 'UnrealEditor*' -o -name 'UE4Editor*' -o -name 'UnrealBuildTool*' \) -not -path '*/proc/*'` | no output (bounded, 45 s) |
| R5 | No UE project on disk | `find /home /opt /srv -name '*.uproject'` ; `ls -d /home/vgpnk/UnrealEngine /opt/UnrealEngine /usr/share/UnrealEngine` | no output ; `no engine install dir` |
| R6 | No MCP server listening | `ss -ltnp \| grep -E ':800[0-9]'` | no output — no listener on 8000–8009 |
| R7 | Endpoint refuses connection | `curl -s -m 3 -o /dev/null -w '%{http_code}' http://127.0.0.1:8000/mcp` | `http_code=000`, curl exit 7 (connection refused) |
| R8 | No generated client config | `ls -la .mcp.json` | `No such file or directory` |
| R9 | Python cannot reach the editor | `python3 -c "import unreal"` ; `importlib.util.find_spec('unreal')` | `ModuleNotFoundError: No module named 'unreal'` ; `unreal spec: None` |
| R10 | AUR package not installed | `pacman -Q unreal-engine` ; `pacman -Qs unreal` | `error: package 'unreal-engine' was not found` ; no output |
| R11 | Engine fetch is SSH-gated | `curl -s "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=unreal-engine"` then `grep -n 'git@github.com'` | `http=200`, 527 lines; `280: if ! git ls-remote git@github.com:EpicGames/UnrealEngine &>/dev/null; then`; `327:` / `336:` `git clone --depth=1 --branch=${pkgver}-release git@github.com:EpicGames/UnrealEngine` |
| R12 | The SSH gate is genuinely closed | `git ls-remote git@github.com:EpicGames/UnrealEngine` | `git@github.com: Permission denied (publickey).` / `fatal: Could not read from remote repository.` |
| R13 | GitHub auth is not Epic-linked | `gh auth status` ; `gh api repos/EpicGames/UnrealEngine` | logged in as `VeigaPunk`, scopes `gist, read:org, repo, workflow` ; `{"message":"Not Found", ... "status":"404"}` |
| R14 | Host capacity | `nproc` / `free -g` / `df -h /` | 32 cores; 30 GB RAM; 780 GB free on `/` |
| R15 | Toolchain present | `jq --version` ; `python3 -VV` ; `shellcheck --version` ; `which docker` | `jq-1.8.2`; `Python 3.14.7`; `ShellCheck 0.11.0`; `/usr/bin/docker` |
| R16 | Lutris available (non-UE route) | `pacman -Ss '^lutris$'` | `extra/lutris 0.5.22-3` |
| R17 | Adjacent artifact executes | `shellcheck upstream/hooks/unreal-context.sh` ; hook run from a fake `.uproject` dir piped to `jq -e` | exit 0, no output ; `true` |

R11–R13 re-derive the blocker rather than quoting it: the AUR PKGBUILD gates on SSH to a
private repo, the SSH key is rejected, and the authenticated GitHub account cannot see
`EpicGames/UnrealEngine` (404). The gate is on the **operator's Epic↔GitHub account link**,
which is not in place. Nothing downstream is attemptable.

## 5. Why `unproven-runtime`, and not the other two labels

- **Not `verified-here`:** no actor tool call was made and none can be. No `list_toolsets`
  output, no `describe_toolset` result, no spawned actor, no transform read-back exists on
  this host. `verified-here` would require a receipt of a bounded run; R6–R9 show there is
  nothing to run against.
- **Why `unproven-runtime` rather than `static-only`:** the two labels differ on whether a
  real runtime path is *identified*. Here it is: the transport, the three meta-tools, the
  `call_tool` argument shape, the endpoint, and the plugin prerequisites are all specified
  (F5–F10, F25–F27), and at least one named toolset is a plausible landing site (F11, F12).
  What is missing is the editor, not the path. Add the decisive structural fact: **every
  capability in this domain is live session state with no on-disk artifact** — the last row
  of §3 (outliner folders) has no file representation whatsoever. So there is no static
  residue that could carry a `static-only` verdict: reading harder cannot test "spawn an
  actor".
- **Residual tension, recorded for the adjudicator:** the sibling card
  `executability/blueprints.md` chose `static-only` on the reasoning that its *tool surface*
  is unspecified, and this card's §2.4 shows the same gap here (no `ActorTools`; `LevelTools`
  named exactly once, in a different skill). If a later round prefers that stricter test, the
  tool-surface section of this card would qualify as `static-only` while the capability set
  would remain `unproven-runtime`. The binding label on this card is `unproven-runtime`,
  taken from the index's label definition (`corpus/knowledge/unreal-mcp/README.md:41`) and
  from the policy line that names "spawning or mutating actors" as an unprovable-here
  operation (`corpus/knowledge/unreal-mcp/README.md:23-24`). Note that the index explicitly
  declines to assign labels — "This index does **not** restate the labels: the binding verdict
  and its evidence live in each card, and only the card is authoritative"
  (`corpus/knowledge/unreal-mcp/README.md:209-211`) — so the label above is argued from this
  card's own evidence, not inherited.

## 6. Unlock condition — engine install

The label moves only through this chain, in order. Step 1 is operator-owned and blocking;
nothing below it can be attempted first.

1. **Operator action (blocking, not automatable here):** link the Epic Games account to the
   GitHub account so `git@github.com:EpicGames/UnrealEngine` becomes reachable. Receipts
   R11–R13 show this is the single closed gate. Alternatively, a Lutris-managed Epic install
   (R16) — but the Epic login is operator-owned too.
2. **Install the engine** — e.g. the AUR `unreal-engine` 5.8.2-1 package whose PKGBUILD was
   probed in R11, or a launcher build. This is a multi-hour build on this host; not attempted.
3. **Create/open a `.uproject` with both `ModelContextProtocol` and `AllToolsets` enabled**
   (F25). Without `AllToolsets` the server starts and exposes no tools — this domain
   included. This is the failure mode that would silently produce an empty Actors and Scene
   surface.
4. **Launch the editor and start the server:** `ModelContextProtocol.StartServer`, or
   `bAutoStartServer=True` (F26).
5. **Generate the client config:** `ModelContextProtocol.GenerateClientConfig ClaudeCode`,
   producing `.mcp.json` at the location matching the build kind (F10).
6. **First real verification, the cheapest possible, and it is this domain:**
   `list_toolsets`, then `describe_toolset` on the candidate, then
   `"List all actors in the current level"` (F17). That single read is the vendor's own
   end-to-end smoke test and converts §2.4's naming gap — the toolset name, its members,
   their signatures — from unknown to known.
7. Only then can spawn / transform / delete / components / outliner folders be tested, and
   each would still need its own `call_tool` receipt, a recovery point (F19), and serialized
   execution (F20) before it could be called verified.

Until step 1 happens, every Actors and Scene claim in this card is a document claim. **No
actor tool has been executed on this host, and none can be.**

## 7. Cross-references

All paths in this section are repo-relative (unlike §2–§4, where paths are relative to
`corpus/knowledge/unreal-mcp/upstream/`).

- Upstream corpus (vendored, byte-identical): `corpus/knowledge/unreal-mcp/upstream/`
- Verification policy and label vocabulary: `corpus/knowledge/unreal-mcp/README.md:12-59`
  (the binary policy), `corpus/knowledge/unreal-mcp/README.md:31-48` (the binary-policy →
  ternary-label mapping table), `corpus/knowledge/unreal-mcp/README.md:204-240` (card index
  and its label-authority caveats)
- Per-file hashes: `corpus/knowledge/unreal-mcp/.manifest.d/seat01.sha256` … `seat11.sha256`,
  reference manifest `corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256`
- Sibling card in this set: `corpus/knowledge/unreal-mcp/executability/blueprints.md`
- Domain census (13 buckets, the source of this card's scope): `reports/round-101/probes/toolset-census.md`
- Round unknowns map (engine-install blocker): `reports/round-101/r101-unknowns-map.md`
- Host engine census: `corpus/knowledge/engines.md` (Unreal row: not installed, not
  executable headless)
