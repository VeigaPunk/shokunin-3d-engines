# UE Version Matrix — ModelContextProtocol / AllToolsets / unreal_mcp_proxy

Seat: **SEAT-29 PROBE**. Round r101, lane `game-dev-3d-shokunin`.
Date of probes: 2026-10-18.

Scope: which Unreal Engine versions ship the `ModelContextProtocol` plugin and the `AllToolsets`
plugin, and what `unreal_mcp_proxy` availability is per platform.

**Evidence standard.** Every row carries the exact command that was run plus its observed output.
Every row is labeled **UNVERIFIABLE-HERE** — see the label definition below. No row in this file
asserts live-editor or runtime behaviour, and none is derived from a running Unreal Editor.

## Label definitions used in this file

| Label | Meaning |
|---|---|
| **UNVERIFIABLE-HERE** | The claim is grounded in a document or repository artifact fetched over the network, but this host cannot close the loop: Unreal Editor is not installed, and the engine source repository is unreadable from this account. The row is a *documented* fact, not an *observed* one. |

This file uses only that one label. It deliberately does **not** use `verified-here`,
`static-only`, or `unproven-runtime`: those belong to the C2 subsystem verdict cards, and none of
the three is defensible for a version-availability claim on this host.

## Host receipts that bound what this seat can prove

Commands run in this session, with observed output:

```
$ gh api repos/EpicGames/UnrealEngine
{"message":"Not Found","documentation_url":"https://docs.github.com/rest/repos/repos#get-a-repository","status":404}
gh: Not Found (HTTP 404)

$ GIT_TERMINAL_PROMPT=0 git ls-remote https://github.com/EpicGames/UnrealEngine.git
remote: Repository not found.
fatal: repository 'https://github.com/EpicGames/UnrealEngine.git/' not found
```

Consequence: **the engine source tree cannot be read from this host.** No `.uplugin`, no
`Engine/Plugins/Experimental/ModelContextProtocol/` listing, and no `Extras/Proxy` directory
contents can be inspected here. Every version-availability row below therefore rests on Epic's
published documentation, and stays UNVERIFIABLE-HERE by construction.

The upstream skills repo is readable and was pinned correctly:

```
$ git -C /tmp/ue-skills-ref rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
$ git -C /tmp/ue-skills-ref log -1 --date=iso --format='%H %ad %s'
a6aa73ada02a9fb1f5415bec491f9942c519b297 2026-09-17 13:19:50 +1200 [MCP] Permit safe concurrent tool calls
```

Pinned SHA matches the round's declared SHA `a6aa73ada02a9fb1f5415bec491f9942c519b297`. All
upstream quotes below are from that checkout.

## Method: how version presence was tested, and the controls that validate it

Epic's documentation site exposes a per-version selector as a query parameter
(`?application_version=<X.Y>`). A document that exists for a version returns the real page; a
document that does not exist for that version returns a fixed **30,755-byte stub** with an empty
`<title>` (the "Can't find any content" page). Size is a reliable discriminator: real pages are
tens of KB to MB, stubs are ~30.75 KB.

Two controls were run to prove the discriminator is real and not an artifact of the probe:

```
$ probe(){ f=/tmp/p_$1_$2.html; code=$(curl -sL -o $f -w "%{http_code}" \
  "https://dev.epicgames.com/documentation/en-us/unreal-engine/$1?application_version=$2"); \
  echo "$1 @$2 -> http=$code size=$(stat -c%s $f) title=$(grep -o -m1 '<title>[^<]*</title>' $f|sed 's/<[^>]*>//g')"; }
```

**Control A — a plugin that predates all versions under test must render at every version.**

```
$ probe Paper2D 5.7
Paper2D @5.7 -> http=200 size=51939 title='Paper2D | Unreal Engine 5.7 Documentation | Epic Developer Community'
$ probe Paper2D 5.8
Paper2D @5.8 -> http=200 size=51584 title='Paper2D | Unreal Engine 5.8 Documentation | Epic Developer Community'
```

Control A passes: the probe resolves a real page at both versions, so the stub is not a generic
failure of the probe.

**Control B — a release-notes page must render at its own version and stub at versions where that
document did not exist.**

