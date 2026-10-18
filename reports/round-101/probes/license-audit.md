# SEAT-28 PROBE — license audit of the vendored unreal-mcp upstream tree

Round r101, lane game-dev-3d. Seat: SEAT-28 PROBE.
Artifact under audit: `corpus/knowledge/unreal-mcp/upstream/LICENSE`
(and, as corroboration, the whole 12-file vendored tree).

Upstream: <https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin>
pinned at SHA `a6aa73ada02a9fb1f5415bec491f9942c519b297`.
Reference clone `/tmp/ue-skills-ref` re-verified against the pin (receipt L1 below).

---

## 1. License identification

**MIT License.** Copyright line: `Copyright (c) 2026 Epic Games, Inc.`

Three independent identifications, all observed:

| Source | Observed value | Receipt |
|---|---|---|
| `upstream/LICENSE` line 1 | `MIT License` | L4 |
| `upstream/.claude-plugin/plugin.json` | `"license": "MIT"` | L5 |
| GitHub API repo metadata | `license: MIT` | L6 |

The vendored `LICENSE` is **byte-identical** to the clone's (sha256
`5b337be051359edcdec510103aee15f5f870efb38b6d42eecd685dc3582314a6`,
both sides — receipt L3), 21 lines / 1073 bytes, LF line endings, no BOM.

**No additional license terms exist in the tree.** A case-insensitive
sweep for `licen[cs]e|copyright|apache|GPL|BSD|third.party|attribut`
across all 12 tracked files returns only: the `LICENSE` itself, the
`plugin.json` `"license": "MIT"` field, and two unrelated English
occurrences of the substring "inherit"/"class attribute" in
`skills/unreal-skill/SKILL.md:53,56` (receipt L7). There is **no
`NOTICE`**, no `COPYING`, no third-party directory, and no per-file
SPDX or copyright header anywhere (receipt L8). `CODEOWNERS` carries
only a review-routing rule (`*	@Thomas.Mansencal`), not a license term.

---

## 2. Operative clause (quoted, with line numbers)

Verbatim from the vendored file (receipt L4):

```
5  Permission is hereby granted, free of charge, to any person obtaining a copy
6  of this software and associated documentation files (the "Software"), to deal
7  in the Software without restriction, including without limitation the rights
8  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
9  copies of the Software, and to permit persons to whom the Software is
10 furnished to do so, subject to the following conditions:
11
12 The above copyright notice and this permission notice shall be included in all
13 copies or substantial portions of the Software.
```

The single condition attached to that grant is the notice-retention
requirement at **lines 12–13**. Lines 15–21 are the standard MIT
all-caps warranty/liability disclaimer and impose no affirmative
obligation on a redistributor.

---

## 3. Verdict — is vendoring permitted for internal craft training?

**VERDICT (labeled paragraph): PERMITTED — vendoring these copies into
this corpus for internal craft training is licensed by the upstream
grant, and the one condition it attaches is already satisfied.**
The grant at lines 5–10 permits dealing in the Software "without
restriction," expressly including the rights "to use, copy, modify,
merge, publish, distribute, sublicense, and/or sell copies of the
Software"; an internal, non-published craft-training corpus is a
strict subset of the copying and use that grant authorizes, so no
further permission from Epic Games is required. The sole condition at
lines 12–13 — "The above copyright notice and this permission notice
shall be included in all copies or substantial portions of the
Software" — is met on the evidence, because the vendored tree contains
`upstream/LICENSE` itself, byte-identical to upstream (sha256
`5b337be0…14a6`, receipt L3), so the copyright notice and the
permission notice travel with every vendored copy rather than being
stripped. The MIT grant is also royalty-free ("free of charge",
line 5) and carries no field-of-use, no-purpose, no-recipient, or
no-modification restriction that a training use could trip; the
"without restriction" language at line 7 forecloses such a reading.
The disclaimer at lines 15–21 ("THE SOFTWARE IS PROVIDED 'AS IS'…")
does not condition the grant — it allocates risk — so it does not
constrain vendoring, though it does mean the corpus inherits no
warranty or fitness claim from Epic Games. Caveat on scope, not on
permission: the MIT license covers the plugin repository's own 12
files only; it does **not** extend to Unreal Engine itself, which is
governed by Epic's separate EULA and is not vendored here, and MIT
grants no trademark rights, so the names "Unreal" and "Epic Games"
remain Epic marks and must not be presented as an endorsement of this
corpus. This is a reading of the license text and receipts below, not
legal advice.

**Practical consequence for the corpus:** no license action is needed
to keep the vendored tree. The condition is self-satisfying as long as
`upstream/LICENSE` stays in the tree unmodified and the provenance
manifest keeps pointing at the pinned SHA. If the tree is ever reduced
to a subset of files, `LICENSE` must be in that subset.

