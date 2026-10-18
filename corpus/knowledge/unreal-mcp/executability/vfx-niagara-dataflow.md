# Executability verdict card — VFX (Niagara systems, Dataflow graphs)

Subsystem: **VFX** — "author Niagara systems and Dataflow graphs"
(`upstream/README.md:107`).

Verdict: **`static-only`**

Label rationale: every VFX claim below is readable from committed bytes in the
vendored tree and was re-derived by the commands shown. **No** VFX operation was
executed, because no Unreal Editor exists on this host and the upstream ships no
VFX tool signature to execute against. This card is a content-availability
measurement of the upstream plugin, not a runtime test.

---

## 0. Provenance and scope

| item | value | how established |
|---|---|---|
| upstream | `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin` | round context |
| pinned SHA | `a6aa73ada02a9fb1f5415bec491f9942c519b297` | `git -C /tmp/ue-skills-ref rev-parse HEAD` → `a6aa73ada02a9fb1f5415bec491f9942c519b297` |
| vendored tree | `corpus/knowledge/unreal-mcp/upstream/` | this repo |
| byte identity | **confirmed** | `diff -rq /tmp/ue-skills-ref corpus/knowledge/unreal-mcp/upstream --exclude=.git` → no output, `exit=0` |
| content files | **12** (`.gitignore`, `CODEOWNERS`, `LICENSE`, `README.md`, `.claude-plugin/plugin.json`, `hooks/hooks.json`, `hooks/unreal-context.sh`, `skills/unreal-mcp/SKILL.md`, `skills/unreal-mcp/references/setup.md`, `skills/unreal-mcp/references/operations.md`, `skills/unreal-skill/SKILL.md`, `skills/create-toolset/SKILL.md`) | `find . -path ./.git -prune -o -type f -print` |
| total bytes | **63556** | `find . -path ./.git -prune -o -type f -print0 \| xargs -0 wc -c` |

The subsystem sits in the upstream README's 13-bullet capability enumeration
(`README.md:100–112`, `grep -c "^- \*\*" README.md` → **17** across the file, of
which lines 100–112 are the 13 domain bullets; VFX is line 107).

---

## 1. What upstream actually says about VFX (positive inventory)

Exhaustive: `grep -rniE "niagara|dataflow|vfx" .` over the vendored tree.

| file | line | text | character of evidence |
|---|---|---|---|
| `README.md` | 3 | `...materials, Niagara, Control Rigs, Sequencer...` | **name-drop** in a capability list |
| `README.md` | 107 | `- **VFX** - author Niagara systems and Dataflow graphs` | **name-drop** — the only Dataflow mention in the entire repo |
| `.claude-plugin/plugin.json` | 4 | same sentence as `README.md:3` | **name-drop**, duplicated in metadata |
| `skills/unreal-mcp/SKILL.md` | 3 | `...create or edit a Blueprint/Widget/Material/Niagara/...` + asset prefix `NS_` | **trigger phrase**, in the skill's YAML `description` |
| `skills/unreal-mcp/SKILL.md` | 8 | `...materials, Niagara, Sequencer, Control Rigs...` | **name-drop** |
| `skills/unreal-mcp/references/operations.md` | 48 | `A toolset you expect (e.g. \`NiagaraTools\`) is missing` | **negative example** — a *troubleshooting symptom*, not a tool reference |

Totals: `grep -roiE "niagara" . \| wc -l` → **6** occurrences across **4** files
(`grep -rliE "niagara\|dataflow\|vfx" . \| wc -l` → `4`). `grep -rniE "dataflow" .`
→ **exactly 1 line** (`README.md:107`). `grep -roE "NS_" . \| wc -l` → **1**
(the asset-prefix list in `SKILL.md:3`).

Every VFX mention is **prose**. None is a tool name with a schema, none is a
`call_tool` example, none is an argument list.

---

## 2. Negative checks — what is absent (the load-bearing evidence)

Absence is what forces `static-only`; each count is a command that was run.

