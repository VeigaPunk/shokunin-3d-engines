# SEAT-16 PROBE — `.claude-plugin/plugin.json` manifest validation

Round: r101 · Lane: game-dev-3d-shokunin · Upstream: `EpicGames/unreal-engine-skills-for-claude-code`
Pinned SHA: `a6aa73ada02a9fb1f5415bec491f9942c519b297`
Probe target: `upstream/.claude-plugin/plugin.json`
Date: 2026-10-18

## Verdict

**VALID, and the obvious plugin-manifest shape is satisfied in full.**

- Syntax: valid JSON under two independent parsers (`jq` 1.8.2 and CPython `json.loads`).
- Key census: exactly **5** top-level keys — `name`, `version`, `description`, `author`, `license`.
- Required-shape probe `has(name|version|description|author)` → **all four `true`**.
- Byte-identity with the pinned clone: sha256 `5aa984848f0fd48c94394651c66f5b200ee1e2583d8df8caeecc22bb550b4d44`, confirmed by `cmp`.

Evidence label for this probe: **verified-here** (pure static artifact validation; no runtime claim made).

## 0. Source resolution (pin confirmed before any read)

Command:

```bash
ls -d /tmp/ue-skills-ref 2>/dev/null && git -C /tmp/ue-skills-ref rev-parse HEAD
```

Observed:

```
/tmp/ue-skills-ref
a6aa73ada02a9fb1f5415bec491f9942c519b297
```

Observed `HEAD` equals the pinned SHA → the pre-existing clone was used as-is; no re-clone to `/tmp/r101work` was needed. Working tree clean (`git status --porcelain` returned empty), and the pin commit is:

```bash
git log -1 --format='%H %ci %s'
```

```
a6aa73ada02a9fb1f5415bec491f9942c519b297 2026-09-17 13:28:32 +1200 [MCP] Permit safe concurrent tool calls
```

## 1. Target file identity

```bash
wc -c .claude-plugin/plugin.json
ls -la .claude-plugin/
```

```
487 .claude-plugin/plugin.json
total 4
drwxr-xr-x 2 vgpnk vgpnk  60 Oct 18 14:06 .
drwxr-xr-x 6 vgpnk vgpnk 200 Oct 18 14:06 ..
-rw-r--r-- 1 vgpnk vgpnk 487 Oct 18 14:06 plugin.json
```

`find . -name 'plugin.json' -not -path './.git/*'` returns exactly one path: `./.claude-plugin/plugin.json`. There is no second/stale manifest elsewhere in the tree.

## 2. Syntax validation

```bash
jq -e . .claude-plugin/plugin.json >/dev/null 2>&1; echo "jq -e . exit=$?"
jq empty .claude-plugin/plugin.json 2>&1; echo "jq empty exit=$?"
```

```
jq -e . exit=0
jq empty exit=0
```

Both exit 0 with empty stderr — the file parses and `jq -e` (which fails on `false`/`null`) also succeeds.

Independent parser cross-check:

```bash
python3 - <<'EOF'
import json,hashlib
p=".claude-plugin/plugin.json"
b=open(p,"rb").read()
print("sha256:", hashlib.sha256(b).hexdigest())
print("bytes:", len(b))
print("starts_with_BOM:", b[:3]==b'\xef\xbb\xbf')
print("ends_with_newline:", b[-1:]==b'\n')
d=json.loads(b)
print("top_level_keys:", list(d.keys()))
print("all_strings_nonempty:", all(isinstance(v,str) and v.strip() for k,v in d.items() if k!="author"))
print("author_keys:", list(d["author"].keys()))
print("author_nonempty:", all(v.strip() for v in d["author"].values()))
EOF
```

```
sha256: 5aa984848f0fd48c94394651c66f5b200ee1e2583d8df8caeecc22bb550b4d44
bytes: 487
starts_with_BOM: False
ends_with_newline: True
top_level_keys: ['name', 'version', 'description', 'author', 'license']
all_strings_nonempty: True
author_keys: ['name', 'email']
author_nonempty: True
```

Raw byte view confirms plain UTF-8, LF, 2-space indent, no BOM:

```bash
head -c 120 .claude-plugin/plugin.json | od -c | head -8
```

```
0000000   {  \n           "   n   a   m   e   "   :       "   u   n   r
0000020   e   a   l   -   e   n   g   i   n   e   -   s   k   i   l   l
0000040   s   -   f   o   r   -   c   l   a   u   d   e   -   c   o   d
0000060   e   "   ,  \n           "   v   e   r   s   i   o   n   "   :
0000100       "   3   .   1   .   1   "   ,  \n           "   d   e   s
0000120   c   r   i   p   t   i   o   n   "   :       "   C   o   n   t
0000140   r   o   l       U   n   r   e   a   l       E   d   i   t
0000160   o   r       d   i   r   e   c   t
```

## 3. Full key census + value types

```bash
jq -r 'to_entries[] | "\(.key)\t\(.value|type)"' .claude-plugin/plugin.json
jq 'length' .claude-plugin/plugin.json
```

```
name	string
version	string
description	string
author	object
license	string
count:
5
```

Recursive leaf-path census (every scalar path in the document):

```bash
jq -r '[paths(scalars)] | map(.[0]) | unique | .[]' .claude-plugin/plugin.json
```

```
author
description
license
name
version
```

The document is **flat except for one level of nesting under `author`**; there are no arrays, no `null`s, no numbers, no booleans anywhere.

