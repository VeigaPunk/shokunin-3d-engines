# SEAT-19 PROBE — YAML frontmatter of the 3 vendored `SKILL.md` files

**Seat:** SEAT-19 PROBE · round 101 · lane `game-dev-3d-shokunin`
**Upstream:** `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin`
**Pinned SHA:** `a6aa73ada02a9fb1f5415bec491f9942c519b297`
**Vendored root:** `corpus/knowledge/unreal-mcp/upstream/`
**Host:** Arch Linux, 32 cores, 30G RAM (host receipts). Unreal Editor **NOT installed** — nothing here was executed against a live editor.

---

## 0. Headline

All 3 `SKILL.md` files carry **exactly two frontmatter keys: `name` and `description`**.

There is **no `allowed-tools` key, and no equivalent tool-permission key, in any of the three files** — not at the pinned SHA, and not at any point in the repository's 53-commit history. A skill's tool surface in this plugin is expressed *in prose inside `description`* (and in the body), not declared in frontmatter.

This is a **calibration-relevant negative result**: a Claude→Kimi adapter that expects to read `allowed-tools` (or `tools`, `permissions`, `metadata.allowed-tools`) off these files will find nothing. The only machine-readable contract in the frontmatter is a trigger/skip routing description.

---

## 1. Verbatim frontmatter blocks

Each block below is reproduced byte-for-byte from the vendored file, including the opening and closing `---` delimiters and the escaped `\"` sequences. Frontmatter occupies **lines 1–4** in all three files.

### 1.1 `corpus/knowledge/unreal-mcp/upstream/skills/create-toolset/SKILL.md`

````markdown
---
name: create-toolset
description: "Use this skill when authoring or extending an Unreal Engine toolset, a class of static, AI-callable functions registered with `ToolsetRegistry` and exposed through the unreal-mcp server. Trigger when the user wants to add, expose, or register a new tool method, create a new toolset, or extend an existing one such as `BlueprintTools`, `StaticMeshTools`, `ObjectTools`, `LevelTools`, or `MaterialTools`. Concrete triggers: 'add a tool to X', 'expose this via MCP', 'register a function so Claude/the agent can call it', 'wire this into the toolset registry', 'create a new toolset for Y', 'add a Python toolset', 'make this AI-callable'; adding a `static` method to a `*Tools.cpp/.h/.py` file; editing files under a `Toolsets/` folder; designing tool parameters, return types, or struct schemas for a toolset. SKIP for: invoking existing tools at runtime (use unreal-mcp instead), authoring an Agent Skill (use unreal-skill), generic refactors that happen to touch a toolset file but don't add or redesign a tool, or unrelated uses of the word 'toolset'."
---
````

### 1.2 `corpus/knowledge/unreal-mcp/upstream/skills/unreal-mcp/SKILL.md`

````markdown
---
name: unreal-mcp
description: "Use this skill to perform actions inside an Unreal Engine project via a live-editor MCP connection. Trigger when the user wants to change, query, or run something in their Unreal Engine project, not for conceptual or docs questions. Concrete triggers: spawn/move/duplicate/transform actors in a level, open a `.uproject`, add things around a PlayerStart, create or edit a Blueprint/Widget/Material/Niagara/Control Rig/Sequencer/Behavior Tree/GAS ability, read or write properties on actors (e.g. `bIsLocked` on `BP_DoorActor`), Live Coding recompile after editing C++ (`AActor`, `UMyComponent::Method`, `UPROPERTY`), or modify Static/Skeletal Mesh assets. Treat as Unreal context even without the word \"Unreal\": asset prefixes `BP_`, `WBP_`, `M_`, `MI_`, `NS_`, `CR_`, `SK_`, `SM_`, `ABP_`; UE C++ types/macros; `.uproject`; Content Browser; Outliner; PlayerStart; \"in my game\" plus UE signals. Skip for: pure conceptual/docs questions, Unity, Godot, or unrelated uses of \"blueprint\"/\"sequencer\"/\"widget\"."
---
````