| probe | command | result |
|---|---|---|
| VFX tool names | `grep -rhoE "\b[A-Za-z]+Tools\b" . \| sort \| uniq -c` | `NiagaraTools` → **1** (operations.md:48, a *missing*-toolset symptom); `DataflowTools` → **0** |
| concrete tool calls | `grep -rhoE "[A-Za-z]+Toolset\.[A-Za-z_]+" . \| sort -u` | **5 distinct real toolsets, 10 occurrences** — `LiveCodingToolset.CompileLiveCoding` (3), `ProgrammaticToolset.execute_tool_script` (1), `AIAssistantToolset.GetDockedContext` (1), `AgentSkillToolset.ListSkills`/`GetSkills` (1+1), plus the doc example `MyToolset.find_things` (3). Bare toolset names appear generically: `ObjectTools` (3), `BlueprintTools` (3), `StaticMeshTools` (2), `AssetTools` (2), `MaterialTools` (1), `LevelTools` (1), `SequencerTools` (1). **Zero are VFX.** |
| Niagara internals | `grep -roE "Emitter\|Renderer\|Particle\|Simulate\|Cascade\|NiagaraSystem\|NiagaraComponent\|NiagaraEmitter\|FNiagara" .` | **all 0**. `Module` matches 4× and `module` 3×, but every hit is generic UE C++ module prose — the engine-module comment in `hooks/unreal-context.sh:15–16` and the `FMyToolsetModule`/`IModuleInterface`/`StartupModule` registration example in `create-toolset/SKILL.md:182–192`. **None is a Niagara module.** |
| asset format | `grep -rioE "uasset" .` | lowercase `uasset` → **0**; the 4 hits are `UAsset` in `unreal-skill/SKILL.md` (lines 3/35/88/90) and refer to **Agent Skill** assets, not VFX assets |

**Consequence.** The upstream defines the VFX *domain* as existing, but ships
**no VFX tool contract**. An agent following `skills/unreal-mcp/SKILL.md` must
discover VFX tools at runtime via `list_toolsets` → `describe_toolset` →
`call_tool`; the repo never names one. So the vendored content **cannot** yield
a VFX tool schema to validate statically — only the *expectation* that such a
toolset may be registered.

---

## 3. Executability chain (why runtime is unreachable here)

The upstream states its own prerequisites (`README.md:15–19`): Unreal Editor
with the **`ModelContextProtocol`** and **`AllToolsets`** plugins enabled, and
**"Editor running to execute tools"**. Each link was probed:

| link | probe | observed |
|---|---|---|
| editor binary | `which UnrealEditor UnrealEditor-Cmd` | `no UnrealEditor in (...)` / `no UnrealEditor-Cmd in (...)` |
| engine tree | `ls /opt/unreal* /home/vgpnk/UnrealEngine` | `No such file or directory` (both) |
| live process | `pgrep -af -i "unreal\|UnrealEditor"` | no Unreal Editor process (only this shell's own grep line matched) |
| MCP endpoint | `timeout 5 bash -c 'exec 3<>/dev/tcp/127.0.0.1/8000'` | `Connection refused` → port CLOSED (upstream default port, `README.md:70`) |
| engine acquisition | `git ls-remote https://github.com/EpicGames/UnrealEngine` | `remote: Repository not found.` / `fatal: repository ... not found` |
| `AllToolsets` | vendored `skills/unreal-mcp/references/setup.md:14,31` | editor-only aggregator, `EnabledByDefault` **off**, must be enabled explicitly — and it is the *only* thing that "provides the tools" |

`AllToolsets` matters for this card specifically: without it "the server starts
but exposes no tools" (`setup.md:14`). Since the editor is absent, the toolset
that would register any `NiagaraTools` never loads. Host receipts for the
blocked engine install (AUR `unreal-engine` PKGBUILD requiring SSH to
`git@github.com:EpicGames/UnrealEngine`, blocked pending operator Epic-account
linking) are carried by the round context and re-confirmed here by the
`ls-remote` failure above.

**Static checks that DO pass** on the vendored bytes (these are real, run
here, and are why the card can claim more than "unread"):

- `shellcheck -s bash hooks/unreal-context.sh` → `exit=0` (the one executable
  script in the repo is clean; it is UE-project *detection*, unrelated to VFX).
- `python3 -c "json.load(...)"` on `.claude-plugin/plugin.json` and
  `hooks/hooks.json` → both parse OK.

These validate the *packaging*, not any VFX behavior.

---

## 4. Verdict and what it does / does not license

**`static-only`.**

- **Licensed:** the upstream plugin *documents VFX as a supported domain*
  (Niagara + Dataflow, `README.md:107`), treats Niagara as a trigger signal
  (`SKILL.md:3`, incl. `NS_`), and anticipates a `NiagaraTools` toolset whose
  absence is a known symptom (`operations.md:48`).
- **NOT licensed:** that any VFX tool exists, its name, its arguments, its
  return shape, its success/error semantics, or that any Niagara/Dataflow
  authoring call succeeds. `README.md:107` is a marketing-grade bullet; the
  repo carries **zero** VFX tool signatures to check it against. A Dataflow
  toolset is never even hypothesized upstream (0 mentions beyond the README
  bullet).
- **Do not** cite this card as evidence that VFX authoring works, or that the
  lane can produce VFX fixtures. It is a coverage measurement of upstream
  content, explicitly bounded.

---

## 5. Unlock condition

To move this card from `static-only` to **`verified-here`**, all of the
following must hold, in order:

1. **Operator action (out of lane scope):** link the Epic account so
   `git@github.com:EpicGames/UnrealEngine` becomes reachable, then install an
   engine ≥ 5.4 (Niagara/Dataflow toolset plugins are editor-only). `ls-remote`
   must stop returning `Repository not found`.
2. **Editor up + plugins on:** enable `ModelContextProtocol` **and**
   `AllToolsets` (or the specific VFX toolset plugin) in the `.uproject`
   (`setup.md:6,14–31`); start the server (`ModelContextProtocol.StartServer`,
   `operations.md:11`) so `/dev/tcp/127.0.0.1/8000` stops refusing.
3. **Discover the contract:** `list_toolsets` → `describe_toolset` on the
   Niagara (and, if present, Dataflow) toolset; record the real tool names and
   schemas — this is the missing artifact step 0 could not supply.
4. **Execute a bounded, reversible call:** one read-only VFX query first, then
   a minimal authoring call in a **throwaway** project (upstream warns MCP edits
   are not always undoable and can mutate VCS-tracked assets,
   `skills/unreal-mcp/SKILL.md:30` + `README.md:94`), with a save/commit
   recovery point.
5. **Capture a receipt** (command, output, project path, editor build) and have
   a **non-author verifier** reproduce it — per the lane's engine-census rule
   that a row may move to "executable headless" only with a saved receipt *and*
   a non-author verifier (`corpus/knowledge/engines.md`, Rules).

Partial unlock: step 3 alone would raise the card to a documented-contract
level while remaining `unproven-runtime`; only steps 4–5 reach `verified-here`.

---

## 6. Cross-references

- Byte-identity + hashes: `corpus/knowledge/unreal-mcp/.manifest.d/` (per-seat
  manifests; this card's vendored blobs re-hashed in §0).
- Engine execution reality: `corpus/knowledge/engines.md` — Unreal Engine row
  `installed = no`, `executable headless = no`.
- Static Unreal precedent: `corpus/artifacts/unreal-r22/README.md` (self-authored
  `.uplugin` descriptor, "static only ... was not loaded by Unreal Editor").

Confidence marks: **[O]** receipt-pinned observation (every count and probe
above), **[I]** inference (`AllToolsets` gating the VFX toolset — inferred from
`setup.md:14` plus the absent editor), **[?]** unknown (whether a `NiagaraTools`
toolset exists at all, and every Dataflow contract).