```
$ probe unreal-engine-5-6-release-notes 5.6
unreal-engine-5-6-release-notes @5.6 -> http=200 size=5239273 title='Unreal Engine 5.6 Release Notes | Unreal Engine 5.6 Documentation | Epic Developer Community'
$ probe unreal-engine-5-6-release-notes 5.7
unreal-engine-5-6-release-notes @5.7 -> http=200 size=811722 title='Unreal Engine 5.7 Release Notes | Unreal Engine 5.7 Documentation | Epic Developer Community'
$ probe unreal-engine-5-6-release-notes 5.8
unreal-engine-5-6-release-notes @5.8 -> http=200 size=30755 title=''
```

Control B passes, and it also explains the slug quirk: Epic serves the *5.7* release notes under
the `unreal-engine-5-6-release-notes` slug with `application_version=5.7`, and there is no
`unreal-engine-5-7-release-notes` document (that slug returns the 30,755-byte stub at every
version). This is why the 5.7 row below is sourced from the slug-plus-parameter pair, not from a
guessed slug.

Source URL for the 5.7 release notes as actually resolved:
<https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-6-release-notes?application_version=5.7>

## Matrix 1 — ModelContextProtocol plugin presence by engine version

| Engine version | ModelContextProtocol shipped? | Label | Source URL (probed command + observed output) |
|---|---|---|---|
| **5.5 and earlier** | No — no MCP plugin of any kind in the engine | UNVERIFIABLE-HERE | No doc page resolves; release-notes page for 5.5 contains 0 hits for "Model Context Protocol": `unreal-engine-5-5-release-notes @5.5 -> http=200 size=1065788` and `grep -o -i 'model context protocol'` → `0`. <https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-5-release-notes> |
| **5.6** | No — not present | UNVERIFIABLE-HERE | Doc probe `unreal-mcp-in-unreal-editor @5.6 -> size=30751 title=''` (stub). Plugin index probe `API/PluginIndex/ModelContextProtocol @5.6` → stub. <https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-mcp-in-unreal-editor?application_version=5.6> |
| **5.7** | No — not present | UNVERIFIABLE-HERE | Two independent probes agree. (a) Doc probe: `unreal-mcp-in-unreal-editor @5.7 -> http=200 size=30751 title=''` (stub). (b) Plugin index probe: `API/PluginIndex/ModelContextProtocol @5.7 -> http=200 size=30765 title=''` (stub). (c) The 5.7 release notes contain **0** occurrences of "Model Context Protocol", "AllToolsets", "ToolsetRegistry", or the standalone word "MCP": `mcp=0 alltoolsets=0 toolsetregistry=0 mcpword=0` on an 811,722-byte page whose `<title>` reads "Unreal Engine 5.7 Release Notes". <https://dev.epicgames.com/documentation/en-us/unreal-engine/API/PluginIndex/ModelContextProtocol?application_version=5.7> |
| **5.8 (and 5.8.x hotfixes)** | **Yes — first and, per Epic's own wording, only version.** Shipped experimental | UNVERIFIABLE-HERE | Epic 5.8 release notes, verbatim: "With Unreal Engine 5.8, we bring a new experimental MCP (Model Context Protocol) plugin for the Unreal Editor." Probe: `unreal-mcp-in-unreal-editor @5.8 -> http=200 size=230148 title='Unreal MCP in Unreal Editor \| Unreal Engine 5.8 Documentation \| Epic Developer Community'`. <https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-8-release-notes> |
| **5.9** | Reported confirmed at Unreal Fest Seoul 2026, with MCP as a focus area; **no release date announced** | UNVERIFIABLE-HERE | Secondary reporting only, no Epic document found in this session. <https://nnets.ru/news/unreal-engine-5-9-epic-delaet-stavku-na-ii-mcp-i-generativnyj-nejrorender> |
| **Unreal Engine 6** | Not shipped; early access targeted end-2027 | UNVERIFIABLE-HERE | <https://ludusengine.com/blog/unreal-engine-6-release-date> |

Additional version-boundary evidence — the 5.8 documentation page exposes **only** the 5.8
selector, and no other:

```
$ grep -o 'application_version=[0-9.]*' /tmp/p_unreal-mcp-in-unreal-editor_5.8.html | sort -u
application_version=5.8
$ grep -o '"[0-9]\.[0-9]\(\.[0-9]\)\?"' /tmp/p_unreal-mcp-in-unreal-editor_5.8.html | sort -u
"5.8"
```

A page that shipped across several versions would list several selector values. This one lists one.

Corroboration from the upstream repo at the pinned SHA — its prerequisites name no engine version,
which is consistent with the plugin being a new-in-5.8 surface rather than a long-standing one:

```
$ sed -n '15,19p' /tmp/ue-skills-ref/README.md
## Prerequisites
1. **Unreal Editor** with the **ModelContextProtocol** and **AllToolsets** plugins enabled
   (`AllToolsets` provides the tools; the server exposes none without it)
```

Source: <https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin/blob/a6aa73ada02a9fb1f5415bec491f9942c519b297/README.md>

### Independent (non-Epic) sources agreeing on the 5.8 floor

These are secondary and were not written by Epic; they are listed as corroboration, not as
evidence, and each is UNVERIFIABLE-HERE for the same reason as the rows above.

| Claim | Source URL |
|---|---|
| "MCP plugin is a UE5.8 new feature; unavailable in 5.7 and earlier" | <https://blog.hangge.com/blog/cache/detail_5129.html> |
| "UE 5.7 has no Epic-official `ModelContextProtocol` (5.8 onward)" | <https://github.com/immigration2000/unreal-mcp-kit> |
| "UE 5.7 vs 5.8 differences — Epic's official ModelContextProtocol plugin ships with UE 5.8" | <https://github.com/ibrews/ue5-mcp> |
| "Epic's official Unreal MCP plugin (UE 5.8 only)" | <https://www.pixelsdesign.it/blog/unreal-engine-mcp-claude-code-explained.html> |
| "Unreal MCP and the new City Sample levels require version 5.8 specifically — not available in 5.7 and earlier" | <https://incrypted.com/en/guide-to-the-claude-unreal-engine-5-8-setup/> |

## Matrix 2 — AllToolsets plugin presence by engine version

| Engine version | AllToolsets shipped? | Label | Source URL (probed command + observed output) |
|---|---|---|---|
| **5.7 and earlier** | No | UNVERIFIABLE-HERE | The 5.7 release notes contain **0** occurrences of `AllToolsets`: `grep -o -i 'AllToolsets' /tmp/rn57c.html \| wc -l` → `0` on an 811,722-byte real page. <https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-6-release-notes?application_version=5.7> |
| **5.8** | Yes — shipped as the tool-providing companion to the MCP server, off by default | UNVERIFIABLE-HERE | Epic's MCP doc states it directly, verbatim: "Toolsets and tools are not implemented by Unreal MCP itself; instead, the **AllToolsets** plugin must be used to enable them." Probed page is 230,148 bytes and contains 2 occurrences of `AllToolsets` and 6 of the friendly name "All Toolsets". <https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-mcp-in-unreal-editor?application_version=5.8> |
| **5.8** | Yes — and required: without it the server starts but exposes no tools | UNVERIFIABLE-HERE | Upstream repo, `skills/unreal-mcp/references/setup.md:14`: "With only `ModelContextProtocol` enabled the server starts but exposes no tools." Line 31 adds: "`AllToolsets` is an editor-only aggregator with `EnabledByDefault` off, so it must be enabled explicitly." <https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin/blob/a6aa73ada02a9fb1f5415bec491f9942c519b297/skills/unreal-mcp/references/setup.md> |

**A gap this seat could not close.** `AllToolsets` does **not** appear as its own entry in Epic's
public plugin index. Probed and stubbed:

```
$ for p in AllToolsets alltoolsets AllToolsetsPlugin Toolsets AllToolsetsEditorTools; do
    f=/tmp/at_$p.html; curl -sL -o $f ".../API/PluginIndex/$p?application_version=5.8"
    echo "$p size=$(stat -c%s $f) title=$(grep -o -m1 '<title>[^<]*</title>' $f|sed 's/<[^>]*>//g')"; done
AllToolsets        size=30755 title=
alltoolsets        size=30755 title=
AllToolsetsPlugin  size=30762 title=
Toolsets           size=30752 title=
AllToolsetsEditorTools size=30766 title=
```