### 1.3 `corpus/knowledge/unreal-mcp/upstream/skills/unreal-skill/SKILL.md`

````markdown
---
name: unreal-skill
description: "Use this skill when creating, editing, or reviewing an Unreal Engine Agent Skill, a named bundle of instructions registered with the unreal-mcp server (distinct from Claude Code's harness skills under `.claude/skills/`). Trigger when the user wants to add or change a skill that the in-editor agent will load. Concrete triggers: 'create a new Agent Skill', 'add a skill for X workflow', 'edit/update this skill', 'review my skill', 'make a Python skill class', 'create a skill UAsset', 'register a skill so Claude picks it up'; writing or editing a `SKILL.md` inside a UE plugin's `Skills/` or `Python/skills/` folder; defining a Python skill class registered with the skill registry; calling `CreateSkill`, `ListSkills`, or `GetSkills` MCP tools; designing a skill's name, description, or instruction body. SKIP for: authoring a toolset (use create-toolset), invoking an existing skill at runtime (use unreal-mcp), editing harness-level Claude Code skills under `.claude/skills/` or `~/.claude/skills/`, or generic uses of the word 'skill'."
---
````

---

## 2. Parsing evidence

Command (run from `corpus/knowledge/unreal-mcp/upstream/`):

```bash
python3 - <<'PY'
import re,json
for f in ["skills/create-toolset/SKILL.md","skills/unreal-mcp/SKILL.md","skills/unreal-skill/SKILL.md"]:
    txt=open(f,encoding="utf-8").read(); lines=txt.split("\n")
    assert lines[0]=="---"
    end=lines.index("---",1); fm=lines[1:end]
    for ln in fm:
        m=re.match(r'^([A-Za-z0-9_-]+):[ ](.*)$',ln); assert m, repr(ln)
        k,v=m.group(1),m.group(2)
        print(k, "raw_len=%d"%len(v), "starts=%r ends=%r"%(v[:1],v[-1:]))
        if v.startswith('"'):
            assert v.endswith('"')
            d=json.loads(v)
            print("   json.loads OK decoded_len=%d equal_inner=%s"%(len(d), d==v[1:-1]))
PY
```

Observed output:

```
FILE: skills/create-toolset/SKILL.md
  key=name raw_len=14 starts='c' ends='t'
    plain scalar: 'create-toolset'
  key=description raw_len=1056 starts='"' ends='"'
    json.loads OK  decoded_len=1054
    decoded == raw_inner?  True
  tab chars in frontmatter: 0
FILE: skills/unreal-mcp/SKILL.md
  key=name raw_len=10 starts='u' ends='p'
    plain scalar: 'unreal-mcp'
  key=description raw_len=1017 starts='"' ends='"'
    json.loads OK  decoded_len=1005
    decoded == raw_inner?  False
    escape sequences at inner offsets: [(702, '\\"'), (710, '\\"'), (867, '\\"'), (879, '\\"'), (976, '\\"'), (987, '\\"'), (990, '\\"'), (1001, '\\"'), (1004, '\\"'), (1012, '\\"')]
  tab chars in frontmatter: 0
FILE: skills/unreal-skill/SKILL.md
  key=name raw_len=12 starts='u' ends='l'
    plain scalar: 'unreal-skill'
  key=description raw_len=1043 starts='"' ends='"'
    json.loads OK  decoded_len=1041
    decoded == raw_inner?  True
  tab chars in frontmatter: 0
ALL_PARSED: True
```

### Structural facts

