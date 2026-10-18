# SEAT-27 PROBE — r22 `.uplugin` vs vendored `.claude-plugin/plugin.json`

Round 101, lane `game-dev-3d-shokunin`. Seat: SEAT-27 PROBE. Scope: relation between the
r22 static Unreal-style plugin descriptor and the upstream Claude Code plugin manifest
vendored by C1. This file is the seat's only write.

## Verdict up front

The two files are **valid JSON but not the same schema family, and they share no
case-sensitive field name**. The case-sensitive intersection of their top-level keys is
the empty set. After case-folding, exactly two names collide — `version`/`Version` and
`description`/`Description` — and both collisions are false friends: `Version` is a JSON
integer in the Unreal descriptor and a semantic-version string in the Claude manifest.

A `.uplugin` is an **engine-owned discovery contract** (parsed by Unreal Editor and
UnrealBuildTool at plugin scan). A `.claude-plugin/plugin.json` is an **ecosystem-level
marketplace manifest** (parsed by Claude Code at plugin install). Their only relation is
that both are "a JSON file naming a plugin and describing it" — a shared *purpose*, not a
shared *schema*.

## Provenance receipts (commands actually run, with observed output)

Upstream pinned at `a6aa73ada02a9fb1f5415bec491f9942c519b297`. The pre-existing clone was
verified against the pin before use, per seat instructions:

```sh
$ git -C /tmp/ue-skills-ref rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
$ git -C /tmp/ue-skills-ref log -1 --format='%H %ad %s'
a6aa73ada02a9fb1f5415bec491f9942c519b297 Thu Sep 17 13:19:50 2026 +1200 [MCP] Permit safe concurrent tool calls
$ git -C /tmp/ue-skills-ref hash-object .claude-plugin/plugin.json
ba4e660a4b053674fb53dfa83f7e2e6825977796
```

Clone matched the pin, so no fresh clone to `/tmp/r101work` was needed. The vendored copy
is byte-identical to upstream, and its digest is the one C1's manifest already records:

```sh
$ sha256sum corpus/knowledge/unreal-mcp/upstream/.claude-plugin/plugin.json /tmp/ue-skills-ref/.claude-plugin/plugin.json
5aa984848f0fd48c94394651c66f5b200ee1e2583d8df8caeecc22bb550b4d44  corpus/knowledge/unreal-mcp/upstream/.claude-plugin/plugin.json
5aa984848f0fd48c94394651c66f5b200ee1e2583d8df8caeecc22bb550b4d44  /tmp/ue-skills-ref/.claude-plugin/plugin.json
$ cat corpus/knowledge/unreal-mcp/.manifest.d/seat03.sha256
5aa984848f0fd48c94394651c66f5b200ee1e2583d8df8caeecc22bb550b4d44  upstream/.claude-plugin/plugin.json
```

The r22 artifact digest matches the one recorded in `corpus/lessons/r22-unreal-review.md`:

```sh
$ sha256sum corpus/artifacts/unreal-r22/Headless3DFixture.uplugin
2543b337f6a63e8827b400939a85b3cc89c192345dcd63a37b96f25b4c89a0f9  corpus/artifacts/unreal-r22/Headless3DFixture.uplugin
```

Both files parse as JSON and were re-validated this seat:

```sh
$ jq -e . corpus/artifacts/unreal-r22/Headless3DFixture.uplugin >/dev/null && echo "uplugin: valid JSON"
uplugin: valid JSON
$ jq -e . corpus/knowledge/unreal-mcp/upstream/.claude-plugin/plugin.json >/dev/null && echo "plugin.json: valid JSON"
plugin.json: valid JSON
$ wc -c corpus/artifacts/unreal-r22/Headless3DFixture.uplugin corpus/knowledge/unreal-mcp/upstream/.claude-plugin/plugin.json
374 corpus/artifacts/unreal-r22/Headless3DFixture.uplugin
487 corpus/knowledge/unreal-mcp/upstream/.claude-plugin/plugin.json
```

### The two descriptors, verbatim

`corpus/artifacts/unreal-r22/Headless3DFixture.uplugin` (374 B):

```json
{
  "FileVersion": 3,
  "Version": 1,
  "VersionName": "1.0",
  "FriendlyName": "Headless 3D Fixture",
  "Description": "Static descriptor study; no Unreal runtime or source module installed",
  "Category": "Examples",
  "CanContainContent": false,
  "Modules": [
    {
      "Name": "Headless3DFixture",
      "Type": "Runtime",
      "LoadingPhase": "Default"
    }
  ]
}
```

`corpus/knowledge/unreal-mcp/upstream/.claude-plugin/plugin.json` (487 B):