| Key | Type | Value |
|---|---|---|
| `name` | string | `unreal-engine-skills-for-claude-code` |
| `version` | string | `3.1.1` |
| `description` | string | `Control Unreal Editor directly from Claude Code via MCP. Hundreds of tools exposed via Unreal's ToolsetRegistry across 30+ toolsets: actors, blueprints, materials, Niagara, Control Rigs, Sequencer, State Trees, widgets, Gameplay Ability System, automation testing, and more.` |
| `author` | object | `{name: "Thomas Mansencal", email: "thomas.mansencal@epicgames.com"}` |
| `author.name` | string | `Thomas Mansencal` |
| `author.email` | string | `thomas.mansencal@epicgames.com` |
| `license` | string | `MIT` |

## 4. Plugin-manifest shape check

The obvious plugin-manifest shape is `name` + `version` + `description` + `author`. Probed directly:

```bash
jq -r '{name:(has("name")),version:(has("version")),description:(has("description")),author:(has("author"))}' .claude-plugin/plugin.json
```

```
{
  "name": true,
  "version": true,
  "description": true,
  "author": true
}
```

**All four required fields are present**, each non-empty, each of a sane type (`author` being an object rather than a bare string — with `name` and `email` both populated — which is the richer of the two accepted author shapes). `license: "MIT"` is present as a bonus field; `LICENSE` exists at the repo root, so the declared license is corroborated by a real file rather than asserted only in metadata.

Full pretty-printed document (`jq . .claude-plugin/plugin.json`):

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

## 5. Byte-identity against the vendored copy (C1 corroboration)

The vendored corpus copy was compared against the pin clone:

```bash
sha256sum corpus/knowledge/unreal-mcp/upstream/.claude-plugin/plugin.json
sha256sum /tmp/ue-skills-ref/.claude-plugin/plugin.json
cmp corpus/knowledge/unreal-mcp/upstream/.claude-plugin/plugin.json /tmp/ue-skills-ref/.claude-plugin/plugin.json && echo "IDENTICAL"
jq -e . corpus/knowledge/unreal-mcp/upstream/.claude-plugin/plugin.json >/dev/null 2>&1; echo "exit=$?"
```

```
5aa984848f0fd48c94394651c66f5b200ee1e2583d8df8caeecc22bb550b4d44  corpus/knowledge/unreal-mcp/upstream/.claude-plugin/plugin.json
5aa984848f0fd48c94394651c66f5b200ee1e2583d8df8caeecc22bb550b4d44  /tmp/ue-skills-ref/.claude-plugin/plugin.json
IDENTICAL
exit=0
```

The vendored copy is byte-identical to the pinned upstream and parses identically. Its digest is also already recorded in the corpus provenance manifest:

```bash
cat corpus/knowledge/unreal-mcp/.manifest.d/seat03.sha256
```

```
5aa984848f0fd48c94394651c66f5b200ee1e2583d8df8caeecc22bb550b4d44  upstream/.claude-plugin/plugin.json
```

`.manifest.d/` currently holds 11 per-seat shard files (`seat01.sha256` … `seat11.sha256`).

## 6. Adjacent manifest facts (context for other seats; static-only)

These are read-only observations from the same pinned tree, recorded because they bound what the manifest does and does not declare.

- **No `mcpServers` key.** `jq -r 'has("mcpServers")'` → `false`. This is deliberate, not an omission: `README.md:72` states *"This plugin does not ship a static `.mcp.json` file. Run `ModelContextProtocol.GenerateClientConfig ClaudeCode` in the editor console to generate it from the current server port and URL."* The `.mcp.json` search over the tree returns nothing.
- **No `marketplace.json`** under `.claude-plugin/` — the plugin is consumed from Anthropic's official marketplace (`README.md:32,39`), so no in-repo marketplace descriptor is expected.
- **Second manifest exists:** `hooks/hooks.json` (valid JSON, `jq -e` exit=0), top-level keys `description` (string) and `hooks` (object). It declares a single `SessionStart` hook matching `startup|resume|clear` that runs `bash ${CLAUDE_PLUGIN_ROOT}/hooks/unreal-context.sh` with `timeout: 5`. So `plugin.json` is not the only manifest in the tree — a complete inventory must include `hooks/hooks.json`.
- **Version cross-reference:** `3.1.1` appears in the tree only in `plugin.json:3`; no other file restates the plugin version, so `plugin.json` is the single source of truth for it.
- Repo top level: `.claude-plugin/`, `CODEOWNERS`, `.gitignore`, `hooks/`, `LICENSE`, `README.md`, `skills/`; `skills/` contains 3 skill directories (`create-toolset`, `unreal-mcp`, `unreal-skill`) and exactly 3 `SKILL.md` files.

## 7. Scope / limits of this probe

- This is a **static artifact** check. It proves the manifest parses, has the expected keys, and is byte-identical to the pinned upstream. It proves nothing about whether the plugin loads in a live Claude Code client, and nothing about whether the MCP server or Unreal Editor is reachable — per round context, Unreal Editor is not installed on this host, so any runtime claim here would be unproven-on-this-host by construction and is therefore not made.
- Key-shape validity was judged against the "obvious" shape named in the seat brief. A stricter schema (e.g. an official Claude Code plugin JSON Schema with `additionalProperties: false`) was **not** fetched, so `license` being an extra top-level key is reported as present, not as schema-conformant or schema-violating.