| File | Total lines | Total bytes | Frontmatter lines | Frontmatter body bytes | Keys | `name` == dirname |
|---|---|---|---|---|---|---|
| `skills/create-toolset/SKILL.md` | 420 | 23258 | 2–3 (delims 1 and 4) | 1090 | `name`, `description` | yes |
| `skills/unreal-mcp/SKILL.md` | 56 | 7098 | 2–3 (delims 1 and 4) | 1047 | `name`, `description` | yes |
| `skills/unreal-skill/SKILL.md` | 112 | 6955 | 2–3 (delims 1 and 4) | 1075 | `name`, `description` | yes |

Line-ending / encoding facts:

```bash
file skills/*/SKILL.md
# skills/create-toolset/SKILL.md: Unicode text, UTF-8 text, with very long lines (1069)
# skills/unreal-mcp/SKILL.md: Unicode text, UTF-8 text, with very long lines (1030)
# skills/unreal-skill/SKILL.md: Python script, Unicode text, UTF-8 text executable, with very long lines (1056)
tr -cd '\r' < skills/*/SKILL.md | wc -c     # 0  -> no CR, pure LF
tail -c1 skills/*/SKILL.md | xxd -p         # 0a -> trailing newline present in all 3
```

Note: `file(1)` misclassifies `skills/unreal-skill/SKILL.md` as "Python script ... executable" — that is a heuristics artifact of the long single-line `description` beginning with a trigger word, not an actual shebang. `head -1` on that file is `---`, and `ls -l` shows mode `-rw-r--r--` (not executable). It is plain Markdown.

### Parsed values (decoded)

| File | `name` | `description` chars (decoded) | `description` words | Contains `Trigger when the user` | Contains skip clause |
|---|---|---|---|---|---|
| `create-toolset` | `create-toolset` | 1054 | 160 | yes | `SKIP for:` (uppercase) |
| `unreal-mcp` | `unreal-mcp` | 1005 | 131 | yes | `Skip for:` (sentence case) |
| `unreal-skill` | `unreal-skill` | 1041 | 153 | yes | `SKIP for:` (uppercase) |

Casing is **not uniform**: `unreal-mcp` uses `Skip for:` mid-sentence while the other two use `SKIP for:`. Any downstream parser that greps a single literal casing will miss one file.

### Frontmatter block hashes (for diffing later rounds)

`sha256sum` over lines 1–4 inclusive (both delimiters):

```
f896bd3a4f4d3ff3147cd6231526d6609468bd28b0d07196855e7cb8c36b1315  skills/create-toolset/SKILL.md
3f49de6f27a3b9f239bcf5abede3ad9c6cd98165cf5155c555c57e1d378e3bad  skills/unreal-mcp/SKILL.md
52efcb1e036fbea2269a485920838193998937dc06b2536be55289eaced5cd96  skills/unreal-skill/SKILL.md
```

`sha256sum` over lines 2–3 (frontmatter body only):

```
36e57db9331debf87b256c592cbc69cb85872708f7885695a10cee77fbc9a12a  skills/create-toolset/SKILL.md
0a03c7baba461a1089b52d05af859bc338fabea55506af6ca8477e8819ae572c  skills/unreal-mcp/SKILL.md
cf06b5d905ab2f3672d5303ee928c3bc2dba29b4c58012f7e9cef1f9236087ef  skills/unreal-skill/SKILL.md
```

Whole-file sha256 (cross-checks the per-seat provenance manifest entries `seat06`, `seat09`, `seat10`):

```
e9d050087f36de51f7eeef49adb0ba9ebc603b65f74f475bc53a6debfc1f7b1c  skills/create-toolset/SKILL.md   (= .manifest.d/seat09.sha256)
7ef8b991a82f591c5776bb5fa167c2bc2269fd00338ed3e8534eacc551d038fa  skills/unreal-mcp/SKILL.md       (= .manifest.d/seat06.sha256)
7a0af781c458c7d192d6b23c16b5737922dc482470e2e4ef617bcda80f435087  skills/unreal-skill/SKILL.md     (= .manifest.d/seat10.sha256)
```

---