```json
{
  "name": "unreal-engine-skills-for-claude-code",
  "version": "3.1.1",
  "description": "Control Unreal Editor directly from Claude Code via MCP. Hundreds of tools exposed via Unreal's ToolsetRegistry across 30+ toolsets: actors, blueprints, materials, Niagara, Control Rigs, Sequencer, State Trees, widgets, Gameplay Ability System, automation testing, and more.",
  "author": {
    "name": "Thomas Mansencal",
    "email": "thomas.mansencal@epicgames.com"
  },
  "license": "MIT"
}
```

### Key-set computation

```sh
$ python3 - "$U" "$P"   # full script body in transcript
uplugin keys : ['FileVersion', 'Version', 'VersionName', 'FriendlyName', 'Description', 'Category', 'CanContainContent', 'Modules']
plugin.json  : ['name', 'version', 'description', 'author', 'license']
case-sensitive intersection : []
case-insensitive intersection: ['description', 'version']
uplugin-only : ['CanContainContent', 'Category', 'Description', 'FileVersion', 'FriendlyName', 'Modules', 'Version', 'VersionName']
plugin-only  : ['author', 'description', 'license', 'name', 'version']
Version type : int 1
version type : str '3.1.1'
Modules type : list 1
```

## Field-by-field table

Every top-level field of both files, one row each. "Family" states which schema the field
belongs to; there is no row that belongs to both.

| Field | File | JSON type | Value in this artifact | Family | Relation / note |
|---|---|---|---|---|---|
| `FileVersion` | `.uplugin` | int | `3` | Unreal `FPluginDescriptor` | **Unreal-only.** The *only required* Unreal descriptor field; a format-version marker, not a plugin version. No Claude analogue. |
| `Version` | `.uplugin` | int | `1` | Unreal `FPluginDescriptor` | Case-folds to Claude `version`, but **type differs** (int vs semver string) and semantics differ (build number vs release tag). False friend. |
| `VersionName` | `.uplugin` | string | `"1.0"` | Unreal `FPluginDescriptor` | Unreal carries *two* version fields (numeric `Version` + display `VersionName`). Claude carries exactly one string `version`. Structural difference, not just a rename. |
| `FriendlyName` | `.uplugin` | string | `"Headless 3D Fixture"` | Unreal `FPluginDescriptor` | Unreal-only display name. Closest Claude counterpart is `name`, but `name` is a *machine* identifier (`kebab-case`, required) — see row below. |
| `Description` | `.uplugin` | string | `"Static descriptor study; …"` | Unreal `FPluginDescriptor` | Case-folds to Claude `description`. Closest genuine semantic match in the pair, though casing differs. |
| `Category` | `.uplugin` | string | `"Examples"` | Unreal `FPluginDescriptor` | Unreal-only. Drives the Editor Plugin Browser category tree. Claude has no category field; discovery is via `keywords` (unused here). |
| `CanContainContent` | `.uplugin` | bool | `false` | Unreal `FPluginDescriptor` | Unreal-only. Gates whether the engine loads a plugin `Content/` folder. No Claude analogue. |
| `Modules` | `.uplugin` | array of object | one module object | Unreal `FPluginDescriptor` | Unreal-only. Required for plugins with code; each entry needs `Name` + `Type`. Claude expresses code delivery via `hooks`/`mcpServers`/`skills`, never a `Modules` array. |
| *(nested)* `Modules[0].Name` | `.uplugin` | string | `"Headless3DFixture"` | Unreal module descriptor | Nested, so outside the top-level comparison; listed for completeness. |
| *(nested)* `Modules[0].Type` | `.uplugin` | string | `"Runtime"` | Unreal module descriptor | Nested. Documented enum: `Runtime`, `RuntimeNoCommandlet`, `Developer`, `Editor`, `EditorNoCommandlet`, `Program`. |
| *(nested)* `Modules[0].LoadingPhase` | `.uplugin` | string | `"Default"` | Unreal module descriptor | Nested. |
| `name` | `plugin.json` | string | `"unreal-engine-skills-for-claude-code"` | Claude Code manifest | **Claude-only and the only required Claude field.** A kebab-case unique identifier — a machine key, whereas Unreal's human-facing name is `FriendlyName` and Unreal's machine key is the *filename* (`Headless3DFixture.uplugin`). |
| `version` | `plugin.json` | string | `"3.1.1"` | Claude Code manifest | Case-folds to Unreal `Version`; semver string vs int. False friend (see above). |
| `description` | `plugin.json` | string | `"Control Unreal Editor directly …"` | Claude Code manifest | Same spelling as Unreal `Description` except casing; the only near-clean semantic pairing. |
| `author` | `plugin.json` | object | `{name, email}` | Claude Code manifest | Claude-only. **Notable:** the upstream author is `thomas.mansencal@epicgames.com` — an Epic Games address on a third-party Claude Code marketplace plugin. |
| `license` | `plugin.json` | string | `"MIT"` | Claude Code manifest | Claude-only as a *field*; Unreal records licensing by shipping a `LICENSE` file and `CreatedBy` text instead. |