---

## 4. Receipts — commands run and observed output

### L1 — clone matches the pin

```
$ git -C /tmp/ue-skills-ref rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297

$ git -C /tmp/ue-skills-ref rev-parse --is-shallow-repository
false

$ git -C /tmp/ue-skills-ref ls-remote origin HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297	HEAD
```

Clone HEAD equals the pinned SHA; the clone is not shallow, and the
remote's current `HEAD` still resolves to the same commit, so the pin
is not a stale branch tip.

### L2 — upstream tree inventory

```
$ git -C /tmp/ue-skills-ref ls-files | wc -l
12

$ git -C /tmp/ue-skills-ref ls-files
.claude-plugin/plugin.json
.gitignore
CODEOWNERS
LICENSE
README.md
hooks/hooks.json
hooks/unreal-context.sh
skills/create-toolset/SKILL.md
skills/unreal-mcp/SKILL.md
skills/unreal-mcp/references/operations.md
skills/unreal-mcp/references/setup.md
skills/unreal-skill/SKILL.md

$ git -C /tmp/ue-skills-ref log --oneline | wc -l
1
```

The pinned commit is the only commit in the clone's history
(`a6aa73a [MCP] Permit safe concurrent tool calls`, author date
`2026-09-17T01:19:50Z`), so there is no earlier or later license
change to consider; `git log --follow -- LICENSE` returns that one
commit only.

### L3 — vendored tree is byte-identical to upstream

Per-file sha256, clone vs `corpus/knowledge/unreal-mcp/upstream/`:

```
$ for f in $(git -C /tmp/ue-skills-ref ls-files); do
    a=$(sha256sum "/tmp/ue-skills-ref/$f" | cut -d' ' -f1)
    b=$(sha256sum ".../upstream/$f" | cut -d' ' -f1)
    [ "$a" = "$b" ] && echo "IDENTICAL  $f" || echo "DIFFER     $f"
  done
IDENTICAL  .claude-plugin/plugin.json
IDENTICAL  .gitignore
IDENTICAL  CODEOWNERS
IDENTICAL  LICENSE
IDENTICAL  README.md
IDENTICAL  hooks/hooks.json
IDENTICAL  hooks/unreal-context.sh
IDENTICAL  skills/create-toolset/SKILL.md
IDENTICAL  skills/unreal-mcp/SKILL.md
IDENTICAL  skills/unreal-mcp/references/operations.md
IDENTICAL  skills/unreal-mcp/references/setup.md
IDENTICAL  skills/unreal-skill/SKILL.md
```

12/12 identical, 0 differing. LICENSE specifically:

```
$ sha256sum .../upstream/LICENSE /tmp/ue-skills-ref/LICENSE
5b337be051359edcdec510103aee15f5f870efb38b6d42eecd685dc3582314a6  .../upstream/LICENSE
5b337be051359edcdec510103aee15f5f870efb38b6d42eecd685dc3582314a6  /tmp/ue-skills-ref/LICENSE

$ wc -lc .../upstream/LICENSE /tmp/ue-skills-ref/LICENSE
  21 1073 .../upstream/LICENSE
  21 1073 /tmp/ue-skills-ref/LICENSE
```

The vendored provenance manifest independently agrees — all 12
entries verify against the vendored bytes:

```
$ cd corpus/knowledge/unreal-mcp && cat .manifest.d/*.sha256 | sha256sum -c
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
   (+ the same 12 repeated from the second concatenated manifest shard — all OK)
```

The `.manifest.d/` directory holds 11 shard files
(`seat01.sha256` … `seat11.sha256`) covering the 12 files
(`seat11.sha256` carries two entries: `CODEOWNERS` and `.gitignore`).
No `FAILED` line appeared in the `sha256sum -c` output.

### L4 — LICENSE full text, numbered

```
$ cat -n .../upstream/LICENSE
 1	MIT License
 2	
 3	Copyright (c) 2026 Epic Games, Inc.
 4	
 5	Permission is hereby granted, free of charge, to any person obtaining a copy
 6	of this software and associated documentation files (the "Software"), to deal
 7	in the Software without restriction, including without limitation the rights
 8	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 9	copies of the Software, and to permit persons to whom the Software is
10	furnished to do so, subject to the following conditions:
11	
12	The above copyright notice and this permission notice shall be included in all
13	copies or substantial portions of the Software.
14	
15	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
16	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
17	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
18	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
19	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
20	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
21	SOFTWARE.
```

`cat -A` shows every line terminated by a bare `$` (LF), no CR, and no
BOM on line 1.

### L5 — plugin metadata declares the same license