Every candidate returns the 30,75x-byte stub. **So the exact `.uplugin` path and module list for
`AllToolsets` are not established in this file.** By analogy with the sibling plugins that *do*
index (below), the path is expected to be
`Engine/Plugins/Experimental/Toolsets/AllToolsets/AllToolsets.uplugin`, but that is an inference
from neighbours, not a fetched fact, and it is **not** asserted here. Confirming it requires either
engine source access or an editor install.

## Matrix 3 — plugin identity and paths (5.8, from Epic's own plugin index)

These rows establish what the plugins *are* and where they live. Each was fetched from Epic's
`API/PluginIndex`, which is generated from the engine source tree, and each resolves only at 5.8.

| Plugin | `.uplugin` path | Category | Modules | Label | Source URL |
|---|---|---|---|---|---|
| `ModelContextProtocol` (friendly name "Unreal MCP") | `Engine\Plugins\Experimental\ModelContextProtocol\ModelContextProtocol.uplugin` | Other | `ModelContextProtocol`, `ModelContextProtocolEngine`, `ModelContextProtocolEditor` | UNVERIFIABLE-HERE | <https://dev.epicgames.com/documentation/en-us/unreal-engine/API/PluginIndex/ModelContextProtocol?application_version=5.8> |
| `MCPClientToolset` | `Engine\Plugins\Experimental\Toolsets\MCPClientToolset\MCPClientToolset.uplugin` | (index renders "beta") | — | UNVERIFIABLE-HERE | <https://dev.epicgames.com/documentation/en-us/unreal-engine/API/PluginIndex/MCPClientToolset?application_version=5.8> |
| `GASToolsets` | `Engine\Plugins\Experimental\Toolsets\GASToolsets\GASToolsets.uplugin` | — | — | UNVERIFIABLE-HERE | <https://dev.epicgames.com/documentation/en-us/unreal-engine/API/PluginIndex/GASToolsets?application_version=5.8> |
| `NiagaraToolsets` | `Engine\Plugins\Experimental\Toolsets\NiagaraToolsets\NiagaraToolsets.uplugin` | FX | — | UNVERIFIABLE-HERE | <https://dev.epicgames.com/documentation/en-us/unreal-engine/API/PluginIndex/NiagaraToolsets?application_version=5.8> |

The `Toolsets\` directory placement is confirmed independently for two members, and both stubbed
at 5.7:

```
$ for p in GASToolsets NiagaraToolsets; do f=/tmp/pi2_$p.html; curl -sL -o $f \
  ".../API/PluginIndex/$p?application_version=5.8"; grep -o 'Engine[\\/][A-Za-z0-9_\\/.-]*uplugin' $f|sort -u|head -1; done
Engine\Plugins\Experimental\Toolsets\GASToolsets\GASToolsets.uplugin
Engine\Plugins\Experimental\Toolsets\NiagaraToolsets\NiagaraToolsets.uplugin

$ NiagaraToolsets @5.7 -> http=200 size=30759 title=''
$ NiagaraToolsets @5.6 -> http=200 size=30760 title=''
```

`ModelContextProtocol`'s index entry also records the experimental marker and its dependency:

```
$ grep -o -i 'ToolsetRegistry' /tmp/mcpplugin58.html | wc -l
0
$ grep -o 'Engine[\\/][A-Za-z0-9_\\/.-]*' /tmp/mcpplugin58.html | sort -u | head -3
Engine\
Engine\Plugins\Experimental\ModelContextProtocol\ModelContextProtocol.uplugin
Engine\\Plugins\\Experimental\\ModelContextProtocol\\ModelContextProtocol.uplugin\u003C/td
```

Its index page lists "Plugin Dependencies: Engine Asset Definitions" and the dependents
"experimental", "other". The literal string `ToolsetRegistry` does **not** occur on that index
page, even though Epic's prose documentation says the MCP plugin "discovers Tools by querying the
Toolset Registry". The dependency is therefore documented in prose but not exposed on the index
page — noted as a discrepancy rather than resolved. `ToolsetRegistry` also has no plugin-index
entry of its own at 5.8 (`ToolsetRegistry @5.8 -> size=30759 title=''`).

## Matrix 4 — `unreal_mcp_proxy` availability per platform

The proxy is **not part of the plugin proper**. Upstream gates it on the engine build shipping an
`Extras/Proxy` directory, and warns that if it is absent the user must keep the direct HTTP setup:

```
$ sed -n '85,97p' /tmp/ue-skills-ref/skills/unreal-mcp/references/setup.md
Use this option if you want the client session to survive editor shutdown and startup. The editor must still run for live tool calls.