Unreal's live documentation example for `.uplugin` carries roughly seventeen top-level
fields (`CreatedBy`, `CreatedByURL`, `DocsURL`, `MarketplaceURL`, `SupportURL`,
`EnabledByDefault`, `IsBetaVersion`, `Installed`, plus all of the above). The r22 artifact
is a **deliberate eight-field subset** — its `verify_descriptor.py` rejects anything outside
an exact key set — so the table above compares the artifact as authored, not the full
Unreal schema.

## Which schema is newer / which is standard

These are two separate questions, and the evidence answers them differently.

**Which is standard:** each is standard inside its own ecosystem, and neither is standard
inside the other's. Unreal's descriptor is the *engine-mandated* discovery contract — the
live Epic page states plugin descriptors "are discovered and loaded automatically by the
Engine, Editor, and UnrealBuildTool (UBT)". Claude's manifest is the *marketplace-mandated*
install contract. There is no shared registry, no shared validator, and no field a `.uplugin`
could gain that would make Claude Code read it, or vice versa.

**Which is newer:** the Unreal *descriptor format* is the older and far more stable of the
two by its own documentation. Epic's page says `FileVersion` "should usually [be] set to the
highest version that is allowed by the Engine (currently, this is 3)" and that because the
version applies to the file format rather than the plugin, "we do not expect that it will
change very frequently, and it should not change with subsequent releases of your Plugin."
The r22 artifact pins `FileVersion: 3`, i.e. it targets the current documented format.

The Claude manifest is demonstrably the younger *artifact*, on upstream git evidence:

```sh
$ git -C /tmp/ue-skills-ref log --format='%H %ad %s' --date=short -- .claude-plugin/plugin.json | tail -1
5a7362426386444f241303ef68527f2aebd2da3d 2026-04-07 Initial commit.
$ git -C /tmp/ue-skills-ref log --oneline | wc -l
53
$ git -C /tmp/ue-skills-ref log --oneline -- .claude-plugin/plugin.json | wc -l
25
```

`plugin.json` arrives with the repository's initial commit on 2026-04-07 and is touched by
25 of the repository's 53 commits — version churn `1.x → 2.0.x → 3.1.1`, including a
2026-05-08 "Rename plugin … as per legal request" commit. So the Claude manifest schema is
the newer and less settled of the two; the Unreal descriptor is the older and more settled.

**Practical consequence for this lane:** vendoring the upstream Claude plugin does *not*
give the corpus an Unreal descriptor to compare against, and it does not make the r22
artifact any more executable. The upstream plugin describes how to *drive* an Unreal Editor
over MCP; the r22 artifact describes a *plugin the engine would load*. The upstream repo
touches `.uplugin` only incidentally — its hook script globs `*.uproject` project files
(`upstream/hooks/unreal-context.sh:22,53`) and its docs tell the operator to edit a
`.uproject` `Plugins` array (`upstream/skills/unreal-mcp/references/setup.md:12-16`). It
ships no `.uplugin` of its own:

```sh
$ git -C /tmp/ue-skills-ref ls-files | wc -l
12
$ git -C /tmp/ue-skills-ref ls-files | grep -c uplugin
0
```

## Limits

- Static-only. Both files were read and parsed; neither was fed to its own toolchain. No
  Unreal Editor or UnrealBuildTool exists on this host (Unreal install is blocked pending
  operator Epic-account linking), so no `.uplugin` here has ever been loaded, compiled, or
  schema-validated by the engine. No Claude Code runtime parsed the manifest in this seat
  either. Everything above is JSON-level and documentation-level.
- The Epic documentation page was fetched live this seat (HTTP 200, 2026-10-18) and is the
  authority for the required-field and `FileVersion: 3` claims; the Claude Code
  plugins-reference page was likewise fetched live this seat and is the authority for
  `name` being the sole required field. Both are external pages, not host receipts.
- The "newer" judgement for the Claude manifest rests on upstream commit dates, which are
  authoring dates, not schema-publication dates. No publication date for the Claude plugin
  manifest schema was established here.
- The r22 artifact's own checker was re-run this seat for consistency with its recorded
  lesson; it validates the *authored sample*, not the Unreal schema, and a pass is not an
  Unreal acceptance.