```
$ cat /tmp/ue-skills-ref/.claude-plugin/plugin.json
{
  "name": "unreal-engine-skills-for-claude-code",
  "version": "3.1.1",
  "description": "Control Unreal Editor directly from Claude Code via MCP. ...",
  "author": {
    "name": "Thomas Mansencal",
    "email": "thomas.mansencal@epicgames.com"
  },
  "license": "MIT"
}
```

### L6 — repo metadata via authenticated `gh`

```
$ gh api repos/EpicGames/unreal-engine-skills-for-claude-code-plugin \
    --jq '{name,visibility,license:.license.spdx_id,html:.html_url,default_branch}'
{"default_branch":"main",
 "html":"https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin",
 "license":"MIT",
 "name":"unreal-engine-skills-for-claude-code-plugin",
 "visibility":"public"}

$ gh api repos/EpicGames/unreal-engine-skills-for-claude-code-plugin/commits/a6aa73a... \
    --jq '{sha:.sha,date:.commit.author.date}'
{"date":"2026-09-17T01:19:50Z","sha":"a6aa73ada02a9fb1f5415bec491f9942c519b297"}
```

The repo is **public** and GitHub's own classifier reports the SPDX id
`MIT`; the pinned commit's author date matches the clone's
(`2026-09-17T01:19:50Z`).

### L7 — no other license/notice terms in the tree

```
$ cd /tmp/ue-skills-ref && grep -rn -iE 'licen[cs]e|copyright|apache|GPL|BSD|third.party|attribut' \
    --include='*' . --exclude-dir=.git | grep -v '^./LICENSE'
./skills/unreal-skill/SKILL.md:53:Decorate the class with `@agent_skill` and inherit from `unreal.AgentSkill`. ...
./skills/unreal-skill/SKILL.md:56:- `instructions` is a class attribute string containing the guidance ...
./.claude-plugin/plugin.json:9:  "license": "MIT"
```

Only the `plugin.json` license field and two substring false positives
(`inherit`, `attribute`) — no NOTICE, no third-party terms.

### L8 — no per-file license headers

```
$ grep -rn -iE 'SPDX|Copyright \(c\)|Licensed under' --include='*' . --exclude-dir=.git
./LICENSE:3:Copyright (c) 2026 Epic Games, Inc.
```

The only copyright assertion in the repository is the single line in
`LICENSE`.

---

## 5. Limits — what this audit does and does not establish

- **Scope of the grant.** MIT here covers the plugin repository's 12
  files. It says nothing about Unreal Engine, the Unreal Editor, or the
  `ModelContextProtocol`/`AllToolsets` plugins, which the README lists
  as prerequisites and which are governed by Epic's separate EULA.
  None of those are vendored, so nothing in this corpus is redistributed
  under a term other than MIT — but the corpus must not be read as
  carrying any engine rights.
- **Trademark.** MIT grants no trademark or endorsement rights. The
  corpus may describe and cite the upstream project; it must not
  present "Unreal" or "Epic Games" as endorsing the lane.
- **VCS state observed.** `corpus/knowledge/unreal-mcp/` is currently
  **untracked** in this repo: `git status --short` shows
  `?? corpus/knowledge/unreal-mcp/`, `git ls-files corpus/knowledge/unreal-mcp`
  is empty, and `git check-ignore` reports no ignore rule covering it
  (the repo has no root `.gitignore`; `corpus/.gitignore` excludes only
  `live/`, `__pycache__/`, `*.pyc`). The lane remote
  `VeigaPunk/shokunin-3d-engines` is **PUBLIC** (`gh repo view … --json visibility`
  → `"visibility":"PUBLIC"`). This does not change the license
  conclusion — MIT permits public redistribution with notice retained
  — but it means that if this tree is committed, a verbatim MIT-licensed
  copy will be published, which is permitted but should be a deliberate
  choice. Flagging it for the L1; the audit itself needed no commit.
- **Not legal advice.** The verdict is a reading of the license text
  and the receipts above by a non-lawyer.
- **No runtime claim.** This seat makes no statement about the MCP
  server, the Unreal Editor, or any live-editor behavior. Unreal Editor
  is not installed on this host; every runtime claim in this round
  remains unproven-on-this-host by construction.

---

## 6. Paths touched

- Written: `reports/round-101/probes/license-audit.md` (this file).
- Read only: `corpus/knowledge/unreal-mcp/upstream/**`,
  `corpus/knowledge/unreal-mcp/.manifest.d/**`, `corpus/README.md`,
  `corpus/.gitignore`, `PROVINCE.md`.
- Read only, outside the repo: `/tmp/ue-skills-ref/**` (verified at the
  pinned SHA before use).
- No commit, no push, no modification of any pre-existing round-101
  file, `LOG.md`, `SCORECARD.md`, `SHONEN.md`, `SKILL.md`, or
  `PROVINCE.md`.