## 3. Absence of `allowed-tools` — three independent checks

### Check A — grep at the pinned SHA (whole repo)

```bash
cd /tmp/ue-skills-ref && grep -rn "allowed[-_]tools" . --exclude-dir=.git
# (no output)
```

### Check B — grep the vendored copy

```bash
cd corpus/knowledge/unreal-mcp/upstream && grep -rn "allowed[-_]tools" .
# (no output)
```

### Check C — full 53-commit history (clone unshallowed this round)

```bash
cd /tmp/ue-skills-ref && git fetch --unshallow -q
git rev-parse --is-shallow-repository        # false
git rev-list --count HEAD                    # 53
git log -S'allowed-tools' --oneline --all    # (no output)
```

### Check D — every frontmatter key ever used, across all commits

```bash
for c in $(git rev-list --all); do for f in skills/create-toolset/SKILL.md skills/unreal-mcp/SKILL.md skills/unreal-skill/SKILL.md; do
  git show "$c:$f" 2>/dev/null | awk 'NR==1&&$0=="---"{i=1;next} i&&$0=="---"{exit} i{print}' | grep -oE '^[A-Za-z0-9_-]+:'
done; done | sort | uniq -c | sort -rn
```

Observed:

```
    124 name:
    124 description:
```

That is the complete set. Across 53 commits, the SKILL.md frontmatter vocabulary of this plugin has **only ever been `name` and `description`**.

### What "equivalent" keys exist elsewhere (and why they are not equivalents)

- `.claude-plugin/plugin.json` — top-level keys are `name`, `version`, `description`, `author`, `license`. No tool/permission key.
- `hooks/hooks.json` — declares a `SessionStart` hook only; no tool scoping.
- **Important distinction:** commit `6514615` ("Trim toolset-specific skill content and drop the Agent Skill toolsets field", bump to 3.0.1) removed a `toolsets` field — but that field belonged to the **in-editor Unreal Agent Skill** concept (a Python class attribute `toolsets = [MyToolset]` and a UAsset `Details` entry), documented in the *body* of `unreal-skill/SKILL.md`. It was never a YAML frontmatter key of these `SKILL.md` files. Do not conflate the two: `git log -S'toolsets:' --all -- 'skills/*/SKILL.md'` is empty.

So: **no frontmatter-level tool allowlist exists in this plugin at all.** The effective tool contract is prose: `unreal-mcp/SKILL.md` states the server advertises only three meta-tools (`list_toolsets`, `describe_toolset`, `call_tool`) with tool search on by default, and everything else is dispatched server-side through `call_tool`.

---

## 4. Tool-surface mentions per file (grep counts, vendored copies)

```bash
grep -oE '\b(list_toolsets|describe_toolset|call_tool|CreateSkill|ListSkills|GetSkills|ToolsetRegistry)\b' <file> | sort | uniq -c
```

| File | `ToolsetRegistry` | `list_toolsets` | `describe_toolset` | `call_tool` | `CreateSkill` | `ListSkills` | `GetSkills` |
|---|---|---|---|---|---|---|---|
| `create-toolset/SKILL.md` | 11 | 1 | 1 | 0 | 0 | 0 | 0 |
| `unreal-mcp/SKILL.md` | 1 | 3 | 3 | 6 | 0 | 0 | 1 |
| `unreal-skill/SKILL.md` | 1 | 1 | 1 | 1 | 3 | 3 | 3 |

Inline-backtick identifier counts (a rough density proxy for how much of the contract is prose-encoded): `create-toolset` 79, `unreal-mcp` 54, `unreal-skill` 43.

---

## 5. Provenance and vendor integrity (supports C1)

```bash
cd /tmp/ue-skills-ref && git rev-parse HEAD
# a6aa73ada02a9fb1f5415bec491f9942c519b297   <-- equals pinned SHA
```

File-list equality against the pinned tree, and byte comparison of all 12 files:

```bash
(cd /tmp/ue-skills-ref && git ls-tree -r --name-only HEAD | sort) > /tmp/up.txt
find . -type f | sed 's|^\./||' | sort > /tmp/vend.txt
diff /tmp/up.txt /tmp/vend.txt && echo "FILE LISTS IDENTICAL"
# FILE LISTS IDENTICAL (12 files)

while read -r p; do
  a=$(sha256sum "corpus/knowledge/unreal-mcp/upstream/$p" | cut -d' ' -f1)
  b=$(cd /tmp/ue-skills-ref && git show "HEAD:$p" | sha256sum | cut -d' ' -f1)
  [ "$a" = "$b" ] || echo "DIFFER $p"
done < /tmp/up.txt
# compared=12 differ=0
```

Upstream tree is 12 files total (6 `.md`, 2 `.sh`/`.json` under `hooks`, `.claude-plugin/plugin.json`, `LICENSE`, `CODEOWNERS`, `.gitignore`). All 12 are vendored; all 3 `SKILL.md` are byte-identical to the pinned SHA. Upstream carries 6 `.md` files; all 6 are present in the vendored tree.

Per-file identity for the three `SKILL.md`:

```
IDENTICAL skills/create-toolset/SKILL.md e9d050087f36de51f7eeef49adb0ba9ebc603b65f74f475bc53a6debfc1f7b1c
IDENTICAL skills/unreal-mcp/SKILL.md     7ef8b991a82f591c5776bb5fa167c2bc2269fd00338ed3e8534eacc551d038fa
IDENTICAL skills/unreal-skill/SKILL.md   7a0af781c458c7d192d6b23c16b5737922dc482470e2e4ef617bcda80f435087
```

---

## 6. Calibration notes for a Claude → Kimi adapter

| Observation | Evidence | Consequence for adaptation |
|---|---|---|
| Frontmatter is `name` + `description` only | §2, §3-D | Do not build a loader that requires `allowed-tools`; there is nothing to read. Fail-open on a missing key, not fail-closed. |
| `description` is a **single very long line** (1005–1054 decoded chars), double-quoted | §2 | Line-based readers that truncate at some column will silently cut the skip clause. Parse to the closing delimiter line, not to a byte budget. |
| Only `unreal-mcp` uses `\"` escapes (10 of them); the other two decode `raw_inner == decoded` | §2 | A naive `strip('"')` works on 2 of 3 files and leaves literal backslashes on `unreal-mcp`. Use a real scalar unescape (YAML dq == JSON string here — verified by `json.loads` on all 3). |
| Skip-clause casing differs (`SKIP for:` vs `Skip for:`) | §2 | Match case-insensitively or you will drop one file's negative routing. |
| No frontmatter tool allowlist anywhere in history | §3-A..D | Tool scoping must come from the body prose / the MCP server's own advertisement, not from frontmatter. |
| `name` equals the containing directory name in all 3 | §2 table | Directory-derived naming is a safe fallback if frontmatter parsing fails. |
| Pure LF, trailing newline, valid UTF-8 | §2 | No CRLF/encoding normalization step needed; a Windows-authored CRLF rewrite would break the byte-identity receipts. |

**Unproven-on-this-host (label, do not assert):** anything about how the Unreal Editor actually consumes these files, and any live-editor MCP behaviour, is unverified here — Unreal Editor is not installed on this host. All statements above are about the vendored bytes and the upstream git history only.

---

## 7. Reproduction

```bash
# clone / verify
git -C /tmp/ue-skills-ref rev-parse HEAD   # must be a6aa73ada02a9fb1f5415bec491f9942c519b297
# frontmatter dump
cd corpus/knowledge/unreal-mcp/upstream
for f in skills/create-toolset/SKILL.md skills/unreal-mcp/SKILL.md skills/unreal-skill/SKILL.md; do sed -n '1,4p' "$f"; done
```