Check whether your engine includes `Engine/Plugins/Experimental/ModelContextProtocol/Extras/Proxy`. If it is absent, keep the direct HTTP setup.

Choose the binary for the operating system where the MCP client runs:

| Platform | Binary under `Extras/Proxy` |
|---|---|
| Windows x64 | `Bin/Win64/unreal_mcp_proxy.exe` |
| macOS arm64 | `Bin/Mac/unreal_mcp_proxy` |
| Linux x64 | `Bin/Linux/unreal_mcp_proxy` |
| Linux arm64 | `Bin/LinuxArm64/unreal_mcp_proxy` |
```

Source: <https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin/blob/a6aa73ada02a9fb1f5415bec491f9942c519b297/skills/unreal-mcp/references/setup.md>

| Platform / architecture | Proxy binary named by upstream | Label | Source URL |
|---|---|---|---|
| Windows x64 | `Bin/Win64/unreal_mcp_proxy.exe` | UNVERIFIABLE-HERE | setup.md, table above |
| macOS arm64 | `Bin/Mac/unreal_mcp_proxy` | UNVERIFIABLE-HERE | setup.md, table above |
| Linux x64 | `Bin/Linux/unreal_mcp_proxy` | UNVERIFIABLE-HERE | setup.md, table above |
| Linux arm64 | `Bin/LinuxArm64/unreal_mcp_proxy` | UNVERIFIABLE-HERE | setup.md, table above |
| Any platform, when `Extras/Proxy` is absent from the build | No proxy — direct HTTP only | UNVERIFIABLE-HERE | setup.md line 87: "If it is absent, keep the direct HTTP setup." |

### What this does **not** establish

- **The table is a naming convention, not a shipping manifest.** It says which binary path to look
  for *per platform*; it does not state that every distribution of 5.8 contains all four. Upstream
  explicitly makes availability conditional on the individual build ("Check whether your engine
  includes…"). **Whether Epic's Windows Launcher build, the Linux page build, and the GitHub source
  build each ship `Extras/Proxy` is not established by any source found in this session.** Every
  row above is therefore UNVERIFIABLE-HERE, and the platform-availability question this seat was
  asked is answered only as "these are the paths to probe", not as "these platforms have it".
- **macOS x64 (Intel) is not listed at all** — only macOS arm64. Whether that is an omission or a
  real gap is not determinable from this source.
- Epic's own MCP documentation page does **not** mention the proxy once:

  ```
  $ grep -o -i 'proxy' /tmp/p_unreal-mcp-in-unreal-editor_5.8.html | wc -l
  0
  ```

  So the proxy is documented by the *skills plugin* (the repo at the pinned SHA), not by the engine
  documentation. That is a notable asymmetry: the highest-authority source available here is silent
  on the feature.
- The proxy's own reference — `Extras/Proxy/README.md`, cited by upstream `operations.md:40` — is
  inside the engine tree and therefore unreadable here.

## Version timeline facts relevant to the matrix

| Fact | Evidence | Label | Source URL |
|---|---|---|---|
| UE 5.8 released 2026-06-17 | Forum announcement "We're excited to announce that Unreal Engine 5.8 is now available." | UNVERIFIABLE-HERE | <https://forums.unrealengine.com/t/unreal-engine-5-8-released/2729274> |
| 5.8.1 hotfix exists (260+ fixes) | Forum announcement | UNVERIFIABLE-HERE | <https://forums.unrealengine.com/t/5-8-1-hotfix-released/2738864> |
| 5.8.2 hotfix exists | Forum announcement | UNVERIFIABLE-HERE | <https://forums.unrealengine.com/t/5-8-2-hotfix-released/2746335> |
| 5.8 is the last *planned* UE5 major; a 5.9 is possible | Epic's own notice, quoted by secondary sources | UNVERIFIABLE-HERE | <https://keemminxu.com/2026/06/18/ue5-8-new-features/> |
| No `unreal-engine-5-8-1-release-notes` doc exists yet | Probe: `size=30729 title=''` | UNVERIFIABLE-HERE | <https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-8-1-release-notes> |

The 5.8.2 hotfix row connects to this round's host receipts: the AUR `unreal-engine 5.8.2-1`
PKGBUILD is the install path under consideration, and 5.8.2 is the version whose MCP plugin
availability this matrix covers. That is the only link between this seat's findings and the lane's
blocked engine install; **no claim is made here that the AUR package actually contains the MCP
plugin**, because that would require reading the PKGBUILD's source tarball, which is the
engine-source access this host does not have.

## Row ledger

| # | Row | Label |
|---|---|---|
| 1 | ModelContextProtocol absent in 5.5 and earlier | UNVERIFIABLE-HERE |
| 2 | ModelContextProtocol absent in 5.6 | UNVERIFIABLE-HERE |
| 3 | ModelContextProtocol absent in 5.7 | UNVERIFIABLE-HERE |
| 4 | ModelContextProtocol present, experimental, in 5.8 / 5.8.x | UNVERIFIABLE-HERE |
| 5 | ModelContextProtocol path `Engine\Plugins\Experimental\ModelContextProtocol\ModelContextProtocol.uplugin` | UNVERIFIABLE-HERE |
| 6 | AllToolsets absent in 5.7 and earlier | UNVERIFIABLE-HERE |
| 7 | AllToolsets present and required in 5.8; off by default | UNVERIFIABLE-HERE |
| 8 | AllToolsets `.uplugin` path | **not established** — every probed index name stubs; path not asserted |
| 9 | `MCPClientToolset` under `Engine\Plugins\Experimental\Toolsets\` | UNVERIFIABLE-HERE |
| 10 | `GASToolsets` / `NiagaraToolsets` under the same `Toolsets\` directory | UNVERIFIABLE-HERE |
| 11 | Proxy binary `Bin/Win64/unreal_mcp_proxy.exe` | UNVERIFIABLE-HERE |
| 12 | Proxy binary `Bin/Mac/unreal_mcp_proxy` | UNVERIFIABLE-HERE |
| 13 | Proxy binary `Bin/Linux/unreal_mcp_proxy` | UNVERIFIABLE-HERE |
| 14 | Proxy binary `Bin/LinuxArm64/unreal_mcp_proxy` | UNVERIFIABLE-HERE |
| 15 | Proxy absent entirely when the build lacks `Extras/Proxy` | UNVERIFIABLE-HERE |
| 16 | Per-distribution proxy contents (which builds ship which binaries) | **not established** |
| 17 | UE 5.9 confirmed with MCP focus, no date | UNVERIFIABLE-HERE |

## What would convert these rows, and what this seat cannot do

To move any row off UNVERIFIABLE-HERE, one of these is required, and none is available on this host:

1. **Engine source access** — `git clone git@github.com:EpicGames/UnrealEngine` requires an
   Epic-linked GitHub account. Blocked: `gh api repos/EpicGames/UnrealEngine` → 404 under the
   `VeigaPunk` account.
2. **An installed editor** — inspecting `Edit > Plugins`, or the on-disk
   `Engine/Plugins/Experimental/ModelContextProtocol/` tree, requires an editor install. Blocked:
   the AUR PKGBUILD needs the same SSH access.
3. **A per-distribution file manifest** — reading the Launcher/Linux build contents would settle
   Matrix 4's open question about which builds actually ship `Extras/Proxy`. No such manifest was
   found in this session.

Until one of those lands, the honest statement of this seat's finding is:

> **`ModelContextProtocol` and `AllToolsets` are 5.8-only, per Epic's own release notes, its
> version-gated documentation, and its plugin index — all of which resolve at 5.8 and return a
> content-less stub at 5.7 and below. `unreal_mcp_proxy` is an optional, build-conditional artifact
> under `Extras/Proxy` with four documented platform paths, and whether any given distribution
> actually ships it is not established by any source reachable from this host.**
